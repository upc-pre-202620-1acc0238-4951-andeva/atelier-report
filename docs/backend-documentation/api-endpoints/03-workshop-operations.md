# Especificación Canónica de Endpoints REST: Workshop Operations Context (MRO)

Este documento define la especificación técnica exhaustiva y canónica de los 36 endpoints REST correspondientes al Bounded Context **Workshop Operations Context (MRO)** (`com.andeva.atelier.platform.operations`) de la plataforma **Atelier Platform Backend**.

El contexto gobierna el ciclo de vida operativo de los vehículos en taller: recepción pericial con checklist e inventario 360°, estimación y presupuestación comercial mediante cotizaciones formales, ejecución técnica de labores mecánicas en bahías y fosos con telemetría de tiempos efectivos (*Wrench Time*), administración de hallazgos periciales y entrega pericial del automóvil.

---

## 1. Documentos de Referencia y Fuentes de Verdad

* [04-workshop-operations.md](file:///home/shouy/development/atelier-report/docs/extended-description-bounded-contexts-backend/04-workshop-operations.md): Especificación táctica extendida del Bounded Context Workshop Operations.
* [atelier-roles.md](file:///home/shouy/development/atelier-report/docs/backend-documentation/atelier-roles.md): Matriz RBAC, catálogo inmutable de permisos atómicos y asignaciones por rol.
* [atelier-database-schema.md](file:///home/shouy/development/atelier-report/docs/atelier-database-schema.md): Estructura relacional de tablas de operaciones en PostgreSQL.
* [28-tactical-level-domain-driven-design-2.md](file:///home/shouy/development/atelier-report/report/chapters/20-requirements-development-and-software-solution-design/28-tactical-level-domain-driven-design-2.md): Diseño táctico y diagramas de arquitectura de software.

---

## 2. Convenciones Globales del API

* **Protocolo y Formato:** RESTful sobre HTTPS, payloads serializados en formato JSON (UTF-8).
* **Prefijo Canónico de Enrutamiento:** `/api/v1/operations`
* **Aislamiento Multi-Inquilino (*Multi-Tenancy*):** Toda petición autenticada requiere el encabezado `Authorization: Bearer <token>`. El identificador de taller (`tenant_id`) se resuelve de forma inmutable desde los claims del token JWT (`claims.tenant_id`) y se valida opcionalmente contra la cabecera `X-Tenant-Id`. Las consultas y mutaciones quedan restringidas al espacio de datos del taller.
* **Representación de Errores:** Todos los errores de validación, dominio y seguridad siguen estrictamente la norma RFC 7807 (*Problem Details for HTTP APIs*).
* **Identificadores Técnicos:** Claves primarias universales en formato UUID v4.
* **Moneda:** Soles peruanos (`PEN`) por defecto.

---

## 3. Matriz General de Endpoints (36 Endpoints)

| N° | Método | Ruta Canónica | Controlador | Permiso Atómico | Rol Mínimo |
| :-: | :---: | :--- | :--- | :--- | :--- |
| 1 | `GET` | `/api/v1/operations/work-orders` | `WorkOrdersController` | `operations:work_orders:read` | `ROLE_RECEPTIONIST` |
| 2 | `POST` | `/api/v1/operations/work-orders` | `WorkOrdersController` | `operations:work_orders:create` | `ROLE_SERVICE_ADVISOR` |
| 3 | `GET` | `/api/v1/operations/work-orders/{id}` | `WorkOrdersController` | `operations:work_orders:read` | `ROLE_RECEPTIONIST` |
| 4 | `PUT` | `/api/v1/operations/work-orders/{id}` | `WorkOrdersController` | `operations:work_orders:update` | `ROLE_SERVICE_ADVISOR` |
| 5 | `POST` | `/api/v1/operations/work-orders/{id}/cancel` | `WorkOrdersController` | `operations:work_orders:cancel` | `ROLE_SERVICE_ADVISOR` |
| 6 | `POST` | `/api/v1/operations/work-orders/{id}/handover` | `WorkOrdersController` | `operations:vehicle_handover:execute` | `ROLE_SERVICE_ADVISOR` |
| 7 | `GET` | `/api/v1/operations/inspections/by-work-order/{workOrderId}` | `InspectionsController` | `operations:inspections:read` | `ROLE_RECEPTIONIST` |
| 8 | `POST` | `/api/v1/operations/inspections` | `InspectionsController` | `operations:inspections:create` | `ROLE_RECEPTIONIST` |
| 9 | `PUT` | `/api/v1/operations/inspections/{id}` | `InspectionsController` | `operations:inspections:update` | `ROLE_SERVICE_ADVISOR` |
| 10 | `POST` | `/api/v1/operations/inspections/{id}/photos` | `InspectionsController` | `operations:inspections:upload_photos` | `ROLE_RECEPTIONIST` |
| 11 | `DELETE` | `/api/v1/operations/inspections/{id}/photos/{photoId}` | `InspectionsController` | `operations:inspections:delete_photos` | `ROLE_SERVICE_ADVISOR` |
| 12 | `GET` | `/api/v1/operations/quotations` | `QuotationsController` | `operations:quotations:read` | `ROLE_SERVICE_ADVISOR` |
| 13 | `POST` | `/api/v1/operations/quotations` | `QuotationsController` | `operations:quotations:create` | `ROLE_SERVICE_ADVISOR` |
| 14 | `GET` | `/api/v1/operations/quotations/{id}` | `QuotationsController` | `operations:quotations:read` | `ROLE_SERVICE_ADVISOR` |
| 15 | `PUT` | `/api/v1/operations/quotations/{id}` | `QuotationsController` | `operations:quotations:update` | `ROLE_SERVICE_ADVISOR` |
| 16 | `POST` | `/api/v1/operations/quotations/{id}/items` | `QuotationsController` | `operations:quotations:update` | `ROLE_SERVICE_ADVISOR` |
| 17 | `DELETE` | `/api/v1/operations/quotations/{id}/items/{itemId}` | `QuotationsController` | `operations:quotations:update` | `ROLE_SERVICE_ADVISOR` |
| 18 | `POST` | `/api/v1/operations/quotations/{id}/send-pdf` | `QuotationsController` | `operations:quotations:send` | `ROLE_SERVICE_ADVISOR` |
| 19 | `POST` | `/api/v1/operations/quotations/{id}/approve` | `QuotationsController` | `operations:quotations:approve` | `ROLE_SERVICE_ADVISOR` |
| 20 | `POST` | `/api/v1/operations/quotations/{id}/reject` | `QuotationsController` | `operations:quotations:reject` | `ROLE_SERVICE_ADVISOR` |
| 21 | `GET` | `/api/v1/operations/proposals/by-work-order/{workOrderId}` | `TaskProposalsController` | `operations:proposals:read` | `ROLE_MECHANIC` |
| 22 | `POST` | `/api/v1/operations/proposals` | `TaskProposalsController` | `operations:proposals:create` | `ROLE_MECHANIC` |
| 23 | `GET` | `/api/v1/operations/proposals/{id}` | `TaskProposalsController` | `operations:proposals:read` | `ROLE_MECHANIC` |
| 24 | `POST` | `/api/v1/operations/proposals/{id}/notify` | `TaskProposalsController` | `operations:proposals:notify` | `ROLE_SERVICE_ADVISOR` |
| 25 | `POST` | `/api/v1/operations/proposals/{id}/approve` | `TaskProposalsController` | `operations:proposals:approve` | `ROLE_SERVICE_ADVISOR` |
| 26 | `POST` | `/api/v1/operations/proposals/{id}/reject` | `TaskProposalsController` | `operations:proposals:reject` | `ROLE_SERVICE_ADVISOR` |
| 27 | `GET` | `/api/v1/operations/tasks` | `TasksController` | `operations:tasks:read` | `ROLE_MECHANIC` |
| 28 | `GET` | `/api/v1/operations/tasks/{id}` | `TasksController` | `operations:tasks:read` | `ROLE_MECHANIC` |
| 29 | `POST` | `/api/v1/operations/tasks/{id}/timer/start` | `TasksController` | `operations:tasks:track_time` | `ROLE_MECHANIC` |
| 30 | `POST` | `/api/v1/operations/tasks/{id}/timer/pause` | `TasksController` | `operations:tasks:track_time` | `ROLE_MECHANIC` |
| 31 | `POST` | `/api/v1/operations/tasks/{id}/photos` | `TasksController` | `operations:tasks:upload_photos` | `ROLE_MECHANIC` |
| 32 | `POST` | `/api/v1/operations/tasks/{id}/hold` | `TasksController` | `operations:tasks:hold_request` | `ROLE_MECHANIC` |
| 33 | `POST` | `/api/v1/operations/tasks/{id}/resume` | `TasksController` | `operations:tasks:hold_validate` | `ROLE_CHIEF_MECHANIC` |
| 34 | `POST` | `/api/v1/operations/tasks/{id}/complete` | `TasksController` | `operations:tasks:complete` | `ROLE_MECHANIC` |
| 35 | `GET` | `/api/v1/operations/bays` | `BaysController` | `operations:bays:read` | `ROLE_MECHANIC` |
| 36 | `POST` | `/api/v1/operations/bays/{id}/reassign` | `BaysController` | `operations:bays:reassign` | `ROLE_CHIEF_MECHANIC` |

---

## 4. Catálogo Detallado de Endpoints REST


### 4.1. [GET] `/api/v1/operations/work-orders`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.WorkOrdersController`
* **Método Java:** `public ResponseEntity<Page<WorkOrderSummaryResource>> getWorkOrders(Pageable pageable, @RequestParam(required = false) UUID branchId, @RequestParam(required = false) String status, @RequestParam(required = false) UUID vehicleId, @RequestParam(required = false) UUID customerId, @RequestParam(required = false) Instant from, @RequestParam(required = false) Instant to)`
* **Ruta Canónica:** `GET /api/v1/operations/work-orders`
* **Propósito Funcional:** Recupera un conjunto paginado y filtrado de órdenes de trabajo del taller automotriz, permitiendo segmentar por sucursal física, estado operativo, vehículo atendido, cliente propietario y ventana temporal de apertura.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_RECEPTIONIST`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:work_orders:read')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Accept` | `String` | No | application/json por defecto. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):** No aplica.

**Parámetros de Consulta (Query Parameters):**

| Parámetro | Tipo | Requerido | Valor por Defecto | Descripción |
| :--- | :--- | :---: | :---: | :--- |
| `branchId` | `UUID` | No | `null` | Filtro por identificador único de la sede física o sucursal operativa. |
| `status` | `String` | No | `null` | Filtro por estado operativo (PENDING_DIAGNOSIS, ESTIMATION, WAITING_APPROVAL, IN_PROGRESS, PAUSED, FINAL_INSPECTION, COMPLETED, PAID, CANCELLED, DELIVERED). |
| `vehicleId` | `UUID` | No | `null` | Filtro por identificador único del automóvil registrado en el taller. |
| `customerId` | `UUID` | No | `null` | Filtro por identificador único del cliente propietario o titular de flota. |
| `from` | `Instant` | No | `null` | Marca temporal ISO-8601 inicial para acotar fecha de creación de la orden. |
| `to` | `Instant` | No | `null` | Marca temporal ISO-8601 final para acotar fecha de creación de la orden. |
| `page` | `Integer` | No | `0` | Índice de la página de resultados base cero. |
| `size` | `Integer` | No | `20` | Cantidad de elementos retornados por página. |
| `sort` | `String` | No | `createdAt,desc` | Criterio y dirección de ordenamiento de resultados. |

#### Cuerpo de Petición (Request)

No requiere cuerpo de petición (petición sin contenido o parámetros en URL).

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `org.springframework.data.domain.Page<com.andeva.atelier.platform.operations.interfaces.rest.resources.WorkOrderSummaryResource>`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `content[].id` | `UUID` | Identificador único global de la orden de trabajo. |
| `content[].orderNumber` | `String` | Código correlativo de negocio generado para la orden (ej. OT-2026-00451). |
| `content[].branchId` | `UUID` | Identificador de la sede operativa receptora del vehículo. |
| `content[].vehicleId` | `UUID` | Identificador del automóvil en el módulo CRM de flotas. |
| `content[].vehiclePlate` | `String` | Placa de rodaje vehicular de identificación rápida. |
| `content[].customerId` | `UUID` | Identificador del cliente titular de la atención. |
| `content[].customerFullName` | `String` | Nombre y apellidos completos o razón social del titular. |
| `content[].status` | `String` | Estado operativo actual dentro de la máquina de estados. |
| `content[].assignedBayId` | `UUID` | Identificador de la bahía física asignada si existe. |
| `content[].assignedBayNumber` | `String` | Código visible de la bahía física (ej. B-02). |
| `content[].totalServicesAmount` | `BigDecimal` | Importe consolidado por conceptos de mano de obra en moneda local. |
| `content[].totalProductsAmount` | `BigDecimal` | Importe consolidado por repuestos e insumos imputados. |
| `content[].grandTotal` | `BigDecimal` | Monto total acumulado de la orden incluyendo impuestos. |
| `content[].currency` | `String` | Código de moneda ISO-4217 de la liquidación (PEN). |
| `content[].intakeMileage` | `Integer` | Kilometraje registrado al momento del ingreso físico. |
| `content[].createdAt` | `Instant` | Marca temporal de registro inicial en UTC. |
| `content[].updatedAt` | `Instant` | Marca temporal de la última actualización en UTC. |
| `totalElements` | `Long` | Cantidad total de órdenes coincidentes con los filtros aplicados. |
| `totalPages` | `Integer` | Cantidad total de bloques paginados disponibles. |
| `size` | `Integer` | Tamaño de bloque configurado para la respuesta. |
| `number` | `Integer` | Índice del bloque actual retornado. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "content": [
    {
      "id": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
      "orderNumber": "OT-2026-00451",
      "branchId": "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
      "vehicleId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "vehiclePlate": "ABC-123",
      "customerId": "8f3b2a1c-4d5e-6f7a-8b9c-0d1e2f3a4b5c",
      "customerFullName": "Carlos Alberto Mendoza Morales",
      "status": "IN_PROGRESS",
      "assignedBayId": "9b1c2d3e-4f5a-6b7c-8d9e-0f1a2b3c4d5e",
      "assignedBayNumber": "B-02",
      "totalServicesAmount": 280.00,
      "totalProductsAmount": 450.50,
      "grandTotal": 730.50,
      "currency": "PEN",
      "intakeMileage": 84520,
      "createdAt": "2026-10-01T08:30:00Z",
      "updatedAt": "2026-10-01T11:15:20Z"
    }
  ],
  "pageable": {
    "pageNumber": 0,
    "pageSize": 20,
    "sort": {
      "empty": false,
      "sorted": true,
      "unsorted": false
    },
    "offset": 0,
    "paged": true,
    "unpaged": false
  },
  "totalElements": 1,
  "totalPages": 1,
  "last": true,
  "size": 20,
  "number": 0,
  "sort": {
    "empty": false,
    "sorted": true,
    "unsorted": false
  },
  "numberOfElements": 1,
  "first": true,
  "empty": false
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 400 | `INVALID_QUERY_PARAMETER` | `IllegalArgumentException` | Uno de los parámetros de filtrado posee formato inválido o fuera de rango. |
| 401 | `UNAUTHORIZED_TOKEN` | `AuthenticationException` | Token de autenticación faltante, expirado o con firma criptográfica inválida. |
| 403 | `ACCESS_DENIED` | `AccessDeniedException` | El usuario no cuenta con la autoridad operations:work_orders:read en su membresía. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/invalid-query-parameter",
  "title": "Parámetro de Consulta Inválido",
  "status": 400,
  "detail": "El valor 'IN_VALID_STATUS' no corresponde a ningún estado operativo permitido.",
  "instance": "/api/v1/operations/work-orders",
  "code": "INVALID_QUERY_PARAMETER",
  "timestamp": "2026-10-01T14:22:10Z"
}
```

---

### 4.2. [POST] `/api/v1/operations/work-orders`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.WorkOrdersController`
* **Método Java:** `public ResponseEntity<WorkOrderResource> createWorkOrder(@Valid @RequestBody CreateWorkOrderResource resource, UriComponentsBuilder ucb)`
* **Ruta Canónica:** `POST /api/v1/operations/work-orders`
* **Propósito Funcional:** Formaliza la apertura de una nueva orden de trabajo en recepción técnica vehicular, vinculando el automóvil, cliente titular, kilometraje físico de ingreso, porcentaje de combustible y descripción inicial de la falla reportada.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_SERVICE_ADVISOR`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:work_orders:create')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Content-Type` | `String` | Sí | application/json para el cuerpo del mensaje. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):** No aplica.

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.CreateWorkOrderResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `branchId` | `UUID` | Sí | @NotNull | Identificador de la sede física receptora. |
| `vehicleId` | `UUID` | Sí | @NotNull | Identificador del vehículo que ingresa. |
| `customerId` | `UUID` | Sí | @NotNull | Identificador del cliente titular del servicio. |
| `intakeMileage` | `Integer` | Sí | @NotNull, @Min(0) | Lectura del odómetro vehicular al ingresar. |
| `fuelLevelPercent` | `Integer` | Sí | @NotNull, @Min(0), @Max(100) | Nivel de combustible en escala de 0 a 100. |
| `customerNotes` | `String` | No | @Size(max = 1000) | Observaciones preliminares expresadas por el cliente. |
| `initialDiagnosis` | `String` | No | @Size(max = 2000) | Diagnóstico inicial elaborado por el asesor de servicio. |
| `appointmentId` | `UUID` | No | Opcional | Identificador de la cita previa de servicio si aplica. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "branchId": "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
  "vehicleId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "customerId": "8f3b2a1c-4d5e-6f7a-8b9c-0d1e2f3a4b5c",
  "intakeMileage": 84520,
  "fuelLevelPercent": 65,
  "customerNotes": "Manifiesta zumbido agudo en eje delantero al aplicar frenado a más de 60 km/h.",
  "initialDiagnosis": "Posible desgaste severo en pastillas de freno delanteras y alabeo de discos ventilados.",
  "appointmentId": "f47ac10b-58cc-4372-a567-0e02b2c3d479"
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `201 Created`
* **Cabecera de Ubicación (*Location Header*):** `/api/v1/operations/work-orders/7b8e5c12-3f84-4a21-9d10-8b45f1e29001`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.WorkOrderResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador técnico de la orden de trabajo generada. |
| `orderNumber` | `String` | Código correlativo institucional de la orden. |
| `tenantId` | `UUID` | Identificador del taller automotriz titular. |
| `branchId` | `UUID` | Identificador de la sede operativa. |
| `vehicleId` | `UUID` | Identificador del automóvil atendido. |
| `vehiclePlate` | `String` | Placa de rodaje vehicular consultada. |
| `customerId` | `UUID` | Identificador del cliente titular. |
| `customerFullName` | `String` | Nombre completo o razón social del cliente. |
| `status` | `String` | Estado operativo inicial (PENDING_DIAGNOSIS). |
| `intakeMileage` | `Integer` | Kilometraje comprobado en odómetro. |
| `fuelLevelPercent` | `Integer` | Porcentaje verificado en indicador de combustible. |
| `customerNotes` | `String` | Motivo de ingreso relatado por el usuario. |
| `initialDiagnosis` | `String` | Juicio técnico inicial del asesor. |
| `assignedBayId` | `UUID` | Identificador de bahía asignada si se configuró. |
| `totalServicesAmount` | `BigDecimal` | Importe total acumulado por mano de obra. |
| `totalProductsAmount` | `BigDecimal` | Importe total acumulado por repuestos. |
| `grandTotal` | `BigDecimal` | Total consolidado de la orden en moneda local. |
| `currency` | `String` | Código ISO de la moneda pactada (PEN). |
| `createdAt` | `Instant` | Marca temporal de apertura en UTC. |
| `updatedAt` | `Instant` | Marca temporal de actualización en UTC. |
| `version` | `Long` | Número de versión para control de concurrencia optimista. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "orderNumber": "OT-2026-00451",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "branchId": "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
  "vehicleId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "vehiclePlate": "ABC-123",
  "customerId": "8f3b2a1c-4d5e-6f7a-8b9c-0d1e2f3a4b5c",
  "customerFullName": "Carlos Alberto Mendoza Morales",
  "status": "PENDING_DIAGNOSIS",
  "intakeMileage": 84520,
  "fuelLevelPercent": 65,
  "customerNotes": "Manifiesta zumbido agudo en eje delantero al aplicar frenado a más de 60 km/h.",
  "initialDiagnosis": "Posible desgaste severo en pastillas de freno delanteras y alabeo de discos ventilados.",
  "assignedBayId": null,
  "totalServicesAmount": 0.00,
  "totalProductsAmount": 0.00,
  "grandTotal": 0.00,
  "currency": "PEN",
  "createdAt": "2026-10-01T08:30:00Z",
  "updatedAt": "2026-10-01T08:30:00Z",
  "version": 0
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 400 | `INVALID_MILEAGE` | `InvalidMileageException` | El kilometraje indicado es negativo o menor al registro histórico del vehículo. |
| 404 | `VEHICLE_NOT_FOUND` | `VehicleNotFoundException` | El vehículo referenciado no existe en el registro del taller. |
| 409 | `WORK_ORDER_ALREADY_ACTIVE_FOR_VEHICLE` | `IllegalStateException` | El vehículo ya cuenta con una orden de trabajo activa en el taller. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/invalid-mileage",
  "title": "Kilometraje Inválido",
  "status": 400,
  "detail": "El kilometraje de ingreso (84520) es inferior al último registro comprobado (85100).",
  "instance": "/api/v1/operations/work-orders",
  "code": "INVALID_MILEAGE",
  "timestamp": "2026-10-01T08:30:01Z"
}
```

---

### 4.3. [GET] `/api/v1/operations/work-orders/{id}`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.WorkOrdersController`
* **Método Java:** `public ResponseEntity<WorkOrderResource> getWorkOrderById(@PathVariable UUID id)`
* **Ruta Canónica:** `GET /api/v1/operations/work-orders/{id}`
* **Propósito Funcional:** Obtiene el detalle exhaustivo de una orden de trabajo específica mediante su identificador único, proyectando su estado operativo, datos vehiculares consolidados y totales de liquidación.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_RECEPTIONIST`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:work_orders:read')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Accept` | `String` | No | application/json por defecto. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador único global de la orden de trabajo. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

