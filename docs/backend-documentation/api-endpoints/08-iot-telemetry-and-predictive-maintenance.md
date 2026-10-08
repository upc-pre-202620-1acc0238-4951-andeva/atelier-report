# Especificación Canónica de Endpoints REST: IoT Telemetry and Predictive Maintenance

El Bounded Context **IoT Telemetry and Predictive Maintenance** (`com.andeva.atelier.platform.iot`) constituye el núcleo de innovación telemática y diagnóstico predictivo de Atelier Platform. Transforma el taller mecánico automotriz convencional en un centro técnico de alta precisión mediante la captura masiva de telemetría vehicular en tiempo real, el almacenamiento de series temporales en hipertablas particionadas de TimescaleDB, la decodificación pericial de códigos de diagnóstico de falla (DTC) y la inferencia predictiva asistida por modelos LPU de Groq con Spring AI.

---

## 1. Arquitectura de Seguridad y Convenciones Globales

Todos los endpoints documentados en esta especificación técnica se adhieren rigurosamente a los estándares de arquitectura de Atelier Platform:

* **Aislamiento de Carga en Hipertablas de TimescaleDB:** Las lecturas telemétricas de alta frecuencia (velocidad, revoluciones por minuto, temperatura del refrigerante y voltaje de batería) se persisten en la hipertabla particionada `telemetry_logs`. Las consultas analíticas históricas aprovechan la función nativa `time_bucket` para calcular agregaciones estadísticas sin degradar el rendimiento relacional de PostgreSQL.
* **Autenticación y Autorización Basada en Privilegios Atómicos:** Todo acceso exige la cabecera obligatoria `Authorization: Bearer <JWT>`. La seguridad a nivel de controlador se aplica mediante `@PreAuthorize("hasAuthority('...')")`, verificando las autoridades asociadas al personal de bahía, asesores de servicio o pasarelas de hardware.
* **Aislamiento Multi-Inquilino de Primer Nivel:** Cada escáner, instalación, registro telemático y reporte pericial se encuentra vinculado de forma obligatoria al `tenant_id` del taller. Se bloquea cualquier intento de vinculación o lectura inter-inquilino a nivel perimetral.
* **Integración con Spring AI y Groq LPU:** La generación de reportes de salud mecánica evalúa simultáneamente las fallas activas y el comportamiento cinemático de los últimos 30 días, consumiendo el motor de inferencia Groq con structured output tipado para la recomendación preventiva de servicios de mantenimiento.
* **Estandarización de Respuestas de Error (RFC 7807):** Cualquier falla de validación o excepción de dominio se proyecta como un documento `ProblemDetail` bajo el estándar `application/problem+json`.

---

## 2. Índice Canónico de Endpoints

El módulo expone exactamente 21 endpoints distribuidos en 6 controladores especializados:

| No. | Método | Ruta Relativa | Controlador Java | Método Java | Permiso Atómico Requerido | Rol Mínimo Sugerido |
| :---: | :---: | :--- | :--- | :--- | :--- | :--- |
| 1 | `POST` | `/api/v1/iot/devices` | `Obd2DevicesController` | `registerDevice()` | `iot:devices:register` | Administrador de Taller |
| 2 | `GET` | `/api/v1/iot/devices/{id}` | `Obd2DevicesController` | `getDeviceById()` | `iot:devices:read` | Jefe de Taller |
| 3 | `GET` | `/api/v1/iot/devices` | `Obd2DevicesController` | `listDevices()` | `iot:devices:read` | Jefe de Taller |
| 4 | `PATCH` | `/api/v1/iot/devices/{id}/status` | `Obd2DevicesController` | `updateDeviceStatus()` | `iot:devices:manage` | Jefe de Taller |
| 5 | `POST` | `/api/v1/iot/installations/install` | `DeviceInstallationsController` | `installDevice()` | `iot:installations:manage` | Mecánico |
| 6 | `POST` | `/api/v1/iot/installations/{id}/uninstall` | `DeviceInstallationsController` | `uninstallDevice()` | `iot:installations:manage` | Mecánico |
| 7 | `GET` | `/api/v1/iot/installations/vehicle/{vehicleId}/active` | `DeviceInstallationsController` | `getActiveInstallationByVehicle()` | `iot:installations:read` | Asesor de Servicio |
| 8 | `POST` | `/api/v1/iot/telemetry/batch` | `TelemetryIngestionController` | `ingestTelemetryBatch()` | `iot:telemetry:ingest` | Dispositivo Telemático / Móvil |
| 9 | `GET` | `/api/v1/iot/telemetry/vehicle/{vehicleId}/latest` | `TelemetryIngestionController` | `getLatestTelemetry()` | `iot:telemetry:read` | Mecánico |
| 10 | `GET` | `/api/v1/iot/telemetry/vehicle/{vehicleId}/history` | `TelemetryIngestionController` | `getTelemetryHistory()` | `iot:telemetry:read` | Asesor de Servicio |
| 11 | `POST` | `/api/v1/iot/faults` | `VehicleFaultsController` | `registerVehicleFault()` | `iot:faults:write` | Mecánico |
| 12 | `GET` | `/api/v1/iot/faults/vehicle/{vehicleId}/active` | `VehicleFaultsController` | `getActiveFaultsByVehicle()` | `iot:faults:read` | Asesor de Servicio |
| 13 | `POST` | `/api/v1/iot/faults/{id}/resolve` | `VehicleFaultsController` | `resolveVehicleFault()` | `iot:faults:resolve` | Mecánico |
| 14 | `GET` | `/api/v1/iot/alerts/tenant` | `PredictiveAlertsController` | `getActiveAlertsForTenant()` | `iot:alerts:read` | Asesor de Servicio |
| 15 | `GET` | `/api/v1/iot/alerts/vehicle/{vehicleId}` | `PredictiveAlertsController` | `getAlertsByVehicle()` | `iot:alerts:read` | Asesor de Servicio |
| 16 | `PATCH` | `/api/v1/iot/alerts/{id}/acknowledge` | `PredictiveAlertsController` | `acknowledgeAlert()` | `iot:alerts:acknowledge` | Asesor de Servicio |
| 17 | `POST` | `/api/v1/iot/alerts/{id}/convert-to-appointment` | `PredictiveAlertsController` | `convertAlertToAppointment()` | `iot:alerts:convert` | Asesor de Servicio |
| 18 | `POST` | `/api/v1/iot/health-reports/generate` | `VehicleHealthReportsController` | `generateHealthReport()` | `iot:health_reports:generate` | Asesor de Servicio |
| 19 | `POST` | `/api/v1/iot/health-reports/generate-async` | `VehicleHealthReportsController` | `generateHealthReportAsync()` | `iot:health_reports:generate` | Jefe de Taller |
| 20 | `GET` | `/api/v1/iot/health-reports/latest` | `VehicleHealthReportsController` | `getLatestHealthReport()` | `iot:health_reports:read` | Mecánico |
| 21 | `GET` | `/api/v1/iot/health-reports/{reportId}/pdf` | `VehicleHealthReportsController` | `downloadHealthReportPdf()` | `iot:health_reports:read` | Asesor de Servicio |

---

## 3. Endpoints de Obd2DevicesController

El controlador `Obd2DevicesController` administra el inventario de hardware de adaptadores y escáneres telemáticos pertenecientes a la dotación técnica del taller automotriz.

### 3.1. [POST] /api/v1/iot/devices

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.iot.interfaces.rest.controllers.Obd2DevicesController`
* **Método Java:** `public ResponseEntity<Obd2DeviceResponse> registerDevice(@Valid @RequestBody RegisterDeviceRequest request, @AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/iot/devices`
* **Ruta Completa:** `/api/v1/iot/devices`
* **Propósito:** Registra un nuevo escáner o adaptador telemático en el inventario del taller automotriz.

#### Descripción Funcional
Permite incorporar un dispositivo físico al parque tecnológico del taller. Valida que el identificador único de hardware (`deviceIdentifier`, tal como dirección MAC Bluetooth o número de serie IMEI) no se encuentre registrado previamente en el sistema. Asocia el dispositivo al `tenant_id` autenticado, inicializa su estado operativo como disponible (`AVAILABLE`) y persiste sus especificaciones de modelo y firmware para futuras actualizaciones remotas.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Dueño de Taller (`ROLE_WORKSHOP_OWNER`) o Administrador de Taller (`ROLE_TENANT_ADMIN`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:devices:register')")`
* **Aislamiento Multi-Inquilino:** El hardware registrado queda vinculado exclusivamente al taller autenticado.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
* **Parámetros de Ruta (Path Parameters):** No aplica.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
* **Registro Java DTO:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.requests.RegisterDeviceRequest`
* **Definición de Campos:**

| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `deviceIdentifier` | `String` | Sí | `@NotBlank` | Dirección MAC Bluetooth o código de serie físico único |
| `connectionType` | `String` | Sí | `@NotBlank` | Protocolo de conectividad (BLUETOOTH_BLE, WIFI, CELLULAR_4G) |
| `hardwareModel` | `String` | No | Sin restricción adicional | Fabricante y referencia técnica del microcontrolador |
| `firmwareVersion` | `String` | No | Sin restricción adicional | Versión de software embebido instalado en el escáner |

**Ejemplo de Carga Útil JSON (Request):**
```json
{
  "deviceIdentifier": "00:1B:44:11:3A:B7",
  "connectionType": "BLUETOOTH_BLE",
  "hardwareModel": "ELM327-v2.2-Pro",
  "firmwareVersion": "v1.4.2"
}
```

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `201 Created` con cabecera `Location: /api/v1/iot/devices/{id}`
* **Registro Java DTO:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.Obd2DeviceResponse`
* **Definición de Campos Proyectados:**

| Campo | Tipo de Dato | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador único del dispositivo en la base de datos |
| `tenantId` | `UUID` | Identificador del taller propietario del hardware |
| `deviceIdentifier` | `String` | Identificador físico de fábrica registrado |
| `connectionType` | `String` | Protocolo de comunicación telemática |
| `status` | `String` | Estado operativo inicial (AVAILABLE, INSTALLED, IN_MAINTENANCE) |
| `hardwareModel` | `String` | Modelo comercial del escáner |
| `firmwareVersion` | `String` | Versión del firmware registrado |
| `createdAt` | `Instant` | Marca temporal de alta en formato ISO 8601 UTC |

**Ejemplo de Carga Útil JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000501",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "deviceIdentifier": "00:1B:44:11:3A:B7",
  "connectionType": "BLUETOOTH_BLE",
  "status": "AVAILABLE",
  "hardwareModel": "ELM327-v2.2-Pro",
  "firmwareVersion": "v1.4.2",
  "createdAt": "2026-10-04T02:00:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Parámetros obligatorios ausentes en la solicitud |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| `403 Forbidden` | `AccessDeniedException` | Permisos insuficientes para registrar dispositivos telemáticos |
| `409 Conflict` | `InvalidDeviceIdentifierException` | El identificador de hardware ya se encuentra registrado |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/device-already-exists",
  "title": "Device Identifier Conflict",
  "status": 409,
  "detail": "El escáner con identificador 00:1B:44:11:3A:B7 ya se encuentra registrado en el sistema",
  "instance": "/api/v1/iot/devices",
  "code": "ERR_DEVICE_ALREADY_EXISTS",
  "timestamp": "2026-10-04T02:00:00Z"
}
```

---

### 3.2. [GET] /api/v1/iot/devices/{id}

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.iot.interfaces.rest.controllers.Obd2DevicesController`
* **Método Java:** `public ResponseEntity<Obd2DeviceResponse> getDeviceById(@PathVariable UUID id, @AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/iot/devices`
* **Ruta Completa:** `/api/v1/iot/devices/{id}`
* **Propósito:** Consulta los datos técnicos y operativos de un escáner específico.

