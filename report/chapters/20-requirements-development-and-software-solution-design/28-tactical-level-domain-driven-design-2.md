### 2.6.4. *Bounded Context: Workshop Operations (MRO)*

El Bounded Context de Workshop Operations (MRO - *Maintenance, Repair, and Overhaul*) constituye el motor productivo y operativo central de Atelier Platform. Su alcance comprende la orquestación integral del flujo de trabajo físico y técnico en el taller mecánico, desde la apertura de la orden de reparación tras la recepción del vehículo, hasta la inspección pericial fotográfica, la asignación dinámica de bahías y técnicos, la ejecución secuencial de tareas mecánicas, el registro de consumo de repuestos y la liquidación técnica del servicio.

En la operativa diaria de los talleres automotrices peruanos, la falta de trazabilidad en las reparaciones representa una de las fuentes principales de desconfianza del cliente y colapso administrativo. Los clientes desconocen qué repuestos fueron realmente sustituidos, mientras que los mecánicos pierden horas en asignaciones manuales desorganizadas y sin registro fidedigno de los tiempos reales invertidos.

Para resolver esta problemática, el contexto modela la raíz de agregado `WorkOrder`, la cual gobierna una rigurosa máquina de estados finita:
$$\text{DRAFT} \longrightarrow \text{ASSIGNED} \longrightarrow \text{IN\_PROGRESS} \longrightarrow \text{QUALITY\_CHECK} \longrightarrow \text{COMPLETED} \longrightarrow \text{DELIVERED}$$

Cada orden de trabajo desglosa el trabajo en entidades dependientes `WorkOrderTask`, correspondientes a tareas específicas (ej. cambio de pastillas de freno, afinamiento electrónico, rectificación de discos). A su vez, cada tarea registra los repuestos y fluidos efectivamente consumidos mediante la entidad `WorkOrderTaskProduct`. Cuando un técnico mecánico consume un repuesto en patio, el agregado emite el evento `SparePartConsumedEvent`, el cual es capturado de manera transaccional por el módulo de inventario para desencadenar la deducción del stock bajo el método de costeo FIFO.

Asimismo, el contexto incorpora el patrón *Direct-to-Cloud* para evidencias fotográficas mediante las entidades dependientes `WorkOrderImage` y `WorkOrderTaskImage`. La aplicación móvil del taller sube las fotografías tomadas en foso directamente a los buckets seguros de Firebase Cloud Storage, persistiendo en la base de datos central únicamente las URLs firmadas inmutables y metadatos de peritaje (momento de la toma, fase de inspección, descripción de la avería). Esto salvaguarda la memoria del servidor backend en Render y provee al conductor una prueba visual inalterable del estado de su vehículo antes y después de la intervención.

#### 2.6.4.1. Domain Layer

La capa de dominio de Workshop Operations encapsula la lógica pura de ejecución de servicios, asignación de bahías y control presupuestario. En la @tbl:mro-domain-types se presenta el catálogo de los componentes que integran esta capa.

