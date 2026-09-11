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
\textbf{Categoría} & Objeto de Valor (ID) \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Series\allowbreak ConfigurationId & Identificador único universal fuertemente tipado para la configuración de series fiscales. \\*
\hline
\textbf{Categoría} & Objeto de Valor (ID) \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PaymentId & Identificador único universal fuertemente tipado para asientos de amortización financiera. \\*
\hline
\textbf{Categoría} & Objeto de Valor (ID) \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
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
VoucherType & Catálogo oficial de tipos de comprobante según tabla 10 de SUNAT (Factura 01, Boleta 03, Nota de Crédito 07). \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada por ElectronicVoucher y SeriesConfiguration. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
VoucherStatus & Estados del ciclo de vida tributario del comprobante (DRAFT, ISSUED, ACCEPTED\_SUNAT, REJECTED\_SUNAT, VOIDED). \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada por la raíz de agregado ElectronicVoucher. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PaymentMethod & Medios de pago autorizados para liquidación en caja (CASH, CREDIT\_CARD, DEBIT\_CARD, BANK\_TRANSFER, DIGITAL\_WALLET\_YAPE, DIGITAL\_WALLET\_PLIN). \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada por la entidad dependiente VoucherPayment. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PaymentStatus & Estados de la transacción financiera de liquidación (PENDING, COMPLETED, REFUNDED). \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada por la entidad dependiente VoucherPayment. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
VoucherItemType & Clasificación comercial del renglón facturado entre repuesto material o servicio técnico (PRODUCT, SERVICE). \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada por la entidad dependiente VoucherLine. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Credit\allowbreak NoteReason & Catálogo 09 de SUNAT para causales legales de emisión de notas de crédito electrónicas. \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada en emisión y validación de notas de crédito. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
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
\textbf{Tipo o Firma} & \texttt{UUID} \\*
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

**Objetos de Valor y Enumeraciones de Invoicing & Compliance**

La consistencia y semántica de las magnitudes tributarias y financieras se salvaguardan mediante objetos de valor inmutables implementados como registros de Java. Al centralizar la validación de formato y rango en sus constructores compactos, estos componentes erradican la presencia de estados inválidos en el dominio. Destaca **TaxCalculation**, el cual consolida la base imponible neta, el débito fiscal de IGV y el importe total facturado, verificando la estricta concordancia aritmética de sus importes.

Complementariamente, el dominio tipifica las dimensiones normativas mediante enumeraciones que reflejan los catálogos oficiales de la SUNAT. Entre ellas, **VoucherType** categoriza los comprobantes autorizados (código 01 para facturas, 03 para boletas y 07 para notas de crédito), **CreditNoteReason** sistematiza las causales admitidas para rectificaciones comerciales, **VoucherStatus** delimita la máquina de estados del documento y **PaymentMethod** clasifica los canales de liquidación aceptados en caja.

En la @tbl:invoicing-value-objects se detallan los objetos de valor inmutables y las enumeraciones reglamentarias que vertebran la semántica fiscal del contexto.

\renewcommand{\arraystretch}{1.25}\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Objetos de Valor y Enumeraciones de Invoicing \& Compliance} \label{tbl:invoicing-value-objects} \\
\hline
\thfirst{Componente Inmutable} & \thcell{Definición de Atributos y Reglas de Validación} \\
\hline
\endfirsthead
\hline
\thfirst{Componente Inmutable} & \thcell{Definición de Atributos y Reglas de Validación} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} VoucherId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal del comprobante electrónico de pago. Inmutable y no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} SeriesConfigurationId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal de la configuración de series fiscales. Inmutable y no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} PaymentId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal del asiento de pago financiero en caja. Inmutable y no nulo. \\
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
*Nota.* Componentes inmutables y enumeraciones legales de SUNAT del paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak domain.\allowbreak model.\allowbreak valueobjects.

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

El aislamiento del modelo conceptual respecto a la infraestructura de persistencia se garantiza mediante contratos de interfaz que definen los puertos de salida del dominio. Estos contratos permiten recuperar y persistir el estado de los agregados respetando sus invariantes transaccionales, prescindiendo por completo de dependencias directas hacia tecnologías relacionales o librerías ORM.

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
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Issue\allowbreak Credit\allowbreak Note\allowbreak Request & Carga útil inmutable para emisión de notas de crédito electrónicas vinculadas a un comprobante previo con código y sustento de rectificación. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por ElectronicVoucherResourceAssembler hacia IssueCreditNoteCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Void\allowbreak Voucher\allowbreak Request & Carga útil inmutable para comunicar formalmente la anulación o baja tributaria ante SUNAT con justificación explícita. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por ElectronicVoucherResourceAssembler hacia VoidElectronicVoucherCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Register\allowbreak Payment\allowbreak Request & Carga útil inmutable para registrar una amortización o liquidación financiera contra un comprobante indicando medio de pago y referencia. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por VoucherPaymentResourceAssembler hacia RegisterVoucherPaymentCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Configure\allowbreak Series\allowbreak Request & Carga útil inmutable para el alta y parametrización de series correlativas autorizadas por sucursal física y tipo fiscal. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por SeriesConfigurationResourceAssembler hacia ConfigureSeriesCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Electronic\allowbreak Voucher\allowbreak Resource & Representación pública integral del comprobante con desglose de impuestos, partidas gravadas, amortizaciones y enlaces de activos tributarios. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por ElectronicVoucherResourceAssembler desde ElectronicVoucher. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Electronic\allowbreak Voucher\allowbreak Summary\allowbreak Resource & Proyección sintetizada para listados paginados de alta velocidad y cuadrículas de consulta de comprobantes fiscales. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por ElectronicVoucherResourceAssembler desde ElectronicVoucher. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Voucher\allowbreak Line\allowbreak Resource & Detalle monetario y tributario de una partida individual gravada de repuesto o servicio automotriz dentro del comprobante. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por ElectronicVoucherResourceAssembler desde VoucherLine. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Voucher\allowbreak Payment\allowbreak Resource & Constancia inmutable de amortización o liquidación monetaria con medio de pago, referencia de transacción y marca temporal. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por VoucherPaymentResourceAssembler desde VoucherPayment. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Daily\allowbreak Cash\allowbreak Summary\allowbreak Resource & Balance financiero diario consolidado por sucursal física con desglose por medios de pago en efectivo, tarjeta, transferencia y billeteras digitales. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por VoucherPaymentResourceAssembler desde agregaciones de VoucherPayment. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Series\allowbreak Configuration\allowbreak Resource & Representación pública del estado y correlativo actual de una serie fiscal autorizada para una sede física. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por SeriesConfigurationResourceAssembler desde SeriesConfiguration. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Cash\allowbreak Flow\allowbreak Report\allowbreak Resource & Estado consolidado de flujo de caja del taller con sumatorias de ingresos, egresos, flujo neto y colección cronológica de movimientos. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por FinancialReportResourceAssembler desde CashFlowReport del servicio de consulta. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Cash\allowbreak Flow\allowbreak Movement\allowbreak Resource & Registro cronológico individual de ingreso o egreso operativo con categoría de negocio, referencia probatoria y saldo progresivo acumulado. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Componente subordinado de CashFlowReportResource. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
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
Voucher\allowbreak Payment\allowbreak Received\allowbreak Integration\allowbreak Event & Notifica el asentamiento de una amortización monetaria para verificar si se alcanzó la cancelación total y habilitar salida del vehículo. \\*
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
*Nota.* Catálogo consolidado de componentes pertenecientes al paquete canónico com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak interfaces.

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

La transferencia de información entre el perímetro exterior y el núcleo transaccional se modela a través de objetos de transferencia de datos inmutables estructurados como registros de Java. En las operaciones de mutación, componentes como **IssueVoucherRequest**, **IssueCreditNoteRequest**, **VoidVoucherRequest**, **RegisterPaymentRequest** y **ConfigureSeriesRequest** aplican validaciones semánticas tempranas sobre importes monetarios positivos, formatos de serie reglamentarios y completitud de datos tributarios.

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
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} Customer\allowbreak Fiscal\allowbreak Info\allowbreak Dto \quad (\textit{Categoría:} Petición)} \\*
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
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} Digital\allowbreak Receipt\allowbreak Urls\allowbreak Dto \quad (\textit{Categoría:} Respuesta)} \\*
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
*Nota.* Componentes ubicados en el paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak interfaces.\allowbreak rest.\allowbreak resources.

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
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{getDailyRevenueSummary}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID tenantId,\allowbreak  UUID branchId,\allowbreak  LocalDate date} $\longrightarrow$ \allowbreak \texttt{Daily\allowbreak Revenue\allowbreak Summary\allowbreak Dto} \\*
\hline
\textbf{Módulos Consumidores} & Dashboard Ejecutivo, Inteligencia de Negocio \\*
\hline
\textbf{Propósito} & Agregación en memoria de cobros y facturación diaria de la sucursal para monitorización gerencial en tiempo real. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak interfaces.\allowbreak acl.