#### Descripción Funcional
Recupera la entidad `Obd2Device` desde la base de datos validando su existencia y comprobando que pertenezca al `tenant_id` autenticado. Retorna el estado funcional del escáner, su identificador físico, protocolo de conexión y datos de versión.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Jefe de Taller (`ROLE_HEAD_MECHANIC`) o Administrador de Taller (`ROLE_TENANT_ADMIN`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:devices:read')")`
* **Aislamiento Multi-Inquilino:** Filtrado estricto por `tenant_id`.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Accept: application/json`
* **Parámetros de Ruta (Path Parameters):**
  * `id` (`UUID`): Identificador universal del dispositivo consultado.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
No aplica (Solicitud de tipo HTTP GET sin cuerpo).

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `200 OK`
* **Registro Java DTO:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.Obd2DeviceResponse`
* **Definición de Campos Proyectados:** Idéntica a la definición de `Obd2DeviceResponse`.

**Ejemplo de Carga Útil JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000501",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "deviceIdentifier": "00:1B:44:11:3A:B7",
  "connectionType": "BLUETOOTH_BLE",
  "status": "AVAILABLE",
  "hardwareModel": "ELM327-v2.2-Pro",
  "firmwareVersion": "v1.4.2",
  "createdAt": "2026-10-04T02:00:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentTypeMismatchException` | El identificador proporcionado en la ruta no es un UUID válido |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o expirado |
| `403 Forbidden` | `AccessDeniedException` | Intento de acceder a hardware perteneciente a otro taller |
| `404 Not Found` | `DeviceNotFoundException` | El dispositivo con el identificador indicado no existe en el taller |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/device-not-found",
  "title": "Device Not Found",
  "status": 404,
  "detail": "El escáner con identificador 018f6c40-7e12-7000-8000-000000000599 no fue localizado",
  "instance": "/api/v1/iot/devices/018f6c40-7e12-7000-8000-000000000599",
  "code": "ERR_DEVICE_NOT_FOUND",
  "timestamp": "2026-10-04T02:05:00Z"
}
```

---

### 3.3. [GET] /api/v1/iot/devices

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.iot.interfaces.rest.controllers.Obd2DevicesController`
* **Método Java:** `public ResponseEntity<List<Obd2DeviceResponse>> listDevices(@RequestParam(required = false) String status, @AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/iot/devices`
* **Ruta Completa:** `/api/v1/iot/devices`
* **Propósito:** Lista el inventario completo de escáneres telemáticos del taller con filtro opcional por estado operativo.

