### 2.5.3. *Software Architecture*

En esta sección el equipo presenta y explica la representación, aplicando **C4 Model**, de la Arquitectura de Software para la solución del ecosistema **Atelier**, incluyendo todos los productos que forman parte de su alcance. **Atelier** es un ecosistema SaaS puro y hardware agnostic diseñado para transformar los talleres automotrices integrando capacidades de ERP, MRO y telemetría IoT predictiva.

El modelado arquitectónico abarca las aplicaciones principales del ecosistema:

**Atelier Workshop:** Plataforma orientada al sector B2B que unifica al segmento personal de gestión y propietarios y al segmento de personal operativo mediante control de acceso basado en roles. Se encuentra disponible tanto en versión de aplicación web como en aplicación móvil, garantizando que los administradores puedan gestionar el taller desde su escritorio o supervisar la operación en patio desde su teléfono celular, mientras los técnicos disponen de movilidad y lectura telemétrica en la zona de bahías.

**Atelier Driver:** Aplicación móvil B2C orientada a los clientes finales para la gestión de citas, aprobación de presupuestos y recepción de alertas predictivas IoT.

Para lograr un sistema escalable, mantenible y resiliente ante las condiciones adversas de conectividad de los talleres, la arquitectura orquesta un robusto backend centralizado en Java 24 con Spring Boot y bases de datos híbridas. En el lado del cliente, las aplicaciones móviles implementan obligatoriamente un patrón offline-first, apoyándose en cachés locales y colas de sincronización asíncrona gestionadas por *background workers* para evitar la pérdida de telemetría y garantizar la operatividad en fosos sin cobertura. Finalmente, el ecosistema delega operaciones de misión crítica a plataformas de terceros mediante patrones tácticos.

A continuación, se incluyen como subsecciones internas los diagramas a nivel de contexto, a nivel de contenedores y los diagramas de despliegue que detallan las interacciones, las tecnologías y la infraestructura de nuestra plataforma tecnológica.

#### 2.5.3.1. Software Architecture Context Level Diagrams

En esta sección se presenta el **Context Level Diagram** para el ecosistema Atelier. Este diagrama modela al sistema en el centro, rodeado de sus usuarios principales y de los sistemas de software externos con los que colabora para proporcionar toda la funcionalidad requerida.

Como se puede observar, el sistema se integra de manera estratégica con hardware de telemetría IoT, procesadores de pago, sistemas de facturación electrónica y servicios en la nube clave de Firebase y Google. Esto permite delegar responsabilidades específicas y mantener un *Core Domain* altamente cohesivo.

