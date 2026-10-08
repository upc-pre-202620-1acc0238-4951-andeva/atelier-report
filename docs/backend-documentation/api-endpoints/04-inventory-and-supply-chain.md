# Especificacion Canonica de Endpoints: Inventory & Supply Chain Context

Este documento constituye la referencia tecnica y exhaustiva de los 18 endpoints expuestos por el Bounded Context **Inventory & Supply Chain Context** (`com.andeva.atelier.platform.inventory`) dentro de la plataforma SaaS **Atelier Platform Backend**.

## 1. Arquitectura de Catalogo, Lotes FIFO y Cadena de Suministro

El modulo Inventory & Supply Chain gobierna la custodia fisica y valorizacion financiera de repuestos, lubricantes e insumos automotrices: la catalogacion estandarizada por codigos SKU, la administracion del directorio comercial de proveedores mayoristas, la gestion del ciclo de abastecimiento mediante ordenes de compra, el costeo y asignacion automatizada bajo el algoritmo estricto FIFO (First-In, First-Out) por lote fisico y el monitoreo preventivo de quiebres de stock mediante alertas automatizadas.

### 1.1. Principios Fundamentales del Diseno de Dominio
1. **Algoritmo Determinista FIFO de Costeo y Asignacion por Lote:** El sistema descarta el costeo promedio ponderado tradicional en favor del metodo First-In, First-Out por lote fisico de adquisicion. Cuando una orden de trabajo demanda repuestos, el motor FifoAllocationEngine consume las unidades del lote mas antiguo disponible, asegurando exactitud en el calculo contable del Costo de Ventas (COGS).
2. **Trazabilidad Documental y Comprobante Probatorio de Factura:** Todo lote ingresado al almacen, sea mediante orden de compra formal o ingreso directo, exige vincular el numero de comprobante fiscal y la URL de la fotografia del documento escaneado en Firebase Storage, impidiendo la creacion de existencias ficticias.
3. **Directorio Homologado de Proveedores con RUC Validado:** Los proveedores comerciales se auditan contra el padron tributario de SUNAT, exigiendo unicidad de RUC en el ambito de cada taller para asegurar consistencia pericial y tributaria.
4. **Maquina de Estados de Abastecimiento:** Las ordenes de compra evolucionan mediante un flujo riguroso: DRAFT (confeccion de lineas), ISSUED (formalizada ante el proveedor e inmutable), RECEIVED (conformidad fisica con factura que genera lotes FIFO) o CANCELLED (anulacion justificada antes de la recepcion).
5. **Monitoreo Proactivo de Umbrales Criticos de Reposicion:** El servicio de aplicacion evalua continuamente el saldo de existencias totales frente al parametro minStock, proyectando alertas reactivas para evitar paralizaciones operativas en bahia.
6. **Aislamiento Multi-Inquilino y Valuacion Patrimonial:** Todo repuesto, lote, proveedor y orden de compra pertenece estrictamente a un tenantId soberano. La valuacion financiera agrega exclusivamente los lotes fisicos remanentes del taller autenticado.
7. **Formato Estandar de Errores RFC 7807:** Cualquier transgresion de invariantes de negocio o excepcion tecnica produce una respuesta ProblemDetail estructurada.

### 1.2. Catalogo Maestro de Endpoints de Inventory & Supply Chain

| No. | Seccion | Metodo | Ruta | Controlador | Metodo Java | Permiso Requerido |
| :---: | :---: | :---: | :--- | :--- | :--- | :--- |
| 1 | 2.1 | `POST` | `/api/v1/inventory/items` | `InventoryItemsController` | `createInventoryItem()` | `@PreAuthorize("hasAuthority('inventory:parts:manage')")` |
| 2 | 2.2 | `GET` | `/api/v1/inventory/items` | `InventoryItemsController` | `getInventoryItems()` | `@PreAuthorize("hasAuthority('inventory:parts:read')")` |
| 3 | 2.3 | `GET` | `/api/v1/inventory/items/{id}` | `InventoryItemsController` | `getInventoryItemById()` | `@PreAuthorize("hasAuthority('inventory:parts:read')")` |
| 4 | 2.4 | `PUT` | `/api/v1/inventory/items/{id}` | `InventoryItemsController` | `updateInventoryItem()` | `@PreAuthorize("hasAuthority('inventory:parts:manage')")` |
| 5 | 2.5 | `GET` | `/api/v1/inventory/items/low-stock` | `InventoryItemsController` | `getLowStockItems()` | `@PreAuthorize("hasAuthority('inventory:parts:read')")` |
| 6 | 2.6 | `GET` | `/api/v1/inventory/items/valuation` | `InventoryItemsController` | `getInventoryValuation()` | `@PreAuthorize("hasAuthority('inventory:parts:read')")` |
| 7 | 3.1 | `POST` | `/api/v1/inventory/items/{itemId}/batches` | `InventoryBatchesController` | `addBatch()` | `@PreAuthorize("hasAuthority('inventory:batches:receive')")` |
| 8 | 3.2 | `GET` | `/api/v1/inventory/items/{itemId}/batches` | `InventoryBatchesController` | `getBatchesByItem()` | `@PreAuthorize("hasAuthority('inventory:parts:read')")` |
| 9 | 4.1 | `POST` | `/api/v1/inventory/suppliers` | `SuppliersController` | `createSupplier()` | `@PreAuthorize("hasAuthority('inventory:suppliers:manage')")` |
| 10 | 4.2 | `GET` | `/api/v1/inventory/suppliers` | `SuppliersController` | `getSuppliers()` | `@PreAuthorize("hasAuthority('inventory:suppliers:read')")` |
| 11 | 4.3 | `GET` | `/api/v1/inventory/suppliers/{id}` | `SuppliersController` | `getSupplierById()` | `@PreAuthorize("hasAuthority('inventory:suppliers:read')")` |
| 12 | 4.4 | `PUT` | `/api/v1/inventory/suppliers/{id}` | `SuppliersController` | `updateSupplier()` | `@PreAuthorize("hasAuthority('inventory:suppliers:manage')")` |
| 13 | 5.1 | `POST` | `/api/v1/inventory/purchase-orders` | `PurchaseOrdersController` | `createPurchaseOrder()` | `@PreAuthorize("hasAuthority('inventory:purchase_orders:create')")` |
| 14 | 5.2 | `GET` | `/api/v1/inventory/purchase-orders` | `PurchaseOrdersController` | `getPurchaseOrders()` | `@PreAuthorize("hasAuthority('inventory:purchase_orders:read')")` |
| 15 | 5.3 | `POST` | `/api/v1/inventory/purchase-orders/{id}/items` | `PurchaseOrdersController` | `addPurchaseOrderItem()` | `@PreAuthorize("hasAuthority('inventory:purchase_orders:create')")` |
| 16 | 5.4 | `PUT` | `/api/v1/inventory/purchase-orders/{id}/issue` | `PurchaseOrdersController` | `issuePurchaseOrder()` | `@PreAuthorize("hasAuthority('inventory:purchase_orders:create')")` |
| 17 | 5.5 | `PUT` | `/api/v1/inventory/purchase-orders/{id}/receive` | `PurchaseOrdersController` | `receivePurchaseOrder()` | `@PreAuthorize("hasAuthority('inventory:batches:receive')")` |
| 18 | 5.6 | `PUT` | `/api/v1/inventory/purchase-orders/{id}/cancel` | `PurchaseOrdersController` | `cancelPurchaseOrder()` | `@PreAuthorize("hasAuthority('inventory:purchase_orders:cancel')")` |

---

## 2. Endpoints de Catalogo de Repuestos e Insumos (InventoryItemsController)

### 2.1. [POST] /api/v1/inventory/items

