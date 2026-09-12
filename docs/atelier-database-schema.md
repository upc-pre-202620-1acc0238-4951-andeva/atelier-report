# Modelo de Base de Datos y Bounded Contexts (Atelier)

Este documento define la estructura relacional de la base de datos de Atelier, mapeada directamente a los Bounded Contexts definidos en la arquitectura táctica Domain-Driven Design (DDD) de la plataforma SaaS de gestión de talleres automotrices y telemetría predictiva.

> **Nota de Arquitectura Transversal (Arquetipo JPA y Herencia `@MappedSuperclass`):**
> Para garantizar la trazabilidad inmutable, el aislamiento multi-inquilino y el control de concurrencia en PostgreSQL 16 (Aiven Cloud), todas las entidades raíz (**Aggregate Roots**) y entidades maestras principales heredan físicamente del arquetipo JPA `auditable_abstract_entity` (`AuditableAbstractEntity`), el cual proyecta las siguientes columnas a nivel relacional:
> * `id` (`UUID` PK): Clave primaria técnica universal generada mediante UUID v4.
> * `tenant_id` (`UUID` FK): Clave foránea obligatoria hacia `tenants(id)` para particionamiento lógico y aislamiento multi-tenant estricto (garantizado en queries mediante directivas Hibernate y filtros de sesión).
> * `created_at` (`TIMESTAMPTZ`): Marca temporal inmutable de registro en UTC (`NOW()`).
> * `updated_at` (`TIMESTAMPTZ`): Marca temporal de última modificación en UTC (`NOW()`).
> * `version` (`BIGINT`): Contador secuencial para control de concurrencia optimista (`@Version`), evitando colisiones y actualizaciones perdidas (*lost updates*).
> * `deleted_at` (`TIMESTAMPTZ` nullable): Marca temporal para borrado lógico (*Soft Delete*), preservando la integridad referencial histórica.
> 
> **Herencia física en el modelo relacional:**
> * **Shared Kernel:** No contiene tablas de negocio directas; define el arquetipo base y la tabla de infraestructura transaccional `outbox_messages`.
> * **IAM & Tenancy:** `tenants`, `branches`, `users` *(cuenta global sin tenant_id)*, `tenant_memberships`, `invitations`, `roles`. *(Entidades dependientes o intermedias no auditables: `profiles`, `verification_tokens`, `role_permissions`, `membership_roles`)*.
> * **Customer & Fleet Management (CRM):** `customers`, `appointments`, `vehicle_ownerships`. *(Excepción arquitectónica: `vehicles` es un activo físico universal a nivel automotor, por lo que hereda id, created_at, updated_at, version y deleted_at pero prescinde de tenant_id)*.
> * **Workshop Operations (MRO):** `work_bays`, `services`, `work_orders`. *(Entidades hijas y dependientes operativas: `work_order_images`, `work_order_tasks`, `work_order_task_products`, `work_order_task_images`, `task_proposals`. Estas entidades actualizan el `updated_at` y `version` de su agregado padre `work_orders`)*.
> * **Inventory & Supply Chain:** `inventory_items`, `suppliers`, `purchase_orders`. *(Entidades dependientes y operativas: `inventory_batches`, `purchase_order_items`)*.
> * **Human Resources Management (HR):** `work_shifts`, `attendance_records`, `payroll_payments`, `employee_profiles`. *(Entidad dependiente: `payroll_items`)*.
> * **Invoicing & Compliance:** `sunat_series_configurations`, `electronic_vouchers`, `voucher_payments`. *(Entidad dependiente: `voucher_lines`)*.
> * **SaaS Billing & Subscriptions:** `plans`, `subscriptions`, `invoices`, `stripe_events`. *(Entidad dependiente: `plan_features`)*.
> * **IoT Telemetry & Predictive Maintenance:** `obd2_devices`, `device_installations`, `vehicle_faults`, `predictive_alerts`, `dtc_catalog`. *(Excepción: `telemetry_logs` es una hypertable append-only en TimescaleDB sin borrado lógico)*.

---

## 1. Identity and Access Management (IAM) & Tenancy Context
**Paquete Backend:** `com.andeva.atelier.platform.iam`

Gobierna la autenticación de usuarios, la seguridad perimetral basada en tokens JWT/OAuth2, el aprovisionamiento de inquilinos (talleres mecánicos), la administración de sedes físicas y el control de acceso basado en roles y permisos granulares (RBAC).

### 1.1 `tenants` (El Taller / Workspace Multi-Tenant)
Entidad raíz del aislamiento lógico de la plataforma SaaS. Representa la empresa o taller mecánico titular de la cuenta corporativa.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador técnico único del taller |
| `name` | `VARCHAR(100)` | - | Sí | - | Nombre comercial del taller automotriz |
| `legal_name` | `VARCHAR(150)` | - | Sí | - | Razón social registrada formalmente ante SUNAT |
| `tax_id` | `VARCHAR(20)` | UK | Sí | - | Número de RUC de la empresa (unívoco nacional) |
| `status` | `VARCHAR(20)` | - | Sí | `'active'` | Estado operativo (`active`, `suspended`, `pending`) |
| `stripe_customer_id` | `VARCHAR(100)` | - | No | `null` | Identificador de cliente en la pasarela Stripe Billing |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de alta en la plataforma |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de última actualización |
| `version` | `BIGINT` | - | Sí | `0` | Versión para bloqueo optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `1:N` hacia `branches` (Un taller posee una o múltiples sedes operativas).
  * `1:N` hacia `tenant_memberships` (Un taller emplea a múltiples colaboradores).
  * `1:N` hacia `invitations` (Un taller emite invitaciones para nuevo personal).
  * `1:N` hacia `roles` (Un taller define roles personalizados de seguridad).
* **Restricciones (Constraints):**
  * `pk_tenants`: `PRIMARY KEY (id)`
  * `uk_tenants_tax_id`: `UNIQUE (tax_id)`
  * `chk_tenant_status`: `CHECK (status IN ('active', 'suspended', 'pending'))`
* **Índices Físicos (B-Tree):**
  * `idx_tenants_tax_id`: B-Tree sobre `(tax_id)`
  * `idx_tenants_status`: B-Tree sobre `(status)`

### 1.2 `branches` (Sedes Físicas y Talleres Operativos)
Representa cada establecimiento físico o sucursal perteneciente al taller. Custodia la ubicación geográfica para validaciones de geocerca y control de presencia.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador técnico único de la sucursal |
| `tenant_id` | `UUID` | FK | Sí | - | Taller propietario (`FK -> tenants(id)`) |
| `name` | `VARCHAR(100)` | - | Sí | - | Denominación o nombre descriptivo de la sede |
| `sunat_code` | `VARCHAR(10)` | - | No | `null` | Código oficial de establecimiento anexo SUNAT (4 dígitos) |
| `latitude` | `DECIMAL(10,8)` | - | No | `null` | Latitud geográfica del centroide del taller |
| `longitude` | `DECIMAL(11,8)` | - | No | `null` | Longitud geográfica del centroide del taller |
| `geofence_radius_m` | `INTEGER` | - | Sí | `50` | Radio en metros para geocercas satelitales |
| `is_active` | `BOOLEAN` | - | Sí | `true` | Bandera de operatividad comercial de la sede |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de creación |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de última modificación |
| `version` | `BIGINT` | - | Sí | `0` | Versión para bloqueo optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `tenants` (`tenant_id` referencia a `tenants.id`).
  * `1:N` hacia `work_bays` en MRO (Una sede dispone de múltiples bahías físicas).
  * `1:N` hacia `appointments` en CRM (Una sede atiende citas programadas).
  * `1:N` hacia `employee_profiles` en HR (Una sede adscribe colaboradores).
* **Restricciones (Constraints):**
  * `pk_branches`: `PRIMARY KEY (id)`
  * `fk_branches_tenant_id`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id)`
  * `chk_geofence_radius`: `CHECK (geofence_radius_m >= 10)`
* **Índices Físicos (B-Tree):**
  * `idx_branches_tenant_id`: B-Tree sobre `(tenant_id)`
  * `idx_branches_coords`: B-Tree compuesto sobre `(latitude, longitude)`

### 1.3 `users` (Cuentas de Acceso Global)
Entidad global del sistema. Representa una persona física con credenciales para interactuar con la plataforma Atelier independientemente de sus afiliaciones corporativas.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador universal de la cuenta de usuario |
| `email` | `VARCHAR(150)` | UK | Sí | - | Correo electrónico unívoco global (login principal) |
| `password_hash` | `VARCHAR(255)` | - | No | `null` | Hash criptográfico de contraseña (BCrypt cost 12) |
| `auth_provider` | `VARCHAR(20)` | - | Sí | `'local'` | Proveedor de autenticación (`local`, `google`) |
| `google_id` | `VARCHAR(255)` | - | No | `null` | Identificador federado de cuenta Google OAuth2 |
| `fcm_token` | `VARCHAR(255)` | - | No | `null` | Token de registro en Firebase Cloud Messaging |
| `status` | `VARCHAR(20)` | - | Sí | `'pending_verification'` | Estado (`pending_verification`, `active`, `suspended`) |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de alta |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de última modificación |
| `version` | `BIGINT` | - | Sí | `0` | Versión para bloqueo optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `1:1` hacia `profiles` (Un usuario posee exactamente un perfil demográfico).
  * `1:N` hacia `verification_tokens` (Un usuario recibe códigos y enlaces de seguridad).
  * `1:N` hacia `tenant_memberships` (Un usuario puede pertenecer a uno o varios talleres).
* **Restricciones (Constraints):**
  * `pk_users`: `PRIMARY KEY (id)`
  * `uk_users_email`: `UNIQUE (email)`
  * `chk_users_auth_provider`: `CHECK (auth_provider IN ('local', 'google'))`
  * `chk_users_status`: `CHECK (status IN ('pending_verification', 'active', 'suspended'))`
* **Índices Físicos (B-Tree):**
  * `idx_users_email`: B-Tree sobre `(email)`
  * `idx_users_google_id`: B-Tree parcial sobre `(google_id) WHERE google_id IS NOT NULL`

### 1.4 `profiles` (Perfiles Demográficos de Usuario)
Contiene la información biográfica y de contacto del usuario. Comparte la misma clave primaria del usuario garantizando una relación estrictamente biunívoca.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `user_id` | `UUID` | PK, FK | Sí | - | Identificador de la cuenta (`PK, FK -> users(id) ON DELETE CASCADE`) |
| `first_name` | `VARCHAR(100)` | - | Sí | - | Nombres de pila de la persona |
| `last_name` | `VARCHAR(100)` | - | Sí | - | Apellidos de la persona |
| `phone_number` | `VARCHAR(20)` | - | No | `null` | Teléfono móvil de contacto personal |
| `avatar_url` | `VARCHAR(255)` | - | No | `null` | URL de la imagen de perfil en Firebase / Google Cloud Storage |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de creación |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de actualización |

* **Relaciones (Integridad Referencial):**
  * `1:1` con `users` (El atributo `user_id` actúa simultáneamente como PK y FK con borrado en cascada).
* **Restricciones (Constraints):**
  * `pk_profiles`: `PRIMARY KEY (user_id)`
  * `fk_profiles_user_id`: `FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE`

### 1.5 `verification_tokens` (Tokens Criptográficos y OTP)
Almacena tokens de un solo uso para validación de cuenta de correo, recuperación de contraseñas y códigos OTP transaccionales.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador técnico del token de seguridad |
| `user_id` | `UUID` | FK | Sí | - | Cuenta destinataria (`FK -> users(id) ON DELETE CASCADE`) |
| `token` | `VARCHAR(255)` | - | Sí | - | Token criptográfico seguro o código numérico OTP |
| `type` | `VARCHAR(30)` | - | Sí | - | Propósito (`email_verification`, `password_reset`, `login_otp`) |
| `expires_at` | `TIMESTAMPTZ` | - | Sí | - | Marca temporal límite de validez temporal |
| `is_used` | `BOOLEAN` | - | Sí | `false` | Bandera de consumo y anulación del token |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de emisión |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de actualización |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `users` (`user_id` referencia a `users.id` con eliminación en cascada).
* **Restricciones (Constraints):**
  * `pk_verification_tokens`: `PRIMARY KEY (id)`
  * `fk_verification_tokens_user_id`: `FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE`
  * `chk_token_type`: `CHECK (type IN ('email_verification', 'password_reset', 'login_otp'))`
* **Índices Físicos (B-Tree):**
  * `idx_verification_tokens_lookup`: B-Tree compuesto sobre `(user_id, token, type)`

### 1.6 `tenant_memberships` (Membresías Contractuales de Taller)
Materializa el vínculo laboral y contractual entre un usuario global y un taller automotriz específico, permitiendo a una persona trabajar en múltiples talleres con roles soberanos.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador técnico de la membresía institucional |
| `tenant_id` | `UUID` | FK | Sí | - | Taller automotriz empleador (`FK -> tenants(id)`) |
| `user_id` | `UUID` | FK | Sí | - | Cuenta de usuario contratada (`FK -> users(id)`) |
| `status` | `VARCHAR(20)` | - | Sí | `'active'` | Estado contractual (`active`, `inactive`) |
| `salary_type` | `VARCHAR(20)` | - | Sí | `'fixed'` | Modalidad de compensación (`fixed`, `hourly`) |
| `base_salary` | `DECIMAL(10,2)` | - | Sí | `0.00` | Remuneración base acordada en contrato |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de incorporación laboral |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de última modificación contractual |
| `version` | `BIGINT` | - | Sí | `0` | Versión para bloqueo optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal de cese laboral (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `tenants` (`tenant_id` referencia a `tenants.id`).
  * `N:1` hacia `users` (`user_id` referencia a `users.id`).
  * `1:N` hacia `membership_roles` (Una membresía puede asumir múltiples roles RBAC).
  * `1:N` hacia `work_order_tasks` en MRO (Un colaborador es asignado como mecánico en tareas).
  * `1:1` hacia `employee_profiles` en HR (Expediente laboral unívoco del colaborador).
  * `1:N` hacia `attendance_records` en HR (Marcaciones presenciales del colaborador).
* **Restricciones (Constraints):**
  * `pk_tenant_memberships`: `PRIMARY KEY (id)`
  * `fk_memberships_tenant_id`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id)`
  * `fk_memberships_user_id`: `FOREIGN KEY (user_id) REFERENCES users(id)`
  * `uk_memberships_tenant_user`: `UNIQUE (tenant_id, user_id)`
  * `chk_membership_status`: `CHECK (status IN ('active', 'inactive'))`
  * `chk_membership_salary_type`: `CHECK (salary_type IN ('fixed', 'hourly'))`
  * `chk_base_salary`: `CHECK (base_salary >= 0.00)`
* **Índices Físicos (B-Tree):**
  * `idx_memberships_tenant_status`: B-Tree sobre `(tenant_id, status)`
  * `idx_memberships_user_id`: B-Tree sobre `(user_id)`

### 1.7 `roles` (Roles de Seguridad RBAC)
Define perfiles de privilegios y facultades. Soporta tanto roles del sistema globales preconfigurados como roles soberanos creados por cada taller.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador del rol de autorización |
| `tenant_id` | `UUID` | FK | No | `null` | Taller propietario (`FK -> tenants(id)`, null si es rol del sistema) |
| `name` | `VARCHAR(100)` | - | Sí | - | Denominación del rol (ej. `ADMIN`, `MECHANIC`, `CASHIER`) |
| `description` | `VARCHAR(255)` | - | Sí | - | Descripción funcional de las facultades del rol |
| `is_system_role` | `BOOLEAN` | - | Sí | `false` | Indica si es un rol global inmutable de plataforma |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de creación |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de última modificación |
| `version` | `BIGINT` | - | Sí | `0` | Versión para bloqueo optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `tenants` (`tenant_id` nullable, referencia a `tenants.id` con borrado en cascada).
  * `1:N` hacia `membership_roles` (Asociación con miembros del taller).
  * `1:N` hacia `role_permissions` (Privilegios granulares asignados al rol).
  * `1:N` hacia `invitations` (Rol predeterminado asignado en invitaciones de onboarding).
* **Restricciones (Constraints):**
  * `pk_roles`: `PRIMARY KEY (id)`
  * `fk_roles_tenant_id`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE`
  * `chk_roles_tenant_or_system`: `CHECK ((is_system_role = TRUE AND tenant_id IS NULL) OR (is_system_role = FALSE AND tenant_id IS NOT NULL))`
* **Índices Físicos (B-Tree):**
  * `idx_roles_tenant_name`: B-Tree sobre `(tenant_id, name)`

### 1.8 `permissions` (Permisos Atómicos del Sistema)
Catálogo inmutable de operaciones elementales protegidas del sistema (recursos y acciones).

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador único del permiso elemental |
| `name` | `VARCHAR(100)` | UK | Sí | - | Código canónico del permiso (ej. `work_orders:create`) |
| `description` | `VARCHAR(255)` | - | Sí | - | Descripción técnica de la acción autorizada |
| `category` | `VARCHAR(50)` | - | Sí | - | Módulo funcional (ej. `iam`, `mro`, `inventory`, `hr`) |

* **Relaciones (Integridad Referencial):**
  * `1:N` hacia `role_permissions` (Un permiso se asocia a múltiples roles).
* **Restricciones (Constraints):**
  * `pk_permissions`: `PRIMARY KEY (id)`
  * `uk_permissions_name`: `UNIQUE (name)`
* **Índices Físicos (B-Tree):**
  * `idx_permissions_category`: B-Tree sobre `(category)`

### 1.9 `role_permissions` (Asignación de Privilegios a Roles)
Tabla relacional asociativa pura que materializa la relación de muchos a muchos entre roles y permisos atómicos.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `role_id` | `UUID` | PK, FK | Sí | - | Rol titular (`PK, FK -> roles(id) ON DELETE CASCADE`) |
| `permission_id` | `UUID` | PK, FK | Sí | - | Permiso otorgado (`PK, FK -> permissions(id) ON DELETE CASCADE`) |
| `granted_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal en la que se concedió el privilegio |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `roles` (`role_id` referencia a `roles.id` con eliminación en cascada).
  * `N:1` hacia `permissions` (`permission_id` referencia a `permissions.id` con eliminación en cascada).
* **Restricciones (Constraints):**
  * `pk_role_permissions`: `PRIMARY KEY (role_id, permission_id)`
  * `fk_role_permissions_role`: `FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE`
  * `fk_role_permissions_permission`: `FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE`

### 1.10 `membership_roles` (Asignación de Roles a Miembros)
Tabla relacional asociativa que adjudica perfiles de rol a las membresías institucionales de un taller.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `membership_id` | `UUID` | PK, FK | Sí | - | Membresía receptora (`PK, FK -> tenant_memberships(id) ON DELETE CASCADE`) |
| `role_id` | `UUID` | PK, FK | Sí | - | Rol asignado (`PK, FK -> roles(id) ON DELETE CASCADE`) |
| `granted_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de adjudicación del rol |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `tenant_memberships` (`membership_id` referencia a `tenant_memberships.id` con borrado en cascada).
  * `N:1` hacia `roles` (`role_id` referencia a `roles.id` con borrado en cascada).
* **Restricciones (Constraints):**
  * `pk_membership_roles`: `PRIMARY KEY (membership_id, role_id)`
  * `fk_membership_roles_membership`: `FOREIGN KEY (membership_id) REFERENCES tenant_memberships(id) ON DELETE CASCADE`
  * `fk_membership_roles_role`: `FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE`

### 1.11 `invitations` (Invitaciones de Onboarding a Nuevos Miembros)
Gestiona el ciclo de vida de incorporación de nuevos técnicos y administrativos a un taller mediante enlaces y tokens criptográficos efímeros.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador técnico de la invitación |
| `tenant_id` | `UUID` | FK | Sí | - | Taller emisor (`FK -> tenants(id) ON DELETE CASCADE`) |
| `email` | `VARCHAR(150)` | - | Sí | - | Correo electrónico de destino del colaborador invitado |
| `target_role_id` | `UUID` | FK | Sí | - | Rol predeterminado a conceder tras el registro (`FK -> roles(id)`) |
| `token` | `VARCHAR(255)` | UK | Sí | - | Token criptográfico de invitación unívoco |
| `status` | `VARCHAR(20)` | - | Sí | `'pending'` | Estado (`pending`, `accepted`, `expired`, `revoked`) |
| `expires_at` | `TIMESTAMPTZ` | - | Sí | - | Fecha y hora límite para redimir la invitación |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de emisión |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de última modificación |
| `version` | `BIGINT` | - | Sí | `0` | Versión para bloqueo optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `tenants` (`tenant_id` referencia a `tenants.id` con eliminación en cascada).
  * `N:1` hacia `roles` (`target_role_id` referencia a `roles.id`).
* **Restricciones (Constraints):**
  * `pk_invitations`: `PRIMARY KEY (id)`
  * `fk_invitations_tenant_id`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE`
  * `fk_invitations_role_id`: `FOREIGN KEY (target_role_id) REFERENCES roles(id)`
  * `uk_invitations_token`: `UNIQUE (token)`
  * `chk_invitations_status`: `CHECK (status IN ('pending', 'accepted', 'expired', 'revoked'))`
