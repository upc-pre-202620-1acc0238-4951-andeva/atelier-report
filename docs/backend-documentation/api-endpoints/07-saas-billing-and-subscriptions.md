# Especificación Canónica de Endpoints REST: SaaS Billing and Subscriptions

El Bounded Context **SaaS Billing and Subscriptions** (`com.andeva.atelier.platform.billing`) gobierna el modelo comercial de ingresos B2B, el aprovisionamiento automatizado de planes comerciales, el control de cuotas operativas de plataforma y la conciliación contable de cobros entre la empresa proveedora de la plataforma (Andeva) y los talleres mecánicos abonados.

---

## 1. Arquitectura de Seguridad y Convenciones Globales

Todos los endpoints documentados en esta especificación técnica se adhieren rigurosamente a los estándares de arquitectura de Atelier Platform:

* **Desacoplamiento Fiscal Estricto:** Este módulo administra exclusivamente las relaciones comerciales y cobros periódicos de la plataforma hacia los talleres automotrices. La facturación tributaria emitida por los talleres a sus propios clientes (Facturas y Boletas UBL 2.1 ante SUNAT) reside de manera desacoplada en el contexto de Invoicing and Compliance.
* **Seguridad Bancaria PCI-DSS Nivel 1:** El backend jamás recibe, procesa ni almacena números de tarjeta bancaria (PAN), códigos de verificación CVC ni fechas de vencimiento. Todo el intercambio de credenciales bancarias se delega al navegador o dispositivo móvil mediante componentes certificados de Stripe Elements y Stripe Mobile SDK, intercambiando únicamente identificadores tokenizados seguros.
* **Gobernanza Determinista de Cuotas (Tenant Quota Limits):** Cada taller opera dentro de límites estrictos definidos por su plan activo. El sistema evalúa techos de sucursales (`maxBranches`), personal activo (`maxActiveStaff`), escáneres telemáticos (`maxActiveObd2Devices`), cupo mensual de órdenes de trabajo (`maxMonthlyWorkOrders`) y reportes periciales de inteligencia artificial (`maxMonthlyAiReports`).
* **Idempotencia Garantizada en Webhooks:** Ante eventos asíncronos despachados por Stripe, la tabla de idempotencia `stripe_events` almacena unívocamente cada identificador con restricción de unicidad para evitar procesamientos duplicados o cobros espurios.
* **Aceleración de Caché en Memoria:** La validación de estado contractual y cuotas operativas se resuelve con latencias menores a 0.05 milisegundos mediante Caffeine Cache local con invalidación reactiva inmediata ante webhooks.
* **Estandarización de Respuestas de Error (RFC 7807):** Toda falla de dominio o de infraestructura se serializa bajo el estándar `application/problem+json` mediante `ProblemDetail`.

---

## 2. Índice Canónico de Endpoints

El módulo expone exactamente 12 endpoints distribuidos en 4 controladores especializados:

| No. | Método | Ruta Relativa | Controlador Java | Método Java | Permiso Atómico Requerido | Rol Mínimo Sugerido |
| :---: | :---: | :--- | :--- | :--- | :--- | :--- |
| 1 | `GET` | `/api/v1/billing/plans` | `SubscriptionPlansController` | `getActivePlans()` | `billing:plans:read` | Público / Conductor |
| 2 | `GET` | `/api/v1/billing/plans/{id}` | `SubscriptionPlansController` | `getPlanById()` | `billing:plans:read` | Público / Conductor |
| 3 | `POST` | `/api/v1/billing/plans` | `SubscriptionPlansController` | `createPlan()` | `billing:plans:manage` | Administrador de Plataforma |
| 4 | `PUT` | `/api/v1/billing/plans/{id}` | `SubscriptionPlansController` | `updatePlan()` | `billing:plans:manage` | Administrador de Plataforma |
| 5 | `GET` | `/api/v1/billing/subscriptions/me` | `TenantSubscriptionsController` | `getCurrentSubscription()` | `billing:subscriptions:read` | Administrador de Taller |
| 6 | `POST` | `/api/v1/billing/subscriptions/checkout-session` | `TenantSubscriptionsController` | `createCheckoutSession()` | `billing:subscriptions:manage_stripe` | Administrador de Taller |
| 7 | `POST` | `/api/v1/billing/subscriptions/customer-portal` | `TenantSubscriptionsController` | `createCustomerPortalSession()` | `billing:subscriptions:manage_stripe` | Administrador de Taller |
| 8 | `POST` | `/api/v1/billing/subscriptions/cancel` | `TenantSubscriptionsController` | `cancelSubscription()` | `billing:subscriptions:manage_stripe` | Administrador de Taller |
| 9 | `GET` | `/api/v1/billing/invoices` | `SaasInvoicesController` | `listInvoices()` | `billing:invoices:read` | Administrador de Taller |
| 10 | `GET` | `/api/v1/billing/invoices/{id}` | `SaasInvoicesController` | `getInvoiceById()` | `billing:invoices:read` | Administrador de Taller |
| 11 | `GET` | `/api/v1/billing/invoices/{id}/pdf` | `SaasInvoicesController` | `redirectToInvoicePdf()` | `billing:invoices:read` | Administrador de Taller |
| 12 | `POST` | `/api/v1/billing/webhooks/stripe` | `StripeWebhooksController` | `handleWebhook()` | Verificación Firma HMAC-SHA256 | Pasarela Externa Stripe |

---

## 3. Endpoints de SubscriptionPlansController

El controlador `SubscriptionPlansController` gestiona el catálogo público de tarifas y planes de suscripción de Atelier Platform, así como la configuración administrativa de cuotas y vinculación con identificadores de precio en Stripe.

### 3.1. [GET] /api/v1/billing/plans

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.billing.interfaces.rest.controllers.SubscriptionPlansController`
* **Método Java:** `public ResponseEntity<List<SubscriptionPlanResource>> getActivePlans()`
* **Ruta Base:** `/api/v1/billing/plans`
* **Ruta Completa:** `/api/v1/billing/plans`
* **Propósito:** Retorna la lista completa de planes comerciales activos disponibles para contratación, detallando precios, ciclo de facturación, cuotas operativas autorizadas y características modulares activas.

#### Descripción Funcional
Permite a los administradores de taller o usuarios no registrados explorar las opciones comerciales disponibles de Atelier Platform. Consulta la base de datos de planes activos filtrando aquellos marcados con vigencia comercial (`isActive = true`), ordenados por nivel tarifario jerárquico (`GO`, `PRO`, `MAX`, `ENTERPRISE`). Cada plan proyecta sus cuotas técnicas asociadas para que el cliente conozca los límites de sucursales, personal activo, órdenes de trabajo mensuales, telemetría IoT y diagnósticos con inteligencia artificial.

#### Seguridad y Autorización
* **Nivel de Acceso:** Público / Catálogo Perimetral
* **Rol Mínimo Requerido:** Público (Sin credenciales) o cualquier rol autenticado
* **Permiso Atómico:** `PermitAll` / `@PreAuthorize("hasAuthority('billing:plans:read') or permitAll()")`
* **Aislamiento Multi-Inquilino:** Catálogo global de plataforma. No aplica filtro por inquilino.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Accept: application/json`
* **Parámetros de Ruta (Path Parameters):** No aplica.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
No aplica (Solicitud de tipo HTTP GET sin cuerpo).

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `200 OK`
* **Registro Java DTO:** `List<com.andeva.atelier.platform.billing.interfaces.rest.resources.responses.SubscriptionPlanResource>`
* **Definición de Campos Proyectados:**