**Creacion de Nuevo Repuesto en Catalogo Maestro**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.controllers.InventoryItemsController`
- **Metodo Java:** `public ResponseEntity<InventoryItemResource> createInventoryItem(@Valid @RequestBody CreateInventoryItemResource resource)`
- **Ruta Base:** `/api/v1/inventory/items`
- **Ruta Completa:** `/api/v1/inventory/items`
- **Proposito:** Registra una nueva pieza, fluido o repuesto en el catalogo maestro del taller automotriz. Valida la unicidad del codigo SKU en el ambito del taller, define el precio base sugerido, la categoria de clasificacion y el umbral de stock minimo para reposicion preventiva. Inicializa el stock total disponible en cero.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Encargado de Repuestos (ROLE_INVENTORY_MANAGER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('inventory:parts:manage')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId resuelto desde el token JWT. El codigo SKU es unico dentro de cada taller.

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
- **Registro Java DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.requests.CreateInventoryItemResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| name | String | Si | @NotBlank, @Size(max = 150) | Nombre comercial o descripcion tecnica del repuesto |
| sku | String | Si | @NotBlank, @Size(max = 50) | Codigo SKU alfanumerico estandarizado |
| category | String | Si | @NotBlank | Categoria funcional (BRAKES, SUSPENSION, ENGINE, FILTERS, FLUIDS, ELECTRICAL) |
| basePrice | BigDecimal | Si | @NotNull, @Positive | Precio base de venta fijado para el taller |
| minStock | BigDecimal | Si | @NotNull, @PositiveOrZero | Cantidad minima de seguridad en inventario |
| currency | String | Si | @NotBlank, @Pattern(regexp = "PEN|USD") | Codigo ISO de la moneda |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "name": "Filtro de Aceite Blindado Sintetico Mann-Filter",
  "sku": "FIL-OIL-W712-94",
  "category": "FILTERS",
  "basePrice": 45,
  "minStock": 5,
  "currency": "PEN"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Registro Java DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.responses.InventoryItemResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador universal unico del repuesto |
| tenantId | UUID | Identificador del taller automotriz propietario |
| name | String | Nombre del repuesto registrado |
| sku | String | Codigo SKU unico en el taller |
| category | String | Categoria del repuesto |
| basePrice | BigDecimal | Precio base de venta |
| totalStock | BigDecimal | Existencias fisicas consolidadas (0.0 al crear) |
| minimumStock | BigDecimal | Umbral de stock minimo |
| status | String | Estado en catalogo (ACTIVE) |
| currency | String | Moneda de facturacion |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000710",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "name": "Filtro de Aceite Blindado Sintetico Mann-Filter",
  "sku": "FIL-OIL-W712-94",
  "category": "FILTERS",
  "basePrice": 45,
  "totalStock": 0,
  "minimumStock": 5,
  "status": "ACTIVE",
  "currency": "PEN"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 400 Bad Request | MethodArgumentNotValidException | Datos de solicitud invalidos o campos en blanco |
| 409 Conflict | DuplicateSkuException | El codigo SKU ya se encuentra registrado por otro repuesto en el taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/duplicate-sku",
  "title": "Codigo SKU Duplicado",
  "status": 409,
  "detail": "Ya existe un repuesto en el catalogo con el codigo SKU FIL-OIL-W712-94",
  "instance": "/api/v1/inventory/items",
  "code": "ERR_DUPLICATE_SKU",
  "timestamp": "2026-10-03T15:00:00Z"
}
```

---

### 2.2. [GET] /api/v1/inventory/items

**Listado de Catalogo de Repuestos con Stock Disponible**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.controllers.InventoryItemsController`
- **Metodo Java:** `public ResponseEntity<List<InventoryItemSummaryResource>> getInventoryItems()`
- **Ruta Base:** `/api/v1/inventory/items`
- **Ruta Completa:** `/api/v1/inventory/items`
- **Proposito:** Retorna el resumen de todos los repuestos registrados en el catalogo maestro del taller automotriz, incluyendo el saldo consolidado de existencias fisicas y precios base para asignacion en foso.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Mecanico (ROLE_MECHANIC), Recepcionista (ROLE_RECEPTIONIST) o Encargado de Repuestos (ROLE_INVENTORY_MANAGER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('inventory:parts:read')")`
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
- **Registro Java DTO:** `java.util.List<com.andeva.atelier.platform.inventory.interfaces.rest.resources.responses.InventoryItemSummaryResource>`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico del repuesto |
| name | String | Nombre comercial del repuesto |
| sku | String | Codigo SKU de identificacion |
| category | String | Categoria funcional |
| basePrice | BigDecimal | Precio de venta al publico |
| totalStock | BigDecimal | Saldo total consolidado disponible |
| currency | String | Divisa de facturacion |

**Ejemplo de Carga Util JSON (Response):**
```json
[
  {
    "id": "018f6c40-7e12-7000-8000-000000000701",
    "name": "Juego de Pastillas Ceramicas Delanteras Bosch",
    "sku": "BRK-PAD-BOSCH-01",
    "category": "BRAKES",
    "basePrice": 180,
    "totalStock": 8,
    "currency": "PEN"
  },
  {
    "id": "018f6c40-7e12-7000-8000-000000000710",
    "name": "Filtro de Aceite Blindado Sintetico Mann-Filter",
    "sku": "FIL-OIL-W712-94",
    "category": "FILTERS",
    "basePrice": 45,
    "totalStock": 12,
    "currency": "PEN"
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 401 Unauthorized | BadCredentialsException | Token JWT ausente o no valido |
| 403 Forbidden | AccessDeniedException | Privilegio insuficiente inventory:parts:read |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/access-denied",
  "title": "Acceso Denegado",
  "status": 403,
  "detail": "No cuenta con el privilegio requerido inventory:parts:read para consultar el catalogo de repuestos",
  "instance": "/api/v1/inventory/items",
  "code": "ACCESS_DENIED",
  "timestamp": "2026-10-03T15:05:00Z"
}
```

---

### 2.3. [GET] /api/v1/inventory/items/{id}

**Detalle de Repuesto con Desglose de Lotes FIFO Activos**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.controllers.InventoryItemsController`
- **Metodo Java:** `public ResponseEntity<InventoryItemDetailResource> getInventoryItemById(@PathVariable UUID id)`
- **Ruta Base:** `/api/v1/inventory/items`
- **Ruta Completa:** `/api/v1/inventory/items/{id}`
- **Proposito:** Recupera la ficha pormenorizada de un repuesto incluyendo la composicion analitica de sus lotes fisicos activos ordenados cronologicamente por fecha de ingreso (FIFO), sus costos unitarios de adquisicion y cantidades remanentes.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Mecanico (ROLE_MECHANIC) o Encargado de Repuestos (ROLE_INVENTORY_MANAGER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('inventory:parts:read')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `id` (UUID): Identificador unico del repuesto consultado

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.responses.InventoryItemDetailResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico del repuesto |
| name | String | Nombre comercial del repuesto |
| sku | String | Codigo SKU |
| category | String | Categoria |
| basePrice | BigDecimal | Precio base de venta |
| totalStock | BigDecimal | Saldo total de existencias |
| minimumStock | BigDecimal | Umbral de reposicion minima |
| currency | String | Moneda |
| batches | List<InventoryBatchResource> | Listado cronologico de lotes activos bajo algoritmo FIFO |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000701",
  "name": "Juego de Pastillas Ceramicas Delanteras Bosch",
  "sku": "BRK-PAD-BOSCH-01",
  "category": "BRAKES",
  "basePrice": 180,
  "totalStock": 8,
  "minimumStock": 4,
  "currency": "PEN",
  "batches": [
    {
      "id": "018f6c40-7e12-7000-8000-000000000780",
      "itemId": "018f6c40-7e12-7000-8000-000000000701",
      "supplierId": "018f6c40-7e12-7000-8000-000000000750",
      "supplierName": "Distribuidora Automotriz del Centro S.A.C.",
      "batchNumber": "LOTE-2026-089",
      "initialQuantity": 10,
      "remainingQuantity": 3,
      "unitCost": 110,
      "currency": "PEN",
      "arrivalDate": "2026-09-15T09:30:00Z",
      "receiptImageUrl": "https://firebasestorage.googleapis.com/v0/b/atelier-app.appspot.com/o/tenants%2F018f6c40-7e12-7000-8000-000000000001%2Fbatches%2Ffactura-f001-4921.jpg?alt=media"
    },
    {
      "id": "018f6c40-7e12-7000-8000-000000000781",
      "itemId": "018f6c40-7e12-7000-8000-000000000701",
      "supplierId": "018f6c40-7e12-7000-8000-000000000750",
      "supplierName": "Distribuidora Automotriz del Centro S.A.C.",
      "batchNumber": "LOTE-2026-112",
      "initialQuantity": 5,
      "remainingQuantity": 5,
      "unitCost": 115,
      "currency": "PEN",
      "arrivalDate": "2026-10-01T14:15:00Z",
      "receiptImageUrl": "https://firebasestorage.googleapis.com/v0/b/atelier-app.appspot.com/o/tenants%2F018f6c40-7e12-7000-8000-000000000001%2Fbatches%2Ffactura-f001-5100.jpg?alt=media"
    }
  ]
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 404 Not Found | InventoryItemNotFoundException | El repuesto solicitado no existe en el catalogo del taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/inventory-item-not-found",
  "title": "Repuesto No Encontrado",
  "status": 404,
  "detail": "No se encontro ningun repuesto con el identificador 018f6c40-7e12-7000-8000-000000000701",
  "instance": "/api/v1/inventory/items/018f6c40-7e12-7000-8000-000000000701",
  "code": "ERR_ITEM_NOT_FOUND",
  "timestamp": "2026-10-03T15:10:00Z"
}
```