No requiere cuerpo de petición (petición sin contenido o parámetros en URL).

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.WorkOrderResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador técnico de la orden de trabajo. |
| `orderNumber` | `String` | Código correlativo unívoco de la orden. |
| `tenantId` | `UUID` | Identificador del taller titular. |
| `branchId` | `UUID` | Identificador de la sede operativa. |
| `vehicleId` | `UUID` | Identificador del automóvil en CRM. |
| `vehiclePlate` | `String` | Placa de rodaje vehicular. |
| `customerId` | `UUID` | Identificador del cliente titular. |
| `customerFullName` | `String` | Nombre completo o razón social del cliente. |
| `status` | `String` | Estado operativo actual. |
| `intakeMileage` | `Integer` | Kilometraje registrado en odómetro. |
| `fuelLevelPercent` | `Integer` | Nivel de combustible registrado. |
| `customerNotes` | `String` | Observaciones del cliente. |
| `initialDiagnosis` | `String` | Diagnóstico inicial del asesor. |
| `assignedBayId` | `UUID` | Bahía asignada actualmente si existe. |
| `totalServicesAmount` | `BigDecimal` | Suma de importes de mano de obra. |
| `totalProductsAmount` | `BigDecimal` | Suma de importes de repuestos. |
| `grandTotal` | `BigDecimal` | Monto total acumulado de la orden. |
| `currency` | `String` | Código de moneda ISO-4217 (PEN). |
| `createdAt` | `Instant` | Marca temporal de apertura en UTC. |
| `updatedAt` | `Instant` | Marca temporal de última modificación en UTC. |
| `version` | `Long` | Número de versión para bloqueo optimista. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "orderNumber": "OT-2026-00451",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "branchId": "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
  "vehicleId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "vehiclePlate": "ABC-123",
  "customerId": "8f3b2a1c-4d5e-6f7a-8b9c-0d1e2f3a4b5c",
  "customerFullName": "Carlos Alberto Mendoza Morales",
  "status": "IN_PROGRESS",
  "intakeMileage": 84520,
  "fuelLevelPercent": 65,
  "customerNotes": "Manifiesta zumbido agudo en eje delantero al aplicar frenado a más de 60 km/h.",
  "initialDiagnosis": "Posible desgaste severo en pastillas de freno delanteras y alabeo de discos ventilados.",
  "assignedBayId": "9b1c2d3e-4f5a-6b7c-8d9e-0f1a2b3c4d5e",
  "totalServicesAmount": 280.00,
  "totalProductsAmount": 450.50,
  "grandTotal": 730.50,
  "currency": "PEN",
  "createdAt": "2026-10-01T08:30:00Z",
  "updatedAt": "2026-10-01T11:15:20Z",
  "version": 3
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `WORK_ORDER_NOT_FOUND` | `WorkOrderNotFoundException` | La orden de trabajo con el identificador provisto no existe en el taller. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/work-order-not-found",
  "title": "Orden de Trabajo No Encontrada",
  "status": 404,
  "detail": "No se encontró la orden de trabajo con ID 7b8e5c12-3f84-4a21-9d10-8b45f1e29001.",
  "instance": "/api/v1/operations/work-orders/7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "code": "WORK_ORDER_NOT_FOUND",
  "timestamp": "2026-10-01T14:30:00Z"
}
```

---

### 4.4. [PUT] `/api/v1/operations/work-orders/{id}`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.WorkOrdersController`
* **Método Java:** `public ResponseEntity<WorkOrderResource> updateWorkOrder(@PathVariable UUID id, @Valid @RequestBody UpdateWorkOrderResource resource)`
* **Ruta Canónica:** `PUT /api/v1/operations/work-orders/{id}`
* **Propósito Funcional:** Actualiza los parámetros operativos complementarios de la orden de trabajo, permitiendo rectificar el kilometraje verificado, nivel de combustible y observaciones diagnósticas del asesor de servicio.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_SERVICE_ADVISOR`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:work_orders:update')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Content-Type` | `String` | Sí | application/json para el cuerpo del mensaje. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador único global de la orden de trabajo a modificar. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.UpdateWorkOrderResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `intakeMileage` | `Integer` | No | @Min(0) | Lectura corregida del odómetro vehicular. |
| `fuelLevelPercent` | `Integer` | No | @Min(0), @Max(100) | Nivel de combustible corregido de 0 a 100. |
| `customerNotes` | `String` | No | @Size(max = 1000) | Ampliación de notas expuestas por el cliente. |
| `initialDiagnosis` | `String` | No | @Size(max = 2000) | Diagnóstico técnico refinado. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "intakeMileage": 84525,
  "fuelLevelPercent": 60,
  "customerNotes": "El cliente agrega que el sonido se intensifica con temperatura operativa alta.",
  "initialDiagnosis": "Comprobado alabeo térmico en discos de freno delanteros tras inspección visual en foso."
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.WorkOrderResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador técnico de la orden de trabajo. |
| `orderNumber` | `String` | Código correlativo de la orden. |
| `tenantId` | `UUID` | Identificador del taller titular. |
| `status` | `String` | Estado operativo actual. |
| `intakeMileage` | `Integer` | Kilometraje actualizado. |
| `fuelLevelPercent` | `Integer` | Nivel de combustible actualizado. |
| `customerNotes` | `String` | Notas actualizadas del cliente. |
| `initialDiagnosis` | `String` | Diagnóstico técnico actualizado. |
| `updatedAt` | `Instant` | Marca temporal de la modificación en UTC. |
| `version` | `Long` | Número de versión incrementado tras la actualización. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "orderNumber": "OT-2026-00451",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "branchId": "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
  "vehicleId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "vehiclePlate": "ABC-123",
  "customerId": "8f3b2a1c-4d5e-6f7a-8b9c-0d1e2f3a4b5c",
  "customerFullName": "Carlos Alberto Mendoza Morales",
  "status": "PENDING_DIAGNOSIS",
  "intakeMileage": 84525,
  "fuelLevelPercent": 60,
  "customerNotes": "El cliente agrega que el sonido se intensifica con temperatura operativa alta.",
  "initialDiagnosis": "Comprobado alabeo térmico en discos de freno delanteros tras inspección visual en foso.",
  "assignedBayId": null,
  "totalServicesAmount": 0.00,
  "totalProductsAmount": 0.00,
  "grandTotal": 0.00,
  "currency": "PEN",
  "createdAt": "2026-10-01T08:30:00Z",
  "updatedAt": "2026-10-01T08:45:10Z",
  "version": 1
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 400 | `INVALID_MILEAGE` | `InvalidMileageException` | El kilometraje corregido es negativo. |
| 404 | `WORK_ORDER_NOT_FOUND` | `WorkOrderNotFoundException` | No existe la orden de trabajo con el identificador provisto. |
| 409 | `OPTIMISTIC_LOCKING_FAILURE` | `OptimisticLockingFailureException` | Conflicto de concurrencia optimista al modificar la orden simultáneamente. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/optimistic-locking-failure",
  "title": "Conflicto de Concurrencia",
  "status": 409,
  "detail": "La orden de trabajo fue actualizada por otro usuario concurrentemente.",
  "instance": "/api/v1/operations/work-orders/7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "code": "OPTIMISTIC_LOCKING_FAILURE",
  "timestamp": "2026-10-01T08:45:11Z"
}
```

---

### 4.5. [POST] `/api/v1/operations/work-orders/{id}/cancel`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.WorkOrdersController`
* **Método Java:** `public ResponseEntity<WorkOrderResource> cancelWorkOrder(@PathVariable UUID id, @Valid @RequestBody CancelWorkOrderResource resource)`
* **Ruta Canónica:** `POST /api/v1/operations/work-orders/{id}/cancel`
* **Propósito Funcional:** Ejecuta la cancelación formal y justificada de una orden de trabajo por desistimiento del cliente o inviabilidad técnica, liberando la bahía física ocupada y revocando reservas de inventario.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_SERVICE_ADVISOR`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:work_orders:cancel')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Content-Type` | `String` | Sí | application/json para el cuerpo del mensaje. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador único de la orden a cancelar. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.CancelWorkOrderResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `cancellationReason` | `String` | Sí | @NotBlank, @Size(min = 10, max = 500) | Motivo justificado de la cancelación de la orden. |
| `cancelledBy` | `UUID` | Sí | @NotNull | Identificador del usuario que autoriza la cancelación. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "cancellationReason": "Cliente desiste del servicio por incompatibilidad de tiempos personales de espera.",
  "cancelledBy": "4e1a2b3c-5d6e-7f8a-9b0c-1d2e3f4a5b6c"
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.WorkOrderResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador técnico de la orden. |
| `orderNumber` | `String` | Código correlativo de la orden. |
| `status` | `String` | Nuevo estado operativo (CANCELLED). |
| `assignedBayId` | `UUID` | Bahía física desvinculada (null). |
| `updatedAt` | `Instant` | Marca temporal de cancelación en UTC. |
| `version` | `Long` | Versión optimista actualizada. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "orderNumber": "OT-2026-00451",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "branchId": "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
  "vehicleId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "vehiclePlate": "ABC-123",
  "customerId": "8f3b2a1c-4d5e-6f7a-8b9c-0d1e2f3a4b5c",
  "customerFullName": "Carlos Alberto Mendoza Morales",
  "status": "CANCELLED",
  "intakeMileage": 84520,
  "fuelLevelPercent": 65,
  "customerNotes": "Manifiesta zumbido agudo en eje delantero al aplicar frenado a más de 60 km/h.",
  "initialDiagnosis": "Posible desgaste severo en pastillas de freno delanteras.",
  "assignedBayId": null,
  "totalServicesAmount": 0.00,
  "totalProductsAmount": 0.00,
  "grandTotal": 0.00,
  "currency": "PEN",
  "createdAt": "2026-10-01T08:30:00Z",
  "updatedAt": "2026-10-01T09:10:00Z",
  "version": 2
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `WORK_ORDER_NOT_FOUND` | `WorkOrderNotFoundException` | No existe la orden especificada. |
| 422 | `INVALID_WORK_ORDER_STATUS_TRANSITION` | `InvalidWorkOrderStatusTransitionException` | La orden no puede cancelarse porque ya fue completada, liquidada o entregada. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/invalid-work-order-status-transition",
  "title": "Transición de Estado Inválida",
  "status": 422,
  "detail": "No se puede cancelar una orden de trabajo que se encuentra en estado COMPLETED o DELIVERED.",
  "instance": "/api/v1/operations/work-orders/7b8e5c12-3f84-4a21-9d10-8b45f1e29001/cancel",
  "code": "INVALID_WORK_ORDER_STATUS_TRANSITION",
  "timestamp": "2026-10-01T09:10:01Z"
}
```

---

### 4.6. [POST] `/api/v1/operations/work-orders/{id}/handover`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.WorkOrdersController`
* **Método Java:** `public ResponseEntity<WorkOrderResource> handoverVehicle(@PathVariable UUID id, @Valid @RequestBody HandoverVehicleResource resource)`
* **Ruta Canónica:** `POST /api/v1/operations/work-orders/{id}/handover`
* **Propósito Funcional:** Ejecuta la entrega pericial definitiva del automóvil al cliente titular o tercero apoderado, validando liquidación económica completa, firma digital de conformidad y pase de salida de planta.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_SERVICE_ADVISOR`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:vehicle_handover:execute')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Content-Type` | `String` | Sí | application/json para el cuerpo del mensaje. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador único de la orden a entregar. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.HandoverVehicleResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `recipientDni` | `String` | Sí | @NotBlank, @Pattern(regexp = "\d{8}") | Documento Nacional de Identidad del receptor. |
| `recipientFullName` | `String` | Sí | @NotBlank, @Size(max = 150) | Nombres y apellidos completos del receptor. |
| `customerSignatureUrl` | `String` | Sí | @NotBlank, @URL | Localizador HTTPS de la firma digital de conformidad capturada en tableta. |
| `handoverNotes` | `String` | No | @Size(max = 1000) | Observaciones finales al momento de la entrega. |
| `odometerAtHandover` | `Integer` | Sí | @NotNull, @Min(0) | Lectura final del odómetro al abandonar la sede. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "recipientDni": "45871234",
  "recipientFullName": "Carlos Alberto Mendoza Morales",
  "customerSignatureUrl": "https://storage.googleapis.com/atelier-signatures/tenants/550e8400/wo-7b8e5c12/handover-signature.png",
  "handoverNotes": "Se entrega vehículo con repuestos sustituidos en maletero y llaves completas.",
  "odometerAtHandover": 84528
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.WorkOrderResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador técnico de la orden. |
| `orderNumber` | `String` | Código correlativo de la orden. |
| `status` | `String` | Estado final de entrega (DELIVERED). |
| `updatedAt` | `Instant` | Marca temporal de la entrega en UTC. |
| `version` | `Long` | Versión optimista actualizada. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "orderNumber": "OT-2026-00451",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "branchId": "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
  "vehicleId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "vehiclePlate": "ABC-123",
  "customerId": "8f3b2a1c-4d5e-6f7a-8b9c-0d1e2f3a4b5c",
  "customerFullName": "Carlos Alberto Mendoza Morales",
  "status": "DELIVERED",
  "intakeMileage": 84520,
  "fuelLevelPercent": 65,
  "customerNotes": "Manifiesta zumbido agudo en eje delantero.",
  "initialDiagnosis": "Posible desgaste severo en pastillas de freno.",
  "assignedBayId": null,
  "totalServicesAmount": 280.00,
  "totalProductsAmount": 450.50,
  "grandTotal": 730.50,
  "currency": "PEN",
  "createdAt": "2026-10-01T08:30:00Z",
  "updatedAt": "2026-10-01T17:45:00Z",
  "version": 6
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 400 | `INVALID_HANDOVER_PARAMETERS` | `IllegalArgumentException` | El odómetro final es inferior al kilometraje de ingreso o la firma carece de URL válida. |
| 404 | `WORK_ORDER_NOT_FOUND` | `WorkOrderNotFoundException` | No existe la orden especificada. |
| 422 | `WORK_ORDER_NOT_PAID_OR_COMPLETED` | `IllegalStateException` | La orden no puede entregarse sin estar en estado PAID o COMPLETED. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/work-order-not-paid-or-completed",
  "title": "Orden Pendiente de Pago o Cierre",
  "status": 422,
  "detail": "No se puede entregar el vehículo porque la orden de trabajo aún no ha sido pagada en su totalidad.",
  "instance": "/api/v1/operations/work-orders/7b8e5c12-3f84-4a21-9d10-8b45f1e29001/handover",
  "code": "WORK_ORDER_NOT_PAID_OR_COMPLETED",
  "timestamp": "2026-10-01T17:45:01Z"
}
```

---

### 4.7. [GET] `/api/v1/operations/inspections/by-work-order/{workOrderId}`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.InspectionsController`
* **Método Java:** `public ResponseEntity<InspectionChecklistResource> getInspectionByWorkOrderId(@PathVariable UUID workOrderId)`
* **Ruta Canónica:** `GET /api/v1/operations/inspections/by-work-order/{workOrderId}`
* **Propósito Funcional:** Recupera el checklist de inspección pericial de recepción 360° vinculado a una orden de trabajo, detallando el estado integral de la carrocería, neumáticos, frenos, batería y accesorios físicos comprobados.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_RECEPTIONIST`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:inspections:read')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Accept` | `String` | No | application/json por defecto. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `workOrderId` | `UUID` | Sí | Identificador único de la orden de trabajo. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