**Eventos de Integración y Coordinación Asíncrona Intermodular**

La coordinación transaccional desacoplada con el ecosistema de Atelier Platform se articula a través de un lenguaje publicado compuesto por eventos de integración inmutables. El contexto publica hechos fiscales concluidos que notifican la emisión de comprobantes, la obtención de resoluciones CDR aprobatorias o rechazadas por la SUNAT y el registro de recaudaciones de fondos en caja, asegurando que módulos como CRM, MRO y Notificaciones reaccionen de manera eventual y autónoma.

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
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} Voucher\allowbreak Payment\allowbreak Received\allowbreak Integration\allowbreak Event \quad (\textit{Tipo:} Publicado)} \\*
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

En la @tbl:invoicing-application-types se sintetiza el catálogo consolidado de servicios de comando, servicios de consulta, escuchadores de eventos y puertos de salida que articulan la Capa de Aplicación de Invoicing & Compliance.

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
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Electronic\allowbreak Voucher\allowbreak Command\allowbreak ServiceImpl & Orquesta la emisi\'on, notas de cr\'edito, anulaciones y respuestas SUNAT con reserva at\'omica de serie. \\*
\hline
\textbf{Categoría} & Implementaci\'on de Servicio de Comando \\*
\hline
\textbf{Relaciones} & Coordina agregados ElectronicVoucher, SeriesConfiguration y repositorios bajo transacci\'on ACID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Voucher\allowbreak Payment\allowbreak Command\allowbreak Service & Contrato de operaciones transaccionales de amortizaci\'on y registro de cobros contra comprobantes fiscales. \\*
\hline
\textbf{Categoría} & Servicio de Comando (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por VoucherPaymentCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Voucher\allowbreak Payment\allowbreak Command\allowbreak ServiceImpl & Gestiona abonos en caja del taller, valida saldo insoluto y emite liberaci\'on de orden hacia MRO. \\*
\hline
\textbf{Categoría} & Implementaci\'on de Servicio de Comando \\*
\hline
\textbf{Relaciones} & Coordina entidad VoucherPayment y agregado ElectronicVoucher con repositorios. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Series\allowbreak Configuration\allowbreak Command\allowbreak Service & Contrato de parametrizaci\'on y ciclo de vida de series alfanum\'ericas fiscales por sede f\'isica. \\*
\hline
\textbf{Categoría} & Servicio de Comando (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por SeriesConfigurationCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Series\allowbreak Configuration\allowbreak Command\allowbreak ServiceImpl & Administra altas de series fiscales seg\'un normativa SUNAT, activaciones y suspensiones por sede. \\*
\hline
\textbf{Categoría} & Implementaci\'on de Servicio de Comando \\*
\hline
\textbf{Relaciones} & Coordina agregado SeriesConfiguration con persistencia JPA. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Electronic\allowbreak Voucher\allowbreak Query\allowbreak Service & Contrato de consultas de solo lectura para cat\'alogo de comprobantes, auditor\'ia y activos tributarios. \\*
\hline
\textbf{Categoría} & Servicio de Consulta (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por ElectronicVoucherQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Electronic\allowbreak Voucher\allowbreak Query\allowbreak ServiceImpl & Ejecuta proyecciones paginadas de comprobantes y descargas de activos binarios XML UBL 2.1, PDF y CDR. \\*
\hline
\textbf{Categoría} & Implementaci\'on de Servicio de Consulta \\*
\hline
\textbf{Relaciones} & Consulta repositorios bajo aislamiento de solo lectura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Voucher\allowbreak Payment\allowbreak Query\allowbreak Service & Contrato de consulta de amortizaciones financieras y cuadres de caja diarios por sucursal f\'isica. \\*
\hline
\textbf{Categoría} & Servicio de Consulta (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por VoucherPaymentQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Voucher\allowbreak Payment\allowbreak Query\allowbreak ServiceImpl & Proyecta abonos desglosados por comprobante y balances de recaudaci\'on diaria por medio de pago. \\*
\hline
\textbf{Categoría} & Implementaci\'on de Servicio de Consulta \\*
\hline
\textbf{Relaciones} & Consulta repositorios y vistas JPA de recaudaci\'on. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Cash\allowbreak Flow\allowbreak Query\allowbreak Service & Contrato de consulta anal\'itica para consolidaci\'on del estado de cuenta y flujo de caja del taller. \\*
\hline
\textbf{Categoría} & Servicio de Consulta (Interfaz) \\*
\hline
\textbf{Relaciones} & Implementado por CashFlowQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Cash\allowbreak Flow\allowbreak Query\allowbreak ServiceImpl & Ejecuta algoritmo de consolidaci\'on en 7 pasos unificando ingresos con egresos de repuestos y n\'omina. \\*
\hline
\textbf{Categoría} & Implementaci\'on de Servicio de Consulta \\*
\hline
\textbf{Relaciones} & Coordina fachadas de Inventory y HR, y el puerto InvoicingPdfGeneratorPort. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Voucher\allowbreak Domain\allowbreak Event\allowbreak Handler & Manejador transaccional de eventos de dominio para emisi\'on, aceptaci\'on fiscal, pago y baja. \\*
\hline
\textbf{Categoría} & Manejador de Eventos de Dominio \\*
\hline
\textbf{Relaciones} & Despacha correos v\'ia Resend, emite alertas a MRO y coordina con Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Work\allowbreak Order\allowbreak Delivered\allowbreak Event\allowbreak Listener & Escuchador de integraci\'on del evento de entrega vehicular emitido por Workshop Operations (MRO). \\*
\hline
\textbf{Categoría} & Escuchador de Eventos de Integraci\'on \\*
\hline
\textbf{Relaciones} & Verifica emisi\'on previa de comprobante y genera advertencia administrativa en omisiones fiscales. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Purchase\allowbreak Order\allowbreak Received\allowbreak Event\allowbreak Listener & Escuchador de integraci\'on de recepci\'on f\'isica de repuestos emitido por Inventory \& Supply Chain. \\*
\hline
\textbf{Categoría} & Escuchador de Eventos de Integraci\'on \\*
\hline
\textbf{Relaciones} & Asienta facturas de compra recibidas como egreso comercial en el flujo de caja del taller. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Payroll\allowbreak Paid\allowbreak Event\allowbreak Listener & Escuchador de integraci\'on de liquidaci\'on salarial emitido por Human Resources \& Payroll. \\*
\hline
\textbf{Categoría} & Escuchador de Eventos de Integraci\'on \\*
\hline
\textbf{Relaciones} & Incorpora dispersi\'on salarial del personal t\'ecnico como egreso laboral en el flujo de caja. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Invoicing\allowbreak Transactional\allowbreak Outbox\allowbreak Publisher & Publicador que serializa eventos de integraci\'on en la tabla outbox\_messages bajo entrega At-Least-Once. \\*
\hline
\textbf{Categoría} & Publicador Transaccional Outbox \\*
\hline
\textbf{Relaciones} & Intercepta eventos del dominio y los almacena en base de datos para despacho as\'incrono confiable. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Nubefact\allowbreak Acl\allowbreak Service & Capa Anticorrupci\'on que transforma ElectronicVoucher a trama JSON V1 para Nubefact PSE/OSE. \\*
\hline
\textbf{Categoría} & Capa Anticorrupci\'on (ACL) \\*
\hline
\textbf{Relaciones} & Implementa la adaptaci\'on perimetral hacia NubefactFiscalGatewayPort. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Customer\allowbreak Fiscal\allowbreak Acl\allowbreak Port & Puerto de salida para recuperar datos fiscales y consultar vigencia de RUC/DNI en CRM o SUNAT. \\*
\hline
\textbf{Categoría} & Puerto de Salida ACL \\*
\hline
\textbf{Relaciones} & Consumido por ElectronicVoucherCommandServiceImpl e implementado en infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Transactional\allowbreak Email\allowbreak Sender\allowbreak Port & Puerto de salida para distribuci\'on de comprobantes por correo con adjuntos binarios (PDF/XML). \\*
\hline
\textbf{Categoría} & Puerto de Salida Gateway \\*
\hline
\textbf{Relaciones} & Consumido por VoucherDomainEventHandler e implementado por ResendEmailAdapter. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak ports.\allowbreak outbound} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Invoicing\allowbreak Pdf\allowbreak Generator\allowbreak Port & Puerto de salida para renderizado de documentos bancarios PDF de flujo de caja y comprobantes. \\*
\hline
\textbf{Categoría} & Puerto de Salida Gateway \\*
\hline
\textbf{Relaciones} & Consumido por CashFlowQueryServiceImpl y ElectronicVoucherQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak ports.\allowbreak outbound} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Invoicing\allowbreak Event\allowbreak Publisher\allowbreak Port & Puerto de infraestructura para publicar eventos hacia el bus de mensajer\'ia y la tabla outbox. \\*
\hline
\textbf{Categoría} & Puerto de Salida Event Bus \\*
\hline
\textbf{Relaciones} & Consumido por servicios de comando y manejadores transaccionales. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak ports.\allowbreak outbound} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Estructura modular consolidada de la capa de aplicación bajo el paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak application.

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
*Nota.* Métodos transaccionales orquestados con aislamiento de lectura confirmada bajo el paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak application.\allowbreak services.

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
*Nota.* Métodos de consulta de solo lectura ejecutados bajo el paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak application.\allowbreak services.

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
*Nota.* Suscripción y despacho transaccional desacoplado bajo el paquete com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak application.\allowbreak events.

**Puertos de Salida, Pasarelas y Adaptadores Anticorrupción**

El aislamiento arquitectónico de Invoicing & Compliance respecto a servicios en la nube y pasarelas de terceros se formaliza a través de puertos de salida especializados ubicados en los paquetes de infraestructura y control de acceso. El contrato **NubefactFiscalGatewayPort**, coordinado por el adaptador **NubefactAclService**, encapsula la serialización hacia la pasarela tributaria del proveedor autorizado por SUNAT y aísla la estructura técnica JSON requerida para la homologación de comprobantes UBL 2.1.

Por su parte, **CustomerFiscalAclPort** recupera y valida datos tributarios desde el contexto de clientes, **TransactionalEmailSenderPort** canaliza el envío de comprobantes mediante Resend, **InvoicingPdfGeneratorPort** maqueta reportes bancarios y representaciones impresas, e **InvoicingEventPublisherPort** gobierna la persistencia y despacho hacia el bus de eventos del Transactional Outbox.

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
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} Nubefact\allowbreak Fiscal\allowbreak Gateway\allowbreak Port \quad (\textit{Categoría:} Pasarela Fiscal REST)} \\*
\hline
\textbf{Métodos Principales} & \texttt{sendInvoice}, \texttt{sendCreditNote}, \texttt{sendVoidedDocument}, \texttt{queryDocumentStatus} \\*
\hline
\textbf{Propósito Técnico} & Despacho perimetral de tramas JSON V1 al PSE/OSE Nubefact para generación de XML UBL 2.1, firma con certificado digital y obtención de CDR de SUNAT. \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak infrastructure.\allowbreak gateways} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} Customer\allowbreak Fiscal\allowbreak Acl\allowbreak Port \quad (\textit{Categoría:} Puerto ACL de Dominio)} \\*
\hline
\textbf{Métodos Principales} & \texttt{getCustomerFiscalInfo}, \texttt{validateTaxIdActiveStatus} \\*
\hline
\textbf{Propósito Técnico} & Consulta desacoplada de identidad fiscal, padrón de RUC activo y domicilio fiscal de clientes comerciales y particulares desde CRM o padrón tributario. \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak acl} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} Transactional\allowbreak Email\allowbreak Sender\allowbreak Port \quad (\textit{Categoría:} Puerto de Notificación Cloud)} \\*
\hline
\textbf{Métodos Principales} & \texttt{sendVoucherEmail}, \texttt{sendCreditNoteNotification}, \texttt{sendCashSummaryReport} \\*
\hline
\textbf{Propósito Técnico} & Despacho asíncrono de comprobantes tributarios a los clientes con archivos binarios PDF y XML UBL 2.1 incrustados como adjuntos seguros vía Resend. \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak ports.\allowbreak outbound} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} Invoicing\allowbreak Pdf\allowbreak Generator\allowbreak Port \quad (\textit{Categoría:} Puerto de Renderizado Documental)} \\*
\hline
\textbf{Métodos Principales} & \texttt{generateCashFlowStatementPdf}, \texttt{generateVoucherPdf}, \texttt{generateDailyCashReportPdf} \\*
\hline
\textbf{Propósito Técnico} & Renderizado binario de reportes de flujo de caja con diseño bancario corporativo y emisión gráfica de comprobantes con código de respuesta rápida QR. \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak ports.\allowbreak outbound} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} Invoicing\allowbreak Event\allowbreak Publisher\allowbreak Port \quad (\textit{Categoría:} Puerto de Mensajería y Outbox)} \\*
\hline
\textbf{Métodos Principales} & \texttt{publish}, \texttt{publishToOutbox}, \texttt{publishAll} \\*
\hline
\textbf{Propósito Técnico} & Publicación de eventos de dominio locales hacia oyentes de contexto y persistencia atómica en outbox\_messages para propagación intermodular. \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak invoicing.\allowbreak application.\allowbreak ports.\allowbreak outbound} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Puertos e interfaces de salida ubicados bajo los paquetes acl y ports.outbound en Invoicing \& Compliance.

