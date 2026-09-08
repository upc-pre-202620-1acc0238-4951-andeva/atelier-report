# ANDEVA: STARTUP PROFILE

## Descripción de la Startup

Andeva es un equipo especializado de ingeniería de software dedicado al diseño y desarrollo de soluciones tecnológicas de vanguardia. Nuestro propósito fundamental es resolver desafíos complejos a través de la innovación, construyendo herramientas digitales eficientes, escalables y centradas en el usuario que impulsen la transformación y el progreso en un entorno tecnológico exigente.

## Significado del nombre

El nombre **Andeva** encapsula la esencia de nuestra identidad y nuestra vocación creadora. Nace de la fusión armónica de dos conceptos poderosos:

* **Andes:** Representa nuestro lugar de origen y el profundo arraigo a la riqueza de la cultura peruana. Simboliza la majestuosidad, la solidez y la visión de altura con la que abordamos cada desafío tecnológico.
* **Eva:** Cuyo significado universal es "la que da vida". Este concepto refleja directamente nuestro ADN tecnológico y carácter innovador: la capacidad de concebir ideas disruptivas y darles vida mediante la creación de productos de software de la más alta calidad.

Juntos, Andeva expresa nuestro compromiso de crear tecnología viva, útil y trascendente desde el Perú hacia el futuro.

## Objetivo (Misión)

Diseñar y desarrollar soluciones de software innovadoras que empoderen a las organizaciones y a las personas. Buscamos brindar herramientas tecnológicas de primera categoría que optimicen procesos, fomenten la creatividad y resuelvan problemas complejos, garantizando siempre la máxima calidad técnica y una experiencia de usuario excepcional.

## Visión

Ser el equipo de ingeniería de software líder y referente tecnológico a nivel internacional, reconocido por nuestra capacidad de innovar y dar vida a productos digitales excepcionales. Aspiramos a construir ecosistemas tecnológicos que definan los estándares del mañana, manteniendo siempre nuestro compromiso inquebrantable con la excelencia y el orgullo por nuestra identidad cultural.

## Nuestro Producto Principal: Atelier

Nuestro principal producto, **Atelier**, es un ecosistema de software (SaaS) diseñado para transformar radicalmente el modelo operativo tradicional de los talleres automotrices, evolucionándolo de un enfoque reactivo a uno proactivo, preventivo e inteligente. Más allá de modernizar la gestión diaria, Atelier funciona como un completo sistema ERP y MRO que otorga al taller control total sobre sus ámbitos administrativos (personal, inventario, citas, órdenes de trabajo) y económicos (cobranza y facturación), logrando fidelizar clientes y reducir drásticamente los costos asociados a averías graves.

El corazón de la innovación de Atelier, que nos permite ofrecer este mantenimiento preventivo, es un software capaz de reconocer e integrarse con cualquier dispositivo OBD2 del mercado. Mediante la telemetría —ya sea conectando OBD2 con tarjeta SIM directa al servidor, o vía Bluetooth/WiFi utilizando el smartphone del conductor como *gateway*— el sistema anticipa los fallos vehiculares y automatiza el flujo de servicio.

El ecosistema se divide estratégicamente en dos fases para conectar a todos los actores del proceso:

