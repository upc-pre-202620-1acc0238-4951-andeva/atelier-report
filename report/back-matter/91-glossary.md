# Glosario

El presente glosario establece las definiciones formales de los términos técnicos, metodológicos, arquitectónicos y de dominio utilizados a lo largo del informe. Su propósito es asegurar una comprensión homogénea y precisa de los conceptos que sustentan el diseño, la ingeniería y la operación del ecosistema Atelier.

- **ACL (Anticorruption Layer):** Patrón de diseño táctico que actúa como capa mediadora y traductora entre modelos de dominio diferentes. En Atelier, aísla la lógica interna del negocio frente a los modelos externos de facturación electrónica de Nubefact y pasarelas de pago de Stripe, impidiendo que conceptos tributarios o bancarios de terceros contaminen el núcleo del software.

- **Agregado (Aggregate):** Patrón táctico de diseño guiado por el dominio que encapsula un conjunto de entidades y objetos de valor tratados como una unidad atómica para la persistencia y la consistencia transaccional. Cada agregado posee una entidad raíz denominada raíz de agregado que custodia las invariantes y reglas de negocio del grupo.

- **Arquitectura Hexagonal:** Estilo arquitectónico, conocido también como patrón de puertos y adaptadores, que desacopla el núcleo del dominio de las tecnologías de infraestructura, frameworks y dependencias externas. El dominio interactúa con el exterior únicamente a través de interfaces denominadas puertos, las cuales son implementadas por adaptadores específicos para bases de datos, APIs web o protocolos de hardware.

- **Atelier Driver:** Aplicación móvil orientada a conductores particulares y administradores de flotas vehiculares dentro del ecosistema Atelier. Permite consultar el estado clínico del automóvil, agendar citas en talleres asociados y recibir notificaciones predictivas sobre averías mecánicas detectadas en tiempo real.

- **Atelier Workshop:** Plataforma integral orientada a los roles operativos y de gestión de talleres automotrices. Comprende una aplicación web de escritorio para finanzas, inventario valorizado y facturación, complementada por una aplicación móvil para mecánicos dotada de lectura telemétrica por Bluetooth, captura pericial de fotografías y funcionamiento sin conexión a internet.

- **BDD (Behavior-Driven Development):** Enfoque de ingeniería de software que promueve la colaboración multidisciplinaria mediante la definición del comportamiento del sistema en un lenguaje natural estructurado. En Atelier, las historias de usuario se especifican bajo la sintaxis Gherkin con cláusulas de contexto, evento y resultado para facilitar la automatización de pruebas de aceptación.

- **BeanOutputConverter:** Componente provisto por el framework Spring AI que analiza, valida y transforma la respuesta generada por un modelo de lenguaje en un objeto Java fuertemente tipado. En el sistema, garantiza que los diagnósticos emitidos por la inteligencia artificial se conviertan de manera determinista en estructuras de datos inmutables sin requerir análisis manual de texto.

- **BLE (Bluetooth Low Energy):** Especificación de comunicación inalámbrica de bajo consumo energético diseñada para la transmisión periódica de datos a corta distancia. En Atelier Workshop Mobile, permite establecer el enlace telemático entre el teléfono inteligente del mecánico y los escáneres OBD-II conectados al puerto del vehículo.

- **Bounded Context:** Límite conceptual y lingüístico explícito dentro del cual un modelo de dominio particular tiene plena validez y significado unívoco. En Atelier, el sistema se particiona en ocho contextos delimitados para aislar responsabilidades operativas, logísticas, tributarias y telemáticas sin incurrir en modelos sobrecargados.

- **C4 Model:** Marco de modelado gráfico jerárquico para la documentación de arquitecturas de software mediante cuatro niveles de abstracción progresiva: contexto del sistema, contenedores, componentes y código. Facilita la comunicación de la estructura técnica ante diversas audiencias técnicas y gerenciales.