La concepción arquitectónica de la Capa de Aplicación de Invoicing & Compliance consolida tres fundamentos de ingeniería de software que afianzan la exactitud tributaria y la resiliencia operativa en Atelier Platform:

En primer lugar, la disciplina tributaria, el determinismo matemático y la inmutabilidad legal de los comprobantes electrónicos garantizan un cumplimiento riguroso de la normativa SUNAT UBL 2.1. Al orquestar la reserva atómica de correlativos antes de la persistencia local y canalizar el despacho hacia el proveedor telemático con contingencia en el Transactional Outbox, el sistema asegura que cada comprobante emitido mantenga inviolabilidad probatoria y cuadre exacto en sus partidas gravadas, eliminando riesgos de multas o nulidades fiscales para el taller automotriz.

En segundo término, la soberanía financiera alcanzada mediante la consolidación en memoria del flujo de caja operativo proporciona una inteligencia de negocio integral para la administración del taller. La capacidad de unificar transaccionalmente los cobros de facturación con los egresos devengados por abastecimiento de repuestos en inventario y dispersión de planillas salariales en recursos humanos faculta a los gerentes de sede para auditar su rentabilidad neta en tiempo real y exportar estados de cuenta con rigor bancario sin acoplamiento a nivel de esquemas relacionales.

Por último, el desacoplamiento perimetral y el blindaje del modelo de dominio frente a servicios en la nube y pasarelas telemáticas garantizan alta tolerancia a fallos y portabilidad tecnológica. La interposición de capas anticorrupción y puertos de salida dedicados aísla la lógica transaccional respecto a especificaciones propietarias de proveedores como Nubefact o servicios de mensajería como Resend, asegurando que eventuales intermitencias externas jamás bloqueen los procesos de cobro y entrega vehicular en las bahías de trabajo mecánicas.



#### 2.6.7.4. Infrastructure Layer

La Capa de Infraestructura del Bounded Context Invoicing & Compliance, materializada bajo el paquete canónico **com.andeva.atelier.platform.invoicing.infrastructure**, provee los mecanismos de persistencia relacional, aislamiento transaccional y comunicación perimetral telemática con las entidades tributarias y servicios externos. Esta capa implementa los contratos de repositorio definidos en el dominio mediante Spring Data JPA e Hibernate sobre PostgreSQL 16 alojado en Aiven Cloud, asegurando la inmutabilidad legal de los comprobantes emitidos, la sincronización atómica de numeraciones correlativas fiscales mediante bloqueo pesimista de fila, y la resiliencia en la emisión electrónica a través de adaptadores telemáticos hacia proveedores de servicios electrónicos homologados.

