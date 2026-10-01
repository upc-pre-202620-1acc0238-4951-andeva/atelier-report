# Especificación Canónica de Roles y Permisos RBAC de Atelier Platform

Este documento define la arquitectura de control de acceso basada en roles (RBAC) para el ecosistema **Atelier Platform Backend**. Establece formalmente los ocho roles predeterminados de fábrica, el catálogo inmutable de permisos atómicos y su correspondencia estricta con los controladores y endpoints de la API REST, así como las directrices para la asignación de múltiples roles por usuario y la creación de roles personalizados por taller.

---

## 1. Arquitectura del Modelo de Control de Acceso (RBAC Híbrido)

El control de acceso en Atelier se implementa como un modelo jerárquico de tres capas articulado dentro del Bounded Context **IAM & Tenancy** (`com.andeva.atelier.platform.iam`):

```text
[ Nivel 1: Catálogo de Permisos Atómicos ]  -> Inmutable, 100% definido por el código de la plataforma
                    ↓
[ Nivel 2: Plantillas de Fábrica de la Plataforma ] -> 8 perfiles base estándar para el rubro automotriz
                    ↓
[ Nivel 3: Roles Soberanos del Taller ]     -> Aprovisionados de fábrica (is_system_role = true) y personalizados (is_system_role = false)
```

