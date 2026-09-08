# Radiografía Arquitectónica y Análisis Técnico Canónico: `learning-center-platform`

Este documento contiene la radiografía técnica exhaustiva, el desglose pormenorizado a nivel de código fuente y el catálogo completo de convenciones del repositorio de referencia del docente: **`learning-center-platform`** (`com.acme.center.platform`), ubicado físicamente en `/home/shouy/development/learning-center-platform`.

Este análisis constituye la **fuente de verdad canónica y normativa** que define los estándares de diseño táctico (DDD), arquitectura hexagonal desacoplada, Context Mapping (ACL/OHS) y manejo funcional de errores para el backend definitivo de **Atelier** y la redacción del capítulo **2.6. Tactical-Level Domain-Driven Design** en el reporte de tesis.

---

## 1. Ficha Técnica y Visión General del Repositorio Docente

| Parámetro | Especificación Canónica en `learning-center-platform` |
| :--- | :--- |
| **Repositorio Local** | `/home/shouy/development/learning-center-platform` |
| **Nombre del Sistema** | ACME Learning Center Platform |
| **Paquete Raíz** | `com.acme.center.platform` |
| **Volumen de Código** | **195 archivos Java** distribuidos en 3 Bounded Contexts y 1 Shared Kernel |
| **Lenguaje y Runtime** | Java 26 (OpenJDK 64-Bit Server VM, Virtual Threads y Pattern Matching) |
| **Framework Base** | Spring Boot 4.0.6 (Spring Framework 7.x) |
| **Motor de Base de Datos** | MySQL 8.0+ (Driver: `com.mysql.cj.jdbc.Driver`, `mysql-connector-j`) |
| **ORM y Mapeo** | Spring Data JPA / Hibernate Core |
| **Estrategia de Nombres Físicos** | `SnakeCaseWithPluralizedTablePhysicalNamingStrategy` (con biblioteca `pluralize:1.0.0`) |
| **Identificadores de Entidad** | `Long` con generación automática `@GeneratedValue(strategy = GenerationType.IDENTITY)` |
| **Seguridad y Tokens** | Spring Security 6 + JJWT (`io.jsonwebtoken:jjwt-api:0.12.6`), Stateless Bearer JWT |
| **Documentación OpenAPI** | SpringDoc OpenAPI Starter WebMVC UI 3.0.3 (`/swagger-ui.html`) |
| **Estilo Arquitectónico** | **Hexagonal Architecture (Ports & Adapters) + DDD Onion + CQRS + Event-Driven** |
| **Módulos / Bounded Contexts** | `shared` (12), `profiles` (30), `iam` (56), `learning` (96) + `Application` (1) |

---

## 2. Inventario Global de Código: 195 Archivos Java

El sistema se compone de 195 archivos Java distribuidos estrictamente según el paradigma de diseño táctico DDD:

```
learning-center-platform/
├── shared/     (12 archivos) -> Clases base abstractas, Result mónada, Error handling, REST assemblers
├── profiles/   (30 archivos) -> Perfiles personales, OHS Facade, convertidores y persistencia JPA
├── iam/        (56 archivos) -> Autenticación, JWT stateless filter, roles, comandos de semilla y BCrypt
├── learning/   (96 archivos) -> Cursos, Rutas, Estudiantes, Matrículas, Eventos, Handlers y Outbound ACL
└── LearningCenterPlatformApplication.java (1 archivo) -> Punto de entrada Spring Boot
```

---

## 3. Análisis Profundo del Shared Kernel (`com.acme.center.platform.shared`)

El Shared Kernel contiene 12 clases que establecen los contratos fundamentales e inmutables compartidos por toda la solución:

```
shared/
├── application/result/
│   ├── ApplicationError.java                              # Record: código de error, mensaje y detalles
│   └── Result.java                                        # Sealed interface mónada (Success, Failure)
├── domain/model/aggregates/
│   └── AbstractDomainAggregateRoot.java                   # Extiende Spring Data Commons AbstractAggregateRoot
├── infrastructure/
│   ├── documentation/openapi/configuration/
│   │   └── OpenApiConfiguration.java                      # Configuración de metadatos Swagger / OpenAPI 3.0
│   ├── i18n/configuration/
│   │   └── LocaleConfiguration.java                       # Configuración de internacionalización (i18n)
│   └── persistence/jpa/
│       ├── configuration/strategy/
│       │   └── SnakeCaseWithPluralizedTablePhysicalNamingStrategy.java # Naming de tablas en plural snake_case
│       └── entities/
│           └── AuditableAbstractPersistenceEntity.java    # Superclase @MappedSuperclass con Long ID y fechas
└── interfaces/rest/
    ├── GlobalExceptionHandler.java                        # Captura MethodArgumentNotValidException y runtime
    ├── resources/
    │   ├── ErrorResource.java                             # Record DTO para respuestas de error (code, message)
    │   └── MessageResource.java                           # Record DTO para confirmaciones simples
    └── transform/
        ├── ErrorResponseAssembler.java                    # Convierte ApplicationError a ResponseEntity<ErrorResource>
        └── ResponseEntityAssembler.java                   # Mapea Result<T, ApplicationError> a ResponseEntity<?>
```

