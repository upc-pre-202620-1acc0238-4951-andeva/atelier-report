# Radiografía Técnica y Análisis Arquitectónico Profundo: `atelier-platform` (Backend v1)

Este documento contiene la radiografía técnica y el análisis exhaustivo a nivel de código fuente de la **primera versión del backend de Atelier** (`com.andeva.atelier.platform`), ubicada físicamente en `/home/shouy/development/atelier-platform`.

El propósito de este análisis es desglosar la totalidad de las **624 clases Java**, sus **27 tablas relacionales en PostgreSQL**, sus flujos de eventos, agregados, comandos, consultas, endpoints REST e integraciones externas, contrastándolos con el estándar de referencia del docente ([docs/backend-documentation/learning-center-platform-reference.md](file:///home/shouy/development/atelier-report/docs/backend-documentation/learning-center-platform-reference.md)) y formalizando la **Matriz Maestra de Transición** hacia los **8 Bounded Contexts definitivos** establecidos en la arquitectura de Atelier.

---

## 1. Ficha Técnica del Backend v1

| Parámetro | Especificación en `atelier-platform` (v1) |
| :--- | :--- |
| **Ubicación Local** | `/home/shouy/development/atelier-platform` |
| **Espacio de Nombres Raíz** | `com.andeva.atelier.platform` |
| **Versión de Lenguaje y Runtime** | Java 26 (OpenJDK 64-Bit Server VM) |
| **Framework Base** | Spring Boot 4.0.6 (Spring Framework 7.x) |
| **Volumen de Código** | **624 archivos Java**, 8 paquetes principales |
| **Motor de Base de Datos** | PostgreSQL (Dialecto `org.hibernate.dialect.PostgreSQLDialect`) |
| **Esquema Relacional DDL** | 27 tablas, 19 triggers de auditoría, 1 trigger de sincronización de stock |
| **Estrategia de Nombres Físicos** | `SnakeCaseWithPluralizedTablePhysicalNamingStrategy` (con biblioteca `pluralize`) |
| **Identificadores de Entidad** | Claves primarias universales `UUID` con `@GeneratedValue(strategy = GenerationType.UUID)` |
| **Estilo Arquitectónico** | **Hexagonal / Clean Architecture + DDD Onion** (Separación estricta entre Dominio Puro y Persistencia JPA) |
| **Seguridad y Autorización** | Spring Security + JJWT (`io.jsonwebtoken:jjwt-api:0.12.6`), Stateless Bearer JWT |
| **Facturación Externa** | Facthub Electronic Invoicing REST API (`https://facthub-service.onrender.com`) |
| **Servicio de Correo** | SMTP tradicional con Spring Mail (`smtp.gmail.com:587` vía TLS) |
| **Módulos Existentes** | `shared` (23), `iam` (66), `core` (149), `fleet` (75), `operations` (89), `inventory` (35), `billing` (63), `iot` (123) |

---

## 2. Paradigma Arquitectónico en v1: Hexagonal DDD Decoupled

Un hallazgo crucial en `atelier-platform` es que el equipo implementó una variante rigurosa de **Arquitectura Hexagonal (Puertos y Adaptadores)** aplicada a Domain-Driven Design:

1. **Agregados de Dominio Puros (Domain Layer):**
   Los agregados en `domain.model.aggregates` (como `WorkOrder`, `Product`, `Quote`, `User`) **no contienen anotaciones de JPA** (`@Entity`, `@Table`, `@Column`, `@Id`). Extienden de `AbstractDomainAggregateRoot<T>`, una clase base del Shared Kernel que hereda de Spring Data Commons `AbstractAggregateRoot` únicamente para ganar la capacidad de registrar eventos de dominio en memoria (`registerDomainEvent()`).
2. **Entidades de Persistencia Separadas (Infrastructure Layer):**
   En `infrastructure.persistence.jpa.entities`, residen las entidades JPA físicas con el sufijo `*PersistenceEntity` (o `*JpaEntity`), las cuales extienden de `AuditableAbstractPersistenceEntity` y contienen todos los mapeos ORM `@Entity`, `@Table`, `@Column`, `@JoinColumn` y claves foráneas.
3. **Assemblers de Persistencia Bidireccionales:**
   En `infrastructure.persistence.jpa.assemblers`, clases como `WorkOrderPersistenceAssembler` o `UserPersistenceAssembler` transforman los agregados puros a entidades JPA (`toEntity`) y reconstituyen agregados de dominio a partir de entidades JPA (`toDomain`).
4. **Adaptadores de Repositorio (Repository Adapters):**
   En `infrastructure.persistence.jpa.adapters`, clases como `WorkOrderRepositoryImpl` implementan las interfaces del dominio (`WorkOrderRepository`), inyectan el `WorkOrderPersistenceRepository` (que extiende `JpaRepository<WorkOrderPersistenceEntity, UUID>`), convierten entidades con el assembler y despachan los eventos de dominio acumulados (`domainEvents()`).
5. **Separación de REST DTOs y Dominio:**
   Los controladores REST nunca exponen agregados ni reciben entidades. Emplean `Resource` records inmutables y transformadores dedicados (`*ResourceFromAggregateAssembler` y `*CommandFromResourceAssembler`).

```
┌────────────────────────────────────────────────────────────────────────┐
│                          INTERFACES LAYER                              │
│   WorkOrdersController ──> WorkOrderCommandFromResourceAssembler       │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │ Command / Query (Record)
┌────────────────────────────────────▼───────────────────────────────────┐
│                         APPLICATION LAYER                              │
│   WorkOrderCommandServiceImpl ──> Inyecta WorkOrderRepository (Domain) │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │ Port Interface
┌────────────────────────────────────▼───────────────────────────────────┐
│                            DOMAIN LAYER                                │
│   WorkOrder (Pure Aggregate) ──> registerDomainEvent(ProductReserved)   │
│   WorkOrderRepository (Interface)                                      │
└────────────────────────────────────▲───────────────────────────────────┘
                                     │ Implements
┌────────────────────────────────────┴───────────────────────────────────┐
│                       INFRASTRUCTURE LAYER                             │
│   WorkOrderRepositoryImpl (Adapter)                                    │
│   ├── WorkOrderPersistenceAssembler (Domain <-> JPA Mapping)          │
│   └── WorkOrderPersistenceRepository (Spring Data JpaRepository)       │
│   WorkOrderPersistenceEntity (@Entity, @Table(name = "work_orders"))  │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Análisis Profundo del Shared Kernel (`com.andeva.atelier.platform.shared`)

El paquete `shared` cuenta con 23 archivos Java y provee los cimientos transversales para toda la plataforma:

### 3.1 `AuditableAbstractPersistenceEntity`
Superclase mapeada que estandariza la auditoría física y los identificadores en PostgreSQL:
```java
@Getter
@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
public abstract class AuditableAbstractPersistenceEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Setter
    @Column(columnDefinition = "uuid", updatable = false, nullable = false)
    private UUID id;

    @CreatedDate
    @Setter
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @LastModifiedDate
    @Setter
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;
}
```

### 3.2 `AbstractDomainAggregateRoot<T>`
Permite a los agregados desacoplarse de JPA y despachar eventos de dominio internamente:
* **Método `registerDomainEvent(Object event)`:** Invoca `super.registerEvent(event)` de Spring Data Commons.
* **Método `domainEvents()`:** Expone la colección de eventos registrados para que el adaptador JPA los publique vía Spring `ApplicationEventPublisher`.
* **Método `clearDomainEvents()`:** Limpia la cola una vez persistido el agregado.

### 3.3 Patrón Funcional `Result<T, E>` y `ApplicationError`
Estandariza la respuesta de los servicios de aplicación sin propagar excepciones descontroladas:
* `Result<T, E>` es una interfaz sellada (`sealed interface`) con dos implementaciones inmutables: `Success<T, E>(T value)` y `Failure<T, E>(E error)`.
* `ApplicationError`: Contiene `code`, `message` y `details` opcionales.
* `ResponseEntityAssembler`: Traduce los objetos `Result` a `ResponseEntity<T>` o `ResponseEntity<ErrorResource>` con los códigos HTTP correspondientes (`200 OK`, `201 CREATED`, `400 BAD REQUEST`, `404 NOT FOUND`, `409 CONFLICT`).

### 3.4 Value Objects Compartidos y Attribute Converters
* **`Money`:** Encapsula `BigDecimal amount` y `Currency currency`. Incluye operaciones `add()`, `subtract()`, `multiply()`, comparaciones seguras y `MoneyAttributeConverter` para guardar el valor numérico en PostgreSQL.
* **`Mileage`:** Encapsula kilometraje automotriz como entero no negativo, con `MileageAttributeConverter`.
* **`Address`:** Encapsula la dirección física formateada, mapeada mediante `AddressAttributeConverter`.
* **`BranchId`, `CustomerId`, `VehicleId`:** Value Objects tipados sobre `UUID` para garantizar *Type Safety* y evitar intercambiar accidentalmente identificadores foráneos.

### 3.5 Eventos de Integración Compartidos
* **`PaymentProcessedEvent(UUID workOrderId)`:** Evento que desacopla la facturación de las operaciones de taller, permitiendo marcar órdenes de trabajo como pagadas sin acoplamiento directo entre módulos.

---

## 4. Radiografía Exhaustiva Módulo por Módulo (v1)

```
Resumen de Distribución de Archivos (624 clases Java):
├── core:         149 clases (23.9%)  <-- "God Module"
├── iot:          123 clases (19.7%)  <-- OBD2, Telemática y Vehículos
├── operations:    89 clases (14.3%)  <-- MRO, Tareas y Catálogo
├── fleet:         75 clases (12.0%)  <-- Citas y Asignaciones
├── iam:           66 clases (10.6%)  <-- Autenticación y Cuentas
├── billing:       63 clases (10.1%)  <-- Cotizaciones, Facturas y Facthub
├── inventory:     35 clases  (5.6%)  <-- Repuestos y Lotes
└── shared:        23 clases  (3.7%)  <-- Núcleo transversal
```

---

### 4.1 Módulo `iam` (66 archivos Java)

#### A. Responsabilidad en v1
Gestión del ciclo de vida de credenciales de usuario, login por correo/contraseña, federación con Google OAuth2 y restablecimiento de contraseña vía tokens temporales enviados por correo SMTP.

#### B. Componentes Técnicos Detallados
* **Agregado Raíz:** `User` (atributos: `id: UserId`, `email: EmailAddress`, `password: Password` [BCrypt Hash], `googleId: GoogleId`, `status: String`, `createdAt`, `updatedAt`, `deletedAt`, `version`).
* **Entidad Interna:** `PasswordRecoveryToken` (atributos: `id: UUID`, `tokenHash: String`, `createdAt: LocalDateTime`, `expiresAt: LocalDateTime`, `isUsed: boolean`, `userId: UUID`).
* **Value Objects:** `UserId(UUID)`, `EmailAddress(String)`, `Password(String)`, `GoogleId(String)`.
* **Comandos (Records):**
  * `SignUpCommand(EmailAddress email, Password password)`
  * `SignInCommand(EmailAddress email, Password password)`
  * `GoogleSignInCommand(String idToken)`
  * `GeneratePasswordRecoveryTokenCommand(EmailAddress email)`
  * `ResetPasswordCommand(String token, Password newPassword)`
  * `UpdateUserEmailCommand(UserId userId, EmailAddress newEmail)`
  * `UpdateUserPasswordCommand(UserId userId, Password currentPassword, Password newPassword)`
* **Consultas (Records):**
  * `GetUserByIdQuery(UserId userId)`
  * `GetUserByEmailQuery(EmailAddress email)`
  * `AuthenticatedUser(User user, String token)`
* **Infraestructura y Seguridad:**
  * `WebSecurityConfiguration`: Configuración de filtros stateless de Spring Security, desactivación de CSRF, políticas de CORS.
  * `BearerAuthorizationRequestFilter`: Interceptor `OncePerRequestFilter` que valida la cabecera `Authorization: Bearer <jwt>`, decodifica los claims con JJWT y establece el `SecurityContextHolder`.
  * `UserDetailsServiceImpl`: Implementación de `UserDetailsService` que recupera el usuario y construye `UserDetailsImpl`.
  * `TokenServiceImpl`: Generación y firma de tokens JWT usando clave secreta HMAC-SHA256 (`jjwt:0.12.6`).
  * `HashingServiceImpl`: Cifrado y verificación de hashes mediante `BCryptPasswordEncoder`.
  * `SmtpEmailService`: Despacho de correos HTML mediante `JavaMailSender` apuntando a `smtp.gmail.com:587`.
* **Persistencia:**
  * Entidades JPA: `UserPersistenceEntity` (`users`), `PasswordRecoveryTokenPersistenceEntity` (`password_recovery_tokens`).
  * Repositorio y Adaptador: `UserRepositoryImpl` implementando `UserRepository`, delegando en `UserPersistenceRepository`.

#### C. Catálogo de Endpoints REST
| Método | Ruta Endpoint | Recurso Entrada | Recurso Retorno | Propósito |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/api/v1/authentication/sign-up` | `SignUpResource` | `AuthenticatedUserResource` | Registro local de nuevo usuario |
| `POST` | `/api/v1/authentication/sign-in` | `SignInResource` | `AuthenticatedUserResource` | Autenticación local y emisión de JWT |
| `POST` | `/api/v1/authentication/google-sign-in` | `GoogleSignInResource` | `AuthenticatedUserResource` | Autenticación federada mediante token de Google |
| `POST` | `/api/v1/authentication/password-recovery` | `PasswordRecoveryResource` | `MessageResource` | Generación de token y envío de email SMTP |
| `POST` | `/api/v1/authentication/reset-password` | `ResetPasswordResource` | `MessageResource` | Canje de token y actualización de contraseña |
| `GET` | `/api/v1/users/{userId}` | - | `UserResource` | Consulta de perfil de usuario por ID |
| `GET` | `/api/v1/users?email={email}` | - | `UserResource` | Consulta de usuario por correo |
| `PUT` | `/api/v1/users/{userId}/email` | `UpdateUserEmailResource` | `AuthenticatedUserResource` | Cambio de correo y reemisión de JWT |
| `PUT` | `/api/v1/users/{userId}/password` | `UpdateUserPasswordResource` | `MessageResource` | Cambio de contraseña validando la anterior |

#### D. Diagnóstico Crítico de Brechas
1. **Falta de Multitenancy Nativo:** La tabla `users` no contiene `tenant_id`. Un usuario no pertenece a un taller en la capa de seguridad; las autorizaciones estaban completamente desacopladas de las membresías.
2. **Falla Crítica de Despliegue (SMTP):** El servicio `SmtpEmailService` utiliza el puerto 587 hacia Gmail. En plataformas PaaS como Render o Railway, los puertos SMTP salientes (25, 465, 587) están bloqueados para evitar spam, lo que provoca que el restablecimiento de contraseñas falle sistemáticamente. En v2 se reemplaza por la **API REST HTTPS de Resend (puerto 443)**.
3. **Ausencia de RBAC Dinámico:** Los roles no estaban formalizados con entidades de permisos; se deducían según si el usuario existía en la tabla `owners`, `employees` o `customers`.

---

### 4.2 Módulo `core` (149 archivos Java) — El "Módulo Dios"

#### A. Responsabilidad en v1
En v1, `core` representaba el 24% de todo el código de la plataforma. Agrupaba de manera indiscriminada la gestión de empresas (talleres), sedes físicas (sucursales), perfiles de personas (dueños, empleados, clientes) y los contratos de suscripción SaaS del propio software Atelier.

#### B. Componentes Técnicos Detallados
* **Agregados Coexistentes en el Paquete:**
  1. `Workshop`: Empresa de taller automotriz (`id: WorkshopId`, `ownerId: OwnerId`, `businessName: String`, `brandName: String`, `taxId: TaxId` [RUC 11 dígitos], `mileageIntervalConfig: int`, auditoría).
  2. `Branch`: Sede física (`id: BranchId`, `workshopId: WorkshopId`, `code: String`, `name: String`, `address: Address`, `phone: Phone`, auditoría).
  3. `Owner`: Dueño del taller (`id: OwnerId`, `userId: UserId`, `name: PersonName`, `document: Document`, `phone: Phone`, auditoría).
  4. `Employee`: Empleado/Mecánico (`id: EmployeeId`, `userId: UserId`, `name: PersonName`, `document: Document`, `phone: Phone`, auditoría).
  5. `Customer`: Cliente dueño de autos (`id: CustomerId`, `userId: UserId`, `isCorporate: boolean`, `name: PersonName`, `businessName: String`, `document: Document`, `phone: Phone`, auditoría).
  6. `SubscriptionPlan`: Catálogo de planes SaaS (`id: SubscriptionPlanId`, `name: String`, `monthlyPrice: double`, `maxObd2Devices: int`, `maxMonthlySnapshotsPerVehicle: int`, `maxCustomers: int`, `maxStaffAccounts: int`, `isActive: boolean`).
  7. `BranchSubscription`: Contrato de suscripción (`id: BranchSubscriptionId`, `branchId: BranchId`, `planId: SubscriptionPlanId`, `status: SubscriptionStatus`, `billingCycle: BillingCycle`, fechas).
* **Value Objects:** `WorkshopId`, `BranchId`, `OwnerId`, `EmployeeId`, `CustomerId`, `SubscriptionPlanId`, `BranchSubscriptionId`, `TaxId`, `Document`, `DocumentType` (`DNI`, `RUC`), `PersonName` (`firstName`, `lastName`), `Phone`, `CreditCard`, `BillingCycle` (`MONTHLY`, `ANNUAL`), `SubscriptionStatus` (`ACTIVE`, `CANCELED`).
* **Comandos (15 records):** `CreateWorkshopCommand`, `UpdateWorkshopCommand`, `CreateBranchCommand`, `UpdateBranchCommand`, `CreateOwnerCommand`, `UpdateOwnerCommand`, `DeleteOwnerCommand`, `CreateEmployeeCommand`, `UpdateEmployeeCommand`, `DeleteEmployeeCommand`, `CreateCustomerCommand`, `UpdateCustomerCommand`, `DeleteCustomerCommand`, `AssignSubscriptionCommand`, `CancelSubscriptionCommand`.
* **Consultas (13 records):** `GetWorkshopByIdQuery`, `GetAllWorkshopsByOwnerIdQuery`, `GetBranchByIdQuery`, `GetAllBranchesByWorkshopIdQuery`, `GetOwnerByIdQuery`, `GetOwnerByUserIdQuery`, `GetEmployeeByIdQuery`, `GetEmployeeByUserIdQuery`, `GetEmployeeByDocumentNumberQuery`, `GetCustomerByIdQuery`, `GetCustomerByUserIdQuery`, `GetProfileByDocumentNumberQuery`, `GetProfileRolesByUserIdQuery`.

#### C. Catálogo de Endpoints REST
| Método | Ruta Endpoint | Acción / Controlador |
| :--- | :--- | :--- |
| `POST` | `/api/v1/workshops` | Creación de empresa taller (`WorkshopsController`) |
| `PUT` | `/api/v1/workshops/{workshopId}` | Actualización de datos de taller |
| `GET` | `/api/v1/workshops/{workshopId}` | Consulta de taller por ID |
| `GET` | `/api/v1/workshops?ownerId={ownerId}` | Lista de talleres de un propietario |
| `POST` | `/api/v1/branches` | Creación de sucursal física (`BranchesController`) |
| `PUT` | `/api/v1/branches/{branchId}` | Actualización de sucursal |
| `GET` | `/api/v1/branches/{branchId}` | Consulta de sucursal por ID |
| `GET` | `/api/v1/branches?workshopId={workshopId}` | Lista de sucursales de un taller |
| `POST` | `/api/v1/branches/{branchId}/subscriptions` | Asignación de suscripción SaaS a una sede |
| `POST` | `/api/v1/owners` | Creación de perfil propietario (`OwnersController`) |
| `PUT` | `/api/v1/owners/{ownerId}` | Actualización de datos de dueño |
| `GET` | `/api/v1/owners/{ownerId}` | Consulta de dueño por ID |
| `GET` | `/api/v1/owners?userId={userId}` | Consulta de dueño por usuario IAM |
| `POST` | `/api/v1/employees` | Registro de empleado (`EmployeesController`) |
| `PUT` | `/api/v1/employees/{employeeId}` | Actualización de empleado |
| `GET` | `/api/v1/employees/{employeeId}` | Consulta de empleado por ID |
| `GET` | `/api/v1/employees?userId={userId}` | Consulta de empleado por usuario IAM |
| `POST` | `/api/v1/customers` | Creación de cliente (`CustomersController`) |
| `PUT` | `/api/v1/customers/{customerId}` | Actualización de cliente |
| `GET` | `/api/v1/customers/{customerId}` | Consulta de cliente por ID |
| `GET` | `/api/v1/customers?userId={userId}` | Consulta de cliente por usuario IAM |
| `GET` | `/api/v1/profiles/roles?userId={userId}` | Obtiene los roles de un usuario en los perfiles |
| `GET` | `/api/v1/profiles?documentNumber={doc}` | Busca perfiles por documento de identidad |

#### D. Diagnóstico Crítico de Brechas
1. **Triplicación de la Persona:** Si una misma persona humana es dueño de taller y a la vez registra su propio auto como cliente, el sistema obligaba a crear un registro en `users`, otro en `owners` y otro en `customers`.
2. **Onboarding Frágil en Cascada (Frontend Nightmare):** Para activar un taller, el frontend de React tenía que disparar secuencialmente: `POST /owners` -> esperar ID -> `POST /workshops` -> esperar ID -> `POST /branches` -> esperar ID -> `POST /subscriptions`. Si el paso 3 o 4 fallaba por red, quedaban entidades huérfanas en la base de datos sin rollback.
3. **Suscripción ligada a Sucursal:** `BranchSubscription` vinculaba la suscripción a nivel de sede física en vez de a nivel de empresa/inquilino (`tenant`).
4. **Tarjetas Simuladas:** El registro de suscripción recibía campos de tarjeta en texto plano simulados sin pasarela de pagos real (Stripe).

---

### 4.3 Módulo `fleet` (75 archivos Java)

#### A. Responsabilidad en v1
Gestión de citas de servicio agendadas por clientes, control de asignación de empleados a sucursales y vinculación de clientes a sedes.

#### B. Componentes Técnicos Detallados
* **Agregados:**
  1. `Appointment`: Cita de taller (`id: UUID`, `branchId: BranchId`, `customerId: CustomerId`, `vehicleId: VehicleId`, `scheduledStart: LocalDateTime`, `scheduledEnd: LocalDateTime`, `status: AppointmentStatus` [`PENDING`, `COMPLETED`, `CANCELED`], `notes: AppointmentSummary`, auditoría).
  2. `CustomerRegistration`: Enlace de cliente con sucursal (`id: CustomerId`, `customerId: UUID`, `branchId: BranchId`, `status: CustomerRegistrationStatus`).
  3. `EmployeeRegistration`: Asignación operativa de personal a sucursal (`id: EmployeeId`, `employeeId: UUID`, `branchId: BranchId`, `speciality: String`, `specialityName: String`, `salary: BigDecimal`, `status: EmployeeRegistrationStatus`).
* **Value Objects:** `AppointmentStatus`, `AppointmentSummary` (valida texto hasta 2000 caracteres), `CustomerRegistrationStatus`, `EmployeeRegistrationStatus`.
* **Comandos (9 records):** `CreateAppointmentCommand`, `UpdateAppointmentCommand`, `DeleteAppointmentCommand`, `CreateCustomerRegistrationCommand`, `UpdateCustomerRegistrationCommand`, `DeleteCustomerRegistrationCommand`, `CreateEmployeeRegistrationCommand`, `UpdateEmployeeRegistrationCommand`, `DeleteEmployeeRegistrationCommand`.
* **Consultas (5 records):** `GetCustomerRegistrationByCustomerIdQuery`, `GetEmployeeRegistrationByIdQuery`, `GetEmployeeRegistrationByEmployeeIdQuery`, `GetEmployeeRegistrationsByBranchIdQuery`, `GetEmployeeRegistrationsByBranchIdAndStatusQuery`.

#### C. Catálogo de Endpoints REST
| Método | Ruta Endpoint | Recurso Entrada / Acción |
| :--- | :--- | :--- |
| `POST` | `/api/v1/appointments` | Creación de cita (`CreateAppointmentResource`) |
| `PUT` | `/api/v1/appointments/{id}` | Modificación de fecha, hora y notas |
| `DELETE`| `/api/v1/appointments/{id}` | Cancelación o borrado lógico de cita |
| `GET` | `/api/v1/appointments` | Búsqueda de citas por sucursal, cliente o fecha |
| `GET` | `/api/v1/appointments/{id}` | Consulta de cita individual por ID |
| `POST` | `/api/v1/customer-registrations` | Vinculación de un cliente a una sede |
| `PUT` | `/api/v1/customer-registrations/{id}` | Cambio de estado de la vinculación del cliente |
| `POST` | `/api/v1/employee-registrations` | Asignación de empleado a sede con salario y especialidad |
| `PUT` | `/api/v1/employee-registrations/{id}` | Actualización de salario y especialidad del empleado |
| `DELETE`| `/api/v1/employee-registrations/{id}` | Desactivación de empleado de la sede |

#### D. Diagnóstico Crítico de Brechas
1. **Confusión Conceptual de Recursos Humanos:** La gestión de especialidades técnicas (`speciality`) y salarios (`salary`) estaba incrustada en un módulo llamado `fleet` (Flotas). En v2, toda la relación contractual y de compensación se traslada al **Human Resources Management Context (HR)**.
2. **Falta de Detección de Conflictos de Horario:** La cita no verificaba la disponibilidad real de bahías físicas ni la carga de trabajo de los mecánicos al agendar.

---

### 4.4 Módulo `operations` (89 archivos Java) — El Núcleo MRO

#### A. Responsabilidad en v1
Es el núcleo de reparación vehicular (Maintenance, Repair, and Overhaul - MRO). Administra el ciclo de vida de la orden de trabajo (`WorkOrder`), las tareas individuales asignadas a los mecánicos (`WorkOrderTask`), los repuestos consumidos por cada tarea (`WorkOrderTaskProduct`) y el catálogo de servicios estándar (`Service`).

#### B. Componentes Técnicos Detallados
* **Agregado Raíz `WorkOrder`:**
  * Atributos: `id: WorkOrderId`, `appointmentId: AppointmentId`, `branchId: BranchId`, `vehicleId: VehicleId`, `customerId: CustomerId`, `internalNumber: Integer`, `status: WorkOrderStatus` (`PENDING`, `IN_PROGRESS`, `COMPLETED`, `PAID`), `diagnosticSummary: DiagnosticSummary`, `mileageIn: Mileage`, `totalAmount: Money`, `tasks: List<WorkOrderTask>`, auditoría.
* **Entidad `WorkOrderTask`:**
  * Atributos: `id: WorkOrderTaskId`, `serviceId: ServiceId`, `branchId: BranchId`, `assignedMechanicId: MechanicId`, `status: WorkOrderTaskStatus` (`PENDING`, `IN_PROGRESS`, `COMPLETED`), `description: TaskDescription`, `price: Money` (mano de obra), `startedAt: Instant`, `completedAt: Instant`, `products: List<WorkOrderTaskProduct>`.
* **Entidad `WorkOrderTaskProduct`:**
  * Atributos: `id: WorkOrderTaskProductId`, `productId: ProductId`, `branchId: BranchId`, `quantity: Quantity`, `unitPrice: Money`, `totalAmount: Money`.
* **Agregado `Service` (Catálogo):**
  * Atributos: `id: ServiceId`, `branchId: BranchId`, `name: String`, `price: Money`, auditoría.
* **Máquina de Estados y Lógica del Agregado `WorkOrder`:**
  * `addTask()`: Valida que la orden no esté `COMPLETED` o `PAID`, agrega la tarea y recalcula el monto total.
  * `addProductToTask()`: Agrega el repuesto a la tarea, recalcula el total y emite **`ProductReservedEvent`** hacia el inventario.
  * `removeProductFromTask()`: Elimina el producto, recalcula el total y emite **`ProductReservationCanceledEvent`**.
  * `removeTask()`: Si la tarea no está completada, cancela la reserva de todos sus repuestos y recalcula el total.
  * `startTask()`: Cambia la tarea a `IN_PROGRESS` y promueve la orden completa a `IN_PROGRESS`.
  * `completeTask()`: Cambia la tarea a `COMPLETED`. Si todas las tareas activas terminaron, la orden completa pasa automáticamente a `COMPLETED`.
  * `reopenTask()`: Regresa una tarea completada a `IN_PROGRESS` y reabre la orden de trabajo.
  * `recalculateTotalAmount()`: Suma iterativamente la mano de obra de cada tarea activa más `(unitPrice * quantity)` de cada repuesto consumido.
* **Eventos de Dominio:**
  * `ProductReservedEvent(Object source, BranchId branchId, ProductId productId, Quantity quantity)`
  * `ProductReservationCanceledEvent(Object source, BranchId branchId, ProductId productId, Quantity quantity)`
  * `WorkOrderPaidEvent(Object source, BranchId branchId, WorkOrderId workOrderId)`
* **Event Listeners:**
  * `WorkOrderPaymentListener`: Escucha `PaymentProcessedEvent` (emitido al pagar el comprobante en Facturación) y dispara automáticamente `MarkWorkOrderAsPaidCommand`.

#### C. Catálogo de Endpoints REST
| Método | Ruta Endpoint | Controlador | Propósito |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/v1/work-orders` | `WorkOrdersController` | Apertura de orden de trabajo con kilometraje de entrada |
| `GET` | `/api/v1/work-orders/{id}` | `WorkOrdersController` | Consulta detallada de orden con tareas y repuestos |
| `GET` | `/api/v1/work-orders?branchId={id}` | `WorkOrdersController` | Listado de órdenes de una sede |
| `PUT` | `/api/v1/work-orders/{id}` | `WorkOrdersController` | Actualización de diagnóstico o kilometraje |
| `DELETE`| `/api/v1/work-orders/{id}` | `WorkOrdersController` | Eliminación lógica (libera reservas de repuestos) |
| `POST` | `/api/v1/work-orders/{id}/tasks` | `WorkOrdersController` | Adición de tarea con mecánico asignado y precio de labor |
| `PUT` | `/api/v1/work-orders/{id}/tasks/{taskId}`| `WorkOrdersController` | Modificación de descripción y mano de obra |
| `DELETE`| `/api/v1/work-orders/{id}/tasks/{taskId}`| `WorkOrdersController` | Retiro de tarea y liberación de repuestos |
| `POST` | `/api/v1/work-order-tasks/{taskId}/start`| `WorkOrderTasksController`| Mecánico inicia la tarea (`IN_PROGRESS`) |
| `POST` | `/api/v1/work-order-tasks/{taskId}/complete`| `WorkOrderTasksController`| Mecánico marca tarea completada |
| `POST` | `/api/v1/work-order-tasks/{taskId}/reopen`| `WorkOrderTasksController`| Reanudación de tarea |
| `POST` | `/api/v1/work-order-tasks/{taskId}/products`| `WorkOrderTasksController`| Consumo de repuesto (reserva stock en inventario) |
| `PUT` | `/api/v1/work-order-tasks/{taskId}/products/{pId}`| `WorkOrderTasksController`| Ajuste de cantidad de repuesto consumido |
| `DELETE`| `/api/v1/work-order-tasks/{taskId}/products/{pId}`| `WorkOrderTasksController`| Retiro de repuesto (devuelve stock al inventario) |
| `POST` | `/api/v1/services` | `ServicesController` | Creación de servicio en catálogo |
| `GET` | `/api/v1/services?branchId={id}` | `ServicesController` | Catálogo de servicios por sucursal |

#### D. Diagnóstico Crítico de Brechas
1. **Falta de Bahías de Trabajo Físicas (`work_bays`):** No existía la asignación del vehículo a una bahía o elevador físico en el taller.
2. **Ausencia de Evidencias Fotográficas:** No había soporte para registrar fotos del estado del vehículo al ingresar ni de repuestos dañados. En v2 se implementa almacenamiento de imágenes *Direct-to-Cloud* en Firebase Storage.
3. **Cálculo de Precios Desacoplado en `Quote`:** La orden de trabajo calculaba `totalAmount`, pero el módulo de facturación volvía a calcular subtotales y descuentos en una entidad separada `Quote`, abriendo la posibilidad de inconsistencias de redondeo de centavos.

---

### 4.5 Módulo `inventory` (35 archivos Java)

#### A. Responsabilidad en v1
Gestión del catálogo de repuestos e insumos físicos del taller, control de existencias mediante lotes y atención a los eventos de reserva provenientes del módulo de operaciones.

#### B. Componentes Técnicos Detallados
* **Agregado Raíz `Product`:**
  * Atributos: `id: UUID`, `branchId: BranchId`, `category: ProductCategory`, `name: ProductName`, `sku: Sku`, `currentStock: InventoryQuantity`, `currentSellingPrice: Money`, `description: String`, `minimumStock: Integer`, `batches: List<ProductBatch>`.
  * Método `reserveStock(InventoryQuantity amount)`: Itera sobre la lista de lotes (`batches`), deduce de `availableQuantity` de cada lote y actualiza `currentStock`. Lanza `InsufficientStockException` si no hay existencias.
  * Método `releaseStock(InventoryQuantity amount)`: Repone existencias en los lotes con capacidad disponible hasta restaurar la reserva cancelada.
* **Entidad `ProductBatch`:**
  * Atributos: `batchId: UUID`, `initialQuantity: InventoryQuantity`, `availableQuantity: InventoryQuantity`, `acquisitionCost: Money`, `receptionDate: Date`, `version: Long`.
* **Event Listener `InventoryStockListener`:**
  * Escucha `ProductReservedEvent` -> busca producto por ID -> ejecuta `product.reserveStock()` -> persiste en JPA.
  * Escucha `ProductReservationCanceledEvent` -> ejecuta `product.releaseStock()` -> persiste en JPA.
  * Escucha `WorkOrderPaidEvent` -> no realiza deducción adicional porque el stock físico ya fue descontado en la reserva.
* **Trigger SQL en Base de Datos (`trg_sync_product_stock`):**
  * Función `sync_product_stock()`: Cada vez que un registro en `product_batches` sufre un `INSERT`, `UPDATE` o `DELETE`, recalcula automáticamente `products.current_stock` sumando `SUM(available_quantity)`.

#### C. Catálogo de Endpoints REST
| Método | Ruta Endpoint | Controlador | Propósito |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/v1/inventory/products` | `ProductsController` | Creación de nuevo producto/repuesto en catálogo |
| `GET` | `/api/v1/inventory/products?branchId={id}` | `ProductsController` | Listado de repuestos de una sucursal con stock actual |
| `GET` | `/api/v1/inventory/products/{id}` | `ProductsController` | Detalle de un producto con desglose de todos sus lotes |
| `PUT` | `/api/v1/inventory/products/{id}` | `ProductsController` | Actualización de nombre, SKU, precio y stock mínimo |
| `DELETE`| `/api/v1/inventory/products/{id}` | `ProductsController` | Eliminación de producto |
| `POST` | `/api/v1/inventory/products/{id}/batches` | `ProductsController` | Ingreso de nuevo lote físico con costo de adquisición |

#### D. Diagnóstico Crítico de Brechas
1. **FIFO Incompleto y sin Costeo Contable:** Aunque existían lotes, el método `reserveStock` consumía del primer lote en la lista en memoria (según el orden de carga del ORM), sin ordenar explícitamente por `reception_date ASC`. Más grave aún: no calculaba el Costo de Ventas (COGS) ponderado por lote para alimentar la contabilidad.
2. **Inexistencia de Proveedores (`suppliers`):** No había entidad de proveedores, ni órdenes de compra, ni relación con comprobantes de adquisición físicos o fotos escaneadas de facturas.

---

### 4.6 Módulo `billing` (63 archivos Java)

#### A. Responsabilidad en v1
Generación de cotizaciones (`Quote`), emisión de comprobantes de pago (`Voucher`) tipo Boleta o Factura, registro de pagos (`Payment`) y despacho electrónico hacia SUNAT mediante la API REST de Facthub.

#### B. Componentes Técnicos Detallados
* **Agregado `Quote`:**
  * Atributos: `id: UUID`, `workOrderId: UUID`, `branchId: BranchId`, `subtotalAmount: Money`, `discountPercentage: Double`, `totalAmount: Money`, `status: QuoteStatus` (`DRAFT`, `APPROVED`, `CANCELED`).
  * Métodos: `approve()` (valida estado `DRAFT` y pasa a `APPROVED`), `cancel()`, `updateDiscount(Double)`.
* **Agregado `Voucher`:**
  * Atributos: `id: UUID`, `quoteId: UUID`, `type: VoucherType` (`RECEIPT`, `INVOICE`), `customerDocumentType: String`, `customerDocumentNumber: String`, `customerName: String`, `totalAmount: Money`, `status: VoucherStatus` (`PENDING`, `PARTIALLY_PAID`, `PAID`, `CANCELED`), `externalInvoiceId: UUID` (retornado por Facthub), `payments: List<Payment>`.
  * Método `addPayment(Money amount, PaymentMethod method, UUID branchId)`: Suma los abonos; si `newTotalPaid == totalAmount`, pasa el estado a `PAID` y registra el evento **`VoucherPaidEvent`**.
* **Entidad `Payment`:**
  * Atributos: `id: UUID`, `amount: Money`, `method: PaymentMethod` (`CASH`, `CREDIT_CARD`, `DEBIT_CARD`, `BANK_TRANSFER`), `branchId: UUID`.
* **Capa Anticorrupción Outbound `FacthubGatewayImpl`:**
  * Cliente REST (`RestTemplate`) que serializa los datos a `FacthubIssueInvoiceRequest` y consume el endpoint de Facthub en Render (`${facthub.api.url}/api/v1/invoices`).
* **Coreografía de Eventos Inter-Módulo:**
  1. `Voucher.addPayment()` completa el pago total y emite `VoucherPaidEvent(this, voucherId, quoteId)`.
  2. `VoucherPaidListener` captura el evento, consulta `QuoteRepository` para obtener el `workOrderId` asociado, y despacha un `PaymentProcessedEvent(workOrderId)`.
  3. En el módulo `operations`, `WorkOrderPaymentListener` recibe `PaymentProcessedEvent` y ejecuta `MarkWorkOrderAsPaidCommand`, cambiando la orden a `PAID`.

```
┌─────────────────────────┐         ┌─────────────────────────┐         ┌─────────────────────────┐
│     VOUCHER (PAID)      │         │   VoucherPaidListener   │         │    WorkOrderPayment     │
│                         │         │        (Billing)        │         │   Listener (Operations) │
└────────────┬────────────┘         └────────────┬────────────┘         └────────────┬────────────┘
             │                                   │                                   │
             │ 1. Emite VoucherPaidEvent         │                                   │
             ├──────────────────────────────────>│                                   │
             │                                   │ 2. Busca quote.workOrderId        │
             │                                   │ 3. Emite PaymentProcessedEvent    │
             │                                   ├──────────────────────────────────>│
             │                                   │                                   │ 4. Ejecuta
             │                                   │                                   │    MarkWorkOrderAsPaid
             │                                   │                                   │    Command
```

#### C. Catálogo de Endpoints REST
| Método | Ruta Endpoint | Recurso Entrada | Propósito |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/v1/quotes` | `CreateQuoteResource` | Genera cotización para una orden de trabajo |
| `PUT` | `/api/v1/quotes/{id}` | `UpdateQuoteResource` | Actualiza el porcentaje de descuento comercial |
| `POST` | `/api/v1/quotes/{id}/approvals` | - | Cliente o asesor aprueba la cotización |
| `POST` | `/api/v1/quotes/{id}/cancellations` | - | Cancela la cotización |
| `GET` | `/api/v1/quotes/{id}` | - | Consulta detalle de cotización |
| `GET` | `/api/v1/quotes?branchId={id}` | - | Listado de presupuestos de una sede |
| `POST` | `/api/v1/vouchers` | `GenerateVoucherResource` | Emite boleta/factura vía Facthub |
| `GET` | `/api/v1/vouchers/{id}` | - | Consulta de comprobante y estado de saldo |
| `POST` | `/api/v1/vouchers/{id}/payments` | `AddPaymentResource` | Registra abono (efectivo, tarjeta, transferencia) |
| `POST` | `/api/v1/checkouts` | `ProcessCheckoutResource` | Pago directo y emisión en una sola transacción |

#### D. Diagnóstico Crítico de Brechas
1. **Acoplamiento con Servicio Externo In-house (Facthub):** Facthub era un microservicio inestable alojado en la capa gratuita de Render. En v2 se sustituye por la API formal de **Nubefact (API JSON V1)** con generación legal de UBL 2.1 ante SUNAT, XML firmado y código QR fiscal.
2. **Confusión entre Facturación Local y Suscripción SaaS:** En v1 se mezclaban conceptos de cobro al cliente final del taller con las suscripciones del taller a Atelier. En v2 se bifurcan en dos contextos separados: **Invoicing & Compliance Context** (para los clientes del taller) y **SaaS Billing & Subscriptions Context** (cobros de membresías del taller a través de Stripe).

---

### 4.7 Módulo `iot` (123 archivos Java)

#### A. Responsabilidad en v1
Captura y decodificación de datos de telemetría de vehículos mediante dispositivos OBD2 Bluetooth/WiFi, vinculación de dispositivos a automóviles, persistencia de métricas de motor y detección de códigos de falla DTC (Diagnostic Trouble Codes).

#### B. Componentes Técnicos Detallados
* **Agregados Residentes en el Módulo:**
  1. `Vehicle`: Datos técnicos del vehículo (`id: VehicleId`, `plateNumber: String`, `brand: String`, `model: String`, `year: Integer`, `vin: String`, auditoría).
  2. `VehicleRegistration`: Titularidad del vehículo ligada al usuario (`id: VehicleRegistrationId`, `userId: UUID`, `vehicleId: VehicleId`, `status: VehicleRegistrationStatus`).
  3. `Obd2Device`: Dispositivo telemático físico (`id: Obd2DeviceId`, `branchId: BranchId`, `macAddress: String`, `lastPing: Instant`, `status: Obd2DeviceStatus`).
  4. `Obd2DeviceRegistration`: Enlace entre dispositivo y vehículo (`id: Obd2DeviceRegistrationId`, `obd2DeviceId: Obd2DeviceId`, `branchId: BranchId`, `vehicleId: VehicleId`, `status: Obd2RegistrationStatus`).
  5. `TelemetrySnapshot`: Captura puntual de variables de motor (`id: TelemetrySnapshotId`, `obd2DeviceRegistrationId: Obd2DeviceRegistrationId`, `branchId: BranchId`, `rpm: Integer`, `temperature: Integer`, `speedKmh: Double`, `odometerKm: Integer`, `fuelLevelPercent: Double`, `createdAt: Instant`).
  6. `DtcAlert`: Alerta de avería detectada (`id: DtcAlertId`, `telemetrySnapshotId: UUID`, `branchId: BranchId`, `dtcCode: String`, `description: String`, `severity: DtcAlertSeverity` [`LOW`, `MEDIUM`, `HIGH`, `CRITICAL`]).
* **Value Objects:** `Obd2DeviceId`, `Obd2DeviceRegistrationId`, `TelemetrySnapshotId`, `DtcAlertId`, `VehicleRegistrationId`, `DtcAlertSeverity`, `Obd2DeviceStatus`, `Obd2RegistrationStatus`, `VehicleRegistrationStatus`.
* **Comandos (9 records):** `CreateObd2DeviceCommand`, `UpdateObd2DeviceCommand`, `DeleteObd2DeviceCommand`, `LinkObd2DeviceToVehicleCommand`, `DeactivateObd2DeviceRegistrationCommand`, `IngestTelemetryBatchCommand`, `RegisterVehicleCommand`, `UpdateVehicleCommand`, `DeleteVehicleCommand`.
* **Consultas (13 records):** `GetObd2DeviceByIdQuery`, `GetObd2DevicesByBranchIdQuery`, `GetAvailableObd2DevicesQuery`, `GetObd2DeviceRegistrationsByBranchIdAndStatusQuery`, `GetTelemetrySnapshotsByRegistrationIdQuery`, `GetLatestTelemetrySnapshotQuery`, `GetTelemetrySnapshotHistoryQuery`, `GetDtcAlertsByRegistrationIdQuery`, `GetVehicleByIdQuery`, `GetVehicleTelemetrySnapshotHistoryQuery`, `GetVehicleDtcAlertHistoryQuery`, `GetActiveVehiclesByCustomerIdQuery`, `GetVehiclesAvailableForLinkingQuery`.
* **Servicio de Ingesta Masiva `TelemetryCommandServiceImpl`:**
  * Recibe `IngestTelemetryBatchCommand` con una lista de mediciones.
  * Verifica la existencia del dispositivo y de su vinculación activa (`findActiveByObd2DeviceId`).
  * Actualiza la fecha de último ping del dispositivo (`device.ping()`).
  * Mapea y persiste la lista de snapshots llamando a `telemetrySnapshotRepository.saveAll(snapshotsToSave)`.

#### C. Catálogo de Endpoints REST
| Método | Ruta Endpoint | Controlador | Propósito |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/v1/telemetry-batches` | `TelemetryBatchesController` | Ingesta masiva de tramas telemétricas desde app móvil |
| `POST` | `/api/v1/obd2-devices` | `Obd2DevicesController` | Registro de dispositivo OBD2 en una sede |
| `GET` | `/api/v1/obd2-devices/{id}` | `Obd2DevicesController` | Consulta de dispositivo por ID |
| `GET` | `/api/v1/obd2-devices/{id}/telemetry-snapshots/latest` | `Obd2DevicesController` | Obtención de la última lectura en tiempo real |
| `GET` | `/api/v1/obd2-devices/{id}/telemetry-snapshots` | `Obd2DevicesController` | Historial de telemetría de un dispositivo |
| `POST` | `/api/v1/obd2-device-registrations` | `Obd2DeviceRegistrationsController` | Emparejamiento de OBD2 con un vehículo |
| `PATCH`| `/api/v1/obd2-device-registrations/{id}`| `Obd2DeviceRegistrationsController` | Desvinculación de dispositivo |
| `GET` | `/api/v1/obd2-device-registrations/{id}/dtc-alerts`| `Obd2DeviceRegistrationsController` | Lista de códigos de error reportados |
| `POST` | `/api/v1/vehicles` | `VehiclesController` | Registro técnico de vehículo (VIN, placa) |
| `GET` | `/api/v1/vehicles/{id}` | `VehiclesController` | Ficha técnica vehicular |
| `GET` | `/api/v1/vehicles/{id}/telemetry-snapshots` | `VehiclesController` | Métricas históricas del vehículo |
| `GET` | `/api/v1/customers/{customerId}/vehicles` | `CustomerVehiclesController` | Vehículos pertenecientes a un cliente |

#### D. Diagnóstico Crítico de Brechas
1. **Extravío del Agregado `Vehicle` en IoT:** El vehículo es la entidad central de un taller mecánico y pertenece conceptualmente a **Customer & Fleet Management (CRM)**, no a la telemetría OBD2.
2. **Cuello de Botella Masivo en PostgreSQL Estándar:** Cada vehículo con OBD2 transmite lecturas cada 5 a 10 segundos. Almacenar cada punto en una tabla PostgreSQL tradicional (`telemetry_snapshots`) con claves primarias aleatorias `UUID` e índices B-Tree provoca una degradación severa en las escrituras en disco y en el rendimiento de consultas a partir de ~100,000 filas. En v2 se migra obligatoriamente a una **Hipertabla Append-Only de TimescaleDB (`telemetry_logs`)** con compresión columnar automática.
3. **Ausencia de Notificaciones Push:** Las alertas DTC se guardaban pasivamente en base de datos sin notificar al conductor. En v2 se despachan en tiempo real vía **Firebase Cloud Messaging (FCM)** hacia la aplicación móvil.

---

## 5. Análisis del Esquema Relacional DDL de v1 (`atelier-platform/docs/atelier-schema.sql`)

El script de inicialización de base de datos definía **27 tablas físicas en PostgreSQL**, respaldadas por un catálogo exhaustivo de restricciones de clave foránea, triggers de auditoría y sincronización.

### 5.1 Catálogo Completo de Tablas y Columnas Físicas

| N° | Tabla Física | Columnas Principales | Claves Foráneas Relevantes | Destino en Arquitectura v2 |
| :--- | :--- | :--- | :--- | :--- |
| 1 | `users` | `id`, `email`, `password_hash`, `google_id`, `status` | - | `iam` (`users`) |
| 2 | `password_recovery_tokens` | `id`, `token_hash`, `expires_at`, `is_used`, `user_id` | `user_id -> users(id)` | `iam` (`verification_tokens`) |
| 3 | `workshops` | `id`, `owner_id`, `business_name`, `brand_name`, `tax_id` | `owner_id -> owners(id)` | `iam` (`tenants`) |
| 4 | `branches` | `id`, `workshop_id`, `code`, `name`, `address`, `phone` | `workshop_id -> workshops(id)` | `iam` (`branches`) |
| 5 | `owners` | `id`, `user_id`, `first_name`, `last_name`, `doc_type`, `phone` | `user_id -> users(id)` | `iam` (`tenant_memberships`) |
| 6 | `employees` | `id`, `user_id`, `first_name`, `last_name`, `doc_type`, `phone` | `user_id -> users(id)` | `iam` (`tenant_memberships`) |
| 7 | `customers` | `id`, `user_id`, `first_name`, `is_corporate`, `business_name` | `user_id -> users(id)` | `crm` (`customers`) |
| 8 | `subscription_plans` | `id`, `name`, `monthly_price`, cuotas operativas | - | `billing` (`plans`) |
| 9 | `branch_subscriptions` | `id`, `branch_id`, `plan_id`, `status`, `billing_cycle` | `branch_id -> branches`, `plan_id` | `billing` (`subscriptions`) |
| 10 | `customer_registrations` | `id`, `customer_id`, `branch_id`, `status` | `customer_id -> customers`, `branch_id`| `crm` (simplificado) |
| 11 | `employee_registrations` | `id`, `employee_id`, `branch_id`, `speciality`, `salary`| `employee_id -> employees`, `branch_id`| `hr` (`work_shifts`, contratos) |
| 12 | `vehicles` | `id`, `plate_number`, `vin`, `year`, `brand`, `model` | - | `crm` (`vehicles`) |
| 13 | `vehicle_registrations` | `id`, `user_id`, `vehicle_id`, `status` | `user_id -> users`, `vehicle_id` | `crm` (`vehicles.customer_id`) |
| 14 | `appointments` | `id`, `branch_id`, `customer_id`, `vehicle_id`, `status`| `branch_id`, `customer_id`, `vehicle_id`| `crm` (`appointments`) |
| 15 | `services` | `id`, `branch_id`, `name`, `price` | `branch_id -> branches(id)` | `mro` (`service_catalog`) |
| 16 | `products` | `id`, `branch_id`, `category`, `name`, `sku`, `stock` | `branch_id -> branches(id)` | `inventory` (`inventory_items`) |
| 17 | `product_batches` | `id`, `product_id`, `initial_qty`, `avail_qty`, `cost` | `product_id -> products(id)` | `inventory` (`inventory_batches`) |
| 18 | `work_orders` | `id`, `appointment_id`, `branch_id`, `status`, `mileage`| `appointment_id`, `branch_id`, `vehicle`| `mro` (`work_orders`) |
| 19 | `work_order_tasks` | `id`, `work_order_id`, `service_id`, `mechanic_id`, `price`| `work_order_id`, `service_id`, `mech` | `mro` (`work_order_tasks`) |
| 20 | `work_order_task_products`| `id`, `work_order_task_id`, `product_id`, `qty`, `cost`| `task_id`, `product_id` | `mro` (`work_order_task_products`)|
| 21 | `quotes` | `id`, `work_order_id`, `branch_id`, `discount`, `total` | `work_order_id`, `branch_id` | `mro` (integrado en WorkOrder) |
| 22 | `vouchers` | `id`, `quote_id`, `branch_id`, `voucher_number`, `type` | `quote_id -> quotes(id)` | `invoicing` (`electronic_vouchers`) |
| 23 | `payments` | `id`, `voucher_id`, `branch_id`, `amount`, `method` | `voucher_id -> vouchers(id)` | `invoicing` (`payments`) |
| 24 | `obd2_devices` | `id`, `branch_id`, `mac_address`, `last_ping`, `status` | `branch_id -> branches(id)` | `iot` (`obd2_devices`) |
| 25 | `obd2_device_registrations`| `id`, `obd2_device_id`, `vehicle_id`, `branch_id` | `device_id`, `vehicle_id`, `branch_id` | `iot` (`device_installations`) |
| 26 | `telemetry_snapshots` | `id`, `reg_id`, `rpm`, `temp`, `speed`, `odometer`, `fuel`| `reg_id -> obd2_device_registrations` | `iot` (`telemetry_logs` Hypertable)|
| 27 | `dtc_alerts` | `id`, `snapshot_id`, `branch_id`, `dtc_code`, `severity`| `snapshot_id -> telemetry_snapshots` | `iot` (`vehicle_faults`) |

### 5.2 Triggers y Funciones de Base de Datos en v1

1. **Trigger de Auditoría Temporal (`update_modified_column`):**
   Garantizaba que la columna `updated_at` se actualizara automáticamente a nivel de motor ante cualquier modificación física, protegiendo contra actualizaciones directas fuera de la aplicación.
   * Aplicado en **19 tablas**: `appointments`, `branches`, `customer_registrations`, `customers`, `employee_registrations`, `employees`, `obd2_devices`, `owners`, `product_batches`, `products`, `quotes`, `services`, `users`, `vehicles`, `vouchers`, `work_order_task_products`, `work_order_tasks`, `work_orders`, `workshops`.

2. **Trigger de Sincronización de Stock (`sync_product_stock`):**
   Mantenía la consistencia del stock global del producto con la suma de los lotes activos:
   ```sql
   CREATE OR REPLACE FUNCTION sync_product_stock()
   RETURNS TRIGGER AS $$
   BEGIN
       IF (TG_OP = 'DELETE') THEN
           UPDATE products
           SET current_stock = (SELECT COALESCE(SUM(available_quantity), 0) FROM product_batches WHERE product_id = OLD.product_id)
           WHERE id = OLD.product_id;
       ELSE
           UPDATE products
           SET current_stock = (SELECT COALESCE(SUM(available_quantity), 0) FROM product_batches WHERE product_id = NEW.product_id)
           WHERE id = NEW.product_id;
       END IF;
       RETURN NEW;
   END;
   $$ LANGUAGE plpgsql;

   CREATE TRIGGER trg_sync_product_stock
       AFTER INSERT OR UPDATE OR DELETE ON product_batches
       FOR EACH ROW EXECUTE FUNCTION sync_product_stock();
   ```

---

## 6. Comparativa Crítica: `atelier-platform` (v1) vs `learning-center-platform` (Docente)

| Dimensión de Diseño | `learning-center-platform` (Docente) | `atelier-platform` (v1) | Veredicto y Directriz para v2 |
| :--- | :--- | :--- | :--- |
| **Identificadores de Entidad** | `Long` auto-incremental (`GenerationType.IDENTITY`) | `UUID` (`GenerationType.UUID`) en toda la base | **Se preserva el enfoque de v1 (`UUID`)**: Es el estándar mandatorio en sistemas SaaS distribuidos y multisede para evitar colisiones y enumeración de IDs. |
| **Mapeo de Agregados y JPA** | Las entidades JPA son el agregado mismo (`@Entity` en el dominio) | **Hexagonal estricto**: Agregados puros sin JPA + `*PersistenceEntity` separadas | **Se adopta el patrón limpio de v1**: Mantiene el dominio libre de anotaciones de Hibernate y facilita tests unitarios ultrarrápidos. |
| **Manejo de Errores y Retornos** | `Result<T, ApplicationError>` sellado + `ResponseEntityAssembler` | Mismo patrón `Result<T, ApplicationError>` implementado en `shared` | **Plena coincidencia y éxito**: Se mantiene y se reutiliza al 100%. |
| **Integración Externa (ACL / OHS)**| Fachadas formales OHS con Interfaces ACL bien delimitadas | ACL presentes (`FacthubGatewayImpl`), pero con clientes directos | **Se perfecciona al estilo docente**: Se estructuran paquetes `interfaces.acl` con mapeos DTO estrictos hacia APIs externas. |
| **Desacoplamiento de Módulos** | Bounded Contexts independientes con agregados pequeños | "Módulo Dios" `core` que agrupaba 7 entidades dispares | **Se refactoriza al estándar docente**: Se divide `core` en los Bounded Contexts canónicos de Tenancy, CRM, HR y SaaS Billing. |
| **Poblado de Datos Inicial (Seed)** | `DataLoader` con `@EventListener(ApplicationReadyEvent)` | Inserción manual o scripts SQL | **Se adopta la práctica del docente**: Creación de `DatabaseSeeder` para levantar entornos de prueba reproducibles. |

---

## 7. Matriz Maestra de Transición: De v1 a los 8 Bounded Contexts Oficiales

Esta matriz define el destino preciso de cada una de las 624 clases y 27 tablas de v1:

```
                  ┌─────────────────────────────────────────────────────────┐
                  │                 ATELIER PLATFORM v1                     │
                  │   iam │ core │ fleet │ operations │ inventory │ billing │ iot  │
                  └────────────────────────────┬────────────────────────────┘
                                               │
                                               ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                  8 BOUNDED CONTEXTS DEFINITIVOS (v2)                                            │
├────────────────────────────────┬────────────────────────────────┬──────────────────────────────────────────────┤
│ Bounded Context v2             │ Elementos Heredados de v1      │ Transformaciones Clave y Nuevas Capacidades  │
├────────────────────────────────┼────────────────────────────────┼──────────────────────────────────────────────┤
│ 1. IAM & Tenancy Context       │ users, tokens, workshops,      │ Aislamiento Multi-Tenant formal (tenant_id). │
│                                │ branches de iam y core.        │ RBAC dinámico. Migración de SMTP a Resend.   │
├────────────────────────────────┼────────────────────────────────┼──────────────────────────────────────────────┤
│ 2. Customer & Fleet (CRM)      │ customers, vehicles,           │ Historial vehicular unificado (hoja clínica).│
│                                │ appointments de core/fleet/iot │ Integración nativa con app móvil Driver.     │
├────────────────────────────────┼────────────────────────────────┼──────────────────────────────────────────────┤
│ 3. Workshop Operations (MRO)   │ work_orders, tasks, products,  │ Bahías físicas (work_bays). Fotos Firebase   │
│                                │ services de operations.        │ Direct-to-Cloud. Persistencia SQLite offline.│
├────────────────────────────────┼────────────────────────────────┼──────────────────────────────────────────────┤
│ 4. Inventory & Supply Chain    │ products, product_batches      │ Algoritmo FIFO estricto por lote. Gestión    │
│                                │ de inventory.                  │ de proveedores (suppliers) y fotos facturas. │
├────────────────────────────────┼────────────────────────────────┼──────────────────────────────────────────────┤
│ 5. Human Resources (HR)        │ employees, employee_           │ Control de asistencia GPS (Fórmula Haversine)│
│                                │ registrations de core y fleet. │ Turnos laborales, registro biométrico/móvil. │
├────────────────────────────────┼────────────────────────────────┼──────────────────────────────────────────────┤
│ 6. Invoicing & Compliance      │ vouchers, payments de billing. │ Migración de Facthub a Nubefact (API JSON).  │
│                                │                                │ Emisión UBL 2.1 SUNAT legal con código QR.   │
├────────────────────────────────┼────────────────────────────────┼──────────────────────────────────────────────┤
│ 7. SaaS Billing & Subscriptions│ subscription_plans, branch_    │ Integración con Stripe (stripe-java).        │
│                                │ subscriptions de core.         │ Cobro a nivel tenant. Transactional Outbox.  │
├────────────────────────────────┼────────────────────────────────┼──────────────────────────────────────────────┤
│ 8. IoT Telemetry & Predictive  │ obd2_devices, snapshots,       │ Migración a Hipertabla TimescaleDB. Alertas  │
│    Maintenance                 │ dtc_alerts de iot.             │ en tiempo real con Firebase Cloud Messaging. │
└────────────────────────────────┴────────────────────────────────┴──────────────────────────────────────────────┘
```

---

## 8. Conclusiones para la Redacción de la Sección 2.6 (Tactical DDD)

La inspección profunda de la base de código de `atelier-platform` (v1) confirma que el proyecto cuenta con un trabajo previo maduro:
1. **La máquina de estados de las órdenes de trabajo (`WorkOrder`)** y sus tareas y repuestos ya posee la lógica de negocio completa y validaciones robustas.
2. **El patrón de eventos internos** entre operaciones, inventario y facturación (`ProductReservedEvent`, `PaymentProcessedEvent`, `VoucherPaidEvent`) demostró ser altamente efectivo y solo requiere formalizarse con interfaces de publicación limpias.
3. **La arquitectura hexagonal desacoplada** (`AbstractDomainAggregateRoot` y `AuditableAbstractPersistenceEntity`) es técnica y académicamente superior a la implementación básica de entidades directas de JPA, pues respeta al 100% la pureza del modelo de dominio de Evans.
4. **La refactorización hacia los 8 Bounded Contexts** no consiste en inventar código desde cero, sino en **desacoplar el "Módulo Dios" `core`**, migrar la persistencia de telemetría a **TimescaleDB**, reemplazar integraciones obsoletas (Gmail SMTP -> **Resend**, Facthub -> **Nubefact**, tarjetas simuladas -> **Stripe**) e incorporar las nuevas entidades de soporte (**bahías de trabajo, proveedores y geocercas GPS**).

Con este análisis y el documento de referencia del docente ([docs/backend-documentation/learning-center-platform-reference.md](file:///home/shouy/development/atelier-report/docs/backend-documentation/learning-center-platform-reference.md)), contamos con el inventario completo para proceder de inmediato con la redacción de los archivos correspondientes a la **Sección 2.6: Tactical-Level Domain-Driven Design** en el reporte de tesis.
