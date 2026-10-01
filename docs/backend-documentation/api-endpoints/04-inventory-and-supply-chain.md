# Especificación Canónica de Endpoints REST: Inventory & Supply Chain Context

Este documento define la especificación técnica exhaustiva y canónica de los 22 endpoints REST correspondientes al Bounded Context **Inventory & Supply Chain Context** (`com.andeva.atelier.platform.inventory`) de la plataforma **Atelier Platform Backend**.

El contexto gobierna la administración del catálogo de repuestos e insumos automotrices, el directorio homologado de proveedores mayoristas, el aprovisionamiento de stock mediante órdenes de compra multi-producto, la trazabilidad física y contable bajo el algoritmo estricto FIFO (First-In, First-Out) por lotes de adquisición y la detección proactiva de umbrales críticos de reposición mediante alertas automatizadas.

---

## 1. Documentos de Referencia y Fuentes de Verdad

* [05-inventory-and-supply-chain.md](file:///home/shouy/development/atelier-report/docs/extended-description-bounded-contexts-backend/05-inventory-and-supply-chain.md): Especificación táctica extendida del Bounded Context Inventory & Supply Chain.
* [atelier-roles.md](file:///home/shouy/development/atelier-report/docs/backend-documentation/atelier-roles.md): Matriz RBAC, catálogo inmutable de permisos atómicos y asignaciones por rol.
* [atelier-database-schema.md](file:///home/shouy/development/atelier-report/docs/atelier-database-schema.md): Estructura relacional de tablas de inventario en PostgreSQL.
* [28-tactical-level-domain-driven-design-2.md](file:///home/shouy/development/atelier-report/report/chapters/20-requirements-development-and-software-solution-design/28-tactical-level-domain-driven-design-2.md): Diseño táctico y diagramas de arquitectura de software.

---

## 2. Convenciones Globales del API

* **Protocolo y Formato:** RESTful sobre HTTPS, payloads serializados en formato JSON (UTF-8).
* **Prefijo Canónico de Enrutamiento:** `/api/v1/inventory`
* **Aislamiento Multi-Inquilino (*Multi-Tenancy*):** Toda petición autenticada requiere el encabezado `Authorization: Bearer <token>`. El identificador de taller (`tenant_id`) se resuelve de forma inmutable desde los claims del token JWT (`claims.tenant_id`) y se valida opcionalmente contra la cabecera `X-Tenant-Id`. Las consultas y mutaciones quedan restringidas al espacio de datos del taller.
* **Representación de Errores:** Todos los errores de validación, dominio y seguridad siguen estrictamente la norma RFC 7807 (*Problem Details for HTTP APIs*).
* **Identificadores Técnicos:** Claves primarias universales en formato UUID v4.
* **Moneda:** Soles peruanos (`PEN`) por defecto.

---

## 3. Matriz General de Endpoints (22 Endpoints)

| N° | Método | Ruta Canónica | Controlador | Permiso Atómico | Rol Mínimo |
| :-: | :---: | :--- | :--- | :--- | :--- |
| 1 | `GET` | `/api/v1/inventory/parts` | `PartsCatalogController` | `inventory:parts:read` | `ROLE_MECHANIC` |
| 2 | `POST` | `/api/v1/inventory/parts` | `PartsCatalogController` | `inventory:parts:manage` | `ROLE_INVENTORY_MANAGER` |
| 3 | `GET` | `/api/v1/inventory/parts/{id}` | `PartsCatalogController` | `inventory:parts:read` | `ROLE_MECHANIC` |
| 4 | `PUT` | `/api/v1/inventory/parts/{id}` | `PartsCatalogController` | `inventory:parts:manage` | `ROLE_INVENTORY_MANAGER` |
| 5 | `GET` | `/api/v1/inventory/parts/by-sku/{sku}` | `PartsCatalogController` | `inventory:parts:read` | `ROLE_MECHANIC` |
| 6 | `GET` | `/api/v1/inventory/parts/by-category/{category}` | `PartsCatalogController` | `inventory:parts:read` | `ROLE_MECHANIC` |
| 7 | `GET` | `/api/v1/inventory/suppliers` | `SuppliersController` | `inventory:suppliers:read` | `ROLE_INVENTORY_MANAGER` |
| 8 | `POST` | `/api/v1/inventory/suppliers` | `SuppliersController` | `inventory:suppliers:manage` | `ROLE_INVENTORY_MANAGER` |
| 9 | `GET` | `/api/v1/inventory/suppliers/{id}` | `SuppliersController` | `inventory:suppliers:read` | `ROLE_INVENTORY_MANAGER` |
| 10 | `PUT` | `/api/v1/inventory/suppliers/{id}` | `SuppliersController` | `inventory:suppliers:manage` | `ROLE_INVENTORY_MANAGER` |
| 11 | `GET` | `/api/v1/inventory/purchase-orders` | `PurchaseOrdersController` | `inventory:purchase_orders:read` | `ROLE_INVENTORY_MANAGER` |
| 12 | `POST` | `/api/v1/inventory/purchase-orders` | `PurchaseOrdersController` | `inventory:purchase_orders:create` | `ROLE_INVENTORY_MANAGER` |
| 13 | `GET` | `/api/v1/inventory/purchase-orders/{id}` | `PurchaseOrdersController` | `inventory:purchase_orders:read` | `ROLE_INVENTORY_MANAGER` |
| 14 | `POST` | `/api/v1/inventory/purchase-orders/{id}/receive` | `PurchaseOrdersController` | `inventory:purchase_orders:receive` | `ROLE_INVENTORY_MANAGER` |
| 15 | `POST` | `/api/v1/inventory/purchase-orders/{id}/cancel` | `PurchaseOrdersController` | `inventory:purchase_orders:cancel` | `ROLE_INVENTORY_MANAGER` |
| 16 | `GET` | `/api/v1/inventory/batches/by-part/{partId}` | `BatchesController` | `inventory:batches:read` | `ROLE_CHIEF_MECHANIC` |
| 17 | `POST` | `/api/v1/inventory/batches/receive` | `BatchesController` | `inventory:batches:receive` | `ROLE_INVENTORY_MANAGER` |
| 18 | `POST` | `/api/v1/inventory/batches/dispatch` | `BatchesController` | `inventory:batches:dispatch_fifo` | `ROLE_MECHANIC` |
| 19 | `POST` | `/api/v1/inventory/batches/restore` | `BatchesController` | `inventory:batches:restore` | `ROLE_CHIEF_MECHANIC` |
| 20 | `GET` | `/api/v1/inventory/alerts` | `StockAlertsController` | `inventory:alerts:read` | `ROLE_CHIEF_MECHANIC` |
| 21 | `POST` | `/api/v1/inventory/alerts/{id}/resolve` | `StockAlertsController` | `inventory:alerts:resolve` | `ROLE_INVENTORY_MANAGER` |
| 22 | `POST` | `/api/v1/inventory/alerts/evaluate` | `StockAlertsController` | `inventory:alerts:evaluate` | `ROLE_INVENTORY_MANAGER` |

---

## 4. Catálogo Detallado de Endpoints REST


### 4.1. [GET] `/api/v1/inventory/parts`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.PartsCatalogController`
* **Método Java:** `public ResponseEntity<Page<PartSummaryResource>> getParts(Pageable pageable, @RequestParam(required = false) String search, @RequestParam(required = false) String category, @RequestParam(required = false) String status, @RequestParam(required = false) Boolean lowStockOnly)`
* **Ruta Canónica:** `GET /api/v1/inventory/parts`
* **Propósito Funcional:** Recupera el listado paginado y filtrado de repuestos e insumos automotrices del catálogo de almacén, proyectando saldos físicos consolidados, precios base y umbrales mínimos de reposición.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_MECHANIC`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('inventory:parts:read')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda al catálogo, lotes o proveedores de otra entidad.

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
| `search` | `String` | No | `null` | Término de búsqueda por denominación comercial o código SKU. |
| `category` | `String` | No | `null` | Familia de repuesto (Frenos, Filtros, Lubricantes, Suspensión, Motor, Eléctrico). |
| `status` | `String` | No | `null` | Estado operativo del repuesto (active, inactive, discontinued). |
| `lowStockOnly` | `Boolean` | No | `false` | Filtra exclusivamente aquellos ítems con saldo menor o igual al umbral mínimo. |
| `page` | `Integer` | No | `0` | Índice de página base cero. |
| `size` | `Integer` | No | `20` | Cantidad de elementos por bloque. |
| `sort` | `String` | No | `name,asc` | Criterio y orden de clasificación. |

#### Cuerpo de Petición (Request)

No requiere cuerpo de petición (petición sin contenido o parámetros en URL).

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `org.springframework.data.domain.Page<com.andeva.atelier.platform.inventory.interfaces.rest.resources.PartSummaryResource>`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `content[].id` | `UUID` | Identificador técnico del repuesto. |
| `content[].sku` | `String` | Código SKU de almacén unívoco en el taller. |
| `content[].name` | `String` | Denominación comercial del repuesto o fluido. |
| `content[].category` | `String` | Familia automotriz clasificada. |
| `content[].basePrice` | `BigDecimal` | Precio sugerido de venta al cliente. |
| `content[].totalStock` | `BigDecimal` | Saldo físico consolidado disponible en bodega. |
| `content[].minimumStock` | `BigDecimal` | Umbral de seguridad para reposición automática. |
| `content[].unitOfMeasure` | `String` | Unidad de medida (UNIDAD, LITRO, JUEGO). |
| `content[].status` | `String` | Estado del artículo en catálogo (active). |
| `content[].currency` | `String` | Moneda oficial (PEN). |
| `content[].createdAt` | `Instant` | Marca temporal de alta en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "content": [
    {
      "id": "6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d",
      "sku": "BRM-P83024",
      "name": "Juego de Pastillas Cerámicas Delanteras Brembo P83024",
      "category": "Frenos",
      "basePrice": 450.50,
      "totalStock": 12.00,
      "minimumStock": 4.00,
      "unitOfMeasure": "JUEGO",
      "status": "active",
      "currency": "PEN",
      "createdAt": "2026-02-10T09:00:00Z"
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
| 400 | `INVALID_QUERY_PARAMETER` | `IllegalArgumentException` | Parámetro de búsqueda o paginación no conforme. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/invalid-query-parameter",
  "title": "Parámetro Inválido",
  "status": 400,
  "detail": "El valor del parámetro de tamaño de página size debe ser estrictamente positivo.",
  "instance": "/api/v1/inventory/parts",
  "code": "INVALID_QUERY_PARAMETER",
  "timestamp": "2026-10-01T12:00:01Z"
}
```

---

### 4.2. [POST] `/api/v1/inventory/parts`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.PartsCatalogController`
* **Método Java:** `public ResponseEntity<PartResource> createPart(@Valid @RequestBody CreatePartResource resource, UriComponentsBuilder ucb)`
* **Ruta Canónica:** `POST /api/v1/inventory/parts`
* **Propósito Funcional:** Registra formalmente una nueva referencia técnica en el catálogo de repuestos del taller automotriz, estableciendo código SKU único, familia técnica, precio sugerido y umbral de seguridad.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_INVENTORY_MANAGER`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('inventory:parts:manage')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda al catálogo, lotes o proveedores de otra entidad.

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

* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.CreatePartResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `name` | `String` | Sí | @NotBlank, @Size(max = 150) | Nombre comercial del repuesto o fluido. |
| `sku` | `String` | Sí | @NotBlank, @Size(max = 50) | Código SKU único de almacén. |
| `category` | `String` | Sí | @NotBlank, @Size(max = 50) | Familia de pertenencia (ej. Frenos, Filtros). |
| `basePrice` | `BigDecimal` | Sí | @NotNull, @DecimalMin("0.00") | Precio de venta sugerido al cliente. |
| `minimumStock` | `BigDecimal` | Sí | @NotNull, @DecimalMin("0.00") | Nivel de stock mínimo para alertas de reposición. |
| `unitOfMeasure` | `String` | Sí | @NotBlank, @Size(max = 20) | Unidad de almacenamiento (UNIDAD, LITRO, JUEGO). |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "name": "Juego de Pastillas Cerámicas Delanteras Brembo P83024",
  "sku": "BRM-P83024",
  "category": "Frenos",
  "basePrice": 450.50,
  "minimumStock": 4.00,
  "unitOfMeasure": "JUEGO"
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `201 Created`
* **Cabecera de Ubicación (*Location Header*):** `/api/v1/inventory/parts/6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d`
* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.PartResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador técnico universal del repuesto. |
| `tenantId` | `UUID` | Identificador del taller titular. |
| `name` | `String` | Denominación comercial registrada. |
| `sku` | `String` | Código SKU validado. |
| `category` | `String` | Familia automotriz asignada. |
| `basePrice` | `BigDecimal` | Precio base de venta. |
| `totalStock` | `BigDecimal` | Saldo inicial consolidado (0.00). |
| `minimumStock` | `BigDecimal` | Umbral crítico de reposición. |
| `unitOfMeasure` | `String` | Unidad de almacenamiento física. |
| `status` | `String` | Estado operativo inicial (active). |
| `createdAt` | `Instant` | Marca temporal de alta en UTC. |
| `updatedAt` | `Instant` | Marca temporal de modificación en UTC. |
| `version` | `Long` | Versión optimista de concurrencia. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Juego de Pastillas Cerámicas Delanteras Brembo P83024",
  "sku": "BRM-P83024",
  "category": "Frenos",
  "basePrice": 450.50,
  "totalStock": 0.00,
  "minimumStock": 4.00,
  "unitOfMeasure": "JUEGO",
  "status": "active",
  "createdAt": "2026-10-01T12:05:00Z",
  "updatedAt": "2026-10-01T12:05:00Z",
  "version": 0
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 400 | `INVALID_PART_DATA` | `IllegalArgumentException` | Precio base o umbral de stock negativo. |
| 409 | `ERR_DUPLICATE_SKU` | `DuplicateSkuException` | Ya existe una referencia en el taller con el código SKU indicado. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/duplicate-sku",
  "title": "Código SKU Duplicado",
  "status": 409,
  "detail": "El código SKU 'BRM-P83024' ya se encuentra registrado para otro repuesto en este taller.",
  "instance": "/api/v1/inventory/parts",
  "code": "ERR_DUPLICATE_SKU",
  "timestamp": "2026-10-01T12:05:01Z"
}
```

---

### 4.3. [GET] `/api/v1/inventory/parts/{id}`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.PartsCatalogController`
* **Método Java:** `public ResponseEntity<PartResource> getPartById(@PathVariable UUID id)`
* **Ruta Canónica:** `GET /api/v1/inventory/parts/{id}`
* **Propósito Funcional:** Obtiene la información exhaustiva de un repuesto específico del catálogo, con el detalle de existencias consolidadas y parámetros de reaprovisionamiento.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_MECHANIC`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('inventory:parts:read')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda al catálogo, lotes o proveedores de otra entidad.

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
| `id` | `UUID` | Sí | Identificador único global del repuesto. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

No requiere cuerpo de petición (petición sin contenido o parámetros en URL).

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.PartResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador técnico del repuesto. |
| `tenantId` | `UUID` | Identificador del taller titular. |
| `name` | `String` | Denominación comercial. |
| `sku` | `String` | Código SKU de almacén. |
| `category` | `String` | Familia automotriz. |
| `basePrice` | `BigDecimal` | Precio sugerido de venta. |
| `totalStock` | `BigDecimal` | Saldo físico consolidado. |
| `minimumStock` | `BigDecimal` | Umbral de seguridad. |
| `unitOfMeasure` | `String` | Unidad de medida. |
| `status` | `String` | Estado operativo (active). |
| `createdAt` | `Instant` | Marca temporal de creación. |
| `updatedAt` | `Instant` | Marca temporal de modificación. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Juego de Pastillas Cerámicas Delanteras Brembo P83024",
  "sku": "BRM-P83024",
  "category": "Frenos",
  "basePrice": 450.50,
  "totalStock": 12.00,
  "minimumStock": 4.00,
  "unitOfMeasure": "JUEGO",
  "status": "active",
  "createdAt": "2026-02-10T09:00:00Z",
  "updatedAt": "2026-10-01T11:00:00Z",
  "version": 4
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `ERR_ITEM_NOT_FOUND` | `InventoryItemNotFoundException` | No existe el repuesto con el identificador provisto en el taller. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/item-not-found",
  "title": "Repuesto No Encontrado",
  "status": 404,
  "detail": "No se localiza el repuesto con ID 6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d.",
  "instance": "/api/v1/inventory/parts/6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d",
  "code": "ERR_ITEM_NOT_FOUND",
  "timestamp": "2026-10-01T12:10:00Z"
}
```

---

### 4.4. [PUT] `/api/v1/inventory/parts/{id}`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.PartsCatalogController`
* **Método Java:** `public ResponseEntity<PartResource> updatePart(@PathVariable UUID id, @Valid @RequestBody UpdatePartResource resource)`
* **Ruta Canónica:** `PUT /api/v1/inventory/parts/{id}`
* **Propósito Funcional:** Actualiza las especificaciones maestras del artículo, modificando el precio sugerido de venta al público, denominación comercial o umbral crítico de reposición.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_INVENTORY_MANAGER`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('inventory:parts:manage')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda al catálogo, lotes o proveedores de otra entidad.

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
| `id` | `UUID` | Sí | Identificador único del repuesto a modificar. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.UpdatePartResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `name` | `String` | No | @Size(max = 150) | Denominación comercial corregida. |
| `category` | `String` | No | @Size(max = 50) | Familia automotriz actualizada. |
| `basePrice` | `BigDecimal` | No | @DecimalMin("0.00") | Nuevo precio de lista al público. |
| `minimumStock` | `BigDecimal` | No | @DecimalMin("0.00") | Nuevo umbral de reposición. |
| `status` | `String` | No | Enum(active, inactive, discontinued) | Estado operativo del repuesto. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "basePrice": 475.00,
  "minimumStock": 6.00,
  "status": "active"
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.PartResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador técnico del repuesto. |
| `basePrice` | `BigDecimal` | Precio de lista actualizado (475.00 PEN). |
| `minimumStock` | `BigDecimal` | Umbral de reposición actualizado (6.00). |
| `updatedAt` | `Instant` | Marca temporal de la modificación en UTC. |
| `version` | `Long` | Versión optimista incrementada. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Juego de Pastillas Cerámicas Delanteras Brembo P83024",
  "sku": "BRM-P83024",
  "category": "Frenos",
  "basePrice": 475.00,
  "totalStock": 12.00,
  "minimumStock": 6.00,
  "unitOfMeasure": "JUEGO",
  "status": "active",
  "createdAt": "2026-02-10T09:00:00Z",
  "updatedAt": "2026-10-01T12:15:00Z",
  "version": 5
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `ERR_ITEM_NOT_FOUND` | `InventoryItemNotFoundException` | No existe el repuesto especificado. |
| 409 | `OPTIMISTIC_LOCKING_FAILURE` | `OptimisticLockingFailureException` | Conflicto de concurrencia al actualizar el artículo simultáneamente. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/optimistic-locking-failure",
  "title": "Conflicto de Concurrencia",
  "status": 409,
  "detail": "El artículo fue modificado concurrentemente por otra sesión.",
  "instance": "/api/v1/inventory/parts/6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d",
  "code": "OPTIMISTIC_LOCKING_FAILURE",
  "timestamp": "2026-10-01T12:15:01Z"
}
```

---

### 4.5. [GET] `/api/v1/inventory/parts/by-sku/{sku}`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.PartsCatalogController`
* **Método Java:** `public ResponseEntity<PartResource> getPartBySku(@PathVariable String sku)`
* **Ruta Canónica:** `GET /api/v1/inventory/parts/by-sku/{sku}`
* **Propósito Funcional:** Búsqueda indexada instantánea de repuesto mediante código SKU de almacén o código de barras del fabricante para identificación en mostrador o terminal móvil de foso.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_MECHANIC`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('inventory:parts:read')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda al catálogo, lotes o proveedores de otra entidad.

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
| `sku` | `String` | Sí | Código SKU de almacén exacto. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

No requiere cuerpo de petición (petición sin contenido o parámetros en URL).

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.PartResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del repuesto localizado. |
| `sku` | `String` | Código SKU coincidente. |
| `name` | `String` | Nombre comercial. |
| `totalStock` | `BigDecimal` | Saldo físico disponible en almacén. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Juego de Pastillas Cerámicas Delanteras Brembo P83024",
  "sku": "BRM-P83024",
  "category": "Frenos",
  "basePrice": 475.00,
  "totalStock": 12.00,
  "minimumStock": 6.00,
  "unitOfMeasure": "JUEGO",
  "status": "active",
  "createdAt": "2026-02-10T09:00:00Z",
  "updatedAt": "2026-10-01T12:15:00Z",
  "version": 5
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `ERR_ITEM_NOT_FOUND` | `InventoryItemNotFoundException` | No existe ningún repuesto registrado con el código SKU provisto. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/item-not-found",
  "title": "SKU No Encontrado",
  "status": 404,
  "detail": "No se localiza ningún artículo con código SKU 'BRM-INEXISTENTE'.",
  "instance": "/api/v1/inventory/parts/by-sku/BRM-INEXISTENTE",
  "code": "ERR_ITEM_NOT_FOUND",
  "timestamp": "2026-10-01T12:20:00Z"
}
```

---

### 4.6. [GET] `/api/v1/inventory/parts/by-category/{category}`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.PartsCatalogController`
* **Método Java:** `public ResponseEntity<List<PartSummaryResource>> getPartsByCategory(@PathVariable String category)`
* **Ruta Canónica:** `GET /api/v1/inventory/parts/by-category/{category}`
* **Propósito Funcional:** Recupera el conjunto de repuestos e insumos agrupados bajo una misma familia técnica automotriz para navegación por árbol de categorías en la aplicación de almacén.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_MECHANIC`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('inventory:parts:read')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda al catálogo, lotes o proveedores de otra entidad.

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
| `category` | `String` | Sí | Nombre de la categoría automotriz (ej. Frenos). |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

No requiere cuerpo de petición (petición sin contenido o parámetros en URL).

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `java.util.List<com.andeva.atelier.platform.inventory.interfaces.rest.resources.PartSummaryResource>`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `[].id` | `UUID` | Identificador del repuesto. |
| `[].sku` | `String` | Código SKU. |
| `[].name` | `String` | Nombre comercial. |
| `[].category` | `String` | Categoría consultada. |
| `[].basePrice` | `BigDecimal` | Precio sugerido de venta. |
| `[].totalStock` | `BigDecimal` | Saldo físico disponible. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
[
  {
    "id": "6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d",
    "sku": "BRM-P83024",
    "name": "Juego de Pastillas Cerámicas Delanteras Brembo P83024",
    "category": "Frenos",
    "basePrice": 475.00,
    "totalStock": 12.00,
    "minimumStock": 6.00,
    "unitOfMeasure": "JUEGO",
    "status": "active",
    "currency": "PEN",
    "createdAt": "2026-02-10T09:00:00Z"
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 400 | `INVALID_QUERY_PARAMETER` | `IllegalArgumentException` | Categoría vacía o con formato inválido. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/invalid-query-parameter",
  "title": "Categoría Inválida",
  "status": 400,
  "detail": "El parámetro category no puede estar vacío.",
  "instance": "/api/v1/inventory/parts/by-category/",
  "code": "INVALID_QUERY_PARAMETER",
  "timestamp": "2026-10-01T12:25:00Z"
}
```

---

### 4.7. [GET] `/api/v1/inventory/suppliers`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.SuppliersController`
* **Método Java:** `public ResponseEntity<List<SupplierResource>> getSuppliers(@RequestParam(required = false) String search, @RequestParam(required = false, defaultValue = "true") Boolean activeOnly)`
* **Ruta Canónica:** `GET /api/v1/inventory/suppliers`
* **Propósito Funcional:** Recupera el directorio comercial homologado de distribuidores mayoristas de repuestos y suministros del taller automotriz.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_INVENTORY_MANAGER`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('inventory:suppliers:read')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda al catálogo, lotes o proveedores de otra entidad.

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
| `search` | `String` | No | `null` | Búsqueda por RUC, razón social o nombre comercial del proveedor. |
| `activeOnly` | `Boolean` | No | `true` | Filtra proveedores activos comercialmente. |

#### Cuerpo de Petición (Request)

No requiere cuerpo de petición (petición sin contenido o parámetros en URL).

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `java.util.List<com.andeva.atelier.platform.inventory.interfaces.rest.resources.SupplierResource>`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `[].id` | `UUID` | Identificador único del proveedor. |
| `[].tenantId` | `UUID` | Identificador del taller titular. |
| `[].taxId` | `String` | Registro Único de Contribuyente (RUC 11 dígitos). |
| `[].companyName` | `String` | Razón social inscrita ante SUNAT. |
| `[].tradeName` | `String` | Nombre comercial del distribuidor. |
| `[].contactName` | `String` | Nombre del ejecutivo de ventas asignado. |
| `[].email` | `String` | Correo electrónico para pedidos y cotizaciones. |
| `[].phone` | `String` | Teléfono de contacto comercial. |
| `[].address` | `String` | Dirección fiscal o almacén de despacho. |
| `[].status` | `String` | Estado operativo (active). |
| `[].createdAt` | `Instant` | Marca temporal de alta en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
[
  {
    "id": "8a9b0c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d",
    "tenantId": "550e8400-e29b-41d4-a716-446655440000",
    "taxId": "20601234567",
    "companyName": "DISTRIBUIDORA AUTOMOTRIZ DEL PERU S.A.C.",
    "tradeName": "DISAUTOP PERU",
    "contactName": "Ing. Fernando Valdivia Paredes",
    "email": "ventas@disautop.com.pe",
    "phone": "+5114859000",
    "address": "Av. Nicolás Arriola 1540, La Victoria, Lima",
    "status": "active",
    "createdAt": "2026-01-20T10:00:00Z"
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 400 | `INVALID_QUERY_PARAMETER` | `IllegalArgumentException` | Término de búsqueda inválido. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/invalid-query-parameter",
  "title": "Búsqueda Inválida",
  "status": 400,
  "detail": "Parámetro search mal estructurado.",
  "instance": "/api/v1/inventory/suppliers",
  "code": "INVALID_QUERY_PARAMETER",
  "timestamp": "2026-10-01T12:30:00Z"
}
```

---

### 4.8. [POST] `/api/v1/inventory/suppliers`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.SuppliersController`
* **Método Java:** `public ResponseEntity<SupplierResource> createSupplier(@Valid @RequestBody CreateSupplierResource resource, UriComponentsBuilder ucb)`
* **Ruta Canónica:** `POST /api/v1/inventory/suppliers`
* **Propósito Funcional:** Registra un nuevo distribuidor de repuestos en el directorio comercial homologado del taller, validando unicidad de RUC ante SUNAT y configurando canales de contacto.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_INVENTORY_MANAGER`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('inventory:suppliers:manage')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda al catálogo, lotes o proveedores de otra entidad.

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

* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.CreateSupplierResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `taxId` | `String` | Sí | @NotBlank, @Pattern(regexp = "\d{11}") | Número de RUC de 11 dígitos numéricos. |
| `companyName` | `String` | Sí | @NotBlank, @Size(max = 150) | Razón social formal del proveedor. |
| `tradeName` | `String` | No | @Size(max = 150) | Nombre comercial de marca. |
| `contactName` | `String` | Sí | @NotBlank, @Size(max = 100) | Nombre del asesor comercial asignado. |
| `email` | `String` | Sí | @NotBlank, @Email | Buzón electrónico corporativo. |
| `phone` | `String` | Sí | @NotBlank, @Size(max = 20) | Teléfono de pedidos y emergencias. |
| `address` | `String` | No | @Size(max = 255) | Dirección fiscal o de almacén de retiro. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "taxId": "20601234567",
  "companyName": "DISTRIBUIDORA AUTOMOTRIZ DEL PERU S.A.C.",
  "tradeName": "DISAUTOP PERU",
  "contactName": "Ing. Fernando Valdivia Paredes",
  "email": "ventas@disautop.com.pe",
  "phone": "+5114859000",
  "address": "Av. Nicolás Arriola 1540, La Victoria, Lima"
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `201 Created`
* **Cabecera de Ubicación (*Location Header*):** `/api/v1/inventory/suppliers/8a9b0c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d`
* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.SupplierResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador técnico del proveedor. |
| `taxId` | `String` | RUC verificado. |
| `companyName` | `String` | Razón social registrada. |
| `status` | `String` | Estado operativo inicial (active). |
| `createdAt` | `Instant` | Marca temporal de alta en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "8a9b0c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "taxId": "20601234567",
  "companyName": "DISTRIBUIDORA AUTOMOTRIZ DEL PERU S.A.C.",
  "tradeName": "DISAUTOP PERU",
  "contactName": "Ing. Fernando Valdivia Paredes",
  "email": "ventas@disautop.com.pe",
  "phone": "+5114859000",
  "address": "Av. Nicolás Arriola 1540, La Victoria, Lima",
  "status": "active",
  "createdAt": "2026-10-01T12:35:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 400 | `INVALID_TAX_ID` | `IllegalArgumentException` | RUC no cumple con el algoritmo de verificación Módulo 11 de SUNAT. |
| 409 | `ERR_DUPLICATE_SUPPLIER_RUC` | `DuplicateSupplierTaxIdException` | Ya existe un proveedor activo con ese número de RUC en el taller. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/duplicate-supplier-ruc",
  "title": "RUC de Proveedor Duplicado",
  "status": 409,
  "detail": "El RUC '20601234567' ya se encuentra registrado para otro proveedor en este taller.",
  "instance": "/api/v1/inventory/suppliers",
  "code": "ERR_DUPLICATE_SUPPLIER_RUC",
  "timestamp": "2026-10-01T12:35:01Z"
}
```

---

### 4.9. [GET] `/api/v1/inventory/suppliers/{id}`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.SuppliersController`
* **Método Java:** `public ResponseEntity<SupplierResource> getSupplierById(@PathVariable UUID id)`
* **Ruta Canónica:** `GET /api/v1/inventory/suppliers/{id}`
* **Propósito Funcional:** Obtiene el detalle comercial y crediticio de un proveedor homologado en el sistema del taller.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_INVENTORY_MANAGER`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('inventory:suppliers:read')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda al catálogo, lotes o proveedores de otra entidad.

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
| `id` | `UUID` | Sí | Identificador único del proveedor. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

No requiere cuerpo de petición (petición sin contenido o parámetros en URL).

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.SupplierResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del proveedor. |
| `taxId` | `String` | RUC del proveedor. |
| `companyName` | `String` | Razón social. |
| `tradeName` | `String` | Nombre comercial. |
| `contactName` | `String` | Contacto comercial. |
| `email` | `String` | Correo electrónico. |
| `phone` | `String` | Teléfono de contacto. |
| `address` | `String` | Dirección fiscal. |
| `status` | `String` | Estado operativo (active). |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "8a9b0c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "taxId": "20601234567",
  "companyName": "DISTRIBUIDORA AUTOMOTRIZ DEL PERU S.A.C.",
  "tradeName": "DISAUTOP PERU",
  "contactName": "Ing. Fernando Valdivia Paredes",
  "email": "ventas@disautop.com.pe",
  "phone": "+5114859000",
  "address": "Av. Nicolás Arriola 1540, La Victoria, Lima",
  "status": "active",
  "createdAt": "2026-01-20T10:00:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `ERR_SUPPLIER_NOT_FOUND` | `SupplierNotFoundException` | No existe el proveedor con el identificador provisto. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/supplier-not-found",
  "title": "Proveedor No Encontrado",
  "status": 404,
  "detail": "No se localiza el proveedor 8a9b0c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d.",
  "instance": "/api/v1/inventory/suppliers/8a9b0c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d",
  "code": "ERR_SUPPLIER_NOT_FOUND",
  "timestamp": "2026-10-01T12:40:00Z"
}
```

---

### 4.10. [PUT] `/api/v1/inventory/suppliers/{id}`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.SuppliersController`
* **Método Java:** `public ResponseEntity<SupplierResource> updateSupplier(@PathVariable UUID id, @Valid @RequestBody UpdateSupplierResource resource)`
* **Ruta Canónica:** `PUT /api/v1/inventory/suppliers/{id}`
* **Propósito Funcional:** Actualiza los datos de contacto, ejecutivo de ventas asignado, dirección física o estado operativo de un proveedor homologado.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_INVENTORY_MANAGER`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('inventory:suppliers:manage')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda al catálogo, lotes o proveedores de otra entidad.

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
| `id` | `UUID` | Sí | Identificador del proveedor a modificar. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.UpdateSupplierResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `tradeName` | `String` | No | @Size(max = 150) | Nombre comercial actualizado. |
| `contactName` | `String` | No | @Size(max = 100) | Nombre del nuevo ejecutivo de ventas. |
| `email` | `String` | No | @Email | Nuevo correo de contacto. |
| `phone` | `String` | No | @Size(max = 20) | Nuevo teléfono corporativo. |
| `address` | `String` | No | @Size(max = 255) | Dirección actualizada. |
| `status` | `String` | No | Enum(active, inactive) | Estado operativo del proveedor. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "contactName": "Lic. Patricia Morales Ríos",
  "email": "pmorales@disautop.com.pe",
  "phone": "+5114859005"
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.SupplierResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del proveedor. |
| `contactName` | `String` | Contacto comercial actualizado. |
| `email` | `String` | Correo actualizado. |
| `phone` | `String` | Teléfono actualizado. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "8a9b0c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "taxId": "20601234567",
  "companyName": "DISTRIBUIDORA AUTOMOTRIZ DEL PERU S.A.C.",
  "tradeName": "DISAUTOP PERU",
  "contactName": "Lic. Patricia Morales Ríos",
  "email": "pmorales@disautop.com.pe",
  "phone": "+5114859005",
  "address": "Av. Nicolás Arriola 1540, La Victoria, Lima",
  "status": "active",
  "createdAt": "2026-01-20T10:00:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `ERR_SUPPLIER_NOT_FOUND` | `SupplierNotFoundException` | No existe el proveedor especificado. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/supplier-not-found",
  "title": "Proveedor No Encontrado",
  "status": 404,
  "detail": "No se encontró el proveedor con ID 8a9b0c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d.",
  "instance": "/api/v1/inventory/suppliers/8a9b0c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d",
  "code": "ERR_SUPPLIER_NOT_FOUND",
  "timestamp": "2026-10-01T12:45:00Z"
}
```

---

### 4.11. [GET] `/api/v1/inventory/purchase-orders`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.PurchaseOrdersController`
* **Método Java:** `public ResponseEntity<Page<PurchaseOrderSummaryResource>> getPurchaseOrders(Pageable pageable, @RequestParam(required = false) UUID supplierId, @RequestParam(required = false) String status)`
* **Ruta Canónica:** `GET /api/v1/inventory/purchase-orders`
* **Propósito Funcional:** Recupera el listado paginado y filtrado de órdenes de compra emitidas a proveedores mayoristas, supervisando compromisos de abastecimiento y recepciones pendientes.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_INVENTORY_MANAGER`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('inventory:purchase_orders:read')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda al catálogo, lotes o proveedores de otra entidad.

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
| `supplierId` | `UUID` | No | `null` | Filtro por proveedor adjudicatario. |
| `status` | `String` | No | `null` | Estado de la orden de compra (DRAFT, ISSUED, RECEIVED, CANCELLED). |
| `page` | `Integer` | No | `0` | Índice de página base cero. |
| `size` | `Integer` | No | `20` | Elementos por página. |
| `sort` | `String` | No | `createdAt,desc` | Criterio de ordenamiento. |

#### Cuerpo de Petición (Request)

No requiere cuerpo de petición (petición sin contenido o parámetros en URL).

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `org.springframework.data.domain.Page<com.andeva.atelier.platform.inventory.interfaces.rest.resources.PurchaseOrderSummaryResource>`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `content[].id` | `UUID` | Identificador único de la orden de compra. |
| `content[].orderNumber` | `String` | Código correlativo institucional (ej. OC-2026-00085). |
| `content[].supplierId` | `UUID` | Identificador del proveedor. |
| `content[].supplierName` | `String` | Razón social del proveedor. |
| `content[].status` | `String` | Estado actual de la orden de compra. |
| `content[].totalItemsCount` | `Integer` | Cantidad de líneas de repuestos incluidas. |
| `content[].subtotalAmount` | `BigDecimal` | Monto neto antes de impuestos. |
| `content[].taxAmount` | `BigDecimal` | IGV facturado (18%). |
| `content[].totalAmount` | `BigDecimal` | Importe total bruto de la compra. |
| `content[].currency` | `String` | Moneda oficial (PEN). |
| `content[].issuedAt` | `Instant` | Marca temporal de emisión en UTC. |
| `content[].receivedAt` | `Instant` | Marca temporal de recepción física en almacén. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "content": [
    {
      "id": "e5f6a7b8-c9d0-1e2f-3a4b-5c6d7e8f9a0b",
      "orderNumber": "OC-2026-00085",
      "supplierId": "8a9b0c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d",
      "supplierName": "DISTRIBUIDORA AUTOMOTRIZ DEL PERU S.A.C.",
      "status": "RECEIVED",
      "totalItemsCount": 1,
      "subtotalAmount": 3000.00,
      "taxAmount": 540.00,
      "totalAmount": 3540.00,
      "currency": "PEN",
      "issuedAt": "2026-09-20T10:00:00Z",
      "receivedAt": "2026-09-25T14:30:00Z"
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
| 400 | `INVALID_QUERY_PARAMETER` | `IllegalArgumentException` | Estado de orden de compra no reconocido. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/invalid-query-parameter",
  "title": "Parámetro Inválido",
  "status": 400,
  "detail": "El valor del estado no corresponde a la máquina de estados de órdenes de compra.",
  "instance": "/api/v1/inventory/purchase-orders",
  "code": "INVALID_QUERY_PARAMETER",
  "timestamp": "2026-10-01T12:50:00Z"
}
```

---

### 4.12. [POST] `/api/v1/inventory/purchase-orders`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.PurchaseOrdersController`
* **Método Java:** `public ResponseEntity<PurchaseOrderResource> createPurchaseOrder(@Valid @RequestBody CreatePurchaseOrderResource resource, UriComponentsBuilder ucb)`
* **Ruta Canónica:** `POST /api/v1/inventory/purchase-orders`
* **Propósito Funcional:** Crea y formaliza una nueva orden de compra para abastecimiento de repuestos e insumos, estableciendo líneas de productos, cantidades y precios acordados con el proveedor.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_INVENTORY_MANAGER`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('inventory:purchase_orders:create')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda al catálogo, lotes o proveedores de otra entidad.

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

* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.CreatePurchaseOrderResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `supplierId` | `UUID` | Sí | @NotNull | Identificador del proveedor adjudicado. |
| `notes` | `String` | No | @Size(max = 1000) | Observaciones de entrega o condiciones de crédito comercial. |
| `expectedDeliveryDate` | `LocalDate` | No | Opcional | Fecha estimada de arribo a bodega. |
| `items` | `List<CreatePurchaseOrderItemResource>` | Sí | @NotEmpty | Colección de repuestos demandados con cantidades y costos unitarios. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "supplierId": "8a9b0c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d",
  "notes": "Entrega en almacén central. Crédito a 30 días según acuerdo marco.",
  "expectedDeliveryDate": "2026-10-10",
  "items": [
    {
      "inventoryItemId": "6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d",
      "quantity": 10.00,
      "unitCost": 300.00
    }
  ]
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `201 Created`
* **Cabecera de Ubicación (*Location Header*):** `/api/v1/inventory/purchase-orders/e5f6a7b8-c9d0-1e2f-3a4b-5c6d7e8f9a0b`
* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.PurchaseOrderResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador técnico de la orden de compra. |
| `orderNumber` | `String` | Código correlativo generado. |
| `tenantId` | `UUID` | Identificador del taller titular. |
| `supplierId` | `UUID` | Identificador del proveedor. |
| `supplierName` | `String` | Razón social del proveedor. |
| `status` | `String` | Estado inicial emitido (ISSUED). |
| `subtotalAmount` | `BigDecimal` | Subtotal de la compra (3000.00 PEN). |
| `taxAmount` | `BigDecimal` | IGV liquidado (540.00 PEN). |
| `totalAmount` | `BigDecimal` | Monto total de la compra (3540.00 PEN). |
| `currency` | `String` | Moneda oficial (PEN). |
| `items` | `List<PurchaseOrderItemResource>` | Partidas detalladas incorporadas. |
| `createdAt` | `Instant` | Marca temporal de emisión en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "e5f6a7b8-c9d0-1e2f-3a4b-5c6d7e8f9a0b",
  "orderNumber": "OC-2026-00085",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "supplierId": "8a9b0c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d",
  "supplierName": "DISTRIBUIDORA AUTOMOTRIZ DEL PERU S.A.C.",
  "status": "ISSUED",
  "notes": "Entrega en almacén central. Crédito a 30 días según acuerdo marco.",
  "expectedDeliveryDate": "2026-10-10",
  "subtotalAmount": 3000.00,
  "taxAmount": 540.00,
  "totalAmount": 3540.00,
  "currency": "PEN",
  "items": [
    {
      "id": "9a0b1c2d-3e4f-5a6b-7c8d-9e0f1a2b3c4d",
      "inventoryItemId": "6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d",
      "partName": "Juego de Pastillas Cerámicas Delanteras Brembo P83024",
      "partSku": "BRM-P83024",
      "quantity": 10.00,
      "unitCost": 300.00,
      "subtotal": 3000.00
    }
  ],
  "createdAt": "2026-10-01T12:55:00Z",
  "updatedAt": "2026-10-01T12:55:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 400 | `ERR_EMPTY_PURCHASE_ORDER` | `PurchaseOrderEmptyException` | Se intenta emitir una orden de compra sin líneas de repuestos. |
| 404 | `ERR_SUPPLIER_NOT_FOUND` | `SupplierNotFoundException` | No existe el proveedor referenciado. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/empty-purchase-order",
  "title": "Orden de Compra Vacía",
  "status": 400,
  "detail": "La orden de compra debe contener al menos un repuesto para ser formalizada.",
  "instance": "/api/v1/inventory/purchase-orders",
  "code": "ERR_EMPTY_PURCHASE_ORDER",
  "timestamp": "2026-10-01T12:55:01Z"
}
```

---

### 4.13. [GET] `/api/v1/inventory/purchase-orders/{id}`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.PurchaseOrdersController`
* **Método Java:** `public ResponseEntity<PurchaseOrderResource> getPurchaseOrderById(@PathVariable UUID id)`
* **Ruta Canónica:** `GET /api/v1/inventory/purchase-orders/{id}`
* **Propósito Funcional:** Consulta el detalle exhaustivo de una orden de compra, incluyendo los repuestos demandados, costos pactados, comprobante de factura adjunto y estado de recepción física.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_INVENTORY_MANAGER`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('inventory:purchase_orders:read')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda al catálogo, lotes o proveedores de otra entidad.

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
| `id` | `UUID` | Sí | Identificador único de la orden de compra. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

No requiere cuerpo de petición (petición sin contenido o parámetros en URL).

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.PurchaseOrderResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador técnico de la orden. |
| `orderNumber` | `String` | Código correlativo de la compra. |
| `status` | `String` | Estado operativo actual. |
| `totalAmount` | `BigDecimal` | Monto total de la compra. |
| `items` | `List<PurchaseOrderItemResource>` | Líneas de detalle de repuestos adquiridos. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "e5f6a7b8-c9d0-1e2f-3a4b-5c6d7e8f9a0b",
  "orderNumber": "OC-2026-00085",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "supplierId": "8a9b0c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d",
  "supplierName": "DISTRIBUIDORA AUTOMOTRIZ DEL PERU S.A.C.",
  "status": "ISSUED",
  "notes": "Entrega en almacén central. Crédito a 30 días según acuerdo marco.",
  "expectedDeliveryDate": "2026-10-10",
  "subtotalAmount": 3000.00,
  "taxAmount": 540.00,
  "totalAmount": 3540.00,
  "currency": "PEN",
  "items": [
    {
      "id": "9a0b1c2d-3e4f-5a6b-7c8d-9e0f1a2b3c4d",
      "inventoryItemId": "6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d",
      "partName": "Juego de Pastillas Cerámicas Delanteras Brembo P83024",
      "partSku": "BRM-P83024",
      "quantity": 10.00,
      "unitCost": 300.00,
      "subtotal": 3000.00
    }
  ],
  "createdAt": "2026-10-01T12:55:00Z",
  "updatedAt": "2026-10-01T12:55:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `ERR_PO_NOT_FOUND` | `PurchaseOrderNotFoundException` | No existe la orden de compra solicitada. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/purchase-order-not-found",
  "title": "Orden de Compra No Encontrada",
  "status": 404,
  "detail": "No se localiza la orden de compra e5f6a7b8-c9d0-1e2f-3a4b-5c6d7e8f9a0b.",
  "instance": "/api/v1/inventory/purchase-orders/e5f6a7b8-c9d0-1e2f-3a4b-5c6d7e8f9a0b",
  "code": "ERR_PO_NOT_FOUND",
  "timestamp": "2026-10-01T13:00:00Z"
}
```

---

### 4.14. [POST] `/api/v1/inventory/purchase-orders/{id}/receive`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.PurchaseOrdersController`
* **Método Java:** `public ResponseEntity<PurchaseOrderResource> receivePurchaseOrder(@PathVariable UUID id, @Valid @RequestBody ReceivePurchaseOrderResource resource)`
* **Ruta Canónica:** `POST /api/v1/inventory/purchase-orders/{id}/receive`
* **Propósito Funcional:** Otorga conformidad física a la recepción de mercadería contra orden de compra, verificando comprobante del proveedor (factura) y dando de alta automática a los lotes FIFO correspondientes.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_INVENTORY_MANAGER`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('inventory:purchase_orders:receive')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda al catálogo, lotes o proveedores de otra entidad.

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
| `id` | `UUID` | Sí | Identificador único de la orden de compra a recibir. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.ReceivePurchaseOrderResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `invoiceNumber` | `String` | Sí | @NotBlank, @Size(max = 50) | Serie y número de la factura comercial o guía de remisión del proveedor. |
| `invoicePhotoUrl` | `String` | Sí | @NotBlank, @URL | Localizador HTTPS del comprobante escaneado en Cloud Storage. |
| `receptionNotes` | `String` | No | @Size(max = 1000) | Observaciones de la inspección visual física de ingreso. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "invoiceNumber": "F001-00045892",
  "invoicePhotoUrl": "https://storage.googleapis.com/atelier-evidence/tenants/550e8400/invoices/F001-00045892.pdf",
  "receptionNotes": "Mercadería recibida en empaques originales sellados de fábrica sin daños aparentes."
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.PurchaseOrderResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la orden de compra. |
| `status` | `String` | Nuevo estado (RECEIVED). |
| `invoiceNumber` | `String` | Comprobante de compra registrado. |
| `receivedAt` | `Instant` | Marca temporal de ingreso físico en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "e5f6a7b8-c9d0-1e2f-3a4b-5c6d7e8f9a0b",
  "orderNumber": "OC-2026-00085",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "supplierId": "8a9b0c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d",
  "supplierName": "DISTRIBUIDORA AUTOMOTRIZ DEL PERU S.A.C.",
  "status": "RECEIVED",
  "invoiceNumber": "F001-00045892",
  "invoicePhotoUrl": "https://storage.googleapis.com/atelier-evidence/tenants/550e8400/invoices/F001-00045892.pdf",
  "subtotalAmount": 3000.00,
  "taxAmount": 540.00,
  "totalAmount": 3540.00,
  "currency": "PEN",
  "receivedAt": "2026-10-01T13:05:00Z",
  "updatedAt": "2026-10-01T13:05:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 400 | `ERR_INVALID_PO_TRANSITION` | `InvalidPurchaseOrderTransitionException` | La orden no se encuentra en estado emitido (ISSUED). |
| 404 | `ERR_PO_NOT_FOUND` | `PurchaseOrderNotFoundException` | No existe la orden especificada. |
| 422 | `ERR_MISSING_RECEIPT_DOC` | `MissingReceiptDocumentationException` | Falta adjuntar el número o imagen del comprobante de factura probatorio. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/missing-receipt-doc",
  "title": "Comprobante Faltante",
  "status": 422,
  "detail": "Es obligatorio adjuntar la factura del proveedor para validar la recepción.",
  "instance": "/api/v1/inventory/purchase-orders/e5f6a7b8-c9d0-1e2f-3a4b-5c6d7e8f9a0b/receive",
  "code": "ERR_MISSING_RECEIPT_DOC",
  "timestamp": "2026-10-01T13:05:01Z"
}
```

---

### 4.15. [POST] `/api/v1/inventory/purchase-orders/{id}/cancel`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.PurchaseOrdersController`
* **Método Java:** `public ResponseEntity<PurchaseOrderResource> cancelPurchaseOrder(@PathVariable UUID id, @Valid @RequestBody CancelPurchaseOrderResource resource)`
* **Ruta Canónica:** `POST /api/v1/inventory/purchase-orders/{id}/cancel`
* **Propósito Funcional:** Ejecuta la cancelación justificada de una orden de compra antes de su recepción física en almacén.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_INVENTORY_MANAGER`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('inventory:purchase_orders:cancel')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda al catálogo, lotes o proveedores de otra entidad.

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
| `id` | `UUID` | Sí | Identificador de la orden de compra a anular. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.CancelPurchaseOrderResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `cancellationReason` | `String` | Sí | @NotBlank, @Size(min = 5, max = 500) | Motivo justificado de la anulación del pedido. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "cancellationReason": "Proveedor notificó quiebre de stock en fábrica y demora superior a 45 días hábiles."
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.PurchaseOrderResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la orden. |
| `status` | `String` | Nuevo estado (CANCELLED). |
| `updatedAt` | `Instant` | Marca temporal de anulación en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "e5f6a7b8-c9d0-1e2f-3a4b-5c6d7e8f9a0b",
  "orderNumber": "OC-2026-00085",
  "tenantId": "550e8400-e29b-41d4-a716-446655440000",
  "status": "CANCELLED",
  "updatedAt": "2026-10-01T13:10:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 400 | `ERR_INVALID_PO_TRANSITION` | `InvalidPurchaseOrderTransitionException` | No se puede anular una orden que ya fue recibida en almacén. |
| 404 | `ERR_PO_NOT_FOUND` | `PurchaseOrderNotFoundException` | No existe la orden especificada. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/invalid-po-transition",
  "title": "Transición Inválida",
  "status": 400,
  "detail": "No se puede anular una orden de compra en estado RECEIVED.",
  "instance": "/api/v1/inventory/purchase-orders/e5f6a7b8-c9d0-1e2f-3a4b-5c6d7e8f9a0b/cancel",
  "code": "ERR_INVALID_PO_TRANSITION",
  "timestamp": "2026-10-01T13:10:01Z"
}
```

---

### 4.16. [GET] `/api/v1/inventory/batches/by-part/{partId}`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.BatchesController`
* **Método Java:** `public ResponseEntity<List<BatchResource>> getBatchesByPartId(@PathVariable UUID partId)`
* **Ruta Canónica:** `GET /api/v1/inventory/batches/by-part/{partId}`
* **Propósito Funcional:** Recupera la trazabilidad cronológica y saldos remanentes de todos los lotes de adquisición asociados a una referencia de repuesto para inspección contable FIFO.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_CHIEF_MECHANIC`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('inventory:batches:read')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda al catálogo, lotes o proveedores de otra entidad.

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
| `partId` | `UUID` | Sí | Identificador único del repuesto. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

No requiere cuerpo de petición (petición sin contenido o parámetros en URL).

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `java.util.List<com.andeva.atelier.platform.inventory.interfaces.rest.resources.BatchResource>`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `[].id` | `UUID` | Identificador técnico del lote de adquisición. |
| `[].inventoryItemId` | `UUID` | Identificador del repuesto. |
| `[].batchNumber` | `String` | Código correlativo de lote de almacén (ej. LOT-2026-0812). |
| `[].supplierId` | `UUID` | Identificador del proveedor mayorista. |
| `[].supplierName` | `String` | Razón social del proveedor. |
| `[].initialQuantity` | `BigDecimal` | Cantidad física ingresada inicialmente. |
| `[].currentStock` | `BigDecimal` | Saldo físico remanente en este lote. |
| `[].purchasePrice` | `BigDecimal` | Costo de adquisición unitario sin impuestos. |
| `[].invoiceNumber` | `String` | Comprobante de factura de compra. |
| `[].entryDate` | `LocalDate` | Fecha formal de ingreso a bodega. |
| `[].status` | `String` | Estado del lote (ACTIVE, DEPLETED, EXPIRED). |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
[
  {
    "id": "7c8d9e0f-1a2b-3c4d-5e6f-7a8b9c0d1e2f",
    "inventoryItemId": "6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d",
    "batchNumber": "LOT-2026-0812",
    "supplierId": "8a9b0c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d",
    "supplierName": "DISTRIBUIDORA AUTOMOTRIZ DEL PERU S.A.C.",
    "initialQuantity": 10.00,
    "currentStock": 7.00,
    "purchasePrice": 300.00,
    "invoiceNumber": "F001-00045892",
    "invoicePhotoUrl": "https://storage.googleapis.com/atelier-evidence/tenants/550e8400/invoices/F001-00045892.pdf",
    "entryDate": "2026-09-25",
    "status": "ACTIVE"
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `ERR_ITEM_NOT_FOUND` | `InventoryItemNotFoundException` | No existe el repuesto referenciado en el catálogo. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/item-not-found",
  "title": "Repuesto No Encontrado",
  "status": 404,
  "detail": "No se localiza el repuesto con ID 6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d.",
  "instance": "/api/v1/inventory/batches/by-part/6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d",
  "code": "ERR_ITEM_NOT_FOUND",
  "timestamp": "2026-10-01T13:15:00Z"
}
```

---

### 4.17. [POST] `/api/v1/inventory/batches/receive`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.BatchesController`
* **Método Java:** `public ResponseEntity<BatchResource> receiveBatch(@Valid @RequestBody ReceiveBatchResource resource, UriComponentsBuilder ucb)`
* **Ruta Canónica:** `POST /api/v1/inventory/batches/receive`
* **Propósito Funcional:** Registra el ingreso manual directo de un lote físico de repuestos al almacén con su costo de adquisición unitario y comprobante probatorio.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_INVENTORY_MANAGER`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('inventory:batches:receive')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda al catálogo, lotes o proveedores de otra entidad.

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

* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.ReceiveBatchResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `inventoryItemId` | `UUID` | Sí | @NotNull | Identificador del repuesto de catálogo. |
| `supplierId` | `UUID` | Sí | @NotNull | Identificador del proveedor. |
| `quantity` | `BigDecimal` | Sí | @NotNull, @DecimalMin("1.00") | Cantidad de unidades físicas adquiridas. |
| `purchasePrice` | `BigDecimal` | Sí | @NotNull, @DecimalMin("0.01") | Costo unitario de adquisición. |
| `invoiceNumber` | `String` | Sí | @NotBlank, @Size(max = 50) | Número de factura del proveedor. |
| `invoicePhotoUrl` | `String` | Sí | @NotBlank, @URL | Localizador HTTPS de la factura probatoria. |
| `manufacturingDate` | `LocalDate` | No | Opcional | Fecha de fabricación del lote si aplica. |
| `expirationDate` | `LocalDate` | No | Opcional | Fecha de caducidad si aplica (ej. fluidos). |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "inventoryItemId": "6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d",
  "supplierId": "8a9b0c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d",
  "quantity": 10.00,
  "purchasePrice": 300.00,
  "invoiceNumber": "F001-00045892",
  "invoicePhotoUrl": "https://storage.googleapis.com/atelier-evidence/tenants/550e8400/invoices/F001-00045892.pdf",
  "manufacturingDate": "2026-05-10",
  "expirationDate": null
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `201 Created`
* **Cabecera de Ubicación (*Location Header*):** `/api/v1/inventory/batches/7c8d9e0f-1a2b-3c4d-5e6f-7a8b9c0d1e2f`
* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.BatchResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador técnico del lote creado. |
| `batchNumber` | `String` | Código correlativo unívoco de lote. |
| `initialQuantity` | `BigDecimal` | Cantidad inicial registrada. |
| `currentStock` | `BigDecimal` | Saldo remanente disponible. |
| `purchasePrice` | `BigDecimal` | Costo de compra unitario. |
| `status` | `String` | Estado operativo (ACTIVE). |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "7c8d9e0f-1a2b-3c4d-5e6f-7a8b9c0d1e2f",
  "inventoryItemId": "6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d",
  "batchNumber": "LOT-2026-0812",
  "supplierId": "8a9b0c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d",
  "supplierName": "DISTRIBUIDORA AUTOMOTRIZ DEL PERU S.A.C.",
  "initialQuantity": 10.00,
  "currentStock": 10.00,
  "purchasePrice": 300.00,
  "invoiceNumber": "F001-00045892",
  "invoicePhotoUrl": "https://storage.googleapis.com/atelier-evidence/tenants/550e8400/invoices/F001-00045892.pdf",
  "entryDate": "2026-10-01",
  "status": "ACTIVE"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 400 | `ERR_INVALID_BATCH_QUANTITY` | `InvalidBatchQuantityException` | Cantidad de lote o costo menor o igual a cero. |
| 404 | `ERR_ITEM_NOT_FOUND` | `InventoryItemNotFoundException` | No existe el repuesto indicado. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/invalid-batch-quantity",
  "title": "Cantidad de Lote Inválida",
  "status": 400,
  "detail": "La cantidad ingresada debe ser estrictamente positiva.",
  "instance": "/api/v1/inventory/batches/receive",
  "code": "ERR_INVALID_BATCH_QUANTITY",
  "timestamp": "2026-10-01T13:20:00Z"
}
```

---

### 4.18. [POST] `/api/v1/inventory/batches/dispatch`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.BatchesController`
* **Método Java:** `public ResponseEntity<StockDischargeResource> dispatchFifo(@Valid @RequestBody DispatchFifoResource resource)`
* **Ruta Canónica:** `POST /api/v1/inventory/batches/dispatch`
* **Propósito Funcional:** Ejecuta el descargo contable automatizado bajo el algoritmo estricto FIFO (First-In, First-Out), deduciendo unidades de los lotes más antiguos y valorizando el costo exacto de la salida imputada a una orden de trabajo.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_MECHANIC`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('inventory:batches:dispatch_fifo')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda al catálogo, lotes o proveedores de otra entidad.

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

* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.DispatchFifoResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `inventoryItemId` | `UUID` | Sí | @NotNull | Identificador del repuesto demandado. |
| `workOrderId` | `UUID` | Sí | @NotNull | Identificador de la orden de trabajo receptora. |
| `taskId` | `UUID` | Sí | @NotNull | Identificador de la labor mecánica específica. |
| `quantity` | `BigDecimal` | Sí | @NotNull, @DecimalMin("0.01") | Cantidad de unidades demandadas para consumo. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "inventoryItemId": "6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d",
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "taskId": "f1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c",
  "quantity": 1.00
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.StockDischargeResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `dischargeId` | `UUID` | Identificador técnico de la transacción de descargo. |
| `inventoryItemId` | `UUID` | Identificador del repuesto descargado. |
| `workOrderId` | `UUID` | Identificador de la orden imputada. |
| `taskId` | `UUID` | Identificador de la tarea mecánica. |
| `totalQuantityDispatched` | `BigDecimal` | Cantidad total efectivamente descargada. |
| `totalCostAmount` | `BigDecimal` | Costo total valorizado a precio de compra FIFO. |
| `currency` | `String` | Moneda oficial (PEN). |
| `dischargedAt` | `Instant` | Marca temporal del descargo en UTC. |
| `allocations[].batchId` | `UUID` | Identificador del lote específico deducido. |
| `allocations[].quantityDeducted` | `BigDecimal` | Cantidad tomada de este lote. |
| `allocations[].unitCost` | `BigDecimal` | Costo unitario de este lote. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "dischargeId": "3b4c5d6e-7f8a-9b0c-1d2e-3f4a5b6c7d8e",
  "inventoryItemId": "6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d",
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "taskId": "f1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c",
  "totalQuantityDispatched": 1.00,
  "totalCostAmount": 300.00,
  "currency": "PEN",
  "dischargedAt": "2026-10-01T13:25:00Z",
  "allocations": [
    {
      "batchId": "7c8d9e0f-1a2b-3c4d-5e6f-7a8b9c0d1e2f",
      "quantityDeducted": 1.00,
      "unitCost": 300.00
    }
  ]
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 400 | `ERR_INVALID_BATCH_QUANTITY` | `InvalidBatchQuantityException` | Cantidad solicitada menor o igual a cero. |
| 404 | `ERR_ITEM_NOT_FOUND` | `InventoryItemNotFoundException` | No existe el repuesto en catálogo. |
| 409 | `ERR_INSUFFICIENT_STOCK` | `InsufficientStockException` | La cantidad solicitada supera el saldo total disponible en lotes activos. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/insufficient-stock",
  "title": "Stock Insuficiente",
  "status": 409,
  "detail": "El saldo disponible para el repuesto (0.00) es insuficiente para atender el descargo de 1.00 unidades.",
  "instance": "/api/v1/inventory/batches/dispatch",
  "code": "ERR_INSUFFICIENT_STOCK",
  "timestamp": "2026-10-01T13:25:01Z"
}
```

---

### 4.19. [POST] `/api/v1/inventory/batches/restore`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.BatchesController`
* **Método Java:** `public ResponseEntity<BatchResource> restoreBatch(@Valid @RequestBody RestoreBatchResource resource)`
* **Ruta Canónica:** `POST /api/v1/inventory/batches/restore`
* **Propósito Funcional:** Reincorpora repuestos previamente descargados al almacén cuando una tarea mecánica ha sido cancelada o un repuesto no fue utilizado, restaurando existencias en el lote originario.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_CHIEF_MECHANIC`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('inventory:batches:restore')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda al catálogo, lotes o proveedores de otra entidad.

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

* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.RestoreBatchResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `batchId` | `UUID` | Sí | @NotNull | Identificador del lote receptor de la devolución. |
| `workOrderId` | `UUID` | Sí | @NotNull | Identificador de la orden de trabajo de origen. |
| `quantity` | `BigDecimal` | Sí | @NotNull, @DecimalMin("0.01") | Cantidad de piezas devueltas intactas. |
| `restorationReason` | `String` | Sí | @NotBlank, @Size(max = 500) | Motivo justificado de la reincorporación al almacén. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "batchId": "7c8d9e0f-1a2b-3c4d-5e6f-7a8b9c0d1e2f",
  "workOrderId": "7b8e5c12-3f84-4a21-9d10-8b45f1e29001",
  "quantity": 1.00,
  "restorationReason": "Repuesto solicitado por error de diagnóstico. Pieza se encuentra en empaque original sellado."
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.BatchResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del lote. |
| `currentStock` | `BigDecimal` | Saldo remanente incrementado tras la restitución. |
| `status` | `String` | Estado operativo del lote (ACTIVE). |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "7c8d9e0f-1a2b-3c4d-5e6f-7a8b9c0d1e2f",
  "inventoryItemId": "6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d",
  "batchNumber": "LOT-2026-0812",
  "currentStock": 8.00,
  "status": "ACTIVE",
  "updatedAt": "2026-10-01T13:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 400 | `ERR_INVALID_BATCH_QUANTITY` | `InvalidBatchQuantityException` | Cantidad a restaurar inválida o excede la capacidad original. |
| 404 | `BATCH_NOT_FOUND` | `EntityNotFoundException` | No existe el lote de almacenamiento indicado. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/batch-not-found",
  "title": "Lote No Encontrado",
  "status": 404,
  "detail": "No se localiza el lote con ID 7c8d9e0f-1a2b-3c4d-5e6f-7a8b9c0d1e2f.",
  "instance": "/api/v1/inventory/batches/restore",
  "code": "BATCH_NOT_FOUND",
  "timestamp": "2026-10-01T13:30:01Z"
}
```

---

### 4.20. [GET] `/api/v1/inventory/alerts`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.StockAlertsController`
* **Método Java:** `public ResponseEntity<List<StockAlertResource>> getAlerts(@RequestParam(required = false, defaultValue = "false") Boolean resolved)`
* **Ruta Canónica:** `GET /api/v1/inventory/alerts`
* **Propósito Funcional:** Recupera la lista de alertas activas de inventario generadas automáticamente por repuestos cuyo stock disponible se encuentra por debajo del umbral mínimo de seguridad.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_CHIEF_MECHANIC`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('inventory:alerts:read')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda al catálogo, lotes o proveedores de otra entidad.

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
| `resolved` | `Boolean` | No | `false` | Filtra alertas ya atendidas o resueltas. |

#### Cuerpo de Petición (Request)

No requiere cuerpo de petición (petición sin contenido o parámetros en URL).

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `java.util.List<com.andeva.atelier.platform.inventory.interfaces.rest.resources.StockAlertResource>`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `[].id` | `UUID` | Identificador técnico de la alerta. |
| `[].tenantId` | `UUID` | Identificador del taller titular. |
| `[].inventoryItemId` | `UUID` | Identificador del repuesto en quiebre. |
| `[].partSku` | `String` | Código SKU del repuesto. |
| `[].partName` | `String` | Denominación comercial. |
| `[].currentStock` | `BigDecimal` | Saldo físico remanente al dispararse la alerta. |
| `[].minimumStock` | `BigDecimal` | Umbral mínimo configurado. |
| `[].deficitQuantity` | `BigDecimal` | Déficit cuantitativo respecto al umbral. |
| `[].alertSeverity` | `String` | Nivel de gravedad (WARNING, CRITICAL, OUT_OF_STOCK). |
| `[].isResolved` | `Boolean` | Indicador de atención de la alerta. |
| `[].createdAt` | `Instant` | Marca temporal del disparo de la alerta en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
[
  {
    "id": "1d2e3f4a-5b6c-7d8e-9f0a-1b2c3d4e5f6a",
    "tenantId": "550e8400-e29b-41d4-a716-446655440000",
    "inventoryItemId": "6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d",
    "partSku": "BRM-P83024",
    "partName": "Juego de Pastillas Cerámicas Delanteras Brembo P83024",
    "currentStock": 2.00,
    "minimumStock": 6.00,
    "deficitQuantity": 4.00,
    "alertSeverity": "CRITICAL",
    "isResolved": false,
    "resolvedAt": null,
    "createdAt": "2026-10-01T11:00:00Z"
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 400 | `INVALID_QUERY_PARAMETER` | `IllegalArgumentException` | Parámetro resolved inválido. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/invalid-query-parameter",
  "title": "Parámetro Inválido",
  "status": 400,
  "detail": "El valor del parámetro resolved debe ser booleano.",
  "instance": "/api/v1/inventory/alerts",
  "code": "INVALID_QUERY_PARAMETER",
  "timestamp": "2026-10-01T11:00:01Z"
}
```

---

### 4.21. [POST] `/api/v1/inventory/alerts/{id}/resolve`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.StockAlertsController`
* **Método Java:** `public ResponseEntity<StockAlertResource> resolveAlert(@PathVariable UUID id, @Valid @RequestBody ResolveAlertResource resource)`
* **Ruta Canónica:** `POST /api/v1/inventory/alerts/{id}/resolve`
* **Propósito Funcional:** Registra la resolución formal de una alerta de inventario tras emitirse una orden de reposición de mercadería o regularizarse físicamente el inventario.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_INVENTORY_MANAGER`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('inventory:alerts:resolve')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda al catálogo, lotes o proveedores de otra entidad.

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
| `id` | `UUID` | Sí | Identificador de la alerta de inventario a resolver. |

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.ResolveAlertResource`

| Campo | Tipo | Requerido | Validaciones de Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `purchaseOrderId` | `UUID` | No | Opcional | Identificador de la orden de compra emitida para resolver el quiebre. |
| `resolutionNotes` | `String` | Sí | @NotBlank, @Size(max = 500) | Explicación de la acción correctiva aplicada. |

**Ejemplo de Payload JSON (Petición):**

```json
{
  "purchaseOrderId": "e5f6a7b8-c9d0-1e2f-3a4b-5c6d7e8f9a0b",
  "resolutionNotes": "Se emitió orden de compra OC-2026-00085 por 10 juegos de pastillas al distribuidor DISAUTOP."
}
```

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.StockAlertResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la alerta. |
| `isResolved` | `Boolean` | Indicador de resolución (true). |
| `resolvedAt` | `Instant` | Marca temporal de resolución en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "id": "1d2e3f4a-5b6c-7d8e-9f0a-1b2c3d4e5f6a",
  "inventoryItemId": "6f2a3b4c-5d6e-7a8b-9c0d-1e2f3a4b5c6d",
  "partSku": "BRM-P83024",
  "partName": "Juego de Pastillas Cerámicas Delanteras Brembo P83024",
  "isResolved": true,
  "resolvedAt": "2026-10-01T13:35:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 404 | `ALERT_NOT_FOUND` | `EntityNotFoundException` | No existe la alerta especificada. |
| 422 | `ALERT_ALREADY_RESOLVED` | `IllegalStateException` | La alerta ya fue resuelta con anterioridad. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/alert-already-resolved",
  "title": "Alerta Ya Resuelta",
  "status": 422,
  "detail": "La alerta 1d2e3f4a-5b6c-7d8e-9f0a-1b2c3d4e5f6a ya se encuentra marcada como resuelta.",
  "instance": "/api/v1/inventory/alerts/1d2e3f4a-5b6c-7d8e-9f0a-1b2c3d4e5f6a/resolve",
  "code": "ALERT_ALREADY_RESOLVED",
  "timestamp": "2026-10-01T13:35:01Z"
}
```

---

### 4.22. [POST] `/api/v1/inventory/alerts/evaluate`

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.StockAlertsController`
* **Método Java:** `public ResponseEntity<MessageResource> evaluateThresholds()`
* **Ruta Canónica:** `POST /api/v1/inventory/alerts/evaluate`
* **Propósito Funcional:** Ejecuta de forma inmediata el motor de evaluación de umbrales críticos de stock (StockReorderEvaluationService), auditando todas las referencias de inventario para generar alertas tempranas de reposición.

#### Seguridad y Autorización
* **Rol Mínimo Requerido:** `ROLE_INVENTORY_MANAGER`
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('inventory:alerts:evaluate')")`
* **Contexto Multi-Inquilino:** Aislamiento multi-inquilino estricto. La petición debe incluir el token JWT en el encabezado Authorization. El filtro perimetral resuelve el tenant_id del token y lo inyecta en el contexto de seguridad. Todas las operaciones en la base de datos se filtran por tenant_id garantizando que ningún taller acceda al catálogo, lotes o proveedores de otra entidad.

#### Parámetros de Petición

**Encabezados HTTP (Headers):**

| Encabezado | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `Authorization` | `String` | Sí | Token de portador JWT Bearer con claims de usuario y permisos atómicos. |
| `Accept` | `String` | No | application/json por defecto. |
| `X-Tenant-Id` | `UUID` | No | Identificador opcional del taller para verificación cruzada de inquilino. |

**Parámetros de Ruta (Path Parameters):** No aplica.

**Parámetros de Consulta (Query Parameters):** No aplica.

#### Cuerpo de Petición (Request)

No requiere cuerpo de petición (petición sin contenido o parámetros en URL).

#### Cuerpo de Respuesta (Response)

* **Estatus HTTP de Éxito:** `200 OK`
* **Java Record DTO:** `com.andeva.atelier.platform.shared.interfaces.rest.resources.MessageResource`

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `message` | `String` | Resultado del proceso de evaluación masiva. |
| `evaluatedItemsCount` | `Integer` | Cantidad total de ítems de catálogo analizados. |
| `alertsTriggeredCount` | `Integer` | Cantidad de alertas nuevas generadas. |
| `evaluatedAt` | `Instant` | Marca temporal del barrido en UTC. |

**Ejemplo de Payload JSON (Respuesta Exitosa):**

```json
{
  "message": "Evaluación de umbrales de stock completada exitosamente.",
  "evaluatedItemsCount": 1420,
  "alertsTriggeredCount": 3,
  "evaluatedAt": "2026-10-01T13:40:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)

| Código HTTP | Código RFC 7807 | Excepción de Dominio | Condición de Activación |
| :---: | :--- | :--- | :--- |
| 500 | `INTERNAL_SERVER_ERROR` | `RuntimeException` | Error inesperado durante la auditoría masiva de existencias. |

**Ejemplo de Respuesta de Error (ProblemDetail RFC 7807):**

```json
{
  "type": "https://api.atelier.andeva.pe/errors/internal-server-error",
  "title": "Error Interno",
  "status": 500,
  "detail": "Falla al conectar con el motor de base de datos durante el barrido de inventario.",
  "instance": "/api/v1/inventory/alerts/evaluate",
  "code": "INTERNAL_SERVER_ERROR",
  "timestamp": "2026-10-01T13:40:01Z"
}
```

---
