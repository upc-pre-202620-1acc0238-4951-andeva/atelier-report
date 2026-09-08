# Especificación Táctica Canónica del Backend: Atelier Platform (v2)

Este documento es la **Especificación Maestra de Diseño Táctico (Tactical-Level Domain-Driven Design)** para el backend de **Atelier Platform** (`com.andeva.atelier.platform`), construido sobre Java 26, Spring Boot 4.0.6 y PostgreSQL con TimescaleDB.

Esta especificación sintetiza e integra:
1. Los **estándares y patrones de excelencia del docente** ([docs/backend-documentation/learning-center-platform-reference.md](file:///home/shouy/development/atelier-report/docs/backend-documentation/learning-center-platform-reference.md)).
2. El **análisis y activos rescatados de la versión previa** ([docs/backend-documentation/atelier-platform-v1-reference.md](file:///home/shouy/development/atelier-report/docs/backend-documentation/atelier-platform-v1-reference.md)).
3. La **Biblia Documental y de Base de Datos de Atelier** ([docs/atelier-database-schema.md](file:///home/shouy/development/atelier-report/docs/atelier-database-schema.md), [docs/atelier-documentation.md](file:///home/shouy/development/atelier-report/docs/atelier-documentation.md), [docs/backend-documentation/atelier-tactical-ddd-guide.md](file:///home/shouy/development/atelier-report/docs/backend-documentation/atelier-tactical-ddd-guide.md)).
4. Los **requisitos estrictos de la rúbrica académica** ([docs/project-statement.md](file:///home/shouy/development/atelier-report/docs/project-statement.md), Sección 2.6).

---

## 1. Plan de Desarrollo Bounded Context por Bounded Context

Para garantizar una precisión milimétrica y cero inconsistencias en los 8 Bounded Contexts y el Bounded Context Shared, el diseño táctico se estructura en fases secuenciales:

| Fase | Bounded Context | Paquete Java | Tablas Físicas Asignadas | Servicios Externos / Integraciones |
| :--- | :--- | :--- | :--- | :--- |
| **0** | **Shared** | `com.andeva.atelier.platform.shared` | MappedSuperclass (`AuditableAbstractPersistenceEntity`) | Spring Data Commons, JJWT, i18n |
| **1** | **IAM & Tenancy Context** | `com.andeva.atelier.platform.iam` | `tenants`, `branches`, `users`, `roles`, `permissions`, `tenant_memberships`, `invitations`, `verification_tokens` (8 tablas) | Resend API (HTTPS 443), JJWT (0.12.6), BCrypt |
| **2** | **Customer & Fleet Management (CRM)** | `com.andeva.atelier.platform.crm` | `customers`, `vehicles`, `appointments` (3 tablas) | Google Places API, Atelier Driver Sync |
| **3** | **Workshop Operations (MRO)** | `com.andeva.atelier.platform.operations` | `work_bays`, `work_orders`, `work_order_tasks`, `work_order_task_products`, `work_order_images`, `work_order_task_images`, `services` (7 tablas) | Firebase Storage (Direct-to-Cloud), SQLite Offline |
| **4** | **Inventory & Supply Chain Context** | `com.andeva.atelier.platform.inventory` | `inventory_items`, `inventory_batches`, `suppliers`, `purchase_orders`, `purchase_order_items` (5 tablas) | FIFO Engine, Image URL de Facturas |
| **5** | **Human Resources Management (HR)** | `com.andeva.atelier.platform.hr` | `work_shifts`, `attendance_records`, `payroll_payments` (3 tablas) | Fórmula de Haversine (GPS Geofencing), Google Places API |
| **6** | **Invoicing & Compliance Context** | `com.andeva.atelier.platform.invoicing` | `electronic_vouchers`, `voucher_lines`, `voucher_payments`, `sunat_series_configurations` (4 tablas) | Nubefact API JSON V1 (UBL 2.1 SUNAT), Resend API |
| **7** | **SaaS Billing & Subscriptions Context**| `com.andeva.atelier.platform.billing` | `plans`, `subscriptions`, `invoices`, `stripe_events` (4 tablas) | Stripe API Java SDK, Webhook Idempotency, Caffeine Cache, Outbox |
| **8** | **IoT Telemetry & Predictive Maintenance**| `com.andeva.atelier.platform.iot` | `obd2_devices`, `device_installations`, `telemetry_logs` (Hipertabla TimescaleDB), `vehicle_faults`, `predictive_alerts` (5 tablas) | TimescaleDB Extension, Firebase Cloud Messaging (FCM) |

---

## 2. Plantilla Estricta de Documentación por Bounded Context (Según Rúbrica 2.6)

Cada uno de los 8 Bounded Contexts contendrá las 7 secciones obligatorias:

1. **Diccionario y Resumen Ejecutivo:**
   * Propósito del contexto en Atelier.
   * Capacidades y límites de responsabilidad.
2. **Domain Layer (Capa de Dominio):**
   * **Aggregates & Aggregate Roots:** Clases que extienden `AbstractDomainAggregateRoot<T>`, atributos privados con Value Objects, invariantes y métodos de mutación de estado con eventos de dominio.
   * **Entities:** Entidades secundarias dependientes con ciclo de vida interno.
   * **Value Objects:** Java Records inmutables con validación compacta de no-nulos y formato.
   * **Domain Commands:** Java Records con constructores de validación.
   * **Domain Queries:** Java Records para lecturas inmutables.
   * **Domain Events:** Java Records con origen, identificadores y timestamps.
   * **Repositories (Interfaces):** Puertos de salida puros sin dependencias de base de datos.
3. **Interface Layer (Capa de Interfaces):**
   * **REST Controllers:** Controladores Spring Web MVC con anotaciones OpenAPI (`@Tag`, `@Operation`, `@ApiResponses`).
   * **Resources / DTOs:** Java Records para Requests (`Create*Resource`, `Update*Resource`) y Responses (`*Resource`).
   * **Resource Assemblers:** Transformadores entre Resources y Commands/Queries, y entre Aggregates y Resources.
   * **Open Host Service (OHS) / Inbound ACL Facade:** Interfaz pública expuesta a otros Bounded Contexts.
   * **Integration Events (Published Language):** Eventos emitidos para consumo de otros contextos.
4. **Application Layer (Capa de Aplicación):**
   * **Command Services & Implementations:** Servicios orquestadores CQRS anotados con `@Service`, ejecutando lógica de negocio y retornando `Result<T, ApplicationError>`.
   * **Query Services & Implementations:** Servicios de lectura que consultan repositorios y retornan opcionales o listas inmutables.
   * **Event Handlers & Listeners:** Clases anotadas con `@EventListener` para eventos de dominio internos o eventos de integración inter-contexto.
   * **Outbound ACL Services:** Clientes que traducen interfaces de otros contextos o pasarelas externas hacia el modelo local.
5. **Infrastructure Layer (Capa de Infraestructura):**
   * **JPA Persistence Entities:** Clases físicas `@Entity` que extienden `AuditableAbstractPersistenceEntity` con identificadores `UUID`.
   * **JPA Repositories:** Interfaces Spring Data JPA (`extends JpaRepository<Entity, UUID>`).
   * **JPA Adapters:** Clases `*RepositoryImpl` que implementan la interfaz de dominio, inyectan el repositorio JPA y publican eventos acumulados.
   * **Persistence Assemblers:** Mapeadores bidireccionales `toEntity(aggregate)` y `toDomain(entity)`.
   * **JPA Converters & Embeddables:** Clases `@Converter` y `@Embeddable` para persistir Value Objects.
   * **External Gateways / Clients:** Clientes HTTP/REST para APIs de terceros (Resend, Nubefact, Stripe, FCM).
6. **Diagramas C4 y UML (Code Level):**
   * **C4 Component Diagram:** Diagrama de componentes del contenedor Backend.
   * **Domain Layer Class Diagram:** Diagrama UML de clases completo con tipos, modificadores de acceso (`+`, `-`, `#`), métodos y multiplicidades.
7. **Database Design Diagram (ERD Relacional):**
   * Diagrama relacional ERD con tablas, columnas, tipos de datos, PK, FK y restricciones de unicidad.

---

## 3. Índice de Especificaciones por Bounded Context

A continuación se indexan los 9 documentos detallados con código fuente Java 26, DTOs, interfaces, servicios CQRS, entidades JPA, adaptadores, diagramas C4 y esquemas ERD para la construcción del backend:

1. [01-shared-kernel.md](file:///home/shouy/development/atelier-report/docs/extended-description-bounded-contexts-backend/01-shared-kernel.md) — Base transversal de eventos de dominio (`AbstractDomainAggregateRoot<T>`), mónada `Result<T, E>` y Value Objects financieros.
2. [02-iam-and-tenancy.md](file:///home/shouy/development/atelier-report/docs/extended-description-bounded-contexts-backend/02-iam-and-tenancy.md) — Multi-inquilino (`Tenant`, `Branch`), identidades (`User`), membresías laborales (`TenantMembership`), RBAC y pasarela Resend API.
3. [03-crm-and-fleet.md](file:///home/shouy/development/atelier-report/docs/extended-description-bounded-contexts-backend/03-crm-and-fleet.md) — Clientes B2C/B2B (`Customer`), parque automotor universal (`Vehicle`, `Vin`, `LicensePlate`) y citas (`Appointment`).
4. [04-workshop-operations.md](file:///home/shouy/development/atelier-report/docs/extended-description-bounded-contexts-backend/04-workshop-operations.md) — Órdenes de trabajo (`WorkOrder`), bahías físicas (`WorkBay`), tareas mecánicas y peritaje multimedia con Firebase Storage.
5. [05-inventory-and-supply-chain.md](file:///home/shouy/development/atelier-report/docs/extended-description-bounded-contexts-backend/05-inventory-and-supply-chain.md) — Catálogo de piezas (`InventoryItem`), costeo FIFO estricto por lote (`InventoryBatch`), órdenes de compra y proveedores.
6. [06-human-resources.md](file:///home/shouy/development/atelier-report/docs/extended-description-bounded-contexts-backend/06-human-resources.md) — Expedientes laborales (`EmployeeProfile`), turnos (`WorkShift`), marcación satelital Haversine y nóminas salariales.
7. [07-invoicing-and-compliance.md](file:///home/shouy/development/atelier-report/docs/extended-description-bounded-contexts-backend/07-invoicing-and-compliance.md) — Facturación electrónica SUNAT UBL 2.1 (`ElectronicVoucher`, `SeriesConfiguration`), cálculo de IGV 18% y pasarela Nubefact.
8. [08-saas-billing-and-subscriptions.md](file:///home/shouy/development/atelier-report/docs/extended-description-bounded-contexts-backend/08-saas-billing-and-subscriptions.md) — Monetización B2B (`SubscriptionPlan`, `TenantSubscription`), integración Stripe SDK, idempotencia de webhooks y cuotas.
9. [09-iot-telemetry-and-predictive-maintenance.md](file:///home/shouy/development/atelier-report/docs/extended-description-bounded-contexts-backend/09-iot-telemetry-and-predictive-maintenance.md) — Escáneres OBD-II (`Obd2Device`), hipertabla TimescaleDB, fallas DTC SAE J2012, motor predictivo y FCM.