![System Context Diagram para el ecosistema de Atelier](report/assets/c4-diagrams/context-level-diagram-atelier.png){#fig:context-level-diagram-atelier}

#### 2.5.3.2. Software Architecture Container Level Diagrams

En esta sección, se presenta el **Container Level Diagram** para el ecosistema Atelier. Este diagrama ilustra los límites del sistema central y descompone su arquitectura en las unidades ejecutables y desplegables de software, detallando cómo se distribuyen las responsabilidades de negocio, las tecnologías seleccionadas y los protocolos de comunicación utilizados tanto internamente como con las plataformas externas.

Para materializar la visión de un SaaS automotriz de alta resiliencia y bajo costo operativo, la arquitectura de Atelier adopta un enfoque de monolito en el backend complementado por clientes frontend especializados y una capa de persistencia híbrida.

![Container Level Diagram para el ecosistema Atelier](report/assets/c4-diagrams/container-level-diagram-atelier.png){#fig:container-level-diagram-atelier}

A continuación, se detalla la responsabilidad, el stack tecnológico y las decisiones arquitectónicas de cada uno de los contenedores que conforman la solución:

| **Contenedor** | **Tecnología** | \centering \textbf{Responsabilidad y Decisiones de Diseño} |
| :---: | :---: | :--- |
| Landing Page | HTML5, CSS3, TypeScript | Sitio web estático público. Comunica la propuesta de valor del ecosistema, planes de suscripción para talleres, catálogo de funcionalidades de telemetría y testimonios, proporcionando llamadas a la acción hacia el registro de talleres en la WebApp. |
|Web Application | Angular 20, TypeScript, Angular Material | SPA para el Personal de Gestión (dueños y administradores) y recepcionistas. Provee dashboards de rentabilidad, administración multi-tenant, control de membresías del personal, catálogo de inventario bajo costeo FIFO, facturación y gestión de citas. |
| Mobile Workshop | Kotlin (Room), Flutter (sqflite) | Aplicación móvil para el Personal del Taller (Gestión y Operativo) unificada mediante RBAC. Permite a dueños y administradores supervisar el taller y aprobar presupuestos desde el móvil, y al personal operativo ejecutar tareas MRO, escaneo Bluetooth de OBD2 y registro fotográfico con soporte offline-first. |
| Mobile Driver | Flutter (sqflite) | Aplicación móvil para los Propietarios de Vehículos (particulares y flotas). Permite el seguimiento del estado de salud vehicular en tiempo real, recepción de alertas predictivas telemétricas, aprobación digital de presupuestos MRO y reserva de citas en el taller. |
| API Application | Java 24, Spring Boot, Caffeine Cache | Monolito modular centralizado desplegado en Render. Orquesta la lógica de negocio de los Bounded Contexts mediante DDD, Clean Architecture, CQRS, ACL y Outbox Pattern. Expone servicios RESTful, maneja autenticación JWT/OAuth y procesa telemetría. |
| Database | PostgreSQL 16, TimescaleDB | Almacén central de datos multi-tenant en Aiven Cloud. Combina persistencia relacional transaccional con hipertablas de series de tiempo optimizadas para compresión masiva de telemetría IoT. |
: Catálogo de Contenedores del Ecosistema Atelier {#tbl:c4-containers-catalog}

**Decisiones y Patrones Arquitectónicos del Backend**

El contenedor central **API Application** ha sido diseñado bajo los más rigurosos estándares de ingeniería de software empresarial para garantizar escalabilidad, desacoplamiento y mantenibilidad:

1. **Monolito Modular y Domain-Driven Design:** En lugar de incurrir en la sobrecarga operativa y de red de los microservicios distribuidos en etapas tempranas, Atelier organiza su código en módulos fuertemente cohesionados que representan los bounded contexts del negocio. La comunicación intermodular en memoria previene la latencia distribuida y reduce costos de infraestructura.

2. **Clean Architecture (Hexagonal / Ports and Adapters):** Cada módulo aísla su núcleo de dominio puro de los frameworks y dependencias externas mediante interfaces. La infraestructura implementa estos puertos, permitiendo sustituir componentes tecnológicos sin afectar las políticas de negocio.

3. **Command Query Responsibility Segregation:** El sistema separa explícitamente las operaciones de modificación de estado de las operaciones de lectura, facilitando la optimización independiente de las consultas.

4. **Anti-Corruption Layer:** Para interactuar con sistemas y estándares heterogéneos externos, el backend implementa capas anticorrupción que traducen los payloads foráneos al modelo de dominio interno de Atelier, impidiendo que cambios en APIs de terceros degraden el diseño del sistema.

5. **Transactional Outbox Pattern:** Para garantizar la consistencia eventual sin recurrir a costosos bloqueos distribuidos, cualquier evento de negocio que deba disparar una acción externa se registra transaccionalmente en la tabla *outbox_messages* de PostgreSQL dentro de la misma transacción local del evento. Un procesador asíncrono en segundo plano lee y despacha los mensajes, garantizando entrega confiable incluso ante fallos de red.

6. **Caché en Memoria con Caffeine:** Se implementa una capa de almacenamiento en memoria dentro del proceso de Spring Boot para datos de alta frecuencia de lectura y baja tasa de cambio, reduciendo drásticamente las consultas hacia Aiven Cloud.

**Estrategia de Conectividad, Resiliencia y Servicios Externos**

* **Estrategia Offline-First en la Aplicación Móvil:** Considerando que el 49.1% de usuarios móviles en el entorno local carece de plan de datos continuo y que los fosos de reparación automotriz presentan nula cobertura de red, la aplicación móvil **Atelier Workshop** almacena catálogos y órdenes de trabajo en una base de datos local relacional SQLite. Las modificaciones se encolan en una cola de eventos pendientes mediante *Sync Queue*. Un *background worker* detecta la reconexión a redes Wi-Fi o datos móviles para enviar los datos en bloque (*Batching*) hacia la API central.

* **Patrón Direct-to-Cloud para Almacenamiento:** Para evitar cuellos de botella en el servidor backend derivados de la transferencia de archivos multimedia pesados, la aplicación móvil **Atelier Workshop** sube las imágenes directamente a los buckets seguros de **Firebase Cloud Storage**, registrando únicamente las URLs firmadas en la API Application.

* **Comunicaciones vía API HTTPS:** La integración con **Resend** mediante peticiones HTTPS REST asegura que el backend alojado en Render pueda enviar invitaciones de onboarding, códigos de verificación de 6 dígitos (OTP) y boletas electrónicas sin verse afectado por las restricciones de puertos SMTP tradicionales de las capas gratuitas en la nube.

#### 2.5.3.3. Software Architecture Component Level Diagrams

En esta sección, se presentan los **Software Architecture Component Level Diagrams** para los contenedores fundamentales del ecosistema Atelier, siguiendo las directrices del modelo C4 en su Nivel 3. Este nivel de abstracción descompone los contenedores en sus módulos y unidades funcionales constitutivas, ilustrando sus dependencias internas y la forma en que interactúan tanto con el usuario como con la infraestructura circundante.

##### 2.5.3.3.1. API Application Component Level Diagram

Para el contenedor principal del backend, la **API Application**, se ilustra la descomposición interna del sistema centralizado en sus módulos funcionales y componentes de infraestructura transversal:

El backend de Atelier adopta una arquitectura de monolito modular guiada por los principios de Domain-Driven Design y Clean Architecture. Siguiendo las directrices del modelo C4 en su Nivel 3, el contenedor central **API Application** se descompone internamente en módulos funcionales de negocio, cada uno de los cuales encapsula y materializa uno de los 8 bounded contexts delimitados en la arquitectura estratégica de dominio, complementados por componentes de infraestructura transversal que proveen resiliencia y optimización sin constituir dominios de negocio independientes.

![Component Level Diagram para la API de Atelier](report/assets/c4-diagrams/component-level-diagram-api.png){#fig:component-level-diagram-api}

A continuación, se detalla el catálogo de componentes internos que estructuran el contenedor central:

| **Componente** | **Tipo y Tecnología** | **Dominio** | \centering \textbf{Responsabilidad y Decisiones de Diseño} |
| :---:| :---: | :---: | :--- |
| IAM y Tenancy Module | Spring Security, JJWT | Bounded Context: IAM & Tenancy | Control de acceso basado en roles, aislamiento multi-tenant por *tenant_id*, autenticación mediante tokens JWT y orquestación del flujo de onboarding del personal del taller. |
| Customer y Fleet Module | Spring Service, Spring Data JPA | Bounded Context: Customer & Fleet Management | Administración de fichas de clientes particulares, flotas comerciales, perfiles de vehículos y gestión del ciclo de vida de reservas y citas previas a la orden de trabajo. |
| Workshop Operations Module | Spring Service, CQRS, JPA | Bounded Context: Workshop Operations | Orquestación del flujo de trabajo automotriz: apertura y cierre de Órdenes de Trabajo, asignación de bahías y mecánicos, desglose de tareas, tramitación de propuestas de averías ocultas y registro pericial de evidencias fotográficas. |
| Inventory y Supply Chain Module | Spring Service, FIFO Engine, JPA | Bounded Context: Inventory & Supply Chain | Gestión del catálogo de repuestos y fluidos, valuación estricta de salidas mediante costeo FIFO por lotes y directorio ágil de compras a proveedores con registro documental. |
| Human Resources Module | Spring Service, Haversine Engine | Bounded Context: Human Resources Management | Control de turnos, cálculo de planillas de mecánicos y verificación algorítmica de asistencia mediante geocercas GPS aplicando la fórmula matemática del Haversine. |
| Invoicing y Compliance Module | Spring Service, ACL Nubefact | Bounded Context: Invoicing & Compliance | Generación y anulación de comprobantes electrónicos con validez tributaria ante SUNAT (estándar UBL 2.1), encapsulado detrás de una Capa Anticorrupción hacia la API de Nubefact. |
| SaaS Billing Module | Spring Service, Stripe SDK, ACL | Bounded Context: SaaS Billing & Subscriptions | Gestión de suscripciones y planes comerciales del SaaS para talleres, procesamiento de cobros recurrentes y validación de webhooks con idempotencia mediante el SDK de Stripe. |
| IoT Telemetry Module | Spring Service, Timescale Client | Bounded Context: IoT Telemetry & Predictive Maintenance | Ingesta masiva de telemetría vehicular proveniente de escáneres OBD-II, evaluación analítica de anomalías y disparo de notificaciones push predictivas vía FCM. |
| Transactional Outbox Worker | Spring Scheduled, Spring Events | Infraestructura Transversal | Procesa asíncronamente los eventos registrados en la tabla *outbox_messages*, garantizando entrega confiable hacia plataformas externas como Nubefact y Resend sin bloqueos distribuidos. |
| Caffeine Cache Manager | Caffeine Cache, Spring Cache | Infraestructura Transversal | Capa de almacenamiento en memoria dentro del proceso de la JVM para optimizar consultas de alta frecuencia de lectura, minimizando latencia y consultas a la base de datos. |
: Catálogo de Componentes de la API Application de Atelier {#tbl:c4-api-components-catalog}

**Mecanismos de Comunicación e Integración Intermodular del Backend**

La interacción entre los componentes del backend sigue patrones rigurosos para salvaguardar la cohesión y el bajo acoplamiento:

1. **Comunicación Síncrona en Memoria e Invocación Tipada:** Para operaciones que requieren consistencia inmediata entre módulos, la invocación se realiza mediante interfaces tipadas en memoria, eliminando el coste de serialización y la latencia de red.

2. **Desacoplamiento Mediante Eventos de Dominio Locales:** Cuando una tarea técnica demanda repuestos, el módulo *Workshop Operations* publica un evento de dominio interno. El módulo *Inventory & Supply Chain* captura dicho evento y reserva las existencias requeridas bajo la política FIFO por lotes dentro de la misma transacción ACID de PostgreSQL, consolidándose en descuento definitivo al liquidar el pago de la orden.

3. **Capas Anticorrupción:** Los módulos *Invoicing & Compliance* y *SaaS Billing* implementan adaptadores ACL que traducen las estructuras externas de Nubefact y Stripe hacia el modelo conceptual propio de Atelier, impidiendo que cambios en especificaciones fiscales o bancarias degraden la lógica de negocio interna.

4. **Despacho Confiable con Transactional Outbox:** Cualquier acción que requiera notificar al exterior, emisión de boletas fiscales o envío de correos vía **Resend**, se registra en la tabla *outbox_messages* como parte atómica de la transacción. El componente *Transactional Outbox Worker* efectúa el polling y reintentos automáticos, asegurando la consistencia eventual frente a interrupciones en la conectividad con terceros.

##### 2.5.3.3.2. Web Application Component Level Diagram

Para el portal administrativo del ecosistema, la **Web Application**, se ilustra la descomposición interna de la Single Page Application desarrollada en Angular 20, TypeScript y Angular Material. La aplicación opera como el centro de mando principal para el personal de gestión y recepcionistas.

Su diseño interno se basa en una arquitectura modular por características con componentes autónomos, reactividad impulsada por signals y *RxJS*, y una estricta separación de responsabilidades entre presentación, estado y comunicación con el backend.

![Component Level Diagram para la Web Application de Atelier](report/assets/c4-diagrams/component-level-diagram-webapp.png){#fig:component-level-diagram-webapp}

A continuación, se detalla el catálogo de componentes que estructuran la aplicación web:

| **Componente** | **Tipo y Tecnología** | \centering \textbf{Responsabilidad y Decisiones de Diseño} |
| :---: | :---: | :--- |
| Auth y Tenancy Guard | Angular Guard, HttpInterceptor | Intercepta peticiones HTTP para inyectar el token JWT y el encabezado *X-Tenant-ID*, valida privilegios de ruta según el rol activo y gestiona el refresco silencioso de sesiones. |
| Multi-Tenant Shell | Standalone Component, Angular Material | Proporciona la estructura visual principal: navegación lateral responsiva, barra superior de notificaciones y selector dinámico de sucursales para talleres multi-sede. |
| Executive Dashboard Component | Standalone Component, Charts | Renderiza indicadores clave de rendimiento, gráficas de ingresos, volumen de órdenes MRO y márgenes financieros del taller en tiempo real. |
| MRO Operations Console | Standalone Component, Drag & Drop | Tablero de control operativo para la supervisión de bahías de trabajo, cambio visual de estados de órdenes mecánicas y asignación de tareas a técnicos. |
| Inventory y FIFO Manager | Standalone Component, Angular Material | Interfaz para la gestión del catálogo de repuestos y fluidos, trazabilidad visual de lotes según costeo FIFO y registro documental de compras a proveedores. |
| Invoicing y SUNAT Billing | Standalone Component, Angular Material | Módulo de facturación electrónica: emisión y anulación de facturas o boletas UBL 2.1, consulta de estados tributarios validados ante SUNAT y descarga directa de archivos XML y PDF. |
| SaaS Subscription y Checkout | Standalone Component, Stripe.js | Panel de administración de suscripciones SaaS del taller e integración con el SDK cliente *Stripe.js* para tokenización directa de tarjetas bancarias conforme al estándar PCI-DSS. |
| HR y Staff Management | Standalone Component, Google Maps | Gestión de contratos, asignación de turnos laborales, cálculo de nóminas y visualización cartográfica de asistencias validadas mediante geocercas GPS. |
| Customer y Appointment Manager | Standalone Component, Angular Material | Directorio comercial de clientes y flotas vehiculares, visualización de fichas técnicas de automóviles y calendario interactivo de citas para recepción. |
| State Store y API Client | Angular Injectable, Signals, RxJS | Capa centralizada de acceso a datos que gestiona el estado reactivo de la UI mediante *Angular Signals*, cachea consultas frecuentes y realiza llamadas RESTful hacia la *API Application*. |
: Catálogo de Componentes de la Web Application de Atelier {#tbl:c4-webapp-components-catalog}

**Decisiones de Diseño y Patrones Arquitectónicos Frontend**

1. **Gestión Reactiva del Estado con Angular Signals y RxJS:** Se combinan *Angular Signals* para la reactividad de granularidad fina en componentes visuales con operadores de *RxJS* en el State Store y API Client para manejar cancelaciones, reintentos y encadenamiento asíncrono de peticiones HTTP.

2. **Seguridad y Control de Acceso por Roles:** El componente Auth y Tenancy Guard evalúa los permisos del usuario almacenados en el payload del JWT antes de instanciar las vistas de administración sensible, garantizando que recepcionistas u operadores no accedan a pantallas gerenciales.

3. **Aislamiento Multi-Tenant en la Experiencia de Usuario:** El componente *Multi-Tenant Shell* extrae el identificador de sucursal seleccionada y garantiza que toda consulta emitida a través de la capa de datos incluya el contexto del taller correspondiente, sincronizando automáticamente las vistas al cambiar de sede.

4. **Tokenización Directa de Pagos:** El componente SaaS Subscription y Checkout incrusta elementos seguros de *Stripe.js*. Los datos sensibles de las tarjetas de crédito son transmitidos exclusivamente a la infraestructura de Stripe, devolviendo a la aplicación únicamente un token representativo, lo que exime al backend de Atelier del alcance de certificación PCI-DSS.

#### 2.5.3.4. Software Architecture Deployment Diagrams

En esta sección, se presenta el **Software Architecture Deployment Diagram** del ecosistema Atelier. Este diagrama ilustra la distribución física y lógica del sistema sobre el hardware, plataformas de nube y entornos de red, detallando cómo los contenedores de software se despliegan en máquinas de usuario, dispositivos vehiculares, servidores en la nube y servicios gestionados, así como los protocolos de comunicación que garantizan su interoperabilidad y resiliencia.

La infraestructura de Atelier responde a un modelo híbrido optimizado para maximizar la disponibilidad y mitigar costos operativos: combina la ejecución en el borde para clientes web y móviles, servicios telemáticos en vehículos mediante escáneres OBD-II, plataformas como servicio contenerizadas en **Render**, bases de datos administradas de alto rendimiento en **Aiven**, y servicios especializados en **Google Cloud Platform** y APIs externas.

![Deployment Diagram de la Infraestructura y Servicios Cloud del Ecosistema Atelier](report/assets/c4-diagrams/deployment-diagram-atelier.png){#fig:deployment-diagram-atelier}

A continuación, se detalla el catálogo de nodos físicos, entornos de ejecución y plataformas que conforman el despliegue del ecosistema:

| **Nodo o Entorno de Despliegue** | **Tipo de Hardware o Plataforma** | **Runtime o Sistema Operativo** | **Software o Contenedor Desplegado** | \centering \textbf{Responsabilidad y Decisiones de Diseño} |
| :---: | :---: | :---: | :---: | :---: |
| Dispositivo del Personal de Gestión | Estación de trabajo o laptop | Windows, macOS o Linux / Web Browser | Instancia cliente de la Web Application | Acceso al portal administrativo SPA mediante navegadores modernos. Renderiza dashboards ejecutivos, control de inventario FIFO y emisión fiscal. |
| Dispositivo Móvil del Taller | Tablet o smartphone de uso rudo | Android OS o iOS | Instancia nativa de Mobile Workshop | Herramienta móvil del personal de taller. Ejecuta tareas MRO, captura evidencias fotográficas y se enlaza por Bluetooth BLE a escáneres OBD-II con persistencia local en SQLite. |
| Dispositivo Móvil del Conductor | Smartphone personal de usuario | Android OS o iOS | Instancia nativa de Mobile Driver | Aplicación del propietario del vehículo. Permite el monitoreo telemático en tiempo real, recepción de alertas predictivas push y aprobación digital de presupuestos mecánicos. |
| Vehículo del Cliente | Puerto de diagnóstico a bordo | Microcontrolador embebido / BLE o Módem Celular | Scanner OBD2 Bluetooth o Dispositivo Autónomo con SIM | Conexión directa a la ECU vehicular. La variante Bluetooth transmite PIDs y DTCs hacia la app móvil, mientras que la variante celular envía tramas telemétricas autónomamente a la nube. |
| Vercel Cloud Platform | Red de distribución perimetral | Vercel Edge Server / TLS Termination | Bundles estáticos de Landing Page y Web Application | Distribución global de alta velocidad y baja latencia para los activos web. Maneja redirecciones y certificados SSL/TLS automáticos. |
| Render Cloud Platform | Plataforma PaaS basada en contenedores Linux | Docker / Eclipse Temurin OpenJDK 24 | Instancia de ejecución de la API Application | Aloja el backend monolítico modular en Spring Boot. Orquesta los 8 Bounded Contexts, expone endpoints RESTful seguros y procesa la ingesta telemétrica masiva. |
| Aiven Cloud Platform | Clúster gestionado de bases de datos | PostgreSQL 16 con extensión TimescaleDB | Instancia central de la base de datos | Almacén persistente multi-tenant con cifrado en reposo y tránsito. Segrega transacciones relacionales ACID de hipertablas de series de tiempo de telemetría IoT. |
| Google Cloud Platform | Infraestructura gestionada de almacenamiento y mensajería | Google Cloud Storage Bucket | Firebase Cloud Storage y Firebase Cloud Messaging | Storage: Almacena imágenes de peritaje bajo el patrón *Direct-to-Cloud*.<br>FCM: Encola y despacha notificaciones push predictivas hacia los teléfonos de mecánicos y conductores. |
| Infraestructura Externa SaaS | Plataformas Cloud de terceros de alta disponibilidad | APIs RESTful seguras vía HTTPS | Stripe, Nubefact, Resend y Google Maps Platform | Proveedores especializados para cobros recurrentes PCI-DSS, facturación electrónica SUNAT UBL 2.1, correos transaccionales y geocercas GPS. |
: Catálogo de Nodos y Entornos de Despliegue de Atelier {#tbl:c4-deployment-nodes-catalog}

**Decisiones de Arquitectura de Infraestructura, Redes y Resiliencia**

El diseño del despliegue físico y en la nube satisface estrictos requerimientos de ingeniería de software:

1. **Topología de Red y Cifrado de Comunicaciones:**
   * Todas las conexiones externas e inter-servicios en la nube están cifradas mediante TLS 1.3 / HTTPS sobre el puerto estándar 443.
   * La comunicación entre la API en Render y el clúster de base de datos en Aiven se realiza mediante JDBC sobre SSL/TLS, garantizando la confidencialidad de la información multi-tenant en tránsito.
   * La telemetría vehicular local opera mediante Bluetooth Low Energy en la banda ISM de 2.4 GHz, ofreciendo bajo consumo energético para no descargar la batería del vehículo durante inspecciones prolongadas.
   * Los dispositivos OBD2 autónomos transmiten mediante redes celulares 4G LTE Cat-M1 o NB-IoT hacia los endpoints de ingesta de la API utilizando peticiones HTTP POST compactas o sockets TCP directos.

2. **Patrón Direct-to-Cloud para Contenido Multimedia:**
   Para preservar la capacidad de cómputo y la memoria RAM del contenedor de Spring Boot en Render, el registro fotográfico de fallas automotrices no transita por el backend. La aplicación móvil **Atelier Workshop** sube las fotografías directamente a **Firebase Cloud Storage** mediante el SDK nativo, obteniendo una URL firmada que posteriormente es enviada como metadato ligero a la API de Atelier para su persistencia en PostgreSQL.

3. **Persistencia Híbrida y Escalabilidad en Aiven Cloud:**
   El clúster de Aiven combina en un único motor gestionado dos paradigmas de almacenamiento: tablas relacionales tradicionales indexadas por *tenant_id* para garantizar integridad referencial y aislamiento estricto entre talleres, e hipertablas de TimescaleDB que particionan automáticamente los millones de registros telemétricos por ventanas de tiempo, aplicando compresión columnar sin bloquear las operaciones del ERP.

4. **Resiliencia ante Restricciones de Servicios en la Nube:**
   Dado que las capas gratuitas y de entrada de servicios PaaS como Render bloquean los puertos tradicionales de correo SMTP para prevenir spam, la arquitectura integra Resend a través de su API RESTful sobre HTTPS. Esto garantiza el envío ininterrumpido de correos de onboarding y códigos OTP sin depender de puertos restringidos. Asimismo, la integración con Stripe incorpora validación de webhooks con idempotencia para soportar reintentos de red sin duplicar transacciones de pago.

\newpage