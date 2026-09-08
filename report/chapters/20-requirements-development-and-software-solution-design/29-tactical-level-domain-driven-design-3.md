### 2.6.7. *Bounded Context: Invoicing & Compliance*

El Bounded Context de Invoicing & Compliance encapsula la totalidad de las reglas contables, fiscales y tributarias exigidas por la legislación peruana bajo la supervisión de la Superintendencia Nacional de Aduanas y de Administración Tributaria (SUNAT), operando bajo el estándar internacional Universal Business Language (UBL 2.1). Su delimitación táctica en la arquitectura de Atelier responde a la necesidad crítica de blindar el núcleo operativo del taller frente a la volatilidad de la normativa tributaria nacional.

En el ecosistema automotriz independiente del Perú, la facturación representa un punto de fricción crítico. Una proporción significativa de talleres mecánicos opera en la informalidad o gestiona comprobantes mediante talonarios físicos manuales, exponiéndose a sanciones tributarias severas y perdiendo la oportunidad de atender flotas corporativas que exigen facturas electrónicas válidas para sustentar costos y deducir crédito fiscal del Impuesto General a las Ventas (IGV). Aquellos talleres que han adoptado facturación electrónica suelen lidiar con sistemas desconectados que obligan a digitar doblemente los repuestos y la mano de obra, propiciando errores humanos en montos y correlativos.

Para resolver este desafío, el contexto establece una clara diferenciación arquitectónica entre dos flujos comerciales complementarios: mientras el contexto de SaaS Billing & Subscriptions gestiona la recaudación recurrente que Andeva percibe de los talleres mecánicos mediante Stripe, Invoicing & Compliance gobierna exclusivamente la emisión de comprobantes que el taller extiende a sus propios clientes (conductores particulares y flotas comerciales). 

El modelo táctico sitúa a la raíz de agregado `ElectronicVoucher` en el centro del dominio, gestionando el ciclo de vida fiscal de los comprobantes electrónicos autorizados por SUNAT: Factura Electrónica (código legal `01`, exigiendo RUC válido de 11 dígitos), Boleta de Venta Electrónica (código legal `03`, para consumidores finales) y Nota de Crédito Electrónica (código legal `07`, para anulaciones y rectificaciones monetarias). Asimismo, el agregado `SeriesConfiguration` gobierna el avance atómico e inviolable de los correlativos numéricos por sucursal física, eliminando el riesgo de duplicidad de numeración.

A nivel de integración y resiliencia, el contexto incorpora una Capa Anticorrupción (ACL) hacia Nubefact, actuando este como Proveedor de Servicios Electrónicos (PSE) homologado ante SUNAT. Mediante el patrón Transactional Outbox, los comprobantes generados localmente se persisten en estado emitido (`ISSUED`) y se encolan para su despacho asíncrono, garantizando que una intermitencia temporal en los servidores tributarios del Estado jamás interrumpa la entrega física del automóvil reparado en el taller.

#### 2.6.7.1. Domain Layer

La capa de dominio de Invoicing & Compliance concentra las entidades, objetos de valor inmutables, invariantes de validación tributaria y contratos de persistencia que garantizan la soberanía fiscal de la plataforma. En la @tbl:invoicing-domain-types se resume el catálogo de tipos tácticos que conforman este paquete.