| Campo | Tipo de Dato | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador único del plan comercial en la base de datos |
| `stripePriceId` | `String` | Identificador oficial del precio en la pasarela Stripe (ej. price_1Ou8abc) |
| `name` | `String` | Nombre comercial formal del plan (ej. Atelier Pro) |
| `tier` | `String` | Nivel funcional del plan (GO, PRO, MAX, ENTERPRISE) |
| `price` | `BigDecimal` | Tarifa periódica en el valor monetario establecido |
| `currency` | `String` | Código ISO de tres caracteres de la divisa (ej. USD o PEN) |
| `billingCycle` | `String` | Frecuencia de renovación contractual (MONTHLY o YEARLY) |
| `quotaLimits` | `TenantQuotaLimitsDto` | Objeto anidado con los techos operativos autorizados por el plan |
| `quotaLimits.maxBranches` | `int` | Cantidad máxima de sedes físicas permitidas simultáneamente |
| `quotaLimits.maxActiveStaff` | `int` | Límite máximo de personal técnico y administrativo activo |
| `quotaLimits.maxActiveObd2Devices` | `int` | Techo de escáneres telemáticos OBD-II vinculables |
| `quotaLimits.maxPhotosPerWorkOrder` | `int` | Cantidad máxima de evidencias fotográficas por orden de trabajo |
| `quotaLimits.maxMonthlyAiReports` | `int` | Cupo mensual de informes de salud mecánica asistidos por Spring AI |
| `quotaLimits.companyRegistrationAllowed` | `boolean` | Bandera que autoriza el registro de clientes tipo corporativo o flota |
| `quotaLimits.multiWarehouseAllowed` | `boolean` | Habilita la gestión de inventario multi-almacén con costeo FIFO |
| `quotaLimits.marketplaceListed` | `boolean` | Determina si el taller aparece listado en el marketplace B2B |
| `quotaLimits.maxMonthlyWorkOrders` | `int` | Límite mensual de órdenes de trabajo procesables |
| `quotaLimits.iotTelemetryEnabled` | `boolean` | Habilitación de ingesta telemática de alta frecuencia |
| `quotaLimits.aiDiagnosticsEnabled` | `boolean` | Habilitación de inferencia predictiva asistida por Groq LPU |
| `features` | `List<PlanFeatureResource>` | Colección de características modulares y servicios del plan |
| `features[].id` | `UUID` | Identificador de la característica en el catálogo |
| `features[].featureKey` | `String` | Clave técnica única de la funcionalidad |
| `features[].name` | `String` | Denominación legible de la funcionalidad |
| `features[].description` | `String` | Explicación del beneficio operativo para el taller |
| `features[].isEnabled` | `boolean` | Estado de activación funcional de la característica |
| `isActive` | `boolean` | Indicador de disponibilidad comercial del plan |
| `createdAt` | `Instant` | Marca temporal de creación en formato ISO 8601 UTC |
| `updatedAt` | `Instant` | Marca temporal de última modificación en formato ISO 8601 UTC |

**Ejemplo de Carga Útil JSON (Response):**
```json
[
  {
    "id": "018f6c40-7e12-7000-8000-000000000101",
    "stripePriceId": "price_1Ou8abcPROMonthly",
    "name": "Atelier Pro Mensual",
    "tier": "PRO",
    "price": 89.00,
    "currency": "USD",
    "billingCycle": "MONTHLY",
    "quotaLimits": {
      "maxBranches": 2,
      "maxActiveStaff": 10,
      "maxActiveObd2Devices": 5,
      "maxPhotosPerWorkOrder": 50,
      "maxMonthlyAiReports": 10,
      "companyRegistrationAllowed": false,
      "multiWarehouseAllowed": false,
      "marketplaceListed": false,
      "maxMonthlyWorkOrders": 300,
      "iotTelemetryEnabled": true,
      "aiDiagnosticsEnabled": true
    },
    "features": [
      {
        "id": "018f6c40-7e12-7000-8000-000000000201",
        "featureKey": "OBD2_TELEMETRY",
        "name": "Telemetría OBD-II en Tiempo Real",
        "description": "Conectividad Bluetooth con escáneres en bahía para diagnóstico en vivo",
        "isEnabled": true
      },
      {
        "id": "018f6c40-7e12-7000-8000-000000000202",
        "featureKey": "FIFO_INVENTORY",
        "name": "Inventario Valorizado FIFO",
        "description": "Gestión de repuestos por lote con costeo de inventario estricto",
        "isEnabled": true
      }
    ],
    "isActive": true,
    "createdAt": "2026-09-01T12:00:00Z",
    "updatedAt": "2026-10-01T14:30:00Z"
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `500 Internal Server Error` | `BillingDomainException` | Error no controlado en la consulta del catálogo de planes comerciales |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/billing-domain-violation",
  "title": "Billing Domain Violation",
  "status": 500,
  "detail": "Error de infraestructura al consultar el catálogo comercial de planes",
  "instance": "/api/v1/billing/plans",
  "code": "ERR_BILLING_DOMAIN_VIOLATION",
  "timestamp": "2026-10-04T02:00:00Z"
}
```

---

### 3.2. [GET] /api/v1/billing/plans/{id}

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.billing.interfaces.rest.controllers.SubscriptionPlansController`
* **Método Java:** `public ResponseEntity<SubscriptionPlanResource> getPlanById(@PathVariable UUID id)`
* **Ruta Base:** `/api/v1/billing/plans`
* **Ruta Completa:** `/api/v1/billing/plans/{id}`
* **Propósito:** Obtiene la ficha técnica y comercial exhaustiva de un plan de suscripción específico a partir de su identificador universal.

#### Descripción Funcional
Recupera la entidad agregada `SubscriptionPlan` localizada por su `PlanId`. Valida la existencia del registro en el repositorio y transforma la estructura interna en un recurso de presentación `SubscriptionPlanResource`, incluyendo sus cuotas operativas y lista detallada de características.

#### Seguridad y Autorización
* **Nivel de Acceso:** Público / Catálogo Perimetral
* **Rol Mínimo Requerido:** Público (Sin credenciales) o cualquier rol autenticado
* **Permiso Atómico:** `PermitAll` / `@PreAuthorize("hasAuthority('billing:plans:read') or permitAll()")`
* **Aislamiento Multi-Inquilino:** Catálogo global de plataforma.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Accept: application/json`
* **Parámetros de Ruta (Path Parameters):**
  * `id` (`UUID`): Identificador universal único del plan tarifario consultado.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
No aplica (Solicitud de tipo HTTP GET sin cuerpo).

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `200 OK`
* **Registro Java DTO:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.responses.SubscriptionPlanResource`
* **Definición de Campos Proyectados:** Idéntica a la definición proyectada en el endpoint `GET /api/v1/billing/plans`.

**Ejemplo de Carga Útil JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000102",
  "stripePriceId": "price_1Ou8abcMAXMonthly",
  "name": "Atelier Max Mensual",
  "tier": "MAX",
  "price": 179.00,
  "currency": "USD",
  "billingCycle": "MONTHLY",
  "quotaLimits": {
    "maxBranches": 5,
    "maxActiveStaff": 25,
    "maxActiveObd2Devices": 15,
    "maxPhotosPerWorkOrder": 100,
    "maxMonthlyAiReports": 60,
    "companyRegistrationAllowed": true,
    "multiWarehouseAllowed": true,
    "marketplaceListed": true,
    "maxMonthlyWorkOrders": 1000,
    "iotTelemetryEnabled": true,
    "aiDiagnosticsEnabled": true
  },
  "features": [
    {
      "id": "018f6c40-7e12-7000-8000-000000000201",
      "featureKey": "OBD2_TELEMETRY",
      "name": "Telemetría OBD-II en Tiempo Real",
      "description": "Conectividad Bluetooth con escáneres en bahía para diagnóstico en vivo",
      "isEnabled": true
    },
    {
      "id": "018f6c40-7e12-7000-8000-000000000203",
      "featureKey": "SPRING_AI_GROQ_DIAGNOSTICS",
      "name": "Diagnósticos Predictivos con Inteligencia Artificial",
      "description": "Análisis computarizado de fallas y emisión de reportes forenses en PDF",
      "isEnabled": true
    }
  ],
  "isActive": true,
  "createdAt": "2026-09-01T12:00:00Z",
  "updatedAt": "2026-10-01T14:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentTypeMismatchException` | El parámetro de ruta id no presenta un formato UUID válido |