* **Índices Físicos (B-Tree):**
  * `idx_invitations_tenant_status`: B-Tree sobre `(tenant_id, status)`
  * `idx_invitations_token`: B-Tree sobre `(token)`

---

## 2. Customer and Fleet Management Context (CRM)
**Paquete Backend:** `com.andeva.atelier.platform.crm`

Administra el padrón de clientes (personas naturales y jurídicas), el parque automotor atendido, el historial legal de titularidad o tenencia vehicular y la programación de citas previas de inspección y recepción en taller.

### 2.1 `customers` (Directorio de Clientes)
Entidad raíz que custodia el padrón de clientes atendidos por cada taller automotriz, modelando tanto individuos como corporaciones o flotas comerciales.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador único del cliente |
| `tenant_id` | `UUID` | FK | Sí | - | Taller automotriz titular de la cartera (`FK -> tenants(id)`) |
| `type` | `VARCHAR(20)` | - | Sí | `'individual'` | Tipificación jurídica (`individual`, `company`) |
| `first_name` | `VARCHAR(100)` | - | No | `null` | Nombres de pila (aplica si tipo es individual) |
| `last_name` | `VARCHAR(100)` | - | No | `null` | Apellidos (aplica si tipo es individual) |
| `company_name` | `VARCHAR(150)` | - | No | `null` | Razón social corporativa (aplica si tipo es company) |
| `tax_id` | `VARCHAR(20)` | - | No | `null` | Documento de identidad fiscal (DNI, RUC, Carné Extranjería) |
| `email` | `VARCHAR(150)` | - | No | `null` | Correo electrónico para notificaciones y facturación |
| `phone` | `VARCHAR(20)` | - | No | `null` | Teléfono móvil o fijo de contacto principal |
| `status` | `VARCHAR(20)` | - | Sí | `'active'` | Estado comercial del cliente (`active`, `inactive`) |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de registro |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de última actualización |
| `version` | `BIGINT` | - | Sí | `0` | Versión para control de concurrencia optimista |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `tenants` (`tenant_id` referencia a `tenants.id`).
  * `1:N` hacia `vehicle_ownerships` (Un cliente registra historial de titularidad sobre vehículos).
  * `1:N` hacia `appointments` (Un cliente agenda citas de servicio).
  * `1:N` hacia `work_orders` en MRO (Un cliente es el titular o solicitante de órdenes de trabajo).
* **Restricciones (Constraints):**
  * `pk_customers`: `PRIMARY KEY (id)`
  * `fk_customers_tenant_id`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id)`
  * `uk_customers_tenant_tax_id`: `UNIQUE (tenant_id, tax_id)`
  * `chk_customer_type`: `CHECK (type IN ('individual', 'company'))`
  * `chk_customer_status`: `CHECK (status IN ('active', 'inactive'))`
* **Índices Físicos (B-Tree):**
  * `idx_customers_tenant_tax_id`: B-Tree sobre `(tenant_id, tax_id)`
  * `idx_customers_search`: B-Tree sobre `(tenant_id, status)`

### 2.2 `vehicles` (Parque Automotor / Activo Vehicular Universal)
Representa la unidad vehicular como un activo físico universal en el mundo real. **Decisión arquitectónica clave:** Carece de `tenant_id` propio, permitiendo que un mismo vehículo físico (identificado unívocamente por su placa nacional) conserve su identidad e historial independientemente de qué taller lo atienda.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador técnico del activo vehicular |
| `plate` | `VARCHAR(15)` | UK | Sí | - | Placa de rodaje oficial unívoca a nivel nacional |
| `vin` | `VARCHAR(17)` | - | No | `null` | Número de Identificación Vehicular (Chasis/VIN) |
| `brand` | `VARCHAR(50)` | - | Sí | - | Marca del vehículo (ej. Toyota, Hyundai, Nissan) |
| `model` | `VARCHAR(50)` | - | Sí | - | Modelo del vehículo (ej. Yaris, Tucson, Hilux) |
| `year` | `INTEGER` | - | Sí | - | Año de fabricación del automotor ($\ge 1950$) |
| `engine_type` | `VARCHAR(20)` | - | Sí | `'gasoline'` | Motorización (`gasoline`, `diesel`, `electric`, `hybrid`) |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de alta en la base de datos |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de última modificación |
| `version` | `BIGINT` | - | Sí | `0` | Versión para bloqueo optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `1:N` hacia `vehicle_ownerships` (Historial cronológico de tenencias y transferencias).
  * `1:N` hacia `appointments` (Citas de recepción técnica del vehículo).
  * `1:N` hacia `work_orders` en MRO (Órdenes de mantenimiento aplicadas al vehículo).
* **Restricciones (Constraints):**
  * `pk_vehicles`: `PRIMARY KEY (id)`
  * `uk_vehicles_plate`: `UNIQUE (plate)`
  * `chk_vehicles_engine_type`: `CHECK (engine_type IN ('gasoline', 'diesel', 'electric', 'hybrid'))`
  * `chk_vehicles_year`: `CHECK (year >= 1950)`
* **Índices Físicos (B-Tree):**
  * `idx_vehicles_plate`: B-Tree sobre `(plate)`
  * `idx_vehicles_vin`: B-Tree parcial sobre `(vin) WHERE vin IS NOT NULL`

### 2.3 `vehicle_ownerships` (Cadena de Custodia y Tenencia Vehicular)
Registra el historial cronológico de titularidad, vinculando a un cliente con un vehículo físico durante una ventana temporal delimitada.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador técnico del periodo de custodia |
| `customer_id` | `UUID` | FK | Sí | - | Cliente poseedor o propietario (`FK -> customers(id)`) |
| `vehicle_id` | `UUID` | FK | Sí | - | Vehículo custodiado (`FK -> vehicles(id)`) |
| `start_date` | `DATE` | - | Sí | `CURRENT_DATE` | Fecha de inicio de titularidad o registro |
| `end_date` | `DATE` | - | No | `null` | Fecha fin de tenencia (null indica titularidad vigente) |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de creación |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de actualización |
| `version` | `BIGINT` | - | Sí | `0` | Versión para bloqueo optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `customers` (`customer_id` referencia a `customers.id`).
  * `N:1` hacia `vehicles` (`vehicle_id` referencia a `vehicles.id`).
* **Restricciones (Constraints):**
  * `pk_vehicle_ownerships`: `PRIMARY KEY (id)`
  * `fk_ownerships_customer_id`: `FOREIGN KEY (customer_id) REFERENCES customers(id)`
  * `fk_ownerships_vehicle_id`: `FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)`
  * `chk_ownership_dates`: `CHECK (end_date IS NULL OR end_date >= start_date)`
  * `uk_vehicle_active_ownership`: `UNIQUE (vehicle_id) WHERE end_date IS NULL`
* **Índices Físicos (B-Tree):**
  * `idx_ownerships_customer`: B-Tree sobre `(customer_id)`
  * `idx_ownerships_vehicle`: B-Tree compuesto sobre `(vehicle_id, end_date)`

### 2.4 `appointments` (Agenda Técnica y Citas de Recepción)
Gestiona la programación de atenciones en patio y citas de mantenimiento preventivo y correctivo agendadas por los clientes en una sede física determinada.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador único de la cita |
| `tenant_id` | `UUID` | FK | Sí | - | Taller automotriz receptor (`FK -> tenants(id)`) |
| `branch_id` | `UUID` | FK | Sí | - | Sede física donde se realizará la inspección (`FK -> branches(id)`) |
| `customer_id` | `UUID` | FK | Sí | - | Cliente titular de la cita (`FK -> customers(id)`) |
| `vehicle_id` | `UUID` | FK | Sí | - | Vehículo a inspeccionar (`FK -> vehicles(id)`) |
| `scheduled_at` | `TIMESTAMPTZ` | - | Sí | - | Fecha y hora programada para el ingreso del vehículo |
| `estimated_duration_minutes` | `INTEGER` | - | Sí | `60` | Duración estimada de la revisión en minutos |
| `reason` | `TEXT` | - | No | `null` | Motivo de la visita o fallas descritas por el cliente |
| `status` | `VARCHAR(20)` | - | Sí | `'pending'` | Estado (`pending`, `confirmed`, `arrived`, `canceled`) |
| `cancellation_reason` | `VARCHAR(500)` | - | No | `null` | Justificación técnica o comercial en caso de anulación |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de agendamiento |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de última modificación |
| `version` | `BIGINT` | - | Sí | `0` | Versión para bloqueo optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `tenants` (`tenant_id` referencia a `tenants.id`).
  * `N:1` hacia `branches` (`branch_id` referencia a `branches.id`).
  * `N:1` hacia `customers` (`customer_id` referencia a `customers.id`).
  * `N:1` hacia `vehicles` (`vehicle_id` referencia a `vehicles.id`).
  * `1:N` hacia `work_orders` en MRO (Una cita atendida culmina en la apertura de una orden de trabajo).
* **Restricciones (Constraints):**
  * `pk_appointments`: `PRIMARY KEY (id)`
  * `fk_appointments_tenant_id`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id)`
  * `fk_appointments_branch_id`: `FOREIGN KEY (branch_id) REFERENCES branches(id)`
  * `fk_appointments_customer_id`: `FOREIGN KEY (customer_id) REFERENCES customers(id)`
  * `fk_appointments_vehicle_id`: `FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)`
  * `chk_appointment_status`: `CHECK (status IN ('pending', 'confirmed', 'arrived', 'canceled'))`
* **Índices Físicos (B-Tree):**
  * `idx_appointments_tenant_branch_date`: B-Tree sobre `(tenant_id, branch_id, scheduled_at)`
  * `idx_appointments_customer`: B-Tree sobre `(customer_id)`
  * `idx_appointments_vehicle`: B-Tree sobre `(vehicle_id)`

---

## 3. Workshop Operations Context (MRO)
**Paquete Backend:** `com.andeva.atelier.platform.mro`

El núcleo operativo de la plataforma técnica. Modela la infraestructura física del taller (bahías y elevadores), el catálogo de servicios estándar, la orquestación integral de órdenes de trabajo (OT), el peritaje inicial fotográfico, el desglose analítico de tareas en foso, la imputación de repuestos y la gestión de hallazgos sobrevenidos mediante propuestas periciales.

### 3.1 `work_bays` (Puestos Físicos y Bahías de Trabajo)
Modela los puestos de trabajo físico (elevadores hidráulicos, fosos de alineación, cabinas de pintura, bahías de lavado) disponibles en cada sede del taller.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador único de la bahía física |
| `tenant_id` | `UUID` | FK | Sí | - | Taller propietario (`FK -> tenants(id)`) |
| `branch_id` | `UUID` | FK | Sí | - | Sede física donde se encuentra la bahía (`FK -> branches(id)`) |
| `name` | `VARCHAR(50)` | - | Sí | - | Nombre o etiqueta (ej. "Elevador Hidráulico 1") |
| `type` | `VARCHAR(20)` | - | Sí | `'lift'` | Tipo (`lift`, `paint_booth`, `washing`, `alignment`) |
| `status` | `VARCHAR(20)` | - | Sí | `'available'` | Estado operativo (`available`, `occupied`, `maintenance`) |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de alta |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de modificación |
| `version` | `BIGINT` | - | Sí | `0` | Versión para bloqueo optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `tenants` (`tenant_id` referencia a `tenants.id`).
  * `N:1` hacia `branches` (`branch_id` referencia a `branches.id`).
  * `1:N` hacia `work_orders` (Una bahía alberga físicamente a órdenes en ejecución).
* **Restricciones (Constraints):**
  * `pk_work_bays`: `PRIMARY KEY (id)`
  * `fk_work_bays_tenant_id`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id)`
  * `fk_work_bays_branch_id`: `FOREIGN KEY (branch_id) REFERENCES branches(id)`
  * `chk_bay_type`: `CHECK (type IN ('lift', 'paint_booth', 'washing', 'alignment'))`
  * `chk_bay_status`: `CHECK (status IN ('available', 'occupied', 'maintenance'))`
* **Índices Físicos (B-Tree):**
  * `idx_work_bays_tenant_branch`: B-Tree sobre `(tenant_id, branch_id)`
  * `idx_work_bays_status`: B-Tree sobre `(tenant_id, status)`

### 3.2 `services` (Catálogo de Servicios Estándar)
Catálogo tarifario de mano de obra y mantenimientos estándar configurados por el taller.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador técnico del servicio |
| `tenant_id` | `UUID` | FK | Sí | - | Taller titular del catálogo (`FK -> tenants(id)`) |
| `name` | `VARCHAR(150)` | - | Sí | - | Nombre comercial del servicio (ej. "Alineación Láser 3D") |
| `base_price` | `DECIMAL(10,2)` | - | Sí | `0.00` | Tarifa base recomendada de mano de obra |
| `estimated_time_m` | `INTEGER` | - | Sí | `60` | Tiempo estándar de ejecución en minutos |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de creación |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de última actualización |
| `version` | `BIGINT` | - | Sí | `0` | Versión para bloqueo optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `tenants` (`tenant_id` referencia a `tenants.id`).
  * `1:N` hacia `work_order_tasks` (Instanciación del servicio en tareas operativas).
  * `1:N` hacia `task_proposals` (Servicios recomendados en venta cruzada o reparaciones).
* **Restricciones (Constraints):**
  * `pk_services`: `PRIMARY KEY (id)`
  * `fk_services_tenant_id`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id)`
  * `uk_services_tenant_name`: `UNIQUE (tenant_id, name)`
  * `chk_services_base_price`: `CHECK (base_price >= 0.00)`
  * `chk_services_estimated_time`: `CHECK (estimated_time_m > 0)`
* **Índices Físicos (B-Tree):**
  * `idx_services_tenant_name`: B-Tree sobre `(tenant_id, name)`

### 3.3 `work_orders` (Órdenes de Trabajo y Mantenimiento)
Raíz de agregado principal del contexto MRO. Custodia el ciclo de vida completo de la atención automotriz, desde el ingreso en patio hasta la liquidación final.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador único de la orden de trabajo |
| `tenant_id` | `UUID` | FK | Sí | - | Taller automotriz emisor (`FK -> tenants(id)`) |
| `branch_id` | `UUID` | FK | Sí | - | Sede física donde se atiende el vehículo (`FK -> branches(id)`) |
| `appointment_id` | `UUID` | FK | No | `null` | Cita de origen si fue agendada previamente (`FK -> appointments(id)`) |
| `vehicle_id` | `UUID` | FK | Sí | - | Vehículo intervenido (`FK -> vehicles(id)`) |
| `customer_id` | `UUID` | FK | Sí | - | Cliente titular o solicitante (`FK -> customers(id)`) |
| `internal_number` | `INTEGER` | - | Sí | - | Correlativo secuencial interno por taller |
| `current_bay_id` | `UUID` | FK | No | `null` | Bahía física donde está ubicado el auto (`FK -> work_bays(id)`) |
| `mileage_in` | `INTEGER` | - | Sí | `0` | Kilometraje registrado en odómetro al ingresar |
| `diagnostic_summary` | `TEXT` | - | Sí | - | Síntomas descritos por cliente y diagnóstico pericial |
| `subtotal` | `DECIMAL(10,2)` | - | Sí | `0.00` | Subtotal acumulado de tareas y repuestos |
| `tax` | `DECIMAL(10,2)` | - | Sí | `0.00` | Impuesto liquidado (IGV 18%) |
| `total_amount` | `DECIMAL(10,2)` | - | Sí | `0.00` | Importe total liquidado de la orden |
| `status` | `VARCHAR(20)` | - | Sí | `'draft'` | Estado (`draft`, `in_progress`, `completed`, `paid`, `canceled`) |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de apertura |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de última modificación |
| `version` | `BIGINT` | - | Sí | `0` | Versión para bloqueo optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `tenants` (`tenant_id` referencia a `tenants.id`).
  * `N:1` hacia `branches` (`branch_id` referencia a `branches.id`).
  * `N:1` hacia `appointments` (`appointment_id` referencia a `appointments.id`).
  * `N:1` hacia `vehicles` (`vehicle_id` referencia a `vehicles.id`).
  * `N:1` hacia `customers` (`customer_id` referencia a `customers.id`).
  * `N:1` hacia `work_bays` (`current_bay_id` referencia a `work_bays.id`).
  * `1:N` hacia `work_order_images` (Fotografías de recepción inicial del auto).
  * `1:N` hacia `work_order_tasks` (Desglose de tareas mecánicas).
  * `1:N` hacia `task_proposals` (Hallazgos sobrevenidos de foso).
* **Restricciones (Constraints):**
  * `pk_work_orders`: `PRIMARY KEY (id)`
  * `fk_work_orders_tenant_id`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id)`
  * `fk_work_orders_branch_id`: `FOREIGN KEY (branch_id) REFERENCES branches(id)`
  * `fk_work_orders_appointment_id`: `FOREIGN KEY (appointment_id) REFERENCES appointments(id)`
  * `fk_work_orders_vehicle_id`: `FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)`
  * `fk_work_orders_customer_id`: `FOREIGN KEY (customer_id) REFERENCES customers(id)`
  * `fk_work_orders_current_bay_id`: `FOREIGN KEY (current_bay_id) REFERENCES work_bays(id)`
  * `uk_work_orders_tenant_number`: `UNIQUE (tenant_id, internal_number)`
  * `chk_work_order_status`: `CHECK (status IN ('draft', 'in_progress', 'completed', 'paid', 'canceled'))`
* **Índices Físicos (B-Tree):**
  * `idx_work_orders_tenant_branch_status`: B-Tree sobre `(tenant_id, branch_id, status)`
  * `idx_work_orders_vehicle`: B-Tree sobre `(vehicle_id)`
  * `idx_work_orders_customer`: B-Tree sobre `(customer_id)`
  * `idx_work_orders_current_bay`: B-Tree parcial sobre `(current_bay_id) WHERE current_bay_id IS NOT NULL`

### 3.4 `work_order_images` (Peritaje Gráfico de Recepción)
Almacena evidencias visuales y peritajes de daños preexistentes en carrocería registrados en el patio de maniobras durante la recepción del vehículo.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador de la fotografía de recepción |
| `work_order_id` | `UUID` | FK | Sí | - | Orden de trabajo vinculada (`FK -> work_orders(id)`) |
| `image_url` | `VARCHAR(255)` | - | Sí | - | URL segura en Cloud Storage / Firebase Storage |
| `description` | `VARCHAR(200)` | - | No | `null` | Glosa o detalle del desperfecto visual detectado |
| `uploaded_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de captura y subida en patio |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de registro |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de modificación |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `work_orders` (`work_order_id` referencia a `work_orders.id`).
* **Restricciones (Constraints):**
  * `pk_work_order_images`: `PRIMARY KEY (id)`
  * `fk_work_order_images_work_order_id`: `FOREIGN KEY (work_order_id) REFERENCES work_orders(id)`
* **Índices Físicos (B-Tree):**
  * `idx_images_work_order`: B-Tree sobre `(work_order_id)`

