# Especificacion Canonica de Endpoints: Workshop Operations Context

Este documento constituye la referencia tecnica y exhaustiva de los 36 endpoints expuestos por el Bounded Context **Workshop Operations Context (MRO)** (`com.andeva.atelier.platform.operations`) dentro de la plataforma SaaS **Atelier Platform Backend**.

## 1. Arquitectura de Operaciones de Taller, Bahias y Labores Mecanicas

El modulo Workshop Operations gobierna la ejecucion tecnica en planta: la apertura formal de ordenes de trabajo de reparacion, la asignacion dinamica de bahias fisicas operativas, el registro pericial de averias ocultas en foso, la gestion de repuestos consumidos con reserva logica FIFO, el cronometraje de horas hombre efectivas (Wrench Time) y el cierre tecnico con peritaje fotografico inmutable Direct-to-Cloud.

### 1.1. Principios Fundamentales del Diseno de Dominio
1. **Maquina de Estados Finita Determinista:** La orden de trabajo transiciona a traves de una secuencia estricta de estados inmutables: DRAFT (apertura y cotizacion), IN_PROGRESS (vehiculo en bahia y labores en foso activas), COMPLETED (labores culminadas tecnicamente y bahia liberada), PAID (pago conciliado y deduccion definitiva de stock) o CANCELLED (anulacion justificada con restitucion de reservas de inventario).
2. **Enrutamiento Desacoplado Shallow Routing:** Para mitigar la latencia de red y evitar sobrecargas en dispositivos moviles de taller en bahia o foso, las labores mecanicas se gestionan bajo una ruta de primer nivel (`/api/v1/tasks`) con un maximo estricto de dos niveles de anidamiento, desvinculando la navegacion operativa del identificador jerarquico de orden.
3. **Asignacion de Bahias Fisicas y Prevencion de Solapamiento:** Cada puesto fisico (elevador, foso, cabina) representa un recurso finito. El dominio impide rigurosamente que dos ordenes activas ocupen la misma bahia simultaneamente o que se asigne una bahia bajo mantenimiento tecnico preventivo.
4. **Separacion Pericial de Hallazgos y Aprobacion Comercial:** Los tecnicos mecanicos registran hallazgos periciales en foso sin incluir importes economicos, garantizando imparcialidad pericial. La valoracion comercial y concertacion con el cliente recae exclusivamente en el Asesor de Servicio antes de generar la tarea formal.
5. **Computo Riguroso de Mano de Obra y Horas Efectivas Wrench Time:** Las labores computan lapsos netos de trabajo en minutos o segundos, deduciendo pausas por falta de repuestos (ON_HOLD) para medir con exactitud la productividad real de foso.
6. **Trazabilidad Inmutable de Evidencias Direct-to-Cloud:** Las imagenes de recepcion pericial e intervenciones en foso se almacenan de manera directa en Firebase Storage mediante URLs firmadas HTTPS inmutables, salvaguardando la integridad pericial sin congestionar el backend.
7. **Estandar de Errores RFC 7807:** Toda anomalia tecnica o violacion de invariantes de dominio se proyecta bajo la estructura ProblemDetail estandarizada.

### 1.2. Catalogo Maestro de Endpoints de Workshop Operations

| No. | Seccion | Metodo | Ruta | Controlador | Metodo Java | Permiso Requerido |
| :---: | :---: | :---: | :--- | :--- | :--- | :--- |
| 1 | 2.1 | `POST` | `/api/v1/work-orders` | `WorkOrdersController` | `createWorkOrder()` | `@PreAuthorize("hasAuthority('operations:work_orders:create')")` |
| 2 | 2.2 | `GET` | `/api/v1/work-orders` | `WorkOrdersController` | `getWorkOrders()` | `@PreAuthorize("hasAuthority('operations:work_orders:read')")` |
| 3 | 2.3 | `GET` | `/api/v1/work-orders/{workOrderId}` | `WorkOrdersController` | `getWorkOrderById()` | `@PreAuthorize("hasAuthority('operations:work_orders:read')")` |
| 4 | 2.4 | `PUT` | `/api/v1/work-orders/{workOrderId}` | `WorkOrdersController` | `updateWorkOrder()` | `@PreAuthorize("hasAuthority('operations:work_orders:update')")` |
| 5 | 2.5 | `PUT` | `/api/v1/work-orders/{workOrderId}/bay` | `WorkOrdersController` | `assignBay()` | `@PreAuthorize("hasAuthority('operations:work_orders:update')")` |
| 6 | 2.6 | `DELETE` | `/api/v1/work-orders/{workOrderId}/bay` | `WorkOrdersController` | `releaseBay()` | `@PreAuthorize("hasAuthority('operations:work_orders:update')")` |
| 7 | 2.7 | `POST` | `/api/v1/work-orders/{workOrderId}/tasks` | `WorkOrdersController` | `addTask()` | `@PreAuthorize("hasAuthority('operations:work_orders:update')")` |
| 8 | 2.8 | `POST` | `/api/v1/work-orders/{workOrderId}/proposals` | `WorkOrdersController` | `submitProposal()` | `@PreAuthorize("hasAuthority('operations:proposals:create')")` |
| 9 | 2.9 | `GET` | `/api/v1/work-orders/{workOrderId}/proposals` | `WorkOrdersController` | `getProposals()` | `@PreAuthorize("hasAuthority('operations:proposals:read')")` |
| 10 | 2.10 | `POST` | `/api/v1/work-orders/{workOrderId}/proposals/{proposalId}/approve` | `WorkOrdersController` | `approveProposal()` | `@PreAuthorize("hasAuthority('operations:work_orders:update')")` |
| 11 | 2.11 | `POST` | `/api/v1/work-orders/{workOrderId}/proposals/{proposalId}/reject` | `WorkOrdersController` | `rejectProposal()` | `@PreAuthorize("hasAuthority('operations:work_orders:update')")` |
| 12 | 2.12 | `POST` | `/api/v1/work-orders/{workOrderId}/intake-images` | `WorkOrdersController` | `attachIntakeImage()` | `@PreAuthorize("hasAuthority('operations:work_orders:update')")` |
| 13 | 2.13 | `POST` | `/api/v1/work-orders/{workOrderId}/start` | `WorkOrdersController` | `startWorkOrder()` | `@PreAuthorize("hasAuthority('operations:work_orders:update')")` |
| 14 | 2.14 | `POST` | `/api/v1/work-orders/{workOrderId}/complete` | `WorkOrdersController` | `completeWorkOrder()` | `@PreAuthorize("hasAuthority('operations:work_orders:update')")` |
| 15 | 2.15 | `POST` | `/api/v1/work-orders/{workOrderId}/mark-as-paid` | `WorkOrdersController` | `markWorkOrderAsPaid()` | `@PreAuthorize("hasAuthority('operations:work_orders:update')")` |
| 16 | 2.16 | `POST` | `/api/v1/work-orders/{workOrderId}/cancel` | `WorkOrdersController` | `cancelWorkOrder()` | `@PreAuthorize("hasAuthority('operations:work_orders:cancel')")` |
| 17 | 3.1 | `GET` | `/api/v1/tasks/{taskId}` | `TasksController` | `getTaskById()` | `@PreAuthorize("hasAuthority('operations:tasks:read')")` |
| 18 | 3.2 | `PUT` | `/api/v1/tasks/{taskId}` | `TasksController` | `updateTask()` | `@PreAuthorize("hasAuthority('operations:tasks:update')")` |
| 19 | 3.3 | `POST` | `/api/v1/tasks/{taskId}/start` | `TasksController` | `startTask()` | `@PreAuthorize("hasAuthority('operations:tasks:track_time')")` |
| 20 | 3.4 | `POST` | `/api/v1/tasks/{taskId}/hold` | `TasksController` | `holdTask()` | `@PreAuthorize("hasAuthority('operations:tasks:track_time')")` |
| 21 | 3.5 | `POST` | `/api/v1/tasks/{taskId}/resume` | `TasksController` | `resumeTask()` | `@PreAuthorize("hasAuthority('operations:tasks:track_time')")` |
| 22 | 3.6 | `POST` | `/api/v1/tasks/{taskId}/complete` | `TasksController` | `completeTask()` | `@PreAuthorize("hasAuthority('operations:tasks:complete')")` |
| 23 | 3.7 | `POST` | `/api/v1/tasks/{taskId}/reopen` | `TasksController` | `reopenTask()` | `@PreAuthorize("hasAuthority('operations:tasks:update')")` |
| 24 | 3.8 | `POST` | `/api/v1/tasks/{taskId}/products` | `TasksController` | `addTaskProduct()` | `@PreAuthorize("hasAuthority('operations:tasks:update')")` |
| 25 | 3.9 | `PUT` | `/api/v1/tasks/{taskId}/products/{productId}` | `TasksController` | `updateTaskProduct()` | `@PreAuthorize("hasAuthority('operations:tasks:update')")` |
| 26 | 3.10 | `DELETE` | `/api/v1/tasks/{taskId}/products/{productId}` | `TasksController` | `removeTaskProduct()` | `@PreAuthorize("hasAuthority('operations:tasks:update')")` |
| 27 | 3.11 | `POST` | `/api/v1/tasks/{taskId}/evidence-images` | `TasksController` | `attachEvidenceImage()` | `@PreAuthorize("hasAuthority('operations:tasks:upload_photos')")` |
| 28 | 4.1 | `POST` | `/api/v1/work-bays` | `WorkBaysController` | `createWorkBay()` | `@PreAuthorize("hasAuthority('operations:bays:manage')")` |
| 29 | 4.2 | `GET` | `/api/v1/work-bays` | `WorkBaysController` | `getWorkBays()` | `@PreAuthorize("hasAuthority('operations:bays:read')")` |
| 30 | 4.3 | `GET` | `/api/v1/work-bays/{bayId}` | `WorkBaysController` | `getWorkBayById()` | `@PreAuthorize("hasAuthority('operations:bays:read')")` |
| 31 | 4.4 | `PUT` | `/api/v1/work-bays/{bayId}/maintenance` | `WorkBaysController` | `setBayMaintenance()` | `@PreAuthorize("hasAuthority('operations:bays:manage')")` |
| 32 | 4.5 | `PUT` | `/api/v1/work-bays/{bayId}/restore` | `WorkBaysController` | `restoreBay()` | `@PreAuthorize("hasAuthority('operations:bays:manage')")` |
| 33 | 5.1 | `POST` | `/api/v1/services` | `ServicesController` | `createService()` | `@PreAuthorize("hasAuthority('operations:services:manage')")` |
| 34 | 5.2 | `GET` | `/api/v1/services` | `ServicesController` | `getServices()` | `@PreAuthorize("hasAuthority('operations:services:read')")` |
| 35 | 5.3 | `GET` | `/api/v1/services/{serviceId}` | `ServicesController` | `getServiceById()` | `@PreAuthorize("hasAuthority('operations:services:read')")` |
| 36 | 5.4 | `PUT` | `/api/v1/services/{serviceId}` | `ServicesController` | `updateService()` | `@PreAuthorize("hasAuthority('operations:services:manage')")` |

---

## 2. Endpoints de Ordenes de Trabajo (WorkOrdersController)

### 2.1. [POST] /api/v1/work-orders

**Apertura de Nueva Orden de Trabajo de Reparacion**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.WorkOrdersController`
- **Metodo Java:** `public ResponseEntity<WorkOrderResource> createWorkOrder(@Valid @RequestBody CreateWorkOrderResource resource)`
- **Ruta Base:** `/api/v1/work-orders`
- **Ruta Completa:** `/api/v1/work-orders`
- **Proposito:** Registra la apertura formal de una orden de trabajo de mantenimiento automotriz en el taller. Asocia la orden a un vehiculo existente en CRM y opcionalmente a una cita previa. Registra el kilometraje verificado en recepcion y el diagnostico inicial reportado por el cliente, inicializando el estado de la orden en DRAFT con importe acumulado en cero.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:work_orders:create')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId resuelto desde el token JWT. La orden se registra con el tenantId del taller en sesion y valida que el vehiculo pertenezca a la custodia o registro del taller.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.requests.CreateWorkOrderResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| appointmentId | UUID | No | Sin validacion adicional | Identificador de la cita previa registrada en CRM (opcional) |
| vehicleId | UUID | Si | @NotNull(message = "El identificador del vehiculo es mandatorio") | Identificador universal del vehiculo que ingresa a reparacion |
| mileageIn | Integer | Si | @NotNull, @PositiveOrZero(message = "El kilometraje no puede ser negativo") | Lectura del odometro constatada fisicamente en la recepcion |
| diagnosticSummary | String | No | @Size(max = 2000, message = "El diagnostico de recepcion no puede superar 2000 caracteres") | Resumen pericial o sintomas declarados por el cliente |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "appointmentId": "018f6c40-7e12-7000-8000-000000000010",
  "vehicleId": "018f6c40-7e12-7000-8000-000000000020",
  "mileageIn": 64500,
  "diagnosticSummary": "Cliente reporta cascabeleo persistente en el eje delantero derecho al girar a la izquierda y chirrido agudo al frenar a baja velocidad."
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.WorkOrderResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico asignado a la orden de trabajo |
| tenantId | UUID | Identificador del taller automotriz propietario |
| internalNumber | Integer | Numero secuencial correlativo de la orden dentro del taller |
| vehicleId | UUID | Identificador del vehiculo ingresado |
| currentBayId | UUID | Identificador de la bahia fisica asignada (null al momento de la apertura) |
| mileageIn | Integer | Kilometraje de recepcion vehicular registrado |
| status | String | Estado operativo inicial de la orden (DRAFT) |
| totalAmount | BigDecimal | Monto acumulado total de la orden (0.00 al inicio) |
| currency | String | Codigo ISO de la moneda de cobro (PEN) |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000100",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "internalNumber": 1042,
  "vehicleId": "018f6c40-7e12-7000-8000-000000000020",
  "currentBayId": null,
  "mileageIn": 64500,
  "status": "DRAFT",
  "totalAmount": 0,
  "currency": "PEN"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 400 Bad Request | MethodArgumentNotValidException | Faltan campos obligatorios como vehicleId o el kilometraje es negativo |
| 400 Bad Request | InvalidMileageException | El kilometraje ingresado es inferior al ultimo odometro historico auditado |
| 404 Not Found | VehicleNotFoundException | El vehiculo especificado no existe en el registro del taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-mileage",
  "title": "Kilometraje de Ingreso Invalido",
  "status": 400,
  "detail": "El kilometraje indicado (64500) es menor al ultimo kilometraje registrado en auditoria (65200) para este vehiculo",
  "instance": "/api/v1/work-orders",
  "code": "INVALID_MILEAGE",
  "timestamp": "2026-10-03T10:15:30Z"
}
```

---

### 2.2. [GET] /api/v1/work-orders