- **Caffeine Cache:** Biblioteca de caché local de alto rendimiento en memoria para la plataforma Java. En la arquitectura backend de Atelier, se implementa para reducir la latencia y aliviar las consultas a la base de datos central en módulos de lectura intensiva como permisos de usuario, planes de suscripción y catálogos de servicios.

- **Context Mapping:** Técnica estratégica de diseño guiado por el dominio que documenta visual y estructuralmente las relaciones e integraciones entre los distintos contextos delimitados de una solución. Describe patrones de interacción como cliente y proveedor, capa anticorrupción, conformista y núcleo compartido.

- **CQRS (Command Query Responsibility Segregation):** Patrón arquitectónico que separa de forma explícita las operaciones de modificación de estado respecto a las operaciones de lectura y consulta de datos. Permite optimizar el procesamiento transaccional mediante agregados de dominio y acelerar la recuperación de información mediante proyecciones ligeras e inmutables sin sobrecarga de frameworks de persistencia.

- **Customer Journey Map:** Herramienta de diseño de experiencia que representa cronológicamente las etapas, interacciones, emociones y puntos de contacto que atraviesa un usuario al interactuar con un servicio o producto digital. Permite identificar dificultades operativas y oportunidades de mejora en los flujos de trabajo.

- **Direct-to-Cloud:** Patrón de arquitectura que delega la subida de archivos pesados, como imágenes o documentos binarios, directamente desde la aplicación cliente hacia un servicio de almacenamiento en la nube sin intermediación del servidor de aplicaciones. En Atelier, las fotos de evidencias mecánicas se cargan desde el dispositivo móvil hacia Firebase Storage, enviando al backend únicamente el identificador y la URL segura del recurso.

- **DTC (Diagnostic Trouble Code):** Código alfanumérico estandarizado bajo normas internacionales como SAE J2012 e ISO 15031-6, generado por las unidades de control electrónico de un vehículo cuando detectan una anomalía funcional en sus circuitos o componentes mecánicos.

- **ELM327:** Microcontrolador programado ampliamente difundido que actúa como puente de conversión entre los protocolos de comunicación automotriz a nivel de hardware y las interfaces estándar de comunicación serie, Bluetooth o WiFi.

- **Empathy Map:** Artefacto visual de diseño centrado en el usuario que sintetiza el comportamiento de un arquetipo específico, analizando lo que dice, hace, piensa y siente en su entorno cotidiano. Ayuda al equipo a identificar necesidades implícitas y motivaciones de uso.

- **EventStorming:** Taller colaborativo de modelado rápido y exploración del dominio que reúne a expertos de negocio y desarrolladores de software para reconstruir la línea de vida de un sistema mediante eventos de dominio pasados, comandos, políticas reactivas y agregados.

- **FIFO (First-In, First-Out):** Método de valuación de inventario y gestión contable que establece que los primeros bienes adquiridos o producidos son los primeros en ser consumidos o descargados. En Atelier, garantiza que cada repuesto o fluido utilizado en una orden de trabajo descuente su costo de adquisición exacto a partir del lote físico correspondiente.

- **Fórmula del Haversine:** Ecuación trigonométrica que calcula la distancia ortodrómica sobre la superficie de una esfera entre dos puntos geográficos definidos por sus coordenadas de latitud y longitud. En Atelier, el backend la emplea para validar si el registro de asistencia del personal técnico se produce dentro del radio geográfico autorizado para la sucursal del taller.

- **Gherkin:** Lenguaje específico de dominio estructurado y legible por humanos que emplea palabras clave estandarizadas como Dado, Cuando y Entonces para describir escenarios de comportamiento de software verificables de forma automatizada.

- **Groq Cloud LPU:** Plataforma de aceleración de hardware e inferencia ultrarrápida impulsada por unidades de procesamiento de lenguaje. En Atelier, ejecuta el modelo fundacional Llama 3.3 70B para traducir parámetros sensoriales y averías en diagnósticos mecánicos causales estructurados con mínima latencia.

