# Conclusiones

## Conclusiones y recomendaciones

El diagnóstico integral de la problemática automotriz y el contraste empírico desarrollado en los talleres mecánicos permitieron validar que las micro y pequeñas empresas de reparación vehicular en el entorno urbano operan bajo un modelo reactivo. Dicho escenario se caracteriza por una marcada desarticulación entre las labores mecánicas ejecutadas en patio y la gobernanza administrativa y contable gestionada en oficina.

**Conclusiones respecto a los Problem Statements y Segmentos Objetivo**

En relación al segmento de Personal de Gestión y Propietarios de Taller, representado por los administradores y dueños de negocio, se corroboró que la ausencia de trazabilidad en las adquisiciones genera discrepancias financieras sistemáticas, fuga de liquidez y márgenes imprecisos al liquidar servicios. Para resolver este problema, el equipo diseñó e implementó una plataforma centralizada de servicios que unifica la facturación electrónica bajo normativa SUNAT UBL 2.1, el control de inventario valorizado por lote y la liquidación consolidada de órdenes de trabajo, eliminando la dispersión de información en planillas aisladas o registros manuales en papel.

En cuanto al segmento de Personal Operativo del Taller, que abarca a técnicos mecánicos y asesores de servicio, se constató que la operatividad en fosos y elevadores se ve entorpecida por la manipulación de órdenes físicas propensas al deterioro por grasas y solventes, la dificultad de registrar evidencias visuales del estado de desarme y la falta de un canal ágil para comunicar averías ocultas imprevistas. Frente a esta necesidad, el diseño de la aplicación móvil de uso rudo dota al técnico de una herramienta de patio para capturar evidencia fotográfica pericial directa a la nube, consultar catálogos de repuestos y ejecutar diagnósticos computarizados mediante escáneres OBD-II por comunicación inalámbrica.

**Conclusiones respecto a la Validación de Supuestos**

El proceso de validación cualitativa aportó evidencia para contrastar los supuestos de negocio y tecnológicos formulados durante la concepción de la solución:

- **Supuesto de conectividad en taller:** Se asumió inicialmente que los talleres dispondrían de cobertura inalámbrica continua y de alta velocidad en todas sus áreas de trabajo. La investigación de campo refutó este supuesto, evidenciando que el 49.1% del personal técnico accede a redes móviles de forma intermitente y que las fosas subterráneas de inspección presentan pérdidas totales de señal por blindaje estructural. Este hallazgo validó de forma concluyente la necesidad crítica de una arquitectura Offline-First en la aplicación móvil, implementando almacenamiento local relacional con SQLite mediante Room en Android nativo y Drift en multiplataforma, sincronizado con colas de eventos en segundo plano cuando se restablece la conexión.

- **Supuesto de equipamiento telemático:** Se contempló originalmente que la telemetría automotriz requeriría hardware propietario de alto costo, lo cual representaría una barrera económica de adopción para los talleres independientes. La validación demostró que la viabilidad del modelo descansa en la interoperabilidad con adaptadores estándar OBD-II genéricos bajo protocolo ELM327 acoplados a Bluetooth Low Energy, empleando el propio teléfono inteligente del mecánico como nodo de enlace telemático, garantizando accesibilidad y bajo costo de despliegue.

- **Supuesto de costeo de inventario:** Se confirmó el supuesto de que un control tradicional de existencias resulta insuficiente ante la volatilidad de precios en repuestos y lubricantes importados. La validación demostró que la dispersión de costos exige un método de costeo estricto bajo el método FIFO por lote físico, garantizando que cada repuesto descontado en una orden de trabajo compute con exactitud el valor de adquisición del lote correspondiente.

- **Supuesto de adopción y canales digitales comerciales:** Se asumió inicialmente que la captación de talleres automotrices se realizaría mediante demostraciones presenciales individuales. La investigación validó que los administradores demandan un canal digital interactivo y transparente que les permita simular tarifas dinámicas, calcular el retorno de inversión y consultar dudas operativas antes de iniciar una prueba de servicio, confirmando la pertinencia del portal web comercial desplegado.

**Conclusiones respecto a las Hipótesis de Solución y Criterios de Éxito**