### 3.1 Base de Persistencia y Auditoría: `AuditableAbstractPersistenceEntity`
Ubicada en `shared.infrastructure.persistence.jpa.entities`:
```java
@Getter
@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
public abstract class AuditableAbstractPersistenceEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @CreatedDate
    @Column(nullable = false, updatable = false)
    private Date createdAt;

    @LastModifiedDate
    @Column(nullable = false)
    private Date updatedAt;

    public void setId(Long id) {
        this.id = id;
    }
}
```
* **Principio de Aislamiento:** Esta clase pertenece estrictamente a `infrastructure`. Los agregados en la capa de dominio nunca heredan de ella; solo las entidades de persistencia JPA (`*PersistenceEntity`) la extienden.

### 3.2 Raíz de Agregado de Dominio: `AbstractDomainAggregateRoot<T>`
Ubicada en `shared.domain.model.aggregates`:
```java
public abstract class AbstractDomainAggregateRoot<T extends AbstractDomainAggregateRoot<T>>
        extends AbstractAggregateRoot<T> {

    protected void registerDomainEvent(Object event) {
        super.registerEvent(event);
    }

    @Override
    public Collection<Object> domainEvents() {
        return super.domainEvents();
    }

    @Override
    public void clearDomainEvents() {
        super.clearDomainEvents();
    }
}
```
* **Mecanismo de Despacho:** Cuando un agregado muta su estado, invoca `registerDomainEvent(event)`. Al persistirse a través del adaptador `*RepositoryImpl`, este extrae la lista de eventos mediante `aggregate.domainEvents()` y los publica en el contexto de Spring (`ApplicationEventPublisher`), limpiando la cola con `clearDomainEvents()`.

### 3.3 Patrón Funcional de Retorno: `Result<T, E>` y `ApplicationError`
El docente prohíbe el uso de excepciones para el control de flujo de negocio ordinario (como errores de validación, duplicados o no encontrados). En su lugar, implementa el patrón mónada `Result`:
```java
public sealed interface Result<T, E> permits Result.Success, Result.Failure {
    record Success<T, E>(T value) implements Result<T, E> {}
    record Failure<T, E>(E error) implements Result<T, E> {}

    static <T, E> Result<T, E> success(T value) { return new Success<>(value); }
    static <T, E> Result<T, E> failure(E error) { return new Failure<>(error); }

    default boolean isSuccess() { return this instanceof Success; }
    default boolean isFailure() { return this instanceof Failure; }
}
```

La clase `ApplicationError` tipifica los fallos de aplicación con constructores semánticos:
```java
public record ApplicationError(String code, String message, List<String> details) {
    public static ApplicationError notFound(String resource, String id) {
        return new ApplicationError("NOT_FOUND", "%s with id %s was not found".formatted(resource, id), List.of());
    }
    public static ApplicationError conflict(String message) {
        return new ApplicationError("CONFLICT", message, List.of());
    }
    public static ApplicationError badRequest(String message) {
        return new ApplicationError("BAD_REQUEST", message, List.of());
    }
}
```

### 3.4 Ensamblado de Respuestas HTTP: `ResponseEntityAssembler`
Permite a los controladores REST transformar el `Result<T, ApplicationError>` devuelto por los servicios de aplicación en respuestas HTTP estandarizadas:
```java
public class ResponseEntityAssembler {
    public static <T, R> ResponseEntity<?> toResponseEntityFromResult(
            Result<T, ApplicationError> result,
            Function<T, R> resourceAssembler,
            HttpStatus successStatus) {
        if (result instanceof Result.Success<T, ApplicationError> success) {
            return new ResponseEntity<>(resourceAssembler.apply(success.value()), successStatus);
        }
        var failure = (Result.Failure<T, ApplicationError>) result;
        return ErrorResponseAssembler.toErrorResponseFromApplicationError(failure.error());
    }
}
```

---

## 4. Bounded Context: `profiles` (30 clases)