**Consulta Paginada y Filtrada de Ordenes de Trabajo**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.WorkOrdersController`
- **Metodo Java:** `public ResponseEntity<PagedModel<WorkOrderSummaryResource>> getWorkOrders(@RequestParam(required = false) UUID branchId, @RequestParam(required = false) String status, @RequestParam(required = false) UUID vehicleId, @RequestParam(required = false) Instant from, @RequestParam(required = false) Instant to, @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "20") int size)`
- **Ruta Base:** `/api/v1/work-orders`
- **Ruta Completa:** `/api/v1/work-orders`
- **Proposito:** Retorna un listado paginado y enriquecido de las ordenes de trabajo de la sede del taller, permitiendo filtrar por sucursal fisica, estado del ciclo de vida, vehiculo especifico e intervalo temporal de creacion. Incluye el nombre descriptivo de la bahia fisica asignada.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:work_orders:read')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId obtenido del contexto de seguridad. Solo se proyectan ordenes correspondientes al taller autenticado.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
- `branchId` (UUID, Opcional): Filtro por identificador de sucursal fisica del taller
- `status` (String, Opcional): Filtro por estado de la orden (DRAFT, IN_PROGRESS, COMPLETED, PAID, CANCELLED)
- `vehicleId` (UUID, Opcional): Filtro por identificador unico de activo vehicular
- `from` (Instant, Opcional): Marca temporal ISO 8601 inicial del intervalo de consulta
- `to` (Instant, Opcional): Marca temporal ISO 8601 final del intervalo de consulta
- `page` (int, Opcional): Numero de pagina solicitada (base cero, por defecto 0)
- `size` (int, Opcional): Tamano maximo de pagina (por defecto 20 registros)

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `org.springframework.hateoas.PagedModel<com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.WorkOrderSummaryResource>`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la orden de trabajo |
| tenantId | UUID | Identificador del taller propietario |
| internalNumber | Integer | Numero secuencial correlativo de la orden |
| vehicleId | UUID | Identificador del vehiculo en reparacion |
| currentBayId | UUID | Identificador de la bahia ocupada o null |
| bayName | String | Nombre o codigo descriptivo de la bahia asignada |
| status | String | Estado operativo actual de la orden |
| totalAmount | BigDecimal | Monto acumulado total facturable |
| currency | String | Moneda de facturacion (PEN o USD) |
| createdAt | Instant | Marca temporal de creacion en formato ISO 8601 |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "content": [
    {
      "id": "018f6c40-7e12-7000-8000-000000000100",
      "tenantId": "018f6c40-7e12-7000-8000-000000000001",
      "internalNumber": 1042,
      "vehicleId": "018f6c40-7e12-7000-8000-000000000020",
      "currentBayId": "018f6c40-7e12-7000-8000-000000000301",
      "bayName": "Bahia 01 - Elevador Hidraulico Principal",
      "status": "IN_PROGRESS",
      "totalAmount": 485.5,
      "currency": "PEN",
      "createdAt": "2026-10-03T10:15:30Z"
    }
  ],
  "page": {
    "size": 20,
    "totalElements": 1,
    "totalPages": 1,
    "number": 0
  }
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 401 Unauthorized | BadCredentialsException | Token JWT ausente, expirado o con firma criptografica no valida |
| 403 Forbidden | AccessDeniedException | El usuario no posee el permiso atómico operations:work_orders:read |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/access-denied",
  "title": "Permiso Insuficiente",
  "status": 403,
  "detail": "No cuenta con el privilegio requerido operations:work_orders:read para listar ordenes de trabajo",
  "instance": "/api/v1/work-orders",
  "code": "ACCESS_DENIED",
  "timestamp": "2026-10-03T10:16:00Z"
}
```

---

### 2.3. [GET] /api/v1/work-orders/{workOrderId}

**Consulta Exhaustiva del Detalle de Orden de Trabajo**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.WorkOrdersController`
- **Metodo Java:** `public ResponseEntity<WorkOrderDetailResource> getWorkOrderById(@PathVariable UUID workOrderId)`
- **Ruta Base:** `/api/v1/work-orders`
- **Ruta Completa:** `/api/v1/work-orders/{workOrderId}`
- **Proposito:** Recupera la ficha completa y pormenorizada de una orden de trabajo. Proyecta las tareas autorizadas con sus mecanicos asignados y repuestos consumidos, el listado de propuestas periciales detectadas en foso y las evidencias fotograficas de recepcion registradas mediante Firebase Storage.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST), Mecanico (ROLE_MECHANIC) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:work_orders:read')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId. Si la orden existe pero pertenece a otro taller, el sistema responde 404 Not Found para prevenir enumeracion de recursos.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `workOrderId` (UUID): Identificador unico de la orden de trabajo consultada

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.WorkOrderDetailResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la orden de trabajo |
| tenantId | UUID | Identificador del taller propietario |
| internalNumber | Integer | Numero secuencial correlativo de taller |
| vehicleId | UUID | Identificador del vehiculo en reparacion |
| currentBayId | UUID | Identificador de la bahia fisica ocupada |
| bayName | String | Nombre descriptivo de la bahia de trabajo |
| mileageIn | Integer | Kilometraje verificado en recepcion |
| diagnosticSummary | String | Diagnostico inicial o sintomas declarados |
| status | String | Estado operativo de la orden |
| totalAmount | BigDecimal | Importe total consolidado |
| currency | String | Divisa monetaria de la orden |
| tasks | List<WorkOrderTaskResource> | Coleccion de labores tecnicas autorizadas |
| proposals | List<TaskProposalResource> | Coleccion de propuestas periciales formuladas en foso |
| intakeImages | List<WorkOrderImageResource> | Coleccion de fotografias periciales de recepcion |
| createdAt | Instant | Marca temporal de creacion |
| updatedAt | Instant | Marca temporal de ultima modificacion |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000100",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "internalNumber": 1042,
  "vehicleId": "018f6c40-7e12-7000-8000-000000000020",
  "currentBayId": "018f6c40-7e12-7000-8000-000000000301",
  "bayName": "Bahia 01 - Elevador Hidraulico Principal",
  "mileageIn": 64500,
  "diagnosticSummary": "Cliente reporta cascabeleo en tren delantero y chillido al frenar.",
  "status": "IN_PROGRESS",
  "totalAmount": 485.5,
  "currency": "PEN",
  "tasks": [
    {
      "id": "018f6c40-7e12-7000-8000-000000000201",
      "workOrderId": "018f6c40-7e12-7000-8000-000000000100",
      "serviceId": "018f6c40-7e12-7000-8000-000000000401",
      "serviceName": "Cambio de Pastillas de Freno Delanteras",
      "mechanicId": "018f6c40-7e12-7000-8000-000000000501",
      "mechanicName": "Juan Carlos Perez",
      "status": "IN_PROGRESS",
      "description": "Desmontaje de mordazas, rectificado ligero y colocacion de pastillas de freno nuevas.",
      "price": 120,
      "currency": "PEN",
      "holdReason": null,
      "missingItemDescription": null,
      "totalPausedSeconds": 0,
      "startedAt": "2026-10-03T10:30:00Z",
      "completedAt": null,
      "products": [
        {
          "id": "018f6c40-7e12-7000-8000-000000000601",
          "taskId": "018f6c40-7e12-7000-8000-000000000201",
          "productId": "018f6c40-7e12-7000-8000-000000000701",
          "productName": "Juego de Pastillas Ceramicas Delanteras Bosch",
          "quantity": 1,
          "unitPrice": 180,
          "totalAmount": 180,
          "currency": "PEN"
        }
      ],
      "evidenceImages": []
    }
  ],
  "proposals": [],
  "intakeImages": [
    {
      "id": "018f6c40-7e12-7000-8000-000000000801",
      "workOrderId": "018f6c40-7e12-7000-8000-000000000100",
      "imageUrl": "https://firebasestorage.googleapis.com/v0/b/atelier-app.appspot.com/o/tenants%2F018f6c40-7e12-7000-8000-000000000001%2Fwork-orders%2F1042%2Ffront-left.jpg?alt=media",
      "description": "Foto lateral delantera izquierda constatando raspadura previa en parachoque.",
      "uploadedAt": "2026-10-03T10:18:22Z"
    }
  ],
  "createdAt": "2026-10-03T10:15:30Z",
  "updatedAt": "2026-10-03T10:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 404 Not Found | WorkOrderNotFoundException | La orden de trabajo solicitada no existe o pertenece a otro taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/work-order-not-found",
  "title": "Orden de Trabajo No Encontrada",
  "status": 404,
  "detail": "No se encontro ninguna orden de trabajo con el identificador 018f6c40-7e12-7000-8000-000000000100",
  "instance": "/api/v1/work-orders/018f6c40-7e12-7000-8000-000000000100",
  "code": "WORK_ORDER_NOT_FOUND",
  "timestamp": "2026-10-03T10:35:00Z"
}
```

---

### 2.4. [PUT] /api/v1/work-orders/{workOrderId}

**Actualizacion de Diagnostico y Kilometraje de Recepcion**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.WorkOrdersController`
- **Metodo Java:** `public ResponseEntity<WorkOrderResource> updateWorkOrder(@PathVariable UUID workOrderId, @Valid @RequestBody UpdateWorkOrderResource resource)`
- **Ruta Base:** `/api/v1/work-orders`
- **Ruta Completa:** `/api/v1/work-orders/{workOrderId}`
- **Proposito:** Actualiza el kilometraje verificado o rectifica el resumen diagnostico de recepcion de una orden de trabajo activa. Impide la mutacion si la orden ya ha sido cancelada o pagada.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:work_orders:update')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del token JWT activo. Se restringe a la orden asociada al taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `workOrderId` (UUID): Identificador unico de la orden de trabajo a modificar

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.requests.UpdateWorkOrderResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| mileageIn | Integer | No | @PositiveOrZero(message = "El kilometraje no puede ser negativo") | Kilometraje rectificado del activo vehicular |
| diagnosticSummary | String | No | @Size(max = 2000, message = "El diagnostico no puede superar 2000 caracteres") | Resumen diagnostico ampliado o corregido |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "mileageIn": 64520,
  "diagnosticSummary": "Diagnostico ampliado: Se constata juego axial en terminal de direccion derecho y desgaste critico de pastillas delanteras al 10% de vida util."
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.WorkOrderResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la orden de trabajo |
| tenantId | UUID | Identificador del taller propietario |
| internalNumber | Integer | Numero secuencial correlativo de orden |
| vehicleId | UUID | Identificador del vehiculo |
| currentBayId | UUID | Identificador de bahia asignada |
| mileageIn | Integer | Kilometraje rectificado |
| status | String | Estado operativo de la orden |
| totalAmount | BigDecimal | Importe total consolidado |
| currency | String | Moneda de operacion |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000100",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "internalNumber": 1042,
  "vehicleId": "018f6c40-7e12-7000-8000-000000000020",
  "currentBayId": "018f6c40-7e12-7000-8000-000000000301",
  "mileageIn": 64520,
  "status": "IN_PROGRESS",
  "totalAmount": 485.5,
  "currency": "PEN"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 400 Bad Request | InvalidMileageException | El kilometraje es negativo o presenta inconsistencia respecto al odometro auditado |
| 404 Not Found | WorkOrderNotFoundException | La orden de trabajo no existe en el taller |
| 422 Unprocessable Entity | InvalidWorkOrderStatusTransitionException | La orden se encuentra cerrada o cancelada e impide modificaciones |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-work-order-status-transition",
  "title": "Transicion de Estado No Permitida",
  "status": 422,
  "detail": "No se puede actualizar los datos de recepcion de una orden en estado COMPLETED",
  "instance": "/api/v1/work-orders/018f6c40-7e12-7000-8000-000000000100",
  "code": "INVALID_WORK_ORDER_STATUS_TRANSITION",
  "timestamp": "2026-10-03T10:40:00Z"
}
```

---

### 2.5. [PUT] /api/v1/work-orders/{workOrderId}/bay

**Asignacion o Reubicacion Fisica de Bahia de Trabajo**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.WorkOrdersController`
- **Metodo Java:** `public ResponseEntity<WorkOrderResource> assignBay(@PathVariable UUID workOrderId, @Valid @RequestBody AssignWorkBayResource resource)`
- **Ruta Base:** `/api/v1/work-orders`
- **Ruta Completa:** `/api/v1/work-orders/{workOrderId}/bay`
- **Proposito:** Asigna o reubica el vehiculo asociado a la orden de trabajo en una bahia fisica operativa disponible. Si la bahia se encuentra ocupada por otro vehiculo o bajo mantenimiento, se aborta la operacion rechazando el solapamiento de infraestructura.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Jefe de Taller (ROLE_WORKSHOP_MANAGER) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:work_orders:update')")`
- **Aislamiento Multi-Inquilino:** Valida que tanto la orden de trabajo como la bahia fisica correspondan al mismo tenantId del taller.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `workOrderId` (UUID): Identificador unico de la orden de trabajo

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.requests.AssignWorkBayResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| bayId | UUID | Si | @NotNull(message = "El identificador de la bahia es mandatorio") | Identificador de la bahia fisica a la cual se asigna la orden |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "bayId": "018f6c40-7e12-7000-8000-000000000301"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.WorkOrderResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la orden de trabajo |
| tenantId | UUID | Identificador del taller |
| internalNumber | Integer | Numero secuencial correlativo |
| vehicleId | UUID | Identificador del vehiculo |
| currentBayId | UUID | Identificador de la nueva bahia fisica asignada |
| mileageIn | Integer | Kilometraje de recepcion |
| status | String | Estado operativo de la orden |
| totalAmount | BigDecimal | Importe acumulado |
| currency | String | Divisa monetaria |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000100",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "internalNumber": 1042,
  "vehicleId": "018f6c40-7e12-7000-8000-000000000020",
  "currentBayId": "018f6c40-7e12-7000-8000-000000000301",
  "mileageIn": 64500,
  "status": "IN_PROGRESS",
  "totalAmount": 485.5,
  "currency": "PEN"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 404 Not Found | WorkOrderNotFoundException | La orden de trabajo no existe |
