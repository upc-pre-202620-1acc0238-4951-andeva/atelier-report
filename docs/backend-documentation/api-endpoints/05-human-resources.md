# Especificación Canónica de Endpoints REST: Human Resources & Staff Management

El Bounded Context **Human Resources & Staff Management** (`com.andeva.atelier.platform.hr`) gestiona integralmente el capital humano y la fuerza técnica del taller mecánico automotriz. Sus responsabilidades operativas abarcan la parametrización de jornadas y turnos de trabajo, la marcación de asistencia con validación perimétrica geodésica mediante coordenadas satelitales WGS84 y algoritmo de Haversine, el control de tardanzas, ausencias y justificaciones administrativas, la liquidación periódica analítica de nóminas salariales con partidas de ingresos y descuentos, y la administración de expedientes laborales de colaboradores adscritos a cada sucursal física.

---

## 1. Arquitectura de Seguridad y Convenciones Globales

Todos los endpoints documentados en esta especificación se adhieren a los siguientes estándares de la plataforma Atelier:
* **Autenticación:** Cabecera obligatoria `Authorization: Bearer <JWT>`. El token debe incluir los claims `tenant_id`, `membership_id` y la lista de privilegios del usuario (`permissions`).
* **Aislamiento Multi-Inquilino:** La separación lógica y de seguridad se garantiza validando el claim `tenant_id` contenido en el token criptográfico, contrastado con la cabecera opcional `X-Tenant-Id`. Toda operación a nivel de repositorio y base de datos aplica el filtro estricto `WHERE tenant_id = :tenantId`.
* **Control de Acceso Basado en Permisos Atómicos:** La autorización a nivel de método se implementa mediante `@PreAuthorize("hasAuthority('...')")` en cada endpoint del controlador Spring Boot.
* **Manejo Estandarizado de Errores (RFC 7807):** Toda condición de error sintáctico, de seguridad o de regla de negocio retorna una carga útil en formato `application/problem+json` con tipo, título, código HTTP, detalle del incidente, marca temporal e identificador único de correlación.
* **Idempotencia y Concurrencia:** Los métodos de modificación soportan control de concurrencia optimista mediante el atributo `version` en entidades relacionales de PostgreSQL.

---

## 2. Índice Canónico de Endpoints

| Método | Ruta Relativa | Controlador Java | Permiso Atómico Requerido | Rol Mínimo Sugerido |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/api/v1/hr/work-shifts` | `WorkShiftsController` | `hr:shifts:manage` | Administrador de Taller |
| `GET` | `/api/v1/hr/work-shifts` | `WorkShiftsController` | `hr:shifts:read` | Técnico Mecánico |
| `GET` | `/api/v1/hr/work-shifts/{shiftId}` | `WorkShiftsController` | `hr:shifts:read` | Técnico Mecánico |
| `PUT` | `/api/v1/hr/work-shifts/{shiftId}` | `WorkShiftsController` | `hr:shifts:manage` | Administrador de Taller |
| `PATCH` | `/api/v1/hr/work-shifts/{shiftId}/activate` | `WorkShiftsController` | `hr:shifts:manage` | Administrador de Taller |
| `PATCH` | `/api/v1/hr/work-shifts/{shiftId}/deactivate` | `WorkShiftsController` | `hr:shifts:manage` | Administrador de Taller |
| `POST` | `/api/v1/hr/attendances/clock-in` | `AttendanceController` | `hr:attendance:clock_in` | Técnico Mecánico |
| `POST` | `/api/v1/hr/attendances/clock-out` | `AttendanceController` | `hr:attendance:clock_out` | Técnico Mecánico |
| `POST` | `/api/v1/hr/attendances/{attendanceId}/justify` | `AttendanceController` | `hr:justifications:approve` | Mecánico Jefe |
| `GET` | `/api/v1/hr/attendances/branch/{branchId}` | `AttendanceController` | `hr:attendance:audit_all` | Mecánico Jefe |
| `GET` | `/api/v1/hr/attendances/employee/{membershipId}/history` | `AttendanceController` | `hr:attendance:audit_all` / `hr:attendance:read_own` | Técnico Mecánico |
| `GET` | `/api/v1/hr/attendances/employee/{membershipId}/active` | `AttendanceController` | `hr:attendance:audit_all` / `hr:attendance:read_own` | Técnico Mecánico |
| `POST` | `/api/v1/hr/payrolls/generate` | `PayrollPaymentsController` | `iam:members:compensate` | Administrador de Taller |
| `GET` | `/api/v1/hr/payrolls` | `PayrollPaymentsController` | `iam:members:compensate` | Administrador de Taller |
| `GET` | `/api/v1/hr/payrolls/{payrollId}` | `PayrollPaymentsController` | `iam:members:compensate` | Administrador de Taller |
| `POST` | `/api/v1/hr/payrolls/{payrollId}/deductions` | `PayrollPaymentsController` | `iam:members:compensate` | Administrador de Taller |
| `POST` | `/api/v1/hr/payrolls/{payrollId}/bonuses` | `PayrollPaymentsController` | `iam:members:compensate` | Administrador de Taller |
| `POST` | `/api/v1/hr/payrolls/{payrollId}/calculate` | `PayrollPaymentsController` | `iam:members:compensate` | Administrador de Taller |
| `POST` | `/api/v1/hr/payrolls/{payrollId}/disburse` | `PayrollPaymentsController` | `iam:members:compensate` | Administrador de Taller |
| `GET` | `/api/v1/hr/payrolls/export/sunat-rem` | `PayrollPaymentsController` | `hr:plame:export` | Administrador de Taller |
| `POST` | `/api/v1/hr/employees` | `StaffProfilesController` | `iam:members:manage_roles` | Administrador de Taller |
| `GET` | `/api/v1/hr/employees/{profileId}` | `StaffProfilesController` | `iam:members:read` | Mecánico Jefe |
| `GET` | `/api/v1/hr/employees/membership/{membershipId}` | `StaffProfilesController` | `iam:members:read` | Técnico Mecánico |
| `GET` | `/api/v1/hr/employees/branch/{branchId}` | `StaffProfilesController` | `iam:members:read` | Mecánico Jefe |
| `PUT` | `/api/v1/hr/employees/{profileId}/shift` | `StaffProfilesController` | `hr:shifts:manage` | Administrador de Taller |
| `PUT` | `/api/v1/hr/employees/{profileId}/salary` | `StaffProfilesController` | `iam:members:compensate` | Administrador de Taller |
| `PATCH` | `/api/v1/hr/employees/{profileId}/status` | `StaffProfilesController` | `iam:members:manage_roles` | Administrador de Taller |

---

## 3. Endpoints de WorkShiftsController

El controlador `WorkShiftsController` administra la configuración, consulta y ciclo de vigencia de las jornadas y turnos de trabajo dentro del taller automotriz. Facilita la parametrización de horas límite y márgenes de tolerancia.

### POST /api/v1/hr/work-shifts

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.WorkShiftsController`
* **Método Java:** `public ResponseEntity<WorkShiftResource> createWorkShift(@RequestHeader("X-Tenant-Id") UUID tenantId, @Valid @RequestBody CreateWorkShiftResource resource)`

#### Descripción Funcional
Crea y parametriza un nuevo turno o jornada laboral para el taller mecánico automotriz. Establece los horarios reglamentarios de apertura y finalización de faenas en bahías y fosas de mantenimiento, junto con el margen de tolerancia en minutos otorgado a los mecánicos antes de computar penalidades por tardanza.

#### Seguridad y Autorización
* **Rol Mínimo:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueño de Taller (ROLE_WORKSHOP_OWNER).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('hr:shifts:manage')")`
* **Contexto Multi-Inquilino:** El turno se asocia de forma obligatoria e inmutable al tenant_id derivado del token JWT verificado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:** Ninguno.
* **Query Parameters:** Ninguno.