Las directrices técnicas fundamentales que rigen el diseño de la Capa de Infraestructura abarcan los siguientes pilares de arquitectura:

- **Garantía de unicidad y concurrencia serial mediante bloqueo pesimista en base de datos:** Reserva atómica y sin condiciones de carrera de números correlativos tributarios mediante consultas bloqueantes sobre configuraciones de series fiscales, impidiendo huecos y colisiones de numeración entre múltiples cajas de cobro.
- **Persistencia físico-relacional auditada y ciclo de vida inmutable de comprobantes:** Mapeo de agregados a tablas normalizadas con claves compuestas, integridad referencial en cascada sobre líneas y pagos, y protección estricta ante modificaciones arbitrarias de registros fiscales ya informados ante la autoridad tributaria.
- **Reconstitución pura del modelo de dominio y transformación desacoplada:** Ensambladores de persistencia que invocan el método estático de fábrica de las entidades de dominio para restaurar su estado sin emitir eventos de dominio espurios durante consultas, complementados con convertidores JPA para tipos complejos y valores enumerados.
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
Electronic\allowbreak Voucher\allowbreak JpaEntity & Mapeo relacional de comprobantes electrónicos fiscales como facturas, boletas y notas de crédito a la tabla física electronic\_vouchers. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Hereda de AuditableAbstractPersistenceEntity. Raíz de persistencia con colecciones lazy en cascada hacia líneas y pagos. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Voucher\allowbreak Line\allowbreak JpaEntity & Mapeo relacional de ítems, servicios y repuestos facturados a la tabla física voucher\_lines. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Clave foránea hacia electronic\_vouchers. Almacena descripción, cantidades, valores unitarios y cuota tributaria de IGV. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Voucher\allowbreak Payment\allowbreak JpaEntity & Mapeo relacional de transacciones de amortización, cobros y medios de pago a la tabla física voucher\_payments. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Hereda de AuditableAbstractPersistenceEntity. Clave foránea hacia electronic\_vouchers. Soporta auditoría y cuadre de caja diario. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Series\allowbreak Configuration\allowbreak JpaEntity & Mapeo relacional de rangos y contadores correlativos de series fiscales por sucursal a la tabla sunat\_series\_configurations. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Hereda de AuditableAbstractPersistenceEntity. Restricción de unicidad compuesta sobre sucursal, tipo de comprobante y serie. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
SpringData\allowbreak Electronic\allowbreak Voucher\allowbreak Repository & Interfaz Spring Data JPA para operaciones relacionales y consultas derivadas sobre comprobantes electrónicos. \\*
\hline
\textbf{Categoría} & Repositorio JPA \\*
\hline
\textbf{Relaciones} & Extiende JpaRepository. Consultas unívocas por serie y número correlativo, filtrado por orden de trabajo y rangos de fechas. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
SpringData\allowbreak Voucher\allowbreak Payment\allowbreak Repository & Interfaz Spring Data JPA para administración relacional y trazabilidad de pagos y amortizaciones. \\*
\hline
\textbf{Categoría} & Repositorio JPA \\*
\hline
\textbf{Relaciones} & Extiende JpaRepository. Consultas por comprobante e informes agregados de recaudación por sucursal y jornada operativa. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
SpringData\allowbreak Series\allowbreak Configuration\allowbreak Repository & Interfaz Spring Data JPA con bloqueo pesimista en base de datos para la reserva atómica de correlativos fiscales. \\*
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
Electronic\allowbreak Voucher\allowbreak Persistence\allowbreak Assembler & Mapeo y transformación bidireccional entre la raíz de agregado ElectronicVoucher y la entidad relacional. \\*
\hline
\textbf{Categoría} & Ensamblador de Persistencia \\*
\hline
\textbf{Relaciones} & Reconstituye el agregado puro mediante método estático reconstitute() sin emitir eventos de dominio espurios. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Voucher\allowbreak Payment\allowbreak Persistence\allowbreak Assembler & Transformación bidireccional entre la entidad de dominio VoucherPayment y VoucherPaymentJpaEntity. \\*
\hline
\textbf{Categoría} & Ensamblador de Persistencia \\*
\hline
\textbf{Relaciones} & Mapea montos monetarios, medios de pago, referencias bancarias y marcas temporales de recaudación. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Series\allowbreak Configuration\allowbreak Persistence\allowbreak Assembler & Transformación bidireccional entre la entidad pura SeriesConfiguration y SeriesConfigurationJpaEntity. \\*
\hline
\textbf{Categoría} & Ensamblador de Persistencia \\*
\hline
\textbf{Relaciones} & Restaura configuraciones de series fiscales sincronizando estado operativo y contador secuencial de emisión. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak transform} \\
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
Nubefact\allowbreak Fiscal\allowbreak Gateway\allowbreak Impl & Pasarela telemática externa que interactúa con la API RESTful JSON V1 del PSE homologado Nubefact. \\*
\hline
\textbf{Categoría} & Pasarela Perimetral Fiscal \\*
\hline
\textbf{Relaciones} & Implementa NubefactFiscalGatewayPort mediante Spring WebClient, autenticación Bearer y reintentos con backoff exponencial. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak infrastructure.\allowbreak gateways} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Resend\allowbreak Email\allowbreak Sender\allowbreak Adapter & Pasarela de notificaciones transaccionales que despacha correos con comprobantes electrónicos adjuntos vía Resend. \\*
\hline
\textbf{Categoría} & Pasarela Cloud de Mensajería \\*
\hline
\textbf{Relaciones} & Implementa TransactionalEmailSenderPort adjuntando representaciones PDF renderizadas y XML UBL 2.1 con firma digital. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak infrastructure.\allowbreak adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
OpenPdf\allowbreak Invoicing\allowbreak Generator\allowbreak Adapter & Motor documental para renderizado vectorial de facturas, boletas, tickets de punto de venta y estados de caja. \\*
\hline
\textbf{Categoría} & Pasarela Documental \\*
\hline
\textbf{Relaciones} & Implementa InvoicingPdfGeneratorPort mediante librería OpenPDF para generar formatos corporativos A4 y tiras de 80 mm. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak infrastructure.\allowbreak adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Customer\allowbreak Fiscal\allowbreak Acl\allowbreak Adapter & Adaptador anticorrupción de salida hacia el contexto CRM y padrones web de contribuyentes. \\*
\hline
\textbf{Categoría} & Adaptador ACL de Salida \\*
\hline
\textbf{Relaciones} & Implementa CustomerFiscalAclPort resolviendo razón social, condición tributaria y domicilio fiscal oficial. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak infrastructure.\allowbreak adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Invoicing\allowbreak Transactional\allowbreak Outbox\allowbreak Publisher\allowbreak Impl & Publicador transaccional que inserta eventos de dominio en la tabla outbox\_messages para despacho confiable. \\*
\hline
\textbf{Categoría} & Adaptador de Mensajería Transaccional \\*
\hline
\textbf{Relaciones} & Implementa InvoicingEventPublisherPort serializando eventos JSONB para propagación asíncrona hacia Kafka o RabbitMQ. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak infrastructure.\allowbreak messaging} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al paquete canónico com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak infrastructure.

**Entidades de Persistencia JPA y Modelado Relacional Físico**

El modelado relacional de persistencia reproduce fielmente la topología legal y financiera del dominio tributario mediante cuatro entidades JPA mapeadas a sus respectivas tablas físicas en PostgreSQL 16. La raíz de persistencia **ElectronicVoucherJpaEntity** se vincula a la tabla **electronic_vouchers**, encapsulando la numeración de serie, base imponible gravada, monto de impuesto general a las ventas, importe total, estado de ciclo de vida, datos fiscales del cliente receptor y metadatos probatorios telemáticos devueltos por la entidad tributaria.