| 404 Not Found | WorkBayNotFoundException | La bahia fisica solicitada no existe en la sede |
| 409 Conflict | WorkBayOccupiedException | La bahia ya se encuentra ocupada por otro automovil en atencion |
| 409 Conflict | WorkBayUnderMaintenanceException | La bahia fisica se encuentra fuera de servicio por mantenimiento |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/work-bay-occupied",
  "title": "Bahia de Trabajo Ocupada",
  "status": 409,
  "detail": "La bahia Bahia 01 - Elevador Hidraulico Principal ya se encuentra asignada a la orden 1039",
  "instance": "/api/v1/work-orders/018f6c40-7e12-7000-8000-000000000100/bay",
  "code": "WORK_BAY_OCCUPIED",
  "timestamp": "2026-10-03T10:42:00Z"
}
```

---

### 2.6. [DELETE] /api/v1/work-orders/{workOrderId}/bay

**Liberacion de Bahia de Trabajo Actual**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.WorkOrdersController`
- **Metodo Java:** `public ResponseEntity<Void> releaseBay(@PathVariable UUID workOrderId)`
- **Ruta Base:** `/api/v1/work-orders`
- **Ruta Completa:** `/api/v1/work-orders/{workOrderId}/bay`
- **Proposito:** Libera la bahia fisica asignada a la orden de trabajo, restaurando el puesto de trabajo al estado AVAILABLE para albergar otros vehiculos. La orden preserva su estado operativo desvinculandose de la infraestructura.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Jefe de Taller (ROLE_WORKSHOP_MANAGER) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:work_orders:update')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller activo.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `workOrderId` (UUID): Identificador unico de la orden de trabajo cuya bahia se libera

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `204 No Content`
**Cuerpo de Respuesta:** Sin contenido en el cuerpo de respuesta (HTTP 204 No Content).

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 404 Not Found | WorkOrderNotFoundException | La orden de trabajo no existe en el taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/work-order-not-found",
  "title": "Orden de Trabajo No Encontrada",
  "status": 404,
  "detail": "No se encontro la orden especificada para liberar la bahia fisica",
  "instance": "/api/v1/work-orders/018f6c40-7e12-7000-8000-000000000100/bay",
  "code": "WORK_ORDER_NOT_FOUND",
  "timestamp": "2026-10-03T10:45:00Z"
}
```

---

### 2.7. [POST] /api/v1/work-orders/{workOrderId}/tasks

**Incorporacion de Labor Formal Autorizada en la Orden**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.WorkOrdersController`
- **Metodo Java:** `public ResponseEntity<WorkOrderTaskResource> addTask(@PathVariable UUID workOrderId, @Valid @RequestBody CreateWorkOrderTaskResource resource)`
- **Ruta Base:** `/api/v1/work-orders`
- **Ruta Completa:** `/api/v1/work-orders/{workOrderId}/tasks`
- **Proposito:** Incorpora una nueva labor tecnica autorizada por el Asesor de Servicio a la orden de trabajo. Vincula el servicio al catalogo maestro, asigna al tecnico mecanico responsable y fija el precio de mano de obra pactado. Inicializa la tarea en estado ASSIGNED (o PENDING si no tuviera mecanico asignado).

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:work_orders:update')")`
- **Aislamiento Multi-Inquilino:** Valida que la orden y el servicio tarifario pertenezcan al mismo tenantId del taller.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `workOrderId` (UUID): Identificador unico de la orden de trabajo

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.requests.CreateWorkOrderTaskResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| serviceId | UUID | Si | @NotNull(message = "El identificador del servicio tarifario es obligatorio") | Identificador del servicio en catalogo maestro |
| mechanicId | UUID | Si | @NotNull(message = "El identificador del tecnico mecanico es mandatorio") | Identificador del colaborador asignado como tecnico |
| description | String | Si | @NotBlank, @Size(max = 1000) | Descripcion detallada de la intervencion mecanica autorizada |
| price | BigDecimal | Si | @NotNull, @Positive | Tarifa de mano de obra acordada para la tarea |
| currency | String | Si | @NotBlank, @Pattern(regexp = "PEN|USD") | Codigo ISO de la moneda de facturacion |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "serviceId": "018f6c40-7e12-7000-8000-000000000401",
  "mechanicId": "018f6c40-7e12-7000-8000-000000000501",
  "description": "Desmontaje de mordazas, rectificado de discos delanteros y purgado del sistema hidraulico de frenos.",
  "price": 150,
  "currency": "PEN"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.WorkOrderTaskResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la labor mecanica generada |
| workOrderId | UUID | Identificador de la orden de trabajo contenedora |
| serviceId | UUID | Identificador del servicio de catalogo |
| serviceName | String | Nombre del servicio estandar |
| mechanicId | UUID | Identificador del mecanico asignado |
| mechanicName | String | Nombres y apellidos del mecanico |
| status | String | Estado operativo de la tarea (ASSIGNED) |
| description | String | Descripcion tecnica de la labor |
| price | BigDecimal | Tarifa de mano de obra fijada |
| currency | String | Moneda de la labor |
| holdReason | String | Motivo de pausa (null al crear) |
| missingItemDescription | String | Descripcion de repuesto faltante (null al crear) |
| totalPausedSeconds | Long | Segundos acumulados en pausa (0 inicial) |
| startedAt | Instant | Marca temporal de inicio (null al crear) |
| completedAt | Instant | Marca temporal de cierre (null al crear) |
| products | List<TaskProductResource> | Coleccion de repuestos asociados |
| evidenceImages | List<WorkOrderTaskImageResource> | Coleccion de fotos periciales |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000201",
  "workOrderId": "018f6c40-7e12-7000-8000-000000000100",
  "serviceId": "018f6c40-7e12-7000-8000-000000000401",
  "serviceName": "Mantenimiento Integral de Frenos Delanteros",
  "mechanicId": "018f6c40-7e12-7000-8000-000000000501",
  "mechanicName": "Juan Carlos Perez",
  "status": "ASSIGNED",
  "description": "Desmontaje de mordazas, rectificado de discos delanteros y purgado del sistema hidraulico de frenos.",
  "price": 150,
  "currency": "PEN",
  "holdReason": null,
  "missingItemDescription": null,
  "totalPausedSeconds": 0,
  "startedAt": null,
  "completedAt": null,
  "products": [],
  "evidenceImages": []
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 404 Not Found | WorkOrderNotFoundException | La orden de trabajo no existe |
| 404 Not Found | ServiceNotFoundException | El servicio de catalogo especificado no existe en el taller |
| 422 Unprocessable Entity | InvalidWorkOrderStatusTransitionException | No se pueden incorporar tareas a una orden cerrada o cancelada |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/service-not-found",
  "title": "Servicio de Catalogo No Encontrado",
  "status": 404,
  "detail": "No se localizo el servicio con identificador 018f6c40-7e12-7000-8000-000000000401 en el tarifario",
  "instance": "/api/v1/work-orders/018f6c40-7e12-7000-8000-000000000100/tasks",
  "code": "SERVICE_NOT_FOUND",
  "timestamp": "2026-10-03T10:50:00Z"
}
```

---

### 2.8. [POST] /api/v1/work-orders/{workOrderId}/proposals

**Registro de Hallazgo Pericial o Propuesta Tecnica en Foso**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.WorkOrdersController`
- **Metodo Java:** `public ResponseEntity<TaskProposalResource> submitProposal(@PathVariable UUID workOrderId, @Valid @RequestBody SubmitTaskProposalResource resource)`
- **Ruta Base:** `/api/v1/work-orders`
- **Ruta Completa:** `/api/v1/work-orders/{workOrderId}/proposals`
- **Proposito:** Permite al tecnico mecanico registrar un hallazgo pericial o averia oculta descubierta durante la inspeccion en elevador o foso. El registro no incluye cotizacion economica ya que esta es potestad del Asesor de Servicio. Se adjunta evidencia fotografica pericial obligatoria y nivel de severidad tecnica.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Mecanico (ROLE_MECHANIC) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:proposals:create')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `workOrderId` (UUID): Identificador unico de la orden de trabajo

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.requests.SubmitTaskProposalResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| mechanicId | UUID | Si | @NotNull(message = "El identificador del mecanico es obligatorio") | Identificador del mecanico que detecto el hallazgo |
| description | String | Si | @NotBlank, @Size(max = 2000) | Detalle tecnico pericial del dano o falla descubierta |
| severity | String | Si | @NotBlank, @Pattern(regexp = "LOW|MEDIUM|CRITICAL") | Nivel de criticidad tecnica del hallazgo |
| imageUrl | String | Si | @NotBlank, @URL | URL segura HTTPS de la foto pericial en Firebase Storage |
| suggestedServiceId | UUID | No | Sin validacion adicional | Servicio sugerido del catalogo para reparar la averia |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "mechanicId": "018f6c40-7e12-7000-8000-000000000501",
  "description": "Se detecta rotura completa del guardapolvo del palier derecho con fuga total de grasa grafitada y principio de corrosion en junta homocinetica.",
  "severity": "CRITICAL",
  "imageUrl": "https://firebasestorage.googleapis.com/v0/b/atelier-app.appspot.com/o/tenants%2F018f6c40-7e12-7000-8000-000000000001%2Fproposals%2Fpalier-danado.jpg?alt=media",
  "suggestedServiceId": "018f6c40-7e12-7000-8000-000000000405"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.TaskProposalResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la propuesta pericial |
| workOrderId | UUID | Identificador de la orden de trabajo |
| taskId | UUID | Identificador de la tarea formal generada tras aprobacion (null al crear) |
| serviceId | UUID | Identificador del servicio sugerido o asignado |
| serviceName | String | Nombre del servicio sugerido |
| mechanicId | UUID | Identificador del tecnico proponente |
| mechanicName | String | Nombres y apellidos del tecnico |
| description | String | Descripcion del hallazgo pericial |
| severity | String | Criticidad tecnica (LOW, MEDIUM, CRITICAL) |
| imageUrl | String | URL pericial de almacenamiento seguro |
| status | String | Estado de la propuesta (SUBMITTED) |
| customerNotes | String | Notas de respuesta del cliente (null al crear) |
| createdAt | Instant | Marca temporal de formulacion |
| updatedAt | Instant | Marca temporal de actualizacion |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000901",
  "workOrderId": "018f6c40-7e12-7000-8000-000000000100",
  "taskId": null,
  "serviceId": "018f6c40-7e12-7000-8000-000000000405",
  "serviceName": "Reemplazo de Fuelle y Mantenimiento de Junta Homocinetica",
  "mechanicId": "018f6c40-7e12-7000-8000-000000000501",
  "mechanicName": "Juan Carlos Perez",
  "description": "Se detecta rotura completa del guardapolvo del palier derecho con fuga total de grasa grafitada y principio de corrosion en junta homocinetica.",
  "severity": "CRITICAL",
  "imageUrl": "https://firebasestorage.googleapis.com/v0/b/atelier-app.appspot.com/o/tenants%2F018f6c40-7e12-7000-8000-000000000001%2Fproposals%2Fpalier-danado.jpg?alt=media",
  "status": "SUBMITTED",
  "customerNotes": null,
  "createdAt": "2026-10-03T10:55:00Z",
  "updatedAt": "2026-10-03T10:55:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 400 Bad Request | InvalidStorageUrlException | La URL de imagen no proviene de un origen HTTPS autorizado de Firebase Storage |
| 404 Not Found | WorkOrderNotFoundException | La orden de trabajo no existe en el taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-storage-url",
  "title": "URL de Fotografia Invalida",
  "status": 400,
  "detail": "La URL proporcionada no cumple con las directivas de seguridad para Firebase Storage",
  "instance": "/api/v1/work-orders/018f6c40-7e12-7000-8000-000000000100/proposals",
  "code": "INVALID_STORAGE_URL",
  "timestamp": "2026-10-03T10:56:00Z"
}
```

---

### 2.9. [GET] /api/v1/work-orders/{workOrderId}/proposals

**Listado de Propuestas Tecnicas y Hallazgos Periciales**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.WorkOrdersController`
- **Metodo Java:** `public ResponseEntity<List<TaskProposalResource>> getProposals(@PathVariable UUID workOrderId)`
- **Ruta Base:** `/api/v1/work-orders`
- **Ruta Completa:** `/api/v1/work-orders/{workOrderId}/proposals`
- **Proposito:** Retorna el conjunto de propuestas tecnicas y averias periciales formuladas durante la atencion de la orden de trabajo, permitiendo auditar el estado de aprobacion o rechazo de cada hallazgo.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Mecanico (ROLE_MECHANIC), Recepcionista (ROLE_RECEPTIONIST) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:proposals:read')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `workOrderId` (UUID): Identificador unico de la orden de trabajo

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `java.util.List<com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.TaskProposalResource>`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la propuesta |
| workOrderId | UUID | Identificador de la orden de trabajo |
| taskId | UUID | Identificador de la tarea formal generada |
| serviceId | UUID | Identificador del servicio asociado |
| serviceName | String | Nombre del servicio |
| mechanicId | UUID | Identificador del mecanico proponente |
| mechanicName | String | Nombres del mecanico |
| description | String | Detalle pericial del hallazgo |
| severity | String | Severidad tecnica (LOW, MEDIUM, CRITICAL) |
| imageUrl | String | URL pericial en Firebase Storage |
| status | String | Estado resolutivo (SUBMITTED, APPROVED, REJECTED) |
| customerNotes | String | Notas del cliente o motivo de desestimacion |
| createdAt | Instant | Marca temporal de creacion |
| updatedAt | Instant | Marca temporal de resolucion |

**Ejemplo de Carga Util JSON (Response):**
```json
[
  {
    "id": "018f6c40-7e12-7000-8000-000000000901",
    "workOrderId": "018f6c40-7e12-7000-8000-000000000100",
    "taskId": null,
    "serviceId": "018f6c40-7e12-7000-8000-000000000405",
    "serviceName": "Reemplazo de Fuelle y Mantenimiento de Junta Homocinetica",
    "mechanicId": "018f6c40-7e12-7000-8000-000000000501",
    "mechanicName": "Juan Carlos Perez",
    "description": "Se detecta rotura completa del guardapolvo del palier derecho con fuga total de grasa grafitada.",
    "severity": "CRITICAL",
    "imageUrl": "https://firebasestorage.googleapis.com/v0/b/atelier-app.appspot.com/o/tenants%2F018f6c40-7e12-7000-8000-000000000001%2Fproposals%2Fpalier-danado.jpg?alt=media",
    "status": "SUBMITTED",
    "customerNotes": null,
    "createdAt": "2026-10-03T10:55:00Z",
    "updatedAt": "2026-10-03T10:55:00Z"
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 404 Not Found | WorkOrderNotFoundException | La orden de trabajo no existe |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/work-order-not-found",
  "title": "Orden de Trabajo No Encontrada",
  "status": 404,
  "detail": "No se encontro la orden especificada para consultar propuestas",
  "instance": "/api/v1/work-orders/018f6c40-7e12-7000-8000-000000000100/proposals",
  "code": "WORK_ORDER_NOT_FOUND",
  "timestamp": "2026-10-03T11:00:00Z"
}
```

---

### 2.10. [POST] /api/v1/work-orders/{workOrderId}/proposals/{proposalId}/approve