No requiere cuerpo de petición (petición sin contenido o parámetros en URL).

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.InspectionChecklistResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador técnico del checklist de inspección. |
| `workOrderId` | `UUID` | Identificador de la orden de trabajo vinculada. |
| `tenantId` | `UUID` | Identificador del taller titular. |
| `inspectorId` | `UUID` | Identificador del usuario que ejecutó la inspección. |
| `inspectorName` | `String` | Nombre completo del inspector receptor. |
| `exteriorCondition` | `String` | Evaluación pericial del estado exterior de carrocería y pintura. |
| `interiorCondition` | `String` | Evaluación del estado del habitáculo, tapicería y tablero. |
| `tireTreadDepthMm` | `Double` | Profundidad mínima promedio del dibujo de neumáticos en milímetros. |
| `brakePadsCondition` | `String` | Diagnóstico visual preliminar de pastillas de freno. |
| `batteryVoltage` | `Double` | Tensión eléctrica comprobada en bornes de la batería en voltios. |
| `fuelLevelPercent` | `Integer` | Porcentaje comprobado de combustible en tanque. |
| `spareTirePresent` | `Boolean` | Indica presencia de rueda de auxilio en maletero. |
| `jackAndToolsPresent` | `Boolean` | Indica presencia de gata mecánica y estuche de herramientas. |
| `obd2ScanStatus` | `String` | Estado de escaneo computarizado (NOT_PERFORMED, CLEAN, DTCS_FOUND). |
| `detectedDtcCodes` | `List<String>` | Lista de códigos de falla registrados en centralita si existen. |
| `inspectionNotes` | `String` | Observaciones generales del peritaje de recepción. |
| `photos` | `List<InspectionPhotoResource>` | Colección de fotografías probatorias capturadas en recepción. |
| `inspectedAt` | `Instant` | Marca temporal del peritaje en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "e3b0c442-98fc-1c14-9afb-4c8996fb9242",
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "inspectorId": "4e1a2b3c-5d6e-7f8a-9b0c-1d2e3f4a5b6c",
  "inspectorName": "Marcos Rivas Quintana",
  "exteriorCondition": "Rayón leve de 15 cm en guardabarro posterior derecho. Sin abolladuras estructurales.",
  "interiorCondition": "Tapicería limpia. Tablero sin testigos de advertencia encendidos al ralentí.",
  "tireTreadDepthMm": 4.5,
  "brakePadsCondition": "Pastillas delanteras al 20% de vida útil remanente. Traseras al 60%.",
  "batteryVoltage": 12.6,
  "fuelLevelPercent": 65,
  "spareTirePresent": true,
  "jackAndToolsPresent": true,
  "obd2ScanStatus": "DTCS_FOUND",
  "detectedDtcCodes": [
    "P0300",
    "C1201"
  ],
  "inspectionNotes": "Cliente autoriza diagnóstico electrónico profundo.",
  "photos": [
    {
      "photoId": "a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6e",
      "inspectionId": "e3b0c442-98fc-1c14-9afb-4c8996fb9242",
      "photoUrl": "https://storage.googleapis.com/atelier-evidence/tenants/550e8400/insp-e3b0/right-fender.jpg",
      "caption": "Evidencia de raspón superficial en guardabarro derecho",
      "viewType": "DAMAGE_DETAIL",
      "fileSizeBytes": 2048500,
      "mimeType": "image/jpeg",
      "uploadedAt": "2026-10-01T08:35:10Z"
    }
  ],
  "inspectedAt": "2026-10-01T08:35:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `INSPECTION_NOT_FOUND` | `InspectionNotFoundException` | No se ha registrado un checklist de inspección para la orden de trabajo provista. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/inspection-not-found",
  "title": "Checklist de Inspección No Encontrado",
  "status": 404,
  "detail": "No existe un checklist pericial para la orden de trabajo 7b8e5c12-3f84-4a21-9d10-8b45f1e29001.",
  "instance": "/api/v1/operations/inspections/by-work-order/7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "code": "INSPECTION_NOT_FOUND",
  "timestamp": "2026-10-01T08:36:00Z"
}
```

---

### 4.8. [POST] `/api/v1/operations/inspections`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.InspectionsController`
* **Método Java:** `public ResponseEntity<InspectionChecklistResource> createInspection(@Valid @RequestBody CreateInspectionChecklistResource resource, UriComponentsBuilder ucb)`
* **Ruta Canónica:** `POST /api/v1/operations/inspections`
* **Propósito Funcional:** Registra formalmente el checklist pericial de recepción inicial e inventario de accesorios físicos del vehículo, salvaguardando la responsabilidad civil del taller ante preexistencias.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_RECEPTIONIST`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:inspections:create')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Content-Type` | `String` | Sí | application/json para el cuerpo del mensaje. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):** No aplica.

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.CreateInspectionChecklistResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `workOrderId` | `UUID` | Sí | @NotNull | Identificador de la orden de trabajo receptora. |
| `inspectorId` | `UUID` | Sí | @NotNull | Identificador del personal que ejecuta el checklist. |
| `exteriorCondition` | `String` | Sí | @NotBlank, @Size(max = 500) | Descripción detallada del estado exterior del vehículo. |
| `interiorCondition` | `String` | Sí | @NotBlank, @Size(max = 500) | Descripción del estado de la cabina y accesorios. |
| `tireTreadDepthMm` | `Double` | Sí | @NotNull, @Min(0) | Profundidad media de la banda de rodadura en mm. |
| `brakePadsCondition` | `String` | Sí | @NotBlank, @Size(max = 255) | Apreciación visual de pastillas y discos. |
| `batteryVoltage` | `Double` | Sí | @NotNull, @Min(0) | Voltaje registrado con voltímetro o escáner. |
| `fuelLevelPercent` | `Integer` | Sí | @NotNull, @Min(0), @Max(100) | Nivel de combustible comprobado. |
| `spareTirePresent` | `Boolean` | Sí | @NotNull | Presencia de rueda de repuesto. |
| `jackAndToolsPresent` | `Boolean` | Sí | @NotNull | Presencia de gata y llave de ruedas. |
| `obd2ScanStatus` | `String` | Sí | @NotBlank, Enum(NOT_PERFORMED, CLEAN, DTCS_FOUND) | Resultado del diagnóstico computarizado inicial. |
| `detectedDtcCodes` | `List<String>` | No | Opcional | Colección de códigos de falla alfanuméricos leídos por escáner. |
| `inspectionNotes` | `String` | No | @Size(max = 1000) | Notas adicionales del peritaje de ingreso. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "inspectorId": "4e1a2b3c-5d6e-7f8a-9b0c-1d2e3f4a5b6c",
  "exteriorCondition": "Rayón leve de 15 cm en guardabarro posterior derecho. Sin abolladuras estructurales.",
  "interiorCondition": "Tapicería limpia. Tablero sin testigos de advertencia encendidos al ralentí.",
  "tireTreadDepthMm": 4.5,
  "brakePadsCondition": "Pastillas delanteras al 20% de vida útil remanente. Traseras al 60%.",
  "batteryVoltage": 12.6,
  "fuelLevelPercent": 65,
  "spareTirePresent": true,
  "jackAndToolsPresent": true,
  "obd2ScanStatus": "DTCS_FOUND",
  "detectedDtcCodes": [
    "P0300",
    "C1201"
  ],
  "inspectionNotes": "Cliente autoriza diagnóstico electrónico profundo."
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `201 Created`
* **Cabecera de Ubicación (*Location Header*):** `/api/v1/operations/inspections/e3b0c442-98fc-1c14-9afb-4c8996fb9242`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.InspectionChecklistResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador técnico del checklist de inspección. |
| `workOrderId` | `UUID` | Identificador de la orden asociada. |
| `tenantId` | `UUID` | Identificador del taller titular. |
| `exteriorCondition` | `String` | Evaluación exterior registrada. |
| `interiorCondition` | `String` | Evaluación interior registrada. |
| `tireTreadDepthMm` | `Double` | Medición de neumáticos en mm. |
| `batteryVoltage` | `Double` | Tensión de batería en voltios. |
| `obd2ScanStatus` | `String` | Resultado del escaneo de códigos. |
| `inspectedAt` | `Instant` | Marca temporal de registro en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "e3b0c442-98fc-1c14-9afb-4c8996fb9242",
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "inspectorId": "4e1a2b3c-5d6e-7f8a-9b0c-1d2e3f4a5b6c",
  "inspectorName": "Marcos Rivas Quintana",
  "exteriorCondition": "Rayón leve de 15 cm en guardabarro posterior derecho.",
  "interiorCondition": "Tapicería limpia. Tablero sin anomalías.",
  "tireTreadDepthMm": 4.5,
  "brakePadsCondition": "Pastillas delanteras al 20%.",
  "batteryVoltage": 12.6,
  "fuelLevelPercent": 65,
  "spareTirePresent": true,
  "jackAndToolsPresent": true,
  "obd2ScanStatus": "DTCS_FOUND",
  "detectedDtcCodes": [
    "P0300",
    "C1201"
  ],
  "inspectionNotes": "Cliente autoriza diagnóstico electrónico profundo.",
  "photos": [],
  "inspectedAt": "2026-10-01T08:35:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 400 | `INVALID_INSPECTION_VALUES` | `IllegalArgumentException` | Valores de batería o neumáticos negativos o incompatibles. |
