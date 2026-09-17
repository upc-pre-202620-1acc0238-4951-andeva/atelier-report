# Conclusiones y Recomendaciones

El diagnóstico de la problemática automotriz y el contraste empírico permitieron validar que los talleres MYPE de reparación vehicular en el entorno urbano operan bajo un modelo reactivo caracterizado por una marcada desarticulación entre las labores mecánicas de patio y la gobernanza administrativa y contable.

En relación al segmento de Personal de Gestión y Propietarios de Talleres, se corroboró que la ausencia de trazabilidad en las compras genera discrepancias financieras sistemáticas, fuga de liquidez y márgenes imprecisos al liquidar servicios. Los dueños y administradores requieren con urgencia un entorno web centralizado de escritorio que unifique la emisión de facturación electrónica bajo normativa SUNAT UBL 2.1, el control de inventario valorizado y la liquidación consolidada de órdenes de trabajo, eliminando la dispersión de información en planillas aisladas o registros manuales.

En cuanto al segmento de Personal Operativo del Taller, que abarca a técnicos mecánicos y asesores de servicio, se constató que la operatividad en fosos y elevadores se ve entorpecida por la manipulación de órdenes físicas de trabajo propensas al deterioro por grasas y solventes, la dificultad de registrar evidencias visuales del estado de desarme y la falta de un canal ágil para comunicar averías ocultas imprevistas. El equipo comprobó que los mecánicos precisan una aplicación móvil de uso rudo que funcione como su única herramienta de patio, capacitada para capturar evidencia fotográfica pericial directa a la nube, consultar catálogos de repuestos y ejecutar diagnósticos computarizados mediante escáneres OBD-II por Bluetooth.

**Conclusiones respecto a la Validación de Supuestos**

El proceso de validación cualitativa aportó evidencia para contrastar los supuestos de negocio y tecnológicos formulados durante la concepción de la solución:

- **Supuesto de conectividad en taller:** Se asumió inicialmente que los talleres dispondrían de cobertura inalámbrica continua y de alta velocidad en toda la extensión de sus instalaciones. La investigación de campo refutó este supuesto, evidenciando que el 49.1% del personal técnico accede a redes móviles de forma intermitente y que las fosas subterráneas de inspección presentan pérdidas totales de señal por blindaje estructural. Este hallazgo validó de forma concluyente la necesidad crítica de una arquitectura Offline-First en la aplicación móvil, implementando almacenamiento local relacional con SQLite mediante Room en Android y Drift en Flutter, sincronizado con colas de eventos en segundo plano cuando se restablece la conexión.

- **Supuesto de equipamiento telemático:** Se contempló originalmente que la telemetría automotriz requeriría hardware propietario de alto costo, lo cual representaría una barrera económica de adopción. La validación demostró que la viabilidad del modelo descansa en la interoperabilidad con adaptadores estándar OBD-II genéricos bajo protocolo ELM327 acoplados a Bluetooth Low Energy, empleando el propio teléfono inteligente del mecánico como nodo gateway telemático, garantizando accesibilidad y bajo costo de despliegue.

- **Supuesto de costeo de repuestos:** Se confirmó el supuesto de que un control tradicional de inventario resulta insuficiente ante la volatilidad de precios en repuestos y lubricantes importados. La validación demostró que la dispersión de costos exige un método de costeo estricto bajo el método FIFO por lote físico, garantizando que cada repuesto descontado en una orden de trabajo compute con exactitud el valor de adquisición del lote correspondiente.

**Conclusiones respecto a las Hipótesis de Solución y Criterios de Éxito**

Las hipótesis planteadas en el proceso Lean UX se contrastaron con los artefactos de diseño y las necesidades declaradas por los usuarios:

- **Hipótesis de telemetría predictiva e inferencia con inteligencia artificial:** Se formuló que la captura continua de parámetros sensoriales PIDs y códigos de falla DTC bajo normas SAE J2012 e ISO 15031-6, combinada con modelos de lenguaje fundacionales, permitiría anticipar averías mecánicas complejas y elevar la confianza del cliente. El diseño del pipeline con Spring AI, Groq Cloud LPU y el modelo fundacional Llama 3.3 70B demostró la factibilidad técnica de emitir diagnósticos periciales causales en menos de un segundo y generar reportes clínicos en formato PDF con OpenPDF y Thymeleaf, cumpliendo el criterio de éxito de reducir el tiempo de diagnóstico inicial y transparentar la comunicación técnica.

