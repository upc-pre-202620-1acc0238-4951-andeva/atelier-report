# Especificación Canónica de Endpoints: SaaS Billing and Subscriptions

## 1. Identidad y Propósito del Bounded Context

El Bounded Context **SaaS Billing and Subscriptions** (`com.andeva.atelier.platform.billing`) gobierna el modelo de monetización recurrente B2B, el aprovisionamiento de planes comerciales, el control de cuotas operativas y la conciliación contable de cobros entre la empresa proveedora de la plataforma (Andeva) y los talleres mecánicos abonados.

Para el detalle de diseño estratégico, agregados y entidades de dominio, consultar:
* [08-saas-billing-and-subscriptions.md](file:///home/shouy/development/atelier-report/docs/extended-description-bounded-contexts-backend/08-saas-billing-and-subscriptions.md)
* [atelier-roles.md](file:///home/shouy/development/atelier-report/docs/backend-documentation/atelier-roles.md)
* [atelier-database-schema.md](file:///home/shouy/development/atelier-report/docs/atelier-database-schema.md)

### Principios Fundamentales del Módulo
1. **Desacoplamiento Fiscal:** Este contexto gestiona exclusivamente las tarifas y membresías cobradas por la plataforma al taller. Los comprobantes fiscales tributarios emitidos por el taller a sus clientes particulares son administrados por el módulo de facturación local.
2. **Cumplimiento PCI-DSS:** El backend jamás almacena ni procesa números de tarjeta bancaria ni códigos de seguridad. Todo intercambio sensible se delega a Stripe Elements, almacenando únicamente identificadores tokenizados.
3. **Idempotencia Estricta en Webhooks:** Deduplicación estricta de eventos asíncronos mediante identificador unívoco de evento en base de datos.
4. **Caché en Memoria:** Evaluación de cuotas con baja latencia mediante Caffeine Cache e invalidación reactiva inmediata ante cambios contractuales.

---

## 2. Inventario de Controladores y Endpoints

El módulo expone un total de 13 endpoints REST organizados en 4 controladores:

1. **SubscriptionPlansController** (`/api/v1/billing/plans`): 4 endpoints para catálogo comercial y administración de tarifas.
2. **TenantSubscriptionsController** (`/api/v1/billing/subscriptions`): 5 endpoints para ciclo de vida de membresías, checkout y portal de cliente.
3. **SaasInvoicesController** (`/api/v1/billing/invoices`): 3 endpoints para historial de facturación de plataforma y comprobantes PDF.
4. **StripeWebhooksController** (`/api/v1/billing/webhooks/stripe`): 1 endpoint para ingesta de eventos asíncronos de la pasarela de pagos.

---

## 3. Especificación Detallada de Endpoints

### 3.1. SubscriptionPlansController

Controlador encargado de la publicación del catálogo de planes comerciales y de la parametrización de cuotas operativas.

#### GET /api/v1/billing/plans

##### Identidad Técnica
* **Controlador:** `SubscriptionPlansController` (`com.andeva.atelier.platform.billing.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<List<SubscriptionPlanResource>> getAllActivePlans(@RequestParam(required = false) String billingCycle)`

##### Descripción Funcional
Consulta la lista consolidada de planes comerciales activos disponibles para contratación. Retorna los niveles de membresía (Go, Pro, Max y Enterprise), precios bases, periodicidad y el conjunto completo de límites y habilitaciones de cuota operativa.

##### Seguridad y Autorización
* **Rol Mínimo:** Acceso público perimetral o cualquier usuario autenticado.
* **Permiso Atómico:** `billing:plans:read` o acceso libre en pasarela perimetral.
* **Contexto Multi-Inquilino:** No requiere aislamiento por taller al tratarse de un catálogo global de la plataforma.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Opcional para visitantes, recomendado para clientes autenticados)
* **Path Variables:** Ninguna.
* **Query Parameters:**
  | Parámetro | Tipo | Requerido | Descripción |
  | :--- | :--- | :--- | :--- |
  | `billingCycle` | String | No | Filtro por ciclo de facturación. Valores admitidos: `MONTHLY`, `YEARLY`. |

##### Request DTO
No aplica para peticiones de lectura HTTP GET.

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `List<com.andeva.atelier.platform.billing.interfaces.rest.resources.responses.SubscriptionPlanResource>`

Campos del recurso `SubscriptionPlanResource`:
| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | UUID | Identificador universal único del plan comercial en la plataforma. |
| `stripePriceId` | String | Identificador del objeto Price registrado en Stripe. |
| `name` | String | Nombre comercial del plan (Go, Pro, Max o Enterprise). |
| `tier` | String | Nivel del plan (`GO`, `PRO`, `MAX`, `ENTERPRISE`). |
| `price` | BigDecimal | Importe monetario de la tarifa base. |
| `currency` | String | Código de moneda bajo estándar ISO 4217 (USD o PEN). |
| `billingCycle` | String | Periodicidad de cobro recurrente (`MONTHLY` o `YEARLY`). |
| `quotaLimits` | TenantQuotaLimitsDto | Objeto anidado con los techos y habilitaciones de recursos del plan. |
| `quotaLimits.maxBranches` | int | Límite máximo de sucursales físicas permitidas. |
| `quotaLimits.maxActiveStaff` | int | Límite máximo de mecánicos y personal activo simultáneamente. |
| `quotaLimits.maxActiveObd2Devices` | int | Límite de escáneres OBD-II telemáticos vinculados en simultáneo. |
| `quotaLimits.maxPhotosPerWorkOrder` | int | Límite de evidencias fotográficas periciales por orden de trabajo. |
| `quotaLimits.maxMonthlyAiReports` | int | Cupo mensual de informes de salud mecánica asistidos por inteligencia artificial. |
| `quotaLimits.companyRegistrationAllowed` | boolean | Indicador de permiso para registrar clientes corporativos y flotas. |
| `quotaLimits.multiWarehouseAllowed` | boolean | Indicador de permiso para transferencias de inventario multi-almacén FIFO. |
| `quotaLimits.marketplaceListed` | boolean | Indicador de presencia comercial en el marketplace de flotas Atelier Business. |
| `quotaLimits.maxMonthlyWorkOrders` | int | Cupo máximo mensual de órdenes de trabajo emitidas. |
| `quotaLimits.iotTelemetryEnabled` | boolean | Indicador de habilitación de ingesta telemática en tiempo real. |
| `quotaLimits.aiDiagnosticsEnabled` | boolean | Indicador de habilitación de diagnósticos predictivos de falla. |
| `features` | List<PlanFeatureResource> | Lista de características comerciales paquetizadas dentro del plan. |
| `isActive` | boolean | Estado de vigencia comercial del plan para nuevas compras. |
| `createdAt` | Instant | Marca temporal de registro inicial en el sistema. |
| `updatedAt` | Instant | Marca temporal de última modificación contractual. |

Ejemplo JSON de Respuesta:
```json
[
  {
    "id": "1e548f3b-8d76-47b2-b13c-fa5d206f4001",
    "stripePriceId": "price_1OuAtelierGoMonth001",
    "name": "Plan Go",
    "tier": "GO",
    "price": 49.00,
    "currency": "USD",
    "billingCycle": "MONTHLY",
    "quotaLimits": {
      "maxBranches": 1,
      "maxActiveStaff": 5,
      "maxActiveObd2Devices": 0,
      "maxPhotosPerWorkOrder": 10,
      "maxMonthlyAiReports": 0,
      "companyRegistrationAllowed": false,
      "multiWarehouseAllowed": false,
      "marketplaceListed": false,
      "maxMonthlyWorkOrders": 100,
      "iotTelemetryEnabled": false,
      "aiDiagnosticsEnabled": false
    },
    "features": [
      {
        "id": "fe018f3b-8d76-47b2-b13c-fa5d206f4001",
        "featureKey": "FEATURE_SINGLE_BRANCH_MRO",
        "name": "Operaciones en Sede Unica",
        "description": "Gestion de ordenes de trabajo y citas para un taller individual.",
        "isEnabled": true
      },
      {
        "id": "fe028f3b-8d76-47b2-b13c-fa5d206f4002",
        "featureKey": "FEATURE_BASIC_INVENTORY",
        "name": "Inventario Valorizado FIFO",
        "description": "Control de repuestos y costeo por lote para almacen unico.",
        "isEnabled": true
      }
    ],
    "isActive": true,
    "createdAt": "2026-01-15T08:00:00Z",
    "updatedAt": "2026-01-15T08:00:00Z"
  },
  {
    "id": "2e548f3b-8d76-47b2-b13c-fa5d206f4002",
    "stripePriceId": "price_1OuAtelierProMonth002",
    "name": "Plan Pro",
    "tier": "PRO",
    "price": 129.00,
    "currency": "USD",
    "billingCycle": "MONTHLY",
    "quotaLimits": {
      "maxBranches": 2,
      "maxActiveStaff": 10,
      "maxActiveObd2Devices": 5,
      "maxPhotosPerWorkOrder": 100,
      "maxMonthlyAiReports": 0,
      "companyRegistrationAllowed": false,
      "multiWarehouseAllowed": false,
      "marketplaceListed": false,
      "maxMonthlyWorkOrders": 300,
      "iotTelemetryEnabled": true,
      "aiDiagnosticsEnabled": false
    },
    "features": [
      {
        "id": "fe038f3b-8d76-47b2-b13c-fa5d206f4003",
        "featureKey": "FEATURE_OBD2_TELEMETRY",
        "name": "Telemetria OBD-II en Vivo",
        "description": "Conectividad Bluetooth con escaneres para monitoreo de RPM y temperatura.",
        "isEnabled": true
      }
    ],
    "isActive": true,
    "createdAt": "2026-01-15T08:00:00Z",
    "updatedAt": "2026-01-15T08:00:00Z"
  }
]
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `500 Internal Server Error` | `https://api.atelier.andeva.pe/errors/internal-error` | `BillingInfrastructureException` | Error no controlado en persistencia o conectividad de catálogo. |

Ejemplo JSON ProblemDetail:
```json
{
  "type": "https://api.atelier.andeva.pe/errors/internal-error",
  "title": "Error Interno de Infraestructura",
  "status": 500,
  "detail": "No se pudo recuperar el catalogo comercial debido a una indisponibilidad temporal.",
  "instance": "/api/v1/billing/plans",
  "code": "BILLING_CATALOG_UNAVAILABLE",
  "timestamp": "2026-10-01T15:30:00Z"
}
```

---

#### GET /api/v1/billing/plans/{id}

##### Identidad Técnica
* **Controlador:** `SubscriptionPlansController` (`com.andeva.atelier.platform.billing.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<SubscriptionPlanResource> getPlanById(@PathVariable UUID id)`

##### Descripción Funcional
Consulta la ficha técnica y comercial completa de un plan de suscripción específico a partir de su identificador único universal.

##### Seguridad y Autorización
* **Rol Mínimo:** Acceso público perimetral o cualquier usuario autenticado.
* **Permiso Atómico:** `billing:plans:read`.
* **Contexto Multi-Inquilino:** No requiere aislamiento por taller.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Opcional en catálogo público)
* **Path Variables:**
  | Variable | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `id` | UUID | Identificador universal único del plan comercial. |
* **Query Parameters:** Ninguno.

##### Request DTO
No aplica para peticiones HTTP GET.

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.responses.SubscriptionPlanResource`

Ejemplo JSON de Respuesta:
```json
{
  "id": "2e548f3b-8d76-47b2-b13c-fa5d206f4002",
  "stripePriceId": "price_1OuAtelierProMonth002",
  "name": "Plan Pro",
  "tier": "PRO",
  "price": 129.00,
  "currency": "USD",
  "billingCycle": "MONTHLY",
  "quotaLimits": {
    "maxBranches": 2,
    "maxActiveStaff": 10,
    "maxActiveObd2Devices": 5,
    "maxPhotosPerWorkOrder": 100,
    "maxMonthlyAiReports": 0,
    "companyRegistrationAllowed": false,
    "multiWarehouseAllowed": false,
    "marketplaceListed": false,
    "maxMonthlyWorkOrders": 300,
    "iotTelemetryEnabled": true,
    "aiDiagnosticsEnabled": false
  },
  "features": [
    {
      "id": "fe038f3b-8d76-47b2-b13c-fa5d206f4003",
      "featureKey": "FEATURE_OBD2_TELEMETRY",
      "name": "Telemetria OBD-II en Vivo",
      "description": "Conectividad Bluetooth con escaneres para monitoreo de RPM y temperatura.",
      "isEnabled": true
    }
  ],
  "isActive": true,
  "createdAt": "2026-01-15T08:00:00Z",
  "updatedAt": "2026-01-15T08:00:00Z"
}
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `400 Bad Request` | `https://api.atelier.andeva.pe/errors/invalid-identifier` | `IllegalArgumentException` | El identificador proporcionado en la ruta no cumple el formato UUID estándar. |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/plan-not-found` | `PlanNotFoundException` | No existe ningun plan registrado con el identificador UUID proporcionado. |

Ejemplo JSON ProblemDetail:
```json
{
  "type": "https://api.atelier.andeva.pe/errors/plan-not-found",
  "title": "Plan Comercial No Encontrado",
  "status": 404,
  "detail": "El plan de suscripcion con identificador 2e548f3b-8d76-47b2-b13c-fa5d206f4999 no existe en el sistema.",
  "instance": "/api/v1/billing/plans/2e548f3b-8d76-47b2-b13c-fa5d206f4999",
  "code": "PLAN_NOT_FOUND",
  "timestamp": "2026-10-01T15:31:00Z"
}
```

---

#### POST /api/v1/billing/plans

##### Identidad Técnica
* **Controlador:** `SubscriptionPlansController` (`com.andeva.atelier.platform.billing.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<SubscriptionPlanResource> createSubscriptionPlan(@Valid @RequestBody CreateSubscriptionPlanRequest request)`

##### Descripción Funcional
Registra administrativamente un nuevo paquete comercial en Atelier Platform, asociándolo con un identificador de precio recurrente previamente creado en Stripe y estableciendo las cuotas técnicas inmutables que gobernarán a los talleres suscriptores.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_SUPER_ADMIN` (Administrador global de la plataforma Andeva).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('billing:plans:write') and hasRole('ROLE_SUPER_ADMIN')")`
* **Contexto Multi-Inquilino:** Operación administrativa global a nivel de plataforma.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio con credenciales de superadministrador)
  * `Content-Type: application/json` (Obligatorio)
* **Path Variables:** Ninguna.
* **Query Parameters:** Ninguno.

##### Request DTO
* **Record Java:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.requests.CreateSubscriptionPlanRequest`

Tabla de Campos:
| Campo | Tipo Java | Validaciones Jakarta | Descripción |
| :--- | :--- | :--- | :--- |
| `stripePriceId` | String | `@NotBlank`, `@Pattern(regexp = "^price_[a-zA-Z0-9]+$")` | Identificador del precio recurrente generado en la consola de Stripe. |
| `name` | String | `@NotBlank`, `@Size(min = 3, max = 100)` | Nombre comercial del plan. |
| `tier` | String | `@NotBlank`, `@Pattern(regexp = "^(GO\|PRO\|MAX\|ENTERPRISE)$")` | Nivel arquitectónico del plan. |
| `price` | BigDecimal | `@NotNull`, `@DecimalMin("0.0")`, `@Digits(integer = 10, fraction = 2)` | Importe monetario base del plan. |
| `currency` | String | `@NotBlank`, `@Size(min = 3, max = 3)` | Código de moneda bajo estándar ISO 4217 (USD o PEN). |
| `billingCycle` | String | `@NotBlank`, `@Pattern(regexp = "^(MONTHLY\|YEARLY)$")` | Ciclo de cobro recurrente. |
| `quotaLimits` | TenantQuotaLimitsDto | `@NotNull`, `@Valid` | Estructura con las cuotas y límites del plan. |
| `features` | List<PlanFeatureRequest> | `@Valid` | Lista opcional de funcionalidades paquetizadas. |

Ejemplo JSON de Solicitud:
```json
{
  "stripePriceId": "price_1OuAtelierMaxMonth003",
  "name": "Plan Max",
  "tier": "MAX",
  "price": 249.00,
  "currency": "USD",
  "billingCycle": "MONTHLY",
  "quotaLimits": {
    "maxBranches": 5,
    "maxActiveStaff": 25,
    "maxActiveObd2Devices": 15,
    "maxPhotosPerWorkOrder": 150,
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
      "featureKey": "FEATURE_AI_PREDICTIONS",
      "name": "Diagnostico Predictivo Spring AI",
      "description": "Inferencia pericial en la nube LPU de Groq con analisis termodinamico.",
      "isEnabled": true
    },
    {
      "featureKey": "FEATURE_MULTI_WAREHOUSE",
      "name": "Gestion Multi-Almacen FIFO",
      "description": "Transferencias de inventario entre sedes y costeo estricto por lote.",
      "isEnabled": true
    }
  ]
}
```

##### Response DTO
* **Estado HTTP:** `201 Created`
* **Headers:** `Location: /api/v1/billing/plans/{id}`
* **Record Java:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.responses.SubscriptionPlanResource`

Ejemplo JSON de Respuesta:
```json
{
  "id": "3e548f3b-8d76-47b2-b13c-fa5d206f4003",
  "stripePriceId": "price_1OuAtelierMaxMonth003",
  "name": "Plan Max",
  "tier": "MAX",
  "price": 249.00,
  "currency": "USD",
  "billingCycle": "MONTHLY",
  "quotaLimits": {
    "maxBranches": 5,
    "maxActiveStaff": 25,
    "maxActiveObd2Devices": 15,
    "maxPhotosPerWorkOrder": 150,
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
      "id": "fe048f3b-8d76-47b2-b13c-fa5d206f4004",
      "featureKey": "FEATURE_AI_PREDICTIONS",
      "name": "Diagnostico Predictivo Spring AI",
      "description": "Inferencia pericial en la nube LPU de Groq con analisis termodinamico.",
      "isEnabled": true
    }
  ],
  "isActive": true,
  "createdAt": "2026-10-01T15:32:00Z",
  "updatedAt": "2026-10-01T15:32:00Z"
}
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `400 Bad Request` | `https://api.atelier.andeva.pe/errors/validation-failed` | `MethodArgumentNotValidException` | Campos requeridos ausentes o violación de expresiones regulares. |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente, vencido o con firma criptográfica inválida. |
| `403 Forbidden` | `https://api.atelier.andeva.pe/errors/forbidden` | `AccessDeniedException` | El usuario no ostenta el rol de superadministrador de plataforma. |
| `409 Conflict` | `https://api.atelier.andeva.pe/errors/duplicate-plan` | `DuplicatePlanException` | Ya existe un plan registrado con el mismo `stripePriceId` o nombre. |
| `422 Unprocessable Entity` | `https://api.atelier.andeva.pe/errors/invalid-plan-pricing` | `InvalidPlanPricingException` | Tarifas monetarias negativas o configuración inconsistente de cuotas. |

Ejemplo JSON ProblemDetail:
```json
{
  "type": "https://api.atelier.andeva.pe/errors/duplicate-plan",
  "title": "Conflicto en Registro de Plan",
  "status": 409,
  "detail": "El identificador de precio price_1OuAtelierMaxMonth003 ya se encuentra asignado a otro plan activo.",
  "instance": "/api/v1/billing/plans",
  "code": "DUPLICATE_STRIPE_PRICE_ID",
  "timestamp": "2026-10-01T15:32:30Z"
}
```

---

#### PUT /api/v1/billing/plans/{id}

##### Identidad Técnica
* **Controlador:** `SubscriptionPlansController` (`com.andeva.atelier.platform.billing.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<SubscriptionPlanResource> updateSubscriptionPlan(@PathVariable UUID id, @Valid @RequestBody UpdateSubscriptionPlanRequest request)`

##### Descripción Funcional
Actualiza los parámetros comerciales, las cuotas operativas autorizadas o el estado de vigencia comercial de un plan de software existente.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_SUPER_ADMIN`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('billing:plans:write') and hasRole('ROLE_SUPER_ADMIN')")`
* **Contexto Multi-Inquilino:** Operación administrativa global.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
  * `Content-Type: application/json` (Obligatorio)
* **Path Variables:**
  | Variable | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `id` | UUID | Identificador universal del plan comercial a modificar. |
* **Query Parameters:** Ninguno.

##### Request DTO
* **Record Java:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.requests.UpdateSubscriptionPlanRequest`

Tabla de Campos:
| Campo | Tipo Java | Validaciones Jakarta | Descripción |
| :--- | :--- | :--- | :--- |
| `name` | String | `@NotBlank`, `@Size(min = 3, max = 100)` | Nombre comercial actualizado del plan. |
| `price` | BigDecimal | `@NotNull`, `@DecimalMin("0.0")`, `@Digits(integer = 10, fraction = 2)` | Nueva tarifa monetaria. |
| `billingCycle` | String | `@NotBlank`, `@Pattern(regexp = "^(MONTHLY\|YEARLY)$")` | Periodicidad de cobro. |
| `quotaLimits` | TenantQuotaLimitsDto | `@NotNull`, `@Valid` | Nuevos techos de cuota operativa. |
| `isActive` | Boolean | Opcional | Estado de vigencia comercial para nuevas ventas. |

Ejemplo JSON de Solicitud:
```json
{
  "name": "Plan Pro Plus",
  "price": 139.00,
  "billingCycle": "MONTHLY",
  "quotaLimits": {
    "maxBranches": 2,
    "maxActiveStaff": 12,
    "maxActiveObd2Devices": 8,
    "maxPhotosPerWorkOrder": 120,
    "maxMonthlyAiReports": 10,
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

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.responses.SubscriptionPlanResource`

Ejemplo JSON de Respuesta:
```json
{
  "id": "2e548f3b-8d76-47b2-b13c-fa5d206f4002",
  "stripePriceId": "price_1OuAtelierProMonth002",
  "name": "Plan Pro Plus",
  "tier": "PRO",
  "price": 139.00,
  "currency": "USD",
  "billingCycle": "MONTHLY",
  "quotaLimits": {
    "maxBranches": 2,
    "maxActiveStaff": 12,
    "maxActiveObd2Devices": 8,
    "maxPhotosPerWorkOrder": 120,
    "maxMonthlyAiReports": 10,
    "companyRegistrationAllowed": false,
    "multiWarehouseAllowed": false,
    "marketplaceListed": false,
    "maxMonthlyWorkOrders": 400,
    "iotTelemetryEnabled": true,
    "aiDiagnosticsEnabled": true
  },
  "features": [],
  "isActive": true,
  "createdAt": "2026-01-15T08:00:00Z",
  "updatedAt": "2026-10-01T15:33:00Z"
}
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `400 Bad Request` | `https://api.atelier.andeva.pe/errors/validation-failed` | `MethodArgumentNotValidException` | Formato numérico incorrecto o violaciones de validación en campos. |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de autenticación ausente o inválido. |
| `403 Forbidden` | `https://api.atelier.andeva.pe/errors/forbidden` | `AccessDeniedException` | Permisos insuficientes sin rol de superadministrador. |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/plan-not-found` | `PlanNotFoundException` | El plan a actualizar no existe en el catálogo. |
| `422 Unprocessable Entity` | `https://api.atelier.andeva.pe/errors/invalid-plan-pricing` | `InvalidPlanPricingException` | Se intenta reducir cuotas operativas por debajo de mínimos permitidos. |

---

### 3.2. TenantSubscriptionsController

Controlador encargado de la gestión del ciclo contractual del taller, sesiones de pago seguras en Stripe Checkout y autogestión de medios de pago.

#### GET /api/v1/billing/subscriptions/me

##### Identidad Técnica
* **Controlador:** `TenantSubscriptionsController` (`com.andeva.atelier.platform.billing.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<TenantSubscriptionResource> getCurrentTenantSubscription(@AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Consulta la suscripción contractual activa del taller automotriz autenticado, su estado contable (`ACTIVE`, `TRIALING`, `PAST_DUE`), periodo de cobertura vigente, bandera de cancelación al fin de ciclo y techos de cuota operativa asignados.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_TENANT_ADMIN` o `ROLE_WORKSHOP_OWNER`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('billing:subscriptions:read')")`
* **Contexto Multi-Inquilino:** El identificador del taller (`tenant_id`) se resuelve de manera determinista desde los claims del token JWT, impidiendo consultas cruzadas entre talleres.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
* **Path Variables:** Ninguna.
* **Query Parameters:** Ninguno.

##### Request DTO
No aplica para peticiones HTTP GET.

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.responses.TenantSubscriptionResource`

Tabla de Campos:
| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | UUID | Identificador unívoco de la suscripción SaaS. |
| `tenantId` | UUID | Identificador del taller titular del contrato. |
| `planId` | UUID | Identificador del plan comercial contratado. |
| `planName` | String | Nombre comercial del plan contratado (ej. Plan Pro). |
| `tier` | String | Nivel del plan (`GO`, `PRO`, `MAX`, `ENTERPRISE`). |
| `status` | String | Estado contable del ciclo de vida (`ACTIVE`, `TRIALING`, `PAST_DUE`, `CANCELED`). |
| `currentPeriodStart` | Instant | Fecha y hora de inicio de la cobertura del ciclo actual. |
| `currentPeriodEnd` | Instant | Fecha y hora límite del ciclo actual antes de renovación. |
| `cancelAtPeriodEnd` | boolean | Indica si la suscripción se dará de baja al concluir el periodo. |
| `trialEndDate` | Instant | Fecha de vencimiento del periodo de prueba gratuita (nullable). |
| `quotaLimits` | TenantQuotaLimitsDto | Cuotas y límites operacionales vigentes para el taller. |
| `isAccessGranted` | boolean | Indicador consolidado de autorización para operar en la plataforma. |

Ejemplo JSON de Respuesta:
```json
{
  "id": "5a432109-8d76-47b2-b13c-fa5d206f4005",
  "tenantId": "a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d",
  "planId": "2e548f3b-8d76-47b2-b13c-fa5d206f4002",
  "planName": "Plan Pro",
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
    "maxPhotosPerWorkOrder": 100,
    "maxMonthlyAiReports": 0,
    "companyRegistrationAllowed": false,
    "multiWarehouseAllowed": false,
    "marketplaceListed": false,
    "maxMonthlyWorkOrders": 300,
    "iotTelemetryEnabled": true,
    "aiDiagnosticsEnabled": false
  },
  "isAccessGranted": true
}
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token JWT expirado o cabecera de autorización ausente. |
| `403 Forbidden` | `https://api.atelier.andeva.pe/errors/forbidden` | `AccessDeniedException` | Usuario sin privilegios de administración en el taller. |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/subscription-not-found` | `SubscriptionNotFoundException` | El taller recién creado no posee ninguna suscripción inicial registrada. |

Ejemplo JSON ProblemDetail:
```json
{
  "type": "https://api.atelier.andeva.pe/errors/subscription-not-found",
  "title": "Suscripcion No Encontrada",
  "status": 404,
  "detail": "El taller no cuenta con una suscripcion activa ni periodo de prueba vigente.",
  "instance": "/api/v1/billing/subscriptions/me",
  "code": "SUBSCRIPTION_NOT_FOUND",
  "timestamp": "2026-10-01T15:34:00Z"
}
```

---

#### POST /api/v1/billing/subscriptions/checkout-session

##### Identidad Técnica
* **Controlador:** `TenantSubscriptionsController` (`com.andeva.atelier.platform.billing.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<CheckoutSessionResponse> createCheckoutSession(@Valid @RequestBody CreateCheckoutSessionRequest request, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Inicializa una sesión de pago alojada en **Stripe Checkout** para contratar una nueva membresía o formalizar un plan de pago tras el periodo de prueba. Retorna la URL segura de redirección de Stripe y el identificador de sesión.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_TENANT_ADMIN` o `ROLE_WORKSHOP_OWNER`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('billing:subscriptions:manage_stripe')")`
* **Contexto Multi-Inquilino:** Inyecta de forma segura el `tenant_id` autenticado dentro de los metadatos de la sesión de Stripe (`client_reference_id` y `metadata.tenant_id`).

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
  * `Content-Type: application/json` (Obligatorio)
* **Path Variables:** Ninguna.
* **Query Parameters:** Ninguno.

##### Request DTO
* **Record Java:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.requests.CreateCheckoutSessionRequest`

Tabla de Campos:
| Campo | Tipo Java | Validaciones Jakarta | Descripción |
| :--- | :--- | :--- | :--- |
| `planId` | UUID | `@NotNull` | Identificador universal del plan comercial que se desea contratar. |
| `successUrl` | String | `@NotBlank` | URL de retorno de la aplicación tras confirmarse el pago exitoso en Stripe. |
| `cancelUrl` | String | `@NotBlank` | URL de retorno si el usuario desiste o cancela el flujo de pago en Stripe. |

Ejemplo JSON de Solicitud:
```json
{
  "planId": "2e548f3b-8d76-47b2-b13c-fa5d206f4002",
  "successUrl": "https://dashboard.atelier.andeva.pe/billing/success?session_id={CHECKOUT_SESSION_ID}",
  "cancelUrl": "https://dashboard.atelier.andeva.pe/billing/plans"
}
```

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.responses.CheckoutSessionResponse`

Tabla de Campos:
| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `checkoutUrl` | String | URL segura de redirección hacia la pasarela de Stripe Checkout. |
| `sessionId` | String | Identificador unívoco de la sesión en Stripe (prefijo `cs_test_` o `cs_live_`). |

Ejemplo JSON de Respuesta:
```json
{
  "checkoutUrl": "https://checkout.stripe.com/c/pay/cs_live_a1b2c3d4e5f6g7h8i9j0k1l2m3n4",
  "sessionId": "cs_live_a1b2c3d4e5f6g7h8i9j0k1l2m3n4"
}
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `400 Bad Request` | `https://api.atelier.andeva.pe/errors/validation-failed` | `MethodArgumentNotValidException` | Las URLs de retorno no son válidas o falta el planId. |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión ausente o revocado. |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/plan-not-found` | `PlanNotFoundException` | El plan especificado en la solicitud no existe o está inactivo. |
| `409 Conflict` | `https://api.atelier.andeva.pe/errors/duplicate-subscription` | `DuplicateActiveSubscriptionException` | El taller ya cuenta con una suscripción activa idéntica en curso. |
| `500 Internal Server Error` | `https://api.atelier.andeva.pe/errors/stripe-integration-error` | `StripeIntegrationException` | Falla de comunicación con los servidores de la API de Stripe. |

Ejemplo JSON ProblemDetail:
```json
{
  "type": "https://api.atelier.andeva.pe/errors/duplicate-subscription",
  "title": "Suscripcion Activa Existente",
  "status": 409,
  "detail": "El taller ya cuenta con una suscripcion activa para este plan. Utilice el endpoint de cambio de plan para modificarla.",
  "instance": "/api/v1/billing/subscriptions/checkout-session",
  "code": "DUPLICATE_ACTIVE_SUBSCRIPTION",
  "timestamp": "2026-10-01T15:35:00Z"
}
```

---

#### POST /api/v1/billing/subscriptions/customer-portal

##### Identidad Técnica
* **Controlador:** `TenantSubscriptionsController` (`com.andeva.atelier.platform.billing.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<CustomerPortalResponse> createCustomerPortalSession(@Valid @RequestBody CustomerPortalRequest request, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Genera una sesión segura en el **Stripe Customer Billing Portal**, permitiendo al propietario del taller actualizar tarjetas de crédito bancarias, revisar comprobantes fiscales y gestionar sus datos de cobro sin intermediación humana.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_TENANT_ADMIN` o `ROLE_WORKSHOP_OWNER`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('billing:subscriptions:manage_stripe')")`
* **Contexto Multi-Inquilino:** Resuelve el `stripe_customer_id` vinculado al `tenant_id` autenticado.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
  * `Content-Type: application/json` (Obligatorio)
* **Path Variables:** Ninguna.
* **Query Parameters:** Ninguno.

##### Request DTO
* **Record Java:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.requests.CustomerPortalRequest`

Tabla de Campos:
| Campo | Tipo Java | Validaciones Jakarta | Descripción |
| :--- | :--- | :--- | :--- |
| `returnUrl` | String | `@NotBlank` | URL a la cual Stripe redirigirá al cliente tras culminar sus gestiones en el portal. |

Ejemplo JSON de Solicitud:
```json
{
  "returnUrl": "https://dashboard.atelier.andeva.pe/settings/billing"
}
```

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.responses.CustomerPortalResponse`

Tabla de Campos:
| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `portalUrl` | String | URL de redirección segura con token temporal hacia el Stripe Billing Portal. |

Ejemplo JSON de Respuesta:
```json
{
  "portalUrl": "https://billing.stripe.com/p/session/live_YWNjdF8xT3VBdGVsaWVyMSxwb3J0YWxfU2Vzc2lvbl9BMTIyMzM0NA"
}
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `400 Bad Request` | `https://api.atelier.andeva.pe/errors/invalid-return-url` | `IllegalArgumentException` | La URL de retorno no pertenece a un dominio institucional autorizado. |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión ausente o vencido. |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/customer-not-found` | `SubscriptionNotFoundException` | El taller no cuenta con un identificador de cliente registrado en Stripe. |
| `500 Internal Server Error` | `https://api.atelier.andeva.pe/errors/stripe-integration-error` | `StripeIntegrationException` | Error devuelto por la pasarela Stripe al generar la sesión. |

---

#### POST /api/v1/billing/subscriptions/change-plan

##### Identidad Técnica
* **Controlador:** `TenantSubscriptionsController` (`com.andeva.atelier.platform.billing.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<TenantSubscriptionResource> changeSubscriptionPlan(@Valid @RequestBody ChangeSubscriptionPlanRequest request, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Modifica el plan contratado por el taller (`upgrade` hacia un plan superior o `downgrade` hacia un plan inferior). Aplica reglas de prorrateo inmediato en Stripe, recalcula las cuotas del taller e invalida de forma inmediata la memoria de Caffeine Cache para reflejar las nuevas cuotas en tiempo real.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_WORKSHOP_OWNER` o `ROLE_TENANT_ADMIN`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('billing:subscriptions:manage_stripe')")`
* **Contexto Multi-Inquilino:** Aislamiento estricto por `tenant_id` obtenido del token JWT.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
  * `Content-Type: application/json` (Obligatorio)
* **Path Variables:** Ninguna.
* **Query Parameters:** Ninguno.

##### Request DTO
* **Record Java:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.requests.ChangeSubscriptionPlanRequest`

Tabla de Campos:
| Campo | Tipo Java | Validaciones Jakarta | Descripción |
| :--- | :--- | :--- | :--- |
| `newPlanId` | UUID | `@NotNull` | Identificador universal del nuevo plan comercial destino. |
| `prorate` | Boolean | Opcional (Default `true`) | Indica si se debe prorratear financieramente el saldo a favor o pendiente en Stripe. |

Ejemplo JSON de Solicitud:
```json
{
  "newPlanId": "3e548f3b-8d76-47b2-b13c-fa5d206f4003",
  "prorate": true
}
```

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.responses.TenantSubscriptionResource`

Ejemplo JSON de Respuesta:
```json
{
  "id": "5a432109-8d76-47b2-b13c-fa5d206f4005",
  "tenantId": "a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d",
  "planId": "3e548f3b-8d76-47b2-b13c-fa5d206f4003",
  "planName": "Plan Max",
  "tier": "MAX",
  "status": "ACTIVE",
  "currentPeriodStart": "2026-10-01T15:36:00Z",
  "currentPeriodEnd": "2026-11-01T00:00:00Z",
  "cancelAtPeriodEnd": false,
  "trialEndDate": null,
  "quotaLimits": {
    "maxBranches": 5,
    "maxActiveStaff": 25,
    "maxActiveObd2Devices": 15,
    "maxPhotosPerWorkOrder": 150,
    "maxMonthlyAiReports": 60,
    "companyRegistrationAllowed": true,
    "multiWarehouseAllowed": true,
    "marketplaceListed": true,
    "maxMonthlyWorkOrders": 1000,
    "iotTelemetryEnabled": true,
    "aiDiagnosticsEnabled": true
  },
  "isAccessGranted": true
}
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `400 Bad Request` | `https://api.atelier.andeva.pe/errors/validation-failed` | `MethodArgumentNotValidException` | Identificador del nuevo plan nulo o malformado. |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión ausente o vencido. |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/plan-not-found` | `PlanNotFoundException` | El nuevo plan comercial solicitado no existe en la plataforma. |
| `409 Conflict` | `https://api.atelier.andeva.pe/errors/same-plan` | `IllegalStateException` | El taller ya tiene asignado el plan solicitado en la petición. |
| `422 Unprocessable Entity` | `https://api.atelier.andeva.pe/errors/downgrade-blocked` | `QuotaExceededException` | No se puede degradar a un plan inferior porque el taller supera las cuotas de dicho nivel (ej. tiene 7 mecánicos y el plan Go solo permite 5). |

Ejemplo JSON ProblemDetail:
```json
{
  "type": "https://api.atelier.andeva.pe/errors/downgrade-blocked",
  "title": "Degradacion de Plan Bloqueada",
  "status": 422,
  "detail": "No es posible cambiar al Plan Go. El taller tiene 7 mecanicos activos y el limite maximo permitido en Go es de 5.",
  "instance": "/api/v1/billing/subscriptions/change-plan",
  "code": "DOWNGRADE_USAGE_EXCEEDS_TARGET_LIMITS",
  "timestamp": "2026-10-01T15:36:30Z"
}
```

---

#### POST /api/v1/billing/subscriptions/cancel

##### Identidad Técnica
* **Controlador:** `TenantSubscriptionsController` (`com.andeva.atelier.platform.billing.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<TenantSubscriptionResource> cancelSubscription(@Valid @RequestBody CancelSubscriptionRequest request, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Registra la solicitud formal de baja de la suscripción SaaS del taller. Permite programar la cancelación al término del periodo facturado actual (`cancelAtPeriodEnd = true`) preservando el acceso hasta la fecha de corte, o rescindir la membresía de manera inmediata.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_WORKSHOP_OWNER` (Exclusivo para el titular propietario del taller).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('billing:subscriptions:manage_stripe') and hasRole('ROLE_WORKSHOP_OWNER')")`
* **Contexto Multi-Inquilino:** Aislamiento estricto por `tenant_id` desde el token JWT.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
  * `Content-Type: application/json` (Obligatorio)
* **Path Variables:** Ninguna.
* **Query Parameters:** Ninguno.

##### Request DTO
* **Record Java:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.requests.CancelSubscriptionRequest`

Tabla de Campos:
| Campo | Tipo Java | Validaciones Jakarta | Descripción |
| :--- | :--- | :--- | :--- |
| `cancelImmediately` | boolean | Obligatorio | Si es `true` cancela de inmediato, si es `false` programa la baja para el fin del periodo actual. |
| `cancellationReason` | String | Opcional | Motivo o justificación comercial de la baja informada por el usuario. |

Ejemplo JSON de Solicitud:
```json
{
  "cancelImmediately": false,
  "cancellationReason": "Cierre temporal de operaciones del taller automotriz."
}
```

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.responses.TenantSubscriptionResource`

Ejemplo JSON de Respuesta:
```json
{
  "id": "5a432109-8d76-47b2-b13c-fa5d206f4005",
  "tenantId": "a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d",
  "planId": "2e548f3b-8d76-47b2-b13c-fa5d206f4002",
  "planName": "Plan Pro",
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
    "maxPhotosPerWorkOrder": 100,
    "maxMonthlyAiReports": 0,
    "companyRegistrationAllowed": false,
    "multiWarehouseAllowed": false,
    "marketplaceListed": false,
    "maxMonthlyWorkOrders": 300,
    "iotTelemetryEnabled": true,
    "aiDiagnosticsEnabled": false
  },
  "isAccessGranted": true
}
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión ausente o revocado. |
| `403 Forbidden` | `https://api.atelier.andeva.pe/errors/forbidden` | `AccessDeniedException` | Solicitud efectuada por un usuario que no ostenta el rol de propietario del taller. |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/subscription-not-found` | `SubscriptionNotFoundException` | No existe una suscripción activa susceptible de cancelación. |
| `409 Conflict` | `https://api.atelier.andeva.pe/errors/already-canceled` | `IllegalStateException` | La suscripción ya se encuentra previamente cancelada o en baja definitiva. |

---

### 3.3. SaasInvoicesController

Controlador encargado de la consulta de facturas de servicio emitidas por Atelier Platform al taller y redirección a sus archivos PDF oficiales en Stripe.

#### GET /api/v1/billing/invoices

##### Identidad Técnica
* **Controlador:** `SaasInvoicesController` (`com.andeva.atelier.platform.billing.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<List<SaasInvoiceSummaryResource>> getTenantInvoices(@RequestParam(required = false) String status, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Lista cronológica de todos los comprobantes y facturas emitidas por concepto de suscripción de software hacia el taller autenticado.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_TENANT_ADMIN`, `ROLE_WORKSHOP_OWNER` o `ROLE_ACCOUNTANT`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('billing:invoices:read')")`
* **Contexto Multi-Inquilino:** Filtrado forzado en base de datos relacional mediante la cláusula `tenant_id = :authenticatedTenantId`.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
* **Path Variables:** Ninguna.
* **Query Parameters:**
  | Parámetro | Tipo | Requerido | Descripción |
  | :--- | :--- | :--- | :--- |
  | `status` | String | No | Filtro por estado de pago de factura (`PAID`, `OPEN`, `VOID`, `UNCOLLECTIBLE`). |

##### Request DTO
No aplica para peticiones HTTP GET.

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `List<com.andeva.atelier.platform.billing.interfaces.rest.resources.responses.SaasInvoiceSummaryResource>`

Tabla de Campos:
| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | UUID | Identificador interno de la factura SaaS en la base de datos de Atelier. |
| `stripeInvoiceId` | String | Identificador oficial de factura en Stripe (prefijo `in_`). |
| `amountPaid` | BigDecimal | Monto monetario debitado con éxito. |
| `currency` | String | Código ISO 4217 de la moneda de facturación. |
| `status` | String | Estado contable del comprobante (`PAID`, `OPEN`, `VOID`, `UNCOLLECTIBLE`). |
| `paidAt` | Instant | Fecha y hora en la que se confirmó el pago en la pasarela. |

Ejemplo JSON de Respuesta:
```json
[
  {
    "id": "7f123456-8d76-47b2-b13c-fa5d206f4007",
    "stripeInvoiceId": "in_1OuAtelierInvoice001",
    "amountPaid": 129.00,
    "currency": "USD",
    "status": "PAID",
    "paidAt": "2026-10-01T00:05:00Z"
  },
  {
    "id": "8f123456-8d76-47b2-b13c-fa5d206f4008",
    "stripeInvoiceId": "in_1OuAtelierInvoice002",
    "amountPaid": 129.00,
    "currency": "USD",
    "status": "PAID",
    "paidAt": "2026-09-01T00:05:00Z"
  }
]
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión no provisto o inválido. |
| `403 Forbidden` | `https://api.atelier.andeva.pe/errors/forbidden` | `AccessDeniedException` | Usuario carece de permisos de lectura de facturación del taller. |

---

#### GET /api/v1/billing/invoices/{id}

##### Identidad Técnica
* **Controlador:** `SaasInvoicesController` (`com.andeva.atelier.platform.billing.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<SaasInvoiceResource> getInvoiceById(@PathVariable UUID id, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Obtiene el detalle financiero exhaustivo de un comprobante de facturación de software emitido hacia el taller, incluyendo enlaces seguros a la factura alojada en Stripe y a su archivo PDF.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_TENANT_ADMIN`, `ROLE_WORKSHOP_OWNER` o `ROLE_ACCOUNTANT`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('billing:invoices:read')")`
* **Contexto Multi-Inquilino:** Verifica que el registro de factura pertenezca estrictamente al `tenant_id` autenticado, arrojando denegación en intentos de acceso cruzado.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
* **Path Variables:**
  | Variable | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `id` | UUID | Identificador interno de la factura SaaS en la base de datos de Atelier. |
* **Query Parameters:** Ninguno.

##### Request DTO
No aplica para peticiones HTTP GET.

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.responses.SaasInvoiceResource`

Tabla de Campos:
| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | UUID | Identificador interno único del registro de factura SaaS. |
| `subscriptionId` | UUID | Identificador de la suscripción asociada al cobro. |
| `tenantId` | UUID | Identificador del taller automotriz titular. |
| `stripeInvoiceId` | String | Identificador oficial del recibo en Stripe. |
| `amountPaid` | BigDecimal | Importe total debitado a la tarjeta o cuenta bancaria. |
| `currency` | String | Código de moneda bajo estándar ISO 4217. |
| `status` | String | Estado contable del comprobante (`PAID`, `OPEN`, `VOID`, `UNCOLLECTIBLE`). |
| `invoicePdfUrl` | String | Enlace oficial firmado provisto por Stripe para descargar el comprobante en PDF. |
| `hostedInvoiceUrl` | String | Enlace interactivo web de Stripe para consultar el recibo detallado. |
| `paidAt` | Instant | Momento en el que se confirmó la liquidación bancaria del pago. |
| `createdAt` | Instant | Marca temporal de registro de la factura en el sistema. |

Ejemplo JSON de Respuesta:
```json
{
  "id": "7f123456-8d76-47b2-b13c-fa5d206f4007",
  "subscriptionId": "5a432109-8d76-47b2-b13c-fa5d206f4005",
  "tenantId": "a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d",
  "stripeInvoiceId": "in_1OuAtelierInvoice001",
  "amountPaid": 129.00,
  "currency": "USD",
  "status": "PAID",
  "invoicePdfUrl": "https://pay.stripe.com/invoice/acct_1OuAtelier/invst_1OuAtelierInvoice001/pdf",
  "hostedInvoiceUrl": "https://invoice.stripe.com/i/acct_1OuAtelier/invst_1OuAtelierInvoice001",
  "paidAt": "2026-10-01T00:05:00Z",
  "createdAt": "2026-10-01T00:05:01Z"
}
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `400 Bad Request` | `https://api.atelier.andeva.pe/errors/invalid-identifier` | `IllegalArgumentException` | Formato UUID del parámetro de ruta inválido. |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión ausente o vencido. |
| `403 Forbidden` | `https://api.atelier.andeva.pe/errors/forbidden` | `AccessDeniedException` | Intento deliberado de acceder a facturas de un taller tercero. |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/invoice-not-found` | `SaasInvoiceNotFoundException` | La factura solicitada no existe en los registros contables. |

---

#### GET /api/v1/billing/invoices/{id}/pdf

##### Identidad Técnica
* **Controlador:** `SaasInvoicesController` (`com.andeva.atelier.platform.billing.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<Void> redirectToInvoicePdf(@PathVariable UUID id, @AuthenticationPrincipal Jwt jwt)`

##### Descripción Funcional
Redirige de manera directa al navegador o cliente móvil mediante código HTTP 302 hacia el enlace oficial y seguro firmado por Stripe para la descarga del comprobante en PDF.

##### Seguridad y Autorización
* **Rol Mínimo:** `ROLE_TENANT_ADMIN`, `ROLE_WORKSHOP_OWNER` o `ROLE_ACCOUNTANT`.
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('billing:invoices:read')")`
* **Contexto Multi-Inquilino:** Verifica la tenencia de la factura antes de efectuar la redirección.

##### Parámetros de Petición
* **Headers:**
  * `Authorization: Bearer <JWT>` (Obligatorio)
* **Path Variables:**
  | Variable | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `id` | UUID | Identificador de la factura SaaS. |
* **Query Parameters:** Ninguno.

##### Request DTO
No aplica para peticiones HTTP GET.

##### Response DTO
* **Estado HTTP:** `302 Found`
* **Headers:**
  * `Location: https://pay.stripe.com/invoice/acct_1OuAtelier/invst_1OuAtelierInvoice001/pdf`
* **Record Java:** No retorna cuerpo en la respuesta (`Void`).

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/unauthorized` | `AuthenticationException` | Token de sesión no provisto o inválido. |
| `403 Forbidden` | `https://api.atelier.andeva.pe/errors/forbidden` | `AccessDeniedException` | Permisos insuficientes para consultar el comprobante. |
| `404 Not Found` | `https://api.atelier.andeva.pe/errors/invoice-not-found` | `SaasInvoiceNotFoundException` | La factura solicitada no existe o no tiene un PDF generado en Stripe. |

---

### 3.4. StripeWebhooksController

Controlador perimetral de ingesta asíncrona de eventos de facturación despachados por la pasarela de pagos Stripe.

#### POST /api/v1/billing/webhooks/stripe

##### Identidad Técnica
* **Controlador:** `StripeWebhooksController` (`com.andeva.atelier.platform.billing.interfaces.rest.controllers`)
* **Método Java:** `public ResponseEntity<StripeWebhookAcknowledgmentResponse> handleStripeWebhook(@RequestHeader("Stripe-Signature") String sigHeader, @RequestBody String rawPayload)`

##### Descripción Funcional
Endpoint público asíncrono para recepción de eventos de Stripe. Valida la firma criptográfica HMAC-SHA256 con el secreto simétrico del webhook, persiste el registro en la tabla `stripe_events` con restricción UNIQUE para garantizar procesamiento exactamente una vez, y dispara la actualización del estado de suscripción y la invalidación reactiva de Caffeine Cache.

Eventos de Stripe procesados:
* `checkout.session.completed`: Vincula el cliente y activa la suscripción inicial del taller.
* `invoice.payment_succeeded`: Asienta la factura pagada y prolonga el periodo de cobertura.
* `invoice.payment_failed`: Conmuta la suscripción a mora (`PAST_DUE`) y envía notificación de contingencia.
* `customer.subscription.updated`: Actualiza los ítems y cuotas del plan ante cambios tarifarios.
* `customer.subscription.deleted`: Conmuta el estado de la membresía a cancelada (`CANCELED`).

##### Seguridad y Autorización
* **Rol Mínimo:** Sin autenticación JWT (Endpoint perimetral público para infraestructura distribuida de Stripe).
* **Firma Criptográfica:** Validación obligatoria de la cabecera `Stripe-Signature` calculada mediante HMAC-SHA256 contra la variable de entorno `STRIPE_WEBHOOK_SECRET`.
* **Contexto Multi-Inquilino:** El `tenant_id` es extraído de los metadatos (`metadata.tenant_id`) embebidos en el payload original del evento.

##### Parámetros de Petición
* **Headers:**
  * `Stripe-Signature: t=1614552225,v1=5257a869e7eee... (Obligatorio)`
  * `Content-Type: application/json` (Obligatorio)
* **Path Variables:** Ninguna.
* **Query Parameters:** Ninguno.

##### Request DTO
* **Tipo:** Payload JSON sin procesar (`String rawPayload`). No debe deserializarse previamente en objetos intermedios para evitar mutaciones que invaliden la comprobación de la firma criptográfica.

Ejemplo JSON de Notificación de Stripe:
```json
{
  "id": "evt_1OuAtelierPaymentSucc001",
  "object": "event",
  "api_version": "2024-06-20",
  "created": 1727800000,
  "data": {
    "object": {
      "id": "in_1OuAtelierInvoice001",
      "object": "invoice",
      "customer": "cus_OuAtelierCust001",
      "subscription": "sub_OuAtelierSub001",
      "amount_paid": 12900,
      "currency": "usd",
      "status": "paid",
      "invoice_pdf": "https://pay.stripe.com/invoice/acct_1OuAtelier/invst_1OuAtelierInvoice001/pdf",
      "hosted_invoice_url": "https://invoice.stripe.com/i/acct_1OuAtelier/invst_1OuAtelierInvoice001",
      "metadata": {
        "tenant_id": "a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d"
      }
    }
  },
  "type": "invoice.payment_succeeded"
}
```

##### Response DTO
* **Estado HTTP:** `200 OK`
* **Record Java:** `com.andeva.atelier.platform.billing.interfaces.rest.resources.responses.StripeWebhookAcknowledgmentResponse`

Tabla de Campos:
| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `received` | boolean | Confirmación booleana de recepción conforme del evento. |
| `eventId` | String | Identificador unívoco del evento procesado (prefijo `evt_`). |
| `status` | String | Estado del procesamiento idempotente (`PROCESSED`, `IGNORED`, `PENDING`). |

Ejemplo JSON de Respuesta:
```json
{
  "received": true,
  "eventId": "evt_1OuAtelierPaymentSucc001",
  "status": "PROCESSED"
}
```

##### Errores y RFC 7807
| Código HTTP | Error Type | Excepción de Dominio | Causa Común |
| :--- | :--- | :--- | :--- |
| `400 Bad Request` | `https://api.atelier.andeva.pe/errors/empty-payload` | `IllegalArgumentException` | Cuerpo de solicitud nulo o vacío. |
| `401 Unauthorized` | `https://api.atelier.andeva.pe/errors/invalid-signature` | `InvalidWebhookSignatureException` | La cabecera `Stripe-Signature` es inválida, expiró la tolerancia temporal de 300 segundos o no coincide con la firma HMAC. |
| `422 Unprocessable Entity` | `https://api.atelier.andeva.pe/errors/webhook-processing-failed` | `StripeWebhookProcessingException` | Fallo al parsear metadatos del evento o tipo de evento no soportado. |
| `500 Internal Server Error` | `https://api.atelier.andeva.pe/errors/internal-error` | `BillingInfrastructureException` | Error al registrar en tabla de idempotencia o falla de broker. |

Ejemplo JSON ProblemDetail:
```json
{
  "type": "https://api.atelier.andeva.pe/errors/invalid-signature",
  "title": "Firma de Webhook Invalida",
  "status": 401,
  "detail": "La firma provista en la cabecera Stripe-Signature no coincide con el secreto configurado.",
  "instance": "/api/v1/billing/webhooks/stripe",
  "code": "INVALID_WEBHOOK_SIGNATURE",
  "timestamp": "2026-10-01T15:37:00Z"
}
```
