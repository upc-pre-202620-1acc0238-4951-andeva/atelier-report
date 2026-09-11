# Modelo de Base de Datos y Bounded Contexts (Atelier)

Este documento define la estructura relacional de la base de datos de Atelier, mapeada directamente a los 8 Bounded Contexts (Paquetes Backend) definidos en la arquitectura DDD. 

> **Nota de Arquitectura Transversal (Auditoría y Soft Deletes):**
> Para mantener este documento limpio, se asume que las entidades principales (**Aggregate Roots**) extienden implícitamente de una clase base `AuditableEntity`. Esta clase inyecta automáticamente a nivel de base de datos las siguientes columnas:
> * `created_at` (TIMESTAMP), `updated_at` (TIMESTAMP), `deleted_at` (TIMESTAMP para **Soft Delete**), y `version` (BIGINT para **Optimistic Locking**).
> 
> **¿Qué tablas son Aggregate Roots y reciben estos atributos?**
> * **IAM:** `tenants`, `branches`, `users`, `tenant_memberships`, `invitations`, `roles`. *(Hijos no auditables: `profiles`, intermedia de permisos).*
> * **CRM:** `customers`, `vehicles`, `appointments`.
> * **MRO:** `work_orders`, `work_bays`. *(Hijos no auditables: `work_order_images`, `work_order_tasks`, `work_order_task_products`, `work_order_task_images`, `task_proposals`. Estas entidades hijas cambian el `updated_at` y `version` de su padre `work_orders` cuando son modificadas).*
> * **Inventory:** `inventory_items`, `services`, `suppliers`, `inventory_batches`.
> * **HR:** `work_shifts`, `attendance_records`, `payroll_payments`.
> * **Invoicing:** `electronic_vouchers`. *(Hijos no auditables: `voucher_lines`).*
> * **SaaS Billing:** `plans`, `subscriptions`, `invoices`, `stripe_events`.
> * **IoT:** `obd2_devices`, `device_installations`, `vehicle_faults`, `predictive_alerts`. *(**Excepción**: `telemetry_logs` es una Hypertable Append-Only en TimescaleDB, por lo que intencionalmente carece de auditoría y Soft Deletes para maximizar el rendimiento).*

## 1. Identity and Access Management (IAM) & Tenancy Context
**Paquete Backend:** `com.atelier.iam`

Esta capa maneja la seguridad, la arquitectura multi-tenant, y el onboarding de empleados.

### 1.1 `tenants` (El Taller / Workspace)
| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| Identificador único del Taller |
| `name` | `VARCHAR(100)`| - | Sí | - | Nombre comercial |
| `legal_name`| `VARCHAR(150)`| - | Sí | - | Razón Social (para facturación SUNAT) |
| `tax_id` | `VARCHAR(20)` | - | Sí | - | RUC de la empresa (Único) |
| `status` | `VARCHAR(20)` | - | Sí | `'active'`| `active`, `suspended`, `pending` |
| `stripe_customer_id` | `VARCHAR(100)` | - | No | `null` | ID cruzado con Stripe para SaaS Billing |
| `created_at`| `TIMESTAMP` | - | Sí | `NOW()` | Fecha de registro en Atelier |

### 1.2 `branches` (Sucursales físicas)
| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| Identificador de sucursal |
| `tenant_id`| `UUID` | FK | Sí | - | Referencia al taller dueño |
| `name` | `VARCHAR(100)`| - | Sí | - | Ej. Sede Central, Sede Miraflores |
| `sunat_code`| `VARCHAR(10)` | - | No | `'0000'`| Código de anexo SUNAT |
| `latitude` | `DECIMAL(10,8)`| - | No | `null` | Coordenada GPS Y (Geocerca) |
| `longitude`| `DECIMAL(11,8)`| - | No | `null` | Coordenada GPS X (Geocerca) |
| `geofence_radius_m` | `INT` | - | Sí | `50` | Radio aceptado en metros para marcar asistencia |

### 1.3 `users` & `profiles` (Identidad Global)
| Tabla | Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|-------|----------|--------------|-------|------|---------|-------------|
| `users` | `id` | `UUID` | PK | Sí | `uuid()`| ID de autenticación (dueños, mecánicos, clientes) |
| `users` | `email` | `VARCHAR(150)`| - | Sí | - | Correo único de acceso |
| `users` | `password_hash`| `VARCHAR(255)`| - | No | `null` | Contraseña encriptada (Null si usa Google) |
| `users` | `auth_provider`| `VARCHAR(20)` | - | Sí | `'local'`| `'local'` o `'google'` (OAuth2 SSO) |
| `users` | `google_id`  | `VARCHAR(255)`| - | No | `null` | Subject ID de Google Auth |
| `users` | `fcm_token` | `VARCHAR(255)`| - | No | `null` | Firebase Token para notificaciones Push |
| `profiles`| `user_id` | `UUID` | PK,FK | Sí | - | Relación 1:1 con `users` |
| `profiles`| `first_name` | `VARCHAR(100)`| - | Sí | - | Nombres |
| `profiles`| `last_name` | `VARCHAR(100)`| - | Sí | - | Apellidos |
| `profiles`| `phone_number` | `VARCHAR(20)` | - | No | `null` | Teléfono de contacto |