### 4.1 Inventario Completo de Clases del Módulo
```
profiles/
├── domain/
│   ├── model/
│   │   ├── aggregates/Profile.java
│   │   ├── commands/CreateProfileCommand.java
│   │   ├── queries/GetProfileByIdQuery.java, GetProfileByEmailQuery.java, GetAllProfilesQuery.java
│   │   ├── valueobjects/PersonName.java, EmailAddress.java, StreetAddress.java
│   │   └── events/ProfileCreatedEvent.java
│   └── repositories/ProfileRepository.java
├── application/
│   ├── commandservices/ProfileCommandService.java
│   ├── queryservices/ProfileQueryService.java
│   ├── acl/ProfilesContextFacadeImpl.java
│   └── internal/
│       ├── commandservices/ProfileCommandServiceImpl.java
│       ├── queryservices/ProfileQueryServiceImpl.java
│       └── eventhandlers/ProfileCreatedEventHandler.java
├── infrastructure/
│   └── persistence/jpa/
│       ├── entities/ProfilePersistenceEntity.java
│       ├── embeddables/PersonNamePersistenceEmbeddable.java, StreetAddressPersistenceEmbeddable.java
│       ├── converters/EmailAddressPersistenceConverter.java
│       ├── repositories/ProfilePersistenceRepository.java
│       ├── adapters/ProfileRepositoryImpl.java
│       └── assemblers/ProfilePersistenceAssembler.java
└── interfaces/
    ├── acl/ProfilesContextFacade.java
    ├── events/ProfileCreatedIntegrationEvent.java
    └── rest/
        ├── ProfilesController.java
        ├── resources/CreateProfileResource.java, ProfileResource.java
        └── transform/CreateProfileCommandFromResourceAssembler.java, ProfileResourceFromEntityAssembler.java
```

### 4.2 Modelo de Dominio de `profiles`
* **Agregado Raíz `Profile`:**
  * Atributos: `id: Long`, `name: PersonName`, `emailAddress: EmailAddress`, `streetAddress: StreetAddress`.
  * Constructores: Constructor completo, constructor con Value Objects, constructor con `CreateProfileCommand`.
  * Emisión de Eventos: Al construirse a partir de `CreateProfileCommand`, ejecuta `this.registerDomainEvent(new ProfileCreatedEvent(this, this))`.
* **Value Objects:**
  * `PersonName(String firstName, String lastName)`: Constructor compacto valida no-vacío. Método de negocio `getFullName()`.
  * `EmailAddress(String address)`: Valida expresión regular de email válida.
  * `StreetAddress(String street, String number, String city, String postalCode, String country)`: Encapsula ubicación física.
* **Comandos y Consultas (Java Records):**
  * `CreateProfileCommand(String firstName, String lastName, String email, String street, String number, String city, String postalCode, String country)`
  * `GetProfileByIdQuery(Long profileId)`
  * `GetProfileByEmailQuery(EmailAddress emailAddress)`
  * `GetAllProfilesQuery()`

### 4.3 Open Host Service (OHS) / Inbound ACL Facade
El contexto `profiles` expone una fachada pública para permitir que otros Bounded Contexts interactúen con él de manera síncrona sin violar el encapsulamiento:
* **Interfaz `ProfilesContextFacade`:**
  ```java
  public interface ProfilesContextFacade {
      Long createProfile(String firstName, String lastName, String email, String street, String number, String city, String postalCode, String country);
      Long fetchProfileIdByEmail(String email);
  }
  ```
* **Implementación `ProfilesContextFacadeImpl`:**
  * Delega en `ProfileCommandService` ejecutando `CreateProfileCommand`.
  * Delega en `ProfileQueryService` ejecutando `GetProfileByEmailQuery`.

### 4.4 Eventos de Dominio y de Integración
* **`ProfileCreatedEvent(Object source, Profile profile)`:** Evento de dominio interno.
* **`ProfileCreatedEventHandler` (Interno de `profiles`):** Captura `ProfileCreatedEvent` y publica **`ProfileCreatedIntegrationEvent(this, profile.getId())`** hacia el exterior (Spring Application Context).

### 4.5 Persistencia JPA en MySQL
* **`ProfilePersistenceEntity`:** Mapea a la tabla `profiles`.
  * `@Embedded private PersonNamePersistenceEmbeddable name;`
  * `@Convert(converter = EmailAddressPersistenceConverter.class) private EmailAddress emailAddress;`
  * `@Embedded private StreetAddressPersistenceEmbeddable streetAddress;`
* **Adaptador `ProfileRepositoryImpl`:** Implementa `ProfileRepository` y despacha los eventos pendientes tras llamar a `save()`.