* **Atelier Workshop (Fase 1):** Una completa Aplicación Web y Móvil orientada al segmento B2B. En esta primera fase, el producto se dirige exclusivamente a dos segmentos objetivo: **Segmento 1: Personal de Gestión y Propietarios del Taller** (dueños con control global y administradores de sucursal) y **Segmento 2: Personal Operativo del Taller** (mecánicos, recepcionistas y asesores de servicio en la zona de trabajo). Con una sólida arquitectura multi-tenant y un estricto control de acceso basado en roles (RBAC), garantiza que cada miembro del equipo disponga exactamente de las herramientas e información que necesita para operar con máxima eficiencia.
  * **REGLA ARQUITECTÓNICA Y DE PRODUCTO (Asimetría WebApp vs. Mobile Workshop):**
    * **Atelier Workshop sirve a ambos segmentos B2B (Personal de Gestión y Personal Operativo):**
      1. **Atelier Workshop WebApp (Escritorio):** Es la herramienta principal para **Personal de Gestión** (dueños, administradores y recepcionistas). Concentra la administración general del taller, finanzas, inventario FIFO, facturación electrónica SUNAT UBL 2.1 y planillas de RRHH. **La WebApp NO CONTIENE herramientas exclusivas de piso de taller** (como escaneo Bluetooth BLE de OBD2, registro fotográfico en foso ni sincronización offline-first), ya que no tienen lógica ni utilidad para un usuario en escritorio.
      2. **Atelier Workshop Mobile (Smartphones y Tablets):** Es una aplicación unificada para **AMBOS segmentos B2B**:
         - **Para Dueños y Administradores:** Contiene **TODO lo que tiene la WebApp** (supervisión de órdenes, aprobación de presupuestos, métricas financieras, catálogo de inventario y estado del personal), permitiéndoles gestionar y supervisar el taller mientras recorren el patio o están fuera de la sede.
         - **Para Mecánicos y Personal Operativo (en constante movimiento físico):** Es su **ÚNICA herramienta de trabajo**, dotada de capacidades exclusivas de patio que no están en la Web: lectura telemétrica OBD-II directa por Bluetooth Low Energy (BLE), captura fotográfica de evidencias de desarme/armado y soporte *Offline-First* con base de datos local SQLite (`Room` / `sqflite`) para operar en fosos y zonas sin cobertura.
* **Atelier Driver (Fase 2):** Una Aplicación Móvil orientada a los clientes finales (**Segmento 3: Propietarios de Vehículos (Particulares y Flotas)**). Funciona como portal de interacción directa para recibir diagnósticos OBD2 en tiempo real, agendar citas y revisar el historial de mantenimientos. 
  * **NOTA CRÍTICA PARA DOCUMENTACIÓN Y DESARROLLO (Regla para IA):** El "Segmento 3: Propietarios de Vehículos (Particulares y Flotas)" y la app "Atelier Driver" son una fortaleza clave del producto frente a la competencia y pueden mencionarse como característica del ecosistema. SIN EMBARGO, para los entregables del reporte académico actual, **este tercer segmento NO SE CONTEMPLA en la documentación de negocio, UX, ni historias de usuario** (es decir, no se deben generar User Stories, entrevistas ni diseños para este segmento). **Las ÚNICAS excepciones son las secciones 2.5.3 (Software Architecture Context/Container/Component Level Diagrams y sus derivados) y 2.6 (Tactical-Level Domain-Driven Design y sus derivados)**, donde este tercer segmento SÍ DEBE INCLUIRSE en los diagramas y código (ej. Structurizr C4, PlantUML, Context Maps) para prever la escalabilidad del sistema y mostrar el panorama completo del ecosistema.

## Features Principales del Ecosistema

### 1. Telemetría IoT y Mantenimiento Predictivo
El servicio premium y diferencial que los talleres ofrecen a sus clientes mediante OBD2 (SIM o BLE/WiFi). Atelier monitoriza constantemente los PIDs (datos en tiempo real) y los códigos de falla (DTC). Ante cualquier anomalía, el sistema envía una alerta simultánea al taller y a la aplicación móvil del cliente (Atelier Driver), permitiendo actuar antes de que ocurra una avería grave. Para los usuarios que no contratan este servicio, la app Driver sigue siendo indispensable para gestionar historiales y agendar citas, pero la telemetría está estrictamente vinculada a los OBD2 configurados de manera exclusiva por el taller hacia los servidores de Atelier.