| 404 | `WORK_ORDER_NOT_FOUND` | `WorkOrderNotFoundException` | No existe la orden de trabajo para asociar la inspección. |
| 409 | `INSPECTION_ALREADY_EXISTS_FOR_WORK_ORDER` | `IllegalStateException` | Ya existe un checklist de recepción formal registrado para esta orden. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/inspection-already-exists",
  "title": "Checklist Preexistente",
  "status": 409,
  "detail": "La orden de trabajo 7b8e5c12-3f84-4a21-9d10-8b45f1e29001 ya cuenta con un checklist registrado.",
  "instance": "/api/v1/operations/inspections",
  "code": "INSPECTION_ALREADY_EXISTS_FOR_WORK_ORDER",
  "timestamp": "2026-10-01T08:35:01Z"
}
```

---

### 4.9. [PUT] `/api/v1/operations/inspections/{id}`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.InspectionsController`
* **Método Java:** `public ResponseEntity<InspectionChecklistResource> updateInspection(@PathVariable UUID id, @Valid @RequestBody UpdateInspectionChecklistResource resource)`
* **Ruta Canónica:** `PUT /api/v1/operations/inspections/{id}`
* **Propósito Funcional:** Actualiza los hallazgos periciales y mediciones del checklist de inspección durante la fase diagnóstica preliminar antes de la aprobación de presupuesto.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_SERVICE_ADVISOR`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:inspections:update')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Content-Type` | `String` | Sí | application/json para el cuerpo del mensaje. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador único del checklist de inspección a actualizar. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.UpdateInspectionChecklistResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `exteriorCondition` | `String` | No | @Size(max = 500) | Anotaciones adicionales de carrocería. |
| `interiorCondition` | `String` | No | @Size(max = 500) | Anotaciones adicionales de cabina. |
| `tireTreadDepthMm` | `Double` | No | @Min(0) | Ajuste de profundidad de dibujo. |
| `brakePadsCondition` | `String` | No | @Size(max = 255) | Ajuste de estado de frenos. |
| `batteryVoltage` | `Double` | No | @Min(0) | Medición refinada de tensión de batería. |
| `spareTirePresent` | `Boolean` | No | Opcional | Estado verificado de rueda de repuesto. |
| `jackAndToolsPresent` | `Boolean` | No | Opcional | Estado verificado de herramientas. |
| `obd2ScanStatus` | `String` | No | Enum(NOT_PERFORMED, CLEAN, DTCS_FOUND) | Estado actualizado del escaneo. |
| `detectedDtcCodes` | `List<String>` | No | Opcional | Códigos DTC complementarios identificados. |
| `inspectionNotes` | `String` | No | @Size(max = 1000) | Notas periciales complementarias. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "exteriorCondition": "Rayón leve en guardabarro posterior derecho y fisura en mica de faro neblinero izquierdo.",
  "brakePadsCondition": "Discos delanteros con alabeo visible. Pastillas desgastadas de forma irregular.",
  "inspectionNotes": "Se requiere desmontaje de ruedas para verificación micrométrica de tolerancia de disco."
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.InspectionChecklistResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador técnico del checklist. |
| `workOrderId` | `UUID` | Identificador de la orden asociada. |
| `exteriorCondition` | `String` | Estado exterior actualizado. |
| `brakePadsCondition` | `String` | Estado de frenos actualizado. |
| `inspectionNotes` | `String` | Notas actualizadas. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "e3b0c442-98fc-1c14-9afb-4c8996fb9242",
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "inspectorId": "4e1a2b3c-5d6e-7f8a-9b0c-1d2e3f4a5b6c",
  "inspectorName": "Marcos Rivas Quintana",
  "exteriorCondition": "Rayón leve en guardabarro posterior derecho y fisura en mica de faro neblinero izquierdo.",
  "interiorCondition": "Tapicería limpia. Tablero sin advertencias.",
  "tireTreadDepthMm": 4.5,
  "brakePadsCondition": "Discos delanteros con alabeo visible. Pastillas desgastadas de forma irregular.",
  "batteryVoltage": 12.6,
  "fuelLevelPercent": 65,
  "spareTirePresent": true,
  "jackAndToolsPresent": true,
  "obd2ScanStatus": "DTCS_FOUND",
  "detectedDtcCodes": [
    "P0300",
    "C1201"
  ],
  "inspectionNotes": "Se requiere desmontaje de ruedas para verificación micrométrica de tolerancia de disco.",
  "photos": [],
  "inspectedAt": "2026-10-01T08:35:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `INSPECTION_NOT_FOUND` | `InspectionNotFoundException` | No existe el checklist de inspección con el identificador provisto. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/inspection-not-found",
  "title": "Inspección No Encontrada",
  "status": 404,
  "detail": "No existe el checklist de inspección e3b0c442-98fc-1c14-9afb-4c8996fb9242.",
  "instance": "/api/v1/operations/inspections/e3b0c442-98fc-1c14-9afb-4c8996fb9242",
  "code": "INSPECTION_NOT_FOUND",
  "timestamp": "2026-10-01T08:50:00Z"
}
```

---

### 4.10. [POST] `/api/v1/operations/inspections/{id}/photos`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.InspectionsController`
* **Método Java:** `public ResponseEntity<InspectionPhotoResource> uploadPhoto(@PathVariable UUID id, @Valid @RequestBody UploadInspectionPhotoResource resource, UriComponentsBuilder ucb)`
* **Ruta Canónica:** `POST /api/v1/operations/inspections/{id}/photos`
* **Propósito Funcional:** Adjunta metadatos de evidencia gráfica probatoria de la recepción vehicular cargada mediante arquitectura Direct-to-Cloud hacia almacenamiento perimetral seguro.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_RECEPTIONIST`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:inspections:upload_photos')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Content-Type` | `String` | Sí | application/json para el cuerpo del mensaje. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador único del checklist de inspección receptor. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.UploadInspectionPhotoResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `photoUrl` | `String` | Sí | @NotBlank, @URL | Localizador HTTPS seguro de la imagen en Cloud Storage. |
| `caption` | `String` | Sí | @NotBlank, @Size(max = 255) | Leyenda descriptiva del plano o componente inspeccionado. |
| `viewType` | `String` | Sí | Enum(FRONT, REAR, LEFT_SIDE, RIGHT_SIDE, INTERIOR, DASHBOARD, ENGINE_BAY, UNDERCARRIAGE, DAMAGE_DETAIL) | Tipología pericial de la perspectiva capturada. |
| `fileSizeBytes` | `Long` | Sí | @NotNull, @Min(1) | Tamaño del archivo de imagen en bytes. |
| `mimeType` | `String` | Sí | @NotBlank, @Pattern(regexp = "image/(jpeg|png|webp)") | Tipo de medio MIME soportado. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "photoUrl": "https://storage.googleapis.com/atelier-evidence/tenants/550e8400/insp-e3b0/right-fender.jpg",
  "caption": "Evidencia de raspón superficial en guardabarro derecho",
  "viewType": "DAMAGE_DETAIL",
  "fileSizeBytes": 2048500,
  "mimeType": "image/jpeg"
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `201 Created`
* **Cabecera de Ubicación (*Location Header*):** `/api/v1/operations/inspections/e3b0c442-98fc-1c14-9afb-4c8996fb9242/photos/a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6e`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.InspectionPhotoResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `photoId` | `UUID` | Identificador técnico de la fotografía probatoria. |
| `inspectionId` | `UUID` | Identificador del checklist receptor. |
| `photoUrl` | `String` | URL pública firmada de visualización segura. |
| `caption` | `String` | Leyenda descriptiva registrada. |
| `viewType` | `String` | Perspectiva pericial categorizada. |
| `fileSizeBytes` | `Long` | Peso del archivo en bytes. |
| `mimeType` | `String` | Tipo de medio MIME de la imagen. |
| `uploadedAt` | `Instant` | Marca temporal de carga en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "photoId": "a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6e",
  "inspectionId": "e3b0c442-98fc-1c14-9afb-4c8996fb9242",
  "photoUrl": "https://storage.googleapis.com/atelier-evidence/tenants/550e8400/insp-e3b0/right-fender.jpg",
  "caption": "Evidencia de raspón superficial en guardabarro derecho",
  "viewType": "DAMAGE_DETAIL",
  "fileSizeBytes": 2048500,
  "mimeType": "image/jpeg",
  "uploadedAt": "2026-10-01T08:35:10Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 400 | `INVALID_STORAGE_URL` | `InvalidStorageUrlException` | La URL provista no satisface el protocolo HTTPS o no proviene de almacenamiento autorizado. |
| 404 | `INSPECTION_NOT_FOUND` | `InspectionNotFoundException` | No existe el checklist de inspección especificado. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/invalid-storage-url",
  "title": "URL de Almacenamiento Inválida",
  "status": 400,
  "detail": "La URL de fotografía provista no proviene del dominio seguro de Cloud Storage del taller.",
  "instance": "/api/v1/operations/inspections/e3b0c442-98fc-1c14-9afb-4c8996fb9242/photos",
  "code": "INVALID_STORAGE_URL",
  "timestamp": "2026-10-01T08:35:11Z"
}
```

---

### 4.11. [DELETE] `/api/v1/operations/inspections/{id}/photos/{photoId}`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.InspectionsController`
* **Método Java:** `public ResponseEntity<Void> deletePhoto(@PathVariable UUID id, @PathVariable UUID photoId)`
* **Ruta Canónica:** `DELETE /api/v1/operations/inspections/{id}/photos/{photoId}`
* **Propósito Funcional:** Elimina una fotografía pericial errónea o duplicada del checklist de recepción, revocando su persistencia en metadatos y programando su purga en almacenamiento.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_SERVICE_ADVISOR`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:inspections:delete_photos')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Accept` | `String` | No | application/json por defecto. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador único del checklist de inspección. |
| `photoId` | `UUID` | Sí | Identificador único de la fotografía a eliminar. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

No requiere cuerpo de petición (petición sin contenido o parámetros en URL).

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `204 No Content`
* **Java Record DTO:** `void`

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
/* Cuerpo vacío (HTTP 204 No Content) */
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `PHOTO_NOT_FOUND` | `PhotoNotFoundException` | La fotografía solicitada para eliminación no existe en la inspección. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/photo-not-found",
  "title": "Fotografía No Encontrada",
  "status": 404,
  "detail": "No se localiza la fotografía probatoria con ID a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6e.",
  "instance": "/api/v1/operations/inspections/e3b0c442-98fc-1c14-9afb-4c8996fb9242/photos/a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6e",
  "code": "PHOTO_NOT_FOUND",
  "timestamp": "2026-10-01T08:40:00Z"
}
```

---

### 4.12. [GET] `/api/v1/operations/quotations`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.QuotationsController`
* **Método Java:** `public ResponseEntity<Page<QuotationSummaryResource>> getQuotations(Pageable pageable, @RequestParam(required = false) UUID branchId, @RequestParam(required = false) UUID workOrderId, @RequestParam(required = false) UUID customerId, @RequestParam(required = false) String status)`
* **Ruta Canónica:** `GET /api/v1/operations/quotations`
* **Propósito Funcional:** Recupera el listado paginado y filtrado de cotizaciones y proformas comerciales de mantenimiento del taller, permitiendo auditar presupuestos en borrador, emitidos, aprobados y desestimados.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_SERVICE_ADVISOR`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:quotations:read')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Accept` | `String` | No | application/json por defecto. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):** No aplica.

**Parámetros de Consulta (Query Parameters):**

| Parámetro | Tipo | Requerido | Valor por Defecto | Descripción |
| :--- | :--- | :---: | :---: | :--- |
| `branchId` | `UUID` | No | `null` | Filtro por sede operativa del taller. |
| `workOrderId` | `UUID` | No | `null` | Filtro por orden de trabajo vinculada. |
| `customerId` | `UUID` | No | `null` | Filtro por cliente titular. |
| `status` | `String` | No | `null` | Filtro por estado de cotización (DRAFT, SENT, APPROVED, REJECTED, EXPIRED). |
| `page` | `Integer` | No | `0` | Índice de la página base cero. |
| `size` | `Integer` | No | `20` | Elementos por página. |
| `sort` | `String` | No | `createdAt,desc` | Criterio de ordenamiento. |

#### Cuerpo de Petición (Request)

No requiere cuerpo de petición (petición sin contenido o parámetros en URL).

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `org.springframework.data.domain.Page<com.andeva.atelier.platform.operations.interfaces.rest.resources.QuotationSummaryResource>`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `content[].id` | `UUID` | Identificador único de la cotización. |
| `content[].quotationNumber` | `String` | Código correlativo comercial (ej. COT-2026-00128). |
| `content[].workOrderId` | `UUID` | Identificador de la orden de trabajo. |
| `content[].workOrderNumber` | `String` | Correlativo de la orden asociada. |
| `content[].customerId` | `UUID` | Identificador del cliente titular. |
| `content[].customerFullName` | `String` | Nombre completo o razón social del cliente. |
| `content[].status` | `String` | Estado comercial de la proforma. |
| `content[].subtotalLabor` | `BigDecimal` | Subtotal acumulado de servicios de mano de obra. |
| `content[].subtotalParts` | `BigDecimal` | Subtotal acumulado de repuestos e insumos. |
| `content[].taxAmount` | `BigDecimal` | Impuesto General a las Ventas calculado (IGV 18%). |
| `content[].grandTotal` | `BigDecimal` | Importe total bruto presupuestado. |
| `content[].currency` | `String` | Moneda de cotización (PEN). |
| `content[].validUntil` | `LocalDate` | Fecha límite de vigencia de la oferta comercial. |
| `content[].createdAt` | `Instant` | Marca temporal de creación en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "content": [
    {
      "id": "c4d5e6f7-a8b9-0c1d-2e3f-4a5b6c7d8e9f",
      "quotationNumber": "COT-2026-00128",
      "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
      "workOrderNumber": "OT-2026-00451",
      "customerId": "8f3b2a1c-4d5e-6f7a-8b9c-0d1e2f3a4b5c",
      "customerFullName": "Carlos Alberto Mendoza Morales",
      "status": "APPROVED",
      "subtotalLabor": 280.00,
      "subtotalParts": 450.50,
      "taxAmount": 131.49,
      "grandTotal": 861.99,
      "currency": "PEN",
      "validUntil": "2026-10-15",
      "createdAt": "2026-10-01T09:00:00Z"
    }
  ],
  "pageable": {
    "pageNumber": 0,
    "pageSize": 20
  },
  "totalElements": 1,
  "totalPages": 1,
  "last": true,
  "size": 20,
  "number": 0,
  "first": true,
  "empty": false
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 400 | `INVALID_QUERY_PARAMETER` | `IllegalArgumentException` | Parámetro de estado o fecha con formato no reconocible. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/invalid-query-parameter",
  "title": "Parámetro Inválido",
  "status": 400,
  "detail": "El filtro de estado 'DESCONOCIDO' no es válido.",
  "instance": "/api/v1/operations/quotations",
  "code": "INVALID_QUERY_PARAMETER",
  "timestamp": "2026-10-01T09:01:00Z"
}
```

---

### 4.13. [POST] `/api/v1/operations/quotations`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.QuotationsController`
* **Método Java:** `public ResponseEntity<QuotationResource> createQuotation(@Valid @RequestBody CreateQuotationResource resource, UriComponentsBuilder ucb)`
* **Ruta Canónica:** `POST /api/v1/operations/quotations`
* **Propósito Funcional:** Elabora una nueva cotización comercial formal para la orden de trabajo, inicializándola en estado borrador con plazo de vigencia predeterminado para incorporación gradual de partidas.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_SERVICE_ADVISOR`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:quotations:create')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Content-Type` | `String` | Sí | application/json para el cuerpo del mensaje. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):** No aplica.

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.CreateQuotationResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `workOrderId` | `UUID` | Sí | @NotNull | Identificador de la orden de trabajo a presupuestar. |
| `validityDays` | `Integer` | Sí | @NotNull, @Min(1), @Max(60) | Días calendario de vigencia de la oferta comercial. |
| `commercialNotes` | `String` | No | @Size(max = 1000) | Términos comerciales, facilidades de pago o advertencias técnicas. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "validityDays": 15,
  "commercialNotes": "Presupuesto incluye repuestos genuinos certificados y garantía de 6 meses en mano de obra."
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `201 Created`
* **Cabecera de Ubicación (*Location Header*):** `/api/v1/operations/quotations/c4d5e6f7-a8b9-0c1d-2e3f-4a5b6c7d8e9f`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.QuotationResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador técnico de la cotización. |
| `quotationNumber` | `String` | Correlativo comercial generado. |
| `workOrderId` | `UUID` | Identificador de la orden asociada. |
| `tenantId` | `UUID` | Identificador del taller titular. |
| `customerId` | `UUID` | Identificador del cliente titular. |
| `status` | `String` | Estado inicial (DRAFT). |
| `validityDays` | `Integer` | Días de vigencia pactados. |
| `validUntil` | `LocalDate` | Fecha límite calculada. |
| `subtotalLabor` | `BigDecimal` | Subtotal de servicios (inicial 0.00). |
| `subtotalParts` | `BigDecimal` | Subtotal de repuestos (inicial 0.00). |
| `taxRate` | `BigDecimal` | Tasa impositiva aplicada (0.18 para IGV). |
| `taxAmount` | `BigDecimal` | Monto de impuesto calculado. |
| `grandTotal` | `BigDecimal` | Importe total presupuestado. |
| `currency` | `String` | Moneda oficial (PEN). |
| `commercialNotes` | `String` | Términos comerciales registrados. |
| `items` | `List<QuotationItemResource>` | Partidas detalladas de mano de obra y repuestos. |
| `createdAt` | `Instant` | Marca temporal de creación en UTC. |
| `updatedAt` | `Instant` | Marca temporal de última modificación en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "c4d5e6f7-a8b9-0c1d-2e3f-4a5b6c7d8e9f",
  "quotationNumber": "COT-2026-00128",
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "customerId": "8f3b2a1c-4d5e-6f7a-8b9c-0d1e2f3a4b5c",
  "status": "DRAFT",
  "validityDays": 15,
  "validUntil": "2026-10-16",
  "subtotalLabor": 0.00,
  "subtotalParts": 0.00,
  "taxRate": 0.18,
  "taxAmount": 0.00,
  "grandTotal": 0.00,
  "currency": "PEN",
  "commercialNotes": "Presupuesto incluye repuestos genuinos certificados y garantía de 6 meses en mano de obra.",
  "items": [],
  "createdAt": "2026-10-01T09:00:00Z",
  "updatedAt": "2026-10-01T09:00:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `WORK_ORDER_NOT_FOUND` | `WorkOrderNotFoundException` | No existe la orden de trabajo referenciada. |
| 409 | `QUOTATION_ALREADY_EXISTS_FOR_WORK_ORDER` | `IllegalStateException` | La orden de trabajo ya cuenta con una cotización activa en proceso. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/quotation-already-exists",
  "title": "Cotización Ya Existente",
  "status": 409,
  "detail": "La orden 7b8e5c12-3f84-4a21-9d10-8b45f1e29001 ya posee una cotización activa.",
  "instance": "/api/v1/operations/quotations",
  "code": "QUOTATION_ALREADY_EXISTS_FOR_WORK_ORDER",
  "timestamp": "2026-10-01T09:00:01Z"
}
```

---

### 4.14. [GET] `/api/v1/operations/quotations/{id}`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.QuotationsController`
* **Método Java:** `public ResponseEntity<QuotationResource> getQuotationById(@PathVariable UUID id)`
* **Ruta Canónica:** `GET /api/v1/operations/quotations/{id}`
* **Propósito Funcional:** Obtiene el detalle analítico de una cotización específica con el desglose pormenorizado de todas sus líneas de servicio mecánico, piezas cotizadas, subtotales e impuestos.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_SERVICE_ADVISOR`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:quotations:read')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Accept` | `String` | No | application/json por defecto. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador único de la cotización comercial. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