**Aprobacion Formal de Propuesta y Creacion de Tarea Mecanica**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.WorkOrdersController`
- **Metodo Java:** `public ResponseEntity<WorkOrderTaskResource> approveProposal(@PathVariable UUID workOrderId, @PathVariable UUID proposalId, @Valid @RequestBody ApproveTaskProposalResource resource)`
- **Ruta Base:** `/api/v1/work-orders`
- **Ruta Completa:** `/api/v1/work-orders/{workOrderId}/proposals/{proposalId}/approve`
- **Proposito:** Procesa la resolucion formal aprobatoria de un hallazgo pericial tras concertacion comercial con el cliente. El Asesor de Servicio fija el precio final pactado, las horas estimadas y el servicio tarifario formal. Instancia automaticamente una nueva tarea mecanica formal WorkOrderTask en estado ASSIGNED vinculada a la orden.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:work_orders:update')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `workOrderId` (UUID): Identificador unico de la orden de trabajo
- `proposalId` (UUID): Identificador unico de la propuesta tecnica a aprobar

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.requests.ApproveTaskProposalResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| serviceId | UUID | Si | @NotNull(message = "El servicio tarifario formal es obligatorio") | Identificador del servicio formal en catalogo |
| finalPrice | BigDecimal | Si | @NotNull, @Positive | Precio total de mano de obra acordado con el cliente |
| laborHours | BigDecimal | Si | @NotNull, @Positive | Horas estimadas autorizadas para la intervencion |
| mechanicId | UUID | No | Sin validacion adicional | Identificador del mecanico asignado para ejecutarla |
| notes | String | No | @Size(max = 1000) | Notas de concertacion telefonica o presencial con el cliente |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "serviceId": "018f6c40-7e12-7000-8000-000000000405",
  "finalPrice": 180,
  "laborHours": 2,
  "mechanicId": "018f6c40-7e12-7000-8000-000000000501",
  "notes": "Cliente autorizo telefonicamente el reemplazo del guardapolvo tras explicarle el riesgo inminente de traba del palier."
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.WorkOrderTaskResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador de la nueva tarea formal creada |
| workOrderId | UUID | Identificador de la orden de trabajo |
| serviceId | UUID | Identificador del servicio tarifario |
| serviceName | String | Nombre del servicio estandar |
| mechanicId | UUID | Identificador del mecanico asignado |
| mechanicName | String | Nombres del mecanico |
| status | String | Estado de la tarea (ASSIGNED) |
| description | String | Descripcion tecnica derivada del hallazgo |
| price | BigDecimal | Tarifa aprobada |
| currency | String | Moneda acordada |
| holdReason | String | Motivo de suspension (null) |
| missingItemDescription | String | Repuesto faltante (null) |
| totalPausedSeconds | Long | Segundos en pausa (0) |
| startedAt | Instant | Marca de inicio (null) |
| completedAt | Instant | Marca de cierre (null) |
| products | List<TaskProductResource> | Repuestos de la tarea |
| evidenceImages | List<WorkOrderTaskImageResource> | Evidencias periciales asociadas |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000202",
  "workOrderId": "018f6c40-7e12-7000-8000-000000000100",
  "serviceId": "018f6c40-7e12-7000-8000-000000000405",
  "serviceName": "Reemplazo de Fuelle y Mantenimiento de Junta Homocinetica",
  "mechanicId": "018f6c40-7e12-7000-8000-000000000501",
  "mechanicName": "Juan Carlos Perez",
  "status": "ASSIGNED",
  "description": "Reemplazo de fuelle de palier derecho por rotura pericial constatada en foso.",
  "price": 180,
  "currency": "PEN",
  "holdReason": null,
  "missingItemDescription": null,
  "totalPausedSeconds": 0,
  "startedAt": null,
  "completedAt": null,
  "products": [],
  "evidenceImages": []
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 404 Not Found | TaskProposalNotFoundException | La propuesta pericial no existe en la orden indicada |
| 404 Not Found | ServiceNotFoundException | El servicio formal de catalogo no existe |
| 409 Conflict | TaskProposalAlreadyProcessedException | La propuesta ya fue resuelta previamente (APPROVED o REJECTED) |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/task-proposal-already-processed",
  "title": "Propuesta Previamente Procesada",
  "status": 409,
  "detail": "La propuesta pericial 018f6c40-7e12-7000-8000-000000000901 ya posee el estado APPROVED",
  "instance": "/api/v1/work-orders/018f6c40-7e12-7000-8000-000000000100/proposals/018f6c40-7e12-7000-8000-000000000901/approve",
  "code": "TASK_PROPOSAL_ALREADY_PROCESSED",
  "timestamp": "2026-10-03T11:05:00Z"
}
```

---

### 2.11. [POST] /api/v1/work-orders/{workOrderId}/proposals/{proposalId}/reject

**Desestimacion y Rechazo de Propuesta Tecnica por el Cliente**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.WorkOrdersController`
- **Metodo Java:** `public ResponseEntity<TaskProposalResource> rejectProposal(@PathVariable UUID workOrderId, @PathVariable UUID proposalId, @Valid @RequestBody RejectTaskProposalResource resource)`
- **Ruta Base:** `/api/v1/work-orders`
- **Ruta Completa:** `/api/v1/work-orders/{workOrderId}/proposals/{proposalId}/reject`
- **Proposito:** Registra la decision del cliente de no autorizar la reparacion del hallazgo pericial. Almacena obligatoriamente los argumentos o motivos expresados por el conductor, archivando la propuesta en estado REJECTED en el historial pericial del vehiculo para salvaguarda de responsabilidad tecnica del taller.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:work_orders:update')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `workOrderId` (UUID): Identificador unico de la orden de trabajo
- `proposalId` (UUID): Identificador unico de la propuesta pericial a desestimar

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.requests.RejectTaskProposalResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| customerNotes | String | Si | @NotBlank, @Size(max = 1000) | Motivo formal expresado por el cliente para rechazar la propuesta |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "customerNotes": "Cliente manifesto no contar con presupuesto adicional en este momento. Se le advierte que el vehiculo no debe circular en carretera."
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.TaskProposalResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la propuesta pericial |
| workOrderId | UUID | Identificador de la orden de trabajo |
| taskId | UUID | Identificador de tarea formal (null) |
| serviceId | UUID | Identificador de servicio |
| serviceName | String | Nombre del servicio |
| mechanicId | UUID | Identificador del tecnico proponente |
| mechanicName | String | Nombres del mecanico |
| description | String | Descripcion del hallazgo |
| severity | String | Severidad tecnica |
| imageUrl | String | URL pericial en Firebase Storage |
| status | String | Estado resolutivo de la propuesta (REJECTED) |
| customerNotes | String | Motivo formal expresado por el cliente |
| createdAt | Instant | Marca temporal de creacion |
| updatedAt | Instant | Marca temporal de desestimacion |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000901",
  "workOrderId": "018f6c40-7e12-7000-8000-000000000100",
  "taskId": null,
  "serviceId": "018f6c40-7e12-7000-8000-000000000405",
  "serviceName": "Reemplazo de Fuelle y Mantenimiento de Junta Homocinetica",
  "mechanicId": "018f6c40-7e12-7000-8000-000000000501",
  "mechanicName": "Juan Carlos Perez",
  "description": "Se detecta rotura completa del guardapolvo del palier derecho.",
  "severity": "CRITICAL",
  "imageUrl": "https://firebasestorage.googleapis.com/v0/b/atelier-app.appspot.com/o/tenants%2F018f6c40-7e12-7000-8000-000000000001%2Fproposals%2Fpalier-danado.jpg?alt=media",
  "status": "REJECTED",
  "customerNotes": "Cliente manifesto no contar con presupuesto adicional en este momento. Se le advierte que el vehiculo no debe circular en carretera.",
  "createdAt": "2026-10-03T10:55:00Z",
  "updatedAt": "2026-10-03T11:10:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 404 Not Found | TaskProposalNotFoundException | La propuesta pericial no existe en la orden |
| 409 Conflict | TaskProposalAlreadyProcessedException | La propuesta ya fue resuelta previamente |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/task-proposal-already-processed",
  "title": "Propuesta Previamente Procesada",
  "status": 409,
  "detail": "La propuesta pericial ya habia sido rechazada previamente",
  "instance": "/api/v1/work-orders/018f6c40-7e12-7000-8000-000000000100/proposals/018f6c40-7e12-7000-8000-000000000901/reject",
  "code": "TASK_PROPOSAL_ALREADY_PROCESSED",
  "timestamp": "2026-10-03T11:11:00Z"
}
```

---

### 2.12. [POST] /api/v1/work-orders/{workOrderId}/intake-images

**Registro de Fotografias Periciales de Recepcion Vehicular**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.WorkOrdersController`
- **Metodo Java:** `public ResponseEntity<WorkOrderImageResource> attachIntakeImage(@PathVariable UUID workOrderId, @Valid @RequestBody AttachImageResource resource)`
- **Ruta Base:** `/api/v1/work-orders`
- **Ruta Completa:** `/api/v1/work-orders/{workOrderId}/intake-images`
- **Proposito:** Registra los metadatos y URL segura de una fotografia pericial capturada durante el inventario y recepcion 360 grados del vehiculo. Sigue el patron Direct-to-Cloud donde la aplicacion movil sube directamente la imagen binaria a Firebase Storage y este endpoint asocia la URL inmutable al expediente de la orden.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:work_orders:update')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `workOrderId` (UUID): Identificador unico de la orden de trabajo

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.requests.AttachImageResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| imageUrl | String | Si | @NotBlank, @URL | URL segura HTTPS de la imagen subida en Firebase Storage |
| description | String | No | @Size(max = 500) | Descripcion o angulo del activo vehicular registrado |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "imageUrl": "https://firebasestorage.googleapis.com/v0/b/atelier-app.appspot.com/o/tenants%2F018f6c40-7e12-7000-8000-000000000001%2Fwork-orders%2F1042%2Frear-bumper.jpg?alt=media",
  "description": "Foto lateral trasera derecha constatando desprendimiento de grapa de moldura."
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.WorkOrderImageResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico del registro de imagen |
| workOrderId | UUID | Identificador de la orden de trabajo asociada |
| imageUrl | String | URL HTTPS inmutable de almacenamiento seguro |
| description | String | Descripcion o angulo pericial registrado |
| uploadedAt | Instant | Marca temporal de subida e indexacion |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000802",
  "workOrderId": "018f6c40-7e12-7000-8000-000000000100",
  "imageUrl": "https://firebasestorage.googleapis.com/v0/b/atelier-app.appspot.com/o/tenants%2F018f6c40-7e12-7000-8000-000000000001%2Fwork-orders%2F1042%2Frear-bumper.jpg?alt=media",
  "description": "Foto lateral trasera derecha constatando desprendimiento de grapa de moldura.",
  "uploadedAt": "2026-10-03T11:15:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 400 Bad Request | InvalidStorageUrlException | La URL no satisface el protocolo HTTPS o no proviene del dominio autorizado |
| 404 Not Found | WorkOrderNotFoundException | La orden de trabajo no existe |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-storage-url",
  "title": "URL de Almacenamiento Invalida",
  "status": 400,
  "detail": "La URL especificada no corresponde a una ruta autorizada de Firebase Storage",
  "instance": "/api/v1/work-orders/018f6c40-7e12-7000-8000-000000000100/intake-images",
  "code": "INVALID_STORAGE_URL",
  "timestamp": "2026-10-03T11:16:00Z"
}
```

---

### 2.13. [POST] /api/v1/work-orders/{workOrderId}/start

**Transicion Formal de la Orden al Estado en Progreso**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.WorkOrdersController`
- **Metodo Java:** `public ResponseEntity<WorkOrderResource> startWorkOrder(@PathVariable UUID workOrderId)`
- **Ruta Base:** `/api/v1/work-orders`
- **Ruta Completa:** `/api/v1/work-orders/{workOrderId}/start`
- **Proposito:** Transiciona formalmente la orden de trabajo del estado DRAFT al estado IN_PROGRESS. Valida que la orden cuente al menos con una tarea mecanica incorporada y que el vehiculo tenga una bahia fisica asignada, habilitando el inicio de cronometraje en foso.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Jefe de Taller (ROLE_WORKSHOP_MANAGER) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:work_orders:update')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `workOrderId` (UUID): Identificador unico de la orden de trabajo a iniciar

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.WorkOrderResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la orden de trabajo |
| tenantId | UUID | Identificador del taller |
| internalNumber | Integer | Numero secuencial de orden |
| vehicleId | UUID | Identificador del vehiculo |
| currentBayId | UUID | Identificador de la bahia fisica asignada |
| mileageIn | Integer | Kilometraje de recepcion |
| status | String | Nuevo estado operativo (IN_PROGRESS) |
| totalAmount | BigDecimal | Importe total acumulado |
| currency | String | Moneda de operacion |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000100",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "internalNumber": 1042,
  "vehicleId": "018f6c40-7e12-7000-8000-000000000020",
  "currentBayId": "018f6c40-7e12-7000-8000-000000000301",
  "mileageIn": 64500,
  "status": "IN_PROGRESS",
  "totalAmount": 330,
  "currency": "PEN"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 404 Not Found | WorkOrderNotFoundException | La orden de trabajo no existe |
| 422 Unprocessable Entity | InvalidWorkOrderStatusTransitionException | La orden no se encuentra en estado DRAFT o carece de tareas y bahia asignada |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-work-order-status-transition",
  "title": "Transicion de Estado No Permitida",
  "status": 422,
  "detail": "No se puede iniciar la orden porque no tiene asignada ninguna bahia de trabajo fisica",
  "instance": "/api/v1/work-orders/018f6c40-7e12-7000-8000-000000000100/start",
  "code": "INVALID_WORK_ORDER_STATUS_TRANSITION",
  "timestamp": "2026-10-03T11:20:00Z"
}
```

---

### 2.14. [POST] /api/v1/work-orders/{workOrderId}/complete

**Cierre Tecnico de la Orden de Trabajo**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.WorkOrdersController`
- **Metodo Java:** `public ResponseEntity<WorkOrderResource> completeWorkOrder(@PathVariable UUID workOrderId)`
- **Ruta Base:** `/api/v1/work-orders`
- **Ruta Completa:** `/api/v1/work-orders/{workOrderId}/complete`
- **Proposito:** Ejecuta el cierre tecnico de la orden de trabajo tras verificar que todas las tareas mecanicas han alcanzado el estado COMPLETED y no existen propuestas periciales pendientes de resolucion. Consolida los importes de mano de obra y repuestos, libera automaticamente la bahia fisica y transiciona la orden a COMPLETED.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Jefe de Taller (ROLE_WORKSHOP_MANAGER) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:work_orders:update')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `workOrderId` (UUID): Identificador unico de la orden de trabajo a culminar

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.WorkOrderResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la orden de trabajo |
| tenantId | UUID | Identificador del taller |
| internalNumber | Integer | Numero secuencial correlativo |
| vehicleId | UUID | Identificador del vehiculo |
| currentBayId | UUID | Identificador de bahia (liberada a null) |
| mileageIn | Integer | Kilometraje de recepcion |
| status | String | Nuevo estado operativo (COMPLETED) |
| totalAmount | BigDecimal | Importe final consolidado |
| currency | String | Moneda de facturacion |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000100",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "internalNumber": 1042,
  "vehicleId": "018f6c40-7e12-7000-8000-000000000020",
  "currentBayId": null,
  "mileageIn": 64500,
  "status": "COMPLETED",
  "totalAmount": 510,
  "currency": "PEN"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 404 Not Found | WorkOrderNotFoundException | La orden de trabajo no existe |
| 422 Unprocessable Entity | InvalidWorkOrderStatusTransitionException | Existen tareas mecanicas aun en progreso o propuestas periciales sin resolver |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-work-order-status-transition",
  "title": "Cierre Tecnico Bloqueado",
  "status": 422,
  "detail": "No se puede completar la orden porque la tarea Mantenimiento Integral de Frenos Delanteros continua en estado IN_PROGRESS",
  "instance": "/api/v1/work-orders/018f6c40-7e12-7000-8000-000000000100/complete",
  "code": "INVALID_WORK_ORDER_STATUS_TRANSITION",
  "timestamp": "2026-10-03T11:25:00Z"
}
```

---

### 2.15. [POST] /api/v1/work-orders/{workOrderId}/mark-as-paid