### 2. Gestión de Inventario Inteligente (Método FIFO)
Un sistema riguroso para la administración de stock (repuestos y líquidos) basado en lotes bajo el principio de "Primeras Entradas, Primeras Salidas" (FIFO). Garantiza que cuando los insumos son asignados a una Orden de Trabajo, se descuenten con su costo de adquisición exacto. El sistema no impone precios de venta; el dueño del taller define sus propios márgenes. En caso de errores físicos en la manipulación (ej. tomar una bujía del lote más nuevo), el impacto financiero se mitiga, ya que contablemente se descarga el costo del lote que corresponde.

### 3. Directorio de Proveedores e Ingreso Rápido de Lotes
Módulo administrativo diseñado para el reabastecimiento eficiente del taller, enfocado en simplificar la carga cognitiva del usuario en el Frontend. En lugar de requerir complejas Órdenes y Líneas de Compra, el administrador registra sus proveedores habituales en un directorio simple (`suppliers`). Cuando llega nueva mercadería, el ingreso se registra con un solo clic como un nuevo lote (`inventory_batches`), permitiendo subir la foto de la boleta/factura directamente a Firebase Storage y estableciendo el costo exacto de esa compra para mantener la precisión matemática del método FIFO.

### 4. MRO (Órdenes de Trabajo) y Trazabilidad
El núcleo operativo del taller, estructurado desde el momento en que se genera una Cita.
* **Flujo Operativo:** Una Cita se convierte en una Orden de Trabajo (OT). El administrador divide la OT en múltiples Tareas (`work_order_tasks`), asigna mecánicos y vincula los repuestos necesarios.
* **Registro Visual y Financiero:** La OT centraliza las imágenes del vehículo al ingresar (`work_order_images`) y la evidencia fotográfica de la reparación finalizada (`work_order_task_images`). Además, las tareas y repuestos mantienen su propio costo integrado (`price`, `unit_price`), permitiendo que el Frontend renderice y recalcule la cotización total al cliente en tiempo real.
* **Ejecución:** Los mecánicos interactúan únicamente con las tareas que les han sido asignadas en su app móvil (cambiando los estados: Pendiente > En Progreso > Finalizado). Al agregar un repuesto a su tarea, el sistema efectúa una "reserva" lógica inmediata contra el módulo de Inventario.

### 5. Control de Personal e Identidad Profesional
Módulo enfocado en la administración de recursos humanos del taller y el seguimiento de planillas (sueldo base, horas laboradas y control de asistencia).
* **Onboarding Innovador:** Los empleados no se crean en el sistema de forma arbitraria. El taller envía una invitación al correo del empleado, quien se registra en Atelier creando su propio perfil profesional. Una vez registrado, el taller lo vincula oficialmente a su local. Si la relación laboral termina, el empleado simplemente es "desvinculado".
* **Proyección a Futuro:** Al mantener su propia cuenta, el mecánico retiene su identidad digital y no necesita registrarse de nuevo si entra a otro taller que use Atelier. Eventualmente, esta base cimentará una red estilo *LinkedIn* para la industria automotriz, donde los talleres publicarán vacantes y los mecánicos independientes podrán postularse directamente desde su app.

## Arquitectura Tecnológica y Stack de Desarrollo

Atelier está diseñado bajo una arquitectura de nivel empresarial (Monolito Modular impulsado por Domain-Driven Design), utilizando servicios en la nube de alta resiliencia.