- **Hipótesis de trazabilidad en propuestas de tareas:** Se propuso que permitir a los mecánicos registrar averías ocultas como propuestas técnicas con evidencia fotográfica directa a Firebase Storage, mediadas por el asesor de servicio ante el cliente, erradicaría la percepción de cobros arbitrarios. La validación reflejó que la demostración fotográfica objetiva incrementa significativamente la tasa de aprobación de mantenimientos correctivos complementarios.

- **Criterios de viabilidad arquitectónica y económica:** Se comprobó que la arquitectura orquestada sobre servicios en la nube de alta disponibilidad, desplegada en plataformas como Render para la API REST, Aiven para PostgreSQL y TimescaleDB, Groq Cloud LPU, Firebase y Resend, satisface los requerimientos de resiliencia, neutralidad de proveedores y sostenibilidad económica para el modelo de negocio SaaS.

**Conclusiones del Diseño Arquitectónico y Estrategia Táctica**

El modelado estratégico bajo Domain-Driven Design permitió descomponer la complejidad operativa del taller en ocho Bounded Contexts cohesivos, articulados en IAM & Tenancy, Customer & Fleet Management, Workshop Operations MRO, Inventory & Supply Chain, Human Resources Management, Invoicing & Compliance, SaaS Billing & Subscriptions, e IoT Telemetry & Predictive Maintenance. Este aislamiento previno la proliferación de modelos saturados de datos y delimitó responsabilidades inequívocas.

Asimismo, la aplicación de patrones tácticos demostró solidez técnica en todos los niveles. La arquitectura hexagonal desacopló la lógica de negocio pura de las dependencias de persistencia y servicios externos. La Capa Anticorrupción protegió el dominio contable frente a los esquemas tributarios de Nubefact y bancarios de Stripe. A su vez, el patrón Transactional Outbox garantizó la consistencia eventual durante la emisión de comprobantes y procesamiento de cobros. Finalmente, la formulación de 10 Épicas y 32 Historias de Usuario bajo sintaxis BDD Gherkin provee una base estructurada y orientada a pruebas automatizadas para el ciclo de desarrollo.

**Recomendaciones y Siguientes Pasos del Roadmap de Producto**

A partir de los resultados y lecciones aprendidas durante la etapa de diseño, el equipo establece las siguientes recomendaciones estructuradas según el roadmap de producto:

- **Etapa de implementación inmediata para Atelier Workshop:**
  - Priorizar el despliegue del Landing Page institucional enfocado en la captación y registro preliminar de talleres automotrices interesados.
  - Ejecutar la construcción del núcleo transaccional de la API en Render, asegurando una cobertura funcional del backend en los módulos críticos de autenticación multi-tenant en IAM, órdenes de trabajo en MRO y gestión de lotes de inventario FIFO.
  - Implementar los esquemas locales de persistencia relacional SQLite mediante Room en Android nativo y Drift en multiplataforma, validando la sincronización reactiva en segundo plano para condiciones de foso sin cobertura de red.
  - Implementar el cálculo perimétrico de geocercas mediante la fórmula del Haversine y Google Places API para la validación satelital de asistencia del personal de taller.

\newpage

- **Etapa de consolidación y validación de campo:**
  - Completar el despliegue integral del backend con especificación OpenAPI pública y contratos de integración documentados.
  - Integrar la Capa Anticorrupción de facturación electrónica con el entorno de pruebas de Nubefact para la generación formal de boletas y facturas electrónicas UBL 2.1 ante SUNAT.
  - Desplegar el motor de inferencia telemétrica con Spring AI y Groq Cloud LPU, validando la emisión de diagnósticos automatizados mediante simuladores de hardware OBD-II Bluetooth.
  - Conducir sesiones de prueba de usabilidad en entornos reales de taller automotriz para calibrar la ergonomía de la interfaz móvil en condiciones operativas exigentes como reflejo de luz solar, manipulación con guantes y presencia de grasas.

- **Etapa de expansión del ecosistema para Atelier Driver:**
  - Iniciar el desarrollo de la aplicación móvil para conductores y administradores de flotas vehiculares, habilitando el expediente clínico digital del automóvil, la recepción de alertas predictivas push por Firebase FCM y el agendamiento directo de citas de servicio, apalancándose en los puntos de integración desacoplados definidos en la arquitectura.

\newpage