Las hipótesis planteadas en el proceso de Lean UX se contrastaron con los artefactos de diseño y las necesidades declaradas por los usuarios:

- **Hipótesis de telemetría predictiva e inferencia con inteligencia artificial:** Se formuló que la captura continua de parámetros sensoriales PIDs y códigos de falla DTC bajo normas SAE J2012 e ISO 15031-6, combinada con modelos fundacionales, permitiría anticipar averías mecánicas complejas y elevar la confianza del cliente. El diseño del flujo de procesamiento con Spring AI, Groq Cloud LPU y el modelo fundacional Llama 3.3 70B demostró la factibilidad técnica de emitir diagnósticos periciales causales en menos de un segundo y generar reportes clínicos en formato PDF con OpenPDF y Thymeleaf, cumpliendo el criterio de éxito de reducir el tiempo de diagnóstico inicial y transparentar la comunicación técnica.

- **Hipótesis de trazabilidad en propuestas de tareas y transparencia:** Se propuso que permitir a los mecánicos registrar averías ocultas como propuestas técnicas con evidencia fotográfica directa a Firebase Storage, mediadas por el asesor de servicio ante el cliente, erradicaría la percepción de cobros arbitrarios. La validación reflejó que la demostración fotográfica objetiva incrementa significativamente la tasa de aprobación de mantenimientos correctivos complementarios.

- **Criterios de viabilidad arquitectónica y sostenibilidad económica:** Se comprobó que la arquitectura orquestada sobre servicios en la nube de alta disponibilidad, desplegada en plataformas como Render para la API REST, Aiven para PostgreSQL y TimescaleDB, Vercel para el portal web comercial, Groq Cloud LPU, Firebase y Resend, satisface los requisitos de resiliencia, neutralidad de proveedores y sostenibilidad económica para el modelo de negocio SaaS.

**Conclusiones del Diseño Arquitectónico y Estrategia Táctica**

El modelado estratégico bajo Domain-Driven Design permitió descomponer la complejidad operativa del taller en ocho Bounded Contexts cohesivos, articulados en IAM and Tenancy, Customer and Fleet Management, Workshop Operations MRO, Inventory and Supply Chain, Human Resources Management, Invoicing and Compliance, SaaS Billing and Subscriptions, e IoT Telemetry and Predictive Maintenance. Este aislamiento previno la proliferación de modelos saturados de datos y delimitó responsabilidades inequívocas en el dominio.

Asimismo, la aplicación de patrones tácticos demostró solidez técnica en todos los niveles. La arquitectura hexagonal desacopló la lógica de negocio pura de las dependencias de persistencia y servicios externos. La Capa Anticorrupción protegió el dominio contable frente a los esquemas tributarios de Nubefact y bancarios de Stripe. A su vez, el patrón Transactional Outbox garantizó la consistencia eventual durante la emisión de comprobantes y procesamiento de cobros. Finalmente, la formulación de épicas e historias de usuario bajo sintaxis BDD Gherkin provee una base estructurada y orientada a pruebas automatizadas para todo el ciclo de desarrollo.

**Conclusiones del Diseño de Experiencia de Usuario e Interfaz**

El diseño de experiencia de usuario e interfaz consolidó un sistema de diseño canónico unificado, denominado Atelier Workshop Design System. Este sistema se estructuró mediante tokens canónicos sobre Tailwind CSS v4, estableciendo una jerarquía tipográfica con la fuente Satoshi para interfaces operativas de alta densidad de datos y la fuente Albert Sans para la identidad de marca, respaldadas por una paleta cromática contrastada que combina Azul Eléctrico, Azul Marino y Naranja Ámbar de acento.

En el ámbito móvil, el diseño se orientó de forma prioritaria a las condiciones de uso rudo en el entorno de taller automotriz. Se optimizó la ergonomía táctil en fosos y bahías mediante zonas de pulsación de gran tamaño, aptas para interacción con guantes de trabajo o dedos con residuos de grasa, y se priorizó el modo oscuro para garantizar legibilidad bajo reflectores intensos y optimizar el consumo de batería. Los diagramas de flujo de usuario y wireflows simplificaron las operaciones críticas de patio a menos de tres toques por acción.