### Backend, Base de Datos y Caché
* **Core:** Java 24 con Spring Boot 3.5.5, asegurando un procesamiento robusto y de muy baja latencia.
* **Infraestructura en la Nube:** Despliegue en **Render** (para la API RESTFul) y **Aiven** (PostgreSQL).
* **Telemetría IoT:** Uso de la extensión **TimescaleDB** dentro de Aiven para particionar y comprimir masivamente los datos en tiempo real provenientes de los dispositivos OBD2, permitiendo mantener históricos sin degradar el rendimiento del ERP.
* **Estrategia de Caché en Memoria (Caffeine):** Para mitigar los tiempos de respuesta y aliviar masivamente los accesos a Aiven, se introduce una capa de caché local en Spring Boot (usando `Caffeine Cache`). Se aplica estrictamente a Bounded Contexts de alta lectura estática, tales como:
  * *Roles y Permisos (IAM):* Leídos en cada petición HTTP para autorizar los endpoints (RBAC).
  * *Planes de Suscripción:* Verificación rápida de los límites del plan contratado por el taller.
  * *Catálogos de MRO e Inventario:* (`services`, `inventory_items`) Consultados de manera constante por los mecánicos para agregar a sus tareas.

### Integraciones Externas de Bajo Costo y Estrategia de Implementación
Para construir este ecosistema manteniendo una alta resiliencia y viabilidad económica (aprovechando capas *Free Tier* y *Pay-as-you-go*), la arquitectura orquesta múltiples APIs bajo estrictos patrones de diseño:

* **Stripe (SaaS Billing y Pasarela de Pagos):**
  * **Implementación:** Se integrará la dependencia oficial `stripe-java`. Las aplicaciones móviles delegarán la tokenización de tarjetas a los SDKs de Stripe, asegurando el cumplimiento de la norma PCI-DSS.
  * **Arquitectura:** Para garantizar consistencia y evitar dobles cobros, el Backend manejará *Webhook Idempotency* (rechazando eventos duplicados) y utilizará el patrón *Transactional Outbox* para sincronizar los pagos exitosos con la base de datos central antes de emitir la factura.
* **Nubefact (Facturación Electrónica SUNAT):**
  * **Implementación:** Se utilizará la API JSON V1 de Nubefact (Entorno Beta/Demo para la validación académica). El backend enviará la trama de datos y Nubefact devolverá inmediatamente las URLs de los comprobantes (`sunat_pdf_url`, `sunat_xml_url`) para ser renderizados en la app.
  * **Arquitectura:** Se aislará esta comunicación mediante una Capa Anticorrupción (ACL) para evitar que los modelos tributarios externos contaminen la lógica de dominio puro del ERP.
* **Firebase Cloud Messaging - FCM (Alertas IoT Predictivas):**
  * **Implementación:** Al iniciar sesión, las aplicaciones (Flutter/Kotlin) generarán un `fcm_token` único por dispositivo. Cuando el motor de telemetría alojado en Spring Boot detecte un fallo predictivo, utilizará el *Firebase Admin SDK* (gratuito) para "empujar" (Push) la alerta de manera simultánea e instantánea al celular del conductor y al dashboard del taller.
* **Firebase Cloud Storage (Almacenamiento de Imágenes y Evidencia):**
  * **Implementación:** Resuelve la necesidad de guardar evidencia visual del vehículo y las reparaciones. Para evitar saturar el servidor backend en Render con el procesamiento de archivos pesados, se empleará el patrón *Direct-to-Cloud*. La aplicación móvil subirá la imagen directamente a los buckets de Firebase mediante el SDK nativo. Firebase retornará una URL segura, y la app enviará únicamente esta URL en formato texto a la API de Spring Boot para ser almacenada en la base de datos relacional.