| `404 Not Found` | `PlanNotFoundException` | El identificador proporcionado no corresponde a ningún plan registrado |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/plan-not-found",
  "title": "Plan Not Found",
  "status": 404,
  "detail": "El plan comercial con identificador 018f6c40-7e12-7000-8000-000000000999 no existe en el catálogo",
  "instance": "/api/v1/billing/plans/018f6c40-7e12-7000-8000-000000000999",
  "code": "ERR_PLAN_NOT_FOUND",
  "timestamp": "2026-10-04T02:00:00Z"
}
```

---

### 3.3. [POST] /api/v1/billing/plans

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.billing.interfaces.rest.controllers.SubscriptionPlansController`
* **Método Java:** `public ResponseEntity<SubscriptionPlanResource> createPlan(@Valid @RequestBody CreateSubscriptionPlanRequest request)`
* **Ruta Base:** `/api/v1/billing/plans`
* **Ruta Completa:** `/api/v1/billing/plans`
* **Propósito:** Registra administrativamente un nuevo plan comercial en la plataforma vinculándolo a un precio preconfigurado en Stripe.

#### Descripción Funcional
Permite a los administradores globales de la plataforma registrar una nueva oferta tarifaria en el sistema. Valida que el identificador de precio en Stripe comience con el prefijo formal `price_`, que la moneda corresponda a un estándar ISO válido y que las cuotas operativas cumplan las invariantes mínimas del dominio. Persiste el agregado `SubscriptionPlan` con sus características modulares y publica el evento de integración `SubscriptionPlanCreatedEvent`.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Exclusivo Administrador de Plataforma
* **Rol Mínimo Requerido:** Administrador de Plataforma (`ROLE_SUPER_ADMIN`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('billing:plans:manage')")`
* **Aislamiento Multi-Inquilino:** Configuración global de plataforma.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
* **Parámetros de Ruta (Path Parameters):** No aplica.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
* **Registro Java DTO:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.requests.CreateSubscriptionPlanRequest`
* **Definición de Campos:**

| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `stripePriceId` | `String` | Sí | `@NotBlank, @Pattern(regexp = "^price_[a-zA-Z0-9]+$")` | Identificador de precio creado en la pasarela Stripe |
| `name` | `String` | Sí | `@NotBlank, @Size(min = 3, max = 100)` | Denominación comercial formal del plan |
| `tier` | `String` | Sí | `@NotBlank, @Pattern(regexp = "^(GO\|PRO\|MAX\|ENTERPRISE)$")` | Nivel del plan tarifario |
| `price` | `BigDecimal` | Sí | `@NotNull, @DecimalMin("0.0"), @Digits(integer = 10, fraction = 2)` | Importe recurrente en la divisa especificada |
| `currency` | `String` | Sí | `@NotBlank, @Size(min = 3, max = 3)` | Código de moneda ISO 4217 (ej. USD, PEN) |
| `billingCycle` | `String` | Sí | `@NotBlank, @Pattern(regexp = "^(MONTHLY\|YEARLY)$")` | Periodicidad de liquidación |
| `quotaLimits` | `TenantQuotaLimitsDto` | Sí | `@NotNull, @Valid` | Cuotas y capacidades técnicas habilitadas |
| `features` | `List<PlanFeatureRequest>` | No | `@Valid` | Lista opcional de características modulares |

**Ejemplo de Carga Útil JSON (Request):**
```json
{
  "stripePriceId": "price_1Ou8abcENTERPRISEAnnual",
  "name": "Atelier Enterprise Corporativo Anual",
  "tier": "ENTERPRISE",
  "price": 2388.00,
  "currency": "USD",
  "billingCycle": "YEARLY",
  "quotaLimits": {
    "maxBranches": 20,
    "maxActiveStaff": 100,
    "maxActiveObd2Devices": 50,
    "maxPhotosPerWorkOrder": 200,
    "maxMonthlyAiReports": 500,
    "companyRegistrationAllowed": true,
    "multiWarehouseAllowed": true,
    "marketplaceListed": true,
    "maxMonthlyWorkOrders": 5000,
    "iotTelemetryEnabled": true,
    "aiDiagnosticsEnabled": true
  },
  "features": [
    {
      "featureKey": "MULTI_WAREHOUSE",
      "name": "Gestión Multi-Almacén Inter-Sede",
      "description": "Transferencias entre depósitos y valoración consolidada FIFO",
      "isEnabled": true
    },
    {
      "featureKey": "PRIORITY_SLA_SUPPORT",
      "name": "Soporte Técnico con SLA Prioritario",
      "description": "Atención telefónica directa 24 horas y resolución en menos de dos horas",
      "isEnabled": true
    }
  ]
}
```

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `201 Created` con cabecera `Location: /api/v1/billing/plans/{id}`
* **Registro Java DTO:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.responses.SubscriptionPlanResource`
* **Definición de Campos Proyectados:** Idéntica a la especificación de `SubscriptionPlanResource`.

**Ejemplo de Carga Útil JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000103",
  "stripePriceId": "price_1Ou8abcENTERPRISEAnnual",
  "name": "Atelier Enterprise Corporativo Anual",
  "tier": "ENTERPRISE",
  "price": 2388.00,
  "currency": "USD",
  "billingCycle": "YEARLY",
  "quotaLimits": {
    "maxBranches": 20,
    "maxActiveStaff": 100,
    "maxActiveObd2Devices": 50,
    "maxPhotosPerWorkOrder": 200,
    "maxMonthlyAiReports": 500,
    "companyRegistrationAllowed": true,
    "multiWarehouseAllowed": true,
    "marketplaceListed": true,
    "maxMonthlyWorkOrders": 5000,
    "iotTelemetryEnabled": true,
    "aiDiagnosticsEnabled": true
  },
  "features": [
    {
      "id": "018f6c40-7e12-7000-8000-000000000204",
      "featureKey": "MULTI_WAREHOUSE",
      "name": "Gestión Multi-Almacén Inter-Sede",
      "description": "Transferencias entre depósitos y valoración consolidada FIFO",
      "isEnabled": true
    },
    {
      "id": "018f6c40-7e12-7000-8000-000000000205",
      "featureKey": "PRIORITY_SLA_SUPPORT",
      "name": "Soporte Técnico con SLA Prioritario",
      "description": "Atención telefónica directa 24 horas y resolución en menos de dos horas",
      "isEnabled": true
    }
  ],
  "isActive": true,
  "createdAt": "2026-10-04T02:05:00Z",
  "updatedAt": "2026-10-04T02:05:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Faltan campos obligatorios o el formato de stripePriceId es inválido |
| `400 Bad Request` | `InvalidPlanPricingException` | Parámetros de importe o moneda inconsistentes con las reglas de Stripe |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| `403 Forbidden` | `AccessDeniedException` | El usuario autenticado carece del rol SUPER_ADMIN |
| `409 Conflict` | `DuplicatePlanException` | Ya existe un plan registrado con el mismo stripePriceId |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/invalid-plan-pricing",
  "title": "Invalid Plan Pricing",
  "status": 400,
  "detail": "El precio especificado no puede ser negativo ni exceder dos decimales de precisión",
  "instance": "/api/v1/billing/plans",
  "code": "ERR_INVALID_PLAN_PRICING",
  "timestamp": "2026-10-04T02:05:00Z"
}
```

---

### 3.4. [PUT] /api/v1/billing/plans/{id}

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.billing.interfaces.rest.controllers.SubscriptionPlansController`
* **Método Java:** `public ResponseEntity<SubscriptionPlanResource> updatePlan(@PathVariable UUID id, @Valid @RequestBody UpdateSubscriptionPlanRequest request)`
* **Ruta Base:** `/api/v1/billing/plans`
* **Ruta Completa:** `/api/v1/billing/plans/{id}`
* **Propósito:** Actualiza cuotas operativas, denominación comercial, estado de vigencia o periodicidad de un plan existente.