- **Hipertabla (Hypertable):** Abstracción relacional provista por la extensión TimescaleDB para PostgreSQL que particiona de forma automática y transparente tablas temporales masivas en fragmentos discretos según intervalos de tiempo. Facilita la ingesta continua de telemetría automotriz de alta frecuencia y permite la compresión columnar eficiente sin degradar el rendimiento del motor de base de datos.

- **Impact Mapping:** Técnica gráfica de planificación estratégica que vincula los objetivos de negocio de una organización con los actores involucrados, los impactos deseados en su comportamiento y los entregables de software necesarios para materializarlos.

- **Lean UX:** Enfoque de diseño de experiencia centrado en la reducción de desperdicios y la validación rápida de supuestos mediante ciclos iterativos de formulación de hipótesis, experimentación y aprendizaje colaborativo.

- **Llama 3.3 70B:** Modelo de lenguaje fundacional de código abierto desarrollado por Meta con setenta mil millones de parámetros. En Atelier, se utiliza para analizar series de tiempo de telemetría, inferir degradación de componentes mecánicos y emitir explicaciones diagnósticas en lenguaje natural comprensible para el conductor y el jefe de taller.

- **MRO (Maintenance, Repair, and Operations):** Conjunto de actividades destinadas a la gestión, mantenimiento preventivo, reparación correctiva y operaciones técnicas en instalaciones y equipos. En Atelier, da nombre al contexto delimitado responsable de controlar el ciclo de vida de las citas, bahías de trabajo, órdenes de reparación y tareas mecánicas.

- **Multi-Tenancy:** Principio de arquitectura de software en el cual una única instancia de aplicación y de base de datos sirve a múltiples organizaciones o clientes independientes denominados inquilinos. Garantiza el aislamiento lógico estricto de los datos de cada taller mediante identificadores unívocos en cada transacción.

- **Needfinding:** Metodología cualitativa de investigación enfocada en identificar necesidades humanas latentes, motivaciones y dificultades cotidianas de los usuarios en su propio entorno operativo a través de observación directa y entrevistas a profundidad.

- **Nubefact:** Plataforma externa proveedora de servicios de facturación electrónica autorizada que procesa comprobantes fiscales digitales y los valida ante la Superintendencia Nacional de Aduanas y de Administración Tributaria. En Atelier, se integra a través de una Capa Anticorrupción para la generación de boletas y facturas electrónicas.

- **OBD-II (On-Board Diagnostics II):** Estándar internacional de diagnóstico automotriz obligatorio en vehículos modernos que regula el puerto físico de conexión, los protocolos de comunicación eléctrica y el formato de datos para la monitorización de emisiones y parámetros del motor.

- **Offline-First:** Paradigma de desarrollo de software que diseña las aplicaciones para operar con plena funcionalidad en ausencia de conexión a internet, almacenando los datos de forma local y resolviendo la sincronización con el servidor remoto en segundo plano cuando la red vuelve a estar disponible.

- **PID (Parameter Identification):** Código numérico de consulta hexadecimal estandarizado utilizado para solicitar lecturas de parámetros sensoriales en tiempo real desde las computadoras de a bordo de un vehículo, tales como velocidad de desplazamiento, revoluciones del motor, temperatura del refrigerante y voltaje eléctrico de la batería.

- **PLAME (Planilla Mensual de Pagos):** Aplicativo informático oficial de la administración tributaria peruana utilizado por los empleadores para declarar mensualmente las remuneraciones, aportes de seguridad social y retenciones del personal. Atelier genera archivos de texto estructurado compatibles para la carga masiva de planillas hacia este sistema.

- **Product Backlog:** Lista ordenada y viva de todos los requisitos, funcionalidades, mejoras técnicas y correcciones que constituyen el alcance proyectado de un producto de software. En Atelier, se organiza jerárquicamente a través de épicas, historias de usuario e historias técnicas.

- **Resend:** Servicio de entrega de correo electrónico transaccional sustentado en una API web basada en HTTPS. En Atelier, se emplea para notificaciones asíncronas como invitaciones a miembros del taller, códigos de verificación de dos factores y envío de reportes periciales o comprobantes en formato PDF.