### 1.4 `verification_tokens` (MFA, OTP & Password Reset)
| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| Identificador único del token |
| `user_id`| `UUID` | FK | Sí | - | Referencia al usuario |
| `token`  | `VARCHAR(255)`| - | Sí | - | OTP numérico (6 dígitos) o Hash alfanumérico |
| `type`   | `VARCHAR(30)` | - | Sí | - | `'email_verification'`, `'password_reset'` |
| `expires_at` | `TIMESTAMP` | - | Sí | - | Fecha de caducidad del token |
| `is_used`| `BOOLEAN` | - | Sí | `false` | Se marca `true` al canjearse |

### 1.5 `tenant_memberships` & `invitations` (Contratos y Onboarding)
| Tabla | Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|-------|----------|--------------|-------|------|---------|-------------|
| `tenant_memberships`| `id` | `UUID` | PK | Sí | `uuid()`| ID oficial del 'Empleado' (usado en MRO y HR) |
| `tenant_memberships`| `tenant_id` | `UUID` | FK | Sí | - | Taller que lo contrata |
| `tenant_memberships`| `user_id` | `UUID` | FK | Sí | - | Persona contratada |
| `tenant_memberships`| `status` | `VARCHAR(20)` | - | Sí | `'active'`| `active`, `inactive` |
| `tenant_memberships`| `salary_type`| `VARCHAR(20)` | - | Sí | `'fixed'` | `fixed` (Mensual), `hourly` (Por horas) |
| `tenant_memberships`| `base_salary`| `DECIMAL(10,2)`| - | Sí | `0.00` | Salario base pactado |
| `invitations` | `id` | `UUID` | PK | Sí | `uuid()`| Invitación al correo vía Resend |
| `invitations` | `tenant_id` | `UUID` | FK | Sí | - | Taller emisor |
| `invitations` | `email` | `VARCHAR(150)`| - | Sí | - | Destinatario |
| `invitations` | `token` | `VARCHAR(255)`| - | Sí | - | Token único de seguridad para el enlace web |
| `invitations` | `status` | `VARCHAR(20)` | - | Sí | `'pending'`| `pending`, `accepted`, `expired` |

### 1.5 Tablas de Seguridad (RBAC)
* **`roles`**: (`id` UUID, `tenant_id` UUID FK, `name` VARCHAR). Ej. "Mecánico Principal".
* **`permissions`**: (`id` UUID, `name` VARCHAR, `description` VARCHAR). Ej. `inventory:delete`, catálogos fijos.
* **`role_permissions`**: (`role_id` UUID, `permission_id` UUID). Relación N:M.
* **`membership_roles`**: (`membership_id` UUID, `role_id` UUID). Asigna un rol al empleado.

## 2. Customer and Fleet Management Context
**Paquete Backend:** `com.atelier.crm`

Gestiona las relaciones comerciales (B2C y B2B), el registro de vehículos y el agendamiento de citas.

### 2.1 `customers` (Clientes y Flotas)
| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| Identificador del cliente |
| `tenant_id` | `UUID` | FK | Sí | - | Taller al que pertenece este cliente |
| `type` | `VARCHAR(20)`| - | Sí | `'individual'`| `individual` (Persona) o `company` (Flota B2B) |
| `first_name`| `VARCHAR(100)`| - | No | `null` | Nombres (si es persona) |
| `last_name` | `VARCHAR(100)`| - | No | `null` | Apellidos (si es persona) |
| `company_name`| `VARCHAR(150)`| - | No | `null` | Razón Social (si es empresa) |
| `tax_id` | `VARCHAR(20)` | - | No | `null` | DNI o RUC (necesario para Facturación) |
| `email` | `VARCHAR(150)`| - | No | `null` | Correo de contacto |
| `phone` | `VARCHAR(20)` | - | No | `null` | Celular de contacto |

