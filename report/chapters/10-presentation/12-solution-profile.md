## 1.2. Solution Profile

### 1.2.1. *Antecedentes y Problemática*

Para poder establecer de manera precisa la problemática que nuestro ecosistema de software busca resolver, hemos aplicado la técnica de análisis de problemas **5W's y 2H's**. Esta metodología nos permite focalizarnos en las causas y en el problema real:

**What (¿QUÉ?)**
El problema radica en la gestión reactiva y carente de tecnología en los talleres mecánicos tradicionales, lo que ocasiona costosas reparaciones correctivas por averías graves y una deficiente administración interna que imposibilita la fidelización del cliente.

**When (¿CUÁNDO?)**
Este problema se manifiesta de forma crítica en dos momentos clave. Por parte del cliente final, se evidencia en el momento exacto en que el vehículo sufre una falla mecánica inesperada o una avería grave durante su trayecto y uso diario, interrumpiendo abruptamente su rutina. Por parte del negocio, el problema está presente constantemente durante la operativa diaria del taller, especialmente al intentar gestionar los cuellos de botella generados por ingresos imprevistos de vehículos, la falta de repuestos adecuados debido a un mal manejo de inventario y la ausencia de un flujo automatizado para coordinar las reparaciones y las citas de manera eficiente.

**Where (¿DÓNDE?)**
La problemática tiene un impacto dual que afecta a dos entornos distintos pero interconectados. Físicamente, el problema se materializa en las vías públicas, carreteras o zonas de tránsito cotidiano donde los conductores particulares o las flotas comerciales experimentan las averías vehiculares. A nivel administrativo y estructural, el problema reside en el entorno operativo interno de los propios talleres mecánicos, afectando directamente sus áreas de recepción de vehículos, sus zonas de trabajo y sus almacenes.

**Who (¿QUIÉN?)**
La problemática impacta directamente a dos segmentos principales de la industria. En primer lugar, afecta a los dueños, administradores y empleados de los talleres mecánicos, cuyas habilidades técnicas y operativas se ven limitadas por la falta de herramientas digitales, lo que resulta en un descontrol de los procesos, pérdida de ventas cruzadas y fuga de clientes. En segundo lugar, afecta de manera severa a los usuarios finales, conformados tanto por conductores particulares como por gestores de flotas empresariales, quienes carecen de visibilidad sobre el estado de salud real de sus vehículos y terminan siendo las principales víctimas de los altos costos y la pérdida de tiempo.

**Why (¿POR QUÉ?)**
El origen estructural del problema se debe a la total desconexión tecnológica y de comunicación entre el estado de salud interno del vehículo y la capacidad de monitoreo del taller. Al no contar con sistemas de telemetría IoT integrados a un ecosistema unificado en la nube, los talleres operan "a ciegas". Esta ausencia de datos en tiempo real y alertas de códigos de falla hace que sea técnicamente imposible aplicar un modelo de mantenimiento predictivo, forzando a todo el ecosistema automotriz a reaccionar únicamente cuando el componente físico ya ha fallado por completo de manera catastrófica.

**How (¿CÓMO?)**
En un escenario óptimo e ideal, la tendencia debería ser proactiva: el taller lograría monitorear el vehículo de manera remota y alertaría al cliente preventivamente antes de que la falla crítica se concrete, automatizando al mismo tiempo la reserva de repuestos y la cita. Sin embargo, la tendencia actual en el mercado sigue un patrón completamente reactivo y aleatorio para el conductor. La avería aparece de forma sorpresiva, desencadenando un proceso de diagnóstico artesanal que resulta excesivamente lento, manual y propenso a errores, alejándose totalmente de la eficiencia y exactitud que brindaría un servicio apoyado en el análisis de datos telemétricos.