No requiere cuerpo de petición (petición sin contenido o parámetros en URL).

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.QuotationResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador técnico de la cotización. |
| `quotationNumber` | `String` | Código correlativo de la oferta. |
| `workOrderId` | `UUID` | Identificador de la orden asociada. |
| `status` | `String` | Estado actual de la proforma. |
| `subtotalLabor` | `BigDecimal` | Suma de partidas de mano de obra. |
| `subtotalParts` | `BigDecimal` | Suma de partidas de repuestos. |
| `taxAmount` | `BigDecimal` | IGV liquidado al 18%. |
| `grandTotal` | `BigDecimal` | Monto total de la cotización. |
| `items[].id` | `UUID` | Identificador único de la línea de cotización. |
| `items[].itemType` | `String` | Tipología de partida (SERVICE o PART). |
| `items[].description` | `String` | Descripción técnica de la partida. |
| `items[].quantity` | `BigDecimal` | Cantidad de unidades u horas. |
| `items[].unitPrice` | `BigDecimal` | Precio unitario sin impuestos. |
| `items[].subtotal` | `BigDecimal` | Importe total de la línea de cotización. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "c4d5e6f7-a8b9-0c1d-2e3f-4a5b6c7d8e9f",
  "quotationNumber": "COT-2026-00128",
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "customerId": "8f3b2a1c-4d5e-6f7a-8b9c-0d1e2f3a4b5c",
  "status": "APPROVED",
  "validityDays": 15,
  "validUntil": "2026-10-16",
  "subtotalLabor": 280.00,
  "subtotalParts": 450.50,
  "taxRate": 0.18,
  "taxAmount": 131.49,
  "grandTotal": 861.99,
  "currency": "PEN",
  "commercialNotes": "Presupuesto incluye repuestos genuinos certificados y garantía de 6 meses en mano de obra.",
  "items": [
    {
      "id": "d1e2f3a4-b5c6-7a8b-9c0d-1e2f3a4b5c6f",
      "itemType": "SERVICE",
      "serviceId": "5e1a2b3c-4d5e-6f7a-8b9c-0d1e2f3a4b5c",
      "partId": null,
      "description": "Desmontaje, rectificado de discos ventilados e instalación de pastillas",
      "quantity": 2.50,
      "unitPrice": 112.00,
      "discountPercent": 0.00,
      "subtotal": 280.00
    },
    {
      "id": "e2f3a4b5-c6d7-8a9b-0c1d-2e3f4a5b6c70",
      "itemType": "PART",
      "serviceId": null,
      "partId": "6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d",
      "description": "Juego de Pastillas Cerámicas Delanteras Brembo P83024",
      "quantity": 1.00,
      "unitPrice": 450.50,
      "discountPercent": 0.00,
      "subtotal": 450.50
    }
  ],
  "createdAt": "2026-10-01T09:00:00Z",
  "updatedAt": "2026-10-01T09:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `QUOTATION_NOT_FOUND` | `QuotationNotFoundException` | No existe la cotización comercial solicitada. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/quotation-not-found",
  "title": "Cotización No Encontrada",
  "status": 404,
  "detail": "No se localiza la cotización c4d5e6f7-a8b9-0c1d-2e3f-4a5b6c7d8e9f en el taller.",
  "instance": "/api/v1/operations/quotations/c4d5e6f7-a8b9-0c1d-2e3f-4a5b6c7d8e9f",
  "code": "QUOTATION_NOT_FOUND",
  "timestamp": "2026-10-01T09:05:00Z"
}
```

---

### 4.15. [PUT] `/api/v1/operations/quotations/{id}`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.QuotationsController`
* **Método Java:** `public ResponseEntity<QuotationResource> updateQuotation(@PathVariable UUID id, @Valid @RequestBody UpdateQuotationResource resource)`
* **Ruta Canónica:** `PUT /api/v1/operations/quotations/{id}`
* **Propósito Funcional:** Actualiza las notas comerciales o vigencia temporal de una cotización mientras se encuentra en estado borrador.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_SERVICE_ADVISOR`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:quotations:update')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Content-Type` | `String` | Sí | application/json para el cuerpo del mensaje. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador de la cotización a modificar. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.UpdateQuotationResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `validityDays` | `Integer` | No | @Min(1), @Max(60) | Días de vigencia ajustados. |
| `commercialNotes` | `String` | No | @Size(max = 1000) | Condiciones comerciales actualizadas. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "validityDays": 20,
  "commercialNotes": "Se extiende vigencia por campaña promocional de frenos de primavera."
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.QuotationResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la cotización. |
| `validityDays` | `Integer` | Días de vigencia actualizados. |
| `validUntil` | `LocalDate` | Nueva fecha límite calculada. |
| `commercialNotes` | `String` | Condiciones actualizadas. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "c4d5e6f7-a8b9-0c1d-2e3f-4a5b6c7d8e9f",
  "quotationNumber": "COT-2026-00128",
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "customerId": "8f3b2a1c-4d5e-6f7a-8b9c-0d1e2f3a4b5c",
  "status": "DRAFT",
  "validityDays": 20,
  "validUntil": "2026-10-21",
  "subtotalLabor": 0.00,
  "subtotalParts": 0.00,
  "taxRate": 0.18,
  "taxAmount": 0.00,
  "grandTotal": 0.00,
  "currency": "PEN",
  "commercialNotes": "Se extiende vigencia por campaña promocional de frenos de primavera.",
  "items": [],
  "createdAt": "2026-10-01T09:00:00Z",
  "updatedAt": "2026-10-01T09:15:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `QUOTATION_NOT_FOUND` | `QuotationNotFoundException` | No existe la cotización especificada. |
| 422 | `QUOTATION_NOT_IN_DRAFT_STATUS` | `IllegalStateException` | Solo se pueden actualizar cotizaciones en estado borrador (DRAFT). |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/quotation-not-draft",
  "title": "Cotización No Editable",
  "status": 422,
  "detail": "La cotización ya fue emitida formalmente o aprobada, por lo que es inmutable.",
  "instance": "/api/v1/operations/quotations/c4d5e6f7-a8b9-0c1d-2e3f-4a5b6c7d8e9f",
  "code": "QUOTATION_NOT_IN_DRAFT_STATUS",
  "timestamp": "2026-10-01T09:15:01Z"
}
```

---

### 4.16. [POST] `/api/v1/operations/quotations/{id}/items`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.QuotationsController`
* **Método Java:** `public ResponseEntity<QuotationResource> addQuotationItem(@PathVariable UUID id, @Valid @RequestBody AddQuotationItemResource resource)`
* **Ruta Canónica:** `POST /api/v1/operations/quotations/{id}/items`
* **Propósito Funcional:** Incorpora una nueva partida de servicio de mano de obra o de repuesto al presupuesto comercial, recalculando automáticamente subtotales, descuentos e impuesto IGV.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_SERVICE_ADVISOR`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:quotations:update')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Content-Type` | `String` | Sí | application/json para el cuerpo del mensaje. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador de la cotización receptora de la partida. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.AddQuotationItemResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `itemType` | `String` | Sí | Enum(SERVICE, PART) | Tipo de concepto cotizado. |
| `serviceId` | `UUID` | Condicional | Obligatorio si itemType es SERVICE | Identificador del servicio de catálogo si aplica. |
| `partId` | `UUID` | Condicional | Obligatorio si itemType es PART | Identificador del repuesto de catálogo si aplica. |
| `description` | `String` | Sí | @NotBlank, @Size(max = 255) | Descripción técnica visible en la proforma. |
| `quantity` | `BigDecimal` | Sí | @NotNull, @DecimalMin("0.01") | Cantidad de unidades o fracciones horarias. |
| `unitPrice` | `BigDecimal` | Sí | @NotNull, @DecimalMin("0.00") | Precio unitario pactado. |
| `discountPercent` | `BigDecimal` | No | @DecimalMin("0.00"), @DecimalMax("100.00") | Porcentaje de descuento comercial aplicado a la línea. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "itemType": "PART",
  "serviceId": null,
  "partId": "6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d",
  "description": "Juego de Pastillas Cerámicas Delanteras Brembo P83024",
  "quantity": 1.00,
  "unitPrice": 450.50,
  "discountPercent": 0.00
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `201 Created`
* **Cabecera de Ubicación (*Location Header*):** `/api/v1/operations/quotations/c4d5e6f7-a8b9-0c1d-2e3f-4a5b6c7d8e9f`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.QuotationResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la cotización. |
| `subtotalParts` | `BigDecimal` | Subtotal de repuestos recalculado. |
| `taxAmount` | `BigDecimal` | IGV recalculado. |
| `grandTotal` | `BigDecimal` | Total consolidado recalculado. |
| `items` | `List<QuotationItemResource>` | Lista de partidas incluyendo la nueva incorporación. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "c4d5e6f7-a8b9-0c1d-2e3f-4a5b6c7d8e9f",
  "quotationNumber": "COT-2026-00128",
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "status": "DRAFT",
  "subtotalLabor": 280.00,
  "subtotalParts": 450.50,
  "taxRate": 0.18,
  "taxAmount": 131.49,
  "grandTotal": 861.99,
  "currency": "PEN",
  "items": [
    {
      "id": "e2f3a4b5-c6d7-8a9b-0c1d-2e3f4a5b6c70",
      "itemType": "PART",
      "description": "Juego de Pastillas Cerámicas Delanteras Brembo P83024",
      "quantity": 1.00,
      "unitPrice": 450.50,
      "discountPercent": 0.00,
      "subtotal": 450.50
    }
  ],
  "updatedAt": "2026-10-01T09:20:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 400 | `INVALID_QUOTATION_ITEM_DATA` | `IllegalArgumentException` | Datos incompatibles entre el tipo de partida y los identificadores provistos. |
| 404 | `QUOTATION_NOT_FOUND` | `QuotationNotFoundException` | No existe la cotización especificada. |
| 422 | `QUOTATION_NOT_IN_DRAFT_STATUS` | `IllegalStateException` | No se pueden añadir partidas a cotizaciones aprobadas o cerradas. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/invalid-quotation-item",
  "title": "Partida de Cotización Inválida",
  "status": 400,
  "detail": "Debe especificar un partId válido cuando itemType es PART.",
  "instance": "/api/v1/operations/quotations/c4d5e6f7-a8b9-0c1d-2e3f-4a5b6c7d8e9f/items",
  "code": "INVALID_QUOTATION_ITEM_DATA",
  "timestamp": "2026-10-01T09:20:01Z"
}
```

---

### 4.17. [DELETE] `/api/v1/operations/quotations/{id}/items/{itemId}`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.QuotationsController`
* **Método Java:** `public ResponseEntity<QuotationResource> removeQuotationItem(@PathVariable UUID id, @PathVariable UUID itemId)`
* **Ruta Canónica:** `DELETE /api/v1/operations/quotations/{id}/items/{itemId}`
* **Propósito Funcional:** Elimina una partida del presupuesto comercial y recalcula automáticamente los totales del presupuesto en tiempo real.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_SERVICE_ADVISOR`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:quotations:update')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Accept` | `String` | No | application/json por defecto. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador de la cotización. |
| `itemId` | `UUID` | Sí | Identificador de la partida a eliminar. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

No requiere cuerpo de petición (petición sin contenido o parámetros en URL).

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.QuotationResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la cotización. |
| `grandTotal` | `BigDecimal` | Total recalculado tras la supresión de la partida. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "c4d5e6f7-a8b9-0c1d-2e3f-4a5b6c7d8e9f",
  "quotationNumber": "COT-2026-00128",
  "status": "DRAFT",
  "subtotalLabor": 280.00,
  "subtotalParts": 0.00,
  "taxAmount": 50.40,
  "grandTotal": 330.40,
  "currency": "PEN",
  "items": [],
  "updatedAt": "2026-10-01T09:25:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `QUOTATION_ITEM_NOT_FOUND` | `EntityNotFoundException` | No existe la partida especificada en la cotización. |
| 422 | `QUOTATION_NOT_IN_DRAFT_STATUS` | `IllegalStateException` | No se pueden eliminar partidas de cotizaciones ya emitidas o aprobadas. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/quotation-item-not-found",
  "title": "Partida No Encontrada",
  "status": 404,
  "detail": "La partida itemId e2f3a4b5-c6d7-8a9b-0c1d-2e3f4a5b6c70 no existe en la cotización.",
  "instance": "/api/v1/operations/quotations/c4d5e6f7-a8b9-0c1d-2e3f-4a5b6c7d8e9f/items/e2f3a4b5-c6d7-8a9b-0c1d-2e3f4a5b6c70",
  "code": "QUOTATION_ITEM_NOT_FOUND",
  "timestamp": "2026-10-01T09:25:01Z"
}
```

---

### 4.18. [POST] `/api/v1/operations/quotations/{id}/send-pdf`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.QuotationsController`
* **Método Java:** `public ResponseEntity<MessageResource> sendQuotationPdf(@PathVariable UUID id)`
* **Ruta Canónica:** `POST /api/v1/operations/quotations/{id}/send-pdf`
* **Propósito Funcional:** Compila el documento PDF formal de la cotización comercial con logotipo del taller y desglose legal, despachándolo por correo electrónico y mensajería digital al cliente.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_SERVICE_ADVISOR`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:quotations:send')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Accept` | `String` | No | application/json por defecto. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador de la cotización a emitir. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

No requiere cuerpo de petición (petición sin contenido o parámetros en URL).

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.shared.interfaces.rest.resources.MessageResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `message` | `String` | Mensaje de confirmación del despacho. |
| `dispatchedAt` | `Instant` | Marca temporal de envío en UTC. |
| `recipientEmail` | `String` | Buzón de correo electrónico destinatario. |
| `recipientPhone` | `String` | Número de teléfono para mensajería digital. |
| `pdfUrl` | `String` | URL pública firmada de consulta del documento PDF. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "message": "Cotización COT-2026-00128 generada y remitida exitosamente al cliente.",
  "dispatchedAt": "2026-10-01T09:30:00Z",
  "recipientEmail": "carlos.mendoza@gmail.com",
  "recipientPhone": "+51987654321",
  "pdfUrl": "https://storage.googleapis.com/atelier-docs/tenants/550e8400/quotations/COT-2026-00128.pdf"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `QUOTATION_NOT_FOUND` | `QuotationNotFoundException` | No existe la cotización especificada. |
| 422 | `EMPTY_QUOTATION_CANNOT_BE_SENT` | `IllegalStateException` | No es posible remitir una cotización que carece de partidas registradas. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/empty-quotation",
  "title": "Cotización Vacía",
  "status": 422,
  "detail": "La cotización c4d5e6f7-a8b9-0c1d-2e3f-4a5b6c7d8e9f no contiene partidas y no puede ser enviada.",
  "instance": "/api/v1/operations/quotations/c4d5e6f7-a8b9-0c1d-2e3f-4a5b6c7d8e9f/send-pdf",
  "code": "EMPTY_QUOTATION_CANNOT_BE_SENT",
  "timestamp": "2026-10-01T09:30:01Z"
}
```

---

### 4.19. [POST] `/api/v1/operations/quotations/{id}/approve`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.QuotationsController`
* **Método Java:** `public ResponseEntity<QuotationResource> approveQuotation(@PathVariable UUID id, @Valid @RequestBody ApproveQuotationResource resource)`
* **Ruta Canónica:** `POST /api/v1/operations/quotations/{id}/approve`
* **Propósito Funcional:** Registra la aprobación formal del presupuesto por parte del cliente, activando la reserva de repuestos en bodega y autorizando el inicio de labores mecánicas en foso.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_SERVICE_ADVISOR`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:quotations:approve')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Content-Type` | `String` | Sí | application/json para el cuerpo del mensaje. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador de la cotización a aprobar. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.ApproveQuotationResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `approvalChannel` | `String` | Sí | Enum(IN_PERSON, WHATSAPP, EMAIL, PHONE) | Canal probatorio mediante el cual el cliente aprobó la cotización. |
| `approvalReference` | `String` | No | @Size(max = 255) | Referencia probatoria (ej. código de chat, ID de correo o firma). |
| `approvedByClientAt` | `Instant` | Sí | @NotNull | Marca temporal en que el cliente otorgó su consentimiento. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "approvalChannel": "WHATSAPP",
  "approvalReference": "Mensaje de texto con confirmación expresa recibido a las 09:40 AM.",
  "approvedByClientAt": "2026-10-01T09:40:00Z"
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.QuotationResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la cotización. |
| `status` | `String` | Nuevo estado comercial (APPROVED). |
| `updatedAt` | `Instant` | Marca temporal de resolución en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "c4d5e6f7-a8b9-0c1d-2e3f-4a5b6c7d8e9f",
  "quotationNumber": "COT-2026-00128",
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "status": "APPROVED",
  "subtotalLabor": 280.00,
  "subtotalParts": 450.50,
  "taxAmount": 131.49,
  "grandTotal": 861.99,
  "currency": "PEN",
  "updatedAt": "2026-10-01T09:45:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `QUOTATION_NOT_FOUND` | `QuotationNotFoundException` | No existe la cotización especificada. |