### 2.2 `vehicles` (Parque Automotor)
*Nota: Esta entidad es independiente del tenant, ya que físicamente el auto es universal y podría visitar distintos talleres de la red Atelier en el futuro.*

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| Identificador único del vehículo |
| `plate` | `VARCHAR(15)` | - | Sí | - | Placa del auto (UNIQUE) |
| `vin` | `VARCHAR(17)` | - | No | `null` | Número de chasis (Vehicle Identification Number) |
| `brand` | `VARCHAR(50)` | - | Sí | - | Marca (Ej. Toyota) |
| `model` | `VARCHAR(50)` | - | Sí | - | Modelo (Ej. Yaris) |
| `year` | `INT` | - | Sí | - | Año de fabricación |
| `engine_type`| `VARCHAR(20)` | - | No | `'gasoline'`| `gasoline`, `diesel`, `electric`, `hybrid` |

### 2.3 `vehicle_ownerships` (Historial de Propiedad)
Mantiene el registro histórico si un cliente vende su auto a otra persona (flota a particular, etc).

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| ID del registro |
| `customer_id`| `UUID` | FK | Sí | - | Cliente dueño |
| `vehicle_id` | `UUID` | FK | Sí | - | Vehículo poseído |
| `start_date` | `DATE` | - | Sí | `NOW()` | Fecha de adquisición/registro |
| `end_date` | `DATE` | - | No | `null` | Fecha de venta (null si es el dueño actual) |

### 2.4 `appointments` (Citas)
| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| Identificador de la cita |
| `tenant_id` | `UUID` | FK | Sí | - | Taller |
| `branch_id` | `UUID` | FK | Sí | - | Sede específica del taller |
| `customer_id`| `UUID` | FK | Sí | - | Cliente que agenda |
| `vehicle_id` | `UUID` | FK | Sí | - | Auto que será revisado |
| `scheduled_at`| `TIMESTAMP` | - | Sí | - | Fecha y hora pactada de llegada |
| `reason` | `TEXT` | - | No | `null` | Motivo (ej. "Alerta predictiva", "Ruido") |
| `status` | `VARCHAR(20)` | - | Sí | `'pending'`| `pending`, `confirmed`, `arrived`, `canceled` |

## 3. Workshop Operations Context (MRO)
**Paquete Backend:** `com.atelier.mro`

Es el motor operativo del taller. Orquesta el flujo de reparación, asignación de mecánicos y captura de evidencia fotográfica (Delegada al ecosistema Firebase).

### 3.1 `work_bays` (Bahías de Trabajo)
| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| Identificador de la bahía |
| `tenant_id` | `UUID` | FK | Sí | - | Taller |
| `branch_id` | `UUID` | FK | Sí | - | Sede física donde se ubica |
| `name` | `VARCHAR(50)` | - | Sí | - | Ej. "Elevador 1", "Pintura A" |
| `type` | `VARCHAR(20)` | - | Sí | `'lift'`| `lift`, `paint_booth`, `washing` |
| `status` | `VARCHAR(20)` | - | Sí | `'available'`| `available`, `occupied`, `maintenance`|

### 3.2 `work_orders` (Órdenes de Trabajo - OT)
| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| Identificador de la OT |
| `tenant_id` | `UUID` | FK | Sí | - | Taller |
| `appointment_id`| `UUID` | FK | No | `null` | Cita previa de la que deriva (nullable) |
| `vehicle_id` | `UUID` | FK | Sí | - | Vehículo a reparar |
| `internal_number`| `INT` | - | Sí | - | Correlativo visible para el cliente (Ej. 1004) |
| `current_bay_id`| `UUID` | FK | No | `null` | Bahía física donde está el auto ahora |
| `mileage_in` | `INT` | - | Sí | - | Kilometraje exacto de ingreso |
| `diagnostic_summary`|`TEXT`| - | Sí | - | Resumen del diagnóstico del auto |
| `total_amount` | `DECIMAL(10,2)`| - | Sí | `0.00` | Subtotal calculado (Suma de tareas y repuestos) |
| `status` | `VARCHAR(20)` | - | Sí | `'draft'` | `draft`, `in_progress`, `completed`, `paid`, `canceled` |

### 3.3 `work_order_images` (Inspección de Ingreso)
| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| Identificador de imagen |
| `work_order_id` | `UUID` | FK | Sí | - | OT asociada |
| `image_url` | `VARCHAR(255)`| - | Sí | - | URL pública devuelta por **Firebase Storage** |
| `description` | `VARCHAR(200)`| - | No | `null` | Ej. "Raspón en puerta derecha" |
| `uploaded_at` | `TIMESTAMP` | - | Sí | `NOW()` | Fecha de subida |