**Conciliacion Formal de Pago y Deduccion Definitiva de Inventario**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.WorkOrdersController`
- **Metodo Java:** `public ResponseEntity<WorkOrderResource> markWorkOrderAsPaid(@PathVariable UUID workOrderId)`
- **Ruta Base:** `/api/v1/work-orders`
- **Ruta Completa:** `/api/v1/work-orders/{workOrderId}/mark-as-paid`
- **Proposito:** Registra la conciliacion economica del pago total de la orden de trabajo. Transiciona la orden de COMPLETED a PAID y consolida las reservas logicas de inventario en deducciones contables permanentes bajo el metodo FIFO, registrando el costo de ventas final.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Administrador (ROLE_ADMIN)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:work_orders:update')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `workOrderId` (UUID): Identificador unico de la orden de trabajo pagada

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.WorkOrderResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la orden |
| tenantId | UUID | Identificador del taller |
| internalNumber | Integer | Numero secuencial correlativo |
| vehicleId | UUID | Identificador del vehiculo |
| currentBayId | UUID | Identificador de bahia (null) |
| mileageIn | Integer | Kilometraje de recepcion |
| status | String | Nuevo estado operativo (PAID) |
| totalAmount | BigDecimal | Importe liquidado |
| currency | String | Moneda de cobro |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000100",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "internalNumber": 1042,
  "vehicleId": "018f6c40-7e12-7000-8000-000000000020",
  "currentBayId": null,
  "mileageIn": 64500,
  "status": "PAID",
  "totalAmount": 510,
  "currency": "PEN"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 404 Not Found | WorkOrderNotFoundException | La orden de trabajo no existe |
| 422 Unprocessable Entity | WorkOrderCannotBePaidException | La orden no puede pagarse porque todavia no ha alcanzado el estado COMPLETED |
| 422 Unprocessable Entity | InvalidWorkOrderStatusTransitionException | La orden ya habia sido pagada previamente |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/work-order-cannot-be-paid",
  "title": "Orden No Liquidable",
  "status": 422,
  "detail": "La orden se encuentra en estado IN_PROGRESS. Debe completarse tecnicamente antes de conciliar el pago",
  "instance": "/api/v1/work-orders/018f6c40-7e12-7000-8000-000000000100/mark-as-paid",
  "code": "WORK_ORDER_CANNOT_BE_PAID",
  "timestamp": "2026-10-03T11:30:00Z"
}
```

---

### 2.16. [POST] /api/v1/work-orders/{workOrderId}/cancel

**Cancelacion Justificada de Orden de Trabajo**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.WorkOrdersController`
- **Metodo Java:** `public ResponseEntity<WorkOrderResource> cancelWorkOrder(@PathVariable UUID workOrderId, @Valid @RequestBody CancelWorkOrderResource resource)`
- **Ruta Base:** `/api/v1/work-orders`
- **Ruta Completa:** `/api/v1/work-orders/{workOrderId}/cancel`
- **Proposito:** Cancela de forma justificada una orden de trabajo activa. Desvincula y libera inmediatamente cualquier bahia fisica ocupada y emite comandos salientes hacia el modulo de inventario para cancelar y restituir todas las reservas de repuestos asociadas.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Jefe de Taller (ROLE_WORKSHOP_MANAGER) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:work_orders:cancel')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `workOrderId` (UUID): Identificador unico de la orden de trabajo a cancelar

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.requests.CancelWorkOrderResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| reason | String | Si | @NotBlank, @Size(max = 1000) | Motivo formal o causa justificada de la anulacion de la orden |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "reason": "Cliente decidio retirar el vehiculo sin efectuar reparaciones por desacuerdo en plazos de entrega de repuestos importados."
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.WorkOrderResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la orden de trabajo |
| tenantId | UUID | Identificador del taller |
| internalNumber | Integer | Numero secuencial correlativo |
| vehicleId | UUID | Identificador del vehiculo |
| currentBayId | UUID | Identificador de bahia (liberada a null) |
| mileageIn | Integer | Kilometraje de recepcion |
| status | String | Nuevo estado operativo (CANCELLED) |
| totalAmount | BigDecimal | Importe liquidado a cero |
| currency | String | Moneda de la orden |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000100",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "internalNumber": 1042,
  "vehicleId": "018f6c40-7e12-7000-8000-000000000020",
  "currentBayId": null,
  "mileageIn": 64500,
  "status": "CANCELLED",
  "totalAmount": 0,
  "currency": "PEN"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 404 Not Found | WorkOrderNotFoundException | La orden de trabajo no existe |
| 422 Unprocessable Entity | InvalidWorkOrderStatusTransitionException | No se puede cancelar una orden que ya fue pagada o que ya se encuentra cancelada |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-work-order-status-transition",
  "title": "Cancelacion No Permitida",
  "status": 422,
  "detail": "No se puede cancelar una orden de trabajo en estado PAID",
  "instance": "/api/v1/work-orders/018f6c40-7e12-7000-8000-000000000100/cancel",
  "code": "INVALID_WORK_ORDER_STATUS_TRANSITION",
  "timestamp": "2026-10-03T11:35:00Z"
}
```

---

## 3. Endpoints de Labores Mecanicas en Foso (TasksController)

### 3.1. [GET] /api/v1/tasks/{taskId}

**Consulta Tecnica Individual de Labor en Foso**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.TasksController`
- **Metodo Java:** `public ResponseEntity<WorkOrderTaskResource> getTaskById(@PathVariable UUID taskId)`
- **Ruta Base:** `/api/v1/tasks`
- **Ruta Completa:** `/api/v1/tasks/{taskId}`
- **Proposito:** Recupera el detalle tecnico y estado operacional de una labor mecanica en foso o bahia. Proyecta el tiempo transcurrido, pausas acumuladas, repuestos asignados y fotografias periciales capturadas durante la intervencion.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Mecanico (ROLE_MECHANIC) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:tasks:read')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId garantizado a traves de la orden de trabajo contenedora.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `taskId` (UUID): Identificador unico de la labor mecanica

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.WorkOrderTaskResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la labor mecanica |
| workOrderId | UUID | Identificador de la orden de trabajo |
| serviceId | UUID | Identificador del servicio tarifario |
| serviceName | String | Nombre del servicio estandar |
| mechanicId | UUID | Identificador del tecnico mecanico |
| mechanicName | String | Nombres y apellidos del tecnico |
| status | String | Estado operativo (ASSIGNED, IN_PROGRESS, ON_HOLD, COMPLETED) |
| description | String | Descripcion detallada de la intervencion |
| price | BigDecimal | Tarifa de mano de obra fijada |
| currency | String | Divisa de cobro |
| holdReason | String | Causa tecnica de suspension si aplica |
| missingItemDescription | String | Descripcion de repuesto faltante |
| totalPausedSeconds | Long | Segundos totales acumulados en estado ON_HOLD |
| startedAt | Instant | Marca temporal de inicio de cronometro |
| completedAt | Instant | Marca temporal de conclusion |
| products | List<TaskProductResource> | Listado de repuestos e insumos consumidos |
| evidenceImages | List<WorkOrderTaskImageResource> | Evidencias periciales fotograficas |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000201",
  "workOrderId": "018f6c40-7e12-7000-8000-000000000100",
  "serviceId": "018f6c40-7e12-7000-8000-000000000401",
  "serviceName": "Mantenimiento Integral de Frenos Delanteros",
  "mechanicId": "018f6c40-7e12-7000-8000-000000000501",
  "mechanicName": "Juan Carlos Perez",
  "status": "IN_PROGRESS",
  "description": "Desmontaje de mordazas, rectificado de discos delanteros y purgado del sistema hidraulico de frenos.",
  "price": 150,
  "currency": "PEN",
  "holdReason": null,
  "missingItemDescription": null,
  "totalPausedSeconds": 0,
  "startedAt": "2026-10-03T10:30:00Z",
  "completedAt": null,
  "products": [],
  "evidenceImages": []
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 404 Not Found | WorkOrderTaskNotFoundException | La tarea mecanica solicitada no existe o no pertenece al taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/work-order-task-not-found",
  "title": "Tarea Mecanica No Encontrada",
  "status": 404,
  "detail": "No se encontro ninguna tarea mecanica con el identificador 018f6c40-7e12-7000-8000-000000000201",
  "instance": "/api/v1/tasks/018f6c40-7e12-7000-8000-000000000201",
  "code": "WORK_ORDER_TASK_NOT_FOUND",
  "timestamp": "2026-10-03T11:40:00Z"
}
```

---

### 3.2. [PUT] /api/v1/tasks/{taskId}

**Modificacion Tecnica de Tarea Mecanica**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.TasksController`
- **Metodo Java:** `public ResponseEntity<WorkOrderTaskResource> updateTask(@PathVariable UUID taskId, @Valid @RequestBody UpdateWorkOrderTaskResource resource)`
- **Ruta Base:** `/api/v1/tasks`
- **Ruta Completa:** `/api/v1/tasks/{taskId}`
- **Proposito:** Actualiza los parametros operativos de la labor tecnica: rectifica la descripcion del procedimiento, reasigna el mecanico responsable o reajusta el precio de mano de obra acordado. Impide mutaciones si la tarea ya ha alcanzado el estado COMPLETED.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Jefe de Taller (ROLE_WORKSHOP_MANAGER) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:tasks:update')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `taskId` (UUID): Identificador unico de la labor mecanica a actualizar

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.requests.UpdateWorkOrderTaskResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| description | String | No | @Size(max = 1000) | Descripcion rectificada del procedimiento mecanico |
| price | BigDecimal | No | @Positive | Precio actualizado de mano de obra |
| mechanicId | UUID | No | Sin validacion adicional | Identificador del nuevo tecnico mecanico asignado |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "description": "Desmontaje de mordazas, rectificado de discos delanteros, limpieza por ultrasonido de calipers y purgado hidraulico DOT 4.",
  "price": 165,
  "mechanicId": "018f6c40-7e12-7000-8000-000000000502"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.WorkOrderTaskResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la labor mecanica |
| workOrderId | UUID | Identificador de la orden de trabajo |
| serviceId | UUID | Identificador del servicio tarifario |
| serviceName | String | Nombre del servicio estandar |
| mechanicId | UUID | Identificador del tecnico reasignado |
| mechanicName | String | Nombres del nuevo tecnico |
| status | String | Estado operativo de la tarea |
| description | String | Descripcion rectificada |
| price | BigDecimal | Precio actualizado |
| currency | String | Moneda de la labor |
| holdReason | String | Motivo de pausa |
| missingItemDescription | String | Repuesto faltante |
| totalPausedSeconds | Long | Segundos en pausa |
| startedAt | Instant | Marca de inicio |
| completedAt | Instant | Marca de conclusion |
| products | List<TaskProductResource> | Repuestos asociados |
| evidenceImages | List<WorkOrderTaskImageResource> | Evidencias periciales |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000201",
  "workOrderId": "018f6c40-7e12-7000-8000-000000000100",
  "serviceId": "018f6c40-7e12-7000-8000-000000000401",
  "serviceName": "Mantenimiento Integral de Frenos Delanteros",
  "mechanicId": "018f6c40-7e12-7000-8000-000000000502",
  "mechanicName": "Roberto Gomez",
  "status": "ASSIGNED",
  "description": "Desmontaje de mordazas, rectificado de discos delanteros, limpieza por ultrasonido de calipers y purgado hidraulico DOT 4.",
  "price": 165,
  "currency": "PEN",
  "holdReason": null,
  "missingItemDescription": null,
  "totalPausedSeconds": 0,
  "startedAt": null,
  "completedAt": null,
  "products": [],
  "evidenceImages": []
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 404 Not Found | WorkOrderTaskNotFoundException | La tarea mecanica no existe |
| 422 Unprocessable Entity | WorkOrderTaskAlreadyCompletedException | La tarea mecanica ya fue completada y no admite modificaciones tecnicas |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/work-order-task-already-completed",
  "title": "Labor Tecnica Ya Completada",
  "status": 422,
  "detail": "No se puede modificar una tarea mecanica que ya cuenta con estatus COMPLETED",
  "instance": "/api/v1/tasks/018f6c40-7e12-7000-8000-000000000201",
  "code": "WORK_ORDER_TASK_ALREADY_COMPLETED",
  "timestamp": "2026-10-03T11:45:00Z"
}
```

---

### 3.3. [POST] /api/v1/tasks/{taskId}/start

**Inicio Operativo de Labor Mecanica en Foso**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.TasksController`
- **Metodo Java:** `public ResponseEntity<WorkOrderTaskResource> startTask(@PathVariable UUID taskId)`
- **Ruta Base:** `/api/v1/tasks`
- **Ruta Completa:** `/api/v1/tasks/{taskId}/start`
- **Proposito:** Registra el arranque operativo de la intervencion mecanica por parte del tecnico asignado. Transiciona la tarea a IN_PROGRESS e inicia el cronometraje formal de mano de obra efectiva (Wrench Time). Si la orden contenedora aun estaba en DRAFT, este evento puede propagar la activacion de la orden.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Mecanico (ROLE_MECHANIC)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:tasks:track_time')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `taskId` (UUID): Identificador unico de la labor mecanica a iniciar

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.WorkOrderTaskResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la labor mecanica |
| workOrderId | UUID | Identificador de la orden de trabajo |
| serviceId | UUID | Identificador del servicio tarifario |
| serviceName | String | Nombre del servicio estandar |
| mechanicId | UUID | Identificador del mecanico |
| mechanicName | String | Nombres del mecanico |
| status | String | Nuevo estado operativo (IN_PROGRESS) |
| description | String | Descripcion del procedimiento |
| price | BigDecimal | Tarifa fijada |
| currency | String | Moneda |
| holdReason | String | Motivo de pausa (null) |
| missingItemDescription | String | Repuesto faltante (null) |
| totalPausedSeconds | Long | Segundos en pausa (0) |
| startedAt | Instant | Marca temporal precisa de inicio de labor |
| completedAt | Instant | Marca de cierre (null) |
| products | List<TaskProductResource> | Repuestos |
| evidenceImages | List<WorkOrderTaskImageResource> | Evidencias |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000201",
  "workOrderId": "018f6c40-7e12-7000-8000-000000000100",
  "serviceId": "018f6c40-7e12-7000-8000-000000000401",
  "serviceName": "Mantenimiento Integral de Frenos Delanteros",
  "mechanicId": "018f6c40-7e12-7000-8000-000000000501",
  "mechanicName": "Juan Carlos Perez",
  "status": "IN_PROGRESS",
  "description": "Desmontaje de mordazas, rectificado de discos delanteros y purgado del sistema hidraulico de frenos.",
  "price": 150,
  "currency": "PEN",
  "holdReason": null,
  "missingItemDescription": null,
  "totalPausedSeconds": 0,
  "startedAt": "2026-10-03T11:48:10Z",
  "completedAt": null,
  "products": [],
  "evidenceImages": []
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 404 Not Found | WorkOrderTaskNotFoundException | La tarea mecanica no existe |
| 422 Unprocessable Entity | WorkOrderTaskAlreadyCompletedException | La labor ya habia sido completada previamente |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/work-order-task-already-completed",
  "title": "Labor Ya Culminada",
  "status": 422,
  "detail": "No se puede iniciar una labor tecnica que ya fue cerrada satisfactoriamente",
  "instance": "/api/v1/tasks/018f6c40-7e12-7000-8000-000000000201/start",
  "code": "WORK_ORDER_TASK_ALREADY_COMPLETED",
  "timestamp": "2026-10-03T11:49:00Z"
}
```

---

### 3.4. [POST] /api/v1/tasks/{taskId}/hold

