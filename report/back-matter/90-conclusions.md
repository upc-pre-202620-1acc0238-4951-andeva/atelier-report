# Conclusiones

## Conclusiones y recomendaciones

El diagnóstico integral de la problemática automotriz y el contraste empírico desarrollado en los talleres mecánicos permitieron validar que las micro y pequeñas empresas de reparación vehicular en el entorno urbano operan bajo un modelo reactivo. Dicho escenario se caracteriza por una marcada desarticulación entre las labores mecánicas ejecutadas en patio y la gobernanza administrativa y contable gestionada en oficina.

**Conclusiones respecto a los Problem Statements y Segmentos Objetivo**

En relación al segmento de Personal de Gestión y Propietarios de Taller, representado por los administradores y dueños de negocio, se corroboró que la ausencia de trazabilidad en las adquisiciones genera discrepancias financieras sistemáticas, fuga de liquidez y márgenes imprecisos al liquidar servicios. Para resolver este problema, el equipo diseñó e implementó una plataforma centralizada de servicios que unifica la facturación electrónica bajo normativa SUNAT UBL 2.1, el control de inventario valorizado por lote, la recaudación multimedio en caja, la supervisión de bahías en tiempo real y la liquidación consolidada de órdenes de trabajo, eliminando la dispersión de información en planillas aisladas o registros manuales en papel.

En cuanto al segmento de Personal Operativo del Taller, que abarca a técnicos mecánicos y asesores de servicio, se constató que la operatividad en fosos y elevadores se ve entorpecida por la manipulación de órdenes físicas propensas al deterioro por grasas y solventes, la dificultad de registrar evidencias visuales del estado de desarme y la falta de un canal ágil para comunicar averías ocultas imprevistas. Frente a esta necesidad, la construcción de las aplicaciones móviles de uso rudo en Android nativo y multiplataforma dota al técnico de una herramienta integral de patio para capturar evidencia fotográfica pericial directa a la nube, registrar cronometrajes efectivos de faena, solicitar repuestos y ejecutar diagnósticos computarizados mediante escáneres OBD-II por comunicación inalámbrica.

**Conclusiones respecto a la Validación de Supuestos**

El proceso de validación cualitativa, el contraste en campo y la implementación integral de las soluciones aportaron evidencia concluyente sobre los supuestos de negocio y tecnológicos formulados durante la concepción del producto:

- **Supuesto de conectividad en taller:** Se asumió inicialmente que los talleres dispondrían de cobertura inalámbrica continua y de alta velocidad en todas sus áreas de trabajo. La investigación de campo y las pruebas operativas refutaron este supuesto, evidenciando que el personal técnico accede a redes móviles de forma intermitente y que las fosas subterráneas de inspección presentan pérdidas totales de señal por blindaje estructural. Este hallazgo validó de forma definitiva la necesidad crítica de una arquitectura Offline-First en las aplicaciones móviles, implementando almacenamiento local relacional con SQLite mediante Room en Android nativo y Drift en Flutter multiplataforma, sincronizado con colas de eventos en segundo plano cuando se restablece la conexión.

- **Supuesto de equipamiento telemático y dispositivos de patio:** Se contempló originalmente que la telemetría automotriz requeriría hardware propietario de alto costo, lo cual representaría una barrera económica de adopción para los talleres independientes. La validación e implementación con las bibliotecas Bluetooth Low Energy demostró que la viabilidad del modelo descansa en la interoperabilidad con adaptadores estándar OBD-II genéricos bajo protocolo ELM327, empleando el propio teléfono inteligente del mecánico como nodo de enlace telemático y herramienta de trabajo en patio, garantizando accesibilidad y bajo costo de despliegue.

- **Supuesto de costeo de inventario:** Se confirmó el supuesto de que un control tradicional de existencias resulta insuficiente ante la volatilidad de precios en repuestos y lubricantes importados. La validación demostró que la dispersión de costos exige un método de costeo estricto bajo el método FIFO por lote físico, garantizando que cada repuesto descontado en una orden de trabajo compute con exactitud el valor de adquisición del lote correspondiente.

- **Supuesto de adopción y canales digitales comerciales:** Se validó que los administradores demandan un canal digital interactivo y transparente que les permita simular tarifas dinámicas, calcular el retorno de inversión y consultar dudas operativas antes de iniciar una prueba de servicio, confirmando la pertinencia del portal web comercial desplegado.

**Conclusiones respecto a las Hipótesis de Solución y Criterios de Éxito**

Las hipótesis planteadas en el proceso de Lean UX se contrastaron con la solución de software completada y la retroalimentación directa de los usuarios:

- **Hipótesis de telemetría predictiva e inferencia con inteligencia artificial:** Se formuló que la captura continua de parámetros sensoriales PIDs y códigos de falla DTC bajo normas SAE J2012 e ISO 15031-6, combinada con modelos fundacionales, permitiría anticipar averías mecánicas complejas y elevar la confianza del cliente. La integración operativa de lectura inalámbrica OBD-II junto con el flujo de procesamiento en Spring AI, Groq Cloud LPU y el modelo fundacional Llama 3.3 70B demostró la factibilidad técnica de emitir diagnósticos periciales causales en menos de un segundo y generar reportes clínicos en formato PDF, cumpliendo el objetivo de reducir el tiempo de diagnóstico inicial y transparentar la comunicación técnica.

- **Hipótesis de trazabilidad en propuestas de tareas y transparencia:** Se propuso que permitir a los mecánicos registrar averías ocultas como propuestas técnicas con evidencia fotográfica directa a Firebase Storage, mediadas por el asesor de servicio ante el cliente, erradicaría la percepción de cobros arbitrarios. La validación en campo reflejó que la demostración fotográfica objetiva incrementa significativamente la tasa de aprobación de mantenimientos correctivos complementarios.

- **Criterios de viabilidad arquitectónica y sostenibilidad económica:** Se comprobó que la arquitectura orquestada sobre servicios en la nube de alta disponibilidad, desplegada en Render para la API REST, Aiven para PostgreSQL y TimescaleDB, Vercel para el portal web comercial, Firebase para autenticación, almacenamiento y distribución de aplicaciones, Groq Cloud LPU y Resend, satisface los requisitos de resiliencia, neutralidad de proveedores y sostenibilidad económica para el modelo de negocio SaaS.

**Conclusiones del Diseño Arquitectónico y Estrategia Táctica**

El modelado estratégico bajo Domain-Driven Design permitió descomponer la complejidad operativa del taller en ocho Bounded Contexts cohesivos, articulados en IAM and Tenancy, Customer and Fleet Management, Workshop Operations MRO, Inventory and Supply Chain, Human Resources Management, Invoicing and Compliance, SaaS Billing and Subscriptions, e IoT Telemetry and Predictive Maintenance. Este aislamiento previno la proliferación de modelos saturados de datos y delimitó responsabilidades inequívocas en el dominio.

Asimismo, la aplicación de patrones tácticos demostró solidez técnica en todos los niveles. La arquitectura hexagonal desacopló la lógica de negocio pura de las dependencias de persistencia y servicios externos tanto en el backend como en los clientes móviles. La Capa Anticorrupción protegió el dominio contable frente a los esquemas tributarios de Nubefact y bancarios de Stripe. A su vez, el patrón Transactional Outbox garantizó la consistencia eventual durante la emisión de comprobantes y procesamiento de cobros. Finalmente, la formulación de épicas e historias de usuario bajo sintaxis BDD Gherkin proveyó una base estructurada y orientada a pruebas automatizadas durante los tres ciclos constructivos.

**Conclusiones del Diseño de Experiencia de Usuario e Interfaz**

El diseño de experiencia de usuario e interfaz consolidó un sistema de diseño canónico unificado, denominado Atelier Workshop Design System. Este sistema se estructuró mediante tokens canónicos sobre Tailwind CSS v4, estableciendo una jerarquía tipográfica con la fuente Satoshi para interfaces operativas de alta densidad de datos y la fuente Albert Sans para la identidad de marca, respaldadas por una paleta cromática contrastada que combina Azul Eléctrico, Azul Marino y Naranja Ámbar de acento.

En el ámbito móvil, el diseño se orientó de forma prioritaria a las condiciones de uso rudo en el entorno de taller automotriz. Se optimizó la ergonomía táctil en fosos y bahías mediante zonas de pulsación superiores a cuarenta y ocho puntos de densidad independientes, aptas para interacción con guantes de trabajo o dedos con residuos de grasa, y se priorizó el modo oscuro para garantizar legibilidad bajo reflectores intensos y optimizar el consumo de batería. Los diagramas de flujo de usuario y wireflows simplificaron las operaciones críticas de patio a menos de tres toques por acción.

En cuanto a la presencia comercial, la arquitectura de información y el diseño del portal web de aterrizaje establecieron sistemas de rotulado técnico directo, navegación secuencial y optimización para motores de búsqueda con etiquetas OpenGraph y metadatos estructurados. La interfaz comercial incorpora una calculadora interactiva de ahorro y comparativa dinámica de tarifas por periodicidad de facturación, orientando al propietario hacia el flujo de activación de su prueba gratuita de catorce días.

**Conclusiones de la Implementación del Producto y Ciclos Constructivos**

A lo largo de tres iteraciones incrementales bajo el marco ágil Scrum, el equipo completó el 100% del alcance planificado, consolidando doscientos dos Story Points totales entre la plataforma de servicios web, el portal comercial y las aplicaciones móviles nativa y multiplataforma.