### 3.4 `work_order_tasks` (Mano de Obra / Tareas)
| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| Identificador de la tarea |
| `work_order_id` | `UUID` | FK | Sí | - | OT a la que pertenece |
| `service_id` | `UUID` | FK | Sí | - | Servicio catálogo (ej. "Cambio de aceite")|
| `mechanic_id` | `UUID` | FK | No | `null` | Ref. a `tenant_memberships` (Mecánico asignado)|
| `status` | `VARCHAR(20)` | - | Sí | `'pending'`| `pending`, `assigned`, `in_progress`, `on_hold`, `completed`, `cancelled` |
| `description` | `TEXT` | - | Sí | - | Descripción/Diagnóstico del mecánico |
| `price` | `DECIMAL(10,2)`| - | Sí | `0.00` | Costo cobrado por la mano de obra |
| `hold_reason` | `VARCHAR(50)` | - | No | `null` | Causal de pausa técnica (`waiting_parts`) |
| `missing_item_description` | `TEXT` | - | No | `null` | Repuesto o insumo faltante reportado en foso |
| `paused_at` | `TIMESTAMP` | - | No | `null` | Fecha/Hora de suspensión técnica |
| `total_paused_seconds` | `BIGINT` | - | Sí | `0` | Tiempo total acumulado en pausa (segundos) |
| `started_at` | `TIMESTAMP` | - | No | `null` | Fecha/Hora de inicio real |
| `completed_at` | `TIMESTAMP` | - | No | `null` | Fecha/Hora de fin real (mide productividad) |

### 3.5 `work_order_task_products` (Repuestos Usados)
*Nota: Al insertar registros aquí, se genera una 'reserva' lógica en el módulo de Inventario.*

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| ID del requerimiento |
| `task_id` | `UUID` | FK | Sí | - | Tarea que solicita el repuesto |
| `product_id` | `UUID` | FK | Sí | - | Repuesto catálogo (`inventory_items`) |
| `quantity` | `DECIMAL(10,2)`| - | Sí | - | Cantidad exacta solicitada |
| `unit_price` | `DECIMAL(10,2)`| - | Sí | - | Precio de venta sugerido al momento de agregar |
| `total_amount` | `DECIMAL(10,2)`| - | Sí | - | `quantity * unit_price` |

### 3.6 `work_order_task_images` (Evidencia de Reparación)
| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| Identificador de evidencia |
| `task_id` | `UUID` | FK | Sí | - | Tarea reparada |
| `image_url` | `VARCHAR(255)`| - | Sí | - | URL pública devuelta por **Firebase Storage** |
| `description` | `VARCHAR(200)`| - | No | `null` | Ej. "Filtro de aire viejo vs instalado" |
| `uploaded_at` | `TIMESTAMP` | - | Sí | `NOW()` | Fecha de subida |

### 3.7 `task_proposals` (Hallazgos y Propuestas de Tareas Adicionales)
*Nota: Representa averías o trabajos adicionales detectados por el técnico durante la inspección en elevador/foso. El mecánico no calcula montos financieros. Requiere cotización del Asesor de Servicio y diálogo pedagógico con el cliente antes de convertirse en una tarea formal (`work_order_tasks`). Si el cliente desestima la propuesta, permanece registrada como antecedente en la historia clínica del vehículo.*

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| Identificador único del hallazgo / propuesta |
| `work_order_id` | `UUID` | FK | Sí | - | Orden de trabajo vinculada |
| `task_id` | `UUID` | FK | No | `null` | Tarea durante la cual se detectó la avería (nullable) |
| `service_id` | `UUID` | FK | No | `null` | Servicio de catálogo sugerido para resolver la falla |
| `mechanic_id` | `UUID` | FK | Sí | - | Mecánico que detectó el hallazgo (ref. a `tenant_memberships`) |
| `description` | `TEXT` | - | Sí | - | Detalle técnico de la avería encontrada |
| `severity` | `VARCHAR(20)` | - | Sí | `'medium'`| Severidad (`low`, `medium`, `critical`) |
| `image_url` | `VARCHAR(255)`| - | Sí | - | Foto pericial del hallazgo alojada en Firebase Storage |
| `status` | `VARCHAR(20)` | - | Sí | `'pending_review'`| Estado (`pending_review`, `approved`, `rejected`) |
| `customer_notes` | `VARCHAR(500)`| - | No | `null` | Justificación del cliente ante aprobación o rechazo |
| `created_at` | `TIMESTAMP` | - | Sí | `NOW()` | Fecha de registro del hallazgo en foso |
| `updated_at` | `TIMESTAMP` | - | Sí | `NOW()` | Fecha de resolución por el asesor de servicio |

## 4. Inventory and Supply Chain Context
**Paquete Backend:** `com.atelier.inventory`