### 1.1. Principios Fundamentales del Modelo
1. **Los Permisos son Atómicos y Representan Capacidades de Endpoints:** Cada permiso codifica una facultad de negocio que protege uno o más métodos de controladores REST específicos (`@PreAuthorize("hasAuthority('...')")`). Los permisos atómicos no pueden ser creados ni modificados arbitrariamente por los usuarios de los talleres, ya que están directamente anclados a la implementación del backend.
2. **Soporte Nativo de Multi-Rol por Membresía (Relación M:N):** La tabla asociativa [`membership_roles`](file:///home/shouy/development/atelier-report/docs/atelier-database-schema.md#L263) vincula una membresía institucional de un taller con múltiples roles en simultáneo. Esto permite que una misma persona asuma responsabilidades cruzadas sin necesidad de duplicar cuentas ni crear roles artificiales combinados.
3. **Consolidación en Memoria y Token JWT O(1):** Durante la autenticación, el servicio `BearerTokenService` recopila los permisos de todos los roles asignados a la membresía, genera la unión matemática sin duplicados (`Set<Permission>`) y la serializa en los *claims* del token JWT (`claims.permissions`). El filtro perimetral `BearerAuthorizationRequestFilter` evalúa la autorización en memoria sin consultar la base de datos en cada petición HTTP.
4. **Aprovisionamiento Automático de Roles por Taller (Tenant Role Provisioning):** Al registrarse un taller automotriz mediante `POST /api/v1/auth/sign-up`, el servicio `RoleProvisioningService` clona automáticamente los ocho roles de fábrica con el `tenant_id` específico del taller e inicializa sus permisos predeterminados en la tabla `role_permissions`. Todos los roles persisten con la clave foránea `tenant_id` obligatoria.
5. **Soberanía y Edición de Roles por Taller:** Cada taller es soberano de sus propios roles. El Dueño o Administrador puede editar los permisos asignados a cualquier rol del taller (tanto de fábrica como personalizado) para adaptar el acceso a su dinámica de trabajo particular, sin afectar en lo absoluto a los demás talleres registrados en la plataforma. Los roles aprovisionados de fábrica se distinguen mediante la bandera `is_system_role = true`, impidiendo su eliminación física o lógica, y pueden ser restablecidos a sus permisos predeterminados de plataforma en cualquier momento.

---

## 2. Catálogo Canónico de los 8 Roles de Fábrica (*System Roles*)

La plataforma proporciona de fábrica ocho roles estandarizados para el rubro automotriz:

### 2.1. Dueño de Taller (`ROLE_WORKSHOP_OWNER`)
* **Propósito:** Titular legal y comercial de la cuenta SaaS en Atelier Platform.
* **Ámbito de Acción:** Gobernanza corporativa, facturación SaaS de la suscripción, cumplimiento tributario ante SUNAT y balances financieros.
* **Responsabilidades Clave:**
  * Gestión de suscripciones, actualización de planes B2B y métodos de pago mediante la pasarela Stripe.
  * Configuración fiscal institucional: RUC, razón social, certificado digital, series de comprobantes y credenciales del Proveedor de Servicios Electrónicos (PSE).
  * Creación y gestión de sedes físicas y geocercas circulares de control perimétrico.
  * Supervisión ejecutiva de flujos de caja y analítica gerencial de rentabilidad.

### 2.2. Administrador de Taller (`ROLE_WORKSHOP_ADMINISTRATOR`)
* **Propósito:** Gerencia operativa diaria del taller mecánico.
* **Ámbito de Acción:** Recursos humanos, asignación de roles a colaboradores, programación de turnos y aprobación de compras.
* **Responsabilidades Clave:**
  * Emisión y revocación de invitaciones laborales para nuevos empleados.
  * Asignación de roles de fábrica o personalizados a las membresías del personal.
  * Configuración de calendarios laborales, turnos semanales y márgenes de tolerancia de asistencia.
  * Aprobación de órdenes de compra a proveedores de repuestos y revisión de descargos contables.
  * Supervisión global de órdenes de trabajo en patio y bahías.

### 2.3. Mecánico Jefe / Jefe de Taller (`ROLE_CHIEF_MECHANIC`)
* **Propósito:** Liderazgo técnico, distribución de carga laboral y aseguramiento de la calidad en patio.
* **Ámbito de Acción:** Asignación de bahías en tiempo real, supervisión de tiempos de fosa y validación técnica pericial.
* **Responsabilidades Clave:**
  * Asignación y reasignación dinámica de bahías de servicio y mecánicos sobre el tablero operativo en tiempo real.
  * Autorización y validación formal de suspensiones de tareas por piezas defectuosas o insumos faltantes (*holds*).
  * Revisión de informes periciales predictivos generados por Spring AI y validación de diagnósticos complejos.
  * Control de calidad final antes de autorizar la entrega técnica del vehículo.

### 2.4. Asesor de Servicio (`ROLE_SERVICE_ADVISOR`)
* **Propósito:** Enlace técnico-comercial directo entre el cliente y el equipo operativo de taller.
* **Ámbito de Acción:** Patio de recepción, inspección física 360°, formulación de cotizaciones y entrega vehicular.
* **Responsabilidades Clave:**
  * Apertura formal de órdenes de trabajo y parametrización de tareas iniciales requeridas por el cliente.
  * Realización del inventario pericial de recepción física y carga inmutable de fotografías periciales hacia Amazon S3.
  * Traducción de síntomas y fallas del cliente a requerimientos técnicos formales.
  * Elaboración, cálculo automático de impuestos y remisión de proformas comerciales en PDF.
  * Notificación y sustento técnico ante el cliente para la aprobación de tareas adicionales detectadas en foso.
  * Entrega técnica final del vehículo en patio explicando los trabajos concluidos y emisión del pase de salida.

### 2.5. Recepcionista (`ROLE_RECEPTIONIST`)
* **Propósito:** Atención de counter de entrada, bienvenida al cliente y gestión de agenda de visitas.
* **Ámbito de Acción:** Sala de recepción, teléfono, mensajería institucional y agenda del taller.
* **Responsabilidades Clave:**
  * Bienvenida, saludo y registro de clientes en mostrador verificando DNI o RUC.
  * Búsqueda y vinculación del automóvil mediante placa de rodaje.
  * Alta y afiliación de clientes en la plataforma distinguiendo si ya poseen cuenta previa en Atelier.
  * Agendamiento y confirmación de citas en el calendario del taller.
  * Derivación del cliente y vehículo al Asesor de Servicio en patio.

### 2.6. Técnico Mecánico (`ROLE_MECHANIC`)
* **Propósito:** Ejecución directa de labores mecánicas, eléctricas y de diagnóstico en bahía o foso.
* **Ámbito de Acción:** Bahía de servicio asignada, utilizando la aplicación móvil *Atelier Workshop Mobile*.
* **Responsabilidades Clave:**
  * Marcación de ingreso y salida laboral validada mediante geocerca GPS satelital.
  * Visualización y priorización de tareas mecánicas asignadas en su dispositivo móvil.
  * Cronometraje de labor efectiva por tarea, registro de pausas operativas y cómputo de horas hombre.
  * Registro fotográfico pericial de desmontaje y montaje de piezas en foso con subida directa a la nube.
  * Sincronización inalámbrica Bluetooth con escáneres OBD-II estándar en bahía.
  * Extracción, decodificación y borrado de códigos de falla DTC en la computadora automotriz.

### 2.7. Encargado de Inventario (`ROLE_INVENTORY_MANAGER`)
* **Propósito:** Custodia física, catalogación y valoración contable de repuestos, lubricantes e insumos.
* **Ámbito de Acción:** Almacén de autopartes, compras y abastecimiento de bahías.
* **Responsabilidades Clave:**
  * Mantenimiento del catálogo de repuestos y asociación con proveedores comerciales.
  * Creación y gestión de órdenes de compra para reposición de inventario.
  * Recepción de lotes de repuestos registrando costo unitario de adquisición para el costeo FIFO.
  * Descargo contable automatizado de piezas imputadas a tareas mecánicas bajo regla estricta FIFO por lote.
  * Reincorporación lógica y física de materiales al almacén en caso de cancelación de tareas.
  * Monitoreo y resolución de alertas automáticas por nivel de stock mínimo.

### 2.8. Cajero (`ROLE_CASHIER`)
* **Propósito:** Recaudación económica, cobranza y liquidación tributaria de servicios.
* **Ámbito de Acción:** Caja, mostrador de pagos y facturación electrónica.
* **Responsabilidades Clave:**
  * Liquidación económica automática en cascada de órdenes de trabajo finalizadas.
  * Registro de recaudación y amortización de pagos multi-medio: efectivo, tarjeta POS, transferencias y billeteras digitales (Yape/Plin).
  * Emisión de comprobantes de pago electrónicos oficiales (Boletas y Facturas bajo estándar UBL 2.1 ante SUNAT vía PSE).
  * Validación del estado pagado para autorizar el pase de salida vehicular.

---

## 3. Análisis Diferencial: Recepcionista frente a Asesor de Servicio

Es esencial contrastar la naturaleza de estos dos roles para evitar solapamientos y clarificar la frontera de permisos:

| Vector de Comparación | Recepcionista (`ROLE_RECEPTIONIST`) | Asesor de Servicio (`ROLE_SERVICE_ADVISOR`) |
| :--- | :--- | :--- |
| **Naturaleza del Rol** | Administrativo, asistencial y de atención al cliente en mostrador. | Técnico-comercial, peritaje automotriz y presupuestación en patio. |
| **Conocimiento Técnico** | Manejo de CRM, agenda de citas y trato protocolar con usuarios. | Criterio mecánico, diagnóstico de averías, normas de peritaje y desglose de mano de obra. |
| **Puesto de Operación** | Counter o recepción frontal del taller. | Patio de maniobras, junto al automóvil en la bahía de recepción. |
| **Responsabilidad Pericial** | Ninguna. No evalúa desgastes, averías mecánicas ni niveles de fluidos. | Total. Realiza la inspección física 360°, registra daños y toma fotografías periciales. |
| **Manejo de Dinero/Presupuesto**| No formula proformas ni presupuesta piezas. Deriva la cotización. | Formula presupuestos, calcula costos en cascada y sustenta costos ante el cliente. |
| **Pase de Salida y Entrega** | Puede verificar la cita, pero no realiza la explicación técnica de entrega. | Conduce la entrega final, explica los trabajos realizados y entrega el vehículo al cliente. |

---

## 4. Catálogo Canónico de Permisos Atómicos y Endpoints de Atelier

Cada permiso atómico se define con precisión funcional y corresponde a los controladores REST documentados en los ocho Bounded Contexts de Atelier:

### 4.1. Bounded Context IAM & Tenancy (`iam:*`)

| Permiso Atómico | Descripción Funcional | Endpoints REST Vinculados |
| :--- | :--- | :--- |
| `iam:tenants:read` | Consultar perfil y configuración del taller actual | `GET /api/v1/tenants/current` |
| `iam:tenants:update` | Actualizar nombre y razón social del taller | `PUT /api/v1/tenants/current` |
| `iam:branches:read` | Consultar sedes de operación y geocercas | `GET /api/v1/branches`, `GET /api/v1/branches/{id}` |
| `iam:branches:manage` | Crear sedes y configurar coordenadas GPS y radio de geocerca | `POST /api/v1/branches`, `PUT /api/v1/branches/{id}/location` |
| `iam:members:read` | Consultar personal del taller y sus estados | `GET /api/v1/tenants/{tenantId}/memberships` |
| `iam:members:invite` | Emitir invitaciones laborales a nuevos colaboradores por correo | `POST /api/v1/invitations/tenant/{tenantId}` |
| `iam:members:manage_roles`| Asignar o revocar roles de seguridad a miembros del taller | `PUT /api/v1/tenants/{tenantId}/memberships/{id}/roles` |
| `iam:members:compensate` | Modificar esquemas de remuneración salarial (fijo o por hora) | `PUT /api/v1/tenants/{tenantId}/memberships/{id}/compensation` |
| `iam:roles:read` | Consultar roles de fábrica y personalizados del taller | `GET /api/v1/tenants/{tenantId}/roles` |
| `iam:roles:create` | Crear roles personalizados combinando permisos del catálogo | `POST /api/v1/tenants/{tenantId}/roles` |
| `iam:permissions:read` | Consultar el catálogo transversal de permisos atómicos | `GET /api/v1/permissions` |

### 4.2. Bounded Context CRM & Fleet Management (`crm:*`)

| Permiso Atómico | Descripción Funcional | Endpoints REST Vinculados |
| :--- | :--- | :--- |
| `crm:customers:read` | Buscar y consultar clientes por documento o datos de contacto | `GET /api/v1/crm/customers`, `GET /api/v1/crm/customers/{id}` |
| `crm:customers:create` | Dar de alta a nuevos clientes propietarios de vehículos | `POST /api/v1/crm/customers` |
| `crm:customers:update` | Modificar datos personales o fiscales del cliente | `PUT /api/v1/crm/customers/{id}` |
| `crm:vehicles:read` | Consultar vehículos por placa, VIN o historial de servicio | `GET /api/v1/crm/vehicles`, `GET /api/v1/crm/vehicles/{id}` |
| `crm:vehicles:create` | Registrar nuevos vehículos y asociarlos a su propietario | `POST /api/v1/crm/vehicles` |
| `crm:vehicles:update` | Actualizar odómetro, kilometraje y especificaciones técnicas | `PUT /api/v1/crm/vehicles/{id}` |
| `crm:fleets:manage` | Administrar flotas vehiculares corporativas y contratos B2B | `GET /api/v1/crm/fleets`, `POST /api/v1/crm/fleets` |

### 4.3. Bounded Context Workshop Operations / MRO (`operations:*`)

| Permiso Atómico | Descripción Funcional | Endpoints REST Vinculados |
| :--- | :--- | :--- |
| `operations:work_orders:read` | Consultar órdenes de trabajo, estados y detalles | `GET /api/v1/operations/work-orders`, `GET /api/v1/operations/work-orders/{id}` |
| `operations:work_orders:create`| Abrir nuevas órdenes de trabajo y configurar tareas iniciales | `POST /api/v1/operations/work-orders` |
| `operations:work_orders:cancel`| Cancelar órdenes de trabajo por desistimiento o inviabilidad | `POST /api/v1/operations/work-orders/{id}/cancel` |
| `operations:inspections:create`| Registrar el checklist pericial de recepción e inventario 360° | `POST /api/v1/operations/inspections` |
| `operations:inspections:upload_photos`| Cargar fotografías de evidencias de daños con URLs firmadas S3 | `POST /api/v1/operations/inspections/{id}/photos` |
| `operations:quotations:read` | Consultar cotizaciones y proformas de mantenimiento | `GET /api/v1/operations/quotations`, `GET /api/v1/operations/quotations/{id}` |
| `operations:quotations:create`| Elaborar presupuestos con cómputo en cascada de mano de obra | `POST /api/v1/operations/quotations` |
| `operations:quotations:send` | Generar y enviar proformas comerciales en PDF al cliente | `POST /api/v1/operations/quotations/{id}/send-pdf` |
| `operations:quotations:approve`| Registrar la resolución formal de aprobación del presupuesto | `POST /api/v1/operations/quotations/{id}/approve` |
| `operations:proposals:create` | Proponer tareas adicionales por averías detectadas en foso | `POST /api/v1/operations/proposals` |
| `operations:proposals:notify` | Remitir propuesta adicional al cliente para autorización técnica | `POST /api/v1/operations/proposals/{id}/notify` |
| `operations:tasks:read` | Consultar tareas mecánicas asignadas a bahías | `GET /api/v1/operations/tasks`, `GET /api/v1/operations/tasks/{id}` |
| `operations:tasks:track_time` | Iniciar, pausar y reanudar cronómetros de labor efectiva | `POST /api/v1/operations/tasks/{id}/timer/start`, `POST /api/v1/operations/tasks/{id}/timer/pause` |
| `operations:tasks:upload_photos`| Adjuntar fotografías periciales de desmontaje y montaje | `POST /api/v1/operations/tasks/{id}/photos` |
| `operations:tasks:hold_request`| Solicitar suspensión de tarea por repuesto defectuoso o faltante | `POST /api/v1/operations/tasks/{id}/hold` |
| `operations:tasks:hold_validate`| Aprobar o resolver administrativamente la suspensión de tarea | `POST /api/v1/operations/tasks/{id}/resume` |
| `operations:tasks:complete` | Registrar el cierre técnico de la labor con cómputo de horas | `POST /api/v1/operations/tasks/{id}/complete` |
| `operations:bays:read` | Consultar disponibilidad y ocupación de bahías en tiempo real | `GET /api/v1/operations/bays` |
| `operations:bays:reassign` | Reasignar mecánicos y vehículos entre bahías operativas | `POST /api/v1/operations/bays/{id}/reassign` |
| `operations:vehicle_handover:execute`| Ejecutar entrega pericial del automóvil y validar pase de salida | `POST /api/v1/operations/work-orders/{id}/handover` |

### 4.4. Bounded Context Inventory & Supply Chain (`inventory:*`)

| Permiso Atómico | Descripción Funcional | Endpoints REST Vinculados |
| :--- | :--- | :--- |
| `inventory:parts:read` | Consultar catálogo de repuestos, precios y niveles de stock | `GET /api/v1/inventory/parts`, `GET /api/v1/inventory/parts/{id}` |
| `inventory:parts:manage` | Crear y actualizar especificaciones de piezas y compatibilidades | `POST /api/v1/inventory/parts`, `PUT /api/v1/inventory/parts/{id}` |
| `inventory:suppliers:manage` | Administrar catálogo de proveedores comerciales | `GET /api/v1/inventory/suppliers`, `POST /api/v1/inventory/suppliers` |
| `inventory:purchase_orders:read`| Consultar órdenes de compra emitidas a proveedores | `GET /api/v1/inventory/purchase-orders` |
| `inventory:purchase_orders:create`| Crear y formalizar órdenes de compra de abastecimiento | `POST /api/v1/inventory/purchase-orders` |
| `inventory:batches:receive` | Registrar ingreso físico de lotes de repuestos con costeo unitario | `POST /api/v1/inventory/batches/receive` |
| `inventory:batches:dispatch_fifo`| Ejecutar descargo contable automatizado bajo método FIFO | `POST /api/v1/inventory/batches/dispatch` |
| `inventory:batches:restore` | Reincorporar repuestos removidos de tareas canceladas | `POST /api/v1/inventory/batches/restore` |
| `inventory:alerts:read` | Consultar alertas de reposición por stock mínimo | `GET /api/v1/inventory/alerts` |
| `inventory:alerts:resolve` | Marcar alertas resueltas tras emitir orden de reposición | `POST /api/v1/inventory/alerts/{id}/resolve` |

### 4.5. Bounded Context Human Resources & Shifts (`hr:*`)

| Permiso Atómico | Descripción Funcional | Endpoints REST Vinculados |
| :--- | :--- | :--- |
| `hr:attendance:clock_in` | Registrar marcación de ingreso laboral con validación de geocerca GPS | `POST /api/v1/hr/attendance/clock-in` |
| `hr:attendance:clock_out` | Registrar marcación de salida y liquidar jornada efectiva | `POST /api/v1/hr/attendance/clock-out` |
| `hr:attendance:read_own` | Consultar historial propio de asistencias y tiempos de labor | `GET /api/v1/hr/attendance/me` |
| `hr:attendance:audit_all`| Auditar marcaciones, anomalías perimétricas y asistencias del taller | `GET /api/v1/hr/attendance/audit` |
| `hr:shifts:read` | Consultar programación semanal de turnos y tolerancias | `GET /api/v1/hr/shifts` |
| `hr:shifts:manage` | Configurar turnos, horarios laborales y márgenes de gracia | `POST /api/v1/hr/shifts`, `PUT /api/v1/hr/shifts/{id}` |
| `hr:justifications:create`| Enviar descargo justificatorio de tardanza o ausencia | `POST /api/v1/hr/justifications` |
| `hr:justifications:approve`| Aprobar o rechazar descargos de tardanza de colaboradores | `POST /api/v1/hr/justifications/{id}/review` |
| `hr:plame:export` | Exportar reportes de jornada laboral compatibles con SUNAT PLAME | `GET /api/v1/hr/reports/plame` |

### 4.6. Bounded Context Invoicing & Compliance (`invoicing:*`)

| Permiso Atómico | Descripción Funcional | Endpoints REST Vinculados |
| :--- | :--- | :--- |
| `invoicing:invoices:read` | Consultar comprobantes emitidos, notas de crédito y estados CDR | `GET /api/v1/invoicing/invoices`, `GET /api/v1/invoicing/invoices/{id}` |
| `invoicing:invoices:settle`| Preliquidar económicamente órdenes de trabajo finalizadas | `POST /api/v1/invoicing/settlements` |
| `invoicing:invoices:issue_sunat`| Emitir comprobantes tributarios electrónicos UBL 2.1 ante SUNAT vía PSE | `POST /api/v1/invoicing/invoices` |
| `invoicing:payments:create`| Registrar cobros y amortizaciones multimoneda y multimedio | `POST /api/v1/invoicing/payments` |
| `invoicing:exit_passes:issue`| Emitir pase digital de salida del vehículo tras orden pagada | `POST /api/v1/invoicing/exit-passes` |
| `invoicing:cashflow:export_pdf`| Generar y exportar reporte contable de flujo de caja en PDF | `GET /api/v1/invoicing/reports/cash-flow/pdf` |
| `invoicing:fiscal_config:manage`| Configurar certificados digitales, enlace PSE y series SUNAT | `GET /api/v1/invoicing/config`, `PUT /api/v1/invoicing/config` |

### 4.7. Bounded Context SaaS Billing & Subscriptions (`billing:*`)

| Permiso Atómico | Descripción Funcional | Endpoints REST Vinculados |
| :--- | :--- | :--- |
| `billing:subscriptions:read` | Consultar plan SaaS contratado, cuotas de uso y fecha de corte | `GET /api/v1/billing/subscriptions/current` |
| `billing:subscriptions:manage_stripe`| Gestionar suscripción B2B, cambio de plan y portal de facturación Stripe | `POST /api/v1/billing/checkout/session`, `POST /api/v1/billing/portal/session` |
| `billing:plans:read` | Consultar catálogo público de planes comerciales y tarifas | `GET /api/v1/billing/plans` |
| `billing:invoices:read` | Consultar facturas por el uso del servicio SaaS de Atelier | `GET /api/v1/billing/invoices` |

### 4.8. Bounded Context IoT Telemetry & Predictive Maintenance (`iot:*`)

| Permiso Atómico | Descripción Funcional | Endpoints REST Vinculados |
| :--- | :--- | :--- |
| `iot:devices:read` | Consultar catálogo de escáneres OBD-II y estados de hardware | `GET /api/v1/iot/devices`, `GET /api/v1/iot/devices/{id}` |
| `iot:devices:register` | Registrar nuevos escáneres OBD-II por dirección MAC y serial | `POST /api/v1/iot/devices` |
| `iot:installations:manage` | Vincular o desvincular escáneres a vehículos en bahía | `POST /api/v1/iot/installations`, `POST /api/v1/iot/installations/{id}/uninstall` |
| `iot:telemetry:ingest` | Ingestar lotes de métricas telemétricas hacia TimescaleDB | `POST /api/v1/iot/telemetry/batches` |
| `iot:telemetry:read` | Consultar lecturas telemétricas en vivo para tacómetros y análisis | `GET /api/v1/iot/telemetry/latest`, `GET /api/v1/iot/telemetry/aggregated` |
| `iot:faults:read` | Consultar fallas electrónicas activas y códigos DTC leídos | `GET /api/v1/iot/faults` |
| `iot:faults:resolve` | Verificar borrado y subsanación de códigos de falla en motor | `POST /api/v1/iot/faults/{id}/resolve` |
| `iot:alerts:read` | Consultar alertas analíticas generadas por anomalías térmicas | `GET /api/v1/iot/alerts` |
| `iot:alerts:acknowledge` | Confirmar recepción y lectura de alertas predictivas | `POST /api/v1/iot/alerts/{id}/acknowledge` |
| `iot:health_reports:generate`| Solicitar inferencia pericial con Spring AI Groq Cloud LPU | `POST /api/v1/iot/health-reports` |
| `iot:health_reports:read` | Descargar reporte forense de salud automotriz en PDF | `GET /api/v1/iot/health-reports/{id}/pdf` |

---

## 5. Matriz Consolidada de Roles y Permisos

La siguiente matriz detalla de forma exhaustiva los permisos atómicos asignados de fábrica a cada uno de los ocho roles estándar:

| Código de Permiso Atómico | Dueño | Admin | Mecánico Jefe | Asesor de Servicio | Recepcionista | Técnico Mecánico | Encargado Inventario | Cajero |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **IAM & Tenancy** | | | | | | | | |
| `iam:tenants:read` | Sí | Sí | Sí | Sí | Sí | Sí | Sí | Sí |
| `iam:tenants:update` | Sí | No | No | No | No | No | No | No |
| `iam:branches:read` | Sí | Sí | Sí | Sí | Sí | Sí | Sí | Sí |
| `iam:branches:manage` | Sí | Sí | No | No | No | No | No | No |
| `iam:members:read` | Sí | Sí | Sí | No | No | No | No | No |
| `iam:members:invite` | Sí | Sí | No | No | No | No | No | No |
| `iam:members:manage_roles` | Sí | Sí | No | No | No | No | No | No |
| `iam:members:compensate` | Sí | No | No | No | No | No | No | No |
| `iam:roles:read` | Sí | Sí | No | No | No | No | No | No |
| `iam:roles:create` | Sí | Sí | No | No | No | No | No | No |
| `iam:permissions:read` | Sí | Sí | No | No | No | No | No | No |
| **CRM & Fleet** | | | | | | | | |
| `crm:customers:read` | Sí | Sí | Sí | Sí | Sí | No | No | Sí |
| `crm:customers:create` | Sí | Sí | No | Sí | Sí | No | No | No |
| `crm:customers:update` | Sí | Sí | No | Sí | Sí | No | No | No |
| `crm:vehicles:read` | Sí | Sí | Sí | Sí | Sí | Sí | Sí | Sí |
| `crm:vehicles:create` | Sí | Sí | No | Sí | Sí | No | No | No |
| `crm:vehicles:update` | Sí | Sí | Sí | Sí | Sí | No | No | No |
| `crm:fleets:manage` | Sí | Sí | No | Sí | No | No | No | No |
| **Workshop Operations (MRO)** | | | | | | | | |
| `operations:work_orders:read` | Sí | Sí | Sí | Sí | Sí | Sí | Sí | Sí |
| `operations:work_orders:create` | Sí | Sí | Sí | Sí | No | No | No | No |
| `operations:work_orders:cancel` | Sí | Sí | No | No | No | No | No | No |
| `operations:inspections:create` | Sí | Sí | Sí | Sí | No | No | No | No |
| `operations:inspections:upload_photos` | Sí | Sí | Sí | Sí | No | No | No | No |
| `operations:quotations:read` | Sí | Sí | Sí | Sí | No | No | Sí | Sí |
| `operations:quotations:create` | Sí | Sí | Sí | Sí | No | No | No | No |
| `operations:quotations:send` | Sí | Sí | No | Sí | No | No | No | No |
| `operations:quotations:approve` | Sí | Sí | No | Sí | No | No | No | No |
| `operations:proposals:create` | Sí | Sí | Sí | Sí | No | Sí | No | No |
| `operations:proposals:notify` | Sí | Sí | No | Sí | No | No | No | No |
| `operations:tasks:read` | Sí | Sí | Sí | Sí | No | Sí | Sí | No |
| `operations:tasks:track_time` | No | No | Sí | No | No | Sí | No | No |
| `operations:tasks:upload_photos` | No | No | Sí | No | No | Sí | No | No |
| `operations:tasks:hold_request` | No | No | No | No | No | Sí | No | No |
| `operations:tasks:hold_validate`| Sí | Sí | Sí | No | No | No | No | No |
| `operations:tasks:complete` | No | No | Sí | No | No | Sí | No | No |
| `operations:bays:read` | Sí | Sí | Sí | Sí | No | Sí | No | No |
| `operations:bays:reassign` | Sí | Sí | Sí | No | No | No | No | No |
| `operations:vehicle_handover:execute` | Sí | Sí | No | Sí | No | No | No | No |
| **Inventory & Supply Chain** | | | | | | | | |
| `inventory:parts:read` | Sí | Sí | Sí | Sí | No | Sí | Sí | No |
| `inventory:parts:manage` | Sí | Sí | No | No | No | No | Sí | No |
| `inventory:suppliers:manage` | Sí | Sí | No | No | No | No | Sí | No |
| `inventory:purchase_orders:read`| Sí | Sí | Sí | No | No | No | Sí | No |
| `inventory:purchase_orders:create`| Sí | Sí | No | No | No | No | Sí | No |
| `inventory:batches:receive` | Sí | Sí | No | No | No | No | Sí | No |
| `inventory:batches:dispatch_fifo` | Sí | Sí | No | No | No | No | Sí | No |
| `inventory:batches:restore` | Sí | Sí | No | No | No | No | Sí | No |
| `inventory:alerts:read` | Sí | Sí | Sí | No | No | No | Sí | No |
| `inventory:alerts:resolve` | Sí | Sí | No | No | No | No | Sí | No |
| **Human Resources & Shifts** | | | | | | | | |
| `hr:attendance:clock_in` | No | No | Sí | Sí | Sí | Sí | Sí | Sí |
| `hr:attendance:clock_out` | No | No | Sí | Sí | Sí | Sí | Sí | Sí |
| `hr:attendance:read_own` | Sí | Sí | Sí | Sí | Sí | Sí | Sí | Sí |
| `hr:attendance:audit_all` | Sí | Sí | Sí | No | No | No | No | No |
| `hr:shifts:read` | Sí | Sí | Sí | Sí | Sí | Sí | Sí | Sí |
| `hr:shifts:manage` | Sí | Sí | No | No | No | No | No | No |
| `hr:justifications:create` | No | No | Sí | Sí | Sí | Sí | Sí | Sí |
| `hr:justifications:approve` | Sí | Sí | Sí | No | No | No | No | No |
| `hr:plame:export` | Sí | Sí | No | No | No | No | No | No |
| **Invoicing & Compliance** | | | | | | | | |
| `invoicing:invoices:read` | Sí | Sí | No | Sí | No | No | No | Sí |
| `invoicing:invoices:settle` | Sí | Sí | No | No | No | No | No | Sí |
| `invoicing:invoices:issue_sunat` | Sí | Sí | No | No | No | No | No | Sí |
| `invoicing:payments:create` | Sí | Sí | No | No | No | No | No | Sí |
| `invoicing:exit_passes:issue` | Sí | Sí | No | No | No | No | No | Sí |
| `invoicing:cashflow:export_pdf` | Sí | No | No | No | No | No | No | No |
| `invoicing:fiscal_config:manage` | Sí | No | No | No | No | No | No | No |
| **SaaS Billing & Subscriptions**| | | | | | | | |
| `billing:subscriptions:read` | Sí | Sí | No | No | No | No | No | No |
| `billing:subscriptions:manage_stripe`| Sí | No | No | No | No | No | No | No |
| `billing:plans:read` | Sí | Sí | Sí | Sí | Sí | Sí | Sí | Sí |
| `billing:invoices:read` | Sí | No | No | No | No | No | No | No |
| **IoT Telemetry & AI** | | | | | | | | |
| `iot:devices:read` | Sí | Sí | Sí | Sí | No | Sí | No | No |
| `iot:devices:register` | Sí | Sí | Sí | No | No | No | No | No |
| `iot:installations:manage` | Sí | Sí | Sí | Sí | No | Sí | No | No |
| `iot:telemetry:ingest` | No | No | No | No | No | Sí | No | No |
| `iot:telemetry:read` | Sí | Sí | Sí | Sí | No | Sí | No | No |
| `iot:faults:read` | Sí | Sí | Sí | Sí | No | Sí | No | No |
| `iot:faults:resolve` | Sí | Sí | Sí | No | No | Sí | No | No |
| `iot:alerts:read` | Sí | Sí | Sí | Sí | No | Sí | No | No |
| `iot:alerts:acknowledge` | Sí | Sí | Sí | No | No | Sí | No | No |
| `iot:health_reports:generate` | Sí | Sí | Sí | Sí | No | Sí | No | No |
| `iot:health_reports:read` | Sí | Sí | Sí | Sí | No | Sí | No | No |

---

## 6. Escenarios Operativos y Asignación de Múltiples Roles

La flexibilidad del modelo relacional M:N permite cubrir indistintamente talleres de diferentes escalas operativas:

### 6.1. Escenario Taller Pequeño (MYPE de 3 a 4 personas)
En un taller micro o pequeño, el equipo asume responsabilidades cruzadas:
* **Colaborador 1 (Don Alberto, Propietario):** Asignado a `[ROLE_WORKSHOP_OWNER, ROLE_WORKSHOP_ADMINISTRATOR]`. Gestiona pagos en Stripe, compras y configuraciones SUNAT.
* **Colaborador 2 (Carlos, Jefe de Bahía):** Asignado a `[ROLE_CHIEF_MECHANIC, ROLE_SERVICE_ADVISOR, ROLE_INVENTORY_MANAGER]`. Recibe los autos con la tablet, asigna bahías, despacha piezas del almacén y valida la calidad.
* **Colaborador 3 (María, Atención y Cobros):** Asignada a `[ROLE_RECEPTIONIST, ROLE_CASHIER]`. Registra clientes y vehículos al entrar, agenda citas, cobra en mostrador y emite las boletas SUNAT.
* **Colaborador 4 (Pedro, Mecánico Operativo):** Asignado exclusivamente a `[ROLE_MECHANIC]`. Conecta el escáner OBD-II, cronometra tareas y repara en foso.

### 6.2. Escenario Taller Mediano o Especializado (10 a 20 personas)
En una empresa estructurada con segregación formal de funciones:
* Cada empleado recibe un único rol estrictamente acotado a su puesto de trabajo.
* El recepcionista solo usa el módulo CRM y agenda.
* El asesor de servicio solo utiliza cotizaciones, peritajes e inspecciones en patio.
* El cajero solo maneja la liquidación de comprobantes y amortización de pagos.
* El administrador del inventario custodia exclusivamente los lotes FIFO y pedidos a proveedores.

---

## 7. Administración, Edición Soberana y Creación de Roles por Taller

Cada taller automotriz dispone de soberanía total para gestionar, auditar, personalizar y ampliar los roles de seguridad que rigen sus operaciones diarias. El Dueño o Administrador interactúa con los siguientes endpoints del controlador `RolesController`:

### 7.1. Listar Roles del Taller
Recupera la colección integral de roles correspondientes al taller en sesión, incluyendo tanto los roles aprovisionados de fábrica como los roles personalizados creados por la empresa.

```http
GET /api/v1/tenants/{tenantId}/roles
Authorization: Bearer <jwt_admin_token>
```

Retorna una lista de recursos `RoleResource` con sus permisos asignados y el indicador booleano `isSystemRole`:

```json
[
  {
    "id": "018f6c40-7e12-7000-8000-000000000010",
    "tenantId": "018f6c40-7e12-7000-8000-000000000001",
    "code": "ROLE_MECHANIC",
    "name": "Técnico Mecánico",
    "description": "Ejecución directa de labores mecánicas y diagnóstico en bahía",
    "isSystemRole": true,
    "permissions": [
      {
        "id": "018f6c45-aaaa-7000-8000-000000000001",
        "name": "operations:tasks:track_time",
        "category": "operations"
      }
    ]
  }
]
```

### 7.2. Crear Rol Personalizado por Taller
Permite formular un nuevo perfil de privilegios combinando un conjunto arbitrario de permisos atómicos del catálogo de la plataforma:

```http
POST /api/v1/tenants/{tenantId}/roles
Content-Type: application/json
Authorization: Bearer <jwt_admin_token>

{
  "name": "ASISTENTE_LUBRICANTE_Y_LLANTAS",
  "description": "Personal técnico enfocado en servicios rápidos de mantenimiento y lubricación",
  "permissionIds": [
    "018f6c45-aaaa-7000-8000-000000000001",
    "018f6c45-bbbb-7000-8000-000000000002",
    "018f6c45-cccc-7000-8000-000000000003"
  ]
}
```

El cuerpo de la petición se modela con el registro `CreateRoleResource(String name, String description, List<UUID> permissionIds)`. El backend ejecuta las siguientes operaciones:
1. Comprueba que el usuario emisor posea el permiso `iam:roles:create`.
2. Valida que todos los `permissionIds` existan en la tabla inmutable `permissions`.
3. Persiste el nuevo registro en la tabla `roles` con `is_system_role = false`, `code = null` y el `tenant_id` del taller solicitante.
4. Vincula los registros correspondientes en la tabla asociativa `role_permissions`.
5. Retorna el nuevo recurso `RoleResource` con código HTTP 201 Created.

### 7.3. Actualizar Permisos de un Rol (Edición Soberana)
Permite reconfigurar el conjunto de facultades de cualquier rol perteneciente al taller, ya sea un rol de fábrica o un rol personalizado:

```http
PUT /api/v1/tenants/{tenantId}/roles/{roleId}/permissions
Content-Type: application/json
Authorization: Bearer <jwt_admin_token>

{
  "permissionIds": [
    "018f6c45-aaaa-7000-8000-000000000001",
    "018f6c45-dddd-7000-8000-000000000004"
  ]
}
```

La solicitud se procesa mediante el registro `UpdateRolePermissionsResource(List<UUID> permissionIds)`. El backend valida que el rol pertenezca al `tenantId` indicado, comprueba los permisos solicitados y actualiza atómicamente la tabla asociativa `role_permissions`. Las modificaciones surten efecto de manera inmediata para cualquier emisión futura de credenciales JWT hacia los miembros que ostenten el rol intervenido. Retorna el recurso `RoleResource` actualizado con código HTTP 200 OK.

### 7.4. Restablecer Rol de Fábrica a Permisos Predeterminados
Si un rol aprovisionado de fábrica fue modificado y el taller opta por retornar al estándar canónico recomendado por la plataforma, puede invocar la operación de restablecimiento:

```http
POST /api/v1/tenants/{tenantId}/roles/{roleId}/reset-defaults
Authorization: Bearer <jwt_admin_token>
```

El backend corrobora que el rol posea `is_system_role == true`, identifica la plantilla original a partir de su atributo canónico `code` y restituye de forma atómica sus permisos predeterminados en `role_permissions`. Retorna el recurso `RoleResource` actualizado con código HTTP 200 OK.

### 7.5. Eliminar Rol Personalizado
Permite dar de baja un rol creado por el taller cuando este queda en desuso:

```http
DELETE /api/v1/tenants/{tenantId}/roles/{roleId}
Authorization: Bearer <jwt_admin_token>
```

Políticas de rechazo y consistencia transaccional:
1. Si el rol tiene `is_system_role == true`, el backend rechaza la petición con código HTTP 409 Conflict y propaga la excepción `SystemRoleImmutableException`. Los roles de fábrica no pueden ser eliminados bajo ninguna circunstancia.
2. Si el rol personalizado está asignado a uno o más colaboradores activos en la tabla `membership_roles`, el backend rechaza la solicitud con código HTTP 409 Conflict y propaga la excepción `RoleInUseException`. Se requiere reasignar o desvincular a los empleados antes de permitir la eliminación.
3. Si el rol es personalizado y no posee asignaciones vigentes, se eliminan sus filas en `role_permissions` y se efectúa el borrado del registro en `roles`, retornando código HTTP 204 No Content.

### 7.6. Asignación Multi-Rol a Miembros del Taller
Para adjudicar uno o múltiples roles en simultáneo a un colaborador del taller:

```http
PUT /api/v1/tenants/{tenantId}/memberships/{id}/roles
Content-Type: application/json
Authorization: Bearer <jwt_admin_token>

{
  "roleIds": [
    "018f6c40-7e12-7000-8000-000000000010",
    "018f6c40-7e12-7000-8000-000000000020"
  ]
}
```