| 422 | `QUOTATION_ALREADY_RESOLVED` | `IllegalStateException` | La cotización ya fue resuelta previamente (APPROVED o REJECTED). |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/quotation-already-resolved",
  "title": "Cotización Ya Resuelta",
  "status": 422,
  "detail": "La cotización c4d5e6f7-a8b9-0c1d-2e3f-4a5b6c7d8e9f ya se encuentra en estado APPROVED.",
  "instance": "/api/v1/operations/quotations/c4d5e6f7-a8b9-0c1d-2e3f-4a5b6c7d8e9f/approve",
  "code": "QUOTATION_ALREADY_RESOLVED",
  "timestamp": "2026-10-01T09:45:01Z"
}
```

---

### 4.20. [POST] `/api/v1/operations/quotations/{id}/reject`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.QuotationsController`
* **Método Java:** `public ResponseEntity<QuotationResource> rejectQuotation(@PathVariable UUID id, @Valid @RequestBody RejectQuotationResource resource)`
* **Ruta Canónica:** `POST /api/v1/operations/quotations/{id}/reject`
* **Propósito Funcional:** Registra la desestimación formal del presupuesto por parte del cliente, archivando la propuesta comercial y liberando las reservas preliminares de repuestos.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_SERVICE_ADVISOR`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:quotations:reject')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Content-Type` | `String` | Sí | application/json para el cuerpo del mensaje. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador de la cotización a desestimar. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.RejectQuotationResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `rejectionReason` | `String` | Sí | @NotBlank, @Size(min = 5, max = 500) | Motivo justificado de la no aceptación del presupuesto. |
| `rejectedByClientAt` | `Instant` | Sí | @NotNull | Marca temporal de la negativa del cliente en UTC. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "rejectionReason": "Cliente considera elevado el costo de las pastillas cerámicas y opta por evaluar opciones alternativas.",
  "rejectedByClientAt": "2026-10-01T09:42:00Z"
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.QuotationResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la cotización. |
| `status` | `String` | Nuevo estado comercial (REJECTED). |
| `updatedAt` | `Instant` | Marca temporal de desestimación en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "c4d5e6f7-a8b9-0c1d-2e3f-4a5b6c7d8e9f",
  "quotationNumber": "COT-2026-00128",
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "status": "REJECTED",
  "subtotalLabor": 280.00,
  "subtotalParts": 450.50,
  "grandTotal": 861.99,
  "currency": "PEN",
  "updatedAt": "2026-10-01T09:45:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `QUOTATION_NOT_FOUND` | `QuotationNotFoundException` | No existe la cotización especificada. |
| 422 | `QUOTATION_ALREADY_RESOLVED` | `IllegalStateException` | La cotización ya fue resuelta previamente. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/quotation-already-resolved",
  "title": "Cotización Ya Resuelta",
  "status": 422,
  "detail": "No se puede desestimar una cotización en estado APPROVED o REJECTED.",
  "instance": "/api/v1/operations/quotations/c4d5e6f7-a8b9-0c1d-2e3f-4a5b6c7d8e9f/reject",
  "code": "QUOTATION_ALREADY_RESOLVED",
  "timestamp": "2026-10-01T09:45:01Z"
}
```

---

### 4.21. [GET] `/api/v1/operations/proposals/by-work-order/{workOrderId}`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.TaskProposalsController`
* **Método Java:** `public ResponseEntity<List<TaskProposalResource>> getProposalsByWorkOrderId(@PathVariable UUID workOrderId)`
* **Ruta Canónica:** `GET /api/v1/operations/proposals/by-work-order/{workOrderId}`
* **Propósito Funcional:** Recupera la colección de hallazgos periciales y averías ocultas descubiertas por los mecánicos durante la intervención técnica en bahía para una orden de trabajo.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_MECHANIC`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:proposals:read')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Accept` | `String` | No | application/json por defecto. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `workOrderId` | `UUID` | Sí | Identificador de la orden de trabajo. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

No requiere cuerpo de petición (petición sin contenido o parámetros en URL).

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `java.util.List<com.andeva.atelier.platform.operations.interfaces.rest.resources.TaskProposalResource>`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `[].id` | `UUID` | Identificador único de la propuesta técnica. |
| `[].workOrderId` | `UUID` | Identificador de la orden asociada. |
| `[].tenantId` | `UUID` | Identificador del taller titular. |
| `[].proposerMechanicId` | `UUID` | Identificador del técnico descubridor. |
| `[].proposerMechanicName` | `String` | Nombre completo del técnico mecánico. |
| `[].title` | `String` | Título sintético del hallazgo pericial. |
| `[].description` | `String` | Detalle técnico de la anomalía constatada. |
| `[].severity` | `String` | Nivel de severidad técnica (LOW, MEDIUM, HIGH, CRITICAL). |
| `[].estimatedHours` | `BigDecimal` | Horas hombre estimadas de mano de obra. |
| `[].estimatedPrice` | `BigDecimal` | Presupuesto sugerido de la reparación. |
| `[].evidencePhotoUrl` | `String` | Localizador HTTPS de la fotografía probatoria del daño. |
| `[].status` | `String` | Estado de evaluación (PENDING_REVIEW, NOTIFIED_TO_CLIENT, APPROVED, REJECTED). |
| `[].createdAt` | `Instant` | Marca temporal del reporte en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
[
  {
    "id": "b1c2d3e4-f5a6-7b8c-9d0e-1f2a3b4c5d6e",
    "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
    "tenantId": "550e8400-e29b-41d4-a716-446655440000",
    "proposerMechanicId": "2c3d4e5f-6a7b-8c9d-0e1f-2a3b4c5d6e7f",
    "proposerMechanicName": "Jorge Luis Huamán Ramos",
    "title": "Fuga severa de fluido en retén de semieje delantero derecho",
    "description": "Durante el desmontaje de caliper se constata pérdida activa de lubricante de transmisión por rotura de retén.",
    "severity": "HIGH",
    "estimatedHours": 1.50,
    "estimatedPrice": 180.00,
    "evidencePhotoUrl": "https://storage.googleapis.com/atelier-evidence/tenants/550e8400/prop-b1c2/oil-leak-axle.jpg",
    "status": "PENDING_REVIEW",
    "createdAt": "2026-10-01T10:15:00Z"
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `WORK_ORDER_NOT_FOUND` | `WorkOrderNotFoundException` | No existe la orden de trabajo referenciada. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/work-order-not-found",
  "title": "Orden No Encontrada",
  "status": 404,
  "detail": "No se localiza la orden 7b8e5c12-3f84-4a21-9d10-8b45f1e29001.",
  "instance": "/api/v1/operations/proposals/by-work-order/7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "code": "WORK_ORDER_NOT_FOUND",
  "timestamp": "2026-10-01T10:16:00Z"
}
```

---

### 4.22. [POST] `/api/v1/operations/proposals`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.TaskProposalsController`
* **Método Java:** `public ResponseEntity<TaskProposalResource> createProposal(@Valid @RequestBody CreateTaskProposalResource resource, UriComponentsBuilder ucb)`
* **Ruta Canónica:** `POST /api/v1/operations/proposals`
* **Propósito Funcional:** Registra formalmente un hallazgo pericial o avería imprevista detectada en elevador por parte del mecánico asignado, adjuntando evidencia visual probatoria y nivel de gravedad.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_MECHANIC`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:proposals:create')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Content-Type` | `String` | Sí | application/json para el cuerpo del mensaje. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):** No aplica.

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.CreateTaskProposalResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `workOrderId` | `UUID` | Sí | @NotNull | Identificador de la orden de trabajo. |
| `title` | `String` | Sí | @NotBlank, @Size(max = 150) | Título del hallazgo detectado. |
| `description` | `String` | Sí | @NotBlank, @Size(max = 1000) | Detalle técnico de la avería encontrada. |
| `severity` | `String` | Sí | Enum(LOW, MEDIUM, HIGH, CRITICAL) | Clasificación de riesgo mecánico. |
| `estimatedHours` | `BigDecimal` | Sí | @NotNull, @DecimalMin("0.1") | Horas hombre estimadas para subsanar el hallazgo. |
| `estimatedPrice` | `BigDecimal` | No | @DecimalMin("0.00") | Precio sugerido para la propuesta. |
| `evidencePhotoUrl` | `String` | Sí | @NotBlank, @URL | Localizador HTTPS de la evidencia fotográfica del daño. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "title": "Fuga severa de fluido en retén de semieje delantero derecho",
  "description": "Durante el desmontaje de caliper se constata pérdida activa de lubricante de transmisión por rotura de retén.",
  "severity": "HIGH",
  "estimatedHours": 1.50,
  "estimatedPrice": 180.00,
  "evidencePhotoUrl": "https://storage.googleapis.com/atelier-evidence/tenants/550e8400/prop-b1c2/oil-leak-axle.jpg"
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `201 Created`
* **Cabecera de Ubicación (*Location Header*):** `/api/v1/operations/proposals/b1c2d3e4-f5a6-7b8c-9d0e-1f2a3b4c5d6e`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.TaskProposalResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador técnico de la propuesta. |
| `workOrderId` | `UUID` | Identificador de la orden asociada. |
| `status` | `String` | Estado operativo inicial (PENDING_REVIEW). |
| `createdAt` | `Instant` | Marca temporal de registro en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "b1c2d3e4-f5a6-7b8c-9d0e-1f2a3b4c5d6e",
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "proposerMechanicId": "2c3d4e5f-6a7b-8c9d-0e1f-2a3b4c5d6e7f",
  "proposerMechanicName": "Jorge Luis Huamán Ramos",
  "title": "Fuga severa de fluido en retén de semieje delantero derecho",
  "description": "Durante el desmontaje de caliper se constata pérdida activa de lubricante de transmisión por rotura de retén.",
  "severity": "HIGH",
  "estimatedHours": 1.50,
  "estimatedPrice": 180.00,
  "evidencePhotoUrl": "https://storage.googleapis.com/atelier-evidence/tenants/550e8400/prop-b1c2/oil-leak-axle.jpg",
  "status": "PENDING_REVIEW",
  "createdAt": "2026-10-01T10:15:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 400 | `INVALID_PROPOSAL_PARAMETERS` | `IllegalArgumentException` | Horas estimadas no positivas o URL de imagen inválida. |
| 404 | `WORK_ORDER_NOT_FOUND` | `WorkOrderNotFoundException` | No existe la orden de trabajo para asociar el hallazgo. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/invalid-proposal",
  "title": "Propuesta Inválida",
  "status": 400,
  "detail": "Las horas estimadas de labor deben ser estrictamente superiores a cero.",
  "instance": "/api/v1/operations/proposals",
  "code": "INVALID_PROPOSAL_PARAMETERS",
  "timestamp": "2026-10-01T10:15:01Z"
}
```

---

### 4.23. [GET] `/api/v1/operations/proposals/{id}`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.TaskProposalsController`
* **Método Java:** `public ResponseEntity<TaskProposalResource> getProposalById(@PathVariable UUID id)`
* **Ruta Canónica:** `GET /api/v1/operations/proposals/{id}`
* **Propósito Funcional:** Consulta el detalle exhaustivo de una propuesta de labor adicional y su estado de resolución comercial y técnica.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_MECHANIC`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:proposals:read')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Accept` | `String` | No | application/json por defecto. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador único de la propuesta de tarea. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

No requiere cuerpo de petición (petición sin contenido o parámetros en URL).

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.TaskProposalResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la propuesta. |
| `title` | `String` | Título del hallazgo. |
| `severity` | `String` | Nivel de severidad técnica. |
| `evidencePhotoUrl` | `String` | URL de evidencia probatoria. |
| `status` | `String` | Estado de resolución de la propuesta. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "b1c2d3e4-f5a6-7b8c-9d0e-1f2a3b4c5d6e",
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "proposerMechanicId": "2c3d4e5f-6a7b-8c9d-0e1f-2a3b4c5d6e7f",
  "proposerMechanicName": "Jorge Luis Huamán Ramos",
  "title": "Fuga severa de fluido en retén de semieje delantero derecho",
  "description": "Durante el desmontaje de caliper se constata pérdida activa de lubricante de transmisión por rotura de retén.",
  "severity": "HIGH",
  "estimatedHours": 1.50,
  "estimatedPrice": 180.00,
  "evidencePhotoUrl": "https://storage.googleapis.com/atelier-evidence/tenants/550e8400/prop-b1c2/oil-leak-axle.jpg",
  "status": "PENDING_REVIEW",
  "createdAt": "2026-10-01T10:15:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `TASK_PROPOSAL_NOT_FOUND` | `TaskProposalNotFoundException` | No existe la propuesta con el identificador provisto. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/proposal-not-found",
  "title": "Propuesta No Encontrada",
  "status": 404,
  "detail": "No existe la propuesta técnica con ID b1c2d3e4-f5a6-7b8c-9d0e-1f2a3b4c5d6e.",
  "instance": "/api/v1/operations/proposals/b1c2d3e4-f5a6-7b8c-9d0e-1f2a3b4c5d6e",
  "code": "TASK_PROPOSAL_NOT_FOUND",
  "timestamp": "2026-10-01T10:16:00Z"
}
```

---

### 4.24. [POST] `/api/v1/operations/proposals/{id}/notify`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.TaskProposalsController`
* **Método Java:** `public ResponseEntity<MessageResource> notifyClient(@PathVariable UUID id)`
* **Ruta Canónica:** `POST /api/v1/operations/proposals/{id}/notify`
* **Propósito Funcional:** Remite la propuesta técnica al cliente mediante notificación digital enriquecida con fotografía probatoria y presupuesto preliminar para su autorización remota.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_SERVICE_ADVISOR`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:proposals:notify')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Accept` | `String` | No | application/json por defecto. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador de la propuesta técnica a notificar. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

No requiere cuerpo de petición (petición sin contenido o parámetros en URL).

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.shared.interfaces.rest.resources.MessageResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `message` | `String` | Confirmación del despacho de notificación. |
| `proposalId` | `UUID` | Identificador de la propuesta remitida. |
| `notificationChannel` | `String` | Canal digital utilizado (WHATSAPP/SMS). |
| `sentAt` | `Instant` | Marca temporal del despacho en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "message": "Notificación de avería imprevista despachada satisfactoriamente al titular del vehículo.",
  "proposalId": "b1c2d3e4-f5a6-7b8c-9d0e-1f2a3b4c5d6e",
  "notificationChannel": "WHATSAPP",
  "sentAt": "2026-10-01T10:20:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `TASK_PROPOSAL_NOT_FOUND` | `TaskProposalNotFoundException` | No existe la propuesta referenciada. |
| 422 | `PROPOSAL_ALREADY_RESOLVED` | `IllegalStateException` | La propuesta ya se encuentra aprobada o rechazada. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/proposal-already-resolved",
  "title": "Propuesta Resuelta",
  "status": 422,
  "detail": "No se puede notificar una propuesta que ya ha sido resuelta técnicamente.",
  "instance": "/api/v1/operations/proposals/b1c2d3e4-f5a6-7b8c-9d0e-1f2a3b4c5d6e/notify",
  "code": "PROPOSAL_ALREADY_RESOLVED",
  "timestamp": "2026-10-01T10:20:01Z"
}
```

---

### 4.25. [POST] `/api/v1/operations/proposals/{id}/approve`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.TaskProposalsController`
* **Método Java:** `public ResponseEntity<TaskProposalResource> approveProposal(@PathVariable UUID id, @Valid @RequestBody ApproveProposalResource resource)`
* **Ruta Canónica:** `POST /api/v1/operations/proposals/{id}/approve`
* **Propósito Funcional:** Registra la autorización formal del cliente para la propuesta de trabajo complementario, instanciando automáticamente una tarea operativa formal de orden de trabajo en estado asignado.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_SERVICE_ADVISOR`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:proposals:approve')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Content-Type` | `String` | Sí | application/json para el cuerpo del mensaje. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador de la propuesta técnica a aprobar. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.ApproveProposalResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `assignedMechanicId` | `UUID` | No | Opcional | Técnico asignado para ejecutar la nueva tarea autorizada. |
| `agreedPrice` | `BigDecimal` | Sí | @NotNull, @DecimalMin("0.00") | Importe económico concertado con el cliente. |
| `approvalNotes` | `String` | No | @Size(max = 500) | Anotaciones sobre el acuerdo de autorización. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "assignedMechanicId": "2c3d4e5f-6a7b-8c9d-0e1f-2a3b4c5d6e7f",
  "agreedPrice": 180.00,
  "approvalNotes": "Cliente autorizó cambio de retén mediante llamada telefónica grabada."
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.TaskProposalResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la propuesta. |
| `status` | `String` | Nuevo estado (APPROVED). |
| `updatedAt` | `Instant` | Marca temporal de resolución en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "b1c2d3e4-f5a6-7b8c-9d0e-1f2a3b4c5d6e",
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "proposerMechanicId": "2c3d4e5f-6a7b-8c9d-0e1f-2a3b4c5d6e7f",
  "title": "Fuga severa de fluido en retén de semieje delantero derecho",
  "status": "APPROVED",
  "estimatedPrice": 180.00,
  "updatedAt": "2026-10-01T10:25:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `TASK_PROPOSAL_NOT_FOUND` | `TaskProposalNotFoundException` | No existe la propuesta especificada. |