- **Room:** Biblioteca de persistencia relacional oficial de Android Jetpack que proporciona una capa de abstracción fluida sobre el motor SQLite local. En Atelier Workshop Mobile, garantiza verificación de consultas SQL en tiempo de compilación y flujos de datos asíncronos reactivos para la operatividad sin conexión.

- **SaaS (Software as a Service):** Modelo de distribución y licenciamiento de software en el cual las aplicaciones son hospedadas en la nube y comercializadas a los clientes mediante suscripciones periódicas bajo demanda.

- **Shallow Routing:** Enfoque de diseño de APIs RESTful que evita el anidamiento excesivo de identificadores de recursos en las rutas URL. En Atelier, permite a los mecánicos acceder a recursos operados en foso mediante rutas cortas de segundo nivel para reducir la complejidad en las llamadas de red.

- **Spring AI:** Framework de integración para el ecosistema Java y Spring Boot que abstrae la conexión con modelos de inteligencia artificial generativa, facilitando el intercambio de proveedores y modelos sin acoplar la arquitectura a SDKs específicos.

- **Stripe:** Plataforma global de procesamiento de pagos e infraestructura financiera en la nube. En Atelier, se utiliza para la gestión automatizada de cobros recurrentes de suscripciones SaaS de los talleres hacia la empresa operadora.

- **SUNAT:** Superintendencia Nacional de Aduanas y de Administración Tributaria del Perú, organismo público responsable de la recaudación fiscal, supervisión aduanera y regulación de los estándares de comprobantes de pago electrónicos.

- **Sync Queue:** Mecanismo de cola asíncrona local persistido en base de datos que almacena las mutaciones y eventos generados por el usuario mientras el dispositivo móvil carece de red. Un trabajador en segundo plano procesa la cola de forma secuencial al recuperar la conectividad.

- **Task Proposal:** Propuesta técnica registrada por un mecánico al detectar una avería imprevista durante la inspección del automotor en elevador o fosa. Permite adjuntar evidencia fotográfica pericial para que el asesor de servicio elabore un presupuesto formal y solicite autorización al cliente antes de ejecutar la labor.

- **TimescaleDB:** Extensión de código abierto para PostgreSQL optimizada para la ingesta masiva, compresión y consulta analítica de datos en series temporales mediante hipertablas automatizadas.

- **Transactional Outbox Pattern:** Patrón de diseño para arquitecturas distribuidas que garantiza la consistencia eventual entre la base de datos local y la publicación de eventos hacia sistemas externos. Almacena los eventos como registros en una tabla de mensajes pendientes dentro de la misma transacción transaccional y los despacha de forma asíncrona mediante un componente de reintento.

- **UBL 2.1 (Universal Business Language):** Biblioteca estándar internacional de esquemas XML diseñada para el intercambio electrónico de documentos comerciales, adoptada oficialmente por la administración tributaria para boletas, facturas, notas de crédito y guías de remisión.

- **Ubiquitous Language (Lenguaje Ubicuo):** Vocabulario formal riguroso y compartido entre los ingenieros de software y los especialistas del dominio del negocio, empleado de manera consistente en la conversación diaria, la documentación técnica y el código fuente del sistema.

- **User Persona:** Arquetipo descriptivo construido a partir de datos cualitativos y cuantitativos reales que representa los patrones de comportamiento, objetivos, frustraciones y competencias de un segmento específico de usuarios.

- **User Story (Historia de Usuario):** Descripción breve y funcional de un requisito de software expresada desde la perspectiva del usuario final, formulada bajo la estructura de rol, deseo y beneficio esperado, acompañada de criterios de aceptación verificables.

- **User Task Matrix:** Matriz analítica que desglosa y clasifica las tareas que cada perfil de usuario ejecuta en el sistema, evaluando su frecuencia, criticidad y nivel de soporte que la plataforma digital debe suministrar.

\newpage