* **Resend (Correos Transaccionales por API HTTPS):**
  Al integrarnos mediante la API de Resend (Puerto 443 HTTPS), evitamos los bloqueos de puertos SMTP tradicionales impuestos por las capas gratuitas de servicios en la nube (ej. Render). Resend se utiliza como motor de comunicación omnicanal para los siguientes casos de uso estratégicos:
  1. **Onboarding B2B:** Envío asíncrono de invitaciones al personal operativo (mecánicos, asesores) para unirse al *tenant* del taller.
  2. **Verificación de Identidad (MFA/OTP):** Envío de códigos numéricos de 6 dígitos para verificar cuentas nuevas o confirmar operaciones sensibles.
  3. **Recuperación de Credenciales:** Flujo seguro de *Password Reset* mediante tokens de un solo uso cuando un usuario olvida su contraseña.
  4. **Recordatorios de Citas y Presupuestos (B2C):** Notificaciones al correo del conductor confirmando que su reserva fue aceptada o que tiene un presupuesto MRO pendiente de aprobación.
  5. **Comprobantes Electrónicos (Billing):** Envío de la boleta o factura (PDF/XML) generada por Nubefact directamente al correo del cliente post-reparación.
  * **Implementación técnica:** Para mantener la alta concurrencia del backend, el envío de correos y la comunicación con la API de Resend se ejecutará de forma no bloqueante utilizando eventos asíncronos (`@Async`) y `WebClient` en Java, evitando pausar la respuesta HTTP del cliente.
* **Google Maps Platform (Control de Personal y Geocercas):**
  * **Implementación:** El frontend utilizará *Google Places API* para normalizar direcciones. Para la validación de asistencia (marcación de entrada/salida), el móvil enviará sus coordenadas GPS al backend. El servidor de Spring Boot utilizará la *Fórmula matemática del Haversine* para calcular la distancia métrica exacta. Si el empleado está fuera del radio de la sucursal (ej. 50m), el sistema rechazará su asistencia.
* **Google Identity Services (Autenticación Federada y Single Sign-On OAuth2 / OIDC):**
  * **Propósito y Casos de Uso:** Proveer un mecanismo de autenticación federada sin fricción, seguro y de alta disponibilidad para todos los actores de la plataforma. Permite que el Personal de Gestión (dueños, administradores y recepcionistas) acceda desde la aplicación web (`Web Application`), y que el Personal Operativo (mecánicos y jefes de patio) y los clientes finales (conductores y administradores de flotas) inicien sesión desde las aplicaciones móviles (`Mobile Workshop`, `Mobile Driver`) utilizando sus cuentas corporativas o personales de Google Workspace sin memorizar contraseñas independientes.
  * **Implementación en Frontend y Clientes Móviles:** Las aplicaciones cliente inicializan los SDKs oficiales de Google Identity Services (`@google/identity` en la Web SPA y el plugin nativo `google_sign_in` en Flutter/Kotlin). La interacción delega la autenticación y el consentimiento del usuario a la infraestructura de Google, la cual retorna un token de identidad criptográfico (`id_token`) estructurado como JWT bajo el estándar RFC 7519.
  * **Verificación Defensiva en el Backend (Arquitectura Zero-Trust):** La aplicación cliente transmite el `id_token` mediante una solicitud HTTPS segura al endpoint `/api/v1/authentication/sign-in-with-google` en el Bounded Context IAM & Tenancy. El backend no delega la confianza en el cliente: mediante la clase adaptadora `GoogleTokenVerifierGatewayImpl` y la biblioteca oficial `google-api-client` (`GoogleIdTokenVerifier`), se descargan y verifican los certificados de claves públicas emitidos por Google (`https://www.googleapis.com/oauth2/v3/certs`). Se comprueba la firma RSA-SHA256, la vigencia temporal del aserto y la coincidencia estricta del claim `audience` (`aud`) con el Client ID de Google configurado en las variables de entorno de producción.
  * **Aprovisionamiento y Aislamiento Multi-Tenant:** Tras la verificación exitosa, el sistema extrae el identificador federado `googleId` (`sub`), el correo electrónico verificado (`email`) y el nombre del perfil. Si el usuario ingresa por primera vez, el servicio de aplicación crea automáticamente la raíz de agregado `User` configurando el proveedor `AuthProvider.GOOGLE`. Posteriormente, IAM resuelve el contexto operativo del usuario: si posee una membresía activa en un taller (`TenantMembership`), inyecta en el token Bearer JWT nativo de Atelier los identificadores `tenantId`, `branchId` y la lista de permisos RBAC autorizados. Si es un nuevo dueño de taller, se le redirige al flujo de onboarding de empresa (`RegisterTenantCommand`). Este desacoplamiento garantiza que la sesión interna de la plataforma y el aislamiento multi-inquilino se mantengan inmutables independientemente de la vigencia del token externo de Google.