### 4.6 Endpoints REST (`ProfilesController`)
* Base URL: `/api/v1/profiles`
* `POST /api/v1/profiles`: Recibe `CreateProfileResource`, despacha `CreateProfileCommand`, retorna HTTP 201 con `ProfileResource`.
* `GET /api/v1/profiles/{profileId}`: Consulta por ID, retorna HTTP 200 con `ProfileResource` o HTTP 404 con `ErrorResource`.
* `GET /api/v1/profiles`: Retorna HTTP 200 con `List<ProfileResource>`.

---

## 5. Bounded Context: `iam` (56 clases)

### 5.1 Inventario Completo de Clases del Módulo
```
iam/
├── domain/
│   ├── model/
│   │   ├── aggregates/User.java
│   │   ├── entities/Role.java
│   │   ├── commands/SignUpCommand.java, SignInCommand.java, SeedRolesCommand.java
│   │   ├── queries/GetUserByIdQuery.java, GetUserByUsernameQuery.java, GetAllUsersQuery.java, GetRoleByNameQuery.java, GetAllRolesQuery.java
│   │   └── valueobjects/Roles.java (Enum: ROLE_USER, ROLE_ADMIN, ROLE_INSTRUCTOR)
│   └── repositories/UserRepository.java, RoleRepository.java
├── application/
│   ├── commandservices/UserCommandService.java, RoleCommandService.java
│   ├── queryservices/UserQueryService.java, RoleQueryService.java
│   ├── acl/IamContextFacadeImpl.java
│   └── internal/
│       ├── commandservices/UserCommandServiceImpl.java, RoleCommandServiceImpl.java
│       └── queryservices/UserQueryServiceImpl.java, RoleQueryServiceImpl.java
├── infrastructure/
│   ├── authorization/sfs/
│   │   ├── configuration/WebSecurityConfiguration.java
│   │   ├── pipeline/BearerAuthorizationRequestFilter.java, UnauthorizedRequestHandlerEntryPoint.java
│   │   ├── services/UserDetailsServiceImpl.java
│   │   └── model/UserDetailsImpl.java, UsernamePasswordAuthenticationTokenBuilder.java
│   ├── hashing/bcrypt/
│   │   ├── BCryptHashingService.java
│   │   └── services/HashingServiceImpl.java
│   ├── tokens/jwt/
│   │   ├── BearerTokenService.java
│   │   └── services/TokenServiceImpl.java
│   └── persistence/jpa/
│       ├── entities/UserPersistenceEntity.java, RolePersistenceEntity.java
│       ├── repositories/UserPersistenceRepository.java, RolePersistenceRepository.java
│       ├── adapters/UserRepositoryImpl.java, RoleRepositoryImpl.java
│       └── assemblers/UserPersistenceAssembler.java, RolePersistenceAssembler.java
└── interfaces/
    ├── acl/IamContextFacade.java
    └── rest/
        ├── AuthenticationController.java, UsersController.java, RolesController.java
        ├── resources/SignInResource.java, SignUpResource.java, AuthenticatedUserResource.java, UserResource.java, RoleResource.java
        └── transform/SignInCommandFromResourceAssembler.java, SignUpCommandFromResourceAssembler.java, UserResourceFromEntityAssembler.java, RoleResourceFromEntityAssembler.java
```

### 5.2 Modelo de Dominio de `iam`
* **Agregado Raíz `User`:**
  * Atributos: `id: Long`, `username: String`, `password: String` (BCrypt Hash), `roles: Set<Role>`.
  * Métodos: `addRole(Role role)`, `addRoles(List<Role> roles)`.
* **Entidad `Role`:**
  * Atributos: `id: Long`, `name: Roles`.
  * Método estático: `Role toRoleFromName(String name)`.
* **Value Object / Enum `Roles`:**
  * Valores: `ROLE_USER`, `ROLE_ADMIN`, `ROLE_INSTRUCTOR`.

### 5.3 Pipeline de Seguridad e Infraestructura
* **`WebSecurityConfiguration`:**
  * Define `SecurityFilterChain` con sesiones stateless.
  * Desactiva CSRF y configura CORS.
  * Define matchers de autorización: Rutas `/api/v1/authentication/**` y Swagger son públicas (`permitAll()`), el resto requiere autenticación Bearer (`authenticated()`).
* **`BearerAuthorizationRequestFilter`:**
  * Extiende `OncePerRequestFilter`.
  * Extrae token del header `Authorization: Bearer <token>`, valida firma con `BearerTokenService`, extrae username, resuelve autoridades y fija el `SecurityContextHolder`.
* **Semilla Automática de Datos (`SeedRolesCommand`):**
  * `RoleCommandServiceImpl` implementa la verificación de roles al iniciar la aplicación (`ApplicationReadyEvent` o constructor) para poblar `roles` si está vacía.