**Suspension Operativa de Labor por Falta de Repuestos**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.TasksController`
- **Metodo Java:** `public ResponseEntity<WorkOrderTaskResource> holdTask(@PathVariable UUID taskId, @Valid @RequestBody HoldTaskResource resource)`
- **Ruta Base:** `/api/v1/tasks`
- **Ruta Completa:** `/api/v1/tasks/{taskId}/hold`
- **Proposito:** Permite al tecnico mecanico suspender la labor en foso cuando constata falta de stock de repuestos o lubricantes requeridos en almacen. Transiciona la tarea al estado ON_HOLD, detiene el computo de mano de obra efectiva y emite alertas reactivas hacia el panel del almacenero y asesor.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Mecanico (ROLE_MECHANIC)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:tasks:track_time')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `taskId` (UUID): Identificador unico de la labor mecanica a suspender

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.requests.HoldTaskResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| missingItemDescription | String | Si | @NotBlank, @Size(max = 500) | Descripcion detallada del repuesto o fluido faltante |
| inventoryItemId | UUID | No | Sin validacion adicional | Identificador opcional del repuesto en catalogo de inventario |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "missingItemDescription": "Laminas antiruido y pines guias de mordaza de freno delantero no disponibles en stock de almacen.",
  "inventoryItemId": "018f6c40-7e12-7000-8000-000000000705"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.WorkOrderTaskResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la labor |
| workOrderId | UUID | Identificador de la orden de trabajo |
| serviceId | UUID | Identificador de servicio tarifario |
| serviceName | String | Nombre del servicio |
| mechanicId | UUID | Identificador del tecnico |
| mechanicName | String | Nombres del mecanico |
| status | String | Nuevo estado operativo (ON_HOLD) |
| description | String | Descripcion del procedimiento |
| price | BigDecimal | Tarifa de mano de obra |
| currency | String | Moneda |
| holdReason | String | Motivo formal de suspension |
| missingItemDescription | String | Descripcion de material no disponible |
| totalPausedSeconds | Long | Segundos acumulados en pausa |
| startedAt | Instant | Marca temporal de inicio original |
| completedAt | Instant | Marca de conclusion (null) |
| products | List<TaskProductResource> | Repuestos |
| evidenceImages | List<WorkOrderTaskImageResource> | Evidencias |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000201",
  "workOrderId": "018f6c40-7e12-7000-8000-000000000100",
  "serviceId": "018f6c40-7e12-7000-8000-000000000401",
  "serviceName": "Mantenimiento Integral de Frenos Delanteros",
  "mechanicId": "018f6c40-7e12-7000-8000-000000000501",
  "mechanicName": "Juan Carlos Perez",
  "status": "ON_HOLD",
  "description": "Desmontaje de mordazas, rectificado de discos delanteros y purgado del sistema hidraulico de frenos.",
  "price": 150,
  "currency": "PEN",
  "holdReason": "Falta de repuestos en almacen",
  "missingItemDescription": "Laminas antiruido y pines guias de mordaza de freno delantero no disponibles en stock de almacen.",
  "totalPausedSeconds": 0,
  "startedAt": "2026-10-03T11:48:10Z",
  "completedAt": null,
  "products": [],
  "evidenceImages": []
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 404 Not Found | WorkOrderTaskNotFoundException | La labor mecanica solicitada no existe |
| 422 Unprocessable Entity | TaskCannotBePutOnHoldException | La tarea no se encuentra en estado IN_PROGRESS o ya habia sido suspendida |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/task-cannot-be-put-on-hold",
  "title": "Suspension No Permitida",
  "status": 422,
  "detail": "La tarea se encuentra en estado ASSIGNED. Solo las tareas en estado IN_PROGRESS pueden ponerse en pausa",
  "instance": "/api/v1/tasks/018f6c40-7e12-7000-8000-000000000201/hold",
  "code": "TASK_CANNOT_BE_PUT_ON_HOLD",
  "timestamp": "2026-10-03T11:55:00Z"
}
```

---

### 3.5. [POST] /api/v1/tasks/{taskId}/resume

**Reanudacion de Labor Mecanica tras Recepcion de Repuestos**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.TasksController`
- **Metodo Java:** `public ResponseEntity<WorkOrderTaskResource> resumeTask(@PathVariable UUID taskId)`
- **Ruta Base:** `/api/v1/tasks`
- **Ruta Completa:** `/api/v1/tasks/{taskId}/resume`
- **Proposito:** Permite al tecnico mecanico reanudar la labor en foso una vez que los repuestos faltantes han sido abastecidos en bahia. Transiciona la tarea de ON_HOLD a IN_PROGRESS, computa el lapso de suspension transcurrido incorporandolo a totalPausedSeconds y reactiva el cronometro de horas efectivas.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Mecanico (ROLE_MECHANIC)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:tasks:track_time')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `taskId` (UUID): Identificador unico de la labor mecanica a reanudar

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.WorkOrderTaskResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la labor mecanica |
| workOrderId | UUID | Identificador de la orden de trabajo |
| serviceId | UUID | Identificador del servicio tarifario |
| serviceName | String | Nombre del servicio |
| mechanicId | UUID | Identificador del tecnico |
| mechanicName | String | Nombres del mecanico |
| status | String | Estado operativo reanudado (IN_PROGRESS) |
| description | String | Descripcion del procedimiento |
| price | BigDecimal | Tarifa fijada |
| currency | String | Moneda |
| holdReason | String | Motivo de pausa (restablecido a null) |
| missingItemDescription | String | Descripcion de repuesto faltante (restablecido a null) |
| totalPausedSeconds | Long | Segundos totales acumulados en suspension |
| startedAt | Instant | Marca temporal de inicio |
| completedAt | Instant | Marca de conclusion (null) |
| products | List<TaskProductResource> | Repuestos |
| evidenceImages | List<WorkOrderTaskImageResource> | Evidencias |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000201",
  "workOrderId": "018f6c40-7e12-7000-8000-000000000100",
  "serviceId": "018f6c40-7e12-7000-8000-000000000401",
  "serviceName": "Mantenimiento Integral de Frenos Delanteros",
  "mechanicId": "018f6c40-7e12-7000-8000-000000000501",
  "mechanicName": "Juan Carlos Perez",
  "status": "IN_PROGRESS",
  "description": "Desmontaje de mordazas, rectificado de discos delanteros y purgado del sistema hidraulico de frenos.",
  "price": 150,
  "currency": "PEN",
  "holdReason": null,
  "missingItemDescription": null,
  "totalPausedSeconds": 1800,
  "startedAt": "2026-10-03T11:48:10Z",
  "completedAt": null,
  "products": [],
  "evidenceImages": []
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 404 Not Found | WorkOrderTaskNotFoundException | La labor mecanica no existe |
| 422 Unprocessable Entity | TaskNotOnHoldException | La tarea no se encuentra en estado ON_HOLD para ser reanudada |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/task-not-on-hold",
  "title": "Labor No Suspendida",
  "status": 422,
  "detail": "La tarea se encuentra en estado IN_PROGRESS. No requiere reanudacion",
  "instance": "/api/v1/tasks/018f6c40-7e12-7000-8000-000000000201/resume",
  "code": "TASK_NOT_ON_HOLD",
  "timestamp": "2026-10-03T12:00:00Z"
}
```

---

### 3.6. [POST] /api/v1/tasks/{taskId}/complete

**Conclusion de Labor Mecanica con Registro de Horas Efectivas**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.TasksController`
- **Metodo Java:** `public ResponseEntity<WorkOrderTaskResource> completeTask(@PathVariable UUID taskId, @Valid @RequestBody CompleteTaskResource resource)`
- **Ruta Base:** `/api/v1/tasks`
- **Ruta Completa:** `/api/v1/tasks/{taskId}/complete`
- **Proposito:** Registra la conclusion tecnica satisfactoria de la labor en foso. El tecnico ingresa las horas hombre reales consumidas de mano de obra efectiva (Wrench Time) y notas periciales de cierre. Transiciona la tarea a COMPLETED y detiene definitivamente los cronometros.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Mecanico (ROLE_MECHANIC)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:tasks:complete')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `taskId` (UUID): Identificador unico de la labor mecanica a culminar

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.requests.CompleteTaskResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| actualLaborHours | BigDecimal | Si | @NotNull, @Positive(message = "Las horas laboradas deben ser mayores a cero") | Horas hombre reales dedicadas a la labor efectiva |
| notes | String | No | @Size(max = 1000) | Observaciones periciales de conclusion y pruebas de frenado realizadas |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "actualLaborHours": 1.75,
  "notes": "Pastillas asentadas correctamente. Se realizo purga de aire y prueba de frenado en dinamometro con resultado optimo."
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.WorkOrderTaskResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la labor mecanica |
| workOrderId | UUID | Identificador de la orden de trabajo |
| serviceId | UUID | Identificador del servicio |
| serviceName | String | Nombre del servicio estandar |
| mechanicId | UUID | Identificador del tecnico |
| mechanicName | String | Nombres del mecanico |
| status | String | Nuevo estado operativo (COMPLETED) |
| description | String | Descripcion tecnica |
| price | BigDecimal | Tarifa de mano de obra fijada |
| currency | String | Moneda |
| holdReason | String | Motivo de pausa (null) |
| missingItemDescription | String | Repuesto faltante (null) |
| totalPausedSeconds | Long | Segundos totales acumulados en pausa |
| startedAt | Instant | Marca temporal de inicio |
| completedAt | Instant | Marca temporal exacta de finalizacion |
| products | List<TaskProductResource> | Repuestos consumidos |
| evidenceImages | List<WorkOrderTaskImageResource> | Evidencias periciales registradas |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000201",
  "workOrderId": "018f6c40-7e12-7000-8000-000000000100",
  "serviceId": "018f6c40-7e12-7000-8000-000000000401",
  "serviceName": "Mantenimiento Integral de Frenos Delanteros",
  "mechanicId": "018f6c40-7e12-7000-8000-000000000501",
  "mechanicName": "Juan Carlos Perez",
  "status": "COMPLETED",
  "description": "Desmontaje de mordazas, rectificado de discos delanteros y purgado del sistema hidraulico de frenos.",
  "price": 150,
  "currency": "PEN",
  "holdReason": null,
  "missingItemDescription": null,
  "totalPausedSeconds": 1800,
  "startedAt": "2026-10-03T11:48:10Z",
  "completedAt": "2026-10-03T13:33:10Z",
  "products": [],
  "evidenceImages": []
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 400 Bad Request | InvalidLaborHoursException | Las horas hombre ingresadas son menores o iguales a cero |
| 404 Not Found | WorkOrderTaskNotFoundException | La labor mecanica no existe |
| 422 Unprocessable Entity | WorkOrderTaskAlreadyCompletedException | La labor tecnica ya habia sido completada |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-labor-hours",
  "title": "Horas Laboradas Invalidas",
  "status": 400,
  "detail": "Las horas laboradas reales deben ser un valor numerico estrictamente positivo",
  "instance": "/api/v1/tasks/018f6c40-7e12-7000-8000-000000000201/complete",
  "code": "INVALID_LABOR_HOURS",
  "timestamp": "2026-10-03T13:35:00Z"
}
```

---

### 3.7. [POST] /api/v1/tasks/{taskId}/reopen

**Reapertura de Labor para Rectificacion o Calibracion Tecnica**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.TasksController`
- **Metodo Java:** `public ResponseEntity<WorkOrderTaskResource> reopenTask(@PathVariable UUID taskId)`
- **Ruta Base:** `/api/v1/tasks`
- **Ruta Completa:** `/api/v1/tasks/{taskId}/reopen`
- **Proposito:** Permite al Jefe de Taller o Asesor de Servicio reabrir una tarea previamente cerrada si durante las pruebas periciales de calidad se detectan desajustes o ruidos residuales. Transiciona la tarea de COMPLETED a IN_PROGRESS, reactivando el foso y los registros operativos.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Jefe de Taller (ROLE_WORKSHOP_MANAGER) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:tasks:update')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `taskId` (UUID): Identificador unico de la labor mecanica a reabrir

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.WorkOrderTaskResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la labor mecanica |
| workOrderId | UUID | Identificador de la orden |
| serviceId | UUID | Identificador de servicio tarifario |
| serviceName | String | Nombre del servicio |
| mechanicId | UUID | Identificador del tecnico |
| mechanicName | String | Nombres del mecanico |
| status | String | Nuevo estado operativo (IN_PROGRESS) |
| description | String | Descripcion del procedimiento |
| price | BigDecimal | Tarifa |
| currency | String | Moneda |
| holdReason | String | Motivo de pausa (null) |
| missingItemDescription | String | Repuesto faltante (null) |
| totalPausedSeconds | Long | Segundos acumulados en pausa |
| startedAt | Instant | Marca de inicio original |
| completedAt | Instant | Marca de cierre (restablecida a null) |
| products | List<TaskProductResource> | Repuestos |
| evidenceImages | List<WorkOrderTaskImageResource> | Evidencias |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000201",
  "workOrderId": "018f6c40-7e12-7000-8000-000000000100",
  "serviceId": "018f6c40-7e12-7000-8000-000000000401",
  "serviceName": "Mantenimiento Integral de Frenos Delanteros",
  "mechanicId": "018f6c40-7e12-7000-8000-000000000501",
  "mechanicName": "Juan Carlos Perez",
  "status": "IN_PROGRESS",
  "description": "Desmontaje de mordazas, rectificado de discos delanteros y purgado del sistema hidraulico de frenos.",
  "price": 150,
  "currency": "PEN",
  "holdReason": null,
  "missingItemDescription": null,
  "totalPausedSeconds": 1800,
  "startedAt": "2026-10-03T11:48:10Z",
  "completedAt": null,
  "products": [],
  "evidenceImages": []
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 404 Not Found | WorkOrderTaskNotFoundException | La labor mecanica no existe en el taller |
| 422 Unprocessable Entity | InvalidWorkOrderStatusTransitionException | La orden contenedora ya fue pagada y no permite reapertura de labores |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-work-order-status-transition",
  "title": "Reapertura No Permitida",
  "status": 422,
  "detail": "No se puede reabrir una tarea en una orden de trabajo liquidada en estado PAID",
  "instance": "/api/v1/tasks/018f6c40-7e12-7000-8000-000000000201/reopen",
  "code": "INVALID_WORK_ORDER_STATUS_TRANSITION",
  "timestamp": "2026-10-03T13:40:00Z"
}
```

---

### 3.8. [POST] /api/v1/tasks/{taskId}/products