| 409 | `TASK_PROPOSAL_ALREADY_PROCESSED` | `TaskProposalAlreadyProcessedException` | La propuesta ya fue resuelta previamente. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/proposal-already-processed",
  "title": "Propuesta Ya Procesada",
  "status": 409,
  "detail": "La propuesta b1c2d3e4-f5a6-7b8c-9d0e-1f2a3b4c5d6e ya fue resuelta y no admite cambios.",
  "instance": "/api/v1/operations/proposals/b1c2d3e4-f5a6-7b8c-9d0e-1f2a3b4c5d6e/approve",
  "code": "TASK_PROPOSAL_ALREADY_PROCESSED",
  "timestamp": "2026-10-01T10:25:01Z"
}
```

---

### 4.26. [POST] `/api/v1/operations/proposals/{id}/reject`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.TaskProposalsController`
* **Método Java:** `public ResponseEntity<TaskProposalResource> rejectProposal(@PathVariable UUID id, @Valid @RequestBody RejectProposalResource resource)`
* **Ruta Canónica:** `POST /api/v1/operations/proposals/{id}/reject`
* **Propósito Funcional:** Desestima la labor complementaria ante la negativa del cliente, archivando formalmente el hallazgo pericial en la historia técnica del vehículo por exención de responsabilidad civil del taller.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_SERVICE_ADVISOR`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:proposals:reject')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Content-Type` | `String` | Sí | application/json para el cuerpo del mensaje. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador de la propuesta técnica a desestimar. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.RejectProposalResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `rejectionReason` | `String` | Sí | @NotBlank, @Size(min = 5, max = 500) | Motivo justificado de la desestimación técnica. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "rejectionReason": "Cliente no autoriza cambio de retén en esta visita por presupuesto limitado. Se le advierte riesgo de daño a la caja de cambios."
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.TaskProposalResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la propuesta. |
| `status` | `String` | Nuevo estado (REJECTED). |
| `rejectionReason` | `String` | Motivo registrado de desestimación. |
| `updatedAt` | `Instant` | Marca temporal de desestimación en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "b1c2d3e4-f5a6-7b8c-9d0e-1f2a3b4c5d6e",
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "status": "REJECTED",
  "rejectionReason": "Cliente no autoriza cambio de retén en esta visita por presupuesto limitado.",
  "updatedAt": "2026-10-01T10:25:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `TASK_PROPOSAL_NOT_FOUND` | `TaskProposalNotFoundException` | No existe la propuesta especificada. |
| 409 | `TASK_PROPOSAL_ALREADY_PROCESSED` | `TaskProposalAlreadyProcessedException` | La propuesta ya fue resuelta previamente. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/proposal-already-processed",
  "title": "Propuesta Ya Procesada",
  "status": 409,
  "detail": "No se puede desestimar una propuesta técnica que ya fue procesada.",
  "instance": "/api/v1/operations/proposals/b1c2d3e4-f5a6-7b8c-9d0e-1f2a3b4c5d6e/reject",
  "code": "TASK_PROPOSAL_ALREADY_PROCESSED",
  "timestamp": "2026-10-01T10:25:01Z"
}
```

---

### 4.27. [GET] `/api/v1/operations/tasks`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.TasksController`
* **Método Java:** `public ResponseEntity<Page<TaskSummaryResource>> getTasks(Pageable pageable, @RequestParam(required = false) UUID workOrderId, @RequestParam(required = false) UUID assignedMechanicId, @RequestParam(required = false) String status)`
* **Ruta Canónica:** `GET /api/v1/operations/tasks`
* **Propósito Funcional:** Recupera el conjunto paginado y filtrado de tareas mecánicas en ejecución o programadas en la planta del taller, facilitando el control visual de carga operativa y cuellos de botella por foso o elevador.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_MECHANIC`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:tasks:read')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Accept` | `String` | No | application/json por defecto. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):** No aplica.

**Parámetros de Consulta (Query Parameters):**

| Parámetro | Tipo | Requerido | Valor por Defecto | Descripción |
| :--- | :--- | :---: | :---: | :--- |
| `workOrderId` | `UUID` | No | `null` | Filtro por orden de trabajo contenedora. |
| `assignedMechanicId` | `UUID` | No | `null` | Filtro por técnico mecánico ejecutor. |
| `status` | `String` | No | `null` | Filtro por estado de la labor (PENDING, ASSIGNED, IN_PROGRESS, ON_HOLD, COMPLETED, CANCELLED). |
| `page` | `Integer` | No | `0` | Índice de la página solicitada. |
| `size` | `Integer` | No | `20` | Elementos por bloque paginado. |
| `sort` | `String` | No | `createdAt,desc` | Criterio de ordenación. |

#### Cuerpo de Petición (Request)

No requiere cuerpo de petición (petición sin contenido o parámetros en URL).

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `org.springframework.data.domain.Page<com.andeva.atelier.platform.operations.interfaces.rest.resources.TaskSummaryResource>`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `content[].id` | `UUID` | Identificador único de la tarea técnica. |
| `content[].workOrderId` | `UUID` | Identificador de la orden de trabajo. |
| `content[].workOrderNumber` | `String` | Correlativo de la orden contenedora. |
| `content[].serviceId` | `UUID` | Identificador del servicio de catálogo. |
| `content[].serviceName` | `String` | Nombre del servicio técnico ejecutado. |
| `content[].assignedMechanicId` | `UUID` | Identificador del mecánico responsable. |
| `content[].assignedMechanicName` | `String` | Nombre completo del técnico asignado. |
| `content[].status` | `String` | Estado operativo actual de la labor. |
| `content[].estimatedHours` | `BigDecimal` | Horas hombre estándar presupuestadas. |
| `content[].actualLaborHours` | `BigDecimal` | Horas hombre efectivas cronometradas. |
| `content[].isHold` | `Boolean` | Bandera de suspensión temporal por falta de insumo o imprevisto. |
| `content[].holdReason` | `String` | Causa tipificada de la suspensión si aplica. |
| `content[].createdAt` | `Instant` | Marca temporal de creación en UTC. |
| `content[].updatedAt` | `Instant` | Marca temporal de última modificación en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "content": [
    {
      "id": "f1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c",
      "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
      "workOrderNumber": "OT-2026-00451",
      "serviceId": "5e1a2b3c-4d5e-6f7a-8b9c-0d1e2f3a4b5c",
      "serviceName": "Desmontaje, rectificado de discos ventilados e instalación de pastillas",
      "assignedMechanicId": "2c3d4e5f-6a7b-8c9d-0e1f-2a3b4c5d6e7f",
      "assignedMechanicName": "Jorge Luis Huamán Ramos",
      "status": "IN_PROGRESS",
      "estimatedHours": 2.50,
      "actualLaborHours": 1.25,
      "isHold": false,
      "holdReason": null,
      "createdAt": "2026-10-01T09:30:00Z",
      "updatedAt": "2026-10-01T10:45:00Z"
    }
  ],
  "pageable": {
    "pageNumber": 0,
    "pageSize": 20
  },
  "totalElements": 1,
  "totalPages": 1,
  "last": true,
  "size": 20,
  "number": 0,
  "first": true,
  "empty": false
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 400 | `INVALID_QUERY_PARAMETER` | `IllegalArgumentException` | Parámetro de estado o paginación no admitido. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/invalid-query-parameter",
  "title": "Parámetro Inválido",
  "status": 400,
  "detail": "El valor del estado no corresponde a la enumeración de tareas.",
  "instance": "/api/v1/operations/tasks",
  "code": "INVALID_QUERY_PARAMETER",
  "timestamp": "2026-10-01T10:46:00Z"
}
```

---

### 4.28. [GET] `/api/v1/operations/tasks/{id}`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.TasksController`
* **Método Java:** `public ResponseEntity<TaskResource> getTaskById(@PathVariable UUID id)`
* **Ruta Canónica:** `GET /api/v1/operations/tasks/{id}`
* **Propósito Funcional:** Obtiene el detalle completo de una tarea mecánica individual, proyectando telemetría de tiempos de foso, estado del cronómetro, repuestos imputados y evidencias fotográficas asociadas.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_MECHANIC`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:tasks:read')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Accept` | `String` | No | application/json por defecto. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador único de la tarea mecánica. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

No requiere cuerpo de petición (petición sin contenido o parámetros en URL).

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.TaskResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador técnico de la labor. |
| `workOrderId` | `UUID` | Identificador de la orden de trabajo. |
| `tenantId` | `UUID` | Identificador del taller titular. |
| `serviceId` | `UUID` | Identificador del servicio de catálogo. |
| `serviceName` | `String` | Denominación técnica de la labor. |
| `assignedMechanicId` | `UUID` | Identificador del mecánico asignado. |
| `assignedMechanicName` | `String` | Nombre completo del técnico responsable. |
| `status` | `String` | Estado operativo actual. |
| `estimatedHours` | `BigDecimal` | Horas hombre presupuestadas. |
| `actualLaborHours` | `BigDecimal` | Horas hombre acumuladas trabajadas. |
| `timerRunning` | `Boolean` | Indica si el cronómetro se encuentra corriendo en tiempo real. |
| `lastTimerStartedAt` | `Instant` | Marca temporal del último inicio de cronómetro en UTC. |
| `isHold` | `Boolean` | Indica si la tarea se encuentra en suspensión operativa. |
| `holdReason` | `String` | Causa de la suspensión si aplica. |
| `requiredParts` | `List<TaskProductResource>` | Colección de repuestos asignados o consumidos para la tarea. |
| `photos` | `List<TaskPhotoResource>` | Evidencias fotográficas periciales capturadas en foso. |
| `createdAt` | `Instant` | Marca temporal de creación en UTC. |
| `updatedAt` | `Instant` | Marca temporal de actualización en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "f1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c",
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "serviceId": "5e1a2b3c-4d5e-6f7a-8b9c-0d1e2f3a4b5c",
  "serviceName": "Desmontaje, rectificado de discos ventilados e instalación de pastillas",
  "assignedMechanicId": "2c3d4e5f-6a7b-8c9d-0e1f-2a3b4c5d6e7f",
  "assignedMechanicName": "Jorge Luis Huamán Ramos",
  "status": "IN_PROGRESS",
  "estimatedHours": 2.50,
  "actualLaborHours": 1.25,
  "timerRunning": true,
  "lastTimerStartedAt": "2026-10-01T10:00:00Z",
  "isHold": false,
  "holdReason": null,
  "requiredParts": [
    {
      "id": "a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c71",
      "taskId": "f1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c",
      "partId": "6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d",
      "partName": "Juego de Pastillas Cerámicas Delanteras Brembo P83024",
      "partSku": "BRM-P83024",
      "quantityRequested": 1.00,
      "quantityDischarged": 1.00,
      "unitPrice": 450.50
    }
  ],
  "photos": [
    {
      "photoId": "7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d",
      "taskId": "f1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c",
      "photoUrl": "https://storage.googleapis.com/atelier-evidence/tenants/550e8400/tasks-f1a2/disassembly-caliper.jpg",
      "caption": "Desmontaje de mordaza de freno y verificación de desgaste",
      "stage": "DISASSEMBLY",
      "fileSizeBytes": 1850400,
      "mimeType": "image/jpeg",
      "uploadedAt": "2026-10-01T10:15:00Z"
    }
  ],
  "createdAt": "2026-10-01T09:30:00Z",
  "updatedAt": "2026-10-01T10:45:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `WORK_ORDER_TASK_NOT_FOUND` | `WorkOrderTaskNotFoundException` | No existe la labor mecánica consultada. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/task-not-found",
  "title": "Tarea No Encontrada",
  "status": 404,
  "detail": "No se localiza la tarea mecánica con ID f1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c.",
  "instance": "/api/v1/operations/tasks/f1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c",
  "code": "WORK_ORDER_TASK_NOT_FOUND",
  "timestamp": "2026-10-01T10:46:00Z"
}
```

---

### 4.29. [POST] `/api/v1/operations/tasks/{id}/timer/start`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.TasksController`
* **Método Java:** `public ResponseEntity<TaskResource> startTimer(@PathVariable UUID id, @Valid @RequestBody StartTimerResource resource)`
* **Ruta Canónica:** `POST /api/v1/operations/tasks/{id}/timer/start`
* **Propósito Funcional:** Inicia formalmente el cronometraje de labor efectiva en foso (Wrench Time), transicionando la tarea al estado IN_PROGRESS y registrando la marca temporal de arranque.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_MECHANIC`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:tasks:track_time')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Content-Type` | `String` | Sí | application/json para el cuerpo del mensaje. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador único de la tarea técnica. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.StartTimerResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `mechanicId` | `UUID` | Sí | @NotNull | Identificador del técnico que inicia el cronómetro. |
| `clientTimestamp` | `Instant` | Sí | @NotNull | Marca temporal del dispositivo móvil del mecánico al pulsar arranque. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "mechanicId": "2c3d4e5f-6a7b-8c9d-0e1f-2a3b4c5d6e7f",
  "clientTimestamp": "2026-10-01T10:00:00Z"
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.TaskResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la tarea. |
| `status` | `String` | Estado operativo (IN_PROGRESS). |
| `timerRunning` | `Boolean` | Bandera de cronómetro activo (true). |
| `lastTimerStartedAt` | `Instant` | Hora de inicio registrada en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "f1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c",
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "status": "IN_PROGRESS",
  "timerRunning": true,
  "lastTimerStartedAt": "2026-10-01T10:00:00Z",
  "actualLaborHours": 0.00,
  "updatedAt": "2026-10-01T10:00:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `WORK_ORDER_TASK_NOT_FOUND` | `WorkOrderTaskNotFoundException` | No existe la labor mecánica indicada. |
| 409 | `TIMER_ALREADY_RUNNING` | `IllegalStateException` | El cronómetro de la labor ya se encuentra activo. |
| 422 | `TASK_CANNOT_BE_STARTED` | `IllegalStateException` | La tarea se encuentra completada o suspendida sin reactivación. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/timer-already-running",
  "title": "Cronómetro Ya Activo",
  "status": 409,
  "detail": "El cronómetro para la labor f1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c ya fue iniciado previamente.",
  "instance": "/api/v1/operations/tasks/f1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c/timer/start",
  "code": "TIMER_ALREADY_RUNNING",
  "timestamp": "2026-10-01T10:00:01Z"
}
```

---

### 4.30. [POST] `/api/v1/operations/tasks/{id}/timer/pause`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.TasksController`
* **Método Java:** `public ResponseEntity<TaskResource> pauseTimer(@PathVariable UUID id, @Valid @RequestBody PauseTimerResource resource)`
* **Ruta Canónica:** `POST /api/v1/operations/tasks/{id}/timer/pause`
* **Propósito Funcional:** Detiene provisionalmente el cronómetro de labor efectiva, computando el lapso transcurrido en el acumulador de horas hombre efectivas del técnico.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_MECHANIC`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:tasks:track_time')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Content-Type` | `String` | Sí | application/json para el cuerpo del mensaje. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador único de la tarea técnica. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.PauseTimerResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `mechanicId` | `UUID` | Sí | @NotNull | Identificador del técnico que pausa el cronómetro. |
| `clientTimestamp` | `Instant` | Sí | @NotNull | Marca temporal del dispositivo móvil al pulsar pausa. |
| `pauseReason` | `String` | No | @Size(max = 255) | Motivo opcional de la interrupción (ej. refrigerio, espera de herramienta). |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "mechanicId": "2c3d4e5f-6a7b-8c9d-0e1f-2a3b4c5d6e7f",
  "clientTimestamp": "2026-10-01T11:15:00Z",
  "pauseReason": "Pausa para almuerzo del personal de bahía."
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.TaskResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la tarea. |
| `timerRunning` | `Boolean` | Bandera de cronómetro desactivada (false). |
| `actualLaborHours` | `BigDecimal` | Horas hombre recalculadas y acumuladas (1.25 horas). |
| `updatedAt` | `Instant` | Marca temporal de la pausa en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "f1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c",
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "status": "IN_PROGRESS",
  "timerRunning": false,
  "lastTimerStartedAt": null,
  "actualLaborHours": 1.25,
  "updatedAt": "2026-10-01T11:15:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `WORK_ORDER_TASK_NOT_FOUND` | `WorkOrderTaskNotFoundException` | No existe la tarea técnica especificada. |