### 5.4 Endpoints REST de IAM
| Método | Ruta Endpoint | Controlador | Recurso Entrada | Recurso Retorno |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/api/v1/authentication/sign-up` | `AuthenticationController` | `SignUpResource` | `UserResource` (HTTP 201) |
| `POST` | `/api/v1/authentication/sign-in` | `AuthenticationController` | `SignInResource` | `AuthenticatedUserResource` (HTTP 200) |
| `GET` | `/api/v1/users` | `UsersController` | - | `List<UserResource>` (HTTP 200) |
| `GET` | `/api/v1/users/{userId}` | `UsersController` | - | `UserResource` (HTTP 200 / 404) |
| `GET` | `/api/v1/roles` | `RolesController` | - | `List<RoleResource>` (HTTP 200) |

---

## 6. Bounded Context: `learning` (96 clases) — El Core Domain

### 6.1 Inventario Completo de Clases del Módulo
```
learning/
├── domain/
│   ├── exceptions/
│   │   ├── CourseNotFoundException.java, EnrollmentNotFoundException.java
│   │   ├── EnrollmentRequestException.java, StudentNotFoundException.java
│   │   └── TutorialCompletedEventHandler.java
│   ├── model/
│   │   ├── aggregates/Course.java, Student.java, Enrollment.java
│   │   ├── entities/LearningPathItem.java, ProgressRecordItem.java
│   │   ├── valueobjects/
│   │   │   ├── AcmeStudentRecordId.java, ProfileId.java, TutorialId.java
│   │   │   ├── EnrollmentStatus.java, ProgressStatus.java
│   │   │   ├── StudentPerformanceMetricSet.java
│   │   │   ├── LearningPath.java, ProgressRecord.java
│   │   ├── commands/
│   │   │   ├── CreateCourseCommand.java, UpdateCourseCommand.java, DeleteCourseCommand.java
│   │   │   ├── AddTutorialToCourseLearningPathCommand.java
│   │   │   ├── CreateStudentCommand.java, CreateStudentByProfileIdCommand.java
│   │   │   ├── UpdateStudentMetricsOnTutorialCompletedCommand.java
│   │   │   ├── RequestEnrollmentCommand.java, ConfirmEnrollmentCommand.java
│   │   │   ├── RejectEnrollmentCommand.java, CancelEnrollmentCommand.java
│   │   │   └── CompleteTutorialForEnrollmentCommand.java
│   │   ├── queries/
│   │   │   ├── GetCourseByIdQuery.java, GetAllCoursesQuery.java
│   │   │   ├── GetLearningPathItemByCourseIdAndTutorialIdQuery.java
│   │   │   ├── GetStudentByAcmeStudentRecordIdQuery.java, GetStudentByProfileIdQuery.java
│   │   │   ├── ExistsByAcmeStudentRecordIdQuery.java
│   │   │   ├── GetEnrollmentByIdQuery.java, GetAllEnrollmentsQuery.java
│   │   │   ├── GetAllEnrollmentsByCourseIdQuery.java, GetAllEnrollmentsByAcmeStudentRecordIdQuery.java
│   │   │   └── GetEnrollmentByAcmeStudentRecordIdAndCourseIdQuery.java
│   │   └── events/TutorialCompletedEvent.java
│   └── repositories/CourseRepository.java, StudentRepository.java, EnrollmentRepository.java
├── application/
│   ├── commandservices/CourseCommandService.java, StudentCommandService.java, EnrollmentCommandService.java
│   ├── queryservices/CourseQueryService.java, StudentQueryService.java, EnrollmentQueryService.java
│   └── internal/
│       ├── commandservices/CourseCommandServiceImpl.java, StudentCommandServiceImpl.java, EnrollmentCommandServiceImpl.java
│       ├── queryservices/CourseQueryServiceImpl.java, StudentQueryServiceImpl.java, EnrollmentQueryServiceImpl.java
│       ├── eventhandlers/TutorialCompletedEventHandler.java, ProfileCreatedEventHandler.java
│       └── outboundservices/acl/ExternalProfileService.java
├── infrastructure/
│   └── persistence/jpa/
│       ├── entities/CoursePersistenceEntity.java, LearningPathItemPersistenceEntity.java
│       │   ├── StudentPersistenceEntity.java, EnrollmentPersistenceEntity.java
│       │   └── ProgressRecordItemPersistenceEntity.java
│       ├── converters/AcmeStudentRecordIdPersistenceConverter.java, ProfileIdPersistenceConverter.java
│       ├── repositories/CoursePersistenceRepository.java, StudentPersistenceRepository.java, EnrollmentPersistenceRepository.java
│       ├── adapters/CourseRepositoryImpl.java, StudentRepositoryImpl.java, EnrollmentRepositoryImpl.java
│       └── assemblers/CoursePersistenceAssembler.java, StudentPersistenceAssembler.java, EnrollmentPersistenceAssembler.java
└── interfaces/
    └── rest/
        ├── CoursesController.java, CourseLearningPathController.java
        ├── StudentsController.java, EnrollmentsController.java, StudentEnrollmentsController.java
        ├── resources/
        │   ├── CreateCourseResource.java, CourseResource.java, UpdateCourseResource.java
        │   ├── LearningPathItemResource.java, CreateStudentResource.java, StudentResource.java
        │   ├── RequestEnrollmentResource.java, EnrollmentResource.java
        └── transform/
            ├── CreateCourseCommandFromResourceAssembler.java, CourseResourceFromEntityAssembler.java
            ├── UpdateCourseCommandFromResourceAssembler.java, LearningPathItemResourceFromEntityAssembler.java
            ├── CreateStudentCommandFromResourceAssembler.java, StudentResourceFromEntityAssembler.java
            └── RequestEnrollmentCommandFromResourceAssembler.java, EnrollmentResourceFromEntityAssembler.java