Durante el ciclo inicial de desarrollo, el portal comercial se desplegó al 100% en Vercel bajo el dominio canónico personalizado atelier.andeva.tech con certificados de seguridad activos. De forma paralela, la plataforma backend se desplegó en Render mediante contenedores Docker multi-etapa con Java 25 y Tomcat embebido, conectada a clústeres administrados de PostgreSQL 16 y TimescaleDB en Aiven. Este núcleo quedó respaldado por ciento noventa y ocho clases de prueba automatizadas con Testcontainers sobre bases de datos reales y veinticuatro endpoints canónicos documentados en OpenAPI 3.1 y Swagger UI.

Durante el segundo ciclo constructivo, se completaron cincuenta y cinco Story Points mediante la construcción y verificación de la aplicación móvil nativa Android Atelier Workshop Mobile en Kotlin 2.0 y Jetpack Compose. Se materializaron los flujos de autenticación multi-tenant, marcación satelital con geocercas geodésicas Haversine, recepción pericial vehicular con inspección fotográfica 360°, liquidación de presupuestos, cronometraje en fosa y abastecimiento de repuestos bajo el método FIFO con persistencia local en Room y SQLite, logrando seiscientas cincuenta pruebas automatizadas y distribución continua de binarios firmados y ofuscados con R8 en Firebase App Distribution.

Durante el tercer y último ciclo constructivo, el equipo culminó los cincuenta y siete Story Points restantes distribuidos en veintiuna historias de usuario mediante el desarrollo de la aplicación móvil multiplataforma en Flutter y Dart orientada a Android e iOS. Esta iteración completó la paridad funcional del ecosistema incorporando el enlace inalámbrico Bluetooth Low Energy con escáneres OBD-II ELM327 para lectura y restablecimiento de códigos DTC, monitoreo en vivo de parámetros telemétricos, generación de informes predictivos asistidos por inteligencia artificial con exportación en PDF, emisión de comprobantes electrónicos UBL 2.1 ante la SUNAT, cobro multimedio en caja, supervisión de bahías en tiempo real y persistencia fuera de línea con Drift sobre SQLite. La confiabilidad del cliente multiplataforma quedó certificada mediante ciento dieciocho archivos de prueba y mil ciento ocho casos automatizados que validan desde las reglas de dominio y simuladores de ECU hasta las colas de sincronización y flujos de extremo a extremo.

**Conclusiones del Proceso de Validación y Evaluación Heurística**

Las entrevistas de validación cualitativa en campo demostraron una alta aceptación y adaptabilidad por parte de administradores y mecánicos. Se comprobó que el registro fotográfico pericial al momento del ingreso previene controversias con los propietarios de automóviles, mientras que el cronometraje directo de labores en bahía y la emisión inmediata de reportes telemáticos en PDF transparentan la productividad y la calidad técnica del taller sin burocracia manual.

Por su parte, la evaluación heurística de experiencia de usuario estructurada bajo los principios de Jakob Nielsen, arquitectura de información y diseño inclusivo evidenció un cumplimiento sobresaliente en visibilidad del estado del sistema, coherencia con el vocabulario automotriz y prevención de errores en la manipulación de inventarios, comprobantes y presupuestos. Las sesiones permitieron identificar y afinar detalles ergonómicos clave, tales como el contraste en áreas oscuras de taller y la confirmación unificada de inicio y fin de faena en patio.

\newpage

**Recomendaciones y Siguientes Pasos del Roadmap de Producto**

Habiendo completado la totalidad del alcance constructivo del ecosistema Atelier Workshop, el equipo establece las siguientes recomendaciones estratégicas para la etapa de operación comercial y evolución del producto:

- **Fase de lanzamiento comercial y publicación en tiendas oficiales:**
  - Publicar la aplicación móvil multiplataforma en Google Play Store y Apple App Store tras completar las revisiones de cumplimiento de políticas de privacidad, permisos Bluetooth y georreferenciación.
  - Activar el entorno productivo definitivo de facturación electrónica con el Proveedor de Servicios Electrónicos ante la SUNAT y habilitar los cobros recurrentes en vivo mediante Stripe para la gestión comercial de suscripciones SaaS.
  - Ejecutar pruebas de carga, estrés y auditoría de seguridad continua sobre la infraestructura en la nube para acompañar el incremento progresivo de talleres suscritos.

- **Fase de expansión hacia Atelier Driver y gestión de flotas:**
  - Iniciar el desarrollo del producto digital complementario Atelier Driver orientado a conductores particulares y administradores de flotas vehiculares, habilitando el historial clínico digital del vehículo, el agendamiento remoto de citas y la recepción de alertas predictivas mediante Firebase Cloud Messaging.
  - Integrar tableros ejecutivos de fidelización que conecten las recomendaciones de mantenimiento preventivo generadas en taller con recordatorios automatizados hacia los propietarios de vehículos.

- **Fase de analítica predictiva avanzada y aprendizaje continuo:**
  - Aprovechar las series temporales acumuladas en las hipertablas de TimescaleDB para entrenar modelos analíticos especializados por marca, modelo y kilometraje, incrementando la precisión de las alertas tempranas de fallas mecánicas en el parque automotor regional.

\newpage
