### 2.6.7. *Bounded Context: Invoicing & Compliance*

El Bounded Context de Invoicing & Compliance encapsula la totalidad de las reglas contables, fiscales y tributarias exigidas por la legislación peruana bajo la supervisión de la Superintendencia Nacional de Aduanas y de Administración Tributaria (SUNAT), operando bajo el estándar internacional Universal Business Language (UBL 2.1). Su delimitación táctica en la arquitectura de Atelier responde a la necesidad crítica de blindar el núcleo operativo del taller frente a la volatilidad de la normativa tributaria nacional.

En el ecosistema automotriz independiente del Perú, la facturación representa un punto de fricción crítico. Una proporción significativa de talleres mecánicos opera en la informalidad o gestiona comprobantes mediante talonarios físicos manuales, exponiéndose a sanciones tributarias severas y perdiendo la oportunidad de atender flotas corporativas que exigen facturas electrónicas válidas para sustentar costos y deducir crédito fiscal del Impuesto General a las Ventas (IGV). Aquellos talleres que han adoptado facturación electrónica suelen lidiar con sistemas desconectados que obligan a digitar doblemente los repuestos y la mano de obra, propiciando errores humanos en montos y correlativos.

Para resolver este desafío, el contexto establece una clara diferenciación arquitectónica entre dos flujos comerciales complementarios: mientras el contexto de SaaS Billing & Subscriptions gestiona la recaudación recurrente que Andeva percibe de los talleres mecánicos mediante Stripe, Invoicing & Compliance gobierna exclusivamente la emisión de comprobantes que el taller extiende a sus propios clientes (conductores particulares y flotas comerciales). 

El modelo táctico sitúa a la raíz de agregado `ElectronicVoucher` en el centro del dominio, gestionando el ciclo de vida fiscal de los comprobantes electrónicos autorizados por SUNAT: Factura Electrónica (código legal `01`, exigiendo RUC válido de 11 dígitos), Boleta de Venta Electrónica (código legal `03`, para consumidores finales) y Nota de Crédito Electrónica (código legal `07`, para anulaciones y rectificaciones monetarias). Asimismo, el agregado `SeriesConfiguration` gobierna el avance atómico e inviolable de los correlativos numéricos por sucursal física, eliminando el riesgo de duplicidad de numeración.

A nivel de integración y resiliencia, el contexto incorpora una Capa Anticorrupción (ACL) hacia Nubefact, actuando este como Proveedor de Servicios Electrónicos (PSE) homologado ante SUNAT. Mediante el patrón Transactional Outbox, los comprobantes generados localmente se persisten en estado emitido (`ISSUED`) y se encolan para su despacho asíncrono, garantizando que una intermitencia temporal en los servidores tributarios del Estado jamás interrumpa la entrega física del automóvil reparado en el taller.

#### 2.6.7.1. Domain Layer

La Capa de Dominio de Invoicing & Compliance constituye el núcleo tributario, contable y fiscal de Atelier Platform, estructurada bajo el paquete canónico com.andeva.atelier.platform.invoicing.domain. Su propósito arquitectónico consiste en gobernar con pureza y determinismo el ciclo de vida de los comprobantes electrónicos autorizados por la Superintendencia Nacional de Aduanas y de Administración Tributaria (SUNAT), aislando los cálculos impositivos y la lógica de validación respecto a la infraestructura de persistencia relacional y proveedores telemáticos externos.

Para salvaguardar la soberanía tributaria y garantizar una conciliación financiera fidedigna en las operaciones del taller, la arquitectura de dominio se fundamenta en cuatro pilares tácticos esenciales:
- Inmutabilidad fiscal y rigurosidad contable bajo los lineamientos del estándar UBL 2.1 y directivas de SUNAT.
- Determinismo matemático en la segregación del Impuesto General a las Ventas mediante redondeo bancario Half-Even a dos decimales.
- Integridad y secuencialidad atómica de correlativos numéricos por sucursal física para prevenir saltos o duplicidades.
- Trazabilidad documental y probatoria con enlace a representaciones digitales oficiales y orquestación reactiva desacoplada.

En la @tbl:invoicing-domain-types se expone el catálogo taxonómico consolidado de los componentes tácticos que estructuran la Capa de Dominio de Invoicing & Compliance, clasificando sus responsabilidades, relaciones cardinales y paquetes canónicos.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo de la Capa de Dominio del Bounded Context Invoicing \& Compliance} \label{tbl:invoicing-domain-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\
\hline
\endhead
Electronic\allowbreak Voucher & Raíz de consistencia del comprobante electrónico. Gobierna ciclo de vida fiscal, partidas gravadas, cálculo de IGV y liquidación financiera. \\*
\hline
\textbf{Categoría} & Raíz de Agregado \\*
\hline
\textbf{Relaciones} & Generalización de AbstractDomainAggregateRoot<ElectronicVoucher>. Composición 1 a N con VoucherLine y VoucherPayment. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Series\allowbreak Configuration & Raíz de consistencia de series y correlativos fiscales. Custodia el contador secuencial atómico estricto por sede y tipo tributario. \\*
\hline
\textbf{Categoría} & Raíz de Agregado \\*
\hline
\textbf{Relaciones} & Generalización de AbstractDomainAggregateRoot<SeriesConfiguration>. Referencia a TenantId, BranchId y VoucherType. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Voucher\allowbreak Line & Partida individual gravada del comprobante. Modela repuesto o servicio con desglose de base imponible, tasa de IGV e importe total. \\*
\hline
\textbf{Categoría} & Entidad Dependiente \\*
\hline
\textbf{Relaciones} & Dependiente subordinada a ElectronicVoucher. Referencia opcional a InventoryItemId o ServiceId. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Voucher\allowbreak Payment & Asiento de amortización financiera del comprobante. Modela medios de pago, referencias de conciliación de caja y monto amortizado. \\*
\hline
\textbf{Categoría} & Entidad Dependiente \\*
\hline
\textbf{Relaciones} & Dependiente subordinada a ElectronicVoucher. Referencia a TenantId, BranchId y PaymentId. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
VoucherId & Identificador único universal fuertemente tipado para el comprobante electrónico. \\*
\hline
\textbf{Categoría} & Identificador Fuertemente Tipado \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak ids} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Series\allowbreak ConfigurationId & Identificador único universal fuertemente tipado para la configuración de series fiscales. \\*
\hline
\textbf{Categoría} & Identificador Fuertemente Tipado \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak ids} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PaymentId & Identificador único universal fuertemente tipado para asientos de amortización financiera. \\*
\hline
\textbf{Categoría} & Identificador Fuertemente Tipado \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak ids} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Voucher\allowbreak LineId & Identificador único universal fuertemente tipado para partidas individuales del comprobante. \\*
\hline
\textbf{Categoría} & Identificador Fuertemente Tipado \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak ids} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
VoucherSerie & Serie fiscal de cuatro caracteres alfanuméricos con validación reglamentaria de patrón SUNAT. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Registro inmutable con expresión regular iniciada con F, B o T. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
VoucherNumber & Correlativo numérico entero estrictamente positivo con formateo legal a ocho dígitos. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Registro inmutable con validación de entero mayor a cero. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Tax\allowbreak Calculation & Estructura inmutable que consolida subtotal, monto de IGV, tasa impositiva y precio de venta total. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Registro inmutable con invariante aritmética de cuadre tributario. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Customer\allowbreak FiscalInfo & Identificación tributaria del receptor formal con RUC o DNI, razón social y domicilio fiscal. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Registro inmutable que referencia TaxId y DocumentType. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Digital\allowbreak ReceiptUrls & Enlaces de descarga segura HTTPS a las representaciones oficiales PDF, XML firmado y CDR de SUNAT. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Registro inmutable con validación de protocolo de transferencia seguro. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
SunatResponse & Metadatos fiscales del dictamen del PSE y SUNAT con código de respuesta, glosa y firma digital SHA-256. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Registro inmutable emitido tras procesamiento telemático. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Voided\allowbreak Info & Registro probatorio formal de la causal justificada y timestamp de la anulación o comunicación de baja. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Registro inmutable referenciado por ElectronicVoucher. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Cash\allowbreak Flow\allowbreak Movement & Registro inmutable de movimiento financiero individual consolidado en el flujo de caja del taller. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Registro inmutable referenciado en liquidaciones y reportes de tesorería. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Cash\allowbreak Flow\allowbreak Summary & Consolidado analítico de ingresos, egresos y balance neto en el cierre de caja de la sucursal. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Registro inmutable producido por servicios de agregación de flujo monetario. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
VoucherType & Catálogo oficial de tipos de comprobante según tabla 10 de SUNAT (Factura 01, Boleta 03, Nota de Crédito 07). \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada por ElectronicVoucher y SeriesConfiguration. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak enums} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
VoucherStatus & Estados del ciclo de vida tributario del comprobante (DRAFT, ISSUED, ACCEPTED\_SUNAT, REJECTED\_SUNAT, VOIDED). \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada por la raíz de agregado ElectronicVoucher. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak enums} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PaymentMethod & Medios de pago autorizados para liquidación en caja (CASH, CREDIT\_CARD, DEBIT\_CARD, BANK\_TRANSFER, DIGITAL\_WALLET\_YAPE, DIGITAL\_WALLET\_PLIN). \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada por la entidad dependiente VoucherPayment. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak enums} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PaymentStatus & Estados de la transacción financiera de liquidación (PENDING, COMPLETED, REFUNDED). \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada por la entidad dependiente VoucherPayment. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak enums} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
VoucherItemType & Clasificación comercial del renglón facturado entre repuesto material o servicio técnico (PRODUCT, SERVICE). \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada por la entidad dependiente VoucherLine. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak enums} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Credit\allowbreak NoteReason & Catálogo 09 de SUNAT para causales legales de emisión de notas de crédito electrónicas. \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada en emisión y validación de notas de crédito. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak enums} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Peruvian\allowbreak Tax\allowbreak Calculation\allowbreak Engine & Motor de cálculo matemático impositivo. Segrega base imponible e IGV bajo redondeo bancario Half-Even a dos y cuatro decimales. \\*
\hline
\textbf{Categoría} & Servicio de Dominio \\*
\hline
\textbf{Relaciones} & Servicio puro sin estado consumido por agregados y factorías. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Voucher\allowbreak Validation\allowbreak Service & Validador de consistencia fiscal peruana. Verifica RUC con algoritmo Módulo 11, tope de boletas y reglas de notas de crédito. \\*
\hline
\textbf{Categoría} & Servicio de Dominio \\*
\hline
\textbf{Relaciones} & Servicio puro sin estado consumido por agregados y comandos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Series\allowbreak Correlative\allowbreak Service & Orquestador del avance atómico y secuencial de series correlativas con control de concurrencia y límites legales. \\*
\hline
\textbf{Categoría} & Servicio de Dominio \\*
\hline
\textbf{Relaciones} & Coordina la raíz SeriesConfiguration y su persistencia. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Electronic\allowbreak Voucher\allowbreak Repository & Contrato agnóstico de persistencia para la raíz de agregado ElectronicVoucher. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Implementado en la capa de infraestructura JPA. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Series\allowbreak Configuration\allowbreak Repository & Contrato agnóstico de persistencia para la raíz de agregado SeriesConfiguration. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Implementado en la capa de infraestructura JPA. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Voucher\allowbreak Payment\allowbreak Repository & Contrato agnóstico de persistencia para la entidad dependiente VoucherPayment. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Implementado en la capa de infraestructura JPA. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Electronic\allowbreak Voucher\allowbreak Issued\allowbreak Event & Notifica la emisión local del comprobante y su encolamiento para despacho a SUNAT. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Voucher\allowbreak Accepted\allowbreak By\allowbreak Sunat\allowbreak Event & Notifica la aceptación legal del comprobante con obtención de firma digital y CDR de SUNAT. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Voucher\allowbreak Rejected\allowbreak By\allowbreak Sunat\allowbreak Event & Notifica el rechazo tributario por discrepancias normativas o de firma digital. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Voucher\allowbreak Voided\allowbreak Event & Notifica la comunicación de baja y anulación formal del comprobante ante SUNAT. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Voucher\allowbreak Payment\allowbreak Registered\allowbreak Event & Notifica el asentamiento de un cobro financiero en caja contra el comprobante fiscal. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Series\allowbreak Configuration\allowbreak Created\allowbreak Event & Notifica la habilitación de una nueva serie fiscal autorizada en una sucursal del taller. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Series\allowbreak Correlative\allowbreak Incremented\allowbreak Event & Notifica el avance numérico secuencial del correlativo asignado a un comprobante. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Credit\allowbreak Note\allowbreak Issued\allowbreak Event & Notifica la emisión de una nota de crédito vinculada para rectificación o anulación de saldo. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak events} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Catálogo taxonómico de los componentes tácticos de la Capa de Dominio de Invoicing \& Compliance.

**Raíces de Agregado y Entidades Dependientes de Invoicing & Compliance**

La raíz de agregado **ElectronicVoucher** custodia los límites de consistencia transaccional del comprobante electrónico de pago, orquestando su ciclo de vida tributario bajo las directivas del estándar UBL 2.1. Como garante de la integridad fiscal, coordina la colección de partidas gravadas mediante **VoucherLine** y el registro de cobros efectivos mediante **VoucherPayment**, prohibiendo cualquier mutación de estado que comprometa el cuadre monetario o vulnere las disposiciones del ente recaudador.

La entidad impone invariantes estrictas según el tipo de documento emitido. Para facturas comerciales exige la acreditación obligatoria de un número de RUC válido mediante **TaxId**, razón social formal y dirección fiscal. Para boletas de venta cuyo importe supere los 700.00 PEN, demanda la identificación plena del adquiriente mediante documento de identidad. Al alcanzar el estado terminal **ACCEPTED_SUNAT**, el comprobante adquiere inmutabilidad legal absoluta, restringiendo rectificaciones posteriores a la emisión de una nota de crédito formal.

En la @tbl:invoicing-voucher-members se detallan los atributos, signaturas de operaciones y reglas de consistencia interna de la raíz de agregado **ElectronicVoucher**.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de la Raíz de Agregado ElectronicVoucher} \label{tbl:invoicing-voucher-members} \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Raíz de Agregado:} ElectronicVoucher (Comprobante Electrónico Tributario)} \\*
\hline
id & Identificador universal único del comprobante electrónico. Inmutable y no nulo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{VoucherId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
tenantId & Taller automotriz emisor del comprobante fiscal. Clave de aislamiento multitenant. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TenantId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
branchId & Sede física del taller donde se concretó la operación comercial gravada. \\*
\hline
\textbf{Tipo o Firma} & \texttt{BranchId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
customerId & Cliente receptor del comprobante electrónico registrado en el padrón de CRM. \\*
\hline
\textbf{Tipo o Firma} & \texttt{CustomerId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
workOrderId & Orden de trabajo de MRO que motivó la facturación. Opcional en ventas libres de mostrador. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Optional<\allowbreak WorkOrderId>} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
voucherType & Tipología tributaria legal autorizada por SUNAT (FACTURA, BOLETA, NOTA\_CREDITO). \\*
\hline
\textbf{Tipo o Firma} & \texttt{VoucherType} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
serie & Serie alfanumérica de cuatro caracteres conforme a normativa de SUNAT. \\*
\hline
\textbf{Tipo o Firma} & \texttt{VoucherSerie} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
number & Correlativo numérico secuencial positivo único por serie en la sucursal. \\*
\hline
\textbf{Tipo o Firma} & \texttt{VoucherNumber} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
taxCalculation & Agrupador inmutable de importes con base imponible, IGV (18\%) y total general. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TaxCalculation} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
currency & Denominación monetaria de curso legal de la transacción (PEN, USD). \\*
\hline
\textbf{Tipo o Firma} & \texttt{Currency} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
status & Estado del comprobante en su ciclo de vida fiscal (DRAFT, ISSUED, ACCEPTED\_SUNAT, REJECTED\_SUNAT, VOIDED). \\*
\hline
\textbf{Tipo o Firma} & \texttt{VoucherStatus} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
customerFiscalInfo & Información tributaria del receptor con RUC o DNI, razón social y domicilio legal. \\*
\hline
\textbf{Tipo o Firma} & \texttt{CustomerFiscalInfo} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
digitalReceiptUrls & Direcciones HTTPS a las representaciones oficiales PDF, XML firmado y CDR de SUNAT. \\*
\hline
\textbf{Tipo o Firma} & \texttt{DigitalReceiptUrls} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
sunatResponse & Dictamen técnico retornado por el PSE con código de respuesta, glosa y hash SHA-256. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Optional<\allowbreak SunatResponse>} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
voidedInfo & Registro documental con causal justificada y timestamp de comunicación de baja tributaria. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Optional<\allowbreak VoidedInfo>} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
lines & Colección inmutable interna de partidas individuales gravadas de servicios y repuestos. \\*
\hline
\textbf{Tipo o Firma} & \texttt{List<\allowbreak VoucherLine>} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
payments & Colección inmutable interna de asientos de amortización y recaudación en caja. \\*
\hline
\textbf{Tipo o Firma} & \texttt{List<\allowbreak VoucherPayment>} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
issue & Factoría que liquida impuestos con redondeo Half-Even, valida reglas fiscales y emite ElectronicVoucherIssuedEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{static ElectronicVoucher issue(TenantId tenantId,\allowbreak  BranchId branchId,\allowbreak  CustomerId customerId,\allowbreak  Optional<\allowbreak WorkOrderId> workOrderId,\allowbreak  VoucherType type,\allowbreak  VoucherSerie serie,\allowbreak  VoucherNumber number,\allowbreak  CustomerFiscalInfo info,\allowbreak  Currency currency,\allowbreak  List<\allowbreak VoucherLine> lines)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
issueCreditNote & Factoría para emitir notas de crédito vinculadas a comprobantes de origen, registrando CreditNoteIssuedEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{static ElectronicVoucher issueCreditNote(TenantId tenantId,\allowbreak  BranchId branchId,\allowbreak  CustomerId customerId,\allowbreak  VoucherId refVoucherId,\allowbreak  VoucherSerie serie,\allowbreak  VoucherNumber number,\allowbreak  CreditNoteReason reason,\allowbreak  String reasonDesc,\allowbreak  List<\allowbreak VoucherLine> lines)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
markAcceptedBySunat & Asienta la conformidad tributaria con CDR de SUNAT, actualiza estado a ACCEPTED\_SUNAT y registra VoucherAcceptedBySunatEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void markAcceptedBySunat(String hash,\allowbreak  String desc,\allowbreak  DigitalReceiptUrls urls)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
markRejectedBySunat & Asienta el rechazo fiscal devuelto por el PSE, actualiza estado a REJECTED\_SUNAT y emite VoucherRejectedBySunatEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void markRejectedBySunat(String errorCode,\allowbreak  String errorMessage)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
voidVoucher & Comunica la baja del comprobante ante SUNAT, conmuta estado a VOIDED y genera VoucherVoidedEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void voidVoucher(String reason,\allowbreak  Instant voidedAt)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
recordPayment & Incorpora un abono financiero contra el comprobante, verifica saldo pendiente y emite VoucherPaymentRegisteredEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{VoucherPayment recordPayment(PaymentId paymentId,\allowbreak  Money amount,\allowbreak  PaymentMethod method,\allowbreak  String transactionRef)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
isFullyPaid & Evalúa si la sumatoria de cobros completados cubre la totalidad del importe facturado. \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean isFullyPaid()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
getPendingBalance & Computa el saldo pendiente restando los cobros efectivos completados al total general. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money getPendingBalance()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de miembros y factorías de la raíz de agregado ElectronicVoucher del paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak aggregates.

La entidad dependiente **VoucherLine** modela cada partida imponible incorporada en el comprobante, asociando un repuesto suministrado por el almacén o un servicio técnico ejecutado por el personal mecánico. La entidad custodia la coherencia matemática de la línea al desglosar el valor unitario libre de tributos, el precio unitario con gravamen y el débito fiscal exacto, asegurando que la multiplicación de la cantidad por el precio unitario cuadre sin discrepancias con el total de la partida.

Por su parte, **VoucherPayment** registra los asientos de liquidación financiera en caja que extinguen la obligación de cobro contraída en el comprobante. La entidad exige registrar importes estrictamente positivos y valida que los cobros canalizados por transferencias bancarias o billeteras electrónicas incluyan el código de operación probatorio para auditorías de tesorería, habilitando al agregado para certificar la liquidación completa del saldo o calcular remanentes adeudados.

En la @tbl:invoicing-lines-payments-members se detallan los miembros, tipos y responsabilidades de las entidades dependientes **VoucherLine** y **VoucherPayment**.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de las Entidades Dependientes VoucherLine y VoucherPayment} \label{tbl:invoicing-lines-payments-members} \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad Dependiente:} VoucherLine (Partida Individual del Comprobante)} \\*
\hline
id & Identificador único universal de la línea de detalle. \\*
\hline
\textbf{Tipo o Firma} & \texttt{VoucherLineId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
voucherId & Referencia al comprobante electrónico padre al que pertenece la partida. \\*
\hline
\textbf{Tipo o Firma} & \texttt{VoucherId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
itemId & Identificador de la pieza de repuesto o servicio técnico facturado. Opcional para conceptos libres. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Optional<\allowbreak UUID>} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
itemType & Tipología del concepto comercial facturado (PRODUCT, SERVICE). \\*
\hline
\textbf{Tipo o Firma} & \texttt{VoucherItemType} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
description & Glosa descriptiva detallada del bien entregado o servicio mecánico ejecutado. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
quantity & Cantidad de unidades facturadas con precisión escalar fija a dos decimales. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Quantity} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
unitValue & Valor monetario unitario sin IGV exigido por UBL 2.1 y la API fiscal. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
unitPrice & Precio monetario unitario de venta al público con IGV incluido (18\%). \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
igvAmount & Monto impositivo de IGV liquidado para la partida individual. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
totalLine & Importe monetario total de la partida resultante de cantidad por precio unitario. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
create & Factoría de dominio que computa la segregación impositiva y el redondeo bancario Half-Even. \\*
\hline
\textbf{Tipo o Firma} & \texttt{static VoucherLine create(VoucherId voucherId,\allowbreak  Optional<\allowbreak UUID> itemId,\allowbreak  VoucherItemType itemType,\allowbreak  String description,\allowbreak  Quantity quantity,\allowbreak  Money unitPrice)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
calculateIgv & Recalcula internamente la base imponible y el gravamen ante variaciones del motor tributario. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void calculateIgv(PeruvianTaxCalculationEngine taxEngine)} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad Dependiente:} VoucherPayment (Liquidación Financiera y Abono en Caja)} \\*
\hline
id & Identificador único universal del asiento financiero de abono. \\*
\hline
\textbf{Tipo o Firma} & \texttt{PaymentId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
voucherId & Referencia al comprobante electrónico amortizado. \\*
\hline
\textbf{Tipo o Firma} & \texttt{VoucherId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
tenantId & Taller automotriz beneficiario de la recaudación monetaria. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TenantId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
branchId & Sede física del taller donde se produjo la cobranza en caja o terminal POS. \\*
\hline
\textbf{Tipo o Firma} & \texttt{BranchId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
amount & Importe monetario liquidado. Debe ser estrictamente superior a cero. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
paymentMethod & Canal de recaudo comercial empleado por el cliente (CASH, tarjetas o billeteras digitales). \\*
\hline
\textbf{Tipo o Firma} & \texttt{PaymentMethod} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
transactionReference & Número de operación bancaria o voucher POS. Obligatorio en medios digitales. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
status & Estado de la liquidación en caja (PENDING, COMPLETED, REFUNDED). \\*
\hline
\textbf{Tipo o Firma} & \texttt{PaymentStatus} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
paidAt & Timestamp cronológico exacto de acreditación de los fondos monetarios. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Instant} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
record & Factoría de dominio que inicializa la amortización financiera en estado COMPLETED. \\*
\hline
\textbf{Tipo o Firma} & \texttt{static VoucherPayment record(PaymentId id,\allowbreak  VoucherId voucherId,\allowbreak  TenantId tenantId,\allowbreak  BranchId branchId,\allowbreak  Money amount,\allowbreak  PaymentMethod method,\allowbreak  String reference)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
complete & Confirma la recepción definitiva de los fondos monetarios en las cuentas del taller. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void complete()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
refund & Revierte el abono financiero ante una anulación formal de la operación comercial. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void refund()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de miembros y métodos de las entidades dependientes VoucherLine y VoucherPayment del paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak entities.

La raíz de agregado **SeriesConfiguration** gobierna la asignación de series alfanuméricas autorizadas y el avance correlativo secuencial en cada sucursal física del taller. Su propósito arquitectónico es prevenir la generación de huecos tributarios o colisiones numéricas entre cajas concurrentes, manteniendo la unicidad compuesta por taller, sede física, tipo de comprobante y serie reglamentaria.

A través de la operación *nextCorrelative()*, el agregado incrementa de forma atómica su contador numérico interno y devuelve el correlativo formateado a ocho dígitos para su impresión y timbrado fiscal. Asimismo, habilita operaciones de administración como *deactivate()* y *activate()*, permitiendo suspender temporal o definitivamente la emisión de comprobantes bajo una serie específica ante traslados de sucursal o auditorías internas.

En la @tbl:invoicing-series-members se especifican los atributos estructurales, métodos de control correlativo y reglas de consistencia de la raíz de agregado **SeriesConfiguration**.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de la Raíz de Agregado SeriesConfiguration} \label{tbl:invoicing-series-members} \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Raíz de Agregado:} SeriesConfiguration (Control de Series y Correlativos Fiscales)} \\*
\hline
id & Identificador universal único de la configuración de series fiscales. \\*
\hline
\textbf{Tipo o Firma} & \texttt{SeriesConfigurationId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
tenantId & Taller automotriz propietario del talonario electrónico. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TenantId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
branchId & Sucursal física autorizada para la emisión de la serie fiscal. \\*
\hline
\textbf{Tipo o Firma} & \texttt{BranchId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
voucherType & Tipología de comprobante al que se destina la serie (FACTURA, BOLETA, NOTA\_CREDITO). \\*
\hline
\textbf{Tipo o Firma} & \texttt{VoucherType} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
serie & Serie autorizada de cuatro caracteres alfanuméricos con formato regex SUNAT. \\*
\hline
\textbf{Tipo o Firma} & \texttt{VoucherSerie} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
currentCorrelative & Contador secuencial entero que custodia el último correlativo emitido. \\*
\hline
\textbf{Tipo o Firma} & \texttt{int} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
isActive & Estado operativo que habilita o inhabilita la serie para emitir comprobantes. \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
create & Factoría de dominio que inicializa la serie fiscal activa con correlativo inicial. \\*
\hline
\textbf{Tipo o Firma} & \texttt{static SeriesConfiguration create(TenantId tenantId,\allowbreak  BranchId branchId,\allowbreak  VoucherType type,\allowbreak  VoucherSerie serie,\allowbreak  int initialCorrelative)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
nextCorrelative & Incrementa atómicamente el correlativo interno y retorna el número asignado. \\*
\hline
\textbf{Tipo o Firma} & \texttt{VoucherNumber nextCorrelative()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
deactivate & Suspende la emisión de nuevos comprobantes bajo esta serie fiscal en la sede. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void deactivate()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
activate & Restablece la operatividad de la serie para nuevos comprobantes en la sede. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void activate()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de miembros y métodos de la raíz de agregado SeriesConfiguration del paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak aggregates.

**Identificadores Tipados, Objetos de Valor y Enumeraciones de Invoicing & Compliance**

La consistencia y semántica de las magnitudes tributarias y financieras se salvaguardan mediante identificadores fuertemente tipados y objetos de valor inmutables implementados como registros de Java. Al centralizar la validación de formato y rango en sus constructores compactos, estos componentes erradican la presencia de estados inválidos en el dominio. Destaca **TaxCalculation**, el cual consolida la base imponible neta, el débito fiscal de IGV y el importe total facturado, verificando la estricta concordancia aritmética de sus importes.

Complementariamente, el dominio tipifica las dimensiones normativas mediante enumeraciones que reflejan los catálogos oficiales de la SUNAT. Entre ellas, **VoucherType** categoriza los comprobantes autorizados (código 01 para facturas, 03 para boletas y 07 para notas de crédito), **CreditNoteReason** sistematiza las causales admitidas para rectificaciones comerciales, **VoucherStatus** delimita la máquina de estados del documento y **PaymentMethod** clasifica los canales de liquidación aceptados en caja.

En la @tbl:invoicing-value-objects se detallan los identificadores tipados, los objetos de valor inmutables y las enumeraciones reglamentarias que vertebran la semántica fiscal del contexto.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Identificadores Tipados, Objetos de Valor y Enumeraciones de Invoicing \& Compliance} \label{tbl:invoicing-value-objects} \\
\hline
\thfirst{Componente Inmutable} & \thcell{Definición de Atributos y Reglas de Validación} \\
\hline
\endfirsthead
\hline
\thfirst{Componente Inmutable} & \thcell{Definición de Atributos y Reglas de Validación} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Identificador Tipado:} VoucherId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal del comprobante electrónico de pago. Inmutable y no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Identificador Tipado:} SeriesConfigurationId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal de la configuración de series fiscales. Inmutable y no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Identificador Tipado:} PaymentId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal del asiento de pago financiero en caja. Inmutable y no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Identificador Tipado:} VoucherLineId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal de la partida individual del comprobante. Inmutable y no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} VoucherSerie} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: String} \\*
\hline
\textbf{Restricciones y Reglas} & Serie alfanumérica de cuatro caracteres validada bajo la expresión regular iniciada en F, B o T. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} VoucherNumber} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: int} \\*
\hline
\textbf{Restricciones y Reglas} & Correlativo numérico entero estrictamente positivo con método de formateo a ocho dígitos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} TaxCalculation} \\*
\hline
\textbf{Atributos Clave} & \texttt{subtotal: Money}, \texttt{igvAmount: Money}, \texttt{totalAmount: Money}, \texttt{igvRate: BigDecimal} \\*
\hline
\textbf{Restricciones y Reglas} & Registro inmutable que impone la invariante de cuadre impositivo exacto subtotal más IGV igual a total general. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} CustomerFiscalInfo} \\*
\hline
\textbf{Atributos Clave} & \texttt{taxId: TaxId}, \texttt{legalName: String}, \texttt{fiscalAddress: String}, \texttt{documentType: DocumentType} \\*
\hline
\textbf{Restricciones y Reglas} & Datos fiscales normalizados del receptor exigidos por SUNAT para validez tributaria del comprobante. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} DigitalReceiptUrls} \\*
\hline
\textbf{Atributos Clave} & \texttt{pdfUrl: String}, \texttt{xmlUrl: String}, \texttt{cdrUrl: String} \\*
\hline
\textbf{Restricciones y Reglas} & Localizadores uniformes de recursos inmutables con protocolo seguro HTTPS para descarga de representaciones probatorias. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} SunatResponse} \\*
\hline
\textbf{Atributos Clave} & \texttt{responseCode: String}, \texttt{description: String}, \texttt{digitalSignatureHash: String} \\*
\hline
\textbf{Restricciones y Reglas} & Metadatos fiscales oficiales emitidos por el PSE tras recepción y validación de la trama XML firmada. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} VoidedInfo} \\*
\hline
\textbf{Atributos Clave} & \texttt{reason: String}, \texttt{voidedAt: Instant} \\*
\hline
\textbf{Restricciones y Reglas} & Registro probatorio formal de la causal justificada y timestamp de la anulación o comunicación de baja. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} CashFlowMovement} \\*
\hline
\textbf{Atributos Clave} & \texttt{movementId: UUID}, \texttt{voucherId: VoucherId}, \texttt{amount: Money}, \texttt{type: String}, \texttt{method: PaymentMethod}, \texttt{occurredAt: Instant} \\*
\hline
\textbf{Restricciones y Reglas} & Registro inmutable que condensa un movimiento financiero individual en el flujo de caja del taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} CashFlowSummary} \\*
\hline
\textbf{Atributos Clave} & \texttt{tenantId: TenantId}, \texttt{branchId: BranchId}, \texttt{period: LocalDate}, \texttt{totalIncome: Money}, \texttt{totalRefunds: Money}, \texttt{netBalance: Money} \\*
\hline
\textbf{Restricciones y Reglas} & Registro inmutable que condensa el balance analítico de ingresos, reembolsos y saldo neto para el periodo consultado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} VoucherType} \\*
\hline
\textbf{Atributos Clave} & Constantes con código oficial de SUNAT \\*
\hline
\textbf{Restricciones y Reglas} & FACTURA (código 01), BOLETA (código 03) y NOTA\_CREDITO (código 07). \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} VoucherStatus} \\*
\hline
\textbf{Atributos Clave} & Constantes de ciclo de vida \\*
\hline
\textbf{Restricciones y Reglas} & Estados transaccionales: DRAFT, ISSUED, ACCEPTED\_SUNAT, REJECTED\_SUNAT y VOIDED. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} PaymentMethod} \\*
\hline
\textbf{Atributos Clave} & Constantes de medios de pago \\*
\hline
\textbf{Restricciones y Reglas} & Modalidades de liquidación: CASH, CREDIT\_CARD, DEBIT\_CARD, BANK\_TRANSFER, DIGITAL\_WALLET\_YAPE y DIGITAL\_WALLET\_PLIN. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} PaymentStatus} \\*
\hline
\textbf{Atributos Clave} & Constantes transaccionales \\*
\hline
\textbf{Restricciones y Reglas} & Estados de abono en caja: PENDING, COMPLETED y REFUNDED. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} VoucherItemType} \\*
\hline
\textbf{Atributos Clave} & Constantes de tipificación de partida \\*
\hline
\textbf{Restricciones y Reglas} & PRODUCT (repuesto físico con control de existencias) y SERVICE (mano de obra o labor técnica). \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} CreditNoteReason} \\*
\hline
\textbf{Atributos Clave} & Constantes con código oficial SUNAT \\*
\hline
\textbf{Restricciones y Reglas} & Motivos según catálogo 09: Anulación de operación (01), error en RUC (02), corrección de descripción (03), descuento global (04) y devolución total (06). \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes inmutables organizados en los subpaquetes modulares ids, valueobjects y enums de com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak domain.\allowbreak model.

**Servicios de Dominio de Invoicing & Compliance**

Las operaciones del negocio que involucran cálculos matemáticos especializados o validaciones algorítmicas de múltiples entidades se encapsulan en servicios de dominio sin estado. El servicio **PeruvianTaxCalculationEngine** centraliza la deducción del Impuesto General a las Ventas mediante la fórmula normalizada de división por 1.18, aplicando redondeo bancario Half-Even a dos decimales para totales y a cuatro decimales para los valores unitarios requeridos por las especificaciones de UBL 2.1, traduciendo además los importes a su representación formal en texto.

A su vez, **VoucherValidationService** aplica el algoritmo de ponderación por Módulo 11 sobre el vector fiscal [5, 4, 3, 2, 7, 6, 5, 4, 3, 2] para autenticar la legitimidad del dígito verificador de los números de RUC, validando adicionalmente los límites monetarios en boletas de venta y la consistencia de comprobantes vinculados a notas de crédito. Finalmente, **SeriesCorrelativeService** orquesta el avance correlativo seguro garantizando la ausencia de duplicidades bajo escenarios de alta concurrencia transaccional.

En la @tbl:invoicing-domain-services se presentan los servicios de dominio de este contexto, indicando sus signaturas operativas y responsabilidades matemáticas.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Servicios de Dominio del Bounded Context Invoicing \& Compliance} \label{tbl:invoicing-domain-services} \\
\hline
\thfirst{Aspecto de Servicio} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Servicio} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Dominio:} PeruvianTaxCalculationEngine} \\*
\hline
\textbf{Métodos Principales} & - \texttt{calculateFromGrossTotal(Money grossTotal)} \newline - \texttt{extractUnitValue(Money unitPriceWithIgv)} \newline - \texttt{convertAmountToWords(Money amount,\allowbreak  Currency currency)} \\*
\hline
\textbf{Responsabilidad} & Aplica segregación impositiva de base imponible e IGV al 18\% con redondeo Half-Even a dos decimales para totales y a cuatro decimales para valores unitarios en tramas UBL 2.1 además de traducir importes a texto formal. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Dominio:} VoucherValidationService} \\*
\hline
\textbf{Métodos Principales} & - \texttt{validateFiscalData(VoucherType type,\allowbreak  CustomerFiscalInfo info,\allowbreak  Money totalAmount)} \newline - \texttt{isValidRuc(String ruc)} \newline - \texttt{validateCreditNoteReference(ElectronicVoucher originalVoucher,\allowbreak  CreditNoteReason reason)} \\*
\hline
\textbf{Responsabilidad} & Verifica legitimidad de RUC mediante algoritmo Módulo 11 con pesos ponderados, comprueba tope legal de S/ 700.00 en boletas sin documento receptor y valida consistencia de notas de crédito vinculadas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Dominio:} SeriesCorrelativeService} \\*
\hline
\textbf{Métodos Principales} & - \texttt{allocateNextCorrelative(TenantId tenantId,\allowbreak  BranchId branchId,\allowbreak  VoucherType type,\allowbreak  VoucherSerie serie)} \\*
\hline
\textbf{Responsabilidad} & Orquesta la reserva y asignación atómica del siguiente número correlativo fiscal consecutivo por sucursal bajo bloqueos pesimistas impidiendo huecos, duplicidades y desbordamiento de límites legales. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Servicios de dominio sin estado ubicados en el paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak domain.\allowbreak services.

**Puertos de Repositorio de la Capa de Dominio**

El aislamiento del modelo conceptual respecto a la infraestructura de persistencia se garantiza mediante contratos de interfaz que definen los puertos de salida del dominio. Estos contratos permiten recuperar y persistir el estado de los agregados respetando sus invariantes transaccionales, prescindiendo por completo de dependencias directas hacia tecnologías relacionales o bibliotecas ORM.

En este marco, **ElectronicVoucherRepository** proporciona métodos de búsqueda por serie, correlativo y rangos de fechas contables, mientras **SeriesConfigurationRepository** provee consultas optimizadas para la gestión y bloqueo concurrente de correlativos por sucursal. Por su parte, **VoucherPaymentRepository** administra el registro histórico de recaudaciones financieras para respaldar arqueos diarios de caja y procesos de conciliación bancaria en el taller.

En la @tbl:invoicing-repository-ports se detallan los contratos de repositorio que desacoplan la lógica fiscal respecto a los adaptadores de persistencia relacional.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Puertos de Repositorio del Bounded Context Invoicing \& Compliance} \label{tbl:invoicing-repository-ports} \\
\hline
\thfirst{Aspecto de Puerto} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Puerto} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Repositorio:} ElectronicVoucherRepository} \\*
\hline
\textbf{Métodos Principales} & - \texttt{save} \newline - \texttt{findById} \newline - \texttt{findByTenantIdAndSerieAndNumber} \newline - \texttt{findAllByTenantIdAndDateRange} \newline - \texttt{findAllByWorkOrderId} \newline - \texttt{existsByTenantIdAndSerieAndNumber} \\*
\hline
\textbf{Responsabilidad de Dominio} & Persistencia agnóstica y consulta de comprobantes fiscales electrónicos, verificación de unicidad de serie y número correlativo y filtrado por orden de trabajo o rango de fechas contable. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Repositorio:} SeriesConfigurationRepository} \\*
\hline
\textbf{Métodos Principales} & - \texttt{save} \newline - \texttt{findById} \newline - \texttt{findByBranchIdAndVoucherTypeAndActive} \newline - \texttt{findByTenantIdAndBranchIdAndSerie} \newline - \texttt{findAllByBranchId} \newline - \texttt{existsByTenantIdAndBranchIdAndSerie} \\*
\hline
\textbf{Responsabilidad de Dominio} & Persistencia y consulta de series fiscales autorizadas por sede física con control de habilitación operativa y soporte de bloqueos pesimistas concurrentes. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Repositorio:} VoucherPaymentRepository} \\*
\hline
\textbf{Métodos Principales} & - \texttt{save} \newline - \texttt{findById} \newline - \texttt{findAllByVoucherId} \newline - \texttt{findAllByBranchIdAndDate} \\*
\hline
\textbf{Responsabilidad de Dominio} & Persistencia y seguimiento de amortizaciones financieras de comprobantes, consulta de cobros diarios por sucursal y soporte para arqueos de caja del taller. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Contratos de persistencia agnósticos ubicados en el paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak domain.\allowbreak repositories.

**Taxonomía de Eventos de Dominio de Invoicing & Compliance**

La propagación de cambios de estado y la integración asíncrona con los demás módulos de la plataforma se articula mediante eventos de dominio inmutables derivados del contrato **DomainEvent**. Estos artefactos representan hechos formalmente consumados en el ciclo de facturación y se persisten en el Transactional Outbox para asegurar su despacho confiable hacia el broker de mensajería:

- **Ciclo de vida y despacho tributario**: **ElectronicVoucherIssuedEvent**, **VoucherAcceptedBySunatEvent**, **VoucherRejectedBySunatEvent** y **VoucherVoidedEvent** informan la emisión, homologación oficial ante la autoridad fiscal mediante el CDR, observaciones tributarias y anulaciones legales.
- **Gestión de cobranza y rectificación**: **VoucherPaymentRegisteredEvent** y **CreditNoteIssuedEvent** comunican amortizaciones financieras en caja y emisiones de notas de crédito vinculadas para regularizar saldos deudores.
- **Control de infraestructura fiscal**: **SeriesConfigurationCreatedEvent** y **SeriesCorrelativeIncrementedEvent** notifican la habilitación de nuevas series y la asignación cronológica de números correlativos por sucursal.

En la @tbl:invoicing-domain-events se sintetiza la taxonomía de los ocho eventos de dominio de Invoicing & Compliance con sus respectivas cargas útiles e impactos intermodulares.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Taxonomía de Eventos de Dominio de Invoicing \& Compliance} \label{tbl:invoicing-domain-events} \\
\hline
\thfirst{Aspecto del Evento} & \thcell{Especificación de Carga Útil y Efecto} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Evento} & \thcell{Especificación de Carga Útil y Efecto} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} ElectronicVoucherIssuedEvent \quad (\textit{Emisor:} ElectronicVoucher)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{voucherId}, \texttt{tenantId}, \texttt{branchId}, \texttt{customerId}, \texttt{type}, \texttt{serie}, \texttt{number}, \texttt{totalAmount}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Notifica la emisión local del comprobante y encola la solicitud de timbrado fiscal hacia Nubefact mediante Transactional Outbox. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} VoucherAcceptedBySunatEvent \quad (\textit{Emisor:} ElectronicVoucher)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{voucherId}, \texttt{tenantId}, \texttt{digitalSignatureHash}, \texttt{urls}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Notifica la aceptación legal por SUNAT con CDR obtenido, disparando el envío automático de enlaces PDF y XML al cliente por correo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} VoucherRejectedBySunatEvent \quad (\textit{Emisor:} ElectronicVoucher)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{voucherId}, \texttt{tenantId}, \texttt{errorCode}, \texttt{errorMessage}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Alerta al personal contable sobre discrepancias tributarias o rechazo de firma digital para su subsanación inmediata. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} VoucherVoidedEvent \quad (\textit{Emisor:} ElectronicVoucher)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{voucherId}, \texttt{tenantId}, \texttt{reason}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Comunica la anulación formal del comprobante ante SUNAT y revierte los compromisos de cobro en los libros contables. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} VoucherPaymentRegisteredEvent \quad (\textit{Emisor:} ElectronicVoucher)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{paymentId}, \texttt{voucherId}, \texttt{tenantId}, \texttt{amount}, \texttt{method}, \texttt{isFullyPaid}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Informa el abono financiero registrado en caja actualizando el balance del cliente en CRM y autorizando la salida física del vehículo en MRO. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} SeriesConfigurationCreatedEvent \quad (\textit{Emisor:} SeriesConfiguration)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{seriesId}, \texttt{tenantId}, \texttt{branchId}, \texttt{type}, \texttt{serie}, \texttt{initialCorrelative}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Notifica la parametrización de una nueva serie fiscal en una sede habilitando su disponibilidad para puntos de cobro. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} SeriesCorrelativeIncrementedEvent \quad (\textit{Emisor:} SeriesConfiguration)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{seriesId}, \texttt{tenantId}, \texttt{branchId}, \texttt{serie}, \texttt{newCorrelative}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Registra la asignación consecutiva del correlativo numérico garantizando auditoría cronológica sin saltos fiscales. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} CreditNoteIssuedEvent \quad (\textit{Emisor:} ElectronicVoucher)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{creditNoteId}, \texttt{referenceVoucherId}, \texttt{tenantId}, \texttt{branchId}, \texttt{serie}, \texttt{number}, \texttt{reason}, \texttt{totalAmount}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Comunica la emisión de una nota de crédito vinculada deduciendo el saldo deudor o anulando la operación previa en el taller. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Taxonomía de eventos de dominio inmutables ubicados bajo el paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak domain.\allowbreak events.

**Excepciones de Dominio y Manejo de Errores Semánticos**

Las anomalías operativas y transgresiones a las reglas de negocio fiscal se canalizan mediante excepciones semánticas no comprobadas derivadas de **DomainException**. Cada excepción encapsula un código semántico legible normalizado bajo la especificación RFC 7807 y se asocia de forma determinista a un código de estado HTTP para su exposición perimetral controlada:

- **Anomalías de identificación y validación impositiva**: **InvalidTaxIdException**, **InvalidVoucherAmountException** y **CustomerFiscalDataMissingException** ante documentos tributarios inválidos, inconsistencias de cuadre aritmético u omisión de datos exigidos por ley.
- **Conflictos de concurrencia e inmutabilidad legal**: **CorrelativeExhaustedException**, **VoucherAlreadyPaidException** y **VoucherImmutableException** ante desbordamiento de numeración, pagos sobre comprobantes saldados o intentos ilícitos de modificar documentos aprobados por SUNAT.
- **Entidades no localizadas y contingencias telemáticas**: **SeriesNotFoundException**, **VoucherNotFoundException**, **CreditNoteReferenceNotFoundException** y **SunatIntegrationException** frente a ausencias en el catálogo de series o interrupciones en la comunicación con el proveedor electrónico.

En la @tbl:invoicing-domain-exceptions se presenta la jerarquía de excepciones semánticas de dominio, detallando sus códigos de error y condiciones de lanzamiento en el modelo.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.8cm} | >{\raggedright\arraybackslash}p{9.6cm} |}
\caption{Excepciones de Dominio y Códigos Semánticos de Invoicing \& Compliance} \label{tbl:invoicing-domain-exceptions} \\
\hline
\thfirst{Código de Error Semántico} & \thcell{Condición de Lanzamiento en el Modelo} \\
\hline
\endfirsthead
\hline
\thfirst{Código de Error Semántico} & \thcell{Condición de Lanzamiento en el Modelo} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} InvalidTaxIdException} \\*
\hline
\texttt{ERR\_INVALID\_\allowbreak TAX\_ID} \newline HTTP 422 Unprocessable Entity & El número de RUC no supera la validación algorítmica de Módulo 11 o no corresponde a una persona natural o jurídica legalmente habilitada. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} CorrelativeExhaustedException} \\*
\hline
\texttt{ERR\_CORRELATIVE\_\allowbreak EXHAUSTED} \newline HTTP 409 Conflict & El correlativo numérico de la serie fiscal ha alcanzado el límite reglamentario máximo de 99,999,999 exigiendo la apertura de una nueva serie. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} VoucherAlreadyPaidException} \\*
\hline
\texttt{ERR\_VOUCHER\_\allowbreak ALREADY\_PAID} \newline HTTP 409 Conflict & Se intenta asentar un cobro financiero cuando el saldo pendiente del comprobante ya es cero o cuando el monto recibido supera el importe total. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} VoucherImmutableException} \\*
\hline
\texttt{ERR\_VOUCHER\_\allowbreak IMMUTABLE} \newline HTTP 409 Conflict & Se intenta alterar o eliminar un comprobante que ya ha sido emitido formalmente o aceptado por SUNAT exigiendo una nota de crédito para correcciones. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} InvalidVoucherAmountException} \\*
\hline
\texttt{ERR\_INVALID\_\allowbreak VOUCHER\_AMOUNT} \newline HTTP 422 Unprocessable Entity & Discrepancia aritmética entre la sumatoria de las partidas individuales y el total consignado en la cabecera o existencia de importes negativos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} CustomerFiscalDataMissingException} \\*
\hline
\texttt{ERR\_CUSTOMER\_\allowbreak FISCAL\_MISSING} \newline HTTP 422 Unprocessable Entity & Omisión de datos fiscales requeridos por ley como razón social y RUC en facturas o documento de identidad en boletas superiores a S/ 700.00. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} SeriesNotFoundException} \\*
\hline
\texttt{ERR\_SERIES\_\allowbreak NOT\_FOUND} \newline HTTP 404 Not Found & No se localiza una serie fiscal activa configurada para la combinación de taller sucursal física y tipo de comprobante solicitada. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} VoucherNotFoundException} \\*
\hline
\texttt{ERR\_VOUCHER\_\allowbreak NOT\_FOUND} \newline HTTP 404 Not Found & No se localiza el comprobante electrónico en el repositorio del taller mediante el identificador unívoco o la serie y correlativo provistos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} SunatIntegrationException} \\*
\hline
\texttt{ERR\_SUNAT\_\allowbreak INTEGRATION\_FAILED} \newline HTTP 502 Bad Gateway & Falla de comunicación de red o rechazo de validación telemática con el Proveedor de Servicios Electrónicos o con los servidores de SUNAT. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} CreditNoteReferenceNotFoundException} \\*
\hline
\texttt{ERR\_CREDIT\_NOTE\_\allowbreak REF\_NOT\_FOUND} \newline HTTP 404 Not Found & La nota de crédito hace referencia a un comprobante emisor preexistente que no figura en los registros de facturación del taller. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Jerarquía de excepciones semánticas tipadas bajo la norma RFC 7807 ubicadas en el paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak domain.\allowbreak exceptions.

A partir de la formalización táctica de Invoicing & Compliance, se identifican tres fundamentos de ingeniería de software que consolidan la disciplina fiscal y contable en el ecosistema de Atelier Platform:

El primer fundamento reside en el determinismo matemático estricto en la segregación impositiva y la adopción del redondeo bancario Half-Even. Al formalizar algoritmos inmutables en el motor de dominio y exigir una escala fija a dos decimales para los importes consolidados y a cuatro decimales para las partidas individuales en UBL 2.1, el sistema erradica discrepancias por acumulación de redondeos y asegura el cuadre aritmético riguroso exigido por los validadores automáticos de la SUNAT.

El segundo pilar se sustenta en la inmutabilidad probatoria, la custodia documental y el desacoplamiento transaccional mediante el patrón Transactional Outbox. Al persistir el comprobante electrónico localmente en estado emitido antes de su despacho telemático y conservar las representaciones oficiales PDF, XML firmado y CDR en almacenamiento seguro, el taller garantiza la validez probatoria de sus ventas y blinda la atención en mostrador frente a intermitencias en los servicios del ente recaudador.

El tercer fundamento radica en la soberanía fiscal y el blindaje modular respecto a los flujos operativos de taller y abastecimiento. Al modelar la facturación como un contexto autónomo que interactúa mediante eventos asíncronos y contratos agnósticos, la plataforma desacopla la liquidación contable respecto a las órdenes de trabajo mecánicas y el inventario, protegiendo al núcleo del negocio automotriz frente a la volatilidad de las normativas tributarias nacionales.

#### 2.6.7.2. Interface Layer

La Capa de Interfaz del Bounded Context Invoicing & Compliance actúa como el adaptador primario perimetral bajo el paquete canónico com.andeva.atelier.platform.invoicing.interfaces. Su propósito arquitectónico consiste en traducir las interacciones externas originadas en clientes web administrativos, aplicaciones móviles de mostrador y servicios intermodulares hacia comandos transaccionales y consultas deterministas, blindando la soberanía fiscal y contable del taller frente a solicitudes malformadas o inconsistentes.

Para estructurar una frontera desacoplada y alineada a las estrictas exigencias normativas de la SUNAT y del estándar UBL 2.1, el diseño perimetral de Invoicing & Compliance se fundamenta en cinco directrices tácticas:

- **Validación rigurosa de invariantes fiscales y contratos de entrada:** Los recursos de entrada imponen restricciones declarativas exhaustivas sobre identificadores, patrones de serie alfanumérica, tipos de comprobante admitidos y algoritmos de dígito verificador en documentos tributarios, interceptando anomalías antes de su derivación a la capa de aplicación.
- **Segregación operativa entre facturación y cobranzas:** La arquitectura perimetral separa taxativamente los controladores de emisión de comprobantes respecto a los de recaudación y liquidación en caja, posibilitando que el taller registre amortizaciones financieras graduales sin alterar la estructura fiscal del comprobante tributario.
- **Desacoplamiento multimedia y acceso a artefactos tributarios:** La descarga y visualización de representaciones gráficas en PDF, archivos XML firmados y constancias de recepción CDR delega el almacenamiento masivo hacia repositorios en la nube, exponiendo en el perímetro únicamente localizadores HTTPS autenticados para optimizar el rendimiento de red.
- **Fachada de Contexto Abierto:** Mediante la interfaz **InvoicingContextFacade**, el contexto expone contratos síncronos fuertemente tipados bajo los patrones Open Host Service y Capa Anticorrupción, facultando al módulo de operaciones de taller para liquidar órdenes de trabajo mecánicas sin acoplarse a particularidades de la pasarela tributaria.
- **Coreografía reactiva de eventos de integración:** La propagación de transiciones de estado hacia los demás módulos de la plataforma y el consumo de hechos originados en compras o planillas se articula a través de eventos de integración inmutables persistidos en el Transactional Outbox, asegurando consistencia eventual confiable y libre de bloqueos relacionales.

En la @tbl:invoicing-interface-types se sintetiza el catálogo consolidado de controladores, recursos de transporte, ensambladores, contratos de fachada y eventos que conforman la Capa de Interfaz de Invoicing & Compliance.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo Consolidado de la Capa de Interfaz de Invoicing \& Compliance} \label{tbl:invoicing-interface-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endhead
Electronic\allowbreak Vouchers\allowbreak Controller & Endpoints REST para emisión de facturas y boletas, notas de crédito, consultas paginadas, anulación formal ante SUNAT y descarga de activos tributarios XML, PDF y CDR. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca ElectronicVoucherCommandService y ElectronicVoucherQueryService. Utiliza ensambladores de recursos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Voucher\allowbreak Payments\allowbreak Controller & Endpoints REST para registro de amortizaciones o liquidaciones financieras contra comprobantes, historial de cobros y reporte de caja diario por sucursal. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca VoucherPaymentCommandService y VoucherPaymentQueryService. Utiliza ensambladores de recursos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Series\allowbreak Configurations\allowbreak Controller & Endpoints REST para alta, parametrización, consulta, suspensión y reactivación operativa de series fiscales correlativas por sucursal física. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca SeriesConfigurationCommandService y SeriesConfigurationQueryService. Utiliza ensambladores de recursos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Financial\allowbreak Reports\allowbreak Controller & Endpoints REST para consolidación analítica interactiva del flujo de caja del taller y descarga del reporte oficial en PDF con diseño bancario corporativo. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca CashFlowQueryService. Utiliza FinancialReportResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Issue\allowbreak Voucher\allowbreak Request & Carga útil inmutable para la emisión de facturas o boletas electrónicas con identificación fiscal del cliente y partidas gravadas. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por ElectronicVoucherResourceAssembler hacia IssueElectronicVoucherCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Issue\allowbreak Credit\allowbreak Note\allowbreak Request & Carga útil inmutable para emisión de notas de crédito electrónicas vinculadas a un comprobante previo con código y sustento de rectificación. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por ElectronicVoucherResourceAssembler hacia IssueCreditNoteCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Void\allowbreak Voucher\allowbreak Request & Carga útil inmutable para comunicar formalmente la anulación o baja tributaria ante SUNAT con justificación explícita. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por ElectronicVoucherResourceAssembler hacia VoidElectronicVoucherCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Register\allowbreak Payment\allowbreak Request & Carga útil inmutable para registrar una amortización o liquidación financiera contra un comprobante indicando medio de pago y referencia. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por VoucherPaymentResourceAssembler hacia RegisterVoucherPaymentCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Configure\allowbreak Series\allowbreak Request & Carga útil inmutable para el alta y parametrización de series correlativas autorizadas por sucursal física y tipo fiscal. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por SeriesConfigurationResourceAssembler hacia ConfigureSeriesCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Voucher\allowbreak Line\allowbreak Request & Carga útil inmutable para detallar una partida individual gravada de repuesto o servicio dentro de la emisión o rectificación del comprobante. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Componente subordinado de IssueVoucherRequest e IssueCreditNoteRequest. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Electronic\allowbreak Voucher\allowbreak Resource & Representación pública integral del comprobante con desglose de impuestos, partidas gravadas, amortizaciones y enlaces de activos tributarios. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por ElectronicVoucherResourceAssembler desde ElectronicVoucher. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Electronic\allowbreak Voucher\allowbreak Summary\allowbreak Resource & Proyección sintetizada para listados paginados de alta velocidad y cuadrículas de consulta de comprobantes fiscales. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por ElectronicVoucherResourceAssembler desde ElectronicVoucher. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Voucher\allowbreak Line\allowbreak Resource & Detalle monetario y tributario de una partida individual gravada de repuesto o servicio automotriz dentro del comprobante. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por ElectronicVoucherResourceAssembler desde VoucherLine. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Voucher\allowbreak Payment\allowbreak Resource & Constancia inmutable de amortización o liquidación monetaria con medio de pago, referencia de transacción y marca temporal. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por VoucherPaymentResourceAssembler desde VoucherPayment. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Daily\allowbreak Cash\allowbreak Summary\allowbreak Resource & Balance financiero diario consolidado por sucursal física con desglose por medios de pago en efectivo, tarjeta, transferencia y billeteras digitales. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por VoucherPaymentResourceAssembler desde agregaciones de VoucherPayment. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Series\allowbreak Configuration\allowbreak Resource & Representación pública del estado y correlativo actual de una serie fiscal autorizada para una sede física. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por SeriesConfigurationResourceAssembler desde SeriesConfiguration. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Cash\allowbreak Flow\allowbreak Report\allowbreak Resource & Estado consolidado de flujo de caja del taller con sumatorias de ingresos, egresos, flujo neto y colección cronológica de movimientos. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por FinancialReportResourceAssembler desde CashFlowReport del servicio de consulta. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Cash\allowbreak Flow\allowbreak Movement\allowbreak Resource & Registro cronológico individual de ingreso o egreso operativo con categoría de negocio, referencia probatoria y saldo progresivo acumulado. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Componente subordinado de CashFlowReportResource. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Electronic\allowbreak Voucher\allowbreak Resource\allowbreak Assembler & Ensamblador bidireccional entre DTOs de petición, comandos de emisión y agregados ElectronicVoucher. \\*
\hline
\textbf{Categoría} & Ensamblador de Recursos \\*
\hline
\textbf{Relaciones} & Transforma comandos mutacionales y recursos del comprobante electrónico. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Voucher\allowbreak Payment\allowbreak Resource\allowbreak Assembler & Ensamblador bidireccional entre peticiones de amortización, comandos y entidades VoucherPayment y resúmenes de caja diaria. \\*
\hline
\textbf{Categoría} & Ensamblador de Recursos \\*
\hline
\textbf{Relaciones} & Transforma comandos de pago y recursos de cobro financiero. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Series\allowbreak Configuration\allowbreak Resource\allowbreak Assembler & Ensamblador bidireccional entre peticiones de serie, comandos y agregados SeriesConfiguration. \\*
\hline
\textbf{Categoría} & Ensamblador de Recursos \\*
\hline
\textbf{Relaciones} & Transforma comandos de serie y recursos de configuración fiscal. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Financial\allowbreak Report\allowbreak Resource\allowbreak Assembler & Ensamblador unidireccional que traduce el modelo consolidado en memoria de CashFlowQueryService hacia CashFlowReportResource. \\*
\hline
\textbf{Categoría} & Ensamblador de Recursos \\*
\hline
\textbf{Relaciones} & Transforma modelos de consulta analítica hacia recursos públicos DTO. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Invoicing\allowbreak Context\allowbreak Facade & Interfaz de contexto abierto para emisión síncrona desde órdenes de trabajo, auditoría de liquidación financiera y verificación de saldo cero. \\*
\hline
\textbf{Categoría} & Fachada de Contexto (OHS / ACL) \\*
\hline
\textbf{Relaciones} & Expone métodos síncronos consumidos principalmente por Workshop Operations (MRO). \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Generate\allowbreak Voucher\allowbreak From\allowbreak Work\allowbreak Order\allowbreak Command\allowbreak Dto & Contrato inmutable para solicitar la emisión y despacho fiscal de un comprobante a partir de una orden de trabajo liquidada. \\*
\hline
\textbf{Categoría} & DTO de Integración de Fachada \\*
\hline
\textbf{Relaciones} & Consumido por el método generateVoucherFromWorkOrder de InvoicingContextFacade. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak acl.\allowbreak dto} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Work\allowbreak Order\allowbreak Item\allowbreak Billing\allowbreak Dto & Detalle inmutable de ítem o labor facturable dentro del comando de liquidación de la orden de trabajo. \\*
\hline
\textbf{Categoría} & DTO de Integración de Fachada \\*
\hline
\textbf{Relaciones} & Componente subordinado de GenerateVoucherFromWorkOrderCommandDto. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak acl.\allowbreak dto} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Voucher\allowbreak Generation\allowbreak Result\allowbreak Dto & Respuesta inmutable que confirma el resultado de la facturación electrónica con identificadores y enlace PDF. \\*
\hline
\textbf{Categoría} & DTO de Integración de Fachada \\*
\hline
\textbf{Relaciones} & Producido por el método generateVoucherFromWorkOrder de InvoicingContextFacade. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak acl.\allowbreak dto} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Voucher\allowbreak Summary\allowbreak Dto & Proyección inmutable con el resumen del estado y pagos de un comprobante vinculado a una orden de trabajo. \\*
\hline
\textbf{Categoría} & DTO de Integración de Fachada \\*
\hline
\textbf{Relaciones} & Retornado por el método getVouchersByWorkOrderId de InvoicingContextFacade. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak acl.\allowbreak dto} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Customer\allowbreak Fiscal\allowbreak Info\allowbreak Dto & Datos fiscales y tributarios del cliente consumidor para consignación formal en el comprobante electrónico. \\*
\hline
\textbf{Categoría} & DTO de Integración de Fachada \\*
\hline
\textbf{Relaciones} & Utilizado por los contratos de integración de la fachada InvoicingContextFacade. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak acl.\allowbreak dto} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Electronic\allowbreak Voucher\allowbreak Issued\allowbreak Integration\allowbreak Event & Notifica la emisión legal formal del comprobante con su numeración fiscal correlativa para actualización contable de la orden de trabajo. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. Consumido por Workshop Operations (MRO). \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Voucher\allowbreak Accepted\allowbreak By\allowbreak Sunat\allowbreak Integration\allowbreak Event & Notifica la homologación satisfactoria por SUNAT mediante CDR para despacho automático de correo con PDF y XML UBL 2.1. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. Consumido por el módulo de Notificaciones. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Voucher\allowbreak Rejected\allowbreak By\allowbreak Sunat\allowbreak Integration\allowbreak Event & Notifica la observación o rechazo fiscal por SUNAT para alertas inmediatas en panel administrativo y regularización tributaria. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. Consumido por Operaciones de Caja y Soporte. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Voucher\allowbreak Voided\allowbreak Integration\allowbreak Event & Notifica la anulación formal o comunicación de baja del comprobante ante SUNAT para reversión contable intermodular. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. Consumido por Workshop Operations (MRO) y Contabilidad. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Voucher\allowbreak Payment\allowbreak Registered\allowbreak Integration\allowbreak Event & Notifica el asentamiento de una amortización monetaria para verificar si se alcanzó la cancelación total y habilitar salida del vehículo. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. Consumido por Workshop Operations (MRO). \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Work\allowbreak Order\allowbreak Delivered\allowbreak Integration\allowbreak Event & Notifica la entrega física del vehículo para auditoría fiscal de cierre y emisión de alerta si la orden no se encuentra facturada. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Originado en Workshop Operations (MRO). Consumido por Invoicing. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Purchase\allowbreak Order\allowbreak Received\allowbreak Integration\allowbreak Event & Notifica la recepción y factura de repuestos para su cómputo automático como egreso operativo en el flujo de caja. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Originado en Inventory \& Supply Chain. Consumido por Invoicing. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Payroll\allowbreak Paid\allowbreak Integration\allowbreak Event & Notifica la dispersión y pago de planillas salariales para su cómputo automático como egreso operativo en el flujo de caja. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Originado en Human Resources Management. Consumido por Invoicing. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak events} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Catálogo consolidado de componentes pertenecientes a los subpaquetes controllers, resources (requests y responses), transform, acl (y dto) y events de com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak interfaces.

**Controladores REST y Endpoints de Comunicación de Invoicing & Compliance**

La interacción HTTP del contexto se centraliza en cuatro controladores REST altamente especializados, cada uno con una demarcación de responsabilidades estrictamente delimitada. El controlador **ElectronicVouchersController** gestiona las rutas situadas bajo **/api/v1/invoicing/vouchers**, abarcando la emisión de comprobantes y notas de crédito, la consulta paginada de registros de venta, la anulación formal y la descarga de tramas XML, representaciones PDF y constancias CDR.

Por su parte, **VoucherPaymentsController** administra las operaciones financieras bajo **/api/v1/invoicing/payments**, posibilitando el registro de amortizaciones contra comprobantes y la generación del cuadre de caja diario por sucursal. En paralelo, **SeriesConfigurationsController** provee endpoints en **/api/v1/invoicing/series-configurations** para la parametrización y control operativo de series correlativas, mientras que **FinancialReportsController** expone en **/api/v1/invoicing/financial-reports** la consolidación interactiva y la descarga del reporte formal de flujo de caja en formato PDF con diseño bancario corporativo.

En la @tbl:invoicing-controllers-and-endpoints se detallan los recursos de petición, verbos HTTP, rutas canónicas y respuestas asociadas a los controladores REST del perímetro de facturación.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Controladores REST y Endpoints de Comunicación de Invoicing \& Compliance} \label{tbl:invoicing-controllers-and-endpoints} \\
\hline
\thfirst{Recurso de Petición} & \thcell{Código y Respuesta HTTP} \\
\hline
\endfirsthead
\hline
\thfirst{Recurso de Petición} & \thcell{Código y Respuesta HTTP} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} Electronic\allowbreak Vouchers\allowbreak Controller} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak invoicing/\allowbreak vouchers}} \\*
\hline
\textbf{Petición:} \texttt{Issue\allowbreak Voucher\allowbreak Request} & \textbf{Respuesta:} 201 CREATED (\texttt{Electronic\allowbreak Voucher\allowbreak Resource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak invoicing/\allowbreak vouchers/\allowbreak credit-notes}} \\*
\hline
\textbf{Petición:} \texttt{Issue\allowbreak Credit\allowbreak Note\allowbreak Request} & \textbf{Respuesta:} 201 CREATED (\texttt{Electronic\allowbreak Voucher\allowbreak Resource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak invoicing/\allowbreak vouchers/\allowbreak \{id\}}} \\*
\hline
\textbf{Petición:} Variable de ruta (\texttt{id}) & \textbf{Respuesta:} 200 OK (\texttt{Electronic\allowbreak Voucher\allowbreak Resource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak invoicing/\allowbreak vouchers}} \\*
\hline
\textbf{Petición:} Filtros query (\texttt{startDate}, \texttt{endDate}, \texttt{voucherType}, \texttt{status}, \texttt{page}, \texttt{size}) & \textbf{Respuesta:} 200 OK (\texttt{PagedModel\textless Electronic\allowbreak Voucher\allowbreak Summary\allowbreak Resource\textgreater}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak invoicing/\allowbreak vouchers/\allowbreak work-orders/\allowbreak \{workOrderId\}}} \\*
\hline
\textbf{Petición:} Variable de ruta (\texttt{workOrderId}) & \textbf{Respuesta:} 200 OK (\texttt{List\textless Electronic\allowbreak Voucher\allowbreak Summary\allowbreak Resource\textgreater}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak invoicing/\allowbreak vouchers/\allowbreak \{id\}/\allowbreak void}} \\*
\hline
\textbf{Petición:} \texttt{Void\allowbreak Voucher\allowbreak Request}, variable de ruta (\texttt{id}) & \textbf{Respuesta:} 200 OK (\texttt{Electronic\allowbreak Voucher\allowbreak Resource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak invoicing/\allowbreak vouchers/\allowbreak \{id\}/\allowbreak xml}} \\*
\hline
\textbf{Petición:} Variable de ruta (\texttt{id}) & \textbf{Respuesta:} 200 OK (\texttt{application/xml}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak invoicing/\allowbreak vouchers/\allowbreak \{id\}/\allowbreak pdf}} \\*
\hline
\textbf{Petición:} Variable de ruta (\texttt{id}) & \textbf{Respuesta:} 200 OK (\texttt{application/pdf}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak invoicing/\allowbreak vouchers/\allowbreak \{id\}/\allowbreak cdr}} \\*
\hline
\textbf{Petición:} Variable de ruta (\texttt{id}) & \textbf{Respuesta:} 200 OK (\texttt{application/xml}) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} Voucher\allowbreak Payments\allowbreak Controller} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak invoicing/\allowbreak payments}} \\*
\hline
\textbf{Petición:} \texttt{Register\allowbreak Payment\allowbreak Request} & \textbf{Respuesta:} 201 CREATED (\texttt{Voucher\allowbreak Payment\allowbreak Resource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak invoicing/\allowbreak payments/\allowbreak vouchers/\allowbreak \{voucherId\}}} \\*
\hline
\textbf{Petición:} Variable de ruta (\texttt{voucherId}) & \textbf{Respuesta:} 200 OK (\texttt{List\textless Voucher\allowbreak Payment\allowbreak Resource\textgreater}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak invoicing/\allowbreak payments/\allowbreak branches/\allowbreak \{branchId\}/\allowbreak daily}} \\*
\hline
\textbf{Petición:} Variable de ruta (\texttt{branchId}), filtro query (\texttt{date}) & \textbf{Respuesta:} 200 OK (\texttt{Daily\allowbreak Cash\allowbreak Summary\allowbreak Resource}) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} Series\allowbreak Configurations\allowbreak Controller} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak invoicing/\allowbreak series-configurations}} \\*
\hline
\textbf{Petición:} \texttt{Configure\allowbreak Series\allowbreak Request} & \textbf{Respuesta:} 201 CREATED (\texttt{Series\allowbreak Configuration\allowbreak Resource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak invoicing/\allowbreak series-configurations/\allowbreak branches/\allowbreak \{branchId\}}} \\*
\hline
\textbf{Petición:} Variable de ruta (\texttt{branchId}) & \textbf{Respuesta:} 200 OK (\texttt{List\textless Series\allowbreak Configuration\allowbreak Resource\textgreater}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{PATCH} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak invoicing/\allowbreak series-configurations/\allowbreak \{id\}/\allowbreak deactivate}} \\*
\hline
\textbf{Petición:} Variable de ruta (\texttt{id}) & \textbf{Respuesta:} 200 OK (\texttt{Series\allowbreak Configuration\allowbreak Resource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{PATCH} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak invoicing/\allowbreak series-configurations/\allowbreak \{id\}/\allowbreak activate}} \\*
\hline
\textbf{Petición:} Variable de ruta (\texttt{id}) & \textbf{Respuesta:} 200 OK (\texttt{Series\allowbreak Configuration\allowbreak Resource}) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} Financial\allowbreak Reports\allowbreak Controller} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak invoicing/\allowbreak financial-reports/\allowbreak cash-flow}} \\*
\hline
\textbf{Petición:} Filtros query (\texttt{startDate}, \texttt{endDate}, \texttt{branchId}) & \textbf{Respuesta:} 200 OK (\texttt{Cash\allowbreak Flow\allowbreak Report\allowbreak Resource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak invoicing/\allowbreak financial-reports/\allowbreak cash-flow/\allowbreak pdf}} \\*
\hline
\textbf{Petición:} Filtros query (\texttt{startDate}, \texttt{endDate}, \texttt{branchId}) & \textbf{Respuesta:} 200 OK (\texttt{application/pdf}) \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Controladores REST ubicados en com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers.

**Recursos DTO de Petición y Respuesta del Perímetro Fiscal**

La transferencia de información entre el perímetro exterior y el núcleo transaccional se modela a través de objetos de transferencia de datos inmutables estructurados como registros de Java. En las operaciones de mutación, componentes como **IssueVoucherRequest**, **IssueCreditNoteRequest**, **VoidVoucherRequest**, **VoucherLineRequest**, **RegisterPaymentRequest** y **ConfigureSeriesRequest** aplican validaciones semánticas tempranas sobre importes monetarios positivos, formatos de serie reglamentarios y completitud de datos tributarios.

En los flujos de respuesta, **ElectronicVoucherResource** proporciona la vista integral del comprobante fiscal consolidando los importes desglosados de subtotal e impuesto, el catálogo de partidas gravadas y los enlaces seguros a los entregables oficiales de la SUNAT. Complementariamente, proyecciones como **ElectronicVoucherSummaryResource**, **DailyCashSummaryResource** y **CashFlowReportResource** suministran datos agregados y optimizados para cuadrículas de consulta interactiva y balances financieros en tiempo real.

En la @tbl:invoicing-resources-dtos se especifican los atributos clave, tipos funcionales y reglas de integridad estructural de los recursos DTO del contexto.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Recursos DTO de Entrada y Salida del Bounded Context Invoicing \& Compliance} \label{tbl:invoicing-resources-dtos} \\
\hline
\thfirst{Aspecto de Recurso} & \thcell{Especificación de Atributos e Integridad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Recurso} & \thcell{Especificación de Atributos e Integridad} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} Issue\allowbreak Voucher\allowbreak Request \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{branchId}, \texttt{customerId}, \texttt{workOrderId}, \texttt{voucherType}, \texttt{serie}, \texttt{customerInfo}, \texttt{currency}, \texttt{lines} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotNull} para branchId y customerInfo con validación anidada (\texttt{@Valid}), \texttt{@NotBlank} y patrón \texttt{@Pattern(regexp = "\textasciicircum(FACTURA|BOLETA)\$")} para voucherType, formato de serie \texttt{@Pattern(regexp = "\textasciicircum[F|B|T][A-Z0-9]\{3\}\$")}, \texttt{@NotBlank} para moneda y lista no vacía \texttt{@NotEmpty} para renglones con elementos validados (\texttt{@Valid}). \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} Issue\allowbreak Credit\allowbreak Note\allowbreak Request \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{branchId}, \texttt{referenceVoucherId}, \texttt{reasonCode}, \texttt{reasonDescription}, \texttt{currency}, \texttt{lines} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotNull} para branchId y comprobante de referencia, \texttt{@NotBlank} para código de motivo y divisa, \texttt{@NotBlank} y \texttt{@Size(max = 250)} para sustento descriptivo y \texttt{@NotEmpty} para partidas rectificativas con validación anidada (\texttt{@Valid}). \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} Void\allowbreak Voucher\allowbreak Request \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{voidReason} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank} y \texttt{@Size(min = 10, max = 250)} para la causa legal explícita de anulación o comunicación formal de baja ante SUNAT. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} Voucher\allowbreak Line\allowbreak Request \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{itemId}, \texttt{itemType}, \texttt{description}, \texttt{quantity}, \texttt{unitPriceWithIgv} \\*
\hline
\textbf{Validación de Integridad} & Anotación \texttt{@NotBlank} y patrón \texttt{@Pattern(regexp = "\textasciicircum(PRODUCT|SERVICE)\$")} para naturaleza del ítem, \texttt{@NotBlank} y \texttt{@Size(max = 250)} para denominación y \texttt{@NotNull} junto a \texttt{@Positive} para cantidad física e importe unitario con IGV incluido. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} Customer\allowbreak Fiscal\allowbreak Info\allowbreak Request \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{taxId}, \texttt{legalName}, \texttt{fiscalAddress}, \texttt{documentType} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank} en todas las propiedades, restricción de tipo \texttt{@Pattern(regexp = "\textasciicircum(DNI|RUC|CE|PASSPORT)\$")} y validación algorítmica Módulo 11 en caso de persona jurídica con RUC. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} Register\allowbreak Payment\allowbreak Request \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{voucherId}, \texttt{amount}, \texttt{currency}, \texttt{paymentMethod}, \texttt{transactionReference} \\*
\hline
\textbf{Validación de Integridad} & Anotación \texttt{@NotNull} para identificador de comprobante, \texttt{@NotNull} y \texttt{@Positive} para importe amortizado, \texttt{@NotBlank} para divisa y medio de pago homologado con catálogo cerrado, y \texttt{@Size(max = 100)} opcional para código de operación financiera. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} Configure\allowbreak Series\allowbreak Request \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{branchId}, \texttt{voucherType}, \texttt{serie}, \texttt{initialCorrelative} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotNull} para sucursal, \texttt{@NotBlank} para tipo de comprobante, formato regulatorio \texttt{@Pattern(regexp = "\textasciicircum[F|B|T][A-Z0-9]\{3\}\$")} y \texttt{@PositiveOrZero} para correlativo numérico de arranque. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} Electronic\allowbreak Voucher\allowbreak Resource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{tenantId}, \texttt{branchId}, \texttt{customerId}, \texttt{workOrderId}, \texttt{voucherType}, \texttt{serie}, \texttt{number}, \texttt{fullVoucherNumber}, \texttt{subtotal}, \texttt{igvAmount}, \texttt{totalAmount}, \texttt{currency}, \texttt{status}, \texttt{customerInfo}, \texttt{digitalReceipts}, \texttt{sunatResponse}, \texttt{lines}, \texttt{payments}, \texttt{issuedAt} \\*
\hline
\textbf{Validación de Integridad} & Serialización inmutable JSON con identificadores de contexto, cálculos impositivos desglosados, estados fiscales y colecciones subordinadas de partidas y abonos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} Electronic\allowbreak Voucher\allowbreak Summary\allowbreak Resource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{fullVoucherNumber}, \texttt{voucherType}, \texttt{totalAmount}, \texttt{currency}, \texttt{status}, \texttt{issuedAt}, \texttt{isFullyPaid} \\*
\hline
\textbf{Validación de Integridad} & Proyección inmutable resumida para consultas de catálogo de alta velocidad y cuadrículas de control en clientes frontend. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} Voucher\allowbreak Line\allowbreak Resource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{itemId}, \texttt{itemType}, \texttt{description}, \texttt{quantity}, \texttt{unitValue}, \texttt{unitPrice}, \texttt{igvAmount}, \texttt{totalLine} \\*
\hline
\textbf{Validación de Integridad} & Representación inmutable de partida gravada con desglose de valor unitario sin impuesto, cuota de IGV e importe liquidado al consumidor. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} Digital\allowbreak Receipt\allowbreak Urls\allowbreak Response \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{pdfUrl}, \texttt{xmlUrl}, \texttt{cdrUrl} \\*
\hline
\textbf{Validación de Integridad} & Enlaces URI seguros y firmados hacia el repositorio en la nube para descarga de la representación gráfica PDF, el XML firmado y la constancia CDR. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} Sunat\allowbreak Response\allowbreak Dto \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{responseCode}, \texttt{description}, \texttt{digitalSignatureHash} \\*
\hline
\textbf{Validación de Integridad} & Constancia documental de homologación tributaria con código de respuesta oficial, glosa descriptiva de SUNAT y resumen hash SHA-256. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} Voucher\allowbreak Payment\allowbreak Resource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{voucherId}, \texttt{amount}, \texttt{currency}, \texttt{paymentMethod}, \texttt{transactionReference}, \texttt{status}, \texttt{paidAt} \\*
\hline
\textbf{Validación de Integridad} & Constancia financiera inmutable de recaudación de fondos con medio de pago clasificado, trazabilidad bancaria y sello cronológico ISO 8601. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} Daily\allowbreak Cash\allowbreak Summary\allowbreak Resource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{branchId}, \texttt{date}, \texttt{totalCash}, \texttt{totalCard}, \texttt{totalTransfer}, \texttt{totalDigitalWallets}, \texttt{totalCollected}, \texttt{paymentCount} \\*
\hline
\textbf{Validación de Integridad} & Cuadre consolidado de caja diaria por sede física con balance de importes recaudados por canal y recuento atómico de operaciones. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} Series\allowbreak Configuration\allowbreak Resource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{tenantId}, \texttt{branchId}, \texttt{voucherType}, \texttt{serie}, \texttt{currentCorrelative}, \texttt{isActive} \\*
\hline
\textbf{Validación de Integridad} & Ficha inmutable del estado operativo y contador secuencial progresivo de la serie correlativa habilitada en el taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} Cash\allowbreak Flow\allowbreak Report\allowbreak Resource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{tenantId}, \texttt{branchId}, \texttt{startDate}, \texttt{endDate}, \texttt{totalIncome}, \texttt{totalExpenses}, \texttt{netCashFlow}, \texttt{currency}, \texttt{movements} \\*
\hline
\textbf{Validación de Integridad} & Estado financiero patrimonial de flujo de fondos con consolidación de ingresos de cobros, egresos de compras y planillas, balance neto y libro cronológico. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} Cash\allowbreak Flow\allowbreak Movement\allowbreak Resource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{transactionId}, \texttt{movementDate}, \texttt{type}, \texttt{category}, \texttt{concept}, \texttt{referenceNumber}, \texttt{amount}, \texttt{runningBalance} \\*
\hline
\textbf{Validación de Integridad} & Línea cronológica individual de movimiento monetario con tipificación de ingreso o egreso, categoría transaccional y saldo progresivo en cuenta. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes ubicados en com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources (subpaquetes requests y responses).

**Ensambladores de Recursos y Transformación de Tipos**

Para garantizar una separación rigurosa entre las representaciones externas de transporte y los modelos de dominio, la arquitectura suministra ensambladores de recursos dedicados. Estas clases de transformación operan de forma bidireccional y sin estado, traduciendo cargas útiles JSON entrantes hacia comandos de la capa de aplicación y proyectando entidades y agregados hacia recursos DTO enriquecidos para consumo de clientes web y móviles.

El componente **ElectronicVoucherResourceAssembler** centraliza la conversión de peticiones de emisión, notas de crédito y anulaciones hacia sus comandos transaccionales respectivos, componiendo además las proyecciones detalladas y sumarizadas del comprobante. A su vez, **VoucherPaymentResourceAssembler**, **SeriesConfigurationResourceAssembler** y **FinancialReportResourceAssembler** orquestan la transformación de asientos de cobro, parametrizaciones de correlativos y estados consolidados de movimientos de caja.

En la @tbl:invoicing-resource-assemblers se definen los métodos principales, signaturas operativas y matrices de transformación implementadas por los ensambladores de recursos.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Ensambladores de Recursos del Bounded Context Invoicing \& Compliance} \label{tbl:invoicing-resource-assemblers} \\
\hline
\thfirst{Aspecto Ensamblador} & \thcell{Firma y Transformación de Tipos} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto Ensamblador} & \thcell{Firma y Transformación de Tipos} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Electronic\allowbreak Voucher\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromRequest} \\*
\hline
\textbf{Transformación} & \texttt{Issue\allowbreak Voucher\allowbreak Request,\allowbreak  TenantId} $\longrightarrow$ \allowbreak \texttt{Issue\allowbreak Electronic\allowbreak Voucher\allowbreak Command} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Electronic\allowbreak Voucher\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCreditNoteCommandFromRequest} \\*
\hline
\textbf{Transformación} & \texttt{Issue\allowbreak Credit\allowbreak Note\allowbreak Request,\allowbreak  TenantId} $\longrightarrow$ \allowbreak \texttt{Issue\allowbreak Credit\allowbreak Note\allowbreak Command} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Electronic\allowbreak Voucher\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toVoidCommandFromRequest} \\*
\hline
\textbf{Transformación} & \texttt{Void\allowbreak Voucher\allowbreak Request,\allowbreak  UUID,\allowbreak  TenantId} $\longrightarrow$ \allowbreak \texttt{Void\allowbreak Electronic\allowbreak Voucher\allowbreak Command} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Electronic\allowbreak Voucher\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResourceFromEntity} \\*
\hline
\textbf{Transformación} & \texttt{Electronic\allowbreak Voucher} $\longrightarrow$ \allowbreak \texttt{Electronic\allowbreak Voucher\allowbreak Resource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Electronic\allowbreak Voucher\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toSummaryResourceFromEntity} \\*
\hline
\textbf{Transformación} & \texttt{Electronic\allowbreak Voucher} $\longrightarrow$ \allowbreak \texttt{Electronic\allowbreak Voucher\allowbreak Summary\allowbreak Resource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Electronic\allowbreak Voucher\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toLineResourceFromEntity} \\*
\hline
\textbf{Transformación} & \texttt{Voucher\allowbreak Line} $\longrightarrow$ \allowbreak \texttt{Voucher\allowbreak Line\allowbreak Resource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Voucher\allowbreak Payment\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromRequest} \\*
\hline
\textbf{Transformación} & \texttt{Register\allowbreak Payment\allowbreak Request,\allowbreak  TenantId} $\longrightarrow$ \allowbreak \texttt{Register\allowbreak Voucher\allowbreak Payment\allowbreak Command} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Voucher\allowbreak Payment\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResourceFromEntity} \\*
\hline
\textbf{Transformación} & \texttt{Voucher\allowbreak Payment} $\longrightarrow$ \allowbreak \texttt{Voucher\allowbreak Payment\allowbreak Resource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Voucher\allowbreak Payment\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toDailySummaryResource} \\*
\hline
\textbf{Transformación} & \texttt{UUID,\allowbreak  LocalDate,\allowbreak  List\textless Voucher\allowbreak Payment\textgreater} $\longrightarrow$ \allowbreak \texttt{Daily\allowbreak Cash\allowbreak Summary\allowbreak Resource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Series\allowbreak Configuration\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromRequest} \\*
\hline
\textbf{Transformación} & \texttt{Configure\allowbreak Series\allowbreak Request,\allowbreak  TenantId} $\longrightarrow$ \allowbreak \texttt{Configure\allowbreak Series\allowbreak Command} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Series\allowbreak Configuration\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResourceFromEntity} \\*
\hline
\textbf{Transformación} & \texttt{Series\allowbreak Configuration} $\longrightarrow$ \allowbreak \texttt{Series\allowbreak Configuration\allowbreak Resource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Financial\allowbreak Report\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toReportResource} \\*
\hline
\textbf{Transformación} & \texttt{Cash\allowbreak Flow\allowbreak Statement} $\longrightarrow$ \allowbreak \texttt{Cash\allowbreak Flow\allowbreak Report\allowbreak Resource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Financial\allowbreak Report\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toMovementResource} \\*
\hline
\textbf{Transformación} & \texttt{Cash\allowbreak Flow\allowbreak Movement} $\longrightarrow$ \allowbreak \texttt{Cash\allowbreak Flow\allowbreak Movement\allowbreak Resource} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Clases ubicadas bajo el paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak transform.

**Fachada de Contexto Abierto y Protocolo Anticorrupción**

La interoperabilidad síncrona en memoria entre Invoicing & Compliance y los demás bounded contexts de la plataforma se canaliza mediante la interfaz **InvoicingContextFacade**. Este componente materializa el patrón Open Host Service complementado con una Capa Anticorrupción, permitiendo que módulos consumidores como Workshop Operations soliciten la facturación de órdenes mecánicas mediante contratos formalizados y libres de dependencias hacia los modelos internos de persistencia o directivas del estándar UBL 2.1.

A través del método *generateVoucherFromWorkOrder()*, la fachada recibe la especificación consolidada de repuestos y labores devengadas en foso para computar los desgloses impositivos y generar el comprobante legal respectivo. Asimismo, métodos como *getVouchersByWorkOrderId()* e *isWorkOrderFullySettled()* habilitan al taller para verificar instantáneamente si una orden de trabajo cuenta con liquidación financiera total antes de autorizar la salida física del vehículo del recinto.

En la @tbl:invoicing-facade-methods se exponen las signaturas de operaciones, parámetros de intercambio, tipos de retorno y módulos consumidores de la fachada de contexto abierto.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Métodos de la Fachada de Contexto Abierto InvoicingContextFacade} \label{tbl:invoicing-facade-methods} \\
\hline
\thfirst{Aspecto del Contrato} & \thcell{Firma, Retorno y Consumidores} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Contrato} & \thcell{Firma, Retorno y Consumidores} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{generateVoucherFromWorkOrder}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{Generate\allowbreak Voucher\allowbreak From\allowbreak Work\allowbreak Order\allowbreak Command\allowbreak Dto command} $\longrightarrow$ \allowbreak \texttt{Voucher\allowbreak Generation\allowbreak Result\allowbreak Dto} \\*
\hline
\textbf{Módulos Consumidores} & Workshop Operations (MRO) \\*
\hline
\textbf{Propósito} & Liquidación formal de órdenes de trabajo mecánicas finalizadas en foso. Convierte repuestos y servicios devengados en factura o boleta legal ante SUNAT. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{getVouchersByWorkOrderId}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID workOrderId} $\longrightarrow$ \allowbreak \texttt{List\textless Voucher\allowbreak Summary\allowbreak Dto\textgreater} \\*
\hline
\textbf{Módulos Consumidores} & Workshop Operations (MRO), Auditoría de Taller \\*
\hline
\textbf{Propósito} & Consulta síncrona en memoria de los comprobantes fiscales emitidos para una orden de trabajo mecánica específica. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{isWorkOrderFullySettled}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID workOrderId} $\longrightarrow$ \allowbreak \texttt{boolean} \\*
\hline
\textbf{Módulos Consumidores} & Workshop Operations (MRO) \\*
\hline
\textbf{Propósito} & Verificación perimetral de cancelación total del importe facturado para autorizar el pase de salida física del automóvil. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak interfaces.\allowbreak acl.

**Eventos de Integración y Coordinación Asíncrona Intermodular**

La coordinación transaccional desacoplada con el ecosistema de Atelier Platform se articula a través de un lenguaje publicado compuesto por eventos de integración inmutables. El contexto publica hechos fiscales concluidos que notifican la emisión de comprobantes, la obtención de resoluciones CDR aprobatorias o rechazadas por la SUNAT, la anulación formal de comprobantes y el registro de recaudaciones de fondos en caja, asegurando que módulos como CRM, MRO y Notificaciones reaccionen de manera eventual y autónoma.

De forma complementaria, el contexto suscribe eventos de integración emitidos por otros dominios para mantener la fidelidad de sus balances contables. La recepción de **PurchaseOrderReceivedIntegrationEvent** proveniente de inventario y de **PayrollPaidIntegrationEvent** procedente de recursos humanos permite imputar de forma automática los egresos operativos por compra de piezas y nóminas en el reporte consolidado de flujo de caja, logrando una visión financiera integral de las operaciones del taller.

En la @tbl:invoicing-integration-events se sintetiza la taxonomía de los eventos de integración publicados y consumidos por Invoicing & Compliance, detallando sus cargas útiles y repercusiones arquitectónicas.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Eventos de Integración del Bounded Context Invoicing \& Compliance} \label{tbl:invoicing-integration-events} \\
\hline
\thfirst{Aspecto de Integración} & \thcell{Carga Útil y Sincronización Intermodular} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Integración} & \thcell{Carga Útil y Sincronización Intermodular} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} Electronic\allowbreak Voucher\allowbreak Issued\allowbreak Integration\allowbreak Event \quad (\textit{Tipo:} Publicado)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{voucherId}, \texttt{tenantId}, \texttt{branchId}, \texttt{workOrderId}, \texttt{fullVoucherNumber}, \texttt{voucherType}, \texttt{totalAmount}, \texttt{currency}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Workshop Operations (MRO), Contabilidad \\*
\hline
\textbf{Efecto Arquitectónico} & Notifica la emisión legal del comprobante con su correlativo asignado, actualizando el estado contable de la orden de trabajo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} Voucher\allowbreak Accepted\allowbreak By\allowbreak Sunat\allowbreak Integration\allowbreak Event \quad (\textit{Tipo:} Publicado)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{voucherId}, \texttt{tenantId}, \texttt{fullVoucherNumber}, \texttt{digitalSignatureHash}, \texttt{pdfUrl}, \texttt{xmlUrl}, \texttt{cdrUrl}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Customer \& Fleet Management (CRM), Notificaciones \\*
\hline
\textbf{Efecto Arquitectónico} & Dispara el envío transaccional por correo electrónico al cliente adjuntando la representación impresa PDF y el XML UBL 2.1 con su constancia CDR. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} Voucher\allowbreak Rejected\allowbreak By\allowbreak Sunat\allowbreak Integration\allowbreak Event \quad (\textit{Tipo:} Publicado)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{voucherId}, \texttt{tenantId}, \texttt{fullVoucherNumber}, \texttt{responseCode}, \texttt{rejectionReason}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Operaciones de Taller, Portal Administrativo \\*
\hline
\textbf{Efecto Arquitectónico} & Genera una alerta operativa inmediata en la consola de supervisión de caja para la subsanación de discrepancias tributarias o refacturación. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} Voucher\allowbreak Voided\allowbreak Integration\allowbreak Event \quad (\textit{Tipo:} Publicado)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{voucherId}, \texttt{tenantId}, \texttt{branchId}, \texttt{fullVoucherNumber}, \texttt{voidReason}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Workshop Operations (MRO), Contabilidad \\*
\hline
\textbf{Efecto Arquitectónico} & Notifica la anulación legal o comunicación de baja del comprobante ante SUNAT para la reversión contable y reactivación operativa de la orden de trabajo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} Voucher\allowbreak Payment\allowbreak Registered\allowbreak Integration\allowbreak Event \quad (\textit{Tipo:} Publicado)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{paymentId}, \texttt{tenantId}, \texttt{voucherId}, \texttt{workOrderId}, \texttt{amount}, \texttt{currency}, \texttt{paymentMethod}, \texttt{isFullyPaid}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Workshop Operations (MRO), Finanzas \\*
\hline
\textbf{Efecto Arquitectónico} & Notifica el abono monetario contra el comprobante y confirma si el saldo restante es cero para habilitar el pase de salida del vehículo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} Work\allowbreak Order\allowbreak Delivered\allowbreak Integration\allowbreak Event \quad (\textit{Tipo:} Consumido)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{tenantId}, \texttt{branchId}, \texttt{customerId}, \texttt{deliveredAt}, \texttt{occurredOn} \\*
\hline
\textbf{Módulo Emisor} & Workshop Operations (MRO) \\*
\hline
\textbf{Efecto Arquitectónico} & Inicia la auditoría fiscal de cierre y emite una alerta contable preventiva en caso de que la orden entregada carezca de comprobante emitido. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} Purchase\allowbreak Order\allowbreak Received\allowbreak Integration\allowbreak Event \quad (\textit{Tipo:} Consumido)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{purchaseOrderId}, \texttt{tenantId}, \texttt{supplierId}, \texttt{orderNumber}, \texttt{receiptNumber}, \texttt{receiptImageUrl}, \texttt{totalCost}, \texttt{occurredOn} \\*
\hline
\textbf{Módulo Emisor} & Inventory \& Supply Chain \\*
\hline
\textbf{Efecto Arquitectónico} & Imputa automáticamente el egreso financiero por adquisición de repuestos y suministros al estado consolidado de flujo de caja del taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} Payroll\allowbreak Paid\allowbreak Integration\allowbreak Event \quad (\textit{Tipo:} Consumido)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{payrollPaymentId}, \texttt{tenantId}, \texttt{branchId}, \texttt{periodYear}, \texttt{periodMonth}, \texttt{totalDisbursedAmount}, \texttt{currency}, \texttt{occurredOn} \\*
\hline
\textbf{Módulo Emisor} & Human Resources Management \\*
\hline
\textbf{Efecto Arquitectónico} & Imputa automáticamente el desembolso salarial de los colaboradores del taller al estado consolidado de flujo de caja del taller. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Registros inmutables pertenecientes al paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak interfaces.\allowbreak events.

El diseño y estructuración de la Capa de Interfaz de Invoicing & Compliance consolida tres decisiones fundamentales de ingeniería de software que blindan la exactitud tributaria y la resiliencia operativa de Atelier Platform:

En primer lugar, la rigurosa pureza RESTful y el blindaje perimetral temprano de las reglas impositivas aseguran que ninguna anomalía de formato o inconsistencia aritmética penetre hacia las capas internas de la aplicación. Al centralizar la validación de series alfanuméricas, comprobación algorítmica de RUC mediante Módulo 11 y obligatoriedad de datos fiscales en los propios registros DTO, el sistema intercepta peticiones malformadas en la frontera de entrada, aliviando la carga de procesamiento transaccional y protegiendo la coherencia de los libros contables del taller.

En segundo término, la soberanía probatoria y la distribución optimizada de activos tributarios digitales resuelven el desafío del almacenamiento de comprobantes oficiales sin degradar el rendimiento de la red corporativa. Al desacoplar la custodia pesada de archivos PDF, XML firmados y constancias CDR hacia almacenamiento seguro en la nube y servir en el perímetro únicamente localizadores URI firmados, la arquitectura minimiza la latencia de transferencia, optimiza el consumo de memoria del backend y garantiza acceso inalterable a la documentación fiscal exigida por el ente recaudador.

Por último, la interoperabilidad híbrida sustentada en la fachada de contexto abierto y la coreografía reactiva mediante Transactional Outbox proporciona un equilibrio óptimo entre inmediatez operativa y resiliencia intermodular. Mientras la fachada síncrona agiliza la verificación en memoria del estado de liquidación de órdenes de trabajo en patio de taller, la publicación asíncrona de eventos de integración garantiza consistencia eventual con módulos como Notificaciones, Inventario y Recursos Humanos, afianzando la continuidad del negocio automotriz frente a fluctuaciones en los servicios telemáticos estatales.

#### 2.6.7.3. Application Layer

La Capa de Aplicación de Invoicing & Compliance opera como el núcleo de orquestación transaccional bajo el paquete canónico com.andeva.atelier.platform.invoicing.application. Su propósito arquitectónico consiste en gobernar los flujos de emisión y anulación de comprobantes electrónicos bajo el estándar UBL 2.1 ante la SUNAT, gestionar las amortizaciones financieras de cobranza en caja y consolidar el estado de movimientos del taller mecánico, estructurándose rigurosamente bajo el patrón CQRS para desacoplar las mutaciones transaccionales de las proyecciones analíticas.

Para garantizar la coherencia tributaria y la resiliencia operativa en las estaciones de servicio, la capa de aplicación implementa cuatro directrices de diseño táctico:

- **Orquestación transaccional atómica y reserva secuencial de correlativos:** Delimita fronteras de consistencia transaccional bajo nivel de aislamiento de lectura confirmada, coordinando la reserva atómica del correlativo en **SeriesConfiguration**, la segregación impositiva con **PeruvianTaxCalculationEngine** y la persistencia local previa a la comunicación fiscal con el proveedor electrónico.
- **Control de flujo determinista mediante el tipo sellado Result<T, InvoicingApplicationError>:** Todos los casos de uso canalizan sus respuestas a través del tipo sellado provisto por el Shared Kernel, transformando colisiones tributarias, sobrepagos y comprobantes duplicados en valores de retorno inmutables sin recurrir a excepciones no controladas.
- **Coreografía reactiva de eventos y garantía de entrega At-Least-Once mediante Transactional Outbox:** Los eventos de dominio se propagan tras la confirmación atómica en base de datos, mientras que los eventos de integración se serializan en el Transactional Outbox para su publicación asíncrona hacia el bus de mensajería, blindando la consistencia intermodular frente a caídas temporales de red.
- **Inversión de dependencias y aislamiento perimetral mediante puertos ACL y pasarelas cloud:** La comunicación con la pasarela tributaria de Nubefact, el motor de correo transaccional, el generador de reportes en PDF y el padrón de contribuyentes de SUNAT se abstrae mediante puertos secundarios y adaptadores anticorrupción, preservando la pureza conceptual del modelo de dominio.

En la @tbl:invoicing-application-types se sintetiza el catálogo consolidado de servicios de comando, servicios de consulta, fachada de contexto, escuchadores de eventos y puertos de salida que articulan la Capa de Aplicación de Invoicing & Compliance.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo Consolidado de la Capa de Aplicación de Invoicing \& Compliance} \label{tbl:invoicing-application-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endhead
Electronic\allowbreak Voucher\allowbreak Command\allowbreak Service & Contrato de casos de uso de escritura para emisi\'on, rectificaci\'on, baja y conciliaci\'on tributaria. \\*
\hline
\textbf{Categoría} & Servicio de Comando (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por ElectronicVoucherCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Electronic\allowbreak Voucher\allowbreak Command\allowbreak ServiceImpl & Orquesta la emisi\'on, notas de cr\'edito, anulaciones y respuestas SUNAT con reserva at\'omica de serie. \\*
\hline
\textbf{Categoría} & Implementaci\'on de Servicio de Comando \\*
\hline
\textbf{Relaciones} & Coordina agregados ElectronicVoucher, SeriesConfiguration y repositorios bajo transacci\'on ACID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak internal.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Voucher\allowbreak Payment\allowbreak Command\allowbreak Service & Contrato de operaciones transaccionales de amortizaci\'on y registro de cobros contra comprobantes fiscales. \\*
\hline
\textbf{Categoría} & Servicio de Comando (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por VoucherPaymentCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Voucher\allowbreak Payment\allowbreak Command\allowbreak ServiceImpl & Gestiona abonos en caja del taller, valida saldo insoluto y emite liberaci\'on de orden hacia MRO. \\*
\hline
\textbf{Categoría} & Implementaci\'on de Servicio de Comando \\*
\hline
\textbf{Relaciones} & Coordina entidad VoucherPayment y agregado ElectronicVoucher con repositorios. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak internal.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Series\allowbreak Configuration\allowbreak Command\allowbreak Service & Contrato de parametrizaci\'on y ciclo de vida de series alfanum\'ericas fiscales por sede f\'isica. \\*
\hline
\textbf{Categoría} & Servicio de Comando (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por SeriesConfigurationCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Series\allowbreak Configuration\allowbreak Command\allowbreak ServiceImpl & Administra altas de series fiscales seg\'un normativa SUNAT, activaciones y suspensiones por sede. \\*
\hline
\textbf{Categoría} & Implementaci\'on de Servicio de Comando \\*
\hline
\textbf{Relaciones} & Coordina agregado SeriesConfiguration con persistencia JPA. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak internal.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Electronic\allowbreak Voucher\allowbreak Query\allowbreak Service & Contrato de consultas de solo lectura para cat\'alogo de comprobantes, auditor\'ia y activos tributarios. \\*
\hline
\textbf{Categoría} & Servicio de Consulta (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por ElectronicVoucherQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak queryservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Electronic\allowbreak Voucher\allowbreak Query\allowbreak ServiceImpl & Ejecuta proyecciones paginadas de comprobantes y descargas de activos binarios XML UBL 2.1, PDF y CDR. \\*
\hline
\textbf{Categoría} & Implementaci\'on de Servicio de Consulta \\*
\hline
\textbf{Relaciones} & Consulta repositorios bajo aislamiento de solo lectura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak internal.\allowbreak queryservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Voucher\allowbreak Payment\allowbreak Query\allowbreak Service & Contrato de consulta de amortizaciones financieras y cuadres de caja diarios por sucursal f\'isica. \\*
\hline
\textbf{Categoría} & Servicio de Consulta (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por VoucherPaymentQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak queryservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Voucher\allowbreak Payment\allowbreak Query\allowbreak ServiceImpl & Proyecta abonos desglosados por comprobante y balances de recaudaci\'on diaria por medio de pago. \\*
\hline
\textbf{Categoría} & Implementaci\'on de Servicio de Consulta \\*
\hline
\textbf{Relaciones} & Consulta repositorios y vistas JPA de recaudaci\'on. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak internal.\allowbreak queryservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Cash\allowbreak Flow\allowbreak Query\allowbreak Service & Contrato de consulta anal\'itica para consolidaci\'on del estado de cuenta y flujo de caja del taller. \\*
\hline
\textbf{Categoría} & Servicio de Consulta (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por CashFlowQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak queryservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Cash\allowbreak Flow\allowbreak Query\allowbreak ServiceImpl & Ejecuta algoritmo de consolidaci\'on en 7 pasos unificando ingresos con egresos de repuestos y n\'omina. \\*
\hline
\textbf{Categoría} & Implementaci\'on de Servicio de Consulta \\*
\hline
\textbf{Relaciones} & Coordina fachadas de Inventory y HR, y el puerto CashFlowPdfGeneratorPort. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak internal.\allowbreak queryservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Invoicing\allowbreak Context\allowbreak Facade\allowbreak Impl & Implementa la fachada de contexto abierto para atender requerimientos de facturaci\'on y liquidaci\'on fiscal desde operaciones de taller. \\*
\hline
\textbf{Categoría} & Implementaci\'on de Fachada de Contexto Abierto \\*
\hline
\textbf{Relaciones} & Coordina ElectronicVoucherCommandService y ElectronicVoucherQueryService mapeando agregados hacia DTO inmutables de fachada. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Voucher\allowbreak Domain\allowbreak Event\allowbreak Handler & Manejador transaccional de eventos de dominio para emisi\'on, aceptaci\'on fiscal, pago y baja. \\*
\hline
\textbf{Categoría} & Manejador de Eventos de Dominio \\*
\hline
\textbf{Relaciones} & Despacha correos v\'ia Resend, emite alertas a MRO y coordina con Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak internal.\allowbreak eventhandlers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Work\allowbreak Order\allowbreak Delivered\allowbreak Event\allowbreak Listener & Escuchador de integraci\'on del evento de entrega vehicular emitido por Workshop Operations (MRO). \\*
\hline
\textbf{Categoría} & Escuchador de Eventos de Integraci\'on \\*
\hline
\textbf{Relaciones} & Verifica emisi\'on previa de comprobante y genera advertencia administrativa en omisiones fiscales. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak internal.\allowbreak eventhandlers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Purchase\allowbreak Order\allowbreak Received\allowbreak Event\allowbreak Listener & Escuchador de integraci\'on de recepci\'on f\'isica de repuestos emitido por Inventory \& Supply Chain. \\*
\hline
\textbf{Categoría} & Escuchador de Eventos de Integraci\'on \\*
\hline
\textbf{Relaciones} & Asienta facturas de compra recibidas como egreso comercial en el flujo de caja del taller. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak internal.\allowbreak eventhandlers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Payroll\allowbreak Paid\allowbreak Event\allowbreak Listener & Escuchador de integraci\'on de liquidaci\'on salarial emitido por Human Resources \& Payroll. \\*
\hline
\textbf{Categoría} & Escuchador de Eventos de Integraci\'on \\*
\hline
\textbf{Relaciones} & Incorpora dispersi\'on salarial del personal t\'ecnico como egreso laboral en el flujo de caja. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak internal.\allowbreak eventhandlers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Invoicing\allowbreak Transactional\allowbreak Outbox\allowbreak Publisher & Publicador que serializa eventos de integraci\'on en la tabla outbox\_messages bajo entrega At-Least-Once. \\*
\hline
\textbf{Categoría} & Publicador Transaccional Outbox \\*
\hline
\textbf{Relaciones} & Intercepta eventos del dominio y los almacena en base de datos para despacho as\'incrono confiable. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak internal.\allowbreak eventhandlers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Nubefact\allowbreak Pse\allowbreak Fiscal\allowbreak Gateway & Puerto de salida para comunicaci\'on telem\'atica y firma digital UBL 2.1 ante el Proveedor de Servicios Electr\'onicos Nubefact. \\*
\hline
\textbf{Categoría} & Puerto de Salida Pasarela Fiscal \\*
\hline
\textbf{Relaciones} & Consumido por ElectronicVoucherCommandServiceImpl e implementado por NubefactPseFiscalAdapter. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak internal.\allowbreak outbound.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Customer\allowbreak Fiscal\allowbreak Validation\allowbreak Acl\allowbreak Service & Puerto de salida para recuperar datos fiscales y consultar vigencia de RUC o DNI en CRM o padr\'on tributario de SUNAT. \\*
\hline
\textbf{Categoría} & Puerto de Salida ACL \\*
\hline
\textbf{Relaciones} & Consumido por ElectronicVoucherCommandServiceImpl e implementado por CustomerFiscalValidationAclAdapter. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak internal.\allowbreak outbound.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Sunat\allowbreak Cdr\allowbreak Storage\allowbreak Gateway & Puerto de salida para almacenamiento inmutable y custodia cloud de constancias de recepci\'on CDR y tramas XML UBL 2.1 firmadas. \\*
\hline
\textbf{Categoría} & Puerto de Salida Pasarela Cloud \\*
\hline
\textbf{Relaciones} & Consumido por servicios de comando y consulta e implementado por FirebaseSunatCdrStorageAdapter. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak internal.\allowbreak outbound.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Voucher\allowbreak Receipt\allowbreak Email\allowbreak Gateway & Puerto de salida para distribuci\'on as\'incrona de comprobantes electr\'onicos a clientes con adjuntos binarios PDF y XML UBL 2.1. \\*
\hline
\textbf{Categoría} & Puerto de Salida Pasarela Cloud \\*
\hline
\textbf{Relaciones} & Consumido por VoucherDomainEventHandler e implementado por ResendVoucherReceiptEmailAdapter. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak internal.\allowbreak outbound.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Cash\allowbreak Flow\allowbreak Pdf\allowbreak Generator\allowbreak Port & Puerto de salida para renderizado tipogr\'afico vectorial del estado de cuenta de flujo de caja y arqueo operativo del taller con membrete y balance financiero. \\*
\hline
\textbf{Categoría} & Puerto de Salida (Outbound Port) \\*
\hline
\textbf{Relaciones} & Consumido por CashFlowQueryServiceImpl e implementado por OpenPdfCashFlowReportAdapter. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak internal.\allowbreak outbound.\allowbreak acl} \\
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Organización modular canónica en commandservices, internal.commandservices, queryservices, internal.queryservices, internal.eventhandlers, internal.outbound.acl y acl.

**Servicios de Comandos de la Capa de Aplicación**

Los servicios de comandos centralizan la lógica de coordinación de casos de uso de escritura bajo transaccionalidad atómica y nivel de aislamiento de lectura confirmada. La clase **ElectronicVoucherCommandServiceImpl** orquesta la emisión de facturas y boletas electrónicas validando las reglas de UBL 2.1, la reserva de series correlativas, el despacho hacia el proveedor telemático y la emisión de notas de crédito formales.

Por su parte, **VoucherPaymentCommandServiceImpl** gobierna los cobros en caja, fiscalizando que las amortizaciones no excedan el saldo insoluto del comprobante y emitiendo notificaciones intermodulares hacia operaciones de taller cuando se liquida la totalidad de la obligación. En paralelo, **SeriesConfigurationCommandServiceImpl** custodia la parametrización de series oficiales por sucursal física, controlando su estado de activación operativa.

En la @tbl:invoicing-command-services se detallan las signaturas operativas, condiciones transaccionales e impactos en el dominio de los comandos de aplicación.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Operaciones Transaccionales de los Servicios de Comandos de Invoicing \& Compliance} \label{tbl:invoicing-command-services} \\
\hline
\thfirst{Aspecto de Operación} & \thcell{Firma, Transaccionalidad y Efecto en el Dominio} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Operación} & \thcell{Firma, Transaccionalidad y Efecto en el Dominio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Comando:} ElectronicVoucherCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{Issue\allowbreak Electronic\allowbreak Voucher\allowbreak Command} $\longrightarrow$ \texttt{Result<\allowbreak Electronic\allowbreak Voucher,\allowbreak  Invoicing\allowbreak Application\allowbreak Error>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida cliente en CRM, reserva correlativo atómico en serie activa de sucursal, ejecuta cálculo impositivo con redondeo Half-Even y despacha trama UBL 2.1 a SUNAT vía Nubefact registrando hash y enlaces oficiales. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Comando:} ElectronicVoucherCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{Issue\allowbreak Credit\allowbreak Note\allowbreak Command} $\longrightarrow$ \texttt{Result<\allowbreak Electronic\allowbreak Voucher,\allowbreak  Invoicing\allowbreak Application\allowbreak Error>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Verifica existencia y estado del comprobante original modificado, valida motivo tributario reglado, reserva correlativo de serie rectificatoria y emite nota de crédito UBL 2.1 ante SUNAT. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Comando:} ElectronicVoucherCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{Void\allowbreak Electronic\allowbreak Voucher\allowbreak Command} $\longrightarrow$ \texttt{Result<\allowbreak Void,\allowbreak  Invoicing\allowbreak Application\allowbreak Error>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Constata estado formal aceptado y ventana de tiempo legal máxima de 7 días calendario, muta comprobante a VOIDED y despacha comunicación de baja ante el ente fiscal. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Comando:} ElectronicVoucherCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{Process\allowbreak Sunat\allowbreak Response\allowbreak Command} $\longrightarrow$ \texttt{Result<\allowbreak Electronic\allowbreak Voucher,\allowbreak  Invoicing\allowbreak Application\allowbreak Error>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Procesa respuesta asíncrona de webhook del PSE/OSE o reintento de outbox, asienta constancia de recepción CDR o causa de rechazo y actualiza hash digital y estado tributario. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Comando:} VoucherPaymentCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{Register\allowbreak Voucher\allowbreak Payment\allowbreak Command} $\longrightarrow$ \texttt{Result<\allowbreak Voucher\allowbreak Payment,\allowbreak  Invoicing\allowbreak Application\allowbreak Error>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida comprobante en estado vigente, verifica saldo insoluto remanente, registra abono inmutable en caja y emite WorkOrderSettledIntegrationEvent hacia MRO cuando se liquida la totalidad del monto adeudado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Comando:} SeriesConfigurationCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{Configure\allowbreak Series\allowbreak Command} $\longrightarrow$ \texttt{Result<\allowbreak Series\allowbreak Configuration,\allowbreak  Invoicing\allowbreak Application\allowbreak Error>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida regex canónica de serie fiscal, comprueba unicidad por sucursal física y tipo de documento, e instanciación en estado ACTIVE con correlativo inicial en uno. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Comando:} SeriesConfigurationCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{Deactivate\allowbreak Series\allowbreak Command} $\longrightarrow$ \texttt{Result<\allowbreak Void,\allowbreak  Invoicing\allowbreak Application\allowbreak Error>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Conmuta la serie fiscal al estado inactivo impidiendo la reserva de nuevos números correlativos en el punto de facturación de la sede física. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Comando:} SeriesConfigurationCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{Activate\allowbreak Series\allowbreak Command} $\longrightarrow$ \texttt{Result<\allowbreak Void,\allowbreak  Invoicing\allowbreak Application\allowbreak Error>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Restablece la vigencia operativa de una serie suspendida previamente habilitando su uso para facturación regular en caja de taller. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Métodos transaccionales segregados entre contratos en commandservices e implementaciones en internal.commandservices.

**Servicios de Consultas y Consolidación de Flujo de Caja**

Las consultas de aplicación se ejecutan bajo aislamiento transaccional de solo lectura para posibilitar proyecciones de alta concurrencia sin contención en la base de datos relacional. El servicio **ElectronicVoucherQueryServiceImpl** atiende búsquedas paginadas y descargas de activos tributarios oficiales (XML firmado, PDF y CDR), mientras **VoucherPaymentQueryServiceImpl** reporta el historial de abonos y el arqueo diario de caja por sucursal física.

Destaca el servicio **CashFlowQueryServiceImpl**, el cual ejecuta un algoritmo de consolidación en memoria estructurado en siete fases: consulta de ingresos por cobros de facturación en **voucher_payments**, consulta de egresos por compras recibidas en **purchase_orders** de inventario, consulta de egresos por planillas desembolsadas en **payroll_payments** de recursos humanos, unificación cronológica temporal, cálculo del saldo progresivo acumulado, cómputo del flujo neto y renderizado del estado en PDF con diseño bancario corporativo, excluyendo costos fijos indirectos ajenos a la operación física del taller.

En la @tbl:invoicing-query-services se exponen los métodos de consulta, parámetros de entrada, tipos de retorno y criterios de proyección del catálogo de lectura.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Métodos de Consulta de la Capa de Aplicación de Invoicing \& Compliance} \label{tbl:invoicing-query-services} \\
\hline
\thfirst{Aspecto de Consulta} & \thcell{Parámetros, Retorno y Criterio de Proyección} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Consulta} & \thcell{Parámetros, Retorno y Criterio de Proyección} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Consulta:} ElectronicVoucherQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetElectronic\allowbreak VoucherByIdQuery} $\longrightarrow$ \texttt{Optional<\allowbreak ElectronicVoucher>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Recupera la entidad agregada completa por identificador primario UUID para visualización integral y auditoría fiscal interna. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Consulta:} ElectronicVoucherQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetElectronic\allowbreak VouchersPagedQuery} $\longrightarrow$ \texttt{PagedModel<\allowbreak ElectronicVoucherSummaryProjection>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Catálogo paginado con filtros multicriterio por sede física, tipo de comprobante, rango de fechas de emisión, estado tributario y cliente. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Consulta:} ElectronicVoucherQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetVouchersBy\allowbreak WorkOrderIdQuery} $\longrightarrow$ \texttt{List<\allowbreak ElectronicVoucherSummaryProjection>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Proyecta los comprobantes tributarios vinculados contractualmente a una orden de mantenimiento vehicular en MRO. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Consulta:} ElectronicVoucherQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetVoucher\allowbreak XmlContentQuery} $\longrightarrow$ \texttt{byte[]\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Descarga la trama estructurada XML original firmada digitalmente con certificado X.509 bajo especificación OASIS UBL 2.1. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Consulta:} ElectronicVoucherQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetVoucher\allowbreak PdfContentQuery} $\longrightarrow$ \texttt{byte[]\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Recupera el binario PDF con diseño gráfico oficial de comprobante, código QR de fiscalización rápida y firma digital imprimible. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Consulta:} ElectronicVoucherQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetVoucher\allowbreak CdrContentQuery} $\longrightarrow$ \texttt{byte[]\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Provee la Constancia de Recepción oficial en paquete comprimido emitida por los servidores centrales de SUNAT o del OSE. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Consulta:} VoucherPaymentQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetVoucher\allowbreak PaymentsBy\allowbreak VoucherIdQuery} $\longrightarrow$ \texttt{List<\allowbreak VoucherPaymentProjection>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Recupera el historial secuencial de amortizaciones y abonos monetarios efectuados sobre un comprobante fiscal específico. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Consulta:} VoucherPaymentQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetDaily\allowbreak CashSummaryQuery} $\longrightarrow$ \texttt{Daily\allowbreak Cash\allowbreak Summary\allowbreak Projection\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Cuadre de caja diario de sucursal física en fecha determinada, discriminando recaudación por efectivo, tarjetas bancarias, transferencia y billeteras digitales. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Consulta:} CashFlowQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetCashFlow\allowbreak StatementQuery} $\longrightarrow$ \texttt{CashFlow\allowbreak Statement\allowbreak Projection\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Ejecuta algoritmo de 7 pasos uniendo cronológicamente ingresos por servicios con egresos de repuestos y nómina, computando saldos acumulados y excluyendo costos fijos indirectos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Consulta:} CashFlowQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{ExportCash\allowbreak FlowPdfQuery} $\longrightarrow$ \texttt{byte[]\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Renderiza informe consolidado del flujo de caja en formato binario PDF con estilo bancario corporativo, cabecera formal, resumen ejecutivo y detalle analítico. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Métodos de consulta de solo lectura, segregados entre contratos en queryservices e implementaciones en internal.queryservices.

**Manejadores de Eventos de Dominio y de Integración**

La reactividad y sincronización del contexto se sustentan en escuchadores desacoplados que procesan transiciones de estado tras la confirmación exitosa de las transacciones. El componente **VoucherDomainEventHandler** intercepta eventos locales en fase posterior a la confirmación para remitir comprobantes PDF y XML al cliente mediante correo transaccional y notificar a operaciones de taller cuando una orden mecánica ha sido cancelada en su totalidad para liberar el vehículo en patio.

Asimismo, **WorkOrderDeliveredEventListener** fiscaliza que los vehículos retirados cuenten con facturación legal, mientras **PurchaseOrderReceivedEventListener** y **PayrollPaidEventListener** alimentan el flujo de caja ante recepciones de mercadería y desembolsos salariales. Finalmente, **InvoicingTransactionalOutboxPublisher** asegura la publicación garantizada con semántica de entrega al menos una vez hacia el bus de mensajería corporativo.

En la @tbl:invoicing-event-handlers se especifican los manejadores de eventos, los tipos de mensaje suscritos, sus fases transaccionales y sus repercusiones en el ecosistema.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Manejadores de Eventos de Dominio y de Integración de Invoicing \& Compliance} \label{tbl:invoicing-event-handlers} \\
\hline
\thfirst{Aspecto del Manejador} & \thcell{Evento Suscrito, Fase Transaccional y Efecto} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Manejador} & \thcell{Evento Suscrito, Fase Transaccional y Efecto} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} VoucherDomainEventHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{Voucher\allowbreak{}Accepted\allowbreak{}By\allowbreak{}Sunat\allowbreak{}Event} \quad (\textit{Fase:} Posterior a confirmación) \\*
\hline
\textbf{Acción Orquestada} & Despacha correo transaccional automático al cliente con PDF oficial y XML UBL 2.1 firmado adjuntos vía ResendEmailAdapter. \\*
\hline
\textbf{Destino del Efecto} & TransactionalEmailSenderPort / Resend \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} VoucherDomainEventHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{Voucher\allowbreak{}Payment\allowbreak{}Registered\allowbreak{}Event} \quad (\textit{Fase:} Posterior a confirmación) \\*
\hline
\textbf{Acción Orquestada} & Si el comprobante queda liquidado en su totalidad y está asociado a una orden, emite WorkOrderSettledIntegrationEvent hacia MRO para habilitar retiro vehicular. \\*
\hline
\textbf{Destino del Efecto} & Event Bus / Workshop Operations MRO \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} VoucherDomainEventHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{Voucher\allowbreak{}Voided\allowbreak{}Event} \quad (\textit{Fase:} Posterior a confirmación) \\*
\hline
\textbf{Acción Orquestada} & Propaga anulación tributaria formal para bloqueo de operaciones asociadas y registro en pistas de auditoría contable. \\*
\hline
\textbf{Destino del Efecto} & Auditoría Contable / Transactional Outbox \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Escuchador de Integración:} WorkOrderDeliveredEventListener} \\*
\hline
\textbf{Evento Capturado} & \texttt{Work\allowbreak{}Order\allowbreak{}Delivered\allowbreak{}Integration\allowbreak{}Event} \quad (\textit{Fase:} Recepción de Integración) \\*
\hline
\textbf{Acción Orquestada} & Valida la existencia de comprobante emitido en estado regular y emite advertencia administrativa si la orden carece de facturación previa. \\*
\hline
\textbf{Destino del Efecto} & ElectronicVoucherCommandService / Alertas \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Escuchador de Integración:} PurchaseOrderReceivedEventListener} \\*
\hline
\textbf{Evento Capturado} & \texttt{Purchase\allowbreak{}Order\allowbreak{}Received\allowbreak{}Integration\allowbreak{}Event} \quad (\textit{Fase:} Recepción de Integración) \\*
\hline
\textbf{Acción Orquestada} & Registra el desembolso por adquisición de insumos y piezas como egreso operativo para la proyección del flujo de caja del taller. \\*
\hline
\textbf{Destino del Efecto} & CashFlowQueryService / Módulo Financiero \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Escuchador de Integración:} PayrollPaidEventListener} \\*
\hline
\textbf{Evento Capturado} & \texttt{Payroll\allowbreak{}Paid\allowbreak{}Integration\allowbreak{}Event} \quad (\textit{Fase:} Recepción de Integración) \\*
\hline
\textbf{Acción Orquestada} & Incorpora la dispersión salarial de los técnicos mecánicos como egreso de personal dentro de la consolidación de caja. \\*
\hline
\textbf{Destino del Efecto} & CashFlowQueryService / Módulo Financiero \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Publicador Transaccional:} InvoicingTransactionalOutboxPublisher} \\*
\hline
\textbf{Evento Capturado} & \texttt{Invoicing\allowbreak{}Domain\allowbreak{}Event} \quad (\textit{Fase:} Misma transacción ACID) \\*
\hline
\textbf{Acción Orquestada} & Serializa y persiste eventos en tabla outbox\_messages con garantía de entrega At-Least-Once hacia Kafka o RabbitMQ sin bloqueo distribuido. \\*
\hline
\textbf{Destino del Efecto} & outbox\_messages / Message Broker \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Suscripción y despacho transaccional desacoplado bajo el paquete canónico application.\allowbreak internal.\allowbreak eventhandlers.

**Puertos de Salida, Pasarelas y Adaptadores Anticorrupción**

El aislamiento arquitectónico de Invoicing & Compliance respecto a servicios en la nube y pasarelas de terceros se formaliza a través de puertos de salida especializados ubicados en el subpaquete com.andeva.atelier.platform.invoicing.application.internal.outbound.acl. El contrato **NubefactPseFiscalGateway** encapsula la comunicación telemática hacia el proveedor autorizado por SUNAT y aísla la estructura técnica JSON requerida para la homologación de comprobantes UBL 2.1.

Por su parte, **CustomerFiscalValidationAclService** recupera y valida datos tributarios desde el contexto de clientes, **VoucherReceiptEmailGateway** canaliza el envío de comprobantes mediante Resend, **SunatCdrStorageGateway** custodia las constancias de recepción y XML firmados en almacenamiento seguro en la nube, mientras que **CashFlowPdfGeneratorPort** maqueta reportes tipográficos de flujo de caja con membrete y balance financiero.

En la @tbl:invoicing-outbound-ports se detallan las interfaces de salida, signaturas clave, tecnologías empleadas y propósitos arquitectónicos de las pasarelas del contexto.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Puertos de Salida, Pasarelas y Adaptadores de la Capa de Aplicación de Invoicing \& Compliance} \label{tbl:invoicing-outbound-ports} \\
\hline
\thfirst{Puerto o Pasarela} & \thcell{Métodos Principales, Tecnología y Propósito} \\
\hline
\endfirsthead
\hline
\thfirst{Puerto o Pasarela} & \thcell{Métodos Principales, Tecnología y Propósito} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} Nubefact\allowbreak Pse\allowbreak Fiscal\allowbreak Gateway \quad (\textit{Categoría:} Pasarela Fiscal REST)} \\*
\hline
\textbf{Métodos Principales} & \texttt{dispatchVoucher}, \texttt{dispatchCreditNote}, \texttt{voidVoucher} \\*
\hline
\textbf{Propósito Técnico} & Despacho perimetral de tramas JSON V1 al PSE/OSE Nubefact para generación de XML UBL 2.1, firma con certificado digital y obtención de CDR de SUNAT. \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak internal.\allowbreak outbound.\allowbreak acl} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} Customer\allowbreak Fiscal\allowbreak Validation\allowbreak Acl\allowbreak Service \quad (\textit{Categoría:} Puerto ACL de Dominio)} \\*
\hline
\textbf{Métodos Principales} & \texttt{getCustomerFiscalData}, \texttt{validateTaxIdStatus} \\*
\hline
\textbf{Propósito Técnico} & Consulta desacoplada de identidad fiscal, padrón de RUC activo y domicilio fiscal de clientes comerciales y particulares desde CRM o padrón tributario. \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak internal.\allowbreak outbound.\allowbreak acl} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} Sunat\allowbreak Cdr\allowbreak Storage\allowbreak Gateway \quad (\textit{Categoría:} Pasarela de Custodia Cloud)} \\*
\hline
\textbf{Métodos Principales} & \texttt{storeCdrXml}, \texttt{storeSignedXml}, \texttt{retrieveCdrXml} \\*
\hline
\textbf{Propósito Técnico} & Almacenamiento inmutable y custodia cloud de constancias de recepción CDR y tramas XML UBL 2.1 firmadas en Firebase Storage. \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak internal.\allowbreak outbound.\allowbreak acl} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} Voucher\allowbreak Receipt\allowbreak Email\allowbreak Gateway \quad (\textit{Categoría:} Pasarela de Notificación Cloud)} \\*
\hline
\textbf{Métodos Principales} & \texttt{sendVoucherReceiptEmail} \\*
\hline
\textbf{Propósito Técnico} & Despacho asíncrono de comprobantes tributarios a los clientes con archivos binarios PDF y XML UBL 2.1 incrustados como adjuntos seguros vía Resend. \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak internal.\allowbreak outbound.\allowbreak acl} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} Cash\allowbreak Flow\allowbreak Pdf\allowbreak Generator\allowbreak Port \quad (\textit{Categoría:} Puerto de Salida (Outbound Port))} \\*
\hline
\textbf{Métodos Principales} & \texttt{byte[] generateCashFlowPdf(UUID tenantId, CashFlowSummary summary, List<CashFlowMovement> movements)} \\*
\hline
\textbf{Tecnología} & OpenPDF / Thymeleaf \\*
\hline
\textbf{Propósito Técnico} & Renderizado tipográfico vectorial del estado de cuenta de flujo de caja y arqueo operativo del taller con membrete y balance financiero. \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak internal.\allowbreak outbound.\allowbreak acl} \\
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Puertos e interfaces de salida organizados bajo el subpaquete canónico application.\allowbreak internal.\allowbreak outbound.\allowbreak acl.

La concepción arquitectónica de la Capa de Aplicación de Invoicing & Compliance consolida tres fundamentos de ingeniería de software que afianzan la exactitud tributaria y la resiliencia operativa en Atelier Platform:

En primer lugar, la disciplina tributaria, el determinismo matemático y la inmutabilidad legal de los comprobantes electrónicos garantizan un cumplimiento riguroso de la normativa SUNAT UBL 2.1. Al orquestar la reserva atómica de correlativos antes de la persistencia local y canalizar el despacho hacia el proveedor telemático con contingencia en el Transactional Outbox, el sistema asegura que cada comprobante emitido mantenga inviolabilidad probatoria y cuadre exacto en sus partidas gravadas, eliminando riesgos de contingencias fiscales para el taller automotriz.

En segundo término, la soberanía financiera alcanzada mediante la consolidación en memoria del flujo de caja operativo proporciona una inteligencia de negocio integral para la administración del taller. La capacidad de unificar transaccionalmente los cobros de facturación con los egresos devengados por abastecimiento de repuestos en inventario y dispersión de planillas salariales en recursos humanos faculta a los gerentes de sede para auditar su rentabilidad neta en tiempo real y exportar estados de cuenta con rigor bancario sin acoplamiento a nivel de esquemas relacionales.

Por último, el desacoplamiento perimetral y el blindaje del modelo de dominio frente a servicios en la nube y pasarelas telemáticas garantizan alta tolerancia a fallos y portabilidad tecnológica. La interposición de capas anticorrupción y puertos de salida dedicados aísla la lógica transaccional respecto a especificaciones propietarias de proveedores como Nubefact o servicios de mensajería como Resend, asegurando que eventuales intermitencias externas jamás bloqueen los procesos de cobro y entrega vehicular en las bahías de trabajo mecánicas.

#### 2.6.7.4. Infrastructure Layer

La Capa de Infraestructura del Bounded Context Invoicing & Compliance, materializada bajo el paquete canónico **com.andeva.atelier.platform.invoicing.infrastructure**, provee los mecanismos de persistencia relacional, aislamiento transaccional y comunicación perimetral telemática con las entidades tributarias y servicios externos. Esta capa implementa los contratos de repositorio definidos en el dominio mediante Spring Data JPA e Hibernate sobre PostgreSQL 16 alojado en Aiven Cloud, asegurando la inmutabilidad legal de los comprobantes emitidos, la sincronización atómica de numeraciones correlativas fiscales mediante bloqueo pesimista de fila, y la resiliencia en la emisión electrónica a través de adaptadores telemáticos hacia proveedores de servicios electrónicos homologados.

Las directrices técnicas fundamentales que rigen el diseño de la Capa de Infraestructura abarcan los siguientes pilares de arquitectura:

- **Garantía de unicidad y concurrencia serial mediante bloqueo pesimista en base de datos:** Reserva atómica y sin condiciones de carrera de números correlativos tributarios mediante consultas bloqueantes sobre configuraciones de series fiscales, impidiendo huecos y colisiones de numeración entre múltiples cajas de cobro.
- **Persistencia físico-relacional auditada y ciclo de vida inmutable de comprobantes:** Mapeo de agregados a tablas normalizadas con claves compuestas, integridad referencial en cascada sobre líneas y pagos, y protección estricta ante modificaciones arbitrarias de registros fiscales ya informados ante la autoridad tributaria.
- **Reconstitución pura del modelo de dominio y ensamblaje desacoplado:** Ensambladores de persistencia que invocan el método estático de fábrica de las entidades de dominio para restaurar su estado sin emitir eventos de dominio espurios durante consultas, complementados con convertidores JPA para tipos complejos y valores enumerados.
- **Aislamiento perimetral y resiliencia de integración telemática en la nube:** Pasarelas secundarias resilientes para la transmisión de tramas tributarias estructuradas hacia proveedores autorizados con circuit breaker y reintentos exponenciales, despacho de notificaciones con comprobantes digitales adjuntos y publicación atómica de eventos en la tabla de mensajería transaccional.

En la @tbl:invoicing-infrastructure-types se sintetiza el catálogo consolidado de clases, adaptadores de persistencia, ensambladores, convertidores y pasarelas de infraestructura que estructuran este perímetro técnico.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo Consolidado de la Capa de Infraestructura de Invoicing \& Compliance} \label{tbl:invoicing-infrastructure-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\
\hline
\endhead
Electronic\allowbreak Voucher\allowbreak Persistence\allowbreak Entity & Mapeo relacional de comprobantes electrónicos fiscales como facturas, boletas y notas de crédito a la tabla física electronic\_vouchers. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Hereda de AuditableAbstractPersistenceEntity. Raíz de persistencia con colecciones lazy en cascada hacia líneas y pagos. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Voucher\allowbreak Line\allowbreak Persistence\allowbreak Entity & Mapeo relacional de ítems, servicios y repuestos facturados a la tabla física voucher\_lines. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Clave foránea hacia electronic\_vouchers. Almacena descripción, cantidades, valores unitarios y cuota tributaria de IGV. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Voucher\allowbreak Payment\allowbreak Persistence\allowbreak Entity & Mapeo relacional de transacciones de amortización, cobros y medios de pago a la tabla física voucher\_payments. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Hereda de AuditableAbstractPersistenceEntity. Clave foránea hacia electronic\_vouchers. Soporta auditoría y cuadre de caja diario. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Series\allowbreak Configuration\allowbreak Persistence\allowbreak Entity & Mapeo relacional de rangos y contadores correlativos de series fiscales por sucursal a la tabla sunat\_series\_configurations. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Hereda de AuditableAbstractPersistenceEntity. Restricción de unicidad compuesta sobre sucursal, tipo de comprobante y serie. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Electronic\allowbreak Voucher\allowbreak Persistence\allowbreak Repository & Interfaz Spring Data JPA para operaciones relacionales y consultas derivadas sobre comprobantes electrónicos. \\*
\hline
\textbf{Categoría} & Repositorio JPA \\*
\hline
\textbf{Relaciones} & Extiende JpaRepository. Consultas unívocas por serie y número correlativo, filtrado por orden de trabajo y rangos de fechas. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Voucher\allowbreak Payment\allowbreak Persistence\allowbreak Repository & Interfaz Spring Data JPA para administración relacional y trazabilidad de pagos y amortizaciones. \\*
\hline
\textbf{Categoría} & Repositorio JPA \\*
\hline
\textbf{Relaciones} & Extiende JpaRepository. Consultas por comprobante e informes agregados de recaudación por sucursal y jornada operativa. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Series\allowbreak Configuration\allowbreak Persistence\allowbreak Repository & Interfaz Spring Data JPA con bloqueo pesimista en base de datos para la reserva atómica de correlativos fiscales. \\*
\hline
\textbf{Categoría} & Repositorio JPA \\*
\hline
\textbf{Relaciones} & Extiende JpaRepository. Implementa consulta de bloqueo exclusivo de fila mediante anotación LockModeType.PESSIMISTIC\_WRITE. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Electronic\allowbreak Voucher\allowbreak Repository\allowbreak Impl & Adaptador secundario de salida que implementa el puerto de dominio ElectronicVoucherRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Persistencia \\*
\hline
\textbf{Relaciones} & Orquesta guardado relacional en cascada, extracción atómica de eventos de dominio y registro en la tabla outbox\_messages. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Voucher\allowbreak Payment\allowbreak Repository\allowbreak Impl & Adaptador secundario de salida que implementa el puerto de dominio VoucherPaymentRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Persistencia \\*
\hline
\textbf{Relaciones} & Persiste cobros monetarios, valida consistencia de saldos insolutos y publica eventos atómicos hacia outbox\_messages. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Series\allowbreak Configuration\allowbreak Repository\allowbreak Impl & Adaptador secundario de salida que implementa el puerto de dominio SeriesConfigurationRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Persistencia \\*
\hline
\textbf{Relaciones} & Ejecuta incremento correlativo estrictamente secuencial bajo transacción atómica y bloqueo pesimista de fila. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Electronic\allowbreak Voucher\allowbreak Persistence\allowbreak Assembler & Mapeo y ensamblaje bidireccional entre la raíz de agregado ElectronicVoucher y la entidad relacional. \\*
\hline
\textbf{Categoría} & Ensamblador de Persistencia \\*
\hline
\textbf{Relaciones} & Reconstituye el agregado puro mediante método estático reconstitute() sin emitir eventos de dominio espurios. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak assemblers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Voucher\allowbreak Payment\allowbreak Persistence\allowbreak Assembler & Mapeo y ensamblaje bidireccional entre la entidad de dominio VoucherPayment y la entidad relacional de persistencia. \\*
\hline
\textbf{Categoría} & Ensamblador de Persistencia \\*
\hline
\textbf{Relaciones} & Mapea montos monetarios, medios de pago, referencias bancarias y marcas temporales de recaudación. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak assemblers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Series\allowbreak Configuration\allowbreak Persistence\allowbreak Assembler & Mapeo y ensamblaje bidireccional entre la entidad pura SeriesConfiguration y la entidad relacional de persistencia. \\*
\hline
\textbf{Categoría} & Ensamblador de Persistencia \\*
\hline
\textbf{Relaciones} & Restaura configuraciones de series fiscales sincronizando estado operativo y contador secuencial de emisión. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak assemblers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Voucher\allowbreak Type\allowbreak Converter & Convertidor JPA para mapeo bidireccional entre el enum VoucherType y códigos de comprobante SUNAT en VARCHAR(10). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Serializa tipos fiscales como 01 para Factura, 03 para Boleta de Venta y 07 para Nota de Crédito. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Voucher\allowbreak Status\allowbreak Converter & Convertidor JPA para serialización del enum de ciclo de vida VoucherStatus a columna relacional VARCHAR(20). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Normaliza estados fiscales DRAFT, ISSUED, ACCEPTED\_SUNAT, REJECTED\_SUNAT y VOIDED. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Payment\allowbreak Method\allowbreak Converter & Convertidor JPA para mapeo del enum de medios de pago PaymentMethod a columna VARCHAR(30). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Mapea modalidades CASH, CREDIT\_CARD, DEBIT\_CARD, BANK\_TRANSFER, DIGITAL\_WALLET\_YAPE y DIGITAL\_WALLET\_PLIN. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Payment\allowbreak Status\allowbreak Converter & Convertidor JPA para serialización del enum PaymentStatus a columna relacional VARCHAR(20). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Normaliza estados financieros de abonos PENDING, COMPLETED y REFUNDED. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Money\allowbreak Converter & Convertidor JPA para mapeo del objeto de valor Money hacia columna escalar NUMERIC(10, 2). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Extrae BigDecimal preservando exactitud contable en dos decimales bajo redondeo Half-Even y divisa PEN o USD. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Tax\allowbreak Calculation\allowbreak Converter & Convertidor JPA para serialización y desglose del cálculo tributario de base imponible e importe de IGV. \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Descompone el cálculo porcentual legal del 18\% asegurando consistencia matemática entre cabecera y líneas. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Voucher\allowbreak Serie\allowbreak Converter & Convertidor JPA para mapeo del objeto de valor VoucherSerie hacia columna relacional VARCHAR(4). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Aplica validación estricta de formato alfanumérico reglamentado por SUNAT como F001, B001, FC01 o BC01. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Nubefact\allowbreak Pse\allowbreak Fiscal\allowbreak Adapter & Pasarela telemática externa que interactúa con la API RESTful JSON V1 del PSE homologado Nubefact. \\*
\hline
\textbf{Categoría} & Pasarela Perimetral Fiscal \\*
\hline
\textbf{Relaciones} & Implementa NubefactPseFiscalGateway mediante Spring WebClient, autenticación Bearer y reintentos con backoff exponencial. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak infrastructure.\allowbreak external.\allowbreak tax.\allowbreak nubefact} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Resend\allowbreak Voucher\allowbreak Receipt\allowbreak Email\allowbreak Adapter & Pasarela de notificaciones transaccionales que despacha correos con comprobantes electrónicos adjuntos vía Resend API. \\*
\hline
\textbf{Categoría} & Pasarela Cloud de Notificaciones \\*
\hline
\textbf{Relaciones} & Implementa VoucherReceiptEmailGateway adjuntando representaciones PDF renderizadas y XML UBL 2.1 con firma digital. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak infrastructure.\allowbreak external.\allowbreak mail.\allowbreak resend} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Firebase\allowbreak Sunat\allowbreak Cdr\allowbreak Storage\allowbreak Adapter & Almacenamiento cloud y custodia probatoria inmutable de constancias oficiales CDR y XML UBL 2.1. \\*
\hline
\textbf{Categoría} & Pasarela Cloud de Almacenamiento \\*
\hline
\textbf{Relaciones} & Implementa SunatCdrStorageGateway mediante Firebase Storage SDK y generación de enlaces de descarga temporales. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak infrastructure.\allowbreak external.\allowbreak cloud.\allowbreak firebase} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Customer\allowbreak Fiscal\allowbreak Validation\allowbreak Acl\allowbreak Adapter & Adaptador anticorrupción de salida hacia el contexto CRM y padrones web de contribuyentes. \\*
\hline
\textbf{Categoría} & Adaptador ACL de Salida \\*
\hline
\textbf{Relaciones} & Implementa CustomerFiscalValidationAclService resolviendo razón social, condición tributaria y domicilio fiscal oficial. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak infrastructure.\allowbreak external.\allowbreak acl.\allowbreak crm} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Invoicing\allowbreak Outbox\allowbreak Message\allowbreak Relay\allowbreak Adapter & Despachador transaccional que inserta eventos de integración en la tabla outbox\_messages para publicación desacoplada. \\*
\hline
\textbf{Categoría} & Adaptador de Mensajería Outbox \\*
\hline
\textbf{Relaciones} & Persiste eventos JSONB atómicamente en PostgreSQL 16 para retransmisión confiable con semántica de entrega al menos una vez. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak infrastructure.\allowbreak external.\allowbreak messaging.\allowbreak outbox} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Open\allowbreak Pdf\allowbreak Cash\allowbreak Flow\allowbreak Report\allowbreak Adapter & Renderizado binario de informes vectoriales en formato PDF para estados de cuenta de flujo de caja y arqueos de tesorería del taller. \\*
\hline
\textbf{Categoría} & Adaptador de Infraestructura Externa \\*
\hline
\textbf{Relaciones} & Implementa CashFlowPdfGeneratorPort compilando plantillas Thymeleaf con OpenPDF 2.0.3. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak infrastructure.\allowbreak external.\allowbreak reporting.\allowbreak openpdf} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes organizados bajo los subpaquetes canónicos persistence.jpa (entities, repositories, adapters, assemblers, converters) y los módulos de integración perimetral external (tax, mail, cloud, acl, messaging, reporting).

**Entidades de Persistencia JPA y Modelado Relacional Físico**

El modelado relacional de persistencia reproduce fielmente la topología legal y financiera del dominio tributario mediante cuatro entidades JPA mapeadas a sus respectivas tablas físicas en PostgreSQL 16. La raíz de persistencia **ElectronicVoucherPersistenceEntity** se vincula a la tabla **electronic_vouchers**, encapsulando la numeración de serie, base imponible gravada, monto de impuesto general a las ventas, importe total, estado de ciclo de vida, datos fiscales del cliente receptor y metadatos probatorios telemáticos devueltos por la entidad tributaria.

Por su parte, la entidad **VoucherLinePersistenceEntity** estructura los ítems, repuestos y servicios gravados en la tabla **voucher_lines**, mientras que **VoucherPaymentPersistenceEntity** custodia los abonos monetarios y medios de pago en la tabla **voucher_payments**. Finalmente, la entidad **SeriesConfigurationPersistenceEntity** gestiona los contadores correlativos atómicos por sede y tipo de comprobante en la tabla **sunat_series_configurations**. En la @tbl:invoicing-jpa-entities se detallan los esquemas físico-relacionales, claves primarias, índices B-Tree y restricciones de verificación de estas entidades.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Especificación Relacional de Entidades JPA de Invoicing \& Compliance} \label{tbl:invoicing-jpa-entities} \\
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} ElectronicVoucherPersistenceEntity \quad (\textit{Tabla:} \texttt{electronic\_vouchers})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{tenant\_id}, \texttt{branch\_id}, \texttt{customer\_id}, \texttt{work\_order\_id}, \texttt{voucher\_type}, \texttt{serie}, \texttt{number}, \texttt{subtotal}, \texttt{igv\_amount}, \texttt{total\_amount}, \texttt{currency}, \texttt{status}, \texttt{customer\_tax\_id}, \texttt{customer\_legal\_name}, \texttt{customer\_fiscal\_address}, \texttt{customer\_document\_type}, \texttt{sunat\_pdf\_url}, \texttt{sunat\_xml\_url}, \texttt{sunat\_cdr\_url}, \texttt{digital\_signature\_hash}, \texttt{sunat\_response\_code}, \texttt{sunat\_description}, \texttt{voided\_reason}, \texttt{voided\_at} \\*
\hline
\textbf{Restricciones e Índices} & Restricción única uk\_vouchers\_tenant\_serie\_number sobre (tenant\_id, serie, number). Claves foráneas fk\_vouchers\_tenant hacia tenants, fk\_vouchers\_branch hacia branches, fk\_vouchers\_customer hacia customers y fk\_vouchers\_work\_order hacia work\_orders. Restricciones de verificación chk\_voucher\_amounts\_positive sobre subtotal, igv\_amount y total\_amount no negativos. Índices B-Tree idx\_vouchers\_tenant\_created sobre (tenant\_id, created\_at DESC), idx\_vouchers\_work\_order sobre work\_order\_id e idx\_vouchers\_customer sobre (tenant\_id, customer\_id). Relación en cascada total con eliminación de huérfanos hacia líneas y pagos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} VoucherLinePersistenceEntity \quad (\textit{Tabla:} \texttt{voucher\_lines})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{voucher\_id}, \texttt{item\_id}, \texttt{item\_type}, \texttt{description}, \texttt{quantity}, \texttt{unit\_value}, \texttt{unit\_price}, \texttt{igv\_amount}, \texttt{total\_line} \\*
\hline
\textbf{Restricciones e Índices} & Clave foránea fk\_voucher\_lines\_voucher hacia electronic\_vouchers con eliminación en cascada. Clave foránea opcional fk\_voucher\_lines\_item hacia el catálogo de repuestos de inventario. Restricciones de verificación chk\_line\_quantity\_positive para cantidad mayor a cero y chk\_line\_amounts\_positive para valores unitarios y totales no negativos. Índices B-Tree idx\_voucher\_lines\_voucher sobre voucher\_id e idx\_voucher\_lines\_item sobre item\_id. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} VoucherPaymentPersistenceEntity \quad (\textit{Tabla:} \texttt{voucher\_payments})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{voucher\_id}, \texttt{tenant\_id}, \texttt{branch\_id}, \texttt{amount}, \texttt{currency}, \texttt{payment\_method}, \texttt{transaction\_reference}, \texttt{status}, \texttt{paid\_at} \\*
\hline
\textbf{Restricciones e Índices} & Claves foráneas fk\_voucher\_payments\_voucher hacia electronic\_vouchers, fk\_payments\_tenant hacia tenants y fk\_payments\_branch hacia branches. Restricción de verificación chk\_payment\_amount\_positive para importes monetarios mayores a cero. Índices B-Tree idx\_payments\_voucher sobre voucher\_id e idx\_payments\_branch\_date sobre (branch\_id, paid\_at DESC) para cuadres de caja y auditoría financiera de cobros por sede. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} SeriesConfigurationPersistenceEntity \quad (\textit{Tabla:} \texttt{sunat\_series\_configurations})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{tenant\_id}, \texttt{branch\_id}, \texttt{voucher\_type}, \texttt{serie}, \texttt{current\_correlative}, \texttt{is\_active} \\*
\hline
\textbf{Restricciones e Índices} & Restricción única uk\_series\_branch\_type\_serie sobre la tupla (branch\_id, voucher\_type, serie). Claves foráneas fk\_series\_tenant hacia tenants y fk\_series\_branch hacia branches. Restricción de verificación chk\_series\_correlative\_non\_negative para contador correlativo no negativo. Índice compuesto B-Tree idx\_series\_lookup sobre (branch\_id, voucher\_type, is\_active) para resolución instantánea del correlativo activo bajo bloqueo pesimista. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación físico-relacional en PostgreSQL 16 con esquema multi-inquilino bajo Aiven Cloud.

**Repositorios Spring Data JPA y Adaptadores de Persistencia**

La mediación entre el modelo de dominio y el motor relacional PostgreSQL se articula mediante interfaces Spring Data JPA y sus correspondientes adaptadores secundarios de persistencia. El adaptador **ElectronicVoucherRepositoryImpl** implementa el puerto de dominio **ElectronicVoucherRepository**, orquestando el guardado en cascada de cabeceras, líneas y cobros, y garantizando la extracción de eventos de integración acumulados para su inserción atómica en la tabla **outbox_messages** dentro de la misma transacción relacional.

Asimismo, el adaptador **SeriesConfigurationRepositoryImpl** implementa el puerto **SeriesConfigurationRepository**, invocando consultas con bloqueo exclusivo de fila para reservar números correlativos de manera estrictamente secuencial y segura ante transacciones concurrentes en una misma sede física. Por su parte, el adaptador **VoucherPaymentRepositoryImpl** gestiona el registro de amortizaciones y provee consultas agregadas para el balance y arqueo diario de caja por sucursal. En la @tbl:invoicing-repository-adapters se especifican los puertos de dominio, componentes JPA inyectados y operaciones fundamentales de estos adaptadores.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Adaptadores de Persistencia y Puertos de Dominio de Invoicing \& Compliance} \label{tbl:invoicing-repository-adapters} \\
\hline
\thfirst{Aspecto de Adaptador} & \thcell{Especificación Técnica y Persistencia} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Adaptador} & \thcell{Especificación Técnica y Persistencia} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} ElectronicVoucherRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{ElectronicVoucherRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{ElectronicVoucherPersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & Mapea el agregado puro **ElectronicVoucher** hacia **ElectronicVoucherPersistenceEntity** mediante **ElectronicVoucherPersistenceAssembler** bajo el subpaquete persistence.jpa.assemblers. Persiste en PostgreSQL 16 coordinando la cascada de líneas de detalle y cobros mediante *saveAndFlush()*. Extrae eventos de integración acumulados con *pullDomainEvents()* y los inserta de manera atómica en la tabla outbox\_messages. Ejecuta *findById()* con hidratación de colecciones dependientes, *findByTenantIdAndSerieAndNumber()* para recuperación canónica de comprobantes fiscales, *findAllByWorkOrderId()* para auditoría de facturación asociada a órdenes de trabajo y *findAllByTenantAndDateRange()* con segmentación optimizada para reportes contables. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} VoucherPaymentRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{VoucherPaymentRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{VoucherPaymentPersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & Persiste transacciones individuales de pago y amortizaciones financieras vinculadas a comprobantes. Registra la referencia bancaria, método de pago y marca temporal de recaudación. Despacha eventos **VoucherPaymentRegisteredEvent** hacia outbox\_messages para notificar la liberación del vehículo en taller. Ejecuta *findById()* para auditoría transaccional, *findAllByVoucherId()* para consultar el historial completo de amortizaciones y *findAllByBranchAndDate()* para consolidar el arqueo de caja diario de la sucursal física. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} SeriesConfigurationRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{SeriesConfigurationRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{SeriesConfigurationPersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & Administra la asignación estrictamente secuencial de números correlativos tributarios por serie y sucursal. Implementa el método *findActiveForUpdate()* aplicando la anotación LockModeType.PESSIMISTIC\_WRITE de JPA, forzando una instrucción SELECT ... FOR UPDATE en PostgreSQL que bloquea la fila de configuración durante la transacción, eliminando condiciones de carrera y saltos de numeración ante emisiones concurrentes. Ejecuta *save()* para incrementar el contador atómico y *findAllByBranchId()* para la parametrización de puntos de emisión. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Clases ubicadas bajo el paquete canónico com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak adapters.

**Ensambladores de Persistencia y Convertidores de Atributos JPA**

El desacoplamiento entre las estructuras relacionales de base de datos y los tipos puros del dominio se materializa mediante ensambladores de persistencia y convertidores de atributos JPA. El ensamblador **ElectronicVoucherPersistenceAssembler** mapea bidireccionalmente los comprobantes electrónicos, reconstruyendo el agregado puro mediante el método estático *reconstitute()* sin desencadenar emisiones espurias de eventos de integración durante operaciones de lectura o consulta analítica. De modo semejante, los ensambladores **VoucherPaymentPersistenceAssembler** y **SeriesConfigurationPersistenceAssembler** preservan la integridad dimensional de pagos y configuraciones de series.

Este esquema de ensamble y conversión se complementa con siete convertidores de atributos JPA que serializan enumeraciones de dominio y objetos de valor hacia tipos columnares estándar de SQL. Entre ellos destacan **VoucherTypeConverter**, que traduce el tipo de comprobante hacia códigos formales reglamentados, **TaxCalculationConverter**, que garantiza la consistencia porcentual del impuesto, y **MoneyConverter**, que asegura exactitud a dos decimales con redondeo bancario *Half-Even*. En la @tbl:invoicing-persistence-assemblers se describen las conversiones y mapeos de tipos implementados por estos componentes.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Ensambladores de Persistencia y Convertidores JPA de Invoicing \& Compliance} \label{tbl:invoicing-persistence-assemblers} \\
\hline
\thfirst{Aspecto de Mapeo} & \thcell{Tipos Relacionados y Mapeo} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Mapeo} & \thcell{Tipos Relacionados y Mapeo} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} ElectronicVoucherPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{ElectronicVoucher} $\longleftrightarrow$ \texttt{ElectronicVoucherPersistenceEntity} \\*
\hline
\textbf{Mapeo y Conversión} & Traduce VoucherId a UUID y descompone los objetos de valor VoucherSerie, VoucherType, TaxCalculation y CustomerFiscalInfo hacia campos relacionales planos. Mapea metadatos devueltos por SUNAT como URLs de PDF, XML y constancia CDR, hash de firma digital y código de respuesta. Reconstituye el agregado puro mediante el método estático de fábrica *ElectronicVoucher.reconstitute()*, hidratando colecciones de líneas y pagos sin disparar eventos de dominio espurios durante consultas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} VoucherPaymentPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{VoucherPayment} $\longleftrightarrow$ \texttt{VoucherPaymentPersistenceEntity} \\*
\hline
\textbf{Mapeo y Conversión} & Mapea PaymentId a UUID, importe monetario Money, método de pago PaymentMethod y referencia bancaria externa. Reconstituye la entidad de pago mediante *VoucherPayment.reconstitute()* preservando la marca temporal inmutable paid\_at y garantizando la coherencia financiera del saldo insoluto. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} SeriesConfigurationPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{SeriesConfiguration} $\longleftrightarrow$ \texttt{SeriesConfigurationPersistenceEntity} \\*
\hline
\textbf{Mapeo y Conversión} & Traduce SeriesConfigurationId a UUID, serie alfanumérica y tipo de comprobante. Invoca *SeriesConfiguration.reconstitute()* para restaurar el contador correlativo actual y el indicador booleano de operatividad sin generar efectos secundarios transaccionales. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} VoucherTypeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{VoucherType} $\longleftrightarrow$ \texttt{VARCHAR(10)} \\*
\hline
\textbf{Mapeo y Conversión} & Convierte la enumeración de dominio hacia los códigos formales de tipo de documento reglamentados por SUNAT como código 01 para Factura, código 03 para Boleta de Venta y código 07 para Nota de Crédito. Reconstituye el tipo tipificado en lecturas relacionales. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} VoucherStatusConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{VoucherStatus} $\longleftrightarrow$ \texttt{VARCHAR(20)} \\*
\hline
\textbf{Mapeo y Conversión} & Serializa los estados del ciclo de vida del comprobante DRAFT, ISSUED, ACCEPTED\_SUNAT, REJECTED\_SUNAT y VOIDED a cadenas normalizadas en mayúsculas. Reconstituye la enumeración correspondiente con validación de transiciones de estado permitidas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} PaymentMethodConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{PaymentMethod} $\longleftrightarrow$ \texttt{VARCHAR(30)} \\*
\hline
\textbf{Mapeo y Conversión} & Mapea modalidades de cobro comerciales CASH, CREDIT\_CARD, DEBIT\_CARD, BANK\_TRANSFER, DIGITAL\_WALLET\_YAPE y DIGITAL\_WALLET\_PLIN a columnas de texto plano. Reconstituye la opción de cobro garantizando compatibilidad retroactiva. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} PaymentStatusConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{PaymentStatus} $\longleftrightarrow$ \texttt{VARCHAR(20)} \\*
\hline
\textbf{Mapeo y Conversión} & Serializa estados financieros de transacciones de amortización PENDING, COMPLETED y REFUNDED a columnas relacionales. Reconstituye el estado asegurando consistencia con el saldo del comprobante. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} MoneyConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{Money} $\longleftrightarrow$ \texttt{NUMERIC(10,\allowbreak 2)} \\*
\hline
\textbf{Mapeo y Conversión} & Extrae el valor decimal BigDecimal preservando una escala fija de dos decimales con redondeo bancario Half-Even. Reconstituye el objeto de valor asignando la divisa oficial PEN o USD según la moneda del comprobante. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} TaxCalculationConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{TaxCalculation} $\longleftrightarrow$ \texttt{NUMERIC(10,\allowbreak 2)} \\*
\hline
\textbf{Mapeo y Conversión} & Extrae la cuota tributaria calculada de IGV al 18\% sobre el valor gravado de venta. Reconstituye el objeto de valor auditando que la suma de valor neto y tributo coincida exactamente con el importe total liquidado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} VoucherSerieConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{VoucherSerie} $\longleftrightarrow$ \texttt{VARCHAR(4)} \\*
\hline
\textbf{Mapeo y Conversión} & Serializa la serie alfanumérica a cadenas fijas de cuatro caracteres en mayúsculas. Reconstituye el objeto de valor aplicando la regla de validación de formato establecida por SUNAT para comprobantes electrónicos. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes configurados bajo los subpaquetes persistence.jpa.assemblers y persistence.jpa.converters de la capa de infraestructura.

**Pasarelas Fiscales Externas e Integración en la Nube**

La comunicación hacia proveedores telemáticos y servicios en la nube se canaliza a través de pasarelas perimetrales y adaptadores anticorrupción que blindan el núcleo transaccional frente a especificaciones externas. La pasarela **NubefactPseFiscalAdapter** interactúa con la interfaz web del proveedor de servicios electrónicos homologado para la generación del documento estructurado en formato UBL 2.1 y su firma con certificado digital tributario, incorporando políticas de tolerancia a fallos con reintentos exponenciales y aislamiento ante anomalías de red.

Adicionalmente, el adaptador **ResendVoucherReceiptEmailAdapter** despacha notificaciones transaccionales al correo electrónico del cliente adjuntando las representaciones oficiales en formato PDF y XML firmado con constancia de recepción, **FirebaseSunatCdrStorageAdapter** asegura la custodia inmutable de los archivos XML UBL 2.1 y constancias CDR oficiales devueltas por la autoridad tributaria, y **OpenPdfCashFlowReportAdapter** genera los reportes vectoriales de flujo de caja y tesorería con OpenPDF y Thymeleaf. Por último, **CustomerFiscalValidationAclAdapter** valida la condición de contribuyente ante el padrón tributario y **InvoicingOutboxMessageRelayAdapter** asegura la entrega confiable de eventos mediante el patrón Transactional Outbox. En la @tbl:invoicing-external-infrastructure se exponen las tecnologías y responsabilidades de estas pasarelas.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Pasarelas Fiscales Externas, Integración Cloud y Adaptadores de Invoicing \& Compliance} \label{tbl:invoicing-external-infrastructure} \\
\hline
\thfirst{Aspecto Técnico} & \thcell{Tecnología y Responsabilidad de Integración} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto Técnico} & \thcell{Tecnología y Responsabilidad de Integración} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Pasarela Externa:} NubefactPseFiscalAdapter \quad (\textit{Categoría:} Pasarela Perimetral Fiscal)} \\*
\hline
\textbf{Tecnología Subyacente} & Spring WebClient con TLS 1.3, Cabeceras Bearer Token y Circuit Breaker Resilience4j \\*
\hline
\textbf{Responsabilidad} & Transmite la trama de datos estructurada JSON V1 hacia los servicios web del PSE homologado Nubefact para su conversión a UBL 2.1 y firma digital con certificado tributario. Configura timeout de conexión de cinco segundos, timeout de lectura de quince segundos y política de tres reintentos con retroceso exponencial ante errores HTTP 502 o 503. Extrae URLs del PDF generado, XML firmado y constancia CDR devuelta por SUNAT. Implementa el puerto NubefactPseFiscalGateway bajo el subpaquete infrastructure.external.tax.nubefact. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Pasarela Externa:} ResendVoucherReceiptEmailAdapter \quad (\textit{Categoría:} Pasarela Cloud de Notificaciones)} \\*
\hline
\textbf{Tecnología Subyacente} & Resend Cloud REST API vía Spring RestClient con Autenticación API Key \\*
\hline
\textbf{Responsabilidad} & Despacha notificaciones transaccionales a la dirección electrónica del cliente final tras la validación exitosa del comprobante. Adjunta de manera automatizada la representación impresa en formato PDF vectorial y el archivo XML UBL 2.1 con su constancia de recepción de SUNAT, garantizando entrega confiable y trazabilidad de recepción. Implementa el puerto VoucherReceiptEmailGateway bajo el subpaquete infrastructure.external.mail.resend. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Pasarela Externa:} FirebaseSunatCdrStorageAdapter \quad (\textit{Categoría:} Pasarela Cloud de Almacenamiento)} \\*
\hline
\textbf{Tecnología Subyacente} & Firebase Storage SDK con Autenticación Cloud IAM y URLs Firmadas Temporales \\*
\hline
\textbf{Responsabilidad} & Custodia legalmente los archivos XML UBL 2.1 firmados y las constancias de recepción oficiales CDR emitidas por SUNAT de manera inmutable. Facilita la descarga autorizada de artefactos probatorios tributarios mediante generación de enlaces seguros temporales con caducidad parametrizable. Implementa el puerto SunatCdrStorageGateway bajo el subpaquete infrastructure.external.cloud.firebase. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Pasarela Externa:} CustomerFiscalValidationAclAdapter \quad (\textit{Categoría:} Adaptador ACL Datos Tributarios)} \\*
\hline
\textbf{Tecnología Subyacente} & Fachada de Módulo en Memoria hacia CRM y Caché Caffeine con TTL de 24 Horas \\*
\hline
\textbf{Responsabilidad} & Obtiene y certifica en tiempo real la identificación tributaria como RUC de 11 dígitos o DNI de 8 dígitos, razón social o denominación civil y domicilio fiscal del cliente desde el contexto Customer \& Fleet Management o contra los padrones web de SUNAT, validando la condición de contribuyente habido antes de la emisión del comprobante. Implementa el puerto CustomerFiscalValidationAclService bajo el subpaquete infrastructure.external.acl.crm. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Pasarela Externa:} InvoicingOutboxMessageRelayAdapter \quad (\textit{Categoría:} Adaptador de Mensajería Outbox)} \\*
\hline
\textbf{Tecnología Subyacente} & PostgreSQL 16 con Serialización JSONB vía Jackson ObjectMapper \\*
\hline
\textbf{Responsabilidad} & Persiste eventos de dominio en la tabla outbox\_messages dentro de la misma transacción relacional de base de datos donde se almacena el comprobante o cobro. Garantiza semántica de publicación confiable con entrega al menos una vez hacia intermediarios de mensajería Apache Kafka o RabbitMQ mediante Debezium CDC, eliminando transacciones distribuidas 2PC. Implementa el despachador de eventos bajo el subpaquete infrastructure.external.messaging.outbox. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Pasarela Externa:} Open\allowbreak Pdf\allowbreak Cash\allowbreak Flow\allowbreak Report\allowbreak Adapter \quad (\textit{Categoría:} Adaptador de Infraestructura Externa)} \\*
\hline
\textbf{Tecnología Subyacente} & OpenPDF 2.0.3, Thymeleaf 3.1 \\*
\hline
\textbf{Responsabilidad} & Renderizado binario de informes vectoriales en formato PDF para estados de cuenta de flujo de caja y arqueos de tesorería del taller. Procesa plantillas XHTML tipográficas con Thymeleaf y las compila en flujos binarios PDF con membrete institucional, balance consolidado y detalle de movimientos. Implementa el puerto CashFlowPdfGeneratorPort bajo el subpaquete infrastructure.external.reporting.openpdf. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Adaptadores de integración configurados bajo los subpaquetes modulares tax.nubefact, cloud.firebase, mail.resend, acl.crm, messaging.outbox y reporting.openpdf dentro de infrastructure.external.

En primer término, el determinismo fiscal y la erradicación de condiciones de carrera en la reserva correlativa mediante bloqueo pesimista en base de datos constituyen la salvaguarda de cumplimiento normativo del taller automotriz. La ejecución de consultas bloqueantes sobre el registro de serie en PostgreSQL garantiza que cada cajero u operador de servicio obtenga una numeración estrictamente secuencial y libre de huecos o duplicidades, satisfaciendo las exigencias legales del reglamento de comprobantes de pago sin degradar el rendimiento global del sistema gracias a la brevedad del ciclo de transacción.

En segundo término, la resiliencia perimetral y la tolerancia a fallos telemáticos en la comunicación con proveedores de servicios electrónicos blindan la continuidad operativa del negocio mecánico. La implementación de circuit breakers, políticas de reintentos progresivos con retroceso exponencial y persistencia de estados contingentes en base de datos local aseguran que las fallas de conectividad hacia el proveedor no interrumpan el cobro ni la entrega del vehículo al cliente, permitiendo la regularización asíncrona de los comprobantes ante la entidad tributaria dentro de los plazos legales establecidos.

Por último, el desacoplamiento transaccional y la garantía de entrega de eventos mediante el Transactional Outbox Pattern consolidan la soberanía modular de la plataforma Atelier. Al insertar atómicamente los eventos de dominio en la tabla de mensajería dentro del mismo límite de transacción relacional donde se almacena el comprobante o cobro, el sistema elimina la necesidad de protocolos de compromiso en dos fases, garantizando que los módulos de Workshop Operations, Inventory y Human Resources reciban notificaciones fidedignas para la liquidación de órdenes, cuadres de inventario y balances de flujo de caja sin riesgo de inconsistencias distribuidas.

#### 2.6.7.5. Bounded Context Software Architecture Component Level Diagrams

En esta sección se presenta la descomposición arquitectónica interna del contenedor central **API Application** en relación con el Bounded Context **Invoicing & Compliance** (paquete canónico com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing), dando estricto cumplimiento al Nivel 3 del Modelo C4.

Dentro de la arquitectura de monolito modular de Atelier Platform, el Bounded Context Invoicing & Compliance opera como el núcleo de soberanía tributaria, emisión de comprobantes electrónicos bajo la normativa peruana SUNAT UBL 2.1, recaudación de amortizaciones financieras y consolidación analítica del flujo de caja operativo del taller. Su diseño táctico garantiza la inmutabilidad de los registros contables y aísla la lógica de negocio de las contingencias de comunicación con los servicios de certificación digital.

Todos los controladores perimetrales, servicios de aplicación de comando y consulta, motores matemáticos de liquidación tributaria, repositorios relacionales con bloqueo pesimista y adaptadores de mensajería asíncrona se articulan armónicamente para asegurar una experiencia transaccional consistente tanto para el personal administrativo como para los asesores de servicio en mostrador y bahía.

En la @tbl:invoicing-c4-components se presenta el catálogo estructurado de los siete componentes de software constitutivos del Bounded Context Invoicing & Compliance dentro del contenedor central de la aplicación.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.5cm} | >{\raggedright\arraybackslash}p{10.9cm} |}
\caption{Catálogo de Componentes de Arquitectura de Software del Bounded Context Invoicing \& Compliance} \label{tbl:invoicing-c4-components} \\
\hline
\thfirst{Aspecto Técnico} & \thcell{Especificación de Arquitectura} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto Técnico} & \thcell{Especificación de Arquitectura} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Invoicing REST Controllers \& Resource Assemblers} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring MVC, SpringDoc OpenAPI, Jakarta Validation, Spring HATEOAS \\*
\hline
\textbf{Responsabilidad} & Expone endpoints REST perimetrales para la emisión de facturas y boletas, registro de abonos y amortizaciones financieras, anulación formal de comprobantes y configuración de series correlativas. Valida contratos de entrada DTO, intercepta excepciones de negocio y proyecta modelos de respuesta hipermedia estructurados. \\*
\hline
\textbf{Relaciones} & Invocado por WebApp y Mobile Workshop mediante peticiones HTTPS seguras. Despacha comandos transaccionales y consultas paginadas hacia los servicios de aplicación CQRS. Emplea ensambladores de recursos REST para transformar entidades en DTOs. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Invoicing CQRS Application Services} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring Service, Transactional, CQRS, Interfaces Funcionales \\*
\hline
\textbf{Responsabilidad} & Orquesta los casos de uso de emisión tributaria, desglose porcentual de IGV, anulación de comprobantes, recaudación de pagos y consolidación analítica del estado de flujo de caja del taller bajo transacciones ACID, canalizando respuestas controladas mediante tipos Result. \\*
\hline
\textbf{Relaciones} & Implementa puertos de entrada de comando y consulta. Invoca reglas de validación en el modelo de dominio. Delega la persistencia relacional y el bloqueo pesimista en repositorios JPA. Coordina con pasarelas externas para despacho fiscal a Nubefact y notificaciones por correo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Invoicing Event Handlers \& Transactional Dispatcher} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring Events, TransactionalEventListener, Outbox Pattern \\*
\hline
\textbf{Responsabilidad} & Captura eventos de dominio atómicos y señales de finalización de órdenes de trabajo desde Workshop Operations, persistiendo cargas útiles serializadas en la tabla invoicing\_outbox\_events dentro de la misma transacción de base de datos para entrega garantizada al menos una vez hacia consumidores asíncronos. \\*
\hline
\textbf{Relaciones} & Escucha eventos de dominio emitidos por los servicios de aplicación de facturación. Persiste registros en la tabla invoicing\_outbox\_events mediante adaptadores de infraestructura. Notifica a consumidores de eventos en Workshop Operations, CRM y contabilidad general. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Invoicing Domain Model \& Peruvian Tax Calculation Engines} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Java 24 puro, Domain Model, Records, Inmutabilidad \\*
\hline
\textbf{Responsabilidad} & Encapsula las invariantes de negocio tributarias, las raíces de agregado ElectronicVoucher, VoucherPayment y SeriesConfiguration, el motor de cálculo fiscal de base imponible e IGV al 18\% con redondeo Half-Even y la validación formal de identificadores RUC bajo el algoritmo Módulo 11 y DNI. \\*
\hline
\textbf{Relaciones} & Contiene las raíces de agregado y entidades dependientes VoucherLine. Ejecuta reglas tributarias e invariantes en PeruvianTaxCalculationEngine y VoucherValidationService. Emite eventos de dominio inmutables hacia el contexto de aplicación. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Invoicing Persistence Repositories \& JPA Adapters} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Jakarta Persistence 3.1, Spring Data JPA, Hibernate ORM, PostgreSQL 16, LockModeType \\*
\hline
\textbf{Responsabilidad} & Materializa los puertos de repositorio del dominio mediante adaptadores JPA, gestionando el bloqueo pesimista en base de datos para la reserva atómica de correlativos sin carreras, el mapeo bidireccional de entidades relacionales y el despacho transaccional en invoicing\_outbox\_events. \\*
\hline
\textbf{Relaciones} & Realiza los contratos de repositorio ElectronicVoucherRepository, VoucherPaymentRepository y SeriesConfigurationRepository. Lee y escribe en las tablas electronic\_vouchers, voucher\_lines, voucher\_payments, sunat\_series\_configurations y invoicing\_outbox\_events. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Inbound ACL \& Invoicing Open Host Facade} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring Service, In-Memory ACL, Published Language \\*
\hline
\textbf{Responsabilidad} & Publica una fachada Open Host Service en memoria que permite al Bounded Context Workshop Operations solicitar la liquidación fiscal y emisión de comprobantes para órdenes de servicio concluidas, traduciendo modelos foráneos a contratos canónicos sin acoplamiento interno. \\*
\hline
\textbf{Relaciones} & Invocado por Workshop Operations para liquidar intervenciones mecánicas. Traduce las líneas de mano de obra y repuestos desde el lenguaje foráneo hacia comandos de facturación. Delega la ejecución en los servicios de aplicación CQRS. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Invoicing External Gateways \& Fiscal Cloud Integration} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring WebClient, Resilience4j, Resend Cloud API, OpenPDF 2.0.3, Thymeleaf 3.1, Caffeine Cache \\*
\hline
\textbf{Responsabilidad} & Conecta con la API RESTful JSON V1 del PSE homologado Nubefact para generación y firma digital de comprobantes UBL 2.1, despacha correos transaccionales con PDF y XML adjuntos vía Resend, genera reportes de flujo de caja y arqueos de tesorería mediante el adaptador OpenPdfCashFlowReportAdapter con OpenPDF y Thymeleaf, y consulta datos fiscales de clientes en CRM o SUNAT. \\*
\hline
\textbf{Relaciones} & Invocado por servicios de aplicación. Conecta vía HTTPS con la API de Nubefact y con Resend. Integra el adaptador OpenPdfCashFlowReportAdapter para exportación documental y consulta en memoria las fachadas de Customer \& Fleet Management, Inventory \& Supply Chain y Human Resources para el estado de flujo de caja. \\
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al contenedor API Application en com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.

En la @fig:c4-component-invoicing se ilustra el diagrama C4 de componentes para el Bounded Context Invoicing & Compliance, detallando las interacciones entre los componentes internos del módulo, los clientes perimetrales, los bounded contexts adyacentes de la plataforma y los servicios de infraestructura externa de certificación fiscal y almacenamiento.

![Diagrama de Componentes C4 (Nivel 3) para el Bounded Context Invoicing & Compliance en API Application](report/assets/c4-diagrams/component-level-diagram-invoicing.png){#fig:c4-component-invoicing}

*Nota.* Elaboración propia en base a la arquitectura táctica del backend y el estándar C4 Model.

**Dinámica de Interacción y Flujos Operativos del Bounded Context Invoicing & Compliance**

Para formalizar la colaboración sincronizada entre los componentes internos del módulo de facturación y los sistemas externos durante las operaciones diarias del taller mecánico, se analizan a continuación los tres ciclos operacionales más representativos de la solución:

- **Ciclo de Emisión Fiscal Electrónica y Despacho Telemático hacia el Proveedor Nubefact:**
  El proceso se desencadena cuando un usuario administrativo solicita la facturación de una orden culminada desde el portal web o cuando el módulo de **Workshop Operations** invoca la interfaz **Inbound ACL & Invoicing Open Host Facade Component** mediante el método *generateVoucherFromWorkOrder()*. La solicitud es recibida por el componente **Invoicing REST Controllers & Resource Assemblers**, el cual valida las restricciones sintácticas del contrato de entrada y delega la ejecución en **Invoicing CQRS Application Services** mediante el comando **IssueElectronicVoucherCommand**.

  El servicio de aplicación coordina la consulta de datos fiscales del receptor invocando a **Invoicing External Gateways & Fiscal Cloud Integration**, la cual se comunica en memoria con la fachada de **Customer & Fleet** para verificar la razón social, el número de documento y el domicilio fiscal registrado. Seguidamente, transfiere las partidas individuales de repuestos y mano de obra a **Invoicing Domain Model & Peruvian Tax Calculation Engines Component**, donde **PeruvianTaxCalculationEngine** determina la base imponible y el 18% del Impuesto General a las Ventas mediante redondeo simétrico Half-Even a dos decimales, al tiempo que **VoucherValidationService** audita el dígito verificador de RUC bajo Módulo 11.

  Una vez comprobadas las invariantes de dominio, el servicio de aplicación solicita la reserva del número correlativo a **Invoicing Persistence Repositories & JPA Adapters**, ejecutando un bloqueo pesimista de escritura sobre el registro de serie en PostgreSQL 16 para impedir carreras o duplicidades. La entidad **ElectronicVoucher** se almacena en la base de datos en estado emitido, tras lo cual la pasarela externa despacha la trama JSON V1 estructurada hacia la API de Nubefact mediante Spring WebClient protegido por Resilience4j. Finalmente, **Invoicing Event Handlers & Transactional Dispatcher** persiste el evento **ElectronicVoucherIssuedEvent** en la tabla **invoicing_outbox_events** para notificación asíncrona, mientras la pasarela transmite el comprobante en formato PDF y XML firmado al correo del cliente mediante Resend.

- **Ciclo de Amortización, Conciliación de Pagos y Liberación Vehicular en Taller:**
  Este flujo se origina en la bahía de entrega de vehículos o mostrador de atención cuando el conductor efectúa la amortización o cancelación de la deuda por los servicios prestados. El cajero ingresa los datos de recaudación a través de la aplicación móvil o web, especificando el monto amortizado, el medio formal de pago y el identificador de la transacción. El componente **Invoicing REST Controllers & Resource Assemblers** intercepta la petición, verifica los tipos de datos y despacha el comando **RegisterVoucherPaymentCommand** hacia **Invoicing CQRS Application Services**.

  El servicio de aplicación recupera la raíz de agregado **ElectronicVoucher** junto a sus pagos previos a través de **Invoicing Persistence Repositories & JPA Adapters**, invocando la operación de dominio *applyPayment()* en **Invoicing Domain Model & Peruvian Tax Calculation Engines Component**. La raíz de agregado evalúa la regla de solvencia contable, constatando que el acumulado de amortizaciones no sobrepase el total facturado del comprobante. Si el abono liquida la totalidad del saldo exigible, el comprobante transiciona al estado cancelado, mientras que abonos parciales mantienen la obligación en estado pendiente reflejando el saldo deudor remanente.

  El adaptador de persistencia almacena el nuevo registro en la tabla relacional **voucher_payments** y consolida la actualización del comprobante en **electronic_vouchers**. Inmediatamente después, **Invoicing Event Handlers & Transactional Dispatcher** captura el suceso e inserta el evento de integración **VoucherPaymentAppliedEvent** en **invoicing_outbox_events** dentro de la misma transacción ACID. Al alcanzarse la cancelación integral de la deuda, el componente **Inbound ACL & Invoicing Open Host Facade Component** notifica de forma sincrónica a **Workshop Operations** la liberación financiera de la orden de servicio, habilitando la generación del pase de salida vehicular para la entrega física de la unidad al propietario.

- **Ciclo de Consolidación Multimodular del Estado de Flujo de Caja Operativo:**
  Para ejercer la gobernanza financiera del taller automotriz, el gerente administrativo solicita el arqueo consolidado de ingresos y egresos para un intervalo cronológico específico desde la interfaz analítica web. La petición arriba a **Invoicing REST Controllers & Resource Assemblers**, que valida los parámetros temporales y despacha la consulta **GetOperationalCashFlowQuery** hacia **Invoicing CQRS Application Services**.

  El servicio de aplicación orquesta una consulta federada respetando los límites de contexto mediante **Invoicing External Gateways & Fiscal Cloud Integration**. En primer término, recupera de **Invoicing Persistence Repositories & JPA Adapters** la totalidad de cobros reales registrados en **voucher_payments** durante las fechas solicitadas, desglosándolos por canal de pago. En segundo término, consulta en memoria la fachada de **Inventory & Supply Chain** para consolidar los desembolsos correspondientes a órdenes de compra de repuestos y lubricantes recibidas físicamente. En tercer término, invoca la fachada de **Human Resources** para cuantificar las erogaciones por planillas laborales y comisiones de mecánicos efectivamente liquidadas.

  La totalidad de registros monetarios es trasladada a **Invoicing Domain Model & Peruvian Tax Calculation Engines Component**, donde el motor especializado **CashFlowAggregationEngine** totaliza los ingresos brutos, cuantifica la estructura de costos y deduce el saldo neto de tesorería del taller. El servicio de aplicación estructura la respuesta en un recurso DTO inmutable con enlaces HATEOAS y metadatos de auditoría, retornando la proyección analítica a la aplicación web para su renderizado visual en tablas y gráficas ejecutivas o su descarga documental en formato PDF formal mediante el adaptador OpenPdfCashFlowReportAdapter.

En primer término, la alta cohesión de las responsabilidades funcionales y el estricto desacoplamiento modular alcanzados mediante el principio de inversión de dependencias permiten que el motor tributario peruano opere como un núcleo de cálculo puro libre de bibliotecas de infraestructura. Dicha segregación formaliza un modelo donde las variaciones normativas de la autoridad fiscal o las adaptaciones de esquemas tributarios se resuelven de forma autocontenida en la capa de dominio, garantizando que los módulos operativos de taller, inventario y recursos humanos permanezcan inmunes ante alteraciones en las reglas impositivas de comprobantes.

En segundo término, la implementación del Transactional Outbox Pattern en el componente de despacho de eventos garantiza la consistencia eventual y la entrega al menos una vez de los sucesos de facturación y cobro sin recurrir a protocolos distribuidos de dos fases. Al persistir los eventos de integración dentro del mismo límite de transacción relacional en que se asienta el comprobante o pago, se erradican las discrepancias contables entre el libro fiscal de facturación y el estado de cierre de las órdenes de trabajo en taller, manteniendo la integridad del sistema ante eventuales interrupciones telemáticas del servidor de aplicaciones.

Por último, el blindaje perimetral conferido por las pasarelas externas y la gestión asíncrona de contingencias aseguran la soberanía fiscal y la continuidad ininterrumpida de las operaciones del taller mecánico. La adopción de patrones de tolerancia a fallos, circuit breakers y almacenamiento de estados contingentes de reintento frente al proveedor de servicios electrónicos evita que las caídas de conectividad hacia la entidad tributaria paralicen la emisión de comprobantes o la recaudación en mostrador, permitiendo regularizar telemáticamente las constancias de recepción dentro de los plazos legales sin perturbar el flujo diario de atención automotriz.

#### 2.6.7.6. Bounded Context Software Architecture Code Level Diagrams

En esta sección se desarrolla la especificación técnica de menor nivel de abstracción para la arquitectura de software del Bounded Context Invoicing & Compliance, trasladando los modelos conceptuales y las responsabilidades tácticas hacia contratos estáticos de código ejecutable. Mediante esta formalización, se asegura que las reglas tributarias de la legislación peruana, los contratos de facturación electrónica bajo el estándar UBL 2.1 y las restricciones de consistencia transaccional se materialicen con rigurosa seguridad de tipos y determinismo computacional.

Esta perspectiva de diseño abarca dos representaciones arquitectónicas complementarias: el Diagrama de Clases de la Capa de Dominio, que modela en memoria las entidades maestras, raíces de agregado, objetos de valor inmutables, motores algorítmicos de cálculo de impuestos y puertos de persistencia, y el Diagrama de Base de Datos, que formaliza el esquema físico relacional en PostgreSQL 16 con discriminadores de aislamiento multi-inquilino, llaves foráneas y mecanismos de concurrencia optimista.

##### 2.6.7.6.1. *Bounded Context Domain Layer Class Diagrams*

El modelado estático de la Capa de Dominio del Bounded Context Invoicing & Compliance establece las estructuras operativas que gobiernan la emisión de comprobantes de pago electrónicos, la amortización de cuentas por cobrar y el control de correlatividad fiscal en las sedes del taller. Su diseño táctico prioriza la pureza algorítmica sin dependencias de frameworks tecnológicos, erradica la obsesión por tipos primitivos mediante identificadores fuertemente tipados y garantiza la inmutabilidad de los libros contables ante la administración tributaria.

En la @fig:class-diagram-invoicing se expone el Diagrama de Clases UML detallado para la Capa de Dominio de Invoicing & Compliance, diseñado conforme a la notación formal UML y compilado mediante la herramienta PlantUML bajo el enfoque de Diagram-as-Code.

![Diagrama de Clases UML de la Capa de Dominio para el Bounded Context Invoicing & Compliance](report/assets/class-diagrams/class-diagram-invoicing.png){#fig:class-diagram-invoicing}

*Nota.* Elaboración propia en base al diseño táctico de dominio y el estándar UML en PlantUML.

La organización interna del modelo estático se estructura en ocho paquetes cohesivos que encapsulan las responsabilidades del dominio fiscal:

- **Raíces de Agregado (invoicing.domain.model.aggregates):** Gobierna las entidades maestras que delimitan las fronteras de consistencia transaccional: **ElectronicVoucher** para el ciclo de vida, tributación y recaudación del comprobante de pago, **SeriesConfiguration** para la reserva atómica y correlatividad secuencial de series autorizadas por sede, y **VoucherPayment** para la amortización y conciliación multimoneda de caja. Todas las raíces extienden de **AbstractDomainAggregateRoot<T>**.
- **Entidades Internas (invoicing.domain.model.entities):** Modela las partes dependientes subordinadas al ciclo del comprobante: **VoucherLine** para la especificación detallada de bienes o servicios atendidos en taller, desagregando base imponible, alícuota e impuesto liquidado.
- **Identificadores Fuertemente Tipados (invoicing.domain.model.ids):** Implementa el contrato **TypedId<UUID>** mediante registros inmutables (**VoucherId**, **VoucherLineId**, **SeriesConfigurationId**, **PaymentId**), asociando identidades transversales del Shared Kernel (**TenantId**, **BranchId**, **CustomerId**, **WorkOrderId**).
- **Objetos de Valor Fiscales y Financieros (invoicing.domain.model.valueobjects):** Encapsula estructuras inmutables con validación de invariantes: **VoucherSerie** para el formato alfanumérico reglamentario, **VoucherNumber** para el correlativo positivo, **TaxCalculation** para la liquidación de subtotal e IGV, **CustomerFiscalInfo** para la identidad tributaria receptora, **DigitalReceiptUrls** para las constancias telemáticas seguras, **SunatResponse** para las respuestas fiscales y **VoidedInfo** para los motivos de anulación, enlazando tipos analíticos y monetarios (**CashFlowMovement**, **CashFlowSummary**, **Money**, **Currency**, **Quantity**, **TaxId**).
- **Enumeraciones de Dominio (invoicing.domain.model.enums):** Normaliza el vocabulario operativo y tributario (**VoucherType**, **VoucherStatus**, **PaymentMethod**, **PaymentStatus**, **CreditNoteReason**, **VoucherItemType**, **DocumentType**).
- **Servicios de Dominio Tributario y Conciliación (invoicing.domain.services):** Provee motores de cálculo puro sin acoplamiento a infraestructura: **PeruvianTaxCalculationEngine** para la liquidación matemática del IGV al 18% con redondeo bancario Half-Even, **VoucherValidationService** para la verificación de RUC por módulo 11 y topes legales de boleta, **SeriesCorrelativeService** para la gobernanza de numeraciones consecutivas y **CashFlowAggregationEngine** para la consolidación de tesorería operativa.
- **Puertos de Persistencia (invoicing.domain.repositories):** Define los contratos abstractos de almacenamiento y consulta (**ElectronicVoucherRepository**, **SeriesConfigurationRepository**, **VoucherPaymentRepository**) desacoplados de motores relacionales.
- **Eventos de Dominio y Excepciones Semánticas (invoicing.domain.events e invoicing.domain.exceptions):** Formaliza mutaciones del estado contable para el Transactional Outbox (**ElectronicVoucherIssuedEvent**, **VoucherAcceptedBySunatEvent**, **VoucherVoidedEvent**) y jerarquiza excepciones no comprobadas derivadas de **DomainException** bajo la norma RFC 7807 (**InvalidTaxIdException**, **CorrelativeExhaustedException**, **VoucherImmutableException**).

En la @tbl:invoicing-domain-classes-members se detalla la especificación formal de atributos, firmas de métodos, modificadores de acceso y reglas de negocio para cada componente de la Capa de Dominio.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo exhaustivo de clases, miembros, ámbitos y relaciones de la Capa de Dominio del Bounded Context Invoicing \& Compliance} \label{tbl:invoicing-domain-classes-members} \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Electronic\allowbreak Voucher \quad (\textit{Aggregate Root})} \\*
\hline
Atributos y composición & Raíz de agregado principal de facturación electrónica. Custodia la validez fiscal y tributaria ante SUNAT bajo UBL 2.1, cálculo determinista de base imponible e IGV, vinculación con la orden de trabajo de MRO y colecciones internas inmutables de líneas de detalle y pagos. Generalización de \texttt{AbstractDomainAggregateRoot<\allowbreak VoucherId>\allowbreak }. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{VoucherId id} \newline - \texttt{TenantId tenantId} \newline - \texttt{BranchId branchId} \newline - \texttt{CustomerId customerId} \newline - \texttt{Optional<\allowbreak WorkOrderId>\allowbreak  workOrderId} \newline - \texttt{VoucherType voucherType} \newline - \texttt{VoucherSerie serie} \newline - \texttt{VoucherNumber number} \newline - \texttt{TaxCalculation taxCalculation} \newline - \texttt{Currency currency} \newline - \texttt{VoucherStatus status} \newline - \texttt{CustomerFiscalInfo customerFiscalInfo} \newline - \texttt{DigitalReceiptUrls digitalReceiptUrls} \newline - \texttt{Optional<\allowbreak SunatResponse>\allowbreak  sunatResponse} \newline - \texttt{Optional<\allowbreak VoidedInfo>\allowbreak  voidedInfo} \newline - \texttt{List<\allowbreak VoucherLine>\allowbreak  lines} \newline - \texttt{List<\allowbreak VoucherPayment>\allowbreak  payments} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Factoría y emisión & Invariantes: estado inicial ISSUED tras validación exitosa. Facturas (tipo 01) exigen RUC de 11 dígitos válido con razón social y domicilio fiscal. Boletas (tipo 03) superiores a S/ 700.00 PEN exigen identificación del cliente. Cuadre aritmético estricto de base imponible e IGV con el importe total facturado. Emite Electronic\allowbreak Voucher\allowbreak Issued\allowbreak Event. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Electronic\allowbreak Voucher issue(TenantId,\allowbreak  BranchId,\allowbreak  CustomerId,\allowbreak  Optional<\allowbreak WorkOrderId>\allowbreak ,\allowbreak  VoucherType,\allowbreak  VoucherSerie,\allowbreak  VoucherNumber,\allowbreak  CustomerFiscalInfo,\allowbreak  Currency,\allowbreak  List<\allowbreak VoucherLine>\allowbreak )} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Transición SUNAT y anulación & Invariantes: comprobantes aceptados por SUNAT (ACCEPTED\_SUNAT) son legalmente inmutables y no admiten alteración ni borrado físico, requiriendo Notas de Crédito para correcciones contables. La anulación formal (VOIDED) exige motivo fundamentado y marca de tiempo en UTC. Emite eventos de fiscalización y anulación. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{void markAcceptedBySunat(String,\allowbreak  String,\allowbreak  DigitalReceiptUrls)} \newline - \texttt{void markRejectedBySunat(String,\allowbreak  String)} \newline - \texttt{void voidVoucher(String,\allowbreak  Instant)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Liquidación y saldos & Invariantes: el monto de amortización debe ser positivo. La sumatoria de pagos completados no puede sobrepasar el importe total del comprobante. Evalúa cancelación total y calcula saldo pendiente en tiempo real. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{VoucherPayment recordPayment(PaymentId,\allowbreak  Money,\allowbreak  PaymentMethod,\allowbreak  String)} \newline - \texttt{boolean isFullyPaid()} \newline - \texttt{Money getPendingBalance()} \newline - \texttt{VoucherId id()} \newline - \texttt{VoucherStatus status()} \newline - \texttt{TaxCalculation taxCalculation()} \newline - \texttt{List<\allowbreak VoucherLine>\allowbreak  lines()} \newline - \texttt{List<\allowbreak VoucherPayment>\allowbreak  payments()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Series\allowbreak Configuration \quad (\textit{Aggregate Root})} \\*
\hline
Atributos y numeración & Raíz de agregado que custodia las series alfanuméricas autorizadas por SUNAT y el control correlativo estricto por sede física y tipo de documento fiscal. Generalización de \texttt{AbstractDomainAggregateRoot<\allowbreak SeriesConfigurationId>\allowbreak }. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{SeriesConfigurationId id} \newline - \texttt{TenantId tenantId} \newline - \texttt{BranchId branchId} \newline - \texttt{VoucherType voucherType} \newline - \texttt{VoucherSerie serie} \newline - \texttt{int currentCorrelative} \newline - \texttt{boolean isActive} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Factoría y correlativo & Invariantes: serie alfanumérica de cuatro caracteres conforme a normativa SUNAT. Correlativo inicial no negativo. Incremento atómico estrictamente secuencial sin saltos ni duplicidades. Solo series activas pueden expedir números correlativos. Emite Series\allowbreak Configuration\allowbreak Created\allowbreak Event y Series\allowbreak Correlative\allowbreak Incremented\allowbreak Event. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{SeriesConfiguration create(TenantId,\allowbreak  BranchId,\allowbreak  VoucherType,\allowbreak  VoucherSerie,\allowbreak  int)} \newline - \texttt{VoucherNumber nextCorrelative()} \newline - \texttt{void deactivate()} \newline - \texttt{void activate()} \newline - \texttt{SeriesConfigurationId id()} \newline - \texttt{VoucherSerie serie()} \newline - \texttt{int currentCorrelative()} \newline - \texttt{boolean isActive()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Voucher\allowbreak Payment \quad (\textit{Aggregate Root})} \\*
\hline
Atributos de pago y canal & Raíz de agregado que formaliza la liquidación financiera o abono de caja asociado a un comprobante fiscal. Registra el canal de cobro, referencia de transacción bancaria o POS y marca temporal exacta del ingreso de fondos. Generalización de \texttt{AbstractDomainAggregateRoot<\allowbreak PaymentId>\allowbreak }. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{PaymentId id} \newline - \texttt{VoucherId voucherId} \newline - \texttt{TenantId tenantId} \newline - \texttt{BranchId branchId} \newline - \texttt{Money amount} \newline - \texttt{PaymentMethod paymentMethod} \newline - \texttt{String transactionReference} \newline - \texttt{PaymentStatus status} \newline - \texttt{Instant paidAt} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Abono y ciclo financiero & Invariantes: importe monetario estrictamente mayor a cero. Operaciones no monetarias en efectivo requieren referencia de transacción no vacía para conciliación y arqueo de caja. Transiciones controladas hacia COMPLETED o REFUNDED. Emite Voucher\allowbreak Payment\allowbreak Registered\allowbreak Event. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{VoucherPayment register(VoucherId,\allowbreak  TenantId,\allowbreak  BranchId,\allowbreak  Money,\allowbreak  PaymentMethod,\allowbreak  String)} \newline - \texttt{void markCompleted()} \newline - \texttt{void refund()} \newline - \texttt{PaymentId id()} \newline - \texttt{Money amount()} \newline - \texttt{PaymentStatus status()} \newline - \texttt{Instant paidAt()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Voucher\allowbreak Line \quad (\textit{Entity})} \\*
\hline
Atributos de partida fiscal & Entidad dependiente subordinada a ElectronicVoucher. Representa una partida individual facturada por concepto de servicio mecánico o repuesto de almacén, preservando la desagregación de valor venta unitario e impuesto general a las ventas. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{VoucherLineId id} \newline - \texttt{VoucherId voucherId} \newline - \texttt{Optional<\allowbreak UUID>\allowbreak  itemId} \newline - \texttt{VoucherItemType itemType} \newline - \texttt{String description} \newline - \texttt{Quantity quantity} \newline - \texttt{Money unitValue} \newline - \texttt{Money unitPrice} \newline - \texttt{Money igvAmount} \newline - \texttt{Money totalLine} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Factoría y totalización & Invariantes: cantidad estrictamente positiva. Descripción no vacía. Coherencia matemática entre valor unitario sin IGV y precio unitario gravado. El total de línea es igual al producto de cantidad por precio unitario. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{VoucherLine create(VoucherId,\allowbreak  Optional<\allowbreak UUID>\allowbreak ,\allowbreak  VoucherItemType,\allowbreak  String,\allowbreak  Quantity,\allowbreak  Money,\allowbreak  Money,\allowbreak  Money)} \newline - \texttt{Money calculateLineTotal()} \newline - \texttt{VoucherLineId id()} \newline - \texttt{VoucherItemType itemType()} \newline - \texttt{Quantity quantity()} \newline - \texttt{Money totalLine()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Peruvian\allowbreak Tax\allowbreak Calculation\allowbreak Engine \quad (\textit{Domain Service})} \\*
\hline
Constantes tributarias & Servicio de dominio puro para liquidaciones tributarias conforme a la ley peruana. Define la alícuota del Impuesto General a las Ventas (18\%) y factores de segregación sin estado persistente. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{BigDecimal IGV\_RATE = 0.18} \newline - \texttt{BigDecimal ONE\_PLUS\_IGV = 1.18} \\*
\hline
\textbf{Ámbito} & Privado / Constante \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Desglose de base imponible e IGV & Invariantes: divide el precio bruto entre 1.18 para obtener la base imponible y calcula el IGV como la diferencia exacta. Aplica redondeo bancario Half-Even a dos decimales, garantizando cuadre sin discrepancias de céntimos. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{TaxCalculation calculateFromGrossTotal(Money)} \newline - \texttt{Money extractUnitValue(Money)} \newline - \texttt{VoucherLine calculateLine(Quantity,\allowbreak  Money)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Voucher\allowbreak Validation\allowbreak Service \quad (\textit{Domain Service})} \\*
\hline
Factores y coeficientes & Servicio de dominio que implementa algoritmos de validación fiscal exigidos por SUNAT. Resguarda factores de ponderación para la comprobación del dígito verificador en documentos de identidad tributaria. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{int[] RUC\_WEIGHTS = [5, 4, 3, 2, 7, 6, 5, 4, 3, 2]} \\*
\hline
\textbf{Ámbito} & Privado / Constante \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Verificación algorítmica & Invariantes: valida que el RUC conste de 11 dígitos y comience con 10, 15, 17 o 20, con dígito verificador ponderado bajo módulo 11. Valida límite de boletas mayores a S/ 700.00 PEN y coherencia de notas de crédito vinculadas. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{boolean validateRuc(String)} \newline - \texttt{void validateBoletaLimit(Money,\allowbreak  DocumentType)} \newline - \texttt{void validateCreditNoteReference(Electronic\allowbreak Voucher)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Series\allowbreak Correlative\allowbreak Service \quad (\textit{Domain Service})} \\*
\hline
Patrón de serie SUNAT & Servicio de dominio que valida la concordancia entre series alfanuméricas y tipos de comprobante según catálogo SUNAT, garantizando numeración correlativa estricta sin saltos ni desbordamientos. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Pattern SUNAT\_SERIE\_PATTERN} \\*
\hline
\textbf{Ámbito} & Privado / Constante \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Cómputo correlativo y prefijos & Invariantes: facturas demandan prefijo F, boletas prefijo B y notas de crédito prefijos FC o BC. Controla que el correlativo no exceda el límite numérico de ocho dígitos (99999999). \\*
\hline
\textbf{Firma o Tipo} & - \texttt{void validateSeriesFormat(VoucherSerie,\allowbreak  VoucherType)} \newline - \texttt{VoucherNumber computeNextCorrelative(int)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Cash\allowbreak Flow\allowbreak Aggregation\allowbreak Engine \quad (\textit{Domain Service})} \\*
\hline
Motor analítico financiero & Servicio de dominio financiero que consolida los flujos de caja operativos de las sedes físicas del taller, totalizando ingresos de pagos completados y deduciendo egresos por suministros y nómina. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Servicio de dominio analítico sin estado} \\*
\hline
\textbf{Ámbito} & Privado / Sin estado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Agregación de cobros y egresos & Invariantes: solo computa liquidaciones en estado COMPLETED. Desagrega totales por medio de pago y moneda, computando el saldo neto operativo del ejercicio. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{CashFlowSummary aggregateOperationalCashFlow(List<\allowbreak VoucherPayment>\allowbreak ,\allowbreak  List<\allowbreak Money>\allowbreak ,\allowbreak  List<\allowbreak Money>\allowbreak )} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Electronic\allowbreak Voucher\allowbreak Repository \quad (\textit{Repository Port})} \\*
\hline
Persistencia y consulta & Puerto de persistencia en dominio para comprobantes electrónicos. Ofrece operaciones desacopladas de almacenamiento, búsqueda por identificador tipado, localización por serie correlativa y consultas por orden de trabajo de MRO. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Electronic\allowbreak Voucher save(Electronic\allowbreak Voucher)} \newline - \texttt{Optional<\allowbreak Electronic\allowbreak Voucher>\allowbreak  findById(VoucherId)} \newline - \texttt{Optional<\allowbreak Electronic\allowbreak Voucher>\allowbreak  findByTenantIdAndSerieAndNumber(TenantId,\allowbreak  VoucherSerie,\allowbreak  VoucherNumber)} \newline - \texttt{List<\allowbreak Electronic\allowbreak Voucher>\allowbreak  findAllByTenantIdAndDateRange(TenantId,\allowbreak  LocalDate,\allowbreak  LocalDate)} \newline - \texttt{List<\allowbreak Electronic\allowbreak Voucher>\allowbreak  findAllByWorkOrderId(WorkOrderId)} \newline - \texttt{boolean existsByTenantIdAndSerieAndNumber(TenantId,\allowbreak  VoucherSerie,\allowbreak  VoucherNumber)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Series\allowbreak Configuration\allowbreak Repository \quad (\textit{Repository Port})} \\*
\hline
Configuración y bloqueo & Puerto de persistencia para el resguardo de series fiscales autorizadas. Incluye bloqueo pesimista en base de datos para garantizar la reserva atómica del número correlativo ante múltiples emisiones concurrentes. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{SeriesConfiguration save(SeriesConfiguration)} \newline - \texttt{Optional<\allowbreak SeriesConfiguration>\allowbreak  findById(SeriesConfigurationId)} \newline - \texttt{Optional<\allowbreak SeriesConfiguration>\allowbreak  findByBranchIdAndVoucherTypeAndActive(BranchId,\allowbreak  VoucherType)} \newline - \texttt{List<\allowbreak SeriesConfiguration>\allowbreak  findAllByBranchId(BranchId)} \newline - \texttt{SeriesConfiguration lockSeriesForNextNumber(SeriesConfigurationId)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Voucher\allowbreak Payment\allowbreak Repository \quad (\textit{Repository Port})} \\*
\hline
Persistencia de pagos & Puerto de persistencia para asientos de amortización y cobranza asociados a comprobantes electrónicos. Permite consultar recaudaciones por comprobante y cierres diarios de caja por sucursal. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{VoucherPayment save(VoucherPayment)} \newline - \texttt{Optional<\allowbreak VoucherPayment>\allowbreak  findById(PaymentId)} \newline - \texttt{List<\allowbreak VoucherPayment>\allowbreak  findAllByVoucherId(VoucherId)} \newline - \texttt{List<\allowbreak VoucherPayment>\allowbreak  findByBranchIdAndDateRange(BranchId,\allowbreak  Instant,\allowbreak  Instant)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Objetos de Valor e Identificadores Tipados} \\*
\hline
Identificadores tipados & Registros inmutables en Java que realizan \texttt{TypedId<\allowbreak UUID>\allowbreak }. Erradican la obsesión por primitivos y previenen intercambios accidentales de identificadores en tiempo de compilación. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{record VoucherId(UUID value)} \newline - \texttt{record VoucherLineId(UUID value)} \newline - \texttt{record SeriesConfigurationId(UUID value)} \newline - \texttt{record PaymentId(UUID value)} \newline - \texttt{static of(UUID)} \newline - \texttt{static generate()} \\*
\hline
\textbf{Ámbito} & Privado / Público \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Series y números fiscales & Objetos de valor inmutables. \textbf{VoucherSerie} valida formato alfanumérico de cuatro caracteres según SUNAT (\string^[FB][A-Z0-9]\{3\}\string$). \textbf{VoucherNumber} valida que el correlativo sea un entero estrictamente positivo. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{record VoucherSerie(String value)} \newline - \texttt{record VoucherNumber(int value)} \newline - \texttt{static of(String)} \newline - \texttt{static of(int)} \\*
\hline
\textbf{Ámbito} & Privado / Público \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Liquidación y receptor fiscal & Objetos de valor inmutables. \textbf{TaxCalculation} consolida base imponible, cuota de IGV (18\%), importe total y alícuota legal. \textbf{CustomerFiscalInfo} resguarda RUC o DNI validado, razón social, dirección fiscal y tipo de documento. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{record TaxCalculation(Money subtotal,\allowbreak  Money igvAmount,\allowbreak  Money totalAmount,\allowbreak  BigDecimal igvRate)} \newline - \texttt{record CustomerFiscalInfo(TaxId taxId,\allowbreak  String legalName,\allowbreak  String fiscalAddress,\allowbreak  DocumentType documentType)} \\*
\hline
\textbf{Ámbito} & Privado / Público \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Evidencia digital y anulación & Objetos de valor inmutables. \textbf{DigitalReceiptUrls} almacena enlaces web seguros HTTPS a los archivos PDF, XML firmado y constancia CDR. \textbf{SunatResponse} custodia código, glosa descriptiva y hash SHA-256. \textbf{VoidedInfo} preserva motivo y marca temporal de baja. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{record DigitalReceiptUrls(String pdfUrl,\allowbreak  String xmlUrl,\allowbreak  String cdrUrl)} \newline - \texttt{record SunatResponse(String responseCode,\allowbreak  String description,\allowbreak  String digitalSignatureHash)} \newline - \texttt{record VoidedInfo(String reason,\allowbreak  Instant voidedAt)} \\*
\hline
\textbf{Ámbito} & Privado / Público \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Flujo de caja y tesorería & Objetos de valor inmutables. \textbf{CashFlowMovement} formaliza cada movimiento financiero individual consolidado en el balance de taller. \textbf{CashFlowSummary} condensa el resumen analítico de ingresos operativos, compras de insumos, planillas laborales y saldo neto de tesorería. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{record CashFlowMovement(UUID transactionId,\allowbreak  Instant movementDate,\allowbreak  String type,\allowbreak  String category,\allowbreak  String concept,\allowbreak  String referenceNumber,\allowbreak  BigDecimal amount,\allowbreak  BigDecimal runningBalance)} \newline - \texttt{record CashFlowSummary(Money grossRevenue,\allowbreak  Money purchaseExpenses,\allowbreak  Money payrollExpenses,\allowbreak  Money netCashFlow)} \\*
\hline
\textbf{Ámbito} & Privado / Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Enumeraciones de Dominio} \\*
\hline
Tipos enumerados de dominio & Tipos enumerados de dominio que rigen la tipología de comprobantes según codificación oficial de SUNAT (\textbf{VoucherType}: FACTURA ``01'', BOLETA ``03'', NOTA\_CREDITO ``07'', NOTA\_DEBITO ``08''), el ciclo de vida fiscal (\textbf{VoucherStatus}: DRAFT, ISSUED, ACCEPTED\_SUNAT, REJECTED\_SUNAT, VOIDED), los medios de pago (\textbf{PaymentMethod}: CASH, CREDIT\_CARD, DEBIT\_CARD, BANK\_TRANSFER, YAPE, PLIN), el estado de cobranza (\textbf{PaymentStatus}: PENDING, COMPLETED, REFUNDED), los motivos reglamentarios de nota de crédito (\textbf{CreditNoteReason}: ANULACION\_DE\_LA\_OPERACION, ANULACION\_POR\_ERROR\_EN\_EL\_RUC, CORRECCION\_POR\_ERROR\_EN\_LA\_DESCRIPCION, DESCUENTO\_GLOBAL, DEVOLUCION\_TOTAL), el tipo de concepto facturado (\textbf{VoucherItemType}: PRODUCT, SERVICE) y el tipo de documento de identidad (\textbf{DocumentType}: RUC, DNI, CE, PASAPORTE). \\*
\hline
\textbf{Firma o Tipo} & - \texttt{VoucherType} \newline - \texttt{VoucherStatus} \newline - \texttt{PaymentMethod} \newline - \texttt{PaymentStatus} \newline - \texttt{CreditNoteReason} \newline - \texttt{VoucherItemType} \newline - \texttt{DocumentType} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Eventos de Dominio} \\*
\hline
Eventos de ciclo fiscal & Registros inmutables en Java que implementan el contrato transversal \texttt{DomainEvent}. Describen mutaciones significativas en el ciclo contable y fiscal para su almacenamiento atómico en el Transactional Outbox y propagación hacia otros bounded contexts del sistema. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Electronic\allowbreak Voucher\allowbreak IssuedEvent(VoucherId,\allowbreak  TenantId,\allowbreak  VoucherType,\allowbreak  VoucherSerie,\allowbreak  VoucherNumber,\allowbreak  Money,\allowbreak  Instant)} \newline - \texttt{Voucher\allowbreak Accepted\allowbreak BySunatEvent(VoucherId,\allowbreak  String,\allowbreak  DigitalReceiptUrls,\allowbreak  Instant)} \newline - \texttt{Voucher\allowbreak Rejected\allowbreak BySunatEvent(VoucherId,\allowbreak  String,\allowbreak  String,\allowbreak  Instant)} \newline - \texttt{Voucher\allowbreak VoidedEvent(VoucherId,\allowbreak  String,\allowbreak  Instant)} \newline - \texttt{Voucher\allowbreak Payment\allowbreak RegisteredEvent(PaymentId,\allowbreak  VoucherId,\allowbreak  Money,\allowbreak  PaymentMethod,\allowbreak  boolean)} \newline - \texttt{Series\allowbreak Configuration\allowbreak CreatedEvent(SeriesConfigurationId,\allowbreak  TenantId,\allowbreak  BranchId,\allowbreak  VoucherType,\allowbreak  VoucherSerie)} \newline - \texttt{Series\allowbreak Correlative\allowbreak IncrementedEvent(SeriesConfigurationId,\allowbreak  VoucherSerie,\allowbreak  int)} \newline - \texttt{Credit\allowbreak Note\allowbreak IssuedEvent(VoucherId,\allowbreak  VoucherId,\allowbreak  String,\allowbreak  Instant)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Jerarquía de Excepciones Semánticas} \\*
\hline
Excepciones RFC 7807 & Excepciones semánticas no comprobadas que extienden \texttt{DomainException}. Portan códigos canónicos normalizados bajo el estándar RFC 7807 para originar respuestas HTTP 4xx descriptivas ante violaciones de invariantes tributarias, inconsistencias de RUC o DNI, colisiones de correlativos, comprobantes inmutables y fallos de integración con la pasarela fiscal. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Invoicing\allowbreak DomainException} \newline - \texttt{Invalid\allowbreak TaxIdException} \newline - \texttt{Correlative\allowbreak ExhaustedException} \newline - \texttt{Voucher\allowbreak AlreadyPaidException} \newline - \texttt{Voucher\allowbreak ImmutableException} \newline - \texttt{Invalid\allowbreak VoucherAmountException} \newline - \texttt{Customer\allowbreak FiscalDataMissingException} \newline - \texttt{Series\allowbreak NotFoundException} \newline - \texttt{Voucher\allowbreak NotFoundException} \newline - \texttt{Sunat\allowbreak IntegrationException} \newline - \texttt{Credit\allowbreak NoteReferenceNotFoundException} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de miembros, modificadores de acceso, tipos de retorno y relaciones de la Capa de Dominio en com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak domain.

A partir del modelo estático ilustrado en la @fig:class-diagram-invoicing y desglosado en la @tbl:invoicing-domain-classes-members, se identifican tres fundamentos de ingeniería de software que respaldan la solidez y cumplimiento fiscal de la plataforma:

- **Determinismo Matemático y Redondeo Bancario Half-Even en Liquidación Tributaria:**
  El motor de dominio aísla el cálculo aritmético en **PeruvianTaxCalculationEngine**, desacoplando la determinación impositiva de los servicios de infraestructura. Para neutralizar el sesgo inflacionario derivado de acumulaciones decimales sucesivas en facturas con múltiples partidas de repuestos y mano de obra, el motor aplica estrictamente la política de redondeo a mitad par (*RoundingMode.HALF_EVEN*) a dos decimales tanto a nivel de línea en **VoucherLine** como en el acumulado global de **TaxCalculation**. Este procedimiento asegura un cuadre matemático perfecto entre la base imponible neta y el impuesto general a las ventas, mitigando discrepancias de céntimos que invalidarían el comprobante ante los validadores sintácticos de la administración tributaria.

- **Inmutabilidad Contable, Trazabilidad y Gobernanza de Correlativos sin Brechas:**
  El diseño impone que todo comprobante electrónico en estado aceptado por la entidad fiscal sea inmutable, prohibiendo modificaciones destructivas o eliminaciones físicas sobre el agregado **ElectronicVoucher**. Cualquier rectificación comercial, devolución de piezas o descuento posterior debe instrumentarse mediante la emisión de una nota de crédito vinculada que referencie al documento primario. Asimismo, la raíz de agregado **SeriesConfiguration** custodia la asignación atómica de números correlativos, coordinando reservas secuenciales que impiden la existencia de saltos de numeración o duplicidades en despachos paralelos de caja, salvaguardando la continuidad del libro de ventas del taller.

- **Aislamiento Multi-Inquilino y Erradicación de Primitive Obsession en Operaciones Fiscales:**
  La arquitectura erradica el intercambio erróneo de parámetros en tiempo de compilación mediante identificadores fuertemente tipados basados en registros inmutables de Java. La incorporación de **TenantId** y **BranchId** en las entidades transaccionales delimita con exactitud la pertenencia corporativa y física de cada comprobante, impidiendo la mezcla accidental de libros contables entre diferentes talleres adscritos a la plataforma. Adicionalmente, el objeto de valor **CustomerFiscalInfo** resguarda la validez de los datos del adquirente, aplicando el algoritmo de Módulo 11 sobre el número de RUC para garantizar legitimidad legal previo al asentamiento formal del pago en **VoucherPayment**.

##### 2.6.7.6.2. *Bounded Context Database Design Diagram*

El diseño de persistencia del Bounded Context Invoicing & Compliance materializa el modelo de dominio en un esquema físico relacional enfocado en garantizar la inmutabilidad de los libros contables, la exactitud en el cómputo impositivo y el estricto cumplimiento tributario ante la SUNAT. La persistencia se distribuye en dos componentes físicos complementarios: la base de datos central PostgreSQL 16 para el backend de la plataforma (**API Application**) y el motor relacional embebido SQLite 3 para la aplicación técnica móvil de taller (**Mobile Workshop**).

En la @fig:database-diagram-invoicing se presenta el Diagrama Entidad-Relación formal bajo notación Crow's Foot para la persistencia del Bounded Context Invoicing & Compliance en sus dos entornos operativos de despliegue: la base de datos central PostgreSQL 16 de la API de backend y el motor relacional local SQLite 3 de la aplicación técnica móvil de taller.

![Diagrama Entidad-Relación de Base de Datos para el Bounded Context Invoicing & Compliance (PostgreSQL 16 y SQLite 3)](report/assets/database-diagrams/database-diagram-invoicing.png){#fig:database-diagram-invoicing}

*Nota.* Elaboración propia en base al diseño físico de persistencia y el estándar PlantUML ERD.

- **Subsistema de Comprobantes Electrónicos y Partidas Fiscales:**
  Gobierna el ciclo de vida transaccional del comprobante y el desglose de conceptos facturados mediante las tablas **electronic_vouchers** y **voucher_lines**. La tabla **electronic_vouchers** preserva las cabeceras fiscales, importes acumulados, discriminadores de inquilino y sede, hashes de firma digital y enlaces a artefactos XML, CDR y PDF validados por la autoridad tributaria. A su vez, la tabla **voucher_lines** desglosa las partidas individuales de mano de obra y repuestos en una relación de composición estricta en cascada, garantizando exactitud matemática entre el subtotal, el impuesto calculado y el monto total de liquidación.

- **Subsistema de Pagos y Liquidaciones de Comprobante:**
  Administra la amortización económica y cobros percibidos a través de la tabla **voucher_payments**. Cada registro asocia el comprobante emitido con el monto cancelado, la divisa, el método de pago bancario o en efectivo y la referencia transaccional externa, asegurando que el estado del comprobante evolucione a pagado únicamente cuando la sumatoria de abonos cubra la totalidad de la deuda fiscal.

- **Subsistema de Gobernanza de Series y Asignación Atómica de Correlativos:**
  Custodia la legalidad de los correlativos tributarios mediante la tabla **sunat_series_configurations**. Esta estructura mantiene el contador secuencial por sede física, tipo de comprobante y serie alfanumérica, permitiendo que las operaciones concurrentes de facturación bloqueen y reserven números correlativos en una única transacción atómica, previniendo brechas de numeración o duplicidades sancionadas por la normativa tributaria.

- **Subsistema de Mensajería Transaccional Outbox y Consistencia Eventual:**
  Asegura la publicación confiable de eventos de dominio hacia brokers externos mediante la tabla **invoicing_outbox_events**. Implementando el patrón de diseño Transactional Outbox, las mutaciones sobre los comprobantes y la inserción del evento de dominio se ejecutan dentro del mismo límite transaccional en PostgreSQL, delegando a un despachador en segundo plano la entrega asíncrona hacia Kafka sin riesgo de pérdida de mensajes por caídas de red.

- **Persistencia Técnica Desconectada en SQLite 3 para Mobile Workshop:**
  Otorga resiliencia y autonomía operativa al personal de taller en zonas de patio o bahías sin cobertura celular mediante las tablas locales **local_voucher_status_cache** y **offline_payment_collections**. La tabla **local_voucher_status_cache** almacena una réplica de lectura del estado de facturación y saldo pendiente vinculado a cada orden de trabajo para autorizar la liberación física del vehículo, mientras que **offline_payment_collections** resguarda pagos percibidos fuera de línea con claves de idempotencia para su conciliación automática al restablecerse la conectividad.

A partir de la arquitectura relacional definida en el diagrama de persistencia, en la @tbl:invoicing-database-objects se cataloga la totalidad de las tablas y objetos físicos que conforman el modelo de datos, detallando el producto donde residen, sus atributos cardinales, restricciones de integridad, estrategias de indexación y su contribución al aislamiento de información.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.1cm} | >{\raggedright\arraybackslash}p{10.3cm} |}
\caption{Catálogo exhaustivo de tablas, objetos de base de datos, restricciones e índices físicos del Bounded Context Invoicing \& Compliance} \label{tbl:invoicing-database-objects} \\
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{electronic\allowbreak \_vouchers}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Cabecera inmutable de comprobantes de pago electrónicos con valor legal y tributario ante SUNAT (Facturas tipo 01, Boletas de Venta tipo 03, Notas de Crédito tipo 07 y Notas de Débito tipo 08). Custodia la base imponible desglosada, cuota fiscal de IGV del 18\%, importe total facturado, datos fiscales del receptor, trazabilidad con la orden de trabajo de MRO y metadatos de validación telemática UBL 2.1 (firma digital hash SHA-256 y constancias CDR, XML y PDF). Aislamiento multi-inquilino gobernado por el discriminador tenant\_id y la sucursal física emisora branch\_id. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID PK)}, \texttt{tenant\_id (UUID FK)}, \texttt{branch\_id (UUID FK)}, \texttt{customer\_id (UUID FK)}, \texttt{work\_order\_id (UUID FK)}, \texttt{voucher\_type (VARCHAR(10))}, \texttt{serie (VARCHAR(4))}, \texttt{number (INTEGER)}, \texttt{subtotal (NUMERIC(10,2))}, \texttt{igv\_amount (NUMERIC(10,2))}, \texttt{total\_amount (NUMERIC(10,2))}, \texttt{currency (VARCHAR(3))}, \texttt{status (VARCHAR(20))}, \texttt{customer\_tax\_id (VARCHAR(20))}, \texttt{customer\_legal\_name (VARCHAR(150))}, \texttt{customer\_fiscal\_address (VARCHAR(200))}, \texttt{customer\_document\_type (VARCHAR(10))}, \texttt{sunat\_pdf\_url (VARCHAR(255))}, \texttt{sunat\_xml\_url (VARCHAR(255))}, \texttt{sunat\_cdr\_url (VARCHAR(255))}, \texttt{digital\_signature\_hash (VARCHAR(100))}, \texttt{sunat\_response\_code (VARCHAR(10))}, \texttt{sunat\_description (VARCHAR(255))}, \texttt{voided\_reason (VARCHAR(255))}, \texttt{voided\_at (TIMESTAMPTZ)}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ)}, \texttt{version (BIGINT)}, \texttt{deleted\_at (TIMESTAMPTZ)}. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_\allowbreak electronic\_\allowbreak vouchers (id) \newline - FK: fk\_\allowbreak vouchers\_\allowbreak tenant\_\allowbreak id hacia tenants(id), fk\_\allowbreak vouchers\_\allowbreak branch\_\allowbreak id hacia branches(id), fk\_\allowbreak vouchers\_\allowbreak customer\_\allowbreak id hacia customers(id), fk\_\allowbreak vouchers\_\allowbreak work\_\allowbreak order\_\allowbreak id hacia work\_\allowbreak orders(id) con ON DELETE SET NULL \newline - UK: uk\_\allowbreak vouchers\_\allowbreak tenant\_\allowbreak serie\_\allowbreak num (tenant\_id, serie, number) \newline - CHECK: chk\_\allowbreak voucher\_\allowbreak type (voucher\_type IN ('01', '03', '07', '08')), chk\_\allowbreak voucher\_\allowbreak status (status IN ('DRAFT', 'ISSUED', 'ACCEPTED\_SUNAT', 'REJECTED\_SUNAT', 'VOIDED')), chk\_\allowbreak voucher\_\allowbreak subtotal (subtotal >= 0.00), chk\_\allowbreak voucher\_\allowbreak igv (igv\_amount >= 0.00), chk\_\allowbreak voucher\_\allowbreak total (total\_amount >= 0.00) \newline - Índices B-Tree: idx\_\allowbreak vouchers\_\allowbreak tenant\_\allowbreak lookup (tenant\_id, serie, number), idx\_\allowbreak vouchers\_\allowbreak branch\_\allowbreak date (branch\_id, created\_at), idx\_\allowbreak vouchers\_\allowbreak customer (customer\_id), idx\_\allowbreak vouchers\_\allowbreak work\_\allowbreak order (work\_order\_id), idx\_\allowbreak vouchers\_\allowbreak status (status) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{voucher\allowbreak \_lines}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Partidas analíticas o ítems detallados subordinados al comprobante electrónico de pago. Desglosa individualmente los servicios mecánicos de taller y repuestos automotrices despachados, registrando cantidad, valor unitario de venta sin impuestos, precio unitario con IGV, cuota tributaria resultante y total consolidado de línea. Integridad referencial con persistencia y eliminación en cascada vinculada al ciclo de vida del comprobante padre. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID PK)}, \texttt{voucher\_id (UUID FK)}, \texttt{item\_id (UUID FK)}, \texttt{item\_type (VARCHAR(20))}, \texttt{description (VARCHAR(200))}, \texttt{quantity (NUMERIC(10,2))}, \texttt{unit\_value (NUMERIC(10,2))}, \texttt{unit\_price (NUMERIC(10,2))}, \texttt{igv\_amount (NUMERIC(10,2))}, \texttt{total\_line (NUMERIC(10,2))}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ)}. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_\allowbreak voucher\_\allowbreak lines (id) \newline - FK: fk\_\allowbreak voucher\_\allowbreak lines\_\allowbreak voucher\_\allowbreak id hacia electronic\_\allowbreak vouchers(id) con ON DELETE CASCADE, fk\_\allowbreak voucher\_\allowbreak lines\_\allowbreak item\_\allowbreak id hacia inventory\_\allowbreak items(id) con ON DELETE SET NULL \newline - CHECK: chk\_\allowbreak line\_\allowbreak item\_\allowbreak type (item\_type IN ('PRODUCT', 'SERVICE')), chk\_\allowbreak line\_\allowbreak quantity (quantity > 0.00), chk\_\allowbreak line\_\allowbreak unit\_\allowbreak value (unit\_value >= 0.00), chk\_\allowbreak line\_\allowbreak unit\_\allowbreak price (unit\_price >= 0.00), chk\_\allowbreak line\_\allowbreak total (total\_line >= 0.00) \newline - Índices B-Tree: idx\_\allowbreak voucher\_\allowbreak lines\_\allowbreak voucher (voucher\_id), idx\_\allowbreak voucher\_\allowbreak lines\_\allowbreak item (item\_id) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{voucher\allowbreak \_payments}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Registro transaccional de abonos y amortizaciones financieras para la liquidación de comprobantes electrónicos y conciliación de arqueo de caja de taller. Discrimina los canales formales de cobro (efectivo, tarjetas bancarias, transferencias electrónicas y billeteras móviles Yape y Plin) y custodia la referencia de operación bancaria o POS. Aislamiento particionado por inquilino mediante tenant\_id y sucursal física branch\_id. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID PK)}, \texttt{voucher\_id (UUID FK)}, \texttt{tenant\_id (UUID FK)}, \texttt{branch\_id (UUID FK)}, \texttt{amount (NUMERIC(10,2))}, \texttt{currency (VARCHAR(3))}, \texttt{payment\_method (VARCHAR(30))}, \texttt{transaction\_reference (VARCHAR(100))}, \texttt{status (VARCHAR(20))}, \texttt{paid\_at (TIMESTAMPTZ)}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ)}, \texttt{version (BIGINT)}, \texttt{deleted\_at (TIMESTAMPTZ)}. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_\allowbreak voucher\_\allowbreak payments (id) \newline - FK: fk\_\allowbreak payments\_\allowbreak voucher\_\allowbreak id hacia electronic\_\allowbreak vouchers(id) con ON DELETE CASCADE, fk\_\allowbreak payments\_\allowbreak tenant\_\allowbreak id hacia tenants(id), fk\_\allowbreak payments\_\allowbreak branch\_\allowbreak id hacia branches(id) \newline - CHECK: chk\_\allowbreak payment\_\allowbreak amount (amount > 0.00), chk\_\allowbreak payment\_\allowbreak method (payment\_method IN ('CASH', 'CREDIT\_CARD', 'DEBIT\_CARD', 'BANK\_TRANSFER', 'DIGITAL\_WALLET\_YAPE', 'DIGITAL\_WALLET\_PLIN')), chk\_\allowbreak payment\_\allowbreak status (status IN ('PENDING', 'COMPLETED', 'REFUNDED')) \newline - Índices B-Tree: idx\_\allowbreak payments\_\allowbreak voucher (voucher\_id), idx\_\allowbreak payments\_\allowbreak branch\_\allowbreak date (branch\_id, paid\_at), idx\_\allowbreak payments\_\allowbreak tenant\_\allowbreak status (tenant\_id, status) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{sunat\allowbreak \_series\allowbreak \_configurations}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Catálogo maestro y motor de control de correlatividad fiscal obligatoria por sede física y tipo de comprobante legal. Garantiza la emisión monotónica, estrictamente creciente y libre de saltos numéricos mediante adquisición atómica con bloqueo pesimista en base de datos relacional (SELECT FOR UPDATE), erradicando colisiones concurrentes entre cajas. Aislamiento corporativo por tenant\_id. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID PK)}, \texttt{tenant\_id (UUID FK)}, \texttt{branch\_id (UUID FK)}, \texttt{voucher\_type (VARCHAR(10))}, \texttt{serie (VARCHAR(4))}, \texttt{current\_correlative (INTEGER)}, \texttt{is\_active (BOOLEAN)}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ)}, \texttt{version (BIGINT)}, \texttt{deleted\_at (TIMESTAMPTZ)}. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_\allowbreak sunat\_\allowbreak series\_\allowbreak configurations (id) \newline - FK: fk\_\allowbreak series\_\allowbreak tenant\_\allowbreak id hacia tenants(id), fk\_\allowbreak series\_\allowbreak branch\_\allowbreak id hacia branches(id) \newline - UK: uk\_\allowbreak series\_\allowbreak branch\_\allowbreak type\_\allowbreak serie (branch\_id, voucher\_type, serie) \newline - CHECK: chk\_\allowbreak series\_\allowbreak correlative (current\_correlative >= 0), chk\_\allowbreak series\_\allowbreak voucher\_\allowbreak type (voucher\_type IN ('01', '03', '07', '08')) \newline - Índices B-Tree: idx\_\allowbreak series\_\allowbreak branch\_\allowbreak active (branch\_id, voucher\_type, is\_active), idx\_\allowbreak series\_\allowbreak tenant (tenant\_id) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{invoicing\allowbreak \_outbox\allowbreak \_events}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Cola transaccional especializada bajo el patrón arquitectónico Transactional Outbox para la publicación confiable y asíncrona de eventos de dominio e integración hacia la pasarela fiscal externa Nubefact y módulos colindantes (MRO, CRM, Inventory y HR). Elimina la necesidad de transacciones distribuidas 2PC y asegura semántica de entrega At-Least-Once frente a contingencias temporales de red. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID PK)}, \texttt{aggregate\_type (VARCHAR(50))}, \texttt{aggregate\_id (UUID)}, \texttt{event\_type (VARCHAR(100))}, \texttt{payload (JSONB)}, \texttt{occurred\_on (TIMESTAMPTZ)}, \texttt{status (VARCHAR(20))}, \texttt{retry\_count (INTEGER)}, \texttt{last\_error (TEXT)}, \texttt{processed\_at (TIMESTAMPTZ)}, \texttt{created\_at (TIMESTAMPTZ)}. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_\allowbreak invoicing\_\allowbreak outbox\_\allowbreak events (id) \newline - CHECK: chk\_\allowbreak outbox\_\allowbreak status (status IN ('PENDING', 'PROCESSING', 'PUBLISHED', 'FAILED')), chk\_\allowbreak outbox\_\allowbreak retry\_\allowbreak count (retry\_count >= 0) \newline - Índices B-Tree: idx\_\allowbreak outbox\_\allowbreak poll parcial (status, occurred\_on) WHERE status IN ('PENDING', 'FAILED'), idx\_\allowbreak outbox\_\allowbreak aggregate (aggregate\_type, aggregate\_id) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{auditable\allowbreak \_abstract\allowbreak \_entity}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Superclase base y arquetipo técnico JPA (@MappedSuperclass) heredado por las entidades del backend de Invoicing \& Compliance. Provee identificador universal primario id, clave lógica foránea de particionamiento multi-inquilino tenant\_id, marcas de tiempo de auditoría inmutable, control de concurrencia optimista y soporte de borrado lógico (soft delete). \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{tenant\_id (UUID)}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ)}, \texttt{version (BIGINT)}, \texttt{deleted\_at (TIMESTAMPTZ)}. \\*
\hline
\textbf{Constraints e Índices} & - PK técnica: pk\_entity (id) \newline - FK lógica: tenant\_id referenciando a tenants(id) \newline - Bloqueo optimista: columna version administrada por Hibernate JPA (@Version) \newline - Filtro de exclusión: deleted\_at IS NULL para soporte de borrado lógico transversal. Superclase @MappedSuperclass JPA \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{local\allowbreak \_voucher\allowbreak \_status\allowbreak \_cache}} \\*
\hline
\textbf{Motor y Producto} & SQLite 3 (Mobile Workshop) \\*
\hline
\textbf{Propósito y Aislamiento} & Caché relacional local de solo lectura en el dispositivo móvil del operario de taller. Almacena una réplica sincronizada de los saldos pendientes, montos facturados y estados de pago de comprobantes por orden de trabajo para autorizar en tiempo real el pase de salida y liberación vehicular en foso o patio sin depender de conectividad telemática. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (TEXT PK)}, \texttt{work\_order\_id (TEXT)}, \texttt{voucher\_serie (TEXT)}, \texttt{voucher\_number (INTEGER)}, \texttt{voucher\_type (TEXT)}, \texttt{total\_amount (REAL)}, \texttt{pending\_balance (REAL)}, \texttt{status (TEXT)}, \texttt{pdf\_url (TEXT)}, \texttt{synced\_at (TEXT)}. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_\allowbreak local\_\allowbreak voucher\_\allowbreak status\_\allowbreak cache (id) \newline - Índices B-Tree: idx\_\allowbreak local\_\allowbreak voucher\_\allowbreak work\_\allowbreak order (work\_order\_id), idx\_\allowbreak local\_\allowbreak voucher\_\allowbreak status (status) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{offline\allowbreak \_payment\allowbreak \_collections}} \\*
\hline
\textbf{Motor y Producto} & SQLite 3 (Mobile Workshop) \\*
\hline
\textbf{Propósito y Aislamiento} & Búfer transaccional local de recaudación y anticipos en patio ante contingencias de red inalámbrica. Almacena los cobros registrados en movilidad junto con la clave única de idempotencia collection\_id, posibilitando la conciliación y replicación atómica hacia el backend mediante llamadas HTTPS REST al restablecer la cobertura celular o WiFi. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{collection\_id (TEXT PK)}, \texttt{voucher\_id (TEXT)}, \texttt{work\_order\_id (TEXT)}, \texttt{amount (REAL)}, \texttt{payment\_method (TEXT)}, \texttt{reference\_code (TEXT)}, \texttt{status (TEXT)}, \texttt{created\_at (TEXT)}, \texttt{synced\_at (TEXT)}. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_\allowbreak offline\_\allowbreak payment\_\allowbreak collections (collection\_id) \newline - CHECK: chk\_\allowbreak offline\_\allowbreak payment\_\allowbreak status (status IN ('PENDING', 'SYNCED', 'FAILED')), chk\_\allowbreak offline\_\allowbreak payment\_\allowbreak amount (amount > 0.00) \newline - Índices B-Tree: idx\_\allowbreak offline\_\allowbreak payments\_\allowbreak status (status, created\_at), idx\_\allowbreak offline\_\allowbreak payments\_\allowbreak voucher (voucher\_id) \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Elaboración propia en base al diseño relacional y la especificación física de persistencia.

A partir de la estructura formalizada en la @fig:database-diagram-invoicing y la @tbl:invoicing-database-objects, se identifican tres fundamentos de ingeniería de software que respaldan la solidez, seguridad y resiliencia de la persistencia:

- **Aislamiento Multi-Inquilino y Restricciones Compuestas de Series Fiscales:**
  La arquitectura física delega la segregación de inquilinos en el discriminador indexado **tenant_id**, presente en toda tabla sujeta a fronteras corporativas. Esta clave de particionamiento lógico, respaldada por la restricción de unicidad compuesta entre inquilino, serie y número en **electronic_vouchers**, impide colisiones entre talleres concurrentes y garantiza el cumplimiento tributario ante la autoridad fiscal. Asimismo, el índice compuesto de búsqueda optimiza la resolución de consultas contables de alta frecuencia en el libro de ventas.

- **Inmutabilidad Contable, Bloqueo Optimista y Trazabilidad Forense:**
  El diseño impone que toda cabecera fiscal aceptada sea inalterable, mitigando fraudes o alteraciones retroactivas en el libro de ingresos del taller. La incorporación del atributo **version** en el arquetipo transversal **auditable_abstract_entity** habilita el control de concurrencia optimista en el motor relacional, previniendo anomalías de actualización perdida en cancelaciones simultáneas. Adicionalmente, las marcas temporales inmutables y el registro del hash SHA-256 consolidan una pista de auditoría forense íntegra para inspecciones legales.

- **Resiliencia Operativa Desconectada y Conciliación Idempotente en SQLite 3:**
  La persistencia local en el dispositivo móvil desacopla el despacho vehicular en patio respecto a la disponibilidad del enlace telemático central. La estructura de caché en **local_voucher_status_cache** permite a los mecánicos validar la solvencia de la orden de trabajo de manera instantánea, agilizando la entrega física del automóvil. Asimismo, la tabla **offline_payment_collections** almacena transacciones de cobro protegidas por identificadores universales únicos de idempotencia, garantizando una convergencia atómica y libre de duplicidades al reintegrarse a la red del taller.

### 2.6.8. *Bounded Context: SaaS Billing & Subscriptions*

El Bounded Context de SaaS Billing & Subscriptions administra de forma integral el modelo de monetización recurrente B2B (*Business-to-Business*) de la compañía Andeva hacia los talleres mecánicos abonados a la plataforma Atelier. Su perímetro de responsabilidad abarca la gestión de los planes de suscripción, el aprovisionamiento dinámico de capacidades de software, el cobro recurrente mediante la pasarela internacional Stripe, la gobernanza de cuotas operativas por taller y la conciliación contable de los recibos de servicio.

En el diseño arquitectónico de Atelier, este contexto mantiene un desacoplamiento estricto respecto al módulo de facturación local (Invoicing & Compliance): mientras que Invoicing gobierna los comprobantes fiscales que el taller extiende a los conductores conforme a las normas de SUNAT, SaaS Billing rige el contrato comercial que vincula al taller como cliente corporativo con Andeva. Mezclar estas dos dimensiones en un único modelo de facturación induciría a severos acoplamientos, contaminando la lógica contable internacional con particularidades tributarias peruanas.

El dominio modela la raíz de agregado `SubscriptionPlan`, la cual define los niveles comerciales del catálogo (`GO`, `PRO`, `MAX`, `ENTERPRISE`), las periodicidades de facturación (`MONTHLY`, `YEARLY`) y los límites de consumo estipulados (`TenantQuotaLimits`). Por su parte, la raíz de agregado `TenantSubscription` gobierna el ciclo de vida contractual de cada taller a través de los estados `TRIALING`, `ACTIVE`, `PAST_DUE`, `CANCELED` y `UNPAID`. Cuando un taller se afilia, la suscripción controla los periodos de gracia ante fallos bancarios y autoriza de forma estricta el acceso al sistema.

Un componente arquitectónico distintivo de este contexto es su adhesión estricta a la certificación de seguridad PCI-DSS (*Payment Card Industry Data Security Standard*). El backend de Atelier jamás procesa, transfiere ni persiste números de tarjetas de crédito o códigos de seguridad bancarios, delegando la captura sensible al frontend mediante Stripe Elements y el SDK móvil oficial de Stripe, custodiando únicamente identificadores de recursos tokenizados (`stripe_customer_id`, `stripe_subscription_id`, `stripe_price_id`). 

Asimismo, para garantizar la consistencia en el procesamiento de eventos asíncronos provenientes de Stripe (cobros de facturas, cancelaciones por falta de pago o cambios de plan), el contexto modela el agregado `StripeWebhookEvent`, el cual asegura un procesamiento exactamente una vez (*Exactly-Once Processing*) mediante restricciones de unicidad e idempotencia estricta.

En cuanto a la soberanía de acceso, la plataforma implementa una arquitectura de Autorización Forzada en Backend (*Backend-Enforced Authorization*). Las interfaces visuales en Angular y Android actúan como compuertas informativas y de experiencia progresiva mediante candados o modales de actualización. Sin embargo, la seguridad del modelo de negocio reside exclusivamente en el servidor central. Toda petición que implique creación de sedes, registro de personal, apertura de órdenes de trabajo, vinculación de dispositivos telemáticos OBD-II, carga de evidencias fotográficas, registro de clientes corporativos, transferencias entre múltiples almacenes o generación de reportes predictivos con inteligencia artificial es fiscalizada por el servicio de dominio puro `SubscriptionQuotaEnforcementService`. Para erradicar la sobrecarga en la base de datos relacional y mantener tiempos de respuesta inferiores a 0.05 milisegundos, la fachada pública del contexto opera sobre una capa de memoria local de alta velocidad estructurada con Caffeine Cache, cuya invalidación se produce de forma reactiva e inmediata tras la recepción conforme de eventos webhooks de Stripe.

#### 2.6.8.1. Domain Layer

La capa de dominio del Bounded Context SaaS Billing & Subscriptions constituye el núcleo conceptual de monetización recurrente y gobierno contractual del ecosistema Atelier. Su perímetro abarca la administración del catálogo de planes de software comercializados por Andeva, el aprovisionamiento dinámico de cuotas operativas para los talleres mecánicos, el procesamiento asíncrono de recaudaciones mediante la pasarela internacional Stripe y la mitigación rigurosa de fallos de red bajo estándares de idempotencia estricta.

Al articular la soberanía de licenciamiento de la plataforma, los componentes tácticos residen bajo el paquete canónico **com.andeva.atelier.platform.billing.domain** y responden a cuatro directrices de diseño arquitectónico:

- **Desacoplamiento estricto frente a comprobantes fiscales locales:** Aislamiento total entre los cobros corporativos B2B que Andeva factura a los talleres automotrices y los comprobantes de pago electrónicos que cada taller emite a conductores o flotas bajo la normativa de SUNAT en Invoicing & Compliance, previniendo la contaminación de modelos contables disímiles.

- **Mitigación integral de riesgos de seguridad PCI-DSS Nivel 1:** El backend de Atelier delega la captura y transmisión de credenciales bancarias sensibles a componentes oficiales de Stripe Elements en el frontend, custodiando en el dominio únicamente identificadores tokenizados inmutables y prescindiendo del almacenamiento de números de tarjeta de crédito o códigos de verificación.

- **Idempotencia transaccional y procesamiento exactamente una vez:** Resiliencia determinista ante la entrega duplicada de notificaciones telemáticas de Stripe durante ventanas de reintento de 72 horas mediante restricciones de unicidad sobre identificadores de eventos, neutralizando dobles facturaciones o inconsistencias de estado.

- **Gobernanza in-memory de cuotas operativas acelerada con caché:** Fiscalización algorítmica de techos de consumo contratados por cada taller automotriz mediante servicios de dominio puros, complementada con invalidación reactiva ante eventos de ciclo de vida para garantizar autorizaciones en submilisegundos en todos los módulos del ERP.

En la @tbl:billing-domain-types se expone el catálogo taxonómico consolidado de los componentes tácticos que estructuran la Capa de Dominio de SaaS Billing & Subscriptions, clasificando sus responsabilidades, relaciones cardinales y paquetes canónicos.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo de la Capa de Dominio del Bounded Context SaaS Billing \& Subscriptions} \label{tbl:billing-domain-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\
\hline
\endhead
Subscription\allowbreak Plan & Raíz de consistencia del catálogo comercial. Define paquetes de licenciamiento, tarifas recurrentes y cuotas de consumo paquetizadas. \\*
\hline
\textbf{Categoría} & Raíz de Agregado \\*
\hline
\textbf{Relaciones} & Generalización de AbstractDomainAggregateRoot<SubscriptionPlan>. Composición 1 a 0..* con PlanFeature. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Tenant\allowbreak Subscription & Raíz de consistencia contractual del taller. Gobierna ciclo de vida del servicio, periodos de cobertura pagada y suspensiones. \\*
\hline
\textbf{Categoría} & Raíz de Agregado \\*
\hline
\textbf{Relaciones} & Generalización de AbstractDomainAggregateRoot<TenantSubscription>. Referencia por identidad a TenantId y PlanId. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Saas\allowbreak Invoice & Raíz de consistencia contable de recaudación. Custodia el comprobante financiero generado por Stripe por liquidación del servicio. \\*
\hline
\textbf{Categoría} & Raíz de Agregado \\*
\hline
\textbf{Relaciones} & Generalización de AbstractDomainAggregateRoot<SaasInvoice>. Referencia por identidad a SubscriptionId y TenantId. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Stripe\allowbreak Webhook\allowbreak Event & Raíz de consistencia para procesamiento exactamente una vez. Garantiza idempotencia estricta y auditoría forense ante notificaciones asíncronas. \\*
\hline
\textbf{Categoría} & Raíz de Agregado \\*
\hline
\textbf{Relaciones} & Raíz independiente con restricción de unicidad relacional sobre StripeEventId para deduplicación. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Plan\allowbreak Feature & Módulo funcional empaquetado en un plan comercial. Modela la habilitación o restricción de capacidades avanzadas de la plataforma. \\*
\hline
\textbf{Categoría} & Entidad Dependiente \\*
\hline
\textbf{Relaciones} & Pertenece por composición a SubscriptionPlan con clave alfanumérica unívoca de funcionalidad. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PlanId & Identificador único universal fuertemente tipado para planes comerciales de software. \\*
\hline
\textbf{Categoría} & Identificador Fuertemente Tipado \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak ids} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
SubscriptionId & Identificador único universal fuertemente tipado para contratos de suscripción SaaS. \\*
\hline
\textbf{Categoría} & Identificador Fuertemente Tipado \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak ids} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Saas\allowbreak InvoiceId & Identificador único universal fuertemente tipado para recibos financieros de suscripción. \\*
\hline
\textbf{Categoría} & Identificador Fuertemente Tipado \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak ids} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Stripe\allowbreak EventId & Identificador unívoco del evento asíncrono emitido por Stripe con prefijo reglamentario evt\_. \\*
\hline
\textbf{Categoría} & Identificador Fuertemente Tipado \\*
\hline
\textbf{Relaciones} & Registro inmutable con validación de expresión regular de la pasarela de pagos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak ids} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Plan\allowbreak FeatureId & Identificador único universal fuertemente tipado para características funcionales empaquetadas en un plan. \\*
\hline
\textbf{Categoría} & Identificador Fuertemente Tipado \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak ids} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PlanTier & Segmentación funcional comercial del paquete de software ofrecido a los talleres. \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Valores GO, PRO, MAX y ENTERPRISE asociados a SubscriptionPlan. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak enums} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
BillingCycle & Periodicidad pactada para el cobro recurrente del servicio en la plataforma. \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Valores formales MONTHLY y YEARLY consumidos por PlanPricing. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak enums} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Subscription\allowbreak Status & Estados formales del ciclo de vida contractual de la membresía del taller mecánico. \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Valores TRIALING, ACTIVE, PAST\_DUE, CANCELED, UNPAID e INCOMPLETE. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak enums} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
InvoiceStatus & Estados formales de liquidación financiera del recibo de suscripción SaaS emitido. \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Valores PAID, OPEN, VOID y UNCOLLECTIBLE gobernados por SaasInvoice. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak enums} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Webhook\allowbreak Processing\allowbreak Status & Situación transaccional del procesamiento de eventos asíncronos recibidos por webhook. \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Valores PENDING, PROCESSED, FAILED e IGNORED gestionados por StripeWebhookEvent. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak enums} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PlanPricing & Estructura inmutable que asocia el importe monetario formal con su ciclo de facturación recurrente. \\*
\hline
\textbf{Categoría} & Objeto de Valor Inmutable \\*
\hline
\textbf{Relaciones} & Agrupa Money y BillingCycle con validación de precio no negativo. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Stripe\allowbreak CustomerId & Identificador del cliente corporativo en la bóveda de Stripe con prefijo reglamentario cus\_. \\*
\hline
\textbf{Categoría} & Objeto de Valor Inmutable \\*
\hline
\textbf{Relaciones} & Registro inmutable que delega el almacenamiento de datos sensibles bajo estándar PCI-DSS. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Stripe\allowbreak SubscriptionId & Identificador unívoco del contrato de cobro recurrente en Stripe con prefijo reglamentario sub\_. \\*
\hline
\textbf{Categoría} & Objeto de Valor Inmutable \\*
\hline
\textbf{Relaciones} & Registro inmutable vinculado al ciclo de facturación externa. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Stripe\allowbreak PriceId & Identificador foráneo del precio recurrente en el catálogo de Stripe con prefijo reglamentario price\_. \\*
\hline
\textbf{Categoría} & Objeto de Valor Inmutable \\*
\hline
\textbf{Relaciones} & Registro inmutable que vincula la tarifa configurada en la pasarela externa. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Stripe\allowbreak InvoiceId & Identificador foráneo unívoco de la factura generada por Stripe con prefijo reglamentario in\_. \\*
\hline
\textbf{Categoría} & Objeto de Valor Inmutable \\*
\hline
\textbf{Relaciones} & Registro inmutable que vincula el comprobante financiero externo con SaasInvoice. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Subscription\allowbreak Period & Ventana temporal inmutable que delimita el intervalo formal de vigencia de cobertura pagada. \\*
\hline
\textbf{Categoría} & Objeto de Valor Inmutable \\*
\hline
\textbf{Relaciones} & Agrupa marcas temporales startDate y endDate con validación de secuencia cronológica. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Tenant\allowbreak Quota\allowbreak Limits & Techos máximos de recursos operativos y banderas de módulos autorizados por plan. \\*
\hline
\textbf{Categoría} & Objeto de Valor Inmutable \\*
\hline
\textbf{Relaciones} & Parámetros inmutables maxBranches, maxActiveStaff, iotTelemetryEnabled y aiDiagnosticsEnabled. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Subscription\allowbreak Quota\allowbreak Enforcement\allowbreak Service & Servicio de dominio que fiscaliza los límites de consumo antes de crear recursos en otros módulos. \\*
\hline
\textbf{Categoría} & Servicio de Dominio \\*
\hline
\textbf{Relaciones} & Evalúa reglas de negocio sobre TenantSubscription y SubscriptionPlan lanzando QuotaExceededException. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Stripe\allowbreak Webhook\allowbreak Signature\allowbreak Verification\allowbreak Service & Servicio de dominio criptográfico que verifica la autenticidad matemática de los eventos entrantes. \\*
\hline
\textbf{Categoría} & Servicio de Dominio \\*
\hline
\textbf{Relaciones} & Comprueba la firma HMAC-SHA256 del encabezado Stripe-Signature contra el secreto simétrico. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Subscription\allowbreak Lifecycle\allowbreak Domain\allowbreak Service & Servicio de dominio que gobierna políticas contractuales, fiscalización de gracia y expiración. \\*
\hline
\textbf{Categoría} & Servicio de Dominio \\*
\hline
\textbf{Relaciones} & Aplica reglas de negocio sobre transiciones de estado de TenantSubscription. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Subscription\allowbreak Plan\allowbreak Repository & Contrato de persistencia de dominio para el catálogo de planes comerciales. \\*
\hline
\textbf{Categoría} & Puerto de Repositorio de Dominio \\*
\hline
\textbf{Relaciones} & Implementado por adaptadores en Infrastructure Layer para persistencia en PostgreSQL 16. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Tenant\allowbreak Subscription\allowbreak Repository & Contrato de persistencia de dominio para contratos de suscripción activa de talleres mecánicos. \\*
\hline
\textbf{Categoría} & Puerto de Repositorio de Dominio \\*
\hline
\textbf{Relaciones} & Provee consultas de alta velocidad y verificación de unicidad de suscripción activa por taller. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Saas\allowbreak Invoice\allowbreak Repository & Contrato de persistencia de dominio para recibos y comprobantes financieros de membresías. \\*
\hline
\textbf{Categoría} & Puerto de Repositorio de Dominio \\*
\hline
\textbf{Relaciones} & Provee consultas históricas de facturación por taller y búsqueda por identificador de Stripe. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Stripe\allowbreak Webhook\allowbreak Event\allowbreak Repository & Contrato de persistencia de dominio para registro forense y control de deduplicación de eventos. \\*
\hline
\textbf{Categoría} & Puerto de Repositorio de Dominio \\*
\hline
\textbf{Relaciones} & Permite verificar existencia previa por StripeEventId garantizando idempotencia estricta. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Subscription\allowbreak Plan\allowbreak Created\allowbreak Event & Notifica la publicación formal de un nuevo plan comercial en el catálogo de Andeva. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Emitido por SubscriptionPlan tras su factoría de creación. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Tenant\allowbreak Subscription\allowbreak Activated\allowbreak Event & Notifica la activación de una membresía o el inicio de una prueba gratuita para un taller. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Emitido por TenantSubscription habilitando el acceso a módulos de la plataforma. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Tenant\allowbreak Subscription\allowbreak Renewed\allowbreak Event & Notifica la extensión del periodo pagado tras la liquidación bancaria exitosa de un ciclo. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Emitido por TenantSubscription renovando la validez en la capa de caché. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Tenant\allowbreak Subscription\allowbreak PastDue\allowbreak Event & Notifica el rechazo bancario de un cobro recurrente dando inicio al periodo de tolerancia. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Emitido por TenantSubscription alertando al administrador del taller. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Tenant\allowbreak Subscription\allowbreak Canceled\allowbreak Event & Notifica la rescisión voluntaria o forzosa de la suscripción SaaS revocando accesos. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Emitido por TenantSubscription invalidando de forma inmediata credenciales de sesión en IAM. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Tenant\allowbreak Plan\allowbreak Changed\allowbreak Event & Notifica el cambio de nivel comercial de un taller reajustando sus cuotas de recursos. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Emitido por TenantSubscription propagando nuevas capacidades a otros contextos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Saas\allowbreak Invoice\allowbreak Paid\allowbreak Event & Notifica la acreditación bancaria exitosa de un recibo de servicio procesado por Stripe. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Emitido por SaasInvoice registrando la liquidación financiera. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Saas\allowbreak Invoice\allowbreak Payment\allowbreak Failed\allowbreak Event & Notifica el fallo del intento de débito bancario asociado a un recibo emitido por la plataforma. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Emitido por SaasInvoice iniciando mecanismos de cobranza y notificación de mora. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Stripe\allowbreak Webhook\allowbreak Processed\allowbreak Event & Notifica el procesamiento transaccional e idempotente exitoso de un webhook de Stripe. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Emitido por StripeWebhookEvent tras culminar la mutación de estado de negocio. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Billing\allowbreak Domain\allowbreak Exception & Superclase abstracta para contingencias semánticas e infracciones a las reglas de cobro SaaS. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Generalización de DomainException con normalización de códigos RFC 7807. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Duplicate\allowbreak Active\allowbreak Subscription\allowbreak Exception & Señala el intento de registrar o activar una nueva suscripción para un taller con membresía vigente. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de BillingDomainException con mapeo HTTP 409 Conflict. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Invalid\allowbreak Plan\allowbreak Pricing\allowbreak Exception & Señala importes monetarios negativos o configuraciones tarifarias inválidas en el plan comercial. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de BillingDomainException con mapeo HTTP 400 Bad Request. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Invalid\allowbreak Webhook\allowbreak Signature\allowbreak Exception & Señala discrepancias criptográficas HMAC-SHA256 en la firma de notificaciones entrantes de Stripe. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de BillingDomainException con mapeo HTTP 401 Unauthorized. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Plan\allowbreak Not\allowbreak Found\allowbreak Exception & Señala la ausencia del plan de suscripción solicitado en el catálogo comercial. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de BillingDomainException con mapeo HTTP 404 Not Found. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Quota\allowbreak Exceeded\allowbreak Exception & Señala la tentativa de exceder los techos operativos autorizados por el plan de suscripción. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de BillingDomainException con mapeo HTTP 403 Forbidden. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Saas\allowbreak Invoice\allowbreak Not\allowbreak Found\allowbreak Exception & Señala que no se localiza el comprobante contable de recaudación en el repositorio financiero. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de BillingDomainException con mapeo HTTP 404 Not Found. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Stripe\allowbreak Integration\allowbreak Exception & Señala anomalías de red, interrupciones o fallos de comunicación con la API externa de Stripe. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de BillingDomainException con mapeo HTTP 502 Bad Gateway. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Stripe\allowbreak Webhook\allowbreak Processing\allowbreak Exception & Señala anomalías sintácticas o estructurales en la deserialización del cuerpo JSON del webhook. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de BillingDomainException con mapeo HTTP 422 Unprocessable Entity. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Subscription\allowbreak Not\allowbreak Found\allowbreak Exception & Señala que no se localiza un contrato de membresía asociado al identificador o taller consultado. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de BillingDomainException con mapeo HTTP 404 Not Found. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Subscription\allowbreak Past\allowbreak Due\allowbreak Exception & Señala que el taller automotriz intenta operar con cobros rechazados fuera del periodo de gracia. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de BillingDomainException con mapeo HTTP 402 Payment Required. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak domain.\allowbreak exceptions} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Catálogo taxonómico de tipos tácticos del paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak billing.\allowbreak domain segregado en los subpaquetes model.\allowbreak aggregates, model.\allowbreak entities, model.\allowbreak ids, model.\allowbreak enums, model.\allowbreak valueobjects, model.\allowbreak events, exceptions, repositories y services.

**Raíces de Agregado y Entidades Dependientes de SaaS Billing & Subscriptions**

El modelo conceptual estructura su consistencia transaccional alrededor de cuatro raíces de agregado independientes y una entidad dependiente, garantizando límites de concurrencia acotados y alta cohesión operativa:

- **SubscriptionPlan**: Modela el paquete comercial de software ofrecido a los talleres automotrices abonados. Custodia las tarifas de licenciamiento, la frecuencia de facturación recurrente pactada y las cuotas de consumo paquetizadas. Mantiene una relación de composición 1 a 0..* con la entidad dependiente **PlanFeature** para gobernar la habilitación selectiva de capacidades técnicas avanzadas de la plataforma.

La entidad impone como invariantes de negocio que los identificadores de tarifa foránea cumplan con el prefijo oficial de la pasarela de pagos, que el importe monetario sea estrictamente no negativo (*price* ≥ 0.00) y que los techos operativos mínimos amparen sedes físicas o unidades de auxilio móvil en campo (*maxBranches* ≥ 1) y personal activo en terminales web o dispositivos móviles (*maxActiveStaff* ≥ 1). La desactivación del plan comercial inhabilita su contratación para nuevos talleres sin alterar los derechos adquiridos de contratos preexistentes.

En la @tbl:billing-plan-members se especifican los atributos estructurales, métodos de control comercial y reglas de consistencia de la raíz de agregado **SubscriptionPlan**.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de la Raíz de Agregado SubscriptionPlan} \label{tbl:billing-plan-members} \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Raíz de Agregado:} SubscriptionPlan (Catálogo Comercial de Licenciamiento)} \\*
\hline
id & Identificador universal único del plan comercial. Inmutable y no nulo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{PlanId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
stripePriceId & Identificador foráneo de la tarifa configurada en Stripe con prefijo reglamentario price\_. \\*
\hline
\textbf{Tipo o Firma} & \texttt{StripePriceId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
name & Denominación descriptiva del paquete de software ofrecido a los talleres mecánicos. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
tier & Segmentación funcional comercial del paquete de software con niveles GO, PRO, MAX o ENTERPRISE. \\*
\hline
\textbf{Tipo o Firma} & \texttt{PlanTier} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
pricing & Estructura inmutable que asocia el importe monetario formal con su periodicidad de recaudación. \\*
\hline
\textbf{Tipo o Firma} & \texttt{PlanPricing} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
quotaLimits & Techos máximos de recursos operativos y banderas de módulos de plataforma autorizados. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TenantQuotaLimits} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
isActive & Bandera booleana que habilita o suspende la oferta del plan para nuevas contrataciones comerciales. \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
features & Colección de capacidades modulares paquetizadas dentro de la oferta de licenciamiento. \\*
\hline
\textbf{Tipo o Firma} & \texttt{List<PlanFeature>} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
create & Factoría de dominio que valida invariantes de precios no negativos y techos unitarios mínimos emitiendo SubscriptionPlanCreatedEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{static SubscriptionPlan create(StripePriceId,\allowbreak  String,\allowbreak  PlanTier,\allowbreak  PlanPricing,\allowbreak  TenantQuotaLimits)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
updateDetails & Actualiza importes tarifarios y techos de cuota preservando intactas las suscripciones previas ya contratadas. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void updateDetails(String,\allowbreak  PlanPricing,\allowbreak  TenantQuotaLimits)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
deactivate & Suspende la disponibilidad comercial del plan impidiendo nuevas adhesiones de talleres sin alterar contratos en curso. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void deactivate()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
activate & Restituye la oferta del plan en el portal de contratación comercial de la plataforma. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void activate()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
addFeature & Asocia una nueva capacidad técnica modular al catálogo de funcionalidades del plan de software. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void addFeature(PlanFeature)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de miembros de la clase SubscriptionPlan del paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak aggregates.

- **TenantSubscription**: Representa el contrato de membresía de software suscrito entre Andeva y el taller automotriz. Gobierna la máquina de estados contractual a través de las transiciones entre estados de prueba, vigencia activa, mora transitoria, suspensión y cancelación voluntaria o forzosa. Controla los intervalos temporales de cobertura pagada y concede el acceso operativo al sistema.

Aplica como regla de consistencia estricta que un taller automotriz no puede poseer más de una suscripción en estado activo o en periodo de prueba simultáneamente, impidiendo duplicidades de licenciamiento sobre el mismo espacio de trabajo. Asimismo, demanda que la fecha de inicio del ciclo sea cronológicamente anterior a la fecha de término (*startDate* < *endDate*) y estipula que una membresía formalmente cancelada adquiere carácter terminal, exigiendo una nueva contratación para restablecer el servicio.

En la @tbl:billing-subscription-members se detallan los atributos, signaturas de operaciones y reglas de consistencia interna de la raíz de agregado **TenantSubscription**.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de la Raíz de Agregado TenantSubscription} \label{tbl:billing-subscription-members} \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Raíz de Agregado:} TenantSubscription (Contrato de Membresía del Taller)} \\*
\hline
id & Identificador universal único del contrato de membresía SaaS. Inmutable y no nulo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{SubscriptionId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
tenantId & Taller automotriz titular del contrato de software. Clave de aislamiento multitenant. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TenantId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
planId & Identificador del paquete comercial contratado por el taller automotriz. \\*
\hline
\textbf{Tipo o Firma} & \texttt{PlanId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
stripeCustomerId & Identificador del cliente corporativo en la bóveda de Stripe con prefijo cus\_. \\*
\hline
\textbf{Tipo o Firma} & \texttt{StripeCustomerId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
stripeSubscriptionId & Identificador unívoco del contrato de suscripción gestionado por Stripe con prefijo sub\_. \\*
\hline
\textbf{Tipo o Firma} & \texttt{StripeSubscriptionId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
status & Situación de vigencia contractual del taller bajo los estados TRIALING, ACTIVE, PAST\_DUE, CANCELED o UNPAID. \\*
\hline
\textbf{Tipo o Firma} & \texttt{SubscriptionStatus} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
currentPeriod & Ventana temporal de cobertura pagada delimitada por fecha de inicio y finalización formal. \\*
\hline
\textbf{Tipo o Firma} & \texttt{SubscriptionPeriod} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
cancelAtPeriodEnd & Bandera que programa la no renovación automática al concluir el periodo pagado vigente. \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
canceledAt & Marca de tiempo UTC formal en que se ejecutó o solicitó la rescisión del servicio. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Optional<Instant>} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
trialEndDate & Marca de tiempo UTC que delimita la expiración de la modalidad de prueba gratuita. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Optional<Instant>} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
startTrial & Factoría de dominio para periodos de prueba registrando TenantSubscriptionActivatedEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{static TenantSubscription startTrial(TenantId,\allowbreak  PlanId,\allowbreak  StripeCustomerId,\allowbreak  int)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
activate & Factoría tras liquidación exitosa en Stripe registrando TenantSubscriptionActivatedEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{static TenantSubscription activate(TenantId,\allowbreak  PlanId,\allowbreak  StripeCustomerId,\allowbreak  StripeSubscriptionId,\allowbreak  SubscriptionPeriod)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
renewPeriod & Extiende la cobertura pagada tras confirmación bancaria y emite TenantSubscriptionRenewedEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void renewPeriod(SubscriptionPeriod)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
markPastDue & Registra la situación de mora ante cobro bancario fallido e inicia tolerancia con TenantSubscriptionPastDueEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void markPastDue()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
cancelAtPeriodEnd & Configura la terminación programada del contrato al expirar el ciclo de cobertura liquidado. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void cancelAtPeriodEnd()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
cancelImmediately & Revoca el acceso de forma inmediata y definitiva emitiendo TenantSubscriptionCanceledEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void cancelImmediately(Instant)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
changePlan & Actualiza el plan comercial emitiendo TenantPlanChangedEvent para reajustar límites de uso. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void changePlan(PlanId,\allowbreak  StripePriceId)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
isAccessGranted & Evalúa si el taller está habilitado para operar bajo estados TRIALING, ACTIVE o periodo de gracia. \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean isAccessGranted()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de miembros de la clase TenantSubscription del paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak aggregates.

- **SaasInvoice**: Modela el comprobante o recibo contable interno generado tras la liquidación de cargos recurrentes ejecutados por Stripe hacia el taller automotriz. Custodia los identificadores foráneos de recaudación, el importe monetario efectivamente amortizado, la marca temporal UTC del débito bancario y los enlaces seguros para la inspección y descarga del comprobante digital.

El agregado establece que todo recibo en estado liquidado es estrictamente inmutable, prohibiendo modificaciones retroactivas sobre importes o clientes vinculados. Asimismo, ante rechazos en los medios de pago bancarios, transiciona su estado para coordinar de forma determinista la apertura del periodo de tolerancia en el contrato de suscripción.

En la @tbl:billing-invoice-members se exponen los atributos, signaturas operativas y reglas de liquidación financiera de la raíz de agregado **SaasInvoice**.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de la Raíz de Agregado SaasInvoice} \label{tbl:billing-invoice-members} \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Raíz de Agregado:} SaasInvoice (Recibo de Liquidación Financiera)} \\*
\hline
id & Identificador universal único del comprobante financiero interno. Inmutable y no nulo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{SaasInvoiceId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
subscriptionId & Identificador del contrato de suscripción asociado a la liquidación financiera. \\*
\hline
\textbf{Tipo o Firma} & \texttt{SubscriptionId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
tenantId & Taller automotriz titular responsable de amortizar el costo del servicio de software. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TenantId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
stripeInvoiceId & Identificador foráneo unívoco del recibo en Stripe con prefijo reglamentario in\_. \\*
\hline
\textbf{Tipo o Firma} & \texttt{StripeInvoiceId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
amountPaid & Importe monetario neto debitado de forma efectiva de la tarjeta de crédito o cuenta bancaria. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
status & Situación de cobro del recibo financiero emitido bajo estados PAID, OPEN, VOID o UNCOLLECTIBLE. \\*
\hline
\textbf{Tipo o Firma} & \texttt{InvoiceStatus} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
invoicePdfUrl & Enlace seguro HTTPS provisto por Stripe para la descarga documental en formato PDF. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
hostedInvoiceUrl & Enlace interactivo seguro provisto por Stripe para consulta en línea y pago de la factura. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
paidAt & Marca de tiempo UTC que certifica la liquidación y acreditación formal del débito bancario. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Optional<Instant>} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
recordPaid & Factoría que registra el cobro satisfactorio y emite SaasInvoicePaidEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{static SaasInvoice recordPaid(SubscriptionId,\allowbreak  TenantId,\allowbreak  StripeInvoiceId,\allowbreak  Money,\allowbreak  String,\allowbreak  String,\allowbreak  Instant)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
markPaymentFailed & Registra el rechazo bancario y emite SaasInvoicePaymentFailedEvent para gestión de mora. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void markPaymentFailed(String)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de miembros de la clase SaasInvoice del paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak aggregates.

- **StripeWebhookEvent** y **PlanFeature**: La raíz de agregado **StripeWebhookEvent** implementa un escudo de idempotencia estricta frente a la entrega asíncrona de notificaciones por parte de la pasarela de pagos. Almacena la carga útil JSON íntegra para fines de auditoría forense y aprovecha una restricción de unicidad relacional sobre el identificador emitido por Stripe para descartar reintentos espurios de red.

Por su parte, **PlanFeature** estructura las capacidades modulares empaquetadas en un plan comercial, abarcando la ingesta de telemetría vehicular IoT y la emisión de diagnósticos predictivos mediante inteligencia artificial, tipificando claves alfanuméricas inmutables para la verificación dinámica de permisos en tiempo de ejecución.

En la @tbl:billing-webhook-feature-members se detallan los miembros, tipos y responsabilidades de la raíz de agregado **StripeWebhookEvent** y la entidad dependiente **PlanFeature**.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de StripeWebhookEvent y PlanFeature} \label{tbl:billing-webhook-feature-members} \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Raíz de Agregado:} StripeWebhookEvent (Idempotencia y Auditoría Forense)} \\*
\hline
id & Identificador universal único interno de la bitácora de eventos asíncronos. \\*
\hline
\textbf{Tipo o Firma} & \texttt{UUID} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
stripeEventId & Identificador unívoco del evento emitido por Stripe con restricción relacional UNIQUE. \\*
\hline
\textbf{Tipo o Firma} & \texttt{StripeEventId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
eventType & Tipificación del suceso asíncrono reportado por Stripe en la pasarela externa. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
eventPayload & Cuerpo íntegro serializado en formato JSON para trazabilidad y auditoría forense. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
status & Situación del procesamiento del mensaje bajo estados PENDING, PROCESSED, FAILED o IGNORED. \\*
\hline
\textbf{Tipo o Firma} & \texttt{WebhookProcessingStatus} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
processedAt & Marca de tiempo UTC de resolución o atención de la notificación en el backend. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Instant} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
errorMessage & Detalle técnico descriptivo en caso de suscitarse anomalías durante el procesamiento. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Optional<String>} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
receive & Factoría que registra la recepción inicial del evento en estado PENDING. \\*
\hline
\textbf{Tipo o Firma} & \texttt{static StripeWebhookEvent receive(StripeEventId,\allowbreak  String,\allowbreak  String)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
markProcessed & Transiciona el estado a PROCESSED tras actualizar satisfactoriamente el modelo de negocio. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void markProcessed()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
markFailed & Transiciona el estado a FAILED registrando la causa técnica del fallo transaccional. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void markFailed(String)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad Dependiente:} PlanFeature (Módulo Funcional Paquetizado)} \\*
\hline
id & Identificador universal único de la característica técnica subordinada. \\*
\hline
\textbf{Tipo o Firma} & \texttt{PlanFeatureId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
featureKey & Clave alfanumérica unívoca de la funcionalidad paquetizada en el catálogo de software. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
description & Glosa comercial descriptiva de la capacidad provista para el usuario final. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
isEnabled & Bandera que habilita o inhabilita la disponibilidad del módulo para el plan activo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de miembros de StripeWebhookEvent y PlanFeature en los paquetes aggregates y entities de com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak billing.\allowbreak domain.

**Objetos de Valor y Enumeraciones de SaaS Billing & Subscriptions**

Los conceptos e invariantes del modelo contractual se encapsulan en objetos de valor inmutables, modelados como registros de Java 21 con validación de frontera en sus constructores compactos. Erradican la obsesión por tipos primitivos mediante tipos dedicados para montos, techos de recursos, intervalos cronológicos e identificadores externos de Stripe.

En la @tbl:billing-value-objects se especifican los atributos y reglas de validación de los objetos de valor inmutables y las enumeraciones que vertebran este contexto.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Objetos de Valor y Enumeraciones de SaaS Billing \& Subscriptions} \label{tbl:billing-value-objects} \\
\hline
\thfirst{Componente Inmutable} & \thcell{Definición de Atributos y Reglas de Validación} \\
\hline
\endfirsthead
\hline
\thfirst{Componente Inmutable} & \thcell{Definición de Atributos y Reglas de Validación} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Identificador Tipado:} PlanId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal del plan comercial de software. Inmutable y no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Identificador Tipado:} SubscriptionId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal del contrato de suscripción SaaS del taller. Inmutable y no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Identificador Tipado:} SaasInvoiceId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal del comprobante contable de suscripción. Inmutable y no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Identificador Tipado:} StripeEventId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: String} \\*
\hline
\textbf{Restricciones y Reglas} & Validación de expresión regular con prefijo obligatorio evt\_ garantizando formato original de Stripe. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Identificador Tipado:} PlanFeatureId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal de la característica funcional empaquetada. Inmutable y no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} PlanPricing} \\*
\hline
\textbf{Atributos Clave} & \texttt{price: Money,\allowbreak  billingCycle: BillingCycle} \\*
\hline
\textbf{Restricciones y Reglas} & Invariante de importe monetario no negativo (*price* ≥ 0.00) y fijación unívoca del ciclo de cobro. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} StripeCustomerId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: String} \\*
\hline
\textbf{Restricciones y Reglas} & Validación con prefijo obligatorio cus\_ identificando al cliente en la bóveda de la pasarela. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} StripeSubscriptionId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: String} \\*
\hline
\textbf{Restricciones y Reglas} & Validación con prefijo obligatorio sub\_ identificando la suscripción recurrente en Stripe. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} StripePriceId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: String} \\*
\hline
\textbf{Restricciones y Reglas} & Validación con prefijo obligatorio price\_ identificando la tarifa comercial en Stripe. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} StripeInvoiceId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: String} \\*
\hline
\textbf{Restricciones y Reglas} & Validación con prefijo obligatorio in\_ identificando la factura en la pasarela externa de Stripe. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} SubscriptionPeriod} \\*
\hline
\textbf{Atributos Clave} & \texttt{startDate: Instant,\allowbreak  endDate: Instant} \\*
\hline
\textbf{Restricciones y Reglas} & Invariante cronológica estricta que exige que la fecha de inicio preceda a la de culminación. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} TenantQuotaLimits} \\*
\hline
\textbf{Atributos Clave} & \texttt{maxBranches: int,\allowbreak  maxActiveStaff: int,\allowbreak  maxActiveObd2Devices: int,\allowbreak  maxPhotosPerWorkOrder: int,\allowbreak  maxMonthlyAiReports: int,\allowbreak  companyRegistrationAllowed: boolean,\allowbreak  multiWarehouseAllowed: boolean,\allowbreak  marketplaceListed: boolean,\allowbreak  maxMonthlyWorkOrders: int,\allowbreak  iotTelemetryEnabled: boolean,\allowbreak  aiDiagnosticsEnabled: boolean} \\*
\hline
\textbf{Restricciones y Reglas} & Invariantes de techos operativos (*maxBranches* $\ge$ 1, *maxActiveStaff* $\ge$ 1), cupos numéricos de dispositivos, fotos y reportes IA, y banderas de autorización. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} PlanTier} \\*
\hline
\textbf{Valores Permitidos} & \texttt{GO}, \texttt{PRO}, \texttt{MAX}, \texttt{ENTERPRISE} \\*
\hline
\textbf{Propósito en el Modelo} & Clasificación comercial del nivel de servicio y volumen de capacidad paquetizado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} BillingCycle} \\*
\hline
\textbf{Valores Permitidos} & \texttt{MONTHLY}, \texttt{YEARLY} \\*
\hline
\textbf{Propósito en el Modelo} & Define la periodicidad de liquidación recurrente de la membresía comercial de software. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} SubscriptionStatus} \\*
\hline
\textbf{Valores Permitidos} & \texttt{TRIALING}, \texttt{ACTIVE}, \texttt{PAST\_DUE}, \texttt{CANCELED}, \texttt{UNPAID}, \texttt{INCOMPLETE} \\*
\hline
\textbf{Propósito en el Modelo} & Rige los estados de vigencia contractual, periodos de gracia y rescisión de la membresía. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} InvoiceStatus} \\*
\hline
\textbf{Valores Permitidos} & \texttt{PAID}, \texttt{OPEN}, \texttt{VOID}, \texttt{UNCOLLECTIBLE} \\*
\hline
\textbf{Propósito en el Modelo} & Modela la situación financiera del comprobante de recaudación emitido hacia el taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} WebhookProcessingStatus} \\*
\hline
\textbf{Valores Permitidos} & \texttt{PENDING}, \texttt{PROCESSED}, \texttt{FAILED}, \texttt{IGNORED} \\*
\hline
\textbf{Propósito en el Modelo} & Rige la situación transaccional de atención y deduplicación de notificaciones de pasarela. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Identificadores tipados, objetos de valor inmutables y enumeraciones en los subpaquetes model.\allowbreak ids, model.\allowbreak valueobjects y model.\allowbreak enums de com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak billing.\allowbreak domain.

**Servicios de Dominio de SaaS Billing & Subscriptions**

Las operaciones que trascienden la frontera de un único agregado o que ejecutan validaciones algorítmicas sin estado se implementan mediante servicios de dominio puros desacoplados de tecnologías de persistencia o transporte HTTP:

- **SubscriptionQuotaEnforcementService**: Intercepta de forma síncrona las solicitudes de alta de recursos físicos y humanos originadas en otros contextos de la plataforma. Verifica en tiempo de ejecución que el volumen acumulado de sucursales físicas y unidades operativas de Mobile Workshop no rebase el límite pactado en el plan contratado antes de autorizar sedes en IAM, supervisa la nómina de personal activo en estaciones web y dispositivos móviles desde Human Resources y certifica la habilitación de módulos especializados, lanzando excepciones tipadas ante desbordamientos de consumo.

- **StripeWebhookSignatureVerificationService**: Ejecuta la comprobación criptográfica rigurosa de los mensajes entrantes en el canal telemático de webhooks. Calcula la firma simétrica HMAC-SHA256 sobre el cuerpo del mensaje empleando el secreto compartido y la compara en tiempo constante contra el encabezado de Stripe, verificando adicionalmente una ventana de tolerancia cronológica de 300 segundos para frustrar ataques de intermediarios y repetición.

- **SubscriptionLifecycleDomainService**: Gobierna las políticas de transición contractual, fiscalización de periodos de gracia ante impagos, reactivación de membresías y vigencia operativa del taller en la plataforma.

En la @tbl:billing-domain-services se presentan los tres servicios de dominio de este contexto, indicando sus signaturas operativas y responsabilidades técnicas.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Servicios de Dominio del Bounded Context SaaS Billing \& Subscriptions} \label{tbl:billing-domain-services} \\
\hline
\thfirst{Aspecto de Servicio} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Servicio} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Dominio:} SubscriptionQuotaEnforcementService} \\*
\hline
\textbf{Métodos Principales} & - \texttt{validateBranchCreationAllowed(TenantSubscription sub,\allowbreak  SubscriptionPlan plan,\allowbreak  int currentBranchCount)} \newline - \texttt{validateStaffAdditionAllowed(TenantSubscription sub,\allowbreak  SubscriptionPlan plan,\allowbreak  int currentStaffCount)} \newline - \texttt{validateWorkOrderCreationAllowed(TenantSubscription sub,\allowbreak  SubscriptionPlan plan,\allowbreak  int currentMonthlyOrders)} \newline - \texttt{validateObd2DeviceRegistrationAllowed(TenantSubscription sub,\allowbreak  SubscriptionPlan plan,\allowbreak  int currentActiveObd2Devices)} \newline - \texttt{validatePhotoUploadAllowed(TenantSubscription sub,\allowbreak  SubscriptionPlan plan,\allowbreak  int currentPhotosInWorkOrder)} \newline - \texttt{validateCompanyCustomerRegistrationAllowed(TenantSubscription sub,\allowbreak  SubscriptionPlan plan)} \newline - \texttt{validateAiReportGenerationAllowed(TenantSubscription sub,\allowbreak  SubscriptionPlan plan,\allowbreak  int currentMonthlyAiReports)} \newline - \texttt{validateMultiWarehouseTransferAllowed(TenantSubscription sub,\allowbreak  SubscriptionPlan plan)} \newline - \texttt{isFeatureEnabled(TenantSubscription sub,\allowbreak  SubscriptionPlan plan,\allowbreak  String featureKey)} \\*
\hline
\textbf{Responsabilidad} & Fiscaliza en memoria que las operaciones y consumos operativos de sedes, colaboradores, órdenes de trabajo, telemetría OBD-II, evidencias fotográficas, clientes jurídicos, informes predictivos con IA y transferencias multi-almacén no rebasen los techos estipulados en el plan contratado lanzando QuotaExceededException ante excesos e inspeccionando módulos avanzados. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Dominio:} StripeWebhookSignatureVerificationService} \\*
\hline
\textbf{Métodos Principales} & - \texttt{verifySignature(String payload,\allowbreak  String signatureHeader,\allowbreak  String secret)} \\*
\hline
\textbf{Responsabilidad} & Realiza la validación criptográfica pura de la firma digital HMAC-SHA256 presente en los encabezados HTTP contra el secreto simétrico del webhook asegurando la autenticidad matemática de los eventos de Stripe. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Dominio:} SubscriptionLifecycleDomainService} \\*
\hline
\textbf{Métodos Principales} & - \texttt{isGracePeriodActive(TenantSubscription sub,\allowbreak  Instant currentTimestamp)} \newline - \texttt{canReactivate(TenantSubscription sub)} \newline - \texttt{evaluateExpirationPolicy(TenantSubscription sub,\allowbreak  Instant currentTimestamp)} \\*
\hline
\textbf{Responsabilidad} & Fiscaliza la vigencia de periodos de gracia tras impagos, verifica condiciones de reactivación contractual y aplica políticas de expiración sobre la membresía del taller. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Servicios de dominio sin estado ubicados en el paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak billing.\allowbreak domain.\allowbreak services.

**Puertos de Repositorio de la Capa de Dominio**

El aislamiento del modelo conceptual respecto a los adaptadores de infraestructura se implementa mediante contratos de repositorio agnósticos. Estos puertos definen las operaciones requeridas para recuperar y persistir el estado de los agregados respetando sus invariantes de consistencia:

En la @tbl:billing-repository-ports se detallan los contratos de repositorio que desacoplan la lógica contractual respecto a los mecanismos de persistencia relacional.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Puertos de Repositorio del Bounded Context SaaS Billing \& Subscriptions} \label{tbl:billing-repository-ports} \\
\hline
\thfirst{Aspecto de Puerto} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Puerto} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Repositorio:} SubscriptionPlanRepository} \\*
\hline
\textbf{Métodos Principales} & - \texttt{save(SubscriptionPlan plan)} \newline - \texttt{findById(PlanId id)} \newline - \texttt{findByStripePriceId(StripePriceId stripePriceId)} \newline - \texttt{findAllActive()} \\*
\hline
\textbf{Responsabilidad de Dominio} & Contrato de persistencia agnóstica para el catálogo maestro de planes comerciales y tarifas de suscripción con recuperación optimizada de planes habilitados. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Repositorio:} TenantSubscriptionRepository} \\*
\hline
\textbf{Métodos Principales} & - \texttt{save(TenantSubscription subscription)} \newline - \texttt{findById(SubscriptionId id)} \newline - \texttt{findByTenantId(TenantId tenantId)} \newline - \texttt{findByStripeSubscriptionId(StripeSubscriptionId stripeSubId)} \newline - \texttt{existsActiveByTenantId(TenantId tenantId)} \\*
\hline
\textbf{Responsabilidad de Dominio} & Contrato de persistencia para los contratos contractuales de membresía activa de talleres mecánicos con soporte de consultas de alta velocidad y verificación de unicidad. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Repositorio:} SaasInvoiceRepository} \\*
\hline
\textbf{Métodos Principales} & - \texttt{save(SaasInvoice invoice)} \newline - \texttt{findById(SaasInvoiceId id)} \newline - \texttt{findByStripeInvoiceId(StripeInvoiceId stripeInvoiceId)} \newline - \texttt{findAllByTenantId(TenantId tenantId)} \\*
\hline
\textbf{Responsabilidad de Dominio} & Contrato de persistencia para el archivo contable de recibos y facturas de suscripción emitidas hacia los talleres abonados. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Repositorio:} StripeWebhookEventRepository} \\*
\hline
\textbf{Métodos Principales} & - \texttt{save(StripeWebhookEvent event)} \newline - \texttt{findByStripeEventId(StripeEventId stripeEventId)} \newline - \texttt{existsByStripeEventId(StripeEventId stripeEventId)} \\*
\hline
\textbf{Responsabilidad de Dominio} & Contrato de persistencia para la bitácora forense de notificaciones asíncronas y verificación determinista de existencia previa para garantizar idempotencia estricta. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Interfaces de salida agnósticas ubicadas en el paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak billing.\allowbreak domain.\allowbreak repositories.

**Taxonomía de Eventos de Dominio de SaaS Billing & Subscriptions**

La propagación de cambios de estado hacia otros Bounded Contexts y la orquestación asíncrona del ciclo de vida de membresías se articula mediante eventos de dominio inmutables derivados del contrato unificado **DomainEvent**. Estos eventos representan sucesos de negocio consumados y se persisten en la tabla Outbox del contexto para garantizar su publicación confiable:

- **Ciclo de vida y activación contractual**: **SubscriptionPlanCreatedEvent**, **TenantSubscriptionActivatedEvent** y **TenantPlanChangedEvent** comunican la publicación de tarifas comerciales, la habilitación operativa de talleres recién suscritos y el ajuste dinámico de cuotas tras migraciones de plan.

- **Continuidad operativa y contingencias de cobranza**: **TenantSubscriptionRenewedEvent**, **TenantSubscriptionPastDueEvent** y **TenantSubscriptionCanceledEvent** informan la extensión regular de la cobertura pagada, el ingreso en periodo de gracia por rechazos bancarios y la suspensión inmediata de accesos por rescisión del servicio.

- **Conciliación contable y liquidaciones**: **SaasInvoicePaidEvent** y **SaasInvoicePaymentFailedEvent** notifican la recaudación monetaria formal o el fracaso transaccional de cobros recurrentes para su registro en los libros financieros de Andeva.

- **Procesamiento de notificaciones de pasarela**: **StripeWebhookProcessedEvent** confirma el procesamiento transaccional e idempotente exitoso de un webhook de Stripe para fines de trazabilidad y auditoría.

En la @tbl:billing-domain-events se sintetiza la taxonomía de los nueve eventos de dominio de SaaS Billing & Subscriptions con sus respectivas cargas útiles y consecuencias intermodulares.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Taxonomía de Eventos de Dominio de SaaS Billing \& Subscriptions} \label{tbl:billing-domain-events} \\
\hline
\thfirst{Aspecto del Evento} & \thcell{Especificación de Carga Útil y Efecto} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Evento} & \thcell{Especificación de Carga Útil y Efecto} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} SubscriptionPlanCreatedEvent \quad (\textit{Emisor:} SubscriptionPlan)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{planId}, \texttt{name}, \texttt{tier}, \texttt{price}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Notifica la publicación formal de un nuevo plan comercial en el catálogo de Andeva para habilitar su venta. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} TenantSubscriptionActivatedEvent \quad (\textit{Emisor:} TenantSubscription)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{subscriptionId}, \texttt{tenantId}, \texttt{planId}, \texttt{expiresAt}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Notifica el alta formal o inicio de prueba gratuita de un taller habilitando sus accesos operativos y sedes en IAM. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} TenantSubscriptionRenewedEvent \quad (\textit{Emisor:} TenantSubscription)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{subscriptionId}, \texttt{tenantId}, \texttt{newPeriodEnd}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Notifica la liquidación exitosa de un ciclo de servicio extendiendo la validez del taller e invalidando la caché de autorización. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} TenantSubscriptionPastDueEvent \quad (\textit{Emisor:} TenantSubscription)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{subscriptionId}, \texttt{tenantId}, \texttt{gracePeriodEnd}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Alerta sobre el impago de un cargo recurrente dando inicio al periodo de tolerancia e instando al taller a regularizar su método de pago. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} TenantSubscriptionCanceledEvent \quad (\textit{Emisor:} TenantSubscription)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{subscriptionId}, \texttt{tenantId}, \texttt{canceledAt}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Comunica la rescisión formal del contrato provocando la revocación inmediata de sesiones activas en IAM y suspensión de servicios. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} TenantPlanChangedEvent \quad (\textit{Emisor:} TenantSubscription)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{subscriptionId}, \texttt{tenantId}, \texttt{oldPlanId}, \texttt{newPlanId}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Notifica la migración hacia un nuevo nivel comercial reajustando de forma dinámica las cuotas de sedes y personal en la plataforma. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} SaasInvoicePaidEvent \quad (\textit{Emisor:} SaasInvoice)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{invoiceId}, \texttt{tenantId}, \texttt{amount}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Notifica la liquidación bancaria formal de un recibo de cobro recurrente consolidando el asiento contable en Andeva. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} SaasInvoicePaymentFailedEvent \quad (\textit{Emisor:} SaasInvoice)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{tenantId}, \texttt{failureReason}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Notifica el rechazo bancario definitivo de un intento de cobro para activar procedimientos de cobranza preventiva. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} StripeWebhookProcessedEvent \quad (\textit{Emisor:} StripeWebhookEvent)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{eventId}, \texttt{eventType}, \texttt{processedAt}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Notifica el procesamiento transaccional e idempotente exitoso de un evento asíncrono emitido por Stripe. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Taxonomía de eventos de dominio del paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak billing.\allowbreak domain.\allowbreak model.\allowbreak events.

**Jerarquía de Excepciones Semánticas de Dominio**

Las anomalías operativas y transgresiones a las invariantes de licenciamiento se canalizan mediante excepciones semánticas no comprobadas derivadas de **BillingDomainException**, la cual especializa la clase abstracta **DomainException** provista en el Bounded Context Shared. Cada excepción encapsula un código legible estandarizado bajo la directiva RFC 7807 y se vincula de manera determinista a un código de estado HTTP para su serialización perimetral:

- **Contingencias de catálogo y localización contractual**: **PlanNotFoundException**, **SubscriptionNotFoundException** y **SaasInvoiceNotFoundException** señalan la ausencia de tarifas, contratos o comprobantes solicitados en las operaciones de consulta.

- **Conflictos de cuota y transgresiones de concurrencia**: **QuotaExceededException** y **DuplicateActiveSubscriptionException** alertan sobre intentos de exceder los techos operativos autorizados o registrar contratos concurrentes para un mismo taller.

- **Vulneraciones de seguridad y fallos de formato telemático**: **InvalidWebhookSignatureException**, **InvalidPlanPricingException**, **SubscriptionPastDueException**, **StripeIntegrationException** y **StripeWebhookProcessingException** deniegan peticiones con firmas criptográficas inválidas, precios monetarios negativos, operaciones fuera de gracia o anomalías telemáticas en la integración con Stripe.

En la @tbl:billing-domain-exceptions se presenta la jerarquía de excepciones semánticas de dominio, detallando sus códigos de error y condiciones de lanzamiento en el modelo.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.8cm} | >{\raggedright\arraybackslash}p{9.6cm} |}
\caption{Excepciones de Dominio y Códigos Semánticos de SaaS Billing \& Subscriptions} \label{tbl:billing-domain-exceptions} \\
\hline
\thfirst{Código de Error Semántico} & \thcell{Condición de Lanzamiento en el Modelo} \\
\hline
\endfirsthead
\hline
\thfirst{Código de Error Semántico} & \thcell{Condición de Lanzamiento en el Modelo} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} BillingDomainException} \\*
\hline
\texttt{ERR\_BILLING\_\allowbreak DOMAIN\_VIOLATION} \newline HTTP 400 Bad Request & Superclase abstracta de contingencias semánticas del modelo de suscripciones que centraliza la estructura del protocolo RFC 7807. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} DuplicateActiveSubscriptionException} \\*
\hline
\texttt{ERR\_DUPLICATE\_\allowbreak ACTIVE\_SUBSCRIPTION} \newline HTTP 409 Conflict & Se intenta registrar o activar una nueva membresía para un taller que ya dispone de una suscripción activa o en periodo de prueba. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} InvalidPlanPricingException} \\*
\hline
\texttt{ERR\_INVALID\_\allowbreak PLAN\_PRICING} \newline HTTP 400 Bad Request & Importes monetarios negativos, ciclos de cobro incompatibles o monedas no soportadas en la definición tarifaria del plan. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} InvalidWebhookSignatureException} \\*
\hline
\texttt{ERR\_INVALID\_\allowbreak WEBHOOK\_SIGNATURE} \newline HTTP 401 Unauthorized & El encabezado Stripe-Signature no coincide con el cálculo matemático HMAC-SHA256 del payload denegando el procesamiento del mensaje. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} PlanNotFoundException} \\*
\hline
\texttt{ERR\_PLAN\_\allowbreak NOT\_FOUND} \newline HTTP 404 Not Found & No se localiza el plan de suscripción solicitado en el catálogo comercial mediante su identificador o código tarifario foráneo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} QuotaExceededException} \\*
\hline
\texttt{ERR\_QUOTA\_\allowbreak EXCEEDED} \newline HTTP 403 Forbidden & Se intenta crear una nueva sucursal física o registrar personal activo excediendo los techos permitidos por el plan vigente del taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} SaasInvoiceNotFoundException} \\*
\hline
\texttt{ERR\_SAAS\_INVOICE\_\allowbreak NOT\_FOUND} \newline HTTP 404 Not Found & No se localiza el comprobante de cobro recurrente solicitado en el repositorio financiero mediante el identificador provisto. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} StripeIntegrationException} \\*
\hline
\texttt{ERR\_STRIPE\_\allowbreak INTEGRATION} \newline HTTP 502 Bad Gateway & Anomalías de red, interrupciones telemáticas o fallos no recuperables en la comunicación con los servicios externos de Stripe. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} StripeWebhookProcessingException} \\*
\hline
\texttt{ERR\_STRIPE\_\allowbreak WEBHOOK\_PROCESSING} \newline HTTP 422 Unprocessable Entity & Anomalía sintáctica o estructural durante la deserialización y análisis del cuerpo JSON del evento asíncrono recibido de Stripe. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} SubscriptionNotFoundException} \\*
\hline
\texttt{ERR\_SUBSCRIPTION\_\allowbreak NOT\_FOUND} \newline HTTP 404 Not Found & No se localiza un contrato de membresía asociado al identificador único o al taller automotriz consultado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} SubscriptionPastDueException} \\*
\hline
\texttt{ERR\_SUBSCRIPTION\_\allowbreak PAST\_DUE} \newline HTTP 402 Payment Required & El taller automotriz con cobros reiteradamente rechazados intenta ejecutar operaciones fuera de su periodo de gracia contractual. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Excepciones semánticas del paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak billing.\allowbreak domain.\allowbreak exceptions.

El diseño táctico de la capa de dominio de SaaS Billing & Subscriptions garantiza el desacoplamiento estricto entre el modelo de negocio B2B de la compañía Andeva y la operativa tributaria interna de los talleres mecánicos. Al erigir fronteras transaccionales limpias, el sistema evita que las particularidades fiscales peruanas interfieran con las reglas de suscripción internacional, permitiendo escalar el esquema de monetización hacia nuevos mercados sin alterar la lógica de facturación de servicios automotrices.

Asimismo, la estrategia de seguridad adoptada neutraliza las vulnerabilidades asociadas al tratamiento de datos bancarios confidenciales. Al relegar la captura de medios de pago a la infraestructura certificada de Stripe y custodiar exclusivamente identificadores tokenizados inmutables, la plataforma satisface con rigor los estándares de cumplimiento PCI-DSS Nivel 1, reduciendo la superficie de ataque y blindando la confidencialidad financiera de los talleres abonados.

Finalmente, la orquestación entre agregados persistidos en almacenamiento relacional y la aceleración de consultas mediante Caffeine Cache resuelve de manera eficiente el compromiso entre consistencia e inmediatez de respuesta. Las validaciones frecuentes de cuotas operativas se resuelven en memoria local sin penalizar la base de datos, mientras que los eventos de dominio y webhooks garantizan la invalidación reactiva de la memoria volátil ante cualquier alteración en el estado de las membresías.

#### 2.6.8.2. Interface Layer

La Capa de Interfaz del Bounded Context SaaS Billing & Subscriptions actúa como el adaptador primario perimetral bajo el paquete canónico **com.andeva.atelier.platform.billing.interfaces**. Su cometido consiste en canalizar y gobernar las interacciones externas procedentes de portales administrativos web, dispositivos móviles de taller y la pasarela telemática internacional Stripe, traduciendo peticiones HTTP y notificaciones asíncronas en comandos transaccionales y consultas deterministas.

Al situarse en la frontera perimetral de monetización y licenciamiento de la plataforma, los componentes de esta capa responden a cuatro principios rectores de arquitectura:

- **Desacoplamiento perimetral y semántica RESTful estricta:** Exposición de recursos sustentada exclusivamente en sustantivos en plural, aislamiento de detalles de almacenamiento y aplicación rigurosa de verbos HTTP idempotentes para consultas y modificaciones, protegiendo las invariantes del modelo contractual.

- **Mitigación integral de riesgos y blindaje PCI-DSS Nivel 1:** El backend no recopila ni persiste números de tarjetas de crédito o códigos de validación bancarios, delegando la captura de credenciales a componentes certificados de Stripe en el frontend y gestionando exclusivamente identificadores tokenizados inmutables.

- **Ingesta asíncrona de webhooks con firma criptográfica e idempotencia:** Verificación matemática simétrica HMAC-SHA256 sobre las notificaciones telemáticas de Stripe con tolerancia temporal de 300 segundos y deduplicación relacional estricta, descartando reintentos de red durante contingencias de conectividad.

- **Fiscalización de cuotas operativas en memoria ultra rápida:** Gobernanza de techos de consumo mediante una Fachada de Contexto Abierto respaldada por memoria volátil Caffeine Cache, resolviendo consultas de autorización intermodular con latencia inferior a 0.05 milisegundos.

En la @tbl:billing-interface-types se presenta el catálogo taxonómico consolidado de los componentes tácticos que integran la Capa de Interfaz de SaaS Billing & Subscriptions, detallando sus categorías, paquetes canónicos y responsabilidades arquitectónicas.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo Consolidado de la Capa de Interfaz de SaaS Billing \& Subscriptions} \label{tbl:billing-interface-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endhead
Subscription\allowbreak Plans\allowbreak Controller & Endpoints REST para la consulta pública y administración de catálogo de planes comerciales, tarifas y cuotas de consumo paquetizadas. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca SubscriptionPlanCommandService y SubscriptionPlanQueryService. Utiliza SubscriptionPlanResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Tenant\allowbreak Subscriptions\allowbreak Controller & Endpoints REST para consulta del estado contractual del taller suscrito, sesiones de Stripe Checkout, portal de clientes y cancelaciones. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca TenantSubscriptionCommandService y TenantSubscriptionQueryService. Utiliza TenantSubscriptionResourceAssembler y CheckoutSessionResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Saas\allowbreak Invoices\allowbreak Controller & Endpoints REST para consulta histórica de comprobantes de cobro del SaaS y redirección segura hacia facturas alojadas en Stripe. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca SaasInvoiceQueryService. Utiliza SaasInvoiceResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Stripe\allowbreak Webhooks\allowbreak Controller & Endpoint perimetral de alta concurrencia receptor de eventos asíncronos emitidos por Stripe con validación HMAC-SHA256 e idempotencia. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca StripeWebhookSignatureVerificationService y StripeWebhookCommandService. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Create\allowbreak Subscription\allowbreak Plan\allowbreak Request & Carga útil inmutable para dar de alta un nuevo plan de suscripción en el catálogo comercial de Andeva. \\*
\hline
\textbf{Categoría} & Recurso REST de Petición \\*
\hline
\textbf{Relaciones} & Validado mediante Jakarta Bean Validation. Mapeado por SubscriptionPlanResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Update\allowbreak Subscription\allowbreak Plan\allowbreak Request & Carga útil inmutable para actualizar tarifas, cuotas operativas y características funcionales de un plan existente. \\*
\hline
\textbf{Categoría} & Recurso REST de Petición \\*
\hline
\textbf{Relaciones} & Validado mediante Jakarta Bean Validation. Mapeado a comando de actualización. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Create\allowbreak Checkout\allowbreak Session\allowbreak Request & Parámetros requeridos para inicializar una sesión de pago alojada en Stripe Checkout para contratación o mejora de plan. \\*
\hline
\textbf{Categoría} & Recurso REST de Petición \\*
\hline
\textbf{Relaciones} & Mapeado a comando de checkout por TenantSubscriptionCommandService. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Create\allowbreak Customer\allowbreak Portal\allowbreak Session\allowbreak Request & Solicitud de generación de enlace interactivo seguro hacia el portal de autogestión financiera de Stripe. \\*
\hline
\textbf{Categoría} & Recurso REST de Petición \\*
\hline
\textbf{Relaciones} & Procesado por TenantSubscriptionCommandService para invocar la API de Stripe. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Change\allowbreak Subscription\allowbreak Plan\allowbreak Request & Solicitud de migración o cambio de nivel comercial de membresía para un taller automotriz. \\*
\hline
\textbf{Categoría} & Recurso REST de Petición \\*
\hline
\textbf{Relaciones} & Validado y transformado en comando por TenantSubscriptionCommandService. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Cancel\allowbreak Subscription\allowbreak Request & Petición para solicitar la cancelación programada o rescisión inmediata de la suscripción del taller. \\*
\hline
\textbf{Categoría} & Recurso REST de Petición \\*
\hline
\textbf{Relaciones} & Mapeado a CancelSubscriptionCommand por TenantSubscriptionCommandService. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Plan\allowbreak Feature\allowbreak Request & Característica modular individual para el catálogo de funcionalidades empaquetadas en un plan comercial. \\*
\hline
\textbf{Categoría} & Recurso REST de Petición \\*
\hline
\textbf{Relaciones} & Componente subordinado de CreateSubscriptionPlanRequest y UpdateSubscriptionPlanRequest. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Subscription\allowbreak Plan\allowbreak Resource & Proyección REST pública y administrativa con los detalles, tarifas y cuotas paquetizadas en un plan comercial. \\*
\hline
\textbf{Categoría} & Recurso REST de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por SubscriptionPlanResourceAssembler a partir del agregado SubscriptionPlan. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Tenant\allowbreak Subscription\allowbreak Resource & Representación consolidada de la membresía activa del taller con vigencia temporal y cuotas operativas vigentes. \\*
\hline
\textbf{Categoría} & Recurso REST de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por TenantSubscriptionResourceAssembler componiendo datos de suscripción y plan. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Tenant\allowbreak Quota\allowbreak Limits\allowbreak Resource & Proyección REST pública inmutable de techos autorizados de consumo para despliegue en clientes de plataforma. \\*
\hline
\textbf{Categoría} & Recurso REST de Respuesta \\*
\hline
\textbf{Relaciones} & Derivado de las cuotas operativas activas de la membresía del taller. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Saas\allowbreak Invoice\allowbreak Resource & Detalle financiero exhaustivo de comprobante de cobro emitido por el SaaS con enlaces de descarga de Stripe. \\*
\hline
\textbf{Categoría} & Recurso REST de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por SaasInvoiceResourceAssembler a partir del agregado SaasInvoice. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Saas\allowbreak Invoice\allowbreak Summary\allowbreak Resource & Proyección resumida de facturación SaaS optimizada para cuadrículas contables de alta velocidad. \\*
\hline
\textbf{Categoría} & Recurso REST de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por SaasInvoiceResourceAssembler para listados masivos organizados por lotes. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Checkout\allowbreak Session\allowbreak Resource & Respuesta con enlace URL seguro de Stripe Checkout e identificador de sesión para redirección interactiva de pago. \\*
\hline
\textbf{Categoría} & Recurso REST de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por CheckoutSessionResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Customer\allowbreak Portal\allowbreak Session\allowbreak Resource & Respuesta con enlace URL temporal firmado hacia el Stripe Customer Portal para gestión autónoma de tarjetas. \\*
\hline
\textbf{Categoría} & Recurso REST de Respuesta \\*
\hline
\textbf{Relaciones} & Generado por TenantSubscriptionCommandService a través de la pasarela Stripe. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Plan\allowbreak Feature\allowbreak Resource & Representación REST inmutable de una característica modular autorizada en el catálogo comercial. \\*
\hline
\textbf{Categoría} & Recurso REST de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por PlanFeatureResourceAssembler desde la entidad PlanFeature. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Stripe\allowbreak Webhook\allowbreak Acknowledgment\allowbreak Resource & Acuse liviano inmutable de confirmación perimetral emitido de inmediato hacia la infraestructura de Stripe. \\*
\hline
\textbf{Categoría} & Recurso REST de Respuesta \\*
\hline
\textbf{Relaciones} & Retornado por StripeWebhooksController tras verificar firma e idempotencia. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Tenant\allowbreak Subscription\allowbreak Status\allowbreak Dto & Contrato inmutable que expone el estado de membresía, vigencia y nivel de plan para otros Bounded Contexts. \\*
\hline
\textbf{Categoría} & DTO de Integración de Fachada \\*
\hline
\textbf{Relaciones} & Retornado por SubscriptionContextFacade para gobernanza intermodular. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak acl.\allowbreak dto} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Tenant\allowbreak Quota\allowbreak Limits\allowbreak Dto & Contrato inmutable de techos operativos autorizados de sucursales, personal activo y órdenes de trabajo. \\*
\hline
\textbf{Categoría} & DTO de Integración de Fachada \\*
\hline
\textbf{Relaciones} & Retornado por SubscriptionContextFacade y utilizado en validaciones sincrónicas en memoria. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak acl.\allowbreak dto} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Feature\allowbreak Entitlement\allowbreak Dto & Contrato inmutable que dictamina derechos de acceso y límites específicos para características funcionales avanzadas. \\*
\hline
\textbf{Categoría} & DTO de Integración de Fachada \\*
\hline
\textbf{Relaciones} & Retornado por checkFeatureEntitlement en SubscriptionContextFacade. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak acl.\allowbreak dto} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Subscription\allowbreak Plan\allowbreak Resource\allowbreak Assembler & Componente de transformación bidireccional entre agregados, comandos y recursos DTO de planes comerciales. \\*
\hline
\textbf{Categoría} & Ensamblador de Recursos REST \\*
\hline
\textbf{Relaciones} & Depende de PlanFeatureResourceAssembler. Utilizado por SubscriptionPlansController. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Tenant\allowbreak Subscription\allowbreak Resource\allowbreak Assembler & Ensamblador que combina datos contractuales y del catálogo comercial para conformar recursos de membresía. \\*
\hline
\textbf{Categoría} & Ensamblador de Recursos REST \\*
\hline
\textbf{Relaciones} & Utilizado por TenantSubscriptionsController. Soporta sobrecarga optimizada con datos de caché. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Saas\allowbreak Invoice\allowbreak Resource\allowbreak Assembler & Ensamblador que proyecta comprobantes contables hacia recursos detallados y resúmenes para cuadrículas. \\*
\hline
\textbf{Categoría} & Ensamblador de Recursos REST \\*
\hline
\textbf{Relaciones} & Utilizado por SaasInvoicesController a partir de SaasInvoice. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Checkout\allowbreak Session\allowbreak Resource\allowbreak Assembler & Ensamblador que estructura la respuesta con enlace URL e identificador de sesión para Stripe Checkout. \\*
\hline
\textbf{Categoría} & Ensamblador de Recursos REST \\*
\hline
\textbf{Relaciones} & Utilizado por TenantSubscriptionsController para inicializar pagos seguros. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Plan\allowbreak Feature\allowbreak Resource\allowbreak Assembler & Ensamblador que transforma colecciones de entidades de características modulares en listas inmutables de recursos. \\*
\hline
\textbf{Categoría} & Ensamblador de Recursos REST \\*
\hline
\textbf{Relaciones} & Invocado por SubscriptionPlanResourceAssembler. Maneja colecciones nulas o vacías de forma segura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Subscription\allowbreak Context\allowbreak Facade & Fachada de Contexto Abierto en memoria para validación sub-milisegundo de vigencia y cuotas operativas desde otros contextos. \\*
\hline
\textbf{Categoría} & Fachada de Contexto Abierto \\*
\hline
\textbf{Relaciones} & Implementada por SubscriptionContextFacadeImpl en la capa de aplicación. Integrada con Caffeine In-Memory Cache. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Tenant\allowbreak Plan\allowbreak Changed\allowbreak Integration\allowbreak Event & Notifica a la plataforma la migración de plan tarifario y actualización de cuotas para sincronización intermodular. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. Consumido por IAM, MRO, HR e IoT. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Tenant\allowbreak Quota\allowbreak Limits\allowbreak Updated\allowbreak Integration\allowbreak Event & Notifica la reconfiguración de techos operativos autorizados para su actualización en memoria volátil. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. Consumido por IAM, MRO y HR. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Tenant\allowbreak Subscription\allowbreak Activated\allowbreak Integration\allowbreak Event & Notifica la activación o formalización de pago de la suscripción para concesión irrestricta de acceso operativo. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. Consumido por IAM y API Gateway. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Tenant\allowbreak Subscription\allowbreak Canceled\allowbreak Integration\allowbreak Event & Notifica la rescisión o cancelación programada de la membresía del taller para revocación de servicios. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. Consumido por IAM y Notificaciones. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Tenant\allowbreak Subscription\allowbreak Past\allowbreak Due\allowbreak Integration\allowbreak Event & Notifica cobros bancarios fallidos e inicio del periodo de gracia para emisión de alertas administrativas. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. Consumido por IAM y Notificaciones. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Billing\allowbreak Exception\allowbreak Handler & Interceptor perimetral que transforma excepciones de dominio en respuestas estandarizadas RFC 7807 Problem Details. \\*
\hline
\textbf{Categoría} & Manejador Global de Excepciones \\*
\hline
\textbf{Relaciones} & Anotado con RestControllerAdvice. Captura BillingDomainException y sus especializaciones. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak advice} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Catálogo taxonómico consolidado de componentes de la Capa de Interfaz pertenecientes a los subpaquetes rest, rest.resources.requests, rest.resources.responses, rest.transform, rest.advice, acl, acl.dto y events de com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak billing.\allowbreak interfaces.

**Controladores REST y Endpoints de Comunicación de SaaS Billing & Subscriptions**

El acceso perimetral a las capacidades de suscripción y facturación se estructura a través de cuatro controladores REST especializados, desacoplados según el perfil del consumidor y el canal de comunicación:

- **SubscriptionPlansController**: Gestiona el catálogo de planes comerciales de software comercializados por Andeva. Expone endpoints públicos y administrativos para listar paquetes tarifarios, consultar techos de consumo y dar de alta nuevas opciones comerciales bajo control de acceso estricto para administradores de la plataforma.

- **TenantSubscriptionsController**: Centraliza el ciclo de vida de la membresía activa de cada taller automotriz. Permite inspeccionar el estado contractual vigente, inicializar sesiones de pago seguras en Stripe Checkout para contrataciones o migraciones, generar enlaces interactivos al portal de clientes, tramitar cancelaciones de servicio y procesar cambios de plan tarifario.

- **SaasInvoicesController**: Provee a los talleres mecánicos acceso auditado a sus comprobantes de facturación corporativa emitida por Andeva, soportando listados históricos clasificados por periodos, detalle contable unitario y redirecciones temporales seguras hacia los comprobantes PDF oficiales custodiados en la infraestructura de Stripe.

- **StripeWebhooksController**: Punto de entrada de alta disponibilidad para la recepción de eventos telemáticos emitidos por Stripe. Verifica la autenticidad criptográfica del mensaje entrante, salvaguarda la idempotencia transaccional y delega el procesamiento hacia la capa de aplicación sin introducir bloqueos en la comunicación perimetral.

En la @tbl:billing-controllers-and-endpoints se detallan los contratos de comunicación, rutas canónicas, verbos HTTP, códigos de respuesta y restricciones de seguridad de los cuatro controladores perimetrales.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Controladores REST y Endpoints de Comunicación de SaaS Billing \& Subscriptions} \label{tbl:billing-controllers-and-endpoints} \\
\hline
\thfirst{Recurso de Petición} & \thcell{Código y Respuesta HTTP} \\
\hline
\endfirsthead
\hline
\thfirst{Recurso de Petición} & \thcell{Código y Respuesta HTTP} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} Subscription\allowbreak Plans\allowbreak Controller} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak billing/\allowbreak plans}} \\*
\hline
\textbf{Petición:} Ninguna & \textbf{Respuesta:} 200 OK (\texttt{List<Subscription\allowbreak Plan\allowbreak Resource>}) \\*
\hline
\textbf{Seguridad y Rol} & Público o Autenticado con \texttt{ROLE\_SUPER\_ADMIN}, \texttt{ROLE\_TENANT\_ADMIN} o \texttt{ROLE\_WORKSHOP\_OWNER} \\*
\hline
\textbf{Responsabilidad} & Recupera el catálogo de planes comerciales activos disponibles para suscripción en la plataforma Atelier. \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak billing/\allowbreak plans/\allowbreak \{id\}}} \\*
\hline
\textbf{Petición:} Path Variable \texttt{id} & \textbf{Respuesta:} 200 OK (\texttt{Subscription\allowbreak Plan\allowbreak Resource}) \\*
\hline
\textbf{Seguridad y Rol} & Público o Autenticado \\*
\hline
\textbf{Responsabilidad} & Obtiene la especificación completa de un plan tarifario, cuotas paquetizadas y funcionalidades habilitadas. \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak billing/\allowbreak plans}} \\*
\hline
\textbf{Petición:} \texttt{Create\allowbreak Subscription\allowbreak Plan\allowbreak Request} & \textbf{Respuesta:} 201 CREATED (\texttt{Subscription\allowbreak Plan\allowbreak Resource}) con cabecera \texttt{Location} \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con rol excluyente \texttt{ROLE\_SUPER\_ADMIN} \\*
\hline
\textbf{Responsabilidad} & Alta administrativa de un nuevo paquete comercial vinculado con un identificador de precio en Stripe. \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{PUT} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak billing/\allowbreak plans/\allowbreak \{id\}}} \\*
\hline
\textbf{Petición:} \texttt{Update\allowbreak Subscription\allowbreak Plan\allowbreak Request} & \textbf{Respuesta:} 200 OK (\texttt{Subscription\allowbreak Plan\allowbreak Resource}) \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con rol excluyente \texttt{ROLE\_SUPER\_ADMIN} \\*
\hline
\textbf{Responsabilidad} & Actualiza cuotas operativas, denominación comercial y módulos autorizados preservando suscripciones en curso. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} Tenant\allowbreak Subscriptions\allowbreak Controller} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak billing/\allowbreak subscriptions/\allowbreak me}} \\*
\hline
\textbf{Petición:} Ninguna (Contexto JWT) & \textbf{Respuesta:} 200 OK (\texttt{Tenant\allowbreak Subscription\allowbreak Resource}) \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con roles \texttt{ROLE\_TENANT\_ADMIN} o \texttt{ROLE\_WORKSHOP\_OWNER} \\*
\hline
\textbf{Responsabilidad} & Consulta el contrato activo del taller autenticado, estado contable, periodo vigente y consumo de cuotas. \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak billing/\allowbreak subscriptions/\allowbreak checkout-session}} \\*
\hline
\textbf{Petición:} \texttt{Create\allowbreak Checkout\allowbreak Session\allowbreak Request} & \textbf{Respuesta:} 200 OK (\texttt{Checkout\allowbreak Session\allowbreak Resource}) \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con roles \texttt{ROLE\_TENANT\_ADMIN} o \texttt{ROLE\_WORKSHOP\_OWNER} \\*
\hline
\textbf{Responsabilidad} & Genera sesión alojada en Stripe Checkout para afiliarse a un plan o formalizar una migración de nivel comercial. \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak billing/\allowbreak subscriptions/\allowbreak customer-portal}} \\*
\hline
\textbf{Petición:} \texttt{Create\allowbreak Customer\allowbreak Portal\allowbreak Session\allowbreak Request} & \textbf{Respuesta:} 200 OK (\texttt{Customer\allowbreak Portal\allowbreak Session\allowbreak Resource}) \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con roles \texttt{ROLE\_TENANT\_ADMIN} o \texttt{ROLE\_WORKSHOP\_OWNER} \\*
\hline
\textbf{Responsabilidad} & Genera sesión interactiva en Stripe Customer Portal para actualizar tarjeta de crédito y consultar facturas. \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak billing/\allowbreak subscriptions/\allowbreak change-plan}} \\*
\hline
\textbf{Petición:} \texttt{Change\allowbreak Subscription\allowbreak Plan\allowbreak Request} & \textbf{Respuesta:} 200 OK (\texttt{Tenant\allowbreak Subscription\allowbreak Resource}) \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con roles \texttt{ROLE\_TENANT\_ADMIN} o \texttt{ROLE\_WORKSHOP\_OWNER} \\*
\hline
\textbf{Responsabilidad} & Procesa la migración a un nuevo nivel tarifario coordinando el prorrateo financiero con Stripe. \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak billing/\allowbreak subscriptions/\allowbreak cancel}} \\*
\hline
\textbf{Petición:} \texttt{Cancel\allowbreak Subscription\allowbreak Request} & \textbf{Respuesta:} 200 OK (\texttt{Tenant\allowbreak Subscription\allowbreak Resource}) o 204 NO CONTENT \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con roles \texttt{ROLE\_TENANT\_ADMIN} o \texttt{ROLE\_WORKSHOP\_OWNER} \\*
\hline
\textbf{Responsabilidad} & Programa la cancelación al expirar el ciclo de cobro vigente o rescinde inmediatamente el servicio. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} Saas\allowbreak Invoices\allowbreak Controller} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak billing/\allowbreak invoices}} \\*
\hline
\textbf{Petición:} Parámetros de consulta por bloques & \textbf{Respuesta:} 200 OK (\texttt{List<Saas\allowbreak Invoice\allowbreak Summary\allowbreak Resource>}) \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con roles administrativos y contables del taller \\*
\hline
\textbf{Responsabilidad} & Lista el historial cronológico de facturas de suscripción emitidas por Andeva al taller mecánico. \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak billing/\allowbreak invoices/\allowbreak \{id\}}} \\*
\hline
\textbf{Petición:} Path Variable \texttt{id} & \textbf{Respuesta:} 200 OK (\texttt{Saas\allowbreak Invoice\allowbreak Resource}) \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con roles administrativos y contables del taller \\*
\hline
\textbf{Responsabilidad} & Obtiene el detalle financiero exhaustivo de un comprobante de facturación de suscripción específico. \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak billing/\allowbreak invoices/\allowbreak \{id\}/\allowbreak pdf}} \\*
\hline
\textbf{Petición:} Path Variable \texttt{id} & \textbf{Respuesta:} 302 FOUND con cabecera \texttt{Location} \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con roles administrativos del taller \\*
\hline
\textbf{Responsabilidad} & Redirige hacia el enlace seguro y firmado temporalmente por Stripe para descarga del PDF contable oficial. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} Stripe\allowbreak Webhooks\allowbreak Controller} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak billing/\allowbreak webhooks/\allowbreak stripe}} \\*
\hline
\textbf{Petición:} Raw JSON en cuerpo & \textbf{Respuesta:} 200 OK (\texttt{Stripe\allowbreak Webhook\allowbreak Acknowledgment\allowbreak Resource}) \\*
\hline
\textbf{Seguridad y Rol} & Validación criptográfica simétrica HMAC-SHA256 mediante cabecera \texttt{Stripe-Signature} \\*
\hline
\textbf{Responsabilidad} & Procesa eventos asíncronos de cobro de facturas y ciclo de vida de Stripe con idempotencia estricta. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación perimetral de rutas, verbos HTTP, códigos de respuesta y seguridad de SaaS Billing \& Subscriptions.

**Recursos DTO de Petición y Respuesta de Facturación y Membresías**

La transferencia de información a través del perímetro HTTP se instrumenta mediante objetos de transferencia de datos inmutables, modelados como registros de Java 21. Esta estrategia erradica la mutabilidad accidental y centraliza las validaciones sintácticas de entrada mediante anotaciones declarativas de Jakarta Bean Validation:

- **Contratos de Petición**: Estructuran las intenciones del usuario validando la presencia obligatoria de identificadores de precio de Stripe, denominaciones comerciales no vacías, importes monetarios no negativos y restricciones de formato sobre direcciones web de retorno seguro.

- **Contratos de Respuesta**: Encapsulan proyecciones optimizadas para clientes web y móviles, denormalizando denominaciones de plan y techos de cuota operativa para evitar viajes de red redundantes y omitiendo campos nulos mediante políticas de serialización selectiva.

- **Contratos DTO de Fachada**: Definen estructuras inmutables de intercambio en memoria para abastecer a otros Bounded Contexts con datos de membresía, cuotas vigentes y derechos de uso funcional sin acoplamiento a entidades internas.

En la @tbl:billing-resources-dtos se especifican los atributos estructurales y las reglas de validación declarativa que rigen los recursos DTO de petición, respuesta y contratos de fachada de este contexto.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Recursos DTO de Entrada y Salida del Bounded Context SaaS Billing \& Subscriptions} \label{tbl:billing-resources-dtos} \\
\hline
\thfirst{Aspecto de Recurso} & \thcell{Especificación de Atributos e Integridad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Recurso} & \thcell{Especificación de Atributos e Integridad} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Petición:} Create\allowbreak Subscription\allowbreak Plan\allowbreak Request} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\*
\hline
\textbf{Atributos Principales} & \texttt{stripePriceId}, \texttt{name}, \texttt{tier}, \texttt{price}, \texttt{currency}, \texttt{billingCycle}, \texttt{quotaLimits}, \texttt{features} \\*
\hline
\textbf{Validación de Integridad} & Anotación \texttt{@NotBlank} y formato \texttt{@Pattern(regexp = "\textasciicircum price\_[a-zA-Z0-9]+\$")} para stripePriceId, \texttt{@NotBlank} y \texttt{@Size(min = 3, max = 100)} para name, \texttt{@Pattern} con valores GO, PRO, MAX o ENTERPRISE para tier, importe no negativo \texttt{@DecimalMin("0.0")} con precisión \texttt{@Digits(integer = 10, fraction = 2)}, código de moneda ISO \texttt{@Size(min = 3, max = 3)}, ciclo de facturación \texttt{@Pattern} con MONTHLY o YEARLY, cuotas validadas (\texttt{@Valid}) y lista de funcionalidades con validación anidada. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Petición:} Update\allowbreak Subscription\allowbreak Plan\allowbreak Request} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\*
\hline
\textbf{Atributos Principales} & \texttt{name}, \texttt{price}, \texttt{billingCycle}, \texttt{quotaLimits}, \texttt{isActive}, \texttt{features} \\*
\hline
\textbf{Validación de Integridad} & \texttt{@NotBlank} y \texttt{@Size(min = 3, max = 100)} para denominación comercial, \texttt{@NotNull} y \texttt{@DecimalMin("0.0")} para precio, ciclo de facturación \texttt{@NotBlank} con MONTHLY o YEARLY, objeto de cuotas obligatorias \texttt{@NotNull} con validación anidada (\texttt{@Valid}), bandera booleana para disponibilidad de contratación y lista de características funcionales validadas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Petición:} Create\allowbreak Checkout\allowbreak Session\allowbreak Request} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\*
\hline
\textbf{Atributos Principales} & \texttt{planId}, \texttt{successUrl}, \texttt{cancelUrl} \\*
\hline
\textbf{Validación de Integridad} & Identificador \texttt{@NotNull} de plan comercial UUID, URLs de retorno obligatorias \texttt{@NotBlank} y validadas mediante expresión regular \texttt{@Pattern(regexp = "\textasciicircum https?://.*")} para garantizar protocolo web seguro. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Petición:} Create\allowbreak Customer\allowbreak Portal\allowbreak Session\allowbreak Request} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\*
\hline
\textbf{Atributos Principales} & \texttt{returnUrl} \\*
\hline
\textbf{Validación de Integridad} & Dirección web obligatoria \texttt{@NotBlank} con patrón \texttt{@Pattern(regexp = "\textasciicircum https?://.*")} que valida destino seguro de redirección al culminar gestiones en Stripe Customer Portal. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Petición:} Change\allowbreak Subscription\allowbreak Plan\allowbreak Request} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\*
\hline
\textbf{Atributos Principales} & \texttt{newPlanId}, \texttt{immediateProration} \\*
\hline
\textbf{Validación de Integridad} & Identificador obligatorio \texttt{@NotNull} del nuevo plan comercial UUID y bandera booleana para habilitar prorrateo financiero inmediato. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Petición:} Cancel\allowbreak Subscription\allowbreak Request} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\*
\hline
\textbf{Atributos Principales} & \texttt{cancelImmediately}, \texttt{cancellationReason} \\*
\hline
\textbf{Validación de Integridad} & Indicador booleano de cancelación inmediata o al fin de ciclo y texto descriptivo de motivo con límite \texttt{@Size(max = 500)}. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Petición:} Plan\allowbreak Feature\allowbreak Request} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\*
\hline
\textbf{Atributos Principales} & \texttt{featureKey}, \texttt{name}, \texttt{description}, \texttt{isEnabled} \\*
\hline
\textbf{Validación de Integridad} & Clave técnica alfanumérica \texttt{@NotBlank} con patrón \texttt{@Pattern(regexp = "\textasciicircum[A-Z0-9\_]+\$")}, nombre obligatorio \texttt{@Size(min = 3, max = 100)}, descripción opcional con límite \texttt{@Size(max = 255)} y bandera booleana de habilitación. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Respuesta:} Subscription\allowbreak Plan\allowbreak Resource} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{stripePriceId}, \texttt{name}, \texttt{tier}, \texttt{price}, \texttt{currency}, \texttt{billingCycle}, \texttt{quotaLimits}, \texttt{features}, \texttt{isActive}, \texttt{createdAt}, \texttt{updatedAt} \\*
\hline
\textbf{Validación de Integridad} & Registro Java 21 inmutable serializado como JSON excluyendo nulos (\texttt{@JsonInclude(NON\_NULL)}). Proyecta tipos primitivos, marcas temporales UTC Instant y listas inmutables de PlanFeatureResource. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Respuesta:} Tenant\allowbreak Subscription\allowbreak Resource} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{tenantId}, \texttt{planId}, \texttt{planName}, \texttt{tier}, \texttt{status}, \texttt{currentPeriodStart}, \texttt{currentPeriodEnd}, \texttt{cancelAtPeriodEnd}, \texttt{trialEndDate}, \texttt{quotaLimits}, \texttt{isAccessGranted} \\*
\hline
\textbf{Validación de Integridad} & Registro Java 21 inmutable con marcas temporales UTC Instant, identificadores UUID y cuotas operativas consolidadas para gobernanza del taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Respuesta:} Tenant\allowbreak Quota\allowbreak Limits\allowbreak Resource} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\*
\hline
\textbf{Atributos Principales} & \texttt{maxBranches}, \texttt{maxActiveStaff}, \texttt{iotTelemetryEnabled}, \texttt{aiDiagnosticsEnabled}, \texttt{maxMonthlyWorkOrders} \\*
\hline
\textbf{Validación de Integridad} & Registro inmutable que proyecta los techos cuantitativos autorizados de sedes, mecánicos y órdenes mecánicas para despliegue perimetral en paneles de control. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Respuesta:} Saas\allowbreak Invoice\allowbreak Resource} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{subscriptionId}, \texttt{tenantId}, \texttt{stripeInvoiceId}, \texttt{amountPaid}, \texttt{currency}, \texttt{status}, \texttt{invoicePdfUrl}, \texttt{hostedInvoiceUrl}, \texttt{paidAt}, \texttt{createdAt} \\*
\hline
\textbf{Validación de Integridad} & Registro inmutable que expone importes monetarios amortizados, enlaces directos a activos digitales en Stripe y marca de tiempo UTC de liquidación. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Respuesta:} Saas\allowbreak Invoice\allowbreak Summary\allowbreak Resource} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{stripeInvoiceId}, \texttt{amountPaid}, \texttt{currency}, \texttt{status}, \texttt{paidAt} \\*
\hline
\textbf{Validación de Integridad} & Proyección liviana inmutable optimizada para cuadrículas de consulta contable masiva en paneles administrativos del taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Respuesta:} Checkout\allowbreak Session\allowbreak Resource} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\*
\hline
\textbf{Atributos Principales} & \texttt{checkoutUrl}, \texttt{sessionId} \\*
\hline
\textbf{Validación de Integridad} & Registro inmutable con localizador URL firmado de Stripe Checkout e identificador de sesión telemática para redirección frontend. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Respuesta:} Customer\allowbreak Portal\allowbreak Session\allowbreak Resource} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\*
\hline
\textbf{Atributos Principales} & \texttt{portalUrl} \\*
\hline
\textbf{Validación de Integridad} & Registro inmutable con enlace URL temporal firmado hacia el Stripe Customer Portal para autogestión de medios de pago y comprobantes. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Respuesta:} Plan\allowbreak Feature\allowbreak Resource} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{featureKey}, \texttt{name}, \texttt{description}, \texttt{isEnabled} \\*
\hline
\textbf{Validación de Integridad} & Registro inmutable que proyecta el identificador universal, clave de funcionalidad alfanumérica, denominación comercial y estado de habilitación. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Respuesta:} Stripe\allowbreak Webhook\allowbreak Acknowledgment\allowbreak Resource} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\*
\hline
\textbf{Atributos Principales} & \texttt{received}, \texttt{eventId}, \texttt{status}, \texttt{timestamp} \\*
\hline
\textbf{Validación de Integridad} & Confirmación ligera serializada de inmediato hacia los servidores de Stripe con acuse booleano, identificador, estado y marca de tiempo UTC. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{DTO de Integración de Fachada:} Tenant\allowbreak Subscription\allowbreak Status\allowbreak Dto} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak acl.\allowbreak dto} \\*
\hline
\textbf{Atributos Principales} & \texttt{tenantId}, \texttt{planName}, \texttt{tier}, \texttt{status}, \texttt{isActive}, \texttt{currentPeriodEnd}, \texttt{cancelAtPeriodEnd} \\*
\hline
\textbf{Validación de Integridad} & Contrato DTO inmutable consumido por otros Bounded Contexts para comprobar estado contractual y vigencia sin acoplamiento a entidades internas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{DTO de Integración de Fachada:} Tenant\allowbreak Quota\allowbreak Limits\allowbreak Dto} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak acl.\allowbreak dto} \\*
\hline
\textbf{Atributos Principales} & \texttt{maxBranches}, \texttt{maxActiveStaff}, \texttt{iotTelemetryEnabled}, \texttt{aiDiagnosticsEnabled}, \texttt{maxMonthlyWorkOrders} \\*
\hline
\textbf{Validación de Integridad} & Techo mínimo de sedes físicas o auxilio móvil con \texttt{@Min(1)}, personal activo con \texttt{@Min(1)}, órdenes mensuales con \texttt{@Min(1)} y banderas booleanas de habilitación modular. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{DTO de Integración de Fachada:} Feature\allowbreak Entitlement\allowbreak Dto} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak interfaces.\allowbreak acl.\allowbreak dto} \\*
\hline
\textbf{Atributos Principales} & \texttt{tenantId}, \texttt{featureKey}, \texttt{isEntitled}, \texttt{currentUsage}, \texttt{maximumLimit} \\*
\hline
\textbf{Validación de Integridad} & Contrato DTO inmutable para comprobaciones puntuales de acceso a capacidades técnicas avanzadas con telemetría y diagnósticos automotrices. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de DTOs inmutables implementados como Java 21 Records con Jakarta Bean Validation pertenecientes a resources y acl.dto.

**Ensambladores de Recursos y Transformación de Tipos**

El desacoplamiento entre el modelo conceptual de dominio y los contratos de transferencia expuestos en el API REST se garantiza mediante ensambladores de recursos dedicados. Estos componentes asumen la responsabilidad bidireccional de convertir agregados y entidades puras en recursos de presentación y traducir peticiones externas en comandos transaccionales:

- **SubscriptionPlanResourceAssembler**: Desempaqueta identificadores tipados hacia tipos universales, extrae importes y divisas desde el objeto de valor de tarificación y delega la proyección de funcionalidades modulares hacia componentes especializados.

- **TenantSubscriptionResourceAssembler**: Amalgama el contrato de membresía con las políticas del catálogo comercial, ofreciendo sobrecargas optimizadas para proyectar el estado contractual a partir de políticas precargadas en memoria sin requerir consultas adicionales hacia la base de datos relacional.

- **SaasInvoiceResourceAssembler**: Traduce recibos de liquidación financiera hacia representaciones detalladas o resumidas, posibilitando la renderización eficiente de grillas contables en los paneles administrativos de los talleres.

- **CheckoutSessionResourceAssembler**: Estructura la respuesta de inicialización de sesiones en Stripe Checkout encapsulando localizadores web e identificadores de sesión.

- **PlanFeatureResourceAssembler**: Mapea la habilitación de módulos técnicos avanzados hacia listas inmutables de presentación con manejo seguro ante colecciones vacías o nulas.

En la @tbl:billing-resource-assemblers se detallan las signaturas operativas, tipos de entrada y salida, y reglas de transformación aplicadas por los ensambladores de recursos.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Ensambladores de Recursos del Bounded Context SaaS Billing \& Subscriptions} \label{tbl:billing-resource-assemblers} \\
\hline
\thfirst{Aspecto Ensamblador} & \thcell{Firma y Transformación de Tipos} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto Ensamblador} & \thcell{Firma y Transformación de Tipos} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Subscription\allowbreak Plan\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResource} \\*
\hline
\textbf{Transformación} & \texttt{SubscriptionPlan} $\longrightarrow$ \texttt{SubscriptionPlanResource} \\*
\hline
\textbf{Reglas de Mapeo} & Desempaqueta identificadores tipados PlanId y StripePriceId hacia UUID y String. Extrae precio y moneda desde PlanPricing.price. Convierte cuotas a TenantQuotaLimitsDto y delega el mapeo de PlanFeature a PlanFeatureResourceAssembler.toResourceList. Arroja IllegalArgumentException si el agregado es nulo. \\
\hline
\textbf{Método Secundario} & \texttt{toResourceList} \\*
\hline
\textbf{Transformación} & \texttt{List<SubscriptionPlan>} $\longrightarrow$ \texttt{List<SubscriptionPlanResource>} \\*
\hline
\textbf{Reglas de Mapeo} & Transforma iterables de planes comerciales retornando listas inmutables serializables para los catálogos públicos y de administración. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Tenant\allowbreak Subscription\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResource} \\*
\hline
\textbf{Transformación} & \texttt{TenantSubscription, SubscriptionPlan} $\longrightarrow$ \texttt{TenantSubscriptionResource} \\*
\hline
\textbf{Reglas de Mapeo} & Combina la raíz de agregado contractual con los metadatos del catálogo comercial. Desempaqueta identificadores UUID, traduce SubscriptionStatus a texto, proyecta marcas de tiempo del periodo pagado e incrusta el DTO de cuotas paquetizadas en el plan. \\
\hline
\textbf{Método Secundario} & \texttt{toResource (Sobrecarga de Caché)} \\*
\hline
\textbf{Transformación} & \texttt{TenantSubscription, String planName, TenantQuotaLimits quotas} $\longrightarrow$ \texttt{TenantSubscriptionResource} \\*
\hline
\textbf{Reglas de Mapeo} & Compone el recurso de suscripción a partir de proyecciones cacheadas en memoria RAM sin necesidad de ejecutar lecturas adicionales sobre el catálogo en PostgreSQL. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Saas\allowbreak Invoice\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResource} \\*
\hline
\textbf{Transformación} & \texttt{SaasInvoice} $\longrightarrow$ \texttt{SaasInvoiceResource} \\*
\hline
\textbf{Reglas de Mapeo} & Mapea SaasInvoiceId y StripeInvoiceId a cadenas e identificadores UUID. Extrae monto y divisa desde Money. Traduce InvoiceStatus e incrusta enlaces PDF seguros emitidos por Stripe. \\
\hline
\textbf{Método Secundario} & \texttt{toSummaryResourceList} \\*
\hline
\textbf{Transformación} & \texttt{List<SaasInvoice>} $\longrightarrow$ \texttt{List<SaasInvoiceSummaryResource>} \\*
\hline
\textbf{Reglas de Mapeo} & Genera proyecciones livianas de facturas optimizadas para grillas de consulta contable masiva en paneles administrativos del taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Checkout\allowbreak Session\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResource} \\*
\hline
\textbf{Transformación} & \texttt{String checkoutUrl, String sessionId} $\longrightarrow$ \texttt{CheckoutSessionResource} \\*
\hline
\textbf{Reglas de Mapeo} & Encapsula el enlace URL seguro de redirección y el identificador telemático de sesión emitidos por la API de Stripe en un recurso inmutable de presentación. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Plan\allowbreak Feature\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResource} \\*
\hline
\textbf{Transformación} & \texttt{PlanFeature} $\longrightarrow$ \texttt{PlanFeatureResource} \\*
\hline
\textbf{Reglas de Mapeo} & Mapea el identificador universal, clave de funcionalidad alfanumérica, denominación, descripción textual y bandera booleana de habilitación modular. \\
\hline
\textbf{Método Secundario} & \texttt{toResourceList} \\*
\hline
\textbf{Transformación} & \texttt{List<PlanFeature>} $\longrightarrow$ \texttt{List<PlanFeatureResource>} \\*
\hline
\textbf{Reglas de Mapeo} & Transforma colecciones de funcionalidades empaquetadas. Si la colección de entrada es nula o vacía retorna de forma segura una lista inmutable vacía. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de firmas y reglas de conversión de los componentes de transformación REST en interfaces.rest.transform.

**Fachada de Contexto Abierto y Gobernanza de Cuotas en Memoria**

La interacción sincrónica de alta frecuencia entre SaaS Billing & Subscriptions y los restantes Bounded Contexts de Atelier Platform se canaliza a través de la interfaz **SubscriptionContextFacade**, configurada bajo el patrón de Fachada de Contexto Abierto. Esta frontera abstracta permite a módulos como IAM, Human Resources, Workshop Operations e IoT Telemetry consultar la vigencia de licencias y comprobar límites de capacidad sin acoplarse a los agregados transaccionales del contexto:

- **Aceleración en memoria volátil**: La implementación perimetral respalda la comprobación de cuotas operativas mediante una estructura de almacenamiento temporal de ultra alta velocidad implementada con Caffeine Cache, logrando latencias de resolución inferiores a 0.05 milisegundos en pruebas de carga.

- **Invalidación reactiva**: Ante eventos de cambio de estado de membresía o migraciones de plan comercial, la memoria volátil expulsa de forma determinista la política almacenada para el taller, garantizando consistencia eventual estricta en todo el clúster de la plataforma.

En la @tbl:billing-facade-methods se exponen los métodos de la fachada de contexto abierto, indicando sus tipos de retorno, módulos consumidores y estrategias de aceleración en memoria.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Métodos de la Fachada de Contexto Abierto SubscriptionContextFacade} \label{tbl:billing-facade-methods} \\
\hline
\thfirst{Aspecto del Contrato} & \thcell{Firma, Retorno y Consumidores} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Contrato} & \thcell{Firma, Retorno y Consumidores} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{isTenantSubscriptionActive}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID tenantId} $\longrightarrow$ \texttt{boolean} \\*
\hline
\textbf{Módulos Consumidores} & IAM \& Tenancy, Workshop Operations (MRO), Human Resources, IoT Telemetry \\*
\hline
\textbf{Estrategia de Caché} & Resuelto en memoria RAM mediante Caffeine In-Memory Cache con latencia menor a 0.05 ms. Invalida de forma reactiva ante cambios contractuales. \\*
\hline
\textbf{Propósito Intermodular} & Verifica si el taller automotriz posee un contrato vigente en estado TRIALING o ACTIVE o si se encuentra dentro del periodo de gracia transitoria. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{getTenantQuotaLimits}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID tenantId} $\longrightarrow$ \texttt{TenantQuotaLimitsDto} \\*
\hline
\textbf{Módulos Consumidores} & Paneles de administración de IAM y tableros de gestión de recursos de plataforma \\*
\hline
\textbf{Estrategia de Caché} & Almacenado en política inmutable en Caffeine Cache con tiempo de vida de 30 minutos y desalojo reactivo por eventos de migración. \\*
\hline
\textbf{Propósito Intermodular} & Provee la nómina completa de techos operativos autorizados para el taller incluyendo sedes, colaboradores, órdenes mecánicas y módulos IoT. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{getTenantSubscriptionStatus}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID tenantId} $\longrightarrow$ \texttt{TenantSubscriptionStatusDto} \\*
\hline
\textbf{Módulos Consumidores} & IAM \& Tenancy, API Gateway, Paneles de administración del taller \\*
\hline
\textbf{Estrategia de Caché} & Resuelto en memoria volátil Caffeine Cache con desalojo reactivo ante transiciones de estado contractual. \\*
\hline
\textbf{Propósito Intermodular} & Retorna el estado contractual detallado del taller incluyendo denominación de plan, nivel tarifario, vigencia y bandera de cancelación programada. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{canAddBranch}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID tenantId, int currentBranchCount} $\longrightarrow$ \texttt{boolean} \\*
\hline
\textbf{Módulos Consumidores} & IAM \& Tenancy (Comando de creación de sedes y auxilio móvil) \\*
\hline
\textbf{Estrategia de Caché} & Comparación aritmética pura en memoria volátil contra el atributo maxBranches pre-cargado en memoria lock-free. \\*
\hline
\textbf{Propósito Intermodular} & Valida si el taller automotriz cuenta con cupo disponible para inaugurar una nueva sucursal física o unidad móvil de auxilio mecánico. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{canAddStaffMember}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID tenantId, int currentStaffCount} $\longrightarrow$ \texttt{boolean} \\*
\hline
\textbf{Módulos Consumidores} & Human Resources (Comando de contratación de personal operativo) \\*
\hline
\textbf{Estrategia de Caché} & Validación aritmética instantánea en RAM contra el valor inmutable maxActiveStaff de la suscripción. \\*
\hline
\textbf{Propósito Intermodular} & Impide la contratación de colaboradores, asesores o mecánicos si la plantilla en servicio iguala el techo del plan contratado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{canCreateWorkOrder}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID tenantId, int currentMonthlyWorkOrders} $\longrightarrow$ \texttt{boolean} \\*
\hline
\textbf{Módulos Consumidores} & Workshop Operations (MRO) (Apertura de órdenes de reparación y mantenimiento) \\*
\hline
\textbf{Estrategia de Caché} & Validación en memoria ultra rápida mitigando sobrecarga transaccional sobre PostgreSQL en el flujo de recepción vehicular. \\*
\hline
\textbf{Propósito Intermodular} & Fiscaliza que el volumen mensual de órdenes mecánicas creadas no rebase la cuota paquetizada en el nivel de software contratado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{isFeatureAllowed}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID tenantId, String featureKey} $\longrightarrow$ \texttt{boolean} \\*
\hline
\textbf{Módulos Consumidores} & IoT Telemetry \& Predictive Maintenance, Módulos de Diagnóstico IA \\*
\hline
\textbf{Estrategia de Caché} & Consulta de pertenencia en Set inmutable de cadenas alfanuméricas pre-compilado en RAM con complejidad algorítmica O(1). \\*
\hline
\textbf{Propósito Intermodular} & Determina en tiempo de ejecución si el plan comercial contratado ampara la ingesta de telemetría OBD-II o diagnósticos avanzados de falla. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{checkFeatureEntitlement}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID tenantId, String featureKey} $\longrightarrow$ \texttt{FeatureEntitlementDto} \\*
\hline
\textbf{Módulos Consumidores} & IoT Telemetry \& Predictive Maintenance, Workshop Operations (MRO) \\*
\hline
\textbf{Estrategia de Caché} & Consulta en memoria volátil combinando banderas booleanas y cuotas específicas de módulos avanzados. \\*
\hline
\textbf{Propósito Intermodular} & Verifica detalladamente los derechos de acceso, límites cuantitativos y consumo actual para una funcionalidad modular específica. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de contratos de interoperabilidad en memoria de SubscriptionContextFacade vinculados a interfaces.acl.dto.

**Eventos de Integración y Coordinación Asíncrona Intermodular**

La coordinación reactiva entre SaaS Billing & Subscriptions y los demás módulos de la plataforma se fundamenta en eventos de integración asíncronos. Estos mensajes inmutables representan hechos consumados y se distribuyen mediante el patrón Outbox transaccional para garantizar entrega confiable y desacoplamiento temporal:

- **Eventos Publicados**: Notifican a la plataforma alteraciones en la vigencia de membresías, reajustes de cuotas operativas por migración de paquete comercial o suspensiones preventivas por impago bancario tras vencer el periodo de gracia.

- **Eventos Consumidos**: La recepción de eventos de alta de talleres desde IAM gatilla de forma desatendida el aprovisionamiento de identidades corporativas en Stripe y la activación automática de licencias de prueba gratuita sin fricción operativa.

En la @tbl:billing-integration-events se sintetiza la taxonomía de los eventos de integración de este contexto, describiendo sus atributos transportados y consecuencias arquitectónicas.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Eventos de Integración del Bounded Context SaaS Billing \& Subscriptions} \label{tbl:billing-integration-events} \\
\hline
\thfirst{Aspecto de Integración} & \thcell{Carga Útil y Sincronización Intermodular} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Integración} & \thcell{Carga Útil y Sincronización Intermodular} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} Tenant\allowbreak Plan\allowbreak Changed\allowbreak Integration\allowbreak Event \quad (\textit{Tipo:} Publicado)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{subscriptionId}, \texttt{tenantId}, \texttt{oldPlanId}, \texttt{newPlanId}, \texttt{newPlanTier}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & IAM \& Tenancy, Workshop Operations (MRO), Human Resources, IoT Telemetry \\*
\hline
\textbf{Efecto Arquitectónico} & Comunica la migración de plan tarifario para sincronizar privilegios comerciales y recalcular techos operativos en los módulos consumidores. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} Tenant\allowbreak Quota\allowbreak Limits\allowbreak Updated\allowbreak Integration\allowbreak Event \quad (\textit{Tipo:} Publicado)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{subscriptionId}, \texttt{tenantId}, \texttt{newQuotas}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & IAM \& Tenancy, Workshop Operations (MRO), Human Resources, API Gateway \\*
\hline
\textbf{Efecto Arquitectónico} & Expande o restringe de forma inmediata los límites autorizados de sucursales, mecánicos y órdenes de trabajo en la memoria volátil de la plataforma. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} Tenant\allowbreak Subscription\allowbreak Activated\allowbreak Integration\allowbreak Event \quad (\textit{Tipo:} Publicado)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{subscriptionId}, \texttt{tenantId}, \texttt{planId}, \texttt{tier}, \texttt{currentPeriodEnd}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & IAM \& Tenancy, API Gateway, Instancias de SubscriptionContextFacade \\*
\hline
\textbf{Efecto Arquitectónico} & Habilita el acceso irrestricto a los módulos operativos contratados e inicializa las entradas de autorización en Caffeine Cache. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} Tenant\allowbreak Subscription\allowbreak Canceled\allowbreak Integration\allowbreak Event \quad (\textit{Tipo:} Publicado)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{subscriptionId}, \texttt{tenantId}, \texttt{cancellationReason}, \texttt{effectiveDate}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & IAM \& Tenancy, API Gateway, Notificaciones \\*
\hline
\textbf{Efecto Arquitectónico} & Programa o ejecuta la rescisión contractual, revoca privilegios operativos al expirar la vigencia y notifica a los administradores del taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} Tenant\allowbreak Subscription\allowbreak Past\allowbreak Due\allowbreak Integration\allowbreak Event \quad (\textit{Tipo:} Publicado)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{subscriptionId}, \texttt{tenantId}, \texttt{stripeInvoiceId}, \texttt{attemptCount}, \texttt{gracePeriodEnd}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & IAM \& Tenancy, API Gateway, Notificaciones \\*
\hline
\textbf{Efecto Arquitectónico} & Alerta sobre cobros bancarios fallidos, activa el periodo de gracia transitorio y restringe funciones críticas si la mora persiste sin subsanarse. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} Tenant\allowbreak Registered\allowbreak Integration\allowbreak Event \quad (\textit{Tipo:} Consumido)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{tenantId}, \texttt{legalName}, \texttt{adminEmail}, \texttt{country}, \texttt{registeredAt} \\*
\hline
\textbf{Módulo Emisor} & IAM \& Tenancy (Flujo de alta y registro inicial del taller) \\*
\hline
\textbf{Efecto Arquitectónico} & Gatilla el aprovisionamiento asíncrono de un cliente corporativo en Stripe y activa una membresía de prueba gratuita de 14 días. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Taxonomía de eventos de integración asíncronos publicados en interfaces.events y consumidos por SaaS Billing \& Subscriptions.

El diseño perimetral de la Capa de Interfaz de SaaS Billing & Subscriptions garantiza el aislamiento absoluto entre las reglas de monetización de Andeva y la operativa tributaria interna de los talleres mecánicos. Al erigir controladores REST y contratos de transferencia independientes, el sistema impide que las regulaciones tributarias de SUNAT modeladas en Invoicing interfieran con el esquema de licenciamiento recurrente, preservando la portabilidad del modelo de negocio hacia nuevos países.

Asimismo, la arquitectura perimetral satisface con rigor los requisitos de seguridad y cumplimiento estipulados por el estándar PCI-DSS Nivel 1. Al derivar la recolección de credenciales financieras hacia interfaces certificadas de Stripe y custodiar exclusivamente identificadores tokenizados inmutables, la plataforma suprime vectores críticos de vulnerabilidad y garantiza la privacidad bancaria de los talleres asociados.

Finalmente, la articulación de la Fachada de Contexto Abierto con la aceleración en memoria provista por Caffeine Cache resuelve eficientemente la disyuntiva entre fiscalización de cuotas y rendimiento operativo. Los procesos cotidianos de taller mecánico validan límites de sucursales, mecánicos y órdenes de trabajo en submilisegundos, asegurando una experiencia fluida tanto en estaciones web de mostrador como en aplicaciones móviles de auxilio en campo sin penalizar el almacenamiento relacional de la plataforma.

#### 2.6.8.3. Application Layer

La Capa de Aplicación del Bounded Context SaaS Billing & Subscriptions constituye el orquestador de los procesos de monetización y licenciamiento de la plataforma Atelier, residiendo bajo el paquete canónico **com.andeva.atelier.platform.billing.application**. Su responsabilidad radica en coordinar la ejecución transaccional de los casos de uso comerciales, mediar entre los adaptadores perimetrales y el modelo de dominio mediante el patrón CQRS, y asegurar la sincronización asíncrona con infraestructuras financieras externas.

Para preservar la cohesión y el rendimiento en el tratamiento de membresías corporativas, el diseño arquitectónico de esta capa se fundamenta en cuatro directrices tácticas:

- **Segregación estricta entre mutaciones y lecturas mediante CQRS:** Aislamiento formal entre los servicios de comandos que modifican el estado de contratos o tarifarios en PostgreSQL y los servicios de consultas que proyectan vistas optimizadas para el portal web y las aplicaciones cliente.

- **Orquestación transaccional e integración segura con Stripe:** Coordinación de flujos de pago complejos delegando la recolección de credenciales financieras a sesiones alojadas en Stripe Checkout y Stripe Customer Portal, salvaguardando el cumplimiento PCI-DSS Nivel 1.

- **Idempotencia determinista y procesamiento exactamente una vez:** Resiliencia ante la entrega duplicada de eventos asíncronos mediante deduplicación en la base de datos relacional y comprobación criptográfica previa de firmas HMAC-SHA256, previniendo alteraciones contables ante reintentos de red.

- **Optimización de consultas perimetrales con almacenamiento en memoria volátil:** Resolución de comprobaciones frecuentes de cuotas operativas mediante Caffeine Cache con tiempos de respuesta sub-milisegundos, acompañada de invalidación reactiva ante eventos de ciclo de vida.

En la @tbl:billing-application-types se expone el catálogo taxonómico consolidado de los componentes tácticos que estructuran la Capa de Aplicación de SaaS Billing & Subscriptions, clasificando sus responsabilidades, relaciones y paquetes canónicos.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo Consolidado de la Capa de Aplicación de SaaS Billing \& Subscriptions} \label{tbl:billing-application-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endhead
Subscription\allowbreak Plan\allowbreak Command\allowbreak Service & Define las operaciones transaccionales para la creación, actualización y gestión comercial de planes de suscripción. \\*
\hline
\textbf{Categoría} & Servicio de Comandos (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por SubscriptionPlanCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Subscription\allowbreak Plan\allowbreak Command\allowbreak Service\allowbreak Impl & Gobierna el ciclo de vida del catálogo comercial de software, alta de tarifas paquetizadas y desactivación administrativa. \\*
\hline
\textbf{Categoría} & Servicio de Comandos (Implementación) \\*
\hline
\textbf{Relaciones} & Implementa SubscriptionPlanCommandService. Invoca SubscriptionPlanRepository y valida identificadores foráneos de precio en Stripe. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak internal.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Tenant\allowbreak Subscription\allowbreak Command\allowbreak Service & Define los flujos transaccionales de contratación, generación de sesiones de pago, renovación, cambio de plan y cancelación. \\*
\hline
\textbf{Categoría} & Servicio de Comandos (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por TenantSubscriptionCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Tenant\allowbreak Subscription\allowbreak Command\allowbreak Service\allowbreak Impl & Orquesta los flujos transaccionales de contratación de planes, sesiones Stripe Checkout, portal de clientes, renovaciones y cancelaciones. \\*
\hline
\textbf{Categoría} & Servicio de Comandos (Implementación) \\*
\hline
\textbf{Relaciones} & Implementa TenantSubscriptionCommandService. Invoca StripeGatewayPort, TenantSubscriptionRepository y BillingCachePort. Publica eventos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak internal.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Stripe\allowbreak Webhook\allowbreak Command\allowbreak Service & Define la ingesta y procesamiento transaccional e idempotente de notificaciones telemáticas asíncronas de Stripe. \\*
\hline
\textbf{Categoría} & Servicio de Comandos (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por StripeWebhookCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Stripe\allowbreak Webhook\allowbreak Command\allowbreak Service\allowbreak Impl & Procesa notificaciones telemáticas de Stripe con verificación criptográfica HMAC-SHA256 e idempotencia estricta en base de datos. \\*
\hline
\textbf{Categoría} & Servicio de Comandos (Implementación) \\*
\hline
\textbf{Relaciones} & Implementa StripeWebhookCommandService. Invoca StripeWebhookSignatureVerificationService y StripeWebhookEventRepository. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak internal.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Saas\allowbreak Invoice\allowbreak Command\allowbreak Service & Define el registro inmutable de comprobantes de recaudación devengados por Stripe y emisión de notificaciones de pago. \\*
\hline
\textbf{Categoría} & Servicio de Comandos (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por SaasInvoiceCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Saas\allowbreak Invoice\allowbreak Command\allowbreak Service\allowbreak Impl & Asienta de forma inmutable los comprobantes de recaudación del SaaS y preserva los enlaces oficiales a los recibos custodiados en Stripe. \\*
\hline
\textbf{Categoría} & Servicio de Comandos (Implementación) \\*
\hline
\textbf{Relaciones} & Implementa SaasInvoiceCommandService. Invoca SaasInvoiceRepository y emite SaasInvoicePaymentSucceededEvent. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak internal.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Subscription\allowbreak Plan\allowbreak Query\allowbreak Service & Define métodos de lectura del catálogo público y corporativo de planes de software, tarifas y funcionalidades autorizadas. \\*
\hline
\textbf{Categoría} & Servicio de Consultas (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por SubscriptionPlanQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak queryservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Subscription\allowbreak Plan\allowbreak Query\allowbreak Service\allowbreak Impl & Provee lecturas optimizadas del catálogo público y corporativo de planes de software, tarifas y funcionalidades autorizadas. \\*
\hline
\textbf{Categoría} & Servicio de Consultas (Implementación) \\*
\hline
\textbf{Relaciones} & Implementa SubscriptionPlanQueryService. Emplea almacenamiento temporal en memoria volátil de alta velocidad. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak internal.\allowbreak queryservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Tenant\allowbreak Subscription\allowbreak Query\allowbreak Service & Define consultas de situación contractual, cuotas operativas vigentes y validez de membresías para los talleres mecánicos. \\*
\hline
\textbf{Categoría} & Servicio de Consultas (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por TenantSubscriptionQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak queryservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Tenant\allowbreak Subscription\allowbreak Query\allowbreak Service\allowbreak Impl & Resuelve consultas de situación contractual, cuotas operativas vigentes y validez de membresías con aceleración en Caffeine Cache. \\*
\hline
\textbf{Categoría} & Servicio de Consultas (Implementación) \\*
\hline
\textbf{Relaciones} & Implementa TenantSubscriptionQueryService. Utiliza anotaciones Spring Cache y consulta TenantSubscriptionRepository. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak internal.\allowbreak queryservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Saas\allowbreak Invoice\allowbreak Query\allowbreak Service & Define consultas de comprobantes de cobro y detalles contables paginados para los administradores de los talleres. \\*
\hline
\textbf{Categoría} & Servicio de Consultas (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por SaasInvoiceQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak queryservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Saas\allowbreak Invoice\allowbreak Query\allowbreak Service\allowbreak Impl & Proyecta resúmenes históricos de comprobantes de cobro y detalles contables paginados para los administradores de los talleres. \\*
\hline
\textbf{Categoría} & Servicio de Consultas (Implementación) \\*
\hline
\textbf{Relaciones} & Implementa SaasInvoiceQueryService. Invoca SaasInvoiceRepository para recuperar registros financieros. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak internal.\allowbreak queryservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Subscription\allowbreak Context\allowbreak Facade\allowbreak Impl & Implementa la fachada de contexto abierto coordinando repositorios de dominio con aceleración en memoria volátil. \\*
\hline
\textbf{Categoría} & Implementación de Fachada de Contexto Abierto \\*
\hline
\textbf{Relaciones} & Implementa SubscriptionContextFacade de la capa de interfaz. Resuelve comprobaciones de cuotas operativas en submilisegundos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Subscription\allowbreak Domain\allowbreak Event\allowbreak Handler & Escucha eventos del ciclo de vida contractual para ejecutar la purga reactiva de caché en memoria y enviar notificaciones. \\*
\hline
\textbf{Categoría} & Manejador de Eventos de Dominio \\*
\hline
\textbf{Relaciones} & Anotado con TransactionalEventListener. Invoca TenantBillingNotificationGatewayPort y expulsa políticas cacheadas en BillingCachePort. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak internal.\allowbreak eventhandlers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Tenant\allowbreak Lifecycle\allowbreak Integration\allowbreak Event\allowbreak Handler & Procesa el registro de nuevos talleres mecánicos aprovisionando el cliente en Stripe y activando la prueba gratuita de catorce días. \\*
\hline
\textbf{Categoría} & Manejador de Eventos de Integración \\*
\hline
\textbf{Relaciones} & Escucha TenantRegisteredIntegrationEvent desde IAM. Invoca TenantSubscriptionCommandService, StripeGatewayPort e IamTenantValidationAclPort. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak internal.\allowbreak eventhandlers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Billing\allowbreak Transactional\allowbreak Outbox\allowbreak Publisher & Persiste eventos de integración en la tabla outbox\_messages bajo la misma transacción ACID con garantía de entrega At-Least-Once. \\*
\hline
\textbf{Categoría} & Publicador Transaccional Outbox \\*
\hline
\textbf{Relaciones} & Intercepta eventos del ciclo de vida contractual y los almacena atómicamente en base de datos para despacho asíncrono seguro. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak internal.\allowbreak eventhandlers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Stripe\allowbreak Gateway\allowbreak Port & Puerto de salida agnóstico que encapsula y aísla las interacciones con el SDK de Stripe protegiendo al dominio de dependencias externas. \\*
\hline
\textbf{Categoría} & Puerto de Salida (Gateway) \\*
\hline
\textbf{Relaciones} & Implementado en la capa de infraestructura por StripeGatewayAdapter. Utilizado por los servicios de comandos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak internal.\allowbreak outbound.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Tenant\allowbreak Billing\allowbreak Notification\allowbreak Gateway\allowbreak Port & Puerto de salida para la transmisión telemática de correos electrónicos transaccionales, confirmaciones de pago y alertas financieras. \\*
\hline
\textbf{Categoría} & Puerto de Salida (Gateway) \\*
\hline
\textbf{Relaciones} & Implementado en infraestructura por ResendTenantBillingNotificationAdapter. Utilizado por los manejadores de eventos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak internal.\allowbreak outbound.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Iam\allowbreak Tenant\allowbreak Validation\allowbreak Acl\allowbreak Port & Puerto de salida anticorrupción para validar la existencia y razón social del taller automotriz contra IAM \& Tenancy. \\*
\hline
\textbf{Categoría} & Puerto de Salida (Gateway) \\*
\hline
\textbf{Relaciones} & Implementado en infraestructura por IamTenantValidationAclAdapter. Utilizado por servicios de comandos y eventos de ciclo de vida. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak internal.\allowbreak outbound.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Billing\allowbreak Cache\allowbreak Port & Puerto de salida para la gestión de caché de alto rendimiento en memoria volátil RAM con Caffeine para cuotas y estados de suscripción. \\*
\hline
\textbf{Categoría} & Puerto de Salida (Gateway) \\*
\hline
\textbf{Relaciones} & Implementado en infraestructura por CaffeineBillingCacheAdapter. Consumido por servicios de consultas y manejadores de eventos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak internal.\allowbreak outbound.\allowbreak acl} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Catálogo taxonómico de tipos de la Capa de Aplicación, organizados en los subpaquetes canónicos commandservices, internal.commandservices, queryservices, internal.queryservices, internal.eventhandlers, internal.outbound.acl y acl.

**Servicios de Comandos de la Capa de Aplicación**

La modificación transaccional del estado de licenciamiento y facturación se gestiona mediante cuatro servicios de comandos especializados, alineados a las raíces de agregado del contexto:

- **TenantSubscriptionCommandServiceImpl**: Orquesta la activación de membresías, la generación de sesiones de pago con Stripe, renovaciones de periodos contables, cambios de plan, conmutaciones a mora transitoria y cancelaciones, asegurando límites transaccionales acotados.

- **StripeWebhookCommandServiceImpl**: Centraliza la ingesta telemática de notificaciones de Stripe, validando firmas criptográficas y asegurando un procesamiento exactamente una vez antes de disparar actualizaciones de ciclo de vida o registrar facturas.

- **SubscriptionPlanCommandServiceImpl**: Administra el catálogo comercial de planes de software comercializados por Andeva, sincronizando precios y cuotas paquetizadas con el tarifario de Stripe y garantizando techos operativos mínimos.

- **SaasInvoiceCommandServiceImpl**: Concreta el asentamiento inmutable de comprobantes de cobro corporativos tras débitos bancarios exitosos, vinculando identificadores foráneos y enlaces seguros al documento digital.

En la @tbl:billing-command-services se detallan las operaciones transaccionales, signaturas, parámetros y reglas de negocio aplicadas por los servicios de comandos de este contexto.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Operaciones Transaccionales de los Servicios de Comandos de SaaS Billing \& Subscriptions} \label{tbl:billing-command-services} \\
\hline
\thfirst{Comando de Entrada} & \thcell{Firma, Retorno y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Comando de Entrada} & \thcell{Firma, Retorno y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Comandos:} Tenant\allowbreak Subscription\allowbreak Command\allowbreak Service\allowbreak Impl} \\*
\hline
\textbf{Comando:} \texttt{Create\allowbreak Checkout\allowbreak Session\allowbreak Command} & \texttt{handle(CreateCheckoutSessionCommand)} → \texttt{CheckoutSessionDto} \\*
\hline
\textbf{Parámetros Principales} & \texttt{TenantId tenantId, PlanId planId, String successUrl, String cancelUrl} \\*
\hline
\textbf{Reglas y Transaccionalidad} & Verifica que el taller no cuente con una membresía activa idéntica en curso. Invoca StripeGatewayPort para crear la sesión de checkout adjuntando identificadores en los metadatos y retorna la URL segura para redirección. Anotado con \texttt{@Transactional}. \\
\hline
\textbf{Comando:} \texttt{Create\allowbreak Customer\allowbreak Portal\allowbreak Session\allowbreak Command} & \texttt{handle(CreateCustomerPortalSessionCommand)} → \texttt{CustomerPortalSessionDto} \\*
\hline
\textbf{Parámetros Principales} & \texttt{TenantId tenantId, String returnUrl} \\*
\hline
\textbf{Reglas y Transaccionalidad} & Recupera el identificador StripeCustomerId asociado al taller y solicita a StripeGatewayPort la emisión de una sesión interactiva del portal de facturación. Valida que la URL de retorno pertenezca a dominios autorizados. \\
\hline
\textbf{Comando:} \texttt{Change\allowbreak Subscription\allowbreak Plan\allowbreak Command} & \texttt{handle(ChangeSubscriptionPlanCommand)} → \texttt{void} \\*
\hline
\textbf{Parámetros Principales} & \texttt{TenantId tenantId, PlanId newPlanId} \\*
\hline
\textbf{Reglas y Transaccionalidad} & Valida la existencia del nuevo plan y su vigencia comercial. Comunica la actualización a Stripe mediante StripeGatewayPort, actualiza las cuotas del taller en TenantSubscription, emite TenantPlanChangedIntegrationEvent y purga la memoria volátil a través de BillingCachePort. \\
\hline
\textbf{Comando:} \texttt{Activate\allowbreak Tenant\allowbreak Subscription\allowbreak Command} & \texttt{handle(ActivateTenantSubscriptionCommand)} → \texttt{SubscriptionId} \\*
\hline
\textbf{Parámetros Principales} & \texttt{TenantId tenantId, PlanId planId, StripeCustomerId customerId, StripeSubscriptionId subId, SubscriptionPeriod period} \\*
\hline
\textbf{Reglas y Transaccionalidad} & Inicializa el contrato en estado ACTIVE o TRIALING según corresponda. Persiste el agregado TenantSubscription, emite TenantSubscriptionActivatedEvent y publica TenantSubscriptionActivatedIntegrationEvent. \\
\hline
\textbf{Comando:} \texttt{Renew\allowbreak Tenant\allowbreak Subscription\allowbreak Command} & \texttt{handle(RenewTenantSubscriptionCommand)} → \texttt{void} \\*
\hline
\textbf{Parámetros Principales} & \texttt{StripeSubscriptionId stripeSubId, SubscriptionPeriod newPeriod} \\*
\hline
\textbf{Reglas y Transaccionalidad} & Localiza la suscripción por su identificador foráneo, extiende la ventana cronológica de cobertura, actualiza el estado a ACTIVE, emite TenantSubscriptionRenewedEvent y purga la memoria volátil en Caffeine vía BillingCachePort. \\
\hline
\textbf{Comando:} \texttt{Mark\allowbreak Tenant\allowbreak Subscription\allowbreak Past\allowbreak Due\allowbreak Command} & \texttt{handle(MarkTenantSubscriptionPastDueCommand)} → \texttt{void} \\*
\hline
\textbf{Parámetros Principales} & \texttt{StripeSubscriptionId stripeSubId} \\*
\hline
\textbf{Reglas y Transaccionalidad} & Transiciona el contrato a estado PAST\_DUE tras confirmarse un fallo bancario en Stripe. Abre el periodo de gracia de catorce días y emite TenantSubscriptionPastDueEvent para despacho de alertas financieras urgentes mediante TenantBillingNotificationGatewayPort. \\
\hline
\textbf{Comando:} \texttt{Cancel\allowbreak Tenant\allowbreak Subscription\allowbreak Command} & \texttt{handle(CancelTenantSubscriptionCommand)} → \texttt{void} \\*
\hline
\textbf{Parámetros Principales} & \texttt{TenantId tenantId, boolean immediately, String cancellationReason} \\*
\hline
\textbf{Reglas y Transaccionalidad} & Si la cancelación es inmediata rescinde el contrato en Stripe, revoca accesos de inmediato y transiciona a CANCELED. Si es al fin de ciclo programa cancelAtPeriodEnd en true. Emite TenantSubscriptionCanceledEvent y TenantSubscriptionCanceledIntegrationEvent. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Comandos:} Stripe\allowbreak Webhook\allowbreak Command\allowbreak Service\allowbreak Impl} \\*
\hline
\textbf{Comando:} \texttt{Process\allowbreak Stripe\allowbreak Webhook\allowbreak Command} & \texttt{handle(ProcessStripeWebhookCommand)} → \texttt{void} \\*
\hline
\textbf{Parámetros Principales} & \texttt{String rawPayload, String signatureHeader} \\*
\hline
\textbf{Reglas y Transaccionalidad} & Valida firma criptográfica HMAC-SHA256 con ventana de tolerancia de 300 segundos. Verifica idempotencia estricta en stripe\_events descartando eventos ya procesados. Enruta de forma polimórfica según la tipología del suceso hacia suscripciones o facturas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Comandos:} Subscription\allowbreak Plan\allowbreak Command\allowbreak Service\allowbreak Impl} \\*
\hline
\textbf{Comando:} \texttt{Create\allowbreak Subscription\allowbreak Plan\allowbreak Command} & \texttt{handle(CreateSubscriptionPlanCommand)} → \texttt{PlanId} \\*
\hline
\textbf{Parámetros Principales} & \texttt{String stripePriceId, String name, PlanTier tier, PlanPricing pricing, TenantQuotaLimits limits} \\*
\hline
\textbf{Reglas y Transaccionalidad} & Valida unicidad del identificador foráneo y denominación comercial. Fiscaliza invariantes de cuotas mínimas permitidas. Persiste el agregado SubscriptionPlan y registra SubscriptionPlanCreatedEvent. \\
\hline
\textbf{Comando:} \texttt{Update\allowbreak Subscription\allowbreak Plan\allowbreak Details\allowbreak Command} & \texttt{handle(UpdateSubscriptionPlanDetailsCommand)} → \texttt{void} \\*
\hline
\textbf{Parámetros Principales} & \texttt{PlanId planId, String name, TenantQuotaLimits quotaLimits, boolean isActive} \\*
\hline
\textbf{Reglas y Transaccionalidad} & Actualiza techos operativos y estado comercial del plan. Respeta los contratos vigentes de talleres ya abonados preservando sus derechos adquiridos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Comandos:} Saas\allowbreak Invoice\allowbreak Command\allowbreak Service\allowbreak Impl} \\*
\hline
\textbf{Comando:} \texttt{Record\allowbreak Saas\allowbreak Invoice\allowbreak Payment\allowbreak Command} & \texttt{handle(RecordSaasInvoicePaymentCommand)} → \texttt{SaasInvoiceId} \\*
\hline
\textbf{Parámetros Principales} & \texttt{StripeInvoiceId stripeInvoiceId, SubscriptionId subId, TenantId tenantId, Money amount, String pdfUrl} \\*
\hline
\textbf{Reglas y Transaccionalidad} & Asienta de forma inmutable el comprobante financiero en la base de datos relacional. Registra la marca temporal UTC de recaudación formal y emite SaasInvoicePaymentSucceededEvent. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de firmas, parámetros y reglas de consistencia de los comandos de la Capa de Aplicación, organizados en commandservices e internal.commandservices.

**Servicios de Consulta y Proyección Acelerada de Datos**

Las necesidades de lectura de los paneles administrativos y de los demás módulos de la plataforma se resuelven mediante servicios de consulta dedicados, desacoplados del modelo transaccional y optimizados con memoria volátil:

- **TenantSubscriptionQueryServiceImpl**: Proyecta la situación contractual activa del taller automotriz y provee verificación instantánea de cuotas de recursos mediante Caffeine Cache, eliminando la contención sobre el motor relacional.

- **SubscriptionPlanQueryServiceImpl**: Provee acceso de alta velocidad al catálogo público y comercial de planes de suscripción, facilitando la visualización transparente de tarifas y módulos autorizados.

- **SaasInvoiceQueryServiceImpl**: Proyecta historiales contables paginados y detalles financieros individuales para su inspección y auditoría por parte del personal administrativo del taller.

En la @tbl:billing-query-services se presentan los métodos de consulta de la capa de aplicación, indicando sus tipos de retorno, parámetros y estrategias de aceleración en memoria.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Métodos de Consulta de la Capa de Aplicación de SaaS Billing \& Subscriptions} \label{tbl:billing-query-services} \\
\hline
\thfirst{Consulta de Entrada} & \thcell{Firma, Retorno y Estrategia de Caché} \\
\hline
\endfirsthead
\hline
\thfirst{Consulta de Entrada} & \thcell{Firma, Retorno y Estrategia de Caché} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Consultas:} Tenant\allowbreak Subscription\allowbreak Query\allowbreak Service\allowbreak Impl} \\*
\hline
\textbf{Consulta:} \texttt{Get\allowbreak Tenant\allowbreak Subscription\allowbreak By\allowbreak Tenant\allowbreak Id\allowbreak Query} & \texttt{handle(GetTenantSubscriptionByTenantIdQuery)} → \texttt{Optional<TenantSubscription>} \\*
\hline
\textbf{Parámetros} & \texttt{TenantId tenantId} \\*
\hline
\textbf{Estrategia de Caché} & Almacenado en Caffeine Cache bajo la región tenantSubscriptionStatus vía BillingCachePort. Resuelve consultas frecuentes de situación contractual en tiempo inferior a 0.05 ms. Transaccionalidad de solo lectura (\texttt{@Transactional(readOnly = true)}). \\
\hline
\textbf{Consulta:} \texttt{Get\allowbreak Tenant\allowbreak Subscription\allowbreak By\allowbreak Id\allowbreak Query} & \texttt{handle(GetTenantSubscriptionByIdQuery)} → \texttt{Optional<TenantSubscription>} \\*
\hline
\textbf{Parámetros} & \texttt{SubscriptionId subscriptionId} \\*
\hline
\textbf{Estrategia de Caché} & Búsqueda directa por clave primaria universal UUID en base de datos relacional. Empleada en flujos de conciliación y sincronización de webhooks. \\
\hline
\textbf{Consulta:} \texttt{Is\allowbreak Tenant\allowbreak Subscription\allowbreak Active\allowbreak Query} & \texttt{handle(IsTenantSubscriptionActiveQuery)} → \texttt{boolean} \\*
\hline
\textbf{Parámetros} & \texttt{TenantId tenantId} \\*
\hline
\textbf{Estrategia de Caché} & Proyección booleana ligera acelerada en RAM mediante BillingCachePort. Evalúa si el contrato se encuentra en ACTIVE, TRIALING o periodo de gracia transitoria. \\
\hline
\textbf{Consulta:} \texttt{Get\allowbreak Tenant\allowbreak Quota\allowbreak Limits\allowbreak Query} & \texttt{handle(GetTenantQuotaLimitsQuery)} → \texttt{TenantQuotaLimitsDto} \\*
\hline
\textbf{Parámetros} & \texttt{TenantId tenantId} \\*
\hline
\textbf{Estrategia de Caché} & Consulta de la política inmutable precompilada en memoria RAM mediante BillingCachePort. Evita accesos a PostgreSQL en las comprobaciones de cuotas de sedes y personal. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Consultas:} Subscription\allowbreak Plan\allowbreak Query\allowbreak Service\allowbreak Impl} \\*
\hline
\textbf{Consulta:} \texttt{Get\allowbreak All\allowbreak Active\allowbreak Subscription\allowbreak Plans\allowbreak Query} & \texttt{handle(GetAllActiveSubscriptionPlansQuery)} → \texttt{List<SubscriptionPlan>} \\*
\hline
\textbf{Parámetros} & Ninguno \\*
\hline
\textbf{Estrategia de Caché} & Caché global en memoria volátil de alta duración bajo la clave activePlans con desalojo reactivo ante modificaciones en el catálogo. \\
\hline
\textbf{Consulta:} \texttt{Get\allowbreak Subscription\allowbreak Plan\allowbreak By\allowbreak Id\allowbreak Query} & \texttt{handle(GetSubscriptionPlanByIdQuery)} → \texttt{Optional<SubscriptionPlan>} \\*
\hline
\textbf{Parámetros} & \texttt{PlanId planId} \\*
\hline
\textbf{Estrategia de Caché} & Recuperación de la especificación técnica completa y funcionalidades hijas PlanFeature por identificador UUID. \\
\hline
\textbf{Consulta:} \texttt{Get\allowbreak Subscription\allowbreak Plan\allowbreak By\allowbreak Stripe\allowbreak Price\allowbreak Id\allowbreak Query} & \texttt{handle(GetSubscriptionPlanByStripePriceIdQuery)} → \texttt{Optional<SubscriptionPlan>} \\*
\hline
\textbf{Parámetros} & \texttt{StripePriceId stripePriceId} \\*
\hline
\textbf{Estrategia de Caché} & Consulta indexada en base de datos relacional para asociar notificaciones de Stripe con el catálogo interno de Andeva. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Consultas:} Saas\allowbreak Invoice\allowbreak Query\allowbreak Service\allowbreak Impl} \\*
\hline
\textbf{Consulta:} \texttt{Get\allowbreak Invoices\allowbreak By\allowbreak Tenant\allowbreak Id\allowbreak Query} & \texttt{handle(GetInvoicesByTenantIdQuery)} → \texttt{List<SaasInvoice>} \\*
\hline
\textbf{Parámetros} & \texttt{TenantId tenantId, int page, int size, InvoiceStatus status} \\*
\hline
\textbf{Estrategia de Caché} & Consulta paginada y filtrada directamente en PostgreSQL optimizada mediante índice idx\_invoices\_tenant para generación de historiales contables. \\
\hline
\textbf{Consulta:} \texttt{Get\allowbreak Saas\allowbreak Invoice\allowbreak By\allowbreak Id\allowbreak Query} & \texttt{handle(GetSaasInvoiceByIdQuery)} → \texttt{Optional<SaasInvoice>} \\*
\hline
\textbf{Parámetros} & \texttt{SaasInvoiceId invoiceId} \\*
\hline
\textbf{Estrategia de Caché} & Recuperación del detalle contable individual y verificación de pertenencia del comprobante respecto al taller solicitante. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de consultas y esquemas de aceleración en memoria volátil de la Capa de Aplicación, organizados en queryservices e internal.queryservices.

**Manejadores de Eventos de Dominio y de Integración**

La reactividad interna del contexto y su coordinación con otros Bounded Contexts se canaliza mediante manejadores de eventos desacoplados y un publicador transaccional Outbox, garantizando consistencia eventual y entrega confiable:

- **SubscriptionDomainEventHandler**: Escucha eventos de dominio de activaciones, renovaciones periódicas, mora bancaria y cancelaciones, ejecutando en fase posterior al commit la invalidación de memorias volátiles y el despacho de notificaciones transaccionales.

- **TenantLifecycleIntegrationEventHandler**: Consume el evento de integración de registro emitido por IAM & Tenancy, gatillando automáticamente la creación del cliente en la bóveda de Stripe y activando una membresía de prueba gratuita de catorce días.

- **BillingTransactionalOutboxPublisher**: Intercepta eventos de dominio e integración para persistirlos de forma atómica en la tabla outbox\_messages dentro de la misma transacción de PostgreSQL, garantizando entrega de tipo At-Least-Once hacia el bus de mensajería sin incurrir en bloqueos distribuidos.

En la @tbl:billing-event-handlers se especifican los eventos interceptados por los manejadores, detallando sus fases de ejecución, orígenes y consecuencias arquitectónicas.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Manejadores de Eventos de Dominio y de Integración de SaaS Billing \& Subscriptions} \label{tbl:billing-event-handlers} \\
\hline
\thfirst{Evento Interceptado} & \thcell{Fase de Ejecución y Efectos del Manejador} \\
\hline
\endfirsthead
\hline
\thfirst{Evento Interceptado} & \thcell{Fase de Ejecución y Efectos del Manejador} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador de Eventos de Dominio:} Subscription\allowbreak Domain\allowbreak Event\allowbreak Handler} \\*
\hline
\textbf{Evento:} \texttt{Tenant\allowbreak Subscription\allowbreak Activated\allowbreak Event} & Ejecución en fase \texttt{AFTER\_COMMIT} mediante \texttt{@TransactionalEventListener} \\*
\hline
\textbf{Origen del Suceso} & Raíz de Agregado TenantSubscription ante activación de plan o inicio de prueba \\*
\hline
\textbf{Efectos del Manejador} & Purga la memoria volátil de Caffeine mediante BillingCachePort y solicita a TenantBillingNotificationGatewayPort el envío del mensaje formal de bienvenida y confirmación de activación. \\
\hline
\textbf{Evento:} \texttt{Tenant\allowbreak Subscription\allowbreak Renewed\allowbreak Event} & Ejecución en fase \texttt{AFTER\_COMMIT} mediante \texttt{@TransactionalEventListener} \\*
\hline
\textbf{Origen del Suceso} & Raíz de Agregado TenantSubscription ante recaudación periódica exitosa \\*
\hline
\textbf{Efectos del Manejador} & Invalida y refresca la política contractual en Caffeine Cache vía BillingCachePort, garantizando que los módulos del ERP reconozcan de inmediato la extensión del periodo pagado. \\
\hline
\textbf{Evento:} \texttt{Tenant\allowbreak Subscription\allowbreak Past\allowbreak Due\allowbreak Event} & Ejecución en fase \texttt{AFTER\_COMMIT} mediante \texttt{@TransactionalEventListener} \\*
\hline
\textbf{Origen del Suceso} & Raíz de Agregado TenantSubscription ante débito bancario fallido en Stripe \\*
\hline
\textbf{Efectos del Manejador} & Despacha una notificación electrónica prioritaria al administrador del taller mediante TenantBillingNotificationGatewayPort con enlace interactivo al Stripe Customer Portal para regularizar su tarjeta bancaria antes de la suspensión forzosa. \\
\hline
\textbf{Evento:} \texttt{Tenant\allowbreak Subscription\allowbreak Canceled\allowbreak Event} & Ejecución en fase \texttt{AFTER\_COMMIT} mediante \texttt{@TransactionalEventListener} \\*
\hline
\textbf{Origen del Suceso} & Raíz de Agregado TenantSubscription ante rescisión voluntaria o forzosa \\*
\hline
\textbf{Efectos del Manejador} & Purga la caché local de autorizaciones en BillingCachePort, propaga el evento de cancelación y emite correo de notificación de cese de servicio mediante TenantBillingNotificationGatewayPort. \\
\hline
\textbf{Evento:} \texttt{Saas\allowbreak Invoice\allowbreak Payment\allowbreak Succeeded\allowbreak Event} & Ejecución en fase \texttt{AFTER\_COMMIT} mediante \texttt{@TransactionalEventListener} \\*
\hline
\textbf{Origen del Suceso} & Raíz de Agregado SaasInvoice ante asentamiento de cobro formal \\*
\hline
\textbf{Efectos del Manejador} & Genera y despacha el comprobante contable digital al correo electrónico del área financiera del taller mecánico incorporando el enlace oficial de descarga del PDF mediante TenantBillingNotificationGatewayPort. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador de Eventos de Integración:} Tenant\allowbreak Lifecycle\allowbreak Integration\allowbreak Event\allowbreak Handler} \\*
\hline
\textbf{Evento:} \texttt{Tenant\allowbreak Registered\allowbreak Integration\allowbreak Event} & Ejecución asíncrona desacoplada mediante consumidor del bus de eventos \\*
\hline
\textbf{Origen del Suceso} & Bounded Context IAM \& Tenancy ante alta y registro corporativo de nuevo taller \\*
\hline
\textbf{Efectos del Manejador} & Aprovisiona de forma desatendida un cliente en Stripe mediante StripeGatewayPort, valida los datos del taller vía IamTenantValidationAclPort, vincula una suscripción de prueba gratuita de 14 días bajo el nivel comercial PRO y activa la cuenta sin fricción para el usuario. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Publicador Transaccional Outbox:} Billing\allowbreak Transactional\allowbreak Outbox\allowbreak Publisher} \\*
\hline
\textbf{Evento:} \texttt{Billing\allowbreak Integration\allowbreak Event} & Ejecución dentro de la misma transacción ACID local antes de la confirmación \\*
\hline
\textbf{Origen del Suceso} & Mutaciones de ciclo de vida contractual en agregados TenantSubscription y SubscriptionPlan \\*
\hline
\textbf{Efectos del Manejador} & Serializa las cargas útiles de eventos de integración en formato JSON y las persiste atómicamente en la tabla outbox\_messages con garantía de entrega At-Least-Once hacia el bus de mensajería sin recurrir a bloqueos distribuidos. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de manejadores de eventos y orquestación reactiva de la Capa de Aplicación bajo el paquete canónico internal.eventhandlers.

**Puertos de Salida, Pasarelas y Adaptadores Anticorrupción**

La comunicación hacia proveedores externos, servicios de plataforma y mecanismos de almacenamiento temporal se aísla rigurosamente mediante puertos de salida agnósticos situados bajo el subpaquete canónico **com.andeva.atelier.platform.billing.application.internal.outbound.acl**:

- **StripeGatewayPort**: Encapsula las operaciones remotas hacia la infraestructura de Stripe, protegiendo al núcleo del software frente a dependencias directas del SDK de la pasarela y traduciendo anomalías telemáticas a excepciones semánticas.

- **TenantBillingNotificationGatewayPort**: Desacopla la lógica de negocio respecto a los mecanismos de transporte SMTP o HTTP en la nube para el envío de alertas de cobranza, confirmaciones de activación y comprobantes de recaudación hacia los administradores.

- **IamTenantValidationAclPort**: Provee acceso seguro a los metadatos de identidad y perfiles de los talleres automotrices, salvaguardando la autonomía de datos de SaaS Billing & Subscriptions frente al modelo relacional de IAM & Tenancy.

- **BillingCachePort**: Abstrae el acceso y desalojo reactivo de políticas contractuales y cuotas operativas en memoria volátil de alta velocidad con Caffeine Cache, resolviendo comprobaciones de autorización en submilisegundos.

En la @tbl:billing-outbound-ports se detallan los puertos de salida de la capa de aplicación, sus signaturas de métodos y sus adaptadores concretos de infraestructura.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Puertos de Salida, Pasarelas y Adaptadores de la Capa de Aplicación de SaaS Billing \& Subscriptions} \label{tbl:billing-outbound-ports} \\
\hline
\thfirst{Puerto de Salida} & \thcell{Firma de Operaciones y Adaptador de Infraestructura} \\
\hline
\endfirsthead
\hline
\thfirst{Puerto de Salida} & \thcell{Firma de Operaciones y Adaptador de Infraestructura} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} Stripe\allowbreak Gateway\allowbreak Port} \\*
\hline
\textbf{Operación Principal} & \texttt{createCustomer(TenantId, String email, String name)} → \texttt{StripeCustomerId} \\*
\hline
\textbf{Operaciones Secundarias} & - \texttt{createCheckoutSession(CheckoutSessionParams)} → \texttt{CheckoutSessionDto} \newline - \texttt{createCustomerPortalSession(StripeCustomerId, String returnUrl)} → \texttt{String} \newline - \texttt{cancelSubscription(StripeSubscriptionId, boolean immediately)} → \texttt{void} \newline - \texttt{retrieveInvoice(StripeInvoiceId)} → \texttt{StripeInvoiceDto} \\*
\hline
\textbf{Adaptador Concreto} & StripeGatewayAdapter en la capa de infraestructura mediante el SDK oficial stripe-java \\*
\hline
\textbf{Propósito Arquitectónico} & Aislar por completo las dependencias y tipos foráneos de la pasarela Stripe del núcleo del software Atelier traduciendo anomalías externas a excepciones de dominio. \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak internal.\allowbreak outbound.\allowbreak acl} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} Tenant\allowbreak Billing\allowbreak Notification\allowbreak Gateway\allowbreak Port} \\*
\hline
\textbf{Operación Principal} & \texttt{sendSubscriptionActivatedEmail(TenantId, String recipient, String planName)} → \texttt{void} \\*
\hline
\textbf{Operaciones Secundarias} & - \texttt{sendPaymentFailedAlertEmail(TenantId, String recipient, String portalUrl)} → \texttt{void} \newline - \texttt{sendSubscriptionCanceledEmail(TenantId, String recipient, Instant effectiveDate)} → \texttt{void} \newline - \texttt{sendInvoiceReceiptEmail(TenantId, String recipient, String invoicePdfUrl)} → \texttt{void} \\*
\hline
\textbf{Adaptador Concreto} & ResendTenantBillingNotificationAdapter en la capa de infraestructura consumiendo el servicio Resend \\*
\hline
\textbf{Propósito Arquitectónico} & Desacoplar la lógica de notificaciones financieras respecto a proveedores concretos de transporte de correo electrónico en la nube. \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak internal.\allowbreak outbound.\allowbreak acl} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} Iam\allowbreak Tenant\allowbreak Validation\allowbreak Acl\allowbreak Port} \\*
\hline
\textbf{Operación Principal} & \texttt{getTenantProfile(TenantId)} → \texttt{Optional<TenantProfileDto>} \\*
\hline
\textbf{Operaciones Secundarias} & - \texttt{validateTenantExistence(TenantId)} → \texttt{boolean} \newline - \texttt{getTenantAdminEmail(TenantId)} → \texttt{Optional<String>} \\*
\hline
\textbf{Adaptador Concreto} & IamTenantValidationAclAdapter en la capa de infraestructura invocando la fachada de IAM \& Tenancy \\*
\hline
\textbf{Propósito Arquitectónico} & Proveer acceso a metadatos de identidad del taller automotriz sin acoplar la capa de aplicación de Billing a las entidades relacionales de IAM. \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak internal.\allowbreak outbound.\allowbreak acl} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} Billing\allowbreak Cache\allowbreak Port} \\*
\hline
\textbf{Operación Principal} & \texttt{getSubscriptionStatus(TenantId)} → \texttt{Optional<TenantSubscriptionStatusDto>} \\*
\hline
\textbf{Operaciones Secundarias} & - \texttt{putSubscriptionStatus(TenantId, TenantSubscriptionStatusDto)} → \texttt{void} \newline - \texttt{evictSubscriptionStatus(TenantId)} → \texttt{void} \newline - \texttt{getQuotaLimits(TenantId)} → \texttt{Optional<TenantQuotaLimitsDto>} \newline - \texttt{putQuotaLimits(TenantId, TenantQuotaLimitsDto)} → \texttt{void} \\*
\hline
\textbf{Adaptador Concreto} & CaffeineBillingCacheAdapter en la capa de infraestructura utilizando el motor de caché en memoria Caffeine \\*
\hline
\textbf{Propósito Arquitectónico} & Proveer una abstracción de acceso a caché de alta velocidad en memoria volátil RAM para comprobación de cuotas operativas con latencia sub-milisegundo. \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak billing.\allowbreak application.\allowbreak internal.\allowbreak outbound.\allowbreak acl} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de puertos de salida y adaptadores de infraestructura organizados en internal.outbound.acl.

La arquitectura implementada en la Capa de Aplicación de SaaS Billing & Subscriptions consolida una frontera transaccional limpia que preserva la consistencia de los contratos corporativos sin comprometer la agilidad operativa del taller. Al articular los casos de uso bajo el patrón CQRS, el sistema asegura que las mutaciones financieras se ejecuten con aislamiento riguroso y auditoría completa, mientras que las consultas intensivas de licenciamiento se atienden con máxima concurrencia y mínima latencia.

Asimismo, la integración desacoplada con la pasarela Stripe resuelve eficazmente los desafíos inherentes a la comunicación asíncrona y la resiliencia de red. El procesamiento idempotente basado en la tabla de eventos mitiga de raíz el riesgo de facturaciones duplicadas o inconsistencias de estado ante reintentos automáticos, blindando la integridad financiera de Andeva y la confianza de los talleres asociados.

Por último, la sincronización armónica entre los eventos de dominio y la memoria en caché de Caffeine materializa un balance óptimo entre inmediatez y frescura de datos. Las consultas frecuentes de autorización de cuotas operativas se resuelven en memoria local sin penalizar la base de datos relacional, garantizando que tanto las estaciones fijas de trabajo como las unidades de auxilio mecánico en campo operen con fluidez continua.

#### 2.6.8.4. Infrastructure Layer

La Capa de Infraestructura del Bounded Context SaaS Billing & Subscriptions, materializada bajo el paquete canónico **com.andeva.atelier.platform.billing.infrastructure**, provee los mecanismos de persistencia relacional física, integración telemática con pasarelas de pago internacionales y comunicación perimetral desacoplada con el ecosistema de microservicios y servicios en la nube. Esta capa implementa los contratos de repositorio y puertos de salida definidos en el dominio y la aplicación mediante Spring Data JPA e Hibernate sobre PostgreSQL 16 alojado en Aiven Cloud, asegurando la consistencia transaccional de los ciclos de cobro, el aislamiento multi-inquilino de los registros de suscripción, la inmutabilidad y trazabilidad de los recibos emitidos, y la estricta idempotencia de eventos asíncronos recibidos mediante webhooks.

Las directrices técnicas fundamentales que rigen el diseño de la Capa de Infraestructura abarcan los siguientes pilares de arquitectura:

- **Persistencia físico-relacional auditada y modelado de cuotas comerciales:** Mapeo de agregados de dominio a tablas relacionales normalizadas en PostgreSQL 16, extendiendo de entidades abstractas de auditoría temporal para preservar marcas de creación y modificación en UTC sin intervención manual.
- **Garantía de idempotencia transaccional y protección contra eventos duplicados:** Registro atómico y verificación previa de identificadores de evento de Stripe en la tabla de auditoría con restricción de unicidad estricta, previniendo el procesamiento redundante de transacciones financieras ante reintentos de red.
- **Reconstitución pura del modelo de dominio y transformación desacoplada:** Ensambladores de persistencia dedicados que hidratan agregados y objetos de valor sin generar emisiones espurias de eventos de dominio durante operaciones de consulta, complementados con convertidores JPA para tipos enumerados y estructuras escalares.
- **Aislamiento perimetral y resiliencia de integración en la nube:** Adaptadores salientes que encapsulan el SDK oficial de Stripe con manejo seguro de credenciales, traducción de excepciones técnicas a excepciones semánticas de dominio, despacho de notificaciones transaccionales vía Resend y almacenamiento en memoria de validaciones de cuota mediante Caffeine Cache para garantizar tiempos de respuesta sub-milisegundo.

En la @tbl:billing-infrastructure-types se sintetiza el catálogo consolidado de clases, entidades de persistencia, adaptadores de repositorio, ensambladores, convertidores y pasarelas de infraestructura que configuran este perímetro.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo Consolidado de la Capa de Infraestructura de SaaS Billing \& Subscriptions} \label{tbl:billing-infrastructure-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\
\hline
\endhead
Subscription\allowbreak Plan\allowbreak Persistence\allowbreak Entity & Mapeo relacional de planes comerciales y cuotas operativas hacia la tabla física plans. \\*
\hline
\textbf{Categoría} & Entidad de Persistencia JPA \\*
\hline
\textbf{Relaciones} & Hereda de AuditableAbstractPersistenceEntity. Raíz de persistencia con colección en cascada hacia PlanFeaturePersistenceEntity. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Plan\allowbreak Feature\allowbreak Persistence\allowbreak Entity & Mapeo relacional de módulos funcionales y banderas de activación hacia la tabla plan\_features. \\*
\hline
\textbf{Categoría} & Entidad de Persistencia JPA \\*
\hline
\textbf{Relaciones} & Clave foránea hacia SubscriptionPlanPersistenceEntity. Restricción de unicidad compuesta sobre identificador de plan y clave funcional. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Tenant\allowbreak Subscription\allowbreak Persistence\allowbreak Entity & Mapeo relacional del ciclo de vida de membresías de talleres hacia la tabla física subscriptions. \\*
\hline
\textbf{Categoría} & Entidad de Persistencia JPA \\*
\hline
\textbf{Relaciones} & Hereda de AuditableAbstractPersistenceEntity. Clave foránea lógica hacia tenants y plans. Índices por estado y suscripción de Stripe. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Saas\allowbreak Invoice\allowbreak Persistence\allowbreak Entity & Mapeo relacional de comprobantes contables y recibos de cobro hacia la tabla física saas\_invoices. \\*
\hline
\textbf{Categoría} & Entidad de Persistencia JPA \\*
\hline
\textbf{Relaciones} & Hereda de AuditableAbstractPersistenceEntity. Clave foránea hacia subscriptions y tenants. Custodia enlaces seguros a facturas en Stripe. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Stripe\allowbreak Webhook\allowbreak Event\allowbreak Persistence\allowbreak Entity & Mapeo de auditoría forense y control estricto de idempotencia hacia la tabla física stripe\_webhook\_events. \\*
\hline
\textbf{Categoría} & Entidad de Persistencia JPA \\*
\hline
\textbf{Relaciones} & Restricción de unicidad estricta sobre el identificador nativo de Stripe impidiendo doble procesamiento transaccional. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Subscription\allowbreak Plan\allowbreak Persistence\allowbreak Repository & Interfaz de persistencia Spring Data JPA para administración del catálogo de planes y precios en Stripe. \\*
\hline
\textbf{Categoría} & Repositorio Spring Data JPA \\*
\hline
\textbf{Relaciones} & Extiende JpaRepository. Consultas unívocas por identificador de precio en Stripe y listado de planes activos en plataforma. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Tenant\allowbreak Subscription\allowbreak Persistence\allowbreak Repository & Interfaz de persistencia Spring Data JPA para administración relacional de suscripciones de talleres. \\*
\hline
\textbf{Categoría} & Repositorio Spring Data JPA \\*
\hline
\textbf{Relaciones} & Extiende JpaRepository. Búsqueda por identificador de taller, identificador de suscripción de Stripe y verificación booleana de estado. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Saas\allowbreak Invoice\allowbreak Persistence\allowbreak Repository & Interfaz de persistencia Spring Data JPA para consultas de facturas de plataforma e historial de cobros. \\*
\hline
\textbf{Categoría} & Repositorio Spring Data JPA \\*
\hline
\textbf{Relaciones} & Extiende JpaRepository. Búsqueda unívoca por factura de Stripe y recuperación cronológica paginada por taller. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Stripe\allowbreak Webhook\allowbreak Event\allowbreak Persistence\allowbreak Repository & Interfaz de persistencia Spring Data JPA para trazabilidad e idempotencia de notificaciones de eventos externos. \\*
\hline
\textbf{Categoría} & Repositorio Spring Data JPA \\*
\hline
\textbf{Relaciones} & Extiende JpaRepository. Verificación booleana ultra rápida de existencia y recuperación de eventos para auditoría de errores. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Subscription\allowbreak Plan\allowbreak Repository\allowbreak Impl & Adaptador secundario de salida que implementa el puerto de dominio SubscriptionPlanRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Repositorio de Persistencia \\*
\hline
\textbf{Relaciones} & Implementa SubscriptionPlanRepository delegando en SubscriptionPlanPersistenceRepository y ensamblador bidireccional. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Tenant\allowbreak Subscription\allowbreak Repository\allowbreak Impl & Adaptador secundario de salida que implementa el puerto de dominio TenantSubscriptionRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Repositorio de Persistencia \\*
\hline
\textbf{Relaciones} & Implementa TenantSubscriptionRepository gestionando transaccionalidad atómica y sincronización de estados operativos. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Saas\allowbreak Invoice\allowbreak Repository\allowbreak Impl & Adaptador secundario de salida que implementa el puerto de dominio SaasInvoiceRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Repositorio de Persistencia \\*
\hline
\textbf{Relaciones} & Implementa SaasInvoiceRepository persistiendo facturas emitidas y facilitando consultas históricas paginadas. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Stripe\allowbreak Webhook\allowbreak Event\allowbreak Repository\allowbreak Impl & Adaptador secundario de salida que implementa el puerto de dominio StripeWebhookEventRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Repositorio de Persistencia \\*
\hline
\textbf{Relaciones} & Implementa StripeWebhookEventRepository garantizando inserción atómica y detección de eventos duplicados en base de datos. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Subscription\allowbreak Plan\allowbreak Persistence\allowbreak Assembler & Ensamblador de datos para transformación bidireccional entre el agregado SubscriptionPlan y su entidad JPA. \\*
\hline
\textbf{Categoría} & Ensamblador de Persistencia JPA \\*
\hline
\textbf{Relaciones} & Convierte cuotas comerciales en columnas escalares y mapea entidades de funcionalidad sin emitir eventos espurios. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak assemblers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Tenant\allowbreak Subscription\allowbreak Persistence\allowbreak Assembler & Ensamblador de datos para transformación bidireccional entre el agregado TenantSubscription y su entidad JPA. \\*
\hline
\textbf{Categoría} & Ensamblador de Persistencia JPA \\*
\hline
\textbf{Relaciones} & Reconstituye agregados de suscripción vinculando identificadores foráneos y fechas de período de facturación en UTC. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak assemblers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Saas\allowbreak Invoice\allowbreak Persistence\allowbreak Assembler & Ensamblador de datos para transformación bidireccional entre el agregado SaasInvoice y su entidad JPA. \\*
\hline
\textbf{Categoría} & Ensamblador de Persistencia JPA \\*
\hline
\textbf{Relaciones} & Mapea montos facturados, referencias de pago en Stripe, URLs de descarga de comprobantes y marcas temporales. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak assemblers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Stripe\allowbreak Webhook\allowbreak Event\allowbreak Persistence\allowbreak Assembler & Ensamblador de datos para transformación bidireccional entre la entidad StripeWebhookEvent y su entidad JPA. \\*
\hline
\textbf{Categoría} & Ensamblador de Persistencia JPA \\*
\hline
\textbf{Relaciones} & Reconstituye registros de auditoría de webhooks preservando la carga JSON original para análisis forense de fallos. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak assemblers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Plan\allowbreak Tier\allowbreak Converter & Convertidor JPA para serialización del tipo enumerado PlanTier a columna relacional VARCHAR(20). \\*
\hline
\textbf{Categoría} & Conversor de Tipos JPA \\*
\hline
\textbf{Relaciones} & Mapea los niveles comerciales GO, PRO, MAX y ENTERPRISE. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Subscription\allowbreak Status\allowbreak Converter & Convertidor JPA para serialización del estado de suscripción SubscriptionStatus a columna VARCHAR(20). \\*
\hline
\textbf{Categoría} & Conversor de Tipos JPA \\*
\hline
\textbf{Relaciones} & Normaliza estados operativos INCOMPLETE, TRIALING, ACTIVE, PAST\_DUE, CANCELED y UNPAID. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Invoice\allowbreak Status\allowbreak Converter & Convertidor JPA para mapeo del ciclo de cobro InvoiceStatus a columna relacional VARCHAR(20). \\*
\hline
\textbf{Categoría} & Conversor de Tipos JPA \\*
\hline
\textbf{Relaciones} & Normaliza estados financieros DRAFT, OPEN, PAID, VOID y UNCOLLECTIBLE. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Billing\allowbreak Cycle\allowbreak Converter & Convertidor JPA para mapeo de periodicidad de facturación BillingCycle a columna VARCHAR(20). \\*
\hline
\textbf{Categoría} & Conversor de Tipos JPA \\*
\hline
\textbf{Relaciones} & Mapea frecuencias periódicas MONTHLY y ANNUAL. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Webhook\allowbreak Processing\allowbreak Status\allowbreak Converter & Convertidor JPA para mapeo del estado WebhookProcessingStatus a columna relacional VARCHAR(20). \\*
\hline
\textbf{Categoría} & Conversor de Tipos JPA \\*
\hline
\textbf{Relaciones} & Normaliza estados PENDING, PROCESSED, FAILED e IGNORED en el registro de auditoría de webhooks. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Tenant\allowbreak Quota\allowbreak Limits\allowbreak Converter & Convertidor JPA para serialización estructurada del objeto de valor TenantQuotaLimits a columna relacional. \\*
\hline
\textbf{Categoría} & Conversor de Tipos JPA \\*
\hline
\textbf{Relaciones} & Serializa cuotas cuantitativas y banderas modulares para comprobación ágil de límites operativos. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Stripe\allowbreak Gateway\allowbreak Adapter & Adaptador de salida perimetral que interactúa con los servicios de pasarela de pago internacional Stripe. \\*
\hline
\textbf{Categoría} & Adaptador de Pasarela de Pagos Externa \\*
\hline
\textbf{Relaciones} & Implementa el puerto StripeGatewayPort utilizando el cliente oficial StripeClient y encapsulando credenciales seguras. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak external.\allowbreak payment.\allowbreak stripe} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Stripe\allowbreak Webhook\allowbreak Signature\allowbreak Verifier\allowbreak Adapter & Adaptador perimetral de verificación criptográfica de cabeceras de firma para webhooks de Stripe. \\*
\hline
\textbf{Categoría} & Adaptador de Pasarela de Pagos Externa \\*
\hline
\textbf{Relaciones} & Valida firmas HMAC-SHA256 y tolerancia temporal de eventos protegiendo al dominio frente a suplantación. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak external.\allowbreak payment.\allowbreak stripe} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Resend\allowbreak Billing\allowbreak Notification\allowbreak Adapter & Pasarela de notificaciones transaccionales para despacho de correos electrónicos vía API REST de Resend. \\*
\hline
\textbf{Categoría} & Adaptador de Correo Transaccional \\*
\hline
\textbf{Relaciones} & Implementa TenantBillingNotificationGatewayPort enviando recibos de pago, confirmaciones de alta y avisos de cobro. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak external.\allowbreak mail.\allowbreak resend} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Iam\allowbreak Tenant\allowbreak Validation\allowbreak Adapter & Adaptador de integración intermodular para consulta en memoria de información corporativa de talleres. \\*
\hline
\textbf{Categoría} & Adaptador Anticorrupción ACL \\*
\hline
\textbf{Relaciones} & Implementa IamTenantValidationAclPort consumiendo TenancyContextFacade sin generar acoplamiento físico en base de datos. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak external.\allowbreak acl.\allowbreak iam} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Caffeine\allowbreak Billing\allowbreak Cache\allowbreak Adapter & Adaptador de almacenamiento en memoria para resolución ultra veloz de membresías y límites operativos. \\*
\hline
\textbf{Categoría} & Adaptador de Caché en Memoria \\*
\hline
\textbf{Relaciones} & Implementa BillingCachePort gestionando almacenamiento y desalojo reactivo en cachés Caffeine en memoria RAM. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak external.\allowbreak cache.\allowbreak caffeine} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Caffeine\allowbreak Cache\allowbreak Configuration & Clase de configuración de infraestructura de almacenamiento en caché en memoria de alto rendimiento. \\*
\hline
\textbf{Categoría} & Configuración de Infraestructura \\*
\hline
\textbf{Relaciones} & Configura BillingCacheManager gestionando cachés tenantSubscriptionStatus y activePlans con latencia sub-milisegundo. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak external.\allowbreak cache.\allowbreak caffeine} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Billing\allowbreak Outbox\allowbreak Message\allowbreak Relay\allowbreak Adapter & Adaptador de despacho y relevo transaccional asíncrono de eventos de integración hacia el bus de la plataforma. \\*
\hline
\textbf{Categoría} & Adaptador de Relé Transaccional Outbox \\*
\hline
\textbf{Relaciones} & Consulta periódicamente outbox\_messages y publica eventos de suscripción y facturación con garantía At-Least-Once. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak external.\allowbreak messaging.\allowbreak outbox} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Catálogo taxonómico de tipos de la Capa de Infraestructura, organizados en los subpaquetes modulares persistence.jpa.entities, persistence.jpa.repositories, persistence.jpa.adapters, persistence.jpa.assemblers, persistence.jpa.converters, external.payment.stripe, external.mail.resend, external.acl.iam, external.cache.caffeine y external.messaging.outbox.

**Entidades de Persistencia JPA y Modelado Relacional Físico**

El modelado relacional de persistencia reproduce fielmente la topología comercial y de cuotas del dominio SaaS mediante cinco entidades JPA mapeadas a sus respectivas tablas físicas en PostgreSQL 16. La entidad **SubscriptionPlanPersistenceEntity** se vincula a la tabla **plans**, encapsulando el identificador del plan tarifario en Stripe, precios monetarios, periodicidad de facturación, cuotas de sucursales y personal, y banderas booleanas de acceso a telemetría IoT y diagnóstico predictivo. A su vez, la entidad **PlanFeaturePersistenceEntity** mapea las características funcionales específicas a la tabla **plan_features**, manteniendo integridad referencial en cascada total.

Por su parte, la entidad **TenantSubscriptionPersistenceEntity** custodia el ciclo de vida de membresía de cada taller en la tabla **subscriptions**, vinculando el cliente y la suscripción remota de Stripe con estados formales y fechas límite de cobertura. La entidad **SaasInvoicePersistenceEntity** estructura los comprobantes contables en la tabla **saas_invoices**, almacenando montos devengados, fechas de pago y enlaces a documentos probatorios. Finalmente, la entidad **StripeWebhookEventPersistenceEntity** opera sobre la tabla **stripe_webhook_events** para blindar la plataforma ante eventuales reintentos de red de la pasarela. En la @tbl:billing-jpa-entities se detallan los esquemas relacionales, claves primarias, índices B-Tree y restricciones de verificación de estas entidades.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Especificación Relacional de Entidades JPA de SaaS Billing \& Subscriptions} \label{tbl:billing-jpa-entities} \\
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} SubscriptionPlanPersistenceEntity \quad (\textit{Tabla:} \texttt{plans})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{stripe\_price\_id}, \texttt{name}, \texttt{tier}, \texttt{price}, \texttt{currency}, \texttt{billing\_cycle}, \texttt{max\_branches}, \texttt{max\_active\_staff}, \texttt{max\_monthly\_work\_orders}, \texttt{iot\_telemetry\_enabled}, \texttt{ai\_diagnostics\_enabled}, \texttt{is\_active}, \texttt{created\_at}, \texttt{updated\_at} \\*
\hline
\textbf{Restricciones e Índices} & Restricción de unicidad uk\_plans\_stripe\_price sobre stripe\_price\_id. Restricciones de verificación chk\_plans\_price\_positive sobre price no negativo y chk\_plans\_quotas\_positive sobre max\_branches y max\_active\_staff mayores a cero. Índice B-Tree idx\_plans\_tier\_active sobre (tier, is\_active) para consulta acelerada de planes comerciales activos. Relación de cascada total con eliminación de huérfanos hacia plan\_features. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} PlanFeaturePersistenceEntity \quad (\textit{Tabla:} \texttt{plan\_features})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{plan\_id}, \texttt{feature\_key}, \texttt{name}, \texttt{description}, \texttt{is\_enabled} \\*
\hline
\textbf{Restricciones e Índices} & Clave foránea fk\_plan\_features\_plan hacia plans con eliminación en cascada. Restricción de unicidad compuesta uk\_plan\_features\_plan\_key sobre la tupla (plan\_id, feature\_key). Índice B-Tree idx\_plan\_features\_lookup sobre (plan\_id, is\_enabled) para comprobación inmediata de funcionalidades durante verificaciones de cuota. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} TenantSubscriptionPersistenceEntity \quad (\textit{Tabla:} \texttt{subscriptions})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{tenant\_id}, \texttt{plan\_id}, \texttt{stripe\_customer\_id}, \texttt{stripe\_sub\_id}, \texttt{status}, \texttt{current\_period\_start}, \texttt{current\_period\_end}, \texttt{cancel\_at\_period\_end}, \texttt{canceled\_at}, \texttt{trial\_end\_date}, \texttt{created\_at}, \texttt{updated\_at} \\*
\hline
\textbf{Restricciones e Índices} & Restricción de unicidad uk\_subscriptions\_tenant sobre tenant\_id garantizando una única suscripción por taller. Clave foránea fk\_subscriptions\_plan hacia plans. Restricción de verificación chk\_subscription\_periods para asegurar que current\_period\_end sea posterior a current\_period\_start. Índices B-Tree idx\_subscriptions\_stripe\_sub sobre stripe\_sub\_id e idx\_subscriptions\_status sobre status. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} SaasInvoicePersistenceEntity \quad (\textit{Tabla:} \texttt{saas\_invoices})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{subscription\_id}, \texttt{tenant\_id}, \texttt{stripe\_invoice\_id}, \texttt{amount\_paid}, \texttt{currency}, \texttt{status}, \texttt{invoice\_pdf\_url}, \texttt{hosted\_invoice\_url}, \texttt{paid\_at}, \texttt{created\_at}, \texttt{updated\_at} \\*
\hline
\textbf{Restricciones e Índices} & Claves foráneas fk\_saas\_invoices\_subscription hacia subscriptions y fk\_saas\_invoices\_tenant hacia tenants. Restricción de unicidad uk\_saas\_invoices\_stripe\_inv sobre stripe\_invoice\_id. Restricción de verificación chk\_saas\_invoice\_amount\_non\_negative para importe monetario no negativo. Índices B-Tree idx\_saas\_invoices\_tenant\_created sobre (tenant\_id, created\_at DESC) e idx\_saas\_invoices\_stripe\_lookup sobre stripe\_invoice\_id. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} StripeWebhookEventPersistenceEntity \quad (\textit{Tabla:} \texttt{stripe\_webhook\_events})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{stripe\_event\_id}, \texttt{type}, \texttt{payload}, \texttt{status}, \texttt{processed\_at}, \texttt{error\_message} \\*
\hline
\textbf{Restricciones e Índices} & Restricción de unicidad estricta uk\_stripe\_webhook\_events\_event\_id sobre stripe\_event\_id que actúa como cerrojo de concurrencia para evitar doble ejecución de webhooks. Índice B-Tree idx\_stripe\_webhook\_events\_type\_status sobre (type, status, processed\_at DESC) para auditoría operativa y depuración de eventos fallidos. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación relacional en PostgreSQL 16 con esquema multi-inquilino bajo Aiven Cloud.

**Repositorios Spring Data JPA y Adaptadores de Persistencia**

La mediación entre las invariantes del modelo de dominio y las operaciones físicas de base de datos se articula mediante interfaces Spring Data JPA y sus correspondientes adaptadores secundarios de persistencia. El adaptador **SubscriptionPlanRepositoryImpl** implementa el puerto de dominio **SubscriptionPlanRepository**, orquestando la persistencia de planes comerciales y su recuperación ágil por identificador de precio de Stripe. Por su parte, el adaptador **TenantSubscriptionRepositoryImpl** materializa las operaciones de **TenantSubscriptionRepository**, sincronizando de forma atómica las transiciones de estado de los talleres tras confirmaciones de pago o solicitudes de cancelación.

Asimismo, el adaptador **SaasInvoiceRepositoryImpl** gestiona el archivo inmutable de recibos en la tabla de facturación mediante el puerto **SaasInvoiceRepository**, ofreciendo consultas paginadas que alimentan el panel de administración contable del taller sin penalizar la memoria de trabajo. Finalmente, el adaptador **StripeWebhookEventRepositoryImpl** resguarda la integridad del sistema al verificar la existencia previa de cada identificador de notificación en la tabla de eventos de Stripe antes de delegar la ejecución a los servicios de comando. En la @tbl:billing-repository-adapters se detallan los puertos de dominio, repositorios Spring Data inyectados, contratos transaccionales y operaciones provistas por estos componentes.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Adaptadores de Persistencia y Puertos de Dominio de SaaS Billing \& Subscriptions} \label{tbl:billing-repository-adapters} \\
\hline
\thfirst{Aspecto de Adaptador} & \thcell{Especificación Técnica y Persistencia} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Adaptador} & \thcell{Especificación Técnica y Persistencia} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} SubscriptionPlanRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{SubscriptionPlanRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{SubscriptionPlanPersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & Transforma agregados SubscriptionPlan hacia SubscriptionPlanPersistenceEntity mediante SubscriptionPlanPersistenceAssembler. Coordina la persistencia relacional en la tabla plans sincronizando en cascada sus características en plan\_features. Provee métodos *save()* bajo transacción de escritura, *findById()* para hidratación de cuotas comerciales, *findByStripePriceId()* para mapear identificadores de precio en Stripe y *findAllActive()* optimizado para la exposición del catálogo comercial. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} TenantSubscriptionRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{TenantSubscriptionRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{TenantSubscriptionPersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & Administra la persistencia del ciclo de vida de membresías de talleres en la tabla subscriptions. Reconstituye agregados puros TenantSubscription vinculando sus estados de vigencia mediante TenantSubscriptionPersistenceAssembler. Provee *save()* con bloqueo a nivel de fila para cambios de estado, *findByTenantId()* para consulta de suscripción activa de taller, *findByStripeSubscriptionId()* para sincronización reactiva desde webhooks y *existsActiveByTenantId()* para validaciones rápidas de membresía. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} SaasInvoiceRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{SaasInvoiceRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{SaasInvoicePersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & Persiste el historial de comprobantes de cobro y recibos contables emitidos por la plataforma en la tabla saas\_invoices mediante SaasInvoicePersistenceAssembler. Provee *save()* para registrar facturas generadas tras pagos exitosos, *findById()* para auditoría individual, *findByStripeInvoiceId()* para conciliación bancaria y *findAllByTenantId()* con soporte nativo de paginación para alimentar la vista histórica del panel del taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} StripeWebhookEventRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{StripeWebhookEventRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{StripeWebhookEventPersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & Implementa el cerrojo de persistencia para el procesamiento seguro de webhooks asíncronos en la tabla stripe\_webhook\_events mediante StripeWebhookEventPersistenceAssembler. Provee *existsByStripeEventId()* para descartar en tiempo constante notificaciones duplicadas emitidas por Stripe ante demoras de confirmación, *save()* para persistir la traza de auditoría con la carga JSON íntegra y *markAsFailed()* para documentar el motivo de excepción en caso de errores en consumidores. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Adaptadores de repositorio de persistencia ubicados bajo el subpaquete canónico persistence.jpa.adapters.

**Ensambladores de Persistencia y Convertidores de Atributos JPA**

El desacoplamiento estricto entre el esquema físico relacional y los tipos puros del dominio se materializa mediante ensambladores de persistencia y convertidores de atributos JPA. El ensamblador **SubscriptionPlanPersistenceAssembler** traduce bidireccionalmente planes comerciales, proyectando las cuotas operativas de sucursales y mecánicos hacia columnas escalares y reconstruyendo el agregado puro mediante su método estático de fábrica sin disparar eventos de dominio espurios durante consultas. De modo semejante, los ensambladores **TenantSubscriptionPersistenceAssembler**, **SaasInvoicePersistenceAssembler** y **StripeWebhookEventPersistenceAssembler** restauran el estado interno de membresías, recibos y trazas de auditoría preservando la inmutabilidad de sus identificadores y marcas temporales en UTC.

Este esquema de transformación se complementa con seis convertidores de atributos JPA que serializan enumeraciones de dominio y estructuras de cuotas hacia tipos columnares estándar de SQL. En particular, **PlanTierConverter** serializa los niveles de suscripción, **SubscriptionStatusConverter** sincroniza los estados de vigencia con la terminología de Stripe, **InvoiceStatusConverter** asegura la validez de los recibos de cobro, **BillingCycleConverter** estandariza la periodicidad mensual y anual, **WebhookProcessingStatusConverter** tipifica las fases de consumo de eventos asíncronos y **TenantQuotaLimitsConverter** serializa las cuotas operativas consolidadas. En la @tbl:billing-persistence-assemblers se describen las transformaciones y mapeos de tipos implementados por estos componentes.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Ensambladores de Persistencia y Convertidores JPA de SaaS Billing \& Subscriptions} \label{tbl:billing-persistence-assemblers} \\
\hline
\thfirst{Aspecto de Mapeo} & \thcell{Tipos Relacionados y Transformación} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Mapeo} & \thcell{Tipos Relacionados y Transformación} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} SubscriptionPlanPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{SubscriptionPlan} $\longleftrightarrow$ \texttt{SubscriptionPlanPersistenceEntity} \\*
\hline
\textbf{Transformación} & Mapea identificadores PlanId y campos comerciales name, price y currency. Descompone el objeto de valor TenantQuotaLimits en columnas escalares max\_branches, max\_active\_staff, max\_monthly\_work\_orders, iot\_telemetry\_enabled y ai\_diagnostics\_enabled. Transforma la colección de entidades hijas PlanFeature hacia PlanFeaturePersistenceEntity. Reconstituye el agregado puro mediante método estático *reconstitute()* sin disparar eventos de dominio espurios durante consultas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} TenantSubscriptionPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{TenantSubscription} $\longleftrightarrow$ \texttt{TenantSubscriptionPersistenceEntity} \\*
\hline
\textbf{Transformación} & Mapea SubscriptionId, TenantId y PlanId a identificadores UUID planos. Vincula los identificadores de cliente y suscripción en Stripe. Convierte marcas temporales de inicio y término de ciclo a marcas Instant en UTC. Reconstituye el agregado puro restaurando su estado de vigencia mediante *reconstitute()* para asegurar invariantes de ciclo de vida sin generar eventos duplicados en base de datos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} SaasInvoicePersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{SaasInvoice} $\longleftrightarrow$ \texttt{SaasInvoicePersistenceEntity} \\*
\hline
\textbf{Transformación} & Mapea SaasInvoiceId, SubscriptionId y TenantId a claves UUID relacionales. Traduce el monto monetario a escala BigDecimal en dos decimales con redondeo contable. Asocia las URLs seguras de descarga de PDF y vista web hospedada de Stripe. Invoca *reconstitute()* restaurando el estado inmutable del recibo de suscripción. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} StripeWebhookEventPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{StripeWebhookEvent} $\longleftrightarrow$ \texttt{StripeWebhookEventPersistenceEntity} \\*
\hline
\textbf{Transformación} & Transforma el identificador de evento nativo de Stripe, el tipo de notificación estructurado y la carga útil en formato JSON crudo hacia columnas de texto plano. Reconstituye la entidad de auditoría con su fecha de recepción y resultado de procesamiento mediante *reconstitute()*. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} PlanTierConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{PlanTier} $\longleftrightarrow$ \texttt{VARCHAR(20)} \\*
\hline
\textbf{Transformación} & Implementa AttributeConverter mapeando los valores enumerados GO, PRO, MAX y ENTERPRISE a cadenas alfanuméricas estándar en PostgreSQL. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} SubscriptionStatusConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{SubscriptionStatus} $\longleftrightarrow$ \texttt{VARCHAR(20)} \\*
\hline
\textbf{Transformación} & Serializa y deserializa los estados de suscripción INCOMPLETE, TRIALING, ACTIVE, PAST\_DUE, CANCELED y UNPAID asegurando coherencia semántica con el ciclo de vida de cobros de Stripe. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} InvoiceStatusConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{InvoiceStatus} $\longleftrightarrow$ \texttt{VARCHAR(20)} \\*
\hline
\textbf{Transformación} & Mapea el estado de recibos DRAFT, OPEN, PAID, VOID y UNCOLLECTIBLE hacia columnas relacionales de texto garantizando la consistencia financiera de los comprobantes. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} BillingCycleConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{BillingCycle} $\longleftrightarrow$ \texttt{VARCHAR(20)} \\*
\hline
\textbf{Transformación} & Mapea la periodicidad comercial de facturación MONTHLY y ANNUAL hacia la base de datos permitiendo configuraciones tarifarias flexibles para talleres automotrices. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} WebhookProcessingStatusConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{WebhookProcessingStatus} $\longleftrightarrow$ \texttt{VARCHAR(20)} \\*
\hline
\textbf{Transformación} & Implementa AttributeConverter mapeando los estados operativos PENDING, PROCESSED, FAILED e IGNORED hacia columnas relacionales de texto para el control de idempotencia y auditoría de eventos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} TenantQuotaLimitsConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{TenantQuotaLimits} $\longleftrightarrow$ \texttt{VARCHAR(255)} \\*
\hline
\textbf{Transformación} & Implementa AttributeConverter serializando la estructura de límites de sucursales, colaboradores y módulos tecnológicos hacia representación estructurada para almacenamiento consistente y comprobación de cuotas. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Ensambladores y conversores ubicados bajo los subpaquetes canónicos persistence.jpa.assemblers y persistence.jpa.converters.

**Pasarelas Externas de Pago, Notificaciones y Caché en Memoria**

La interacción con los servicios perimetrales de nube y las dependencias intermodulares se articula mediante adaptadores especializados organizados en subpaquetes modulares según el proveedor o tecnología externa. El adaptador **StripeGatewayAdapter** encapsula las llamadas remotas hacia la API de Stripe mediante el cliente oficial, gestionando la generación de clientes, sesiones de cobro hospedadas y enlaces al portal de autoservicio con credenciales aisladas del código fuente. De forma complementaria, **StripeWebhookSignatureVerifierAdapter** valida la autenticidad criptográfica de los eventos asíncronos mediante el cálculo de firmas HMAC-SHA256. Por su parte, el adaptador **ResendBillingNotificationAdapter** conecta con la infraestructura de mensajería RESTful de Resend para emitir confirmaciones de pago, recibos contables y alertas preventivas de regularización financiera.

Asimismo, el adaptador **IamTenantValidationAdapter** resuelve los datos de razón social, documento de identidad fiscal y correo electrónico del titular del taller consumiendo la fachada en memoria del contexto IAM & Tenancy bajo el patrón Open Host Service, eliminando dependencias de red o acoplamientos relacionales entre esquemas de base de datos. Para garantizar la verificación inmediata de cuotas operativas en las estaciones de trabajo de taller y en terminales móviles, el adaptador **CaffeineBillingCacheAdapter** y la clase de configuración **CaffeineCacheConfiguration** definen políticas de retención temporal en memoria RAM con latencia de resolución sub-milisegundo. Finalmente, el adaptador **BillingOutboxMessageRelayAdapter** orquesta el relevo transaccional asíncrono de eventos de integración hacia el bus de la plataforma con garantía de entrega At-Least-Once. En la @tbl:billing-external-infrastructure se resumen los puertos implementados, componentes tecnológicos y mecanismos de resiliencia adoptados por estas pasarelas.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Pasarelas Externas de Pago, Notificaciones y Caché de SaaS Billing \& Subscriptions} \label{tbl:billing-external-infrastructure} \\
\hline
\thfirst{Componente de Integración} & \thcell{Especificación Técnica y Resiliencia} \\
\hline
\endfirsthead
\hline
\thfirst{Componente de Integración} & \thcell{Especificación Técnica y Resiliencia} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} StripeGatewayAdapter} \\*
\hline
\textbf{Puerto Implementado} & \texttt{StripeGatewayPort} \\*
\hline
\textbf{Tecnología y Cliente} & SDK oficial stripe-java mediante instancia inyectada com.stripe.StripeClient. \\*
\hline
\textbf{Operaciones y Resiliencia} & Gestiona la creación de clientes en Stripe mediante *createCustomer()*, sesiones seguras Stripe Checkout mediante *createCheckoutSession()*, redirección hacia Stripe Customer Portal mediante *createCustomerPortalSession()*, cancelación de membresías con *cancelSubscription()* y consulta de comprobantes con *retrieveInvoice()*. Encapsula credenciales secretas mediante inyección externa de propiedades. Traduce excepciones nativas de pasarela CardException, RateLimitException e InvalidRequestException en excepciones semánticas de dominio BillingDomainException para proteger las capas internas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} StripeWebhookSignatureVerifierAdapter} \\*
\hline
\textbf{Puerto Implementado} & \texttt{StripeWebhookSignatureVerificationService} \\*
\hline
\textbf{Tecnología y Cliente} & SDK oficial stripe-java mediante com.stripe.net.Webhook.Signature. \\*
\hline
\textbf{Operaciones y Resiliencia} & Valida la autenticidad criptográfica y frescura de la cabecera Stripe-Signature calculando y comparando el hash HMAC-SHA256 con tolerancia estricta de tiempo de 300 segundos, neutralizando ataques de repetición o transmisiones apócrifas antes de que alcancen el modelo de dominio. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} ResendBillingNotificationAdapter} \\*
\hline
\textbf{Puerto Implementado} & \texttt{TenantBillingNotificationGatewayPort} \\*
\hline
\textbf{Tecnología y Cliente} & Cliente HTTP RESTful de Resend con plantillas responsivas HTML5 parametrizadas. \\*
\hline
\textbf{Operaciones y Resiliencia} & Despacha notificaciones transaccionales para bienvenida de suscripciones activadas mediante *sendSubscriptionActivatedEmail()*, confirmación de abono periódico con recibo descargable mediante *sendInvoiceReceiptEmail()*, avisos de cancelación mediante *sendSubscriptionCanceledEmail()* y alertas preventivas de regularización bancaria ante cobros rechazados mediante *sendPaymentFailedAlertEmail()*. Implementa reintentos exponenciales automáticos y tolerancia a fallos transitorios de red para asegurar entrega de avisos críticos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} IamTenantValidationAdapter} \\*
\hline
\textbf{Puerto Implementado} & \texttt{IamTenantValidationAclPort} \\*
\hline
\textbf{Tecnología y Cliente} & Fachada pública de contexto TenancyContextFacade consumida en memoria bajo patrón Open Host Service. \\*
\hline
\textbf{Operaciones y Resiliencia} & Resuelve la razón social del taller, documento tributario de identidad, correo del propietario y sucursales activas invocando métodos de la fachada en memoria. Garantiza desacoplamiento físico entre esquemas de base de datos y provee validaciones atómicas de existencia de taller previas a la creación de sesiones de cobro. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} CaffeineBillingCacheAdapter} \\*
\hline
\textbf{Puerto Implementado} & \texttt{BillingCachePort} \\*
\hline
\textbf{Tecnología y Cliente} & Biblioteca Caffeine Cache integrada mediante Spring CacheManager. \\*
\hline
\textbf{Operaciones y Resiliencia} & Provee almacenamiento y recuperación ultra veloz de estados de suscripción mediante *getSubscriptionStatus()*, *putSubscriptionStatus()*, *evictSubscriptionStatus()* y cuotas vigentes mediante *getQuotaLimits()*, *putQuotaLimits()*, resolviendo comprobaciones de autorización en submilisegundos (< 0.05 ms) para interacciones concurrentes desde estaciones web y talleres móviles. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Configuración:} CaffeineCacheConfiguration} \\*
\hline
\textbf{Propósito en Infraestructura} & \texttt{Configuración de Infraestructura de Caché} \\*
\hline
\textbf{Tecnología y Cliente} & Anotaciones @Configuration y @Bean de Spring Framework con CaffeineCacheManager. \\*
\hline
\textbf{Operaciones y Resiliencia} & Configura BillingCacheManager gestionando cachés dedicados tenantSubscriptionStatus y activePlans con directiva de expiración *expireAfterWrite* de 5 minutos y capacidad máxima de 10,000 entradas para optimizar el uso de memoria RAM y evitar saturación por consumo de recursos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} BillingOutboxMessageRelayAdapter} \\*
\hline
\textbf{Propósito en Infraestructura} & \texttt{Adaptador de Relé Transaccional Outbox} \\*
\hline
\textbf{Tecnología y Cliente} & Programador asíncrono Spring Task Scheduler (@Scheduled) y Spring Data JPA sobre tabla outbox\_messages. \\*
\hline
\textbf{Operaciones y Resiliencia} & Consulta periódicamente mensajes pendientes de integración en la tabla outbox\_messages con semántica de entrega At-Least-Once, transmitiendo eventos de suscripción y facturación hacia el bus de eventos de la plataforma con políticas de reintentos exponenciales y marcado de estado PROCESSED o FAILED tras confirmación de despacho. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Pasarelas y adaptadores externos ubicados bajo los subpaquetes modulares de external.

El diseño de la Capa de Infraestructura de SaaS Billing & Subscriptions garantiza el aislamiento físico y lógico entre los datos de facturación de la plataforma y los esquemas operativos de los talleres automotrices abonados. Al centralizar la persistencia relacional en tablas normalizadas con claves foráneas e índices B-Tree optimizados en PostgreSQL 16, el sistema asegura tiempos de consulta deterministas y previene degradaciones de rendimiento durante picos de recaudación mensual o auditorías impositivas.

Asimismo, la delegación completa de la captura de instrumentos financieros hacia las interfaces certificadas de Stripe Checkout y Customer Portal reduce al mínimo absoluto el perímetro de cumplimiento normativo PCI-DSS Nivel 1. La plataforma Atelier nunca almacena, procesa ni transmite números de tarjetas de crédito o credenciales bancarias sensibles, reteniendo únicamente identificadores opacos de cliente y suscripción que vinculan las cuentas de taller con el registro contable en la nube.

Finalmente, el mecanismo de persistencia atómica de webhooks y el registro previo en la tabla de auditoría confieren una tolerancia absoluta a fallas transitorias de red y reintentos repetidos por parte de la pasarela de pagos. Cada evento recibido es evaluado contra restricciones únicas de clave antes de disparar cualquier transición de estado en las suscripciones, asegurando que los talleres gocen de continuidad operativa ininterrumpida y que los pagos queden asentados con exactitud contable e inmutabilidad legal.

#### 2.6.8.5. Bounded Context Software Architecture Component Level Diagrams

En esta sección se presenta la descomposición arquitectónica interna del contenedor central **API Application** en relación con el Bounded Context **SaaS Billing & Subscriptions** (paquete canónico com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak billing), dando estricto cumplimiento al Nivel 3 del Modelo C4.

Dentro de la arquitectura de monolito modular de Atelier Platform, el Bounded Context SaaS Billing & Subscriptions opera como el núcleo de soberanía financiera, monetización periódica, gobierno estricto de cuotas operativas y licenciamiento multi-inquilino. Su diseño táctico garantiza transacciones atómicas para el ciclo de suscripciones, previene fallos transaccionales y cobros redundantes mediante el procesamiento idempotente de notificaciones asíncronas, y aísla la lógica de negocio interna del perímetro normativo de tarjetas de crédito mediante la delegación hacia pasarelas certificadas bajo el estándar PCI-DSS Nivel 1.

Todos los controladores perimetrales, servicios de aplicación de comando y consulta, motores criptográficos de verificación de firmas, repositorios relacionales y fachadas en memoria se articulan armónicamente para asegurar una experiencia transaccional fluida y predecible tanto para los propietarios de talleres automotrices como para las estaciones de trabajo de taller y unidades mecánicas móviles en campo.

En la @tbl:billing-c4-components se presenta el catálogo estructurado de los siete componentes de software constitutivos del Bounded Context SaaS Billing & Subscriptions dentro del contenedor central de la aplicación.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.5cm} | >{\raggedright\arraybackslash}p{10.9cm} |}
\caption{Catálogo de Componentes de Arquitectura de Software del Bounded Context SaaS Billing \& Subscriptions} \label{tbl:billing-c4-components} \\
\hline
\thfirst{Aspecto Técnico} & \thcell{Especificación de Arquitectura} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto Técnico} & \thcell{Especificación de Arquitectura} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Billing REST Controllers \& Resource Assemblers} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring MVC, SpringDoc OpenAPI, Jakarta Validation, Spring HATEOAS \\*
\hline
\textbf{Responsabilidad} & Expone endpoints REST perimetrales para el catálogo comercial de planes, inicialización de sesiones de pago Stripe Checkout, redirección hacia Stripe Customer Portal, consulta histórica de recibos contables y recepción de webhooks asíncronos mediante SubscriptionPlansController, TenantSubscriptionsController, SaasInvoicesController y StripeWebhooksController. Valida contratos DTO, gestiona excepciones con RFC 7807 y proyecta representaciones hipermedia estructuradas mediante ensambladores de recursos REST. \\*
\hline
\textbf{Relaciones} & Invocado por WebApp y Mobile Workshop mediante peticiones HTTPS seguras. Recibe webhooks desde Stripe Platform. Despacha comandos transaccionales y consultas hacia los servicios de aplicación CQRS. Emplea ensambladores dedicados (SubscriptionPlanResourceAssembler, TenantSubscriptionResourceAssembler, SaasInvoiceResourceAssembler) para transformar modelos de dominio en recursos DTO. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Billing CQRS Application Services} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring Service, Transactional, CQRS, Interfaces Funcionales \\*
\hline
\textbf{Responsabilidad} & Orquesta los casos de uso transaccionales de planes comerciales, contratación de membresías, transiciones de estado operativo, cancelaciones inmediatas o a término de ciclo y archivo contable de comprobantes de cobro bajo transacciones ACID mediante SubscriptionPlanCommandService, TenantSubscriptionCommandService, StripeWebhookCommandService, SaasInvoiceCommandService y TenantSubscriptionQueryService, canalizando resultados mediante tipos Result. \\*
\hline
\textbf{Relaciones} & Implementa contratos de casos de uso de comando y consulta. Invoca reglas de gobernanza y validación de cuotas en el modelo de dominio. Delega la persistencia relacional en repositorios JPA. Coordina con pasarelas externas para sesiones de pago en Stripe y despacho de recibos por correo vía Resend. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Billing Event Handlers \& Outbox Publisher} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring Events, TransactionalEventListener, Webhook Processor, Outbox Pattern \\*
\hline
\textbf{Responsabilidad} & Procesa notificaciones asíncronas de eventos emitidos por Stripe garantizando estricta idempotencia transaccional mediante verificación previa en la tabla stripe\_webhook\_events. Despacha eventos de dominio internos de activación y morosidad de suscripciones mediante SubscriptionDomainEventHandler, e inserta registros de integración en el Outbox transaccional mediante BillingTransactionalOutboxPublisher. \\*
\hline
\textbf{Relaciones} & Recibe cargas de eventos de Stripe desde los controladores perimetrales. Verifica y registra identificadores únicos en stripe\_webhook\_events mediante adaptadores de persistencia. Notifica a la fachada Open Host Service para invalidar la memoria en caché y publica eventos hacia contextos hermanos mediante el relé Outbox. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Billing Domain Model \& Quota Governance Engines} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Java 24 puro, Domain Model, Records, Inmutabilidad, Criptografía HMAC-SHA256 \\*
\hline
\textbf{Responsabilidad} & Encapsula las invariantes de negocio de licenciamiento SaaS, las raíces de agregado SubscriptionPlan, TenantSubscription, SaasInvoice y StripeWebhookEvent, la entidad dependiente PlanFeature, el motor de gobernanza de cuotas operativas SubscriptionQuotaEnforcementService, el servicio criptográfico de verificación de firmas HMAC-SHA256 StripeWebhookSignatureVerificationService y las políticas contractuales en SubscriptionLifecycleDomainService. \\*
\hline
\textbf{Relaciones} & Contiene las entidades maestras y dependientes PlanFeature. Evalúa invariantes de cuota para creación de sucursales, vinculación de mecánicos y acceso a telemetría IoT. Provee contratos criptográficos consumidos por el procesador de webhooks y emite eventos de dominio inmutables. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Billing Persistence Repositories \& JPA Adapters} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Jakarta Persistence 3.1, Spring Data JPA, Hibernate ORM, PostgreSQL 16 \\*
\hline
\textbf{Responsabilidad} & Materializa los puertos de repositorio del dominio mediante adaptadores secundarios JPA (SubscriptionPlanRepositoryImpl, TenantSubscriptionRepositoryImpl, SaasInvoiceRepositoryImpl, StripeWebhookEventRepositoryImpl) respaldados por repositorios Spring Data JPA, administrando la persistencia relacional normalizada, restricciones de unicidad de suscripción por taller, índices B-Tree de alto rendimiento y cerrojo de auditoría contra eventos duplicados de Stripe. \\*
\hline
\textbf{Relaciones} & Realiza los contratos SubscriptionPlanRepository, TenantSubscriptionRepository, SaasInvoiceRepository y StripeWebhookEventRepository. Lee y escribe en las tablas plans, plan\_features, subscriptions, saas\_invoices y stripe\_webhook\_events en PostgreSQL 16. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Billing Open Host Facade \& Quota Evaluation ACL} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring Service, Open Host Service, In-Memory ACL, Caffeine Cache \\*
\hline
\textbf{Responsabilidad} & Publica una fachada Open Host Service en memoria mediante SubscriptionContextFacadeImpl que permite a los Bounded Contexts IAM \& Tenancy y Workshop Operations verificar la vigencia de membresía, cuotas de sucursales, personal activo y permisos de telemetría IoT con latencia sub-milisegundo (< 0.05 ms) respaldada en memoria RAM. \\*
\hline
\textbf{Relaciones} & Invocado en memoria por IAM \& Tenancy y Workshop Operations. Consulta la vigencia de suscripciones y límites en repositorios JPA o en memoria en caché mediante Caffeine Cache. Invalida entradas de caché ante eventos de actualización emitidos por el procesador de webhooks. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Billing External Gateways \& Cloud Integration} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Stripe Java SDK v24+, Spring WebClient, Resend Cloud API, Caffeine Cache Manager \\*
\hline
\textbf{Responsabilidad} & Encapsula la comunicación perimetral con la API de Stripe mediante StripeGatewayAdapter para crear sesiones de pago hospedadas y enlaces al portal de autoservicio de clientes. Despacha confirmaciones y recibos contables por correo vía ResendBillingNotificationAdapter, consulta datos corporativos en IAM mediante IamTenantValidationAdapter, acelera lecturas con CaffeineBillingCacheAdapter y despacha eventos asíncronos con BillingOutboxMessageRelayAdapter. \\*
\hline
\textbf{Relaciones} & Invocado por los servicios de aplicación CQRS. Conecta vía HTTPS REST con la plataforma Stripe y con la API de Resend. Consume en memoria la fachada de IAM \& Tenancy para validar la existencia del taller sin acoplamientos relacionales. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al contenedor API Application en com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak billing.

En la @fig:c4-component-billing se ilustra el diagrama C4 de componentes para el Bounded Context SaaS Billing & Subscriptions, detallando las interacciones entre los componentes internos del módulo, los clientes perimetrales, los bounded contexts adyacentes de la plataforma y los servicios de infraestructura externa de pasarela de pagos y mensajería transaccional.

![Diagrama de Componentes C4 (Nivel 3) para el Bounded Context SaaS Billing & Subscriptions en API Application](report/assets/c4-diagrams/component-level-diagram-billing.png){#fig:c4-component-billing}

*Nota.* Elaboración propia en base a la arquitectura táctica del backend y el estándar C4 Model.

**Dinámica de Interacción y Flujos Operativos del Bounded Context SaaS Billing & Subscriptions**

Para formalizar la colaboración sincronizada entre los componentes internos del módulo de suscripciones y los sistemas externos durante el ciclo de vida comercial del taller mecánico, se analizan a continuación los tres ciclos operacionales más representativos de la solución:

- **Ciclo de Inicialización de Checkout y Activación de Suscripción con Pasarela Externa (Stripe):**
  El proceso se desencadena cuando el administrador de un taller mecánico decide contratar un nuevo plan tarifario o actualizar su nivel de suscripción desde el portal web. La solicitud es recibida por el componente **Billing REST Controllers & Resource Assemblers**, el cual valida las restricciones de entrada y delega la ejecución en **Billing CQRS Application Services** mediante el comando **CreateCheckoutSessionCommand**.

  El servicio de aplicación coordina la consulta de datos del taller invocando a **Billing External Gateways & Cloud Integration**, la cual interactúa en memoria con la fachada de **IAM & Tenancy Context** para verificar la razón social y el correo electrónico del titular. A continuación, la pasarela solicita a la API de Stripe la apertura de una sesión de pago hospedada utilizando el cliente oficial stripe-java, configurando las direcciones seguras de redirección ante éxito o cancelación. El controlador retorna la URL generada a la aplicación web para redirigir al usuario hacia la pasarela protegida de Stripe, garantizando que los datos confidenciales de tarjetas de crédito nunca toquen la infraestructura de Atelier.

  Una vez completado el pago de manera exitosa en Stripe, su infraestructura emite el webhook asíncrono checkout.session.completed hacia el endpoint perimetral de Atelier. El componente **Billing Event Handlers & Outbox Publisher** verifica la firma digital HMAC-SHA256 en **Billing Domain Model & Quota Governance Engines**, comprueba la no duplicidad del evento contra la tabla **stripe_webhook_events** en **Billing Persistence Repositories & JPA Adapters**, activa formalmente la entidad **TenantSubscription**, asienta el comprobante inicial en **saas_invoices**, notifica la confirmación de alta por correo mediante Resend e invalida de forma reactiva la memoria en caché en **Billing Open Host Facade & Quota Evaluation ACL**.

- **Ciclo de Notificación Asíncrona, Conciliación de Pagos e Idempotencia vía Webhooks:**
  Este flujo gobierna la consistencia financiera del sistema frente a cobros recurrentes periódicos mensuales o anuales ejecutados de manera desatendida por Stripe. Al cumplirse el ciclo de facturación, la pasarela intenta efectuar el cobro automático sobre la tarjeta registrada del taller, generando eventos asíncronos invoice.payment_succeeded o invoice.payment_failed que se envían hacia el endpoint perimetral de webhooks de Stripe.

  El componente **Billing REST Controllers & Resource Assemblers** intercepta la petición HTTP y traslada la carga útil y la cabecera Stripe-Signature hacia **Billing CQRS Application Services**. El servicio de aplicación delega la autenticación criptográfica en **Billing Domain Model & Quota Governance Engines**, donde **StripeWebhookSignatureVerificationService** computa la firma HMAC-SHA256 empleando la clave secreta institucional para rechazar intentos maliciosos de falsificación o repetición.

  Seguidamente, el componente **Billing Event Handlers & Outbox Publisher** comprueba la existencia previa del identificador en **Billing Persistence Repositories & JPA Adapters**. Si el evento ya fue procesado con anterioridad, se descarta inmediatamente retornando un código de confirmación para neutralizar reintentos repetidos de red. Si es inédito, se registra en la tabla **stripe_webhook_events**, se actualiza el estado de la membresía del taller a vigencia plena o mora controlada, se almacena el recibo con enlaces de auditoría en la tabla **saas_invoices**, se emite el evento de dominio correspondiente y se purga reactivamente la entrada de membresía en la memoria en caché.

- **Ciclo de Verificación y Aplicación de Cuotas Operativas con Memoria en Caché (Caffeine):**
  Para garantizar la integridad operativa de la plataforma sin introducir latencias perjudiciales en los flujos diarios de trabajo, este ciclo se ejecuta de manera continua cada vez que un taller intenta registrar una nueva sede, afiliar personal técnico o aperturar órdenes de trabajo. El módulo solicitante de **IAM & Tenancy** o **Workshop Operations** invoca en memoria los métodos de consulta expuestos por **Billing Open Host Facade & Quota Evaluation ACL**.

  El componente de fachada evalúa en primer término el estado de suscripción y límites de cuota almacenados en la memoria RAM mediante **Caffeine Cache Manager**. Si la entrada se encuentra vigente en caché, la validación se resuelve de inmediato con una latencia sub-milisegundo (< 0.05 ms), permitiendo que las estaciones de trabajo fijas y terminales móviles en campo operen con total fluidez.

  En situaciones de fallo de caché, la fachada recupera la suscripción activa del taller y su agregado **SubscriptionPlan** desde **Billing Persistence Repositories & JPA Adapters**, delegando en **Billing Domain Model & Quota Governance Engines** la evaluación del límite contratado de sucursales o personal frente al consumo acumulado. Si la capacidad ha alcanzado su techo máximo, el motor de cuotas emite la excepción semántica de negocio **QuotaExceededException**, impidiendo la creación del recurso y orientando al usuario hacia el módulo de mejora de plan. El resultado válido se almacena en la memoria en caché con directiva de expiración de cinco minutos tras escritura.

En primer término, la estricta segregación de responsabilidades y la delegación de captura de instrumentos financieros hacia Stripe Checkout y Customer Portal reducen de forma determinante el perímetro de cumplimiento normativo PCI-DSS Nivel 1. Al no almacenar, procesar ni transmitir números de tarjeta de crédito en los servidores de Atelier, el sistema elimina riesgos de filtración de información bancaria sensible, conservando únicamente tokens opacos de cliente y suscripción vinculados a los registros corporativos en PostgreSQL 16.

En segundo término, la implementación del cerrojo de persistencia para eventos asíncronos en el componente de procesamiento de webhooks confiere una tolerancia absoluta a fallas de red y reintentos repetidos por parte de la pasarela de pagos. La restricción de unicidad sobre la tabla **stripe_webhook_events** garantiza que cada abono periódico o transición de estado se asiente una única vez con exactitud contable, erradicando duplicidades de cobro o inconsistencias en los recibos emitidos ante eventuales intermitencias en la infraestructura de nube.

Por último, la articulación de la fachada Open Host Service respaldada en almacenamiento en caché con Caffeine Cache resuelve eficazmente la concurrencia masiva de consultas de licenciamiento. Al absorber las verificaciones intensivas de cuota y vigencia en memoria local con tiempos de respuesta sub-milisegundo, el sistema descarga de trabajo al motor de base de datos relacional y garantiza que tanto las terminales administrativas de mostrador como los asesores en bahía y mecánicos en auxilio vial dispongan de autorización inmediata para el desempeño de sus labores automotrices.

#### 2.6.8.6. Bounded Context Software Architecture Code Level Diagrams

En esta sección se desarrolla la especificación técnica de menor nivel de abstracción para la arquitectura de software del Bounded Context SaaS Billing & Subscriptions, trasladando las fronteras conceptuales y las responsabilidades tácticas hacia contratos estáticos de código ejecutable. Mediante esta formalización, se asegura que las reglas comerciales de licenciamiento recurrente, los controles de consumo multi-inquilino y las garantías de seguridad financiera se materialicen con estricta seguridad de tipos y determinismo computacional.

Esta perspectiva de diseño abarca dos representaciones arquitectónicas complementarias: el Diagrama de Clases de la Capa de Dominio, que modela en memoria las raíces de agregado, entidades subordinadas, objetos de valor inmutables, motores algorítmicos de gobernanza de cuotas y puertos de persistencia, y el Diagrama de Base de Datos, que formaliza el esquema físico relacional en PostgreSQL 16 con restricciones de unicidad, índices de alta velocidad y aislamiento multi-inquilino.

##### 2.6.8.6.1. *Bounded Context Domain Layer Class Diagrams*

El modelado estático de la Capa de Dominio del Bounded Context SaaS Billing & Subscriptions establece las estructuras operativas que gobiernan el catálogo comercial de planes, el ciclo de vida contractual de las membresías de los talleres mecánicos y la conciliación asíncrona de recaudaciones. Su diseño táctico prioriza la pureza algorítmica sin dependencias de frameworks tecnológicos, erradica la obsesión por tipos primitivos mediante identificadores fuertemente tipados y garantiza la mitigación integral de riesgos normativos bancarios bajo el estándar PCI-DSS Nivel 1.

En la @fig:class-diagram-billing se expone el Diagrama de Clases UML detallado para la Capa de Dominio de SaaS Billing & Subscriptions, diseñado conforme a la notación formal UML y compilado mediante la herramienta PlantUML bajo el enfoque de Diagram-as-Code.

![Diagrama de Clases UML de la Capa de Dominio para el Bounded Context SaaS Billing & Subscriptions](report/assets/class-diagrams/class-diagram-billing.png){#fig:class-diagram-billing}

*Nota.* Elaboración propia en base al diseño táctico de dominio y el estándar UML en PlantUML.

La organización interna del modelo estático se estructura en nueve paquetes canónicos cohesivos que encapsulan las responsabilidades del dominio de monetización y licenciamiento:

- **Raíces de Agregado (billing.domain.model.aggregates):** Gobierna las 4 entidades maestras que delimitan las fronteras de consistencia transaccional y extienden de AbstractDomainAggregateRoot: SubscriptionPlan para la soberanía del catálogo de tarifas y cuotas, TenantSubscription para el ciclo de vida contractual y periodos de vigencia del taller mecánico, SaasInvoice para el registro contable inmutable de recaudación, y StripeWebhookEvent para la deduplicación telemática estricta e idempotencia.
- **Entidades Dependientes (billing.domain.model.entities):** Modela la entidad subordinada PlanFeature (identificada unívocamente mediante PlanFeatureId id), la cual encapsula la especificación modular de capacidades avanzadas habilitadas por plan comercial, tales como telemetría vehicular OBD-II continua o algoritmos predictivos con inteligencia artificial.
- **Identificadores Fuertemente Tipados (billing.domain.model.ids):** Implementa el contrato canónico TypedId mediante 5 registros inmutables libres de tipos primitivos: PlanId, SubscriptionId, SaasInvoiceId, StripeEventId y PlanFeatureId, asociando además la identidad transversal de organización TenantId proveniente del Shared Kernel.
- **Objetos de Valor Inmutables (billing.domain.model.valueobjects):** Encapsula 7 estructuras inmutables con validación de invariantes de negocio: PlanPricing para asociar cuantías de dinero con la frecuencia de cobro, StripeCustomerId, StripeSubscriptionId, StripePriceId y StripeInvoiceId para validar identificadores oficiales de pasarela con prefijos reglamentarios, SubscriptionPeriod para delimitar la ventana cronológica de vigencia pagada, y TenantQuotaLimits para cuantificar los techos autorizados de sedes físicas, mecánicos y órdenes de trabajo mensuales, enlazando tipos universales Money y Currency.
- **Enumeraciones de Dominio (billing.domain.model.enums):** Normaliza el vocabulario operativo y comercial mediante 5 tipos enumerados inmutables: PlanTier (niveles Go, Pro, Max, Enterprise), BillingCycle (periodicidades mensual y anual), SubscriptionStatus (estados Trialing, Active, Past Due, Canceled, Unpaid, Incomplete), InvoiceStatus (liquidaciones Paid, Open, Void, Uncollectible) y WebhookProcessingStatus (estados Pending, Processed, Failed, Ignored).
- **Servicios de Dominio Puros (billing.domain.services):** Provee 3 motores algorítmicos sin acoplamiento a infraestructura tecnológica: SubscriptionQuotaEnforcementService para la comprobación determinista de techos de consumo frente a los recursos acumulados del taller, StripeWebhookSignatureVerificationService para la autenticación criptográfica de firmas HMAC-SHA256 con tolerancia temporal, y SubscriptionLifecycleDomainService para la gobernanza de políticas de gracia, reactivaciones y rescisión contractual.
- **Puertos de Repositorio de Dominio (billing.domain.repositories):** Define los 4 contratos abstractos de almacenamiento y consulta desacoplados de motores relacionales: SubscriptionPlanRepository, TenantSubscriptionRepository, SaasInvoiceRepository y StripeWebhookEventRepository.
- **Eventos de Dominio (billing.domain.model.events):** Formaliza las mutaciones de estado transaccionales mediante 9 eventos inmutables para el Transactional Outbox: SubscriptionPlanCreatedEvent, TenantSubscriptionActivatedEvent, TenantSubscriptionRenewedEvent, TenantSubscriptionPastDueEvent, TenantSubscriptionCanceledEvent, TenantPlanChangedEvent, SaasInvoicePaidEvent, SaasInvoicePaymentFailedEvent y StripeWebhookProcessedEvent.
- **Jerarquía de Excepciones Semánticas (billing.domain.exceptions):** Estructura 11 excepciones de dominio no comprobadas derivadas de DomainException con mapeo normalizado bajo el estándar RFC 7807: BillingDomainException como raíz jerárquica, DuplicateActiveSubscriptionException, InvalidPlanPricingException, InvalidWebhookSignatureException, PlanNotFoundException, QuotaExceededException, SaasInvoiceNotFoundException, StripeIntegrationException, StripeWebhookProcessingException, SubscriptionNotFoundException y SubscriptionPastDueException.

En la @tbl:billing-domain-classes-members se detalla la especificación formal de atributos, firmas de métodos, modificadores de acceso y reglas de negocio para cada componente de la Capa de Dominio.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo exhaustivo de clases, miembros, ámbitos y relaciones de la Capa de Dominio del Bounded Context SaaS Billing \& Subscriptions} \label{tbl:billing-domain-classes-members} \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Subscription\allowbreak Plan \quad (\textit{Aggregate Root})} \\*
\hline
Atributos y composición & Raíz de agregado del catálogo de planes comerciales. Custodia la soberanía tarifaria, niveles de servicio, límites operativos y capacidades modulares empaquetadas. Generalización de \texttt{AbstractDomainAggregateRoot<\allowbreak PlanId>\allowbreak }. Composición 1 a 1 con \textbf{PlanPricing} y \textbf{TenantQuotaLimits}, y 1 a 0..* con \textbf{PlanFeature}. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{PlanId id} \newline - \texttt{StripePriceId stripePriceId} \newline - \texttt{String name} \newline - \texttt{PlanTier tier} \newline - \texttt{PlanPricing pricing} \newline - \texttt{TenantQuotaLimits quotaLimits} \newline - \texttt{List<\allowbreak PlanFeature>\allowbreak  features} \newline - \texttt{boolean isActive} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Factoría y gestión comercial & Invariantes: el plan nace en estado comercialmente activo. El precio base y el ciclo tarifario deben ser consistentes. El identificador de Stripe Price es inmutable tras su asignación. Emite Subscription\allowbreak Plan\allowbreak Created\allowbreak Event. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Subscription\allowbreak Plan create(StripePriceId,\allowbreak  String,\allowbreak  PlanTier,\allowbreak  PlanPricing,\allowbreak  TenantQuotaLimits,\allowbreak  List<\allowbreak PlanFeature>\allowbreak )} \newline - \texttt{void updateDetails(String,\allowbreak  PlanPricing,\allowbreak  TenantQuotaLimits)} \newline - \texttt{void addFeature(PlanFeature)} \newline - \texttt{void removeFeature(String)} \newline - \texttt{boolean hasFeature(String)} \newline - \texttt{void activate()} \newline - \texttt{void deactivate()} \newline - \texttt{PlanId id()} \newline - \texttt{StripePriceId stripePriceId()} \newline - \texttt{PlanTier tier()} \newline - \texttt{PlanPricing pricing()} \newline - \texttt{TenantQuotaLimits quotaLimits()} \newline - \texttt{List<\allowbreak PlanFeature>\allowbreak  features()} \newline - \texttt{boolean isActive()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Tenant\allowbreak Subscription \quad (\textit{Aggregate Root})} \\*
\hline
Atributos y vigencia & Raíz de agregado que gobierna el contrato de servicio SaaS del taller mecánico. Controla transiciones operativas de membresía, periodos de cobertura pagada, suspensiones por impago y desafiliaciones. Generalización de \texttt{AbstractDomainAggregateRoot<\allowbreak SubscriptionId>\allowbreak }. Composición 1 a 1 con \textbf{SubscriptionPeriod}. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{SubscriptionId id} \newline - \texttt{TenantId tenantId} \newline - \texttt{PlanId planId} \newline - \texttt{StripeCustomerId stripeCustomerId} \newline - \texttt{StripeSubscriptionId stripeSubscriptionId} \newline - \texttt{SubscriptionStatus status} \newline - \texttt{SubscriptionPeriod currentPeriod} \newline - \texttt{boolean cancelAtPeriodEnd} \newline - \texttt{Optional<\allowbreak Instant>\allowbreak  canceledAt} \newline - \texttt{Optional<\allowbreak Instant>\allowbreak  trialEndDate} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Ciclo de vida y transiciones & Invariantes: un taller solo puede mantener una suscripción activa de forma concurrente. La activación formal conmuta a ACTIVE y emite Tenant\allowbreak Subscription\allowbreak Activated\allowbreak Event. La renovación extiende el periodo y emite Tenant\allowbreak Subscription\allowbreak Renewed\allowbreak Event. El impago transiciona a PAST\_DUE emitiendo Tenant\allowbreak Subscription\allowbreak PastDue\allowbreak Event. La desafiliación programa la baja o la ejecuta inmediatamente emitiendo Tenant\allowbreak Subscription\allowbreak Canceled\allowbreak Event. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Tenant\allowbreak Subscription startTrial(TenantId,\allowbreak  PlanId,\allowbreak  StripeCustomerId,\allowbreak  int)} \newline - \texttt{Tenant\allowbreak Subscription activate(TenantId,\allowbreak  PlanId,\allowbreak  StripeCustomerId,\allowbreak  StripeSubscriptionId,\allowbreak  SubscriptionPeriod)} \newline - \texttt{void renewPeriod(SubscriptionPeriod)} \newline - \texttt{void markPastDue()} \newline - \texttt{void markUnpaid()} \newline - \texttt{void cancelAtPeriodEnd()} \newline - \texttt{void cancelImmediately(Instant)} \newline - \texttt{void reactivate()} \newline - \texttt{void changePlan(PlanId,\allowbreak  StripePriceId)} \newline - \texttt{boolean isAccessGranted()} \newline - \texttt{SubscriptionId id()} \newline - \texttt{TenantId tenantId()} \newline - \texttt{PlanId planId()} \newline - \texttt{StripeCustomerId stripeCustomerId()} \newline - \texttt{StripeSubscriptionId stripeSubscriptionId()} \newline - \texttt{SubscriptionStatus status()} \newline - \texttt{SubscriptionPeriod currentPeriod()} \newline - \texttt{boolean isCancelAtPeriodEnd()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Saas\allowbreak Invoice \quad (\textit{Aggregate Root})} \\*
\hline
Atributos y recaudación & Raíz de agregado contable de liquidación SaaS. Custodia los comprobantes de cobro emitidos por Stripe hacia el taller abonado, montos recaudados, divisa pactada y enlaces a comprobantes fiscales hospedados. Generalización de \texttt{AbstractDomainAggregateRoot<\allowbreak SaasInvoiceId>\allowbreak }. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{SaasInvoiceId id} \newline - \texttt{SubscriptionId subscriptionId} \newline - \texttt{TenantId tenantId} \newline - \texttt{StripeInvoiceId stripeInvoiceId} \newline - \texttt{Money amountPaid} \newline - \texttt{Currency currency} \newline - \texttt{InvoiceStatus status} \newline - \texttt{String invoicePdfUrl} \newline - \texttt{String hostedInvoiceUrl} \newline - \texttt{Optional<\allowbreak Instant>\allowbreak  paidAt} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Liquidación y auditoría contable & Invariantes: el monto saldado debe ser estrictamente positivo. La confirmación de pago conmuta el estado a PAID y emite Saas\allowbreak Invoice\allowbreak Paid\allowbreak Event. El fallo en la transacción bancaria conmuta a OPEN o UNCOLLECTIBLE registrando el motivo y emite Saas\allowbreak Invoice\allowbreak PaymentFailed\allowbreak Event. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Saas\allowbreak Invoice recordPaid(SubscriptionId,\allowbreak  TenantId,\allowbreak  StripeInvoiceId,\allowbreak  Money,\allowbreak  String,\allowbreak  String,\allowbreak  Instant)} \newline - \texttt{void markPaymentFailed(String)} \newline - \texttt{void markVoid()} \newline - \texttt{SaasInvoiceId id()} \newline - \texttt{SubscriptionId subscriptionId()} \newline - \texttt{TenantId tenantId()} \newline - \texttt{StripeInvoiceId stripeInvoiceId()} \newline - \texttt{Money amountPaid()} \newline - \texttt{Currency currency()} \newline - \texttt{InvoiceStatus status()} \newline - \texttt{String invoicePdfUrl()} \newline - \texttt{String hostedInvoiceUrl()} \newline - \texttt{Optional<\allowbreak Instant>\allowbreak  paidAt()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Stripe\allowbreak Webhook\allowbreak Event \quad (\textit{Aggregate Root})} \\*
\hline
Atributos e idempotencia & Raíz de agregado de auditoría telemática e idempotencia estricta. Custodia el identificador del evento de Stripe, tipo de notificación, carga JSON inmutable y estado de deduplicación relacional. Generalización de \texttt{AbstractDomainAggregateRoot<\allowbreak UUID>\allowbreak }. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{UUID id} \newline - \texttt{StripeEventId stripeEventId} \newline - \texttt{String eventType} \newline - \texttt{String eventPayload} \newline - \texttt{WebhookProcessingStatus status} \newline - \texttt{Optional<\allowbreak Instant>\allowbreak  processedAt} \newline - \texttt{Optional<\allowbreak String>\allowbreak  errorMessage} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Deduplicación y procesamiento & Invariantes: el identificador de evento de Stripe es unívoco en toda la plataforma. La recepción inicial establece estado PENDING. El procesamiento exitoso sella con marca de tiempo UTC y emite Stripe\allowbreak Webhook\allowbreak Processed\allowbreak Event. El fallo registra la causa sin alterar la carga original. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Stripe\allowbreak Webhook\allowbreak Event receive(StripeEventId,\allowbreak  String,\allowbreak  String)} \newline - \texttt{void markProcessed(Instant)} \newline - \texttt{void markFailed(String)} \newline - \texttt{void markIgnored()} \newline - \texttt{UUID id()} \newline - \texttt{StripeEventId stripeEventId()} \newline - \texttt{String eventType()} \newline - \texttt{String eventPayload()} \newline - \texttt{WebhookProcessingStatus status()} \newline - \texttt{Optional<\allowbreak Instant>\allowbreak  processedAt()} \newline - \texttt{Optional<\allowbreak String>\allowbreak  errorMessage()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Plan\allowbreak Feature \quad (\textit{Entity})} \\*
\hline
Atributos y capacidad & Entidad dependiente subordinada a \textbf{SubscriptionPlan}. Modela una característica funcional paquetizada en el licenciamiento SaaS, tal como telemetría OBD-II en tiempo real o diagnósticos predictivos mediante inteligencia artificial. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{PlanFeatureId id} \newline - \texttt{PlanId planId} \newline - \texttt{String featureKey} \newline - \texttt{String description} \newline - \texttt{boolean isEnabled} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Operaciones de habilitación & Invariantes: la clave de funcionalidad es alfanumérica y unívoca dentro del plan. Permite activar o suspender el acceso a módulos tecnológicos especializados de Atelier. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{PlanFeature of(PlanFeatureId,\allowbreak  PlanId,\allowbreak  String,\allowbreak  String,\allowbreak  boolean)} \newline - \texttt{void enable()} \newline - \texttt{void disable()} \newline - \texttt{PlanFeatureId id()} \newline - \texttt{PlanId planId()} \newline - \texttt{String featureKey()} \newline - \texttt{String description()} \newline - \texttt{boolean isEnabled()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Dominio:} Subscription\allowbreak Quota\allowbreak Enforcement\allowbreak Service} \\*
\hline
Fiscalización de cuotas & Servicio de dominio puro sin estado. Aplica algoritmos deterministas para contrastar el consumo acumulado de sedes físicas, mecánicos en plantilla y órdenes de trabajo mensuales contra las cuotas pactadas en el plan activo. Emite \textbf{QuotaExceededException} ante sobregiros. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{void validateBranchCreationAllowed(TenantSubscription,\allowbreak  SubscriptionPlan,\allowbreak  int)} \newline - \texttt{void validateStaffAdditionAllowed(TenantSubscription,\allowbreak  SubscriptionPlan,\allowbreak  int)} \newline - \texttt{void validateWorkOrderCreationAllowed(TenantSubscription,\allowbreak  SubscriptionPlan,\allowbreak  int)} \newline - \texttt{boolean isFeatureEnabled(TenantSubscription,\allowbreak  SubscriptionPlan,\allowbreak  String)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Dominio:} Stripe\allowbreak Webhook\allowbreak Signature\allowbreak Verification\allowbreak Service} \\*
\hline
Autenticación criptográfica & Servicio criptográfico sin estado. Computa firmas digitales HMAC-SHA256 sobre el cuerpo sin procesar de los webhooks utilizando la clave institucional secreta de endpoint, verificando marcas temporales contra ataques de repetición. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{boolean verifySignature(String,\allowbreak  String,\allowbreak  String)} \newline - \texttt{long extractTimestamp(String)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Dominio:} Subscription\allowbreak Lifecycle\allowbreak Domain\allowbreak Service} \\*
\hline
Gobernanza de ciclo de vida & Servicio de dominio puro sin estado. Gobierna las políticas contractuales, evaluación de ventanas temporales de gracia, condiciones de reactivación y reglas de expiración ante impago prolongado. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{boolean isGracePeriodActive(TenantSubscription,\allowbreak  Instant)} \newline - \texttt{boolean canReactivate(TenantSubscription)} \newline - \texttt{void evaluateExpirationPolicy(TenantSubscription,\allowbreak  Instant)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puertos de Repositorio:} Repositorios de Persistencia de Dominio} \\*
\hline
Subscription\allowbreak Plan\allowbreak Repository & Contrato agnóstico de persistencia para el catálogo comercial de planes de software. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{SubscriptionPlan save(SubscriptionPlan)} \newline - \texttt{Optional<\allowbreak SubscriptionPlan>\allowbreak  findById(PlanId)} \newline - \texttt{Optional<\allowbreak SubscriptionPlan>\allowbreak  findByStripePriceId(StripePriceId)} \newline - \texttt{List<\allowbreak SubscriptionPlan>\allowbreak  findAllActive()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
Tenant\allowbreak Subscription\allowbreak Repository & Contrato de persistencia para las membresías de talleres mecánicos con búsqueda por taller y estado. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{TenantSubscription save(TenantSubscription)} \newline - \texttt{Optional<\allowbreak TenantSubscription>\allowbreak  findById(SubscriptionId)} \newline - \texttt{Optional<\allowbreak TenantSubscription>\allowbreak  findByTenantId(TenantId)} \newline - \texttt{Optional<\allowbreak TenantSubscription>\allowbreak  findByStripeSubscriptionId(StripeSubscriptionId)} \newline - \texttt{List<\allowbreak TenantSubscription>\allowbreak  findAllByStatus(SubscriptionStatus)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
Saas\allowbreak Invoice\allowbreak Repository & Contrato de persistencia para los recibos contables generados por liquidación recurrente. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{SaasInvoice save(SaasInvoice)} \newline - \texttt{Optional<\allowbreak SaasInvoice>\allowbreak  findById(SaasInvoiceId)} \newline - \texttt{Optional<\allowbreak SaasInvoice>\allowbreak  findByStripeInvoiceId(StripeInvoiceId)} \newline - \texttt{List<\allowbreak SaasInvoice>\allowbreak  findAllByTenantId(TenantId)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
Stripe\allowbreak Webhook\allowbreak Event\allowbreak Repository & Contrato de persistencia para la tabla de eventos con verificación de unicidad atómica. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{StripeWebhookEvent save(StripeWebhookEvent)} \newline - \texttt{Optional<\allowbreak StripeWebhookEvent>\allowbreak  findByStripeEventId(StripeEventId)} \newline - \texttt{boolean existsByStripeEventId(StripeEventId)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Identificadores Fuertemente Tipados:} Identidades de Dominio} \\*
\hline
Identificadores tipados & Registros inmutables que realizan \texttt{TypedId} para erradicar la obsesión por tipos primitivos y garantizar seguridad de tipos en compilación. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{record PlanId(UUID value)} \newline - \texttt{record SubscriptionId(UUID value)} \newline - \texttt{record SaasInvoiceId(UUID value)} \newline - \texttt{record StripeEventId(String value)} \newline - \texttt{record PlanFeatureId(UUID value)} \newline - \texttt{static of(UUID / String)} \newline - \texttt{static generate()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objetos de Valor Inmutables:} Estructuras de Licenciamiento y Pasarela} \\*
\hline
Plan\allowbreak Pricing & Registro inmutable que empaqueta la cuantía monetaria y la cadencia recurrente de cobro. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Money price} \newline - \texttt{BillingCycle billingCycle} \newline - \texttt{PlanPricing of(Money,\allowbreak  BillingCycle)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
Identificadores remotos de Stripe & Registros inmutables que encapsulan identificadores alfanuméricos oficiales de Stripe con validación de prefijos reglamentarios. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{record StripeCustomerId(String value)} \quad (prefijo cus\_) \newline - \texttt{record StripeSubscriptionId(String value)} \quad (prefijo sub\_) \newline - \texttt{record StripePriceId(String value)} \quad (prefijo price\_) \newline - \texttt{record StripeInvoiceId(String value)} \quad (prefijo in\_) \\*
\hline
\textbf{Ámbito} & Público \\
\hline
Subscription\allowbreak Period & Registro inmutable que delimita el intervalo temporal de cobertura pagada. Métodos: \texttt{isActiveAt(Instant)} y \texttt{daysRemaining(Instant)}. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Instant startDate} \newline - \texttt{Instant endDate} \newline - \texttt{SubscriptionPeriod of(Instant,\allowbreak  Instant)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
Tenant\allowbreak Quota\allowbreak Limits & Registro inmutable que cuantifica las capacidades máximas autorizadas por taller mecánico. Métodos: \texttt{canAddBranch(int)}, \texttt{canAddStaff(int)}, \texttt{canCreateWorkOrder(int)}, \texttt{canRegisterObd2Device(int)}, \texttt{canUploadPhotos(int)}, \texttt{canRegisterCompanyCustomer()}, \texttt{canGenerateAiReport(int)} y \texttt{canPerformMultiWarehouseTransfer()}. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{int maxBranches} \newline - \texttt{int maxActiveStaff} \newline - \texttt{int maxActiveObd2Devices} \newline - \texttt{int maxPhotosPerWorkOrder} \newline - \texttt{int maxMonthlyAiReports} \newline - \texttt{boolean companyRegistrationAllowed} \newline - \texttt{boolean multiWarehouseAllowed} \newline - \texttt{boolean marketplaceListed} \newline - \texttt{int maxMonthlyWorkOrders} \newline - \texttt{boolean iotTelemetryEnabled} \newline - \texttt{boolean aiDiagnosticsEnabled} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeraciones de Dominio:} Vocabularios Controlados Inmutables} \\*
\hline
Enumeraciones de Dominio & Vocabularios controlados inmutables que tipifican niveles comerciales, periodicidades, estados contractuales, liquidaciones y deduplicación de eventos. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{PlanTier (GO,\allowbreak  PRO,\allowbreak  MAX,\allowbreak  ENTERPRISE)} \newline - \texttt{BillingCycle (MONTHLY,\allowbreak  YEARLY)} \newline - \texttt{SubscriptionStatus (TRIALING,\allowbreak  ACTIVE,\allowbreak  PAST\_DUE,\allowbreak  CANCELED,\allowbreak  UNPAID,\allowbreak  INCOMPLETE)} \newline - \texttt{InvoiceStatus (PAID,\allowbreak  OPEN,\allowbreak  VOID,\allowbreak  UNCOLLECTIBLE)} \newline - \texttt{WebhookProcessingStatus (PENDING,\allowbreak  PROCESSED,\allowbreak  FAILED,\allowbreak  IGNORED)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Eventos de Dominio:} Mutaciones Transaccionales para Transactional Outbox} \\*
\hline
Eventos de Dominio & Registros inmutables que implementan \texttt{DomainEvent}. Describen mutaciones transaccionales en el ciclo de suscripciones y facturación para propagación asíncrona mediante el Transactional Outbox. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Subscription\allowbreak Plan\allowbreak Created\allowbreak Event(PlanId,\allowbreak  StripePriceId,\allowbreak  String,\allowbreak  PlanTier,\allowbreak  PlanPricing,\allowbreak  TenantQuotaLimits,\allowbreak  Instant)} \newline - \texttt{Tenant\allowbreak Subscription\allowbreak Activated\allowbreak Event(SubscriptionId,\allowbreak  TenantId,\allowbreak  PlanId,\allowbreak  StripeSubscriptionId,\allowbreak  SubscriptionPeriod,\allowbreak  Instant)} \newline - \texttt{Tenant\allowbreak Subscription\allowbreak Renewed\allowbreak Event(SubscriptionId,\allowbreak  TenantId,\allowbreak  SubscriptionPeriod,\allowbreak  Instant)} \newline - \texttt{Tenant\allowbreak Subscription\allowbreak PastDue\allowbreak Event(SubscriptionId,\allowbreak  TenantId,\allowbreak  Instant)} \newline - \texttt{Tenant\allowbreak Subscription\allowbreak Canceled\allowbreak Event(SubscriptionId,\allowbreak  TenantId,\allowbreak  boolean,\allowbreak  Instant)} \newline - \texttt{Tenant\allowbreak Plan\allowbreak Changed\allowbreak Event(SubscriptionId,\allowbreak  TenantId,\allowbreak  PlanId,\allowbreak  StripePriceId,\allowbreak  Instant)} \newline - \texttt{Saas\allowbreak Invoice\allowbreak Paid\allowbreak Event(SaasInvoiceId,\allowbreak  SubscriptionId,\allowbreak  TenantId,\allowbreak  StripeInvoiceId,\allowbreak  Money,\allowbreak  Instant)} \newline - \texttt{Saas\allowbreak Invoice\allowbreak Payment\allowbreak Failed\allowbreak Event(SaasInvoiceId,\allowbreak  SubscriptionId,\allowbreak  TenantId,\allowbreak  StripeInvoiceId,\allowbreak  String,\allowbreak  Instant)} \newline - \texttt{Stripe\allowbreak Webhook\allowbreak Processed\allowbreak Event(UUID,\allowbreak  StripeEventId,\allowbreak  String,\allowbreak  Instant)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Jerarquía de Excepciones Semánticas:} Errores de Negocio RFC 7807} \\*
\hline
Excepciones RFC 7807 & Excepciones semánticas no comprobadas derivadas de \texttt{DomainException}. Portan códigos canónicos normalizados bajo RFC 7807 para mapeo HTTP 4xx en la capa perimetral ante infracciones de cuotas, precios inválidos, planes inexistentes, suscripciones duplicadas o firmas ilegítimas. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{BillingDomainException} \newline - \texttt{DuplicateActiveSubscriptionException} \newline - \texttt{InvalidPlanPricingException} \newline - \texttt{InvalidWebhookSignatureException} \newline - \texttt{PlanNotFoundException} \newline - \texttt{QuotaExceededException} \newline - \texttt{SaasInvoiceNotFoundException} \newline - \texttt{StripeIntegrationException} \newline - \texttt{StripeWebhookProcessingException} \newline - \texttt{SubscriptionNotFoundException} \newline - \texttt{SubscriptionPastDueException} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación formal de miembros, modificadores de acceso, tipos de retorno y relaciones de la Capa de Dominio en com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak billing.\allowbreak domain.

A partir del modelo estático ilustrado en la @fig:class-diagram-billing y desglosado en la @tbl:billing-domain-classes-members, se identifican tres fundamentos de ingeniería de software que respaldan la solidez y soberanía financiera de la plataforma:

- **Aislamiento Normativo PCI-DSS Nivel 1 y Desacoplamiento de Modelos Contables:**
  El diseño arquitectónico impone una separación radical entre los cobros comerciales corporativos que Andeva factura a los talleres automotrices y los comprobantes fiscales que cada taller emite a conductores particulares bajo normativa de SUNAT en Invoicing & Compliance. Al delegar completamente la captura de números de tarjeta de crédito e instrumentos bancarios hacia Stripe Checkout y Stripe Customer Portal, el backend de Atelier prescinde de almacenar credenciales financieras sensibles, reteniendo únicamente tokens opacos de cliente y suscripción en **TenantSubscription**, erradicando riesgos de vulneración de datos bancarios.

- **Criptografía Simétrica HMAC-SHA256, Idempotencia y Resiliencia en Notificaciones:**
  La recepción de eventos asíncronos de facturación recurrente se salvaguarda mediante autenticación criptográfica obligatoria en **StripeWebhookSignatureVerificationService**, neutralizando intentos de suplantación mediante la verificación del hash simétrico HMAC-SHA256. Asimismo, la raíz **StripeWebhookEvent** actúa como cerrojo de persistencia relacional frente a la tabla **stripe_webhook_events**, garantizando que las confirmaciones de abono o alertas de morosidad se procesen exactamente una vez y descartando de manera inocua las transmisiones duplicadas originadas por reintentos de red.

- **Fiscalización Determinista de Cuotas Operativas y Aceleración en Memoria RAM:**
  La gobernanza de capacidades de plataforma se aísla en el motor algorítmico **SubscriptionQuotaEnforcementService**, el cual valida en tiempo de ejecución que ningún taller sobrepase el techo contratado de sucursales activas, mecánicos en nómina u órdenes mensuales de servicio. Al articularse con una fachada Open Host Service respaldada en memoria mediante Caffeine Cache, el sistema resuelve verificaciones de cuota con latencia sub-milisegundo (< 0.05 ms), asegurando que tanto las estaciones web de administración como los asesores en bahía y mecánicos en campo gocen de una respuesta inmediata sin penalizar a la base de datos relacional.

##### 2.6.8.6.2. *Bounded Context Database Design Diagram*

El diseño de persistencia del Bounded Context SaaS Billing & Subscriptions materializa el modelo de dominio en un esquema relacional enfocado en garantizar aislamiento estricto de datos por inquilino, integridad contable y disponibilidad ininterrumpida. La persistencia se distribuye en dos componentes físicos complementarios: la base de datos central PostgreSQL 16 para el backend de la plataforma (**API Application**) y el motor relacional embebido SQLite 3 para la aplicación técnica móvil de taller (**Mobile Workshop**).

En la @fig:database-diagram-billing se presenta el Diagrama Entidad-Relación físico para la persistencia del Bounded Context SaaS Billing & Subscriptions en sus dos entornos operativos de despliegue: la base de datos central PostgreSQL 16 de la API de backend y el motor relacional local SQLite 3 de la aplicación móvil de taller.

![Diagrama Entidad-Relación de Base de Datos para el Bounded Context SaaS Billing & Subscriptions (PostgreSQL 16 y SQLite 3)](report/assets/database-diagrams/database-diagram-billing.png){#fig:database-diagram-billing}

*Nota.* Elaboración propia en base al diseño físico de persistencia y el estándar PlantUML ERD.

- **Subsistema de Catálogo Comercial y Capacidades Granulares:**
  Gobierna la definición jerárquica de planes comerciales y capacidades modulares mediante las tablas **plans** y **plan_features**. La tabla **plans** custodia las tarifas monetarias recurrentes, ciclos contables e hitos cuantitativos de plataforma, como sucursales autorizadas y técnicos en plantilla. A su vez, la tabla **plan_features** normaliza en una relación de composición uno a muchos las banderas booleanas de activación funcional para características avanzadas, tales como telemetría vehicular OBD-II continua o algoritmos de diagnóstico predictivo.

- **Subsistema de Membresías Contractuales y Ciclos de Facturación:**
  Administra el ciclo de vida ontológico del contrato de suscripción del taller automotriz mediante la tabla **subscriptions**. Esta entidad vincula directamente al inquilino con su plan vigente y preserva los identificadores remotos en Stripe. Asimismo, gobierna de forma determinista los estados de vigencia operativa, períodos de gracia de prueba, cancelaciones diferidas a fin de ciclo y marcas temporales de corte para renovación automática.

- **Subsistema de Recaudación Periódica y Trazabilidad de Pagos:**
  Registra la bitácora contable de cobros recurrentes de software mediante la tabla **saas_invoices**. Esta tabla sincroniza los cobros bancarios procesados por Stripe Invoices, resguardando el monto exacto debitado, la divisa de transacción, el estado de liquidación y los enlaces seguros hacia los comprobantes en formato PDF y portales de pago hospedados, garantizando una auditoría financiera inmutable para los administradores del taller.

- **Subsistema de Auditoría Transaccional e Idempotencia de Webhooks:**
  Proporciona un cerrojo criptográfico y de concurrencia contra entregas duplicadas de Stripe Webhooks mediante la tabla **stripe_webhook_events**. Al imponer una restricción de unicidad estricta sobre el identificador único del evento y custodiar la carga útil completa en formato de texto, el sistema garantiza procesamiento exactamente una vez, descartando automáticamente reintentos de red sin degradar la consistencia de las membresías.

- **Persistencia Técnica Desconectada en SQLite 3:**
  Otorga soberanía operacional al cliente móvil de taller mediante las tablas locales **local_subscription_cache** y **local_plan_features_cache**. La tabla **local_subscription_cache** resguarda en el dispositivo del técnico una réplica ligera de las cuotas operativas vigentes y el estado de la suscripción, facultando la evaluación de límites en foso o patio sin depender de conectividad celular. De forma análoga, la tabla **local_plan_features_cache** mantiene las autorizaciones modulares para habilitar o restringir componentes de la interfaz de usuario en movilidad.

A partir de la arquitectura relacional definida en el diagrama de persistencia, en la @tbl:billing-database-tables-schema se cataloga la totalidad de las tablas y objetos físicos que conforman el modelo de datos, detallando el producto donde residen, sus atributos cardinales, restricciones de integridad, estrategias de indexación y su contribución al aislamiento de información.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.1cm} | >{\raggedright\arraybackslash}p{10.3cm} |}
\caption{Catálogo exhaustivo de tablas, objetos de base de datos, restricciones e índices físicos del Bounded Context SaaS Billing \& Subscriptions} \label{tbl:billing-database-tables-schema} \\
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{plans}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Catálogo maestro de planes comerciales de suscripción SaaS ofertados por Andeva a los talleres mecánicos en los niveles Go, Pro, Max y Enterprise. Define el precio recurrente, divisa, periodicidad contable y los techos de cuotas operativas para sucursales, mecánicos activos, dispositivos OBD-II, fotos por orden de trabajo, reportes mensuales de IA y órdenes de trabajo mensuales permitidas, así como habilitaciones para registro de flotas empresariales, multialmacén intersede, presencia en marketplace B2B, telemetría IoT y diagnóstico predictivo con IA. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID PK)}, \texttt{stripe\_price\_id (VARCHAR(100) UK)}, \texttt{name (VARCHAR(100))}, \texttt{tier (VARCHAR(20))}, \texttt{price (DECIMAL(10,2))}, \texttt{currency (VARCHAR(3))}, \texttt{billing\_cycle (VARCHAR(20))}, \texttt{max\_branches (INTEGER)}, \texttt{max\_active\_staff (INTEGER)}, \texttt{max\_active\_obd2\_devices (INTEGER)}, \texttt{max\_photos\_per\_work\_order (INTEGER)}, \texttt{max\_monthly\_ai\_reports (INTEGER)}, \texttt{company\_registration\_allowed (BOOLEAN)}, \texttt{multi\_warehouse\_allowed (BOOLEAN)}, \texttt{marketplace\_listed (BOOLEAN)}, \texttt{max\_monthly\_work\_orders (INTEGER)}, \texttt{iot\_telemetry\_enabled (BOOLEAN)}, \texttt{ai\_diagnostics\_enabled (BOOLEAN)}, \texttt{is\_active (BOOLEAN)}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ)}, \texttt{version (BIGINT)}, \texttt{deleted\_at (TIMESTAMPTZ)}. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_\allowbreak plans (id) \newline - UK: uk\_\allowbreak plans\_\allowbreak stripe\_\allowbreak price\_\allowbreak id (stripe\_price\_id) \newline - CHECK: chk\_\allowbreak plans\_\allowbreak tier (tier IN ('GO', 'PRO', 'MAX', 'ENTERPRISE')), chk\_\allowbreak plans\_\allowbreak cycle (billing\_cycle IN ('MONTHLY', 'YEARLY')), chk\_\allowbreak plans\_\allowbreak price (price >= 0.00), chk\_\allowbreak plans\_\allowbreak max\_\allowbreak branches (max\_branches > 0), chk\_\allowbreak plans\_\allowbreak max\_\allowbreak staff (max\_active\_staff > 0) \newline - Índices B-Tree: idx\_\allowbreak plans\_\allowbreak tier (tier), idx\_\allowbreak plans\_\allowbreak active (is\_active), idx\_\allowbreak plans\_\allowbreak stripe\_\allowbreak price (stripe\_price\_id) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{plan\allowbreak \_features}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Desglose granular de funcionalidades, módulos de software y capacidades técnicas habilitadas o restringidas por plan comercial. Permite el control modular de acceso a características como telemetría OBD-II continua, gestión multialmacén, alertas predictivas por algoritmos analíticos y facturación electrónica ilimitada. Integridad referencial en cascada asociada al ciclo de vida del plan maestro. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID PK)}, \texttt{plan\_id (UUID FK)}, \texttt{feature\_key (VARCHAR(50))}, \texttt{description (VARCHAR(255))}, \texttt{is\_enabled (BOOLEAN)}, \texttt{created\_at (TIMESTAMPTZ)}. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_\allowbreak plan\_\allowbreak features (id) \newline - FK: fk\_\allowbreak plan\_\allowbreak features\_\allowbreak plan\_\allowbreak id hacia plans(id) con ON DELETE CASCADE \newline - UK: uk\_\allowbreak plan\_\allowbreak features\_\allowbreak key (plan\_id, feature\_key) \newline - CHECK: chk\_\allowbreak feature\_\allowbreak key\_\allowbreak not\_\allowbreak empty (LENGTH(feature\_key) > 0) \newline - Índices B-Tree: idx\_\allowbreak plan\_\allowbreak features\_\allowbreak plan (plan\_id), idx\_\allowbreak plan\_\allowbreak features\_\allowbreak lookup (plan\_id, feature\_key, is\_enabled) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{subscriptions}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Membresía contractual y estado de afiliación comercial del taller automotriz cliente con la plataforma Atelier. Vincula al inquilino con su plan comercial contratado y custodia los identificadores externos del cliente y suscripción recurrente en Stripe. Gobierna las fechas de inicio y corte del período contable, la programación de cancelaciones a término de ciclo y las fechas de expiración de periodos de prueba gratuita. Aislamiento multi-inquilino estricto con restricción de unicidad por taller. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID PK)}, \texttt{tenant\_id (UUID UK FK)}, \texttt{plan\_id (UUID FK)}, \texttt{stripe\_customer\_id (VARCHAR(100))}, \texttt{stripe\_sub\_id (VARCHAR(100))}, \texttt{status (VARCHAR(20))}, \texttt{current\_period\_start (TIMESTAMPTZ)}, \texttt{current\_period\_end (TIMESTAMPTZ)}, \texttt{cancel\_at\_period\_end (BOOLEAN)}, \texttt{canceled\_at (TIMESTAMPTZ)}, \texttt{trial\_end\_date (TIMESTAMPTZ)}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ)}, \texttt{version (BIGINT)}, \texttt{deleted\_at (TIMESTAMPTZ)}. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_\allowbreak subscriptions (id) \newline - FK: fk\_\allowbreak subscriptions\_\allowbreak tenant\_\allowbreak id hacia tenants(id), fk\_\allowbreak subscriptions\_\allowbreak plan\_\allowbreak id hacia plans(id) \newline - UK: uk\_\allowbreak subscriptions\_\allowbreak tenant\_\allowbreak id (tenant\_id) \newline - CHECK: chk\_\allowbreak subscription\_\allowbreak status (status IN ('TRIALING', 'ACTIVE', 'PAST\_DUE', 'CANCELED', 'UNPAID', 'INCOMPLETE')) \newline - Índices B-Tree: idx\_\allowbreak subscriptions\_\allowbreak tenant (tenant\_id), idx\_\allowbreak subscriptions\_\allowbreak status (status), idx\_\allowbreak subscriptions\_\allowbreak stripe\_\allowbreak sub (stripe\_sub\_id), idx\_\allowbreak subscriptions\_\allowbreak period\_\allowbreak end (current\_period\_end) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{saas\allowbreak \_invoices}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Registro histórico y comprobante contable de recaudación recurrente emitido por Andeva al taller automotriz por el uso del software SaaS. Sincronizado bidireccionalmente con los cobros exitosos procesados en Stripe Invoices. Custodia el importe debitado en tarjeta, la moneda del cobro, el estado de liquidación, la marca temporal del pago y los enlaces seguros para la descarga del recibo en formato PDF o visualización en Stripe Hosted Invoice. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID PK)}, \texttt{subscription\_id (UUID FK)}, \texttt{tenant\_id (UUID FK)}, \texttt{stripe\_invoice\_id (VARCHAR(100) UK)}, \texttt{amount\_paid (DECIMAL(10,2))}, \texttt{currency (VARCHAR(3))}, \texttt{status (VARCHAR(20))}, \texttt{invoice\_pdf\_url (VARCHAR(255))}, \texttt{hosted\_invoice\_url (VARCHAR(255))}, \texttt{paid\_at (TIMESTAMPTZ)}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ)}, \texttt{version (BIGINT)}, \texttt{deleted\_at (TIMESTAMPTZ)}. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_\allowbreak saas\_\allowbreak invoices (id) \newline - FK: fk\_\allowbreak saas\_\allowbreak invoices\_\allowbreak subscription\_\allowbreak id hacia subscriptions(id), fk\_\allowbreak saas\_\allowbreak invoices\_\allowbreak tenant\_\allowbreak id hacia tenants(id) \newline - UK: uk\_\allowbreak saas\_\allowbreak invoices\_\allowbreak stripe\_\allowbreak invoice\_\allowbreak id (stripe\_invoice\_id) \newline - CHECK: chk\_\allowbreak saas\_\allowbreak invoice\_\allowbreak status (status IN ('DRAFT', 'OPEN', 'PAID', 'UNCOLLECTIBLE', 'VOID')), chk\_\allowbreak saas\_\allowbreak invoice\_\allowbreak amount\_\allowbreak paid (amount\_paid >= 0.00) \newline - Índices B-Tree: idx\_\allowbreak saas\_\allowbreak invoices\_\allowbreak subscription (subscription\_id), idx\_\allowbreak saas\_\allowbreak invoices\_\allowbreak tenant\_\allowbreak paid (tenant\_id, paid\_at), idx\_\allowbreak saas\_\allowbreak invoices\_\allowbreak status (status) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{stripe\allowbreak \_webhook\allowbreak \_events}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Registro transaccional de auditoría y cerrojo de concurrencia e idempotencia para notificaciones asíncronas transmitidas por Stripe Webhooks. Resguarda el identificador único del evento emitido por Stripe, la tipología semántica de notificación, la carga útil JSON inmutable, el estado de procesamiento en la plataforma Atelier y los diagnósticos de excepción en caso de error. Previene el doble procesamiento ante reintentos automáticos de red de Stripe. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID PK)}, \texttt{stripe\_event\_id (VARCHAR(100) UK)}, \texttt{type (VARCHAR(50))}, \texttt{payload (TEXT)}, \texttt{status (VARCHAR(20))}, \texttt{processed\_at (TIMESTAMPTZ)}, \texttt{error\_message (VARCHAR(500))}. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_\allowbreak stripe\_\allowbreak webhook\_\allowbreak events (id) \newline - UK: uk\_\allowbreak stripe\_\allowbreak webhook\_\allowbreak events\_\allowbreak event\_\allowbreak id (stripe\_event\_id) \newline - CHECK: chk\_\allowbreak stripe\_\allowbreak webhook\_\allowbreak event\_\allowbreak status (status IN ('PENDING', 'PROCESSED', 'FAILED', 'IGNORED')) \newline - Índices B-Tree: idx\_\allowbreak stripe\_\allowbreak webhook\_\allowbreak events\_\allowbreak status (status, processed\_at), idx\_\allowbreak stripe\_\allowbreak webhook\_\allowbreak events\_\allowbreak type (type) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{auditable\allowbreak \_abstract\allowbreak \_entity}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Superclase base y arquetipo técnico JPA (@MappedSuperclass) heredado por las entidades del backend de SaaS Billing \& Subscriptions. Provee identificador universal primario id, marcas temporales de auditoría inmutable created\_at y updated\_at, control de concurrencia optimista version y soporte de borrado lógico transversal mediante deleted\_at. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ)}, \texttt{version (BIGINT)}, \texttt{deleted\_at (TIMESTAMPTZ)}. \\*
\hline
\textbf{Constraints e Índices} & - PK técnica: pk\_entity (id) \newline - Bloqueo optimista: columna version administrada por Hibernate JPA (@Version) \newline - Filtro de exclusión: deleted\_at IS NULL para soporte de borrado lógico transversal. Superclase @MappedSuperclass JPA \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{local\allowbreak \_subscription\allowbreak \_cache}} \\*
\hline
\textbf{Motor y Producto} & SQLite 3 (Mobile Workshop) \\*
\hline
\textbf{Propósito y Aislamiento} & Caché relacional local de solo lectura en el dispositivo móvil del técnico o asesor de patio. Almacena una copia sincronizada de la membresía del taller y sus cuotas operativas vigentes respecto al número máximo de sucursales, mecánicos activos permitidos, dispositivos OBD-II, fotos por orden de trabajo, órdenes de trabajo mensuales autorizadas, registro de flotas y habilitación de telemetría IoT o diagnóstico predictivo. Permite la evaluación inmediata en frío de capacidades en fosos y bahías sin depender de conectividad telemática. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (TEXT PK)}, \texttt{tenant\_id (TEXT UK)}, \texttt{plan\_name (TEXT)}, \texttt{plan\_tier (TEXT)}, \texttt{subscription\_status (TEXT)}, \texttt{max\_branches (INTEGER)}, \texttt{max\_active\_staff (INTEGER)}, \texttt{max\_active\_obd2\_devices (INTEGER)}, \texttt{max\_photos\_per\_work\_order (INTEGER)}, \texttt{max\_monthly\_work\_orders (INTEGER)}, \texttt{company\_registration\_allowed (INTEGER)}, \texttt{iot\_telemetry\_enabled (INTEGER)}, \texttt{ai\_diagnostics\_enabled (INTEGER)}, \texttt{current\_period\_end (TEXT)}, \texttt{synced\_at (TEXT)}. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_\allowbreak local\_\allowbreak subscription\_\allowbreak cache (id) \newline - UK: uk\_\allowbreak local\_\allowbreak subscription\_\allowbreak tenant (tenant\_id) \newline - Índices B-Tree: idx\_\allowbreak local\_\allowbreak subscription\_\allowbreak status (subscription\_status), idx\_\allowbreak local\_\allowbreak subscription\_\allowbreak tenant (tenant\_id) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{local\allowbreak \_plan\allowbreak \_features\allowbreak \_cache}} \\*
\hline
\textbf{Motor y Producto} & SQLite 3 (Mobile Workshop) \\*
\hline
\textbf{Propósito y Aislamiento} & Réplica local de banderas y permisos modulares habilitados para el taller automotriz en su aplicación móvil. Faculta la activación o bloqueo reactivo de componentes de la interfaz de usuario en el cliente técnico de patio de forma determinista y sin latencia, manteniendo una réplica sincronizada incrementalmente con el backend central. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{feature\_id (TEXT PK)}, \texttt{tenant\_id (TEXT)}, \texttt{feature\_key (TEXT)}, \texttt{is\_enabled (INTEGER)}, \texttt{synced\_at (TEXT)}. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_\allowbreak local\_\allowbreak plan\_\allowbreak features\_\allowbreak cache (feature\_id) \newline - UK: uk\_\allowbreak local\_\allowbreak features\_\allowbreak tenant\_\allowbreak key (tenant\_id, feature\_key) \newline - Índices B-Tree: idx\_\allowbreak local\_\allowbreak features\_\allowbreak lookup (tenant\_id, feature\_key, is\_enabled) \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Elaboración propia en base al diseño relacional y la especificación física de persistencia.

A partir de la estructura formalizada en la @fig:database-diagram-billing y la @tbl:billing-database-tables-schema, se identifican tres fundamentos de ingeniería de software que respaldan la solidez, seguridad y resiliencia de la persistencia:

- **Aislamiento Multi-Inquilino y Gobernanza de Planes Comerciales en PostgreSQL 16:**
  El particionamiento lógico de los datos de suscripción se salvaguarda a través de la restricción foránea única en la columna **tenant_id** de la tabla **subscriptions**, garantizando que cada taller cuente exactamente con una única membresía operativa asociada. Dicha segregación se complementa con el arquetipo técnico **auditable_abstract_entity**, el cual inyecta mecanismos universales de control de concurrencia optimista mediante marcas de versión y borrado lógico, previniendo sobreescrituras accidentales entre administradores concurrentes.

- **Criptografía, Resiliencia e Idempotencia Estricta en la Ingestión de Webhooks:**
  La persistencia física en la tabla **stripe_webhook_events** constituye una barrera transaccional que neutraliza las contingencias de red inherentes a los pagos electrónicos en la nube. Al sincronizar las transiciones de estado de cobro en **saas_invoices** y renovaciones de ciclo en **subscriptions** dentro de la misma frontera transaccional ACID donde se inserta el evento de Stripe, se asegura que anomalías en las comunicaciones HTTP nunca originen cobros duplicados o desincronizaciones contractuales.

- **Evaluación de Cuotas Operativas en Frío y Sincronización Reactiva hacia Clientes Móviles:**
  La inclusión de las tablas de caché en SQLite 3 responde al requisito operacional de movilidad en talleres automotrices, donde la recepción de vehículos y asignación de órdenes de trabajo puede ejecutarse en sótanos o zonas sin cobertura inalámbrica. Mediante un protocolo de refresco incremental basado en marcas temporales y cabeceras de validación condicional ETag, la aplicación móvil actualiza sus techos de capacidad sin generar sobrecarga en el backend central, garantizando fluidez en la atención al cliente.
### 2.6.9. *Bounded Context: IoT Telemetry & Predictive Maintenance*

El Bounded Context de IoT Telemetry & Predictive Maintenance constituye la pieza central de innovación tecnológica y la ventaja competitiva más relevante de Atelier Platform en el mercado automotriz. Su propósito es convertir al taller mecánico tradicional en un centro de servicio inteligente, conectado y proactivo, capaz de anticipar fallas mecánicas catastróficas en los automóviles antes de que se manifiesten en daños irreparables o accidentes viales.

En los talleres mecánicos convencionales, el mantenimiento es preponderantemente reactivo: el cliente acude cuando el automóvil ya presenta ruidos anormales, pérdida de potencia, recalentamiento de motor o remolcado en grúa. Este modelo provoca costos de reparación exorbitantes para el conductor y picos de trabajo impredecibles e ineficientes para el taller. Por su parte, los escáneres automotrices tradicionales se utilizan de forma manual y aislada en foso, perdiéndose la telemetría en tiempo real una vez que el vehículo abandona el establecimiento.

Para transformar este paradigma, el contexto modela la ingesta masiva de parámetros de diagnóstico vehicular a través del puerto OBD-II (*On-Board Diagnostics II*), estandarizado bajo normas internacionales SAE J1962 / ISO 15031. Mediante dispositivos de hardware conectados físicamente al puerto del automóvil (módems celulares con tarjeta SIM o escáneres Bluetooth BLE que se comunican a través del smartphone del conductor), Atelier recolecta de forma continua los flujos de identificación de parámetros (PIDs): revoluciones por minuto del motor (RPM), velocidad del vehículo, temperatura del refrigerante, nivel de combustible y tensión eléctrica de la batería.

Debido al volumen masivo de datos generados, con cientos de lecturas por minuto por cada vehículo activo, almacenar estos registros en una base de datos relacional transaccional convencional degradaría el rendimiento del ERP. Por esta razón, el dominio aísla la serie temporal en la hipertabla especializada `telemetry_logs` gestionada por TimescaleDB en Aiven Cloud. Esta tabla opera bajo una semántica de solo inserción (*Append-Only*), prescindiendo de borrados lógicos y restricciones foráneas pesadas en tiempo de ejecución, y aplicando políticas automáticas de compresión columnar para reducir la huella en disco en más de un 90%.

Sobre esta telemetría continua, el motor de inferencia `PredictiveAnomalyDetectionEngine` evalúa correlaciones matemáticas en tiempo real. Cuando los parámetros exceden umbrales térmicos o eléctricos seguros, o cuando la computadora del auto (ECU/PCM) emite códigos de avería de diagnóstico (DTC - *Diagnostic Trouble Codes* bajo el estándar SAE J2012), el sistema formula una `PredictiveAlert` con un puntaje de confianza algorítmica (`confidence_score`). De manera inmediata, esta alerta vincula un servicio preventivo del catálogo de MRO y se despacha como notificación push de alta prioridad mediante Firebase Cloud Messaging (FCM) al conductor en `Atelier Driver` y al asesor del taller en `Atelier Workshop`, permitiendo una intervención correctiva oportuna.

#### 2.6.9.1. Domain Layer

La capa de dominio de IoT Telemetry \& Predictive Maintenance concentra los modelos ontológicos, agregados de series temporales, reglas de inferencia analítica y contratos asíncronos que permiten transformar los datos brutos del computador de a bordo en servicios preventivos de taller. Todos sus tipos residen bajo el paquete raíz **com.andeva.atelier.platform.iot.domain** y se articulan sobre cuatro fundamentos tácticos de ingeniería:

- **Ingesta masiva append-only y particionamiento temporal:** Desacoplamiento de lecturas sensoriales de alta frecuencia hacia hipertablas optimizadas en TimescaleDB, suprimiendo bloqueos de contención y sobrecarga transaccional sobre la base de datos relacional del ERP.
- **Topología híbrida de conectividad de hardware y gateways móviles:** Admisión coordinada de escáneres con módem celular directo y enlaces Bluetooth de baja energía asistidos por dispositivos móviles, asegurando almacenamiento intermedio en Room SQLite ante pérdidas de cobertura.
- **Motor determinista de mantenimiento predictivo y termodinámica:** Detección algorítmica de anomalías críticas sustentada en leyes físicas de combustión, gradientes térmicos de refrigerante y curvas de descarga de batería para anticipar averías catastróficas.
- **Notificación push multicanal instantánea de alta prioridad:** Despacho automatizado de alertas preventivas en tiempo real hacia las aplicaciones móviles del conductor y del asesor de servicio mediante la pasarela de Google Firebase Cloud Messaging.

En la @tbl:iot-domain-types se presenta la clasificación formal de los componentes que integran el núcleo del dominio telemático, detallando sus categorías tácticas, relaciones cardinales y paquetes canónicos.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo de la Capa de Dominio de IoT Telemetry \& Predictive Maintenance} \label{tbl:iot-domain-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\
\hline
\endhead
Obd2Device & Modela el hardware físico de escaneo a bordo custodiando su identificación unívoca y canal de transmisión. \\*
\hline
\textbf{Categoría} & Raíz de Agregado \\*
\hline
\textbf{Relaciones} & Generalización de AbstractDomainAggregateRoot<Obd2Device>. Vinculado al taller titular TenantId y referenciado en DeviceInstallation. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
DeviceInstallation & Gobierna la sesión física temporal de acople de un escáner en el puerto de diagnóstico del vehículo. \\*
\hline
\textbf{Categoría} & Raíz de Agregado \\*
\hline
\textbf{Relaciones} & Generalización de AbstractDomainAggregateRoot<DeviceInstallation>. Mantiene referencias foráneas por identidad con DeviceId, VehicleId y TenantId. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
VehicleFault & Modela un código de avería electrónica diagnosticado por la computadora de a bordo del automóvil. \\*
\hline
\textbf{Categoría} & Raíz de Agregado \\*
\hline
\textbf{Relaciones} & Generalización de AbstractDomainAggregateRoot<VehicleFault>. Asociado a VehicleId y TenantId con clasificación estandarizada mediante DtcCode. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PredictiveAlert & Advertencia de mantenimiento proactivo formulada algorítmicamente ante riesgo inminente de fallo mecánico. \\*
\hline
\textbf{Categoría} & Raíz de Agregado \\*
\hline
\textbf{Relaciones} & Generalización de AbstractDomainAggregateRoot<PredictiveAlert>. Vinculada a VehicleId, TenantId y opcionalmente a un servicio preventivo de MRO. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
TelemetryRecord & Registro inmutable de parámetros de sensores vehiculares persistido en la hipertabla de TimescaleDB. \\*
\hline
\textbf{Categoría} & Agregado de Serie Temporal \\*
\hline
\textbf{Relaciones} & Clave compuesta por marca temporal y VehicleId con desnormalización de TenantId. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
DtcCatalogEntry & Registro maestro del catálogo internacional de códigos de avería automotriz SAE J2012 e ISO 15031. \\*
\hline
\textbf{Categoría} & Entidad Dependiente \\*
\hline
\textbf{Relaciones} & Identificado por DtcCatalogId y utilizado por los servicios de dominio para clasificación taxonómica de fallas. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
DeviceId & Identificador único universal fuertemente tipado para el hardware de escaneo a bordo OBD-II. \\*
\hline
\textbf{Categoría} & Identificador Fuertemente Tipado \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak ids} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
InstallationId & Identificador único universal fuertemente tipado para la sesión física de vinculación telemática. \\*
\hline
\textbf{Categoría} & Identificador Fuertemente Tipado \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak ids} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
FaultId & Identificador único universal fuertemente tipado para el reporte de avería diagnosticada en el vehículo. \\*
\hline
\textbf{Categoría} & Identificador Fuertemente Tipado \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak ids} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
AlertId & Identificador único universal fuertemente tipado para la advertencia predictiva formulada por el sistema. \\*
\hline
\textbf{Categoría} & Identificador Fuertemente Tipado \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak ids} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
DtcCatalogId & Identificador único universal fuertemente tipado para la entrada normativa del catálogo de códigos de avería. \\*
\hline
\textbf{Categoría} & Identificador Fuertemente Tipado \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak ids} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
ConnectionType & Canales físicos y lógicos de transmisión telemática vehicular soportados por los dispositivos de hardware. \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Valores BLUETOOTH\_BLE, SIM\_CELLULAR y WIFI asociados a Obd2Device. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak enums} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
DeviceStatus & Situación operativa y administrativa del hardware que condiciona la admisión de tramas sensoriales. \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Valores ACTIVE, INACTIVE, LOST y BROKEN gobernados por Obd2Device. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak enums} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
FaultSeverity & Nivel de criticidad técnica asignado al código de avería detectado por la computadora del vehículo. \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Valores LOW, MEDIUM y CRITICAL clasificados en VehicleFault y DtcCatalogEntry. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak enums} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
AlertSeverity & Nivel de urgencia o gravedad de la advertencia predictiva para la priorización en el taller y conductor. \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Valores LOW, MEDIUM, HIGH y CRITICAL vinculados a la notificación preventiva. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak enums} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
AlertStatus & Estados formales del ciclo de vida y atención de la advertencia predictiva en la plataforma. \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Valores DISPATCHED, ACKNOWLEDGED, RESOLVED y DISMISSED gestionados por PredictiveAlert. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak enums} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
RiskLevel & Nivel de riesgo integral estimado por los modelos analíticos de mantenimiento preventivo y peritaje. \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Valores LOW, MODERATE, HIGH y CRITICAL utilizados en evaluaciones de salud mecánica. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak enums} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
DeviceIdentifier & Objeto de valor inmutable que valida el identificador de hardware mediante dirección MAC o código celular IMEI. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Valida formato de seis pares hexadecimales o quince dígitos numéricos bajo restricción de unicidad. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
DtcCode & Objeto de valor inmutable para códigos de diagnóstico normalizados bajo SAE J2012 e ISO 15031-6. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Valida sintaxis con letra inicial P, C, B o U seguida de cuatro caracteres numéricos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
ConfidenceScore & Expresa la certeza probabilística calculada por el motor predictivo para una avería vehicular inminente. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Registro inmutable con escala porcentual decimal validada entre 0.00 y 100.00. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
EngineTemperature & Magnitud térmica del refrigerante de motor en grados Celsius con validación termodinámica. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Provee lógica de dominio isCriticalOverheating() para valores superiores a 105.0°C. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
EngineRpm & Régimen de rotación del cigüeñal en revoluciones por minuto con validación de límites físicos de motor. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Provee lógica de dominio isExcessiveRpm() para valores superiores a 6000 RPM. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
VehicleSpeed & Velocidad lineal instantánea del automóvil reportada por la unidad de control electrónico en km/h. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Valida rango físico no negativo acotado estrictamente entre 0 y 350 km/h. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
BatteryVoltage & Tensión eléctrica en voltios registrada en los terminales de batería o alternador del vehículo. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Provee lógica de dominio isLowBattery() para mediciones inferiores a 11.80V en reposo. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
FuelLevel & Porcentaje de combustible remanente en el depósito vehicular reportado por el aforador electrónico. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Valida magnitud física en escala porcentual acotada estrictamente entre 0.0 y 100.0. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
GeoCoordinates & Posicionamiento satelital GPS compuesto por coordenadas geodésicas decimales de latitud y longitud. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Valida límites geográficos con latitud en [-90.0, 90.0] y longitud en [-180.0, 180.0]. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
TelemetryPids & Mapeo inmutable de parámetros OBD-II normalizados (PIDs) leídos e interpretados desde la trama vehicular. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Encapsula lecturas paramétricas complementarias de sensores automotrices sin acoplar esquemas fijos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
ActiveInstallation\allowbreak ConflictException & Señala conflicto al intentar instalar un escáner en un vehículo que ya posee una sesión activa en paralelo. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de IoTDomainException asociada al código ERR\_ACTIVE\_INSTALLATION\_CONFLICT y HTTP 409 Conflict. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
DeviceAlready\allowbreak InstalledException & Señala que el escáner seleccionado ya mantiene una sesión de montaje activa en otra unidad sin concluir. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de IoTDomainException asociada al código ERR\_DEVICE\_ALREADY\_INSTALLED y HTTP 409 Conflict. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
DeviceNotFound\allowbreak Exception & Señala que no se localiza el escáner telemático mediante el identificador UUID o dirección física suministrada. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de IoTDomainException asociada al código ERR\_DEVICE\_NOT\_FOUND y HTTP 404 Not Found. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
InstallationNotFound\allowbreak Exception & Señala que la sesión de montaje telemático consultada no existe en el registro del taller automotriz. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de IoTDomainException asociada al código ERR\_INSTALLATION\_NOT\_FOUND y HTTP 404 Not Found. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
InvalidDevice\allowbreak IdentifierException & Señala que la dirección física no cumple el formato estricto de MAC Address ni de código celular IMEI. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de IoTDomainException asociada al código ERR\_INVALID\_DEVICE\_IDENTIFIER y HTTP 422 Unprocessable Entity. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
InvalidDtc\allowbreak CodeException & Señala que la trama del código de avería recibido incumple la nomenclatura reglamentaria SAE J2012. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de IoTDomainException asociada al código ERR\_INVALID\_DTC\_CODE y HTTP 422 Unprocessable Entity. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
IoTDomain\allowbreak Exception & Superclase abstracta no comprobada de la que derivan todas las contingencias semánticas del contexto telemático. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Generalización de RuntimeException con código legible normalizado bajo norma RFC 7807. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PredictiveAlert\allowbreak NotFoundException & Señala que no se localiza la alerta predictiva consultada para su confirmación o resolución en taller. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de IoTDomainException asociada al código ERR\_PREDICTIVE\_ALERT\_NOT\_FOUND y HTTP 404 Not Found. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
TimescaleIngestion\allowbreak Exception & Señala lecturas fuera del dominio físico plausible o fallos irrecuperables en la ingesta por lotes en TimescaleDB. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de IoTDomainException asociada al código ERR\_TIMESCALE\_INGESTION\_FAILED y HTTP 422 Unprocessable Entity. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
VehicleFault\allowbreak NotFoundException & Señala que no se localiza el registro del código de avería consultado para su seguimiento o resolución en taller. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de IoTDomainException asociada al código ERR\_VEHICLE\_FAULT\_NOT\_FOUND y HTTP 404 Not Found. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
DeviceInstallation\allowbreak Repository & Contrato de persistencia para auditar las sesiones de montaje físico y vigencia temporal de escáneres. \\*
\hline
\textbf{Categoría} & Puerto de Repositorio \\*
\hline
\textbf{Relaciones} & Implementado por adaptadores de persistencia relacional en la Capa de Infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
DtcCatalog\allowbreak Repository & Contrato de persistencia para consultas sobre el catálogo maestro internacional de fallas SAE J2012 e ISO 15031. \\*
\hline
\textbf{Categoría} & Puerto de Repositorio \\*
\hline
\textbf{Relaciones} & Implementado por adaptadores de persistencia relacional en la Capa de Infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Obd2Device\allowbreak Repository & Contrato de persistencia para el inventario de hardware telemático y validación de unicidad de identificadores. \\*
\hline
\textbf{Categoría} & Puerto de Repositorio \\*
\hline
\textbf{Relaciones} & Implementado por adaptadores de persistencia relacional en la Capa de Infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PredictiveAlert\allowbreak Repository & Contrato de persistencia para la gestión del ciclo de vida y despacho de advertencias predictivas. \\*
\hline
\textbf{Categoría} & Puerto de Repositorio \\*
\hline
\textbf{Relaciones} & Implementado por adaptadores de persistencia relacional en la Capa de Infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
TelemetryRecord\allowbreak Repository & Contrato de persistencia para inserción masiva JDBC en hipertablas y agregaciones temporales en TimescaleDB. \\*
\hline
\textbf{Categoría} & Puerto de Repositorio \\*
\hline
\textbf{Relaciones} & Implementado por adaptadores optimizados para series temporales en la Capa de Infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
VehicleFault\allowbreak Repository & Contrato de persistencia para el historial de códigos de avería electrónica y control de resolución mecánica. \\*
\hline
\textbf{Categoría} & Puerto de Repositorio \\*
\hline
\textbf{Relaciones} & Implementado por adaptadores de persistencia relacional en la Capa de Infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PredictiveAnomaly\allowbreak DetectionEngine & Motor analítico de inferencia en tiempo real que evalúa telemetría sensorial recién arribada para formular advertencias. \\*
\hline
\textbf{Categoría} & Servicio de Dominio \\*
\hline
\textbf{Relaciones} & Invocado durante la ingesta de telemetría para evaluar desviaciones térmicas y eléctricas según heurísticas de combustión. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
DtcCodeEvaluation\allowbreak Service & Servicio de enriquecimiento taxonómico de códigos de diagnóstico conforme a SAE J2012 e ISO 15031. \\*
\hline
\textbf{Categoría} & Servicio de Dominio \\*
\hline
\textbf{Relaciones} & Invocado al detectar códigos de falla para asignar severidad predeterminada y sugerir servicios de MRO. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
VehicleThermodynamic\allowbreak EvaluationService & Evalúa los gradientes térmicos y dinámicas de disipación de calor del motor analizando revoluciones, velocidad y temperatura. \\*
\hline
\textbf{Categoría} & Servicio de Dominio \\*
\hline
\textbf{Relaciones} & Modela correlaciones dinámicas de termodinámica interna para anticipar fallas incipientes de refrigeración. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
CriticalEngine\allowbreak AnomalyDetected\allowbreak Event & Emitido por el motor de inferencia cuando los sensores rebasan umbrales termodinámicos de peligro inminente. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Propagado de forma reactiva para formular alertas predictivas y despachar notificaciones push de alta prioridad. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
DeviceInstalled\allowbreak OnVehicleEvent & Emitido al acoplar físicamente un escáner en el puerto OBD-II del vehículo iniciando el monitoreo continuo. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Notifica el inicio de sesión física para habilitar la ingesta telemática de la unidad. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
DeviceUninstalled\allowbreak FromVehicleEvent & Emitido al desconectar el hardware telemático en foso asentando el odómetro final de la sesión. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Notifica el cierre de monitoreo y sincroniza el odómetro final con el expediente vehicular en CRM. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Obd2Device\allowbreak RegisteredEvent & Emitido al catalogar y registrar un nuevo hardware telemático en el inventario del taller automotriz. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Registra la incorporación del escáner con identificación unívoca por dirección MAC o IMEI. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PredictiveAlert\allowbreak AcknowledgedEvent & Emitido cuando el conductor o el asesor de servicio confirma la lectura de la alerta predictiva. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Asienta la confirmación de recepción en el ciclo de vida de la advertencia. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PredictiveAlert\allowbreak DispatchedEvent & Emitido al despachar la notificación push a las aplicaciones móviles mediante Firebase Cloud Messaging. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Registra el identificador de mensaje FCM para auditoría de entrega perimetral. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PredictiveAlert\allowbreak GeneratedEvent & Emitido al formularse algorítmicamente una nueva advertencia predictiva en el núcleo de dominio. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Dispara la orquestación de despacho de notificaciones y la vinculación con servicios de MRO. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
TelemetryBatch\allowbreak IngestedEvent & Emitido tras insertar exitosamente una ráfaga masiva de lecturas temporales en la hipertabla de TimescaleDB. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Habilita el cálculo reactivo de resúmenes estadísticos y la actualización de instrumental en tiempo real. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
VehicleFault\allowbreak DetectedEvent & Emitido al registrarse un código de avería DTC activo proveniente de la computadora de a bordo. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Inicia el expediente patológico de la falla y evalúa la necesidad de intervención técnica en taller. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
VehicleFault\allowbreak ResolvedEvent & Emitido al certificar la reparación mecánica en foso de un código de avería previamente diagnosticado. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Cierra el estado de la avería en el historial técnico del vehículo automotriz. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak domain.\allowbreak model.\allowbreak events} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Catálogo taxonómico de los tipos tácticos fundamentales del paquete com.andeva.atelier.platform.iot.domain.

**Raíces de Agregado y Entidades Dependientes de IoT Telemetry**

El núcleo transaccional del dominio organiza sus fronteras de consistencia en cinco agregados y una entidad dependiente especializada:

- **Obd2Device:** Raíz de agregado que custodia el inventario físico de hardware de diagnóstico adquirido por el taller o provisto por la plataforma. Administra su identificación unívoca por dirección MAC o número IMEI bajo restricción de unicidad global, su tecnología de enlace y su situación operativa. Asegura que ningún escáner extraviado o averiado admita la recepción de tramas telemáticas.

En la @tbl:iot-device-members se especifican los atributos estructurales, métodos de mutación protegida y reglas de invariante de la raíz de agregado **Obd2Device**.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de la Raíz de Agregado Obd2Device} \label{tbl:iot-device-members} \\
\hline
\thfirst{Elemento o Atributo} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento o Atributo} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
id & Identificador universal único e inmutable del hardware telemático. \\*
\hline
\textbf{Firma o Tipo} & \texttt{DeviceId} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
tenantId & Identificador del taller automotriz propietario o custodio del dispositivo. \\*
\hline
\textbf{Firma o Tipo} & \texttt{TenantId} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
deviceIdentifier & Dirección física MAC Bluetooth o código IMEI celular validado bajo restricción única global. \\*
\hline
\textbf{Firma o Tipo} & \texttt{DeviceIdentifier} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
connectionType & Canal físico de transmisión de datos configurado en el equipo. \\*
\hline
\textbf{Firma o Tipo} & \texttt{ConnectionType (BLUETOOTH\_BLE, SIM\_CELLULAR, WIFI)} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
status & Situación operativa del dispositivo que condiciona la admisión de tramas de telemetría. \\*
\hline
\textbf{Firma o Tipo} & \texttt{DeviceStatus (ACTIVE, INACTIVE, LOST, BROKEN)} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
hardwareModel & Denominación técnica y fabricante del modelo comercial homologado. \\*
\hline
\textbf{Firma o Tipo} & \texttt{String} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
firmwareVersion & Versión de software embebido instalado en el microcontrolador del escáner. \\*
\hline
\textbf{Firma o Tipo} & \texttt{String} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Método u Operación} & \thcell{Comportamiento y Reglas de Dominio} \\*
\hline
register & Factoría de dominio que valida la sintaxis del identificador e inicializa el equipo en estado activo. \\*
\hline
\textbf{Firma o Tipo} & \texttt{static Obd2Device register(TenantId tId, DeviceIdentifier devId, ConnectionType conn, String model, String fw)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
markLost & Inhabilita el escáner por extravío y bloquea la ingesta de telemetría proveniente de este identificador. \\*
\hline
\textbf{Firma o Tipo} & \texttt{void markLost()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
markBroken & Registra inoperatividad irreversible por daño físico en patio o manipulación indebida. \\*
\hline
\textbf{Firma o Tipo} & \texttt{void markBroken()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
updateFirmware & Actualiza la versión de software embebido tras procedimientos de mantenimiento técnico. \\*
\hline
\textbf{Firma o Tipo} & \texttt{void updateFirmware(String newVersion)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de miembros de la clase Obd2Device del paquete com.andeva.atelier.platform.iot.domain.model.aggregates.

- **DeviceInstallation:** Raíz de agregado que gobierna la sesión física de monitoreo y vinculación operativa entre un escáner telemático y un vehículo automotriz. Controla los sellos cronológicos de conexión y desconexión, y registra el odómetro inicial y final en kilómetros. Impone como regla de negocio que un escáner solo puede estar instalado en un vehículo a la vez y que ningún vehículo puede mantener múltiples sesiones activas simultáneamente.

En la @tbl:iot-installation-members se detallan los miembros, métodos y restricciones de consistencia temporal de la raíz de agregado **DeviceInstallation**.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de la Raíz de Agregado DeviceInstallation} \label{tbl:iot-installation-members} \\
\hline
\thfirst{Elemento o Atributo} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento o Atributo} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
id & Identificador universal único de la sesión de montaje telemático. \\*
\hline
\textbf{Firma o Tipo} & \texttt{InstallationId} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
deviceId & Referencia al hardware físico OBD-II instalado en el puerto de diagnóstico. \\*
\hline
\textbf{Firma o Tipo} & \texttt{DeviceId} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
vehicleId & Vehículo automotriz intervenido y objeto del monitoreo preventivo. \\*
\hline
\textbf{Firma o Tipo} & \texttt{VehicleId} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
tenantId & Taller automotriz prestador y responsable del servicio de telemetría. \\*
\hline
\textbf{Firma o Tipo} & \texttt{TenantId} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
installedAt & Marca de tiempo UTC en que se efectúa el acople físico e inicia la transmisión. \\*
\hline
\textbf{Firma o Tipo} & \texttt{Instant} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
uninstalledAt & Marca de tiempo UTC de desconexión física y cierre formal de la sesión de monitoreo. \\*
\hline
\textbf{Firma o Tipo} & \texttt{Optional<Instant>} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
initialOdometerKm & Kilometraje registrado en el odómetro al momento de la instalación con valor mayor o igual a cero. \\*
\hline
\textbf{Firma o Tipo} & \texttt{int} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
finalOdometerKm & Kilometraje verificado al retirar el escáner con valor mayor o igual al kilometraje inicial. \\*
\hline
\textbf{Firma o Tipo} & \texttt{Optional<Integer>} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Método u Operación} & \thcell{Comportamiento y Reglas de Dominio} \\*
\hline
install & Factoría de dominio que vincula el escáner al vehículo y emite DeviceInstalledOnVehicleEvent. \\*
\hline
\textbf{Firma o Tipo} & \texttt{static DeviceInstallation install(DeviceId devId, VehicleId vehId, TenantId tenId, int initialKm)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
uninstall & Concluye la sesión de monitoreo validando el odómetro final y emite DeviceUninstalledFromVehicleEvent. \\*
\hline
\textbf{Firma o Tipo} & \texttt{void uninstall(int finalKm, Instant at)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
isActive & Evalúa si la sesión continúa transmitiendo activamente comprobando la ausencia de fecha de retiro. \\*
\hline
\textbf{Firma o Tipo} & \texttt{boolean isActive()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de miembros de la clase DeviceInstallation del paquete com.andeva.atelier.platform.iot.domain.model.aggregates.

- **TelemetryRecord:** Agregado inmutable de serie temporal que modela una lectura instantánea capturada por los sensores vehiculares y almacenada en la hipertabla de TimescaleDB. Contiene magnitudes cinemáticas y termodinámicas de la unidad automotriz, incluyendo velocidad, régimen de revoluciones, temperatura de refrigerante, tensión eléctrica y nivel de combustible. Su diseño de solo inserción garantiza inmutabilidad absoluta y máxima velocidad de procesamiento analítico.

En la @tbl:iot-telemetry-record-members se desglosan los atributos cinemáticos y sensoriales que estructuran el agregado inmutable **TelemetryRecord**.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros del Agregado de Serie Temporal TelemetryRecord} \label{tbl:iot-telemetry-record-members} \\
\hline
\thfirst{Elemento o Atributo} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento o Atributo} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
timestamp & Marca de tiempo UTC de captura sensorial que actúa como clave de partición en TimescaleDB. \\*
\hline
\textbf{Firma o Tipo} & \texttt{Instant} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
vehicleId & Vehículo emisor que conforma la clave primaria compuesta relacional de la hipertabla. \\*
\hline
\textbf{Firma o Tipo} & \texttt{VehicleId} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
tenantId & Taller automotriz desnormalizado para acelerar agregaciones analíticas multi-inquilino. \\*
\hline
\textbf{Firma o Tipo} & \texttt{TenantId} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
location & Coordenadas geodésicas GPS emitidas por el gateway móvil o módem celular con enlace satelital. \\*
\hline
\textbf{Firma o Tipo} & \texttt{Optional<GeoCoordinates>} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
speed & Velocidad instantánea en kilómetros por hora leída desde la unidad de control del motor. \\*
\hline
\textbf{Firma o Tipo} & \texttt{VehicleSpeed} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
engineTemperature & Temperatura del refrigerante de motor en grados Celsius restringida a rangos termodinámicos plausibles. \\*
\hline
\textbf{Firma o Tipo} & \texttt{EngineTemperature} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
engineRpm & Revoluciones por minuto del cigüeñal con validación física entre cero y doce mil revoluciones. \\*
\hline
\textbf{Firma o Tipo} & \texttt{EngineRpm} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
fuelLevel & Porcentaje de combustible remanente en el tanque con escala porcentual de cero a cien. \\*
\hline
\textbf{Firma o Tipo} & \texttt{Optional<FuelLevel>} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
batteryVoltage & Tensión eléctrica del sistema de carga en voltios leída en terminales de batería o alternador. \\*
\hline
\textbf{Firma o Tipo} & \texttt{Optional<BatteryVoltage>} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
telemetryPids & Mapeo inmutable de parámetros OBD-II normalizados leídos e interpretados desde la trama vehicular. \\*
\hline
\textbf{Firma o Tipo} & \texttt{Optional<TelemetryPids>} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\thfirst{Método u Operación} & \thcell{Comportamiento y Reglas de Dominio} \\*
\hline
of & Factoría inmutable que valida rangos físicos antes de admitir la inserción masiva en hipertablas. \\*
\hline
\textbf{Firma o Tipo} & \texttt{static TelemetryRecord of(Instant ts, VehicleId vId, TenantId tId, Optional<GeoCoordinates> loc, VehicleSpeed spd, EngineTemperature temp, EngineRpm rpm, Optional<FuelLevel> fuel, Optional<BatteryVoltage> batt, Optional<TelemetryPids> pids)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de miembros de TelemetryRecord del paquete com.andeva.atelier.platform.iot.domain.model.aggregates.

- **VehicleFault:** Raíz de agregado que representa un código de diagnóstico de avería emitido por la computadora de a bordo y detectado por el escáner. Almacena el código alfanumérico estandarizado, el nivel de severidad asignado, la descripción del subsistema comprometido y el estado de reparación en foso. Preserva el expediente técnico y patológico del vehículo para su consulta en intervenciones futuras.

- **PredictiveAlert:** Raíz de agregado que materializa una advertencia preventiva de avería inminente generada por el motor analítico. Asocia la amenaza detectada con un servicio del catálogo maestro de operaciones de taller, calculando la certeza probabilística del fallo y gestionando el ciclo de vida de la alerta desde su despacho por notificación push hasta su resolución o descarte en el taller.

- **DtcCatalogEntry:** Entidad dependiente que representa el catálogo maestro internacional de códigos de avería automotriz regulado por las normas SAE J2012 e ISO 15031. Permite que el sistema traduzca códigos alfanuméricos en definiciones comprensibles y determine su severidad reglamentaria.

En la @tbl:iot-fault-alert-members se describen los miembros, métodos e invariantes que rigen el ciclo de vida de **VehicleFault**, **PredictiveAlert** y la entidad **DtcCatalogEntry**.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de VehicleFault, PredictiveAlert y DtcCatalogEntry} \label{tbl:iot-fault-alert-members} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Raíz de Agregado:} VehicleFault} \\*
\hline
\thfirst{Elemento o Método} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Raíz de Agregado:} VehicleFault (Continuación)} \\*
\hline
\thfirst{Elemento o Método} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
id & Identificador universal único del desperfecto electrónico vehicular (\texttt{FaultId}). \\*
\hline
vehicleId \textbar\ tenantId & Identificadores de la unidad automotriz afectada y del taller a cargo del diagnóstico. \\*
\hline
dtcCode \textbar\ severity & Código alfanumérico SAE J2012 y severidad asignada (\texttt{LOW}, \texttt{MEDIUM}, \texttt{CRITICAL}). \\*
\hline
description \textbar\ detectedAt & Glosa técnica descriptiva y marca temporal de captura sensorial por el escáner. \\*
\hline
isResolved \textbar\ resolvedAt & Bandera que certifica subsanación técnica y fecha de reparación mecánica en foso. \\*
\hline
detect & Factoría de dominio que asienta la avería y emite \texttt{VehicleFaultDetectedEvent}. \\*
\hline
markResolved & Conmuta el estado a subsanado tras la intervención mecánica en el taller emitiendo \texttt{VehicleFaultResolvedEvent}. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Raíz de Agregado:} PredictiveAlert} \\*
\hline
id & Identificador universal único de la advertencia preventiva formulada (\texttt{AlertId}). \\*
\hline
vehicleId \textbar\ tenantId & Identificadores del vehículo en riesgo inminente y del taller responsable de la atención. \\*
\hline
recommendedServiceId & Servicio preventivo sugerido del catálogo de MRO para solucionar la causa raíz. \\*
\hline
alertType \textbar\ confidenceScore & Tipo de riesgo mecánico y probabilidad porcentual estimada por el motor algorítmico. \\*
\hline
message \textbar\ status & Advertencia en lenguaje comprensible y estado (\texttt{DISPATCHED}, \texttt{ACKNOWLEDGED}, \texttt{RESOLVED}, \texttt{DISMISSED}). \\*
\hline
fcmMessageId & Identificador de entrega push retornado por Firebase Cloud Messaging. \\*
\hline
create & Factoría de dominio que inicializa la alerta emitiendo \texttt{PredictiveAlertGeneratedEvent} y \texttt{PredictiveAlertDispatchedEvent}. \\*
\hline
markDispatched \textbar\ acknowledge & Registra el identificador de despacho FCM y asienta la lectura por parte del conductor emitiendo \texttt{PredictiveAlertAcknowledgedEvent}. \\*
\hline
resolve \textbar\ dismiss & Cierra la alerta tras la reparación en taller o la descarta por decisión del usuario. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad Dependiente:} DtcCatalogEntry} \\*
\hline
id & Identificador universal inmutable de la entrada normativa del catálogo (\texttt{DtcCatalogId}). \\*
\hline
code \textbar\ category & Código SAE J2012 y categoría funcional (\texttt{POWERTRAIN\_P}, \texttt{CHASSIS\_C}, \texttt{BODY\_B}, \texttt{NETWORK\_U}). \\*
\hline
standardDescription & Glosa canónica oficial estandarizada que define la anomalía técnica detectada. \\*
\hline
defaultSeverity & Gravedad predeterminada por la taxonomía internacional para enriquecer alertas. \\*
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de componentes de diagnóstico y mantenimiento predictivo en com.andeva.atelier.platform.iot.domain.

**Objetos de Valor y Enumeraciones de IoT Telemetry**

La consistencia y tipado estricto del dominio se garantizan mediante objetos de valor inmutables implementados como registros de Java. Cada registro encapsula validaciones sintácticas en su constructor compacto para erradicar el antipatrón de obsesión por tipos primitivos, asegurando que magnitudes físicas como temperatura, velocidad, revoluciones o coordenadas geodésicas se mantengan dentro de rangos mecánicamente admisibles.

En la @tbl:iot-value-objects se detallan los objetos de valor inmutables y los tipos enumerados que salvaguardan la integridad de los datos telemáticos.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Identificadores Tipados, Objetos de Valor y Enumeraciones de IoT Telemetry \& Predictive Maintenance} \label{tbl:iot-value-objects} \\
\hline
\thfirst{Componente Inmutable} & \thcell{Definición de Atributos y Reglas de Validación} \\
\hline
\endfirsthead
\hline
\thfirst{Componente Inmutable} & \thcell{Definición de Atributos y Reglas de Validación} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Identificador Tipado:} DeviceId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal del hardware telemático OBD-II. Inmutable y no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Identificador Tipado:} InstallationId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal de la sesión física de vinculación y monitoreo vehicular. Inmutable y no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Identificador Tipado:} FaultId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal del reporte de código de avería electrónica diagnosticada. Inmutable y no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Identificador Tipado:} AlertId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal de la advertencia preventiva o predictiva formulada. Inmutable y no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Identificador Tipado:} DtcCatalogId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal de la entrada normativa en el catálogo maestro internacional de fallas. Inmutable y no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} DeviceIdentifier} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: String} \\*
\hline
\textbf{Restricciones y Reglas} & Valida dirección física MAC de seis pares hexadecimales o código de módem celular IMEI de quince dígitos numéricos bajo restricción de unicidad global. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} DtcCode} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: String} \\*
\hline
\textbf{Restricciones y Reglas} & Valida formato alfanumérico estandarizado SAE J2012 e ISO 15031-6 con prefijo P, C, B o U seguido de cuatro dígitos numéricos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} ConfidenceScore} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: BigDecimal} \\*
\hline
\textbf{Restricciones y Reglas} & Probabilidad matemática de fallo inminente estimada por el motor algorítmico, acotada en escala porcentual de 0.00 a 100.00. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} EngineTemperature} \\*
\hline
\textbf{Atributos Clave} & \texttt{celsius: double} \\*
\hline
\textbf{Restricciones y Reglas} & Temperatura del refrigerante de motor en grados Celsius acotada a rangos termodinámicos plausibles. Provee método \textit{isCriticalOverheating()} para magnitudes superiores a 105.0°C. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} EngineRpm} \\*
\hline
\textbf{Atributos Clave} & \texttt{rpm: int} \\*
\hline
\textbf{Restricciones y Reglas} & Régimen de giro del cigüeñal en revoluciones por minuto acotado entre cero y doce mil. Provee método \textit{isExcessiveRpm()} para valores mayores a 6000 RPM. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} VehicleSpeed} \\*
\hline
\textbf{Atributos Clave} & \texttt{kmh: int} \\*
\hline
\textbf{Restricciones y Reglas} & Velocidad lineal instantánea reportada por la computadora del vehículo, acotada en un rango no negativo de 0 a 350 km/h. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} BatteryVoltage} \\*
\hline
\textbf{Atributos Clave} & \texttt{volts: double} \\*
\hline
\textbf{Restricciones y Reglas} & Tensión eléctrica del sistema de carga en voltios leída en bornes. Provee método \textit{isLowBattery()} para mediciones inferiores a 11.80V en reposo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} FuelLevel} \\*
\hline
\textbf{Atributos Clave} & \texttt{percentage: double} \\*
\hline
\textbf{Restricciones y Reglas} & Porcentaje de combustible remanente en el depósito vehicular, acotado estrictamente en escala porcentual de 0.0 a 100.0. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} GeoCoordinates} \\*
\hline
\textbf{Atributos Clave} & \texttt{latitude: double, longitude: double} \\*
\hline
\textbf{Restricciones y Reglas} & Coordenadas geodésicas de posicionamiento GPS en formato decimal con latitud entre -90.0 y 90.0 y longitud entre -180.0 y 180.0. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} TelemetryPids} \\*
\hline
\textbf{Atributos Clave} & \texttt{parameters: Map<String, Object>} \\*
\hline
\textbf{Restricciones y Reglas} & Mapeo inmutable de parámetros OBD-II normalizados (PIDs) leídos e interpretados desde la trama sensorial vehicular. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} ConnectionType} \\*
\hline
\textbf{Atributos Clave} & Constantes de conectividad física \\*
\hline
\textbf{Restricciones y Reglas} & Canales de transmisión telemática vehicular: BLUETOOTH\_BLE, SIM\_CELLULAR y WIFI. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} DeviceStatus} \\*
\hline
\textbf{Atributos Clave} & Constantes de situación operativa \\*
\hline
\textbf{Restricciones y Reglas} & Estados de habilitación del hardware en plataforma: ACTIVE, INACTIVE, LOST y BROKEN. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} FaultSeverity} \\*
\hline
\textbf{Atributos Clave} & Constantes de gravedad técnica \\*
\hline
\textbf{Restricciones y Reglas} & Criticidad del código de avería en la ECU automotriz: LOW, MEDIUM y CRITICAL. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} AlertSeverity} \\*
\hline
\textbf{Atributos Clave} & Constantes de criticidad de alerta \\*
\hline
\textbf{Restricciones y Reglas} & Niveles de severidad predictiva para conductor y taller: LOW, MEDIUM, HIGH y CRITICAL. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} AlertStatus} \\*
\hline
\textbf{Atributos Clave} & Constantes de ciclo de vida \\*
\hline
\textbf{Restricciones y Reglas} & Estados de atención y gestión de la advertencia predictiva: DISPATCHED, ACKNOWLEDGED, RESOLVED y DISMISSED. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} RiskLevel} \\*
\hline
\textbf{Atributos Clave} & Constantes de riesgo analítico \\*
\hline
\textbf{Restricciones y Reglas} & Clasificación de riesgo global estimado por el motor de inferencia: LOW, MODERATE, HIGH y CRITICAL. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes inmutables organizados en los subpaquetes modulares ids, valueobjects y enums de com.andeva.atelier.platform.iot.domain.model.

**Servicios de Dominio de IoT Telemetry & Predictive Maintenance**

Aquellas operaciones algorítmicas que involucran transformaciones complejas o evaluación de reglas de negocio multidisciplinarias se delegan en servicios de dominio puros:

- **PredictiveAnomalyDetectionEngine:** Motor analítico de inferencia que evalúa en tiempo real cada registro telemático recién arribado. Aplica heurísticas fundadas en la termodinámica vehicular para advertir sobrecalentamientos de refrigerante superiores a 105.0°C o 115.0°C, caídas de tensión de acumulador por debajo de 11.80V en ralentí y combustiones defectuosas en cilindros asociadas a fluctuaciones erráticas de RPM.

- **DtcCodeEvaluationService:** Servicio taxonómico que interpreta la nomenclatura alfanumérica de códigos de falla según estándares internacionales, clasificando su impacto en tren motriz, chasis, carrocería o redes de comunicación y proponiendo paquetes de servicio correctivo en el taller.

- **VehicleThermodynamicEvaluationService:** Servicio analítico que modela las curvas dinámicas de disipación térmica y cinemática vehicular. Correlaciona la temperatura del refrigerante con el régimen de revoluciones y la velocidad para diagnosticar fallas incipientes en el sistema de enfriamiento antes de una sobretemperatura catastrófica.

En la @tbl:iot-domain-services se formalizan las responsabilidades algorítmicas y los contratos públicos de los servicios de dominio telemáticos.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Servicios de Dominio de IoT Telemetry \& Predictive Maintenance} \label{tbl:iot-domain-services} \\
\hline
\thfirst{Servicio de Dominio} & \thcell{Responsabilidad y Lógica Algorítmica} \\
\hline
\endfirsthead
\hline
\thfirst{Servicio de Dominio} & \thcell{Responsabilidad y Lógica Algorítmica} \\
\hline
\endhead
PredictiveAnomaly\allowbreak DetectionEngine & Motor analítico de inferencia en tiempo real que evalúa las lecturas de telemetría recién ingestadas. \newline
- Sobrecalentamiento crítico de refrigerante: temperatura superior a 105.0°C genera alerta con 88.00\% de certeza, incrementándose a 98.50\% si supera 115.0°C para mitigar deformación del bloque de motor. \newline
- Degradación severa de acumulador: voltaje inferior a 11.80V con vehículo en reposo genera alerta con 91.20\% de certeza ante riesgo inminente de arranque fallido. \newline
- Combustión anómala de cilindros: presencia de códigos en rango P0300 a P0304 junto a fluctuaciones de RPM genera alerta con 95.00\% de certeza para prevenir fundición de catalizador. \\*
\hline
\textbf{Métodos Clave} & \texttt{Optional<AnomalyEvaluationResult> evaluateTelemetryRecord(TelemetryRecord record)} \\*
\hline
\textbf{Paquete} & \texttt{...iot.domain.services} \\
\hline
DtcCodeEvaluation\allowbreak Service & Servicio de enriquecimiento taxonómico de códigos de diagnóstico conforme a SAE J2012 e ISO 15031. \newline
- Extrae la letra inicial del código alfanumérico para determinar la categoría funcional del subsistema automotriz afectado. \newline
- Asigna la severidad reglamentaria predeterminada evaluando si el código compromete la seguridad de marcha, emisiones o confort. \newline
- Sugiere el enlace paramétrico hacia paquetes de mantenimiento preventivo y correctivo del catálogo maestro de MRO. \\*
\hline
\textbf{Métodos Clave} & \texttt{DtcEvaluationResult evaluateDtcCode(DtcCode dtcCode)} \\*
\hline
\textbf{Paquete} & \texttt{...iot.domain.services} \\
\hline
VehicleThermodynamic\allowbreak EvaluationService & Servicio de evaluación termodinámica y cinemática de motores de combustión interna. \newline
- Modela curvas térmicas en función del régimen de revoluciones por minuto, velocidad lineal y temperatura de refrigerante. \newline
- Detecta gradientes anómalos de disipación térmica para anticipar fallas incipientes en termostato, electroventilador o bomba de agua. \newline
- Correlaciona caídas térmicas en regímenes de alta carga mecánica para prevenir choque térmico en componentes del motor. \\*
\hline
\textbf{Métodos Clave} & \texttt{ThermodynamicEvaluationResult evaluateThermalDynamics(EngineTemperature temp, EngineRpm rpm, VehicleSpeed speed)} \\*
\hline
\textbf{Paquete} & \texttt{...iot.domain.services} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de servicios de dominio analíticos del paquete com.andeva.atelier.platform.iot.domain.services.

**Puertos de Repositorio de la Capa de Dominio**

El aislamiento de la lógica de negocio frente a los motores de almacenamiento se consolida mediante interfaces de repositorio que definen operaciones atómicas de consulta e inserción por lotes.

En la @tbl:iot-repository-ports se detallan los contratos de persistencia del dominio y sus métodos de acceso especializados.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Puertos de Repositorio de la Capa de Dominio de IoT Telemetry} \label{tbl:iot-repository-ports} \\
\hline
\thfirst{Puerto de Repositorio} & \thcell{Operaciones y Responsabilidad de Dominio} \\
\hline
\endfirsthead
\hline
\thfirst{Puerto de Repositorio} & \thcell{Operaciones y Responsabilidad de Dominio} \\
\hline
\endhead
Obd2DeviceRepository & Contrato de persistencia para el inventario de escáneres OBD-II y verificación de identificadores. \newline
\textit{save(Obd2Device device): Obd2Device} \newline
\textit{findById(DeviceId id): Optional<Obd2Device>} \newline
\textit{findByIdentifier(DeviceIdentifier id): Optional<Obd2Device>} \newline
\textit{findAllByTenantId(TenantId tenantId): List<Obd2Device>} \newline
\textit{existsByIdentifier(DeviceIdentifier id): boolean} \\*
\hline
\textbf{Paquete} & \texttt{...iot.domain.repositories} \\
\hline
DeviceInstallation\allowbreak Repository & Contrato para auditar las sesiones de montaje físico y vigencia temporal de escáneres. \newline
\textit{save(DeviceInstallation inst): DeviceInstallation} \newline
\textit{findById(InstallationId id): Optional<DeviceInstallation>} \newline
\textit{findActiveByVehicleId(VehicleId id): Optional<DeviceInstallation>} \newline
\textit{findActiveByDeviceId(DeviceId id): Optional<DeviceInstallation>} \newline
\textit{findAllHistoryByVehicleId(VehicleId id): List<DeviceInstallation>} \\*
\hline
\textbf{Paquete} & \texttt{...iot.domain.repositories} \\
\hline
TelemetryRecord\allowbreak Repository & Contrato de persistencia de alto rendimiento para inserción por lotes y agregación en TimescaleDB. \newline
\textit{saveAllBatch(List<TelemetryRecord> records): void} \newline
\textit{findLatestByVehicleId(VehicleId id): Optional<TelemetryRecord>} \newline
\textit{findHistoryAggregated(VehicleId id, Instant from, Instant to, String bucket): List<TelemetryRecord>} \\*
\hline
\textbf{Paquete} & \texttt{...iot.domain.repositories} \\
\hline
VehicleFaultRepository & Contrato para gestionar el registro histórico y estado de códigos de avería por vehículo. \newline
\textit{save(VehicleFault fault): VehicleFault} \newline
\textit{findById(FaultId id): Optional<VehicleFault>} \newline
\textit{findActiveByVehicleId(VehicleId id): List<VehicleFault>} \newline
\textit{findAllByVehicleId(VehicleId id): List<VehicleFault>} \\*
\hline
\textbf{Paquete} & \texttt{...iot.domain.repositories} \\
\hline
PredictiveAlert\allowbreak Repository & Contrato para almacenar y monitorear las alertas predictivas formuladas para conductores y talleres. \newline
\textit{save(PredictiveAlert alert): PredictiveAlert} \newline
\textit{findById(AlertId id): Optional<PredictiveAlert>} \newline
\textit{findAllByVehicleId(VehicleId id): List<PredictiveAlert>} \newline
\textit{findAllByTenantIdAndStatus(TenantId id, AlertStatus st): List<PredictiveAlert>} \\*
\hline
\textbf{Paquete} & \texttt{...iot.domain.repositories} \\
\hline
DtcCatalogRepository & Contrato de consulta sobre el catálogo maestro internacional de fallas SAE J2012 e ISO 15031. \newline
\textit{findById(DtcCatalogId id): Optional<DtcCatalogEntry>} \newline
\textit{findByCode(DtcCode code): Optional<DtcCatalogEntry>} \newline
\textit{findAllByCategory(String category): List<DtcCatalogEntry>} \newline
\textit{existsByCode(DtcCode code): boolean} \\*
\hline
\textbf{Paquete} & \texttt{...iot.domain.repositories} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Interfaces de repositorios del dominio en el paquete com.andeva.atelier.platform.iot.domain.repositories.

**Taxonomía de Eventos de Dominio de IoT Telemetry**

La comunicación asíncrona y la propagación de cambios de estado hacia otros límites del sistema se orquestan mediante eventos de dominio inmutables. Estos eventos informan el alta de hardware, el inicio de sesiones de monitoreo, la inserción masiva de lecturas y la formulación de alertas predictivas.

En la @tbl:iot-domain-events se sintetiza la taxonomía de eventos de dominio generados en el subsistema de telemetría y mantenimiento predictivo.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Taxonomía de Eventos de Dominio de IoT Telemetry \& Predictive Maintenance} \label{tbl:iot-domain-events} \\
\hline
\thfirst{Evento de Dominio} & \thcell{Causa de Emisión y Carga Útil del Contrato} \\
\hline
\endfirsthead
\hline
\thfirst{Evento de Dominio} & \thcell{Causa de Emisión y Carga Útil del Contrato} \\
\hline
\endhead
CriticalEngineAnomaly\allowbreak DetectedEvent & Emitido por el motor de inferencia cuando los sensores rebasan umbrales termodinámicos de peligro inminente. \newline
\textbf{Carga útil:} VehicleId vehicleId, TenantId tenantId, AlertType type, ConfidenceScore score, String message. \\*
\hline
DeviceInstalledOn\allowbreak VehicleEvent & Emitido al acoplar un escáner en el puerto OBD-II del vehículo iniciando el monitoreo continuo. \newline
\textbf{Carga útil:} InstallationId installationId, DeviceId deviceId, VehicleId vehicleId, Instant timestamp. \\*
\hline
DeviceUninstalledFrom\allowbreak VehicleEvent & Emitido al desconectar el hardware en foso asentando el odómetro final para su sincronización con CRM. \newline
\textbf{Carga útil:} InstallationId installationId, VehicleId vehicleId, int finalOdometerKm, Instant timestamp. \\*
\hline
Obd2DeviceRegistered\allowbreak Event & Emitido al incorporar y catalogar un nuevo hardware en el inventario del taller automotriz. \newline
\textbf{Carga útil:} DeviceId deviceId, TenantId tenantId, DeviceIdentifier identifier, Instant occurredOn. \\*
\hline
PredictiveAlert\allowbreak AcknowledgedEvent & Emitido cuando el conductor o el asesor de servicio confirma la lectura de la alerta predictiva. \newline
\textbf{Carga útil:} AlertId alertId, VehicleId vehicleId, Instant acknowledgedAt. \\*
\hline
PredictiveAlert\allowbreak DispatchedEvent & Emitido al despachar la notificación push a las aplicaciones móviles mediante Firebase Cloud Messaging. \newline
\textbf{Carga útil:} AlertId alertId, VehicleId vehicleId, TenantId tenantId, String fcmMessageId, Instant dispatchedAt. \\*
\hline
PredictiveAlert\allowbreak GeneratedEvent & Emitido al formularse algorítmicamente una nueva advertencia preventiva tras el análisis analítico. \newline
\textbf{Carga útil:} AlertId alertId, VehicleId vehicleId, TenantId tenantId, AlertType type, ConfidenceScore confidenceScore, Instant generatedAt. \\*
\hline
TelemetryBatchIngested\allowbreak Event & Emitido tras insertar exitosamente una ráfaga masiva de lecturas temporales en TimescaleDB. \newline
\textbf{Carga útil:} VehicleId vehicleId, TenantId tenantId, int recordsCount, Instant latestTimestamp. \\*
\hline
VehicleFaultDetected\allowbreak Event & Emitido al capturar un código de avería DTC emitido por la computadora de a bordo del automóvil. \newline
\textbf{Carga útil:} FaultId faultId, VehicleId vehicleId, TenantId tenantId, DtcCode dtcCode, FaultSeverity severity. \\*
\hline
VehicleFaultResolved\allowbreak Event & Emitido al certificar la resolución técnica y reparación mecánica en foso de una falla DTC en el taller. \newline
\textbf{Carga útil:} FaultId faultId, VehicleId vehicleId, TenantId tenantId, DtcCode dtcCode, Instant resolvedAt. \\*
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Taxonomía de eventos de dominio inmutables del paquete com.andeva.atelier.platform.iot.domain.model.events.

**Excepciones de Dominio y Manejo de Errores Semánticos**

Las transgresiones a las invariantes de negocio y anomalías en las tramas sensoriales se gestionan mediante excepciones semánticas no comprobadas derivadas de **IoTDomainException**. Cada excepción porta un código de error normalizado bajo la norma RFC 7807 que permite proyectar fallos claros hacia las interfaces de usuario.

En la @tbl:iot-domain-exceptions se catalogan las excepciones semánticas del dominio y sus condiciones de activación en el sistema.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.8cm} | >{\raggedright\arraybackslash}p{9.6cm} |}
\caption{Excepciones de Dominio y Códigos Semánticos de IoT Telemetry} \label{tbl:iot-domain-exceptions} \\
\hline
\thfirst{Código de Error Semántico} & \thcell{Condición de Lanzamiento en el Modelo} \\
\hline
\endfirsthead
\hline
\thfirst{Código de Error Semántico} & \thcell{Condición de Lanzamiento en el Modelo} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} ActiveInstallationConflictException} \\*
\hline
\texttt{ERR\_ACTIVE\_INSTALLATION\_CONFLICT} & El vehículo ya tiene asignado otro escáner físico transmitiendo telemetría en paralelo. Mapeo HTTP 409 Conflict. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} DeviceAlreadyInstalledException} \\*
\hline
\texttt{ERR\_DEVICE\_ALREADY\_INSTALLED} & El escáner OBD-II ya cuenta con una instalación activa en otra unidad sin concluir previamente. Mapeo HTTP 409 Conflict. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} DeviceNotFoundException} \\*
\hline
\texttt{ERR\_DEVICE\_NOT\_FOUND} & No se localiza el escáner en el inventario mediante el identificador UUID o dirección física suministrada. Mapeo HTTP 404 Not Found. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} InstallationNotFoundException} \\*
\hline
\texttt{ERR\_INSTALLATION\_NOT\_FOUND} & La sesión de montaje telemático consultada no existe en el registro del taller automotriz. Mapeo HTTP 404 Not Found. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} InvalidDeviceIdentifierException} \\*
\hline
\texttt{ERR\_INVALID\_DEVICE\_IDENTIFIER} & La dirección física incumple el formato estricto de MAC Address de seis pares hexadecimales o código IMEI celular de quince dígitos. Mapeo HTTP 422 Unprocessable Entity. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} InvalidDtcCodeException} \\*
\hline
\texttt{ERR\_INVALID\_DTC\_CODE} & El código alfanumérico transgrede la nomenclatura formal de la norma SAE J2012 e ISO 15031-6. Mapeo HTTP 422 Unprocessable Entity. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} IoTDomainException} \\*
\hline
\texttt{ERR\_IOT\_DOMAIN\_BASE} & Superclase abstracta no comprobada de la que derivan todas las contingencias semánticas del contexto telemático bajo norma RFC 7807. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} PredictiveAlertNotFoundException} \\*
\hline
\texttt{ERR\_PREDICTIVE\_ALERT\_NOT\_FOUND} & No se localiza la alerta predictiva consultada para su confirmación o resolución en taller. Mapeo HTTP 404 Not Found. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} TimescaleIngestionException} \\*
\hline
\texttt{ERR\_TIMESCALE\_INGESTION\_FAILED} & Las lecturas sensoriales contienen magnitudes incompatibles con las leyes físicas del automotor o la ingesta por lotes en TimescaleDB falló. Mapeo HTTP 422 Unprocessable Entity. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} VehicleFaultNotFoundException} \\*
\hline
\texttt{ERR\_VEHICLE\_FAULT\_NOT\_FOUND} & No se localiza el registro del código de avería consultado para su seguimiento o resolución en taller. Mapeo HTTP 404 Not Found. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Jerarquía de excepciones semánticas no comprobadas del paquete com.andeva.atelier.platform.iot.domain.exceptions.

A partir de la formalización táctica de IoT Telemetry \& Predictive Maintenance, se identifican tres fundamentos de ingeniería de software que consolidan la robustez del subsistema de diagnóstico automotriz:

- **Aislamiento Físico y Desacoplamiento de Cargas de Series Temporales:**
  El diseño separa tajantemente el almacenamiento de telemetría de alta frecuencia respecto a las tablas transaccionales del ERP del taller. Al confinar las millones de lecturas sensoriales de motor en hipertablas particionadas por tiempo en TimescaleDB, la solución neutraliza cualquier riesgo de saturación de memoria, contención de bloqueos relacionales o degradación en el rendimiento de órdenes de trabajo y facturación.

- **Resiliencia de Conectividad en el Borde mediante Almacenamiento Intermedio Local:**
  La arquitectura reconoce la volatilidad de cobertura en carreteras y fosos mecánicos. Al equipar las aplicaciones móviles con capacidades de pasarela Bluetooth y persistencia local en Room SQLite, el sistema recolecta datos de forma ininterrumpida sin requerir conexión a internet perpetua, consolidando ráfagas masivas hacia el servidor central en cuanto se restablece el enlace de datos.

- **Sinergia Comercial Ética y Transformación Predictiva del Mantenimiento:**
  La articulación entre el motor analítico de anomalías, el catálogo de servicios de mantenimiento y la pasarela de notificaciones push de Firebase redefine el modelo operativo del taller mecánico. La detección matemática anticipada de fallas críticas evita averías catastróficas al propietario del vehículo y proporciona al taller un canal proactivo y justificado de venta cruzada preventiva con cotizaciones preconcebidas.



#### 2.6.9.2. Interface Layer

La Capa de Interfaz del Bounded Context IoT Telemetry & Predictive Maintenance opera como el adaptador primario perimetral bajo el paquete canónico **com.andeva.atelier.platform.iot.interfaces**. Su responsabilidad consiste en gobernar el flujo de comunicación proveniente de módems telemáticos vehiculares, teléfonos móviles de conductores y mecánicos en calidad de pasarelas Bluetooth, y estaciones web de taller, traduciendo tramas binarias u objetos JSON en comandos y consultas de aplicación con estricto aislamiento respecto a la persistencia interna.

Al ubicarse en la frontera perimetral del ecosistema telemático vehicular, los componentes tácticos de esta capa responden a cuatro principios arquitectónicos fundamentales:

- **Desacoplamiento perimetral y semántica RESTful orientada a recursos:** Exposición de servicios sustentada en sustantivos en plural y rutas superficiales de máximo dos niveles de profundidad, aislando la estructura interna de hipertablas de TimescaleDB y aplicando códigos HTTP semánticos para reflejar fielmente el resultado de cada transacción.

- **Ingestión asíncrona por ráfagas de alto rendimiento:** Recepción de lotes telemáticos masivos con persistencia por bloques y respuesta inmediata con código HTTP 202 Accepted, desacoplando el transporte de enlace de la ejecución del motor analítico de anomalías para sostener picos de tráfico sin degradación.

- **Validación defensiva perimetral fuertemente tipada:** Aplicación sistemática de reglas declarativas de Bean Validation sobre registros inmutables de Java, descartando tramas corruptas, códigos DTC anómalos o rangos físicos inverosímiles antes de que alcancen el modelo de dominio.

- **Fachada de Contexto Abierto con desacoplamiento intermodular:** Exposición controlada de contratos de lectura de telemetría, códigos de avería y cálculo de puntuación de salud mecánica hacia los contextos de CRM y MRO, garantizando interoperabilidad limpia sin dependencias bidireccionales.

En la @tbl:iot-interface-types se expone el catálogo taxonómico consolidado de los componentes tácticos que integran la Capa de Interfaz de IoT Telemetry & Predictive Maintenance, detallando sus categorías, paquetes canónicos y responsabilidades arquitectónicas.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo Consolidado de la Capa de Interfaz de IoT Telemetry \& Predictive Maintenance} \label{tbl:iot-interface-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endhead
Obd2\allowbreak Devices\allowbreak Controller & Endpoints REST para el registro, inventario y fiscalización del estado operativo de escáneres telemáticos del taller. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca Obd2DeviceCommandService y Obd2DeviceQueryService. Utiliza Obd2DeviceResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Device\allowbreak Installations\allowbreak Controller & Endpoints REST para orquestar la vinculación física, montaje y desmonte de dispositivos OBD-II en vehículos automotrices. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca DeviceInstallationCommandService y DeviceInstallationQueryService. Utiliza DeviceInstallationResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Telemetry\allowbreak Ingestion\allowbreak Controller & Endpoint perimetral de alta frecuencia para ingestión de ráfagas temporales, lecturas de tacómetro en tiempo real y métricas analíticas. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca TelemetryIngestionCommandService y TelemetryLogQueryService. Utiliza TelemetryResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Faults\allowbreak Controller & Endpoints REST para registro, consulta diagnóstica y resolución formal de códigos de avería electrónica vehicular DTC. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca VehicleFaultCommandService y VehicleFaultQueryService. Utiliza VehicleFaultResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Predictive\allowbreak Alerts\allowbreak Controller & Endpoints REST para gestión de advertencias predictivas, confirmación de lectura y canalización hacia mantenimiento preventivo. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca PredictiveAlertCommandService y PredictiveAlertQueryService. Utiliza PredictiveAlertResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Health\allowbreak Reports\allowbreak Controller & Endpoints REST para generación asistida por inteligencia artificial de diagnósticos globales, consulta pericial y descarga documental PDF. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca VehicleHealthReportCommandService y VehicleHealthReportQueryService. Utiliza VehicleHealthReportResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Register\allowbreak Device\allowbreak Request & Carga útil inmutable para dar de alta un nuevo escáner telemático en el inventario del taller mecánico. \\*
\hline
\textbf{Categoría} & Recurso REST de Petición \\*
\hline
\textbf{Relaciones} & Validado con Jakarta Bean Validation. Mapeado por Obd2DeviceResourceAssembler hacia RegisterObd2DeviceCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Update\allowbreak Device\allowbreak Status\allowbreak Request & Carga útil inmutable para actualizar la situación operativa del escáner en inventario. \\*
\hline
\textbf{Categoría} & Recurso REST de Petición \\*
\hline
\textbf{Relaciones} & Validado con Jakarta Bean Validation. Mapeado por Obd2DeviceResourceAssembler hacia UpdateDeviceStatusCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Install\allowbreak Device\allowbreak Request & Carga útil inmutable para acoplar un escáner telemático a una unidad automotriz registrando odómetro inicial. \\*
\hline
\textbf{Categoría} & Recurso REST de Petición \\*
\hline
\textbf{Relaciones} & Validado con Jakarta Bean Validation. Mapeado por DeviceInstallationResourceAssembler hacia InstallDeviceCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Uninstall\allowbreak Device\allowbreak Request & Carga útil inmutable para registrar el desmonte físico de un dispositivo con odómetro final e instante de retiro. \\*
\hline
\textbf{Categoría} & Recurso REST de Petición \\*
\hline
\textbf{Relaciones} & Validado con Jakarta Bean Validation. Mapeado por DeviceInstallationResourceAssembler hacia UninstallDeviceCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Telemetry\allowbreak Batch\allowbreak Request & Lote inmutable de hasta cien lecturas cinemáticas y térmicas emitidas por pasarelas móviles o módems vehiculares. \\*
\hline
\textbf{Categoría} & Recurso REST de Petición \\*
\hline
\textbf{Relaciones} & Validado en cascada con Jakarta Bean Validation. Mapeado por TelemetryResourceAssembler hacia IngestTelemetryBatchCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Register\allowbreak Vehicle\allowbreak Fault\allowbreak Request & Carga útil inmutable para asentar un código de avería electrónica DTC detectado en la computadora vehicular. \\*
\hline
\textbf{Categoría} & Recurso REST de Petición \\*
\hline
\textbf{Relaciones} & Validado con expresión regular SAE J2012. Mapeado por VehicleFaultResourceAssembler hacia RegisterVehicleFaultCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Generate\allowbreak Health\allowbreak Report\allowbreak Request & Carga útil inmutable para solicitar la generación pericial de un diagnóstico de salud vehicular parametrizando la ventana temporal. \\*
\hline
\textbf{Categoría} & Recurso REST de Petición \\*
\hline
\textbf{Relaciones} & Validado con límites de días de análisis. Mapeado por VehicleHealthReportResourceAssembler hacia GenerateVehicleHealthReportCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Obd2\allowbreak Device\allowbreak Response & Representación pública inmutable de un escáner telemático con especificaciones de enlace, modelo y estado de inventario. \\*
\hline
\textbf{Categoría} & Recurso REST de Respuesta \\*
\hline
\textbf{Relaciones} & Ensamblado por Obd2DeviceResourceAssembler a partir del agregado Obd2Device. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Device\allowbreak Installation\allowbreak Response & Representación pública inmutable de una sesión de vinculación entre escáner y vehículo con marcas de kilometraje y vigencia. \\*
\hline
\textbf{Categoría} & Recurso REST de Respuesta \\*
\hline
\textbf{Relaciones} & Ensamblado por DeviceInstallationResourceAssembler a partir del agregado DeviceInstallation. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Telemetry\allowbreak Ingestion\allowbreak Ack\allowbreak Response & Acuse de recibo perimetral tras la persistencia en lote indicando cantidad de lecturas procesadas y detección de anomalías. \\*
\hline
\textbf{Categoría} & Recurso REST de Respuesta \\*
\hline
\textbf{Relaciones} & Retornado por TelemetryIngestionController tras la ejecución de IngestTelemetryBatchCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Latest\allowbreak Telemetry\allowbreak Response & Tacómetro digital en tiempo real con lecturas instantáneas de velocidad, temperatura de motor, régimen de giro y batería. \\*
\hline
\textbf{Categoría} & Recurso REST de Respuesta \\*
\hline
\textbf{Relaciones} & Ensamblado por TelemetryResourceAssembler a partir del agregado temporal TelemetryRecord. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Fault\allowbreak Response & Representación pública inmutable de avería electrónica vehicular enriquecida con severidad, descripción y estado de resolución. \\*
\hline
\textbf{Categoría} & Recurso REST de Respuesta \\*
\hline
\textbf{Relaciones} & Ensamblado por VehicleFaultResourceAssembler a partir de la entidad VehicleFault y el catálogo de averías. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Predictive\allowbreak Alert\allowbreak Response & Representación pública inmutable de recomendación preventiva de taller con índice de certeza y servicio correctivo sugerido. \\*
\hline
\textbf{Categoría} & Recurso REST de Respuesta \\*
\hline
\textbf{Relaciones} & Ensamblado por PredictiveAlertResourceAssembler a partir del agregado PredictiveAlert. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Health\allowbreak Report\allowbreak Created\allowbreak Response & Carga útil perimetral de informe generado con resumen ejecutivo, métrica consolidada de salud y enlaces de acceso REST y descarga PDF. \\*
\hline
\textbf{Categoría} & Recurso REST de Respuesta \\*
\hline
\textbf{Relaciones} & Ensamblado por VehicleHealthReportResourceAssembler a partir del DTO analítico generado con Spring AI. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Latest\allowbreak Telemetry\allowbreak Dto & DTO inmutable perimetral para transferir en memoria la última instantánea sensorial vehicular a CRM y Workshop Operations (MRO). \\*
\hline
\textbf{Categoría} & DTO de Integración de Fachada \\*
\hline
\textbf{Relaciones} & Expuesto por IoTTelemetryContextFacade sin acoplamiento a las tablas temporales de TimescaleDB. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak acl.\allowbreak dto} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Active\allowbreak Vehicle\allowbreak Faults\allowbreak Dto & DTO inmutable perimetral para abastecer a Workshop Operations (MRO) con la lista de códigos DTC activos al abrir órdenes de trabajo. \\*
\hline
\textbf{Categoría} & DTO de Integración de Fachada \\*
\hline
\textbf{Relaciones} & Expuesto por IoTTelemetryContextFacade a partir de averías no resueltas de la unidad automotriz. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak acl.\allowbreak dto} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Telemetry\allowbreak Health\allowbreak Dto & DTO inmutable perimetral que condensa el índice de salud mecánica, indicador semafórico y existencia de alertas predictivas. \\*
\hline
\textbf{Categoría} & DTO de Integración de Fachada \\*
\hline
\textbf{Relaciones} & Expuesto por IoTTelemetryContextFacade hacia Customer and Fleet Management (CRM). \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak acl.\allowbreak dto} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Obd2\allowbreak Device\allowbreak Resource\allowbreak Assembler & Mapea agregados Obd2Device a Obd2DeviceResponse y transforma RegisterDeviceRequest en comandos de aplicación. \\*
\hline
\textbf{Categoría} & Ensamblador de Recursos REST \\*
\hline
\textbf{Relaciones} & Inyectado en Obd2DevicesController. Desempaqueta identificadores fuertemente tipados DeviceId. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Device\allowbreak Installation\allowbreak Resource\allowbreak Assembler & Mapea entidades DeviceInstallation a DeviceInstallationResponse y formula comandos de instalación y desinstalación física. \\*
\hline
\textbf{Categoría} & Ensamblador de Recursos REST \\*
\hline
\textbf{Relaciones} & Inyectado en DeviceInstallationsController. Valida transiciones de ciclo de vida de montaje. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Telemetry\allowbreak Resource\allowbreak Assembler & Proyecta agregados TelemetryRecord a VehicleLatestTelemetryResponse y mapea solicitudes de lote a IngestTelemetryBatchCommand. \\*
\hline
\textbf{Categoría} & Ensamblador de Recursos REST \\*
\hline
\textbf{Relaciones} & Inyectado en TelemetryIngestionController. Desacopla hipertablas de TimescaleDB de los contratos HTTP. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Fault\allowbreak Resource\allowbreak Assembler & Mapea entidades VehicleFault a VehicleFaultResponse y transforma peticiones de registro en comandos de aplicación. \\*
\hline
\textbf{Categoría} & Ensamblador de Recursos REST \\*
\hline
\textbf{Relaciones} & Inyectado en VehicleFaultsController. Enriquecido con el catálogo de códigos de avería. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Predictive\allowbreak Alert\allowbreak Resource\allowbreak Assembler & Transforma agregados PredictiveAlert en recursos de respuesta perimetrales PredictiveAlertResponse. \\*
\hline
\textbf{Categoría} & Ensamblador de Recursos REST \\*
\hline
\textbf{Relaciones} & Inyectado en PredictiveAlertsController. Denormaliza niveles de confianza y recomendaciones de servicio. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Health\allowbreak Report\allowbreak Resource\allowbreak Assembler & Transforma el dictamen pericial de inteligencia artificial en HealthReportCreatedResponse con enlaces REST y descarga PDF. \\*
\hline
\textbf{Categoría} & Ensamblador de Recursos REST \\*
\hline
\textbf{Relaciones} & Inyectado en VehicleHealthReportsController. Mapea GenerateHealthReportRequest hacia comandos de aplicación. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
IoT\allowbreak Telemetry\allowbreak Context\allowbreak Facade & Contrato público perimetral de Fachada de Contexto Abierto que abastece de datos telemáticos a CRM y Workshop Operations (MRO). \\*
\hline
\textbf{Categoría} & Fachada de Contexto Abierto \\*
\hline
\textbf{Relaciones} & Implementado en application.acl por IoTTelemetryContextFacadeImpl. Expone DTOs del subpaquete acl.dto. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Anomaly\allowbreak Detected\allowbreak Integration\allowbreak Event & Evento publicado al confirmar una anomalía cinemática o térmica severa en motor para alerta inmediata de CRM y notificaciones push. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado mediante Outbox transaccional. Consumido por CRM y pasarela de notificaciones push. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Predictive\allowbreak Alert\allowbreak Generated\allowbreak Integration\allowbreak Event & Evento publicado al formularse una recomendación predictiva de mantenimiento automotriz para presupuestación anticipada en taller. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado mediante Outbox transaccional. Consumido por Workshop Operations (MRO) y CRM. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Fault\allowbreak Logged\allowbreak Integration\allowbreak Event & Evento publicado al registrarse un nuevo código de falla DTC persistente para precarga diagnóstica en órdenes de trabajo de taller. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado mediante Outbox transaccional. Consumido por Workshop Operations (MRO). \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Health\allowbreak Report\allowbreak Generated\allowbreak Integration\allowbreak Event & Evento publicado al concluir la inferencia diagnóstica con inteligencia artificial comunicando la disponibilidad del dictamen pericial. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado mediante Outbox transaccional. Consumido por Workshop Operations (MRO) y CRM. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
IoT\allowbreak Exception\allowbreak Handler & Interceptor perimetral que captura excepciones de dominio de IoT y las serializa bajo el estándar RFC 7807 Problem Details. \\*
\hline
\textbf{Categoría} & Manejador Global de Excepciones \\*
\hline
\textbf{Relaciones} & Anotado con RestControllerAdvice. Captura IoTDomainException y excepciones de validación de Bean Validation. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak advice} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Catálogo taxonómico consolidado de componentes de la Capa de Interfaz pertenecientes a los subpaquetes interfaces.rest.controllers, interfaces.rest.resources.requests, interfaces.rest.resources.responses, interfaces.rest.transform, interfaces.rest.advice, interfaces.acl, interfaces.acl.dto e interfaces.events de com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak iot.

Los controladores REST de la capa perimetral delimitan formalmente los puntos de entrada para la gestión de dispositivos, el montaje vehicular, la ingestión de métricas, el diagnóstico electrónico, las alertas preventivas y la evaluación pericial de salud automotriz:

- **Obd2DevicesController**: Provee endpoints administrativos para la catalogación física, auditoría de número de serie o dirección MAC y alternancia de estados de disponibilidad operativa del inventario de escáneres del taller.

- **DeviceInstallationsController**: Orquesta las operaciones de instalación y desinstalación física de escáneres en automóviles, verificando la unicidad de sesiones activas y preservando la trazabilidad de kilometrajes de montaje y desmontaje.

- **TelemetryIngestionController**: Endpoint perimetral de máxima concurrencia optimizado para procesar ráfagas sensoriales emitidas por pasarelas vehiculares, proveyendo lecturas instantáneas para tacómetros digitales y agregaciones analíticas de series temporales.

- **VehicleFaultsController**: Canaliza el reporte de averías electrónicas capturadas desde la unidad de control del motor, facilitando la consulta de anomalías no resueltas y el asentamiento formal de su subsanación en foso.

- **PredictiveAlertsController**: Administra el ciclo de vida de las advertencias comerciales y técnicas generadas por el motor analítico, permitiendo la confirmación de lectura por el personal o la conversión proactiva en citas de servicio.

- **VehicleHealthReportsController**: Expone puntos de acceso perimetrales para la generación asistida por inteligencia artificial de diagnósticos globales del estado del vehículo, consulta del dictamen pericial más reciente y compilación descargable en documento PDF institucional.

En la @tbl:iot-controllers-and-endpoints se detallan los contratos de comunicación, rutas canónicas, verbos HTTP, códigos de respuesta y restricciones de seguridad de los seis controladores perimetrales.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Controladores REST y Endpoints de Comunicación de IoT Telemetry \& Predictive Maintenance} \label{tbl:iot-controllers-and-endpoints} \\
\hline
\thfirst{Recurso de Petición} & \thcell{Código y Respuesta HTTP} \\
\hline
\endfirsthead
\hline
\thfirst{Recurso de Petición} & \thcell{Código y Respuesta HTTP} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} Obd2\allowbreak Devices\allowbreak Controller} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak iot/\allowbreak devices}} \\*
\hline
\textbf{Petición:} Ninguna o Filtros de Consulta & \textbf{Respuesta:} 200 OK (\texttt{List<Obd2\allowbreak Device\allowbreak Response>}) \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con roles de personal de taller mecánico \\*
\hline
\textbf{Responsabilidad} & Recupera el catálogo de escáneres telemáticos registrados y disponibles en el taller autenticado. \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak iot/\allowbreak devices/\allowbreak \{id\}}} \\*
\hline
\textbf{Petición:} Path Variable \texttt{id} & \textbf{Respuesta:} 200 OK (\texttt{Obd2\allowbreak Device\allowbreak Response}) \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con \texttt{ROLE\_WORKSHOP\_ADMIN} o \texttt{ROLE\_WORKSHOP\_TECHNICIAN} \\*
\hline
\textbf{Responsabilidad} & Obtiene la especificación detallada de un dispositivo, identificador físico, protocolo y estado de inventario. \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak iot/\allowbreak devices}} \\*
\hline
\textbf{Petición:} \texttt{Register\allowbreak Device\allowbreak Request} & \textbf{Respuesta:} 201 CREATED (\texttt{Obd2\allowbreak Device\allowbreak Response}) con cabecera \texttt{Location} \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con rol directivo \texttt{ROLE\_WORKSHOP\_ADMIN} \\*
\hline
\textbf{Responsabilidad} & Registra un nuevo escáner en el inventario del taller validando la unicidad del identificador físico. \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{PATCH} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak iot/\allowbreak devices/\allowbreak \{id\}/\allowbreak status}} \\*
\hline
\textbf{Petición:} \texttt{Update\allowbreak Device\allowbreak Status\allowbreak Request} & \textbf{Respuesta:} 200 OK (\texttt{Obd2\allowbreak Device\allowbreak Response}) \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con rol directivo \texttt{ROLE\_WORKSHOP\_ADMIN} \\*
\hline
\textbf{Responsabilidad} & Actualiza la condición operativa del dispositivo permitiendo marcarlo como disponible, en mantenimiento o averiado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} Device\allowbreak Installations\allowbreak Controller} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak iot/\allowbreak installations/\allowbreak install}} \\*
\hline
\textbf{Petición:} \texttt{Install\allowbreak Device\allowbreak Request} & \textbf{Respuesta:} 201 CREATED (\texttt{Device\allowbreak Installation\allowbreak Response}) con cabecera \texttt{Location} \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con \texttt{ROLE\_WORKSHOP\_TECHNICIAN} o \texttt{ROLE\_WORKSHOP\_ADMIN} \\*
\hline
\textbf{Responsabilidad} & Asocia físicamente un escáner a un automóvil validando que ni el dispositivo ni el vehículo tengan sesiones activas. \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak iot/\allowbreak installations/\allowbreak \{id\}/\allowbreak uninstall}} \\*
\hline
\textbf{Petición:} \texttt{Uninstall\allowbreak Device\allowbreak Request} & \textbf{Respuesta:} 200 OK (\texttt{Device\allowbreak Installation\allowbreak Response}) \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con \texttt{ROLE\_WORKSHOP\_TECHNICIAN} o \texttt{ROLE\_WORKSHOP\_ADMIN} \\*
\hline
\textbf{Responsabilidad} & Registra el retiro físico del escáner asentando kilometraje final e instante formal de conclusión de sesión. \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak iot/\allowbreak installations/\allowbreak vehicle/\allowbreak \{vehicleId\}/\allowbreak active}} \\*
\hline
\textbf{Petición:} Path Variable \texttt{vehicleId} & \textbf{Respuesta:} 200 OK (\texttt{Device\allowbreak Installation\allowbreak Response}) \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con rol de conductor o personal de taller mecánico \\*
\hline
\textbf{Responsabilidad} & Consulta el escáner telemático actualmente montado y transmitiendo en la unidad vehicular. \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak iot/\allowbreak installations/\allowbreak vehicle/\allowbreak \{vehicleId\}/\allowbreak history}} \\*
\hline
\textbf{Petición:} Path Variable \texttt{vehicleId} & \textbf{Respuesta:} 200 OK (\texttt{List<Device\allowbreak Installation\allowbreak Response>}) \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con rol técnico de taller mecánico \\*
\hline
\textbf{Responsabilidad} & Provee la trazabilidad histórica de dispositivos instalados en el vehículo durante su ciclo de mantenimiento. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} Telemetry\allowbreak Ingestion\allowbreak Controller} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak iot/\allowbreak telemetry/\allowbreak batch}} \\*
\hline
\textbf{Petición:} \texttt{Telemetry\allowbreak Batch\allowbreak Request} & \textbf{Respuesta:} 202 ACCEPTED (\texttt{Telemetry\allowbreak Ingestion\allowbreak Ack\allowbreak Response}) \\*
\hline
\textbf{Seguridad y Rol} & Token de Dispositivo o Autenticación Bearer JWT de conductor en ruta \\*
\hline
\textbf{Responsabilidad} & Ingesta ráfagas de una a cien lecturas temporales persistiendo en TimescaleDB y evaluando anomalías predictivas. \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak iot/\allowbreak telemetry/\allowbreak vehicle/\allowbreak \{vehicleId\}/\allowbreak latest}} \\*
\hline
\textbf{Petición:} Path Variable \texttt{vehicleId} & \textbf{Respuesta:} 200 OK (\texttt{Vehicle\allowbreak Latest\allowbreak Telemetry\allowbreak Response}) \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con rol de conductor o personal de taller \\*
\hline
\textbf{Responsabilidad} & Retorna la última instantánea sensorial registrada operando como tacómetro digital en tiempo real. \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak iot/\allowbreak telemetry/\allowbreak vehicle/\allowbreak \{vehicleId\}/\allowbreak history}} \\*
\hline
\textbf{Petición:} Parámetros \texttt{from}, \texttt{to}, \texttt{interval} & \textbf{Respuesta:} 200 OK (\texttt{List<Vehicle\allowbreak Latest\allowbreak Telemetry\allowbreak Response>}) \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con rol técnico o directivo de taller \\*
\hline
\textbf{Responsabilidad} & Consulta series temporales agregadas por intervalos mediante funciones nativas de hipertabla de TimescaleDB. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} Vehicle\allowbreak Faults\allowbreak Controller} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak iot/\allowbreak faults}} \\*
\hline
\textbf{Petición:} \texttt{Register\allowbreak Vehicle\allowbreak Fault\allowbreak Request} & \textbf{Respuesta:} 201 CREATED (\texttt{Vehicle\allowbreak Fault\allowbreak Response}) con cabecera \texttt{Location} \\*
\hline
\textbf{Seguridad y Rol} & Token de Dispositivo o Autenticación Bearer JWT técnica \\*
\hline
\textbf{Responsabilidad} & Asienta un código de avería electrónica DTC detectado en la computadora vehicular clasificando su severidad. \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak iot/\allowbreak faults/\allowbreak vehicle/\allowbreak \{vehicleId\}/\allowbreak active}} \\*
\hline
\textbf{Petición:} Path Variable \texttt{vehicleId} & \textbf{Respuesta:} 200 OK (\texttt{List<Vehicle\allowbreak Fault\allowbreak Response>}) \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con rol de conductor o mecánico de taller \\*
\hline
\textbf{Responsabilidad} & Lista las anomalías electrónicas no resueltas registradas en la unidad automotriz para diagnóstico en foso. \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{PATCH} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak iot/\allowbreak faults/\allowbreak \{id\}/\allowbreak resolve}} \\*
\hline
\textbf{Petición:} Path Variable \texttt{id} & \textbf{Respuesta:} 200 OK (\texttt{Vehicle\allowbreak Fault\allowbreak Response}) \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con rol técnico \texttt{ROLE\_WORKSHOP\_TECHNICIAN} \\*
\hline
\textbf{Responsabilidad} & Marca una avería electrónica como resuelta vinculando la subsanación mecánica efectuada en el taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} Predictive\allowbreak Alerts\allowbreak Controller} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak iot/\allowbreak alerts/\allowbreak tenant}} \\*
\hline
\textbf{Petición:} Parámetros \texttt{severity}, \texttt{status} & \textbf{Respuesta:} 200 OK (\texttt{List<Predictive\allowbreak Alert\allowbreak Response>}) \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con \texttt{ROLE\_WORKSHOP\_MANAGER} o \texttt{ROLE\_WORKSHOP\_ADMIN} \\*
\hline
\textbf{Responsabilidad} & Despliega el tablero de advertencias predictivas y oportunidades de servicio preventivo del taller mecánico. \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak iot/\allowbreak alerts/\allowbreak vehicle/\allowbreak \{vehicleId\}}} \\*
\hline
\textbf{Petición:} Path Variable \texttt{vehicleId} & \textbf{Respuesta:} 200 OK (\texttt{List<Predictive\allowbreak Alert\allowbreak Response>}) \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con rol de conductor o asesor de taller \\*
\hline
\textbf{Responsabilidad} & Recupera el historial de alertas predictivas generadas por el motor analítico para una unidad automotriz. \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{PATCH} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak iot/\allowbreak alerts/\allowbreak \{id\}/\allowbreak acknowledge}} \\*
\hline
\textbf{Petición:} Path Variable \texttt{id} & \textbf{Respuesta:} 200 OK (\texttt{Predictive\allowbreak Alert\allowbreak Response}) \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con rol de personal técnico o asesor \\*
\hline
\textbf{Responsabilidad} & Registra el acuse de recibo de la alerta predictiva confirmando que el personal del taller ha tomado conocimiento. \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak iot/\allowbreak alerts/\allowbreak \{id\}/\allowbreak convert-to-appointment}} \\*
\hline
\textbf{Petición:} Path Variable \texttt{id} & \textbf{Respuesta:} 200 OK (\texttt{Predictive\allowbreak Alert\allowbreak Response}) \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con rol de asesor de servicio \\*
\hline
\textbf{Responsabilidad} & Canaliza la alerta predictiva hacia la programación de cita de mantenimiento preventivo en los módulos de CRM y MRO. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} Vehicle\allowbreak Health\allowbreak Reports\allowbreak Controller} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak iot/\allowbreak vehicles/\allowbreak \{vehicleId\}/\allowbreak health-reports/\allowbreak generate}} \\*
\hline
\textbf{Petición:} \texttt{Generate\allowbreak Health\allowbreak Report\allowbreak Request}, Path \texttt{vehicleId} & \textbf{Respuesta:} 201 CREATED (\texttt{Health\allowbreak Report\allowbreak Created\allowbreak Response}) con cabecera \texttt{Location} \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con rol técnico, asesor de servicio o administrador de taller \\*
\hline
\textbf{Responsabilidad} & Coordina la extracción de telemetría y averías electrónicas, invoca la inferencia de inteligencia artificial estructurada y persiste alertas preventivas de alta certeza. \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak iot/\allowbreak vehicles/\allowbreak \{vehicleId\}/\allowbreak health-reports/\allowbreak generate-async}} \\*
\hline
\textbf{Petición:} \texttt{Generate\allowbreak Health\allowbreak Report\allowbreak Request}, Path \texttt{vehicleId} & \textbf{Respuesta:} 202 ACCEPTED (\texttt{Void}) \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con rol directivo de taller o gestor de flota \\*
\hline
\textbf{Responsabilidad} & Encola el análisis pericial en segundo plano para evaluación de flotas vehiculares masivas sin bloquear la interfaz de usuario. \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak iot/\allowbreak vehicles/\allowbreak \{vehicleId\}/\allowbreak health-reports/\allowbreak latest}} \\*
\hline
\textbf{Petición:} Path Variable \texttt{vehicleId} & \textbf{Respuesta:} 200 OK (\texttt{Health\allowbreak Report\allowbreak Created\allowbreak Response}) \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con rol técnico, asesor de servicio o conductor \\*
\hline
\textbf{Responsabilidad} & Recupera el último dictamen consolidado de salud automotriz con resumen pericial, índice global y enlaces de acceso. \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak iot/\allowbreak vehicles/\allowbreak \{vehicleId\}/\allowbreak health-reports/\allowbreak \{reportId\}/\allowbreak pdf}} \\*
\hline
\textbf{Petición:} Path Variables \texttt{vehicleId}, \texttt{reportId} & \textbf{Respuesta:} 200 OK (\texttt{application/pdf}) con \texttt{Content-Disposition} \\*
\hline
\textbf{Seguridad y Rol} & Autenticación Bearer JWT con rol técnico, asesor de servicio o conductor \\*
\hline
\textbf{Responsabilidad} & Renderiza y transmite el informe pericial en formato binario PDF aplicando maquetación institucional con membrete corporativo y semáforos de estado. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación formal de controladores REST y endpoints de comunicación del Bounded Context IoT Telemetry \& Predictive Maintenance.

La transferencia de información a través del perímetro del sistema se estructura mediante contratos de datos inmutables modelados como registros de Java:

- **Contratos de Petición**: Capturan las intenciones del usuario o dispositivos telemáticos validando identificadores vehiculares obligatorios, rangos de magnitudes físicas, estructuras SAE J2012 de códigos DTC y límites temporales de análisis.

- **Contratos de Respuesta**: Encapsulan proyecciones optimizadas para visualización en aplicaciones web y móviles, serializando estados operativos, historiales diagnósticos y acuses de recibo perimetrales.

- **Contratos DTO de Fachada**: Definen estructuras inmutables de intercambio en memoria para proveer a CRM y Workshop Operations con datos telemáticos consolidados sin acoplar los contextos colaboradores a la persistencia interna.

En la @tbl:iot-resources-dtos se especifican los atributos estructurales y las reglas de validación declarativa que rigen los recursos DTO de petición, respuesta y contratos de fachada de este contexto.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Recursos DTO de Entrada y Salida del Bounded Context IoT Telemetry \& Predictive Maintenance} \label{tbl:iot-resources-dtos} \\
\hline
\thfirst{Aspecto de Recurso} & \thcell{Especificación de Atributos e Integridad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Recurso} & \thcell{Especificación de Atributos e Integridad} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Petición:} Register\allowbreak Device\allowbreak Request} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\*
\hline
\textbf{Atributos Principales} & \texttt{deviceIdentifier}, \texttt{connectionType}, \texttt{hardwareModel}, \texttt{firmwareVersion} \\*
\hline
\textbf{Validación de Integridad} & Anotación \texttt{@NotBlank} para deviceIdentifier con validación de patrón MAC Address o IMEI, \texttt{@NotBlank} para connectionType admitiendo BLUETOOTH\_BLE, SIM\_CELLULAR o WIFI, y longitud máxima de cien caracteres para modelo y versión de firmware. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Petición:} Update\allowbreak Device\allowbreak Status\allowbreak Request} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\*
\hline
\textbf{Atributos Principales} & \texttt{status} \\*
\hline
\textbf{Validación de Integridad} & Anotación \texttt{@NotBlank} y validación de patrón coincidente con valores del enum DeviceStatus como AVAILABLE, INSTALLED, IN\_MAINTENANCE, BROKEN o DECOMMISSIONED. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Petición:} Install\allowbreak Device\allowbreak Request} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\*
\hline
\textbf{Atributos Principales} & \texttt{deviceId}, \texttt{vehicleId}, \texttt{currentOdometerKm} \\*
\hline
\textbf{Validación de Integridad} & Identificadores obligatorios \texttt{@NotNull} en formato UUID para escáner y vehículo, y kilometraje actual de odómetro mayor o igual a cero con anotación \texttt{@Min(0)}. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Petición:} Uninstall\allowbreak Device\allowbreak Request} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\*
\hline
\textbf{Atributos Principales} & \texttt{finalOdometerKm}, \texttt{uninstalledAt} \\*
\hline
\textbf{Validación de Integridad} & Kilometraje final no negativo validado con \texttt{@Min(0)} verificando avance cronológico respecto al odómetro de instalación, e instante de retiro con valor no futuro o nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Petición:} Telemetry\allowbreak Batch\allowbreak Request} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\*
\hline
\textbf{Atributos Principales} & \texttt{vehicleId}, \texttt{readings} \\*
\hline
\textbf{Validación de Integridad} & Identificador vehicular obligatorio \texttt{@NotNull}, y colección de lecturas no vacía \texttt{@NotEmpty} con límite superior de cien elementos \texttt{@Size(min = 1, max = 100)}, validando cada elemento en cascada con \texttt{@Valid}. Cada lectura incluye marca temporal, coordenadas opcionales, velocidad acotada a trescientos cincuenta kilómetros por hora, temperatura de motor obligatoria entre menos cuarenta y ciento cincuenta grados Celsius, régimen de giro no negativo, voltaje y nivel de combustible. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Petición:} Register\allowbreak Vehicle\allowbreak Fault\allowbreak Request} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\*
\hline
\textbf{Atributos Principales} & \texttt{vehicleId}, \texttt{dtcCode}, \texttt{severity}, \texttt{description} \\*
\hline
\textbf{Validación de Integridad} & Identificador vehicular \texttt{@NotNull}, código de avería \texttt{@NotBlank} validado con expresión regular \texttt{@Pattern(regexp = "	extasciicircum [PCBU][0-9]\{4\}\$")} según la norma SAE J2012, severidad obligatoria no vacía y descripción opcional de hasta quinientos caracteres. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Petición:} Generate\allowbreak Health\allowbreak Report\allowbreak Request} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak requests} \\*
\hline
\textbf{Atributos Principales} & \texttt{daysToAnalyze}, \texttt{includeResolvedDtcHistory}, \texttt{triggerReason} \\*
\hline
\textbf{Validación de Integridad} & Ventana temporal de análisis restringida entre siete y noventa días con anotaciones \texttt{@Min(7)} y \texttt{@Max(90)}, indicador booleano de inclusión de historial resuelto y motivo contextual de generación. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Respuesta:} Obd2\allowbreak Device\allowbreak Response} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{tenantId}, \texttt{deviceIdentifier}, \texttt{connectionType}, \texttt{status}, \texttt{hardwareModel}, \texttt{firmwareVersion}, \texttt{createdAt} \\*
\hline
\textbf{Estructura y Serialización} & Encapsula los metadatos completos del hardware telemático denormalizando denominaciones de conectividad y estado operativo para clientes web y aplicaciones móviles. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Respuesta:} Device\allowbreak Installation\allowbreak Response} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{deviceId}, \texttt{vehicleId}, \texttt{tenantId}, \texttt{installedAt}, \texttt{uninstalledAt}, \texttt{initialOdometerKm}, \texttt{finalOdometerKm}, \texttt{isActive} \\*
\hline
\textbf{Estructura y Serialización} & Proyección inmutable de la sesión de montaje telemático con marcas temporales, odómetros de inicio y retiro, y bandera booleana de vigencia activa. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Respuesta:} Telemetry\allowbreak Ingestion\allowbreak Ack\allowbreak Response} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\*
\hline
\textbf{Atributos Principales} & \texttt{vehicleId}, \texttt{ingestedCount}, \texttt{anomalyDetected}, \texttt{alertMessage} \\*
\hline
\textbf{Estructura y Serialización} & Confirmación perimetral inmediata tras la persistencia por bloques en TimescaleDB, informando la cantidad de registros procesados y advertencias generadas en tiempo real. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Respuesta:} Vehicle\allowbreak Latest\allowbreak Telemetry\allowbreak Response} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\*
\hline
\textbf{Atributos Principales} & \texttt{vehicleId}, \texttt{timestamp}, \texttt{latitude}, \texttt{longitude}, \texttt{speedKmh}, \texttt{engineTempCelsius}, \texttt{engineRpm}, \texttt{batteryVoltage}, \texttt{fuelPercentage} \\*
\hline
\textbf{Estructura y Serialización} & Tacómetro digital proyectado para cuadros de instrumentos en tiempo real, omitiendo valores nulos para optimizar el consumo de ancho de banda móvil. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Respuesta:} Vehicle\allowbreak Fault\allowbreak Response} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{vehicleId}, \texttt{dtcCode}, \texttt{severity}, \texttt{description}, \texttt{detectedAt}, \texttt{isResolved}, \texttt{resolvedAt} \\*
\hline
\textbf{Estructura y Serialización} & Ficha de avería electrónica vehicular complementada con el estándar SAE J2012, marcas cronológicas de detección y estado formal de subsanación técnica. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Respuesta:} Predictive\allowbreak Alert\allowbreak Response} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{vehicleId}, \texttt{recommendedServiceId}, \texttt{alertType}, \texttt{confidenceScore}, \texttt{message}, \texttt{status}, \texttt{createdAt} \\*
\hline
\textbf{Estructura y Serialización} & Advertencia predictiva que vincula el vehículo con un servicio de mantenimiento sugerido, denormalizando la probabilidad de falla y el mensaje de orientación. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso REST de Respuesta:} Health\allowbreak Report\allowbreak Created\allowbreak Response} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.\allowbreak responses} \\*
\hline
\textbf{Atributos Principales} & \texttt{reportId}, \texttt{vehicleId}, \texttt{overallHealthScore}, \texttt{executiveSummary}, \texttt{totalRisksDetected}, \texttt{generatedAt}, \texttt{jsonResourceUrl}, \texttt{pdfDownloadUrl} \\*
\hline
\textbf{Estructura y Serialización} & Confirmación perimetral del dictamen emitido por el motor de inteligencia artificial, integrando métrica consolidada de salud, resumen ejecutivo y enlaces de descarga. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{DTO de Integración de Fachada:} Vehicle\allowbreak Latest\allowbreak Telemetry\allowbreak Dto} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak acl.\allowbreak dto} \\*
\hline
\textbf{Atributos Principales} & \texttt{vehicleId}, \texttt{timestamp}, \texttt{speedKmh}, \texttt{engineTempCelsius}, \texttt{engineRpm}, \texttt{batteryVoltage} \\*
\hline
\textbf{Estructura y Serialización} & Objeto inmutable de intercambio en memoria para abastecer a CRM y Workshop Operations (MRO) con la lectura instantánea vehicular sin dependencia de TimescaleDB. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{DTO de Integración de Fachada:} Active\allowbreak Vehicle\allowbreak Faults\allowbreak Dto} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak acl.\allowbreak dto} \\*
\hline
\textbf{Atributos Principales} & \texttt{faultId}, \texttt{dtcCode}, \texttt{severity}, \texttt{description}, \texttt{detectedAt} \\*
\hline
\textbf{Estructura y Serialización} & Objeto inmutable perimetral para precargar averías electrónicas activas en órdenes de trabajo de taller al momento de la recepción del vehículo en patio. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{DTO de Integración de Fachada:} Vehicle\allowbreak Telemetry\allowbreak Health\allowbreak Dto} \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak interfaces.\allowbreak acl.\allowbreak dto} \\*
\hline
\textbf{Atributos Principales} & \texttt{vehicleId}, \texttt{overallHealthScore}, \texttt{healthStatusTrafficLight}, \texttt{activeFaultCount}, \texttt{hasPendingPredictiveAlerts} \\*
\hline
\textbf{Estructura y Serialización} & Objeto inmutable de resumen que consolida la puntuación de salud de cero a cien, estado de semáforo automotriz y recuentos de anomalías para tableros de flota. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Recursos DTO inmutables de petición, respuesta y contratos de fachada con validación perimetral declarativa del Bounded Context IoT Telemetry \& Predictive Maintenance.

Para asegurar un desacoplamiento riguroso entre las estructuras de transferencia y el modelo táctico de dominio, la capa incorpora ensambladores dedicados de recursos:

- **Obd2DeviceResourceAssembler**: Transforma agregados de hardware hacia recursos de presentación e interpreta peticiones de alta para formular comandos transaccionales inyectando el taller correspondiente.

- **DeviceInstallationResourceAssembler**: Traduce el estado de las sesiones de montaje físico hacia contratos enriquecidos con métricas de kilometraje y gestiona la conversión de comandos de instalación y desinstalación.

- **TelemetryResourceAssembler**: Proyecta registros individuales hacia tacómetros en tiempo real, convierte lecturas continuas y formula comandos de ingestión en lote.

- **VehicleFaultResourceAssembler**: Cruza las fallas registradas con el catálogo estándar de diagnóstico automotriz para entregar recursos comprensibles para los técnicos de taller.

- **PredictiveAlertResourceAssembler**: Modela advertencias algorítmicas en recursos claros con índices de confianza y servicios recomendados para la toma de decisiones preventivas.

- **VehicleHealthReportResourceAssembler**: Transforma los dictámenes periciales generados por el motor de inteligencia artificial hacia contratos de respuesta enriquecidos con enlaces HATEOAS, y mapea peticiones perimetrales en comandos de generación analítica.

En la @tbl:iot-resource-assemblers se describen los ensambladores de recursos REST y los métodos de transformación bidireccional entre la capa perimetral y el dominio.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Ensambladores de Recursos REST de IoT Telemetry \& Predictive Maintenance} \label{tbl:iot-resource-assemblers} \\
\hline
\thfirst{Aspecto Ensamblador} & \thcell{Firma y Transformación de Tipos} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto Ensamblador} & \thcell{Firma y Transformación de Tipos} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador de Recursos:} Obd2\allowbreak Device\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{toResource(Obd2Device)} & Transforma el agregado Obd2Device en la respuesta Obd2DeviceResponse, desempaquetando identificadores fuertemente tipados DeviceId y normalizando estados operativos. \\*
\hline
\textbf{toCommand(RegisterDeviceRequest, UUID)} & Convierte la solicitud HTTP en el comando RegisterObd2DeviceCommand asociando el identificador del taller mecánico autenticado. \\*
\hline
\textbf{Responsabilidad} & Aísla los agregados de hardware de las representaciones de serialización perimetral de inventario técnico. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador de Recursos:} Device\allowbreak Installation\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{toResource(DeviceInstallation)} & Mapea la entidad DeviceInstallation hacia DeviceInstallationResponse proyectando marcas temporales, odómetros inicial y final, y estado de vigencia activa. \\*
\hline
\textbf{toInstallCommand(InstallDeviceRequest)} & Transforma la solicitud perimetral en InstallDeviceCommand extrayendo los identificadores UUID de escáner y vehículo. \\*
\hline
\textbf{toUninstallCommand(UUID, UninstallDeviceRequest)} & Transforma la petición en UninstallDeviceCommand verificando consistencia temporal y kilométrica del desmonte. \\*
\hline
\textbf{Responsabilidad} & Gobierna el mapeo bidireccional entre sesiones de montaje físico en vehículo y contratos de transporte perimetral. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador de Recursos:} Telemetry\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{toLatestResponse(TelemetryRecord)} & Mapea el registro más reciente de la serie temporal hacia VehicleLatestTelemetryResponse formateando magnitudes cinemáticas y térmicas para visualización en tacómetro digital. \\*
\hline
\textbf{toBatchCommand(TelemetryBatchRequest)} & Mapea el lote de lecturas sensoriales de transferencia hacia el comando IngestTelemetryBatchCommand validando marcas temporales no futuras. \\*
\hline
\textbf{Responsabilidad} & Desacopla la estructura física de series temporales en TimescaleDB de los formatos de transporte perimetral de baja latencia. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador de Recursos:} Vehicle\allowbreak Fault\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{toResource(VehicleFault, DtcCatalogEntry)} & Mapea la entidad VehicleFault complementándola con la descripción formal del catálogo oficial SAE J2012 para generar VehicleFaultResponse. \\*
\hline
\textbf{toCommand(RegisterVehicleFaultRequest)} & Construye RegisterVehicleFaultCommand a partir de la solicitud perimetral validando el formato formal del código DTC. \\*
\hline
\textbf{Responsabilidad} & Centraliza la conversión entre averías de computadoras de a bordo y fichas diagnósticas enriquecidas para el personal técnico. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador de Recursos:} Predictive\allowbreak Alert\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{toResource(PredictiveAlert)} & Transforma el agregado PredictiveAlert hacia PredictiveAlertResponse denormalizando puntuaciones de confianza y descripciones de servicio preventivo. \\*
\hline
\textbf{Responsabilidad} & Proyecta advertencias matemáticas de mantenimiento predictivo hacia representaciones claras para asesores de taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador de Recursos:} Vehicle\allowbreak Health\allowbreak Report\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{toCreatedResponse(report, vehicleId, jsonUrl, pdfUrl)} & Construye la respuesta HealthReportCreatedResponse proveyendo el identificador generado, índice consolidado y las rutas canónicas de consulta REST y descarga PDF. \\*
\hline
\textbf{toGenerateCommand(vehicleId, request)} & Mapea la petición perimetral hacia GenerateVehicleHealthReportCommand aplicando valores por defecto para ventana temporal e historial de averías. \\*
\hline
\textbf{Responsabilidad} & Desacopla la estructura analítica generada por el motor de inteligencia artificial de las representaciones de serialización y enlace perimetral. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Ensambladores de recursos REST y métodos de transformación bidireccional ubicados en interfaces.rest.transform de IoT Telemetry \& Predictive Maintenance.

La integración sincrónica intermodular se canaliza a través de la Fachada de Contexto Abierto **IoTTelemetryContextFacade**. Este componente actúa como una capa de prevención de corrupción ante los módulos consumidores de la plataforma, evitando que la complejidad de las tramas sensoriales o la tecnología de base de datos de series temporales trascienda hacia el resto del sistema.

En la @tbl:iot-facade-methods se presentan las firmas públicas, tipos de retorno, módulos clientes y propósitos arquitectónicos de la fachada de contexto abierto.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Métodos Públicos de la Fachada Inbound OHS IoTTelemetryContextFacade} \label{tbl:iot-facade-methods} \\
\hline
\thfirst{Firma del Método} & \thcell{Contrato, Retorno y Módulos Consumidores} \\
\hline
\endfirsthead
\hline
\thfirst{Firma del Método} & \thcell{Contrato, Retorno y Módulos Consumidores} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método OHS:} getVehicle\allowbreak Latest\allowbreak Telemetry(VehicleId vehicleId)} \\*
\hline
\textbf{Tipo de Retorno} & \texttt{Optional<Vehicle\allowbreak Latest\allowbreak Telemetry\allowbreak Dto>} \\*
\hline
\textbf{Módulos Consumidores} & Customer and Fleet Management (CRM), Workshop Operations (MRO) \\*
\hline
\textbf{Propósito y Efecto} & Provee la última lectura cinemática y térmica registrada del vehículo incluyendo velocidad, temperatura de motor, régimen de giro y voltaje de batería. Permite a los asesores de servicio visualizar el estado operativo instantáneo en el mostrador del taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método OHS:} getActive\allowbreak Faults\allowbreak ForVehicle(VehicleId vehicleId)} \\*
\hline
\textbf{Tipo de Retorno} & \texttt{List<Active\allowbreak Vehicle\allowbreak Faults\allowbreak Dto>} \\*
\hline
\textbf{Módulos Consumidores} & Workshop Operations (MRO) \\*
\hline
\textbf{Propósito y Efecto} & Recupera la lista de averías electrónicas activas y códigos DTC no subsanados registrados en la computadora de a bordo. Se invoca automáticamente al aperturar una Orden de Trabajo precargando los hallazgos mecánicos para inspección en foso. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método OHS:} hasActive\allowbreak Device\allowbreak Installation(VehicleId vehicleId)} \\*
\hline
\textbf{Tipo de Retorno} & \texttt{boolean} \\*
\hline
\textbf{Módulos Consumidores} & Customer and Fleet Management (CRM), Mobile Workshop Gateway \\*
\hline
\textbf{Propósito y Efecto} & Verifica si el vehículo dispone de un escáner OBD-II enlazado y transmitiendo en tiempo real. Habilita o restringe en la interfaz de usuario del conductor las funciones de monitoreo remoto y tacómetro digital continuo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método OHS:} getVehicle\allowbreak Telemetry\allowbreak Health(VehicleId vehicleId)} \\*
\hline
\textbf{Tipo de Retorno} & \texttt{Vehicle\allowbreak Telemetry\allowbreak Health\allowbreak Dto} \\*
\hline
\textbf{Módulos Consumidores} & Customer and Fleet Management (CRM) \\*
\hline
\textbf{Propósito y Efecto} & Provee el diagnóstico global de salud mecánica consolidando el índice numérico de cero a cien, el indicador semafórico, el conteo de averías activas y la existencia de alertas predictivas pendientes para cuadros de mando de flotas. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación formal de los métodos públicos expuestos por la Fachada Inbound OHS IoTTelemetryContextFacade.

La propagación de eventos asíncronos garantiza la sincronización eventual del ecosistema automotriz ante contingencias de telemetría y cambios en la vida operativa de los vehículos:

- **Eventos Publicados**: Notifican a los contextos de CRM y MRO la detección de anomalías críticas, la generación de oportunidades de servicio preventivo, el registro de códigos de falla y la disponibilidad de nuevos reportes de salud mecánica con inteligencia artificial.

- **Eventos Consumidos**: Escuchan instrucciones de baja vehicular, transferencia de dominio y culminación de reparaciones para actualizar de manera autónoma las sesiones telemáticas y el estatus de las averías.

En la @tbl:iot-integration-events se sintetiza la taxonomía de eventos de integración intermodulares, especificando sus cargas útiles y los efectos arquitectónicos derivados en la plataforma.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Taxonomía de Eventos de Integración de IoT Telemetry \& Predictive Maintenance} \label{tbl:iot-integration-events} \\
\hline
\thfirst{Aspecto de Integración} & \thcell{Carga Útil y Sincronización Intermodular} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Integración} & \thcell{Carga Útil y Sincronización Intermodular} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} Vehicle\allowbreak Anomaly\allowbreak Detected\allowbreak Integration\allowbreak Event \quad (\textit{Tipo:} Publicado)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{vehicleId}, \texttt{anomalyType}, \texttt{severity}, \texttt{measuredValue}, \texttt{thresholdValue}, \texttt{detectedAt}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Customer and Fleet Management (CRM), Pasarela de Notificaciones Push FCM \\*
\hline
\textbf{Efecto Arquitectónico} & Dispara alertas tempranas de riesgo mecánico crítico hacia el conductor y habilita al asesor comercial para contactar al cliente con propuesta prioritaria de inspección. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} Predictive\allowbreak Alert\allowbreak Generated\allowbreak Integration\allowbreak Event \quad (\textit{Tipo:} Publicado)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{alertId}, \texttt{vehicleId}, \texttt{recommendedServiceId}, \texttt{confidenceScore}, \texttt{alertType}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Workshop Operations (MRO), Customer and Fleet Management (CRM) \\*
\hline
\textbf{Efecto Arquitectónico} & Preconfigura borradores de órdenes de trabajo y presupuestos de mantenimiento en el taller mecánico antes de que el cliente ingrese a las instalaciones. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} Vehicle\allowbreak Fault\allowbreak Logged\allowbreak Integration\allowbreak Event \quad (\textit{Tipo:} Publicado)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{faultId}, \texttt{vehicleId}, \texttt{dtcCode}, \texttt{severity}, \texttt{ecuSystem}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Workshop Operations (MRO) \\*
\hline
\textbf{Efecto Arquitectónico} & Asienta de inmediato el código de diagnóstico en el historial clínico automotriz precargando tareas de foso en el módulo operativo del taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} Vehicle\allowbreak Health\allowbreak Report\allowbreak Generated\allowbreak Integration\allowbreak Event \quad (\textit{Tipo:} Publicado)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{reportId}, \texttt{vehicleId}, \texttt{overallHealthScore}, \texttt{totalRisksDetected}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Workshop Operations (MRO), Customer and Fleet Management (CRM) \\*
\hline
\textbf{Efecto Arquitectónico} & Notifica la culminación de la inferencia diagnóstica con inteligencia artificial y la disponibilidad del informe consolidado de salud mecánica y dictamen pericial descargable. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} Vehicle\allowbreak Decommissioned\allowbreak Integration\allowbreak Event \quad (\textit{Tipo:} Consumido)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{vehicleId}, \texttt{tenantId}, \texttt{reason}, \texttt{decommissionedAt}, \texttt{occurredOn} \\*
\hline
\textbf{Módulo Emisor} & Customer and Fleet Management (CRM) \\*
\hline
\textbf{Efecto Arquitectónico} & Finaliza automáticamente cualquier sesión activa de escáner en el vehículo dado de baja definitiva liberando el hardware para nuevo montaje en taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} Vehicle\allowbreak Ownership\allowbreak Transferred\allowbreak Integration\allowbreak Event \quad (\textit{Tipo:} Consumido)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{vehicleId}, \texttt{previousOwnerId}, \texttt{newOwnerId}, \texttt{transferredAt}, \texttt{occurredOn} \\*
\hline
\textbf{Módulo Emisor} & Customer and Fleet Management (CRM) \\*
\hline
\textbf{Efecto Arquitectónico} & Concluye la instalación telemática actual preservando la privacidad del propietario saliente y reinicia las líneas base estadísticas del vehículo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} Work\allowbreak Order\allowbreak Completed\allowbreak Integration\allowbreak Event \quad (\textit{Tipo:} Consumido)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{vehicleId}, \texttt{repairedSystems}, \texttt{completedAt}, \texttt{occurredOn} \\*
\hline
\textbf{Módulo Emisor} & Workshop Operations (MRO) \\*
\hline
\textbf{Efecto Arquitectónico} & Marca de manera automática como resueltas todas las fallas electrónicas DTC asociadas a los subsistemas automotrices reparados en taller. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Taxonomía de eventos de integración asíncronos publicados en interfaces.events y consumidos por IoT Telemetry \& Predictive Maintenance.

El diseño perimetral de la Capa de Interfaz de IoT Telemetry & Predictive Maintenance asegura el aislamiento absoluto entre el flujo continuo de señales automotrices y las transacciones de gestión operativa del taller mecánico. Al implementar controladores independientes y una ingestión asíncrona con acuse de recibo inmediato, el sistema impide que ráfagas de telemetría de cientos de vehículos conectados degraden los tiempos de respuesta de la facturación, los contratos de suscripción o las agendas de mantenimiento.

Asimismo, la arquitectura perimetral satisface con solvencia las restricciones de conectividad intermitente propias de vehículos en ruta y zonas con cobertura limitada. Al aceptar lotes telemáticos consolidados por pasarelas móviles locales y someterlos a validaciones declarativas rigurosas antes de su persistencia en TimescaleDB, la plataforma conjuga una alta resiliencia operativa en el borde con una defensa hermética frente a lecturas físicas espurias o tramas corruptas de bus CAN.

Finalmente, la articulación de la Fachada de Contexto Abierto con la taxonomía de eventos de integración garantiza una colaboración fluida y proactiva con los módulos de CRM y MRO. Las fallas electrónicas y advertencias predictivas se traducen automáticamente en cotizaciones preventivas y precargas diagnósticas en las órdenes de trabajo de foso, transformando los datos cinemáticos en valor comercial tangible y fidelización técnica para el taller sin generar dependencias acopladas entre subsistemas.

#### 2.6.9.3. Application Layer

La Capa de Aplicación del Bounded Context IoT Telemetry & Predictive Maintenance opera bajo el paquete canónico **com.andeva.atelier.platform.iot.application**. Su responsabilidad medular consiste en gobernar los flujos de negocio automotrices articulando las estaciones web de mostrador de servicio, las pasarelas móviles Android e iOS en campo y los módems celulares en vehículos. Esta orquestación coordina la persistencia de hardware y sesiones de montaje, la ingesta masiva de series temporales cinemáticas y térmicas, la inferencia analítica de anomalías y la propagación de advertencias preventivas hacia los demás contextos de la plataforma.

Para gestionar las altas demandas de concurrencia y volumen de datos de los vehículos conectados sin comprometer la consistencia del dominio, la capa se fundamenta en cuatro directrices de ingeniería:

- **Segregación categórica de responsabilidades mediante el patrón CQRS:** Separación estricta entre los servicios de comandos responsables de mutar el estado y los servicios de consultas optimizados para lectura analítica sobre hipertablas de TimescaleDB, eliminando la contención de bloqueos relacionales.

- **Orquestación transaccional de ingesta en bloque y evaluación analítica:** Procesamiento eficiente de ráfagas sensoriales mediante inserciones masivas por lotes acopladas con la evaluación inmediata de anomalías físicas por el motor de inferencia, garantizando tiempos de respuesta mínimos.

- **Sincronización reactiva intermodular desacoplada:** Despacho de notificaciones y publicación de eventos de integración supeditados a la confirmación exitosa de las transacciones de base de datos, evitando falsos positivos y asegurando coherencia eventual en el ecosistema.

- **Blindaje y aislamiento mediante Capas Anticorrupción:** Mediación sistemática frente a bibliotecas de terceros y contextos satélites a través de interfaces especializadas que encapsulan el SDK de Firebase Admin, los contratos de mantenimiento de taller y la conectividad JDBC de alto rendimiento.

En la @tbl:iot-application-types se expone el catálogo taxonómico consolidado de los componentes tácticos que integran la Capa de Aplicación de IoT Telemetry & Predictive Maintenance, detallando sus categorías, paquetes canónicos y propósitos arquitectónicos.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo Consolidado de la Capa de Aplicación de IoT Telemetry \& Predictive Maintenance} \label{tbl:iot-application-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endhead
Device\allowbreak Installation\allowbreak Command\allowbreak Service & Define los casos de uso transaccionales para la vinculación física de escáneres OBD-II a unidades vehiculares y el desmonte documentado de hardware. \\*
\hline
\textbf{Categoría} & Servicio de Comando (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por DeviceInstallationCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Device\allowbreak Installation\allowbreak Command\allowbreak Service\allowbreak Impl & Orquesta el ciclo de vinculación física, montaje y desmonte de escáneres en automóviles, validando consistencia de odómetros y exclusividad de sesiones. \\*
\hline
\textbf{Categoría} & Servicio de Comando (Implementación) \\*
\hline
\textbf{Relaciones} & Implementa DeviceInstallationCommandService. Invoca DeviceInstallationRepository y Obd2DeviceRepository. Publica eventos de dominio. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak internal.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Obd2\allowbreak Device\allowbreak Command\allowbreak Service & Define los contratos de escritura para la incorporación de dispositivos de telemetría y actualización del estado operativo de inventario. \\*
\hline
\textbf{Categoría} & Servicio de Comando (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por Obd2DeviceCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Obd2\allowbreak Device\allowbreak Command\allowbreak Service\allowbreak Impl & Gobierna el alta de escáneres telemáticos en el inventario del taller y la alternancia de estados de disponibilidad física. \\*
\hline
\textbf{Categoría} & Servicio de Comando (Implementación) \\*
\hline
\textbf{Relaciones} & Implementa Obd2DeviceCommandService. Invoca Obd2DeviceRepository y valida la unicidad de identificadores físicos MAC o IMEI celular. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak internal.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Predictive\allowbreak Alert\allowbreak Command\allowbreak Service & Define los casos de uso para generación analítica, confirmación de lectura, descarte y conversión de alertas predictivas. \\*
\hline
\textbf{Categoría} & Servicio de Comando (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por PredictiveAlertCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Predictive\allowbreak Alert\allowbreak Command\allowbreak Service\allowbreak Impl & Administra el ciclo operativo de advertencias preventivas, confirmación de lectura por asesores y descarte justificado de recomendaciones mecánicas. \\*
\hline
\textbf{Categoría} & Servicio de Comando (Implementación) \\*
\hline
\textbf{Relaciones} & Implementa PredictiveAlertCommandService. Invoca PredictiveAlertRepository y OperationsAclPort. Emite eventos de integración hacia CRM y MRO. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak internal.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Telemetry\allowbreak Ingestion\allowbreak Command\allowbreak Service & Define el contrato transaccional para la ingesta en lote de series temporales telemáticas y disparo de análisis de anomalías en tiempo real. \\*
\hline
\textbf{Categoría} & Servicio de Comando (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por TelemetryIngestionCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Telemetry\allowbreak Ingestion\allowbreak Command\allowbreak Service\allowbreak Impl & Orquesta la persistencia masiva en lote de lecturas sensoriales en TimescaleDB y activa en tiempo real el motor analítico de detección de anomalías predictivas. \\*
\hline
\textbf{Categoría} & Servicio de Comando (Implementación) \\*
\hline
\textbf{Relaciones} & Implementa TelemetryIngestionCommandService. Invoca DeviceInstallationRepository, TelemetryLogRepository, PredictiveAnomalyDetectionEngine, OperationsAclPort y FcmNotificationAclPort. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak internal.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Fault\allowbreak Command\allowbreak Service & Define los casos de uso transaccionales para el registro de averías electrónicas automotrices y su resolución técnica en taller. \\*
\hline
\textbf{Categoría} & Servicio de Comando (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por VehicleFaultCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Fault\allowbreak Command\allowbreak Service\allowbreak Impl & Registra averías electrónicas automotrices según la norma SAE J2012 y asienta su subsanación formal tras la reparación en taller. \\*
\hline
\textbf{Categoría} & Servicio de Comando (Implementación) \\*
\hline
\textbf{Relaciones} & Implementa VehicleFaultCommandService. Invoca VehicleFaultRepository, DtcCatalogRepository y DtcCodeEvaluationService. Publica eventos de dominio e integración. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak internal.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Health\allowbreak Report\allowbreak Command\allowbreak Service & Define las operaciones para la inferencia diagnóstica con inteligencia artificial estructurada y encolamiento por lotes de flotas. \\*
\hline
\textbf{Categoría} & Servicio de Comando (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por VehicleHealthReportCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Health\allowbreak Report\allowbreak Command\allowbreak Service\allowbreak Impl & Coordina la generación analítica de informes periciales con inteligencia artificial estructurada y persiste alertas de alta certeza. \\*
\hline
\textbf{Categoría} & Servicio de Comando (Implementación) \\*
\hline
\textbf{Relaciones} & Implementa VehicleHealthReportCommandService. Invoca AiInferenceDiagnosticPort, PredictiveAlertRepository y DomainEventPublisher. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak internal.\allowbreak commandservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Device\allowbreak Installation\allowbreak Query\allowbreak Service & Define los métodos de consulta para instalaciones telemáticas vigentes y trazabilidad histórica de montajes por vehículo. \\*
\hline
\textbf{Categoría} & Servicio de Consulta (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por DeviceInstallationQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak queryservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Device\allowbreak Installation\allowbreak Query\allowbreak Service\allowbreak Impl & Consulta la sesión de instalación actualmente activa y la trazabilidad de montajes previos de una unidad vehicular. \\*
\hline
\textbf{Categoría} & Servicio de Consulta (Implementación) \\*
\hline
\textbf{Relaciones} & Implementa DeviceInstallationQueryService. Consulta DeviceInstallationRepository con transaccionalidad de solo lectura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak internal.\allowbreak queryservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Obd2\allowbreak Device\allowbreak Query\allowbreak Service & Define consultas paginadas del inventario de hardware telemático y filtrado de escáneres disponibles para asignación. \\*
\hline
\textbf{Categoría} & Servicio de Consulta (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por Obd2DeviceQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak queryservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Obd2\allowbreak Device\allowbreak Query\allowbreak Service\allowbreak Impl & Provee lecturas paginadas del inventario de hardware telemático y filtra dispositivos disponibles para instalación. \\*
\hline
\textbf{Categoría} & Servicio de Consulta (Implementación) \\*
\hline
\textbf{Relaciones} & Implementa Obd2DeviceQueryService. Consulta Obd2DeviceRepository mediante Spring Data con paginación Pageable. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak internal.\allowbreak queryservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Predictive\allowbreak Alert\allowbreak Query\allowbreak Service & Define las consultas para tableros de control predictivo por taller automotriz e historial preventivo por unidad. \\*
\hline
\textbf{Categoría} & Servicio de Consulta (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por PredictiveAlertQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak queryservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Predictive\allowbreak Alert\allowbreak Query\allowbreak Service\allowbreak Impl & Resuelve tableros de oportunidades preventivas de taller mecánico y el registro histórico de advertencias emitidas. \\*
\hline
\textbf{Categoría} & Servicio de Consulta (Implementación) \\*
\hline
\textbf{Relaciones} & Implementa PredictiveAlertQueryService. Consulta PredictiveAlertRepository con filtros de severidad y estado. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak internal.\allowbreak queryservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Telemetry\allowbreak Log\allowbreak Query\allowbreak Service & Define consultas para lecturas de tacómetro en tiempo real y agregaciones analíticas de series temporales en cubos temporales. \\*
\hline
\textbf{Categoría} & Servicio de Consulta (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por TelemetryLogQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak queryservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Telemetry\allowbreak Log\allowbreak Query\allowbreak Service\allowbreak Impl & Provee lecturas de tacómetro en tiempo real y calcula promedios históricos mediante funciones de hipertabla time\_bucket de TimescaleDB. \\*
\hline
\textbf{Categoría} & Servicio de Consulta (Implementación) \\*
\hline
\textbf{Relaciones} & Implementa TelemetryLogQueryService. Consulta TelemetryLogRepository con transaccionalidad de solo lectura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak internal.\allowbreak queryservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Fault\allowbreak Query\allowbreak Service & Define las consultas para averías electrónicas activas no resueltas e historial clínico integral de diagnósticos por unidad. \\*
\hline
\textbf{Categoría} & Servicio de Consulta (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por VehicleFaultQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak queryservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Fault\allowbreak Query\allowbreak Service\allowbreak Impl & Resuelve consultas de códigos DTC activos y el historial clínico de diagnósticos electrónicos del automóvil. \\*
\hline
\textbf{Categoría} & Servicio de Consulta (Implementación) \\*
\hline
\textbf{Relaciones} & Implementa VehicleFaultQueryService. Consulta VehicleFaultRepository optimizando lecturas de averías no subsanadas. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak internal.\allowbreak queryservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Health\allowbreak Report\allowbreak Query\allowbreak Service & Define las consultas para recuperación del último informe pericial de salud vehicular y exportación documental en formato PDF. \\*
\hline
\textbf{Categoría} & Servicio de Consulta (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por VehicleHealthReportQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak queryservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Health\allowbreak Report\allowbreak Query\allowbreak Service\allowbreak Impl & Resuelve consultas del último dictamen de salud y coordina la compilación del documento pericial en formato PDF. \\*
\hline
\textbf{Categoría} & Servicio de Consulta (Implementación) \\*
\hline
\textbf{Relaciones} & Implementa VehicleHealthReportQueryService. Invoca VehicleHealthReportPdfGeneratorPort y repositorios telemáticos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak internal.\allowbreak queryservices} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
IoT\allowbreak Transactional\allowbreak Outbox\allowbreak Publisher & Garantiza la entrega at-least-once y consistencia eventual persistiendo eventos de dominio localmente dentro de la misma transacción de PostgreSQL 16. \\*
\hline
\textbf{Categoría} & Manejador de Eventos \\*
\hline
\textbf{Relaciones} & Intercepta eventos de dominio y persiste mensajes atómicamente en la tabla relacional outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak internal.\allowbreak eventhandlers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Predictive\allowbreak Alert\allowbreak Domain\allowbreak Event\allowbreak Handler & Publica eventos de integración hacia CRM y MRO ante la generación formal de advertencias predictivas. \\*
\hline
\textbf{Categoría} & Manejador de Eventos \\*
\hline
\textbf{Relaciones} & Escucha PredictiveAlertGeneratedEvent y PredictiveAlertDismissedEvent propagando efectos intermodulares. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak internal.\allowbreak eventhandlers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Telemetry\allowbreak Domain\allowbreak Event\allowbreak Handler & Despacha de forma asíncrona notificaciones push críticas ante anomalías severas de motor hacia conductores y talleres mecánicos. \\*
\hline
\textbf{Categoría} & Manejador de Eventos \\*
\hline
\textbf{Relaciones} & Escucha CriticalEngineAnomalyDetectedEvent en fase posterior al commit invocando FcmNotificationAclPort. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak internal.\allowbreak eventhandlers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Fault\allowbreak Domain\allowbreak Event\allowbreak Handler & Publica eventos de integración hacia MRO ante el asentamiento de nuevos códigos DTC en la computadora vehicular. \\*
\hline
\textbf{Categoría} & Manejador de Eventos \\*
\hline
\textbf{Relaciones} & Escucha VehicleFaultDetectedEvent y VehicleFaultResolvedEvent sincronizando el historial clínico automotriz. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak internal.\allowbreak eventhandlers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Lifecycle\allowbreak Integration\allowbreak Event\allowbreak Handler & Consume eventos intermodulares para desconectar escáneres en unidades dadas de baja y resolver fallas reparadas en taller. \\*
\hline
\textbf{Categoría} & Manejador de Eventos \\*
\hline
\textbf{Relaciones} & Suscriptor de VehicleDecommissionedIntegrationEvent, VehicleOwnershipTransferredIntegrationEvent y WorkOrderCompletedIntegrationEvent. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak internal.\allowbreak eventhandlers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Ai\allowbreak Inference\allowbreak Diagnostic\allowbreak Port & Define el contrato perimetral para solicitar inferencias diagnósticas periciales estructuradas a modelos de lenguaje avanzados. \\*
\hline
\textbf{Categoría} & Puerto de Salida ACL \\*
\hline
\textbf{Relaciones} & Implementado por GroqAiInferenceAdapter en la Capa de Infraestructura mediante Spring AI ChatClient y Groq LPU. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak internal.\allowbreak outbound.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Crm\allowbreak Fleet\allowbreak Acl\allowbreak Port & Capa Anticorrupción que consulta en CRM los datos de contacto, tokens de notificación y titulares de flotas vehiculares. \\*
\hline
\textbf{Categoría} & Puerto de Salida ACL \\*
\hline
\textbf{Relaciones} & Implementado por CrmFleetAclAdapter consumiendo la fachada pública Inbound OHS de Customer and Fleet Management CRM. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak internal.\allowbreak outbound.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Fcm\allowbreak Notification\allowbreak Acl\allowbreak Port & Capa Anticorrupción que encapsula el SDK de Firebase Cloud Messaging para estructurar mensajes push de alta prioridad en ruta. \\*
\hline
\textbf{Categoría} & Puerto de Salida ACL \\*
\hline
\textbf{Relaciones} & Implementado por FirebaseNotificationGateway en la Capa de Infraestructura mediante el SDK oficial de Firebase Admin. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak internal.\allowbreak outbound.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Operations\allowbreak Acl\allowbreak Port & Capa Anticorrupción que consulta en MRO los servicios recomendados del catálogo de taller y canaliza pre-órdenes de trabajo. \\*
\hline
\textbf{Categoría} & Puerto de Salida ACL \\*
\hline
\textbf{Relaciones} & Implementado por OperationsAclAdapter consumiendo la fachada pública Inbound OHS de Workshop Operations MRO. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak internal.\allowbreak outbound.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Timescale\allowbreak Batch\allowbreak Jdbc\allowbreak Client\allowbreak Port & Puerto de persistencia masiva de alto rendimiento para inserción en bloque de series temporales en hipertablas de TimescaleDB. \\*
\hline
\textbf{Categoría} & Puerto de Salida ACL \\*
\hline
\textbf{Relaciones} & Implementado por TimescaleTelemetryRepositoryImpl en la Capa de Infraestructura mediante inserciones JDBC masivas. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak internal.\allowbreak outbound.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Health\allowbreak Report\allowbreak Pdf\allowbreak Generator\allowbreak Port & Puerto de salida perimetral que define el contrato de renderizado y exportación tipográfica del dictamen de salud en binario PDF. \\*
\hline
\textbf{Categoría} & Puerto de Salida ACL \\*
\hline
\textbf{Relaciones} & Implementado por VehicleHealthReportPdfGeneratorAdapter en la Capa de Infraestructura mediante Thymeleaf y OpenPDF. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak internal.\allowbreak outbound.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
IoT\allowbreak Telemetry\allowbreak Context\allowbreak Facade\allowbreak Impl & Materializa el contrato Inbound OHS proveyendo lecturas telemáticas consolidadas, fallas activas y salud vehicular hacia otros contextos. \\*
\hline
\textbf{Categoría} & Implementación de Fachada de Contexto Abierto \\*
\hline
\textbf{Relaciones} & Implementa la interfaz pública IoTTelemetryContextFacade de la Capa de Interfaz coordinando repositorios del dominio. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iot.\allowbreak application.\allowbreak acl} \\
\hline
\end{longtable}
*Nota.* Catálogo taxonómico de tipos de la Capa de Aplicación, organizados en los subpaquetes canónicos commandservices, internal.commandservices, queryservices, internal.queryservices, internal.eventhandlers, internal.outbound.acl y acl.

**Servicios de Comandos y Flujos Transaccionales**

Los servicios de comandos constituyen el núcleo orquestador del lado de escritura del subsistema telemático. Cada componente encapsula un caso de uso transaccional gobernando la carga de entidades desde los repositorios, la invocación de métodos de dominio y la persistencia de cambios:

- **TelemetryIngestionCommandServiceImpl**: Valida la existencia de sesiones de montaje vigentes, transforma las lecturas recibidas en agregados inmutables y delega la inserción masiva en bloque sobre TimescaleDB. Asimismo, evalúa la lectura más reciente en el motor analítico de anomalías, registrando alertas preventivas y gatillando alertas de alta prioridad hacia conductores y mecánicos cuando se detectan desvíos críticos.

- **DeviceInstallationCommandServiceImpl**: Controla la vinculación física de escáneres OBD-II con automóviles garantizando que no coexistan instalaciones duplicadas activas, y asienta la desvinculación formal registrando el kilometraje acumulado de odómetro.

- **PredictiveAlertCommandServiceImpl**: Conduce el ciclo operativo de las advertencias preventivas, gestionando la confirmación de lectura por el personal técnico, el descarte documentado y la conversión de advertencias en solicitudes de citas de taller.

- **Obd2DeviceCommandServiceImpl**: Supervisa el alta de escáneres en el inventario del taller fiscalizando la unicidad física de identificadores MAC o IMEI celular y actualizando estados de disponibilidad.

- **VehicleFaultCommandServiceImpl**: Canaliza el registro de averías electrónicas bajo la norma SAE J2012 y certifica la corrección formal de fallas tras la culminación de reparaciones en foso.

- **VehicleHealthReportCommandServiceImpl**: Coordina la extracción analítica de telemetría y averías electrónicas, invoca el servicio de inferencia de inteligencia artificial estructurada, persiste alertas preventivas de alta certeza y despacha eventos de integración para flujos de taller.

En la @tbl:iot-command-services se detallan las operaciones transaccionales, signaturas, comandos de entrada y consecuencias en el modelo de dominio de los seis servicios de comandos.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Operaciones Transaccionales de los Servicios de Comandos de IoT Telemetry \& Predictive Maintenance} \label{tbl:iot-command-services} \\
\hline
\thfirst{Comando de Entrada} & \thcell{Firma, Retorno y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Comando de Entrada} & \thcell{Firma, Retorno y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Comandos:} Telemetry\allowbreak Ingestion\allowbreak Command\allowbreak Service\allowbreak Impl} \\*
\hline
\textbf{Comando:} \texttt{Ingest\allowbreak Telemetry\allowbreak Batch\allowbreak Command} & \texttt{handle(IngestTelemetryBatchCommand)} → \texttt{int} \\*
\hline
\textbf{Parámetros Principales} & \texttt{UUID vehicleId, List<TelemetryReadingItemDto> readings} \\*
\hline
\textbf{Reglas y Transaccionalidad} & Valida que el vehículo mantenga una sesión de montaje activa en DeviceInstallationRepository. Transforma lecturas en agregados inmutables TelemetryRecord y persiste masivamente en bloque JDBC sobre la Hipertabla telemetry\_logs de TimescaleDB mediante TimescaleBatchJdbcClientPort. Evalúa la lectura más reciente en PredictiveAnomalyDetectionEngine. Si se detecta anomalía crítica consulta servicios recomendados en OperationsAclPort, persiste PredictiveAlert, despacha notificación push FCM vía FcmNotificationAclPort y emite CriticalEngineAnomalyDetectedEvent. Anotado con \texttt{@Transactional}. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Comandos:} Device\allowbreak Installation\allowbreak Command\allowbreak Service\allowbreak Impl} \\*
\hline
\textbf{Comando:} \texttt{Install\allowbreak Device\allowbreak On\allowbreak Vehicle\allowbreak Command} & \texttt{handle(InstallDeviceOnVehicleCommand)} → \texttt{UUID} \\*
\hline
\textbf{Parámetros Principales} & \texttt{UUID deviceId, UUID vehicleId, int currentOdometerKm} \\*
\hline
\textbf{Reglas y Transaccionalidad} & Verifica que el escáner se encuentre en estado AVAILABLE y que el vehículo no cuente con otra instalación activa en curso. Instancia el agregado DeviceInstallation con odómetro inicial, transiciona el hardware a estado INSTALLED y persiste la sesión emitiendo DeviceInstalledOnVehicleEvent. Anotado con \texttt{@Transactional}. \\
\hline
\textbf{Comando:} \texttt{Uninstall\allowbreak Device\allowbreak Command} & \texttt{handle(UninstallDeviceCommand)} → \texttt{void} \\*
\hline
\textbf{Parámetros Principales} & \texttt{UUID installationId, int finalOdometerKm, Instant uninstalledTimestamp} \\*
\hline
\textbf{Reglas y Transaccionalidad} & Localiza la sesión de montaje activa, valida que el odómetro final no sea inferior al inicial, concluye la sesión con marca temporal y reintegra el escáner a estado AVAILABLE emitiendo DeviceUninstalledFromVehicleEvent. Anotado con \texttt{@Transactional}. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Comandos:} Predictive\allowbreak Alert\allowbreak Command\allowbreak Service\allowbreak Impl} \\*
\hline
\textbf{Comando:} \texttt{Generate\allowbreak Predictive\allowbreak Alert\allowbreak Command} & \texttt{handle(GeneratePredictiveAlertCommand)} → \texttt{UUID} \\*
\hline
\textbf{Parámetros Principales} & \texttt{UUID vehicleId, UUID recommendedServiceId, String alertType, BigDecimal confidenceScore, String message} \\*
\hline
\textbf{Reglas y Transaccionalidad} & Instancia el agregado PredictiveAlert en estado ACTIVE vinculando la recomendación preventiva emitida por MRO mediante OperationsAclPort. Persiste la alerta en base de datos relacional y publica PredictiveAlertGeneratedIntegrationEvent. Anotado con \texttt{@Transactional}. \\
\hline
\textbf{Comando:} \texttt{Acknowledge\allowbreak Predictive\allowbreak Alert\allowbreak Command} & \texttt{handle(AcknowledgePredictiveAlertCommand)} → \texttt{void} \\*
\hline
\textbf{Parámetros Principales} & \texttt{UUID alertId, UUID staffId} \\*
\hline
\textbf{Reglas y Transaccionalidad} & Localiza la advertencia en PredictiveAlertRepository y transiciona su estado a ACKNOWLEDGED registrando el asesor técnico responsable de la revisión y publicando PredictiveAlertAcknowledgedEvent. Anotado con \texttt{@Transactional}. \\
\hline
\textbf{Comando:} \texttt{Dismiss\allowbreak Predictive\allowbreak Alert\allowbreak Command} & \texttt{handle(DismissPredictiveAlertCommand)} → \texttt{void} \\*
\hline
\textbf{Parámetros Principales} & \texttt{UUID alertId, String dismissalReason, UUID staffId} \\*
\hline
\textbf{Reglas y Transaccionalidad} & Exige justificación técnica obligatoria, transiciona el estado de la alerta a DISMISSED y emite PredictiveAlertDismissedEvent para retroalimentación analítica. Anotado con \texttt{@Transactional}. \\
\hline
\textbf{Comando:} \texttt{Convert\allowbreak Alert\allowbreak To\allowbreak Appointment\allowbreak Command} & \texttt{handle(ConvertAlertToAppointmentCommand)} → \texttt{UUID} \\*
\hline
\textbf{Parámetros Principales} & \texttt{UUID alertId, Instant preferredDate} \\*
\hline
\textbf{Reglas y Transaccionalidad} & Invoca a OperationsAclPort para formular una pre-orden de trabajo y agendar una inspección técnica en MRO asociando la cotización preventiva. Anotado con \texttt{@Transactional}. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Comandos:} Obd2\allowbreak Device\allowbreak Command\allowbreak Service\allowbreak Impl} \\*
\hline
\textbf{Comando:} \texttt{Register\allowbreak Obd2\allowbreak Device\allowbreak Command} & \texttt{handle(RegisterObd2DeviceCommand)} → \texttt{UUID} \\*
\hline
\textbf{Parámetros Principales} & \texttt{UUID tenantId, String deviceIdentifier, String connectionType, String hardwareModel, String firmwareVersion} \\*
\hline
\textbf{Reglas y Transaccionalidad} & Comprueba en Obd2DeviceRepository que el identificador MAC o IMEI no se encuentre registrado previamente. Crea el agregado Obd2Device en estado AVAILABLE, lo persiste en PostgreSQL 16 y emite Obd2DeviceRegisteredEvent. Anotado con \texttt{@Transactional}. \\
\hline
\textbf{Comando:} \texttt{Update\allowbreak Device\allowbreak Status\allowbreak Command} & \texttt{handle(UpdateDeviceStatusCommand)} → \texttt{void} \\*
\hline
\textbf{Parámetros Principales} & \texttt{UUID deviceId, DeviceStatus newStatus, String reason} \\*
\hline
\textbf{Reglas y Transaccionalidad} & Modifica la situación de inventario del escáner permitiendo retirarlo a mantenimiento técnico o darlo de baja por extravío físico. Anotado con \texttt{@Transactional}. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Comandos:} Vehicle\allowbreak Fault\allowbreak Command\allowbreak Service\allowbreak Impl} \\*
\hline
\textbf{Comando:} \texttt{Register\allowbreak Vehicle\allowbreak Fault\allowbreak Command} & \texttt{handle(RegisterVehicleFaultCommand)} → \texttt{UUID} \\*
\hline
\textbf{Parámetros Principales} & \texttt{UUID vehicleId, String dtcCode, String severity, String description} \\*
\hline
\textbf{Reglas y Transaccionalidad} & Valida que el código cumpla la estructura oficial SAE J2012 mediante DtcCodeEvaluationService. Persiste la entidad VehicleFault en estado no resuelto y publica VehicleFaultLoggedIntegrationEvent hacia MRO. Anotado con \texttt{@Transactional}. \\
\hline
\textbf{Comando:} \texttt{Resolve\allowbreak Vehicle\allowbreak Fault\allowbreak Command} & \texttt{handle(ResolveVehicleFaultCommand)} → \texttt{void} \\*
\hline
\textbf{Parámetros Principales} & \texttt{UUID faultId, String resolutionNotes, UUID workOrderId} \\*
\hline
\textbf{Reglas y Transaccionalidad} & Marca formalmente la avería electrónica como resuelta asociando las notas técnicas y la orden de trabajo de foso que subsanó el problema emitiendo VehicleFaultResolvedEvent. Anotado con \texttt{@Transactional}. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Comandos:} Vehicle\allowbreak Health\allowbreak Report\allowbreak Command\allowbreak Service\allowbreak Impl} \\*
\hline
\textbf{Comando:} \texttt{Generate\allowbreak Vehicle\allowbreak Health\allowbreak Report\allowbreak Command} & \texttt{handle(GenerateVehicleHealthReportCommand)} → \texttt{HealthReportResult} \\*
\hline
\textbf{Signatura y Tipos} & Entrada: identificador de vehículo, días de análisis, inclusión de historial DTC y motivo de activación \\*
\hline
\textbf{Consecuencias de Dominio} & Extrae métricas agregadas desde TimescaleDB y averías activas desde PostgreSQL 16, ejecuta inferencia diagnóstica mediante AiInferenceDiagnosticPort con Spring AI ChatClient sobre Groq LPU, persiste alertas con confianza superior o igual al setenta por ciento y publica el evento VehicleHealthReportGeneratedIntegrationEvent. Anotado con \texttt{@Transactional}. \\
\hline
\textbf{Comando:} \texttt{Enqueue\allowbreak Vehicle\allowbreak Health\allowbreak Report\allowbreak Analysis\allowbreak Command} & \texttt{handle(EnqueueVehicleHealthReportAnalysisCommand)} → \texttt{UUID} \\*
\hline
\textbf{Signatura y Tipos} & Entrada: identificador de lote de flota, parámetros de ventana temporal y destinatario de notificación \\*
\hline
\textbf{Consecuencias de Dominio} & Registra una tarea de procesamiento asíncrono en segundo plano para evaluación de flotas masivas, retornando un identificador de seguimiento sin bloquear la interfaz de usuario. Anotado con \texttt{@Transactional}. \\
\hline
\end{longtable}
*Nota.* Especificación de operaciones transaccionales y lógica de orquestación de los Command Services de IoT Telemetry \& Predictive Maintenance.

**Servicios de Consultas y Lectura Especializada**

El lado de lectura del subsistema resuelve los requisitos informativos de tableros de control web y aplicaciones móviles de taller y conductor sin sobrecargar el modelo de escritura:

- **TelemetryLogQueryServiceImpl**: Combina lecturas instantáneas de tacómetro digital en tiempo real con consultas agregadas de series temporales calculadas mediante la función SQL time\_bucket de TimescaleDB, entregando promedios y cotas máximas de velocidad, revoluciones y temperatura de refrigerante.

- **VehicleFaultQueryServiceImpl**: Provee la recuperación eficiente de averías electrónicas activas para su visualización inmediata al recepcionar vehículos en taller, así como la reconstrucción del historial clínico de diagnósticos.

- **PredictiveAlertQueryServiceImpl**: Filtra las advertencias preventivas activas del taller por nivel de severidad y estado operativo, permitiendo priorizar las intervenciones mecánicas comerciales.

- **Obd2DeviceQueryServiceImpl**: Expone vistas paginadas del inventario de hardware telemático y filtra dispositivos disponibles para asignación inmediata.

- **DeviceInstallationQueryServiceImpl**: Provee la consulta de la sesión telemática actualmente activa en el vehículo y el registro cronológico de instalaciones previas.

- **VehicleHealthReportQueryServiceImpl**: Provee la recuperación estructurada del informe pericial de salud más reciente para cuadros de mando web y móviles, y coordina la compilación tipográfica del dictamen en documento PDF.

En la @tbl:iot-query-services se presentan los métodos de consulta de la capa de aplicación, indicando sus tipos de retorno, parámetros y mecanismos de lectura sobre la base de datos.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Métodos de Consulta de la Capa de Aplicación de IoT Telemetry \& Predictive Maintenance} \label{tbl:iot-query-services} \\
\hline
\thfirst{Consulta de Entrada} & \thcell{Firma, Retorno y Mecanismo de Lectura} \\
\hline
\endfirsthead
\hline
\thfirst{Consulta de Entrada} & \thcell{Firma, Retorno y Mecanismo de Lectura} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Consultas:} Telemetry\allowbreak Log\allowbreak Query\allowbreak Service\allowbreak Impl} \\*
\hline
\textbf{Consulta:} \texttt{Get\allowbreak Latest\allowbreak Telemetry\allowbreak Query} & \texttt{handle(GetLatestTelemetryQuery)} → \texttt{Optional<VehicleLatestTelemetryResource>} \\*
\hline
\textbf{Parámetros} & \texttt{UUID vehicleId} \\*
\hline
\textbf{Mecanismo de Lectura} & Consulta el registro con marca temporal más reciente en la hipertabla telemetry\_logs de TimescaleDB mediante índice temporal inverso. Provee lecturas de tacómetro digital en tiempo real con transaccionalidad de solo lectura mediante la anotación \texttt{@Transactional(readOnly = true)}. \\
\hline
\textbf{Consulta:} \texttt{Get\allowbreak Aggregated\allowbreak Telemetry\allowbreak Query} & \texttt{handle(GetAggregatedTelemetryQuery)} → \texttt{List<TelemetryAggregateResource>} \\*
\hline
\textbf{Parámetros} & \texttt{UUID vehicleId, Instant from, Instant to, Duration bucketInterval} \\*
\hline
\textbf{Mecanismo de Lectura} & Ejecuta consultas analíticas aprovechando la función SQL time\_bucket de TimescaleDB promediando velocidades RPM y temperaturas en cubos temporales uniformes bajo \texttt{@Transactional(readOnly = true)}. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Consultas:} Vehicle\allowbreak Fault\allowbreak Query\allowbreak Service\allowbreak Impl} \\*
\hline
\textbf{Consulta:} \texttt{Get\allowbreak Active\allowbreak Faults\allowbreak By\allowbreak Vehicle\allowbreak Query} & \texttt{handle(GetActiveFaultsByVehicleQuery)} → \texttt{List<VehicleFaultResource>} \\*
\hline
\textbf{Parámetros} & \texttt{UUID vehicleId} \\*
\hline
\textbf{Mecanismo de Lectura} & Recupera del repositorio relacional todas las averías electrónicas con bandera de resolución en falso para desplegar el diagnóstico en la orden de trabajo de foso con transaccionalidad de solo lectura mediante \texttt{@Transactional(readOnly = true)}. \\
\hline
\textbf{Consulta:} \texttt{Get\allowbreak Fault\allowbreak History\allowbreak By\allowbreak Vehicle\allowbreak Query} & \texttt{handle(GetFaultHistoryByVehicleQuery)} → \texttt{List<VehicleFaultResource>} \\*
\hline
\textbf{Parámetros} & \texttt{UUID vehicleId} \\*
\hline
\textbf{Mecanismo de Lectura} & Provee la trazabilidad histórica completa de anomalías electrónicas detectadas y subsanadas a lo largo de la vida útil del vehículo bajo \texttt{@Transactional(readOnly = true)}. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Consultas:} Predictive\allowbreak Alert\allowbreak Query\allowbreak Service\allowbreak Impl} \\*
\hline
\textbf{Consulta:} \texttt{Get\allowbreak Active\allowbreak Alerts\allowbreak By\allowbreak Tenant\allowbreak Query} & \texttt{handle(GetActiveAlertsByTenantQuery)} → \texttt{List<PredictiveAlertResource>} \\*
\hline
\textbf{Parámetros} & \texttt{UUID tenantId, AlertSeverity severity, AlertStatus status} \\*
\hline
\textbf{Mecanismo de Lectura} & Filtra las alertas preventivas activas del taller mecánico permitiendo a los asesores de servicio priorizar vehículos con alto riesgo de avería inminente bajo \texttt{@Transactional(readOnly = true)}. \\
\hline
\textbf{Consulta:} \texttt{Get\allowbreak Alerts\allowbreak By\allowbreak Vehicle\allowbreak Query} & \texttt{handle(GetAlertsByVehicleQuery)} → \texttt{List<PredictiveAlertResource>} \\*
\hline
\textbf{Parámetros} & \texttt{UUID vehicleId} \\*
\hline
\textbf{Mecanismo de Lectura} & Recupera el historial de advertencias preventivas emitidas por el motor de inferencia analítica para una unidad automotriz específica bajo \texttt{@Transactional(readOnly = true)}. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Consultas:} Obd2\allowbreak Device\allowbreak Query\allowbreak Service\allowbreak Impl} \\*
\hline
\textbf{Consulta:} \texttt{Get\allowbreak Devices\allowbreak By\allowbreak Tenant\allowbreak Query} & \texttt{handle(GetDevicesByTenantQuery)} → \texttt{Page<Obd2DeviceResource>} \\*
\hline
\textbf{Parámetros} & \texttt{UUID tenantId, Pageable pageable} \\*
\hline
\textbf{Mecanismo de Lectura} & Consulta paginada del inventario de hardware telemático registrado en el taller optimizando el consumo de memoria mediante Spring Data JPA bajo \texttt{@Transactional(readOnly = true)}. \\
\hline
\textbf{Consulta:} \texttt{Get\allowbreak Available\allowbreak Devices\allowbreak Query} & \texttt{handle(GetAvailableDevicesQuery)} → \texttt{List<Obd2DeviceResource>} \\*
\hline
\textbf{Parámetros} & \texttt{UUID tenantId} \\*
\hline
\textbf{Mecanismo de Lectura} & Retorna la lista de escáneres operativos sin sesión de montaje activa disponibles para instalación inmediata en patio vehicular bajo \texttt{@Transactional(readOnly = true)}. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Consultas:} Device\allowbreak Installation\allowbreak Query\allowbreak Service\allowbreak Impl} \\*
\hline
\textbf{Consulta:} \texttt{Get\allowbreak Active\allowbreak Installation\allowbreak By\allowbreak Vehicle\allowbreak Query} & \texttt{handle(GetActiveInstallationByVehicleQuery)} → \texttt{Optional<DeviceInstallationResource>} \\*
\hline
\textbf{Parámetros} & \texttt{UUID vehicleId} \\*
\hline
\textbf{Mecanismo de Lectura} & Localiza la sesión de montaje telemático actualmente vigente para la unidad automotriz retornando los metadatos del escáner enlazado bajo \texttt{@Transactional(readOnly = true)}. \\
\hline
\textbf{Consulta:} \texttt{Get\allowbreak Installation\allowbreak History\allowbreak By\allowbreak Vehicle\allowbreak Query} & \texttt{handle(GetInstallationHistoryByVehicleQuery)} → \texttt{List<DeviceInstallationResource>} \\*
\hline
\textbf{Parámetros} & \texttt{UUID vehicleId} \\*
\hline
\textbf{Mecanismo de Lectura} & Reconstruye la cronología de escáneres instalados y retirados del vehículo con marcas temporales y lecturas de kilometraje acumulado bajo \texttt{@Transactional(readOnly = true)}. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Consultas:} Vehicle\allowbreak Health\allowbreak Report\allowbreak Query\allowbreak Service\allowbreak Impl} \\*
\hline
\textbf{Consulta:} \texttt{Get\allowbreak Latest\allowbreak Vehicle\allowbreak Health\allowbreak Report\allowbreak Query} & \texttt{handle(GetLatestVehicleHealthReportQuery)} → \texttt{Optional<VehicleHealthReportResource>} \\*
\hline
\textbf{Parámetros} & \texttt{UUID vehicleId} \\*
\hline
\textbf{Mecanismo de Lectura} & Recupera el último diagnóstico pericial generado consolidando evaluaciones por subsistema, correlaciones DTC y recomendaciones de mantenimiento preventivo bajo \texttt{@Transactional(readOnly = true)}. \\
\hline
\textbf{Consulta:} \texttt{Export\allowbreak Vehicle\allowbreak Health\allowbreak Report\allowbreak Pdf\allowbreak Query} & \texttt{handle(ExportVehicleHealthReportPdfQuery)} → \texttt{byte[]} \\*
\hline
\textbf{Parámetros} & \texttt{UUID vehicleId, UUID reportId} \\*
\hline
\textbf{Mecanismo de Lectura} & Invoca al puerto VehicleHealthReportPdfGeneratorPort para renderizar el informe analítico completo en binario PDF aplicando maquetación institucional con membrete y semáforos de salud mecánica bajo \texttt{@Transactional(readOnly = true)}. \\
\hline
\end{longtable}
*Nota.* Métodos de consulta de la Capa de Aplicación de IoT Telemetry \& Predictive Maintenance.

**Manejadores de Eventos de Dominio y de Integración**

La coordinación reactiva y la consistencia eventual entre subsistemas se articulan mediante manejadores dedicados de eventos:

- **IoTTransactionalOutboxPublisher**: Intercepta eventos de dominio del contexto telemático y persiste mensajes de forma atómica en la tabla relacional de outbox dentro de la misma transacción de base de datos, garantizando una entrega confiable at-least-once sin pérdida de información ante fallas de red.

- **TelemetryDomainEventHandler**: Intercepta eventos de detección de anomalías críticas de motor tras la confirmación transaccional de la ingesta sensorial, despachando de forma asíncrona notificaciones push de alta prioridad hacia las aplicaciones móviles de conductor y taller mediante la pasarela de Firebase.

- **PredictiveAlertDomainEventHandler**: Propaga eventos de integración hacia los contextos de CRM y MRO ante la generación formal de advertencias predictivas, facilitando la preconfiguración automática de presupuestos de mantenimiento.

- **VehicleFaultDomainEventHandler**: Emite eventos de integración ante el reporte de códigos DTC en la computadora vehicular para nutrir la ficha técnica automotriz.

- **VehicleLifecycleIntegrationEventHandler**: Consume notificaciones externas de baja definitiva vehicular, transferencia de titularidad y culminación de órdenes de trabajo para liberar dispositivos telemáticos y marcar como subsanadas las averías reparadas.

En la @tbl:iot-event-handlers se especifican los eventos interceptados por los manejadores, detallando sus fases de ejecución, orígenes y consecuencias arquitectónicas.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Manejadores de Eventos de Dominio y de Integración de IoT Telemetry \& Predictive Maintenance} \label{tbl:iot-event-handlers} \\
\hline
\thfirst{Evento Interceptado} & \thcell{Fase de Ejecución y Efectos del Manejador} \\
\hline
\endfirsthead
\hline
\thfirst{Evento Interceptado} & \thcell{Fase de Ejecución y Efectos del Manejador} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Publicador Transaccional Outbox:} IoT\allowbreak Transactional\allowbreak Outbox\allowbreak Publisher} \\*
\hline
\textbf{Evento:} \texttt{Domain\allowbreak Event} & Ejecución síncrona en fase \texttt{BEFORE\_COMMIT} mediante \texttt{@TransactionalEventListener(phase = TransactionPhase.BEFORE\_COMMIT)} \\*
\hline
\textbf{Origen del Suceso} & Agregados de dominio TelemetryRecord, DeviceInstallation, VehicleFault, PredictiveAlert y Obd2Device \\*
\hline
\textbf{Efectos del Manejador} & Serializa la carga útil del suceso en estructura JSON y persiste el registro en la tabla de outbox transaccional de PostgreSQL 16 dentro de la misma transacción de negocio, asegurando consistencia eventual y entrega confiable hacia intermediarios de mensajería externos sin riesgo de pérdida de datos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador de Eventos de Dominio:} Telemetry\allowbreak Domain\allowbreak Event\allowbreak Handler} \\*
\hline
\textbf{Evento:} \texttt{Critical\allowbreak Engine\allowbreak Anomaly\allowbreak Detected\allowbreak Event} & Ejecución en fase \texttt{AFTER\_COMMIT} mediante \texttt{@TransactionalEventListener} y \texttt{@Async} \\*
\hline
\textbf{Origen del Suceso} & Inferencia analítica del motor matemático tras la ingesta de ráfagas sensoriales \\*
\hline
\textbf{Efectos del Manejador} & Invoca de inmediato a FcmNotificationAclPort despachando notificaciones push de alta prioridad hacia el teléfono del conductor y la pantalla de recepción del taller mecánico. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador de Eventos de Dominio:} Predictive\allowbreak Alert\allowbreak Domain\allowbreak Event\allowbreak Handler} \\*
\hline
\textbf{Evento:} \texttt{Predictive\allowbreak Alert\allowbreak Generated\allowbreak Event} & Ejecución en fase \texttt{AFTER\_COMMIT} mediante \texttt{@TransactionalEventListener} \\*
\hline
\textbf{Origen del Suceso} & Agregado PredictiveAlert ante instanciación formal de recomendación preventiva \\*
\hline
\textbf{Efectos del Manejador} & Publica el evento PredictiveAlertGeneratedIntegrationEvent hacia el bus de mensajería para preconfigurar presupuestos y citas de mantenimiento en CRM y MRO. \\
\hline
\textbf{Evento:} \texttt{Predictive\allowbreak Alert\allowbreak Dismissed\allowbreak Event} & Ejecución en fase \texttt{AFTER\_COMMIT} mediante \texttt{@TransactionalEventListener} \\*
\hline
\textbf{Origen del Suceso} & Agregado PredictiveAlert ante descarte fundamentado de una alerta \\*
\hline
\textbf{Efectos del Manejador} & Registra los motivos de descarte en el almacén analítico para calibración continua de los umbrales algorítmicos del motor de anomalías. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador de Eventos de Dominio:} Vehicle\allowbreak Fault\allowbreak Domain\allowbreak Event\allowbreak Handler} \\*
\hline
\textbf{Evento:} \texttt{Vehicle\allowbreak Fault\allowbreak Detected\allowbreak Event} & Ejecución en fase \texttt{AFTER\_COMMIT} mediante \texttt{@TransactionalEventListener} \\*
\hline
\textbf{Origen del Suceso} & Agregado VehicleFault ante detección de un nuevo código DTC en la ECU \\*
\hline
\textbf{Efectos del Manejador} & Emite VehicleFaultLoggedIntegrationEvent permitiendo que Workshop Operations precargue la anomalía en la orden de trabajo de foso. \\
\hline
\textbf{Evento:} \texttt{Vehicle\allowbreak Fault\allowbreak Resolved\allowbreak Event} & Ejecución en fase \texttt{AFTER\_COMMIT} mediante \texttt{@TransactionalEventListener} \\*
\hline
\textbf{Origen del Suceso} & Agregado VehicleFault ante culminación de reparación técnica \\*
\hline
\textbf{Efectos del Manejador} & Actualiza el historial clínico del vehículo notificando la corrección exitosa de la anomalía electrónica. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador de Eventos de Integración:} Vehicle\allowbreak Lifecycle\allowbreak Integration\allowbreak Event\allowbreak Handler} \\*
\hline
\textbf{Evento:} \texttt{Vehicle\allowbreak Decommissioned\allowbreak Integration\allowbreak Event} & Ejecución asíncrona desacoplada mediante suscriptor del bus de eventos \\*
\hline
\textbf{Origen del Suceso} & Bounded Context Customer and Fleet Management CRM ante baja definitiva de unidad \\*
\hline
\textbf{Efectos del Manejador} & Finaliza automáticamente cualquier sesión de montaje activa liberando el hardware OBD-II para su reutilización en el inventario del taller. \\
\hline
\textbf{Evento:} \texttt{Vehicle\allowbreak Ownership\allowbreak Transferred\allowbreak Integration\allowbreak Event} & Ejecución asíncrona desacoplada mediante suscriptor del bus de eventos \\*
\hline
\textbf{Origen del Suceso} & Bounded Context Customer and Fleet Management CRM ante transferencia vehicular \\*
\hline
\textbf{Efectos del Manejador} & Concluye la instalación telemática vigente protegiendo la privacidad del usuario saliente y reinicia las líneas base analíticas de conducción. \\
\hline
\textbf{Evento:} \texttt{Work\allowbreak Order\allowbreak Completed\allowbreak Integration\allowbreak Event} & Ejecución asíncrona desacoplada mediante suscriptor del bus de eventos \\*
\hline
\textbf{Origen del Suceso} & Bounded Context Workshop Operations MRO tras cierre de orden de trabajo en foso \\*
\hline
\textbf{Efectos del Manejador} & Marca automáticamente como corregidas todas las fallas electrónicas DTC asociadas a los subsistemas automotrices reparados en taller. \\
\hline
\end{longtable}
*Nota.* Especificación de manejadores de eventos de dominio y de integración de IoT Telemetry \& Predictive Maintenance.

**Puertos Salientes y Capas Anticorrupción**

La comunicación hacia proveedores externos y servicios especializados de persistencia se aísla rigurosamente mediante puertos de salida y Capas Anticorrupción ubicados bajo el paquete canónico internal.outbound.acl:

- **AiInferenceDiagnosticPort**: Define el contrato perimetral para orquestar consultas de inferencia diagnóstica con inteligencia artificial estructurada, desacoplando los modelos de lenguaje fundacionales y garantizando dictámenes técnicos con tiempos de respuesta reducidos.

- **CrmFleetAclPort**: Resuelve la identidad de conductores, tokens de dispositivos y estado de registro de vehículos corporativos interactuando con Customer and Fleet Management bajo una interfaz neutral.

- **FcmNotificationAclPort**: Encapsula el SDK oficial de Firebase Admin para estructurar y remitir notificaciones push con canalización prioritaria, aislando el núcleo de la aplicación de particularidades técnicas de la infraestructura de Google Cloud.

- **OperationsAclPort**: Traduce anomalías telemáticas a servicios sugeridos de mantenimiento y consulta el catálogo de servicios de taller en Workshop Operations, evitando el acoplamiento directo con el modelo interno de órdenes de trabajo.

- **TimescaleBatchJdbcClientPort**: Define el contrato de persistencia masiva de alto rendimiento para la inserción en bloque de lecturas sensoriales sobre la hipertabla particionada de TimescaleDB.

- **VehicleHealthReportPdfGeneratorPort**: Define el contrato perimetral para renderizado y compilación documental del informe de salud mecánica en formato binario PDF con maquetación institucional.

En la @tbl:iot-outbound-ports se detallan los puertos de salida de la capa de aplicación, sus signaturas de métodos y sus adaptadores concretos de infraestructura.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Puertos de Salida, Pasarelas y Adaptadores de la Capa de Aplicación de IoT Telemetry \& Predictive Maintenance} \label{tbl:iot-outbound-ports} \\
\hline
\thfirst{Puerto de Salida} & \thcell{Firma de Operaciones y Adaptador de Infraestructura} \\
\hline
\endfirsthead
\hline
\thfirst{Puerto de Salida} & \thcell{Firma de Operaciones y Adaptador de Infraestructura} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto / Capa Anticorrupción:} Ai\allowbreak Inference\allowbreak Diagnostic\allowbreak Port} \\*
\hline
\textbf{Operación Principal} & \texttt{generateVehicleDiagnostic(TenantId tenantId, VehicleId vehicleId, int daysToAnalyze, boolean includeResolvedDtcHistory)} → \texttt{VehicleHealthReportAiDto} \\*
\hline
\textbf{Operaciones Secundarias} & - \texttt{isAiDiagnosticServiceAvailable()} → \texttt{boolean} \\*
\hline
\textbf{Adaptador Concreto} & GroqAiInferenceAdapter en la Capa de Infraestructura mediante Spring AI ChatClient sobre Groq LPU con Llama 3 70B Versatile \\*
\hline
\textbf{Propósito Arquitectónico} & Desacoplar la orquestación de la aplicación de los proveedores de LLM y modelos de lenguaje fundacionales, canalizando diagnósticos periciales estructurados con latencias sub-segundo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto / Capa Anticorrupción:} Crm\allowbreak Fleet\allowbreak Acl\allowbreak Port} \\*
\hline
\textbf{Operación Principal} & \texttt{getDriverFcmDeviceToken(VehicleId vehicleId)} → \texttt{String} \\*
\hline
\textbf{Operaciones Secundarias} & - \texttt{isVehicleRegistered(VehicleId vehicleId)} → \texttt{boolean} \newline - \texttt{getVehicleOwnerContact(VehicleId vehicleId)} → \texttt{VehicleOwnerContactDto} \\*
\hline
\textbf{Adaptador Concreto} & CrmFleetAclAdapter consumiendo la fachada pública Inbound OHS de Customer and Fleet Management CRM \\*
\hline
\textbf{Propósito Arquitectónico} & Resolver la titularidad del automóvil y el identificador de token móvil para el ruteo de alertas críticas salvaguardando la autonomía de datos entre contextos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto / Capa Anticorrupción:} Fcm\allowbreak Notification\allowbreak Acl\allowbreak Port} \\*
\hline
\textbf{Operación Principal} & \texttt{sendHighPriorityNotification(VehicleId vehicleId, String title, String body, Map<String, String> data)} → \texttt{String} \\*
\hline
\textbf{Operaciones Secundarias} & - \texttt{sendTopicNotification(String topic, String title, String body, Map<String, String> data)} → \texttt{String} \\*
\hline
\textbf{Adaptador Concreto} & FirebaseNotificationGateway en la Capa de Infraestructura mediante el SDK oficial de Firebase Admin \\*
\hline
\textbf{Propósito Arquitectónico} & Aislar el núcleo de software de las dependencias externas del SDK de Google Firebase estructurando notificaciones push con canal de alta prioridad para alertas de cabina en ruta. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto / Capa Anticorrupción:} Operations\allowbreak Acl\allowbreak Port} \\*
\hline
\textbf{Operación Principal} & \texttt{getAvailableWorkshopServices(TenantId tenantId)} → \texttt{List<WorkshopServiceCatalogItemDto>} \\*
\hline
\textbf{Operaciones Secundarias} & - \texttt{createPreventiveWorkOrderDraft(VehicleId vehicleId, UUID serviceId, String reason)} → \texttt{UUID} \newline - \texttt{isWorkshopCapacityAvailable(TenantId tenantId, Instant preferredDate)} → \texttt{boolean} \\*
\hline
\textbf{Adaptador Concreto} & OperationsAclAdapter consumiendo la fachada pública Inbound OHS de Workshop Operations MRO \\*
\hline
\textbf{Propósito Arquitectónico} & Traducir anomalías telemáticas físicas en paquetes de servicios mecánicos estandarizados y consultar disponibilidad operativa sin acoplarse al modelo interno de órdenes de trabajo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto Especializado:} Timescale\allowbreak Batch\allowbreak Jdbc\allowbreak Client\allowbreak Port} \\*
\hline
\textbf{Operación Principal} & \texttt{executeBatchInsert(List<TelemetryRecord> records)} → \texttt{void} \\*
\hline
\textbf{Operaciones Secundarias} & - \texttt{queryLatestRecord(VehicleId vehicleId)} → \texttt{Optional<TelemetryRecord>} \newline - \texttt{queryAggregates(VehicleId vehicleId, Instant from, Instant to, Duration bucket)} → \texttt{List<TelemetryBucketDto>} \\*
\hline
\textbf{Adaptador Concreto} & TimescaleTelemetryRepositoryImpl en la Capa de Infraestructura mediante Spring JdbcClient con inserciones preparadas por lotes \\*
\hline
\textbf{Propósito Arquitectónico} & Garantizar persistencia masiva de series temporales de alta velocidad en hipertablas de TimescaleDB con latencias sub-segundo aislando el código SQL nativo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto Especializado:} Vehicle\allowbreak Health\allowbreak Report\allowbreak Pdf\allowbreak Generator\allowbreak Port} \\*
\hline
\textbf{Operación Principal} & \texttt{generateHealthReportPdf(VehicleHealthReportAiDto reportData, VehicleMetadataDto metadata)} → \texttt{byte[]} \\*
\hline
\textbf{Operaciones Secundarias} & - \texttt{validateTemplateAvailability()} → \texttt{boolean} \newline - \texttt{getReportMetadata(UUID reportId)} → \texttt{ReportMetadataDto} \\*
\hline
\textbf{Adaptador Concreto} & VehicleHealthReportPdfGeneratorAdapter en la Capa de Infraestructura mediante plantillas XHTML procesadas por Thymeleaf y compilador binario OpenPDF \\*
\hline
\textbf{Propósito Arquitectónico} & Aislar la lógica de aplicación de las bibliotecas de maquetación documental tipográfica garantizando compilación determinista y desacoplada de informes periciales en formato PDF. \\
\hline
\end{longtable}
*Nota.* Especificación formal de puertos salientes, pasarelas de infraestructura y Capas Anticorrupción de IoT Telemetry \& Predictive Maintenance.

El desacoplamiento provisto por la Capa de Aplicación de IoT Telemetry & Predictive Maintenance asegura una orquestación fluida y resiliente de los procesos telemáticos del taller automotriz. Al estructurar los flujos bajo el patrón CQRS, el sistema canaliza ráfagas continuas de telemetría de cientos de automóviles en tránsito hacia hipertablas optimizadas en TimescaleDB sin introducir bloqueos transaccionales ni ralentizar las consultas analíticas del personal de servicio.

Asimismo, la mediación de Capas Anticorrupción consolida una protección rigurosa frente a contingencias en proveedores externos y dependencias de red. Al confinar el protocolo de notificaciones push de Firebase Admin y las consultas de servicios de MRO detrás de adaptadores perimetrales, la plataforma garantiza que fallas transitorias de conectividad externa no interrumpan la captura sensorial ni corrompan el estado del dominio automotriz.

Finalmente, la articulación de los manejadores de eventos con el ciclo transaccional posterior al commit y el publicador transaccional outbox garantiza una consistencia eventual intachable en toda la plataforma. Las anomalías de motor y advertencias predictivas se traducen de forma autónoma en oportunidades comerciales tangibles y citas preventivas, consolidando una sinergia operativa entre el monitoreo físico del vehículo y la gestión comercial del taller mecánico.



#### 2.6.9.4. Infrastructure Layer

La Capa de Infraestructura del Bounded Context **IoT Telemetry & Predictive Maintenance** (paquete canónico com.andeva.atelier.platform.iot.infrastructure) materializa el acceso físico a los mecanismos de persistencia híbrida, traduce las operaciones de los puertos de dominio hacia tecnologías de almacenamiento concretas y encapsula la interacción perimetral con plataformas en la nube y contextos satélite. En el entorno de la plataforma Atelier, esta capa soporta flujos masivos de telemetría automotriz generados en tiempo real por escáneres OBD-II y módems celulares, asegurando una ingesta continua sin penalizar el rendimiento del modelo relacional transaccional.

La arquitectura de infraestructura descansa sobre cuatro pilares técnicos fundamentales:

- **Persistencia híbrida relacional y de series temporales:** Convivencia armónica entre PostgreSQL 16 para entidades auditadas de inventario y sesiones de montaje en persistence.jpa, y la extensión TimescaleDB en persistence.timescale para la ingesta en ráfagas de series temporales en hipertablas particionadas por tiempo.
- **Ingesta masiva y analítica de alto rendimiento con inserción por lotes:** Canalización de lecturas de sensores mediante un repositorio JDBC especializado que prescinde del seguimiento de estados de Hibernate en favor de operaciones por lotes de baja sobrecarga computacional y consultas analíticas con ventanas temporales de agregación.
- **Reconstitución pura del modelo de dominio y erradicación de transform en JPA:** Ensambladores de persistencia dedicados en persistence.jpa.assemblers y persistence.timescale.assemblers que hidratan agregados y objetos de valor inmutables sin disparar eventos de dominio espurios durante consultas operativas, complementados con convertidores de atributos JPA para tipos complejos.
- **Adaptadores externos segregados por tecnología y resiliencia perimetral:** Aislamiento estricto de clientes externos en el subpaquete infrastructure.external, organizados modularmente para inferencia pericial con Spring AI sobre Groq, pasarela push de alta prioridad con Firebase Cloud Messaging, compilación de informes PDF periciales con OpenPDF, relay transaccional outbox y capas anticorrupción hacia contextos satélite.

En la @tbl:iot-infrastructure-types se sintetiza el catálogo consolidado de clases, entidades de persistencia, adaptadores de repositorio, ensambladores, convertidores y pasarelas que configuran este perímetro.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo Consolidado de la Capa de Infraestructura de IoT Telemetry \& Predictive Maintenance} \label{tbl:iot-infrastructure-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\
\hline
\endhead
Obd2\allowbreak Device\allowbreak Persistence\allowbreak Entity & Mapeo relacional del inventario físico de hardware telemático hacia la tabla obd2\_devices. \\*
\hline
\textbf{Categoría} & Entidad de Persistencia JPA \\*
\hline
\textbf{Relaciones} & Hereda de AuditableAbstractPersistenceEntity. Raíz de persistencia para escáneres con índice único sobre device\_identifier. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Device\allowbreak Installation\allowbreak Persistence\allowbreak Entity & Mapeo relacional de las sesiones de emparejamiento telemático hacia la tabla device\_installations. \\*
\hline
\textbf{Categoría} & Entidad de Persistencia JPA \\*
\hline
\textbf{Relaciones} & Hereda de AuditableAbstractPersistenceEntity. Claves foráneas lógicas hacia vehicle\_id y device\_id con índices de búsqueda. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Vehicle\allowbreak Fault\allowbreak Persistence\allowbreak Entity & Mapeo relacional del historial clínico y averías electrónicas hacia la tabla vehicle\_faults. \\*
\hline
\textbf{Categoría} & Entidad de Persistencia JPA \\*
\hline
\textbf{Relaciones} & Hereda de AuditableAbstractPersistenceEntity. Índice compuesto sobre vehicle\_id y estado de subsanación is\_resolved. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Predictive\allowbreak Alert\allowbreak Persistence\allowbreak Entity & Mapeo relacional de alertas preventivas y recomendaciones mecánicas hacia la tabla predictive\_alerts. \\*
\hline
\textbf{Categoría} & Entidad de Persistencia JPA \\*
\hline
\textbf{Relaciones} & Hereda de AuditableAbstractPersistenceEntity. Clave foránea opcional a orden de trabajo e índice por estado operativo. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Dtc\allowbreak Catalog\allowbreak Persistence\allowbreak Entity & Mapeo relacional del catálogo canónico de fallas SAE J2012 e ISO 15031-6 hacia la tabla dtc\_catalog. \\*
\hline
\textbf{Categoría} & Entidad de Persistencia JPA \\*
\hline
\textbf{Relaciones} & Hereda de AuditableAbstractPersistenceEntity. Restricción de unicidad estricta sobre la columna dtc\_code. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Obd2\allowbreak Device\allowbreak Persistence\allowbreak Repository & Interfaz de persistencia Spring Data JPA para administración de dispositivos telemáticos del taller. \\*
\hline
\textbf{Categoría} & Repositorio Spring Data JPA \\*
\hline
\textbf{Relaciones} & Extiende JpaRepository. Consultas unívocas por identificador físico y verificación de existencia por MAC o IMEI. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Device\allowbreak Installation\allowbreak Persistence\allowbreak Repository & Interfaz de persistencia Spring Data JPA para control de instalaciones activas e histórico de montaje. \\*
\hline
\textbf{Categoría} & Repositorio Spring Data JPA \\*
\hline
\textbf{Relaciones} & Extiende JpaRepository. Consultas por vehículo activo sin desinstalación y listado cronológico de sesiones vehiculares. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Vehicle\allowbreak Fault\allowbreak Persistence\allowbreak Repository & Interfaz de persistencia Spring Data JPA para gestión de averías electrónicas y códigos DTC activos. \\*
\hline
\textbf{Categoría} & Repositorio Spring Data JPA \\*
\hline
\textbf{Relaciones} & Extiende JpaRepository. Filtrado de fallas no subsanadas por vehículo y recuperación de historial de diagnósticos. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Predictive\allowbreak Alert\allowbreak Persistence\allowbreak Repository & Interfaz de persistencia Spring Data JPA para administración de tableros de alertas de mantenimiento predictivo. \\*
\hline
\textbf{Categoría} & Repositorio Spring Data JPA \\*
\hline
\textbf{Relaciones} & Extiende JpaRepository. Búsqueda de alertas por taller automotriz y estado operativo con ordenamiento cronológico. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Dtc\allowbreak Catalog\allowbreak Persistence\allowbreak Repository & Interfaz de persistencia Spring Data JPA para consulta canónica de definiciones de diagnóstico automotriz. \\*
\hline
\textbf{Categoría} & Repositorio Spring Data JPA \\*
\hline
\textbf{Relaciones} & Extiende JpaRepository. Búsqueda por código DTC normalizado y recuperación por categoría de subsistema vehicular. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Obd2\allowbreak Device\allowbreak Persistence\allowbreak Assembler & Ensamblador de datos para transformación bidireccional entre el agregado Obd2Device y su entidad JPA. \\*
\hline
\textbf{Categoría} & Ensamblador de Persistencia \\*
\hline
\textbf{Relaciones} & Mapea identificadores tipados y estados de hardware reconstituyendo agregados sin emitir eventos espurios. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak assemblers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Device\allowbreak Installation\allowbreak Persistence\allowbreak Assembler & Ensamblador para transformación bidireccional entre DeviceInstallation y DeviceInstallationPersistenceEntity. \\*
\hline
\textbf{Categoría} & Ensamblador de Persistencia \\*
\hline
\textbf{Relaciones} & Desempaqueta lecturas de odómetro en kilómetros y fechas Instant en UTC preservando invariantes de instalación. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak assemblers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Vehicle\allowbreak Fault\allowbreak Persistence\allowbreak Assembler & Ensamblador para transformación bidireccional entre VehicleFault y VehicleFaultPersistenceEntity. \\*
\hline
\textbf{Categoría} & Ensamblador de Persistencia \\*
\hline
\textbf{Relaciones} & Transforma códigos DTC y niveles de severidad reconstituyendo la entidad de avería con marcas temporales exactas. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak assemblers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Predictive\allowbreak Alert\allowbreak Persistence\allowbreak Assembler & Ensamblador para transformación bidireccional entre PredictiveAlert y PredictiveAlertPersistenceEntity. \\*
\hline
\textbf{Categoría} & Ensamblador de Persistencia \\*
\hline
\textbf{Relaciones} & Mapea niveles de confianza de pronóstico y referencias a servicios de taller recomendados en el dominio. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak assemblers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Dtc\allowbreak Catalog\allowbreak Persistence\allowbreak Assembler & Ensamblador para transformación bidireccional entre DtcCatalogEntry y DtcCatalogPersistenceEntity. \\*
\hline
\textbf{Categoría} & Ensamblador de Persistencia \\*
\hline
\textbf{Relaciones} & Traduce registros canónicos de normas automotrices aislando la lógica de dominio del esquema físico relacional. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak assemblers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Battery\allowbreak Voltage\allowbreak Attribute\allowbreak Converter & Convertidor JPA para transformación bidireccional entre el objeto de valor BatteryVoltage y la columna física DOUBLE PRECISION. \\*
\hline
\textbf{Categoría} & Conversor de Atributo JPA \\*
\hline
\textbf{Relaciones} & Implementa AttributeConverter validando voltajes automotrices válidos en el ciclo de persistencia relacional. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Confidence\allowbreak Score\allowbreak Attribute\allowbreak Converter & Convertidor JPA para mapeo del objeto de valor ConfidenceScore hacia la columna NUMERIC(5,2). \\*
\hline
\textbf{Categoría} & Conversor de Atributo JPA \\*
\hline
\textbf{Relaciones} & Implementa AttributeConverter garantizando precisión decimal en índices analíticos de certeza diagnóstica. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Device\allowbreak Identifier\allowbreak Attribute\allowbreak Converter & Convertidor JPA para transformación bidireccional entre DeviceIdentifier y la columna VARCHAR(100). \\*
\hline
\textbf{Categoría} & Conversor de Atributo JPA \\*
\hline
\textbf{Relaciones} & Implementa AttributeConverter asegurando formato normalizado de números de serie o direcciones MAC de hardware. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Dtc\allowbreak Code\allowbreak Attribute\allowbreak Converter & Convertidor JPA para mapeo del objeto de valor DtcCode hacia la columna VARCHAR(10). \\*
\hline
\textbf{Categoría} & Conversor de Atributo JPA \\*
\hline
\textbf{Relaciones} & Implementa AttributeConverter validando el formato estandarizado SAE J2012 de cinco caracteres alfanuméricos. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Engine\allowbreak Temperature\allowbreak Attribute\allowbreak Converter & Convertidor JPA para transformación bidireccional entre EngineTemperature y la columna física DOUBLE PRECISION. \\*
\hline
\textbf{Categoría} & Conversor de Atributo JPA \\*
\hline
\textbf{Relaciones} & Implementa AttributeConverter resguardando la escala en grados Celsius del refrigerante de motor. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Geo\allowbreak Coordinates\allowbreak Attribute\allowbreak Converter & Convertidor JPA para mapeo bidireccional del objeto de valor GeoCoordinates hacia pares de coordenadas geográficas. \\*
\hline
\textbf{Categoría} & Conversor de Atributo JPA \\*
\hline
\textbf{Relaciones} & Implementa AttributeConverter garantizando rangos válidos de latitud y longitud satelital GPS. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Device\allowbreak Installation\allowbreak Repository\allowbreak Impl & Adaptador secundario de salida que implementa el puerto de dominio DeviceInstallationRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Repositorio JPA \\*
\hline
\textbf{Relaciones} & Implementa DeviceInstallationRepository orquestando la persistencia relacional y consultas de sesiones activas. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Dtc\allowbreak Catalog\allowbreak Repository\allowbreak Impl & Adaptador secundario de salida que implementa el puerto de dominio DtcCatalogRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Repositorio JPA \\*
\hline
\textbf{Relaciones} & Implementa DtcCatalogRepository resolviendo descripciones en español y severidades canónicas de diagnóstico. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Obd2\allowbreak Device\allowbreak Repository\allowbreak Impl & Adaptador secundario de salida que implementa el puerto de dominio Obd2DeviceRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Repositorio JPA \\*
\hline
\textbf{Relaciones} & Conecta el puerto de dominio con Obd2DevicePersistenceRepository delegando transformaciones en el ensamblador respectivo. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Predictive\allowbreak Alert\allowbreak Repository\allowbreak Impl & Adaptador secundario de salida que implementa el puerto de dominio PredictiveAlertRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Repositorio JPA \\*
\hline
\textbf{Relaciones} & Implementa PredictiveAlertRepository gestionando el ciclo de vida de advertencias y vinculaciones con órdenes de servicio. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Vehicle\allowbreak Fault\allowbreak Repository\allowbreak Impl & Adaptador secundario de salida que implementa el puerto de dominio VehicleFaultRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Repositorio JPA \\*
\hline
\textbf{Relaciones} & Implementa VehicleFaultRepository persistiendo anomalías electrónicas y facilitando consultas de fallas abiertas. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Telemetry\allowbreak Log\allowbreak Persistence\allowbreak Entity & Mapeo relacional de series temporales de telemetría vehicular hacia la hipertabla telemetry\_logs de TimescaleDB. \\*
\hline
\textbf{Categoría} & Entidad de Serie Temporal TimescaleDB \\*
\hline
\textbf{Relaciones} & Clave primaria compuesta TelemetryRecordId sobre timestamp y vehicle\_id con índice temporal descendente en TimescaleDB. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak timescale.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Timescale\allowbreak Telemetry\allowbreak Jdbc\allowbreak Repository & Cliente JDBC Batch de acceso a datos de alto rendimiento para inserción masiva en ráfagas sobre hipertablas de TimescaleDB. \\*
\hline
\textbf{Categoría} & Cliente JDBC Batch de Hipertabla \\*
\hline
\textbf{Relaciones} & Emplea JdbcTemplate e inserciones SQL por lotes para ingesta continua sin sobrecarga de entidades JPA. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak timescale.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Timescale\allowbreak Telemetry\allowbreak Analytics\allowbreak Repository & Repositorio analítico de consultas estadísticas agregadas por ventanas de tiempo diario sobre la hipertabla telemetry\_logs. \\*
\hline
\textbf{Categoría} & Repositorio Analítico TimescaleDB \\*
\hline
\textbf{Relaciones} & Extiende Repository ejecutando la función time\_bucket de TimescaleDB para promedios y desviaciones estándar de sensores. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak timescale.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Timescale\allowbreak Telemetry\allowbreak Repository\allowbreak Impl & Adaptador de repositorio que implementa el puerto de dominio TelemetryLogRepository y el puerto de salida de aplicación. \\*
\hline
\textbf{Categoría} & Adaptador de Repositorio TimescaleDB \\*
\hline
\textbf{Relaciones} & Implementa TelemetryLogRepository utilizando TimescaleTelemetryJdbcRepository y TimescaleTelemetryPersistenceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak timescale.\allowbreak adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Timescale\allowbreak Telemetry\allowbreak Persistence\allowbreak Assembler & Ensamblador temporal para transformación bidireccional entre el agregado TelemetryRecord y la entidad de hipertabla. \\*
\hline
\textbf{Categoría} & Ensamblador de Persistencia Temporal \\*
\hline
\textbf{Relaciones} & Descompone objetos inmutables de telemetría hacia columnas de hipertabla e hidrata agregados sin eventos espurios. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak timescale.\allowbreak assemblers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Crm\allowbreak Fleet\allowbreak Acl\allowbreak Adapter & Adaptador cliente remoto hacia Customer and Fleet Management para resolución de titulares vehiculares y tokens móviles FCM. \\*
\hline
\textbf{Categoría} & Adaptador ACL Antifragilidad \\*
\hline
\textbf{Relaciones} & Implementa CrmFleetAclPort consumiendo CustomerContextFacade en memoria bajo el patrón Open Host Service. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak external.\allowbreak acl.\allowbreak crm} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Workshop\allowbreak Operations\allowbreak Acl\allowbreak Adapter & Adaptador cliente remoto hacia Workshop Operations para mapeo de averías y anclaje estricto al catálogo de servicios de taller. \\*
\hline
\textbf{Categoría} & Adaptador ACL Antifragilidad \\*
\hline
\textbf{Relaciones} & Implementa OperationsAclPort consumiendo WorkshopOperationsContextFacade bajo el patrón Open Host Service. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak external.\allowbreak acl.\allowbreak mro} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Groq\allowbreak Spring\allowbreak Ai\allowbreak Diagnostic\allowbreak Adapter & Adaptador perimetral de inferencia analítica sustentado en Spring AI con modelos LPU de ultra-baja latencia sobre Groq. \\*
\hline
\textbf{Categoría} & Adaptador de Inferencia con IA \\*
\hline
\textbf{Relaciones} & Implementa AiInferenceDiagnosticPort combinando telemetría de 30 días, fallas activas y catálogo de taller con BeanOutputConverter. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak external.\allowbreak ai.\allowbreak groq} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
IoT\allowbreak Outbox\allowbreak Message\allowbreak Relay\allowbreak Adapter & Retransmisor transaccional en segundo plano para publicación confiable de eventos de integración hacia el broker de mensajería. \\*
\hline
\textbf{Categoría} & Relay de Publicación Transaccional Outbox \\*
\hline
\textbf{Relaciones} & Implementa sondeo programado sobre la tabla outbox garantizando entrega at-least-once hacia RabbitMQ o Kafka. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak external.\allowbreak messaging.\allowbreak outbox} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Firebase\allowbreak Cloud\allowbreak Messaging\allowbreak Gateway\allowbreak Adapter & Pasarela perimetral de notificaciones push de alta prioridad hacia terminales móviles de conductores y jefes de taller. \\*
\hline
\textbf{Categoría} & Pasarela Push Notificaciones \\*
\hline
\textbf{Relaciones} & Implementa FcmNotificationAclPort aislando el SDK oficial de Google Firebase Admin con protocolo seguro HTTP v1. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak external.\allowbreak notification.\allowbreak firebase} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
OpenPdf\allowbreak Vehicle\allowbreak Health\allowbreak Report\allowbreak Generator\allowbreak Adapter & Adaptador perimetral para renderizado y compilación del Informe Pericial Unificado de salud automotriz en formato PDF. \\*
\hline
\textbf{Categoría} & Motor Generador de Documentos PDF \\*
\hline
\textbf{Relaciones} & Implementa VehicleHealthReportPdfGeneratorPort procesando plantillas XHTML con Thymeleaf y compilando con OpenPDF. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak external.\allowbreak reporting.\allowbreak openpdf} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes distribuidos en los subpaquetes modulares persistence.jpa, persistence.timescale y external bajo el paquete canónico com.andeva.atelier.platform.iot.infrastructure.

**Entidades de Persistencia JPA, Hipertabla Temporal y Esquema Relacional Físico**

El modelado relacional de persistencia reproduce la topología telemática y automotriz del dominio mediante cinco entidades JPA transaccionales en persistence.jpa.entities y una entidad de serie temporal en persistence.timescale.entities sobre PostgreSQL 16 con la extensión TimescaleDB. La entidad **Obd2DevicePersistenceEntity** mapea el hardware físico hacia la tabla **obd2_devices**, extendiendo de la clase abstracta de auditoría para registrar marcas temporales y versiones de control de concurrencia optimista. Por su parte, **DeviceInstallationPersistenceEntity** custodia en la tabla **device_installations** el historial cronológico de emparejamiento entre escáneres y vehículos, resguardando lecturas de odómetro inicial y final en kilómetros.

A su vez, **TelemetryLogPersistenceEntity** estructura el almacenamiento masivo sobre la hipertabla **telemetry_logs**, particionada automáticamente por intervalos de tiempo sobre la marca temporal UTC y respaldada por una clave primaria compuesta sobre el instante de captura y el identificador vehicular. Para el diagnóstico electrónico, **VehicleFaultPersistenceEntity** registra en la tabla **vehicle_faults** las averías bajo el estándar SAE J2012, mientras que **PredictiveAlertPersistenceEntity** custodia en **predictive_alerts** los pronósticos de degradación mecánica con índices de confianza analíticos. Finalmente, **DtcCatalogPersistenceEntity** normaliza el catálogo de definiciones automotrices en la tabla **dtc_catalog**. En la @tbl:iot-jpa-entities se detallan los esquemas relacionales, claves primarias, índices B-Tree y restricciones de estas entidades.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Especificación Relacional de Entidades JPA e Hipertabla de IoT Telemetry \& Predictive Maintenance} \label{tbl:iot-jpa-entities} \\
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} Obd2DevicePersistenceEntity \quad (\textit{Tabla:} \texttt{obd2\_devices})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{tenant\_id}, \texttt{device\_identifier}, \texttt{connection\_type}, \texttt{status}, \texttt{hardware\_model}, \texttt{firmware\_version}, \texttt{created\_at}, \texttt{updated\_at}, \texttt{version}, \texttt{deleted\_at} \\*
\hline
\textbf{Restricciones e Índices} & Restricción de unicidad estricta uk\_obd2\_devices\_identifier sobre la columna device\_identifier. Restricciones de verificación chk\_device\_conn\_type y chk\_device\_status para dominios de valores válidos. Índice B-Tree idx\_devices\_tenant\_status sobre (tenant\_id, status) para filtrado ágil de escáneres disponibles en patio de taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} DeviceInstallationPersistenceEntity \quad (\textit{Tabla:} \texttt{device\_installations})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{tenant\_id}, \texttt{device\_id}, \texttt{vehicle\_id}, \texttt{installed\_at}, \texttt{uninstalled\_at}, \texttt{initial\_odometer\_km}, \texttt{final\_odometer\_km}, \texttt{created\_at}, \texttt{updated\_at}, \texttt{version}, \texttt{deleted\_at} \\*
\hline
\textbf{Restricciones e Índices} & Claves foráneas fk\_installations\_device hacia obd2\_devices y fk\_installations\_vehicle hacia el módulo vehicular. Restricción de verificación chk\_odometer\_positive sobre kilometrajes no negativos y chk\_uninstalled\_after\_installed para consistencia cronológica. Índices B-Tree idx\_installations\_vehicle sobre vehicle\_id e idx\_installations\_device sobre device\_id para resolución inmediata de sesiones activas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA e Hipertabla:} TelemetryLogPersistenceEntity \quad (\textit{Hipertabla TimescaleDB:} \texttt{telemetry\_logs})} \\*
\hline
\textbf{Clave Primaria} & Clave compuesta \texttt{TelemetryRecordId(timestamp TIMESTAMPTZ, vehicle\_id UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{timestamp}, \texttt{vehicle\_id}, \texttt{tenant\_id}, \texttt{latitude}, \texttt{longitude}, \texttt{speed}, \texttt{engine\_temp\_c}, \texttt{rpm}, \texttt{fuel\_level\_pct}, \texttt{battery\_voltage} \\*
\hline
\textbf{Restricciones e Índices} & Hipertabla particionada automáticamente en bloques temporales de siete días mediante la función create\_hypertable de TimescaleDB. Índice temporal descendente idx\_telemetry\_vehicle\_time sobre las columnas (vehicle\_id, timestamp DESC). Política de compresión columnar activa sobre segmentos (vehicle\_id, tenant\_id) para particiones con antigüedad superior a treinta días. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} VehicleFaultPersistenceEntity \quad (\textit{Tabla:} \texttt{vehicle\_faults})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{tenant\_id}, \texttt{vehicle\_id}, \texttt{dtc\_code}, \texttt{severity}, \texttt{description}, \texttt{detected\_at}, \texttt{is\_resolved}, \texttt{resolved\_at}, \texttt{created\_at}, \texttt{updated\_at}, \texttt{version}, \texttt{deleted\_at} \\*
\hline
\textbf{Restricciones e Índices} & Clave foránea fk\_faults\_vehicle hacia el registro automotriz. Restricción de verificación chk\_fault\_severity sobre valores LOW, MEDIUM, HIGH y CRITICAL. Índices B-Tree idx\_faults\_vehicle\_dtc sobre (vehicle\_id, dtc\_code) e idx\_faults\_detected\_at sobre detected\_at para inspección inmediata de fallas mecánicas abiertas durante el servicio en bahía. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} PredictiveAlertPersistenceEntity \quad (\textit{Tabla:} \texttt{predictive\_alerts})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{tenant\_id}, \texttt{vehicle\_id}, \texttt{recommended\_service\_id}, \texttt{alert\_type}, \texttt{confidence\_score}, \texttt{message}, \texttt{status}, \texttt{fcm\_message\_id}, \texttt{created\_at}, \texttt{updated\_at}, \texttt{version}, \texttt{deleted\_at} \\*
\hline
\textbf{Restricciones e Índices} & Restricción de verificación chk\_confidence\_range que asegura un índice de certeza entre 0.00 y 1.00. Índices B-Tree idx\_alerts\_vehicle sobre vehicle\_id e idx\_alerts\_status sobre status para alimentar tableros de advertencia en tiempo real. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} DtcCatalogPersistenceEntity \quad (\textit{Tabla:} \texttt{dtc\_catalog})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{dtc\_code}, \texttt{system\_category}, \texttt{description\_es}, \texttt{description\_en}, \texttt{default\_severity}, \texttt{is\_critical}, \texttt{created\_at}, \texttt{updated\_at}, \texttt{version}, \texttt{deleted\_at} \\*
\hline
\textbf{Restricciones e Índices} & Restricción de unicidad estricta uk\_dtc\_catalog\_code sobre la columna dtc\_code. Índice B-Tree idx\_dtc\_category sobre system\_category para clasificaciones por subsistemas motrices, tren de fuerza, carrocería y chasis. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación relacional en PostgreSQL 16 y extensión TimescaleDB bajo Aiven Cloud.

**Repositorios Spring Data JPA y Adaptadores de Persistencia**

La mediación entre los contratos abstractos de persistencia del dominio y las operaciones físicas de base de datos se articula mediante interfaces Spring Data JPA en persistence.jpa.repositories y adaptadores de repositorio en persistence.jpa.adapters y persistence.timescale.adapters. El adaptador **Obd2DeviceRepositoryImpl** implementa el puerto de dominio **Obd2DeviceRepository**, canalizando consultas derivadas por identificador físico de hardware o taller automotriz. Del mismo modo, **DeviceInstallationRepositoryImpl** resuelve las sesiones activas de escáner en vehículos mediante métodos optimizados en **DeviceInstallationPersistenceRepository**, garantizando que una unidad automotriz no posea dos dispositivos montados simultáneamente.

Asimismo, **VehicleFaultRepositoryImpl** y **PredictiveAlertRepositoryImpl** gestionan el almacenamiento de anomalías y advertencias mecánicas, ofreciendo filtros por taller, vehículo y estado operativo para alimentar los tableros de control en bahía. Por su parte, **DtcCatalogRepositoryImpl** provee la recuperación de definiciones estandarizadas mediante **DtcCatalogPersistenceRepository**. Para la persistencia de alto flujo de mediciones telemáticas, el adaptador **TimescaleTelemetryRepositoryImpl** implementa **TelemetryLogRepository** utilizando el cliente especializado **TimescaleTelemetryJdbcRepository** y sentencias SQL parametrizadas por lotes. Este componente elude deliberadamente el ciclo de vida de entidades JPA para insertar ráfagas de cincuenta a cien registros en un único viaje de red hacia el motor de base de datos, complementándose con consultas estadísticas ejecutadas por **TimescaleTelemetryAnalyticsRepository**. En la @tbl:iot-repository-adapters se detallan los puertos de dominio, repositorios inyectados y operaciones provistas.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Adaptadores de Persistencia y Puertos de Dominio de IoT Telemetry \& Predictive Maintenance} \label{tbl:iot-repository-adapters} \\
\hline
\thfirst{Aspecto de Adaptador} & \thcell{Especificación Técnica y Persistencia} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Adaptador} & \thcell{Especificación Técnica y Persistencia} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} Obd2DeviceRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{Obd2DeviceRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{Obd2DevicePersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & Conecta el modelo de dominio con la base de datos relacional mediante Obd2DevicePersistenceAssembler. Provee métodos *save()* para alta y actualización de escáneres, *findById()* para hidratación por clave universal, *findByDeviceIdentifier()* para validación por código de fábrica y *existsByDeviceIdentifier()* para cerrojos de concurrencia. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} DeviceInstallationRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{DeviceInstallationRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{DeviceInstallationPersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & Administra la persistencia de sesiones de instalación vehicular en la tabla device\_installations. Provee métodos *save()* para iniciar o cerrar emparejamientos, *findActiveByVehicleId()* para resolver el escáner montado actualmente en la unidad y *findAllHistoryByVehicleId()* para auditoría histórica de intervenciones. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} VehicleFaultRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{VehicleFaultRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{VehicleFaultPersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & Persiste las averías electrónicas automotrices registradas en vehicle\_faults. Provee métodos *save()* para registrar o marcar como resuelta una falla, *findById()* para consulta puntual de avería y *findActiveByVehicleId()* optimizado para desplegar diagnósticos pendientes en el tacómetro de taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} PredictiveAlertRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{PredictiveAlertRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{PredictiveAlertPersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & Custodia el ciclo de vida de advertencias mecánicas preventivas en predictive\_alerts. Provee métodos *save()* para almacenamiento con identificador de mensaje push, *findAllByVehicleId()* para la cronología clínica de la unidad y *findAllByTenantIdAndStatus()* para alimentar consolas de despacho en taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} DtcCatalogRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{DtcCatalogRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{DtcCatalogPersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & Provee acceso canónico a las descripciones estandarizadas de fallas automotrices. Provee métodos *findByCode()* para traducir códigos alfanuméricos de cinco caracteres a definiciones en español, *findAllByCategory()* para inspecciones por subsistema y *existsByCode()* para verificaciones de catálogo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} TimescaleTelemetryRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{TelemetryLogRepository} \\*
\hline
\textbf{Tecnología y Cliente} & \texttt{TimescaleTelemetryJdbcRepository} con Spring JdbcClient y JdbcTemplate sobre PostgreSQL 16 con extensión TimescaleDB. \\*
\hline
\textbf{Operaciones Clave} & Adaptador de alto rendimiento para flujos telemáticos masivos. Ejecuta *saveAllBatch()* insertando ráfagas completas de lecturas mediante sentencias SQL por lotes, *findLatestByVehicleId()* recuperando la última métrica de motor de cada unidad automotriz registrada y *findHistoryAggregated()* para series agregadas por ventanas de tiempo. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Adaptadores de repositorio ubicados bajo los subpaquetes persistence.jpa.adapters y persistence.timescale.adapters.

**Ensambladores de Persistencia, Convertidores JPA y Erradicación de Transform**

El desacoplamiento estricto entre el esquema físico relacional y los tipos puros del dominio se materializa mediante ensambladores de persistencia bidireccionales y convertidores JPA, habiéndose erradicado totalmente el subpaquete transform en la persistencia de datos. El componente **Obd2DevicePersistenceAssembler** traduce el agregado **Obd2Device** hacia su entidad relacional desempaquetando identificadores fuertemente tipados y enumeraciones de conectividad, al tiempo que restaura agregados puros mediante métodos de fábrica sin disparar eventos de dominio espurios durante consultas. De forma idéntica, **DeviceInstallationPersistenceAssembler** descompone los valores de odómetro hacia tipos numéricos escalares y garantiza la integridad de marcas temporales Instant en UTC.

Por su parte, **VehicleFaultPersistenceAssembler** y **PredictiveAlertPersistenceAssembler** restauran entidades de avería y alerta preventiva, transformando cadenas DTC alfanuméricas, niveles de severidad y porcentajes de confianza sin alterar las reglas de encapsulamiento del modelo. Para el catálogo de diagnósticos, **DtcCatalogPersistenceAssembler** traduce registros normativos SAE hacia representaciones inmutables de dominio. Asimismo, **TimescaleTelemetryPersistenceAssembler** descompone lecturas inmutables de velocidad, temperatura de refrigerante, régimen de revoluciones por minuto y tensión de batería en parámetros posicionales SQL para su despacho por lotes en la hipertabla telemetry_logs. Esta arquitectura se complementa con seis convertidores JPA de atributos para garantizar la serialización de magnitudes físicas y tipados fuertes. En la @tbl:iot-persistence-assemblers se describen las transformaciones y mapeos de tipos implementados por estos componentes.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Ensambladores de Persistencia y Convertidores JPA de IoT Telemetry \& Predictive Maintenance} \label{tbl:iot-persistence-assemblers} \\
\hline
\thfirst{Aspecto de Mapeo} & \thcell{Tipos Relacionados y Transformación} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Mapeo} & \thcell{Tipos Relacionados y Transformación} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador de Persistencia:} Obd2DevicePersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{Obd2Device} $\longleftrightarrow$ \texttt{Obd2DevicePersistenceEntity} \\*
\hline
\textbf{Transformación} & Traduce identificadores fuertemente tipados DeviceId, TenantId y DeviceIdentifier hacia valores UUID y cadenas alfanuméricas. Convierte los enumerados ConnectionType y DeviceStatus hacia representaciones estándar VARCHAR. Reconstituye el agregado puro protegiendo sus invariantes de fábrica sin emitir eventos espurios. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador de Persistencia:} DeviceInstallationPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{DeviceInstallation} $\longleftrightarrow$ \texttt{DeviceInstallationPersistenceEntity} \\*
\hline
\textbf{Transformación} & Descompone los objetos de valor inicial y final de odómetro en columnas numéricas enteras. Convierte marcas temporales a objetos Instant en UTC. Reconstituye agregados de instalación validando la consistencia temporal entre la fecha de montaje y la fecha de desinstalación. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador de Persistencia:} VehicleFaultPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{VehicleFault} $\longleftrightarrow$ \texttt{VehicleFaultPersistenceEntity} \\*
\hline
\textbf{Transformación} & Mapea objetos de valor DtcCode y FaultSeverity hacia tipos relacionales normalizados. Preserva el estado booleano de resolución y marcas temporales de subsanación. Reconstituye la entidad de dominio manteniendo intacto el identificador de orden de trabajo vinculada. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador de Persistencia:} PredictiveAlertPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{PredictiveAlert} $\longleftrightarrow$ \texttt{PredictiveAlertPersistenceEntity} \\*
\hline
\textbf{Transformación} & Desempaqueta el objeto de valor ConfidenceScore hacia una columna escalar BigDecimal con dos decimales de precisión. Mapea tipos de advertencia AlertType y estados AlertStatus. Preserva el identificador de despacho FCM para auditoría de entrega push. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador de Persistencia:} DtcCatalogPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{DtcCatalogEntry} $\longleftrightarrow$ \texttt{DtcCatalogPersistenceEntity} \\*
\hline
\textbf{Transformación} & Mapea códigos de falla normalizados de cinco caracteres, descripciones oficiales en español e inglés, y niveles de severidad predeterminados. Convierte banderas booleanas de criticidad y resguarda la inmutabilidad del catálogo automotriz. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador Temporal:} TimescaleTelemetryPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{TelemetryRecord} $\longleftrightarrow$ \texttt{TelemetryLogPersistenceEntity} \\*
\hline
\textbf{Transformación} & Descompone objetos inmutables VehicleSpeed, EngineTemperature, EngineRpm, FuelLevel, BatteryVoltage y GeoCoordinates en parámetros posicionales y entidades de hipertabla optimizadas para inserción masiva en ráfagas batch mediante el cliente JDBC de TimescaleDB. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Ensambladores de persistencia ubicados bajo persistence.jpa.assemblers y persistence.timescale.assemblers.

**Adaptadores Externos Segregados por Tecnología y Clientes Anticorrupción**

La interacción con servicios externos en la nube, motores analíticos de inferencia pericial y contextos satélite de la plataforma Atelier se gestiona a través de adaptadores externos segregados por tecnología bajo el subpaquete infrastructure.external, implementando los puertos de salida definidos en la capa de aplicación. El componente **CrmFleetAclAdapter** en external.acl.crm consume en memoria la fachada de clientes y flotas para resolver tokens de notificación móvil y verificar el registro de unidades sin generar acoplamiento físico en base de datos. Por su parte, **WorkshopOperationsAclAdapter** en external.acl.mro consume la fachada de operaciones de taller bajo el patrón Open Host Service, anclando de forma estricta las recomendaciones predictivas al catálogo real de servicios facturables del taller.

En el ámbito de la inteligencia artificial y diagnóstico estructurado, **GroqSpringAiDiagnosticAdapter** en external.ai.groq materializa la inferencia pericial mediante Spring AI ChatClient sobre la infraestructura Groq LPU, analizando un doble horizonte temporal que combina las lecturas de telemetría de los últimos treinta días en TimescaleDB con las averías activas de la ECU. Para la exportación pericial, **OpenPdfVehicleHealthReportGeneratorAdapter** en external.reporting.openpdf procesa plantillas XHTML con Thymeleaf y compila el Informe Pericial Unificado en documentos PDF binarios con membrete institucional. Asimismo, **IoTOutboxMessageRelayAdapter** en external.messaging.outbox ejecuta la publicación programada y atómica de eventos de integración hacia el broker de mensajería bajo el patrón Transactional Outbox. Finalmente, **FirebaseCloudMessagingGatewayAdapter** en external.notification.firebase despacha notificaciones push de alta prioridad mediante el protocolo HTTP v1 de Google Firebase Admin hacia terminales móviles de conductores y jefes de taller. En la @tbl:iot-external-infrastructure se resumen las tecnologías y directrices de resiliencia de estos adaptadores.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Adaptadores Externos Segregados por Tecnología de IoT Telemetry \& Predictive Maintenance} \label{tbl:iot-external-infrastructure} \\
\hline
\thfirst{Componente de Integración} & \thcell{Especificación Técnica y Resiliencia} \\
\hline
\endfirsthead
\hline
\thfirst{Componente de Integración} & \thcell{Especificación Técnica y Resiliencia} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador ACL Antifragilidad:} CrmFleetAclAdapter} \\*
\hline
\textbf{Puerto Implementado} & \texttt{CrmFleetAclPort} \\*
\hline
\textbf{Tecnología y Cliente} & Fachada pública de contexto CustomerContextFacade consumida en memoria bajo el patrón Open Host Service. \\*
\hline
\textbf{Operaciones y Resiliencia} & Resuelve tokens móviles FCM de los propietarios y conductores asignados a la unidad vehicular consultando la fachada en memoria del cliente. Asegura que las advertencias predictivas alcancen oportunamente el dispositivo personal del titular del vehículo sin acoplamiento físico en base de datos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador ACL Antifragilidad:} WorkshopOperationsAclAdapter} \\*
\hline
\textbf{Puerto Implementado} & \texttt{OperationsAclPort} \\*
\hline
\textbf{Tecnología y Cliente} & Fachada pública de contexto WorkshopOperationsContextFacade (mro\_service\_catalog) consumida en memoria. \\*
\hline
\textbf{Operaciones y Resiliencia} & Mapea códigos de diagnóstico vehicular hacia paquetes de servicio preventivo del taller mediante el método *getAvailableWorkshopServices()*. Garantiza anclaje estricto a servicios facturables reales y provee tolerancia ante ausencia transitoria del catálogo operativo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador de Inferencia con IA:} GroqSpringAiDiagnosticAdapter} \\*
\hline
\textbf{Puerto Implementado} & \texttt{AiInferenceDiagnosticPort} \\*
\hline
\textbf{Tecnología y Cliente} & Framework Spring AI con ChatClient y modelos LPU de ultra-baja latencia sobre Groq bajo BeanOutputConverter para serialización tipada en Java 21 Records. \\*
\hline
\textbf{Operaciones y Resiliencia} & Analiza simultáneamente el estado instantáneo de la unidad y el historial acumulado de treinta días en TimescaleDB, anclando recomendaciones al catálogo de servicios de MRO. Aplica control de temperatura en 0.1 y políticas de reintento automático con respaldo determinista ante contingencias de conectividad. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Relay de Publicación Transaccional Outbox:} IoTOutboxMessageRelayAdapter} \\*
\hline
\textbf{Puerto Implementado} & Componente transaccional de retransmisión de eventos de integración \\*
\hline
\textbf{Tecnología y Cliente} & Tarea programada en segundo plano con Spring Scheduling y RabbitTemplate sobre RabbitMQ o productor Kafka. \\*
\hline
\textbf{Operaciones y Resiliencia} & Realiza sondeos programados sobre la tabla outbox de mensajes pendientes, despachando eventos de integración telemáticos con garantías de entrega at-least-once y confirmación asíncrona hacia el broker de mensajería corporativo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Pasarela Push Notificaciones:} FirebaseCloudMessagingGatewayAdapter} \\*
\hline
\textbf{Puerto Implementado} & \texttt{FcmNotificationAclPort} \\*
\hline
\textbf{Tecnología y Cliente} & SDK oficial de Google Firebase Admin v9 mediante protocolo seguro HTTP v1. \\*
\hline
\textbf{Operaciones y Resiliencia} & Despacha notificaciones push de alta prioridad con cargas útiles estructuradas hacia terminales móviles de conductores y jefes de taller por el canal atelier\_critical\_alerts. Incorpora reintentos exponenciales automáticos y aislamiento de fallos para evitar que demoras en la red de Google degraden la ingesta telemática central. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Motor Generador de Documentos PDF:} OpenPdfVehicleHealthReportGeneratorAdapter} \\*
\hline
\textbf{Puerto Implementado} & \texttt{VehicleHealthReportPdfGeneratorPort} \\*
\hline
\textbf{Tecnología y Cliente} & Motor de plantillas XHTML Thymeleaf 3.1 y biblioteca de renderizado OpenPDF 1.3 mediante canalización en memoria. \\*
\hline
\textbf{Operaciones y Resiliencia} & Compila el Informe Pericial Unificado estructurado en formato binario PDF aplicando maquetación institucional con membrete del taller, semáforos cromáticos de salud mecánica, desglose de subsistemas y correlación causal DTC frente a señales sensoriales. Incorpora canalización atómica en memoria para prevenir fugas de recursos del servidor. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Adaptadores externos segregados por tecnología bajo el paquete canónico com.andeva.atelier.platform.iot.infrastructure.external.

El diseño de la Capa de Infraestructura de IoT Telemetry & Predictive Maintenance asegura el aislamiento completo entre el flujo continuo de ingesta de señales automotrices y las transacciones comerciales de la plataforma Atelier. Al desacoplar la persistencia temporal en TimescaleDB de las entidades de auditoría relacionales en PostgreSQL 16, el sistema preserva la estabilidad operativa del motor principal incluso ante ráfagas simultáneas emitidas por cientos de vehículos conectados en ruta o terminales móviles en talleres de patio.

Asimismo, la sustitución deliberada de Hibernate por inserciones directas mediante operaciones por lotes en el adaptador telemático permite procesar ráfagas de lecturas con una sobrecarga de memoria mínima y tiempos de inserción en base de datos del orden de microsegundos. Este enfoque de alto rendimiento garantiza que los algoritmos de detección de anomalías dispongan de datos actualizados sin provocar contención de bloqueos relacionales sobre las tablas de inventario físico o sesiones de montaje.

Esta arquitectura perimetral se extiende hacia las terminales móviles de patio y cabina vehicular en las aplicaciones cliente Atelier Workshop y Atelier Driver. Ante pérdidas transitorias de cobertura celular en carretera o zonas ciegas del taller, los dispositivos resguardan las lecturas sensoriales en una base de datos local SQLite 3 gestionada mediante Room en Android y Drift en Flutter, ejecutando una sincronización masiva en bloque hacia el adaptador telemático tan pronto se restablece el enlace de red.

Finalmente, la integración perimetral con Firebase Cloud Messaging y las capas anticorrupción hacia los contextos de taller y clientes consolidan un ecosistema predictivo verdaderamente reactivo. La detección inmediata de averías mecánicas críticas desencadena notificaciones push hacia los dispositivos móviles de los conductores en cuestión de milisegundos, vinculando automáticamente recomendaciones de servicio preventivo que optimizan la gestión de citas en los talleres automotrices y mitigan el riesgo de fallas catastróficas en carretera.


#### 2.6.9.5. Bounded Context Software Architecture Component Level Diagrams

En esta sección se presenta la descomposición arquitectónica interna del contenedor central **API Application** en relación con el Bounded Context **IoT Telemetry & Predictive Maintenance**, bajo el paquete canónico com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak iot, dando estricto cumplimiento al Nivel 3 del Modelo C4.

Dentro de la arquitectura de monolito modular de Atelier Platform, el Bounded Context IoT Telemetry & Predictive Maintenance opera como el centro de ingesta masiva de señales automotrices, procesamiento analítico en tiempo real y gobierno de alertas preventivas. Su diseño táctico garantiza la captura ininterrumpida de ráfagas de telemetría emitidas por adaptadores físicos OBD-II y módems celulares, previene degradaciones de rendimiento en el esquema transaccional mediante el uso de hipertablas temporales en TimescaleDB, e infiere anomalías de motor en milisegundos mediante motores de evaluación analítica desacoplados.

Todos los controladores perimetrales, servicios de aplicación CQRS, manejadores de eventos, motores analíticos de inferencia predictiva, repositorios de persistencia híbrida y fachadas en memoria se articulan de manera armónica para brindar una experiencia reactiva y confiable a las estaciones de trabajo de taller, terminales móviles de mecánicos y conductores en carretera.

En la @tbl:iot-c4-components se presenta el catálogo estructurado de los siete componentes de software constitutivos del Bounded Context IoT Telemetry & Predictive Maintenance dentro del contenedor central de la aplicación.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.5cm} | >{\raggedright\arraybackslash}p{10.9cm} |}
\caption{Catálogo de Componentes de Arquitectura de Software del Bounded Context IoT Telemetry \& Predictive Maintenance} \label{tbl:iot-c4-components} \\
\hline
\thfirst{Aspecto Técnico} & \thcell{Especificación de Arquitectura} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto Técnico} & \thcell{Especificación de Arquitectura} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} IoT REST Controllers \& Resource Assemblers Component} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring MVC, SpringDoc OpenAPI, Jakarta Validation, Spring HATEOAS \\*
\hline
\textbf{Responsabilidad} & Expone endpoints REST perimetrales para ingesta masiva por lotes de telemetría vehicular, aprovisionamiento de adaptadores OBD-II, sesiones de montaje en vehículos, consulta de averías electrónicas, tablero de advertencias predictivas y generación pericial de informes de salud vehicular con descarga binaria en formato PDF. Valida contratos DTO mediante Jakarta Validation, canaliza errores con Problem Details bajo RFC 7807 y proyecta representaciones hipermedia enriquecidas. \\*
\hline
\textbf{Relaciones} & Invocado por módems celulares con tarjeta SIM en vehículos vía HTTP POST masivo, y por Web Application, Mobile Workshop y Mobile Driver mediante peticiones HTTPS seguras para consulta operativa y descarga de reportes clínicos. Despacha comandos de ingesta, montaje físico, resolución de averías y generación de informes periciales hacia IoT CQRS Application Services Component. Emplea ensambladores de recursos REST para transformar modelos de dominio en representaciones hipermedia. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} IoT CQRS Application Services Component} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring Service, Transactional, CQRS, Java 21 Records \\*
\hline
\textbf{Responsabilidad} & Orquesta casos de uso transaccionales de ingesta de señales telemáticas, emparejamiento físico de escáneres, resolución de averías DTC, despacho de advertencias mecánicas predictivas y coordinación de diagnósticos periciales asistidos por inteligencia artificial. Aísla las capas perimetrales mediante tipos monádicos Result, gobierna la persistencia automática de riesgos detectados y coordina la ejecución transaccional atómica. \\*
\hline
\textbf{Relaciones} & Invocado por IoT REST Controllers \& Resource Assemblers Component. Ejecuta reglas de invariantes en IoT Domain Model \& Predictive Analytics Engines Component, persiste lecturas en IoT Persistence Repositories, JPA \& TimescaleDB Adapters Component, solicita inferencia diagnóstica y despacho push a IoT External Gateways \& Cloud Adapters Component y emite eventos hacia IoT Event Handlers \& Outbox Worker Component. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} IoT Event Handlers \& Outbox Worker Component} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring Events, TransactionalEventListener, Transactional Outbox Pattern \\*
\hline
\textbf{Responsabilidad} & Captura eventos de dominio e integración tras el commit transaccional, procesando notificaciones de telemetría procesada y anomalías de motor detectadas. Dispara notificaciones push reactivas hacia terminales móviles y asegura la entrega confiable de mensajes mediante el patrón Transactional Outbox. \\*
\hline
\textbf{Relaciones} & Recibe eventos publicados por IoT CQRS Application Services Component y eventos de integración consumidos de otros contextos. Invoca IoT External Gateways \& Cloud Adapters Component para despacho inmediato de notificaciones push críticas hacia conductores. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} IoT Domain Model \& Predictive Analytics Engines Component} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Java 21, Domain-Driven Design, Inmutabilidad, Estándar SAE J2012 e ISO 15031-6 \\*
\hline
\textbf{Responsabilidad} & Custodia los invariantes automotrices en los agregados Obd2Device, DeviceInstallation, VehicleFault, PredictiveAlert y TelemetryRecord, junto a la entidad dependiente DtcCatalogEntry. Alberga los motores analíticos PredictiveAnomalyDetectionEngine para inferencia de sobrecalentamiento y fallas eléctricas en milisegundos, DtcCodeEvaluationService para clasificación de severidad de códigos de error y VehicleThermodynamicEvaluationService para análisis de dinámicas de disipación térmica. \\*
\hline
\textbf{Relaciones} & Invocado por IoT CQRS Application Services Component para evaluación de métricas y validación de reglas de dominio. Emite eventos de dominio inmutables hacia las capas de orquestación de aplicación. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} IoT Persistence Repositories, JPA \& TimescaleDB Adapters Component} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Jakarta Persistence 3.1, Spring Data JPA, Hibernate 6, Spring JdbcClient, TimescaleDB 2.14 \\*
\hline
\textbf{Responsabilidad} & Materializa la arquitectura de persistencia híbrida. Gestiona entidades relacionales auditadas en PostgreSQL 16 para inventario de escáneres, sesiones de montaje, fallas y catálogo DTC, y ejecuta inserciones masivas en bloque de alta velocidad sobre la hipertabla particionada telemetry\_logs en TimescaleDB sin sobrecarga de Hibernate. \\*
\hline
\textbf{Relaciones} & Invocado por IoT CQRS Application Services Component y consultado analíticamente por IoT Open Host Facade \& Tacometer Evaluation Component. Conecta vía TCP y JDBC hacia el contenedor anfitrión Database. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} IoT Open Host Facade \& Tacometer Evaluation Component} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring Service, Open Host Service Pattern, In-Memory ACL \\*
\hline
\textbf{Responsabilidad} & Expone un contrato público estable en memoria que suministra odómetro digital en tiempo real, última lectura telemática y diagnóstico vehicular activo para Workshop Operations y Customer \& Fleet Management, erradicando acoplamientos físicos en base de datos. \\*
\hline
\textbf{Relaciones} & Invocado en memoria por Workshop Operations Module para apertura de órdenes de trabajo y Customer \& Fleet Module para monitoreo de salud de flotas. Recupera lecturas más recientes desde IoT Persistence Repositories, JPA \& TimescaleDB Adapters Component. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} IoT External Gateways \& Cloud Adapters Component} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Google Firebase Admin SDK v9, Spring AI ChatClient, OpenPDF, Thymeleaf, HTTP v1 API, In-Memory ACL \\*
\hline
\textbf{Responsabilidad} & Conecta con Google Firebase Cloud Messaging para despacho de notificaciones push de alta prioridad ante averías críticas, ejecuta inferencia analítica ultra-rápida sustentada en Spring AI sobre la infraestructura de Groq Cloud LPU mediante el modelo fundacional Llama 3.3 70B, compila informes periciales en formato PDF mediante OpenPDF y Thymeleaf, e implementa adaptadores de cliente anticorrupción hacia Workshop Operations para mapear fallas a servicios preventivos y Customer \& Fleet para resolver tokens móviles FCM de conductores. \\*
\hline
\textbf{Relaciones} & Invocado por IoT CQRS Application Services Component y IoT Event Handlers \& Outbox Worker Component. Conecta vía HTTPS con TLS hacia Firebase Cloud Messaging y Groq Cloud LPU, y consulta en memoria las fachadas de Workshop Operations Module y Customer \& Fleet Module. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al contenedor API Application en com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak iot.

En la @fig:c4-component-iot se ilustra el diagrama C4 de componentes para el Bounded Context IoT Telemetry & Predictive Maintenance, detallando las interacciones entre los componentes internos del módulo, los clientes perimetrales, los bounded contexts adyacentes de la plataforma y los servicios de infraestructura externa de ingesta masiva y mensajería push.

![Diagrama de Componentes C4 (Nivel 3) para el Bounded Context IoT Telemetry & Predictive Maintenance en API Application](report/assets/c4-diagrams/component-level-diagram-iot.png){#fig:c4-component-iot}

*Nota.* Diagrama generado mediante Structurizr DSL y PlantUML bajo el enfoque de Diagram-as-Code.

**Dinámica de Interacción y Flujos Operativos del Bounded Context IoT Telemetry & Predictive Maintenance**

Para formalizar la colaboración sincronizada entre los componentes internos del módulo de telemetría y los sistemas externos durante la operación vehicular diaria, se analizan a continuación los cuatro ciclos operacionales más representativos de la solución:

- **Ciclo de Ingesta Masiva por Lotes y Persistencia de Series Temporales (TimescaleDB):**
  El proceso se desencadena cuando un módem celular o un adaptador físico OBD-II transmite un paquete comprimido de lecturas sensoriales recopiladas en ruta hacia el endpoint perimetral de la plataforma. La solicitud arriba a **IoT REST Controllers & Resource Assemblers Component**, el cual verifica la validez del identificador del dispositivo y la firma de autenticación del mensaje, trasladando la carga útil hacia **IoT CQRS Application Services Component** mediante el comando **IngestTelemetryBatchCommand**.

  El servicio de aplicación coordina la inserción directa en bloque invocando a **IoT Persistence Repositories, JPA & TimescaleDB Adapters Component**, donde un adaptador especializado ejecuta sentencias SQL masivas de alta velocidad empleando Spring JdbcClient sobre la hipertabla particionada **telemetry_logs** en TimescaleDB, evitando por completo la sobrecarga de introspección relacional de Hibernate. Tras la confirmación del lote, el servicio actualiza el odómetro virtual del automotor y publica el evento de dominio inmutable **TelemetryBatchIngestedEvent** para activar de forma asíncrona los mecanismos analíticos de detección de fallas.

- **Ciclo de Detección Analítica de Anomalías de Motor y Despacho Push Reactivo (Firebase Cloud Messaging):**
  Este flujo asegura la protección activa del automotor ante anomalías térmicas o mecánicas incipientes. Al asentarse las nuevas lecturas sensoriales, el componente **IoT Domain Model & Predictive Analytics Engines Component** somete los registros al motor especializado **PredictiveAnomalyDetectionEngine**, evaluando en milisegundos si la temperatura de refrigerante sobrepasa el umbral crítico de 105.0°C durante intervalos consecutivos o si la tensión de batería desciende de forma anómala por debajo de 11.8 V con motor encendido.

  Al confirmarse una condición de riesgo, el motor analítico instancia el agregado **VehicleFault** y emite la alerta predictiva **PredictiveAlert**. El componente **IoT Event Handlers & Outbox Worker Component** captura el suceso, persiste el mensaje en la tabla transaccional de outbox para garantizar tolerancia a caídas de red y delega en **IoT External Gateways & Cloud Adapters Component** el despacho telemático inmediato hacia Google Firebase Cloud Messaging v1, logrando que la notificación push de advertencia alcance la pantalla del conductor y del jefe de flota en cuestión de milisegundos.

- **Ciclo de Diagnóstico Pericial Asistido por Inteligencia Artificial y Emisión de Informes PDF (Groq Cloud LPU y OpenPDF):**
  Este ciclo se activa cuando el personal técnico del taller o el conductor solicitan una evaluación clínica integral del automotor desde la aplicación web o el dispositivo móvil. La petición arriba a **IoT REST Controllers & Resource Assemblers Component**, el cual traslada el comando **GenerateVehicleHealthReportCommand** hacia **IoT CQRS Application Services Component**.

  El servicio de aplicación coordina la extracción de agregaciones continuas de series temporales en **IoT Persistence Repositories, JPA & TimescaleDB Adapters Component** mediante la función *time_bucket()* y compila el inventario de códigos DTC activos desde la tabla relacional **vehicle_faults**. Con este vector estadístico consolidado, delega la inferencia en **IoT External Gateways & Cloud Adapters Component**, donde el adaptador perimetral sustentado en Spring AI invoca la infraestructura de **Groq Cloud LPU** ejecutando el modelo fundacional **Llama 3.3 70B Versatile**, alcanzando una velocidad de procesamiento de ~500 tokens por segundo y una latencia de respuesta inferior a 0.8 segundos.

  El resultado estructurado clasifica los hallazgos en sistemas de motor, refrigeración, frenos y batería, asignando probabilidades porcentuales de avería y recomendaciones preventivas de mantenimiento. El servicio persiste automáticamente en la base de datos relacional aquellas advertencias con certeza estadística mayor o igual al 70 por ciento dentro del agregado **PredictiveAlert**, y delega en el motor tipográfico **OpenPDF** la maquetación sobre una plantilla XHTML procesada por **Thymeleaf**, produciendo el informe pericial en formato PDF listo para su descarga inmediata o archivo clínico.

- **Ciclo de Interoperabilidad en Memoria y Diagnóstico Preventivo para Mantenimiento de Flotas:**
  Para habilitar la sincronización entre el estado físico de los vehículos y la planificación técnica del taller sin incurrir en acoplamientos a nivel de base de datos, este ciclo se activa cuando los módulos de **Workshop Operations** o **Customer & Fleet Management** requieren verificar el kilometraje real o los códigos de falla almacenados. El subsistema solicitante invoca en memoria la interfaz expuesta por **IoT Open Host Facade & Tacometer Evaluation Component** mediante métodos limpios como *getVehicleOdometer()* o *getVehicleLatestTelemetry()*.

  El componente de fachada recupera la información consolidada interactuando con **IoT Persistence Repositories, JPA & TimescaleDB Adapters Component**, resolviendo la consulta en microsegundos sin bloquear el esquema transaccional. Esta interoperabilidad desacoplada permite que el asesor de servicio visualice instantáneamente el odómetro certificado al momento de admitir una orden de trabajo en la bahía de atención, transformando las señales sensoriales continuas en recomendaciones automatizadas de mantenimiento preventivo para el taller automotriz.

El diseño de componentes de IoT Telemetry & Predictive Maintenance responde rigurosamente a las exigencias de alta concurrencia, disponibilidad continua y aislamiento perimetral demandadas por la telemetría automotriz moderna. Al confinar la ingesta masiva en un adaptador JDBC por lotes y delegar las lecturas temporales hacia la hipertabla particionada **telemetry_logs** en TimescaleDB, el sistema elimina por completo la contención de bloqueos relacionales sobre las tablas de inventario físico y sesiones de montaje, garantizando tiempos de respuesta deterministas incluso ante ráfagas simultáneas generadas por flotas vehiculares de gran escala.

Asimismo, la integración desacoplada mediante Google Firebase Cloud Messaging v1 y el patrón Transactional Outbox confiere una robusta tolerancia a fallos transitorios de red. La detección inmediata de averías mecánicas críticas por parte del motor analítico desencadena notificaciones push hacia los dispositivos móviles de los conductores en cuestión de milisegundos, asegurando que las alertas de seguridad vial alcancen oportunamente a los usuarios sin comprometer el ciclo transaccional principal de la API central.

Esta arquitectura perimetral se extiende de forma sinérgica hacia las terminales móviles de patio y cabina en las aplicaciones Atelier Workshop y Atelier Driver. Ante pérdidas eventuales de enlace celular en ruta o zonas sin cobertura, los dispositivos móviles preservan las lecturas sensoriales en una base de datos local SQLite 3 gestionada mediante Room en Android y Drift en Flutter, ejecutando una sincronización masiva en bloque tan pronto se restablece la conectividad hacia el backend.

Finalmente, la exposición de tacómetro y odómetro virtual mediante la fachada Open Host Service consolida una interoperabilidad limpia en memoria con los módulos de órdenes de trabajo y gestión de flotas. Este mecanismo desacopla la persistencia física de series temporales y erradica dependencias directas de base de datos entre módulos, transformando las señales físicas del motor en acciones preventivas automatizadas para el taller mecánico.


#### 2.6.9.6. Bounded Context Software Architecture Code Level Diagrams

En esta sección se desarrolla la especificación técnica de menor nivel de abstracción para la arquitectura de software del Bounded Context **IoT Telemetry & Predictive Maintenance**, trasladando las fronteras conceptuales y las responsabilidades tácticas hacia contratos estáticos de código ejecutable. Mediante esta formalización, se asegura que la captura ininterrumpida de ráfagas de telemetría, el diagnóstico automotriz estandarizado y los algoritmos de detección analítica de anomalías mecánicas se materialicen con estricta seguridad de tipos y determinismo computacional.

Esta perspectiva de diseño abarca dos representaciones arquitectónicas complementarias: el Diagrama de Clases de la Capa de Dominio, que modela en memoria las raíces de agregado, objetos de valor inmutables, motores algorítmicos de inferencia predictiva y puertos de persistencia, y el Diagrama de Base de Datos, que formaliza el esquema físico híbrido relacional en PostgreSQL 16 y series temporales sobre hipertablas particionadas en TimescaleDB.

##### 2.6.9.6.1. *Bounded Context Domain Layer Class Diagrams*

El modelado estático de la Capa de Dominio del Bounded Context IoT Telemetry & Predictive Maintenance establece las estructuras operativas que gobiernan el inventario de escáneres telemáticos, las sesiones de montaje físico en vehículos, el catálogo universal de códigos DTC bajo normativas SAE J2012 e ISO 15031-6, y la generación de advertencias mecánicas predictivas. Su diseño táctico prioriza la pureza algorítmica sin dependencias de frameworks tecnológicos, erradica la obsesión por tipos primitivos mediante identificadores fuertemente tipados y garantiza tiempos de inferencia analítica en microsegundos para proteger la seguridad vehicular en ruta.

En la @fig:class-diagram-iot se expone el Diagrama de Clases UML detallado para la Capa de Dominio de IoT Telemetry & Predictive Maintenance, diseñado conforme a la notación formal UML y compilado mediante la herramienta PlantUML bajo el enfoque de Diagram-as-Code.

![Diagrama de Clases UML de la Capa de Dominio para el Bounded Context IoT Telemetry & Predictive Maintenance](report/assets/class-diagrams/class-diagram-iot.png){#fig:class-diagram-iot}

*Nota.* Elaboración propia en base al diseño táctico de dominio y el estándar UML en PlantUML.

La organización interna del modelo estático se estructura en ocho paquetes cohesivos que encapsulan las responsabilidades del dominio telemático y analítico:

- **Raíces de Agregado y Entidades Dependientes (domain.model.aggregates y domain.model.entities):**
  Gobierna las entidades maestras que delimitan las fronteras de consistencia transaccional y la serie temporal telemática. Comprende cuatro raíces de agregado relacionales (**Obd2Device** para inventario físico de hardware, **DeviceInstallation** para sesiones de emparejamiento, **VehicleFault** para averías electrónicas y **PredictiveAlert** para advertencias formuladas analíticamente), una raíz de serie temporal append-only (**TelemetryRecord** para lecturas multidimensionales continuas) y la entidad dependiente **DtcCatalogEntry** para el catálogo universal de diagnóstico. Todas las raíces transaccionales extienden de **AbstractDomainAggregateRoot<T>**.

- **Identificadores Fuertemente Tipados (domain.model.ids):**
  Implementa el contrato **TypedId<UUID>** mediante registros Java inmutables que erradican la obsesión por tipos primitivos y blindan la seguridad de tipos en tiempo de compilación: **DeviceId**, **InstallationId**, **FaultId**, **AlertId** y **DtcCatalogId**. Estos identificadores se articulan armónicamente con identidades foráneas transversales del Shared Kernel como **TenantId**, **VehicleId** y **ServiceId**.

- **Objetos de Valor Sensoriales y Métricos (domain.model.valueobjects):**
  Encapsula magnitudes físicas y reglas de validación en registros inmutables sin identidad propia: **DeviceIdentifier** con validación estricta de dirección MAC o código celular IMEI, **DtcCode** con sintaxis reglamentaria SAE J2012, **ConfidenceScore** con certeza estadística de 0.00 a 100.00, **EngineTemperature** con termometría de sobrecalentamiento crítico, **EngineRpm** para régimen de giro de motor, **VehicleSpeed** para velocidad lineal instantánea acotada, **BatteryVoltage** con diagnóstico de tensión eléctrica, **FuelLevel** para aforo porcentual, **GeoCoordinates** para posicionamiento GPS geodésico y **TelemetryPids** para el mapa inmutable de parámetros normalizados.

- **Enumeraciones de Dominio (domain.model.enums):**
  Estandariza los vocabularios controlados e invariantes operacionales del subsistema mediante seis enumeraciones inmutables: **ConnectionType** (canales físicos BLUETOOTH_BLE, SIM_CELLULAR y WIFI), **DeviceStatus** (situaciones ACTIVE, INACTIVE, LOST y BROKEN), **FaultSeverity** (criticidad LOW, MEDIUM y CRITICAL), **AlertSeverity** (gravedad de advertencia LOW, MEDIUM, HIGH y CRITICAL), **AlertStatus** (ciclo DISPATCHED, ACKNOWLEDGED, RESOLVED y DISMISSED) y **RiskLevel** (escala analítica LOW, MODERATE, HIGH y CRITICAL).

- **Servicios de Dominio de Inferencia y Diagnóstico (domain.services):**
  Concentra la lógica de negocio algorítmica y determinista independiente de frameworks tecnológicos: **PredictiveAnomalyDetectionEngine** para evaluación de lecturas de motor en tiempo real y disparo de alertas preventivas, **DtcCodeEvaluationService** para catalogación taxonómica de fallas y recomendación de paquetes de servicio de taller, y **VehicleThermodynamicEvaluationService** para modelado de gradientes térmicos y disipación de calor del bloque motriz.

- **Puertos de Repositorio (domain.repositories):**
  Declara los contratos abstractos de persistencia agnósticos a la tecnología subyacente: **Obd2DeviceRepository** para inventario y unicidad de hardware, **DeviceInstallationRepository** para sesiones de emparejamiento activo e historial, **TelemetryRecordRepository** para inserciones masivas por lotes y agregaciones temporales, **VehicleFaultRepository** para historial de averías detectadas, **PredictiveAlertRepository** para despacho y seguimiento de alertas preventivas, y **DtcCatalogRepository** para consultas sobre el catálogo maestro de fallas.

- **Eventos de Dominio Inmutables (domain.model.events):**
  Formaliza las transiciones de estado y sucesos de negocio para su propagación asíncrona mediante el patrón Transactional Outbox: **CriticalEngineAnomalyDetectedEvent**, **DeviceInstalledOnVehicleEvent**, **DeviceUninstalledFromVehicleEvent**, **Obd2DeviceRegisteredEvent**, **PredictiveAlertAcknowledgedEvent**, **PredictiveAlertDispatchedEvent**, **PredictiveAlertGeneratedEvent**, **TelemetryBatchIngestedEvent**, **VehicleFaultDetectedEvent** y **VehicleFaultResolvedEvent**.

- **Jerarquía de Excepciones Semánticas (domain.exceptions):**
  Especializa la jerarquía no comprobada derivada de **IoTDomainException** con mapeo directo a códigos Problem Details bajo la norma RFC 7807: **ActiveInstallationConflictException**, **DeviceAlreadyInstalledException**, **DeviceNotFoundException**, **InstallationNotFoundException**, **InvalidDeviceIdentifierException**, **InvalidDtcCodeException**, **PredictiveAlertNotFoundException**, **TimescaleIngestionException** y **VehicleFaultNotFoundException**.

En la @tbl:iot-domain-classes-members se detalla la especificación formal de atributos, firmas de métodos, modificadores de acceso y reglas de negocio para cada componente de la Capa de Dominio.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo exhaustivo de clases, miembros, ámbitos y relaciones de la Capa de Dominio del Bounded Context IoT Telemetry \& Predictive Maintenance} \label{tbl:iot-domain-classes-members} \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Obd2Device \quad (\textit{Aggregate Root})} \\*
\hline
Atributos y composición & Raíz de agregado que custodia el inventario físico de escáneres telemáticos y su canal de transmisión. Generalización de AbstractDomainAggregateRoot<DeviceId>. Composición con DeviceIdentifier, ConnectionType y DeviceStatus. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{DeviceId id} \newline - \texttt{TenantId tenantId} \newline - \texttt{DeviceIdentifier deviceIdentifier} \newline - \texttt{ConnectionType connectionType} \newline - \texttt{DeviceStatus status} \newline - \texttt{String hardwareModel} \newline - \texttt{String firmwareVersion} \newline - \texttt{Instant registeredAt} \newline - \texttt{Optional<\allowbreak Instant>\allowbreak  lastHeartbeatAt} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Factoría y gestión operativa & Invariantes: el dispositivo nace en estado ACTIVE. El identificador de hardware es inmutable y unívoco. El latido telemático actualiza la marca de tiempo de actividad. Emite Obd2DeviceRegisteredEvent. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Obd2Device register(TenantId,\allowbreak  DeviceIdentifier,\allowbreak  ConnectionType,\allowbreak  String,\allowbreak  String)} \newline - \texttt{void recordHeartbeat(Instant)} \newline - \texttt{void markActive()} \newline - \texttt{void markInactive()} \newline - \texttt{void markLost()} \newline - \texttt{void markBroken()} \newline - \texttt{void updateFirmware(String)} \newline - \texttt{DeviceId id()} \newline - \texttt{TenantId tenantId()} \newline - \texttt{DeviceIdentifier deviceIdentifier()} \newline - \texttt{ConnectionType connectionType()} \newline - \texttt{DeviceStatus status()} \newline - \texttt{boolean isOperational()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} DeviceInstallation \quad (\textit{Aggregate Root})} \\*
\hline
Atributos y vigencia & Raíz de agregado que delimita la sesión física de montaje de un escáner en un automotor. Custodia kilometrajes iniciales y finales para auditoría de odómetro. Generalización de AbstractDomainAggregateRoot<InstallationId>. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{InstallationId id} \newline - \texttt{TenantId tenantId} \newline - \texttt{DeviceId deviceId} \newline - \texttt{VehicleId vehicleId} \newline - \texttt{Instant installedAt} \newline - \texttt{Optional<\allowbreak Instant>\allowbreak  uninstalledAt} \newline - \texttt{int initialOdometerKm} \newline - \texttt{Optional<\allowbreak Integer>\allowbreak  finalOdometerKm} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Ciclo de vida y montaje & Invariantes: un automotor solo puede registrar una instalación activa simultáneamente. El kilometraje final de desmontaje debe ser mayor o igual al inicial. Emite DeviceInstalledOnVehicleEvent y DeviceUninstalledFromVehicleEvent. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{DeviceInstallation install(DeviceId,\allowbreak  VehicleId,\allowbreak  TenantId,\allowbreak  int,\allowbreak  Instant)} \newline - \texttt{void uninstall(int,\allowbreak  Instant)} \newline - \texttt{boolean isActive()} \newline - \texttt{InstallationId id()} \newline - \texttt{DeviceId deviceId()} \newline - \texttt{VehicleId vehicleId()} \newline - \texttt{TenantId tenantId()} \newline - \texttt{Instant installedAt()} \newline - \texttt{Optional<\allowbreak Instant>\allowbreak  uninstalledAt()} \newline - \texttt{int initialOdometerKm()} \newline - \texttt{Optional<\allowbreak Integer>\allowbreak  finalOdometerKm()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} VehicleFault \quad (\textit{Aggregate Root})} \\*
\hline
Atributos y diagnóstico & Raíz de agregado que formaliza la persistencia y ciclo de resolución de fallas DTC detectadas en ruta. Generalización de AbstractDomainAggregateRoot<FaultId>. Composición con DtcCode y FaultSeverity. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{FaultId id} \newline - \texttt{TenantId tenantId} \newline - \texttt{VehicleId vehicleId} \newline - \texttt{DtcCode dtcCode} \newline - \texttt{FaultSeverity severity} \newline - \texttt{String description} \newline - \texttt{Instant detectedAt} \newline - \texttt{boolean isResolved} \newline - \texttt{Optional<\allowbreak Instant>\allowbreak  resolvedAt} \newline - \texttt{Optional<\allowbreak String>\allowbreak  resolutionNotes} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Resolución y criticidad & Invariantes: el código DTC debe ser válido bajo SAE J2012. La confirmación de avería emite VehicleFaultDetectedEvent. La resolución formal sella con marca de tiempo UTC y emite VehicleFaultResolvedEvent. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{VehicleFault detect(VehicleId,\allowbreak  TenantId,\allowbreak  DtcCode,\allowbreak  FaultSeverity,\allowbreak  String,\allowbreak  Instant)} \newline - \texttt{void resolve(String,\allowbreak  Instant)} \newline - \texttt{boolean isResolved()} \newline - \texttt{boolean isCritical()} \newline - \texttt{FaultId id()} \newline - \texttt{VehicleId vehicleId()} \newline - \texttt{TenantId tenantId()} \newline - \texttt{DtcCode dtcCode()} \newline - \texttt{FaultSeverity severity()} \newline - \texttt{String description()} \newline - \texttt{Instant detectedAt()} \newline - \texttt{Optional<\allowbreak Instant>\allowbreak  resolvedAt()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} PredictiveAlert \quad (\textit{Aggregate Root})} \\*
\hline
Atributos y despacho & Raíz de agregado que modela advertencias generadas analíticamente por inferencia predictiva. Asocia paquetes de servicio sugeridos de MRO y gobierna la notificación push reactiva hacia Atelier Workshop y Atelier Driver. Generalización de AbstractDomainAggregateRoot<AlertId>. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{AlertId id} \newline - \texttt{TenantId tenantId} \newline - \texttt{VehicleId vehicleId} \newline - \texttt{Optional<\allowbreak ServiceId>\allowbreak  recommendedServiceId} \newline - \texttt{AlertSeverity severity} \newline - \texttt{RiskLevel riskLevel} \newline - \texttt{ConfidenceScore confidenceScore} \newline - \texttt{String message} \newline - \texttt{AlertStatus status} \newline - \texttt{Optional<\allowbreak String>\allowbreak  fcmMessageId} \newline - \texttt{Instant createdAt} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Inferencia y notificación & Invariantes: la confianza estadística debe situarse en el rango de 0.00 a 100.00. Emite PredictiveAlertGeneratedEvent al crearse, PredictiveAlertDispatchedEvent al notificarse y PredictiveAlertAcknowledgedEvent al confirmarse su lectura. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{PredictiveAlert generate(VehicleId,\allowbreak  TenantId,\allowbreak  Optional<\allowbreak ServiceId>\allowbreak ,\allowbreak  AlertSeverity,\allowbreak  RiskLevel,\allowbreak  ConfidenceScore,\allowbreak  String)} \newline - \texttt{void markDispatched(String)} \newline - \texttt{void acknowledge()} \newline - \texttt{void resolve()} \newline - \texttt{void dismiss()} \newline - \texttt{AlertId id()} \newline - \texttt{VehicleId vehicleId()} \newline - \texttt{TenantId tenantId()} \newline - \texttt{AlertSeverity severity()} \newline - \texttt{RiskLevel riskLevel()} \newline - \texttt{ConfidenceScore confidenceScore()} \newline - \texttt{AlertStatus status()} \newline - \texttt{Optional<\allowbreak String>\allowbreak  fcmMessageId()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} TelemetryRecord \quad (\textit{Time-Series Aggregate Root})} \\*
\hline
Atributos sensoriales & Registro inmutable de serie temporal que modela una lectura puntual multidimensional del tren motriz para la hipertabla telemetry\_logs de TimescaleDB. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Instant timestamp} \newline - \texttt{VehicleId vehicleId} \newline - \texttt{TenantId tenantId} \newline - \texttt{DeviceId deviceId} \newline - \texttt{VehicleSpeed speed} \newline - \texttt{EngineRpm rpm} \newline - \texttt{EngineTemperature coolantTemperature} \newline - \texttt{Optional<\allowbreak BatteryVoltage>\allowbreak  batteryVoltage} \newline - \texttt{Optional<\allowbreak FuelLevel>\allowbreak  fuelLevel} \newline - \texttt{Optional<\allowbreak GeoCoordinates>\allowbreak  coordinates} \newline - \texttt{Optional<\allowbreak TelemetryPids>\allowbreak  telemetryPids} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Invariantes y evaluación & Invariantes: la marca de tiempo UTC es obligatoria. La velocidad, revoluciones y temperatura se validan en los objetos de valor asociados. Provee métodos deterministas de detección preliminar. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{TelemetryRecord of(Instant,\allowbreak  VehicleId,\allowbreak  TenantId,\allowbreak  DeviceId,\allowbreak  VehicleSpeed,\allowbreak  EngineRpm,\allowbreak  EngineTemperature,\allowbreak  Optional<\allowbreak BatteryVoltage>\allowbreak ,\allowbreak  Optional<\allowbreak FuelLevel>\allowbreak ,\allowbreak  Optional<\allowbreak GeoCoordinates>\allowbreak ,\allowbreak  Optional<\allowbreak TelemetryPids>\allowbreak )} \newline - \texttt{boolean indicatesOverheating()} \newline - \texttt{boolean indicatesLowBattery()} \newline - \texttt{Instant timestamp()} \newline - \texttt{VehicleId vehicleId()} \newline - \texttt{TenantId tenantId()} \newline - \texttt{DeviceId deviceId()} \newline - \texttt{VehicleSpeed speed()} \newline - \texttt{EngineRpm rpm()} \newline - \texttt{EngineTemperature coolantTemperature()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} DtcCatalogEntry \quad (\textit{Dependent Entity})} \\*
\hline
Atributos y normativa & Entidad dependiente del catálogo maestro de diagnóstico vehicular bajo normativas SAE J2012 e ISO 15031-6. Clasifica códigos en categorías Powertrain, Chassis, Body y Network. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{DtcCatalogId id} \newline - \texttt{DtcCode code} \newline - \texttt{String standard} \newline - \texttt{String systemCategory} \newline - \texttt{String descriptionEs} \newline - \texttt{String descriptionEn} \newline - \texttt{FaultSeverity defaultSeverity} \newline - \texttt{boolean isCritical} \newline - \texttt{Optional<\allowbreak ServiceId>\allowbreak  recommendedServiceId} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Clasificación y enlace MRO & Invariantes: el código de falla es unívoco. Permite actualizar descripciones bilingües y vincular paquetes de servicio preventivo del módulo de operaciones para órdenes de trabajo automáticas. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{DtcCatalogEntry of(DtcCatalogId,\allowbreak  DtcCode,\allowbreak  String,\allowbreak  String,\allowbreak  String,\allowbreak  String,\allowbreak  FaultSeverity,\allowbreak  boolean,\allowbreak  Optional<\allowbreak ServiceId>\allowbreak )} \newline - \texttt{void updateDescriptions(String,\allowbreak  String)} \newline - \texttt{void assignRecommendedService(ServiceId)} \newline - \texttt{DtcCatalogId id()} \newline - \texttt{DtcCode code()} \newline - \texttt{String systemCategory()} \newline - \texttt{FaultSeverity defaultSeverity()} \newline - \texttt{boolean isCritical()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Dominio:} PredictiveAnomalyDetectionEngine} \\*
\hline
Inferencia de anomalías en tiempo real & Servicio de dominio algorítmico puro sin estado. Evalúa telemetría sensorial recién arribada para formular advertencias predictivas analizando correlaciones térmicas y eléctricas según leyes de combustión interna. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Optional<\allowbreak PredictiveAlert>\allowbreak  evaluateTelemetry(TelemetryRecord,\allowbreak  Optional<\allowbreak ServiceId>\allowbreak )} \newline - \texttt{boolean detectThermalRunaway(List<\allowbreak TelemetryRecord>\allowbreak )} \newline - \texttt{boolean detectAlternatorFailure(BatteryVoltage,\allowbreak  EngineRpm)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Dominio:} DtcCodeEvaluationService} \\*
\hline
Evaluación de códigos de avería & Servicio de dominio que contrasta códigos DTC contra el catálogo estandarizado para clasificar severidad operativa y recomendar paquetes de servicio preventivo en taller mecánico. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{FaultSeverity evaluateSeverity(DtcCode)} \newline - \texttt{Optional<\allowbreak ServiceId>\allowbreak  resolveRecommendedService(DtcCode)} \newline - \texttt{boolean isEmissionsRelated(DtcCode)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Dominio:} VehicleThermodynamicEvaluationService} \\*
\hline
Modelado termodinámico y refrigeración & Servicio de dominio puro que evalúa gradientes térmicos y dinámicas de disipación de calor del motor analizando correlaciones continuas entre revoluciones por minuto, velocidad lineal y temperatura de refrigerante. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{boolean evaluateThermalGradient(EngineTemperature,\allowbreak  EngineTemperature,\allowbreak  Duration)} \newline - \texttt{boolean isCoolingSystemDegraded(EngineTemperature,\allowbreak  VehicleSpeed,\allowbreak  EngineRpm)} \newline - \texttt{double calculateHeatDissipationIndex(EngineTemperature,\allowbreak  VehicleSpeed)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puertos de Repositorio:} Repositorios de Persistencia de Dominio} \\*
\hline
Puertos de persistencia de dominio & Interfaces puras desacopladas de tecnología: Obd2DeviceRepository, DeviceInstallationRepository, TelemetryRecordRepository, VehicleFaultRepository, PredictiveAlertRepository y DtcCatalogRepository. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Obd2Device save(Obd2Device)} \newline - \texttt{Optional<\allowbreak Obd2Device>\allowbreak  findById(DeviceId)} \newline - \texttt{Optional<\allowbreak Obd2Device>\allowbreak  findByDeviceIdentifier(DeviceIdentifier)} \newline - \texttt{Optional<\allowbreak DeviceInstallation>\allowbreak  findActiveByVehicleId(VehicleId)} \newline - \texttt{void saveAllBatch(List<\allowbreak TelemetryRecord>\allowbreak )} \newline - \texttt{List<\allowbreak VehicleFault>\allowbreak  findActiveByVehicleId(VehicleId)} \newline - \texttt{List<\allowbreak PredictiveAlert>\allowbreak  findAllByVehicleId(VehicleId)} \newline - \texttt{Optional<\allowbreak DtcCatalogEntry>\allowbreak  findByCode(DtcCode)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Identificadores Fuertemente Tipados:} Identidades de Dominio} \\*
\hline
Identificadores tipados & Registros Java inmutables que realizan TypedId<UUID> para erradicar la obsesión por tipos primitivos y garantizar seguridad de tipos en compilación: DeviceId, InstallationId, FaultId, AlertId y DtcCatalogId. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{record DeviceId(UUID value)} \newline - \texttt{record InstallationId(UUID value)} \newline - \texttt{record FaultId(UUID value)} \newline - \texttt{record AlertId(UUID value)} \newline - \texttt{record DtcCatalogId(UUID value)} \newline - \texttt{static of(UUID value)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objetos de Valor Inmutables:} Magnitudes Sensoriales y Diagnósticas} \\*
\hline
Estructuras inmutables & Registros Java inmutables con validación estricta de invariantes en construcción: DeviceIdentifier, DtcCode, ConfidenceScore, EngineTemperature, EngineRpm, VehicleSpeed, BatteryVoltage, FuelLevel, GeoCoordinates y TelemetryPids. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{DeviceIdentifier of(String value)} \newline - \texttt{DtcCode of(String value)} \newline - \texttt{ConfidenceScore of(BigDecimal value)} \newline - \texttt{EngineTemperature of(double value)} \newline - \texttt{EngineRpm of(int value)} \newline - \texttt{VehicleSpeed of(double value)} \newline - \texttt{BatteryVoltage of(double value)} \newline - \texttt{FuelLevel of(double value)} \newline - \texttt{GeoCoordinates of(double latitude,\allowbreak  double longitude)} \newline - \texttt{TelemetryPids of(Map<\allowbreak String,\allowbreak  Object>\allowbreak  pids)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeraciones de Dominio:} Vocabularios Controlados Inmutables} \\*
\hline
Enumeraciones de dominio & Vocabularios controlados inmutables que tipifican canales de transmisión, situaciones de hardware, severidad de fallas, niveles de advertencia, estados de notificación y escalas de riesgo analítico. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{ConnectionType (BLUETOOTH\_BLE,\allowbreak  SIM\_CELLULAR,\allowbreak  WIFI)} \newline - \texttt{DeviceStatus (ACTIVE,\allowbreak  INACTIVE,\allowbreak  LOST,\allowbreak  BROKEN)} \newline - \texttt{FaultSeverity (LOW,\allowbreak  MEDIUM,\allowbreak  CRITICAL)} \newline - \texttt{AlertSeverity (LOW,\allowbreak  MEDIUM,\allowbreak  HIGH,\allowbreak  CRITICAL)} \newline - \texttt{AlertStatus (DISPATCHED,\allowbreak  ACKNOWLEDGED,\allowbreak  RESOLVED,\allowbreak  DISMISSED)} \newline - \texttt{RiskLevel (LOW,\allowbreak  MODERATE,\allowbreak  HIGH,\allowbreak  CRITICAL)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Eventos de Dominio:} Mutaciones Transaccionales para Transactional Outbox} \\*
\hline
Eventos de dominio & Registros inmutables que implementan DomainEvent. Describen mutaciones transaccionales del estado vehicular y hardware telemático para propagación asíncrona mediante el Transactional Outbox. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{CriticalEngine\allowbreak AnomalyDetected\allowbreak Event(VehicleId,\allowbreak  DeviceId,\allowbreak  TenantId,\allowbreak  String,\allowbreak  Instant)} \newline - \texttt{DeviceInstalled\allowbreak OnVehicleEvent(InstallationId,\allowbreak  DeviceId,\allowbreak  VehicleId,\allowbreak  TenantId,\allowbreak  int,\allowbreak  Instant)} \newline - \texttt{DeviceUninstalled\allowbreak FromVehicleEvent(InstallationId,\allowbreak  DeviceId,\allowbreak  VehicleId,\allowbreak  TenantId,\allowbreak  int,\allowbreak  Instant)} \newline - \texttt{Obd2Device\allowbreak RegisteredEvent(DeviceId,\allowbreak  TenantId,\allowbreak  DeviceIdentifier,\allowbreak  Instant)} \newline - \texttt{PredictiveAlert\allowbreak AcknowledgedEvent(AlertId,\allowbreak  VehicleId,\allowbreak  TenantId,\allowbreak  Instant)} \newline - \texttt{PredictiveAlert\allowbreak DispatchedEvent(AlertId,\allowbreak  VehicleId,\allowbreak  TenantId,\allowbreak  String,\allowbreak  Instant)} \newline - \texttt{PredictiveAlert\allowbreak GeneratedEvent(AlertId,\allowbreak  VehicleId,\allowbreak  TenantId,\allowbreak  AlertSeverity,\allowbreak  RiskLevel,\allowbreak  ConfidenceScore,\allowbreak  Instant)} \newline - \texttt{TelemetryBatch\allowbreak IngestedEvent(VehicleId,\allowbreak  DeviceId,\allowbreak  TenantId,\allowbreak  int,\allowbreak  Instant,\allowbreak  Instant)} \newline - \texttt{VehicleFault\allowbreak DetectedEvent(FaultId,\allowbreak  VehicleId,\allowbreak  TenantId,\allowbreak  DtcCode,\allowbreak  FaultSeverity,\allowbreak  Instant)} \newline - \texttt{VehicleFault\allowbreak ResolvedEvent(FaultId,\allowbreak  VehicleId,\allowbreak  TenantId,\allowbreak  DtcCode,\allowbreak  Instant)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Jerarquía de Excepciones Semánticas:} Errores de Negocio RFC 7807} \\*
\hline
Excepciones semánticas RFC 7807 & Jerarquía no comprobada derivada de IoTDomainException. Portan códigos legibles normalizados bajo RFC 7807 para mapeo HTTP en la capa perimetral ante conflictos de montaje, dispositivos no encontrados, tramas inválidas o anomalías en TimescaleDB. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{ActiveInstallation\allowbreak ConflictException(VehicleId)} \newline - \texttt{DeviceAlready\allowbreak InstalledException(DeviceId)} \newline - \texttt{DeviceNotFound\allowbreak Exception(DeviceId)} \newline - \texttt{InstallationNotFound\allowbreak Exception(InstallationId)} \newline - \texttt{InvalidDevice\allowbreak IdentifierException(String)} \newline - \texttt{InvalidDtc\allowbreak CodeException(String)} \newline - \texttt{IoTDomain\allowbreak Exception(String,\allowbreak  String,\allowbreak  HttpStatus)} \newline - \texttt{PredictiveAlert\allowbreak NotFoundException(AlertId)} \newline - \texttt{TimescaleIngestion\allowbreak Exception(String)} \newline - \texttt{VehicleFault\allowbreak NotFoundException(FaultId)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación técnica de la Capa de Dominio en el paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak iot.\allowbreak domain.

A partir del modelo estático ilustrado en la @fig:class-diagram-iot y desglosado en la @tbl:iot-domain-classes-members, se identifican cuatro fundamentos de ingeniería de software que respaldan la solidez técnica y la adaptabilidad operativa de la plataforma:

- **Aislamiento Algorítmico y Determinismo Termodinámico:**
  El riguroso aislamiento algorítmico de los motores de diagnóstico predictivo y la inmutabilidad de los registros sensoriales garantizan que la evaluación del estado mecánico de los vehículos se ejecute con determinismo matemático y sin acoplamiento a bibliotecas de persistencia. Al encapsular las magnitudes físicas en objetos de valor especializados, el sistema valida las invariantes termodinámicas y eléctricas en el instante mismo de su construcción, asegurando que lecturas anómalas o corrompidas sean interceptadas antes de ingresar a los modelos de inferencia.

- **Integridad Temporal del Emparejamiento Vehicular y Odometría No Decreciente:**
  La formalización de las sesiones físicas de emparejamiento mediante el agregado **DeviceInstallation** resuelve con precisión la integridad temporal del vínculo entre adaptadores y automotores. Al imponer la regla de que ningún vehículo puede mantener múltiples escáneres activos simultáneamente y certificar la secuencia no decreciente de odómetros entre desmontajes sucesivos, el modelo de dominio protege la fidelidad histórica del kilometraje, erradicando discrepancias de auditoría física tanto en talleres concesionarios como en flotas de transporte corporativo.

- **Diferenciación Semántica entre Diagnóstico Confirmado e Inferencia Preventiva:**
  La separación limpia entre averías electrónicas normalizadas (**VehicleFault**) bajo el estándar SAE J2012 y advertencias de inferencia predictiva (**PredictiveAlert**) confiere una adaptabilidad excepcional al ecosistema. Esta distinción permite que el taller diferencie entre fallas confirmadas por la computadora del automotor y riesgos incipientes calculados estadísticamente, habilitando la programación anticipada de citas de mantenimiento en la estación web **Atelier Workshop** y la emisión de alertas push instantáneas hacia los conductores en carretera mediante **Atelier Driver**.

- **Sincronización Resiliente Multi-Producto y Amortiguamiento Fuera de Línea:**
  La articulación del puerto de persistencia masiva en lote modela con exactitud la sincronización resiliente con terminales móviles en campo. Cuando las aplicaciones móviles actúan como pasarelas telemáticas locales en zonas de nula cobertura celular, los registros sensoriales se custodian transitoriamente en el motor relacional embebido **SQLite 3** mediante **Room** en Android y **Drift** en Flutter, garantizando una transmisión posterior íntegra y ordenada hacia las hipertablas de TimescaleDB sin pérdida de telemetría.



##### 2.6.9.6.2. *Bounded Context Database Design Diagram*

El diseño de persistencia del Bounded Context **IoT Telemetry & Predictive Maintenance** materializa el modelo de dominio en un esquema híbrido y multi-producto, diseñado para balancear la consistencia transaccional de los diagnósticos con la ingestión masiva en ráfaga de series temporales. La persistencia física se distribuye armónicamente en dos entornos operativos complementarios: la infraestructura central en la nube basada en **PostgreSQL 16** y la extensión **TimescaleDB** para el backend de la plataforma (**API Application**), y el motor relacional transaccional embebido **SQLite 3** para las aplicaciones cliente en movilidad (**Atelier Workshop** y **Atelier Driver**).

En la @fig:database-diagram-iot se expone el Diagrama Entidad-Relación físico para la persistencia del Bounded Context IoT Telemetry & Predictive Maintenance en sus dos entornos operativos de despliegue, delimitando las entidades relacionales transaccionales, la hipertabla de series temporales y las estructuras de amortiguamiento local en terminales móviles.

![Diagrama Entidad-Relación de Base de Datos para el Bounded Context IoT Telemetry & Predictive Maintenance (PostgreSQL 16, TimescaleDB y SQLite 3)](report/assets/database-diagrams/database-diagram-iot.png){#fig:database-diagram-iot}

*Nota.* Elaboración propia en base al diseño físico de persistencia y el estándar PlantUML ERD.

- **Subsistema de Inventario y Homologación de Equipamiento Telemático:**
  Gobierna el registro maestro de los adaptadores y escáneres OBD-II homologados mediante la tabla **obd2_devices**. Esta entidad preserva la identidad física única de cada adaptador mediante su dirección MAC para enlaces Bluetooth Low Energy o su código IMEI para módems celulares de telemetría continua. Asimismo, fiscaliza el protocolo de bajo nivel soportado y clasifica el estado del hardware para impedir la vinculación de dispositivos averiados, extraviados o dados de baja.

- **Subsistema de Emparejamiento Físico y Auditoría de Odometría:**
  Administra el ciclo de vida de las sesiones de conexión física del escáner en los puertos de diagnóstico de los vehículos automotores mediante la tabla **device_installations**. Esta estructura formaliza la relación temporal entre el dispositivo y el vehículo intervenido, salvaguardando el kilometraje inicial de conexión y el kilometraje final de desmonte. De este modo, impone como regla de integridad que ningún vehículo admita múltiples escáneres activos simultáneamente y que el odómetro mantenga una progresión no decreciente durante la prestación del servicio.

- **Subsistema de Catálogo Universal de Diagnóstico Automotriz:**
  Estandariza el diccionario de códigos de avería mediante la tabla **dtc_catalog**, clasificada bajo normas SAE J2012 e ISO 15031-6. Almacena las definiciones técnicas bilingües en español e inglés, la severidad intrínseca recomendada, la categorización por subsistemas de tren motriz, chasis, carrocería y redes, así como el indicador de criticidad de intervención técnica en el taller automotriz.

- **Subsistema de Averías Electrónicas Vehiculares:**
  Resguarda la bitácora de códigos de falla registrados por la computadora vehicular mediante la tabla **vehicle_faults**, vinculada por identidad hacia el expediente del vehículo. Permite auditar el momento de detección por el sensor, el estado de resolución técnica por el mecánico en foso y las notas de procedimiento correctivo aplicadas en la orden de servicio de mantenimiento.

- **Subsistema de Inferencia Preventiva y Notificaciones Push:**
  Registra las anomalías mecánicas detectadas analíticamente por los motores de evaluación mediante la tabla **predictive_alerts**. Esta entidad almacena el grado de certeza estadística asignado por el algoritmo, vincula proactivamente el paquete de servicio sugerido procedente del catálogo de taller y custodia los identificadores de entrega asíncrona hacia Firebase Cloud Messaging para despacho multicanal.

- **Subsistema de Ingesta Masiva de Series Temporales en TimescaleDB:**
  Aísla la captura de lecturas sensoriales de alta frecuencia mediante la hipertabla especializada **telemetry_logs**, desplegada sobre TimescaleDB en Aiven Cloud. Esta tabla opera bajo una semántica append-only y se particiona automáticamente en bloques temporales de siete días, complementados por una política de compresión columnar automática para registros que superen los treinta días de antigüedad. Este particionamiento optimizado absorbe millones de mediciones de velocidad, temperatura de refrigerante, tensión de batería, nivel de combustible y coordenadas geográficas sin generar contención sobre las transacciones del sistema.

- **Persistencia Desconectada y Amortiguamiento Fuera de Línea en SQLite 3:**
  Garantiza la operatividad continua de los clientes móviles en zonas sin cobertura de red móvil mediante las tablas locales **local_telemetry_buffer**, **local_vehicle_faults_cache** y **local_predictive_alerts_cache**. La tabla **local_telemetry_buffer** actúa como un buffer transaccional en el dispositivo para almacenar en frío las tramas OBD-II capturadas por Bluetooth, drenándolas en lote hacia el backend en cuanto se recupera el enlace celular. Por su parte, las tablas de caché local proporcionan acceso inmediato a los códigos de falla y advertencias preventivas sin latencia de red.

A partir de la arquitectura física formalizada en el diagrama de persistencia, en la @tbl:iot-database-tables-schema se cataloga la totalidad de las tablas y objetos físicos que estructuran el modelo de datos, detallando el producto donde residen, sus atributos cardinales, restricciones de integridad, estrategias de indexación y su aporte a la resiliencia operativa.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.1cm} | >{\raggedright\arraybackslash}p{10.3cm} |}
\caption{Catálogo exhaustivo de tablas, objetos de base de datos, restricciones e índices físicos del Bounded Context IoT Telemetry \& Predictive Maintenance} \label{tbl:iot-database-tables-schema} \\
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{obd2\allowbreak \_devices}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Inventario maestro de adaptadores telemáticos y escáneres OBD-II pertenecientes a la dotación técnica del taller. Almacena las direcciones físicas MAC para dispositivos Bluetooth Low Energy o números IMEI para terminales celulares 4G LTE, administrando el estado funcional del equipo y previniendo la utilización de adaptadores extraviados o dañados. Aislamiento estricto por taller mediante clave foránea obligatoria. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID PK)}, \texttt{tenant\_id (UUID FK)}, \texttt{device\_identifier (VARCHAR(100) UK)}, \texttt{connection\_type (VARCHAR(20))}, \texttt{status (VARCHAR(20))}, \texttt{hardware\_model (VARCHAR(100))}, \texttt{firmware\_version (VARCHAR(50))}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ)}, \texttt{version (BIGINT)}, \texttt{deleted\_at (TIMESTAMPTZ)}. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_\allowbreak obd2\_\allowbreak devices (id) \newline - UK: uk\_\allowbreak obd2\_\allowbreak devices\_\allowbreak identifier (device\_identifier) \newline - FK: fk\_\allowbreak obd2\_\allowbreak devices\_\allowbreak tenant hacia tenants(id) \newline - CHECK: chk\_\allowbreak device\_\allowbreak conn\_\allowbreak type (connection\_type IN ('BLUETOOTH\_BLE', 'SIM\_CELLULAR', 'WIFI')), chk\_\allowbreak device\_\allowbreak status (status IN ('ACTIVE', 'INACTIVE', 'LOST', 'BROKEN')) \newline - Índices B-Tree: idx\_\allowbreak devices\_\allowbreak tenant\_\allowbreak status (tenant\_id, status), idx\_\allowbreak obd2\_\allowbreak identifier (device\_identifier) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{device\allowbreak \_installations}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Sesiones de acoplamiento físico entre un escáner OBD-II y un vehículo automotor intervenido. Gobierna el período temporal de monitoreo, auditando el kilometraje inicial al conectar y el kilometraje final al desinstalar. Protege la consistencia operativa asegurando que no existan registros simultáneos activos para el mismo vehículo y comprobando que el odómetro sea monótonamente creciente. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID PK)}, \texttt{tenant\_id (UUID FK)}, \texttt{device\_id (UUID FK)}, \texttt{vehicle\_id (UUID FK)}, \texttt{installed\_at (TIMESTAMPTZ)}, \texttt{uninstalled\_at (TIMESTAMPTZ)}, \texttt{initial\_odometer\_km (INTEGER)}, \texttt{final\_odometer\_km (INTEGER)}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ)}, \texttt{version (BIGINT)}, \texttt{deleted\_at (TIMESTAMPTZ)}. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_\allowbreak device\_\allowbreak installations (id) \newline - FK: fk\_\allowbreak installations\_\allowbreak device hacia obd2\_devices(id), fk\_\allowbreak installations\_\allowbreak vehicle hacia vehicles(id), fk\_\allowbreak installations\_\allowbreak tenant hacia tenants(id) \newline - CHECK: chk\_\allowbreak odometer\_\allowbreak positive (initial\_odometer\_km >= 0 AND (final\_odometer\_km IS NULL OR final\_odometer\_km >= initial\_odometer\_km)), chk\_\allowbreak uninstalled\_\allowbreak after\_\allowbreak installed (uninstalled\_at IS NULL OR uninstalled\_at >= installed\_at) \newline - Índices B-Tree: idx\_\allowbreak installations\_\allowbreak device (device\_id), idx\_\allowbreak installations\_\allowbreak vehicle (vehicle\_id), idx\_\allowbreak installations\_\allowbreak active (vehicle\_id, uninstalled\_at) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{dtc\allowbreak \_catalog}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Diccionario universal estandarizado de códigos de diagnóstico automotriz bajo los esquemas normativos SAE J2012 e ISO 15031-6. Almacena las definiciones técnicas en español e inglés, la severidad intrínseca recomendada, la categorización por subsistema vehicular y la criticidad de intervención técnica en taller. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID PK)}, \texttt{dtc\_code (VARCHAR(10) UK)}, \texttt{system\_category (VARCHAR(30))}, \texttt{description\_es (VARCHAR(500))}, \texttt{description\_en (VARCHAR(500))}, \texttt{default\_severity (VARCHAR(20))}, \texttt{is\_critical (BOOLEAN)}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ)}, \texttt{version (BIGINT)}, \texttt{deleted\_at (TIMESTAMPTZ)}. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_\allowbreak dtc\_\allowbreak catalog (id) \newline - UK: uk\_\allowbreak dtc\_\allowbreak catalog\_\allowbreak code (dtc\_code) \newline - CHECK: chk\_\allowbreak dtc\_\allowbreak category (system\_category IN ('powertrain', 'chassis', 'body', 'network')), chk\_\allowbreak dtc\_\allowbreak severity (default\_severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')) \newline - Índices B-Tree: idx\_\allowbreak dtc\_\allowbreak code (dtc\_code), idx\_\allowbreak dtc\_\allowbreak category (system\_category) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{vehicle\allowbreak \_faults}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Registro formal de códigos de avería de diagnóstico automotriz emitidos por la computadora del vehículo y leídos a través del bus CAN. Permite auditar el momento de detección, el estado de resolución técnica por el mecánico en taller y las notas de procedimiento correctivo aplicadas en la orden de servicio. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID PK)}, \texttt{tenant\_id (UUID FK)}, \texttt{vehicle\_id (UUID FK)}, \texttt{dtc\_code (VARCHAR(10))}, \texttt{severity (VARCHAR(20))}, \texttt{description (VARCHAR(255))}, \texttt{detected\_at (TIMESTAMPTZ)}, \texttt{is\_resolved (BOOLEAN)}, \texttt{resolved\_at (TIMESTAMPTZ)}, \texttt{resolution\_notes (VARCHAR(500))}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ)}, \texttt{version (BIGINT)}, \texttt{deleted\_at (TIMESTAMPTZ)}. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_\allowbreak vehicle\_\allowbreak faults (id) \newline - FK: fk\_\allowbreak faults\_\allowbreak vehicle hacia vehicles(id), fk\_\allowbreak faults\_\allowbreak tenant hacia tenants(id) \newline - CHECK: chk\_\allowbreak fault\_\allowbreak severity (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')) \newline - Índices B-Tree: idx\_\allowbreak faults\_\allowbreak vehicle\_\allowbreak dtc (vehicle\_id, dtc\_code), idx\_\allowbreak faults\_\allowbreak detected\_\allowbreak at (detected\_at) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{predictive\allowbreak \_alerts}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Advertencias mecánicas preventivas inferidas deterministamente por los algoritmos analíticos a partir de desviaciones en las series temporales de telemetría. Cuantifica la probabilidad de daño en un porcentaje de certeza, asocia el servicio correctivo sugerido del catálogo de taller y resguarda el acuse de recibo del mensaje push emitido por Firebase Cloud Messaging hacia los clientes. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID PK)}, \texttt{tenant\_id (UUID FK)}, \texttt{vehicle\_id (UUID FK)}, \texttt{recommended\_service\_id (UUID FK)}, \texttt{alert\_type (VARCHAR(50))}, \texttt{confidence\_score (DECIMAL(5,2))}, \texttt{message (VARCHAR(255))}, \texttt{status (VARCHAR(20))}, \texttt{fcm\_message\_id (VARCHAR(100))}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ)}, \texttt{version (BIGINT)}, \texttt{deleted\_at (TIMESTAMPTZ)}. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_\allowbreak predictive\_\allowbreak alerts (id) \newline - FK: fk\_\allowbreak alerts\_\allowbreak vehicle hacia vehicles(id), fk\_\allowbreak alerts\_\allowbreak tenant hacia tenants(id), fk\_\allowbreak alerts\_\allowbreak service hacia services(id) \newline - CHECK: chk\_\allowbreak confidence\_\allowbreak range (confidence\_score >= 0.00 AND confidence\_score <= 1.00), chk\_\allowbreak alert\_\allowbreak status (status IN ('DISPATCHED', 'ACKNOWLEDGED', 'RESOLVED', 'DISMISSED')) \newline - Índices B-Tree: idx\_\allowbreak alerts\_\allowbreak vehicle (vehicle\_id), idx\_\allowbreak alerts\_\allowbreak status (status) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{telemetry\allowbreak \_logs}} \\*
\hline
\textbf{Motor y Producto} & TimescaleDB Extension (API Application / Aiven Cloud) \\*
\hline
\textbf{Propósito y Aislamiento} & Hipertabla de series temporales de solo inserción para la ingesta masiva de lecturas de sensores vehiculares de identificación de parámetros. Particionada en intervalos temporales de siete días con compresión columnar automática tras treinta días de antigüedad, optimizando el uso de disco en más de un noventa por ciento. Soporta el cómputo de métricas continuas de velocidad, temperatura del motor, revoluciones, tensión de batería, nivel de combustible y coordenadas geográficas. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{timestamp (TIMESTAMPTZ PK)}, \texttt{vehicle\_id (UUID PK FK)}, \texttt{tenant\_id (UUID FK)}, \texttt{latitude (DECIMAL(10,8))}, \texttt{longitude (DECIMAL(11,8))}, \texttt{speed (INTEGER)}, \texttt{engine\_temp\_c (DECIMAL(5,2))}, \texttt{rpm (INTEGER)}, \texttt{fuel\_level\_pct (DECIMAL(5,2))}, \texttt{battery\_voltage (DECIMAL(4,2))}. \\*
\hline
\textbf{Constraints e Índices} & - PK Compuesta: pk\_\allowbreak telemetry\_\allowbreak logs (timestamp, vehicle\_id) \newline - FK: fk\_\allowbreak telemetry\_\allowbreak tenant hacia tenants(id) \newline - Particionamiento: time chunks de siete días sobre la dimensión temporal timestamp mediante create\_hypertable \newline - Compresión Columnar: activada para chunks mayores a treinta días con segmentby (vehicle\_id, tenant\_id) y orderby timestamp DESC \newline - Índices Físicos: idx\_\allowbreak telemetry\_\allowbreak vehicle\_\allowbreak time (vehicle\_id, timestamp DESC), idx\_\allowbreak telemetry\_\allowbreak tenant\_\allowbreak time (tenant\_id, timestamp DESC) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{auditable\allowbreak \_abstract\allowbreak \_entity}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Superclase arquetípica de persistencia JPA anotada con @MappedSuperclass heredada transversalmente por las entidades maestras del contexto. Suministra la clave técnica primaria UUID, las marcas temporales inmutables de auditoría created\_at y updated\_at, el contador version para el bloqueo optimista en transacciones concurrentes y el soporte de borrado lógico deleted\_at. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID PK)}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ)}, \texttt{version (BIGINT)}, \texttt{deleted\_at (TIMESTAMPTZ)}. \\*
\hline
\textbf{Constraints e Índices} & - PK técnica: pk\_\allowbreak auditable\_\allowbreak entity (id) \newline - Concurrencia optimista: version administrada por el proveedor JPA Hibernate \newline - Borrado lógico: filtro SQL deleted\_at IS NULL inyectado en consultas relacionales \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{local\allowbreak \_telemetry\allowbreak \_buffer}} \\*
\hline
\textbf{Motor y Producto} & SQLite 3 (Atelier Workshop \& Atelier Driver) \\*
\hline
\textbf{Propósito y Aislamiento} & Amortiguador transaccional local en terminal móvil gestionado mediante Room en Android y Drift en Flutter. Captura y encola tramas telemáticas OBD-II emitidas por adaptadores Bluetooth en circunstancias de nula cobertura inalámbrica, preservando las marcas temporales ISO-8601 originales y los valores físicos de los sensores para su posterior transmisión en lote hacia la API central. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (TEXT PK)}, \texttt{vehicle\_id (TEXT)}, \texttt{timestamp (TEXT)}, \texttt{speed (INTEGER)}, \texttt{rpm (INTEGER)}, \texttt{engine\_temp\_c (REAL)}, \texttt{battery\_voltage (REAL)}, \texttt{fuel\_level (REAL)}, \texttt{latitude (REAL)}, \texttt{longitude (REAL)}, \texttt{sync\_status (TEXT)}, \texttt{created\_at (TEXT)}. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_\allowbreak local\_\allowbreak telemetry\_\allowbreak buffer (id) \newline - CHECK: chk\_\allowbreak telem\_\allowbreak sync (sync\_status IN ('PENDING', 'SYNCED', 'FAILED')) \newline - Índices B-Tree: idx\_\allowbreak local\_\allowbreak telem\_\allowbreak status (sync\_status, timestamp) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{local\allowbreak \_vehicle\allowbreak \_faults\allowbreak \_cache}} \\*
\hline
\textbf{Motor y Producto} & SQLite 3 (Atelier Workshop \& Atelier Driver) \\*
\hline
\textbf{Propósito y Aislamiento} & Réplica relacional local de códigos de avería automotriz activos en el vehículo monitoreado. Habilita la consulta instantánea en foso o en ruta por el técnico mecánico o el conductor sin dependencia de conexión a Internet, permitiendo la visualización inmediata del diagnóstico DTC y su nivel de severidad. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{fault\_id (TEXT PK)}, \texttt{vehicle\_id (TEXT)}, \texttt{dtc\_code (TEXT)}, \texttt{severity (TEXT)}, \texttt{description (TEXT)}, \texttt{detected\_at (TEXT)}, \texttt{synced\_at (TEXT)}. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_\allowbreak local\_\allowbreak faults (fault\_id) \newline - Índices B-Tree: idx\_\allowbreak local\_\allowbreak faults\_\allowbreak vehicle (vehicle\_id) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{local\allowbreak \_predictive\allowbreak \_alerts\allowbreak \_cache}} \\*
\hline
\textbf{Motor y Producto} & SQLite 3 (Atelier Workshop \& Atelier Driver) \\*
\hline
\textbf{Propósito y Aislamiento} & Caché local de historial de alertas preventivas notificadas al usuario a través de notificaciones push o refrescos periódicos de datos. Garantiza la renderización reactiva de advertencias mecánicas en la aplicación móvil aun cuando el dispositivo pierda señal celular en túneles o sótanos. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{alert\_id (TEXT PK)}, \texttt{vehicle\_id (TEXT)}, \texttt{alert\_type (TEXT)}, \texttt{confidence\_score (REAL)}, \texttt{message (TEXT)}, \texttt{status (TEXT)}, \texttt{created\_at (TEXT)}, \texttt{synced\_at (TEXT)}. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_\allowbreak local\_\allowbreak alerts (alert\_id) \newline - Índices B-Tree: idx\_\allowbreak local\_\allowbreak alerts\_\allowbreak vehicle (vehicle\_id) \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Elaboración propia en base al diseño físico de persistencia y la arquitectura multi-producto de series temporales.

A partir de la estructura formalizada en la @fig:database-diagram-iot y catalogada en la @tbl:iot-database-tables-schema, se identifican tres fundamentos de ingeniería de software que respaldan la escalabilidad, consistencia y resiliencia de la persistencia:

- **Segregación de Cargas de Trabajo y Particionamiento Temporal en TimescaleDB:**
  La bifurcación entre el esquema transaccional en PostgreSQL 16 y la hipertabla de series temporales en TimescaleDB erradica la contención de bloqueos relacionales durante la ingestión masiva de datos telemáticos. Al particionar los registros en bloques temporales de siete días y aplicar compresión columnar automática tras treinta días de almacenamiento, el sistema reduce la huella física en más de un noventa por ciento y preserva tiempos de respuesta constantes para las consultas operativas del ERP automotriz.

- **Integridad Referencial Temporal y Monotonicidad Odometría:**
  La formalización de las sesiones de emparejamiento mediante **device_installations** y el registro de averías en **vehicle_faults** garantizan la trazabilidad física inmutable de las intervenciones mecánicas. La imposición de restricciones CHECK que validan la monotonicidad no decreciente del odómetro y los índices compuestos sobre el estado del vehículo aseguran que ninguna discrepancia en los sensores corrompa el historial legal y técnico del automotor durante auditorías o inspecciones de flota.

- **Amortiguamiento Transaccional Desconectado y Replicación Resiliente en SQLite 3:**
  La implementación de colas locales de sincronización en terminales móviles mediante SQLite 3 confiere una robustez excepcional al ecosistema ante interrupciones de conectividad en carretera o instalaciones subterráneas. El buffer local **local_telemetry_buffer** actúa como un cerrojo transaccional en el dispositivo, asegurando que las ráfagas sensoriales se drenen de manera ordenada y con marcas temporales fidedignas hacia la nube una vez restablecido el enlace telemático, garantizando cero pérdida de información crítica.

\newpage
