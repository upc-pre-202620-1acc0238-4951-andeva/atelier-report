### 2.6.4. *Bounded Context: Workshop Operations (MRO)*

El Bounded Context de Workshop Operations (MRO) constituye el motor productivo y operativo central de Atelier Platform. Su alcance comprende la orquestación integral del flujo de trabajo físico y técnico en el taller mecánico, desde la apertura de la orden de reparación tras la recepción vehicular, hasta la inspección pericial fotográfica, la asignación dinámica de bahías y técnicos, la ejecución secuencial de tareas mecánicas, el registro de demanda de repuestos y la liquidación técnica del servicio.

En la operativa diaria de los talleres automotrices, la falta de trazabilidad en las reparaciones representa una de las fuentes principales de desconfianza del cliente y colapso administrativo. Los clientes desconocen qué repuestos fueron realmente sustituidos, mientras que los mecánicos pierden horas en asignaciones manuales desorganizadas y sin registro fidedigno de los tiempos reales invertidos.

Para resolver esta problemática, la arquitectura establece una rigurosa segregación de responsabilidades entre la orden de trabajo (**WorkOrder**) y las labores técnicas atómicas (**WorkOrderTask**). La orden de trabajo actúa como el documento maestro de custodia y atención comercial, gestionado desde la aplicación web por el Asesor de Servicio a partir de la recepción vehicular. Por el contrario, las tareas técnicas representan intervenciones operativas concretas ejecutadas por los técnicos mecánicos en bahía o foso a través de la aplicación móvil de taller. Los mecánicos en foso no poseen atribuciones para crear órdenes de trabajo ni para autorizar tareas con impacto comercial sin consentimiento previo.

Durante la inspección en elevador o foso, cuando un técnico descubre una avería imprevista o un desgaste crítico oculto, el sistema canaliza dicho hallazgo mediante la entidad dependiente **TaskProposal**. El mecánico documenta el problema adjuntando evidencia fotográfica y una descripción técnica, enviando la propuesta al Asesor de Servicio sin calcular montos económicos arbitrarios. En lugar de emitir una notificación impersonal que desconcierte al conductor, el asesor ejerce un rol pedagógico y empático, contactando al cliente para explicarle con claridad técnica la necesidad de la reparación y el presupuesto asociado. Si el cliente aprueba la intervención, el asesor formaliza la propuesta como una nueva **WorkOrderTask** en estado asignado o pendiente. De ser desestimada, el hallazgo se archiva como antecedente clínico en el historial del vehículo, sirviendo de base para futuras alertas predictivas.

La raíz de agregado **WorkOrder** gobierna una rigurosa máquina de estados finita determinista:
$$\text{DRAFT} \longrightarrow \text{IN\_PROGRESS} \longrightarrow \text{COMPLETED} \longrightarrow \text{PAID}$$
mientras que las intervenciones técnicas individuales **WorkOrderTask** administran su propio ciclo operativo:
$$\text{PENDING} \longrightarrow \text{ASSIGNED} \longrightarrow \text{IN\_PROGRESS} \longleftrightarrow \text{ON\_HOLD} \longrightarrow \text{COMPLETED}$$
distinguiendo entre el tiempo efectivo de intervención (*Wrench Time*) y los periodos de detención por desabastecimiento logístico de repuestos (*Hold Time*).

Para asegurar la resiliencia operativa en zonas de baja conectividad dentro del taller, las interacciones perimetrales de las tareas se estructuran bajo un esquema de enrutamiento plano (*Shallow Routing*) sin anidamientos redundantes. Asimismo, cuando una labor demanda repuestos mediante **WorkOrderTaskProduct**, se emite el evento **ProductStockReservationRequestedEvent**, bloqueando de inmediato el stock bajo el método de costeo FIFO, consolidándose dicha reserva como descuento físico permanente únicamente al confirmarse el pago de la orden con **WorkOrderPaidEvent**.

Asimismo, el contexto incorpora el patrón Direct-to-Cloud para evidencias fotográficas mediante las entidades dependientes **WorkOrderImage** y **WorkOrderTaskImage**. La aplicación móvil del taller sube las fotografías tomadas en foso directamente a los depósitos seguros de Firebase Cloud Storage, persistiendo en la base de datos central únicamente los localizadores inmutables y metadatos de peritaje. Esto salvaguarda la memoria del servidor backend en Render y provee al conductor una prueba visual inalterable del estado de su vehículo antes y después de la intervención técnica.

#### 2.6.4.1. Domain Layer

La Capa de Dominio de Workshop Operations (MRO) constituye el núcleo productivo y motor transaccional de Atelier Platform, implementado bajo el paquete canónico com.andeva.atelier.platform.operations.domain. Su propósito es encapsular con máxima pureza y rigor la lógica operativa del taller automotriz, aislando las reglas físicas de mantenimiento mecánico respecto a los detalles periféricos de persistencia relacional, protocolos de transporte y facturación tributaria.

Para garantizar la integridad operativa del taller y la satisfacción técnica del cliente, la arquitectura de dominio se fundamenta en cuatro pilares tácticos esenciales:
- Consistencia transaccional del ciclo de reparación vehicular y máquina de estados finita: la orden de trabajo gobierna transiciones deterministas e irrevocables desde la recepción inicial hasta la entrega final del vehículo.
- Asignación determinista y gestión física de bahías operativas: controla el aforo físico de elevadores y áreas de foso por sede, garantizando la exclusión mutua de ocupación y evitando cuellos de botella en patio.
- Desacoplamiento multimedia mediante el patrón Direct-to-Cloud: preserva el rendimiento y memoria del servidor backend al delegar la subida de binarios fotográficos a Firebase Cloud Storage, persistiendo únicamente localizadores inmutables.
- Coordinación transaccional desacoplada con el módulo de inventario: gestiona la demanda de repuestos y lubricantes mediante eventos de dominio que solicitan reservas atómicas bajo el método de costeo FIFO.

En la @tbl:mro-domain-types se presenta el catálogo consolidado de los componentes que integran la Capa de Dominio de Workshop Operations.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo de la Capa de Dominio del Bounded Context Workshop Operations (MRO)} \label{tbl:mro-domain-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\
\hline
\endhead
WorkOrder & Raíz de consistencia de la reparación automotriz. Gobierna el ciclo de vida del servicio, la máquina de estados finita, la asignación de puestos físicos y el cómputo financiero del costo total. \\*
\hline
\textbf{Categoría} & Raíz de Agregado \\*
\hline
\textbf{Relaciones} & Generalización de AbstractDomainAggregateRoot<WorkOrder>. Composición 1 a N con WorkOrderTask, TaskProposal y WorkOrderImage. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak domain.\allowbreak model.\allowbreak aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
WorkBay & Espacio físico de taller habilitado en una sucursal específica. Administra disponibilidad operativa y exclusión mutua de ocupación vehicular para elevadores, cabinas de pintura y fosas. \\*
\hline
\textbf{Categoría} & Raíz de Agregado \\*
\hline
\textbf{Relaciones} & Generalización de AbstractDomainAggregateRoot<WorkBay>. Referencia a TenantId, BranchId y WorkOrderId. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak domain.\allowbreak model.\allowbreak aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Service & Catálogo maestro de servicios estándar y tarifas de mano de obra técnica del taller automotriz con duraciones de referencia. \\*
\hline
\textbf{Categoría} & Raíz de Agregado \\*
\hline
\textbf{Relaciones} & Generalización de AbstractDomainAggregateRoot<Service>. Referencia a TenantId. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak domain.\allowbreak model.\allowbreak aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
WorkOrderTask & Intervención técnica individual y atómica dentro del plan de trabajo. Registra mecánico asignado, horas hombre presupuestadas y reales, y demanda de componentes. \\*
\hline
\textbf{Categoría} & Entidad Dependiente \\*
\hline
\textbf{Relaciones} & Dependiente subordinada a WorkOrder. Composición 1 a N con WorkOrderTaskProduct y WorkOrderTaskImage. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak domain.\allowbreak model.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
WorkOrderTaskProduct & Demanda y consumo físico de un repuesto, insumo o lubricante para una tarea mecánica específica con cantidad y precio unitario pactado. \\*
\hline
\textbf{Categoría} & Entidad Dependiente \\*
\hline
\textbf{Relaciones} & Dependiente subordinada a WorkOrderTask. Referencia al catálogo de inventario de repuestos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak domain.\allowbreak model.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
WorkOrderImage & Registro de evidencia fotográfica del peritaje vehicular de recepción o entrega bajo el patrón de almacenamiento Direct-to-Cloud. \\*
\hline
\textbf{Categoría} & Entidad Dependiente \\*
\hline
\textbf{Relaciones} & Dependiente subordinada a WorkOrder. Contiene StorageUrl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak domain.\allowbreak model.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
WorkOrderTaskImage & Evidencia técnica pericial capturada por el técnico mecánico en foso durante la ejecución de una labor automotriz concreta. \\*
\hline
\textbf{Categoría} & Entidad Dependiente \\*
\hline
\textbf{Relaciones} & Dependiente subordinada a WorkOrderTask. Contiene StorageUrl y EvidenceType. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak domain.\allowbreak model.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
TaskProposal & Registro pericial de averías imprevistas y propuestas de labores adicionales detectadas durante la inspección técnica en foso. \\*
\hline
\textbf{Categoría} & Entidad Dependiente \\*
\hline
\textbf{Relaciones} & Dependiente subordinada a WorkOrder. Requiere validación y presupuesto del Asesor de Servicio para su formalización. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak domain.\allowbreak model.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
WorkOrderId & Identificador unívoco universal fuertemente tipado para órdenes de trabajo automotrices. \\*
\hline
\textbf{Categoría} & Objeto de Valor (ID) \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
WorkOrderNumber & Código correlativo formal y legible de la orden de servicio automotriz con formato formal canónico. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Registro inmutable con expresión regular de formato por taller. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
WorkOrderStatus & Enumeración del ciclo de vida operativo determinista de la orden de trabajo. \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Define estados DRAFT, IN\_PROGRESS, COMPLETED, PAID y CANCELED. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
WorkOrderTaskStatus & Enumeración del ciclo de vida operativo de las intervenciones mecánicas en foso. \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Define estados PENDING, ASSIGNED, IN\_PROGRESS, ON\_HOLD, COMPLETED y CANCELLED. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
HoldReason & Causal objetiva y auditable para la pausa temporal de intervenciones en foso. \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Define el motivo WAITING\_PARTS para congelar el cómputo de mano de obra activa. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
WorkBayId & Identificador unívoco universal fuertemente tipado para puestos físicos de taller. \\*
\hline
\textbf{Categoría} & Objeto de Valor (ID) \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
BayType & Clasificación física y electromecánica del puesto de trabajo en patio. \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Define tipos LIFT, PAINT\_BOOTH, WASHING y ALIGNMENT. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
BayStatus & Estados de disponibilidad y ocupación física del puesto de taller. \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Define estados AVAILABLE, OCCUPIED y MAINTENANCE. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
ProposalSeverity & Clasificación de gravedad técnica de las averías imprevistas detectadas en foso. \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Define niveles de severidad LOW, MEDIUM y CRITICAL. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
ProposalStatus & Estado del ciclo de concertación y resolución de propuestas técnicas adicionales. \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Define estados PENDING\_REVIEW, APPROVED y REJECTED. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
WorkOrderCostCalculator & Servicio de dominio que totaliza deterministamente mano de obra y repuestos aplicando el impuesto general a las ventas con redondeo bancario. \\*
\hline
\textbf{Categoría} & Servicio de Dominio \\*
\hline
\textbf{Relaciones} & Utilizado por WorkOrder para preservar la consistencia presupuestaria. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak domain.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
BayAllocationService & Servicio de dominio que valida la disponibilidad física de las bahías y previene sobreasignaciones vehiculares simultáneas. \\*
\hline
\textbf{Categoría} & Servicio de Dominio \\*
\hline
\textbf{Relaciones} & Consulta WorkBayRepository para verificar el aforo operativo. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak domain.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
WorkOrderTransitionValidator & Servicio de dominio que custodia la inviolabilidad de las transiciones de estado y precondiciones de finalización y cobro. \\*
\hline
\textbf{Categoría} & Servicio de Dominio \\*
\hline
\textbf{Relaciones} & Utilizado por WorkOrder antes de ejecutar cualquier mutación de ciclo de vida. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak domain.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
WorkOrderRepository & Contrato de persistencia agnóstico para la raíz de agregado WorkOrder. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Implementado en la capa de infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
WorkBayRepository & Contrato de persistencia agnóstico para la raíz de agregado WorkBay. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Implementado en la capa de infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
ServiceRepository & Contrato de persistencia agnóstico para la raíz de agregado Service. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Implementado en la capa de infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak domain.\allowbreak repositories} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes tácticos de la Capa de Dominio de Workshop Operations implementados bajo el paquete canónico com.andeva.atelier.platform.operations.domain.

**Raíces de Agregado y Entidades Dependientes de Workshop Operations**

El diseño estructural de Workshop Operations se organiza alrededor de la raíz de agregado **WorkOrder**, la cual centraliza el flujo de reparación mecánica y custodia las invariantes de consistencia física y financiera del taller. A su alrededor orbitan las raíces de agregado **WorkBay** y **Service**, complementadas por las entidades dependientes encargadas de desglosar las labores técnicas, cuantificar la demanda de repuestos y registrar las evidencias visuales.

- **WorkOrder**: Modela la orden de servicio automotriz como la frontera de consistencia principal del taller. El agregado controla la admisión vehicular a través de la factoría *create()*, requiriendo un kilometraje de odómetro no negativo (*mileageIn* ≥ 0) y un resumen de diagnóstico preliminar estructurado. La asignación física a una bahía operativa se realiza mediante *assignWorkBay()*, sin asociar el automóvil a un único técnico global, dado que las reparaciones se desglosan en labores atómicas especializadas. Su comportamiento interno está regido por una máquina de estados finita determinista:

$$\text{DRAFT} \xrightarrow{\text{startWork}} \text{IN\_PROGRESS} \xrightarrow{\text{completeAllTasks}} \text{COMPLETED} \xrightarrow{\text{markPaid}} \text{PAID}$$
$$\text{DRAFT / IN\_PROGRESS} \xrightarrow{\text{cancel}} \text{CANCELED}$$

La entidad prohíbe cualquier mutación en el plan de trabajo si el estado es final (**COMPLETED**, **PAID** o **CANCELED**). Asimismo, no admite la transición a **COMPLETED** si persisten labores pendientes, asignadas, en progreso o en pausa técnica (**ON\_HOLD**). Cada adición o retiro de tareas mecánicas o repuestos recalcula de forma inmediata y determinista el subtotal, el impuesto y el costo total de la orden.

Asimismo, la raíz de agregado custodia la colección interna de propuestas periciales (**proposals**). Cuando un técnico detecta una avería oculta durante la inspección en elevador, el agregado registra el hallazgo a través de *submitProposal()*, y tras la concertación empática del Asesor de Servicio con el cliente, formaliza la labor mediante *approveProposal()* o preserva el antecedente clínico mediante *rejectProposal()*.

En la @tbl:mro-workorder-members se detallan los atributos, firmas de operaciones y reglas de consistencia de la raíz de agregado **WorkOrder**.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de la Raíz de Agregado WorkOrder} \label{tbl:mro-workorder-members} \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Raíz de Agregado:} WorkOrder (Frontera de Consistencia de Reparación Automotriz)} \\*
\hline
id & Identificador unívoco universal de la orden de trabajo en la plataforma. \\*
\hline
\textbf{Tipo o Firma} & \texttt{WorkOrderId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
tenantId & Taller automotriz dueño y custodio del expediente de servicio. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TenantId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
branchId & Sede física del taller donde se ejecuta físicamente la atención técnica. \\*
\hline
\textbf{Tipo o Firma} & \texttt{BranchId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
appointmentId & Cita previa agendada que origina la apertura de la orden (opcional). \\*
\hline
\textbf{Tipo o Firma} & \texttt{AppointmentId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
vehicleId & Automóvil admitido a recepción e intervención en taller. \\*
\hline
\textbf{Tipo o Firma} & \texttt{VehicleId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
customerId & Cliente titular o empresa responsable del pago del servicio. \\*
\hline
\textbf{Tipo o Firma} & \texttt{CustomerId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
internalNumber & Código correlativo formal y legible de la orden de servicio. \\*
\hline
\textbf{Tipo o Firma} & \texttt{WorkOrderNumber} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
currentBayId & Bahía física asignada para la atención técnica del vehículo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{WorkBayId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
mileageIn & Kilometraje vehicular verificado en odómetro (*mileageIn* $\ge$ 0). \\*
\hline
\textbf{Tipo o Firma} & \texttt{Mileage} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
diagnosticSummary & Resumen preliminar de síntomas y diagnóstico inicial levantado. \\*
\hline
\textbf{Tipo o Firma} & \texttt{DiagnosticSummary} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
subtotal & Suma acumulada de mano de obra y repuestos antes de tributos. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
tax & Importe correspondiente al Impuesto General a las Ventas (18\%). \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
totalAmount & Monto total liquidado de la orden resultante de la suma de subtotal e impuesto. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
status & Estado actual en la máquina de estados finita determinista. \\*
\hline
\textbf{Tipo o Firma} & \texttt{WorkOrderStatus} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
tasks & Colección interna de tareas mecánicas atómicas presupuestadas. \\*
\hline
\textbf{Tipo o Firma} & \texttt{List<WorkOrderTask>} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
proposals & Colección de hallazgos periciales y propuestas de tareas adicionales detectadas en foso. \\*
\hline
\textbf{Tipo o Firma} & \texttt{List<TaskProposal>} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
intakeImages & Evidencias fotográficas del peritaje de recepción bajo Direct-to-Cloud. \\*
\hline
\textbf{Tipo o Firma} & \texttt{List<WorkOrderImage>} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
create & Factoría de dominio que inicializa la orden en DRAFT y registra evento. \\*
\hline
\textbf{Tipo o Firma} & \texttt{static WorkOrder create(...)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
assignWorkBay & Asigna o reubica el puesto físico de taller asociando la bahía a la orden. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void assignWorkBay(WorkBayId bayId)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
releaseBay & Libera la estación de trabajo física y emite WorkBayReleasedEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void releaseBay()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
startWork & Conmuta el estado de la orden a IN\_PROGRESS para iniciar faena en patio. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void startWork()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
addTask & Añade una nueva labor mecánica al plan de trabajo y recalcula importes. \\*
\hline
\textbf{Tipo o Firma} & \texttt{WorkOrderTask addTask(ServiceId sid,\allowbreak  UUID mid,\allowbreak  String desc,\allowbreak  Money price,\allowbreak  LaborHours est)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
removeTask & Remueve una tarea no ejecutada revirtiendo reservas de repuestos activas. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void removeTask(WorkOrderTaskId taskId)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
startTask & Inicia formalmente una labor mecánica individual en foso de trabajo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void startTask(WorkOrderTaskId taskId)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
completeTask & Finaliza la labor técnica registrando horas reales y evaluando cierre global. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void completeTask(WorkOrderTaskId taskId,\allowbreak  LaborHours actualHours)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
addProductToTask & Agrega repuesto o lubricante a la labor y solicita reserva a inventario. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void addProductToTask(WorkOrderTaskId tid,\allowbreak  UUID pid,\allowbreak  Quantity qty,\allowbreak  Money price)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
removeProductFromTask & Elimina repuesto de la labor y revierte la reserva de stock constituida. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void removeProductFromTask(WorkOrderTaskId tid,\allowbreak  WorkOrderTaskProductId pid)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
attachIntakeImage & Registra evidencia fotográfica de ingreso bajo el esquema Direct-to-Cloud. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void attachIntakeImage(StorageUrl imageUrl,\allowbreak  String description)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
submitProposal & Registra un hallazgo pericial en foso emitiendo TaskProposalSubmittedEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TaskProposal submitProposal(UUID mid,\allowbreak  String desc,\allowbreak  ProposalSeverity sev,\allowbreak  StorageUrl url,\allowbreak  ServiceId suggestedServiceId)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
approveProposal & Aprueba la propuesta concertada con el cliente e instancia una WorkOrderTask asignada. \\*
\hline
\textbf{Tipo o Firma} & \texttt{WorkOrderTask approveProposal(UUID propId,\allowbreak  ServiceId sid,\allowbreak  UUID mechanicId,\allowbreak  Money price,\allowbreak  LaborHours hrs,\allowbreak  String notes)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
rejectProposal & Registra el rechazo del cliente y preserva el hallazgo para el historial vehicular. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void rejectProposal(UUID propId,\allowbreak  String notes)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
recalculateTotalAmount & Suma mano de obra y repuestos aplicando IGV 18\% con redondeo bancario. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void recalculateTotalAmount()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
markPaid & Asienta la cancelación económica del servicio habilitando la entrega vehicular. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void markPaid()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
deliverVehicle & Formaliza la entrega física del automóvil al cliente cerrando la atención. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void deliverVehicle()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
cancel & Anula la orden liberando la bahía ocupada y revirtiendo reservas de repuestos. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void cancel(String reason)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de miembros y métodos de la raíz de agregado WorkOrder del paquete com.andeva.atelier.platform.operations.domain.model.aggregates.

Para modelar la complejidad operativa del trabajo mecánico en patio, **WorkOrder** se apoya en entidades dependientes encargadas de estructurar la mano de obra, el consumo de partes y los hallazgos periciales: **WorkOrderTask**, **WorkOrderTaskProduct** y **TaskProposal**.

- **WorkOrderTask**: Representa una intervención atómica de mano de obra adscrita a un servicio del catálogo. Gestiona su propio técnico mecánico ejecutor, el tiempo presupuestado mediante **LaborHours**, las marcas cronológicas exactas de inicio y fin, y las horas hombre reales consumidas. Provee métodos para el avance operativo y la agregación de repuestos, garantizando que ninguna tarea completada pueda ser alterada sin una reapertura explícita.

- **WorkOrderTaskProduct**: Cuantifica la demanda de un componente físico o fluido proveniente del catálogo de inventario. Almacena la cantidad requerida mediante **Quantity** y el precio unitario pactado al momento de su incorporación, calculando el importe total determinista de la pieza y emitiendo eventos de dominio hacia la cadena de suministro para reservar el lote correspondiente bajo la regla FIFO.

- **TaskProposal**: Modela las averías imprevistas y propuestas de tareas adicionales descubiertas por los mecánicos durante la inspección en foso o elevador. Almacena la severidad técnica mediante **ProposalSeverity**, el estado de concertación comercial mediante **ProposalStatus**, la evidencia fotográfica registrada y las notas pedagógicas acordadas con el cliente, proveyendo métodos *approve()* y *reject()* para gestionar su ciclo de vida.

En la @tbl:mro-task-product-members se especifican los miembros de las entidades dependientes **WorkOrderTask**, **WorkOrderTaskProduct** y **TaskProposal**.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de las Entidades Dependientes WorkOrderTask, WorkOrderTaskProduct y TaskProposal} \label{tbl:mro-task-product-members} \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad Dependiente:} WorkOrderTask (Intervención Mecánica Atómica)} \\*
\hline
id & Identificador unívoco universal de la labor mecánica en el plan técnico. \\*
\hline
\textbf{Tipo o Firma} & \texttt{WorkOrderTaskId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
workOrderId & Identificador de la orden de trabajo a la que se subordina la tarea. \\*
\hline
\textbf{Tipo o Firma} & \texttt{WorkOrderId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
serviceId & Identificador del servicio de catálogo de mano de obra asociado. \\*
\hline
\textbf{Tipo o Firma} & \texttt{ServiceId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
mechanicId & Identificador de membresía laboral del técnico mecánico ejecutante. \\*
\hline
\textbf{Tipo o Firma} & \texttt{UUID} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
status & Estado operativo de la labor (PENDING, ASSIGNED, IN\_PROGRESS, ON\_HOLD, COMPLETED o CANCELLED). \\*
\hline
\textbf{Tipo o Firma} & \texttt{WorkOrderTaskStatus} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
description & Memoria técnica y detalle del procedimiento mecánico a ejecutar. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
price & Costo cobrado por concepto de mano de obra para esta intervención. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
estimatedHours & Tiempo presupuestado en horas hombre para la intervención (*estimatedHours* > 0.00). \\*
\hline
\textbf{Tipo o Firma} & \texttt{LaborHours} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
actualHours & Tiempo real insumido por el mecánico tras culminar el procedimiento. \\*
\hline
\textbf{Tipo o Firma} & \texttt{LaborHours} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
startedAt & Marca temporal exacta en la cual el mecánico inició las tareas en foso. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Instant} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
completedAt & Marca temporal exacta en la cual se finalizó la faena mecánica. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Instant} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
consumedProducts & Colección de repuestos, lubricantes e insumos demandados por la tarea. \\*
\hline
\textbf{Tipo o Firma} & \texttt{List<WorkOrderTaskProduct>} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
taskImages & Evidencias fotográficas periciales capturadas durante la labor mecánica. \\*
\hline
\textbf{Tipo o Firma} & \texttt{List<WorkOrderTaskImage>} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
holdReason & Causal objetiva y auditable registrada al suspender temporalmente la faena. \\*
\hline
\textbf{Tipo o Firma} & \texttt{HoldReason} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
missingItemDescription & Descripción del repuesto o insumo faltante que motiva la suspensión temporal. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
pausedAt & Marca temporal en la cual se suspendió la intervención congelando el cómputo de horas. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Instant} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
totalPausedSeconds & Tiempo acumulado en segundos de interrupción por desabastecimiento de piezas. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Long} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
start & Inicia la intervención registrando startedAt y conmutando a IN\_PROGRESS. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void start()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
complete & Finaliza la labor registrando completedAt y las horas hombre reales. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void complete(LaborHours actualHours)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
reopen & Restaura el estado a IN\_PROGRESS ante necesidad de rectificación técnica. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void reopen()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
holdForWaitingParts & Suspende la intervención por falta de repuestos transicionando a ON\_HOLD y emitiendo evento. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void holdForWaitingParts(String missingItemDescription)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
resume & Reanuda la labor mecánica tras la llegada de piezas computando el tiempo detenido y volviendo a IN\_PROGRESS. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void resume()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
assignMechanic & Asocia el técnico responsable de la intervención transicionando a ASSIGNED. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void assignMechanic(UUID mechanicMembershipId)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
updatePrice & Actualiza la tarifa cobrada por la mano de obra de esta labor. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void updatePrice(Money newPrice)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
addProduct & Agrega una demanda de repuesto a la colección interna de la tarea. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void addProduct(WorkOrderTaskProduct product)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
removeProduct & Remueve un requerimiento de repuesto liberando el ítem asociado. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void removeProduct(WorkOrderTaskProductId productId)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad Dependiente:} WorkOrderTaskProduct (Demanda y Consumo de Repuestos)} \\*
\hline
id & Identificador unívoco universal del requerimiento de repuesto. \\*
\hline
\textbf{Tipo o Firma} & \texttt{WorkOrderTaskProductId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
taskId & Tarea mecánica que demanda el repuesto o lubricante. \\*
\hline
\textbf{Tipo o Firma} & \texttt{WorkOrderTaskId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
productId & Identificador del repuesto en el catálogo de inventario de piezas. \\*
\hline
\textbf{Tipo o Firma} & \texttt{UUID} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
quantity & Cantidad exacta solicitada con precisión de dos decimales (*quantity* > 0.00). \\*
\hline
\textbf{Tipo o Firma} & \texttt{Quantity} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
unitPrice & Precio unitario pactado al momento de su incorporación a la orden. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
totalAmount & Subtotal liquidado de la pieza calculado como cantidad por precio unitario. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
updateQuantity & Modifica la cantidad consumida y actualiza deterministamente el total. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void updateQuantity(Quantity newQuantity)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad Dependiente:} TaskProposal (Hallazgos Periciales y Propuestas Técnicas)} \\*
\hline
id & Identificador unívoco universal del hallazgo o propuesta de labor técnica. \\*
\hline
\textbf{Tipo o Firma} & \texttt{UUID} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
workOrderId & Orden de trabajo automotriz vinculada al hallazgo pericial. \\*
\hline
\textbf{Tipo o Firma} & \texttt{WorkOrderId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
taskId & Tarea técnica durante cuya ejecución se detectó la avería (opcional). \\*
\hline
\textbf{Tipo o Firma} & \texttt{WorkOrderTaskId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
suggestedServiceId & Servicio de catálogo sugerido para subsanar la avería (opcional). \\*
\hline
\textbf{Tipo o Firma} & \texttt{ServiceId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
mechanicId & Identificador de membresía laboral del mecánico que reportó el hallazgo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{UUID} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
description & Memoria técnica y descripción de la avería oculta detectada en foso. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
severity & Nivel de gravedad técnica del hallazgo (LOW, MEDIUM o CRITICAL). \\*
\hline
\textbf{Tipo o Firma} & \texttt{ProposalSeverity} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
imageUrl & Localizador HTTPS inmutable de la fotografía pericial en Firebase Storage. \\*
\hline
\textbf{Tipo o Firma} & \texttt{StorageUrl} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
status & Estado actual de la propuesta (PENDING\_REVIEW, APPROVED o REJECTED). \\*
\hline
\textbf{Tipo o Firma} & \texttt{ProposalStatus} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
customerNotes & Anotaciones de la concertación con el cliente o justificación de rechazo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
approve & Conmuta el estado a APPROVED registrando las notas pedagógicas acordadas. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void approve(String notes)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
reject & Conmuta el estado a REJECTED preservando la causa para el historial vehicular. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void reject(String customerReason)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de miembros de las entidades WorkOrderTask, WorkOrderTaskProduct y TaskProposal del paquete com.andeva.atelier.platform.operations.domain.model.entities.

El rigor pericial y la transparencia hacia el cliente demandan registrar pruebas gráficas inalterables del estado del automóvil. En lugar de procesar flujos pesados de bytes a través de la API en Spring Boot, el sistema delega la carga multimedia al dispositivo móvil mediante el patrón Direct-to-Cloud hacia Firebase Cloud Storage. Las entidades dependientes **WorkOrderImage** y **WorkOrderTaskImage** encapsulan los metadatos de dichas evidencias:

- **WorkOrderImage**: Custodia las fotografías periciales de recepción y entrega del vehículo, asociando la dirección **StorageUrl** inmutable y una nota descriptiva sobre averías preexistentes para deslindar responsabilidades legales del taller.

- **WorkOrderTaskImage**: Registra el peritaje técnico específico de una labor en foso, tipificando la evidencia mediante **EvidenceType** para documentar piezas desgastadas frente a componentes nuevos recién instalados.

En la @tbl:mro-image-evidence-members se especifican los miembros de las entidades multimedia de peritaje **WorkOrderImage** y **WorkOrderTaskImage**.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de las Entidades Multimedia de Peritaje WorkOrderImage y WorkOrderTaskImage} \label{tbl:mro-image-evidence-members} \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad Dependiente:} WorkOrderImage (Peritaje de Recepción y Entrega)} \\*
\hline
id & Identificador unívoco universal del registro fotográfico pericial. \\*
\hline
\textbf{Tipo o Firma} & \texttt{UUID} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
workOrderId & Orden de trabajo a la cual pertenece la fotografía de recepción o entrega. \\*
\hline
\textbf{Tipo o Firma} & \texttt{WorkOrderId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
imageUrl & Dirección URL HTTPS inmutable alojada en Firebase Cloud Storage. \\*
\hline
\textbf{Tipo o Firma} & \texttt{StorageUrl} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
description & Nota pericial descriptiva de abolladuras o desperfectos preexistentes. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
uploadedAt & Marca temporal exacta de captura y registro de la fotografía en el sistema. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Instant} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad Dependiente:} WorkOrderTaskImage (Evidencias Técnicas de Reparación)} \\*
\hline
id & Identificador unívoco universal de la evidencia técnica en foso. \\*
\hline
\textbf{Tipo o Firma} & \texttt{UUID} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
taskId & Tarea mecánica a la cual se vincula la evidencia técnica fotográfica. \\*
\hline
\textbf{Tipo o Firma} & \texttt{WorkOrderTaskId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
imageUrl & Dirección URL HTTPS inmutable alojada en Firebase Cloud Storage. \\*
\hline
\textbf{Tipo o Firma} & \texttt{StorageUrl} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
evidenceType & Tipología técnica de la evidencia (INITIAL\_INSPECTION, DEFECT, IN\_PROGRESS o COMPLETED). \\*
\hline
\textbf{Tipo o Firma} & \texttt{EvidenceType} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
description & Detalle pericial de la pieza averiada o del procedimiento de montaje efectuado. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
uploadedAt & Marca temporal exacta de carga de la evidencia fotográfica desde el móvil. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Instant} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de miembros de las entidades multimedia WorkOrderImage y WorkOrderTaskImage del paquete com.andeva.atelier.platform.operations.domain.model.entities.

La gestión del espacio físico en patio y la estandarización del portafolio técnico se resuelven mediante dos raíces de agregado independientes pero articuladas: **WorkBay** y **Service**.

- **WorkBay**: Modela los puestos físicos de trabajo del taller clasificados según su tipología mecánica (**BayType**). Administra su condición operativa (**BayStatus**), prohibiendo la sobreasignación de bahías en estado ocupado o bajo mantenimiento técnico para evitar colisiones operativas en el patio de maniobras.

- **Service**: Representa el catálogo maestro de mano de obra del taller automotriz. Define la tarifa base sugerida y la duración promedio en minutos para estandarizar cotizaciones y alimentar la planificación de agendas.

En la @tbl:mro-bay-service-members se exponen los atributos, métodos y reglas de negocio de las raíces de agregado **WorkBay** y **Service**.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de las Raíces de Agregado WorkBay y Service} \label{tbl:mro-bay-service-members} \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Raíz de Agregado:} WorkBay (Puesto Físico de Taller)} \\*
\hline
id & Identificador unívoco universal del puesto físico de trabajo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{WorkBayId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
tenantId & Taller mecánico titular de las instalaciones físicas de patio. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TenantId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
branchId & Sede física donde se encuentra emplazada la bahía operativa. \\*
\hline
\textbf{Tipo o Firma} & \texttt{BranchId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
name & Denominación visual identificatoria de la bahía (longitud entre 2 y 50 caracteres). \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
type & Tipología técnica de la bahía (LIFT, PAINT\_BOOTH, WASHING o ALIGNMENT). \\*
\hline
\textbf{Tipo o Firma} & \texttt{BayType} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
status & Estado operativo actual del puesto (AVAILABLE, OCCUPIED o MAINTENANCE). \\*
\hline
\textbf{Tipo o Firma} & \texttt{BayStatus} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
currentWorkOrderId & Orden de trabajo que ocupa físicamente la bahía o nulo si desocupada. \\*
\hline
\textbf{Tipo o Firma} & \texttt{WorkOrderId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
create & Factoría de dominio que inicializa el puesto físico en estado AVAILABLE. \\*
\hline
\textbf{Tipo o Firma} & \texttt{static WorkBay create(...)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
occupy & Asocia la orden de trabajo activa y conmuta el estado de la bahía a OCCUPIED. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void occupy(WorkOrderId orderId)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
release & Desvincula la orden atendida y restituye la condición operativa a AVAILABLE. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void release()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
setUnderMaintenance & Inhabilita el puesto por avería o calibración conmutando a MAINTENANCE. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void setUnderMaintenance(String reason)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
restoreAvailable & Concluye los trabajos de mantenimiento restituyendo la bahía a AVAILABLE. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void restoreAvailable()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Raíz de Agregado:} Service (Catálogo Maestro de Mano de Obra)} \\*
\hline
id & Identificador unívoco universal del servicio técnico de catálogo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{ServiceId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
tenantId & Taller automotriz dueño del catálogo tarifario de servicios. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TenantId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
name & Denominación estandarizada del servicio (longitud entre 3 y 150 caracteres). \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
basePrice & Tarifa base sugerida de mano de obra antes de impuestos (*basePrice* $\ge$ 0.00). \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
estimatedDurationMinutes & Tiempo de referencia estándar en minutos (*estimatedDurationMinutes* > 0). \\*
\hline
\textbf{Tipo o Firma} & \texttt{int} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
create & Factoría de dominio para registrar un nuevo servicio estándar en el taller. \\*
\hline
\textbf{Tipo o Firma} & \texttt{static Service create(...)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
updateDetails & Actualiza denominación comercial, tarifa de mano de obra y tiempo estimado. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void updateDetails(String name,\allowbreak  Money price,\allowbreak  int minutes)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de miembros de los agregados WorkBay y Service del paquete com.andeva.atelier.platform.operations.domain.model.aggregates.

**Objetos de Valor y Enumeraciones de Workshop Operations**

Siguiendo el principio de encapsulamiento y erradicación de la obsesión por tipos primitivos, Workshop Operations modela sus conceptos de valor como registros inmutables de Java. Estos componentes garantizan autovalidación en el constructor compacto e impiden estados corruptos en odómetros, horas hombre, cómputos de repuestos o localizadores multimedia.

En la @tbl:mro-value-objects se especifican los objetos de valor y enumeraciones propios de este contexto.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Objetos de Valor y Enumeraciones del Bounded Context Workshop Operations (MRO)} \label{tbl:mro-value-objects} \\
\hline
\thfirst{Componente de Dominio} & \thcell{Especificación Técnica y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Componente de Dominio} & \thcell{Especificación Técnica y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} WorkOrderId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal de orden de trabajo automotriz. Inmutable y no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} WorkOrderNumber} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: String} \\*
\hline
\textbf{Restricciones y Reglas} & Código formal legible bajo expresión regular canónica WO-YYYYMM-XXXX único por taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} WorkOrderTaskId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal para labores mecánicas atómicas. Inmutable y no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} WorkOrderTaskProductId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal para demandas de repuestos en tareas. Inmutable y no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} WorkBayId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal para puestos físicos de taller. Inmutable y no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} ServiceId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal para servicios del catálogo maestro. Inmutable y no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} Mileage} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: Integer} \\*
\hline
\textbf{Restricciones y Reglas} & Kilometraje automotriz entero registrado en odómetro. Valor estrictamente no negativo (*value* $\ge$ 0). \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} DiagnosticSummary} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: String} \\*
\hline
\textbf{Restricciones y Reglas} & Resumen técnico de recepción normalizado sin espacios repetitivos con longitud máxima de 2000 caracteres. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} LaborHours} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: BigDecimal} \\*
\hline
\textbf{Restricciones y Reglas} & Registro de horas hombre con escala fija a dos decimales y valor estrictamente positivo (*value* > 0.00). \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} Quantity} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: BigDecimal} \\*
\hline
\textbf{Restricciones y Reglas} & Magnitud física de repuestos o lubricantes con escala fija a dos decimales (*value* > 0.00). \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} StorageUrl} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: String} \\*
\hline
\textbf{Restricciones y Reglas} & Dirección URL HTTPS validada proveniente de Firebase Cloud Storage o Google Cloud Storage. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} WorkOrderStatus} \\*
\hline
\textbf{Valores Admisibles} & \texttt{DRAFT}, \texttt{IN\_PROGRESS}, \texttt{COMPLETED}, \texttt{PAID}, \texttt{CANCELED} \\*
\hline
\textbf{Restricciones y Reglas} & Ciclo de vida determinista de la orden de trabajo en el taller mecánico. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} WorkOrderTaskStatus} \\*
\hline
\textbf{Valores Admisibles} & \texttt{PENDING}, \texttt{ASSIGNED}, \texttt{IN\_PROGRESS}, \texttt{ON\_HOLD}, \texttt{COMPLETED}, \texttt{CANCELLED} \\*
\hline
\textbf{Restricciones y Reglas} & Estados secuenciales de ejecución operativa de la labor mecánica en foso. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} HoldReason} \\*
\hline
\textbf{Valores Admisibles} & \texttt{WAITING\_PARTS} \\*
\hline
\textbf{Restricciones y Reglas} & Justificación objetiva admitida para suspender temporalmente el cómputo de horas hombre efectivas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} BayType} \\*
\hline
\textbf{Valores Admisibles} & \texttt{LIFT}, \texttt{PAINT\_BOOTH}, \texttt{WASHING}, \texttt{ALIGNMENT} \\*
\hline
\textbf{Restricciones y Reglas} & Clasificación física y electromecánica del puesto operativo de patio. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} BayStatus} \\*
\hline
\textbf{Valores Admisibles} & \texttt{AVAILABLE}, \texttt{OCCUPIED}, \texttt{MAINTENANCE} \\*
\hline
\textbf{Restricciones y Reglas} & Disponibilidad física de la estación de trabajo automotriz. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} EvidenceType} \\*
\hline
\textbf{Valores Admisibles} & \texttt{INITIAL\_INSPECTION}, \texttt{DEFECT}, \texttt{IN\_PROGRESS}, \texttt{COMPLETED} \\*
\hline
\textbf{Restricciones y Reglas} & Clasificación pericial técnica de la fotografía de evidencia capturada en foso. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} ProposalSeverity} \\*
\hline
\textbf{Valores Admisibles} & \texttt{LOW}, \texttt{MEDIUM}, \texttt{CRITICAL} \\*
\hline
\textbf{Restricciones y Reglas} & Nivel de gravedad y riesgo técnico de una avería imprevista detectada en foso. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} ProposalStatus} \\*
\hline
\textbf{Valores Admisibles} & \texttt{PENDING\_REVIEW}, \texttt{APPROVED}, \texttt{REJECTED} \\*
\hline
\textbf{Restricciones y Reglas} & Estado del flujo de evaluación y concertación de propuestas de labores adicionales. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes inmutables del paquete com.andeva.atelier.platform.operations.domain.model.valueobjects.

**Servicios de Dominio de Workshop Operations**

Aquellas reglas complejas que coordinan múltiples agregados o imponen cálculos algorítmicos transversales sin encajar naturalmente dentro de una sola entidad se encapsulan como servicios de dominio puros:

- **WorkOrderCostCalculator**: Orquesta el recálculo financiero integral de la orden sumando la mano de obra de tareas y los repuestos demandados. Aplica la alícuota del Impuesto General a las Ventas (IGV 18\%) mediante redondeo bancario determinista con modo HALF\_EVEN, garantizando paridad matemática absoluta con los comprobantes tributarios emitidos por el módulo de facturación.

- **BayAllocationService**: Verifica la disponibilidad física de los puestos de taller consultando el repositorio de bahías. Comprueba que el puesto pertenezca a la misma sucursal donde se ejecuta el servicio y no albergue otro vehículo en atención simultánea.

- **WorkOrderTransitionValidator**: Garantiza la inviolabilidad de la máquina de estados finita determinista, evaluando precondiciones operativas rigurosas antes de autorizar el cierre técnico o la liquidación económica.

En la @tbl:mro-domain-services se exponen las especificaciones y responsabilidades de estos tres servicios de dominio.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Servicios de Dominio del Bounded Context Workshop Operations (MRO)} \label{tbl:mro-domain-services} \\
\hline
\thfirst{Aspecto de Servicio} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Servicio} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Dominio:} WorkOrderCostCalculator} \\*
\hline
\textbf{Métodos Principales} & \texttt{calculateTotal(WorkOrder workOrder)} \\*
\hline
\textbf{Responsabilidad} & Totaliza deterministamente mano de obra y repuestos aplicando IGV 18\% con redondeo bancario HALF\_EVEN. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Dominio:} BayAllocationService} \\*
\hline
\textbf{Métodos Principales} & \texttt{validateBayAvailability(WorkBayId bayId,\allowbreak  WorkOrderId orderId)} \\*
\hline
\textbf{Responsabilidad} & Evalúa la disponibilidad física de la bahía y su pertenencia a la misma sucursal previniendo sobreasignaciones. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Dominio:} WorkOrderTransitionValidator} \\*
\hline
\textbf{Métodos Principales} & \texttt{validateTransition(WorkOrder workOrder,\allowbreak  WorkOrderStatus targetStatus)} \\*
\hline
\textbf{Responsabilidad} & Impone el cumplimiento de la máquina de estados y verifica precondiciones operativas de cierre técnico y cobranza. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes ubicados en el paquete com.andeva.atelier.platform.operations.domain.services.

**Puertos de Repositorio de la Capa de Dominio**

En estricta observancia de los postulados de Clean Architecture, la capa de dominio expone contratos de persistencia abstractos que declaran las necesidades de almacenamiento sin establecer dependencias con frameworks relacionales:

- **WorkOrderRepository**: Contrato para la persistencia del agregado **WorkOrder**, incorporando búsquedas por identificador interno, correlativo formal, vehículo, cliente y generación de secuencia correlativa por taller.

- **WorkBayRepository**: Contrato para la consulta y control de aforo de bahías operativas, proveyendo filtros por sucursal, disponibilidad y tipología física.

- **ServiceRepository**: Contrato para administrar el catálogo maestro de servicios estándar y tarifas de mano de obra técnica del taller.

En la @tbl:mro-repository-ports se detallan las operaciones provistas por estos puertos de salida.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Puertos de Repositorio del Bounded Context Workshop Operations (MRO)} \label{tbl:mro-repository-ports} \\
\hline
\thfirst{Aspecto de Puerto} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Puerto} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Repositorio:} WorkOrderRepository} \\*
\hline
\textbf{Métodos Principales} & - \texttt{save} \newline - \texttt{findById} \newline - \texttt{findByOrderNumber} \newline - \texttt{findByTenantId} \newline - \texttt{findByBranchId} \newline - \texttt{findByVehicleId} \newline - \texttt{findByCustomerId} \newline - \texttt{findByCurrentBayId} \newline - \texttt{findNextInternalSequence} \\*
\hline
\textbf{Responsabilidad de Dominio} & Persistencia y consulta de órdenes de trabajo por identificador, número correlativo, sucursal, vehículo y cliente. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Repositorio:} WorkBayRepository} \\*
\hline
\textbf{Métodos Principales} & - \texttt{save} \newline - \texttt{findById} \newline - \texttt{findByTenantIdAndBranchId} \newline - \texttt{findAvailableBays} \\*
\hline
\textbf{Responsabilidad de Dominio} & Persistencia, control de aforo y consulta de disponibilidad de bahías operativas por sucursal y tipología. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Repositorio:} ServiceRepository} \\*
\hline
\textbf{Métodos Principales} & - \texttt{save} \newline - \texttt{findById} \newline - \texttt{findByTenantId} \newline - \texttt{findByTenantIdAndName} \\*
\hline
\textbf{Responsabilidad de Dominio} & Persistencia y consulta del catálogo tarifario maestro de servicios y paquetes de mano de obra del taller. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Interfaces de salida ubicadas en el paquete com.andeva.atelier.platform.operations.domain.repositories.

**Taxonomía de Eventos de Dominio de Workshop Operations**

Los eventos de dominio de Workshop Operations modelan hechos de negocio irrevocables ocurridos en el taller. Todos implementan la interfaz canónica **DomainEvent** provista por el Shared Kernel para su despacho seguro mediante el Transactional Outbox:

- **Coordinación física y asignación técnica**: **WorkOrderCreatedEvent**, **WorkBayAssignedEvent** y **WorkBayReleasedEvent** informan la apertura de la orden y la ocupación o desocupación de bahías en el tablero de control de patio.

- **Ejecución operativa y productividad laboral**: **WorkOrderTaskAssignedEvent**, **WorkOrderTaskStartedEvent**, **WorkOrderTaskHoldEvent**, **WorkOrderTaskResumedEvent** y **WorkOrderTaskCompletedEvent** difunden el avance de faena técnica distinguiendo horas efectivas de pausas por repuestos.

- **Hallazgos periciales y propuestas de foso**: **TaskProposalSubmittedEvent**, **TaskProposalApprovedEvent** y **TaskProposalRejectedEvent** notifican el hallazgo imprevisto, la aprobación concertada con el cliente o la desestimación para el historial clínico vehicular.

- **Integración transaccional con inventario**: **ProductStockReservationRequestedEvent** y **ProductStockReservationCancelledEvent** coordinan de forma asíncrona y atómica el bloqueo o restitución de piezas en los almacenes bajo el método FIFO.

- **Cierre comercial, facturación y peritaje**: **WorkOrderCompletedEvent**, **WorkOrderPaidEvent** y **WorkOrderDeliveredEvent** habilitan la emisión fiscal, la liberación del automóvil y el despacho de notificaciones push, mientras que **WorkOrderIntakeImageAttachedEvent** y **WorkOrderTaskEvidenceAttachedEvent** respaldan el expediente fotográfico inmutable.

En la @tbl:mro-domain-events se sintetiza la taxonomía de los dieciocho eventos de dominio de este contexto.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Taxonomía de Eventos de Dominio del Bounded Context Workshop Operations (MRO)} \label{tbl:mro-domain-events} \\
\hline
\thfirst{Aspecto del Evento} & \thcell{Especificación de Carga Útil y Efecto} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Evento} & \thcell{Especificación de Carga Útil y Efecto} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} WorkOrderCreatedEvent \quad (\textit{Emisor:} WorkOrder)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{tenantId}, \texttt{branchId}, \texttt{vehicleId}, \texttt{customerId}, \texttt{internalNumber}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Notifica la apertura formal de la orden de trabajo para alistar la bahía de recepción e iniciar inspección. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} WorkBayAssignedEvent \quad (\textit{Emisor:} WorkOrder)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{bayId}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Comunica la ocupación física de la bahía y actualiza el tablero de control de patio. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} WorkBayReleasedEvent \quad (\textit{Emisor:} WorkOrder)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{bayId}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Informa la liberación del puesto de trabajo restituyendo disponibilidad física en el tablero de control de patio. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} WorkOrderTaskAssignedEvent \quad (\textit{Emisor:} WorkOrderTask)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{taskId}, \texttt{mechanicId}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Notifica al mecánico asignado sobre la nueva labor técnica programada en su terminal móvil. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} WorkOrderTaskStartedEvent \quad (\textit{Emisor:} WorkOrderTask)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{taskId}, \texttt{mechanicId}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Registra el inicio de faena mecánica en foso y sincroniza el estado de la orden global a IN\_PROGRESS. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} WorkOrderTaskHoldEvent \quad (\textit{Emisor:} WorkOrderTask)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{taskId}, \texttt{reason}, \texttt{missingItemDescription}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Informa la detención de la labor por desabastecimiento alertando a almacén y al asesor de servicio. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} WorkOrderTaskResumedEvent \quad (\textit{Emisor:} WorkOrderTask)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{taskId}, \texttt{pausedDurationSeconds}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Notifica la reactivación de la faena mecánica en foso tras la provisión de las piezas requeridas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} WorkOrderTaskCompletedEvent \quad (\textit{Emisor:} WorkOrderTask)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{taskId}, \texttt{mechanicId}, \texttt{actualHours}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Notifica la finalización de la labor técnica registrando las horas hombre consumidas para métricas de productividad. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} TaskProposalSubmittedEvent \quad (\textit{Emisor:} WorkOrder)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{proposalId}, \texttt{mechanicId}, \texttt{severity}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Notifica al Asesor de Servicio sobre una avería imprevista detectada en foso para evaluación y presupuesto. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} TaskProposalApprovedEvent \quad (\textit{Emisor:} WorkOrder)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{proposalId}, \texttt{createdTaskId}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Comunica la formalización de la tarea tras la concertación con el cliente incorporándola al plan de trabajo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} TaskProposalRejectedEvent \quad (\textit{Emisor:} WorkOrder)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{proposalId}, \texttt{customerNotes}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Registra la desestimación del cliente archivando el antecedente para el historial clínico de mantenimiento predictivo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} ProductStockReservationRequestedEvent \quad (\textit{Emisor:} WorkOrder)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{taskId}, \texttt{productId}, \texttt{quantity}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Solicita al contexto de inventario el bloqueo y reserva inmediata de existencias bajo el método FIFO. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} ProductStockReservationCancelledEvent \quad (\textit{Emisor:} WorkOrder)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{taskId}, \texttt{productId}, \texttt{quantity}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Notifica la anulación de la demanda de una pieza liberando la reserva de existencias previamente constituida. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} WorkOrderCompletedEvent \quad (\textit{Emisor:} WorkOrder)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{tenantId}, \texttt{vehicleId}, \texttt{totalAmount}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Notifica la culminación técnica de todas las tareas habilitando a facturación para la emisión del comprobante. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} WorkOrderPaidEvent \quad (\textit{Emisor:} WorkOrder)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{tenantId}, \texttt{totalAmount}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Comunica la cancelación financiera del servicio habilitando el procedimiento de entrega formal del automóvil. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} WorkOrderDeliveredEvent \quad (\textit{Emisor:} WorkOrder)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{tenantId}, \texttt{vehicleId}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Registra la salida física del vehículo concluyendo el ciclo MRO y despachando notificación de cierre al cliente. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} WorkOrderIntakeImageAttachedEvent \quad (\textit{Emisor:} WorkOrder)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{imageId}, \texttt{imageUrl}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Registra la vinculación de evidencia pericial fotográfica de recepción bajo almacenamiento Direct-to-Cloud. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} WorkOrderTaskEvidenceAttachedEvent \quad (\textit{Emisor:} WorkOrder)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{taskId}, \texttt{imageId}, \texttt{imageUrl}, \texttt{evidenceType}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Registra la evidencia técnica del componente sustituido para alimentar el expediente digital pericial de reparación. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Eventos de dominio ubicados bajo el paquete com.andeva.atelier.platform.operations.domain.events.

**Excepciones de Dominio y Manejo de Errores Semánticos**

El tratamiento de desviaciones en el flujo operativo se gestiona mediante excepciones no comprobadas fuertemente tipadas derivadas de **DomainException**. Cada excepción encapsula un código legible y su estatus HTTP según la norma RFC 7807:

- **Anomalías de entidades de operaciones**: **WorkOrderNotFoundException**, **WorkBayNotFoundException** y **ServiceNotFoundException** cuando los identificadores no corresponden a registros válidos en el taller.

- **Conflictos de ocupación y mantenimiento**: **WorkBayOccupiedException** y **WorkBayUnderMaintenanceException** si se intenta asignar un vehículo a un puesto no disponible.

- **Infracciones de máquina de estados**: **InvalidWorkOrderStatusTransitionException**, **WorkOrderTaskAlreadyCompletedException**, **TaskCannotBePutOnHoldException**, **TaskNotOnHoldException** y **WorkOrderCannotBePaidException** ante operaciones incompatibles con la fase actual del servicio.

- **Gestión de propuestas y hallazgos periciales**: **TaskProposalNotFoundException** y **TaskProposalAlreadyProcessedException** al operar sobre propuestas inexistentes o previamente resueltas.

- **Violaciones de invariantes de valor**: **InvalidMileageException**, **InvalidStorageUrlException**, **InvalidLaborHoursException** e **InvalidQuantityException** si los datos numéricos o formatos no satisfacen las restricciones de negocio.

En la @tbl:mro-domain-exceptions se sintetiza la jerarquía de excepciones de dominio y sus códigos de error semánticos asociados.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.8cm} | >{\raggedright\arraybackslash}p{9.6cm} |}
\caption{Excepciones de Dominio y Códigos Semánticos de Workshop Operations (MRO)} \label{tbl:mro-domain-exceptions} \\
\hline
\thfirst{Código de Error Semántico} & \thcell{Condición de Lanzamiento en el Modelo} \\
\hline
\endfirsthead
\hline
\thfirst{Código de Error Semántico} & \thcell{Condición de Lanzamiento en el Modelo} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} WorkOrderNotFoundException} \\*
\hline
\texttt{WORK\_ORDER\_NOT\_FOUND} & La orden de trabajo consultada no existe en la base de datos del taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} WorkBayNotFoundException} \\*
\hline
\texttt{WORK\_BAY\_NOT\_FOUND} & El puesto físico de taller solicitado no existe en la sucursal indicada. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} ServiceNotFoundException} \\*
\hline
\texttt{SERVICE\_NOT\_FOUND} & El servicio de mano de obra del catálogo maestro no se encuentra registrado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} WorkBayOccupiedException} \\*
\hline
\texttt{WORK\_BAY\_OCCUPIED} & La bahía física seleccionada alberga actualmente otro vehículo en atención activa. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} WorkBayUnderMaintenanceException} \\*
\hline
\texttt{WORK\_BAY\_UNDER\_MAINTENANCE} & El puesto físico se encuentra inhabilitado por avería mecánica o calibración periódica. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} InvalidWorkOrderStatusTransitionException} \\*
\hline
\texttt{INVALID\_WORK\_ORDER\_STATUS\_TRANSITION} & La transición de estado solicitada infringe la máquina de estados finita determinista. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} WorkOrderTaskNotFoundException} \\*
\hline
\texttt{WORK\_ORDER\_TASK\_NOT\_FOUND} & La labor técnica mecánica consultada no pertenece a la orden de trabajo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} WorkOrderTaskAlreadyCompletedException} \\*
\hline
\texttt{WORK\_ORDER\_TASK\_ALREADY\_COMPLETED} & No se permite reiniciar o alterar una labor mecánica concluida satisfactoriamente. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} TaskCannotBePutOnHoldException} \\*
\hline
\texttt{TASK\_CANNOT\_BE\_PUT\_ON\_HOLD} & La labor mecánica no se encuentra en estado IN\_PROGRESS para ser suspendida por falta de partes. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} TaskNotOnHoldException} \\*
\hline
\texttt{TASK\_NOT\_ON\_HOLD} & La labor técnica no se encuentra en estado ON\_HOLD para ser reanudada. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} WorkOrderCannotBePaidException} \\*
\hline
\texttt{WORK\_ORDER\_CANNOT\_BE\_PAID} & No es admisible registrar la liquidación económica de una orden que no esté en estado COMPLETED. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} InvalidMileageException} \\*
\hline
\texttt{INVALID\_MILEAGE} & El kilometraje de odómetro suministrado en recepción es un valor numérico negativo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} InvalidStorageUrlException} \\*
\hline
\texttt{INVALID\_STORAGE\_URL} & La dirección URL multimedia no satisface el protocolo HTTPS seguro hacia Firebase Cloud Storage. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} InvalidLaborHoursException} \\*
\hline
\texttt{INVALID\_LABOR\_HOURS} & La cantidad de horas hombre suministrada es menor o igual a cero o carece de escala a dos decimales. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} InvalidQuantityException} \\*
\hline
\texttt{INVALID\_QUANTITY} & La cantidad de repuestos demandada es menor o igual a cero o presenta escala incompatible. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} TaskProposalNotFoundException} \\*
\hline
\texttt{TASK\_PROPOSAL\_NOT\_FOUND} & El hallazgo pericial o propuesta de tarea consultada no existe dentro de la orden de trabajo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} TaskProposalAlreadyProcessedException} \\*
\hline
\texttt{TASK\_PROPOSAL\_ALREADY\_PROCESSED} & La propuesta ya fue resuelta previamente y no admite modificaciones posteriores. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes ubicados bajo el paquete com.andeva.atelier.platform.operations.domain.exceptions.

A partir de la formalización táctica de Workshop Operations, se identifican tres fundamentos de ingeniería de software que consolidan la robustez y resiliencia del subsistema productivo en el taller automotriz:

El primer fundamento reside en el determinismo estricto de la máquina de estados de la orden de trabajo, la cual previene estados corruptos e inconsistencias operativas en el patio de servicio. Al imponer que toda mutación transaccional valide exhaustivamente sus precondiciones y transiciones permitidas dentro de la raíz de agregado, se garantiza que ningún vehículo pueda ser facturado o retirado de las instalaciones del taller sin haber completado satisfactoriamente la totalidad de las intervenciones mecánicas planificadas.

El segundo pilar radica en la mitigación de sobrecarga y contención de recursos en el servidor backend mediante el desacoplamiento multimedia del patrón Direct-to-Cloud. Al delegar la transferencia binaria de imágenes periciales de alta resolución hacia Firebase Cloud Storage y confinar el alcance del dominio al registro inmutable de localizadores HTTPS validados, el sistema elimina cuellos de botella de memoria en el runtime de Spring Boot y provee a clientes y mecánicos un expediente visual transparente e inalterable.

El tercer fundamento se sustenta en la integridad referencial y coordinación asíncrona desacoplada con los subsistemas periféricos de inventario y facturación. Mediante la emisión de eventos de dominio tipados para la reserva y consumo de repuestos bajo el método contable FIFO y la posterior proforma tributaria, MRO salvaguarda su autonomía transaccional sin incurrir en acoplamientos rígidos de persistencia, manteniendo consistencia eventual sólida a través del Transactional Outbox.

#### 2.6.4.2. Interface Layer

La Capa de Interfaz del Bounded Context Workshop Operations (MRO) actúa como el adaptador primario perimetral bajo el paquete canónico **com.andeva.atelier.platform.operations.interfaces**. Su propósito arquitectónico consiste en traducir las interacciones externas provenientes de clientes web y dispositivos móviles hacia invocaciones deterministas sobre los casos de uso transaccionales, salvaguardando la integridad del núcleo operativo del taller mecánico.

Para asegurar una frontera desacoplada y alineada a los requerimientos de alta concurrencia en planta, el diseño perimetral de Workshop Operations se rige por cinco directrices tácticas fundamentales:

- **Mediación determinista mediante tipos funcionales sellados**: La interacción con la Capa de Aplicación se gestiona de forma estricta a través del contenedor tipado **Result<T, ApplicationError>**, canalizando excepciones de infraestructura hacia respuestas de error HTTP predecibles sin propagar fallos no controlados.
- **Modelado RESTful estricto y enrutamiento plano (*Shallow Routing*)**: Las URIs erradican anidamientos de más de dos niveles. Las labores en foso se orquestan bajo **/api/v1/tasks/{taskId}**, mientras que la orden macro gobierna apertura, puestos físicos y propuestas bajo **/api/v1/work-orders**.
- **Flujo concertado de propuestas y peritaje humano**: Los hallazgos periciales imprevistos se canalizan hacia el Asesor de Servicio, quien valida el informe y entabla un diálogo empático y pedagógico con el cliente antes de su aprobación o desestimación formal.
- **Desacoplamiento multimedia Direct-to-Cloud**: La captura de evidencias fotográficas delega la transferencia de secuencias binarias a Firebase Cloud Storage, recibiendo en el perímetro únicamente localizadores validados para evitar la degradación de memoria en el servidor.
- **Publicación transaccional y fachada de contexto abierto**: La coordinación intermodular se instrumenta mediante eventos de integración emitidos a través del Transactional Outbox y una interfaz pública de contexto para consultas síncronas en memoria, preservando la autonomía transaccional frente a facturación e inventario.

En la @tbl:mro-interface-types se sintetiza el catálogo consolidado de tipos, controladores, recursos de transporte, ensambladores y eventos que integran la Capa de Interfaz de Workshop Operations.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo Consolidado de la Capa de Interfaz de Workshop Operations (MRO)} \label{tbl:mro-interface-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endhead
WorkOrdersController & Endpoints REST para apertura, supervisión, asignación de bahías, propuestas periciales y liquidación de órdenes. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca WorkOrderCommandService y WorkOrderQueryService. Utiliza ensambladores de recursos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
TasksController & Endpoints REST de enrutamiento plano para ejecución técnica en foso, repuestos y evidencias fotográficas. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca WorkOrderCommandService. Gestiona entidades WorkOrderTask, TaskProduct y WorkOrderTaskImage. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
WorkBaysController & Endpoints REST para administración física de elevadores, cabinas de pintura y puestos de taller. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca WorkBayCommandService y WorkBayQueryService. Gestiona entidades WorkBay. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
ServicesController & Endpoints REST para gestión del tarifario maestro de servicios y tiempos estimados de intervención. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca ServiceCommandService y ServiceQueryService. Gestiona entidades Service. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Create\allowbreak WorkOrder\allowbreak Resource & Carga útil inmutable para recepción vehicular y apertura formal de orden de trabajo de reparación. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por CreateWorkOrderCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Assign\allowbreak WorkBay\allowbreak Resource & Carga útil para asignación física o reubicación de una orden de trabajo hacia una bahía libre. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por AssignWorkBayCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Create\allowbreak WorkOrderTask\allowbreak Resource & Carga útil para incorporación de una nueva labor técnica formal autorizada con técnico asignado. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por CreateWorkOrderTaskCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Assign\allowbreak TaskMechanic\allowbreak Resource & Carga útil para asignación de técnico mecánico responsable a una labor técnica en foso. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por AssignTaskMechanicCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Hold\allowbreak Task\allowbreak Resource & Carga útil para suspender temporalmente una tarea en foso indicando el repuesto faltante. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por HoldTaskCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Submit\allowbreak TaskProposal\allowbreak Resource & Carga útil para reporte de avería imprevista detectada en foso con fotografía y severidad. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por SubmitTaskProposalCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Approve\allowbreak TaskProposal\allowbreak Resource & Carga útil para aprobación de propuesta por el Asesor tras concertación comercial con el cliente. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por ApproveTaskProposalCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Reject\allowbreak TaskProposal\allowbreak Resource & Carga útil para desestimación de propuesta registrando las razones expresadas por el cliente. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por RejectTaskProposalCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Complete\allowbreak Task\allowbreak Resource & Carga útil para registro de culminación de tarea con horas hombre reales insumidas y notas. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por CompleteWorkOrderTaskCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Add\allowbreak TaskProduct\allowbreak Resource & Carga útil para solicitud de repuesto con cantidad demandada y reserva en inventario. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por AddTaskProductCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Update\allowbreak TaskProduct\allowbreak Resource & Carga útil para ajuste de cantidad demandada de repuesto consumido en foso. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por UpdateTaskProductQuantityCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Attach\allowbreak Image\allowbreak Resource & Carga útil con localizador HTTPS de imagen pericial registrada en Firebase Cloud Storage. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por AttachIntakeImageCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Attach\allowbreak TaskEvidence\allowbreak Resource & Carga útil con localizador HTTPS de evidencia técnica fotográfica de la intervención en foso. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por AttachTaskEvidenceCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Cancel\allowbreak WorkOrder\allowbreak Resource & Carga útil con justificación explícita de anulación de la orden de trabajo. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por CancelWorkOrderCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Create\allowbreak WorkBay\allowbreak Resource & Carga útil para alta física de un nuevo puesto de trabajo en la sucursal. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por CreateWorkBayCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Create\allowbreak Service\allowbreak Resource & Carga útil para registro de un nuevo servicio estándar en el catálogo del taller. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por CreateServiceCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
WorkOrder\allowbreak Resource & Representación pública inmutable del estado general y totales de la orden de trabajo. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por WorkOrderResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
WorkOrder\allowbreak Summary\allowbreak Resource & Resumen ligero de la orden para cuadrículas de monitorización y tableros en planta. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por WorkOrderResourceAssembler para consultas paginadas. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
WorkOrder\allowbreak Detail\allowbreak Resource & Expediente técnico exhaustivo con tareas mecánicas, repuestos y evidencias fotográficas. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por WorkOrderResourceAssembler resolviendo entidades dependientes. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
WorkOrder\allowbreak Task\allowbreak Resource & Ficha operativa de labor en foso con cómputo de horas, repuestos y evidencias asociadas. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por WorkOrderTaskResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
TaskProposal\allowbreak Resource & Representación inmutable del hallazgo pericial con estado de concertación y notas del cliente. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por TaskProposalResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
TaskProduct\allowbreak Resource & Detalle de repuesto consumido en la labor con cantidades, precio unitario y total. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Incluido dentro de WorkOrderTaskResource. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
WorkOrder\allowbreak Image\allowbreak Resource & Metadatos inmutables de imagen fotográfica de peritaje inicial vehicular. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Incluido dentro de WorkOrderDetailResource. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
WorkBay\allowbreak Resource & Representación inmutable del puesto físico, tipología operativa y estado de ocupación. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por WorkBayResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Service\allowbreak Resource & Representación inmutable del servicio técnico en catálogo con precio base y duración. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por ServiceResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Create\allowbreak WorkOrder\allowbreak Command\allowbreak From\allowbreak Resource\allowbreak Assembler & Ensamblador que transforma el recurso de recepción vehicular en comando transaccional. \\*
\hline
\textbf{Categoría} & Ensamblador Inbound \\*
\hline
\textbf{Relaciones} & Construye CreateWorkOrderCommand inyectando el identificador del taller. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
WorkOrder\allowbreak Resource\allowbreak Assembler & Ensamblador que traduce el agregado WorkOrder hacia representaciones DTO públicas. \\*
\hline
\textbf{Categoría} & Ensamblador Outbound \\*
\hline
\textbf{Relaciones} & Mapea agregados hacia WorkOrderResource y WorkOrderDetailResource. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Submit\allowbreak TaskProposal\allowbreak Command\allowbreak From\allowbreak Resource\allowbreak Assembler & Ensamblador que transforma el reporte de foso en comando de registro de propuesta. \\*
\hline
\textbf{Categoría} & Ensamblador Inbound \\*
\hline
\textbf{Relaciones} & Construye SubmitTaskProposalCommand vinculando la orden y el mecánico. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Approve\allowbreak TaskProposal\allowbreak Command\allowbreak From\allowbreak Resource\allowbreak Assembler & Ensamblador que transforma la resolución del Asesor en comando de aprobación formal. \\*
\hline
\textbf{Categoría} & Ensamblador Inbound \\*
\hline
\textbf{Relaciones} & Construye ApproveTaskProposalCommand con tarifa e imputación pactada. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Reject\allowbreak TaskProposal\allowbreak Command\allowbreak From\allowbreak Resource\allowbreak Assembler & Ensamblador que traduce la desestimación del cliente en comando de rechazo pericial. \\*
\hline
\textbf{Categoría} & Ensamblador Inbound \\*
\hline
\textbf{Relaciones} & Construye RejectTaskProposalCommand preservando motivos en el historial. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Update\allowbreak TaskProduct\allowbreak Quantity\allowbreak Command\allowbreak From\allowbreak Resource\allowbreak Assembler & Ensamblador que transforma el recurso de ajuste de repuesto en comando transaccional. \\*
\hline
\textbf{Categoría} & Ensamblador Inbound \\*
\hline
\textbf{Relaciones} & Construye UpdateTaskProductQuantityCommand vinculando tarea y repuesto. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
TaskProposal\allowbreak Resource\allowbreak Assembler & Ensamblador que traduce la entidad TaskProposal hacia su representación pública DTO. \\*
\hline
\textbf{Categoría} & Ensamblador Outbound \\*
\hline
\textbf{Relaciones} & Mapea TaskProposal hacia TaskProposalResource. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Assign\allowbreak TaskMechanic\allowbreak Command\allowbreak From\allowbreak Resource\allowbreak Assembler & Ensamblador que transforma el recurso de asignación técnica en comando transaccional. \\*
\hline
\textbf{Categoría} & Ensamblador Inbound \\*
\hline
\textbf{Relaciones} & Construye AssignTaskMechanicCommand vinculando tarea y técnico. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Hold\allowbreak Task\allowbreak Command\allowbreak From\allowbreak Resource\allowbreak Assembler & Ensamblador que transforma el reporte de suspensión por repuestos en comando transaccional. \\*
\hline
\textbf{Categoría} & Ensamblador Inbound \\*
\hline
\textbf{Relaciones} & Construye HoldTaskCommand con causal y descripción de insumo faltante. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Resume\allowbreak Task\allowbreak Command\allowbreak From\allowbreak Resource\allowbreak Assembler & Ensamblador que construye el comando transaccional de reanudación de intervención mecánica. \\*
\hline
\textbf{Categoría} & Ensamblador Inbound \\*
\hline
\textbf{Relaciones} & Construye ResumeTaskCommand para reactivar faena en foso. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak rest.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Workshop\allowbreak Operations\allowbreak Context\allowbreak Facade & Interfaz pública que expone consultas y verificaciones de operaciones en memoria. \\*
\hline
\textbf{Categoría} & Fachada de Contexto (OHS) \\*
\hline
\textbf{Relaciones} & Consumida por Facturación Electrónica, Inventario y CRM. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Workshop\allowbreak Operations\allowbreak Context\allowbreak FacadeImpl & Implementación de la fachada que consulta repositorios preservando los agregados. \\*
\hline
\textbf{Categoría} & Implementación ACL \\*
\hline
\textbf{Relaciones} & Implementa WorkshopOperationsContextFacade desacoplando el modelo interno. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
WorkOrder\allowbreak Created\allowbreak Integration\allowbreak Event & Notificación asíncrona de orden abierta para actualización en CRM y Atelier Driver. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. Notifica la recepción física del automóvil. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
WorkOrder\allowbreak Completed\allowbreak Integration\allowbreak Event & Notificación asíncrona de orden culminada para emisión de comprobante en Invoicing. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. Desencadena la liquidación tributaria SUNAT. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Product\allowbreak StockReservation\allowbreak Requested\allowbreak Integration\allowbreak Event & Notificación asíncrona para reserva física y costeo FIFO en Inventory. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. Solicita la asignación de lotes de repuestos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
WorkBay\allowbreak Assigned\allowbreak Integration\allowbreak Event & Notificación asíncrona de bahía física asignada o reubicada para monitores de patio. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. Notifica ocupación física de la bahía. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
WorkOrderTask\allowbreak Assigned\allowbreak Integration\allowbreak Event & Notificación asíncrona enviada al dispositivo móvil del técnico sobre nueva labor asignada. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. Despacha alerta técnica directa al mecánico. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
WorkOrderTask\allowbreak Hold\allowbreak Integration\allowbreak Event & Notificación asíncrona de detención operativa de labor por desabastecimiento de piezas. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. Alerta a almacén de inventario y al asesor de servicio. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
WorkOrderTask\allowbreak Resumed\allowbreak Integration\allowbreak Event & Notificación asíncrona de reactivación de faena técnica en foso tras la provisión de partes. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. Informa el restablecimiento de faena en patio. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak interfaces.\allowbreak events} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al paquete canónico com.andeva.atelier.platform.operations.interfaces.

A continuación, se profundiza en la especificación a manera de diccionario de cada una de las clases, ensambladores y controladores que integran esta capa.

**Controladores REST y Endpoints de Comunicación**

La exposición perimetral de servicios HTTP se organiza en cuatro controladores especializados anotados mediante la anotación RestController y documentados mediante especificaciones OpenAPI 3, aplicando el principio de enrutamiento superficial (*Shallow Routing*) para preservar URIs canónicas de dos niveles de profundidad:

- **WorkOrdersController**: Orquesta el ciclo de vida integral del expediente de taller bajo la ruta canónica /api/v1/work-orders. Gestiona la apertura de la orden en recepción física, la asignación y desasignación de puestos de trabajo, la vinculación de labores mecánicas planificadas por el Asesor de Servicio, el registro de fotografías periciales de recepción, las transiciones deterministas de estado y la gestión pericial de propuestas técnicas originadas por hallazgos imprevistos de foso.

- **TasksController**: Centraliza las operaciones directas sobre tareas técnicas atómicas bajo la ruta canónica /api/v1/tasks. Permite a los técnicos de planta iniciar, culminar o reabrir intervenciones mecánicas, gestionar la demanda de repuestos con reserva física en inventario y adjuntar evidencias fotográficas periciales directas a la labor asignada.

- **WorkBaysController**: Administra la capacidad física instalada del taller mecánico bajo la ruta canónica /api/v1/work-bays. Facilita el registro de puestos físicos de atención, la consulta filtrada por tipología técnica y disponibilidad de uso, así como el bloqueo preventivo por mantenimiento de maquinaria o su restitución al servicio activo.

- **ServicesController**: Custodia el catálogo maestro y tarifario estándar de mano de obra bajo la ruta canónica /api/v1/services. Provee puntos de acceso para la definición de servicios mecánicos estandarizados, la consulta perimetral del catálogo y la actualización de tarifas base y tiempos referenciales.

En la @tbl:mro-controllers-and-endpoints se detallan las rutas, verbos HTTP, códigos de estado y tipos asociados a los controladores de Workshop Operations.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\raggedright\arraybackslash}p{6.0cm} | >{\raggedright\arraybackslash}p{9.4cm} |}
\caption{Controladores REST y Endpoints de Comunicación de Workshop Operations (MRO)} \label{tbl:mro-controllers-and-endpoints} \\
\hline
\thfirst{Recurso de Petición} & \thcell{Código y Respuesta HTTP} \\
\hline
\endfirsthead
\hline
\thfirst{Recurso de Petición} & \thcell{Código y Respuesta HTTP} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} WorkOrdersController} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak work-orders}} \\*
\hline
\textbf{Petición:} \texttt{CreateWorkOrderResource} & \textbf{Respuesta:} 201 CREATED (\texttt{WorkOrderResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak work-orders}} \\*
\hline
\textbf{Petición:} Parámetros de consulta (\texttt{branchId}, \texttt{status}, \texttt{vehicleId}) & \textbf{Respuesta:} 200 OK (\texttt{PagedModel\textless WorkOrderSummaryResource\textgreater}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak work-orders/\allowbreak \{workOrderId\}}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{WorkOrderDetailResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{PUT} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak work-orders/\allowbreak \{workOrderId\}/\allowbreak bay}} \\*
\hline
\textbf{Petición:} \texttt{AssignWorkBayResource} & \textbf{Respuesta:} 200 OK (\texttt{WorkOrderResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{DELETE} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak work-orders/\allowbreak \{workOrderId\}/\allowbreak bay}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 204 NO CONTENT \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak work-orders/\allowbreak \{workOrderId\}/\allowbreak tasks}} \\*
\hline
\textbf{Petición:} \texttt{CreateWorkOrderTaskResource} & \textbf{Respuesta:} 201 CREATED (\texttt{WorkOrderTaskResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak work-orders/\allowbreak \{workOrderId\}/\allowbreak intake-images}} \\*
\hline
\textbf{Petición:} \texttt{AttachImageResource} & \textbf{Respuesta:} 201 CREATED (\texttt{WorkOrderImageResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak work-orders/\allowbreak \{workOrderId\}/\allowbreak start}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{WorkOrderResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak work-orders/\allowbreak \{workOrderId\}/\allowbreak complete}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{WorkOrderResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak work-orders/\allowbreak \{workOrderId\}/\allowbreak cancel}} \\*
\hline
\textbf{Petición:} \texttt{CancelWorkOrderResource} & \textbf{Respuesta:} 200 OK (\texttt{WorkOrderResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak work-orders/\allowbreak \{workOrderId\}/\allowbreak mark-as-paid}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{WorkOrderResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak work-orders/\allowbreak \{workOrderId\}/\allowbreak proposals}} \\*
\hline
\textbf{Petición:} \texttt{SubmitTaskProposalResource} & \textbf{Respuesta:} 201 CREATED (\texttt{TaskProposalResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak work-orders/\allowbreak \{workOrderId\}/\allowbreak proposals}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{List\textless TaskProposalResource\textgreater}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak work-orders/\allowbreak \{workOrderId\}/\allowbreak proposals/\allowbreak \{proposalId\}/\allowbreak approve}} \\*
\hline
\textbf{Petición:} \texttt{ApproveTaskProposalResource} & \textbf{Respuesta:} 200 OK (\texttt{WorkOrderTaskResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak work-orders/\allowbreak \{workOrderId\}/\allowbreak proposals/\allowbreak \{proposalId\}/\allowbreak reject}} \\*
\hline
\textbf{Petición:} \texttt{RejectTaskProposalResource} & \textbf{Respuesta:} 200 OK (\texttt{TaskProposalResource}) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} TasksController} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tasks/\allowbreak \{taskId\}}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{WorkOrderTaskResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{PUT} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tasks/\allowbreak \{taskId\}}} \\*
\hline
\textbf{Petición:} \texttt{UpdateWorkOrderTaskResource} & \textbf{Respuesta:} 200 OK (\texttt{WorkOrderTaskResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tasks/\allowbreak \{taskId\}/\allowbreak assign}} \\*
\hline
\textbf{Petición:} \texttt{AssignTaskMechanicResource} & \textbf{Respuesta:} 200 OK (\texttt{WorkOrderTaskResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tasks/\allowbreak \{taskId\}/\allowbreak start}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{WorkOrderTaskResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tasks/\allowbreak \{taskId\}/\allowbreak hold}} \\*
\hline
\textbf{Petición:} \texttt{HoldTaskResource} & \textbf{Respuesta:} 200 OK (\texttt{WorkOrderTaskResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tasks/\allowbreak \{taskId\}/\allowbreak resume}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{WorkOrderTaskResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tasks/\allowbreak \{taskId\}/\allowbreak complete}} \\*
\hline
\textbf{Petición:} \texttt{CompleteTaskResource} & \textbf{Respuesta:} 200 OK (\texttt{WorkOrderTaskResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tasks/\allowbreak \{taskId\}/\allowbreak reopen}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{WorkOrderTaskResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tasks/\allowbreak \{taskId\}/\allowbreak products}} \\*
\hline
\textbf{Petición:} \texttt{AddTaskProductResource} & \textbf{Respuesta:} 201 CREATED (\texttt{TaskProductResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{PUT} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tasks/\allowbreak \{taskId\}/\allowbreak products/\allowbreak \{productId\}}} \\*
\hline
\textbf{Petición:} \texttt{UpdateTaskProductResource} & \textbf{Respuesta:} 200 OK (\texttt{TaskProductResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{DELETE} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tasks/\allowbreak \{taskId\}/\allowbreak products/\allowbreak \{productId\}}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 204 NO CONTENT \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tasks/\allowbreak \{taskId\}/\allowbreak evidence-images}} \\*
\hline
\textbf{Petición:} \texttt{AttachTaskEvidenceResource} & \textbf{Respuesta:} 201 CREATED (\texttt{WorkOrderTaskImageResource}) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} WorkBaysController} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak work-bays}} \\*
\hline
\textbf{Petición:} \texttt{CreateWorkBayResource} & \textbf{Respuesta:} 201 CREATED (\texttt{WorkBayResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak work-bays}} \\*
\hline
\textbf{Petición:} Parámetros de consulta (\texttt{branchId}, \texttt{bayType}, \texttt{status}) & \textbf{Respuesta:} 200 OK (\texttt{List\textless WorkBayResource\textgreater}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak work-bays/\allowbreak \{bayId\}}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{WorkBayResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{PUT} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak work-bays/\allowbreak \{bayId\}/\allowbreak maintenance}} \\*
\hline
\textbf{Petición:} \texttt{MaintenanceBayResource} & \textbf{Respuesta:} 200 OK (\texttt{WorkBayResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{PUT} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak work-bays/\allowbreak \{bayId\}/\allowbreak restore}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{WorkBayResource}) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} ServicesController} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak services}} \\*
\hline
\textbf{Petición:} \texttt{CreateServiceResource} & \textbf{Respuesta:} 201 CREATED (\texttt{ServiceResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak services}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{List\textless ServiceResource\textgreater}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak services/\allowbreak \{serviceId\}}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{ServiceResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{PUT} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak services/\allowbreak \{serviceId\}}} \\*
\hline
\textbf{Petición:} \texttt{UpdateServiceResource} & \textbf{Respuesta:} 200 OK (\texttt{ServiceResource}) \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Controladores REST ubicados en com.andeva.atelier.platform.operations.interfaces.rest.controllers.

En sus relaciones de colaboración, estos controladores inyectan los servicios de comando y consulta de la Capa de Aplicación, delegando de forma exclusiva la ejecución de la lógica transaccional y empleando ensambladores para desacoplar el transporte web del modelo de dominio interno.

**Recursos DTO de Petición y Respuesta HTTP**

Para impedir la exposición directa de las entidades de persistencia y asegurar la validación sintáctica de las peticiones en el perímetro, la capa define un catálogo de registros inmutables estructurados como objetos de transferencia de datos.

Los recursos de petición se implementan como registros inmutables de Java decorados con anotaciones de Jakarta Bean Validation. Componentes como **CreateWorkOrderResource**, **CreateWorkOrderTaskResource**, **AssignTaskMechanicResource**, **HoldTaskResource**, **UpdateWorkOrderTaskResource**, **AddTaskProductResource**, **UpdateTaskProductResource**, **SubmitTaskProposalResource**, **ApproveTaskProposalResource**, **RejectTaskProposalResource** y **AttachImageResource** validan de forma defensiva la presencia de identificadores obligatorios, valores numéricos mayores a cero, localizadores HTTPS válidos y restricciones de longitud antes de alcanzar los servicios de aplicación.

Por su parte, los recursos de respuesta encapsulan las cargas útiles entregadas a los clientes web y móviles mediante estructuras inmutables. Destacan **WorkOrderSummaryResource**, optimizado para el refresco rápido de monitores de taller, **WorkOrderDetailResource**, que consolida el expediente integral con tareas, propuestas periciales, repuestos y fotografías, **WorkOrderTaskResource**, portador del desglose operativo y cómputo de horas de intervención técnica, y **TaskProposalResource**, representativo de los hallazgos técnicos registrados en foso.

En la @tbl:mro-resources-dtos se especifican los atributos y restricciones de validación de estos recursos DTO.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Recursos DTO de Entrada y Salida del Bounded Context Workshop Operations (MRO)} \label{tbl:mro-resources-dtos} \\
\hline
\thfirst{Aspecto de Recurso} & \thcell{Especificación de Atributos e Integridad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Recurso} & \thcell{Especificación de Atributos e Integridad} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} CreateWorkOrderResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{appointmentId}, \texttt{vehicleId}, \texttt{mileageIn}, \texttt{diagnosticSummary} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotNull} en vehículo y kilometraje, \texttt{@PositiveOrZero} en kilometraje y \texttt{@Size(max = 2000)} en diagnóstico. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} AssignWorkBayResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{bayId} \\*
\hline
\textbf{Validación de Integridad} & Anotación \texttt{@NotNull} para el identificador de bahía física. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} CreateWorkOrderTaskResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{serviceId}, \texttt{mechanicId}, \texttt{description}, \texttt{price}, \texttt{currency} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotNull}, \texttt{@NotBlank}, \texttt{@Size(max = 1000)}, \texttt{@Positive} para precio y \texttt{@Pattern(regexp = "PEN|USD")} para divisa. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} AssignTaskMechanicResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{mechanicId} \\*
\hline
\textbf{Validación de Integridad} & Anotación \texttt{@NotNull} para el identificador del técnico mecánico asignado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} HoldTaskResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{reason}, \texttt{missingItemDescription}, \texttt{inventoryItemId} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotNull} para motivo \texttt{WAITING\_PARTS}, \texttt{@NotBlank} y \texttt{@Size(max = 1000)} para detalle de pieza faltante. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} UpdateWorkOrderTaskResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{description}, \texttt{price}, \texttt{currency} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank}, \texttt{@Size(max = 1000)}, \texttt{@Positive} para precio y \texttt{@Pattern(regexp = "PEN|USD")} para divisa. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} CompleteTaskResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{actualLaborHours}, \texttt{notes} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotNull}, \texttt{@Positive} para horas hombre reales y \texttt{@Size(max = 1000)} para notas técnicas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} AddTaskProductResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{productId}, \texttt{quantity}, \texttt{unitPrice}, \texttt{currency} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotNull}, \texttt{@Positive} en cantidad y precio unitario, y \texttt{@Pattern(regexp = "PEN|USD")} en divisa. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} UpdateTaskProductResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{quantity} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotNull} y \texttt{@Positive} para ajuste de cantidad física de repuesto en labor. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} SubmitTaskProposalResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{description}, \texttt{severity}, \texttt{evidenceImageUrl}, \texttt{suggestedServiceId} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank}, \texttt{@Size(max = 1000)}, \texttt{@NotNull} para severidad y \texttt{@URL} para evidencia en Firebase Storage. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} ApproveTaskProposalResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{advisorNotes}, \texttt{mechanicId} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@Size(max = 500)} para notas del asesor y \texttt{@NotNull} para asignación técnica. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} RejectTaskProposalResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{customerRejectionReason} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank} y \texttt{@Size(max = 1000)} para justificación comunicada por el cliente. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} AttachImageResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{imageUrl}, \texttt{description} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank}, \texttt{@URL} para localizador de Firebase Storage y \texttt{@Size(max = 500)}. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} AttachTaskEvidenceResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{imageUrl}, \texttt{description} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank}, \texttt{@URL} para evidencia en Firebase Storage y \texttt{@Size(max = 500)}. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} CancelWorkOrderResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{reason} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank} y \texttt{@Size(max = 1000)} para justificación técnica de anulación. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} CreateWorkBayResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{branchId}, \texttt{name}, \texttt{bayType} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotNull}, \texttt{@NotBlank}, \texttt{@Size(max = 100)} y \texttt{@Pattern} con tipologías permitidas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} MaintenanceBayResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{reason} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank} y \texttt{@Size(max = 1000)} para causal de mantenimiento. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} CreateServiceResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{name}, \texttt{basePrice}, \texttt{currency}, \texttt{estimatedMinutes} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank}, \texttt{@Size(max = 150)}, \texttt{@Positive} en tarifa base y minutos, y \texttt{@Pattern(regexp = "PEN|USD")}. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} UpdateServiceResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{name}, \texttt{basePrice}, \texttt{currency}, \texttt{estimatedMinutes} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank}, \texttt{@Size(max = 150)}, \texttt{@Positive} en tarifa base y minutos, y \texttt{@Pattern(regexp = "PEN|USD")}. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} WorkOrderResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{tenantId}, \texttt{internalNumber}, \texttt{vehicleId}, \texttt{currentBayId}, \texttt{mileageIn}, \texttt{status}, \texttt{totalAmount}, \texttt{currency} \\*
\hline
\textbf{Validación de Integridad} & Representación pública inmutable del estado general y totales de la orden de trabajo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} WorkOrderSummaryResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{tenantId}, \texttt{internalNumber}, \texttt{vehicleId}, \texttt{currentBayId}, \texttt{bayName}, \texttt{status}, \texttt{totalAmount}, \texttt{currency}, \texttt{createdAt} \\*
\hline
\textbf{Validación de Integridad} & Resumen ligero para colecciones tabulares y cuadrículas de monitorización en planta. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} WorkOrderDetailResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{tenantId}, \texttt{internalNumber}, \texttt{vehicleId}, \texttt{currentBayId}, \texttt{bayName}, \texttt{mileageIn}, \texttt{diagnosticSummary}, \texttt{status}, \texttt{totalAmount}, \texttt{currency}, \texttt{tasks}, \texttt{proposals}, \texttt{intakeImages}, \texttt{createdAt}, \texttt{updatedAt} \\*
\hline
\textbf{Validación de Integridad} & Expediente consolidado integral de la orden con tareas mecánicas, propuestas técnicas periciales, repuestos y evidencias fotográficas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} WorkOrderTaskResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{workOrderId}, \texttt{serviceId}, \texttt{serviceName}, \texttt{mechanicId}, \texttt{mechanicName}, \texttt{status}, \texttt{description}, \texttt{price}, \texttt{currency}, \texttt{startedAt}, \texttt{completedAt}, \texttt{holdReason}, \texttt{missingItemDescription}, \texttt{totalPausedSeconds}, \texttt{products}, \texttt{evidenceImages} \\*
\hline
\textbf{Validación de Integridad} & Detalle de labor en foso con cómputo de horas, pausas por repuestos, insumos consumidos y evidencias fotográficas técnicas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} TaskProductResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{taskId}, \texttt{productId}, \texttt{productName}, \texttt{quantity}, \texttt{unitPrice}, \texttt{totalAmount}, \texttt{currency} \\*
\hline
\textbf{Validación de Integridad} & Ficha de repuesto demandado con cantidades físicas y costeo total calculado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} WorkOrderImageResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{workOrderId}, \texttt{imageUrl}, \texttt{description}, \texttt{uploadedAt} \\*
\hline
\textbf{Validación de Integridad} & Metadatos inmutables de imagen pericial registrada durante la recepción vehicular inicial. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} WorkOrderTaskImageResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{taskId}, \texttt{imageUrl}, \texttt{description}, \texttt{uploadedAt} \\*
\hline
\textbf{Validación de Integridad} & Metadatos inmutables de evidencia fotográfica de intervención técnica en foso. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} TaskProposalResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{workOrderId}, \texttt{mechanicId}, \texttt{description}, \texttt{severity}, \texttt{evidenceImageUrl}, \texttt{suggestedServiceId}, \texttt{status}, \texttt{submittedAt}, \texttt{reviewedAt}, \texttt{reviewNotes}, \texttt{createdTaskId} \\*
\hline
\textbf{Validación de Integridad} & Representación pública inmutable de la propuesta técnica de foso y su resolución pericial por el Asesor. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} WorkBayResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{tenantId}, \texttt{branchId}, \texttt{name}, \texttt{bayType}, \texttt{status}, \texttt{currentWorkOrderId} \\*
\hline
\textbf{Validación de Integridad} & Estado físico de la bahía operativa, tipología de maquinaria y vehículo en atención técnica. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} ServiceResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{tenantId}, \texttt{name}, \texttt{basePrice}, \texttt{currency}, \texttt{estimatedMinutes} \\*
\hline
\textbf{Validación de Integridad} & Ficha pública de servicio mecánico en catálogo tarifario estándar del taller. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes ubicados en el paquete com.andeva.atelier.platform.operations.interfaces.rest.resources.

**Ensambladores y Transformadores de Recursos**

El desacoplamiento entre las peticiones HTTP y los casos de uso transaccionales se materializa a través de ensambladores bidireccionales. Los ensambladores de entrada, tales como **CreateWorkOrderCommandFromResourceAssembler**, **AssignTaskMechanicCommandFromResourceAssembler**, **HoldTaskCommandFromResourceAssembler**, **ResumeTaskCommandFromResourceAssembler**, **SubmitTaskProposalCommandFromResourceAssembler**, **ApproveTaskProposalCommandFromResourceAssembler**, **RejectTaskProposalCommandFromResourceAssembler** y **UpdateTaskProductQuantityCommandFromResourceAssembler**, extraen los valores de los registros DTO y construyen los comandos inmutables correspondientes, inyectando identificadores de ruta y del inquilino autenticado.

De forma complementaria, los ensambladores de salida traducen las raíces de agregado y entidades del dominio hacia representaciones DTO públicas. Componentes como **WorkOrderResourceAssembler**, **WorkOrderTaskResourceAssembler**, **TaskProposalResourceAssembler**, **WorkBayResourceAssembler** y **ServiceResourceAssembler** formatean los datos del negocio, mientras que **WorkOrderDetailResourceAssembler** integra tareas mecánicas, propuestas técnicas, repuestos demandados y evidencias fotográficas.

En la @tbl:mro-resource-assemblers se detallan los métodos y tipos de transformación ejecutados por estos ensambladores.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.1cm} | >{\raggedright\arraybackslash}p{10.3cm} |}
\caption{Ensambladores de Recursos del Bounded Context Workshop Operations (MRO)} \label{tbl:mro-resource-assemblers} \\
\hline
\thfirst{Aspecto del Ensamblador} & \thcell{Firma y Transformación de Tipos} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Ensamblador} & \thcell{Firma y Transformación de Tipos} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} CreateWorkOrderCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{CreateWorkOrderResource,\allowbreak  UUID} $\longrightarrow$ \texttt{CreateWorkOrderCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} AssignWorkBayCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{AssignWorkBayResource,\allowbreak  UUID} $\longrightarrow$ \texttt{AssignWorkBayCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} CreateWorkOrderTaskCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{CreateWorkOrderTaskResource,\allowbreak  UUID} $\longrightarrow$ \texttt{CreateWorkOrderTaskCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} AssignTaskMechanicCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{AssignTaskMechanicResource,\allowbreak  UUID,\allowbreak  UUID} $\longrightarrow$ \texttt{AssignTaskMechanicCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} HoldTaskCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{HoldTaskResource,\allowbreak  UUID,\allowbreak  UUID} $\longrightarrow$ \texttt{HoldTaskCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} ResumeTaskCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{UUID,\allowbreak  UUID} $\longrightarrow$ \texttt{ResumeTaskCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} CompleteWorkOrderTaskCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{CompleteTaskResource,\allowbreak  UUID,\allowbreak  UUID} $\longrightarrow$ \texttt{CompleteWorkOrderTaskCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} AddTaskProductCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{AddTaskProductResource,\allowbreak  UUID,\allowbreak  UUID} $\longrightarrow$ \texttt{AddTaskProductCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} UpdateTaskProductQuantityCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{UpdateTaskProductResource,\allowbreak  UUID,\allowbreak  UUID} $\longrightarrow$ \texttt{UpdateTaskProductQuantityCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} SubmitTaskProposalCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{SubmitTaskProposalResource,\allowbreak  UUID,\allowbreak  UUID} $\longrightarrow$ \texttt{SubmitTaskProposalCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} ApproveTaskProposalCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{ApproveTaskProposalResource,\allowbreak  UUID,\allowbreak  UUID,\allowbreak  UUID} $\longrightarrow$ \texttt{ApproveTaskProposalCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} RejectTaskProposalCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{RejectTaskProposalResource,\allowbreak  UUID,\allowbreak  UUID,\allowbreak  UUID} $\longrightarrow$ \texttt{RejectTaskProposalCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} AttachIntakeImageCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{AttachImageResource,\allowbreak  UUID} $\longrightarrow$ \texttt{AttachWorkOrderIntakeImageCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} AttachTaskEvidenceCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{AttachTaskEvidenceResource,\allowbreak  UUID,\allowbreak  UUID} $\longrightarrow$ \texttt{AttachTaskEvidenceCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} CancelWorkOrderCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{CancelWorkOrderResource,\allowbreak  UUID} $\longrightarrow$ \texttt{CancelWorkOrderCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} CreateWorkBayCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{CreateWorkBayResource,\allowbreak  UUID} $\longrightarrow$ \texttt{CreateWorkBayCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} CreateServiceCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{CreateServiceResource,\allowbreak  UUID} $\longrightarrow$ \texttt{CreateServiceItemCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} UpdateServiceCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{UpdateServiceResource,\allowbreak  UUID} $\longrightarrow$ \texttt{UpdateServiceItemCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} WorkOrderResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResourceFromAggregate} \\*
\hline
\textbf{Transformación} & \texttt{WorkOrder} $\longrightarrow$ \texttt{WorkOrderResource / WorkOrderSummaryResource / WorkOrderDetailResource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} WorkOrderTaskResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResourceFromEntity} \\*
\hline
\textbf{Transformación} & \texttt{WorkOrderTask} $\longrightarrow$ \texttt{WorkOrderTaskResource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} TaskProposalResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResourceFromEntity} \\*
\hline
\textbf{Transformación} & \texttt{TaskProposal} $\longrightarrow$ \texttt{TaskProposalResource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} WorkBayResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResourceFromEntity} \\*
\hline
\textbf{Transformación} & \texttt{WorkBay} $\longrightarrow$ \texttt{WorkBayResource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} ServiceResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResourceFromEntity} \\*
\hline
\textbf{Transformación} & \texttt{Service} $\longrightarrow$ \texttt{ServiceResource} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Clases ubicadas bajo el paquete com.andeva.atelier.platform.operations.interfaces.rest.transform.

**Fachada de Contexto Abierto (Open Host Service / Inbound ACL)**

Para preservar la pureza del modelo de dominio de Workshop Operations y evitar acoplamientos circulares con otros bounded contexts de la plataforma, la capa de interfaz implementa el patrón Open Host Service complementado con una Capa Anticorrupción de entrada.

Este patrón se materializa en la interfaz **WorkshopOperationsContextFacade**, ubicada en el paquete canónico **com.andeva.atelier.platform.operations.interfaces.acl**. Esta fachada define contratos públicos en memoria para que módulos consumidores como Invoicing, Inventory y CRM consulten el estado de órdenes, verifiquen repuestos consumidos para la liquidación fiscal o comprueben la disponibilidad física de una bahía sin acceder a entidades JPA.

La implementación **WorkshopOperationsContextFacadeImpl** delega estas consultas en los repositorios y servicios de aplicación de MRO, transformando los resultados en registros inmutables de frontera, tales como **WorkOrderSummaryDto**, **WorkOrderBillingDto**, **WorkOrderConsumedProductDto** y **WorkBaySummaryDto**, asegurando un aislamiento total entre contextos.

En la @tbl:mro-operations-facade se especifican los métodos y tipos de la fachada de contexto abierto.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Métodos de la Fachada de Contexto Abierto WorkshopOperationsContextFacade} \label{tbl:mro-operations-facade} \\
\hline
\thfirst{Aspecto del Contrato} & \thcell{Firma, Retorno y Consumidores} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Contrato} & \thcell{Firma, Retorno y Consumidores} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{fetchWorkOrderById}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID workOrderId} $\longrightarrow$ \texttt{Optional<\allowbreak WorkOrderSummaryDto>\allowbreak } \\*
\hline
\textbf{Módulos Consumidores} & Invoicing (Facturación electrónica), CRM, Atelier Driver (App móvil) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{fetchWorkOrderBillingDetails}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID workOrderId} $\longrightarrow$ \texttt{Optional<\allowbreak WorkOrderBillingDto>\allowbreak } \\*
\hline
\textbf{Módulos Consumidores} & Invoicing (Liquidación de comprobante y cálculo de impuestos SUNAT) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{fetchProductsConsumedInOrder}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID workOrderId} $\longrightarrow$ \texttt{List<\allowbreak WorkOrderConsumedProductDto>\allowbreak } \\*
\hline
\textbf{Módulos Consumidores} & Invoicing (Desglose de repuestos en comprobante), Inventory (Auditoría de salidas FIFO) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{markWorkOrderAsPaid}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID workOrderId} $\longrightarrow$ \texttt{boolean} \\*
\hline
\textbf{Módulos Consumidores} & Invoicing (Conciliación automática tras cobro de factura) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{isBayOccupied}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID bayId} $\longrightarrow$ \texttt{boolean} \\*
\hline
\textbf{Módulos Consumidores} & Workshop Operations (Validación concurrente de asignación), CRM (Planificación de citas) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{fetchBayStatus}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID bayId} $\longrightarrow$ \texttt{Optional<\allowbreak WorkBaySummaryDto>\allowbreak } \\*
\hline
\textbf{Módulos Consumidores} & CRM (Disponibilidad de bahías para citas), Monitor de Taller Web \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al paquete com.andeva.atelier.platform.operations.interfaces.acl.

**Eventos de Integración (Published Language)**

Para la sincronización asíncrona intermodular sin incurrir en consistencia transaccional inmediata ni bloqueos de concurrencia, el Bounded Context Workshop Operations define un lenguaje publicado compuesto por once eventos de integración inmutables.

Dichos eventos notifican hitos relevantes del ciclo de vida productivo. Por un lado, **WorkOrderCreatedIntegrationEvent** y **WorkOrderStartedIntegrationEvent** mantienen informado al conductor a través de la aplicación móvil. Por otro lado, **WorkBayAssignedIntegrationEvent**, **WorkOrderTaskAssignedIntegrationEvent**, **WorkOrderTaskHoldIntegrationEvent** y **WorkOrderTaskResumedIntegrationEvent** coordinan la trazabilidad física, la asignación a técnicos y las alertas de desabastecimiento en patio. Asimismo, **ProductStockReservationRequestedIntegrationEvent** y **ProductStockReservationCancelledIntegrationEvent** coordinan la reserva y reversión de inventario bajo costeo FIFO, mientras que **WorkOrderCompletedIntegrationEvent** gatilla la proforma tributaria en Facturación Electrónica.

En la @tbl:mro-integration-events se sintetiza la estructura de estos eventos de integración.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Eventos de Integración del Bounded Context Workshop Operations (MRO)} \label{tbl:mro-integration-events} \\
\hline
\thfirst{Aspecto de Integración} & \thcell{Carga Útil y Sincronización Intermodular} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Integración} & \thcell{Carga Útil y Sincronización Intermodular} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} WorkOrderCreatedIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{tenantId}, \texttt{vehicleId}, \texttt{internalNumber}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & CRM, Atelier Driver \\*
\hline
\textbf{Propósito} & Notificación al conductor sobre recepción física vehicular y apertura de expediente técnico. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} WorkBayAssignedIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{tenantId}, \texttt{bayId}, \texttt{bayName}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Monitor de Taller, CRM \\*
\hline
\textbf{Propósito} & Actualización de ocupación en planta y trazabilidad física del automóvil. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} WorkOrderTaskAssignedIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{taskId}, \texttt{mechanicId}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Atelier Mobile Workshop, Dispositivo del Técnico \\*
\hline
\textbf{Propósito} & Notificación push al dispositivo móvil del técnico sobre nueva intervención técnica asignada. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} WorkOrderTaskHoldIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{taskId}, \texttt{reason}, \texttt{missingItemDescription}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Inventory \& Supply Chain, CRM, Portal Web del Asesor \\*
\hline
\textbf{Propósito} & Alerta operativa sobre pausa en foso por repuestos faltantes para acelerar el suministro logístico. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} WorkOrderTaskResumedIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{taskId}, \texttt{pausedDurationSeconds}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Monitor de Taller, Control de Tiempos \\*
\hline
\textbf{Propósito} & Notificación de reactivación de faena en foso tras la provisión de partes requeridas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} WorkOrderStartedIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{tenantId}, \texttt{vehicleId}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Atelier Driver, IoT Telemetry \\*
\hline
\textbf{Propósito} & Notificación de inicio de trabajos en foso e inhibición temporal de alertas telemétricas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} ProductStockReservationRequestedIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{taskId}, \texttt{productId}, \texttt{quantity}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Inventory \& Supply Chain \\*
\hline
\textbf{Propósito} & Demanda formal de repuestos con reserva física y cálculo de costo bajo método FIFO. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} ProductStockReservationCancelledIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{taskId}, \texttt{productId}, \texttt{quantity}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Inventory \& Supply Chain \\*
\hline
\textbf{Propósito} & Reversión inmediata de reservas de stock ante rectificación o eliminación de tarea técnica. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} WorkOrderCompletedIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{tenantId}, \texttt{vehicleId}, \texttt{totalAmount}, \texttt{currency}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Invoicing \& Fiscal Compliance \\*
\hline
\textbf{Propósito} & Notificación de culminación mecánica para liquidación tributaria y emisión de factura o boleta SUNAT. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} WorkOrderPaidIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{tenantId}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Atelier Driver, Portería de Taller \\*
\hline
\textbf{Propósito} & Habilitación formal de entrega del automóvil tras conciliación exitosa del pago. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} WorkOrderDeliveredIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{workOrderId}, \texttt{tenantId}, \texttt{vehicleId}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & CRM, Atelier Driver \\*
\hline
\textbf{Propósito} & Registro de salida vehicular del establecimiento e incorporación al historial mecánico del cliente. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Registros inmutables pertenecientes al paquete com.andeva.atelier.platform.operations.interfaces.events.

El diseño arquitectónico de la Capa de Interfaz de Workshop Operations manifiesta tres decisiones fundamentales de ingeniería de software que fortalecen la escalabilidad y mantenibilidad del sistema:

En primer lugar, la rigurosa segregación perimetral y el modelado RESTful orientado a recursos garantizan una exposición limpia y predecible. La adopción de enrutamiento superficial (*Shallow Routing*) para las tareas de taller desacopla la ejecución atómica en foso respecto a la apertura macro de la orden, preservando rutas canónicas de dos niveles de profundidad. Asimismo, el circuito pericial de propuestas técnicas canaliza los hallazgos imprevistos detectados por mecánicos hacia el Asesor de Servicio, quien asume el rol educativo y comercial frente al propietario del vehículo antes de formalizar cualquier labor adicional.

En segundo término, la estrategia de desacoplamiento multimedia Direct-to-Cloud proporciona una alta eficiencia operacional frente a la concurrencia física del taller. Al delegar la recepción y almacenamiento de archivos binarios pesados en Firebase Cloud Storage y transportar únicamente localizadores HTTPS inmutables en los contratos JSON, se eliminan los cuellos de botella de memoria y ancho de banda en el servidor central de Spring Boot.

Por último, el desacoplamiento intermodular sustentado en la fachada de contexto abierto y el lenguaje publicado de eventos asegura una interoperabilidad fluida con Inventario y Facturación Electrónica. El empleo del patrón Transactional Outbox garantiza que la reserva de insumos bajo costeo FIFO durante la ejecución y la deducción definitiva al conciliar el pago se ejecuten sin contención de bases de datos compartidas ni transacciones distribuidas complejas.

#### 2.6.4.3. Application Layer

La Capa de Aplicación de Workshop Operations (MRO) constituye el motor orquestador de los procesos de negocio técnicos en Atelier Platform, coordinando el flujo integral de mantenimiento y reparación vehicular desde el arribo a recepción hasta la entrega formal al cliente.

Ubicada en el paquete canónico com.andeva.atelier.platform.operations.application, su diseño arquitectónico adopta una segregación rigurosa bajo el patrón CQRS, desacoplando las operaciones mutacionales de escritura de las proyecciones de solo lectura a través de cuatro directrices esenciales de diseño:

- **Orquestación Transaccional Atómica:** Delimitación de fronteras de consistencia transaccional mediante la anotación de servicio transaccional con nivel de aislamiento de lectura confirmada. Esta disciplina asegura atomicidad estricta entre la orden de trabajo y la bahía física ocupada, evitando colisiones operativas en planta, sincronizando el ciclo de vida de labores mecánicas y recalculando el importe liquidado bajo precisión fija y redondeo bancario.

- **Flujo Determinista sin Excepciones:** Adopción del tipo de resultado sellado **Result<T, ApplicationError>** para gobernar las respuestas de los casos de uso. Las condiciones de fallo previsibles vinculadas a indisponibilidad de elevadores, violaciones de estado operativo o desabastecimiento de piezas se tratan como valores inmutables de retorno, imponiendo verificación exhaustiva mediante coincidencia de patrones.

- **Coreografía de Eventos de Dominio e Integración:** Manejo dual de eventos mediante oyentes locales para efectos colaterales sincrónicos y oyentes posteriores a la confirmación transaccional para la propagación de eventos hacia el Transactional Outbox, asegurando consistencia eventual con los módulos de inventario, facturación electrónica y telemetría sin acoplamiento temporal.

- **Inversión de Dependencias y Aislamiento Perimetral:** Abstracción de servicios de infraestructura y contextos limítrofes mediante puertos de salida específicos para la verificación de vehículos y clientes en CRM, validación de membresías de mecánicos en IAM, reserva física por lotes FIFO en almacén y validación criptográfica de evidencias fotográficas en Firebase Cloud Storage.

A fin de ofrecer una visión sistemática de estos componentes, en la @tbl:mro-application-types se presenta el catálogo consolidado de las clases, interfaces y registros que estructuran la Capa de Aplicación de Workshop Operations (MRO).

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo Consolidado de la Capa de Aplicación de Workshop Operations (MRO)} \label{tbl:mro-application-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endhead
WorkOrder\allowbreak Command\allowbreak Service & Contrato de casos de uso de escritura para órdenes de trabajo, labores técnicas y peritajes. \\*
\hline
\textbf{Categoría} & Servicio de Comando \\*
\hline
\textbf{Relaciones} & Implementado por WorkOrderCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
WorkOrder\allowbreak Command\allowbreak ServiceImpl & Orquesta el ciclo de vida de órdenes, bahías, tareas en foso, propuestas y reservas FIFO. \\*
\hline
\textbf{Categoría} & Implementación de Comando \\*
\hline
\textbf{Relaciones} & Coordina agregados WorkOrder, WorkBay y repositorios con persistencia ACID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
WorkBay\allowbreak Command\allowbreak Service & Contrato para alta física y control operacional de bahías y elevadores de taller. \\*
\hline
\textbf{Categoría} & Servicio de Comando \\*
\hline
\textbf{Relaciones} & Implementado por WorkBayCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
WorkBay\allowbreak Command\allowbreak ServiceImpl & Gestiona la incorporación de bahías y conmutaciones a mantenimiento o disponibilidad. \\*
\hline
\textbf{Categoría} & Implementación de Comando \\*
\hline
\textbf{Relaciones} & Coordina agregado WorkBay con repositorios. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Service\allowbreak Command\allowbreak Service & Contrato de catálogo maestro de tarifas y horas estándar de mano de obra. \\*
\hline
\textbf{Categoría} & Servicio de Comando \\*
\hline
\textbf{Relaciones} & Implementado por ServiceCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Service\allowbreak Command\allowbreak ServiceImpl & Administra altas, actualizaciones tarifarias y desactivaciones del catálogo de servicios. \\*
\hline
\textbf{Categoría} & Implementación de Comando \\*
\hline
\textbf{Relaciones} & Coordina entidad Service con repositorios. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
WorkOrder\allowbreak Query\allowbreak Service & Contrato de operaciones de consulta de solo lectura sobre órdenes, tareas y propuestas. \\*
\hline
\textbf{Categoría} & Servicio de Consulta \\*
\hline
\textbf{Relaciones} & Implementado por WorkOrderQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
WorkOrder\allowbreak Query\allowbreak ServiceImpl & Ejecuta proyecciones optimizadas de órdenes por sede, estado, vehículo y labores por mecánico. \\*
\hline
\textbf{Categoría} & Implementación de Consulta \\*
\hline
\textbf{Relaciones} & Consulta repositorios bajo aislamiento de solo lectura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
WorkBay\allowbreak Query\allowbreak Service & Contrato de consulta física y disponibilidad en tiempo real de bahías de trabajo. \\*
\hline
\textbf{Categoría} & Servicio de Consulta \\*
\hline
\textbf{Relaciones} & Implementado por WorkBayQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
WorkBay\allowbreak Query\allowbreak ServiceImpl & Proyecta bahías por sede y consulta disponibilidad para asignación inmediata. \\*
\hline
\textbf{Categoría} & Implementación de Consulta \\*
\hline
\textbf{Relaciones} & Consulta WorkBayRepository bajo aislamiento de solo lectura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Service\allowbreak Query\allowbreak Service & Contrato de consulta del catálogo de servicios de mano de obra del taller. \\*
\hline
\textbf{Categoría} & Servicio de Consulta \\*
\hline
\textbf{Relaciones} & Implementado por ServiceQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Service\allowbreak Query\allowbreak ServiceImpl & Proyecta servicios de mano de obra activos y búsqueda individual por identificador. \\*
\hline
\textbf{Categoría} & Implementación de Consulta \\*
\hline
\textbf{Relaciones} & Consulta ServiceRepository bajo aislamiento de solo lectura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
WorkOrder\allowbreak Domain\allowbreak Events\allowbreak Handler & Manejador de eventos de dominio emitidos por la raíz de agregado WorkOrder. \\*
\hline
\textbf{Categoría} & Manejador de Eventos \\*
\hline
\textbf{Relaciones} & Transforma y deposita eventos de integración en el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak application.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
WorkOrder\allowbreak Task\allowbreak Domain\allowbreak Events\allowbreak Handler & Manejador de eventos de labores en foso, pausas técnicas y demanda de repuestos. \\*
\hline
\textbf{Categoría} & Manejador de Eventos \\*
\hline
\textbf{Relaciones} & Despacha alertas a mecánicos, almacén y publica reservas FIFO en Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak application.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Workshop\allowbreak External\allowbreak Events\allowbreak Listener & Suscriptor de eventos de integración emitidos por CRM y Facturación Electrónica. \\*
\hline
\textbf{Categoría} & Oyente de Eventos Externos \\*
\hline
\textbf{Relaciones} & Desencadena apertura automática de órdenes y conciliación de pago. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak application.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Customer\allowbreak Fleet\allowbreak Acl\allowbreak Service & Puerto de salida perimetral para validación de clientes y vehículos con CRM. \\*
\hline
\textbf{Categoría} & Puerto de Salida ACL \\*
\hline
\textbf{Relaciones} & Implementado por CustomerFleetAclAdapter mediante CustomerFleetContextFacade. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak application.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Tenancy\allowbreak Acl\allowbreak Service & Puerto de salida perimetral para validación de mecánicos y sedes físicas con IAM. \\*
\hline
\textbf{Categoría} & Puerto de Salida ACL \\*
\hline
\textbf{Relaciones} & Implementado por TenancyAclAdapter mediante TenancyContextFacade. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak application.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Inventory\allowbreak Reservation\allowbreak Acl\allowbreak Service & Puerto de salida perimetral para coordinación de reservas FIFO con Inventario. \\*
\hline
\textbf{Categoría} & Puerto de Salida ACL \\*
\hline
\textbf{Relaciones} & Implementado por InventoryReservationAclAdapter. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak application.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Direct\allowbreak To\allowbreak Cloud\allowbreak Storage\allowbreak Gateway & Puerto de salida para validación de firmas y localizadores en Firebase Cloud Storage. \\*
\hline
\textbf{Categoría} & Puerto de Salida Gateway \\*
\hline
\textbf{Relaciones} & Implementado por FirebaseStorageDirectUploadGateway. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak application.\allowbreak acl} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Estructura modular del paquete com.andeva.atelier.platform.operations.application.

**Servicios de Comandos y Orquestación Transaccional**

La ejecución de casos de uso de escritura y la coordinación mutacional del taller se centralizan en tres implementaciones de servicios de comandos delimitadas por agregados.

El componente **WorkOrderCommandServiceImpl** gobierna el flujo transaccional del agregado principal de la orden de servicio. Al procesar **CreateWorkOrderCommand**, consulta el contexto CRM para validar la existencia del vehículo y la cita asociada, genera el identificador formal correlativo e inicializa la orden en estado borrador.

Asimismo, orquesta la asignación y liberación atómica de bahías técnicas (**AssignWorkBayCommand**, **ReleaseWorkBayCommand**), garantizando que ningún vehículo ingrese a un elevador o foso que no se encuentre en disponibilidad operativa.

En el ámbito de las intervenciones mecánicas, administra la planificación de labores autorizadas (**AddTaskToWorkOrderCommand**) y la asignación técnica de especialistas (**AssignTaskMechanicCommand**), emitiendo alertas inmediatas hacia la aplicación móvil de los técnicos. Cuando el operario inicia la reparación (**StartWorkOrderTaskCommand**), promueve concurrentemente el estado de la tarea y de la orden a progreso activo.

Ante la carencia de repuestos en almacén, ejecuta **HoldWorkOrderTaskCommand**, conmutando la tarea a estado en pausa con causa objetiva de desabastecimiento, congelando el cómputo de horas hombre efectivas para preservar la exactitud del rendimiento técnico y alertando al área logística. Una vez abastecido el insumo, **ResumeWorkOrderTaskCommand** reactiva la labor acumulando el tiempo pausado, mientras que **CompleteWorkOrderTaskCommand** registra las horas reales y evalúa si todas las labores finalizaron para cerrar la orden macro.

Adicionalmente, coordina la demanda de insumos (**AddTaskProductCommand**, **RemoveProductFromTaskCommand**) emitiendo solicitudes de reserva por lotes FIFO hacia inventario, y gestiona el circuito pericial de hallazgos imprevistos en foso (**SubmitTaskProposalCommand**, **ApproveTaskProposalCommand**, **RejectTaskProposalCommand**).

Finalmente, procesa el registro pericial de fotografías de recepción y evidencias técnicas (**AttachWorkOrderIntakeImageCommand**, **AttachTaskEvidenceCommand**), la conciliación contable de pago (**MarkWorkOrderAsPaidCommand**) que instruye la deducción definitiva de existencias en almacén y la liberación de la bahía, la entrega al conductor (**DeliverWorkOrderCommand**) y la cancelación justificada (**CancelWorkOrderCommand**).

Por su parte, **WorkBayCommandServiceImpl** administra la infraestructura física del taller mediante **CreateWorkBayCommand**, validando la pertenencia a una sede activa en IAM, y gobierna los cambios de estado operativo (**SetBayMaintenanceCommand**, **RestoreBayAvailableCommand**). Por último, **ServiceCommandServiceImpl** custodia el tarifario estándar del taller (**CreateServiceItemCommand**, **UpdateServiceItemCommand**, **DeactivateServiceItemCommand**), asegurando la validez de precios base y tiempos estándar de mano de obra.

Para sintetizar los flujos mutacionales, en la @tbl:mro-command-services se detallan las operaciones, comandos de entrada, invariantes de consistencia transaccional y tipos de retorno de los servicios de comandos.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Operaciones Transaccionales de los Servicios de Comandos de Workshop Operations (MRO)} \label{tbl:mro-command-services} \\
\hline
\thfirst{Aspecto de Operación} & \thcell{Especificación de Orquestación y Consistencia} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Operación} & \thcell{Especificación de Orquestación y Consistencia} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{CreateWorkOrderCommand} $\longrightarrow$ \texttt{Result<\allowbreak WorkOrder,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida vehículo y cliente en CRM. Asigna número correlativo secuencial e inicializa orden en estado DRAFT con kilometraje y diagnóstico de ingreso. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{AssignWorkBayCommand} $\longrightarrow$ \texttt{Result<\allowbreak WorkOrder,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Verifica disponibilidad física de la bahía y ejecuta ocupación atómica vinculando la orden con el elevador o foso correspondiente. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{ReleaseWorkBayCommand} $\longrightarrow$ \texttt{Result<\allowbreak WorkOrder,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Libera la bahía física ocupada desvinculándola de la orden de trabajo para habilitar su disponibilidad operativa. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{AddTaskToWorkOrderCommand} $\longrightarrow$ \texttt{Result<\allowbreak WorkOrder,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida servicio en catálogo. Si especifica técnico verifica membresía en IAM asignando estado ASSIGNED o en caso contrario PENDING. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{AssignTaskMechanicCommand} $\longrightarrow$ \texttt{Result<\allowbreak WorkOrder,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Asigna o reasigna técnico mecánico responsable a una labor técnica transicionándola a ASSIGNED y emitiendo alerta móvil. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{StartWorkOrderTaskCommand} $\longrightarrow$ \texttt{Result<\allowbreak WorkOrder,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & El técnico inicia la labor en foso pasando la tarea a IN\_PROGRESS y promoviendo el estado macro de la orden a IN\_PROGRESS. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{HoldWorkOrderTaskCommand} $\longrightarrow$ \texttt{Result<\allowbreak WorkOrder,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Pausa la labor por falta de repuestos pasando a ON\_HOLD con causa WAITING\_PARTS congelando el cómputo de horas activas y alertando a almacén. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{ResumeWorkOrderTaskCommand} $\longrightarrow$ \texttt{Result<\allowbreak WorkOrder,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Reanuda la labor técnica tras suministro de insumos acumulando el tiempo en pausa y retornando la tarea a IN\_PROGRESS. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{CompleteWorkOrderTaskCommand} $\longrightarrow$ \texttt{Result<\allowbreak WorkOrder,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Registra horas hombre reales y marca la labor COMPLETED. Si todas las tareas finalizaron cierra automáticamente la orden a COMPLETED. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{AddTaskProductCommand} $\longrightarrow$ \texttt{Result<\allowbreak WorkOrder,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Añade repuesto o insumo consumido a la labor técnica recalculando el monto total y solicitando reserva FIFO a Inventario. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{UpdateTaskProductQuantityCommand} $\longrightarrow$ \texttt{Result<\allowbreak WorkOrder,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Modifica la cantidad consumida de repuesto recalculando el importe total y ajustando la reserva por lotes en Inventario. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{RemoveProductFromTaskCommand} $\longrightarrow$ \texttt{Result<\allowbreak WorkOrder,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Elimina el repuesto de la labor técnica deduciendo su costo del total de la orden y cancelando la reserva física en Inventario. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{SubmitTaskProposalCommand} $\longrightarrow$ \texttt{Result<\allowbreak TaskProposal,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Mecánico en foso reporta hallazgo imprevisto con fotografía y severidad sin cotización económica preliminar para arbitraje de asesor. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{ApproveTaskProposalCommand} $\longrightarrow$ \texttt{Result<\allowbreak WorkOrderTask,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Asesor pacta presupuesto y mano de obra con cliente aprobando el hallazgo e instanciando una nueva labor técnica en ASSIGNED. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{RejectTaskProposalCommand} $\longrightarrow$ \texttt{Result<\allowbreak TaskProposal,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Registra la desestimación formal del cliente archivando el hallazgo pericial como antecedente en la historia clínica vehicular. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{AttachWorkOrderIntakeImageCommand} $\longrightarrow$ \texttt{Result<\allowbreak WorkOrder,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida URL de Firebase Storage y registra metadata pericial de inspección fotográfica al recibir el vehículo en taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{AttachTaskEvidenceCommand} $\longrightarrow$ \texttt{Result<\allowbreak WorkOrderTask,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Registra metadata y evidencia fotográfica del procedimiento de reparación en foso validando almacenamiento Direct-to-Cloud. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{CompleteWorkOrderCommand} $\longrightarrow$ \texttt{Result<\allowbreak WorkOrder,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Cierre técnico formal de la orden constatando que todas las labores mecánicas asociadas alcanzaron estado COMPLETED. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{MarkWorkOrderAsPaidCommand} $\longrightarrow$ \texttt{Result<\allowbreak WorkOrder,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Concilia el pago económico de la orden pasando a PAID liberando la bahía física e instruyendo deducción definitiva FIFO en inventario. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{DeliverWorkOrderCommand} $\longrightarrow$ \texttt{Result<\allowbreak WorkOrder,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Registra el retiro físico y entrega del vehículo al cliente emitiendo evento de integración para historial de mantenimiento en CRM. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{CancelWorkOrderCommand} $\longrightarrow$ \texttt{Result<\allowbreak WorkOrder,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Anulación justificada de la orden liberando la bahía asignada y revirtiendo todas las reservas de repuestos en Inventario. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkBayCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{CreateWorkBayCommand} $\longrightarrow$ \texttt{Result<\allowbreak WorkBay,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida existencia de sede física en IAM y da de alta una nueva bahía técnica elevador o foso en estado AVAILABLE. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkBayCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{UpdateWorkBayStatusCommand} $\longrightarrow$ \texttt{Result<\allowbreak WorkBay,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Actualiza el estado operativo general de la bahía física para supervisión y monitoreo de planta. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkBayCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{SetBayMaintenanceCommand} $\longrightarrow$ \texttt{Result<\allowbreak WorkBay,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Conmuta la bahía técnica al estado MAINTENANCE inhabilitando temporalmente la asignación de nuevas órdenes de trabajo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkBayCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{RestoreBayAvailableCommand} $\longrightarrow$ \texttt{Result<\allowbreak WorkBay,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Restablece la bahía física concluido su mantenimiento preventivo dejándola en estado AVAILABLE para operaciones activas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} ServiceCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{CreateServiceItemCommand} $\longrightarrow$ \texttt{Result<\allowbreak Service,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Registra un nuevo servicio de mano de obra en el catálogo maestro del taller con tarifa base y tiempo estándar de ejecución. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} ServiceCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{UpdateServiceItemCommand} $\longrightarrow$ \texttt{Result<\allowbreak Service,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Actualiza especificaciones técnicas importe base o duración estimada de un servicio de catálogo preexistente. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} ServiceCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{DeactivateServiceItemCommand} $\longrightarrow$ \texttt{Result<\allowbreak Service,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Deshabilita un servicio de mano de obra del catálogo del taller previniendo su asignación en órdenes de trabajo futuras. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Clases ubicadas bajo el paquete com.andeva.atelier.platform.operations.application.services.

**Servicios de Consulta y Proyecciones de Lectura**

La recuperación de información y la alimentación de interfaces de usuario se estructuran mediante servicios de consulta especializados configurados bajo aislamiento de solo lectura, suprimiendo la sobrecarga de seguimiento de cambios en el motor de persistencia.

El componente **WorkOrderQueryServiceImpl** atiende las consultas operativas del taller mediante proyecciones optimizadas. Provee la recuperación exhaustiva de expedientes individuales (**GetWorkOrderByIdQuery**), listados globales de órdenes por empresa (**GetWorkOrdersByTenantQuery**), filtros por sucursal física (**GetWorkOrdersByBranchQuery**) y tableros de supervisión por estado operacional (**GetWorkOrdersByStatusQuery**).

Asimismo, expone consultas históricas orientadas a vehículos (**GetWorkOrdersByVehicleQuery**) y clientes (**GetWorkOrdersByCustomerQuery**), además de posibilitar el acceso desacoplado a tareas individuales (**GetTaskByIdQuery**), labores por orden (**GetTasksByWorkOrderQuery**), asignaciones por mecánico (**GetTasksByMechanicQuery**) y el catálogo de propuestas periciales (**GetProposalsByWorkOrderQuery**).

Complementariamente, **WorkBayQueryServiceImpl** gestiona las consultas de infraestructura física, recuperando el detalle y estado de una bahía específica (**GetWorkBayByIdQuery**), el inventario completo de puestos de una sede (**GetWorkBaysByBranchQuery**) y la disponibilidad en tiempo real de bahías desocupadas (**GetAvailableWorkBaysQuery**). Por último, **ServiceQueryServiceImpl** canaliza las consultas sobre el catálogo de mano de obra del taller (**GetServiceByIdQuery**, **GetServicesByTenantQuery**), habilitando la selección rápida de tarifas vigentes en los formularios de recepción.

Con el propósito de consolidar estos contratos de lectura, en la @tbl:mro-query-services se presentan las firmas de los métodos de consulta, sus parámetros y los modelos inmutables proyectados por los servicios de consulta.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Métodos de Consulta de la Capa de Aplicación de Workshop Operations (MRO)} \label{tbl:mro-query-services} \\
\hline
\thfirst{Aspecto de Consulta} & \thcell{Especificación Técnica y Recuperación} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Consulta} & \thcell{Especificación Técnica y Recuperación} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetWorkOrderByIdQuery} $\longrightarrow$ \texttt{Optional<\allowbreak WorkOrder>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Consulta integral de expediente de orden de trabajo por identificador UUID dentro del taller autenticado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetWorkOrdersByTenantQuery} $\longrightarrow$ \texttt{List<\allowbreak WorkOrder>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Listado global paginado de órdenes de trabajo asociadas a la empresa automotriz. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetWorkOrdersByBranchQuery} $\longrightarrow$ \texttt{List<\allowbreak WorkOrder>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Listado de órdenes operativas adscritas a una sede física de taller con filtrado por estado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetWorkOrdersByStatusQuery} $\longrightarrow$ \texttt{List<\allowbreak WorkOrder>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Recuperación de órdenes en un estado operacional específico para tableros kanban de supervisión. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetWorkOrdersByVehicleQuery} $\longrightarrow$ \texttt{List<\allowbreak WorkOrder>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Historial cronológico de órdenes de servicio acumuladas sobre un vehículo automotor universal. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetWorkOrdersByCustomerQuery} $\longrightarrow$ \texttt{List<\allowbreak WorkOrder>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Órdenes de mantenimiento contratadas por un cliente particular o empresa de flota. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetTaskByIdQuery} $\longrightarrow$ \texttt{Optional<\allowbreak WorkOrderTask>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Consulta técnica individual de labor en foso mediante shallow routing sin sobrecarga de agregados padre. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetTasksByWorkOrderQuery} $\longrightarrow$ \texttt{List<\allowbreak WorkOrderTask>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Conjunto de intervenciones mecánicas mano de obra y repuestos demandados en una orden específica. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetTasksByMechanicQuery} $\longrightarrow$ \texttt{List<\allowbreak WorkOrderTask>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Labores mecánicas asignadas a un técnico específico para gestión de carga laboral y terminal móvil. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkOrderQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetProposalsByWorkOrderQuery} $\longrightarrow$ \texttt{List<\allowbreak TaskProposal>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Catálogo de hallazgos periciales y averías imprevistas registradas por técnicos en una orden. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkBayQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetWorkBayByIdQuery} $\longrightarrow$ \texttt{Optional<\allowbreak WorkBay>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Consulta de especificaciones físicas estado y orden asociada de una bahía técnica por ID. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkBayQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetWorkBaysByBranchQuery} $\longrightarrow$ \texttt{List<\allowbreak WorkBay>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Inventario completo de bahías elevadores fosos y cabinas registradas en una sucursal física. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} WorkBayQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetAvailableWorkBaysQuery} $\longrightarrow$ \texttt{List<\allowbreak WorkBay>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Bahías desocupadas en estado AVAILABLE filtradas opcionalmente por tipo de equipamiento físico. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} ServiceQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetServiceByIdQuery} $\longrightarrow$ \texttt{Optional<\allowbreak Service>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Consulta técnica de una prestación de mano de obra del catálogo maestro del taller por identificador. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} ServiceQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetServicesByTenantQuery} $\longrightarrow$ \texttt{List<\allowbreak Service>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Catálogo completo de servicios vigentes configurados para el taller mecánico con tarifas y tiempos. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Clases ubicadas bajo el paquete com.andeva.atelier.platform.operations.application.services.

**Manejadores de Eventos de Dominio y Publicación Asíncrona**

La arquitectura reactiva del Bounded Context se implementa mediante manejadores de eventos desacoplados que diferencian las acciones colaterales sincrónicas inmediatas de las propagaciones asíncronas intermodulares.

El manejador **WorkOrderDomainEventsHandler** procesa los eventos emanados por la raíz de agregado de órdenes de trabajo. Mediante oyentes posteriores a la confirmación de la transacción, construye los eventos de integración inmutables (**WorkOrderCreatedIntegrationEvent**, **WorkBayAssignedIntegrationEvent**, **WorkOrderStartedIntegrationEvent**, **WorkOrderCompletedIntegrationEvent**, **WorkOrderPaidIntegrationEvent**, **WorkOrderDeliveredIntegrationEvent**, **WorkOrderCancelledIntegrationEvent**) y los deposita en la tabla del Transactional Outbox, garantizando entrega confiable hacia los módulos de facturación, telemetría y fidelización de clientes.

Asimismo, **WorkOrderTaskDomainEventsHandler** administra los eventos asociados a las tareas técnicas en foso. Mediante oyentes locales sincrónicos, despacha notificaciones push inmediatas a los terminales móviles de los mecánicos ante asignaciones (**WorkOrderTaskAssignedEvent**), remite alertas prioritarias al asesor y al almacén ante detenciones por falta de repuestos (**WorkOrderTaskHoldEvent**), notifica reanudaciones (**WorkOrderTaskResumedEvent**) y evalúa la auto-completitud de la orden macro al finalizar una tarea (**WorkOrderTaskCompletedEvent**).

En paralelo, sus oyentes posteriores a la confirmación transaccional publican eventos de demanda (**ProductStockReservationRequestedIntegrationEvent**) y cancelación de repuestos (**ProductStockReservationCancelledIntegrationEvent**) hacia el motor de inventario FIFO.

Por último, **WorkshopExternalEventsListener** captura los eventos de integración emitidos por otros contextos delimitados. Al recepcionar el arribo físico del vehículo desde CRM (**AppointmentArrivedIntegrationEvent**), invoca automáticamente la apertura del borrador de la orden de trabajo en recepción. De igual forma, al recibir la confirmación de pago desde Facturación Electrónica (**PaymentProcessedIntegrationEvent**), desencadena la conciliación formal de la orden, consolidando la deducción contable definitiva de inventario y liberando la bahía técnica.

A fin de resumir la arquitectura de eventos, en la @tbl:mro-event-handlers se especifican las responsabilidades, fases transaccionales y destinos de los manejadores de eventos de la capa.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Manejadores de Eventos de Dominio de Workshop Operations (MRO)} \label{tbl:mro-event-handlers} \\
\hline
\thfirst{Aspecto del Manejador} & \thcell{Orquestación y Efecto Colateral} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Manejador} & \thcell{Orquestación y Efecto Colateral} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} WorkOrderDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{WorkOrderCreatedEvent} \quad (\textit{Fase:} Posterior a confirmación) \\*
\hline
\textbf{Acción Orquestada} & Publica WorkOrderCreatedIntegrationEvent al Outbox para alertar al cliente del ingreso del auto a taller. \\*
\hline
\textbf{Destino del Efecto} & Transactional Outbox / Event Bus \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} WorkOrderDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{WorkBayAssignedEvent} \quad (\textit{Fase:} Posterior a confirmación) \\*
\hline
\textbf{Acción Orquestada} & Publica WorkBayAssignedIntegrationEvent para telemetría y monitorización de ocupación en planta. \\*
\hline
\textbf{Destino del Efecto} & Transactional Outbox / Event Bus \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} WorkOrderDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{WorkOrderStartedEvent} \quad (\textit{Fase:} Posterior a confirmación) \\*
\hline
\textbf{Acción Orquestada} & Publica WorkOrderStartedIntegrationEvent notificando el inicio formal de labores mecánicas activas. \\*
\hline
\textbf{Destino del Efecto} & Transactional Outbox / Event Bus \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} WorkOrderDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{WorkOrderCompletedEvent} \quad (\textit{Fase:} Posterior a confirmación) \\*
\hline
\textbf{Acción Orquestada} & Publica WorkOrderCompletedIntegrationEvent para que Facturación proceda a preparar comprobantes SUNAT. \\*
\hline
\textbf{Destino del Efecto} & Transactional Outbox / Event Bus \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} WorkOrderDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{WorkOrderPaidEvent} \quad (\textit{Fase:} Posterior a confirmación) \\*
\hline
\textbf{Acción Orquestada} & Publica WorkOrderPaidIntegrationEvent instruyendo deducción contable FIFO definitiva en Inventario. \\*
\hline
\textbf{Destino del Efecto} & Transactional Outbox / Event Bus \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} WorkOrderDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{WorkOrderDeliveredEvent} \quad (\textit{Fase:} Posterior a confirmación) \\*
\hline
\textbf{Acción Orquestada} & Publica WorkOrderDeliveredIntegrationEvent actualizando el expediente clínico vehicular en CRM. \\*
\hline
\textbf{Destino del Efecto} & Transactional Outbox / Event Bus \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} WorkOrderDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{WorkOrderCancelledEvent} \quad (\textit{Fase:} Posterior a confirmación) \\*
\hline
\textbf{Acción Orquestada} & Publica WorkOrderCancelledIntegrationEvent para revertir reservas de repuestos y desocupar bahías. \\*
\hline
\textbf{Destino del Efecto} & Transactional Outbox / Event Bus \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} WorkOrderTaskDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{WorkOrderTaskAssignedEvent} \quad (\textit{Fase:} Inmediata) \\*
\hline
\textbf{Acción Orquestada} & Emite notificación push en tiempo real hacia la aplicación móvil de taller del mecánico asignado. \\*
\hline
\textbf{Destino del Efecto} & MechanicAppPushGateway / FCM \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} WorkOrderTaskDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{WorkOrderTaskHoldEvent} \quad (\textit{Fase:} Inmediata y posterior a confirmación) \\*
\hline
\textbf{Acción Orquestada} & Despacha alerta inmediata a almacén y asesor por desabastecimiento WAITING\_PARTS para priorizar adquisición. \\*
\hline
\textbf{Destino del Efecto} & AdvisorNotificationService y Almacén \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} WorkOrderTaskDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{WorkOrderTaskResumedEvent} \quad (\textit{Fase:} Inmediata) \\*
\hline
\textbf{Acción Orquestada} & Notifica al asesor de servicio que la labor técnica en foso ha sido reanudada exitosamente. \\*
\hline
\textbf{Destino del Efecto} & AdvisorNotificationService \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} WorkOrderTaskDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{WorkOrderTaskCompletedEvent} \quad (\textit{Fase:} Inmediata) \\*
\hline
\textbf{Acción Orquestada} & Evalúa si todas las tareas de la orden culminaron ejecutando el cierre automático macro a COMPLETED. \\*
\hline
\textbf{Destino del Efecto} & WorkOrderCommandService \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} WorkOrderTaskDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{TaskProductAddedEvent} \quad (\textit{Fase:} Posterior a confirmación) \\*
\hline
\textbf{Acción Orquestada} & Publica ProductStockReservationRequestedIntegrationEvent para reserva atómica por lotes FIFO. \\*
\hline
\textbf{Destino del Efecto} & Transactional Outbox / Event Bus \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} WorkOrderTaskDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{TaskProductRemovedEvent} \quad (\textit{Fase:} Posterior a confirmación) \\*
\hline
\textbf{Acción Orquestada} & Publica ProductStockReservationCancelledIntegrationEvent liberando la reserva de insumo en almacén. \\*
\hline
\textbf{Destino del Efecto} & Transactional Outbox / Event Bus \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} WorkshopExternalEventsListener} \\*
\hline
\textbf{Evento Capturado} & \texttt{AppointmentArrivedIntegrationEvent} \quad (\textit{Fase:} Posterior a confirmación) \\*
\hline
\textbf{Acción Orquestada} & Recepciona arribo vehicular desde CRM y ejecuta automáticamente CreateWorkOrderCommand en DRAFT. \\*
\hline
\textbf{Destino del Efecto} & WorkOrderCommandService \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} WorkshopExternalEventsListener} \\*
\hline
\textbf{Evento Capturado} & \texttt{PaymentProcessedIntegrationEvent} \quad (\textit{Fase:} Posterior a confirmación) \\*
\hline
\textbf{Acción Orquestada} & Recepciona confirmación de pago desde Facturación y ejecuta automáticamente MarkWorkOrderAsPaidCommand. \\*
\hline
\textbf{Destino del Efecto} & WorkOrderCommandService \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Clases ubicadas bajo el paquete com.andeva.atelier.platform.operations.application.events.

**Puertos de Salida y Pasarelas de Integración**

Para salvaguardar la independencia de la lógica de aplicación frente a detalles de implementación externos y librerías propietarias, la capa define contratos formales de puertos de salida en su perímetro arquitectónico.

El puerto **CustomerFleetAclService** establece la pasarela de comunicación con el Bounded Context de CRM a través de su fachada de contexto abierto, posibilitando la validación estricta de vehículos universalmente registrados, titulares de flota y citas agendadas sin acoplar la capa de operaciones al esquema de persistencia de clientes.

Por su parte, **TenancyAclService** provee el enlace perimetral hacia IAM & Tenancy, verificando la vigencia de contratos laborales de mecánicos, la asignación de roles operativos y la operatividad de las sedes físicas del taller antes de formalizar asignaciones de trabajo.

Asimismo, **InventoryReservationAclService** encapsula la interacción con el motor de inventario y cadena de suministro, orquestando la verificación de disponibilidad de piezas mecánicas y lubricantes, la reserva atómica bajo valuación FIFO por lotes y la restitución de existencias ante rectificaciones periciales.

Finalmente, **DirectToCloudStorageGateway** materializa la pasarela de control para almacenamiento de objetos, verificando que las fotografías de peritaje de recepción y evidencias de reparación cumplan con las firmas criptográficas y rutas autorizadas del bucket de Firebase Cloud Storage.

Con el objeto de sistematizar las dependencias perimetrales, en la @tbl:mro-outbound-ports se describen los métodos y responsabilidades técnicas de estos puertos de salida y pasarelas de integración.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.1cm} | >{\raggedright\arraybackslash}p{10.3cm} |}
\caption{Puertos de Salida y Pasarelas de la Capa de Aplicación de Workshop Operations (MRO)} \label{tbl:mro-outbound-ports} \\
\hline
\thfirst{Aspecto del Componente} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Componente} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} Customer\allowbreak Fleet\allowbreak Acl\allowbreak Service \quad (\textit{Categoría:} Puerto de Salida)} \\*
\hline
\textbf{Métodos Principales} & \texttt{findVehicleById}, \texttt{findCustomerById}, \texttt{validateAppointmentEligibility} \\*
\hline
\textbf{Responsabilidad Técnica} & Consulta y validación de vehículos universalmente registrados y titulares de flota en CRM vía CustomerFleetContextFacade. \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak application.\allowbreak acl} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} Tenancy\allowbreak Acl\allowbreak Service \quad (\textit{Categoría:} Puerto de Salida)} \\*
\hline
\textbf{Métodos Principales} & \texttt{isMechanicActiveMember}, \texttt{isBranchActive}, \texttt{getMechanicDisplayName} \\*
\hline
\textbf{Responsabilidad Técnica} & Verificación de vigencia contractual de mecánicos y sedes físicas en IAM vía TenancyContextFacade. \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak application.\allowbreak acl} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} Inventory\allowbreak Reservation\allowbreak Acl\allowbreak Service \quad (\textit{Categoría:} Puerto de Salida)} \\*
\hline
\textbf{Métodos Principales} & \texttt{requestStockReservation}, \texttt{cancelStockReservation}, \texttt{confirmStockDeduction} \\*
\hline
\textbf{Responsabilidad Técnica} & Coordinación síncrona o asíncrona de disponibilidad, reserva y consumo definitivo de existencias FIFO en Inventario. \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak application.\allowbreak acl} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} Direct\allowbreak To\allowbreak Cloud\allowbreak Storage\allowbreak Gateway \quad (\textit{Categoría:} Puerto de Salida)} \\*
\hline
\textbf{Métodos Principales} & \texttt{validateStorageUrl}, \texttt{verifyImageSignature} \\*
\hline
\textbf{Responsabilidad Técnica} & Validación criptográfica y comprobación perimetral de URLs seguras en Firebase Cloud Storage para inspección y peritaje. \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak operations.\allowbreak application.\allowbreak acl} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Clases ubicadas bajo el paquete com.andeva.atelier.platform.operations.application.acl.

**Análisis Arquitectónico y Rigor Operacional de la Capa de Aplicación**

En primer lugar, la orquestación transaccional implementada garantiza consistencia atómica entre la asignación física de puestos de trabajo y la máquina de estados determinista de las órdenes de servicio. Al gobernar la concurrencia sobre las bahías mediante verificación previa y bloqueo transaccional, se erradica la sobreasignación de elevadores y se asegura que cada transición de estado macro refleje fielmente la realidad física del taller mecánico.

En segundo término, la modelación de pausas técnicas objetivas por desabastecimiento de piezas preserva la validez de los indicadores de productividad laboral sin distorsionar el tiempo efectivo de llave. Al suspender formalmente el cómputo de horas activas durante la espera de repuestos y acumular con precisión los segundos de inactividad involuntaria, se previene la manipulación de métricas de rendimiento y se proporciona visibilidad inmediata al área de adquisiciones para mitigar cuellos de botella en almacén.

Por último, el desacoplamiento reactivo sustentado en el patrón Transactional Outbox y las pasarelas perimetrales de salida asegura una integración robusta con los módulos de inventario y facturación. La separación entre reservas preventivas de piezas durante la ejecución técnica y su deducción contable definitiva tras la liquidación del pago protege la integridad del balance de existencias FIFO sin incurrir en transacciones distribuidas complejas ni bloqueos prolongados de base de datos.

#### 2.6.4.4 Infrastructure Layer

La Capa de Infraestructura del Bounded Context Workshop Operations (MRO) materializa técnicamente los puertos de persistencia física, seguridad y comunicación perimetral definidos en los contratos de Dominio y Aplicación. Su implementación reside en el paquete canónico com.andeva.atelier.platform.operations.infrastructure, proveyendo el soporte relacional en PostgreSQL 16 sobre la infraestructura en la nube de Aiven Cloud mediante Spring Data JPA e Hibernate ORM.

Asimismo, esta capa gobierna la transformación bidireccional entre los modelos puros del negocio y los esquemas de base de datos, asegura la neutralidad de eventos mediante la reconstitución controlada de agregados, y garantiza el despacho atómico de eventos hacia la tabla transaccional outbox_messages. De igual forma, gestiona la integración perimetral con Google Cloud Storage y Firebase para peritaje fotográfico directo, así como adaptadores anticorrupción hacia los contextos de CRM, IAM e Inventory.

El diseño arquitectónico de este subsistema de infraestructura se fundamenta en cuatro directrices esenciales:

- **Desacoplamiento Estricto de Persistencia e Inversión de Dependencias:** Las entidades y agregados del dominio carecen por completo de anotaciones del estándar Jakarta Persistence. La persistencia física se confina en entidades JPA especializadas que heredan un identificador primario universal y marcas temporales automáticas de auditoría desde la superclase **AuditableAbstractPersistenceEntity**.

- **Persistencia Nulo-Segura y Normalización de Objetos de Valor:** Los objetos de valor inmutables y estados del negocio se traducen de forma transparente hacia tipos escalares nativos mediante convertidores JPA dedicados. Esta estrategia garantiza la integridad de invariantes como importes monetarios con precisión contable, códigos normalizados y categorizaciones de taller sin acoplar el núcleo de dominio al dialecto relacional.

- **Consistencia Transaccional Mediante Transactional Outbox:** Las operaciones mutacionales orquestadas por los adaptadores de repositorio ejecutan la persistencia relacional y la inserción del evento de dominio en la tabla transaccional outbox_messages dentro de la misma transacción de base de datos, garantizando una semántica de entrega al menos una vez hacia consumidores asíncronos.

- **Pasarela Multimedia Direct-to-Cloud e Integración Perimetral Resiliente:** La captura masiva de peritajes fotográficos y evidencias de reparación se articula mediante pasarelas de nube que generan identificadores de subida directa hacia Google Cloud Storage y Firebase Storage. Esto previene la sobrecarga de memoria en el servidor de Spring Boot y asegura que las imágenes sean transferidas de forma segura y verificable desde los dispositivos móviles de taller.

A fin de ofrecer una visión sistemática de estos componentes, en la @tbl:mro-infrastructure-types se presenta el catálogo consolidado de los tipos técnicos que conforman la Capa de Infraestructura de Workshop Operations (MRO).

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo Consolidado de la Capa de Infraestructura de Workshop Operations (MRO)} \label{tbl:mro-infrastructure-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\
\hline
\endhead
WorkOrder\allowbreak Persistence\allowbreak Entity & Mapeo relacional de órdenes de servicio automotriz a la tabla física work\_orders. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Hereda de AuditableAbstractPersistenceEntity. Raíz de persistencia de OTs. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
WorkBay\allowbreak Persistence\allowbreak Entity & Mapeo relacional de puestos físicos y elevadores a la tabla work\_bays. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Hereda de AuditableAbstractPersistenceEntity. 1:N con sedes físicas. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
WorkOrder\allowbreak Task\allowbreak Persistence\allowbreak Entity & Mapeo relacional de intervenciones mecánicas a la tabla work\_order\_tasks. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Clave foránea a work\_orders. Soporta pausas técnicas y asignación técnica. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
WorkOrder\allowbreak TaskProduct\allowbreak Persistence\allowbreak Entity & Mapeo relacional de repuestos utilizados a work\_order\_task\_products. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Clave foránea a tareas e inventario. Dispara reservas lógicas FIFO. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
TaskProposal\allowbreak Persistence\allowbreak Entity & Mapeo relacional de hallazgos periciales a la tabla task\_proposals. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Clave foránea a work\_orders. Modela averías detectadas en inspección de foso. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
WorkOrder\allowbreak Image\allowbreak Persistence\allowbreak Entity & Mapeo relacional de fotos de recepción inicial a work\_order\_images. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Clave foránea a work\_orders. Almacena URLs periciales en Firebase Storage. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
WorkOrder\allowbreak TaskImage\allowbreak Persistence\allowbreak Entity & Mapeo relacional de evidencias mecánicas a work\_order\_task\_images. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Clave foránea a tareas. Resguarda fotos de peritaje durante la reparación. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
Service\allowbreak Persistence\allowbreak Entity & Mapeo relacional del catálogo maestro de mano de obra a la tabla services. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Hereda de AuditableAbstractPersistenceEntity. Tarifas sugeridas de taller. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
WorkOrder\allowbreak Persistence\allowbreak Repository & Interfaz Spring Data JPA para persistencia relacional y consultas de OTs. \\*
\hline
\textbf{Categoría} & Repositorio Spring Data \\*
\hline
\textbf{Relaciones} & Declara consultas derivadas y bloqueos pesimistas para mutaciones de estado. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
WorkBay\allowbreak Persistence\allowbreak Repository & Interfaz Spring Data JPA para administración de bahías y puestos de trabajo. \\*
\hline
\textbf{Categoría} & Repositorio Spring Data \\*
\hline
\textbf{Relaciones} & Consultas de disponibilidad física por sede y tipo con bloqueo pesimista. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
Service\allowbreak Persistence\allowbreak Repository & Interfaz Spring Data JPA para catálogo de servicios y mano de obra estándar. \\*
\hline
\textbf{Categoría} & Repositorio Spring Data \\*
\hline
\textbf{Relaciones} & Búsquedas por sede y denominación comercial de intervenciones. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
WorkOrder\allowbreak Repository\allowbreak Impl & Adaptador de persistencia que materializa el puerto WorkOrderRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Repositorio \\*
\hline
\textbf{Relaciones} & Persiste órdenes de trabajo y canaliza eventos hacia outbox\_messages. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak adapters} \\
\hline
WorkBay\allowbreak Repository\allowbreak Impl & Adaptador de persistencia que implementa el puerto WorkBayRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Repositorio \\*
\hline
\textbf{Relaciones} & Coordina ocupación y liberación física concurrente de puestos de taller. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak adapters} \\
\hline
Service\allowbreak Repository\allowbreak Impl & Adaptador de persistencia que implementa el puerto ServiceRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Repositorio \\*
\hline
\textbf{Relaciones} & Gestiona el acceso al catálogo de mano de obra y tarifas estándar. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak adapters} \\
\hline
WorkOrder\allowbreak Persistence\allowbreak Assembler & Transformación bidireccional entre agregado WorkOrder y entidades JPA. \\*
\hline
\textbf{Categoría} & Ensamblador de Persistencia \\*
\hline
\textbf{Relaciones} & Hidrata agregados mediante factory reconstitute() sin disparar eventos. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak transform} \\
\hline
WorkBay\allowbreak Persistence\allowbreak Assembler & Transformación bidireccional entre agregado WorkBay y entidad JPA. \\*
\hline
\textbf{Categoría} & Ensamblador de Persistencia \\*
\hline
\textbf{Relaciones} & Mapea tipos de bahía y reconstituye el agregado puro en memoria. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak transform} \\
\hline
Service\allowbreak Persistence\allowbreak Assembler & Transformación bidireccional entre agregado Service y entidad JPA. \\*
\hline
\textbf{Categoría} & Ensamblador de Persistencia \\*
\hline
\textbf{Relaciones} & Mapea objetos de valor monetarios y reconstituye el catálogo de servicios. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak transform} \\
\hline
TaskProposal\allowbreak Persistence\allowbreak Assembler & Transformación bidireccional para propuestas periciales de tareas. \\*
\hline
\textbf{Categoría} & Ensamblador de Persistencia \\*
\hline
\textbf{Relaciones} & Mapea severidad, estado y notas de revisión sin alterar la historia clínica. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak transform} \\
\hline
WorkOrder\allowbreak Status\allowbreak Attribute\allowbreak Converter & Conversión bidireccional entre WorkOrderStatus y columna VARCHAR(20). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Normaliza estados macro DRAFT, IN\_PROGRESS, COMPLETED, PAID y CANCELED. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
WorkOrder\allowbreak TaskStatus\allowbreak Attribute\allowbreak Converter & Conversión bidireccional entre WorkOrderTaskStatus y columna VARCHAR(20). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Normaliza estados PENDING, ASSIGNED, IN\_PROGRESS, ON\_HOLD y COMPLETED. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
BayType\allowbreak Attribute\allowbreak Converter & Conversión bidireccional entre BayType y columna VARCHAR(20). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Mapea tipos físicos LIFT, PAINT\_BOOTH, WASHING y ALIGNMENT. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
BayStatus\allowbreak Attribute\allowbreak Converter & Conversión bidireccional entre BayStatus y columna VARCHAR(20). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Mapea estados de disponibilidad AVAILABLE, OCCUPIED y MAINTENANCE. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
Proposal\allowbreak Severity\allowbreak Attribute\allowbreak Converter & Conversión bidireccional entre ProposalSeverity y columna VARCHAR(20). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Mapea niveles de criticidad pericial LOW, MEDIUM y CRITICAL. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
Proposal\allowbreak Status\allowbreak Attribute\allowbreak Converter & Conversión bidireccional entre ProposalStatus y columna VARCHAR(20). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Mapea resoluciones de cliente PENDING\_REVIEW, APPROVED y REJECTED. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
Money\allowbreak Attribute\allowbreak Converter & Conversión bidireccional entre Money y columna NUMERIC(10, 2). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Extrae BigDecimal preservando exactitud contable en tarifas y totales. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
Firebase\allowbreak Storage\allowbreak Direct\allowbreak Upload\allowbreak Gateway\allowbreak Impl & Pasarela cloud que emite URLs pre-firmadas PUT hacia Google Cloud Storage. \\*
\hline
\textbf{Categoría} & Pasarela Cloud de Salida \\*
\hline
\textbf{Relaciones} & Valida tipos MIME periciales y elimina el paso de binarios por el backend. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak infrastructure.\allowbreak external} \\
\hline
Customer\allowbreak Fleet\allowbreak Acl\allowbreak Adapter & Adaptador perimetral de salida hacia la fachada del contexto CRM. \\*
\hline
\textbf{Categoría} & Adaptador ACL de Salida \\*
\hline
\textbf{Relaciones} & Valida titularidad vehicular activa y datos de cita antes de abrir OTs. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak infrastructure.\allowbreak external} \\
\hline
Tenancy\allowbreak Acl\allowbreak Adapter & Adaptador perimetral de salida hacia la fachada del contexto IAM. \\*
\hline
\textbf{Categoría} & Adaptador ACL de Salida \\*
\hline
\textbf{Relaciones} & Verifica suscripción de taller, sedes operativas y técnicos asignables. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak infrastructure.\allowbreak external} \\
\hline
Inventory\allowbreak Reservation\allowbreak Acl\allowbreak Adapter & Adaptador perimetral de salida hacia el contexto Inventory. \\*
\hline
\textbf{Categoría} & Adaptador ACL de Salida \\*
\hline
\textbf{Relaciones} & Orquesta reservas de repuestos en tareas y confirma consumos FIFO al pagar. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak infrastructure.\allowbreak external} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes configurados bajo el paquete canónico com.andeva.atelier.platform.operations.infrastructure.

**Entidades de Persistencia JPA y Modelado Relacional Físico**

El modelado relacional de persistencia reproduce fielmente la topología operativa del taller mecánico mediante ocho entidades JPA mapeadas a sus respectivas tablas físicas en PostgreSQL 16. La raíz de persistencia **WorkOrderPersistenceEntity** se vincula a la tabla work_orders, encapsulando el correlativo interno por taller, el vehículo intervenido, la bahía física ocupada y el resumen diagnóstico de ingreso.

Por su parte, la entidad **WorkBayPersistenceEntity** representa los puestos físicos de trabajo en la tabla work_bays, soportando elevadores, cabinas de pintura y fosos de alineamiento con índices especializados para consultas de disponibilidad inmediata. Las tareas mecánicas se registran en **WorkOrderTaskPersistenceEntity**, incorporando marcas temporales de inicio, término y pausas técnicas por desabastecimiento de piezas en almacén.

Asimismo, las demandas de repuestos se asignan a **WorkOrderTaskProductPersistenceEntity**, mientras que los hallazgos adicionales detectados en inspección técnica se almacenan en **TaskProposalPersistenceEntity** para su evaluación comercial. La evidencia visual se distribuye entre **WorkOrderImagePersistenceEntity** para el estado inicial de recepción y **WorkOrderTaskImagePersistenceEntity** para la certificación del procedimiento mecánico, preservando las URLs de Firebase.

Con el propósito de especificar la correlación física y estructural del modelo relacional, en la @tbl:mro-jpa-entities se detallan las entidades JPA, sus tablas correspondientes, columnas principales, restricciones e índices.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Especificación Relacional de Entidades JPA de Workshop Operations (MRO)} \label{tbl:mro-jpa-entities} \\
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} WorkOrderPersistenceEntity \quad (\textit{Tabla:} \texttt{work\_orders})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{tenant\_id}, \texttt{appointment\_id}, \texttt{vehicle\_id}, \texttt{internal\_number}, \texttt{current\_bay\_id}, \texttt{mileage\_in}, \texttt{diagnostic\_summary}, \texttt{total\_amount}, \texttt{status} \\*
\hline
\textbf{Restricciones e Índices} & Restricción única en tupla (tenant\_id, internal\_number). Claves foráneas hacia tenants, appointments, vehicles y work\_bays. Índice idx\_work\_orders\_tenant\_status. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} WorkBayPersistenceEntity \quad (\textit{Tabla:} \texttt{work\_bays})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{tenant\_id}, \texttt{branch\_id}, \texttt{name}, \texttt{type}, \texttt{status}, \texttt{current\_work\_order\_id} \\*
\hline
\textbf{Restricciones e Índices} & Claves foráneas hacia tenants, branches y work\_orders. Índice compuesto idx\_work\_bays\_branch\_status para consulta inmediata de disponibilidad física. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} WorkOrderTaskPersistenceEntity \quad (\textit{Tabla:} \texttt{work\_order\_tasks})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{work\_order\_id}, \texttt{service\_id}, \texttt{mechanic\_id}, \texttt{status}, \texttt{description}, \texttt{price}, \texttt{hold\_reason}, \texttt{missing\_item\_description}, \texttt{paused\_at}, \texttt{total\_paused\_seconds}, \texttt{started\_at}, \texttt{completed\_at} \\*
\hline
\textbf{Restricciones e Índices} & Claves foráneas a work\_orders, services y tenant\_memberships. Restricción de verificación en price mayor o igual a cero. Índices idx\_work\_order\_tasks\_order\_status y idx\_tasks\_mechanic. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} WorkOrderTaskProductPersistenceEntity \quad (\textit{Tabla:} \texttt{work\_order\_task\_products})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{task\_id}, \texttt{product\_id}, \texttt{quantity}, \texttt{unit\_price}, \texttt{total\_amount} \\*
\hline
\textbf{Restricciones e Índices} & Claves foráneas a work\_order\_tasks e inventory\_items. Restricción de verificación en quantity mayor a cero. Índice idx\_task\_products\_task\_id. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} TaskProposalPersistenceEntity \quad (\textit{Tabla:} \texttt{task\_proposals})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{work\_order\_id}, \texttt{task\_id}, \texttt{service\_id}, \texttt{mechanic\_id}, \texttt{description}, \texttt{severity}, \texttt{image\_url}, \texttt{status}, \texttt{customer\_notes}, \texttt{created\_at}, \texttt{updated\_at} \\*
\hline
\textbf{Restricciones e Índices} & Claves foráneas a work\_orders, work\_order\_tasks, services y tenant\_memberships. Restricción en severity y status. Índice idx\_proposals\_order\_status. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} WorkOrderImagePersistenceEntity \quad (\textit{Tabla:} \texttt{work\_order\_images})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{work\_order\_id}, \texttt{image\_url}, \texttt{description}, \texttt{uploaded\_at} \\*
\hline
\textbf{Restricciones e Índices} & Clave foránea a work\_orders con eliminación en cascada. Validación no nulo en image\_url y uploaded\_at. Índice idx\_work\_order\_images\_order\_id. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} WorkOrderTaskImagePersistenceEntity \quad (\textit{Tabla:} \texttt{work\_order\_task\_images})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{task\_id}, \texttt{image\_url}, \texttt{description}, \texttt{uploaded\_at} \\*
\hline
\textbf{Restricciones e Índices} & Clave foránea a work\_order\_tasks con eliminación en cascada. Validación no nulo en image\_url. Índice idx\_task\_images\_task\_id. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} ServicePersistenceEntity \quad (\textit{Tabla:} \texttt{services})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{tenant\_id}, \texttt{name}, \texttt{base\_price}, \texttt{estimated\_time\_m} \\*
\hline
\textbf{Restricciones e Índices} & Clave foránea a tenants. Restricción de verificación en base\_price y estimated\_time\_m. Índice idx\_services\_tenant\_name. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Tablas físicas alojadas en el motor PostgreSQL 16 con herencia de auditoría temporal en la base de datos central.

**Repositorios Spring Data JPA y Adaptadores de Persistencia**

La interacción técnica con la base de datos se desacopla mediante el patrón Adaptador de Repositorio. Las interfaces Spring Data JPA declaran operaciones optimizadas de acceso a datos y consultas derivadas, mientras que las clases adaptadoras implementan formalmente los puertos de salida definidos en la Capa de Dominio.

Durante las operaciones de mutación, el adaptador **WorkOrderRepositoryImpl** transforma el agregado puro en su representación relacional mediante su ensamblador, persiste el registro a través de **WorkOrderPersistenceRepository**, extrae la colección de eventos acumulados y los canaliza al publicador transaccional para su registro en outbox_messages. Este mismo flujo garantiza la integridad atómica en **WorkBayRepositoryImpl** y **ServiceRepositoryImpl**.

A fin de sistematizar las responsabilidades y contratos de persistencia, en la @tbl:mro-repository-adapters se especifican los adaptadores de repositorio, sus puertos de dominio asociados y las operaciones relacionales implementadas.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Adaptadores de Persistencia y Puertos de Dominio de Workshop Operations (MRO)} \label{tbl:mro-repository-adapters} \\
\hline
\thfirst{Aspecto de Adaptador} & \thcell{Especificación Técnica y Persistencia} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Adaptador} & \thcell{Especificación Técnica y Persistencia} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} WorkOrderRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{WorkOrderRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{WorkOrderPersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & Mapea agregado a entidad relacional. Persiste en PostgreSQL 16. Extrae eventos acumulados y los canaliza al publicador transaccional hacia outbox\_messages. findById con carga eager de tareas e imágenes. findByTenantIdAndInternalNumber para búsqueda correlativa. findActiveByVehicleId para evitar doble ingreso vehicular. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} WorkBayRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{WorkBayRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{WorkBayPersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & Persiste bahías con control de concurrencia optimista. findById con validación de inquilino. findAllByBranchId para tablero de puestos de trabajo. findAvailableByBranchIdAndType con bloqueo pesimista en asignación para prevenir sobreocupación física. findByCurrentWorkOrderId para desvinculación operativa. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} ServiceRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{ServiceRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{ServicePersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & Persiste y actualiza servicios del catálogo maestro. findById con verificación de pertenencia a taller. findAllByTenantId con paginación de tarifas. findByNameAndTenantId para evitar duplicidad de nombres. searchByNameLike para autocompletado en foso. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Clases ubicadas bajo el paquete canónico com.andeva.atelier.platform.operations.infrastructure.persistence.jpa.adapters.

**Ensambladores de Persistencia y Convertidores JPA**

La correspondencia entre estructuras inmutables del dominio y modelos relacionales mutables se resuelve a través de cuatro ensambladores de persistencia dedicados. Estos componentes extraen los valores escalares de las entidades JPA y reconstruyen los agregados puros en memoria invocando métodos de fábrica estáticos controlados, tales como *WorkOrder.reconstitute()*, garantizando que la lectura no dispare eventos de dominio espurios.

De forma complementaria, los convertidores de atributos JPA estandarizan la serialización de enumeraciones del negocio hacia columnas relacionales de tipo VARCHAR. Componentes como **WorkOrderStatusAttributeConverter**, **WorkOrderTaskStatusAttributeConverter**, **BayTypeAttributeConverter** y **BayStatusAttributeConverter** garantizan consistencia semántica, mientras que **MoneyAttributeConverter** preserva la precisión contable de dos decimales en columnas NUMERIC.

Para sintetizar las reglas de transformación y correspondencia estructural, en la @tbl:mro-persistence-assemblers se describen los ensambladores de persistencia y convertidores JPA del contexto.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Ensambladores de Persistencia y Convertidores JPA de Workshop Operations (MRO)} \label{tbl:mro-persistence-assemblers} \\
\hline
\thfirst{Aspecto de Mapeo} & \thcell{Tipos Relacionados y Transformación} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Mapeo} & \thcell{Tipos Relacionados y Transformación} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} WorkOrderPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{WorkOrder} $\longleftrightarrow$ \texttt{WorkOrderPersistenceEntity} \\*
\hline
\textbf{Transformación} & Traduce WorkOrderId a UUID. Mapea colecciones hijas de tareas, productos, propuestas e imágenes. Reconstituye el agregado puro mediante fábrica estática WorkOrder.reconstitute() sin disparar eventos de dominio espurios. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} WorkBayPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{WorkBay} $\longleftrightarrow$ \texttt{WorkBayPersistenceEntity} \\*
\hline
\textbf{Transformación} & Mapea WorkBayId, BranchId y WorkOrderId a UUID. Invoca WorkBay.reconstitute() para restaurar el estado físico de bahías sin mutaciones laterales. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} ServicePersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{Service} $\longleftrightarrow$ \texttt{ServicePersistenceEntity} \\*
\hline
\textbf{Transformación} & Traduce ServiceId a UUID y Money a BigDecimal. Invoca Service.reconstitute() preservando las tarifas maestras de mano de obra. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} TaskProposalPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{TaskProposal} $\longleftrightarrow$ \texttt{TaskProposalPersistenceEntity} \\*
\hline
\textbf{Transformación} & Traduce TaskProposalId a UUID, severidad, evidencia fotográfica y estado de resolución. Reconstituye hallazgos periciales como registros inmutables de inspección. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} WorkOrderStatusAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{WorkOrderStatus} $\longleftrightarrow$ \texttt{VARCHAR(20)} \\*
\hline
\textbf{Transformación} & Mapea estados DRAFT, IN\_PROGRESS, COMPLETED, PAID y CANCELED a valores relacionales normalizados en base de datos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} WorkOrderTaskStatusAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{WorkOrderTaskStatus} $\longleftrightarrow$ \texttt{VARCHAR(20)} \\*
\hline
\textbf{Transformación} & Mapea estados PENDING, ASSIGNED, IN\_PROGRESS, ON\_HOLD, COMPLETED y CANCELLED a columnas físicas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} BayTypeAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{BayType} $\longleftrightarrow$ \texttt{VARCHAR(20)} \\*
\hline
\textbf{Transformación} & Mapea tipos de puesto LIFT, PAINT\_BOOTH, WASHING y ALIGNMENT a literales relacionales. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} BayStatusAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{BayStatus} $\longleftrightarrow$ \texttt{VARCHAR(20)} \\*
\hline
\textbf{Transformación} & Mapea condiciones físicas AVAILABLE, OCCUPIED y MAINTENANCE a la columna status de bahías. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} ProposalSeverityAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{ProposalSeverity} $\longleftrightarrow$ \texttt{VARCHAR(20)} \\*
\hline
\textbf{Transformación} & Mapea niveles de riesgo LOW, MEDIUM y CRITICAL a cadenas normalizadas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} ProposalStatusAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{ProposalStatus} $\longleftrightarrow$ \texttt{VARCHAR(20)} \\*
\hline
\textbf{Transformación} & Mapea dictámenes de revisión PENDING\_REVIEW, APPROVED y REJECTED a valores relacionales. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} EvidenceTypeAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{EvidenceType} $\longleftrightarrow$ \texttt{VARCHAR(20)} \\*
\hline
\textbf{Transformación} & Mapea categorizaciones de fotos INITIAL\_INSPECTION, TASK\_EVIDENCE y PROPOSAL a columnas físicas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} MoneyAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{Money} $\longleftrightarrow$ \texttt{NUMERIC(10,\allowbreak 2)} \\*
\hline
\textbf{Transformación} & Extrae el valor numérico decimal con escala estricta de dos posiciones preservando exactitud contable. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes configurados bajo los paquetes transform y converters de la capa de infraestructura.

**Pasarelas Externas de Infraestructura e Integración Cloud**

La integración con plataformas externas y subsistemas adyacentes se canaliza mediante adaptadores secundarios ubicados en el paquete com.andeva.atelier.platform.operations.infrastructure.external. Estos componentes implementan los puertos de salida definidos en la Capa de Aplicación, aislando el núcleo operativo del taller de dependencias externas.

El adaptador **FirebaseStorageDirectUploadGatewayImpl** materializa el puerto **DirectUploadStorageGateway** comunicándose con Google Cloud Storage SDK para emitir URLs pre-firmadas HTTP PUT con expiración estricta de quince minutos. Este mecanismo valida tipos MIME periciales autorizados y erradica el tránsito de archivos binarios por la memoria RAM de la API backend, reduciendo la latencia de carga en la aplicación móvil de taller.

Asimismo, los adaptadores perimetrales **CustomerFleetAclAdapter**, **TenancyAclAdapter** e **InventoryReservationAclAdapter** canalizan la comunicación intermodular hacia CRM, IAM e Inventory. Estos componentes verifican la titularidad vehicular, validan la disponibilidad de mecánicos activos y coordinan las reservas lógicas de repuestos, asegurando la consistencia operativa sin incurrir en acoplamientos rígidos entre módulos.

A fin de ilustrar la arquitectura de integración y servicios en la nube, en la @tbl:mro-external-infrastructure se presentan las tecnologías subyacentes y las responsabilidades técnicas de cada pasarela externa.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Pasarelas Externas y Adaptadores de Integración Cloud de Workshop Operations (MRO)} \label{tbl:mro-external-infrastructure} \\
\hline
\thfirst{Aspecto Técnico} & \thcell{Tecnología y Responsabilidad de Integración} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto Técnico} & \thcell{Tecnología y Responsabilidad de Integración} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Pasarela Externa:} FirebaseStorageDirectUploadGatewayImpl \quad (\textit{Categoría:} Pasarela Multimedia Cloud)} \\*
\hline
\textbf{Tecnología Subyacente} & Google Cloud Storage SDK (HTTP PUT Pre-signed URLs) \\*
\hline
\textbf{Responsabilidad} & Genera URLs pre-firmadas con expiración de quince minutos y validación rigurosa de tipo de medio para subida pericial directa hacia Google Cloud Storage. Elimina la congestión de memoria en la API backend. Implementa DirectUploadStorageGateway. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Pasarela Externa:} CustomerFleetAclAdapter \quad (\textit{Categoría:} Adaptador ACL CRM)} \\*
\hline
\textbf{Tecnología Subyacente} & In-Memory Context Facade / CustomerFleetContextFacade \\*
\hline
\textbf{Responsabilidad} & Invoca la fachada del contexto CRM para verificar la titularidad vehicular activa, el kilometraje previo y las citas técnicas concertadas antes de aperturar la orden de servicio. Implementa CustomerFleetGateway. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Pasarela Externa:} TenancyAclAdapter \quad (\textit{Categoría:} Adaptador ACL IAM)} \\*
\hline
\textbf{Tecnología Subyacente} & In-Memory Context Facade / TenancyContextFacade \\*
\hline
\textbf{Responsabilidad} & Consulta la fachada del contexto IAM para autenticar la pertenencia laboral y el estado activo de los mecánicos asignados, así como la vigencia de la suscripción del taller. Implementa TenancyGateway. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Pasarela Externa:} InventoryReservationAclAdapter \quad (\textit{Categoría:} Adaptador ACL Inventario)} \\*
\hline
\textbf{Tecnología Subyacente} & In-Memory Module Facade / Outbox Events \\*
\hline
\textbf{Responsabilidad} & Comunica requerimientos de repuestos al contexto Inventory solicitando reservas preventivas durante la tarea mecánica y confirmando la deducción FIFO definitiva tras la liquidación contable. Implementa InventoryReservationGateway. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes configurados bajo el paquete canónico com.andeva.atelier.platform.operations.infrastructure.external.

**Análisis Arquitectónico y Rigor Operacional de la Capa de Infraestructura**

En primer lugar, el modelo de persistencia relacional implementado garantiza el aislamiento estricto de datos multi-inquilino mediante la propagación obligatoria del identificador de taller en las tablas maestras. La segregación física entre bahías de trabajo, órdenes de servicio y tareas mecánicas asegura que las consultas transaccionales operen exclusivamente sobre los activos del concesionario autenticado, evitando cualquier fuga o interferencia de información.

En segundo término, la arquitectura de subida multimedia Direct-to-Cloud hacia Google Cloud Storage optimiza drásticamente el perfil de consumo computacional de la plataforma. Al delegar la recepción y almacenamiento de evidencias periciales en la infraestructura perimetral de Google, la API central conserva su ancho de banda y capacidad de memoria para la orquestación de casos de uso críticos, alcanzando un desempeño sostenido durante picos de recepción matutina.

Por último, el patrón Transactional Outbox y la reconstitución aséptica de agregados consolidan la resiliencia operativa del sistema. Al desvincular la persistencia atómica local de la publicación asíncrona de eventos, se garantiza una semántica de entrega confiable hacia los módulos de inventario y facturación sin bloquear hilos de base de datos ni arriesgar inconsistencias ante fallos de conectividad temporal.

#### 2.6.4.5. Bounded Context Software Architecture Component Level Diagrams

En esta sección se presenta la descomposición arquitectónica interna del contenedor central **API Application** en relación con el Bounded Context Workshop Operations (MRO). Siguiendo el Nivel 3 del Modelo C4, se ilustran los bloques estructurales que conforman este subsistema productivo, formalizando sus responsabilidades técnicas, fronteras operacionales y mecanismos de integración con clientes, módulos adyacentes y servicios externos.

Dentro de la arquitectura de monolito modular de Atelier Platform, el Bounded Context Workshop Operations asume la responsabilidad de gobernar el flujo productivo del taller mecánico, el ciclo de vida transaccional de las órdenes de trabajo, la ocupación física concurrente de bahías y elevadores, el control de tiempos de llave y pausas técnicas por desabastecimiento de piezas, la captura de evidencias fotográficas periciales en foso y la coordinación de demanda de repuestos hacia inventario.

En la @tbl:mro-c4-components se presenta el catálogo estructurado de los siete componentes constitutivos del Bounded Context Workshop Operations (MRO) dentro del contenedor anfitrión. Cada bloque encapsula una responsabilidad arquitectónica cohesiva, delimitando con precisión la frontera entre los controladores perimetrales REST, la orquestación de casos de uso mediante CQRS, el modelo de dominio puro, la persistencia física en base de datos y la integración con pasarelas de nube.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.5cm} | >{\raggedright\arraybackslash}p{10.9cm} |}
\caption{Catálogo de Componentes de Arquitectura de Software del Bounded Context Workshop Operations (MRO)} \label{tbl:mro-c4-components} \\
\hline
\thfirst{Aspecto Técnico} & \thcell{Especificación de Arquitectura} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto Técnico} & \thcell{Especificación de Arquitectura} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} MRO REST Controllers \& Resource Assemblers} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring MVC, SpringDoc OpenAPI, Jakarta Validation \\*
\hline
\textbf{Responsabilidad} & Expone endpoints REST perimetrales para la gestión integral de órdenes de trabajo, puestos de taller, tareas mecánicas y catálogo tarifario. Valida contratos sintácticos y proyecta recursos REST enriquecidos con enlaces. \\*
\hline
\textbf{Relaciones} & Entrada desde WebApp y Mobile Workshop. Despacha comandos de mutación y consultas de lectura a servicios CQRS. Utiliza ensambladores de recursos REST. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} MRO CQRS Application Services} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring Service, Transactional, CQRS, Interfaces Funcionales \\*
\hline
\textbf{Responsabilidad} & Orquesta casos de uso de negocio de apertura de órdenes, control de concurrencia en asignación de bahías, ejecución/pausa de labores técnicas, registro de hallazgos periciales y liquidación contable bajo transacciones ACID. \\*
\hline
\textbf{Relaciones} & Implementa contratos de comando y consulta. Invoca reglas de negocio en el núcleo de dominio. Delega en adaptadores de persistencia JPA y pasarelas de nube. Emite eventos de dominio hacia oyentes dedicados. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} MRO Domain Event Listeners \& Integration Dispatcher} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring Events, TransactionalEventListener, Outbox Pattern \\*
\hline
\textbf{Responsabilidad} & Captura eventos de dominio emitidos por los agregados (cambios de estado en OT, pausas por desabastecimiento de piezas, tareas completadas) y los canaliza a la tabla transaccional outbox\_messages para notificación asíncrona. \\*
\hline
\textbf{Relaciones} & Escucha eventos de dominio de servicios de aplicación. Persiste mensajes transaccionales en base de datos. Notifica a consumidores en Inventory, Invoicing y CRM. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} MRO Domain Model \& Aggregate Roots} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Java 26 puro, Domain Model, Records, Inmutabilidad \\*
\hline
\textbf{Responsabilidad} & Encapsula las reglas puras del negocio: máquina de estados finita de órdenes de trabajo, estados de disponibilidad de bahías, pausas técnicas objetivas (waiting\_parts), cálculo financiero con redondeo contable e invariantes periciales. \\*
\hline
\textbf{Relaciones} & Contiene raíces WorkOrder, WorkBay, Service y entidades dependientes WorkOrderTask, WorkOrderTaskProduct, TaskProposal, WorkOrderImage, WorkOrderTaskImage. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} MRO Persistence Repositories \& JPA Adapters} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Jakarta Persistence 3.1, Spring Data JPA, Hibernate, PostgreSQL 16 \\*
\hline
\textbf{Responsabilidad} & Materializa los puertos de repositorio de dominio mediante adaptadores secundarios, implementando bloqueos pesimistas para asignación concurrente de puestos físicos y despacho atómico Outbox dentro de la misma transacción. \\*
\hline
\textbf{Relaciones} & Realiza interfaces WorkOrderRepository, WorkBayRepository, ServiceRepository. Lee y escribe en las tablas relacionales de PostgreSQL 16. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Inbound ACL \& Workshop Operations Facade} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring Service, In-Memory ACL, Published Language \\*
\hline
\textbf{Responsabilidad} & Publica una interfaz Open Host Service en memoria que provee a módulos adyacentes (Invoicing, CRM, IoT) el estado de órdenes de trabajo, resúmenes diagnósticos y ocupación de bahías sin acoplamiento interno. \\*
\hline
\textbf{Relaciones} & Invocado por Invoicing \& Compliance (liquidación fiscal), IoT Telemetry (asociación de DTCs) y Customer \& Fleet (historial clínico). Delega lecturas en repositorios JPA. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} MRO External Gateways \& Cloud Integration} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Google Cloud Storage SDK, In-Memory ACL Adapters \\*
\hline
\textbf{Responsabilidad} & Genera URLs pre-firmadas HTTP PUT hacia Google Cloud Storage con expiración de 15 minutos para carga directa de fotos periciales (cero memoria RAM en el backend), y canaliza adaptadores anticorrupción hacia CRM, IAM e Inventory. \\*
\hline
\textbf{Relaciones} & Invocado por servicios de aplicación. Conecta vía HTTPS con Google Cloud Storage y mediante llamadas en memoria con las fachadas de CRM, IAM e Inventory. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al contenedor API Application en com.andeva.atelier.platform.operations.

En la @fig:c4-component-mro se ilustra el diagrama C4 de componentes para el Bounded Context Workshop Operations (MRO), detallando las interacciones entre los controladores REST, los servicios de aplicación CQRS, los manejadores de eventos de integración, el núcleo de dominio, los adaptadores de persistencia relacional, la fachada de contexto abierto y las pasarelas externas.

![Diagrama de Componentes C4 (Nivel 3) para el Bounded Context Workshop Operations (MRO) en API Application](report/assets/c4-diagrams/component-level-diagram-mro.png){#fig:c4-component-mro}

*Nota.* Elaboración propia en base a la arquitectura táctica del backend y el estándar C4 Model.

**Dinámica de Interacción y Flujos Operativos del Bounded Context Workshop Operations (MRO)**

Para comprender la colaboración entre los componentes de Workshop Operations y los módulos adyacentes durante la ejecución del sistema, se analizan a continuación los tres flujos operacionales más representativos de la plataforma:

- **Ciclo de Apertura de Orden de Trabajo, Asignación de Bahía y Peritaje Multimedia Direct-to-Cloud:**
  Cuando un vehículo arriba a la recepción del taller, el Asesor de Servicio registra el kilometraje de ingreso y el diagnóstico preliminar desde la aplicación web o tableta móvil. El componente **MRO REST Controllers & Resource Assemblers** recibe la petición HTTP POST en el endpoint perimetral de órdenes de trabajo, valida la integridad sintáctica de los identificadores y despacha el comando correspondiente hacia **MRO CQRS Application Services**.

  El servicio de aplicación consulta la pasarela **MRO External Gateways & Cloud Integration**, la cual verifica síncronamente en memoria frente al módulo de Customer & Fleet que el vehículo posea una titularidad activa y que la cita previa se encuentre en estado arribado. Validada la precondición, el servicio invoca el método de fábrica del agregado en **MRO Domain Model & Aggregate Roots**, asignando un número correlativo secuencial único por taller y estableciendo el estado inicial DRAFT.

  Si la solicitud especifica una bahía inicial (elevador o foso de alineamiento), el servicio invoca el repositorio de bahías en **MRO Persistence Repositories & JPA Adapters** aplicando bloqueo pesimista para evitar sobreocupación física ante recepciones simultáneas. Una vez vinculada la bahía, el adaptador de persistencia salva la orden y el nuevo estado OCCUPIED de la bahía en PostgreSQL 16, extrayendo los eventos de dominio acumulados e insertándolos en la tabla transaccional outbox_messages dentro de la misma transacción ACID.

  Para el registro fotográfico pericial de recepción, el cliente móvil solicita URLs de subida directa. La pasarela externa invoca Google Cloud Storage SDK para emitir URLs firmadas HTTP PUT con expiración de 15 minutos y restricción estricta de tipo de medio. El dispositivo móvil transfiere directamente el binario fotográfico al bucket perimetral de Google sin transitar por la memoria RAM del servidor de Spring Boot, notificando posteriormente la finalización mediante metadatos ligeros para asociar la evidencia a la orden de trabajo.

- **Ciclo de Intervención en Foso, Pausas por Desabastecimiento de Piezas y Reserva FIFO:**
  Una vez que el vehículo ingresa a la bahía asignada, el mecánico asignado consulta su tablero de labores en la aplicación móvil de taller. Al iniciar una labor, el operario interactúa con la interfaz móvil, emitiendo una petición al controlador perimetral. El controlador delega en **MRO CQRS Application Services**, el cual recupera la orden de trabajo mediante su adaptador de persistencia y ejecuta la transición hacia IN_PROGRESS en la tarea correspondiente, estampando la marca temporal real de inicio.

  Si durante la intervención el mecánico detecta la necesidad de un repuesto no disponible en patio, emite un reporte de suspensión especificando la causal objetiva de espera de repuestos y el detalle del insumo faltante. El modelo de dominio valida la transición hacia ON_HOLD, registra el instante exacto de suspensión e interrumpe el cómputo de productividad laboral, evitando que el tiempo de inactividad involuntaria penalice los indicadores de rendimiento técnico. La orden acumula el evento de pausa de tarea, notificando al área de adquisiciones para agilizar el abastecimiento.

  Cuando el almacén suministra la pieza requerida, el asesor de servicio agrega el repuesto a la labor técnica. El servicio de aplicación invoca la pasarela **MRO External Gateways & Cloud Integration**, la cual se comunica con el módulo de Inventory solicitando una reserva preventiva de existencias. El motor logístico bloquea las unidades en el lote físico FIFO correspondiente. Finalmente, el mecánico reanuda la labor, computando la diferencia temporal acumulada de inactividad y restableciendo el estado IN_PROGRESS hasta certificar su culminación física con fotografías de peritaje final.

- **Ciclo de Liquidación Financiera, Despacho Transactional Outbox y Consumo Definitivo FIFO:**
  Una vez que la totalidad de labores técnicas ha alcanzado el estado de culminación y las bahías físicas han sido liberadas, el asesor de servicio solicita la liquidación financiera de la orden. El servicio de aplicación recupera la orden y delega en el calculador de costos de dominio, el cual efectúa la sumatoria atómica de mano de obra y repuestos aplicados, incorporando la tasa del Impuesto General a las Ventas bajo modo de redondeo contable bancario, transitando la orden deterministamente al estado COMPLETED.

  Cuando el cliente efectúa el pago en recepción, la pasarela perimetral registra la transición hacia PAID, registrando en memoria el evento de pago de orden. El adaptador **MRO Persistence Repositories & JPA Adapters** persiste el estado terminal en la tabla work_orders y canaliza el evento hacia la tabla transaccional outbox_messages. El despachador en segundo plano detecta el mensaje no procesado y emite el evento de integración hacia los módulos adyacentes.

  Al recibir la notificación de pago, el módulo de Invoicing & Compliance consulta en memoria la fachada **Inbound ACL & Workshop Operations Facade**, obteniendo el desglose inmutable de conceptos gravados para la emisión electrónica del comprobante fiscal ante la SUNAT mediante Nubefact. Simultáneamente, el módulo de Inventory & Supply Chain transforma las reservas preventivas en deducciones contables definitivas, consumiendo los lotes físicos FIFO al costo histórico de adquisición y recalculando el balance de existencias en almacén sin requerir transacciones distribuidas ni comprometer la disponibilidad.

#### 2.6.4.6. Bounded Context Software Architecture Code Level Diagrams

En esta sección se profundiza en el nivel de máxima granularidad y rigor técnico dentro de la arquitectura de software del Bounded Context Workshop Operations (MRO), trasladando las fronteras tácticas y los invariantes operativos hacia especificaciones estáticas que orientan la codificación de la plataforma. Mediante esta aproximación, se garantiza que la planificación de intervenciones mecánicas, la ocupación física de bahías, el despacho de repuestos y la liquidación comercial de servicios se ejecuten bajo tipado estricto y consistencia determinista.

Esta dimensión arquitectónica se estructura en dos perspectivas complementarias: el Diagrama de Clases de la Capa de Dominio, que modela en memoria las raíces de agregado, entidades subordinadas, objetos de valor inmutables, servicios de cálculo y puertos de persistencia; y el Diagrama de Base de Datos, que formaliza el esquema físico relacional en PostgreSQL 16 con aislamiento multi-inquilino, restricciones de integridad referencial e índices B-Tree optimizados para entornos de alta concurrencia.

##### 2.6.4.6.1. *Bounded Context Domain Layer Class Diagrams*

El modelado estático de la Capa de Dominio del Bounded Context Workshop Operations (MRO) establece las estructuras de datos y contratos en memoria que gobiernan los flujos de reparación vehicular en taller. Su concepción sigue rigurosamente los principios de Clean Architecture y Domain-Driven Design táctico, erradicando la obsesión por tipos primitivos mediante identificadores fuertemente tipados, centralizando la consistencia transaccional en la raíz de agregado principal y preservando la pureza del dominio al excluir dependencias de persistencia relacional o frameworks web.

En la @fig:class-diagram-mro se expone el Diagrama de Clases UML detallado para la Capa de Dominio del Bounded Context Workshop Operations (MRO), modelado conforme al estándar UML y compilado mediante la herramienta PlantUML bajo el enfoque de Diagram-as-Code.

![Diagrama de Clases UML de la Capa de Dominio para el Bounded Context Workshop Operations (MRO)](report/assets/class-diagrams/class-diagram-mro.png){#fig:class-diagram-mro}

*Nota.* Elaboración propia en base al diseño táctico de dominio y el estándar UML en PlantUML.

La organización interna del diagrama se estructura en ocho paquetes lógicos que agrupan las responsabilidades tácticas del subsistema operativo de taller:

- **Raíces de Agregado (`operations.domain.model.aggregates`):** Modela las entidades principales que delimitan las fronteras transaccionales: **WorkOrder** para la gestión integral de la orden de servicio automotriz; **WorkBay** para el control de aforo y ocupación física de puestos de trabajo; y **Service** para el catálogo maestro de tarifas estándar de mano de obra. Todas las raíces heredan de **AbstractDomainAggregateRoot<T>**.
- **Entidades Internas (`operations.domain.model.entities`):** Define las entidades dependientes subordinadas al ciclo de vida de la orden: **WorkOrderTask** para las intervenciones técnicas individuales en foso; **WorkOrderTaskProduct** para la cuantificación de repuestos demandados; **TaskProposal** para averías imprevistas detectadas en inspección; y **WorkOrderImage** junto a **WorkOrderTaskImage** para la custodia de evidencias fotográficas.
- **Identificadores Fuertemente Tipados (`operations.domain.model.ids`):** Implementa la interfaz **TypedId<UUID>** mediante registros inmutables (**WorkOrderId**, **WorkOrderTaskId**, **WorkOrderTaskProductId**, **WorkBayId**, **ServiceId**), incorporando referencias foráneas inmutables a los agregados externos (**TenantId**, **BranchId**, **AppointmentId**, **VehicleId**, **CustomerId**).
- **Objetos de Valor Operativos (`operations.domain.model.valueobjects`):** Encapsula conceptos inmutables como el número correlativo de orden (**WorkOrderNumber**), el kilometraje de odómetro (**Mileage**), el resumen de fallas (**DiagnosticSummary**), las horas técnicas (**LaborHours**), las existencias (**Quantity**), el localizador fotográfico (**StorageUrl**) y la magnitud financiera (**Money**).
- **Enumeraciones de Dominio (`operations.domain.model.enums`):** Estandariza los estados de ciclo de vida y modalidades de faena (**WorkOrderStatus**, **WorkOrderTaskStatus**, **HoldReason**, **BayType**, **BayStatus**, **ProposalSeverity**, **ProposalStatus**, **EvidenceType**).
- **Servicios de Dominio (`operations.domain.services`):** Incorpora lógica de negocio pura sin estado que opera sobre múltiples entidades: **WorkOrderCostCalculator** para el cálculo financiero de mano de obra, repuestos e impuestos; **BayAllocationService** para la verificación de aforo y compatibilidad de estaciones; y **WorkOrderTransitionValidator** para la validación de precondiciones de cierre.
- **Puertos de Persistencia (`operations.domain.repositories`):** Establece los contratos de persistencia pura (**WorkOrderRepository**, **WorkBayRepository**, **ServiceRepository**) desacoplados de cualquier infraestructura ORM o tecnología relacional.
- **Jerarquía de Excepciones Semánticas (`operations.domain.exceptions`):** Provee doce clases no comprobadas que heredan de **DomainException**, asignando códigos de error legibles y deterministas para incidentes de aforo, transiciones ilegales o recursos no encontrados.

En la @tbl:mro-domain-classes-members se detalla la especificación formal de atributos, firmas de métodos, modificadores de acceso y reglas de negocio para cada elemento de la Capa de Dominio.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo exhaustivo de clases, miembros, ámbitos y relaciones de la Capa de Dominio del Bounded Context Workshop Operations (MRO)} \label{tbl:mro-domain-classes-members} \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} WorkOrder} \\*
\hline
Atributos & Raíz de agregado principal. Modela la orden de trabajo automotriz y custodia la consistencia de labores, repuestos y peritaje. Generalización de \texttt{AbstractDomainAggregateRoot<\allowbreak WorkOrderId>\allowbreak }. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{WorkOrderId id} \newline - \texttt{TenantId tenantId} \newline - \texttt{BranchId branchId} \newline - \texttt{AppointmentId appointmentId} \newline - \texttt{VehicleId vehicleId} \newline - \texttt{CustomerId customerId} \newline - \texttt{WorkOrderNumber internalNumber} \newline - \texttt{WorkBayId currentBayId} \newline - \texttt{Mileage mileageIn} \newline - \texttt{DiagnosticSummary diagnosticSummary} \newline - \texttt{Money subtotal} \newline - \texttt{Money tax} \newline - \texttt{Money totalAmount} \newline - \texttt{WorkOrderStatus status} \newline - \texttt{List<\allowbreak WorkOrderTask>\allowbreak  tasks} \newline - \texttt{List<\allowbreak TaskProposal>\allowbreak  proposals} \newline - \texttt{List<\allowbreak WorkOrderImage>\allowbreak  intakeImages} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos factoría y ciclo & Invariantes: estado inicial DRAFT. Kilometraje no negativo. Vinculación y liberación atómica de bahía física. Cancelación y cobranza formal. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{WorkOrder create(...)} \newline - \texttt{void assignWorkBay(WorkBayId)} \newline - \texttt{void releaseBay()} \newline - \texttt{void startWork()} \newline - \texttt{void markPaid()} \newline - \texttt{void deliverVehicle()} \newline - \texttt{void cancel(String)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Labores y repuestos & Composición 1 a 0..* con \textbf{WorkOrderTask}. Gestión de tareas, demanda de repuestos hacia inventario y recálculo determinista de totales con IGV 18\%. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{WorkOrderTask addTask(...)} \newline - \texttt{void removeTask(WorkOrderTaskId)} \newline - \texttt{void startTask(WorkOrderTaskId)} \newline - \texttt{void completeTask(WorkOrderTaskId,\allowbreak  LaborHours)} \newline - \texttt{void addProductToTask(...)} \newline - \texttt{void removeProductFromTask(...)} \newline - \texttt{void attachIntakeImage(...)} \newline - \texttt{void recalculateTotalAmount()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Propuestas periciales & Composición 1 a 0..* con \textbf{TaskProposal}. Registro de hallazgos del técnico en foso, aprobación comercial con cotización o rechazo con justificación. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{TaskProposal submitProposal(...)} \newline - \texttt{WorkOrderTask approveProposal(...)} \newline - \texttt{void rejectProposal(UUID,\allowbreak  String)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} WorkBay} \\*
\hline
Atributos & Raíz de agregado de puesto de trabajo físico en taller. Modela elevadores, fosos de alineamiento y cabinas de pintura. Generalización de \texttt{AbstractDomainAggregateRoot<\allowbreak WorkBayId>\allowbreak }. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{WorkBayId id} \newline - \texttt{TenantId tenantId} \newline - \texttt{BranchId branchId} \newline - \texttt{String name} \newline - \texttt{BayType type} \newline - \texttt{BayStatus status} \newline - \texttt{WorkOrderId currentWorkOrderId} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos operativos & Invariantes: estado inicial AVAILABLE. Exclusión mutua de ocupación vehicular. Inhabilitación por mantenimiento preventivo. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{WorkBay create(TenantId,\allowbreak  BranchId,\allowbreak  String,\allowbreak  BayType)} \newline - \texttt{void occupy(WorkOrderId)} \newline - \texttt{void release()} \newline - \texttt{void setUnderMaintenance(String)} \newline - \texttt{void restoreAvailable()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Service} \\*
\hline
Atributos y métodos & Raíz de agregado del catálogo de servicios de taller. Fija tarifas base sugeridas de mano de obra y tiempos estándar de ejecución. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{ServiceId id} \newline - \texttt{TenantId tenantId} \newline - \texttt{String name} \newline - \texttt{Money basePrice} \newline - \texttt{int estimatedDurationMinutes} \newline - \texttt{Service create(...)} \newline - \texttt{void updateDetails(String,\allowbreak  Money,\allowbreak  int)} \\*
\hline
\textbf{Ámbito} & Privado / Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} WorkOrderTask} \\*
\hline
Atributos & Entidad dependiente de labor mecánica individual. Asignada a un técnico y sujeta a estados de faena, suspensiones y control de tiempos efectivos. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{WorkOrderTaskId id} \newline - \texttt{WorkOrderId workOrderId} \newline - \texttt{ServiceId serviceId} \newline - \texttt{UUID mechanicId} \newline - \texttt{WorkOrderTaskStatus status} \newline - \texttt{String description} \newline - \texttt{Money price} \newline - \texttt{LaborHours estimatedHours} \newline - \texttt{LaborHours actualHours} \newline - \texttt{HoldReason holdReason} \newline - \texttt{String missingItemDescription} \newline - \texttt{Instant pausedAt} \newline - \texttt{Long totalPausedSeconds} \newline - \texttt{Instant startedAt} \newline - \texttt{Instant completedAt} \newline - \texttt{List<\allowbreak WorkOrderTaskProduct>\allowbreak  consumedProducts} \newline - \texttt{List<\allowbreak WorkOrderTaskImage>\allowbreak  taskImages} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Operaciones de faena y pausas & Transición controlada a ON\_HOLD por causal WAITING\_PARTS. Acumula tiempo de inactividad involuntaria para cálculo equitativo de Wrench Time. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{void assignMechanic(UUID)} \newline - \texttt{void start()} \newline - \texttt{void holdForWaitingParts(String)} \newline - \texttt{void resume()} \newline - \texttt{void complete(LaborHours)} \newline - \texttt{void reopen()} \newline - \texttt{void updatePrice(Money)} \newline - \texttt{void addProduct(WorkOrderTaskProduct)} \newline - \texttt{void removeProduct(WorkOrderTaskProductId)} \newline - \texttt{void attachEvidenceImage(...)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} WorkOrderTaskProduct} \\*
\hline
Atributos y métodos & Entidad dependiente de consumo de repuestos e insumos en foso. Cuantifica piezas demandadas y subtotaliza costos según precio unitario. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{WorkOrderTaskProductId id} \newline - \texttt{WorkOrderTaskId taskId} \newline - \texttt{UUID productId} \newline - \texttt{Quantity quantity} \newline - \texttt{Money unitPrice} \newline - \texttt{Money totalAmount} \newline - \texttt{void updateQuantity(Quantity)} \\*
\hline
\textbf{Ámbito} & Privado / Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} TaskProposal} \\*
\hline
Atributos y métodos & Entidad dependiente de hallazgo pericial en foso. Captura evidencia fotográfica y severidad de averías ocultas para concertación comercial con el cliente. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{UUID id} \newline - \texttt{WorkOrderId workOrderId} \newline - \texttt{WorkOrderTaskId taskId} \newline - \texttt{ServiceId serviceId} \newline - \texttt{UUID mechanicId} \newline - \texttt{String description} \newline - \texttt{ProposalSeverity severity} \newline - \texttt{StorageUrl imageUrl} \newline - \texttt{ProposalStatus status} \newline - \texttt{String customerNotes} \newline - \texttt{void approve(String)} \newline - \texttt{void reject(String)} \\*
\hline
\textbf{Ámbito} & Privado / Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} WorkOrderImage, WorkOrderTaskImage} \\*
\hline
Atributos y métodos & Entidades multimedia bajo el patrón Direct-to-Cloud. Almacenan referencias inmutables StorageUrl validadas contra Google Cloud Storage. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{UUID id} \newline - \texttt{StorageUrl imageUrl} \newline - \texttt{EvidenceType evidenceType} \newline - \texttt{String description} \newline - \texttt{Instant uploadedAt} \newline - \texttt{StorageUrl imageUrl()} \\*
\hline
\textbf{Ámbito} & Privado / Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} WorkOrderId, WorkOrderTaskId, WorkOrderTaskProductId, WorkBayId, ServiceId} \\*
\hline
Atributo value y factoría & Registros inmutables que realizan la interfaz \texttt{TypedId<\allowbreak UUID>\allowbreak }, erradicando la obsesión por tipos primitivos en identidades de operaciones. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{UUID value} \newline - \texttt{of(UUID)} \\*
\hline
\textbf{Ámbito} & Privado / Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} WorkOrderNumber, Mileage, DiagnosticSummary, LaborHours, Quantity, StorageUrl} \\*
\hline
Atributos y validaciones & Objetos de valor inmutables. \textbf{WorkOrderNumber} valida formato WO-YYYYMM-XXXX. \textbf{Mileage} odómetro no negativo. \textbf{LaborHours} y \textbf{Quantity} valores positivos con escala decimal fija. \textbf{StorageUrl} URL HTTPS segura. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{String value} \newline - \texttt{Integer value} \newline - \texttt{BigDecimal value} \newline - \texttt{boolean isValid()} \\*
\hline
\textbf{Ámbito} & Privado / Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Enumeraciones de Dominio de Workshop Operations} \\*
\hline
Valores constantes & Tipos enumerados que gobiernan estados de orden (**WorkOrderStatus**), labores (**WorkOrderTaskStatus**), causas de suspensión (**HoldReason**), estaciones (**BayType**, **BayStatus**), severidad y aprobación (**ProposalSeverity**, **ProposalStatus**) y tipos periciales (**EvidenceType**). \\*
\hline
\textbf{Firma o Tipo} & \texttt{Enumeraciones de dominio} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} WorkOrderCostCalculator, BayAllocationService, WorkOrderTransitionValidator} \\*
\hline
Servicios de dominio & Lógica pura sin estado. Totaliza costos con IGV 18\% bancario RoundingMode.HALF\_EVEN, valida exclusión mutua de bahías y fiscaliza precondiciones de cierre de órdenes. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Money calculateTotal(WorkOrder)} \newline - \texttt{Result<\allowbreak Void,\allowbreak  DomainException>\allowbreak  validateBayAvailability(...)} \newline - \texttt{Result<\allowbreak Void,\allowbreak  DomainException>\allowbreak  validateTransition(...)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} WorkOrderRepository, WorkBayRepository, ServiceRepository} \\*
\hline
Firmas de acceso persistente & Puertos secundarios para operaciones de persistencia agnóstica de órdenes, asignación de bahías y consulta tarifaria de catálogo. \\*
\hline
\textbf{Firma o Tipo} & \texttt{Interfaces de repositorio} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Jerarquía de Excepciones de Dominio} \\*
\hline
Constructores tipados & Doce excepciones no comprobadas derivadas de \texttt{DomainException} que encapsulan códigos semánticos legibles para respuestas RFC 7807 ante colisiones de aforo o estados inválidos. \\*
\hline
\textbf{Firma o Tipo} & Subclases de \texttt{DomainException} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Elaboración propia en base al diseño táctico de dominio y la especificación UML de la solución.

A partir del modelo estático ilustrado en la @fig:class-diagram-mro y formalizado en la @tbl:mro-domain-classes-members, se identifican tres fundamentos de ingeniería de software que consolidan la robustez y pureza del subsistema operativo:

- **Determinismo Financiero e Invariantes Tributarias en Memoria:**
  El cálculo del costo total de las órdenes de servicio se centraliza en el servicio de dominio **WorkOrderCostCalculator**, garantizando que la adición de horas hombre de mano de obra y el consumo de repuestos se sumen de forma atómica. La aplicación de la alícuota fiscal del 18\% mediante el modo de redondeo bancario de mitad al par (*RoundingMode.HALF_EVEN*) erradica la discrepancia por acumulación de centavos residuales, asegurando concordancia matemática exacta con los comprobantes emitidos ante la administración tributaria.

- **Trazabilidad Pericial y Desacoplamiento Multimedia Direct-to-Cloud:**
  La captura fotográfica de evidencias vehiculares en los agregados **WorkOrder** y **WorkOrderTask** se articula mediante el objeto de valor **StorageUrl**, abstrayéndose de la transferencia física de binarios pesados a través del servidor backend. Al delegar la subida directa hacia Google Cloud Storage mediante credenciales prefirmadas temporales, la memoria heap de la API permanece libre de congestión, permitiendo procesar peritajes gráficos de alta resolución sin degradar el rendimiento de transacciones concurrentes.

- **Máquinas de Estados Finitos y Auditoría Equitativa de Rendimiento Técnico:**
  La transición de las labores en foso hacia el estado suspendido por falta de repuestos (*WAITING_PARTS*) congela automáticamente el cómputo de horas hombre efectivas mediante el acumulador inmutable de segundos en pausa. Este mecanismo previene que las demoras logísticas atribuibles a proveedores o almacén penalicen el tiempo de llave (*Wrench Time*) del mecánico, preservando la fidelidad de las métricas de productividad operativa y los incentivos salariales del taller.

##### 2.6.4.6.2. *Bounded Context Database Design Diagram*

La persistencia del Bounded Context Workshop Operations materializa el modelo operacional mediante una arquitectura relacional distribuida en dos motores complementarios. El repositorio central en PostgreSQL 16 garantiza la consistencia transaccional ACID, el aislamiento multi-inquilino de las órdenes de servicio y la imputación financiera de costos, mientras que el motor local SQLite 3 confiere autonomía operativa en la aplicación móvil para faenas mecánicas en fosos y patios sin cobertura inalámbrica.

En la @fig:database-diagram-mro se presenta el Diagrama Entidad-Relación físico para la persistencia del Bounded Context Workshop Operations en sus dos entornos operativos de despliegue: el repositorio central PostgreSQL 16 de la API de backend y el motor relacional local SQLite 3 de la aplicación móvil de taller.

![Diagrama Entidad-Relación de Base de Datos para el Bounded Context Workshop Operations (PostgreSQL 16 y SQLite 3)](report/assets/database-diagrams/database-diagram-mro.png){#fig:database-diagram-mro}

*Nota.* Elaboración propia en base al diseño físico de persistencia y el estándar PlantUML ERD.

A partir del modelo entidad-relación ilustrado, la arquitectura de datos se descompone en cuatro subsistemas relacionales especializados:

- **Subsistema de Infraestructura Física de Bahías y Catálogo Operativo:**
  Estructura los puestos físicos de trabajo en taller (**work_bays**) y el catálogo estandarizado de prestaciones de mano de obra (**services**), subordinados a la partición organizacional del taller mediante la clave foránea **tenant_id**. La tabla de bahías modela elevadores, cabinas de pintura, zonas de lavado y fosos de alineamiento vinculados a cada sede (**branch_id**), incorporando restricciones de verificación sobre su estado operativo para asegurar la exclusión mutua durante la asignación vehicular.

- **Subsistema Transaccional de Órdenes de Servicio y Peritaje Multimedia:**
  Custodia la entidad central de faena (**work_orders**) y su documentación fotográfica de recepción y entrega (**work_order_images**). La orden articula referencias foráneas hacia el cliente solicitante, el vehículo atendido, la bahía de estacionamiento y la cita previa opcional. Preserva subtotales financieros calculados, kilometraje de entrada y diagnóstico preliminar, complementándose con registros multimedia desacoplados bajo el patrón Direct-to-Cloud que almacenan referencias seguras hacia almacenamiento en la nube sin sobrecargar la base de datos con binarios.

- **Subsistema de Ejecución Técnica, Consumo de Repuestos y Propuestas de Foso:**
  Gobierna el desglose granular de intervenciones mecánicas (**work_order_tasks**), la demanda de repuestos e insumos de almacén (**work_order_task_products**), las evidencias fotográficas de labor (**work_order_task_images**) y las averías imprevistas detectadas en foso (**task_proposals**). Cada tarea registra tiempos reales de ejecución y pausas por abastecimiento, mientras que la tabla de productos vincula los insumos al catálogo de inventario para deducción contable FIFO. A su vez, las propuestas periciales formalizan hallazgos mecánicos adicionales requiriendo aprobación formal antes de incorporarse a la cotización final.

- **Persistencia Desconectada y Buffer de Mutaciones en SQLite 3:**
  Garantiza la continuidad operativa en la aplicación móvil de taller desplegada en dispositivos de operarios mediante las tablas locales **local_bays_cache**, **local_work_orders_cache**, **local_tasks_cache**, **offline_pit_mutations** y **offline_pending_evidences**. Este esquema local almacena réplicas ligeras de consulta inmediata y encola de manera transaccional las mutaciones de inicio, pausa y culminación de faena, así como la cola de fotografías periciales tomadas en foso sin señal inalámbrica, garantizando sincronización confiable hacia el backend central mediante reintentos exponenciales.

A partir de la arquitectura relacional definida en el diagrama de persistencia, en la @tbl:mro-database-objects se cataloga la totalidad de las tablas y objetos físicos que conforman el modelo de datos, detallando el producto donde residen, sus atributos cardinales, restricciones de integridad, estrategias de indexación y su contribución al aislamiento de información.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.1cm} | >{\raggedright\arraybackslash}p{10.3cm} |}
\caption{Catálogo exhaustivo de tablas, objetos de base de datos, restricciones e índices físicos del Bounded Context Workshop Operations} \label{tbl:mro-database-objects} \\
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{work\_orders}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Tabla transaccional central de la orden de servicio automotriz. Custodia montos financieros calculados, odómetro de ingreso, bahía física asignada y ciclo de vida integral con aislamiento estricto por tenant\_id. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{tenant\_id (UUID)}, \texttt{branch\_id (UUID)}, \texttt{appointment\_id (UUID)}, \texttt{vehicle\_id (UUID)}, \texttt{customer\_id (UUID)}, \texttt{internal\_number (INTEGER)}, \texttt{current\_bay\_id (UUID)}, \texttt{mileage\_in (INTEGER)}, \texttt{diagnostic\_summary (TEXT)}, \texttt{subtotal (DECIMAL)}, \texttt{tax (DECIMAL)}, \texttt{total\_amount (DECIMAL)}, \texttt{status (VARCHAR)}, auditoría transversal. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_work\_orders (id) \newline - FK: fk\_work\_orders\_tenant, fk\_work\_orders\_branch, fk\_work\_orders\_vehicle, fk\_work\_orders\_customer, fk\_work\_orders\_bay \newline - UK: uk\_work\_orders\_tenant\_number (tenant\_id, internal\_number) \newline - CHECK: chk\_order\_status \newline - Índices B-Tree: idx\_orders\_tenant\_branch\_status, idx\_orders\_vehicle, idx\_orders\_customer, idx\_orders\_bay parcial \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{work\_order\_tasks}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Entidad dependiente subordinada a la orden de trabajo. Modela la labor técnica individual asignada al mecánico, registrando tiempos efectivos de faena, cronometraje y suspensiones técnicas en foso. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{work\_order\_id (UUID)}, \texttt{service\_id (UUID)}, \texttt{mechanic\_id (UUID)}, \texttt{status (VARCHAR)}, \texttt{description (TEXT)}, \texttt{price (DECIMAL)}, \texttt{estimated\_hours (DECIMAL)}, \texttt{actual\_hours (DECIMAL)}, \texttt{hold\_reason (VARCHAR)}, \texttt{missing\_item\_description (TEXT)}, \texttt{paused\_at (TIMESTAMPTZ)}, \texttt{total\_paused\_seconds (BIGINT)}, auditoría técnica. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_work\_order\_tasks (id) \newline - FK: fk\_tasks\_work\_order hacia work\_orders, fk\_tasks\_service hacia services, fk\_tasks\_mechanic hacia tenant\_memberships \newline - CHECK: chk\_task\_status, chk\_hold\_reason \newline - Índices B-Tree: idx\_tasks\_work\_order, idx\_tasks\_mechanic\_status \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{work\_order\_task\_products}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Desglose de repuestos, lubricantes e insumos demandados por cada tarea mecánica. Su inserción genera reservas lógicas y deducciones contables FIFO coordinadas con inventario. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{task\_id (UUID)}, \texttt{product\_id (UUID)}, \texttt{quantity (DECIMAL)}, \texttt{unit\_price (DECIMAL)}, \texttt{total\_amount (DECIMAL)}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ).} \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_task\_products (id) \newline - FK: fk\_task\_products\_task hacia work\_order\_tasks, fk\_task\_products\_item hacia inventory\_items \newline - CHECK: chk\_products\_quantity (quantity > 0.00), chk\_products\_total (total\_amount >= 0.00) \newline - Índices B-Tree: idx\_task\_products\_task, idx\_task\_products\_product \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{work\_order\_images}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Registro de peritaje fotográfico de recepción vehicular y entrega bajo el patrón Direct-to-Cloud, almacenando únicamente URLs seguras de Firebase Storage sin saturar la base relacional con binarios pesados. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{work\_order\_id (UUID)}, \texttt{image\_url (VARCHAR)}, \texttt{description (VARCHAR)}, \texttt{uploaded\_at (TIMESTAMPTZ)}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ).} \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_work\_order\_images (id) \newline - FK: fk\_images\_work\_order hacia work\_orders \newline - Índice B-Tree: idx\_images\_work\_order (work\_order\_id) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{work\_order\_task\_images}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Evidencias técnicas de peritaje en foso (piezas desgastadas versus repuestos nuevos instalados), tipificadas por fase operativa para transparencia ante auditorías periciales y peritajes de aseguradoras. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{task\_id (UUID)}, \texttt{image\_url (VARCHAR)}, \texttt{evidence\_type (VARCHAR)}, \texttt{description (VARCHAR)}, \texttt{uploaded\_at (TIMESTAMPTZ)}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ).} \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_task\_images (id) \newline - FK: fk\_task\_images\_task hacia work\_order\_tasks \newline - CHECK: chk\_evidence\_type \newline - Índice B-Tree: idx\_task\_images\_task (task\_id) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{task\_proposals}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Modela averías imprevistas detectadas por el mecánico durante la labor en foso. Permite concertación comercial sin alterar la orden de trabajo hasta recibir la aprobación formal del cliente. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{work\_order\_id (UUID)}, \texttt{task\_id (UUID)}, \texttt{service\_id (UUID)}, \texttt{mechanic\_id (UUID)}, \texttt{description (TEXT)}, \texttt{severity (VARCHAR)}, \texttt{image\_url (VARCHAR)}, \texttt{status (VARCHAR)}, \texttt{customer\_notes (VARCHAR)}, auditoría transversal. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_task\_proposals (id) \newline - FK: fk\_proposals\_order, fk\_proposals\_task, fk\_proposals\_service, fk\_proposals\_mechanic \newline - CHECK: chk\_proposal\_severity, chk\_proposal\_status \newline - Índices B-Tree: idx\_proposals\_work\_order, idx\_proposals\_status \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{work\_bays}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Modela los puestos físicos de trabajo en taller (elevadores, cabinas de pintura y fosos de alineamiento). Garantiza exclusión mutua de asignación y control de aforo por sede física con aislamiento multi-inquilino. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{tenant\_id (UUID)}, \texttt{branch\_id (UUID)}, \texttt{name (VARCHAR)}, \texttt{type (VARCHAR)}, \texttt{status (VARCHAR)}, auditoría transversal y control de versiones. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_work\_bays (id) \newline - FK: fk\_work\_bays\_tenant\_id hacia tenants, fk\_work\_bays\_branch\_id hacia branches \newline - CHECK: chk\_bay\_type, chk\_bay\_status \newline - Índices B-Tree: idx\_work\_bays\_tenant\_branch, idx\_work\_bays\_status \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{services}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Catálogo maestro de servicios estándar y tarifas de mano de obra del taller automotriz. Soporta cotización uniforme y tiempos estimados de faena con aislamiento por taller. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{tenant\_id (UUID)}, \texttt{name (VARCHAR)}, \texttt{base\_price (DECIMAL)}, \texttt{estimated\_time\_m (INTEGER)}, auditoría transversal y control de versiones. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_services (id) \newline - FK: fk\_services\_tenant hacia tenants \newline - UK: uk\_services\_tenant\_name (tenant\_id, name) \newline - CHECK: chk\_service\_price (base\_price >= 0.00), chk\_service\_duration (estimated\_time\_m > 0) \newline - Índice B-Tree: idx\_services\_tenant\_name \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{local\_work\_orders\_cache}} \\*
\hline
\textbf{Motor y Producto} & SQLite 3 (Mobile Workshop) \\*
\hline
\textbf{Propósito y Aislamiento} & Caché local desconectado de órdenes de trabajo activas en la sucursal física. Permite al técnico consultar la ficha operativa completa sin requerir conexión a internet. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{order\_id (TEXT)}, \texttt{tenant\_id (TEXT)}, \texttt{branch\_id (TEXT)}, \texttt{internal\_number (TEXT)}, \texttt{vehicle\_plate (TEXT)}, \texttt{vehicle\_brand\_model (TEXT)}, \texttt{customer\_name (TEXT)}, \texttt{current\_bay\_id (TEXT)}, \texttt{bay\_name (TEXT)}, \texttt{status (TEXT)}, \texttt{diagnostic\_summary (TEXT)}, \texttt{mileage\_in (INTEGER)}, \texttt{total\_amount (REAL)}, \texttt{synced\_at (TEXT).} \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_local\_orders (order\_id) \newline - Índice B-Tree: idx\_local\_orders\_branch\_status (branch\_id, status) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{local\_tasks\_cache}} \\*
\hline
\textbf{Motor y Producto} & SQLite 3 (Mobile Workshop) \\*
\hline
\textbf{Propósito y Aislamiento} & Almacenamiento local de tareas mecánicas asignadas al técnico autenticado. Permite conmutar estados de labor, registrar pausas y cronometrar faena en tiempo real en fosos sin red. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{task\_id (TEXT)}, \texttt{work\_order\_id (TEXT)}, \texttt{service\_name (TEXT)}, \texttt{mechanic\_id (TEXT)}, \texttt{status (TEXT)}, \texttt{description (TEXT)}, \texttt{estimated\_hours (REAL)}, \texttt{actual\_hours (REAL)}, \texttt{hold\_reason (TEXT)}, \texttt{missing\_item\_description (TEXT)}, \texttt{paused\_at (TEXT)}, \texttt{total\_paused\_seconds (INTEGER)}, \texttt{synced\_at (TEXT).} \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_local\_tasks (task\_id) \newline - Índices B-Tree: idx\_local\_tasks\_order, idx\_local\_tasks\_mechanic \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{local\_bays\_cache}} \\*
\hline
\textbf{Motor y Producto} & SQLite 3 (Mobile Workshop) \\*
\hline
\textbf{Propósito y Aislamiento} & Directorio local de bahías físicas y su estado de ocupación actual. Facilita la verificación inmediata de puestos libres y reubicación vehicular en patio de maniobras. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{bay\_id (TEXT)}, \texttt{tenant\_id (TEXT)}, \texttt{branch\_id (TEXT)}, \texttt{name (TEXT)}, \texttt{type (TEXT)}, \texttt{status (TEXT)}, \texttt{current\_work\_order\_id (TEXT)}, \texttt{synced\_at (TEXT).} \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_local\_bays (bay\_id) \newline - Índice B-Tree: idx\_local\_bays\_branch (branch\_id) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{offline\_pit\_mutations}} \\*
\hline
\textbf{Motor y Producto} & SQLite 3 (Mobile Workshop) \\*
\hline
\textbf{Propósito y Aislamiento} & Cola transaccional persistente de mutaciones ejecutadas por el mecánico en foso (inicios, pausas y culminaciones). Garantiza entrega At-Least-Once mediante drenaje asíncrono e idempotente. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{mutation\_id (TEXT)}, \texttt{work\_order\_id (TEXT)}, \texttt{task\_id (TEXT)}, \texttt{action\_type (TEXT)}, \texttt{payload (TEXT JSON)}, \texttt{status (TEXT)}, \texttt{retry\_count (INTEGER)}, \texttt{created\_at (TEXT)}, \texttt{synced\_at (TEXT).} \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_pit\_mutations (mutation\_id) \newline - CHECK: chk\_mutation\_status \newline - Índice B-Tree: idx\_pit\_mutations\_status (status, created\_at) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{offline\_pending\_evidences}} \\*
\hline
\textbf{Motor y Producto} & SQLite 3 (Mobile Workshop) \\*
\hline
\textbf{Propósito y Aislamiento} & Buffer local de fotografías periciales tomadas por el técnico. Gestiona la subida asíncrona hacia Firebase Storage mediante credenciales temporales antes de notificar la mutación técnica. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{evidence\_id (TEXT)}, \texttt{task\_id (TEXT)}, \texttt{local\_file\_path (TEXT)}, \texttt{target\_storage\_path (TEXT)}, \texttt{evidence\_type (TEXT)}, \texttt{upload\_status (TEXT)}, \texttt{signed\_url (TEXT)}, \texttt{created\_at (TEXT).} \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_pending\_evidences (evidence\_id) \newline - CHECK: chk\_upload\_status \newline - Índice B-Tree: idx\_evidences\_status (upload\_status) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{auditable\_abstract\_entity}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Superclase JPA (@MappedSuperclass) que confiere identidad técnica, aislamiento multi-inquilino obligatorio y auditoría temporal heredada por las tablas maestras de operaciones. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{tenant\_id (UUID)}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ)}, \texttt{version (BIGINT)}, \texttt{deleted\_at (TIMESTAMPTZ).} \\*
\hline
\textbf{Constraints e Índices} & - PK técnica: pk\_auditable\_entity (id) \newline - FK lógica: tenant\_id. Superclase MappedSuperclass JPA con bloqueo optimista \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Elaboración propia en base al diseño relacional y la especificación física de persistencia.

A partir de la estructura formalizada en la @fig:database-diagram-mro y la @tbl:mro-database-objects, se identifican tres fundamentos de ingeniería de software que respaldan la solidez, integridad y resiliencia de la persistencia:

- **Particionamiento Lógico Multi-Inquilino y Control de Concurrencia Optimista en Taller:**
  La segregación de la información operativa en PostgreSQL 16 se asegura mediante la inclusión mandatoria de la clave foránea **tenant_id** en las tablas maestras **work_orders**, **work_bays** y **services**, complementada por el control de concurrencia optimista a través de la columna **version**. Esta estrategia previene que modificaciones simultáneas sobre una misma orden de servicio por parte del asesor comercial y el jefe de taller generen inconsistencias financieras o sobrescritura destructiva de diagnósticos preliminares.

- **Integridad Transaccional ACID y Deducción Contable de Repuestos en Inventario:**
  La vinculación entre las labores mecánicas en **work_order_tasks** y los insumos materiales en **work_order_task_products** se sustenta en restricciones de integridad referencial que previenen consumos huérfanos. La inserción de líneas de producto dentro de una tarea en ejecución coordina eventos transaccionales hacia el módulo de almacén, asegurando que la reserva física de repuestos y la aplicación del método contable FIFO se ejecuten bajo consistencia atómica, respaldando la concordancia entre los costos liquidados y la existencia física en almacén.

- **Resiliencia Operacional Desconectada en Foso y Desacoplamiento Multimedia:**
  La coexistencia del repositorio central con la base de datos local SQLite 3 en los terminales móviles de taller garantiza la continuidad de la faena mecánica en zonas sin cobertura de red inalámbrica [@herrera2026offline]. Mediante las estructuras **offline_pit_mutations** y **offline_pending_evidences**, la aplicación móvil retiene las acciones de inicio y pausa de tareas junto con los archivos periciales en almacenamiento local. Al detectar la recuperación de conectividad, el motor de sincronización despacha los binarios directamente a Firebase Storage mediante URLs firmadas y procesa las mutaciones en el backend central con reintentos idempotentes y políticas de reconciliación determinista [@korichi2026dmrp].

### 2.6.5. *Bounded Context: Inventory & Supply Chain*

El Bounded Context de Inventory & Supply Chain gestiona el abastecimiento logístico, el control físico de existencias y la valuación de almacén en Atelier Platform. Su alcance abarca la administración del catálogo de repuestos, lubricantes e insumos mecánicos, la valuación de inventario bajo el método contable de costeo FIFO (*First-In, First-Out*) por lotes físicos de adquisición, el directorio comercial de proveedores y la orquestación de órdenes de compra con control documental.

En la industria del mantenimiento y reparación automotriz, la gestión deficiente de almacenes constituye una de las principales causas de pérdida de rentabilidad y fuga silenciosa de capital. Muchos talleres tradicionales operan sin un método estandarizado de costeo de inventario, aplicando precios promedio empíricos o asumiendo el último costo de compra reportado. Esta práctica desvirtúa el cálculo del margen real de beneficio, especialmente en contextos inflacionarios donde el costo de adquisición de repuestos automotrices fluctúa constantemente.

Para erradicar esta vulnerabilidad financiera, Atelier implementa a nivel de dominio el algoritmo de asignación y costeo FIFO mediante la raíz de agregado `InventoryItem` y sus entidades dependientes `InventoryBatch`. Cada lote físico recibido almacena su fecha de ingreso, su costo unitario de compra inalterable y su saldo remanente disponible. Cuando una orden de trabajo consume repuestos, el motor algorítmico del dominio deduce las existencias agotando prioritariamente los lotes de adquisición más antiguos, garantizando que el costo de venta liquidado en la orden MRO refleje el desembolso financiero histórico real del taller.

Adicionalmente, el contexto modela el ciclo de reabastecimiento a través de las raíces de agregado `Supplier` (directorio de distribuidores y fabricantes) y `PurchaseOrder` (órdenes formales de compra con desglose de ítems cotizados). La recepción física de una orden de compra aprobada desencadena automáticamente el alta de nuevos lotes en los ítems de inventario correspondientes, asegurando trazabilidad integral de compra a consumo.

#### 2.6.5.1. Domain Layer

La Capa de Dominio de Inventory & Supply Chain constituye el núcleo logístico y financiero de materiales de Atelier Platform, implementada bajo el paquete canónico com.andeva.atelier.platform.inventory.domain. Su propósito arquitectónico es gobernar con máxima pureza y determinismo la existencia física de repuestos, lubricantes y consumibles, aislando las reglas de costeo y abastecimiento respecto a los mecanismos de persistencia relacional y protocolos de transporte.

Para asegurar la rentabilidad contable y el abastecimiento continuo en las estaciones de servicio, la arquitectura de dominio se estructura sobre cuatro pilares tácticos esenciales:
- Valuación contable estricta y determinismo financiero mediante el algoritmo FIFO por lotes físicos de adquisición.
- Trazabilidad documental probatoria con enlace Direct-to-Cloud hacia comprobantes fiscales de compra en almacenamiento seguro.
- Aislamiento multi-inquilino del catálogo de repuestos y padrón homologado de proveedores con validación formal de RUC ante SUNAT.
- Coordinación transaccional desacoplada con las órdenes de trabajo mecánicas (MRO) mediante eventos de reserva y consumo atómico.

En la @tbl:inventory-domain-types se presenta el catálogo consolidado de los componentes que integran la Capa de Dominio de Inventory & Supply Chain.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo de la Capa de Dominio del Bounded Context Inventory \& Supply Chain} \label{tbl:inventory-domain-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\
\hline
\endhead
InventoryItem & Raíz de consistencia del catálogo de piezas y existencias. Custodia precios de venta sugeridos, existencias totales consolidadas y lotes físicos de abastecimiento. \\*
\hline
\textbf{Categoría} & Raíz de Agregado \\*
\hline
\textbf{Relaciones} & Generalización de AbstractDomainAggregateRoot<InventoryItem>. Composición 1 a N con InventoryBatch. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak domain.\allowbreak model.\allowbreak aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
InventoryBatch & Lote físico de adquisición recibido en almacén. Encapsula el costo unitario de compra inalterable, fecha exacta de ingreso y saldo de existencias para consumo FIFO. \\*
\hline
\textbf{Categoría} & Entidad Dependiente \\*
\hline
\textbf{Relaciones} & Dependiente subordinada a InventoryItem. Vinculada opcionalmente a Supplier y PurchaseOrder. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak domain.\allowbreak model.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Supplier & Ficha del distribuidor o fabricante comercial de autopartes. Custodia la razón social, RUC de 11 dígitos homologado, contactos y vigencia comercial. \\*
\hline
\textbf{Categoría} & Raíz de Agregado \\*
\hline
\textbf{Relaciones} & Generalización de AbstractDomainAggregateRoot<Supplier>. Referencia a TenantId y TaxId. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak domain.\allowbreak model.\allowbreak aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PurchaseOrder & Orden formal de reabastecimiento emitida hacia un proveedor comercial. Gobierna la máquina de estados, el cómputo del costo total y la auditoría de comprobantes fiscales. \\*
\hline
\textbf{Categoría} & Raíz de Agregado \\*
\hline
\textbf{Relaciones} & Generalización de AbstractDomainAggregateRoot<PurchaseOrder>. Composición 1 a N con PurchaseOrderItem. Referencia a SupplierId y BranchId. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak domain.\allowbreak model.\allowbreak aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PurchaseOrderItem & Línea de detalle de compra adscrita a una orden formal. Asocia un repuesto específico con la cantidad pactada y el costo unitario de adquisición cotizado. \\*
\hline
\textbf{Categoría} & Entidad Dependiente \\*
\hline
\textbf{Relaciones} & Dependiente subordinada a PurchaseOrder. Referencia a InventoryItemId. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak domain.\allowbreak model.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
InventoryItemId & Identificador único universal fuertemente tipado para piezas y consumibles del catálogo. \\*
\hline
\textbf{Categoría} & Objeto de Valor (ID) \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
InventoryBatchId & Identificador único universal fuertemente tipado para lotes físicos de adquisición. \\*
\hline
\textbf{Categoría} & Objeto de Valor (ID) \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
SupplierId & Identificador único universal fuertemente tipado para proveedores comerciales de autopartes. \\*
\hline
\textbf{Categoría} & Objeto de Valor (ID) \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PurchaseOrderId & Identificador único universal fuertemente tipado para órdenes formales de adquisición. \\*
\hline
\textbf{Categoría} & Objeto de Valor (ID) \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PurchaseOrderItemId & Identificador único universal fuertemente tipado para renglones de órdenes de compra. \\*
\hline
\textbf{Categoría} & Objeto de Valor (ID) \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Sku & Código alfanumérico estandarizado de control de existencias normalizado en mayúsculas y único por taller. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Registro inmutable con expresión regular alfanumérica de 3 a 50 caracteres. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Quantity & Magnitud numérica decimal no negativa con escala fija a dos posiciones para control volumétrico y unitario. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Registro inmutable basado en BigDecimal con operaciones aritméticas protegidas. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
StockAllocation & Registro inmutable que transporta el resultado de una asignación FIFO con desglose de lotes y costo de ventas. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Estructura inmutable portadora de deducciones atómicas por lote y costo financiero consolidado. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
BatchDeduction & Detalle específico de las unidades consumidas de un lote particular y su costo unitario histórico. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Componente inmutable subordinado a StockAllocation. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
ItemCategory & Taxonomía funcional técnica para la clasificación operativa de partes y consumibles en taller. \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Define constantes como LUBRICANTS, BRAKES, SUSPENSION, ENGINE, ELECTRICAL, TIRES y FILTERS. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
InventoryItemStatus & Ciclo de vigencia comercial del repuesto dentro del catálogo operativo del taller mecánico. \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Define estados ACTIVE, INACTIVE y DISCONTINUED. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PurchaseOrderStatus & Máquina de estados determinista para el abastecimiento y recepción física de suministros. \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Define estados DRAFT, ISSUED, RECEIVED y CANCELED. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
FifoAllocationEngine & Servicio de asignación algorítmica secuencial que consume lotes por fecha cronológica ascendente y calcula el costo real de ventas. \\*
\hline
\textbf{Categoría} & Servicio de Dominio \\*
\hline
\textbf{Relaciones} & Coordina InventoryItem e InventoryBatch durante la reserva de materiales. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak domain.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
InventoryValuationService & Cómputo patrimonial financiero del inventario activo mediante valuación FIFO consolidada. \\*
\hline
\textbf{Categoría} & Servicio de Dominio \\*
\hline
\textbf{Relaciones} & Opera sobre colecciones de ítems y lotes del taller. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak domain.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
StockReorderEvaluationService & Monitoreo analítico de existencias frente a umbrales mínimos para sugerencia de reaprovisionamiento. \\*
\hline
\textbf{Categoría} & Servicio de Dominio \\*
\hline
\textbf{Relaciones} & Evalúa niveles de stock y proyecta demandas preventivas de compra. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak domain.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
InventoryItemRepository & Contrato agnóstico de persistencia para el catálogo maestro de repuestos y existencias. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Implementado en la capa de infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
InventoryBatchRepository & Contrato agnóstico de persistencia para consulta y auditoría cronológica de lotes físicos. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Implementado en la capa de infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
SupplierRepository & Contrato agnóstico de persistencia para el directorio homologado de proveedores de autopartes. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Implementado en la capa de infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PurchaseOrderRepository & Contrato agnóstico de persistencia para órdenes de compra y trazabilidad de recepción. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Implementado en la capa de infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak domain.\allowbreak repositories} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Catálogo de tipos tácticos que conforman el paquete canónico com.andeva.atelier.platform.inventory.domain.

**Raíz de Agregado InventoryItem y Control de Existencias**

La raíz de agregado **InventoryItem** encapsula la identidad física y comercial del repuesto o fluido automotriz, custodiando el código interno **Sku**, el precio de venta sugerido **basePrice** y el umbral de alerta **minimumStock**. El agregado mantiene la colección interna de lotes físicos **InventoryBatch**, garantizando como invariante fundamental que el atributo **totalStock** coincida siempre con la sumatoria exacta de las cantidades remanentes de todos sus lotes activos.

Asimismo, la entidad prohíbe alteraciones arbitrarias sobre el balance de existencias, obligando a canalizar los ingresos a través de *addBatch()* y las deducciones mediante *allocateStockFifo()*. Esta última operación evalúa existencias suficientes y consume secuencialmente los lotes más antiguos, calculando de forma inmutable el Costo de Mercadería Vendida acumulado y emitiendo alertas cuando el saldo resultante desciende por debajo del umbral de seguridad.

En la @tbl:inventory-item-members se detallan los atributos, firmas de operaciones y reglas de consistencia de la raíz de agregado **InventoryItem**.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de la Raíz de Agregado InventoryItem} \label{tbl:inventory-item-members} \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Raíz de Agregado:} InventoryItem (Frontera de Consistencia de Repuestos y Existencias)} \\*
\hline
id & Identificador unívoco universal del repuesto en el catálogo del taller. \\*
\hline
\textbf{Tipo o Firma} & \texttt{InventoryItemId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
tenantId & Taller automotriz propietario y custodio de las existencias. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TenantId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
name & Denominación comercial formal del repuesto o fluido automotriz. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
sku & Código interno o número de parte de fabricante único por taller. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Sku} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
category & Clasificación funcional técnica de la autoparte o consumible. \\*
\hline
\textbf{Tipo o Firma} & \texttt{ItemCategory} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
basePrice & Precio monetario unitario de venta sugerido al consumidor final. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
totalStock & Sumatoria virtual de existencias disponibles para despacho. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Quantity} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
minimumStock & Umbral cuantitativo de alerta para disparo de reabastecimiento. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Quantity} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
status & Estado operativo del ítem dentro del ciclo de vida de catálogo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{InventoryItemStatus} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
batches & Colección interna de lotes físicos ordenados cronológicamente. \\*
\hline
\textbf{Tipo o Firma} & \texttt{List<InventoryBatch>} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
create & Factoría de dominio que inicializa el repuesto en estado ACTIVE y registra evento. \\*
\hline
\textbf{Tipo o Firma} & \texttt{static InventoryItem create(TenantId tenantId,\allowbreak  String name,\allowbreak  Sku sku,\allowbreak  ItemCategory category,\allowbreak  Money basePrice,\allowbreak  Quantity minStock)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
addBatch & Incorpora un nuevo lote de compra incrementando existencias y emitiendo evento. \\*
\hline
\textbf{Tipo o Firma} & \texttt{InventoryBatch addBatch(SupplierId supplierId,\allowbreak  String batchNumber,\allowbreak  Quantity quantity,\allowbreak  Money unitCost,\allowbreak  Instant arrivalDate,\allowbreak  ImageUrl receiptImageUrl)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
allocateStockFifo & Deduce existencias por orden FIFO calculando el costo real de ventas y registrando asignación. \\*
\hline
\textbf{Tipo o Firma} & \texttt{StockAllocation allocateStockFifo(Quantity requestedQuantity)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
releaseStockAllocation & Restituye unidades canceladas a sus lotes originales y actualiza existencias totales. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void releaseStockAllocation(StockAllocation allocation)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
updateDetails & Actualiza metadatos descriptivos precio base y umbral mínimo verificando márgenes. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void updateDetails(String name,\allowbreak  ItemCategory category,\allowbreak  Money basePrice,\allowbreak  Quantity minStock)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
deactivate & Conmuta el repuesto al estado inactivo impidiendo nuevas asignaciones de existencias. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void deactivate()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de miembros y métodos de la raíz de agregado InventoryItem del paquete com.andeva.atelier.platform.inventory.domain.model.aggregates.

**Entidades Dependientes de Inventario y Abastecimiento**

Para articular el soporte contable del método FIFO y estructurar las líneas cotizadas en compras, el dominio delega responsabilidades en dos entidades dependientes fuertemente cohesionadas con sus raíces respectivas: **InventoryBatch** y **PurchaseOrderItem**.

- **InventoryBatch**: Modela la remesa física individual de repuestos ingresada en almacén mediante una compra específica. Custodia de forma inalterable su costo unitario histórico mediante **Money** y la marca cronológica de arribo **arrivalDate**, la cual actúa como clave primaria de ordenamiento para el motor FIFO. Sus operaciones *deduct()* y *restore()* controlan el saldo remanente impidiendo sobregiros o devoluciones que superen la cantidad ingresada.

- **PurchaseOrderItem**: Representa el renglón atómico de demanda comercial dentro de una orden de abastecimiento. Vincula el repuesto solicitado **InventoryItemId** con la cantidad pactada **Quantity** y el costo unitario negociado **Money**, recalculando de manera determinista el subtotal de la línea tras cada ajuste de volumen.

En la @tbl:inventory-batch-poitem-members se especifican los miembros de las entidades dependientes **InventoryBatch** y **PurchaseOrderItem**.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de las Entidades Dependientes InventoryBatch y PurchaseOrderItem} \label{tbl:inventory-batch-poitem-members} \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad Dependiente:} InventoryBatch (Lote Físico de Compra y Portador de Costo FIFO)} \\*
\hline
id & Identificador unívoco universal del lote físico ingresado a almacén. \\*
\hline
\textbf{Tipo o Firma} & \texttt{InventoryBatchId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
tenantId & Taller automotriz propietario del inventario físico ingresado. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TenantId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
itemId & Repuesto o consumible específico al que pertenece el lote. \\*
\hline
\textbf{Tipo o Firma} & \texttt{InventoryItemId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
supplierId & Proveedor comercial del cual procede la remesa física de piezas. \\*
\hline
\textbf{Tipo o Firma} & \texttt{SupplierId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
batchNumber & Código correlativo alfanumérico provisto por el fabricante o distribuidor. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
initialQuantity & Cantidad física original ingresada durante la recepción en almacén. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Quantity} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
remainingQuantity & Saldo cuantitativo remanente disponible para consumo mecánico. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Quantity} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
unitCost & Costo financiero unitario de compra inmutable en moneda operativa. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
arrivalDate & Marca de tiempo exacta de arribo físico y clave de ordenamiento FIFO. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Instant} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
receiptImageUrl & Enlace a la fotografía de la factura física en almacenamiento seguro. \\*
\hline
\textbf{Tipo o Firma} & \texttt{ImageUrl} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
hasStock & Evalúa si el lote dispone de unidades remanentes mayores a cero. \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean hasStock()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
deduct & Decrementa existencias hasta el saldo remanente y retorna el total consumido. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Quantity deduct(Quantity requestedQuantity)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
restore & Restituye unidades liberadas validando no rebasar la cantidad inicial del lote. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void restore(Quantity quantityToRestore)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad Dependiente:} PurchaseOrderItem (Renglón de Adquisición en Orden de Compra)} \\*
\hline
id & Identificador unívoco universal de la línea de detalle de compra. \\*
\hline
\textbf{Tipo o Firma} & \texttt{PurchaseOrderItemId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
orderId & Orden formal de adquisición a la que se encuentra adscrito el renglón. \\*
\hline
\textbf{Tipo o Firma} & \texttt{PurchaseOrderId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
itemId & Repuesto solicitado del catálogo comercial del taller mecánico. \\*
\hline
\textbf{Tipo o Firma} & \texttt{InventoryItemId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
quantity & Volumen físico pactado con el proveedor comercial para el abastecimiento. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Quantity} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
unitCost & Precio monetario unitario cotizado y acordado con el distribuidor. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
totalCost & Subtotal financiero correspondiente al producto de cantidad y costo unitario. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
updateQuantity & Ajusta el volumen demandado y actualiza deterministamente el subtotal. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void updateQuantity(Quantity newQuantity)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de miembros de las entidades dependientes InventoryBatch y PurchaseOrderItem del paquete com.andeva.atelier.platform.inventory.domain.model.entities.

**Raíces de Agregado Supplier y PurchaseOrder**

El ciclo de aprovisionamiento de autopartes se formaliza a través de las raíces de agregado **Supplier** y **PurchaseOrder**, las cuales aseguran relaciones comerciales transparentes y conformidad física en recepción:

- **Supplier**: Modela la ficha comercial del distribuidor o fabricante de componentes mecánicos. Impone como invariante la homologación de su RUC de 11 dígitos mediante validación formal del algoritmo Módulo 11 de SUNAT, garantizando que el taller solo establezca vínculos de compra con personas jurídicas formalmente reconocidas.

- **PurchaseOrder**: Conduce el flujo de reabastecimiento mediante una máquina de estados determinista (**DRAFT** $\to$ **ISSUED** $\to$ **RECEIVED** o **CANCELED**). Exige la incorporación de al menos una línea antes de emitirse y condiciona la recepción final a la verificación del comprobante fiscal **receiptNumber** y su evidencia fotográfica **receiptImageUrl**, disparando el alta de nuevos lotes en el inventario.

En la @tbl:inventory-supplier-po-members se especifican los miembros de las raíces de agregado **Supplier** y **PurchaseOrder**.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de las Raíces de Agregado Supplier y PurchaseOrder} \label{tbl:inventory-supplier-po-members} \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Raíz de Agregado:} Supplier (Directorio Comercial Homologado de Proveedores)} \\*
\hline
id & Identificador unívoco universal de la empresa distribuidora de repuestos. \\*
\hline
\textbf{Tipo o Firma} & \texttt{SupplierId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
tenantId & Taller automotriz que administra la relación comercial con el proveedor. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TenantId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
businessName & Razón social oficial o denominación tributaria legal de la empresa. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
taxId & Número de RUC de 11 dígitos homologado mediante validación formal. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TaxId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
contactName & Persona de contacto comercial o asesor corporativo de ventas asignado. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
phone & Teléfono de contacto comercial normalizado según el estándar E.164. \\*
\hline
\textbf{Tipo o Firma} & \texttt{PhoneNumber} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
email & Correo electrónico institucional para remisión formal de órdenes de compra. \\*
\hline
\textbf{Tipo o Firma} & \texttt{EmailAddress} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
address & Domicilio fiscal o dirección del centro logístico principal de distribución. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
isActive & Estado de vigencia operativa y habilitación comercial ante el taller. \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
register & Factoría de dominio que valida RUC único y registra al distribuidor. \\*
\hline
\textbf{Tipo o Firma} & \texttt{static Supplier register(TenantId tenantId,\allowbreak  String businessName,\allowbreak  TaxId taxId,\allowbreak  String contactName,\allowbreak  PhoneNumber phone,\allowbreak  EmailAddress email,\allowbreak  String address)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
updateContactInfo & Actualiza canales de contacto comercial y dirección física del proveedor. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void updateContactInfo(String contactName,\allowbreak  PhoneNumber phone,\allowbreak  EmailAddress email,\allowbreak  String address)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
deactivate & Inhabilita temporalmente al distribuidor para nuevas órdenes de compra. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void deactivate()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
activate & Restablece la vigencia operativa y comercial del proveedor en el taller. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void activate()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Raíz de Agregado:} PurchaseOrder (Aprovisionamiento y Recepción Documental)} \\*
\hline
id & Identificador unívoco universal de la orden formal de compra. \\*
\hline
\textbf{Tipo o Firma} & \texttt{PurchaseOrderId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
tenantId & Taller automotriz que emite y financia la adquisición de suministros. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TenantId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
supplierId & Proveedor comercial seleccionado para el suministro de los materiales. \\*
\hline
\textbf{Tipo o Firma} & \texttt{SupplierId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
branchId & Sede física operativa de destino autorizada para recepcionar la carga. \\*
\hline
\textbf{Tipo o Firma} & \texttt{BranchId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
orderNumber & Código correlativo formal de control interno de abastecimiento. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
status & Estado actual en la máquina determinista de aprovisionamiento de taller. \\*
\hline
\textbf{Tipo o Firma} & \texttt{PurchaseOrderStatus} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
totalCost & Monto monetario total consolidado de la adquisición de repuestos. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
receiptImageUrl & Enlace a la factura física escaneada en almacenamiento seguro. \\*
\hline
\textbf{Tipo o Firma} & \texttt{ImageUrl} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
receiptNumber & Número de serie y correlativo fiscal del comprobante de proveedor. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
receivedAt & Marca de tiempo exacta de conformidad de recepción física en almacén. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Instant} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
items & Colección interna de renglones de piezas cotizadas en la orden. \\*
\hline
\textbf{Tipo o Firma} & \texttt{List<PurchaseOrderItem>} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
create & Factoría de dominio que abre la orden en estado DRAFT y emite evento. \\*
\hline
\textbf{Tipo o Firma} & \texttt{static PurchaseOrder create(TenantId tenantId,\allowbreak  SupplierId supplierId,\allowbreak  BranchId branchId,\allowbreak  String orderNumber)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
addItem & Incorpora una línea de repuesto y recalcula el costo acumulado de la orden. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void addItem(InventoryItemId itemId,\allowbreak  Quantity quantity,\allowbreak  Money unitCost)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
removeItem & Remueve una línea de adquisición y recalcula el costo total de la orden. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void removeItem(PurchaseOrderItemId itemId)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
issue & Emite formalmente la orden al proveedor conmutando a ISSUED y emitiendo evento. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void issue()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
receive & Convalida la entrega física con comprobante fotográfico y da de alta los lotes. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void receive(ImageUrl receiptImageUrl,\allowbreak  String receiptNumber,\allowbreak  Instant receivedAt)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
cancel & Anula la orden de compra antes de su recepción física liberando compromisos. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void cancel(String reason)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de miembros de las raíces de agregado Supplier y PurchaseOrder del paquete com.andeva.atelier.platform.inventory.domain.model.aggregates.

**Objetos de Valor y Enumeraciones de Inventory & Supply Chain**

En estricta observancia del principio de inmutabilidad y erradicación de la obsesión por tipos primitivos, los conceptos cuantitativos y taxonómicos de este contexto se implementan como registros Java (*Java Records*). Estos componentes validan sus restricciones en el constructor compacto, imposibilitando importes monetarios o volúmenes negativos.

En la @tbl:inventory-value-objects se especifican los objetos de valor y enumeraciones propios de la gestión de inventario y cadena de suministro.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Objetos de Valor y Enumeraciones del Bounded Context Inventory \& Supply Chain} \label{tbl:inventory-value-objects} \\
\hline
\thfirst{Componente de Dominio} & \thcell{Especificación Técnica y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Componente de Dominio} & \thcell{Especificación Técnica y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} InventoryItemId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal de pieza o consumible. Inmutable y no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} InventoryBatchId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal del lote físico de adquisición. Inmutable y no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} SupplierId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal del proveedor comercial de autopartes. Inmutable y no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} PurchaseOrderId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal de la orden formal de compra. Inmutable y no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} PurchaseOrderItemId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal del renglón de compra. Inmutable y no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} Sku} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: String} \\*
\hline
\textbf{Restricciones y Reglas} & Formato alfanumérico en mayúsculas sin espacios de longitud entre 3 y 50 caracteres único por taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} Quantity} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: BigDecimal} \\*
\hline
\textbf{Restricciones y Reglas} & Magnitud no negativa con escala fija a dos decimales con métodos add subtract isGreaterThan e isLessThanOrEqualTo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} StockAllocation} \\*
\hline
\textbf{Atributos Clave} & \texttt{allocationId: UUID}, \texttt{allocatedQuantity: Quantity}, \texttt{totalCostOfGoodsSold: Money}, \texttt{deductions: List<BatchDeduction>} \\*
\hline
\textbf{Restricciones y Reglas} & Registro inmutable portador del resultado de deducción FIFO costo acumulado de mercadería y desglose de lotes afectados. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} BatchDeduction} \\*
\hline
\textbf{Atributos Clave} & \texttt{batchId: UUID}, \texttt{quantityDeducted: Quantity}, \texttt{unitCost: Money} \\*
\hline
\textbf{Restricciones y Reglas} & Detalle inmutable de unidades extraídas de un lote físico específico junto con su costo unitario histórico. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} ItemCategory} \\*
\hline
\textbf{Atributos Clave} & Constantes de enumeración \\*
\hline
\textbf{Restricciones y Reglas} & Clasificación técnica: LUBRICANTS, BRAKES, SUSPENSION, ENGINE, ELECTRICAL, TIRES, FILTERS, BODYWORK y ACCESSORIES. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} InventoryItemStatus} \\*
\hline
\textbf{Atributos Clave} & Constantes de enumeración \\*
\hline
\textbf{Restricciones y Reglas} & Estados operativos del ciclo de vida del repuesto: ACTIVE, INACTIVE y DISCONTINUED. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} PurchaseOrderStatus} \\*
\hline
\textbf{Atributos Clave} & Constantes de enumeración \\*
\hline
\textbf{Restricciones y Reglas} & Máquina determinista de la orden de compra: DRAFT transiciona a ISSUED, luego a RECEIVED o bien a CANCELED. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes inmutables y tipos taxonómicos del paquete com.andeva.atelier.platform.inventory.domain.model.valueobjects.

**Servicios de Dominio de Inventory & Supply Chain**

Aquellas operaciones de cálculo matemático complejo que involucran múltiples agregados o aplican algoritmos contables transversales se formulan como servicios de dominio puros sin estado:

- **FifoAllocationEngine**: Ejecuta el algoritmo determinista de asignación de materiales por orden cronológico estricto de arribo físico. Ordena los lotes con existencias positivas por fecha ascendente, calcula la deducción óptima y determina el Costo de Mercadería Vendida acumulado, previniendo atómicamente inventarios negativos ante faltantes de stock.

- **InventoryValuationService**: Consolida la valuación patrimonial global del inventario del taller automotriz, sumando el producto del saldo disponible de cada lote activo por su costo unitario histórico bajo precisión bancaria HALF\_EVEN, proveyendo sustento para balances contables y auditorías impositivas.

- **StockReorderEvaluationService**: Monitorea continuamente las existencias frente al umbral crítico de seguridad tras cada consumo, proyectando la demanda esperada durante el tiempo de entrega del proveedor para sugerir cantidades óptimas de reaprovisionamiento.

En la @tbl:inventory-domain-services se exponen las especificaciones y responsabilidades de estos tres servicios de dominio.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Servicios de Dominio del Bounded Context Inventory \& Supply Chain} \label{tbl:inventory-domain-services} \\
\hline
\thfirst{Aspecto de Servicio} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Servicio} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Dominio:} FifoAllocationEngine} \\*
\hline
\textbf{Métodos Principales} & \texttt{StockAllocation allocate(InventoryItem item,\allowbreak  Quantity requestedQuantity)} \\*
\hline
\textbf{Responsabilidad} & Ordena lotes activos por fecha cronológica ascendente deduce existencias atómicamente calcula el costo real acumulado de ventas y arroja InsufficientStockException ante saldo insuficiente. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Dominio:} InventoryValuationService} \\*
\hline
\textbf{Métodos Principales} & \texttt{Money calculateTotalValuation(TenantId tenantId,\allowbreak  List<InventoryItem> items)} \\*
\hline
\textbf{Responsabilidad} & Computa el valor contable consolidado del almacén sumando el producto del saldo remanente de cada lote activo por su costo unitario de adquisición con redondeo HALF\_EVEN. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Dominio:} StockReorderEvaluationService} \\*
\hline
\textbf{Métodos Principales} & \texttt{ReorderRecommendation evaluateReorder(InventoryItem item,\allowbreak  int averageDailyDemand,\allowbreak  int supplierLeadTimeDays)} \\*
\hline
\textbf{Responsabilidad} & Evalúa existencias totales frente al umbral mínimo proyecta la demanda durante el tiempo de entrega y genera recomendaciones inmutables de reabastecimiento. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Servicios sin estado ubicados en el paquete com.andeva.atelier.platform.inventory.domain.services.

**Puertos de Repositorio de la Capa de Dominio**

En concordancia con los principios de Clean Architecture, la capa de dominio expone contratos de persistencia agnósticos que definen las necesidades de almacenamiento sin acoplarse a tecnologías relacionales ni frameworks de infraestructura:

- **InventoryItemRepository**: Contrato para la persistencia y búsqueda de piezas por código interno, umbrales de reorden y filtros de catálogo por taller.

- **InventoryBatchRepository**: Contrato para la consulta cronológica y auditoría histórica de lotes físicos activos y agotados.

- **SupplierRepository**: Contrato para la administración y validación de unicidad fiscal del padrón comercial de distribuidores.

- **PurchaseOrderRepository**: Contrato para el control correlativo, consulta y trazabilidad del ciclo de compras de repuestos.

En la @tbl:inventory-repository-ports se detallan las operaciones provistas por estos puertos de salida.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Puertos de Repositorio del Bounded Context Inventory \& Supply Chain} \label{tbl:inventory-repository-ports} \\
\hline
\thfirst{Aspecto de Puerto} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Puerto} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Repositorio:} InventoryItemRepository} \\*
\hline
\textbf{Métodos Principales} & - \texttt{save} \newline - \texttt{findById} \newline - \texttt{findByTenantIdAndSku} \newline - \texttt{findByTenantId} \newline - \texttt{findLowStockItems} \newline - \texttt{existsByTenantIdAndSku} \\*
\hline
\textbf{Responsabilidad de Dominio} & Persistencia y consulta del catálogo maestro de piezas existencias totales y filtrado de desabastecimiento crítico por taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Repositorio:} InventoryBatchRepository} \\*
\hline
\textbf{Métodos Principales} & - \texttt{save} \newline - \texttt{findByItemIdOrderByArrivalDateAsc} \newline - \texttt{findActiveBatchesByItemId} \\*
\hline
\textbf{Responsabilidad de Dominio} & Persistencia y consulta cronológica de lotes físicos para soporte del motor de deducción FIFO y auditoría histórica. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Repositorio:} SupplierRepository} \\*
\hline
\textbf{Métodos Principales} & - \texttt{save} \newline - \texttt{findById} \newline - \texttt{findByTenantIdAndTaxId} \newline - \texttt{findByTenantId} \\*
\hline
\textbf{Responsabilidad de Dominio} & Persistencia y consulta del padrón de distribuidores comerciales homologados y validación de unicidad de RUC por taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Repositorio:} PurchaseOrderRepository} \\*
\hline
\textbf{Métodos Principales} & - \texttt{save} \newline - \texttt{findById} \newline - \texttt{findByTenantId} \newline - \texttt{findBySupplierId} \\*
\hline
\textbf{Responsabilidad de Dominio} & Persistencia y seguimiento del ciclo de vida de órdenes formales de adquisición y recepción probatoria de mercadería. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Contratos de salida agnósticos ubicados en el paquete com.andeva.atelier.platform.inventory.domain.repositories.

**Taxonomía de Eventos de Dominio de Inventory & Supply Chain**

Los eventos de dominio de este contexto representan hechos logísticos y comerciales concluidos, implementando la interfaz **DomainEvent** provista por el Shared Kernel para su transporte garantizado mediante el Transactional Outbox:

- **Gestión de catálogo y remesas físicas**: **InventoryItemCreatedEvent** e **InventoryBatchAddedEvent** difunden el alta de ítems e ingresos físicos de lotes al almacén.

- **Coordinación transaccional con MRO**: **StockAllocatedFifoEvent** y **StockReleasedEvent** comunican la reserva confirmada de existencias con su costo contable liquidado o la reversión de materiales por anulación de labores técnicas.

- **Alertas logísticas y homologación comercial**: **LowStockThresholdReachedEvent** y **SupplierRegisteredEvent** notifican riesgos de desabastecimiento y el alta de distribuidores formalizados.

- **Ciclo de aprovisionamiento documental**: **PurchaseOrderCreatedEvent**, **PurchaseOrderIssuedEvent**, **PurchaseOrderReceivedEvent** y **PurchaseOrderCanceledEvent** orquestan las fases de compra y disparan la creación de lotes con comprobante fiscal.

En la @tbl:inventory-domain-events se sintetiza la taxonomía de los diez eventos de dominio de este contexto.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Taxonomía de Eventos de Dominio del Bounded Context Inventory \& Supply Chain} \label{tbl:inventory-domain-events} \\
\hline
\thfirst{Aspecto del Evento} & \thcell{Especificación de Carga Útil y Efecto} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Evento} & \thcell{Especificación de Carga Útil y Efecto} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} InventoryItemCreatedEvent \quad (\textit{Emisor:} InventoryItem)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{itemId}, \texttt{tenantId}, \texttt{sku}, \texttt{name}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Notifica el alta de una nueva pieza en el catálogo maestro habilitando su cotización y gestión de existencias. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} InventoryBatchAddedEvent \quad (\textit{Emisor:} InventoryItem)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{batchId}, \texttt{itemId}, \texttt{quantity}, \texttt{unitCost}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Comunica el ingreso físico de un nuevo lote a almacén incrementando el stock consolidado y habilitando unidades para despacho. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} StockAllocatedFifoEvent \quad (\textit{Emisor:} InventoryItem)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{itemId}, \texttt{allocatedQuantity}, \texttt{cogs}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Informa la deducción exitosa de existencias reportando el Costo de Mercadería Vendida para imputación en la orden de trabajo de MRO. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} StockReleasedEvent \quad (\textit{Emisor:} InventoryItem)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{itemId}, \texttt{releasedQuantity}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Notifica la restitución de piezas a sus lotes de procedencia tras la anulación o modificación de una labor mecánica. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} LowStockThresholdReachedEvent \quad (\textit{Emisor:} InventoryItem)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{itemId}, \texttt{tenantId}, \texttt{currentStock}, \texttt{minStock}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Alerta al personal de compras y logística sobre existencias por debajo del umbral de seguridad para emitir sugerencias de reposición. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} SupplierRegisteredEvent \quad (\textit{Emisor:} Supplier)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{supplierId}, \texttt{tenantId}, \texttt{businessName}, \texttt{taxId}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Notifica el registro de un nuevo proveedor homologado con RUC formal en el directorio comercial del taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} PurchaseOrderCreatedEvent \quad (\textit{Emisor:} PurchaseOrder)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{orderId}, \texttt{tenantId}, \texttt{supplierId}, \texttt{branchId}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Notifica la apertura de una orden de compra en borrador para presupuestar suministros requeridos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} PurchaseOrderIssuedEvent \quad (\textit{Emisor:} PurchaseOrder)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{orderId}, \texttt{tenantId}, \texttt{supplierId}, \texttt{totalCost}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Comunica la emisión formal de la orden al proveedor autorizando el despacho comercial hacia la sucursal. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} PurchaseOrderReceivedEvent \quad (\textit{Emisor:} PurchaseOrder)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{orderId}, \texttt{tenantId}, \texttt{supplierId}, \texttt{totalCost}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Notifica la recepción física conforme de las piezas con comprobante escaneado disparando el alta automática de lotes en el inventario. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} PurchaseOrderCanceledEvent \quad (\textit{Emisor:} PurchaseOrder)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{orderId}, \texttt{reason}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Registra la anulación de la orden de compra antes de su recepción física liberando los compromisos financieros adquiridos. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Eventos de dominio inmutables ubicados bajo el paquete com.andeva.atelier.platform.inventory.domain.events.

**Excepciones de Dominio y Manejo de Errores Semánticos**

Las desviaciones funcionales y vulneraciones a invariantes se canalizan a través de excepciones semánticas no comprobadas derivadas de **DomainException**. Cada excepción encapsula un código legible estandarizado bajo la norma RFC 7807 y su estatus HTTP representativo:

- **Anomalías de existencias y unicidad de catálogo**: **InsufficientStockException**, **DuplicateSkuException** y **DuplicateSupplierTaxIdException** ante demandas superiores al saldo disponible o colisiones de códigos y RUC.

- **Infracciones de cantidad y máquina de estados**: **InvalidBatchQuantityException**, **InvalidPurchaseOrderTransitionException** y **PurchaseOrderEmptyException** al vulnerar reglas cuantitativas o transiciones prohibidas en compras.

- **Validación documental y entidades no localizadas**: **MissingReceiptDocumentationException**, **InventoryItemNotFoundException**, **SupplierNotFoundException** y **PurchaseOrderNotFoundException** frente a omisión de facturas o búsquedas infructuosas.

En la @tbl:inventory-domain-exceptions se sintetiza la jerarquía de excepciones de dominio y sus códigos semánticos asociados.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.8cm} | >{\raggedright\arraybackslash}p{9.6cm} |}
\caption{Excepciones de Dominio y Códigos Semánticos de Inventory \& Supply Chain} \label{tbl:inventory-domain-exceptions} \\
\hline
\thfirst{Código de Error Semántico} & \thcell{Condición de Lanzamiento en el Modelo} \\
\hline
\endfirsthead
\hline
\thfirst{Código de Error Semántico} & \thcell{Condición de Lanzamiento en el Modelo} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} InsufficientStockException} \\*
\hline
\texttt{ERR\_INSUFFICIENT\_\allowbreak STOCK} \newline HTTP 409 Conflict & La cantidad demandada para consumo en la orden de trabajo supera el saldo total disponible de existencias en los lotes físicos activos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} DuplicateSkuException} \\*
\hline
\texttt{ERR\_DUPLICATE\_\allowbreak SKU} \newline HTTP 409 Conflict & Se intenta registrar o actualizar una pieza con un código SKU que ya existe registrado para el mismo taller automotriz. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} DuplicateSupplierTaxIdException} \\*
\hline
\texttt{ERR\_DUPLICATE\_\allowbreak SUPPLIER\_\allowbreak RUC} \newline HTTP 409 Conflict & Se intenta registrar un proveedor comercial con un RUC fiscal que ya se encuentra activo en el directorio del taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} InvalidBatchQuantityException} \\*
\hline
\texttt{ERR\_INVALID\_\allowbreak BATCH\_\allowbreak QUANTITY} \newline HTTP 422 Unprocessable Entity & La cantidad ingresada o deducida de un lote físico es menor o igual a cero o excede la capacidad remanente admisible. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} InvalidPurchaseOrderTransitionException} \\*
\hline
\texttt{ERR\_INVALID\_\allowbreak PO\_\allowbreak TRANSITION} \newline HTTP 400 Bad Request & Se solicita una transición incompatible con la máquina de estados finita de la orden de compra como conmutar a recepción desde borrador. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} PurchaseOrderEmptyException} \\*
\hline
\texttt{ERR\_EMPTY\_\allowbreak PURCHASE\_\allowbreak ORDER} \newline HTTP 422 Unprocessable Entity & Se intenta emitir formalmente hacia el proveedor una orden de compra que carece de renglones de repuestos agregados. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} MissingReceiptDocumentationException} \\*
\hline
\texttt{ERR\_MISSING\_\allowbreak RECEIPT\_\allowbreak DOC} \newline HTTP 422 Unprocessable Entity & Se intenta dar conformidad de recepción física a una orden de compra sin adjuntar el comprobante fotográfico o número fiscal. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} InventoryItemNotFoundException} \\*
\hline
\texttt{ERR\_ITEM\_\allowbreak NOT\_\allowbreak FOUND} \newline HTTP 404 Not Found & No se localiza el repuesto o insumo en el catálogo del taller mediante el identificador unívoco suministrado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} SupplierNotFoundException} \\*
\hline
\texttt{ERR\_SUPPLIER\_\allowbreak NOT\_\allowbreak FOUND} \newline HTTP 404 Not Found & No se localiza la empresa proveedora en el directorio comercial del taller mediante su identificador único. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} PurchaseOrderNotFoundException} \\*
\hline
\texttt{ERR\_PO\_\allowbreak NOT\_\allowbreak FOUND} \newline HTTP 404 Not Found & No se localiza la orden de compra consultada para operaciones de emisión recepción física o anulación formal. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Jerarquía de excepciones semánticas no comprobadas del paquete com.andeva.atelier.platform.inventory.domain.exceptions.

A partir de la formalización táctica de Inventory & Supply Chain, se identifican tres fundamentos de ingeniería de software que consolidan la disciplina operativa y contable del almacén automotriz:

El primer fundamento se sustenta en el determinismo algorítmico del motor FIFO por lotes físicos, el cual erradica distorsiones en el cálculo del Costo de Mercadería Vendida causadas por métodos promedio en escenarios de alta volatilidad de precios. Al ordenar cronológicamente las remesas y agotar de manera estricta los lotes de adquisición más antiguos, el sistema traslada con exactitud matemática el costo histórico real hacia la orden de trabajo de MRO, protegiendo el margen comercial neto del taller mecánico.

El segundo pilar reside en la integridad documental probatoria sustentada en el desacoplamiento Direct-to-Cloud de comprobantes fiscales de compra. Al condicionar la conformidad de recepción y el alta automática de lotes a la persistencia de la fotografía de la factura en almacenamiento seguro junto a su número correlativo oficial, el sistema blinda la trazabilidad ante auditorías tributarias y disputas comerciales sin sobrecargar el servidor backend con secuencias binarias de archivos multimedia.

El tercer fundamento radica en la coordinación reactiva desacoplada con el taller mecánico y la prevención sistemática de quiebres de existencias. Mediante la publicación de eventos inmutables a través del Transactional Outbox, la cadena de suministro satisface reservas de piezas solicitadas por las bahías de trabajo sin compartir estado transaccional directo, notificando oportunamente cuando los saldos alcanzan el umbral crítico de reposición para sugerir compras preventivas y garantizar la continuidad operativa.

#### 2.6.5.2. Interface Layer

La Capa de Interfaz del Bounded Context Inventory & Supply Chain actúa como el adaptador primario perimetral bajo el paquete canónico **com.andeva.atelier.platform.inventory.interfaces**. Su propósito arquitectónico consiste en traducir las interacciones externas provenientes de clientes web, aplicaciones de mostrador y dispositivos móviles hacia invocaciones deterministas sobre los casos de uso transaccionales, salvaguardando la disciplina contable FIFO y la integridad de las existencias del almacén automotriz.

Para estructurar una frontera desacoplada y alineada a las exigencias operativas y tributarias del taller mecánico, el diseño perimetral de Inventory & Supply Chain se fundamenta en cinco directrices tácticas:

- **Mediación determinista mediante tipos funcionales sellados**: La interacción perimetral con los servicios de aplicación se gobierna estrictamente mediante el contenedor monádico **Result<T, ApplicationError>**, transformando errores de dominio como quiebres de existencias o violaciones de estado en respuestas HTTP semánticas estandarizadas sin propagar excepciones no controladas.
- **Modelado RESTful estricto y enrutamiento orientado a recursos**: Las URIs perimetrales se diseñan bajo una granularidad limpia y predecible, erradicando anidamientos excesivos mediante recursos independientes para el catálogo de piezas en **/api/v1/inventory/items**, lotes de abastecimiento, proveedores homologados y expedientes formales de compra en **/api/v1/inventory/purchase-orders**.
- **Trazabilidad probatoria y desacoplamiento Direct-to-Cloud de comprobantes**: La carga de comprobantes fiscales de compra delega la transmisión binaria pesada hacia Firebase Cloud Storage, recibiendo en el perímetro únicamente localizadores HTTPS validados y números correlativos oficiales para evitar la degradación de memoria del servidor backend.
- **Asignación atómica FIFO de lotes y publicación transaccional**: Las operaciones de descuento de existencias procesan lotes por orden cronológico estricto de arribo y emiten eventos de dominio persistidos en el Transactional Outbox, garantizando consistencia eventual confiable con las órdenes de trabajo mecánicas sin contención de bloqueos relacionales.
- **Fachada de contexto abierto para interoperabilidad en memoria de alta frecuencia**: Para satisfacer la demanda síncrona inmediata requerida por Workshop Operations e Invoicing, la interfaz **InventoryContextFacade** expone contratos fuertemente tipados bajo el patrón Open Host Service, permitiendo reservar materiales y verificar costos sin acoplamiento a modelos de persistencia.

En la @tbl:inventory-interface-types se sintetiza el catálogo consolidado de tipos, controladores, recursos de transporte, ensambladores y eventos que integran la Capa de Interfaz de Inventory & Supply Chain.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo Consolidado de la Capa de Interfaz de Inventory \& Supply Chain} \label{tbl:inventory-interface-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endhead
InventoryItemsController & Endpoints REST para catálogo de repuestos, precios sugeridos, bajas lógicas, saldos críticos y valuación contable. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca InventoryItemCommandService y InventoryItemQueryService. Utiliza ensambladores de recursos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
InventoryBatchesController & Endpoints REST para registro directo de lotes físicos de adquisición y auditoría de remesas activas. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca InventoryBatchCommandService e InventoryBatchQueryService. Utiliza ensambladores de recursos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
SuppliersController & Endpoints REST para padrón homologado de proveedores comerciales, validación de RUC y datos de contacto. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca SupplierCommandService y SupplierQueryService. Utiliza ensambladores de recursos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
PurchaseOrdersController & Endpoints REST para órdenes de compra, agregación de ítems, emisión oficial, recepción y cancelación. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca PurchaseOrderCommandService y PurchaseOrderQueryService. Utiliza ensambladores de recursos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Create\allowbreak InventoryItem\allowbreak Resource & Carga útil inmutable para incorporación de nuevo repuesto o consumible con SKU y precio base. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por InventoryItemResourceAssembler hacia CreateInventoryItemCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Update\allowbreak InventoryItem\allowbreak Resource & Carga útil para actualización comercial de nombre, categoría técnica, precio base y stock mínimo. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por InventoryItemResourceAssembler hacia UpdateInventoryItemCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Add\allowbreak InventoryBatch\allowbreak Resource & Carga útil para ingreso directo de lote físico con costo unitario, cantidad y comprobante fiscal. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por InventoryBatchResourceAssembler hacia AddInventoryBatchCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Create\allowbreak Supplier\allowbreak Resource & Carga útil para registro de proveedor comercial con razón social, RUC SUNAT y contacto. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por SupplierResourceAssembler hacia CreateSupplierCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Update\allowbreak Supplier\allowbreak Resource & Carga útil para actualización de razón social, teléfono y correo electrónico de proveedor. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por SupplierResourceAssembler hacia UpdateSupplierCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Create\allowbreak PurchaseOrder\allowbreak Resource & Carga útil para apertura de orden de compra formal asociada a un proveedor y sede física. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por PurchaseOrderResourceAssembler hacia CreatePurchaseOrderCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Add\allowbreak PurchaseOrderItem\allowbreak Resource & Carga útil para incorporación de renglón de compra indicando repuesto, cantidad y costo unitario. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por PurchaseOrderResourceAssembler hacia AddPurchaseOrderItemCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Receive\allowbreak PurchaseOrder\allowbreak Resource & Carga útil para conformidad física con número de factura escaneada en Firebase Storage. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por PurchaseOrderResourceAssembler hacia ReceivePurchaseOrderCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Cancel\allowbreak PurchaseOrder\allowbreak Resource & Carga útil con motivo explícito de desistimiento o anulación de la orden de reabastecimiento. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por PurchaseOrderResourceAssembler hacia CancelPurchaseOrderCommand. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
InventoryItem\allowbreak Resource & Representación pública canónica de autoparte con existencias consolidadas y estado comercial. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por InventoryItemResourceAssembler desde InventoryItem. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
InventoryItem\allowbreak SummaryResource & Proyección sintetizada para listados paginados de alta velocidad y monitor de existencias. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por InventoryItemResourceAssembler desde InventoryItem. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
InventoryItem\allowbreak DetailResource & Representación detallada que integra la colección activa de lotes físicos para inspección FIFO. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por InventoryItemResourceAssembler desde InventoryItem e InventoryBatch. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
InventoryBatch\allowbreak Resource & Registro inmutable de remesa con costo unitario histórico de compra y fecha de ingreso. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por InventoryBatchResourceAssembler desde InventoryBatch. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Supplier\allowbreak Resource & Ficha de proveedor comercial homologado con razón social, RUC SUNAT y contacto. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por SupplierResourceAssembler desde Supplier. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
PurchaseOrder\allowbreak Resource & Resumen del expediente de orden de compra con estado de abastecimiento y costo total. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por PurchaseOrderResourceAssembler desde PurchaseOrder. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
PurchaseOrderItem\allowbreak Resource & Renglón individual de compra con repuesto adquirido, cantidad demandada y costo pactado. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por PurchaseOrderResourceAssembler desde PurchaseOrderItem. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
PurchaseOrder\allowbreak DetailResource & Expediente exhaustivo con desglose de renglones, proveedor asociado y datos de factura fiscal. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por PurchaseOrderResourceAssembler integrando Supplier y PurchaseOrderItem. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
InventoryValuation\allowbreak Resource & Balance patrimonial consolidado de almacén bajo valuación contable FIFO estricta. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por InventoryItemResourceAssembler desde reporte de valuación. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
InventoryItem\allowbreak ResourceAssembler & Ensamblador bidireccional entre DTOs de catálogo, comandos y entidades InventoryItem. \\*
\hline
\textbf{Categoría} & Ensamblador de Recursos \\*
\hline
\textbf{Relaciones} & Transforma comandos mutacionales y recursos de catálogo de repuestos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak assemblers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
InventoryBatch\allowbreak ResourceAssembler & Ensamblador bidireccional entre peticiones de ingreso, comandos y entidades InventoryBatch. \\*
\hline
\textbf{Categoría} & Ensamblador de Recursos \\*
\hline
\textbf{Relaciones} & Transforma comandos de alta directa y recursos de lotes de existencias. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak assemblers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Supplier\allowbreak ResourceAssembler & Ensamblador bidireccional entre DTOs de proveedores, comandos y entidades Supplier. \\*
\hline
\textbf{Categoría} & Ensamblador de Recursos \\*
\hline
\textbf{Relaciones} & Transforma comandos de gestión de proveedores y recursos de salida. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak assemblers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
PurchaseOrder\allowbreak ResourceAssembler & Ensamblador bidireccional para expedientes de compra, ítems, recepciones y anulaciones. \\*
\hline
\textbf{Categoría} & Ensamblador de Recursos \\*
\hline
\textbf{Relaciones} & Transforma comandos de abastecimiento y recursos de órdenes de compra. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak rest.\allowbreak assemblers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
InventoryContext\allowbreak Facade & Interfaz de contexto abierto para reservas síncronas FIFO, valuación y verificación de existencias. \\*
\hline
\textbf{Categoría} & Fachada de Contexto Abierto (OHS / ACL) \\*
\hline
\textbf{Relaciones} & Expone métodos síncronos consumidos por Workshop Operations e Invoicing. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
StockReserved\allowbreak IntegrationEvent & Notificación de reserva física confirmada con imputación del costo histórico FIFO. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Emitido al Transactional Outbox. Consumido por Workshop Operations e Invoicing. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
StockReservation\allowbreak Failed\allowbreak IntegrationEvent & Alerta operativa por saldo insuficiente para atender reserva solicitada desde foso. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Emitido al Transactional Outbox. Consumido por Workshop Operations y Monitor de Taller. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
StockLow\allowbreak IntegrationEvent & Alerta preventiva por descenso de existencias por debajo del umbral mínimo configurado. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Emitido al Transactional Outbox. Consumido por Compras y Portal del Administrador. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
BatchReceived\allowbreak IntegrationEvent & Notificación de alta física de remesa para reactivación de labores pausadas por insumos. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Emitido al Transactional Outbox. Consumido por Workshop Operations y Finanzas. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
PurchaseOrder\allowbreak Issued\allowbreak IntegrationEvent & Notificación de emisión formal de pedido de compra enviada hacia distribuidor comercial. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Emitido al Transactional Outbox. Consumido por Portal de Compras y Notificaciones. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
PurchaseOrder\allowbreak Received\allowbreak IntegrationEvent & Conformidad física y documental de recepción de compra con alta automática de lotes FIFO. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Emitido al Transactional Outbox. Consumido por Invoicing, Contabilidad y Almacén. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
InventoryItem\allowbreak Created\allowbreak IntegrationEvent & Notificación de incorporación de nueva pieza al catálogo maestro para cotizaciones. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Emitido al Transactional Outbox. Consumido por Workshop Operations y CRM. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
InventoryItem\allowbreak Deactivated\allowbreak IntegrationEvent & Notificación de baja lógica comercial de pieza para inhabilitar su uso en órdenes activas. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Emitido al Transactional Outbox. Consumido por Workshop Operations y CRM. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak interfaces.\allowbreak events} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Catálogo consolidado de componentes pertenecientes al paquete canónico com.andeva.atelier.platform.inventory.interfaces.

**Controladores REST y Rutas Perimetrales**

Los puntos de acceso perimetrales de Inventory & Supply Chain se estructuran en cuatro controladores REST especializados, garantizando alta cohesión y separación estricta de responsabilidades:

- **InventoryItemsController**: Administra el catálogo maestro de autopartes, lubricantes y consumibles bajo la ruta canónica **/api/v1/inventory/items**. Centraliza las operaciones de registro de repuestos, consultas paginadas con filtrado taxonómico, actualización de tarifas base, baja lógica comercial, detección temprana de piezas en quiebre crítico y cálculo de la valuación patrimonial del almacén.

- **InventoryBatchesController**: Gestiona el abastecimiento físico por remesas bajo la ruta canónica **/api/v1/inventory/items/{itemId}/batches**. Facilita el ingreso directo de lotes en mostrador con imputación de costo unitario inalterable y comprobante probatorio, además de proveer la consulta cronológica de remesas activas para fiscalización del motor FIFO.

- **SuppliersController**: Custodia el directorio homologado de distribuidores y fabricantes comerciales bajo la ruta canónica **/api/v1/inventory/suppliers**. Provee endpoints para la inscripción formal de empresas proveedoras con validación de RUC de 11 dígitos, consulta de legajos comerciales, actualización de contactos y desactivación operativa.

- **PurchaseOrdersController**: Orquesta el ciclo formal de adquisición bajo la ruta canónica **/api/v1/inventory/purchase-orders**. Permite la apertura de expedientes de compra multi-ítem, agregación y remoción de renglones cotizados, emisión oficial hacia el proveedor, recepción física con auditoría de factura en Firebase Cloud Storage y cancelación justificada.

En la @tbl:inventory-controllers-and-endpoints se detallan las rutas, verbos HTTP, códigos de estado y tipos asociados a los controladores de Inventory & Supply Chain.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\raggedright\arraybackslash}p{6.0cm} | >{\raggedright\arraybackslash}p{9.4cm} |}
\caption{Controladores REST y Endpoints de Comunicación de Inventory \& Supply Chain} \label{tbl:inventory-controllers-and-endpoints} \\
\hline
\thfirst{Recurso de Petición} & \thcell{Código y Respuesta HTTP} \\
\hline
\endfirsthead
\hline
\thfirst{Recurso de Petición} & \thcell{Código y Respuesta HTTP} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} InventoryItemsController} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak inventory/\allowbreak items}} \\*
\hline
\textbf{Petición:} \texttt{CreateInventoryItemResource} & \textbf{Respuesta:} 201 CREATED (\texttt{InventoryItemResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak inventory/\allowbreak items}} \\*
\hline
\textbf{Petición:} Parámetros de consulta (\texttt{category}, \texttt{status}, \texttt{page}, \texttt{size}) & \textbf{Respuesta:} 200 OK (\texttt{PagedModel\textless InventoryItemSummaryResource\textgreater}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak inventory/\allowbreak items/\allowbreak \{id\}}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{InventoryItemDetailResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{PUT} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak inventory/\allowbreak items/\allowbreak \{id\}}} \\*
\hline
\textbf{Petición:} \texttt{UpdateInventoryItemResource} & \textbf{Respuesta:} 200 OK (\texttt{InventoryItemResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{PATCH} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak inventory/\allowbreak items/\allowbreak \{id\}/\allowbreak deactivate}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{InventoryItemResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak inventory/\allowbreak items/\allowbreak low-stock}} \\*
\hline
\textbf{Petición:} Parámetros de consulta (\texttt{branchId}, \texttt{page}, \texttt{size}) & \textbf{Respuesta:} 200 OK (\texttt{PagedModel\textless InventoryItemSummaryResource\textgreater}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak inventory/\allowbreak items/\allowbreak valuation}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{InventoryValuationResource}) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} InventoryBatchesController} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak inventory/\allowbreak items/\allowbreak \{itemId\}/\allowbreak batches}} \\*
\hline
\textbf{Petición:} \texttt{AddInventoryBatchResource} & \textbf{Respuesta:} 201 CREATED (\texttt{InventoryBatchResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak inventory/\allowbreak items/\allowbreak \{itemId\}/\allowbreak batches}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{List\textless InventoryBatchResource\textgreater}) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} SuppliersController} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak inventory/\allowbreak suppliers}} \\*
\hline
\textbf{Petición:} \texttt{CreateSupplierResource} & \textbf{Respuesta:} 201 CREATED (\texttt{SupplierResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak inventory/\allowbreak suppliers}} \\*
\hline
\textbf{Petición:} Parámetros de consulta (\texttt{status}, \texttt{page}, \texttt{size}) & \textbf{Respuesta:} 200 OK (\texttt{PagedModel\textless SupplierResource\textgreater}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak inventory/\allowbreak suppliers/\allowbreak \{id\}}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{SupplierResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{PUT} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak inventory/\allowbreak suppliers/\allowbreak \{id\}}} \\*
\hline
\textbf{Petición:} \texttt{UpdateSupplierResource} & \textbf{Respuesta:} 200 OK (\texttt{SupplierResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{PATCH} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak inventory/\allowbreak suppliers/\allowbreak \{id\}/\allowbreak deactivate}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{SupplierResource}) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} PurchaseOrdersController} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak inventory/\allowbreak purchase-orders}} \\*
\hline
\textbf{Petición:} \texttt{CreatePurchaseOrderResource} & \textbf{Respuesta:} 201 CREATED (\texttt{PurchaseOrderResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak inventory/\allowbreak purchase-orders}} \\*
\hline
\textbf{Petición:} Parámetros de consulta (\texttt{supplierId}, \texttt{status}, \texttt{page}, \texttt{size}) & \textbf{Respuesta:} 200 OK (\texttt{PagedModel\textless PurchaseOrderResource\textgreater}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak inventory/\allowbreak purchase-orders/\allowbreak \{id\}}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{PurchaseOrderDetailResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak inventory/\allowbreak purchase-orders/\allowbreak \{id\}/\allowbreak items}} \\*
\hline
\textbf{Petición:} \texttt{AddPurchaseOrderItemResource} & \textbf{Respuesta:} 201 CREATED (\texttt{PurchaseOrderItemResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{DELETE} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak inventory/\allowbreak purchase-orders/\allowbreak \{id\}/\allowbreak items/\allowbreak \{itemId\}}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 204 NO CONTENT \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak inventory/\allowbreak purchase-orders/\allowbreak \{id\}/\allowbreak issue}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{PurchaseOrderResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak inventory/\allowbreak purchase-orders/\allowbreak \{id\}/\allowbreak receive}} \\*
\hline
\textbf{Petición:} \texttt{ReceivePurchaseOrderResource} & \textbf{Respuesta:} 200 OK (\texttt{PurchaseOrderResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak inventory/\allowbreak purchase-orders/\allowbreak \{id\}/\allowbreak cancel}} \\*
\hline
\textbf{Petición:} \texttt{CancelPurchaseOrderResource} & \textbf{Respuesta:} 200 OK (\texttt{PurchaseOrderResource}) \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Endpoints del Bounded Context Inventory & Supply Chain diseñados bajo convención RESTful estricta.

**Recursos DTO de Petición y Respuesta HTTP**

Para evitar la fuga perimetral de modelos relacionales y proteger la integridad del dominio, la Capa de Interfaz implementa un catálogo especializado de registros inmutables concebidos como objetos de transferencia de datos.

Los recursos de petición se modelan mediante registros inmutables de Java enriquecidos con anotaciones declarativas de Jakarta Bean Validation. Clases como **CreateInventoryItemResource**, **UpdateInventoryItemResource**, **AddInventoryBatchResource**, **CreateSupplierResource**, **UpdateSupplierResource**, **CreatePurchaseOrderResource**, **AddPurchaseOrderItemResource**, **ReceivePurchaseOrderResource** y **CancelPurchaseOrderResource** imponen validaciones defensivas inmediatas sobre formatos de SKU, números de RUC de 11 dígitos, cantidades positivas mayores a cero, identificadores obligatorios y localizadores de comprobantes antes de derivar el flujo a los casos de uso.

En contraparte, los recursos de respuesta estructuran las cargas informativas entregadas a los clientes del sistema. Destacan **InventoryItemResource** como ficha canónica de catálogo, **InventoryItemSummaryResource** para visualizaciones en rejillas de alto rendimiento, **InventoryItemDetailResource** para la auditoría técnica de lotes activos, **InventoryBatchResource** como constancia de remesa FIFO, **SupplierResource** para fichas de proveedores, **PurchaseOrderDetailResource** para expedientes integrales de abastecimiento e **InventoryValuationResource** para la proyección patrimonial de almacén.

En la @tbl:inventory-resources-dtos se detallan los atributos y reglas de validación de los recursos DTO de Inventory & Supply Chain.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Recursos DTO de Entrada y Salida del Bounded Context Inventory \& Supply Chain} \label{tbl:inventory-resources-dtos} \\
\hline
\thfirst{Aspecto de Recurso} & \thcell{Especificación de Atributos e Integridad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Recurso} & \thcell{Especificación de Atributos e Integridad} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} CreateInventoryItemResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{name}, \texttt{sku}, \texttt{category}, \texttt{basePrice}, \texttt{currency}, \texttt{minimumStock} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank}, \texttt{@Size(max = 150)} para nombre, \texttt{@Pattern(regexp = "\textasciicircum[A-Z0-9-]\{3,50\}\$")} para código SKU, \texttt{@NotNull} para categoría técnica, \texttt{@NotNull} y \texttt{@Positive} para precio base, \texttt{@Pattern(regexp = "PEN|USD")} para divisa y \texttt{@NotNull}, \texttt{@PositiveOrZero} para umbral de existencias mínimas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} UpdateInventoryItemResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{name}, \texttt{category}, \texttt{basePrice}, \texttt{currency}, \texttt{minimumStock} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank}, \texttt{@Size(max = 150)} para nombre, \texttt{@NotNull} para categoría técnica, \texttt{@NotNull} y \texttt{@Positive} para precio base, \texttt{@Pattern(regexp = "PEN|USD")} para divisa y \texttt{@NotNull}, \texttt{@PositiveOrZero} para stock mínimo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} AddInventoryBatchResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{supplierId}, \texttt{batchNumber}, \texttt{quantity}, \texttt{unitCost}, \texttt{currency}, \texttt{receiptImageUrl} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotNull} y \texttt{@Positive} para cantidad y costo unitario, \texttt{@Pattern(regexp = "PEN|USD")} para divisa, \texttt{@Size(max = 50)} para identificador de lote y \texttt{@URL} opcional para comprobante fiscal. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} CreateSupplierResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{businessName}, \texttt{taxId}, \texttt{phone}, \texttt{email} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank}, \texttt{@Size(max = 150)} para razón social, \texttt{@NotBlank}, \texttt{@Pattern(regexp = "\textasciicircum[0-9]\{11\}\$")} para RUC SUNAT de 11 dígitos, \texttt{@Size(max = 20)} para teléfono y \texttt{@Email}, \texttt{@Size(max = 150)} para correo electrónico. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} UpdateSupplierResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{businessName}, \texttt{phone}, \texttt{email} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank}, \texttt{@Size(max = 150)} para razón social, \texttt{@Size(max = 20)} para teléfono de contacto y \texttt{@Email}, \texttt{@Size(max = 150)} para correo electrónico. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} CreatePurchaseOrderResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{supplierId}, \texttt{branchId}, \texttt{expectedDeliveryDate}, \texttt{notes} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotNull} para identificadores de proveedor y sucursal, \texttt{@FutureOrPresent} opcional para fecha prevista de arribo y \texttt{@Size(max = 1000)} para notas operativas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} AddPurchaseOrderItemResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{itemId}, \texttt{quantity}, \texttt{unitCost}, \texttt{currency} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotNull} para repuesto demandado, \texttt{@NotNull} y \texttt{@Positive} para cantidad física y costo unitario pactado, y \texttt{@Pattern(regexp = "PEN|USD")} para divisa. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} ReceivePurchaseOrderResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{receiptNumber}, \texttt{receiptImageUrl}, \texttt{receptionNotes} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank}, \texttt{@Size(max = 50)} para correlativo de comprobante del proveedor, \texttt{@NotBlank}, \texttt{@URL} para enlace seguro en Firebase Storage y \texttt{@Size(max = 1000)} para notas de conformidad física. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} CancelPurchaseOrderResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{cancellationReason} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank} y \texttt{@Size(min = 10, max = 500)} para fundamentación explícita de anulación del expediente de compra. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} InventoryItemResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{tenantId}, \texttt{name}, \texttt{sku}, \texttt{category}, \texttt{basePrice}, \texttt{currency}, \texttt{totalStock}, \texttt{minimumStock}, \texttt{status}, \texttt{createdAt} \\*
\hline
\textbf{Validación de Integridad} & Ficha canónica de autoparte con saldo total consolidado e indicador de vigencia comercial. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} InventoryItemSummaryResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{name}, \texttt{sku}, \texttt{category}, \texttt{basePrice}, \texttt{totalStock}, \texttt{status}, \texttt{lowStock} \\*
\hline
\textbf{Validación de Integridad} & Representación compacta proyectada para listados de alta velocidad y monitor de existencias críticas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} InventoryItemDetailResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{tenantId}, \texttt{name}, \texttt{sku}, \texttt{category}, \texttt{basePrice}, \texttt{currency}, \texttt{totalStock}, \texttt{minimumStock}, \texttt{status}, \texttt{batches} \\*
\hline
\textbf{Validación de Integridad} & Expediente completo del repuesto integrando la colección activa de lotes físicos para inspección FIFO. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} InventoryBatchResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{itemId}, \texttt{supplierId}, \texttt{purchaseOrderId}, \texttt{batchNumber}, \texttt{initialQuantity}, \texttt{remainingQuantity}, \texttt{unitCost}, \texttt{currency}, \texttt{arrivalDate}, \texttt{receiptImageUrl} \\*
\hline
\textbf{Validación de Integridad} & Registro inmutable de remesa con fecha de ingreso cronológico y costo unitario histórico de compra. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} SupplierResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{tenantId}, \texttt{businessName}, \texttt{taxId}, \texttt{phone}, \texttt{email}, \texttt{active}, \texttt{createdAt} \\*
\hline
\textbf{Validación de Integridad} & Ficha homologada de proveedor comercial con razón social y registro fiscal tributario. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} PurchaseOrderResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{tenantId}, \texttt{supplierId}, \texttt{branchId}, \texttt{orderNumber}, \texttt{status}, \texttt{totalCost}, \texttt{currency}, \texttt{receiptNumber}, \texttt{receiptImageUrl}, \texttt{receivedAt}, \texttt{createdAt} \\*
\hline
\textbf{Validación de Integridad} & Encabezado del expediente de compra con estado de abastecimiento y total consolidado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} PurchaseOrderItemResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{purchaseOrderId}, \texttt{itemId}, \texttt{itemName}, \texttt{sku}, \texttt{quantity}, \texttt{unitCost}, \texttt{totalCost}, \texttt{currency} \\*
\hline
\textbf{Validación de Integridad} & Renglón formal de adquisición con subtotal calculado e identificación del repuesto. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} PurchaseOrderDetailResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{tenantId}, \texttt{supplier}, \texttt{branchId}, \texttt{orderNumber}, \texttt{status}, \texttt{totalCost}, \texttt{currency}, \texttt{receiptNumber}, \texttt{receiptImageUrl}, \texttt{receivedAt}, \texttt{items} \\*
\hline
\textbf{Validación de Integridad} & Expediente integral de orden de compra con desglose de ítems, proveedor adjudicado y auditoría documental. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} InventoryValuationResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{tenantId}, \texttt{valuationMethod}, \texttt{totalValuationAmount}, \texttt{currency}, \texttt{totalItemsCount}, \texttt{totalBatchesCount}, \texttt{calculatedAt} \\*
\hline
\textbf{Validación de Integridad} & Balance patrimonial financiero del almacén calculado bajo valuación matemática FIFO estricta. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes ubicados en el paquete com.andeva.atelier.platform.inventory.interfaces.rest.resources.

**Ensambladores y Transformadores de Recursos**

El desacoplamiento entre las peticiones HTTP y los casos de uso transaccionales se materializa a través de ensambladores bidireccionales de recursos. Los transformadores de entrada reciben los registros inmutables DTO y componen los comandos transaccionales correspondientes, garantizando la inyección segura del identificador del taller autenticado y los identificadores de ruta.

Por su parte, los ensambladores de salida traducen las raíces de agregado y entidades del dominio hacia representaciones DTO preparadas para el consumo perimetral. Componentes como **InventoryItemResourceAssembler**, **InventoryBatchResourceAssembler**, **SupplierResourceAssembler** y **PurchaseOrderResourceAssembler** aíslan las entidades de persistencia respecto a las capas externas, protegiendo las invariantes del motor FIFO y permitiendo componer vistas enriquecidas con desgloses de lotes y proveedores.

En la @tbl:inventory-resource-assemblers se detallan los métodos principales y firmas de transformación de estos ensambladores.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.1cm} | >{\raggedright\arraybackslash}p{10.3cm} |}
\caption{Ensambladores de Recursos del Bounded Context Inventory \& Supply Chain} \label{tbl:inventory-resource-assemblers} \\
\hline
\thfirst{Aspecto del Ensamblador} & \thcell{Firma y Transformación de Tipos} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Ensamblador} & \thcell{Firma y Transformación de Tipos} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} InventoryItemResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{CreateInventoryItemResource,\allowbreak  TenantId} $\longrightarrow$ \texttt{CreateInventoryItemCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} InventoryItemResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{UpdateInventoryItemResource,\allowbreak  UUID,\allowbreak  TenantId} $\longrightarrow$ \texttt{UpdateInventoryItemCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} InventoryItemResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResourceFromEntity} \\*
\hline
\textbf{Transformación} & \texttt{InventoryItem} $\longrightarrow$ \texttt{InventoryItemResource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} InventoryItemResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toSummaryResourceFromEntity} \\*
\hline
\textbf{Transformación} & \texttt{InventoryItem} $\longrightarrow$ \texttt{InventoryItemSummaryResource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} InventoryItemResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toDetailResourceFromEntity} \\*
\hline
\textbf{Transformación} & \texttt{InventoryItem,\allowbreak  List\textless InventoryBatch\textgreater} $\longrightarrow$ \texttt{InventoryItemDetailResource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} InventoryBatchResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{AddInventoryBatchResource,\allowbreak  UUID,\allowbreak  TenantId} $\longrightarrow$ \texttt{AddInventoryBatchCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} InventoryBatchResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResourceFromEntity} \\*
\hline
\textbf{Transformación} & \texttt{InventoryBatch} $\longrightarrow$ \texttt{InventoryBatchResource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} InventoryBatchResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResourceListFromEntities} \\*
\hline
\textbf{Transformación} & \texttt{List\textless InventoryBatch\textgreater} $\longrightarrow$ \texttt{List\textless InventoryBatchResource\textgreater} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} SupplierResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{CreateSupplierResource,\allowbreak  TenantId} $\longrightarrow$ \texttt{CreateSupplierCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} SupplierResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{UpdateSupplierResource,\allowbreak  UUID,\allowbreak  TenantId} $\longrightarrow$ \texttt{UpdateSupplierCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} SupplierResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResourceFromEntity} \\*
\hline
\textbf{Transformación} & \texttt{Supplier} $\longrightarrow$ \texttt{SupplierResource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} PurchaseOrderResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{CreatePurchaseOrderResource,\allowbreak  TenantId} $\longrightarrow$ \texttt{CreatePurchaseOrderCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} PurchaseOrderResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{AddPurchaseOrderItemResource,\allowbreak  UUID,\allowbreak  TenantId} $\longrightarrow$ \texttt{AddPurchaseOrderItemCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} PurchaseOrderResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{ReceivePurchaseOrderResource,\allowbreak  UUID,\allowbreak  TenantId} $\longrightarrow$ \texttt{ReceivePurchaseOrderCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} PurchaseOrderResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{CancelPurchaseOrderResource,\allowbreak  UUID,\allowbreak  TenantId} $\longrightarrow$ \texttt{CancelPurchaseOrderCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} PurchaseOrderResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResourceFromEntity} \\*
\hline
\textbf{Transformación} & \texttt{PurchaseOrder} $\longrightarrow$ \texttt{PurchaseOrderResource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} PurchaseOrderResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toItemResourceFromEntity} \\*
\hline
\textbf{Transformación} & \texttt{PurchaseOrderItem} $\longrightarrow$ \texttt{PurchaseOrderItemResource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} PurchaseOrderResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toDetailResourceFromEntity} \\*
\hline
\textbf{Transformación} & \texttt{PurchaseOrder,\allowbreak  Supplier} $\longrightarrow$ \texttt{PurchaseOrderDetailResource} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes ubicados en el paquete com.andeva.atelier.platform.inventory.interfaces.rest.assemblers.

**Fachada de Contexto Abierto (Open Host Service / Inbound ACL)**

Para preservar la pureza del modelo de dominio de Inventory & Supply Chain y permitir una interoperabilidad de alta frecuencia sin acoplamientos circulares, la capa de interfaz implementa el patrón Open Host Service complementado con una Capa Anticorrupción de entrada.

Este mecanismo se materializa en la interfaz **InventoryContextFacade**, ubicada en el paquete canónico **com.andeva.atelier.platform.inventory.interfaces.acl**. Esta fachada define contratos públicos en memoria para que contextos limítrofes como Workshop Operations e Invoicing reserven existencias bajo estricto ordenamiento cronológico FIFO, liberen reservas ante cancelaciones periciales, verifiquen saldos disponibles en tiempo real y computen la valuación patrimonial de almacén sin acceder a tablas ni entidades JPA.

La implementación **InventoryContextFacadeImpl** delega estas operaciones en los repositorios y servicios de aplicación de inventario, devolviendo registros inmutables de frontera como **StockReservationDto**, **InventoryItemSummaryDto** e **InventoryValuationDto**, blindando el aislamiento transaccional y la autonomía de cada bounded context.

En la @tbl:inventory-facade-methods se especifican los métodos, signaturas, tipos de retorno y módulos consumidores de la fachada de contexto abierto.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Métodos de la Fachada de Contexto Abierto InventoryContextFacade} \label{tbl:inventory-facade-methods} \\
\hline
\thfirst{Aspecto del Contrato} & \thcell{Firma, Retorno y Consumidores} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Contrato} & \thcell{Firma, Retorno y Consumidores} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{reserveStockForWorkOrder}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID tenantId,\allowbreak  UUID workOrderId,\allowbreak  UUID itemId,\allowbreak  BigDecimal quantity} $\longrightarrow$ \texttt{Result\textless StockReservationDto,\allowbreak  InventoryErrorDto\textgreater} \\*
\hline
\textbf{Módulos Consumidores} & Workshop Operations (MRO) \\*
\hline
\textbf{Propósito} & Reserva atómica de repuestos para faenas en foso aplicando deducción FIFO por lotes y calculando el costo real de salida. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{releaseStockReservation}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID tenantId,\allowbreak  UUID workOrderId,\allowbreak  UUID itemId,\allowbreak  BigDecimal quantity} $\longrightarrow$ \texttt{Result\textless Void,\allowbreak  InventoryErrorDto\textgreater} \\*
\hline
\textbf{Módulos Consumidores} & Workshop Operations (MRO) \\*
\hline
\textbf{Propósito} & Reversión inmediata de unidades reservadas ante rectificación o desestimación de tareas mecánicas en foso. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{fetchItemSummary}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID tenantId,\allowbreak  UUID itemId} $\longrightarrow$ \texttt{Optional\textless InventoryItemSummaryDto\textgreater} \\*
\hline
\textbf{Módulos Consumidores} & Workshop Operations (MRO), Invoicing (Facturación electrónica) \\*
\hline
\textbf{Propósito} & Consulta síncrona en memoria de denominación comercial, código SKU y precio unitario de venta sugerido. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{fetchItemCurrentStock}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID tenantId,\allowbreak  UUID itemId} $\longrightarrow$ \texttt{BigDecimal} \\*
\hline
\textbf{Módulos Consumidores} & Workshop Operations (MRO), CRM \\*
\hline
\textbf{Propósito} & Comprobación instantánea de disponibilidad de existencias para evaluación técnica y planificación de servicios. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{calculateInventoryValuation}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID tenantId} $\longrightarrow$ \texttt{InventoryValuationDto} \\*
\hline
\textbf{Módulos Consumidores} & Invoicing (Facturación y auditoría tributaria), Reportes Financieros \\*
\hline
\textbf{Propósito} & Determinación del valor monetario total del inventario activo consolidando saldos remanentes y costos unitarios de lotes FIFO. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al paquete com.andeva.atelier.platform.inventory.interfaces.acl.

**Eventos de Integración (Published Language)**

Para asegurar la coordinación asíncrona intermodular sin recurrir a transacciones distribuidas ni generar contención de bloqueos relacionales, Inventory & Supply Chain define un lenguaje publicado compuesto por ocho eventos de integración inmutables.

Estos eventos notifican transiciones deterministas del inventario hacia el ecosistema. Por una parte, **StockReservedIntegrationEvent** y **StockReservationFailedIntegrationEvent** informan la resolución de pedidos de repuestos emanados por el taller mecánico, imputando el costo histórico calculado o señalando el quiebre de existencias. Por otra parte, **StockLowIntegrationEvent** dispara recomendaciones de reabastecimiento preventivo, mientras que **BatchReceivedIntegrationEvent** notifica el arribo de remesas para destrabar faenas en espera. Finalmente, **PurchaseOrderIssuedIntegrationEvent** y **PurchaseOrderReceivedIntegrationEvent** orquestan el ciclo de compra formal, y los eventos **InventoryItemCreatedIntegrationEvent** e **InventoryItemDeactivatedIntegrationEvent** mantienen sincronizados los catálogos comerciales.

En la @tbl:inventory-integration-events se sintetiza la estructura de estos eventos de integración y su impacto intermodular.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Eventos de Integración del Bounded Context Inventory \& Supply Chain} \label{tbl:inventory-integration-events} \\
\hline
\thfirst{Aspecto de Integración} & \thcell{Carga Útil y Sincronización Intermodular} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Integración} & \thcell{Carga Útil y Sincronización Intermodular} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} StockReservedIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{reservationId}, \texttt{tenantId}, \texttt{workOrderId}, \texttt{itemId}, \texttt{quantity}, \texttt{allocatedCost}, \texttt{currency}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Workshop Operations (MRO), Invoicing \\*
\hline
\textbf{Propósito} & Notificación de reserva física exitosa con imputación del costo histórico FIFO a la orden de reparación. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} StockReservationFailedIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{tenantId}, \texttt{workOrderId}, \texttt{itemId}, \texttt{requestedQuantity}, \texttt{availableQuantity}, \texttt{reason}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Workshop Operations (MRO), Monitor de Taller \\*
\hline
\textbf{Propósito} & Alerta por insuficiencia de existencias en almacén para suspender temporalmente la tarea en foso. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} StockLowIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{tenantId}, \texttt{itemId}, \texttt{sku}, \texttt{currentStock}, \texttt{minimumStock}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Compras y Reabastecimiento, Portal Web del Administrador \\*
\hline
\textbf{Propósito} & Disparo preventivo de sugerencia de compra tras alcanzar el umbral mínimo de seguridad. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} BatchReceivedIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{batchId}, \texttt{tenantId}, \texttt{itemId}, \texttt{supplierId}, \texttt{quantity}, \texttt{unitCost}, \texttt{currency}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Workshop Operations (MRO), Finanzas \\*
\hline
\textbf{Propósito} & Notificación de ingreso físico de remesa para reactivación de tareas pausadas por repuestos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} PurchaseOrderIssuedIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{purchaseOrderId}, \texttt{tenantId}, \texttt{supplierId}, \texttt{orderNumber}, \texttt{totalCost}, \texttt{currency}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Proveedor Comercial, Portal de Compras \\*
\hline
\textbf{Propósito} & Formalización comercial del pedido con reserva presupuestal y envío oficial al proveedor. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} PurchaseOrderReceivedIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{purchaseOrderId}, \texttt{tenantId}, \texttt{supplierId}, \texttt{orderNumber}, \texttt{receiptNumber}, \texttt{receiptImageUrl}, \texttt{receivedAt}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Invoicing, Auditoría Contable, Almacén \\*
\hline
\textbf{Propósito} & Certificación de conformidad física documental y generación automática de lotes FIFO con comprobante fiscal. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} InventoryItemCreatedIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{itemId}, \texttt{tenantId}, \texttt{name}, \texttt{sku}, \texttt{category}, \texttt{basePrice}, \texttt{currency}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Workshop Operations (MRO), CRM \\*
\hline
\textbf{Propósito} & Actualización de catálogos en terminales de taller y sincronización de tarifas de repuestos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} InventoryItemDeactivatedIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{itemId}, \texttt{tenantId}, \texttt{sku}, \texttt{reason}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Workshop Operations (MRO), CRM \\*
\hline
\textbf{Propósito} & Inhibición de selección de piezas discontinuadas en nuevas cotizaciones y órdenes de trabajo. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Registros inmutables pertenecientes al paquete com.andeva.atelier.platform.inventory.interfaces.events.

El diseño arquitectónico de la Capa de Interfaz de Inventory & Supply Chain consolida tres decisiones fundamentales de ingeniería de software que fortalecen la exactitud contable y la resiliencia operativa del sistema:

En primer lugar, la rigurosa segregación perimetral y el modelado RESTful orientado a recursos garantizan una exposición de servicios limpia y predecible. La delimitación estricta de controladores independientes para catálogo de piezas, lotes físicos de abastecimiento, padrón de proveedores y órdenes de compra erradica anidamientos profundos y dependencias cruzadas. Esta estructura asegura que los clientes web y móviles consuman contratos granulares respaldados por tipos inmutables y validaciones semánticas tempranas, impidiendo que peticiones inconsistentes comprometan el estado interno del almacén.

En segundo término, la sinergia entre el determinismo contable FIFO y el desacoplamiento documental Direct-to-Cloud proporciona una alta fidelidad probatoria sin sacrificar el desempeño del backend. Al vincular cada lote físico o recepción de compra a un localizador HTTPS seguro en Firebase Cloud Storage junto al número correlativo del comprobante del proveedor, se garantiza respaldo inalterable ante auditorías tributarias. Simultáneamente, el servidor de aplicaciones queda liberado del procesamiento de flujos binarios pesados, concentrando sus ciclos de cómputo en la resolución algorítmica de inventario y la imputación exacta del Costo de Mercadería Vendida.

Por último, la coordinación asíncrona intermodular sustentada en el Transactional Outbox y la fachada de contexto abierto preserva la autonomía operativa de las estaciones de servicio. La publicación atómica de eventos de integración asegura que las reservas de materiales demandadas desde foso y las alertas por umbrales críticos de desabastecimiento se sincronicen con Workshop Operations y Facturación Electrónica sin riesgo de inconsistencias transaccionales ni bloqueos distribuidos, afianzando la continuidad operativa del taller automotriz.

#### 2.6.5.3. Application Layer

La Capa de Aplicación de Inventory & Supply Chain constituye el motor orquestador de los flujos de abastecimiento, control de existencias y costeo contable en Atelier Platform, coordinando la gestión del catálogo de repuestos, el directorio comercial de proveedores y el aprovisionamiento de piezas mecánicas.

Ubicada en el paquete canónico com.andeva.atelier.platform.inventory.application, su diseño arquitectónico adopta una segregación rigurosa bajo el patrón CQRS, desacoplando las operaciones mutacionales de escritura de las proyecciones de solo lectura a través de cuatro directrices esenciales de diseño:

- **Orquestación Transaccional Atómica:** Delimitación de fronteras de consistencia transaccional mediante servicios transaccionales con nivel de aislamiento de lectura confirmada. Esta disciplina asegura atomicidad estricta entre la deducción cronológica de existencias y la imputación del Costo de Ventas en el motor FIFO, así como en la recepción de órdenes de compra multi-producto que generan simultáneamente múltiples lotes físicos con respaldo documental.

- **Flujo Determinista sin Excepciones:** Adopción del tipo de resultado sellado **Result<T, ApplicationError>** para gobernar las respuestas de los casos de uso. Las condiciones operativas previsibles asociadas a códigos SKU duplicados, existencias insuficientes o incongruencias en el estado de una orden de compra se tratan como valores inmutables de retorno, imponiendo una verificación exhaustiva sin penalizaciones por propagación de excepciones.

- **Coreografía Reactiva de Eventos y Garantía de Entrega At-Least-Once:** Manejo dual de eventos mediante oyentes locales sincrónicos para atender solicitudes de reserva demandadas desde Workshop Operations y oyentes posteriores a la confirmación transaccional para la propagación de eventos hacia el Transactional Outbox, asegurando consistencia eventual con Facturación Electrónica y CRM sin acoplamiento temporal ni bloqueos distribuidos.

- **Inversión de Dependencias y Aislamiento Perimetral:** Abstracción de servicios de infraestructura y servicios externos mediante puertos de salida específicos para la verificación de comprobantes tributarios en Firebase Cloud Storage, la consulta del padrón oficial de contribuyentes en SUNAT y el despacho asíncrono de eventos de integración hacia el bus de mensajería.

A fin de ofrecer una visión sistemática de estos componentes, en la @tbl:inventory-application-types se presenta el catálogo consolidado de las clases, interfaces y registros que estructuran la Capa de Aplicación de Inventory & Supply Chain.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo Consolidado de la Capa de Aplicación de Inventory \& Supply Chain} \label{tbl:inventory-application-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endhead
Inventory\allowbreak Item\allowbreak Command\allowbreak Service\allowbreak Impl & Orquesta el ciclo de vida del catálogo de repuestos, ingreso de lotes físicos y el algoritmo de deducción y restitución FIFO. \\*
\hline
\textbf{Categoría} & Implementación de Comando \\*
\hline
\textbf{Relaciones} & Coordina agregados InventoryItem e InventoryBatch con repositorios bajo persistencia ACID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Supplier\allowbreak Command\allowbreak Service\allowbreak Impl & Administra el padrón comercial de proveedores, altas con validación fiscal SUNAT, actualizaciones de contacto y desactivaciones. \\*
\hline
\textbf{Categoría} & Implementación de Comando \\*
\hline
\textbf{Relaciones} & Coordina agregado Supplier y repositorio SupplierRepository con aislamiento transaccional. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Purchase\allowbreak Order\allowbreak Command\allowbreak Service\allowbreak Impl & Orquesta el ciclo de órdenes de compra, agregación de ítems, emisión formal, recepción física con alta automática de lotes y anulación. \\*
\hline
\textbf{Categoría} & Implementación de Comando \\*
\hline
\textbf{Relaciones} & Coordina agregados PurchaseOrder e InventoryItem asegurando integridad referencial en abastecimiento. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Inventory\allowbreak Item\allowbreak Query\allowbreak Service\allowbreak Impl & Atiende consultas de solo lectura del catálogo de repuestos, proyecciones paginadas, detalle con lotes activos, umbrales de stock crítico y valuación total. \\*
\hline
\textbf{Categoría} & Implementación de Consulta \\*
\hline
\textbf{Relaciones} & Consulta repositorios de inventario bajo aislamiento de solo lectura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Supplier\allowbreak Query\allowbreak Service\allowbreak Impl & Recupera información de proveedores comerciales por identificador único o listados de proveedores activos adscritos al taller. \\*
\hline
\textbf{Categoría} & Implementación de Consulta \\*
\hline
\textbf{Relaciones} & Consulta SupplierRepository bajo aislamiento de solo lectura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Purchase\allowbreak Order\allowbreak Query\allowbreak Service\allowbreak Impl & Provee recuperación de órdenes de compra individuales, expedientes detallados con líneas de repuestos y listados filtrados por proveedor o estado. \\*
\hline
\textbf{Categoría} & Implementación de Consulta \\*
\hline
\textbf{Relaciones} & Consulta PurchaseOrderRepository bajo aislamiento de solo lectura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Work\allowbreak Order\allowbreak Stock\allowbreak Reservation\allowbreak Requested\allowbreak Listener & Oyente sincrónico que atiende solicitudes de reserva de materiales provenientes de Workshop Operations, ejecutando la deducción FIFO. \\*
\hline
\textbf{Categoría} & Manejador de Eventos \\*
\hline
\textbf{Relaciones} & Invoca InventoryItemCommandService y despacha eventos de confirmación o fallo hacia el Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak application.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Work\allowbreak Order\allowbreak Stock\allowbreak Reservation\allowbreak Cancelled\allowbreak Listener & Oyente sincrónico que reacciona ante cancelaciones o rectificaciones de tareas mecánicas en foso, restituyendo piezas a sus lotes de origen. \\*
\hline
\textbf{Categoría} & Manejador de Eventos \\*
\hline
\textbf{Relaciones} & Invoca InventoryItemCommandService para liberación atómica de asignaciones FIFO. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak application.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Inventory\allowbreak Low\allowbreak Stock\allowbreak Alert\allowbreak Listener & Oyente de eventos de dominio que captura alertas cuando el saldo de un repuesto desciende del umbral mínimo de seguridad. \\*
\hline
\textbf{Categoría} & Manejador de Eventos \\*
\hline
\textbf{Relaciones} & Registra notificaciones de reposición en el panel de adquisiciones y despacha StockLowIntegrationEvent. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak application.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Inventory\allowbreak Transactional\allowbreak Outbox\allowbreak Publisher & Manejador transaccional posterior a confirmación que serializa eventos de dominio e integración en la tabla outbox\_messages. \\*
\hline
\textbf{Categoría} & Publicador Outbox \\*
\hline
\textbf{Relaciones} & Transforma y deposita eventos transaccionales en OutboxMessageRepository del Shared Kernel. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak application.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Firebase\allowbreak Receipt\allowbreak Image\allowbreak Storage\allowbreak Gateway & Puerto de salida perimetral para comprobación y resolución de URLs seguras en Firebase Storage de facturas de compra. \\*
\hline
\textbf{Categoría} & Pasarela de Almacenamiento \\*
\hline
\textbf{Relaciones} & Implementado por FirebaseStorageInvoiceClient en la capa de infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak application.\allowbreak ports} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Sunat\allowbreak Tax\allowbreak Id\allowbreak Validation\allowbreak Gateway & Puerto de salida perimetral para verificación síncrona de existencia, estado y condición tributaria de RUC ante padrones SUNAT. \\*
\hline
\textbf{Categoría} & Pasarela Fiscal \\*
\hline
\textbf{Relaciones} & Implementado por SunatRestAdapter en la capa de infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak application.\allowbreak ports} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Inventory\allowbreak Event\allowbreak Publisher\allowbreak Port & Puerto de salida para publicación de eventos de integración hacia el bus de mensajería asíncrona de la plataforma. \\*
\hline
\textbf{Categoría} & Puerto de Eventos \\*
\hline
\textbf{Relaciones} & Implementado por SpringEventPublisherAdapter o KafkaEventPublisherAdapter. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak application.\allowbreak ports} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Estructura modular del paquete com.andeva.atelier.platform.inventory.application.

**Servicios de Comandos y Orquestación Transaccional**

La ejecución de casos de uso mutacionales y la coordinación del abastecimiento y despacho de repuestos se centralizan en tres implementaciones de servicios de comandos delimitadas por agregados.

El componente **InventoryItemCommandServiceImpl** gobierna el catálogo de repuestos y el motor de costeo. Al procesar **CreateInventoryItemCommand**, valida la unicidad del código SKU en el taller y genera la pieza con saldo inicial en cero. Mediante **AddInventoryBatchCommand**, incorpora lotes físicos de adquisición directa validando la URL del comprobante en Firebase Storage y recalculando el stock total. Asimismo, atiende la demanda de piezas desde foso mediante **AllocateStockFifoCommand**, consumiendo existencias cronológicamente por lote e imputando el Costo de Ventas real, mientras que **ReleaseStockAllocationCommand** restituye unidades ante cancelaciones operativas. Finalmente, gestiona modificaciones maestras con **UpdateInventoryItemCommand** y desactiva repuestos mediante **DeactivateInventoryItemCommand** constatando la ausencia de reservas activas.

Por su parte, **SupplierCommandServiceImpl** administra el padrón de socios comerciales. Al recibir **RegisterSupplierCommand**, verifica sintácticamente el RUC de once dígitos y corrobora su condición activa y habida ante SUNAT mediante la pasarela perimetral, impidiendo registros duplicados por taller. Asimismo, actualiza la información corporativa mediante **UpdateSupplierCommand** y ejecuta la inhabilitación del proveedor con **DeactivateSupplierCommand** tras validar que no existan compras pendientes de recepción.

Por último, **PurchaseOrderCommandServiceImpl** orquesta el aprovisionamiento multi-producto. Al ejecutar **CreatePurchaseOrderCommand**, valida al proveedor adjudicado e inicializa el pedido en estado borrador con correlativo secuencial. Administra la composición de repuestos mediante **AddPurchaseOrderItemCommand** y **RemovePurchaseOrderItemCommand**, recalculando atómicamente el costo consolidado. Tras emitir la orden formalmente con **IssuePurchaseOrderCommand**, procesa la recepción física mediante **ReceivePurchaseOrderCommand**, verificando la factura escaneada en Firebase Storage, conmutando el estado a recibido y generando automáticamente un lote físico FIFO en almacén por cada línea adquirida. En caso de desistimiento, **CancelPurchaseOrderCommand** anula la orden antes de su recepción física.

Para sintetizar los flujos mutacionales, en la @tbl:inventory-command-services se detallan las operaciones, comandos de entrada, reglas de consistencia transaccional y tipos de retorno de los servicios de comandos.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Operaciones Transaccionales de los Servicios de Comandos de Inventory \& Supply Chain} \label{tbl:inventory-command-services} \\
\hline
\thfirst{Aspecto de Operación} & \thcell{Especificación de Orquestación y Consistencia} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Operación} & \thcell{Especificación de Orquestación y Consistencia} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} InventoryItemCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{CreateInventoryItemCommand} $\longrightarrow$ \texttt{Result<\allowbreak InventoryItem,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida unicidad de SKU en el taller. Instancia InventoryItem en estado ACTIVE con stock inicial en cero y emite InventoryItemCreatedEvent. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} InventoryItemCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{AddInventoryBatchCommand} $\longrightarrow$ \texttt{Result<\allowbreak InventoryBatch,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida repuesto y existencia del proveedor comercial si aplica. Verifica URL del comprobante en Firebase Storage, añade el lote físico, recalcula existencias e incrementa versión de concurrencia optimista. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} InventoryItemCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{AllocateStockFifoCommand} $\longrightarrow$ \texttt{Result<\allowbreak StockAllocation,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Constata que existencias totales satisfagan la cantidad demandada. Ejecuta deducción cronológica sobre lotes activos (arrivalDate ASC), actualiza saldo remanente y computa el Costo de Ventas exacto. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} InventoryItemCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{ReleaseStockAllocationCommand} $\longrightarrow$ \texttt{Result<\allowbreak Void,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Restituye las unidades previamente reservadas a cada lote físico de procedencia y actualiza el saldo consolidado totalStock del agregado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} InventoryItemCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{UpdateInventoryItemCommand} $\longrightarrow$ \texttt{Result<\allowbreak InventoryItem,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Modifica descripción, categoría, precio base de venta y umbral de stock mínimo de un repuesto existente garantizando parámetros cuantitativos válidos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} InventoryItemCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{DeactivateInventoryItemCommand} $\longrightarrow$ \texttt{Result<\allowbreak Void,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Constata que el repuesto carezca de reservas activas en órdenes de trabajo en curso, conmuta estado a INACTIVE y emite InventoryItemDeactivatedEvent. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} SupplierCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{RegisterSupplierCommand} $\longrightarrow$ \texttt{Result<\allowbreak Supplier,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida sintaxis y condición activa y habida del RUC de once dígitos ante SUNAT. Verifica unicidad de RUC por taller e instancia el proveedor en estado activo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} SupplierCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{UpdateSupplierCommand} $\longrightarrow$ \texttt{Result<\allowbreak Supplier,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Actualiza nombre de contacto, número telefónico, correo corporativo y dirección fiscal de un proveedor comercial registrado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} SupplierCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{DeactivateSupplierCommand} $\longrightarrow$ \texttt{Result<\allowbreak Void,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Constata que el proveedor no posea órdenes de compra en estado ISSUED pendientes de recepción y suspende su condición operativa. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} PurchaseOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{CreatePurchaseOrderCommand} $\longrightarrow$ \texttt{Result<\allowbreak PurchaseOrder,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida proveedor adjudicado y sede receptora. Asigna número correlativo secuencial e inicializa la orden en estado DRAFT con costo cero. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} PurchaseOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{AddPurchaseOrderItemCommand} $\longrightarrow$ \texttt{Result<\allowbreak PurchaseOrder,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Verifica estado DRAFT y existencia del repuesto en catálogo. Agrega la línea de compra y recalcula atómicamente el costo total de la orden. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} PurchaseOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{RemovePurchaseOrderItemCommand} $\longrightarrow$ \texttt{Result<\allowbreak PurchaseOrder,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Verifica estado DRAFT de la orden de compra, elimina el ítem seleccionado y deduce su subtotal del costo consolidado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} PurchaseOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{IssuePurchaseOrderCommand} $\longrightarrow$ \texttt{Result<\allowbreak PurchaseOrder,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida que la orden contenga al menos un ítem registrado, conmuta el estado a ISSUED y registra PurchaseOrderIssuedIntegrationEvent en el Outbox. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} PurchaseOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{ReceivePurchaseOrderCommand} $\longrightarrow$ \texttt{Result<\allowbreak PurchaseOrder,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida estado ISSUED, comprueba factura en Firebase Storage y asigna número de comprobante. Conmuta a RECEIVED, crea automáticamente los lotes FIFO vinculados y emite PurchaseOrderReceivedIntegrationEvent. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} PurchaseOrderCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{CancelPurchaseOrderCommand} $\longrightarrow$ \texttt{Result<\allowbreak PurchaseOrder,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Verifica que la orden no haya alcanzado estado RECEIVED, asigna motivo de anulación formal y conmuta a CANCELED. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Clases ubicadas bajo el paquete com.andeva.atelier.platform.inventory.application.services.

**Servicios de Consulta y Proyecciones de Lectura**

La recuperación de información y la alimentación de interfaces de usuario se estructuran mediante servicios de consulta especializados configurados bajo aislamiento transaccional de solo lectura, suprimiendo la sobrecarga de seguimiento de cambios en el motor de persistencia relacional.

El componente **InventoryItemQueryServiceImpl** atiende las consultas del almacén automotriz mediante proyecciones optimizadas. Provee la recuperación exhaustiva de repuestos individuales (**GetInventoryItemByIdQuery**), catálogos paginados con filtrado por texto y categoría (**GetInventoryItemsPagedQuery**) y expedientes detallados con desglose cronológico de lotes con saldo activo (**GetInventoryItemDetailQuery**). Asimismo, identifica piezas en desabastecimiento crítico (**GetLowStockItemsQuery**) y calcula la valuación monetaria global del inventario (**GetInventoryValuationQuery**) a través de la suma ponderada del saldo remanente por costo de adquisición de cada lote.

Complementariamente, **SupplierQueryServiceImpl** canaliza las consultas sobre el directorio comercial de proveedores, recuperando fichas individuales por identificador (**GetSupplierByIdQuery**) o listados completos de proveedores activos adscritos a la empresa automotriz (**GetSuppliersByTenantIdQuery**). Por último, **PurchaseOrderQueryServiceImpl** provee la consulta de órdenes de compra individuales (**GetPurchaseOrderByIdQuery**), expedientes detallados con sus líneas de ítems y comprobantes probatorios (**GetPurchaseOrderDetailQuery**) y relaciones históricas filtradas por sucursal o estado operativo (**GetPurchaseOrdersByTenantIdQuery**).

Con el propósito de consolidar estos contratos de lectura, en la @tbl:inventory-query-services se presentan las firmas de los métodos de consulta, sus parámetros y los modelos inmutables proyectados por los servicios de consulta.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Métodos de Consulta de la Capa de Aplicación de Inventory \& Supply Chain} \label{tbl:inventory-query-services} \\
\hline
\thfirst{Aspecto de Consulta} & \thcell{Especificación Técnica y Recuperación} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Consulta} & \thcell{Especificación Técnica y Recuperación} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} InventoryItemQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetInventoryItemByIdQuery} $\longrightarrow$ \texttt{Optional<\allowbreak InventoryItem>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Consulta integral de agregado de repuesto por identificador UUID dentro del taller autenticado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} InventoryItemQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetInventoryItemsPagedQuery} $\longrightarrow$ \texttt{PagedModel<\allowbreak InventoryItemSummaryProjection>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Catálogo paginado de repuestos con filtrado por categoría, estado operativo y coincidencia textual en nombre o SKU. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} InventoryItemQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetInventoryItemDetailQuery} $\longrightarrow$ \texttt{Optional<\allowbreak InventoryItemDetailProjection>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Proyección enriquecida con información maestra del repuesto y desglose cronológico de lotes activos con saldo remanente. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} InventoryItemQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetLowStockItemsQuery} $\longrightarrow$ \texttt{List<\allowbreak InventoryItemSummaryProjection>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Identificación de piezas mecánicas con existencias inferiores o iguales al umbral de stock mínimo configurado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} InventoryItemQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetInventoryValuationQuery} $\longrightarrow$ \texttt{InventoryValuationProjection} \\*
\hline
\textbf{Propósito de Consulta} & Computación contable del valor monetario total del almacén mediante suma ponderada de saldo remanente y costo unitario por lote. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} SupplierQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetSupplierByIdQuery} $\longrightarrow$ \texttt{Optional<\allowbreak Supplier>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Consulta de la ficha comercial y condición tributaria de un proveedor específico por identificador UUID. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} SupplierQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetSuppliersByTenantIdQuery} $\longrightarrow$ \texttt{List<\allowbreak SupplierSummaryProjection>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Directorio comercial de proveedores del taller con filtrado opcional por condición activa para compras. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} PurchaseOrderQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetPurchaseOrderByIdQuery} $\longrightarrow$ \texttt{Optional<\allowbreak PurchaseOrder>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Recuperación de cabecera de orden de compra con sede física, proveedor y estado operativo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} PurchaseOrderQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetPurchaseOrderDetailQuery} $\longrightarrow$ \texttt{Optional<\allowbreak PurchaseOrderDetailProjection>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Proyección detallada de la orden con colección de repuestos adquiridos, costos unitarios, comprobante escaneado y fecha de recepción. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} PurchaseOrderQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetPurchaseOrdersByTenantIdQuery} $\longrightarrow$ \texttt{List<\allowbreak PurchaseOrderSummaryProjection>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Historial de órdenes de compra adscritas a la empresa con filtros por proveedor, sucursal de recepción y estado de ciclo de vida. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Clases ubicadas bajo el paquete com.andeva.atelier.platform.inventory.application.services.

**Manejadores de Eventos de Dominio y Publicación Asíncrona**

La arquitectura reactiva del Bounded Context articula la sincronización intermodular diferenciando las acciones locales inmediatas de las propagaciones transaccionales asíncronas.

El componente **WorkOrderStockReservationRequestedListener** escucha síncronamente las demandas de materiales emitidas desde Workshop Operations ante la asignación de repuestos en labores mecánicas. Ejecuta atómicamente la reserva FIFO sobre los lotes físicos de la pieza, despachando **StockReservedIntegrationEvent** con el Costo de Ventas imputado hacia el Transactional Outbox en caso de éxito, o emitiendo **StockReservationFailedIntegrationEvent** si el inventario resulta insuficiente para pausar oportunamente la tarea técnica en foso. En sentido inverso, **WorkOrderStockReservationCancelledListener** procesa cancelaciones y rectificaciones de tareas, restituyendo las cantidades liberadas a sus lotes de procedencia.

Asimismo, **InventoryLowStockAlertListener** atiende el evento de dominio emitido cuando el saldo total de un repuesto desciende del umbral de seguridad, canalizando la alerta hacia el panel de compras para priorizar el reabastecimiento y publicando **StockLowIntegrationEvent**. Por último, **InventoryTransactionalOutboxPublisher** intercepta los eventos generados tras la confirmación de la transacción y los serializa en la tabla outbox\_messages del Shared Kernel, garantizando semántica de entrega al menos una vez hacia el bus de mensajería sin comprometer la atomicidad local.

A fin de resumir la arquitectura de eventos, en la @tbl:inventory-event-handlers se especifican las responsabilidades, fases transaccionales y destinos de los manejadores de eventos de la capa.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Manejadores de Eventos de Dominio y de Integración de Inventory \& Supply Chain} \label{tbl:inventory-event-handlers} \\
\hline
\thfirst{Aspecto del Manejador} & \thcell{Orquestación y Efecto Colateral} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Manejador} & \thcell{Orquestación y Efecto Colateral} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} WorkOrderStockReservationRequestedListener} \\*
\hline
\textbf{Evento Capturado} & \texttt{ProductStockReservationRequestedIntegrationEvent} \quad (\textit{Fase:} Inmediata) \\*
\hline
\textbf{Acción Orquestada} & Atiende la demanda de repuestos de MRO e invoca AllocateStockFifoCommand deduciendo unidades de lotes cronológicos. \\*
\hline
\textbf{Destino del Efecto} & Transactional Outbox / Event Bus \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} WorkOrderStockReservationCancelledListener} \\*
\hline
\textbf{Evento Capturado} & \texttt{ProductStockReservationCancelledIntegrationEvent} \quad (\textit{Fase:} Inmediata) \\*
\hline
\textbf{Acción Orquestada} & Captura la liberación de repuestos por modificación o cancelación en foso e invoca ReleaseStockAllocationCommand restituyendo saldo a los lotes. \\*
\hline
\textbf{Destino del Efecto} & InventoryItemCommandService / Base de Datos \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} InventoryLowStockAlertListener} \\*
\hline
\textbf{Evento Capturado} & \texttt{StockLowEvent} \quad (\textit{Fase:} Posterior a confirmación) \\*
\hline
\textbf{Acción Orquestada} & Procesa la alerta por existencias inferiores al umbral de seguridad generando la notificación de reposición y despachando StockLowIntegrationEvent. \\*
\hline
\textbf{Destino del Efecto} & Transactional Outbox / Panel de Adquisiciones \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} InventoryTransactionalOutboxPublisher} \\*
\hline
\textbf{Evento Capturado} & \texttt{DomainEvent} o \texttt{IntegrationEvent} \quad (\textit{Fase:} Posterior a confirmación) \\*
\hline
\textbf{Acción Orquestada} & Serializa eventos de dominio e integración en formato JSON e inserta registros en la tabla outbox\_messages garantizando entrega al menos una vez. \\*
\hline
\textbf{Destino del Efecto} & Tabla outbox\_messages / Message Broker \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Clases ubicadas bajo el paquete com.andeva.atelier.platform.inventory.application.events.

**Puertos de Salida y Pasarelas de Integración**

Para salvaguardar la independencia de la lógica de aplicación frente a dependencias externas y servicios de terceros, la capa delimita contratos formales de puertos de salida en su perímetro arquitectónico.

El puerto **FirebaseReceiptImageStorageGateway** materializa la pasarela hacia Firebase Cloud Storage, permitiendo la validación perimetral de URLs seguras, comprobación de firmas criptográficas y metadatos de las facturas y boletas escaneadas durante el alta de lotes físicos o la recepción formal de órdenes de compra.

Por su parte, **SunatTaxIdValidationGateway** provee el enlace de consulta hacia los servicios de padrón tributario de SUNAT, validando en tiempo real la validez del número RUC, la razón social legal y la condición de activo y habido antes de formalizar la incorporación de un nuevo proveedor comercial al taller.

Finalmente, **InventoryEventPublisherPort** encapsula el mecanismo de publicación de eventos de integración hacia el bus de eventos de la plataforma, posibilitando la notificación desacoplada hacia los módulos de operaciones de taller, facturación y contabilidad analítica sin generar acoplamientos técnicos a brokers específicos.

Con el objeto de sistematizar las dependencias perimetrales, en la @tbl:inventory-outbound-ports se describen los métodos y responsabilidades técnicas de estos puertos de salida y pasarelas de integración.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.1cm} | >{\raggedright\arraybackslash}p{10.3cm} |}
\caption{Puertos de Salida y Pasarelas de la Capa de Aplicación de Inventory \& Supply Chain} \label{tbl:inventory-outbound-ports} \\
\hline
\thfirst{Aspecto del Componente} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Componente} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} FirebaseReceiptImageStorageGateway \quad (\textit{Categoría:} Pasarela de Almacenamiento)} \\*
\hline
\textbf{Métodos Principales} & \texttt{validateStorageUrl}, \texttt{verifyReceiptFileMetadata}, \texttt{generateReadPresignedUrl} \\*
\hline
\textbf{Responsabilidad Técnica} & Validación perimetral, comprobación de metadatos y generación de URLs de acceso seguro en Firebase Storage para comprobantes de compra. \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak application.\allowbreak ports} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} SunatTaxIdValidationGateway \quad (\textit{Categoría:} Pasarela Fiscal)} \\*
\hline
\textbf{Métodos Principales} & \texttt{validateTaxId}, \texttt{queryTaxpayerStatus}, \texttt{isTaxpayerHabido} \\*
\hline
\textbf{Responsabilidad Técnica} & Consulta síncrona a servicios de padrón tributario para certificar razón social, estado activo y condición de habido de proveedores comerciales. \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak application.\allowbreak ports} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} InventoryEventPublisherPort \quad (\textit{Categoría:} Puerto de Eventos)} \\*
\hline
\textbf{Métodos Principales} & \texttt{publishEvent}, \texttt{publishAllEvents} \\*
\hline
\textbf{Responsabilidad Técnica} & Despacho perimetral de eventos de integración hacia el bus de mensajería distribuido para comunicación reactiva con otros módulos. \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak inventory.\allowbreak application.\allowbreak ports} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Clases ubicadas bajo el paquete com.andeva.atelier.platform.inventory.application.ports.

**Análisis Arquitectónico y Rigor Operacional de la Capa de Aplicación**

En primer lugar, la orquestación transaccional implementada garantiza la disciplina contable y la consistencia atómica en el cálculo del Costo de Mercadería Vendida mediante la asignación FIFO sobre lotes físicos. Al gobernar la deducción cronológica bajo transacciones de lectura confirmada y concurrencia optimista, se asegura que cada pieza consumida en foso liquide exactamente el valor monetario de adquisición de su remesa de ingreso, erradicando distorsiones contables y protegiendo el margen bruto del taller automotriz.

En segundo término, la centralización probatoria articulada en la recepción física de órdenes de compra multi-producto consolida una trazabilidad auditable sin sobrecargar el servidor de aplicaciones. Al vincular múltiples líneas de repuestos a un comprobante fiscal escaneado y validado en Firebase Cloud Storage mediante transferencias directas, el backend delega el tráfico binario pesado y preserva evidencia inalterable ante fiscalizaciones tributarias, simplificando la incorporación de inventario y acelerando el abastecimiento.

Por último, el desacoplamiento reactivo sustentado en el patrón Transactional Outbox previene sistemáticamente quiebres de existencias y resguarda la continuidad de las operaciones mecánicas. La publicación atómica de alertas de inventario crítico y la sincronización asíncrona de eventos de reserva con Workshop Operations y Facturación Electrónica permiten mantener informado al departamento de compras en tiempo real, evitando detenciones prolongadas de vehículos en elevador y blindando la consistencia intermodular frente a fallos transitorios de red.

#### 2.6.5.4. Infrastructure Layer

La Capa de Infraestructura del Bounded Context Inventory & Supply Chain materializa técnicamente los puertos de persistencia física, seguridad y comunicación perimetral definidos en los contratos de Dominio y Aplicación. Su implementación reside en el paquete canónico com.andeva.atelier.platform.inventory.infrastructure, proveyendo el soporte relacional en PostgreSQL 16 sobre la infraestructura en la nube de Aiven Cloud mediante Spring Data JPA e Hibernate ORM.

Asimismo, esta capa gobierna la transformación bidireccional entre los modelos inmutables del negocio y los esquemas de base de datos, asegura la neutralidad de eventos mediante la reconstitución aséptica de agregados, y garantiza el despacho atómico de eventos hacia la tabla transaccional **outbox_messages**. De igual forma, gestiona la integración perimetral con Google Cloud Storage y Firebase para comprobantes fiscales de compra, la validación en tiempo real de proveedores ante SUNAT y la coordinación reactiva con Workshop Operations.

El diseño arquitectónico de este subsistema de infraestructura se fundamenta en cuatro directrices esenciales:

- **Desacoplamiento Estricto de Persistencia e Inversión de Dependencias:** Las entidades y agregados del dominio carecen por completo de anotaciones del estándar Jakarta Persistence. La persistencia física se confina en entidades JPA especializadas que heredan un identificador primario universal y marcas temporales automáticas de auditoría desde la superclase **AuditableAbstractPersistenceEntity**.

- **Normalización y Persistencia Determinista de Objetos de Valor:** Los objetos de valor inmutables se traducen de forma transparente hacia tipos escalares nativos mediante convertidores JPA dedicados. Esta estrategia garantiza la integridad de invariantes como códigos SKU normalizados, registros de RUC de 11 dígitos, cantidades físicas e importes monetarios con precisión contable sin acoplar el núcleo de dominio al dialecto relacional.

- **Consistencia Transaccional Mediante Transactional Outbox:** Las operaciones mutacionales orquestadas por los adaptadores de repositorio ejecutan la persistencia relacional y la inserción del evento de dominio en la tabla transaccional **outbox_messages** dentro de la misma transacción de base de datos, garantizando una semántica de entrega al menos una vez hacia consumidores asíncronos.

- **Validación Perimetral Tributaria y Gestión Multimedia Cloud:** La certificación de proveedores comerciales se verifica en tiempo real ante el padrón oficial de SUNAT mediante un cliente seguro con caché en memoria. Paralelamente, la recepción física de compras vincula comprobantes digitales mediante pasarelas de nube que emiten identificadores de subida directa hacia Google Cloud Storage, suprimiendo la sobrecarga de memoria en el servidor backend.

A fin de ofrecer una visión sistemática de estos componentes, en la @tbl:inventory-infrastructure-types se presenta el catálogo consolidado de los tipos técnicos que conforman la Capa de Infraestructura de Inventory & Supply Chain.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo Consolidado de la Capa de Infraestructura de Inventory \& Supply Chain} \label{tbl:inventory-infrastructure-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\
\hline
\endhead
InventoryItem\allowbreak Persistence\allowbreak Entity & Mapeo relacional del catálogo maestro de repuestos e insumos a la tabla física inventory\_items. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Hereda de AuditableAbstractPersistenceEntity. Raíz de persistencia de ítems. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
InventoryBatch\allowbreak Persistence\allowbreak Entity & Mapeo relacional de lotes físicos de adquisición con costeo inmutable a inventory\_batches. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Clave foránea a inventory\_items. Soporta valoración cronológica FIFO. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
Supplier\allowbreak Persistence\allowbreak Entity & Mapeo relacional del directorio de distribuidores de repuestos a la tabla suppliers. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Hereda de AuditableAbstractPersistenceEntity. Custodia RUC y datos comerciales. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
PurchaseOrder\allowbreak Persistence\allowbreak Entity & Mapeo relacional de órdenes formales de reabastecimiento a la tabla purchase\_orders. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Hereda de AuditableAbstractPersistenceEntity. Clave foránea a proveedores y sedes. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
PurchaseOrderItem\allowbreak Persistence\allowbreak Entity & Mapeo relacional de líneas de detalle de adquisición a purchase\_order\_items. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Clave foránea a purchase\_orders y a inventory\_items. Origina lotes al recibir. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
InventoryItem\allowbreak Persistence\allowbreak Repository & Interfaz Spring Data JPA para persistencia relacional y consultas de piezas de inventario. \\*
\hline
\textbf{Categoría} & Repositorio JPA \\*
\hline
\textbf{Relaciones} & Extiende JpaRepository. Consultas derivadas por SKU y búsquedas de catálogo. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
InventoryBatch\allowbreak Persistence\allowbreak Repository & Interfaz Spring Data JPA para resolución indexada de lotes físicos y valuación total. \\*
\hline
\textbf{Categoría} & Repositorio JPA \\*
\hline
\textbf{Relaciones} & Extiende JpaRepository. Consultas ordenadas por arrivalDate ascendente para FIFO. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
Supplier\allowbreak Persistence\allowbreak Repository & Interfaz Spring Data JPA para administración del registro comercial de proveedores. \\*
\hline
\textbf{Categoría} & Repositorio JPA \\*
\hline
\textbf{Relaciones} & Extiende JpaRepository. Localización por RUC y razón social en el taller. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
PurchaseOrder\allowbreak Persistence\allowbreak Repository & Interfaz Spring Data JPA para trazabilidad documental de pedidos de reabastecimiento. \\*
\hline
\textbf{Categoría} & Repositorio JPA \\*
\hline
\textbf{Relaciones} & Extiende JpaRepository. Generación de correlativos y consultas por proveedor. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
PurchaseOrderItem\allowbreak Persistence\allowbreak Repository & Interfaz Spring Data JPA para consulta de ítems asociados a órdenes de compra. \\*
\hline
\textbf{Categoría} & Repositorio JPA \\*
\hline
\textbf{Relaciones} & Extiende JpaRepository. Proyección de líneas adquiridas por orden de compra. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
InventoryItem\allowbreak Repository\allowbreak Impl & Adaptador secundario de salida que implementa el puerto InventoryItemRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Persistencia \\*
\hline
\textbf{Relaciones} & Orquesta guardado relacional, extracción atómica de eventos y registro en Outbox. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak adapters} \\
\hline
Supplier\allowbreak Repository\allowbreak Impl & Adaptador secundario de salida que implementa el puerto SupplierRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Persistencia \\*
\hline
\textbf{Relaciones} & Persiste proveedores comerciales y despacha eventos **SupplierRegisteredEvent** a Outbox. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak adapters} \\
\hline
PurchaseOrder\allowbreak Repository\allowbreak Impl & Adaptador secundario de salida que implementa el puerto PurchaseOrderRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Persistencia \\*
\hline
\textbf{Relaciones} & Persiste órdenes en cascada y emite eventos **PurchaseOrderReceivedEvent** a Outbox. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak adapters} \\
\hline
InventoryItem\allowbreak Persistence\allowbreak Assembler & Transformación bidireccional entre agregado puro InventoryItem y entidad relacional. \\*
\hline
\textbf{Categoría} & Ensamblador de Persistencia \\*
\hline
\textbf{Relaciones} & Reconstituye el agregado con lotes ordenados sin disparar eventos espurios. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak transform} \\
\hline
InventoryBatch\allowbreak Persistence\allowbreak Assembler & Transformación bidireccional para remesas físicas de piezas y consumos FIFO. \\*
\hline
\textbf{Categoría} & Ensamblador de Persistencia \\*
\hline
\textbf{Relaciones} & Mapea cantidades remanentes, costos y URLs periciales hacia InventoryBatch. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak transform} \\
\hline
Supplier\allowbreak Persistence\allowbreak Assembler & Transformación bidireccional entre agregado Supplier y entidad relacional. \\*
\hline
\textbf{Categoría} & Ensamblador de Persistencia \\*
\hline
\textbf{Relaciones} & Traduce cadenas escalares hacia objetos de valor TaxId y datos de contacto. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak transform} \\
\hline
PurchaseOrder\allowbreak Persistence\allowbreak Assembler & Transformación bidireccional para órdenes de compra y colecciones de líneas. \\*
\hline
\textbf{Categoría} & Ensamblador de Persistencia \\*
\hline
\textbf{Relaciones} & Reconstituye PurchaseOrder sincronizando estados operativos y totales monetarios. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak transform} \\
\hline
PurchaseOrderItem\allowbreak Persistence\allowbreak Assembler & Transformación bidireccional para renglones individuales de órdenes de compra. \\*
\hline
\textbf{Categoría} & Ensamblador de Persistencia \\*
\hline
\textbf{Relaciones} & Mapea cantidades y costos unitarios hacia la entidad PurchaseOrderItem. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak transform} \\
\hline
Sku\allowbreak Attribute\allowbreak Converter & Conversión bidireccional entre objeto de valor Sku y columna VARCHAR(50). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Normaliza códigos alfanuméricos de piezas garantizando mayúsculas en base de datos. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
TaxId\allowbreak Attribute\allowbreak Converter & Conversión bidireccional entre objeto de valor TaxId y columna VARCHAR(20). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Serializa el RUC tributario de 11 dígitos con validación previa de integridad. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
Quantity\allowbreak Attribute\allowbreak Converter & Conversión bidireccional entre Quantity y columna NUMERIC(10, 2). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Garantiza precisión decimal estricta y redondeo bancario para existencias físicas. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
Money\allowbreak Attribute\allowbreak Converter & Conversión bidireccional entre objeto de valor Money y columna NUMERIC(10, 2). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Extrae BigDecimal preservando exactitud contable en costos unitarios y precios. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
ItemCategory\allowbreak Attribute\allowbreak Converter & Conversión bidireccional entre enumeración ItemCategory y columna VARCHAR(50). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Mapea las categorías de repuestos LUBRICANTS, BRAKES, SUSPENSION o ENGINE. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
InventoryItemStatus\allowbreak Attribute\allowbreak Converter & Conversión bidireccional entre InventoryItemStatus y columna VARCHAR(20). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Normaliza estados operativos active, inactive y discontinued. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
PurchaseOrderStatus\allowbreak Attribute\allowbreak Converter & Conversión bidireccional entre PurchaseOrderStatus y columna VARCHAR(20). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Normaliza estados de pedido draft, issued, received y canceled. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
FirebaseReceiptImage\allowbreak StorageGatewayImpl & Pasarela cloud que emite URLs pre-firmadas PUT hacia Google Cloud Storage. \\*
\hline
\textbf{Categoría} & Pasarela Cloud de Salida \\*
\hline
\textbf{Relaciones} & Valida comprobantes de compra y elimina la congestión binaria en la API backend. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak infrastructure.\allowbreak external.\allowbreak firebase} \\
\hline
SunatTaxId\allowbreak ValidationGatewayImpl & Pasarela perimetral que valida la condición tributaria de proveedores en SUNAT. \\*
\hline
\textbf{Categoría} & Pasarela Perimetral Externa \\*
\hline
\textbf{Relaciones} & Cliente HTTP REST seguro con caché Caffeine de 24 horas para certificar RUC. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak infrastructure.\allowbreak external.\allowbreak sunat} \\
\hline
InventoryTransactional\allowbreak OutboxPublisherImpl & Publicador transaccional que persiste eventos atómicos en outbox\_messages. \\*
\hline
\textbf{Categoría} & Adaptador de Mensajería \\*
\hline
\textbf{Relaciones} & Serializa cargas útiles en formato JSONB para despacho confiable con Debezium. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak infrastructure.\allowbreak external.\allowbreak outbox} \\
\hline
WorkshopOperations\allowbreak AclAdapter & Adaptador anticorrupción de salida hacia el contexto de Workshop Operations. \\*
\hline
\textbf{Categoría} & Adaptador ACL de Salida \\*
\hline
\textbf{Relaciones} & Coordina la reserva de repuestos en tareas y la confirmación contable FIFO. \\*
\hline
\textbf{Paquete} & \texttt{...\allowbreak infrastructure.\allowbreak external.\allowbreak operations} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes configurados bajo el paquete canónico com.andeva.atelier.platform.inventory.infrastructure.

**Entidades de Persistencia JPA y Modelado Relacional Físico**

El modelado relacional de persistencia reproduce fielmente la topología logística del almacén automotriz mediante cinco entidades JPA mapeadas a sus respectivas tablas físicas en PostgreSQL 16. La raíz de persistencia **InventoryItemPersistenceEntity** se vincula a la tabla **inventory_items**, encapsulando el código de parte unívoco por taller, la denominación comercial, categoría taxonómica, precio base sugerido, stock total consolidado y umbral de seguridad.

Por su parte, la entidad **InventoryBatchPersistenceEntity** representa las remesas físicas de piezas en la tabla **inventory_batches**, modelando el costo unitario real de adquisición, fecha de arribo y saldo remanente. Un aspecto central de esta entidad es su índice B-Tree compuesto sobre item_id, arrival_date ascendente y remaining_quantity, permitiendo al motor relacional resolver deducciones FIFO en tiempo logarítmico sin incurrir en ordenamientos en memoria ni escaneos secuenciales de tabla.

Asimismo, los distribuidores de repuestos se registran en **SupplierPersistenceEntity**, mientras que las adquisiciones formales se distribuyen entre **PurchaseOrderPersistenceEntity** para la cabecera del pedido y **PurchaseOrderItemPersistenceEntity** para las líneas de piezas demandadas. Esta jerarquía vincula comprobantes tributarios digitales y asegura la trazabilidad documental de cada repuesto incorporado al catálogo del taller.

Con el propósito de especificar la correlación física y estructural del modelo relacional, en la @tbl:inventory-jpa-entities se detallan las entidades JPA, sus tablas correspondientes, columnas principales, restricciones e índices.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Especificación Relacional de Entidades JPA de Inventory \& Supply Chain} \label{tbl:inventory-jpa-entities} \\
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} InventoryItemPersistenceEntity \quad (\textit{Tabla:} \texttt{inventory\_items})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{tenant\_id}, \texttt{sku}, \texttt{name}, \texttt{description}, \texttt{category}, \texttt{base\_price}, \texttt{total\_stock}, \texttt{minimum\_stock}, \texttt{status} \\*
\hline
\textbf{Restricciones e Índices} & Restricción única uk\_inventory\_items\_tenant\_sku sobre tupla (tenant\_id, sku). Clave foránea a tenants. Índices idx\_inventory\_items\_tenant\_status e idx\_inventory\_items\_search sobre (tenant\_id, name, sku). Colección bidireccional ordenada con inventory\_batches. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} InventoryBatchPersistenceEntity \quad (\textit{Tabla:} \texttt{inventory\_batches})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{item\_id}, \texttt{supplier\_id}, \texttt{purchase\_order\_id}, \texttt{batch\_number}, \texttt{initial\_quantity}, \texttt{remaining\_quantity}, \texttt{unit\_cost}, \texttt{arrival\_date}, \texttt{receipt\_image\_url} \\*
\hline
\textbf{Restricciones e Índices} & Claves foráneas fk\_batches\_item a inventory\_items, fk\_batches\_supplier a suppliers y fk\_batches\_purchase\_order a purchase\_orders. Restricciones de verificación en cantidades y costo no negativos. Índice compuesto B-Tree idx\_batches\_fifo sobre (item\_id, arrival\_date ASC, remaining\_quantity) para deducción en tiempo logarítmico. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} SupplierPersistenceEntity \quad (\textit{Tabla:} \texttt{suppliers})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{tenant\_id}, \texttt{business\_name}, \texttt{tax\_id}, \texttt{contact\_name}, \texttt{phone}, \texttt{email}, \texttt{address}, \texttt{is\_active} \\*
\hline
\textbf{Restricciones e Índices} & Restricción única uk\_suppliers\_tenant\_tax\_id sobre (tenant\_id, tax\_id). Clave foránea a tenants. Índice idx\_suppliers\_tenant\_tax\_id para búsquedas directas por RUC e idx\_suppliers\_search sobre (tenant\_id, business\_name) para autocompletado y catálogo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} PurchaseOrderPersistenceEntity \quad (\textit{Tabla:} \texttt{purchase\_orders})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{tenant\_id}, \texttt{supplier\_id}, \texttt{branch\_id}, \texttt{order\_number}, \texttt{status}, \texttt{total\_cost}, \texttt{currency}, \texttt{receipt\_image\_url}, \texttt{receipt\_number}, \texttt{received\_at} \\*
\hline
\textbf{Restricciones e Índices} & Restricción única uk\_purchase\_orders\_tenant\_number sobre (tenant\_id, order\_number). Claves foráneas hacia tenants, suppliers y branches. Índices idx\_purchase\_orders\_tenant\_status, idx\_purchase\_orders\_supplier e idx\_purchase\_orders\_branch. Colección en cascada con purchase\_order\_items con eliminación de huérfanos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} PurchaseOrderItemPersistenceEntity \quad (\textit{Tabla:} \texttt{purchase\_order\_items})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{purchase\_order\_id}, \texttt{item\_id}, \texttt{quantity}, \texttt{unit\_cost}, \texttt{total\_cost} \\*
\hline
\textbf{Restricciones e Índices} & Claves foráneas fk\_po\_items\_order a purchase\_orders y fk\_po\_items\_item a inventory\_items. Restricciones de verificación en cantidad positiva y costos no negativos. Índices idx\_po\_items\_order e idx\_po\_items\_item. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Tablas físicas alojadas en el motor PostgreSQL 16 con herencia de auditoría temporal en la base de datos central.

**Repositorios Spring Data JPA y Adaptadores de Persistencia**

La interacción técnica con la base de datos se desacopla mediante el patrón Adaptador de Repositorio. Las interfaces Spring Data JPA declaran operaciones optimizadas de acceso a datos y consultas derivadas, mientras que las clases adaptadoras implementan formalmente los contratos de persistencia definidos en la Capa de Dominio.

Durante las operaciones de mutación, el adaptador **InventoryItemRepositoryImpl** transforma el agregado puro en su representación relacional mediante su ensamblador, persiste el registro a través de **InventoryItemPersistenceRepository**, extrae la colección de eventos acumulados y los canaliza al publicador transaccional para su registro en **outbox_messages**. Este mismo flujo atómico garantiza la consistencia en **SupplierRepositoryImpl** y **PurchaseOrderRepositoryImpl**.

A fin de sistematizar las responsabilidades y contratos de persistencia, en la @tbl:inventory-repository-adapters se especifican los adaptadores de repositorio, sus puertos de dominio asociados y las operaciones relacionales implementadas.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Adaptadores de Persistencia y Puertos de Dominio de Inventory \& Supply Chain} \label{tbl:inventory-repository-adapters} \\
\hline
\thfirst{Aspecto de Adaptador} & \thcell{Especificación Técnica y Persistencia} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Adaptador} & \thcell{Especificación Técnica y Persistencia} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} InventoryItemRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{InventoryItemRepository} \\*
\hline
\textbf{Repositorios Inyectados} & \texttt{InventoryItemPersistenceRepository}, \texttt{InventoryBatchPersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & Mapea el agregado **InventoryItem** a su entidad relacional mediante ensamblador. Persiste en PostgreSQL 16 mediante *saveAndFlush()*. Extrae eventos acumulados mediante *pullDomainEvents()* y los canaliza al publicador transaccional hacia outbox\_messages. Ejecuta *findById()* con hidratación cronológica de lotes, *findByTenantIdAndSku()* para resolución por código natural de parte, *findLowStockItems()* para detección preventiva de repuestos en umbral crítico y *existsByTenantIdAndSku()* para prevención de duplicados. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} SupplierRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{SupplierRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{SupplierPersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & Persiste y actualiza fichas de distribuidores comerciales. Despacha el evento **SupplierRegisteredEvent** en altas nuevas hacia outbox\_messages. Ejecuta *findById()* con validación de inquilino, *findByTenantIdAndTaxId()* para resolución unívoca por RUC de 11 dígitos, *existsByTenantIdAndTaxId()* para verificación de unicidad fiscal previa al registro y *searchByBusinessName()* para autocompletado en emisión de órdenes. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} PurchaseOrderRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{PurchaseOrderRepository} \\*
\hline
\textbf{Repositorios Inyectados} & \texttt{PurchaseOrderPersistenceRepository}, \texttt{PurchaseOrderItemPersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & Persiste en cascada la cabecera de la orden y las líneas de detalle. Al transicionar a RECEIVED emite **PurchaseOrderReceivedEvent** en outbox\_messages para originar lotes FIFO dependientes. Ejecuta *findById()* con carga de detalles y URL de comprobante digital, *findByTenantIdAndOrderNumber()* para consulta de órdenes por código correlativo y *findNextOrderSequence()* con consulta agregada para correlación atómica de pedidos. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Clases ubicadas bajo el paquete canónico com.andeva.atelier.platform.inventory.infrastructure.persistence.jpa.adapters.

**Ensambladores de Persistencia y Convertidores JPA**

La correspondencia entre estructuras inmutables del dominio y modelos relacionales mutables se resuelve a través de cinco ensambladores de persistencia dedicados. Estos componentes extraen los valores escalares de las entidades JPA y reconstruyen los agregados puros en memoria invocando métodos estáticos de fábrica controlados como *InventoryItem.reconstitute()*, garantizando que la lectura no dispare eventos de dominio espurios.

De forma complementaria, siete convertidores de atributos JPA estandarizan la serialización de objetos de valor y enumeraciones del negocio hacia columnas relacionales nativas. Los convertidores **SkuAttributeConverter**, **TaxIdAttributeConverter**, **QuantityAttributeConverter** y **MoneyAttributeConverter** preservan la precisión y reglas semánticas, mientras que los convertidores de estado normalizan las transiciones operativas en base de datos.

Para sintetizar las reglas de transformación y correspondencia estructural, en la @tbl:inventory-persistence-assemblers se describen los ensambladores de persistencia y convertidores JPA del contexto.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Ensambladores de Persistencia y Convertidores JPA de Inventory \& Supply Chain} \label{tbl:inventory-persistence-assemblers} \\
\hline
\thfirst{Aspecto de Mapeo} & \thcell{Tipos Relacionados y Transformación} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Mapeo} & \thcell{Tipos Relacionados y Transformación} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} InventoryItemPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{InventoryItem} $\longleftrightarrow$ \texttt{InventoryItemPersistenceEntity} \\*
\hline
\textbf{Transformación} & Traduce InventoryItemId a UUID. Mapea código SKU, categoría, precio monetario y stock consolidado. Reconstituye el agregado puro mediante el método estático *InventoryItem.reconstitute()* hidratando lotes FIFO ordenados sin disparar eventos de dominio espurios. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} InventoryBatchPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{InventoryBatch} $\longleftrightarrow$ \texttt{InventoryBatchPersistenceEntity} \\*
\hline
\textbf{Transformación} & Mapea InventoryBatchId a UUID, cantidades físicas decimales, costo unitario de adquisición pactado y URL probatoria de factura digital. Invoca *InventoryBatch.reconstitute()* para restaurar remesas físicas de piezas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} SupplierPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{Supplier} $\longleftrightarrow$ \texttt{SupplierPersistenceEntity} \\*
\hline
\textbf{Transformación} & Traduce SupplierId a UUID y TaxId a cadena escalar. Mapea razón social, persona de contacto y condición comercial. Invoca *Supplier.reconstitute()* preservando las invariantes del proveedor. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} PurchaseOrderPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{PurchaseOrder} $\longleftrightarrow$ \texttt{PurchaseOrderPersistenceEntity} \\*
\hline
\textbf{Transformación} & Traduce PurchaseOrderId a UUID, correlativo formal de compra y moneda ISO 4217. Sincroniza líneas dependientes e invoca *PurchaseOrder.reconstitute()* garantizando la inmutabilidad de compras liquidadas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} PurchaseOrderItemPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{PurchaseOrderItem} $\longleftrightarrow$ \texttt{PurchaseOrderItemPersistenceEntity} \\*
\hline
\textbf{Transformación} & Mapea PurchaseOrderItemId a UUID, cantidades pactadas, costo unitario e importe total. Invoca *PurchaseOrderItem.reconstitute()* para recomponer el detalle de la orden. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} SkuAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{Sku} $\longleftrightarrow$ \texttt{VARCHAR(50)} \\*
\hline
\textbf{Transformación} & Serializa y normaliza códigos de parte en mayúsculas a cadenas escalares relacionales. Restaura instancias inmutables de Sku aplicando validación de formato. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} TaxIdAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{TaxId} $\longleftrightarrow$ \texttt{VARCHAR(20)} \\*
\hline
\textbf{Transformación} & Convierte identificadores tributarios RUC de 11 dígitos a cadenas alfanuméricas. Reconstituye el objeto de valor validando longitud y dígito de verificación fiscal. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} QuantityAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{Quantity} $\longleftrightarrow$ \texttt{NUMERIC(10,\allowbreak 2)} \\*
\hline
\textbf{Transformación} & Extrae el saldo de existencias físicas en dos posiciones decimales con redondeo bancario. Reconstituye Quantity asegurando neutralidad ante valores nulos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} MoneyAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{Money} $\longleftrightarrow$ \texttt{NUMERIC(10,\allowbreak 2)} \\*
\hline
\textbf{Transformación} & Extrae el importe monetario como BigDecimal con escala de dos posiciones decimales. Reconstituye Money asignando la divisa reglamentaria del taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} ItemCategoryAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{ItemCategory} $\longleftrightarrow$ \texttt{VARCHAR(50)} \\*
\hline
\textbf{Transformación} & Mapea las categorías taxonómicas LUBRICANTS, BRAKES, SUSPENSION o TIRES a cadenas en mayúsculas. Reconstituye la enumeración de forma insensible a mayúsculas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} InventoryItemStatusAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{InventoryItemStatus} $\longleftrightarrow$ \texttt{VARCHAR(20)} \\*
\hline
\textbf{Transformación} & Mapea estados de catálogo active, inactive y discontinued a columnas relacionales. Reconstituye la enumeración correspondiente de estado operativo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} PurchaseOrderStatusAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{PurchaseOrderStatus} $\longleftrightarrow$ \texttt{VARCHAR(20)} \\*
\hline
\textbf{Transformación} & Mapea transiciones de compra draft, issued, received y canceled a columnas relacionales normalizadas. Reconstituye el estado del pedido formal. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes configurados bajo los paquetes transform y converters de la capa de infraestructura.

**Pasarelas Externas de Infraestructura e Integración Cloud**

La integración con plataformas externas y subsistemas adyacentes se canaliza mediante adaptadores secundarios ubicados en el paquete com.andeva.atelier.platform.inventory.infrastructure.external. Estos componentes implementan los puertos de salida definidos en la Capa de Dominio y Aplicación, aislando el núcleo operativo del almacén de dependencias externas.

El adaptador **FirebaseReceiptImageStorageGatewayImpl** materializa el puerto de almacenamiento emitiendo URLs pre-firmadas HTTP PUT con expiración de quince minutos hacia Google Cloud Storage. Este mecanismo valida tipos de medio autorizados y erradica el tránsito de archivos binarios por la memoria RAM de la API backend. Paralelamente, **SunatTaxIdValidationGatewayImpl** consulta el padrón tributario estatal mediante un cliente seguro con caché en memoria.

Asimismo, **InventoryTransactionalOutboxPublisherImpl** asegura la inserción de eventos en **outbox_messages** y **WorkshopOperationsAclAdapter** canaliza la coordinación con el taller mecánico. Este adaptador procesa reservas lógicas de repuestos en tareas y confirma deducciones FIFO tras el pago de la orden de servicio, garantizando la consistencia intermodular.

A fin de ilustrar la arquitectura de integración y servicios en la nube, en la @tbl:inventory-external-infrastructure se presentan las tecnologías subyacentes y las responsabilidades técnicas de cada pasarela externa.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Pasarelas Externas y Adaptadores de Integración Cloud de Inventory \& Supply Chain} \label{tbl:inventory-external-infrastructure} \\
\hline
\thfirst{Aspecto Técnico} & \thcell{Tecnología y Responsabilidad de Integración} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto Técnico} & \thcell{Tecnología y Responsabilidad de Integración} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Pasarela Externa:} FirebaseReceiptImageStorageGatewayImpl \quad (\textit{Categoría:} Pasarela Multimedia Cloud)} \\*
\hline
\textbf{Tecnología Subyacente} & Google Cloud Storage SDK (HTTP PUT Pre-signed URLs) \\*
\hline
\textbf{Responsabilidad} & Emite URLs pre-firmadas con expiración de quince minutos y validación estricta de tipos de medio (JPEG, PNG, WebP y PDF) para subida directa de comprobantes de compra. Suprime el paso de flujos binarios masivos por la memoria de la API backend. Implementa FirebaseReceiptImageStorageGateway. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Pasarela Externa:} SunatTaxIdValidationGatewayImpl \quad (\textit{Categoría:} Pasarela Perimetral Externa)} \\*
\hline
\textbf{Tecnología Subyacente} & Spring RestClient con TLS y Caché en Memoria Caffeine (TTL de 24 Horas) \\*
\hline
\textbf{Responsabilidad} & Consulta en tiempo real el padrón fiscal de RUC ante los servicios web de la autoridad tributaria SUNAT. Certifica razón social oficial, estado activo y condición de habido previa al alta de proveedores. Mitiga límites de tasa mediante almacenamiento transitorio en memoria. Implementa SunatTaxIdValidationGateway. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Pasarela Externa:} InventoryTransactionalOutboxPublisherImpl \quad (\textit{Categoría:} Adaptador de Mensajería Transaccional)} \\*
\hline
\textbf{Tecnología Subyacente} & PostgreSQL 16 con Serialización JSONB vía Jackson ObjectMapper \\*
\hline
\textbf{Responsabilidad} & Persiste eventos de dominio en la tabla outbox\_messages dentro de la misma transacción local del agregado. Garantiza semántica de publicación confiable con entrega al menos una vez hacia Apache Kafka o RabbitMQ mediante Debezium CDC. Implementa InventoryTransactionalOutboxPublisher y DomainEventPublisher. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Pasarela Externa:} WorkshopOperationsAclAdapter \quad (\textit{Categoría:} Adaptador ACL Taller Mecánico)} \\*
\hline
\textbf{Tecnología Subyacente} & Fachada en Memoria de Módulo e Integración Reactiva por Eventos \\*
\hline
\textbf{Responsabilidad} & Atiende solicitudes de repuestos originadas en intervenciones mecánicas coordinando la asignación física y valoración FIFO. Emite eventos de existencias reservadas o desabastecimiento. Al liquidarse la orden en el taller consolida la imputación contable definitiva del costo de mercadería vendida. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes configurados bajo el paquete canónico com.andeva.atelier.platform.inventory.infrastructure.external.

**Análisis Arquitectónico y Rigor Operacional de la Capa de Infraestructura**

En primer lugar, el índice físico B-Tree cronológico implementado sobre la tabla de lotes garantiza una determinación rigurosa y escalable del Costo de Mercadería Vendida. Al indexar conjuntamente el identificador de la pieza, la fecha de arribo ascendente y la cantidad remanente disponible, el motor relacional localiza de inmediato las unidades más antiguas para imputar su costo unitario exacto a las tareas mecánicas, salvaguardando el margen comercial del taller sin degradar los tiempos de respuesta.

En segundo término, el patrón Transactional Outbox y la hidratación controlada de agregados fortalecen la resiliencia operativa y la consistencia eventual de la plataforma. La inserción atómica de eventos en la misma transacción de almacenamiento elimina riesgos de desincronización ante fallos del bus de mensajería, mientras que la reconstitución aséptica previene la emisión espuria de eventos durante consultas rutinarias de existencias en mostrador.

Por último, la arquitectura Direct-to-Cloud para la captura de comprobantes de pago optimiza el rendimiento del servidor y blinda la trazabilidad fiscal. Al derivar la transferencia de archivos binarios pesados hacia la infraestructura perimetral de Google Cloud Storage mediante credenciales temporales, la API backend preserva sus recursos de cómputo para transacciones críticas, garantizando la custodia inalterable de evidencias documentales ante auditorías comerciales y tributarias.

#### 2.6.5.5. Bounded Context Software Architecture Component Level Diagrams

En esta sección se presenta la descomposición arquitectónica interna del contenedor central **API Application** en relación con el Bounded Context Inventory & Supply Chain. Siguiendo el Nivel 3 del Modelo C4, se detallan los bloques estructurales que constituyen este subsistema logístico, formalizando sus límites de responsabilidad técnica, interfaces de comunicación y mecanismos de integración con clientes web y móviles, subsistemas adyacentes y servicios externos.

Dentro de la arquitectura de monolito modular de Atelier Platform, el Bounded Context Inventory & Supply Chain asume la gobernanza integral del catálogo de autopartes, la custodia física y valuación financiera de materiales bajo la disciplina First-In, First-Out, la gestión del ciclo de abastecimiento mediante órdenes de compra y la certificación tributaria de proveedores comerciales ante la administración fiscal.

En la @tbl:inventory-c4-components se expone el catálogo estructurado de los siete componentes constitutivos del Bounded Context Inventory & Supply Chain dentro del contenedor anfitrión. Cada bloque encapsula una responsabilidad arquitectónica cohesiva, delimitando con precisión la frontera entre los controladores perimetrales REST, los servicios de aplicación CQRS, el motor de valuación de dominio, la persistencia relacional optimizada y las pasarelas externas.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.5cm} | >{\raggedright\arraybackslash}p{10.9cm} |}
\caption{Catálogo de Componentes de Arquitectura de Software del Bounded Context Inventory \& Supply Chain} \label{tbl:inventory-c4-components} \\
\hline
\thfirst{Aspecto Técnico} & \thcell{Especificación de Arquitectura} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto Técnico} & \thcell{Especificación de Arquitectura} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Inventory REST Controllers \& Resource Assemblers} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring MVC, SpringDoc OpenAPI, Jakarta Validation \\*
\hline
\textbf{Responsabilidad} & Expone endpoints REST perimetrales para catálogo de repuestos, ingreso de lotes físicos, órdenes de compra y gestión de proveedores comerciales. Valida contratos sintácticos DTO y proyecta recursos REST enriquecidos con hipermedios. \\*
\hline
\textbf{Relaciones} & Invocado por WebApp y Mobile Workshop vía HTTPS. Despacha comandos de mutación y consultas de lectura a servicios CQRS. Utiliza ensambladores de recursos REST. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Inventory CQRS Application Services} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring Service, Transactional, CQRS, Interfaces Funcionales \\*
\hline
\textbf{Responsabilidad} & Orquesta los casos de uso de catalogación de autopartes, asignación FIFO de lotes, gestión del ciclo de vida de órdenes de compra y registro de proveedores bajo transacciones ACID, canalizando resultados deterministas mediante estructuras Result. \\*
\hline
\textbf{Relaciones} & Implementa contratos de comando y consulta. Invoca reglas de negocio en el núcleo de dominio. Delega en adaptadores de persistencia JPA y pasarelas de nube. Emite eventos de dominio hacia oyentes transaccionales. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Inventory Event Handlers \& Transactional Dispatcher} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring Events, TransactionalEventListener, Outbox Pattern \\*
\hline
\textbf{Responsabilidad} & Captura eventos de dominio locales y solicitudes de reserva desde Workshop Operations, canalizando eventos atómicos hacia la tabla outbox\_messages para publicación asíncrona confiable hacia módulos adyacentes. \\*
\hline
\textbf{Relaciones} & Escucha eventos de dominio de servicios de aplicación. Persiste mensajes transaccionales en base de datos PostgreSQL 16 mediante puertos de repositorio. Notifica a consumidores en MRO, Invoicing y CRM. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Inventory Domain Model \& FIFO Valuation Engine} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Java 26 puro, Domain Model, Records, Inmutabilidad \\*
\hline
\textbf{Responsabilidad} & Encapsula invariantes de negocio, el motor algorítmico de costeo y asignación FIFO por lotes físicos cronológicos, la determinación matemática de umbrales críticos de stock y las raíces de agregado inmutables. \\*
\hline
\textbf{Relaciones} & Contiene raíces InventoryItem, Supplier, PurchaseOrder y entidades dependientes InventoryBatch, PurchaseOrderItem. Ejecuta algoritmos de costeo en FifoAllocationEngine e InventoryValuationService. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Inventory Persistence Repositories \& JPA Adapters} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Jakarta Persistence 3.1, Spring Data JPA, Hibernate ORM, PostgreSQL 16 \\*
\hline
\textbf{Responsabilidad} & Materializa los puertos de repositorio de dominio con Spring Data JPA e Hibernate, implementando índices B-Tree especializados para deducción FIFO cronológica, bloqueos de concurrencia optimista y despacho atómico Outbox. \\*
\hline
\textbf{Relaciones} & Realiza interfaces InventoryItemRepository, SupplierRepository, PurchaseOrderRepository. Lee y escribe en las tablas inventory\_items, inventory\_batches, suppliers, purchase\_orders, purchase\_order\_items y outbox\_messages. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Inbound ACL \& Inventory Open Host Facade} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring Service, In-Memory ACL, Published Language \\*
\hline
\textbf{Responsabilidad} & Publica una fachada Open Host Service en memoria que atiende demandas de reserva preventiva y consumo definitivo de repuestos desde Workshop Operations con cómputo exacto de COGS, y consultas de valuación para Invoicing sin acoplamiento interno. \\*
\hline
\textbf{Relaciones} & Invocado por Workshop Operations para reservas y consumo con costeo FIFO, y por Invoicing \& Compliance para valorización de liquidaciones. Delega lecturas optimizadas en adaptadores de persistencia JPA. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Inventory External Gateways \& Cloud Integration} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Google Cloud Storage SDK, Spring RestClient, In-Memory ACL \\*
\hline
\textbf{Responsabilidad} & Genera URLs pre-firmadas HTTP PUT con expiración de 15 minutos para comprobantes de compra en Google Cloud Storage bajo arquitectura Direct-to-Cloud, consulta el padrón RUC en tiempo real ante SUNAT mediante HTTPS/REST y coordina validaciones de tenencia con IAM. \\*
\hline
\textbf{Relaciones} & Invocado por servicios de aplicación. Conecta vía HTTPS con Google Cloud Storage y con los servicios web de SUNAT. Consulta en memoria la fachada de IAM \& Tenancy para verificar el estado del taller. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al contenedor API Application en com.andeva.atelier.platform.inventory.

En la @fig:c4-component-inventory se ilustra el diagrama C4 de componentes para el Bounded Context Inventory & Supply Chain, detallando las interacciones entre los controladores REST, los servicios de aplicación CQRS, los manejadores de eventos de integración, el motor de valuación FIFO de dominio, los adaptadores de persistencia relacional, la fachada de contexto abierto y las pasarelas externas.

![Diagrama de Componentes C4 (Nivel 3) para el Bounded Context Inventory & Supply Chain en API Application](report/assets/c4-diagrams/component-level-diagram-inventory.png){#fig:c4-component-inventory}

*Nota.* Elaboración propia en base a la arquitectura táctica del backend y el estándar C4 Model.

**Dinámica de Interacción y Flujos Operativos del Bounded Context Inventory & Supply Chain**

Para comprender la colaboración entre los componentes de Inventory & Supply Chain y los módulos adyacentes durante la operación del sistema, se analizan a continuación los tres flujos operacionales críticos de la plataforma:

- **Ciclo de Ingreso y Valuación de Lotes FIFO con Evidencia Direct-to-Cloud:**
  Cuando arriba un nuevo embarque de autopartes al almacén, el encargado inicia el registro desde la aplicación web o tableta móvil. El componente **Inventory REST Controllers & Resource Assemblers** recibe la solicitud y delega en **Inventory CQRS Application Services**, el cual solicita a **Inventory External Gateways & Cloud Integration** la generación de una URL pre-firmada con expiración de 15 minutos. El cliente transfiere directamente el comprobante tributario escaneado a Google Cloud Storage, prescindiendo del consumo de memoria del servidor backend.

  Posteriormente, el cliente emite la solicitud de ingreso de lote con el enlace de la imagen almacenada. El servicio de aplicación invoca el agregado en **Inventory Domain Model & FIFO Valuation Engine**, el cual valida el costo unitario de adquisición, la cantidad inicial y la fecha de recepción, creando una entidad de lote inmutable. Finalmente, el adaptador **Inventory Persistence Repositories & JPA Adapters** persiste el lote en PostgreSQL 16, actualiza el saldo global de existencias y registra el evento de lote ingresado en la tabla transaccional **outbox_messages**.

- **Ciclo de Reserva Preventiva y Consumo FIFO Orquestado desde Taller:**
  Durante la ejecución de una labor técnica en foso, el módulo de Workshop Operations solicita la reserva de piezas requeridas mediante la fachada **Inbound ACL & Inventory Open Host Facade**. Esta fachada canaliza el requerimiento hacia **Inventory CQRS Application Services**, el cual recupera las existencias activas a través de los adaptadores JPA ordenadas cronológicamente por fecha de ingreso ascendente.

  El motor **Inventory Domain Model & FIFO Valuation Engine** evalúa los lotes físicos disponibles, consumiendo prioritariamente los más antiguos para calcular de forma determinista el Costo de Mercadería Vendida. El servicio de aplicación aplica la deducción en los lotes correspondientes y verifica si el stock remanente se sitúa por debajo del umbral mínimo de seguridad. Ante saldos críticos, el manejador **Inventory Event Handlers & Transactional Dispatcher** persiste una alerta de reabastecimiento en **outbox_messages** para notificar al área de compras.

- **Ciclo de Aprovisionamiento, Certificación Tributaria de Proveedores y Conformidad de Compra:**
  Al incorporar un nuevo proveedor comercial al catálogo maestro, **Inventory REST Controllers & Resource Assemblers** intercepta el registro y delega en el servicio de aplicación. La pasarela **Inventory External Gateways & Cloud Integration** consulta en tiempo real el servicio web de la SUNAT mediante HTTPS y almacenamiento en caché, certificando que el número de RUC corresponda a una entidad activa y con condición de habido.

  Confirmada la habilitación fiscal, se emite una orden de compra consolidando los requerimientos de reposición. Al arribar la mercadería al taller, el jefe de almacén registra la recepción física en el sistema. El servicio de aplicación verifica las cantidades recibidas frente a las ordenadas, concilia los costos unitarios pactados y actualiza el estado de la orden a recibida, insertando de manera atómica el evento de conformidad en **outbox_messages** para su posterior liquidación financiera.

#### 2.6.5.6. Bounded Context Software Architecture Code Level Diagrams

En esta sección se aborda el nivel de mayor granularidad y rigor técnico dentro de la arquitectura de software del Bounded Context Inventory & Supply Chain, traduciendo los límites tácticos y responsabilidades funcionales hacia especificaciones estáticas que orientan la codificación de la plataforma. Mediante este enfoque, se garantiza que la gestión de piezas, la valuación de existencias y el ciclo de abastecimiento con proveedores se ejecuten bajo tipado estricto y consistencia determinista.

Esta dimensión arquitectónica se estructura en dos perspectivas complementarias: el Diagrama de Clases de la Capa de Dominio, que modela en memoria las raíces de agregado, entidades dependientes, objetos de valor inmutables, motores algorítmicos y puertos de repositorio; y el Diagrama de Base de Datos, que define la persistencia física en PostgreSQL 16 con aislamiento multi-inquilino mediante discriminador de taller, restricciones de integridad referencial e índices B-Tree optimizados para alta concurrencia.

##### 2.6.5.6.1. *Bounded Context Domain Layer Class Diagrams*

El modelado estático de la Capa de Dominio del Bounded Context Inventory & Supply Chain establece las estructuras de datos y contratos en memoria que gobiernan la custodia de inventarios, la valorización de costos de mercadería y el reaprovisionamiento comercial. Su diseño prioriza el encapsulamiento riguroso de reglas de negocio, erradica la obsesión por tipos primitivos mediante identificadores fuertemente tipados y preserva la pureza conceptual al excluir anotaciones de frameworks externos o librerías de persistencia relacional.

En la @fig:class-diagram-inventory se expone el Diagrama de Clases UML detallado para la Capa de Dominio del Bounded Context Inventory & Supply Chain, modelado conforme al estándar UML y compilado mediante la herramienta PlantUML bajo el enfoque de Diagram-as-Code.

![Diagrama de Clases UML de la Capa de Dominio del Bounded Context Inventory & Supply Chain](report/assets/class-diagrams/class-diagram-inventory.png){#fig:class-diagram-inventory}

*Nota.* Elaboración propia en base a la especificación de dominio y el estándar PlantUML UML.

La organización interna del diagrama se estructura en ocho paquetes lógicos que agrupan las responsabilidades tácticas del subsistema de inventario y compras:

- **Raíces de Agregado (`inventory.domain.model.aggregates`):** Modela las entidades principales que delimitan las fronteras transaccionales: **InventoryItem** para el catálogo maestro de piezas, control de existencias consolidadas y asignación de stock; **Supplier** para la ficha comercial de proveedores y certificación tributaria; y **PurchaseOrder** para la formalización y recepción de órdenes de reabastecimiento. Todas las raíces heredan de **AbstractDomainAggregateRoot<T>**.
- **Entidades Internas (`inventory.domain.model.entities`):** Define las entidades dependientes subordinadas al ciclo de vida de su raíz: **InventoryBatch** para modelar lotes físicos de adquisición con saldos remanentes y costos unitarios históricos; y **PurchaseOrderItem** para cuantificar las líneas de piezas solicitadas en cada orden de compra.
- **Identificadores Fuertemente Tipados (`inventory.domain.model.ids`):** Implementa la interfaz **TypedId<UUID>** mediante registros inmutables (**InventoryItemId**, **InventoryBatchId**, **SupplierId**, **PurchaseOrderId**, **PurchaseOrderItemId**), reutilizando **TenantId** y **BranchId** de los módulos de soporte e IAM.
- **Objetos de Valor de Suministro y Valorización (`inventory.domain.model.valueobjects`):** Encapsula conceptos inmutables como el código alfanumérico estandarizado (**Sku**), la magnitud física de existencias (**Quantity**), la asignación formal de stock (**StockAllocation**), la deducción física de lote (**BatchDeduction**), el código correlativo de compra (**PurchaseOrderNumber**) y el localizador seguro de comprobantes (**StorageUrl**), complementados por **Money** y **TaxId** provistos por el Shared Kernel.
- **Enumeraciones de Dominio (`inventory.domain.model.enums`):** Define los estados operativos y modalidades de inventario (**InventoryItemStatus**, **ItemCategory**, **PurchaseOrderStatus**).
- **Servicios de Dominio Puro (`inventory.domain.services`):** Incorpora lógica de negocio sin estado que opera sobre múltiples entidades: **FifoAllocationEngine** para la deducción cronológica de existencias y cómputo determinista de costo de mercadería vendida; **InventoryValuationService** para la valorización patrimonial consolidada de almacén; y **StockReorderEvaluationService** para la proyección de compras según demanda media y tiempos de abastecimiento.
- **Puertos de Persistencia (`inventory.domain.repositories`):** Establece los contratos de persistencia pura (**InventoryItemRepository**, **InventoryBatchRepository**, **SupplierRepository**, **PurchaseOrderRepository**) desacoplados de cualquier infraestructura relacional u ORM.
- **Jerarquía de Excepciones Semánticas (`inventory.domain.exceptions`):** Provee clases no comprobadas que heredan de **DomainException**, asignando códigos de error legibles y unificados para quiebres de existencias, transiciones inválidas, duplicidad fiscal o entidades no localizadas.

En la @tbl:inventory-domain-classes-members se detalla la especificación formal de atributos, firmas de métodos, modificadores de acceso y reglas de negocio para cada elemento de la Capa de Dominio.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo exhaustivo de clases, miembros, ámbitos y relaciones de la Capa de Dominio del Bounded Context Inventory \& Supply Chain} \label{tbl:inventory-domain-classes-members} \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} InventoryItem} \\*
\hline
Atributos & Raíz de agregado principal. Modela el catálogo de piezas, control consolidado de existencias, punto de reorden y asignación de lotes. Generalización de \texttt{AbstractDomainAggregateRoot<\allowbreak InventoryItemId>\allowbreak }. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{InventoryItemId id} \newline - \texttt{TenantId tenantId} \newline - \texttt{String name} \newline - \texttt{Sku sku} \newline - \texttt{ItemCategory category} \newline - \texttt{Money basePrice} \newline - \texttt{Quantity totalStock} \newline - \texttt{Quantity minimumStock} \newline - \texttt{InventoryItemStatus status} \newline - \texttt{List<\allowbreak InventoryBatch>\allowbreak  batches} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos factoría y ciclo & Invariantes: estado inicial ACTIVE. Existencias y umbrales mínimos mayores o iguales a cero. Modificación controlada de catálogo y alternancia de vigencia comercial. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{InventoryItem create(...)} \newline - \texttt{void updateDetails(...)} \newline - \texttt{void deactivate()} \newline - \texttt{void activate()} \newline - \texttt{InventoryItemId id()} \newline - \texttt{Sku sku()} \newline - \texttt{Quantity totalStock()} \newline - \texttt{Money basePrice()} \newline - \texttt{InventoryItemStatus status()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Lotes y asignación FIFO & Composición 1 a 0..* con \textbf{InventoryBatch}. Incorporación de remesas físicas de compra, reserva First-In First-Out de repuestos para órdenes de trabajo y restitución de existencias ante cancelaciones. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{InventoryBatch addBatch(...)} \newline - \texttt{StockAllocation allocateStockFifo(Quantity)} \newline - \texttt{void releaseStockAllocation(StockAllocation)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Supplier} \\*
\hline
Atributos & Raíz de agregado del catálogo de proveedores comerciales. Modela la entidad jurídica de aprovisionamiento y su certificación tributaria. Generalización de \texttt{AbstractDomainAggregateRoot<\allowbreak SupplierId>\allowbreak }. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{SupplierId id} \newline - \texttt{TenantId tenantId} \newline - \texttt{String businessName} \newline - \texttt{TaxId taxId} \newline - \texttt{String contactName} \newline - \texttt{String phone} \newline - \texttt{String email} \newline - \texttt{String address} \newline - \texttt{boolean isActive} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos operativos & Invariantes: razón social no vacía. Validación de formato de RUC mediante algoritmo de módulo 11 en TaxId. Actualización de canales de contacto y habilitación operativa. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Supplier register(...)} \newline - \texttt{void updateContactInfo(...)} \newline - \texttt{void deactivate()} \newline - \texttt{void activate()} \newline - \texttt{SupplierId id()} \newline - \texttt{String businessName()} \newline - \texttt{TaxId taxId()} \newline - \texttt{boolean isActive()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} PurchaseOrder} \\*
\hline
Atributos & Raíz de agregado de abastecimiento comercial formal. Modela la orden de compra emitida a proveedores y custodia la máquina de estados de adquisición. Generalización de \texttt{AbstractDomainAggregateRoot<\allowbreak PurchaseOrderId>\allowbreak }. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{PurchaseOrderId id} \newline - \texttt{TenantId tenantId} \newline - \texttt{SupplierId supplierId} \newline - \texttt{BranchId branchId} \newline - \texttt{PurchaseOrderNumber orderNumber} \newline - \texttt{PurchaseOrderStatus status} \newline - \texttt{Money totalCost} \newline - \texttt{StorageUrl receiptImageUrl} \newline - \texttt{String receiptNumber} \newline - \texttt{Instant receivedAt} \newline - \texttt{List<\allowbreak PurchaseOrderItem>\allowbreak  items} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos factoría y ciclo & Invariantes: estado inicial DRAFT. Emisión formal con verificación de líneas de pedido no vacías. Recepción física con digitalización obligatoria de comprobante fiscal o cancelación justificada. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{PurchaseOrder create(...)} \newline - \texttt{void issue()} \newline - \texttt{void receive(StorageUrl,\allowbreak  String,\allowbreak  Instant)} \newline - \texttt{void cancel(String)} \newline - \texttt{PurchaseOrderId id()} \newline - \texttt{PurchaseOrderStatus status()} \newline - \texttt{Money totalCost()} \newline - \texttt{SupplierId supplierId()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Líneas de pedido & Composición 1 a 1..* con \textbf{PurchaseOrderItem}. Adición y remoción de repuestos cotizados con actualización automática del costo total consolidado de la orden. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{void addItem(InventoryItemId,\allowbreak  Quantity,\allowbreak  Money)} \newline - \texttt{void removeItem(PurchaseOrderItemId)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} InventoryBatch} \\*
\hline
Atributos y deducción FIFO & Entidad dependiente de lote físico de adquisición. Encapsula remanente disponible, costo unitario histórico de compra, fecha de ingreso en almacén y referencia al comprobante digitalizado. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{InventoryBatchId id} \newline - \texttt{TenantId tenantId} \newline - \texttt{InventoryItemId itemId} \newline - \texttt{SupplierId supplierId} \newline - \texttt{String batchNumber} \newline - \texttt{Quantity initialQuantity} \newline - \texttt{Quantity remainingQuantity} \newline - \texttt{Money unitCost} \newline - \texttt{Instant arrivalDate} \newline - \texttt{StorageUrl receiptImageUrl} \newline - \texttt{boolean hasStock()} \newline - \texttt{Quantity deduct(Quantity)} \newline - \texttt{void restore(Quantity)} \newline - \texttt{InventoryBatchId id()} \newline - \texttt{Quantity remainingQuantity()} \newline - \texttt{Money unitCost()} \newline - \texttt{Instant arrivalDate()} \\*
\hline
\textbf{Ámbito} & Privado / Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} PurchaseOrderItem} \\*
\hline
Atributos y métodos & Entidad dependiente de línea de pedido en orden de compra. Vincula el repuesto solicitado con la cantidad pactada y calcula el costo total multiplicado por el costo unitario. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{PurchaseOrderItemId id} \newline - \texttt{PurchaseOrderId orderId} \newline - \texttt{InventoryItemId itemId} \newline - \texttt{Quantity quantity} \newline - \texttt{Money unitCost} \newline - \texttt{Money totalCost} \newline - \texttt{void updateQuantity(Quantity)} \newline - \texttt{PurchaseOrderItemId id()} \newline - \texttt{InventoryItemId itemId()} \newline - \texttt{Quantity quantity()} \newline - \texttt{Money unitCost()} \newline - \texttt{Money totalCost()} \\*
\hline
\textbf{Ámbito} & Privado / Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} FifoAllocationEngine, InventoryValuationService, StockReorderEvaluationService} \\*
\hline
Servicios de dominio & Lógica algorítmica pura sin estado. \textbf{FifoAllocationEngine} ejecuta la deducción cronológica de existencias y calcula el Costo de Mercadería Vendida. \textbf{InventoryValuationService} totaliza el valor contable consolidado de existencias con redondeo bancario Half-Even. \textbf{StockReorderEvaluationService} evalúa umbrales de reabastecimiento según demanda diaria y tiempo de entrega de proveedores. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{StockAllocation allocate(InventoryItem,\allowbreak  Quantity)} \newline - \texttt{Money calculateCogs(List<\allowbreak BatchDeduction>\allowbreak )} \newline - \texttt{Money calculateTotalValuation(TenantId,\allowbreak  List<\allowbreak InventoryItem>\allowbreak )} \newline - \texttt{Money calculateItemValuation(InventoryItem)} \newline - \texttt{boolean evaluateReorder(InventoryItem,\allowbreak  int,\allowbreak  int)} \newline - \texttt{Quantity calculateReorderQuantity(InventoryItem,\allowbreak  int,\allowbreak  int)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} InventoryItemRepository, InventoryBatchRepository, SupplierRepository, PurchaseOrderRepository} \\*
\hline
Puertos de persistencia & Interfaces agnósticas de persistencia en dominio. Proveen métodos de consulta y almacenamiento desacoplados de tecnologías ORM o relacionales, incluyendo detección de existencias críticas y correlativos de compra. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{InventoryItem save(InventoryItem)} \newline - \texttt{Optional<\allowbreak InventoryItem>\allowbreak  findById(InventoryItemId)} \newline - \texttt{List<\allowbreak InventoryItem>\allowbreak  findLowStockItems(TenantId)} \newline - \texttt{List<\allowbreak InventoryBatch>\allowbreak  findActiveBatchesByItemId(InventoryItemId)} \newline - \texttt{Optional<\allowbreak Supplier>\allowbreak  findByTenantIdAndTaxId(TenantId,\allowbreak  TaxId)} \newline - \texttt{PurchaseOrderNumber findNextOrderNumber(TenantId)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} InventoryItemId, InventoryBatchId, SupplierId, PurchaseOrderId, PurchaseOrderItemId} \\*
\hline
Atributo value y factoría & Registros inmutables que realizan la interfaz sellada \texttt{TypedId<\allowbreak UUID>\allowbreak }, erradicando la obsesión por tipos primitivos en identidades de suministros y compras. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{UUID value} \newline - \texttt{of(UUID)} \newline - \texttt{UUID value()} \\*
\hline
\textbf{Ámbito} & Privado / Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Sku, Quantity, StockAllocation, BatchDeduction, PurchaseOrderNumber, StorageUrl} \\*
\hline
Atributos y validaciones & Objetos de valor inmutables. \textbf{Sku} valida formato alfanumérico en mayúsculas de 3 a 50 caracteres. \textbf{Quantity} garantiza valores decimales no negativos con escala fija a dos decimales. \textbf{StockAllocation} y \textbf{BatchDeduction} custodian los desgloses y subtotales FIFO. \textbf{PurchaseOrderNumber} valida código correlativo PO. \textbf{StorageUrl} asegura enlaces HTTPS a comprobantes digitalizados. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{String value} \newline - \texttt{BigDecimal value} \newline - \texttt{UUID allocationId} \newline - \texttt{UUID batchId} \newline - \texttt{boolean isValid()} \newline - \texttt{Quantity add(Quantity)} \newline - \texttt{Quantity subtract(Quantity)} \\*
\hline
\textbf{Ámbito} & Privado / Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Enumeraciones de Dominio de Inventory \& Supply Chain} \\*
\hline
Valores constantes & Tipos enumerados que gobiernan la vigencia comercial del catálogo (\textbf{InventoryItemStatus}: ACTIVE, INACTIVE, DISCONTINUED), las familias de repuestos (\textbf{ItemCategory}: LUBRICANTS, BRAKES, SUSPENSION, ENGINE, ELECTRICAL, TIRES, FILTERS, BODYWORK, ACCESSORIES) y el ciclo de vida de compras (\textbf{PurchaseOrderStatus}: DRAFT, ISSUED, RECEIVED, CANCELED). \\*
\hline
\textbf{Firma o Tipo} & \texttt{Enumeraciones de dominio} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Jerarquía de Excepciones de Dominio} \\*
\hline
Constructores tipados & Diez excepciones no comprobadas derivadas de \texttt{DomainException} que encapsulan códigos semánticos legibles para respuestas RFC 7807 ante quiebres de existencias, duplicidades de RUC o SKU, órdenes vacías y comprobantes faltantes. \\*
\hline
\textbf{Firma o Tipo} & Subclases de \texttt{DomainException} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Elaboración propia en base al diseño táctico de dominio y la especificación UML de la solución.

A partir del modelo estático ilustrado en la @fig:class-diagram-inventory y formalizado en la @tbl:inventory-domain-classes-members, se identifican tres fundamentos de ingeniería de software que consolidan la robustez y pureza del subsistema de inventario:

- **Determinismo Algorítmico FIFO y Preservación del Margen Comercial:**
  La valuación cronológica estricta First-In, First-Out materializada por el motor **FifoAllocationEngine** sobre las entidades **InventoryBatch** resuelve el problema crítico de descalce financiero en entornos inflacionarios o con fluctuaciones de precios en repuestos importados. Al vincular el costo real de adquisición de cada lote físico con el servicio de MRO donde se consume la pieza, el sistema calcula de manera exacta el Costo de Mercadería Vendida, impidiendo que el taller erosione su margen operativo por liquidar componentes a costos históricos desactualizados o promedios ponderados distorsionados.

- **Erradicación de Primitive Obsession y Desacoplamiento Multimedia Direct-to-Cloud:**
  La formalización del modelo de dominio sustituye cadenas y números genéricos por tipos especializados como **Sku**, **Quantity**, **TaxId** y **PurchaseOrderNumber**, garantizando que cualquier violación de invariantes se detecte en el momento de instanciación en memoria. Complementariamente, el objeto de valor **StorageUrl** desacopla la recepción física de compras de la carga de binarios pesados en la API Spring Boot, permitiendo a los operarios capturar facturas y guías de remisión directamente hacia Google Cloud Storage mediante URLs firmadas sin degradar la memoria de la aplicación.

- **Consistencia Eventual Transaccional y Coordinación con MRO e Invoicing:**
  La emisión de eventos de dominio ante recepciones de mercadería y deducciones de existencias se acopla con el patrón Transactional Outbox para coordinar de forma asíncrona la actualización de órdenes de trabajo y la posterior liquidación tributaria. Este desacoplamiento garantiza que las operaciones intensivas de taller continúen operando de manera resiliente, manteniendo la integridad referencial entre el catálogo de suministros y los comprobantes electrónicos emitidos ante la SUNAT sin recurrir a bloqueos distribuidos de dos fases.

##### 2.6.5.6.2. *Bounded Context Database Design Diagram*

La arquitectura de persistencia del Bounded Context Inventory & Supply Chain gobierna el catálogo maestro de repuestos y lubricantes, la valuación de existencias bajo el método FIFO por lotes físicos, el directorio homologado de proveedores y la emisión de órdenes de compra con control documental. El diseño físico articula el repositorio central en la nube con el almacenamiento desconectado de los terminales móviles de taller, asegurando consistencia transaccional absoluta y resiliencia en la faena diaria de los operarios.

En la @fig:database-diagram-inventory se presenta el Diagrama Entidad-Relación físico para la persistencia del Bounded Context Inventory & Supply Chain en sus dos entornos operativos de despliegue: la base de datos central PostgreSQL 16 de la API de backend y el motor relacional local SQLite 3 de la aplicación móvil de taller.

![Diagrama Entidad-Relación de Base de Datos para el Bounded Context Inventory & Supply Chain (PostgreSQL 16 y SQLite 3)](report/assets/database-diagrams/database-diagram-inventory.png){#fig:database-diagram-inventory}

*Nota.* Elaboración propia en base al diseño físico de persistencia y el estándar PlantUML ERD.

El diseño relacional presentado en la @fig:database-diagram-inventory se estructura en dos subsistemas articulados para satisfacer los requerimientos operativos y contables de la plataforma:
- **Gestión Transaccional Central y Núcleo Contable FIFO en PostgreSQL 16:**
  Consolida las tablas maestras **inventory_items**, **suppliers**, **purchase_orders**, **inventory_batches** y **purchase_order_items**, las cuales extienden la superclase JPA **auditable_abstract_entity**. Este subsistema garantiza aislamiento multi-inquilino mediante la clave foránea indexada **tenant_id**, control de concurrencia optimista a través del atributo **version** y resolución sub-milisegundo de la prelación cronológica FIFO mediante un índice B-Tree parcial condicionado a lotes con existencias remanentes positivas.
- **Persistencia Desconectada y Buffer de Reservas en SQLite 3:**
  Garantiza la continuidad operativa en los terminales móviles de taller mediante las tablas locales **local_inventory_cache**, **local_batches_cache**, **local_suppliers_cache** y **offline_inventory_reservations**. Esta arquitectura retiene réplicas ligeras de consulta inmediata en foso y encola de manera transaccional los apartados de repuestos efectuados por mecánicos en zonas de blindaje electromagnético, sincronizando las reservas hacia el backend central mediante llamadas REST idempotentes al restablecer la conectividad.

A partir de la arquitectura relacional definida en el diagrama de persistencia, en la @tbl:inventory-database-objects se cataloga la totalidad de las tablas y objetos físicos que conforman el modelo de datos, detallando el producto donde residen, sus atributos cardinales, restricciones de integridad, estrategias de indexación y su contribución al aislamiento de información.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.1cm} | >{\raggedright\arraybackslash}p{10.3cm} |}
\caption{Catálogo exhaustivo de tablas, objetos de base de datos, restricciones e índices físicos del Bounded Context Inventory \& Supply Chain} \label{tbl:inventory-database-objects} \\
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{inventory\_items}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Catálogo maestro de repuestos, lubricantes y consumibles del taller automotriz. Custodia existencias consolidadas, precios de venta y umbrales de reorden con aislamiento estricto por tenant\_id. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{tenant\_id (UUID)}, \texttt{name (VARCHAR)}, \texttt{sku (VARCHAR)}, \texttt{category (VARCHAR)}, \texttt{base\_price (DECIMAL)}, \texttt{total\_stock (DECIMAL)}, \texttt{minimum\_stock (DECIMAL)}, \texttt{status (VARCHAR)}, auditoría transversal y control de versiones JPA. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_inventory\_items (id) \newline - FK: fk\_inventory\_items\_tenant\_id hacia tenants \newline - UK: uk\_inventory\_items\_tenant\_sku (tenant\_id, sku) \newline - CHECK: chk\_inventory\_items\_status, chk\_inventory\_items\_stock, chk\_inventory\_items\_min\_stock, chk\_inventory\_items\_price \newline - Índices B-Tree: idx\_inventory\_items\_tenant\_sku, idx\_inventory\_items\_category, idx\_inventory\_items\_low\_stock parcial \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{inventory\_batches}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Núcleo contable de valuación patrimonial y costeo FIFO. Custodia lotes físicos de adquisición con su costo unitario inalterable y saldo remanente para deducción cronológica en reparaciones. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{tenant\_id (UUID)}, \texttt{item\_id (UUID)}, \texttt{supplier\_id (UUID)}, \texttt{purchase\_order\_id (UUID)}, \texttt{batch\_number (VARCHAR)}, \texttt{receipt\_image\_url (VARCHAR)}, \texttt{initial\_qty (DECIMAL)}, \texttt{remaining\_qty (DECIMAL)}, \texttt{unit\_cost (DECIMAL)}, \texttt{arrival\_date (TIMESTAMPTZ)}, auditoría transversal. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_inventory\_batches (id) \newline - FK: fk\_inventory\_batches\_tenant\_id hacia tenants, fk\_inventory\_batches\_item\_id hacia inventory\_items, fk\_inventory\_batches\_supplier\_id hacia suppliers, fk\_inventory\_batches\_po\_id hacia purchase\_orders \newline - CHECK: chk\_batches\_remaining\_qty, chk\_batches\_initial\_qty, chk\_batches\_unit\_cost, chk\_batches\_remaining\_le\_initial \newline - Índices B-Tree: idx\_inventory\_batches\_item\_fifo parcial WHERE remaining\_qty > 0.00, idx\_inventory\_batches\_tenant, idx\_inventory\_batches\_po, idx\_inventory\_batches\_supplier \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{suppliers}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Directorio homologado de distribuidores y proveedores comerciales del taller. Custodia RUC tributario validado ante SUNAT, datos de contacto y estado operativo con aislamiento multi-inquilino. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{tenant\_id (UUID)}, \texttt{business\_name (VARCHAR)}, \texttt{tax\_id (VARCHAR)}, \texttt{contact\_name (VARCHAR)}, \texttt{phone (VARCHAR)}, \texttt{email (VARCHAR)}, \texttt{address (VARCHAR)}, \texttt{is\_active (BOOLEAN)}, auditoría transversal y control de versiones JPA. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_suppliers (id) \newline - FK: fk\_suppliers\_tenant\_id hacia tenants \newline - UK: uk\_suppliers\_tenant\_tax\_id (tenant\_id, tax\_id) \newline - Índices B-Tree: idx\_suppliers\_tenant\_tax\_id, idx\_suppliers\_tenant\_business\_name \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{purchase\_orders}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Orquestación del ciclo formal de abastecimiento de repuestos. Centraliza el pedido comercial, la recepción física en sucursal y la evidencia probatoria digitalizada del comprobante de pago. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{tenant\_id (UUID)}, \texttt{supplier\_id (UUID)}, \texttt{branch\_id (UUID)}, \texttt{order\_number (VARCHAR)}, \texttt{status (VARCHAR)}, \texttt{total\_cost (DECIMAL)}, \texttt{receipt\_image\_url (VARCHAR)}, \texttt{receipt\_number (VARCHAR)}, \texttt{received\_at (TIMESTAMPTZ)}, auditoría transversal y control de versiones. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_purchase\_orders (id) \newline - FK: fk\_purchase\_orders\_tenant\_id hacia tenants, fk\_purchase\_orders\_supplier\_id hacia suppliers, fk\_purchase\_orders\_branch\_id hacia branches \newline - UK: uk\_purchase\_orders\_tenant\_number (tenant\_id, order\_number) \newline - CHECK: chk\_purchase\_order\_status, chk\_purchase\_order\_total \newline - Índices B-Tree: idx\_purchase\_orders\_tenant\_status, idx\_purchase\_orders\_supplier, idx\_purchase\_orders\_branch \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{purchase\_order\_items}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Líneas de detalle de la adquisición comercial. Vincula cada repuesto demandado con la cantidad acordada y el costo unitario cotizado, originando los lotes de inventario al confirmarse la recepción. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{purchase\_order\_id (UUID)}, \texttt{item\_id (UUID)}, \texttt{quantity (DECIMAL)}, \texttt{unit\_cost (DECIMAL)}, \texttt{total\_cost (DECIMAL)}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ).} \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_purchase\_order\_items (id) \newline - FK: fk\_po\_items\_order\_id hacia purchase\_orders, fk\_po\_items\_item\_id hacia inventory\_items \newline - CHECK: chk\_po\_items\_quantity, chk\_po\_items\_unit\_cost, chk\_po\_items\_total\_cost \newline - Índices B-Tree: idx\_po\_items\_order, idx\_po\_items\_item \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{local\_inventory\_cache}} \\*
\hline
\textbf{Motor y Producto} & SQLite 3 (Mobile Workshop) \\*
\hline
\textbf{Propósito y Aislamiento} & Caché relacional local de repuestos e insumos en el terminal móvil. Permite al mecánico verificar existencias consolidadas y precios de catálogo en fosos o áreas sin cobertura de red. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{item\_id (TEXT)}, \texttt{tenant\_id (TEXT)}, \texttt{name (TEXT)}, \texttt{sku (TEXT)}, \texttt{category (TEXT)}, \texttt{base\_price (REAL)}, \texttt{total\_stock (REAL)}, \texttt{minimum\_stock (REAL)}, \texttt{status (TEXT)}, \texttt{synced\_at (TEXT).} \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_local\_inventory (item\_id) \newline - Índice B-Tree: idx\_local\_inventory\_tenant\_sku (tenant\_id, sku) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{local\_batches\_cache}} \\*
\hline
\textbf{Motor y Producto} & SQLite 3 (Mobile Workshop) \\*
\hline
\textbf{Propósito y Aislamiento} & Réplica local de lotes físicos disponibles con saldo remanente. Brinda visibilidad operativa en foso de los números de lote y fechas de ingreso para comprobaciones mecánicas directas. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{batch\_id (TEXT)}, \texttt{item\_id (TEXT)}, \texttt{batch\_number (TEXT)}, \texttt{remaining\_qty (REAL)}, \texttt{unit\_cost (REAL)}, \texttt{arrival\_date (TEXT)}, \texttt{synced\_at (TEXT).} \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_local\_batches (batch\_id) \newline - Índice B-Tree: idx\_local\_batches\_item\_fifo (item\_id, arrival\_date) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{local\_suppliers\_cache}} \\*
\hline
\textbf{Motor y Producto} & SQLite 3 (Mobile Workshop) \\*
\hline
\textbf{Propósito y Aislamiento} & Directorio local de proveedores comerciales homologados. Facilita la consulta de razones sociales y números de contacto de emergencia ante requerimientos urgentes de repuestos en bahía. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{supplier\_id (TEXT)}, \texttt{tenant\_id (TEXT)}, \texttt{business\_name (TEXT)}, \texttt{tax\_id (TEXT)}, \texttt{phone (TEXT)}, \texttt{synced\_at (TEXT).} \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_local\_suppliers (supplier\_id) \newline - Índice B-Tree: idx\_local\_suppliers\_tenant (tenant\_id) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{offline\_inventory\_reservations}} \\*
\hline
\textbf{Motor y Producto} & SQLite 3 (Mobile Workshop) \\*
\hline
\textbf{Propósito y Aislamiento} & Buffer transaccional local de apartados de repuestos efectuados por operarios en foso. Retiene solicitudes mecánicas para su drenaje atómico e idempotente hacia la API central al recuperar enlace. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{reservation\_id (TEXT)}, \texttt{work\_order\_id (TEXT)}, \texttt{task\_id (TEXT)}, \texttt{item\_id (TEXT)}, \texttt{requested\_quantity (REAL)}, \texttt{status (TEXT)}, \texttt{retry\_count (INTEGER)}, \texttt{created\_at (TEXT)}, \texttt{synced\_at (TEXT).} \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_offline\_reservations (reservation\_id) \newline - CHECK: chk\_reservation\_status \newline - Índice B-Tree: idx\_reservations\_status (status, created\_at) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{auditable\_abstract\_entity}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito y Aislamiento} & Superclase JPA (@MappedSuperclass) que confiere clave primaria técnica unívoca, segregación multi-inquilino mandatoria, control de concurrencia optimista y auditoría temporal a las entidades del módulo. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{tenant\_id (UUID)}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ)}, \texttt{version (BIGINT)}, \texttt{deleted\_at (TIMESTAMPTZ).} \\*
\hline
\textbf{Constraints e Índices} & - PK técnica: pk\_auditable\_entity (id) \newline - FK lógica: tenant\_id. Superclase MappedSuperclass JPA con bloqueo optimista \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Elaboración propia en base al diseño relacional y la especificación física de persistencia.

A partir de la estructura formalizada en la @fig:database-diagram-inventory y la @tbl:inventory-database-objects, se identifican tres fundamentos de ingeniería de software que respaldan la solidez, integridad y resiliencia de la persistencia:

- **Aislamiento Multi-Inquilino y Control de Concurrencia Optimista en Inventario:**
  La segregación de la información logística en PostgreSQL 16 se asegura mediante la inclusión obligatoria de la clave foránea **tenant_id** en todas las tablas maestras, articulada con la restricción unívoca compuesta sobre (**tenant_id**, **sku**). Esta disposición impide colisiones de codificación entre talleres competidores, mientras que la columna **version** gestiona el control de concurrencia optimista, garantizando que dos operarios no asignen simultáneamente el saldo remanente de una misma pieza física.

- **Optimización de Asignación Cronológica FIFO y Desacoplamiento Multimedia:**
  La deducción algorítmica de costos First-In, First-Out se sustenta en el índice parcial B-Tree **idx_inventory_batches_item_fifo**, el cual descarta los lotes históricos con saldo agotado para resolver en tiempo sub-milisegundo la remesa activa más antigua. De forma complementaria, la integración con Firebase Storage bajo el patrón Direct-to-Cloud elude la memoria de la API Spring Boot al persistir exclusivamente las referencias sanitizadas de las facturas escaneadas, asegurando trazabilidad probatoria inalterable ante auditorías contables.

- **Resiliencia Operacional Desconectada en Foso Automotriz y Reconciliación Determinista:**
  La coexistencia del esquema central con el motor relacional SQLite 3 en terminales móviles salvaguarda la continuidad de la faena mecánica en fosas subterráneas sin cobertura inalámbrica [@herrera2026offline]. Mediante las estructuras **local_inventory_cache** y **offline_inventory_reservations**, los operarios consultan existencias y registran apartados provisionales que, al restablecerse el enlace de red, se drenan atómicamente hacia la API con claves de idempotencia para prevenir duplicidades o inconsistencias en el almacén [@korichi2026dmrp].

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