```

### 6.2 Agregados y Entidades del Dominio Educativo

#### A. Agregado `Course`
* **Atributos:** `id: Long`, `title: String`, `description: String`, `learningPath: LearningPath`.
* **Entidad Hija `LearningPathItem`:** Representa una lección o tutorial dentro de la ruta de aprendizaje (`id: Long`, `courseId: Long`, `tutorialId: TutorialId`, `order: int`).
* **Value Object `LearningPath`:** Encapsula la colección inmutable de `learningPathItems` y valida que no se agreguen tutoriales duplicados a un mismo curso.
* **Métodos de Negocio:**
  * `addTutorialToLearningPath(TutorialId tutorialId)`: Agrega una lección a la ruta calculando el orden correlativo correspondiente.

#### B. Agregado `Student`
* **Atributos:** `id: Long`, `acmeStudentRecordId: AcmeStudentRecordId`, `profileId: ProfileId`, `performanceMetricSet: StudentPerformanceMetricSet`.
* **Value Objects:**
  * `AcmeStudentRecordId`: Identificador único de registro de estudiante generado como UUID String inmutable.
  * `ProfileId`: Referencia foránea lógica al Bounded Context `profiles` (Long no nulo y mayor a cero).
  * `StudentPerformanceMetricSet`: Record con `totalCompletedCourses: Integer` y `totalCompletedTutorials: Integer`.
* **Métodos de Negocio:**
  * `updateMetricsOnTutorialCompleted()`: Incrementa en 1 el total de tutoriales completados.
  * `updateMetricsOnCourseCompleted()`: Incrementa en 1 el total de cursos completados.

#### C. Agregado `Enrollment`
* **Atributos:** `id: Long`, `studentRecordId: AcmeStudentRecordId`, `courseId: Long`, `status: EnrollmentStatus`, `progressRecord: ProgressRecord`.
* **Entidad Hija `ProgressRecordItem`:** Registra el avance de una lección individual (`id: Long`, `enrollmentId: Long`, `tutorialId: TutorialId`, `status: ProgressStatus`, `completedAt: Date`).
* **Value Objects:**
  * `EnrollmentStatus`: Enum (`REQUESTED`, `CONFIRMED`, `REJECTED`, `CANCELLED`).
  * `ProgressStatus`: Enum (`NOT_STARTED`, `STARTED`, `COMPLETED`).
  * `ProgressRecord`: Encapsula la lista de `progressRecordItems`.
* **Máquina de Estados de la Matrícula:**
  * `confirm()`: Transiciona de `REQUESTED` a `CONFIRMED`. Lanza `IllegalStateException` si no está en estado solicitado.
  * `reject()`: Transiciona de `REQUESTED` a `REJECTED`.
  * `cancel()`: Transiciona de `CONFIRMED` a `CANCELLED`.
  * `completeTutorial(TutorialId tutorialId)`: Ubica el ítem en el `progressRecord`, actualiza su estado a `COMPLETED` con la fecha actual, y **registra el evento de dominio `TutorialCompletedEvent`**.

### 6.3 Eventos de Integración y Handlers Cross-Context

```
┌─────────────────────────────────────────────────────────┐
│                    PROFILES CONTEXT                     │
│   Profile.java ──> Emite ProfileCreatedIntegrationEvent │
└────────────────────────────┬────────────────────────────┘
                             │
                             │ Spring ApplicationEventPublisher (Synchronous)
                             ▼