Funciona como un mini-ERP logístico. Asegura la rentabilidad real del negocio aplicando estrictamente el método de costeo FIFO (Primeras Entradas, Primeras Salidas).

### 4.1 `inventory_items` (Catálogo Físico)
| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| ID del repuesto / líquido |
| `tenant_id` | `UUID` | FK | Sí | - | Taller dueño del inventario |
| `name` | `VARCHAR(150)`| - | Sí | - | Ej. "Filtro de Aceite Bosh" |
| `sku` | `VARCHAR(50)` | - | Sí | - | Código interno (Stock Keeping Unit) |
| `category` | `VARCHAR(50)` | - | No | `null` | Ej. Lubricantes, Frenos, Suspensión |
| `base_price` | `DECIMAL(10,2)`| - | Sí | `0.00` | Precio de venta sugerido al cliente |
| `total_stock`| `DECIMAL(10,2)`| - | Sí | `0.00` | Stock total (Suma virtual de los lotes) |

### 4.2 `services` (Catálogo de Mano de Obra)
| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| ID del servicio abstracto |
| `tenant_id` | `UUID` | FK | Sí | - | Taller que ofrece el servicio |
| `name` | `VARCHAR(150)`| - | Sí | - | Ej. "Alineamiento y Balanceo" |
| `base_price` | `DECIMAL(10,2)`| - | Sí | `0.00` | Precio cobrado por la mano de obra |
| `estimated_time_m` | `INT` | - | No | `60` | Tiempo estimado en minutos |

### 4.3 `suppliers` (Directorio de Proveedores)
Directorio interno del taller. Permite vincular rápidamente de quién provienen los lotes sin requerir complejas órdenes de compra en el Frontend.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| Identificador del proveedor |
| `tenant_id` | `UUID` | FK | Sí | - | Taller al que le pertenece el registro |
| `business_name` | `VARCHAR(150)`| - | Sí | - | Nombre o Razón Social |
| `tax_id` | `VARCHAR(20)` | - | No | `null` | RUC del proveedor |
| `phone` | `VARCHAR(20)` | - | No | `null` | Teléfono de contacto |
| `email` | `VARCHAR(150)`| - | No | `null` | Correo de contacto |

### 4.4 `inventory_batches` (Lotes FIFO - El Núcleo Contable)
El administrador crea un lote directamente en el Frontend indicando costo y cantidad. Al consumir repuestos en MRO, el sistema los descuenta del lote con fecha más antigua, arrastrando este costo exacto.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| Identificador del lote |
| `tenant_id` | `UUID` | FK | Sí | - | Taller |
| `item_id` | `UUID` | FK | Sí | - | Producto físico al que suma stock |
| `supplier_id` | `UUID` | FK | No | `null` | ¿A quién se lo compraron? (Directorio) |
| `receipt_image_url`| `VARCHAR(255)`| - | No | `null` | **URL de Firebase Storage** con la foto de la factura/boleta |
| `initial_qty` | `DECIMAL(10,2)`| - | Sí | - | Cantidad que ingresó originalmente |
| `remaining_qty`| `DECIMAL(10,2)`| - | Sí | - | Cantidad disponible actual (FIFO) |
| `unit_cost` | `DECIMAL(10,2)`| - | Sí | - | Costo exacto que se usará para rentabilidad |
| `arrival_date` | `TIMESTAMP` | - | Sí | `NOW()` | Vital para el ordenamiento cronológico FIFO |

## 5. Human Resources Management Context
**Paquete Backend:** `com.atelier.hr`

Gestiona los horarios, procesa la asistencia validada algorítmicamente por GPS (Geocercas) y calcula las nóminas/planillas de los empleados.

### 5.1 `work_shifts` (Turnos de Trabajo)
| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| Identificador del turno |
| `tenant_id` | `UUID` | FK | Sí | - | Taller |
| `name` | `VARCHAR(50)` | - | Sí | - | Ej. "Turno Mañana", "Madrugada" |
| `start_time` | `TIME` | - | Sí | - | Hora de ingreso oficial (Ej. 08:00) |
| `end_time` | `TIME` | - | Sí | - | Hora de salida oficial (Ej. 17:00) |
| `grace_period_m`| `INT` | - | Sí | `15` | Minutos de tolerancia para tardanza |