Por su parte, la entidad **VoucherLineJpaEntity** estructura los ítems, repuestos y servicios gravados en la tabla **voucher_lines**, mientras que **VoucherPaymentJpaEntity** custodia los abonos monetarios y medios de pago en la tabla **voucher_payments**. Finalmente, la entidad **SeriesConfigurationJpaEntity** gestiona los contadores correlativos atómicos por sede y tipo de comprobante en la tabla **sunat_series_configurations**. En la @tbl:invoicing-jpa-entities se detallan los esquemas físico-relacionales, claves primarias, índices B-Tree y restricciones de verificación de estas entidades.

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
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} ElectronicVoucherJpaEntity \quad (\textit{Tabla:} \texttt{electronic\_vouchers})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{tenant\_id}, \texttt{branch\_id}, \texttt{customer\_id}, \texttt{work\_order\_id}, \texttt{voucher\_type}, \texttt{serie}, \texttt{number}, \texttt{subtotal}, \texttt{igv\_amount}, \texttt{total\_amount}, \texttt{currency}, \texttt{status}, \texttt{customer\_tax\_id}, \texttt{customer\_legal\_name}, \texttt{customer\_fiscal\_address}, \texttt{customer\_document\_type}, \texttt{sunat\_pdf\_url}, \texttt{sunat\_xml\_url}, \texttt{sunat\_cdr\_url}, \texttt{digital\_signature\_hash}, \texttt{sunat\_response\_code}, \texttt{sunat\_description}, \texttt{voided\_reason}, \texttt{voided\_at} \\*
\hline
\textbf{Restricciones e Índices} & Restricción única uk\_vouchers\_tenant\_serie\_number sobre (tenant\_id, serie, number). Claves foráneas fk\_vouchers\_tenant hacia tenants, fk\_vouchers\_branch hacia branches, fk\_vouchers\_customer hacia customers y fk\_vouchers\_work\_order hacia work\_orders. Restricciones de verificación chk\_voucher\_amounts\_positive sobre subtotal, igv\_amount y total\_amount no negativos. Índices B-Tree idx\_vouchers\_tenant\_created sobre (tenant\_id, created\_at DESC), idx\_vouchers\_work\_order sobre work\_order\_id e idx\_vouchers\_customer sobre (tenant\_id, customer\_id). Relación en cascada total con eliminación de huérfanos hacia líneas y pagos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} VoucherLineJpaEntity \quad (\textit{Tabla:} \texttt{voucher\_lines})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{voucher\_id}, \texttt{item\_id}, \texttt{item\_type}, \texttt{description}, \texttt{quantity}, \texttt{unit\_value}, \texttt{unit\_price}, \texttt{igv\_amount}, \texttt{total\_line} \\*
\hline
\textbf{Restricciones e Índices} & Clave foránea fk\_voucher\_lines\_voucher hacia electronic\_vouchers con eliminación en cascada. Clave foránea opcional fk\_voucher\_lines\_item hacia el catálogo de repuestos de inventario. Restricciones de verificación chk\_line\_quantity\_positive para cantidad mayor a cero y chk\_line\_amounts\_positive para valores unitarios y totales no negativos. Índices B-Tree idx\_voucher\_lines\_voucher sobre voucher\_id e idx\_voucher\_lines\_item sobre item\_id. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} VoucherPaymentJpaEntity \quad (\textit{Tabla:} \texttt{voucher\_payments})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{voucher\_id}, \texttt{tenant\_id}, \texttt{branch\_id}, \texttt{amount}, \texttt{currency}, \texttt{payment\_method}, \texttt{transaction\_reference}, \texttt{status}, \texttt{paid\_at} \\*
\hline
\textbf{Restricciones e Índices} & Claves foráneas fk\_voucher\_payments\_voucher hacia electronic\_vouchers, fk\_payments\_tenant hacia tenants y fk\_payments\_branch hacia branches. Restricción de verificación chk\_payment\_amount\_positive para importes monetarios mayores a cero. Índices B-Tree idx\_payments\_voucher sobre voucher\_id e idx\_payments\_branch\_date sobre (branch\_id, paid\_at DESC) para cuadres de caja y auditoría financiera de cobros por sede. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} SeriesConfigurationJpaEntity \quad (\textit{Tabla:} \texttt{sunat\_series\_configurations})} \\*
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
\textbf{Repositorio Inyectado} & \texttt{SpringDataElectronicVoucherRepository} \\*
\hline
\textbf{Operaciones Clave} & Transforma el agregado puro **ElectronicVoucher** hacia **ElectronicVoucherJpaEntity** mediante **ElectronicVoucherPersistenceAssembler**. Persiste en PostgreSQL 16 coordinando la cascada de líneas de detalle y cobros mediante *saveAndFlush()*. Extrae eventos de integración acumulados con *pullDomainEvents()* y los inserta de manera atómica en la tabla outbox\_messages. Ejecuta *findById()* con hidratación de colecciones dependientes, *findByTenantIdAndSerieAndNumber()* para recuperación canónica de comprobantes fiscales, *findAllByWorkOrderId()* para auditoría de facturación asociada a órdenes de trabajo y *findAllByTenantAndDateRange()* con paginación optimizada para reportes contables. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} VoucherPaymentRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{VoucherPaymentRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{SpringDataVoucherPaymentRepository} \\*
\hline
\textbf{Operaciones Clave} & Persiste transacciones individuales de pago y amortizaciones financieras vinculadas a comprobantes. Registra la referencia bancaria, método de pago y marca temporal de recaudación. Despacha eventos **VoucherPaymentRegisteredEvent** hacia outbox\_messages para notificar la liberación del vehículo en taller. Ejecuta *findById()* para auditoría transaccional, *findAllByVoucherId()* para consultar el historial completo de amortizaciones y *findAllByBranchAndDate()* para consolidar el arqueo de caja diario de la sucursal física. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} SeriesConfigurationRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{SeriesConfigurationRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{SpringDataSeriesConfigurationRepository} \\*
\hline
\textbf{Operaciones Clave} & Administra la asignación estrictamente secuencial de números correlativos tributarios por serie y sucursal. Implementa el método *findActiveForUpdate()* aplicando la anotación LockModeType.PESSIMISTIC\_WRITE de JPA, forzando una instrucción SELECT ... FOR UPDATE en PostgreSQL que bloquea la fila de configuración durante la transacción, eliminando condiciones de carrera y saltos de numeración ante emisiones concurrentes. Ejecuta *save()* para incrementar el contador atómico y *findAllByBranchId()* para la parametrización de puntos de emisión. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Clases ubicadas bajo el paquete canónico com.\allowbreak andeva.\allowbreak atelier.\allowbreak platform.\allowbreak invoicing.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak adapters.

**Ensambladores de Persistencia y Convertidores de Atributos JPA**

El desacoplamiento entre las estructuras relacionales de base de datos y los tipos puros del dominio se materializa mediante ensambladores de persistencia y convertidores de atributos JPA. El ensamblador **ElectronicVoucherPersistenceAssembler** transforma bidireccionalmente los comprobantes electrónicos, reconstruyendo el agregado puro mediante el método estático *reconstitute()* sin desencadenar emisiones espurias de eventos de integración durante operaciones de lectura o consulta analítica. De modo semejante, los ensambladores **VoucherPaymentPersistenceAssembler** y **SeriesConfigurationPersistenceAssembler** preservan la integridad dimensional de pagos y configuraciones de series.

Este esquema de transformación se complementa con siete convertidores de atributos JPA que serializan enumeraciones de dominio y objetos de valor hacia tipos columnares estándar de SQL. Entre ellos destacan **VoucherTypeConverter**, que traduce el tipo de comprobante hacia códigos formales reglamentados; **TaxCalculationConverter**, que garantiza la consistencia porcentual del impuesto; y **MoneyConverter**, que asegura exactitud a dos decimales con redondeo bancario *Half-Even*. En la @tbl:invoicing-persistence-assemblers se describen las transformaciones y mapeos de tipos implementados por estos componentes.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Ensambladores de Persistencia y Convertidores JPA de Invoicing \& Compliance} \label{tbl:invoicing-persistence-assemblers} \\
\hline
\thfirst{Aspecto de Mapeo} & \thcell{Tipos Relacionados y Transformación} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Mapeo} & \thcell{Tipos Relacionados y Transformación} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} ElectronicVoucherPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{ElectronicVoucher} $\longleftrightarrow$ \texttt{ElectronicVoucherJpaEntity} \\*
\hline
\textbf{Transformación} & Traduce VoucherId a UUID y descompone los objetos de valor VoucherSerie, VoucherType, TaxCalculation y CustomerFiscalInfo hacia campos relacionales planos. Mapea metadatos devueltos por SUNAT como URLs de PDF, XML y constancia CDR, hash de firma digital y código de respuesta. Reconstituye el agregado puro mediante el método estático de fábrica *ElectronicVoucher.reconstitute()*, hidratando colecciones de líneas y pagos sin disparar eventos de dominio espurios durante consultas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} VoucherPaymentPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{VoucherPayment} $\longleftrightarrow$ \texttt{VoucherPaymentJpaEntity} \\*
\hline
\textbf{Transformación} & Mapea PaymentId a UUID, importe monetario Money, método de pago PaymentMethod y referencia bancaria externa. Reconstituye la entidad de pago mediante *VoucherPayment.reconstitute()* preservando la marca temporal inmutable paid\_at y garantizando la coherencia financiera del saldo insoluto. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} SeriesConfigurationPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{SeriesConfiguration} $\longleftrightarrow$ \texttt{SeriesConfigurationJpaEntity} \\*
\hline
\textbf{Transformación} & Traduce SeriesConfigurationId a UUID, serie alfanumérica y tipo de comprobante. Invoca *SeriesConfiguration.reconstitute()* para restaurar el contador correlativo actual y el indicador booleano de operatividad sin generar efectos secundarios transaccionales. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} VoucherTypeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{VoucherType} $\longleftrightarrow$ \texttt{VARCHAR(10)} \\*
\hline
\textbf{Transformación} & Convierte la enumeración de dominio hacia los códigos formales de tipo de documento reglamentados por SUNAT como código 01 para Factura, código 03 para Boleta de Venta y código 07 para Nota de Crédito. Reconstituye el tipo tipificado en lecturas relacionales. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} VoucherStatusConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{VoucherStatus} $\longleftrightarrow$ \texttt{VARCHAR(20)} \\*
\hline
\textbf{Transformación} & Serializa los estados del ciclo de vida del comprobante DRAFT, ISSUED, ACCEPTED\_SUNAT, REJECTED\_SUNAT y VOIDED a cadenas normalizadas en mayúsculas. Reconstituye la enumeración correspondiente con validación de transiciones de estado permitidas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} PaymentMethodConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{PaymentMethod} $\longleftrightarrow$ \texttt{VARCHAR(30)} \\*
\hline
\textbf{Transformación} & Mapea modalidades de cobro comerciales CASH, CREDIT\_CARD, DEBIT\_CARD, BANK\_TRANSFER, DIGITAL\_WALLET\_YAPE y DIGITAL\_WALLET\_PLIN a columnas de texto plano. Reconstituye la opción de cobro garantizando compatibilidad retroactiva. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} PaymentStatusConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{PaymentStatus} $\longleftrightarrow$ \texttt{VARCHAR(20)} \\*
\hline
\textbf{Transformación} & Serializa estados financieros de transacciones de amortización PENDING, COMPLETED y REFUNDED a columnas relacionales. Reconstituye el estado asegurando consistencia con el saldo del comprobante. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} MoneyConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{Money} $\longleftrightarrow$ \texttt{NUMERIC(10,\allowbreak 2)} \\*
\hline
\textbf{Transformación} & Extrae el valor decimal BigDecimal preservando una escala fija de dos decimales con redondeo bancario Half-Even. Reconstituye el objeto de valor asignando la divisa oficial PEN o USD según la moneda del comprobante. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} TaxCalculationConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{TaxCalculation} $\longleftrightarrow$ \texttt{NUMERIC(10,\allowbreak 2)} \\*
\hline
\textbf{Transformación} & Extrae la cuota tributaria calculada de IGV al 18\% sobre el valor gravado de venta. Reconstituye el objeto de valor auditando que la suma de valor neto y tributo coincida exactamente con el importe total liquidado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} VoucherSerieConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{VoucherSerie} $\longleftrightarrow$ \texttt{VARCHAR(4)} \\*
\hline
\textbf{Transformación} & Serializa la serie alfanumérica a cadenas fijas de cuatro caracteres en mayúsculas. Reconstituye el objeto de valor aplicando la regla de validación de formato establecida por SUNAT para comprobantes electrónicos. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes configurados bajo los paquetes transform y converters de la capa de infraestructura.