#### Descripción Funcional
Permite a los jefes de taller y mecánicos visualizar todos los escáneres registrados para su sede o empresa. Admite un parámetro opcional de consulta `status` para filtrar dispositivos disponibles para instalación (`AVAILABLE`), en uso activo en vehículos de clientes (`INSTALLED`) o en mantenimiento técnico (`IN_MAINTENANCE`).

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Jefe de Taller (`ROLE_HEAD_MECHANIC`) o Administrador de Taller (`ROLE_TENANT_ADMIN`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:devices:read')")`
* **Aislamiento Multi-Inquilino:** Filtrado estricto por el `tenant_id` autenticado.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Accept: application/json`
* **Parámetros de Ruta (Path Parameters):** No aplica.
* **Parámetros de Consulta (Query Parameters):**
  * `status` (`String`, Opcional): Filtro de situación operativa (AVAILABLE, INSTALLED, IN_MAINTENANCE).

#### Recurso de Petición (Request Body)
No aplica (Solicitud de tipo HTTP GET sin cuerpo).

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `200 OK`
* **Registro Java DTO:** `List<com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.Obd2DeviceResponse>`
* **Definición de Campos Proyectados:** Idéntica a la definición de `Obd2DeviceResponse`.

**Ejemplo de Carga Útil JSON (Response):**
```json
[
  {
    "id": "018f6c40-7e12-7000-8000-000000000501",
    "tenantId": "018f6c40-7e12-7000-8000-000000000001",
    "deviceIdentifier": "00:1B:44:11:3A:B7",
    "connectionType": "BLUETOOTH_BLE",
    "status": "AVAILABLE",
    "hardwareModel": "ELM327-v2.2-Pro",
    "firmwareVersion": "v1.4.2",
    "createdAt": "2026-10-04T02:00:00Z"
  },
  {
    "id": "018f6c40-7e12-7000-8000-000000000502",
    "tenantId": "018f6c40-7e12-7000-8000-000000000001",
    "deviceIdentifier": "00:1B:44:22:9C:F1",
    "connectionType": "BLUETOOTH_BLE",
    "status": "INSTALLED",
    "hardwareModel": "OBDLink-MX-Plus",
    "firmwareVersion": "v2.1.0",
    "createdAt": "2026-10-03T18:00:00Z"
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| `403 Forbidden` | `AccessDeniedException` | Permisos insuficientes para listar el inventario telemático |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/access-denied",
  "title": "Access Denied",
  "status": 403,
  "detail": "El usuario no cuenta con autorización para auditar los dispositivos telemáticos del taller",
  "instance": "/api/v1/iot/devices",
  "code": "ERR_ACCESS_DENIED",
  "timestamp": "2026-10-04T02:10:00Z"
}
```

---

### 3.4. [PATCH] /api/v1/iot/devices/{id}/status

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.iot.interfaces.rest.controllers.Obd2DevicesController`
* **Método Java:** `public ResponseEntity<Obd2DeviceResponse> updateDeviceStatus(@PathVariable UUID id, @Valid @RequestBody UpdateDeviceStatusRequest request, @AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/iot/devices`
* **Ruta Completa:** `/api/v1/iot/devices/{id}/status`
* **Propósito:** Actualiza el estado operativo o administrativo de un dispositivo específico.

#### Descripción Funcional
Permite cambiar el estado de un escáner para reflejar situaciones operativas como envío a laboratorio para calibración (`IN_MAINTENANCE`), reincorporación a inventario (`AVAILABLE`) o baja definitiva por daño físico irreparable (`DECOMMISSIONED`). Valida que el dispositivo no se encuentre actualmente vinculado a una sesión activa de instalación en un vehículo antes de pasarlo a mantenimiento o baja.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Jefe de Taller (`ROLE_HEAD_MECHANIC`) o Administrador de Taller (`ROLE_TENANT_ADMIN`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:devices:manage')")`
* **Aislamiento Multi-Inquilino:** Modificación restringida al taller propietario del hardware.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
* **Parámetros de Ruta (Path Parameters):**
  * `id` (`UUID`): Identificador universal del dispositivo a modificar.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
* **Registro Java DTO:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.requests.UpdateDeviceStatusRequest`
* **Definición de Campos:**

| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `status` | `String` | Sí | `@NotBlank` | Nuevo estado operativo (AVAILABLE, IN_MAINTENANCE, DECOMMISSIONED) |

**Ejemplo de Carga Útil JSON (Request):**
```json
{
  "status": "IN_MAINTENANCE"
}
```

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `200 OK`
* **Registro Java DTO:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.Obd2DeviceResponse`
* **Definición de Campos Proyectados:** Idéntica a la definición de `Obd2DeviceResponse`.

**Ejemplo de Carga Útil JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000501",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "deviceIdentifier": "00:1B:44:11:3A:B7",
  "connectionType": "BLUETOOTH_BLE",
  "status": "IN_MAINTENANCE",
  "hardwareModel": "ELM327-v2.2-Pro",
  "firmwareVersion": "v1.4.2",
  "createdAt": "2026-10-04T02:00:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Estado no válido o cuerpo de petición vacío |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o expirado |
| `403 Forbidden` | `AccessDeniedException` | Permisos insuficientes para actualizar el estado del dispositivo |
| `404 Not Found` | `DeviceNotFoundException` | El dispositivo solicitado no existe en el inventario del taller |
| `409 Conflict` | `DeviceAlreadyInstalledException` | No se puede alterar el estado porque el dispositivo está instalado en un automóvil |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/device-already-installed",
  "title": "Device Currently Installed",
  "status": 409,
  "detail": "El escáner se encuentra actualmente instalado en un vehículo y no puede pasar a mantenimiento sin desvincularse primero",
  "instance": "/api/v1/iot/devices/018f6c40-7e12-7000-8000-000000000501/status",
  "code": "ERR_DEVICE_ALREADY_INSTALLED",
  "timestamp": "2026-10-04T02:15:00Z"
}
```

---

## 4. Endpoints de DeviceInstallationsController

El controlador `DeviceInstallationsController` gobierna el ciclo de vinculación física y operativa de los escáneres telemáticos sobre los vehículos de clientes en las bahías o fosas del taller automotriz.

### 4.1. [POST] /api/v1/iot/installations/install

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.iot.interfaces.rest.controllers.DeviceInstallationsController`
* **Método Java:** `public ResponseEntity<DeviceInstallationResponse> installDevice(@Valid @RequestBody InstallDeviceRequest request, @AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/iot/installations`
* **Ruta Completa:** `/api/v1/iot/installations/install`
* **Propósito:** Vincula formalmente un escáner OBD-II disponible a un vehículo en el taller, registrando el kilometraje inicial de la sesión de diagnóstico.

#### Descripción Funcional
Comprueba que el escáner se encuentre en estado disponible (`AVAILABLE`) y que el vehículo no cuente con otra sesión de escáner activa simultánea (`ActiveInstallationConflictException`). Verifica la cuota operativa del taller respecto al límite máximo de escáneres activos autorizados por su plan de suscripción (`maxActiveObd2Devices`). Crea el agregado `DeviceInstallation` con marca temporal de inicio y odómetro inicial, actualiza el estado del dispositivo a instalado (`INSTALLED`) y publica el evento `DeviceInstalledEvent`.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Mecánico (`ROLE_MECHANIC`), Jefe de Taller (`ROLE_HEAD_MECHANIC`) o Dueño de Taller (`ROLE_WORKSHOP_OWNER`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:installations:manage')")`
* **Aislamiento Multi-Inquilino:** El vehículo y el dispositivo deben pertenecer o encontrarse atendidos bajo el `tenant_id` del taller autenticado.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
* **Parámetros de Ruta (Path Parameters):** No aplica.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
* **Registro Java DTO:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.requests.InstallDeviceRequest`
* **Definición de Campos:**

| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `deviceId` | `UUID` | Sí | `@NotNull` | Identificador único del escáner en inventario |
| `vehicleId` | `UUID` | Sí | `@NotNull` | Identificador del vehículo automotriz a diagnosticar |
| `currentOdometerKm` | `int` | Sí | `@Min(0)` | Lectura actual del cuentakilómetros del vehículo |

**Ejemplo de Carga Útil JSON (Request):**
```json
{
  "deviceId": "018f6c40-7e12-7000-8000-000000000501",
  "vehicleId": "018f6c40-7e12-7000-8000-000000000601",
  "currentOdometerKm": 48520
}
```

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `201 Created` con cabecera `Location: /api/v1/iot/installations/{id}`
* **Registro Java DTO:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.DeviceInstallationResponse`
* **Definición de Campos Proyectados:**

| Campo | Tipo de Dato | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador único de la sesión de instalación |
| `deviceId` | `UUID` | Identificador del escáner instalado |
| `vehicleId` | `UUID` | Identificador del vehículo atendido |
| `tenantId` | `UUID` | Identificador del taller que gestiona la instalación |
| `installedAt` | `Instant` | Marca temporal de conexión en formato ISO 8601 UTC |
| `uninstalledAt` | `Instant` | Marca temporal de desconexión (null mientras siga activo) |
| `initialOdometerKm` | `int` | Kilometraje registrado al momento de la instalación |
| `finalOdometerKm` | `Integer` | Kilometraje al momento del retiro (null mientras siga activo) |
| `isActive` | `boolean` | Indica si la vinculación se encuentra operativa |

**Ejemplo de Carga Útil JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000701",
  "deviceId": "018f6c40-7e12-7000-8000-000000000501",
  "vehicleId": "018f6c40-7e12-7000-8000-000000000601",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "installedAt": "2026-10-04T02:20:00Z",
  "uninstalledAt": null,
  "initialOdometerKm": 48520,
  "finalOdometerKm": null,
  "isActive": true
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Campos obligatorios nulos o kilometraje negativo |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| `403 Forbidden` | `QuotaExceededException` | El taller superó el cupo de escáneres activos permitido por su plan SaaS |
| `404 Not Found` | `DeviceNotFoundException` | El escáner indicado no fue localizado en el taller |
| `409 Conflict` | `ActiveInstallationConflictException` | El vehículo ya cuenta con otro escáner activo conectado |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/active-installation-conflict",
  "title": "Active Installation Conflict",
  "status": 409,
  "detail": "El vehículo ya posee una sesión de escáner telemático activa en este momento",
  "instance": "/api/v1/iot/installations/install",
  "code": "ERR_ACTIVE_INSTALLATION_CONFLICT",
  "timestamp": "2026-10-04T02:20:00Z"
}
```

---

### 4.2. [POST] /api/v1/iot/installations/{id}/uninstall

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.iot.interfaces.rest.controllers.DeviceInstallationsController`
* **Método Java:** `public ResponseEntity<DeviceInstallationResponse> uninstallDevice(@PathVariable UUID id, @Valid @RequestBody UninstallDeviceRequest request, @AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/iot/installations`
* **Ruta Completa:** `/api/v1/iot/installations/{id}/uninstall`
* **Propósito:** Registra la desconexión física de un escáner telemático y asienta el kilometraje final del vehículo.

#### Descripción Funcional
Finaliza una sesión de monitoreo telemático activa. Valida que el kilometraje final no sea inferior al kilometraje registrado al momento de la instalación inicial. Marca la instalación como inactiva (`isActive = false`), asienta la marca temporal de desconexión (`uninstalledAt`), restituye el estado del escáner a disponible (`AVAILABLE`) y emite el evento de dominio `DeviceUninstalledEvent`.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Mecánico (`ROLE_MECHANIC`), Jefe de Taller (`ROLE_HEAD_MECHANIC`) o Dueño de Taller (`ROLE_WORKSHOP_OWNER`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:installations:manage')")`
* **Aislamiento Multi-Inquilino:** La sesión de instalación debe pertenecer al `tenant_id` autenticado.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
* **Parámetros de Ruta (Path Parameters):**
  * `id` (`UUID`): Identificador universal de la instalación activa a concluir.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
* **Registro Java DTO:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.requests.UninstallDeviceRequest`
* **Definición de Campos:**

| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `finalOdometerKm` | `int` | Sí | `@Min(0)` | Lectura del cuentakilómetros al momento de la desconexión |
| `uninstalledAt` | `Instant` | No | Sin restricción adicional | Marca temporal del retiro físico (asume hora actual si es nulo) |

**Ejemplo de Carga Útil JSON (Request):**
```json
{
  "finalOdometerKm": 48550,
  "uninstalledAt": "2026-10-04T02:25:00Z"
}
```

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `200 OK`
* **Registro Java DTO:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.DeviceInstallationResponse`
* **Definición de Campos Proyectados:** Idéntica a la definición de `DeviceInstallationResponse`.

**Ejemplo de Carga Útil JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000701",
  "deviceId": "018f6c40-7e12-7000-8000-000000000501",
  "vehicleId": "018f6c40-7e12-7000-8000-000000000601",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "installedAt": "2026-10-04T02:20:00Z",
  "uninstalledAt": "2026-10-04T02:25:00Z",
  "initialOdometerKm": 48520,
  "finalOdometerKm": 48550,
  "isActive": false
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `IoTDomainException` | El odómetro final es inferior al kilometraje registrado al instalar |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| `403 Forbidden` | `AccessDeniedException` | Permisos insuficientes para desvincular el escáner |
| `404 Not Found` | `InstallationNotFoundException` | La sesión de instalación especificada no existe |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/installation-not-found",
  "title": "Installation Not Found",
  "status": 404,
  "detail": "La sesión de instalación con identificador 018f6c40-7e12-7000-8000-000000000799 no existe en el taller",
  "instance": "/api/v1/iot/installations/018f6c40-7e12-7000-8000-000000000799/uninstall",
  "code": "ERR_INSTALLATION_NOT_FOUND",
  "timestamp": "2026-10-04T02:25:00Z"
}
```

---

### 4.3. [GET] /api/v1/iot/installations/vehicle/{vehicleId}/active

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.iot.interfaces.rest.controllers.DeviceInstallationsController`
* **Método Java:** `public ResponseEntity<DeviceInstallationResponse> getActiveInstallationByVehicle(@PathVariable UUID vehicleId, @AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/iot/installations`
* **Ruta Completa:** `/api/v1/iot/installations/vehicle/{vehicleId}/active`
* **Propósito:** Consulta los datos del escáner telemático actualmente conectado y en transmisión sobre un vehículo específico.

#### Descripción Funcional
Permite a la aplicación móvil del mecánico y al panel web de taller verificar si un vehículo en fosa o recepción dispone de un escáner conectado. Consulta la tabla de instalaciones filtrando por `vehicleId` y la condición `uninstalledAt IS NULL` y `isActive = true`. Si existe sesión activa, retorna la información completa de la instalación junto con el kilometraje de inicio.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Mecánico (`ROLE_MECHANIC`), Asesor de Servicio (`ROLE_SERVICE_ADVISOR`) o Jefe de Taller (`ROLE_HEAD_MECHANIC`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:installations:read')")`
* **Aislamiento Multi-Inquilino:** Comprobación estricta de pertenencia del vehículo al `tenant_id` autenticado.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Accept: application/json`
* **Parámetros de Ruta (Path Parameters):**
  * `vehicleId` (`UUID`): Identificador universal del vehículo consultado.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
No aplica (Solicitud de tipo HTTP GET sin cuerpo).

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `200 OK`
* **Registro Java DTO:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.DeviceInstallationResponse`
* **Definición de Campos Proyectados:** Idéntica a la definición de `DeviceInstallationResponse`.

**Ejemplo de Carga Útil JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000701",
  "deviceId": "018f6c40-7e12-7000-8000-000000000501",
  "vehicleId": "018f6c40-7e12-7000-8000-000000000601",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "installedAt": "2026-10-04T02:20:00Z",
  "uninstalledAt": null,
  "initialOdometerKm": 48520,
  "finalOdometerKm": null,
  "isActive": true
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentTypeMismatchException` | El identificador del vehículo en la ruta no es un UUID válido |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| `403 Forbidden` | `AccessDeniedException` | Permisos insuficientes para consultar instalaciones del vehículo |
| `404 Not Found` | `InstallationNotFoundException` | El vehículo no cuenta con un escáner telemático activo conectado |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/installation-not-found",
  "title": "No Active Installation Found",
  "status": 404,
  "detail": "El vehículo no cuenta con un dispositivo OBD-II activo instalado en este momento",
  "instance": "/api/v1/iot/installations/vehicle/018f6c40-7e12-7000-8000-000000000601/active",
  "code": "ERR_INSTALLATION_NOT_FOUND",
  "timestamp": "2026-10-04T02:30:00Z"
}
```

---

## 5. Endpoints de TelemetryIngestionController

El controlador `TelemetryIngestionController` constituye la compuerta de ingesta telemática de alto rendimiento de Atelier Platform, procesando ráfagas masivas de lecturas hacia TimescaleDB y exponiendo tacómetros en vivo y series temporales agregadas.

### 5.1. [POST] /api/v1/iot/telemetry/batch

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.iot.interfaces.rest.controllers.TelemetryIngestionController`
* **Método Java:** `public ResponseEntity<TelemetryIngestionAckResponse> ingestTelemetryBatch(@Valid @RequestBody TelemetryBatchRequest request, @AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/iot/telemetry`
* **Ruta Completa:** `/api/v1/iot/telemetry/batch`
* **Propósito:** Ingesta un lote de lecturas telemétricas cinemáticas y térmicas de un vehículo directamente hacia las hipertablas de TimescaleDB.

#### Descripción Funcional
Recibe ráfagas de telemetría emitidas periódicamente por la aplicación móvil (puente BLE) o módems celulares OBD-II. Comprueba que el vehículo mantenga una sesión de instalación activa en el taller. Valida los rangos físicos de las magnitudes (temperatura entre -40 y 150 grados Celsius, RPM mayores o iguales a cero, velocidad plausible). Ejecuta una persistencia masiva en bloque mediante inserción JDBC optimizada sobre la hipertabla `telemetry_logs` de TimescaleDB, garantizando tiempos de procesamiento inferiores a 25 milisegundos para lotes de hasta 100 lecturas. Dispara de forma asíncrona el motor de detección de anomalías térmicas y cinemáticas.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Ingesta Telemática
* **Rol Mínimo Requerido:** Mecánico (`ROLE_MECHANIC`), Dispositivo Telemático o Aplicación Móvil de Taller
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:telemetry:ingest')")`
* **Aislamiento Multi-Inquilino:** La tenencia se resuelve a partir del vehículo asociado y la instalación activa del taller.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
* **Parámetros de Ruta (Path Parameters):** No aplica.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
* **Registro Java DTO:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.requests.TelemetryBatchRequest`
* **Definición de Campos:**

| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `vehicleId` | `UUID` | Sí | `@NotNull` | Identificador del vehículo emisor de los datos |
| `readings` | `List<TelemetryReadingItemDto>` | Sí | `@NotEmpty, @Valid` | Lista ordenada cronológicamente de lecturas tomadas |
| `readings[].timestamp` | `Instant` | Sí | `@NotNull` | Marca temporal de la lectura en formato ISO 8601 UTC |
| `readings[].latitude` | `Double` | No | Sin restricción adicional | Coordenada GPS latitud |
| `readings[].longitude` | `Double` | No | Sin restricción adicional | Coordenada GPS longitud |
| `readings[].speedKmh` | `int` | Sí | `@Min(0)` | Velocidad instantánea en kilómetros por hora |
| `readings[].engineTempCelsius`| `Double` | Sí | `@NotNull` | Temperatura del refrigerante de motor en grados Celsius |
| `readings[].engineRpm` | `int` | Sí | `@Min(0)` | Revoluciones por minuto del motor |
| `readings[].fuelPercentage` | `Double` | No | Sin restricción adicional | Nivel de combustible relativo entre 0 y 100 por ciento |
| `readings[].batteryVoltage` | `Double` | No | Sin restricción adicional | Tensión en bornes de batería en voltios |

**Ejemplo de Carga Útil JSON (Request):**
```json
{
  "vehicleId": "018f6c40-7e12-7000-8000-000000000601",
  "readings": [
    {
      "timestamp": "2026-10-04T02:30:00Z",
      "latitude": -12.0864,
      "longitude": -77.0345,
      "speedKmh": 45,
      "engineTempCelsius": 92.5,
      "engineRpm": 2100,
      "fuelPercentage": 65.0,
      "batteryVoltage": 14.1
    },
    {
      "timestamp": "2026-10-04T02:30:05Z",
      "latitude": -12.0869,
      "longitude": -77.0350,
      "speedKmh": 52,
      "engineTempCelsius": 94.0,
      "engineRpm": 2450,
      "fuelPercentage": 64.9,
      "batteryVoltage": 14.2
    }
  ]
}
```

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `202 Accepted`
* **Registro Java DTO:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.TelemetryIngestionAckResponse`
* **Definición de Campos Proyectados:**

| Campo | Tipo de Dato | Descripción |
| :--- | :--- | :--- |
| `vehicleId` | `UUID` | Identificador del vehículo procesado |
| `ingestedCount` | `int` | Cantidad exacta de lecturas almacenadas con éxito en TimescaleDB |
| `anomalyDetected` | `boolean` | Bandera que indica si el motor analítico detectó anomalías térmicas |
| `alertMessage` | `String` | Mensaje descriptivo de la alerta o null si no se encontraron anomalías |

**Ejemplo de Carga Útil JSON (Response):**
```json
{
  "vehicleId": "018f6c40-7e12-7000-8000-000000000601",
  "ingestedCount": 2,
  "anomalyDetected": false,
  "alertMessage": null
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Lista de lecturas vacía o valores numéricos fuera de rango físico |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| `403 Forbidden` | `AccessDeniedException` | Permisos insuficientes para ingesta telemática |
| `404 Not Found` | `InstallationNotFoundException` | El vehículo no mantiene una sesión de escáner activa en el taller |
| `500 Internal Server Error` | `TimescaleIngestionException` | Falla de conexión o inserción en la hipertabla de TimescaleDB |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/installation-not-found",
  "title": "No Active Installation For Ingestion",
  "status": 404,
  "detail": "No se puede ingerir telemetría porque el vehículo no tiene una sesión de escáner activa",
  "instance": "/api/v1/iot/telemetry/batch",
  "code": "ERR_INSTALLATION_NOT_FOUND",
  "timestamp": "2026-10-04T02:30:00Z"
}
```

---

### 5.2. [GET] /api/v1/iot/telemetry/vehicle/{vehicleId}/latest

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.iot.interfaces.rest.controllers.TelemetryIngestionController`
* **Método Java:** `public ResponseEntity<VehicleLatestTelemetryResponse> getLatestTelemetry(@PathVariable UUID vehicleId, @AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/iot/telemetry`
* **Ruta Completa:** `/api/v1/iot/telemetry/vehicle/{vehicleId}/latest`
* **Propósito:** Retorna la lectura telemétrica más reciente registrada para alimentar tacómetros e indicadores en tiempo real.

#### Descripción Funcional
Provee al panel web de taller o a la vista móvil del mecánico el estado cinemático instantáneo del vehículo. Consulta la última fila persistida en la hipertabla `telemetry_logs` ordenada descendentemente por marca temporal. Retorna velocidad actual, revoluciones por minuto, temperatura de refrigerante, tensión de batería y nivel de combustible.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Mecánico (`ROLE_MECHANIC`), Asesor de Servicio (`ROLE_SERVICE_ADVISOR`) o Jefe de Taller (`ROLE_HEAD_MECHANIC`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:telemetry:read')")`
* **Aislamiento Multi-Inquilino:** Filtrado por vehículo perteneciente al taller autenticado.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Accept: application/json`
* **Parámetros de Ruta (Path Parameters):**
  * `vehicleId` (`UUID`): Identificador universal del vehículo consultado.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
No aplica (Solicitud de tipo HTTP GET sin cuerpo).

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `200 OK`
* **Registro Java DTO:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.VehicleLatestTelemetryResponse`
* **Definición de Campos Proyectados:**

| Campo | Tipo de Dato | Descripción |
| :--- | :--- | :--- |
| `vehicleId` | `UUID` | Identificador único del vehículo |
| `timestamp` | `Instant` | Marca temporal de la última lectura en formato ISO 8601 UTC |
| `latitude` | `Double` | Última coordenada latitud capturada |
| `longitude` | `Double` | Última coordenada longitud capturada |
| `speedKmh` | `int` | Velocidad instantánea en km/h |
| `engineTempCelsius` | `double` | Temperatura del refrigerante del motor en grados Celsius |
| `engineRpm` | `int` | Régimen de giro en revoluciones por minuto |
| `batteryVoltage` | `Double` | Tensión actual del alternador o batería en voltios |
| `fuelPercentage` | `Double` | Porcentaje remanente en depósito de combustible |

**Ejemplo de Carga Útil JSON (Response):**
```json
{
  "vehicleId": "018f6c40-7e12-7000-8000-000000000601",
  "timestamp": "2026-10-04T02:30:05Z",
  "latitude": -12.0869,
  "longitude": -77.0350,
  "speedKmh": 52,
  "engineTempCelsius": 94.0,
  "engineRpm": 2450,
  "batteryVoltage": 14.2,
  "fuelPercentage": 64.9
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentTypeMismatchException` | Identificador de vehículo con formato no válido |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o expirado |
| `403 Forbidden` | `AccessDeniedException` | Permisos insuficientes para consultar telemetría |
| `404 Not Found` | `IoTDomainException` | El vehículo no registra lecturas telemétricas previas |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/telemetry-not-found",
  "title": "Telemetry Log Not Found",
  "status": 404,
  "detail": "El vehículo no registra ninguna lectura telemétrica en la base de datos",
  "instance": "/api/v1/iot/telemetry/vehicle/018f6c40-7e12-7000-8000-000000000601/latest",
  "code": "ERR_TELEMETRY_NOT_FOUND",
  "timestamp": "2026-10-04T02:35:00Z"
}
```

---

### 5.3. [GET] /api/v1/iot/telemetry/vehicle/{vehicleId}/history

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.iot.interfaces.rest.controllers.TelemetryIngestionController`
* **Método Java:** `public ResponseEntity<List<TelemetryHistoryBucketResponse>> getTelemetryHistory(@PathVariable UUID vehicleId, @RequestParam(required = false) Instant from, @RequestParam(required = false) Instant to, @RequestParam(defaultValue = "1 hour") String bucket, @AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/iot/telemetry`
* **Ruta Completa:** `/api/v1/iot/telemetry/vehicle/{vehicleId}/history`
* **Propósito:** Retorna agregaciones históricas de magnitudes telemétricas calculadas mediante la función nativa time_bucket de TimescaleDB.

#### Descripción Funcional
Permite a los asesores de servicio y jefes de taller auditar el comportamiento cinemático y térmico del vehículo en un periodo determinado (por defecto, los últimos 7 días). El repositorio ejecuta una sentencia SQL optimizada con `time_bucket(?, timestamp)` agrupando métricas por hora o por día, calculando promedios ponderados de velocidad, RPM, temperatura y conteo de muestras. Esta información alimenta los gráficos analíticos del panel web sin saturar el ancho de banda.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Asesor de Servicio (`ROLE_SERVICE_ADVISOR`), Jefe de Taller (`ROLE_HEAD_MECHANIC`) o Mecánico (`ROLE_MECHANIC`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:telemetry:read')")`
* **Aislamiento Multi-Inquilino:** Filtrado estricto por vehículo perteneciente al taller autenticado.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Accept: application/json`
* **Parámetros de Ruta (Path Parameters):**
  * `vehicleId` (`UUID`): Identificador universal del vehículo consultado.
* **Parámetros de Consulta (Query Parameters):**
  * `from` (`Instant`, Opcional): Fecha y hora inicial del periodo analítico (formato ISO 8601 UTC).
  * `to` (`Instant`, Opcional): Fecha y hora final del periodo analítico (formato ISO 8601 UTC).
  * `bucket` (`String`, Opcional, por defecto "1 hour"): Intervalo de agregación para TimescaleDB (ej. "15 minutes", "1 hour", "1 day").

#### Recurso de Petición (Request Body)
No aplica (Solicitud de tipo HTTP GET sin cuerpo).

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `200 OK`
* **Registro Java DTO:** `List<com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.TelemetryHistoryBucketResponse>`
* **Definición de Campos Proyectados:**

| Campo | Tipo de Dato | Descripción |
| :--- | :--- | :--- |
| `bucketTime` | `Instant` | Inicio del intervalo temporal agrupado en formato ISO 8601 UTC |
| `vehicleId` | `UUID` | Identificador del vehículo consultado |
| `avgSpeedKmh` | `int` | Promedio de velocidad en el intervalo |
| `avgEngineTempCelsius` | `double` | Promedio de temperatura de refrigerante |
| `avgEngineRpm` | `int` | Promedio de revoluciones por minuto |
| `avgFuelPercentage` | `Double` | Promedio del nivel de combustible |
| `avgBatteryVoltage` | `Double` | Promedio de tensión eléctrica en bornes |
| `sampleCount` | `int` | Conteo de lecturas físicas consolidadas en este intervalo |

**Ejemplo de Carga Útil JSON (Response):**
```json
[
  {
    "bucketTime": "2026-10-04T01:00:00Z",
    "vehicleId": "018f6c40-7e12-7000-8000-000000000601",
    "avgSpeedKmh": 38,
    "avgEngineTempCelsius": 89.2,
    "avgEngineRpm": 1850,
    "avgFuelPercentage": 67.2,
    "avgBatteryVoltage": 14.1,
    "sampleCount": 720
  },
  {
    "bucketTime": "2026-10-04T02:00:00Z",
    "vehicleId": "018f6c40-7e12-7000-8000-000000000601",
    "avgSpeedKmh": 48,
    "avgEngineTempCelsius": 93.1,
    "avgEngineRpm": 2240,
    "avgFuelPercentage": 65.5,
    "avgBatteryVoltage": 14.2,
    "sampleCount": 720
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `IoTDomainException` | Intervalo de agregación bucket no reconocido o rango de fechas invertido |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o expirado |
| `403 Forbidden` | `AccessDeniedException` | Permisos insuficientes para auditar telemetría histórica |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/invalid-bucket-interval",
  "title": "Invalid Aggregation Interval",
  "status": 400,
  "detail": "El intervalo temporal especificado en el parámetro bucket no es válido para TimescaleDB",
  "instance": "/api/v1/iot/telemetry/vehicle/018f6c40-7e12-7000-8000-000000000601/history",
  "code": "ERR_INVALID_BUCKET_INTERVAL",
  "timestamp": "2026-10-04T02:40:00Z"
}
```

---

## 6. Endpoints de VehicleFaultsController

El controlador `VehicleFaultsController` administra el ciclo de vida de las averías electrónicas y códigos de diagnóstico de falla (DTC) decodificados desde el puerto OBD-II del vehículo.

### 6.1. [POST] /api/v1/iot/faults

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.iot.interfaces.rest.controllers.VehicleFaultsController`
* **Método Java:** `public ResponseEntity<VehicleFaultResponse> registerVehicleFault(@Valid @RequestBody RegisterVehicleFaultRequest request, @AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/iot/faults`
* **Ruta Completa:** `/api/v1/iot/faults`
* **Propósito:** Asienta un código de falla DTC detectado por el escáner durante el escaneo computarizado del vehículo.

#### Descripción Funcional
Registra un código de diagnóstico de falla detectado en los módulos de control electrónico del vehículo (ECU, TCU, ABS). Valida que el formato del código cumpla la norma internacional SAE J2012 (letra P, B, C o U seguida de 4 dígitos hexadecimales). Asocia la severidad técnica preliminar, persiste la avería en estado no resuelto (`isResolved = false`) y dispara el análisis pericial del motor de diagnóstico predictivo para evaluar riesgos mecánicos colaterales.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Mecánico (`ROLE_MECHANIC`), Jefe de Taller (`ROLE_HEAD_MECHANIC`) o Dueño de Taller (`ROLE_WORKSHOP_OWNER`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:faults:write')")`
* **Aislamiento Multi-Inquilino:** El vehículo debe pertenecer al taller autenticado.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
* **Parámetros de Ruta (Path Parameters):** No aplica.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
* **Registro Java DTO:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.requests.RegisterVehicleFaultRequest`
* **Definición de Campos:**

| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `vehicleId` | `UUID` | Sí | `@NotNull` | Identificador único del vehículo con avería |
| `dtcCode` | `String` | Sí | `@NotBlank, @Pattern(regexp = "^[PBUC][0-9A-Fa-f]{4}$")` | Código DTC estándar SAE J2012 (ej. P0300) |
| `severity` | `String` | Sí | `@NotBlank, @Pattern(regexp = "^(MINOR\|MODERATE\|CRITICAL)$")` | Nivel de severidad técnica del fallo |
| `description` | `String` | No | Sin restricción adicional | Glosa técnica o descripción del componente afectado |

**Ejemplo de Carga Útil JSON (Request):**
```json
{
  "vehicleId": "018f6c40-7e12-7000-8000-000000000601",
  "dtcCode": "P0300",
  "severity": "CRITICAL",
  "description": "Fallo de encendido detectado en múltiples cilindros del motor"
}
```

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `201 Created` con cabecera `Location: /api/v1/iot/faults/{id}`
* **Registro Java DTO:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.VehicleFaultResponse`
* **Definición de Campos Proyectados:**

| Campo | Tipo de Dato | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador único del registro de avería |
| `vehicleId` | `UUID` | Identificador del vehículo afectado |
| `dtcCode` | `String` | Código DTC normalizado |
| `severity` | `String` | Nivel de severidad técnica clasificado |
| `description` | `String` | Explicación del fallo mecánico detectado |
| `detectedAt` | `Instant` | Marca temporal de captura en formato ISO 8601 UTC |
| `isResolved` | `boolean` | Indica si la falla fue solucionada |
| `resolvedAt` | `Instant` | Marca temporal de solución (null mientras esté activa) |

**Ejemplo de Carga Útil JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000801",
  "vehicleId": "018f6c40-7e12-7000-8000-000000000601",
  "dtcCode": "P0300",
  "severity": "CRITICAL",
  "description": "Fallo de encendido detectado en múltiples cilindros del motor",
  "detectedAt": "2026-10-04T02:45:00Z",
  "isResolved": false,
  "resolvedAt": null
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `InvalidDtcCodeException` | El código DTC no se ajusta al formato estándar SAE J2012 |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| `403 Forbidden` | `AccessDeniedException` | Permisos insuficientes para registrar fallas de diagnóstico |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/invalid-dtc-code",
  "title": "Invalid DTC Format",
  "status": 400,
  "detail": "El código DTC proporcionado no cumple con el estándar SAE J2012 de 5 caracteres alfanuméricos",
  "instance": "/api/v1/iot/faults",
  "code": "ERR_INVALID_DTC_CODE",
  "timestamp": "2026-10-04T02:45:00Z"
}
```

---

### 6.2. [GET] /api/v1/iot/faults/vehicle/{vehicleId}/active

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.iot.interfaces.rest.controllers.VehicleFaultsController`
* **Método Java:** `public ResponseEntity<List<VehicleFaultResponse>> getActiveFaultsByVehicle(@PathVariable UUID vehicleId, @AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/iot/faults`
* **Ruta Completa:** `/api/v1/iot/faults/vehicle/{vehicleId}/active`
* **Propósito:** Lista todas las averías electrónicas activas (no subsanadas) registradas para un vehículo específico.

#### Descripción Funcional
Permite a los mecánicos y asesores de servicio revisar el expediente de anomalías activas antes de iniciar reparaciones o durante la inspección de recepción. Consulta la tabla `vehicle_faults` filtrando por `vehicleId` y la condición `isResolved = false`. Proyecta cada avería con su código, nivel de severidad y marca temporal de captura original.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Asesor de Servicio (`ROLE_SERVICE_ADVISOR`), Mecánico (`ROLE_MECHANIC`) o Jefe de Taller (`ROLE_HEAD_MECHANIC`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:faults:read')")`
* **Aislamiento Multi-Inquilino:** Comprobación estricta de pertenencia del vehículo al `tenant_id` autenticado.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Accept: application/json`
* **Parámetros de Ruta (Path Parameters):**
  * `vehicleId` (`UUID`): Identificador universal del vehículo a consultar.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
No aplica (Solicitud de tipo HTTP GET sin cuerpo).

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `200 OK`
* **Registro Java DTO:** `List<com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.VehicleFaultResponse>`
* **Definición de Campos Proyectados:** Idéntica a la definición de `VehicleFaultResponse`.

**Ejemplo de Carga Útil JSON (Response):**
```json
[
  {
    "id": "018f6c40-7e12-7000-8000-000000000801",
    "vehicleId": "018f6c40-7e12-7000-8000-000000000601",
    "dtcCode": "P0300",
    "severity": "CRITICAL",
    "description": "Fallo de encendido detectado en múltiples cilindros del motor",
    "detectedAt": "2026-10-04T02:45:00Z",
    "isResolved": false,
    "resolvedAt": null
  },
  {
    "id": "018f6c40-7e12-7000-8000-000000000802",
    "vehicleId": "018f6c40-7e12-7000-8000-000000000601",
    "dtcCode": "P0171",
    "severity": "MODERATE",
    "description": "Mezcla demasiado pobre en banco 1 de inyección",
    "detectedAt": "2026-10-04T02:46:12Z",
    "isResolved": false,
    "resolvedAt": null
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentTypeMismatchException` | Formato UUID del vehículo malformado |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o expirado |
| `403 Forbidden` | `AccessDeniedException` | Permisos insuficientes para auditar fallas del vehículo |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/access-denied",
  "title": "Access Denied",
  "status": 403,
  "detail": "El usuario no cuenta con privilegios para consultar el expediente de fallas de este vehículo",
  "instance": "/api/v1/iot/faults/vehicle/018f6c40-7e12-7000-8000-000000000601/active",
  "code": "ERR_ACCESS_DENIED",
  "timestamp": "2026-10-04T02:50:00Z"
}
```

---

### 6.3. [POST] /api/v1/iot/faults/{id}/resolve

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.iot.interfaces.rest.controllers.VehicleFaultsController`
* **Método Java:** `public ResponseEntity<VehicleFaultResponse> resolveVehicleFault(@PathVariable UUID id, @AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/iot/faults`
* **Ruta Completa:** `/api/v1/iot/faults/{id}/resolve`
* **Propósito:** Marca una avería electrónica como subsanada tras la ejecución efectiva de reparaciones mecánicas y borrado de código con escáner.

#### Descripción Funcional
Permite a los mecánicos cerrar formalmente un código de falla tras sustituir bujías, sensores o componentes defectuosos. Valida que la avería exista y no haya sido subsanada con anterioridad. Actualiza el estado a resuelto (`isResolved = true`), fija la marca temporal de resolución (`resolvedAt`) y emite el evento `VehicleFaultResolvedEvent` para recalcular la puntuación de salud de la unidad.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Mecánico (`ROLE_MECHANIC`), Jefe de Taller (`ROLE_HEAD_MECHANIC`) o Dueño de Taller (`ROLE_WORKSHOP_OWNER`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:faults:resolve')")`
* **Aislamiento Multi-Inquilino:** La avería debe pertenecer al `tenant_id` del taller autenticado.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Accept: application/json`
* **Parámetros de Ruta (Path Parameters):**
  * `id` (`UUID`): Identificador universal de la avería a subsanar.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
No aplica (Solicitud de tipo HTTP POST sin cuerpo).

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `200 OK`
* **Registro Java DTO:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.VehicleFaultResponse`
* **Definición de Campos Proyectados:** Idéntica a la definición de `VehicleFaultResponse` con `isResolved = true` y `resolvedAt` presente.

**Ejemplo de Carga Útil JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000801",
  "vehicleId": "018f6c40-7e12-7000-8000-000000000601",
  "dtcCode": "P0300",
  "severity": "CRITICAL",
  "description": "Fallo de encendido detectado en múltiples cilindros del motor",
  "detectedAt": "2026-10-04T02:45:00Z",
  "isResolved": true,
  "resolvedAt": "2026-10-04T02:55:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentTypeMismatchException` | Identificador de falla con formato UUID no válido |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| `403 Forbidden` | `AccessDeniedException` | Permisos insuficientes para subsanar averías |
| `404 Not Found` | `VehicleFaultNotFoundException` | La avería especificada no fue localizada en el sistema |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/fault-not-found",
  "title": "Vehicle Fault Not Found",
  "status": 404,
  "detail": "La avería con identificador 018f6c40-7e12-7000-8000-000000000899 no existe en el registro",
  "instance": "/api/v1/iot/faults/018f6c40-7e12-7000-8000-000000000899/resolve",
  "code": "ERR_FAULT_NOT_FOUND",
  "timestamp": "2026-10-04T02:55:00Z"
}
```

---

## 7. Endpoints de PredictiveAlertsController

El controlador `PredictiveAlertsController` gestiona las alertas proactivas emitidas por los algoritmos de detección de anomalías y provee la conversión directa de alertas técnicas en citas preventivas del taller.

### 7.1. [GET] /api/v1/iot/alerts/tenant

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.iot.interfaces.rest.controllers.PredictiveAlertsController`
* **Método Java:** `public ResponseEntity<List<PredictiveAlertResponse>> getActiveAlertsForTenant(@AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/iot/alerts`
* **Ruta Completa:** `/api/v1/iot/alerts/tenant`
* **Propósito:** Retorna el tablero consolidado de alertas predictivas activas y no reconocidas de todos los vehículos atendidos por el taller.

#### Descripción Funcional
Provee al jefe de taller y asesores comerciales un panorama de oportunidades de servicio preventivo y riesgos mecánicos inminentes. Consulta la tabla `predictive_alerts` filtrando por el `tenant_id` autenticado y estado pendiente (`status = PENDING`), ordenadas de manera descendente por nivel de confianza estadística (`confidenceScore`). Cada alerta incluye una recomendación de servicio correctivo o preventivo.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Asesor de Servicio (`ROLE_SERVICE_ADVISOR`), Jefe de Taller (`ROLE_HEAD_MECHANIC`) o Dueño de Taller (`ROLE_WORKSHOP_OWNER`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:alerts:read')")`
* **Aislamiento Multi-Inquilino:** Filtrado estricto por el `tenant_id` del taller solicitante.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Accept: application/json`
* **Parámetros de Ruta (Path Parameters):** No aplica.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
No aplica (Solicitud de tipo HTTP GET sin cuerpo).

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `200 OK`
* **Registro Java DTO:** `List<com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.PredictiveAlertResponse>`
* **Definición de Campos Proyectados:**

| Campo | Tipo de Dato | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador único de la alerta predictiva |
| `vehicleId` | `UUID` | Identificador del vehículo que experimenta la anomalía |
| `recommendedServiceId` | `UUID` | Identificador del servicio del catálogo sugerido (ej. afinamiento) |
| `alertType` | `String` | Categoría técnica de la alerta (THERMAL_ANOMALY, VOLTAGE_DROP, MISFIRE_RISK) |
| `confidenceScore` | `BigDecimal` | Puntuación de certeza estadística entre 0.00 y 1.00 |
| `message` | `String` | Texto explicativo con diagnóstico preventivo sugerido |
| `status` | `String` | Estado operativo (PENDING, ACKNOWLEDGED, RESOLVED, DISMISSED) |
| `createdAt` | `Instant` | Marca temporal de generación en formato ISO 8601 UTC |

**Ejemplo de Carga Útil JSON (Response):**
```json
[
  {
    "id": "018f6c40-7e12-7000-8000-000000000901",
    "vehicleId": "018f6c40-7e12-7000-8000-000000000601",
    "recommendedServiceId": "018f6c40-7e12-7000-8000-000000000950",
    "alertType": "THERMAL_ANOMALY",
    "confidenceScore": 0.94,
    "message": "Temperatura de refrigerante supera 105C bajo régimen moderado. Riesgo inminente de sobrecalentamiento de culata",
    "status": "PENDING",
    "createdAt": "2026-10-04T02:32:00Z"
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| `403 Forbidden` | `AccessDeniedException` | Permisos insuficientes para acceder al tablero de alertas |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/access-denied",
  "title": "Access Denied",
  "status": 403,
  "detail": "El usuario no dispone de privilegios para auditar el tablero de alertas predictivas del taller",
  "instance": "/api/v1/iot/alerts/tenant",
  "code": "ERR_ACCESS_DENIED",
  "timestamp": "2026-10-04T02:40:00Z"
}
```

---

### 7.2. [GET] /api/v1/iot/alerts/vehicle/{vehicleId}

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.iot.interfaces.rest.controllers.PredictiveAlertsController`
* **Método Java:** `public ResponseEntity<List<PredictiveAlertResponse>> getAlertsByVehicle(@PathVariable UUID vehicleId, @AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/iot/alerts`
* **Ruta Completa:** `/api/v1/iot/alerts/vehicle/{vehicleId}`
* **Propósito:** Consulta el historial completo de alertas predictivas emitidas para un vehículo específico.

#### Descripción Funcional
Permite a los asesores técnicos examinar la evolución histórica de riesgos de un automóvil. Recupera todas las alertas generadas históricamente para el vehículo especificado, sin importar si su estado es pendiente, reconocida o subsanada, ordenadas cronológicamente de forma descendente.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Asesor de Servicio (`ROLE_SERVICE_ADVISOR`), Jefe de Taller (`ROLE_HEAD_MECHANIC`) o Dueño de Taller (`ROLE_WORKSHOP_OWNER`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:alerts:read')")`
* **Aislamiento Multi-Inquilino:** Comprobación estricta de pertenencia del vehículo al `tenant_id` autenticado.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Accept: application/json`
* **Parámetros de Ruta (Path Parameters):**
  * `vehicleId` (`UUID`): Identificador universal del vehículo consultado.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
No aplica (Solicitud de tipo HTTP GET sin cuerpo).

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `200 OK`
* **Registro Java DTO:** `List<com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.PredictiveAlertResponse>`
* **Definición de Campos Proyectados:** Idéntica a la definición de `PredictiveAlertResponse`.

**Ejemplo de Carga Útil JSON (Response):**
```json
[
  {
    "id": "018f6c40-7e12-7000-8000-000000000901",
    "vehicleId": "018f6c40-7e12-7000-8000-000000000601",
    "recommendedServiceId": "018f6c40-7e12-7000-8000-000000000950",
    "alertType": "THERMAL_ANOMALY",
    "confidenceScore": 0.94,
    "message": "Temperatura de refrigerante supera 105C bajo régimen moderado. Riesgo inminente de sobrecalentamiento de culata",
    "status": "PENDING",
    "createdAt": "2026-10-04T02:32:00Z"
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentTypeMismatchException` | Formato UUID del vehículo no válido |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| `403 Forbidden` | `AccessDeniedException` | Permisos insuficientes para auditar alertas del vehículo |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/access-denied",
  "title": "Access Denied",
  "status": 403,
  "detail": "El usuario no cuenta con autorización para examinar el historial del vehículo especificado",
  "instance": "/api/v1/iot/alerts/vehicle/018f6c40-7e12-7000-8000-000000000601",
  "code": "ERR_ACCESS_DENIED",
  "timestamp": "2026-10-04T02:45:00Z"
}
```

---

### 7.3. [PATCH] /api/v1/iot/alerts/{id}/acknowledge

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.iot.interfaces.rest.controllers.PredictiveAlertsController`
* **Método Java:** `public ResponseEntity<PredictiveAlertResponse> acknowledgeAlert(@PathVariable UUID id, @Valid @RequestBody AcknowledgeAlertRequest request, @AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/iot/alerts`
* **Ruta Completa:** `/api/v1/iot/alerts/{id}/acknowledge`
* **Propósito:** Marca una alerta predictiva como leída y evaluada por el personal técnico del taller.

#### Descripción Funcional
Permite a los asesores de servicio o jefes de taller registrar formalmente la toma de conocimiento de una alerta técnica. Cambia el estado a reconocido (`status = ACKNOWLEDGED`), registra el nombre del colaborador responsable y retira la alerta de los tableros de urgencias inmediatas.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Asesor de Servicio (`ROLE_SERVICE_ADVISOR`), Jefe de Taller (`ROLE_HEAD_MECHANIC`) o Dueño de Taller (`ROLE_WORKSHOP_OWNER`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:alerts:acknowledge')")`
* **Aislamiento Multi-Inquilino:** La alerta debe pertenecer al taller autenticado.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
* **Parámetros de Ruta (Path Parameters):**
  * `id` (`UUID`): Identificador universal de la alerta a reconocer.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
* **Registro Java DTO:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.requests.AcknowledgeAlertRequest`
* **Definición de Campos:**

| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `acknowledgedBy` | `String` | No | Sin restricción adicional | Nombre o identificador del colaborador que revisa la alerta |

**Ejemplo de Carga Útil JSON (Request):**
```json
{
  "acknowledgedBy": "Carlos Mendoza (Jefe de Taller)"
}
```

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `200 OK`
* **Registro Java DTO:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.PredictiveAlertResponse`
* **Definición de Campos Proyectados:** Idéntica a la definición de `PredictiveAlertResponse` con `status = ACKNOWLEDGED`.

**Ejemplo de Carga Útil JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000901",
  "vehicleId": "018f6c40-7e12-7000-8000-000000000601",
  "recommendedServiceId": "018f6c40-7e12-7000-8000-000000000950",
  "alertType": "THERMAL_ANOMALY",
  "confidenceScore": 0.94,
  "message": "Temperatura de refrigerante supera 105C bajo régimen moderado. Riesgo inminente de sobrecalentamiento de culata",
  "status": "ACKNOWLEDGED",
  "createdAt": "2026-10-04T02:32:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentTypeMismatchException` | Identificador de alerta con formato no válido |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o expirado |
| `403 Forbidden` | `AccessDeniedException` | Permisos insuficientes para reconocer alertas |
| `404 Not Found` | `PredictiveAlertNotFoundException` | La alerta especificada no existe en el taller |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/alert-not-found",
  "title": "Predictive Alert Not Found",
  "status": 404,
  "detail": "La alerta con identificador 018f6c40-7e12-7000-8000-000000000999 no existe en el registro",
  "instance": "/api/v1/iot/alerts/018f6c40-7e12-7000-8000-000000000999/acknowledge",
  "code": "ERR_ALERT_NOT_FOUND",
  "timestamp": "2026-10-04T02:50:00Z"
}
```

---

### 7.4. [POST] /api/v1/iot/alerts/{id}/convert-to-appointment

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.iot.interfaces.rest.controllers.PredictiveAlertsController`
* **Método Java:** `public ResponseEntity<AppointmentResponse> convertAlertToAppointment(@PathVariable UUID id, @AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/iot/alerts`
* **Ruta Completa:** `/api/v1/iot/alerts/{id}/convert-to-appointment`
* **Propósito:** Transforma una alerta predictiva en una cita de servicio preventivo en los módulos de CRM y operaciones del taller.

#### Descripción Funcional
Conecta la inteligencia predictiva telemática con la facturación y retención de clientes. Recupera la alerta predictiva, resuelve el vehículo y su cliente propietario registrado en CRM, y delega a través del puerto de salida desacoplado `CrmFleetAclPort` la creación de una cita preventiva (`Appointment`) pre-llenada con el servicio recomendado y notas periciales. Marca la alerta técnica como resuelta (`status = RESOLVED`) y retorna el identificador de la cita agendada.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Asesor de Servicio (`ROLE_SERVICE_ADVISOR`) o Dueño de Taller (`ROLE_WORKSHOP_OWNER`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:alerts:convert')")`
* **Aislamiento Multi-Inquilino:** La alerta y la cita se confinan estrictamente al `tenant_id` autenticado.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Accept: application/json`
* **Parámetros de Ruta (Path Parameters):**
  * `id` (`UUID`): Identificador universal de la alerta que se desea convertir.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
No aplica (Solicitud de tipo HTTP POST sin cuerpo).

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `200 OK`
* **Registro Java DTO:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.AppointmentResponse`
* **Definición de Campos Proyectados:**

| Campo | Tipo de Dato | Descripción |
| :--- | :--- | :--- |
| `appointmentId` | `UUID` | Identificador único de la cita agendada en CRM |
| `vehicleId` | `UUID` | Identificador del vehículo agendado |
| `customerId` | `UUID` | Identificador del cliente propietario en CRM |
| `scheduledAt` | `Instant` | Fecha y hora tentativa propuesta para la cita |
| `status` | `String` | Estado de la cita (SCHEDULED) |
| `notes` | `String` | Resumen técnico derivado de la alerta predictiva |

**Ejemplo de Carga Útil JSON (Response):**
```json
{
  "appointmentId": "018f6c40-7e12-7000-8000-000000000980",
  "vehicleId": "018f6c40-7e12-7000-8000-000000000601",
  "customerId": "018f6c40-7e12-7000-8000-000000000990",
  "scheduledAt": "2026-10-06T14:00:00Z",
  "status": "SCHEDULED",
  "notes": "Cita generada automáticamente desde alerta de anomalía térmica P0300"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentTypeMismatchException` | Formato UUID no válido |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o expirado |
| `403 Forbidden` | `AccessDeniedException` | Permisos insuficientes para agendar citas |
| `404 Not Found` | `PredictiveAlertNotFoundException` | La alerta especificada no existe en el sistema |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/alert-not-found",
  "title": "Predictive Alert Not Found",
  "status": 404,
  "detail": "No se puede convertir la alerta porque no fue encontrada en la base de datos",
  "instance": "/api/v1/iot/alerts/018f6c40-7e12-7000-8000-000000000999/convert-to-appointment",
  "code": "ERR_ALERT_NOT_FOUND",
  "timestamp": "2026-10-04T02:55:00Z"
}
```

---

## 8. Endpoints de VehicleHealthReportsController

El controlador `VehicleHealthReportsController` orquesta el motor pericial de diagnóstico vehicular asistido por Inteligencia Artificial (Spring AI con Groq Cloud LPU), la consolidación analítica de reportes de salud mecánica y la exportación de comprobantes periciales en formato binario PDF.

### 8.1. [POST] /api/v1/iot/health-reports/generate

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.iot.interfaces.rest.controllers.VehicleHealthReportsController`
* **Método Java:** `public ResponseEntity<HealthReportCreatedResponse> generateHealthReport(@RequestParam UUID vehicleId, @Valid @RequestBody GenerateHealthReportRequest request, @AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/iot/health-reports`
* **Ruta Completa:** `/api/v1/iot/health-reports/generate`
* **Propósito:** Ejecuta la evaluación analítica forense completa del vehículo con inferencia Spring AI Groq de manera síncrona.

#### Descripción Funcional
Comprueba la cuota operativa mensual del taller respecto al límite de reportes asistidos por IA (`maxMonthlyAiReports` del plan SaaS). Recupera el historial agregado de 30 días en TimescaleDB (`time_bucket`) y los códigos DTC activos de la unidad. Construye un prompt enriquecido con lenguaje ubicuo automotriz y consulta el modelo Groq LPU mediante structured output tipado. Recibe el dictamen pericial, computa el índice general de salud (0 a 100), persiste el informe en la tabla `vehicle_health_reports` y emite el evento `VehicleHealthReportGeneratedEvent`.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Asesor de Servicio (`ROLE_SERVICE_ADVISOR`), Jefe de Taller (`ROLE_HEAD_MECHANIC`) o Dueño de Taller (`ROLE_WORKSHOP_OWNER`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:health_reports:generate')")`
* **Aislamiento Multi-Inquilino:** El vehículo analizado debe pertenecer al taller autenticado.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
* **Parámetros de Ruta (Path Parameters):** No aplica.
* **Parámetros de Consulta (Query Parameters):**
  * `vehicleId` (`UUID`, Obligatorio): Identificador universal del vehículo que será evaluado.

#### Recurso de Petición (Request Body)
* **Registro Java DTO:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.requests.GenerateHealthReportRequest`
* **Definición de Campos:**

| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `daysToAnalyze` | `Integer` | No | `@Min(7), @Max(90)` | Ventana temporal de series telemétricas (por defecto 30 días) |
| `includeResolvedDtcHistory` | `Boolean` | No | Sin restricción adicional | Si se auditan códigos ya resueltos previamente (por defecto false) |
| `triggerReason` | `String` | No | Sin restricción adicional | Causa del reporte (ej. PRE_PURCHASE_INSPECTION o FLEET_AUDIT) |

**Ejemplo de Carga Útil JSON (Request):**
```json
{
  "daysToAnalyze": 30,
  "includeResolvedDtcHistory": false,
  "triggerReason": "PRE_PURCHASE_INSPECTION"
}
```

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `201 Created` con cabecera `Location: /api/v1/iot/health-reports/{reportId}`
* **Registro Java DTO:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.HealthReportCreatedResponse`
* **Definición de Campos Proyectados:**

| Campo | Tipo de Dato | Descripción |
| :--- | :--- | :--- |
| `reportId` | `UUID` | Identificador único del reporte pericial generado |
| `vehicleId` | `UUID` | Identificador del vehículo evaluado |
| `overallHealthScore` | `int` | Puntuación integral de salud mecánica en escala de 0 a 100 puntos |
| `executiveSummary` | `String` | Resumen ejecutivo generado por el modelo Groq LPU |
| `totalRisksDetected` | `int` | Cantidad de anomalías o riesgos mecánicos identificados |
| `generatedAt` | `Instant` | Marca temporal de emisión pericial en formato ISO 8601 UTC |
| `jsonResourceUrl` | `String` | Enlace para inspección de datos estructurados completos |
| `pdfDownloadUrl` | `String` | Enlace perimetral para la descarga del informe institucional en PDF |

**Ejemplo de Carga Útil JSON (Response):**
```json
{
  "reportId": "018f6c40-7e12-7000-8000-000000001001",
  "vehicleId": "018f6c40-7e12-7000-8000-000000000601",
  "overallHealthScore": 78,
  "executiveSummary": "Unidad con desgaste moderado en sistema de encendido. Código P0300 detectado con variaciones térmicas elevadas en tráfico lento.",
  "totalRisksDetected": 2,
  "generatedAt": "2026-10-04T02:50:00Z",
  "jsonResourceUrl": "/api/v1/iot/health-reports/018f6c40-7e12-7000-8000-000000001001",
  "pdfDownloadUrl": "/api/v1/iot/health-reports/018f6c40-7e12-7000-8000-000000001001/pdf"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Parámetros de días fuera de rango permitido (7 a 90) |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| `403 Forbidden` | `QuotaExceededException` | El taller excedió el cupo mensual de reportes con IA de su plan SaaS |
| `404 Not Found` | `VehicleNotFoundException` | El vehículo especificado no existe en la base de datos |
| `502 Bad Gateway` | `AiInferenceServiceUnavailableException` | Fallo de conexión o respuesta no estructurada desde Groq Cloud LPU |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/quota-exceeded",
  "title": "AI Diagnostics Quota Exceeded",
  "status": 403,
  "detail": "El taller ha alcanzado el límite mensual de 60 reportes de salud mecánica con IA permitidos por su plan Atelier Max",
  "instance": "/api/v1/iot/health-reports/generate",
  "code": "ERR_QUOTA_EXCEEDED",
  "timestamp": "2026-10-04T02:50:00Z"
}
```

---

### 8.2. [POST] /api/v1/iot/health-reports/generate-async

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.iot.interfaces.rest.controllers.VehicleHealthReportsController`
* **Método Java:** `public ResponseEntity<AsyncJobResponse> generateHealthReportAsync(@RequestParam UUID vehicleId, @Valid @RequestBody GenerateHealthReportRequest request, @AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/iot/health-reports`
* **Ruta Completa:** `/api/v1/iot/health-reports/generate-async`
* **Propósito:** Encola la generación pericial del informe de salud mecánica para procesamiento asíncrono en segundo plano.

#### Descripción Funcional
Diseñado para la evaluación de flotas corporativas masivas o escenarios donde el cliente no requiere esperar la inferencia síncrona en pantalla. Valida cuotas del taller, encola un trabajo de procesamiento en segundo plano con identificador único `jobId` y responde inmediatamente `202 Accepted` con el tiempo estimado de culminación. Al concluir el procesamiento asíncrono, se despacha una notificación push WebSocket o correo al solicitante.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Jefe de Taller (`ROLE_HEAD_MECHANIC`) o Dueño de Taller (`ROLE_WORKSHOP_OWNER`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:health_reports:generate')")`
* **Aislamiento Multi-Inquilino:** Verificación estricta de tenencia sobre el vehículo.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
* **Parámetros de Ruta (Path Parameters):** No aplica.
* **Parámetros de Consulta (Query Parameters):**
  * `vehicleId` (`UUID`, Obligatorio): Identificador universal del vehículo a evaluar.

#### Recurso de Petición (Request Body)
* **Registro Java DTO:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.requests.GenerateHealthReportRequest`
* **Definición de Campos:** Idéntica a la especificación de `GenerateHealthReportRequest`.

**Ejemplo de Carga Útil JSON (Request):**
```json
{
  "daysToAnalyze": 60,
  "includeResolvedDtcHistory": true,
  "triggerReason": "FLEET_PERIODIC_AUDIT"
}
```

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `202 Accepted`
* **Registro Java DTO:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.AsyncJobResponse`
* **Definición de Campos Proyectados:**

| Campo | Tipo de Dato | Descripción |
| :--- | :--- | :--- |
| `jobId` | `UUID` | Identificador único de la tarea encolada en segundo plano |
| `status` | `String` | Estado del trabajo (QUEUED, PROCESSING) |
| `vehicleId` | `UUID` | Identificador del vehículo vinculado |
| `submittedAt` | `Instant` | Marca temporal de recepción en formato ISO 8601 UTC |
| `estimatedCompletionTime` | `Instant` | Estimación proyectada de culminación del reporte |

**Ejemplo de Carga Útil JSON (Response):**
```json
{
  "jobId": "018f6c40-7e12-7000-8000-000000001050",
  "status": "QUEUED",
  "vehicleId": "018f6c40-7e12-7000-8000-000000000601",
  "submittedAt": "2026-10-04T02:55:00Z",
  "estimatedCompletionTime": "2026-10-04T02:55:15Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Parámetros inválidos en el cuerpo de la solicitud |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| `403 Forbidden` | `QuotaExceededException` | Cupo mensual de diagnósticos IA agotado en el taller |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/quota-exceeded",
  "title": "AI Diagnostics Quota Exceeded",
  "status": 403,
  "detail": "Cupo de procesamiento con inteligencia artificial agotado para el mes en curso",
  "instance": "/api/v1/iot/health-reports/generate-async",
  "code": "ERR_QUOTA_EXCEEDED",
  "timestamp": "2026-10-04T02:55:00Z"
}
```

---

### 8.3. [GET] /api/v1/iot/health-reports/latest

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.iot.interfaces.rest.controllers.VehicleHealthReportsController`
* **Método Java:** `public ResponseEntity<HealthReportCreatedResponse> getLatestHealthReport(@RequestParam UUID vehicleId, @AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/iot/health-reports`
* **Ruta Completa:** `/api/v1/iot/health-reports/latest`
* **Propósito:** Consulta el último informe pericial de salud mecánica calculado para un automóvil.

#### Descripción Funcional
Recupera el dictamen de salud más reciente emitido para el vehículo solicitado sin desencadenar una nueva inferencia en Groq Cloud, ahorrando cuotas y costos de procesamiento. Consulta el último informe ordenado descendentemente por fecha de generación, retornando la puntuación de salud, resumen ejecutivo y enlaces de descarga.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Mecánico (`ROLE_MECHANIC`), Asesor de Servicio (`ROLE_SERVICE_ADVISOR`) o Jefe de Taller (`ROLE_HEAD_MECHANIC`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:health_reports:read')")`
* **Aislamiento Multi-Inquilino:** Filtrado por vehículo perteneciente al taller autenticado.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Accept: application/json`
* **Parámetros de Ruta (Path Parameters):** No aplica.
* **Parámetros de Consulta (Query Parameters):**
  * `vehicleId` (`UUID`, Obligatorio): Identificador del vehículo consultado.

#### Recurso de Petición (Request Body)
No aplica (Solicitud de tipo HTTP GET sin cuerpo).

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `200 OK`
* **Registro Java DTO:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.HealthReportCreatedResponse`
* **Definición de Campos Proyectados:** Idéntica a la definición de `HealthReportCreatedResponse`.

**Ejemplo de Carga Útil JSON (Response):**
```json
{
  "reportId": "018f6c40-7e12-7000-8000-000000001001",
  "vehicleId": "018f6c40-7e12-7000-8000-000000000601",
  "overallHealthScore": 78,
  "executiveSummary": "Unidad con desgaste moderado en sistema de encendido. Código P0300 detectado con variaciones térmicas elevadas en tráfico lento.",
  "totalRisksDetected": 2,
  "generatedAt": "2026-10-04T02:50:00Z",
  "jsonResourceUrl": "/api/v1/iot/health-reports/018f6c40-7e12-7000-8000-000000001001",
  "pdfDownloadUrl": "/api/v1/iot/health-reports/018f6c40-7e12-7000-8000-000000001001/pdf"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentTypeMismatchException` | Formato UUID no válido |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| `403 Forbidden` | `AccessDeniedException` | Permisos insuficientes para consultar reportes |
| `404 Not Found` | `VehicleHealthReportNotFoundException` | No se encontraron reportes generados para el vehículo |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/health-report-not-found",
  "title": "Health Report Not Found",
  "status": 404,
  "detail": "El vehículo no cuenta con reportes periciales de salud mecánica previos en el sistema",
  "instance": "/api/v1/iot/health-reports/latest",
  "code": "ERR_HEALTH_REPORT_NOT_FOUND",
  "timestamp": "2026-10-04T02:55:00Z"
}
```

---

### 8.4. [GET] /api/v1/iot/health-reports/{reportId}/pdf

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.iot.interfaces.rest.controllers.VehicleHealthReportsController`
* **Método Java:** `public ResponseEntity<byte[]> downloadHealthReportPdf(@PathVariable UUID reportId, @AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/iot/health-reports`
* **Ruta Completa:** `/api/v1/iot/health-reports/{reportId}/pdf`
* **Propósito:** Genera y descarga el informe pericial institucional en formato binario PDF maquetado con OpenPDF.

#### Descripción Funcional
Recupera el informe de salud mecánica y compila los gráficos de telemetría, códigos DTC y recomendaciones periciales mediante el motor documental OpenPDF. Genera el documento estructurado incorporando la identidad gráfica institucional de Atelier y del taller mecánico, retornando el flujo binario con cabecera `Content-Type: application/pdf` y cabecera de disposición para descarga inmediata en el navegador del cliente o asesor.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Asesor de Servicio (`ROLE_SERVICE_ADVISOR`), Mecánico (`ROLE_MECHANIC`) o Jefe de Taller (`ROLE_HEAD_MECHANIC`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:health_reports:read')")`
* **Aislamiento Multi-Inquilino:** El informe debe pertenecer a un vehículo administrado por el taller autenticado.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Accept: application/pdf`
* **Parámetros de Ruta (Path Parameters):**
  * `reportId` (`UUID`): Identificador universal del reporte pericial.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
No aplica (Solicitud de tipo HTTP GET sin cuerpo).

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `200 OK`
* **Cabeceras de Respuesta Clave:**
  * `Content-Type: application/pdf`
  * Cabecera `Content-Disposition` con disposición attachment y nombre de archivo institucional
* **Formato del Cuerpo:** Flujo binario con el documento PDF oficial generado

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentTypeMismatchException` | Formato UUID del reporte no válido |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| `403 Forbidden` | `AccessDeniedException` | Permisos insuficientes para descargar reportes periciales |
| `404 Not Found` | `VehicleHealthReportNotFoundException` | El reporte solicitado no existe en la base de datos |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/health-report-not-found",
  "title": "Health Report Not Found",
  "status": 404,
  "detail": "El informe pericial con identificador 018f6c40-7e12-7000-8000-000000001099 no existe en el sistema",
  "instance": "/api/v1/iot/health-reports/018f6c40-7e12-7000-8000-000000001099/pdf",
  "code": "ERR_HEALTH_REPORT_NOT_FOUND",
  "timestamp": "2026-10-04T02:58:00Z"
}
```