### 5.2 `attendance_records` (Marcaciones GPS)
Cuando el empleado marca asistencia, la app móvil envía sus coordenadas. El backend calcula la fórmula de Haversine contra la sucursal y, si aprueba, inserta este registro.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| ID de la marcación |
| `membership_id`| `UUID` | FK | Sí | - | Empleado que marca |
| `shift_id` | `UUID` | FK | Sí | - | Turno que se le está evaluando |
| `clock_in` | `TIMESTAMP` | - | Sí | `NOW()` | Hora real en la que ingresó |
| `clock_out` | `TIMESTAMP` | - | No | `null` | Hora real en la que salió |
| `status` | `VARCHAR(20)` | - | Sí | `'on_time'`| `on_time`, `late`, `absent` (Calculado) |
| `latitude` | `DECIMAL(10,8)`| - | Sí | - | GPS Y (Evidencia de dónde marcó) |
| `longitude` | `DECIMAL(11,8)`| - | Sí | - | GPS X (Evidencia de dónde marcó) |

### 5.3 `payroll_payments` (Planillas / Nóminas)
| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| Identificador de la boleta de pago |
| `membership_id`| `UUID` | FK | Sí | - | Empleado que recibe el pago |
| `period_start` | `DATE` | - | Sí | - | Inicio del periodo (Ej. 01/08/2025) |
| `period_end` | `DATE` | - | Sí | - | Fin del periodo (Ej. 31/08/2025) |
| `base_amount` | `DECIMAL(10,2)`| - | Sí | - | Salario base extraído de su contrato |
| `deductions` | `DECIMAL(10,2)`| - | Sí | `0.00` | Descuentos aplicados por `late`/`absent` |
| `bonuses` | `DECIMAL(10,2)`| - | No | `0.00` | Bonos por productividad |
| `total_paid` | `DECIMAL(10,2)`| - | Sí | - | Monto final a transferir |
| `status` | `VARCHAR(20)` | - | Sí | `'draft'` | `draft`, `approved`, `paid` |

## 6. Invoicing and Compliance Context
**Paquete Backend:** `com.atelier.invoicing`

Encapsula la complejidad tributaria (Impuestos, SUNAT) lejos del MRO y del Inventario, operando de manera segura detrás de una Capa Anticorrupción (ACL) hacia Nubefact.

### 6.1 `electronic_vouchers` (Comprobantes de Pago Electrónicos)
| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| Identificador interno |
| `tenant_id` | `UUID` | FK | Sí | - | Taller emisor (RUC) |
| `customer_id`| `UUID` | FK | Sí | - | Cliente receptor (DNI/RUC) |
| `work_order_id`| `UUID`| FK | No | `null` | OT que originó el cobro (si aplica) |
| `type` | `VARCHAR(10)` | - | Sí | - | `01` (Factura), `03` (Boleta) según SUNAT |
| `serie` | `VARCHAR(4)` | - | Sí | - | Ej. `F001`, `B001` |
| `number` | `INT` | - | Sí | - | Correlativo autoincremental (Ej. 142) |
| `subtotal` | `DECIMAL(10,2)`| - | Sí | - | Suma sin IGV |
| `igv_amount` | `DECIMAL(10,2)`| - | Sí | - | Monto del IGV (18%) |
| `total_amount`| `DECIMAL(10,2)`| - | Sí | - | `subtotal + igv_amount` |
| `sunat_pdf_url`| `VARCHAR(255)`| - | No | `null` | URL pública devuelta por Nubefact (PDF) |
| `sunat_xml_url`| `VARCHAR(255)`| - | No | `null` | URL pública devuelta por Nubefact (XML UBL 2.1) |
| `status` | `VARCHAR(20)` | - | Sí | `'draft'`| `draft`, `accepted`, `rejected_sunat` |

### 6.2 `voucher_lines` (Detalle del Comprobante)
Nubefact exige que los precios unitarios se envíen desglosados lógicamente (con y sin IGV).

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| ID de la línea |
| `voucher_id` | `UUID` | FK | Sí | - | Comprobante al que pertenece |
| `description`| `VARCHAR(200)`| - | Sí | - | Nombre exacto del repuesto o servicio |
| `quantity` | `DECIMAL(10,2)`| - | Sí | - | Cantidad vendida |
| `unit_value` | `DECIMAL(10,2)`| - | Sí | - | Precio unitario SIN IGV (Requerido por Nubefact) |
| `unit_price` | `DECIMAL(10,2)`| - | Sí | - | Precio unitario CON IGV |
| `total_line` | `DECIMAL(10,2)`| - | Sí | - | Subtotal de esta línea |

## 7. SaaS Billing and Subscriptions Context
**Paquete Backend:** `com.atelier.subscriptions`

Administra los ingresos B2B de la startup Andeva (el pago que hacen los talleres mensualmente por usar el software). Completamente integrado con **Stripe**.