**Solicitud de Repuesto con Reserva Logica FIFO en Inventario**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.TasksController`
- **Metodo Java:** `public ResponseEntity<TaskProductResource> addTaskProduct(@PathVariable UUID taskId, @Valid @RequestBody AddTaskProductResource resource)`
- **Ruta Base:** `/api/v1/tasks`
- **Ruta Completa:** `/api/v1/tasks/{taskId}/products`
- **Proposito:** Incorpora un repuesto o insumo consumido en la labor tecnica. Despacha una invocacion sincronica a traves de la fachada Inbound ACL hacia el Bounded Context de Inventario para verificar existencias y asegurar la reserva logica inmediata bajo el algoritmo estricto FIFO por lotes de adquisicion.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Mecanico (ROLE_MECHANIC) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:tasks:update')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId. La reserva en inventario se ejecuta sobre el catalogo del mismo taller.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `taskId` (UUID): Identificador unico de la labor mecanica

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.requests.AddTaskProductResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| productId | UUID | Si | @NotNull(message = "El identificador del producto es obligatorio") | Identificador del repuesto en catalogo de inventario |
| quantity | BigDecimal | Si | @NotNull, @Positive(message = "La cantidad demandada debe ser estrictamente positiva") | Cantidad de unidades requeridas |
| unitPrice | BigDecimal | Si | @NotNull, @Positive(message = "El precio unitario debe ser positivo") | Precio unitario de venta al cliente fijado |
| currency | String | Si | @NotBlank, @Pattern(regexp = "PEN|USD") | Codigo ISO de la moneda de facturacion |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "productId": "018f6c40-7e12-7000-8000-000000000701",
  "quantity": 1,
  "unitPrice": 180,
  "currency": "PEN"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.TaskProductResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la asignacion de producto |
| taskId | UUID | Identificador de la labor mecanica receptora |
| productId | UUID | Identificador del repuesto en catalogo |
| productName | String | Denominacion comercial del repuesto |
| quantity | BigDecimal | Cantidad reservada y asignada |
| unitPrice | BigDecimal | Precio unitario pactado |
| totalAmount | BigDecimal | Importe total facturable del item |
| currency | String | Divisa monetaria de facturacion |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000601",
  "taskId": "018f6c40-7e12-7000-8000-000000000201",
  "productId": "018f6c40-7e12-7000-8000-000000000701",
  "productName": "Juego de Pastillas Ceramicas Delanteras Bosch",
  "quantity": 1,
  "unitPrice": 180,
  "totalAmount": 180,
  "currency": "PEN"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 400 Bad Request | InvalidQuantityException | La cantidad demandada es menor o igual a cero |
| 404 Not Found | WorkOrderTaskNotFoundException | La labor mecanica solicitada no existe |
| 409 Conflict | InsufficientStockException | El inventario no cuenta con existencias disponibles suficientes para atender la reserva |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/insufficient-stock",
  "title": "Stock Insuficiente en Almacen",
  "status": 409,
  "detail": "No se cuenta con existencias suficientes del repuesto Juego de Pastillas Ceramicas para satisfacer la cantidad demandada (1.0)",
  "instance": "/api/v1/tasks/018f6c40-7e12-7000-8000-000000000201/products",
  "code": "ERR_INSUFFICIENT_STOCK",
  "timestamp": "2026-10-03T13:45:00Z"
}
```

---

### 3.9. [PUT] /api/v1/tasks/{taskId}/products/{productId}

**Ajuste de Cantidad de Repuesto Consumido en Labor**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.TasksController`
- **Metodo Java:** `public ResponseEntity<TaskProductResource> updateTaskProduct(@PathVariable UUID taskId, @PathVariable UUID productId, @Valid @RequestBody UpdateTaskProductResource resource)`
- **Ruta Base:** `/api/v1/tasks`
- **Ruta Completa:** `/api/v1/tasks/{taskId}/products/{productId}`
- **Proposito:** Permite ajustar la cantidad asignada de un repuesto en una labor técnica en curso (por ejemplo, al requerirse litros adicionales de fluido hidraulico). Coordina con el motor FIFO de inventario la ampliacion o liberacion parcial de la reserva logica y recalcula el importe total de la orden.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Mecanico (ROLE_MECHANIC) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:tasks:update')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `taskId` (UUID): Identificador unico de la labor mecanica
- `productId` (UUID): Identificador del repuesto asignado a ajustar

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.requests.UpdateTaskProductResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| quantity | BigDecimal | Si | @NotNull, @Positive(message = "La cantidad demandada debe ser estrictamente positiva") | Nueva cantidad rectificada consumida |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "quantity": 2
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.TaskProductResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la linea de producto |
| taskId | UUID | Identificador de la labor mecanica |
| productId | UUID | Identificador del repuesto en catalogo |
| productName | String | Denominacion del repuesto |
| quantity | BigDecimal | Cantidad reajustada |
| unitPrice | BigDecimal | Precio unitario |
| totalAmount | BigDecimal | Nuevo importe total |
| currency | String | Moneda |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000601",
  "taskId": "018f6c40-7e12-7000-8000-000000000201",
  "productId": "018f6c40-7e12-7000-8000-000000000701",
  "productName": "Juego de Pastillas Ceramicas Delanteras Bosch",
  "quantity": 2,
  "unitPrice": 180,
  "totalAmount": 360,
  "currency": "PEN"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 400 Bad Request | InvalidQuantityException | La cantidad rectificada es menor o igual a cero |
| 404 Not Found | WorkOrderTaskNotFoundException | La labor mecanica no existe |
| 409 Conflict | InsufficientStockException | El incremento solicitado supera el stock remanente en almacen |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/insufficient-stock",
  "title": "Stock Insuficiente para Ampliacion",
  "status": 409,
  "detail": "No se puede ampliar la reserva a 2.0 unidades por falta de existencias en el lote activo",
  "instance": "/api/v1/tasks/018f6c40-7e12-7000-8000-000000000201/products/018f6c40-7e12-7000-8000-000000000701",
  "code": "ERR_INSUFFICIENT_STOCK",
  "timestamp": "2026-10-03T13:50:00Z"
}
```

---

### 3.10. [DELETE] /api/v1/tasks/{taskId}/products/{productId}

**Remocion de Repuesto y Anulacion de Reserva en Inventario**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.TasksController`
- **Metodo Java:** `public ResponseEntity<Void> removeTaskProduct(@PathVariable UUID taskId, @PathVariable UUID productId)`
- **Ruta Base:** `/api/v1/tasks`
- **Ruta Completa:** `/api/v1/tasks/{taskId}/products/{productId}`
- **Proposito:** Elimina un repuesto previamente asignado a la labor tecnica. Despacha una orden de liberacion de reserva inmediata hacia el Bounded Context de Inventario, restituyendo las unidades a los lotes FIFO correspondientes y deduciendo el costo del consolidado de la orden.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Mecanico (ROLE_MECHANIC) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:tasks:update')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `taskId` (UUID): Identificador unico de la labor mecanica
- `productId` (UUID): Identificador del repuesto asignado a desvincular

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `204 No Content`
**Cuerpo de Respuesta:** Sin contenido en el cuerpo de respuesta (HTTP 204 No Content).

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 404 Not Found | WorkOrderTaskNotFoundException | La labor mecanica no existe en el taller |
| 422 Unprocessable Entity | WorkOrderTaskAlreadyCompletedException | No se pueden desvincular repuestos de una labor ya finalizada |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/work-order-task-already-completed",
  "title": "Desvinculacion No Permitida",
  "status": 422,
  "detail": "La labor se encuentra finalizada. No se permite anular reservas de materiales aplicados",
  "instance": "/api/v1/tasks/018f6c40-7e12-7000-8000-000000000201/products/018f6c40-7e12-7000-8000-000000000701",
  "code": "WORK_ORDER_TASK_ALREADY_COMPLETED",
  "timestamp": "2026-10-03T13:55:00Z"
}
```

---

### 3.11. [POST] /api/v1/tasks/{taskId}/evidence-images

**Carga Pericial de Evidencia Fotografica de Labor en Foso**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.TasksController`
- **Metodo Java:** `public ResponseEntity<WorkOrderTaskImageResource> attachEvidenceImage(@PathVariable UUID taskId, @Valid @RequestBody AttachTaskEvidenceResource resource)`
- **Ruta Base:** `/api/v1/tasks`
- **Ruta Completa:** `/api/v1/tasks/{taskId}/evidence-images`
- **Proposito:** Registra los metadatos y URL HTTPS de una fotografia pericial capturada por el mecanico en el foso durante el procedimiento mecanico (por ejemplo, piezas desgastadas desmontadas o torque verificado en la instalacion). Vincula la imagen de Firebase Storage de forma inmutable a la labor.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Mecanico (ROLE_MECHANIC)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:tasks:upload_photos')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `taskId` (UUID): Identificador unico de la labor mecanica

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.requests.AttachTaskEvidenceResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| imageUrl | String | Si | @NotBlank, @URL | URL segura HTTPS de la foto pericial en Firebase Storage |
| description | String | No | @Size(max = 500) | Descripcion del procedimiento o elemento mecanico retratado |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "imageUrl": "https://firebasestorage.googleapis.com/v0/b/atelier-app.appspot.com/o/tenants%2F018f6c40-7e12-7000-8000-000000000001%2Ftasks%2F201%2Fcaliper-montado.jpg?alt=media",
  "description": "Constancia de montaje de pastillas nuevas y pernos de caliper ajustados con torquimetro a 85 Nm."
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.WorkOrderTaskImageResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico del registro de evidencia |
| taskId | UUID | Identificador de la labor mecanica receptora |
| imageUrl | String | URL HTTPS inmutable de almacenamiento seguro |
| description | String | Descripcion pericial de la fotografia |
| uploadedAt | Instant | Marca temporal de subida e indexacion |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000850",
  "taskId": "018f6c40-7e12-7000-8000-000000000201",
  "imageUrl": "https://firebasestorage.googleapis.com/v0/b/atelier-app.appspot.com/o/tenants%2F018f6c40-7e12-7000-8000-000000000001%2Ftasks%2F201%2Fcaliper-montado.jpg?alt=media",
  "description": "Constancia de montaje de pastillas nuevas y pernos de caliper ajustados con torquimetro a 85 Nm.",
  "uploadedAt": "2026-10-03T13:58:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 400 Bad Request | InvalidStorageUrlException | La URL no pertenece al almacenamiento autorizado de Firebase Storage |
| 404 Not Found | WorkOrderTaskNotFoundException | La labor mecanica no existe en el taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-storage-url",
  "title": "URL de Evidencia Invalida",
  "status": 400,
  "detail": "La URL proporcionada no cumple las directivas de seguridad para almacenamiento Direct-to-Cloud",
  "instance": "/api/v1/tasks/018f6c40-7e12-7000-8000-000000000201/evidence-images",
  "code": "INVALID_STORAGE_URL",
  "timestamp": "2026-10-03T13:59:00Z"
}
```

---

## 4. Endpoints de Bahias de Trabajo (WorkBaysController)

### 4.1. [POST] /api/v1/work-bays

**Creacion y Habilitacion de Puesto o Bahia de Trabajo**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.WorkBaysController`
- **Metodo Java:** `public ResponseEntity<WorkBayResource> createWorkBay(@Valid @RequestBody CreateWorkBayResource resource)`
- **Ruta Base:** `/api/v1/work-bays`
- **Ruta Completa:** `/api/v1/work-bays`
- **Proposito:** Registra y habilita un nuevo puesto fisico de trabajo operativo (elevador mecanico, cabina de pintura, foso de diagnostico, bahia de lavado o estacion de alineacion) en una sucursal del taller. Inicializa la bahia en estado AVAILABLE sin orden vehicular asignada.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Jefe de Taller (ROLE_WORKSHOP_MANAGER) o Administrador (ROLE_ADMIN)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:bays:manage')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId resuelto desde el token JWT. Valida que la sucursal branchId pertenezca al taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.requests.CreateWorkBayResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| branchId | UUID | Si | @NotNull(message = "La sucursal de pertenencia es obligatoria") | Identificador de la sucursal fisica |
| name | String | Si | @NotBlank, @Size(max = 100) | Nombre o codigo distintivo de la bahia |
| bayType | String | Si | @NotBlank, @Pattern(regexp = "MECHANICAL_LIFT|PAINT_BOOTH|WASH_BAY|DIAGNOSTIC_PIT|ALIGNMENT_STATION") | Tipologia operativa del puesto fisico |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "branchId": "018f6c40-7e12-7000-8000-000000000050",
  "name": "Bahia 02 - Elevador de Dos Columnas 4T",
  "bayType": "MECHANICAL_LIFT"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.WorkBayResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la bahia fisica |
| tenantId | UUID | Identificador del taller propietario |
| branchId | UUID | Identificador de la sucursal |
| name | String | Nombre descriptivo de la bahia |
| bayType | String | Tipologia de bahia |
| status | String | Estado operativo inicial (AVAILABLE) |
| currentWorkOrderId | UUID | Identificador de la orden asignada (null) |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000302",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "branchId": "018f6c40-7e12-7000-8000-000000000050",
  "name": "Bahia 02 - Elevador de Dos Columnas 4T",
  "bayType": "MECHANICAL_LIFT",
  "status": "AVAILABLE",
  "currentWorkOrderId": null
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 400 Bad Request | MethodArgumentNotValidException | Tipologia de bahia desconocida o nombre en blanco |
| 404 Not Found | BranchNotFoundException | La sucursal fisica especificada no pertenece al taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-argument",
  "title": "Parametros de Bahia Invalidos",
  "status": 400,
  "detail": "La tipologia de bahia proporcionada no coincide con las categorias homologadas de taller",
  "instance": "/api/v1/work-bays",
  "code": "INVALID_ARGUMENT",
  "timestamp": "2026-10-03T14:00:00Z"
}
```

---

### 4.2. [GET] /api/v1/work-bays