**Pasarelas Fiscales Externas e Integración en la Nube**

La comunicación hacia proveedores telemáticos y servicios en la nube se canaliza a través de pasarelas perimetrales y adaptadores anticorrupción que blindan el núcleo transaccional frente a especificaciones externas. La pasarela **NubefactFiscalGatewayImpl** interactúa con la interfaz web del proveedor de servicios electrónicos homologado para la generación del documento estructurado en formato UBL 2.1 y su firma con certificado digital tributario, incorporando políticas de tolerancia a fallos con reintentos exponenciales y aislamiento ante anomalías de red.

Adicionalmente, el adaptador **ResendEmailSenderAdapter** despacha notificaciones transaccionales al correo electrónico del cliente adjuntando las representaciones oficiales en formato PDF y XML firmado con constancia de recepción, mientras que **OpenPdfInvoicingGeneratorAdapter** genera dinámicamente representaciones gráficas vectoriales A4 y tickets térmicos para punto de venta. Por último, **CustomerFiscalAclAdapter** valida la condición de contribuyente ante el padrón tributario y **InvoicingTransactionalOutboxPublisherImpl** asegura la entrega confiable de eventos mediante el patrón Transactional Outbox. En la @tbl:invoicing-external-infrastructure se exponen las tecnologías y responsabilidades de estas pasarelas.

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
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Pasarela Externa:} NubefactFiscalGatewayImpl \quad (\textit{Categoría:} Pasarela Perimetral Fiscal)} \\*
\hline
\textbf{Tecnología Subyacente} & Spring WebClient con TLS 1.3, Cabeceras Bearer Token y Circuit Breaker Resilience4j \\*
\hline
\textbf{Responsabilidad} & Transmite la trama de datos estructurada JSON V1 hacia los servicios web del PSE homologado Nubefact para su transformación a UBL 2.1 y firma digital con certificado tributario. Configura timeout de conexión de cinco segundos, timeout de lectura de quince segundos y política de tres reintentos con retroceso exponencial ante errores HTTP 502 o 503. Extrae URLs del PDF generado, XML firmado y constancia CDR devuelta por SUNAT. Implementa NubefactFiscalGatewayPort. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Pasarela Externa:} ResendEmailSenderAdapter \quad (\textit{Categoría:} Pasarela Cloud de Notificaciones)} \\*
\hline
\textbf{Tecnología Subyacente} & Resend Cloud REST API vía Spring RestClient con Autenticación API Key \\*
\hline
\textbf{Responsabilidad} & Despacha notificaciones transaccionales a la dirección electrónica del cliente final tras la validación exitosa del comprobante. Adjunta de manera automatizada la representación impresa en formato PDF vectorial y el archivo XML UBL 2.1 con su constancia de recepción de SUNAT, garantizando entrega confiable y trazabilidad de recepción. Implementa TransactionalEmailSenderPort. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Pasarela Externa:} OpenPdfInvoicingGeneratorAdapter \quad (\textit{Categoría:} Pasarela Documental PDF)} \\*
\hline
\textbf{Tecnología Subyacente} & Biblioteca OpenPDF 1.3.39 con Renderizado Gráfico Vectorial \\*
\hline
\textbf{Responsabilidad} & Renderiza documentos imprimibles en formato bancario estándar A4 con código de barras PDF417 bidimensional y tickets térmicos de punto de venta de 80 mm para entrega en mostrador. Genera asimismo los informes de recaudación diaria y estados de flujo de caja consolidados en PDF sin sobrecargar la CPU del servidor central. Implementa InvoicingPdfGeneratorPort. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Pasarela Externa:} CustomerFiscalAclAdapter \quad (\textit{Categoría:} Adaptador ACL Datos Tributarios)} \\*
\hline
\textbf{Tecnología Subyacente} & Fachada de Módulo en Memoria hacia CRM y Caché Caffeine con TTL de 24 Horas \\*
\hline
\textbf{Responsabilidad} & Obtiene y certifica en tiempo real la identificación tributaria como RUC de 11 dígitos o DNI de 8 dígitos, razón social o denominación civil y domicilio fiscal del cliente desde el contexto Customer \& Fleet Management o contra los padrones web de SUNAT, validando la condición de contribuyente habido antes de la emisión del comprobante. Implementa CustomerFiscalAclPort. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Pasarela Externa:} InvoicingTransactionalOutboxPublisherImpl \quad (\textit{Categoría:} Adaptador de Mensajería Transaccional)} \\*
\hline
\textbf{Tecnología Subyacente} & PostgreSQL 16 con Serialización JSONB vía Jackson ObjectMapper \\*
\hline
\textbf{Responsabilidad} & Persiste eventos de dominio en la tabla outbox\_messages dentro de la misma transacción relacional de base de datos donde se almacena el comprobante o cobro. Garantiza semántica de publicación confiable con entrega al menos una vez hacia intermediarios de mensajería Apache Kafka o RabbitMQ mediante Debezium CDC, eliminando transacciones distribuidas 2PC. Implementa InvoicingEventPublisherPort. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes configurados bajo los paquetes gateways, adapters y messaging de la capa de infraestructura.

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
\textbf{Responsabilidad} & Captura eventos de dominio atómicos y señales de finalización de órdenes de trabajo desde Workshop Operations, persistiendo cargas útiles serializadas en la tabla outbox\_messages dentro de la misma transacción de base de datos para entrega garantizada al menos una vez hacia consumidores asíncronos. \\*
\hline
\textbf{Relaciones} & Escucha eventos de dominio emitidos por los servicios de aplicación de facturación. Persiste registros en la tabla outbox\_messages mediante adaptadores de infraestructura. Notifica a consumidores de eventos en Workshop Operations, CRM y contabilidad general. \\
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
\textbf{Responsabilidad} & Materializa los puertos de repositorio del dominio mediante adaptadores JPA, gestionando el bloqueo pesimista en base de datos para la reserva atómica de correlativos sin carreras, el mapeo bidireccional de entidades relacionales y el despacho transaccional en outbox\_messages. \\*
\hline
\textbf{Relaciones} & Realiza los contratos de repositorio ElectronicVoucherRepository, VoucherPaymentRepository y SeriesConfigurationRepository. Lee y escribe en las tablas electronic\_vouchers, voucher\_lines, voucher\_payments, sunat\_series\_configurations y outbox\_messages. \\
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
\textbf{Tecnologías} & Spring WebClient, Resilience4j, Resend Cloud API, OpenPDF, Caffeine Cache \\*
\hline
\textbf{Responsabilidad} & Conecta con la API RESTful JSON V1 del PSE homologado Nubefact para generación y firma digital de comprobantes UBL 2.1, despacha correos transaccionales con PDF y XML adjuntos vía Resend, renderiza comprobantes vectoriales con OpenPDF y consulta datos fiscales de clientes en CRM o SUNAT. \\*
\hline
\textbf{Relaciones} & Invocado por servicios de aplicación. Conecta vía HTTPS con la API de Nubefact y con Resend. Consulta en memoria las fachadas de Customer \& Fleet Management, Inventory \& Supply Chain y Human Resources para el estado de flujo de caja. \\
\hline
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

  Una vez comprobadas las invariantes de dominio, el servicio de aplicación solicita la reserva del número correlativo a **Invoicing Persistence Repositories & JPA Adapters**, ejecutando un bloqueo pesimista de escritura sobre el registro de serie en PostgreSQL 16 para impedir carreras o duplicidades. La entidad **ElectronicVoucher** se almacena en la base de datos en estado emitido, tras lo cual la pasarela externa despacha la trama JSON V1 estructurada hacia la API de Nubefact mediante Spring WebClient protegido por Resilience4j. Finalmente, **Invoicing Event Handlers & Transactional Dispatcher** persiste el evento **ElectronicVoucherIssuedEvent** en la tabla **outbox_messages** para notificación asíncrona, mientras la pasarela transmite el comprobante en formato PDF y XML firmado al correo del cliente mediante Resend.