### 3.5 `work_order_tasks` (Tareas Técnicas Desglosadas)
Representa cada labor técnica elemental o servicio específico que compone una orden de trabajo, orquestando tiempos, pausas, mecánicos asignados y costos de mano de obra.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador de la tarea técnica |
| `work_order_id` | `UUID` | FK | Sí | - | Orden de trabajo contenedora (`FK -> work_orders(id)`) |
| `service_id` | `UUID` | FK | Sí | - | Servicio instanciado (`FK -> services(id)`) |
| `mechanic_id` | `UUID` | FK | No | `null` | Mecánico responsable asignado (`FK -> tenant_memberships(id)`) |
| `status` | `VARCHAR(20)` | - | Sí | `'pending'` | Estado (`pending`, `assigned`, `in_progress`, `on_hold`, `completed`, `cancelled`) |
| `description` | `TEXT` | - | Sí | - | Instrucciones técnicas y alcance de la faena |
| `price` | `DECIMAL(10,2)` | - | Sí | `0.00` | Precio liquidado de mano de obra |
| `estimated_hours` | `DECIMAL(4,2)` | - | Sí | `1.00` | Horas presupuestadas para la tarea |
| `actual_hours` | `DECIMAL(4,2)` | - | No | `null` | Horas reales de trabajo efectivo cronometradas |
| `hold_reason` | `VARCHAR(50)` | - | No | `null` | Causa de suspensión (`waiting_parts`, null si activa) |
| `missing_item_description` | `TEXT` | - | No | `null` | Repuesto faltante solicitado a almacén |
| `paused_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal del inicio de la pausa actual |
| `total_paused_seconds` | `BIGINT` | - | Sí | `0` | Segundos acumulados en estado suspendido |
| `started_at` | `TIMESTAMPTZ` | - | No | `null` | Momento de inicio efectivo de la labor |
| `completed_at` | `TIMESTAMPTZ` | - | No | `null` | Momento de culminación de la labor |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de creación |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de actualización |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `work_orders` (`work_order_id` referencia a `work_orders.id`).
  * `N:1` hacia `services` (`service_id` referencia a `services.id`).
  * `N:1` hacia `tenant_memberships` (`mechanic_id` referencia a `tenant_memberships.id`).
  * `1:N` hacia `work_order_task_products` (Repuestos consumidos o imputados en la tarea).
  * `1:N` hacia `work_order_task_images` (Evidencias probatorias de ejecución en foso).
  * `1:N` hacia `task_proposals` (Hallazgos adicionales derivados de esta tarea).
* **Restricciones (Constraints):**
  * `pk_work_order_tasks`: `PRIMARY KEY (id)`
  * `fk_work_order_tasks_work_order_id`: `FOREIGN KEY (work_order_id) REFERENCES work_orders(id)`
  * `fk_work_order_tasks_service_id`: `FOREIGN KEY (service_id) REFERENCES services(id)`
  * `fk_work_order_tasks_mechanic_id`: `FOREIGN KEY (mechanic_id) REFERENCES tenant_memberships(id)`
  * `chk_task_status`: `CHECK (status IN ('pending', 'assigned', 'in_progress', 'on_hold', 'completed', 'cancelled'))`
  * `chk_hold_reason`: `CHECK (hold_reason IS NULL OR hold_reason = 'waiting_parts')`
* **Índices Físicos (B-Tree):**
  * `idx_tasks_work_order`: B-Tree sobre `(work_order_id)`
  * `idx_tasks_mechanic_status`: B-Tree sobre `(mechanic_id, status)`

### 3.6 `work_order_task_products` (Imputación de Repuestos a Tareas)
Materializa el consumo e instalación real de piezas, fluidos y repuestos procedentes del almacén en una tarea mecánica determinada.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador de la línea de repuesto imputado |
| `task_id` | `UUID` | FK | Sí | - | Tarea mecánica donde se monta la pieza (`FK -> work_order_tasks(id)`) |
| `product_id` | `UUID` | FK | Sí | - | Repuesto extraído de almacén (`FK -> inventory_items(id)`) |
| `quantity` | `DECIMAL(10,2)` | - | Sí | `1.00` | Cantidad instalada o litros consumidos |
| `unit_price` | `DECIMAL(10,2)` | - | Sí | `0.00` | Precio unitario facturado al cliente |
| `total_amount` | `DECIMAL(10,2)` | - | Sí | `0.00` | Importe total liquidado de la línea (`quantity * unit_price`) |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de imputación |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de actualización |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `work_order_tasks` (`task_id` referencia a `work_order_tasks.id`).
  * `N:1` hacia `inventory_items` (`product_id` referencia a `inventory_items.id`).
* **Restricciones (Constraints):**
  * `pk_work_order_task_products`: `PRIMARY KEY (id)`
  * `fk_work_order_task_products_task_id`: `FOREIGN KEY (task_id) REFERENCES work_order_tasks(id)`
  * `fk_work_order_task_products_product_id`: `FOREIGN KEY (product_id) REFERENCES inventory_items(id)`
  * `chk_task_products_quantity`: `CHECK (quantity > 0.00)`
  * `chk_task_products_total`: `CHECK (total_amount >= 0.00)`
* **Índices Físicos (B-Tree):**
  * `idx_task_products_task`: B-Tree sobre `(task_id)`
  * `idx_task_products_product`: B-Tree sobre `(product_id)`

### 3.7 `work_order_task_images` (Evidencias Probatorias en Foso)
Almacena el registro gráfico del estado de las piezas antes, durante y después de la intervención mecánica, garantizando transparencia probatoria ante el cliente.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador de la evidencia gráfica en foso |
| `task_id` | `UUID` | FK | Sí | - | Tarea a la que corresponde la evidencia (`FK -> work_order_tasks(id)`) |
| `image_url` | `VARCHAR(255)` | - | Sí | - | Enlace HTTPS en Cloud Storage / Firebase Storage |
| `evidence_type` | `VARCHAR(30)` | - | Sí | - | Hito probatorio (`initial_inspection`, `defect`, `in_progress`, `completed`) |
| `description` | `VARCHAR(200)` | - | No | `null` | Glosa o descripción técnica del estado visual |
| `uploaded_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Momento en que fue sincronizada a la nube |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de creación |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de actualización |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `work_order_tasks` (`task_id` referencia a `work_order_tasks.id`).
* **Restricciones (Constraints):**
  * `pk_work_order_task_images`: `PRIMARY KEY (id)`
  * `fk_work_order_task_images_task_id`: `FOREIGN KEY (task_id) REFERENCES work_order_tasks(id)`
  * `chk_evidence_type`: `CHECK (evidence_type IN ('initial_inspection', 'defect', 'in_progress', 'completed'))`
* **Índices Físicos (B-Tree):**
  * `idx_task_images_task`: B-Tree sobre `(task_id)`

### 3.8 `task_proposals` (Propuestas Periciales y Hallazgos Ocultos)
Captura fallas ocultas, fugas o desgaste severo detectado por los mecánicos durante el desmontaje. Notifica instantáneamente al cliente para su aprobación o rechazo en línea.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador único de la propuesta técnica |
| `work_order_id` | `UUID` | FK | Sí | - | Orden de trabajo vehicular vinculada (`FK -> work_orders(id)`) |
| `task_id` | `UUID` | FK | No | `null` | Tarea en curso durante la cual se halló el fallo (`FK -> work_order_tasks(id)`) |
| `service_id` | `UUID` | FK | No | `null` | Servicio recomendado a adicionar (`FK -> services(id)`) |
| `mechanic_id` | `UUID` | FK | Sí | - | Mecánico que descubrió el defecto (`FK -> tenant_memberships(id)`) |
| `description` | `TEXT` | - | Sí | - | Diagnóstico detallado del componente dañado |
| `severity` | `VARCHAR(20)` | - | Sí | `'medium'` | Nivel de urgencia (`low`, `medium`, `critical`) |
| `image_url` | `VARCHAR(255)` | - | Sí | - | Fotografía probatoria del desgaste o rotura |
| `status` | `VARCHAR(20)` | - | Sí | `'pending_review'` | Decisión del cliente (`pending_review`, `approved`, `rejected`) |
| `customer_notes` | `VARCHAR(500)` | - | No | `null` | Comentarios u objeciones del propietario |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de la propuesta |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de resolución del cliente |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `work_orders` (`work_order_id` referencia a `work_orders.id`).
  * `N:1` hacia `work_order_tasks` (`task_id` referencia a `work_order_tasks.id`).
  * `N:1` hacia `services` (`service_id` referencia a `services.id`).
  * `N:1` hacia `tenant_memberships` (`mechanic_id` referencia a `tenant_memberships.id`).
* **Restricciones (Constraints):**
  * `pk_task_proposals`: `PRIMARY KEY (id)`
  * `fk_task_proposals_work_order_id`: `FOREIGN KEY (work_order_id) REFERENCES work_orders(id)`
  * `fk_task_proposals_task_id`: `FOREIGN KEY (task_id) REFERENCES work_order_tasks(id)`
  * `fk_task_proposals_service_id`: `FOREIGN KEY (service_id) REFERENCES services(id)`
  * `fk_task_proposals_mechanic_id`: `FOREIGN KEY (mechanic_id) REFERENCES tenant_memberships(id)`
  * `chk_proposal_severity`: `CHECK (severity IN ('low', 'medium', 'critical'))`
  * `chk_proposal_status`: `CHECK (status IN ('pending_review', 'approved', 'rejected'))`
* **Índices Físicos (B-Tree):**
  * `idx_proposals_work_order`: B-Tree sobre `(work_order_id)`
  * `idx_proposals_status`: B-Tree sobre `(status)`

---

## 4. Inventory and Supply Chain Context
**Paquete Backend:** `com.andeva.atelier.platform.inventory`

Gobierna la administración del catálogo de repuestos e insumos automotrices, la trazabilidad física y contable mediante el algoritmo FIFO (First-In, First-Out) por lotes de adquisición, el directorio homologado de proveedores y el ciclo de abastecimiento mediante órdenes de compra multi-producto.

### 4.1 `inventory_items` (Catálogo de Repuestos e Insumos de Almacén)
Raíz de agregado del catálogo de existencias. Custodia las especificaciones del artículo, niveles de stock consolidado y umbrales mínimos para reabastecimiento.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador técnico del artículo |
| `tenant_id` | `UUID` | FK | Sí | - | Taller automotriz titular del inventario (`FK -> tenants(id)`) |
| `name` | `VARCHAR(150)` | - | Sí | - | Denominación comercial del repuesto o fluido |
| `sku` | `VARCHAR(50)` | - | Sí | - | Código de referencia de almacén (unívoco por taller) |
| `category` | `VARCHAR(50)` | - | Sí | - | Familia automotriz (ej. Frenos, Filtros, Lubricantes) |
| `base_price` | `DECIMAL(10,2)` | - | Sí | `0.00` | Precio sugerido de venta al público |
| `total_stock` | `DECIMAL(10,2)` | - | Sí | `0.00` | Saldo físico consolidado disponible en almacén |
| `minimum_stock` | `DECIMAL(10,2)` | - | Sí | `0.00` | Umbral crítico de reposición para alertas de quiebre |
| `status` | `VARCHAR(20)` | - | Sí | `'active'` | Estado operativo (`active`, `inactive`, `discontinued`) |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de creación |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de última modificación |
| `version` | `BIGINT` | - | Sí | `0` | Versión para bloqueo optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `tenants` (`tenant_id` referencia a `tenants.id`).
  * `1:N` hacia `inventory_batches` (Un artículo posee múltiples lotes físicos cronológicos).
  * `1:N` hacia `purchase_order_items` (Un artículo figura en líneas de órdenes de compra).
  * `1:N` hacia `work_order_task_products` en MRO (Un artículo es instalado en tareas de reparación).
* **Restricciones (Constraints):**
  * `pk_inventory_items`: `PRIMARY KEY (id)`
  * `fk_inventory_items_tenant_id`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id)`
  * `uk_inventory_items_tenant_sku`: `UNIQUE (tenant_id, sku)`
  * `chk_inventory_items_status`: `CHECK (status IN ('active', 'inactive', 'discontinued'))`
  * `chk_inventory_items_stock`: `CHECK (total_stock >= 0.00)`
  * `chk_inventory_items_min_stock`: `CHECK (minimum_stock >= 0.00)`
  * `chk_inventory_items_price`: `CHECK (base_price >= 0.00)`
* **Índices Físicos (B-Tree):**
  * `idx_inventory_items_tenant_sku`: B-Tree sobre `(tenant_id, sku)`
  * `idx_inventory_items_category`: B-Tree sobre `(tenant_id, category)`
  * `idx_inventory_items_low_stock`: B-Tree parcial sobre `(tenant_id, total_stock) WHERE total_stock <= minimum_stock`

### 4.2 `inventory_batches` (Lotes Físicos de Adquisición FIFO)
Representa cada lote físico de ingreso al almacén. Base matemática indispensable para el cálculo determinista del Costo de Ventas bajo la regla contable FIFO.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador del lote de inventario |
| `tenant_id` | `UUID` | FK | Sí | - | Taller automotriz titular (`FK -> tenants(id)`) |
| `item_id` | `UUID` | FK | Sí | - | Repuesto al que pertenece el lote (`FK -> inventory_items(id)`) |
| `supplier_id` | `UUID` | FK | No | `null` | Distribuidor proveedor (`FK -> suppliers(id)`) |
| `purchase_order_id` | `UUID` | FK | No | `null` | Orden de compra que originó el lote (`FK -> purchase_orders(id)`) |
| `batch_number` | `VARCHAR(50)` | - | Sí | - | Número de lote del fabricante o código interno |
| `receipt_image_url` | `VARCHAR(255)` | - | No | `null` | URL en Cloud Storage de la factura o guía de remisión física |
| `initial_qty` | `DECIMAL(10,2)` | - | Sí | - | Cantidad física ingresada inicialmente |
| `remaining_qty` | `DECIMAL(10,2)` | - | Sí | - | Saldo de piezas remanentes aún disponibles para consumo |
| `unit_cost` | `DECIMAL(10,2)` | - | Sí | - | Costo unitario neto real de adquisición |
| `arrival_date` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Fecha y hora de arribo físico (criterio de ordenación FIFO) |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de creación |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de actualización |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `tenants` (`tenant_id` referencia a `tenants.id`).
  * `N:1` hacia `inventory_items` (`item_id` referencia a `inventory_items.id`).
  * `N:1` hacia `suppliers` (`supplier_id` referencia a `suppliers.id`).
  * `N:1` hacia `purchase_orders` (`purchase_order_id` referencia a `purchase_orders.id`).
* **Restricciones (Constraints):**
  * `pk_inventory_batches`: `PRIMARY KEY (id)`
  * `fk_inventory_batches_tenant_id`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id)`
  * `fk_inventory_batches_item_id`: `FOREIGN KEY (item_id) REFERENCES inventory_items(id)`
  * `fk_inventory_batches_supplier_id`: `FOREIGN KEY (supplier_id) REFERENCES suppliers(id)`
  * `fk_inventory_batches_purchase_order_id`: `FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id)`
  * `chk_batches_remaining_qty`: `CHECK (remaining_qty >= 0.00)`
  * `chk_batches_initial_qty`: `CHECK (initial_qty > 0.00)`
  * `chk_batches_unit_cost`: `CHECK (unit_cost >= 0.00)`
  * `chk_batches_remaining_le_initial`: `CHECK (remaining_qty <= initial_qty)`
* **Índices Físicos (B-Tree):**
  * `idx_inventory_batches_item_fifo`: B-Tree parcial indexado sobre `(item_id, arrival_date ASC) WHERE remaining_qty > 0.00`
  * `idx_inventory_batches_tenant`: B-Tree sobre `(tenant_id)`
  * `idx_inventory_batches_po`: B-Tree sobre `(purchase_order_id)`
  * `idx_inventory_batches_supplier`: B-Tree sobre `(supplier_id)`

### 4.3 `suppliers` (Directorio Homologado de Proveedores)
Padrón de proveedores, mayoristas e importadores de repuestos automotrices homologados por el taller.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador único del proveedor |
| `tenant_id` | `UUID` | FK | Sí | - | Taller automotriz cliente (`FK -> tenants(id)`) |
| `business_name` | `VARCHAR(150)` | - | Sí | - | Razón social comercial del distribuidor |
| `tax_id` | `VARCHAR(20)` | - | Sí | - | RUC o identificación tributaria (unívoco por taller) |
| `contact_name` | `VARCHAR(100)` | - | No | `null` | Nombre del asesor comercial o ejecutivo de cuenta |
| `phone` | `VARCHAR(20)` | - | No | `null` | Teléfono de contacto comercial |
| `email` | `VARCHAR(150)` | - | No | `null` | Correo electrónico para cotizaciones y pedidos |
| `address` | `VARCHAR(200)` | - | No | `null` | Domicilio fiscal o dirección de almacén central |
| `is_active` | `BOOLEAN` | - | Sí | `true` | Bandera de homologación comercial activa |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de alta |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de actualización |
| `version` | `BIGINT` | - | Sí | `0` | Versión para bloqueo optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `tenants` (`tenant_id` referencia a `tenants.id`).
  * `1:N` hacia `purchase_orders` (Un proveedor recibe órdenes de compra del taller).
  * `1:N` hacia `inventory_batches` (Un proveedor provee lotes físicos adquiridos).
* **Restricciones (Constraints):**
  * `pk_suppliers`: `PRIMARY KEY (id)`
  * `fk_suppliers_tenant_id`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id)`
  * `uk_suppliers_tenant_tax_id`: `UNIQUE (tenant_id, tax_id)`
* **Índices Físicos (B-Tree):**
  * `idx_suppliers_tenant_tax_id`: B-Tree sobre `(tenant_id, tax_id)`
  * `idx_suppliers_tenant_business_name`: B-Tree sobre `(tenant_id, business_name)`

### 4.4 `purchase_orders` (Órdenes de Compra y Abastecimiento)
Gestiona la adquisición planificada de lotes de repuestos y suministros para abastecer los almacenes del taller.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador de la orden de compra |
| `tenant_id` | `UUID` | FK | Sí | - | Taller automotriz emisor (`FK -> tenants(id)`) |
| `supplier_id` | `UUID` | FK | Sí | - | Proveedor adjudicado (`FK -> suppliers(id)`) |
| `branch_id` | `UUID` | FK | Sí | - | Sede física que recibirá el despacho (`FK -> branches(id)`) |
| `order_number` | `VARCHAR(50)` | - | Sí | - | Número de orden correlativo (unívoco por taller) |
| `status` | `VARCHAR(20)` | - | Sí | `'draft'` | Estado (`draft`, `issued`, `received`, `canceled`) |
| `total_cost` | `DECIMAL(10,2)` | - | Sí | `0.00` | Costo total consolidado de la adquisición |
| `receipt_image_url` | `VARCHAR(255)` | - | No | `null` | Factura física o guía de remisión escaneada en Cloud Storage |
| `receipt_number` | `VARCHAR(50)` | - | No | `null` | Número de comprobante físico emitido por el proveedor |
| `received_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal de recepción y descargo en almacén |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de emisión |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de última actualización |
| `version` | `BIGINT` | - | Sí | `0` | Versión para bloqueo optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `tenants` (`tenant_id` referencia a `tenants.id`).
  * `N:1` hacia `suppliers` (`supplier_id` referencia a `suppliers.id`).
  * `N:1` hacia `branches` (`branch_id` referencia a `branches.id`).
  * `1:N` hacia `purchase_order_items` (Líneas de repuestos adquiridos).
  * `1:N` hacia `inventory_batches` (Lotes generados automáticamente tras la recepción).
* **Restricciones (Constraints):**
  * `pk_purchase_orders`: `PRIMARY KEY (id)`
  * `fk_purchase_orders_tenant_id`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id)`
  * `fk_purchase_orders_supplier_id`: `FOREIGN KEY (supplier_id) REFERENCES suppliers(id)`
  * `fk_purchase_orders_branch_id`: `FOREIGN KEY (branch_id) REFERENCES branches(id)`
  * `uk_purchase_orders_tenant_number`: `UNIQUE (tenant_id, order_number)`
  * `chk_purchase_order_status`: `CHECK (status IN ('draft', 'issued', 'received', 'canceled'))`
  * `chk_purchase_order_total`: `CHECK (total_cost >= 0.00)`
* **Índices Físicos (B-Tree):**
  * `idx_purchase_orders_tenant_status`: B-Tree sobre `(tenant_id, status)`
  * `idx_purchase_orders_supplier`: B-Tree sobre `(supplier_id)`
  * `idx_purchase_orders_branch`: B-Tree sobre `(branch_id)`

### 4.5 `purchase_order_items` (Líneas de Detalle de Órdenes de Compra)
Detalle analítico de cantidades y costos acordados para cada repuesto en una orden de compra.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador del renglón de compra |
| `purchase_order_id` | `UUID` | FK | Sí | - | Orden de compra vinculada (`FK -> purchase_orders(id)`) |
| `item_id` | `UUID` | FK | Sí | - | Repuesto solicitado (`FK -> inventory_items(id)`) |
| `quantity` | `DECIMAL(10,2)` | - | Sí | `1.00` | Cantidad de piezas solicitadas |
| `unit_cost` | `DECIMAL(10,2)` | - | Sí | `0.00` | Costo unitario acordado |
| `total_cost` | `DECIMAL(10,2)` | - | Sí | `0.00` | Costo de la línea (`quantity * unit_cost`) |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de creación |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de actualización |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `purchase_orders` (`purchase_order_id` referencia a `purchase_orders.id`).
  * `N:1` hacia `inventory_items` (`item_id` referencia a `inventory_items.id`).
* **Restricciones (Constraints):**
  * `pk_purchase_order_items`: `PRIMARY KEY (id)`
  * `fk_po_items_order_id`: `FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id)`
  * `fk_po_items_item_id`: `FOREIGN KEY (item_id) REFERENCES inventory_items(id)`
  * `chk_po_items_quantity`: `CHECK (quantity > 0.00)`
  * `chk_po_items_unit_cost`: `CHECK (unit_cost >= 0.00)`
  * `chk_po_items_total_cost`: `CHECK (total_cost >= 0.00)`
* **Índices Físicos (B-Tree):**
  * `idx_po_items_order`: B-Tree sobre `(purchase_order_id)`
  * `idx_po_items_item`: B-Tree sobre `(item_id)`

---

## 5. Human Resources Management Context (HR)
**Paquete Backend:** `com.andeva.atelier.platform.hr`

Gobierna la gestión de expedientes laborales de colaboradores, la definición de turnos y franjas horarias con márgenes de tolerancia, el control inalterable de asistencia física mediante geocercas satelitales en alta precisión y la consolidación de planillas salariales periódicas con desglose de bonificaciones y penalizaciones por tardanzas.

### 5.1 `work_shifts` (Turnos Laborales y Franjas Horarias)
Catálogo maestro de jornadas y turnos de trabajo configurados por el taller. Establece horarios de apertura, cierre y márgenes de gracia en minutos.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador técnico del turno |
| `tenant_id` | `UUID` | FK | Sí | - | Taller automotriz empleador (`FK -> tenants(id)`) |
| `name` | `VARCHAR(50)` | - | Sí | - | Denominación del turno (ej. "Turno Central Taller", "Guardia Sábados") |
| `start_time` | `TIME` | - | Sí | - | Hora programada de inicio de labores |
| `end_time` | `TIME` | - | Sí | - | Hora programada de salida de labores |
| `grace_period_m` | `INTEGER` | - | Sí | `15` | Tolerancia en minutos antes de computar tardanza ($0 \le m \le 60$) |
| `is_active` | `BOOLEAN` | - | Sí | `true` | Bandera de vigencia operativa del turno |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de registro |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de modificación |
| `version` | `BIGINT` | - | Sí | `0` | Versión para control de concurrencia optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `tenants` (`tenant_id` referencia a `tenants.id`).
  * `1:N` hacia `employee_profiles` (Turno predeterminado asignado al personal).
  * `1:N` hacia `attendance_records` (Turno contrastado contra cada marcación).
* **Restricciones (Constraints):**
  * `pk_work_shifts`: `PRIMARY KEY (id)`
  * `fk_work_shifts_tenant_id`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id)`
  * `uk_work_shifts_tenant_name`: `UNIQUE (tenant_id, name)`
  * `chk_shift_grace_period`: `CHECK (grace_period_m >= 0 AND grace_period_m <= 60)`