### 7.1 `plans` (Planes de Suscripción)
| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| Identificador del plan |
| `stripe_price_id`| `VARCHAR(100)`| - | Sí | - | ID oficial en Stripe (Ej. `price_1N2M...`) |
| `name` | `VARCHAR(100)`| - | Sí | - | Ej. "Plan Pro (Hasta 5 sucursales)" |
| `price` | `DECIMAL(10,2)`| - | Sí | - | Precio mensual (USD o PEN) |
| `billing_cycle`| `VARCHAR(20)` | - | Sí | `'monthly'`| `monthly`, `yearly` |

### 7.2 `subscriptions` (Suscripciones Activas)
| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| ID interno de la suscripción |
| `tenant_id` | `UUID` | FK | Sí | - | Taller que contrató el plan |
| `plan_id` | `UUID` | FK | Sí | - | Plan contratado |
| `stripe_sub_id`| `VARCHAR(100)`| - | Sí | - | ID recurrente en Stripe (`sub_...`) |
| `status` | `VARCHAR(20)` | - | Sí | `'active'` | `active`, `past_due`, `canceled` |
| `current_period_end`| `TIMESTAMP` | - | Sí | - | Fecha del próximo corte/cobro |

### 7.3 `invoices` (Facturas SaaS - Andeva al Taller)
*Nota: No confundir con el Invoicing SUNAT (que es del taller hacia sus clientes). Estas son facturas internas de uso de plataforma.*

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| Identificador de la factura SaaS |
| `subscription_id`| `UUID` | FK | Sí | - | Suscripción que generó el cobro |
| `stripe_invoice_id`| `VARCHAR(100)`| - | Sí | - | ID de factura de Stripe (`in_...`) |
| `amount_paid` | `DECIMAL(10,2)`| - | Sí | - | Monto exacto cobrado a la tarjeta |
| `status` | `VARCHAR(20)` | - | Sí | `'paid'` | `draft`, `paid`, `void` |
| `paid_at` | `TIMESTAMP` | - | Sí | `NOW()` | Fecha del cobro exitoso |

### 7.4 `stripe_events` (Webhook Idempotency)
Tabla crítica arquitectónicamente. Cuando Stripe cobra, envía un evento asíncrono (Webhook) a nuestro servidor. Si la red falla y Stripe manda el mismo evento 2 veces, esta tabla lo rechaza (restricción `UNIQUE`) para no procesarlo de nuevo.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| ID interno de base de datos |
| `stripe_event_id`| `VARCHAR(100)`| - | Sí | - | ID del evento Stripe (Ej. `evt_...`) **[UNIQUE]** |
| `type` | `VARCHAR(50)` | - | Sí | - | Ej. `invoice.payment_succeeded` |
| `processed_at` | `TIMESTAMP` | - | Sí | `NOW()` | Cuando el sistema de Atelier procesó el evento |

## 8. IoT Telemetry and Predictive Maintenance Context
**Paquete Backend:** `com.atelier.iot`

El núcleo diferenciador del negocio. Ingesta, procesa y evalúa los millones de registros de telemetría vehicular enviados a través de las apps *Gateway*.

### 8.1 `obd2_devices` (Hardware del Taller)
| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| Identificador de base de datos |
| `tenant_id` | `UUID` | FK | Sí | - | Taller dueño del equipo (BYOD) |
| `device_identifier`| `VARCHAR(100)`| - | Sí | - | MAC Address (BLE) o IMEI (SIM) **[UNIQUE]** |
| `connection_type`| `VARCHAR(20)` | - | Sí | - | `bluetooth`, `sim_cellular`, `wifi` |
| `status` | `VARCHAR(20)` | - | Sí | `'active'`| `active`, `lost`, `broken` |

### 8.2 `device_installations` (Asignación al Vehículo)
Conecta físicamente el escáner del taller al auto del cliente por un periodo de tiempo.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| ID de instalación |
| `device_id` | `UUID` | FK | Sí | - | Escáner OBD2 usado |
| `vehicle_id` | `UUID` | FK | Sí | - | Vehículo receptor |
| `installed_at`| `TIMESTAMP` | - | Sí | `NOW()` | Fecha que inició el servicio VIP |
| `uninstalled_at`|`TIMESTAMP` | - | No | `null` | Fecha fin (null si sigue activo) |