### Ecosistema Móvil y Viabilidad del MVP (Estrategia Offline-First)
Para las aplicaciones "Workshop" y "Driver", se aplicará un enfoque utilizando **Flutter** y **Kotlin**. 

Basado en hallazgos donde el **49.1% de usuarios móviles accede a internet sin un plan de datos activo constante** (dependiendo de redes Wi-Fi) y considerando los escenarios operativos del taller (fosos de inspección sin cobertura), el ecosistema móvil debe regirse bajo un patrón **Offline-First obligatorio**.

Durante la fase de validación (MVP/Proyecto Universitario), Atelier asegura el cumplimiento estricto de interacciones complejas exigidas a nivel académico:
1. **Recursos de Hardware Interno:** Las aplicaciones interactúan con el hardware nativo (Bluetooth/BLE) para leer la telemetría del vehículo actuando como *Gateway*. En entornos de prueba académica (sin vehículos físicos), el sistema leerá los datos desde simuladores de hardware OBD2. Adicionalmente, se extraen las coordenadas GPS del dispositivo móvil para la validación algorítmica de geocercas.
2. **Almacenamiento Local Robusto (Caché Offline-First con SQLite):** Uso de base de datos relacional local basada en el motor estándar **SQLite**: implementado mediante **Room Database** (Android Jetpack) en la versión nativa de Kotlin (aprovechando la verificación de consultas en tiempo de compilación, cero código boilerplate y flujos reactivos con Coroutines/Flow) y mediante **SQLite (`sqflite`)** en la versión multiplataforma de Flutter. Ambas tecnologías mantienen catálogos, historial de reparaciones y órdenes en caché local. La UI debe leer siempre de esta caché y no depender de llamadas directas a red, garantizando funcionamiento ininterrumpido en zonas de baja cobertura.
3. **Patrón de Cola de Sincronización (Sync Queue):** Acciones complejas offline (marcar tareas como terminadas, adjuntar fotos de evidencia de reparaciones, o encolar reservaciones de citas) se guardan en el celular en una tabla local de eventos pendientes. Un *Background Worker* se encarga de enviarlas a la API mediante subida diferida (Deferred Uploads) cuando detecta conexión de red, sin bloquear al usuario.
4. **Feature de Aprendizaje Autónomo:** El equipo implementará de forma autodidacta librerías avanzadas no provistas en el temario base (tales como el SDK nativo de *Stripe* para procesamiento de transacciones, o la comunicación Bluetooth serial de bajo nivel para la ingesta IoT).

## Arquitectura de Software y Patrones Tácticos

El ecosistema Atelier está estructurado bajo los más altos estándares de ingeniería de software, operando como un **Monolito Modular** fuertemente impulsado por los principios del **Domain-Driven Design (DDD)**. 

### Patrones Arquitectónicos Aplicados
Para asegurar que el sistema sea mantenible, escalable y tolerante a fallos, se han aplicado los siguientes patrones:

* **Arquitectura Hexagonal (Ports and Adapters):** Cada módulo aísla su lógica de negocio pura (Dominio) en el centro. Las interacciones con el exterior (Base de datos PostgreSQL, APIs de Stripe o Nubefact, simuladores Bluetooth OBD2) se realizan invirtiendo las dependencias mediante puertos (Interfaces) y adaptadores, lo que permite intercambiar tecnologías (ej. cambiar de Nubefact a otro facturador electrónico) sin afectar el núcleo del sistema.
* **CQRS Lógico (Command Query Responsibility Segregation):** Las operaciones transaccionales complejas (como descontar un repuesto físico bajo el método FIFO) utilizan entidades de dominio completas vía Spring Data JPA. Por otro lado, las consultas de lectura masivas (como cargar el historial histórico de reparaciones) evitan la sobrecarga de Hibernate utilizando proyecciones ligeras e inmutables (Java Records) atacando directamente a la base de datos.
* **Patrón Transactional Outbox:** Garantiza la consistencia eventual al integrar APIs críticas. Por ejemplo, al realizar un cobro por Stripe y emitir una factura, el evento se guarda localmente en la transacción ACID del ERP y un *worker* asíncrono garantiza su envío a Nubefact "al menos una vez", evitando que el taller pierda dinero o evada impuestos si la conexión de red falla temporalmente.
* **Capa Anticorrupción (ACL - Anticorruption Layer):** Se implementan barreras estrictas al interactuar con servicios de terceros para evitar que sus modelos de datos externos contaminen los modelos de dominio limpios de Atelier.

### Diseño Estratégico y Modelado de Dominio (DDD)

El ecosistema se ha modelado respetando estrictamente las fronteras lingüísticas (*Ubiquitous Language*) del negocio, evitando el antipatrón de las "Entidades Dios" (God Entities). Por ejemplo, el concepto de "Vehículo" se ha fragmentado: en el CRM es un activo de propiedad (VIN, dueño), en MRO es el sujeto de reparación (fotos, bahía asignada), y en IoT es un generador de flujos masivos de telemetría.

#### 1. Categorización de Subdominios
* **Core Domains (Diferenciadores clave del negocio):** IoT Telemetry (mantenimiento predictivo) y Workshop Operations (la operación central del taller).
* **Supporting Subdomains (Apoyo indispensable):** Customer & Fleet Management y Inventory & Supply Chain.
* **Generic Subdomains (Soluciones estándar):** IAM & Tenancy, HR Management, SaaS Billing (Stripe), e Invoicing (Nubefact).

#### 2. Context Map y Patrones de Integración
Las relaciones entre estos contextos utilizan patrones DDD canónicos:
* **Anticorruption Layer (ACL):** Utilizado entre los contextos de facturación y las APIs externas (Stripe y Nubefact) para evitar que modelos de datos tributarios o bancarios de terceros infecten el dominio puro de Atelier.
* **Customer / Supplier:** El contexto de CRM genera Citas (*Supplier*), las cuales son consumidas por el contexto MRO (*Customer*) para transformarlas operativamente en Órdenes de Trabajo.
* **Conformist:** El `tenant_id` (originado en el contexto IAM) es compartido y respetado incondicionalmente por todos los demás contextos para garantizar la arquitectura Multi-Tenant de extremo a extremo.

#### 3. Los 8 Bounded Contexts (Descripción Extendida)
El sistema se divide orgánicamente en 8 subdominios delimitados, cada uno con un propósito altamente cohesivo y justificado:

1. **Identity and Access Management (IAM) & Tenancy Context:**
   * **Propósito y Por qué se creó:** Aislar la enorme complejidad de la seguridad, autenticación y multitenencia. Se creó para garantizar de forma monolítica que la data de un taller jamás se cruce con la de otro, y para cimentar la visión a futuro de una "Red Profesional de Mecánicos" al darles una identidad independiente.
   * **Descripción:** Gestiona la partición Multi-Tenant, el control de acceso basado en roles (RBAC - Dueño, Administrador, Mecánico) y el innovador proceso de Onboarding del personal mediante invitaciones asíncronas por correo (Resend).

2. **Customer and Fleet Management Context:**
   * **Propósito y Por qué se creó:** Separar la gestión comercial y de relaciones públicas (B2C/B2B2C) de la dura operatividad mecánica del taller, centralizando la interacción con el cliente final.
   * **Descripción:** Administra los perfiles de los conductores individuales, empresas con flotas vehiculares, el registro histórico de propiedad de los vehículos y el agendamiento de citas que los clientes realizan desde su aplicación cliente (Atelier Driver).