┌─────────────────────────────────────────────────────────┐
│                    LEARNING CONTEXT                     │
│   ProfileCreatedEventHandler.java                       │
│   └── Invoca StudentCommandService                      │
│       └── Persiste nuevo Student(profileId)             │
└─────────────────────────────────────────────────────────┘
```

1. **`ProfileCreatedEventHandler`:**
   * Ubicado en `learning.application.internal.eventhandlers`.
   * Escucha `ProfileCreatedIntegrationEvent` de `profiles.interfaces.events`.
   * Invoca `StudentCommandService.handle(new CreateStudentByProfileIdCommand(event.profileId()))`.
   * Garantiza la creación transparente del estudiante sin requerir acoplamiento de base de datos ni llamadas HTTP.

2. **`TutorialCompletedEventHandler`:**
   * Ubicado en `learning.application.internal.eventhandlers`.
   * Escucha `TutorialCompletedEvent`.
   * Actualiza el progreso de métricas del estudiante de manera reactiva e interna.

### 6.4 Outbound Anti-Corruption Layer (ACL): `ExternalProfileService`
Ubicado en `learning.application.internal.outboundservices.acl`:
```java
@Service
public class ExternalProfileService {
    private final ProfilesContextFacade profilesContextFacade;

    public ExternalProfileService(ProfilesContextFacade profilesContextFacade) {
        this.profilesContextFacade = profilesContextFacade;
    }

    public Optional<ProfileId> fetchProfileByEmail(String email) {
        var profileId = profilesContextFacade.fetchProfileIdByEmail(email);
        return profileId == 0L ? Optional.empty() : Optional.of(new ProfileId(profileId));
    }

    public Optional<ProfileId> createProfile(String firstName, String lastName, String email, String street, String number, String city, String postalCode, String country) {
        var profileId = profilesContextFacade.createProfile(firstName, lastName, email, street, number, city, postalCode, country);
        return profileId == 0L ? Optional.empty() : Optional.of(new ProfileId(profileId));
    }
}
```

### 6.5 Catálogo Completo de Endpoints REST en `learning`

| Método | Ruta Endpoint | Controlador | Recurso Entrada / Acción |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/v1/courses` | `CoursesController` | `CreateCourseResource` -> `CourseResource` (201) |
| `GET` | `/api/v1/courses/{courseId}` | `CoursesController` | Consulta de curso por ID (200 / 404) |
| `GET` | `/api/v1/courses` | `CoursesController` | Listado de todos los cursos (200) |
| `PUT` | `/api/v1/courses/{courseId}` | `CoursesController` | `UpdateCourseResource` -> Actualiza título/descripción (200) |
| `DELETE`| `/api/v1/courses/{courseId}` | `CoursesController` | Eliminación de curso (200 / 404) |
| `POST` | `/api/v1/courses/{courseId}/learning-path-items/{tutorialId}` | `CourseLearningPathController` | Agrega tutorial a la ruta de aprendizaje (201) |
| `POST` | `/api/v1/students` | `StudentsController` | `CreateStudentResource` -> Crea perfil vía ACL y registra estudiante (201) |
| `GET` | `/api/v1/students/{studentRecordId}` | `StudentsController` | Consulta ficha de estudiante por su UUID de registro (200) |
| `POST` | `/api/v1/enrollments` | `EnrollmentsController` | `RequestEnrollmentResource` -> Solicitud de matrícula (201) |
| `POST` | `/api/v1/enrollments/{id}/confirmations` | `EnrollmentsController` | Confirmación formal de la matrícula (200) |
| `POST` | `/api/v1/enrollments/{id}/rejections` | `EnrollmentsController` | Rechazo de la solicitud de matrícula (200) |
| `POST` | `/api/v1/enrollments/{id}/cancellations` | `EnrollmentsController` | Cancelación de matrícula activa (200) |
| `GET` | `/api/v1/enrollments` | `EnrollmentsController` | Listado general de matrículas (200) |
| `GET` | `/api/v1/students/{studentRecordId}/enrollments` | `StudentEnrollmentsController` | Historial de matrículas de un estudiante (200) |

---

## 7. Esquema Relacional Físico en MySQL (9 Tablas)