| Clase o Tipo | Categoría Táctica | Responsabilidad Principal en el Dominio |
| :--- | :--- | :--- |
| `WorkOrder` | Raíz de Agregado | Frontera de consistencia de la reparación; gobierna la máquina de estados, bahía asignada, tareas y costos. |
| `WorkOrderTask` | Entidad Dependiente | Tarea mecánica atómica desglosada con técnico asignado, horas estimadas/reales y estado de ejecución. |
| `WorkOrderTaskProduct` | Entidad Dependiente | Vinculación de un repuesto o insumo consumido en una tarea con cantidad y precio unitario pactado. |
| `WorkOrderImage` | Entidad Dependiente | Metadato de evidencia fotográfica general del vehículo durante la recepción o entrega. |
| `WorkOrderTaskImage` | Entidad Dependiente | Fotografía pericial de una tarea específica (evidencia de falla previa o componente reemplazado). |
| `WorkBay` | Raíz de Agregado | Bahía física de trabajo (elevador, foso, diagnóstico); gestiona su disponibilidad y vehículo en atención. |
| `ServiceCatalogItem` | Raíz de Agregado | Ítem del catálogo tarifario estándar de servicios del taller con tiempos de referencia. |
| `WorkOrderId` | Objeto de Valor | Identificador único universal (`UUID`) fuertemente tipado para órdenes de trabajo. |
| `WorkOrderNumber` | Objeto de Valor | Código correlativo legible y formal de la orden de trabajo (`WO-YYYYMM-XXXX`). |
| `WorkOrderStatus` | Enumeración de Dominio | Estados del ciclo de vida de la orden de trabajo. |
| `WorkBayId` | Objeto de Valor | Identificador único universal (`UUID`) para bahías físicas de taller. |
| `BayType` | Enumeración de Dominio | Tipología funcional de la bahía (`LIFT_2_POST`, `LIFT_4_POST`, `PIT`, `DIAGNOSTIC_BAY`, `GENERAL`). |
| `BayStatus` | Enumeración de Dominio | Estado operativo de la bahía (`AVAILABLE`, `OCCUPIED`, `MAINTENANCE`). |
| `TaskId` | Objeto de Valor | Identificador universal único (`UUID`) para tareas de la orden. |
| `TaskStatus` | Enumeración de Dominio | Estados de ejecución de la tarea (`PENDING`, `IN_PROGRESS`, `COMPLETED`). |
| `LaborHours` | Objeto de Valor | Cantidad de horas hombre de trabajo mecánico expresada como decimal positivo a dos decimales. |
| `EvidenceType` | Enumeración de Dominio | Clasificación pericial de la fotografía (`INITIAL_INSPECTION`, `DEFECT`, `IN_PROGRESS`, `COMPLETED`). |
| `StorageUrl` | Objeto de Valor | Dirección URL firmada HTTPS que apunta al recurso multimedia en Firebase Cloud Storage. |
| `ServiceId` | Objeto de Valor | Identificador único universal (`UUID`) para servicios del catálogo. |
| `WorkOrderCostCalculator` | Servicio de Dominio | Calcula el costo acumulado de la orden sumando importes de mano de obra y repuestos consumidos. |
| `BayAllocationService` | Servicio de Dominio | Valida la disponibilidad física de bahías impidiendo sobreasignaciones vehiculares. |
| `WorkOrderTransitionValidator` | Servicio de Dominio | Impone la inviolabilidad de las transiciones permitidas en la máquina de estados. |
| `WorkOrderRepository` | Puerto de Salida | Contrato de persistencia de dominio para la Raíz de Agregado `WorkOrder`. |
| `WorkBayRepository` | Puerto de Salida | Contrato de persistencia de dominio para la Raíz de Agregado `WorkBay`. |
| `ServiceCatalogRepository` | Puerto de Salida | Contrato de persistencia de dominio para la Raíz de Agregado `ServiceCatalogItem`. |
| `WorkOrderCreatedEvent` | Evento de Dominio | Notifica la creación y apertura inicial de una orden de trabajo. |
| `WorkOrderAssignedEvent` | Evento de Dominio | Notifica la asignación de la orden a una bahía y a un técnico mecánico responsable. |
| `WorkOrderStartedEvent` | Evento de Dominio | Notifica el inicio formal de las labores mecánicas sobre el vehículo. |
| `TaskCompletedEvent` | Evento de Dominio | Notifica la finalización satisfactoria de una tarea mecánica individual. |
| `SparePartConsumedEvent` | Evento de Dominio | Notifica el consumo de un repuesto en foso para su deducción en inventario vía FIFO. |
| `WorkOrderCompletedEvent` | Evento de Dominio | Notifica la culminación de todos los trabajos y la aprobación del control de calidad. |
| `WorkOrderDeliveredEvent` | Evento de Dominio | Notifica la entrega formal del vehículo al cliente y cierre definitivo de la orden. |
: Catálogo de Tipos de Dominio del Bounded Context Workshop Operations (MRO) {#tbl:mro-domain-types}

*Nota.* Componentes tácticos del paquete canónico com.andeva.atelier.platform.operations.domain.

**Raíces de Agregado y Entidades Dependientes de Workshop Operations**

1. `WorkOrder`: Actúa como la raíz de agregado que garantiza la consistencia del flujo de reparación. Encapsula las entidades hijas `WorkOrderTask`, `WorkOrderTaskProduct` y las imágenes de peritaje. Controla las precondiciones de cada transición: una orden no puede pasar a `COMPLETED` si contiene tareas pendientes, ni puede entregarse (`DELIVERED`) si no ha sido completada satisfactoriamente.

| Elemento | Tipo o Firma | Ámbito | Descripción y Reglas de Negocio |
| :--- | :--- | :---: | :--- |
| `id` | `WorkOrderId` | Privado | Identificador único universal de la orden de trabajo. |
| `tenantId` | `TenantId` | Privado | Identificador del taller propietario de la orden. |
| `branchId` | `BranchId` | Privado | Sede física donde se ejecuta la reparación. |
| `workOrderNumber` | `WorkOrderNumber` | Privado | Código correlativo legible formateado. |
| `customerId` | `CustomerId` | Privado | Cliente propietario del vehículo intervenido. |
| `vehicleId` | `VehicleId` | Privado | Vehículo sobre el cual se ejecutan los trabajos. |
| `workBayId` | `WorkBayId` | Privado | Bahía física asignada para la atención. |
| `assignedTechnicianId`| `UserId` | Privado | Mecánico principal responsable de la orden. |
| `status` | `WorkOrderStatus` | Privado | Estado actual en la máquina de estados. |
| `tasks` | `List<WorkOrderTask>` | Privado | Desglose de tareas mecánicas que componen el servicio. |
| `images` | `List<WorkOrderImage>` | Privado | Evidencias fotográficas de recepción y entrega. |
| `subtotal` | `Money` | Privado | Importe acumulado de mano de obra y repuestos antes de impuestos. |
| `tax` | `Money` | Privado | Monto de impuesto IGV correspondiente. |
| `total` | `Money` | Privado | Monto total liquidado de la orden. |
| `create` | `static WorkOrder create(...)` | Público | Factoría que inicializa la orden en `DRAFT` y emite `WorkOrderCreatedEvent`. |
| `assignToBayAndTechnician`| `void assignToBayAndTechnician(...)`| Público | Asocia bahía y técnico responsable, transicionando a `ASSIGNED`. |
| `startWork` | `void startWork()` | Público | Transiciona a `IN_PROGRESS` y emite `WorkOrderStartedEvent`. |
| `addTask` | `WorkOrderTask addTask(...)` | Público | Incorpora una nueva tarea mecánica al plan de trabajo. |
| `consumeSparePart` | `void consumeSparePart(...)` | Público | Registra el uso de un repuesto en una tarea y emite `SparePartConsumedEvent`. |
| `completeWorkOrder`| `void completeWorkOrder()` | Público | Valida finalización de todas las tareas, calcula totales y transiciona a `COMPLETED`. |
| `deliverVehicle` | `void deliverVehicle()` | Público | Transiciona a `DELIVERED` y emite `WorkOrderDeliveredEvent`. |
: Miembros de la Raíz de Agregado WorkOrder {#tbl:mro-workorder-members}

*Nota.* Especificación de miembros de la raíz de agregado WorkOrder del paquete com.andeva.atelier.platform.operations.domain.model.aggregates.

En cuanto a sus relaciones, `WorkOrder` hereda de `AbstractDomainAggregateRoot<WorkOrder>` y mantiene relaciones de composición 1 a N con `WorkOrderTask` y `WorkOrderImage`. Mantiene referencias por identificador (`CustomerId`, `VehicleId`, `WorkBayId`, `UserId`) hacia otros agregados.

2. `WorkOrderTask`: Modela una tarea mecánica específica dentro de la orden. Gestiona su propio técnico ejecutante, las horas hombre requeridas (`LaborHours`), su estado de avance y la lista de repuestos consumidos (`WorkOrderTaskProduct`). Provee métodos para iniciar la labor, registrar fotografías de evidencia (`WorkOrderTaskImage`) y marcar la culminación de la tarea emitiendo `TaskCompletedEvent`.

| Elemento | Tipo o Firma | Ámbito | Descripción y Reglas de Negocio |
| :--- | :--- | :---: | :--- |
| `id` | `TaskId` | Privado | Identificador universal único de la tarea. |
| `workOrderId` | `WorkOrderId` | Privado | Orden de trabajo a la que pertenece. |
| `description` | `String` | Privado | Descripción técnica del procedimiento mecánico. |
| `technicianId` | `UserId` | Privado | Mecánico asignado específicamente a esta labor. |
| `estimatedHours` | `LaborHours` | Privado | Tiempo presupuestado para la ejecución. |
| `actualHours` | `LaborHours` | Privado | Tiempo real insumido tras la culminación. |
| `status` | `TaskStatus` | Privado | Estado de la tarea (`PENDING`, `IN_PROGRESS`, `COMPLETED`). |
| `products` | `List<WorkOrderTaskProduct>` | Privado | Repuestos e insumos consumidos en esta tarea. |
| `images` | `List<WorkOrderTaskImage>` | Privado | Fotografías de respaldo del componente reparado. |
| `startTask` | `void startTask()` | Público | Transiciona a `IN_PROGRESS` marcando inicio de labores. |
| `completeTask` | `void completeTask(LaborHours actual)`| Público | Registra tiempo final, transiciona a `COMPLETED` y emite evento. |
| `addProduct` | `void addProduct(WorkOrderTaskProduct p)`| Público | Asocia un repuesto consumido a la tarea. |
: Miembros de la Entidad Dependiente WorkOrderTask {#tbl:mro-task-members}

*Nota.* Especificación de miembros de la entidad WorkOrderTask del paquete com.andeva.atelier.platform.operations.domain.model.entities.

3. `WorkBay`: Raíz de agregado que representa una estación o espacio físico de trabajo en patio (elevador de dos columnas, foso de alineación, zona de diagnóstico). Controla su disponibilidad operativa a través del estado `BayStatus`. Prohíbe que una bahía en estado `OCCUPIED` o `MAINTENANCE` sea reasignada a un nuevo vehículo, garantizando que el flujo físico en el taller no genere cuellos de botella.

| Elemento | Tipo o Firma | Ámbito | Descripción y Reglas de Negocio |
| :--- | :--- | :---: | :--- |
| `id` | `WorkBayId` | Privado | Identificador universal de la bahía. |
| `tenantId` | `TenantId` | Privado | Taller al que pertenece la instalación. |
| `branchId` | `BranchId` | Privado | Sucursal física donde se localiza la bahía. |
| `name` | `String` | Privado | Denominación visual de la bahía (ej. "Bahía 1 - Elevador 2 Postes"). |
| `type` | `BayType` | Privado | Tipología técnica de la bahía. |
| `status` | `BayStatus` | Privado | Estado de ocupación actual (`AVAILABLE`, `OCCUPIED`, `MAINTENANCE`). |
| `currentVehicleId` | `VehicleId` | Privado | Vehículo que se encuentra ocupando físicamente la estación. |
| `occupy` | `void occupy(VehicleId vehicleId)` | Público | Asigna la bahía al vehículo cambiando su estado a `OCCUPIED`. |
| `release` | `void release()` | Público | Libera la estación restaurando su estado a `AVAILABLE`. |
| `setMaintenance` | `void setMaintenance()` | Público | Inhabilita la bahía por calibración o mantenimiento preventivo. |
: Miembros de la Raíz de Agregado WorkBay {#tbl:mro-bay-members}

*Nota.* Especificación de miembros del agregado WorkBay del paquete com.andeva.atelier.platform.operations.domain.model.aggregates.

**Objetos de Valor de Workshop Operations**

| Objeto de Valor | Atributos Clave | Restricciones de Validación y Reglas de Negocio |
| :--- | :--- | :--- |
| `WorkOrderNumber` | `value`: `String` | Expresión regular `^WO-[0-9]{6}-[0-9]{4}$`, inmutable y único por taller. |
| `LaborHours` | `value`: `BigDecimal` | Escala fija de 2 decimales, valor estrictamente positivo ($> 0.00$). |
| `StorageUrl` | `value`: `String` | URL segura HTTPS validada proveniente de Firebase Cloud Storage. |
| `ServiceName` | `value`: `String` | Denominación no vacía de longitud de 3 a 100 caracteres. |
| `BasePrice` | `value`: `Money` | Tarifa base de mano de obra no negativa ($\ge 0.00$). |
: Objetos de Valor del Bounded Context Workshop Operations {#tbl:mro-value-objects}

*Nota.* Especificación de Objetos de Valor del paquete com.andeva.atelier.platform.operations.domain.model.valueobjects.

**Servicios de Dominio de Workshop Operations**

1. `WorkOrderCostCalculator`: Orquesta el recálculo financiero de la orden de trabajo. Suma el costo total de mano de obra (obtenido multiplicando las horas reales de cada tarea por la tarifa horaria pactada) y el costo total de los repuestos consumidos. Aplica la alícuota del impuesto general a las ventas (IGV 18%) mediante redondeo bancario `RoundingMode.HALF_EVEN`, actualizando atómicamente los campos `subtotal`, `tax` y `total` en la orden de trabajo.
2. `BayAllocationService`: Servicio de validación que consulta el estado operativo de las bahías en la sucursal. Impide que una orden de trabajo sea asignada a una bahía cuyo estado no sea `AVAILABLE` o cuya capacidad física no admita la tipología del vehículo atendido.
3. `WorkOrderTransitionValidator`: Valida que cada cambio de estado respete la máquina de estados secuencial, rechazando transiciones anómalas (como intentar entregar un vehículo en estado borrador) y verificando que se cumplan las precondiciones operativas exigidas por la empresa.

**Puertos de Repositorio de la Capa de Dominio**

| Puerto de Repositorio | Métodos Principales | Responsabilidad de Dominio |
| :--- | :--- | :--- |
| `WorkOrderRepository` | `save`, `findById`, `findByOrderNumber`, `findActiveByBranchId` | Persistencia y recuperación de órdenes de trabajo. |
| `WorkBayRepository` | `save`, `findById`, `findByBranchIdAndStatus`, `findAvailable` | Consulta y gestión de bahías operativas. |
| `ServiceCatalogRepository` | `save`, `findById`, `findByTenantIdAndActive`, `findByName` | Catálogo maestro de servicios y tarifas del taller. |
: Puertos de Repositorio del Bounded Context Workshop Operations {#tbl:mro-repository-ports}

*Nota.* Interfaces de salida del paquete com.andeva.atelier.platform.operations.domain.repositories.

**Eventos de Dominio y Manejo de Errores Semánticos**

Los eventos de dominio emitidos por MRO sincronizan la cadena de valor operativa:
* `WorkOrderCreatedEvent`: Notifica la creación de la orden para preparar la bahía de recepción.
* `WorkOrderAssignedEvent`: Alerta al técnico mecánico en su dispositivo móvil sobre la asignación de la orden.
* `SparePartConsumedEvent`: Despacha un evento transaccional con el código del repuesto y cantidad consumida para que el módulo de inventario efectúe el descuento inmediato bajo el método FIFO.
* `WorkOrderCompletedEvent`: Habilita al módulo de facturación para la emisión del comprobante tributario.
* `WorkOrderDeliveredEvent`: Notifica la salida del vehículo del patio del taller, liberando definitivamente la bahía y cerrando el ciclo MRO.

Las condiciones excepcionales se controlan mediante `Result<T, ApplicationError>` y excepciones semánticas de dominio (`WorkOrderNotFoundException`, `WorkBayOccupiedException`, `InvalidWorkOrderStatusTransitionException`).



#### 2.6.4.2. Interface Layer



#### 2.6.4.3. Application Layer



#### 2.6.4.4 Infrastructure Layer



#### 2.6.4.5. Bounded Context Software Architecture Component Level Diagrams



#### 2.6.4.6. Bounded Context Software Architecture Code Level Diagrams



##### 2.6.4.6.1. *Bounded Context Domain Layer Class Diagrams*



##### 2.6.4.6.2. *Bounded Context Database Design Diagram*



### 2.6.5. *Bounded Context: Inventory & Supply Chain*

El Bounded Context de Inventory & Supply Chain gestiona el abastecimiento logístico, el control físico de existencias y la valuación de almacén en Atelier Platform. Su alcance abarca la administración del catálogo de repuestos, lubricantes e insumos mecánicos, la valuación de inventario bajo el método contable de costeo FIFO (*First-In, First-Out*) por lotes físicos de adquisición, el directorio comercial de proveedores y la orquestación de órdenes de compra con control documental.

En la industria del mantenimiento y reparación automotriz, la gestión deficiente de almacenes constituye una de las principales causas de pérdida de rentabilidad y fuga silenciosa de capital. Muchos talleres tradicionales operan sin un método estandarizado de costeo de inventario, aplicando precios promedio empíricos o asumiendo el último costo de compra reportado. Esta práctica desvirtúa el cálculo del margen real de beneficio, especialmente en contextos inflacionarios donde el costo de adquisición de repuestos automotrices fluctúa constantemente.

Para erradicar esta vulnerabilidad financiera, Atelier implementa a nivel de dominio el algoritmo de asignación y costeo FIFO mediante la raíz de agregado `InventoryItem` y sus entidades dependientes `InventoryBatch`. Cada lote físico recibido almacena su fecha de ingreso, su costo unitario de compra inalterable y su saldo remanente disponible. Cuando una orden de trabajo consume repuestos, el motor algorítmico del dominio deduce las existencias agotando prioritariamente los lotes de adquisición más antiguos, garantizando que el costo de venta liquidado en la orden MRO refleje el desembolso financiero histórico real del taller.

Adicionalmente, el contexto modela el ciclo de reabastecimiento a través de las raíces de agregado `Supplier` (directorio de distribuidores y fabricantes) y `PurchaseOrder` (órdenes formales de compra con desglose de ítems cotizados). La recepción física de una orden de compra aprobada desencadena automáticamente el alta de nuevos lotes en los ítems de inventario correspondientes, asegurando trazabilidad integral de compra a consumo.

#### 2.6.5.1. Domain Layer

La capa de dominio de Inventory & Supply Chain encapsula la lógica matemática de costeo por lotes y las reglas de reabastecimiento de existencias. En la @tbl:inventory-domain-types se presenta el catálogo de los componentes que integran esta capa.

| Clase o Tipo | Categoría Táctica | Responsabilidad Principal en el Dominio |
| :--- | :--- | :--- |
| `InventoryItem` | Raíz de Agregado | Catálogo maestro de repuestos y fluidos; gestiona umbrales de reorden, stock total y lotes de compra. |
| `InventoryBatch` | Entidad Dependiente | Lote físico de adquisición que encapsula costo unitario de compra inmutable, fecha y saldo remanente. |
| `Supplier` | Raíz de Agregado | Ficha comercial del proveedor automotriz; gestiona RUC, razón social, contactos y condiciones de pago. |
| `PurchaseOrder` | Raíz de Agregado | Orden formal de compra emitida a un proveedor; gobierna su ciclo de aprobación y recepción de piezas. |
| `PurchaseOrderItem` | Entidad Dependiente | Línea de detalle de orden de compra que asocia un ítem solicitado con cantidad y costo unitario pactado. |
| `ItemId` | Objeto de Valor | Identificador único universal (`UUID`) fuertemente tipado para ítems de inventario. |
| `BatchId` | Objeto de Valor | Identificador único universal (`UUID`) para lotes de adquisición. |
| `SupplierId` | Objeto de Valor | Identificador único universal (`UUID`) para proveedores automotrices. |
| `PurchaseOrderId` | Objeto de Valor | Identificador único universal (`UUID`) para órdenes de compra. |
| `Sku` | Objeto de Valor | Código alfanumérico formal de mantenimiento de inventario (`^[A-Z0-9]{4,12}$`). |
| `PartNumber` | Objeto de Valor | Código de parte original OEM o de fabricante alternativo (aftermarket). |
| `ItemCategory` | Enumeración de Dominio | Clasificación funcional del ítem (`SPARE_PART`, `FLUID`, `CONSUMABLE`, `TOOL`). |
| `StockQuantity` | Objeto de Valor | Cantidad entera no negativa ($\ge 0$) que modela existencias físicas o demandas de despacho. |
| `BatchNumber` | Objeto de Valor | Código correlativo de lote físico emitido durante la recepción en almacén (`BATCH-YYYYMM-XXXX`). |
| `PurchaseOrderStatus` | Enumeración de Dominio | Estados de la orden de compra (`DRAFT`, `SUBMITTED`, `APPROVED`, `RECEIVED`, `CANCELLED`). |
| `FifoAllocationEngine` | Servicio de Dominio | Motor algorítmico que ejecuta el consumo secuencial por lotes más antiguos y calcula el costo real de salida. |
| `StockReorderEvaluationService` | Servicio de Dominio | Evalúa si las existencias de un ítem han caído por debajo de su umbral mínimo emitiendo alertas de compra. |
| `InventoryItemRepository` | Puerto de Salida | Contrato de persistencia de dominio para la Raíz de Agregado `InventoryItem`. |
| `SupplierRepository` | Puerto de Salida | Contrato de persistencia de dominio para la Raíz de Agregado `Supplier`. |
| `PurchaseOrderRepository` | Puerto de Salida | Contrato de persistencia de dominio para la Raíz de Agregado `PurchaseOrder`. |
| `InventoryStockReceivedEvent` | Evento de Dominio | Notifica el ingreso de un nuevo lote físico a almacén incrementando el stock disponible. |
| `FifoStockDeductedEvent` | Evento de Dominio | Notifica la deducción exitosa de existencias reportando el costo financiero consolidado de salida. |
| `StockLowThresholdReachedEvent` | Evento de Dominio | Notifica que un ítem ha alcanzado su nivel crítico de reorden para disparar la reposición. |
| `PurchaseOrderApprovedEvent` | Evento de Dominio | Notifica la validación formal de una orden de compra habilitando su despacho por el proveedor. |
| `PurchaseOrderReceivedEvent` | Evento de Dominio | Notifica la recepción física conforme de las piezas y el alta automática de lotes en inventario. |
: Catálogo de Tipos de Dominio del Bounded Context Inventory & Supply Chain {#tbl:inventory-domain-types}

*Nota.* Componentes tácticos del paquete canónico com.andeva.atelier.platform.inventory.domain.

**Raíces de Agregado y Entidades Dependientes de Inventory & Supply Chain**

1. `InventoryItem`: Raíz de agregado que encapsula la identidad física y comercial del repuesto o fluido. Gestiona su código de control interno `Sku`, código de parte del fabricante `PartNumber` y umbral de seguridad `minStockThreshold`. El agregado mantiene la lista de entidades dependientes `InventoryBatch`. Prohíbe mutaciones directas arbitrarias de stock, obligando a que cualquier adición se efectúe mediante `receiveBatch` y cualquier egreso a través del servicio de asignación FIFO, garantizando que la suma del stock disponible coincida siempre con la suma exacta de los saldos remanentes de sus lotes activos.

| Elemento | Tipo o Firma | Ámbito | Descripción y Reglas de Negocio |
| :--- | :--- | :---: | :--- |
| `id` | `ItemId` | Privado | Identificador universal único del repuesto o insumo. |
| `tenantId` | `TenantId` | Privado | Taller propietario del inventario. |
| `sku` | `Sku` | Privado | Código alfanumérico interno normalizado. |
| `partNumber` | `PartNumber` | Privado | Código de parte del fabricante OEM o alternativo. |
| `name` | `String` | Privado | Denominación técnica y comercial del producto. |
| `category` | `ItemCategory` | Privado | Clasificación del ítem (`SPARE_PART`, `FLUID`, etc.). |
| `minStockThreshold` | `StockQuantity` | Privado | Nivel mínimo de existencias de seguridad. |
| `batches` | `List<InventoryBatch>` | Privado | Colección de lotes físicos de adquisición activos e históricos. |
| `create` | `static InventoryItem create(...)` | Público | Factoría constructora que registra el ítem sin existencias iniciales. |
| `receiveBatch` | `InventoryBatch receiveBatch(...)` | Público | Registra un nuevo lote físico con su costo de adquisición y emite evento. |
| `getTotalAvailableStock`| `StockQuantity getTotalAvailableStock()`| Público | Calcula la sumatoria en tiempo real de saldos de lotes activos. |
| `isLowStock` | `boolean isLowStock()` | Público | Determina si el stock total es inferior o igual al umbral mínimo. |
| `updateThreshold` | `void updateThreshold(StockQuantity min)`| Público | Ajusta el umbral de reorden de seguridad. |
: Miembros de la Raíz de Agregado InventoryItem {#tbl:inventory-item-members}

*Nota.* Especificación de miembros del agregado InventoryItem del paquete com.andeva.atelier.platform.inventory.domain.model.aggregates.

En cuanto a sus relaciones, `InventoryItem` hereda de `AbstractDomainAggregateRoot<InventoryItem>` y mantiene una relación de composición 1 a N con la entidad dependiente `InventoryBatch`.

2. `InventoryBatch`: Entidad dependiente que modela un lote físico individual adquirido mediante una compra específica. Cada lote almacena de forma inmutable su fecha de recepción `receptionDate` y su precio unitario de adquisición `purchasePrice`. El atributo `remainingQuantity` modela el saldo de piezas disponibles en el lote, el cual se decrementa conforme el taller consume repuestos en sus órdenes de trabajo. Cuando `remainingQuantity == 0`, el lote queda agotado para futuros despachos, pero se preserva en el agregado para fines de auditoría contable histórica.

| Elemento | Tipo o Firma | Ámbito | Descripción y Reglas de Negocio |
| :--- | :--- | :---: | :--- |
| `id` | `BatchId` | Privado | Identificador universal único del lote. |
| `itemId` | `ItemId` | Privado | Ítem de inventario al que pertenece el lote. |
| `batchNumber` | `BatchNumber` | Privado | Código correlativo identificador del lote físico. |
| `purchasePrice` | `Money` | Privado | Costo unitario de compra inmutable en moneda local. |
| `initialQuantity`| `StockQuantity` | Privado | Cantidad original adquirida al ingresar el lote. |
| `remainingQuantity`| `StockQuantity` | Privado | Cantidad remanente disponible para consumo. |
| `receptionDate` | `LocalDate` | Privado | Fecha cronológica de ingreso físico a almacén. |
| `deductQuantity` | `void deductQuantity(StockQuantity qty)`| Público | Decrementa el saldo disponible validando no sobrepasar el remanente. |
| `isDepleted` | `boolean isDepleted()` | Público | Indica si el lote ha consumido la totalidad de sus existencias. |
: Miembros de la Entidad Dependiente InventoryBatch {#tbl:inventory-batch-members}

*Nota.* Especificación de miembros de la entidad InventoryBatch del paquete com.andeva.atelier.platform.inventory.domain.model.entities.

3. `Supplier`: Raíz de agregado que modela al proveedor de piezas y lubricantes. Impone que la empresa proveedora cuente con un número de RUC de 11 dígitos validado formalmente mediante el algoritmo Módulo 11 de SUNAT, garantizando que el taller solo emita órdenes de compra hacia empresas legalmente constituidas.

| Elemento | Tipo o Firma | Ámbito | Descripción y Reglas de Negocio |
| :--- | :--- | :---: | :--- |
| `id` | `SupplierId` | Privado | Identificador universal único del proveedor. |
| `tenantId` | `TenantId` | Privado | Taller que registra al proveedor en su directorio. |
| `ruc` | `RucNumber` | Privado | RUC del proveedor validado ante SUNAT. |
| `legalName` | `String` | Privado | Razón social oficial del proveedor. |
| `commercialName`| `String` | Privado | Nombre de marca o denominación comercial. |
| `contact` | `ContactInfo` | Privado | Datos de contacto para despacho de cotizaciones y pedidos. |
| `paymentTermsDays`| `int` | Privado | Plazo comercial de crédito acordado en días ($\ge 0$). |
| `isActive` | `boolean` | Privado | Estado operativo de la relación comercial con el proveedor. |
| `updateTerms` | `void updateTerms(int days)` | Público | Modifica los términos de crédito comercial pactados. |
| `deactivate` | `void deactivate()` | Público | Suspende comercialmente al proveedor para nuevas compras. |
: Miembros de la Raíz de Agregado Supplier {#tbl:inventory-supplier-members}

*Nota.* Especificación de miembros del agregado Supplier del paquete com.andeva.atelier.platform.inventory.domain.model.aggregates.

4. `PurchaseOrder`: Raíz de agregado que formaliza la adquisición de repuestos hacia un proveedor. Encapsula la lista de líneas `PurchaseOrderItem`, valida que contenga al menos un ítem al aprobarse y gobierna el flujo de estados `DRAFT` $\to$ `SUBMITTED` $\to$ `APPROVED` $\to$ `RECEIVED`. Al transicionar a `RECEIVED`, el agregado emite `PurchaseOrderReceivedEvent`, lo que instruye al sistema para poblar los nuevos lotes de existencias en el inventario del taller.

**Objetos de Valor de Inventory & Supply Chain**

| Objeto de Valor | Atributos Clave | Restricciones de Validación y Reglas de Negocio |
| :--- | :--- | :--- |
| `Sku` | `value`: `String` | Formato alfanumérico en mayúsculas sin espacios (`^[A-Z0-9]{4,12}$`). |
| `PartNumber` | `value`: `String` | Código de parte alfanumérico no vacío de longitud entre 2 y 40 caracteres. |
| `StockQuantity` | `value`: `int` | Entero positivo o cero ($\ge 0$). Rechaza cantidades negativas. |
| `BatchNumber` | `value`: `String` | Expresión regular `^BATCH-[0-9]{6}-[0-9]{4}$`, único por taller. |
| `PurchaseOrderNumber`| `value`: `String` | Código formal correlativo de orden de compra (`^PO-[0-9]{6}-[0-9]{4}$`). |
: Objetos de Valor del Bounded Context Inventory & Supply Chain {#tbl:inventory-value-objects}

*Nota.* Especificación de Objetos de Valor del paquete com.andeva.atelier.platform.inventory.domain.model.valueobjects.

**Servicios de Dominio de Inventory & Supply Chain**

1. `FifoAllocationEngine`: Constituye el motor algorítmico medular del inventario automotriz. Cuando una orden de trabajo solicita consumir una cantidad $Q_{\text{req}}$ de un repuesto determinado, el servicio ejecuta el siguiente procedimiento matemático puro:
   * Recupera todos los lotes activos del ítem con saldo remanente positivo ($remainingQuantity > 0$).
   * Ordena los lotes cronológicamente de forma ascendente por su fecha de recepción (`receptionDate ASC`), garantizando la prioridad de consumo más antiguo (*First-In*).
   * Itera sobre cada lote $B_i$, calculando la cuota consumida de dicho lote como $q_i = \min(Q_{\text{pendiente}}, B_{i}.\text{remainingQuantity})$.
   * Calcula el costo financiero real de la cuota como $C_i = q_i \times B_{i}.\text{purchasePrice}$.
   * Aplica el descuento atómico sobre el lote ($B_{i}.\text{deductQuantity}(q_i)$) y acumula el costo total consolidado de salida:
     $$C_{\text{total}} = \sum_{i=1}^{k} \left( q_i \times B_{i}.\text{purchasePrice} \right)$$
   * Invariante de saldo suficiente: Si la sumatoria total del stock remanente de todos los lotes disponibles es estrictamente menor a la cantidad solicitada ($\sum B_i < Q_{\text{req}}$), el servicio aborta la operación de forma atómica y arroja la excepción de dominio `InsufficientStockException`, impidiendo inventarios negativos.
   * Tras la asignación exitosa, registra el evento `FifoStockDeductedEvent` reportando las cuotas descontadas por lote y el costo financiero exacto del egreso.

2. `StockReorderEvaluationService`: Evalúa el nivel de existencias físicas tras cada egreso de almacén. Si el stock disponible resultante es menor o igual al `minStockThreshold` del ítem, el servicio emite `StockLowThresholdReachedEvent`, facilitando la generación proactiva de borradores de órdenes de compra para prevenir desabastecimientos en taller.

**Puertos de Repositorio de la Capa de Dominio**

| Puerto de Repositorio | Métodos Principales | Responsabilidad de Dominio |
| :--- | :--- | :--- |
| `InventoryItemRepository`| `save`, `findById`, `findBySku`, `findByPartNumber`, `findLowStockItems` | Persistencia y consulta de ítems y lotes de inventario. |
| `SupplierRepository` | `save`, `findById`, `findByRuc`, `findByTenantIdAndActive` | Directorio de proveedores homologados del taller. |
| `PurchaseOrderRepository`| `save`, `findById`, `findByOrderNumber`, `findBySupplierId` | Gestión y seguimiento de órdenes de compra. |
: Puertos de Repositorio del Bounded Context Inventory & Supply Chain {#tbl:inventory-repository-ports}

*Nota.* Interfaces de salida del paquete com.andeva.atelier.platform.inventory.domain.repositories.

**Eventos de Dominio y Manejo de Errores Semánticos**

Los eventos de dominio de inventario permiten coordinar el abastecimiento y la contabilidad interna:
* `InventoryStockReceivedEvent`: Notifica el alta de un nuevo lote físico incrementando las existencias del taller.
* `FifoStockDeductedEvent`: Transporta el costo real de adquisición liquidado para su imputación contable en la orden MRO.
* `StockLowThresholdReachedEvent`: Alerta al personal de adquisiciones sobre repuestos en estado crítico.
* `PurchaseOrderApprovedEvent`: Habilita el despacho formal hacia el distribuidor.
* `PurchaseOrderReceivedEvent`: Dispara la recepción física y la instanciación de lotes en el catálogo.

Las violaciones de invariantes se gestionan mediante `Result<T, ApplicationError>` y excepciones tipadas (`InsufficientStockException`, `BatchDepletedException`, `DuplicateSkuException`).



#### 2.6.5.2. Interface Layer



#### 2.6.5.3. Application Layer



#### 2.6.5.4 Infrastructure Layer



#### 2.6.5.5. Bounded Context Software Architecture Component Level Diagrams



#### 2.6.5.6. Bounded Context Software Architecture Code Level Diagrams



##### 2.6.5.6.1. *Bounded Context Domain Layer Class Diagrams*



##### 2.6.5.6.2. *Bounded Context Database Design Diagram*



### 2.6.6. *Bounded Context: Human Resources Management (HR)*

El Bounded Context de Human Resources Management (HR) gestiona el capital humano y la fuerza laboral de los talleres automotrices en Atelier Platform. Su alcance de dominio abarca el expediente laboral y perfil técnico de los colaboradores (`EmployeeProfile`), la planificación y asignación de turnos laborales (`WorkShift`), el control de asistencia presencial verificado mediante geocercas GPS circulares (`AttendanceRecord`), y la liquidación de nóminas salariales (`PayrollPayment`) integrando esquemas meritocráticos de compensación por productividad.

En el contexto socioeconómico del sector de reparación automotriz peruano, caracterizado por una informalidad laboral superior al 70%, la rotación de mecánicos calificados y la falta de transparencia en el pago de remuneraciones representan trabas críticas para la profesionalización del taller. Muchos técnicos perciben que sus esfuerzos extraordinarios no son reconocidos, mientras que los dueños de taller carecen de herramientas para certificar si el personal se encuentra físicamente en patio durante su jornada contratada.

Para transformar esta realidad, el contexto de Recursos Humanos introduce dos capacidades de dominio:
1. **Control de Asistencia Georreferenciado:** Mediante la raíz de agregado `AttendanceRecord` y el servicio de dominio `HaversineGeofencingService`, el sistema valida la presencia física del operario en el taller al momento de marcar entrada o salida desde su teléfono móvil. Las coordenadas satelitales WGS84 provistas por el dispositivo se contrastan contra el centroide y radio perimetral de la sucursal asignada ($\le 150$ metros). Si la distancia excede el radio autorizado, el registro se clasifica como fuera de perímetro (`REJECTED_OUTSIDE_GEOFENCE`), impidiendo suplantaciones de identidad.
2. **Liquidación Meritocrática de Nóminas:** A través del agregado `PayrollPayment`, el sistema no se limita a calcular salarios fijos, sino que procesa las órdenes de trabajo cerradas satisfactoriamente por cada mecánico en el módulo de MRO, calculando bonificaciones objetivas y meritocráticas basadas en el cumplimiento de tiempos estándar y volumen de vehículos atendidos.

#### 2.6.6.1. Domain Layer

La capa de dominio de Human Resources Management encapsula las reglas de jornada laboral, cálculos trigonométricos de proximidad física y liquidación de remuneraciones. En la @tbl:hr-domain-types se presenta el catálogo de los componentes que integran esta capa.

| Clase o Tipo | Categoría Táctica | Responsabilidad Principal en el Dominio |
| :--- | :--- | :--- |
| `EmployeeProfile` | Raíz de Agregado | Ficha profesional del colaborador; gestiona especialidades mecánicas, certificaciones y fecha de ingreso. |
| `WorkShift` | Raíz de Agregado | Horario planificado de trabajo asignado a colaboradores en una sucursal; define horas de entrada, salida y tolerancias. |
| `AttendanceRecord` | Raíz de Agregado | Marcación física de jornada; encapsula coordenadas GPS capturadas, distancia calculada a la sede y estado de validez. |
| `PayrollPayment` | Raíz de Agregado | Liquidación salarial periódica; consolida sueldo base, bonos por órdenes MRO, deducciones y conceptos desglosados. |
| `PayrollItem` | Entidad Dependiente | Concepto individual que compone la nómina (bonificación, retención tributaria, compensación por horas extra). |
| `EmployeeId` | Objeto de Valor | Identificador único universal (`UUID`) fuertemente tipado para expedientes de empleados. |
| `ShiftId` | Objeto de Valor | Identificador único universal (`UUID`) para turnos laborales. |
| `AttendanceId` | Objeto de Valor | Identificador único universal (`UUID`) para registros de asistencia. |
| `PayrollId` | Objeto de Valor | Identificador único universal (`UUID`) para liquidaciones de nómina. |
| `ShiftSchedule` | Objeto de Valor | Horario regular de inicio y fin de labores con margen de tolerancia en minutos ($[0, 60]$). |
| `DistanceMeters` | Objeto de Valor | Distancia euclidiana o esférica en metros ($\ge 0.0$) entre el móvil y la sede del taller. |
| `AttendanceStatus` | Enumeración de Dominio | Estados de la marcación (`VALID`, `LATE`, `REJECTED_OUTSIDE_GEOFENCE`, `MANUAL_OVERRIDE`). |
| `PayrollPeriod` | Objeto de Valor | Período contable de liquidación mensual o quincenal expresado bajo la convención formal YYYY-MM. |
| `PayrollItemType` | Enumeración de Dominio | Tipología del concepto salarial (`BASE_SALARY`, `PRODUCTIVITY_BONUS`, `OVERTIME`, `TAX_DEDUCTION`). |
| `HaversineGeofencingService` | Servicio de Dominio | Motor matemático que evalúa si la coordenada GPS de marcación se ubica dentro del radio perimetral del taller. |
| `OvertimeAndCommissionCalculator`| Servicio de Dominio | Servicio puro que consolida tiempos de órdenes MRO y turnos para calcular bonificaciones por rendimiento. |
| `EmployeeProfileRepository` | Puerto de Salida | Contrato de persistencia de dominio para la Raíz de Agregado `EmployeeProfile`. |
| `WorkShiftRepository` | Puerto de Salida | Contrato de persistencia de dominio para la Raíz de Agregado `WorkShift`. |
| `AttendanceRecordRepository` | Puerto de Salida | Contrato de persistencia de dominio para la Raíz de Agregado `AttendanceRecord`. |
| `PayrollPaymentRepository` | Puerto de Salida | Contrato de persistencia de dominio para la Raíz de Agregado `PayrollPayment`. |
| `ShiftAssignedEvent` | Evento de Dominio | Notifica la asignación de un nuevo horario de trabajo al colaborador. |
| `AttendanceMarkedEvent` | Evento de Dominio | Notifica la marcación exitosa y conforme de asistencia dentro de la geocerca. |
| `AttendanceGeofenceBreachedEvent`| Evento de Dominio | Notifica un intento de registro fuera del perímetro físico autorizado de la sucursal. |
| `PayrollGeneratedEvent` | Evento de Dominio | Notifica el cálculo y emisión del borrador preliminar de planilla de haberes. |
| `PayrollPaidEvent` | Evento de Dominio | Notifica el desembolso y liquidación definitiva de la nómina al colaborador. |
: Catálogo de Tipos de Dominio del Bounded Context Human Resources (HR) {#tbl:hr-domain-types}

*Nota.* Componentes tácticos del paquete canónico com.andeva.atelier.platform.hr.domain.

**Raíces de Agregado y Entidades Dependientes de Human Resources**

1. `EmployeeProfile`: Modela el expediente técnico del trabajador dentro de la plataforma. Vincula al colaborador con su identidad global `UserId` del módulo IAM, almacenando especialidades técnicas automotrices (electricidad, inyección electrónica, motores diésel, transmisiones) y fecha de contratación. Controla el estado laboral del operario impidiendo asignaciones operativas si el perfil se encuentra inactivo.

| Elemento | Tipo o Firma | Ámbito | Descripción y Reglas de Negocio |
| :--- | :--- | :---: | :--- |
| `id` | `EmployeeId` | Privado | Identificador universal único del empleado. |
| `tenantId` | `TenantId` | Privado | Taller empleador. |
| `userId` | `UserId` | Privado | Identidad de usuario vinculada en el contexto IAM. |
| `branchId` | `BranchId` | Privado | Sede física principal de adscripción. |
| `jobTitle` | `String` | Privado | Denominación del puesto de trabajo (ej. "Técnico Mecánico Senior"). |
| `specialties` | `List<String>` | Privado | Áreas de especialización electromecánica del técnico. |
| `hireDate` | `LocalDate` | Privado | Fecha formal de ingreso laboral al taller. |
| `isActive` | `boolean` | Privado | Estado operativo del contrato. |
| `create` | `static EmployeeProfile create(...)` | Público | Factoría constructora que inicializa el expediente laboral. |
| `assignBranch` | `void assignBranch(BranchId newBranch)` | Público | Transfiere al técnico a una nueva sede física operativa. |
| `deactivate` | `void deactivate()` | Público | Inhabilita el expediente ante cese o renuncia del trabajador. |
: Miembros de la Raíz de Agregado EmployeeProfile {#tbl:hr-employee-members}

*Nota.* Especificación de miembros de EmployeeProfile del paquete com.andeva.atelier.platform.hr.domain.model.aggregates.

En cuanto a sus relaciones, `EmployeeProfile` hereda de `AbstractDomainAggregateRoot<EmployeeProfile>` y mantiene referencias por identificador (`UserId`, `BranchId`, `TenantId`) hacia otros contextos.

2. `AttendanceRecord`: Raíz de agregado que encapsula la marcación de asistencia del operario. Registra la marca de tiempo de lectura, la coordenada satelital WGS84 transmitida por la aplicación móvil `GeoPoint`, la distancia esférica calculada hacia la sucursal `DistanceMeters` y el estado resultante `AttendanceStatus`.

| Elemento | Tipo o Firma | Ámbito | Descripción y Reglas de Negocio |
| :--- | :--- | :---: | :--- |
| `id` | `AttendanceId` | Privado | Identificador universal único de la marcación. |
| `tenantId` | `TenantId` | Privado | Taller empleador. |
| `employeeId` | `EmployeeId` | Privado | Colaborador que efectúa la marcación. |
| `branchId` | `BranchId` | Privado | Sede física donde se registra la asistencia. |
| `checkTimestamp`| `Instant` | Privado | Marca de tiempo UTC certificada del registro. |
| `location` | `GeoPoint` | Privado | Coordenada satelital capturada desde el smartphone. |
| `distance` | `DistanceMeters` | Privado | Distancia en metros calculada respecto a la sede del taller. |
| `status` | `AttendanceStatus` | Privado | Clasificación de validez de la marcación (`VALID`, `REJECTED_OUTSIDE_GEOFENCE`, etc.). |
| `markValid` | `static AttendanceRecord markValid(...)` | Público | Factoría para asistencias dentro de la geocerca que emite `AttendanceMarkedEvent`. |
| `markBreached` | `static AttendanceRecord markBreached(...)` | Público | Factoría para registros fuera de tolerancia que emite evento de transgresión. |
: Miembros de la Raíz de Agregado AttendanceRecord {#tbl:hr-attendance-members}

*Nota.* Especificación de miembros del agregado AttendanceRecord del paquete com.andeva.atelier.platform.hr.domain.model.aggregates.

3. `PayrollPayment`: Raíz de agregado que liquida la remuneración del colaborador. Agrupa una lista de entidades `PayrollItem` que desglosan el haber básico pactado, las comisiones por órdenes mecánicas culminadas, las horas extraordinarias y las deducciones tributarias o previsionales. Impone la invariante de que el monto neto liquidado no puede ser negativo ($netAmount \ge 0.00$).

| Elemento | Tipo o Firma | Ámbito | Descripción y Reglas de Negocio |
| :--- | :--- | :---: | :--- |
| `id` | `PayrollId` | Privado | Identificador universal único de la liquidación de haberes. |
| `tenantId` | `TenantId` | Privado | Taller empleador. |
| `employeeId` | `EmployeeId` | Privado | Colaborador destinatario del pago. |
| `period` | `PayrollPeriod` | Privado | Mes y año contable liquidado (YYYY-MM). |
| `items` | `List<PayrollItem>` | Privado | Desglose pormenorizado de conceptos remunerativos y deducciones. |
| `totalGross` | `Money` | Privado | Monto bruto acumulado antes de descuentos. |
| `totalDeductions`| `Money` | Privado | Sumatoria de retenciones de ley y adelantos. |
| `totalNet` | `Money` | Privado | Importe líquido final a pagar al trabajador ($\ge 0.00$). |
| `isPaid` | `boolean` | Privado | Estado de confirmación del desembolso bancario. |
| `addItem` | `void addItem(PayrollItem item)` | Público | Incorpora un nuevo concepto y recalcula importes netos. |
| `markAsPaid` | `void markAsPaid()` | Público | Confirma el pago efectivo y emite `PayrollPaidEvent`. |
: Miembros de la Raíz de Agregado PayrollPayment {#tbl:hr-payroll-members}

*Nota.* Especificación de miembros de PayrollPayment del paquete com.andeva.atelier.platform.hr.domain.model.aggregates.

**Objetos de Valor de Human Resources Management**

| Objeto de Valor | Atributos Clave | Restricciones de Validación y Reglas de Negocio |
| :--- | :--- | :--- |
| `ShiftSchedule` | `startTime`, `endTime`: `LocalTime`, `toleranceMinutes`: `int` | Invariante cronológica: `startTime < endTime`, tolerancia entre 0 y 60 minutos. |
| `DistanceMeters` | `value`: `double` | Valor decimal no negativo ($\ge 0.0$) que expresa separación espacial. |
| `PayrollPeriod` | `value`: `String` | Expresión regular `^[0-9]{4}-(0[1-9]\|1[0-2])$`, validando año y mes gregoriano. |
: Objetos de Valor del Bounded Context Human Resources {#tbl:hr-value-objects}

*Nota.* Especificación de Objetos de Valor del paquete com.andeva.atelier.platform.hr.domain.model.valueobjects.

**Servicios de Dominio de Human Resources Management**

1. `HaversineGeofencingService`: Encapsula la formulación trigonométrica esférica para determinar la proximidad espacial entre las coordenadas satelitales del técnico mecánico y el centroide de la sucursal física:
   $$d = 2 R \arcsin\left(\sqrt{\sin^2\left(\frac{\Delta \phi}{2}\right) + \cos(\phi_1)\cos(\phi_2)\sin^2\left(\frac{\Delta \lambda}{2}\right)}\right)$$
   Donde $R = 6,371,000$ metros representa el radio esférico medio de la Tierra, $\phi_1, \phi_2$ corresponden a las latitudes en radianes y $\Delta \phi, \Delta \lambda$ a los diferenciales angulares. Si la distancia calculada $d$ es menor o igual al radio de geocerca autorizado para la sede ($\le 150.0$ metros), el servicio aprueba la marcación (`VALID`); en caso contrario, rechaza la operación clasificándola como `REJECTED_OUTSIDE_GEOFENCE`.
2. `OvertimeAndCommissionCalculator`: Consolida las horas efectivamente invertidas por el mecánico en las tareas de órdenes MRO terminadas durante el período de planilla. Multiplica las horas extraordinarias por el factor legal de recargo (25% para las dos primeras horas, 35% para las subsecuentes conforme a la normativa laboral) y añade los porcentajes pactados de comisión por servicios especializados, generando los ítems correspondientes en el agregado `PayrollPayment`.

**Puertos de Repositorio de la Capa de Dominio**

| Puerto de Repositorio | Métodos Principales | Responsabilidad de Dominio |
| :--- | :--- | :--- |
| `EmployeeProfileRepository` | `save`, `findById`, `findByUserId`, `findByBranchId` | Persistencia y consulta de expedientes de colaboradores. |
| `WorkShiftRepository` | `save`, `findById`, `findByTenantIdAndActive`, `findByBranchId` | Gestión de turnos y esquemas de jornada laboral. |
| `AttendanceRecordRepository` | `save`, `findById`, `findByEmployeeIdAndDateRange` | Almacenamiento histórico de marcaciones de asistencia. |
| `PayrollPaymentRepository` | `save`, `findById`, `findByEmployeeIdAndPeriod`, `findByPeriod` | Control y archivo de liquidaciones de nóminas salariales. |
: Puertos de Repositorio del Bounded Context Human Resources {#tbl:hr-repository-ports}

*Nota.* Interfaces de salida del paquete com.andeva.atelier.platform.hr.domain.repositories.

**Eventos de Dominio y Manejo de Errores Semánticos**

Los eventos de dominio de Recursos Humanos coordinan la gestión de personal:
* `ShiftAssignedEvent`: Notifica al colaborador en su dispositivo móvil sobre su horario programado.
* `AttendanceMarkedEvent`: Confirma el registro conforme de asistencia en el taller.
* `AttendanceGeofenceBreachedEvent`: Alerta al administrador sobre un intento de marcación fuera de los límites de la sucursal.
* `PayrollGeneratedEvent`: Informa la disponibilidad de la boleta de pago preliminar para revisión del trabajador.
* `PayrollPaidEvent`: Confirma el cierre definitivo y pago de la nómina.

Las fallas de validación se gestionan mediante `Result<T, ApplicationError>` y excepciones tipadas (`GeofenceValidationException`, `ShiftConflictException`, `AttendanceAlreadyMarkedException`).



#### 2.6.6.2. Interface Layer



#### 2.6.6.3. Application Layer



#### 2.6.6.4 Infrastructure Layer



#### 2.6.6.5. Bounded Context Software Architecture Component Level Diagrams



#### 2.6.6.6. Bounded Context Software Architecture Code Level Diagrams



##### 2.6.6.6.1. *Bounded Context Domain Layer Class Diagrams*



##### 2.6.6.6.2. *Bounded Context Database Design Diagram*