#### Descripción Funcional
Permite a los administradores de la plataforma ajustar las capacidades técnicas asignadas a un plan comercial o retirar su vigencia comercial mediante la bandera `isActive`. El agregador valida que la modificación de cuotas no infrinja restricciones sobre talleres actualmente suscritos que requieran soporte continuado. Tras la mutación, se invalidan selectivamente las entradas en Caffeine Cache para forzar la actualización de cuotas en las subsiguientes peticiones de los talleres.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Exclusivo Administrador de Plataforma
* **Rol Mínimo Requerido:** Administrador de Plataforma (`ROLE_SUPER_ADMIN`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('billing:plans:manage')")`
* **Aislamiento Multi-Inquilino:** Configuración global de plataforma.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
* **Parámetros de Ruta (Path Parameters):**
  * `id` (`UUID`): Identificador universal del plan que se desea actualizar.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
* **Registro Java DTO:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.requests.UpdateSubscriptionPlanRequest`
* **Definición de Campos:**

| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `name` | `String` | Sí | `@NotBlank, @Size(min = 3, max = 100)` | Nombre comercial actualizado del plan |
| `price` | `BigDecimal` | Sí | `@NotNull, @DecimalMin("0.0"), @Digits(integer = 10, fraction = 2)` | Importe actualizado |
| `billingCycle` | `String` | Sí | `@NotBlank, @Pattern(regexp = "^(MONTHLY\|YEARLY)$")` | Periodicidad de liquidación |
| `quotaLimits` | `TenantQuotaLimitsDto` | Sí | `@NotNull, @Valid` | Cuotas y capacidades técnicas actualizadas |
| `isActive` | `Boolean` | No | Sin restricción adicional | Estado de activación comercial del plan |

**Ejemplo de Carga Útil JSON (Request):**
```json
{
  "name": "Atelier Pro Plus Mensual",
  "price": 99.00,
  "billingCycle": "MONTHLY",
  "quotaLimits": {
    "maxBranches": 3,
    "maxActiveStaff": 12,
    "maxActiveObd2Devices": 8,
    "maxPhotosPerWorkOrder": 60,
    "maxMonthlyAiReports": 15,
    "companyRegistrationAllowed": false,
    "multiWarehouseAllowed": false,
    "marketplaceListed": false,
    "maxMonthlyWorkOrders": 400,
    "iotTelemetryEnabled": true,
    "aiDiagnosticsEnabled": true
  },
  "isActive": true
}
```

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `200 OK`
* **Registro Java DTO:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.responses.SubscriptionPlanResource`
* **Definición de Campos Proyectados:** Idéntica a la especificación de `SubscriptionPlanResource`.

**Ejemplo de Carga Útil JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000101",
  "stripePriceId": "price_1Ou8abcPROMonthly",
  "name": "Atelier Pro Plus Mensual",
  "tier": "PRO",
  "price": 99.00,
  "currency": "USD",
  "billingCycle": "MONTHLY",
  "quotaLimits": {
    "maxBranches": 3,
    "maxActiveStaff": 12,
    "maxActiveObd2Devices": 8,
    "maxPhotosPerWorkOrder": 60,
    "maxMonthlyAiReports": 15,
    "companyRegistrationAllowed": false,
    "multiWarehouseAllowed": false,
    "marketplaceListed": false,
    "maxMonthlyWorkOrders": 400,
    "iotTelemetryEnabled": true,
    "aiDiagnosticsEnabled": true
  },
  "features": [
    {
      "id": "018f6c40-7e12-7000-8000-000000000201",
      "featureKey": "OBD2_TELEMETRY",
      "name": "Telemetría OBD-II en Tiempo Real",
      "description": "Conectividad Bluetooth con escáneres en bahía para diagnóstico en vivo",
      "isEnabled": true
    }
  ],
  "isActive": true,
  "createdAt": "2026-09-01T12:00:00Z",
  "updatedAt": "2026-10-04T02:10:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Campos obligatorios ausentes o formato de cuotas inválido |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o expirado |
| `403 Forbidden` | `AccessDeniedException` | Permisos insuficientes para editar planes comerciales |
| `404 Not Found` | `PlanNotFoundException` | El identificador del plan no existe en el repositorio |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/plan-not-found",
  "title": "Plan Not Found",
  "status": 404,
  "detail": "No se puede actualizar el plan porque no existe en la base de datos",
  "instance": "/api/v1/billing/plans/018f6c40-7e12-7000-8000-000000000101",
  "code": "ERR_PLAN_NOT_FOUND",
  "timestamp": "2026-10-04T02:10:00Z"
}
```

---

## 4. Endpoints de TenantSubscriptionsController

El controlador `TenantSubscriptionsController` gobierna el ciclo de vida de la suscripción del taller mecánico autenticado, gestionando la consulta del estado operativo, la inicialización de sesiones alojadas en Stripe Checkout, la generación de portales de autogestión de cliente y la cancelación de membresías.

### 4.1. [GET] /api/v1/billing/subscriptions/me

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.billing.interfaces.rest.controllers.TenantSubscriptionsController`
* **Método Java:** `public ResponseEntity<TenantSubscriptionResource> getCurrentSubscription(@AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/billing/subscriptions`
* **Ruta Completa:** `/api/v1/billing/subscriptions/me`
* **Propósito:** Consulta el contrato de suscripción vigente del taller automotriz autenticado, su estado contable, periodo de facturación actual y límites de cuota técnica en tiempo real.