#### Cuerpo de Petición (Request DTO)
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.requests.CreateWorkShiftResource`

| Campo | Tipo Java | Restricciones y Validaciones | Descripción |
| :--- | :--- | :--- | :--- |
| `name` | `String` | @NotBlank, @Size(max = 100) | Denominación descriptiva del turno laboral dentro del taller |
| `startTime` | `LocalTime` | @NotNull | Hora oficial de inicio de jornada laboral en formato HH:mm:ss |
| `endTime` | `LocalTime` | @NotNull | Hora oficial de cierre de jornada laboral en formato HH:mm:ss |
| `gracePeriodMinutes` | `int` | @Min(0), @Max(60) | Tolerancia en minutos admitida antes de computar tardanza en el ingreso |


```json
{
  "name": "Turno Central Diurno",
  "startTime": "08:00:00",
  "endTime": "17:30:00",
  "gracePeriodMinutes": 15
}
```
#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `201 CREATED`
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.responses.WorkShiftResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador único asignado al turno |
| `name` | `String` | Denominación oficial del turno laboral |
| `startTime` | `LocalTime` | Hora programada de apertura |
| `endTime` | `LocalTime` | Hora programada de cierre |
| `gracePeriodMinutes` | `int` | Minutos de gracia configurados |
| `isActive` | `boolean` | Indicador de vigencia operativa del turno |


```json
{
  "id": "e3b0c442-98fc-4c14-9afe-0c07c4587123",
  "name": "Turno Central Diurno",
  "startTime": "08:00:00",
  "endTime": "17:30:00",
  "gracePeriodMinutes": 15,
  "isActive": true
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 400 Bad Request | `https://api.atelier.pe/errors/invalid-argument` | `MethodArgumentNotValidException` | Campos requeridos faltantes o valores de tiempo y tolerancia fuera de rango |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Credencial Bearer ausente o inválida en el encabezado de autorización |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | El usuario autenticado carece del permiso hr:shifts:manage |
| 409 Conflict | `https://api.atelier.pe/errors/shift-conflict` | `ShiftConflictException` | Ya existe un turno con la misma denominación para este taller |


```json
{
  "type": "https://api.atelier.pe/errors/shift-conflict",
  "title": "Conflicto en Turno Laboral",
  "status": 409,
  "detail": "El taller ya cuenta con un turno registrado bajo el nombre Turno Central Diurno.",
  "instance": "/api/v1/hr/work-shifts",
  "timestamp": "2026-10-01T15:30:00Z",
  "correlationId": "req-shift-409-01"
}
```

---

### GET /api/v1/hr/work-shifts

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.WorkShiftsController`
* **Método Java:** `public ResponseEntity<List<WorkShiftResource>> getAllWorkShifts(@RequestHeader("X-Tenant-Id") UUID tenantId)`

#### Descripción Funcional
Recupera el listado completo de turnos laborales registrados en el taller automotriz autenticado, incluyendo turnos activos e inactivos. Permite al personal técnico y administrativo consultar los esquemas horarios vigentes.

#### Seguridad y Autorización
* **Rol Mínimo:** Técnico Mecánico (ROLE_MECHANIC) o cualquier rol operativo con acceso de lectura.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('hr:shifts:read')")`
* **Contexto Multi-Inquilino:** Filtra estrictamente los registros asociados al tenant_id del usuario autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:** Ninguno.
* **Query Parameters:** Ninguno.

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `List<com.andeva.atelier.platform.hr.interfaces.rest.resources.responses.WorkShiftResource>`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador único del turno |
| `name` | `String` | Nombre del turno laboral |
| `startTime` | `LocalTime` | Hora de inicio |
| `endTime` | `LocalTime` | Hora de finalización |
| `gracePeriodMinutes` | `int` | Tolerancia en minutos |
| `isActive` | `boolean` | Estado operativo del turno |


```json
[
  {
    "id": "e3b0c442-98fc-4c14-9afe-0c07c4587123",
    "name": "Turno Central Diurno",
    "startTime": "08:00:00",
    "endTime": "17:30:00",
    "gracePeriodMinutes": 15,
    "isActive": true
  },
  {
    "id": "f81d4fae-7dec-11d0-a765-00a0c91e6bf6",
    "name": "Guardia Sabatina",
    "startTime": "08:30:00",
    "endTime": "13:00:00",
    "gracePeriodMinutes": 10,
    "isActive": true
  }
]
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o expirado |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | El usuario carece del permiso hr:shifts:read |


```json
{
  "type": "https://api.atelier.pe/errors/unauthorized",
  "title": "No Autorizado",
  "status": 401,
  "detail": "La credencial de autenticacion ha expirado o no es valida.",
  "instance": "/api/v1/hr/work-shifts",
  "timestamp": "2026-10-01T15:31:00Z",
  "correlationId": "req-shift-401-01"
}
```

---

### GET /api/v1/hr/work-shifts/{shiftId}

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.WorkShiftsController`
* **Método Java:** `public ResponseEntity<WorkShiftResource> getWorkShiftById(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("shiftId") UUID shiftId)`

#### Descripción Funcional
Obtiene la información técnica y operativa detallada de un turno laboral específico a partir de su identificador único universal. Verifica que el turno pertenezca al taller autenticado.

#### Seguridad y Autorización
* **Rol Mínimo:** Técnico Mecánico (ROLE_MECHANIC) o rol operativo equivalente.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('hr:shifts:read')")`
* **Contexto Multi-Inquilino:** Valida pertenencia estricta del turno al tenant_id solicitante.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `shiftId` (UUID): Identificador único del turno laboral consultado
* **Query Parameters:** Ninguno.

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.responses.WorkShiftResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del turno |
| `name` | `String` | Nombre del turno |
| `startTime` | `LocalTime` | Hora de inicio de faena |
| `endTime` | `LocalTime` | Hora de clausura de faena |
| `gracePeriodMinutes` | `int` | Tolerancia en minutos |
| `isActive` | `boolean` | Estado de vigencia operativa |


```json
{
  "id": "e3b0c442-98fc-4c14-9afe-0c07c4587123",
  "name": "Turno Central Diurno",
  "startTime": "08:00:00",
  "endTime": "17:30:00",
  "gracePeriodMinutes": 15,
  "isActive": true
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Credencial JWT no suministrada o inválida |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | El usuario no posee el permiso hr:shifts:read |
| 404 Not Found | `https://api.atelier.pe/errors/work-shift-not-found` | `WorkShiftNotFoundException` | El turno solicitado no existe o pertenece a otro taller |


```json
{
  "type": "https://api.atelier.pe/errors/work-shift-not-found",
  "title": "Turno Laboral No Encontrado",
  "status": 404,
  "detail": "No se encontro ningun turno con identificador e3b0c442-98fc-4c14-9afe-0c07c4587999 en este taller.",
  "instance": "/api/v1/hr/work-shifts/e3b0c442-98fc-4c14-9afe-0c07c4587999",
  "timestamp": "2026-10-01T15:32:00Z",
  "correlationId": "req-shift-404-01"
}
```

---

### PUT /api/v1/hr/work-shifts/{shiftId}

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.WorkShiftsController`
* **Método Java:** `public ResponseEntity<WorkShiftResource> updateWorkShift(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("shiftId") UUID shiftId, @Valid @RequestBody UpdateWorkShiftResource resource)`

#### Descripción Funcional
Actualiza los parámetros operativos de un turno de trabajo existente, incluyendo su denominación, horarios de jornada y minutos de tolerancia por tardanza. Aplica control de concurrencia optimista.

#### Seguridad y Autorización
* **Rol Mínimo:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueño de Taller (ROLE_WORKSHOP_OWNER).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('hr:shifts:manage')")`
* **Contexto Multi-Inquilino:** Valida que el turno pertenezca al tenant_id autenticado antes de persistir cambios.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `shiftId` (UUID): Identificador único del turno que se desea actualizar
* **Query Parameters:** Ninguno.

#### Cuerpo de Petición (Request DTO)
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.requests.UpdateWorkShiftResource`

| Campo | Tipo Java | Restricciones y Validaciones | Descripción |
| :--- | :--- | :--- | :--- |
| `name` | `String` | @NotBlank, @Size(max = 100) | Nueva denominación descriptiva del turno laboral |
| `startTime` | `LocalTime` | @NotNull | Nueva hora de inicio de jornada |
| `endTime` | `LocalTime` | @NotNull | Nueva hora de cierre de jornada |
| `gracePeriodMinutes` | `int` | @Min(0), @Max(60) | Nueva tolerancia en minutos |


```json
{
  "name": "Turno Central Ampliado",
  "startTime": "07:30:00",
  "endTime": "17:30:00",
  "gracePeriodMinutes": 20
}
```
#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.responses.WorkShiftResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del turno actualizado |
| `name` | `String` | Denominación actualizada |
| `startTime` | `LocalTime` | Hora de inicio actualizada |
| `endTime` | `LocalTime` | Hora de finalización actualizada |
| `gracePeriodMinutes` | `int` | Tolerancia actualizada |
| `isActive` | `boolean` | Estado de vigencia operativa |


```json
{
  "id": "e3b0c442-98fc-4c14-9afe-0c07c4587123",
  "name": "Turno Central Ampliado",
  "startTime": "07:30:00",
  "endTime": "17:30:00",
  "gracePeriodMinutes": 20,
  "isActive": true
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 400 Bad Request | `https://api.atelier.pe/errors/invalid-argument` | `MethodArgumentNotValidException` | Horas inválidas o tolerancia superior a 60 minutos |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | El usuario carece del permiso hr:shifts:manage |
| 404 Not Found | `https://api.atelier.pe/errors/work-shift-not-found` | `WorkShiftNotFoundException` | El turno indicado no existe en el taller |
| 409 Conflict | `https://api.atelier.pe/errors/shift-conflict` | `ShiftConflictException` | El nombre especificado colisiona con otro turno del taller |


```json
{
  "type": "https://api.atelier.pe/errors/shift-conflict",
  "title": "Conflicto en Actualizacion de Turno",
  "status": 409,
  "detail": "Ya existe otro turno configurado con el nombre Turno Central Ampliado.",
  "instance": "/api/v1/hr/work-shifts/e3b0c442-98fc-4c14-9afe-0c07c4587123",
  "timestamp": "2026-10-01T15:33:00Z",
  "correlationId": "req-shift-409-02"
}
```

---

### PATCH /api/v1/hr/work-shifts/{shiftId}/activate

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.WorkShiftsController`
* **Método Java:** `public ResponseEntity<Void> activateWorkShift(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("shiftId") UUID shiftId)`

#### Descripción Funcional
Restaura la vigencia y disponibilidad operativa de un turno laboral que se encontraba deshabilitado. Permite que vuelva a ser asignado a empleados o utilizado en marcaciones presenciales.

#### Seguridad y Autorización
* **Rol Mínimo:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueño de Taller (ROLE_WORKSHOP_OWNER).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('hr:shifts:manage')")`
* **Contexto Multi-Inquilino:** Exige concordancia entre el tenant_id del usuario y el turno objetivo.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `shiftId` (UUID): Identificador único del turno que se activará
* **Query Parameters:** Ninguno.

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `204 NO CONTENT`
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permisos insuficientes para activar turnos |
| 404 Not Found | `https://api.atelier.pe/errors/work-shift-not-found` | `WorkShiftNotFoundException` | Turno no encontrado en el taller |


```json
{
  "type": "https://api.atelier.pe/errors/work-shift-not-found",
  "title": "Turno No Encontrado",
  "status": 404,
  "detail": "No se pudo activar el turno debido a que el identificador no existe en el taller.",
  "instance": "/api/v1/hr/work-shifts/e3b0c442-98fc-4c14-9afe-0c07c4587999/activate",
  "timestamp": "2026-10-01T15:34:00Z",
  "correlationId": "req-shift-404-02"
}
```

---

### PATCH /api/v1/hr/work-shifts/{shiftId}/deactivate

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.WorkShiftsController`
* **Método Java:** `public ResponseEntity<Void> deactivateWorkShift(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("shiftId") UUID shiftId)`

#### Descripción Funcional
Inhabilita un turno laboral para impedir que nuevos colaboradores sean asignados a él. Los colaboradores con el turno previamente asignado mantienen su registro histórico pero no podrán generar nuevas marcaciones.

#### Seguridad y Autorización
* **Rol Mínimo:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueño de Taller (ROLE_WORKSHOP_OWNER).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('hr:shifts:manage')")`
* **Contexto Multi-Inquilino:** Verifica pertenencia del recurso al tenant_id de la petición.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `shiftId` (UUID): Identificador único del turno que se desactivará
* **Query Parameters:** Ninguno.

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `204 NO CONTENT`
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token de acceso no autenticado |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso hr:shifts:manage denegado |
| 404 Not Found | `https://api.atelier.pe/errors/work-shift-not-found` | `WorkShiftNotFoundException` | Turno no encontrado en el taller |


```json
{
  "type": "https://api.atelier.pe/errors/work-shift-not-found",
  "title": "Turno No Encontrado",
  "status": 404,
  "detail": "No se encontro el turno para su desactivacion operativa.",
  "instance": "/api/v1/hr/work-shifts/e3b0c442-98fc-4c14-9afe-0c07c4587999/deactivate",
  "timestamp": "2026-10-01T15:35:00Z",
  "correlationId": "req-shift-404-03"
}
```

---

## 4. Endpoints de AttendanceController

El controlador `AttendanceController` es el punto de entrada para el registro perimétrico geocercado de entradas y salidas de los operarios de taller, la consulta de estados de actividad y la regularización justificada de tardanzas o inasistencias.

### POST /api/v1/hr/attendances/clock-in

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.AttendanceController`
* **Método Java:** `public ResponseEntity<AttendanceResource> clockIn(@RequestHeader("X-Tenant-Id") UUID tenantId, @AuthenticationPrincipal UserPrincipal principal, @Valid @RequestBody ClockInRequest request)`

#### Descripción Funcional
Registra el ingreso laboral presencial de un técnico o colaborador del taller. Valida en tiempo real las coordenadas satelitales WGS84 del dispositivo móvil contra el polígono o radio de geocerca perimétrica configurado para la sucursal física mediante el algoritmo de Haversine. Si la distancia supera el límite permitido, rechaza la operación. Adicionalmente, verifica la vigencia del turno asignado y calcula si el ingreso califica como puntual o tardanza evaluando los minutos de gracia.

#### Seguridad y Autorización
* **Rol Mínimo:** Técnico Mecánico (ROLE_MECHANIC) o rol operativo adscrito al taller.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('hr:attendance:clock_in')")`
* **Contexto Multi-Inquilino:** El registro se vincula unívocamente al tenant_id y membership_id extraídos del token JWT autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:** Ninguno.
* **Query Parameters:** Ninguno.

#### Cuerpo de Petición (Request DTO)
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.requests.ClockInRequest`

| Campo | Tipo Java | Restricciones y Validaciones | Descripción |
| :--- | :--- | :--- | :--- |
| `branchId` | `UUID` | @NotNull | Identificador único de la sucursal física donde labora el técnico |
| `shiftId` | `UUID` | @NotNull | Identificador del turno laboral correspondiente a la jornada |
| `latitude` | `Double` | @NotNull, @DecimalMin("-90.0"), @DecimalMax("90.0") | Latitud geográfica WGS84 capturada por el sensor GPS del dispositivo móvil |
| `longitude` | `Double` | @NotNull, @DecimalMin("-180.0"), @DecimalMax("180.0") | Longitud geográfica WGS84 capturada por el sensor GPS del dispositivo móvil |


```json
{
  "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
  "shiftId": "e3b0c442-98fc-4c14-9afe-0c07c4587123",
  "latitude": -12.096521,
  "longitude": -77.035412
}
```
#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `201 CREATED`
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.responses.AttendanceResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador único del registro de asistencia generado |
| `branchId` | `UUID` | Sede física en la cual se efectuó la marcación |
| `membershipId` | `UUID` | Membresía institucional del colaborador |
| `shiftId` | `UUID` | Turno evaluado |
| `clockIn` | `Instant` | Marca temporal UTC exacta de entrada |
| `clockOut` | `Instant` | Marca temporal UTC de salida (nula al ingresar) |
| `status` | `String` | Calificación de la asistencia (ON_TIME, LATE, EXCUSED) |
| `latitude` | `Double` | Latitud registrada |
| `longitude` | `Double` | Longitud registrada |
| `distanceToBranchMeters` | `Double` | Distancia calculada en metros al centroide del taller |
| `justificationReason` | `String` | Motivo de tardanza (nulo al registrar ingreso regular) |
| `justifiedBy` | `UUID` | Supervisor que aprobó la justificación (nulo inicialmente) |
| `justifiedAt` | `Instant` | Fecha y hora de justificación (nula inicialmente) |


```json
{
  "id": "a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d",
  "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
  "membershipId": "c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f",
  "shiftId": "e3b0c442-98fc-4c14-9afe-0c07c4587123",
  "clockIn": "2026-10-01T13:05:12Z",
  "clockOut": null,
  "status": "ON_TIME",
  "latitude": -12.096521,
  "longitude": -77.035412,
  "distanceToBranchMeters": 14.8,
  "justificationReason": null,
  "justifiedBy": null,
  "justifiedAt": null
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 400 Bad Request | `https://api.atelier.pe/errors/invalid-argument` | `MethodArgumentNotValidException` | Faltan coordenadas o identificadores requeridos |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | El usuario no posee el permiso hr:attendance:clock_in |
| 409 Conflict | `https://api.atelier.pe/errors/duplicate-attendance` | `DuplicateActiveAttendanceException` | El técnico ya cuenta con una jornada laboral abierta y sin marcar salida |
| 422 Unprocessable Entity | `https://api.atelier.pe/errors/geofence-violation` | `GeofenceViolationException` | La ubicación satelital se encuentra fuera del perímetro geocercado del taller |


```json
{
  "type": "https://api.atelier.pe/errors/geofence-violation",
  "title": "Violacion de Geocerca de Asistencia",
  "status": 422,
  "detail": "La posicion reportada dista 452.3 metros del centroide del taller, superando la tolerancia maxima perimetral de 100 metros.",
  "instance": "/api/v1/hr/attendances/clock-in",
  "timestamp": "2026-10-01T13:05:12Z",
  "correlationId": "req-clockin-422-01"
}
```

---

### POST /api/v1/hr/attendances/clock-out

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.AttendanceController`
* **Método Java:** `public ResponseEntity<AttendanceResource> clockOut(@RequestHeader("X-Tenant-Id") UUID tenantId, @AuthenticationPrincipal UserPrincipal principal, @Valid @RequestBody ClockOutRequest request)`

#### Descripción Funcional
Registra la culminación de la jornada laboral diaria de un colaborador, cerrando el registro de asistencia activo y calculando la duración efectiva total en horas y minutos computables para el cálculo de nómina.

#### Seguridad y Autorización
* **Rol Mínimo:** Técnico Mecánico (ROLE_MECHANIC) o rol operativo adscrito.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('hr:attendance:clock_out')")`
* **Contexto Multi-Inquilino:** Valida que la marcación pertenezca al membership_id y tenant_id autenticados.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:** Ninguno.
* **Query Parameters:** Ninguno.

#### Cuerpo de Petición (Request DTO)
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.requests.ClockOutRequest`

| Campo | Tipo Java | Restricciones y Validaciones | Descripción |
| :--- | :--- | :--- | :--- |
| `attendanceId` | `UUID` | @NotNull | Identificador del registro de asistencia que se desea liquidar y cerrar |
| `clockOutTime` | `Instant` | @NotNull | Marca temporal UTC en la que se registra la salida efectiva |


```json
{
  "attendanceId": "a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d",
  "clockOutTime": "2026-10-01T22:30:00Z"
}
```
#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.responses.AttendanceResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del registro de asistencia |
| `branchId` | `UUID` | Sucursal física del taller |
| `membershipId` | `UUID` | Membresía del técnico |
| `shiftId` | `UUID` | Turno de la jornada |
| `clockIn` | `Instant` | Hora de entrada |
| `clockOut` | `Instant` | Hora de salida registrada |
| `status` | `String` | Estado definitivo de la asistencia |
| `latitude` | `Double` | Latitud de ingreso |
| `longitude` | `Double` | Longitud de ingreso |
| `distanceToBranchMeters` | `Double` | Distancia calculada en el ingreso |
| `justificationReason` | `String` | Motivo de tardanza si existiera |
| `justifiedBy` | `UUID` | Identificador del supervisor que justificó |
| `justifiedAt` | `Instant` | Marca temporal de la justificación |


```json
{
  "id": "a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d",
  "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
  "membershipId": "c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f",
  "shiftId": "e3b0c442-98fc-4c14-9afe-0c07c4587123",
  "clockIn": "2026-10-01T13:05:12Z",
  "clockOut": "2026-10-01T22:30:00Z",
  "status": "ON_TIME",
  "latitude": -12.096521,
  "longitude": -77.035412,
  "distanceToBranchMeters": 14.8,
  "justificationReason": null,
  "justifiedBy": null,
  "justifiedAt": null
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 400 Bad Request | `https://api.atelier.pe/errors/invalid-clock-out` | `InvalidAttendanceClockOutException` | La hora de salida es cronológicamente anterior a la hora de ingreso o la marcación ya estaba cerrada |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso hr:attendance:clock_out no concedido |
| 404 Not Found | `https://api.atelier.pe/errors/attendance-not-found` | `AttendanceRecordNotFoundException` | El registro de asistencia especificado no existe o no corresponde al usuario autenticado |


```json
{
  "type": "https://api.atelier.pe/errors/invalid-clock-out",
  "title": "Egreso Invalido",
  "status": 400,
  "detail": "La marca temporal de salida no puede ser anterior a la marca temporal de ingreso registrada a las 13:05:12 UTC.",
  "instance": "/api/v1/hr/attendances/clock-out",
  "timestamp": "2026-10-01T22:31:00Z",
  "correlationId": "req-clockout-400-01"
}
```

---

### POST /api/v1/hr/attendances/{attendanceId}/justify

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.AttendanceController`
* **Método Java:** `public ResponseEntity<AttendanceResource> justifyAttendance(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("attendanceId") UUID attendanceId, @Valid @RequestBody JustifyAttendanceRequest request)`

#### Descripción Funcional
Permite a un supervisor administrativo o jefe de taller regularizar formalmente un registro de asistencia clasificado como tardanza o falta justificada. Registra el descargo legal, cambia el estado a EXCUSED y almacena la auditoría del supervisor que autorizó la regularización.

#### Seguridad y Autorización
* **Rol Mínimo:** Mecánico Jefe (ROLE_CHIEF_MECHANIC) o Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('hr:justifications:approve')")`
* **Contexto Multi-Inquilino:** Valida que el registro pertenezca a la sucursal y tenant administrado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `attendanceId` (UUID): Identificador del registro de marcación que se desea justificar
* **Query Parameters:** Ninguno.

#### Cuerpo de Petición (Request DTO)
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.requests.JustifyAttendanceRequest`

| Campo | Tipo Java | Restricciones y Validaciones | Descripción |
| :--- | :--- | :--- | :--- |
| `reason` | `String` | @NotBlank, @Size(max = 500) | Glosa o motivo formal que sustenta la regularización administrativa |


```json
{
  "reason": "Tardanza ocasionada por congestion vehicular severa documentada en via expresa. El colaborador compenso los minutos al cierre."
}
```
#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.responses.AttendanceResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del registro |
| `branchId` | `UUID` | Sucursal del taller |
| `membershipId` | `UUID` | Membresía del técnico |
| `shiftId` | `UUID` | Turno evaluado |
| `clockIn` | `Instant` | Hora de entrada |
| `clockOut` | `Instant` | Hora de salida |
| `status` | `String` | Estado actualizado a EXCUSED |
| `latitude` | `Double` | Latitud registrada |
| `longitude` | `Double` | Longitud registrada |
| `distanceToBranchMeters` | `Double` | Distancia calculada |
| `justificationReason` | `String` | Texto del descargo aprobado |
| `justifiedBy` | `UUID` | Identificador del supervisor que autorizó |
| `justifiedAt` | `Instant` | Marca temporal de aprobación del descargo |


```json
{
  "id": "a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d",
  "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
  "membershipId": "c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f",
  "shiftId": "e3b0c442-98fc-4c14-9afe-0c07c4587123",
  "clockIn": "2026-10-01T13:35:00Z",
  "clockOut": "2026-10-01T22:30:00Z",
  "status": "EXCUSED",
  "latitude": -12.096521,
  "longitude": -77.035412,
  "distanceToBranchMeters": 14.8,
  "justificationReason": "Tardanza ocasionada por congestion vehicular severa documentada en via expresa. El colaborador compenso los minutos al cierre.",
  "justifiedBy": "f4a5b6c7-d8e9-4012-3456-7890abcdef12",
  "justifiedAt": "2026-10-01T14:10:00Z"
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 400 Bad Request | `https://api.atelier.pe/errors/not-justifiable` | `AttendanceNotJustifiableException` | El registro no califica para justificación o ya fue cerrado formalmente |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Credencial JWT no suministrada o inválida |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | El rol no posee la autoridad hr:justifications:approve |
| 404 Not Found | `https://api.atelier.pe/errors/attendance-not-found` | `AttendanceRecordNotFoundException` | El identificador de marcación no existe en el taller |


```json
{
  "type": "https://api.atelier.pe/errors/not-justifiable",
  "title": "Marcacion No Justificable",
  "status": 400,
  "detail": "La marcacion indicada ya se encuentra calificada como puntual y no requiere justificacion administrativa.",
  "instance": "/api/v1/hr/attendances/a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d/justify",
  "timestamp": "2026-10-01T14:11:00Z",
  "correlationId": "req-justify-400-01"
}
```

---

### GET /api/v1/hr/attendances/branch/{branchId}

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.AttendanceController`
* **Método Java:** `public ResponseEntity<List<AttendanceResource>> getAttendancesByBranch(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("branchId") UUID branchId, @RequestParam(value = "date", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date)`

#### Descripción Funcional
Lista todas las marcaciones presenciales registradas en una sucursal física determinada para una fecha de corte específica. Si no se suministra el parámetro date, el backend asume la fecha actual del servidor en la zona horaria del taller.

#### Seguridad y Autorización
* **Rol Mínimo:** Mecánico Jefe (ROLE_CHIEF_MECHANIC) o Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('hr:attendance:audit_all')")`
* **Contexto Multi-Inquilino:** Valida que la sucursal branchId pertenezca al tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `branchId` (UUID): Identificador único de la sucursal física del taller
* **Query Parameters:**
  * `date` (LocalDate, Opcional): Fecha de consulta en formato YYYY-MM-DD. Si se omite, retorna el día de hoy

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `List<com.andeva.atelier.platform.hr.interfaces.rest.resources.responses.AttendanceResource>`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la marcación |
| `branchId` | `UUID` | Identificador de la sucursal |
| `membershipId` | `UUID` | Membresía del empleado |
| `shiftId` | `UUID` | Turno evaluado |
| `clockIn` | `Instant` | Hora de entrada |
| `clockOut` | `Instant` | Hora de salida |
| `status` | `String` | Estado de la asistencia |
| `latitude` | `Double` | Latitud registrada |
| `longitude` | `Double` | Longitud registrada |
| `distanceToBranchMeters` | `Double` | Distancia calculada al taller |
| `justificationReason` | `String` | Descargo si existe |
| `justifiedBy` | `UUID` | Supervisor que aprobó |
| `justifiedAt` | `Instant` | Marca temporal de justificación |


```json
[
  {
    "id": "a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d",
    "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
    "membershipId": "c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f",
    "shiftId": "e3b0c442-98fc-4c14-9afe-0c07c4587123",
    "clockIn": "2026-10-01T13:05:12Z",
    "clockOut": "2026-10-01T22:30:00Z",
    "status": "ON_TIME",
    "latitude": -12.096521,
    "longitude": -77.035412,
    "distanceToBranchMeters": 14.8,
    "justificationReason": null,
    "justifiedBy": null,
    "justifiedAt": null
  }
]
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso hr:attendance:audit_all denegado |
| 404 Not Found | `https://api.atelier.pe/errors/branch-not-found` | `BranchNotFoundException` | La sucursal solicitada no existe o no corresponde al taller |


```json
{
  "type": "https://api.atelier.pe/errors/branch-not-found",
  "title": "Sucursal No Encontrada",
  "status": 404,
  "detail": "No se encontro la sede fisica especificada para consultar marcaciones.",
  "instance": "/api/v1/hr/attendances/branch/b8c3d9a1-4567-4e89-9123-abcdef012999",
  "timestamp": "2026-10-01T15:00:00Z",
  "correlationId": "req-branch-att-404-01"
}
```

---

### GET /api/v1/hr/attendances/employee/{membershipId}/history

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.AttendanceController`
* **Método Java:** `public ResponseEntity<List<AttendanceResource>> getEmployeeAttendanceHistory(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("membershipId") UUID membershipId, @RequestParam("startDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate, @RequestParam("endDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate)`

#### Descripción Funcional
Recupera el historial cronológico detallado de marcaciones de asistencia de un colaborador particular en un intervalo de fechas especificado. Permite auditar jornadas cumplidas, tardanzas acumuladas y justificaciones tramitadas.

#### Seguridad y Autorización
* **Rol Mínimo:** Técnico Mecánico (ROLE_MECHANIC) para su propio registro, o Mecánico Jefe para cualquier técnico.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('hr:attendance:audit_all o hr:attendance:read_own')")`
* **Contexto Multi-Inquilino:** Asegura que el membershipId pertenezca al tenant_id autenticado en la plataforma.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `membershipId` (UUID): Identificador único de la membresía del colaborador
* **Query Parameters:**
  * `startDate` (LocalDate, Requerido): Fecha inicial del intervalo de búsqueda en formato YYYY-MM-DD
  * `endDate` (LocalDate, Requerido): Fecha final del intervalo de búsqueda en formato YYYY-MM-DD

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `List<com.andeva.atelier.platform.hr.interfaces.rest.resources.responses.AttendanceResource>`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la marcación |
| `branchId` | `UUID` | Sucursal del taller |
| `membershipId` | `UUID` | Membresía del empleado |
| `shiftId` | `UUID` | Turno evaluado |
| `clockIn` | `Instant` | Hora de entrada |
| `clockOut` | `Instant` | Hora de salida |
| `status` | `String` | Estado de la marcación |
| `latitude` | `Double` | Latitud registrada |
| `longitude` | `Double` | Longitud registrada |
| `distanceToBranchMeters` | `Double` | Distancia calculada al taller |
| `justificationReason` | `String` | Descargo si existe |
| `justifiedBy` | `UUID` | Supervisor que aprobó |
| `justifiedAt` | `Instant` | Fecha y hora de justificación |


```json
[
  {
    "id": "a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d",
    "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
    "membershipId": "c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f",
    "shiftId": "e3b0c442-98fc-4c14-9afe-0c07c4587123",
    "clockIn": "2026-10-01T13:05:12Z",
    "clockOut": "2026-10-01T22:30:00Z",
    "status": "ON_TIME",
    "latitude": -12.096521,
    "longitude": -77.035412,
    "distanceToBranchMeters": 14.8,
    "justificationReason": null,
    "justifiedBy": null,
    "justifiedAt": null
  }
]
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 400 Bad Request | `https://api.atelier.pe/errors/invalid-date-range` | `MethodArgumentNotValidException` | Rango de fechas invertido o mal formateado |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | El usuario no tiene permiso para consultar el historial de este colaborador |
| 404 Not Found | `https://api.atelier.pe/errors/employee-not-found` | `EmployeeProfileNotFoundException` | El perfil de empleado asociado a la membresía no existe |


```json
{
  "type": "https://api.atelier.pe/errors/invalid-date-range",
  "title": "Rango de Fechas Invalido",
  "status": 400,
  "detail": "La fecha inicial 2026-10-15 no puede ser posterior a la fecha final 2026-10-01.",
  "instance": "/api/v1/hr/attendances/employee/c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f/history",
  "timestamp": "2026-10-01T15:02:00Z",
  "correlationId": "req-hist-400-01"
}
```

---

### GET /api/v1/hr/attendances/employee/{membershipId}/active

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.AttendanceController`
* **Método Java:** `public ResponseEntity<AttendanceResource> getActiveAttendance(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("membershipId") UUID membershipId)`

#### Descripción Funcional
Consulta la marcación de asistencia actualmente abierta (con clock_in registrado y clock_out nulo) para un colaborador específico. Permite a los supervisores de patio y a la app móvil verificar si el mecánico se encuentra habilitado para recibir asignaciones de órdenes de trabajo.

#### Seguridad y Autorización
* **Rol Mínimo:** Técnico Mecánico (ROLE_MECHANIC) para su propio estado, o Mecánico Jefe para cualquier técnico.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('hr:attendance:audit_all o hr:attendance:read_own')")`
* **Contexto Multi-Inquilino:** Valida correspondencia entre el membershipId y el tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `membershipId` (UUID): Identificador único de la membresía del colaborador
* **Query Parameters:** Ninguno.

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.responses.AttendanceResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del registro de asistencia activa |
| `branchId` | `UUID` | Sucursal del taller donde se encuentra activo |
| `membershipId` | `UUID` | Membresía del empleado |
| `shiftId` | `UUID` | Turno en desarrollo |
| `clockIn` | `Instant` | Hora de inicio de la jornada actual |
| `clockOut` | `Instant` | Hora de egreso (nula mientras permanezca laborando) |
| `status` | `String` | Estado preliminar de la asistencia |
| `latitude` | `Double` | Latitud registrada |
| `longitude` | `Double` | Longitud registrada |
| `distanceToBranchMeters` | `Double` | Distancia calculada al ingresar |
| `justificationReason` | `String` | Descargo si fue justificado |
| `justifiedBy` | `UUID` | Supervisor |
| `justifiedAt` | `Instant` | Marca temporal de justificación |


```json
{
  "id": "a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d",
  "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
  "membershipId": "c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f",
  "shiftId": "e3b0c442-98fc-4c14-9afe-0c07c4587123",
  "clockIn": "2026-10-01T13:05:12Z",
  "clockOut": null,
  "status": "ON_TIME",
  "latitude": -12.096521,
  "longitude": -77.035412,
  "distanceToBranchMeters": 14.8,
  "justificationReason": null,
  "justifiedBy": null,
  "justifiedAt": null
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso denegado para consultar la marcación de este empleado |
| 404 Not Found | `https://api.atelier.pe/errors/active-attendance-not-found` | `AttendanceRecordNotFoundException` | El colaborador no cuenta con una jornada laboral abierta en este momento |


```json
{
  "type": "https://api.atelier.pe/errors/active-attendance-not-found",
  "title": "Sin Jornada Activa",
  "status": 404,
  "detail": "El colaborador no presenta una marcacion de ingreso activa sin salida registrada.",
  "instance": "/api/v1/hr/attendances/employee/c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f/active",
  "timestamp": "2026-10-01T15:05:00Z",
  "correlationId": "req-active-att-404-01"
}
```

---

## 5. Endpoints de PayrollPaymentsController

El controlador `PayrollPaymentsController` gobierna el flujo financiero de las nóminas salariales de los mecánicos y colaboradores del taller. Centraliza la generación de preliquidaciones, cómputo de deducciones de ley, asignación de bonos y comisiones por productividad, cálculo neto formal, desembolso bancario y exportación para la Planilla Mensual de Pagos (PLAME) de SUNAT.

### POST /api/v1/hr/payrolls/generate

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.PayrollPaymentsController`
* **Método Java:** `public ResponseEntity<PayrollPaymentResource> generatePayroll(@RequestHeader("X-Tenant-Id") UUID tenantId, @Valid @RequestBody GeneratePayrollRequest request)`

#### Descripción Funcional
Genera una nueva liquidación proforma de nómina salarial para un colaborador durante un ciclo de corte contable quincenal o mensual. Inicializa los conceptos de remuneración básica pactada en el expediente laboral, inicializa las deducciones y bonificaciones en cero, y coloca la planilla en estado DRAFT para revisión contable.

#### Seguridad y Autorización
* **Rol Mínimo:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueño de Taller (ROLE_WORKSHOP_OWNER).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iam:members:compensate')")`
* **Contexto Multi-Inquilino:** Valida que el colaborador pertenezca a la plantilla formal del tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:** Ninguno.
* **Query Parameters:** Ninguno.

#### Cuerpo de Petición (Request DTO)
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.requests.GeneratePayrollRequest`

| Campo | Tipo Java | Restricciones y Validaciones | Descripción |
| :--- | :--- | :--- | :--- |
| `membershipId` | `UUID` | @NotNull | Identificador único de la membresía del colaborador a liquidar |
| `periodStart` | `LocalDate` | @NotNull | Fecha inicial del periodo de cómputo en formato YYYY-MM-DD |
| `periodEnd` | `LocalDate` | @NotNull | Fecha final del periodo de cómputo en formato YYYY-MM-DD |


```json
{
  "membershipId": "c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f",
  "periodStart": "2026-09-01",
  "periodEnd": "2026-09-30"
}
```
#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `201 CREATED`
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.responses.PayrollPaymentResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador único de la liquidación de nómina |
| `membershipId` | `UUID` | Identificador de la membresía del colaborador |
| `periodStart` | `LocalDate` | Fecha de inicio del ciclo |
| `periodEnd` | `LocalDate` | Fecha de fin del ciclo |
| `baseAmount` | `BigDecimal` | Sueldo base computable pactado |
| `deductions` | `BigDecimal` | Total acumulado de descuentos |
| `bonuses` | `BigDecimal` | Total acumulado de bonificaciones y comisiones |
| `totalPaid` | `BigDecimal` | Remuneración neta proyectada |
| `currency` | `String` | Divisa legal de la planilla (PEN o USD) |
| `status` | `String` | Estado inicial de la liquidación (DRAFT) |
| `paidAt` | `Instant` | Fecha de pago bancario (nula en borrador) |
| `paymentReference` | `String` | Referencia bancaria (nula en borrador) |
| `items` | `List<PayrollItemResource>` | Desglose de partidas analíticas de ingresos y descuentos |


```json
{
  "id": "d4e5f6a7-b8c9-4012-3456-7890abcdef34",
  "membershipId": "c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f",
  "periodStart": "2026-09-01",
  "periodEnd": "2026-09-30",
  "baseAmount": 2800,
  "deductions": 0,
  "bonuses": 0,
  "totalPaid": 2800,
  "currency": "PEN",
  "status": "DRAFT",
  "paidAt": null,
  "paymentReference": null,
  "items": [
    {
      "id": "e5f6a7b8-c9d0-4123-4567-890abcdef45",
      "category": "BASE_SALARY",
      "concept": "Remuneracion Basica Mensual",
      "amount": 2800,
      "type": "BASE",
      "date": "2026-09-30"
    }
  ]
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 400 Bad Request | `https://api.atelier.pe/errors/invalid-argument` | `MethodArgumentNotValidException` | Faltan parámetros requeridos o las fechas del periodo son incoherentes |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | El usuario no posee el permiso iam:members:compensate |
| 404 Not Found | `https://api.atelier.pe/errors/employee-not-found` | `EmployeeProfileNotFoundException` | El colaborador no cuenta con expediente laboral registrado |
| 409 Conflict | `https://api.atelier.pe/errors/payroll-exists` | `InvalidPayrollModificationException` | Ya existe una liquidación de nómina para este colaborador en el periodo indicado |


```json
{
  "type": "https://api.atelier.pe/errors/payroll-exists",
  "title": "Planilla Preexistente",
  "status": 409,
  "detail": "Ya existe una liquidacion de planilla para el colaborador en el periodo comprendido entre 2026-09-01 y 2026-09-30.",
  "instance": "/api/v1/hr/payrolls/generate",
  "timestamp": "2026-10-01T15:10:00Z",
  "correlationId": "req-pay-gen-409-01"
}
```

---

### GET /api/v1/hr/payrolls

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.PayrollPaymentsController`
* **Método Java:** `public ResponseEntity<Page<PayrollPaymentSummaryResource>> listPayrolls(@RequestHeader("X-Tenant-Id") UUID tenantId, @RequestParam(value = "periodStart", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate periodStart, @RequestParam(value = "periodEnd", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate periodEnd, @RequestParam(value = "status", required = false) String status, Pageable pageable)`

#### Descripción Funcional
Lista de forma segmentada y filtrada las planillas de pago emitidas en el taller automotriz. Permite filtrar por estado (DRAFT, APPROVED, PAID, CANCELLED) y rango de fechas de periodo contable para facilitar la auditoría de haberes.

#### Seguridad y Autorización
* **Rol Mínimo:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueño de Taller (ROLE_WORKSHOP_OWNER).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iam:members:compensate')")`
* **Contexto Multi-Inquilino:** Filtra únicamente las planillas emitidas bajo el tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:** Ninguno.
* **Query Parameters:**
  * `periodStart` (LocalDate, Opcional): Filtro por fecha de inicio de corte en formato YYYY-MM-DD
  * `periodEnd` (LocalDate, Opcional): Filtro por fecha de fin de corte en formato YYYY-MM-DD
  * `status` (String, Opcional): Filtro por estado de planilla (DRAFT, APPROVED, PAID, CANCELLED)
  * `page` (int, Opcional): Índice de desplazamiento de registros comenzando en cero
  * `size` (int, Opcional): Cantidad máxima de elementos por bloque de resultados

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `Page<com.andeva.atelier.platform.hr.interfaces.rest.resources.responses.PayrollPaymentSummaryResource>`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador único de la planilla |
| `membershipId` | `UUID` | Identificador del colaborador |
| `periodStart` | `LocalDate` | Fecha inicial del periodo |
| `periodEnd` | `LocalDate` | Fecha final del periodo |
| `baseAmount` | `BigDecimal` | Sueldo base pactado |
| `totalPaid` | `BigDecimal` | Remuneración neta liquidada |
| `currency` | `String` | Divisa (PEN o USD) |
| `status` | `String` | Estado actual de la nómina |


```json
{
  "content": [
    {
      "id": "d4e5f6a7-b8c9-4012-3456-7890abcdef34",
      "membershipId": "c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f",
      "periodStart": "2026-09-01",
      "periodEnd": "2026-09-30",
      "baseAmount": 2800,
      "totalPaid": 2950,
      "currency": "PEN",
      "status": "PAID"
    }
  ],
  "pageable": {
    "pageNumber": 0,
    "pageSize": 20
  },
  "totalElements": 1,
  "totalPages": 1
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | El usuario carece del permiso iam:members:compensate |


```json
{
  "type": "https://api.atelier.pe/errors/unauthorized",
  "title": "No Autorizado",
  "status": 401,
  "detail": "Se requiere autenticacion valida para consultar planillas.",
  "instance": "/api/v1/hr/payrolls",
  "timestamp": "2026-10-01T15:11:00Z",
  "correlationId": "req-pay-list-401-01"
}
```

---

### GET /api/v1/hr/payrolls/{payrollId}

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.PayrollPaymentsController`
* **Método Java:** `public ResponseEntity<PayrollPaymentResource> getPayrollById(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("payrollId") UUID payrollId)`

#### Descripción Funcional
Recupera el detalle exhaustivo de una boleta de pago o liquidación salarial, incorporando el desglose analítico completo de partidas de haberes: sueldo base, bonificaciones por comisiones de órdenes de trabajo finalizadas, horas extras, y deducciones de ley o préstamos internos.

#### Seguridad y Autorización
* **Rol Mínimo:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueño de Taller (ROLE_WORKSHOP_OWNER).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iam:members:compensate')")`
* **Contexto Multi-Inquilino:** Valida pertenencia de la liquidación al tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `payrollId` (UUID): Identificador único de la planilla solicitada
* **Query Parameters:** Ninguno.

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.responses.PayrollPaymentResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la liquidación |
| `membershipId` | `UUID` | Colaborador liquidado |
| `periodStart` | `LocalDate` | Fecha inicial del periodo |
| `periodEnd` | `LocalDate` | Fecha final del periodo |
| `baseAmount` | `BigDecimal` | Remuneración básica pactada |
| `deductions` | `BigDecimal` | Monto total de deducciones aplicadas |
| `bonuses` | `BigDecimal` | Monto total de bonos asignados |
| `totalPaid` | `BigDecimal` | Importe neto final resultante |
| `currency` | `String` | Divisa legal |
| `status` | `String` | Estado formal de la boleta |
| `paidAt` | `Instant` | Marca temporal de transferencia |
| `paymentReference` | `String` | Constancia de pago bancario |
| `items` | `List<PayrollItemResource>` | Líneas detalladas de conceptos |


```json
{
  "id": "d4e5f6a7-b8c9-4012-3456-7890abcdef34",
  "membershipId": "c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f",
  "periodStart": "2026-09-01",
  "periodEnd": "2026-09-30",
  "baseAmount": 2800,
  "deductions": 364,
  "bonuses": 514,
  "totalPaid": 2950,
  "currency": "PEN",
  "status": "APPROVED",
  "paidAt": null,
  "paymentReference": null,
  "items": [
    {
      "id": "e5f6a7b8-c9d0-4123-4567-890abcdef45",
      "category": "BASE_SALARY",
      "concept": "Remuneracion Basica Mensual",
      "amount": 2800,
      "type": "BASE",
      "date": "2026-09-30"
    },
    {
      "id": "f6a7b8c9-d0e1-4234-5678-901abcdef56",
      "category": "DEDUCTION",
      "concept": "Aporte Obligatorio AFP Integra Fondo 2",
      "amount": 364,
      "type": "AFP",
      "date": "2026-09-30"
    },
    {
      "id": "a7b8c9d0-e1f2-4345-6789-012abcdef67",
      "category": "BONUS",
      "concept": "Comision por Servicios de Frenos y Suspension",
      "amount": 514,
      "type": "WORK_ORDER_COMMISSION",
      "date": "2026-09-30"
    }
  ]
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso denegado para consultar la planilla |
| 404 Not Found | `https://api.atelier.pe/errors/payroll-not-found` | `PayrollPaymentNotFoundException` | La liquidación solicitada no existe o no corresponde a este taller |


```json
{
  "type": "https://api.atelier.pe/errors/payroll-not-found",
  "title": "Planilla No Encontrada",
  "status": 404,
  "detail": "No se encontro la planilla especificada con identificador d4e5f6a7-b8c9-4012-3456-7890abcdef99.",
  "instance": "/api/v1/hr/payrolls/d4e5f6a7-b8c9-4012-3456-7890abcdef99",
  "timestamp": "2026-10-01T15:12:00Z",
  "correlationId": "req-pay-get-404-01"
}
```

---

### POST /api/v1/hr/payrolls/{payrollId}/deductions

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.PayrollPaymentsController`
* **Método Java:** `public ResponseEntity<PayrollPaymentResource> addPayrollDeduction(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("payrollId") UUID payrollId, @Valid @RequestBody AddPayrollDeductionRequest request)`

#### Descripción Funcional
Registra un descuento o deducción específica dentro de una planilla en estado borrador (DRAFT). Admite retenciones de ley (AFP, ONP, EsSalud Vida, Impuesto a la Renta de 5ta categoría), anticipos salariales o penalidades por inasistencias injustificadas acumuladas.

#### Seguridad y Autorización
* **Rol Mínimo:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueño de Taller (ROLE_WORKSHOP_OWNER).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iam:members:compensate')")`
* **Contexto Multi-Inquilino:** Exige concordancia entre el tenant_id autenticado y la planilla receptora.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `payrollId` (UUID): Identificador único de la nómina donde se imputará la deducción
* **Query Parameters:** Ninguno.

#### Cuerpo de Petición (Request DTO)
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.requests.AddPayrollDeductionRequest`

| Campo | Tipo Java | Restricciones y Validaciones | Descripción |
| :--- | :--- | :--- | :--- |
| `concept` | `String` | @NotBlank, @Size(max = 150) | Glosa explicativa del descuento o retención legal |
| `amount` | `BigDecimal` | @NotNull, @Positive | Importe monetario del descuento estrictamente mayor a cero |
| `currency` | `String` | @NotBlank, @Size(min = 3, max = 3), @Pattern("PEN|USD") | Código ISO de la divisa del descuento |
| `deductionType` | `String` | @NotBlank, @Pattern("AFP|ONP|ESSALUD_VIDA|TAX_RETENTION|ADVANCE|LOAN|UNEXCUSED_ABSENCE|PENALTY") | Clasificación contable y tributaria de la deducción |
| `date` | `LocalDate` | @NotNull | Fecha de imputación del descuento en formato YYYY-MM-DD |


```json
{
  "concept": "Retencion de Aporte Previsional AFP Profuturo",
  "amount": 364,
  "currency": "PEN",
  "deductionType": "AFP",
  "date": "2026-09-30"
}
```
#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.responses.PayrollPaymentResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la planilla |
| `membershipId` | `UUID` | Identificador del colaborador |
| `periodStart` | `LocalDate` | Fecha de inicio del ciclo |
| `periodEnd` | `LocalDate` | Fecha de fin del ciclo |
| `baseAmount` | `BigDecimal` | Sueldo base pactado |
| `deductions` | `BigDecimal` | Total actualizado de descuentos |
| `bonuses` | `BigDecimal` | Total de bonos |
| `totalPaid` | `BigDecimal` | Remuneración neta recalculada |
| `currency` | `String` | Divisa |
| `status` | `String` | Estado de la planilla |
| `paidAt` | `Instant` | Fecha de pago |
| `paymentReference` | `String` | Referencia bancaria |
| `items` | `List<PayrollItemResource>` | Lista de partidas con la deducción anexada |


```json
{
  "id": "d4e5f6a7-b8c9-4012-3456-7890abcdef34",
  "membershipId": "c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f",
  "periodStart": "2026-09-01",
  "periodEnd": "2026-09-30",
  "baseAmount": 2800,
  "deductions": 364,
  "bonuses": 0,
  "totalPaid": 2436,
  "currency": "PEN",
  "status": "DRAFT",
  "paidAt": null,
  "paymentReference": null,
  "items": [
    {
      "id": "e5f6a7b8-c9d0-4123-4567-890abcdef45",
      "category": "BASE_SALARY",
      "concept": "Remuneracion Basica Mensual",
      "amount": 2800,
      "type": "BASE",
      "date": "2026-09-30"
    },
    {
      "id": "f6a7b8c9-d0e1-4234-5678-901abcdef56",
      "category": "DEDUCTION",
      "concept": "Retencion de Aporte Previsional AFP Profuturo",
      "amount": 364,
      "type": "AFP",
      "date": "2026-09-30"
    }
  ]
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 400 Bad Request | `https://api.atelier.pe/errors/invalid-argument` | `MethodArgumentNotValidException` | Monto no positivo o tipo de deducción inválido |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso denegado para imputar deducciones |
| 404 Not Found | `https://api.atelier.pe/errors/payroll-not-found` | `PayrollPaymentNotFoundException` | La liquidación indicada no existe |
| 409 Conflict | `https://api.atelier.pe/errors/payroll-immutable` | `InvalidPayrollModificationException` | La planilla ya se encuentra aprobada o pagada y no admite modificaciones |


```json
{
  "type": "https://api.atelier.pe/errors/payroll-immutable",
  "title": "Planilla Inmutable",
  "status": 409,
  "detail": "No se pueden agregar deducciones a una planilla en estado APPROVED o PAID.",
  "instance": "/api/v1/hr/payrolls/d4e5f6a7-b8c9-4012-3456-7890abcdef34/deductions",
  "timestamp": "2026-10-01T15:13:00Z",
  "correlationId": "req-ded-409-01"
}
```

---

### POST /api/v1/hr/payrolls/{payrollId}/bonuses

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.PayrollPaymentsController`
* **Método Java:** `public ResponseEntity<PayrollPaymentResource> addPayrollBonus(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("payrollId") UUID payrollId, @Valid @RequestBody AddPayrollBonusRequest request)`

#### Descripción Funcional
Registra un incentivo económico, bono por productividad, asignación familiar o comisión técnica por destajo devengada de órdenes de trabajo cerradas satisfactoriamente dentro del periodo contable.

#### Seguridad y Autorización
* **Rol Mínimo:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueño de Taller (ROLE_WORKSHOP_OWNER).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iam:members:compensate')")`
* **Contexto Multi-Inquilino:** Garantiza aislamiento asegurando que la nómina corresponda al tenant autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `payrollId` (UUID): Identificador único de la liquidación receptora del bono
* **Query Parameters:** Ninguno.

#### Cuerpo de Petición (Request DTO)
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.requests.AddPayrollBonusRequest`

| Campo | Tipo Java | Restricciones y Validaciones | Descripción |
| :--- | :--- | :--- | :--- |
| `concept` | `String` | @NotBlank, @Size(max = 150) | Glosa descriptiva de la bonificación o comisión |
| `amount` | `BigDecimal` | @NotNull, @Positive | Monto de la bonificación estrictamente positivo |
| `currency` | `String` | @NotBlank, @Size(min = 3, max = 3), @Pattern("PEN|USD") | Divisa legal del bono |
| `bonusType` | `String` | @NotBlank, @Pattern("PRODUCTIVITY|WORK_ORDER_COMMISSION|OVERTIME|PUNCTUALITY|SPECIAL_BONUS") | Clasificación contable del beneficio |
| `date` | `LocalDate` | @NotNull | Fecha de devengo del concepto en formato YYYY-MM-DD |


```json
{
  "concept": "Comision por Productividad en Mantenimiento Preventivo",
  "amount": 450,
  "currency": "PEN",
  "bonusType": "WORK_ORDER_COMMISSION",
  "date": "2026-09-28"
}
```
#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.responses.PayrollPaymentResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la liquidación |
| `membershipId` | `UUID` | Colaborador liquidado |
| `periodStart` | `LocalDate` | Fecha de inicio del ciclo |
| `periodEnd` | `LocalDate` | Fecha de fin del ciclo |
| `baseAmount` | `BigDecimal` | Sueldo base pactado |
| `deductions` | `BigDecimal` | Total acumulado de deducciones |
| `bonuses` | `BigDecimal` | Total acumulado de bonificaciones |
| `totalPaid` | `BigDecimal` | Remuneración neta recalculada |
| `currency` | `String` | Divisa |
| `status` | `String` | Estado de la planilla |
| `paidAt` | `Instant` | Fecha de pago |
| `paymentReference` | `String` | Referencia bancaria |
| `items` | `List<PayrollItemResource>` | Lista de partidas con el bono incluido |


```json
{
  "id": "d4e5f6a7-b8c9-4012-3456-7890abcdef34",
  "membershipId": "c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f",
  "periodStart": "2026-09-01",
  "periodEnd": "2026-09-30",
  "baseAmount": 2800,
  "deductions": 364,
  "bonuses": 450,
  "totalPaid": 2886,
  "currency": "PEN",
  "status": "DRAFT",
  "paidAt": null,
  "paymentReference": null,
  "items": [
    {
      "id": "e5f6a7b8-c9d0-4123-4567-890abcdef45",
      "category": "BASE_SALARY",
      "concept": "Remuneracion Basica Mensual",
      "amount": 2800,
      "type": "BASE",
      "date": "2026-09-30"
    },
    {
      "id": "b8c9d0e1-f2a3-4456-7890-123abcdef78",
      "category": "BONUS",
      "concept": "Comision por Productividad en Mantenimiento Preventivo",
      "amount": 450,
      "type": "WORK_ORDER_COMMISSION",
      "date": "2026-09-28"
    }
  ]
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 400 Bad Request | `https://api.atelier.pe/errors/invalid-argument` | `MethodArgumentNotValidException` | Importe no positivo o tipo de bonificación inválido |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso denegado para imputar bonificaciones |
| 404 Not Found | `https://api.atelier.pe/errors/payroll-not-found` | `PayrollPaymentNotFoundException` | La liquidación indicada no existe |
| 409 Conflict | `https://api.atelier.pe/errors/payroll-immutable` | `InvalidPayrollModificationException` | La planilla no se encuentra en estado DRAFT |


```json
{
  "type": "https://api.atelier.pe/errors/payroll-immutable",
  "title": "Planilla Cerrada",
  "status": 409,
  "detail": "No se pueden imputar bonificaciones a una planilla que ya ha sido cerrada o aprobada.",
  "instance": "/api/v1/hr/payrolls/d4e5f6a7-b8c9-4012-3456-7890abcdef34/bonuses",
  "timestamp": "2026-10-01T15:14:00Z",
  "correlationId": "req-bon-409-01"
}
```

---

### POST /api/v1/hr/payrolls/{payrollId}/calculate

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.PayrollPaymentsController`
* **Método Java:** `public ResponseEntity<PayrollPaymentResource> calculateAndApprovePayroll(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("payrollId") UUID payrollId)`

#### Descripción Funcional
Ejecuta el recálculo matemático formal de la liquidación salarial consolidando base imponible, sumatoria de deducciones y bonos, validando que el saldo neto resultante no sea negativo. Tras el recálculo, congela la nómina pasando su estado de DRAFT a APPROVED para habilitar el desembolso bancario.

#### Seguridad y Autorización
* **Rol Mínimo:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueño de Taller (ROLE_WORKSHOP_OWNER).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iam:members:compensate')")`
* **Contexto Multi-Inquilino:** Valida que la liquidación pertenezca al taller autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `payrollId` (UUID): Identificador único de la liquidación que se recalcula y aprueba
* **Query Parameters:** Ninguno.

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.responses.PayrollPaymentResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la liquidación |
| `membershipId` | `UUID` | Colaborador liquidado |
| `periodStart` | `LocalDate` | Fecha inicial del periodo |
| `periodEnd` | `LocalDate` | Fecha final del periodo |
| `baseAmount` | `BigDecimal` | Sueldo base computable |
| `deductions` | `BigDecimal` | Suma consolidada de deducciones |
| `bonuses` | `BigDecimal` | Suma consolidada de bonos |
| `totalPaid` | `BigDecimal` | Monto neto final aprobado |
| `currency` | `String` | Divisa legal |
| `status` | `String` | Estado formal actualizado a APPROVED |
| `paidAt` | `Instant` | Fecha de pago |
| `paymentReference` | `String` | Referencia bancaria |
| `items` | `List<PayrollItemResource>` | Partidas analíticas |


```json
{
  "id": "d4e5f6a7-b8c9-4012-3456-7890abcdef34",
  "membershipId": "c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f",
  "periodStart": "2026-09-01",
  "periodEnd": "2026-09-30",
  "baseAmount": 2800,
  "deductions": 364,
  "bonuses": 450,
  "totalPaid": 2886,
  "currency": "PEN",
  "status": "APPROVED",
  "paidAt": null,
  "paymentReference": null,
  "items": [
    {
      "id": "e5f6a7b8-c9d0-4123-4567-890abcdef45",
      "category": "BASE_SALARY",
      "concept": "Remuneracion Basica Mensual",
      "amount": 2800,
      "type": "BASE",
      "date": "2026-09-30"
    },
    {
      "id": "f6a7b8c9-d0e1-4234-5678-901abcdef56",
      "category": "DEDUCTION",
      "concept": "Retencion de Aporte Previsional AFP Profuturo",
      "amount": 364,
      "type": "AFP",
      "date": "2026-09-30"
    },
    {
      "id": "b8c9d0e1-f2a3-4456-7890-123abcdef78",
      "category": "BONUS",
      "concept": "Comision por Productividad en Mantenimiento Preventivo",
      "amount": 450,
      "type": "WORK_ORDER_COMMISSION",
      "date": "2026-09-28"
    }
  ]
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso denegado para recalcular o aprobar la nómina |
| 404 Not Found | `https://api.atelier.pe/errors/payroll-not-found` | `PayrollPaymentNotFoundException` | La liquidación solicitada no existe |
| 409 Conflict | `https://api.atelier.pe/errors/invalid-total` | `InvalidPayrollModificationException` | El neto resultante es negativo o la nómina no se encuentra en estado DRAFT |


```json
{
  "type": "https://api.atelier.pe/errors/invalid-total",
  "title": "Monto Neto Invalido",
  "status": 409,
  "detail": "Las deducciones acumuladas superan la suma de remuneracion basica y bonificaciones, produciendo un saldo negativo.",
  "instance": "/api/v1/hr/payrolls/d4e5f6a7-b8c9-4012-3456-7890abcdef34/calculate",
  "timestamp": "2026-10-01T15:15:00Z",
  "correlationId": "req-calc-409-01"
}
```

---

### POST /api/v1/hr/payrolls/{payrollId}/disburse

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.PayrollPaymentsController`
* **Método Java:** `public ResponseEntity<PayrollPaymentResource> disbursePayroll(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("payrollId") UUID payrollId, @Valid @RequestBody DisbursePayrollRequest request)`

#### Descripción Funcional
Marca la nómina como efectivamente pagada y desembolsada en banco, registrando el código de transferencia u operación financiera y la marca temporal de liquidación. Pasa el estado a PAID e imposibilita modificaciones ulteriores.

#### Seguridad y Autorización
* **Rol Mínimo:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueño de Taller (ROLE_WORKSHOP_OWNER).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iam:members:compensate')")`
* **Contexto Multi-Inquilino:** Valida pertenencia de la nómina al tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `payrollId` (UUID): Identificador único de la planilla a desembolsar
* **Query Parameters:** Ninguno.

#### Cuerpo de Petición (Request DTO)
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.requests.DisbursePayrollRequest`

| Campo | Tipo Java | Restricciones y Validaciones | Descripción |
| :--- | :--- | :--- | :--- |
| `paymentReference` | `String` | @NotBlank, @Size(max = 100) | Código de operación interbancaria o comprobante de transferencia |
| `paidAt` | `Instant` | @NotNull | Marca temporal UTC en que se ejecutó la transferencia de fondos |


```json
{
  "paymentReference": "BCP-OP-8923412093",
  "paidAt": "2026-10-01T15:20:00Z"
}
```
#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.responses.PayrollPaymentResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la liquidación |
| `membershipId` | `UUID` | Colaborador |
| `periodStart` | `LocalDate` | Fecha inicial |
| `periodEnd` | `LocalDate` | Fecha final |
| `baseAmount` | `BigDecimal` | Sueldo base |
| `deductions` | `BigDecimal` | Deducciones |
| `bonuses` | `BigDecimal` | Bonos |
| `totalPaid` | `BigDecimal` | Monto transferido |
| `currency` | `String` | Divisa |
| `status` | `String` | Estado formal PAID |
| `paidAt` | `Instant` | Fecha de pago registrada |
| `paymentReference` | `String` | Referencia bancaria registrada |
| `items` | `List<PayrollItemResource>` | Partidas consolidadas |


```json
{
  "id": "d4e5f6a7-b8c9-4012-3456-7890abcdef34",
  "membershipId": "c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f",
  "periodStart": "2026-09-01",
  "periodEnd": "2026-09-30",
  "baseAmount": 2800,
  "deductions": 364,
  "bonuses": 450,
  "totalPaid": 2886,
  "currency": "PEN",
  "status": "PAID",
  "paidAt": "2026-10-01T15:20:00Z",
  "paymentReference": "BCP-OP-8923412093",
  "items": [
    {
      "id": "e5f6a7b8-c9d0-4123-4567-890abcdef45",
      "category": "BASE_SALARY",
      "concept": "Remuneracion Basica Mensual",
      "amount": 2800,
      "type": "BASE",
      "date": "2026-09-30"
    }
  ]
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 400 Bad Request | `https://api.atelier.pe/errors/invalid-argument` | `MethodArgumentNotValidException` | Referencia bancaria ausente o vacía |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso denegado para desembolsar nóminas |
| 404 Not Found | `https://api.atelier.pe/errors/payroll-not-found` | `PayrollPaymentNotFoundException` | Nómina no encontrada |
| 409 Conflict | `https://api.atelier.pe/errors/payroll-not-approved` | `InvalidPayrollModificationException` | La nómina debe estar en estado APPROVED para autorizar su desembolso |


```json
{
  "type": "https://api.atelier.pe/errors/payroll-not-approved",
  "title": "Planilla No Aprobada",
  "status": 409,
  "detail": "La planilla debe ser recalculada y aprobada formalmente antes de registrar su desembolso bancario.",
  "instance": "/api/v1/hr/payrolls/d4e5f6a7-b8c9-4012-3456-7890abcdef34/disburse",
  "timestamp": "2026-10-01T15:21:00Z",
  "correlationId": "req-disb-409-01"
}
```

---

### GET /api/v1/hr/payrolls/export/sunat-rem

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.PayrollPaymentsController`
* **Método Java:** `public ResponseEntity<byte[]> exportSunatRem(@RequestHeader("X-Tenant-Id") UUID tenantId, @RequestParam("period") String period, @RequestParam(value = "branchId", required = false) UUID branchId)`

#### Descripción Funcional
Genera y exporta el archivo estructurado oficial requerido por la Planilla Mensual de Pagos (PLAME) de la SUNAT en formato de texto plano (.rem) con delimitadores de barra vertical. Compila los haberes pagados a cada técnico según la tabla de conceptos tributarios del PDT 601.

#### Seguridad y Autorización
* **Rol Mínimo:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueño de Taller (ROLE_WORKSHOP_OWNER).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('hr:plame:export')")`
* **Contexto Multi-Inquilino:** Compila exclusivamente la información de planillas liquidadas bajo el tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:** Ninguno.
* **Query Parameters:**
  * `period` (String, Requerido): Periodo tributario mensual en formato YYYY-MM (ejemplo 2026-09)
  * `branchId` (UUID, Opcional): Identificador de sede física si se desea exportar por sucursal específica

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `Content-Type` | `Header` | Cabecera MIME text/plain con codificación ISO-8859-1 |
| `Content-Disposition` | `Header` | Adjunto de descarga con nombre de archivo 060120260920608945231.rem |


```text
06|20608945231|01|45892314|0121|2800.00|2800.00|
06|20608945231|01|45892314|0605|364.00|364.00|
06|20608945231|01|45892314|0903|450.00|450.00|
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 400 Bad Request | `https://api.atelier.pe/errors/invalid-period` | `HrDomainException` | Formato de periodo no cumple con la máscara YYYY-MM |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso hr:plame:export no autorizado |
| 404 Not Found | `https://api.atelier.pe/errors/no-data` | `HrDomainException` | No existen nóminas en estado PAID para el periodo tributario solicitado |


```json
{
  "type": "https://api.atelier.pe/errors/invalid-period",
  "title": "Periodo Tributario Invalido",
  "status": 400,
  "detail": "El periodo tributario 2026-9 no coincide con el patron requerido YYYY-MM.",
  "instance": "/api/v1/hr/payrolls/export/sunat-rem",
  "timestamp": "2026-10-01T15:22:00Z",
  "correlationId": "req-plame-400-01"
}
```

---

## 6. Endpoints de StaffProfilesController

El controlador `StaffProfilesController` custodia los expedientes laborales y las condiciones de contratación del personal adscrito a cada sede física del taller, articulando su vinculación con la membresía institucional en IAM.

### POST /api/v1/hr/employees

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.StaffProfilesController`
* **Método Java:** `public ResponseEntity<EmployeeProfileResource> registerEmployeeProfile(@RequestHeader("X-Tenant-Id") UUID tenantId, @Valid @RequestBody RegisterEmployeeProfileRequest request)`

#### Descripción Funcional
Crea y formaliza el expediente laboral operativo de un colaborador en el taller automotriz, vinculándolo a su membresía contractual preexistente en IAM & Tenancy. Configura la sucursal de adscripción física, el turno laboral asignado, el sueldo base pactado y el cargo técnico desempeñado.

#### Seguridad y Autorización
* **Rol Mínimo:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueño de Taller (ROLE_WORKSHOP_OWNER).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iam:members:manage_roles')")`
* **Contexto Multi-Inquilino:** Valida que tanto la membresía como la sucursal y el turno pertenezcan al tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:** Ninguno.
* **Query Parameters:** Ninguno.

#### Cuerpo de Petición (Request DTO)
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.requests.RegisterEmployeeProfileRequest`

| Campo | Tipo Java | Restricciones y Validaciones | Descripción |
| :--- | :--- | :--- | :--- |
| `branchId` | `UUID` | @NotNull | Identificador único de la sede física de trabajo asignada |
| `membershipId` | `UUID` | @NotNull | Identificador único de la membresía del usuario en IAM |
| `shiftId` | `UUID` | @NotNull | Identificador del turno laboral predeterminado asignado |
| `baseSalary` | `BigDecimal` | @NotNull, @Positive | Remuneración básica contractual estrictamente positiva |
| `currency` | `String` | @NotBlank, @Size(min = 3, max = 3), @Pattern("PEN|USD") | Código ISO 4217 de la moneda pactada |
| `compensationType` | `String` | @NotBlank, @Pattern("FIXED_MONTHLY|DAILY_RATE|HOURLY_RATE|COMMISSION_BASED") | Modalidad de esquema salarial acordada |
| `jobTitle` | `String` | @NotBlank, @Size(max = 100) | Denominación del puesto o cargo laboral en taller |


```json
{
  "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
  "membershipId": "c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f",
  "shiftId": "e3b0c442-98fc-4c14-9afe-0c07c4587123",
  "baseSalary": 2800,
  "currency": "PEN",
  "compensationType": "FIXED_MONTHLY",
  "jobTitle": "Mecanico Especialista en Suspension y Direccion"
}
```
#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `201 CREATED`
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.responses.EmployeeProfileResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador único del expediente laboral |
| `branchId` | `UUID` | Sucursal física adscrita |
| `membershipId` | `UUID` | Membresía institucional |
| `assignedShiftId` | `UUID` | Turno de trabajo habitual |
| `baseSalary` | `BigDecimal` | Remuneración básica |
| `currency` | `String` | Moneda pactada |
| `compensationType` | `String` | Modalidad de pago |
| `jobTitle` | `String` | Cargo laboral desempeñado |
| `employmentStatus` | `String` | Situación laboral inicial (ACTIVE) |


```json
{
  "id": "f1a2b3c4-d5e6-4789-0123-456789abcdef",
  "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
  "membershipId": "c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f",
  "assignedShiftId": "e3b0c442-98fc-4c14-9afe-0c07c4587123",
  "baseSalary": 2800,
  "currency": "PEN",
  "compensationType": "FIXED_MONTHLY",
  "jobTitle": "Mecanico Especialista en Suspension y Direccion",
  "employmentStatus": "ACTIVE"
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 400 Bad Request | `https://api.atelier.pe/errors/invalid-argument` | `MethodArgumentNotValidException` | Datos requeridos faltantes o salario no positivo |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | El usuario no posee el permiso iam:members:manage_roles |
| 404 Not Found | `https://api.atelier.pe/errors/work-shift-not-found` | `WorkShiftNotFoundException` | El turno laboral asignado no existe |
| 409 Conflict | `https://api.atelier.pe/errors/profile-exists` | `ShiftConflictException` | La membresía de usuario ya tiene un expediente laboral activo registrado |


```json
{
  "type": "https://api.atelier.pe/errors/profile-exists",
  "title": "Expediente Preexistente",
  "status": 409,
  "detail": "La membresia de colaborador c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f ya cuenta con un expediente laboral registrado.",
  "instance": "/api/v1/hr/employees",
  "timestamp": "2026-10-01T15:25:00Z",
  "correlationId": "req-emp-409-01"
}
```

---

### GET /api/v1/hr/employees/{profileId}

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.StaffProfilesController`
* **Método Java:** `public ResponseEntity<EmployeeProfileResource> getEmployeeProfileById(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("profileId") UUID profileId)`

#### Descripción Funcional
Recupera los datos completos del expediente laboral de un empleado a partir del identificador técnico único del expediente.

#### Seguridad y Autorización
* **Rol Mínimo:** Mecánico Jefe (ROLE_CHIEF_MECHANIC) o Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iam:members:read')")`
* **Contexto Multi-Inquilino:** Valida pertenencia estricta del expediente al tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `profileId` (UUID): Identificador único del expediente laboral
* **Query Parameters:** Ninguno.

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.responses.EmployeeProfileResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del expediente |
| `branchId` | `UUID` | Sucursal física |
| `membershipId` | `UUID` | Membresía del usuario |
| `assignedShiftId` | `UUID` | Turno habitual asignado |
| `baseSalary` | `BigDecimal` | Remuneración básica |
| `currency` | `String` | Divisa pactada |
| `compensationType` | `String` | Modalidad salarial |
| `jobTitle` | `String` | Cargo |
| `employmentStatus` | `String` | Estado laboral (ACTIVE, ON_LEAVE, TERMINATED) |


```json
{
  "id": "f1a2b3c4-d5e6-4789-0123-456789abcdef",
  "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
  "membershipId": "c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f",
  "assignedShiftId": "e3b0c442-98fc-4c14-9afe-0c07c4587123",
  "baseSalary": 2800,
  "currency": "PEN",
  "compensationType": "FIXED_MONTHLY",
  "jobTitle": "Mecanico Especialista en Suspension y Direccion",
  "employmentStatus": "ACTIVE"
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso iam:members:read no concedido |
| 404 Not Found | `https://api.atelier.pe/errors/employee-not-found` | `EmployeeProfileNotFoundException` | El expediente laboral no existe o no corresponde a este taller |


```json
{
  "type": "https://api.atelier.pe/errors/employee-not-found",
  "title": "Expediente No Encontrado",
  "status": 404,
  "detail": "No se encontro ningun expediente con identificador f1a2b3c4-d5e6-4789-0123-456789abc999.",
  "instance": "/api/v1/hr/employees/f1a2b3c4-d5e6-4789-0123-456789abc999",
  "timestamp": "2026-10-01T15:26:00Z",
  "correlationId": "req-emp-get-404-01"
}
```

---

### GET /api/v1/hr/employees/membership/{membershipId}

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.StaffProfilesController`
* **Método Java:** `public ResponseEntity<EmployeeProfileResource> getEmployeeProfileByMembershipId(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("membershipId") UUID membershipId)`

#### Descripción Funcional
Obtiene el expediente laboral de un colaborador asociándolo directamente desde el identificador de su membresía en el taller. Permite al técnico consultar su propio perfil y turno desde la aplicación móvil o a los supervisores auditarlo.

#### Seguridad y Autorización
* **Rol Mínimo:** Técnico Mecánico (ROLE_MECHANIC) para su propia membresía, o Mecánico Jefe para cualquier técnico.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iam:members:read o hr:attendance:read_own')")`
* **Contexto Multi-Inquilino:** Valida que la membresía corresponda al tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `membershipId` (UUID): Identificador único de la membresía en IAM
* **Query Parameters:** Ninguno.

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.responses.EmployeeProfileResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del expediente |
| `branchId` | `UUID` | Sucursal física |
| `membershipId` | `UUID` | Membresía institucional |
| `assignedShiftId` | `UUID` | Turno de trabajo habitual |
| `baseSalary` | `BigDecimal` | Remuneración básica |
| `currency` | `String` | Moneda pactada |
| `compensationType` | `String` | Modalidad salarial |
| `jobTitle` | `String` | Cargo desempeñado |
| `employmentStatus` | `String` | Estado laboral |


```json
{
  "id": "f1a2b3c4-d5e6-4789-0123-456789abcdef",
  "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
  "membershipId": "c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f",
  "assignedShiftId": "e3b0c442-98fc-4c14-9afe-0c07c4587123",
  "baseSalary": 2800,
  "currency": "PEN",
  "compensationType": "FIXED_MONTHLY",
  "jobTitle": "Mecanico Especialista en Suspension y Direccion",
  "employmentStatus": "ACTIVE"
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso denegado para consultar este expediente |
| 404 Not Found | `https://api.atelier.pe/errors/employee-not-found` | `EmployeeProfileNotFoundException` | No existe expediente laboral asociado a la membresía especificada |


```json
{
  "type": "https://api.atelier.pe/errors/employee-not-found",
  "title": "Expediente Inexistente",
  "status": 404,
  "detail": "No se encontro ningun expediente laboral vinculado a la membresia c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f.",
  "instance": "/api/v1/hr/employees/membership/c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f",
  "timestamp": "2026-10-01T15:27:00Z",
  "correlationId": "req-emp-mem-404-01"
}
```

---

### GET /api/v1/hr/employees/branch/{branchId}

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.StaffProfilesController`
* **Método Java:** `public ResponseEntity<List<EmployeeProfileResource>> getEmployeesByBranch(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("branchId") UUID branchId)`

#### Descripción Funcional
Lista todos los colaboradores activos y vigentes que se encuentran adscritos a una sede física o sucursal particular del taller.

#### Seguridad y Autorización
* **Rol Mínimo:** Mecánico Jefe (ROLE_CHIEF_MECHANIC) o Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iam:members:read')")`
* **Contexto Multi-Inquilino:** Valida que la sucursal física pertenezca al tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `branchId` (UUID): Identificador único de la sucursal del taller
* **Query Parameters:** Ninguno.

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `List<com.andeva.atelier.platform.hr.interfaces.rest.resources.responses.EmployeeProfileResource>`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del expediente |
| `branchId` | `UUID` | Sucursal física |
| `membershipId` | `UUID` | Membresía institucional |
| `assignedShiftId` | `UUID` | Turno asignado |
| `baseSalary` | `BigDecimal` | Sueldo base |
| `currency` | `String` | Divisa |
| `compensationType` | `String` | Esquema de pago |
| `jobTitle` | `String` | Cargo |
| `employmentStatus` | `String` | Estado laboral |


```json
[
  {
    "id": "f1a2b3c4-d5e6-4789-0123-456789abcdef",
    "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
    "membershipId": "c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f",
    "assignedShiftId": "e3b0c442-98fc-4c14-9afe-0c07c4587123",
    "baseSalary": 2800,
    "currency": "PEN",
    "compensationType": "FIXED_MONTHLY",
    "jobTitle": "Mecanico Especialista en Suspension y Direccion",
    "employmentStatus": "ACTIVE"
  }
]
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso denegado para consultar la lista de empleados |
| 404 Not Found | `https://api.atelier.pe/errors/branch-not-found` | `BranchNotFoundException` | La sucursal indicada no existe |


```json
{
  "type": "https://api.atelier.pe/errors/branch-not-found",
  "title": "Sucursal Inexistente",
  "status": 404,
  "detail": "La sucursal indicada no fue encontrada en este taller.",
  "instance": "/api/v1/hr/employees/branch/b8c3d9a1-4567-4e89-9123-abcdef012999",
  "timestamp": "2026-10-01T15:28:00Z",
  "correlationId": "req-emp-br-404-01"
}
```

---

### PUT /api/v1/hr/employees/{profileId}/shift

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.StaffProfilesController`
* **Método Java:** `public ResponseEntity<EmployeeProfileResource> assignShift(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("profileId") UUID profileId, @Valid @RequestBody AssignShiftRequest request)`

#### Descripción Funcional
Modifica y reasigna el turno de trabajo predeterminado de un colaborador. Valida que el nuevo turno se encuentre activo y pertenezca al mismo taller automotriz.

#### Seguridad y Autorización
* **Rol Mínimo:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueño de Taller (ROLE_WORKSHOP_OWNER).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('hr:shifts:manage')")`
* **Contexto Multi-Inquilino:** Valida que el expediente y el nuevo turno pertenezcan al tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `profileId` (UUID): Identificador único del expediente del empleado
* **Query Parameters:** Ninguno.

#### Cuerpo de Petición (Request DTO)
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.requests.AssignShiftRequest`

| Campo | Tipo Java | Restricciones y Validaciones | Descripción |
| :--- | :--- | :--- | :--- |
| `shiftId` | `UUID` | @NotNull | Identificador único del nuevo turno laboral que se asignará al colaborador |


```json
{
  "shiftId": "f81d4fae-7dec-11d0-a765-00a0c91e6bf6"
}
```
#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.responses.EmployeeProfileResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del expediente |
| `branchId` | `UUID` | Sucursal física |
| `membershipId` | `UUID` | Membresía institucional |
| `assignedShiftId` | `UUID` | Nuevo turno asignado |
| `baseSalary` | `BigDecimal` | Remuneración básica |
| `currency` | `String` | Divisa pactada |
| `compensationType` | `String` | Modalidad de pago |
| `jobTitle` | `String` | Cargo desempeñado |
| `employmentStatus` | `String` | Estado laboral |


```json
{
  "id": "f1a2b3c4-d5e6-4789-0123-456789abcdef",
  "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
  "membershipId": "c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f",
  "assignedShiftId": "f81d4fae-7dec-11d0-a765-00a0c91e6bf6",
  "baseSalary": 2800,
  "currency": "PEN",
  "compensationType": "FIXED_MONTHLY",
  "jobTitle": "Mecanico Especialista en Suspension y Direccion",
  "employmentStatus": "ACTIVE"
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 400 Bad Request | `https://api.atelier.pe/errors/invalid-argument` | `MethodArgumentNotValidException` | Identificador de turno nulo o inválido |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso hr:shifts:manage denegado |
| 404 Not Found | `https://api.atelier.pe/errors/work-shift-not-found` | `WorkShiftNotFoundException` | El turno indicado no existe o está inactivo |


```json
{
  "type": "https://api.atelier.pe/errors/work-shift-not-found",
  "title": "Turno No Disponible",
  "status": 404,
  "detail": "El turno especificado f81d4fae-7dec-11d0-a765-00a0c91e6bf6 no existe o se encuentra desactivado.",
  "instance": "/api/v1/hr/employees/f1a2b3c4-d5e6-4789-0123-456789abcdef/shift",
  "timestamp": "2026-10-01T15:29:00Z",
  "correlationId": "req-emp-sh-404-01"
}
```

---

### PUT /api/v1/hr/employees/{profileId}/salary

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.StaffProfilesController`
* **Método Java:** `public ResponseEntity<EmployeeProfileResource> updateSalary(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("profileId") UUID profileId, @Valid @RequestBody UpdateSalaryRequest request)`

#### Descripción Funcional
Modifica las condiciones salariales contractuales del colaborador, actualizando su remuneración básica pactada, moneda de pago y modalidad de liquidación.

#### Seguridad y Autorización
* **Rol Mínimo:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueño de Taller (ROLE_WORKSHOP_OWNER).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iam:members:compensate')")`
* **Contexto Multi-Inquilino:** Valida que el expediente corresponda al tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `profileId` (UUID): Identificador único del expediente del empleado
* **Query Parameters:** Ninguno.

#### Cuerpo de Petición (Request DTO)
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.requests.UpdateSalaryRequest`

| Campo | Tipo Java | Restricciones y Validaciones | Descripción |
| :--- | :--- | :--- | :--- |
| `baseSalary` | `BigDecimal` | @NotNull, @Positive | Nueva remuneración básica contractual |
| `currency` | `String` | @NotBlank, @Size(min = 3, max = 3), @Pattern("PEN|USD") | Código de moneda pactado |
| `compensationType` | `String` | @NotBlank, @Pattern("FIXED_MONTHLY|DAILY_RATE|HOURLY_RATE|COMMISSION_BASED") | Nuevo esquema salarial |


```json
{
  "baseSalary": 3200,
  "currency": "PEN",
  "compensationType": "FIXED_MONTHLY"
}
```
#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.responses.EmployeeProfileResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del expediente |
| `branchId` | `UUID` | Sucursal física |
| `membershipId` | `UUID` | Membresía institucional |
| `assignedShiftId` | `UUID` | Turno de trabajo habitual |
| `baseSalary` | `BigDecimal` | Sueldo base actualizado |
| `currency` | `String` | Moneda pactada |
| `compensationType` | `String` | Modalidad salarial |
| `jobTitle` | `String` | Cargo desempeñado |
| `employmentStatus` | `String` | Estado laboral |


```json
{
  "id": "f1a2b3c4-d5e6-4789-0123-456789abcdef",
  "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
  "membershipId": "c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f",
  "assignedShiftId": "e3b0c442-98fc-4c14-9afe-0c07c4587123",
  "baseSalary": 3200,
  "currency": "PEN",
  "compensationType": "FIXED_MONTHLY",
  "jobTitle": "Mecanico Especialista en Suspension y Direccion",
  "employmentStatus": "ACTIVE"
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 400 Bad Request | `https://api.atelier.pe/errors/invalid-argument` | `MethodArgumentNotValidException` | Salario no positivo o divisa inválida |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso iam:members:compensate denegado |
| 404 Not Found | `https://api.atelier.pe/errors/employee-not-found` | `EmployeeProfileNotFoundException` | Expediente no encontrado en el taller |


```json
{
  "type": "https://api.atelier.pe/errors/employee-not-found",
  "title": "Expediente Inexistente",
  "status": 404,
  "detail": "No se encontro el expediente para actualizar condiciones salariales.",
  "instance": "/api/v1/hr/employees/f1a2b3c4-d5e6-4789-0123-456789abc999/salary",
  "timestamp": "2026-10-01T15:30:00Z",
  "correlationId": "req-emp-sal-404-01"
}
```

---

### PATCH /api/v1/hr/employees/{profileId}/status

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.hr.interfaces.rest.StaffProfilesController`
* **Método Java:** `public ResponseEntity<EmployeeProfileResource> updateEmploymentStatus(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("profileId") UUID profileId, @Valid @RequestBody UpdateEmploymentStatusRequest request)`

#### Descripción Funcional
Actualiza la situación laboral formal del colaborador dentro del taller automotriz, permitiendo transiciones entre estados operativos reglamentarios: ACTIVE (activo), ON_LEAVE (de permiso o descanso médico) o TERMINATED (cese contractual). Un colaborador en estado ON_LEAVE o TERMINATED queda inhabilitado automáticamente para marcación de asistencias y asignación de órdenes de trabajo.

#### Seguridad y Autorización
* **Rol Mínimo:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueño de Taller (ROLE_WORKSHOP_OWNER).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iam:members:manage_roles')")`
* **Contexto Multi-Inquilino:** Valida que el expediente pertenezca al tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `profileId` (UUID): Identificador único del expediente del colaborador
* **Query Parameters:** Ninguno.

#### Cuerpo de Petición (Request DTO)
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.requests.UpdateEmploymentStatusRequest`

| Campo | Tipo Java | Restricciones y Validaciones | Descripción |
| :--- | :--- | :--- | :--- |
| `employmentStatus` | `String` | @NotBlank, @Pattern("ACTIVE|ON_LEAVE|TERMINATED") | Nuevo estado laboral que se asignará al colaborador |


```json
{
  "employmentStatus": "ON_LEAVE"
}
```
#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `com.andeva.atelier.platform.hr.interfaces.rest.resources.responses.EmployeeProfileResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del expediente |
| `branchId` | `UUID` | Sucursal física |
| `membershipId` | `UUID` | Membresía institucional |
| `assignedShiftId` | `UUID` | Turno de trabajo habitual |
| `baseSalary` | `BigDecimal` | Remuneración básica |
| `currency` | `String` | Divisa pactada |
| `compensationType` | `String` | Modalidad salarial |
| `jobTitle` | `String` | Cargo desempeñado |
| `employmentStatus` | `String` | Estado laboral actualizado |


```json
{
  "id": "f1a2b3c4-d5e6-4789-0123-456789abcdef",
  "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
  "membershipId": "c2d3e4f5-a6b7-4c8d-9e0f-1a2b3c4d5e6f",
  "assignedShiftId": "e3b0c442-98fc-4c14-9afe-0c07c4587123",
  "baseSalary": 2800,
  "currency": "PEN",
  "compensationType": "FIXED_MONTHLY",
  "jobTitle": "Mecanico Especialista en Suspension y Direccion",
  "employmentStatus": "ON_LEAVE"
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 400 Bad Request | `https://api.atelier.pe/errors/invalid-argument` | `MethodArgumentNotValidException` | Estado laboral no reconocido |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso iam:members:manage_roles no concedido |
| 404 Not Found | `https://api.atelier.pe/errors/employee-not-found` | `EmployeeProfileNotFoundException` | Expediente no encontrado en el taller |


```json
{
  "type": "https://api.atelier.pe/errors/employee-not-found",
  "title": "Expediente No Encontrado",
  "status": 404,
  "detail": "No se encontro el expediente para actualizar la condicion laboral.",
  "instance": "/api/v1/hr/employees/f1a2b3c4-d5e6-4789-0123-456789abc999/status",
  "timestamp": "2026-10-01T15:31:00Z",
  "correlationId": "req-emp-stat-404-01"
}
```

---