### 8.3 `telemetry_logs` (TimescaleDB Hypertable)
*Nota Arquitectónica: Optimizada masivamente para particionamiento por tiempo.*

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `timestamp` | `TIMESTAMP` | PK | Sí | `NOW()` | **Clave de partición (Time chunk)** |
| `vehicle_id` | `UUID` | PK,FK | Sí | - | Vehículo que emite (PK compuesta) |
| `tenant_id` | `UUID` | FK | Sí | - | Desnormalizado para reportes rápidos del taller|
| `latitude` | `DECIMAL(10,8)`| - | No | `null` | Coordenada GPS Y (Si el gateway la provee) |
| `longitude` | `DECIMAL(11,8)`| - | No | `null` | Coordenada GPS X (Si el gateway la provee) |
| `speed` | `INT` | - | No | `null` | Velocidad actual reportada por la ECU |
| `engine_temp_c`| `DECIMAL(5,2)` | - | No | `null` | Temperatura del motor en grados Celcius |
| `rpm` | `INT` | - | No | `null` | Revoluciones del motor |

### 8.4 `vehicle_faults` (Códigos de Error - DTC)
| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| ID del registro |
| `vehicle_id` | `UUID` | FK | Sí | - | Vehículo que sufre el fallo |
| `dtc_code` | `VARCHAR(10)` | - | Sí | - | Ej. `P0420` (Catalizador) |
| `severity` | `VARCHAR(20)` | - | Sí | `'low'` | `low`, `medium`, `critical` |
| `detected_at` | `TIMESTAMP` | - | Sí | `NOW()` | Cuando el OBD2 arrojó la alerta |

### 8.5 `predictive_alerts` (Notificaciones Push)
| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| ID de alerta predictiva |
| `vehicle_id` | `UUID` | FK | Sí | - | Vehículo evaluado por el modelo |
| `recommended_service_id`| `UUID` | FK| Sí | - | Enlace con Módulo Inventory (Venta Cruzada) |
| `confidence_score`| `DECIMAL(5,2)`| - | Sí | - | % de probabilidad de fallo real (Ej. `88.50`) |
| `status` | `VARCHAR(20)` | - | Sí | `'sent'`| `sent`, `resolved`, `ignored` |
| `created_at` | `TIMESTAMP` | - | Sí | `NOW()` | Dispara el Firebase Admin SDK |

## Infraestructura y Patrones Globales
**Paquete Backend:** `com.atelier.shared`

### 8.6 `outbox_messages` (Transactional Outbox)
Tabla base de la arquitectura para garantizar la Consistencia Eventual. Los eventos (ej. enviar factura a SUNAT, enviar correo por Resend) se guardan aquí *antes* de salir a internet.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|----------|--------------|-------|------|---------|-------------|
| `id` | `UUID` | PK | Sí | `uuid()`| ID del mensaje encolado |
| `aggregate_type`| `VARCHAR(100)`| - | Sí | - | Nombre del evento (Ej. `InvoiceCreated`) |
| `aggregate_id`| `UUID` | - | Sí | - | ID de la entidad principal afectada |
| `payload` | `JSONB` | - | Sí | - | Los datos crudos a procesar (JSON) |
| `status` | `VARCHAR(20)` | - | Sí | `'pending'`| `pending`, `processed`, `failed` |
| `retry_count` | `INT` | - | Sí | `0` | Veces que el Worker (`@Scheduled`) re-intentó |

## 9. Addendum: Modelo de Datos Local Móvil (Offline-First Sync Queue)
Para soportar el modo offline en ambientes sin cobertura (49.1% de usuarios sin plan de datos constante o mecánicos en fosos), las aplicaciones de Atelier (Workshop y Driver) mantendrán bases de datos locales embebidas fundamentadas en **SQLite como motor relacional transaccional**: implementado mediante **Room Database** (Android Jetpack) en la versión de Kotlin por su validación en tiempo de compilación y reactividad nativa con Coroutines/Flow, y mediante **Drift** en la versión multiplataforma de Flutter.

Además de cachear catálogos (`services`, `inventory_items`) para lectura instantánea, la estructura vital para operar de forma desconectada será la cola de sincronización (Sync Queue) o "Transactional Outbox Móvil":

### `pending_sync_events` (Cola de Sincronización Móvil)
| Atributo | Tipo de Dato | Llave | Req. | Descripción |
|----------|--------------|-------|------|-------------|
| `id` | `UUID` | PK | Sí | Identificador local del evento |
| `action_type`| `VARCHAR(100)`| - | Sí | Ej. `MARK_TASK_COMPLETED`, `UPLOAD_EVIDENCE` |
| `payload` | `JSON` | - | Sí | Datos a enviar a la API cuando haya conexión (ej. `taskId`) |
| `status` | `VARCHAR(20)` | - | Sí | `pending`, `syncing`, `failed` |
| `created_at` | `TIMESTAMP` | - | Sí | Marca de tiempo en la que el usuario hizo la acción offline |

*Esta tabla permite el diseño resiliente que procesará las actualizaciones diferidas cuando un Background Worker recupere la conexión a la red.*