- **Ciclo de Amortización, Conciliación de Pagos y Liberación Vehicular en Taller:**
  Este flujo se origina en la bahía de entrega de vehículos o mostrador de atención cuando el conductor efectúa la amortización o cancelación de la deuda por los servicios prestados. El cajero ingresa los datos de recaudación a través de la aplicación móvil o web, especificando el monto amortizado, el medio formal de pago y el identificador de la transacción. El componente **Invoicing REST Controllers & Resource Assemblers** intercepta la petición, verifica los tipos de datos y despacha el comando **RegisterVoucherPaymentCommand** hacia **Invoicing CQRS Application Services**.

  El servicio de aplicación recupera la raíz de agregado **ElectronicVoucher** junto a sus pagos previos a través de **Invoicing Persistence Repositories & JPA Adapters**, invocando la operación de dominio *applyPayment()* en **Invoicing Domain Model & Peruvian Tax Calculation Engines Component**. La raíz de agregado evalúa la regla de solvencia contable, constatando que el acumulado de amortizaciones no sobrepase el total facturado del comprobante. Si el abono liquida la totalidad del saldo exigible, el comprobante transiciona al estado cancelado, mientras que abonos parciales mantienen la obligación en estado pendiente reflejando el saldo deudor remanente.

  El adaptador de persistencia almacena el nuevo registro en la tabla relacional **voucher_payments** y consolida la actualización del comprobante en **electronic_vouchers**. Inmediatamente después, **Invoicing Event Handlers & Transactional Dispatcher** captura el suceso e inserta el evento de integración **VoucherPaymentAppliedEvent** en **outbox_messages** dentro de la misma transacción ACID. Al alcanzarse la cancelación integral de la deuda, el componente **Inbound ACL & Invoicing Open Host Facade Component** notifica de forma sincrónica a **Workshop Operations** la liberación financiera de la orden de servicio, habilitando la generación del pase de salida vehicular para la entrega física de la unidad al propietario.

- **Ciclo de Consolidación Multimodular del Estado de Flujo de Caja Operativo:**
  Para ejercer la gobernanza financiera del taller automotriz, el gerente administrativo solicita el arqueo consolidado de ingresos y egresos para un intervalo cronológico específico desde la interfaz analítica web. La petición arriba a **Invoicing REST Controllers & Resource Assemblers**, que valida los parámetros temporales y despacha la consulta **GetOperationalCashFlowQuery** hacia **Invoicing CQRS Application Services**.

  El servicio de aplicación orquesta una consulta federada respetando los límites de contexto mediante **Invoicing External Gateways & Fiscal Cloud Integration**. En primer término, recupera de **Invoicing Persistence Repositories & JPA Adapters** la totalidad de cobros reales registrados en **voucher_payments** durante las fechas solicitadas, desglosándolos por canal de pago. En segundo término, consulta en memoria la fachada de **Inventory & Supply Chain** para consolidar los desembolsos correspondientes a órdenes de compra de repuestos y lubricantes recibidas físicamente. En tercer término, invoca la fachada de **Human Resources** para cuantificar las erogaciones por planillas laborales y comisiones de mecánicos efectivamente liquidadas.

  La totalidad de registros monetarios es trasladada a **Invoicing Domain Model & Peruvian Tax Calculation Engines Component**, donde el motor especializado **CashFlowAggregationEngine** totaliza los ingresos brutos, cuantifica la estructura de costos y deduce el saldo neto de tesorería del taller. El servicio de aplicación estructura la respuesta en un recurso DTO inmutable con enlaces HATEOAS y metadatos de auditoría, retornando la proyección analítica a la aplicación web para su renderizado visual en tablas y gráficas ejecutivas o su descarga documental en formato PDF formal.

En primer término, la alta cohesión de las responsabilidades funcionales y el estricto desacoplamiento modular alcanzados mediante el principio de inversión de dependencias permiten que el motor tributario peruano opere como un núcleo de cálculo puro libre de librerías de infraestructura. Dicha segregación formaliza un modelo donde las variaciones normativas de la autoridad fiscal o las adaptaciones de esquemas tributarios se resuelven de forma autocontenida en la capa de dominio, garantizando que los módulos operativos de taller, inventario y recursos humanos permanezcan inmunes ante alteraciones en las reglas impositivas de comprobantes.