**How Much (¿CUÁNTO?)**
El impacto económico y operativo es sustancial para ambas partes. Para el conductor o la empresa dueña de la flota, esperar a que el vehículo se descomponga implica asumir gastos de reparación correctiva que pueden llegar a ser entre 3 y 4 veces superiores al costo que habría tenido un mantenimiento preventivo a tiempo, sumado a los días de inactividad del vehículo que paralizan sus operaciones. Para el taller mecánico, la ineficiencia logística, el mal manejo de inventario sin costeo FIFO y la falta de estrategias de retención basadas en la prevención, se traducen sistemáticamente en miles de dólares mensuales en oportunidades de rentabilidad desperdiciadas y pérdida de competitividad en el sector.

**Antecedentes del Dominio del Problema**

La disciplina del mantenimiento automotriz ha transitado históricamente por fases conceptuales diferenciadas: el mantenimiento reactivo y el mantenimiento preventivo basado en umbrales estáticos, como el kilometraje o tiempo. Sin embargo, la creciente complejidad electromecánica exige la transición hacia el **mantenimiento predictivo**. Investigaciones de frontera demuestran que la integración del estándar de diagnóstico a bordo con arquitecturas de aprendizaje automático permite procesar series temporales generadas por sensores vehiculares (RPM, temperatura, presión), logrando clasificar estados de fallo inminentes con precisiones superiores al 95% [@hossain2024ai; @michailidis2025obd].