```sql
-- 1. Tabla de Usuarios (IAM)
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL
);

-- 2. Tabla de Roles (IAM)
CREATE TABLE roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- 3. Tabla Intermedia Usuario-Roles (IAM)
CREATE TABLE user_roles (
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_roles_role FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

-- 4. Tabla de Perfiles (Profiles)
CREATE TABLE profiles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email_address VARCHAR(255) NOT NULL UNIQUE,
    street VARCHAR(255) NOT NULL,
    number VARCHAR(50) NOT NULL,
    city VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL
);

-- 5. Tabla de Cursos (Learning)
CREATE TABLE courses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL
);

-- 6. Tabla de Ítems de la Ruta de Aprendizaje (Learning)
CREATE TABLE learning_path_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    course_id BIGINT NOT NULL,
    tutorial_id BIGINT NOT NULL,
    item_order INT NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    CONSTRAINT fk_learning_path_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- 7. Tabla de Estudiantes (Learning)
CREATE TABLE students (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_record_id VARCHAR(36) NOT NULL UNIQUE,
    profile_id BIGINT NOT NULL, -- Clave Foránea Lógica hacia el Bounded Context profiles
    total_completed_courses INT NOT NULL DEFAULT 0,
    total_completed_tutorials INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL
);

-- 8. Tabla de Matrículas (Learning)
CREATE TABLE enrollments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_record_id VARCHAR(36) NOT NULL,
    course_id BIGINT NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    CONSTRAINT fk_enrollments_course FOREIGN KEY (course_id) REFERENCES courses(id)
);

-- 9. Tabla de Ítems de Registro de Progreso (Learning)
CREATE TABLE progress_record_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id BIGINT NOT NULL,
    tutorial_id BIGINT NOT NULL,
    status VARCHAR(50) NOT NULL,
    completed_at DATETIME NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    CONSTRAINT fk_progress_items_enrollment FOREIGN KEY (enrollment_id) REFERENCES enrollments(id) ON DELETE CASCADE
);
```

---

## 8. Los 10 Mandamientos Arquitectónicos del Docente para Atelier

Para que el diseño táctico del backend de Atelier cumpla con los máximos criterios de la rúbrica, se adoptan como normas inquebrantables los 10 patrones observados en `learning-center-platform`:

1. **Inmutabilidad Absoluta en Casos de Uso:** Todos los Commands, Queries y Resources son **Java Records** con constructores compactos que validan precondiciones (no nulos, no vacíos, rangos válidos).
2. **Hexagonal Persistence Decoupling:** Los agregados de dominio **nunca llevan anotaciones `@Entity` ni `@Table`**. Heredan de `AbstractDomainAggregateRoot<T>`. Las anotaciones ORM residen exclusivamente en `*PersistenceEntity` dentro de la capa `infrastructure`.
3. **Control de Flujo Funcional (`Result<T, E>`):** Se prohíben bloques `try-catch` para validaciones de negocio ordinarias. Los métodos de servicios de aplicación retornan `Result.success(value)` o `Result.failure(ApplicationError)`.
4. **Separación de Responsabilidades en HTTP (Assemblers):** Los controladores nunca instancian agregados ni entidades JPA directamente. Emplean `*CommandFromResourceAssembler` para transformar el payload entrante y `ResponseEntityAssembler` para el payload de retorno.
5. **Aislamiento Estricto entre Bounded Contexts (No Foreign Keys cruzadas):** Queda terminantemente prohibido hacer `@ManyToOne`, `@OneToMany` o `@JoinColumn` de JPA entre entidades físicas de distintos Bounded Contexts. La vinculación inter-contexto se realiza exclusivamente mediante **Value Objects de ID lógico** (`TenantId`, `CustomerId`, `VehicleId`, `BranchId`).
6. **Open Host Service (OHS) para Consultas Síncronas:** Todo Bounded Context que deba proveer información a otro debe exponer una interfaz pública en su paquete `interfaces.acl` (ej. `TenancyContextFacade`, `ProfilesContextFacade`).
7. **Anti-Corruption Layer (ACL) para Consumo:** El contexto consumidor debe encapsular las llamadas a servicios externos o a otros Bounded Contexts dentro de una clase en `application.internal.outboundservices.acl` (ej. `ExternalNubefactService`, `ExternalStripeService`, `ExternalProfileService`).
8. **Coreografía de Eventos Asíncronos:** Los eventos de integración inter-contexto deben residir en `interfaces.events` del contexto emisor (el *Published Language*) y ser escuchados por handlers en `application.internal.eventhandlers` del contexto receptor.
9. **Auditoría Transversal Estandarizada:** Todas las entidades físicas deben heredar de `AuditableAbstractPersistenceEntity`, garantizando columnas `created_at` y `updated_at`. En Atelier, se adopta `UUID` como clave primaria en lugar de `Long` para soportar la arquitectura multi-tenant distribuida sin colisiones.
10. **Contratos Vivos OpenAPI:** Cada endpoint REST debe estar documentado exhaustivamente con anotaciones `@Operation`, `@ApiResponses`, `@ApiResponse` y `@Tag` de Swagger/OpenAPI 3.0 para garantizar la generación automática de SDKs y clientes móviles.