En segundo término, la implementación del Transactional Outbox Pattern en el componente de despacho de eventos garantiza la consistencia eventual y la entrega al menos una vez de los sucesos de facturación y cobro sin recurrir a protocolos distribuidos de dos fases. Al persistir los eventos de integración dentro del mismo límite de transacción relacional en que se asienta el comprobante o pago, se erradican las discrepancias contables entre el libro fiscal de facturación y el estado de cierre de las órdenes de trabajo en taller, manteniendo la integridad del sistema ante eventuales interrupciones telemáticas del servidor de aplicaciones.

Por último, el blindaje perimetral conferido por las pasarelas externas y la gestión asíncrona de contingencias aseguran la soberanía fiscal y la continuidad ininterrumpida de las operaciones del taller mecánico. La adopción de patrones de tolerancia a fallos, circuit breakers y almacenamiento de estados contingentes de reintento frente al proveedor de servicios electrónicos evita que las caídas de conectividad hacia la entidad tributaria paralicen la emisión de comprobantes o la recaudación en mostrador, permitiendo regularizar telemáticamente las constancias de recepción dentro de los plazos legales sin perturbar el flujo diario de atención automotriz.



#### 2.6.7.6. Bounded Context Software Architecture Code Level Diagrams

En esta sección se desarrolla la especificación técnica de menor nivel de abstracción para la arquitectura de software del Bounded Context Invoicing & Compliance, trasladando los modelos conceptuales y las responsabilidades tácticas hacia contratos estáticos de código ejecutable. Mediante esta formalización, se asegura que las reglas tributarias de la legislación peruana, los contratos de facturación electrónica bajo el estándar UBL 2.1 y las restricciones de consistencia transaccional se materialicen con rigurosa seguridad de tipos y determinismo computacional.

Esta perspectiva de diseño abarca dos representaciones arquitectónicas complementarias: el Diagrama de Clases de la Capa de Dominio, que modela en memoria las entidades maestras, raíces de agregado, objetos de valor inmutables, motores algorítmicos de cálculo de impuestos y puertos de persistencia; y el Diagrama de Base de Datos, que formaliza el esquema físico relacional en PostgreSQL 16 con discriminadores de aislamiento multi-inquilino, llaves foráneas y mecanismos de concurrencia optimista.

##### 2.6.7.6.1. *Bounded Context Domain Layer Class Diagrams*

El modelado estático de la Capa de Dominio del Bounded Context Invoicing & Compliance establece las estructuras operativas que gobiernan la emisión de comprobantes de pago electrónicos, la amortización de cuentas por cobrar y el control de correlatividad fiscal en las sedes del taller. Su diseño táctico prioriza la pureza algorítmica sin dependencias de frameworks tecnológicos, erradica la obsesión por tipos primitivos mediante identificadores fuertemente tipados y garantiza la inmutabilidad de los libros contables ante la administración tributaria.

En la @fig:class-diagram-invoicing se expone el Diagrama de Clases UML detallado para la Capa de Dominio de Invoicing & Compliance, diseñado conforme a la notación formal UML y compilado mediante la herramienta PlantUML bajo el enfoque de Diagram-as-Code.

![Diagrama de Clases UML de la Capa de Dominio para el Bounded Context Invoicing & Compliance](report/assets/class-diagrams/class-diagram-invoicing.png){#fig:class-diagram-invoicing}

*Nota.* Elaboración propia en base al diseño táctico de dominio y el estándar UML en PlantUML.

La organización interna del modelo estático se estructura en ocho paquetes cohesivos que encapsulan las responsabilidades del dominio fiscal:

- **Raíces de Agregado (`invoicing.domain.model.aggregates`):** Gobierna las entidades maestras que delimitan las fronteras de consistencia transaccional: **ElectronicVoucher** para el ciclo de vida, tributación y recaudación del comprobante de pago; **SeriesConfiguration** para la reserva atómica y correlatividad secuencial de series autorizadas por sede; y **VoucherPayment** para la amortización y conciliación multimoneda de caja. Todas las raíces extienden de **AbstractDomainAggregateRoot<T>**.
- **Entidades Internas (`invoicing.domain.model.entities`):** Modela las partes dependientes subordinadas al ciclo del comprobante: **VoucherLine** para la especificación detallada de bienes o servicios atendidos en taller, desagregando base imponible, alícuota e impuesto liquidado.
- **Identificadores Fuertemente Tipados (`invoicing.domain.model.ids`):** Implementa el contrato **TypedId<UUID>** mediante registros inmutables (**VoucherId**, **SeriesConfigurationId**, **PaymentId**), asociando identidades transversales del Shared Kernel (**TenantId**, **BranchId**, **CustomerId**, **WorkOrderId**).
- **Objetos de Valor Fiscales y Financieros (`invoicing.domain.model.valueobjects`):** Encapsula estructuras inmutables con validación de invariantes: **VoucherSerie** para el formato alfanumérico reglamentario, **VoucherNumber** para el correlativo positivo, **TaxCalculation** para la liquidación de subtotal e IGV, **CustomerFiscalInfo** para la identidad tributaria receptora, **DigitalReceiptUrls** para las constancias telemáticas seguras, **SunatResponse** para las respuestas fiscales y **VoidedInfo** para los motivos de anulación, enlazando tipos monetarios (**Money**, **Currency**, **Quantity**, **TaxId**).
- **Enumeraciones de Dominio (`invoicing.domain.model.enums`):** Normaliza el vocabulario operativo y tributario (**VoucherType**, **VoucherStatus**, **PaymentMethod**, **PaymentStatus**, **CreditNoteReason**, **VoucherItemType**, **DocumentType**).
- **Servicios de Dominio Tributario y Conciliación (`invoicing.domain.services`):** Provee motores de cálculo puro sin acoplamiento a infraestructura: **PeruvianTaxCalculationEngine** para la liquidación matemática del IGV al 18% con redondeo bancario Half-Even, **VoucherValidationService** para la verificación de RUC por módulo 11 y topes legales de boleta, **SeriesCorrelativeService** para la gobernanza de numeraciones consecutivas y **CashFlowAggregationEngine** para la consolidación de tesorería operativa.
- **Puertos de Persistencia (`invoicing.domain.repositories`):** Define los contratos abstractos de almacenamiento y consulta (**ElectronicVoucherRepository**, **SeriesConfigurationRepository**, **VoucherPaymentRepository**) desacoplados de motores relacionales.
- **Eventos de Dominio y Excepciones Semánticas (`invoicing.domain.events` e `invoicing.domain.exceptions`):** Formaliza mutaciones del estado contable para el Transactional Outbox (**ElectronicVoucherIssuedEvent**, **VoucherAcceptedBySunatEvent**, **VoucherVoidedEvent**) y jerarquiza excepciones no comprobadas derivadas de **DomainException** bajo la norma RFC 7807 (**InvalidTaxIdException**, **CorrelativeExhaustedException**, **VoucherImmutableException**).

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
\textbf{Firma o Tipo} & - \texttt{UUID id} \newline - \texttt{VoucherId voucherId} \newline - \texttt{Optional<\allowbreak UUID>\allowbreak  itemId} \newline - \texttt{VoucherItemType itemType} \newline - \texttt{String description} \newline - \texttt{Quantity quantity} \newline - \texttt{Money unitValue} \newline - \texttt{Money unitPrice} \newline - \texttt{Money igvAmount} \newline - \texttt{Money totalLine} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Factoría y totalización & Invariantes: cantidad estrictamente positiva. Descripción no vacía. Coherencia matemática entre valor unitario sin IGV y precio unitario gravado. El total de línea es igual al producto de cantidad por precio unitario. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{VoucherLine create(VoucherId,\allowbreak  Optional<\allowbreak UUID>\allowbreak ,\allowbreak  VoucherItemType,\allowbreak  String,\allowbreak  Quantity,\allowbreak  Money,\allowbreak  Money,\allowbreak  Money)} \newline - \texttt{Money calculateLineTotal()} \newline - \texttt{UUID id()} \newline - \texttt{VoucherItemType itemType()} \newline - \texttt{Quantity quantity()} \newline - \texttt{Money totalLine()} \\*
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
\textbf{Firma o Tipo} & - \texttt{record VoucherId(UUID value)} \newline - \texttt{record SeriesConfigurationId(UUID value)} \newline - \texttt{record PaymentId(UUID value)} \newline - \texttt{static of(UUID)} \newline - \texttt{static generate()} \\*
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