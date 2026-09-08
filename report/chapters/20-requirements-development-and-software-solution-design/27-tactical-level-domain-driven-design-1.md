## 2.6. Tactical-Level Domain-Driven Design

En esta sección el equipo expone y fundamenta la propuesta para la perspectiva táctica del diseño de la solución de software del ecosistema **Atelier**, centrándose primordialmente en la arquitectura interna del contenedor backend central **API Application**, pero articulando de manera formal su integración y correspondencia táctica hacia los productos cliente móviles del ecosistema: **Atelier Workshop**, desarrollada nativamente en Kotlin para Android y en Flutter y **Atelier Driver**, desarrollada en Flutter.

Habiendo delimitado en la fase estratégica precedente los bounded contexts del sistema y trazado sus mapas de contexto, el diseño táctico desciende al nivel de abstracción del código fuente, los contratos inmutables y los modelos de dominio. Su propósito es estructurar los componentes de software empleando los patrones tácticos canónicos de Domain-Driven Design: Raíces de Agregado, Entidades, Objetos de Valor, Servicios de Dominio, Fábricas, Interfaces de Repositorio y Eventos de Dominio.

La concepción arquitectónica de Atelier responde a la necesidad de gestionar una lógica de negocio automotriz sumamente densa y heterogénea:

- Aislamiento estricto multi-inquilino en cada operación y consulta transaccional para garantizar la privacidad y confidencialidad absoluta de los talleres mecánicos.
- Gestión operativa integral de mantenimiento, reparación y operaciones, abarcando presupuestos, órdenes de trabajo, asignación dinámica de mecánicos y registro de evidencias fotográficas.
- Valuación rigurosa de inventario de repuestos y lubricantes mediante el algoritmo de costeo FIFO por lotes de adquisición.
- Cumplimiento normativo tributario electrónico ante la SUNAT bajo el estándar OASIS UBL 2.1 a través de una Capa Anticorrupción con la plataforma Nubefact.
- Control de asistencia presencial y cálculo de planillas de mecánicos mediante geocercas GPS circulares calculadas con la fórmula matemática del Haversine.
- Procesamiento e ingesta continua de series de tiempo de telemetría vehicular IoT proveniente de escáneres OBD-II, con detección analítica de anomalías y disparo de notificaciones predictivas en tiempo real.

Para prevenir el deterioro del sistema en modelos anémicos y dependencias circulares, tanto el backend centralizado como las aplicaciones cliente móviles adoptan rigurosamente los preceptos de clean architecture, delimitando responsabilidades claras según la naturaleza técnica y operativa de cada producto:

**Estructura arquitectónica del backend**

El monolito modular backend se organiza internamente en cuatro capas concéntricas puras:

- **Capa de Dominio:** Núcleo conceptual del negocio, libre de acoplamientos tecnológicos. Contiene raíces de agregado, entidades, objetos de valor inmutables, servicios de dominio con algoritmos puros y puertos de repositorio. Presenta cero dependencias de Spring, JPA, Hibernate o Jackson.
- **Capa de Aplicación:** Orquesta los flujos de procesos del negocio aplicando el patrón CQRS. Los manejadores de comandos y consultas coordinan la ejecución transaccional y el manejo determinista de resultados mediante **Result<T, E>**.
- **Capa de Interfaz:** Adaptadores de entrada que reciben peticiones HTTP a través de controladores REST, validan sintácticamente los recursos DTO y exponen fachadas de contexto abierto (Open Host Service) para la comunicación intermodular.
- **Capa de Infraestructura:** Adaptadores de salida que implementan la persistencia física en PostgreSQL 16 y TimescaleDB mediante Spring Data JPA, clientes HTTP para plataformas externas y el worker asíncrono del transactional Outbox.

### 2.6.1. *Bounded Context: Shared*

El Bounded Context Shared constituye el núcleo transversal y fundacional de la arquitectura de Atelier Platform. En términos de Domain-Driven Design, este contexto encapsula aquellos conceptos, invariantes y tipos de datos que son compartidos de forma homogénea por todos los demás bounded contexts del ecosistema. Su presencia en la arquitectura previene la duplicidad de modelos y erradica el antipatrón de obsesión por primitivos, proveyendo abstracciones sólidas para el manejo de identidades, cálculos financieros, coordenadas geográficas y control determinista de resultados operativos.

#### 2.6.1.1. Domain Layer

La capa de dominio del Bounded Context Shared concentra las abstracciones arquitectónicas fundamentales, los contratos inmutables de eventos, la taxonomía de identificadores fuertemente tipados, los objetos de valor universales y la jerarquía de excepciones de dominio transversales a los ocho bounded contexts de Atelier Platform. Al modelar el lenguaje ubicuo fundacional de la solución, sus componentes residen en el paquete raíz **com.andeva.atelier.platform.shared.domain** y responden a cuatro directrices de diseño táctico:

- **Aislamiento de tecnologías de persistencia:** Las clases del dominio carecen de dependencias hacia frameworks ORM como Hibernate o especificaciones como Jakarta Persistence. La herencia de Spring Data Commons se circunscribe estrictamente al registro desacoplado de eventos de dominio en memoria, asegurando portabilidad e idoneidad para pruebas unitarias de ejecución instantánea.

- **Inmutabilidad y constructores compactos:** Todos los objetos de valor se estructuran como registros inmutables de Java, encapsulando la validación de frontera en sus constructores compactos para impedir que cualquier entidad u objeto de valor nazca en un estado inconsistente o no válido.

- **Seguridad de tipos en identificadores:** Erradicación sistemática del antipatrón de obsesión por primitivos mediante tipos dedicados basados en UUID, imposibilitando que las firmas de métodos intercambien accidentalmente identificadores de distinta semántica de negocio.

- **Precisión matemática y rigor normativo:** Modelado estricto de importes financieros (**Money**) y cubicajes (**Quantity**) mediante el tipo numérico exacto **BigDecimal** con redondeo bancario legal Half-Even a dos decimales, cálculo ortodrómico satelital puro mediante la fórmula del Haversine (**GeoPoint**) y verificación fiscal de documentos de identidad tributaria (**TaxId**) aplicando el algoritmo de Módulo 11 ponderado de la SUNAT.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo de la Capa de Dominio del Bounded Context Shared} \label{tbl:shared-domain-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\
\hline
\endhead
AbstractDomainAggregateRoot<T> & Superclase abstracta que gestiona la acumulación en memoria de eventos de dominio. \\*
\hline
\textbf{Categoría} & Raíz de Agregado Base \\*
\hline
\textbf{Relaciones} & Heredada por todas las Raíces de Agregado del sistema. \\*
\hline
\textbf{Paquete} & \texttt{...shared.domain.model.aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
DomainEvent & Contrato inmutable base para la publicación de eventos y el patrón Outbox. \\*
\hline
\textbf{Categoría} & Interfaz de Evento \\*
\hline
\textbf{Relaciones} & Implementada por todos los eventos de dominio de la plataforma. \\*
\hline
\textbf{Paquete} & \texttt{...shared.domain.events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Currency & Catálogo de divisas formales aceptadas en la plataforma (PEN y USD). \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada por el objeto de valor Money. \\*
\hline
\textbf{Paquete} & \texttt{...shared.domain.model.valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Money & Magnitud monetaria inmutable con escala a 2 decimales y redondeo Half-Even. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Asociada a precios, costos, cotizaciones y facturas. \\*
\hline
\textbf{Paquete} & \texttt{...shared.domain.model.valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
MeasurementUnit & Catálogo de unidades físicas de almacenamiento y consumo en taller. \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada por el objeto de valor Quantity. \\*
\hline
\textbf{Paquete} & \texttt{...shared.domain.model.valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Quantity & Cantidad física no negativa con escala decimal asociada a su unidad de medida. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Utilizada en inventario de repuestos y partidas de MRO. \\*
\hline
\textbf{Paquete} & \texttt{...shared.domain.model.valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Mileage & Odómetro automotriz expresado como entero no negativo en kilómetros. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Vinculado a vehículos, recepciones y telemetría OBD-II. \\*
\hline
\textbf{Paquete} & \texttt{...shared.domain.model.valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
TenantId & Identificador único universal fuertemente tipado del taller mecánico. \\*
\hline
\textbf{Categoría} & Objeto de Valor (ID) \\*
\hline
\textbf{Relaciones} & Clave transversal de particionamiento multi-inquilino. \\*
\hline
\textbf{Paquete} & \texttt{...shared.domain.model.valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
BranchId & Identificador único universal de la sede o sucursal física de atención. \\*
\hline
\textbf{Categoría} & Objeto de Valor (ID) \\*
\hline
\textbf{Relaciones} & Vinculado a bahías de servicio, almacenes y turnos. \\*
\hline
\textbf{Paquete} & \texttt{...shared.domain.model.valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
CustomerId & Identificador único universal del cliente particular o corporativo. \\*
\hline
\textbf{Categoría} & Objeto de Valor (ID) \\*
\hline
\textbf{Relaciones} & Vinculado a perfiles de clientes, vehículos y comprobantes. \\*
\hline
\textbf{Paquete} & \texttt{...shared.domain.model.valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
VehicleId & Identificador único universal de la unidad vehicular automotriz. \\*
\hline
\textbf{Categoría} & Objeto de Valor (ID) \\*
\hline
\textbf{Relaciones} & Vinculado a órdenes de trabajo, citas y telemetría. \\*
\hline
\textbf{Paquete} & \texttt{...shared.domain.model.valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
UserId & Identificador único universal de la cuenta de usuario del sistema. \\*
\hline
\textbf{Categoría} & Objeto de Valor (ID) \\*
\hline
\textbf{Relaciones} & Vinculado a membresías de taller, perfiles y auditorías. \\*
\hline
\textbf{Paquete} & \texttt{...shared.domain.model.valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
DistanceMeters & Magnitud escalar de separación espacial en metros no negativa. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Utilizada en la evaluación de geocercas satelitales. \\*
\hline
\textbf{Paquete} & \texttt{...shared.domain.model.valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
GeoPoint & Coordenadas WGS84 con cálculo ortodrómico basado en la fórmula del Haversine. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Utilizada en ubicación de sucursales y marcación de asistencia. \\*
\hline
\textbf{Paquete} & \texttt{...shared.domain.model.valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
TaxIdType & Tipología legal de documentos tributarios nacionales e internacionales. \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada por el objeto de valor TaxId. \\*
\hline
\textbf{Paquete} & \texttt{...shared.domain.model.valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
TaxId & Documento tributario validado mediante Módulo 11 (RUC) y longitud (DNI). \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Vinculado a talleres concesionarios, clientes y facturación. \\*
\hline
\textbf{Paquete} & \texttt{...shared.domain.model.valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
EmailAddress & Dirección de correo electrónico normalizada y validada bajo la RFC 5322. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Vinculada a cuentas de usuario, notificaciones y contactos. \\*
\hline
\textbf{Paquete} & \texttt{...shared.domain.model.valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PhoneNumber & Número telefónico internacional formateado según el estándar UIT-T E.164. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Vinculado a datos de contacto de clientes y mecánicos. \\*
\hline
\textbf{Paquete} & \texttt{...shared.domain.model.valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
DateRange & Intervalo temporal cerrado con invariante estricta de orden cronológico. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Utilizado en turnos laborales, contratos y períodos de análisis. \\*
\hline
\textbf{Paquete} & \texttt{...shared.domain.model.valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
DomainException & Superclase abstracta no comprobada portadora de código de error semántico. \\*
\hline
\textbf{Categoría} & Excepción Base \\*
\hline
\textbf{Relaciones} & Base para todas las excepciones del dominio del ecosistema. \\*
\hline
\textbf{Paquete} & \texttt{...shared.domain.exceptions} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Tipos de datos canónicos correspondientes al paquete com.andeva.atelier.platform.shared.domain.

A continuación, se profundiza en la especificación a manera de diccionario de cada una de las clases, objetos de valor y estructuras que componen esta capa.

**Superclase base de agregados y contrato de eventos de dominio**

En Domain-Driven Design, las raíces de agregado salvaguardan los límites de consistencia transaccional del negocio. Para facilitar la propagación de eventos hacia otros módulos y hacia el almacenamiento seguro del Transactional Outbox sin incorporar librerías ORM en el dominio, la arquitectura suministra la clase abstracta **AbstractDomainAggregateRoot<T>**.

Esta clase emplea la técnica de polimorfismo con límite F (F-bounded polymorphism, expresado como `T extends AbstractDomainAggregateRoot<T>`), permitiendo que las clases derivadas mantengan una referencia fuertemente tipada sobre sí mismas. Al extender de la clase base de Spring Data Commons, la superclase acumula eventos de dominio en una colección interna en memoria cada vez que se invoca el método protegido *registerDomainEvent()*.

Dichos eventos quedan disponibles para su lectura inmutable mediante *domainEvents()* y son eliminados a través de *clearDomainEvents()* una vez que la transacción de persistencia se confirma exitosamente. Asimismo, sobrescribe los métodos *equals()* y *hashCode()* para asegurar que dos agregados se consideren idénticos si y solo si comparten la misma identidad de dominio, preservando la coherencia semántica en colecciones.

Por su parte, la interfaz **DomainEvent** establece el contrato inmutable universal que deben satisfacer todos los eventos de dominio del ecosistema Atelier. Cada evento generado encapsula un identificador unívoco de evento (**eventId**), la marca temporal precisa de ocurrencia en UTC (**occurredOn**), el identificador textual de la raíz de agregado emisora (**aggregateId**) y el descriptor calificado del tipo de evento (**eventType**), habilitando una deserialización polimórfica sin ambigüedades.

En la @tbl:shared-aggregates-and-events se detallan los miembros de la superclase de agregados y el contrato de eventos.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de la Superclase Base de Agregados y la Interfaz de Eventos de Dominio} \label{tbl:shared-aggregates-and-events} \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Propósito} \\
\hline
\endhead
\multicolumn{2}{|c|}{\textbf{Componente:} AbstractDomainAggregateRoot<T> (Superclase Base de Agregados)} \\*
\hline
domainEvents (Atributo) & Acumulador interno de eventos de dominio generados durante la transacción en memoria. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Collection<Object>} \\*
\hline
\textbf{Ámbito de Acceso} & Protegido \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
registerDomainEvent & Registra un nuevo evento de dominio en la colección acumuladora en memoria. \newline \textbf{Reglas de negocio:} \newline - Rechaza argumentos nulos mediante validación estricta. \newline - Asocia la identidad del agregado al evento emitido. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void registerDomainEvent(Object event)} \\*
\hline
\textbf{Ámbito de Acceso} & Protegido \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
domainEvents (Método) & Expone la colección de eventos de dominio acumulados para su procesamiento posterior. \newline \textbf{Reglas de negocio:} \newline - Retorna una vista inmutable mediante colección no modificable para impedir mutaciones externas. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Collection<Object> domainEvents()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
clearDomainEvents & Purga la colección de eventos de dominio en memoria. \newline \textbf{Reglas de negocio:} \newline - Se ejecuta exclusivamente tras la confirmación atómica de la transacción de persistencia. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void clearDomainEvents()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
equals & Evalúa la igualdad semántica entre dos instancias de raíz de agregado. \newline \textbf{Reglas de negocio:} \newline - Se fundamenta única y exclusivamente en la identidad de dominio (\textit{id}). \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean equals(Object obj)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
hashCode & Genera el código hash de la entidad para estructuras de datos basadas en tablas hash. \newline \textbf{Reglas de negocio:} \newline - Se calcula a partir de la identidad de dominio para mantener coherencia estricta con \textit{equals()}. \\*
\hline
\textbf{Tipo o Firma} & \texttt{int hashCode()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Componente:} DomainEvent (Interfaz de Contrato de Eventos de Dominio)} \\*
\hline
eventId & Expone el identificador global unívoco del evento de dominio. \newline \textbf{Reglas de negocio:} \newline - Garantiza la idempotencia y deduplicación en el despacho hacia brokers de mensajería. \\*
\hline
\textbf{Tipo o Firma} & \texttt{UUID} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
occurredOn & Expone la marca temporal precisa de ocurrencia del evento. \newline \textbf{Reglas de negocio:} \newline - Registrada inmutablemente en el huso horario estándar UTC. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Instant} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
aggregateId & Expone la clave textual unívoca de la raíz de agregado que originó el evento. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
eventType & Expone el descriptor semántico calificado del tipo de evento. \newline \textbf{Reglas de negocio:} \newline - Utilizado para el enrutamiento polimórfico en el Transactional Outbox. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes ubicados en com.andeva.atelier.platform.shared.domain.model.aggregates y com.andeva.atelier.platform.shared.domain.events.

En términos de relaciones, **AbstractDomainAggregateRoot<T>** actúa como superclase generalizadora directa de las raíces de agregado de todos los módulos de negocio de Atelier: **Tenant**, **User** y **TenantMembership** para el bounded context IAM, **Customer** y **Vehicle** para el bounded context CRM, **WorkOrder** para el bounded context MRO, **InventoryItem** para el bounded context Inventory, **WorkShift** y **PayrollPayment** para el bounded context Human Resources, **ElectronicVoucher** para el bounded context Invoicing, **SubscriptionPlan** por parte del bounded context Billing y **Obd2Device** para el bounded context IoT.

Por su parte, la interfaz **DomainEvent** es implementada por la totalidad de los registros de eventos de dominio concretos generados por dichas raíces, garantizando compatibilidad con el worker de despacho transaccional hacia brokers externos.

**Objetos de valor financieros, cuantitativos y métricos**

La gestión de talleres mecánicos demanda una precisión aritmética rigurosa en cobros, costeo de mano de obra, cubicación de lubricantes y control de desgaste kilométrico. Para evitar errores de redondeo de punto flotante binario y operaciones ilícitas entre magnitudes incomparables, el Bounded Context Shared incorpora un conjunto especializado de objetos de valor inmutables:

- **Currency**: Enumeración que tipifica las monedas formales aceptadas en la plataforma, abarcando PEN (Sol peruano, símbolo "S/") y USD (Dólar estadounidense, símbolo "$") de conformidad con la norma ISO 4217. Cada constante provee métodos de acceso a su descripción y símbolo representativo.

- **Money**: Registro inmutable compuesto por un monto numérico (**amount**: `BigDecimal`) y su respectiva divisa (**currency**: Currency). Su constructor compacto aplica una escala fija de 2 decimales con la estrategia de redondeo bancario `RoundingMode.HALF_EVEN`, descartando valores nulos. Define constantes estáticas para valores cero (**ZERO_PEN** y **ZERO_USD**) y una factoría estática *of(BigDecimal, Currency)*. Ofrece operaciones aritméticas seguras (*add*, *subtract*, *multiply*, *divide*), verificando obligatoriamente que ambas magnitudes compartan la misma divisa antes de operar y arrojando **CurrencyMismatchException** en caso de discrepancia. Asimismo, provee métodos lógicos de comparación (*isGreaterThan*, *isLessThan*, *isPositive*, *isZero*).

- **MeasurementUnit**: Enumeración que define las unidades de medida físicas homologadas para el control de inventario y tarificación de servicios: UNIT (unidades indivisibles), LITER (litros de lubricantes o fluidos), GALLON (galones), KILOGRAM (kilogramos de grasa o metales), METER (metros lineales de cableado o mangueras) y HOUR (horas hombre de diagnóstico o mano de obra).

- **Quantity**: Registro inmutable que asocia un valor numérico decimal (**value**: **BigDecimal**) con su unidad de medida (**unit**: MeasurementUnit). Su constructor compacto impone una escala de 2 decimales con redondeo Half-Even y prohíbe terminantemente cantidades negativas (*value* ≥ 0.00). Implementa operaciones de suma (*add*), resta controlada (*subtract*) y verificación de suficiencia de existencias (*hasSufficient*), comprobando que ambas magnitudes utilicen idéntica unidad de medida.

- **Mileage**: Registro inmutable que modela el kilometraje automotriz acumulado mediante un entero escalar (**value**: int). Su constructor compacto asegura la invariante de no negatividad (*value* ≥ 0). Suministra métodos de comparación de progresión (*isGreaterThan*) y de cálculo de recorrido diferencial (*difference*), fundamentales para validar que el odómetro en una orden de trabajo no decrezca respecto a visitas previas.

En la @tbl:shared-financial-and-measurement-vos se detalla la estructura y comportamiento de estos objetos de valor.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de los Objetos de Valor Financieros, Cuantitativos y Métricos} \label{tbl:shared-financial-and-measurement-vos} \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Propósito} \\
\hline
\endhead
\multicolumn{2}{|c|}{\textbf{Componente:} Money (Objeto de Valor Financiero)} \\*
\hline
amount & Almacena la cuantía numérica inmutable del importe monetario. \newline \textbf{Reglas de negocio:} \newline - Normalizado a escala fija de 2 decimales exactos. \newline - Redondeo bancario legal bajo la estrategia \textit{RoundingMode.HALF\_EVEN}. \\*
\hline
\textbf{Tipo o Firma} & \texttt{BigDecimal} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
currency & Divisa formal asociada al importe monetario. \newline \textbf{Reglas de negocio:} \newline - Restringida estrictamente a los valores autorizados en la enumeración \textit{Currency}. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Currency} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
ZERO\_PEN & Constante estática representativa de importe nulo en moneda nacional (S/ 0.00). \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
ZERO\_USD & Constante estática representativa de importe nulo en moneda extranjera (\$ 0.00). \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
add & Suma aritméticamente dos objetos de valor monetarios. \newline \textbf{Reglas de negocio:} \newline - Exige homogeneidad estricta de divisas entre ambos importes. \newline - Arroja \textit{CurrencyMismatchException} ante discrepancia de moneda. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money add(Money other)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
subtract & Resta aritméticamente dos objetos de valor monetarios. \newline \textbf{Reglas de negocio:} \newline - Exige homogeneidad estricta de divisas entre ambos importes. \newline - Arroja \textit{CurrencyMismatchException} si las divisas no coinciden. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money subtract(Money other)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
multiply & Multiplica el importe monetario por un factor numérico escalar. \newline \textbf{Reglas de negocio:} \newline - Aplica redondeo bancario \textit{HALF\_EVEN} a 2 decimales sobre el resultado. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money multiply(BigDecimal factor)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
divide & Divide el importe monetario entre un divisor numérico escalar. \newline \textbf{Reglas de negocio:} \newline - Prohíbe terminantemente divisores iguales a cero. \newline - Aplica redondeo bancario \textit{HALF\_EVEN} a 2 decimales sobre el cociente. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money divide(BigDecimal divisor)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
isGreaterThan & Determina si el importe actual supera estrictamente al importe suministrado. \newline \textbf{Reglas de negocio:} \newline - Exige homogeneidad estricta de divisas antes de la comparación. \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean isGreaterThan(Money other)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
isPositive & Determina si el importe monetario es estrictamente mayor a cero. \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean isPositive()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
isZero & Determina si el importe monetario es exactamente equivalente a cero. \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean isZero()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Componente:} Quantity (Objeto de Valor Cuantitativo)} \\*
\hline
value & Almacena la magnitud numérica cuantitativa del insumo o servicio. \newline \textbf{Reglas de negocio:} \newline - Impone la invariante de no negatividad (\textit{value} ≥ 0.00). \newline - Escala fijada a 2 decimales con redondeo \textit{HALF\_EVEN}. \\*
\hline
\textbf{Tipo o Firma} & \texttt{BigDecimal} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
unit & Unidad de almacenamiento o tarificación física asociada. \\*
\hline
\textbf{Tipo o Firma} & \texttt{MeasurementUnit} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
add & Incrementa la cantidad actual sumando otra magnitud cuantitativa. \newline \textbf{Reglas de negocio:} \newline - Exige correspondencia exacta en la unidad de medida (\textit{unit}). \\*
\hline
\textbf{Tipo o Firma} & \texttt{Quantity add(Quantity other)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
subtract & Reduce la cantidad actual restando otra magnitud cuantitativa. \newline \textbf{Reglas de negocio:} \newline - Exige correspondencia exacta en la unidad de medida (\textit{unit}). \newline - Prohíbe resultados negativos arrojando \textit{BusinessRuleValidationException}. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Quantity subtract(Quantity other)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
hasSufficient & Evalúa si la cantidad actual cubre o supera la magnitud requerida. \newline \textbf{Reglas de negocio:} \newline - Exige que ambas cantidades compartan la misma unidad de medida. \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean hasSufficient(Quantity req)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Componente:} Mileage (Objeto de Valor Métrico)} \\*
\hline
value & Almacena el valor escalar del odómetro vehicular en kilómetros. \newline \textbf{Reglas de negocio:} \newline - Impone la invariante de no negatividad (\textit{value} ≥ 0). \\*
\hline
\textbf{Tipo o Firma} & \texttt{int} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
isGreaterThan & Comprueba si el kilometraje actual supera al valor de comparación. \newline \textbf{Reglas de negocio:} \newline - Utilizado para validar que el odómetro no decrezca en inspecciones sucesivas. \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean isGreaterThan(Mileage o)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
difference & Calcula el delta absoluto de recorrido en kilómetros entre dos lecturas. \\*
\hline
\textbf{Tipo o Firma} & \texttt{int difference(Mileage other)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al paquete com.andeva.atelier.platform.shared.domain.model.valueobjects.

Respecto a sus relaciones, Money y Currency son consumidos directamente por los contextos de MRO, Inventario y Facturación. El objeto Quantity interactúa íntimamente con los agregados InventoryItem y WorkOrder para controlar el despacho de insumos, mientras que Mileage es utilizado por CRM para el historial vehicular, por MRO en la recepción de la unidad y por IoT Telemetry para contrastar lecturas de odometría extraídas de la computadora a bordo del automóvil.

**Taxonomía de identificadores**

En aplicaciones empresariales de gran escala, el uso recurrente del tipo estándar UUID para referenciar entidades introduce el antipatrón de obsesión por primitivos. Bajo este esquema, una firma de método como `assignVehicle(UUID tenantId, UUID customerId, UUID vehicleId)` resulta propensa a errores humanos indetectables por el compilador, ya que el orden accidental de los argumentos no viola la compatibilidad de tipos.

Para resolver esta vulnerabilidad, Atelier diseña una taxonomía de registros inmutables que encapsulan identificadores únicos universales, dotando a la capa de dominio de seguridad de tipos estricta con **Type Safety**:

- **TenantId**: Modela el identificador unívoco de un taller mecánico inquilino. Actúa como clave de particionamiento lógico multi-tenant en todas las entidades, agregados y consultas de la solución, garantizando que ninguna operación transgreda las fronteras de aislamiento de datos del cliente corporativo.
- **BranchId**: Representa el identificador único de una sede física o sucursal del taller mecánico. Es utilizado para segmentar inventarios físicos, asociar bahías operativas de mantenimiento y delimitar la marcación laboral presencial.
- **CustomerId**: Representa el identificador unívoco de un cliente (propietario particular o empresa flotillera). Vincula los expedientes vehiculares, las órdenes de servicio y los comprobantes de pago emitidos.
- **VehicleId**: Representa el identificador unívoco de la unidad vehicular automotriz. Asocia la ficha técnica del vehículo, su historial de mantenimientos en MRO y su vinculación con dispositivos telemáticos OBD-II.
- **UserId**: Representa el identificador unívoco de una cuenta de usuario autenticable en la plataforma. Es empleado en el control de acceso, asignación de membresías en talleres, auditoría transaccional y vinculación de expedientes laborales.

Cada uno de estos registros implementa validación estricta de no nulidad en su constructor compacto y expone métodos factoría estáticos: *of(UUID value)* para instanciación controlada, *of(String value)* con análisis sintáctico seguro de cadenas UUID y *generate()* para la creación de nuevos identificadores criptográficamente aleatorios mediante *UUID.randomUUID()*.

En la @tbl:shared-identity-vos se expone la especificación de estos identificadores tipados.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\raggedright\arraybackslash}p{4.2cm} | >{\raggedright\arraybackslash}p{11.2cm} |}
\caption{Especificación de los Objetos de Valor de Identidad Fuertemente Tipados} \label{tbl:shared-identity-vos} \\
\hline
\thfirst{Factorías Estáticas} & \thcell{Propósito Arquitectónico y Frontera de Dominio} \\
\hline
\endfirsthead
\hline
\thfirst{Factorías Estáticas} & \thcell{Propósito Arquitectónico y Frontera de Dominio} \\
\hline
\endhead
\multicolumn{2}{|c|}{\textbf{Objeto de Valor:} TenantId (UUID)} \\*
\hline
- \texttt{of(UUID)} \newline - \texttt{of(String)} \newline - \texttt{generate()} & Clave transversal obligatoria de particionamiento lógico multi-inquilino. \\
\hline
\multicolumn{2}{|c|}{\textbf{Objeto de Valor:} BranchId (UUID)} \\*
\hline
- \texttt{of(UUID)} \newline - \texttt{of(String)} \newline - \texttt{generate()} & Demarcación física de inventarios de almacén, bahías y turnos de trabajo. \\
\hline
\multicolumn{2}{|c|}{\textbf{Objeto de Valor:} CustomerId (UUID)} \\*
\hline
- \texttt{of(UUID)} \newline - \texttt{of(String)} \newline - \texttt{generate()} & Asociación unívoca de clientes particulares y flotas comerciales. \\
\hline
\multicolumn{2}{|c|}{\textbf{Objeto de Valor:} VehicleId (UUID)} \\*
\hline
- \texttt{of(UUID)} \newline - \texttt{of(String)} \newline - \texttt{generate()} & Identificación de unidades automotrices para trazabilidad MRO y telemetría. \\
\hline
\multicolumn{2}{|c|}{\textbf{Objeto de Valor:} UserId (UUID)} \\*
\hline
- \texttt{of(UUID)} \newline - \texttt{of(String)} \newline - \texttt{generate()} & Identificación de usuarios del sistema para control de acceso y auditoría. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}

*Nota.* Registros inmutables del paquete com.andeva.atelier.platform.shared.domain.model.valueobjects.

En cuanto a sus relaciones, estos identificadores constituyen los puentes de referencia débiles preconizados por DDD para comunicar agregados entre distintos bounded contexts sin incurrir en acoplamiento de grafo en memoria. De este modo, un agregado **WorkOrder** en el contexto MRO no contiene referencias completas a las entidades **Tenant**, **Customer** o **Vehicle**, sino que almacena exclusivamente sus objetos de valor **TenantId**, **CustomerId** y **VehicleId**, preservando fronteras transaccionales limpias y altamente escalables.

**Objetos de valor geoespaciales, fiscales y de contacto**

La operación física de los talleres automotrices involucra geolocalización de sedes, cumplimiento estricto de la normativa tributaria peruana y comunicación automatizada omnicanal con usuarios y conductores. El Bounded Context Shared unifica estas capacidades mediante objetos de valor especializados:

- **GeoPoint** y **DistanceMeters**: El registro inmutable `GeoPoint(double latitude, double longitude)` modela coordenadas esféricas bajo el datum geodésico WGS84. Su constructor compacto impone límites geográficos universales: latitud dentro del intervalo [-90.0, 90.0] y longitud dentro de [-180.0, 180.0]. Incorpora el método *distanceTo(GeoPoint other)*, el cual implementa de manera pura la formulación trigonométrica del Haversine:

   $$\Delta\sigma = 2 \arcsin\left(\sqrt{\sin^2\left(\frac{\Delta\phi}{2}\right) + \cos(\phi_1)\cos(\phi_2)\sin^2\left(\frac{\Delta\lambda}{2}\right)}\right)$$
   $$d = R \cdot \Delta\sigma$$

   donde *R* = 6,371,000 metros representa el radio medio de la Tierra. El resultado se retorna encapsulado en el registro `DistanceMeters(double value)`, cuya invariante restringe valores negativos (*value* ≥ 0.0) y cuyo método *isWithinThreshold(double threshold)* facilita la verificación instantánea de geocercas circulares.

- **TaxIdType** y **TaxId**: Para asegurar el estricto cumplimiento ante la Superintendencia Nacional de Aduanas y de Administración Tributaria, la enumeración TaxIdType categoriza los documentos oficiales reconocidos: RUC, DNI, CE y PASSPORT. Por su parte, el registro inmutable `TaxId(String value, TaxIdType type)` ejecuta validaciones algorítmicas de frontera:
   - Para documentos tipo DNI, verifica que la cadena esté conformada por exactamente 8 dígitos numéricos (`^\d{8}$`).
   - Para documentos tipo RUC, verifica la presencia de 11 dígitos numéricos (`^\d{11}$`) y ejecuta el algoritmo de Módulo 11 ponderado oficial de SUNAT. Dicho algoritmo multiplica los primeros diez dígitos por los coeficientes fijos [5, 4, 3, 2, 7, 6, 5, 4, 3, 2], calcula la suma ponderada, obtiene el residuo respecto a 11 y deduce el dígito verificador (11 - (suma mod 11)), comprobando que coincida exactamente con el undécimo dígito.

- **EmailAddress**: Registro inmutable que almacena direcciones de correo electrónico. Su constructor compacto elimina espacios en blanco circundantes, convierte la totalidad de la cadena a minúsculas para prevenir cuentas duplicadas por disparidad de capitalización y valida su estructura sintáctica mediante una expresión regular que satisface la especificación técnica RFC 5322.

- **PhoneNumber**: Registro inmutable que representa números telefónicos bajo la norma internacional UIT-T E.164. Valida que el número incluya el prefijo internacional con signo positivo opcional seguido de 7 a 15 dígitos numéricos (`^\+?[1-9]\d{7,14}$`), garantizando interoperabilidad con pasarelas de mensajería SMS y WhatsApp de alertas mecánicas.

- **DateRange**: Registro inmutable delimitado por dos fechas (**startDate**: LocalDate, **endDate**: LocalDate). Su constructor compacto valida la invariante cronológica obligatoria que prohíbe que la fecha final sea anterior a la inicial (`!endDate.isBefore(startDate)`). Provee métodos de cálculo temporal como *contains(LocalDate)* para evaluar la pertenencia de un hito y *overlaps(DateRange)* para la detección de traslapes en programaciones de talleres o contratos de trabajo.

En la @tbl:shared-spatial-fiscal-contact-vos se exponen los miembros y reglas operativas de estos objetos de valor.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de los Objetos de Valor Espaciales, Fiscales y de Contacto} \label{tbl:shared-spatial-fiscal-contact-vos} \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Propósito} \\
\hline
\endhead
\multicolumn{2}{|c|}{\textbf{Componente:} GeoPoint (Objeto de Valor Geoespacial)} \\*
\hline
latitude & Almacena la latitud geográfica en el datum geodésico WGS84. \newline \textbf{Reglas de negocio:} \newline - Rango angular restringido estrictamente al intervalo [-90.0, 90.0]. \\*
\hline
\textbf{Tipo o Firma} & \texttt{double} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
longitude & Almacena la longitud geográfica en el datum geodésico WGS84. \newline \textbf{Reglas de negocio:} \newline - Rango angular restringido estrictamente al intervalo [-180.0, 180.0]. \\*
\hline
\textbf{Tipo o Firma} & \texttt{double} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
distanceTo & Calcula la distancia geodésica ortodrómica hacia otro punto geográfico. \newline \textbf{Reglas de negocio:} \newline - Aplica la formulación del Semiverseno (\textit{Haversine}) sobre una esfera de radio medio terrestre \textit{R} = 6,371,000 m. \\*
\hline
\textbf{Tipo o Firma} & \texttt{DistanceMeters distanceTo(GeoPoint o)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Componente:} DistanceMeters (Objeto de Valor de Separación Espacial)} \\*
\hline
value & Almacena la magnitud física escalar de separación espacial en metros. \newline \textbf{Reglas de negocio:} \newline - Impone la invariante de distancia no negativa (\textit{value} ≥ 0.0). \\*
\hline
\textbf{Tipo o Firma} & \texttt{double} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
isWithinThreshold & Evalúa si la distancia calculada se encuentra dentro del radio límite permitido. \newline \textbf{Reglas de negocio:} \newline - Utilizado para la validación de geocercas en la marcación presencial de mecánicos. \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean isWithinThreshold(double t)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Componente:} TaxId (Objeto de Valor Fiscal)} \\*
\hline
value & Almacena la cadena alfanumérica depurada representativa del documento tributario. \newline \textbf{Reglas de negocio:} \newline - Desprovista de guiones, espacios o caracteres especiales. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
type & Tipología legal del documento según el catálogo normativo SUNAT. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TaxIdType} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
ruc & Factoría estática para la construcción de identificadores tributarios de tipo RUC. \newline \textbf{Reglas de negocio:} \newline - Exige exactamente 11 dígitos numéricos. \newline - Prefijo inicial restringido a 10, 15, 17 o 20. \newline - Superación mandatoria del algoritmo de verificación ponderada por Módulo 11. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TaxId ruc(String rucValue)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
dni & Factoría estática para la construcción de documentos de identidad nacional (DNI). \newline \textbf{Reglas de negocio:} \newline - Exige exactamente 8 dígitos numéricos continuos. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TaxId dni(String dniValue)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Componente:} EmailAddress (Objeto de Valor de Contacto)} \\*
\hline
value & Almacena la dirección de correo electrónico normalizada para comunicaciones. \newline \textbf{Reglas de negocio:} \newline - Validación de estructura sintáctica conforme a la norma RFC 5322. \newline - Conversión automática a minúsculas canónicas para prevenir duplicidad de cuentas. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\multicolumn{2}{|c|}{\textbf{Componente:} PhoneNumber (Objeto de Valor de Contacto)} \\*
\hline
value & Almacena el número telefónico para mensajería SMS y WhatsApp. \newline \textbf{Reglas de negocio:} \newline - Formato internacional conforme al estándar ITU-T E.164 (signo '+' seguido de código de país y abonado). \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\multicolumn{2}{|c|}{\textbf{Componente:} DateRange (Objeto de Valor Temporal)} \\*
\hline
startDate & Almacena la fecha inicial del intervalo temporal. \newline \textbf{Reglas de negocio:} \newline - Valor obligatorio no nulo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{LocalDate} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
endDate & Almacena la fecha de término del intervalo temporal. \newline \textbf{Reglas de negocio:} \newline - Obligatoriamente posterior o igual a \textit{startDate} (\textit{endDate} ≥ \textit{startDate}). \\*
\hline
\textbf{Tipo o Firma} & \texttt{LocalDate} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
contains & Evalúa si una fecha específica se ubica dentro del intervalo cronológico cerrado. \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean contains(LocalDate date)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
overlaps & Comprueba si dos intervalos temporales presentan traslape o solapamiento parcial. \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean overlaps(DateRange other)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes del paquete com.andeva.atelier.platform.shared.domain.model.valueobjects.

En cuanto a sus relaciones en el ecosistema, **GeoPoint** y **DistanceMeters** son utilizados por el módulo IAM para fijar las coordenadas de cada sucursal y por el módulo de Recursos Humanos para verificar que la marcación presencial de asistencia de los mecánicos ocurra dentro del radio circular permitido del taller.

Por su parte, **TaxId** y **TaxIdType** son requeridos por IAM para validar el RUC de la empresa del taller, por CRM para el padrón de clientes y por Facturación Electrónica para la confección del comprobante XML UBL 2.1 exigido por SUNAT. Los objetos **EmailAddress** y **PhoneNumber** actúan como medios de contacto obligatorios en perfiles de usuario y órdenes de servicio, mientras que **DateRange** regula la vigencia de suscripciones SaaS, contratos laborales de operarios y rangos de extracción analítica en telemetría IoT.

**Jerarquía de excepciones de dominio**

En estricta observancia de los fundamentos de Clean Architecture, la capa de dominio de Atelier no propaga excepciones genéricas de infraestructura ni depende de bibliotecas web para la señalización de errores. Cuando una operación de negocio o la instanciación de un objeto de valor transgrede una invariante del dominio, el sistema interrumpe la ejecución mediante excepciones no comprobadas fuertemente tipadas.

La base de esta jerarquía es la clase abstracta **DomainException**, la cual hereda directamente de `java.lang.RuntimeException` y almacena un código alfanumérico inmutable (**errorCode**: String). Este código proporciona un identificador semántico independiente del idioma o del canal de entrega.

Dicho diseño facilita que las capas superiores traduzcan de manera inmediata el error hacia una falla tipada en el tipo de resultado funcional **Result<T, E>** o hacia una respuesta REST estandarizada bajo la norma RFC 7807. A partir de esta clase base se derivan tres excepciones canónicas especializadas:

- **BusinessRuleValidationException**: Disparada cuando la invocación de un método de negocio transgrede una regla o invariante explícita del dominio. Asocia el código `BUSINESS_RULE_VIOLATION`.
- **EntityNotFoundException**: Disparada ante la inexistencia de una entidad o referencia requerida dentro de un límite de consistencia transaccional. Asocia el código de error `ENTITY_NOT_FOUND`.
- **CurrencyMismatchException**: Disparada de forma específica cuando una operación aritmética en el objeto de valor Money involucra importes con divisas heterogéneas sin previa conversión formal. Asocia el código `CURRENCY_MISMATCH`.

En la @tbl:shared-domain-exceptions se sintetiza la taxonomía de excepciones de dominio.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.8cm} | >{\raggedright\arraybackslash}p{9.6cm} |}
\caption{Jerarquía de Excepciones de Dominio y Códigos de Error Semánticos} \label{tbl:shared-domain-exceptions} \\
\hline
\thfirst{Código de Error Semántico} & \thcell{Causal de Lanzamiento en el Dominio} \\
\hline
\endfirsthead
\hline
\thfirst{Código de Error Semántico} & \thcell{Causal de Lanzamiento en el Dominio} \\
\hline
\endhead
\multicolumn{2}{|c|}{\textbf{Excepción:} DomainException (Superclase abstracta)} \\*
\hline
\textit{Parametrizado} & Superclase abstracta de anomalías de lógica del dominio. Transporta e inicializa el código semántico de error. \\
\hline
\multicolumn{2}{|c|}{\textbf{Excepción:} BusinessRuleValidationException (\texttt{DomainException})} \\*
\hline
\texttt{BUSINESS\_RULE\_VIOLATION} & Violación explícita de invariantes de estado, argumentos no válidos o transiciones de ciclo de vida ilícitas. \\
\hline
\multicolumn{2}{|c|}{\textbf{Excepción:} EntityNotFoundException (\texttt{DomainException})} \\*
\hline
\texttt{ENTITY\_NOT\_FOUND} & Ausencia o inexistencia de una entidad o agregado requerido dentro del límite de consistencia transaccional. \\
\hline
\multicolumn{2}{|c|}{\textbf{Excepción:} CurrencyMismatchException (\texttt{DomainException})} \\*
\hline
\texttt{CURRENCY\_MISMATCH} & Intento de realizar operaciones aritméticas entre objetos de valor \textit{Money} con divisas heterogéneas. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}

*Nota.* Componentes del paquete com.andeva.atelier.platform.shared.domain.exceptions.

En términos de interacción arquitectónica, estas excepciones son arrojadas exclusivamente en el núcleo del dominio cuando se violan invariantes no recuperables. Al ascender hacia la Capa de Aplicación, los manejadores de comandos y consultas interceptan estas anomalías y las encapsulan ordenadamente como resultados fallidos con **Result.Failure**, garantizando que la Capa de Interfaz entregue respuestas HTTP deterministas y uniformes sin filtrar trazas internas de la pila de ejecución al usuario final.

#### 2.6.1.2. Interface Layer

La capa de interfaz del Bounded Context Shared consolida los contratos perimetrales de comunicación, los mecanismos de transformación de resultados funcionales hacia respuestas HTTP, los estándares de serialización de errores bajo la norma internacional RFC 7807 (*Problem Details for HTTP APIs*), el asesoramiento global de excepciones y la trazabilidad distribuida para la totalidad de peticiones que acceden a los ocho bounded contexts del ecosistema Atelier.

Ubicada en el paquete raíz `com.andeva.atelier.platform.shared.interfaces`, su concepción arquitectónica responde a cuatro directrices fundamentales:

- **Aislamiento Perimetral y Desacoplamiento del Dominio:** Los controladores REST jamás interactúan de forma directa con agregados o entidades de dominio ni capturan excepciones de bajo nivel. Toda comunicación se canaliza hacia la Capa de Aplicación mediante comandos o consultas, recibiendo como respuesta determinista el tipo de resultado sellado **Result<T, ApplicationError>**. La traducción hacia el protocolo HTTP se delega en ensambladores especializados (**ResponseEntityAssembler**).
- **Homogeneidad en la Representación de Anomalías:** Toda condición de error, ya sea una falla de validación sintáctica en el cuerpo de la petición (Jakarta Bean Validation), una regla de negocio insatisfecha en el dominio o una falla de infraestructura externa, se serializa como un recurso inmutable **ErrorResource**, suprimiendo cualquier filtración de volcados de pila o detalles sensibles del servidor hacia el cliente externo.
- **Estandarización de Respuestas Paginadas:** La gestión operativa de talleres mecánicos involucra la recuperación masiva de información en catálogos de repuestos, historiales vehiculares, expedientes de clientes y registros de telemetría. El registro genérico **PagedResultResource<T>** unifica la estructura de datos y metadatos de paginación (`page`, `size`, `totalElements`, `totalPages`, `first`, `last`) para todas las consultas del sistema.
- **Observabilidad y Correlación Distribuida:** Para asegurar la trazabilidad transversal en despliegues basados en contenedores y facilitar la auditoría de solicitudes concurrentes, el filtro perimetral **CorrelationIdFilter** extrae o genera un identificador unívoco de correlación (`X-Correlation-Id`), asociándolo tanto a las cabeceras HTTP de respuesta como al contexto de diagnóstico Mapped Diagnostic Context (MDC) de SLF4J.

En la @tbl:shared-interface-types se presenta el catálogo consolidado de los tipos que componen la Capa de Interfaz del Bounded Context Shared.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo Consolidado de la Capa de Interfaz del Bounded Context Shared} \label{tbl:shared-interface-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endhead
ErrorResource & Representación inmutable de errores HTTP estandarizada conforme a RFC 7807. \\*
\hline
\textbf{Categoría} & Recurso REST (DTO) \\*
\hline
\textbf{Relaciones} & Generado por ErrorResponseAssembler y GlobalExceptionHandler. \\*
\hline
\textbf{Paquete} & \texttt{...shared.interfaces.rest.resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
MessageResource & Respuesta inmutable para confirmaciones operativas simples sin cuerpo de entidad. \\*
\hline
\textbf{Categoría} & Recurso REST (DTO) \\*
\hline
\textbf{Relaciones} & Consumido en endpoints de acciones asíncronas o de comando. \\*
\hline
\textbf{Paquete} & \texttt{...shared.interfaces.rest.resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
PagedResultResource<T> & Contenedor genérico inmutable para colecciones paginadas de recursos. \\*
\hline
\textbf{Categoría} & Recurso REST (DTO) \\*
\hline
\textbf{Relaciones} & Utilizado por controladores REST de CRM, MRO, Inventario y Facturación. \\*
\hline
\textbf{Paquete} & \texttt{...shared.interfaces.rest.resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
ErrorResponseAssembler & Mapea errores de aplicación hacia respuestas HTTP con ErrorResource. \\*
\hline
\textbf{Categoría} & Ensamblador REST \\*
\hline
\textbf{Relaciones} & Traduce códigos semánticos hacia códigos de estado HTTP oficiales. \\*
\hline
\textbf{Paquete} & \texttt{...shared.interfaces.rest.transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
ResponseEntityAssembler & Ensamblador genérico que traduce resultados de tipo Result a respuestas ResponseEntity. \\*
\hline
\textbf{Categoría} & Ensamblador REST \\*
\hline
\textbf{Relaciones} & Utilizado por los controladores REST de todos los Bounded Contexts. \\*
\hline
\textbf{Paquete} & \texttt{...shared.interfaces.rest.transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
GlobalExceptionHandler & Interceptor global (\texttt{@RestControllerAdvice}) de excepciones web y dominio. \\*
\hline
\textbf{Categoría} & Asesor de Controladores \\*
\hline
\textbf{Relaciones} & Captura anomalías durante el ciclo de despacho HTTP de Spring MVC. \\*
\hline
\textbf{Paquete} & \texttt{...shared.interfaces.rest} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
CorrelationIdFilter & Filtro perimetral que inyecta \texttt{X-Correlation-Id} en petición, respuesta y MDC. \\*
\hline
\textbf{Categoría} & Filtro Web Perimetral \\*
\hline
\textbf{Relaciones} & Filtro de máxima precedencia en la cadena de filtros web. \\*
\hline
\textbf{Paquete} & \texttt{...shared.interfaces.rest.filters} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}

*Nota.* Componentes pertenecientes al paquete canónico com.andeva.atelier.platform.shared.interfaces.

A continuación, se profundiza en la especificación a manera de diccionario de cada una de las clases, ensambladores y controladores que integran esta capa.

**Recursos DTO y Representación de Respuestas REST**

Para evitar la exposición directa de las entidades de persistencia y preservar la inmutabilidad de los datos transferidos a través del protocolo HTTP, la arquitectura establece un catálogo de Objetos de Transferencia de Datos universales estructurados como registros inmutables de Java:

- **ErrorResource**: Modela la representación canónica de anomalías conforme al estándar RFC 7807. Encapsula el código alfanumérico estandarizado del error (**code**), una descripción legible amigable para el usuario o desarrollador (**message**), una lista inmutable de detalles específicos de validación de campos (**details**) y la marca temporal de ocurrencia en UTC (**timestamp**).

  Su constructor compacto garantiza que la colección de detalles jamás sea nula mediante una copia inmutable (`List.copyOf`), asignando por defecto la hora actual del sistema en caso de omisión. Incorpora la anotación `@JsonInclude(JsonInclude.Include.NON_EMPTY)` de Jackson para evitar la emisión de campos vacíos en la respuesta JSON final. Provee métodos factoría estáticos *of(String code, String message)* y *of(String code, String message, List<String> details)*.

- **MessageResource**: Modela respuestas de confirmación simple para aquellos endpoints donde la ejecución de una operación no produce una entidad persistida de retorno. Encapsula un mensaje textual legible (**message**) y su marca temporal UTC (**timestamp**).

- **PagedResultResource<T>**: Contenedor genérico para respuestas de consultas que retornan conjuntos paginados de datos. Encapsula la lista inmutable de elementos de la página actual (**items**), el índice numérico de la página solicitada (**page**, base cero), la dimensión máxima de la página (**size**), la cantidad total de registros coincidentes en la base de datos (**totalElements**), el número total de páginas computadas (**totalPages**) y los predicados booleanos de frontera (**first** y **last**).

  Su método factoría estático *of(List<T> items, int page, int size, long totalElements)* calcula automáticamente las páginas totales mediante la fórmula:
  $$\text{totalPages} = \left\lceil \frac{\text{totalElements}}{\text{size}} \right\rceil$$
  e infiere los estados **first** (`page == 0`) y **last** (`page >= totalPages - 1`), asegurando una navegación determinista en las aplicaciones clientes web y móviles.

En la @tbl:shared-interface-resources se detallan los atributos, constructores y métodos de estos recursos DTO.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de los Recursos REST DTO del Bounded Context Shared} \label{tbl:shared-interface-resources} \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Propósito} \\
\hline
\endhead
\multicolumn{2}{|c|}{\textbf{Componente:} ErrorResource (Recurso REST DTO de Errores RFC 7807)} \\*
\hline
code (Atributo) & Código semántico unívoco representativo del error. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
message (Atributo) & Explicación legible y contextual de la condición de error producida. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
details (Atributo) & Lista inmutable de fallas de validación a nivel de campo. \newline \textbf{Reglas de negocio:} \newline - Garantiza invariante de no nulidad mediante copia defensiva inmutable (\textit{List.copyOf}). \\*
\hline
\textbf{Tipo o Firma} & \texttt{List<String>} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
timestamp (Atributo) & Marca temporal precisa en huso horario estándar UTC del instante del error. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Instant} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
of (Factoría) & Factoría estática para instanciación rápida de errores sin lista de detalles. \\*
\hline
\textbf{Tipo o Firma} & \texttt{ErrorResource of(String c, String m)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
of (Factoría con detalles) & Factoría estática para errores complejos con desglose de campos observados. \\*
\hline
\textbf{Tipo o Firma} & \texttt{ErrorResource of(String c, String m, List<String> d)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Componente:} MessageResource (Recurso REST DTO de Confirmación Operativa)} \\*
\hline
message (Atributo) & Mensaje textual de confirmación operativa para endpoints de comando sin retorno de entidad. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
of (Factoría) & Factoría estática que asocia el mensaje con la estampa de tiempo actual del sistema. \\*
\hline
\textbf{Tipo o Firma} & \texttt{MessageResource of(String msg)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Componente:} PagedResultResource<T> (Recurso REST DTO para Respuestas Paginadas)} \\*
\hline
items (Atributo) & Colección inmutable de elementos correspondientes a la página solicitada. \\*
\hline
\textbf{Tipo o Firma} & \texttt{List<T>} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
page (Atributo) & Índice numérico de la página actual en base cero. \newline \textbf{Reglas de negocio:} \newline - Impone invariante de no negatividad (\textit{page} $\ge$ 0). \\*
\hline
\textbf{Tipo o Firma} & \texttt{int} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
size (Atributo) & Cantidad máxima de registros por página solicitada. \newline \textbf{Reglas de negocio:} \newline - Impone invariante estrictamente positiva (\textit{size} > 0). \\*
\hline
\textbf{Tipo o Firma} & \texttt{int} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
totalElements (Atributo) & Cardinalidad total de registros existentes en la base de datos. \newline \textbf{Reglas de negocio:} \newline - Impone invariante de no negatividad (\textit{totalElements} $\ge$ 0). \\*
\hline
\textbf{Tipo o Firma} & \texttt{long} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
totalPages (Atributo) & Total de páginas resultantes computadas mediante redondeo hacia arriba. \\*
\hline
\textbf{Tipo o Firma} & \texttt{int} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
first (Atributo) & Bandera lógica que certifica si la respuesta corresponde a la primera página (\textit{page} == 0). \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
last (Atributo) & Bandera lógica que certifica si la respuesta corresponde a la página de término (\textit{page} $\ge$ \textit{totalPages} - 1). \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
of (Factoría) & Factoría estática que calcula automáticamente totales de página y banderas booleanas de frontera. \\*
\hline
\textbf{Tipo o Firma} & \texttt{PagedResultResource<T> of(List<T> i, int p, int s, long t)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al paquete com.andeva.atelier.platform.shared.interfaces.rest.resources.

En cuanto a sus relaciones en el sistema, **ErrorResource** es generado internamente por **ErrorResponseAssembler** y por el controlador global **GlobalExceptionHandler**, siendo consumido por clientes externos ante cualquier anomalía. **MessageResource** es utilizado por los controladores de IAM y Billing para acuses de recibo operativos. Por su parte, **PagedResultResource<T>** mantiene una relación de asociación genérica con las consultas de listado de todos los bounded contexts de la plataforma.

**Ensambladores y Transformadores de Respuestas HTTP**

El desarrollo de controladores REST bajo enfoques tradicionales suele adolecer de alta redundancia, caracterizada por bloques dispersos de captura de excepciones y verificaciones condicionales anidadas para evaluar si una operación tuvo éxito o fallo. Para eliminar esta complejidad accidental y materializar el patrón Railway-Oriented Programming, el Bounded Context Shared introduce una pareja de ensambladores utilitarios altamente desacoplados:

- **ErrorResponseAssembler**: Clase final no instanciable que actúa como traductor de fallas de la Capa de Aplicación. Su método estático *toErrorResponseFromApplicationError(ApplicationError error)* analiza el código semántico inmutable portado por el error (`error.code()`) mediante una expresión switch de coincidencia de patrones, determinando el código de estado HTTP canónico más adecuado:
   - `NOT_FOUND`, `RESOURCE_NOT_FOUND`, `ENTITY_NOT_FOUND` → `HttpStatus.NOT_FOUND` (404).
   - `CONFLICT`, `ALREADY_EXISTS`, `DUPLICATE_RESOURCE` → `HttpStatus.CONFLICT` (409).
   - `BAD_REQUEST`, `VALIDATION_FAILED`, `INVALID_ARGUMENT` → `HttpStatus.BAD_REQUEST` (400).
   - `UNAUTHORIZED`, `INVALID_CREDENTIALS`, `TOKEN_EXPIRED` → `HttpStatus.UNAUTHORIZED` (401).
   - `FORBIDDEN`, `ACCESS_DENIED`, `SUBSCRIPTION_REQUIRED` → `HttpStatus.FORBIDDEN` (403).
   - `UNPROCESSABLE_ENTITY`, `BUSINESS_RULE_VIOLATION`, `INSUFFICIENT_STOCK`, `CURRENCY_MISMATCH` → `HttpStatus.UNPROCESSABLE_ENTITY` (422).
   - Cualquier otro código no registrado es `HttpStatus.INTERNAL_SERVER_ERROR` (500).

  Construye la instancia correspondiente de **ErrorResource** y retorna una respuesta HTTP fuertemente tipada `ResponseEntity<ErrorResource>`.

- **ResponseEntityAssembler**: Clase final de utilidad genérica que orquesta la conversión entre el tipo de resultado funcional **Result<T, ApplicationError>** y la abstracción `ResponseEntity<?>` de Spring Framework. Provee métodos estáticos sobrecargados diseñados para cubrir todos los patrones de interacción REST:
   - *toResponseEntityFromResult(result, resourceAssembler, successStatus)*: Procesa operaciones sobre entidades individuales. Si el resultado es **Result.Success**, ejecuta la función de transformación y retorna la respuesta con el código de éxito configurado (`HttpStatus.OK` o `HttpStatus.CREATED`). Si el resultado es **Result.Failure**, delega inmediatamente en **ErrorResponseAssembler**.
   - *toResponseEntityFromListResult(result, itemAssembler, successStatus)*: Procesa colecciones de entidades, aplicando de manera funcional la transformación elemento a elemento sobre el flujo de datos.
   - *toResponseEntityFromEmptyResult(result, successStatus)*: Maneja comandos que no devuelven carga útil sustancial, emitiendo códigos como `HttpStatus.NO_CONTENT` (204) ante ejecuciones satisfactorias.

En la @tbl:shared-interface-assemblers se resumen las firmas y comportamientos de estos ensambladores.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Métodos de los Ensambladores REST del Bounded Context Shared} \label{tbl:shared-interface-assemblers} \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Propósito} \\
\hline
\endhead
\multicolumn{2}{|c|}{\textbf{Componente:} ErrorResponseAssembler (Ensamblador de Respuestas de Error)} \\*
\hline
toErrorResponseFromApplicationError & Traduce el código de error semántico a código de estado HTTP oficial y construye el recurso estructurado. \newline \textbf{Reglas de negocio:} \newline - Mapea códigos semánticos hacia códigos de estado RFC 7807 (400, 401, 403, 404, 409, 422 o 500). \\*
\hline
\textbf{Tipo o Firma} & \texttt{ResponseEntity<ErrorResource> toErrorResponse(ApplicationError error)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Componente:} ResponseEntityAssembler (Ensamblador Genérico de Respuestas Funcionales)} \\*
\hline
toResponseEntityFromResult & Mapea resultados funcionales de entidades individuales aplicando ensamblado funcional declarativo. \newline \textbf{Reglas de negocio:} \newline - Ante \textit{Result.Success}, transforma la entidad con la función de mapeo y emite el código HTTP de éxito. \newline - Ante \textit{Result.Failure}, delega automáticamente en \textit{ErrorResponseAssembler}. \\*
\hline
\textbf{Tipo o Firma} & \texttt{ResponseEntity<?> toResponseEntityFromResult(Result<T, ApplicationError>, Function<T, R>, HttpStatus)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
toResponseEntityFromListResult & Mapea resultados funcionales de colecciones transformando cada registro de forma funcional. \\*
\hline
\textbf{Tipo o Firma} & \texttt{ResponseEntity<?> toResponseEntityFromListResult(Result<List<T>, ApplicationError>, Function<T, R>, HttpStatus)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
toResponseEntityFromEmptyResult & Mapea resultados funcionales vacíos emitiendo cabeceras de éxito sin cuerpo de respuesta. \\*
\hline
\textbf{Tipo o Firma} & \texttt{ResponseEntity<?> toResponseEntityFromEmptyResult(Result<Void, ApplicationError>, HttpStatus)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al paquete com.andeva.atelier.platform.shared.interfaces.rest.transform.

Respecto a sus relaciones, estos ensambladores representan el puente de enlace canónico entre la Capa de Aplicación y los Controladores REST de los ocho bounded contexts. Al utilizar **ResponseEntityAssembler**, los controladores de IAM, CRM, MRO, Inventario, Facturación, Recursos Humanos, Suscripciones y Telemetría reducen el cuerpo de sus métodos a una sola invocación declarativa, garantizando un manejo determinista y homogéneo de los flujos de respuesta en toda la plataforma.

**Control Global de Excepciones Web**

A pesar de que el flujo ordinario del sistema canaliza los errores de negocio a través del tipo de resultado **Result**, el entorno perimetral HTTP está expuesto a anomalías técnicas que escapan al control de los servicios de aplicación, incluyendo violaciones sintácticas en el análisis del JSON entrante, tipos de contenido no soportados o transgresiones directas de invariantes del dominio.

Para gobernar estos escenarios de forma centralizada y transparente, el Bounded Context Shared incorpora la clase **GlobalExceptionHandler**, anotada con `@RestControllerAdvice`. Este componente intercepta las excepciones generadas en la capa de transporte web de Spring Boot y las reconvierte en respuestas estructuradas **ErrorResource** bajo los siguientes criterios:

- **MethodArgumentNotValidException**: Ocurre cuando un cuerpo de solicitud `@RequestBody` decorado con `@Valid` de Jakarta Bean Validation contiene campos que incumplen restricciones de integridad. El manejador itera sobre los errores de campo (`FieldError`), formatea cada discrepancia con la estructura `"campo: mensaje de restricción"` y genera un **ErrorResource** con código `VALIDATION_FAILED` y código HTTP 400 BAD REQUEST.
- **ConstraintViolationException**: Ocurre ante la transgresión de restricciones aplicadas directamente sobre parámetros de consulta (`@RequestParam`) o de ruta (`@PathVariable`). Se formatea la lista de violaciones y se emite un código `CONSTRAINT_VIOLATION` con HTTP 400 BAD REQUEST.
- **DomainException**: Intercepta excepciones no comprobadas arrojadas directamente por el núcleo del dominio cuando se violan invariantes no capturadas en aplicación. Preserva el código de error semántico de la excepción (`ex.errorCode()`) y emite una respuesta HTTP 422 UNPROCESSABLE_ENTITY.
- **HttpMessageNotReadableException**: Ocurre cuando el cuerpo de la petición HTTP está truncado, presenta sintaxis JSON corrupta o suministra tipos incompatibles con la carga útil esperada. Retorna el código `MALFORMED_JSON_REQUEST` y HTTP 400 BAD REQUEST.
- **HttpRequestMethodNotSupportedException** y **HttpMediaTypeNotSupportedException**: Gestionan peticiones enviadas con métodos HTTP no habilitados (retornando `METHOD_NOT_ALLOWED` con HTTP 405) o encabezados `Content-Type` incompatibles (retornando `UNSUPPORTED_MEDIA_TYPE` con HTTP 415).
- **Exception** (Manejador de Rescate Final): Actúa como mecanismo de contingencia para capturar anomalías no previstas o fallos críticos de infraestructura. El manejador recupera el identificador de correlación activo desde el contexto MDC, registra la traza completa de la excepción en los logs del servidor con severidad `ERROR` para observabilidad, y entrega al cliente un **ErrorResource** con código `INTERNAL_SERVER_ERROR` y mensaje neutro.

En la @tbl:shared-global-exception-handler se especifican los métodos manejadores y códigos HTTP asignados por este componente.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{4.4cm} | >{\centering\arraybackslash}p{3.8cm} | >{\centering\arraybackslash}p{2.6cm} |}
\caption{Métodos de Intercepción del Controlador Global de Excepciones} \label{tbl:shared-global-exception-handler} \\
\hline
\thfirst{Método Manejador} & \thcell{Excepción Interceptada} & \thcell{Código Emitido} & \thcell{Código HTTP} \\
\hline
\endfirsthead
\hline
\thfirst{Método Manejador} & \thcell{Excepción Interceptada} & \thcell{Código Emitido} & \thcell{Código HTTP} \\
\hline
\endhead
handleMethodArgumentNotValid & \texttt{\small MethodArgumentNotValidException} & \texttt{\small VALIDATION\_FAILED} & \texttt{\small 400 BAD REQUEST} \\*
\hline
\multicolumn{1}{|c|}{\textbf{Causal de Activación}} & \multicolumn{3}{p{10.8cm}|}{Fallas en restricciones Bean Validation (\texttt{@Valid}) en cuerpos DTO entrantes.} \\
\hline
handleConstraintViolation & \texttt{\small ConstraintViolationException} & \texttt{\small CONSTRAINT\_VIOLATION} & \texttt{\small 400 BAD REQUEST} \\*
\hline
\multicolumn{1}{|c|}{\textbf{Causal de Activación}} & \multicolumn{3}{p{10.8cm}|}{Violación de restricciones en parámetros de consulta (\texttt{@RequestParam}) o variables de ruta.} \\
\hline
handleDomainException & \texttt{\small DomainException} & \textit{Parametrizado (errorCode)} & \texttt{\small 422 UNPROCESSABLE} \\*
\hline
\multicolumn{1}{|c|}{\textbf{Causal de Activación}} & \multicolumn{3}{p{10.8cm}|}{Transgresión de invariantes de negocio no interceptadas en la capa de aplicación.} \\
\hline
handleHttpMessageNotReadable & \texttt{\small HttpMessageNotReadableException} & \texttt{\small MALFORMED\_JSON\_REQUEST} & \texttt{\small 400 BAD REQUEST} \\*
\hline
\multicolumn{1}{|c|}{\textbf{Causal de Activación}} & \multicolumn{3}{p{10.8cm}|}{Cuerpos de solicitud con sintaxis JSON corrupta o tipos de datos incompatibles.} \\
\hline
handleMethodNotSupported & \texttt{\small HttpRequestMethodNotSupportedException} & \texttt{\small METHOD\_NOT\_ALLOWED} & \texttt{\small 405 METHOD NOT ALLOWED} \\*
\hline
\multicolumn{1}{|c|}{\textbf{Causal de Activación}} & \multicolumn{3}{p{10.8cm}|}{Invocación de un endpoint mediante un verbo HTTP no habilitado.} \\
\hline
handleMediaTypeNotSupported & \texttt{\small HttpMediaTypeNotSupportedException} & \texttt{\small UNSUPPORTED\_MEDIA\_TYPE} & \texttt{\small 415 UNSUPPORTED MEDIA} \\*
\hline
\multicolumn{1}{|c|}{\textbf{Causal de Activación}} & \multicolumn{3}{p{10.8cm}|}{Peticiones que especifican un encabezado \texttt{Content-Type} no aceptado por la API.} \\
\hline
handleUnhandledException & \texttt{\small Exception} & \texttt{\small INTERNAL\_SERVER\_ERROR} & \texttt{\small 500 INTERNAL ERROR} \\*
\hline
\multicolumn{1}{|c|}{\textbf{Causal de Activación}} & \multicolumn{3}{p{10.8cm}|}{Fallos imprevistos de infraestructura. Registra en log con \texttt{correlationId} y oculta la traza de error.} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}

*Nota.* Componente anotado con RestControllerAdvice en el paquete com.andeva.atelier.platform.shared.interfaces.rest.

En términos de relaciones, **GlobalExceptionHandler** intercepta automáticamente cualquier fallo no contenido que se propague desde los controladores de cualquiera de los módulos de Atelier Platform, sirviendo como barrera unificadora de seguridad y gobernanza de la API.

**Filtros Perimetrales y Trazabilidad Distribuida**

La depuración y monitorización de aplicaciones empresariales resulta inviable si las peticiones concurrentes carecen de un mecanismo unificado de seguimiento. Cuando múltiples talleres, mecánicos y dispositivos telemáticos realizan transacciones simultáneas, asociar las líneas de registro en consola con la solicitud de origen exige un identificador que atraviese todas las capas de ejecución.

Para resolver esta necesidad, el Bounded Context Shared implementa el componente **CorrelationIdFilter**, estructurado como un filtro web que extiende de `OncePerRequestFilter` y decorado con `@Order(Ordered.HIGHEST_PRECEDENCE)` para asegurar su ejecución como el primer eslabón en la cadena de filtros perimetrales de Spring Web.

Su comportamiento operativo se resume en las siguientes fases:

- **Extracción o Generación de Identidad:** Al ingresar una petición HTTP, el filtro inspecciona la cabecera `X-Correlation-Id`. Si el cliente o una pasarela API externa suministró dicho valor, el filtro lo adopta. Si la cabecera está ausente o en blanco, genera un nuevo identificador unívoco universal mediante *UUID.randomUUID().toString()*.
- **Inyección en el Contexto de Diagnóstico (MDC):** El filtro asocia el identificador a la clave `correlationId` en el Mapped Diagnostic Context de SLF4J (`MDC.put("correlationId", correlationId)`). Esta vinculación garantiza que cualquier mensaje registrado posteriormente mediante el logger en cualquier capa del sistema incorpore automáticamente dicho identificador en su formato de salida.
- **Propagación en la Respuesta HTTP:** El filtro inyecta la cabecera `X-Correlation-Id` en el objeto `HttpServletResponse`, permitiendo al cliente receptor correlacionar cualquier consulta o reporte de error con los registros internos del servidor.
- **Garantía de Purga en Contextos Multihilo:** Dado que los servidores de aplicaciones Java reciclan los hilos de trabajo mediante grupos de subprocesos, el filtro ejecuta la cadena `filterChain.doFilter(request, response)` dentro de un bloque `try-finally`. En la cláusula `finally`, ejecuta obligatoriamente `MDC.remove("correlationId")`, erradicando el riesgo de contaminación cruzada de registros entre solicitudes independientes.

En la @tbl:shared-correlation-filter se exponen las constantes y métodos que definen este componente perimetral.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros del Filtro de Trazabilidad y Correlación Distribuida} \label{tbl:shared-correlation-filter} \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Propósito} \\
\hline
\endhead
\multicolumn{2}{|c|}{\textbf{Componente:} CorrelationIdFilter (Filtro Perimetral de Trazabilidad)} \\*
\hline
CORRELATION\_ID\_HEADER & Constante estática con el nombre oficial del encabezado HTTP (\texttt{X-Correlation-Id}). \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
CORRELATION\_ID\_MDC\_KEY & Clave identificadora para el contexto Mapped Diagnostic Context (\texttt{correlationId}). \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
doFilterInternal & Lógica de extracción, generación, inyección en MDC, asignación en respuesta y purga. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void (HttpServletRequest,\allowbreak  HttpServletResponse,\allowbreak  FilterChain)} \\*
\hline
\textbf{Ámbito de Acceso} & Protegido \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componente del paquete com.andeva.atelier.platform.shared.interfaces.rest.filters configurado con Ordered.HIGHEST_PRECEDENCE.

En cuanto a sus relaciones en el sistema, **CorrelationIdFilter** precede a los filtros de autenticación de seguridad perimetral, garantizando que incluso las peticiones rechazadas por credenciales no válidas o tokens expirados cuenten con un identificador de correlación persistido en los registros de auditoría del sistema.

#### 2.6.1.3. Application Layer

La capa de aplicación del Bounded Context Shared suministra los bloques de construcción funcionales, los modelos de error tipados, los contratos base para el patrón CQRS, las abstracciones de paginación agnósticas de frameworks y los puertos de publicación de eventos compartidos de forma transversal por los ocho bounded contexts de Atelier Platform.

Ubicada en el paquete canónico `com.andeva.atelier.platform.shared.application`, su concepción arquitectónica responde a cuatro directrices esenciales de Clean Architecture y diseño guiado por el dominio:

- **Railway-Oriented Programming:** Erradicación sistemática del uso de excepciones como mecanismo de control de flujo para anomalías previsibles de negocio (recursos no encontrados, colisiones de unicidad o validaciones insatisfechas). Toda operación susceptible de experimentar fallas retorna el tipo de resultado sellado **Result<T, E>**, garantizando que el compilador de Java 26 verifique la exhaustividad de los caminos de éxito (**Success**) y fallo (**Failure**) mediante coincidencia de patrones.
- **Taxonomía Semántica de Errores de Aplicación:** Desacoplamiento total del transporte web mediante el registro inmutable **ApplicationError**. Este componente estandariza los códigos alfanuméricos de falla, los mensajes explicativos y el desglose de campos observados, permitiendo que la Capa de Interfaz los asigne de forma determinista a respuestas HTTP bajo la norma RFC 7807 sin que la lógica de aplicación dependa de bibliotecas de presentación o frameworks web.
- **Estandarización de Contratos CQRS:** Definición de interfaces funcionales genéricas para manejadores de comandos transaccionales (**CommandHandler<C, R>**, **VoidCommandHandler<C>**), manejadores de consultas (**QueryHandler<Q, R>**) y manejadores de eventos en memoria (**DomainEventHandler<E>**), promoviendo una separación estricta entre operaciones de mutación de estado y consultas de solo lectura.
- **Paginación Desacoplada y Publicación de Eventos:** Modelado de solicitudes (**PagedQuery**) y respuestas paginadas (**PagedResult<T>**) completamente libres de dependencias de interfaces de persistencia de Spring Data, así como la delimitación del puerto **DomainEventPublisher** que canaliza los eventos acumulados en las raíces de agregado hacia el worker asíncrono del Transactional Outbox.

En la @tbl:shared-application-types se presenta el catálogo consolidado de los tipos que componen la Capa de Aplicación del Bounded Context Shared.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo Consolidado de la Capa de Aplicación del Bounded Context Shared} \label{tbl:shared-application-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endhead
Result<T, E> & Interfaz sellada que modela el resultado determinista de operaciones de negocio. \\*
\hline
\textbf{Categoría} & Tipo de Resultado \\*
\hline
\textbf{Relaciones} & Retorno universal de Command y Query Handlers. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak shared.\allowbreak application.\allowbreak result} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
ApplicationError & Estructura inmutable portadora de código semántico, mensaje y detalles. \\*
\hline
\textbf{Categoría} & Registro de Error \\*
\hline
\textbf{Relaciones} & Transportado en el camino Failure del tipo de resultado Result. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak shared.\allowbreak application.\allowbreak result} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
CommandHandler<C, R> & Interfaz funcional para casos de uso de mutación transaccional con retorno. \\*
\hline
\textbf{Categoría} & Contrato CQRS \\*
\hline
\textbf{Relaciones} & Implementada por servicios de comando en todos los módulos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak shared.\allowbreak application.\allowbreak handlers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
VoidCommandHandler<C> & Interfaz funcional para casos de uso mutacionales sin valor de retorno. \\*
\hline
\textbf{Categoría} & Contrato CQRS \\*
\hline
\textbf{Relaciones} & Implementada por comandos de acción mutacional simple. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak shared.\allowbreak application.\allowbreak handlers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
QueryHandler<Q, R> & Interfaz funcional para casos de uso de recuperación y lectura de datos. \\*
\hline
\textbf{Categoría} & Contrato CQRS \\*
\hline
\textbf{Relaciones} & Implementada por servicios de consulta en todos los módulos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak shared.\allowbreak application.\allowbreak handlers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
DomainEventHandler<E> & Interfaz funcional para consumidores en memoria de eventos de dominio. \\*
\hline
\textbf{Categoría} & Manejador de Eventos \\*
\hline
\textbf{Relaciones} & Suscrita a eventos emitidos tras el commit transaccional. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak shared.\allowbreak application.\allowbreak handlers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
SortDirection & Sentido de ordenamiento cronológico o alfabético (ASC, DESC). \\*
\hline
\textbf{Categoría} & Enumeración \\*
\hline
\textbf{Relaciones} & Utilizada por el registro de consulta PagedQuery. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak shared.\allowbreak application.\allowbreak pagination} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
PagedQuery & Solicitud inmutable de paginación agnóstica de frameworks ORM. \\*
\hline
\textbf{Categoría} & Modelo de Consulta \\*
\hline
\textbf{Relaciones} & Parámetro de entrada en consultas paginadas de la aplicación. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak shared.\allowbreak application.\allowbreak pagination} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
PagedResult<T> & Envoltorio inmutable de colecciones paginadas con metadatos de cálculo. \\*
\hline
\textbf{Categoría} & Contenedor de Datos \\*
\hline
\textbf{Relaciones} & Retorno de consultas de listado. mapeado a la Capa de Interfaz. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak shared.\allowbreak application.\allowbreak pagination} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
DomainEventPublisher & Contrato para la emisión de eventos hacia el Transactional Outbox. \\*
\hline
\textbf{Categoría} & Puerto de Aplicación \\*
\hline
\textbf{Relaciones} & Invocado por repositorios y servicios de aplicación. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak shared.\allowbreak application.\allowbreak events} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al paquete canónico com.andeva.atelier.platform.shared.application.

A continuación, se profundiza en la especificación a manera de diccionario de cada uno de los componentes que integran esta capa.

**Tipo de Resultado Funcional Result y Registro de Error ApplicationError**

En las arquitecturas empresariales basadas en el lanzamiento de excepciones para controlar el flujo de negocio, la ruptura de la localidad del código y la sobrecarga computacional asociada a la captura de la pila de llamadas degradan el rendimiento global del sistema y complican el diagnóstico de fallos. Para mitigar estos problemas, el Bounded Context Shared adopta el patrón de tipos de resultado funcionales:

- **Result<T, E>**: Interfaz sellada (`sealed interface Result<T, E> permits Result.Success, Result.Failure`) que formaliza una bifurcación disjunta entre dos subtipos inmutables:
   - **Success<T, E>(T value)**: Registro inmutable que almacena la carga útil generada por la operación. Su constructor compacto exige que `value` sea no nulo mediante `Objects.requireNonNull`, previniendo la propagación de referencias vacías.
   - **Failure<T, E>(E error)**: Registro inmutable que almacena la descripción tipada del fallo. Su constructor compacto impone que `error` sea estrictamente no nulo.
   
  La interfaz incorpora factorías estáticas (*success*, *failure* y el puente interoperable *fromOptional*), predicados lógicos booleanos (*isSuccess*, *isFailure*), conversiones seguras hacia el contenedor estándar (*toOptional*, *toErrorOptional*) y operaciones functoriales de orden superior:
   - *map*: Aplica una transformación sobre el valor exitoso, preservando el estado de error inalterado en caso de fallo.
   - *flatMap*: Encadena operaciones consecutivas que a su vez producen instancias de **Result**, evitando el anidamiento indeseado de tipos.
   - *mapError*: Transforma funcionalmente la estructura del objeto de error.
   - *onSuccess* y *onFailure*: Ejecutan acciones declarativas o efectos secundarios condicionados al camino de ejecución.
   - *orElse*, *orElseGet* y *orElseThrow*: Proveen desempaquetado controlado del valor o elevación explícita de excepciones cuando la interacción con frameworks externos así lo demande.

En la @tbl:shared-result-type se detallan exhaustivamente las operaciones, factorías y métodos del tipo de resultado funcional **Result<T, E>**.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros y Operaciones del Tipo de Resultado Funcional Result} \label{tbl:shared-result-type} \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Propósito} \\
\hline
\endhead
\multicolumn{2}{|c|}{\textbf{Componente:} Result<T, E> (Tipo de Resultado Funcional Sellado)} \\*
\hline
Success & Subtipo inmutable que encapsula el valor satisfactorio no nulo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{record Success<T,\allowbreak  E>(T value)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
Failure & Subtipo inmutable que encapsula la condición de error no nula. \\*
\hline
\textbf{Tipo o Firma} & \texttt{record Failure<T,\allowbreak  E>(E error)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
success & Factoría estática que instancia un resultado exitoso validando no nulidad. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Result<T,\allowbreak  E> success(T value)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
failure & Factoría estática que instancia un resultado fallido validando no nulidad. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Result<T,\allowbreak  E> failure(E error)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
fromOptional & Convierte un \texttt{Optional} a \texttt{Result}, asignando el error indicado si está vacío. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Result<T,\allowbreak  E> fromOptional(Optional<T>,\allowbreak  E)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
isSuccess & Predicado booleano que certifica si la ejecución fue satisfactoria (\texttt{instanceof Success}). \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean isSuccess()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
isFailure & Predicado booleano que certifica si la ejecución experimentó un fallo (\texttt{instanceof Failure}). \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean isFailure()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
toOptional & Proyecta el valor exitoso a un \texttt{Optional}, retornando \texttt{Optional.empty()} si es fallo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Optional<T> toOptional()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
toErrorOptional & Proyecta el error a un \texttt{Optional}, retornando \texttt{Optional.empty()} si es éxito. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Optional<E> toErrorOptional()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
map & Aplica la función transformadora sobre el valor en caso de éxito. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Result<R,\allowbreak  E> map(Function<? super T,\allowbreak  ? extends R>)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
flatMap & Encadena secuencialmente otra operación funcional sobre el valor exitoso. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Result<R,\allowbreak  E> flatMap(Function<? super T,\allowbreak  Result<R,\allowbreak  E>>)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
mapError & Transforma funcionalmente la estructura del objeto de error en caso de fallo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Result<T,\allowbreak  F> mapError(Function<? super E,\allowbreak  ? extends F>)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
onSuccess & Ejecuta un efecto secundario declarativo únicamente si el resultado es exitoso. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Result<T,\allowbreak  E> onSuccess(Consumer<? super T>)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
onFailure & Ejecuta un efecto secundario declarativo únicamente si el resultado es un fallo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Result<T,\allowbreak  E> onFailure(Consumer<? super E>)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
orElse & Retorna el valor contenido o el valor predeterminado si es fallo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{T orElse(T defaultValue)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
orElseGet & Retorna el valor contenido o invoca el proveedor suministrado si es fallo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{T orElseGet(Supplier<? extends T>)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
orElseThrow & Extrae el valor exitoso o arroja la excepción derivada del error. \\*
\hline
\textbf{Tipo o Firma} & \texttt{T orElseThrow(Function<? super E,\allowbreak  X>) throws X} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componente ubicado en el paquete com.andeva.atelier.platform.shared.application.result.

- **ApplicationError**: Registro inmutable que tipifica semánticamente las condiciones anómalas de la aplicación. Encapsula un código alfanumérico identificador (**code**), un mensaje inteligible para el usuario o diagnóstico (**message**) y una lista inmutable de detalles específicos de validación (**details**).

  En su constructor compacto impone validación estricta de no nulidad sobre el código y el mensaje, aplicando copias defensivas inmutables (`List.copyOf`) sobre los detalles para evitar modificaciones posteriores. Suministra un catálogo de métodos factoría semánticos que cubren la totalidad de transgresiones de negocio del ecosistema Atelier.

En la @tbl:shared-application-error se especifican los atributos y el catálogo completo de factorías semánticas de **ApplicationError**.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros y Factorías Semánticas del Registro ApplicationError} \label{tbl:shared-application-error} \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Propósito} \\
\hline
\endhead
\multicolumn{2}{|c|}{\textbf{Componente:} ApplicationError (Registro Inmutable de Errores de Aplicación)} \\*
\hline
code & Código alfanumérico estandarizado del error (no nulo). \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
message & Mensaje explicativo y contextual de la condición observada (no nulo). \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
details & Lista inmutable de observaciones o fallas específicas de validación de campo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{List<String>} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
Constructor Compacto & Garantiza no nulidad de código y mensaje, y genera copia inmutable de \texttt{details}. \\*
\hline
\textbf{Tipo o Firma} & \texttt{ApplicationError(...)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
notFound (con ID) & Genera error NOT\_FOUND con mensaje formateado de recurso e identificador. \\*
\hline
\textbf{Tipo o Firma} & \texttt{ApplicationError notFound(String,\allowbreak  Object)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
notFound (simple) & Genera error NOT\_FOUND con mensaje descriptivo directo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{ApplicationError notFound(String)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
conflict & Genera error CONFLICT ante colisiones de unicidad o conflictos de concurrencia. \\*
\hline
\textbf{Tipo o Firma} & \texttt{ApplicationError conflict(String)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
badRequest (simple) & Genera error BAD\_REQUEST ante argumentos inválidos o sintaxis incorrecta. \\*
\hline
\textbf{Tipo o Firma} & \texttt{ApplicationError badRequest(String)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
badRequest (con detalles) & Genera error BAD\_REQUEST asociando la lista de transgresiones por campo observadas. \\*
\hline
\textbf{Tipo o Firma} & \texttt{ApplicationError badRequest(String,\allowbreak  List<String>)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
unauthorized & Genera error UNAUTHORIZED ante fallas de autenticación o credenciales ausentes. \\*
\hline
\textbf{Tipo o Firma} & \texttt{ApplicationError unauthorized(String)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
forbidden & Genera error FORBIDDEN ante transgresiones de permisos o restricciones de rol (RBAC). \\*
\hline
\textbf{Tipo o Firma} & \texttt{ApplicationError forbidden(String)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
unprocessableEntity & Genera error UNPROCESSABLE\_ENTITY ante invariantes de negocio procesables insatisfechas. \\*
\hline
\textbf{Tipo o Firma} & \texttt{ApplicationError unprocessableEntity(String)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
internalError & Genera error INTERNAL\_ERROR ante contingencias inesperadas o fallas de infraestructura. \\*
\hline
\textbf{Tipo o Firma} & \texttt{ApplicationError internalError(String)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componente ubicado en el paquete com.andeva.atelier.platform.shared.application.result.

En cuanto a sus relaciones en el sistema, el tipo de resultado **Result** actúa como el tipo de retorno universal para la totalidad de servicios de aplicación y manejadores CQRS de los ocho bounded contexts. A su vez, es consumida en la Capa de Interfaz por **ResponseEntityAssembler**, cerrando el ciclo de vida de la petición de forma limpia y tipada.

**Contratos Base Transversales para CQRS**

Para asegurar que los casos de uso en todos los módulos de Atelier mantengan una estructura predecible y homogénea, el Bounded Context Shared delimita las interfaces funcionales que modelan los manejadores de comandos, consultas y eventos:

- **CommandHandler<C, R>** y **VoidCommandHandler<C>**: Interfaces funcionales (`@FunctionalInterface`) que regulan los casos de uso de mutación de estado. El comando C representa una intención inmutable de cambio de estado transaccional. El manejador orquesta la recuperación del agregado, invoca sus métodos de negocio, persiste los cambios y despacha eventos, retornando un **Result<R, ApplicationError>** o **Result<Void, ApplicationError>** sin arrojar excepciones de control.
- **QueryHandler<Q, R>**: Interfaz funcional (`@FunctionalInterface`) que gobierna los casos de uso de solo lectura. El objeto de consulta Q transporta los criterios de filtrado y paginación requeridos, mientras que el manejador accede a vistas optimizadas o repositorios de lectura para proyectar la información directamente en DTOs de salida, retornando **Result<R, ApplicationError>**.
- **DomainEventHandler<E extends DomainEvent>**: Interfaz funcional (`@FunctionalInterface`) que tipifica a los suscriptores en memoria de eventos de dominio emitidos por raíces de agregado. Al delimitar el parámetro genérico `E` con la interfaz inmutable **DomainEvent**, asegura que cualquier manejador de eventos del ecosistema responda exclusivamente a sucesos legítimos del dominio tras confirmarse la transacción de persistencia.

En la @tbl:shared-cqrs-handlers se sintetizan las firmas y responsabilidades de estos contratos CQRS.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Contratos Base para Manejadores CQRS del Bounded Context Shared} \label{tbl:shared-cqrs-handlers} \\
\hline
\thfirst{Aspecto del Contrato} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Contrato} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endhead
\multicolumn{2}{|c|}{\textbf{Contrato CQRS:} CommandHandler<C, R>} \\*
\hline
\textbf{Tipo de Componente} & Interfaz Funcional \\*
\hline
\textbf{Método Principal} & \texttt{Result<R,\allowbreak  ApplicationError> handle(C command)} \\*
\hline
\textbf{Responsabilidad} & Coordina mutaciones transaccionales que producen un resultado o entidad. \\
\hline
\multicolumn{2}{|c|}{\textbf{Contrato CQRS:} VoidCommandHandler<C>} \\*
\hline
\textbf{Tipo de Componente} & Interfaz Funcional \\*
\hline
\textbf{Método Principal} & \texttt{Result<Void,\allowbreak  ApplicationError> handle(C command)} \\*
\hline
\textbf{Responsabilidad} & Coordina mutaciones transaccionales de acción simple sin carga útil de retorno. \\
\hline
\multicolumn{2}{|c|}{\textbf{Contrato CQRS:} QueryHandler<Q, R>} \\*
\hline
\textbf{Tipo de Componente} & Interfaz Funcional \\*
\hline
\textbf{Método Principal} & \texttt{Result<R,\allowbreak  ApplicationError> handle(Q query)} \\*
\hline
\textbf{Responsabilidad} & Ejecuta consultas de lectura optimizadas proyectando resultados en DTOs. \\
\hline
\multicolumn{2}{|c|}{\textbf{Contrato CQRS:} DomainEventHandler<E>} \\*
\hline
\textbf{Tipo de Componente} & Interfaz Funcional \\*
\hline
\textbf{Método Principal} & \texttt{void handle(E event)} \\*
\hline
\textbf{Responsabilidad} & Consume y procesa de forma desacoplada eventos de dominio en memoria. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al paquete com.andeva.atelier.platform.shared.application.handlers.

Respecto a sus relaciones, estas interfaces son implementadas por las clases de servicio de aplicación de todos los bounded contexts de Atelier, permitiendo una organización modular conforme al Principio de Responsabilidad Única.

**Modelos de Paginación de la Capa de Aplicación**

En arquitecturas desacopladas, emplear abstracciones de infraestructura como `Pageable` o `Page` de Spring Data en las firmas de los servicios de aplicación genera un acoplamiento indebido hacia el framework. Para erradicar esta dependencia física, el Bounded Context Shared introduce modelos propios e inmutables para la gestión de paginación:

- **SortDirection**: Enumeración que tipifica las direcciones de ordenación permitidas en consultas de catálogo: ASC (ascendente) y DESC (descendente).
- **PagedQuery**: Registro inmutable que estandariza los parámetros de solicitud de listados. Encapsula el índice de página solicitado (**page**, base cero), la dimensión máxima de elementos (**size**), el campo de ordenamiento (**sortBy**) y la dirección de clasificación (**sortDirection**).

  Su constructor compacto impone validaciones de frontera (*page* ≥ 0 y *size* > 0, arrojando `IllegalArgumentException` si se transgreden), asignando valores por defecto seguros (`page = 0`, `size = 20`, `sortBy = "id"`, `sortDirection = ASC`) en caso de omisión o cadenas vacías. Dispone de dos sobrecargas factoría: *of(page, size)* con ordenación por defecto y *of(page, size, sortBy, sortDirection)* parametrizable.

- **PagedResult<T>**: Contenedor inmutable de datos paginados emitido por los manejadores de consultas. Encapsula la lista inmutable de elementos (**content**), la página actual (**page**), el tamaño solicitado (**size**), la cardinalidad total de registros existentes (**totalElements**) y el total de páginas disponibles (**totalPages**).

  En su constructor compacto verifica la no nulidad del contenido y crea una copia inmutable defensiva (`List.copyOf(content)`), validando que ningún contador sea negativo. Provee el método factoría estático *of(List<T>, int, int, long)*, el cual computa de manera automática las páginas totales mediante redondeo hacia arriba:
  $$\text{calculatedTotalPages} = \begin{cases} \lceil \frac{\text{totalElements}}{\text{size}} \rceil & \text{si } \text{size} > 0 \\ 0 & \text{en caso contrario} \end{cases}$$
  Asimismo, suministra la función de orden superior `<R> PagedResult<R> map(Function<? super T, ? extends R> mapper)`, la cual permite a los servicios de aplicación proyectar entidades de dominio hacia DTOs de salida preservando los metadatos de paginación intactos.

En la @tbl:shared-pagination-models se detallan los miembros y reglas operativas de estos modelos de paginación.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de los Modelos de Paginación de la Capa de Aplicación} \label{tbl:shared-pagination-models} \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Propósito} \\
\hline
\endhead
\multicolumn{2}{|c|}{\textbf{Componente:} Modelos de Paginación (SortDirection, PagedQuery, PagedResult<T>)} \\*
\hline
ASC / DESC & Constantes que delimitan el sentido del ordenamiento en consultas. \\*
\hline
\textbf{Tipo o Firma} & \texttt{SortDirection} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
page (Query) & Índice de página solicitado. impone la invariante estricta (\textit{page} $\ge$ 0). \\*
\hline
\textbf{Tipo o Firma} & \texttt{int} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
size (Query) & Límite de elementos por página. impone la invariante estricta (\textit{size} > 0). \\*
\hline
\textbf{Tipo o Firma} & \texttt{int} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
sortBy & Nombre del atributo sobre el cual ordenar. asigna "id" por defecto. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
sortDirection & Dirección de ordenación asociada. asigna ASC por defecto. \\*
\hline
\textbf{Tipo o Firma} & \texttt{SortDirection} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
of (simple) & Factoría estática con valores por defecto para campo ("id") y dirección (ASC). \\*
\hline
\textbf{Tipo o Firma} & \texttt{PagedQuery of(int page,\allowbreak  int size)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
of (completa) & Factoría estática con parametrización total de ordenamiento. \\*
\hline
\textbf{Tipo o Firma} & \texttt{PagedQuery of(int,\allowbreak  int,\allowbreak  String,\allowbreak  SortDirection)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
content & Colección inmutable y copia defensiva de elementos de la página. \\*
\hline
\textbf{Tipo o Firma} & \texttt{List<T>} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
totalElements & Cantidad total de registros existentes en base de datos (\textit{totalElements} $\ge$ 0). \\*
\hline
\textbf{Tipo o Firma} & \texttt{long} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
totalPages & Número total de páginas calculadas mediante función techo matemática. \\*
\hline
\textbf{Tipo o Firma} & \texttt{int} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
of (PagedResult) & Factoría estática que computa automáticamente las páginas totales. \\*
\hline
\textbf{Tipo o Firma} & \texttt{PagedResult<T> of(List<T>,\allowbreak  int,\allowbreak  int,\allowbreak  long)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
map & Transforma funcionalmente los elementos preservando metadatos de paginación. \\*
\hline
\textbf{Tipo o Firma} & \texttt{PagedResult<R> map(Function<? super T,\allowbreak  ? extends R>)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al paquete com.andeva.atelier.platform.shared.application.pagination.

En cuanto a sus relaciones, **PagedQuery** es recibido por los manejadores de consultas de CRM (búsqueda de clientes y flotas), MRO (órdenes de trabajo por estado o mecánico), Inventario (repuestos con stock crítico) y Facturación (comprobantes por rango de fechas). A su vez, **PagedResult<T>** es devuelto por dichos manejadores y transformado directamente hacia **PagedResultResource<T>** en la Capa de Interfaz.

**Puerto de Publicación y Despacho de Eventos**

En Clean Architecture, la propagación de eventos fuera de las fronteras de un bounded context o hacia colas de mensajería asíncrona no debe realizarse directamente desde las entidades ni acoplarse a clases de infraestructura como `ApplicationEventPublisher` de Spring.

Para gobernar este proceso, la Capa de Aplicación del Bounded Context Shared delimita el puerto formal **DomainEventPublisher**. Esta interfaz suministra dos contratos esenciales:

- *publish(DomainEvent event)*: Emite un evento de dominio individual inmediatamente después de confirmarse una operación unitaria.
- *publishAll(Collection<Object> events)*: Extrae y emite en bloque todos los eventos acumulados en la colección en memoria de una raíz de agregado (`aggregate.domainEvents()`), coordinando su registro en la tabla transaccional del Outbox (`outbox_messages`) antes de purgar la cola mediante `aggregate.clearDomainEvents()`.

En la @tbl:shared-event-publisher se especifican los métodos de este puerto de aplicación.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Métodos del Puerto de Publicación de Eventos de Dominio} \label{tbl:shared-event-publisher} \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Propósito} \\
\hline
\endhead
\multicolumn{2}{|c|}{\textbf{Componente:} DomainEventPublisher (Puerto de Publicación de Eventos)} \\*
\hline
publish & Despacha un evento de dominio individual verificando su no nulidad. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void publish(DomainEvent event)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
publishAll & Despacha en lote la colección de eventos extraída de la raíz de agregado. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void publishAll(Collection<Object> events)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componente ubicado en el paquete com.andeva.atelier.platform.shared.application.events.

En términos de relaciones, **DomainEventPublisher** es invocado por los manejadores de comandos de todos los bounded contexts y es implementado en la Capa de Infraestructura por adaptadores que persisten los eventos en PostgreSQL bajo el patrón Transactional Outbox, garantizando consistencia eventual y una semántica de entrega al menos una vez hacia sistemas externos.

#### 2.6.1.4. Infrastructure Layer

La capa de infraestructura del Bounded Context Shared suministra los mecanismos técnicos de persistencia relacional, la auditoría temporal automática, los convertidores de tipos para objetos de valor, la convención física de nombrado en base de datos, la infraestructura del patrón Transactional Outbox y la configuración centralizada de metadatos de documentación OpenAPI 3.0 que operan de forma transversal en los ocho bounded contexts de Atelier Platform.

Ubicada en el paquete canónico `com.andeva.atelier.platform.shared.infrastructure`, su diseño arquitectónico materializa los siguientes principios de Clean Architecture y resiliencia de software empresarial:

- **Desacoplamiento Estricto de Persistencia y Principio de Inversión de Dependencias (DIP):** Las entidades y agregados del modelo de dominio carecen deliberadamente de anotaciones relacionales de Jakarta Persistence (`@Entity`, `@Table`, `@Column`). La responsabilidad del mapeo objeto-relacional (ORM) se confina a entidades de persistencia dedicadas (**PersistenceEntity**), las cuales heredan un identificador técnico universal UUID y marcas temporales automáticas de auditoría mediante la superclase **AuditableAbstractPersistenceEntity**.
- **Normalización Relacional de Objetos de Valor:** Los objetos de valor inmutables del dominio se transforman de manera transparente a tipos escalares nativos en PostgreSQL 16 (NUMERIC(12, 2), INTEGER, VARCHAR) mediante convertidores JPA especializados (`@Converter`), asegurando que la persistencia física preserve la integridad semántica sin corromper las invariantes de encapsulamiento del dominio.
- **Estandarización Física del Esquema de Base de Datos:** La estrategia personalizada **SnakeCaseWithPluralizedTablePhysicalNamingStrategy** estandariza el esquema relacional en PostgreSQL, transformando los nombres de clases PascalCase a tablas físicas en minúsculas, separadas por guiones bajos y pluralizadas canónicamente en idioma inglés tras suprimir los sufijos técnicos de persistencia.
- **Confiabilidad Transaccional y Consistencia Eventual (Transactional Outbox):** Para sortear el problema de la escritura dual y evitar inconsistencias ante caídas del sistema o particiones de red, la emisión de eventos de dominio hacia brokers asíncronos se delega en el componente **JpaDomainEventPublisher**. Este adaptador serializa los eventos a formato JSON e inserta atómicamente el registro en la tabla **outbox_messages** dentro del mismo límite transaccional de base de datos, garantizando una semántica de entrega al menos una vez.
- **Estandarización Contractual de la API:** La clase **OpenApiConfiguration** centraliza la definición de metadatos OpenAPI 3.0 y el esquema de seguridad perimetral basado en tokens JWT (RFC 7519), asegurando una documentación homogénea e interactiva para los clientes web y móviles del sistema.

En la @tbl:shared-infrastructure-types se presenta el catálogo consolidado de los tipos que componen la Capa de Infraestructura del Bounded Context Shared.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo Consolidado de la Capa de Infraestructura del Bounded Context Shared} \label{tbl:shared-infrastructure-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endhead
AuditableAbstractPersistenceEntity & Base abstracta con clave primaria UUID y marcas temporales de auditoría automáticas. \\*
\hline
\textbf{Categoría} & Superclase JPA \\*
\hline
\textbf{Relaciones} & Heredada por todas las entidades \textbf{PersistenceEntity} del sistema. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak shared.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
MoneyAttributeConverter & Mapeo bidireccional seguro entre \textbf{Money} y NUMERIC(12, 2). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Aplica sobre columnas de importe en cotizaciones, órdenes y facturas. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak shared.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
MileageAttributeConverter & Mapeo bidireccional entre \textbf{Mileage} y columna escalar INTEGER. \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Aplica sobre odómetros en vehículos, recepciones y telemetría. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak shared.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
TaxIdAttributeConverter & Mapeo bidireccional nulo-seguro entre \textbf{TaxId} y columna VARCHAR(11). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Aplica sobre identificadores fiscales (RUC, DNI) en clientes y talleres. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak shared.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
EmailAddressAttributeConverter & Mapeo bidireccional normalizado entre \textbf{EmailAddress} y VARCHAR(254). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Aplica sobre direcciones de correo en perfiles de usuario y contacto. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak shared.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
PhoneNumberAttributeConverter & Mapeo bidireccional entre \textbf{PhoneNumber} y columna VARCHAR(15). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Aplica sobre números telefónicos estandarizados bajo la norma E.164. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak shared.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
SnakeCaseWithPluralizedTablePhysicalNamingStrategy & Convención Hibernate de nombrado de tablas pluralizadas en snake\_case. \\*
\hline
\textbf{Categoría} & Estrategia Física \\*
\hline
\textbf{Relaciones} & Integrada en la configuración de EntityManagerFactory de Spring Boot. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak shared.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak configuration.\allowbreak strategy} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
OutboxStatus & Ciclo de vida transaccional del mensaje outbox (PENDING, PUBLISHED, FAILED). \\*
\hline
\textbf{Categoría} & Enumeración \\*
\hline
\textbf{Relaciones} & Atributo de estado en \textbf{OutboxMessagePersistenceEntity}. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak shared.\allowbreak infrastructure.\allowbreak outbox.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
OutboxMessagePersistenceEntity & Entidad relacional mapeada a la tabla transaccional \textbf{outbox\_messages}. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Persistida en PostgreSQL por \textbf{JpaDomainEventPublisher}. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak shared.\allowbreak infrastructure.\allowbreak outbox.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
OutboxMessageJpaRepository & Interfaz de persistencia y sondeo ordenado de mensajes outbox pendientes. \\*
\hline
\textbf{Categoría} & Repositorio Spring Data \\*
\hline
\textbf{Relaciones} & Invocada por el worker asíncrono de reintento y despacho a colas. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak shared.\allowbreak infrastructure.\allowbreak outbox.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
JpaDomainEventPublisher & Implementación del puerto \textbf{DomainEventPublisher} mediante inserción outbox. \\*
\hline
\textbf{Categoría} & Adaptador de Salida \\*
\hline
\textbf{Relaciones} & Implementa el puerto de aplicación. interactúa con PostgreSQL y Spring. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak shared.\allowbreak infrastructure.\allowbreak outbox.\allowbreak publisher} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
OpenApiConfiguration & Definición de metadatos globales OpenAPI 3.0 y esquemas de seguridad Bearer JWT. \\*
\hline
\textbf{Categoría} & Configuración \\*
\hline
\textbf{Relaciones} & Utilizada por Swagger UI y herramientas de generación de contratos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak shared.\allowbreak infrastructure.\allowbreak documentation.\allowbreak openapi.\allowbreak configuration} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al paquete canónico com.andeva.atelier.platform.shared.infrastructure.

A continuación, se detalla la especificación formal a manera de diccionario de cada uno de los componentes de esta capa.

**Superclase Base de Persistencia y Auditoría JPA**

En arquitecturas guiadas por el dominio, acoplar las clases del dominio a anotaciones de un framework de mapeo relacional genera fugas de abstracción y complejiza las pruebas unitarias. Por este motivo, el modelo relacional de Atelier confina las dependencias de Jakarta Persistence a entidades dedicadas, las cuales extienden la superclase **AuditableAbstractPersistenceEntity**.

Esta clase está anotada con `@MappedSuperclass` y registrada ante el interceptor `@EntityListeners(AuditingEntityListener.class)` de Spring Data JPA. Gestiona una clave primaria técnica de tipo UUID generada automáticamente mediante `@GeneratedValue(strategy = GenerationType.UUID)` y mapeada a una columna nativa inmodificable.

Asimismo, captura de forma transparente las marcas temporales de auditoría mediante las anotaciones `@CreatedDate` y `@LastModifiedDate`, asignando valores de tipo Instant en UTC en el momento de inserción y en cada actualización transaccional. Además, sobrescribe los métodos *equals()* y *hashCode()* fundamentándose en el identificador persistido para garantizar consistencia semántica en colecciones gestionadas por el contexto de persistencia de Hibernate.

En la @tbl:shared-auditable-entity se detallan los miembros y directrices de diseño de esta superclase.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de la Superclase Base de Persistencia y Auditoría JPA} \label{tbl:shared-auditable-entity} \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Propósito} \\
\hline
\endhead
\multicolumn{2}{|c|}{\textbf{Componente:} AuditableAbstractPersistenceEntity (Superclase JPA de Persistencia)} \\*
\hline
id & Clave primaria técnica \texttt{@Id}. columna uuid inmodificable y no nula. \\*
\hline
\textbf{Tipo o Firma} & \texttt{UUID} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
createdAt & Marca temporal de creación \texttt{@CreatedDate}. columna inmodificable y no nula. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Instant} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
updatedAt & Marca temporal de última modificación \texttt{@LastModifiedDate}. columna no nula. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Instant} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
getId / setId & Métodos de acceso y asignación requeridos por la especificación JPA. \\*
\hline
\textbf{Tipo o Firma} & \texttt{UUID getId()`,\allowbreak  `void setId(UUID)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
getCreatedAt / setCreatedAt & Métodos de acceso para la marca temporal auditada de inserción. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Instant getCreatedAt()`,\allowbreak  `void setCreatedAt(Instant)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
getUpdatedAt / setUpdatedAt & Métodos de acceso para la marca temporal auditada de actualización. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Instant getUpdatedAt()`,\allowbreak  `void setUpdatedAt(Instant)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
equals & Evalúa igualdad basada exclusivamente en el identificador técnico no nulo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean equals(Object o)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Propósito} \\*
\hline
hashCode & Retorna código hash consistente basado en la clase de persistencia. \\*
\hline
\textbf{Tipo o Firma} & \texttt{int hashCode()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componente ubicado en el paquete com.andeva.atelier.platform.shared.infrastructure.persistence.jpa.entities.

En términos de relaciones arquitectónicas, **AuditableAbstractPersistenceEntity** es extendida exclusivamente por las clases de entidad de persistencia de los diferentes bounded contexts del sistema. Los agregados del dominio jamás heredan de ella.

**Catálogo de Convertidores JPA de Atributos para Objetos de Valor**

Para preservar la pureza del dominio y la seguridad de tipos, los atributos de negocio modelados como objetos de valor inmutables no deben aplanarse manualmente en cada operación de persistencia. El Bounded Context Shared implementa el patrón de conversión de atributos de JPA mediante clases anotadas con `@Converter`, las cuales efectúan transformaciones bidireccionales y nulo-seguras entre el modelo de objetos y las columnas relacionales de PostgreSQL 16:

- **MoneyAttributeConverter**: Implementa `AttributeConverter<Money, BigDecimal>`. Transforma la magnitud monetaria inmutable hacia una columna NUMERIC(12, 2), extrayendo *attribute.amount()* y reconstituyendo la entidad mediante *Money.of(dbData, Currency.PEN)*.
- **MileageAttributeConverter**: Implementa `AttributeConverter<Mileage, Integer>`. Mapea el odómetro automotriz a una columna INTEGER, preservando la regla de no negatividad al instanciar *new Mileage(dbData)*.
- **TaxIdAttributeConverter**: Implementa `AttributeConverter<TaxId, String>`. Mapea documentos de identidad tributaria a VARCHAR(11), deduciendo el tipo **TaxIdType** en función de la longitud del dato almacenado (11 dígitos para RUC y 8 para DNI).
- **EmailAddressAttributeConverter**: Implementa `AttributeConverter<EmailAddress, String>`. Persiste direcciones electrónicas normalizadas en minúsculas en columnas VARCHAR(254).
- **PhoneNumberAttributeConverter**: Implementa `AttributeConverter<PhoneNumber, String>`. Almacena el número telefónico internacional en formato canónico E.164 en columnas VARCHAR(15).

En la @tbl:shared-jpa-converters se detallan los tipos mapeados y métodos de conversión de este catálogo.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Catálogo de Convertidores JPA para Objetos de Valor} \label{tbl:shared-jpa-converters} \\
\hline
\thfirst{Método de Conversión} & \thcell{Firma y Comportamiento} \\
\hline
\endfirsthead
\hline
\thfirst{Método de Conversión} & \thcell{Firma y Comportamiento} \\
\hline
\endhead
\multicolumn{2}{|c|}{\textbf{Convertidor JPA:} MoneyAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{Money} $\longleftrightarrow$ \texttt{BigDecimal (NUMERIC(12,\allowbreak 2))} \\*
\hline
\textbf{Hacia Base de Datos} & \texttt{attribute.amount()} (o null) \\*
\hline
\textbf{Hacia Entidad Dominio} & \texttt{Money.of(dbData, Currency.PEN)} \\
\hline
\multicolumn{2}{|c|}{\textbf{Convertidor JPA:} MileageAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{Mileage} $\longleftrightarrow$ \texttt{Integer (INTEGER)} \\*
\hline
\textbf{Hacia Base de Datos} & \texttt{attribute.value()} (o null) \\*
\hline
\textbf{Hacia Entidad Dominio} & \texttt{new Mileage(dbData)} \\
\hline
\multicolumn{2}{|c|}{\textbf{Convertidor JPA:} TaxIdAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{TaxId} $\longleftrightarrow$ \texttt{String (VARCHAR(11))} \\*
\hline
\textbf{Hacia Base de Datos} & \texttt{attribute.value()} (o null) \\*
\hline
\textbf{Hacia Entidad Dominio} & \texttt{new TaxId(deduceType(dbData), dbData)} \\
\hline
\multicolumn{2}{|c|}{\textbf{Convertidor JPA:} EmailAddressAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{EmailAddress} $\longleftrightarrow$ \texttt{String (VARCHAR(254))} \\*
\hline
\textbf{Hacia Base de Datos} & \texttt{attribute.value()} (o null) \\*
\hline
\textbf{Hacia Entidad Dominio} & \texttt{new EmailAddress(dbData)} \\
\hline
\multicolumn{2}{|c|}{\textbf{Convertidor JPA:} PhoneNumberAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{PhoneNumber} $\longleftrightarrow$ \texttt{String (VARCHAR(15))} \\*
\hline
\textbf{Hacia Base de Datos} & \texttt{attribute.value()} (o null) \\*
\hline
\textbf{Hacia Entidad Dominio} & \texttt{new PhoneNumber(dbData)} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al paquete com.andeva.atelier.platform.shared.infrastructure.persistence.jpa.converters.

Respecto a sus relaciones, estos convertidores son referenciados explícitamente mediante la anotación `@Convert(converter = ...)` en los campos correspondientes de las entidades de persistencia en todos los módulos de Atelier, eliminando la necesidad de tablas secundarias para tipos de dato escalares.

**Estrategia Física de Nombrado de Tablas y Columnas**

La denominación de artefactos en bases de datos relacionales debe mantener una convención uniforme que facilite el mantenimiento y la interoperabilidad con herramientas de migración (Flyway). Para automatizar esta correspondencia, el Bounded Context Shared define la clase **SnakeCaseWithPluralizedTablePhysicalNamingStrategy**.

Esta clase hereda de **CamelCaseToUnderscoresNamingStrategy** de Hibernate 6.x y sobrescribe dos métodos fundamentales:

- *toPhysicalTableName()*: Intercepta el nombre lógico de la entidad, suprime los sufijos técnicos de persistencia (**PersistenceEntity** o **Entity**), aplica un algoritmo determinista de pluralización sintáctica en idioma inglés (transformando terminaciones como consonante más `y` en `ies`, silbantes `s`, `sh`, `ch`, `x`, `z` en `es`, y agregando `s` en casos generales), y finalmente convierte la cadena resultante a notación snake_case en minúsculas.
- *toPhysicalColumnName()*: Transforma propiedades de la entidad expresadas en notación camelCase hacia columnas relacionales en notación snake_case en minúsculas.

En la @tbl:shared-naming-strategy se sintetizan las responsabilidades y métodos de esta estrategia.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Métodos de la Estrategia Física de Nombrado Relacional} \label{tbl:shared-naming-strategy} \\
\hline
\thfirst{Elemento} & \thcell{Regla de Transformación Físico-Relacional} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Regla de Transformación Físico-Relacional} \\
\hline
\endhead
\multicolumn{2}{|c|}{\textbf{Componente:} PhysicalNamingStrategyImpl (Estrategia Física de Nombrado)} \\*
\hline
toPhysicalTableName & Elimina sufijos técnicos, pluraliza en inglés y convierte a snake\_case minúsculas. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Identifier toPhysicalTableName(Identifier,\allowbreak  JdbcEnv)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Regla de Transformación Físico-Relacional} \\*
\hline
toPhysicalColumnName & Transforma nombres de campos camelCase en columnas snake\_case minúsculas. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Identifier toPhysicalColumnName(Identifier,\allowbreak  JdbcEnv)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Regla de Transformación Físico-Relacional} \\*
\hline
pluralize & Aplica reglas gramaticales estándar de sufijación plural en inglés. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String pluralize(String input)} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componente ubicado en com.andeva.atelier.platform.shared.infrastructure.persistence.jpa.configuration.strategy.

En términos de integración, esta estrategia se registra en el archivo de configuración `application.yml` bajo la propiedad `spring.jpa.hibernate.naming.physical-strategy`, gobernando de manera transversal la generación física del esquema en PostgreSQL.

**Infraestructura del Patrón Transactional Outbox**

La comunicación asíncrona confiable entre bounded contexts o hacia sistemas externos exige evitar la escritura dual desincronizada, en la cual un fallo de red posterior al commit transaccional impide publicar el evento correspondiente. Para resolver esta contingencia, el Bounded Context Shared implementa el patrón Transactional Outbox mediante cuatro componentes especializados:

- **OutboxStatus**: Enumeración que tipifica el ciclo de vida del mensaje outbox en tres estados disjuntos: PENDING (mensaje registrado atómicamente y listo para despacho), PUBLISHED (mensaje despachado y confirmado satisfactoriamente hacia el broker) y FAILED (mensaje que agotó sus intentos de reintento por fallo persistente).
- **OutboxMessagePersistenceEntity**: Entidad relacional mapeada a la tabla **outbox_messages**. Incorpora un índice compuesto **idx_outbox_status_occurred_on** sobre las columnas **status** y **occurred_on** para optimizar las consultas de sondeo. Almacena el tipo de agregado (**aggregate_type**), el identificador del agregado (**aggregate_id**), el nombre semántico del evento (**event_type**), la carga útil serializada en una columna nativa JSONB de PostgreSQL (**payload**), la fecha de ocurrencia (**occurred_on**), el estado actual (**status**), el contador de reintentos (**retry_count**), el último mensaje de error (**last_error**) y la marca de tiempo de procesamiento (**processed_at**). Su factoría estática *pendingOf()* estandariza la instanciación en estado pendiente con cero reintentos.
- **OutboxMessageJpaRepository**: Repositorio Spring Data JPA que expone la consulta de sondeo derivada *findTop50ByStatusOrderByOccurredOnAsc(OutboxStatus status)*. Esta consulta recupera en bloques controlados los eventos pendientes en riguroso orden cronológico ascendente, minimizando el impacto de contención de bloqueos en la base de datos.
- **JpaDomainEventPublisher**: Adaptador de salida que implementa el puerto **DomainEventPublisher** de la Capa de Aplicación. Anotado con `@Transactional(propagation = Propagation.MANDATORY)`, exige que exista una transacción activa abierta por el caso de uso invocador. Serializa el evento a JSON mediante **ObjectMapper** de Jackson, inserta la entidad **OutboxMessagePersistenceEntity** en PostgreSQL y emite en paralelo el evento al contexto de Spring mediante **ApplicationEventPublisher** para notificar a los suscriptores en memoria tras el commit.

En la @tbl:shared-outbox-infrastructure se detallan los elementos de la infraestructura del Transactional Outbox.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Componentes y Métodos de la Infraestructura del Transactional Outbox} \label{tbl:shared-outbox-infrastructure} \\
\hline
\thfirst{Aspecto de Infraestructura} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Infraestructura} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endhead
\multicolumn{2}{|c|}{\textbf{Componente Outbox:} OutboxStatus} \\*
\hline
\textbf{Tipo de Elemento} & Enumeración \\*
\hline
\textbf{Firma o Definición} & \texttt{PENDING,\allowbreak  PUBLISHED,\allowbreak  FAILED} \\*
\hline
\textbf{Responsabilidad} & Modela las etapas de vida transaccional del mensaje outbox. \\
\hline
\multicolumn{2}{|c|}{\textbf{Componente Outbox:} OutboxMessagePersistenceEntity} \\*
\hline
\textbf{Tipo de Elemento} & Entidad JPA \\*
\hline
\textbf{Firma o Definición} & \texttt{Tabla outbox\_messages} \\*
\hline
\textbf{Responsabilidad} & Estructura inmutable relacional con carga útil JSONB y auditoría de reintentos. \\
\hline
\multicolumn{2}{|c|}{\textbf{Componente Outbox:} pendingOf} \\*
\hline
\textbf{Tipo de Elemento} & Factoría Estática \\*
\hline
\textbf{Firma o Definición} & \texttt{pendingOf(type,\allowbreak  id,\allowbreak  event,\allowbreak  payload,\allowbreak  date)} \\*
\hline
\textbf{Responsabilidad} & Construye un registro outbox en estado inicial PENDING con contador cero. \\
\hline
\multicolumn{2}{|c|}{\textbf{Componente Outbox:} findTop50ByStatusOrderByOccurredOnAsc} \\*
\hline
\textbf{Tipo de Elemento} & Consulta Derivada \\*
\hline
\textbf{Firma o Definición} & \texttt{List<OutboxMessagePersistenceEntity> (...)} \\*
\hline
\textbf{Responsabilidad} & Sondeo cronológico de los 50 mensajes pendientes prioritarios para despacho. \\
\hline
\multicolumn{2}{|c|}{\textbf{Componente Outbox:} publish} \\*
\hline
\textbf{Tipo de Elemento} & Método Adaptador \\*
\hline
\textbf{Firma o Definición} & \texttt{void publish(DomainEvent event)} \\*
\hline
\textbf{Responsabilidad} & Serializa el evento a JSON e inserta el registro outbox dentro de la transacción. \\
\hline
\multicolumn{2}{|c|}{\textbf{Componente Outbox:} publishAll} \\*
\hline
\textbf{Tipo de Elemento} & Método Adaptador \\*
\hline
\textbf{Firma o Definición} & \texttt{void publishAll(Collection<Object> events)} \\*
\hline
\textbf{Responsabilidad} & Itera y despacha la colección completa de eventos extraída de la raíz de agregado. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes ubicados en com.andeva.atelier.platform.shared.infrastructure.outbox.

Respecto a sus relaciones, este mecanismo desacopla la mutación local del agregado del transporte externo. Los manejadores de comandos invocan **JpaDomainEventPublisher**, el cual persiste el mensaje en PostgreSQL; posteriormente, un proceso worker desacoplado consulta **OutboxMessageJpaRepository** periódicamente para publicar los mensajes en el intermediario de mensajería asíncrona **RabbitMQ**, garantizando entrega confiable sin bloqueo transaccional.

**Configuración de Metadatos OpenAPI 3.0**

La estandarización de contratos de interfaz en un entorno modular multisede requiere la publicación de especificaciones precisas para los equipos de desarrollo frontend (Angular) y móvil (Flutter). La clase **OpenApiConfiguration** centraliza estos contratos mediante la biblioteca SpringDoc OpenAPI 2.8.

Configurada con la anotación `@Configuration`, declara el bean *customOpenAPI()* que suministra los metadatos generales de la solución, parametriza los servidores de ejecución, y define el esquema de seguridad global **bearerAuth**. Dicho esquema modela el transporte de credenciales mediante el encabezado HTTP Authorization con tokens JWT firmados digitalmente conforme al estándar RFC 7519, asegurando que las interfaces de exploración interactiva de Swagger UI apliquen autenticación transparente sobre los endpoints protegidos.

En la @tbl:shared-openapi-configuration se resumen los parámetros configurados por este componente.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Parámetros y Componentes de Configuración de OpenAPI 3.0} \label{tbl:shared-openapi-configuration} \\
\hline
\thfirst{Aspecto de Configuración} & \thcell{Especificación Técnica y Propósito} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Configuración} & \thcell{Especificación Técnica y Propósito} \\
\hline
\endhead
\multicolumn{2}{|c|}{\textbf{Elemento:} applicationName} \\*
\hline
\textbf{Parámetro o Esquema} & Inyección \texttt{@Value} \\*
\hline
\textbf{Valor o Definición} & \texttt{spring.application.name} \\*
\hline
\textbf{Propósito} & Título dinámico asignado a la documentación interactiva. \\
\hline
\multicolumn{2}{|c|}{\textbf{Elemento:} customOpenAPI} \\*
\hline
\textbf{Parámetro o Esquema} & Bean Spring \texttt{@Bean} \\*
\hline
\textbf{Valor o Definición} & \texttt{Retorna instancia OpenAPI} \\*
\hline
\textbf{Propósito} & Ensambla información, servidores y esquemas de seguridad global. \\
\hline
\multicolumn{2}{|c|}{\textbf{Elemento:} bearerAuth} \\*
\hline
\textbf{Parámetro o Esquema} & Esquema de Seguridad \\*
\hline
\textbf{Valor o Definición} & \texttt{HTTP Bearer (JWT RFC 7519)} \\*
\hline
\textbf{Propósito} & Exige inclusión de token de autorización en peticiones protegidas. \\
\hline
\multicolumn{2}{|c|}{\textbf{Elemento:} Servidores de Ejecución} \\*
\hline
\textbf{Parámetro o Esquema} & Lista de Server \\*
\hline
\textbf{Valor o Definición} & \texttt{/api/v1` y URL de Producción} \\*
\hline
\textbf{Propósito} & Enrutamiento perimetral para ejecución de pruebas interactivas. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componente ubicado en com.andeva.atelier.platform.shared.infrastructure.documentation.openapi.configuration.

En cuanto a sus relaciones en el sistema, **OpenApiConfiguration** opera transversalmente descubriendo y catalogando automáticamente los controladores REST definidos en los ocho bounded contexts de Atelier, sirviendo como contrato formal para la interoperabilidad del ecosistema cliente-servidor.

#### 2.6.1.5. Bounded Context Software Architecture Component Level Diagrams

En esta sección se presenta la descomposición arquitectónica interna del contenedor central **API Application** en relación con el Bounded Context Shared.

Dentro de la arquitectura de monolito modular de Atelier Platform, el Bounded Context Shared no opera como un subsistema periférico ni como un módulo funcional aislado, sino como la fundación arquitectónica e infraestructura transversal que dota de coherencia e interoperabilidad a los ocho bounded contexts de negocio: IAM & Tenancy, Customer & Fleet, Workshop Operations, Inventory & Supply Chain, Human Resources, Invoicing & Compliance, SaaS Billing e IoT Telemetry.

Todos los controladores REST, servicios de comando y consulta, agregados de dominio, entidades relacionales y adaptadores de integración del backend se sustentan en los componentes del Bounded Context Shared para gobernar el ciclo de vida de las solicitudes, persistir en PostgreSQL 16 y publicar eventos transaccionales confiables.

En la @tbl:shared-c4-components se presenta el catálogo estructurado de los siete componentes constitutivos del Bounded Context Shared dentro del contenedor central.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.5cm} | >{\raggedright\arraybackslash}p{10.9cm} |}
\caption{Catálogo de Componentes de Arquitectura de Software del Bounded Context Shared} \label{tbl:shared-c4-components} \\
\hline
\thfirst{Aspecto Técnico} & \thcell{Especificación de Arquitectura} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto Técnico} & \thcell{Especificación de Arquitectura} \\
\hline
\endhead
\multicolumn{2}{|c|}{\textbf{Componente C4:} Perimeter Tracing \& Exception Handling} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring Web, OncePerRequestFilter, SLF4J MDC, RFC 7807 \\*
\hline
\textbf{Responsabilidad} & Intercepta solicitudes HTTP inyectando \texttt{X-Correlation-Id}, enriquece el contexto diagnóstico MDC para logs distribuidos y captura fallas traduciéndolas a la norma RFC 7807. \\*
\hline
\textbf{Relaciones} & - Entrada perimetral desde WebApp y Mobile Workshop \newline - Envuelve controladores REST \newline - Propaga contexto a SLF4J MDC \\
\hline
\multicolumn{2}{|c|}{\textbf{Componente C4:} REST Assembler \& DTO Resource} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring MVC, Java 26 Records, Generics \\*
\hline
\textbf{Responsabilidad} & Transforma deterministamente el tipo de resultado \textbf{Result<T, ApplicationError>} a \texttt{ResponseEntity<?>}, asigna códigos HTTP semánticos y formatea sobres paginados \textbf{PagedResultResource<T>}. \\*
\hline
\textbf{Relaciones} & - Invocado por controladores REST de los 8 módulos \newline - Consume \textbf{Result<T, E>} y \textbf{ApplicationError} \\
\hline
\multicolumn{2}{|c|}{\textbf{Componente C4:} CQRS Framework \& Pagination} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Java 26 Functional Interfaces, Sealed Interfaces, Railway-Oriented Programming \\*
\hline
\textbf{Responsabilidad} & Suministra los contratos base para manejadores CQRS (\textbf{CommandHandler}, \textbf{QueryHandler}, \textbf{DomainEventHandler}) y los modelos de paginación (\textbf{PagedQuery}, \textbf{PagedResult<T>}). \\*
\hline
\textbf{Relaciones} & - Implementado por servicios de aplicación en todos los módulos \newline - Base estructural de casos de uso \\
\hline
\multicolumn{2}{|c|}{\textbf{Componente C4:} Domain Foundation \& Value Objects} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring Data Commons, Java Records, Haversine Engine, SUNAT Módulo 11 \\*
\hline
\textbf{Responsabilidad} & Provee la superclase base de agregados \textbf{AbstractDomainAggregateRoot<T>}, el contrato \textbf{DomainEvent}, identificadores UUID tipados, objetos de valor inmutables y \textbf{DomainException}. \\*
\hline
\textbf{Relaciones} & - Heredado por raíces de agregado de todos los módulos \newline - Núcleo del lenguaje ubicuo \\
\hline
\multicolumn{2}{|c|}{\textbf{Componente C4:} Persistence Superclass \& Converters} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Jakarta Persistence 3.1, Spring Data JPA Auditing, Hibernate 6.x \\*
\hline
\textbf{Responsabilidad} & Provee la superclase \textbf{AuditableAbstractPersistenceEntity} con auditoría automática y UUID técnico, convertidores JPA para Value Objects y estrategia física de nombrado. \\*
\hline
\textbf{Relaciones} & - Heredado por entidades \textbf{PersistenceEntity} \newline - Interactúa con PostgreSQL 16 \\
\hline
\multicolumn{2}{|c|}{\textbf{Componente C4:} Transactional Outbox Publisher} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring Data JPA, Jackson JSONB, Spring ApplicationEventPublisher, PostgreSQL 16 \\*
\hline
\textbf{Responsabilidad} & Implementa el puerto \textbf{DomainEventPublisher}, serializando eventos a JSON e insertándolos atómicamente en \textbf{outbox\_messages} dentro de la transacción activa con publicación local. \\*
\hline
\textbf{Relaciones} & - Invocado por Command Handlers \newline - Persiste en base de datos \newline - Alimenta contexto Spring \\
\hline
\multicolumn{2}{|c|}{\textbf{Componente C4:} OpenAPI Specification} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & SpringDoc OpenAPI 2.8, Swagger UI, RFC 7519 (JWT Bearer) \\*
\hline
\textbf{Responsabilidad} & Centraliza la definición de metadatos globales OpenAPI 3.0, servidores de ejecución y el esquema de seguridad \textbf{bearerAuth} con tokens JWT para la generación de contratos. \\*
\hline
\textbf{Relaciones} & - Descubre dinámicamente endpoints REST \newline - Consultado por desarrolladores y clientes \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al contenedor API Application en com.andeva.atelier.platform.shared.

En la @fig:c4-component-shared se ilustra el diagrama C4 de componentes para el Bounded Context Shared, detallando las interacciones entre los componentes transversales, los clientes perimetrales, los módulos de negocio de la aplicación y los servicios de infraestructura física.

![Diagrama de Componentes C4 (Nivel 3) para el Bounded Context Shared en API Application](report/assets/c4-diagrams/component-level-diagram-shared.png){#fig:c4-component-shared}

*Nota.* Elaboración propia en base a la arquitectura táctica del backend y el estándar C4 Model.

**Dinámica de Interacción y Flujos Operativos del Bounded Context Shared**

Para comprender la colaboración entre los componentes del Bounded Context Shared y los módulos de negocio durante el ciclo de vida de una operación, se analizan a continuación los tres flujos operacionales más representativos del sistema:

- **Ciclo de Vida de una Petición HTTP Entrante:**
  Cuando un cliente web o móvil transmite una petición HTTP, el componente **Perimeter Tracing & Exception Handling** intercepta la solicitud en **CorrelationIdFilter**. Si el encabezado `X-Correlation-Id` está ausente, genera un nuevo UUID versión 4, lo propaga en el contexto diagnóstico MDC de SLF4J y lo asigna preventivamente en la respuesta HTTP.

  La petición es canalizada a través de la cadena de filtros de Spring Security hacia el controlador REST del módulo correspondiente. El controlador instancia el comando y delega su procesamiento en un caso de uso que implementa el contrato provisto por el componente **CQRS Framework & Pagination**. A su vez, el manejador de comando orquesta la operación y retorna de forma determinista un tipo de resultado sellado **Result<?, ApplicationError>**.

  El controlador traslada el resultado a **ResponseEntityAssembler**. Si la operación fue satisfactoria (*Success*), se genera un estado HTTP 201 Created con la identidad creada. En caso de suscitarse un fallo previsible (*Failure*), se traduce el **ApplicationError** hacia un recurso **ErrorResource** estructurado bajo la norma RFC 7807. En caso de surgir una excepción de tiempo de ejecución no anticipada, el interceptor **GlobalExceptionHandler** la neutraliza, registrándola con su respectivo identificador de correlación y retornando un HTTP 500 Internal Server Error sin filtrar trazas internas del sistema.

- **Ciclo de Vida de Mutación de Dominio y Despacho Outbox:**
  Durante la ejecución de un caso de uso mutacional, el servicio de comando recupera la raíz de agregado que hereda de **AbstractDomainAggregateRoot<T>**. El agregado ejecuta su lógica de negocio interna, valida invariantes y registra el evento correspondiente mediante el método *registerDomainEvent(event)*, reteniéndolo en memoria.

  El repositorio mapea el agregado hacia su respectiva entidad relacional que extiende **AuditableAbstractPersistenceEntity**. Hibernate asigna de manera automática la marca temporal de auditoría **updatedAt** y los convertidores JPA normalizan los objetos de valor hacia columnas nativas de PostgreSQL.

  Antes de culminar la transacción local, el servicio de comando invoca *publishAll()* sobre el componente **Transactional Outbox Publisher**. Este adaptador, operando bajo transacción obligatoria (`Propagation.MANDATORY`), serializa cada evento a formato JSON mediante Jackson y lo persiste como un registro en estado PENDING en la tabla **outbox_messages**. De forma complementaria, despacha el evento al contexto de Spring (**ApplicationEventPublisher**) para suscriptores locales en memoria que escuchan tras el commit (`@TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)`).

  Al confirmarse el commit ACID en PostgreSQL, se garantizan de manera indivisible tanto el cambio de estado del agregado como el encolamiento del mensaje outbox. Inmediatamente después, el agregado purga su acumulador mediante *clearDomainEvents()*, y un proceso worker en segundo plano sondea periódicamente la tabla **outbox_messages** a través de **OutboxMessageJpaRepository** para despachar los eventos hacia colas de mensajería en **RabbitMQ** mediante el protocolo AMQP, logrando consistencia eventual sin riesgo de pérdidas ante fallos de red.

- **Ciclo de Consulta Paginada Desacoplada:**
  Ante solicitudes de listados masivos emitidas por el frontend, el controlador REST construye un registro inmutable **PagedQuery** con las invariantes validadas de índice de página (*page* ≥ 0), tamaño (*size* > 0), atributo de ordenación y sentido (**SortDirection**).

  El servicio de consulta implementa **QueryHandler<Q, PagedResult<DTO>>**, ejecutando la lectura optimizada en la base de datos y envolviendo el conjunto de resultados en el contenedor inmutable **PagedResult<T>**, el cual computa de forma matemática el número total de páginas mediante la función techo:
  $$\text{totalPages} = \left\lceil \frac{\text{totalElements}}{\text{size}} \right\rceil$$

  Finalmente, **ResponseEntityAssembler** proyecta dicho contenedor hacia el recurso **PagedResultResource<T>** en la Capa de Interfaz, suministrando metadatos homogéneos de navegación al cliente sin introducir dependencias físicas hacia clases de Spring Data (`Pageable` o `Page`) en las firmas de la capa de aplicación.

#### 2.6.1.6. Bounded Context Software Architecture Code Level Diagrams

En esta sección se desciende al nivel de mayor granularidad de la arquitectura de software del Bounded Context Shared, formalizando las especificaciones técnicas estáticas que orientan la codificación directa de la solución. A través de este nivel de detalle, se trasladan los conceptos del dominio táctico y los límites de componentes hacia construcciones formales de código y esquemas físicos de persistencia.

Esta perspectiva comprende dos dimensiones complementarias: el Diagrama de Clases de la Capa de Dominio, que rige los contratos inmutables en memoria y las reglas de negocio atómicas, y el Diagrama de Base de Datos, que formaliza el esquema relacional en PostgreSQL 16 para el patrón Transactional Outbox y las estructuras locales en SQLite 3 para la sincronización móvil.

##### 2.6.1.6.1. *Bounded Context Domain Layer Class Diagrams*

El modelado estático de la Capa de Dominio del Bounded Context Shared establece las estructuras fundacionales compartidas por los ocho bounded contexts de la plataforma Atelier. Su propósito primordial es erradicar el antipatrón de obsesión por primitivos, garantizar la inmutabilidad de los datos en memoria y consolidar la pureza arquitectónica de Clean Architecture, asegurando que las clases del núcleo de dominio permanezcan libres de anotaciones de frameworks externos o librerías de persistencia relacional.

En la @fig:class-diagram-shared se presenta el Diagrama de Clases UML detallado para la Capa de Dominio del Bounded Context Shared, modelado rigurosamente bajo el estándar UML empleando la herramienta PlantUML como Diagram-as-Code.

![Diagrama de Clases UML de la Capa de Dominio para el Bounded Context Shared](report/assets/class-diagrams/class-diagram-shared.png){#fig:class-diagram-shared}

*Nota.* Elaboración propia en base al diseño táctico de dominio y el estándar UML en PlantUML.

La estructura del diagrama se articula en cuatro paquetes lógicos cohesivos que delimitan con claridad las responsabilidades tácticas:

- **Agregados y Eventos de Dominio (`domain.model.aggregates`):** Provee la superclase abstracta de capa **AbstractDomainAggregateRoot<ID>**, la cual encapsula la identidad genérica y la recolección en memoria de instancias de **DomainEvent**. Este mecanismo desacopla la generación de eventos de negocio de su mecanismo de despacho transaccional en la infraestructura.
- **Identificadores Fuertemente Tipados (`domain.model.ids`):** Define la interfaz sellada **TypedId<T>** y sus realizaciones inmutables como registros de Java (**TenantId**, **UserId**, **WorkOrderId**, **VehicleId**, **CustomerId**). Esta abstracción previene que identificadores de distinta naturaleza semántica sean intercambiados accidentalmente en firmas de métodos o constructores.
- **Objetos de Valor Financieros, Métricos y Operativos (`domain.model.valueobjects`):** Modela estructuras inmutables para el manejo de moneda y montos con redondeo bancario (**Money**, **Currency**), cantidades y unidades de medida (**Quantity**, **UnitOfMeasure**), odómetro no decreciente (**Mileage**), posicionamiento geoespacial ortodrómico (**GeoPoint**), identificación fiscal ante la SUNAT (**TaxId**, **TaxIdType**), direcciones de correo electrónico bajo RFC 5322 (**EmailAddress**), telefonía internacional E.164 (**PhoneNumber**) e intervalos cronológicos de trabajo (**DateRange**).
- **Jerarquía de Excepciones de Dominio (`domain.exceptions`):** Centraliza la captura y tipificación de anomalías mediante la superclase no comprobada **DomainException** y sus especializaciones semánticas: **BusinessRuleValidationException**, **EntityNotFoundException** y **CurrencyMismatchException**.

En la @tbl:shared-domain-classes-members se detalla la especificación exhaustiva de cada clase, interfaz, registro inmutable y enumeración, explicitando sus atributos, firmas de métodos con tipos de retorno, ámbito de visibilidad y relaciones con cardinalidad asociada.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo exhaustivo de clases, miembros, ámbitos y relaciones de la Capa de Dominio del Bounded Context Shared} \label{tbl:shared-domain-classes-members} \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|c|}{\textbf{Clase o Estructura:} AbstractDomainAggregateRoot<ID>} \\*
\hline
Atributo id & Identificador único genérico del agregado. hereda el parámetro de tipo ID. \\*
\hline
\textbf{Firma o Tipo} & \texttt{ID} \\*
\hline
\textbf{Ámbito} & Protegido \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Atributo domainEvents & Acumulador interno en memoria para eventos de dominio generados. \\*
\hline
\textbf{Firma o Tipo} & \texttt{List<DomainEvent>} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Constructor & Inicializa el agregado asignando el identificador y una lista vacía de eventos. \\*
\hline
\textbf{Firma o Tipo} & \texttt{AbstractDomainAggregateRoot(id: ID)} \\*
\hline
\textbf{Ámbito} & Protegido \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Método id & Retorna el identificador fuertemente tipado de la raíz de agregado. \\*
\hline
\textbf{Firma o Tipo} & \texttt{ID} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Método domainEvents & Retorna una vista inmutable de los eventos de dominio acumulados. \\*
\hline
\textbf{Firma o Tipo} & \texttt{List<DomainEvent>} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Método registerDomainEvent & Registra un nuevo evento verificando no-nulidad. Composición 1 a 0..* con \textbf{DomainEvent}. \\*
\hline
\textbf{Firma o Tipo} & \texttt{void registerDomainEvent(DomainEvent event)} \\*
\hline
\textbf{Ámbito} & Protegido \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Método clearDomainEvents & Purga la colección de eventos tras su almacenamiento atómico en el Transactional Outbox. \\*
\hline
\textbf{Firma o Tipo} & \texttt{void clearDomainEvents()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Clase o Estructura:} DomainEvent} \\*
\hline
Método eventId & Identificador global único del evento para trazabilidad y deduplicación. \\*
\hline
\textbf{Firma o Tipo} & \texttt{UUID} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Método occurredOn & Marca temporal UTC en la que ocurrió el evento de dominio. \\*
\hline
\textbf{Firma o Tipo} & \texttt{Instant} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Método eventType & Clasificador semántico o nombre canónico calificado del evento. \\*
\hline
\textbf{Firma o Tipo} & \texttt{String} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Clase o Estructura:} TypedId<T>} \\*
\hline
Método value & Contrato genérico de interfaz para obtener el valor primitivo subyacente. \\*
\hline
\textbf{Firma o Tipo} & \texttt{T} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Clase o Estructura:} TenantId} \\*
\hline
Atributo value & Registro inmutable. realiza \texttt{TypedId<UUID>}. Identificador universal del taller. \\*
\hline
\textbf{Firma o Tipo} & \texttt{UUID} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos estáticos & Factorías estáticas de instanciación y generación criptográfica de identificador. \\*
\hline
\textbf{Firma o Tipo} & \texttt{TenantId of(UUID)`,\allowbreak  `fromString(String)`,\allowbreak  `generate()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Clase o Estructura:} UserId} \\*
\hline
Atributo value & Registro inmutable. realiza \texttt{TypedId<UUID>}. Identificador de usuario del sistema. \\*
\hline
\textbf{Firma o Tipo} & \texttt{UUID} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos estáticos & Factorías estáticas para vinculación de credenciales y miembros de taller. \\*
\hline
\textbf{Firma o Tipo} & \texttt{UserId of(UUID)`,\allowbreak  `fromString(String)`,\allowbreak  `generate()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Clase o Estructura:} WorkOrderId} \\*
\hline
Atributo value & Registro inmutable. realiza \texttt{TypedId<UUID>}. Identificador de orden de trabajo. \\*
\hline
\textbf{Firma o Tipo} & \texttt{UUID} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos estáticos & Factorías estáticas para órdenes de servicio mecánico y mantenimiento. \\*
\hline
\textbf{Firma o Tipo} & \texttt{WorkOrderId of(UUID)`,\allowbreak  `fromString(String)`,\allowbreak  `generate()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Clase o Estructura:} VehicleId} \\*
\hline
Atributo value & Registro inmutable. realiza \texttt{TypedId<UUID>}. Identificador de unidad vehicular. \\*
\hline
\textbf{Firma o Tipo} & \texttt{UUID} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos estáticos & Factorías estáticas para vehículos ingresados a custodia y diagnóstico. \\*
\hline
\textbf{Firma o Tipo} & \texttt{VehicleId of(UUID)`,\allowbreak  `fromString(String)`,\allowbreak  `generate()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Clase o Estructura:} CustomerId} \\*
\hline
Atributo value & Registro inmutable. realiza \texttt{TypedId<UUID>}. Identificador de cliente o propietario. \\*
\hline
\textbf{Firma o Tipo} & \texttt{UUID} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos estáticos & Factorías estáticas para personas naturales y empresas propietarias de vehículos. \\*
\hline
\textbf{Firma o Tipo} & \texttt{CustomerId of(UUID)`,\allowbreak  `fromString(String)`,\allowbreak  `generate()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Clase o Estructura:} Currency} \\*
\hline
Constantes & Enumeración de divisas. Soles peruanos y Dólares estadounidenses. \\*
\hline
\textbf{Firma o Tipo} & \texttt{PEN,\allowbreak  USD} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Clase o Estructura:} Money} \\*
\hline
Atributo amount & Cuantía monetaria normalizada a dos decimales con redondeo Half-Even. \\*
\hline
\textbf{Firma o Tipo} & \texttt{BigDecimal} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Atributo currency & Composición 1 a 1 con enumeración \textbf{Currency}. Divisa oficial del importe. \\*
\hline
\textbf{Firma o Tipo} & \texttt{Currency} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Constructor compacto & Invariante: valida no-nulidad y redondea a escala 2. Lanza \textbf{BusinessRuleValidationException}. \\*
\hline
\textbf{Firma o Tipo} & \texttt{Money(BigDecimal amount,\allowbreak  Currency currency)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Factorías & Métodos de construcción segura para monedas estándar. \\*
\hline
\textbf{Firma o Tipo} & \texttt{Money of(BigDecimal,\allowbreak  Currency)`,\allowbreak  `pen(...)`,\allowbreak  `usd(...)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos aritméticos & Opera importes inmutables. Lanza \textbf{CurrencyMismatchException} ante divisas heterogéneas. \\*
\hline
\textbf{Firma o Tipo} & \texttt{Money add(Money)`,\allowbreak  `subtract(Money)`,\allowbreak  `multiply(...)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos de estado & Predicados lógicos para validaciones de tarifas, saldos y presupuestos. \\*
\hline
\textbf{Firma o Tipo} & \texttt{boolean isPositive()`,\allowbreak  `boolean isZero()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Clase o Estructura:} UnitOfMeasure} \\*
\hline
Constantes & Enumeración de unidades físicas de almacenamiento y consumo de repuestos. \\*
\hline
\textbf{Firma o Tipo} & \texttt{UNIT,\allowbreak  LITER,\allowbreak  GALLON,\allowbreak  KILOGRAM,\allowbreak  METER} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Clase o Estructura:} Quantity} \\*
\hline
Atributo value & Cuantía cuantitativa física con escala configurable a 4 decimales. \\*
\hline
\textbf{Firma o Tipo} & \texttt{BigDecimal} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Atributo uom & Composición 1 a 1 con \textbf{UnitOfMeasure}. Unidad física de magnitud. \\*
\hline
\textbf{Firma o Tipo} & \texttt{UnitOfMeasure} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos operativos & Factorías y operaciones de suma/resta con validación de concordancia de unidad. \\*
\hline
\textbf{Firma o Tipo} & \texttt{Quantity of(...)`,\allowbreak  `units(...)`,\allowbreak  `add(...)`,\allowbreak  `subtract(...)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Clase o Estructura:} Mileage} \\*
\hline
Atributo kilometers & Registro inmutable. Odómetro expresado como valor escalar entero no negativo. \\*
\hline
\textbf{Firma o Tipo} & \texttt{int} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos & Invariante: rechaza valores negativos (\textit{km} $\ge$ 0). Calcula distancias entre lecturas. \\*
\hline
\textbf{Firma o Tipo} & \texttt{Mileage of(int)`,\allowbreak  `boolean isGreaterThan(...)`,\allowbreak  `int distanceTo(...)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Clase o Estructura:} GeoPoint} \\*
\hline
Atributos & Registro inmutable de coordenadas satelitales bajo datum WGS84. \\*
\hline
\textbf{Firma o Tipo} & \texttt{double latitude`,\allowbreak  `double longitude} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos & Invariante: latitud en [-90.0, 90.0], longitud en [-180.0, 180.0]. Computa distancia ortodrómica vía Haversine. \\*
\hline
\textbf{Firma o Tipo} & \texttt{GeoPoint of(...)`,\allowbreak  `double distanceTo(GeoPoint)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Clase o Estructura:} TaxIdType} \\*
\hline
Constantes & Enumeración legal de documentos de identidad tributaria ante la SUNAT. \\*
\hline
\textbf{Firma o Tipo} & \texttt{DNI,\allowbreak  RUC,\allowbreak  CE,\allowbreak  PASSPORT} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Clase o Estructura:} TaxId} \\*
\hline
Atributos & Composición 1 a 1 con \textbf{TaxIdType}. Número de documento tributario validado. \\*
\hline
\textbf{Firma o Tipo} & \texttt{TaxIdType type`,\allowbreak  `String value} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Factorías y métodos & Invariante: verifica longitud (8 para DNI, 11 para RUC) y suma ponderada de Módulo 11. \\*
\hline
\textbf{Firma o Tipo} & \texttt{TaxId dni(String)`,\allowbreak  `ruc(String)`,\allowbreak  `passport(String)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Clase o Estructura:} EmailAddress} \\*
\hline
Atributo value & Registro inmutable. Dirección de correo electrónico validada. \\*
\hline
\textbf{Firma o Tipo} & \texttt{String} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos & Invariante: valida estructura conforme a la especificación sintáctica RFC 5322. \\*
\hline
\textbf{Firma o Tipo} & \texttt{EmailAddress of(String)`,\allowbreak  `String value()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Clase o Estructura:} PhoneNumber} \\*
\hline
Atributo value & Registro inmutable. Número telefónico formateado en estándar internacional. \\*
\hline
\textbf{Firma o Tipo} & \texttt{String} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos & Invariante: valida prefijo internacional y longitud bajo norma ITU-T E.164. \\*
\hline
\textbf{Firma o Tipo} & \texttt{PhoneNumber of(String)`,\allowbreak  `String value()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Clase o Estructura:} DateRange} \\*
\hline
Atributos & Registro inmutable de intervalo temporal cerrado para turnos y contratos. \\*
\hline
\textbf{Firma o Tipo} & \texttt{LocalDate startDate`,\allowbreak  `LocalDate endDate} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos & Invariante: requiere \textit{startDate} $\le$ \textit{endDate}. Evalúa contención y traslape. \\*
\hline
\textbf{Firma o Tipo} & \texttt{DateRange of(...)`,\allowbreak  `boolean contains(...)`,\allowbreak  `overlaps(...)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Clase o Estructura:} DomainException} \\*
\hline
Atributo errorCode & Superclase abstracta de excepciones no comprobadas de dominio. \\*
\hline
\textbf{Firma o Tipo} & \texttt{String} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos & Constructor protegido para subclases e inspector del código de error semántico. \\*
\hline
\textbf{Firma o Tipo} & \texttt{DomainException(errorCode,\allowbreak  msg)`,\allowbreak  `String errorCode()} \\*
\hline
\textbf{Ámbito} & Protegido / Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Clase o Estructura:} BusinessRuleValidationException} \\*
\hline
Constructor & Generalización de \textbf{DomainException}. Lanza en violación de invariantes de dominio. \\*
\hline
\textbf{Firma o Tipo} & \texttt{BusinessRuleValidationException(errorCode,\allowbreak  msg)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Clase o Estructura:} EntityNotFoundException} \\*
\hline
Constructor & Generalización de \textbf{DomainException}. Lanza ante entidades inexistentes. \\*
\hline
\textbf{Firma o Tipo} & \texttt{EntityNotFoundException(entityName,\allowbreak  id)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|c|}{\textbf{Clase o Estructura:} CurrencyMismatchException} \\*
\hline
Constructor & Generalización de \textbf{DomainException}. Lanza ante incompatibilidad de divisas en \textbf{Money}. \\*
\hline
\textbf{Firma o Tipo} & \texttt{CurrencyMismatchException(sourceCur,\allowbreak  targetCur)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Elaboración propia en base al diseño táctico de dominio y la especificación UML de la solución.

A partir de la estructura plasmada en la @fig:class-diagram-shared y descrita en la @tbl:shared-domain-classes-members, se identifican tres fundamentos de ingeniería de software que sustentan la solidez del modelo de dominio:

- **Inmutabilidad Absoluta y Ausencia de Mutadores:** Al adoptar los Java Records para todos los objetos de valor y tipos de identidad, se elimina completamente la posibilidad de mutación no autorizada de estado. Cada instancia es inmutable por definición de compilador, garantizando seguridad en entornos concurrentes y simplificando el razonamiento sobre la consistencia de los datos.
- **Verificación Algorítmica Rigurosa en Tiempo de Instanciación:** Las validaciones críticas no se delegan a servicios externos ni a controladores perimetrales; residen en los constructores compactos de los objetos de valor. Destacan dos algoritmos fundamentales:
  - **Cálculo de Distancia Ortodrómica:** Para la evaluación de geocercas en la marcación de asistencia de mecánicos y la asignación de auxilio en ruta, el método *distanceTo()* calcula la distancia geodésica entre dos puntos sobre una esfera de radio medio terrestre *R* = 6,371,000 m mediante:
    $$d = 2 R \arcsin \left( \sqrt{\sin^2\left(\frac{\Delta\phi}{2}\right) + \cos(\phi_1)\cos(\phi_2)\sin^2\left(\frac{\Delta\lambda}{2}\right)} \right)$$
    donde $\phi_1, \phi_2$ corresponden a las latitudes y $\Delta\lambda$ a la diferencia de longitudes en radianes.
  - **Validación Ponderada de Identificación Tributaria (Módulo 11 en TaxId):** La validación de RUCs peruanos emitidos por la SUNAT comprueba que el identificador posea 11 dígitos, comience por los prefijos autorizados (10 para personas naturales, 20 para personas jurídicas, o 15/17) y que el último dígito coincida exactamente con el cálculo ponderado por los coeficientes [5, 4, 3, 2, 7, 6, 5, 4, 3, 2]. Cualquier infracción matemática desencadena inmediatamente una **BusinessRuleValidationException**, impidiendo que datos tributarios corruptos contaminen el ciclo de facturación electrónica.
- **Manejo Excepcional Semántico y Tipificado:** En lugar de emplear excepciones genéricas de Java, el dominio instituye una taxonomía de excepciones especializadas derivadas de **DomainException**. Cada excepción porta un código de error semántico estandarizado y legible por máquina, facilitando que la Capa de Interfaz traduzca estos incidentes a recursos RFC 7807 sin necesidad de inspeccionar cadenas de texto arbitrarias.

##### 2.6.1.6.2. *Bounded Context Database Design Diagram*

En esta sección se expone el diseño físico de persistencia y almacenamiento relacional del Bounded Context Shared, el cual rige las políticas de auditoría transversal, el aislamiento multi-inquilino y los mecanismos de consistencia eventual en el ecosistema Atelier.

Aunque el Bounded Context Shared no define tablas transaccionales de entidades directas de negocio, su modelo físico estandariza los objetos de base de datos que dan soporte a los dos productos de software donde se ejecuta la solución: la aplicación central de backend (**API Application**), implementada sobre PostgreSQL 16, y el cliente técnico móvil para talleres (**Mobile Workshop**), estructurado sobre una base de datos relacional local en SQLite 3.

En la @fig:database-diagram-shared se presenta el Diagrama Entidad-Relación formal bajo notación Crow's Foot, especificando las tablas físicas, columnas, tipos de datos, restricciones e índices de rendimiento para ambos motores de base de datos, junto con los canales de sincronización que interconectan la operación móvil con el núcleo transaccional.

![Diagrama Entidad-Relación de Base de Datos para el Bounded Context Shared (PostgreSQL 16 y SQLite 3)](report/assets/database-diagrams/database-diagram-shared.png){#fig:database-diagram-shared}

*Nota.* Elaboración propia en base al diseño físico de persistencia y el estándar PlantUML ERD.

A partir del modelo plasmado en el diagrama de persistencia, en la @tbl:shared-database-objects se sintetiza el catálogo formal de objetos de base de datos, detallando el producto donde se alojan, su propósito arquitectónico, columnas esenciales, restricciones de integridad e índices de rendimiento.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.5cm} | >{\raggedright\arraybackslash}p{10.9cm} |}
\caption{Objetos de persistencia física y estructuras relacionales del Bounded Context Shared} \label{tbl:shared-database-objects} \\
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endhead
\multicolumn{2}{|c|}{\textbf{Objeto de Persistencia:} \texttt{outbox\_messages}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API Application) \\*
\hline
\textbf{Propósito Arquitectónico} & Cola transaccional de eventos de dominio para garantizar entrega confiable y consistencia eventual con brokers externos. \\*
\hline
\textbf{Columnas Clave} & \texttt{id (UUID),\allowbreak  aggregate\_type,\allowbreak  aggregate\_id,\allowbreak  event\_type,\allowbreak  payload (JSONB),\allowbreak  status,\allowbreak  retry\_count,\allowbreak  occurred\_on} \\*
\hline
\textbf{Restricciones e Índices} & - \textbf{Clave Primaria:} \texttt{pk\_outbox\_messages} \newline - \textbf{Restricción CHECK:} \texttt{chk\_outbox\_status} \newline - \textbf{Índice Parcial (B-Tree):} \texttt{idx\_outbox\_status\_occurred\_on} \newline - \textbf{Índice (B-Tree):} \texttt{idx\_outbox\_aggregate} \\
\hline
\multicolumn{2}{|c|}{\textbf{Objeto de Persistencia:} \texttt{pending\_sync\_events}} \\*
\hline
\textbf{Motor y Producto} & SQLite 3 (Mobile Workshop) \\*
\hline
\textbf{Propósito Arquitectónico} & Cola local persistente de mutaciones generadas por mecánicos durante trabajos en condiciones desconectadas (Outbox móvil). \\*
\hline
\textbf{Columnas Clave} & \texttt{id (TEXT),\allowbreak  tenant\_id,\allowbreak  action\_type,\allowbreak  payload (TEXT/JSON),\allowbreak  status,\allowbreak  retry\_count,\allowbreak  created\_at,\allowbreak  synced\_at} \\*
\hline
\textbf{Restricciones e Índices} & - \textbf{Clave Primaria:} \texttt{pk\_pending\_sync\_events} \newline - \textbf{Restricción CHECK:} \texttt{chk\_sync\_status} \newline - \textbf{Índice (B-Tree):} \texttt{idx\_sync\_status\_created} para procesamiento FIFO \\
\hline
\multicolumn{2}{|c|}{\textbf{Objeto de Persistencia:} \texttt{local\_cache\_metadata}} \\*
\hline
\textbf{Motor y Producto} & SQLite 3 (Mobile Workshop) \\*
\hline
\textbf{Propósito Arquitectónico} & Control de marcas de agua e invalidación incremental de catálogos cacheados en el dispositivo. \\*
\hline
\textbf{Columnas Clave} & \texttt{entity\_type (TEXT),\allowbreak  last\_sync\_timestamp,\allowbreak  record\_count,\allowbreak  schema\_version} \\*
\hline
\textbf{Restricciones e Índices} & - \textbf{Clave Primaria:} \texttt{pk\_local\_cache\_metadata} \newline - \textbf{Validación Delta:} Soporta validación condicional de deltas mediante cabeceras HTTP ETag \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Resumen de esquemas de almacenamiento para el backend central (PostgreSQL 16) y la aplicación técnica móvil (SQLite 3).

A partir de la estructura formalizada en la @fig:database-diagram-shared y la @tbl:shared-database-objects, se identifican cuatro fundamentos de ingeniería de software que respaldan la resiliencia y escalabilidad de la arquitectura de datos:

- **Resolución del problema de la doble escritura mediante el patrón Transactional Outbox:**
  En sistemas empresariales distribuidos, la publicación sincrónica de eventos de dominio hacia el intermediario de mensajería **RabbitMQ** o APIs perimetrales dentro de la transacción de negocio induce fallas de consistencia ante caídas de red o cancelaciones repentinas.

  Al confinar los eventos de dominio a la tabla **outbox_messages** dentro de la transacción ACID local de PostgreSQL 16, la mutación de la entidad de negocio y el registro del evento se ejecutan de manera atómica. Un worker asíncrono desacoplado sondea esta tabla y asegura la entrega al menos una vez, reintentando de forma controlada ante cualquier indisponibilidad perimetral.

- **Indexación parcial de alto rendimiento para workers de sondeo en PostgreSQL 16:**
  Para evitar cuellos de botella en la lectura recurrente del worker de despacho conforme la tabla acumula registros históricos procesados, se implementa el índice parcial **idx_outbox_status_occurred_on** sobre las columnas **(status, occurred_on ASC)** con la condición restrictiva `WHERE status = 'PENDING'`.

  Esta técnica reduce de forma drástica el volumen del árbol B-Tree en memoria al ignorar millones de filas en estado PROCESSED, logrando consultas de sondeo en tiempos sub-milisegundos y eliminando cualquier degradación en la concurrencia de inserción.

- **Estandarización de aislamiento multi-inquilino y auditoría temporal:**
  Mediante el arquetipo de persistencia **auditable_abstract_entity**, el Bounded Context Shared impone de manera uniforme la columna discriminadora **tenant_id** en cada tabla transaccional del backend. Este mecanismo asegura que ninguna consulta SQL o regla ORM omita el particionamiento lógico, previniendo accesos indebidos entre talleres mecánicos concurrentes.

  Asimismo, la presencia de marcas temporales inmutables en UTC (TIMESTAMPTZ) y el campo de versión para control de concurrencia optimista protegen la consistencia transaccional ante modificaciones simultáneas efectuadas desde terminales web y móviles.

- **Resiliencia operativa desconectada y sincronización eventual en SQLite 3:**
  En entornos de taller automotriz con fosos subterráneos o estructuras metálicas que mitigan la señal celular, la aplicación **Mobile Workshop** no detiene su operativa. Cada acción técnica ejecutada por el personal se almacena inmediatamente en la tabla local **pending_sync_events** de SQLite con un UUID v4 autogenerado.

  Al restaurarse la conectividad inalámbrica, un servicio en segundo plano procesa la cola y despacha las mutaciones acumuladas mediante peticiones HTTPS REST en lote. El backend central valida de forma idempotente cada mutación para prevenir duplicaciones por reintentos de red, actualizando los registros correspondientes y convergiendo el estado del sistema hacia la base de datos central de manera completamente transparente para los mecánicos.

### 2.6.2. *Bounded Context: Identity and Access Management (IAM) & Tenancy*

El Bounded Context Identity and Access Management (IAM) & Tenancy constituye el pilar fundacional de seguridad, gobernanza multi-inquilino y administración de identidades en Atelier Platform. Su responsabilidad dentro del ecosistema radica en resolver tres necesidades operativas críticas:

- **Aislamiento multi-inquilino de primer nivel:** Modela la estructura empresarial de los talleres automotrices (**Tenant**) y sus sedes físicas (**Branch**), asegurando que cualquier operación o registro transaccional en el sistema esté particionado lógicamente por el identificador de inquilino (**TenantId**). Delimita el perímetro geográfico de los talleres mediante geocercas satelitales circulares calculadas con la formulación del Haversine para habilitar el control presencial del personal.

- **Identidad universal y autenticación federada:** Centraliza la administración de cuentas de usuario globales (**User**) y sus perfiles personales (**Profile**), admitiendo tanto credenciales locales aseguradas mediante la función criptográfica BCrypt como autenticación federada con Google OAuth2. Asimismo, gobierna el ciclo de vida de tokens de un solo uso (**VerificationToken**) para la confirmación de correos electrónicos y la recuperación segura de contraseñas.

- **Membresías laborales y control de acceso basado en roles:** Desacopla la cuenta de la persona de su relación con una empresa determinada a través de membresías (**TenantMembership**), regulando esquemas de retribución salarial, gestionando roles dinámicos (**Role**) vinculados a permisos atómicos (**Permission**) y coordinando la incorporación digital de colaboradores mediante invitaciones tokenizadas (**Invitation**).

#### 2.6.2.1. Domain Layer

La capa de dominio de IAM & Tenancy encapsula los modelos conceptuales, las invariantes transaccionales y las políticas de seguridad sin establecer dependencia alguna con frameworks tecnológicos o motores de persistencia relacional. Residiendo bajo el paquete canónico **com.andeva.atelier.platform.iam.domain**, su diseño táctico se estructura bajo cuatro fundamentos arquitectónicos:

- **Aislamiento estricto de infraestructura:** Las raíces de agregado extienden de **AbstractDomainAggregateRoot<T>** para la acumulación desacoplada de eventos de dominio en memoria, careciendo de anotaciones JPA, Hibernate o validadores dependientes de contenedor.

- **Segregación entre identidad global y vinculación laboral:** Una cuenta **User** representa a un individuo en la plataforma global, mientras que **TenantMembership** modela su contrato en un taller específico. Esta separación permite que un mecánico o asesor trabaje en distintos talleres sin duplicar credenciales ni mezclar accesos.

- **Modelo de autorización granular:** Control de acceso basado en roles con soporte para plantillas inmutables del sistema y roles personalizados a nivel de inquilino, compuestos por permisos atómicos expresados en convenciones canónicas de recurso y acción.

- **Inmutabilidad y seguridad de tipos:** Todo identificador y objeto de valor se implementa mediante registros inmutables de Java, asegurando que las reglas sintácticas y semánticas se validen defensivamente en los constructores compactos.

En la @tbl:iam-domain-types se presenta el catálogo unificado de componentes que conforman la capa de dominio de IAM & Tenancy.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo de la Capa de Dominio del Bounded Context IAM \& Tenancy} \label{tbl:iam-domain-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\
\hline
\endhead
Tenant & Raíz de consistencia del taller. administra RUC fiscal, razón social, sedes físicas y estado operativo. \\*
\hline
\textbf{Categoría} & Raíz de Agregado \\*
\hline
\textbf{Relaciones} & Generalización de AbstractDomainAggregateRoot<Tenant>. composición 1 a 1..* con Branch. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak model.\allowbreak aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Branch & Sede física de atención. administra código de anexo SUNAT, coordenadas WGS84 y geocerca circular. \\*
\hline
\textbf{Categoría} & Entidad Dependiente \\*
\hline
\textbf{Relaciones} & Dependiente subordinada a Tenant. compuesta por BranchId, TenantId y GeoPoint. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak model.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
User & Cuenta global de identidad y autenticación. gestiona credenciales seguras, proveedor federado y estado. \\*
\hline
\textbf{Categoría} & Raíz de Agregado \\*
\hline
\textbf{Relaciones} & Generalización de AbstractDomainAggregateRoot<User>. composición 1 a 1 con Profile y 1 a N con VerificationToken. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak model.\allowbreak aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Profile & Datos demográficos del usuario. administra nombres, teléfono normalizado E.164 y fotografía de perfil. \\*
\hline
\textbf{Categoría} & Entidad Dependiente \\*
\hline
\textbf{Relaciones} & Dependiente subordinada a User en relación 1 a 1. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak model.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
VerificationToken & Código OTP numérico o token alfanumérico para validación de correo y restablecimiento de claves con expiración temporal. \\*
\hline
\textbf{Categoría} & Entidad Dependiente \\*
\hline
\textbf{Relaciones} & Dependiente subordinada a User. almacena UserId y TokenType. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak model.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
TenantMembership & Contrato laboral operativo entre un usuario y un taller específico. administra roles de seguridad y esquema salarial. \\*
\hline
\textbf{Categoría} & Raíz de Agregado \\*
\hline
\textbf{Relaciones} & Generalización de AbstractDomainAggregateRoot<TenantMembership>. referencia a TenantId, UserId y Role. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak model.\allowbreak aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Role & Agrupador de privilegios de seguridad por taller o provisto globalmente por la plataforma como plantilla del sistema. \\*
\hline
\textbf{Categoría} & Raíz de Agregado \\*
\hline
\textbf{Relaciones} & Generalización de AbstractDomainAggregateRoot<Role>. agregación con entidades Permission. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak model.\allowbreak aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Permission & Privilegio atómico de autorización modelado como cadena canónica de autoridad por recurso y acción. \\*
\hline
\textbf{Categoría} & Entidad Dependiente \\*
\hline
\textbf{Relaciones} & Dependiente subordinada a Role. identificada por PermissionId. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak model.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Invitation & Control de incorporación y onboarding digital de colaboradores mediante correo transaccional y token uniuso. \\*
\hline
\textbf{Categoría} & Raíz de Agregado \\*
\hline
\textbf{Relaciones} & Generalización de AbstractDomainAggregateRoot<Invitation>. referencia a TenantId, EmailAddress y RoleId. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak model.\allowbreak aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
TenantMembershipId & Identificador único universal fuertemente tipado para el contrato de membresía laboral. \\*
\hline
\textbf{Categoría} & Objeto de Valor (ID) \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
RoleId & Identificador único universal fuertemente tipado para roles de seguridad en la plataforma. \\*
\hline
\textbf{Categoría} & Objeto de Valor (ID) \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PermissionId & Identificador único universal fuertemente tipado para permisos atómicos del catálogo de seguridad. \\*
\hline
\textbf{Categoría} & Objeto de Valor (ID) \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
InvitationId & Identificador único universal fuertemente tipado para invitaciones de onboarding de personal. \\*
\hline
\textbf{Categoría} & Objeto de Valor (ID) \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Password & Contenedor de contraseña cifrada que valida formato y entropía de hash BCrypt de 60 caracteres. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Utilizado por la raíz de agregado User para cuentas locales. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PersonName & Nombre y apellido estructurado de la persona con normalización léxica y supresión de espacios superfluos. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Utilizado por la entidad Profile. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
TenantStatus & Estados operativos del taller mecánico (PENDING, ACTIVE, SUSPENDED). \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada por la raíz de agregado Tenant. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
UserStatus & Estados del ciclo de vida de la cuenta de usuario (PENDING\_VERIFICATION, ACTIVE, SUSPENDED). \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada por la raíz de agregado User. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
MembershipStatus & Estados de vigencia contractual del trabajador en el taller (ACTIVE, INACTIVE). \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada por el agregado TenantMembership. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
SalaryType & Modalidad de retribución pactada para el personal operativo (FIXED, HOURLY). \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada por el agregado TenantMembership. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
TokenType & Tipología funcional de tokens de un solo uso (EMAIL\_VERIFICATION, PASSWORD\_RESET). \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada por la entidad VerificationToken. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
InvitationStatus & Estados del ciclo de vida de la invitación (PENDING, ACCEPTED, EXPIRED, REVOKED). \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada por el agregado Invitation. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
AuthProvider & Mecanismo de procedencia y autenticación de la cuenta (LOCAL, GOOGLE). \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada por la raíz de agregado User. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
TenantRegistrationDomainService & Orquesta la creación atómica de taller, sede matriz, usuario administrador, membresía y rol de propietario. \\*
\hline
\textbf{Categoría} & Servicio de Dominio \\*
\hline
\textbf{Relaciones} & Coordina Tenant, Branch, User, Profile, Role y TenantMembership. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PasswordEncryptionDomainService & Encapsula el algoritmo de derivación de claves BCrypt y la verificación de solidez de contraseñas. \\*
\hline
\textbf{Categoría} & Servicio de Dominio \\*
\hline
\textbf{Relaciones} & Empleado en registro y cambio de credenciales de User. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
TokenGeneratorDomainService & Algoritmo criptográfico seguro para la generación de OTPs decimales y tokens URL-safe de onboarding. \\*
\hline
\textbf{Categoría} & Servicio de Dominio \\*
\hline
\textbf{Relaciones} & Empleado por User, VerificationToken e Invitation. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
TenantRepository & Contrato de persistencia agnóstico para la raíz de agregado Tenant. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Implementado en la capa de infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
UserRepository & Contrato de persistencia agnóstico para la raíz de agregado User. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Implementado en la capa de infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
TenantMembershipRepository & Contrato de persistencia agnóstico para la raíz de agregado TenantMembership. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Implementado en la capa de infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
RoleRepository & Contrato de persistencia agnóstico para la raíz de agregado Role. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Implementado en la capa de infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
PermissionRepository & Contrato de persistencia y consulta para entidades Permission. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Implementado en la capa de infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
InvitationRepository & Contrato de persistencia agnóstico para la raíz de agregado Invitation. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Implementado en la capa de infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
VerificationTokenRepository & Contrato de persistencia y consumo para tokens de verificación y OTPs. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Implementado en la capa de infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
TenantRegisteredEvent & Notifica el alta exitosa de un nuevo taller mecánico en la plataforma. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
TenantActivatedEvent & Notifica la reactivación de un taller previamente suspendido. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
TenantSuspendedEvent & Notifica la suspensión administrativa de un taller por morosidad o infracción. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
BranchCreatedEvent & Notifica la apertura y delimitación perimetral de una nueva sucursal física. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
BranchUpdatedEvent & Notifica modificaciones en la denominación o coordenadas de la sede física. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
BranchDeactivatedEvent & Notifica el cese temporal o definitivo de operaciones en una sucursal física. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
UserRegisteredEvent & Notifica el registro inicial de una identidad de usuario en la plataforma. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
UserVerifiedEvent & Notifica la confirmación de la dirección de correo y activación de la cuenta. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
UserPasswordResetRequestedEvent & Notifica la solicitud de restablecimiento de contraseña para despacho de OTP. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
UserPasswordChangedEvent & Notifica la actualización satisfactoria de la credencial de acceso. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
UserSuspendedEvent & Notifica la inhabilitación global de una cuenta de usuario. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
TenantMembershipCreatedEvent & Notifica la vinculación contractual de un colaborador a la planilla de un taller. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
TenantMembershipDeactivatedEvent & Notifica el cese o desvinculación laboral de un colaborador en el taller. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
StaffInvitedEvent & Notifica la emisión de una invitación de personal para despacho por correo. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
StaffInvitationAcceptedEvent & Notifica la aceptación del colaborador y la consumación del onboarding. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
TenantNotFoundException & Señaliza la inexistencia de un taller para el identificador suministrado. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de DomainException. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
TenantAlreadyExistsException & Señaliza el intento de registrar un taller con un RUC fiscal duplicado. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de DomainException. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
TenantSuspendedException & Impide operaciones sobre un taller cuyo estado se encuentra inhabilitado. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de DomainException. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
UserNotFoundException & Señaliza la inexistencia de una cuenta de usuario durante la autenticación. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de DomainException. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
UserAlreadyExistsException & Señaliza la colisión de direcciones de correo en el registro global. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de DomainException. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
UserSuspendedException & Impide el inicio de sesión a usuarios con cuentas inhabilitadas. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de DomainException. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
InvalidCredentialsException & Señaliza el rechazo de credenciales por discrepancia de contraseña o proveedor. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de DomainException. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
MembershipNotFoundException & Señaliza la ausencia de vínculo laboral entre un usuario y un taller. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de DomainException. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
MembershipAlreadyExistsException & Impide la duplicación de contratos de trabajo entre un mismo usuario y taller. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de DomainException. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
RoleNotFoundException & Señaliza la inexistencia del rol asignado en el contexto del taller. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de DomainException. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
SystemRoleImmutableException & Impide la alteración o eliminación de roles semilla globales del sistema. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de DomainException. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
InvitationNotFoundException & Señaliza que el token de invitación no corresponde a ningún registro activo. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de DomainException. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
InvitationExpiredException & Señaliza que el plazo de vigencia temporal de la invitación ha caducado. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de DomainException. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
InvitationAlreadyAcceptedException & Impide el reuso de un token de invitación que ya fue canjeado previamente. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de DomainException. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak exceptions} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
InvalidVerificationTokenException & Señaliza que el código OTP provisto es erróneo, caduco o ya consumido. \\*
\hline
\textbf{Categoría} & Excepción de Dominio \\*
\hline
\textbf{Relaciones} & Especialización de DomainException. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak domain.\allowbreak exceptions} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes ubicados bajo el paquete com.andeva.atelier.platform.iam.domain.

**Raíces de Agregado y Entidades Dependientes de IAM & Tenancy**

El diseño de las entidades de este contexto asegura que toda mutación de estado preserve las invariantes de gobernanza, seguridad y consistencia transaccional:

- **Tenant**: Representa la empresa o taller mecánico titular de una cuenta en la plataforma. Es la raíz de particionamiento lógico para el aislamiento multi-inquilino. Impone como regla inquebrantable que toda organización posea un documento tributario **TaxId** formalmente validado bajo el algoritmo Módulo 11 de SUNAT, el cual resulta inmutable tras su confirmación fiscal. Administra el identificador de cliente en la pasarela Stripe (**stripeCustomerId**) y regula el ciclo de vida operativo mediante transiciones estrictas: PENDING → ACTIVE → SUSPENDED. Toda empresa operativa debe contar con al menos una sede física activa que actúe como sede matriz.

En la @tbl:iam-tenant-members se detallan los miembros y reglas operativas de la raíz de agregado **Tenant**.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de la Raíz de Agregado Tenant} \label{tbl:iam-tenant-members} \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Raíz de Agregado:} Tenant (Núcleo Organizacional del Taller)} \\*
\hline
id & Identificador universal único del taller mecánico. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TenantId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
name & Nombre comercial del taller automotriz. longitud entre 3 y 100 caracteres. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
legalName & Razón social formal registrada ante la autoridad tributaria SUNAT. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
taxId & Registro Único de Contribuyentes validado con algoritmo Módulo 11. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TaxId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
status & Estado operativo del taller en la plataforma (PENDING, ACTIVE, SUSPENDED). \\*
\hline
\textbf{Tipo o Firma} & \texttt{TenantStatus} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
stripeCustomerId & Identificador de cliente asignado en Stripe para facturación de suscripción. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
branches & Colección interna de sedes físicas administradas por el taller automotriz. \\*
\hline
\textbf{Tipo o Firma} & \texttt{List<\allowbreak Branch>\allowbreak } \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
create & Factoría de dominio que valida datos, instancia el agregado y registra TenantRegisteredEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{static Tenant create(String name,\allowbreak  String legalName,\allowbreak  TaxId taxId)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
assignStripeCustomerId & Asocia el identificador de cliente de Stripe una vez sincronizado por Billing. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void assignStripeCustomerId(String customerId)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
activate & Transiciona el estado del taller a ACTIVE y registra TenantActivatedEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void activate()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
suspend & Transiciona el estado a SUSPENDED y registra TenantSuspendedEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void suspend(String reason)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
addBranch & Instancia e incorpora una nueva sede física, emitiendo BranchCreatedEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Branch addBranch(String name,\allowbreak  String sunatCode,\allowbreak  GeoPoint location,\allowbreak  int radius)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
updateProfile & Modifica los datos corporativos del taller bajo validación de estado activo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void updateProfile(String name,\allowbreak  String legalName)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
findBranchById & Consulta una sede física específica dentro de la colección interna. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Optional<\allowbreak Branch>\allowbreak  findBranchById(BranchId branchId)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
activeBranches & Retorna una vista inmutable de las sedes operativas no dadas de baja. \\*
\hline
\textbf{Tipo o Firma} & \texttt{List<\allowbreak Branch>\allowbreak  activeBranches()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de miembros y métodos del agregado Tenant del paquete com.andeva.atelier.platform.iam.domain.model.aggregates.

En cuanto a sus relaciones, **Tenant** hereda de **AbstractDomainAggregateRoot<Tenant>** y mantiene una relación de composición 1 a 1..* con sus entidades dependientes **Branch**. Si el taller es suspendido o eliminado, el acceso a sus sedes y operaciones queda revocado de inmediato.

- **Branch**: Representa una sucursal o establecimiento físico perteneciente a la empresa automotriz. Su código de anexo tributario **sunatCode** exige una cadena de cuatro dígitos asignada por SUNAT (fijando "0000" para la sede matriz). Su ubicación geográfica se modela mediante el objeto de valor **GeoPoint** en coordenadas WGS84, delimitando una geocerca circular con radio radial en metros (*geofenceRadiusMeters* ≥ 10). La entidad ofrece el método *isWithinGeofence(GeoPoint)*, el cual evalúa la proximidad física del personal contrastando la distancia ortodrómica calculada por Haversine con el radio perimetral autorizado.

En la @tbl:iam-branch-members se exponen los atributos y métodos de la entidad **Branch**.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de la Entidad Dependiente Branch} \label{tbl:iam-branch-members} \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad Dependiente:} Branch (Sede Operativa del Taller)} \\*
\hline
id & Identificador universal único de la sede física de atención. \\*
\hline
\textbf{Tipo o Firma} & \texttt{BranchId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
tenantId & Identificador del taller automotriz propietario. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TenantId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
name & Denominación operativa de la sucursal (longitud entre 3 y 100 caracteres). \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
sunatCode & Código tributario de anexo SUNAT de cuatro dígitos (por defecto 0000). \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
location & Coordenadas geodésicas WGS84 correspondientes al centroide del taller. \\*
\hline
\textbf{Tipo o Firma} & \texttt{GeoPoint} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
geofenceRadiusMeters & Radio radial en metros (\textit{geofenceRadiusMeters} $\ge$ 10) para control presencial. \\*
\hline
\textbf{Tipo o Firma} & \texttt{int} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
isActive & Indicador de disponibilidad operativa de la sucursal. \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
updateLocation & Modifica la posición satelital y el radio perimetral de la sede física. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void updateLocation(GeoPoint newLocation,\allowbreak  int newRadiusMeters)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
updateDetails & Actualiza el nombre operativo y el código de anexo tributario de la sede. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void updateDetails(String newName,\allowbreak  String newSunatCode)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
deactivate & Inhabilita operativamente la sede y registra BranchDeactivatedEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void deactivate()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
isWithinGeofence & Verifica si una coordenada GPS se sitúa dentro del radio perimetral autorizado. \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean isWithinGeofence(GeoPoint coordinate)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de miembros de la entidad Branch del paquete com.andeva.atelier.platform.iam.domain.model.entities.

Respecto a sus relaciones, **Branch** es una entidad subordinada a la raíz **Tenant** y encapsula los objetos de valor **BranchId**, **TenantId** y **GeoPoint**, interactuando con el Bounded Context Human Resources para la validación satelital del marcaje de asistencia de mecánicos.

- **User**: Modela la identidad global de un individuo dentro del ecosistema Atelier, ya sea propietario, recepcionista, mecánico o conductor particular. La dirección de correo electrónico (**EmailAddress**) actúa como credencial canónica única a nivel global. En cuentas de autenticación local, la credencial **Password** es obligatoria y contiene un hash BCrypt verificado, mientras que en cuentas federadas con Google OAuth2 se vincula el identificador externo (**googleId**) sin requerir contraseña local. Administra el token de mensajería Firebase (**fcmToken**) y el ciclo de vida de la cuenta: PENDING_VERIFICATION → ACTIVE → SUSPENDED.

- **Profile**: Entidad dependiente en relación 1 a 1 con **User** que resguarda los datos demográficos del individuo. Encapsula el nombre estructurado (**PersonName**), el número telefónico normalizado bajo estándar internacional E.164 (**PhoneNumber**) y la dirección URI de la imagen de avatar. Su mutación se encuentra controlada por métodos de frontera en el agregado raíz.

- **VerificationToken**: Entidad dependiente que gestiona credenciales de un solo uso requeridas para confirmar correos electrónicos y procesar el restablecimiento de contraseñas olvidadas. Puede almacenar códigos OTP decimales de 6 dígitos con vigencia estricta de 15 minutos o tokens alfanuméricos de alta entropía con caducidad de 24 horas. Registra una bandera de consumo (**isUsed**) para imposibilitar ataques de reutilización.

En la @tbl:iam-user-profile-token-members se especifican los miembros de **User**, **Profile** y **VerificationToken**.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de la Raíz de Agregado User y Entidades Profile y VerificationToken} \label{tbl:iam-user-profile-token-members} \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Raíz de Agregado:} User (Identidad Universal de Usuario)} \\*
\hline
id (User) & Identificador universal único de la cuenta de usuario. \\*
\hline
\textbf{Tipo o Firma} & \texttt{UserId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
email & Dirección de correo electrónico canónica normalizada a minúsculas. \\*
\hline
\textbf{Tipo o Firma} & \texttt{EmailAddress} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
password & Hash BCrypt de la contraseña para cuentas de autenticación local. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Password} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
authProvider & Mecanismo de autenticación de la cuenta (LOCAL o GOOGLE). \\*
\hline
\textbf{Tipo o Firma} & \texttt{AuthProvider} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
googleId & Identificador federado de usuario provisto por Google OAuth2 SSO. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
fcmToken & Token de registro en Firebase Cloud Messaging para notificaciones push. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
status & Estado del usuario (PENDING\_VERIFICATION, ACTIVE, SUSPENDED). \\*
\hline
\textbf{Tipo o Firma} & \texttt{UserStatus} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
profile & Entidad interna 1 a 1 con los datos biográficos de la persona. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Profile} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
verificationTokens & Colección interna de tokens de verificación emitidos y consumidos. \\*
\hline
\textbf{Tipo o Firma} & \texttt{List<\allowbreak VerificationToken>\allowbreak } \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
registerWithLocalCredentials & Factoría para cuentas locales en estado pendiente que registra UserRegisteredEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{static User registerWithLocalCredentials(...)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
registerWithGoogle & Factoría para cuentas federadas activas validadas por Google OAuth2. \\*
\hline
\textbf{Tipo o Firma} & \texttt{static User registerWithGoogle(...)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
verifyEmail & Confirma el correo electrónico, transiciona a ACTIVE y emite UserVerifiedEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void verifyEmail()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
updatePassword & Actualiza el hash de la contraseña y registra UserPasswordChangedEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void updatePassword(Password newPassword)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
updateFcmToken & Actualiza el token de mensajería push de Firebase para el dispositivo móvil. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void updateFcmToken(String fcmToken)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
validateAndConsumeToken & Valida la vigencia del token y lo marca como consumido de forma irreversible. \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean validateAndConsumeToken(...)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad Dependiente:} Profile (Perfil Biográfico de Usuario)} \\*
\hline
updateProfile & Delega la mutación de atributos demográficos a la entidad interna Profile. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void updateProfile(PersonName name,\allowbreak  PhoneNumber phone)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
name (Profile) & Nombres y apellidos normalizados de la persona. \\*
\hline
\textbf{Tipo o Firma} & \texttt{PersonName} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
phone & Número telefónico formateado conforme a la norma internacional E.164. \\*
\hline
\textbf{Tipo o Firma} & \texttt{PhoneNumber} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
avatarUrl & Enlace URI hacia el archivo de imagen de perfil del usuario en almacenamiento de objetos. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad Dependiente:} VerificationToken (Token Criptográfico Temporal)} \\*
\hline
issueVerificationToken & Genera un token numérico OTP o alfanumérico seguro con vigencia temporal. \\*
\hline
\textbf{Tipo o Firma} & \texttt{VerificationToken issueVerificationToken(...)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
token (VerificationToken) & Valor criptográfico o código numérico decimal de un solo uso. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
tokenType & Propósito del token (EMAIL\_VERIFICATION o PASSWORD\_RESET). \\*
\hline
\textbf{Tipo o Firma} & \texttt{TokenType} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
expiresAt & Marca temporal límite de validez en horario UTC. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Instant} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
isUsed & Indicador booleano que certifica si el token ya fue consumido. \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes a los paquetes com.andeva.atelier.platform.iam.domain.model.aggregates y com.andeva.atelier.platform.iam.domain.model.entities.

En sus relaciones, **User** hereda de **AbstractDomainAggregateRoot<User>** y compone de forma unívoca a **Profile** y de forma múltiple a **VerificationToken**. Si la cuenta es purgada del sistema, su perfil y tokens asociados se eliminan en cascada sin afectar los registros históricos de auditoría.

- **TenantMembership**: Modela el vínculo contractual y operativo entre una cuenta global **User** y un taller específico **Tenant**. Representa formalmente la figura del colaborador o trabajador automotriz. Su invariante fundamental es la unicidad estricta del par compuesto por (**tenantId**, **userId**), impidiendo contratos duplicados para la misma persona en una sola empresa. Asocia el esquema de retribución salarial pactado (**SalaryType**: FIXED para sueldo mensual o quincenal, HOURLY para retribución por hora de labor en taller) y el importe económico base (**baseSalary**: **Money**) con restricción (*amount* ≥ 0.00). Centraliza el conjunto de roles de seguridad (**Role**) concedidos al trabajador y regula su vigencia mediante los estados ACTIVE e INACTIVE.

En la @tbl:iam-membership-members se detallan los atributos y operaciones de **TenantMembership**.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de la Raíz de Agregado TenantMembership} \label{tbl:iam-membership-members} \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Raíz de Agregado:} TenantMembership (Vinculación Laboral y Acceso)} \\*
\hline
id & Identificador universal único del contrato de membresía laboral. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TenantMembershipId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
tenantId & Identificador del taller mecánico empleador. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TenantId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
userId & Identificador de la cuenta de usuario adscrita al contrato. \\*
\hline
\textbf{Tipo o Firma} & \texttt{UserId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
status & Estado de vigencia del vínculo de trabajo (ACTIVE o INACTIVE). \\*
\hline
\textbf{Tipo o Firma} & \texttt{MembershipStatus} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
salaryType & Modalidad de retribución convenida con el trabajador (FIXED u HOURLY). \\*
\hline
\textbf{Tipo o Firma} & \texttt{SalaryType} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
baseSalary & Monto de retribución base pactada expresada en moneda local (\textit{amount} $\ge$ 0.00). \\*
\hline
\textbf{Tipo o Firma} & \texttt{Money} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
assignedRoles & Colección de roles de seguridad y permisos concedidos en este taller. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Set<\allowbreak Role>\allowbreak } \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
create & Factoría de dominio que inicializa el contrato y registra TenantMembershipCreatedEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{static TenantMembership create(...)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
assignRole & Otorga un nuevo rol al colaborador dentro del marco operativo del taller. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void assignRole(Role role)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
revokeRole & Remueve un rol asignado asegurando que el colaborador conserve al menos uno activo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void revokeRole(RoleId roleId)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
updateCompensation & Modifica la modalidad salarial y el importe pactado con el colaborador. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void updateCompensation(SalaryType type,\allowbreak  Money salary)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
activate & Restablece la vigencia del contrato laboral a estado ACTIVE. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void activate()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
deactivate & Inhabilita el contrato laboral y registra TenantMembershipDeactivatedEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void deactivate()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
hasPermission & Evalúa si alguno de los roles asignados al colaborador posee el permiso consultado. \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean hasPermission(String permissionName)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de miembros de TenantMembership del paquete com.andeva.atelier.platform.iam.domain.model.aggregates.

Respecto a sus relaciones, **TenantMembership** hereda de **AbstractDomainAggregateRoot<TenantMembership>** y actúa como puente de referencia débil hacia **TenantId** y **UserId**, estableciendo una agregación directa con las entidades **Role** del taller. Esta estructura suministra el sustrato para la generación de liquidaciones en Human Resources y la asignación técnica de órdenes en MRO.

- **Role**, **Permission** e **Invitation**: Completan el subsistema de gobernanza y control de acceso. **Role** actúa como raíz de agregado que agrupa un conjunto de entidades dependientes **Permission**, las cuales modelan privilegios atómicos según la convención canónica `<contexto>:<recurso>:<accion>`. Los roles pueden pertenecer a un taller específico o ser roles semilla del sistema protegidos por la bandera **isSystemRole**, lo que impide su alteración o supresión por parte de usuarios del taller. Por su parte, **Invitation** gestiona el proceso de onboarding mediante tokens criptográficos de un solo uso generados aleatoriamente con validez estricta de 72 horas, permitiendo que nuevos colaboradores activen su cuenta e ingresen a la membresía del taller emitiendo los eventos StaffInvitedEvent y StaffInvitationAcceptedEvent.

En la @tbl:iam-security-members se sintetizan los miembros de **Role**, **Permission** e **Invitation**.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de las Entidades de Seguridad Role, Permission e Invitation} \label{tbl:iam-security-members} \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Raíz de Agregado:} Role (Rol de Seguridad RBAC)} \\*
\hline
id (Role) & Identificador universal único del rol de seguridad. \\*
\hline
\textbf{Tipo o Firma} & \texttt{RoleId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
tenantId (Role) & Identificador del taller propietario (nulo en roles globales del sistema). \\*
\hline
\textbf{Tipo o Firma} & \texttt{TenantId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
name (Role) & Denominación funcional del rol (única dentro del ámbito del taller). \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
isSystemRole & Bandera de inmutabilidad para roles nativos provistos por la plataforma. \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
permissions & Conjunto de permisos atómicos asignados al rol. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Set<\allowbreak Permission>\allowbreak } \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
grantPermission & Incorpora un permiso al rol asegurando que no se encuentre protegido por el sistema. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void grantPermission(Permission permission)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
revokePermission & Remueve un permiso del conjunto verificando la mutabilidad del rol. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void revokePermission(PermissionId id)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad de Dominio:} Permission (Permiso Atómico del Sistema)} \\*
\hline
id (Permission) & Identificador universal único del permiso atómico. \\*
\hline
\textbf{Tipo o Firma} & \texttt{PermissionId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
name (Permission) & Nombre descriptivo del permiso dentro del catálogo del sistema. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
resource & Recurso o entidad de negocio protegida por la regla de seguridad. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
action & Operación permitida sobre el recurso (creación, lectura, edición, baja o ejecución). \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Raíz de Agregado:} Invitation (Invitación de Personal)} \\*
\hline
id (Invitation) & Identificador universal único de la invitación de personal. \\*
\hline
\textbf{Tipo o Firma} & \texttt{InvitationId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
token (Invitation) & Token criptográfico aleatorio de alta entropía codificado en Base64 URL-safe. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
status (Invitation) & Estado de la invitación (PENDING, ACCEPTED, EXPIRED, REVOKED). \\*
\hline
\textbf{Tipo o Firma} & \texttt{InvitationStatus} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
targetRoleId & Rol que se concederá automáticamente al usuario una vez canjeado el token. \\*
\hline
\textbf{Tipo o Firma} & \texttt{RoleId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
expiresAt (Invitation) & Límite temporal de vigencia fijado en 72 horas desde la emisión. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Instant} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
issue & Factoría de dominio que emite la invitación y registra StaffInvitedEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{static Invitation issue(...)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
accept & Canjea el token, transiciona a ACCEPTED y emite StaffInvitationAcceptedEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void accept(UserId acceptedByUserId)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
expire & Transiciona el estado a EXPIRED si se sobrepasó la marca temporal límite. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void expire()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
revoke & Anula administrativamente la invitación impidiendo su posterior canje. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void revoke()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes a los paquetes com.andeva.atelier.platform.iam.domain.model.aggregates y com.andeva.atelier.platform.iam.domain.model.entities.

**Objetos de Valor y Enumeraciones de Dominio de IAM & Tenancy**

Para salvaguardar la pureza del modelo y prevenir errores derivados de tipos de datos primitivos desprovistos de contexto semántico, el Bounded Context IAM adopta una colección rigurosa de registros inmutables y tipos enumerados:

- **Identificadores fuertemente tipados**: Registros inmutables que encapsulan identificadores universales de 128 bits para conferir seguridad de tipos absoluta: **TenantMembershipId**, **RoleId**, **PermissionId** e **InvitationId**. Cada uno valida en su constructor compacto que el valor no sea nulo y provee factorías para cadenas de texto, UUIDs directos y generación aleatoria segura. Los identificadores transversales **TenantId**, **BranchId** y **UserId** son reutilizados directamente desde el Bounded Context Shared.

- **Password**: Registro inmutable de Java `Password(String hash)` que actúa como contenedor inviolable de credenciales locales. Su constructor compacto exige una longitud exacta de 60 caracteres y valida la presencia de los prefijos estandarizados de la función de derivación de claves BCrypt (variantes 2a, 2b o 2y delimitadas por el carácter de moneda). Impide almacenar o manipular contraseñas en texto plano dentro del modelo de dominio.

- **PersonName**: Registro inmutable de Java `PersonName(String firstName, String lastName)` que modela los componentes patronímicos del usuario. Valida que ninguno de sus atributos sea nulo ni posea una longitud inferior a 2 caracteres, suprimiendo espacios sobrantes y garantizando coherencia tipográfica en perfiles y credenciales.

- **Enumeraciones del ciclo de vida y seguridad**: El modelo incorpora un conjunto de tipos enumerados cerrados para tipificar las transiciones operativas:
  - **TenantStatus**: Estados operativos de la empresa automotriz (PENDING, ACTIVE, SUSPENDED).
  - **UserStatus**: Estados de habilitación de la cuenta de usuario (PENDING_VERIFICATION, ACTIVE, SUSPENDED).
  - **MembershipStatus**: Vigencia contractual del colaborador en un taller determinado (ACTIVE, INACTIVE).
  - **SalaryType**: Modalidad de retribución convenida con el personal (FIXED, HOURLY).
  - **TokenType**: Propósito funcional de los tokens temporales (EMAIL_VERIFICATION, PASSWORD_RESET).
  - **InvitationStatus**: Fases del flujo de onboarding de personal (PENDING, ACCEPTED, EXPIRED, REVOKED).
  - **AuthProvider**: Origen de identidad y mecanismo de autenticación (LOCAL, GOOGLE).

En la @tbl:iam-value-objects se especifican los objetos de valor y enumeraciones propios de este contexto.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Objetos de Valor y Enumeraciones del Bounded Context IAM \& Tenancy} \label{tbl:iam-value-objects} \\
\hline
\thfirst{Aspecto del Tipo} & \thcell{Especificación de Dominio} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Tipo} & \thcell{Especificación de Dominio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} TenantMembershipId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal de membresía laboral. no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} RoleId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal de rol de seguridad. no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} PermissionId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal de permiso atómico. no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} InvitationId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal de invitación de personal. no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} Password} \\*
\hline
\textbf{Atributos Clave} & \texttt{hash: String} \\*
\hline
\textbf{Restricciones y Reglas} & Longitud exacta de 60 caracteres. prefijos válidos de BCrypt. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} PersonName} \\*
\hline
\textbf{Atributos Clave} & \texttt{firstName}, \texttt{lastName: String} \\*
\hline
\textbf{Restricciones y Reglas} & Mínimo 2 caracteres por atributo. eliminación de espacios superfluos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración:} TenantStatus} \\*
\hline
\textbf{Atributos Clave} & Enumeración \\*
\hline
\textbf{Restricciones y Reglas} & Tres valores cerrados representativos del ciclo de vida del taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración:} UserStatus} \\*
\hline
\textbf{Atributos Clave} & Enumeración \\*
\hline
\textbf{Restricciones y Reglas} & Tres valores cerrados representativos de la habilitación de la cuenta. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración:} MembershipStatus} \\*
\hline
\textbf{Atributos Clave} & Enumeración \\*
\hline
\textbf{Restricciones y Reglas} & Dos estados que regulan el acceso activo a las operaciones del taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración:} SalaryType} \\*
\hline
\textbf{Atributos Clave} & Enumeración \\*
\hline
\textbf{Restricciones y Reglas} & Dos esquemas de retribución económica homologados para el personal. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración:} TokenType} \\*
\hline
\textbf{Atributos Clave} & Enumeración \\*
\hline
\textbf{Restricciones y Reglas} & Dos modalidades de tokens de verificación temporal emitidos por la plataforma. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración:} InvitationStatus} \\*
\hline
\textbf{Atributos Clave} & Enumeración \\*
\hline
\textbf{Restricciones y Reglas} & Cuatro estados que gobiernan el ciclo de vida del onboarding digital. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración:} AuthProvider} \\*
\hline
\textbf{Atributos Clave} & Enumeración \\*
\hline
\textbf{Restricciones y Reglas} & Dos mecanismos de autenticación admitidos en el acceso al ecosistema. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes ubicados en com.andeva.atelier.platform.iam.domain.model.valueobjects.

**Servicios de Dominio de IAM & Tenancy**

Los servicios de dominio encapsulan operaciones de lógica de negocio pura y algoritmos criptográficos que operan sobre múltiples raíces de agregado o que no pertenecen por cohesión a una sola entidad:

- **TenantRegistrationDomainService**: Orquesta el caso de negocio fundacional de Atelier: el alta integral de una empresa automotriz. Esta operación atómica comprende la validación tributaria del RUC mediante el objeto de valor **TaxId**, la creación de la raíz **Tenant**, la apertura automática de la sede matriz inicial con código de anexo "0000", la creación de la cuenta **User** del propietario con su entidad dependiente **Profile**, la provisión de la plantilla de roles del sistema para el nuevo taller, la concesión del rol de administrador y la formalización de la primera membresía **TenantMembership**. Asimismo, vincula el identificador de cliente en Stripe si se encuentra disponible.

- **PasswordEncryptionDomainService**: Servicio puro que encapsula el algoritmo criptográfico BCrypt con factor de costo computacional de 12 rondas. Provee el método *hashPassword(String rawPassword)* para derivar resúmenes criptográficos seguros e impone la política de complejidad de contraseñas de Atelier: longitud mínima de 8 caracteres, al menos una letra mayúscula, una letra minúscula, un dígito numérico y un símbolo especial. Ofrece también el método *verifyPassword(String rawPassword, Password hashedPassword)* para la evaluación segura de credenciales sin riesgos de ataques de sincronización temporal.

- **TokenGeneratorDomainService**: Servicio criptográfico responsable de generar valores aleatorios de alta entropía empleando la clase segura **SecureRandom**. Suministra el método *generateNumericOtp(int digits)*, el cual produce secuencias decimales uniformemente distribuidas de 6 dígitos para validación rápida en canales móviles y correo electrónico, y el método *generateSecureToken(int byteLength)*, que produce cadenas alfanuméricas seguras codificadas en Base64 URL-safe.

En la @tbl:iam-domain-services se exponen las interfaces de estos tres servicios de dominio.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Servicios de Dominio del Bounded Context IAM \& Tenancy} \label{tbl:iam-domain-services} \\
\hline
\thfirst{Aspecto de Servicio} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Servicio} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Dominio:} TenantRegistrationDomainService} \\*
\hline
\textbf{Métodos Principales} & \texttt{registerTenant(...)} \\*
\hline
\textbf{Responsabilidad} & Orquesta la creación atómica de taller, sede matriz, usuario titular y membresía inicial. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Dominio:} PasswordEncryptionDomainService} \\*
\hline
\textbf{Métodos Principales} & - \texttt{hashPassword(...)} \newline - \texttt{verifyPassword(...)} \newline - \texttt{validatePolicy(...)} \\*
\hline
\textbf{Responsabilidad} & Cifrado seguro BCrypt y verificación de políticas de complejidad de credenciales. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Dominio:} TokenGeneratorDomainService} \\*
\hline
\textbf{Métodos Principales} & - \texttt{generateNumericOtp(...)} \newline - \texttt{generateSecureToken(...)} \\*
\hline
\textbf{Responsabilidad} & Generación de números OTP de 6 dígitos y tokens criptográficos Base64 URL-safe. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes ubicados en el paquete com.andeva.atelier.platform.iam.domain.services.

**Puertos de Repositorio de la Capa de Dominio**

En concordancia con los principios de Clean Architecture, la persistencia de las entidades de IAM se desacopla mediante puertos de salida abstractos en el dominio. Las interfaces definen los contratos requeridos utilizando estrictamente tipos de dominio, sin anotaciones de Spring ni de Jakarta Persistence:

- **TenantRepository**: Define las operaciones para persistir y consultar talleres automotrices mediante **TenantId**, razón social o número de **TaxId**.

- **UserRepository**: Administra la persistencia de identidades de acceso, ofreciendo consultas deterministas por **UserId** y búsqueda canónica por **EmailAddress**.

- **TenantMembershipRepository**: Gestiona los contratos laborales, permitiendo recuperar la membresía activa por el par compuesto por **TenantId** y **UserId**, listar colaboradores por taller y consultar el personal asignado a una sucursal específica.

- **RoleRepository**: Provee métodos de recuperación para roles personalizados del taller y consulta de plantillas globales del sistema protegidas contra modificación.

- **PermissionRepository**: Catálogo de solo lectura para la resolución en memoria de permisos atómicos y códigos de autoridad del ecosistema.

- **InvitationRepository**: Controla la persistencia de invitaciones de onboarding, facilitando la consulta de invitaciones pendientes por token criptográfico o por correo destinatario dentro de un taller.

- **VerificationTokenRepository**: Administra el almacenamiento y consumo de tokens OTP de un solo uso, implementando métodos para validar códigos vigentes y purgar registros caducos.

En la @tbl:iam-repository-ports se detallan las operaciones provistas por estos puertos de salida.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Puertos de Repositorio del Bounded Context IAM \& Tenancy} \label{tbl:iam-repository-ports} \\
\hline
\thfirst{Aspecto de Puerto} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Puerto} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Repositorio:} TenantRepository} \\*
\hline
\textbf{Métodos Principales} & - \texttt{save} \newline - \texttt{findById} \newline - \texttt{findByTaxId} \newline - \texttt{existsByTaxId} \\*
\hline
\textbf{Responsabilidad de Dominio} & Persistencia y consulta de la raíz de agregado Tenant por identidad y RUC fiscal. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Repositorio:} UserRepository} \\*
\hline
\textbf{Métodos Principales} & - \texttt{save} \newline - \texttt{findById} \newline - \texttt{findByEmail} \newline - \texttt{existsByEmail} \\*
\hline
\textbf{Responsabilidad de Dominio} & Persistencia de cuentas de usuario y recuperación por dirección canónica de correo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Repositorio:} TenantMembershipRepository} \\*
\hline
\textbf{Métodos Principales} & - \texttt{save} \newline - \texttt{findById} \newline - \texttt{findByTenantIdAndUserId} \newline - \texttt{findByTenantId} \\*
\hline
\textbf{Responsabilidad de Dominio} & Gestión contractual de colaboradores y resolución de membresías por empresa. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Repositorio:} RoleRepository} \\*
\hline
\textbf{Métodos Principales} & - \texttt{save} \newline - \texttt{findById} \newline - \texttt{findByTenantIdAndName} \newline - \texttt{findSystemRoles} \\*
\hline
\textbf{Responsabilidad de Dominio} & Administración de roles de seguridad personalizados de taller y roles globales. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Repositorio:} PermissionRepository} \\*
\hline
\textbf{Métodos Principales} & - \texttt{findAll} \newline - \texttt{findById} \newline - \texttt{findByName} \\*
\hline
\textbf{Responsabilidad de Dominio} & Catálogo de privilegios de seguridad y consulta de autoridades del sistema. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Repositorio:} InvitationRepository} \\*
\hline
\textbf{Métodos Principales} & - \texttt{save} \newline - \texttt{findById} \newline - \texttt{findByToken} \newline - \texttt{findByTenantIdAndEmail} \\*
\hline
\textbf{Responsabilidad de Dominio} & Control del ciclo de vida y canje de invitaciones de incorporación de personal. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Repositorio:} VerificationTokenRepository} \\*
\hline
\textbf{Métodos Principales} & - \texttt{save} \newline - \texttt{findByTokenAndType} \newline - \texttt{deleteExpiredTokens} \\*
\hline
\textbf{Responsabilidad de Dominio} & Almacenamiento, validación y depuración de tokens OTP temporales de un solo uso. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Interfaces de salida pertenecientes al paquete com.andeva.atelier.platform.iam.domain.repositories.

**Eventos de Dominio y Taxonomía de Excepciones Semánticas**

La sincronización entre el Bounded Context IAM y los demás módulos de negocio de Atelier Platform se articula mediante eventos de dominio inmutables que implementan el contrato base **DomainEvent**. Estos eventos se publican transaccionalmente mediante el patrón Transactional Outbox, asegurando entrega con semántica at-least-once:

- **Eventos de taller**: **TenantRegisteredEvent** notifica el alta inicial de la empresa automotriz para provisionar su catálogo inicial en Inventario y Facturación; **TenantActivatedEvent** señala la rehabilitación de operaciones; **TenantSuspendedEvent** notifica la revocación inmediata de accesos y la suspensión de servicios por morosidad o infracción contractual.

- **Eventos de sede física**: **BranchCreatedEvent** notifica la delimitación de una nueva sucursal con sus coordenadas satelitales WGS84 para la apertura de turnos en Human Resources; **BranchUpdatedEvent** transporta ajustes en nombre o perímetro; **BranchDeactivatedEvent** notifica el cese operativo de la sede.

- **Eventos de identidad y credenciales**: **UserRegisteredEvent** notifica el alta de una cuenta para iniciar la verificación de correo electrónico; **UserVerifiedEvent** confirma la activación plena del usuario; **UserPasswordResetRequestedEvent** transporta el token OTP para su despacho mediante la API REST de Resend; **UserPasswordChangedEvent** registra la renovación de credenciales; **UserSuspendedEvent** revoca las sesiones activas en todos los clientes móviles y web.

- **Eventos de contratación y onboarding**: **TenantMembershipCreatedEvent** notifica la adscripción de un trabajador al taller para el registro de su legajo en Recursos Humanos; **TenantMembershipDeactivatedEvent** notifica la baja laboral; **StaffInvitedEvent** transporta el token de invitación para el envío del correo de bienvenida; **StaffInvitationAcceptedEvent** formaliza la incorporación del colaborador al equipo operativo del taller.

En la @tbl:iam-domain-events se sintetiza la taxonomía de eventos de dominio de este contexto.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Taxonomía de Eventos de Dominio del Bounded Context IAM \& Tenancy} \label{tbl:iam-domain-events} \\
\hline
\thfirst{Aspecto del Evento} & \thcell{Especificación de Carga Útil y Efecto} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Evento} & \thcell{Especificación de Carga Útil y Efecto} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} TenantRegisteredEvent \quad (\textit{Emisor:} Tenant)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{tenantId}, \texttt{name}, \texttt{taxId}, \texttt{status} \\*
\hline
\textbf{Efecto Intermodular} & Notifica el alta del taller para inicialización de catálogos y contabilidad. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} TenantActivatedEvent \quad (\textit{Emisor:} Tenant)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{tenantId}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Restablece los permisos y accesos operativos del personal en el taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} TenantSuspendedEvent \quad (\textit{Emisor:} Tenant)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{tenantId}, \texttt{reason}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Revoca de inmediato los accesos y sesiones de usuarios adscritos al taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} BranchCreatedEvent \quad (\textit{Emisor:} Tenant)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{branchId}, \texttt{tenantId}, \texttt{name}, \texttt{location} \\*
\hline
\textbf{Efecto Intermodular} & Provisiona bahías de servicio y habilita la marcación de asistencia presencial. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} BranchUpdatedEvent \quad (\textit{Emisor:} Tenant)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{branchId}, \texttt{name}, \texttt{location}, \texttt{radius} \\*
\hline
\textbf{Efecto Intermodular} & Actualiza el perímetro satelital de la sede para el control de geocercas GPS. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} BranchDeactivatedEvent \quad (\textit{Emisor:} Tenant)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{branchId}, \texttt{tenantId}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Cierra la disponibilidad operativa de la sucursal para nuevas órdenes de trabajo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} UserRegisteredEvent \quad (\textit{Emisor:} User)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{userId}, \texttt{email}, \texttt{authProvider} \\*
\hline
\textbf{Efecto Intermodular} & Dispara el envío de correo de bienvenida y verificación inicial de identidad. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} UserVerifiedEvent \quad (\textit{Emisor:} User)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{userId}, \texttt{email}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Habilita el inicio de sesión y la asignación plena de credenciales. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} UserPasswordResetRequestedEvent \quad (\textit{Emisor:} User)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{userId}, \texttt{email}, \texttt{token}, \texttt{expiresAt} \\*
\hline
\textbf{Efecto Intermodular} & Despacha el código OTP mediante el servicio transaccional de mensajería. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} UserPasswordChangedEvent \quad (\textit{Emisor:} User)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{userId}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Invalida tokens de sesión previos exigiendo reautenticación en clientes. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} UserSuspendedEvent \quad (\textit{Emisor:} User)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{userId}, \texttt{reason}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Bloquea el acceso universal de la cuenta a todos los talleres y aplicaciones. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} TenantMembershipCreatedEvent \quad (\textit{Emisor:} TenantMembership)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{membershipId}, \texttt{tenantId}, \texttt{userId}, \texttt{role} \\*
\hline
\textbf{Efecto Intermodular} & Registra el alta del trabajador en el padrón laboral y control de asistencia. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} TenantMembershipDeactivatedEvent \quad (\textit{Emisor:} TenantMembership)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{membershipId}, \texttt{tenantId}, \texttt{userId} \\*
\hline
\textbf{Efecto Intermodular} & Da de baja las credenciales del trabajador en el taller y liquida turnos activos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} StaffInvitedEvent \quad (\textit{Emisor:} Invitation)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{invitationId}, \texttt{tenantId}, \texttt{email}, \texttt{token} \\*
\hline
\textbf{Efecto Intermodular} & Despacha la invitación por correo electrónico con enlace tokenizado uniuso. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} StaffInvitationAcceptedEvent \quad (\textit{Emisor:} Invitation)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{invitationId}, \texttt{tenantId}, \texttt{userId}, \texttt{role} \\*
\hline
\textbf{Efecto Intermodular} & Consolida la afiliación del nuevo trabajador y crea su membresía laboral. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Eventos inmutables ubicados bajo el paquete com.andeva.atelier.platform.iam.domain.events.

Por último, el manejo determinista de anomalías de negocio se implementa mediante excepciones semánticas fuertemente tipadas que heredan de la clase base **DomainException** provista por el Bounded Context Shared. Al producirse la transgresión de una regla o invariante, la capa de dominio interrumpe la operación arrojando una de estas anomalías, las cuales son interceptadas por los manejadores de comandos de la Capa de Aplicación y transformadas en resultados de falla **Result.Failure** o formateadas como problemas estándar bajo la RFC 7807:

- **Anomalías de taller**: **TenantNotFoundException** ante identificadores de taller inexistentes; **TenantAlreadyExistsException** ante intentos de duplicar un RUC registrado; **TenantSuspendedException** si se intenta operar sobre una empresa con actividades comerciales suspendidas.

- **Anomalías de usuario y credenciales**: **UserNotFoundException** ante cuentas inexistentes; **UserAlreadyExistsException** cuando una dirección de correo ya se encuentra en uso; **UserSuspendedException** al detectar accesos de cuentas suspendidas; **InvalidCredentialsException** ante contraseñas incorrectas; **InvalidVerificationTokenException** ante códigos OTP erróneos, vencidos o previamente consumidos.

- **Anomalías de membresía y roles**: **MembershipNotFoundException** cuando un usuario no posee contrato en un taller consultado; **MembershipAlreadyExistsException** al intentar duplicar el contrato de un trabajador en el mismo taller; **RoleNotFoundException** si se hace referencia a un rol no catalogado; **SystemRoleImmutableException** si se intenta modificar o eliminar un rol predefinido de la plataforma.

- **Anomalías de onboarding**: **InvitationNotFoundException** si el token de invitación no corresponde a ningún registro; **InvitationExpiredException** cuando se sobrepasa el plazo de 72 horas; **InvitationAlreadyAcceptedException** si se intenta canjear un enlace previamente utilizado.

En la @tbl:iam-domain-exceptions se sintetiza la jerarquía de excepciones de dominio y sus códigos de error semánticos asociados.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.8cm} | >{\raggedright\arraybackslash}p{9.6cm} |}
\caption{Excepciones de Dominio y Códigos Semánticos de IAM \& Tenancy} \label{tbl:iam-domain-exceptions} \\
\hline
\thfirst{Código de Error Semántico} & \thcell{Condición de Lanzamiento en el Modelo} \\
\hline
\endfirsthead
\hline
\thfirst{Código de Error Semántico} & \thcell{Condición de Lanzamiento en el Modelo} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} TenantNotFoundException} \\*
\hline
\texttt{TENANT\_NOT\_FOUND} & El identificador de taller consultado no existe en el sistema. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} TenantAlreadyExistsException} \\*
\hline
\texttt{TENANT\_ALREADY\_EXISTS} & El documento RUC provisto ya se encuentra registrado por otra empresa. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} TenantSuspendedException} \\*
\hline
\texttt{TENANT\_SUSPENDED} & La empresa titular se encuentra inhabilitada para operar transacciones. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} UserNotFoundException} \\*
\hline
\texttt{USER\_NOT\_FOUND} & La identidad de usuario consultada no existe en la plataforma global. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} UserAlreadyExistsException} \\*
\hline
\texttt{USER\_ALREADY\_EXISTS} & La dirección de correo electrónico ya está registrada en otra cuenta. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} UserSuspendedException} \\*
\hline
\texttt{USER\_SUSPENDED} & La cuenta global de usuario ha sido suspendida administrativamente. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} InvalidCredentialsException} \\*
\hline
\texttt{INVALID\_CREDENTIALS} & La contraseña o credencial federada provista no coincide con el registro. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} MembershipNotFoundException} \\*
\hline
\texttt{MEMBERSHIP\_NOT\_FOUND} & El usuario no cuenta con un contrato laboral activo en el taller consultado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} MembershipAlreadyExistsException} \\*
\hline
\texttt{MEMBERSHIP\_ALREADY\_EXISTS} & Ya existe una relación laboral activa para este usuario en el taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} RoleNotFoundException} \\*
\hline
\texttt{ROLE\_NOT\_FOUND} & El rol de seguridad solicitado no está disponible en el taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} SystemRoleImmutableException} \\*
\hline
\texttt{SYSTEM\_ROLE\_IMMUTABLE} & Se intentó modificar o dar de baja un rol semilla global del sistema. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} InvitationNotFoundException} \\*
\hline
\texttt{INVITATION\_NOT\_FOUND} & El token de invitación suministrado no corresponde a ningún registro. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} InvitationExpiredException} \\*
\hline
\texttt{INVITATION\_EXPIRED} & El token de invitación ha superado su plazo máximo de vigencia de 72 horas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} InvitationAlreadyAcceptedException} \\*
\hline
\texttt{INVITATION\_ALREADY\_ACCEPTED} & El token de invitación suministrado ya fue canjeado con anterioridad. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} InvalidVerificationTokenException} \\*
\hline
\texttt{INVALID\_VERIFICATION\_TOKEN} & El código OTP o token de un solo uso es inválido, vencido o consumido. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes ubicados bajo el paquete com.andeva.atelier.platform.iam.domain.exceptions.

#### 2.6.2.2. Interface Layer

La capa de interfaz del Bounded Context Identity and Access Management (IAM) & Tenancy constituye el adaptador primario de entrada para la autenticación perimetral, la administración de talleres automotrices, la configuración de sedes físicas, la gestión de colaboradores y el control de acceso basado en roles en Atelier Platform.

Ubicada en el paquete canónico **com.andeva.atelier.platform.iam.interfaces**, su concepción arquitectónica responde a cuatro directrices esenciales de diseño táctico:

- **Desacoplamiento perimetral y traducción determinista:** Los controladores REST nunca interactúan de forma directa con los agregados de dominio ni capturan excepciones de bajo nivel. Toda comunicación se canaliza hacia los servicios de aplicación mediante comandos y consultas, recibiendo como respuesta el tipo de resultado sellado **Result<T, ApplicationError>**. La conversión hacia respuestas HTTP se delega en ensambladores especializados y en el componente transversal **ResponseEntityAssembler**.

- **Tokens de seguridad contextuales y enriquecidos:** El emisor de tokens genera credenciales JWT que integran en sus declaraciones criptográficas el identificador de usuario, el taller activo, la sucursal predeterminada y el conjunto consolidado de autoridades de seguridad. Este esquema permite que los filtros perimetrales autoricen peticiones en memoria con complejidad de tiempo constante, eliminando consultas repetitivas a la base de datos relacional.

- **Verificación perimetral de fronteras multi-inquilino:** Los controladores que exponen rutas parametrizadas por taller verifican que el identificador suministrado en la ruta coincida con el taller autenticado en el contexto de seguridad. Esta validación previene vulnerabilidades de acceso horizontal entre distintos talleres mecánicos que coexisten en la plataforma.

- **Fachada de contexto abierto para integración intermodular:** Para posibilitar que otros módulos consulten la vigencia de talleres, la afiliación de mecánicos o la ubicación de sedes sin acoplamientos circulares, la capa expone la interfaz **TenancyContextFacade**, resguardando la pureza interna de los agregados de identidad.

En la @tbl:iam-interface-types se presenta el catálogo consolidado de los componentes que integran la Capa de Interfaz de IAM & Tenancy.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo Consolidado de la Capa de Interfaz de IAM \& Tenancy} \label{tbl:iam-interface-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endhead
AuthenticationController & Endpoints para registro de talleres, autenticación local y federada, y recuperación de claves. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca TenantCommandService y UserCommandService. utiliza ensambladores de recursos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
TenantsController & Endpoints de consulta y actualización de metadatos de la empresa automotriz titular. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca TenantCommandService y TenantQueryService. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
BranchesController & Endpoints para creación, consulta, modificación de geocercas y baja de sedes físicas. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca TenantCommandService y TenantQueryService. gestiona entidades Branch. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
MembershipsController & Endpoints para administración de colaboradores, asignación de roles y esquema salarial. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca MembershipCommandService y MembershipQueryService. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
InvitationsController & Endpoints para emisión, validación previa y aceptación de invitaciones de personal. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca InvitationCommandService e InvitationQueryService. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
RolesController & Endpoints para consulta y definición de roles de seguridad y catálogo de permisos. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca RoleCommandService y RoleQueryService. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
CreateTenantResource & Carga útil para registro simultáneo de taller, sede matriz y cuenta administradora. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por CreateTenantCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
SignInResource & Credenciales de acceso local mediante correo electrónico y contraseña. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por SignInCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
GoogleSignInResource & Credencial federada compuesta por el token de identidad provisto por Google OAuth2. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Procesado en AuthenticationController para autenticación SSO. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
VerifyEmailResource & Código OTP numérico de 6 dígitos para validación y activación de cuenta. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Consumido en el endpoint de verificación de correo. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
ForgotPasswordResource & Dirección de correo electrónico receptora del enlace de recuperación de contraseña. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Dispara la generación de token y despacho transaccional por Resend. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
ResetPasswordResource & Token de seguridad y nueva contraseña para restablecimiento de credenciales. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Procesado para la actualización segura de contraseña. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
UpdateTenantProfileResource & Datos modificables de denominación comercial y razón social del taller automotriz. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Consumido en el endpoint de actualización de perfil de taller. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
CreateBranchResource & Datos para apertura de sede: nombre, anexo SUNAT, coordenadas WGS84 y radio. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por CreateBranchCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
UpdateBranchLocationResource & Nuevas coordenadas geográficas y radio en metros para el perímetro de la sede. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Consumido en el endpoint de actualización de geocerca satelital. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
InviteStaffResource & Correo electrónico de destino y rol asignado para invitación de nuevo personal. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por InviteStaffCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
AcceptInvitationResource & Token de invitación, contraseña elegida y datos biográficos del colaborador. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por AcceptInvitationCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
AssignRolesResource & Lista de identificadores de roles concedidos a un colaborador en el taller. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Consumido en el endpoint de asignación de roles. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
CreateRoleResource & Denominación, descripción y conjunto de permisos para un rol personalizado. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por CreateRoleCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
UpdateCompensationResource & Esquema de retribución económica e importe salarial pactado con el colaborador. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Consumido en el endpoint de ajuste de remuneración laboral. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
AuthenticatedUserResource & Token JWT emitido, datos de usuario, taller activo y lista de permisos autorizados. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Retornado tras el inicio de sesión o aceptación de invitación. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
TenantResource & Representación pública inmutable de los datos corporativos de la empresa automotriz. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por TenantResourceFromAggregateAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
TenantSummaryResource & Resumen ligero del taller titular para inclusión en respuestas contextuales. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Incluido dentro de AuthenticatedUserResource. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
BranchResource & Representación inmutable de una sede física, su código SUNAT y geocerca perimetral. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por BranchResourceFromEntityAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
MembershipResource & Ficha contractual del colaborador con datos de usuario, roles y esquema salarial. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por MembershipResourceFromAggregateAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
RoleResource & Definición de rol de seguridad con su indicador de sistema y lista de permisos. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por RoleResourceFromAggregateAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
PermissionResource & Detalle de un permiso atómico con código canónico de recurso y acción. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por PermissionResourceFromEntityAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
InvitationResource & Estado, correo destinatario y marca temporal límite de vigencia de una invitación. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por InvitationResourceFromAggregateAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
InvitationValidationResource & Estado de vigencia de token y metadatos de bienvenida para la interfaz de usuario. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Retornado en la pantalla de pre-registro de colaboradores. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
TenancyContextFacade & Interfaz pública que expone consultas y validaciones de tenencia en memoria. \\*
\hline
\textbf{Categoría} & Fachada de Contexto (OHS) \\*
\hline
\textbf{Relaciones} & Consumida por MRO, CRM, Facturación y Recursos Humanos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
TenancyContextFacadeImpl & Implementación de la fachada que consulta repositorios y evalúa geocercas GPS. \\*
\hline
\textbf{Categoría} & Implementación ACL \\*
\hline
\textbf{Relaciones} & Implementa TenancyContextFacade. desacopla entidades internas. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
TenantCreatedIntegrationEvent & Notificación asíncrona de creación de taller para inicialización en Billing e Invoicing. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. integra con módulos de suscripciones y facturación. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
BranchCreatedIntegrationEvent & Notificación asíncrona de nueva sede física para configuración de bahías y turnos. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. integra con Workshop Operations y HR. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
UserRegisteredIntegrationEvent & Notificación asíncrona de registro de usuario para sincronización con CRM. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. integra con Customer \& Fleet Management. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
TenantMembershipCreatedIntegrationEvent & Notificación asíncrona de nuevo colaborador para apertura de legajo laboral. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. integra con Human Resources Management. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
StaffInvitedIntegrationEvent & Registro de auditoría de invitación emitida para trazabilidad de onboarding. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox para auditoría y monitorización. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
BearerAuthorizationRequestFilter & Filtro web que valida el token JWT e inyecta la autenticación en Spring Security. \\*
\hline
\textbf{Categoría} & Filtro Perimetral \\*
\hline
\textbf{Relaciones} & Extrae claims de usuario, taller y permisos para autorización en memoria. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak filters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
TenantContextResolver & Verificador de frontera que comprueba concordancia entre URL y taller activo. \\*
\hline
\textbf{Categoría} & Validador Perimetral \\*
\hline
\textbf{Relaciones} & Previene accesos horizontales no autorizados entre talleres. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak iam.\allowbreak interfaces.\allowbreak rest.\allowbreak filters} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al paquete canónico com.andeva.atelier.platform.iam.interfaces.

A continuación, se profundiza en la especificación a manera de diccionario de cada una de las clases, ensambladores y controladores que integran esta capa.

**Controladores REST y Endpoints de Comunicación**

La exposición perimetral de servicios HTTP se organiza en seis controladores anotados con `@RestController` y documentados mediante especificaciones OpenAPI 3, distribuyendo responsabilidades operativas claras:

- **AuthenticationController**: Gestiona el ciclo de vida de credenciales y acceso global. Su endpoint `/api/v1/auth/sign-up` procesa el registro fundacional del taller automotriz, coordinando la validación del RUC y la creación simultánea del usuario administrador. Asimismo, provee endpoints para autenticación local (`/sign-in`), inicio de sesión federado con Google OAuth2 (`/google-sign-in`), activación de cuentas mediante código OTP (`/verify-email`) y el flujo de recuperación de contraseñas olvidadas (`/forgot-password` y `/reset-password`) con despacho transaccional a través de la API REST de Resend.

- **TenantsController**: Expone operaciones de administración corporativa para el taller mecánico titular. El endpoint `GET /api/v1/tenants/current` recupera los datos del taller resuelto a partir del contexto del token JWT autenticado, permitiendo que la aplicación cliente cargue la identidad corporativa sin requerir parámetros de consulta superfluos. Por su parte, `PUT /api/v1/tenants/current` permite modificar la denominación comercial y razón social del taller.

- **BranchesController**: Administra las sedes físicas del taller bajo la ruta `/api/v1/tenants/{tenantId}/branches`. Centraliza el alta de nuevas sucursales con su respectivo código de anexo tributario SUNAT, el listado de sedes activas, la consulta detallada por identificador, la actualización de coordenadas satelitales WGS84 con radio de cobertura en metros y la desactivación operativa de locales.

- **MembershipsController**: Modela la administración del personal del taller en `/api/v1/tenants/{tenantId}/memberships`. Ofrece endpoints para listar colaboradores, consultar el detalle de legajos laborales, asignar o revocar roles de seguridad de forma dinámica, renegociar condiciones salariales pactadas y tramitar la desvinculación laboral mediante la desactivación del contrato.

- **InvitationsController**: Conduce el flujo de onboarding digital bajo las rutas `/api/v1/tenants/{tenantId}/invitations` y `/api/v1/invitations/{token}`. Permite que la administración del taller emita invitaciones formales despachadas por correo transaccional, provee la resolución previa del token de invitación para renderizar el formulario de bienvenida en la interfaz de usuario, y procesa la aceptación formal bajo `/api/v1/invitations/{token}/accept` con registro de credenciales y creación inmediata de la membresía.

- **RolesController**: Provee el gobierno de permisos y perfiles de seguridad bajo la ruta `/api/v1/tenants/{tenantId}/roles`. Permite consultar los roles disponibles para el taller (tanto plantillas del sistema como roles a medida), crear roles personalizados seleccionando privilegios específicos y consultar el catálogo transversal de permisos del sistema en `/api/v1/permissions`.

En la @tbl:iam-controllers-and-endpoints se detallan los controladores REST, rutas, verbos HTTP y tipos de respuesta asociados.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\raggedright\arraybackslash}p{6.0cm} | >{\raggedright\arraybackslash}p{9.4cm} |}
\caption{Controladores REST y Endpoints de Comunicación de IAM \& Tenancy} \label{tbl:iam-controllers-and-endpoints} \\
\hline
\thfirst{Recurso de Petición} & \thcell{Código y Respuesta HTTP} \\
\hline
\endfirsthead
\hline
\thfirst{Recurso de Petición} & \thcell{Código y Respuesta HTTP} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} AuthenticationController} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak auth/\allowbreak sign-up}} \\*
\hline
\textbf{Petición:} \texttt{CreateTenantResource} & \textbf{Respuesta:} 201 CREATED (\texttt{TenantResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak auth/\allowbreak sign-in}} \\*
\hline
\textbf{Petición:} \texttt{SignInResource} & \textbf{Respuesta:} 200 OK (\texttt{AuthenticatedUserResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak auth/\allowbreak google-sign-in}} \\*
\hline
\textbf{Petición:} \texttt{GoogleSignInResource} & \textbf{Respuesta:} 200 OK (\texttt{AuthenticatedUserResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak auth/\allowbreak verify-email}} \\*
\hline
\textbf{Petición:} \texttt{VerifyEmailResource} & \textbf{Respuesta:} 200 OK (\texttt{MessageResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak auth/\allowbreak forgot-password}} \\*
\hline
\textbf{Petición:} \texttt{ForgotPasswordResource} & \textbf{Respuesta:} 200 OK (\texttt{MessageResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak auth/\allowbreak reset-password}} \\*
\hline
\textbf{Petición:} \texttt{ResetPasswordResource} & \textbf{Respuesta:} 200 OK (\texttt{MessageResource}) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} TenantsController} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tenants/\allowbreak current}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{TenantResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{PUT} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tenants/\allowbreak current}} \\*
\hline
\textbf{Petición:} \texttt{UpdateTenantProfileResource} & \textbf{Respuesta:} 200 OK (\texttt{TenantResource}) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} BranchesController} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tenants/\allowbreak \{tenantId\}/\allowbreak branches}} \\*
\hline
\textbf{Petición:} \texttt{CreateBranchResource} & \textbf{Respuesta:} 201 CREATED (\texttt{BranchResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tenants/\allowbreak \{tenantId\}/\allowbreak branches}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{List\textless BranchResource\textgreater}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tenants/\allowbreak \{tenantId\}/\allowbreak branches/\allowbreak \{branchId\}}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{BranchResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{PUT} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tenants/\allowbreak \{tenantId\}/\allowbreak branches/\allowbreak \{branchId\}/\allowbreak location}} \\*
\hline
\textbf{Petición:} \texttt{UpdateBranchLocationResource} & \textbf{Respuesta:} 200 OK (\texttt{BranchResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{DELETE} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tenants/\allowbreak \{tenantId\}/\allowbreak branches/\allowbreak \{branchId\}}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 204 NO CONTENT \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} MembershipsController} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tenants/\allowbreak \{tenantId\}/\allowbreak memberships}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{List\textless MembershipResource\textgreater}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tenants/\allowbreak \{tenantId\}/\allowbreak memberships/\allowbreak \{membershipId\}}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{MembershipResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{PUT} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tenants/\allowbreak \{tenantId\}/\allowbreak memberships/\allowbreak \{membershipId\}/\allowbreak roles}} \\*
\hline
\textbf{Petición:} \texttt{AssignRolesResource} & \textbf{Respuesta:} 200 OK (\texttt{MembershipResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{PUT} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tenants/\allowbreak \{tenantId\}/\allowbreak memberships/\allowbreak \{membershipId\}/\allowbreak compensation}} \\*
\hline
\textbf{Petición:} \texttt{UpdateCompensationResource} & \textbf{Respuesta:} 200 OK (\texttt{MembershipResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{DELETE} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tenants/\allowbreak \{tenantId\}/\allowbreak memberships/\allowbreak \{membershipId\}}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 204 NO CONTENT \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} InvitationsController} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tenants/\allowbreak \{tenantId\}/\allowbreak invitations}} \\*
\hline
\textbf{Petición:} \texttt{InviteStaffResource} & \textbf{Respuesta:} 201 CREATED (\texttt{InvitationResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak invitations/\allowbreak \{token\}}} \\*
\hline
\textbf{Petición:} Parámetro en ruta (\texttt{token}) & \textbf{Respuesta:} 200 OK (\texttt{InvitationValidationResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak invitations/\allowbreak \{token\}/\allowbreak accept}} \\*
\hline
\textbf{Petición:} \texttt{AcceptInvitationResource} & \textbf{Respuesta:} 201 CREATED (\texttt{AuthenticatedUserResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{DELETE} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tenants/\allowbreak \{tenantId\}/\allowbreak invitations/\allowbreak \{invitationId\}}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 204 NO CONTENT \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} RolesController} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tenants/\allowbreak \{tenantId\}/\allowbreak roles}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{List\textless RoleResource\textgreater}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak tenants/\allowbreak \{tenantId\}/\allowbreak roles}} \\*
\hline
\textbf{Petición:} \texttt{CreateRoleResource} & \textbf{Respuesta:} 201 CREATED (\texttt{RoleResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak permissions}} \\*
\hline
\textbf{Petición:} Ninguno & \textbf{Respuesta:} 200 OK (\texttt{List\textless PermissionResource\textgreater}) \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Controladores REST ubicados en com.andeva.atelier.platform.iam.interfaces.rest.controllers.

En sus relaciones de colaboración, estos controladores inyectan los servicios de comando y consulta de la Capa de Aplicación, delegando de forma exclusiva la ejecución de la lógica transaccional y empleando ensambladores para desacoplar el transporte web del modelo de dominio interno.

**Recursos DTO de Petición y Respuesta HTTP**

Para impedir la exposición directa de las entidades de persistencia y asegurar la validación sintáctica de las peticiones en el perímetro, la capa define un catálogo de registros inmutables estructurados como objetos de transferencia de datos.

Los recursos de petición se implementan como registros inmutables de Java decorados con anotaciones de Jakarta Bean Validation. Componentes como **CreateTenantResource**, **SignInResource**, **CreateBranchResource** e **InviteStaffResource** validan de forma defensiva la no nulidad de cadenas, la sintaxis de correos bajo la RFC 5322, la estructura numérica del RUC fiscal y longitudes de contraseña antes de alcanzar los servicios de aplicación.

Por su parte, los recursos de respuesta encapsulan las cargas útiles entregadas a los clientes web y móviles mediante estructuras inmutables. Destacan **AuthenticatedUserResource**, portador del token Bearer JWT y autoridades de seguridad; **TenantResource** y **BranchResource**, que exponen los datos corporativos y de geocercas satelitales; y **MembershipResource**, que consolida la ficha contractual del colaborador en el taller.

En la @tbl:iam-resources-dtos se especifican los atributos y restricciones de validación de estos recursos DTO.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Recursos DTO de Entrada y Salida del Bounded Context IAM \& Tenancy} \label{tbl:iam-resources-dtos} \\
\hline
\thfirst{Aspecto de Recurso} & \thcell{Especificación de Atributos e Integridad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Recurso} & \thcell{Especificación de Atributos e Integridad} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} CreateTenantResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{name}, \texttt{legalName}, \texttt{taxId}, \texttt{adminEmail}, \texttt{adminPassword}, \texttt{adminPhone} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank}, \texttt{@Email}, \texttt{@Pattern} para RUC y \texttt{@Size(min = 8)}. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} SignInResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{email}, \texttt{password} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank} y \texttt{@Email}. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} GoogleSignInResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{idToken} \\*
\hline
\textbf{Validación de Integridad} & Anotación \texttt{@NotBlank}. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} VerifyEmailResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{token} \\*
\hline
\textbf{Validación de Integridad} & Anotación \texttt{@NotBlank} con patrón numérico de 6 dígitos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} ForgotPasswordResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{email} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank} y \texttt{@Email}. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} ResetPasswordResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{token}, \texttt{newPassword} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank} y \texttt{@Size(min = 8)}. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} UpdateTenantProfileResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{name}, \texttt{legalName} \\*
\hline
\textbf{Validación de Integridad} & Anotación \texttt{@NotBlank} en ambas propiedades. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} CreateBranchResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{name}, \texttt{sunatCode}, \texttt{latitude}, \texttt{longitude}, \texttt{geofenceRadiusMeters} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank}, código SUNAT de 4 dígitos y radio mayor o igual a 10. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} UpdateBranchLocationResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{latitude}, \texttt{longitude}, \texttt{geofenceRadiusMeters} \\*
\hline
\textbf{Validación de Integridad} & Coordenadas no nulas y radio mayor o igual a 10 metros. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} InviteStaffResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{email}, \texttt{roleId} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank}, \texttt{@Email} y \texttt{@NotNull} para el rol. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} AcceptInvitationResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{token}, \texttt{password}, \texttt{firstName}, \texttt{lastName}, \texttt{phone} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank}, \texttt{@Size(min = 8)} y formato telefónico. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} AssignRolesResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{roleIds} \\*
\hline
\textbf{Validación de Integridad} & Anotación \texttt{@NotEmpty} para la lista de roles asignados. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} CreateRoleResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{name}, \texttt{description}, \texttt{permissionIds} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank} y \texttt{@NotEmpty} para el conjunto de permisos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} UpdateCompensationResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{salaryType}, \texttt{baseSalary}, \texttt{currency} \\*
\hline
\textbf{Validación de Integridad} & Esquema salarial válido e importe numérico mayor o igual a cero. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} AuthenticatedUserResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{userId}, \texttt{email}, \texttt{fullName}, \texttt{token}, \texttt{tokenType}, \texttt{activeTenant}, \texttt{permissions} \\*
\hline
\textbf{Validación de Integridad} & Serialización inmutable JSON con encabezados de autorización. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} TenantResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{name}, \texttt{legalName}, \texttt{taxId}, \texttt{status}, \texttt{stripeCustomerId}, \texttt{createdAt} \\*
\hline
\textbf{Validación de Integridad} & Representación pública del taller mecánico. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} BranchResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{tenantId}, \texttt{name}, \texttt{sunatCode}, \texttt{latitude}, \texttt{longitude}, \texttt{geofenceRadiusMeters}, \texttt{isActive} \\*
\hline
\textbf{Validación de Integridad} & Representación de sede física y geocerca satelital. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} MembershipResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{tenantId}, \texttt{userId}, \texttt{employeeName}, \texttt{email}, \texttt{status}, \texttt{salaryType}, \texttt{baseSalary}, \texttt{roles} \\*
\hline
\textbf{Validación de Integridad} & Ficha laboral y contractual del colaborador. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} RoleResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{name}, \texttt{description}, \texttt{isSystemRole}, \texttt{permissions} \\*
\hline
\textbf{Validación de Integridad} & Definición de rol y privilegios concedidos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} PermissionResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{name}, \texttt{description}, \texttt{resource}, \texttt{action} \\*
\hline
\textbf{Validación de Integridad} & Detalle atómico del permiso de seguridad. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} InvitationResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{tenantId}, \texttt{email}, \texttt{status}, \texttt{expiresAt} \\*
\hline
\textbf{Validación de Integridad} & Estado y vigencia de la invitación de personal. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes ubicados en el paquete com.andeva.atelier.platform.iam.interfaces.rest.resources.

**Ensambladores y Transformadores de Recursos**

El desacoplamiento entre las peticiones HTTP y los casos de uso transaccionales se materializa a través de ensambladores bidireccionales. Los ensambladores de entrada, tales como **CreateTenantCommandFromResourceAssembler** y **SignInCommandFromResourceAssembler**, extraen los valores de los registros DTO y construyen los comandos inmutables correspondientes, inyectando identificadores de ruta cuando corresponde.

De forma complementaria, los ensambladores de salida traducen las raíces de agregado y entidades del dominio hacia representaciones DTO públicas. Componentes como **TenantResourceFromAggregateAssembler**, **BranchResourceFromEntityAssembler** y **MembershipResourceFromAggregateAssembler** formatean los datos del negocio, mientras que **AuthenticatedUserResourceAssembler** integra el token criptográfico emitido y el catálogo de permisos concedidos.

En la @tbl:iam-resource-assemblers se detallan los métodos y tipos de transformación ejecutados por estos ensambladores.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.1cm} | >{\raggedright\arraybackslash}p{10.3cm} |}
\caption{Ensambladores de Recursos del Bounded Context IAM \& Tenancy} \label{tbl:iam-resource-assemblers} \\
\hline
\thfirst{Aspecto del Ensamblador} & \thcell{Firma y Transformación de Tipos} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Ensamblador} & \thcell{Firma y Transformación de Tipos} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} CreateTenantCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{CreateTenantResource} $\longrightarrow$ \texttt{CreateTenantCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} SignInCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{SignInResource} $\longrightarrow$ \texttt{AuthenticateUserCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} CreateBranchCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{CreateBranchResource,\allowbreak  UUID} $\longrightarrow$ \texttt{CreateBranchCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} UpdateBranchLocationCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{UpdateBranchLocationResource,\allowbreak  UUID} $\longrightarrow$ \texttt{UpdateBranchLocationCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} InviteStaffCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{InviteStaffResource,\allowbreak  UUID} $\longrightarrow$ \texttt{InviteStaffCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} AcceptInvitationCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{AcceptInvitationResource} $\longrightarrow$ \texttt{AcceptInvitationCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} CreateRoleCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{CreateRoleResource,\allowbreak  UUID} $\longrightarrow$ \texttt{CreateRoleCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} UpdateCompensationCommandFromResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{UpdateCompensationResource,\allowbreak  UUID} $\longrightarrow$ \texttt{UpdateCompensationCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} TenantResourceFromAggregateAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResourceFromAggregate} \\*
\hline
\textbf{Transformación} & \texttt{Tenant} $\longrightarrow$ \texttt{TenantResource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} BranchResourceFromEntityAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResourceFromEntity} \\*
\hline
\textbf{Transformación} & \texttt{Branch} $\longrightarrow$ \texttt{BranchResource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} MembershipResourceFromAggregateAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResourceFromAggregate} \\*
\hline
\textbf{Transformación} & \texttt{TenantMembership,\allowbreak  User} $\longrightarrow$ \texttt{MembershipResource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} RoleResourceFromAggregateAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResourceFromAggregate} \\*
\hline
\textbf{Transformación} & \texttt{Role} $\longrightarrow$ \texttt{RoleResource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} PermissionResourceFromEntityAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResourceFromEntity} \\*
\hline
\textbf{Transformación} & \texttt{Permission} $\longrightarrow$ \texttt{PermissionResource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} InvitationResourceFromAggregateAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResourceFromAggregate} \\*
\hline
\textbf{Transformación} & \texttt{Invitation} $\longrightarrow$ \texttt{InvitationResource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} AuthenticatedUserResourceAssembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResource} \\*
\hline
\textbf{Transformación} & \texttt{User,\allowbreak  Tenant,\allowbreak  String,\allowbreak  List<\allowbreak String>\allowbreak } $\longrightarrow$ \texttt{AuthenticatedUserResource} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Clases ubicadas bajo el paquete com.andeva.atelier.platform.iam.interfaces.rest.transform.

**Fachada de Contexto Abierto (Open Host Service / Inbound ACL)**

Para preservar la pureza del modelo de dominio de IAM y evitar acoplamientos circulares con otros bounded contexts de la plataforma, la capa de interfaz implementa el patrón Open Host Service complementado con una Capa Anticorrupción de entrada.

Este patrón se materializa en la interfaz **TenancyContextFacade**, ubicada en el paquete canónico **com.andeva.atelier.platform.iam.interfaces.acl**. Esta fachada define contratos públicos en memoria para que módulos consumidores como MRO, CRM, Facturación y Recursos Humanos consulten datos de talleres, validen la vigencia de membresías de mecánicos o evalúen la proximidad de coordenadas GPS respecto a la geocerca de una sede física mediante la formulación del Haversine sin acceder a entidades JPA.

La implementación **TenancyContextFacadeImpl** delega estas consultas en los servicios de aplicación de IAM y transforma los resultados en registros inmutables de frontera, tales como **TenantAclDto**, **BranchAclDto**, **UserAclDto** y **BranchGeofenceAclDto**, asegurando un aislamiento total entre contextos.

En la @tbl:iam-tenancy-facade se especifican los métodos y tipos de la fachada de contexto abierto.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Métodos de la Fachada de Contexto Abierto TenancyContextFacade} \label{tbl:iam-tenancy-facade} \\
\hline
\thfirst{Aspecto del Contrato} & \thcell{Firma, Retorno y Consumidores} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Contrato} & \thcell{Firma, Retorno y Consumidores} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{fetchTenantById}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID tenantId} $\longrightarrow$ \texttt{Optional<\allowbreak TenantAclDto>\allowbreak } \\*
\hline
\textbf{Módulos Consumidores} & Invoicing, Billing, MRO \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{fetchBranchById}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID branchId} $\longrightarrow$ \texttt{Optional<\allowbreak BranchAclDto>\allowbreak } \\*
\hline
\textbf{Módulos Consumidores} & Workshop Operations (MRO), Inventory \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{fetchUserById}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID userId} $\longrightarrow$ \texttt{Optional<\allowbreak UserAclDto>\allowbreak } \\*
\hline
\textbf{Módulos Consumidores} & CRM, Human Resources, Notifications \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{validateTenantMembership}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID tenantId,\allowbreak  UUID userId} $\longrightarrow$ \texttt{boolean} \\*
\hline
\textbf{Módulos Consumidores} & Human Resources, MRO, Inventory \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{fetchUserPermissionsInTenant}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID tenantId,\allowbreak  UUID userId} $\longrightarrow$ \texttt{List<\allowbreak String>\allowbreak } \\*
\hline
\textbf{Módulos Consumidores} & Security Filter, MRO, Human Resources \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{fetchBranchGeofence}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID branchId} $\longrightarrow$ \texttt{Optional<\allowbreak BranchGeofenceAclDto>\allowbreak } \\*
\hline
\textbf{Módulos Consumidores} & Human Resources (Marcación de asistencia) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{isPointWithinBranchGeofence}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID branchId,\allowbreak  Double lat,\allowbreak  Double lng} $\longrightarrow$ \texttt{boolean} \\*
\hline
\textbf{Módulos Consumidores} & Human Resources (Control presencial móvil) \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al paquete com.andeva.atelier.platform.iam.interfaces.acl.

**Eventos de Integración (Published Language)**

Para la sincronización asíncrona intermodular sin incurrir en consistencia transaccional inmediata ni bloqueos de concurrencia, el Bounded Context IAM define un lenguaje publicado compuesto por cinco eventos de integración inmutables.

Dichos eventos notifican hitos relevantes del ciclo de vida: **TenantCreatedIntegrationEvent** y **BranchCreatedIntegrationEvent** permiten a Facturación, Suscripciones y Operaciones inicializar catálogos y bahías; **UserRegisteredIntegrationEvent** sincroniza fichas vehiculares en CRM; y **TenantMembershipCreatedIntegrationEvent** apertura el legajo laboral en Recursos Humanos para el control de asistencia presencial.

En la @tbl:iam-integration-events se sintetiza la estructura de estos eventos de integración.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Eventos de Integración del Bounded Context IAM \& Tenancy} \label{tbl:iam-integration-events} \\
\hline
\thfirst{Aspecto de Integración} & \thcell{Carga Útil y Sincronización Intermodular} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Integración} & \thcell{Carga Útil y Sincronización Intermodular} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} TenantCreatedIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{tenantId}, \texttt{name}, \texttt{legalName}, \texttt{taxId}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Billing, Invoicing \\*
\hline
\textbf{Propósito} & Provisión de cuenta SaaS e inicialización de configuración fiscal. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} BranchCreatedIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{branchId}, \texttt{tenantId}, \texttt{name}, \texttt{sunatCode}, \texttt{lat}, \texttt{lng}, \texttt{radius} \\*
\hline
\textbf{Módulos Receptores} & MRO, Human Resources \\*
\hline
\textbf{Propósito} & Habilitación de bahías operativas y turnos presenciales de trabajo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} UserRegisteredIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{userId}, \texttt{email}, \texttt{fullName}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & CRM \\*
\hline
\textbf{Propósito} & Alta automática del perfil de cliente para conductores particulares. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} TenantMembershipCreatedIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{membershipId}, \texttt{tenantId}, \texttt{userId}, \texttt{roleNames}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Human Resources \\*
\hline
\textbf{Propósito} & Apertura del legajo laboral del mecánico y control de asistencia. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} StaffInvitedIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{invitationId}, \texttt{tenantId}, \texttt{email}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Auditoría de Seguridad \\*
\hline
\textbf{Propósito} & Trazabilidad del flujo de incorporación y bienvenida de personal. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Registros inmutables pertenecientes al paquete com.andeva.atelier.platform.iam.interfaces.events.

**Filtros Perimetrales de Seguridad y Validación Multi-Tenant**

La protección perimetral del ecosistema Atelier se ejecuta antes de que las solicitudes alcancen los controladores web, gobernada por dos filtros de seguridad especializados.

El componente **BearerAuthorizationRequestFilter** extiende de `OncePerRequestFilter` y valida criptográficamente los tokens JWT mediante la biblioteca Jjwt. Al verificar la firma, extrae los identificadores de usuario, taller, sucursal y la lista de autoridades concedidas, inyectando la autenticación en el **SecurityContextHolder** para posibilitar autorizaciones en memoria con coste temporal constante.

Por su parte, el filtro **TenantContextResolver** comprueba que el identificador de taller especificado en rutas relativas de tipo `/api/v1/tenants/{tenantId}/**` concuerde estrictamente con el inquilino activo autenticado en el token JWT. Esta validación perimetral neutraliza de forma preventiva ataques de escalamiento horizontal entre talleres mecánicos independientes.

En la @tbl:iam-security-filters se especifican los métodos y reglas de estos componentes perimetrales de seguridad.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Filtros Perimetrales de Seguridad de IAM \& Tenancy} \label{tbl:iam-security-filters} \\
\hline
\thfirst{Aspecto del Filtro} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Filtro} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Filtro Perimetral:} BearerAuthorizationRequestFilter \quad (\textit{Tipo:} OncePerRequestFilter)} \\*
\hline
\textbf{Orden de Ejecución} & Filtro de Seguridad perimetral \\*
\hline
\textbf{Responsabilidad} & Valida firma JWT, extrae claims de tenencia y pobla el SecurityContext. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Filtro Perimetral:} TenantContextResolver \quad (\textit{Tipo:} OncePerRequestFilter)} \\*
\hline
\textbf{Orden de Ejecución} & Previo a controladores REST \\*
\hline
\textbf{Responsabilidad} & Verifica coincidencia entre tenantId de ruta y taller autenticado en JWT. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al paquete com.andeva.atelier.platform.iam.interfaces.rest.filters.

#### 2.6.2.3. Application Layer

La capa de aplicación del Bounded Context de Identity and Access Management (IAM) &
Tenancy orquesta los casos de uso transaccionales de alta empresarial, autenticación y
credenciales, administración de sedes físicas, membresías de personal, invitaciones y
roles de seguridad en la plataforma Atelier.

Ubicada en el paquete canónico com.andeva.atelier.platform.iam.application, su concepción
arquitectónica implementa una separación rigurosa bajo el patrón CQRS, desacoplando los
flujos mutacionales de escritura de las proyecciones de solo lectura a través de cuatro
directrices esenciales de diseño:

- **Orquestación Transaccional Atómica:** Delimitación de fronteras de consistencia
mediante la anotación de servicio transaccional con nivel de aislamiento de lectura
confirmada. Esta estrategia asegura atomicidad estricta en operaciones multiorigen
complejas que integran el aprovisionamiento coordinado de taller, sucursal inicial, cuenta
administradora y membresía de empleo.

- **Flujo Determinista sin Excepciones:** Adopción del tipo de resultado sellado
**Result<T, ApplicationError>** para gobernar las respuestas de los casos de uso. Las
condiciones de fallo previsibles vinculadas a colisiones de identificador tributario o
credenciales inválidas se tratan como valores inmutables de retorno, imponiendo
verificación exhaustiva mediante coincidencia de patrones.

- **Coreografía de Eventos de Dominio e Integración:** Manejo dual de eventos mediante
oyentes locales para tareas accesorias sincrónicas y oyentes posteriores a la confirmación
transaccional para la propagación de eventos de integración hacia el Transactional Outbox,
evitando inconsistencias entre la base de datos y la mensajería asíncrona.

- **Inversión de Dependencias y Aislamiento Perimetral:** Abstracción de servicios de
infraestructura externos mediante puertos de salida específicos para mensajería
transaccional vía HTTPS, validación de identidades federadas, derivación criptográfica de
contraseñas y emisión de tokens de seguridad enriquecidos.

A fin de ofrecer una visión sistemática de estos componentes, en la
@tbl:iam-application-types se presenta el catálogo consolidado de las clases, interfaces y
registros que estructuran la Capa de Aplicación de IAM & Tenancy.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo Consolidado de la Capa de Aplicación de IAM \& Tenancy} \label{tbl:iam-application-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endhead
TenantCommandService & Contrato de casos de uso de escritura para talleres y sedes. \\*
\hline
\textbf{Categoría} & Servicio de Comando \\*
\hline
\textbf{Relaciones} & Implementado por TenantCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{...application.services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
TenantCommandServiceImpl & Orquesta la creación atómica de empresas, sedes iniciales y perfiles. \\*
\hline
\textbf{Categoría} & Implementación de Comando \\*
\hline
\textbf{Relaciones} & Coordina agregados Tenant y User con persistencia ACID. \\*
\hline
\textbf{Paquete} & \texttt{...application.services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
UserCommandService & Contrato de casos de uso para autenticación, registro y contraseñas. \\*
\hline
\textbf{Categoría} & Servicio de Comando \\*
\hline
\textbf{Relaciones} & Implementado por UserCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{...application.services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
UserCommandServiceImpl & Ejecuta validación de credenciales, derivación criptográfica y tokens. \\*
\hline
\textbf{Categoría} & Implementación de Comando \\*
\hline
\textbf{Relaciones} & Utiliza BCryptHashingService y BearerTokenService. \\*
\hline
\textbf{Paquete} & \texttt{...application.services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
BranchCommandService & Contrato para incorporación y actualización de sedes físicas. \\*
\hline
\textbf{Categoría} & Servicio de Comando \\*
\hline
\textbf{Relaciones} & Implementado por BranchCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{...application.services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
BranchCommandServiceImpl & Gestiona geocercas satelitales y códigos anexos de sucursales. \\*
\hline
\textbf{Categoría} & Implementación de Comando \\*
\hline
\textbf{Relaciones} & Modifica la colección interna de sedes en Tenant. \\*
\hline
\textbf{Paquete} & \texttt{...application.services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
MembershipCommandService & Contrato para gestión laboral y esquemas remunerativos. \\*
\hline
\textbf{Categoría} & Servicio de Comando \\*
\hline
\textbf{Relaciones} & Implementado por MembershipCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{...application.services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
MembershipCommandServiceImpl & Actualiza roles y condiciones contractuales de colaboradores. \\*
\hline
\textbf{Categoría} & Implementación de Comando \\*
\hline
\textbf{Relaciones} & Coordina agregados TenantMembership y Role. \\*
\hline
\textbf{Paquete} & \texttt{...application.services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
InvitationCommandService & Contrato de onboarding y bienvenida de nuevos colaboradores. \\*
\hline
\textbf{Categoría} & Servicio de Comando \\*
\hline
\textbf{Relaciones} & Implementado por InvitationCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{...application.services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
InvitationCommandServiceImpl & Emite y valida tokens de invitación despachados por correo. \\*
\hline
\textbf{Categoría} & Implementación de Comando \\*
\hline
\textbf{Relaciones} & Interactúa con ResendEmailService y emite eventos. \\*
\hline
\textbf{Paquete} & \texttt{...application.services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
RoleCommandService & Contrato para administración de roles y privilegios RBAC. \\*
\hline
\textbf{Categoría} & Servicio de Comando \\*
\hline
\textbf{Relaciones} & Implementado por RoleCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{...application.services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
RoleCommandServiceImpl & Configura roles por taller y realiza el semillero inicial del sistema. \\*
\hline
\textbf{Categoría} & Implementación de Comando \\*
\hline
\textbf{Relaciones} & Administra entidades Role y Permission. \\*
\hline
\textbf{Paquete} & \texttt{...application.services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
TenantQueryService & Contrato de recuperación de datos de talleres mecánicos. \\*
\hline
\textbf{Categoría} & Servicio de Consulta \\*
\hline
\textbf{Relaciones} & Implementado por TenantQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{...application.services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
TenantQueryServiceImpl & Consultas de lectura optimizada de empresas y razones sociales. \\*
\hline
\textbf{Categoría} & Implementación de Consulta \\*
\hline
\textbf{Relaciones} & Accede a TenantRepository en modo de solo lectura. \\*
\hline
\textbf{Paquete} & \texttt{...application.services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
UserQueryService & Contrato de búsqueda y proyección de cuentas de usuario. \\*
\hline
\textbf{Categoría} & Servicio de Consulta \\*
\hline
\textbf{Relaciones} & Implementado por UserQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{...application.services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
UserQueryServiceImpl & Consultas de identidad por identificador único o correo canónico. \\*
\hline
\textbf{Categoría} & Implementación de Consulta \\*
\hline
\textbf{Relaciones} & Accede a UserRepository en modo de solo lectura. \\*
\hline
\textbf{Paquete} & \texttt{...application.services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
BranchQueryService & Contrato de consulta de sucursales y geocercas activas. \\*
\hline
\textbf{Categoría} & Servicio de Consulta \\*
\hline
\textbf{Relaciones} & Implementado por BranchQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{...application.services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
BranchQueryServiceImpl & Recupera listados y detalles de sedes físicas por taller. \\*
\hline
\textbf{Categoría} & Implementación de Consulta \\*
\hline
\textbf{Relaciones} & Accede a BranchRepository en modo de solo lectura. \\*
\hline
\textbf{Paquete} & \texttt{...application.services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
MembershipQueryService & Contrato de lectura de contratos y personal del taller. \\*
\hline
\textbf{Categoría} & Servicio de Consulta \\*
\hline
\textbf{Relaciones} & Implementado por MembershipQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{...application.services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
MembershipQueryServiceImpl & Proyecta listas de colaboradores, roles asignados y compensación. \\*
\hline
\textbf{Categoría} & Implementación de Consulta \\*
\hline
\textbf{Relaciones} & Accede a TenantMembershipRepository de solo lectura. \\*
\hline
\textbf{Paquete} & \texttt{...application.services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
RoleQueryService & Contrato de consulta de catálogo de roles y permisos. \\*
\hline
\textbf{Categoría} & Servicio de Consulta \\*
\hline
\textbf{Relaciones} & Implementado por RoleQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{...application.services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
RoleQueryServiceImpl & Consulta roles configurados y catálogo transversal de permisos. \\*
\hline
\textbf{Categoría} & Implementación de Consulta \\*
\hline
\textbf{Relaciones} & Accede a RoleRepository y PermissionRepository. \\*
\hline
\textbf{Paquete} & \texttt{...application.services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
InvitationQueryService & Contrato de verificación de tokens y solicitudes de onboarding. \\*
\hline
\textbf{Categoría} & Servicio de Consulta \\*
\hline
\textbf{Relaciones} & Implementado por InvitationQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{...application.services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
InvitationQueryServiceImpl & Comprueba vigencia y datos de invitaciones emitidas. \\*
\hline
\textbf{Categoría} & Implementación de Consulta \\*
\hline
\textbf{Relaciones} & Accede a InvitationRepository en modo de solo lectura. \\*
\hline
\textbf{Paquete} & \texttt{...application.services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
UserDomainEventsHandler & Suscriptor en memoria de eventos emitidos por usuarios. \\*
\hline
\textbf{Categoría} & Manejador de Eventos \\*
\hline
\textbf{Relaciones} & Despacha notificaciones de correo mediante Resend. \\*
\hline
\textbf{Paquete} & \texttt{...application.events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
TenantDomainEventsHandler & Suscriptor de ciclo de vida corporativo y publicación Outbox. \\*
\hline
\textbf{Categoría} & Manejador de Eventos \\*
\hline
\textbf{Relaciones} & Transforma eventos locales a eventos de integración. \\*
\hline
\textbf{Paquete} & \texttt{...application.events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
ResendEmailService & Interfaz para el despacho transaccional de correos vía REST HTTPS. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Implementado en la Capa de Infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{...application.acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
GoogleIdentityGateway & Interfaz para validación de firmas de identidad federada OAuth2. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Consumido por casos de uso de inicio de sesión social. \\*
\hline
\textbf{Paquete} & \texttt{...application.acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
BearerTokenService & Interfaz para generación y extracción de tokens JWT enriquecidos. \\*
\hline
\textbf{Categoría} & Servicio de Seguridad \\*
\hline
\textbf{Relaciones} & Inyecta identificadores de tenencia y autoridades. \\*
\hline
\textbf{Paquete} & \texttt{...application.acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
BCryptHashingService & Interfaz para derivación y confrontación segura de contraseñas. \\*
\hline
\textbf{Categoría} & Servicio Criptográfico \\*
\hline
\textbf{Relaciones} & Aplica funciones criptográficas de derivación de claves. \\*
\hline
\textbf{Paquete} & \texttt{...application.acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
AuthenticatedUser & Registro inmutable de sesión que agrupa usuario, token y permisos. \\*
\hline
\textbf{Categoría} & Modelo de Sesión \\*
\hline
\textbf{Relaciones} & Entregado como resultado exitoso de autenticación. \\*
\hline
\textbf{Paquete} & \texttt{...application.model} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
GoogleUserPayload & Registro con datos biográficos extraídos de credenciales federadas. \\*
\hline
\textbf{Categoría} & Modelo de Identidad \\*
\hline
\textbf{Relaciones} & Utilizado en aprovisionamiento de cuentas federadas. \\*
\hline
\textbf{Paquete} & \texttt{...application.model} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes implementados en Java 26 bajo el paquete canónico com.andeva.atelier.platform.iam.application.

**Servicios de Comandos y Orquestación Transaccional**

Los flujos de modificación de estado se implementan mediante servicios orquestadores
decorados con anotaciones transaccionales que delimitan el alcance de persistencia y
garantizan el cumplimiento de invariantes de negocio en el modelo.

El servicio **TenantCommandServiceImpl** centraliza el caso de uso de alta integral de
talleres mecánicos. Al procesar el comando **CreateTenantCommand**, el orquestador valida
la disponibilidad del Registro Único de Contribuyentes y del correo electrónico antes de
instanciar entidades en el dominio automotriz.

Posteriormente, cifra la contraseña administrativa mediante **BCryptHashingService**,
instancia la raíz de agregado **User** junto a su entidad **Profile**, construye el
agregado **Tenant** asociando su sede principal inicial con código de anexo tributario
SUNAT y genera la membresía laboral vinculante con el rol de administración de taller.

De manera análoga, **BranchCommandServiceImpl** coordina la incorporación de sedes
operativas mediante **CreateBranchCommand**, asegurando que las coordenadas geográficas
WGS84 y el radio de cobertura satelital satisfagan las reglas de proximidad antes de mutar
la colección interna de sucursales del taller mecánico.

En el ámbito de la identidad, **UserCommandServiceImpl** gestiona el ciclo de vida de
credenciales. Administra el registro de usuarios con despacho de códigos de un solo uso,
la autenticación local validando resúmenes criptográficos y el inicio de sesión federado
mediante el componente **GoogleIdentityGateway**.

Asimismo, orquesta la emisión de tokens enriquecidos con tenencia y permisos, la
confirmación de correos electrónicos y la renovación de contraseñas. Por su parte,
**MembershipCommandServiceImpl** e **InvitationCommandServiceImpl** regulan el vínculo
contractual de los colaboradores del taller mecánico.

Dichos servicios gobiernan la asignación de roles de seguridad, la actualización de
esquemas de remuneración fija o por horas y la emisión de invitaciones tokenizadas con
plazo de expiración de siete días. Finalmente, **RoleCommandServiceImpl** respalda la
creación de roles personalizados y ejecuta la inicialización canónica de permisos.

Para sintetizar los flujos mutacionales, en la @tbl:iam-command-services se detallan las
operaciones, comandos de entrada, invariantes de consistencia transaccional y tipos de
retorno de los servicios de comandos.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Operaciones Transaccionales de los Servicios de Comandos de IAM \& Tenancy} \label{tbl:iam-command-services} \\
\hline
\thfirst{Aspecto de Operación} & \thcell{Especificación de Orquestación y Consistencia} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Operación} & \thcell{Especificación de Orquestación y Consistencia} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} TenantCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{CreateTenantCommand} $\longrightarrow$ \texttt{Result<\allowbreak Tenant,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida RUC y email únicos. crea User, Tenant, Sede 0000 y asigna rol de taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} TenantCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{UpdateTenantProfileCommand} $\longrightarrow$ \texttt{Result<\allowbreak Tenant,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Verifica existencia del taller. actualiza razón social y nombre comercial. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} TenantCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{SuspendTenantCommand} $\longrightarrow$ \texttt{Result<\allowbreak Tenant,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Transiciona estado a suspendido e inhabilita acceso a colaboradores. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} BranchCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{CreateBranchCommand} $\longrightarrow$ \texttt{Result<\allowbreak Branch,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida código SUNAT no repetido. agrega sede con geocerca satelital. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} BranchCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{UpdateBranchLocationCommand} $\longrightarrow$ \texttt{Result<\allowbreak Branch,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Actualiza coordenadas WGS84 y radio en metros para el control de asistencia. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} UserCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{RegisterUserCommand} $\longrightarrow$ \texttt{Result<\allowbreak User,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida correo disponible. emite token OTP numérico de seis dígitos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} UserCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{AuthenticateUserCommand} $\longrightarrow$ \texttt{Result<\allowbreak AuthenticatedUser,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida hash BCrypt. resuelve tenencia activa y genera token Bearer JWT. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} UserCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{AuthenticateWithGoogleCommand} $\longrightarrow$ \texttt{Result<\allowbreak AuthenticatedUser,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida firma del token con Google. aprovisiona cuenta si es nueva y emite JWT. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} UserCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{VerifyEmailTokenCommand} $\longrightarrow$ \texttt{Result<\allowbreak Void,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida código OTP vigente. transiciona estado de cuenta a verificado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} UserCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{RequestPasswordResetCommand} $\longrightarrow$ \texttt{Result<\allowbreak Void,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Genera token criptográfico de reseteo con caducidad de dos horas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} UserCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{ResetPasswordCommand} $\longrightarrow$ \texttt{Result<\allowbreak Void,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida token de reseteo. actualiza el resumen criptográfico de clave. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} MembershipCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{AssignRoleToMembershipCommand} $\longrightarrow$ \texttt{Result<\allowbreak TenantMembership,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Verifica pertenencia de roles al taller. garantiza al menos un rol asignado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} MembershipCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{UpdateMembershipCompensationCommand} $\longrightarrow$ \texttt{Result<\allowbreak TenantMembership,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida importe mayor o igual a cero. actualiza esquema salarial fijo o por hora. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} InvitationCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{InviteStaffCommand} $\longrightarrow$ \texttt{Result<\allowbreak Invitation,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Comprueba ausencia de invitación pendiente. genera token URL de siete días. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} InvitationCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{AcceptInvitationCommand} $\longrightarrow$ \texttt{Result<\allowbreak AuthenticatedUser,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida token vigente. crea cuenta User, membresía en taller y sesión JWT. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} RoleCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{CreateCustomRoleCommand} $\longrightarrow$ \texttt{Result<\allowbreak Role,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida unicidad de nombre en el taller. enlaza permisos del catálogo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} RoleCommandService \quad (\texttt{seedDefaultRolesAndPermissions})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{Ninguno} $\longrightarrow$ \texttt{void} \\*
\hline
\textbf{Reglas de Consistencia} & Inicializa roles canónicos globales y matriz de privilegios en el arranque. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes ubicados en el paquete com.andeva.atelier.platform.iam.application.services.

**Servicios de Consulta y Proyección de Datos**

Las operaciones de recuperación de información se estructuran mediante servicios de
consulta especializados anotados con transaccionalidad de solo lectura, permitiendo a la
infraestructura relacional omitir la gestión de instantáneas de detección de cambios.

Los seis servicios de consulta abarcan la totalidad de requerimientos del contexto:
**TenantQueryServiceImpl** recupera fichas corporativas por identificador o RUC;
**UserQueryServiceImpl** provee consultas demográficas y de credenciales; mientras que
**BranchQueryServiceImpl** lista las sedes físicas y geocercas satelitales.

De forma complementaria, **MembershipQueryServiceImpl** consolida el legajo de personal y
esquemas remunerativos; **RoleQueryServiceImpl** expone la matriz de privilegios de
seguridad; e **InvitationQueryServiceImpl** valida la vigencia de solicitudes de
onboarding previas a la visualización del formulario web de registro.

Con el propósito de ilustrar las vías de recuperación de datos, en la
@tbl:iam-query-services se presentan los métodos, parámetros de consulta y tipos
proyectados por los servicios de consulta.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Métodos de Consulta de la Capa de Aplicación de IAM \& Tenancy} \label{tbl:iam-query-services} \\
\hline
\thfirst{Aspecto de Consulta} & \thcell{Especificación Técnica y Recuperación} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Consulta} & \thcell{Especificación Técnica y Recuperación} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} TenantQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetTenantByIdQuery} $\longrightarrow$ \texttt{Optional<\allowbreak Tenant>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Consulta de ficha de taller mecánico por identificador universal. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} TenantQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetTenantByTaxIdQuery} $\longrightarrow$ \texttt{Optional<\allowbreak Tenant>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Verificación previa de RUC tributario ante registros de empresas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} UserQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetUserByIdQuery} $\longrightarrow$ \texttt{Optional<\allowbreak User>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Proyección de datos biográficos y estado de cuenta de usuario. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} UserQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetUserByEmailQuery} $\longrightarrow$ \texttt{Optional<\allowbreak User>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Búsqueda canónica de usuario para validación de acceso. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} BranchQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetBranchByIdQuery} $\longrightarrow$ \texttt{Optional<\allowbreak Branch>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Detalle operativo y límites satelitales de una sede específica. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} BranchQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetBranchesByTenantIdQuery} $\longrightarrow$ \texttt{List<\allowbreak Branch>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Listado completo de sedes físicas administradas por el taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} MembershipQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetMembershipByIdQuery} $\longrightarrow$ \texttt{Optional<\allowbreak TenantMembership>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Ficha contractual individual del colaborador en el taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} MembershipQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetMembershipsByTenantIdQuery} $\longrightarrow$ \texttt{List<\allowbreak TenantMembership>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Nómina completa del personal laboral asignado a la empresa. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} MembershipQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetMembershipByTenantAndUserQuery} $\longrightarrow$ \texttt{Optional<\allowbreak TenantMembership>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Resolución de afiliación activa para autorización perimetral. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} RoleQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetRolesByTenantIdQuery} $\longrightarrow$ \texttt{List<\allowbreak Role>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Catálogo de roles configurados para el esquema RBAC del taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} RoleQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetAllPermissionsQuery} $\longrightarrow$ \texttt{List<\allowbreak Permission>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Listado transversal de privilegios del sistema para asignación. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} InvitationQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetInvitationByTokenQuery} $\longrightarrow$ \texttt{Optional<\allowbreak Invitation>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Validación de vigencia de token de onboarding para registro web. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Métodos configurados con transaccionalidad de solo lectura en el paquete com.andeva.atelier.platform.iam.application.services.

**Manejadores de Eventos de Dominio y Publicación Asíncrona**

El desacoplamiento entre casos de uso mutacionales y sus efectos secundarios se articula a
través de dos manejadores de eventos especializados en memoria que responden a las
mutaciones confirmadas de las entidades del dominio.

La clase **UserDomainEventsHandler** captura los eventos de identidad mediante oyentes de
eventos convencionales. Cuando se emite **VerificationTokenIssuedEvent**, extrae el código
numérico y activa el puerto de correo transaccional para remitir la clave de un solo uso
con plantilla estructurada.

Ante la captura de **PasswordResetRequestedEvent**, despacha la notificación con el enlace
seguro de restablecimiento de credenciales hacia la interfaz web. Por su parte,
**TenantDomainEventsHandler** combina oyentes estándar con oyentes condicionados a la
confirmación exitosa de la transacción en la base de datos.

Mientras que los avisos de invitación a colaboradores (**StaffInvitedEvent**) se remiten
de forma sincrónica, eventos corporativos como **TenantRegisteredEvent**,
**BranchCreatedEvent** y **TenantMembershipCreatedEvent** se capturan tras la confirmación
para construir y publicar los eventos de integración hacia el Transactional Outbox.

A fin de resumir la arquitectura de eventos, en la @tbl:iam-event-handlers se especifican
las responsabilidades, fases transaccionales y destinos de los manejadores de eventos de
la capa.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Manejadores de Eventos de Dominio de IAM \& Tenancy} \label{tbl:iam-event-handlers} \\
\hline
\thfirst{Aspecto del Manejador} & \thcell{Orquestación y Efecto Colateral} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Manejador} & \thcell{Orquestación y Efecto Colateral} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} UserDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{VerificationTokenIssuedEvent} \quad (\textit{Fase:} Inmediata) \\*
\hline
\textbf{Acción Orquestada} & Despacha correo electrónico transaccional con plantilla HTML y OTP. \\*
\hline
\textbf{Destino del Efecto} & Resend REST Client (Puerto 443) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} UserDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{PasswordResetRequestedEvent} \quad (\textit{Fase:} Inmediata) \\*
\hline
\textbf{Acción Orquestada} & Remite enlace web con token criptográfico de actualización de clave. \\*
\hline
\textbf{Destino del Efecto} & Resend REST Client (Puerto 443) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} TenantDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{StaffInvitedEvent} \quad (\textit{Fase:} Inmediata) \\*
\hline
\textbf{Acción Orquestada} & Envía invitación de empleo con enlace de aceptación al taller. \\*
\hline
\textbf{Destino del Efecto} & Resend REST Client (Puerto 443) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} TenantDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{TenantRegisteredEvent} \quad (\textit{Fase:} Posterior a confirmación) \\*
\hline
\textbf{Acción Orquestada} & Traduce y publica TenantCreatedIntegrationEvent para suscripciones. \\*
\hline
\textbf{Destino del Efecto} & Transactional Outbox / Event Bus \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} TenantDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{BranchCreatedEvent} \quad (\textit{Fase:} Posterior a confirmación) \\*
\hline
\textbf{Acción Orquestada} & Publica BranchCreatedIntegrationEvent para bahías y turnos. \\*
\hline
\textbf{Destino del Efecto} & Transactional Outbox / Event Bus \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} TenantDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{TenantMembershipCreatedEvent} \quad (\textit{Fase:} Posterior a confirmación) \\*
\hline
\textbf{Acción Orquestada} & Publica TenantMembershipCreatedIntegrationEvent para legajo laboral. \\*
\hline
\textbf{Destino del Efecto} & Transactional Outbox / Event Bus \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Clases ubicadas bajo el paquete com.andeva.atelier.platform.iam.application.events.

**Puertos de Salida y Modelos Inmutables de Sesión**

Para preservar la independencia de la lógica de negocio respecto a bibliotecas
propietarias y servicios en la nube, la capa define puertos de salida que establecen
contratos semánticos puros para interactuar con proveedores perimetrales.

El puerto **ResendEmailService** sustituye la pila de despacho SMTP tradicional por
peticiones HTTPS asíncronas sobre el puerto 443, neutralizando fallos de conexión en
plataformas en la nube. A su vez, **GoogleIdentityGateway** encapsula la verificación de
tokens criptográficos emitidos por el proveedor de inicio de sesión federado.

En el ámbito criptográfico y de seguridad, **BCryptHashingService** gestiona las funciones
de resumen unidireccional con coste computacional configurable, mientras que
**BearerTokenService** administra la conformación y análisis de firmas de tokens JWT
enriquecidos con atributos de tenencia y autoridades.

Finalmente, los registros inmutables **AuthenticatedUser** y **GoogleUserPayload**
consolidan las cargas útiles de sesión y perfiles federados, protegiendo las entidades
internas de dominio contra exposiciones involuntarias hacia capas externas.

Con el objeto de sistematizar las dependencias perimetrales, en la @tbl:iam-outbound-ports
se describen los métodos y responsabilidades técnicas de estos puertos de salida y modelos
de sesión.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.1cm} | >{\raggedright\arraybackslash}p{10.3cm} |}
\caption{Puertos de Salida y Modelos de la Capa de Aplicación de IAM \& Tenancy} \label{tbl:iam-outbound-ports} \\
\hline
\thfirst{Aspecto del Componente} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Componente} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} ResendEmailService \quad (\textit{Categoría:} Puerto de Salida)} \\*
\hline
\textbf{Métodos Principales} & \texttt{sendVerificationEmail}, \texttt{sendPasswordResetEmail}, \texttt{sendStaffInvitationEmail} \\*
\hline
\textbf{Responsabilidad Técnica} & Despacho de correos transaccionales vía HTTPS REST sin bloqueos SMTP. \\*
\hline
\textbf{Paquete Canónico} & \texttt{...application.acl} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} GoogleIdentityGateway \quad (\textit{Categoría:} Puerto de Salida)} \\*
\hline
\textbf{Métodos Principales} & \texttt{verifyIdToken} \\*
\hline
\textbf{Responsabilidad Técnica} & Validación criptográfica de firmas de tokens emitidos por Google OAuth2. \\*
\hline
\textbf{Paquete Canónico} & \texttt{...application.acl} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} BearerTokenService \quad (\textit{Categoría:} Servicio de Seguridad)} \\*
\hline
\textbf{Métodos Principales} & \texttt{generateToken}, \texttt{validateToken}, \texttt{extractClaims} \\*
\hline
\textbf{Responsabilidad Técnica} & Generación y lectura de tokens Bearer JWT con tenencia y permisos. \\*
\hline
\textbf{Paquete Canónico} & \texttt{...application.acl} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} BCryptHashingService \quad (\textit{Categoría:} Servicio Criptográfico)} \\*
\hline
\textbf{Métodos Principales} & \texttt{hash}, \texttt{matches} \\*
\hline
\textbf{Responsabilidad Técnica} & Derivación y validación de contraseñas mediante función hash adaptativa. \\*
\hline
\textbf{Paquete Canónico} & \texttt{...application.acl} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} AuthenticatedUser \quad (\textit{Categoría:} Modelo de Sesión)} \\*
\hline
\textbf{Métodos Principales} & \texttt{userId}, \texttt{email}, \texttt{token}, \texttt{activeTenant}, \texttt{permissions} \\*
\hline
\textbf{Responsabilidad Técnica} & Registro inmutable representativo de una sesión autenticada válida. \\*
\hline
\textbf{Paquete Canónico} & \texttt{...application.model} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} GoogleUserPayload \quad (\textit{Categoría:} Modelo de Identidad)} \\*
\hline
\textbf{Métodos Principales} & \texttt{sub}, \texttt{email}, \texttt{givenName}, \texttt{familyName}, \texttt{pictureUrl} \\*
\hline
\textbf{Responsabilidad Técnica} & Carga útil demográfica validada proveniente de Google Identity Services. \\*
\hline
\textbf{Paquete Canónico} & \texttt{...application.model} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al paquete com.andeva.atelier.platform.iam.application.

#### 2.6.2.4 Infrastructure Layer

La capa de infraestructura del Bounded Context de Identity and Access Management (IAM) &
Tenancy materializa los adaptadores técnicos y mecanismos de persistencia relacional,
seguridad perimetral, criptografía y comunicaciones externas que respaldan el modelo de
dominio de Atelier Platform.

Ubicada en el paquete canónico com.andeva.atelier.platform.iam.infrastructure, su diseño
arquitectónico confina los acoplamientos a bases de datos relacionales, marcos de trabajo
de seguridad y pasarelas de nube mediante cuatro directrices fundamentales:

- **Desacoplamiento Estricto de Persistencia:** Los agregados de dominio carecen por
completo de anotaciones del estándar Jakarta Persistence. La persistencia física en
PostgreSQL 16 se encomienda a entidades de persistencia dedicadas que heredan auditoría
temporal automática y clave técnica UUID de la superclase
AuditableAbstractPersistenceEntity.

- **Persistencia Nulo-Segura de Objetos de Valor:** Los objetos de valor inmutables del
dominio se transforman a tipos escalares nativos en PostgreSQL mediante convertidores JPA
especializados y componentes embebibles para coordenadas geográficas WGS84, asegurando
normalización relacional sin degradar el encapsulamiento.

- **Seguridad Perimetral Sin Estado y Multi-Inquilino:** La arquitectura de seguridad se
fundamenta en Spring Security 6 bajo una política estrictamente sin estado, gobernada por
filtros que validan firmas criptográficas de tokens JWT con claims enriquecidos y
comprueban la coincidencia de identificadores de taller en rutas relativas.

- **Comunicaciones Externas Confiables vía HTTPS:** Eliminación definitiva de protocolos
SMTP propensos a bloqueos en plataformas en la nube, delegando el despacho transaccional
de correos a la API REST de Resend sobre el puerto 443, e integrando la validación
criptográfica de Single Sign-On con Google Identity Services.

A fin de ofrecer una visión sistemática de estos componentes, en la
@tbl:iam-infrastructure-types se presenta el catálogo consolidado de los tipos técnicos
que conforman la Capa de Infraestructura de IAM & Tenancy.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo Consolidado de la Capa de Infraestructura de IAM \& Tenancy} \label{tbl:iam-infrastructure-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\
\hline
\endhead
TenantPersistenceEntity & Mapeo relacional de talleres automotrices a la tabla física tenants. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Hereda de AuditableAbstractPersistenceEntity. 1:N con sedes. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
BranchPersistenceEntity & Mapeo relacional de sedes físicas y geocercas satelitales a branches. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Pertenece a un taller específico mediante clave foránea. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
UserPersistenceEntity & Mapeo relacional de credenciales e identidad a la tabla users. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & 1:1 con perfiles biográficos y 1:N con tokens OTP. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
ProfilePersistenceEntity & Mapeo de datos biográficos a la tabla relacional profiles. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Comparte clave primaria compartida con la cuenta de usuario. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
VerificationTokenPersistenceEntity & Mapeo de tokens de verificación y reseteo a verification\_tokens. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Vinculado a usuarios con control de caducidad temporal. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
TenantMembershipPersistenceEntity & Mapeo de contratos laborales a la tabla tenant\_memberships. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Relación N:M con roles mediante membership\_roles. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
InvitationPersistenceEntity & Mapeo de invitaciones de onboarding a la tabla invitations. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Clave foránea al taller emisor y token URL seguro. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
RolePersistenceEntity & Mapeo relacional de roles de seguridad a la tabla roles. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Relación N:M con permisos mediante role\_permissions. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
PermissionPersistenceEntity & Mapeo relacional del catálogo atómico a la tabla permissions. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Entidad de catálogo transversal referenciada por roles. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
GeoPointEmbeddable & Estructura embebible con coordenadas de latitud y longitud WGS84. \\*
\hline
\textbf{Categoría} & Componente Embebible \\*
\hline
\textbf{Relaciones} & Integrada en BranchPersistenceEntity para geocercas. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
TaxIdAttributeConverter & Conversión bidireccional entre TaxId y columna VARCHAR(11). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Aplica sobre RUC fiscal en la entidad de taller. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
EmailAddressAttributeConverter & Conversión bidireccional entre EmailAddress y VARCHAR(150). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Normaliza correos electrónicos canónicos a minúsculas. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
MoneyAttributeConverter & Conversión bidireccional entre Money y columna NUMERIC(10,2). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Mapea salario base en membresías de colaboradores. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
TenantPersistenceRepository & Operaciones de persistencia física y consultas de unicidad de RUC. \\*
\hline
\textbf{Categoría} & Repositorio Spring Data \\*
\hline
\textbf{Relaciones} & Extiende \texttt{JpaRepository<\allowbreak TenantPersistenceEntity,\allowbreak  UUID>\allowbreak }. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
BranchPersistenceRepository & Consultas de sedes físicas y geocercas satelitales por taller. \\*
\hline
\textbf{Categoría} & Repositorio Spring Data \\*
\hline
\textbf{Relaciones} & Extiende \texttt{JpaRepository<\allowbreak BranchPersistenceEntity,\allowbreak  UUID>\allowbreak }. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
UserPersistenceRepository & Consultas de cuentas de usuario por correo canónico o Google ID. \\*
\hline
\textbf{Categoría} & Repositorio Spring Data \\*
\hline
\textbf{Relaciones} & Extiende \texttt{JpaRepository<\allowbreak UserPersistenceEntity,\allowbreak  UUID>\allowbreak }. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
TenantMembershipPersistenceRepository & Consultas de afiliación laboral y nómina activa por taller. \\*
\hline
\textbf{Categoría} & Repositorio Spring Data \\*
\hline
\textbf{Relaciones} & Extiende \texttt{JpaRepository<\allowbreak TenantMembershipPersistenceEntity,\allowbreak  UUID>\allowbreak }. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
RolePersistenceRepository & Consultas de roles configurados en el taller y roles globales. \\*
\hline
\textbf{Categoría} & Repositorio Spring Data \\*
\hline
\textbf{Relaciones} & Extiende \texttt{JpaRepository<\allowbreak RolePersistenceEntity,\allowbreak  UUID>\allowbreak }. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
PermissionPersistenceRepository & Consultas del catálogo de permisos de seguridad por categoría. \\*
\hline
\textbf{Categoría} & Repositorio Spring Data \\*
\hline
\textbf{Relaciones} & Extiende \texttt{JpaRepository<\allowbreak PermissionPersistenceEntity,\allowbreak  UUID>\allowbreak }. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
InvitationPersistenceRepository & Búsqueda y validación de tokens secretos de onboarding laboral. \\*
\hline
\textbf{Categoría} & Repositorio Spring Data \\*
\hline
\textbf{Relaciones} & Extiende \texttt{JpaRepository<\allowbreak InvitationPersistenceEntity,\allowbreak  UUID>\allowbreak }. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
TenantPersistenceAssembler & Transforma agregados Tenant hacia y desde entidades JPA. \\*
\hline
\textbf{Categoría} & Ensamblador \\*
\hline
\textbf{Relaciones} & Traduce identificadores fuertemente tipados a UUID. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
BranchPersistenceAssembler & Transforma entidades Branch hacia y desde entidades JPA. \\*
\hline
\textbf{Categoría} & Ensamblador \\*
\hline
\textbf{Relaciones} & Mapea coordenadas geográficas y radios de geocerca. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
UserPersistenceAssembler & Transforma agregados User hacia y desde entidades JPA. \\*
\hline
\textbf{Categoría} & Ensamblador \\*
\hline
\textbf{Relaciones} & Reconstituye perfiles demográficos y tokens asociados. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
TenantMembershipPersistenceAssembler & Transforma agregados TenantMembership a entidades JPA. \\*
\hline
\textbf{Categoría} & Ensamblador \\*
\hline
\textbf{Relaciones} & Mapea esquemas remunerativos y roles vinculados. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
RolePersistenceAssembler & Transforma agregados Role hacia y desde entidades JPA. \\*
\hline
\textbf{Categoría} & Ensamblador \\*
\hline
\textbf{Relaciones} & Hidrata el conjunto inmutable de permisos del rol. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
InvitationPersistenceAssembler & Transforma agregados Invitation a entidades JPA. \\*
\hline
\textbf{Categoría} & Ensamblador \\*
\hline
\textbf{Relaciones} & Preserva el token criptográfico y fecha de expiración. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
TenantRepositoryImpl & Implementación del puerto de dominio TenantRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Persistencia \\*
\hline
\textbf{Relaciones} & Persiste entidades y despacha eventos al Outbox. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
BranchRepositoryImpl & Implementación del puerto de dominio BranchRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Persistencia \\*
\hline
\textbf{Relaciones} & Coordina consultas y mutaciones de sucursales físicas. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
UserRepositoryImpl & Implementación del puerto de dominio UserRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Persistencia \\*
\hline
\textbf{Relaciones} & Gestiona almacenamiento de identidades y credenciales. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
TenantMembershipRepositoryImpl & Implementación del puerto TenantMembershipRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Persistencia \\*
\hline
\textbf{Relaciones} & Sincroniza vínculos laborales y extrae eventos de dominio. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
RoleRepositoryImpl & Implementación del puerto de dominio RoleRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Persistencia \\*
\hline
\textbf{Relaciones} & Gestiona persistencia de esquemas RBAC personalizados. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
PermissionRepositoryImpl & Implementación del puerto PermissionRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Persistencia \\*
\hline
\textbf{Relaciones} & Provee acceso de lectura al catálogo atómico de permisos. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
InvitationRepositoryImpl & Implementación del puerto InvitationRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Persistencia \\*
\hline
\textbf{Relaciones} & Almacena invitaciones y garantiza unicidad de token. \\*
\hline
\textbf{Paquete} & \texttt{...persistence.jpa.adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
ResendEmailClient & Cliente REST HTTPS que despacha correos vía Resend API. \\*
\hline
\textbf{Categoría} & Adaptador de Salida \\*
\hline
\textbf{Relaciones} & Implementa el puerto de aplicación ResendEmailService. \\*
\hline
\textbf{Paquete} & \texttt{...communication.resend} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
GoogleTokenVerifierGatewayImpl & Pasarela que verifica tokens Google OAuth2 con certificados. \\*
\hline
\textbf{Categoría} & Adaptador de Salida \\*
\hline
\textbf{Relaciones} & Implementa el puerto de aplicación GoogleIdentityGateway. \\*
\hline
\textbf{Paquete} & \texttt{...identity.google} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
BearerTokenServiceImpl & Genera y valida tokens JWT enriquecidos mediante JJWT. \\*
\hline
\textbf{Categoría} & Servicio Criptográfico \\*
\hline
\textbf{Relaciones} & Implementa el puerto de aplicación BearerTokenService. \\*
\hline
\textbf{Paquete} & \texttt{...security.jwt} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
BCryptHashingServiceImpl & Cifra y confronta contraseñas con factor de coste 12. \\*
\hline
\textbf{Categoría} & Servicio Criptográfico \\*
\hline
\textbf{Relaciones} & Implementa el puerto de aplicación BCryptHashingService. \\*
\hline
\textbf{Paquete} & \texttt{...security.crypto} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
WebSecurityConfiguration & Configuración perimetral de filtros, CORS y rutas en Spring. \\*
\hline
\textbf{Categoría} & Configuración de Seguridad \\*
\hline
\textbf{Relaciones} & Publica la cadena de filtros SecurityFilterChain. \\*
\hline
\textbf{Paquete} & \texttt{...security.configuration} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes implementados en Java 26 bajo el paquete canónico com.andeva.atelier.platform.iam.infrastructure.

**Entidades JPA de Persistencia y Modelado Físico Relacional**

El modelado relacional de la persistencia confina las anotaciones de Hibernate en nueve
entidades dedicadas que reflejan la estructura física de tablas de PostgreSQL 16 alojadas
en la infraestructura gestionada de Aiven Cloud.

La entidad **TenantPersistenceEntity** se asigna a la tabla tenants, encapsulando las
columnas de razón social, nombre comercial, RUC fiscal con restricción de unicidad y el
identificador de cliente de Stripe. Establece una relación compositiva en cascada con
**BranchPersistenceEntity**, mapeada a la tabla branches con coordenadas satelitales
WGS84.

Por su parte, **UserPersistenceEntity** se vincula a la tabla users con índice único sobre
el correo electrónico canónico. Comparte su clave primaria con
**ProfilePersistenceEntity** mediante la anotación de mapeo compartido de clave foránea, y
sostiene una relación de un titular a múltiples tokens temporales con
**VerificationTokenPersistenceEntity**.

El esquema de personal y seguridad contractual se materializa mediante
**TenantMembershipPersistenceEntity**, vinculada a talleres y usuarios. Esta entidad
define una relación de múltiples a múltiples hacia **RolePersistenceEntity** soportada en
la tabla intermedia membership_roles, mientras que los privilegios atómicos se vinculan a
roles mediante la tabla intermedia role_permissions.

Para consolidar el flujo de incorporación laboral, la entidad
**InvitationPersistenceEntity** se asigna a la tabla invitations, imponiendo restricción
de unicidad sobre el token criptográfico URL-safe y preservando la marca temporal de
expiración.

A fin de detallar la correlación física, en la @tbl:iam-jpa-entities se especifican las
entidades JPA, sus tablas correspondientes, columnas clave, constraints e índices
relacionales.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Especificación Relacional de Entidades JPA de IAM \& Tenancy} \label{tbl:iam-jpa-entities} \\
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} TenantPersistenceEntity \quad (\textit{Tabla:} \texttt{tenants})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{name}, \texttt{legal\_name}, \texttt{tax\_id}, \texttt{status}, \texttt{stripe\_customer\_id} \\*
\hline
\textbf{Restricciones e Índices} & Restricción única uk\_tenants\_tax\_id. no nulo en name y legal\_name. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} BranchPersistenceEntity \quad (\textit{Tabla:} \texttt{branches})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{tenant\_id}, \texttt{name}, \texttt{sunat\_code}, \texttt{latitude}, \texttt{longitude}, \texttt{geofence\_radius\_m}, \texttt{is\_active} \\*
\hline
\textbf{Restricciones e Índices} & Clave foránea a tenants. índice compuesto en tenant\_id y sunat\_code. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} UserPersistenceEntity \quad (\textit{Tabla:} \texttt{users})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{email}, \texttt{password\_hash}, \texttt{auth\_provider}, \texttt{google\_id}, \texttt{fcm\_token}, \texttt{status} \\*
\hline
\textbf{Restricciones e Índices} & Restricción única uk\_users\_email. índice en google\_id. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} ProfilePersistenceEntity \quad (\textit{Tabla:} \texttt{profiles})} \\*
\hline
\textbf{Clave Primaria} & \texttt{user\_id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{first\_name}, \texttt{last\_name}, \texttt{phone\_number} \\*
\hline
\textbf{Restricciones e Índices} & Clave primaria compartida MapsId con clave foránea a users. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} VerificationTokenPersistenceEntity \quad (\textit{Tabla:} \texttt{verification\_tokens})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{user\_id}, \texttt{token}, \texttt{type}, \texttt{expires\_at}, \texttt{is\_used} \\*
\hline
\textbf{Restricciones e Índices} & Clave foránea a users. índice en token y expires\_at. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} TenantMembershipPersistenceEntity \quad (\textit{Tabla:} \texttt{tenant\_memberships})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{tenant\_id}, \texttt{user\_id}, \texttt{status}, \texttt{salary\_type}, \texttt{base\_salary} \\*
\hline
\textbf{Restricciones e Índices} & Restricción única en tupla (tenant\_id, user\_id). claves foráneas dobles. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} InvitationPersistenceEntity \quad (\textit{Tabla:} \texttt{invitations})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{tenant\_id}, \texttt{email}, \texttt{token}, \texttt{status}, \texttt{target\_role\_id}, \texttt{expires\_at} \\*
\hline
\textbf{Restricciones e Índices} & Restricción única uk\_invitations\_token. clave foránea a tenants. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} RolePersistenceEntity \quad (\textit{Tabla:} \texttt{roles})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{tenant\_id}, \texttt{name}, \texttt{description}, \texttt{is\_system\_role} \\*
\hline
\textbf{Restricciones e Índices} & Clave foránea nullable a tenants. índice en tenant\_id y name. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} PermissionPersistenceEntity \quad (\textit{Tabla:} \texttt{permissions})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{name}, \texttt{description}, \texttt{category} \\*
\hline
\textbf{Restricciones e Índices} & Restricción única uk\_permissions\_name. índice en columna category. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Tablas físicas alojadas en el motor PostgreSQL 16 con motor InnoDB equivalente relacional.

**Repositorios Spring Data JPA y Adaptadores de Persistencia**

La interacción técnica con la base de datos se desacopla mediante el patrón Adaptador de
Repositorio. Las interfaces Spring Data JPA declaran operaciones optimizadas de acceso a
datos, mientras que las clases adaptadoras implementan los puertos de dominio.

Durante las operaciones de mutación, el adaptador **TenantRepositoryImpl** transforma el
agregado puro en su representación relacional mediante su ensamblador, persiste el
registro mediante **TenantPersistenceRepository**, extrae la colección de eventos de
dominio acumulados y los canaliza al componente **DomainEventPublisher** para su inserción
en el Transactional Outbox.

El mismo ciclo transaccional se ejecuta en los adaptadores **UserRepositoryImpl**,
**TenantMembershipRepositoryImpl**, **RoleRepositoryImpl** e **InvitationRepositoryImpl**,
garantizando que ninguna entidad física escape de la frontera de persistencia y
preservando la pureza de los modelos del dominio.

A fin de sintetizar estos componentes de persistencia relacional, en la
@tbl:iam-repository-adapters se detallan exhaustivamente los adaptadores de repositorio,
las interfaces de dominio implementadas y las operaciones transaccionales de acceso a
datos.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Adaptadores de Persistencia y Puertos de Dominio de IAM \& Tenancy} \label{tbl:iam-repository-adapters} \\
\hline
\thfirst{Aspecto de Adaptador} & \thcell{Especificación Técnica y Persistencia} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Adaptador} & \thcell{Especificación Técnica y Persistencia} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} TenantRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{TenantRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{TenantPersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & save con extracción de eventos, findById, findByTaxId, existsByTaxId. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} BranchRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{BranchRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{BranchPersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & save, findById, findAllByTenantId, findByIdAndTenantId. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} UserRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{UserRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{UserPersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & save con despacho Outbox, findById, findByEmail, existsByEmail. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} TenantMembershipRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{TenantMembershipRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{TenantMembershipPersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & save, findById, findAllByTenantId, findByTenantIdAndUserId. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} RoleRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{RoleRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{RolePersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & save, findById, findAllByTenantIdOrTenantIdIsNull, findByNameAndTenantId. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} PermissionRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{PermissionRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{PermissionPersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & findById, findAll, findAllByCategory, findByName. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} InvitationRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{InvitationRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{InvitationPersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & save con eventos, findByToken, findAllByTenantId, existsPending. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Clases ubicadas bajo el paquete com.andeva.atelier.platform.iam.infrastructure.persistence.jpa.adapters.

**Ensambladores de Persistencia y Convertidores JPA**

La correspondencia entre estructuras inmutables del dominio y modelos relacionales
mutables se resuelve a través de siete ensambladores de persistencia dedicados,
garantizando que los agregados se hidraten sin disparar eventos de dominio espurios
durante la lectura.

Los ensambladores extraen los valores escalares de objetos de valor representativos de
identificadores fuertemente tipados, números de documento tributario y coordenadas
geográficas para poblar las entidades JPA, reconstituyendo las raíces de agregado mediante
constructores de dominio controlados que validan exhaustivamente las invariantes.

De forma complementaria, los convertidores de atributos JPA **TaxIdAttributeConverter**,
**EmailAddressAttributeConverter** y **MoneyAttributeConverter** efectúan la normalización
automática a tipos VARCHAR y NUMERIC, mientras que **GeoPointEmbeddable** estructura
coordenadas de latitud y longitud satelital de forma embebida.

Con el propósito de ilustrar estas transformaciones bidireccionales, en la
@tbl:iam-persistence-assemblers se describen los ensambladores de persistencia,
convertidores de tipos, estructuras de entrada y reglas de mapeo relacional.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Ensambladores de Persistencia y Convertidores JPA de IAM \& Tenancy} \label{tbl:iam-persistence-assemblers} \\
\hline
\thfirst{Aspecto de Mapeo} & \thcell{Tipos Relacionados y Transformación} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Mapeo} & \thcell{Tipos Relacionados y Transformación} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} TenantPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{Tenant} $\longleftrightarrow$ \texttt{TenantPersistenceEntity} \\*
\hline
\textbf{Transformación} & Traduce TenantId a UUID. mapea sedes hijas y atributos corporativos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} BranchPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{Branch} $\longleftrightarrow$ \texttt{BranchPersistenceEntity} \\*
\hline
\textbf{Transformación} & Mapea BranchId a UUID, código SUNAT y GeoPointEmbeddable. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} UserPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{User} $\longleftrightarrow$ \texttt{UserPersistenceEntity} \\*
\hline
\textbf{Transformación} & Traduce UserId a UUID. mapea entidad Profile y tokens de verificación. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} TenantMembershipPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{TenantMembership} $\longleftrightarrow$ \texttt{TenantMembershipPersistenceEntity} \\*
\hline
\textbf{Transformación} & Mapea TenantMembershipId, esquema salarial y colección de roles. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} RolePersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{Role} $\longleftrightarrow$ \texttt{RolePersistenceEntity} \\*
\hline
\textbf{Transformación} & Mapea RoleId, bandera de sistema y catálogo de permisos vinculados. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} InvitationPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{Invitation} $\longleftrightarrow$ \texttt{InvitationPersistenceEntity} \\*
\hline
\textbf{Transformación} & Traduce InvitationId a UUID, rol objetivo y token URL-safe. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} TaxIdAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{TaxId} $\longleftrightarrow$ \texttt{VARCHAR(11)} \\*
\hline
\textbf{Transformación} & Mapea el número de RUC deduciendo el tipo según longitud de caracteres. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} EmailAddressAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{EmailAddress} $\longleftrightarrow$ \texttt{VARCHAR(150)} \\*
\hline
\textbf{Transformación} & Normaliza el correo canónico a minúsculas para persistencia relacional. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} MoneyAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{Money} $\longleftrightarrow$ \texttt{NUMERIC(10,\allowbreak 2)} \\*
\hline
\textbf{Transformación} & Extrae el valor numérico decimal preservando la moneda en el contexto. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} GeoPointEmbeddable} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{GeoPoint} $\longleftrightarrow$ \texttt{Columnas latitude y longitude} \\*
\hline
\textbf{Transformación} & Componente embebible con precisión de ocho decimales para geocercas. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes ubicados en los paquetes transform y converters de la capa de infraestructura.

**Seguridad Perimetral, Criptografía y Pasarelas de Nube**

La protección perimetral del sistema y la comunicación con servicios externos se consolida
en componentes de infraestructura desacoplados que materializan los puertos de aplicación
bajo estrictos estándares de seguridad informática.

La clase de configuración **WebSecurityConfiguration** establece una cadena de filtros de
seguridad estrictamente sin estado en Spring Security 6. Deshabilita la protección contra
CSRF por tratarse de una API REST consumida mediante tokens de autorización Bearer,
configura políticas de CORS restrictivas e inyecta los filtros perimetrales
especializados.

En el plano criptográfico, **BearerTokenServiceImpl** administra la emisión y verificación
de firmas HMAC-SHA256 mediante JJWT 0.12.6, inyectando claims contextuales que posibilitan
autorizaciones en memoria de coste constante. Por su parte, **BCryptHashingServiceImpl**
aplica funciones hash adaptativas con factor de coste 12 para contraseñas de acceso.

Finalmente, la integración externa comprende el cliente **ResendEmailClient**, que efectúa
peticiones REST HTTPS sobre el puerto 443 hacia la API de Resend para el despacho de
correos transaccionales, y la pasarela **GoogleTokenVerifierGatewayImpl**, que comprueba
las firmas de Google Identity Services frente a certificados criptográficos rotativos.

A fin de resumir la arquitectura de seguridad y servicios perimetrales, en la
@tbl:iam-security-infrastructure se especifican las responsabilidades de estos
componentes.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Componentes de Seguridad e Integración Externa de IAM \& Tenancy} \label{tbl:iam-security-infrastructure} \\
\hline
\thfirst{Aspecto Técnico} & \thcell{Tecnología y Responsabilidad de Seguridad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto Técnico} & \thcell{Tecnología y Responsabilidad de Seguridad} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente Técnico:} WebSecurityConfiguration \quad (\textit{Categoría:} Configuración)} \\*
\hline
\textbf{Tecnología Subyacente} & Spring Security 6 \\*
\hline
\textbf{Responsabilidad} & Publica SecurityFilterChain sin estado, deshabilita CSRF y gestiona CORS. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente Técnico:} BearerAuthorizationRequestFilter \quad (\textit{Categoría:} Filtro Perimetral)} \\*
\hline
\textbf{Tecnología Subyacente} & OncePerRequestFilter \\*
\hline
\textbf{Responsabilidad} & Extrae token Bearer, verifica firma e inyecta el SecurityContext. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente Técnico:} TenantContextResolver \quad (\textit{Categoría:} Filtro Perimetral)} \\*
\hline
\textbf{Tecnología Subyacente} & OncePerRequestFilter \\*
\hline
\textbf{Responsabilidad} & Comprueba que el tenant\_id de la ruta coincida con el inquilino en JWT. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente Técnico:} BearerTokenServiceImpl \quad (\textit{Categoría:} Servicio Criptográfico)} \\*
\hline
\textbf{Tecnología Subyacente} & JJWT 0.12.6 (HMAC-SHA256) \\*
\hline
\textbf{Responsabilidad} & Emite y valida tokens JWT inyectando claims de usuario, taller y permisos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente Técnico:} BCryptHashingServiceImpl \quad (\textit{Categoría:} Servicio Criptográfico)} \\*
\hline
\textbf{Tecnología Subyacente} & Spring Security Crypto \\*
\hline
\textbf{Responsabilidad} & Derivación unidireccional de contraseñas con factor de trabajo adaptativo 12. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente Técnico:} ResendEmailClient \quad (\textit{Categoría:} Adaptador de Salida)} \\*
\hline
\textbf{Tecnología Subyacente} & Spring RestClient (HTTPS 443) \\*
\hline
\textbf{Responsabilidad} & Despacho de correos transaccionales vía Resend API con plantillas HTML. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente Técnico:} GoogleTokenVerifierGatewayImpl \quad (\textit{Categoría:} Adaptador de Salida)} \\*
\hline
\textbf{Tecnología Subyacente} & Google API Client SDK \\*
\hline
\textbf{Responsabilidad} & Validación de certificados públicos y claims de tokens Google OAuth2. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes configurados bajo los paquetes security, communication e identity.

#### 2.6.2.5. Bounded Context Software Architecture Component Level Diagrams

En esta sección se presenta la descomposición arquitectónica interna del contenedor central **API Application** en relación con el Bounded Context IAM & Tenancy. Siguiendo el Nivel 3 del Modelo C4, se ilustran los bloques estructurales que conforman este subsistema perimetral, formalizando sus responsabilidades técnicas, fronteras operacionales y mecanismos de integración con clientes, módulos adyacentes y servicios externos.

Dentro de la arquitectura de monolito modular de Atelier Platform, el Bounded Context IAM & Tenancy asume la responsabilidad crítica de gobernar la identidad, la autenticación sin estado y el aislamiento multi-inquilino. La totalidad de peticiones emitidas desde el portal administrativo web y los aplicativos móviles transita por este subsistema antes de alcanzar la lógica operacional de órdenes de trabajo, inventario, facturación o telemetría.

En la @tbl:iam-c4-components se presenta el catálogo estructurado de los ocho componentes constitutivos del Bounded Context IAM & Tenancy dentro del contenedor anfitrión. Cada bloque encapsula una responsabilidad arquitectónica cohesiva, delimitando con precisión la frontera entre la seguridad perimetral, la orquestación de casos de uso, el modelo de dominio puro y la persistencia física en base de datos.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.5cm} | >{\raggedright\arraybackslash}p{10.9cm} |}
\caption{Catálogo de Componentes de Arquitectura de Software del Bounded Context IAM \& Tenancy} \label{tbl:iam-c4-components} \\
\hline
\thfirst{Aspecto Técnico} & \thcell{Especificación de Arquitectura} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto Técnico} & \thcell{Especificación de Arquitectura} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Perimeter Security \& Tenancy Filter} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring Security 6, OncePerRequestFilter, JJWT \\*
\hline
\textbf{Responsabilidad} & Intercepta solicitudes HTTP entrantes, valida la firma HMAC-SHA256 de tokens Bearer JWT, extrae identificadores de inquilino y usuario, y establece el contexto de seguridad. \\*
\hline
\textbf{Relaciones} & Entrada desde clientes HTTP. invoca servicio de tokens. canaliza peticiones hacia controladores REST y módulos de negocio. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} REST Controllers \& Inbound Interface} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring MVC, SpringDoc OpenAPI, Jakarta Validation \\*
\hline
\textbf{Responsabilidad} & Expone endpoints REST para autenticación local y federada, administración de talleres, sedes físicas con geocercas, invitaciones de personal y roles RBAC. \\*
\hline
\textbf{Relaciones} & Invocado por WebApp y aplicaciones móviles. delega en servicios de aplicación CQRS. utiliza ensambladores de respuesta. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} IAM CQRS Application Services} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring Service, Transactional, Interfaces Funcionales \\*
\hline
\textbf{Responsabilidad} & Orquesta los casos de uso de registro, incorporación de talleres, emisión de invitaciones y asignación de permisos bajo demarcación transaccional estricta. \\*
\hline
\textbf{Relaciones} & Implementa contratos de comando y consulta. orquesta modelos de dominio. delega en adaptadores de persistencia JPA. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Security \& Cryptographic Services} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & JJWT 0.12.6, Spring Security Crypto \\*
\hline
\textbf{Responsabilidad} & Emite y valida tokens JWT sin estado con asertos de usuario, taller y permisos. efectúa el cifrado unidireccional y verificación de contraseñas mediante algoritmo BCrypt. \\*
\hline
\textbf{Relaciones} & Consumido por filtros perimetrales, servicios de comando y controladores de autenticación. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} IAM Domain Aggregate Roots \& Core Models} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Dominio puro Java 26, AbstractDomainAggregateRoot \\*
\hline
\textbf{Responsabilidad} & Encapsula las invariantes de negocio, validación de RUC bajo Módulo 11 de la SUNAT, delimitación de geocercas Haversine y acumulación de eventos de dominio en memoria. \\*
\hline
\textbf{Relaciones} & Raíces Tenant, User, TenantMembership, Role, Invitation. entidades y objetos de valor inmutables. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Persistence Repositories \& JPA Adapters} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Jakarta Persistence 3.1, Spring Data JPA, Hibernate \\*
\hline
\textbf{Responsabilidad} & Materializa los puertos de repositorio del dominio mediante adaptadores JPA, gobernando el mapeo relacional bidireccional y la persistencia en PostgreSQL 16. \\*
\hline
\textbf{Relaciones} & Realiza interfaces de repositorio del dominio. interactúa directamente con el esquema relacional de la base de datos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Inbound ACL \& Tenancy Facade} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring Service, Capa Anticorrupción en Memoria \\*
\hline
\textbf{Responsabilidad} & Publica una fachada de servicio abierto para que bounded contexts externos consulten la validez de inquilinos, membresías laborales y permisos sin acoplamiento. \\*
\hline
\textbf{Relaciones} & Invocado por Workshop Operations, HR, CRM, Invoicing y SaaS Billing. delega lecturas en repositorios JPA. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} External Gateways \& Outbound Integration} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring RestClient, Google API Client SDK \\*
\hline
\textbf{Responsabilidad} & Comunica con pasarelas de nube mediante canales seguros HTTPS en puerto 443, gestionando el despacho de correos transaccionales y la verificación de identidad federada. \\*
\hline
\textbf{Relaciones} & Invocado por servicios de aplicación. conecta con Resend API y Google Identity Services. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al contenedor API Application en com.andeva.atelier.platform.iam.

En la @fig:c4-component-iam se ilustra el diagrama C4 de componentes para el Bounded Context IAM & Tenancy, detallando las interacciones entre los componentes perimetrales de seguridad, los controladores REST, los servicios de aplicación CQRS, el núcleo de dominio, los adaptadores de persistencia relacional y las pasarelas externas.

![Diagrama de Componentes C4 (Nivel 3) para el Bounded Context IAM & Tenancy en API Application](report/assets/c4-diagrams/component-level-diagram-iam.png){#fig:c4-component-iam}

*Nota.* Elaboración propia en base a la arquitectura táctica del backend y el estándar C4 Model.

**Dinámica de Interacción y Flujos Operativos del Bounded Context IAM & Tenancy**

Para comprender la colaboración entre los componentes de IAM & Tenancy y los módulos de negocio durante la ejecución del sistema, se analizan a continuación los tres flujos operacionales más representativos de la plataforma:

- **Ciclo de Autenticación Perimetral y Control de Acceso:**
  Cuando un usuario transmite sus credenciales desde la interfaz web o móvil, el componente **Perimeter Security & Tenancy Filter** intercepta la petición HTTP. Al reconocer una ruta pública de ingreso, la cadena de filtros autoriza el paso hacia el controlador de autenticación en **REST Controllers & Inbound Interface**, el cual valida el contrato de entrada y despacha el comando correspondiente hacia **IAM CQRS Application Services**.

  El servicio de aplicación recupera el usuario mediante **Persistence Repositories & JPA Adapters** y delega en **Security & Cryptographic Services** la verificación de la contraseña mediante el cotejo del hash BCrypt. Comprobada la identidad, se determina el taller activo y se solicita la generación de un token Bearer JWT con los identificadores requeridos y la lista inmutable de permisos autorizados, retornándolo al cliente con estado satisfactorio.

  En solicitudes protegidas subsecuentes, el filtro perimetral extrae el token del encabezado Authorization, verifica la firma criptográfica HMAC-SHA256 en memoria sin consultar la base de datos e inyecta la autenticación en el contexto de seguridad. Adicionalmente, comprueba que el identificador de taller de la ruta coincida con el inquilino autorizado en el token, rechazando intentos de acceso no autorizados entre talleres.

- **Ciclo Transaccional de Registro de Taller y Aprovisionamiento Multi-Inquilino:**
  Al registrarse un nuevo taller, el controlador recibe la solicitud y valida la estructura sintáctica del documento tributario mediante el objeto de valor correspondiente. El comando de creación se canaliza hacia **IAM CQRS Application Services**, el cual inicia una transacción de base de datos y confirma la inexistencia previa del número de RUC en el repositorio de persistencia.

  Posteriormente, el servicio instancia la raíz de agregado **Tenant** en el componente **IAM Domain Aggregate Roots & Core Models**, junto con su sucursal inicial validada mediante coordenadas geoespaciales. De manera simultánea, se crea el usuario administrador con contraseña cifrada, se configura el rol con privilegios globales de taller y se materializa la membresía contractual que vincula al usuario con la empresa.

  El componente **Persistence Repositories & JPA Adapters** persiste atómicamente la constelación de entidades en las tablas relacionales de PostgreSQL 16. La raíz de agregado registra el evento de aprovisionamiento en memoria, y el servicio delega en **External Gateways & Outbound Integration** la emisión de un correo electrónico de bienvenida mediante la API REST de Resend a través de HTTPS en el puerto 443, garantizando entrega confiable sin bloqueos de red.

- **Ciclo de Consumo Intercontextual mediante Fachada de Control de Acceso:**
  Cuando los módulos de operaciones de taller, recursos humanos o facturación requieren verificar la vigencia de una sucursal o los permisos de un operario, no acceden a las tablas de usuarios ni a los repositorios de seguridad. En su lugar, invocan la interfaz en memoria provista por **Inbound ACL & Tenancy Facade**, la cual implementa el patrón de servicio abierto y capa anticorrupción.

  La fachada recibe los identificadores inmutables de consulta y delega en **Persistence Repositories & JPA Adapters** una lectura optimizada de solo lectura. Los datos recuperados se proyectan hacia contratos inmutables del lenguaje publicado, tales como registros de transferencia de datos de inquilino o membresía, los cuales exponen únicamente los atributos pertinentes para la operación solicitada.

  Este mecanismo permite que el módulo de recursos humanos valide si un mecánico se encuentra dentro del radio de geocerca de la sucursal para registrar su asistencia, o que operaciones de taller verifique si una orden corresponde a un taller activo, preservando la pureza de los modelos de dominio y evitando acoplamientos innecesarios con la infraestructura de seguridad.

#### 2.6.2.6. Bounded Context Software Architecture Code Level Diagrams

En esta sección se profundiza en el nivel de mayor detalle técnico para la arquitectura de software del Bounded Context IAM & Tenancy, trasladando las fronteras conceptuales y las responsabilidades tácticas hacia especificaciones estáticas que guían la codificación de la plataforma. Mediante esta aproximación, se asegura que las reglas de negocio, los contratos de seguridad y el aislamiento multi-inquilino se ejecuten de manera determinista y tipificada.

Esta perspectiva abarca dos representaciones complementarias: el Diagrama de Clases de la Capa de Dominio, que modela las entidades, raíces de agregado, objetos de valor y puertos de persistencia en memoria; y el Diagrama de Base de Datos, que formaliza el esquema físico relacional en PostgreSQL 16 con claves de particionamiento lógico, restricciones de unicidad e integridad referencial.

##### 2.6.2.6.1. *Bounded Context Domain Layer Class Diagrams*

El modelado estático de la Capa de Dominio del Bounded Context IAM & Tenancy establece las estructuras operativas que regulan la identidad, el aprovisionamiento de talleres automotrices y el control de accesos basado en roles. Su diseño prioriza la encapsulación de invariantes en modelos de dominio ricos, erradica la obsesión por tipos primitivos mediante identificadores fuertemente tipados y desacopla la lógica de negocio de cualquier dependencia de frameworks externos.

En la @fig:class-diagram-iam se expone el Diagrama de Clases UML detallado para la Capa de Dominio del Bounded Context IAM & Tenancy, modelado conforme al estándar UML y compilado mediante la herramienta PlantUML bajo el enfoque de Diagram-as-Code.

![Diagrama de Clases UML de la Capa de Dominio para el Bounded Context IAM & Tenancy](report/assets/class-diagrams/class-diagram-iam.png){#fig:class-diagram-iam}

*Nota.* Elaboración propia en base al diseño táctico de dominio y el estándar UML en PlantUML.

La organización interna del diagrama se estructura en siete paquetes lógicos que agrupan las responsabilidades del dominio de seguridad:

- **Raíces de Agregado (`iam.domain.model.aggregates`):** Modela las entidades maestras que preservan la consistencia transaccional: **Tenant** para la gestión del taller y sus sedes físicas; **User** para la cuenta universal de usuario; **TenantMembership** para la relación contractual y asignación de roles; **Role** para la definición de privilegios RBAC; e **Invitation** para la incorporación controlada de colaboradores. Todas las raíces heredan de **AbstractDomainAggregateRoot<T>**.
- **Entidades Internas (`iam.domain.model.entities`):** Define entidades dependientes que carecen de existencia autónoma fuera de su raíz: **Branch** para las sedes operativas del taller; **Profile** para los datos biográficos del usuario; **VerificationToken** para la validación de credenciales efímeras; y **Permission** para privilegios atómicos de autorización.
- **Identificadores Fuertemente Tipados (`iam.domain.model.ids`):** Implementa la interfaz **TypedId<UUID>** mediante registros inmutables (**BranchId**, **TenantMembershipId**, **RoleId**, **PermissionId**, **InvitationId**), complementando las identidades universales del Shared Kernel (**TenantId**, **UserId**).
- **Objetos de Valor de Seguridad (`iam.domain.model.valueobjects`):** Encapsula conceptos inmutables como la credencial cifrada (**Password**) y la identidad nominal (**PersonName**), vinculando tipos del Shared Kernel para coordenadas satelitales (**GeoPoint**), identificación tributaria (**TaxId**), mensajería (**EmailAddress**, **PhoneNumber**) y cuantías económicas (**Money**).
- **Enumeraciones de Dominio (`iam.domain.model.enums`):** Estandariza los estados de ciclo de vida y modalidades operativas (**TenantStatus**, **UserStatus**, **AuthProvider**, **TokenType**, **MembershipStatus**, **SalaryType**, **InvitationStatus**).
- **Puertos de Persistencia (`iam.domain.repositories`):** Establece contratos de persistencia pura (**TenantRepository**, **UserRepository**, **BranchRepository**, **TenantMembershipRepository**, **RoleRepository**, **PermissionRepository**, **InvitationRepository**) sin dependencias de infraestructura.
- **Jerarquía de Excepciones Semánticas (`iam.domain.exceptions`):** Provee clases no comprobadas que heredan de **DomainException**, asignando códigos de error legibles por máquina para incidentes de autenticación, unicidad o autorización.

En la @tbl:iam-domain-classes-members se detalla la especificación formal de atributos, firmas de métodos, modificadores de acceso y reglas de negocio para cada elemento de la Capa de Dominio.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo exhaustivo de clases, miembros, ámbitos y relaciones de la Capa de Dominio del Bounded Context IAM \& Tenancy} \label{tbl:iam-domain-classes-members} \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Tenant} \\*
\hline
Atributos & Raíz de agregado. Administra razón social, RUC y sedes operativas. Generalización de \texttt{AbstractDomainAggregateRoot<\allowbreak TenantId>\allowbreak }. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{TenantId id} \newline - \texttt{String name} \newline - \texttt{String legalName} \newline - \texttt{TaxId taxId} \newline - \texttt{TenantStatus status} \newline - \texttt{String stripeCustomerId} \newline - \texttt{List<\allowbreak Branch>\allowbreak  branches} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos factoría y estado & Invariantes: estado inicial PENDING. activación sujeta a RUC válido y sede principal. Transiciones semánticas de estado. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Tenant create(...)} \newline - \texttt{void activate()} \newline - \texttt{void suspend(String reason)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos de sedes & Composición 1 a 1..* con \textbf{Branch}. Asegura que el taller mantenga al menos una sede física activa en todo momento. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Branch addBranch(name,\allowbreak  sunatCode,\allowbreak  loc,\allowbreak  radius)} \newline - \texttt{Optional<\allowbreak Branch>\allowbreak  findBranchById(BranchId)} \newline - \texttt{List<\allowbreak Branch>\allowbreak  activeBranches()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Branch} \\*
\hline
Atributos & Entidad de sede física. Delimitada espacialmente por \textbf{GeoPoint}. Vinculada al taller mediante \texttt{TenantId}. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{BranchId id} \newline - \texttt{TenantId tenantId} \newline - \texttt{String name} \newline - \texttt{String sunatCode} \newline - \texttt{GeoPoint location} \newline - \texttt{int geofenceRadiusMeters} \newline - \texttt{boolean isActive} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos operativos & Invariantes: radio de geocerca estrictamente positivo. Evalúa proximidad física mediante la formulación de Haversine. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{void updateLocation(GeoPoint,\allowbreak  int)} \newline - \texttt{void updateDetails(String,\allowbreak  String)} \newline - \texttt{boolean isWithinGeofence(GeoPoint)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} User} \\*
\hline
Atributos & Raíz de agregado de identidad universal. Generalización de \texttt{AbstractDomainAggregateRoot<\allowbreak UserId>\allowbreak }. Composición 1 a 1 con \textbf{Profile} y 1 a 0..* con \textbf{VerificationToken}. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{UserId id} \newline - \texttt{EmailAddress email} \newline - \texttt{Password password} \newline - \texttt{AuthProvider authProvider} \newline - \texttt{String googleId} \newline - \texttt{String fcmToken} \newline - \texttt{UserStatus status} \newline - \texttt{Profile profile} \newline - \texttt{List<\allowbreak VerificationToken>\allowbreak  verificationTokens} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos factoría & Factorías estáticas según proveedor. Asigna estado inicial PENDING\_VERIFICATION en flujo local o ACTIVE en federación. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{User registerWithLocalCredentials(...)} \newline - \texttt{User registerWithGoogle(...)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos de seguridad & Invariantes: renovación de clave requiere hash previo válido. Suspensión inhabilita inmediatamente credenciales de acceso. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{void verifyEmail()} \newline - \texttt{void updatePassword(Password)} \newline - \texttt{void updateFcmToken(String)} \newline - \texttt{void suspend()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos de tokens & Emite y consume tokens criptográficos temporales. Invalida tokens canjeados de manera irrevocable. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{VerificationToken issueVerificationToken(TokenType,\allowbreak  Duration)} \newline - \texttt{boolean validateAndConsumeToken(String,\allowbreak  TokenType)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Profile} \\*
\hline
Atributos y métodos & Entidad biográfica asociada en relación 1 a 1 con \textbf{User}. Centraliza nombres completos y teléfono internacional. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{UserId userId} \newline - \texttt{PersonName name} \newline - \texttt{PhoneNumber phone} \newline - \texttt{String avatarUrl} \newline - \texttt{void update(PersonName,\allowbreak  PhoneNumber)} \newline - \texttt{String fullName()} \\*
\hline
\textbf{Ámbito} & Privado / Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} VerificationToken} \\*
\hline
Atributos y métodos & Entidad efímera. Invariante: vigente si el indicador de uso es falso y la marca de tiempo actual no excede la expiración. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{UUID id} \newline - \texttt{UserId userId} \newline - \texttt{String tokenValue} \newline - \texttt{TokenType type} \newline - \texttt{Instant expiresAt} \newline - \texttt{boolean isUsed} \newline - \texttt{boolean isValid()} \newline - \texttt{void consume()} \\*
\hline
\textbf{Ámbito} & Privado / Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} TenantMembership} \\*
\hline
Atributos & Raíz de agregado de vinculación laboral. Conecta un \textbf{Tenant} con un \textbf{User}. Agregación 1 a 1..* con \textbf{Role}. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{TenantMembershipId id} \newline - \texttt{TenantId tenantId} \newline - \texttt{UserId userId} \newline - \texttt{MembershipStatus status} \newline - \texttt{SalaryType salaryType} \newline - \texttt{Money baseSalary} \newline - \texttt{Set<\allowbreak Role>\allowbreak  assignedRoles} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos de roles & Invariantes: restringe la asignación a roles del mismo taller o de alcance global. Evalúa privilegios atómicos. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{void assignRole(Role)} \newline - \texttt{void revokeRole(RoleId)} \newline - \texttt{boolean hasPermission(String)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos contractuales & Invariantes: compensación monetaria no negativa. Gestiona el alta, cese o reactivación laboral del operario. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{void updateCompensation(SalaryType,\allowbreak  Money)} \newline - \texttt{void activate()} \newline - \texttt{void deactivate()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Role} \\*
\hline
Atributos & Raíz de agregado de seguridad RBAC. Identificador \texttt{tenantId} nulo indica rol global. Agregación 1 a 1..* con \textbf{Permission}. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{RoleId id} \newline - \texttt{TenantId tenantId} \newline - \texttt{String name} \newline - \texttt{String description} \newline - \texttt{boolean isSystemRole} \newline - \texttt{Set<\allowbreak Permission>\allowbreak  permissions} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos operativos & Invariantes: roles predefinidos del sistema son inmutables frente a supresión. Roles locales gestionados por el taller. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Role defineTenantRole(...)} \newline - \texttt{Role defineSystemRole(...)} \newline - \texttt{void grantPermission(Permission)} \newline - \texttt{void revokePermission(PermissionId)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Permission} \\*
\hline
Atributos y métodos & Entidad de privilegio atómico inmutable. Representa la acción autorizada bajo formato jerárquico. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{PermissionId id} \newline - \texttt{String name} \newline - \texttt{String description} \newline - \texttt{String category} \newline - \texttt{Permission of(...)} \\*
\hline
\textbf{Ámbito} & Privado / Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Invitation} \\*
\hline
Atributos y métodos & Raíz de agregado para incorporación de usuarios. Invariante: aceptación exige estado PENDING y plazo vigente. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{InvitationId id} \newline - \texttt{TenantId tenantId} \newline - \texttt{EmailAddress email} \newline - \texttt{RoleId roleId} \newline - \texttt{String token} \newline - \texttt{InvitationStatus status} \newline - \texttt{Instant expiresAt} \newline - \texttt{void accept()} \newline - \texttt{void revoke()} \\*
\hline
\textbf{Ámbito} & Privado / Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Password} \\*
\hline
Atributo y factoría & Objeto de valor inmutable en Java Record. Resguarda el hash BCrypt e impide la fuga de claves en memoria. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{String hashedValue} \newline - \texttt{Password fromHash(String)} \\*
\hline
\textbf{Ámbito} & Privado / Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} PersonName} \\*
\hline
Atributos y métodos & Objeto de valor inmutable en Java Record. Normaliza nombres y apellidos de contacto personal. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{String firstName} \newline - \texttt{String lastName} \newline - \texttt{PersonName of(String,\allowbreak  String)} \newline - \texttt{String fullName()} \\*
\hline
\textbf{Ámbito} & Privado / Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} BranchId, TenantMembershipId, RoleId, PermissionId, InvitationId} \\*
\hline
Atributo value y factoría & Registros inmutables que realizan la interfaz \texttt{TypedId<\allowbreak UUID>\allowbreak }, confiriendo tipado estricto a identificadores de entidad. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{UUID value} \newline - \texttt{of(UUID)} \\*
\hline
\textbf{Ámbito} & Privado / Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} TenantStatus, UserStatus, AuthProvider, TokenType, MembershipStatus, SalaryType, InvitationStatus} \\*
\hline
Valores constantes & Tipos enumerados que gobiernan las transiciones de estado, esquemas de retribución y canales de federación. \\*
\hline
\textbf{Firma o Tipo} & \texttt{Enumeraciones de dominio} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} TenantRepository, UserRepository, BranchRepository, TenantMembershipRepository, RoleRepository, PermissionRepository, InvitationRepository} \\*
\hline
Firmas de acceso persistente & Puertos de persistencia para operaciones atómicas de lectura y escritura, desacoplados del motor de persistencia. \\*
\hline
\textbf{Firma o Tipo} & \texttt{Interfaces de repositorio} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Jerarquía de Excepciones de Dominio} \\*
\hline
Constructores tipados & Excepciones semánticas no comprobadas que portan códigos de error normalizados para respuestas HTTP 4xx. \\*
\hline
\textbf{Firma o Tipo} & Subclases de \texttt{DomainException} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Elaboración propia en base al diseño táctico de dominio y la especificación UML de la solución.

A partir del modelo estático ilustrado en la @fig:class-diagram-iam y desglosado en la @tbl:iam-domain-classes-members, se identifican tres fundamentos de ingeniería de software que respaldan la solidez y seguridad de la plataforma:

- **Desacoplamiento entre Identidad Universal y Membresía Multitenant:**
  El diseño separa la existencia ontológica del individuo en **User** de su vínculo laboral o administrativo formalizado en **TenantMembership**. Esta división permite que un mismo técnico u operario acceda a múltiples talleres automotrices con credenciales federadas centralizadas, desempeñando roles y esquemas remunerativos independientes sin provocar inconsistencias en los datos ni acoplar las cuentas personales a la estructura societaria del taller.

- **Validación Geodésica de Geocercas mediante la Ecuación de Haversine:**
  Para verificar la presencia del mecánico en las instalaciones antes de convalidar el registro de asistencia o permitir intervenciones mecánicas, el método *isWithinGeofence()* calcula la distancia esférica entre la posición del dispositivo móvil $(\phi_u, \lambda_u)$ y la coordenada central de la sede física $(\phi_b, \lambda_b)$ sobre un radio terrestre medio $R = 6\,371\,000 \text{ m}$:
  $$d = 2 R \arcsin \left( \sqrt{\sin^2\left(\frac{\Delta\phi}{2}\right) + \cos(\phi_b)\cos(\phi_u)\sin^2\left(\frac{\Delta\lambda}{2}\right)} \right)$$
  donde $\Delta\phi = \phi_u - \phi_b$ y $\Delta\lambda = \lambda_u - \lambda_b$ se computan en radianes. Si la distancia resultante $d$ es menor o igual al radio asignado en **geofenceRadiusMeters**, la operación se aprueba en el agregado sin requerir cálculos geoespaciales externos en base de datos.

- **Encapsulamiento Criptográfico e Invariantes Tributarias:**
  La integridad del sistema se preserva mediante constructores compactos y objetos de valor inmutables. El objeto **TaxId** evalúa el algoritmo ponderado de Módulo 11 de la SUNAT sobre los 11 dígitos del RUC, abortando la creación del taller ante numeraciones inválidas. A su vez, el objeto **Password** restringe el almacenamiento a hashes BCrypt con salting adaptativo, mientras que las entidades **VerificationToken** e **Invitation** garantizan la validez temporal de los procesos de autenticación e incorporación, previniendo ataques de reutilización mediante revocación atómica tras su primer consumo.



##### 2.6.2.6.2. *Bounded Context Database Design Diagram*

El diseño de persistencia del Bounded Context IAM & Tenancy materializa el modelo de dominio en un esquema relacional enfocado en garantizar aislamiento de datos, consistencia transaccional y disponibilidad continua. La persistencia se distribuye en dos componentes físicos complementarios: la base de datos central PostgreSQL 16 para el backend de la plataforma (**API Application**) y el motor relacional embebido SQLite 3 para la aplicación técnica móvil de taller (**Mobile Workshop**).

En la @fig:database-diagram-iam se presenta el Diagrama Entidad-Relación físico para la persistencia del Bounded Context IAM & Tenancy en sus dos entornos operativos de despliegue: la base de datos central PostgreSQL 16 de la API de backend y el motor relacional local SQLite 3 de la aplicación móvil de taller.

![Diagrama Entidad-Relación de Base de Datos para el Bounded Context IAM & Tenancy (PostgreSQL 16 y SQLite 3)](report/assets/database-diagrams/database-diagram-iam.png){#fig:database-diagram-iam}

*Nota.* Elaboración propia en base al diseño físico de persistencia y el estándar PlantUML ERD.

- **Subsistema de Tenancy y Sedes Físicas:**
  Gobierna la jerarquía organizacional de la plataforma mediante las tablas **tenants** y **branches**. La tabla **tenants** representa la persona jurídica del taller automotriz, resguardando su razón social, identificador tributario único validado y estado de suscripción. A su vez, la tabla **branches** modela los establecimientos físicos y almacenes anexos, incorporando coordenadas geodésicas en latitud y longitud junto con el radio métrico de geocerca para delimitar el perímetro espacial del taller.

- **Subsistema de Identidad Universal y Credenciales:**
  Administra el ciclo de vida ontológico del usuario mediante las tablas **users**, **profiles** y **verification_tokens**. La tabla **users** centraliza el acceso unificado a través de correo electrónico y contraseñas protegidas con el algoritmo criptográfico BCrypt o identificadores federados OAuth2. La tabla **profiles** preserva la información demográfica personal en una relación uno a uno, mientras que **verification_tokens** gestiona códigos de seguridad de un solo uso con caducidad temporal para confirmaciones y reajustes de clave.

- **Subsistema de Contratación Laboral y Seguridad RBAC:**
  Desacopla la identidad del personal mediante las tablas **tenant_memberships**, **roles**, **permissions**, **membership_roles**, **role_permissions** e **invitations**. La tabla **tenant_memberships** formaliza el vínculo contractual y régimen remunerativo del colaborador en un taller específico. El esquema de control de accesos se normaliza mediante las tablas asociativas **membership_roles** y **role_permissions**, que enlazan roles de sistema o personalizados con el catálogo canónico de operaciones atómicas en **permissions**, mientras **invitations** orquesta el enrolamiento seguro de colaboradores mediante tokens de alta entropía.

- **Persistencia Técnica Desconectada en SQLite 3:**
  Otorga autonomía operacional al cliente móvil de taller mediante las tablas locales **auth_session** y **local_permissions_cache**. La tabla **auth_session** resguarda en el almacenamiento seguro del dispositivo las credenciales de acceso JWT activas, el contexto de membresía, los roles asignados y las coordenadas geográficas de la sucursal asignada. Por su parte, la tabla **local_permissions_cache** conserva una copia sincronizada de las autorizaciones operativas, facultando la validación inmediata de privilegios y el cómputo de proximidad física en fosos mecánicos sin depender de señal celular.

A partir de la arquitectura relacional definida en el diagrama de persistencia, en la @tbl:iam-database-objects se cataloga la totalidad de las tablas y objetos físicos que conforman el modelo de datos, detallando el producto donde residen, sus atributos cardinales, restricciones de integridad, estrategias de indexación y su contribución al aislamiento de información.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.1cm} | >{\raggedright\arraybackslash}p{10.3cm} |}
\caption{Catálogo exhaustivo de tablas, objetos de base de datos, restricciones e índices físicos del Bounded Context IAM \& Tenancy} \label{tbl:iam-database-objects} \\
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{tenants}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API) \\*
\hline
\textbf{Propósito y Aislamiento} & Entidad raíz organizacional del taller automotriz. Delimita la frontera lógica superior de multi-inquilino en toda la base de datos. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{name (VARCHAR)}, \texttt{legal\_name (VARCHAR)}, \texttt{tax\_id (VARCHAR)}, \texttt{status (VARCHAR)}, \texttt{stripe\_customer\_id (VARCHAR)}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ)}, \texttt{version (BIGINT)}, \texttt{deleted\_at (TIMESTAMPTZ).} \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_tenants (id) \newline - UK: uk\_tenants\_tax\_id (tax\_id) \newline - CHECK: chk\_tenant\_status \newline - Índices B-Tree: idx\_tenants\_tax\_id, idx\_tenants\_status \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{branches}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API) \\*
\hline
\textbf{Propósito y Aislamiento} & Modela las sedes físicas y talleres. Aislamiento por discriminador tenant\_id y soporte espacial para delimitación de geocercas satelitales. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{tenant\_id (UUID)}, \texttt{name (VARCHAR)}, \texttt{sunat\_code (VARCHAR)}, \texttt{latitude (DECIMAL)}, \texttt{longitude (DECIMAL)}, \texttt{geofence\_radius\_m (INTEGER)}, \texttt{is\_active (BOOLEAN)}, auditoría transversal. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_branches (id) \newline - FK: fk\_branches\_tenant\_id (tenant\_id) \newline - CHECK: chk\_geofence\_radius (geofence\_radius\_m >= 10) \newline - Índices B-Tree: idx\_branches\_tenant\_id, idx\_branches\_coords \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{users}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API) \\*
\hline
\textbf{Propósito y Aislamiento} & Identidad universal del individuo transversal a múltiples talleres. Desacoplada del inquilino para permitir credenciales federadas. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{email (VARCHAR)}, \texttt{password\_hash (VARCHAR)}, \texttt{auth\_provider (VARCHAR)}, \texttt{google\_id (VARCHAR)}, \texttt{fcm\_token (VARCHAR)}, \texttt{status (VARCHAR)}, auditoría transversal. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_users (id) \newline - UK: uk\_users\_email (email) \newline - CHECK: chk\_users\_auth\_provider, chk\_users\_status \newline - Índices: idx\_users\_email, idx\_users\_google\_id (parcial) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{profiles}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API) \\*
\hline
\textbf{Propósito y Aislamiento} & Información demográfica personal en relación uno a uno con users. Segregación asociada al ciclo de vida del usuario. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{user\_id (UUID)}, \texttt{first\_name (VARCHAR)}, \texttt{last\_name (VARCHAR)}, \texttt{phone\_number (VARCHAR)}, \texttt{avatar\_url (VARCHAR)}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ).} \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_profiles (user\_id) \newline - FK: fk\_profiles\_user\_id hacia users(id) con ON DELETE CASCADE \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{verification\_tokens}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API) \\*
\hline
\textbf{Propósito y Aislamiento} & Custodia de códigos de verificación y recuperación. Invalidación atómica tras consumo para prevenir ataques de repetición. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{user\_id (UUID)}, \texttt{token (VARCHAR)}, \texttt{type (VARCHAR)}, \texttt{expires\_at (TIMESTAMPTZ)}, \texttt{is\_used (BOOLEAN)}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ).} \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_verification\_tokens (id) \newline - FK: fk\_verification\_tokens\_user\_id hacia users(id) \newline - CHECK: chk\_token\_type \newline - Índice compuesto: idx\_verification\_tokens\_lookup \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{tenant\_memberships}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API) \\*
\hline
\textbf{Propósito y Aislamiento} & Contrato laboral del usuario en un taller específico. Aislamiento estricto por tenant\_id garantizando particionamiento de datos. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{tenant\_id (UUID)}, \texttt{user\_id (UUID)}, \texttt{status (VARCHAR)}, \texttt{salary\_type (VARCHAR)}, \texttt{base\_salary (DECIMAL)}, auditoría transversal. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_tenant\_memberships (id) \newline - FK: fk\_memberships\_tenant\_id, fk\_memberships\_user\_id \newline - UK: uk\_memberships\_tenant\_user \newline - CHECK: chk\_membership\_status, chk\_base\_salary (base\_salary >= 0.00) \newline - Índices: idx\_memberships\_tenant\_status, idx\_memberships\_user\_id \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{roles}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API) \\*
\hline
\textbf{Propósito y Aislamiento} & Definición de roles de seguridad. Roles de sistema con tenant\_id nulo compartidos. roles personalizados aislados por tenant\_id. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{tenant\_id (UUID)}, \texttt{name (VARCHAR)}, \texttt{description (VARCHAR)}, \texttt{is\_system\_role (BOOLEAN)}, auditoría transversal. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_roles (id) \newline - FK: fk\_roles\_tenant\_id con ON DELETE CASCADE \newline - CHECK: chk\_roles\_tenant\_or\_system \newline - Índice B-Tree: idx\_roles\_tenant\_name \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{permissions}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API) \\*
\hline
\textbf{Propósito y Aislamiento} & Catálogo canónico e inmutable de operaciones atómicas del sistema agrupadas por Bounded Context. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{name (VARCHAR)}, \texttt{description (VARCHAR)}, \texttt{category (VARCHAR).} \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_permissions (id) \newline - UK: uk\_permissions\_name (name) \newline - Índice B-Tree: idx\_permissions\_category \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{membership\_roles}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API) \\*
\hline
\textbf{Propósito y Aislamiento} & Tabla asociativa que adjudica roles a miembros laborales dentro del alcance del taller empleador. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{membership\_id (UUID)}, \texttt{role\_id (UUID)}, \texttt{granted\_at (TIMESTAMPTZ).} \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_membership\_roles (membership\_id, role\_id) \newline - FK: fk\_membership\_roles\_membership, fk\_membership\_roles\_role con ON DELETE CASCADE \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{role\_permissions}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API) \\*
\hline
\textbf{Propósito y Aislamiento} & Tabla asociativa que vincula permisos canónicos a roles de sistema o específicos de taller. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{role\_id (UUID)}, \texttt{permission\_id (UUID)}, \texttt{granted\_at (TIMESTAMPTZ).} \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_role\_permissions (role\_id, permission\_id) \newline - FK: fk\_role\_permissions\_role, fk\_role\_permissions\_permission con ON DELETE CASCADE \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{invitations}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API) \\*
\hline
\textbf{Propósito y Aislamiento} & Enrolamiento de colaboradores por correo transaccional. Aislamiento por tenant\_id y token de alta entropía. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{tenant\_id (UUID)}, \texttt{email (VARCHAR)}, \texttt{target\_role\_id (UUID)}, \texttt{token (VARCHAR)}, \texttt{status (VARCHAR)}, \texttt{expires\_at (TIMESTAMPTZ)}, auditoría transversal. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_invitations (id) \newline - FK: fk\_invitations\_tenant\_id con ON DELETE CASCADE, fk\_invitations\_role\_id \newline - UK: uk\_invitations\_token \newline - CHECK: chk\_invitations\_status \newline - Índices: idx\_invitations\_tenant\_status, idx\_invitations\_token \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{auth\_session}} \\*
\hline
\textbf{Motor y Producto} & SQLite 3 (Mobile) \\*
\hline
\textbf{Propósito y Aislamiento} & Persistencia local de credenciales, roles, tokens y sede en el terminal móvil para operación desconectada sin red. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{user\_id (TEXT)}, \texttt{tenant\_id (TEXT)}, \texttt{membership\_id (TEXT)}, \texttt{email (TEXT)}, \texttt{full\_name (TEXT)}, \texttt{avatar\_url (TEXT)}, \texttt{access\_token (TEXT)}, \texttt{refresh\_token (TEXT)}, \texttt{cached\_roles (TEXT)}, \texttt{cached\_permissions (TEXT)}, \texttt{branch\_id (TEXT)}, \texttt{branch\_latitude (REAL)}, \texttt{branch\_longitude (REAL)}, \texttt{geofence\_radius\_m (INTEGER)}, \texttt{session\_expires\_at (TEXT)}, \texttt{last\_authenticated\_at (TEXT).} \\*
\hline
\textbf{Constraints e Índices} & PK: pk\_auth\_session (user\_id). \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{local\_permissions\_cache}} \\*
\hline
\textbf{Motor y Producto} & SQLite 3 (Mobile) \\*
\hline
\textbf{Propósito y Aislamiento} & Caché local de autorizaciones operativas para inspección y renderizado reactivo de la interfaz móvil en frío. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{permission\_name (TEXT)}, \texttt{category (TEXT)}, \texttt{description (TEXT)}, \texttt{synced\_at (TEXT).} \\*
\hline
\textbf{Constraints e Índices} & PK: pk\_local\_permissions\_cache (permission\_name). \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{auditable\_abstract\_entity}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API) \\*
\hline
\textbf{Propósito y Aislamiento} & Arquetipo transversal inyectado en entidades del backend para garantizar auditoría temporal, bloqueo optimista y aislamiento por tenant\_id. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{tenant\_id (UUID)}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ)}, \texttt{version (BIGINT)}, \texttt{deleted\_at (TIMESTAMPTZ).} \\*
\hline
\textbf{Constraints e Índices} & - PK técnica: id \newline - FK lógica: tenant\_id. Superclase MappedSuperclass JPA \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Elaboración propia en base al diseño relacional y la especificación física de persistencia.

A partir de la estructura formalizada en la @fig:database-diagram-iam y la @tbl:iam-database-objects, se identifican tres fundamentos de ingeniería de software que respaldan la solidez, seguridad y resiliencia de la persistencia:

- **Aislamiento Multi-Inquilino y Mitigación de Fuga de Datos:**
  La arquitectura física delega la segregación de inquilinos en el discriminador indexado **tenant_id**, presente en toda tabla sujeta a fronteras corporativas. Esta clave de particionamiento lógico, respaldada por índices B-Tree específicos, garantiza que los filtros de persistencia descarten de forma determinista tuplas ajenas al taller en sesión, erradicando vectores de fuga de información entre organizaciones concurrentes. Asimismo, la inclusión del atributo secuencial **version** habilita el control de concurrencia optimista en el motor relacional, bloqueando sobreescrituras accidentales cuando múltiples usuarios interactúan en simultáneo sobre una misma entidad.

- **Normalización 3NF del Esquema RBAC y Auditoría Transversal Heredada:**
  El diseño desacopla las credenciales globales del individuo respecto a sus facultades de acceso mediante la descomposición en Tercera Forma Normal (3NF) del modelo de seguridad. La articulación de **tenant_memberships**, **roles** y **permissions** a través de tablas asociativas previene anomalías de actualización y asegura la propagación inmediata de cambios en privilegios sin redundancia estructural. Además, la herencia uniforme del arquetipo **auditable_abstract_entity** mediante superclases JPA proporciona marcas temporales inmutables en UTC y soporte para borrado lógico, consolidando una pista de auditoría forense indispensable para el cumplimiento normativo.

- **Autonomía Operativa Desconectada en SQLite 3 para Mobile Workshop:**
  La persistencia local en el dispositivo móvil neutraliza las contingencias de conectividad en zonas con apantallamiento electromagnético o fosos mecánicos profundos. Mediante la tabla **auth_session**, el cliente técnico almacena credenciales criptográficas JWT y las coordenadas de la sede de trabajo, permitiendo evaluar la proximidad física mediante geocercas satelitales directamente en el dispositivo antes de autorizar el fichaje. Al complementar esta estructura con **local_permissions_cache**, la interfaz de usuario convalida privilegios de manera instantánea en frío, asegurando la continuidad de la jornada operativa sin latencia de red.



### 2.6.3. *Bounded Context: Customer and Fleet Management (CRM)*

El Bounded Context de Customer and Fleet Management (CRM) gestiona la dimensión comercial, relacional y operativa previa del ecosistema Atelier. Su alcance de dominio abarca el ciclo de vida de los clientes del taller, el empadronamiento del parque automotor universal, la trazabilidad temporal de la cadena de custodia vehicular y la programación anticipada de citas para intervenciones automotrices.

Dentro del sector automotriz, los talleres mecánicos atienden a dos perfiles de clientes con dinámicas comerciales diferenciadas:

- **Clientes particulares (B2C):** Propietarios individuales de vehículos de uso personal que demandan atención ágil, presupuestos transparentes y comunicación directa sobre el avance de sus reparaciones.

- **Flotas corporativas (B2B):** Empresas de transporte, distribución, logística o servicios que gestionan decenas o cientos de vehículos comerciales. Para estos clientes corporativos, el sistema requiere registrar la razón social y el número de RUC ante la autoridad tributaria, permitiendo administrar una flota heterogénea con condiciones comerciales preferenciales.

El diseño táctico resuelve estos requerimientos mediante la raíz de agregado **Customer**, la cual modela de forma polimórfica a ambos perfiles bajo un estricto aislamiento por taller (**TenantId**). A su vez, el automóvil físico se representa mediante la raíz de agregado global **Vehicle**, cuya existencia es independiente de cualquier taller particular para consolidar una historia clínica automotriz universal. La titularidad sobre las unidades se gobierna a través de la entidad dependiente **VehicleOwnership**, registrando el inicio y cese de custodia sin duplicar registros de chasis ni desvincular diagnósticos históricos.

Adicionalmente, el contexto modela la raíz de agregado **Appointment** para coordinar el ingreso ordenado de vehículos a las sedes físicas del taller (**BranchId**). La gestión de citas actúa como la antesala al proceso operativo de MRO, garantizando que la demanda de servicios no sobrepase la capacidad física instalada de bahías ni la disponibilidad de personal técnico en cada sucursal.

#### 2.6.3.1. Domain Layer

La capa de dominio de Customer and Fleet Management encapsula los modelos conceptuales, las invariantes transaccionales de la cartera comercial y las reglas de custodia automotriz sin establecer dependencia con librerías tecnológicas ni motores de persistencia. Residiendo bajo el paquete canónico **com.andeva.atelier.platform.crm.domain**, su diseño táctico se estructura sobre cuatro pilares fundamentales:

- **Aislamiento multi-inquilino de la cartera comercial:** Las fichas comerciales de clientes particulares y corporativos pertenecen a un taller determinado mediante **TenantId**, garantizando la confidencialidad de la base de clientes y la autonomía operativa de cada negocio mecánico adscrito a la plataforma.

- **Parque automotor universal e independiente del taller:** Las unidades vehiculares se modelan como raíces de agregado globales que carecen de **TenantId**. Un automóvil existe en el mundo físico y puede recibir atención en múltiples talleres a lo largo de su ciclo de vida, lo que permite consolidar una hoja clínica técnica y un historial de telemetría continuos e integrados en la nube.

- **Cadena de custodia y trazabilidad temporal:** La relación entre clientes y automóviles se gobierna mediante la entidad dependiente **VehicleOwnership**, registrando fechas formales de inicio y cese de custodia. Este desacoplamiento permite efectuar transferencias de titularidad vehicular sin alterar ni duplicar los historiales mecánicos ni diagnósticos previos.

- **Orquestación del agendamiento y transición operativa hacia MRO:** La raíz de agregado **Appointment** administra la reserva de capacidad en sedes físicas (**BranchId**). Al alcanzar el estado de arribo físico a patio, la cita dispara eventos de dominio que despiertan la generación automática de la orden de trabajo en el contexto operativo.

En la @tbl:crm-domain-types se presenta el catálogo consolidado de componentes que conforman la capa de dominio de Customer and Fleet Management.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo de la Capa de Dominio del Bounded Context CRM} \label{tbl:crm-domain-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\
\hline
\endhead
Customer & Raíz de consistencia comercial. Administra clientes particulares y flotas corporativas, validación fiscal y contacto. \\*
\hline
\textbf{Categoría} & Raíz de Agregado \\*
\hline
\textbf{Relaciones} & Generalización de AbstractDomainAggregateRoot<Customer>. Referencia a TenantId, TaxId y PersonName. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak model.\allowbreak aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Vehicle & Unidad automotriz física universal. Mantiene placa de rodaje única, número VIN ISO 3779, especificaciones y custodia histórica. \\*
\hline
\textbf{Categoría} & Raíz de Agregado \\*
\hline
\textbf{Relaciones} & Generalización de AbstractDomainAggregateRoot<Vehicle>. Composición 1 a 1..* con VehicleOwnership. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak model.\allowbreak aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
VehicleOwnership & Vínculo temporal de titularidad y custodia vehicular entre un cliente y un vehículo físico. \\*
\hline
\textbf{Categoría} & Entidad Dependiente \\*
\hline
\textbf{Relaciones} & Dependiente subordinada a Vehicle. Referencia a VehicleId, CustomerId y fechas de vigencia. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak model.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Appointment & Reserva y agendamiento previo de servicio técnico en una sucursal física del taller mecánico. \\*
\hline
\textbf{Categoría} & Raíz de Agregado \\*
\hline
\textbf{Relaciones} & Generalización de AbstractDomainAggregateRoot<Appointment>. Referencia a TenantId, BranchId, CustomerId y VehicleId. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak model.\allowbreak aggregates} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
CustomerId & Identificador único universal fuertemente tipado para clientes del taller. \\*
\hline
\textbf{Categoría} & Objeto de Valor (ID) \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
VehicleId & Identificador único universal fuertemente tipado para unidades del parque automotor. \\*
\hline
\textbf{Categoría} & Objeto de Valor (ID) \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
VehicleOwnershipId & Identificador único universal fuertemente tipado para el registro de titularidad vehicular. \\*
\hline
\textbf{Categoría} & Objeto de Valor (ID) \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
AppointmentId & Identificador único universal fuertemente tipado para citas programadas en taller. \\*
\hline
\textbf{Categoría} & Objeto de Valor (ID) \\*
\hline
\textbf{Relaciones} & Registro inmutable de identidad basado en UUID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
LicensePlate & Matrícula de rodaje normalizada en mayúsculas sin separadores, con validación de sintaxis oficial MTC. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Utilizado por la raíz de agregado Vehicle. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Vin & Número de Identificación Vehicular estandarizado de 17 caracteres alfanuméricos según ISO 3779. \\*
\hline
\textbf{Categoría} & Objeto de Valor \\*
\hline
\textbf{Relaciones} & Utilizado por la raíz de agregado Vehicle. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
CustomerType & Modalidad jurídica y comercial del cliente (INDIVIDUAL, COMPANY). \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada por la raíz de agregado Customer. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
CustomerStatus & Estados operativos de la ficha del cliente en el taller (ACTIVE, INACTIVE). \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada por la raíz de agregado Customer. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
EngineType & Tipología de motorización electromecánica del vehículo (GASOLINE, DIESEL, ELECTRIC, HYBRID). \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada por la raíz de agregado Vehicle. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
AppointmentStatus & Estados del ciclo de vida de la cita técnica (PENDING, CONFIRMED, ARRIVED, CANCELED). \\*
\hline
\textbf{Categoría} & Enumeración de Dominio \\*
\hline
\textbf{Relaciones} & Utilizada por la raíz de agregado Appointment. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak model.\allowbreak valueobjects} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Appointment\allowbreak Scheduling\allowbreak Service & Valida viabilidad operativa, antelación horaria y aforo de recepción de citas en sucursal física. \\*
\hline
\textbf{Categoría} & Servicio de Dominio \\*
\hline
\textbf{Relaciones} & Coordina TenantId, BranchId, AppointmentRepository y reglas temporales. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Vehicle\allowbreak Transfer\allowbreak Domain\allowbreak Service & Orquesta el traspaso de propiedad vehicular comprobando la ausencia de órdenes activas en MRO. \\*
\hline
\textbf{Categoría} & Servicio de Dominio \\*
\hline
\textbf{Relaciones} & Coordina Vehicle, Customer y VehicleOwnership. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
CustomerRepository & Contrato de persistencia agnóstico para la raíz de agregado Customer. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Implementado en la capa de infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
VehicleRepository & Contrato de persistencia agnóstico para la raíz de agregado Vehicle. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Implementado en la capa de infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Vehicle\allowbreak Ownership\allowbreak Repository & Contrato de persistencia y consulta de la cadena de custodia vehicular. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Implementado en la capa de infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
AppointmentRepository & Contrato de persistencia agnóstico para la raíz de agregado Appointment. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Implementado en la capa de infraestructura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
CustomerRegisteredEvent & Notifica el alta de un nuevo cliente particular o corporativo en el taller. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Customer\allowbreak Contact\allowbreak Updated\allowbreak Event & Notifica la actualización de los canales de contacto de un cliente. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
VehicleRegisteredEvent & Notifica la matriculación y vinculación inicial de un vehículo en el catálogo global. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Vehicle\allowbreak Ownership\allowbreak Transferred\allowbreak Event & Notifica el traspaso de custodia y titularidad vehicular hacia un nuevo cliente. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Appointment\allowbreak Scheduled\allowbreak Event & Notifica la solicitud inicial de una cita técnica en una sucursal determinada. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Appointment\allowbreak Confirmed\allowbreak Event & Notifica la confirmación de la cita por parte del equipo de recepción del taller. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
AppointmentArrivedEvent & Notifica la recepción física del automóvil en patio, despertando la apertura de la orden de trabajo. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Appointment\allowbreak Canceled\allowbreak Event & Notifica la anulación de la cita técnica liberando el aforo de recepción de la sede. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en el Dominio} \\*
\hline
Appointment\allowbreak Rescheduled\allowbreak Event & Notifica la reprogramación de la fecha u hora acordada para la cita automotriz. \\*
\hline
\textbf{Categoría} & Evento de Dominio \\*
\hline
\textbf{Relaciones} & Implementa DomainEvent para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak domain.\allowbreak events} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes tácticos de la Capa de Dominio de Customer and Fleet Management implementados bajo el paquete canónico com.andeva.atelier.platform.crm.domain.

**Raíces de Agregado y Entidades Dependientes de CRM**

El núcleo operativo de CRM se articula alrededor de tres raíces de agregado principales (**Customer**, **Vehicle** y **Appointment**) y una entidad dependiente (**VehicleOwnership**) encargada de preservar la integridad histórica de la posesión automotriz.

- **Customer**: Modela la ficha comercial del cliente adscrito a un taller específico. El agregado implementa un esquema polimórfico que distingue entre personas naturales particulares de tipo **INDIVIDUAL** y empresas administradoras de flotas vehiculares de tipo **COMPANY**. Esta diferenciación impone invariantes de consistencia estrictas sobre la documentación tributaria y las razones comerciales: los particulares exigen nombres estructurados mediante el objeto de valor **PersonName** y un documento nacional de identidad de ocho dígitos o carné de extranjería validado a través de **TaxId**, mientras que las entidades corporativas demandan una razón social obligatoria y un registro único de contribuyentes de once dígitos avalado formalmente.

Asimismo, la entidad exige contar con al menos una vía de contacto válida (**EmailAddress** o **PhoneNumber**) para habilitar el despacho de recordatorios y avisos transaccionales. El agregado provee métodos para la actualización controlada de datos de contacto y la inhabilitación comercial, impidiendo que una ficha inactiva tramite nuevas atenciones en el taller.

En la @tbl:crm-customer-members se detallan los miembros, firmas y reglas operativas de la raíz de agregado **Customer**.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de la Raíz de Agregado Customer} \label{tbl:crm-customer-members} \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Raíz de Agregado:} Customer (Núcleo Comercial y Cartera de Clientes)} \\*
\hline
id & Identificador universal único del cliente en la plataforma. \\*
\hline
\textbf{Tipo o Firma} & \texttt{CustomerId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
tenantId & Identificador del taller mecánico titular de la ficha comercial. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TenantId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
type & Naturaleza jurídica del cliente (INDIVIDUAL o COMPANY). \\*
\hline
\textbf{Tipo o Firma} & \texttt{CustomerType} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
name & Nombres y apellidos estructurados (obligatorio en INDIVIDUAL; nulo en COMPANY). \\*
\hline
\textbf{Tipo o Firma} & \texttt{PersonName} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
companyName & Razón social o denominación comercial (obligatorio en COMPANY; nulo en INDIVIDUAL). \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
taxId & Documento oficial de identidad tributaria (DNI de 8 dígitos o RUC de 11 dígitos). \\*
\hline
\textbf{Tipo o Firma} & \texttt{TaxId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
email & Dirección canónica de correo electrónico para notificaciones comerciales y avisos. \\*
\hline
\textbf{Tipo o Firma} & \texttt{EmailAddress} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
phone & Teléfono o línea móvil de contacto validado bajo estándar internacional UIT-T E.164. \\*
\hline
\textbf{Tipo o Firma} & \texttt{PhoneNumber} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
status & Estado operativo de la ficha del cliente en el taller (ACTIVE o INACTIVE). \\*
\hline
\textbf{Tipo o Firma} & \texttt{CustomerStatus} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
registerIndividual & Factoría para personas naturales; valida invariantes y emite CustomerRegisteredEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{static Customer registerIndividual(TenantId t,\allowbreak  PersonName n,\allowbreak  TaxId x,\allowbreak  EmailAddress e,\allowbreak  PhoneNumber p)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
registerCompany & Factoría para flotas corporativas con RUC validado; emite CustomerRegisteredEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{static Customer registerCompany(TenantId t,\allowbreak  String comp,\allowbreak  TaxId x,\allowbreak  EmailAddress e,\allowbreak  PhoneNumber p)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
updateContact & Actualiza los canales de contacto exigiendo al menos un medio de notificación no nulo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void updateContact(EmailAddress newEmail,\allowbreak  PhoneNumber newPhone)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
updateProfile & Actualiza nombres y apellidos; admisible exclusivamente en clientes de tipo INDIVIDUAL. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void updateProfile(PersonName newName)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
updateCompanyDetails & Actualiza la denominación comercial; admisible exclusivamente en clientes de tipo COMPANY. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void updateCompanyDetails(String newCompanyName)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
activate & Transiciona el estado de la ficha a ACTIVE habilitando la apertura de servicios. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void activate()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
deactivate & Inhabilita la ficha comercial del cliente impidiendo el registro de nuevas atenciones. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void deactivate()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
getDisplayName & Retorna la razón social corporativa o la concatenación de nombres y apellidos. \\*
\hline
\textbf{Tipo o Firma} & \texttt{String getDisplayName()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de miembros y métodos del agregado Customer del paquete com.andeva.atelier.platform.crm.domain.model.aggregates.

En cuanto a sus relaciones de dominio, **Customer** extiende la superclase **AbstractDomainAggregateRoot<Customer>** para la acumulación y despacho atómico de eventos de dominio en memoria, manteniendo un aislamiento lógico estricto por taller mediante **TenantId** sin establecer referencias directas a colecciones de infraestructura.

- **Vehicle**: Modela la unidad automotriz física de forma universal e independiente de cualquier inquilino o taller particular. El vehículo se identifica inequívocamente a nivel nacional mediante su placa de rodaje (**LicensePlate**), normalizada en mayúsculas sin guiones ni caracteres especiales, y opcionalmente por su número de identificación de chasis (**Vin**) bajo la norma internacional ISO 3779. El agregado encapsula especificaciones electromecánicas esenciales tales como la marca comercial, modelo, año de fabricación y tipología de propulsión (**EngineType**).

Para gobernar la posesión del automóvil a lo largo del tiempo, **Vehicle** encapsula la colección histórica de entidades **VehicleOwnership**, imponiendo la invariante de que en todo momento debe existir exactamente una titularidad activa cuya fecha de término permanezca abierta. Cuando ocurre una enajenación o traspaso vehicular, el método *transferOwnership()* clausura el vínculo precedente y crea una nueva titularidad activa, emitiendo el evento correspondiente sin comprometer los registros de mantenimiento previos.

- **VehicleOwnership**: Entidad dependiente subordinada al ciclo de vida de **Vehicle** que documenta el período de posesión de un cliente sobre la unidad física. Almacena el identificador del titular (**CustomerId**), la fecha de inicio de custodia y la fecha de finalización. La entidad valida que la fecha de término sea cronológicamente posterior o igual a la fecha de adquisición, permitiendo discernir con precisión al propietario civil responsable del vehículo en cualquier instante del tiempo.

En la @tbl:crm-vehicle-members se exponen los miembros y métodos de la raíz de agregado **Vehicle** y de su entidad dependiente **VehicleOwnership**.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de la Raíz de Agregado Vehicle y de la Entidad Dependiente VehicleOwnership} \label{tbl:crm-vehicle-members} \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Raíz de Agregado:} Vehicle (Parque Automotor Universal)} \\*
\hline
id & Identificador universal único del vehículo en el parque automotor global. \\*
\hline
\textbf{Tipo o Firma} & \texttt{VehicleId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
plate & Placa de rodaje vehicular normalizada única a nivel nacional. \\*
\hline
\textbf{Tipo o Firma} & \texttt{LicensePlate} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
vin & Número de identificación vehicular de 17 caracteres alfanuméricos ISO 3779 (opcional). \\*
\hline
\textbf{Tipo o Firma} & \texttt{Vin} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
brand & Marca del fabricante automotriz normalizada (longitud entre 2 y 50 caracteres). \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
model & Denominación comercial del modelo vehicular (longitud entre 1 y 50 caracteres). \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
year & Año de fabricación dentro del intervalo histórico válido (año entre 1950 y el año actual más uno). \\*
\hline
\textbf{Tipo o Firma} & \texttt{int} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
engineType & Clasificación electromecánica de la propulsión vehicular. \\*
\hline
\textbf{Tipo o Firma} & \texttt{EngineType} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
ownershipHistory & Colección histórica de propietarios que han poseído o custodian este vehículo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{List<\allowbreak VehicleOwnership>} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
register & Factoría que matricula el vehículo, crea la titularidad activa y emite evento. \\*
\hline
\textbf{Tipo o Firma} & \texttt{static Vehicle register(LicensePlate p,\allowbreak  Vin v,\allowbreak  String b,\allowbreak  String m,\allowbreak  int y,\allowbreak  EngineType e,\allowbreak  CustomerId o)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
transferOwnership & Cierra la titularidad previa, crea el nuevo registro activo y emite evento de dominio. \\*
\hline
\textbf{Tipo o Firma} & \texttt{VehicleOwnership transferOwnership(CustomerId newOwnerId,\allowbreak  LocalDate transferDate)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
getActiveOwnership & Consulta el registro de custodia y titularidad activo con fecha de culminación nula. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Optional<\allowbreak VehicleOwnership>\allowbreak  getActiveOwnership()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
getCurrentOwnerId & Retorna el identificador del cliente que actualmente posee la titularidad del vehículo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{Optional<\allowbreak CustomerId>\allowbreak  getCurrentOwnerId()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
updateTechnicalDetails & Actualiza la motorización o el número VIN verificado en inspección física. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void updateTechnicalDetails(Vin newVin,\allowbreak  EngineType newEngineType)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad Dependiente:} VehicleOwnership (Cadena de Custodia y Titularidad)} \\*
\hline
id & Identificador universal único del registro de titularidad y custodia. \\*
\hline
\textbf{Tipo o Firma} & \texttt{VehicleOwnershipId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
vehicleId & Identificador del vehículo físico asociado a este período de custodia. \\*
\hline
\textbf{Tipo o Firma} & \texttt{VehicleId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
customerId & Identificador del cliente propietario durante el lapso de vigencia. \\*
\hline
\textbf{Tipo o Firma} & \texttt{CustomerId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
startDate & Fecha de adquisición o inicio de custodia en la red del taller mecánico. \\*
\hline
\textbf{Tipo o Firma} & \texttt{LocalDate} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
endDate & Fecha de enajenación o fin de custodia (nula si es el propietario actual). \\*
\hline
\textbf{Tipo o Firma} & \texttt{LocalDate} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
isCurrent & Comprueba si el registro corresponde a la titularidad vigente (endDate == null). \\*
\hline
\textbf{Tipo o Firma} & \texttt{boolean isCurrent()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
terminate & Fija la fecha de finalización exigiendo que sea posterior o igual a startDate. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void terminate(LocalDate terminationDate)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de miembros del agregado Vehicle y la entidad dependiente VehicleOwnership del paquete com.andeva.atelier.platform.crm.domain.

En cuanto a sus relaciones, **Vehicle** extiende de **AbstractDomainAggregateRoot<Vehicle>** y mantiene una relación de composición 1 a 1..* con sus registros dependientes **VehicleOwnership**. Las consultas de historial mecánico en los módulos de inspección y taller operan directamente sobre el identificador universal **VehicleId**, garantizando que el expediente técnico del automóvil acompañe al vehículo sin importar qué taller de la red preste el servicio.

- **Appointment**: Raíz de agregado encargada de coordinar el flujo de recepción programada en las sedes físicas del taller. La reserva se delimita en el espacio mediante **BranchId** y en el tiempo a través de una marca temporal UTC obligatoriamente futura al momento del registro, acompañada de una duración estimada de inspección previa.

El ciclo de vida de la cita se gestiona mediante una máquina de estados finita y determinista que transiciona de forma secuencial desde el estado inicial **PENDING** hacia **CONFIRMED** cuando la sede valida su aforo técnico. Al momento en que el cliente arriba físicamente a las instalaciones del taller, el método *markArrived()* transiciona el estado a **ARRIVED** y emite **AppointmentArrivedEvent**, hecho que actúa como detonante perimetral para que el contexto de operaciones de taller proceda con la apertura preliminar de la orden de trabajo. Asimismo, el agregado admite reprogramaciones y cancelaciones justificadas, siempre que el vehículo no haya ingresado al patio de maniobras.

En la @tbl:crm-appointment-members se detallan los miembros, firmas y condiciones de transición de la raíz de agregado **Appointment**.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Miembros de la Raíz de Agregado Appointment} \label{tbl:crm-appointment-members} \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Raíz de Agregado:} Appointment (Agendamiento y Reserva de Taller)} \\*
\hline
id & Identificador universal único de la cita en la plataforma. \\*
\hline
\textbf{Tipo o Firma} & \texttt{AppointmentId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
tenantId & Identificador del taller receptor de la solicitud de servicio técnico. \\*
\hline
\textbf{Tipo o Firma} & \texttt{TenantId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
branchId & Identificador de la sucursal física seleccionada para la recepción del vehículo. \\*
\hline
\textbf{Tipo o Firma} & \texttt{BranchId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
customerId & Identificador del cliente titular que solicita la atención. \\*
\hline
\textbf{Tipo o Firma} & \texttt{CustomerId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
vehicleId & Identificador del automóvil que será objeto de revisión o mantenimiento. \\*
\hline
\textbf{Tipo o Firma} & \texttt{VehicleId} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
scheduledAt & Marca temporal acordada para la recepción en taller (debe ser futura al crearse). \\*
\hline
\textbf{Tipo o Firma} & \texttt{Instant} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
estimatedDurationMinutes & Tiempo estimado de recepción e inspección inicial (mínimo 15 min, default 30). \\*
\hline
\textbf{Tipo o Firma} & \texttt{int} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
reason & Motivo descriptivo de la solicitud (longitud entre 5 y 255 caracteres). \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
status & Estado actual en el ciclo de vida de la reserva (PENDING, CONFIRMED, ARRIVED, CANCELED). \\*
\hline
\textbf{Tipo o Firma} & \texttt{AppointmentStatus} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
cancellationReason & Justificación textual obligatoria en caso de anulación (mínimo 5 caracteres). \\*
\hline
\textbf{Tipo o Firma} & \texttt{String} \\*
\hline
\textbf{Ámbito de Acceso} & Privado \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
schedule & Factoría en estado inicial PENDING que registra AppointmentScheduledEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{static Appointment schedule(TenantId t,\allowbreak  BranchId b,\allowbreak  CustomerId c,\allowbreak  VehicleId v,\allowbreak  Instant s,\allowbreak  int d,\allowbreak  String r)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
confirm & Transiciona el estado de PENDING a CONFIRMED y emite AppointmentConfirmedEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void confirm()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
markArrived & Registra el arribo físico a patio (ARRIVED) y dispara AppointmentArrivedEvent hacia MRO. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void markArrived()} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
cancel & Anula la reserva exigiendo justificación válida de al menos 5 caracteres y emite AppointmentCanceledEvent. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void cancel(String reason)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\thfirst{Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
reschedule & Modifica la fecha acordada (en PENDING o CONFIRMED) y emite evento de dominio. \\*
\hline
\textbf{Tipo o Firma} & \texttt{void reschedule(Instant newScheduledAt)} \\*
\hline
\textbf{Ámbito de Acceso} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Especificación de miembros del agregado Appointment del paquete com.andeva.atelier.platform.crm.domain.model.aggregates.

En cuanto a sus relaciones, **Appointment** extiende de **AbstractDomainAggregateRoot<Appointment>** y mantiene desacoplamiento con los demás agregados mediante referencias por identidad (**TenantId**, **BranchId**, **CustomerId**, **VehicleId**), evitando acoplamientos en memoria y garantizando límites transaccionales acotados.

**Objetos de Valor y Enumeraciones del Bounded Context CRM**

Para erradicar la obsesión por tipos primitivos y resguardar la inmutabilidad de los datos, el dominio de CRM estructura todos sus identificadores y conceptos atómicos mediante registros inmutables de Java. Las reglas de normalización y restricciones defensivas se ejecutan de manera inmediata en los constructores compactos:

- **Identificadores fuertemente tipados**: Los tipos **CustomerId**, **VehicleId**, **VehicleOwnershipId** y **AppointmentId** encapsulan identificadores únicos universales inmutables basados en UUID, validando defensivamente la no vacuidad de sus valores.

- **Especificaciones automotrices tipadas**: El objeto de valor **LicensePlate** normaliza automáticamente las matrículas vehiculares suprimiendo espacios o guiones y transformando el texto a mayúsculas, validando su sintaxis contra los patrones oficiales del Ministerio de Transportes y Comunicaciones (MTC). Por su parte, **Vin** encapsula el número de chasis internacional conforme al estándar ISO 3779, verificando una longitud exacta de 17 caracteres alfanuméricos y vetando caracteres ambiguos.

- **Enumeraciones de control**: Las enumeraciones **CustomerType** y **CustomerStatus** regulan la personería jurídica y la viabilidad comercial del cliente; **EngineType** clasifica las variantes de tren motriz vehicular; y **AppointmentStatus** gobierna los estados secuenciales de agendamiento en taller.

En la @tbl:crm-value-objects se especifican los objetos de valor y enumeraciones propios de este contexto.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Objetos de Valor y Enumeraciones del Bounded Context CRM} \label{tbl:crm-value-objects} \\
\hline
\thfirst{Aspecto del Tipo} & \thcell{Especificación de Dominio} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Tipo} & \thcell{Especificación de Dominio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} CustomerId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal de cliente. no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} VehicleId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal de vehículo. no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} VehicleOwnershipId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal de titularidad y custodia vehicular. no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} AppointmentId} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: UUID} \\*
\hline
\textbf{Restricciones y Reglas} & Identificador unívoco universal de cita técnica de taller. no nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} LicensePlate} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: String} \\*
\hline
\textbf{Restricciones y Reglas} & Matrícula vehicular normalizada en mayúsculas sin guiones. Valida formato peruano MTC (6 caracteres alfanuméricos). \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Valor:} Vin} \\*
\hline
\textbf{Atributos Clave} & \texttt{value: String} \\*
\hline
\textbf{Restricciones y Reglas} & Número de Identificación Vehicular ISO 3779. Exactamente 17 caracteres alfanuméricos sin I, O ni Q. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} CustomerType} \\*
\hline
\textbf{Valores Admisibles} & \texttt{INDIVIDUAL}, \texttt{COMPANY} \\*
\hline
\textbf{Restricciones y Reglas} & Clasificación jurídica del cliente (particular o empresa de flota). \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} CustomerStatus} \\*
\hline
\textbf{Valores Admisibles} & \texttt{ACTIVE}, \texttt{INACTIVE} \\*
\hline
\textbf{Restricciones y Reglas} & Estados operativos de la ficha comercial del cliente en el taller mecánico. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} EngineType} \\*
\hline
\textbf{Valores Admisibles} & \texttt{GASOLINE}, \texttt{DIESEL}, \texttt{ELECTRIC}, \texttt{HYBRID} \\*
\hline
\textbf{Restricciones y Reglas} & Tipología de propulsión y tren motriz electromecánico del vehículo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Enumeración de Dominio:} AppointmentStatus} \\*
\hline
\textbf{Valores Admisibles} & \texttt{PENDING}, \texttt{CONFIRMED}, \texttt{ARRIVED}, \texttt{CANCELED} \\*
\hline
\textbf{Restricciones y Reglas} & Estados secuenciales dentro del ciclo de vida de la reserva de servicio técnico. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes inmutables ubicados bajo el paquete com.andeva.atelier.platform.crm.domain.model.valueobjects.

**Servicios de Dominio de CRM**

Aquellas reglas de negocio que demandan coordinar múltiples agregados o consultar el estado concurrente de persistencia sin pertenecer de forma natural a una única entidad se modelan como servicios de dominio puros:

- **AppointmentSchedulingService**: Evalúa la capacidad operativa y la disponibilidad física para agendar una cita en una sucursal determinada. El servicio verifica que la fecha y hora pactadas se sitúen dentro de la ventana de atención técnica, impone una antelación mínima de dos horas respecto a la marca temporal actual y consulta el repositorio de citas para asegurar que la cantidad de atenciones simultáneas no sobrepase el aforo de recepción de la sede.

- **VehicleTransferDomainService**: Orquesta el traspaso seguro de propiedad vehicular entre clientes del sistema. Valida que el vehículo cuente con un titular activo vigente, corrobora que el cliente receptor se encuentre debidamente registrado y activo, y comprueba que no existan órdenes de trabajo abiertas o pendientes de liquidación en el contexto de operaciones antes de autorizar el cambio de titularidad en el agregado vehicular.

En la @tbl:crm-domain-services se exponen las especificaciones y responsabilidades de estos dos servicios de dominio.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Servicios de Dominio del Bounded Context CRM} \label{tbl:crm-domain-services} \\
\hline
\thfirst{Aspecto de Servicio} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Servicio} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Dominio:} AppointmentSchedulingService} \\*
\hline
\textbf{Métodos Principales} & \texttt{validateSlotAvailability(...)} \\*
\hline
\textbf{Responsabilidad} & Evalúa la viabilidad horaria, antelación mínima (2 horas) y aforo concurrente de recepción en la sucursal. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio de Dominio:} VehicleTransferDomainService} \\*
\hline
\textbf{Métodos Principales} & \texttt{transferVehicle(...)} \\*
\hline
\textbf{Responsabilidad} & Orquesta el traspaso seguro de propiedad vehicular comprobando la ausencia de órdenes de trabajo activas en MRO. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes ubicados en el paquete com.andeva.atelier.platform.crm.domain.services.

**Puertos de Repositorio de la Capa de Dominio**

En estricta concordancia con los principios de Clean Architecture y aislamiento de persistencia, la capa de dominio de CRM expone puertos de salida abstractos que declaran las necesidades de almacenamiento y recuperación sin vincularse con Jakarta Persistence ni con bases de datos relacionales específicas:

- **CustomerRepository**: Contrato para la persistencia del agregado **Customer**, proveyendo consultas por identificador interno, documento tributario y listados filtrados por inquilino.

- **VehicleRepository**: Contrato agnóstico de taller para registrar y consultar automóviles en el parque automotor global mediante su identificador unívoco, placa de rodaje normalizada o número VIN.

- **VehicleOwnershipRepository**: Contrato especializado en la consulta y auditoría de la cadena de custodia vehicular, resolviendo la titularidad activa vigente o el historial cronológico de transferencias de una unidad física.

- **AppointmentRepository**: Contrato para el control del ciclo de vida de las reservas, incorporando mecanismos de agregación para el cómputo de aforo de recepción por franja horaria y filtros combinados por taller, sucursal y rango de fechas.

En la @tbl:crm-repository-ports se detallan las operaciones provistas por estos puertos de salida.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Puertos de Repositorio del Bounded Context CRM} \label{tbl:crm-repository-ports} \\
\hline
\thfirst{Aspecto de Puerto} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Puerto} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Repositorio:} CustomerRepository} \\*
\hline
\textbf{Métodos Principales} & - \texttt{save} \newline - \texttt{findById} \newline - \texttt{findByTenantIdAndTaxId} \newline - \texttt{findByTenantId} \newline - \texttt{existsByTenantIdAndTaxId} \\*
\hline
\textbf{Responsabilidad de Dominio} & Persistencia y consulta de la raíz de agregado Customer por identidad y documento tributario en el taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Repositorio:} VehicleRepository} \\*
\hline
\textbf{Métodos Principales} & - \texttt{save} \newline - \texttt{findById} \newline - \texttt{findByPlate} \newline - \texttt{findByVin} \newline - \texttt{existsByPlate} \newline - \texttt{findByCurrentOwnerId} \\*
\hline
\textbf{Responsabilidad de Dominio} & Persistencia y recuperación de vehículos en el catálogo universal independiente de taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Repositorio:} VehicleOwnershipRepository} \\*
\hline
\textbf{Métodos Principales} & - \texttt{save} \newline - \texttt{findByVehicleId} \newline - \texttt{findActiveOwnershipByVehicleId} \\*
\hline
\textbf{Responsabilidad de Dominio} & Trazabilidad y recuperación histórica de la cadena de custodia y titularidad vehicular. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Repositorio:} AppointmentRepository} \\*
\hline
\textbf{Métodos Principales} & - \texttt{save} \newline - \texttt{findById} \newline - \texttt{findByTenantIdAndBranchIdAndDate} \newline - \texttt{findByCustomerId} \newline - \texttt{findByVehicleId} \newline - \texttt{countActiveByBranchAndSlot} \\*
\hline
\textbf{Responsabilidad de Dominio} & Persistencia de citas, verificación de aforo por franja horaria y consulta por sede y cliente. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Interfaces de salida ubicadas en el paquete com.andeva.atelier.platform.crm.domain.repositories.

**Taxonomía de Eventos de Dominio de CRM**

Los eventos de dominio de CRM capturan hechos de negocio consumados y significativos, implementando la interfaz canónica **DomainEvent** provista por el Shared Kernel para su persistencia en el patrón Transactional Outbox y su posterior difusión reactiva:

- **Sincronización comercial y facturación**: El evento **CustomerRegisteredEvent** notifica la incorporación de un nuevo cliente, posibilitando que el módulo de facturación inicialice su expediente de cobranza y SUNAT. Asimismo, **CustomerContactUpdatedEvent** propaga cambios en direcciones de correo o teléfonos hacia los servicios de notificación.

- **Trazabilidad y telemetría automotriz**: **VehicleRegisteredEvent** difunde la matriculación de una unidad física para permitir el emparejamiento de adaptadores telemétricos en el módulo de IoT, mientras que **VehicleOwnershipTransferredEvent** comunica el relevo de propiedad a los módulos de mantenimiento sin que se pierdan las hojas de diagnóstico previas.

- **Coordinación de operaciones de taller**: El agendamiento, confirmación y reprogramación de citas se informan mediante **AppointmentScheduledEvent**, **AppointmentConfirmedEvent** y **AppointmentRescheduledEvent**, coordinando avisos push vía Firebase Cloud Messaging. De forma crítica, el arribo físico registrado por **AppointmentArrivedEvent** actúa como el evento detonante que despierta al contexto de Workshop Operations para aperturar la orden de trabajo en patio.

En la @tbl:crm-domain-events se sintetiza la taxonomía de eventos de dominio de este contexto.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Taxonomía de Eventos de Dominio del Bounded Context CRM} \label{tbl:crm-domain-events} \\
\hline
\thfirst{Aspecto del Evento} & \thcell{Especificación de Carga Útil y Efecto} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Evento} & \thcell{Especificación de Carga Útil y Efecto} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} CustomerRegisteredEvent \quad (\textit{Emisor:} Customer)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{customerId}, \texttt{tenantId}, \texttt{type}, \texttt{displayName}, \texttt{taxId}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Notifica el alta del cliente para sincronización con facturación y directorio comercial. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} CustomerContactUpdatedEvent \quad (\textit{Emisor:} Customer)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{customerId}, \texttt{email}, \texttt{phone}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Actualiza los canales de contacto para el despacho de avisos transaccionales. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} VehicleRegisteredEvent \quad (\textit{Emisor:} Vehicle)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{vehicleId}, \texttt{plate}, \texttt{initialOwnerId}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Incorpora el vehículo al padrón global y habilita vinculación telemétrica en IoT. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} VehicleOwnershipTransferredEvent \quad (\textit{Emisor:} Vehicle)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{vehicleId}, \texttt{previousOwnerId}, \texttt{newOwnerId}, \texttt{transferDate}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Actualiza la titularidad del vehículo manteniendo intacto el expediente técnico histórico. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} AppointmentScheduledEvent \quad (\textit{Emisor:} Appointment)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{appointmentId}, \texttt{tenantId}, \texttt{branchId}, \texttt{customerId}, \texttt{vehicleId}, \texttt{scheduledAt}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Reserva provisional de cupo en sucursal y confirmación inicial en la aplicación móvil. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} AppointmentConfirmedEvent \quad (\textit{Emisor:} Appointment)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{appointmentId}, \texttt{customerId}, \texttt{scheduledAt}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Confirma la cita y programa el recordatorio push mediante Firebase Cloud Messaging. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} AppointmentArrivedEvent \quad (\textit{Emisor:} Appointment)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{appointmentId}, \texttt{tenantId}, \texttt{branchId}, \texttt{customerId}, \texttt{vehicleId}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Disparador primario que despierta la creación de la orden de trabajo preliminar en MRO. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} AppointmentCanceledEvent \quad (\textit{Emisor:} Appointment)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{appointmentId}, \texttt{tenantId}, \texttt{branchId}, \texttt{reason}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Libera el cupo en la sucursal y desactiva recordatorios pendientes en los clientes. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Dominio:} AppointmentRescheduledEvent \quad (\textit{Emisor:} Appointment)} \\*
\hline
\textbf{Atributos Transportados} & \texttt{appointmentId}, \texttt{newScheduledAt}, \texttt{occurredOn} \\*
\hline
\textbf{Efecto Intermodular} & Actualiza la agenda de la sucursal y despacha notificación de nueva fecha acordada. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Eventos inmutables ubicados bajo el paquete com.andeva.atelier.platform.crm.domain.events.

**Jerarquía de Excepciones de Dominio y Manejo Semántico de Errores**

El resguardo de las invariantes y el tratamiento predecible de anomalías de negocio se articula mediante excepciones semánticas fuertemente tipadas que extienden de **DomainException**. Al detectarse la vulneración de una condición de consistencia, la capa de dominio interrumpe la operación arrojando una de estas anomalías, las cuales son capturadas en los servicios de aplicación y transformadas en resultados de fallo tipados **Result.Failure** o formateadas bajo el estándar de problemas RFC 7807:

- **Anomalías de clientes**: **CustomerNotFoundException** ante identificadores o documentos inexistentes en el taller; **CustomerAlreadyExistsException** si se intenta duplicar un documento tributario en la misma empresa; **CustomerInactiveException** ante intentos de operar comercialmente con una ficha dada de baja.

- **Anomalías de parque automotor y custodia**: **VehicleNotFoundException** ante unidades no catalogadas; **VehicleAlreadyExistsException** si la matrícula vehicular ya se encuentra registrada en el sistema; **InvalidLicensePlateException** e **InvalidVinException** si las cadenas suministradas no satisfacen los formatos oficiales MTC e ISO 3779; **VehicleActiveOwnershipNotFoundException** si el automóvil carece de un titular activo; **VehicleHasOpenWorkOrdersException** al intentar transferir un vehículo que mantiene órdenes de trabajo activas en taller.

- **Anomalías de agendamiento**: **AppointmentNotFoundException** ante citas inexistentes; **AppointmentSlotUnavailableException** si la sucursal ha alcanzado el aforo máximo de recepción técnica; **AppointmentInvalidStateTransitionException** ante mutaciones incompatibles con la máquina de estados; **AppointmentAlreadyArrivedException** si se pretende cancelar o reprogramar una cita ya ingresada a taller; **AppointmentPastDateException** si se intenta programar una reserva en una marca temporal pretérita.

En la @tbl:crm-domain-exceptions se sintetiza la jerarquía de excepciones de dominio y sus códigos de error semánticos asociados.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.8cm} | >{\raggedright\arraybackslash}p{9.6cm} |}
\caption{Excepciones de Dominio y Códigos Semánticos de CRM} \label{tbl:crm-domain-exceptions} \\
\hline
\thfirst{Código de Error Semántico} & \thcell{Condición de Lanzamiento en el Modelo} \\
\hline
\endfirsthead
\hline
\thfirst{Código de Error Semántico} & \thcell{Condición de Lanzamiento en el Modelo} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} CustomerNotFoundException} \\*
\hline
\texttt{CUSTOMER\_\allowbreak NOT\_\allowbreak FOUND} & El cliente consultado no existe en la cartera comercial del taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} CustomerAlreadyExistsException} \\*
\hline
\texttt{CUSTOMER\_\allowbreak ALREADY\_\allowbreak EXISTS} & El documento de identidad tributaria ya se encuentra registrado en el taller. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} CustomerInactiveException} \\*
\hline
\texttt{CUSTOMER\_\allowbreak INACTIVE} & La ficha comercial del cliente se encuentra inhabilitada para transacciones. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} VehicleNotFoundException} \\*
\hline
\texttt{VEHICLE\_\allowbreak NOT\_\allowbreak FOUND} & El vehículo consultado no existe en el catálogo automotor global. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} VehicleAlreadyExistsException} \\*
\hline
\texttt{VEHICLE\_\allowbreak ALREADY\_\allowbreak EXISTS} & La placa de rodaje ya se encuentra matriculada en la plataforma. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} InvalidLicensePlateException} \\*
\hline
\texttt{INVALID\_\allowbreak LICENSE\_\allowbreak PLATE} & La matrícula no cumple la sintaxis vehicular oficial peruana MTC. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} InvalidVinException} \\*
\hline
\texttt{INVALID\_\allowbreak VIN} & El número de chasis no satisface los 17 caracteres alfanuméricos ISO 3779. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} VehicleActiveOwnershipNotFoundException} \\*
\hline
\texttt{VEHICLE\_\allowbreak ACTIVE\_\allowbreak OWNERSHIP\_\allowbreak NOT\_\allowbreak FOUND} & La unidad automotriz carece de un titular activo registrado en el sistema. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} VehicleHasOpenWorkOrdersException} \\*
\hline
\texttt{VEHICLE\_\allowbreak HAS\_\allowbreak OPEN\_\allowbreak WORK\_\allowbreak ORDERS} & No se permite transferir un vehículo que mantiene órdenes de trabajo abiertas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} AppointmentNotFoundException} \\*
\hline
\texttt{APPOINTMENT\_\allowbreak NOT\_\allowbreak FOUND} & La cita de servicio técnico solicitada no existe en el sistema. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} AppointmentSlotUnavailableException} \\*
\hline
\texttt{APPOINTMENT\_\allowbreak SLOT\_\allowbreak UNAVAILABLE} & La sucursal ha alcanzado el aforo máximo de recepción en la franja solicitada. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} AppointmentInvalidStateTransitionException} \\*
\hline
\texttt{APPOINTMENT\_\allowbreak INVALID\_\allowbreak STATE\_\allowbreak TRANSITION} & La mutación solicitada no es admisible en el ciclo de vida de la reserva. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} AppointmentAlreadyArrivedException} \\*
\hline
\texttt{APPOINTMENT\_\allowbreak ALREADY\_\allowbreak ARRIVED} & La cita ya ingresó a patio de taller y no puede anularse ni reprogramarse. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Excepción:} AppointmentPastDateException} \\*
\hline
\texttt{APPOINTMENT\_\allowbreak PAST\_\allowbreak DATE} & No se permite agendar una cita en una marca temporal anterior a la actual. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes ubicados bajo el paquete com.andeva.atelier.platform.crm.domain.exceptions.


#### 2.6.3.2. Interface Layer

La capa de interfaz del Bounded Context Customer and Fleet Management (CRM) opera como el adaptador primario de entrada dentro de la arquitectura de Atelier Platform, gobernando la interacción perimetral con los clientes del taller, la administración técnica del parque automotor y el ciclo de vida operativo de las citas de servicio.

Ubicada en el paquete canónico **com.andeva.atelier.platform.crm.interfaces**, su concepción táctica responde a cuatro directrices esenciales de diseño:

- **Desacoplamiento perimetral y mediación determinista:** Los controladores REST nunca interaccionan directamente con las raíces de agregado ni capturan excepciones de bajo nivel. Toda comunicación se canaliza hacia los servicios de aplicación a través de comandos y consultas inmutables, recibiendo como respuesta el tipo sellado **Result<T, ApplicationError>** para garantizar respuestas HTTP predecibles.

- **Aislamiento multi-inquilino y contratos especializados:** La cartera de clientes se encuentra estrictamente segmentada por taller automotriz a través del identificador resuelto en el contexto de seguridad. Asimismo, la capa proporciona contratos especializados para personas naturales y empresas de flotas corporativas, erradicando ambigüedades en la validación tributaria perimetral.

- **Catálogo automotriz universal y trazabilidad temporal de custodia:** El vehículo se modela como un activo físico global e independiente del inquilino, asegurando unicidad nacional por placa de rodaje y número de chasis bajo el estándar ISO 3779. La titularidad se gestiona mediante un historial cronológico inmutable de periodos de custodia, reflejando fielmente la transferencia de propiedad entre clientes.

- **Fachada de contexto abierto y eventos de integración intermodulares:** La capa resguarda la pureza del modelo de dominio exponiendo la interfaz **CustomerFleetContextFacade** para consultas síncronas en memoria desde otros módulos, al tiempo que propaga eventos del lenguaje publicado mediante el patrón Transactional Outbox para coordinar de forma asíncrona la apertura de órdenes de trabajo, la provisión telemétrica y la facturación electrónica.

En la @tbl:crm-interface-types se presenta el catálogo consolidado de los componentes que integran la Capa de Interfaz de Customer and Fleet Management (CRM).

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo Consolidado de la Capa de Interfaz de Customer \& Fleet Management (CRM)} \label{tbl:crm-interface-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endhead
CustomersController & Endpoints REST para administración de cartera de clientes, categorización persona o empresa y titularidad. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca CustomerCommandService y CustomerQueryService. Utiliza ensambladores de recursos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
VehiclesController & Endpoints REST para catálogo universal automotriz, consulta técnica por placa y traspasos de custodia. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca VehicleCommandService y VehicleQueryService. Gestiona entidades Vehicle y VehicleOwnership. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
AppointmentsController & Endpoints REST para reserva, confirmación, registro de arribo físico y cancelación de citas previas. \\*
\hline
\textbf{Categoría} & Controlador REST \\*
\hline
\textbf{Relaciones} & Invoca AppointmentCommandService y AppointmentQueryService. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak interfaces.\allowbreak rest.\allowbreak controllers} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Create\allowbreak Individual\allowbreak Customer\allowbreak Resource & Carga útil inmutable para registro de clientes persona natural con DNI y datos de contacto. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por RegisterCustomerCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Create\allowbreak Company\allowbreak Customer\allowbreak Resource & Carga útil inmutable para registro de clientes corporativos de flota con RUC y razón social. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por RegisterCustomerCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Update\allowbreak Customer\allowbreak Contact\allowbreak Resource & Carga útil inmutable para actualización perimetral de correo electrónico y teléfono celular. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por UpdateCustomerContactCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Create\allowbreak Vehicle\allowbreak Resource & Carga útil para incorporación de vehículo global con placa, VIN, especificaciones y titular inicial. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por RegisterVehicleCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Transfer\allowbreak Vehicle\allowbreak Ownership\allowbreak Resource & Carga útil para traspaso de titularidad vehicular especificando nuevo dueño y fecha formal. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por TransferVehicleOwnershipCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Schedule\allowbreak Appointment\allowbreak Resource & Carga útil para reserva de cita con identificación de sede, cliente, vehículo, fecha y motivo. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por ScheduleAppointmentCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Reschedule\allowbreak Appointment\allowbreak Resource & Carga útil para reprogramación con nueva marca temporal acordada para la atención técnica. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por RescheduleAppointmentCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Cancel\allowbreak Appointment\allowbreak Resource & Carga útil con motivo explícito de anulación justificada de la cita agendada. \\*
\hline
\textbf{Categoría} & Recurso de Petición \\*
\hline
\textbf{Relaciones} & Mapeado por CancelAppointmentCommandFromResourceAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
CustomerResource & Representación inmutable de la ficha comercial de cliente con denominación resuelta y estado. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por CustomerResourceFromAggregateAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
VehicleResource & Representación inmutable de la ficha técnica de un automóvil con datos del custodio actual. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por VehicleResourceFromAggregateAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
VehicleOwnershipResource & Representación inmutable de un segmento temporal de custodia y titularidad vehicular. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por VehicleOwnershipResourceFromEntityAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
AppointmentResource & Representación inmutable de una cita técnica con nombres desnormalizados para visualización. \\*
\hline
\textbf{Categoría} & Recurso de Respuesta \\*
\hline
\textbf{Relaciones} & Producido por AppointmentResourceFromAggregateAssembler. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak interfaces.\allowbreak rest.\allowbreak resources} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Customer\allowbreak Fleet\allowbreak Context\allowbreak Facade & Interfaz pública que expone consultas síncronas de clientes, vehículos y citas en memoria. \\*
\hline
\textbf{Categoría} & Fachada de Contexto (OHS) \\*
\hline
\textbf{Relaciones} & Consumida por Workshop Operations (MRO), Invoicing e IoT Telemetry. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak interfaces.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Customer\allowbreak Fleet\allowbreak Context\allowbreak FacadeImpl & Implementación de la fachada que consulta repositorios y preserva la pureza de los agregados. \\*
\hline
\textbf{Categoría} & Implementación ACL \\*
\hline
\textbf{Relaciones} & Implementa CustomerFleetContextFacade desacoplando el modelo interno. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak interfaces.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Customer\allowbreak Created\allowbreak Integration\allowbreak Event & Notificación asíncrona de cliente creado para pre-carga de datos fiscales en Invoicing. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. Integra con el módulo de facturación electrónica. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Registered\allowbreak Integration\allowbreak Event & Notificación asíncrona de vehículo registrado para provisión telemétrica en IoT Telemetry. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. Integra con la plataforma telemétrica vehicular. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Ownership\allowbreak Transferred\allowbreak Integration\allowbreak Event & Notificación asíncrona de cambio de titular para reasignación en Atelier Driver e IoT. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. Integra con IoT Telemetry y la aplicación móvil del conductor. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Appointment\allowbreak Scheduled\allowbreak Integration\allowbreak Event & Notificación asíncrona de cita agendada para previsión de capacidad en Workshop Operations. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. Integra con planificación de bahías de servicio técnico. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak interfaces.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Appointment\allowbreak Arrived\allowbreak Integration\allowbreak Event & Notificación asíncrona de arribo físico para apertura de Orden de Trabajo en Workshop Operations. \\*
\hline
\textbf{Categoría} & Evento de Integración \\*
\hline
\textbf{Relaciones} & Publicado vía Outbox. Desencadena la recepción formal en el taller operativo. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak interfaces.\allowbreak events} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al paquete canónico com.andeva.atelier.platform.crm.interfaces.

A continuación, se profundiza en la especificación a manera de diccionario de cada una de las clases, controladores, contratos DTO y ensambladores que conforman esta capa.

**Controladores REST y Endpoints de Comunicación**

La exposición perimetral de los servicios web se organiza en tres controladores anotados con `@RestController`, delimitando con precisión las fronteras operativas del dominio:

- **CustomersController**: Centraliza la administración de la cartera comercial del taller automotriz bajo la ruta base `/api/v1/customers`. Provee rutas semánticamente diferenciadas para el alta de personas naturales (`/individuals`) y empresas de flotas (`/companies`), evitando estructuras polimórficas ambiguas. Asimismo, implementa endpoints para la consulta paginada de clientes filtrada por taller, la inspección detallada por identificador, la actualización idempotente de canales de contacto directo y el listado del parque vehicular bajo titularidad activa del cliente.

- **VehiclesController**: Expone las operaciones vinculadas al parque automotor global bajo `/api/v1/vehicles`. Gestiona el alta técnica de automóviles validando la placa de rodaje y el número de chasis ISO 3779, la consulta técnica por identificador único y la búsqueda por placa normalizada. Para modelar el cambio de custodio sin recurrir a verbos en las rutas, implementa el traspaso de propiedad mediante la creación de un nuevo recurso de custodia bajo `/api/v1/vehicles/{vehicleId}/ownerships`, permitiendo adicionalmente consultar la trazabilidad cronológica de dueños pasados y vigentes.

- **AppointmentsController**: Gobierna el agendamiento y la máquina de estados de las citas previas bajo `/api/v1/appointments`. Ofrece la reserva de atenciones técnicas en sedes físicas, la búsqueda de citas filtradas por sucursal, fecha y estado, y la inspección individual de cada solicitud. Asimismo, expone endpoints de acción mediante peticiones POST para materializar transiciones de estado explícitas con efectos colaterales, tales como la confirmación formal de la cita, el registro de arribo físico a recepción (haciendo que el módulo de operaciones abra automáticamente la orden de trabajo), la reprogramación temporal y la anulación con justificación obligatoria.

En la @tbl:crm-controllers-and-endpoints se detallan los controladores REST, rutas, verbos HTTP y tipos de respuesta asociados.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\raggedright\arraybackslash}p{6.0cm} | >{\raggedright\arraybackslash}p{9.4cm} |}
\caption{Controladores REST y Endpoints de Comunicación de Customer \& Fleet Management (CRM)} \label{tbl:crm-controllers-and-endpoints} \\
\hline
\thfirst{Recurso de Petición} & \thcell{Código y Respuesta HTTP} \\
\hline
\endfirsthead
\hline
\thfirst{Recurso de Petición} & \thcell{Código y Respuesta HTTP} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} CustomersController} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak customers/\allowbreak individuals}} \\*
\hline
\textbf{Petición:} \texttt{Create\allowbreak Individual\allowbreak Customer\allowbreak Resource} & \textbf{Respuesta:} 201 CREATED (\texttt{CustomerResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak customers/\allowbreak companies}} \\*
\hline
\textbf{Petición:} \texttt{Create\allowbreak Company\allowbreak Customer\allowbreak Resource} & \textbf{Respuesta:} 201 CREATED (\texttt{CustomerResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak customers}} \\*
\hline
\textbf{Petición:} Filtros query (\texttt{type}, \texttt{search}, \texttt{status}) & \textbf{Respuesta:} 200 OK (\texttt{List\textless CustomerResource\textgreater}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak customers/\allowbreak \{customerId\}}} \\*
\hline
\textbf{Petición:} Variable de ruta (\texttt{customerId}) & \textbf{Respuesta:} 200 OK (\texttt{CustomerResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{PUT} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak customers/\allowbreak \{customerId\}/\allowbreak contact}} \\*
\hline
\textbf{Petición:} \texttt{Update\allowbreak Customer\allowbreak Contact\allowbreak Resource} & \textbf{Respuesta:} 200 OK (\texttt{CustomerResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak customers/\allowbreak \{customerId\}/\allowbreak vehicles}} \\*
\hline
\textbf{Petición:} Variable de ruta (\texttt{customerId}) & \textbf{Respuesta:} 200 OK (\texttt{List\textless VehicleResource\textgreater}) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} VehiclesController} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak vehicles}} \\*
\hline
\textbf{Petición:} \texttt{CreateVehicleResource} & \textbf{Respuesta:} 201 CREATED (\texttt{VehicleResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak vehicles/\allowbreak \{vehicleId\}}} \\*
\hline
\textbf{Petición:} Variable de ruta (\texttt{vehicleId}) & \textbf{Respuesta:} 200 OK (\texttt{VehicleResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak vehicles/\allowbreak by-plate/\allowbreak \{plate\}}} \\*
\hline
\textbf{Petición:} Variable de ruta (\texttt{plate}) & \textbf{Respuesta:} 200 OK (\texttt{VehicleResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak vehicles/\allowbreak \{vehicleId\}/\allowbreak ownerships}} \\*
\hline
\textbf{Petición:} \texttt{Transfer\allowbreak Vehicle\allowbreak Ownership\allowbreak Resource} & \textbf{Respuesta:} 201 CREATED (\texttt{VehicleOwnershipResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak vehicles/\allowbreak \{vehicleId\}/\allowbreak ownerships}} \\*
\hline
\textbf{Petición:} Variable de ruta (\texttt{vehicleId}) & \textbf{Respuesta:} 200 OK (\texttt{List\textless VehicleOwnershipResource\textgreater}) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Controlador REST:} AppointmentsController} \\*
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak appointments}} \\*
\hline
\textbf{Petición:} \texttt{ScheduleAppointmentResource} & \textbf{Respuesta:} 201 CREATED (\texttt{AppointmentResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak appointments}} \\*
\hline
\textbf{Petición:} Filtros query (\texttt{branchId}, \texttt{date}, \texttt{status}) & \textbf{Respuesta:} 200 OK (\texttt{List\textless AppointmentResource\textgreater}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{GET} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak appointments/\allowbreak \{appointmentId\}}} \\*
\hline
\textbf{Petición:} Variable de ruta (\texttt{appointmentId}) & \textbf{Respuesta:} 200 OK (\texttt{AppointmentResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak appointments/\allowbreak \{appointmentId\}/\allowbreak confirm}} \\*
\hline
\textbf{Petición:} Variable de ruta (\texttt{appointmentId}) & \textbf{Respuesta:} 200 OK (\texttt{AppointmentResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak appointments/\allowbreak \{appointmentId\}/\allowbreak arrive}} \\*
\hline
\textbf{Petición:} Variable de ruta (\texttt{appointmentId}) & \textbf{Respuesta:} 200 OK (\texttt{AppointmentResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak appointments/\allowbreak \{appointmentId\}/\allowbreak reschedule}} \\*
\hline
\textbf{Petición:} \texttt{Reschedule\allowbreak Appointment\allowbreak Resource} & \textbf{Respuesta:} 200 OK (\texttt{AppointmentResource}) \\
\hline
\multicolumn{2}{|>{\raggedright\arraybackslash}p{15.4cm}|}{\textbf{POST} \quad \texttt{/\allowbreak api/\allowbreak v1/\allowbreak appointments/\allowbreak \{appointmentId\}/\allowbreak cancel}} \\*
\hline
\textbf{Petición:} \texttt{CancelAppointmentResource} & \textbf{Respuesta:} 200 OK (\texttt{AppointmentResource}) \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Controladores REST ubicados en com.andeva.atelier.platform.crm.interfaces.rest.controllers.

En sus relaciones de colaboración, estos controladores inyectan de forma exclusiva los servicios de comando y consulta de la Capa de Aplicación, delegando la ejecución transaccional y empleando ensambladores para desacoplar el transporte HTTP del modelo interno.

**Recursos DTO de Petición y Respuesta HTTP**

Para impedir la exposición directa de las entidades de persistencia y garantizar una validación sintáctica rigurosa en la frontera perimetral, la capa implementa estructuras inmutables estructuradas como registros de Java.

Los recursos de petición incorporan restricciones de integridad declarativas mediante anotaciones de Jakarta Bean Validation. Componentes como **CreateIndividualCustomerResource**, **CreateCompanyCustomerResource**, **CreateVehicleResource** y **ScheduleAppointmentResource** comprueban de forma defensiva la no vaciedad de cadenas, la conformidad de documentos de identidad con estándares nacionales (DNI de 8 dígitos y RUC de 11 dígitos), la estructura de placas vehiculares, el cumplimiento de la norma ISO 3779 para números VIN y marcas temporales en tiempo futuro para citas antes de alcanzar los servicios de aplicación.

Por su parte, los recursos de respuesta encapsulan las cargas útiles entregadas a las aplicaciones cliente mediante estructuras estables y optimizadas. Destacan **CustomerResource**, portador del estado comercial y nombre resuelto del cliente; **VehicleResource**, que expone la ficha técnica del vehículo junto con la identidad de su titular vigente; **VehicleOwnershipResource**, representativo del periodo de custodia; y **AppointmentResource**, que provee los metadatos consolidados de la cita para facilitar su renderización en paneles web y dispositivos móviles.

En la @tbl:crm-resources-dtos se especifican los atributos y restricciones de validación de estos recursos DTO.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Recursos DTO de Entrada y Salida del Bounded Context Customer \& Fleet Management (CRM)} \label{tbl:crm-resources-dtos} \\
\hline
\thfirst{Aspecto de Recurso} & \thcell{Especificación de Atributos e Integridad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Recurso} & \thcell{Especificación de Atributos e Integridad} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} CreateIndividualCustomerResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{firstName}, \texttt{lastName}, \texttt{taxId}, \texttt{email}, \texttt{phone} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank}, \texttt{@Size(min = 2, max = 100)}, patrón DNI 8 dígitos, \texttt{@Email} y formato E.164. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} CreateCompanyCustomerResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{companyName}, \texttt{taxId}, \texttt{email}, \texttt{phone} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank}, \texttt{@Size(min = 3, max = 150)}, patrón RUC 11 dígitos, \texttt{@Email} y formato E.164. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} UpdateCustomerContactResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{email}, \texttt{phone} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank}, \texttt{@Email} y validación telefónica E.164. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} CreateVehicleResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{plate}, \texttt{vin}, \texttt{brand}, \texttt{model}, \texttt{year}, \texttt{engineType}, \texttt{initialOwnerId} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank}, patrón placa alfanumérica, VIN ISO 3779, \texttt{@Min(1950)} y \texttt{@NotNull}. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} TransferVehicleOwnershipResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{newOwnerId}, \texttt{transferDate} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotNull} para nuevo propietario y \texttt{@PastOrPresent} para fecha formal de custodia. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} ScheduleAppointmentResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{branchId}, \texttt{customerId}, \texttt{vehicleId}, \texttt{scheduledAt}, \texttt{estimatedDurationMinutes}, \texttt{reason} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotNull} en identificadores, \texttt{@Future} para fecha pactada, \texttt{@Min(15)} y \texttt{@Size(5, 500)}. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} RescheduleAppointmentResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{newScheduledAt} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotNull} y \texttt{@Future} para la nueva marca temporal pactada. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} CancelAppointmentResource \quad (\textit{Categoría:} Petición)} \\*
\hline
\textbf{Atributos Principales} & \texttt{reason} \\*
\hline
\textbf{Validación de Integridad} & Anotaciones \texttt{@NotBlank} y \texttt{@Size(min = 5, max = 250)} para justificación de cancelación. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} CustomerResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{tenantId}, \texttt{type}, \texttt{displayName}, \texttt{taxId}, \texttt{email}, \texttt{phone}, \texttt{status}, \texttt{createdAt} \\*
\hline
\textbf{Validación de Integridad} & Representación pública inmutable de la cartera comercial del taller automotriz. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} VehicleResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{plate}, \texttt{vin}, \texttt{brand}, \texttt{model}, \texttt{year}, \texttt{engineType}, \texttt{currentOwnerId}, \texttt{currentOwnerName} \\*
\hline
\textbf{Validación de Integridad} & Ficha automotriz universal con identificación desnormalizada del custodio vigente. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} VehicleOwnershipResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{vehicleId}, \texttt{customerId}, \texttt{ownerName}, \texttt{startDate}, \texttt{endDate}, \texttt{isCurrent} \\*
\hline
\textbf{Validación de Integridad} & Registro inmutable del periodo temporal de titularidad y custodia física del vehículo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Recurso DTO:} AppointmentResource \quad (\textit{Categoría:} Respuesta)} \\*
\hline
\textbf{Atributos Principales} & \texttt{id}, \texttt{tenantId}, \texttt{branchId}, \texttt{customerId}, \texttt{customerName}, \texttt{vehicleId}, \texttt{vehiclePlate}, \texttt{scheduledAt}, \texttt{status} \\*
\hline
\textbf{Validación de Integridad} & Ficha operativa de cita previa con nombres y placas resueltos para visualización cliente. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes ubicados en el paquete com.andeva.atelier.platform.crm.interfaces.rest.resources.

**Ensambladores y Transformadores de Recursos**

El desacoplamiento entre los contratos de transporte web y los modelos transaccionales de aplicación se consolida a través de ensambladores bidireccionales dedicados.

Los ensambladores de entrada procesan las cargas útiles de las peticiones HTTP y construyen comandos inmutables de aplicación, inyectando identificadores de ruta y resolviendo conversiones tipadas. Entre ellos, destacan **RegisterCustomerCommandFromResourceAssembler**, que bifurca el mapeo según el tipo de cliente suministrado, **RegisterVehicleCommandFromResourceAssembler**, que traduce las especificaciones técnicas del vehículo, y **ScheduleAppointmentCommandFromResourceAssembler**, que compone los parámetros temporales y de localización física.

En sentido inverso, los ensambladores de salida proyectan las raíces de agregado y entidades del dominio hacia representaciones DTO públicas. Componentes como **CustomerResourceFromAggregateAssembler**, **VehicleResourceFromAggregateAssembler**, **VehicleOwnershipResourceFromEntityAssembler** y **AppointmentResourceFromAggregateAssembler** formatean valores monetarios y temporales, resolviendo denominaciones amigables sin forzar consultas circulares en el cliente.

En la @tbl:crm-resource-assemblers se detallan los métodos y tipos de transformación ejecutados por estos ensambladores.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.1cm} | >{\raggedright\arraybackslash}p{10.3cm} |}
\caption{Ensambladores de Recursos del Bounded Context Customer \& Fleet Management (CRM)} \label{tbl:crm-resource-assemblers} \\
\hline
\thfirst{Aspecto del Ensamblador} & \thcell{Firma y Transformación de Tipos} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Ensamblador} & \thcell{Firma y Transformación de Tipos} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Register\allowbreak Customer\allowbreak Command\allowbreak From\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{CreateIndividualCustomerResource / CreateCompanyCustomerResource,\allowbreak  UUID} $\longrightarrow$ \texttt{RegisterCustomerCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Update\allowbreak Customer\allowbreak Contact\allowbreak Command\allowbreak From\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{UpdateCustomerContactResource,\allowbreak  UUID} $\longrightarrow$ \texttt{UpdateCustomerContactCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Register\allowbreak Vehicle\allowbreak Command\allowbreak From\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{CreateVehicleResource} $\longrightarrow$ \texttt{RegisterVehicleCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Transfer\allowbreak Vehicle\allowbreak Ownership\allowbreak Command\allowbreak From\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{TransferVehicleOwnershipResource,\allowbreak  UUID} $\longrightarrow$ \texttt{TransferVehicleOwnershipCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Schedule\allowbreak Appointment\allowbreak Command\allowbreak From\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{ScheduleAppointmentResource,\allowbreak  UUID} $\longrightarrow$ \texttt{ScheduleAppointmentCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Reschedule\allowbreak Appointment\allowbreak Command\allowbreak From\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{RescheduleAppointmentResource,\allowbreak  UUID} $\longrightarrow$ \texttt{RescheduleAppointmentCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Cancel\allowbreak Appointment\allowbreak Command\allowbreak From\allowbreak Resource\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toCommandFromResource} \\*
\hline
\textbf{Transformación} & \texttt{CancelAppointmentResource,\allowbreak  UUID} $\longrightarrow$ \texttt{CancelAppointmentCommand} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Customer\allowbreak Resource\allowbreak From\allowbreak Aggregate\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResourceFromAggregate} \\*
\hline
\textbf{Transformación} & \texttt{Customer} $\longrightarrow$ \texttt{CustomerResource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Vehicle\allowbreak Resource\allowbreak From\allowbreak Aggregate\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResourceFromAggregate} \\*
\hline
\textbf{Transformación} & \texttt{Vehicle,\allowbreak  Customer} $\longrightarrow$ \texttt{VehicleResource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Vehicle\allowbreak Ownership\allowbreak Resource\allowbreak From\allowbreak Entity\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResourceFromEntity} \\*
\hline
\textbf{Transformación} & \texttt{VehicleOwnership,\allowbreak  Customer} $\longrightarrow$ \texttt{VehicleOwnershipResource} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador:} Appointment\allowbreak Resource\allowbreak From\allowbreak Aggregate\allowbreak Assembler} \\*
\hline
\textbf{Método Principal} & \texttt{toResourceFromAggregate} \\*
\hline
\textbf{Transformación} & \texttt{Appointment,\allowbreak  Customer,\allowbreak  Vehicle} $\longrightarrow$ \texttt{AppointmentResource} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Clases ubicadas bajo el paquete com.andeva.atelier.platform.crm.interfaces.rest.transform.

**Fachada de Contexto Abierto (Open Host Service / Inbound ACL)**

Con el propósito de mantener el aislamiento de dominio y evitar dependencias circulares con otros módulos del backend, la capa de interfaz expone una fachada pública en memoria sustentada en los patrones Open Host Service y Capa Anticorrupción de entrada.

Este mecanismo se instrumenta en la interfaz **CustomerFleetContextFacade**, alojada en el paquete canónico **com.andeva.atelier.platform.crm.interfaces.acl**. Dicha fachada proporciona métodos síncronos de consulta para que módulos consumidores como Workshop Operations (MRO), Facturación Electrónica (Invoicing) e IoT Telemetry verifiquen la existencia de clientes, obtengan la ficha técnica de un automóvil por identificador o placa de rodaje, resuelvan el titular legítimo para la emisión de comprobantes o consulten el estado de una cita técnica.

La implementación **CustomerFleetContextFacadeImpl** delega estas operaciones en los repositorios y servicios de aplicación de CRM, convirtiendo las entidades internas en registros inmutables de frontera (**CustomerAclDto**, **VehicleAclDto** y **AppointmentAclDto**), preservando la integridad de los agregados.

En la @tbl:crm-customer-fleet-facade se especifican los métodos y tipos de la fachada de contexto abierto.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Métodos de la Fachada de Contexto Abierto CustomerFleetContextFacade} \label{tbl:crm-customer-fleet-facade} \\
\hline
\thfirst{Aspecto del Contrato} & \thcell{Firma, Retorno y Consumidores} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Contrato} & \thcell{Firma, Retorno y Consumidores} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{fetchCustomerById}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID customerId} $\longrightarrow$ \texttt{Optional<\allowbreak CustomerAclDto>\allowbreak } \\*
\hline
\textbf{Módulos Consumidores} & Invoicing (Facturación electrónica), Workshop Operations (MRO), Billing \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{fetchVehicleById}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID vehicleId} $\longrightarrow$ \texttt{Optional<\allowbreak VehicleAclDto>\allowbreak } \\*
\hline
\textbf{Módulos Consumidores} & Workshop Operations (MRO), IoT Telemetry, Inventory \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{fetchVehicleByPlate}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{String plate} $\longrightarrow$ \texttt{Optional<\allowbreak VehicleAclDto>\allowbreak } \\*
\hline
\textbf{Módulos Consumidores} & Workshop Operations (Recepción rápida en taller), IoT Telemetry \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{fetchCurrentOwnerId}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID vehicleId} $\longrightarrow$ \texttt{Optional<\allowbreak UUID>\allowbreak } \\*
\hline
\textbf{Módulos Consumidores} & Invoicing (Emisión de comprobante al custodio), Atelier Driver (App móvil) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{fetchAppointmentById}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID appointmentId} $\longrightarrow$ \texttt{Optional<\allowbreak AppointmentAclDto>\allowbreak } \\*
\hline
\textbf{Módulos Consumidores} & Workshop Operations (MRO conversión a Orden de Trabajo) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Método de Fachada:} \texttt{markAppointmentAsConvertedToWorkOrder}} \\*
\hline
\textbf{Parámetros y Retorno} & \texttt{UUID appointmentId} $\longrightarrow$ \texttt{boolean} \\*
\hline
\textbf{Módulos Consumidores} & Workshop Operations (MRO registro de ingreso físico a bahía) \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al paquete com.andeva.atelier.platform.crm.interfaces.acl.

**Eventos de Integración (Published Language)**

Para la sincronización reactiva e intermodular sin acoplamiento temporal ni dependencias de persistencia directa, el Bounded Context CRM define un lenguaje publicado conformado por cinco eventos de integración inmutables.

Estos eventos notifican hitos sustanciales del ciclo de vida del negocio: **CustomerCreatedIntegrationEvent** permite a Facturación Electrónica precargar perfiles fiscales de clientes; **VehicleRegisteredIntegrationEvent** y **VehicleOwnershipTransferredIntegrationEvent** posibilitan a IoT Telemetry provisionar dispositivos OBD2 y reasignar privilegios telemétricos hacia la aplicación móvil del nuevo custodio; finalmente, **AppointmentScheduledIntegrationEvent** y **AppointmentArrivedIntegrationEvent** informan a Workshop Operations sobre la demanda esperada y desencadenan la apertura de órdenes de trabajo preliminares ante la llegada física del automóvil.

En la @tbl:crm-integration-events se sintetiza la estructura de estos eventos de integración.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Eventos de Integración del Bounded Context Customer \& Fleet Management (CRM)} \label{tbl:crm-integration-events} \\
\hline
\thfirst{Aspecto de Integración} & \thcell{Carga Útil y Sincronización Intermodular} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Integración} & \thcell{Carga Útil y Sincronización Intermodular} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} CustomerCreatedIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{customerId}, \texttt{tenantId}, \texttt{displayName}, \texttt{taxId}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Invoicing \\*
\hline
\textbf{Propósito} & Pre-carga de datos fiscales en el catálogo de clientes receptores de comprobantes electrónicos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} VehicleRegisteredIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{vehicleId}, \texttt{plate}, \texttt{vin}, \texttt{ownerId}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & IoT Telemetry \\*
\hline
\textbf{Propósito} & Alta automática de vehículo en plataforma telemétrica para provisión de dispositivos OBD2. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} VehicleOwnershipTransferredIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{vehicleId}, \texttt{previousOwnerId}, \texttt{newOwnerId}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & IoT Telemetry, Atelier Driver \\*
\hline
\textbf{Propósito} & Reasignación de permisos de monitoreo telemétrico hacia la cuenta del nuevo custodio. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} AppointmentScheduledIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{appointmentId}, \texttt{tenantId}, \texttt{branchId}, \texttt{customerId}, \texttt{vehicleId}, \texttt{scheduledAt}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Workshop Operations (MRO) \\*
\hline
\textbf{Propósito} & Previsión de capacidad de bahías operativas y asignación temprana de técnicos especialistas. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Evento de Integración:} AppointmentArrivedIntegrationEvent} \\*
\hline
\textbf{Atributos Transportados} & \texttt{appointmentId}, \texttt{tenantId}, \texttt{branchId}, \texttt{customerId}, \texttt{vehicleId}, \texttt{occurredOn} \\*
\hline
\textbf{Módulos Receptores} & Workshop Operations (MRO) \\*
\hline
\textbf{Propósito} & Apertura automática de Orden de Trabajo de recepción y generación de checklist vehicular. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Registros inmutables pertenecientes al paquete com.andeva.atelier.platform.crm.interfaces.events.



#### 2.6.3.3. Application Layer

La capa de aplicación del Bounded Context de Customer & Fleet Management (CRM) orquesta
los casos de uso transaccionales de alta de clientes particulares y flotas corporativas,
administración del catálogo universal vehicular, trazabilidad histórica de custodias,
planificación de citas técnicas y transiciones de estado de recepción en la plataforma
Atelier.

Ubicada en el paquete canónico com.andeva.atelier.platform.crm.application, su concepción
arquitectónica implementa una separación rigurosa bajo el patrón CQRS, desacoplando los
flujos mutacionales de escritura de las proyecciones de solo lectura a través de cuatro
directrices esenciales de diseño:

- **Orquestación Transaccional Atómica:** Delimitación de fronteras de consistencia
mediante la anotación de servicio transaccional con nivel de aislamiento de lectura
confirmada. Esta estrategia asegura atomicidad estricta en operaciones multiorigen que
coordinan la validación fiscal de documentos, la verificación de cuotas SaaS, el alta de
clientes y la inicialización de custodias vehiculares.

- **Flujo Determinista sin Excepciones:** Adopción del tipo de resultado sellado
**Result<T, ApplicationError>** para gobernar las respuestas de los casos de uso. Las
condiciones de fallo previsibles vinculadas a colisiones de documentos de identidad, placas
automotrices preexistentes o saturación de bahías se tratan como valores inmutables de
retorno, imponiendo verificación exhaustiva mediante coincidencia de patrones.

- **Coreografía de Eventos de Dominio e Integración:** Manejo dual de eventos mediante
oyentes locales para tareas accesorias sincrónicas y oyentes posteriores a la confirmación
transaccional para la propagación de eventos de integración hacia el Transactional Outbox,
asegurando consistencia eventual con los módulos de facturación, telemetría y operaciones.

- **Inversión de Dependencias y Aislamiento Perimetral:** Abstracción de servicios de
infraestructura externos mediante puertos de salida específicos para geocodificación de
direcciones corporativas, despacho de notificaciones push móviles hacia conductores y
verificación de cuotas contractuales del taller mecánico.

A fin de ofrecer una visión sistemática de estos componentes, en la
@tbl:crm-application-types se presenta el catálogo consolidado de las clases, interfaces y
registros que estructuran la Capa de Aplicación de Customer & Fleet Management (CRM).

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo Consolidado de la Capa de Aplicación de Customer \& Fleet Management (CRM)} \label{tbl:crm-application-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\
\hline
\endhead
Customer\allowbreak Command\allowbreak Service & Contrato de casos de uso de escritura para clientes particulares y empresas de flota. \\*
\hline
\textbf{Categoría} & Servicio de Comando \\*
\hline
\textbf{Relaciones} & Implementado por CustomerCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Customer\allowbreak Command\allowbreak ServiceImpl & Orquesta el alta, actualización y desactivación de clientes con validación fiscal. \\*
\hline
\textbf{Categoría} & Implementación de Comando \\*
\hline
\textbf{Relaciones} & Coordina agregado Customer y repositorios con persistencia ACID. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Command\allowbreak Service & Contrato para registro universal y traspaso formal de titularidad automotriz. \\*
\hline
\textbf{Categoría} & Servicio de Comando \\*
\hline
\textbf{Relaciones} & Implementado por VehicleCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Command\allowbreak ServiceImpl & Administra el catálogo global vehicular y gestiona periodos de custodia inmutables. \\*
\hline
\textbf{Categoría} & Implementación de Comando \\*
\hline
\textbf{Relaciones} & Coordina agregados Vehicle y VehicleOwnership. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Appointment\allowbreak Command\allowbreak Service & Contrato de casos de uso para agendamiento y transiciones de estado de citas. \\*
\hline
\textbf{Categoría} & Servicio de Comando \\*
\hline
\textbf{Relaciones} & Implementado por AppointmentCommandServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Appointment\allowbreak Command\allowbreak ServiceImpl & Orquesta la máquina de estados de citas y coordina efectos colaterales de arribo. \\*
\hline
\textbf{Categoría} & Implementación de Comando \\*
\hline
\textbf{Relaciones} & Coordina agregado Appointment y emite eventos de dominio. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Customer\allowbreak Query\allowbreak Service & Contrato de recuperación de clientes por identificador o documento tributario. \\*
\hline
\textbf{Categoría} & Servicio de Consulta \\*
\hline
\textbf{Relaciones} & Implementado por CustomerQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Customer\allowbreak Query\allowbreak ServiceImpl & Consultas de lectura optimizada de clientes y segmentación de cartera por taller. \\*
\hline
\textbf{Categoría} & Implementación de Consulta \\*
\hline
\textbf{Relaciones} & Accede a CustomerRepository en modo de solo lectura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Query\allowbreak Service & Contrato de consulta técnica de vehículos, placas y trazabilidad de dueños. \\*
\hline
\textbf{Categoría} & Servicio de Consulta \\*
\hline
\textbf{Relaciones} & Implementado por VehicleQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Query\allowbreak ServiceImpl & Proyecta fichas automotrices y cadenas históricas de tenencia vehicular. \\*
\hline
\textbf{Categoría} & Implementación de Consulta \\*
\hline
\textbf{Relaciones} & Accede a VehicleRepository y VehicleOwnershipRepository. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Appointment\allowbreak Query\allowbreak Service & Contrato de lectura para agenda de citas por sede física, fecha y estado. \\*
\hline
\textbf{Categoría} & Servicio de Consulta \\*
\hline
\textbf{Relaciones} & Implementado por AppointmentQueryServiceImpl. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Appointment\allowbreak Query\allowbreak ServiceImpl & Proyecciones de citas previas para planificación operativa de bahías. \\*
\hline
\textbf{Categoría} & Implementación de Consulta \\*
\hline
\textbf{Relaciones} & Accede a AppointmentRepository en modo de solo lectura. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak application.\allowbreak services} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Customer\allowbreak Domain\allowbreak Events\allowbreak Handler & Suscriptor de eventos de cliente para sincronización asíncrona hacia facturación. \\*
\hline
\textbf{Categoría} & Manejador de Eventos \\*
\hline
\textbf{Relaciones} & Construye eventos de integración para el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak application.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Vehicle\allowbreak Domain\allowbreak Events\allowbreak Handler & Suscriptor de eventos vehiculares y traspasos para provisión en IoT Telemetry. \\*
\hline
\textbf{Categoría} & Manejador de Eventos \\*
\hline
\textbf{Relaciones} & Deposita eventos de integración en el Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak application.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Appointment\allowbreak Domain\allowbreak Events\allowbreak Handler & Suscriptor dual de citas para notificaciones push móviles y apertura de ODT en MRO. \\*
\hline
\textbf{Categoría} & Manejador de Eventos \\*
\hline
\textbf{Relaciones} & Despacha push vía FCM y publica eventos de integración. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak application.\allowbreak events} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Places\allowbreak Address\allowbreak Verification\allowbreak Gateway & Interfaz de pasarela perimetral para normalización geográfica de direcciones. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Implementado en la Capa de Infraestructura vía Google Places API. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak application.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Driver\allowbreak App\allowbreak Push\allowbreak Gateway & Interfaz de pasarela para envío de notificaciones push hacia la app móvil del conductor. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Implementado en Infraestructura mediante Firebase Cloud Messaging. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak application.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Subscription\allowbreak Validation\allowbreak Service & Interfaz para verificación de cuotas y límites contratados en el plan SaaS del taller. \\*
\hline
\textbf{Categoría} & Puerto de Salida \\*
\hline
\textbf{Relaciones} & Consulta al Bounded Context Billing para gobernanza de límites. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak application.\allowbreak acl} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Capa} \\*
\hline
Verified\allowbreak Address\allowbreak Dto & Registro inmutable portador de la dirección normalizada y coordenadas resueltas. \\*
\hline
\textbf{Categoría} & Modelo de Frontera \\*
\hline
\textbf{Relaciones} & Entregado por PlacesAddressVerificationGateway. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak application.\allowbreak model} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al paquete canónico com.andeva.atelier.platform.crm.application.

**Servicios de Comandos y Orquestación Transaccional**

Los flujos de modificación de estado se implementan mediante servicios orquestadores
decorados con anotaciones transaccionales que delimitan el alcance de persistencia y
garantizan el cumplimiento de invariantes de negocio en el modelo.

El servicio **CustomerCommandServiceImpl** centraliza el alta y gestión de clientes. Al
procesar **RegisterIndividualCustomerCommand**, verifica la unicidad del documento nacional
de identidad y del correo electrónico en el taller activo, comprueba la cuota máxima del
plan SaaS contratado mediante **SubscriptionValidationService** y persiste el agregado
**Customer** asociando sus datos de contacto.

Cuando procesa **RegisterCompanyCustomerCommand**, valida el Registro Único de Contribuyentes,
solicita la estandarización y coordenadas del domicilio fiscal corporativo a través de
**PlacesAddressVerificationGateway** y registra la empresa. Asimismo, el servicio gobierna
la actualización de información de contacto y la desactivación lógica de clientes que no
mantengan citas activas ni órdenes pendientes.

Por su parte, **VehicleCommandServiceImpl** administra el ciclo de vida del catálogo
automotriz universal. Al ejecutar **RegisterVehicleCommand**, normaliza la placa de rodaje,
comprueba su inexistencia global en la base de datos, valida el número de chasis bajo el
estándar ISO 3779 e inicializa el historial de pertenencia vinculando al titular con una
entidad **VehicleOwnership** activa.

En el traspaso de titularidad vehicular mediante **TransferVehicleOwnershipCommand**,
verifica la solvencia del nuevo cliente en el taller, cierra el intervalo temporal de la
custodia anterior asignando fecha de término y registra el nuevo periodo de titularidad,
emitiendo el evento de dominio correspondiente para su sincronización perimetral.

Finalmente, **AppointmentCommandServiceImpl** orquesta la máquina de estados de las citas
del taller. Mediante **ScheduleAppointmentCommand**, asegura una antelación mínima de dos
horas, verifica la disponibilidad simultánea de bahías de atención y crea la cita en estado
pendiente.

Posteriormente, administra las confirmaciones (**ConfirmAppointmentCommand**) con despacho
de alertas móviles, registra el arribo vehicular (**MarkAppointmentArrivedCommand**) para
desencadenar la apertura de la orden de trabajo en operaciones de taller, y procesa
reprogramaciones o cancelaciones justificadas.

Para sintetizar los flujos mutacionales, en la @tbl:crm-command-services se detallan las
operaciones, comandos de entrada, invariantes de consistencia transaccional y tipos de
retorno de los servicios de comandos.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Operaciones Transaccionales de los Servicios de Comandos de Customer \& Fleet Management (CRM)} \label{tbl:crm-command-services} \\
\hline
\thfirst{Aspecto de Operación} & \thcell{Especificación de Orquestación y Consistencia} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Operación} & \thcell{Especificación de Orquestación y Consistencia} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} CustomerCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{RegisterIndividualCustomerCommand} $\longrightarrow$ \texttt{Result<\allowbreak Customer,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida DNI de 8 dígitos y unicidad en taller. Verifica cuota SaaS y crea cliente con nombre y contacto. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} CustomerCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{RegisterCompanyCustomerCommand} $\longrightarrow$ \texttt{Result<\allowbreak Customer,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida RUC de 11 dígitos, verifica dirección corporativa en Google Places y registra empresa de flota. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} CustomerCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{UpdateCustomerContactCommand} $\longrightarrow$ \texttt{Result<\allowbreak Customer,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Verifica existencia de cliente en taller y actualiza correo electrónico y teléfono E.164. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} CustomerCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{DeactivateCustomerCommand} $\longrightarrow$ \texttt{Result<\allowbreak Customer,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Comprueba ausencia de citas activas u órdenes de trabajo abiertas en MRO y transiciona a inactivo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} VehicleCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{RegisterVehicleCommand} $\longrightarrow$ \texttt{Result<\allowbreak Vehicle,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida placa normalizada única, formato VIN ISO 3779 y vincula el primer titular en historial. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} VehicleCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{TransferVehicleOwnershipCommand} $\longrightarrow$ \texttt{Result<\allowbreak Vehicle,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Verifica nuevo cliente en taller, cierra custodia vigente y crea nuevo segmento temporal de titularidad. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} AppointmentCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{ScheduleAppointmentCommand} $\longrightarrow$ \texttt{Result<\allowbreak Appointment,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida cliente, vehículo, sede y antelación mínima de 2 horas. Comprueba cupo en bahías y crea cita PENDING. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} AppointmentCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{ConfirmAppointmentCommand} $\longrightarrow$ \texttt{Result<\allowbreak Appointment,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Transiciona cita a CONFIRMED y emite evento para notificación push móvil al conductor. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} AppointmentCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{MarkAppointmentArrivedCommand} $\longrightarrow$ \texttt{Result<\allowbreak Appointment,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Transiciona a ARRIVED y emite evento que desencadena apertura automática de WorkOrder en MRO. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} AppointmentCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{RescheduleAppointmentCommand} $\longrightarrow$ \texttt{Result<\allowbreak Appointment,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida estado no finalizado, comprueba disponibilidad en nueva franja horaria y reprograma. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} AppointmentCommandService \quad (\texttt{handle})} \\*
\hline
\textbf{Comando y Retorno} & \texttt{CancelAppointmentCommand} $\longrightarrow$ \texttt{Result<\allowbreak Appointment,\allowbreak  ApplicationError>\allowbreak } \\*
\hline
\textbf{Reglas de Consistencia} & Valida que vehículo no esté en patio, registra motivo de anulación y transiciona a CANCELED. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes ubicados en el paquete com.andeva.atelier.platform.crm.application.services.

**Servicios de Consulta y Proyección de Datos**

Las operaciones de recuperación de información se estructuran mediante servicios de
consulta especializados anotados con transaccionalidad de solo lectura, permitiendo a la
infraestructura relacional omitir la gestión de instantáneas de detección de cambios.

Los tres servicios de consulta atienden las necesidades de visualización y filtrado del
contexto: **CustomerQueryServiceImpl** recupera fichas individuales de clientes por
identificador interno o documento de identidad, y suministra listados paginados aplicando
criterios de tipo de cliente y búsquedas por coincidencia de texto.

En el ámbito automotriz, **VehicleQueryServiceImpl** expone la consulta técnica universal
de vehículos por identificador, la búsqueda rápida por placa de rodaje normalizada, la flota
vigente asociada a un titular y el historial cronológico completo de transferencias de
custodia del automotor.

De forma complementaria, **AppointmentQueryServiceImpl** proporciona los detalles
operativos de citas agendadas, proyecta la programación de recepciones filtrada por sede
física y fecha de calendario, y expone el historial de visitas solicitado por cada cliente.

Con el propósito de ilustrar las vías de recuperación de datos, en la
@tbl:crm-query-services se presentan los métodos, parámetros de consulta y tipos
proyectados por los servicios de consulta.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Métodos de Consulta de la Capa de Aplicación de Customer \& Fleet Management (CRM)} \label{tbl:crm-query-services} \\
\hline
\thfirst{Aspecto de Consulta} & \thcell{Especificación Técnica y Recuperación} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Consulta} & \thcell{Especificación Técnica y Recuperación} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} CustomerQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetCustomerByIdQuery} $\longrightarrow$ \texttt{Optional<\allowbreak Customer>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Consulta de ficha de cliente por identificador dentro del taller autenticado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} CustomerQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetCustomersByTenantIdQuery} $\longrightarrow$ \texttt{List<\allowbreak Customer>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Listado paginado de clientes con filtros opcionales de tipo y texto. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} CustomerQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetCustomerByTaxIdQuery} $\longrightarrow$ \texttt{Optional<\allowbreak Customer>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Localización rápida de cliente por DNI o RUC tributario. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} VehicleQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetVehicleByIdQuery} $\longrightarrow$ \texttt{Optional<\allowbreak Vehicle>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Consulta técnica universal de vehículo por identificador UUID. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} VehicleQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetVehicleByPlateQuery} $\longrightarrow$ \texttt{Optional<\allowbreak Vehicle>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Búsqueda vehicular rápida por placa de rodaje normalizada. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} VehicleQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetVehiclesByCustomerIdQuery} $\longrightarrow$ \texttt{List<\allowbreak Vehicle>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Flota de vehículos actualmente bajo titularidad activa del cliente. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} VehicleQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetVehicleOwnershipHistoryQuery} $\longrightarrow$ \texttt{List<\allowbreak VehicleOwnership>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Historial cronológico completo de transferencias y custodios del vehículo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} AppointmentQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetAppointmentByIdQuery} $\longrightarrow$ \texttt{Optional<\allowbreak Appointment>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Detalle operativo individual de una cita técnica agendada. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} AppointmentQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetAppointmentsByTenantAndBranchQuery} $\longrightarrow$ \texttt{List<\allowbreak Appointment>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Agenda de citas por sede física y fecha para gestión de recepción. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Servicio:} AppointmentQueryService \quad (\texttt{handle})} \\*
\hline
\textbf{Parámetro y Proyección} & \texttt{GetAppointmentsByCustomerQuery} $\longrightarrow$ \texttt{List<\allowbreak Appointment>\allowbreak } \\*
\hline
\textbf{Propósito de Consulta} & Historial de solicitudes de atención técnica agendadas por un cliente. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Métodos configurados con transaccionalidad de solo lectura en el paquete com.andeva.atelier.platform.crm.application.services.

**Manejadores de Eventos de Dominio y Publicación Asíncrona**

El desacoplamiento entre casos de uso mutacionales y sus efectos secundarios se articula a
través de tres manejadores de eventos en memoria que responden a las mutaciones
confirmadas de las entidades del dominio.

El componente **CustomerDomainEventsHandler** captura la emisión de **CustomerCreatedEvent**
tras la confirmación transaccional en la base de datos, estructurando y depositando el
evento de integración **CustomerCreatedIntegrationEvent** en el Transactional Outbox para la
sincronización con el módulo de facturación.

De manera paralela, **VehicleDomainEventsHandler** responde a **VehicleRegisteredEvent** y
**VehicleOwnershipTransferredEvent** en fase posterior a la confirmación, publicando los
eventos de integración requeridos por el módulo de telemetría IoT para la provisión de
dispositivos OBD2 y la asignación del vehículo en la aplicación móvil de conductores.

Por último, **AppointmentDomainEventsHandler** implementa un esquema de manejo dual según
la naturaleza del efecto colateral. Ante **AppointmentConfirmedEvent** y
**AppointmentCanceledEvent**, actúa de forma sincrónica inmediata despachando
notificaciones push al smartphone del cliente mediante **DriverAppPushGateway**.

Por el contrario, ante **AppointmentScheduledEvent** y **AppointmentArrivedEvent**, opera
tras la confirmación de la transacción, publicando eventos de integración en el
Transactional Outbox para que el módulo de operaciones de taller anticipe la demanda o
inicie la apertura automática de la orden de trabajo preliminar.

A fin de resumir la arquitectura de eventos, en la @tbl:crm-event-handlers se especifican
las responsabilidades, fases transaccionales y destinos de los manejadores de eventos de
la capa.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Manejadores de Eventos de Dominio de Customer \& Fleet Management (CRM)} \label{tbl:crm-event-handlers} \\
\hline
\thfirst{Aspecto del Manejador} & \thcell{Orquestación y Efecto Colateral} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Manejador} & \thcell{Orquestación y Efecto Colateral} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} CustomerDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{CustomerCreatedEvent} \quad (\textit{Fase:} Posterior a confirmación) \\*
\hline
\textbf{Acción Orquestada} & Traduce y publica CustomerCreatedIntegrationEvent para el catálogo de clientes de facturación. \\*
\hline
\textbf{Destino del Efecto} & Transactional Outbox / Event Bus \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} VehicleDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{VehicleRegisteredEvent} \quad (\textit{Fase:} Posterior a confirmación) \\*
\hline
\textbf{Acción Orquestada} & Publica VehicleRegisteredIntegrationEvent para provisión telemétrica de dispositivos OBD2. \\*
\hline
\textbf{Destino del Efecto} & Transactional Outbox / Event Bus \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} VehicleDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{VehicleOwnershipTransferredEvent} \quad (\textit{Fase:} Posterior a confirmación) \\*
\hline
\textbf{Acción Orquestada} & Publica VehicleOwnershipTransferredIntegrationEvent para reasignación en Atelier Driver e IoT. \\*
\hline
\textbf{Destino del Efecto} & Transactional Outbox / Event Bus \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} AppointmentDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{AppointmentScheduledEvent} \quad (\textit{Fase:} Posterior a confirmación) \\*
\hline
\textbf{Acción Orquestada} & Publica AppointmentScheduledIntegrationEvent para previsión de capacidad en bahías técnicas. \\*
\hline
\textbf{Destino del Efecto} & Transactional Outbox / Event Bus \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} AppointmentDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{AppointmentConfirmedEvent} \quad (\textit{Fase:} Inmediata) \\*
\hline
\textbf{Acción Orquestada} & Despacha alerta push móvil al smartphone del conductor con datos de fecha y sede. \\*
\hline
\textbf{Destino del Efecto} & DriverAppPushGateway (FCM) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} AppointmentDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{AppointmentArrivedEvent} \quad (\textit{Fase:} Posterior a confirmación) \\*
\hline
\textbf{Acción Orquestada} & Publica AppointmentArrivedIntegrationEvent que desencadena la apertura de Orden de Trabajo en MRO. \\*
\hline
\textbf{Destino del Efecto} & Transactional Outbox / Event Bus \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Manejador:} AppointmentDomainEventsHandler} \\*
\hline
\textbf{Evento Capturado} & \texttt{AppointmentCanceledEvent} \quad (\textit{Fase:} Inmediata) \\*
\hline
\textbf{Acción Orquestada} & Remite notificación push informando la anulación formal de la cita al cliente. \\*
\hline
\textbf{Destino del Efecto} & DriverAppPushGateway (FCM) \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Clases ubicadas bajo el paquete com.andeva.atelier.platform.crm.application.events.

**Puertos de Salida y Pasarelas de Integración**

Para preservar la independencia de la lógica de negocio respecto a bibliotecas
propietarias y servicios perimetrales, la capa define contratos de puertos de salida que
aíslan al dominio de dependencias de infraestructura externa.

El puerto **PlacesAddressVerificationGateway** encapsula la interacción con servicios de
geocodificación externa, resolviendo la estandarización de direcciones y coordenadas
geográficas WGS84 para clientes corporativos de flota sin acoplar el servicio de comando al
cliente HTTP subyacente.

Por su parte, **DriverAppPushGateway** abstrae los mecanismos de comunicación móvil en tiempo
real basados en Firebase Cloud Messaging, gestionando la entrega de alertas operativas
sobre citas agendadas, confirmadas o anuladas hacia la aplicación móvil de conductores.

Asimismo, **SubscriptionValidationService** establece el enlace de consulta síncrona hacia
el contexto de facturación y membresías, garantizando que el alta de clientes y vehículos
respete rigurosamente las cuotas contratadas por el taller en su suscripción SaaS.

Finalmente, el registro inmutable **VerifiedAddressDto** materializa el modelo de frontera
que encapsula los datos geográficos normalizados y coordenadas resueltas, evitando la
exposición de tipos externos dentro del núcleo de la aplicación.

Con el objeto de sistematizar las dependencias perimetrales, en la @tbl:crm-outbound-ports
se describen los métodos y responsabilidades técnicas de estos puertos de salida y modelos
de frontera.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.1cm} | >{\raggedright\arraybackslash}p{10.3cm} |}
\caption{Puertos de Salida y Pasarelas de la Capa de Aplicación de Customer \& Fleet Management (CRM)} \label{tbl:crm-outbound-ports} \\
\hline
\thfirst{Aspecto del Componente} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto del Componente} & \thcell{Especificación Técnica y Responsabilidad} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} PlacesAddressVerificationGateway \quad (\textit{Categoría:} Puerto de Salida)} \\*
\hline
\textbf{Métodos Principales} & \texttt{verifyAddress} \\*
\hline
\textbf{Responsabilidad Técnica} & Validación, georreferenciación y normalización de direcciones corporativas vía Google Places API. \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak application.\allowbreak acl} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} DriverAppPushGateway \quad (\textit{Categoría:} Puerto de Salida)} \\*
\hline
\textbf{Métodos Principales} & \texttt{sendPushNotification} \\*
\hline
\textbf{Responsabilidad Técnica} & Emisión de notificaciones push móviles hacia Atelier Driver mediante Firebase Cloud Messaging (FCM). \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak application.\allowbreak acl} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} SubscriptionValidationService \quad (\textit{Categoría:} Puerto de Salida)} \\*
\hline
\textbf{Métodos Principales} & \texttt{validateCustomerQuota}, \texttt{validateVehicleQuota} \\*
\hline
\textbf{Responsabilidad Técnica} & Consulta síncrona de cuotas activas hacia el módulo de Billing para gobernar límites del plan SaaS. \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak application.\allowbreak acl} \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Puerto de Salida:} VerifiedAddressDto \quad (\textit{Categoría:} Modelo de Frontera)} \\*
\hline
\textbf{Métodos Principales} & \texttt{formattedAddress}, \texttt{latitude}, \texttt{longitude}, \texttt{postalCode} \\*
\hline
\textbf{Responsabilidad Técnica} & Registro inmutable portador de la dirección normalizada y coordenadas resueltas por la pasarela. \\*
\hline
\textbf{Paquete Canónico} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak application.\allowbreak model} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Interfaces y registros ubicados en com.andeva.atelier.platform.crm.application.acl y model.

#### 2.6.3.4. Infrastructure Layer

La Capa de Infraestructura del Bounded Context Customer & Fleet Management (CRM) materializa técnicamente los puertos de persistencia física y comunicación perimetral definidos en los contratos de Dominio y Aplicación. Su implementación reside en el paquete canónico com.andeva.atelier.platform.crm.infrastructure, proveyendo el soporte relacional en PostgreSQL 16 sobre la infraestructura en la nube de Aiven Cloud mediante Spring Data JPA e Hibernate ORM.

Asimismo, esta capa gobierna la transformación bidireccional de objetos de valor tipados hacia columnas escalares normalizadas, garantiza el despacho atómico de eventos hacia la tabla transaccional outbox_messages, y articula la integración síncrona y asíncrona con servicios de nube externos como Google Maps Places API, Firebase Cloud Messaging y el Bounded Context de Billing.

El diseño arquitectónico de este subsistema se fundamenta en cuatro directrices esenciales:

- **Desacoplamiento Estricto de Persistencia e Inversión de Dependencias:** Las entidades y agregados del dominio carecen deliberadamente de anotaciones relacionales de Jakarta Persistence. La persistencia física se confina en entidades de infraestructura especializadas que heredan un identificador primario universal y marcas temporales automáticas de auditoría desde la superclase **AuditableAbstractPersistenceEntity**.

- **Normalización Relacional Segura de Objetos de Valor:** Los objetos de valor inmutables se traducen de forma transparente hacia tipos escalares nativos mediante convertidores JPA dedicados. Esta estrategia garantiza la integridad de invariantes como números de chasis ISO 3779, placas vehiculares reglamentarias y documentos tributarios sin acoplar el núcleo del negocio al dialecto de la base de datos.

- **Consistencia Transaccional Mediante Transactional Outbox:** Las operaciones mutacionales orquestadas por los adaptadores de repositorio ejecutan la persistencia relacional y la inserción del evento de dominio en la tabla transaccional outbox_messages dentro de la misma transacción de base de datos, garantizando una semántica de entrega al menos una vez hacia consumidores asíncronos.

- **Resiliencia e Integración Perimetral con Servicios Externos:** Las comunicaciones hacia APIs geográficas de terceros y redes de notificación push para dispositivos móviles se implementan mediante clientes desacoplados provistos de políticas de tiempo de espera rigurosas y mecanismos de respaldo que mitigan caídas operativas.

A fin de ofrecer una visión sistemática de estos componentes, en la @tbl:crm-infrastructure-types se presenta el catálogo consolidado de los tipos técnicos que conforman la Capa de Infraestructura de Customer & Fleet Management (CRM).

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo Consolidado de la Capa de Infraestructura de Customer \& Fleet Management (CRM)} \label{tbl:crm-infrastructure-types} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\
\hline
\endfirsthead
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\
\hline
\endhead
Customer\allowbreak Persistence\allowbreak Entity & Mapeo relacional de clientes particulares y corporativos a la tabla customers. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Hereda de AuditableAbstractPersistenceEntity. Aislada por taller. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Vehicle\allowbreak Persistence\allowbreak Entity & Mapeo relacional del parque automotor universal a la tabla física vehicles. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Hereda de AuditableAbstractPersistenceEntity. 1:N con titularidades. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Vehicle\allowbreak Ownership\allowbreak Persistence\allowbreak Entity & Mapeo relacional de periodos de custodia a la tabla vehicle\_ownerships. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Relación N:1 con VehiclePersistenceEntity y clave foránea a clientes. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Appointment\allowbreak Persistence\allowbreak Entity & Mapeo relacional de citas de recepción técnica a la tabla appointments. \\*
\hline
\textbf{Categoría} & Entidad JPA \\*
\hline
\textbf{Relaciones} & Claves foráneas hacia talleres, sedes físicas, clientes y vehículos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak entities} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
License\allowbreak Plate\allowbreak Attribute\allowbreak Converter & Conversión bidireccional entre LicensePlate y columna VARCHAR(15). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Normaliza placas a mayúsculas sin guiones para unicidad global. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Vin\allowbreak Attribute\allowbreak Converter & Conversión bidireccional entre Vin y columna VARCHAR(17) ISO 3779. \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Mapea número de chasis estandarizado excluyendo letras ambiguas. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Customer\allowbreak Type\allowbreak Attribute\allowbreak Converter & Conversión bidireccional entre CustomerType y columna VARCHAR(20). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Mapea enumeraciones INDIVIDUAL y COMPANY a literales relacionales. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Engine\allowbreak Type\allowbreak Attribute\allowbreak Converter & Conversión bidireccional entre EngineType y columna VARCHAR(20). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Mapea opciones de propulsión térmica, híbrida y eléctrica. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Appointment\allowbreak Status\allowbreak Attribute\allowbreak Converter & Conversión bidireccional entre AppointmentStatus y VARCHAR(20). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Mapea estados PENDING, CONFIRMED, ARRIVED y CANCELED. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Tax\allowbreak Id\allowbreak Attribute\allowbreak Converter & Conversión bidireccional entre TaxId y columna VARCHAR(20). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Mapea documentos DNI de 8 dígitos y RUC fiscal de 11 dígitos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Email\allowbreak Address\allowbreak Attribute\allowbreak Converter & Conversión bidireccional entre EmailAddress y VARCHAR(150). \\*
\hline
\textbf{Categoría} & Convertidor JPA \\*
\hline
\textbf{Relaciones} & Normaliza correos de contacto a minúsculas para persistencia homogénea. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak converters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Customer\allowbreak Persistence\allowbreak Repository & Operaciones de persistencia física y consultas de unicidad de clientes. \\*
\hline
\textbf{Categoría} & Repositorio Spring Data \\*
\hline
\textbf{Relaciones} & Extiende \texttt{JpaRepository<\allowbreak CustomerPersistenceEntity,\allowbreak  UUID>\allowbreak }. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Vehicle\allowbreak Persistence\allowbreak Repository & Consultas de unicidad global de placa de rodaje y código VIN. \\*
\hline
\textbf{Categoría} & Repositorio Spring Data \\*
\hline
\textbf{Relaciones} & Extiende \texttt{JpaRepository<\allowbreak VehiclePersistenceEntity,\allowbreak  UUID>\allowbreak }. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Vehicle\allowbreak Ownership\allowbreak Persistence\allowbreak Repository & Consultas de custodia activa e historial cronológico de propiedad. \\*
\hline
\textbf{Categoría} & Repositorio Spring Data \\*
\hline
\textbf{Relaciones} & Extiende \texttt{JpaRepository<\allowbreak VehicleOwnershipPersistenceEntity,\allowbreak  UUID>\allowbreak }. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Appointment\allowbreak Persistence\allowbreak Repository & Consultas de agenda de citas por taller, sede física y disponibilidad. \\*
\hline
\textbf{Categoría} & Repositorio Spring Data \\*
\hline
\textbf{Relaciones} & Extiende \texttt{JpaRepository<\allowbreak AppointmentPersistenceEntity,\allowbreak  UUID>\allowbreak }. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak repositories} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Customer\allowbreak Persistence\allowbreak Assembler & Transforma agregados Customer hacia y desde entidades JPA. \\*
\hline
\textbf{Categoría} & Ensamblador \\*
\hline
\textbf{Relaciones} & Traduce CustomerId y TenantId a UUID y reconstituye datos de contacto. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Vehicle\allowbreak Persistence\allowbreak Assembler & Transforma agregados Vehicle hacia y desde entidades JPA. \\*
\hline
\textbf{Categoría} & Ensamblador \\*
\hline
\textbf{Relaciones} & Mapea especificaciones automotrices y colección de titularidades. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Vehicle\allowbreak Ownership\allowbreak Persistence\allowbreak Assembler & Transforma entidades VehicleOwnership a representaciones JPA. \\*
\hline
\textbf{Categoría} & Ensamblador \\*
\hline
\textbf{Relaciones} & Preserva fechas de intervalo temporal y vinculación con vehículos. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Appointment\allowbreak Persistence\allowbreak Assembler & Transforma agregados Appointment hacia y desde entidades JPA. \\*
\hline
\textbf{Categoría} & Ensamblador \\*
\hline
\textbf{Relaciones} & Mapea marcas temporales, sedes físicas y motivos de cita. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak transform} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Customer\allowbreak Repository\allowbreak Impl & Implementación del puerto de dominio CustomerRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Persistencia \\*
\hline
\textbf{Relaciones} & Persiste entidades y canaliza eventos de dominio al Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Vehicle\allowbreak Repository\allowbreak Impl & Implementación del puerto de dominio VehicleRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Persistencia \\*
\hline
\textbf{Relaciones} & Garantiza unicidad global y publica eventos en Transactional Outbox. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Vehicle\allowbreak Ownership\allowbreak Repository\allowbreak Impl & Implementación del puerto VehicleOwnershipRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Persistencia \\*
\hline
\textbf{Relaciones} & Gestiona consultas de titulares activos e historial de custodias. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Appointment\allowbreak Repository\allowbreak Impl & Implementación del puerto de dominio AppointmentRepository. \\*
\hline
\textbf{Categoría} & Adaptador de Persistencia \\*
\hline
\textbf{Relaciones} & Persiste citas previas y emite eventos de arribo para el taller. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak persistence.\allowbreak jpa.\allowbreak adapters} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Google\allowbreak Places\allowbreak Client & Cliente REST HTTPS para validación y geocodificación de direcciones. \\*
\hline
\textbf{Categoría} & Adaptador de Salida \\*
\hline
\textbf{Relaciones} & Implementa PlacesAddressVerificationGateway vía Google Places API. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak external.\allowbreak places} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Driver\allowbreak App\allowbreak Fcm\allowbreak Client & Pasarela de mensajería push móvil para la app Atelier Driver. \\*
\hline
\textbf{Categoría} & Adaptador de Salida \\*
\hline
\textbf{Relaciones} & Implementa DriverAppPushGateway mediante Firebase Admin SDK. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak external.\allowbreak fcm} \\
\hline
\thfirst{Clase o Tipo} & \thcell{Propósito en la Arquitectura} \\*
\hline
Subscription\allowbreak Validation\allowbreak Client & Cliente de integración síncrona para verificación de límites SaaS. \\*
\hline
\textbf{Categoría} & Adaptador de Salida \\*
\hline
\textbf{Relaciones} & Implementa SubscriptionValidationService consultando Billing. \\*
\hline
\textbf{Paquete} & \texttt{.\allowbreak .\allowbreak .\allowbreak crm.\allowbreak infrastructure.\allowbreak external.\allowbreak billing} \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al paquete canónico com.andeva.atelier.platform.crm.infrastructure.

**Entidades JPA de Persistencia y Modelado Físico Relacional**

El modelado físico relacional de Customer & Fleet Management confina las anotaciones de Hibernate en cuatro entidades de persistencia mapeadas directamente a tablas relacionales de PostgreSQL 16. Todas las entidades mutables extienden la superclase **AuditableAbstractPersistenceEntity**, adquiriendo un identificador primario universal y marcas temporales de auditoría gestionadas de forma nativa por el motor ORM.

La entidad **CustomerPersistenceEntity** se asigna a la tabla customers, asegurando el aislamiento multi-inquilino mediante la columna obligatoria tenant_id. Su definición incorpora la restricción única compuesta uk_customers_tenant_tax_id sobre el identificador de inquilino y el número de documento tributario, así como índices secundarios para agilizar búsquedas filtradas por razón social, nombres de cliente o correo electrónico.

Por su parte, **VehiclePersistenceEntity** se vincula a la tabla física vehicles bajo un diseño global desprovisto de tenant_id. Esta decisión arquitectónica modela al vehículo como un activo físico universal dentro de la plataforma automotriz, permitiendo que una unidad mecánica conserve intacto su historial técnico y cronológico de servicios aunque transite entre diferentes talleres o cambie de propietario.

La relación histórica de custodia se materializa mediante **VehicleOwnershipPersistenceEntity** en la tabla vehicle_ownerships, asociando claves foráneas hacia el cliente y la unidad vehicular. A nivel de base de datos relacional, esta tabla incorpora el índice parcial único idx_vo_active sobre el identificador vehicular cuando la fecha de finalización es nula, garantizando que un automóvil ostente un único titular vigente simultáneamente.

Finalmente, **AppointmentPersistenceEntity** se asigna a la tabla appointments, articulando las relaciones foráneas con el taller, la sede física operativa, el cliente y el vehículo en recepción. La entidad preserva la marca temporal pactada en horario UTC, la duración estimada de la inspección técnica, el motivo del servicio reportado y la justificación obligatoria en caso de cancelación de la reserva.

Con el propósito de especificar la correlación física y estructural del modelo relacional, en la @tbl:crm-jpa-entities se detallan las entidades JPA, sus tablas correspondientes, columnas principales, restricciones e índices.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Especificación Relacional de Entidades JPA de Customer \& Fleet Management (CRM)} \label{tbl:crm-jpa-entities} \\
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} CustomerPersistenceEntity \quad (\textit{Tabla:} \texttt{customers})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{tenant\_id}, \texttt{type}, \texttt{first\_name}, \texttt{last\_name}, \texttt{company\_name}, \texttt{tax\_id}, \texttt{email}, \texttt{phone}, \texttt{status} \\*
\hline
\textbf{Restricciones e Índices} & Restricción única uk\_customers\_tenant\_tax\_id. índice compuesto en tenant\_id y type. no nulo en tenant\_id y status. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} VehiclePersistenceEntity \quad (\textit{Tabla:} \texttt{vehicles})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{plate}, \texttt{vin}, \texttt{brand}, \texttt{model}, \texttt{year}, \texttt{engine\_type} \\*
\hline
\textbf{Restricciones e Índices} & Restricción única global uk\_vehicles\_plate. índice en columna vin. relación 1:N en cascada con vehicle\_ownerships. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} VehicleOwnershipPersistenceEntity \quad (\textit{Tabla:} \texttt{vehicle\_ownerships})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{customer\_id}, \texttt{vehicle\_id}, \texttt{start\_date}, \texttt{end\_date} \\*
\hline
\textbf{Restricciones e Índices} & Claves foráneas fk\_vo\_customer y fk\_vo\_vehicle. índice parcial idx\_vo\_active en vehicle\_id donde end\_date es nulo. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Entidad JPA:} AppointmentPersistenceEntity \quad (\textit{Tabla:} \texttt{appointments})} \\*
\hline
\textbf{Clave Primaria} & \texttt{id (UUID)} \\*
\hline
\textbf{Columnas Principales} & \texttt{tenant\_id}, \texttt{branch\_id}, \texttt{customer\_id}, \texttt{vehicle\_id}, \texttt{scheduled\_at}, \texttt{estimated\_duration\_minutes}, \texttt{reason}, \texttt{status}, \texttt{cancellation\_reason} \\*
\hline
\textbf{Restricciones e Índices} & Claves foráneas a tenants, branches, customers y vehicles. índice compuesto idx\_appt\_tenant\_branch\_date. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Tablas físicas alojadas en el motor PostgreSQL 16 con motor InnoDB equivalente relacional.

**Repositorios Spring Data JPA y Adaptadores de Persistencia**

El acceso a los datos y la ejecución de sentencias relacionales se desacoplan rigurosamente mediante el patrón de Adaptador de Repositorio. Las interfaces Spring Data JPA ubicadas en el paquete com.andeva.atelier.platform.crm.infrastructure.persistence.jpa.repositories declaran métodos de consulta derivados y proyecciones JPQL optimizadas para resolver requerimientos de lectura y comprobación de unicidad.

En este nivel, **CustomerPersistenceRepository** define consultas compuestas para validar la disponibilidad del documento fiscal o correo electrónico dentro de un taller, además de incorporar la sentencia JPQL *searchCustomers()* para búsquedas flexibles y paginadas. Complementariamente, **VehiclePersistenceRepository** gestiona la validación perimetral de placas de rodaje y números de chasis a escala global en toda la plataforma.

Asimismo, **VehicleOwnershipPersistenceRepository** resuelve consultas sobre el titular activo y el historial cronológico de custodia de cada automóvil, mientras que **AppointmentPersistenceRepository** implementa la consulta de sobreposición temporal *countOverlappingAppointments()* para gobernar la capacidad de recepción técnica por sede, junto con la proyección de agendas diarias en patio.

Los adaptadores secundarios de salida **CustomerRepositoryImpl**, **VehicleRepositoryImpl**, **VehicleOwnershipRepositoryImpl** y **AppointmentRepositoryImpl** implementan las interfaces del dominio encapsulando el ciclo de vida de persistencia relacional. Cada operación mutacional ejecuta una secuencia coordinada en seis pasos atómicos:

- Convierte el agregado de dominio a su entidad de persistencia JPA mediante el ensamblador técnico respectivo.
- Persiste y sincroniza la entidad físicamente en PostgreSQL ejecutando *saveAndFlush()* sobre el repositorio JPA.
- Extrae la colección inmutable de eventos de dominio registrados en la raíz del agregado mediante *getDomainEvents()*.
- Por cada evento extraído, genera un registro atómico en la tabla outbox_messages con su identificador, tipo de agregado, carga útil serializada en JSON y marca temporal UTC.
- Limpia la cola interna de eventos del agregado invocando la operación *clearDomainEvents()*.
- Retorna la instancia de dominio reconstituida hacia la Capa de Aplicación.

A fin de sistematizar las responsabilidades y contratos de persistencia, en la @tbl:crm-repository-adapters se especifican los adaptadores de repositorio, sus puertos de dominio asociados y las operaciones relacionales implementadas.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Adaptadores de Persistencia y Puertos de Dominio de Customer \& Fleet Management (CRM)} \label{tbl:crm-repository-adapters} \\
\hline
\thfirst{Aspecto de Adaptador} & \thcell{Especificación Técnica y Persistencia} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Adaptador} & \thcell{Especificación Técnica y Persistencia} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} CustomerRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{CustomerRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{CustomerPersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & save con extracción de eventos al Outbox, findById, findByIdAndTenantId, findByTenantIdAndTaxId, existsByTenantIdAndTaxId, existsByTenantIdAndEmail, findAllByTenantId. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} VehicleRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{VehicleRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{VehiclePersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & save con publicación Outbox, findById, findByPlate, findByVin, existsByPlate, existsByVin. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} VehicleOwnershipRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{VehicleOwnershipRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{VehicleOwnershipPersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & save, findActiveByVehicleId, findAllByVehicleIdOrderByStartDateDesc, findAllByCustomerIdAndEndDateIsNull. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Adaptador:} AppointmentRepositoryImpl} \\*
\hline
\textbf{Puerto de Dominio} & \texttt{AppointmentRepository} \\*
\hline
\textbf{Repositorio Inyectado} & \texttt{AppointmentPersistenceRepository} \\*
\hline
\textbf{Operaciones Clave} & save con emisión de eventos al Outbox, findById, findByIdAndTenantId, findAllByTenantIdAndBranchIdAndDate, countOverlappingAppointments, existsActiveAppointmentsByCustomerId. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Clases ubicadas bajo el paquete com.andeva.atelier.platform.crm.infrastructure.persistence.jpa.adapters.

**Ensambladores de Persistencia y Convertidores JPA**

La correspondencia bidireccional entre los modelos inmutables del núcleo de dominio y las entidades relacionales mutables de JPA se gestiona mediante ensambladores de persistencia dedicados. Estos componentes aplican el principio de aislamiento del ciclo de vida: las transformaciones hacia el dominio reconstituyen las entidades mediante métodos de factoría específicos como *reconstitute()*, evitando invocar constructores de creación que emitan eventos espurios hacia el outbox durante operaciones de lectura.

El componente **CustomerPersistenceAssembler** traduce los valores escalares de identificadores fuertemente tipados, nombres personales, documentos de identidad y correos electrónicos, discriminando entre clientes individuales y corporativos. De manera similar, **VehiclePersistenceAssembler** y **VehicleOwnershipPersistenceAssembler** orquestan la hidratación de datos técnicos vehiculares y de la colección histórica de propietarios sin degradar la inmutabilidad de las listas de dominio.

Por su parte, **AppointmentPersistenceAssembler** mapea las marcas temporales, sedes operativas y motivos de atención hacia la entidad de persistencia, preservando la coherencia del estado operativo de la reserva al transitar entre capas arquitectónicas.

En el plano de los convertidores de atributos JPA, la infraestructura incorpora siete clases especializadas que implementan la interfaz canónica de persistencia:

- **LicensePlateAttributeConverter:** Normaliza las placas vehiculares a mayúsculas compactas sin guiones ni espacios para garantizar búsquedas unívocas sobre columnas de texto.
- **VinAttributeConverter:** Valida la estructura alfanumérica del número de identificación vehicular bajo la norma ISO 3779, excluyendo caracteres ambiguos para almacenamiento en columnas de diecisiete caracteres.
- **CustomerTypeAttributeConverter:** Traduce las constantes enumeradas de clientes particulares y corporativos a literales de base de datos en minúsculas.
- **EngineTypeAttributeConverter:** Mapea las opciones de motorización a representaciones relacionales para configuraciones térmicas, híbridas y eléctricas.
- **AppointmentStatusAttributeConverter:** Convierte los estados del ciclo de vida de la cita técnica hacia valores escalares normalizados.
- **TaxIdAttributeConverter:** Persiste documentos de identidad fiscal distinguiendo entre registros de ocho dígitos para personas naturales y once dígitos para empresas.
- **EmailAddressAttributeConverter:** Convierte direcciones de correo electrónico a cadenas homogéneas en minúsculas.

Para sintetizar las reglas de transformación y correspondencia estructural, en la @tbl:crm-persistence-assemblers se describen los ensambladores de persistencia y convertidores JPA del contexto.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Ensambladores de Persistencia y Convertidores JPA de Customer \& Fleet Management (CRM)} \label{tbl:crm-persistence-assemblers} \\
\hline
\thfirst{Aspecto de Mapeo} & \thcell{Tipos Relacionados y Transformación} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Mapeo} & \thcell{Tipos Relacionados y Transformación} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} CustomerPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{Customer} $\longleftrightarrow$ \texttt{CustomerPersistenceEntity} \\*
\hline
\textbf{Transformación} & Traduce CustomerId y TenantId a UUID. mapea PersonName, TaxId, EmailAddress y PhoneNumber. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} VehiclePersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{Vehicle} $\longleftrightarrow$ \texttt{VehiclePersistenceEntity} \\*
\hline
\textbf{Transformación} & Mapea VehicleId a UUID, LicensePlate, Vin, motorización y colección interna de titularidades. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} VehicleOwnershipPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{VehicleOwnership} $\longleftrightarrow$ \texttt{VehicleOwnershipPersistenceEntity} \\*
\hline
\textbf{Transformación} & Mapea VehicleOwnershipId a UUID, customer\_id, fechas de inicio y término, y enlace a Vehicle. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} AppointmentPersistenceAssembler} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{Appointment} $\longleftrightarrow$ \texttt{AppointmentPersistenceEntity} \\*
\hline
\textbf{Transformación} & Mapea AppointmentId a UUID, sede física, cliente, vehículo, marca temporal Instant y estado. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} LicensePlateAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{LicensePlate} $\longleftrightarrow$ \texttt{VARCHAR(15)} \\*
\hline
\textbf{Transformación} & Normaliza placas a mayúsculas sin guiones para garantizar unicidad e indexación rápida. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} VinAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{Vin} $\longleftrightarrow$ \texttt{VARCHAR(17)} \\*
\hline
\textbf{Transformación} & Valida formato ISO 3779 excluyendo letras ambiguas y persiste en texto plano. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} CustomerTypeAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{CustomerType} $\longleftrightarrow$ \texttt{VARCHAR(20)} \\*
\hline
\textbf{Transformación} & Convierte constantes INDIVIDUAL y COMPANY a literales de base de datos. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} EngineTypeAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{EngineType} $\longleftrightarrow$ \texttt{VARCHAR(20)} \\*
\hline
\textbf{Transformación} & Mapea tipos de propulsión GASOLINE, DIESEL, ELECTRIC e HYBRID a cadenas relacionales. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} AppointmentStatusAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{AppointmentStatus} $\longleftrightarrow$ \texttt{VARCHAR(20)} \\*
\hline
\textbf{Transformación} & Mapea estados PENDING, CONFIRMED, ARRIVED y CANCELED a columna física. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} TaxIdAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{TaxId} $\longleftrightarrow$ \texttt{VARCHAR(20)} \\*
\hline
\textbf{Transformación} & Persiste DNI de 8 dígitos o RUC de 11 dígitos verificando formato numérico. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Ensamblador / Convertidor:} EmailAddressAttributeConverter} \\*
\hline
\textbf{Mapeo de Tipos} & \texttt{EmailAddress} $\longleftrightarrow$ \texttt{VARCHAR(150)} \\*
\hline
\textbf{Transformación} & Normaliza correos de contacto a minúsculas para persistencia uniforme. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes ubicados en los paquetes transform y converters de la capa de infraestructura.

**Pasarelas Externas de Infraestructura e Integración Cloud**

La integración con plataformas externas y subsistemas adyacentes se canaliza mediante adaptadores secundarios ubicados en el paquete com.andeva.atelier.platform.crm.infrastructure.external. Estos componentes implementan los puertos de salida definidos en la Capa de Aplicación, aislando el núcleo operativo del taller de dependencias tecnológicas externas.

El adaptador **GooglePlacesClient** materializa el puerto **PlacesAddressVerificationGateway** comunicándose con Google Maps Places API mediante peticiones seguras HTTPS sobre el puerto 443 utilizando Spring 6 **RestClient**. Este cliente estandariza domicilios fiscales y bases operativas de flotas corporativas, extrayendo coordenadas satelitales en formato WGS 84 y componentes estructurados de dirección bajo una política de tolerancia a fallos que preserva la dirección original ante indisponibilidad del proveedor.

Por su parte, **DriverAppFcmClient** implementa el puerto **DriverAppPushGateway** mediante el kit de desarrollo oficial Firebase Admin SDK. Este componente construye y despacha notificaciones push móviles hacia las aplicaciones de conductores y propietarios ante la confirmación de citas técnicas, avisos de arribo a patio y alertas de cancelación, gestionando la invalidación de credenciales móviles cuando se reportan dispositivos desregistrados.

Finalmente, **SubscriptionValidationClient** implementa la interfaz **SubscriptionValidationService** para auditar en tiempo real las cuotas contractuales de clientes y vehículos registradas en el Bounded Context de Billing antes de permitir mutaciones de alta en el sistema. Si el taller excede los límites contractuales de su plan comercial activo, la pasarela interrumpe la operación arrojando una excepción de negocio que protege el modelo de monetización de la plataforma.

A fin de ilustrar la arquitectura de integración y servicios en la nube, en la @tbl:crm-external-infrastructure se presentan las tecnologías subyacentes y las responsabilidades técnicas de cada pasarela externa.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{10.6cm} |}
\caption{Pasarelas Externas y Adaptadores de Integración de Customer \& Fleet Management (CRM)} \label{tbl:crm-external-infrastructure} \\
\hline
\thfirst{Aspecto Técnico} & \thcell{Tecnología y Responsabilidad de Integración} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto Técnico} & \thcell{Tecnología y Responsabilidad de Integración} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Pasarela Externa:} GooglePlacesClient \quad (\textit{Categoría:} Pasarela Geográfica)} \\*
\hline
\textbf{Tecnología Subyacente} & Spring RestClient (HTTPS 443) \\*
\hline
\textbf{Responsabilidad} & Invoca Google Maps Places API para validar, geocodificar y normalizar domicilios fiscales de flotas B2B. Implementa PlacesAddressVerificationGateway. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Pasarela Externa:} DriverAppFcmClient \quad (\textit{Categoría:} Pasarela Push Móvil)} \\*
\hline
\textbf{Tecnología Subyacente} & Firebase Admin SDK (FCM HTTPS) \\*
\hline
\textbf{Responsabilidad} & Despacha notificaciones push móviles hacia Atelier Driver ante confirmaciones y recordatorios de citas técnicas. Implementa DriverAppPushGateway. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Pasarela Externa:} SubscriptionValidationClient \quad (\textit{Categoría:} Adaptador de Cuotas)} \\*
\hline
\textbf{Tecnología Subyacente} & In-Memory Module Facade / RestClient \\*
\hline
\textbf{Responsabilidad} & Consulta síncrona hacia el Bounded Context de Billing para validar cuotas de clientes y vehículos antes de mutaciones. Implementa SubscriptionValidationService. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes configurados bajo el paquete canónico com.andeva.atelier.platform.crm.infrastructure.external.



#### 2.6.3.5. Bounded Context Software Architecture Component Level Diagrams

En esta sección se expone la descomposición arquitectónica interna del contenedor central **API Application** en relación con el Bounded Context Customer & Fleet Management (CRM). Siguiendo el Nivel 3 del Modelo C4, se ilustran los bloques estructurales que conforman este subsistema, formalizando sus responsabilidades técnicas, fronteras operacionales y mecanismos de integración con clientes, módulos adyacentes y servicios externos.

Dentro de la arquitectura de monolito modular de Atelier Platform, el Bounded Context Customer & Fleet Management asume la responsabilidad de gobernar la cartera comercial de clientes particulares y corporativos, el catálogo automotriz universal, la trazabilidad de tenencias vehiculares y el motor de agendamiento de citas. Las peticiones emitidas desde el portal administrativo web y los aplicativos móviles interactúan con este subsistema para coordinar la admisión de automotores y preparar las órdenes operativas.

En la @tbl:crm-c4-components se presenta el catálogo estructurado de los siete componentes constitutivos del Bounded Context Customer & Fleet Management dentro del contenedor anfitrión. Cada bloque encapsula una responsabilidad arquitectónica cohesiva, delimitando con precisión la frontera entre la interfaz de controladores REST, la orquestación de casos de uso mediante CQRS, el modelo de dominio puro, la persistencia relacional en base de datos y la integración con pasarelas externas.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{4.5cm} | >{\raggedright\arraybackslash}p{10.9cm} |}
\caption{Catálogo de Componentes de Arquitectura de Software del Bounded Context Customer \& Fleet Management (CRM)} \label{tbl:crm-c4-components} \\
\hline
\thfirst{Aspecto Técnico} & \thcell{Especificación de Arquitectura} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto Técnico} & \thcell{Especificación de Arquitectura} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} CRM REST Controllers \& Resource Assemblers} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring MVC, SpringDoc OpenAPI, Jakarta Validation \\*
\hline
\textbf{Responsabilidad} & Expone endpoints REST perimetrales para la gestión de clientes, flotas corporativas, catálogo universal de vehículos y el ciclo de vida completo de citas técnicas. Valida sintácticamente las solicitudes entrantes y proyecta las respuestas mediante ensambladores de recursos. \\*
\hline
\textbf{Relaciones} & Entrada desde clientes WebApp y aplicaciones móviles. Despacha comandos de escritura y consultas de lectura a servicios de aplicación CQRS. Utiliza ensambladores de recursos REST. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} CRM CQRS Application Services} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring Service, Transactional, CQRS, Interfaces Funcionales \\*
\hline
\textbf{Responsabilidad} & Orquesta los casos de uso de negocio de registro de clientes, validación de solvencia fiscal, alta universal de vehículos, transferencias de tenencia automotriz y transiciones de la máquina de estados de citas técnicas bajo consistencia transaccional. \\*
\hline
\textbf{Relaciones} & Implementa contratos de comando y consulta. Invoca reglas de negocio en el núcleo de dominio. Delega en adaptadores de persistencia JPA y pasarelas de nube. Emite eventos de dominio hacia oyentes dedicados. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} CRM Domain Event Listeners \& Integration Dispatcher} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring Events, TransactionalEventListener, Outbox Pattern \\*
\hline
\textbf{Responsabilidad} & Captura eventos de dominio de citas técnicas y vehículos. Despacha notificaciones push móviles hacia conductores y deposita eventos de integración estructurados en el Transactional Outbox para su propagación asíncrona hacia módulos adyacentes. \\*
\hline
\textbf{Relaciones} & Suscrito a eventos de dominio. Delega en pasarelas externas para notificaciones móviles. Registra eventos de integración para sincronización con operaciones de taller, facturación y telemetría. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} CRM Domain Model \& Aggregate Roots} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Dominio puro Java 26, AbstractDomainAggregateRoot, Records \\*
\hline
\textbf{Responsabilidad} & Encapsula las invariantes de negocio, normalización de placas de rodaje, validación de formato VIN bajo norma ISO 3779, reglas de tipología de clientes y la inmutabilidad de la cadena histórica de custodia vehicular. \\*
\hline
\textbf{Relaciones} & Raíces Customer, Vehicle, VehicleOwnership, Appointment. Entidades y objetos de valor inmutables. Acumula eventos de dominio en memoria. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} CRM Persistence Repositories \& JPA Adapters} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Jakarta Persistence 3.1, Spring Data JPA, Hibernate, PostgreSQL 16 \\*
\hline
\textbf{Responsabilidad} & Materializa los contratos de repositorio del dominio mediante adaptadores JPA, gobernando el mapeo relacional bidireccional y la persistencia transaccional en el esquema físico de PostgreSQL 16 con aislamiento multi-inquilino. \\*
\hline
\textbf{Relaciones} & Realiza interfaces de repositorio del dominio. Ejecuta operaciones SQL relacionales en la base de datos central. Provee lecturas optimizadas para la fachada de integración. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} Inbound ACL \& Customer Fleet Facade} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring Service, Capa Anticorrupción en Memoria, Published Language \\*
\hline
\textbf{Responsabilidad} & Publica una interfaz de servicio abierto en memoria para proveer fichas técnicas de vehículos, titulares activos y datos fiscales de clientes a bounded contexts externos sin comprometer el encapsulamiento del dominio. \\*
\hline
\textbf{Relaciones} & Invocado por Workshop Operations, Invoicing y Telemetría IoT. Delega lecturas desacopladas en repositorios de persistencia JPA. \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Componente C4:} External Gateways \& Cloud Integration} \\*
\hline
\textbf{Tipo de Elemento} & Componente \\*
\hline
\textbf{Tecnologías} & Spring RestClient, Firebase Admin SDK, Billing Quota Client \\*
\hline
\textbf{Responsabilidad} & Canaliza la integración con plataformas en la nube mediante canales seguros HTTPS en puerto 443, normalizando direcciones corporativas con Google Maps Places API, enviando notificaciones push con Firebase FCM y auditando cuotas en SaaS Billing. \\*
\hline
\textbf{Relaciones} & Invocado por servicios de aplicación y oyentes de eventos. Conecta con Google Maps Platform, Firebase Cloud Messaging y el módulo de facturación de suscripciones. \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Componentes pertenecientes al contenedor API Application en com.andeva.atelier.platform.crm.

En la @fig:c4-component-crm se ilustra el diagrama C4 de componentes para el Bounded Context Customer & Fleet Management (CRM), detallando las interacciones entre los controladores REST, los servicios de aplicación CQRS, los manejadores de eventos, el núcleo de dominio, los adaptadores de persistencia relacional, la fachada de integración y las pasarelas externas en la nube.

![Diagrama de Componentes C4 (Nivel 3) para el Bounded Context Customer & Fleet Management (CRM) en API Application](report/assets/c4-diagrams/component-level-diagram-crm.png){#fig:c4-component-crm}

*Nota.* Elaboración propia en base a la arquitectura táctica del backend y el estándar C4 Model.

**Dinámica de Interacción y Flujos Operativos del Bounded Context Customer & Fleet Management (CRM)**

Para comprender la colaboración dinámica y el flujo de control entre los componentes del Bounded Context Customer & Fleet Management y los módulos de negocio durante la ejecución del sistema, se analizan a continuación los tres flujos operacionales más representativos de la plataforma:

- **Ciclo Transaccional de Alta Corporativa y Verificación Externa:**
  Cuando un administrador de taller da de alta una empresa de transporte o flota corporativa desde la aplicación web, el componente **CRM REST Controllers & Resource Assemblers** intercepta la petición HTTP en la ruta correspondiente. Tras validar la estructura sintáctica del documento tributario mediante el objeto de valor de identificación fiscal, el controlador despacha el comando de registro hacia **CRM CQRS Application Services**.

  El servicio de aplicación inicia una transacción atómica y consulta de forma síncrona a **External Gateways & Cloud Integration** para auditar que el taller no sobrepase las cuotas contractuales de clientes asignadas a su suscripción en el módulo de facturación. Tras validar la solvencia de la cuenta, la pasarela solicita la normalización geográfica del domicilio fiscal conectando con los servicios en la nube de Google Maps Platform sobre canales seguros en el puerto 443.

  Con las coordenadas geocodificadas, el servicio instancia la raíz de agregado **Customer** de tipo corporativo en **CRM Domain Model & Aggregate Roots** y delega su almacenamiento en **CRM Persistence Repositories & JPA Adapters**, persistiendo en la tabla relacional de clientes de PostgreSQL 16. La raíz de agregado registra el evento de dominio correspondiente y deposita un evento de integración en el Transactional Outbox para coordinar la pre-carga fiscal en el subsistema de facturación electrónica.

- **Ciclo de Agendamiento, Alertas Push Móviles y Recepción en Bahía:**
  El agendamiento de atenciones técnicas se inicia cuando un conductor solicita una cita desde el aplicativo móvil o cuando recepción ingresa la reserva desde la consola de escritorio. El controlador valida una antelación temporal mínima de dos horas y traslada el comando hacia **CRM CQRS Application Services**, el cual corrobora la disponibilidad operativa de las bahías físicas y persiste la entidad **Appointment** en estado pendiente a través de los adaptadores JPA.

  Al confirmarse la reserva por parte del taller, el servicio de comando ejecuta la transición formal en el agregado y emite el evento de confirmación de cita. El componente **CRM Domain Event Listeners & Integration Dispatcher** captura dicho evento y solicita a **External Gateways & Cloud Integration** el despacho de una notificación push mediante Firebase Cloud Messaging, alertando al dispositivo del conductor sobre la confirmación del servicio de manera inmediata.

  Cuando el automotor ingresa físicamente al establecimiento, el personal técnico registra el arribo en patio desde la aplicación móvil de taller. El servicio de aplicación procesa el arribo transicionando el agregado al estado arribado y publicando un evento transaccional que el procesador outbox propaga hacia el módulo de operaciones de taller, desencadenando la apertura automática de la orden de trabajo y vinculando la bahía física asignada.

- **Ciclo de Traspaso de Custodia Vehicular y Consumo por Servicios Abiertos:**
  La venta o transferencia de titularidad de un automóvil registrado en el catálogo universal se gestiona mediante una solicitud de cambio de custodio recibida por **CRM REST Controllers & Resource Assemblers**. El controlador despacha el comando hacia **CRM CQRS Application Services**, el cual recupera el agregado automotriz y su colección histórica de titularidades mediante los adaptadores de persistencia relacional.

  El servicio ejecuta la operación de traspaso en el agregado **Vehicle**, cerrando el segmento temporal de la custodia anterior e instanciando un nuevo registro inmutable **VehicleOwnership** para el cliente adquirente. Esta mutación salvaguarda la inmutabilidad del expediente técnico automotriz y garantiza que los mantenimientos históricos permanezcan ligados a la unidad física sin importar las variaciones en la titularidad jurídica del vehículo.

  Para consultar los datos vehiculares consolidados sin violar el encapsulamiento de dominio, los módulos de operaciones de taller, facturación electrónica y telemetría consumen la interfaz provista por **Inbound ACL & Customer Fleet Facade**. Esta fachada ejecuta lecturas de solo lectura de alto rendimiento sobre los repositorios de persistencia y transforma las proyecciones en contratos inmutables del lenguaje publicado, permitiendo verificar coberturas y emitir comprobantes sin acoplamiento a los modelos internos.

#### 2.6.3.6. Bounded Context Software Architecture Code Level Diagrams

En esta sección se aborda el nivel de mayor granularidad y rigor técnico dentro de la arquitectura de software del Bounded Context Customer & Fleet Management (CRM), traduciendo los límites tácticos y responsabilidades funcionales hacia especificaciones estáticas que orientan la codificación de la plataforma. Mediante este enfoque, se garantiza que la gestión de clientes, la historia clínica automotriz y la recepción en taller se ejecuten bajo tipado estricto y consistencia determinista.

Esta dimensión arquitectónica se estructura en dos perspectivas complementarias: el Diagrama de Clases de la Capa de Dominio, que modela en memoria las raíces de agregado, entidades dependientes, objetos de valor y puertos de repositorio; y el Diagrama de Base de Datos, que define la persistencia física en PostgreSQL 16 con aislamiento multi-inquilino mediante discriminador de taller, restricciones de unicidad e índices B-Tree de alta velocidad.

##### 2.6.3.6.1. *Bounded Context Domain Layer Class Diagrams*

El modelado estático de la Capa de Dominio del Bounded Context Customer & Fleet Management (CRM) establece las estructuras de datos y contratos en memoria que gobiernan la relación con clientes y la trazabilidad del parque automotor. Su diseño prioriza el encapsulamiento estricto de reglas de negocio, erradica la obsesión por primitivos mediante identificadores fuertemente tipados y preserva la pureza conceptual al excluir anotaciones de frameworks o librerías de persistencia relacional.

En la @fig:class-diagram-crm se expone el Diagrama de Clases UML detallado para la Capa de Dominio del Bounded Context Customer & Fleet Management (CRM), modelado conforme al estándar UML y compilado mediante la herramienta PlantUML bajo el enfoque de Diagram-as-Code.

![Diagrama de Clases UML de la Capa de Dominio para el Bounded Context Customer & Fleet Management (CRM)](report/assets/class-diagrams/class-diagram-crm.png){#fig:class-diagram-crm}

*Nota.* Elaboración propia en base al diseño táctico de dominio y el estándar UML en PlantUML.

La organización interna del diagrama se estructura en ocho paquetes lógicos que agrupan las responsabilidades tácticas del subsistema comercial y de flota:

- **Raíces de Agregado (`crm.domain.model.aggregates`):** Modela las entidades principales que delimitan las fronteras transaccionales: **Customer** para la ficha comercial y fiscal del cliente; **Vehicle** para la ficha técnica del automotor; y **Appointment** para la reserva y recepción de servicios en sede física. Todas las raíces heredan de **AbstractDomainAggregateRoot<T>**.
- **Entidades Internas (`crm.domain.model.entities`):** Define entidades dependientes subordinadas al ciclo de vida de su raíz: **VehicleOwnership** para modelar la titularidad y periodos de custodia entre clientes y vehículos a lo largo del tiempo.
- **Identificadores Fuertemente Tipados (`crm.domain.model.ids`):** Implementa la interfaz **TypedId<UUID>** mediante registros inmutables (**CustomerId**, **VehicleId**, **VehicleOwnershipId**, **AppointmentId**), reutilizando **TenantId** y **BranchId** de los módulos de soporte.
- **Objetos de Valor Automotrices (`crm.domain.model.valueobjects`):** Encapsula conceptos inmutables como la placa vehicular normalizada (**LicensePlate**) y el número de chasis estandarizado (**Vin**), complementados por los tipos de contacto y tributarios provistos por el Shared Kernel.
- **Enumeraciones de Dominio (`crm.domain.model.enums`):** Define los estados operativos y modalidades de negocio (**CustomerType**, **CustomerStatus**, **EngineType**, **AppointmentStatus**).
- **Servicios de Dominio (`crm.domain.services`):** Incorpora lógica de negocio transversal que coordina múltiples agregados: **AppointmentSchedulingService** para el control de aforo y antelación en citas, y **VehicleTransferDomainService** para la orquestación atómica del traspaso vehicular.
- **Puertos de Persistencia (`crm.domain.repositories`):** Establece contratos de persistencia pura (**CustomerRepository**, **VehicleRepository**, **VehicleOwnershipRepository**, **AppointmentRepository**) desacoplados de los motores de bases de datos.
- **Jerarquía de Excepciones Semánticas (`crm.domain.exceptions`):** Provee clases no comprobadas que heredan de **DomainException**, asignando códigos de error unificados para infracciones de unicidad, estados inválidos o capacidad desbordada.

En la @tbl:crm-domain-classes-members se detalla la especificación formal de atributos, firmas de métodos, modificadores de acceso y reglas de negocio para cada elemento de la Capa de Dominio.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.0cm} | >{\raggedright\arraybackslash}p{10.4cm} |}
\caption{Catálogo exhaustivo de clases, miembros, ámbitos y relaciones de la Capa de Dominio del Bounded Context Customer \& Fleet Management (CRM)} \label{tbl:crm-domain-classes-members} \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endfirsthead
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Customer} \\*
\hline
Atributos & Raíz de agregado comercial. Administra cartera de clientes individuales y corporativos en el taller. Generalización de \texttt{AbstractDomainAggregateRoot<\allowbreak CustomerId>\allowbreak }. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{CustomerId id} \newline - \texttt{TenantId tenantId} \newline - \texttt{CustomerType type} \newline - \texttt{PersonName name} \newline - \texttt{String companyName} \newline - \texttt{TaxId taxId} \newline - \texttt{EmailAddress email} \newline - \texttt{PhoneNumber phone} \newline - \texttt{CustomerStatus status} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos factoría y estado & Invariantes: nombre obligatorio en clientes individuales y razón social en corporativos. Estado inicial ACTIVE. Registra evento de registro. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Customer registerIndividual(...)} \newline - \texttt{Customer registerCompany(...)} \newline - \texttt{void activate()} \newline - \texttt{void deactivate()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos de actualización & Permite modificar canales de contacto y datos de perfil. Resuelve la denominación comercial según la naturaleza jurídica. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{void updateContact(EmailAddress,\allowbreak  PhoneNumber)} \newline - \texttt{void updateProfile(PersonName)} \newline - \texttt{void updateCompanyDetails(String)} \newline - \texttt{String getDisplayName()} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Vehicle} \\*
\hline
Atributos & Raíz de agregado automotriz. Registro universal del vehículo independiente de sede. Generalización de \texttt{AbstractDomainAggregateRoot<\allowbreak VehicleId>\allowbreak }. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{VehicleId id} \newline - \texttt{LicensePlate plate} \newline - \texttt{Vin vin} \newline - \texttt{String brand} \newline - \texttt{String model} \newline - \texttt{int year} \newline - \texttt{EngineType engineType} \newline - \texttt{List<\allowbreak VehicleOwnership>\allowbreak  ownershipHistory} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos factoría y custodia & Composición 1 a 1..* con \textbf{VehicleOwnership}. Invariantes: año entre 1950 y año actual más uno. Exactamente un custodio activo con fecha de fin nula. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Vehicle register(...)} \newline - \texttt{VehicleOwnership transferOwnership(CustomerId,\allowbreak  LocalDate)} \newline - \texttt{Optional<\allowbreak VehicleOwnership>\allowbreak  getActiveOwnership()} \newline - \texttt{Optional<\allowbreak CustomerId>\allowbreak  getCurrentOwnerId()} \newline - \texttt{void updateTechnicalDetails(Vin,\allowbreak  EngineType)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} VehicleOwnership} \\*
\hline
Atributos y métodos & Entidad dependiente de custodia. Modela el periodo de titularidad vehicular. Invariante: fecha de fin posterior a fecha de inicio. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{VehicleOwnershipId id} \newline - \texttt{VehicleId vehicleId} \newline - \texttt{CustomerId customerId} \newline - \texttt{LocalDate startDate} \newline - \texttt{LocalDate endDate} \newline - \texttt{boolean isCurrent()} \newline - \texttt{void terminate(LocalDate)} \\*
\hline
\textbf{Ámbito} & Privado / Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Appointment} \\*
\hline
Atributos & Raíz de agregado de agendamiento y recepción de citas en taller. Generalización de \texttt{AbstractDomainAggregateRoot<\allowbreak AppointmentId>\allowbreak }. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{AppointmentId id} \newline - \texttt{TenantId tenantId} \newline - \texttt{BranchId branchId} \newline - \texttt{CustomerId customerId} \newline - \texttt{VehicleId vehicleId} \newline - \texttt{Instant scheduledAt} \newline - \texttt{int estimatedDurationMinutes} \newline - \texttt{String reason} \newline - \texttt{AppointmentStatus status} \newline - \texttt{String cancellationReason} \\*
\hline
\textbf{Ámbito} & Privado \\
\hline
\thfirst{Miembro o Elemento} & \thcell{Descripción y Reglas de Negocio} \\*
\hline
Métodos de ciclo de vida & Invariantes: agendamiento con antelación mínima de 2 horas. Máquina de estados determinista. Arribo físico irreversible. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Appointment schedule(...)} \newline - \texttt{void confirm()} \newline - \texttt{void markArrived()} \newline - \texttt{void cancel(String)} \newline - \texttt{void reschedule(Instant)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} CustomerId, VehicleId, VehicleOwnershipId, AppointmentId} \\*
\hline
Atributo value y factoría & Registros inmutables que realizan la interfaz \texttt{TypedId<\allowbreak UUID>\allowbreak }, confiriendo tipado estricto a las identidades del dominio. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{UUID value} \newline - \texttt{of(UUID)} \\*
\hline
\textbf{Ámbito} & Privado / Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} LicensePlate, Vin} \\*
\hline
Atributos y validaciones & Objetos de valor inmutables. \textbf{LicensePlate} normaliza caracteres alfanuméricos oficiales MTC. \textbf{Vin} valida suma ponderada ISO 3779. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{String value} \newline - \texttt{LicensePlate of(String)} \newline - \texttt{String normalized()} \newline - \texttt{Vin of(String)} \newline - \texttt{boolean isValid()} \\*
\hline
\textbf{Ámbito} & Privado / Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} CustomerType, CustomerStatus, EngineType, AppointmentStatus} \\*
\hline
Valores constantes & Tipos enumerados que gobiernan la clasificación legal, vigencia comercial, tecnología de motorización y estados de citas. \\*
\hline
\textbf{Firma o Tipo} & \texttt{Enumeraciones de dominio} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} AppointmentSchedulingService, VehicleTransferDomainService} \\*
\hline
Servicios de dominio & Lógica pura sin estado. Validan aforo simultáneo de recepción en sucursal y orquestan el traspaso atómico de propiedad entre clientes. \\*
\hline
\textbf{Firma o Tipo} & - \texttt{Result<\allowbreak Void,\allowbreak  DomainException>\allowbreak  validateSlotAvailability(...)} \newline - \texttt{Result<\allowbreak VehicleOwnership,\allowbreak  DomainException>\allowbreak  transferVehicle(...)} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} CustomerRepository, VehicleRepository, VehicleOwnershipRepository, AppointmentRepository} \\*
\hline
Firmas de acceso persistente & Puertos secundarios para operaciones de persistencia agnóstica de agregados y resolución de consultas operativas de flota. \\*
\hline
\textbf{Firma o Tipo} & \texttt{Interfaces de repositorio} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Clase o Estructura:} Jerarquía de Excepciones de Dominio} \\*
\hline
Constructores tipados & Excepciones no comprobadas derivadas de \texttt{DomainException} que portan códigos legibles por máquina para respuestas de error HTTP 4xx. \\*
\hline
\textbf{Firma o Tipo} & Subclases de \texttt{DomainException} \\*
\hline
\textbf{Ámbito} & Público \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Elaboración propia en base al diseño táctico de dominio y la especificación UML de la solución.

A partir del modelo estático ilustrado en la @fig:class-diagram-crm y formalizado en la @tbl:crm-domain-classes-members, se identifican tres fundamentos de ingeniería de software que consolidan la robustez y pureza del subsistema:

- **Desacoplamiento entre la Identidad Física Automotriz y la Custodia Jurídica:**
  Al concebir a **Vehicle** como una entidad universal dotada de ciclo de vida propio y separar los vínculos de posesión en **VehicleOwnership**, la plataforma asegura la inmutabilidad de la historia clínica automotriz. Cuando un automóvil es transferido entre particulares o flotas corporativas, los registros históricos de fallas, telemetría e intervenciones mecánicas permanecen ligados a la unidad física, evitando la pérdida de información técnica ante sucesivas compraventas.

- **Determinismo Operativo en el Agendamiento y Recepción mediante Máquinas de Estados:**
  La raíz **Appointment** restringe rigurosamente las transiciones de estado a través de métodos de mutación semánticos, impidiendo regresiones inconsistentes o cancelaciones indebidas. El arribo formal del automotor a la sucursal física consolida un estado terminal irrevocable, emitiendo de manera atómica el evento transaccional que instruye al módulo de operaciones de taller la apertura inmediata de la orden de trabajo correspondiente.

- **Normalización Estricta de Activos y Mitigación de Vulnerabilidades Sintácticas:**
  Los objetos de valor **LicensePlate** y **Vin** garantizan que ninguna cadena vehicular entre en memoria con formatos erróneos o caracteres ambiguos. La normalización de placas conforme al estándar del Ministerio de Transportes y Comunicaciones del Perú y la verificación de chasis bajo el estándar ISO 3779 erradican fallos de duplicidad o inconsistencia en consultas cruzadas con sistemas telemáticos e integraciones de aseguradoras.

##### 2.6.3.6.2. *Bounded Context Database Design Diagram*

La persistencia del Bounded Context Customer & Fleet Management materializa el modelo de dominio mediante una arquitectura relacional distribuida en dos motores especializados. El repositorio central en PostgreSQL 16 garantiza la consistencia transaccional y el aislamiento multi-inquilino de las carteras comerciales, mientras que el motor embebido SQLite 3 provee autonomía operativa desconectada en la aplicación móvil de taller ante contingencias de conectividad en patio o fosas mecánicas.

En la @fig:database-diagram-crm se presenta el Diagrama Entidad-Relación físico para la persistencia del Bounded Context Customer & Fleet Management en sus dos entornos operativos de despliegue: el repositorio central PostgreSQL 16 de la API de backend y el motor relacional local SQLite 3 de la aplicación móvil de taller.

![Diagrama Entidad-Relación de Base de Datos para el Bounded Context Customer & Fleet Management (PostgreSQL 16 y SQLite 3)](report/assets/database-diagrams/database-diagram-crm.png){#fig:database-diagram-crm}

*Nota.* Elaboración propia en base al diseño físico de persistencia y el estándar PlantUML ERD.

A partir del modelo entidad-relación ilustrado, la arquitectura de datos se descompone en cuatro subsistemas relacionales especializados:

- **Subsistema de Gestión Comercial y Cartera de Clientes:**
  Formaliza el registro de clientes particulares y corporativos en la tabla **customers**, vinculada a la entidad raíz organizacional **tenants** mediante la clave foránea **tenant_id**. La tabla incorpora un discriminador semántico de tipo y restricciones de unicidad compuestas sobre el documento tributario, garantizando que cada taller administre su cartera de clientes con estricta confidencialidad comercial y sin duplicidad de registros fiscales.

- **Subsistema de Parque Automotor e Historial de Tenencia:**
  Estructura el catálogo físico vehicular a través de las tablas **vehicles** y **vehicle_ownerships**. La tabla **vehicles** modela el activo automotriz de forma universal sin asociarlo a un inquilino particular, normalizando placas de rodaje y números de chasis bajo estándares internacionales. A su vez, **vehicle_ownerships** preserva la trazabilidad cronológica de custodia mediante fechas de inicio y cese de propiedad, respaldada por un índice único parcial que restringe la titularidad vigente a un único custodio activo.

- **Subsistema de Agendamiento y Recepción Operativa:**
  Administra el flujo de reservas técnicas e ingreso a bahías mediante la tabla **appointments**. Cada registro articula las relaciones foráneas hacia el taller empleador, la sede física receptora, el cliente titular y el vehículo a inspeccionar. Su ciclo de vida es gobernado por restricciones de verificación de estados, facilitando la transición ordenada desde la reserva preliminar hasta la confirmación de arribo que dispara la apertura de órdenes de trabajo en el contexto de taller.

- **Persistencia Desconectada de Recepción en SQLite 3:**
  Provee continuidad operacional a la aplicación móvil de taller a través de las tablas locales **local_customers_cache**, **local_vehicles_cache**, **local_appointments_cache** y **offline_reception_mutations**. Este conjunto de estructuras resguarda réplicas ligeras de consulta inmediata y encola mutaciones de recepción en patio sin depender de red celular, replicando los arribos confirmados hacia el backend central mediante peticiones seguras al restablecer la conexión.

A partir de la arquitectura relacional definida en el diagrama de persistencia, en la @tbl:crm-database-objects se cataloga la totalidad de las tablas y objetos físicos que conforman el modelo de datos, detallando el producto donde residen, sus atributos cardinales, restricciones de integridad, estrategias de indexación y su contribución al aislamiento de información.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{5.1cm} | >{\raggedright\arraybackslash}p{10.3cm} |}
\caption{Catálogo exhaustivo de tablas, objetos de base de datos, restricciones e índices físicos del Bounded Context Customer \& Fleet Management} \label{tbl:crm-database-objects} \\
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endfirsthead
\hline
\thfirst{Aspecto de Persistencia} & \thcell{Especificación Físico-Relacional} \\
\hline
\endhead
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{customers}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API) \\*
\hline
\textbf{Propósito y Aislamiento} & Cartera de clientes particulares B2C y flotas corporativas B2B. Aislamiento por tenant\_id que previene fugas de datos comerciales entre talleres mecánicos concurrentes. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{tenant\_id (UUID)}, \texttt{type (VARCHAR)}, \texttt{first\_name (VARCHAR)}, \texttt{last\_name (VARCHAR)}, \texttt{company\_name (VARCHAR)}, \texttt{tax\_id (VARCHAR)}, \texttt{email (VARCHAR)}, \texttt{phone (VARCHAR)}, \texttt{status (VARCHAR)}, auditoría transversal. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_customers (id) \newline - FK: fk\_customers\_tenant\_id hacia tenants(id) \newline - UK: uk\_customers\_tenant\_tax\_id (tenant\_id, tax\_id) \newline - CHECK: chk\_customer\_type, chk\_customer\_status \newline - Índices B-Tree: idx\_customers\_tenant\_tax\_id, idx\_customers\_search \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{vehicles}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API) \\*
\hline
\textbf{Propósito y Aislamiento} & Catálogo automotriz universal. Activo físico independiente de tenant\_id para consolidar la historia clínica y técnica del vehículo a través de múltiples talleres. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{plate (VARCHAR)}, \texttt{vin (VARCHAR)}, \texttt{brand (VARCHAR)}, \texttt{model (VARCHAR)}, \texttt{year (INTEGER)}, \texttt{engine\_type (VARCHAR)}, auditoría técnica transversal. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_vehicles (id) \newline - UK: uk\_vehicles\_plate (plate) \newline - CHECK: chk\_vehicles\_engine\_type, chk\_vehicles\_year (year >= 1950) \newline - Índices B-Tree: idx\_vehicles\_plate, idx\_vehicles\_vin (parcial) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{vehicle\_ownerships}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API) \\*
\hline
\textbf{Propósito y Aislamiento} & Trazabilidad temporal de custodia y propiedad legal del vehículo. Desacopla la unidad física del titular y permite transferencias de tenencia inmutables. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{customer\_id (UUID)}, \texttt{vehicle\_id (UUID)}, \texttt{start\_date (DATE)}, \texttt{end\_date (DATE)}, auditoría transversal. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_vehicle\_ownerships (id) \newline - FK: fk\_ownerships\_customer\_id, fk\_ownerships\_vehicle\_id \newline - CHECK: chk\_ownership\_dates \newline - UK parcial: uk\_vehicle\_active\_ownership (vehicle\_id) WHERE end\_date IS NULL \newline - Índices: idx\_ownerships\_customer, idx\_ownerships\_vehicle \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{appointments}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API) \\*
\hline
\textbf{Propósito y Aislamiento} & Programación y recepción de citas en sedes físicas. Aislamiento por tenant\_id y branch\_id con control de transiciones de estado operativo hacia órdenes de trabajo. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{tenant\_id (UUID)}, \texttt{branch\_id (UUID)}, \texttt{customer\_id (UUID)}, \texttt{vehicle\_id (UUID)}, \texttt{scheduled\_at (TIMESTAMPTZ)}, \texttt{estimated\_duration\_minutes (INTEGER)}, \texttt{reason (TEXT)}, \texttt{status (VARCHAR)}, \texttt{cancellation\_reason (VARCHAR)}, auditoría transversal. \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_appointments (id) \newline - FK: fk\_appointments\_tenant\_id, fk\_appointments\_branch\_id, fk\_appointments\_customer\_id, fk\_appointments\_vehicle\_id \newline - CHECK: chk\_appointment\_status \newline - Índices: idx\_appointments\_tenant\_branch\_date, idx\_appointments\_customer, idx\_appointments\_vehicle \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{local\_customers\_cache}} \\*
\hline
\textbf{Motor y Producto} & SQLite 3 (Mobile) \\*
\hline
\textbf{Propósito y Aislamiento} & Directorio local desconectado de clientes adscritos al taller del operario. Habilita búsquedas presenciales instantáneas durante la recepción en patio sin latencia de red. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{customer\_id (TEXT)}, \texttt{tenant\_id (TEXT)}, \texttt{display\_name (TEXT)}, \texttt{tax\_id (TEXT)}, \texttt{phone (TEXT)}, \texttt{type (TEXT)}, \texttt{synced\_at (TEXT).} \\*
\hline
\textbf{Constraints e Índices} & PK: pk\_local\_customers (customer\_id) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{local\_vehicles\_cache}} \\*
\hline
\textbf{Motor y Producto} & SQLite 3 (Mobile) \\*
\hline
\textbf{Propósito y Aislamiento} & Caché local de parque automotor para reconocimiento inmediato de placas de rodaje y validación preliminar de chasis en fosas mecánicas sin cobertura celular. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{vehicle\_id (TEXT)}, \texttt{plate (TEXT)}, \texttt{vin (TEXT)}, \texttt{brand\_model (TEXT)}, \texttt{current\_owner\_id (TEXT)}, \texttt{synced\_at (TEXT).} \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_local\_vehicles (vehicle\_id) \newline - Índice B-Tree: idx\_local\_vehicles\_plate (plate) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{local\_appointments\_cache}} \\*
\hline
\textbf{Motor y Producto} & SQLite 3 (Mobile) \\*
\hline
\textbf{Propósito y Aislamiento} & Agenda operativa del día filtrada para la sede asignada al dispositivo técnico. Permite consultar citas y anticipar bahías en frío. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{appointment\_id (TEXT)}, \texttt{tenant\_id (TEXT)}, \texttt{branch\_id (TEXT)}, \texttt{customer\_name (TEXT)}, \texttt{vehicle\_plate (TEXT)}, \texttt{scheduled\_at (TEXT)}, \texttt{status (TEXT)}, \texttt{reason (TEXT)}, \texttt{synced\_at (TEXT).} \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_local\_appointments (appointment\_id) \newline - Índice B-Tree: idx\_local\_appointments\_date (scheduled\_at) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{offline\_reception\_mutations}} \\*
\hline
\textbf{Motor y Producto} & SQLite 3 (Mobile) \\*
\hline
\textbf{Propósito y Aislamiento} & Buffer transaccional local que encola mutaciones de arribo vehicular e inspección preliminar registradas sin cobertura de red para su sincronización diferida. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{mutation\_id (TEXT)}, \texttt{appointment\_id (TEXT)}, \texttt{action\_type (TEXT)}, \texttt{payload (TEXT)}, \texttt{status (TEXT)}, \texttt{retry\_count (INTEGER)}, \texttt{created\_at (TEXT)}, \texttt{synced\_at (TEXT).} \\*
\hline
\textbf{Constraints e Índices} & - PK: pk\_offline\_reception\_mutations (mutation\_id) \newline - CHECK: chk\_mutation\_status \newline - Índice B-Tree: idx\_mutations\_status (status, created\_at) \\
\hline
\multicolumn{2}{|>{\centering\arraybackslash}p{15.4cm}|}{\textbf{Objeto de Persistencia:} \texttt{auditable\_abstract\_entity}} \\*
\hline
\textbf{Motor y Producto} & PostgreSQL 16 (API) \\*
\hline
\textbf{Propósito y Aislamiento} & Arquetipo transversal inyectado en entidades del backend para garantizar auditoría temporal, bloqueo optimista y aislamiento por tenant\_id. \\*
\hline
\textbf{Columnas Clave y Tipos} & \texttt{id (UUID)}, \texttt{tenant\_id (UUID)}, \texttt{created\_at (TIMESTAMPTZ)}, \texttt{updated\_at (TIMESTAMPTZ)}, \texttt{version (BIGINT)}, \texttt{deleted\_at (TIMESTAMPTZ).} \\*
\hline
\textbf{Constraints e Índices} & - PK técnica: id \newline - FK lógica: tenant\_id. Superclase MappedSuperclass JPA \\
\hline
\end{longtable}
\renewcommand{\arraystretch}{1.0}
*Nota.* Elaboración propia en base al diseño relacional y la especificación física de persistencia.

A partir de la estructura formalizada en la @fig:database-diagram-crm y la @tbl:crm-database-objects, se identifican tres fundamentos de ingeniería de software que sustentan la integridad, escalabilidad y resiliencia de la persistencia:

- **Desacoplamiento entre la Identidad Física Automotriz y el Aislamiento Multi-Inquilino:**
  La decisión arquitectónica de excluir la clave de particionamiento **tenant_id** en la tabla **vehicles** garantiza que cada unidad automotriz conserve una identidad global independiente de los talleres mecánicos. Al desacoplar el activo vehicular respecto a los registros de tenencia en **vehicle_ownerships**, la plataforma consolida una hoja técnica universal que preserva diagnósticos, lecturas de telemetría y mantenimientos previos ante transferencias de dominio entre clientes particulares o flotas corporativas.

- **Determinismo Temporal en la Propiedad Vehicular mediante Índices Parciales Únicos:**
  La integridad de la cadena de custodia se garantiza a nivel de motor relacional mediante el índice único condicional **uk_vehicle_active_ownership**, el cual restringe la existencia de registros con fecha de finalización nula a una sola tupla por vehículo. Este mecanismo previene condiciones de carrera o inconsistencias concurrentes durante el traspaso de activos entre empresas de transporte, asegurando que las órdenes de servicio y comprobantes fiscales se emitan inequívocamente al titular legítimo en cada fecha operativa.

- **Resiliencia Operacional Desconectada y Drenaje Asíncrono en SQLite 3:**
  La coexistencia del repositorio central en PostgreSQL 16 con el esquema local en SQLite 3 resuelve los desafíos de conectividad en fosas de inspección y patios de maniobra. La tabla **offline_reception_mutations** implementa el patrón de Outbox móvil, absorbiendo los registros de arribo vehicular y listas de verificación sin degradar la experiencia de usuario. Una vez restablecida la señal inalámbrica, los procesos en segundo plano sincronizan las mutaciones pendientes mediante reintentos exponenciales garantizando idempotencia transaccional.