**Consulta Filtrada de Bahias de Trabajo de Sucursal**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.WorkBaysController`
- **Metodo Java:** `public ResponseEntity<List<WorkBayResource>> getWorkBays(@RequestParam(required = false) UUID branchId, @RequestParam(required = false) String bayType, @RequestParam(required = false) String status)`
- **Ruta Base:** `/api/v1/work-bays`
- **Ruta Completa:** `/api/v1/work-bays`
- **Proposito:** Retorna el inventario de bahias fisicas de trabajo del taller, permitiendo filtrar por sucursal fisica, tipo de instalacion (mecanica, pintura, foso) y estado actual de ocupacion (AVAILABLE, OCCUPIED, MAINTENANCE).

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST), Mecanico (ROLE_MECHANIC) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:bays:read')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId. Solo se proyectan puestos de trabajo del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
- `branchId` (UUID, Opcional): Filtro por identificador de sucursal fisica
- `bayType` (String, Opcional): Filtro por tipologia de bahia (MECHANICAL_LIFT, PAINT_BOOTH, WASH_BAY, DIAGNOSTIC_PIT, ALIGNMENT_STATION)
- `status` (String, Opcional): Filtro por disponibilidad (AVAILABLE, OCCUPIED, MAINTENANCE)

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `java.util.List<com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.WorkBayResource>`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la bahia |
| tenantId | UUID | Identificador del taller |
| branchId | UUID | Identificador de la sucursal |
| name | String | Nombre descriptivo de la bahia |
| bayType | String | Tipologia de bahia |
| status | String | Estado operativo actual |
| currentWorkOrderId | UUID | Orden que ocupa la bahia o null si esta libre |

**Ejemplo de Carga Util JSON (Response):**
```json
[
  {
    "id": "018f6c40-7e12-7000-8000-000000000301",
    "tenantId": "018f6c40-7e12-7000-8000-000000000001",
    "branchId": "018f6c40-7e12-7000-8000-000000000050",
    "name": "Bahia 01 - Elevador Hidraulico Principal",
    "bayType": "MECHANICAL_LIFT",
    "status": "OCCUPIED",
    "currentWorkOrderId": "018f6c40-7e12-7000-8000-000000000100"
  },
  {
    "id": "018f6c40-7e12-7000-8000-000000000302",
    "tenantId": "018f6c40-7e12-7000-8000-000000000001",
    "branchId": "018f6c40-7e12-7000-8000-000000000050",
    "name": "Bahia 02 - Elevador de Dos Columnas 4T",
    "bayType": "MECHANICAL_LIFT",
    "status": "AVAILABLE",
    "currentWorkOrderId": null
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 401 Unauthorized | BadCredentialsException | Token JWT ausente o expirado |
| 403 Forbidden | AccessDeniedException | Privilegio insuficiente operations:bays:read |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/access-denied",
  "title": "Acceso Denegado",
  "status": 403,
  "detail": "No cuenta con el privilegio requerido operations:bays:read para consultar bahias fisicas",
  "instance": "/api/v1/work-bays",
  "code": "ACCESS_DENIED",
  "timestamp": "2026-10-03T14:05:00Z"
}
```

---

### 4.3. [GET] /api/v1/work-bays/{bayId}

**Detalle Individual de Bahia de Trabajo y Vehiculo Ocupante**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.WorkBaysController`
- **Metodo Java:** `public ResponseEntity<WorkBayResource> getWorkBayById(@PathVariable UUID bayId)`
- **Ruta Base:** `/api/v1/work-bays`
- **Ruta Completa:** `/api/v1/work-bays/{bayId}`
- **Proposito:** Recupera la informacion operativa y estado de ocupacion de una bahia fisica puntual, proyectando la orden de trabajo activa que alberga actualmente.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST), Mecanico (ROLE_MECHANIC) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:bays:read')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `bayId` (UUID): Identificador unico de la bahia fisica consultada

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.WorkBayResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la bahia |
| tenantId | UUID | Identificador del taller |
| branchId | UUID | Identificador de la sucursal |
| name | String | Nombre de la bahia |
| bayType | String | Tipologia operativa |
| status | String | Estado (AVAILABLE, OCCUPIED, MAINTENANCE) |
| currentWorkOrderId | UUID | Orden que ocupa la bahia o null si esta libre |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000301",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "branchId": "018f6c40-7e12-7000-8000-000000000050",
  "name": "Bahia 01 - Elevador Hidraulico Principal",
  "bayType": "MECHANICAL_LIFT",
  "status": "OCCUPIED",
  "currentWorkOrderId": "018f6c40-7e12-7000-8000-000000000100"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 404 Not Found | WorkBayNotFoundException | La bahia fisica solicitada no existe en el taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/work-bay-not-found",
  "title": "Bahia No Encontrada",
  "status": 404,
  "detail": "No se encontro ninguna bahia fisica con el identificador 018f6c40-7e12-7000-8000-000000000301",
  "instance": "/api/v1/work-bays/018f6c40-7e12-7000-8000-000000000301",
  "code": "WORK_BAY_NOT_FOUND",
  "timestamp": "2026-10-03T14:10:00Z"
}
```

---

### 4.4. [PUT] /api/v1/work-bays/{bayId}/maintenance

**Bloqueo Preventivo o Correctivo de Bahia por Mantenimiento**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.WorkBaysController`
- **Metodo Java:** `public ResponseEntity<WorkBayResource> setBayMaintenance(@PathVariable UUID bayId, @Valid @RequestBody MaintenanceBayResource resource)`
- **Ruta Base:** `/api/v1/work-bays`
- **Ruta Completa:** `/api/v1/work-bays/{bayId}/maintenance`
- **Proposito:** Inhabilita operativamente una bahia fisica por causa de mantenimiento de maquinaria, falla hidraulica o calibracion tecnica. Impide la transicion si la bahia se encuentra actualmente ocupada por un vehiculo en atencion.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Jefe de Taller (ROLE_WORKSHOP_MANAGER) o Administrador (ROLE_ADMIN)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:bays:manage')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `bayId` (UUID): Identificador unico de la bahia fisica a suspender

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.requests.MaintenanceBayResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| reason | String | Si | @NotBlank, @Size(max = 1000) | Justificacion tecnica formal del mantenimiento de maquinaria |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "reason": "Fuga de aceite en reten del cilindro hidraulico secundario del elevador. Requiere cambio de sellos y prueba de carga."
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.WorkBayResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la bahia |
| tenantId | UUID | Identificador del taller |
| branchId | UUID | Identificador de la sucursal |
| name | String | Nombre descriptivo de la bahia |
| bayType | String | Tipologia operativa |
| status | String | Nuevo estado operativo (MAINTENANCE) |
| currentWorkOrderId | UUID | Identificador de orden (null) |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000302",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "branchId": "018f6c40-7e12-7000-8000-000000000050",
  "name": "Bahia 02 - Elevador de Dos Columnas 4T",
  "bayType": "MECHANICAL_LIFT",
  "status": "MAINTENANCE",
  "currentWorkOrderId": null
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 404 Not Found | WorkBayNotFoundException | La bahia fisica no existe |
| 409 Conflict | WorkBayOccupiedException | La bahia no puede ponerse en mantenimiento porque alberga un vehiculo en atencion |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/work-bay-occupied",
  "title": "Bahia Fisicamente Ocupada",
  "status": 409,
  "detail": "No se puede poner en mantenimiento la bahia porque se encuentra ocupada por la orden 1042",
  "instance": "/api/v1/work-bays/018f6c40-7e12-7000-8000-000000000302/maintenance",
  "code": "WORK_BAY_OCCUPIED",
  "timestamp": "2026-10-03T14:15:00Z"
}
```

---

### 4.5. [PUT] /api/v1/work-bays/{bayId}/restore

**Restitucion de Bahia Fisica a Estado Disponible**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.WorkBaysController`
- **Metodo Java:** `public ResponseEntity<WorkBayResource> restoreBay(@PathVariable UUID bayId)`
- **Ruta Base:** `/api/v1/work-bays`
- **Ruta Completa:** `/api/v1/work-bays/{bayId}/restore`
- **Proposito:** Restaura la operatividad de una bahia fisica que se encontraba bajo mantenimiento tecnico o suspension preventiva, transicionandola al estado AVAILABLE para volver a recibir ordenes de trabajo vehiculares.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Jefe de Taller (ROLE_WORKSHOP_MANAGER) o Administrador (ROLE_ADMIN)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:bays:manage')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `bayId` (UUID): Identificador unico de la bahia fisica a rehabilitar

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.WorkBayResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la bahia |
| tenantId | UUID | Identificador del taller |
| branchId | UUID | Identificador de la sucursal |
| name | String | Nombre descriptivo de la bahia |
| bayType | String | Tipologia operativa |
| status | String | Nuevo estado operativo restablecido (AVAILABLE) |
| currentWorkOrderId | UUID | Identificador de orden (null) |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000302",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "branchId": "018f6c40-7e12-7000-8000-000000000050",
  "name": "Bahia 02 - Elevador de Dos Columnas 4T",
  "bayType": "MECHANICAL_LIFT",
  "status": "AVAILABLE",
  "currentWorkOrderId": null
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 404 Not Found | WorkBayNotFoundException | La bahia fisica no existe en el taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/work-bay-not-found",
  "title": "Bahia No Encontrada",
  "status": 404,
  "detail": "No se encontro la bahia para restituir operatividad",
  "instance": "/api/v1/work-bays/018f6c40-7e12-7000-8000-000000000302/restore",
  "code": "WORK_BAY_NOT_FOUND",
  "timestamp": "2026-10-03T14:20:00Z"
}
```

---

## 5. Endpoints del Catalogo Maestro de Servicios (ServicesController)

### 5.1. [POST] /api/v1/services

**Registro de Nuevo Servicio en el Tarifario Estandar**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.ServicesController`
- **Metodo Java:** `public ResponseEntity<ServiceResource> createService(@Valid @RequestBody CreateServiceResource resource)`
- **Ruta Base:** `/api/v1/services`
- **Ruta Completa:** `/api/v1/services`
- **Proposito:** Crea un nuevo servicio estandar de mano de obra en el catalogo maestro del taller. Define la tarifa base de referencia, la divisa monetaria y los minutos de duracion estimada previstos para la intervencion.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Jefe de Taller (ROLE_WORKSHOP_MANAGER) o Administrador (ROLE_ADMIN)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:services:manage')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.requests.CreateServiceResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| name | String | Si | @NotBlank, @Size(max = 150) | Nombre del servicio automotriz estandar |
| basePrice | BigDecimal | Si | @NotNull, @Positive | Tarifa base de mano de obra |
| currency | String | Si | @NotBlank, @Pattern(regexp = "PEN|USD") | Codigo ISO de la divisa |
| estimatedMinutes | int | Si | @Positive | Duracion estimada en minutos |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "name": "Alineacion Computarizada y Balanceo de Cuatro Ruedas",
  "basePrice": 90,
  "currency": "PEN",
  "estimatedMinutes": 45
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.ServiceResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico del servicio en catalogo |
| tenantId | UUID | Identificador del taller propietario |
| name | String | Nombre del servicio estandar |
| basePrice | BigDecimal | Tarifa base de mano de obra |
| currency | String | Divisa monetaria de cotizacion |
| estimatedMinutes | int | Tiempo estandar estimado en minutos |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000410",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "name": "Alineacion Computarizada y Balanceo de Cuatro Ruedas",
  "basePrice": 90,
  "currency": "PEN",
  "estimatedMinutes": 45
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 400 Bad Request | MethodArgumentNotValidException | Nombre en blanco, tarifa base negativa o duracion menor o igual a cero |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-argument",
  "title": "Parametros de Servicio Invalidos",
  "status": 400,
  "detail": "La tarifa base debe ser estrictamente positiva",
  "instance": "/api/v1/services",
  "code": "INVALID_ARGUMENT",
  "timestamp": "2026-10-03T14:25:00Z"
}
```

---

### 5.2. [GET] /api/v1/services

**Consulta del Catalogo Activo de Servicios del Taller**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.ServicesController`
- **Metodo Java:** `public ResponseEntity<List<ServiceResource>> getServices()`
- **Ruta Base:** `/api/v1/services`
- **Ruta Completa:** `/api/v1/services`
- **Proposito:** Retorna el tarifario completo y activo de servicios de mano de obra registrados en la sede del taller automotriz, para la seleccion y elaboracion de cotizaciones y ordenes de trabajo.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST), Mecanico (ROLE_MECHANIC) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:services:read')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `java.util.List<com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.ServiceResource>`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico del servicio |
| tenantId | UUID | Identificador del taller |
| name | String | Nombre del servicio estandar |
| basePrice | BigDecimal | Tarifa base de mano de obra |
| currency | String | Moneda |
| estimatedMinutes | int | Minutos estimados |

**Ejemplo de Carga Util JSON (Response):**
```json
[
  {
    "id": "018f6c40-7e12-7000-8000-000000000401",
    "tenantId": "018f6c40-7e12-7000-8000-000000000001",
    "name": "Mantenimiento Integral de Frenos Delanteros",
    "basePrice": 150,
    "currency": "PEN",
    "estimatedMinutes": 90
  },
  {
    "id": "018f6c40-7e12-7000-8000-000000000410",
    "tenantId": "018f6c40-7e12-7000-8000-000000000001",
    "name": "Alineacion Computarizada y Balanceo de Cuatro Ruedas",
    "basePrice": 90,
    "currency": "PEN",
    "estimatedMinutes": 45
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 401 Unauthorized | BadCredentialsException | Token JWT ausente o no valido |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/unauthorized",
  "title": "Sesion No Autorizada",
  "status": 401,
  "detail": "Se requiere un token Bearer valido para consultar el tarifario",
  "instance": "/api/v1/services",
  "code": "UNAUTHORIZED",
  "timestamp": "2026-10-03T14:30:00Z"
}
```

---

### 5.3. [GET] /api/v1/services/{serviceId}

**Detalle de Tarifa y Duracion Estimada de un Servicio**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.ServicesController`
- **Metodo Java:** `public ResponseEntity<ServiceResource> getServiceById(@PathVariable UUID serviceId)`
- **Ruta Base:** `/api/v1/services`
- **Ruta Completa:** `/api/v1/services/{serviceId}`
- **Proposito:** Recupera la definicion tarifaria puntual de un servicio de catalogo especifico por su identificador.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST), Mecanico (ROLE_MECHANIC) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:services:read')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `serviceId` (UUID): Identificador unico del servicio consultado

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.ServiceResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico del servicio |
| tenantId | UUID | Identificador del taller |
| name | String | Nombre del servicio estandar |
| basePrice | BigDecimal | Tarifa base de mano de obra |
| currency | String | Moneda |
| estimatedMinutes | int | Tiempo estandar en minutos |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000401",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "name": "Mantenimiento Integral de Frenos Delanteros",
  "basePrice": 150,
  "currency": "PEN",
  "estimatedMinutes": 90
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 404 Not Found | ServiceNotFoundException | El servicio de catalogo consultado no existe |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/service-not-found",
  "title": "Servicio No Encontrado",
  "status": 404,
  "detail": "No se encontro ningun servicio tarifario con el identificador 018f6c40-7e12-7000-8000-000000000401",
  "instance": "/api/v1/services/018f6c40-7e12-7000-8000-000000000401",
  "code": "SERVICE_NOT_FOUND",
  "timestamp": "2026-10-03T14:35:00Z"
}
```

---

### 5.4. [PUT] /api/v1/services/{serviceId}

**Actualizacion de Precio Base y Duracion Estimada de Servicio**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.operations.interfaces.rest.controllers.ServicesController`
- **Metodo Java:** `public ResponseEntity<ServiceResource> updateService(@PathVariable UUID serviceId, @Valid @RequestBody UpdateServiceResource resource)`
- **Ruta Base:** `/api/v1/services`
- **Ruta Completa:** `/api/v1/services/{serviceId}`
- **Proposito:** Actualiza los parametros comerciales y tecnicos de un servicio en el catalogo estandar: renombra la denominacion, ajusta la tarifa base de mano de obra o rectifica los minutos estimados de intervencion.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Jefe de Taller (ROLE_WORKSHOP_MANAGER) o Administrador (ROLE_ADMIN)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('operations:services:manage')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `serviceId` (UUID): Identificador unico del servicio a actualizar

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.requests.UpdateServiceResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| name | String | Si | @NotBlank, @Size(max = 150) | Nombre actualizado del servicio automotriz |
| basePrice | BigDecimal | Si | @NotNull, @Positive | Nueva tarifa base de mano de obra |
| currency | String | Si | @NotBlank, @Pattern(regexp = "PEN|USD") | Codigo ISO de la divisa |
| estimatedMinutes | int | Si | @Positive | Tiempo estandar rectificado en minutos |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "name": "Mantenimiento Integral de Frenos Delanteros y Purgado",
  "basePrice": 160,
  "currency": "PEN",
  "estimatedMinutes": 90
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.operations.interfaces.rest.resources.responses.ServiceResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico del servicio |
| tenantId | UUID | Identificador del taller |
| name | String | Denominacion actualizada |
| basePrice | BigDecimal | Nueva tarifa base |
| currency | String | Moneda |
| estimatedMinutes | int | Minutos estimados |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000401",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "name": "Mantenimiento Integral de Frenos Delanteros y Purgado",
  "basePrice": 160,
  "currency": "PEN",
  "estimatedMinutes": 90
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 400 Bad Request | MethodArgumentNotValidException | Datos de actualizacion invalidos o campos en blanco |
| 404 Not Found | ServiceNotFoundException | El servicio de catalogo no existe en el taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/service-not-found",
  "title": "Servicio No Encontrado",
  "status": 404,
  "detail": "No se encontro el servicio para actualizar",
  "instance": "/api/v1/services/018f6c40-7e12-7000-8000-000000000401",
  "code": "SERVICE_NOT_FOUND",
  "timestamp": "2026-10-03T14:40:00Z"
}
```

---