* **Índices Físicos (B-Tree):**
  * `idx_work_shifts_tenant_name`: B-Tree sobre `(tenant_id, name)`
  * `idx_work_shifts_active`: B-Tree sobre `(tenant_id, is_active)`

### 5.2 `employee_profiles` (Expedientes Laborales de Colaboradores)
Custodia la ficha laboral y contractual del personal del taller. Mantiene la soberanía del expediente dentro de HR vinculándose a la membresía de IAM sin violar fronteras de contexto.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador del expediente del empleado |
| `tenant_id` | `UUID` | FK | Sí | - | Taller automotriz empleador (`FK -> tenants(id)`) |
| `branch_id` | `UUID` | FK | Sí | - | Sede física de adscripción habitual (`FK -> branches(id)`) |
| `membership_id` | `UUID` | FK, UK | Sí | - | Membresía contractual en IAM (`FK, UK -> tenant_memberships(id)`) |
| `assigned_shift_id` | `UUID` | FK | No | `null` | Turno habitual asignado (`FK -> work_shifts(id)`) |
| `base_salary` | `NUMERIC(10,2)` | - | Sí | `0.00` | Salario base contractual pactado |
| `currency` | `VARCHAR(3)` | - | Sí | `'PEN'` | Código ISO 4217 de la moneda de pago (`PEN`, `USD`) |
| `salary_type` | `VARCHAR(20)` | - | Sí | `'monthly_fixed'` | Modalidad de compensación (`monthly_fixed`, `hourly_rate`) |
| `job_title` | `VARCHAR(100)` | - | Sí | - | Cargo laboral (ej. "Mecánico Especialista en Diagnóstico") |
| `employment_status` | `VARCHAR(20)` | - | Sí | `'active'` | Situación laboral (`active`, `on_leave`, `terminated`) |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de alta |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de última modificación |
| `version` | `BIGINT` | - | Sí | `0` | Versión para bloqueo optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para cese de contrato (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `tenants` (`tenant_id` referencia a `tenants.id`).
  * `N:1` hacia `branches` (`branch_id` referencia a `branches.id`).
  * `1:1` hacia `tenant_memberships` (`membership_id` referencia unívocamente a `tenant_memberships.id`).
  * `N:1` hacia `work_shifts` (`assigned_shift_id` referencia a `work_shifts.id`).
* **Restricciones (Constraints):**
  * `pk_employee_profiles`: `PRIMARY KEY (id)`
  * `fk_employee_tenant_id`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id)`
  * `fk_employee_branch_id`: `FOREIGN KEY (branch_id) REFERENCES branches(id)`
  * `fk_employee_membership_id`: `FOREIGN KEY (membership_id) REFERENCES tenant_memberships(id)`
  * `fk_employee_shift_id`: `FOREIGN KEY (assigned_shift_id) REFERENCES work_shifts(id)`
  * `uk_employee_profiles_membership`: `UNIQUE (membership_id)`
  * `chk_employee_salary_type`: `CHECK (salary_type IN ('monthly_fixed', 'hourly_rate'))`
  * `chk_employee_employment_status`: `CHECK (employment_status IN ('active', 'on_leave', 'terminated'))`
* **Índices Físicos (B-Tree):**
  * `idx_employee_profiles_branch`: B-Tree sobre `(branch_id)`
  * `idx_employee_profiles_membership`: B-Tree sobre `(membership_id)`
  * `idx_employee_profiles_tenant_status`: B-Tree sobre `(tenant_id, employment_status)`

### 5.3 `attendance_records` (Registro y Marcación de Asistencia Presencial)
Registro probatorio inmutable de la presencia física de los técnicos en el taller. Compara la posición GPS reportada contra la sede física mediante la distancia esférica de Haversine.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador del marcaje de asistencia |
| `tenant_id` | `UUID` | FK | Sí | - | Taller empleador (`FK -> tenants(id)`) |
| `branch_id` | `UUID` | FK | Sí | - | Sede física donde se efectúa el marcaje (`FK -> branches(id)`) |
| `membership_id` | `UUID` | FK | Sí | - | Colaborador que marca presencia (`FK -> tenant_memberships(id)`) |
| `shift_id` | `UUID` | FK | Sí | - | Turno programado evaluado (`FK -> work_shifts(id)`) |
| `clock_in` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal UTC exacta de entrada |
| `clock_out` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal UTC de salida (null mientras labore) |
| `status` | `VARCHAR(20)` | - | Sí | `'on_time'` | Calificación (`on_time`, `late`, `excused`, `absent`) |
| `latitude` | `NUMERIC(10,8)` | - | Sí | - | Latitud satelital al momento de la marcación |
| `longitude` | `NUMERIC(11,8)` | - | Sí | - | Longitud satelital al momento de la marcación |
| `distance_to_branch_m` | `INTEGER` | - | Sí | `0` | Distancia calculada en metros al centroide del taller |
| `justification_reason` | `VARCHAR(255)` | - | No | `null` | Motivo de tardanza o descargo emitido por el técnico |
| `justified_by` | `UUID` | FK | No | `null` | Supervisor que aprobó la justificación (`FK -> users(id)`) |
| `justified_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal de aprobación de la justificación |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de creación |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de actualización |
| `version` | `BIGINT` | - | Sí | `0` | Versión para bloqueo optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `tenants` (`tenant_id` referencia a `tenants.id`).
  * `N:1` hacia `branches` (`branch_id` referencia a `branches.id`).
  * `N:1` hacia `tenant_memberships` (`membership_id` referencia a `tenant_memberships.id`).
  * `N:1` hacia `work_shifts` (`shift_id` referencia a `work_shifts.id`).
  * `N:1` hacia `users` (`justified_by` referencia a `users.id`).
* **Restricciones (Constraints):**
  * `pk_attendance_records`: `PRIMARY KEY (id)`
  * `fk_attendance_tenant_id`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id)`
  * `fk_attendance_branch_id`: `FOREIGN KEY (branch_id) REFERENCES branches(id)`
  * `fk_attendance_membership_id`: `FOREIGN KEY (membership_id) REFERENCES tenant_memberships(id)`
  * `fk_attendance_shift_id`: `FOREIGN KEY (shift_id) REFERENCES work_shifts(id)`
  * `fk_attendance_justified_by`: `FOREIGN KEY (justified_by) REFERENCES users(id)`
  * `chk_attendance_status`: `CHECK (status IN ('on_time', 'late', 'excused', 'absent'))`
* **Índices Físicos (B-Tree):**
  * `idx_attendance_membership_date`: B-Tree sobre `(membership_id, clock_in)`
  * `idx_attendance_branch_date`: B-Tree sobre `(branch_id, clock_in)`
  * `idx_attendance_status`: B-Tree sobre `(tenant_id, status)`

### 5.4 `payroll_payments` (Liquidaciones Periódicas de Nómina)
Consolida la liquidación formal periódica de haberes para cada colaborador, integrando sueldo base, penalidades por tardanzas o inasistencias y bonificaciones por productividad en faenas de taller.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador de la liquidación de nómina |
| `tenant_id` | `UUID` | FK | Sí | - | Taller automotriz empleador (`FK -> tenants(id)`) |
| `membership_id` | `UUID` | FK | Sí | - | Colaborador liquidado (`FK -> tenant_memberships(id)`) |
| `period_start` | `DATE` | - | Sí | - | Fecha inicial del periodo de corte contable |
| `period_end` | `DATE` | - | Sí | - | Fecha final del periodo de corte contable |
| `base_amount` | `NUMERIC(10,2)` | - | Sí | `0.00` | Remuneración base computable para el periodo |
| `deductions` | `NUMERIC(10,2)` | - | Sí | `0.00` | Descuentos acumulados por tardanzas o faltas |
| `bonuses` | `NUMERIC(10,2)` | - | Sí | `0.00` | Bonificaciones por comisiones o productividad |
| `total_paid` | `NUMERIC(10,2)` | - | Sí | `0.00` | Saldo neto a transferir (`base_amount - deductions + bonuses`) |
| `currency` | `VARCHAR(3)` | - | Sí | `'PEN'` | Código ISO de la divisa de pago (`PEN`, `USD`) |
| `status` | `VARCHAR(20)` | - | Sí | `'draft'` | Estado (`draft`, `approved`, `paid`, `cancelled`) |
| `paid_at` | `TIMESTAMPTZ` | - | No | `null` | Fecha y hora en que se efectuó el pago bancario |
| `payment_reference` | `VARCHAR(100)` | - | No | `null` | Número de operación bancaria o comprobante |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de generación de la planilla |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de modificación |
| `version` | `BIGINT` | - | Sí | `0` | Versión para bloqueo optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `tenants` (`tenant_id` referencia a `tenants.id`).
  * `N:1` hacia `tenant_memberships` (`membership_id` referencia a `tenant_memberships.id`).
  * `1:N` hacia `payroll_items` (Partidas analíticas de detalle subordinadas).
* **Restricciones (Constraints):**
  * `pk_payroll_payments`: `PRIMARY KEY (id)`
  * `fk_payroll_tenant_id`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id)`
  * `fk_payroll_membership_id`: `FOREIGN KEY (membership_id) REFERENCES tenant_memberships(id)`
  * `uk_payroll_membership_period`: `UNIQUE (membership_id, period_start, period_end)`
  * `chk_payroll_status`: `CHECK (status IN ('draft', 'approved', 'paid', 'cancelled'))`
  * `chk_payroll_total`: `CHECK (total_paid >= 0.00)`
* **Índices Físicos (B-Tree):**
  * `idx_payroll_tenant_period`: B-Tree sobre `(tenant_id, period_start, period_end)`
  * `idx_payroll_membership`: B-Tree sobre `(membership_id)`
  * `idx_payroll_status`: B-Tree sobre `(tenant_id, status)`

### 5.5 `payroll_items` (Desglose Analítico de Conceptos de Nómina)
Desglosa individualmente cada concepto computable que compone la boleta de pago del técnico, salvaguardando la trazabilidad de cada partida ante auditorías laborales.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador de la partida de nómina |
| `payroll_payment_id` | `UUID` | FK | Sí | - | Liquidación a la que pertenece (`FK -> payroll_payments(id) ON DELETE CASCADE`) |
| `category` | `VARCHAR(20)` | - | Sí | - | Tipo de afectación (`deduction`, `bonus`, `base_salary`) |
| `concept` | `VARCHAR(200)` | - | Sí | - | Glosa explicativa de la línea |
| `amount` | `NUMERIC(10,2)` | - | Sí | `0.00` | Monto monetario computado |
| `type` | `VARCHAR(50)` | - | Sí | - | Tipificación interna (`LATE_PENALTY`, `COMMISSION`, `BASE`) |
| `date` | `DATE` | - | Sí | `CURRENT_DATE` | Fecha a la que corresponde la imputación |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de creación |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de actualización |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `payroll_payments` (`payroll_payment_id` referencia a `payroll_payments.id` con eliminación en cascada).
* **Restricciones (Constraints):**
  * `pk_payroll_items`: `PRIMARY KEY (id)`
  * `fk_payroll_items_payment_id`: `FOREIGN KEY (payroll_payment_id) REFERENCES payroll_payments(id) ON DELETE CASCADE`
  * `chk_payroll_item_category`: `CHECK (category IN ('deduction', 'bonus', 'base_salary'))`
  * `chk_payroll_item_amount`: `CHECK (amount >= 0.00)`
* **Índices Físicos (B-Tree):**
  * `idx_payroll_items_payment`: B-Tree sobre `(payroll_payment_id)`
  * `idx_payroll_items_category`: B-Tree sobre `(category)`

---

## 6. Invoicing and Compliance Context
**Paquete Backend:** `com.andeva.atelier.platform.invoicing`

Encapsula la complejidad tributaria, la emisión de comprobantes electrónicos de pago con valor legal y el cumplimiento normativo ante la SUNAT bajo el estándar internacional UBL 2.1 (mediante la integración con el Proveedor de Servicios Electrónicos - PSE Nubefact). Gobierna el avance correlativo estricto por serie y sede física, la liquidación y amortización de pagos de taller en mostrador y patio, y la conciliación contable de órdenes de trabajo de MRO.

### 6.1 `sunat_series_configurations` (Control de Series y Correlativos Fiscales por Sede)
Gobierna la parametrización formal de series alfanuméricas autorizadas por SUNAT para cada sede física del taller, custodiando el avance correlativo secuencial estricto y previniendo saltos o colisiones de numeración tributaria.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador único universal de la configuración de serie fiscal |
| `tenant_id` | `UUID` | FK | Sí | - | Taller automotriz titular (`FK -> tenants(id)`) |
| `branch_id` | `UUID` | FK | Sí | - | Sede física titular autorizada para emitir la serie (`FK -> branches(id)`) |
| `voucher_type` | `VARCHAR(10)` | - | Sí | - | Tipo de comprobante SUNAT (`01` = Factura, `03` = Boleta, `07` = NC, `08` = ND) |
| `serie` | `VARCHAR(4)` | - | Sí | - | Código alfanumérico formal de 4 caracteres (ej. `F001`, `B001`, `FC01`) |
| `current_correlative` | `INTEGER` | - | Sí | `0` | Último correlativo numérico emitido ($current\_correlative \ge 0$) |
| `is_active` | `BOOLEAN` | - | Sí | `true` | Bandera de vigencia y disponibilidad operativa de la serie |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de alta en plataforma |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de última modificación |
| `version` | `BIGINT` | - | Sí | `0` | Versión para control de concurrencia optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `tenants` (`tenant_id` referencia a `tenants.id`).
  * `N:1` hacia `branches` (`branch_id` referencia a `branches.id`).
  * `1:N` hacia `electronic_vouchers` (Una configuración emite múltiples comprobantes correlativos).
* **Restricciones (Constraints):**
  * `pk_sunat_series`: `PRIMARY KEY (id)`
  * `fk_series_tenant_id`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id)`
  * `fk_series_branch_id`: `FOREIGN KEY (branch_id) REFERENCES branches(id)`
  * `uk_series_branch_type_serie`: `UNIQUE (branch_id, voucher_type, serie)`
  * `chk_series_voucher_type`: `CHECK (voucher_type IN ('01', '03', '07', '08'))`
  * `chk_series_correlative_pos`: `CHECK (current_correlative >= 0)`
* **Índices Físicos (B-Tree):**
  * `idx_series_branch_type`: B-Tree compuesto sobre `(branch_id, voucher_type, is_active)`
  * `idx_series_tenant`: B-Tree sobre `(tenant_id)`

### 6.2 `electronic_vouchers` (Comprobantes de Pago Electrónicos UBL 2.1)
Entidad raíz del agregado de facturación. Modela el comprobante fiscal emitido con valor tributario (Factura, Boleta de Venta, Nota de Crédito o Débito), custodiando la representación impresa (PDF), el archivo firmado digitalmente (XML) y la Constancia de Recepción (CDR) validada por SUNAT.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador único universal del comprobante fiscal |
| `tenant_id` | `UUID` | FK | Sí | - | Taller automotriz emisor (`FK -> tenants(id)`) |
| `branch_id` | `UUID` | FK | Sí | - | Sede física y domicilio fiscal emisor (`FK -> branches(id)`) |
| `customer_id` | `UUID` | FK | Sí | - | Cliente receptor del comprobante (`FK -> customers(id)`) |
| `work_order_id` | `UUID` | FK | No | `null` | Orden de trabajo origen de la liquidación (`FK -> work_orders(id)`) |
| `voucher_type` | `VARCHAR(10)` | - | Sí | - | Tipo fiscal (`01` = Factura, `03` = Boleta, `07` = NC, `08` = ND) |
| `serie` | `VARCHAR(4)` | - | Sí | - | Serie fiscal autorizada de 4 caracteres alfanuméricos |
| `number` | `INTEGER` | - | Sí | - | Número correlativo secuencial estricto autoincremental por serie |
| `subtotal` | `DECIMAL(12,2)` | - | Sí | - | Base imponible o valor de venta gravado sin IGV |
| `igv_amount` | `DECIMAL(12,2)` | - | Sí | - | Importe liquidado del Impuesto General a las Ventas (18%) |
| `total_amount` | `DECIMAL(12,2)` | - | Sí | - | Monto total general facturado (`subtotal + igv_amount`) |
| `currency` | `VARCHAR(3)` | - | Sí | `'PEN'` | Código ISO 4217 de moneda formal (`PEN`, `USD`) |
| `status` | `VARCHAR(20)` | - | Sí | `'draft'` | Estado (`draft`, `issued`, `accepted_sunat`, `rejected_sunat`, `voided`) |
| `customer_tax_id` | `VARCHAR(20)` | - | Sí | - | Documento de identidad fiscal del receptor (RUC o DNI) |
| `customer_legal_name` | `VARCHAR(150)` | - | Sí | - | Razón social o nombres y apellidos del cliente receptor |
| `customer_fiscal_address` | `VARCHAR(200)` | - | No | `null` | Dirección fiscal formal declarada ante SUNAT |
| `customer_document_type` | `VARCHAR(10)` | - | Sí | - | Tipo de documento SUNAT (`6` = RUC, `1` = DNI, `4` = CE, `7` = Pasaporte) |
| `sunat_pdf_url` | `VARCHAR(255)` | - | No | `null` | Enlace seguro de descarga de la representación impresa oficial en PDF |
| `sunat_xml_url` | `VARCHAR(255)` | - | No | `null` | Enlace seguro al archivo XML firmado digitalmente bajo UBL 2.1 |
| `sunat_cdr_url` | `VARCHAR(255)` | - | No | `null` | Enlace a la Constancia de Recepción formal devuelta por SUNAT |
| `digital_signature_hash` | `VARCHAR(100)` | - | No | `null` | Valor del resumen hash criptográfico SHA-256 de la firma digital |
| `sunat_response_code` | `VARCHAR(10)` | - | No | `null` | Código numérico oficial de respuesta de SUNAT (`0` = Aceptado) |
| `sunat_description` | `VARCHAR(255)` | - | No | `null` | Glosa descriptiva oficial de respuesta emitida por SUNAT |
| `voided_reason` | `VARCHAR(255)` | - | No | `null` | Motivo formal documentado de la anulación o comunicación de baja |
| `voided_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal UTC de formalización de la baja fiscal |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de creación |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de última modificación |
| `version` | `BIGINT` | - | Sí | `0` | Versión para control de concurrencia optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `tenants` (`tenant_id` referencia a `tenants.id`).
  * `N:1` hacia `branches` (`branch_id` referencia a `branches.id`).
  * `N:1` hacia `customers` (`customer_id` referencia a `customers.id`).
  * `N:1` hacia `work_orders` (`work_order_id` referencia a `work_orders.id`).
  * `1:N` hacia `voucher_lines` (Un comprobante desglosa una o múltiples partidas con eliminación en cascada).
  * `1:N` hacia `voucher_payments` (Un comprobante amortiza cobros con eliminación en cascada).
