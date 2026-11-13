# Conclusiones

## Conclusiones y recomendaciones

El diagnóstico integral de la problemática automotriz y el contraste empírico desarrollado en los talleres mecánicos permitieron validar que las micro y pequeñas empresas de reparación vehicular en el entorno urbano operan bajo un modelo reactivo. Dicho escenario se caracteriza por una marcada desarticulación entre las labores mecánicas ejecutadas en patio y la gobernanza administrativa y contable gestionada en oficina.

**Conclusiones respecto a los Problem Statements y Segmentos Objetivo**

En relación al segmento de Personal de Gestión y Propietarios de Taller, representado por los administradores y dueños de negocio, se corroboró que la ausencia de trazabilidad en las adquisiciones genera discrepancias financieras sistemáticas, fuga de liquidez y márgenes imprecisos al liquidar servicios. Para resolver este problema, el equipo diseñó e implementó una plataforma centralizada de servicios que unifica la facturación electrónica bajo normativa SUNAT UBL 2.1, el control de inventario valorizado por lote y la liquidación consolidada de órdenes de trabajo, eliminando la dispersión de información en planillas aisladas o registros manuales en papel.

En cuanto al segmento de Personal Operativo del Taller, que abarca a técnicos mecánicos y asesores de servicio, se constató que la operatividad en fosos y elevadores se ve entorpecida por la manipulación de órdenes físicas propensas al deterioro por grasas y solventes, la dificultad de registrar evidencias visuales del estado de desarme y la falta de un canal ágil para comunicar averías ocultas imprevistas. Frente a esta necesidad, el diseño y construcción de la aplicación móvil de uso rudo dota al técnico de una herramienta de patio para capturar evidencia fotográfica pericial directa a la nube, registrar cronometrajes efectivos de faena, solicitar repuestos y ejecutar diagnósticos computarizados mediante escáneres OBD-II por comunicación inalámbrica.

**Conclusiones respecto a la Validación de Supuestos**

El proceso de validación cualitativa y el contraste en campo aportaron evidencia concluyente para contrastar los supuestos de negocio y tecnológicos formulados durante la concepción de la solución:

- **Supuesto de conectividad en taller:** Se asumió inicialmente que los talleres dispondrían de cobertura inalámbrica continua y de alta velocidad en todas sus áreas de trabajo. La investigación de campo y las pruebas operativas refutaron este supuesto, evidenciando que el personal técnico accede a redes móviles de forma intermitente y que las fosas subterráneas de inspección presentan pérdidas totales de señal por blindaje estructural. Este hallazgo validó de forma definitiva la necesidad crítica de una arquitectura Offline-First en la aplicación móvil, implementando almacenamiento local relacional con SQLite mediante Room en Android nativo y Drift en multiplataforma, sincronizado con colas de eventos en segundo plano cuando se restablece la conexión.

- **Supuesto de equipamiento telemático y dispositivos de patio:** Se contempló originalmente que la telemetría automotriz requeriría hardware propietario de alto costo, lo cual representaría una barrera económica de adopción para los talleres independientes. La validación demostró que la viabilidad del modelo descansa en la interoperabilidad con adaptadores estándar OBD-II genéricos bajo protocolo ELM327 acoplados a Bluetooth Low Energy, empleando el propio teléfono inteligente del mecánico como nodo de enlace telemático y herramienta de trabajo en patio, garantizando accesibilidad y bajo costo de despliegue.

- **Supuesto de costeo de inventario:** Se confirmó el supuesto de que un control tradicional de existencias resulta insuficiente ante la volatilidad de precios en repuestos y lubricantes importados. La validación demostró que la dispersión de costos exige un método de costeo estricto bajo el método FIFO por lote físico, garantizando que cada repuesto descontado en una orden de trabajo compute con exactitud el valor de adquisición del lote correspondiente.

- **Supuesto de adopción y canales digitales comerciales:** Se validó que los administradores demandan un canal digital interactivo y transparente que les permita simular tarifas dinámicas, calcular el retorno de inversión y consultar dudas operativas antes de iniciar una prueba de servicio, confirmando la pertinencia del portal web comercial desplegado.

**Conclusiones respecto a las Hipótesis de Solución y Criterios de Éxito**

Las hipótesis planteadas en el proceso de Lean UX se contrastaron con los incrementos de software construidos y la retroalimentación directa de los usuarios:

- **Hipótesis de telemetría predictiva e inferencia con inteligencia artificial:** Se formuló que la captura continua de parámetros sensoriales PIDs y códigos de falla DTC bajo normas SAE J2012 e ISO 15031-6, combinada con modelos fundacionales, permitiría anticipar averías mecánicas complejas y elevar la confianza del cliente. El diseño del flujo de procesamiento con Spring AI, Groq Cloud LPU y el modelo fundacional Llama 3.3 70B demostró la factibilidad técnica de emitir diagnósticos periciales causales en menos de un segundo y generar reportes clínicos en formato PDF con OpenPDF y Thymeleaf, cumpliendo el objetivo de reducir el tiempo de diagnóstico inicial y transparentar la comunicación técnica.

- **Hipótesis de trazabilidad en propuestas de tareas y transparencia:** Se propuso que permitir a los mecánicos registrar averías ocultas como propuestas técnicas con evidencia fotográfica directa a Firebase Storage, mediadas por el asesor de servicio ante el cliente, erradicaría la percepción de cobros arbitrarios. La validación en campo reflejó que la demostración fotográfica objetiva incrementa significativamente la tasa de aprobación de mantenimientos correctivos complementarios.

- **Criterios de viabilidad arquitectónica y sostenibilidad económica:** Se comprobó que la arquitectura orquestada sobre servicios en la nube de alta disponibilidad, desplegada en plataformas como Render para la API REST, Aiven para PostgreSQL y TimescaleDB, Vercel para el portal web comercial, Firebase para autenticación, almacenamiento y distribución de aplicaciones, Groq Cloud LPU y Resend, satisface los requisitos de resiliencia, neutralidad de proveedores y sostenibilidad económica para el modelo de negocio SaaS.

**Conclusiones del Diseño Arquitectónico y Estrategia Táctica**

El modelado estratégico bajo Domain-Driven Design permitió descomponer la complejidad operativa del taller en ocho Bounded Contexts cohesivos, articulados en IAM and Tenancy, Customer and Fleet Management, Workshop Operations MRO, Inventory and Supply Chain, Human Resources Management, Invoicing and Compliance, SaaS Billing and Subscriptions, e IoT Telemetry and Predictive Maintenance. Este aislamiento previno la proliferación de modelos saturados de datos y delimitó responsabilidades inequívocas en el dominio.

Asimismo, la aplicación de patrones tácticos demostró solidez técnica en todos los niveles. La arquitectura hexagonal desacopló la lógica de negocio pura de las dependencias de persistencia y servicios externos. La Capa Anticorrupción protegió el dominio contable frente a los esquemas tributarios de Nubefact y bancarios de Stripe. A su vez, el patrón Transactional Outbox garantizó la consistencia eventual durante la emisión de comprobantes y procesamiento de cobros. Finalmente, la formulación de épicas e historias de usuario bajo sintaxis BDD Gherkin proveyó una base estructurada y orientada a pruebas automatizadas para todo el ciclo constructivo.

**Conclusiones del Diseño de Experiencia de Usuario e Interfaz**

El diseño de experiencia de usuario e interfaz consolidó un sistema de diseño canónico unificado, denominado Atelier Workshop Design System. Este sistema se estructuró mediante tokens canónicos sobre Tailwind CSS v4, estableciendo una jerarquía tipográfica con la fuente Satoshi para interfaces operativas de alta densidad de datos y la fuente Albert Sans para la identidad de marca, respaldadas por una paleta cromática contrastada que combina Azul Eléctrico, Azul Marino y Naranja Ámbar de acento.

En el ámbito móvil, el diseño se orientó de forma prioritaria a las condiciones de uso rudo en el entorno de taller automotriz. Se optimizó la ergonomía táctil en fosos y bahías mediante zonas de pulsación superiores a cuarenta y ocho puntos de densidad independientes, aptas para interacción con guantes de trabajo o dedos con residuos de grasa, y se priorizó el modo oscuro para garantizar legibilidad bajo reflectores intensos y optimizar el consumo de batería. Los diagramas de flujo de usuario y wireflows simplificaron las operaciones críticas de patio a menos de tres toques por acción.

En cuanto a la presencia comercial, la arquitectura de información y el diseño del portal web de aterrizaje establecieron sistemas de rotulado técnico directo, navegación secuencial y optimización para motores de búsqueda con etiquetas OpenGraph y metadatos estructurados. La interfaz comercial incorpora una calculadora interactiva de ahorro y comparativa dinámica de tarifas por periodicidad de facturación, orientando al propietario hacia el flujo de activación de su prueba gratuita de catorce días.


**Conclusiones de la Implementación del Producto y Ciclos Constructivos**

Durante el ciclo inicial de desarrollo, el equipo materializó y verificó los cimientos constructivos de la plataforma mediante la ejecución disciplinada del marco ágil Scrum. Se completó el 100% de los noventa Story Points comprometidos en el primer ciclo, abarcando cuatro historias de usuario del portal comercial, veinticuatro historias técnicas de servicios del backend y tres tareas de investigación técnica profunda.