![Estrategias de mantenimiento y arquitectura del mantenimiento predictivo](assets/background-and-problems/maintenance-strategies.png){#fig:maintenance-strategies}

*Nota.* Adaptado de @hossain2024ai.

![Métodos de diagnóstico de fallos vehiculares basados en inteligencia artificial](assets/background-and-problems/vehicle-fault-diagnosis.png){#fig:vehicle-fault-diagnosis}

*Nota.* Adaptado de @hossain2024ai.

A pesar de la madurez de estos modelos, en Perú el sector de reparación automotriz, compuesto en su mayoría por MYPEs, exhibe una inmadurez digital estructural. Aunque el 94% de las pymes declaran haber invertido en tecnología post-pandemia, la digitalización en talleres mecánicos suele limitarse a redes sociales o mensajería. Esto se aclarece mas cuando el 50.19% de las MYPEs utilizan la tecnología para gestionar inventario, cuentas por cobrar y transacciones de manera integral, mientras que un 31.46% lo hace exclusivamente para inventarios básicos [@velasquez2025adopcion]. Esto deja el núcleo operativo vulnerable y operando de forma empírica.

![Distribución porcentual del uso de tecnología en las microempresas](assets/background-and-problems/technology-mype.png){#fig:technology-mype}

*Nota.* Tomado de @velasquez2025adopcion.

Para romper este ciclo, la adopción del Internet de las Cosas aplicado a la telemetría vehicular es el habilitador indispensable. Esto se logra mediante gateways telemétricos: dispositivos OBD-II con tarjetas SIM autónomas, o dispositivos Bluetooth que utilizan el teléfono inteligente del conductor como puente de transmisión de datos hacia la nube, democratizando el acceso a diagnósticos avanzados.

**Problemática Actual e Impacto Socioeconómico**

En el área metropolitana de Lima, esta desconexión tecnológica es crítica. Según los reportes oficiales de la Asociación Automotriz del Perú [@aap2023flota], la antigüedad promedio de la flota vehicular en circulación supera los 14 años, representando un riesgo exponencial de fallos y contaminación por gases de escape. Operar este parque bajo un modelo reactivo fuerza a los propietarios a asumir gastos de reparación correctiva que son, en promedio, entre el 300% y el 400% superiores a los costos de una intervención preventiva oportuna.

El costo de oportunidad por no digitalizar estos procesos es inmenso. El mercado global de aplicaciones de mantenimiento predictivo automotriz alcanzó los $4.8 mil millones de dólares en 2025, con proyecciones de escalar a $14.7 mil millones hacia 2034, y un ingreso promedio estimado de $112 dólares anuales por cada vehículo conectado [@dataintelo2025predictive].

![Tamaño del mercado global y proyección de aplicaciones de mantenimiento predictivo automotriz](assets/background-and-problems/predictive-maintenance-market.png){#fig:predictive-maintenance-market}

*Nota.* Tomado de @dataintelo2025predictive.

Específicamente, América Latina representó el 6.8% de los ingresos globales en 2025 y se proyecta que crezca a una tasa compuesta anual (CAGR) del 11.1% hasta 2034. En países con flotas vehiculares envejecidas, como Brasil, México y Perú, existe una fuerte demanda de diagnósticos predictivos rentables que puedan extender la vida útil de los vehículos [@dataintelo2025predictive]. Los talleres que no integren estas capacidades perderán competitividad rápidamente.

![Participación porcentual del mercado de mantenimiento predictivo automotriz por regiones (2025)](assets/background-and-problems/market-by-region.png){#fig:market-by-region}

*Nota.* Tomado de @dataintelo2025predictive.

Para transformar este ecosistema obsoleto y revertir las ineficiencias operativas descritas, Atelier ha sido concebido para resolver de manera directa tres fronteras críticas del dominio mediante una arquitectura Monolítica Modular. Cada uno de estos puntos ataca una deficiencia específica que imposibilita la escalabilidad de los talleres mecánicos:

**Ausencia de Ingesta Telemática y Análisis Predictivo:** Se debe resolver la ausencia técnica del taller procesando los flujos masivos de telemetría temporal de los vehículos. Esto exige separar la base de datos relacional transaccional de la carga analítica IoT, empleando estructuras de series temporales para no degradar el rendimiento del ERP.

**Fricción en la Trazabilidad Operativa:** Es necesario digitalizar todo el ciclo de vida de la reparación, desde la cita hasta el ingreso a la bahía de trabajo. Con ello se erradica la vulnerabilidad probatoria al implementar un registro fotográfico inmutable directamente desde el móvil hacia la nube de almacenamiento.

**Colapso Financiero por Descontrol de Inventarios:** Los talleres sufren constantes fugas de capital por aplicar costeos empíricos. Nuestra solución impone algorítmicamente el método de costeo FIFO, vinculando cada repuesto consumido a su lote de compra original para garantizar la rentabilidad real de la orden de trabajo.

Como respuesta a estas problemáticas, el proyecto persigue metas estratégicas enfocadas en revolucionar la forma en la que operan los negocios automotrices. A nivel macro, nuestros propósitos generales apuntan a una transformación integral y tecnológica del sector:

**Orquestar un ecosistema SaaS bilateral:** Consolidar toda la operatividad logística, de recursos humanos y administrativa del taller automotriz (B2B), habilitando al mismo tiempo el paradigma del mantenimiento predictivo inteligente a través de telemetría IoT orientada al consumidor final (B2C).

**Transformar el modelo de negocio automotriz:** Evolucionar la industria de un enfoque puramente reactivo a uno proactivo y predictivo. Esto se logra democratizando el acceso a diagnósticos avanzados mediante el uso de escáneres OBD-II bajo un modelo donde el taller adquiere su propio dispositivo.

Para materializar esta visión global, nos hemos trazado acciones específicas y cuantificables que guiarán la construcción de la plataforma y asegurarán la viabilidad operativa del ecosistema:

**Garantizar la resiliencia en la ingesta telemática:** Soportar la captura y compresión de millones de datos temporales mediante hipertablas, procesando códigos de fallos de motor para disparar alertas predictivas simultáneas hacia el taller y al conductor.

**Asegurar la trazabilidad financiera:** Lograr que la totalidad de las órdenes de trabajo operativas calculen su margen de ganancia descontando repuestos bajo un principio contable estricto.

**Proveer herramientas multiplataforma especializadas:** Desplegar interfaces web y aplicaciones móviles de uso para todos los actores del taller, aplicando un riguroso control de acceso basado en roles (RBAC).

El desarrollo de este ecosistema se encuentra delimitado por restricciones técnicas, académicas y presupuestales que moldean su alcance final durante la fase de despliegue:

**Alcance Tecnológico:** El backend se desarrollará obligatoriamente en Java siguiendo los lineamientos de diseño guiado por Domain-Driven Design. Para el frontend, se utilizará simultáneamente Flutter y Kotlin (Nativo en Android) para evaluar su rendimiento frente a las conexiones Bluetooth con escáneres vehiculares.

**Infraestructura de Pruebas IoT:** Debido a los altos costos y normativas, el ecosistema no será validado sobre motores de combustión reales operando de forma continua. El sistema se probará inyectando telemetría simulada a través de microcontroladores y transceptores CAN Bus que actuarán como emuladores de hardware, validando así la resiliencia de los endpoints del backend.

**Tolerancia y Cuotas de APIs Externas:** La integración con servicios de misión crítica estará restringida a los límites de procesamiento de sus capas gratuitas. Esto obliga al sistema a implementar mecanismos de caché y patrones de consistencia asíncrona para evitar la saturación.

**Agnosticismo Predictivo:** El sistema proporcionará probabilidades de fallo basadas en datos, pero actuará exclusivamente como un sistema experto de recomendación. La responsabilidad legal y la validación técnica final recaerán indelegablemente en la pericia y criterio del técnico mecánico.

### 1.2.2. *Lean UX Process*

#### 1.2.2.1. Lean UX Problem Statements

El estado actual de la micro y pequeña empresa (MYPE) del sector de mantenimiento, reparación y operaciones automotrices en Lima Metropolitana se caracteriza principalmente por una gestión artesanal y reactiva, en la que dueños de talleres mecánicos y técnicos operarios lidian con diagnósticos manuales lentos, descontrol en el costeo de inventarios de repuestos, ausencia de trazabilidad probatoria ante reclamos de clientes y pérdidas financieras sistemáticas derivadas de una administración empírica.

Lo que los productos y servicios existentes no logran abordar es la disponibilidad de un ecosistema SaaS unificado, accesible y nativo en la nube, diseñado específicamente para talleres independientes, que integre la ingesta de telemetría vehicular IoT con las operaciones críticas del negocio: valorización estricta de inventarios por método FIFO por lotes de compra, registro fotográfico inmutable de evidencia operativa, cronometraje de mano de obra validado por geocerca y facturación electrónica tributaria automatizada.

Nuestro producto abordará esta brecha mediante **Atelier Workshop**, una plataforma SaaS B2B integral desarrollada bajo principios de Domain-Driven Design (DDD). Atelier Workshop capacita al taller para conectar escáneres OBD-II estándar del mercado, ingestando telemetría en series temporales para agilizar diagnósticos preliminares y disparar alertas predictivas en el panel de control del taller. Simultáneamente, articula dos interfaces especializadas por rol: un panel web gerencial para el gestor del taller y una aplicación móvil de uso rudo y arquitectura *Offline-First* para el mecánico en bahía.

Nuestro enfoque inicial estará en los dos perfiles operativos internos de talleres automotrices independientes (MYPEs) de Lima Metropolitana: los gestores y propietarios de talleres y los técnicos mecánicos automotrices.

¿Cómo podríamos dotar a los administradores y técnicos mecánicos de talleres MYPE con una herramienta digital integrada que elimine la fricción operativa y probatoria en bahía, asegure la rentabilidad real de las reparaciones mediante costeo FIFO y habilite diagnósticos telemétricos predictivos sin requerir inversiones prohibitivas en hardware propietario?

Sabremos que tenemos éxito cuando observemos los siguientes cambios medibles en el comportamiento de nuestro público objetivo:

1. Una **reducción de al menos el 40%** en el tiempo promedio de recepción vehicular y emisión de diagnóstico preliminar en bahía, gracias a los datos telemétricos precargados y al flujo digital de órdenes de trabajo.
2. Al menos el **35% de los servicios de mantenimiento preventivo** gestionados en el taller se originen a partir de alertas tempranas detectadas por el monitoreo telemétrico de anomalías (DTCs y desviaciones de PIDs).
3. Una **tasa de retención mensual** de talleres suscritos a la plataforma SaaS **superior al 96%** (tasa de deserción o *churn* mensual inferior al 4%).
4. Una **disminución del 30%** en pérdidas económicas por discrepancias o mal costeo de inventario, mediante la aplicación estricta y automatizada del método FIFO por lote de compra.

#### 1.2.2.2. Lean UX Assumptions

**Business Assumptions**

1. Creemos que existe una demanda latente insatisfecha en el sector de talleres mecánicos MYPE por una solución SaaS B2B que unifique la gestión de órdenes de trabajo con telemetría vehicular IoT en tiempo real.
2. Creemos que un modelo de suscripción mensual escalonado por taller y volumen de bahías activas resulta económicamente viable y atractivo para las MYPEs automotrices frente al costo de ERPs tradicionales.
3. Creemos que la filosofía *Hardware Agnostic* eliminará la resistencia inicial de inversión en equipamiento por parte del taller.
4. Creemos que una arquitectura Monolítica Modular guiada por el dominio (DDD) nos otorgará la velocidad y estabilidad necesarias para evolucionar el núcleo transaccional (ERP) y analítico (IoT) sin sobrecostos de infraestructura.
5. Creemos que la digitalización y formalización tributaria integrada (SUNAT) servirá como palanca clave para que los talleres atraigan contratos de mantenimiento con flotas comerciales.

**Business Outcome Assumptions**

1. Creemos que lograremos una tasa de retención mensual de talleres suscritos superior al 96% al cabo de los primeros 12 meses de operación.
2. Creemos que reduciremos en al menos un 40% el tiempo promedio de recepción vehicular y diagnóstico preliminar en los talleres que adopten la aplicación móvil de bahía.
3. Creemos que lograremos que al menos el 35% de los ingresos por mantenimiento preventivo en el taller se deriven del seguimiento proactivo de alertas telemétricas.
4. Creemos que disminuiremos en un 30% las pérdidas financieras asociadas a discrepancias de stock y mermas mediante la valorización automatizada FIFO por lote.
5. Creemos que reduciremos el tiempo promedio de liquidación administrativa y emisión de comprobantes electrónicos a menos de 2 minutos por orden de trabajo.

**User Assumptions**

1. **Gestor y Propietario de Taller (Decisor B2B):** Creemos que es un adulto maduro (45 a 64 años), con perfil de migrante digital, responsable financiero del taller, que busca maximizar márgenes de ganancia, evitar fugas de capital en almacén y disponer de control gerencial sin lidiar con interfaces complejas.
2. **Técnico Mecánico Automotriz (Operario B2B):** Creemos que es un profesional técnico (19 a 40 años), nativo o migrante digital temprano, habituado al uso de smartphones y escáneres automotrices, que requiere una interfaz móvil ágil, de alto contraste, operable en bahía y resiliente ante cortes de conectividad (*Offline-First*).
3. **Contexto Tecnológico:** Creemos que ambos perfiles utilizan teléfonos inteligentes Android en su rutina diaria, pero rechazan software con excesivos pasos manuales o campos innecesarios que entorpezcan su ritmo de trabajo.

**User Outcome and Benefit Assumptions**

1. Creemos que los gestores de taller desean calcular con precisión matemática la rentabilidad de cada servicio, descontando repuestos bajo su costo real de adquisición (FIFO) y controlando la productividad de su personal.
2. Creemos que los gestores de taller desean reducir drásticamente el tiempo dedicado a la emisión de facturación electrónica y liquidaciones contables ante SUNAT.
3. Creemos que los técnicos mecánicos desean reducir la incertidumbre del diagnóstico accediendo a los códigos de falla (DTCs) y flujos de datos (PIDs) del vehículo antes de iniciar el desarmado físico.
4. Creemos que los técnicos mecánicos desean protegerse de disputas infundadas por daños preexistentes en los vehículos mediante un registro fotográfico digital inmutable al momento de la recepción.
5. Creemos que los técnicos mecánicos valoran un sistema que registre de forma transparente sus horas de trabajo efectivas por orden, respaldando esquemas de incentivos por rendimiento.

**Feature Assumptions**

1. Creemos que un módulo de ingesta telemática IoT (procesamiento de series temporales de PIDs y códigos DTC mediante TimescaleDB) acelerará el diagnóstico técnico en bahía.
2. Creemos que un panel gerencial de alertas predictivas telemétricas permitirá al taller contactar proactivamente a sus clientes fidelizados para programar servicios antes de averías mayores.
3. Creemos que un módulo móvil de órdenes de trabajo con captura de fotos inmutables (*Direct-to-Cloud*) blindará al taller frente a reclamos por garantías o daños no atribuibles al servicio.
4. Creemos que un sistema de control de inventario automatizado bajo el principio FIFO por lote de compra erradicará el costeo empírico y transparentará los márgenes netos por orden.
5. Creemos que un módulo de agendamiento y asignación inteligente de bahías optimizará la utilización de los puestos de trabajo y reducirá tiempos muertos entre servicios.
6. Creemos que un cronómetro operativo de mano de obra con validación de proximidad por geocerca garantizará mediciones reales de productividad sin requerir marcaciones biométricas complejas.
7. Creemos que disponer de dos interfaces diferenciadas para el taller (*Dashboard Web* para administración y *Mobile App* de uso rudo para mecánicos) maximizará la adopción de la plataforma en ambos roles.
8. Creemos que un módulo de facturación electrónica integrado que conecte la liquidación de la orden con el servicio de SUNAT simplificará la formalización tributaria del taller.

#### 1.2.2.3. Lean UX Hypothesis Statements

**Hypothesis Statement 1: Ingesta Telemática y Diagnóstico Acelerado en Bahía**

**Creemos que lograremos** una reducción de al menos el 40% en el tiempo promedio de recepción vehicular y diagnóstico preliminar en el taller,  
**si** los técnicos mecánicos automotrices  
**obtienen** acceso anticipado y en tiempo real a los parámetros de salud vehicular (PIDs en series temporales) y códigos de falla (DTCs) durante la inspección del automóvil,  
**mediante** un módulo de ingesta telemática en la nube compatible con escáneres OBD-II estándar del mercado (*Hardware Agnostic*).

**Hypothesis Statement 2: Panel de Alertas Telemáticas y Mantenimiento Proactivo**

**Creemos que lograremos** que al menos el 35% de los mantenimientos preventivos agendados en el taller se originen proactivamente por seguimiento técnico,  
**si** los gestores y administradores de taller  
**obtienen** un panel centralizado que traduzca eventos telemétricos y anomalías recurrentes de la flota de vehículos atendida en oportunidades concretas de servicio preventivo,  
**mediante** un motor de reglas y alertas tempranas configurado en el dashboard de gestión del taller.

**Hypothesis Statement 3: Órdenes de Trabajo Digitales con Respaldo Fotográfico Inmutable**

**Creemos que lograremos** mantener una tasa de retención mensual de talleres suscritos superior al 96% (deserción inferior al 4%),  
**si** los gestores de taller y técnicos mecánicos  
**obtienen** un blindaje probatorio digital inalterable del estado visual y mecánico del vehículo al ingresar, durante la intervención y en la entrega,  
**mediante** un módulo de órdenes de trabajo móviles con captura y carga directa de evidencia fotográfica a la nube (*Direct-to-Cloud*).

**Hypothesis Statement 4: Control y Valorización de Inventario por Método FIFO**

**Creemos que lograremos** reducir en un 30% las pérdidas económicas por discrepancias de inventario y asegurar que el 100% de los repuestos utilizados descuenten su costo del lote de compra original,  
**si** los administradores de taller y técnicos mecánicos  
**obtienen** un mecanismo simple de asignación y escaneo de repuestos que elimine el costeo empírico y los apuntes manuales,  
**mediante** un módulo de inventario automatizado que aplique estrictamente el principio contable FIFO por lotes de adquisición.

**Hypothesis Statement 5: Agendamiento Inteligente y Optimización de Bahías**

**Creemos que lograremos** elevar la tasa de ocupación efectiva de las bahías de trabajo al 85% y reducir los tiempos de inactividad no programados a menos de 15 minutos entre turnos,  
**si** los administradores y recepcionistas de taller  
**obtienen** una visualización en tiempo real de la disponibilidad física de los puestos de servicio y la carga de trabajo asignada a cada mecánico,  
**mediante** un módulo de agendamiento y balanceo de bahías integrado directamente al flujo de órdenes de trabajo.

**Hypothesis Statement 6: Registro de Tiempos de Mano de Obra con Validación de Proximidad**

**Creemos que lograremos** reducir la brecha entre el tiempo presupuestado y el tiempo real de mano de obra a menos de un 10% por orden de trabajo,  
**si** los jefes de taller y técnicos mecánicos  
**obtienen** un control cronometrado por fases operativas sin fricción burocrática y con validación automática de presencia física en las instalaciones,  
**mediante** una funcionalidad móvil de control de tiempos vinculada a la orden de trabajo y verificada por geocerca perimetral.

**Hypothesis Statement 7: Interfaces Especializadas por Rol B2B (Web y Mobile)**

**Creemos que lograremos** que más del 85% de los administradores y técnicos utilicen activamente la plataforma como su canal operativo primario diario,  
**si** ambos perfiles del taller  
**obtienen** una experiencia de uso adaptada estrictamente a su contexto laboral (panel analítico web de toma de decisiones para el dueño; interfaz móvil de alto contraste, pocos toques y *Offline-First* para el mecánico en bahía),  
**mediante** el despliegue de las dos interfaces especializadas del ecosistema *Atelier Workshop*.

**Hypothesis Statement 8: Cumplimiento Tributario y Facturación Electrónica Integrada**

**Creemos que lograremos** una reducción del 75% en el tiempo de liquidación y cierre administrativo de las órdenes de trabajo (emisión de comprobantes en menos de 2 minutos tras la aprobación del cliente),  
**si** los administradores de taller  
**obtienen** la emisión automática e inmediata de comprobantes de pago digitales válidos ante SUNAT generados directamente desde la orden liquidada,  
**mediante** un módulo de facturación electrónica integrado bajo el Régimen MYPE Tributario (RMT).

#### 1.2.2.4. Lean UX Canvas

![Matriz del Lean UX Canvas para el Ecosistema Atelier Workshop](assets/lean-ux/lean-ux-canva.jpg)

*Enlace al tablero interactivo:* [Ver en Miro](https://miro.com/welcomeonboard/ZEZJcWF2dElmbVAwcG1VV2JxUEc2RHpsSkxHL25uNE9RcFBVaTdxekxqNTlxK2xmczRXTDVXTzNvS2NDMXdKUkRjQmxNMDZhUmpvQlZ0cEllS21yMHZZMDFnbHRlL0pwSHhNR2l0WmhaL0ZNNytYQzhyb0dIWkpQaFN5WkNaMkNzVXVvMm53MW9OWFg5bkJoVXZxdFhRPT0hdjE=?share_link_id=454241249260)

\newpage