3. **Workshop Operations Context (MRO - Maintenance, Repair, and Operations):**
   * **Propósito y Por qué se creó:** Es el motor central del taller mecánico. Se delimitó para orquestar exclusivamente el flujo de trabajo, manteniendo los precios y subtotales locales de cada orden (para facilidad de cálculo en el Frontend) sin verse abrumado por detalles de facturación nacional (Invoicing) o suscripciones (SaaS Billing).
   * **Descripción:** Controla el ciclo de vida de las Órdenes de Trabajo (OT). Transforma citas en OTs, divide el trabajo en Tareas, las asigna a los mecánicos, y centraliza el almacenamiento estructurado de imágenes en Firebase Storage.

4. **Inventory and Supply Chain Context:**
   * **Propósito y Por qué se creó:** Aislar la compleja lógica matemática y financiera del control de stock. Al contexto MRO no le importa de qué lote provino una pastilla de freno ni a qué proveedor se le compró; es Inventario quien maneja la complejidad de descontarla y resguardar el margen de ganancia.
   * **Descripción:** Funciona como el core logístico. Garantiza la trazabilidad estricta de repuestos y líquidos mediante el método de costeo FIFO por Lotes. Gestiona también un directorio interno rápido de proveedores (`suppliers`) para enlazar las facturas o boletas de ingreso escaneadas (`receipt_image_url`) directamente a los lotes ingresados, simplificando la operación del usuario administrador.

5. **Human Resources Management Context:**
   * **Propósito y Por qué se creó:** Separar la "persona como usuario del sistema" (lógica de IAM) de la "persona como empleado que genera un gasto operativo y tiene un horario" (lógica de RRHH).
   * **Descripción:** Gestiona los turnos laborales, el cálculo de planillas/salarios de los mecánicos y el control de asistencia. Esta asistencia es validada algorítmicamente contrastando el hardware GPS del celular del mecánico con las geocercas de la sucursal.

6. **Invoicing and Compliance Context:**
   * **Propósito y Por qué se creó:** La tributación (impuestos, XMLs fiscales) es un dominio muy volátil, rígido y específico por país. Se creó para encapsular las reglas impuestas por la SUNAT lejos del dominio de la reparación automotriz y del inventario.
   * **Descripción:** Responsable de la emisión de comprobantes de pago electrónicos con validez legal (UBL 2.1). Protege al resto del sistema operando detrás de una Capa Anticorrupción (ACL) en su comunicación bidireccional con la API de Nubefact.

7. **SaaS Billing and Subscriptions Context:**
   * **Propósito y Por qué se creó:** Gestionar los ingresos propios de la startup *Andeva* (el pago que los talleres realizan mes a mes por usar Atelier) sin mezclarlo con la economía interna y la facturación a los clientes del taller (manejada por MRO e Invoicing).
   * **Descripción:** Administra los cobros recurrentes de la suscripción SaaS, la pasarela de pagos y el cumplimiento de estándares de seguridad PCI-DSS, integrando la infraestructura de *Stripe* mediante mecanismos de resiliencia como Webhook Idempotency.

8. **IoT Telemetry and Predictive Maintenance Context:**
   * **Propósito y Por qué se creó:** Manejar el altísimo volumen de datos estructurados por tiempo (Time-Series) que generan los escáneres OBD2, evitando colapsar y ralentizar las bases de datos transaccionales (PostgreSQL) del ERP del taller.
   * **Descripción:** El núcleo de la innovación de Andeva. Se encarga de la ingesta de telemetría masiva (vía tarjetas SIM o vía la app móvil actuando como Gateway Bluetooth) comprimiéndola en *TimescaleDB*. Procesa los PIDs (RPM, temperatura) y códigos de error (DTCs) para emitir alertas predictivas inmediatas (vía Firebase FCM) antes de que el motor sufra daños severos.