| Clase o Tipo | Categoría Táctica | Responsabilidad Principal en el Dominio |
| :--- | :--- | :--- |
| `ElectronicVoucher` | Raíz de Agregado | Frontera de consistencia del comprobante electrónico; gobierna líneas, pagos, estados y hashes fiscales. |
| `VoucherLine` | Entidad Dependiente | Partida individual que desglosa un repuesto o servicio facturado con su base imponible y desglose de IGV. |
| `VoucherPayment` | Entidad Dependiente | Asiento de liquidación financiera (efectivo, tarjeta, transferencia, billetera digital) contra el comprobante. |
| `SeriesConfiguration` | Raíz de Agregado | Configuración de series alfanuméricas autorizadas y avance secuencial atómico de correlativos por sede. |
| `VoucherId` | Objeto de Valor | Identificador único universal (`UUID`) fuertemente tipado para comprobantes electrónicos. |
| `SeriesConfigurationId` | Objeto de Valor | Identificador único universal (`UUID`) para configuraciones de series fiscales. |
| `PaymentId` | Objeto de Valor | Identificador único universal (`UUID`) para asientos de recaudación monetaria. |
| `VoucherSerie` | Objeto de Valor | Serie alfanumérica de cuatro caracteres conforme a normativa de SUNAT (ej. `F001`, `B001`, `FC01`). |
| `VoucherNumber` | Objeto de Valor | Correlativo numérico entero estrictamente positivo asociado a una serie fiscal. |
| `VoucherType` | Enumeración de Dominio | Clasificación legal de comprobantes oficiales (`FACTURA`, `BOLETA`, `NOTA_CREDITO`). |
| `VoucherStatus` | Enumeración de Dominio | Estados del ciclo de vida fiscal (`DRAFT`, `ISSUED`, `ACCEPTED_SUNAT`, `REJECTED_SUNAT`, `VOIDED`). |
| `TaxCalculation` | Objeto de Valor | Estructura inmutable que segrega base imponible, importe de IGV, tasa impositiva y precio final de venta. |
| `CustomerFiscalInfo` | Objeto de Valor | Registro tributario del receptor (RUC o DNI, razón social o nombres, domicilio fiscal verificado). |
| `DigitalReceiptUrls` | Objeto de Valor | Conjunto de direcciones URL seguras que apuntan al PDF impreso, archivo XML firmado y CDR de SUNAT. |
| `SunatResponse` | Objeto de Valor | Metadatos de conformidad retornados por SUNAT (código de respuesta, glosa y hash de firma digital). |
| `PaymentMethod` | Enumeración de Dominio | Medios formales de pago (`CASH`, `CREDIT_CARD`, `DEBIT_CARD`, `BANK_TRANSFER`, `YAPE`, `PLIN`). |
| `PaymentStatus` | Enumeración de Dominio | Estados del registro de pago (`PENDING`, `COMPLETED`, `REFUNDED`). |
| `PeruvianTaxCalculationEngine` | Servicio de Dominio | Motor matemático que segrega el IGV (18%) con redondeo bancario *Half-Even* a dos decimales. |
| `VoucherValidationService` | Servicio de Dominio | Valida algoritmos de dígito verificador módulo 11 para RUCs y umbral legal para boletas sin DNI. |
| `ElectronicVoucherRepository` | Puerto de Salida | Contrato de persistencia de dominio para la Raíz de Agregado `ElectronicVoucher`. |
| `SeriesConfigurationRepository` | Puerto de Salida | Contrato de persistencia de dominio para la Raíz de Agregado `SeriesConfiguration`. |
| `VoucherPaymentRepository` | Puerto de Salida | Contrato de persistencia de dominio para liquidaciones de pago vinculadas a comprobantes. |
| `ElectronicVoucherIssuedEvent` | Evento de Dominio | Notifica la emisión local formal del comprobante previa a su despacho a SUNAT. |
| `VoucherAcceptedBySunatEvent` | Evento de Dominio | Notifica la homologación satisfactoria de la validez fiscal acreditada mediante el CDR. |
| `VoucherRejectedBySunatEvent` | Evento de Dominio | Notifica observaciones o inconsistencias tributarias detectadas por el ente recaudador. |
| `VoucherVoidedEvent` | Evento de Dominio | Notifica la anulación legal del comprobante mediante comunicación de baja formal. |
| `VoucherPaymentRegisteredEvent` | Evento de Dominio | Notifica la amortización total o parcial del importe adeudado en el comprobante. |
: Catálogo de Tipos de Dominio del Bounded Context Invoicing & Compliance {#tbl:invoicing-domain-types}

*Nota.* Componentes tácticos pertenecientes al paquete com.andeva.atelier.platform.invoicing.domain.

**Raíces de Agregado y Entidades Dependientes de Invoicing & Compliance**

1. `ElectronicVoucher`: Actúa como la raíz de agregado principal que custodia la consistencia tributaria del comprobante. Encapsula las entidades hijas `VoucherLine` y `VoucherPayment`. Impone como invariantes inviolables que el importe total del comprobante coincida de forma exacta con la sumatoria aritmética de sus líneas, y que la base imponible sumada al impuesto de ley totalice el monto facturado. Cuando el comprobante alcanza el estado `ACCEPTED_SUNAT`, se torna legalmente inmutable; cualquier modificación ulterior debe realizarse mediante la emisión de una Nota de Crédito que referencie su serie y correlativo original.

En la @tbl:invoicing-voucher-members se detallan los atributos y operaciones de la raíz de agregado `ElectronicVoucher`.

| Elemento | Tipo o Firma | Ámbito | Descripción y Reglas de Negocio |
| :--- | :--- | :---: | :--- |
| `id` | `VoucherId` | Privado | Identificador universal único del comprobante. |
| `tenantId` | `TenantId` | Privado | Taller emisor del comprobante fiscal. |
| `branchId` | `BranchId` | Privado | Sucursal física donde se concretó la venta o servicio. |
| `customerId` | `CustomerId` | Privado | Cliente receptor de la transacción comercial. |
| `workOrderId` | `Optional<WorkOrderId>` | Privado | Orden de trabajo de MRO que motivó la emisión (opcional en venta de mostrador). |
| `voucherType` | `VoucherType` | Privado | Tipo de documento fiscal regulado (`FACTURA`, `BOLETA`, `NOTA_CREDITO`). |
| `serie` | `VoucherSerie` | Privado | Serie alfanumérica de cuatro caracteres autorizada por SUNAT. |
| `number` | `VoucherNumber` | Privado | Correlativo numérico entero asignado en forma consecutiva. |
| `taxCalculation` | `TaxCalculation` | Privado | Objeto de valor con desglose de subtotal, IGV y monto total consolidado. |
| `currency` | `Currency` | Privado | Moneda formal de la operación (`PEN`, `USD`). |
| `status` | `VoucherStatus` | Privado | Estado actual en la máquina de estados del comprobante. |
| `customerFiscalInfo`| `CustomerFiscalInfo` | Privado | Datos fiscales del receptor verificados al momento de emitir. |
| `digitalReceiptUrls`| `DigitalReceiptUrls` | Privado | Enlaces seguros a representaciones digitales (PDF, XML, CDR). |
| `sunatResponse` | `Optional<SunatResponse>` | Privado | Código de respuesta, descripción oficial y firma digital SHA-256 de SUNAT. |
| `lines` | `List<VoucherLine>` | Privado | Colección ordenada de partidas facturadas que integran el comprobante. |
| `payments` | `List<VoucherPayment>` | Privado | Historial de abonos monetarios efectuados para saldar el documento. |
| `issue` | `static ElectronicVoucher issue(...)` | Público | Factoría de dominio que valida reglas fiscales peruanas y emite `ElectronicVoucherIssuedEvent`. |
| `markAcceptedBySunat` | `void markAcceptedBySunat(...)` | Público | Registra la aprobación de SUNAT con su hash fiscal y dispara `VoucherAcceptedBySunatEvent`. |
| `markRejectedBySunat` | `void markRejectedBySunat(...)` | Público | Asienta el motivo de rechazo formal y emite `VoucherRejectedBySunatEvent`. |
| `voidVoucher` | `void voidVoucher(String reason)` | Público | Transiciona el documento a `VOIDED` y registra `VoucherVoidedEvent`. |
| `recordPayment` | `VoucherPayment recordPayment(...)` | Público | Registra un pago monetario verificando que el saldo acumulado no supere el total facturado. |
| `isFullyPaid` | `boolean isFullyPaid()` | Público | Determina si la sumatoria de abonos liquidados cubre el 100% de la obligación. |
| `getPendingBalance` | `Money getPendingBalance()` | Público | Calcula el saldo remanente pendiente de recaudación. |
: Miembros de la Raíz de Agregado ElectronicVoucher {#tbl:invoicing-voucher-members}

*Nota.* Especificación de miembros de la clase ElectronicVoucher del paquete com.andeva.atelier.platform.invoicing.domain.model.aggregates.

En cuanto a sus relaciones, `ElectronicVoucher` hereda de `AbstractDomainAggregateRoot<ElectronicVoucher>`, mantiene relaciones de composición 1 a 1..* con `VoucherLine` y 1 a 0..* con `VoucherPayment`, y se asocia mediante identificadores inmutables con `TenantId`, `BranchId`, `CustomerId` y de forma opcional con `WorkOrderId` del contexto MRO.

2. `VoucherLine`: Entidad dependiente contenida dentro de `ElectronicVoucher`. Modela cada partida individual facturada correspondiente a un servicio técnico o a un repuesto despachado desde el almacén. Custodia atributos como el identificador del ítem facturado (`itemId: Optional<UUID>`), la descripción del concepto, la cantidad provista (`Quantity`), el valor unitario libre de tributos (`unitValue: Money`), el precio unitario con IGV incluido (`unitPrice: Money`) y el total de la partida (`totalLine: Money`). Garantiza que el valor unitario sea calculado mediante la segregación matemática del IGV exigida por el estándar UBL 2.1.

3. `SeriesConfiguration`: Raíz de agregado que gobierna la asignación de series fiscales autorizadas y el avance correlativo estricto en cada sede física del taller. Previene saltos involuntarios en la numeración correlativa y colisiones entre cajeros concurrentes mediante mecanismos de incremento atómico. En la @tbl:invoicing-series-members se exponen sus componentes estructurales.

| Elemento | Tipo o Firma | Ámbito | Descripción y Reglas de Negocio |
| :--- | :--- | :---: | :--- |
| `id` | `SeriesConfigurationId` | Privado | Identificador universal único del registro de serie. |
| `tenantId` | `TenantId` | Privado | Taller propietario de la autorización de serie. |
| `branchId` | `BranchId` | Privado | Sede física a la que se circunscribe la emisión correlativa. |
| `voucherType` | `VoucherType` | Privado | Tipo de comprobante al que aplica la serie (`FACTURA`, `BOLETA`, etc.). |
| `serie` | `VoucherSerie` | Privado | Prefijo fiscal de cuatro caracteres alfanuméricos (ej. `F001`). |
| `currentCorrelative`| `int` | Privado | Último número correlativo asignado e impreso. |
| `isActive` | `boolean` | Privado | Estado operativo de la serie para nuevas emisiones. |
| `create` | `static SeriesConfiguration create(...)` | Público | Factoría de dominio que inicializa la serie con correlativo base. |
| `nextCorrelative` | `VoucherNumber nextCorrelative()` | Público | Incrementa de forma atómica y segura el contador interno devolviendo el nuevo correlativo. |
| `deactivate` | `void deactivate()` | Público | Inhabilita la serie para prevenir futuras emisiones en la sede. |
: Miembros de la Raíz de Agregado SeriesConfiguration {#tbl:invoicing-series-members}

*Nota.* Especificación de miembros de SeriesConfiguration del paquete com.andeva.atelier.platform.invoicing.domain.model.aggregates.

Respecto a sus relaciones, `SeriesConfiguration` hereda de `AbstractDomainAggregateRoot<SeriesConfiguration>` y mantiene vínculos mediante referencias de clave con `TenantId` y `BranchId`.

4. `VoucherPayment`: Modela la recaudación monetaria vinculada a una factura o boleta electrónica. Captura atributos esenciales como `paymentId`, `voucherId`, `tenantId`, `branchId`, el monto liquidado (`amount: Money`), el canal de recaudación (`paymentMethod: PaymentMethod`), la referencia de transacción bancaria o comprobante POS (`transactionReference: String`) y la marca temporal de abono (`paidAt: Instant`). Si el medio de pago corresponde a transferencias bancarias o billeteras electrónicas (Yape, Plin), la referencia de operación es obligatoria para garantizar la posterior conciliación contable de caja.

**Objetos de Valor de Invoicing & Compliance**

La consistencia y semántica de las magnitudes tributarias se modelan mediante objetos de valor inmutables, cuyas restricciones se resumen en la @tbl:invoicing-value-objects.

| Objeto de Valor | Atributos Clave | Restricciones de Validación y Reglas de Negocio |
| :--- | :--- | :--- |
| `VoucherSerie` | `value`: `String` | Patrón `^[F|B|T][A-Z0-9]{3}$`. Facturas inician con `F`, Boletas con `B` y Notas con su correlación de serie. |
| `VoucherNumber` | `value`: `int` | Número entero estrictamente positivo ($> 0$), formateado a ocho dígitos para impresión (`%08d`). |
| `TaxCalculation` | `subtotal`, `igvAmount`, `totalAmount`: `Money`, `igvRate`: `BigDecimal` | Invariante matemática: `subtotal.add(igvAmount).equals(totalAmount)`. Tasa fijada en $0.18$ (18%). |
| `CustomerFiscalInfo`| `taxId`: `TaxId`, `legalName`, `fiscalAddress`: `String`, `documentType`: `DocumentType` | RUC debe poseer 11 dígitos numéricos; DNI 8 dígitos. Razón social y dirección obligatorias en Facturas. |
| `DigitalReceiptUrls`| `pdfUrl`, `xmlUrl`, `cdrUrl`: `String` | Direcciones HTTPS accesibles y firmadas digitalmente que custodian los entregables de SUNAT. |
| `SunatResponse` | `responseCode`, `description`, `digitalSignatureHash`: `String` | Código `0` para aceptación íntegra; hash SHA-256 de seguridad generado por el certificado PSE. |
: Objetos de Valor del Bounded Context Invoicing & Compliance {#tbl:invoicing-value-objects}

*Nota.* Especificación de Objetos de Valor del paquete com.andeva.atelier.platform.invoicing.domain.model.valueobjects.

**Servicios de Dominio de Invoicing & Compliance**

1. `PeruvianTaxCalculationEngine`: Encapsula los algoritmos matemáticos de segregación impositiva y redondeo bancario exigidos por la legislación peruana. A partir de los importes brutos pactados con el cliente en la orden de servicio, el motor deduce la base imponible y el débito fiscal aplicando las fórmulas normalizadas:
   $$\text{Subtotal} = \frac{\text{Total Bruto}}{1.18}, \quad \text{Monto IGV} = \text{Total Bruto} - \text{Subtotal}$$
   Todas las operaciones de división monetaria emplean la escala a dos decimales con modo de redondeo bancario *Half-Even* (`RoundingMode.HALF_EVEN`), eliminando los sesgos estadísticos de aproximación y cuadrando con exactitud los céntimos requeridos por los validadores XSD de SUNAT. Asimismo, extrae el valor unitario neto de cada línea con cuatro decimales de precisión para su inclusión en la trama XML UBL 2.1 y convierte el total numérico a su representación formal en texto en castellano para la impresión legal del comprobante (ej. "SON: CIENTO VEINTE CON 00/100 SOLES").

2. `VoucherValidationService`: Aplica el algoritmo de validación de módulo 11 ponderado para números de RUC en el territorio peruano, utilizando el vector de ponderación legal $[5, 4, 3, 2, 7, 6, 5, 4, 3, 2]$. Verifica que el dígito verificador calculado coincida con el último dígito del documento tributario y que los prefijos correspondan a personas naturales con negocio (`10`, `15`, `17`) o personas jurídicas (`20`). Además, fiscaliza que las Boletas de Venta que excedan el límite reglamentario de S/ 700.00 PEN contengan obligatoriamente la identificación formal del adquirente.

**Puertos de Repositorio de la Capa de Dominio**

En la @tbl:invoicing-repository-ports se detallan los contratos de persistencia que desacoplan la lógica de dominio fiscal de los adaptadores de infraestructura PostgreSQL y Spring Data JPA.

| Puerto de Repositorio | Métodos Principales | Responsabilidad de Dominio |
| :--- | :--- | :--- |
| `ElectronicVoucherRepository` | `save`, `findById`, `findByTenantIdAndSerieAndNumber`, `findAllByWorkOrderId` | Persistencia y consulta histórica de comprobantes de pago emitidos. |
| `SeriesConfigurationRepository`| `save`, `findById`, `findByBranchIdAndVoucherTypeAndActive`, `findAllByBranchId` | Almacenamiento y bloqueo pesimista de correlativos por sede de taller. |
| `VoucherPaymentRepository` | `save`, `findById`, `findAllByVoucherId`, `findAllByBranchIdAndDate` | Registro y conciliación de asientos de cobranza por comprobante y sucursal. |
: Puertos de Repositorio del Bounded Context Invoicing & Compliance {#tbl:invoicing-repository-ports}

*Nota.* Interfaces de salida del paquete com.andeva.atelier.platform.invoicing.domain.repositories.

**Eventos de Dominio y Manejo Semántico de Errores**

La sincronización entre la facturación y los demás módulos de la plataforma se articula a través de eventos de dominio inmutables:
* `ElectronicVoucherIssuedEvent`: Informa la creación local del comprobante y gatilla su almacenamiento en el outbox transaccional para despacho a la pasarela electrónica.
* `VoucherAcceptedBySunatEvent`: Confirma la conformidad fiscal de la operación, posibilitando el cierre administrativo definitivo en el taller.
* `VoucherRejectedBySunatEvent`: Dispara notificaciones operativas al cajero y al administrador para subsanar inconsistencias en los datos tributarios del cliente.
* `VoucherPaymentRegisteredEvent`: Notifica a MRO y CRM sobre el ingreso financiero, permitiendo la entrega material del automóvil al cliente si se saldó el total pactado.

Las transgresiones de reglas de negocio fiscal se reportan de forma determinista mediante el tipo mónada `Result<T, ApplicationError>` y excepciones especializadas (`InvalidTaxIdException`, `CorrelativeExhaustedException`, `VoucherAlreadyPaidException`, `SunatCommunicationException`).



#### 2.6.7.2. Interface Layer



#### 2.6.7.3. Application Layer



#### 2.6.7.4 Infrastructure Layer



#### 2.6.7.5. Bounded Context Software Architecture Component Level Diagrams



#### 2.6.7.6. Bounded Context Software Architecture Code Level Diagrams



##### 2.6.7.6.1. *Bounded Context Domain Layer Class Diagrams*



##### 2.6.7.6.2. *Bounded Context Database Design Diagram*



### 2.6.8. *Bounded Context: SaaS Billing & Subscriptions*

El Bounded Context de SaaS Billing & Subscriptions administra de forma integral el modelo de monetización recurrente B2B (*Business-to-Business*) de la compañía Andeva hacia los talleres mecánicos abonados a la plataforma Atelier. Su perímetro de responsabilidad abarca la gestión de los planes de suscripción, el aprovisionamiento dinámico de capacidades de software, el cobro recurrente mediante la pasarela internacional Stripe, la gobernanza de cuotas operativas por taller y la conciliación contable de los recibos de servicio.

En el diseño arquitectónico de Atelier, este contexto mantiene un desacoplamiento estricto respecto al módulo de facturación local (Invoicing & Compliance): mientras que Invoicing gobierna los comprobantes fiscales que el taller extiende a los conductores conforme a las normas de SUNAT, SaaS Billing rige el contrato comercial que vincula al taller como cliente corporativo con Andeva. Mezclar estas dos dimensiones en un único modelo de facturación induciría a severos acoplamientos, contaminando la lógica contable internacional con particularidades tributarias peruanas.

El dominio modela la raíz de agregado `SubscriptionPlan`, la cual define los niveles comerciales del catálogo (`STARTER`, `PROFESSIONAL`, `ENTERPRISE`), las periodicidades de facturación (`MONTHLY`, `YEARLY`) y los límites de consumo estipulados (`TenantQuotaLimits`). Por su parte, la raíz de agregado `TenantSubscription` gobierna el ciclo de vida contractual de cada taller a través de los estados `TRIALING`, `ACTIVE`, `PAST_DUE`, `CANCELED` y `UNPAID`. Cuando un taller se afilia, la suscripción controla los periodos de gracia ante fallos bancarios y autoriza de forma estricta el acceso al sistema.

Un componente arquitectónico distintivo de este contexto es su adhesión estricta a la certificación de seguridad PCI-DSS (*Payment Card Industry Data Security Standard*). El backend de Atelier jamás procesa, transfiere ni persiste números de tarjetas de crédito o códigos de seguridad bancarios; delega la captura sensible al frontend mediante Stripe Elements y el SDK móvil oficial de Stripe, custodiando únicamente identificadores de recursos tokenizados (`stripe_customer_id`, `stripe_subscription_id`, `stripe_price_id`). 

Asimismo, para garantizar la consistencia en el procesamiento de eventos asíncronos provenientes de Stripe (cobros de facturas, cancelaciones por falta de pago o cambios de plan), el contexto modela el agregado `StripeWebhookEvent`, el cual asegura un procesamiento exactamente una vez (*Exactly-Once Processing*) mediante restricciones de unicidad e idempotencia estricta. Para optimizar el rendimiento del ERP y evitar consultas repetitivas a la base de datos relacional cada vez que un usuario interactúa con la plataforma, la validación de vigencia de suscripciones se acelera mediante una capa de caché de ultra alta velocidad implementada con Caffeine Cache, con invalidación reactiva ante eventos de webhook.

#### 2.6.8.1. Domain Layer

La capa de dominio de SaaS Billing & Subscriptions encapsula las reglas contractuales de licenciamiento de software, las restricciones de cuotas de recursos y el procesamiento seguro de pagos recurrentes. En la @tbl:billing-domain-types se detalla la nómina de componentes que integran este módulo táctico.

| Clase o Tipo | Categoría Táctica | Responsabilidad Principal en el Dominio |
| :--- | :--- | :--- |
| `SubscriptionPlan` | Raíz de Agregado | Define el catálogo comercial de software, tarifas de cobro y límites de recursos paquetizados. |
| `TenantSubscription` | Raíz de Agregado | Gobierna el contrato de servicio activo del taller, estados de vigencia, renovaciones y suspensiones. |
| `SaasInvoice` | Raíz de Agregado | Recibo financiero generado por Stripe por el cobro mensual o anual del servicio prestado. |
| `StripeWebhookEvent` | Raíz de Agregado | Garantiza la idempotencia y auditoría forense de eventos asíncronos emitidos por Stripe. |
| `PlanFeature` | Entidad Dependiente | Funcionalidad o módulo específico habilitado dentro de la configuración de un plan de software. |
| `PlanId` | Objeto de Valor | Identificador universal único (`UUID`) fuertemente tipado para planes de suscripción. |
| `SubscriptionId` | Objeto de Valor | Identificador universal único (`UUID`) para contratos de suscripción de talleres. |
| `SaasInvoiceId` | Objeto de Valor | Identificador universal único (`UUID`) para recibos de cobro del SaaS. |
| `StripeEventId` | Objeto de Valor | Identificador unívoco del evento emitido por Stripe (`evt_...`) para deduplicación estricta. |
| `StripeCustomerId` | Objeto de Valor | Identificador de cliente corporativo registrado en la bóveda de Stripe (`cus_...`). |
| `StripeSubscriptionId` | Objeto de Valor | Identificador unívoco del contrato de suscripción gestionado por Stripe (`sub_...`). |
| `StripePriceId` | Objeto de Valor | Identificador del tarifario recurrente configurado en el panel de Stripe (`price_...`). |
| `BillingCycle` | Enumeración de Dominio | Periodicidad del cobro recurrente pactado (`MONTHLY`, `YEARLY`). |
| `SubscriptionStatus` | Enumeración de Dominio | Estados de vigencia contractual (`TRIALING`, `ACTIVE`, `PAST_DUE`, `CANCELED`, `UNPAID`). |
| `InvoiceStatus` | Enumeración de Dominio | Estados de pago del recibo emitido (`PAID`, `OPEN`, `VOID`, `UNCOLLECTIBLE`). |
| `PlanTier` | Enumeración de Dominio | Segmentación comercial del paquete de software (`STARTER`, `PROFESSIONAL`, `ENTERPRISE`). |
| `PlanPricing` | Objeto de Valor | Vinculación del importe monetario formal con su periodicidad de recaudación. |
| `TenantQuotaLimits` | Objeto de Valor | Conjunto inmutable de techos operativos autorizados para el taller (sucursales, personal, módulos). |
| `SubscriptionPeriod` | Objeto de Valor | Ventana temporal delimitada por fecha de inicio y fin de cobertura pagada del servicio. |
| `WebhookProcessingStatus`| Enumeración de Dominio | Estado de atención de la notificación asíncrona (`PENDING`, `PROCESSED`, `FAILED`, `IGNORED`). |
| `SubscriptionQuotaEnforcementService` | Servicio de Dominio | Valida que las operaciones del taller no transgredan las cuotas contratadas en su plan activo. |
| `SubscriptionPlanRepository` | Puerto de Salida | Contrato de persistencia de dominio para la Raíz de Agregado `SubscriptionPlan`. |
| `TenantSubscriptionRepository` | Puerto de Salida | Contrato de persistencia de dominio para la Raíz de Agregado `TenantSubscription`. |
| `SaasInvoiceRepository` | Puerto de Salida | Contrato de persistencia de dominio para la Raíz de Agregado `SaasInvoice`. |
| `StripeWebhookEventRepository` | Puerto de Salida | Contrato de persistencia de dominio para eventos de webhook e idempotencia. |
| `SubscriptionPlanCreatedEvent` | Evento de Dominio | Notifica la publicación formal de un nuevo plan en el catálogo comercial de Andeva. |
| `TenantSubscriptionActivatedEvent` | Evento de Dominio | Notifica la activación de una suscripción o el inicio satisfactorio de una prueba gratuita. |
| `TenantSubscriptionRenewedEvent` | Evento de Dominio | Notifica la extensión del período de servicio tras la liquidación bancaria del ciclo. |
| `TenantSubscriptionPastDueEvent` | Evento de Dominio | Notifica el impago de un cargo recurrente, dando inicio al período de tolerancia y gracia. |
| `TenantSubscriptionCanceledEvent` | Evento de Dominio | Notifica la rescisión del contrato de software y la revocación de accesos al sistema. |
| `TenantPlanChangedEvent` | Evento de Dominio | Notifica la migración de un taller hacia un plan superior o inferior (*upgrade/downgrade*). |
| `SaasInvoicePaymentSucceededEvent` | Evento de Dominio | Notifica la recaudación exitosa de un recibo de cobro a través de Stripe. |
: Catálogo de Tipos de Dominio del Bounded Context SaaS Billing & Subscriptions {#tbl:billing-domain-types}

*Nota.* Componentes tácticos pertenecientes al paquete com.andeva.atelier.platform.billing.domain.

**Raíces de Agregado y Entidades Dependientes de SaaS Billing**

1. `SubscriptionPlan`: Modela el paquete comercial de software ofrecido por Andeva a los talleres mecánicos automotrices. Define el precio formal de licenciamiento, la frecuencia de facturación y las cuotas de recursos asignadas a cada nivel. Mantiene una relación de composición 1 a 1..* con la entidad `PlanFeature`. Impone como regla de negocio que los límites operativos (sucursales y mecánicos) sean estrictamente mayores o iguales a la unidad, y que el identificador `stripePriceId` cumpla con la convención sintáctica de Stripe.

En la @tbl:billing-plan-members se especifican los atributos y operaciones de la raíz de agregado `SubscriptionPlan`.

| Elemento | Tipo o Firma | Ámbito | Descripción y Reglas de Negocio |
| :--- | :--- | :---: | :--- |
| `id` | `PlanId` | Privado | Identificador universal único del plan comercial. |
| `stripePriceId` | `StripePriceId` | Privado | Identificador foráneo del precio en Stripe (`price_...`). |
| `name` | `String` | Privado | Nombre comercial descriptivo del plan (ej. "Plan Profesional"). |
| `tier` | `PlanTier` | Privado | Nivel funcional del paquete (`STARTER`, `PROFESSIONAL`, `ENTERPRISE`). |
| `pricing` | `PlanPricing` | Privado | Objeto de valor con importe monetario y ciclo recurrente pactado. |
| `quotaLimits` | `TenantQuotaLimits` | Privado | Techos máximos de sucursales, personal y módulos IoT permitidos. |
| `isActive` | `boolean` | Privado | Bandera de disponibilidad comercial para nuevas afiliaciones. |
| `create` | `static SubscriptionPlan create(...)` | Público | Factoría de dominio que inicializa el plan y registra `SubscriptionPlanCreatedEvent`. |
| `updateDetails` | `void updateDetails(...)` | Público | Actualiza precios y cuotas operativas preservando suscripciones en curso. |
| `deactivate` | `void deactivate()` | Público | Retira el plan del catálogo impidiendo nuevas contrataciones. |
| `activate` | `void activate()` | Público | Restituye la comercialización del plan en el portal de ventas. |
: Miembros de la Raíz de Agregado SubscriptionPlan {#tbl:billing-plan-members}

*Nota.* Especificación de miembros de la clase SubscriptionPlan del paquete com.andeva.atelier.platform.billing.domain.model.aggregates.

En cuanto a sus relaciones, `SubscriptionPlan` hereda de `AbstractDomainAggregateRoot<SubscriptionPlan>` y mantiene una relación de composición 1 a 1..* con la entidad dependiente `PlanFeature`.

2. `TenantSubscription`: Actúa como la frontera de consistencia contractual entre Andeva y el taller automotriz. Custodia el identificador del taller abonado (`tenantId`), el plan suscrito (`planId`), las credenciales del cliente en la pasarela de pagos (`stripeCustomerId`, `stripeSubscriptionId`), la ventana de cobertura temporal (`currentPeriod: SubscriptionPeriod`) y la situación del servicio (`status: SubscriptionStatus`). Aplica como invariante que un taller mecánico no puede poseer más de una suscripción activa o en período de prueba simultáneamente, y que la fecha de culminación del ciclo debe ser cronológicamente posterior a su inicio.

En la @tbl:billing-subscription-members se exponen los miembros y métodos de control de la raíz de agregado `TenantSubscription`.

| Elemento | Tipo o Firma | Ámbito | Descripción y Reglas de Negocio |
| :--- | :--- | :---: | :--- |
| `id` | `SubscriptionId` | Privado | Identificador universal único del contrato de suscripción. |
| `tenantId` | `TenantId` | Privado | Taller automotriz titular de la membresía. |
| `planId` | `PlanId` | Privado | Identificador del plan comercial contratado. |
| `stripeCustomerId` | `StripeCustomerId` | Privado | Identificador del cliente en Stripe (`cus_...`). |
| `stripeSubscriptionId`| `StripeSubscriptionId`| Privado | Identificador de suscripción recurrente en Stripe (`sub_...`). |
| `status` | `SubscriptionStatus` | Privado | Situación de vigencia (`TRIALING`, `ACTIVE`, `PAST_DUE`, `CANCELED`, etc.). |
| `currentPeriod` | `SubscriptionPeriod` | Privado | Intervalo de tiempo cubierto por la liquidación de pago. |
| `cancelAtPeriodEnd` | `boolean` | Privado | Indica si la renovación se interrumpirá al concluir el período vigente. |
| `canceledAt` | `Optional<Instant>` | Privado | Marca de tiempo UTC formal en que se solicitó o ejecutó la baja. |
| `trialEndDate` | `Optional<Instant>` | Privado | Fecha y hora límite en que expira el acceso en modalidad de prueba. |
| `startTrial` | `static TenantSubscription startTrial(...)` | Público | Factoría para pruebas gratuitas; registra `TenantSubscriptionActivatedEvent`. |
| `activate` | `static TenantSubscription activate(...)` | Público | Factoría tras pago formal en Stripe; registra `TenantSubscriptionActivatedEvent`. |
| `renewPeriod` | `void renewPeriod(SubscriptionPeriod period)` | Público | Extiende el ciclo tras un cobro recurrente exitoso y emite `TenantSubscriptionRenewedEvent`. |
| `markPastDue` | `void markPastDue()` | Público | Declara la mora tras rechazo bancario e inicia gracia con `TenantSubscriptionPastDueEvent`. |
| `cancelAtPeriodEnd` | `void cancelAtPeriodEnd()` | Público | Programa la no renovación del servicio al expirar el ciclo pagado. |
| `cancelImmediately` | `void cancelImmediately(Instant at)` | Público | Revoca el acceso de forma inmediata y emite `TenantSubscriptionCanceledEvent`. |
| `changePlan` | `void changePlan(PlanId newPlanId, ...)`| Público | Modifica el nivel contratado (*upgrade/downgrade*) y registra `TenantPlanChangedEvent`. |
| `isAccessGranted` | `boolean isAccessGranted()` | Público | Evalúa si el taller está autorizado a operar en la plataforma en tiempo de ejecución. |
: Miembros de la Raíz de Agregado TenantSubscription {#tbl:billing-subscription-members}

*Nota.* Especificación de miembros de la clase TenantSubscription del paquete com.andeva.atelier.platform.billing.domain.model.aggregates.

Respecto a sus relaciones, `TenantSubscription` hereda de `AbstractDomainAggregateRoot<TenantSubscription>` y se asocia mediante identificadores inmutables con `TenantId` y `PlanId`.

3. `SaasInvoice`: Raíz de agregado que representa el comprobante contable emitido por Andeva hacia el taller mecánico por la prestación del servicio de software. Almacena el identificador foráneo de la factura en Stripe (`stripeInvoiceId`), el importe neto cobrado a la tarjeta (`amountPaid: Money`), la situación de cobro (`status: InvoiceStatus`), la marca de tiempo de acreditación bancaria (`paidAt: Instant`) y las direcciones web de descarga del PDF formal y la pasarela alojada de pago (`hostedInvoiceUrl`).

4. `StripeWebhookEvent`: Raíz de agregado concebida como escudo de idempotencia frente a la entrega asíncrona de notificaciones por parte de Stripe. Almacena el identificador unívoco del evento (`stripeEventId`), la categoría de suceso reportada (`eventType: String`), el cuerpo JSON íntegro para auditoría forense (`eventPayload: String`), el estado de procesamiento (`status: WebhookProcessingStatus`) y la marca de tiempo de atención. Una restricción de unicidad estricta a nivel de base de datos relacional sobre `stripe_event_id` garantiza que los reintentos automáticos de red no provoquen duplicación en las renovaciones o facturaciones de los talleres.

**Objetos de Valor de SaaS Billing & Subscriptions**

Los conceptos e invariantes del modelo de membresías se plasman en objetos de valor inmutables, resumidos en la @tbl:billing-value-objects.

| Objeto de Valor | Atributos Clave | Restricciones de Validación y Reglas de Negocio |
| :--- | :--- | :--- |
| `PlanPricing` | `price`: `Money`, `billingCycle`: `BillingCycle` | Monto no negativo ($price \ge 0.00$), moneda fijada según el mercado corporativo (USD/PEN). |
| `TenantQuotaLimits`| `maxBranches`, `maxActiveStaff`: `int`, `iotTelemetryEnabled`, `aiDiagnosticsEnabled`: `boolean` | `maxBranches >= 1`, `maxActiveStaff >= 1`. Controla acceso modular por licenciamiento. |
| `SubscriptionPeriod`| `startDate`, `endDate`: `Instant` | Invariante temporal estricta: `startDate.isBefore(endDate)`. |
| `StripeEventId` | `value`: `String` | Prefijo estricto `^evt_[a-zA-Z0-9]+$`, garantizando formato original de la pasarela. |
| `StripeSubscriptionId`| `value`: `String` | Prefijo estricto `^sub_[a-zA-Z0-9]+$`, identificando el contrato en Stripe. |
: Objetos de Valor del Bounded Context SaaS Billing & Subscriptions {#tbl:billing-value-objects}

*Nota.* Especificación de Objetos de Valor del paquete com.andeva.atelier.platform.billing.domain.model.valueobjects.

**Servicios de Dominio de SaaS Billing & Subscriptions**

1. `SubscriptionQuotaEnforcementService`: Servicio de dominio encargado de salvaguardar las fronteras de consumo del software contratadas por el taller. Intercepta los comandos emitidos en otros contextos de la plataforma antes de que se creen recursos físicos o lógicos:
   * En IAM & Tenancy: verifica que la cantidad de sucursales activas no supere `maxBranches` antes de dar de alta una nueva sede física.
   * En Human Resources: verifica que la plantilla de mecánicos y colaboradores en servicio no sobrepase `maxActiveStaff`.
   * En Workshop Operations (MRO): verifica el volumen mensual de órdenes de trabajo procesadas.
   * En IoT Telemetry: fiscaliza que la bandera `iotTelemetryEnabled` se encuentre activa antes de admitir la vinculación de escáneres vehiculares OBD-II.
   Si una operación transgrede el límite estipulado, el servicio lanza de forma síncrona una excepción tipada `QuotaExceededException`, impidiendo la creación del recurso y orientando al usuario a realizar una actualización de plan (*upgrade*).

**Puertos de Repositorio de la Capa de Dominio**

En la @tbl:billing-repository-ports se presentan los puertos de persistencia que desacoplan la lógica contractual de la infraestructura relacional.

| Puerto de Repositorio | Métodos Principales | Responsabilidad de Dominio |
| :--- | :--- | :--- |
| `SubscriptionPlanRepository` | `save`, `findById`, `findByStripePriceId`, `findAllActive` | Catálogo maestro de planes comerciales y tarifas de suscripción. |
| `TenantSubscriptionRepository` | `save`, `findById`, `findByTenantId`, `existsActiveByTenantId` | Contratos vigentes de talleres automotrices y consultas de alta velocidad. |
| `SaasInvoiceRepository` | `save`, `findById`, `findByStripeInvoiceId`, `findAllByTenantId` | Archivo contable de recibos y cobros procesados por Stripe. |
| `StripeWebhookEventRepository` | `save`, `findByStripeEventId`, `existsByStripeEventId` | Registro de idempotencia y bitácora de auditoría para eventos asíncronos. |
: Puertos de Repositorio del Bounded Context SaaS Billing & Subscriptions {#tbl:billing-repository-ports}

*Nota.* Interfaces de salida del paquete com.andeva.atelier.platform.billing.domain.repositories.

**Eventos de Dominio y Notificaciones de Integración**

El ciclo de facturación recurrente se comunica mediante eventos de dominio:
* `TenantSubscriptionActivatedEvent`: Señaliza que el taller cuenta con licencia activa, habilitando sus sedes y usuarios administradores.
* `TenantSubscriptionRenewedEvent`: Extiende el período de licenciamiento y renueva la memoria en caché de autorizaciones.
* `TenantSubscriptionPastDueEvent`: Notifica a los administradores del taller sobre cobros bancarios fallidos e inicia el periodo de gracia.
* `TenantSubscriptionCanceledEvent`: Provoca la invalidación inmediata de sesiones activas en IAM e inhabilita el acceso a la plataforma.
* `TenantPlanChangedEvent`: Modifica instantáneamente las cuotas de recursos disponibles para el taller.



#### 2.6.8.2. Interface Layer



#### 2.6.8.3. Application Layer



#### 2.6.8.4 Infrastructure Layer



#### 2.6.8.5. Bounded Context Software Architecture Component Level Diagrams



#### 2.6.8.6. Bounded Context Software Architecture Code Level Diagrams



##### 2.6.8.6.1. *Bounded Context Domain Layer Class Diagrams*



##### 2.6.8.6.2. *Bounded Context Database Design Diagram*



### 2.6.9. *Bounded Context: IoT Telemetry & Predictive Maintenance*

El Bounded Context de IoT Telemetry & Predictive Maintenance constituye la pieza central de innovación tecnológica y la ventaja competitiva más relevante de Atelier Platform en el mercado automotriz. Su propósito es convertir al taller mecánico tradicional en un centro de servicio inteligente, conectado y proactivo, capaz de anticipar fallas mecánicas catastróficas en los automóviles antes de que se manifiesten en daños irreparables o accidentes viales.

En los talleres mecánicos convencionales, el mantenimiento es preponderantemente reactivo: el cliente acude cuando el automóvil ya presenta ruidos anormales, pérdida de potencia, recalentamiento de motor o remolcado en grúa. Este modelo provoca costos de reparación exorbitantes para el conductor y picos de trabajo impredecibles e ineficientes para el taller. Por su parte, los escáneres automotrices tradicionales se utilizan de forma manual y aislada en foso, perdiéndose la telemetría en tiempo real una vez que el vehículo abandona el establecimiento.

Para transformar este paradigma, el contexto modela la ingesta masiva de parámetros de diagnóstico vehicular a través del puerto OBD-II (*On-Board Diagnostics II*), estandarizado bajo normas internacionales SAE J1962 / ISO 15031. Mediante dispositivos de hardware conectados físicamente al puerto del automóvil (módems celulares con tarjeta SIM o escáneres Bluetooth BLE que se comunican a través del smartphone del conductor), Atelier recolecta de forma continua los flujos de identificación de parámetros (PIDs): revoluciones por minuto del motor (RPM), velocidad del vehículo, temperatura del refrigerante, nivel de combustible y tensión eléctrica de la batería.

Debido al volumen masivo de datos generados —cientos de lecturas por minuto por cada vehículo activo—, almacenar estos registros en una base de datos relacional transaccional convencional degradaría el rendimiento del ERP. Por esta razón, el dominio aísla la serie temporal en la hipertabla especializada `telemetry_logs` gestionada por TimescaleDB en Aiven Cloud. Esta tabla opera bajo una semántica de solo inserción (*Append-Only*), prescindiendo de borrados lógicos y restricciones foráneas pesadas en tiempo de ejecución, y aplicando políticas automáticas de compresión columnar para reducir la huella en disco en más de un 90%.

Sobre esta telemetría continua, el motor de inferencia `PredictiveAnomalyDetectionEngine` evalúa correlaciones matemáticas en tiempo real. Cuando los parámetros exceden umbrales térmicos o eléctricos seguros, o cuando la computadora del auto (ECU/PCM) emite códigos de avería de diagnóstico (DTC - *Diagnostic Trouble Codes* bajo el estándar SAE J2012), el sistema formula una `PredictiveAlert` con un puntaje de confianza algorítmica (`confidence_score`). De manera inmediata, esta alerta vincula un servicio preventivo del catálogo de MRO y se despacha como notificación push de alta prioridad mediante Firebase Cloud Messaging (FCM) al conductor en `Atelier Driver` y al asesor del taller en `Atelier Workshop`, permitiendo una intervención correctiva oportuna.

#### 2.6.9.1. Domain Layer

La capa de dominio de IoT Telemetry & Predictive Maintenance contiene los modelos de representación de hardware telemático, la ingestión de series temporales de alta velocidad, la clasificación taxonómica de fallas vehiculares y los motores analíticos predictivos. En la @tbl:iot-domain-types se detalla el conjunto de componentes tácticos de este paquete.

| Clase o Tipo | Categoría Táctica | Responsabilidad Principal en el Dominio |
| :--- | :--- | :--- |
| `Obd2Device` | Raíz de Agregado | Custodia el inventario de escáneres OBD-II, canales físicos de enlace y estado operativo. |
| `DeviceInstallation` | Raíz de Agregado | Gobierna el ciclo de vinculación física temporal del escáner en el puerto de un automóvil. |
| `TelemetryRecord` | Agregado de Serie Temporal | Representación inmutable de una lectura instantánea de sensores vehiculares en la hipertabla. |
| `VehicleFault` | Raíz de Agregado | Modela un código de avería DTC activo o histórico emitido por la computadora del vehículo. |
| `PredictiveAlert` | Raíz de Agregado | Alerta de mantenimiento proactivo formulada por el motor analítico ante anomalías inminentes. |
| `DtcCatalogEntry` | Entidad Dependiente | Registro estandarizado del catálogo internacional SAE/ISO de códigos de falla automotriz. |
| `DeviceId` | Objeto de Valor | Identificador universal único (`UUID`) fuertemente tipado para escáneres OBD-II. |
| `InstallationId` | Objeto de Valor | Identificador universal único (`UUID`) para sesiones de instalación en vehículos. |
| `FaultId` | Objeto de Valor | Identificador universal único (`UUID`) para diagnósticos de falla vehicular. |
| `AlertId` | Objeto de Valor | Identificador universal único (`UUID`) para advertencias de mantenimiento predictivo. |
| `DeviceIdentifier` | Objeto de Valor | Dirección física MAC Bluetooth o código IMEI de 15 dígitos validado sintácticamente. |
| `ConnectionType` | Enumeración de Dominio | Canal de comunicación telemática (`BLUETOOTH_BLE`, `SIM_CELLULAR`, `WIFI`). |
| `DeviceStatus` | Enumeración de Dominio | Estado operativo del dispositivo (`ACTIVE`, `INACTIVE`, `LOST`, `BROKEN`). |
| `DtcCode` | Objeto de Valor | Código alfanumérico normalizado SAE J2012 (ej. `P0300`, `P0420`, `B0001`). |
| `FaultSeverity` | Enumeración de Dominio | Gravedad del desperfecto detectado (`LOW`, `MEDIUM`, `CRITICAL`). |
| `ConfidenceScore` | Objeto de Valor | Probabilidad porcentual estimada del fallo inminente ($0.00\% \le p \le 100.00\%$). |
| `EngineTemperature` | Objeto de Valor | Temperatura del refrigerante del motor en grados Celsius con lógica de sobrecalentamiento. |
| `EngineRpm` | Objeto de Valor | Revoluciones por minuto del cigüeñal con métodos de detección de sobre-revolución. |
| `VehicleSpeed` | Objeto de Valor | Velocidad instantánea de desplazamiento del automóvil en kilómetros por hora. |
| `BatteryVoltage` | Objeto de Valor | Tensión eléctrica del sistema de carga en voltios con alerta de degradación de batería. |
| `FuelLevel` | Objeto de Valor | Porcentaje del tanque de combustible remanente ($0.0\% \le f \le 100.0\%$). |
| `AlertType` | Enumeración de Dominio | Clasificación analítica de la amenaza (`ENGINE_OVERHEATING_RISK`, `BATTERY_FAILURE_RISK`, etc.). |
| `AlertStatus` | Enumeración de Dominio | Situación operativa de la alerta (`DISPATCHED`, `ACKNOWLEDGED`, `RESOLVED`, `DISMISSED`). |
| `PredictiveAnomalyDetectionEngine` | Servicio de Dominio | Motor analítico que procesa telemetría en tiempo real y calcula riesgos de rotura mecánica. |
| `DtcCodeEvaluationService` | Servicio de Dominio | Mapea la gravedad y subsistema vehicular afectado a partir del código alfanumérico DTC. |
| `Obd2DeviceRepository` | Puerto de Salida | Contrato de persistencia de dominio para la Raíz de Agregado `Obd2Device`. |
| `DeviceInstallationRepository` | Puerto de Salida | Contrato de persistencia de dominio para la Raíz de Agregado `DeviceInstallation`. |
| `TelemetryLogRepository` | Puerto de Salida | Contrato de persistencia e inserción masiva JDBC en hipertablas TimescaleDB. |
| `VehicleFaultRepository` | Puerto de Salida | Contrato de persistencia de dominio para la Raíz de Agregado `VehicleFault`. |
| `PredictiveAlertRepository` | Puerto de Salida | Contrato de persistencia de dominio para la Raíz de Agregado `PredictiveAlert`. |
| `Obd2DeviceRegisteredEvent` | Evento de Dominio | Notifica el alta y catalogación de un nuevo escáner en el parque de hardware del taller. |
| `DeviceInstalledOnVehicleEvent` | Evento de Dominio | Notifica el acople físico de un escáner en el puerto OBD-II de un automóvil. |
| `DeviceUninstalledFromVehicleEvent` | Evento de Dominio | Notifica la desconexión del escáner y el asentamiento del kilometraje final. |
| `TelemetryBatchIngestedEvent` | Evento de Dominio | Notifica el procesamiento satisfactorio de una ráfaga masiva de telemetría. |
| `CriticalEngineAnomalyDetectedEvent` | Evento de Dominio | Notifica que los sensores del motor han traspasado umbrales mecánicos de peligro crítico. |
| `VehicleFaultDetectedEvent` | Evento de Dominio | Notifica la captura de un código de avería DTC emitido por la computadora a bordo. |
| `PredictiveAlertDispatchedEvent` | Evento de Dominio | Notifica la distribución exitosa de la alerta push a través de Firebase Cloud Messaging. |
: Catálogo de Tipos de Dominio del Bounded Context IoT Telemetry & Predictive Maintenance {#tbl:iot-domain-types}

*Nota.* Componentes tácticos pertenecientes al paquete com.andeva.atelier.platform.iot.domain.

**Raíces de Agregado y Entidades Dependientes de IoT Telemetry**

1. `Obd2Device`: Modela el equipo físico de diagnóstico a bordo propiedad del taller o adquirido bajo modalidad BYOD (*Bring Your Own Device*). Custodia su identificación física inmutable (`deviceIdentifier`), su estándar de transmisión de datos (`connectionType`), su situación física (`status`) y los metadatos de firmware del fabricante. Asegura como regla de negocio que la dirección MAC o el código IMEI sean sintácticamente válidos y únicos en toda la infraestructura de la plataforma.

En la @tbl:iot-device-members se detallan los atributos y métodos de la raíz de agregado `Obd2Device`.

| Elemento | Tipo o Firma | Ámbito | Descripción y Reglas de Negocio |
| :--- | :--- | :---: | :--- |
| `id` | `DeviceId` | Privado | Identificador universal único del hardware. |
| `tenantId` | `TenantId` | Privado | Taller propietario o administrador del escáner. |
| `deviceIdentifier` | `DeviceIdentifier` | Privado | Dirección MAC Bluetooth o código IMEI celular validado unívocamente. |
| `connectionType` | `ConnectionType` | Privado | Canal de enlace físico (`BLUETOOTH_BLE`, `SIM_CELLULAR`, `WIFI`). |
| `status` | `DeviceStatus` | Privado | Estado operativo (`ACTIVE`, `INACTIVE`, `LOST`, `BROKEN`). |
| `hardwareModel` | `String` | Privado | Modelo del dispositivo provisto por el fabricante (ej. "ELM327 v2.1"). |
| `firmwareVersion` | `String` | Privado | Versión del software embebido instalado en el escáner. |
| `register` | `static Obd2Device register(...)` | Público | Factoría de dominio que valida el identificador y emite `Obd2DeviceRegisteredEvent`. |
| `markLost` | `void markLost()` | Público | Inhabilita el escáner por extravío, bloqueando la recepción de telemetría futura. |
| `markBroken` | `void markBroken()` | Público | Asienta la inoperatividad por daño físico en patio o manipulación indebida. |
| `updateFirmware` | `void updateFirmware(String version)`| Público | Registra la actualización de la versión de software embebido. |
: Miembros de la Raíz de Agregado Obd2Device {#tbl:iot-device-members}

*Nota.* Especificación de miembros de la clase Obd2Device del paquete com.andeva.atelier.platform.iot.domain.model.aggregates.

En cuanto a sus relaciones, `Obd2Device` hereda de `AbstractDomainAggregateRoot<Obd2Device>` y se asocia mediante identificador inmutable con el taller propietario `TenantId`.

2. `DeviceInstallation`: Gobierna la sesión física de monitoreo telemático entre un dispositivo `Obd2Device` y un vehículo `Vehicle`. Controla las marcas temporales de inicio (`installedAt`) y conclusión (`uninstalledAt`), así como el odómetro de entrada y salida (`initialOdometerKm`, `finalOdometerKm`). Aplica como invariante que un dispositivo no puede estar instalado simultáneamente en más de un automóvil, ni un vehículo puede tener asignados múltiples escáneres activos en el mismo intervalo de tiempo.

En la @tbl:iot-installation-members se especifican los componentes de la raíz de agregado `DeviceInstallation`.

| Elemento | Tipo o Firma | Ámbito | Descripción y Reglas de Negocio |
| :--- | :--- | :---: | :--- |
| `id` | `InstallationId` | Privado | Identificador universal único de la instalación. |
| `deviceId` | `DeviceId` | Privado | Escáner físico conectado al vehículo. |
| `vehicleId` | `VehicleId` | Privado | Automóvil intervenido y monitoreado. |
| `tenantId` | `TenantId` | Privado | Taller responsable del servicio de telemetría. |
| `installedAt` | `Instant` | Privado | Marca de tiempo UTC de inicio del monitoreo en foso. |
| `uninstalledAt` | `Optional<Instant>` | Privado | Marca de tiempo UTC de desconexión (nula mientras siga activo). |
| `initialOdometerKm`| `int` | Privado | Kilometraje del vehículo al momento de la instalación ($\ge 0$). |
| `finalOdometerKm` | `Optional<Integer>` | Privado | Kilometraje verificado al momento del retiro ($\ge initialOdometerKm$). |
| `install` | `static DeviceInstallation install(...)` | Público | Factoría que vincula el hardware y emite `DeviceInstalledOnVehicleEvent`. |
| `uninstall` | `void uninstall(int finalKm, ...)`| Público | Concluye la sesión telemática y emite `DeviceUninstalledFromVehicleEvent`. |
| `isActive` | `boolean isActive()` | Público | Determina si la sesión de telemetría continúa transmitiendo activamente. |
: Miembros de la Raíz de Agregado DeviceInstallation {#tbl:iot-installation-members}

*Nota.* Especificación de miembros de DeviceInstallation del paquete com.andeva.atelier.platform.iot.domain.model.aggregates.

Respecto a sus relaciones, `DeviceInstallation` hereda de `AbstractDomainAggregateRoot<DeviceInstallation>`, manteniendo asociaciones por clave foránea de dominio con `DeviceId`, `VehicleId` y `TenantId`.

3. `TelemetryRecord`: Modela una lectura instantánea e inmutable de parámetros de sensores del automóvil persistida en la hipertabla particionada de TimescaleDB. Contiene atributos clave como `timestamp`, `vehicleId`, `tenantId`, `location: Optional<GeoCoordinates>`, `speed: VehicleSpeed`, `engineTemperature: EngineTemperature`, `engineRpm: EngineRpm`, `fuelLevel: Optional<FuelLevel>` y `batteryVoltage: Optional<BatteryVoltage>`. Carece deliberadamente de estado mutable y de lógica de borrado; su integridad física se fundamenta en su inserción secuencial y agregación estadística por cubos de tiempo (*time_buckets*).

4. `VehicleFault`: Representa un código de error de diagnóstico (**DTC**) emitido formalmente por la unidad de control del motor (ECU) o computadora de transmisión del automóvil. Almacena el código estandarizado (`dtcCode: DtcCode`), el nivel de severidad asignado (`severity: FaultSeverity`), la glosa técnica oficial que identifica el subsistema comprometido (`description`), la marca temporal de detección (`detectedAt`) y el estado de reparación en taller (`isResolved: boolean`). Permite trazar el historial patológico del automóvil a lo largo de su vida útil.

5. `PredictiveAlert`: Raíz de agregado que materializa una recomendación de intervención mecánica preventiva formulada por el motor de inferencia. En la @tbl:iot-alert-members se detallan los elementos que estructuran esta raíz de agregado.

| Elemento | Tipo o Firma | Ámbito | Descripción y Reglas de Negocio |
| :--- | :--- | :---: | :--- |
| `id` | `AlertId` | Privado | Identificador universal único de la alerta generada. |
| `vehicleId` | `VehicleId` | Privado | Automóvil en riesgo inminente de avería. |
| `tenantId` | `TenantId` | Privado | Taller automotriz que asiste la unidad. |
| `recommendedServiceId`| `Optional<ServiceId>`| Privado | Servicio preventivo sugerido del catálogo de MRO para solucionar la causa raíz. |
| `alertType` | `AlertType` | Privado | Clasificación del riesgo (`ENGINE_OVERHEATING_RISK`, `BATTERY_FAILURE_RISK`, etc.). |
| `confidenceScore` | `ConfidenceScore` | Privado | Probabilidad porcentual matemática calculada por el motor algorítmico. |
| `message` | `String` | Privado | Glosa redactada en lenguaje comprensible y no técnico orientada al conductor. |
| `status` | `AlertStatus` | Privado | Estado operativo de la notificación (`DISPATCHED`, `ACKNOWLEDGED`, `RESOLVED`). |
| `fcmMessageId` | `Optional<String>` | Privado | Identificador de entrega devuelto por la API de Firebase Cloud Messaging. |
| `createdAt` | `Instant` | Privado | Marca de tiempo UTC en que se detectó la anomalía y formuló la alerta. |
| `generate` | `static PredictiveAlert generate(...)` | Público | Factoría de dominio que asienta la alerta y emite `PredictiveAlertDispatchedEvent`. |
| `markDispatched` | `void markDispatched(String fcmId)` | Público | Registra el identificador de entrega push tras su envío por FCM. |
| `acknowledge` | `void acknowledge()` | Público | Registra la confirmación de lectura por parte del conductor en la app móvil. |
| `resolve` | `void resolve()` | Público | Cierra la alerta tras ejecutarse la reparación correspondiente en el taller. |
| `dismiss` | `void dismiss()` | Público | Descarta la alerta por considerarse una falsa alarma o descarte del usuario. |
: Miembros de la Raíz de Agregado PredictiveAlert {#tbl:iot-alert-members}

*Nota.* Especificación de miembros de PredictiveAlert del paquete com.andeva.atelier.platform.iot.domain.model.aggregates.

En cuanto a sus relaciones, `PredictiveAlert` hereda de `AbstractDomainAggregateRoot<PredictiveAlert>` y mantiene referencias por identificador con `VehicleId`, `TenantId` y de forma opcional con `ServiceId` del catálogo de servicios de MRO.

**Objetos de Valor de IoT Telemetry & Predictive Maintenance**

En la @tbl:iot-value-objects se especifican los objetos de valor inmutables y las reglas de validación física que aseguran la consistencia de los datos telemáticos.

| Objeto de Valor | Atributos Clave | Restricciones de Validación y Reglas de Negocio |
| :--- | :--- | :--- |
| `DeviceIdentifier` | `value`: `String` | Expresión regular para MAC (`^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$`) o IMEI (`^[0-9]{15}$`). |
| `DtcCode` | `value`: `String` | Patrón SAE J2012 `^[P|C|B|U][0-9]{4}$`. Prefijo: `P` (tren motriz), `C` (chasis), `B` (carrocería), `U` (red). |
| `ConfidenceScore` | `value`: `BigDecimal` | Rango de certeza probabilística: $0.00 \le value \le 100.00$, formateado a dos decimales. |
| `EngineTemperature`| `celsius`: `double` | Rango admisible: $-40.0^\circ\text{C} \le celsius \le 200.0^\circ\text{C}$. Método `isCriticalOverheating()` si $> 105.0^\circ\text{C}$. |
| `EngineRpm` | `rpm`: `int` | Rango de giro: $0 \le rpm \le 12000$. Método `isExcessiveRpm()` si $rpm > 6000$. |
| `VehicleSpeed` | `kmh`: `int` | Velocidad de avance: $0 \le kmh \le 350$. |
| `BatteryVoltage` | `volts`: `double` | Tensión de circuito: $0.0\text{V} \le volts \le 30.0\text{V}$. Método `isLowBattery()` si $volts < 11.8\text{V}$. |
: Objetos de Valor del Bounded Context IoT Telemetry & Predictive Maintenance {#tbl:iot-value-objects}

*Nota.* Especificación de Objetos de Valor del paquete com.andeva.atelier.platform.iot.domain.model.valueobjects.

**Servicios de Dominio de IoT Telemetry & Predictive Maintenance**

1. `PredictiveAnomalyDetectionEngine`: Motor analítico de inferencia en tiempo real que examina cada lote de lecturas de telemetría ingestadas. Evalúa reglas heurísticas fundamentadas en termodinámica automotriz y degradación de componentes electromecánicos:
   * **Sobrecalentamiento Crítico de Refrigerante:** Si la temperatura del refrigerante $T$ supera el umbral crítico ($T > 105.0^\circ\text{C}$) mientras el vehículo está en marcha, evalúa el gradiente térmico. Si $T \ge 115.0^\circ\text{C}$, asigna una certidumbre de avería inminente del $98.50\%$; en caso contrario ($105.0^\circ\text{C} < T < 115.0^\circ\text{C}$), asigna un puntaje del $88.00\%$, formulando una alerta de tipo `ENGINE_OVERHEATING_RISK` para evitar el soplado del empaque de culata o la deformación del bloque de motor.
   * **Degradación Severa de Batería y Sistema de Carga:** Si la tensión eléctrica en reposo $V$ (con velocidad $0\text{ km/h}$) decae por debajo de $11.80\text{ V}$, el motor diagnostica una probabilidad del $91.20\%$ de fallo en el encendido subsecuente, formulando una alerta `BATTERY_FAILURE_RISK`.
   * **Fallas de Combustión en Cilindros:** Ante la captura de ráfagas de códigos DTC en el rango `P0300` a `P0304` asociados con fluctuaciones erráticas de RPM en ralentí, genera una alerta `CYLINDER_MISFIRE_HAZARD` con $95.00\%$ de confianza por riesgo de contaminación y fundición del convertidor catalítico.

2. `DtcCodeEvaluationService`: Servicio de enriquecimiento taxonómico de fallas vehiculares. Clasifica los códigos leídos según el estándar SAE J2012 / ISO 15031, asociando su categoría funcional (Tren motriz, Chasis, Carrocería o Comunicaciones de Red) con su nivel de gravedad predeterminado y sugiriendo la vinculación automática con los paquetes correctivos del catálogo de MRO.

**Puertos de Repositorio de la Capa de Dominio**

En la @tbl:iot-repository-ports se definen las interfaces de salida que gobiernan el acceso a los datos de telemetría y diagnóstico.

| Puerto de Repositorio | Métodos Principales | Responsabilidad de Dominio |
| :--- | :--- | :--- |
| `Obd2DeviceRepository` | `save`, `findById`, `findByIdentifier`, `findAllByTenantId` | Persistencia y gestión del catálogo de hardware telemático. |
| `DeviceInstallationRepository` | `save`, `findById`, `findActiveByVehicleId`, `findActiveByDeviceId` | Trazabilidad de sesiones de montaje y acople de escáneres en autos. |
| `TelemetryLogRepository` | `saveAllBatch`, `findLatestByVehicleId`, `findHistoryAggregated` | Inserción JDBC de alta velocidad y agregación temporal en TimescaleDB. |
| `VehicleFaultRepository` | `save`, `findById`, `findActiveByVehicleId`, `findAllByVehicleId` | Almacenamiento histórico de códigos de error y diagnósticos técnicos. |
| `PredictiveAlertRepository` | `save`, `findById`, `findAllByVehicleId`, `findAllByTenantIdAndStatus`| Gestión del ciclo de vida y despacho de alertas predictivas de avería. |
: Puertos de Repositorio del Bounded Context IoT Telemetry & Predictive Maintenance {#tbl:iot-repository-ports}

*Nota.* Interfaces de salida del paquete com.andeva.atelier.platform.iot.domain.repositories.

**Eventos de Dominio y Manejo de Errores Semánticos**

El subsistema de telemetría orquesta su comportamiento asíncrono a través de eventos de dominio especializados:
* `Obd2DeviceRegisteredEvent`: Notifica la incorporación de un nuevo dispositivo al stock del taller.
* `DeviceInstalledOnVehicleEvent`: Inicia formalmente el monitoreo proactivo del automóvil en la aplicación del conductor.
* `DeviceUninstalledFromVehicleEvent`: Concluye el período de servicio telemático y actualiza el odómetro final del vehículo en CRM.
* `TelemetryBatchIngestedEvent`: Notifica a los motores de suscripción y cuotas la actividad periódica del vehículo.
* `CriticalEngineAnomalyDetectedEvent`: Desencadena de forma inmediata la formulación de la alerta predictiva y el aviso al asesor del taller.
* `PredictiveAlertDispatchedEvent`: Comunica al gateway de Firebase la necesidad de emitir la notificación push a los smartphones vinculados.

Los errores semánticos y anomalías en las tramas telemáticas son gestionados mediante el tipo `Result<T, ApplicationError>` y excepciones tipadas (`DeviceAlreadyAssignedException`, `InvalidDtcCodeException`, `DeviceNotFoundException`, `TelemetryIngestionException`).



#### 2.6.9.2. Interface Layer



#### 2.6.9.3. Application Layer



#### 2.6.9.4 Infrastructure Layer



#### 2.6.9.5. Bounded Context Software Architecture Component Level Diagrams



#### 2.6.9.6. Bounded Context Software Architecture Code Level Diagrams



##### 2.6.9.6.1. *Bounded Context Domain Layer Class Diagrams*



##### 2.6.9.6.2. *Bounded Context Database Design Diagram*



\newpage