#### Descripción Funcional
Extrae el `tenant_id` del token JWT de la sesión autenticada. Primero consulta en la capa de caché de alto rendimiento Caffeine Cache para verificar si existe un registro válido con tiempo de vida remanente. De no existir en memoria o ante una invalidación reactiva por webhook de Stripe, acude al repositorio PostgreSQL para reconstruir el agregado `TenantSubscription`, contrastando las fechas de inicio y término del ciclo, la presencia de periodo de prueba (`trialEndDate`) y el indicador de cancelación programada (`cancelAtPeriodEnd`). Resuelve determinísticamente la bandera `isAccessGranted`.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Administrador de Taller (`ROLE_TENANT_ADMIN`) o Dueño de Taller (`ROLE_WORKSHOP_OWNER`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('billing:subscriptions:read')")`
* **Aislamiento Multi-Inquilino:** La consulta se encuentra estrictamente anclada al `tenant_id` inyectado en el claim criptográfico del token JWT.

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
* **Registro Java DTO:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.responses.TenantSubscriptionResource`
* **Definición de Campos Proyectados:**

| Campo | Tipo de Dato | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador único de la suscripción del taller |
| `tenantId` | `UUID` | Identificador del taller automotriz titular del contrato |
| `planId` | `UUID` | Identificador del plan comercial contratado |
| `planName` | `String` | Nombre comercial formal del plan suscrito |
| `tier` | `String` | Nivel del plan (GO, PRO, MAX, ENTERPRISE) |
| `status` | `String` | Estado contractual (TRIALING, ACTIVE, PAST_DUE, CANCELED, UNPAID) |
| `currentPeriodStart` | `Instant` | Inicio del ciclo de facturación vigente en formato ISO 8601 UTC |
| `currentPeriodEnd` | `Instant` | Fin del ciclo de facturación vigente en formato ISO 8601 UTC |
| `cancelAtPeriodEnd` | `boolean` | Indica si la suscripción se cancelará al terminar el periodo |
| `trialEndDate` | `Instant` | Fecha límite del periodo de prueba gratuito si aplica |
| `quotaLimits` | `TenantQuotaLimitsDto` | Techos operativos autorizados para el taller |
| `isAccessGranted` | `boolean` | Indicador booleano que certifica acceso operativo irrestricto |

**Ejemplo de Carga Útil JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000301",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "planId": "018f6c40-7e12-7000-8000-000000000101",
  "planName": "Atelier Pro Mensual",
  "tier": "PRO",
  "status": "ACTIVE",
  "currentPeriodStart": "2026-10-01T00:00:00Z",
  "currentPeriodEnd": "2026-11-01T00:00:00Z",
  "cancelAtPeriodEnd": false,
  "trialEndDate": null,
  "quotaLimits": {
    "maxBranches": 2,
    "maxActiveStaff": 10,
    "maxActiveObd2Devices": 5,
    "maxPhotosPerWorkOrder": 50,
    "maxMonthlyAiReports": 10,
    "companyRegistrationAllowed": false,
    "multiWarehouseAllowed": false,
    "marketplaceListed": false,
    "maxMonthlyWorkOrders": 300,
    "iotTelemetryEnabled": true,
    "aiDiagnosticsEnabled": true
  },
  "isAccessGranted": true
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente, expirado o con firma digital inválida |
| `403 Forbidden` | `AccessDeniedException` | El usuario autenticado carece de privilegios administrativos de taller |
| `404 Not Found` | `SubscriptionNotFoundException` | El taller autenticado no cuenta con contrato de suscripción registrado |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/subscription-not-found",
  "title": "Subscription Not Found",
  "status": 404,
  "detail": "El taller automotriz no posee un contrato de suscripción SaaS activo ni periodo de prueba asignado",
  "instance": "/api/v1/billing/subscriptions/me",
  "code": "ERR_SUBSCRIPTION_NOT_FOUND",
  "timestamp": "2026-10-04T02:15:00Z"
}
```

---

### 4.2. [POST] /api/v1/billing/subscriptions/checkout-session

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.billing.interfaces.rest.controllers.TenantSubscriptionsController`
* **Método Java:** `public ResponseEntity<CheckoutSessionResponse> createCheckoutSession(@Valid @RequestBody CreateCheckoutSessionRequest request, @AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/billing/subscriptions`
* **Ruta Completa:** `/api/v1/billing/subscriptions/checkout-session`
* **Propósito:** Genera una sesión de pago alojada en Stripe Checkout para contratar un plan o formalizar una actualización de membresía.

#### Descripción Funcional
Permite a los administradores de taller iniciar el proceso seguro de pago para suscribirse a un nuevo plan comercial. El servicio valida la existencia del `planId` solicitado, comprueba si el taller ya cuenta con un cliente registrado en Stripe (`stripe_customer_id`) o crea uno nuevo en la pasarela sincronizando la información fiscal del taller, y genera una sesión de Stripe Checkout en modo `subscription`. Retorna la URL oficial de Stripe hacia la cual el frontend redirige al usuario para ingresar los datos de su tarjeta bancaria bajo cumplimiento PCI-DSS Nivel 1.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Administrador de Taller (`ROLE_TENANT_ADMIN`) o Dueño de Taller (`ROLE_WORKSHOP_OWNER`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('billing:subscriptions:manage_stripe')")`
* **Aislamiento Multi-Inquilino:** La sesión de Stripe se parametriza con el `tenant_id` autenticado inyectado en los metadatos (`client_reference_id` y `metadata.tenantId`).

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
* **Parámetros de Ruta (Path Parameters):** No aplica.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
* **Registro Java DTO:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.requests.CreateCheckoutSessionRequest`
* **Definición de Campos:**

| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `planId` | `UUID` | Sí | `@NotNull` | Identificador único del plan comercial seleccionado |
| `successUrl` | `String` | Sí | `@NotBlank` | URL de retorno seguro hacia el frontend tras el pago exitoso |
| `cancelUrl` | `String` | Sí | `@NotBlank` | URL de retorno hacia el frontend si el usuario cancela la sesión |

**Ejemplo de Carga Útil JSON (Request):**
```json
{
  "planId": "018f6c40-7e12-7000-8000-000000000102",
  "successUrl": "https://app.atelier.pe/settings/billing?session_id={CHECKOUT_SESSION_ID}&status=success",
  "cancelUrl": "https://app.atelier.pe/settings/billing?status=cancelled"
}
```

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `200 OK`
* **Registro Java DTO:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.responses.CheckoutSessionResponse`
* **Definición de Campos Proyectados:**

| Campo | Tipo de Dato | Descripción |
| :--- | :--- | :--- |
| `checkoutUrl` | `String` | URL alojada en los servidores seguros de Stripe Checkout |
| `sessionId` | `String` | Identificador único de sesión emitido por Stripe (cs_test_...) |

**Ejemplo de Carga Útil JSON (Response):**
```json
{
  "checkoutUrl": "https://checkout.stripe.com/c/pay/cs_test_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6",
  "sessionId": "cs_test_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | URLs de retorno malformadas o planId nulo |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| `403 Forbidden` | `AccessDeniedException` | Permisos insuficientes para gestionar sesiones de pago |
| `404 Not Found` | `PlanNotFoundException` | El plan seleccionado no existe en el catálogo |
| `409 Conflict` | `DuplicateActiveSubscriptionException` | El taller ya cuenta con una suscripción activa idéntica |
| `502 Bad Gateway` | `StripeIntegrationException` | Falla de conexión telemática con los servidores de Stripe |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/stripe-integration-error",
  "title": "Stripe Integration Error",
  "status": 502,
  "detail": "Error de comunicación con la API de Stripe al crear la sesión de Checkout",
  "instance": "/api/v1/billing/subscriptions/checkout-session",
  "code": "ERR_STRIPE_INTEGRATION",
  "timestamp": "2026-10-04T02:20:00Z"
}
```

---

### 4.3. [POST] /api/v1/billing/subscriptions/customer-portal

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.billing.interfaces.rest.controllers.TenantSubscriptionsController`
* **Método Java:** `public ResponseEntity<CustomerPortalResponse> createCustomerPortalSession(@Valid @RequestBody CustomerPortalRequest request, @AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/billing/subscriptions`
* **Ruta Completa:** `/api/v1/billing/subscriptions/customer-portal`
* **Propósito:** Genera una sesión de autogestión interactiva en el Stripe Customer Portal para actualizar tarjetas bancarias, consultar métodos de pago y descargar facturas.

#### Descripción Funcional
Proporciona al dueño del taller un enlace seguro y efímero hacia el portal alojado de Stripe Billing. Resuelve el `stripe_customer_id` vinculado al taller en la base de datos de Atelier, invoca la API de Stripe para instanciar la sesión del portal configurada con la URL de retorno proporcionada, y entrega la URL firmada. A través de este portal oficial, el cliente puede cambiar su tarjeta de crédito o débito, modificar su domicilio comercial de facturación y descargar comprobantes históricos sin que Atelier almacene datos sensibles.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Administrador de Taller (`ROLE_TENANT_ADMIN`) o Dueño de Taller (`ROLE_WORKSHOP_OWNER`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('billing:subscriptions:manage_stripe')")`
* **Aislamiento Multi-Inquilino:** La sesión del portal se genera estrictamente contra el `stripe_customer_id` del taller autenticado.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
* **Parámetros de Ruta (Path Parameters):** No aplica.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
* **Registro Java DTO:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.requests.CustomerPortalRequest`
* **Definición de Campos:**

| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `returnUrl` | `String` | Sí | `@NotBlank` | URL del panel web del taller a la cual regresará el usuario al salir del portal |

**Ejemplo de Carga Útil JSON (Request):**
```json
{
  "returnUrl": "https://app.atelier.pe/settings/billing"
}
```

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `200 OK`
* **Registro Java DTO:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.responses.CustomerPortalResponse`
* **Definición de Campos Proyectados:**

| Campo | Tipo de Dato | Descripción |
| :--- | :--- | :--- |
| `portalUrl` | `String` | URL segura de redirección hacia el Stripe Customer Billing Portal |

**Ejemplo de Carga Útil JSON (Response):**
```json
{
  "portalUrl": "https://billing.stripe.com/p/session/portal_test_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Parámetro returnUrl ausente o con formato URI inválido |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o expirado |
| `403 Forbidden` | `AccessDeniedException` | Permisos insuficientes para acceder al portal de facturación |
| `404 Not Found` | `SubscriptionNotFoundException` | El taller no cuenta con un identificador de cliente en Stripe asociado |
| `502 Bad Gateway` | `StripeIntegrationException` | Error al contactar la API de portales de Stripe |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/subscription-not-found",
  "title": "Subscription Not Found",
  "status": 404,
  "detail": "El taller automotriz no posee un cliente de facturación registrado en la pasarela de pagos",
  "instance": "/api/v1/billing/subscriptions/customer-portal",
  "code": "ERR_SUBSCRIPTION_NOT_FOUND",
  "timestamp": "2026-10-04T02:25:00Z"
}
```

---

### 4.4. [POST] /api/v1/billing/subscriptions/cancel

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.billing.interfaces.rest.controllers.TenantSubscriptionsController`
* **Método Java:** `public ResponseEntity<TenantSubscriptionResource> cancelSubscription(@Valid @RequestBody CancelSubscriptionRequest request, @AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/billing/subscriptions`
* **Ruta Completa:** `/api/v1/billing/subscriptions/cancel`
* **Propósito:** Procesa la solicitud voluntaria de cancelación de la suscripción SaaS del taller, permitiendo finalizar al término del periodo o de manera inmediata.

#### Descripción Funcional
Permite a los administradores del taller cancelar formalmente su suscripción a Atelier Platform. El comando recibe un motivo descriptivo opcional y el indicador booleano `cancelImmediately`. Si `cancelImmediately` es falso, la suscripción se marca en Stripe con `cancel_at_period_end = true`, garantizando que el taller mantenga acceso operativo irrestricto hasta el final del periodo ya pagado. Si es verdadero, el contrato se rescinde de forma fulminante y se suspende el acceso al sistema. Tras la ejecución, se emite el evento de dominio `TenantSubscriptionCanceledEvent` y se actualiza la entrada en Caffeine Cache.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Administrador de Taller (`ROLE_TENANT_ADMIN`) o Dueño de Taller (`ROLE_WORKSHOP_OWNER`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('billing:subscriptions:manage_stripe')")`
* **Aislamiento Multi-Inquilino:** La cancelación afecta únicamente la membresía del `tenant_id` autenticado.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
* **Parámetros de Ruta (Path Parameters):** No aplica.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
* **Registro Java DTO:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.requests.CancelSubscriptionRequest`
* **Definición de Campos:**

| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `cancelImmediately` | `boolean` | Sí | Sin restricción adicional | Define si la cancelación opera de inmediato o al final del periodo |
| `cancellationReason` | `String` | No | Sin restricción adicional | Motivo cualitativo de la cancelación para analítica de retención |

**Ejemplo de Carga Útil JSON (Request):**
```json
{
  "cancelImmediately": false,
  "cancellationReason": "Cierre temporal de operaciones por remodelación del taller mecánico"
}
```

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `200 OK`
* **Registro Java DTO:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.responses.TenantSubscriptionResource`
* **Definición de Campos Proyectados:** Idéntica a la especificación de `TenantSubscriptionResource` con `cancelAtPeriodEnd = true` o `status = CANCELED`.

**Ejemplo de Carga Útil JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000301",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "planId": "018f6c40-7e12-7000-8000-000000000101",
  "planName": "Atelier Pro Mensual",
  "tier": "PRO",
  "status": "ACTIVE",
  "currentPeriodStart": "2026-10-01T00:00:00Z",
  "currentPeriodEnd": "2026-11-01T00:00:00Z",
  "cancelAtPeriodEnd": true,
  "trialEndDate": null,
  "quotaLimits": {
    "maxBranches": 2,
    "maxActiveStaff": 10,
    "maxActiveObd2Devices": 5,
    "maxPhotosPerWorkOrder": 50,
    "maxMonthlyAiReports": 10,
    "companyRegistrationAllowed": false,
    "multiWarehouseAllowed": false,
    "marketplaceListed": false,
    "maxMonthlyWorkOrders": 300,
    "iotTelemetryEnabled": true,
    "aiDiagnosticsEnabled": true
  },
  "isAccessGranted": true
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| `403 Forbidden` | `AccessDeniedException` | Permisos insuficientes para cancelar la suscripción del taller |
| `404 Not Found` | `SubscriptionNotFoundException` | El taller no cuenta con una suscripción activa para cancelar |
| `409 Conflict` | `BillingDomainException` | La suscripción ya se encuentra en estado cancelado definitivo |
| `502 Bad Gateway` | `StripeIntegrationException` | Error al notificar la cancelación a la pasarela de pagos Stripe |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/billing-domain-violation",
  "title": "Billing Domain Violation",
  "status": 409,
  "detail": "El contrato de suscripción ya se encuentra cancelado definitivamente",
  "instance": "/api/v1/billing/subscriptions/cancel",
  "code": "ERR_BILLING_DOMAIN_VIOLATION",
  "timestamp": "2026-10-04T02:30:00Z"
}
```

---

## 5. Endpoints de SaasInvoicesController

El controlador `SaasInvoicesController` administra el historial contable de facturas y comprobantes emitidos por la empresa proveedora de la plataforma (Andeva) hacia el taller automotriz, permitiendo la consulta de resúmenes, el detalle de recaudación y la redirección oficial hacia comprobantes en PDF.

### 5.1. [GET] /api/v1/billing/invoices

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.billing.interfaces.rest.controllers.SaasInvoicesController`
* **Método Java:** `public ResponseEntity<List<SaasInvoiceSummaryResource>> listInvoices(@AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/billing/invoices`
* **Ruta Completa:** `/api/v1/billing/invoices`
* **Propósito:** Obtiene la lista cronológica de comprobantes y facturas de suscripción emitidas al taller automotriz autenticado.

#### Descripción Funcional
Recupera el historial de comprobantes de pago generados periódicamente por la plataforma hacia el taller. Realiza una consulta optimizada sobre la tabla `saas_invoices` filtrando por el `tenant_id` autenticado, ordenada descendentemente por fecha de pago (`paidAt`). Retorna un listado de resúmenes contables ligeros optimizados para renderizado en tablas web, evitando sobrecargas de red al no transferir URLs pesadas en listados masivos.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Administrador de Taller (`ROLE_TENANT_ADMIN`), Dueño de Taller (`ROLE_WORKSHOP_OWNER`) o Contador (`ROLE_ACCOUNTANT`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('billing:invoices:read')")`
* **Aislamiento Multi-Inquilino:** Filtrado estricto por el `tenant_id` extraído del token JWT.

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
* **Registro Java DTO:** `List<com.andeva.atelier.platform.billing.interfaces.rest.resources.responses.SaasInvoiceSummaryResource>`
* **Definición de Campos Proyectados:**

| Campo | Tipo de Dato | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador único del comprobante en la base de datos de Atelier |
| `stripeInvoiceId` | `String` | Identificador oficial de factura en Stripe (ej. in_1Ou8abc) |
| `amountPaid` | `BigDecimal` | Monto total liquidado y recaudado |
| `currency` | `String` | Código ISO de tres caracteres de la divisa (ej. USD) |
| `status` | `String` | Estado del comprobante (PAID, OPEN, VOID, UNCOLLECTIBLE) |
| `paidAt` | `Instant` | Fecha y hora exacta de confirmación del pago en formato ISO 8601 UTC |

**Ejemplo de Carga Útil JSON (Response):**
```json
[
  {
    "id": "018f6c40-7e12-7000-8000-000000000401",
    "stripeInvoiceId": "in_1Ou8abc20261001",
    "amountPaid": 89.00,
    "currency": "USD",
    "status": "PAID",
    "paidAt": "2026-10-01T00:05:22Z"
  },
  {
    "id": "018f6c40-7e12-7000-8000-000000000402",
    "stripeInvoiceId": "in_1Ou8abc20260901",
    "amountPaid": 89.00,
    "currency": "USD",
    "status": "PAID",
    "paidAt": "2026-09-01T00:04:15Z"
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| `403 Forbidden` | `AccessDeniedException` | Permisos insuficientes para consultar facturas de la plataforma |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/access-denied",
  "title": "Access Denied",
  "status": 403,
  "detail": "El rol asignado no cuenta con privilegios contables para auditar facturas SaaS",
  "instance": "/api/v1/billing/invoices",
  "code": "ERR_ACCESS_DENIED",
  "timestamp": "2026-10-04T02:35:00Z"
}
```

---

### 5.2. [GET] /api/v1/billing/invoices/{id}

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.billing.interfaces.rest.controllers.SaasInvoicesController`
* **Método Java:** `public ResponseEntity<SaasInvoiceResource> getInvoiceById(@PathVariable UUID id, @AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/billing/invoices`
* **Ruta Completa:** `/api/v1/billing/invoices/{id}`
* **Propósito:** Consulta el detalle financiero y administrativo exhaustivo de un comprobante de facturación SaaS específico.

#### Descripción Funcional
Recupera el registro completo de la entidad `SaasInvoice` identificada por su `UUID`. Comprueba de forma rigurosa que el comprobante pertenezca al `tenant_id` autenticado, bloqueando accesos inter-inquilino. Retorna el identificador de suscripción asociada, el identificador oficial de Stripe, el monto cobrado, la fecha de emisión y las URLs seguras para inspección web alojada y descarga en PDF.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Administrador de Taller (`ROLE_TENANT_ADMIN`), Dueño de Taller (`ROLE_WORKSHOP_OWNER`) o Contador (`ROLE_ACCOUNTANT`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('billing:invoices:read')")`
* **Aislamiento Multi-Inquilino:** Verificación estricta de pertenencia al `tenant_id` del solicitante. Si el comprobante pertenece a otro inquilino, se emite una excepción de acceso no autorizado o no encontrado.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
  * `Accept: application/json`
* **Parámetros de Ruta (Path Parameters):**
  * `id` (`UUID`): Identificador universal de la factura SaaS en la base de datos.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
No aplica (Solicitud de tipo HTTP GET sin cuerpo).

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `200 OK`
* **Registro Java DTO:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.responses.SaasInvoiceResource`
* **Definición de Campos Proyectados:**

| Campo | Tipo de Dato | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador único de la factura en Atelier |
| `subscriptionId` | `UUID` | Identificador de la suscripción SaaS vinculada |
| `tenantId` | `UUID` | Identificador del taller automotriz titular |
| `stripeInvoiceId` | `String` | Identificador oficial del comprobante en Stripe |
| `amountPaid` | `BigDecimal` | Importe total liquidado |
| `currency` | `String` | Divisa de la transacción (USD o PEN) |
| `status` | `String` | Estado operativo del comprobante (PAID, OPEN, VOID, UNCOLLECTIBLE) |
| `invoicePdfUrl` | `String` | Enlace oficial firmado para la descarga del comprobante PDF en Stripe |
| `hostedInvoiceUrl` | `String` | Enlace a la interfaz web interactiva del comprobante en Stripe |
| `paidAt` | `Instant` | Fecha y hora de confirmación del pago en formato ISO 8601 UTC |
| `createdAt` | `Instant` | Fecha de emisión contable en formato ISO 8601 UTC |

**Ejemplo de Carga Útil JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000401",
  "subscriptionId": "018f6c40-7e12-7000-8000-000000000301",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "stripeInvoiceId": "in_1Ou8abc20261001",
  "amountPaid": 89.00,
  "currency": "USD",
  "status": "PAID",
  "invoicePdfUrl": "https://pay.stripe.com/invoice/acct_123/invst_456/pdf?s=ap",
  "hostedInvoiceUrl": "https://invoice.stripe.com/i/acct_123/invst_456",
  "paidAt": "2026-10-01T00:05:22Z",
  "createdAt": "2026-10-01T00:00:10Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentTypeMismatchException` | El formato del identificador de factura en la ruta no es un UUID válido |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o expirado |
| `403 Forbidden` | `AccessDeniedException` | Intento de acceder a un comprobante que pertenece a otro taller |
| `404 Not Found` | `SaasInvoiceNotFoundException` | La factura solicitada no existe en el registro del taller |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/saas-invoice-not-found",
  "title": "SaaS Invoice Not Found",
  "status": 404,
  "detail": "El comprobante contable con identificador 018f6c40-7e12-7000-8000-000000000499 no fue localizado",
  "instance": "/api/v1/billing/invoices/018f6c40-7e12-7000-8000-000000000499",
  "code": "ERR_SAAS_INVOICE_NOT_FOUND",
  "timestamp": "2026-10-04T02:40:00Z"
}
```

---

### 5.3. [GET] /api/v1/billing/invoices/{id}/pdf

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.billing.interfaces.rest.controllers.SaasInvoicesController`
* **Método Java:** `public ResponseEntity<Void> redirectToInvoicePdf(@PathVariable UUID id, @AuthenticationPrincipal Jwt jwt)`
* **Ruta Base:** `/api/v1/billing/invoices`
* **Ruta Completa:** `/api/v1/billing/invoices/{id}/pdf`
* **Propósito:** Redirige de forma transparente al usuario hacia el enlace oficial y seguro de descarga del PDF generado por Stripe.

#### Descripción Funcional
Comprueba la existencia del comprobante y su pertenencia al taller autenticado. En lugar de transmitir pesados flujos binarios de PDF a través del servidor de aplicaciones de Atelier sobrecargando la red interna, el controlador emite una respuesta de redirección HTTP `302 Found` con la cabecera estándar `Location` apuntando hacia la URL de descarga oficial generada por Stripe en su red de distribución CDN. El navegador del cliente inicia la descarga inmediata del documento fiscal emitido por Andeva.

#### Seguridad y Autorización
* **Nivel de Acceso:** Protegido / Taller Autenticado
* **Rol Mínimo Requerido:** Administrador de Taller (`ROLE_TENANT_ADMIN`), Dueño de Taller (`ROLE_WORKSHOP_OWNER`) o Contador (`ROLE_ACCOUNTANT`)
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('billing:invoices:read')")`
* **Aislamiento Multi-Inquilino:** Comprobación estricta de titularidad multi-inquilino sobre el recurso solicitado.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Authorization: Bearer <JWT>`
* **Parámetros de Ruta (Path Parameters):**
  * `id` (`UUID`): Identificador único de la factura en el sistema.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
No aplica (Solicitud de tipo HTTP GET sin cuerpo).

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `302 Found`
* **Cabeceras de Respuesta Clave:**
  * `Location: https://pay.stripe.com/invoice/acct_123/invst_456/pdf?s=ap`
* **Registro Java DTO:** No aplica (Cuerpo vacío con cabecera Location de redirección).

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| `403 Forbidden` | `AccessDeniedException` | Acceso denegado a comprobantes de otro inquilino |
| `404 Not Found` | `SaasInvoiceNotFoundException` | La factura solicitada no existe o carece de URL de descarga PDF |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/saas-invoice-not-found",
  "title": "SaaS Invoice Not Found",
  "status": 404,
  "detail": "El comprobante contable no dispone de archivo PDF disponible para descarga en este momento",
  "instance": "/api/v1/billing/invoices/018f6c40-7e12-7000-8000-000000000401/pdf",
  "code": "ERR_SAAS_INVOICE_NOT_FOUND",
  "timestamp": "2026-10-04T02:45:00Z"
}
```

---

## 6. Endpoints de StripeWebhooksController

El controlador `StripeWebhooksController` provee el canal de comunicación perimetral asíncrono y desacoplado para la ingesta segura de eventos emitidos por la pasarela de pagos Stripe Inc.

### 6.1. [POST] /api/v1/billing/webhooks/stripe

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.billing.interfaces.rest.controllers.StripeWebhooksController`
* **Método Java:** `public ResponseEntity<StripeWebhookAcknowledgmentResponse> handleWebhook(@RequestBody String rawPayload, @RequestHeader("Stripe-Signature") String signatureHeader)`
* **Ruta Base:** `/api/v1/billing/webhooks/stripe`
* **Ruta Completa:** `/api/v1/billing/webhooks/stripe`
* **Propósito:** Procesa eventos asíncronos enviados por Stripe, verificando matemáticamente la firma criptográfica HMAC-SHA256, garantizando idempotencia estricta y sincronizando el estado contable de las suscripciones.

#### Descripción Funcional
Constituye la puerta de entrada asíncrona de Stripe. Debido a que la verificación de firma criptográfica exige comparar el cuerpo crudo de la petición contra el encabezado sin mutaciones causadas por deserializadores JSON, el método recibe la cadena `rawPayload` intacta. El servicio `StripeWebhookSignatureVerificationService` calcula el hash HMAC-SHA256 utilizando el secreto `STRIPE_WEBHOOK_SECRET` y tolera un desfase temporal máximo de 300 segundos para impedir ataques de repetición.

Tras la validación matemática:
1. Registra el identificador de evento (`eventId`) en la tabla de idempotencia `stripe_events`. Si el evento ya fue registrado previamente, descarta la ejecución retornando inmediatamente confirmación `200 OK` para evitar cobros o renovaciones duplicadas.
2. Despacha el comando transaccional correspondiente según el tipo de evento:
   * `customer.subscription.created` y `customer.subscription.updated`: Actualiza vigencia, periodo y cuotas en `TenantSubscription`.
   * `invoice.payment_succeeded`: Registra el comprobante en `saas_invoices` y emite `SaasInvoicePaymentSucceededEvent`.
   * `invoice.payment_failed`: Pasa la membresía a estado `PAST_DUE` y despacha alerta urgente por correo mediante Resend.
   * `customer.subscription.deleted`: Marca el contrato como rescindido (`CANCELED`).
3. Invalida de forma reactiva la entrada del taller en Caffeine Cache.

#### Seguridad y Autorización
* **Nivel de Acceso:** Público Perimetral / Pasarela Externa Stripe
* **Rol Mínimo Requerido:** No aplica (Punto de enlace perimetral externo)
* **Permiso Atómico:** Verificación Criptográfica de Cabecera `Stripe-Signature` contra el secreto de webhook `STRIPE_WEBHOOK_SECRET`
* **Aislamiento Multi-Inquilino:** La tenencia se resuelve a partir de los metadatos (`metadata.tenantId`) o del cliente de Stripe (`customer`) contenido en el objeto del evento.

#### Parámetros de Invocación
* **Cabeceras HTTP (Headers):**
  * `Content-Type: application/json`
  * `Stripe-Signature: t=1614552225,v1=5257a869e7eee22... (Obligatoria)`
* **Parámetros de Ruta (Path Parameters):** No aplica.
* **Parámetros de Consulta (Query Parameters):** No aplica.

#### Recurso de Petición (Request Body)
* **Registro Java DTO:** Cadena JSON cruda (`String rawPayload`) correspondiente a la estructura del evento Stripe.

**Ejemplo de Carga Útil JSON (Request - Evento invoice.payment_succeeded):**
```json
{
  "id": "evt_1Ou8abcPaymentSuccess001",
  "object": "event",
  "api_version": "2024-06-20",
  "created": 1727740800,
  "type": "invoice.payment_succeeded",
  "data": {
    "object": {
      "id": "in_1Ou8abc20261001",
      "object": "invoice",
      "amount_paid": 8900,
      "currency": "usd",
      "customer": "cus_1Ou8abcCustomerTaller01",
      "subscription": "sub_1Ou8abcSubActive01",
      "status": "paid",
      "invoice_pdf": "https://pay.stripe.com/invoice/acct_123/invst_456/pdf?s=ap",
      "hosted_invoice_url": "https://invoice.stripe.com/i/acct_123/invst_456",
      "lines": {
        "data": [
          {
            "id": "il_1Ou8abcLineItem01",
            "amount": 8900,
            "currency": "usd",
            "period": {
              "start": 1727740800,
              "end": 1730419200
            },
            "price": {
              "id": "price_1Ou8abcPROMonthly"
            }
          }
        ]
      },
      "metadata": {
        "tenantId": "018f6c40-7e12-7000-8000-000000000001"
      }
    }
  }
}
```

#### Recurso de Respuesta (Response Body)
* **Estado HTTP Exitoso:** `200 OK`
* **Registro Java DTO:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.responses.StripeWebhookAcknowledgmentResponse`
* **Definición de Campos Proyectados:**

| Campo | Tipo de Dato | Descripción |
| :--- | :--- | :--- |
| `received` | `boolean` | Confirmación booleana de recepción exitosa para Stripe |
| `eventId` | `String` | Identificador del evento registrado para fines de auditoría |
| `status` | `String` | Estado de procesamiento del evento (PROCESSED o DUPLICATE_IGNORED) |

**Ejemplo de Carga Útil JSON (Response):**
```json
{
  "received": true,
  "eventId": "evt_1Ou8abcPaymentSuccess001",
  "status": "PROCESSED"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Excepción Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `BillingDomainException` | Carga JSON vacía o malformada |
| `401 Unauthorized` | `InvalidWebhookSignatureException` | Firma Stripe-Signature ausente, expirada o con hash HMAC incorrecto |
| `422 Unprocessable Entity` | `StripeWebhookProcessingException` | Esquema del evento irreconocible o metadatos de tenantId corruptos |
| `500 Internal Server Error` | `BillingDomainException` | Falla de concurrencia al registrar la persistencia en base de datos |

**Ejemplo de Carga Útil de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.andeva.com/errors/invalid-webhook-signature",
  "title": "Invalid Webhook Signature",
  "status": 401,
  "detail": "La firma criptográfica HMAC-SHA256 en la cabecera Stripe-Signature no coincide con el secreto configurado",
  "instance": "/api/v1/billing/webhooks/stripe",
  "code": "ERR_INVALID_WEBHOOK_SIGNATURE",
  "timestamp": "2026-10-04T02:50:00Z"
}
```
