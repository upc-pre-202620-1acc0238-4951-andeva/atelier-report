# Catálogo Maestro de Endpoints REST de Atelier Platform Backend

Este documento constituye el índice de referencia general y punto de entrada a la especificación técnica exhaustiva de los **188 endpoints REST** que componen la API del backend modular de **Atelier**.

---

## 1. Visión General de la API

La API de Atelier está diseñada bajo los principios de **Arquitectura Hexagonal (Ports & Adapters)** y **Diseño Guiado por el Dominio (DDD)**, estructurada en 8 Bounded Contexts independientes con aislamiento lógico multi-inquilino (*multi-tenant*).

### Especificaciones de Plataforma
* **Framework:** Spring Boot 3.4.x sobre Java 25 con soporte nativo de hilos virtuales (*Virtual Threads* de Project Loom).
* **Persistencia Relacional:** PostgreSQL 16 alojado en Aiven Cloud.
* **Persistencia de Series Temporales:** TimescaleDB para la ingesta telemática de alta frecuencia proveniente de escáneres OBD-II.
* **Inteligencia Artificial Diagnóstica:** Integración mediante Spring AI con modelos Llama 3 70B alojados en Groq Cloud LPU.
* **Estándar de Errores:** RFC 7807 Problem Details (`application/problem+json`).
* **Seguridad y Control de Acceso:** Tokens de acceso JWT con resolución O(1) de permisos atómicos (`claims.permissions`) y control de acceso basado en roles (RBAC) soberano por taller.

---

## 2. Convenciones Globales y Seguridad

### 2.1. Cabeceras HTTP Obligatorias
Toda petición hacia los endpoints protegidos de la plataforma debe incluir las siguientes cabeceras:

| Cabecera | Tipo | Obligatorio | Descripción |
| :--- | :--- | :--- | :--- |
| `Authorization` | `String` | Sí (excepto auth pública y webhooks) | Token de portador con formato `Bearer <JWT>` |
| `Content-Type` | `String` | Sí (en peticiones con cuerpo) | `application/json` |
| `X-Tenant-Id` | `UUID` | Opcional | Identificador del taller en caso de sobreescritura administrativa de contexto |
| `Stripe-Signature` | `String` | Sí (solo en `/api/v1/billing/webhooks/stripe`) | Firma criptográfica HMAC-SHA256 emitida por Stripe |

### 2.2. Esquema Global de Errores (RFC 7807)
Todos los errores de validación, reglas de negocio o excepciones de dominio devuelven una estructura uniforme `ProblemDetail`:

```json
{
  "type": "https://api.atelier.pe/errors/resource-not-found",
  "title": "Recurso No Encontrado",
  "status": 404,
  "detail": "No se encontró el registro solicitado con el identificador proporcionado.",
  "instance": "/api/v1/operations/work-orders/c8f2a1b0-4d3e-4b2a-9f1c-7e8a9b0c1d2e",
  "timestamp": "2026-10-01T20:30:00Z"
}
```

En errores de validación de formulario (código HTTP 400), se adjunta la propiedad adicional `invalidParams`:

```json
{
  "type": "https://api.atelier.pe/errors/invalid-parameters",
  "title": "Parámetros de Petición Inválidos",
  "status": 400,
  "detail": "La petición contiene campos que no superaron las restricciones de validación.",
  "instance": "/api/v1/customers",
  "timestamp": "2026-10-01T20:30:00Z",
  "invalidParams": [
    {
      "name": "email",
      "reason": "El formato del correo electrónico es inválido"
    }
  ]
}
```

---

## 3. Matriz de Bounded Contexts y Documentación Detallada

La especificación exhaustiva de cada endpoint (incluyendo firmas de métodos Java, controladores, registros DTO de petición/respuesta, ejemplos JSON completos y tablas de excepciones de dominio) se encuentra desglosada en los siguientes documentos:

| Bounded Context | Endpoints | Controladores Principales | Archivo de Especificación |
| :--- | :---: | :--- | :--- |
| **IAM & Tenancy** | 28 | `AuthenticationController`, `TenantsController`, `BranchesController`, `InvitationsController`, `MembershipsController`, `RolesController`, `UsersController` | [01-iam-and-tenancy.md](file:///home/shouy/development/atelier-report/docs/backend-documentation/api-endpoints/01-iam-and-tenancy.md) |
| **CRM & Fleet Management** | 22 | `CustomersController`, `VehiclesController`, `FleetsController`, `CustomerNotesController` | [02-crm-and-fleet.md](file:///home/shouy/development/atelier-report/docs/backend-documentation/api-endpoints/02-crm-and-fleet.md) |
| **Workshop Operations (MRO)** | 36 | `WorkOrdersController`, `InspectionsController`, `QuotationsController`, `TaskProposalsController`, `TasksController`, `BaysController` | [03-workshop-operations.md](file:///home/shouy/development/atelier-report/docs/backend-documentation/api-endpoints/03-workshop-operations.md) |
| **Inventory & Supply Chain** | 22 | `PartsCatalogController`, `SuppliersController`, `PurchaseOrdersController`, `BatchesController`, `StockAlertsController` | [04-inventory-and-supply-chain.md](file:///home/shouy/development/atelier-report/docs/backend-documentation/api-endpoints/04-inventory-and-supply-chain.md) |
| **Human Resources & Shifts** | 27 | `WorkShiftsController`, `AttendanceController`, `PayrollPaymentsController`, `StaffProfilesController` | [05-human-resources.md](file:///home/shouy/development/atelier-report/docs/backend-documentation/api-endpoints/05-human-resources.md) |
| **Invoicing & Compliance** | 18 | `ElectronicVouchersController`, `VoucherPaymentsController`, `SeriesConfigurationsController`, `FinancialReportsController` | [06-invoicing-and-compliance.md](file:///home/shouy/development/atelier-report/docs/backend-documentation/api-endpoints/06-invoicing-and-compliance.md) |
| **SaaS Billing & Subscriptions** | 13 | `SubscriptionPlansController`, `TenantSubscriptionsController`, `SaasInvoicesController`, `StripeWebhookController` | [07-saas-billing-and-subscriptions.md](file:///home/shouy/development/atelier-report/docs/backend-documentation/api-endpoints/07-saas-billing-and-subscriptions.md) |
| **IoT Telemetry & Predictive Maintenance** | 22 | `Obd2DevicesController`, `DeviceInstallationsController`, `TelemetryIngestionController`, `VehicleFaultsController`, `PredictiveAlertsController`, `VehicleHealthReportsController` | [08-iot-telemetry-and-predictive-maintenance.md](file:///home/shouy/development/atelier-report/docs/backend-documentation/api-endpoints/08-iot-telemetry-and-predictive-maintenance.md) |
| **Total Global** | **188** | **34 Controladores REST** | **8 Documentos Técnicos** |

---

## 4. Gobernanza de Roles, Permisos y Aprovisionamiento Soberano

Todos los endpoints documentados están protegidos mediante anotaciones de seguridad declarativa `@PreAuthorize("hasAuthority('...')")`.

Para consultar la matriz completa de asignación de permisos hacia los 8 roles de fábrica de Atelier (`ROLE_WORKSHOP_OWNER`, `ROLE_WORKSHOP_ADMINISTRATOR`, `ROLE_CHIEF_MECHANIC`, `ROLE_SERVICE_ADVISOR`, `ROLE_RECEPTIONIST`, `ROLE_MECHANIC`, `ROLE_INVENTORY_MANAGER`, `ROLE_CASHIER`), así como las directivas de asignación multi-rol y edición soberana por taller, consulte el documento:

* [atelier-roles.md](file:///home/shouy/development/atelier-report/docs/backend-documentation/atelier-roles.md)

---

## 5. Política de Calidad y Formato

Este catálogo y sus documentos hijos cumplen estrictamente las siguientes directrices de ingeniería:
* Ausencia absoluta de rayas o guiones largos (em dashes).
* Ausencia absoluta del signo ortográfico punto y coma en prosa narrativa y celdas de tablas Markdown.
* Ejemplos JSON completos y realistas contextualizados en la operativa automotriz y tributaria peruana.
* Rutas y enlaces relativos válidos mediante el esquema de archivo `file://`.
