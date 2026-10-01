# Especificación Canónica de Endpoints: IoT Telemetry and Predictive Maintenance

## 1. Identidad y Propósito del Bounded Context

El Bounded Context **IoT Telemetry and Predictive Maintenance** (`com.andeva.atelier.platform.iot`) constituye el núcleo de innovación y diagnóstico avanzado de Atelier Platform. Transforma el taller automotriz convencional en un centro técnico predictivo mediante la captura masiva de telemetría vehicular en tiempo real, el aislamiento de series temporales en hipertablas de TimescaleDB, la detección de códigos de diagnóstico de falla (DTC) y la inferencia predictiva pericial asistida por modelos LPU de Groq con Spring AI.

Para el detalle de diseño estratégico, agregados y entidades de dominio, consultar:
* [09-iot-telemetry-and-predictive-maintenance.md](file:///home/shouy/development/atelier-report/docs/extended-description-bounded-contexts-backend/09-iot-telemetry-and-predictive-maintenance.md)
* [spring-ai-iot-predictive-diagnostics-guide.md](file:///home/shouy/development/atelier-report/docs/backend-documentation/spring-ai-iot-predictive-diagnostics-guide.md)
* [atelier-roles.md](file:///home/shouy/development/atelier-report/docs/backend-documentation/atelier-roles.md)
* [atelier-database-schema.md](file:///home/shouy/development/atelier-report/docs/atelier-database-schema.md)

### Principios Fundamentales del Módulo
1. **Aislamiento de Carga en TimescaleDB:** Las lecturas telemétricas de alta frecuencia (RPM, velocidad, temperatura del refrigerante y voltaje de batería) se insertan de forma directa en hipertablas append-only particionadas por intervalos de 7 días, previniendo cuellos de botella en el esquema transaccional del ERP.
2. **Ciclo de Vida de Escáneres e Instalaciones:** Soporte para adaptadores físicos OBD-II Bluetooth BLE y módems celulares SIM (BYOD o provistos por Andeva), gobernando el emparejamiento temporal con los vehículos en bahía y el registro de kilometraje pericial.
3. **Diagnóstico Electrónico Estandarizado:** Decodificación de códigos DTC SAE J1979/ISO 15031, clasificación por severidad (`LOW`, `MEDIUM`, `CRITICAL`) y trazabilidad de resolución tras borrado computarizado en bahía.
4. **Mantenimiento Predictivo con Spring AI:** Análisis termodinámico y correlación estadística de telemetría para predecir fallas catastróficas antes de su ocurrencia, generando alertas proactivas vinculadas a servicios recomendados del catálogo de MRO y despachando notificaciones push inmediatas mediante Firebase Cloud Messaging (FCM).

---

## 2. Inventario de Controladores y Endpoints

El módulo expone un total de 22 endpoints REST organizados en 6 controladores:

1. **Obd2DevicesController** (`/api/v1/iot/devices`): 4 endpoints para inventario de hardware y estados operativos de escáneres OBD-II.
2. **DeviceInstallationsController** (`/api/v1/iot/installations`): 4 endpoints para vinculación física, desinstalación e historial por vehículo.
3. **TelemetryIngestionController** (`/api/v1/iot/telemetry`): 3 endpoints para ingesta por lotes a alta velocidad y consulta de tacómetro en vivo y series temporales agregadas.
4. **VehicleFaultsController** (`/api/v1/iot/faults`): 3 endpoints para registro, listado y subsanación de códigos de falla DTC.
5. **PredictiveAlertsController** (`/api/v1/iot/alerts`): 4 endpoints para tablero de alertas predictivas de taller y vehículo, descarte y reconocimiento formal.
6. **VehicleHealthReportsController** (`/api/v1/iot/vehicles`): 4 endpoints para orquestación de reportes de salud mecánica, inferencia Groq LPU Spring AI y exportación PDF.

---

## 3. Especificación Detallada de Endpoints

### 3.1. Obd2DevicesController

Controlador encargado de la administración del inventario de adaptadores y escáneres telemáticos pertenecientes a la dotación del taller automotriz.

#### GET /api/v1/iot/devices

##### Identidad Técnica
* **Controlador:** `Obd2DevicesController` (`com.andeva.atelier.platform.iot.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<List<Obd2DeviceResponse>> getWorkshopDevices(@RequestParam(required = false) String status, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Lista todos los escáneres OBD-II físicos registrados en el inventario del taller automotriz autenticado, permitiendo filtrar por estado operativo (`ACTIVE`, `MAINTENANCE`, `DECOMMISSIONED`, `DEFECTIVE`).

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_WORKSHOP_ADMIN`, `ROLE_SERVICE_ADVISOR`, `ROLE_CHIEF_MECHANIC` o `ROLE_MECHANIC`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:devices:read')")`
* **Contexto Multi-Inquilino:** Aislamiento forzado mediante el claim `tenant_id` extraído del token JWT.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
* **Path Variables:** Ninguna.
* **Query Parameters:**
  | Parámetro | Tipo | Requerido | Descripción |
  | :--- | :--- | :--- | :--- |
  | `status` | String | No | Filtro opcional por situación del escáner (`ACTIVE`, `MAINTENANCE`, `DECOMMISSIONED`, `DEFECTIVE`). |

##### Request DTO
No aplica para peticiones HTTP GET.

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `List<com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.Obd2DeviceResponse>`

Tabla de Campos:
| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | UUID | Identificador unívoco del hardware en la plataforma Atelier. |
| `tenantId` | UUID | Identificador del taller propietario del dispositivo. |
| `deviceIdentifier` | String | Dirección MAC Bluetooth (ej. AA:BB:CC:11:22:33) o número IMEI celular. |
| `connectionType` | String | Protocolo de conectividad (`BLUETOOTH_BLE` o `CELLULAR_SIM`). |
| `status` | String | Estado operativo actual del dispositivo. |
| `hardwareModel` | String | Modelo comercial o fabricante del adaptador OBD-II (ej. ELM327 v2.1, OBDLink MX+). |
| `firmwareVersion` | String | Versión de firmware reportada por el escáner. |
| `createdAt` | Instant | Fecha y hora de alta en el sistema. |

Ejemplo JSON de Respuesta:
```json
[
  {
    "id": "8a123456-789a-bcde-f012-3456789abc01",
    "tenantId": "a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d",
    "deviceIdentifier": "00:1D:A5:68:98:8B",
    "connectionType": "BLUETOOTH_BLE",
    "status": "ACTIVE",
    "hardwareModel": "OBDLink MX+ Bluetooth",
    "firmwareVersion": "v5.6.1",
    "createdAt": "2026-02-10T10:00:00Z"
  },
  {
    "id": "8a123456-789a-bcde-f012-3456789abc02",
    "tenantId": "a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d",
    "deviceIdentifier": "864275039182745",
    "connectionType": "CELLULAR_SIM",
    "status": "MAINTENANCE",
    "hardwareModel": "Teltonika FMB003 4G",
    "firmwareVersion": "03.27.07",
    "createdAt": "2026-03-01T14:30:00Z"
  }
]
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión no provisto o expirado. |
| `403 Forbidden` | `https://api.atelier.andeva.pe/errors/forbidden` | `AccessDeniedException` | Usuario carece de permisos de lectura sobre el inventario telemático. |

---

#### GET /api/v1/iot/devices/{id}

##### Identidad Técnica
* **Controlador:** `Obd2DevicesController` (`com.andeva.atelier.platform.iot.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<Obd2DeviceResponse> getDeviceById(@PathVariable UUID id, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Consulta la ficha técnica detallada de un escáner OBD-II registrado en el taller a partir de su identificador UUID.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_WORKSHOP_ADMIN`, `ROLE_SERVICE_ADVISOR`, `ROLE_CHIEF_MECHANIC` o `ROLE_MECHANIC`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:devices:read')")`
* **Contexto Multi-Inquilino:** Valida que el dispositivo solicitado pertenezca al `tenant_id` autenticado.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
* **Path Variables:**
  | Variable | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `id` | UUID | Identificador unívoco del escáner en Atelier. |
* **Query Parameters:** Ninguno.

##### Request DTO
No aplica para peticiones HTTP GET.

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.Obd2DeviceResponse`

Ejemplo JSON de Respuesta:
```json
{
  "id": "8a123456-789a-bcde-f012-3456789abc01",
  "tenantId": "a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d",
  "deviceIdentifier": "00:1D:A5:68:98:8B",
  "connectionType": "BLUETOOTH_BLE",
  "status": "ACTIVE",
  "hardwareModel": "OBDLink MX+ Bluetooth",
  "firmwareVersion": "v5.6.1",
  "createdAt": "2026-02-10T10:00:00Z"
}
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `400 Bad Request` | `https://api.atelier.andeva.pe/errors/invalid-identifier` | `IllegalArgumentException` | Formato UUID del parámetro de ruta malformado. |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión inválido. |
| `403 Forbidden` | `https://api.atelier.andeva.pe/errors/forbidden` | `AccessDeniedException` | Intento de consultar un hardware asignado a otro taller. |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/device-not-found` | `DeviceNotFoundException` | El escáner solicitado no existe en la base de datos. |

---

#### POST /api/v1/iot/devices

##### Identidad Técnica
* **Controlador:** `Obd2DevicesController` (`com.andeva.atelier.platform.iot.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<Obd2DeviceResponse> registerDevice(@Valid @RequestBody RegisterDeviceRequest request, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Registra un nuevo adaptador OBD-II en el inventario del taller automotriz. Valida la disponibilidad de cuotas de hardware bajo el plan SaaS contratado (`maxActiveObd2Devices`) e impide el registro duplicado de direcciones MAC o números IMEI a nivel global.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_WORKSHOP_ADMIN` o `ROLE_CHIEF_MECHANIC`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:devices:register')")`
* **Contexto Multi-Inquilino:** Asocia automáticamente el registro al `tenant_id` del token JWT.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
  * `Content-Type: application/json` (Obligatorio)
* **Path Variables:** Ninguna.
* **Query Parameters:** Ninguno.

##### Request DTO
* **Record Java:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.requests.RegisterDeviceRequest`

Tabla de Campos:
| Campo | Tipo Java | Validaciones Jakarta | Descripción |
| :--- | :--- | :--- | :--- |
| `deviceIdentifier` | String | `@NotBlank` | Dirección MAC física Bluetooth o código IMEI celular. |
| `connectionType` | String | `@NotBlank`, patrón `BLUETOOTH_BLE\|CELLULAR_SIM` | Tipo de conectividad física del dispositivo. |
| `hardwareModel` | String | Opcional | Modelo comercial del adaptador telemático. |
| `firmwareVersion` | String | Opcional | Versión de firmware del fabricante. |

Ejemplo JSON de Solicitud:
```json
{
  "deviceIdentifier": "00:1D:A5:99:44:11",
  "connectionType": "BLUETOOTH_BLE",
  "hardwareModel": "Viecar Bluetooth 4.0 BLE",
  "firmwareVersion": "v1.5"
}
```

##### Response DTO
* **Estado HTTP:** `201 Created`
* **Headers:** `Location: /api/v1/iot/devices/{id}`
* **Record Java:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.Obd2DeviceResponse`

Ejemplo JSON de Respuesta:
```json
{
  "id": "9b234567-89ab-cdef-0123-456789abcdef",
  "tenantId": "a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d",
  "deviceIdentifier": "00:1D:A5:99:44:11",
  "connectionType": "BLUETOOTH_BLE",
  "status": "ACTIVE",
  "hardwareModel": "Viecar Bluetooth 4.0 BLE",
  "firmwareVersion": "v1.5",
  "createdAt": "2026-10-01T15:40:00Z"
}
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `400 Bad Request` | `https://api.atelier.andeva.pe/errors/validation-failed` | `MethodArgumentNotValidException` | Formato de identificador o tipo de conexión inválido. |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión ausente o revocado. |
| `403 Forbidden` | `https://api.atelier.andeva.pe/errors/quota-exceeded` | `QuotaExceededException` | El taller alcanzó el límite de escáneres activos permitido en su plan SaaS. |
| `409 Conflict` | `https://api.atelier.andeva.pe/errors/duplicate-device` | `DuplicateDeviceIdentifierException` | La dirección MAC o IMEI ya se encuentra registrada en la plataforma. |

Ejemplo JSON ProblemDetail:
```json
{
  "type": "https://api.atelier.andeva.pe/errors/quota-exceeded",
  "title": "Limite de Dispositivos Copado",
  "status": 403,
  "detail": "El Plan Pro autoriza un maximo de 5 escaneres OBD-II activos. Actualice al Plan Max para registrar mas dispositivos.",
  "instance": "/api/v1/iot/devices",
  "code": "OBD2_DEVICE_QUOTA_REACHED",
  "timestamp": "2026-10-01T15:40:30Z"
}
```

---

#### PATCH /api/v1/iot/devices/{id}/status

##### Identidad Técnica
* **Controlador:** `Obd2DevicesController` (`com.andeva.atelier.platform.iot.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<Obd2DeviceResponse> updateDeviceStatus(@PathVariable UUID id, @Valid @RequestBody UpdateDeviceStatusRequest request, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Actualiza la situación técnica u operativa de un escáner OBD-II (`ACTIVE`, `MAINTENANCE`, `DECOMMISSIONED`, `DEFECTIVE`), permitiendo bloquear temporalmente hardware averiado para evitar instalaciones espurias en bahía.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_WORKSHOP_ADMIN` o `ROLE_CHIEF_MECHANIC`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:devices:register')")`
* **Contexto Multi-Inquilino:** Verifica que el escáner pertenezca al taller autenticado.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
  * `Content-Type: application/json` (Obligatorio)
* **Path Variables:**
  | Variable | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `id` | UUID | Identificador unívoco del dispositivo a actualizar. |
* **Query Parameters:** Ninguno.

##### Request DTO
* **Record Java:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.requests.UpdateDeviceStatusRequest`

Tabla de Campos:
| Campo | Tipo Java | Validaciones Jakarta | Descripción |
| :--- | :--- | :--- | :--- |
| `status` | String | `@NotBlank`, patrón `ACTIVE\|MAINTENANCE\|DECOMMISSIONED\|DEFECTIVE` | Nuevo estado operativo del dispositivo. |

Ejemplo JSON de Solicitud:
```json
{
  "status": "MAINTENANCE"
}
```

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.Obd2DeviceResponse`

Ejemplo JSON de Respuesta:
```json
{
  "id": "8a123456-789a-bcde-f012-3456789abc01",
  "tenantId": "a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d",
  "deviceIdentifier": "00:1D:A5:68:98:8B",
  "connectionType": "BLUETOOTH_BLE",
  "status": "MAINTENANCE",
  "hardwareModel": "OBDLink MX+ Bluetooth",
  "firmwareVersion": "v5.6.1",
  "createdAt": "2026-02-10T10:00:00Z"
}
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `400 Bad Request` | `https://api.atelier.andeva.pe/errors/validation-failed` | `MethodArgumentNotValidException` | Estado operativo no reconocido en la enumeración de dominio. |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión ausente o revocado. |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/device-not-found` | `DeviceNotFoundException` | El dispositivo a modificar no existe en el inventario. |

---

### 3.2. DeviceInstallationsController

Controlador encargado de gestionar las vinculaciones físicas temporales entre escáneres OBD-II y vehículos atendidos en el taller.

#### POST /api/v1/iot/installations/install

##### Identidad Técnica
* **Controlador:** `DeviceInstallationsController` (`com.andeva.atelier.platform.iot.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<DeviceInstallationResponse> installDevice(@Valid @RequestBody InstallDeviceRequest request, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Asocia formalmente un escáner OBD-II disponible a un vehículo en bahía de trabajo, registrando el kilometraje inicial del odómetro y garantizando mediante invariantes de dominio que ni el vehículo ni el dispositivo posean otra instalación activa simultánea.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_WORKSHOP_ADMIN`, `ROLE_SERVICE_ADVISOR`, `ROLE_CHIEF_MECHANIC` o `ROLE_MECHANIC`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:installations:manage')")`
* **Contexto Multi-Inquilino:** Verifica que el escáner y el vehículo pertenezcan al mismo taller del token JWT.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
  * `Content-Type: application/json` (Obligatorio)
* **Path Variables:** Ninguna.
* **Query Parameters:** Ninguno.

##### Request DTO
* **Record Java:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.requests.InstallDeviceRequest`

Tabla de Campos:
| Campo | Tipo Java | Validaciones Jakarta | Descripción |
| :--- | :--- | :--- | :--- |
| `deviceId` | UUID | `@NotNull` | Identificador del escáner OBD-II a vincular. |
| `vehicleId` | UUID | `@NotNull` | Identificador del vehículo automotriz receptor. |
| `currentOdometerKm` | int | `@Min(0)` | Kilometraje actual asentado en el odómetro del tablero. |

Ejemplo JSON de Solicitud:
```json
{
  "deviceId": "8a123456-789a-bcde-f012-3456789abc01",
  "vehicleId": "4c56789a-bcde-f012-3456-789abcdef012",
  "currentOdometerKm": 68450
}
```

##### Response DTO
* **Estado HTTP:** `201 Created`
* **Headers:** `Location: /api/v1/iot/installations/{id}`
* **Record Java:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.DeviceInstallationResponse`

Tabla de Campos:
| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | UUID | Identificador universal único del registro de instalación. |
| `deviceId` | UUID | Identificador del escáner telemático asignado. |
| `vehicleId` | UUID | Identificador del vehículo vinculado. |
| `tenantId` | UUID | Identificador del taller automotriz. |
| `installedAt` | Instant | Fecha y hora formal de instalación en bahía. |
| `uninstalledAt` | Instant | Fecha de retiro (nulo mientras permanezca activa). |
| `initialOdometerKm` | int | Kilometraje registrado al momento de la conexión física. |
| `finalOdometerKm` | Integer | Kilometraje al retiro (nulo mientras permanezca activa). |
| `isActive` | boolean | Indicador booleano de vigencia activa de la vinculación. |

Ejemplo JSON de Respuesta:
```json
{
  "id": "1b345678-9abc-def0-1234-56789abcdef0",
  "deviceId": "8a123456-789a-bcde-f012-3456789abc01",
  "vehicleId": "4c56789a-bcde-f012-3456-789abcdef012",
  "tenantId": "a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d",
  "installedAt": "2026-10-01T15:42:00Z",
  "uninstalledAt": null,
  "initialOdometerKm": 68450,
  "finalOdometerKm": null,
  "isActive": true
}
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `400 Bad Request` | `https://api.atelier.andeva.pe/errors/validation-failed` | `MethodArgumentNotValidException` | Kilometraje negativo o identificadores UUID faltantes. |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión no provisto o inválido. |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/resource-not-found` | `DeviceNotFoundException` | El escáner o el vehículo especificado no existen. |
| `409 Conflict` | `https://api.atelier.andeva.pe/errors/active-installation-conflict` | `ActiveInstallationConflictException` | El vehículo ya cuenta con un escáner activo o el escáner ya está instalado en otro vehículo. |

Ejemplo JSON ProblemDetail:
```json
{
  "type": "https://api.atelier.andeva.pe/errors/active-installation-conflict",
  "title": "Conflicto de Instalacion Activa",
  "status": 409,
  "detail": "El escaner 8a123456-789a-bcde-f012-3456789abc01 ya se encuentra vinculado activamente a otro vehiculo.",
  "instance": "/api/v1/iot/installations/install",
  "code": "DEVICE_ALREADY_INSTALLED",
  "timestamp": "2026-10-01T15:42:30Z"
}
```

---

#### POST /api/v1/iot/installations/{id}/uninstall

##### Identidad Técnica
* **Controlador:** `DeviceInstallationsController` (`com.andeva.atelier.platform.iot.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<DeviceInstallationResponse> uninstallDevice(@PathVariable UUID id, @Valid @RequestBody UninstallDeviceRequest request, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Registra la desvinculación física de un escáner OBD-II de un vehículo, asentando el kilometraje final y liberando el dispositivo en el inventario para futuras operaciones.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_WORKSHOP_ADMIN`, `ROLE_SERVICE_ADVISOR`, `ROLE_CHIEF_MECHANIC` o `ROLE_MECHANIC`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:installations:manage')")`
* **Contexto Multi-Inquilino:** Verifica la pertenencia de la instalación al taller autenticado.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
  * `Content-Type: application/json` (Obligatorio)
* **Path Variables:**
  | Variable | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `id` | UUID | Identificador unívoco del registro de instalación a cerrar. |
* **Query Parameters:** Ninguno.

##### Request DTO
* **Record Java:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.requests.UninstallDeviceRequest`

Tabla de Campos:
| Campo | Tipo Java | Validaciones Jakarta | Descripción |
| :--- | :--- | :--- | :--- |
| `finalOdometerKm` | int | `@Min(0)` | Kilometraje final constatado en el odómetro al momento del retiro. |
| `uninstalledAt` | Instant | Opcional | Marca temporal de retiro físico (toma la hora del servidor si no se envía). |

Ejemplo JSON de Solicitud:
```json
{
  "finalOdometerKm": 68485,
  "uninstalledAt": "2026-10-01T17:30:00Z"
}
```

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.DeviceInstallationResponse`

Ejemplo JSON de Respuesta:
```json
{
  "id": "1b345678-9abc-def0-1234-56789abcdef0",
  "deviceId": "8a123456-789a-bcde-f012-3456789abc01",
  "vehicleId": "4c56789a-bcde-f012-3456-789abcdef012",
  "tenantId": "a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d",
  "installedAt": "2026-10-01T15:42:00Z",
  "uninstalledAt": "2026-10-01T17:30:00Z",
  "initialOdometerKm": 68450,
  "finalOdometerKm": 68485,
  "isActive": false
}
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `400 Bad Request` | `https://api.atelier.andeva.pe/errors/invalid-odometer` | `IllegalArgumentException` | El kilometraje final es menor al kilometraje inicial registrado en la instalación. |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión no provisto o inválido. |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/installation-not-found` | `InstallationNotFoundException` | La instalación especificada no existe en la base de datos. |
| `409 Conflict` | `https://api.atelier.andeva.pe/errors/installation-already-closed` | `IllegalStateException` | La instalación ya se encuentra cerrada y dada de baja previamente. |

---

#### GET /api/v1/iot/installations/vehicle/{vehicleId}/active

##### Identidad Técnica
* **Controlador:** `DeviceInstallationsController` (`com.andeva.atelier.platform.iot.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<DeviceInstallationResponse> getActiveInstallationByVehicle(@PathVariable UUID vehicleId, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Consulta la vinculación telemática actualmente activa de un vehículo, retornando los detalles del escáner enlazado, kilometraje de inicio y timestamp de conexión.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_WORKSHOP_ADMIN`, `ROLE_SERVICE_ADVISOR`, `ROLE_CHIEF_MECHANIC`, `ROLE_MECHANIC` o `ROLE_VEHICLE_OWNER`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:installations:manage') or hasAuthority('iot:devices:read')")`
* **Contexto Multi-Inquilino:** Verifica que el vehículo pertenezca al `tenant_id` autenticado.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
* **Path Variables:**
  | Variable | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `vehicleId` | UUID | Identificador universal del vehículo a consultar. |
* **Query Parameters:** Ninguno.

##### Request DTO
No aplica para peticiones HTTP GET.

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.DeviceInstallationResponse`

Ejemplo JSON de Respuesta:
```json
{
  "id": "1b345678-9abc-def0-1234-56789abcdef0",
  "deviceId": "8a123456-789a-bcde-f012-3456789abc01",
  "vehicleId": "4c56789a-bcde-f012-3456-789abcdef012",
  "tenantId": "a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d",
  "installedAt": "2026-10-01T15:42:00Z",
  "uninstalledAt": null,
  "initialOdometerKm": 68450,
  "finalOdometerKm": null,
  "isActive": true
}
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión ausente o vencido. |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/active-installation-not-found` | `InstallationNotFoundException` | El vehículo no tiene ningún escáner vinculado activamente. |

---

#### GET /api/v1/iot/installations/vehicle/{vehicleId}/history

##### Identidad Técnica
* **Controlador:** `DeviceInstallationsController` (`com.andeva.atelier.platform.iot.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<List<DeviceInstallationResponse>> getInstallationHistoryByVehicle(@PathVariable UUID vehicleId, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Consulta la bitácora cronológica histórica de todas las instalaciones y desinstalaciones de escáneres efectuadas sobre un vehículo a lo largo de su ciclo de servicio en el taller.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_WORKSHOP_ADMIN`, `ROLE_SERVICE_ADVISOR`, `ROLE_CHIEF_MECHANIC` o `ROLE_MECHANIC`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:installations:manage') or hasAuthority('iot:devices:read')")`
* **Contexto Multi-Inquilino:** Filtrado forzado por `tenant_id` y `vehicle_id`.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
* **Path Variables:**
  | Variable | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `vehicleId` | UUID | Identificador universal del vehículo. |
* **Query Parameters:** Ninguno.

##### Request DTO
No aplica para peticiones HTTP GET.

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `List<com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.DeviceInstallationResponse>`

Ejemplo JSON de Respuesta:
```json
[
  {
    "id": "1b345678-9abc-def0-1234-56789abcdef0",
    "deviceId": "8a123456-789a-bcde-f012-3456789abc01",
    "vehicleId": "4c56789a-bcde-f012-3456-789abcdef012",
    "tenantId": "a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d",
    "installedAt": "2026-10-01T15:42:00Z",
    "uninstalledAt": "2026-10-01T17:30:00Z",
    "initialOdometerKm": 68450,
    "finalOdometerKm": 68485,
    "isActive": false
  },
  {
    "id": "2c456789-0bcd-ef01-2345-6789abcdef01",
    "deviceId": "8a123456-789a-bcde-f012-3456789abc02",
    "vehicleId": "4c56789a-bcde-f012-3456-789abcdef012",
    "tenantId": "a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d",
    "installedAt": "2026-08-15T09:00:00Z",
    "uninstalledAt": "2026-08-15T12:15:00Z",
    "initialOdometerKm": 65120,
    "finalOdometerKm": 65135,
    "isActive": false
  }
]
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión ausente o revocado. |
| `403 Forbidden` | `https://api.atelier.andeva.pe/errors/forbidden` | `AccessDeniedException` | Acceso denegado a vehículos de otra empresa o taller. |

---

### 3.3. TelemetryIngestionController

Controlador de alta concurrencia encargado de la ingesta masiva por ráfagas hacia hipertablas TimescaleDB, lectura instantánea del tacómetro en vivo y agregación temporal de parámetros.

#### POST /api/v1/iot/telemetry/batch

##### Identidad Técnica
* **Controlador:** `TelemetryIngestionController` (`com.andeva.atelier.platform.iot.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<TelemetryIngestionAckResponse> ingestTelemetryBatch(@Valid @RequestBody TelemetryBatchRequest request, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Ingesta un paquete por lotes de lecturas telemétricas generadas por escáneres OBD-II y retransmitidas por la app móvil en foso (`Gateway BLE`) o módems celulares SIM. Ejecuta persistencia JDBC en bloque sobre la hipertabla `telemetry_logs` de TimescaleDB y dispara de forma asíncrona la evaluación termodinámica del motor analítico de anomalías.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_MECHANIC` o dispositivo de telemetría autenticado vía credenciales M2M.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:telemetry:ingest')")`
* **Contexto Multi-Inquilino:** El `tenant_id` se resuelve a partir del contexto del operador autenticado o de la instalación activa del vehículo en el taller.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
  * `Content-Type: application/json` (Obligatorio)
* **Path Variables:** Ninguna.
* **Query Parameters:** Ninguno.

##### Request DTO
* **Record Java:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.requests.TelemetryBatchRequest`

Tabla de Campos de `TelemetryBatchRequest`:
| Campo | Tipo Java | Validaciones Jakarta | Descripción |
| :--- | :--- | :--- | :--- |
| `vehicleId` | UUID | `@NotNull` | Identificador del vehículo automotriz emisor de la telemetría. |
| `readings` | List<TelemetryReadingItemDto> | `@NotEmpty`, `@Valid` | Colección cronológica de lecturas de sensores PIDs capturadas. |

Tabla de Campos de `TelemetryReadingItemDto`:
| Campo | Tipo Java | Validaciones Jakarta | Descripción |
| :--- | :--- | :--- | :--- |
| `timestamp` | Instant | `@NotNull` | Marca temporal exacta de la medición en el computador de abordo. |
| `latitude` | Double | Opcional | Coordenada geográfica de latitud WGS84 del vehículo. |
| `longitude` | Double | Opcional | Coordenada geográfica de longitud WGS84 del vehículo. |
| `speedKmh` | int | `@Min(0)` | Velocidad instantánea en kilómetros por hora. |
| `engineTempCelsius`| Double | `@NotNull` | Temperatura del líquido refrigerante del motor en grados Celsius. |
| `engineRpm` | int | `@Min(0)` | Régimen de giro del cigüeñal en revoluciones por minuto. |
| `fuelPercentage` | Double | Opcional | Nivel de combustible restante (0.0 a 100.0 por ciento). |
| `batteryVoltage` | Double | Opcional | Tensión eléctrica en bornes de batería automotriz (Voltios). |

Ejemplo JSON de Solicitud:
```json
{
  "vehicleId": "4c56789a-bcde-f012-3456-789abcdef012",
  "readings": [
    {
      "timestamp": "2026-10-01T15:45:00Z",
      "latitude": -12.0864,
      "longitude": -77.0345,
      "speedKmh": 45,
      "engineTempCelsius": 92.5,
      "engineRpm": 2150,
      "fuelPercentage": 65.0,
      "batteryVoltage": 13.8
    },
    {
      "timestamp": "2026-10-01T15:45:05Z",
      "latitude": -12.0869,
      "longitude": -77.0349,
      "speedKmh": 52,
      "engineTempCelsius": 93.0,
      "engineRpm": 2400,
      "fuelPercentage": 64.9,
      "batteryVoltage": 13.9
    }
  ]
}
```

##### Response DTO
* **Estado HTTP:** `202 Accepted`
* **Record Java:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.TelemetryIngestionAckResponse`

Tabla de Campos:
| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `vehicleId` | UUID | Identificador del vehículo cuyas lecturas fueron recibidas. |
| `ingestedCount` | int | Cantidad total de registros validados e insertados en TimescaleDB. |
| `anomalyDetected` | boolean | Indicador booleano si la evaluación preliminar detectó anomalías térmicas o eléctricas. |
| `alertMessage` | String | Mensaje diagnóstico preliminar o nulo si los parámetros son nominales. |

Ejemplo JSON de Respuesta:
```json
{
  "vehicleId": "4c56789a-bcde-f012-3456-789abcdef012",
  "ingestedCount": 2,
  "anomalyDetected": false,
  "alertMessage": null
}
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `400 Bad Request` | `https://api.atelier.andeva.pe/errors/validation-failed` | `MethodArgumentNotValidException` | Lista de lecturas vacía o datos con timestamps futuros irreales. |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión no provisto o inválido. |
| `403 Forbidden` | `https://api.atelier.andeva.pe/errors/quota-exceeded` | `QuotaExceededException` | El plan SaaS no incluye el módulo de telemetría IoT activa (Plan Go). |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/vehicle-not-found` | `VehicleNotFoundException` | El vehículo para el cual se envía telemetría no existe. |
| `500 Internal Server Error` | `https://api.atelier.andeva.pe/errors/timescale-error` | `TimescaleIngestionException` | Falla en el buffer pool JDBC de inserción a TimescaleDB. |

---

#### GET /api/v1/iot/telemetry/vehicle/{vehicleId}/latest

##### Identidad Técnica
* **Controlador:** `TelemetryIngestionController` (`com.andeva.atelier.platform.iot.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<VehicleLatestTelemetryResponse> getLatestTelemetryByVehicle(@PathVariable UUID vehicleId, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Consulta la última medición telemétrica válida registrada para el vehículo, permitiendo alimentar tacómetros digitales interactivos, monitores de temperatura del refrigerante y gráficos de estado de batería en tiempo real.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_WORKSHOP_ADMIN`, `ROLE_SERVICE_ADVISOR`, `ROLE_CHIEF_MECHANIC`, `ROLE_MECHANIC` o `ROLE_VEHICLE_OWNER`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:telemetry:read')")`
* **Contexto Multi-Inquilino:** Verifica que el vehículo pertenezca a la flota del taller o sea conducido por el usuario autenticado.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
* **Path Variables:**
  | Variable | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `vehicleId` | UUID | Identificador universal del vehículo automotriz. |
* **Query Parameters:** Ninguno.

##### Request DTO
No aplica para peticiones HTTP GET.

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.VehicleLatestTelemetryResponse`

Tabla de Campos:
| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `vehicleId` | UUID | Identificador universal del vehículo. |
| `timestamp` | Instant | Marca temporal de la última lectura asentada en la base de datos. |
| `latitude` | Double | Última latitud registrada. |
| `longitude` | Double | Última longitud registrada. |
| `speedKmh` | int | Velocidad instantánea en km/h. |
| `engineTempCelsius`| double | Temperatura de refrigerante en grados Celsius. |
| `engineRpm` | int | Revoluciones por minuto del motor. |
| `batteryVoltage` | Double | Voltaje en bornes de batería. |
| `fuelPercentage` | Double | Porcentaje de combustible disponible. |

Ejemplo JSON de Respuesta:
```json
{
  "vehicleId": "4c56789a-bcde-f012-3456-789abcdef012",
  "timestamp": "2026-10-01T15:45:05Z",
  "latitude": -12.0869,
  "longitude": -77.0349,
  "speedKmh": 52,
  "engineTempCelsius": 93.0,
  "engineRpm": 2400,
  "batteryVoltage": 13.9,
  "fuelPercentage": 64.9
}
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión ausente o vencido. |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/telemetry-not-found` | `TelemetryNotFoundException` | El vehículo aún no cuenta con ningún registro telemétrico en la hipertabla. |

---

#### GET /api/v1/iot/telemetry/vehicle/{vehicleId}/range

##### Identidad Técnica
* **Controlador:** `TelemetryIngestionController` (`com.andeva.atelier.platform.iot.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<List<TelemetryStatisticalSummaryDto>> getTelemetryRangeByVehicle(@PathVariable UUID vehicleId, @RequestParam Instant startTime, @RequestParam Instant endTime, @RequestParam(defaultValue = "15m") String bucketInterval, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Ejecuta una consulta analítica de serie temporal sobre la hipertabla de TimescaleDB mediante la función `time_bucket`, retornando estadísticas agregadas de promedios, máximos y mínimos de RPM, temperatura del motor, velocidad y voltaje dentro del rango cronológico solicitado.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_WORKSHOP_ADMIN`, `ROLE_SERVICE_ADVISOR`, `ROLE_CHIEF_MECHANIC` o `ROLE_MECHANIC`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:telemetry:read')")`
* **Contexto Multi-Inquilino:** Aislamiento forzado por `tenant_id` y `vehicle_id`.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
* **Path Variables:**
  | Variable | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `vehicleId` | UUID | Identificador universal del vehículo. |
* **Query Parameters:**
  | Parámetro | Tipo | Requerido | Descripción |
  | :--- | :--- | :--- | :--- |
  | `startTime` | Instant | Sí | Fecha y hora de inicio del intervalo de análisis ISO 8601. |
  | `endTime` | Instant | Sí | Fecha y hora de fin del intervalo de análisis ISO 8601. |
  | `bucketInterval`| String | No | Ventana de agregación temporal TimescaleDB (ej. `5m`, `15m`, `1h`, default `15m`). |

##### Request DTO
No aplica para peticiones HTTP GET.

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `List<com.andeva.atelier.platform.iot.domain.model.dto.TelemetryStatisticalSummary>`

Tabla de Campos:
| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `bucketStart` | Instant | Marca temporal de inicio de la ventana de agregación. |
| `bucketEnd` | Instant | Marca temporal de término de la ventana de agregación. |
| `avgRpm` | double | Promedio aritmético de revoluciones por minuto. |
| `maxRpm` | int | Pico máximo de revoluciones alcanzado en el intervalo. |
| `avgTempCelsius` | double | Temperatura promedio del refrigerante en grados Celsius. |
| `maxTempCelsius` | double | Pico térmico máximo registrado en el motor. |
| `avgSpeedKmh` | double | Velocidad media del vehículo en km/h. |
| `maxSpeedKmh` | int | Velocidad máxima alcanzada. |
| `minBatteryVoltage`| double | Tensión mínima de batería registrada en la ventana. |
| `totalReadingsCount`| long | Cantidad de muestras individuales agregadas en el cubo. |

Ejemplo JSON de Respuesta:
```json
[
  {
    "bucketStart": "2026-10-01T15:00:00Z",
    "bucketEnd": "2026-10-01T15:15:00Z",
    "avgRpm": 2150.4,
    "maxRpm": 3400,
    "avgTempCelsius": 91.2,
    "maxTempCelsius": 96.5,
    "avgSpeedKmh": 38.6,
    "maxSpeedKmh": 65,
    "minBatteryVoltage": 13.6,
    "totalReadingsCount": 180
  },
  {
    "bucketStart": "2026-10-01T15:15:00Z",
    "bucketEnd": "2026-10-01T15:30:00Z",
    "avgRpm": 2420.1,
    "maxRpm": 4100,
    "avgTempCelsius": 94.8,
    "maxTempCelsius": 102.3,
    "avgSpeedKmh": 54.2,
    "maxSpeedKmh": 88,
    "minBatteryVoltage": 13.7,
    "totalReadingsCount": 180
  }
]
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `400 Bad Request` | `https://api.atelier.andeva.pe/errors/invalid-time-range` | `IllegalArgumentException` | El parámetro startTime es posterior a endTime o el intervalo de agregación es inválido. |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión no provisto o inválido. |

---

### 3.4. VehicleFaultsController

Controlador encargado de la captura, consulta y subsanación pericial de códigos de diagnóstico de falla (DTC).

#### POST /api/v1/iot/faults

##### Identidad Técnica
* **Controlador:** `VehicleFaultsController` (`com.andeva.atelier.platform.iot.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<VehicleFaultResponse> registerVehicleFault(@Valid @RequestBody RegisterVehicleFaultRequest request, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Registra un código de diagnóstico de falla vehicular (DTC) reportado por el escáner o ingresado por el mecánico en fosa, validando el formato estandarizado SAE J1979/ISO 15031 y asignando la severidad clínica del defecto en el historial del vehículo.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_MECHANIC` o `ROLE_CHIEF_MECHANIC`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:faults:read') or hasAuthority('iot:devices:register')")`
* **Contexto Multi-Inquilino:** Verifica que el vehículo pertenezca al taller del operador autenticado.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
  * `Content-Type: application/json` (Obligatorio)
* **Path Variables:** Ninguna.
* **Query Parameters:** Ninguno.

##### Request DTO
* **Record Java:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.requests.RegisterVehicleFaultRequest`

Tabla de Campos:
| Campo | Tipo Java | Validaciones Jakarta | Descripción |
| :--- | :--- | :--- | :--- |
| `vehicleId` | UUID | `@NotNull` | Identificador del vehículo diagnosticado. |
| `dtcCode` | String | `@NotBlank`, patrón `^[PBUC][0-3][0-9A-F]{3}$` | Código estandarizado de falla (ej. P0300, P0420, B0001). |
| `severity` | String | `@NotBlank`, patrón `LOW\|MEDIUM\|CRITICAL` | Nivel de criticidad clínica de la avería. |
| `description` | String | Opcional | Descripción técnica del síntoma o subsistema afectado. |

Ejemplo JSON de Solicitud:
```json
{
  "vehicleId": "4c56789a-bcde-f012-3456-789abcdef012",
  "dtcCode": "P0300",
  "severity": "CRITICAL",
  "description": "Fallo aleatorio o multiple de encendido en los cilindros del motor detectado por sensor de detonacion."
}
```

##### Response DTO
* **Estado HTTP:** `201 Created`
* **Headers:** `Location: /api/v1/iot/faults/{id}`
* **Record Java:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.VehicleFaultResponse`

Tabla de Campos:
| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | UUID | Identificador unívoco del registro de falla en la base de datos. |
| `vehicleId` | UUID | Identificador del vehículo afectado. |
| `dtcCode` | String | Código estandarizado DTC SAE. |
| `severity` | String | Criticidad de la falla (`LOW`, `MEDIUM`, `CRITICAL`). |
| `description` | String | Descripción clínica o diagnóstica de la falla. |
| `detectedAt` | Instant | Fecha y hora en la que se asentó la avería. |
| `isResolved` | boolean | Indicador booleano de subsanación o reparación. |
| `resolvedAt` | Instant | Fecha y hora de resolución (nulo si permanece activa). |

Ejemplo JSON de Respuesta:
```json
{
  "id": "3d456789-0123-4567-89ab-cdef01234567",
  "vehicleId": "4c56789a-bcde-f012-3456-789abcdef012",
  "dtcCode": "P0300",
  "severity": "CRITICAL",
  "description": "Fallo aleatorio o multiple de encendido en los cilindros del motor detectado por sensor de detonacion.",
  "detectedAt": "2026-10-01T15:48:00Z",
  "isResolved": false,
  "resolvedAt": null
}
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `400 Bad Request` | `https://api.atelier.andeva.pe/errors/invalid-dtc` | `InvalidDtcCodeException` | El código DTC no cumple la convención SAE J1979 (ej. debe iniciar con P, B, U o C). |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión no provisto o inválido. |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/vehicle-not-found` | `VehicleNotFoundException` | El vehículo especificado no existe en el sistema. |

---

#### GET /api/v1/iot/faults/vehicle/{vehicleId}

##### Identidad Técnica
* **Controlador:** `VehicleFaultsController` (`com.andeva.atelier.platform.iot.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<List<VehicleFaultResponse>> getVehicleFaults(@PathVariable UUID vehicleId, @RequestParam(required = false, defaultValue = "false") boolean activeOnly, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Lista las averías y códigos DTC registrados en el historial de un vehículo automotriz, permitiendo discriminar únicamente las fallas activas pendientes de reparación en bahía.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_WORKSHOP_ADMIN`, `ROLE_SERVICE_ADVISOR`, `ROLE_CHIEF_MECHANIC` o `ROLE_MECHANIC`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:faults:read')")`
* **Contexto Multi-Inquilino:** Verifica la pertenencia del vehículo al taller del usuario.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
* **Path Variables:**
  | Variable | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `vehicleId` | UUID | Identificador universal del vehículo. |
* **Query Parameters:**
  | Parámetro | Tipo | Requerido | Descripción |
  | :--- | :--- | :--- | :--- |
  | `activeOnly` | boolean | No | Si es `true` retorna exclusivamente fallas no subsanadas (`isResolved = false`). |

##### Request DTO
No aplica para peticiones HTTP GET.

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `List<com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.VehicleFaultResponse>`

Ejemplo JSON de Respuesta:
```json
[
  {
    "id": "3d456789-0123-4567-89ab-cdef01234567",
    "vehicleId": "4c56789a-bcde-f012-3456-789abcdef012",
    "dtcCode": "P0300",
    "severity": "CRITICAL",
    "description": "Fallo aleatorio o multiple de encendido en los cilindros del motor.",
    "detectedAt": "2026-10-01T15:48:00Z",
    "isResolved": false,
    "resolvedAt": null
  },
  {
    "id": "4e567890-1234-5678-9abc-def012345678",
    "vehicleId": "4c56789a-bcde-f012-3456-789abcdef012",
    "dtcCode": "P0128",
    "severity": "MEDIUM",
    "description": "Temperatura de refrigerante del motor por debajo de la temperatura regulada por el termostato.",
    "detectedAt": "2026-09-20T11:15:00Z",
    "isResolved": true,
    "resolvedAt": "2026-09-21T16:00:00Z"
  }
]
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión no provisto o inválido. |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/vehicle-not-found` | `VehicleNotFoundException` | Vehículo no encontrado en el sistema. |

---

#### PATCH /api/v1/iot/faults/{id}/resolve

##### Identidad Técnica
* **Controlador:** `VehicleFaultsController` (`com.andeva.atelier.platform.iot.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<VehicleFaultResponse> resolveVehicleFault(@PathVariable UUID id, @Valid @RequestBody(required = false) ResolveVehicleFaultRequest request, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Marca una avería electrónica como subsanada tras la ejecución del servicio correctivo en bahía y el posterior borrado computarizado del código DTC en la computadora del motor (ECU).

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_WORKSHOP_ADMIN`, `ROLE_CHIEF_MECHANIC` o `ROLE_MECHANIC`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:faults:resolve')")`
* **Contexto Multi-Inquilino:** Verifica que la falla pertenezca a un vehículo registrado en el taller autenticado.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
  * `Content-Type: application/json` (Opcional)
* **Path Variables:**
  | Variable | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `id` | UUID | Identificador unívoco del registro de falla a resolver. |
* **Query Parameters:** Ninguno.

##### Request DTO
* **Record Java:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.requests.ResolveVehicleFaultRequest`

Tabla de Campos:
| Campo | Tipo Java | Validaciones Jakarta | Descripción |
| :--- | :--- | :--- | :--- |
| `clearedByMechanic`| String | Opcional | Nombre o código de personal del mecánico que efectuó el borrado de avería. |
| `clearingMethod` | String | Opcional | Método de resolución (ej. `ECU_DTC_CLEAR_COMMAND`, `PART_REPLACEMENT`). |
| `notes` | String | Opcional | Observaciones técnicas periciales sobre la corrección física. |

Ejemplo JSON de Solicitud:
```json
{
  "clearedByMechanic": "Carlos Mendoza",
  "clearingMethod": "PART_REPLACEMENT",
  "notes": "Se sustituyeron las 4 bujias de encendido y se comprobo borrado de codigo DTC en ralentí."
}
```

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.VehicleFaultResponse`

Ejemplo JSON de Respuesta:
```json
{
  "id": "3d456789-0123-4567-89ab-cdef01234567",
  "vehicleId": "4c56789a-bcde-f012-3456-789abcdef012",
  "dtcCode": "P0300",
  "severity": "CRITICAL",
  "description": "Fallo aleatorio o multiple de encendido en los cilindros del motor.",
  "detectedAt": "2026-10-01T15:48:00Z",
  "isResolved": true,
  "resolvedAt": "2026-10-01T17:15:00Z"
}
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión no provisto o inválido. |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/fault-not-found` | `VehicleFaultNotFoundException` | La avería especificada no existe en la base de datos. |
| `409 Conflict` | `https://api.atelier.andeva.pe/errors/fault-already-resolved` | `IllegalStateException` | La avería ya figuraba previamente como subsanada. |

---

### 3.5. PredictiveAlertsController

Controlador encargado de la gestión de alertas predictivas generadas por el motor analítico ante patrones pre-catastróficos detectados en la telemetría.

#### GET /api/v1/iot/alerts/tenant

##### Identidad Técnica
* **Controlador:** `PredictiveAlertsController` (`com.andeva.atelier.platform.iot.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<List<PredictiveAlertResponse>> getTenantAlerts(@RequestParam(required = false) String severity, @RequestParam(required = false) String status, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Tablero general de control de alertas predictivas del taller automotriz, permitiendo a los asesores de servicio identificar oportunidades de contacto proactivo con clientes cuyos vehículos presentan riesgos inminentes de rotura.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_WORKSHOP_ADMIN`, `ROLE_SERVICE_ADVISOR` o `ROLE_CHIEF_MECHANIC`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:alerts:read')")`
* **Contexto Multi-Inquilino:** Filtrado forzado por el `tenant_id` autenticado.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
* **Path Variables:** Ninguna.
* **Query Parameters:**
  | Parámetro | Tipo | Requerido | Descripción |
  | :--- | :--- | :--- | :--- |
  | `severity` | String | No | Filtro por severidad de alerta (`LOW`, `MEDIUM`, `HIGH`, `CRITICAL`). |
  | `status` | String | No | Filtro por estado de atención (`NEW`, `ACKNOWLEDGED`, `DISMISSED`, `CONVERTED`). |

##### Request DTO
No aplica para peticiones HTTP GET.

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `List<com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.PredictiveAlertResponse>`

Tabla de Campos:
| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | UUID | Identificador unívoco de la alerta predictiva. |
| `vehicleId` | UUID | Identificador del vehículo automotriz en riesgo. |
| `recommendedServiceId`| UUID | Servicio de mantenimiento preventivo sugerido del catálogo MRO. |
| `alertType` | String | Tipología de anomalía detectada (ej. `COOLANT_OVERHEATING`, `BATTERY_DEGRADATION`). |
| `confidenceScore` | BigDecimal | Índice de certidumbre analítica calculada por el modelo (0.00 a 1.00). |
| `message` | String | Resumen explicativo de la condición de riesgo detectada. |
| `status` | String | Estado actual de gestión de la alerta (`NEW`, `ACKNOWLEDGED`, `DISMISSED`). |
| `createdAt` | Instant | Fecha y hora en la que el motor analítico emitió la alerta. |

Ejemplo JSON de Respuesta:
```json
[
  {
    "id": "5f678901-2345-6789-abcd-ef0123456789",
    "vehicleId": "4c56789a-bcde-f012-3456-789abcdef012",
    "recommendedServiceId": "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
    "alertType": "COOLANT_OVERHEATING",
    "confidenceScore": 0.94,
    "message": "Temperatura de motor sostenida por encima de 105C en regimen de ralenti. Riesgo de sopladura de junta de culata.",
    "status": "NEW",
    "createdAt": "2026-10-01T15:50:00Z"
  }
]
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión no provisto o inválido. |
| `403 Forbidden` | `https://api.atelier.andeva.pe/errors/forbidden` | `AccessDeniedException` | Usuario carece de permisos de lectura de alertas. |

---

#### GET /api/v1/iot/alerts/vehicle/{vehicleId}

##### Identidad Técnica
* **Controlador:** `PredictiveAlertsController` (`com.andeva.atelier.platform.iot.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<List<PredictiveAlertResponse>> getVehicleAlerts(@PathVariable UUID vehicleId, @RequestParam(required = false) String status, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Consulta la lista de alertas predictivas generadas exclusivamente para un vehículo particular, permitiendo evaluar el historial de advertencias preventivas antes de recepcionar una orden de trabajo.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_WORKSHOP_ADMIN`, `ROLE_SERVICE_ADVISOR`, `ROLE_CHIEF_MECHANIC` o `ROLE_MECHANIC`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:alerts:read')")`
* **Contexto Multi-Inquilino:** Verifica la tenencia del vehículo por parte del taller autenticado.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
* **Path Variables:**
  | Variable | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `vehicleId` | UUID | Identificador universal del vehículo. |
* **Query Parameters:**
  | Parámetro | Tipo | Requerido | Descripción |
  | :--- | :--- | :--- | :--- |
  | `status` | String | No | Filtro opcional por estado de la alerta (`NEW`, `ACKNOWLEDGED`, `DISMISSED`). |

##### Request DTO
No aplica para peticiones HTTP GET.

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `List<com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.PredictiveAlertResponse>`

Ejemplo JSON de Respuesta:
```json
[
  {
    "id": "5f678901-2345-6789-abcd-ef0123456789",
    "vehicleId": "4c56789a-bcde-f012-3456-789abcdef012",
    "recommendedServiceId": "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
    "alertType": "COOLANT_OVERHEATING",
    "confidenceScore": 0.94,
    "message": "Temperatura de motor sostenida por encima de 105C en regimen de ralenti.",
    "status": "NEW",
    "createdAt": "2026-10-01T15:50:00Z"
  }
]
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión ausente o revocado. |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/vehicle-not-found` | `VehicleNotFoundException` | El vehículo solicitado no existe en los registros. |

---

#### PATCH /api/v1/iot/alerts/{id}/dismiss

##### Identidad Técnica
* **Controlador:** `PredictiveAlertsController` (`com.andeva.atelier.platform.iot.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<PredictiveAlertResponse> dismissAlert(@PathVariable UUID id, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Descarta formalmente una alerta predictiva cuando el asesor de servicio o el jefe de taller comprueban que se debió a una condición operativa espuria o prueba controlada en dinamómetro, cerrando la advertencia.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_WORKSHOP_ADMIN` o `ROLE_SERVICE_ADVISOR`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:alerts:acknowledge')")`
* **Contexto Multi-Inquilino:** Verifica que la alerta pertenezca al taller autenticado.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
* **Path Variables:**
  | Variable | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `id` | UUID | Identificador universal de la alerta predictiva a descartar. |
* **Query Parameters:** Ninguno.

##### Request DTO
No aplica para este endpoint.

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.PredictiveAlertResponse`

Ejemplo JSON de Respuesta:
```json
{
  "id": "5f678901-2345-6789-abcd-ef0123456789",
  "vehicleId": "4c56789a-bcde-f012-3456-789abcdef012",
  "recommendedServiceId": "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
  "alertType": "COOLANT_OVERHEATING",
  "confidenceScore": 0.94,
  "message": "Temperatura de motor sostenida por encima de 105C en regimen de ralenti.",
  "status": "DISMISSED",
  "createdAt": "2026-10-01T15:50:00Z"
}
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión no provisto o inválido. |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/alert-not-found` | `PredictiveAlertNotFoundException` | La alerta especificada no existe en la base de datos. |

---

#### POST /api/v1/iot/alerts/{id}/acknowledge

##### Identidad Técnica
* **Controlador:** `PredictiveAlertsController` (`com.andeva.atelier.platform.iot.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<PredictiveAlertResponse> acknowledgeAlert(@PathVariable UUID id, @Valid @RequestBody(required = false) AcknowledgeAlertRequest request, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Confirma la lectura y reconocimiento técnico de una alerta predictiva por parte del personal del taller, cambiando su estado a `ACKNOWLEDGED` para indicar que el personal está gestionando el contacto con el conductor o preparando una orden de inspección.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_WORKSHOP_ADMIN`, `ROLE_SERVICE_ADVISOR`, `ROLE_CHIEF_MECHANIC` o `ROLE_MECHANIC`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:alerts:acknowledge')")`
* **Contexto Multi-Inquilino:** Verifica la tenencia de la alerta por parte del taller autenticado.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
  * `Content-Type: application/json` (Opcional)
* **Path Variables:**
  | Variable | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `id` | UUID | Identificador universal de la alerta predictiva a reconocer. |
* **Query Parameters:** Ninguno.

##### Request DTO
* **Record Java:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.requests.AcknowledgeAlertRequest`

Tabla de Campos:
| Campo | Tipo Java | Validaciones Jakarta | Descripción |
| :--- | :--- | :--- | :--- |
| `acknowledgedBy`| String | Opcional | Nombre o identificador del asesor o mecánico responsable del seguimiento. |

Ejemplo JSON de Solicitud:
```json
{
  "acknowledgedBy": "Marco Polo - Asesor de Servicio"
}
```

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.PredictiveAlertResponse`

Ejemplo JSON de Respuesta:
```json
{
  "id": "5f678901-2345-6789-abcd-ef0123456789",
  "vehicleId": "4c56789a-bcde-f012-3456-789abcdef012",
  "recommendedServiceId": "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
  "alertType": "COOLANT_OVERHEATING",
  "confidenceScore": 0.94,
  "message": "Temperatura de motor sostenida por encima de 105C en regimen de ralenti.",
  "status": "ACKNOWLEDGED",
  "createdAt": "2026-10-01T15:50:00Z"
}
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión no provisto o inválido. |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/alert-not-found` | `PredictiveAlertNotFoundException` | La alerta especificada no existe en la base de datos. |

---

### 3.6. VehicleHealthReportsController

Controlador encargado de la orquestación del motor pericial de diagnóstico vehicular con Inteligencia Artificial (Spring AI con Groq Cloud LPU), generación de dictámenes mecánicos y exportación documental en PDF.

#### POST /api/v1/iot/vehicles/{vehicleId}/health-reports

##### Identidad Técnica
* **Controlador:** `VehicleHealthReportsController` (`com.andeva.atelier.platform.iot.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<HealthReportCreatedResponse> generateVehicleHealthReport(@PathVariable UUID vehicleId, @Valid @RequestBody(required = false) GenerateHealthReportRequest request, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Dispara el flujo completo de evaluación de salud automotriz sobre las series temporales de TimescaleDB y fallas DTC activas. Valida el cupo mensual de reportes IA bajo el plan SaaS contratado (`maxMonthlyAiReports`), ejecuta la inferencia diagnóstica con Spring AI, almacena el reporte estructurado y retorna `201 Created` con enlaces HATEOAS para consulta JSON y descarga binaria en PDF.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_WORKSHOP_ADMIN`, `ROLE_SERVICE_ADVISOR` o `ROLE_CHIEF_MECHANIC`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:health_reports:generate')")`
* **Contexto Multi-Inquilino:** Deducción estricta de `tenant_id` desde el token JWT e inspección de cuota de suscripción en Caffeine Cache.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
  * `Content-Type: application/json` (Opcional)
* **Path Variables:**
  | Variable | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `vehicleId` | UUID | Identificador universal del vehículo automotriz a diagnosticar. |
* **Query Parameters:** Ninguno.

##### Request DTO
* **Record Java:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.requests.GenerateHealthReportRequest`

Tabla de Campos:
| Campo | Tipo Java | Validaciones Jakarta | Descripción |
| :--- | :--- | :--- | :--- |
| `daysToAnalyze` | Integer | `@Min(7)`, `@Max(90)`, Default `30` | Ventana temporal histórica de telemetría evaluada en TimescaleDB. |
| `includeResolvedDtcHistory` | Boolean | Default `false` | Indicador si se deben incluir averías ya resueltas en la inferencia. |
| `triggerReason` | String | Default `MANUAL_REQUEST` | Motivo del peritaje (ej. `PRE_TRIP_INSPECTION`, `WORK_ORDER_AUDIT`). |

Ejemplo JSON de Solicitud:
```json
{
  "daysToAnalyze": 30,
  "includeResolvedDtcHistory": false,
  "triggerReason": "PRE_TRIP_INSPECTION"
}
```

##### Response DTO
* **Estado HTTP:** `201 Created`
* **Headers:** `Location: /api/v1/iot/vehicles/{vehicleId}/health-reports/{reportId}`
* **Record Java:** `com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.HealthReportCreatedResponse`

Tabla de Campos:
| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `reportId` | UUID | Identificador universal único del informe de salud generado. |
| `vehicleId` | UUID | Identificador del vehículo evaluado. |
| `overallHealthScore` | int | Calificación general pericial de salud vehicular de 0 a 100 puntos. |
| `executiveSummary` | String | Dictamen pericial ejecutivo generado por el modelo de inteligencia artificial. |
| `totalRisksDetected` | int | Conteo total de riesgos y anomalías detectadas en los subsistemas. |
| `generatedAt` | Instant | Marca temporal de culminación de la inferencia analítica. |
| `jsonResourceUrl` | String | Ruta canónica para consultar la versión estructurada en JSON. |
| `pdfDownloadUrl` | String | Ruta canónica para descargar el documento pericial en formato binario PDF. |

Ejemplo JSON de Respuesta:
```json
{
  "reportId": "7a890123-4567-89ab-cdef-0123456789ab",
  "vehicleId": "4c56789a-bcde-f012-3456-789abcdef012",
  "overallHealthScore": 78,
  "executiveSummary": "El vehiculo presenta una condicion mecanica estable pero con signos tempranos de fatiga termica en circuito refrigerante y degradacion en bateria.",
  "totalRisksDetected": 2,
  "generatedAt": "2026-10-01T15:55:00Z",
  "jsonResourceUrl": "/api/v1/iot/vehicles/4c56789a-bcde-f012-3456-789abcdef012/health-reports/7a890123-4567-89ab-cdef-0123456789ab",
  "pdfDownloadUrl": "/api/v1/iot/vehicles/4c56789a-bcde-f012-3456-789abcdef012/health-reports/7a890123-4567-89ab-cdef-0123456789ab/pdf"
}
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `400 Bad Request` | `https://api.atelier.andeva.pe/errors/validation-failed` | `MethodArgumentNotValidException` | Días de análisis menores a 7 o mayores a 90. |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión no provisto o inválido. |
| `403 Forbidden` | `https://api.atelier.andeva.pe/errors/quota-exceeded` | `QuotaExceededException` | El taller copó su cupo mensual de reportes IA o su plan no incluye el módulo (Go/Pro). |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/vehicle-not-found` | `VehicleNotFoundException` | El vehículo a evaluar no existe en el sistema. |
| `502 Bad Gateway` | `https://api.atelier.andeva.pe/errors/ai-inference-failed` | `AiInferenceException` | Fallo de conexión o tiempo de espera agotado con la nube LPU de Groq. |

Ejemplo JSON ProblemDetail:
```json
{
  "type": "https://api.atelier.andeva.pe/errors/quota-exceeded",
  "title": "Cupo de Diagnosticos IA Copado",
  "status": 403,
  "detail": "El Plan Max otorga hasta 60 reportes IA mensuales. Ha alcanzado el 100 por ciento de su cuota contratada.",
  "instance": "/api/v1/iot/vehicles/4c56789a-bcde-f012-3456-789abcdef012/health-reports",
  "code": "AI_REPORT_QUOTA_EXCEEDED",
  "timestamp": "2026-10-01T15:55:30Z"
}
```

---

#### POST /api/v1/iot/vehicles/{vehicleId}/ai-insights

##### Identidad Técnica
* **Controlador:** `VehicleHealthReportsController` (`com.andeva.atelier.platform.iot.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<Void> requestAiInference(@PathVariable UUID vehicleId, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Solicita de forma asíncrona la inferencia pericial para auditorías masivas de flotas vehiculares o procesamiento batch nocturno. Encola la orden en el ejecutor de tareas asíncronas de Spring Boot y responde de inmediato con código HTTP 202 Accepted.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_WORKSHOP_ADMIN` o `ROLE_SERVICE_ADVISOR`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:health_reports:generate')")`
* **Contexto Multi-Inquilino:** Verifica la pertenencia del vehículo al taller del token JWT.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
* **Path Variables:**
  | Variable | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `vehicleId` | UUID | Identificador universal del vehículo a encolar. |
* **Query Parameters:** Ninguno.

##### Request DTO
No aplica para este endpoint.

##### Response DTO
* **Estado HTTP:** `202 Accepted`
* **Record Java:** No retorna cuerpo (`Void`).

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión no provisto o inválido. |
| `403 Forbidden` | `https://api.atelier.andeva.pe/errors/quota-exceeded` | `QuotaExceededException` | Cuota de inferencias predictivas agotada para el periodo actual. |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/vehicle-not-found` | `VehicleNotFoundException` | Vehículo no encontrado en el sistema. |

---

#### GET /api/v1/iot/vehicles/{vehicleId}/health-reports

##### Identidad Técnica
* **Controlador:** `VehicleHealthReportsController` (`com.andeva.atelier.platform.iot.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<List<HealthReportCreatedResponse>> getVehicleHealthReports(@PathVariable UUID vehicleId, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Lista la bitácora cronológica de todos los informes de salud mecánica e inferencias periciales calculadas históricamente para el automóvil especificado.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_WORKSHOP_ADMIN`, `ROLE_SERVICE_ADVISOR`, `ROLE_CHIEF_MECHANIC`, `ROLE_MECHANIC` o `ROLE_VEHICLE_OWNER`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:health_reports:read')")`
* **Contexto Multi-Inquilino:** Verifica que el vehículo pertenezca a la flota del taller o sea conducido por el usuario autenticado.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
* **Path Variables:**
  | Variable | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `vehicleId` | UUID | Identificador universal del vehículo. |
* **Query Parameters:** Ninguno.

##### Request DTO
No aplica para peticiones HTTP GET.

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `List<com.andeva.atelier.platform.iot.interfaces.rest.resources.responses.HealthReportCreatedResponse>`

Ejemplo JSON de Respuesta:
```json
[
  {
    "reportId": "7a890123-4567-89ab-cdef-0123456789ab",
    "vehicleId": "4c56789a-bcde-f012-3456-789abcdef012",
    "overallHealthScore": 78,
    "executiveSummary": "El vehiculo presenta una condicion mecanica estable pero con signos tempranos de fatiga termica.",
    "totalRisksDetected": 2,
    "generatedAt": "2026-10-01T15:55:00Z",
    "jsonResourceUrl": "/api/v1/iot/vehicles/4c56789a-bcde-f012-3456-789abcdef012/health-reports/7a890123-4567-89ab-cdef-0123456789ab",
    "pdfDownloadUrl": "/api/v1/iot/vehicles/4c56789a-bcde-f012-3456-789abcdef012/health-reports/7a890123-4567-89ab-cdef-0123456789ab/pdf"
  }
]
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión no provisto o inválido. |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/vehicle-not-found` | `VehicleNotFoundException` | Vehículo no encontrado en el sistema. |

---

#### GET /api/v1/iot/vehicles/{vehicleId}/health-reports/{reportId}/pdf

##### Identidad Técnica
* **Controlador:** `VehicleHealthReportsController` (`com.andeva.atelier.platform.iot.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<byte[]> downloadVehicleHealthReportPdf(@PathVariable UUID vehicleId, @PathVariable UUID reportId, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Genera y transmite de forma binaria el documento pericial maquetado en formato PDF con la identidad corporativa de Atelier Platform y del taller automotriz, incluyendo gráficos de telemetría, desglose de códigos DTC y recomendaciones preventivas calculadas por la IA.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_WORKSHOP_ADMIN`, `ROLE_SERVICE_ADVISOR` o `ROLE_VEHICLE_OWNER`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('iot:health_reports:read')")`
* **Contexto Multi-Inquilino:** Verifica que el reporte y el vehículo correspondan al taller autenticado.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
* **Path Variables:**
  | Variable | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `vehicleId` | UUID | Identificador universal del vehículo. |
  | `reportId` | UUID | Identificador universal del reporte de salud a descargar. |
* **Query Parameters:** Ninguno.

##### Request DTO
No aplica para peticiones HTTP GET.

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Headers:**
  * `Content-Type: application/pdf`
  * `Content-Disposition: attachment, filename="informe-salud-vehicular-7a890123.pdf"`
* **Tipo de Contenido:** Flujo binario de bytes (`byte[]`).

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión no provisto o inválido. |
| `403 Forbidden` | `https://api.atelier.andeva.pe/errors/forbidden` | `AccessDeniedException` | Permisos insuficientes para descargar el peritaje documental. |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/report-not-found` | `VehicleHealthReportNotFoundException` | El informe de salud solicitado no existe en los registros. |
| `500 Internal Server Error` | `https://api.atelier.andeva.pe/errors/pdf-generation-error` | `PdfRenderingException` | Falla en el motor OpenPDF durante la maquetación del documento. |

Ejemplo JSON ProblemDetail:
```json
{
  "type": "https://api.atelier.andeva.pe/errors/report-not-found",
  "title": "Informe Pericial No Encontrado",
  "status": 404,
  "detail": "No se encontro el informe de salud con identificador 7a890123-4567-89ab-cdef-0123456789ab para este vehiculo.",
  "instance": "/api/v1/iot/vehicles/4c56789a-bcde-f012-3456-789abcdef012/health-reports/7a890123-4567-89ab-cdef-0123456789ab/pdf",
  "code": "HEALTH_REPORT_NOT_FOUND",
  "timestamp": "2026-10-01T15:56:00Z"
}
```