* **Restricciones (Constraints):**
  * `pk_electronic_vouchers`: `PRIMARY KEY (id)`
  * `fk_vouchers_tenant_id`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id)`
  * `fk_vouchers_branch_id`: `FOREIGN KEY (branch_id) REFERENCES branches(id)`
  * `fk_vouchers_customer_id`: `FOREIGN KEY (customer_id) REFERENCES customers(id)`
  * `fk_vouchers_work_order_id`: `FOREIGN KEY (work_order_id) REFERENCES work_orders(id)`
  * `uk_vouchers_tenant_serie_number`: `UNIQUE (tenant_id, serie, number)`
  * `chk_vouchers_type`: `CHECK (voucher_type IN ('01', '03', '07', '08'))`
  * `chk_vouchers_status`: `CHECK (status IN ('draft', 'issued', 'accepted_sunat', 'rejected_sunat', 'voided'))`
  * `chk_vouchers_currency`: `CHECK (currency IN ('PEN', 'USD'))`
  * `chk_vouchers_amounts`: `CHECK (total_amount >= 0.00 AND subtotal >= 0.00 AND igv_amount >= 0.00)`
* **Índices Físicos (B-Tree):**
  * `idx_vouchers_tenant_date`: B-Tree compuesto sobre `(tenant_id, created_at DESC)`
  * `idx_vouchers_lookup_fiscal`: B-Tree compuesto sobre `(tenant_id, serie, number)`
  * `idx_vouchers_work_order`: B-Tree parcial sobre `(work_order_id) WHERE work_order_id IS NOT NULL`
  * `idx_vouchers_customer`: B-Tree sobre `(customer_id)`
  * `idx_vouchers_status`: B-Tree compuesto sobre `(tenant_id, status)`

### 6.3 `voucher_lines` (Partidas Detalladas de Bienes y Servicios)
Desglosa cada ítem de producto o servicio contenido en el comprobante fiscal, computando el valor unitario (sin IGV), precio unitario (con IGV) e importe tributario de acuerdo con las especificaciones técnicas de SUNAT UBL 2.1.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador único universal de la partida de detalle |
| `voucher_id` | `UUID` | FK | Sí | - | Comprobante de pago contenedor (`FK -> electronic_vouchers(id) ON DELETE CASCADE`) |
| `item_id` | `UUID` | - | No | `null` | Identificador del repuesto o servicio liquidado (nullable para glosas libres) |
| `item_type` | `VARCHAR(20)` | - | Sí | - | Clasificación del concepto facturado (`PRODUCT`, `SERVICE`) |
| `description` | `VARCHAR(200)` | - | Sí | - | Glosa descriptiva detallada del repuesto o mano de obra ejecutada |
| `quantity` | `DECIMAL(10,2)` | - | Sí | - | Cantidad facturada de unidades o labores ($quantity > 0.00$) |
| `unit_value` | `DECIMAL(12,2)` | - | Sí | - | Valor unitario neto sin IGV exigido por la normativa fiscal |
| `unit_price` | `DECIMAL(12,2)` | - | Sí | - | Precio unitario bruto con IGV incluido facturado al cliente |
| `igv_amount` | `DECIMAL(12,2)` | - | Sí | - | Importe del IGV atribuible a esta partida (`(unit_price - unit_value) * quantity`) |
| `total_line` | `DECIMAL(12,2)` | - | Sí | - | Importe total liquidado de la partida ($total\_line \ge 0.00$) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `electronic_vouchers` (`voucher_id` referencia a `electronic_vouchers.id` con eliminación en cascada).
* **Restricciones (Constraints):**
  * `pk_voucher_lines`: `PRIMARY KEY (id)`
  * `fk_voucher_lines_voucher_id`: `FOREIGN KEY (voucher_id) REFERENCES electronic_vouchers(id) ON DELETE CASCADE`
  * `chk_lines_item_type`: `CHECK (item_type IN ('PRODUCT', 'SERVICE'))`
  * `chk_lines_quantity`: `CHECK (quantity > 0.00)`
  * `chk_lines_total_positive`: `CHECK (total_line >= 0.00)`
* **Índices Físicos (B-Tree):**
  * `idx_voucher_lines_voucher_id`: B-Tree sobre `(voucher_id)`
  * `idx_voucher_lines_item`: B-Tree parcial sobre `(item_id) WHERE item_id IS NOT NULL`

### 6.4 `voucher_payments` (Liquidaciones de Pagos y Cobranzas de Taller)
Custodia los cobros dinerarios recaudados en mostrador o patio para cancelar o amortizar el saldo del comprobante fiscal, vinculando el medio de pago, divisa y referencia financiera.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador único universal de la transacción de pago |
| `voucher_id` | `UUID` | FK | Sí | - | Comprobante electrónico amortizado (`FK -> electronic_vouchers(id) ON DELETE CASCADE`) |
| `tenant_id` | `UUID` | FK | Sí | - | Taller automotriz recaudador (`FK -> tenants(id)`) |
| `branch_id` | `UUID` | FK | Sí | - | Sede física donde se percibe el fondo dinerario (`FK -> branches(id)`) |
| `amount` | `DECIMAL(12,2)` | - | Sí | - | Monto monetario del abono recibido ($amount > 0.00$) |
| `currency` | `VARCHAR(3)` | - | Sí | `'PEN'` | Divisa de cobro (`PEN`, `USD`) |
| `payment_method` | `VARCHAR(30)` | - | Sí | - | Medio (`cash`, `credit_card`, `debit_card`, `bank_transfer`, `yape`, `plin`) |
| `transaction_reference` | `VARCHAR(100)` | - | No | `null` | Código de voucher POS, número de depósito bancario o billetera móvil |
| `status` | `VARCHAR(20)` | - | Sí | `'completed'` | Estado del abono (`pending`, `completed`, `refunded`) |
| `paid_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal UTC en la que se percibió efectivamente el pago |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de creación |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de última modificación |
| `version` | `BIGINT` | - | Sí | `0` | Versión para control de concurrencia optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `electronic_vouchers` (`voucher_id` referencia a `electronic_vouchers.id` con eliminación en cascada).
  * `N:1` hacia `tenants` (`tenant_id` referencia a `tenants.id`).
  * `N:1` hacia `branches` (`branch_id` referencia a `branches.id`).
* **Restricciones (Constraints):**
  * `pk_voucher_payments`: `PRIMARY KEY (id)`
  * `fk_payments_voucher_id`: `FOREIGN KEY (voucher_id) REFERENCES electronic_vouchers(id) ON DELETE CASCADE`
  * `fk_payments_tenant_id`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id)`
  * `fk_payments_branch_id`: `FOREIGN KEY (branch_id) REFERENCES branches(id)`
  * `chk_payments_amount`: `CHECK (amount > 0.00)`
  * `chk_payments_currency`: `CHECK (currency IN ('PEN', 'USD'))`
  * `chk_payments_method`: `CHECK (payment_method IN ('cash', 'credit_card', 'debit_card', 'bank_transfer', 'yape', 'plin'))`
  * `chk_payments_status`: `CHECK (status IN ('pending', 'completed', 'refunded'))`
* **Índices Físicos (B-Tree):**
  * `idx_payments_voucher_id`: B-Tree sobre `(voucher_id)`
  * `idx_payments_branch_paid_at`: B-Tree compuesto sobre `(branch_id, paid_at DESC)`
  * `idx_payments_tenant_method`: B-Tree compuesto sobre `(tenant_id, payment_method)`

---

## 7. SaaS Billing and Subscriptions Context
**Paquete Backend:** `com.andeva.atelier.platform.billing`

Administra los ingresos B2B de la plataforma SaaS (la facturación recurrente que los talleres abonan por la licencia de software), el catálogo de planes comerciales, el gobierno estricto de cuotas operativas (número de sedes, mecánicos activos, órdenes de trabajo mensuales, telemetría IoT e IA diagnóstica) y la integración asíncrona resiliente con Stripe Billing bajo cumplimiento PCI-DSS Nivel 1.

### 7.1 `plans` (Catálogo Comercial de Planes Tarifarios y Cuotas)
Entidad maestra global de plataforma. Define la oferta comercial de planes SaaS, tarifas recurrentes, periocidad de facturación y límites máximos cuantitativos y cualitativos permitidos para los talleres mecánicos.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador único universal del plan comercial |
| `stripe_price_id` | `VARCHAR(100)` | UK | Sí | - | Identificador oficial del precio en Stripe (ej. `price_...`) |
| `name` | `VARCHAR(100)` | - | Sí | - | Nombre comercial formal (ej. "Starter", "Professional", "Enterprise") |
| `tier` | `VARCHAR(20)` | - | Sí | - | Nivel (`COMMUNITY`, `STARTER`, `PROFESSIONAL`, `ENTERPRISE`) |
| `price` | `DECIMAL(10,2)` | - | Sí | - | Tarifa monetaria recurrente ($price \ge 0.00$) |
| `currency` | `VARCHAR(3)` | - | Sí | `'USD'` | Divisa formal ISO 4217 (`USD`, `PEN`) |
| `billing_cycle` | `VARCHAR(20)` | - | Sí | - | Frecuencia de cobro (`MONTHLY`, `YEARLY`) |
| `max_branches` | `INTEGER` | - | Sí | - | Techo máximo de sedes físicas permitidas por taller ($max > 0$) |
| `max_active_staff` | `INTEGER` | - | Sí | - | Límite de colaboradores activos simultáneos ($max > 0$) |
| `max_monthly_work_orders` | `INTEGER` | - | Sí | - | Techo mensual de órdenes de trabajo permitidas ($max > 0$) |
| `iot_telemetry_enabled` | `BOOLEAN` | - | Sí | `false` | Autorización de acceso a telemetría OBD-II en tiempo real |
| `ai_diagnostics_enabled` | `BOOLEAN` | - | Sí | `false` | Autorización de acceso a diagnósticos asistidos por IA |
| `is_active` | `BOOLEAN` | - | Sí | `true` | Bandera de disponibilidad comercial del plan para contratación |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de alta |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de última modificación |
| `version` | `BIGINT` | - | Sí | `0` | Versión para control de concurrencia optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para inhabilitación lógica (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `1:N` hacia `plan_features` (Un plan desglosa múltiples características con eliminación en cascada).
  * `1:N` hacia `subscriptions` (Un plan es contratado por múltiples talleres clientes).
* **Restricciones (Constraints):**
  * `pk_plans`: `PRIMARY KEY (id)`
  * `uk_plans_stripe_price`: `UNIQUE (stripe_price_id)`
  * `chk_plans_tier`: `CHECK (tier IN ('COMMUNITY', 'STARTER', 'PROFESSIONAL', 'ENTERPRISE'))`
  * `chk_plans_cycle`: `CHECK (billing_cycle IN ('MONTHLY', 'YEARLY'))`
  * `chk_plans_currency`: `CHECK (currency IN ('USD', 'PEN'))`
  * `chk_plans_price`: `CHECK (price >= 0.00)`
  * `chk_plans_quotas`: `CHECK (max_branches > 0 AND max_active_staff > 0 AND max_monthly_work_orders > 0)`
* **Índices Físicos (B-Tree):**
  * `idx_plans_tier`: B-Tree sobre `(tier)`
  * `idx_plans_tier_active`: B-Tree compuesto sobre `(tier, is_active)`

### 7.2 `plan_features` (Desglose de Capacidades Modulares Paquetizadas)
Modela el conjunto granular de funcionalidades tecnológicas incluidas o restringidas en cada nivel comercial de suscripción, gobernando de manera determinista la activación de módulos en la plataforma web y móvil.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador único universal de la característica funcional |
| `plan_id` | `UUID` | FK | Sí | - | Plan tarifario contenedor (`FK -> plans(id) ON DELETE CASCADE`) |
| `feature_key` | `VARCHAR(50)` | - | Sí | - | Clave alfanumérica canónica (ej. `OBD2_TELEMETRY`, `AI_DIAGNOSTICS`) |
| `description` | `VARCHAR(255)` | - | Sí | - | Glosa explicativa de la funcionalidad empaquetada |
| `is_enabled` | `BOOLEAN` | - | Sí | `true` | Indicador de disponibilidad operativa en el plan |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de asignación al plan |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `plans` (`plan_id` referencia a `plans.id` con eliminación en cascada).
* **Restricciones (Constraints):**
  * `pk_plan_features`: `PRIMARY KEY (id)`
  * `fk_plan_features_plan`: `FOREIGN KEY (plan_id) REFERENCES plans(id) ON DELETE CASCADE`
  * `uk_plan_features_plan_key`: `UNIQUE (plan_id, feature_key)`
* **Índices Físicos (B-Tree):**
  * `idx_plan_features_plan`: B-Tree sobre `(plan_id)`
  * `idx_plan_features_lookup`: B-Tree compuesto sobre `(plan_id, is_enabled)`

### 7.3 `subscriptions` (Ciclo Contractual de Membresías por Taller)
Entidad raíz del agregado de suscripción. Custodia el estado contractual y operativo del taller automotriz en la plataforma SaaS, el identificador de cliente y contrato en Stripe Billing, y las fechas de corte y vigencia del servicio.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador técnico único del contrato de suscripción SaaS |
| `tenant_id` | `UUID` | UK, FK | Sí | - | Taller titular abonado (`FK, UK -> tenants(id)`). Regla de una sola suscripción |
| `plan_id` | `UUID` | FK | Sí | - | Plan comercial contratado (`FK -> plans(id)`) |
| `stripe_customer_id` | `VARCHAR(100)` | - | Sí | - | Identificador de cliente en Stripe Billing (`cus_...`) |
| `stripe_sub_id` | `VARCHAR(100)` | - | Sí | - | Identificador de suscripción recurrente en Stripe (`sub_...`) |
| `status` | `VARCHAR(20)` | - | Sí | `'trialing'` | Estado (`trialing`, `active`, `past_due`, `canceled`, `unpaid`, `incomplete`) |
| `current_period_start` | `TIMESTAMPTZ` | - | Sí | - | Marca temporal UTC de inicio del ciclo de cobertura pagado |
| `current_period_end` | `TIMESTAMPTZ` | - | Sí | - | Marca temporal UTC de vencimiento del ciclo actual ($end \ge start$) |
| `cancel_at_period_end` | `BOOLEAN` | - | Sí | `false` | Indicador de cancelación voluntaria al culminar el ciclo corriente |
| `canceled_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal UTC de rescisión anticipada de la suscripción |
| `trial_end_date` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal UTC de finalización del periodo de prueba |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de alta del contrato |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de última modificación |
| `version` | `BIGINT` | - | Sí | `0` | Versión para control de concurrencia optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal de baja lógica (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `1:1` hacia `tenants` (`tenant_id` referencia unívocamente a `tenants.id`).
  * `N:1` hacia `plans` (`plan_id` referencia a `plans.id`).
  * `1:N` hacia `invoices` (Una suscripción genera múltiples recibos periódicos con eliminación en cascada).
* **Restricciones (Constraints):**
  * `pk_subscriptions`: `PRIMARY KEY (id)`
  * `uk_subscriptions_tenant`: `UNIQUE (tenant_id)`
  * `fk_subscriptions_tenant`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id)`
  * `fk_subscriptions_plan`: `FOREIGN KEY (plan_id) REFERENCES plans(id)`
  * `chk_subscriptions_status`: `CHECK (status IN ('trialing', 'active', 'past_due', 'canceled', 'unpaid', 'incomplete'))`
  * `chk_subscriptions_period`: `CHECK (current_period_end >= current_period_start)`
* **Índices Físicos (B-Tree):**
  * `idx_subscriptions_tenant`: B-Tree sobre `(tenant_id)`
  * `idx_subscriptions_status`: B-Tree sobre `(status)`
  * `idx_subscriptions_stripe_sub`: B-Tree sobre `(stripe_sub_id)`
  * `idx_subscriptions_plan`: B-Tree sobre `(plan_id)`

### 7.4 `invoices` (Liquidaciones y Comprobantes Contables de Suscripción SaaS)
*Nota Arquitectónica: Corresponde a los comprobantes de cobro B2B emitidos por la plataforma Andeva hacia los talleres mecánicos por el uso del software (no confundir con los comprobantes tributarios SUNAT emitidos por el taller hacia sus clientes finales en Invoicing & Compliance).*

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador técnico del recibo de servicio SaaS |
| `subscription_id` | `UUID` | FK | Sí | - | Suscripción titular (`FK -> subscriptions(id) ON DELETE CASCADE`) |
| `tenant_id` | `UUID` | FK | Sí | - | Taller automotriz titular del cobro (`FK -> tenants(id)`) |
| `stripe_invoice_id` | `VARCHAR(100)` | UK | Sí | - | Identificador oficial del recibo en Stripe (`in_...`) |
| `amount_paid` | `DECIMAL(10,2)` | - | Sí | - | Monto exacto liquidado ($amount\_paid \ge 0.00$) |
| `currency` | `VARCHAR(3)` | - | Sí | `'USD'` | Divisa formal del cobro (`USD`, `PEN`) |
| `status` | `VARCHAR(20)` | - | Sí | - | Estado (`paid`, `open`, `void`, `uncollectible`, `draft`) |
| `invoice_pdf_url` | `VARCHAR(255)` | - | No | `null` | Enlace oficial de descarga del comprobante en PDF emitido por Stripe |
| `hosted_invoice_url` | `VARCHAR(255)` | - | No | `null` | URL del portal alojado de pago y recibo digital en Stripe |
| `paid_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal UTC en la que se debitó exitosamente el fondo bancario |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de creación |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de última modificación |
| `version` | `BIGINT` | - | Sí | `0` | Versión para control de concurrencia optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `subscriptions` (`subscription_id` referencia a `subscriptions.id` con eliminación en cascada).
  * `N:1` hacia `tenants` (`tenant_id` referencia a `tenants.id`).
* **Restricciones (Constraints):**
  * `pk_invoices`: `PRIMARY KEY (id)`
  * `uk_invoices_stripe_invoice`: `UNIQUE (stripe_invoice_id)`
  * `fk_invoices_subscription`: `FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE CASCADE`
  * `fk_invoices_tenant`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id)`
  * `chk_invoices_status`: `CHECK (status IN ('paid', 'open', 'void', 'uncollectible', 'draft'))`
  * `chk_invoices_amount`: `CHECK (amount_paid >= 0.00)`
  * `chk_invoices_currency`: `CHECK (currency IN ('USD', 'PEN'))`
* **Índices Físicos (B-Tree):**
  * `idx_invoices_subscription`: B-Tree sobre `(subscription_id)`
  * `idx_invoices_tenant`: B-Tree sobre `(tenant_id)`
  * `idx_invoices_tenant_created`: B-Tree compuesto sobre `(tenant_id, created_at DESC)`
  * `idx_invoices_stripe_lookup`: B-Tree sobre `(stripe_invoice_id)`

### 7.5 `stripe_events` (Auditoría Telemática y Deduplicación Idempotente de Webhooks)
Tabla cardinal de resiliencia e idempotencia. Cuando Stripe procesa cobros recurrentes o cancelaciones, transmite webhooks asíncronos hacia la API de Atelier. La restricción de unicidad estricta sobre `stripe_event_id` garantiza que reintentos por latencia de red sean interceptados e ignorados sin alterar el estado contractual del taller.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador técnico del registro de evento webhook |
| `stripe_event_id` | `VARCHAR(100)` | UK | Sí | - | Identificador unívoco del evento en Stripe (ej. `evt_...`). Cerrojo de idempotencia |
| `type` | `VARCHAR(100)` | - | Sí | - | Nombre canónico del evento (ej. `invoice.payment_succeeded`, `customer.subscription.deleted`) |
| `payload` | `TEXT` | - | Sí | - | Carga útil completa serializada en formato JSON para auditoría forense |
| `status` | `VARCHAR(20)` | - | Sí | `'pending'` | Estado del ciclo de procesamiento (`pending`, `processed`, `failed`, `ignored`) |
| `processed_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal UTC de culminación del procesamiento local |
| `error_message` | `VARCHAR(500)` | - | No | `null` | Traza explicativa en caso de inconsistencia o excepción transaccional |

* **Restricciones (Constraints):**
  * `pk_stripe_events`: `PRIMARY KEY (id)`
  * `uk_stripe_events_id`: `UNIQUE (stripe_event_id)`
  * `chk_stripe_events_status`: `CHECK (status IN ('pending', 'processed', 'failed', 'ignored'))`
* **Índices Físicos (B-Tree):**
  * `idx_stripe_events_status`: B-Tree sobre `(status)`
  * `idx_stripe_events_type_status`: B-Tree compuesto sobre `(type, status, processed_at DESC)`

---

## 8. IoT Telemetry and Predictive Maintenance Context
**Paquete Backend:** `com.andeva.atelier.platform.iot`

El núcleo tecnológico diferenciador de Atelier. Modela el ciclo de vida del equipamiento telemático (adaptadores OBD-II BLE y módems celulares), la ingesta masiva de parámetros operacionales del motor (PIDs) en series temporales de alto rendimiento mediante TimescaleDB, el registro de fallas diagnósticas normalizadas bajo el estándar SAE J2012 / ISO 15031-6, la orquestación analítica asistida por Inteligencia Artificial (Spring AI sobre Groq Cloud LPU `llama-3.3-70b-versatile`) y el despacho de alertas preventivas en tiempo real mediante Firebase Cloud Messaging.

### 8.1 `obd2_devices` (Inventario de Adaptadores y Escáneres Telemáticos)
Registro maestro de dispositivos telemáticos homologados propiedad del taller automotriz (BYOD - Bring Your Own Device), controlando su dirección física MAC o IMEI y su compatibilidad de protocolos de bajo nivel.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador único universal del adaptador telemático |
| `tenant_id` | `UUID` | FK | Sí | - | Taller automotriz propietario del equipamiento (`FK -> tenants(id)`) |
| `device_identifier` | `VARCHAR(100)` | UK | Sí | - | Dirección física MAC (BLE) o código IMEI celular de 15 dígitos |
| `connection_type` | `VARCHAR(20)` | - | Sí | - | Protocolo de transporte físico (`bluetooth`, `sim_cellular`, `wifi`) |
| `protocol_type` | `VARCHAR(20)` | - | Sí | - | Familia de comunicación (`elm327`, `custom_telematics`) |
| `status` | `VARCHAR(20)` | - | Sí | `'active'` | Estado operativo del hardware (`active`, `inactive`, `lost`, `broken`) |
| `hardware_model` | `VARCHAR(100)` | - | No | `null` | Modelo comercial del chipset y microcontrolador embebido |
| `firmware_version` | `VARCHAR(50)` | - | No | `null` | Versión del firmware instalado en el dispositivo |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de alta del hardware |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de última modificación |
| `version` | `BIGINT` | - | Sí | `0` | Versión para control de concurrencia optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `tenants` (`tenant_id` referencia a `tenants.id`).
  * `1:N` hacia `device_installations` (Un escáner es acoplado en múltiples sesiones vehiculares).