| 409 | `TIMER_NOT_RUNNING` | `IllegalStateException` | El cronómetro no se encontraba corriendo. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/timer-not-running",
  "title": "Cronómetro Inactivo",
  "status": 409,
  "detail": "No se puede pausar un cronómetro que se encuentra detenido.",
  "instance": "/api/v1/operations/tasks/f1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c/timer/pause",
  "code": "TIMER_NOT_RUNNING",
  "timestamp": "2026-10-01T11:15:01Z"
}
```

---

### 4.31. [POST] `/api/v1/operations/tasks/{id}/photos`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.TasksController`
* **Método Java:** `public ResponseEntity<TaskPhotoResource> uploadPhoto(@PathVariable UUID id, @Valid @RequestBody UploadTaskPhotoResource resource, UriComponentsBuilder ucb)`
* **Ruta Canónica:** `POST /api/v1/operations/tasks/{id}/photos`
* **Propósito Funcional:** Adjunta evidencias gráficas intermedias del proceso de intervención técnica en bahía (desmontaje, estado de pieza sustituida, instalación de pieza nueva y montaje final).

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_MECHANIC`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:tasks:upload_photos')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Content-Type` | `String` | Sí | application/json para el cuerpo del mensaje. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador de la tarea mecánica receptora. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.UploadTaskPhotoResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `photoUrl` | `String` | Sí | @NotBlank, @URL | Localizador HTTPS seguro de la evidencia en Cloud Storage. |
| `caption` | `String` | Sí | @NotBlank, @Size(max = 255) | Leyenda descriptiva del componente o maniobra. |
| `stage` | `String` | Sí | Enum(DISASSEMBLY, DEFECT_DETAIL, NEW_PART_INSTALLED, COMPLETED) | Fase operativa en que se captura la evidencia. |
| `fileSizeBytes` | `Long` | Sí | @NotNull, @Min(1) | Peso del archivo en bytes. |
| `mimeType` | `String` | Sí | @NotBlank, @Pattern(regexp = "image/(jpeg|png|webp)") | Formato MIME de imagen admitido. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "photoUrl": "https://storage.googleapis.com/atelier-evidence/tenants/550e8400/tasks-f1a2/disassembly-caliper.jpg",
  "caption": "Desmontaje de mordaza de freno y verificación de desgaste",
  "stage": "DISASSEMBLY",
  "fileSizeBytes": 1850400,
  "mimeType": "image/jpeg"
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `201 Created`
* **Cabecera de Ubicación (*Location Header*):** `/api/v1/operations/tasks/f1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c/photos/7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.TaskPhotoResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `photoId` | `UUID` | Identificador técnico de la fotografía. |
| `taskId` | `UUID` | Identificador de la tarea asociada. |
| `photoUrl` | `String` | URL pública firmada de consulta. |
| `caption` | `String` | Leyenda descriptiva registrada. |
| `stage` | `String` | Fase operativa clasificada. |
| `fileSizeBytes` | `Long` | Peso del archivo en bytes. |
| `mimeType` | `String` | Tipo MIME verificado. |
| `uploadedAt` | `Instant` | Marca temporal de carga en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "photoId": "7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d",
  "taskId": "f1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c",
  "photoUrl": "https://storage.googleapis.com/atelier-evidence/tenants/550e8400/tasks-f1a2/disassembly-caliper.jpg",
  "caption": "Desmontaje de mordaza de freno y verificación de desgaste",
  "stage": "DISASSEMBLY",
  "fileSizeBytes": 1850400,
  "mimeType": "image/jpeg",
  "uploadedAt": "2026-10-01T10:15:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 400 | `INVALID_STORAGE_URL` | `InvalidStorageUrlException` | URL no conforme con protocolo seguro o dominio oficial. |
| 404 | `WORK_ORDER_TASK_NOT_FOUND` | `WorkOrderTaskNotFoundException` | No existe la tarea técnica especificada. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/invalid-storage-url",
  "title": "URL Inválida",
  "status": 400,
  "detail": "El localizador provisto no satisface el esquema seguro HTTPS de Cloud Storage.",
  "instance": "/api/v1/operations/tasks/f1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c/photos",
  "code": "INVALID_STORAGE_URL",
  "timestamp": "2026-10-01T10:15:01Z"
}
```

---

### 4.32. [POST] `/api/v1/operations/tasks/{id}/hold`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.TasksController`
* **Método Java:** `public ResponseEntity<TaskResource> requestHold(@PathVariable UUID id, @Valid @RequestBody RequestHoldResource resource)`
* **Ruta Canónica:** `POST /api/v1/operations/tasks/{id}/hold`
* **Propósito Funcional:** Solicita la suspensión temporal de una tarea técnica (ON_HOLD) por indisponibilidad sobrevenida de repuestos en bodega, necesidad de rectificado externo o consulta al cliente.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_MECHANIC`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:tasks:hold_request')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Content-Type` | `String` | Sí | application/json para el cuerpo del mensaje. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador único de la tarea mecánica. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.RequestHoldResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `holdReason` | `String` | Sí | Enum(WAITING_PARTS, EXTERNAL_MACHINING, CLIENT_AUTHORIZATION, OTHER) | Causa tipificada de la suspensión operativa. |
| `holdDetails` | `String` | Sí | @NotBlank, @Size(max = 500) | Detalle explicativo de la razón que impide continuar. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "holdReason": "WAITING_PARTS",
  "holdDetails": "Retén de semieje solicitado no cuenta con saldo disponible en bodega central. En espera de despacho de proveedor mayorista."
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.TaskResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la tarea. |
| `status` | `String` | Nuevo estado (ON_HOLD). |
| `isHold` | `Boolean` | Indicador de suspensión activado (true). |
| `holdReason` | `String` | Causa tipificada registrada. |
| `timerRunning` | `Boolean` | Cronómetro automáticamente detenido (false). |
| `updatedAt` | `Instant` | Marca temporal de suspensión en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "f1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c",
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "status": "ON_HOLD",
  "isHold": true,
  "holdReason": "WAITING_PARTS",
  "timerRunning": false,
  "updatedAt": "2026-10-01T11:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `WORK_ORDER_TASK_NOT_FOUND` | `WorkOrderTaskNotFoundException` | No existe la tarea técnica especificada. |
| 422 | `TASK_CANNOT_BE_PUT_ON_HOLD` | `TaskCannotBePutOnHoldException` | La labor no se encuentra en estado IN_PROGRESS o ya está en pausa. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/task-cannot-be-put-on-hold",
  "title": "Suspensión No Permitida",
  "status": 422,
  "detail": "Solo tareas en ejecución activa pueden solicitar suspensión por repuesto faltante.",
  "instance": "/api/v1/operations/tasks/f1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c/hold",
  "code": "TASK_CANNOT_BE_PUT_ON_HOLD",
  "timestamp": "2026-10-01T11:30:01Z"
}
```

---

### 4.33. [POST] `/api/v1/operations/tasks/{id}/resume`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.TasksController`
* **Método Java:** `public ResponseEntity<TaskResource> resumeTask(@PathVariable UUID id, @Valid @RequestBody ResumeTaskResource resource)`
* **Ruta Canónica:** `POST /api/v1/operations/tasks/{id}/resume`
* **Propósito Funcional:** Reanuda administrativamente una labor suspendida tras verificarse la llegada del repuesto o la culminación del servicio de terceros, habilitando nuevamente el cronómetro.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_CHIEF_MECHANIC`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:tasks:hold_validate')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Content-Type` | `String` | Sí | application/json para el cuerpo del mensaje. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador de la tarea suspendida. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.ResumeTaskResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `resolutionNotes` | `String` | Sí | @NotBlank, @Size(max = 500) | Detalle de la resolución del impedimento técnico o logístico. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "resolutionNotes": "Repuesto recibido en almacén mediante remisión de distribuidor local. Se entrega a mecánico en bahía."
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.TaskResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la tarea. |
| `status` | `String` | Nuevo estado (ASSIGNED o IN_PROGRESS). |
| `isHold` | `Boolean` | Bandera de suspensión desactivada (false). |
| `holdReason` | `String` | Causa limpiada (null). |
| `updatedAt` | `Instant` | Marca temporal de reactivación en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "f1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c",
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "status": "ASSIGNED",
  "isHold": false,
  "holdReason": null,
  "timerRunning": false,
  "updatedAt": "2026-10-01T13:45:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `WORK_ORDER_TASK_NOT_FOUND` | `WorkOrderTaskNotFoundException` | No existe la tarea técnica especificada. |
| 422 | `TASK_NOT_ON_HOLD` | `TaskNotOnHoldException` | La tarea no se encuentra en estado ON_HOLD. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/task-not-on-hold",
  "title": "Tarea No Suspendida",
  "status": 422,
  "detail": "No se puede reanudar una tarea mecánica que no se encuentra en estado de suspensión ON_HOLD.",
  "instance": "/api/v1/operations/tasks/f1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c/resume",
  "code": "TASK_NOT_ON_HOLD",
  "timestamp": "2026-10-01T13:45:01Z"
}
```

---

### 4.34. [POST] `/api/v1/operations/tasks/{id}/complete`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.TasksController`
* **Método Java:** `public ResponseEntity<TaskResource> completeTask(@PathVariable UUID id, @Valid @RequestBody CompleteTaskResource resource)`
* **Ruta Canónica:** `POST /api/v1/operations/tasks/{id}/complete`
* **Propósito Funcional:** Registra la culminación técnica satisfactoria de la labor mecánica, deteniendo cronómetros, consolidando horas hombre definitivas y habilitando el pase de control de calidad pericial.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_MECHANIC`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:tasks:complete')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Content-Type` | `String` | Sí | application/json para el cuerpo del mensaje. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador único de la labor mecánica a finalizar. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.CompleteTaskResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `finalNotes` | `String` | No | @Size(max = 1000) | Observaciones técnicas de la maniobra culminada. |
| `mechanicReport` | `String` | Sí | @NotBlank, @Size(max = 1000) | Informe pericial de conformidad técnica del operario. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "finalNotes": "Discos rectificados dentro de tolerancia de fabricante (26.2 mm). Pastillas asentadas correctamente.",
  "mechanicReport": "Prueba de frenado estática conforme. Pedal firme sin esponjosidad. Sin fugas de líquido hidráulico."
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.TaskResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la tarea. |
| `status` | `String` | Nuevo estado definitivo (COMPLETED). |
| `actualLaborHours` | `BigDecimal` | Total consolidado de horas hombre efectivas. |
| `timerRunning` | `Boolean` | Cronómetro desactivado de forma definitiva (false). |
| `updatedAt` | `Instant` | Marca temporal de culminación en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "f1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c",
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "status": "COMPLETED",
  "actualLaborHours": 2.20,
  "timerRunning": false,
  "updatedAt": "2026-10-01T15:00:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `WORK_ORDER_TASK_NOT_FOUND` | `WorkOrderTaskNotFoundException` | No existe la tarea técnica especificada. |
| 422 | `WORK_ORDER_TASK_ALREADY_COMPLETED` | `WorkOrderTaskAlreadyCompletedException` | La labor técnica ya fue finalizada previamente. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/task-already-completed",
  "title": "Tarea Ya Completada",
  "status": 422,
  "detail": "La tarea f1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c ya se encuentra en estado COMPLETED.",
  "instance": "/api/v1/operations/tasks/f1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c/complete",
  "code": "WORK_ORDER_TASK_ALREADY_COMPLETED",
  "timestamp": "2026-10-01T15:00:01Z"
}
```

---

### 4.35. [GET] `/api/v1/operations/bays`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.BaysController`
* **Método Java:** `public ResponseEntity<List<BayResource>> getBays(@RequestParam(required = false) UUID branchId, @RequestParam(required = false) String status)`
* **Ruta Canónica:** `GET /api/v1/operations/bays`
* **Propósito Funcional:** Consulta en tiempo real el mapa físico de bahías operativas del taller (elevadores, fosos de alineamiento y puestos de diagnóstico), supervisando ocupación y vehículos atendidos.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_MECHANIC`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:bays:read')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Accept` | `String` | No | application/json por defecto. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):** No aplica.

**Parámetros de Consulta (Query Parameters):**

| Parámetro | Tipo | Requerido | Valor por Defecto | Descripción |
| :--- | :--- | :---: | :---: | :--- |
| `branchId` | `UUID` | No | `null` | Filtro por sede física operativa. |
| `status` | `String` | No | `null` | Filtro por estado de la bahía (AVAILABLE, OCCUPIED, MAINTENANCE, INACTIVE). |

#### Cuerpo de Petición (Request)

No requiere cuerpo de petición (petición sin contenido o parámetros en URL).

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `java.util.List<com.andeva.atelier.platform.operations.interfaces.rest.resources.BayResource>`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `[].id` | `UUID` | Identificador único de la bahía física. |
| `[].branchId` | `UUID` | Identificador de la sede del taller. |
| `[].bayNumber` | `String` | Código visible de la bahía (ej. B-01). |
| `[].name` | `String` | Denominación descriptiva del puesto. |
| `[].bayType` | `String` | Tipología física (TWO_POST_LIFT, FOUR_POST_LIFT, SCISSOR_LIFT, PIT_BAY, ALIGNMENT_BAY, WASH_BAY). |
| `[].status` | `String` | Estado operativo en tiempo real. |
| `[].currentWorkOrderId` | `UUID` | Identificador de la orden de trabajo activa si está ocupada. |
| `[].currentVehiclePlate` | `String` | Placa del automóvil que ocupa la bahía si aplica. |
| `[].createdAt` | `Instant` | Marca temporal de creación en UTC. |
| `[].updatedAt` | `Instant` | Marca temporal de actualización en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
[
  {
    "id": "9b1c2d3e-4f5a-6b7c-8d9e-0f1a2b3c4d5e",
    "branchId": "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
    "bayNumber": "B-02",
    "name": "Elevador Hidráulico 2 Columnas Principal",
    "bayType": "TWO_POST_LIFT",
    "status": "OCCUPIED",
    "currentWorkOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
    "currentVehiclePlate": "ABC-123",
    "createdAt": "2026-01-15T08:00:00Z",
    "updatedAt": "2026-10-01T08:30:00Z"
  },
  {
    "id": "a2b3c4d5-e6f7-8a9b-0c1d-2e3f4a5b6c7d",
    "branchId": "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
    "bayNumber": "B-03",
    "name": "Foso de Alineamiento y Suspensión",
    "bayType": "ALIGNMENT_BAY",
    "status": "AVAILABLE",
    "currentWorkOrderId": null,
    "currentVehiclePlate": null,
    "createdAt": "2026-01-15T08:00:00Z",
    "updatedAt": "2026-10-01T08:00:00Z"
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 400 | `INVALID_QUERY_PARAMETER` | `IllegalArgumentException` | Estado de bahía no reconocido en el sistema. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/invalid-query-parameter",
  "title": "Parámetro Inválido",
  "status": 400,
  "detail": "El valor del estado no corresponde a las tipologías de bahía.",
  "instance": "/api/v1/operations/bays",
  "code": "INVALID_QUERY_PARAMETER",
  "timestamp": "2026-10-01T08:00:01Z"
}
```

---

### 4.36. [POST] `/api/v1/operations/bays/{id}/reassign`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.BaysController`
* **Método Java:** `public ResponseEntity<BayResource> reassignBay(@PathVariable UUID id, @Valid @RequestBody ReassignBayResource resource)`
* **Ruta Canónica:** `POST /api/v1/operations/bays/{id}/reassign`
* **Propósito Funcional:** Ejecuta la reubicación física de un vehículo hacia una bahía destino libre para continuar maniobras especializadas (ej. traslado de elevador mecánico a puesto de alineamiento láser).

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_CHIEF_MECHANIC`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('operations:bays:reassign')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda a datos de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Content-Type` | `String` | Sí | application/json para el cuerpo del mensaje. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):**

| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Sí | Identificador de la bahía física de destino. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.ReassignBayResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `workOrderId` | `UUID` | Sí | @NotNull | Identificador de la orden de trabajo cuyo vehículo se reubica. |
| `reassignmentReason` | `String` | Sí | @NotBlank, @Size(max = 255) | Motivo justificado del traslado físico. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "reassignmentReason": "Culminada instalación de frenos. Se traslada a foso B-03 para calibración y alineamiento de dirección."
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.BayResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la bahía destino. |
| `bayNumber` | `String` | Código de la bahía asignada (B-03). |
| `status` | `String` | Nuevo estado (OCCUPIED). |
| `currentWorkOrderId` | `UUID` | Orden de trabajo asociada. |
| `currentVehiclePlate` | `String` | Placa del vehículo reubicado. |
| `updatedAt` | `Instant` | Marca temporal del traslado en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "a2b3c4d5-e6f7-8a9b-0c1d-2e3f4a5b6c7d",
  "branchId": "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
  "bayNumber": "B-03",
  "name": "Foso de Alineamiento y Suspensión",
  "bayType": "ALIGNMENT_BAY",
  "status": "OCCUPIED",
  "currentWorkOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "currentVehiclePlate": "ABC-123",
  "createdAt": "2026-01-15T08:00:00Z",
  "updatedAt": "2026-10-01T15:10:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `WORK_BAY_NOT_FOUND` | `WorkBayNotFoundException` | No existe la bahía física de destino indicada. |
| 409 | `WORK_BAY_OCCUPIED` | `WorkBayOccupiedException` | La bahía destino se encuentra ocupada por otro vehículo en atención activa. |
| 422 | `WORK_BAY_UNDER_MAINTENANCE` | `WorkBayUnderMaintenanceException` | La bahía destino se encuentra inhabilitada por mantenimiento o calibración técnica. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/work-bay-occupied",
  "title": "Bahía Ocupada",
  "status": 409,
  "detail": "La bahía B-03 se encuentra actualmente ocupada por otro vehículo.",
  "instance": "/api/v1/operations/bays/a2b3c4d5-e6f7-8a9b-0c1d-2e3f4a5b6c7d/reassign",
  "code": "WORK_BAY_OCCUPIED",
  "timestamp": "2026-10-01T15:10:01Z"
}
```

---