---

### 2.4. [PUT] /api/v1/inventory/items/{id}

**Actualizacion de Parametros y Precios de Repuesto**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.controllers.InventoryItemsController`
- **Metodo Java:** `public ResponseEntity<InventoryItemResource> updateInventoryItem(@PathVariable UUID id, @Valid @RequestBody UpdateInventoryItemResource resource)`
- **Ruta Base:** `/api/v1/inventory/items`
- **Ruta Completa:** `/api/v1/inventory/items/{id}`
- **Proposito:** Actualiza los parametros operativos de un repuesto existente en el catalogo: nombre, categoria, precio base de venta fijado y umbral de stock minimo de reposicion. El codigo SKU no es modificable para salvaguardar la trazabilidad historica.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Encargado de Repuestos (ROLE_INVENTORY_MANAGER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('inventory:parts:manage')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `id` (UUID): Identificador unico del repuesto a actualizar

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.requests.UpdateInventoryItemResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| name | String | Si | @NotBlank, @Size(max = 150) | Nombre comercial actualizado del repuesto |
| category | String | Si | @NotBlank | Categoria funcional rectificada |
| basePrice | BigDecimal | Si | @NotNull, @Positive | Nuevo precio base de venta |
| minStock | BigDecimal | Si | @NotNull, @PositiveOrZero | Nuevo umbral de stock minimo |
| currency | String | Si | @NotBlank, @Pattern(regexp = "PEN|USD") | Codigo ISO de la moneda |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "name": "Filtro de Aceite Blindado Sintetico Premium Mann-Filter",
  "category": "FILTERS",
  "basePrice": 48,
  "minStock": 6,
  "currency": "PEN"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.responses.InventoryItemResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico del repuesto |
| tenantId | UUID | Identificador del taller |
| name | String | Nombre actualizado |
| sku | String | Codigo SKU inmutable |
| category | String | Categoria |
| basePrice | BigDecimal | Nuevo precio de venta |
| totalStock | BigDecimal | Saldo total disponible |
| minimumStock | BigDecimal | Nuevo stock minimo |
| status | String | Estado en catalogo |
| currency | String | Moneda |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000710",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "name": "Filtro de Aceite Blindado Sintetico Premium Mann-Filter",
  "sku": "FIL-OIL-W712-94",
  "category": "FILTERS",
  "basePrice": 48,
  "totalStock": 12,
  "minimumStock": 6,
  "status": "ACTIVE",
  "currency": "PEN"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 400 Bad Request | MethodArgumentNotValidException | Datos de actualizacion invalidos o campos requeridos omitidos |
| 404 Not Found | InventoryItemNotFoundException | El repuesto no existe en el catalogo del taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/inventory-item-not-found",
  "title": "Repuesto No Encontrado",
  "status": 404,
  "detail": "No se encontro el repuesto para actualizar con el identificador 018f6c40-7e12-7000-8000-000000000710",
  "instance": "/api/v1/inventory/items/018f6c40-7e12-7000-8000-000000000710",
  "code": "ERR_ITEM_NOT_FOUND",
  "timestamp": "2026-10-03T15:15:00Z"
}
```

---

### 2.5. [GET] /api/v1/inventory/items/low-stock

**Alerta de Repuestos por Debajo del Umbral Minimo**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.controllers.InventoryItemsController`
- **Metodo Java:** `public ResponseEntity<List<InventoryItemSummaryResource>> getLowStockItems()`
- **Ruta Base:** `/api/v1/inventory/items`
- **Ruta Completa:** `/api/v1/inventory/items/low-stock`
- **Proposito:** Ejecuta una verificacion sistematica del estado de inventario para proyectar aquellos repuestos cuyo saldo de existencias totales se encuentra por debajo o igual a su umbral de stock minimo parametrizado. Permite al encargado de compras alimentar proactivamente las ordenes de abastecimiento.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Mecanico Jefe (ROLE_CHIEF_MECHANIC) o Encargado de Repuestos (ROLE_INVENTORY_MANAGER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('inventory:parts:read')")`
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
- **Registro Java DTO:** `java.util.List<com.andeva.atelier.platform.inventory.interfaces.rest.resources.responses.InventoryItemSummaryResource>`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico del repuesto en alerta |
| name | String | Nombre comercial del repuesto |
| sku | String | Codigo SKU |
| category | String | Categoria del repuesto |
| basePrice | BigDecimal | Precio de venta al publico |
| totalStock | BigDecimal | Saldo remanente en nivel critico |
| currency | String | Moneda |

**Ejemplo de Carga Util JSON (Response):**
```json
[
  {
    "id": "018f6c40-7e12-7000-8000-000000000705",
    "name": "Liquido de Frenos Sintetico DOT 4 (500 ml)",
    "sku": "FLD-BRK-DOT4-500",
    "category": "FLUIDS",
    "basePrice": 32,
    "totalStock": 2,
    "currency": "PEN"
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 401 Unauthorized | BadCredentialsException | Token JWT ausente o expirado |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/unauthorized",
  "title": "Sesion No Autorizada",
  "status": 401,
  "detail": "Se requiere un token Bearer valido para consultar alertas de stock",
  "instance": "/api/v1/inventory/items/low-stock",
  "code": "UNAUTHORIZED",
  "timestamp": "2026-10-03T15:20:00Z"
}
```

---

### 2.6. [GET] /api/v1/inventory/items/valuation

**Calculo de Valuacion Total del Inventario a Costo FIFO**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.controllers.InventoryItemsController`
- **Metodo Java:** `public ResponseEntity<InventoryValuationResource> getInventoryValuation()`
- **Ruta Base:** `/api/v1/inventory/items`
- **Ruta Completa:** `/api/v1/inventory/items/valuation`
- **Proposito:** Computa la valorizacion monetaria patrimonial completa del inventario del taller. Aplica la sumatoria del producto de la cantidad remanente de cada lote fisico activo por su costo unitario historico de adquisicion, reportando el valor patrimonial neto y numero de articulos distintos.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Encargado de Repuestos (ROLE_INVENTORY_MANAGER) o Administrador (ROLE_ADMIN)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('inventory:parts:read')")`
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
- **Registro Java DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.responses.InventoryValuationResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| tenantId | UUID | Identificador del taller auditado |
| totalValuation | BigDecimal | Monto consolidado de valuacion patrimonial a costo FIFO |
| distinctItemsCount | int | Cantidad de articulos distintos con stock activo |
| calculatedAt | Instant | Marca temporal exacta del calculo financiero |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "totalValuation": 28450.75,
  "distinctItemsCount": 142,
  "calculatedAt": "2026-10-03T15:25:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 401 Unauthorized | BadCredentialsException | Token JWT ausente o expirado |