* **Restricciones (Constraints):**
  * `pk_obd2_devices`: `PRIMARY KEY (id)`
  * `uk_obd2_identifier`: `UNIQUE (device_identifier)`
  * `fk_obd2_tenant`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id)`
  * `chk_obd2_conn`: `CHECK (connection_type IN ('bluetooth', 'sim_cellular', 'wifi'))`
  * `chk_obd2_protocol`: `CHECK (protocol_type IN ('elm327', 'custom_telematics'))`
  * `chk_obd2_status`: `CHECK (status IN ('active', 'inactive', 'lost', 'broken'))`
* **Índices Físicos (B-Tree):**
  * `idx_obd2_tenant`: B-Tree sobre `(tenant_id)`
  * `idx_obd2_identifier`: B-Tree sobre `(device_identifier)`
  * `idx_obd2_status`: B-Tree compuesto sobre `(tenant_id, status)`

### 8.2 `device_installations` (Sesiones Físicas de Montaje en Vehículos)
Modela el acoplamiento físico temporal o permanente de un escáner OBD-II en el conector de diagnóstico de un vehículo específico del cliente, delimitando el odómetro inicial y final de la sesión de monitoreo VIP.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador único universal de la sesión de instalación |
| `tenant_id` | `UUID` | FK | Sí | - | Taller automotriz que supervisa la instalación (`FK -> tenants(id)`) |
| `device_id` | `UUID` | FK | Sí | - | Escáner telemático asignado (`FK -> obd2_devices(id)`) |
| `vehicle_id` | `UUID` | FK | Sí | - | Automotor receptor monitoreado (`FK -> vehicles(id)`) |
| `installed_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Fecha y hora de conexión física al puerto de diagnóstico |
| `uninstalled_at` | `TIMESTAMPTZ` | - | No | `null` | Fecha y hora de desacople físico (null mientras permanezca activo) |
| `initial_odometer_km` | `INTEGER` | - | Sí | - | Odómetro registrado al acoplar el equipo ($initial \ge 0$) |
| `final_odometer_km` | `INTEGER` | - | No | `null` | Odómetro registrado al retirar el equipo ($final \ge initial$) |
| `status` | `VARCHAR(20)` | - | Sí | `'active'` | Estado ontológico de la instalación (`active`, `completed`) |
| `installation_notes` | `VARCHAR(500)` | - | No | `null` | Observaciones periciales del técnico sobre el conector o foso |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de creación |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de última modificación |
| `version` | `BIGINT` | - | Sí | `0` | Versión para control de concurrencia optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `tenants` (`tenant_id` referencia a `tenants.id`).
  * `N:1` hacia `obd2_devices` (`device_id` referencia a `obd2_devices.id`).
  * `N:1` hacia `vehicles` (`vehicle_id` referencia a `vehicles.id`).
* **Restricciones (Constraints):**
  * `pk_device_installations`: `PRIMARY KEY (id)`
  * `fk_inst_tenant`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id)`
  * `fk_inst_device`: `FOREIGN KEY (device_id) REFERENCES obd2_devices(id)`
  * `fk_inst_vehicle`: `FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)`
  * `chk_inst_status`: `CHECK (status IN ('active', 'completed'))`
  * `chk_inst_initial_odometer`: `CHECK (initial_odometer_km >= 0)`
  * `chk_inst_odometer`: `CHECK (final_odometer_km IS NULL OR final_odometer_km >= initial_odometer_km)`
* **Índices Físicos (B-Tree):**
  * `idx_inst_vehicle_status`: B-Tree compuesto sobre `(vehicle_id, status)`
  * `idx_inst_device_status`: B-Tree compuesto sobre `(device_id, status)`
  * `idx_inst_tenant`: B-Tree sobre `(tenant_id)`

### 8.3 `telemetry_logs` (Hipertabla TimescaleDB de Señales Sensoriales y PIDs)
*Nota de Arquitectura de Series Temporales:* Representa el repositorio masivo de magnitudes sensoriales continuas emitidas por la computadora del vehículo (ECU). Opera como una **Hipertabla particionada automáticamente por bloques de tiempo (time chunks) de 7 días** mediante la extensión TimescaleDB en Aiven Cloud. Carece de borrado lógico y de claves foráneas restrictivas en runtime, optimizada exclusivamente para inserción masiva en ráfaga (*Append-Only*) y compresión columnar transparente tras 30 días (`timescaledb.compress_segmentby = 'vehicle_id'`, `timescaledb.compress_orderby = 'timestamp DESC'`), alcanzando reducciones de almacenamiento superiores al 90%.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `timestamp` | `TIMESTAMPTZ` | PK | Sí | `NOW()` | **Dimensión temporal de particionamiento (Time Chunk Key)** |
| `vehicle_id` | `UUID` | PK, FK | Sí | - | Automotor emisor de la telemetría (`FK -> vehicles(id)`) |
| `tenant_id` | `UUID` | FK | Sí | - | Taller titular desnormalizado para consultas sin JOINs |
| `device_id` | `UUID` | FK | Sí | - | Escáner OBD-II que capturó la trama (`FK -> obd2_devices(id)`) |
| `speed` | `INTEGER` | - | No | `null` | Velocidad instantánea del vehículo en km/h ($speed \ge 0$) |
| `rpm` | `INTEGER` | - | No | `null` | Revoluciones por minuto del cigüeñal ($rpm \ge 0$) |
| `engine_temp_c` | `DECIMAL(5,2)` | - | No | `null` | Temperatura del líquido refrigerante del motor en °C |
| `battery_voltage` | `DECIMAL(4,2)` | - | No | `null` | Tensión eléctrica en bornes de batería en voltios |
| `fuel_level` | `DECIMAL(5,2)` | - | No | `null` | Nivel relativo de combustible en tanque ($0.00 \le level \le 100.00$) |
| `throttle_position` | `DECIMAL(5,2)` | - | No | `null` | Posición angular de la mariposa de aceleración ($0.00 \le pos \le 100.00$) |
| `engine_load` | `DECIMAL(5,2)` | - | No | `null` | Porcentaje de carga absoluta calculada del motor ($0.00 \le load \le 100.00$) |
| `latitude` | `DECIMAL(10,8)` | - | No | `null` | Coordenada geográfica de latitud WGS84 provista por el gateway |
| `longitude` | `DECIMAL(11,8)` | - | No | `null` | Coordenada geográfica de longitud WGS84 provista por el gateway |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `vehicles` (`vehicle_id` referencia a `vehicles.id`).
  * `N:1` hacia `tenants` (`tenant_id` referencia a `tenants.id`).
  * `N:1` hacia `obd2_devices` (`device_id` referencia a `obd2_devices.id`).
* **Restricciones (Constraints):**
  * `pk_telemetry_logs`: `PRIMARY KEY (timestamp, vehicle_id)` (Clave compuesta exigida por TimescaleDB)
  * `fk_telemetry_vehicle`: `FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)`
  * `fk_telemetry_tenant`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id)`
  * `fk_telemetry_device`: `FOREIGN KEY (device_id) REFERENCES obd2_devices(id)`
  * `chk_telemetry_speed`: `CHECK (speed IS NULL OR speed >= 0)`
  * `chk_telemetry_rpm`: `CHECK (rpm IS NULL OR rpm >= 0)`
  * `chk_telemetry_fuel`: `CHECK (fuel_level IS NULL OR (fuel_level >= 0.00 AND fuel_level <= 100.00))`
* **Políticas de Almacenamiento TimescaleDB:**
  * Chunk Interval: `7 days` (`SELECT create_hypertable('telemetry_logs', 'timestamp', chunk_time_interval => INTERVAL '7 days');`)
  * Compresión Columnar: Segmentado por `vehicle_id` y ordenado por `timestamp DESC` tras 30 días de antigüedad.
* **Índices Físicos (B-Tree):**
  * `idx_telemetry_veh_time`: B-Tree compuesto sobre `(vehicle_id, timestamp DESC)`
  * `idx_telemetry_tenant_time`: B-Tree compuesto sobre `(tenant_id, timestamp DESC)`

### 8.4 `vehicle_faults` (Registro de Averías y Fallas DTC Detectadas)
Almacena las anomalías y fallas de diagnóstico extraídas de la memoria no volátil de la computadora del vehículo (DTC - Diagnostic Trouble Codes), clasificadas por severidad y asociadas a su ciclo de inspección y corrección física en taller.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador único universal del fallo diagnosticado |
| `tenant_id` | `UUID` | FK | Sí | - | Taller automotriz responsable del seguimiento (`FK -> tenants(id)`) |
| `vehicle_id` | `UUID` | FK | Sí | - | Automotor diagnosticado (`FK -> vehicles(id)`) |
| `dtc_code` | `VARCHAR(10)` | - | Sí | - | Código alfanumérico SAE J2012 (ej. `P0300`, `P0420`, `C0035`, `U0100`) |
| `severity` | `VARCHAR(20)` | - | Sí | `'low'` | Criticidad técnica de la avería (`low`, `medium`, `critical`) |
| `status` | `VARCHAR(20)` | - | Sí | `'active'` | Ciclo de resolución (`active`, `pending_review`, `resolved`, `cleared`) |
| `description` | `VARCHAR(255)` | - | Sí | - | Glosa técnica explicativa de la falla |
| `detected_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de captura de la trama por el escáner |
| `resolved_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal de subsanación técnica o reseteo en taller |
| `resolution_notes` | `VARCHAR(500)` | - | No | `null` | Detalle pericial de la intervención ejecutada en orden de trabajo |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de creación |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de última modificación |
| `version` | `BIGINT` | - | Sí | `0` | Versión para control de concurrencia optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `tenants` (`tenant_id` referencia a `tenants.id`).
  * `N:1` hacia `vehicles` (`vehicle_id` referencia a `vehicles.id`).
* **Restricciones (Constraints):**
  * `pk_vehicle_faults`: `PRIMARY KEY (id)`
  * `fk_faults_tenant`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id)`
  * `fk_faults_vehicle`: `FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)`
  * `chk_faults_severity`: `CHECK (severity IN ('low', 'medium', 'critical'))`
  * `chk_faults_status`: `CHECK (status IN ('active', 'pending_review', 'resolved', 'cleared'))`
* **Índices Físicos (B-Tree):**
  * `idx_faults_vehicle_status`: B-Tree compuesto sobre `(vehicle_id, status)`
  * `idx_faults_tenant_severity`: B-Tree compuesto sobre `(tenant_id, severity)`
  * `idx_faults_dtc_code`: B-Tree sobre `(dtc_code)`

### 8.5 `predictive_alerts` (Advertencias Preventivas y Diagnóstico Predictivo por IA)
Registra las advertencias de degradación mecánica anticipada inferidas por el motor analítico `PredictiveAnomalyDetectionEngine` y enriquecidas mediante Spring AI con Groq Cloud LPU (`llama-3.3-70b-versatile`). Dispara notificaciones push inmediatas al conductor a través de Firebase Cloud Messaging y propone servicios de mantenimiento en MRO.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador único universal de la alerta preventiva generada |
| `tenant_id` | `UUID` | FK | Sí | - | Taller automotriz que gestiona la prevención (`FK -> tenants(id)`) |
| `vehicle_id` | `UUID` | FK | Sí | - | Automotor evaluado por el modelo inferencial (`FK -> vehicles(id)`) |
| `recommended_service_id` | `UUID` | FK | No | `null` | Servicio preventivo sugerido en el catálogo de MRO (`FK -> services(id)`) |
| `alert_type` | `VARCHAR(50)` | - | Sí | - | Patrón inferido (`overheating_risk`, `battery_drain`, `alternator_failure`, `misfire`, `emissions_degradation`) |
| `confidence_score` | `DECIMAL(5,2)` | - | Sí | - | Certeza estadística calculada en porcentaje ($75.00 \le score \le 100.00$) |
| `message` | `VARCHAR(255)` | - | Sí | - | Glosa preventiva orientada al cliente propietario del vehículo |
| `status` | `VARCHAR(20)` | - | Sí | `'dispatched'` | Estado (`dispatched`, `acknowledged`, `resolved`, `dismissed`) |
| `fcm_message_id` | `VARCHAR(100)` | - | No | `null` | Identificador de entrega devuelto por Firebase Cloud Messaging |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal UTC de emisión de la alerta |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de última modificación |
| `version` | `BIGINT` | - | Sí | `0` | Versión para control de concurrencia optimista JPA |
| `deleted_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal para borrado lógico (*Soft Delete*) |

* **Relaciones (Integridad Referencial):**
  * `N:1` hacia `tenants` (`tenant_id` referencia a `tenants.id`).
  * `N:1` hacia `vehicles` (`vehicle_id` referencia a `vehicles.id`).
  * `N:1` hacia `services` en MRO (`recommended_service_id` referencia a `services.id`).
* **Restricciones (Constraints):**
  * `pk_predictive_alerts`: `PRIMARY KEY (id)`
  * `fk_alerts_tenant`: `FOREIGN KEY (tenant_id) REFERENCES tenants(id)`
  * `fk_alerts_vehicle`: `FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)`
  * `fk_alerts_service`: `FOREIGN KEY (recommended_service_id) REFERENCES services(id)`
  * `chk_alerts_status`: `CHECK (status IN ('dispatched', 'acknowledged', 'resolved', 'dismissed'))`
  * `chk_alerts_confidence`: `CHECK (confidence_score >= 0.00 AND confidence_score <= 100.00)`
* **Índices Físicos (B-Tree):**
  * `idx_alerts_status_date`: B-Tree compuesto sobre `(status, created_at DESC)`
  * `idx_alerts_vehicle`: B-Tree sobre `(vehicle_id)`
  * `idx_alerts_tenant`: B-Tree sobre `(tenant_id)`

