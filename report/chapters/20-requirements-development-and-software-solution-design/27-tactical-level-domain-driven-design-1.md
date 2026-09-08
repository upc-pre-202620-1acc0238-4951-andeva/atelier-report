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

| Clase o Tipo | Categoría Táctica | Paquete Canónico | Propósito en el Dominio | Relaciones Principales |
| :---: | :---: | :--- | :--- | :--- |
| AbstractDomainAggregateRoot<T> | Raíz de Agregado Base | `...shared.domain.model.aggregates` | Superclase abstracta que gestiona la acumulación en memoria de eventos de dominio. | Heredada por todas las Raíces de Agregado del sistema. |
| DomainEvent | Interfaz de Evento | `...shared.domain.events` | Contrato inmutable base para la publicación de eventos y el patrón Outbox. | Implementada por todos los eventos de dominio de la plataforma. |
| Currency | Enumeración de Dominio | `...shared.domain.model.valueobjects` | Catálogo de divisas formales aceptadas en la plataforma (PEN y USD). | Utilizada por el objeto de valor Money. |
| Money | Objeto de Valor | `...shared.domain.model.valueobjects` | Magnitud monetaria inmutable con escala a 2 decimales y redondeo Half-Even. | Asociada a precios, costos, cotizaciones y facturas. |
| MeasurementUnit | Enumeración de Dominio | `...shared.domain.model.valueobjects` | Catálogo de unidades físicas de almacenamiento y consumo en taller. | Utilizada por el objeto de valor Quantity. |
| Quantity | Objeto de Valor | `...shared.domain.model.valueobjects` | Cantidad física no negativa con escala decimal asociada a su unidad de medida. | Utilizada en inventario de repuestos y partidas de MRO. |
| Mileage | Objeto de Valor | `...shared.domain.model.valueobjects` | Odómetro automotriz expresado como entero no negativo en kilómetros. | Vinculado a vehículos, recepciones y telemetría OBD-II. |
| TenantId | Objeto de Valor (ID) | `...shared.domain.model.valueobjects` | Identificador único universal fuertemente tipado del taller mecánico. | Clave transversal de particionamiento multi-inquilino. |
| BranchId | Objeto de Valor (ID) | `...shared.domain.model.valueobjects` | Identificador único universal de la sede o sucursal física de atención. | Vinculado a bahías de servicio, almacenes y turnos. |
| CustomerId | Objeto de Valor (ID) | `...shared.domain.model.valueobjects` | Identificador único universal del cliente particular o corporativo. | Vinculado a perfiles de clientes, vehículos y comprobantes. |
| VehicleId | Objeto de Valor (ID) | `...shared.domain.model.valueobjects` | Identificador único universal de la unidad vehicular automotriz. | Vinculado a órdenes de trabajo, citas y telemetría. |
| UserId | Objeto de Valor (ID) | `...shared.domain.model.valueobjects` | Identificador único universal de la cuenta de usuario del sistema. | Vinculado a membresías de taller, perfiles y auditorías. |
| DistanceMeters | Objeto de Valor | `...shared.domain.model.valueobjects` | Magnitud escalar de separación espacial en metros no negativa. | Utilizada en la evaluación de geocercas satelitales. |
| GeoPoint | Objeto de Valor | `...shared.domain.model.valueobjects` | Coordenadas WGS84 con cálculo ortodrómico basado en la fórmula del Haversine. | Utilizada en ubicación de sucursales y marcación de asistencia. |
| TaxIdType | Enumeración de Dominio | `...shared.domain.model.valueobjects` | Tipología legal de documentos tributarios nacionales e internacionales. | Utilizada por el objeto de valor TaxId. |
| TaxId | Objeto de Valor | `...shared.domain.model.valueobjects` | Documento tributario validado mediante Módulo 11 (RUC) y longitud (DNI). | Vinculado a talleres concesionarios, clientes y facturación. |
| EmailAddress | Objeto de Valor | `...shared.domain.model.valueobjects` | Dirección de correo electrónico normalizada y validada bajo la RFC 5322. | Vinculada a cuentas de usuario, notificaciones y contactos. |
| PhoneNumber | Objeto de Valor | `...shared.domain.model.valueobjects` | Número telefónico internacional formateado según el estándar UIT-T E.164. | Vinculado a datos de contacto de clientes y mecánicos. |
| DateRange | Objeto de Valor | `...shared.domain.model.valueobjects` | Intervalo temporal cerrado con invariante estricta de orden cronológico. | Utilizado en turnos laborales, contratos y períodos de análisis. |
| DomainException | Excepción Base | `...shared.domain.exceptions` | Superclase abstracta no comprobada portadora de código de error semántico. | Base para todas las excepciones del dominio del ecosistema. |
: Catálogo de la Capa de Dominio del Bounded Context Shared {#tbl:shared-domain-types}

*Nota.* Tipos de datos canónicos correspondientes al paquete com.andeva.atelier.platform.shared.domain.

A continuación, se profundiza en la especificación a manera de diccionario de cada una de las clases, objetos de valor y estructuras que componen esta capa.

**Superclase base de agregados y contrato de eventos de dominio**

En Domain-Driven Design, las raíces de agregado salvaguardan los límites de consistencia transaccional del negocio. Para facilitar la propagación de eventos hacia otros módulos y hacia el almacenamiento seguro del Transactional Outbox sin incorporar librerías ORM en el dominio, la arquitectura suministra la clase abstracta **AbstractDomainAggregateRoot<T>**.

Esta clase emplea la técnica de polimorfismo con límite F (F-bounded polymorphism, expresado como `T extends AbstractDomainAggregateRoot<T>`), permitiendo que las clases derivadas mantengan una referencia fuertemente tipada sobre sí mismas. Al extender de la clase base de Spring Data Commons, la superclase acumula eventos de dominio en una colección interna en memoria cada vez que se invoca el método protegido *registerDomainEvent()*.

Dichos eventos quedan disponibles para su lectura inmutable mediante *domainEvents()* y son eliminados a través de *clearDomainEvents()* una vez que la transacción de persistencia se confirma exitosamente. Asimismo, sobrescribe los métodos *equals()* y *hashCode()* para asegurar que dos agregados se consideren idénticos si y solo si comparten la misma identidad de dominio, preservando la coherencia semántica en colecciones.

Por su parte, la interfaz **DomainEvent** establece el contrato inmutable universal que deben satisfacer todos los eventos de dominio del ecosistema Atelier. Cada evento generado encapsula un identificador unívoco de evento (**eventId**), la marca temporal precisa de ocurrencia en UTC (**occurredOn**), el identificador textual de la raíz de agregado emisora (**aggregateId**) y el descriptor calificado del tipo de evento (**eventType**), habilitando una deserialización polimórfica sin ambigüedades.

En la @tbl:shared-aggregates-and-events se detallan los miembros de la superclase de agregados y el contrato de eventos.

| Elemento | Tipo o Firma | Ámbito | Propósito y Reglas de Negocio |
| :---: | :--- | :---: | :--- |
| domainEvents | Collection<Object> | Protegido | Acumulador interno de eventos generados durante la transacción en memoria. |
| registerDomainEvent | `void registerDomainEvent(Object event)` | Protegido | Registra un evento de dominio no nulo; rechaza argumentos nulos con validación estricta. |
| domainEvents | `Collection<Object> domainEvents()` | Público | Expone una vista inmutable de los eventos acumulados mediante colección no modificable. |
| clearDomainEvents | `void clearDomainEvents()` | Público | Purga todos los eventos acumulados tras la persistencia transaccional. |
| equals | `boolean equals(Object obj)` | Público | Evalúa la igualdad semántica basada exclusivamente en la identidad del agregado. |
| hashCode | `int hashCode()` | Público | Genera el código hash fundamentado en la identidad del agregado. |
| eventId | UUID | Público | Retorna el identificador unívoco universal del evento para deduplicación. |
| occurredOn | Instant | Público | Retorna la marca de tiempo exacta de ocurrencia en el huso horario UTC. |
| aggregateId | String | Público | Retorna la clave de la raíz de agregado que originó el evento. |
| eventType | String | Público | Retorna el nombre semántico calificado del evento para el enrutamiento asíncrono. |
: Miembros de la Superclase Base de Agregados y la Interfaz de Eventos de Dominio {#tbl:shared-aggregates-and-events}

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

| Elemento | Tipo o Firma | Ámbito | Propósito y Reglas de Negocio |
| :---: | :--- | :---: | :--- |
| amount | BigDecimal | Privado | Monto monetario inmutable escalado a 2 decimales exactos. |
| currency | Currency | Privado | Divisa formal asociada al importe monetario. |
| ZERO_PEN | Money | Público | Constante estática representativa de cero soles (S/ 0.00). |
| ZERO_USD | Money | Público | Constante estática representativa de cero dólares ($ 0.00). |
| add | `Money add(Money other)` | Público | Suma importes; exige divisas homogéneas o arroja CurrencyMismatchException. |
| subtract | `Money subtract(Money other)` | Público | Resta importes; exige divisas homogéneas y escala uniforme. |
| multiply | `Money multiply(BigDecimal factor)` | Público | Multiplica el importe por un factor numérico con redondeo Half-Even. |
| divide | `Money divide(BigDecimal divisor)` | Público | Divide el importe; rechaza divisores iguales a cero con validación de frontera. |
| isGreaterThan | `boolean isGreaterThan(Money other)` | Público | Determina si el importe actual supera al suministrado. |
| isPositive | `boolean isPositive()` | Público | Determina si el importe es estrictamente mayor a cero. |
| isZero | `boolean isZero()` | Público | Determina si el importe es exactamente equivalente a cero. |
| value (Quantity) | BigDecimal | Privado | Magnitud cuantitativa no negativa escalada a 2 decimales. |
| unit | MeasurementUnit | Privado | Unidad de almacenamiento o tarificación física asociada. |
| add (Quantity) | `Quantity add(Quantity other)` | Público | Incrementa la cantidad asegurando correspondencia en la unidad de medida. |
| subtract (Quantity) | `Quantity subtract(Quantity other)` | Público | Reduce la cantidad sin permitir resultados por debajo de cero. |
| hasSufficient | `boolean hasSufficient(Quantity req)` | Público | Evalúa si la cantidad actual cubre o supera la magnitud requerida. |
| value (Mileage) | int | Privado | Valor numérico entero del odómetro; impone invariante (*value* ≥ 0). |
| isGreaterThan | `boolean isGreaterThan(Mileage o)` | Público | Comprueba si el kilometraje supera al valor de comparación. |
| difference | `int difference(Mileage other)` | Público | Calcula el delta absoluto de kilometraje entre dos lecturas. |
: Miembros de los Objetos de Valor Financieros, Cuantitativos y Métricos {#tbl:shared-financial-and-measurement-vos}

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

| Identificador | Tipo Subyacente | Factorías Estáticas | Propósito Arquitectónico y Frontera de Dominio |
| :---: | :---: | :--- | :--- |
| TenantId | UUID | `of(UUID)`, `of(String)`, `generate()` | Clave transversal obligatoria de particionamiento lógico multi-inquilino. |
| BranchId | UUID | `of(UUID)`, `of(String)`, `generate()` | Demarcación física de inventarios de almacén, bahías y turnos de trabajo. |
| CustomerId | UUID | `of(UUID)`, `of(String)`, `generate()` | Asociación unívoca de clientes particulares y flotas comerciales. |
| VehicleId | UUID | `of(UUID)`, `of(String)`, `generate()` | Identificación de unidades automotrices para trazabilidad MRO y telemetría. |
| UserId | UUID | `of(UUID)`, `of(String)`, `generate()` | Identificación de usuarios del sistema para control de acceso y auditoría. |
: Especificación de los Objetos de Valor de Identidad Fuertemente Tipados {#tbl:shared-identity-vos}

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

| Elemento | Tipo o Firma | Ámbito | Propósito y Reglas de Negocio |
| :---: | :--- | :---: | :--- |
| latitude | double | Privado | Latitud geográfica WGS84 dentro del rango [-90.0, 90.0]. |
| longitude | double | Privado | Longitud geográfica WGS84 dentro del rango [-180.0, 180.0]. |
| distanceTo | `DistanceMeters distanceTo(GeoPoint o)` | Público | Calcula la distancia geodésica ortodrómica aplicando la fórmula del Haversine. |
| value (Distance) | double | Privado | Magnitud física escalar en metros; impone invariante (*value* ≥ 0.0). |
| isWithinThreshold | `boolean isWithinThreshold(double t)` | Público | Evalúa si la distancia calculada se encuentra dentro del radio límite permitido. |
| value (TaxId) | String | Privado | Cadena alfanumérica depurada representativa del documento tributario. |
| type | TaxIdType | Privado | Tipología legal del documento (RUC, DNI, CE, PASSPORT). |
| ruc | `TaxId ruc(String rucValue)` | Público | Factoría estática con verificación algorítmica de Módulo 11 de SUNAT. |
| dni | `TaxId dni(String dniValue)` | Público | Factoría estática con validación estricta de 8 dígitos numéricos. |
| value (Email) | String | Privado | Dirección de correo electrónico normalizada a minúsculas bajo RFC 5322. |
| value (Phone) | String | Privado | Número telefónico internacional formateado conforme al estándar E.164. |
| startDate | LocalDate | Privado | Fecha inicial del intervalo temporal; no nula. |
| endDate | LocalDate | Privado | Fecha de término del intervalo temporal; no anterior a startDate. |
| contains | `boolean contains(LocalDate date)` | Público | Determina si una fecha específica se ubica dentro del rango cronológico. |
| overlaps | `boolean overlaps(DateRange other)` | Público | Comprueba si dos intervalos temporales presentan traslape o solapamiento. |
: Miembros de los Objetos de Valor Espaciales, Fiscales y de Contacto {#tbl:shared-spatial-fiscal-contact-vos}

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

| Excepción | Clase Base | Código de Error | Causal de Lanzamiento en el Dominio |
| :---: | :---: | :---: | :--- |
| DomainException | RuntimeException | Parametrizado | Superclase abstracta de anomalías de lógica del dominio; transporta el código de error. |
| BusinessRuleValidationException | DomainException | BUSINESS_RULE_VIOLATION | Violación explícita de invariantes de estado, argumentos no válidos o transiciones ilícitas. |
| EntityNotFoundException | DomainException | ENTITY_NOT_FOUND | Ausencia de una entidad requerida dentro de las fronteras de consistencia del agregado. |
| CurrencyMismatchException | DomainException | CURRENCY_MISMATCH | Intento de realizar operaciones aritméticas entre objetos Money de divisas incompatibles. |
: Jerarquía de Excepciones de Dominio y Códigos de Error Semánticos {#tbl:shared-domain-exceptions}

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

| Clase o Tipo | Categoría Táctica | Paquete Canónico | Propósito en la Capa | Relaciones Principales |
| :---: | :---: | :--- | :--- | :--- |
| ErrorResource | Recurso REST (DTO) | `...shared.interfaces.rest.resources` | Representación inmutable de errores HTTP estandarizada conforme a RFC 7807. | Generado por ErrorResponseAssembler y GlobalExceptionHandler. |
| MessageResource | Recurso REST (DTO) | `...shared.interfaces.rest.resources` | Respuesta inmutable para confirmaciones operativas simples sin cuerpo de entidad. | Consumido en endpoints de acciones asíncronas o de comando. |
| PagedResultResource<T> | Recurso REST (DTO) | `...shared.interfaces.rest.resources` | Contenedor genérico inmutable para colecciones paginadas de recursos. | Utilizado por controladores REST de CRM, MRO, Inventario y Facturación. |
| ErrorResponseAssembler | Ensamblador REST | `...shared.interfaces.rest.transform` | Mapea errores de aplicación hacia respuestas HTTP con ErrorResource. | Traduce códigos semánticos hacia códigos de estado HTTP oficiales. |
| ResponseEntityAssembler | Ensamblador REST | `...shared.interfaces.rest.transform` | Ensamblador genérico que traduce resultados de tipo Result a respuestas ResponseEntity. | Utilizado por los controladores REST de todos los Bounded Contexts. |
| GlobalExceptionHandler | Asesor de Controladores | `...shared.interfaces.rest` | Interceptor global (`@RestControllerAdvice`) de excepciones web y dominio. | Captura anomalías durante el ciclo de despacho HTTP de Spring MVC. |
| CorrelationIdFilter | Filtro Web Perimetral | `...shared.interfaces.rest.filters` | Filtro perimetral que inyecta X-Correlation-Id en petición, respuesta y MDC. | Filtro de máxima precedencia en la cadena de filtros web. |
: Catálogo Consolidado de la Capa de Interfaz del Bounded Context Shared {#tbl:shared-interface-types}

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

| Elemento | Tipo o Firma | Ámbito | Propósito y Reglas de Negocio |
| :---: | :--- | :---: | :--- |
| code | String | Privado | Código semántico unívoco representativo del error. |
| message | String | Privado | Explicación legible y contextual de la condición de error producida. |
| details | List<String> | Privado | Lista inmutable de fallas de validación a nivel de campo; nunca nula. |
| timestamp | Instant | Privado | Marca temporal precisa en huso horario UTC del instante del error. |
| of (Error) | `ErrorResource of(String c, String m)` | Público | Factoría estática para instanciación rápida de errores sin lista de detalles. |
| of (Error con detalles) | `ErrorResource of(String c, String m, List<String> d)` | Público | Factoría estática para errores complejos con desglose de campos observados. |
| message | String | Privado | Mensaje textual de confirmación operativa en MessageResource. |
| of (Message) | `MessageResource of(String msg)` | Público | Factoría estática que asocia el mensaje con la estampa de tiempo actual. |
| items | List<T> | Privado | Colección inmutable de elementos correspondientes a la página solicitada. |
| page | int | Privado | Índice de página actual; impone invariante estricta (*page* ≥ 0). |
| size | int | Privado | Cantidad máxima de registros por página; impone invariante (*size* > 0). |
| totalElements | long | Privado | Cardinalidad total de registros existentes; impone (*totalElements* ≥ 0). |
| totalPages | int | Privado | Total de páginas resultantes calculadas mediante redondeo hacia arriba. |
| first | boolean | Privado | Bandera lógica que certifica si la respuesta corresponde a la primera página. |
| last | boolean | Privado | Bandera lógica que certifica si la respuesta corresponde a la página de término. |
| of (PagedResult) | `PagedResultResource<T> of(List<T> i, int p, int s, long t)` | Público | Factoría estática que computa automáticamente totales y banderas de frontera. |
: Miembros de los Recursos REST DTO del Bounded Context Shared {#tbl:shared-interface-resources}

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

| Elemento | Tipo o Firma | Ámbito | Propósito y Reglas de Negocio |
| :---: | :--- | :---: | :--- |
| toErrorResponseFromApplicationError | `ResponseEntity<ErrorResource> (ApplicationError error)` | Público | Traduce el código de error semántico a código de estado HTTP y genera ErrorResource. |
| toResponseEntityFromResult | `ResponseEntity<?> (Result<T, ApplicationError>, Function<T, R>, HttpStatus)` | Público | Mapea resultados funcionales de entidades individuales aplicando ensamblado funcional. |
| toResponseEntityFromListResult | `ResponseEntity<?> (Result<List<T>, ApplicationError>, Function<T, R>, HttpStatus)` | Público | Mapea resultados funcionales de listas de entidades transformando cada registro. |
| toResponseEntityFromEmptyResult | `ResponseEntity<?> (Result<Void, ApplicationError>, HttpStatus)` | Público | Mapea resultados funcionales vacíos emitiendo cabeceras de éxito sin cuerpo de respuesta. |
: Métodos de los Ensambladores REST del Bounded Context Shared {#tbl:shared-interface-assemblers}

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

| Método Manejador | Excepción Interceptada | Código Emitido | Código HTTP Resultante | Causal de Activación |
| :---: | :--- | :---: | :---: | :--- |
| handleMethodArgumentNotValid | MethodArgumentNotValidException | VALIDATION_FAILED | 400 BAD REQUEST | Fallas en restricciones Bean Validation (`@Valid`) en cuerpos DTO entrantes. |
| handleConstraintViolation | ConstraintViolationException | CONSTRAINT_VIOLATION | 400 BAD REQUEST | Violación de restricciones en parámetros de consulta (`@RequestParam`) o ruta. |
| handleDomainException | DomainException | Parametrizado (errorCode) | 422 UNPROCESSABLE_ENTITY | Transgresión de invariantes de negocio no interceptadas en la capa de aplicación. |
| handleHttpMessageNotReadable | HttpMessageNotReadableException | MALFORMED_JSON_REQUEST | 400 BAD REQUEST | Cuerpos de solicitud con sintaxis JSON corrupta o tipos de datos incompatibles. |
| handleMethodNotSupported | HttpRequestMethodNotSupportedException | METHOD_NOT_ALLOWED | 405 METHOD NOT ALLOWED | Invocación de un endpoint mediante un verbo HTTP no habilitado. |
| handleMediaTypeNotSupported | HttpMediaTypeNotSupportedException | UNSUPPORTED_MEDIA_TYPE | 415 UNSUPPORTED MEDIA | Peticiones que especifican un encabezado Content-Type no aceptado por la API. |
| handleUnhandledException | Exception | INTERNAL_SERVER_ERROR | 500 INTERNAL ERROR | Fallos imprevistos de infraestructura; registra en log con correlationId y oculta stack trace. |
: Métodos de Intercepción del Controlador Global de Excepciones {#tbl:shared-global-exception-handler}

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

| Elemento | Tipo o Firma | Ámbito | Propósito y Reglas de Negocio |
| :---: | :--- | :---: | :--- |
| CORRELATION_ID_HEADER | String | Público | Constante estática con el nombre oficial del encabezado HTTP (`X-Correlation-Id`). |
| CORRELATION_ID_MDC_KEY | String | Público | Clave identificadora para el contexto Mapped Diagnostic Context (`correlationId`). |
| doFilterInternal | `void (HttpServletRequest, HttpServletResponse, FilterChain)` | Protegido | Lógica de extracción, generación, inyección en MDC, asignación en respuesta y purga. |
: Miembros del Filtro de Trazabilidad y Correlación Distribuida {#tbl:shared-correlation-filter}

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

| Clase o Tipo | Categoría Táctica | Paquete Canónico | Propósito en la Capa | Relaciones Principales |
| :---: | :---: | :--- | :--- | :--- |
| Result<T, E> | Tipo de Resultado | `...shared.application.result` | Interfaz sellada que modela el resultado determinista de operaciones de negocio. | Retorno universal de Command y Query Handlers. |
| ApplicationError | Registro de Error | `...shared.application.result` | Estructura inmutable portadora de código semántico, mensaje y detalles. | Transportado en el camino Failure del tipo de resultado Result. |
| CommandHandler<C, R> | Contrato CQRS | `...shared.application.handlers` | Interfaz funcional para casos de uso de mutación transaccional con retorno. | Implementada por servicios de comando en todos los módulos. |
| VoidCommandHandler<C> | Contrato CQRS | `...shared.application.handlers` | Interfaz funcional para casos de uso mutacionales sin valor de retorno. | Implementada por comandos de acción mutacional simple. |
| QueryHandler<Q, R> | Contrato CQRS | `...shared.application.handlers` | Interfaz funcional para casos de uso de recuperación y lectura de datos. | Implementada por servicios de consulta en todos los módulos. |
| DomainEventHandler<E> | Manejador de Eventos | `...shared.application.handlers` | Interfaz funcional para consumidores en memoria de eventos de dominio. | Suscrita a eventos emitidos tras el commit transaccional. |
| SortDirection | Enumeración | `...shared.application.pagination` | Sentido de ordenamiento cronológico o alfabético (ASC, DESC). | Utilizada por el registro de consulta PagedQuery. |
| PagedQuery | Modelo de Consulta | `...shared.application.pagination` | Solicitud inmutable de paginación agnóstica de frameworks ORM. | Parámetro de entrada en consultas paginadas de la aplicación. |
| PagedResult<T> | Contenedor de Datos | `...shared.application.pagination` | Envoltorio inmutable de colecciones paginadas con metadatos de cálculo. | Retorno de consultas de listado; mapeado a la Capa de Interfaz. |
| DomainEventPublisher | Puerto de Aplicación | `...shared.application.events` | Contrato para la emisión de eventos hacia el Transactional Outbox. | Invocado por repositorios y servicios de aplicación. |
: Catálogo Consolidado de la Capa de Aplicación del Bounded Context Shared {#tbl:shared-application-types}

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

| Elemento | Tipo o Firma | Ámbito | Propósito y Reglas de Negocio |
| :---: | :--- | :---: | :--- |
| Success | `record Success<T, E>(T value)` | Público | Subtipo inmutable que encapsula el valor satisfactorio no nulo. |
| Failure | `record Failure<T, E>(E error)` | Público | Subtipo inmutable que encapsula la condición de error no nula. |
| success | `Result<T, E> success(T value)` | Público | Factoría estática que instancia un resultado exitoso validando no nulidad. |
| failure | `Result<T, E> failure(E error)` | Público | Factoría estática que instancia un resultado fallido validando no nulidad. |
| fromOptional | `Result<T, E> fromOptional(Optional<T>, E)` | Público | Convierte un `Optional` a `Result`, asignando el error indicado si está vacío. |
| isSuccess | `boolean isSuccess()` | Público | Predicado booleano que certifica si la ejecución fue satisfactoria (`instanceof Success`). |
| isFailure | `boolean isFailure()` | Público | Predicado booleano que certifica si la ejecución experimentó un fallo (`instanceof Failure`). |
| toOptional | `Optional<T> toOptional()` | Público | Proyecta el valor exitoso a un `Optional`, retornando `Optional.empty()` si es fallo. |
| toErrorOptional | `Optional<E> toErrorOptional()` | Público | Proyecta el error a un `Optional`, retornando `Optional.empty()` si es éxito. |
| map | `Result<R, E> map(Function<? super T, ? extends R>)` | Público | Aplica la función transformadora sobre el valor en caso de éxito. |
| flatMap | `Result<R, E> flatMap(Function<? super T, Result<R, E>>)` | Público | Encadena secuencialmente otra operación funcional sobre el valor exitoso. |
| mapError | `Result<T, F> mapError(Function<? super E, ? extends F>)` | Público | Transforma funcionalmente la estructura del objeto de error en caso de fallo. |
| onSuccess | `Result<T, E> onSuccess(Consumer<? super T>)` | Público | Ejecuta un efecto secundario declarativo únicamente si el resultado es exitoso. |
| onFailure | `Result<T, E> onFailure(Consumer<? super E>)` | Público | Ejecuta un efecto secundario declarativo únicamente si el resultado es un fallo. |
| orElse | `T orElse(T defaultValue)` | Público | Retorna el valor contenido o el valor predeterminado si es fallo. |
| orElseGet | `T orElseGet(Supplier<? extends T>)` | Público | Retorna el valor contenido o invoca el proveedor suministrado si es fallo. |
| orElseThrow | `T orElseThrow(Function<? super E, X>) throws X` | Público | Extrae el valor exitoso o arroja la excepción derivada del error. |
: Miembros y Operaciones del Tipo de Resultado Funcional Result {#tbl:shared-result-type}

*Nota.* Componente ubicado en el paquete com.andeva.atelier.platform.shared.application.result.

- **ApplicationError**: Registro inmutable que tipifica semánticamente las condiciones anómalas de la aplicación. Encapsula un código alfanumérico identificador (**code**), un mensaje inteligible para el usuario o diagnóstico (**message**) y una lista inmutable de detalles específicos de validación (**details**).

  En su constructor compacto impone validación estricta de no nulidad sobre el código y el mensaje, aplicando copias defensivas inmutables (`List.copyOf`) sobre los detalles para evitar modificaciones posteriores. Suministra un catálogo de métodos factoría semánticos que cubren la totalidad de transgresiones de negocio del ecosistema Atelier.

En la @tbl:shared-application-error se especifican los atributos y el catálogo completo de factorías semánticas de **ApplicationError**.

| Elemento | Tipo o Firma | Ámbito | Propósito y Reglas de Negocio |
| :---: | :--- | :---: | :--- |
| code | String | Privado | Código alfanumérico estandarizado del error (no nulo). |
| message | String | Privado | Mensaje explicativo y contextual de la condición observada (no nulo). |
| details | List<String> | Privado | Lista inmutable de observaciones o fallas específicas de validación de campo. |
| Constructor Compacto | `ApplicationError(...)` | Público | Garantiza no nulidad de código y mensaje, y genera copia inmutable de `details`. |
| notFound (con ID) | `ApplicationError notFound(String, Object)` | Público | Genera error NOT_FOUND con mensaje formateado de recurso e identificador. |
| notFound (simple) | `ApplicationError notFound(String)` | Público | Genera error NOT_FOUND con mensaje descriptivo directo. |
| conflict | `ApplicationError conflict(String)` | Público | Genera error CONFLICT ante colisiones de unicidad o conflictos de concurrencia. |
| badRequest (simple) | `ApplicationError badRequest(String)` | Público | Genera error BAD_REQUEST ante argumentos inválidos o sintaxis incorrecta. |
| badRequest (con detalles) | `ApplicationError badRequest(String, List<String>)` | Público | Genera error BAD_REQUEST asociando la lista de transgresiones por campo observadas. |
| unauthorized | `ApplicationError unauthorized(String)` | Público | Genera error UNAUTHORIZED ante fallas de autenticación o credenciales ausentes. |
| forbidden | `ApplicationError forbidden(String)` | Público | Genera error FORBIDDEN ante transgresiones de permisos o restricciones de rol (RBAC). |
| unprocessableEntity | `ApplicationError unprocessableEntity(String)` | Público | Genera error UNPROCESSABLE_ENTITY ante invariantes de negocio procesables insatisfechas. |
| internalError | `ApplicationError internalError(String)` | Público | Genera error INTERNAL_ERROR ante contingencias inesperadas o fallas de infraestructura. |
: Miembros y Factorías Semánticas del Registro ApplicationError {#tbl:shared-application-error}

*Nota.* Componente ubicado en el paquete com.andeva.atelier.platform.shared.application.result.

En cuanto a sus relaciones en el sistema, el tipo de resultado **Result** actúa como el tipo de retorno universal para la totalidad de servicios de aplicación y manejadores CQRS de los ocho bounded contexts. A su vez, es consumida en la Capa de Interfaz por **ResponseEntityAssembler**, cerrando el ciclo de vida de la petición de forma limpia y tipada.

**Contratos Base Transversales para CQRS**

Para asegurar que los casos de uso en todos los módulos de Atelier mantengan una estructura predecible y homogénea, el Bounded Context Shared delimita las interfaces funcionales que modelan los manejadores de comandos, consultas y eventos:

- **CommandHandler<C, R>** y **VoidCommandHandler<C>**: Interfaces funcionales (`@FunctionalInterface`) que regulan los casos de uso de mutación de estado. El comando C representa una intención inmutable de cambio de estado transaccional. El manejador orquesta la recuperación del agregado, invoca sus métodos de negocio, persiste los cambios y despacha eventos, retornando un **Result<R, ApplicationError>** o **Result<Void, ApplicationError>** sin arrojar excepciones de control.
- **QueryHandler<Q, R>**: Interfaz funcional (`@FunctionalInterface`) que gobierna los casos de uso de solo lectura. El objeto de consulta Q transporta los criterios de filtrado y paginación requeridos, mientras que el manejador accede a vistas optimizadas o repositorios de lectura para proyectar la información directamente en DTOs de salida, retornando **Result<R, ApplicationError>**.
- **DomainEventHandler<E extends DomainEvent>**: Interfaz funcional (`@FunctionalInterface`) que tipifica a los suscriptores en memoria de eventos de dominio emitidos por raíces de agregado. Al delimitar el parámetro genérico `E` con la interfaz inmutable **DomainEvent**, asegura que cualquier manejador de eventos del ecosistema responda exclusivamente a sucesos legítimos del dominio tras confirmarse la transacción de persistencia.

En la @tbl:shared-cqrs-handlers se sintetizan las firmas y responsabilidades de estos contratos CQRS.

| Contrato | Tipo de Componente | Método Principal | Responsabilidad Arquitectónica |
| :---: | :---: | :--- | :--- |
| CommandHandler<C, R> | Interfaz Funcional | `Result<R, ApplicationError> handle(C command)` | Coordina mutaciones transaccionales que producen un resultado o entidad. |
| VoidCommandHandler<C> | Interfaz Funcional | `Result<Void, ApplicationError> handle(C command)` | Coordina mutaciones transaccionales de acción simple sin carga útil de retorno. |
| QueryHandler<Q, R> | Interfaz Funcional | `Result<R, ApplicationError> handle(Q query)` | Ejecuta consultas de lectura optimizadas proyectando resultados en DTOs. |
| DomainEventHandler<E> | Interfaz Funcional | `void handle(E event)` | Consume y procesa de forma desacoplada eventos de dominio en memoria. |
: Contratos Base para Manejadores CQRS del Bounded Context Shared {#tbl:shared-cqrs-handlers}

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

| Elemento | Tipo o Firma | Ámbito | Propósito y Reglas de Negocio |
| :---: | :--- | :---: | :--- |
| ASC / DESC | SortDirection | Público | Constantes que delimitan el sentido del ordenamiento en consultas. |
| page (Query) | int | Privado | Índice de página solicitado; impone la invariante estricta (*page* ≥ 0). |
| size (Query) | int | Privado | Límite de elementos por página; impone la invariante estricta (*size* > 0). |
| sortBy | String | Privado | Nombre del atributo sobre el cual ordenar; asigna "id" por defecto. |
| sortDirection | SortDirection | Privado | Dirección de ordenación asociada; asigna ASC por defecto. |
| of (simple) | `PagedQuery of(int page, int size)` | Público | Factoría estática con valores por defecto para campo ("id") y dirección (ASC). |
| of (completa) | `PagedQuery of(int, int, String, SortDirection)` | Público | Factoría estática con parametrización total de ordenamiento. |
| content | List<T> | Privado | Colección inmutable y copia defensiva de elementos de la página. |
| totalElements | long | Privado | Cantidad total de registros existentes en base de datos (*totalElements* ≥ 0). |
| totalPages | int | Privado | Número total de páginas calculadas mediante función techo matemática. |
| of (PagedResult) | `PagedResult<T> of(List<T>, int, int, long)` | Público | Factoría estática que computa automáticamente las páginas totales. |
| map | `PagedResult<R> map(Function<? super T, ? extends R>)` | Público | Transforma funcionalmente los elementos preservando metadatos de paginación. |
: Miembros de los Modelos de Paginación de la Capa de Aplicación {#tbl:shared-pagination-models}

*Nota.* Componentes pertenecientes al paquete com.andeva.atelier.platform.shared.application.pagination.

En cuanto a sus relaciones, **PagedQuery** es recibido por los manejadores de consultas de CRM (búsqueda de clientes y flotas), MRO (órdenes de trabajo por estado o mecánico), Inventario (repuestos con stock crítico) y Facturación (comprobantes por rango de fechas). A su vez, **PagedResult<T>** es devuelto por dichos manejadores y transformado directamente hacia **PagedResultResource<T>** en la Capa de Interfaz.

**Puerto de Publicación y Despacho de Eventos**

En Clean Architecture, la propagación de eventos fuera de las fronteras de un bounded context o hacia colas de mensajería asíncrona no debe realizarse directamente desde las entidades ni acoplarse a clases de infraestructura como `ApplicationEventPublisher` de Spring.

Para gobernar este proceso, la Capa de Aplicación del Bounded Context Shared delimita el puerto formal **DomainEventPublisher**. Esta interfaz suministra dos contratos esenciales:

- *publish(DomainEvent event)*: Emite un evento de dominio individual inmediatamente después de confirmarse una operación unitaria.
- *publishAll(Collection<Object> events)*: Extrae y emite en bloque todos los eventos acumulados en la colección en memoria de una raíz de agregado (`aggregate.domainEvents()`), coordinando su registro en la tabla transaccional del Outbox (`outbox_messages`) antes de purgar la cola mediante `aggregate.clearDomainEvents()`.

En la @tbl:shared-event-publisher se especifican los métodos de este puerto de aplicación.

| Método | Firma | Ámbito | Propósito y Reglas de Negocio |
| :---: | :--- | :---: | :--- |
| publish | `void publish(DomainEvent event)` | Público | Despacha un evento de dominio individual verificando su no nulidad. |
| publishAll | `void publishAll(Collection<Object> events)` | Público | Despacha en lote la colección de eventos extraída de la raíz de agregado. |
: Métodos del Puerto de Publicación de Eventos de Dominio {#tbl:shared-event-publisher}

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

| Clase o Tipo | Categoría Táctica | Paquete Canónico | Propósito en la Capa | Relaciones Principales |
| :---: | :---: | :--- | :--- | :--- |
| AuditableAbstractPersistenceEntity | Superclase JPA | `...shared.infrastructure.persistence.jpa.entities` | Base abstracta con clave primaria UUID y marcas temporales de auditoría automáticas. | Heredada por todas las entidades **PersistenceEntity** del sistema. |
| MoneyAttributeConverter | Convertidor JPA | `...shared.infrastructure.persistence.jpa.converters` | Mapeo bidireccional seguro entre **Money** y NUMERIC(12, 2). | Aplica sobre columnas de importe en cotizaciones, órdenes y facturas. |
| MileageAttributeConverter | Convertidor JPA | `...shared.infrastructure.persistence.jpa.converters` | Mapeo bidireccional entre **Mileage** y columna escalar INTEGER. | Aplica sobre odómetros en vehículos, recepciones y telemetría. |
| TaxIdAttributeConverter | Convertidor JPA | `...shared.infrastructure.persistence.jpa.converters` | Mapeo bidireccional nulo-seguro entre **TaxId** y columna VARCHAR(11). | Aplica sobre identificadores fiscales (RUC, DNI) en clientes y talleres. |
| EmailAddressAttributeConverter | Convertidor JPA | `...shared.infrastructure.persistence.jpa.converters` | Mapeo bidireccional normalizado entre **EmailAddress** y VARCHAR(254). | Aplica sobre direcciones de correo en perfiles de usuario y contacto. |
| PhoneNumberAttributeConverter | Convertidor JPA | `...shared.infrastructure.persistence.jpa.converters` | Mapeo bidireccional entre **PhoneNumber** y columna VARCHAR(15). | Aplica sobre números telefónicos estandarizados bajo la norma E.164. |
| SnakeCaseWithPluralizedTablePhysicalNamingStrategy | Estrategia Física | `...shared.infrastructure.persistence.jpa.configuration.strategy` | Convención Hibernate de nombrado de tablas pluralizadas en snake_case. | Integrada en la configuración de EntityManagerFactory de Spring Boot. |
| OutboxStatus | Enumeración | `...shared.infrastructure.outbox.entities` | Ciclo de vida transaccional del mensaje outbox (PENDING, PUBLISHED, FAILED). | Atributo de estado en **OutboxMessagePersistenceEntity**. |
| OutboxMessagePersistenceEntity | Entidad JPA | `...shared.infrastructure.outbox.entities` | Entidad relacional mapeada a la tabla transaccional **outbox_messages**. | Persistida en PostgreSQL por **JpaDomainEventPublisher**. |
| OutboxMessageJpaRepository | Repositorio Spring Data | `...shared.infrastructure.outbox.repositories` | Interfaz de persistencia y sondeo ordenado de mensajes outbox pendientes. | Invocada por el worker asíncrono de reintento y despacho a colas. |
| JpaDomainEventPublisher | Adaptador de Salida | `...shared.infrastructure.outbox.publisher` | Implementación del puerto **DomainEventPublisher** mediante inserción outbox. | Implementa el puerto de aplicación; interactúa con PostgreSQL y Spring. |
| OpenApiConfiguration | Configuración | `...shared.infrastructure.documentation.openapi.configuration` | Definición de metadatos globales OpenAPI 3.0 y esquemas de seguridad Bearer JWT. | Utilizada por Swagger UI y herramientas de generación de contratos. |
: Catálogo Consolidado de la Capa de Infraestructura del Bounded Context Shared {#tbl:shared-infrastructure-types}

*Nota.* Componentes pertenecientes al paquete canónico com.andeva.atelier.platform.shared.infrastructure.

A continuación, se detalla la especificación formal a manera de diccionario de cada uno de los componentes de esta capa.

**Superclase Base de Persistencia y Auditoría JPA**

En arquitecturas guiadas por el dominio, acoplar las clases del dominio a anotaciones de un framework de mapeo relacional genera fugas de abstracción y complejiza las pruebas unitarias. Por este motivo, el modelo relacional de Atelier confina las dependencias de Jakarta Persistence a entidades dedicadas, las cuales extienden la superclase **AuditableAbstractPersistenceEntity**.

Esta clase está anotada con `@MappedSuperclass` y registrada ante el interceptor `@EntityListeners(AuditingEntityListener.class)` de Spring Data JPA. Gestiona una clave primaria técnica de tipo UUID generada automáticamente mediante `@GeneratedValue(strategy = GenerationType.UUID)` y mapeada a una columna nativa inmodificable.

Asimismo, captura de forma transparente las marcas temporales de auditoría mediante las anotaciones `@CreatedDate` y `@LastModifiedDate`, asignando valores de tipo Instant en UTC en el momento de inserción y en cada actualización transaccional. Además, sobrescribe los métodos *equals()* y *hashCode()* fundamentándose en el identificador persistido para garantizar consistencia semántica en colecciones gestionadas por el contexto de persistencia de Hibernate.

En la @tbl:shared-auditable-entity se detallan los miembros y directrices de diseño de esta superclase.

| Elemento | Tipo o Firma | Ámbito | Propósito y Reglas de Persistencia |
| :---: | :--- | :---: | :--- |
| id | UUID | Privado | Clave primaria técnica `@Id`; columna uuid inmodificable y no nula. |
| createdAt | Instant | Privado | Marca temporal de creación `@CreatedDate`; columna inmodificable y no nula. |
| updatedAt | Instant | Privado | Marca temporal de última modificación `@LastModifiedDate`; columna no nula. |
| getId / setId | `UUID getId()`, `void setId(UUID)` | Público | Métodos de acceso y asignación requeridos por la especificación JPA. |
| getCreatedAt / setCreatedAt | `Instant getCreatedAt()`, `void setCreatedAt(Instant)` | Público | Métodos de acceso para la marca temporal auditada de inserción. |
| getUpdatedAt / setUpdatedAt | `Instant getUpdatedAt()`, `void setUpdatedAt(Instant)` | Público | Métodos de acceso para la marca temporal auditada de actualización. |
| equals | `boolean equals(Object o)` | Público | Evalúa igualdad basada exclusivamente en el identificador técnico no nulo. |
| hashCode | `int hashCode()` | Público | Retorna código hash consistente basado en la clase de persistencia. |
: Miembros de la Superclase Base de Persistencia y Auditoría JPA {#tbl:shared-auditable-entity}

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

| Convertidor | Tipo Dominio | Tipo Base de Datos | Método a Base de Datos | Método a Entidad Dominio |
| :---: | :---: | :--- | :--- | :--- |
| MoneyAttributeConverter | Money | BigDecimal (NUMERIC(12,2)) | `attribute.amount()` (o null) | `Money.of(dbData, Currency.PEN)` |
| MileageAttributeConverter | Mileage | Integer (INTEGER) | `attribute.value()` (o null) | `new Mileage(dbData)` |
| TaxIdAttributeConverter | TaxId | String (VARCHAR(11)) | `attribute.value()` (o null) | `new TaxId(deduceType(dbData), dbData)` |
| EmailAddressAttributeConverter | EmailAddress | String (VARCHAR(254)) | `attribute.value()` (o null) | `new EmailAddress(dbData)` |
| PhoneNumberAttributeConverter | PhoneNumber | String (VARCHAR(15)) | `attribute.value()` (o null) | `new PhoneNumber(dbData)` |
: Catálogo de Convertidores JPA para Objetos de Valor {#tbl:shared-jpa-converters}

*Nota.* Componentes pertenecientes al paquete com.andeva.atelier.platform.shared.infrastructure.persistence.jpa.converters.

Respecto a sus relaciones, estos convertidores son referenciados explícitamente mediante la anotación `@Convert(converter = ...)` en los campos correspondientes de las entidades de persistencia en todos los módulos de Atelier, eliminando la necesidad de tablas secundarias para tipos de dato escalares.

**Estrategia Física de Nombrado de Tablas y Columnas**

La denominación de artefactos en bases de datos relacionales debe mantener una convención uniforme que facilite el mantenimiento y la interoperabilidad con herramientas de migración (Flyway). Para automatizar esta correspondencia, el Bounded Context Shared define la clase **SnakeCaseWithPluralizedTablePhysicalNamingStrategy**.

Esta clase hereda de **CamelCaseToUnderscoresNamingStrategy** de Hibernate 6.x y sobrescribe dos métodos fundamentales:

- *toPhysicalTableName()*: Intercepta el nombre lógico de la entidad, suprime los sufijos técnicos de persistencia (**PersistenceEntity** o **Entity**), aplica un algoritmo determinista de pluralización sintáctica en idioma inglés (transformando terminaciones como consonante más `y` en `ies`, silbantes `s`, `sh`, `ch`, `x`, `z` en `es`, y agregando `s` en casos generales), y finalmente convierte la cadena resultante a notación snake_case en minúsculas.
- *toPhysicalColumnName()*: Transforma propiedades de la entidad expresadas en notación camelCase hacia columnas relacionales en notación snake_case en minúsculas.

En la @tbl:shared-naming-strategy se sintetizan las responsabilidades y métodos de esta estrategia.

| Método | Firma | Ámbito | Regla de Transformación Físico-Relacional |
| :---: | :--- | :---: | :--- |
| toPhysicalTableName | `Identifier toPhysicalTableName(Identifier, JdbcEnv)` | Público | Elimina sufijos técnicos, pluraliza en inglés y convierte a snake_case minúsculas. |
| toPhysicalColumnName | `Identifier toPhysicalColumnName(Identifier, JdbcEnv)` | Público | Transforma nombres de campos camelCase en columnas snake_case minúsculas. |
| pluralize | `String pluralize(String input)` | Privado | Aplica reglas gramaticales estándar de sufijación plural en inglés. |
: Métodos de la Estrategia Física de Nombrado Relacional {#tbl:shared-naming-strategy}

*Nota.* Componente ubicado en com.andeva.atelier.platform.shared.infrastructure.persistence.jpa.configuration.strategy.

En términos de integración, esta estrategia se registra en el archivo de configuración `application.yml` bajo la propiedad `spring.jpa.hibernate.naming.physical-strategy`, gobernando de manera transversal la generación física del esquema en PostgreSQL.

**Infraestructura del Patrón Transactional Outbox**

La comunicación asíncrona confiable entre bounded contexts o hacia sistemas externos exige evitar la escritura dual desincronizada, en la cual un fallo de red posterior al commit transaccional impide publicar el evento correspondiente. Para resolver esta contingencia, el Bounded Context Shared implementa el patrón Transactional Outbox mediante cuatro componentes especializados:

- **OutboxStatus**: Enumeración que tipifica el ciclo de vida del mensaje outbox en tres estados disjuntos: PENDING (mensaje registrado atómicamente y listo para despacho), PUBLISHED (mensaje despachado y confirmado satisfactoriamente hacia el broker) y FAILED (mensaje que agotó sus intentos de reintento por fallo persistente).
- **OutboxMessagePersistenceEntity**: Entidad relacional mapeada a la tabla **outbox_messages**. Incorpora un índice compuesto **idx_outbox_status_occurred_on** sobre las columnas **status** y **occurred_on** para optimizar las consultas de sondeo. Almacena el tipo de agregado (**aggregate_type**), el identificador del agregado (**aggregate_id**), el nombre semántico del evento (**event_type**), la carga útil serializada en una columna nativa JSONB de PostgreSQL (**payload**), la fecha de ocurrencia (**occurred_on**), el estado actual (**status**), el contador de reintentos (**retry_count**), el último mensaje de error (**last_error**) y la marca de tiempo de procesamiento (**processed_at**). Su factoría estática *pendingOf()* estandariza la instanciación en estado pendiente con cero reintentos.
- **OutboxMessageJpaRepository**: Repositorio Spring Data JPA que expone la consulta de sondeo derivada *findTop50ByStatusOrderByOccurredOnAsc(OutboxStatus status)*. Esta consulta recupera en bloques controlados los eventos pendientes en riguroso orden cronológico ascendente, minimizando el impacto de contención de bloqueos en la base de datos.
- **JpaDomainEventPublisher**: Adaptador de salida que implementa el puerto **DomainEventPublisher** de la Capa de Aplicación. Anotado con `@Transactional(propagation = Propagation.MANDATORY)`, exige que exista una transacción activa abierta por el caso de uso invocador. Serializa el evento a JSON mediante **ObjectMapper** de Jackson, inserta la entidad **OutboxMessagePersistenceEntity** en PostgreSQL y emite en paralelo el evento al contexto de Spring mediante **ApplicationEventPublisher** para notificar a los suscriptores en memoria tras el commit.

En la @tbl:shared-outbox-infrastructure se detallan los elementos de la infraestructura del Transactional Outbox.

| Componente | Tipo de Elemento | Firma o Definición | Responsabilidad Arquitectónica |
| :---: | :---: | :--- | :--- |
| OutboxStatus | Enumeración | PENDING, PUBLISHED, FAILED | Modela las etapas de vida transaccional del mensaje outbox. |
| OutboxMessagePersistenceEntity | Entidad JPA | Tabla outbox_messages | Estructura inmutable relacional con carga útil JSONB y auditoría de reintentos. |
| pendingOf | Factoría Estática | `pendingOf(type, id, event, payload, date)` | Construye un registro outbox en estado inicial PENDING con contador cero. |
| findTop50ByStatusOrderByOccurredOnAsc | Consulta Derivada | `List<OutboxMessagePersistenceEntity> (...)` | Sondeo cronológico de los 50 mensajes pendientes prioritarios para despacho. |
| publish | Método Adaptador | `void publish(DomainEvent event)` | Serializa el evento a JSON e inserta el registro outbox dentro de la transacción. |
| publishAll | Método Adaptador | `void publishAll(Collection<Object> events)` | Itera y despacha la colección completa de eventos extraída de la raíz de agregado. |
: Componentes y Métodos de la Infraestructura del Transactional Outbox {#tbl:shared-outbox-infrastructure}

*Nota.* Componentes ubicados en com.andeva.atelier.platform.shared.infrastructure.outbox.

Respecto a sus relaciones, este mecanismo desacopla la mutación local del agregado del transporte externo. Los manejadores de comandos invocan **JpaDomainEventPublisher**, el cual persiste el mensaje en PostgreSQL; posteriormente, un proceso worker desacoplado consulta **OutboxMessageJpaRepository** periódicamente para publicar los mensajes en el intermediario de mensajería asíncrona **RabbitMQ**, garantizando entrega confiable sin bloqueo transaccional.

**Configuración de Metadatos OpenAPI 3.0**

La estandarización de contratos de interfaz en un entorno modular multisede requiere la publicación de especificaciones precisas para los equipos de desarrollo frontend (Angular) y móvil (Flutter). La clase **OpenApiConfiguration** centraliza estos contratos mediante la biblioteca SpringDoc OpenAPI 2.8.

Configurada con la anotación `@Configuration`, declara el bean *customOpenAPI()* que suministra los metadatos generales de la solución, parametriza los servidores de ejecución, y define el esquema de seguridad global **bearerAuth**. Dicho esquema modela el transporte de credenciales mediante el encabezado HTTP Authorization con tokens JWT firmados digitalmente conforme al estándar RFC 7519, asegurando que las interfaces de exploración interactiva de Swagger UI apliquen autenticación transparente sobre los endpoints protegidos.

En la @tbl:shared-openapi-configuration se resumen los parámetros configurados por este componente.

| Elemento de Configuración | Parámetro o Esquema | Valor o Definición | Propósito en la Arquitectura |
| :---: | :--- | :--- | :--- |
| applicationName | Inyección `@Value` | `spring.application.name` | Título dinámico asignado a la documentación interactiva. |
| customOpenAPI | Bean Spring `@Bean` | Retorna instancia OpenAPI | Ensambla información, servidores y esquemas de seguridad global. |
| bearerAuth | Esquema de Seguridad | HTTP Bearer (JWT RFC 7519) | Exige inclusión de token de autorización en peticiones protegidas. |
| Servidores de Ejecución | Lista de Server | `/api/v1` y URL de Producción | Enrutamiento perimetral para ejecución de pruebas interactivas. |
: Parámetros y Componentes de Configuración de OpenAPI 3.0 {#tbl:shared-openapi-configuration}

*Nota.* Componente ubicado en com.andeva.atelier.platform.shared.infrastructure.documentation.openapi.configuration.

En cuanto a sus relaciones en el sistema, **OpenApiConfiguration** opera transversalmente descubriendo y catalogando automáticamente los controladores REST definidos en los ocho bounded contexts de Atelier, sirviendo como contrato formal para la interoperabilidad del ecosistema cliente-servidor.

#### 2.6.1.5. Bounded Context Software Architecture Component Level Diagrams

En esta sección se presenta la descomposición arquitectónica interna del contenedor central **API Application** en relación con el Bounded Context Shared.

Dentro de la arquitectura de monolito modular de Atelier Platform, el Bounded Context Shared no opera como un subsistema periférico ni como un módulo funcional aislado, sino como la fundación arquitectónica e infraestructura transversal que dota de coherencia e interoperabilidad a los ocho bounded contexts de negocio: IAM & Tenancy, Customer & Fleet, Workshop Operations, Inventory & Supply Chain, Human Resources, Invoicing & Compliance, SaaS Billing e IoT Telemetry.

Todos los controladores REST, servicios de comando y consulta, agregados de dominio, entidades relacionales y adaptadores de integración del backend se sustentan en los componentes del Bounded Context Shared para gobernar el ciclo de vida de las solicitudes, persistir en PostgreSQL 16 y publicar eventos transaccionales confiables.

En la @tbl:shared-c4-components se presenta el catálogo estructurado de los siete componentes constitutivos del Bounded Context Shared dentro del contenedor central.

| Componente | Tipo C4 | Tecnología | Responsabilidad Arquitectónica | Relaciones y Dependencias |
| :--- | :---: | :--- | :--- | :--- |
| Perimeter Tracing & Exception Handling | Componente | Spring Web, OncePerRequestFilter, SLF4J MDC, RFC 7807 | Intercepta solicitudes HTTP inyectando `X-Correlation-Id`, enriquece el contexto diagnóstico MDC para logs distribuidos y captura fallas traduciéndolas a la norma RFC 7807. | Entrada perimetral desde WebApp y Mobile Workshop; envuelve controladores REST; propaga contexto a SLF4J MDC. |
| REST Assembler & DTO Resource | Componente | Spring MVC, Java 26 Records, Generics | Transforma deterministamente el tipo de resultado **Result<T, ApplicationError>** a `ResponseEntity<?>`, asigna códigos HTTP semánticos y formatea sobres paginados **PagedResultResource<T>**. | Invocado por controladores REST de los 8 módulos; consume **Result<T, E>** y **ApplicationError**. |
| CQRS Framework & Pagination | Componente | Java 26 Functional Interfaces, Sealed Interfaces, Railway-Oriented Programming | Suministra los contratos base para manejadores CQRS (**CommandHandler**, **QueryHandler**, **DomainEventHandler**) y los modelos de paginación (**PagedQuery**, **PagedResult<T>**). | Implementado por servicios de aplicación en todos los módulos; base de casos de uso. |
| Domain Foundation & Value Objects | Componente | Spring Data Commons, Java Records, Haversine Engine, SUNAT Módulo 11 | Provee la superclase base de agregados **AbstractDomainAggregateRoot<T>**, el contrato **DomainEvent**, identificadores UUID tipados, objetos de valor inmutables y **DomainException**. | Heredado por raíces de agregado de todos los módulos; núcleo del lenguaje ubicuo. |
| Persistence Superclass & Converters | Componente | Jakarta Persistence 3.1, Spring Data JPA Auditing, Hibernate 6.x | Provee la superclase **AuditableAbstractPersistenceEntity** con auditoría automática y UUID técnico, convertidores JPA para Value Objects y estrategia física de nombrado. | Heredado por entidades **PersistenceEntity**; interactúa con PostgreSQL 16. |
| Transactional Outbox Publisher | Componente | Spring Data JPA, Jackson JSONB, Spring ApplicationEventPublisher, PostgreSQL 16 | Implementa el puerto **DomainEventPublisher**, serializando eventos a JSON e insertándolos atómicamente en **outbox_messages** dentro de la transacción activa con publicación local. | Invocado por Command Handlers; persiste en base de datos; alimenta contexto Spring. |
| OpenAPI Specification | Componente | SpringDoc OpenAPI 2.8, Swagger UI, RFC 7519 (JWT Bearer) | Centraliza la definición de metadatos globales OpenAPI 3.0, servidores de ejecución y el esquema de seguridad **bearerAuth** con tokens JWT para la generación de contratos. | Descubre dinámicamente endpoints REST; consultado por desarrolladores y clientes. |
: Catálogo de Componentes de Arquitectura de Software del Bounded Context Shared {#tbl:shared-c4-components}

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

| Clase o Estructura | Elemento | Firma o Tipo | Ámbito | Descripción, Relaciones y Reglas de Negocio |
| :---: | :---: | :--- | :---: | :--- |
| AbstractDomainAggregateRoot<ID> | Atributo id | ID | Protegido | Identificador único genérico del agregado; hereda el parámetro de tipo ID. |
| AbstractDomainAggregateRoot<ID> | Atributo domainEvents | List<DomainEvent> | Privado | Acumulador interno en memoria para eventos de dominio generados. |
| AbstractDomainAggregateRoot<ID> | Constructor | `AbstractDomainAggregateRoot(id: ID)` | Protegido | Inicializa el agregado asignando el identificador y una lista vacía de eventos. |
| AbstractDomainAggregateRoot<ID> | Método id | ID | Público | Retorna el identificador fuertemente tipado de la raíz de agregado. |
| AbstractDomainAggregateRoot<ID> | Método domainEvents | List<DomainEvent> | Público | Retorna una vista inmutable de los eventos de dominio acumulados. |
| AbstractDomainAggregateRoot<ID> | Método registerDomainEvent | `void registerDomainEvent(DomainEvent event)` | Protegido | Registra un nuevo evento verificando no-nulidad. Composición 1 a 0..* con **DomainEvent**. |
| AbstractDomainAggregateRoot<ID> | Método clearDomainEvents | `void clearDomainEvents()` | Público | Purga la colección de eventos tras su almacenamiento atómico en el Transactional Outbox. |
| DomainEvent | Método eventId | UUID | Público | Identificador global único del evento para trazabilidad y deduplicación. |
| DomainEvent | Método occurredOn | Instant | Público | Marca temporal UTC en la que ocurrió el evento de dominio. |
| DomainEvent | Método eventType | String | Público | Clasificador semántico o nombre canónico calificado del evento. |
| TypedId<T> | Método value | T | Público | Contrato genérico de interfaz para obtener el valor primitivo subyacente. |
| TenantId | Atributo value | UUID | Privado | Registro inmutable; realiza `TypedId<UUID>`. Identificador universal del taller. |
| TenantId | Métodos estáticos | `TenantId of(UUID)`, `fromString(String)`, `generate()` | Público | Factorías estáticas de instanciación y generación criptográfica de identificador. |
| UserId | Atributo value | UUID | Privado | Registro inmutable; realiza `TypedId<UUID>`. Identificador de usuario del sistema. |
| UserId | Métodos estáticos | `UserId of(UUID)`, `fromString(String)`, `generate()` | Público | Factorías estáticas para vinculación de credenciales y miembros de taller. |
| WorkOrderId | Atributo value | UUID | Privado | Registro inmutable; realiza `TypedId<UUID>`. Identificador de orden de trabajo. |
| WorkOrderId | Métodos estáticos | `WorkOrderId of(UUID)`, `fromString(String)`, `generate()` | Público | Factorías estáticas para órdenes de servicio mecánico y mantenimiento. |
| VehicleId | Atributo value | UUID | Privado | Registro inmutable; realiza `TypedId<UUID>`. Identificador de unidad vehicular. |
| VehicleId | Métodos estáticos | `VehicleId of(UUID)`, `fromString(String)`, `generate()` | Público | Factorías estáticas para vehículos ingresados a custodia y diagnóstico. |
| CustomerId | Atributo value | UUID | Privado | Registro inmutable; realiza `TypedId<UUID>`. Identificador de cliente o propietario. |
| CustomerId | Métodos estáticos | `CustomerId of(UUID)`, `fromString(String)`, `generate()` | Público | Factorías estáticas para personas naturales y empresas propietarias de vehículos. |
| Currency | Constantes | PEN, USD | Público | Enumeración de divisas; Soles peruanos y Dólares estadounidenses. |
| Money | Atributo amount | BigDecimal | Privado | Cuantía monetaria normalizada a dos decimales con redondeo Half-Even. |
| Money | Atributo currency | Currency | Privado | Composición 1 a 1 con enumeración **Currency**. Divisa oficial del importe. |
| Money | Constructor compacto | `Money(BigDecimal amount, Currency currency)` | Público | Invariante: valida no-nulidad y redondea a escala 2. Lanza **BusinessRuleValidationException**. |
| Money | Factorías | `Money of(BigDecimal, Currency)`, `pen(...)`, `usd(...)` | Público | Métodos de construcción segura para monedas estándar. |
| Money | Métodos aritméticos | `Money add(Money)`, `subtract(Money)`, `multiply(...)` | Público | Opera importes inmutables. Lanza **CurrencyMismatchException** ante divisas heterogéneas. |
| Money | Métodos de estado | `boolean isPositive()`, `boolean isZero()` | Público | Predicados lógicos para validaciones de tarifas, saldos y presupuestos. |
| UnitOfMeasure | Constantes | UNIT, LITER, GALLON, KILOGRAM, METER | Público | Enumeración de unidades físicas de almacenamiento y consumo de repuestos. |
| Quantity | Atributo value | BigDecimal | Privado | Cuantía cuantitativa física con escala configurable a 4 decimales. |
| Quantity | Atributo uom | UnitOfMeasure | Privado | Composición 1 a 1 con **UnitOfMeasure**. Unidad física de magnitud. |
| Quantity | Métodos operativos | `Quantity of(...)`, `units(...)`, `add(...)`, `subtract(...)` | Público | Factorías y operaciones de suma/resta con validación de concordancia de unidad. |
| Mileage | Atributo kilometers | int | Privado | Registro inmutable. Odómetro expresado como valor escalar entero no negativo. |
| Mileage | Métodos | `Mileage of(int)`, `boolean isGreaterThan(...)`, `int distanceTo(...)` | Público | Invariante: rechaza valores negativos (*km* ≥ 0). Calcula distancias entre lecturas. |
| GeoPoint | Atributos | `double latitude`, `double longitude` | Privado | Registro inmutable de coordenadas satelitales bajo datum WGS84. |
| GeoPoint | Métodos | `GeoPoint of(...)`, `double distanceTo(GeoPoint)` | Público | Invariante: latitud en [-90.0, 90.0], longitud en [-180.0, 180.0]. Computa distancia ortodrómica vía Haversine. |
| TaxIdType | Constantes | DNI, RUC, CE, PASSPORT | Público | Enumeración legal de documentos de identidad tributaria ante la SUNAT. |
| TaxId | Atributos | `TaxIdType type`, `String value` | Privado | Composición 1 a 1 con **TaxIdType**. Número de documento tributario validado. |
| TaxId | Factorías y métodos | `TaxId dni(String)`, `ruc(String)`, `passport(String)` | Público | Invariante: verifica longitud (8 para DNI, 11 para RUC) y suma ponderada de Módulo 11. |
| EmailAddress | Atributo value | String | Privado | Registro inmutable. Dirección de correo electrónico validada. |
| EmailAddress | Métodos | `EmailAddress of(String)`, `String value()` | Público | Invariante: valida estructura conforme a la especificación sintáctica RFC 5322. |
| PhoneNumber | Atributo value | String | Privado | Registro inmutable. Número telefónico formateado en estándar internacional. |
| PhoneNumber | Métodos | `PhoneNumber of(String)`, `String value()` | Público | Invariante: valida prefijo internacional y longitud bajo norma ITU-T E.164. |
| DateRange | Atributos | `LocalDate startDate`, `LocalDate endDate` | Privado | Registro inmutable de intervalo temporal cerrado para turnos y contratos. |
| DateRange | Métodos | `DateRange of(...)`, `boolean contains(...)`, `overlaps(...)` | Público | Invariante: requiere *startDate* ≤ *endDate*. Evalúa contención y traslape. |
| DomainException | Atributo errorCode | String | Privado | Superclase abstracta de excepciones no comprobadas de dominio. |
| DomainException | Métodos | `DomainException(errorCode, msg)`, `String errorCode()` | Protegido / Público | Constructor protegido para subclases e inspector del código de error semántico. |
| BusinessRuleValidationException | Constructor | `BusinessRuleValidationException(errorCode, msg)` | Público | Generalización de **DomainException**. Lanza en violación de invariantes de dominio. |
| EntityNotFoundException | Constructor | `EntityNotFoundException(entityName, id)` | Público | Generalización de **DomainException**. Lanza ante entidades inexistentes. |
| CurrencyMismatchException | Constructor | `CurrencyMismatchException(sourceCur, targetCur)` | Público | Generalización de **DomainException**. Lanza ante incompatibilidad de divisas en **Money**. |
: Catálogo exhaustivo de clases, miembros, ámbitos y relaciones de la Capa de Dominio del Bounded Context Shared {#tbl:shared-domain-classes-members}

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

| Objeto de Base de Datos | Motor y Producto | Propósito Arquitectónico | Columnas Clave | Restricciones e Índices |
| :---: | :--- | :--- | :--- | :--- |
| outbox_messages | PostgreSQL 16 (API Application) | Cola transaccional de eventos de dominio para garantizar entrega confiable y consistencia eventual con brokers externos. | id (UUID), aggregate_type, aggregate_id, event_type, payload (JSONB), status, retry_count, occurred_on. | PK: pk_outbox_messages. CHECK: chk_outbox_status. Índice Parcial: idx_outbox_status_occurred_on (B-Tree). Índice: idx_outbox_aggregate. |
| pending_sync_events | SQLite 3 (Mobile Workshop) | Cola local persistente de mutaciones generadas por mecánicos durante trabajos en condiciones desconectadas (Outbox móvil). | id (TEXT), tenant_id, action_type, payload (TEXT/JSON), status, retry_count, created_at, synced_at. | PK: pk_pending_sync_events. CHECK: chk_sync_status. Índice: idx_sync_status_created para procesamiento FIFO. |
| local_cache_metadata | SQLite 3 (Mobile Workshop) | Control de marcas de agua e invalidación incremental de catálogos cacheados en el dispositivo. | entity_type (TEXT), last_sync_timestamp, record_count, schema_version. | PK: pk_local_cache_metadata. Soporta validación condicional de deltas mediante cabeceras HTTP ETag. |
: Objetos de persistencia física y estructuras relacionales del Bounded Context Shared {#tbl:shared-database-objects}

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




#### 2.6.2.1. Domain Layer

El núcleo de la capa de dominio de IAM & Tenancy encapsula las entidades fundamentales, objetos de valor y reglas de negocio sin depender de ningún framework tecnológico ni mecanismo de persistencia. En la @tbl:iam-domain-types se presenta el catálogo unificado de clases, agregados, objetos de valor, servicios de dominio, repositorios, eventos y excepciones que componen esta capa.

| Clase o Tipo | Categoría Táctica | Responsabilidad Principal en el Dominio |
| :--- | :--- | :--- |
| `Tenant` | Raíz de Agregado | Raíz de consistencia del taller; gestiona RUC, razón social, slug único, estado operativo y sedes físicas. |
| `Branch` | Entidad Dependiente | Sede física del taller; administra código de anexo SUNAT, capacidad instalada de bahías y geocerca GPS circular. |
| `User` | Raíz de Agregado | Identidad global de autenticación; gestiona credenciales seguras, tokens OTP, estado de verificación y perfil personal. |
| `TenantMembership` | Entidad Dependiente | Vinculación contractual entre un usuario y un taller específico; asocia rol de seguridad y esquema salarial pactado. |
| `Role` | Raíz de Agregado | Agrupador de privilegios de seguridad por taller o del sistema (`ROLE_OWNER`, `ROLE_ADMIN`, `ROLE_MECHANIC`, `ROLE_RECEPTIONIST`). |
| `Permission` | Entidad Dependiente | Privilegio atómico de autorización modelado como cadena de autoridad canónica (ej. `mro:order:create`). |
| `Invitation` | Raíz de Agregado | Ciclo de vida del proceso de incorporación y onboarding digital de colaboradores mediante correo transaccional (TTL 72h). |
| `VerificationToken` | Entidad Dependiente | Código OTP numérico de 6 dígitos para validación de email y restablecimiento de contraseñas con TTL de 15 minutos. |
| `TenantName` | Objeto de Valor | Nombre comercial del taller mecánico; valida longitud de 3 a 100 caracteres y elimina espacios superfluos. |
| `TenantSlug` | Objeto de Valor | Identificador legible URL-safe normalizado (`^[a-z0-9]+(?:-[a-z0-9]+)*$`) para subdominios y rutas web del taller. |
| `RucNumber` | Objeto de Valor | Registro Único de Contribuyentes peruano; valida 11 dígitos numéricos, prefijos válidos y algoritmo Módulo 11 de SUNAT. |
| `TenantStatus` | Enumeración de Dominio | Estados del ciclo de vida del taller (`PENDING`, `ACTIVE`, `SUSPENDED`). |
| `UserEmail` | Objeto de Valor | Correo electrónico canónico; valida estándar RFC 5322 y normaliza estrictamente a minúsculas. |
| `HashedPassword` | Objeto de Valor | Contenedor de contraseña cifrada; impone validación estricta de hash BCrypt y longitud exacta de 60 caracteres. |
| `PersonName` | Objeto de Valor | Nombres y apellidos de la persona; valida longitud mínima de 2 caracteres y normaliza capitalización. |
| `UserStatus` | Enumeración de Dominio | Estados de la cuenta de usuario (`PENDING_VERIFICATION`, `ACTIVE`, `SUSPENDED`). |
| `RoleId` | Objeto de Valor | Identificador universal único (`UUID`) fuertemente tipado para roles de seguridad. |
| `RoleName` | Objeto de Valor | Denominación estandarizada del rol; valida formato alfanumérico con prefijo formal `ROLE_`. |
| `PermissionName` | Objeto de Valor | Cadena atómica de autoridad bajo la convención formal `<bounded_context>:<resource>:<action>`. |
| `BranchId` | Objeto de Valor | Identificador universal único (`UUID`) fuertemente tipado para sedes físicas. |
| `InvitationToken` | Objeto de Valor | Token criptográfico seguro y aleatorio de alta entropía para el enlace de invitación de personal. |
| `OtpCode` | Objeto de Valor | Código numérico decimal de 6 dígitos (`^[0-9]{6}$`) para autenticación de dos factores o verificación rápida. |
| `PasswordPolicyEnforcer` | Servicio de Dominio | Servicio puro que valida la entropía y complejidad de contraseñas (mínimo 8 caracteres, mayúscula, minúscula, dígito y símbolo). |
| `TenantSlugGenerator` | Servicio de Dominio | Algoritmo puro de normalización léxica, eliminación de diacríticos y resolución de colisiones para generar slugs de talleres. |
| `TenantRepository` | Puerto de Salida | Contrato de persistencia de dominio para la Raíz de Agregado `Tenant`. |
| `UserRepository` | Puerto de Salida | Contrato de persistencia de dominio para la Raíz de Agregado `User`. |
| `RoleRepository` | Puerto de Salida | Contrato de persistencia de dominio para la Raíz de Agregado `Role`. |
| `InvitationRepository` | Puerto de Salida | Contrato de persistencia de dominio para la Raíz de Agregado `Invitation`. |
| `VerificationTokenRepository`| Puerto de Salida | Contrato de persistencia de dominio para tokens de verificación y OTPs. |
| `TenantRegisteredEvent` | Evento de Dominio | Notifica el registro inicial y exitoso de un nuevo taller mecánico en la plataforma. |
| `BranchCreatedEvent` | Evento de Dominio | Notifica la creación y delimitación perimetral de una nueva sede física operativa. |
| `UserCreatedEvent` | Evento de Dominio | Notifica el alta de una nueva identidad de usuario en el sistema. |
| `UserInvitedEvent` | Evento de Dominio | Notifica la emisión de una invitación de onboarding para un colaborador hacia su correo electrónico. |
| `UserVerifiedEvent` | Evento de Dominio | Notifica la verificación satisfactoria del correo electrónico y activación plena de la cuenta de usuario. |
| `TenantSuspendedEvent` | Evento de Dominio | Notifica la suspensión administrativa de un taller y la inhabilitación inmediata del acceso de su personal. |
: Catálogo de Tipos de Dominio del Bounded Context IAM & Tenancy {#tbl:iam-domain-types}

*Nota.* Componentes del modelo táctico de dominio para el Bounded Context de IAM & Tenancy implementados en Java 24 bajo el paquete canónico com.andeva.atelier.platform.iam.domain.

**Raíces de Agregado y Entidades Dependientes de IAM & Tenancy**

El diseño de las entidades de este contexto asegura que toda mutación de estado preserve las invariantes de gobernanza, seguridad y consistencia transaccional:

1. `Tenant`: Modela la empresa automotriz titular en la plataforma. Actúa como la frontera de consistencia transaccional y particionamiento lógico para el aislamiento multi-inquilino. Impone como invariante que toda empresa posea un `RucNumber` formalmente validado ante el algoritmo Módulo 11 de SUNAT, el cual resulta inmutable tras su confirmación tributaria. Asimismo, el `TenantSlug` debe ser único en toda la plataforma global, impidiendo colisiones de rutas web. Todo taller operativo debe contar con al menos una sede física activa que actúe como sede matriz (código de anexo "0000"). Las transiciones de estado siguen el flujo `PENDING` $\to$ `ACTIVE` $\to$ `SUSPENDED`.

| Elemento | Tipo o Firma | Ámbito | Descripción y Reglas de Negocio |
| :--- | :--- | :---: | :--- |
| `id` | `TenantId` | Privado | Identificador único universal del taller. |
| `name` | `TenantName` | Privado | Denominación comercial y de marca del taller automotriz. |
| `legalName` | `String` | Privado | Razón social oficial inscrita ante registros públicos y SUNAT. |
| `slug` | `TenantSlug` | Privado | Identificador amigable único para URLs y subdominios. |
| `ruc` | `RucNumber` | Privado | Registro Único de Contribuyentes validado. |
| `status` | `TenantStatus` | Privado | Estado operativo de la cuenta del taller en el SaaS. |
| `stripeCustomerId` | `String` | Privado | Identificador de cliente asignado en Stripe para cobros recurrentes. |
| `branches` | `List<Branch>` | Privado | Colección de sedes físicas administradas por el taller. |
| `register` | `static Tenant register(...)` | Público | Factoría que instancia el taller en estado `ACTIVE`, crea la sede matriz y registra `TenantRegisteredEvent`. |
| `addBranch` | `Branch addBranch(...)` | Público | Instancia e incorpora una nueva sede física, emitiendo `BranchCreatedEvent`. |
| `updateProfile` | `void updateProfile(...)` | Público | Modifica la razón social y nombre comercial bajo validación de estado activo. |
| `activate` | `void activate()` | Público | Transiciona el estado a `ACTIVE`, rehabilitando el acceso a sus usuarios. |
| `suspend` | `void suspend(String reason)` | Público | Transiciona el estado a `SUSPENDED` y registra `TenantSuspendedEvent`. |
: Miembros de la Raíz de Agregado Tenant {#tbl:iam-tenant-members}

*Nota.* Especificación de miembros y métodos del agregado Tenant del paquete com.andeva.atelier.platform.iam.domain.model.aggregates.

En cuanto a sus relaciones, `Tenant` hereda de `AbstractDomainAggregateRoot<Tenant>` y mantiene una relación de composición 1 a 1..* con sus entidades dependientes `Branch`. Si el `Tenant` es eliminado o purgado, sus sedes físicas se extinguen con él.

2. `Branch`: Representa un establecimiento o sucursal física perteneciente al taller automotriz. Su código de anexo tributario `branchCode` debe contener una cadena de 4 dígitos numéricos asignada por la administración tributaria. Su capacidad instalada `capacity` representa el número simultáneo de bahías de trabajo activas y debe ser un entero estrictamente positivo ($\ge 1$). Asimismo, delimita una geocerca circular con un radio radial en metros ($geofenceRadiusMeters \ge 10$), utilizado para validar la proximidad del personal operativo en el control de asistencia.

| Elemento | Tipo o Firma | Ámbito | Descripción y Reglas de Negocio |
| :--- | :--- | :---: | :--- |
| `id` | `BranchId` | Privado | Identificador universal único de la sede física. |
| `tenantId` | `TenantId` | Privado | Identificador del taller propietario. |
| `name` | `String` | Privado | Denominación operativa de la sede física (entre 3 y 100 caracteres). |
| `branchCode` | `String` | Privado | Código tributario de anexo SUNAT (`^[0-9]{4}$`). |
| `address` | `Address` | Privado | Dirección física postal estructurada. |
| `location` | `GeoPoint` | Privado | Centroide geográfico WGS84 de la sede. |
| `geofenceRadiusMeters` | `int` | Privado | Radio radial en metros ($[10, 500]$) para control presencial. |
| `capacity` | `int` | Privado | Cantidad simultánea de bahías vehiculares disponibles ($\ge 1$). |
| `isActive` | `boolean` | Privado | Indicador de operatividad activa de la sede. |
| `isWithinGeofence` | `boolean isWithinGeofence(GeoPoint coord)` | Público | Verifica si una coordenada GPS se ubica dentro del perímetro radial de la sede. |
| `updateCapacity` | `void updateCapacity(int capacity)` | Público | Modifica la capacidad instalada de bahías del local. |
| `deactivate` | `void deactivate()` | Público | Inhabilita operativamente la sucursal. |
: Miembros de la Entidad Dependiente Branch {#tbl:iam-branch-members}

*Nota.* Especificación de miembros de la entidad Branch del paquete com.andeva.atelier.platform.iam.domain.model.entities.

Respecto a sus relaciones, `Branch` es una entidad subordinada a la raíz `Tenant` (N a 1) y compone los objetos de valor `BranchId`, `TenantId`, `Address` y `GeoPoint`.

3. `User`: Modela la identidad global de un individuo dentro de Atelier (dueño, administrador, recepcionista o técnico mecánico). El correo electrónico `email` es estrictamente único en la plataforma global, fungiendo como credencial principal. Cuando la autenticación es local (`authProvider == LOCAL`), la contraseña cifrada `password` es mandatoria y debe contener un hash BCrypt válido. Las cuentas locales inician en estado `PENDING_VERIFICATION` y solo transicionan a `ACTIVE` tras la validación de un código OTP de 6 dígitos.

| Elemento | Tipo o Firma | Ámbito | Descripción y Reglas de Negocio |
| :--- | :--- | :---: | :--- |
| `id` | `UserId` | Privado | Identificador universal único de la cuenta de usuario. |
| `email` | `UserEmail` | Privado | Dirección de correo electrónico canónica normalizada. |
| `password` | `HashedPassword` | Privado | Hash BCrypt de la contraseña para cuentas de autenticación local. |
| `name` | `PersonName` | Privado | Nombres y apellidos completos del usuario. |
| `authProvider` | `AuthProvider` | Privado | Proveedor de identidad (`LOCAL`, `GOOGLE`). |
| `status` | `UserStatus` | Privado | Estado de la cuenta (`PENDING_VERIFICATION`, `ACTIVE`, `SUSPENDED`). |
| `memberships` | `List<TenantMembership>` | Privado | Colección de relaciones laborales y de membresía con talleres. |
| `registerLocal` | `static User registerLocal(...)` | Público | Factoría para cuentas locales en estado pendiente que registra `UserCreatedEvent`. |
| `verifyEmail` | `void verifyEmail()` | Público | Valida la cuenta y transiciona a estado `ACTIVE`, emitiendo `UserVerifiedEvent`. |
| `issueVerificationToken` | `VerificationToken issueVerificationToken(...)` | Público | Genera un código OTP de 6 dígitos con vigencia de 15 minutos. |
| `validateAndConsumeToken` | `boolean validateAndConsumeToken(...)` | Público | Comprueba la vigencia del OTP y lo marca como consumido. |
| `addMembership` | `void addMembership(TenantMembership mem)` | Público | Incorpora una nueva vinculación laboral a un taller específico. |
: Miembros de la Raíz de Agregado User {#tbl:iam-user-members}

*Nota.* Especificación de miembros del agregado User del paquete com.andeva.atelier.platform.iam.domain.model.aggregates.

En sus relaciones, `User` hereda de `AbstractDomainAggregateRoot<User>` y mantiene composición 1 a N con las entidades `TenantMembership` y `VerificationToken`.

4. `TenantMembership`: Modela la vinculación contractual y laboral entre un usuario y un taller específico. Impone la invariante de que la tupla `(tenantId, userId)` es unívoca en el sistema: un usuario no puede registrar membresías duplicadas en el mismo taller. Cada membresía exige la asignación de un `Role` válido y registra el esquema de compensación económica (`FIXED` para salario mensual o quincenal, `HOURLY` para retribución por hora efectiva de trabajo mecánico), cuyo monto base debe ser mayor o igual a cero ($baseSalary \ge 0.00$).

| Elemento | Tipo o Firma | Ámbito | Descripción y Reglas de Negocio |
| :--- | :--- | :---: | :--- |
| `id` | `TenantMembershipId` | Privado | Identificador universal de la membresía laboral. |
| `tenantId` | `TenantId` | Privado | Taller empleador al que se adscribe el trabajador. |
| `userId` | `UserId` | Privado | Usuario adscrito a la relación contractual. |
| `role` | `Role` | Privado | Rol de seguridad y privilegios operativos concedidos. |
| `status` | `MembershipStatus` | Privado | Estado de la relación laboral (`ACTIVE`, `INACTIVE`). |
| `salaryType` | `SalaryType` | Privado | Modalidad de compensación (`FIXED`, `HOURLY`). |
| `baseSalary` | `Money` | Privado | Salario base pactado en moneda local ($\ge 0.00$). |
| `joinedAt` | `Instant` | Privado | Fecha y hora de incorporación formal al taller. |
| `changeRole` | `void changeRole(Role newRole)` | Público | Actualiza el rol asignado al colaborador. |
| `updateSalary` | `void updateSalary(Money salary)` | Público | Modifica la remuneración base pactada. |
: Miembros de la Entidad Dependiente TenantMembership {#tbl:iam-membership-members}

*Nota.* Especificación de miembros de TenantMembership del paquete com.andeva.atelier.platform.iam.domain.model.entities.

5. `Role`, `Permission`, `Invitation` y `VerificationToken`: Completan la seguridad del contexto. `Role` agrupa un conjunto de entidades `Permission` que representan cadenas atómicas de autorización formateadas según la convención `<contexto>:<recurso>:<accion>`. Por su parte, `Invitation` gestiona el flujo de onboarding mediante tokens criptográficos aleatorios con una vigencia temporal estricta de 72 horas, emitiendo el evento `UserInvitedEvent`. Finalmente, `VerificationToken` modela códigos OTP numéricos de 6 dígitos empleados en la activación de cuentas y restablecimiento seguro de credenciales con una caducidad de 15 minutos.

**Objetos de Valor del Bounded Context IAM & Tenancy**

Los objetos de valor de IAM encapsulan las reglas sintácticas y de integridad de datos para credenciales, documentos tributarios e identificadores:

| Objeto de Valor | Atributos Clave | Restricciones de Validación y Reglas de Negocio |
| :--- | :--- | :--- |
| `TenantName` | `value`: `String` | Longitud entre 3 y 100 caracteres, normalizado sin espacios múltiples. |
| `TenantSlug` | `value`: `String` | Formato alfanumérico URL-safe en minúsculas (`^[a-z0-9]+(?:-[a-z0-9]+)*$`). |
| `RucNumber` | `value`: `String` | 11 dígitos numéricos con prefijo 10 o 20, validado con algoritmo Módulo 11 de SUNAT. |
| `UserEmail` | `value`: `String` | Sintaxis RFC 5322, conversión obligatoria a minúsculas. |
| `HashedPassword` | `value`: `String` | Longitud exacta de 60 caracteres, prefijo de algoritmo BCrypt (`$2a$`, `$2b$`, `$2y$`). |
| `PersonName` | `firstName`, `lastName`: `String` | Longitud mínima de 2 caracteres por componente, normalización léxica. |
| `OtpCode` | `value`: `String` | Exactamente 6 dígitos numéricos decimales (`^[0-9]{6}$`). |
| `InvitationToken` | `value`: `String` | Cadena hexadecimal de alta entropía generada criptográficamente. |
| `RoleName` | `value`: `String` | Denominación en mayúsculas con prefijo mandatorio `ROLE_`. |
| `PermissionName` | `value`: `String` | Convención formal de autoridad atómica `<bounded_context>:<resource>:<action>`. |
: Objetos de Valor del Bounded Context IAM & Tenancy {#tbl:iam-value-objects}

*Nota.* Especificación de Objetos de Valor del paquete com.andeva.atelier.platform.iam.domain.model.valueobjects.

**Servicios de Dominio de IAM & Tenancy**

Los servicios de dominio encapsulan lógica de negocio pura y algoritmos que operan de forma transversal a múltiples entidades:

1. `PasswordPolicyEnforcer`: Evalúa la solidez y entropía de las contraseñas provistas por los usuarios durante el registro o actualización de credenciales. La regla exige una longitud mínima de 8 caracteres, la presencia de al menos una letra mayúscula, una letra minúscula, un dígito numérico y un carácter especial o símbolo. Si la contraseña no satisface estos requisitos, el servicio rechaza la operación retornando un error descriptivo tipado sin recurrir a excepciones de infraestructura.
2. `TenantSlugGenerator`: Servicio algorítmico encargado de generar identificadores de URL legibles a partir del nombre comercial o razón social del taller automotriz. El proceso realiza la eliminación de diacríticos y tildes mediante normalización Unicode NFD, convierte los caracteres a minúsculas, sustituye espacios y signos de puntuación por guiones simples, y resuelve colisiones consultando al repositorio de talleres para anexar sufijos numéricos incrementales cuando el slug base ya se encuentra ocupado.

**Puertos de Repositorio de la Capa de Dominio**

Las interfaces de repositorio definen los contratos puros de persistencia y recuperación requeridos por los agregados de IAM, utilizando únicamente tipos de dominio y abstrayéndose de cualquier tecnología de base de datos relacional:

| Puerto de Repositorio | Métodos Principales | Responsabilidad de Dominio |
| :--- | :--- | :--- |
| `TenantRepository` | `save`, `findById`, `findByRuc`, `findBySlug`, `existsBySlug` | Persistencia y recuperación de la raíz de agregado `Tenant`. |
| `UserRepository` | `save`, `findById`, `findByEmail`, `existsByEmail` | Persistencia y recuperación de identidades de usuario. |
| `RoleRepository` | `save`, `findById`, `findByNameAndTenantId`, `findSystemRoles` | Gestión de roles de seguridad personalizados y predefinidos. |
| `InvitationRepository` | `save`, `findById`, `findByToken`, `findByEmailAndTenantId` | Control de invitaciones de incorporación de personal. |
| `VerificationTokenRepository`| `save`, `findByTokenAndType`, `deleteExpired` | Almacenamiento y validación de tokens OTP temporales. |
: Puertos de Repositorio del Bounded Context IAM & Tenancy {#tbl:iam-repository-ports}

*Nota.* Interfaces de salida del paquete com.andeva.atelier.platform.iam.domain.repositories.

**Eventos de Dominio y Manejo de Errores Semánticos**

Las mutaciones válidas de estado en IAM registran eventos de dominio inmutables que notifican cambios relevantes para la sincronización intermodular:
* `TenantRegisteredEvent`: Transporta `tenantId`, `ruc`, `slug` y marca de tiempo tras el alta exitosa de un taller.
* `BranchCreatedEvent`: Notifica la creación de una nueva sede física con sus coordenadas y radio perimetral.
* `UserCreatedEvent`: Notifica el registro de un nuevo usuario en la plataforma.
* `UserInvitedEvent`: Transporta el token de invitación y el correo destinatario para su envío asíncrono vía Resend.
* `UserVerifiedEvent`: Notifica la confirmación de identidad y habilitación plena de acceso.
* `TenantSuspendedEvent`: Notifica la suspensión del taller para la revocación inmediata de sesiones activas.

Para el manejo de errores, el contexto adopta el tipo de resultado `Result<T, ApplicationError>`, complementado por excepciones semánticas de dominio (`TenantNotFoundException`, `InvalidCredentialsException`, `UserAlreadyExistsException`, `TenantSuspendedException`) reservadas para infracciones críticas de invariantes.

#### 2.6.2.2. Interface Layer



#### 2.6.2.3. Application Layer



#### 2.6.2.4 Infrastructure Layer



#### 2.6.2.5. Bounded Context Software Architecture Component Level Diagrams



#### 2.6.2.6. Bounded Context Software Architecture Code Level Diagrams



##### 2.6.2.6.1. *Bounded Context Domain Layer Class Diagrams*



##### 2.6.2.6.2. *Bounded Context Database Design Diagram*



### 2.6.3. *Bounded Context: Customer and Fleet Management (CRM)*

El Bounded Context de Customer and Fleet Management (CRM) gestiona la dimensión comercial y relacional del ecosistema Atelier. Su alcance de dominio abarca el ciclo de vida de los clientes del taller, el empadronamiento y seguimiento técnico de sus vehículos, y la programación anticipada de citas para intervenciones automotrices.

Dentro del sector automotriz, los talleres atienden a dos perfiles de clientes con dinámicas comerciales y requerimientos de soporte diferenciados:
1. **Clientes Particulares:** Propietarios individuales de vehículos de uso personal que buscan atención ágil, presupuestos transparentes y comunicación directa sobre el avance de sus reparaciones.
2. **Flotas Corporativas (B2B):** Empresas de transporte, distribución, logística o servicios que poseen decenas o cientos de vehículos utilitarios. Para estos clientes corporativos, el sistema requiere registrar la razón social, número de RUC de la empresa y gestionar de forma centralizada una flota vehicular heterogénea asignada a conductores designados, habilitando tarifas preferenciales y facturación agrupada.

El contexto resuelve este requerimiento mediante la raíz de agregado `Customer`, la cual soporta ambos tipos de clientes y encapsula la colección de entidades dependientes `Vehicle`. Cada vehículo mantiene su Número de Identificación Vehicular (`VinNumber`), placa de rodaje (`PlateNumber`), características electromecánicas y odómetro actual (`Mileage`). El sistema impone como regla de negocio inviolable la monotonicidad creciente del odómetro: ninguna actualización manual o telemétrica puede reportar un kilometraje inferior al último valor certificado por el taller, evitando fraudes comerciales en la reventa vehicular.

Adicionalmente, el contexto modela la raíz de agregado `Appointment` para coordinar el ingreso ordenado de vehículos a las sedes físicas del taller. La gestión de citas actúa como la antesala al proceso operativo de MRO, asegurando que la demanda de servicios no exceda la capacidad física instalada de bahías ni la disponibilidad del personal técnico en cada sucursal.

#### 2.6.3.1. Domain Layer

La capa de dominio de Customer and Fleet Management encapsula las reglas de consistencia de clientes, automóviles y reservas previas. En la @tbl:crm-domain-types se presenta el catálogo de los componentes que conforman esta capa.

| Clase o Tipo | Categoría Táctica | Responsabilidad Principal en el Dominio |
| :--- | :--- | :--- |
| `Customer` | Raíz de Agregado | Gestiona el perfil del cliente (particular o corporativo), documentos de identidad y flota vehicular asociada. |
| `Vehicle` | Entidad Dependiente | Ficha técnica vehicular asociada a un cliente; valida VIN, placa y garantiza la monotonicidad del odómetro. |
| `Appointment` | Raíz de Agregado | Reserva de atención previa en una sucursal física; gestiona fechas, horarios, estado de confirmación y cancelación. |
| `CustomerId` | Objeto de Valor | Identificador único universal (`UUID`) fuertemente tipado para clientes. |
| `VehicleId` | Objeto de Valor | Identificador único universal (`UUID`) fuertemente tipado para vehículos. |
| `AppointmentId` | Objeto de Valor | Identificador único universal (`UUID`) fuertemente tipado para citas programadas. |
| `CustomerType` | Enumeración de Dominio | Clasificación comercial del cliente (`INDIVIDUAL` o `FLEET`). |
| `DocumentNumber` | Objeto de Valor | Documento oficial de identidad peruano; valida 8 dígitos para DNI, 11 para RUC o alfanumérico para Carné de Extranjería. |
| `CustomerName` | Objeto de Valor | Nombre completo de persona natural o denominación social corporativa de la empresa de flota. |
| `ContactInfo` | Objeto de Valor | Información de contacto canónica agrupando correo electrónico y teléfono internacional validado. |
| `VehicleBrand` | Objeto de Valor | Marca automotriz validada contra catálogo oficial (ej. Toyota, Nissan, Hyundai). |
| `VehicleModel` | Objeto de Valor | Modelo vehicular comercial (ej. Hilux, Sentra, Tucson). |
| `VehicleYear` | Objeto de Valor | Año de fabricación del modelo dentro de un intervalo histórico admisible ($1950 \le \text{año} \le \text{añoActual} + 1$). |
| `AppointmentDateTime` | Objeto de Valor | Marca temporal de inicio y fin de la cita, garantizando una duración mínima de 30 minutos. |
| `AppointmentStatus` | Enumeración de Dominio | Estados del ciclo de vida de la cita (`SCHEDULED`, `CONFIRMED`, `IN_PROGRESS`, `COMPLETED`, `CANCELLED`). |
| `CancellationReason` | Objeto de Valor | Justificación textual obligatoria al anular una cita previamente agendada. |
| `AppointmentSchedulingValidator`| Servicio de Dominio | Servicio puro que verifica que la cita respete el horario del taller, anticipación mínima y capacidad de bahías. |
| `MileageMonotonicityValidator` | Servicio de Dominio | Regla algorítmica que comprueba que un nuevo kilometraje reportado no sea inferior al histórico certificado. |
| `CustomerRepository` | Puerto de Salida | Contrato de persistencia de dominio para la Raíz de Agregado `Customer`. |
| `VehicleRepository` | Puerto de Salida | Contrato de persistencia de dominio para la entidad `Vehicle`. |
| `AppointmentRepository` | Puerto de Salida | Contrato de persistencia de dominio para la Raíz de Agregado `Appointment`. |
| `CustomerRegisteredEvent` | Evento de Dominio | Notifica el alta de un nuevo cliente particular o corporativo en el taller. |
| `VehicleRegisteredEvent` | Evento de Dominio | Notifica la incorporación de un nuevo vehículo al padrón del taller. |
| `MileageUpdatedEvent` | Evento de Dominio | Notifica la actualización certificada del odómetro vehicular. |
| `AppointmentScheduledEvent` | Evento de Dominio | Notifica la reserva de una nueva cita de servicio en el taller. |
| `AppointmentConfirmedEvent` | Evento de Dominio | Notifica la confirmación de la cita tras la revisión de disponibilidad técnica. |
| `AppointmentCancelledEvent` | Evento de Dominio | Notifica la anulación de la cita liberando el cupo en la sucursal. |
: Catálogo de Tipos de Dominio del Bounded Context CRM {#tbl:crm-domain-types}

*Nota.* Componentes tácticos de dominio para el Bounded Context de Customer and Fleet Management implementados en Java 24 bajo el paquete canónico com.andeva.atelier.platform.crm.domain.

**Raíces de Agregado y Entidades Dependientes de CRM**

1. `Customer`: Modela el cliente del taller automotriz bajo un esquema polimórfico flexible. Impone que todo cliente particular cuente con un `DocumentNumber` de tipo DNI o Carné de Extranjería, mientras que los clientes corporativos exigen obligatoriamente un RUC de 11 dígitos. El agregado encapsula la lista de vehículos vinculados, garantizando que un cliente no registre vehículos con placas de rodaje idénticas y proveyendo métodos para actualizar datos de contacto y auditar el historial de atención.

| Elemento | Tipo o Firma | Ámbito | Descripción y Reglas de Negocio |
| :--- | :--- | :---: | :--- |
| `id` | `CustomerId` | Privado | Identificador único universal del cliente. |
| `tenantId` | `TenantId` | Privado | Identificador del taller al que pertenece el cliente. |
| `type` | `CustomerType` | Privado | Clasificación del cliente (`INDIVIDUAL`, `FLEET`). |
| `documentNumber` | `DocumentNumber` | Privado | Documento oficial de identidad validado. |
| `name` | `CustomerName` | Privado | Nombre completo de persona o razón social empresarial. |
| `contact` | `ContactInfo` | Privado | Correo electrónico y teléfono de contacto principal. |
| `vehicles` | `List<Vehicle>` | Privado | Colección de vehículos asociados al cliente. |
| `registerIndividual` | `static Customer registerIndividual(...)` | Público | Factoría para personas naturales que emite `CustomerRegisteredEvent`. |
| `registerFleet` | `static Customer registerFleet(...)` | Público | Factoría para empresas de flota corporativa con RUC validado. |
| `addVehicle` | `Vehicle addVehicle(...)` | Público | Incorpora un nuevo vehículo a la flota del cliente y emite `VehicleRegisteredEvent`. |
| `findVehicleByPlate` | `Optional<Vehicle> findVehicleByPlate(PlateNumber plate)` | Público | Localiza un vehículo dentro de la flota del cliente por su matrícula. |
| `updateContactInfo` | `void updateContactInfo(ContactInfo newContact)` | Público | Modifica los datos de contacto corporativos o personales. |
: Miembros de la Raíz de Agregado Customer {#tbl:crm-customer-members}

*Nota.* Especificación de miembros del agregado Customer del paquete com.andeva.atelier.platform.crm.domain.model.aggregates.

En cuanto a sus relaciones, `Customer` hereda de `AbstractDomainAggregateRoot<Customer>` y mantiene una relación de composición 1 a N con la entidad dependiente `Vehicle`.

2. `Vehicle`: Entidad dependiente que modela la ficha técnica del automóvil o unidad de transporte. Cada vehículo posee un identificador de chasis estandarizado `VinNumber` y una matrícula vehicular `PlateNumber`. El atributo `mileage` encapsula el odómetro actual, el cual solo puede incrementarse mediante el método de negocio `updateMileage`, disparando una verificación de monotonicidad que rechaza valores inferiores al odómetro histórico certificado.

| Elemento | Tipo o Firma | Ámbito | Descripción y Reglas de Negocio |
| :--- | :--- | :---: | :--- |
| `id` | `VehicleId` | Privado | Identificador único universal del vehículo. |
| `customerId` | `CustomerId` | Privado | Identificador del cliente propietario de la unidad. |
| `vin` | `VinNumber` | Privado | Número de identificación vehicular de 17 caracteres ISO 3779. |
| `plate` | `PlateNumber` | Privado | Placa de rodaje vehicular normalizada. |
| `brand` | `VehicleBrand` | Privado | Marca comercial del fabricante automotriz. |
| `model` | `VehicleModel` | Privado | Denominación del modelo vehicular. |
| `year` | `VehicleYear` | Privado | Año de fabricación del vehículo. |
| `mileage` | `Mileage` | Privado | Kilometraje actual certificado de la unidad. |
| `color` | `String` | Privado | Color predominante de la carrocería del vehículo. |
| `updateMileage` | `void updateMileage(Mileage newMileage)` | Público | Actualiza el odómetro exigiendo monotonicidad y emite `MileageUpdatedEvent`. |
| `updateDetails` | `void updateDetails(String newColor)` | Público | Modifica atributos descriptivos secundarios del vehículo. |
: Miembros de la Entidad Dependiente Vehicle {#tbl:crm-vehicle-members}

*Nota.* Especificación de miembros de la entidad Vehicle del paquete com.andeva.atelier.platform.crm.domain.model.entities.

3. `Appointment`: Raíz de agregado independiente que modela la solicitud y reserva temporal de un cupo de servicio en una sucursal del taller. Gobierna una máquina de estados estricta: transiciona de `SCHEDULED` (agendada por el cliente) a `CONFIRMED` (aprobada por el taller), `IN_PROGRESS` (vehículo ingresado a patio para inspección) y finalmente `COMPLETED` (orden de trabajo generada) o `CANCELLED` (anulada con motivo formal).

| Elemento | Tipo o Firma | Ámbito | Descripción y Reglas de Negocio |
| :--- | :--- | :---: | :--- |
| `id` | `AppointmentId` | Privado | Identificador único universal de la cita. |
| `tenantId` | `TenantId` | Privado | Taller en el que se llevará a cabo la atención. |
| `branchId` | `BranchId` | Privado | Sucursal física seleccionada para el servicio. |
| `customerId` | `CustomerId` | Privado | Cliente que solicita la cita. |
| `vehicleId` | `VehicleId` | Privado | Vehículo que será objeto de revisión o mantenimiento. |
| `timeWindow` | `AppointmentDateTime` | Privado | Intervalo temporal acordado para la recepción. |
| `status` | `AppointmentStatus` | Privado | Estado actual de la cita en el taller. |
| `serviceReason` | `String` | Privado | Motivo descriptivo del ingreso reportado por el cliente. |
| `cancellationReason` | `CancellationReason` | Privado | Motivo de anulación en caso de estado `CANCELLED`. |
| `schedule` | `static Appointment schedule(...)` | Público | Factoría constructora que inicializa la cita en estado `SCHEDULED` y emite evento. |
| `confirm` | `void confirm()` | Público | Transiciona el estado a `CONFIRMED` y emite `AppointmentConfirmedEvent`. |
| `startProgress` | `void startProgress()` | Público | Marca el inicio de la atención tras el arribo físico del vehículo al taller. |
| `complete` | `void complete()` | Público | Finaliza la cita al aperturarse la orden de trabajo respectiva. |
| `cancel` | `void cancel(CancellationReason reason)` | Público | Anula la cita registrando el motivo y emite `AppointmentCancelledEvent`. |
: Miembros de la Raíz de Agregado Appointment {#tbl:crm-appointment-members}

*Nota.* Especificación de miembros del agregado Appointment del paquete com.andeva.atelier.platform.crm.domain.model.aggregates.

En cuanto a sus relaciones, `Appointment` hereda de `AbstractDomainAggregateRoot<Appointment>` y mantiene referencias por identificador (`CustomerId`, `VehicleId`, `BranchId`, `TenantId`) con los demás agregados del sistema, evitando acoplamientos directos en memoria.

**Objetos de Valor del Bounded Context CRM**

| Objeto de Valor | Atributos Clave | Restricciones de Validación y Reglas de Negocio |
| :--- | :--- | :--- |
| `DocumentNumber` | `value`: `String`, `type`: `DocumentType` | DNI (8 dígitos), RUC (11 dígitos con validación SUNAT), CE (9 a 12 caracteres). |
| `CustomerName` | `fullName`: `String` | Longitud entre 2 y 150 caracteres, capitalización normalizada. |
| `ContactInfo` | `email`: `EmailAddress`, `phone`: `PhoneNumber` | Objetos de valor delegados que validan RFC 5322 y UIT-T E.164. |
| `VehicleBrand` | `name`: `String` | Denominación no vacía de longitud de 2 a 50 caracteres. |
| `VehicleModel` | `name`: `String` | Denominación no vacía de longitud de 1 a 50 caracteres. |
| `VehicleYear` | `year`: `int` | Intervalo cerrado $[1950, \text{añoActual} + 1]$. |
| `AppointmentDateTime` | `start`: `LocalDateTime`, `end`: `LocalDateTime` | Invariante temporal: `start < end` con duración mínima de 30 minutos. |
| `CancellationReason` | `reason`: `String` | Justificación obligatoria no vacía de al menos 10 caracteres. |
: Objetos de Valor del Bounded Context CRM {#tbl:crm-value-objects}

*Nota.* Especificación de Objetos de Valor del paquete com.andeva.atelier.platform.crm.domain.model.valueobjects.

**Servicios de Dominio de CRM**

1. `AppointmentSchedulingValidator`: Evalúa la viabilidad operativa de agendar una nueva cita en una sucursal determinada. El servicio valida que la marca temporal de inicio se encuentre dentro del horario de atención del taller, que se cumpla un tiempo de anticipación mínima de al menos 2 horas, y consulta la disponibilidad del repositorio de citas para asegurar que la cantidad de citas simultáneas no sobrepase la capacidad instalada de bahías operativas de la sede.
2. `MileageMonotonicityValidator`: Valida algorítmicamente que cualquier nuevo odómetro reportado para un vehículo sea estrictamente mayor o igual al último kilometraje histórico registrado en base de datos. Ante una discrepancia que implique una reducción de odómetro, el servicio rechaza la actualización protegiendo la integridad probatoria de la ficha vehicular.

**Puertos de Repositorio de la Capa de Dominio**

| Puerto de Repositorio | Métodos Principales | Responsabilidad de Dominio |
| :--- | :--- | :--- |
| `CustomerRepository` | `save`, `findById`, `findByDocumentNumber`, `findByTenantId` | Persistencia y consulta de la raíz de agregado `Customer`. |
| `VehicleRepository` | `save`, `findById`, `findByPlate`, `findByVin`, `findByCustomerId` | Persistencia y recuperación de la entidad `Vehicle`. |
| `AppointmentRepository` | `save`, `findById`, `findByBranchIdAndDateRange`, `countActiveByBranch` | Control de citas y disponibilidad de cupos en sucursal. |
: Puertos de Repositorio del Bounded Context CRM {#tbl:crm-repository-ports}

*Nota.* Interfaces de salida del paquete com.andeva.atelier.platform.crm.domain.repositories.

**Eventos de Dominio y Manejo de Errores Semánticos**

Los eventos de dominio de CRM coordinan la sincronización con los módulos operativos:
* `CustomerRegisteredEvent`: Transporta el identificador del nuevo cliente para su indexación en el directorio de facturación.
* `VehicleRegisteredEvent`: Notifica la incorporación del vehículo para habilitar la vinculación de dispositivos OBD-II en el módulo de IoT.
* `MileageUpdatedEvent`: Dispara la evaluación de anomalías o umbrales de mantenimiento en el módulo predictivo.
* `AppointmentScheduledEvent` y `AppointmentConfirmedEvent`: Habilitan la reserva previa de materiales y herramientas en taller.
* `AppointmentCancelledEvent`: Notifica la liberación de cupos para reasignación en el calendario de recepción.

Las infracciones de reglas se gestionan mediante `Result<T, ApplicationError>` y excepciones tipadas (`CustomerNotFoundException`, `VehicleAlreadyExistsException`, `InvalidAppointmentScheduleException`).



#### 2.6.3.2. Interface Layer



#### 2.6.3.3. Application Layer



#### 2.6.3.4 Infrastructure Layer



#### 2.6.3.5. Bounded Context Software Architecture Component Level Diagrams



#### 2.6.3.6. Bounded Context Software Architecture Code Level Diagrams



##### 2.6.3.6.1. *Bounded Context Domain Layer Class Diagrams*



##### 2.6.3.6.2. *Bounded Context Database Design Diagram*