| 403 Forbidden | AccessDeniedException | Privilegio insuficiente para consultar valuaciones patrimoniales |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/access-denied",
  "title": "Permiso Insuficiente",
  "status": 403,
  "detail": "No cuenta con el privilegio requerido inventory:parts:read para consultar valuacion contable",
  "instance": "/api/v1/inventory/items/valuation",
  "code": "ACCESS_DENIED",
  "timestamp": "2026-10-03T15:26:00Z"
}
```

---

## 3. Endpoints de Trazabilidad y Lotes Fisicos (InventoryBatchesController)

### 3.1. [POST] /api/v1/inventory/items/{itemId}/batches

**Ingreso Manual de Lote Fisico con Costo Unitario y Factura**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.controllers.InventoryBatchesController`
- **Metodo Java:** `public ResponseEntity<InventoryBatchResource> addBatch(@PathVariable UUID itemId, @Valid @RequestBody AddInventoryBatchResource resource)`
- **Ruta Base:** `/api/v1/inventory/items/{itemId}/batches`
- **Ruta Completa:** `/api/v1/inventory/items/{itemId}/batches`
- **Proposito:** Registra un ingreso fisico directo de lote para un repuesto en catalogo (ingreso manual por compras locales de emergencia o ajuste inicial de inventario). Registra el proveedor mayorista, numero de lote o comprobante, cantidad ingresada, costo unitario de adquisicion y URL de la fotografia de la factura.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Encargado de Repuestos (ROLE_INVENTORY_MANAGER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('inventory:batches:receive')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `itemId` (UUID): Identificador unico del repuesto receptor

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.requests.AddInventoryBatchResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| supplierId | UUID | Si | @NotNull | Identificador del proveedor mayorista emisor |
| batchNumber | String | Si | @NotBlank, @Size(max = 50) | Numero de lote o serie de factura del proveedor |
| quantity | BigDecimal | Si | @NotNull, @Positive | Cantidad fisica de unidades que ingresan al almacen |
| unitCost | BigDecimal | Si | @NotNull, @Positive | Costo unitario de adquisicion gravado sin impuestos |
| currency | String | Si | @NotBlank, @Pattern(regexp = "PEN|USD") | Codigo ISO de la moneda |
| receiptImageUrl | String | Si | @NotBlank, @URL | URL segura HTTPS de la factura escaneada en Firebase Storage |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "supplierId": "018f6c40-7e12-7000-8000-000000000750",
  "batchNumber": "F001-0006240",
  "quantity": 20,
  "unitCost": 108.5,
  "currency": "PEN",
  "receiptImageUrl": "https://firebasestorage.googleapis.com/v0/b/atelier-app.appspot.com/o/tenants%2F018f6c40-7e12-7000-8000-000000000001%2Fbatches%2Ffactura-f001-6240.jpg?alt=media"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Registro Java DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.responses.InventoryBatchResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico del lote fisico registrado |
| itemId | UUID | Identificador del repuesto al que pertenece |
| supplierId | UUID | Identificador del proveedor mayorista |
| supplierName | String | Razon social del proveedor |
| batchNumber | String | Numero de lote o factura |
| initialQuantity | BigDecimal | Cantidad de ingreso original |
| remainingQuantity | BigDecimal | Cantidad remanente disponible para despacho |
| unitCost | BigDecimal | Costo unitario de adquisicion |
| currency | String | Moneda de adquisicion |
| arrivalDate | Instant | Marca temporal de recepcion e ingreso al stock |
| receiptImageUrl | String | URL HTTPS de la factura probatoria |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000785",
  "itemId": "018f6c40-7e12-7000-8000-000000000701",
  "supplierId": "018f6c40-7e12-7000-8000-000000000750",
  "supplierName": "Distribuidora Automotriz del Centro S.A.C.",
  "batchNumber": "F001-0006240",
  "initialQuantity": 20,
  "remainingQuantity": 20,
  "unitCost": 108.5,
  "currency": "PEN",
  "arrivalDate": "2026-10-03T15:30:00Z",
  "receiptImageUrl": "https://firebasestorage.googleapis.com/v0/b/atelier-app.appspot.com/o/tenants%2F018f6c40-7e12-7000-8000-000000000001%2Fbatches%2Ffactura-f001-6240.jpg?alt=media"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 400 Bad Request | MethodArgumentNotValidException | Datos de lote invalidos o campos requeridos omitidos |
| 404 Not Found | InventoryItemNotFoundException | El repuesto no existe en el catalogo del taller |
| 404 Not Found | SupplierNotFoundException | El proveedor comercial no existe en el directorio |
| 422 Unprocessable Entity | InvalidBatchQuantityException | La cantidad del lote es menor o igual a cero |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-batch-quantity",
  "title": "Cantidad de Lote Invalida",
  "status": 422,
  "detail": "La cantidad de unidades ingresadas en el lote debe ser estrictamente positiva",
  "instance": "/api/v1/inventory/items/018f6c40-7e12-7000-8000-000000000701/batches",
  "code": "ERR_INVALID_BATCH_QUANTITY",
  "timestamp": "2026-10-03T15:31:00Z"
}
```

---

### 3.2. [GET] /api/v1/inventory/items/{itemId}/batches

**Trazabilidad Historica de Lotes FIFO del Repuesto**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.controllers.InventoryBatchesController`
- **Metodo Java:** `public ResponseEntity<List<InventoryBatchResource>> getBatchesByItem(@PathVariable UUID itemId)`
- **Ruta Base:** `/api/v1/inventory/items/{itemId}/batches`
- **Ruta Completa:** `/api/v1/inventory/items/{itemId}/batches`
- **Proposito:** Recupera el historial cronologico exhaustivo de todos los lotes ingresados para un repuesto especifico, tanto activos con saldo remanente como lotes agotados por consumo previo, permitiendo auditorias periciales y tributarias de costos.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Mecanico Jefe (ROLE_CHIEF_MECHANIC) o Encargado de Repuestos (ROLE_INVENTORY_MANAGER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('inventory:parts:read')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `itemId` (UUID): Identificador unico del repuesto consultado

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `java.util.List<com.andeva.atelier.platform.inventory.interfaces.rest.resources.responses.InventoryBatchResource>`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico del lote |
| itemId | UUID | Identificador del repuesto |
| supplierId | UUID | Identificador del proveedor |
| supplierName | String | Nombre del proveedor mayorista |
| batchNumber | String | Numero de serie de lote o factura |
| initialQuantity | BigDecimal | Cantidad de ingreso original |
| remainingQuantity | BigDecimal | Cantidad remanente actual |
| unitCost | BigDecimal | Costo unitario historico |
| currency | String | Moneda |
| arrivalDate | Instant | Marca temporal de recepcion |
| receiptImageUrl | String | URL HTTPS del comprobante escaneado |

**Ejemplo de Carga Util JSON (Response):**
```json
[
  {
    "id": "018f6c40-7e12-7000-8000-000000000780",
    "itemId": "018f6c40-7e12-7000-8000-000000000701",
    "supplierId": "018f6c40-7e12-7000-8000-000000000750",
    "supplierName": "Distribuidora Automotriz del Centro S.A.C.",
    "batchNumber": "LOTE-2026-089",
    "initialQuantity": 10,
    "remainingQuantity": 3,
    "unitCost": 110,
    "currency": "PEN",
    "arrivalDate": "2026-09-15T09:30:00Z",
    "receiptImageUrl": "https://firebasestorage.googleapis.com/v0/b/atelier-app.appspot.com/o/tenants%2F018f6c40-7e12-7000-8000-000000000001%2Fbatches%2Ffactura-f001-4921.jpg?alt=media"
  },
  {
    "id": "018f6c40-7e12-7000-8000-000000000785",
    "itemId": "018f6c40-7e12-7000-8000-000000000701",
    "supplierId": "018f6c40-7e12-7000-8000-000000000750",
    "supplierName": "Distribuidora Automotriz del Centro S.A.C.",
    "batchNumber": "F001-0006240",
    "initialQuantity": 20,
    "remainingQuantity": 20,
    "unitCost": 108.5,
    "currency": "PEN",
    "arrivalDate": "2026-10-03T15:30:00Z",
    "receiptImageUrl": "https://firebasestorage.googleapis.com/v0/b/atelier-app.appspot.com/o/tenants%2F018f6c40-7e12-7000-8000-000000000001%2Fbatches%2Ffactura-f001-6240.jpg?alt=media"
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 404 Not Found | InventoryItemNotFoundException | El repuesto no existe en el catalogo del taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/inventory-item-not-found",
  "title": "Repuesto No Encontrado",
  "status": 404,
  "detail": "No se encontro el repuesto solicitado para consultar su trazabilidad de lotes",
  "instance": "/api/v1/inventory/items/018f6c40-7e12-7000-8000-000000000701/batches",
  "code": "ERR_ITEM_NOT_FOUND",
  "timestamp": "2026-10-03T15:35:00Z"
}
```

---

## 4. Endpoints de Directorio de Proveedores (SuppliersController)

### 4.1. [POST] /api/v1/inventory/suppliers

**Registro de Nuevo Proveedor Mayorista de Repuestos**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.controllers.SuppliersController`
- **Metodo Java:** `public ResponseEntity<SupplierResource> createSupplier(@Valid @RequestBody CreateSupplierResource resource)`
- **Ruta Base:** `/api/v1/inventory/suppliers`
- **Ruta Completa:** `/api/v1/inventory/suppliers`
- **Proposito:** Registra una nueva empresa proveedora de repuestos, lubricantes o consumibles en el directorio comercial del taller. Valida el numero de RUC de 11 digitos y su unicidad en el ambito del taller, asociando datos de contacto corporativo y direccion fiscal. Inicializa el estado del proveedor en activo.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Encargado de Repuestos (ROLE_INVENTORY_MANAGER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('inventory:suppliers:manage')")`
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
- **Registro Java DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.requests.CreateSupplierResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| businessName | String | Si | @NotBlank, @Size(max = 150) | Razon social formal inscrita ante SUNAT |
| taxId | String | Si | @NotBlank, @Pattern(regexp = "^(10|20)\d{9}$") | Numero de RUC valido de 11 digitos |
| contactName | String | Si | @NotBlank, @Size(max = 100) | Nombres y apellidos del ejecutivo de cuentas |
| phone | String | Si | @NotBlank, @Pattern(regexp = "^\+?[0-9]{9,15}$") | Numero telefonico de contacto directo |
| email | String | Si | @NotBlank, @Email | Correo electronico para emision de pedidos |
| address | String | Si | @NotBlank, @Size(max = 255) | Direccion fisica o almacen del proveedor |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "businessName": "DISTRIBUIDORA AUTOMOTRIZ DEL CENTRO S.A.C.",
  "taxId": "20519842103",
  "contactName": "Miguel Angel Ramirez",
  "phone": "+51981234567",
  "email": "ventas@distribuidoracentro.pe",
  "address": "Av. Nicolas Ayllon 1420, Ate, Lima"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Registro Java DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.responses.SupplierResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico del proveedor |
| tenantId | UUID | Identificador del taller propietario |
| businessName | String | Razon social registrada |
| taxId | String | RUC validado |
| contactName | String | Contacto comercial |
| phone | String | Telefono corporativo |
| email | String | Correo electronico |
| address | String | Direccion registrada |
| isActive | boolean | Estado operativo en directorio (true) |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000750",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "businessName": "DISTRIBUIDORA AUTOMOTRIZ DEL CENTRO S.A.C.",
  "taxId": "20519842103",
  "contactName": "Miguel Angel Ramirez",
  "phone": "+51981234567",
  "email": "ventas@distribuidoracentro.pe",
  "address": "Av. Nicolas Ayllon 1420, Ate, Lima",
  "isActive": true
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 400 Bad Request | MethodArgumentNotValidException | RUC invalido o campos de contacto omitidos |
| 409 Conflict | DuplicateSupplierTaxIdException | El numero de RUC ya se encuentra registrado por otro proveedor en el taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/duplicate-supplier-tax-id",
  "title": "RUC de Proveedor Duplicado",
  "status": 409,
  "detail": "Ya existe un proveedor registrado con el RUC 20519842103 en el directorio del taller",
  "instance": "/api/v1/inventory/suppliers",
  "code": "ERR_DUPLICATE_SUPPLIER_RUC",
  "timestamp": "2026-10-03T15:40:00Z"
}
```

---

### 4.2. [GET] /api/v1/inventory/suppliers

**Consulta del Directorio de Proveedores del Taller**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.controllers.SuppliersController`
- **Metodo Java:** `public ResponseEntity<List<SupplierResource>> getSuppliers()`
- **Ruta Base:** `/api/v1/inventory/suppliers`
- **Ruta Completa:** `/api/v1/inventory/suppliers`
- **Proposito:** Retorna el directorio completo de proveedores comerciales mayoristas homologados por el taller automotriz, para la seleccion y elaboracion de ordenes de abastecimiento.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Encargado de Repuestos (ROLE_INVENTORY_MANAGER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('inventory:suppliers:read')")`
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
- **Registro Java DTO:** `java.util.List<com.andeva.atelier.platform.inventory.interfaces.rest.resources.responses.SupplierResource>`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico del proveedor |
| tenantId | UUID | Identificador del taller |
| businessName | String | Razon social |
| taxId | String | Numero de RUC |
| contactName | String | Nombre del contacto |
| phone | String | Telefono |
| email | String | Correo corporativo |
| address | String | Direccion |
| isActive | boolean | Estado de actividad |

**Ejemplo de Carga Util JSON (Response):**
```json
[
  {
    "id": "018f6c40-7e12-7000-8000-000000000750",
    "tenantId": "018f6c40-7e12-7000-8000-000000000001",
    "businessName": "DISTRIBUIDORA AUTOMOTRIZ DEL CENTRO S.A.C.",
    "taxId": "20519842103",
    "contactName": "Miguel Angel Ramirez",
    "phone": "+51981234567",
    "email": "ventas@distribuidoracentro.pe",
    "address": "Av. Nicolas Ayllon 1420, Ate, Lima",
    "isActive": true
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 401 Unauthorized | BadCredentialsException | Token JWT ausente o expirado |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/unauthorized",
  "title": "Sesion No Autorizada",
  "status": 401,
  "detail": "Se requiere autenticacion para consultar proveedores",
  "instance": "/api/v1/inventory/suppliers",
  "code": "UNAUTHORIZED",
  "timestamp": "2026-10-03T15:45:00Z"
}
```

---

### 4.3. [GET] /api/v1/inventory/suppliers/{id}

**Detalle Exhaustivo de Proveedor Comercial**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.controllers.SuppliersController`
- **Metodo Java:** `public ResponseEntity<SupplierResource> getSupplierById(@PathVariable UUID id)`
- **Ruta Base:** `/api/v1/inventory/suppliers`
- **Ruta Completa:** `/api/v1/inventory/suppliers/{id}`
- **Proposito:** Recupera la ficha detallada de un proveedor comercial especifico mediante su identificador unico.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Encargado de Repuestos (ROLE_INVENTORY_MANAGER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('inventory:suppliers:read')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `id` (UUID): Identificador unico del proveedor comercial

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.responses.SupplierResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico del proveedor |
| tenantId | UUID | Identificador del taller |
| businessName | String | Razon social |
| taxId | String | RUC validado |
| contactName | String | Nombre del contacto |
| phone | String | Telefono |
| email | String | Correo electronico |
| address | String | Direccion |
| isActive | boolean | Estado en directorio |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000750",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "businessName": "DISTRIBUIDORA AUTOMOTRIZ DEL CENTRO S.A.C.",
  "taxId": "20519842103",
  "contactName": "Miguel Angel Ramirez",
  "phone": "+51981234567",
  "email": "ventas@distribuidoracentro.pe",
  "address": "Av. Nicolas Ayllon 1420, Ate, Lima",
  "isActive": true
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 404 Not Found | SupplierNotFoundException | El proveedor comercial no existe en el directorio del taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/supplier-not-found",
  "title": "Proveedor No Encontrado",
  "status": 404,
  "detail": "No se encontro ningun proveedor con el identificador 018f6c40-7e12-7000-8000-000000000750",
  "instance": "/api/v1/inventory/suppliers/018f6c40-7e12-7000-8000-000000000750",
  "code": "ERR_SUPPLIER_NOT_FOUND",
  "timestamp": "2026-10-03T15:50:00Z"
}
```

---

### 4.4. [PUT] /api/v1/inventory/suppliers/{id}

**Actualizacion de Contacto y Direccion de Proveedor**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.controllers.SuppliersController`
- **Metodo Java:** `public ResponseEntity<SupplierResource> updateSupplier(@PathVariable UUID id, @Valid @RequestBody UpdateSupplierResource resource)`
- **Ruta Base:** `/api/v1/inventory/suppliers`
- **Ruta Completa:** `/api/v1/inventory/suppliers/{id}`
- **Proposito:** Actualiza la informacion de contacto directo, numero telefonico, correo corporativo y direccion de despacho de un proveedor registrado. La razon social y el RUC se preservan inmutables para no alterar la consistencia de comprobantes historicos.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Encargado de Repuestos (ROLE_INVENTORY_MANAGER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('inventory:suppliers:manage')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `id` (UUID): Identificador unico del proveedor comercial a actualizar

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.requests.UpdateSupplierResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| contactName | String | Si | @NotBlank, @Size(max = 100) | Nombres actualizados del ejecutivo de cuentas |
| phone | String | Si | @NotBlank, @Pattern(regexp = "^\+?[0-9]{9,15}$") | Nuevo numero telefonico de contacto |
| email | String | Si | @NotBlank, @Email | Correo corporativo actualizado |
| address | String | Si | @NotBlank, @Size(max = 255) | Nueva direccion fiscal o de almacen |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "contactName": "Miguel Angel Ramirez Alva",
  "phone": "+51981234999",
  "email": "mramirez@distribuidoracentro.pe",
  "address": "Av. Nicolas Ayllon 1450, Ate, Lima"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.responses.SupplierResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico del proveedor |
| tenantId | UUID | Identificador del taller |
| businessName | String | Razon social inmutable |
| taxId | String | RUC inmutable |
| contactName | String | Contacto comercial actualizado |
| phone | String | Telefono actualizado |
| email | String | Correo actualizado |
| address | String | Direccion actualizada |
| isActive | boolean | Estado en directorio |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000750",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "businessName": "DISTRIBUIDORA AUTOMOTRIZ DEL CENTRO S.A.C.",
  "taxId": "20519842103",
  "contactName": "Miguel Angel Ramirez Alva",
  "phone": "+51981234999",
  "email": "mramirez@distribuidoracentro.pe",
  "address": "Av. Nicolas Ayllon 1450, Ate, Lima",
  "isActive": true
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 400 Bad Request | MethodArgumentNotValidException | Datos de contacto invalidos o formato de correo incorrecto |
| 404 Not Found | SupplierNotFoundException | El proveedor comercial no existe en el taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/supplier-not-found",
  "title": "Proveedor No Encontrado",
  "status": 404,
  "detail": "No se encontro el proveedor para actualizar con el identificador 018f6c40-7e12-7000-8000-000000000750",
  "instance": "/api/v1/inventory/suppliers/018f6c40-7e12-7000-8000-000000000750",
  "code": "ERR_SUPPLIER_NOT_FOUND",
  "timestamp": "2026-10-03T15:55:00Z"
}
```

---

## 5. Endpoints de Ordenes de Compra y Abastecimiento (PurchaseOrdersController)

### 5.1. [POST] /api/v1/inventory/purchase-orders

**Creacion de Orden de Compra en Estado Borrador**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.controllers.PurchaseOrdersController`
- **Metodo Java:** `public ResponseEntity<PurchaseOrderResource> createPurchaseOrder(@Valid @RequestBody CreatePurchaseOrderResource resource)`
- **Ruta Base:** `/api/v1/inventory/purchase-orders`
- **Ruta Completa:** `/api/v1/inventory/purchase-orders`
- **Proposito:** Inicia el proceso formal de abastecimiento de repuestos mediante la creacion de una orden de compra en estado DRAFT vinculada a un proveedor homologado y a una sucursal del taller. Inicializa el costo total en cero y la coleccion de lineas vacia.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Encargado de Repuestos (ROLE_INVENTORY_MANAGER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('inventory:purchase_orders:create')")`
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
- **Registro Java DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.requests.CreatePurchaseOrderResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| supplierId | UUID | Si | @NotNull | Identificador del proveedor mayorista destinatario |
| branchId | UUID | Si | @NotNull | Identificador de la sucursal del taller receptora |
| orderNumber | String | Si | @NotBlank, @Size(max = 50) | Codigo correlativo interno de orden de compra |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "supplierId": "018f6c40-7e12-7000-8000-000000000750",
  "branchId": "018f6c40-7e12-7000-8000-000000000050",
  "orderNumber": "OC-2026-0045"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Registro Java DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.responses.PurchaseOrderResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la orden de compra |
| tenantId | UUID | Identificador del taller |
| supplierId | UUID | Identificador del proveedor mayorista |
| supplierName | String | Razon social del proveedor |
| branchId | UUID | Identificador de sucursal |
| orderNumber | String | Numero correlativo de orden |
| status | String | Estado operativo inicial (DRAFT) |
| totalCost | BigDecimal | Costo consolidado acumulado (0.00 al inicio) |
| currency | String | Moneda de operacion (PEN) |
| receiptImageUrl | String | URL de factura escaneada (null al crear) |
| receiptNumber | String | Numero de comprobante (null al crear) |
| receivedAt | Instant | Marca temporal de recepcion (null al crear) |
| items | List<PurchaseOrderItemResource> | Lineas de repuestos agregadas |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000880",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "supplierId": "018f6c40-7e12-7000-8000-000000000750",
  "supplierName": "DISTRIBUIDORA AUTOMOTRIZ DEL CENTRO S.A.C.",
  "branchId": "018f6c40-7e12-7000-8000-000000000050",
  "orderNumber": "OC-2026-0045",
  "status": "DRAFT",
  "totalCost": 0,
  "currency": "PEN",
  "receiptImageUrl": null,
  "receiptNumber": null,
  "receivedAt": null,
  "items": []
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 400 Bad Request | MethodArgumentNotValidException | Datos obligatorios omitidos o formato invalido |
| 404 Not Found | SupplierNotFoundException | El proveedor comercial especificado no existe en el taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/supplier-not-found",
  "title": "Proveedor No Encontrado",
  "status": 404,
  "detail": "No se localizo el proveedor indicado para la orden de compra",
  "instance": "/api/v1/inventory/purchase-orders",
  "code": "ERR_SUPPLIER_NOT_FOUND",
  "timestamp": "2026-10-03T16:00:00Z"
}
```

---

### 5.2. [GET] /api/v1/inventory/purchase-orders

**Listado de Ordenes de Compra del Taller**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.controllers.PurchaseOrdersController`
- **Metodo Java:** `public ResponseEntity<List<PurchaseOrderResource>> getPurchaseOrders()`
- **Ruta Base:** `/api/v1/inventory/purchase-orders`
- **Ruta Completa:** `/api/v1/inventory/purchase-orders`
- **Proposito:** Retorna el historial completo de ordenes de compra de abastecimiento del taller automotriz, permitiendo auditar el ciclo de adquisicion desde borradores, ordenes emitidas y mercaderia recibida.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Encargado de Repuestos (ROLE_INVENTORY_MANAGER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('inventory:purchase_orders:read')")`
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
- **Registro Java DTO:** `java.util.List<com.andeva.atelier.platform.inventory.interfaces.rest.resources.responses.PurchaseOrderResource>`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador unico de la orden de compra |
| tenantId | UUID | Identificador del taller |
| supplierId | UUID | Identificador del proveedor |
| supplierName | String | Nombre del proveedor |
| branchId | UUID | Identificador de sucursal |
| orderNumber | String | Numero correlativo |
| status | String | Estado operativo (DRAFT, ISSUED, RECEIVED, CANCELLED) |
| totalCost | BigDecimal | Costo total consolidado |
| currency | String | Moneda |
| receiptImageUrl | String | URL de factura |
| receiptNumber | String | Numero de comprobante |
| receivedAt | Instant | Marca de recepcion |
| items | List<PurchaseOrderItemResource> | Lineas de repuestos |

**Ejemplo de Carga Util JSON (Response):**
```json
[
  {
    "id": "018f6c40-7e12-7000-8000-000000000880",
    "tenantId": "018f6c40-7e12-7000-8000-000000000001",
    "supplierId": "018f6c40-7e12-7000-8000-000000000750",
    "supplierName": "DISTRIBUIDORA AUTOMOTRIZ DEL CENTRO S.A.C.",
    "branchId": "018f6c40-7e12-7000-8000-000000000050",
    "orderNumber": "OC-2026-0045",
    "status": "DRAFT",
    "totalCost": 0,
    "currency": "PEN",
    "receiptImageUrl": null,
    "receiptNumber": null,
    "receivedAt": null,
    "items": []
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 401 Unauthorized | BadCredentialsException | Token JWT ausente o expirado |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/unauthorized",
  "title": "Sesion No Autorizada",
  "status": 401,
  "detail": "Se requiere autenticacion para consultar ordenes de compra",
  "instance": "/api/v1/inventory/purchase-orders",
  "code": "UNAUTHORIZED",
  "timestamp": "2026-10-03T16:05:00Z"
}
```

---

### 5.3. [POST] /api/v1/inventory/purchase-orders/{id}/items

**Adicion de Lineas de Repuestos a la Orden de Compra**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.controllers.PurchaseOrdersController`
- **Metodo Java:** `public ResponseEntity<PurchaseOrderResource> addPurchaseOrderItem(@PathVariable UUID id, @Valid @RequestBody AddPurchaseOrderItemResource resource)`
- **Ruta Base:** `/api/v1/inventory/purchase-orders`
- **Ruta Completa:** `/api/v1/inventory/purchase-orders/{id}/items`
- **Proposito:** Agrega un repuesto especifico con su cantidad solicitada y costo unitario pactado a una orden de compra en estado DRAFT. Actualiza de manera automatica el importe total acumulado de la orden.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Encargado de Repuestos (ROLE_INVENTORY_MANAGER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('inventory:purchase_orders:create')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `id` (UUID): Identificador unico de la orden de compra

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.requests.AddPurchaseOrderItemResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| itemId | UUID | Si | @NotNull | Identificador del repuesto en catalogo maestro |
| quantity | BigDecimal | Si | @NotNull, @Positive | Cantidad de unidades requeridas |
| unitCost | BigDecimal | Si | @NotNull, @Positive | Costo unitario pactado sin impuestos |
| currency | String | Si | @NotBlank, @Pattern(regexp = "PEN|USD") | Codigo ISO de la moneda |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "itemId": "018f6c40-7e12-7000-8000-000000000701",
  "quantity": 15,
  "unitCost": 105,
  "currency": "PEN"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Registro Java DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.responses.PurchaseOrderResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador de la orden de compra |
| tenantId | UUID | Identificador del taller |
| supplierId | UUID | Identificador del proveedor |
| supplierName | String | Nombre del proveedor |
| branchId | UUID | Identificador de sucursal |
| orderNumber | String | Numero correlativo |
| status | String | Estado operativo (DRAFT) |
| totalCost | BigDecimal | Nuevo costo consolidado |
| currency | String | Moneda |
| receiptImageUrl | String | URL de factura |
| receiptNumber | String | Numero de comprobante |
| receivedAt | Instant | Marca de recepcion |
| items | List<PurchaseOrderItemResource> | Lineas de repuestos actualizadas |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000880",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "supplierId": "018f6c40-7e12-7000-8000-000000000750",
  "supplierName": "DISTRIBUIDORA AUTOMOTRIZ DEL CENTRO S.A.C.",
  "branchId": "018f6c40-7e12-7000-8000-000000000050",
  "orderNumber": "OC-2026-0045",
  "status": "DRAFT",
  "totalCost": 1575,
  "currency": "PEN",
  "receiptImageUrl": null,
  "receiptNumber": null,
  "receivedAt": null,
  "items": [
    {
      "id": "018f6c40-7e12-7000-8000-000000000885",
      "itemId": "018f6c40-7e12-7000-8000-000000000701",
      "itemName": "Juego de Pastillas Ceramicas Delanteras Bosch",
      "sku": "BRK-PAD-BOSCH-01",
      "quantity": 15,
      "unitCost": 105,
      "totalCost": 1575,
      "currency": "PEN"
    }
  ]
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 400 Bad Request | InvalidPurchaseOrderTransitionException | La orden ya ha sido emitida o recibida y no permite agregar lineas |
| 404 Not Found | PurchaseOrderNotFoundException | La orden de compra no existe |
| 404 Not Found | InventoryItemNotFoundException | El repuesto especificado no existe en el catalogo |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-po-transition",
  "title": "Modificacion de Orden No Permitida",
  "status": 400,
  "detail": "No se pueden incorporar lineas a una orden de compra que se encuentra en estado ISSUED",
  "instance": "/api/v1/inventory/purchase-orders/018f6c40-7e12-7000-8000-000000000880/items",
  "code": "ERR_INVALID_PO_TRANSITION",
  "timestamp": "2026-10-03T16:10:00Z"
}
```

---

### 5.4. [PUT] /api/v1/inventory/purchase-orders/{id}/issue

**Emision Formal de la Orden de Compra al Proveedor**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.controllers.PurchaseOrdersController`
- **Metodo Java:** `public ResponseEntity<PurchaseOrderResource> issuePurchaseOrder(@PathVariable UUID id)`
- **Ruta Base:** `/api/v1/inventory/purchase-orders`
- **Ruta Completa:** `/api/v1/inventory/purchase-orders/{id}/issue`
- **Proposito:** Formaliza y emite la orden de compra al proveedor mayorista. Valida que la orden cuente al menos con un repuesto incorporado y transiciona el estado de DRAFT a ISSUED, bloqueando posteriores modificaciones de lineas.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Encargado de Repuestos (ROLE_INVENTORY_MANAGER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('inventory:purchase_orders:create')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `id` (UUID): Identificador unico de la orden de compra a formalizar

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.responses.PurchaseOrderResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador de la orden |
| tenantId | UUID | Identificador del taller |
| supplierId | UUID | Identificador del proveedor |
| supplierName | String | Nombre del proveedor |
| branchId | UUID | Identificador de sucursal |
| orderNumber | String | Numero correlativo |
| status | String | Nuevo estado operativo (ISSUED) |
| totalCost | BigDecimal | Costo consolidado formalizado |
| currency | String | Moneda |
| receiptImageUrl | String | URL de factura |
| receiptNumber | String | Numero de comprobante |
| receivedAt | Instant | Marca de recepcion |
| items | List<PurchaseOrderItemResource> | Lineas de repuestos |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000880",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "supplierId": "018f6c40-7e12-7000-8000-000000000750",
  "supplierName": "DISTRIBUIDORA AUTOMOTRIZ DEL CENTRO S.A.C.",
  "branchId": "018f6c40-7e12-7000-8000-000000000050",
  "orderNumber": "OC-2026-0045",
  "status": "ISSUED",
  "totalCost": 1575,
  "currency": "PEN",
  "receiptImageUrl": null,
  "receiptNumber": null,
  "receivedAt": null,
  "items": [
    {
      "id": "018f6c40-7e12-7000-8000-000000000885",
      "itemId": "018f6c40-7e12-7000-8000-000000000701",
      "itemName": "Juego de Pastillas Ceramicas Delanteras Bosch",
      "sku": "BRK-PAD-BOSCH-01",
      "quantity": 15,
      "unitCost": 105,
      "totalCost": 1575,
      "currency": "PEN"
    }
  ]
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 400 Bad Request | InvalidPurchaseOrderTransitionException | La orden no se encuentra en estado DRAFT |
| 404 Not Found | PurchaseOrderNotFoundException | La orden de compra no existe |
| 422 Unprocessable Entity | PurchaseOrderEmptyException | No se puede emitir una orden de compra que no contiene lineas de repuestos |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/empty-purchase-order",
  "title": "Orden de Compra Vacia",
  "status": 422,
  "detail": "La orden de compra no cuenta con ningun item agregado para ser emitida formalmente",
  "instance": "/api/v1/inventory/purchase-orders/018f6c40-7e12-7000-8000-000000000880/issue",
  "code": "ERR_EMPTY_PURCHASE_ORDER",
  "timestamp": "2026-10-03T16:15:00Z"
}
```

---

### 5.5. [PUT] /api/v1/inventory/purchase-orders/{id}/receive

**Conformidad de Recepcion con Subida de Factura Escaneada**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.controllers.PurchaseOrdersController`
- **Metodo Java:** `public ResponseEntity<PurchaseOrderResource> receivePurchaseOrder(@PathVariable UUID id, @Valid @RequestBody ReceivePurchaseOrderResource resource)`
- **Ruta Base:** `/api/v1/inventory/purchase-orders`
- **Ruta Completa:** `/api/v1/inventory/purchase-orders/{id}/receive`
- **Proposito:** Registra la recepcion fisica y fiscal de la mercaderia en el almacen del taller. Requiere obligatoriamente el numero de factura o comprobante fiscal y la URL de la fotografia del documento en Firebase Storage. Instancia automaticamente un lote fisico InventoryBatch por cada repuesto recibido bajo el algoritmo FIFO y transiciona la orden a RECEIVED.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Encargado de Repuestos (ROLE_INVENTORY_MANAGER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('inventory:batches:receive')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `id` (UUID): Identificador unico de la orden de compra a recibir

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.requests.ReceivePurchaseOrderResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| receiptImageUrl | String | Si | @NotBlank, @URL | URL segura HTTPS de la factura escaneada en Firebase Storage |
| receiptNumber | String | Si | @NotBlank, @Size(max = 50) | Numero de serie y correlativo de la factura del proveedor |
| receivedAt | Instant | Si | @NotNull | Marca temporal de recepcion fisica de los repuestos |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "receiptImageUrl": "https://firebasestorage.googleapis.com/v0/b/atelier-app.appspot.com/o/tenants%2F018f6c40-7e12-7000-8000-000000000001%2Fpurchase-orders%2Ffactura-f001-9980.jpg?alt=media",
  "receiptNumber": "F001-0009980",
  "receivedAt": "2026-10-03T16:20:00Z"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.responses.PurchaseOrderResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador de la orden de compra |
| tenantId | UUID | Identificador del taller |
| supplierId | UUID | Identificador del proveedor |
| supplierName | String | Nombre del proveedor |
| branchId | UUID | Identificador de sucursal |
| orderNumber | String | Numero correlativo |
| status | String | Nuevo estado operativo (RECEIVED) |
| totalCost | BigDecimal | Costo total de mercaderia ingresada |
| currency | String | Moneda |
| receiptImageUrl | String | URL de factura probatoria |
| receiptNumber | String | Numero de factura validado |
| receivedAt | Instant | Marca temporal de recepcion confirmada |
| items | List<PurchaseOrderItemResource> | Lineas de repuestos |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000880",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "supplierId": "018f6c40-7e12-7000-8000-000000000750",
  "supplierName": "DISTRIBUIDORA AUTOMOTRIZ DEL CENTRO S.A.C.",
  "branchId": "018f6c40-7e12-7000-8000-000000000050",
  "orderNumber": "OC-2026-0045",
  "status": "RECEIVED",
  "totalCost": 1575,
  "currency": "PEN",
  "receiptImageUrl": "https://firebasestorage.googleapis.com/v0/b/atelier-app.appspot.com/o/tenants%2F018f6c40-7e12-7000-8000-000000000001%2Fpurchase-orders%2Ffactura-f001-9980.jpg?alt=media",
  "receiptNumber": "F001-0009980",
  "receivedAt": "2026-10-03T16:20:00Z",
  "items": [
    {
      "id": "018f6c40-7e12-7000-8000-000000000885",
      "itemId": "018f6c40-7e12-7000-8000-000000000701",
      "itemName": "Juego de Pastillas Ceramicas Delanteras Bosch",
      "sku": "BRK-PAD-BOSCH-01",
      "quantity": 15,
      "unitCost": 105,
      "totalCost": 1575,
      "currency": "PEN"
    }
  ]
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 400 Bad Request | InvalidPurchaseOrderTransitionException | La orden debe encontrarse en estado ISSUED para poder recibirse |
| 404 Not Found | PurchaseOrderNotFoundException | La orden de compra no existe |
| 422 Unprocessable Entity | MissingReceiptDocumentationException | Falta la fotografia de la factura o el numero de comprobante fiscal |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/missing-receipt-doc",
  "title": "Documentacion de Recepcion Incompleta",
  "status": 422,
  "detail": "Se requiere adjuntar la URL de la fotografia de la factura para dar conformidad a la recepcion",
  "instance": "/api/v1/inventory/purchase-orders/018f6c40-7e12-7000-8000-000000000880/receive",
  "code": "ERR_MISSING_RECEIPT_DOC",
  "timestamp": "2026-10-03T16:21:00Z"
}
```

---

### 5.6. [PUT] /api/v1/inventory/purchase-orders/{id}/cancel

**Anulacion Justificada de Orden de Compra**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.inventory.interfaces.rest.controllers.PurchaseOrdersController`
- **Metodo Java:** `public ResponseEntity<PurchaseOrderResource> cancelPurchaseOrder(@PathVariable UUID id, @Valid @RequestBody CancelPurchaseOrderResource resource)`
- **Ruta Base:** `/api/v1/inventory/purchase-orders`
- **Ruta Completa:** `/api/v1/inventory/purchase-orders/{id}/cancel`
- **Proposito:** Anula una orden de compra en estado DRAFT o ISSUED antes de la entrega de mercaderia. Registra obligatoriamente el motivo formal de cancelacion y transiciona la orden al estado CANCELLED.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Encargado de Repuestos (ROLE_INVENTORY_MANAGER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('inventory:purchase_orders:cancel')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
- `id` (UUID): Identificador unico de la orden de compra a anular

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.requests.CancelPurchaseOrderResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| reason | String | Si | @NotBlank, @Size(max = 1000) | Motivo justificado de la cancelacion de la orden |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "reason": "Proveedor informo quiebre de stock en planta matriz y demora de sesenta dias en reabastecimiento."
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.inventory.interfaces.rest.resources.responses.PurchaseOrderResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| id | UUID | Identificador de la orden de compra |
| tenantId | UUID | Identificador del taller |
| supplierId | UUID | Identificador del proveedor |
| supplierName | String | Nombre del proveedor |
| branchId | UUID | Identificador de sucursal |
| orderNumber | String | Numero correlativo |
| status | String | Nuevo estado operativo (CANCELLED) |
| totalCost | BigDecimal | Costo total |
| currency | String | Moneda |
| receiptImageUrl | String | URL de factura |
| receiptNumber | String | Numero de comprobante |
| receivedAt | Instant | Marca de recepcion |
| items | List<PurchaseOrderItemResource> | Lineas de repuestos |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000880",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "supplierId": "018f6c40-7e12-7000-8000-000000000750",
  "supplierName": "DISTRIBUIDORA AUTOMOTRIZ DEL CENTRO S.A.C.",
  "branchId": "018f6c40-7e12-7000-8000-000000000050",
  "orderNumber": "OC-2026-0045",
  "status": "CANCELLED",
  "totalCost": 1575,
  "currency": "PEN",
  "receiptImageUrl": null,
  "receiptNumber": null,
  "receivedAt": null,
  "items": []
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :--- | :--- | :--- |
| 400 Bad Request | InvalidPurchaseOrderTransitionException | No se puede cancelar una orden que ya ha alcanzado el estado RECEIVED |
| 404 Not Found | PurchaseOrderNotFoundException | La orden de compra no existe en el taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-po-transition",
  "title": "Anulacion No Permitida",
  "status": 400,
  "detail": "No se puede anular una orden de compra cuya mercaderia ya fue recibida en almacen",
  "instance": "/api/v1/inventory/purchase-orders/018f6c40-7e12-7000-8000-000000000880/cancel",
  "code": "ERR_INVALID_PO_TRANSITION",
  "timestamp": "2026-10-03T16:25:00Z"
}
```

---