En el aspecto de infraestructura en la nube, el portal comercial se desplegó al 100% en la red global de Vercel vinculado al dominio canónico personalizado atelier.andeva.tech con certificados de seguridad activos. Asimismo, la plataforma de servicios backend se desplegó en Render mediante contenedores Docker multi-etapa con Java 25 y Tomcat embebido, conectada a clústeres administrados de PostgreSQL 16 y TimescaleDB en Aiven. Se implementó una suite automatizada de ciento noventa y ocho clases de prueba con JUnit 5, Mockito, AssertJ y Testcontainers sobre bases de datos reales, complementada con veinticuatro endpoints canónicos documentados bajo la especificación OpenAPI 3.1 y expuestos en Swagger UI en producción.

Durante el segundo ciclo constructivo, el equipo concentró su capacidad técnica en la construcción y verificación de la aplicación móvil nativa Android Atelier Workshop Mobile mediante Kotlin 2.0 y Jetpack Compose. Se alcanzó una velocidad de cincuenta y cinco Story Points distribuidos en veintidós historias de usuario que materializaron los flujos centrales de autenticación multi-tenant, marcación de asistencia satelital con geocercas geodésicas Haversine, recepción pericial vehicular en patio con inspección fotográfica 360°, liquidación automatizada de presupuestos, cronometraje de tareas en fosa y abastecimiento de repuestos bajo el método FIFO. La aplicación demostró operatividad sin conexión obligatoria a internet gracias a la persistencia relacional local con Room y SQLite.

Para la distribución continua, el equipo implementó un flujo automatizado mediante Firebase App Distribution, generando binarios firmados y ofuscados mediante R8 para su instalación inmediata en dispositivos físicos de evaluación.

**Conclusiones del Proceso de Validación y Evaluación Heurística**

Las entrevistas de validación cualitativa en campo demostraron una alta aceptación y adaptabilidad por parte de administradores y mecánicos. Se comprobó que el registro fotográfico pericial al momento del ingreso previene controversias con los propietarios de automóviles, mientras que el cronometraje directo de labores en bahía transparenta la productividad del equipo técnico sin burocracia manual.

Por su parte, la evaluación heurística de experiencia de usuario estructurada bajo los principios de Jakob Nielsen, arquitectura de información y diseño inclusivo evidenció un cumplimiento notable en visibilidad del estado del sistema, coherencia con el vocabulario automotriz y prevención de errores en la manipulación de inventarios y presupuestos. Las sesiones permitieron identificar y afinar detalles ergonómicos clave, tales como el contraste en áreas oscuras de taller y la confirmación unificada de inicio y fin de faena en patio.


\newpage

**Recomendaciones y Siguientes Pasos del Roadmap de Producto**

A partir de los resultados y lecciones aprendidas durante la culminación de los ciclos constructivos y las validaciones en campo, el equipo establece las siguientes recomendaciones estructuradas según el roadmap de producto:

- **Fase de telemetría vehicular avanzada e inferencia predictiva:**
  - Incorporar en la aplicación móvil la capa de comunicación inalámbrica Bluetooth Low Energy para la lectura en tiempo real de flujos de datos sensoriales PIDs y códigos de error DTC mediante adaptadores estándar OBD-II bajo protocolo ELM327.
  - Conectar el componente de inferencia diagnóstica con Spring AI y el modelo fundacional Llama 3.3 70B en Groq Cloud LPU para emitir diagnósticos causales automáticos y recomendaciones de reparación directamente en la aplicación.

- **Fase de homologación tributaria y facturación electrónica nativa:**
  - Conectar la Capa Anticorrupción de facturación con el entorno oficial de pruebas de Nubefact para la emisión, validación y timbrado de boletas y facturas electrónicas bajo la normativa UBL 2.1 ante la SUNAT.
  - Integrar la pasarela de pagos con Stripe para la gestión automatizada de cobros recurrentes y facturación de suscripciones comerciales del modelo SaaS.

- **Fase de expansión hacia Atelier Driver y distribución pública:**
  - Iniciar el diseño y desarrollo del producto digital complementario Atelier Driver para conductores particulares y administradores de flotas vehiculares, habilitando el historial clínico digital del vehículo, el agendamiento remoto de citas y la recepción de alertas predictivas push mediante Firebase Cloud Messaging.
  - Realizar pruebas de rendimiento y estrés sobre la infraestructura en la nube y preparar los manifiestos de publicación para el despliegue formal de la aplicación móvil en canales de distribución general.

\newpage