En cuanto a la presencia comercial, la arquitectura de información y el diseño del portal web de aterrizaje establecieron sistemas de rotulado técnico directo, navegación secuencial y optimización para motores de búsqueda con etiquetas OpenGraph y metadatos estructurados. La interfaz comercial incorpora una calculadora interactiva de ahorro y comparativa dinámica de tarifas por periodicidad de facturación, orientando al propietario hacia el flujo de activación de su prueba gratuita de catorce días.

**Conclusiones de la Implementación del Producto y Ciclo Constructivo**

Durante el primer ciclo de desarrollo, el equipo materializó y verificó los cimientos constructivos de la plataforma mediante la ejecución disciplinada del marco ágil Scrum. Se completó el 100% de los noventa Story Points comprometidos en el Sprint Backlog, abarcando cuatro historias de usuario del portal comercial, veinticuatro historias técnicas de servicios del backend y tres tareas de investigación técnica profunda.

En el aspecto de despliegue continuo en la nube, se alcanzó la operatividad en producción de los dos componentes centrales de este hito. El portal comercial se desplegó al 100% en la red global de Vercel vinculado al dominio canónico personalizado atelier.andeva.tech con certificados de seguridad activos. Asimismo, la plataforma de servicios backend se desplegó en Render mediante contenedores Docker multi-etapa con Java 25 y Tomcat embebido, conectada a clústeres administrados de PostgreSQL 16 y TimescaleDB en Aiven, alcanzando la disponibilidad total de los servicios requeridos.

En el aseguramiento de la calidad y gobierno de servicios, el equipo implementó una suite automatizada de ciento noventa y ocho clases de prueba con JUnit 5, Mockito, AssertJ y Testcontainers. La ejecución de pruebas contra contenedores efímeros con bases de datos reales garantizó el cumplimiento determinista de las reglas de negocio sin regresiones, validando el algoritmo de Haversine para geocercas, la valoración FIFO por lote y la consistencia transaccional. Por último, se documentaron e integraron veinticuatro endpoints canónicos bajo la especificación OpenAPI 3.1, expuestos interactivamente en producción a través de Swagger UI con manejo uniforme de errores bajo el estándar RFC 7807.

\newpage

**Recomendaciones y Siguientes Pasos del Roadmap de Producto**

A partir de los resultados y lecciones aprendidas durante la culminación del primer ciclo constructivo, el equipo establece las siguientes recomendaciones estructuradas según el roadmap de producto:

- **Fase de desarrollo móvil y validación en campo:**
  - Construir e integrar los clientes móviles nativos en Android con Kotlin, Jetpack Compose y Room, y en multiplataforma con Flutter y Drift, conectándolos directamente a los servicios web desplegados en Render.
  - Implementar la capa de comunicación inalámbrica Bluetooth Low Energy para la captura de telemetría automotriz en vivo mediante adaptadores OBD-II bajo protocolo ELM327.
  - Integrar el almacenamiento fotográfico pericial inmutable en Firebase Storage para la carga directa de evidencias en órdenes de trabajo y propuestas de tareas.
  - Ejecutar entrevistas de validación de solución y evaluaciones heurísticas de usabilidad con mecánicos y propietarios en talleres físicos de Lima Metropolitana, calibrando la ergonomía de la interfaz en condiciones reales de iluminación y suciedad.

- **Fase de consolidación empresarial y distribución:**
  - Integrar la Capa Anticorrupción de facturación electrónica con el entorno de pruebas de Nubefact para la homologación formal de boletas y facturas electrónicas UBL 2.1 ante la SUNAT.
  - Integrar la pasarela de pagos con Stripe para la gestión automatizada de suscripciones comerciales recurrentes y cobros por taller.
  - Publicar la versión beta de la aplicación móvil en Firebase App Distribution para pruebas de campo controladas con usuarios piloto.
  - Iniciar el diseño y desarrollo del módulo complementario Atelier Driver para conductores particulares y administradores de flotas, habilitando el historial clínico digital del vehículo y alertas predictivas de mantenimiento.

\newpage