### 8.6 `dtc_catalog` (Catálogo Estandarizado de Códigos de Falla SAE J2012 / ISO 15031-6)
Diccionario maestro universal de códigos de falla automotriz para el enriquecimiento semántico automático de las lecturas OBD-II, mapeando el subsistema mecánico o electrónico y suministrando pautas técnicas oficiales de diagnóstico.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador técnico del registro en el catálogo universal |
| `code` | `VARCHAR(10)` | UK | Sí | - | Código canónico estandarizado (ej. `P0128`, `B0001`, `U0401`) |
| `standard` | `VARCHAR(20)` | - | Sí | - | Norma técnica rectora (`sae_j2012`, `iso_15031`) |
| `system_category` | `VARCHAR(30)` | - | Sí | - | Subsistema vehicular (`powertrain`, `chassis`, `body`, `network`) |
| `description_es` | `VARCHAR(500)` | - | Sí | - | Definición técnica formal en español para el mecánico y asesor |
| `severity` | `VARCHAR(20)` | - | Sí | - | Nivel normativo de severidad (`low`, `medium`, `critical`) |
| `recommended_action` | `VARCHAR(500)` | - | No | `null` | Protocolo técnico o procedimiento de intervención sugerido |
| `is_emissions_related` | `BOOLEAN` | - | Sí | `false` | Indicador de afectación a la inspección ambiental de emisiones |
| `created_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de registro en catálogo |
| `updated_at` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de última modificación |

* **Restricciones (Constraints):**
  * `pk_dtc_catalog`: `PRIMARY KEY (id)`
  * `uk_dtc_code`: `UNIQUE (code)`
  * `chk_dtc_standard`: `CHECK (standard IN ('sae_j2012', 'iso_15031'))`
  * `chk_dtc_category`: `CHECK (system_category IN ('powertrain', 'chassis', 'body', 'network'))`
  * `chk_dtc_severity`: `CHECK (severity IN ('low', 'medium', 'critical'))`
* **Índices Físicos (B-Tree):**
  * `idx_dtc_code`: B-Tree sobre `(code)`
  * `idx_dtc_category`: B-Tree sobre `(system_category)`

---

## Infraestructura Transversal y Shared Kernel
**Paquete Backend:** `com.andeva.atelier.platform.shared`

Contiene los artefactos de infraestructura y mensajería transaccional transversales a todos los Bounded Contexts de la plataforma central en PostgreSQL 16.

### `outbox_messages` (Transactional Outbox Universal)
Tabla cardinal del patrón Transactional Outbox. Garantiza la consistencia eventual y la entrega at-least-once de eventos de dominio e integración entre módulos y hacia agentes externos (SUNAT Nubefact, Stripe, Firebase Cloud Messaging, Resend) dentro de la misma transacción relacional de base de datos.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `UUID` | PK | Sí | `uuid()` | Identificador único del mensaje encolado |
| `aggregate_type` | `VARCHAR(100)` | - | Sí | - | Tipo de agregado emisor (ej. `WorkOrder`, `ElectronicVoucher`, `Subscription`, `Attendance`) |
| `aggregate_id` | `UUID` | - | Sí | - | Identificador unívoco de la entidad raíz afectada |
| `event_type` | `VARCHAR(100)` | - | Sí | - | Nombre de la clase del evento emitido |
| `payload` | `JSONB` | - | Sí | - | Representación serializada en JSON de los datos del evento |
| `occurred_on` | `TIMESTAMPTZ` | - | Sí | `NOW()` | Marca temporal de ocurrencia del evento en dominio |
| `status` | `VARCHAR(20)` | - | Sí | `'PENDING'` | Estado de publicación (`PENDING`, `PROCESSED`, `FAILED`) |
| `retry_count` | `INTEGER` | - | Sí | `0` | Número de reintentos ejecutados por el relay worker |
| `last_error` | `TEXT` | - | No | `null` | Traza o mensaje del último error en caso de fallo |
| `processed_at` | `TIMESTAMPTZ` | - | No | `null` | Marca temporal en la que el mensaje fue despachado exitosamente |

* **Restricciones (Constraints):**
  * `pk_outbox_messages`: `PRIMARY KEY (id)`
  * `chk_outbox_status`: `CHECK (status IN ('PENDING', 'PROCESSED', 'FAILED'))`
* **Índices Físicos (B-Tree):**
  * `idx_outbox_pending`: B-Tree parcial sobre `(status, occurred_on) WHERE status = 'PENDING'`

---

## 9. Addendum: Modelo de Datos Local Móvil (Offline-First SQLite 3 Persistence)

Para garantizar la continuidad operativa en ambientes de nula o deficiente conectividad inalámbrica (zonas de foso, sótanos de alineación, patios de maniobras o mecánicos en ruta), las aplicaciones móviles de Atelier (**Atelier Workshop Mobile** para técnicos de patio y **Atelier Driver Mobile** para clientes) implementan una arquitectura de persistencia relacional local desacoplada basada en **SQLite 3 como motor relacional transaccional embebido**.

Esta capa se materializa a través de **Room Database (Android Jetpack)** en la versión nativa de Kotlin y mediante **Drift** en la variante multiplataforma. La persistencia local se estructura bajo un enfoque de **Transactional Outbox Móvil**: todas las acciones ejecutadas por los operarios se persisten localmente en colas de mutaciones pendientes (*sync queues*) junto con marcas de tiempo ISO-8601 y cargas útiles JSON inmutables. De manera paralela, las consultas de lectura operan sobre réplicas y cachés locales indexados, eliminando por completo los bloqueos por latencia de red.

A continuación, se detalla la especificación relacional de la totalidad de tablas locales implementadas para los Bounded Contexts desarrollados:

### 9.1 Infraestructura Transversal y Cola de Sincronización (Shared)

#### 9.1.1 `pending_sync_events` (Transactional Outbox Móvil Genérico)
Cola transaccional centralizada para la captura e intermediación de eventos de mutación offline de la aplicación móvil hacia el backend central.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `TEXT` | PK | Sí | - | Identificador local único del evento (UUID v4) |
| `action_type` | `TEXT` | - | Sí | - | Código de acción (ej. `CLOCK_IN`, `COMPLETE_TASK`, `ALLOCATE_ITEM`) |
| `payload` | `TEXT` | - | Sí | - | Datos completos a transmitir en formato JSON serializado |
| `status` | `TEXT` | - | Sí | `'PENDING'` | Estado de sincronización (`PENDING`, `SYNCING`, `SYNCED`, `FAILED`) |
| `retry_count` | `INTEGER` | - | Sí | `0` | Número de reintentos ejecutados por el Background Worker |
| `last_error` | `TEXT` | - | No | `null` | Traza del último fallo de red o rechazo HTTP |
| `created_at` | `TEXT` | - | Sí | - | Marca temporal ISO-8601 en la que el usuario ejecutó la acción |
| `synced_at` | `TEXT` | - | No | `null` | Marca temporal ISO-8601 de confirmación exitosa por el backend |

* **Restricciones (Constraints):**
  * `pk_pending_sync_events`: `PRIMARY KEY (id)`
  * `chk_sync_status`: `CHECK (status IN ('PENDING', 'SYNCING', 'SYNCED', 'FAILED'))`
* **Índices Físicos (B-Tree):**
  * `idx_sync_events_status`: B-Tree sobre `(status, created_at)`
* **Mecanismo de Sincronización:**
  * Background Worker reactivo (`WorkManager` / cron local) que drena la cola mediante peticiones HTTPS REST idempotentes con backoff exponencial.

#### 9.1.2 `local_cache_metadata` (Control de Versiones y Sincronización Incremental Delta)
Custodia las marcas temporales de última actualización (*last-sync-timestamp*) y hashes de versión por catálogo para sincronización delta selectiva.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `table_name` | `TEXT` | PK | Sí | - | Nombre de la tabla de caché local (ej. `local_inventory_cache`) |
| `last_synced_at` | `TEXT` | - | Sí | - | Marca temporal ISO-8601 del último delta sincronizado exitosamente |
| `version_hash` | `TEXT` | - | No | `null` | Hash criptográfico del catálogo remoto (ETag) |
| `record_count` | `INTEGER` | - | Sí | `0` | Cantidad de registros consolidados en la base local |

* **Restricciones (Constraints):**
  * `pk_local_cache_metadata`: `PRIMARY KEY (table_name)`
* **Mecanismo de Sincronización:**
  * Provee el encabezado HTTP `If-Modified-Since` o parámetro `since` en las peticiones GET para descargar exclusivamente cambios incrementales.

---

### 9.2 Persistencia Local de IAM & Tenancy Context

#### 9.2.1 `auth_session` (Sesión Local Autenticada, Credenciales y Geocerca)
Custodia la identidad criptográfica del usuario, tokens de acceso JWT, credenciales de refresco, perfil del colaborador y coordenadas de la sucursal para autorizaciones locales inmediatas.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `user_id` | `TEXT` | PK | Sí | - | Identificador único del usuario autenticado |
| `tenant_id` | `TEXT` | - | Sí | - | Taller automotriz al que está conectado |
| `membership_id` | `TEXT` | - | Sí | - | Membresía contractual del operario |
| `email` | `TEXT` | - | Sí | - | Correo corporativo del operario |
| `full_name` | `TEXT` | - | Sí | - | Nombres y apellidos completos del técnico |
| `avatar_url` | `TEXT` | - | No | `null` | URL de la imagen de perfil |
| `access_token` | `TEXT` | - | Sí | - | Token JWT de acceso perimetral |
| `refresh_token` | `TEXT` | - | Sí | - | Token para renovación segura de sesión |
| `cached_roles` | `TEXT` | - | Sí | - | Arreglo JSON de roles asignados al usuario |
| `cached_permissions` | `TEXT` | - | Sí | - | Arreglo JSON de permisos atómicos adjudicados |
| `branch_id` | `TEXT` | - | Sí | - | Sede física a la que está adscrito |
| `branch_latitude` | `REAL` | - | No | `null` | Latitud geográfica del centroide del taller |
| `branch_longitude` | `REAL` | - | No | `null` | Longitud geográfica del centroide del taller |
| `geofence_radius_m` | `INTEGER` | - | Sí | `50` | Radio de tolerancia de geocerca en metros |
| `session_expires_at` | `TEXT` | - | Sí | - | Expiración de la sesión local (ISO-8601) |
| `last_authenticated_at` | `TEXT` | - | Sí | - | Última autenticación exitosa (ISO-8601) |

* **Restricciones (Constraints):**
  * `pk_auth_session`: `PRIMARY KEY (user_id)`
* **Mecanismo de Sincronización:**
  * Protocolo OAuth2 / OpenID Connect contra `POST /api/v1/iam/auth/refresh-token` al recuperar enlace.

#### 9.2.2 `local_permissions_cache` (Caché de Permisos Atómicos y RBAC)
Caché local del directorio de permisos atómicos del sistema para evaluación de privilegios UI en frío.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `permission_name` | `TEXT` | PK | Sí | - | Nombre canónico del permiso (ej. `work_orders:edit`) |
| `category` | `TEXT` | - | Sí | - | Módulo del permiso (ej. `mro`, `inventory`) |
| `description` | `TEXT` | - | Sí | - | Descripción del alcance operativo |
| `synced_at` | `TEXT` | - | Sí | - | Marca temporal de refresco (ISO-8601) |

* **Restricciones (Constraints):**
  * `pk_local_permissions_cache`: `PRIMARY KEY (permission_name)`
* **Índices Físicos (B-Tree):**
  * `idx_local_permissions_category`: B-Tree sobre `(category)`
* **Mecanismo de Sincronización:**
  * Descarga periódica incremental contra `GET /api/v1/iam/permissions`.

---

### 9.3 Persistencia Local de Customer & Fleet Management Context (CRM)

#### 9.3.1 `local_customers_cache` (Directorio Local de Clientes de Taller)
Caché de clientes del taller para autocompletado y búsqueda instantánea en recepción de patio.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `customer_id` | `TEXT` | PK | Sí | - | Identificador del cliente |
| `tenant_id` | `TEXT` | - | Sí | - | Taller automotriz |
| `display_name` | `TEXT` | - | Sí | - | Nombre comercial o nombres completos del titular |
| `tax_id` | `TEXT` | - | No | `null` | Documento de identidad fiscal (DNI, RUC) |
| `phone` | `TEXT` | - | No | `null` | Teléfono de contacto |
| `type` | `TEXT` | - | Sí | - | Tipo (`individual`, `company`) |
| `synced_at` | `TEXT` | - | Sí | - | Marca temporal de sincronización (ISO-8601) |

* **Restricciones (Constraints):**
  * `pk_local_customers`: `PRIMARY KEY (customer_id)`
* **Índices Físicos (B-Tree):**
  * `idx_local_customers_tax_id`: B-Tree sobre `(tax_id)`
* **Mecanismo de Sincronización:**
  * Refresco incremental vía `GET /api/v1/crm/customers?since=...`.

#### 9.3.2 `local_vehicles_cache` (Caché de Vehículos y Placas)
Permite la identificación vehicular instantánea por placa de rodaje sin latencia en el portón de ingreso.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `vehicle_id` | `TEXT` | PK | Sí | - | Identificador del vehículo |
| `plate` | `TEXT` | - | Sí | - | Placa de rodaje unívoca |
| `vin` | `TEXT` | - | No | `null` | Número de chasis / VIN |
| `brand_model` | `TEXT` | - | Sí | - | Marca y modelo consolidados (ej. "Toyota Yaris") |
| `current_owner_id` | `TEXT` | - | No | `null` | Identificador del cliente propietario actual |
| `synced_at` | `TEXT` | - | Sí | - | Marca temporal de sincronización (ISO-8601) |

* **Restricciones (Constraints):**
  * `pk_local_vehicles`: `PRIMARY KEY (vehicle_id)`
* **Índices Físicos (B-Tree):**
  * `idx_local_vehicles_plate`: B-Tree sobre `(plate)`
* **Mecanismo de Sincronización:**
  * Descarga previa de unidades recurrentes y consulta bajo demanda `GET /api/v1/crm/vehicles/by-plate/{plate}`.

#### 9.3.3 `local_appointments_cache` (Agenda Técnica Local de Citas del Día)
Réplica de las citas programadas para la sede del taller en la jornada en curso.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `appointment_id` | `TEXT` | PK | Sí | - | Identificador de la cita |
| `tenant_id` | `TEXT` | - | Sí | - | Taller automotriz |
| `branch_id` | `TEXT` | - | Sí | - | Sede física de atención |
| `customer_name` | `TEXT` | - | Sí | - | Nombre del cliente agendado |
| `vehicle_plate` | `TEXT` | - | Sí | - | Placa del vehículo esperado |
| `scheduled_at` | `TEXT` | - | Sí | - | Hora programada (ISO-8601) |
| `status` | `TEXT` | - | Sí | - | Estado (`pending`, `confirmed`, `arrived`, `canceled`) |
| `reason` | `TEXT` | - | No | `null` | Motivo de la atención técnica |
| `synced_at` | `TEXT` | - | Sí | - | Marca temporal de sincronización (ISO-8601) |

* **Restricciones (Constraints):**
  * `pk_local_appointments`: `PRIMARY KEY (appointment_id)`
* **Índices Físicos (B-Tree):**
  * `idx_local_appointments_date`: B-Tree sobre `(scheduled_at)`
* **Mecanismo de Sincronización:**
  * Descarga inicial de apertura de taller mediante `GET /api/v1/crm/appointments?branchId=...&date=...`.

#### 9.3.4 `offline_reception_mutations` (Buffer Transaccional de Arribo y Fichaje)
Cola local para registrar arribos y recepción de vehículos en patio ante fallos de conectividad.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `mutation_id` | `TEXT` | PK | Sí | - | Identificador único de la mutación local |
| `appointment_id` | `TEXT` | - | Sí | - | Cita afectada |
| `action_type` | `TEXT` | - | Sí | - | Acción (`MARK_ARRIVED`, `CANCEL_APPOINTMENT`) |
| `payload` | `TEXT` | - | Sí | - | Carga útil con kilometraje y notas de recepción (JSON) |
| `status` | `TEXT` | - | Sí | `'PENDING'` | Estado (`PENDING`, `SYNCED`, `FAILED`) |
| `retry_count` | `INTEGER` | - | Sí | `0` | Contador de reintentos |
| `created_at` | `TEXT` | - | Sí | - | Marca temporal de captura en patio (ISO-8601) |
| `synced_at` | `TEXT` | - | No | `null` | Marca temporal de confirmación (ISO-8601) |

* **Restricciones (Constraints):**
  * `pk_offline_reception_mutations`: `PRIMARY KEY (mutation_id)`
  * `chk_reception_mutation_status`: `CHECK (status IN ('PENDING', 'SYNCED', 'FAILED'))`
* **Índices Físicos (B-Tree):**
  * `idx_reception_mutations_status`: B-Tree sobre `(status, created_at)`
* **Mecanismo de Sincronización:**
  * Drenaje idempotente hacia `POST /api/v1/crm/appointments/{id}/arrive`.

---

### 9.4 Persistencia Local de Workshop Operations Context (MRO)

#### 9.4.1 `local_bays_cache` (Mapa de Puestos y Bahías de Trabajo)
Permite al personal de patio visualizar la ocupación física de elevadores y fosos sin conexión.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `bay_id` | `TEXT` | PK | Sí | - | Identificador de la bahía |
| `tenant_id` | `TEXT` | - | Sí | - | Taller automotriz |
| `branch_id` | `TEXT` | - | Sí | - | Sede física |
| `name` | `TEXT` | - | Sí | - | Denominación (ej. "Elevador 2") |
| `type` | `TEXT` | - | Sí | - | Tipo (`lift`, `paint_booth`, `washing`, `alignment`) |
| `status` | `TEXT` | - | Sí | - | Estado (`available`, `occupied`, `maintenance`) |
| `current_work_order_id` | `TEXT` | - | No | `null` | Orden de trabajo que la ocupa actualmente |
| `synced_at` | `TEXT` | - | Sí | - | Marca temporal de refresco (ISO-8601) |

* **Restricciones (Constraints):**
  * `pk_local_bays`: `PRIMARY KEY (bay_id)`
* **Mecanismo de Sincronización:**
  * Refresco periódico mediante `GET /api/v1/mro/work-bays?branchId=...`.

#### 9.4.2 `local_work_orders_cache` (Caché Local de Órdenes de Trabajo)
Réplica completa de las órdenes activas en el taller para consulta técnica de diagnósticos e importes.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `order_id` | `TEXT` | PK | Sí | - | Identificador de la orden |
| `tenant_id` | `TEXT` | - | Sí | - | Taller automotriz |
| `branch_id` | `TEXT` | - | Sí | - | Sede de atención |
| `internal_number` | `TEXT` | - | Sí | - | Número correlativo visible |
| `vehicle_plate` | `TEXT` | - | Sí | - | Placa del vehículo intervenido |
| `vehicle_brand_model` | `TEXT` | - | Sí | - | Marca y modelo del auto |
| `customer_name` | `TEXT` | - | Sí | - | Nombre completo del cliente |
| `current_bay_id` | `TEXT` | - | No | `null` | Bahía asignada |
| `bay_name` | `TEXT` | - | No | `null` | Nombre legible de la bahía |
| `status` | `TEXT` | - | Sí | - | Estado de la orden (`draft`, `in_progress`, etc.) |
| `diagnostic_summary` | `TEXT` | - | No | `null` | Peritaje de ingreso |
| `mileage_in` | `INTEGER` | - | Sí | `0` | Kilometraje de entrada |
| `total_amount` | `REAL` | - | Sí | `0.0` | Monto total acumulado |
| `synced_at` | `TEXT` | - | Sí | - | Marca temporal de sincronización (ISO-8601) |

* **Restricciones (Constraints):**
  * `pk_local_work_orders`: `PRIMARY KEY (order_id)`
* **Mecanismo de Sincronización:**
  * Descarga y actualización delta vía `GET /api/v1/mro/work-orders?status=in_progress`.

#### 9.4.3 `local_tasks_cache` (Tareas Asignadas, Tiempos y Pausas en Foso)
Almacena las tareas asignadas específicamente al técnico que opera el terminal móvil, gestionando cronómetros en local.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `task_id` | `TEXT` | PK | Sí | - | Identificador de la tarea |
| `work_order_id` | `TEXT` | - | Sí | - | Orden de trabajo contenedora |
| `service_name` | `TEXT` | - | Sí | - | Denominación del servicio mecánico |
| `mechanic_id` | `TEXT` | - | No | `null` | Mecánico asignado |
| `status` | `TEXT` | - | Sí | - | Estado (`pending`, `in_progress`, `on_hold`, `completed`) |
| `description` | `TEXT` | - | Sí | - | Indicaciones de trabajo |
| `estimated_hours` | `REAL` | - | Sí | `1.0` | Horas presupuestadas |
| `actual_hours` | `REAL` | - | No | `null` | Horas reales cronometradas |
| `hold_reason` | `TEXT` | - | No | `null` | Causa de suspensión de la faena |
| `missing_item_description` | `TEXT` | - | No | `null` | Repuesto solicitado a almacén |
| `paused_at` | `TEXT` | - | No | `null` | Marca temporal del inicio de pausa (ISO-8601) |
| `total_paused_seconds` | `INTEGER` | - | Sí | `0` | Segundos acumulados en pausa |
| `synced_at` | `TEXT` | - | Sí | - | Marca temporal de sincronización (ISO-8601) |

* **Restricciones (Constraints):**
  * `pk_local_tasks`: `PRIMARY KEY (task_id)`
* **Mecanismo de Sincronización:**
  * Descarga de tareas del operario mediante `GET /api/v1/mro/tasks/assigned`.

#### 9.4.4 `offline_pit_mutations` (Cola Transaccional de Mutaciones de Faena)
Buffer de mutaciones para inicio, suspensión, reactivación y finalización de faenas en foso.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `mutation_id` | `TEXT` | PK | Sí | - | Identificador técnico de la mutación local |
| `work_order_id` | `TEXT` | - | Sí | - | Orden de trabajo |
| `task_id` | `TEXT` | - | Sí | - | Tarea intervenida |
| `action_type` | `TEXT` | - | Sí | - | Acción (`START_TASK`, `PAUSE_TASK`, `RESUME_TASK`, `COMPLETE_TASK`) |
| `payload` | `TEXT` | - | Sí | - | Carga útil con tiempos y motivos en JSON |
| `status` | `TEXT` | - | Sí | `'PENDING'` | Estado (`PENDING`, `SYNCED`, `FAILED`) |
| `retry_count` | `INTEGER` | - | Sí | `0` | Reintentos automáticos |
| `created_at` | `TEXT` | - | Sí | - | Marca temporal de captura en foso (ISO-8601) |
| `synced_at` | `TEXT` | - | No | `null` | Marca temporal de confirmación (ISO-8601) |

* **Restricciones (Constraints):**
  * `pk_offline_pit_mutations`: `PRIMARY KEY (mutation_id)`
  * `chk_pit_mutation_status`: `CHECK (status IN ('PENDING', 'SYNCED', 'FAILED'))`
* **Índices Físicos (B-Tree):**
  * `idx_pit_mutations_status`: B-Tree sobre `(status, created_at)`
* **Mecanismo de Sincronización:**
  * Replicación hacia `POST /api/v1/mro/tasks/{id}/actions` con idempotencia por `mutation_id`.

#### 9.4.5 `offline_pending_evidences` (Buffer Local de Evidencias Fotográficas)
Cola de imágenes capturadas en terminal móvil pendientes de subida directa a Google Cloud Storage / Firebase Storage.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `evidence_id` | `TEXT` | PK | Sí | - | Identificador de la evidencia |
| `task_id` | `TEXT` | - | Sí | - | Tarea vinculada |
| `local_file_path` | `TEXT` | - | Sí | - | Ruta absoluta en almacenamiento privado del dispositivo |
| `target_storage_path` | `TEXT` | - | Sí | - | Ruta de destino en el bucket de Cloud Storage |
| `evidence_type` | `TEXT` | - | Sí | - | Tipo (`initial_inspection`, `defect`, `completed`) |
| `upload_status` | `TEXT` | - | Sí | `'PENDING'` | Estado (`PENDING`, `UPLOADING`, `UPLOADED`, `FAILED`) |
| `signed_url` | `TEXT` | - | No | `null` | URL prefirmada obtenida del backend para carga directa |
| `created_at` | `TEXT` | - | Sí | - | Marca temporal de captura de la fotografía (ISO-8601) |

* **Restricciones (Constraints):**
  * `pk_offline_pending_evidences`: `PRIMARY KEY (evidence_id)`
  * `chk_evidence_upload_status`: `CHECK (upload_status IN ('PENDING', 'UPLOADING', 'UPLOADED', 'FAILED'))`
* **Mecanismo de Sincronización:**
  * Solicita URL prefirmada al backend (`POST /api/v1/mro/tasks/{id}/evidences/presigned-url`), realiza subida binaria Direct-to-Cloud y confirma registro mediante `POST /api/v1/mro/tasks/{id}/evidences`.

---

### 9.5 Persistencia Local de Inventory & Supply Chain Context

#### 9.5.1 `local_inventory_cache` (Catálogo Local de Repuestos e Insumos)
Caché de repuestos, lubricantes y consumibles para consulta inmediata en foso y verificación de disponibilidad.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `item_id` | `TEXT` | PK | Sí | - | Identificador del repuesto |
| `tenant_id` | `TEXT` | - | Sí | - | Taller automotriz |
| `name` | `TEXT` | - | Sí | - | Denominación del producto |
| `sku` | `TEXT` | - | Sí | - | Código de referencia interno |
| `category` | `TEXT` | - | Sí | - | Categoría automotriz |
| `base_price` | `REAL` | - | Sí | `0.0` | Precio unitario al cliente |
| `total_stock` | `REAL` | - | Sí | `0.0` | Existencia física consolidada |
| `minimum_stock` | `REAL` | - | Sí | `0.0` | Nivel mínimo de seguridad |
| `status` | `TEXT` | - | Sí | - | Estado del artículo (`active`, `inactive`) |
| `synced_at` | `TEXT` | - | Sí | - | Marca temporal de refresco (ISO-8601) |

* **Restricciones (Constraints):**
  * `pk_local_inventory`: `PRIMARY KEY (item_id)`
* **Índices Físicos (B-Tree):**
  * `idx_local_inventory_sku`: B-Tree sobre `(sku)`
  * `idx_local_inventory_category`: B-Tree sobre `(category)`
* **Mecanismo de Sincronización:**
  * Refresco incremental periódico mediante `GET /api/v1/inventory/items?since=...`.

#### 9.5.2 `local_batches_cache` (Caché de Lotes Remanentes Disponibles)
Permite al técnico comprobar la existencia de lotes específicos y números de serie en taller.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `batch_id` | `TEXT` | PK | Sí | - | Identificador del lote |
| `item_id` | `TEXT` | - | Sí | - | Repuesto al que pertenece |
| `batch_number` | `TEXT` | - | Sí | - | Código o serie del lote |
| `remaining_qty` | `REAL` | - | Sí | - | Saldo de piezas disponibles |
| `unit_cost` | `REAL` | - | Sí | - | Costo unitario de compra |
| `arrival_date` | `TEXT` | - | Sí | - | Fecha de ingreso (ISO-8601) |
| `synced_at` | `TEXT` | - | Sí | - | Marca temporal de sincronización (ISO-8601) |

* **Restricciones (Constraints):**
  * `pk_local_batches`: `PRIMARY KEY (batch_id)`
* **Mecanismo de Sincronización:**
  * Refresco selectivo contra `GET /api/v1/inventory/items/{id}/batches`.

#### 9.5.3 `local_suppliers_cache` (Directorio Local de Proveedores Homologados)
Directorio de proveedores para verificación rápida de procedencia de repuestos.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `supplier_id` | `TEXT` | PK | Sí | - | Identificador del proveedor |
| `tenant_id` | `TEXT` | - | Sí | - | Taller automotriz |
| `business_name` | `TEXT` | - | Sí | - | Razón social del proveedor |
| `tax_id` | `TEXT` | - | Sí | - | RUC o identificación tributaria |
| `phone` | `TEXT` | - | No | `null` | Teléfono de contacto |
| `synced_at` | `TEXT` | - | Sí | - | Marca temporal de sincronización (ISO-8601) |

* **Restricciones (Constraints):**
  * `pk_local_suppliers`: `PRIMARY KEY (supplier_id)`
* **Mecanismo de Sincronización:**
  * Descarga estática mediante `GET /api/v1/inventory/suppliers`.

#### 9.5.4 `offline_inventory_reservations` (Cola Transaccional de Reservas en Foso)
Encola solicitudes de reserva y consumo de repuestos originadas desde el foso mecánico mientras el dispositivo permanece desconectado.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `reservation_id` | `TEXT` | PK | Sí | - | Identificador único de la reserva local |
| `work_order_id` | `TEXT` | - | Sí | - | Orden de trabajo que demanda la pieza |
| `task_id` | `TEXT` | - | Sí | - | Tarea específica de montaje |
| `item_id` | `TEXT` | - | Sí | - | Repuesto reservado |
| `requested_quantity` | `REAL` | - | Sí | - | Cantidad solicitada a apartar |
| `status` | `TEXT` | - | Sí | `'PENDING'` | Estado (`PENDING`, `SYNCED`, `FAILED`) |
| `retry_count` | `INTEGER` | - | Sí | `0` | Contador de reintentos |
| `created_at` | `TEXT` | - | Sí | - | Marca temporal de solicitud en foso (ISO-8601) |
| `synced_at` | `TEXT` | - | No | `null` | Marca temporal de sincronización (ISO-8601) |

* **Restricciones (Constraints):**
  * `pk_offline_inventory_reservations`: `PRIMARY KEY (reservation_id)`
  * `chk_reservation_status`: `CHECK (status IN ('PENDING', 'SYNCED', 'FAILED'))`
* **Índices Físicos (B-Tree):**
  * `idx_reservations_status`: B-Tree sobre `(status, created_at)`
* **Mecanismo de Sincronización:**
  * Drenaje idempotente hacia `POST /api/v1/inventory/items/{id}/allocate` al reconectar.

---

### 9.6 Persistencia Local de Human Resources Management Context (HR)

#### 9.6.1 `local_attendance_cache` (Historial Local de Marcaciones del Técnico)
Caché local que almacena las marcaciones presenciales de la jornada en curso y días previos del operario titular del dispositivo móvil.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `TEXT` | PK | Sí | - | Identificador de la marcación |
| `tenant_id` | `TEXT` | - | Sí | - | Taller empleador |
| `branch_id` | `TEXT` | - | Sí | - | Sede física |
| `membership_id` | `TEXT` | - | Sí | - | Colaborador |
| `shift_id` | `TEXT` | - | Sí | - | Turno evaluado |
| `clock_in` | `TEXT` | - | Sí | - | Fecha y hora de entrada (ISO-8601) |
| `clock_out` | `TEXT` | - | No | `null` | Fecha y hora de salida (ISO-8601) |
| `status` | `TEXT` | - | Sí | - | Calificación (`on_time`, `late`, `excused`, `absent`) |
| `latitude` | `REAL` | - | Sí | - | Latitud satelital registrada |
| `longitude` | `REAL` | - | Sí | - | Longitud satelital registrada |
| `distance_to_branch_m` | `INTEGER` | - | Sí | `0` | Distancia calculada en metros |
| `synced_at` | `TEXT` | - | Sí | - | Marca temporal de sincronización (ISO-8601) |

* **Restricciones (Constraints):**
  * `pk_local_attendance`: `PRIMARY KEY (id)`
* **Mecanismo de Sincronización:**
  * Consulta periódica y descarga de marcaciones mediante `GET /api/v1/hr/attendance/my-record`.

#### 9.6.2 `local_shift_cache` (Caché de Turnos y Franjas Horarias)
Almacena la configuración de turnos y márgenes de tolerancia del taller para evaluar localmente en tiempo real el cumplimiento del horario de ingreso antes de transmitir.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `TEXT` | PK | Sí | - | Identificador del turno |
| `tenant_id` | `TEXT` | - | Sí | - | Taller automotriz |
| `name` | `TEXT` | - | Sí | - | Denominación del turno |
| `start_time` | `TEXT` | - | Sí | - | Hora de entrada programada (HH:MM:SS) |
| `end_time` | `TEXT` | - | Sí | - | Hora de salida programada (HH:MM:SS) |
| `grace_period_m` | `INTEGER` | - | Sí | `15` | Tolerancia de tardanza en minutos |
| `synced_at` | `TEXT` | - | Sí | - | Marca temporal de sincronización (ISO-8601) |

* **Restricciones (Constraints):**
  * `pk_local_shift`: `PRIMARY KEY (id)`
* **Mecanismo de Sincronización:**
  * Refresco periódico mediante `GET /api/v1/hr/work-shifts`.

#### 9.6.3 `offline_attendance_mutations` (Buffer Transaccional de Marcaciones GPS en Patio)
Buffer transaccional para la captura y encolado de marcaciones de ingreso y salida tomadas con geolocalización satelital en el patio del taller ante caídas de cobertura inalámbrica.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `mutation_id` | `TEXT` | PK | Sí | - | Identificador técnico de la mutación local |
| `membership_id` | `TEXT` | - | Sí | - | Colaborador que efectúa el marcaje |
| `action_type` | `TEXT` | - | Sí | - | Tipo de marcación (`CLOCK_IN`, `CLOCK_OUT`) |
| `timestamp` | `TEXT` | - | Sí | - | Momento exacto de la marcación en patio (ISO-8601) |
| `latitude` | `REAL` | - | Sí | - | Coordenada satelital de latitud al momento del clic |
| `longitude` | `REAL` | - | Sí | - | Coordenada satelital de longitud al momento del clic |
| `status` | `TEXT` | - | Sí | `'PENDING'` | Estado de sincronización (`PENDING`, `SYNCED`, `FAILED`) |
| `retry_count` | `INTEGER` | - | Sí | `0` | Reintentos efectuados |
| `created_at` | `TEXT` | - | Sí | - | Marca temporal de creación en dispositivo (ISO-8601) |
| `synced_at` | `TEXT` | - | No | `null` | Marca temporal de replicación exitosa (ISO-8601) |

* **Restricciones (Constraints):**
  * `pk_offline_attendance_mutations`: `PRIMARY KEY (mutation_id)`
  * `chk_attendance_mutation_status`: `CHECK (status IN ('PENDING', 'SYNCED', 'FAILED'))`
* **Índices Físicos (B-Tree):**
  * `idx_mutations_status`: B-Tree sobre `(status, created_at)`
* **Mecanismo de Sincronización:**
  * Drenaje idempotente mediante `POST /api/v1/hr/attendance/clock-in` o `POST /api/v1/hr/attendance/clock-out` enviando el `mutation_id` como clave de idempotencia.
---

### 9.7 Persistencia Local de Invoicing & Compliance Context

#### 9.7.1 `local_voucher_status_cache` (Caché Local de Saldos y Comprobantes por Orden de Trabajo)
Almacena réplicas indexadas de comprobantes fiscales emitidos y saldos pendientes de pago asociados a órdenes de trabajo, permitiendo a los recepcionistas y jefes de patio verificar en frío y en milisegundos si un vehículo cuenta con autorización económica de salida sin requerir conectividad a Internet.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `TEXT` | PK | Sí | - | Identificador unívoco del comprobante fiscal (UUID texto) |
| `work_order_id` | `TEXT` | - | Sí | - | Orden de trabajo vinculada para resolución local en patio |
| `voucher_serie` | `TEXT` | - | Sí | - | Serie formal del comprobante (ej. `F001`, `B001`) |
| `voucher_number` | `INTEGER` | - | Sí | - | Número correlativo formal del comprobante emitido |
| `voucher_type` | `TEXT` | - | Sí | - | Código fiscal SUNAT (`01`, `03`, `07`, `08`) |
| `total_amount` | `REAL` | - | Sí | - | Importe total liquidado facturado al cliente |
| `pending_balance` | `REAL` | - | Sí | - | Saldo pendiente por amortizar ($0.0$ = Pagado) |
| `status` | `TEXT` | - | Sí | - | Estado de liquidación (`draft`, `issued`, `accepted_sunat`, `voided`) |
| `pdf_url` | `TEXT` | - | No | `null` | Enlace local o remoto a la representación impresa en PDF |
| `synced_at` | `TEXT` | - | Sí | - | Marca temporal de sincronización con la nube (ISO-8601) |

* **Restricciones (Constraints):**
  * `pk_local_voucher_status`: `PRIMARY KEY (id)`
* **Índices Físicos (B-Tree):**
  * `idx_local_vouchers_wo`: B-Tree sobre `(work_order_id)`
* **Mecanismo de Sincronización:**
  * Consulta periódica y refresco bajo demanda mediante `GET /api/v1/invoicing/vouchers/work-order/{id}`.

#### 9.7.2 `offline_payment_collections` (Buffer Transaccional de Cobros en Patio)
Búfer transaccional local que captura los cobros percibidos en efectivo o POS móvil en patio o foso mecánico mientras el dispositivo permanece desconectado, dotado de un identificador de idempotencia universal para garantizar entrega exactamente una vez (*Exactly-Once Delivery*).

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `collection_id` | `TEXT` | PK | Sí | - | UUID autogenerado localmente para garantizar idempotencia en la replicación |
| `voucher_id` | `TEXT` | - | No | `null` | Comprobante amortizado (si ya fue emitido previamente) |
| `work_order_id` | `TEXT` | - | Sí | - | Orden de trabajo cobrada en patio |
| `amount` | `REAL` | - | Sí | - | Monto dinerario recibido ($amount > 0.0$) |
| `payment_method` | `TEXT` | - | Sí | - | Medio de cobro (`cash`, `pos_card`, `mobile_wallet`) |
| `reference_code` | `TEXT` | - | No | `null` | Código de operación POS o número de voucher bancario |
| `status` | `TEXT` | - | Sí | `'PENDING'` | Estado de sincronización (`PENDING`, `SYNCED`, `FAILED`) |
| `created_at` | `TEXT` | - | Sí | - | Marca temporal de captura en el dispositivo móvil (ISO-8601) |
| `synced_at` | `TEXT` | - | No | `null` | Marca temporal de confirmación 200 OK del backend central (ISO-8601) |

* **Restricciones (Constraints):**
  * `pk_offline_payment_collections`: `PRIMARY KEY (collection_id)`
  * `chk_offline_payment_status`: `CHECK (status IN ('PENDING', 'SYNCED', 'FAILED'))`
* **Índices Físicos (B-Tree):**
  * `idx_offline_payments_status`: B-Tree sobre `(status, created_at)`
  * `idx_offline_payments_wo`: B-Tree sobre `(work_order_id)`
* **Mecanismo de Sincronización:**
  * Drenaje idempotente mediante `POST /api/v1/invoicing/payments/offline-sync` transmitiendo el `collection_id` como clave de idempotencia al restablecerse la conexión de red.

---

### 9.8 Persistencia Local de SaaS Billing & Subscriptions Context

#### 9.8.1 `local_subscription_cache` (Caché Local de Cuotas y Vigencia de Suscripción por Taller)
Almacena una réplica local compacta de los límites cuantitativos autorizados del plan contratado y la fecha de expiración de cobertura, permitiendo al dispositivo evaluar instantáneamente y sin latencia si el taller dispone de margen para crear nuevas órdenes de trabajo, registrar técnicos o acceder a módulos avanzados.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `TEXT` | PK | Sí | - | Identificador único canónico de la suscripción (UUID texto) |
| `tenant_id` | `TEXT` | UK | Sí | - | Taller titular para resolución unívoca |
| `plan_name` | `TEXT` | - | Sí | - | Nombre comercial del plan contratado (ej. "Professional") |
| `plan_tier` | `TEXT` | - | Sí | - | Nivel comercial (`COMMUNITY`, `STARTER`, `PROFESSIONAL`, `ENTERPRISE`) |
| `subscription_status` | `TEXT` | - | Sí | - | Estado contractual vigente (`active`, `trialing`, `past_due`, `canceled`) |
| `max_branches` | `INTEGER` | - | Sí | - | Cuota local máxima autorizada de sedes físicas |
| `max_active_staff` | `INTEGER` | - | Sí | - | Límite local de colaboradores activos simultáneos |
| `max_monthly_work_orders` | `INTEGER` | - | Sí | - | Techo mensual de órdenes de trabajo permitidas |
| `iot_telemetry_enabled` | `INTEGER` | - | Sí | `0` | Flag numérico SQLite (`1` = Habilitado, `0` = Bloqueado) para telemetría |
| `ai_diagnostics_enabled` | `INTEGER` | - | Sí | `0` | Flag numérico SQLite (`1` = Habilitado, `0` = Bloqueado) para IA diagnóstica |
| `current_period_end` | `TEXT` | - | Sí | - | Marca temporal UTC en formato ISO-8601 de expiración de cobertura |
| `synced_at` | `TEXT` | - | Sí | - | Marca temporal ISO-8601 del último refresco ETag con el servidor |

* **Restricciones (Constraints):**
  * `pk_local_subscription_cache`: `PRIMARY KEY (id)`
  * `uk_local_sub_tenant`: `UNIQUE (tenant_id)`
* **Índices Físicos (B-Tree):**
  * `idx_local_sub_tenant`: B-Tree sobre `(tenant_id)`
* **Mecanismo de Sincronización:**
  * Refresco condicional eficiente mediante `GET /api/v1/billing/subscriptions/tenant-quota` con encabezado HTTP `If-None-Match` (ETag), respondiendo HTTP 304 Not Modified cuando no existan modificaciones.

#### 9.8.2 `local_plan_features_cache` (Caché Local de Capacidades Modulares Habilitadas)
Mantiene el desglose de flags booleanos correspondientes a los módulos tecnológicos avanzados autorizados para el taller, gobernando de manera determinista la visibilidad de componentes en la interfaz de la aplicación móvil.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `feature_id` | `TEXT` | PK | Sí | - | Identificador canónico de la característica modular en texto |
| `tenant_id` | `TEXT` | - | Sí | - | Taller titular al cual se asocia la funcionalidad |
| `feature_key` | `TEXT` | UK | Sí | - | Clave alfanumérica de la funcionalidad (ej. `OBD2_TELEMETRY`) |
| `is_enabled` | `INTEGER` | - | Sí | `1` | Flag numérico SQLite (`1` = Activa, `0` = Inactiva) |
| `synced_at` | `TEXT` | - | Sí | - | Marca temporal ISO-8601 de sincronización con el backend central |

* **Restricciones (Constraints):**
  * `pk_local_plan_features`: `PRIMARY KEY (feature_id)`
  * `uk_local_features_tenant_key`: `UNIQUE (tenant_id, feature_key)`
* **Índices Físicos (B-Tree):**
  * `idx_local_features_tenant`: B-Tree sobre `(tenant_id)`
* **Mecanismo de Sincronización:**
  * Descarga incremental delta conjunta con la actualización de cuotas del plan de suscripción.

---

### 9.9 Persistencia Local de IoT Telemetry & Predictive Maintenance Context

#### 9.9.1 `local_telemetry_buffer` (Buffer Transaccional Desconectado de Tramas Sensoriales BLE)
Amortiguador transaccional local en terminales móviles para la captura e ingesta en frío de lecturas sensoriales de la ECU vehicular (PIDs OBD-II vía ELM327 Bluetooth LE) ante pérdidas de conectividad en carretera, sótano o foso de inspección.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `id` | `TEXT` | PK | Sí | - | Identificador técnico único de la lectura telemática (UUID texto) |
| `vehicle_id` | `TEXT` | - | Sí | - | Identificador del automotor que emite las señales |
| `timestamp` | `TEXT` | - | Sí | - | Marca temporal de captura por el adaptador OBD-II (ISO-8601) |
| `speed` | `INTEGER` | - | No | `null` | Velocidad reportada en km/h |
| `rpm` | `INTEGER` | - | No | `null` | Revoluciones por minuto del motor |
| `engine_temp_c` | `REAL` | - | No | `null` | Temperatura del refrigerante de motor en °C |
| `battery_voltage` | `REAL` | - | No | `null` | Voltaje medido en bornes de batería |
| `fuel_level` | `REAL` | - | No | `null` | Nivel relativo de combustible en porcentaje ($0.0 - 100.0$) |
| `latitude` | `REAL` | - | No | `null` | Coordenada satelital de latitud al momento de la muestra |
| `longitude` | `REAL` | - | No | `null` | Coordenada satelital de longitud al momento de la muestra |
| `sync_status` | `TEXT` | - | Sí | `'PENDING'` | Estado en cola local (`PENDING`, `SYNCED`, `FAILED`) |
| `created_at` | `TEXT` | - | Sí | - | Marca temporal de persistencia en SQLite (ISO-8601) |

* **Restricciones (Constraints):**
  * `pk_local_telem`: `PRIMARY KEY (id)`
  * `chk_local_telem_sync`: `CHECK (sync_status IN ('PENDING', 'SYNCED', 'FAILED'))`
* **Índices Físicos (B-Tree):**
  * `idx_local_telem_status`: B-Tree sobre `(sync_status, timestamp)`
  * `idx_local_telem_vehicle`: B-Tree sobre `(vehicle_id)`
* **Mecanismo de Sincronización:**
  * Drenaje transaccional por lotes (*Batch Ingestion*) mediante `POST /api/v1/iot/telemetry/ingest/batch` al reestablecer enlace de red móvil o Wi-Fi.

#### 9.9.2 `local_vehicle_faults_cache` (Caché Móvil de Averías y Códigos DTC)
Caché local de averías y códigos de falla leídos desde la ECU, permitiendo a mecánicos en foso y conductores en ruta auditar de inmediato la severidad y descripción de anomalías sin latencia ni dependencia de servidores remotos.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `fault_id` | `TEXT` | PK | Sí | - | Identificador técnico del fallo diagnosticado (UUID texto) |
| `vehicle_id` | `TEXT` | - | Sí | - | Automotor diagnosticado |
| `dtc_code` | `TEXT` | - | Sí | - | Código alfanumérico normativo SAE J2012 (ej. `P0300`, `P0420`) |
| `severity` | `TEXT` | - | Sí | - | Criticidad operativa (`low`, `medium`, `critical`) |
| `description` | `TEXT` | - | Sí | - | Glosa técnica explicativa del subsistema afectado |
| `detected_at` | `TEXT` | - | Sí | - | Marca temporal de lectura por el escáner (ISO-8601) |
| `synced_at` | `TEXT` | - | Sí | - | Marca temporal de sincronización con la nube (ISO-8601) |

* **Restricciones (Constraints):**
  * `pk_local_faults`: `PRIMARY KEY (fault_id)`
* **Índices Físicos (B-Tree):**
  * `idx_local_faults_vehicle`: B-Tree sobre `(vehicle_id)`
  * `idx_local_faults_code`: B-Tree sobre `(dtc_code)`
* **Mecanismo de Sincronización:**
  * Consulta periódica y descarga de fallas activas mediante `GET /api/v1/iot/faults/vehicle/{vehicleId}`.

#### 9.9.3 `local_predictive_alerts_cache` (Historial Móvil de Alertas Preventivas y Notificaciones Push)
Registro local de advertencias preventivas recibidas desde la nube o inferidas por el dispositivo móvil, resguardando el historial para visualización reactiva en la interfaz de usuario de Atelier Driver y Atelier Workshop Mobile.

| Atributo | Tipo de Dato | Llave | Req. | Default | Descripción |
|---|---|---|---|---|---|
| `alert_id` | `TEXT` | PK | Sí | - | Identificador de la alerta preventiva (UUID texto) |
| `vehicle_id` | `TEXT` | - | Sí | - | Automotor evaluado por el modelo inferencial |
| `alert_type` | `TEXT` | - | Sí | - | Tipo de anomalía (`overheating_risk`, `battery_drain`, etc.) |
| `confidence_score` | `REAL` | - | Sí | - | Certeza estadística calculada en porcentaje ($75.0 - 100.0$) |
| `message` | `TEXT` | - | Sí | - | Mensaje preventivo comprensible orientado al conductor |
| `status` | `TEXT` | - | Sí | - | Estado de la alerta (`dispatched`, `acknowledged`, `resolved`) |
| `created_at` | `TEXT` | - | Sí | - | Marca temporal de emisión de la alerta (ISO-8601) |
| `synced_at` | `TEXT` | - | Sí | - | Marca temporal de confirmación o recepción local (ISO-8601) |

* **Restricciones (Constraints):**
  * `pk_local_alerts`: `PRIMARY KEY (alert_id)`
* **Índices Físicos (B-Tree):**
  * `idx_local_alerts_vehicle`: B-Tree sobre `(vehicle_id, created_at)`
* **Mecanismo de Sincronización:**
  * Ingesta automática mediante notificaciones push de datos de Firebase Cloud Messaging (FCM) y refresco periódico desde `GET /api/v1/iot/alerts/vehicle/{vehicleId}`.
