## 2.5. Strategic-Level Domain-Driven Design

En el desarrollo de ecosistemas de software empresarial contemporáneos, la complejidad esencial no radica en la selección de frameworks o tecnologías de infraestructura, sino en el modelado fidedigno y riguroso de la lógica del negocio. Para el ecosistema **Atelier**, una plataforma SaaS multi-tenant orientada a la transformación integral de la gestión y mantenimiento vehicular en talleres automotrices, la adopción del diseño guiado por el dominio (*Domain-Driven Design* - DDD) en su vertiente estratégica constituye el pilar fundamental para garantizar cohesión conceptual, desacoplamiento arquitectónico y escalabilidad modular a largo plazo.

El enfoque estratégico de DDD propuesto por Eric Evans y profundizado por Vaughn Vernon y Alberto Brandolini nos permite descomponer un dominio de alta densidad operativa —que abarca telemetría predictiva IoT mediante OBD-II, planificación de mantenimiento, reparación y operaciones (MRO), control contable de inventarios bajo costeo FIFO, facturación electrónica fiscal y control de personal— en subdominios especializados. Esta delimitación previene la formación del antipatrón del "gran lodo de código" (*Big Ball of Mud*) y asegura que cada unidad de software resuelva un problema acotado mediante un lenguaje ubicuo compartido entre ingenieros y expertos del dominio.

A través del taller colaborativo de *EventStorming*, el equipo identificó los eventos de negocio, comandos y agregados, trazando los límites contextuales (*Bounded Contexts*) y estableciendo las relaciones de comunicación intercontextual mediante *Domain Message Flows* y *Context Mapping*.

### 2.5.1. *EventStorming*

El *EventStorming* es una metodología de modelado rápido, colaborativo y centrado en el dominio desarrollada por Alberto Brandolini. A través de sesiones dinámicas e iterativas, expertos en el negocio automotriz, administradores de talleres y el equipo de ingeniería de software plasmaron el flujo completo de valor del ecosistema Atelier sobre una superficie continua, utilizando un sistema estandarizado de artefactos visuales codificados por color:

- **Naranja (Eventos de Dominio - Domain Events):** Sucesos significativos e inmutables que han ocurrido en el pasado dentro del dominio, expresados gramaticalmente en participio pasado (ej. `falla telemática detectada`, `orden de trabajo completada`).
- **Azul (Comandos - Commands):** Acciones, intenciones o directivas explícitas ejecutadas por un usuario o gatilladas por una política para desencadenar una modificación de estado (ej. `generar presupuesto mro`, `descargar repuesto por método fifo`).
- **Amarillo Claro (Actores y Roles - Users/Actors):** Personas o perfiles que interactúan directamente con el sistema para ejecutar comandos (ej. Administrador del Taller, Mecánico Operativo, Conductor/Propietario de Flota).
- **Lila / Morado (Políticas - Policies):** Reglas de negocio reactivas del tipo "Cuando ocurre [Evento], Entonces se ejecuta [Comando]" que orquestan procesos asíncronos y desacoplados.
- **Verde (Modelos de Lectura - Read Models / UI Projections):** Vistas informativas y proyecciones de datos que los usuarios necesitan consultar en pantalla para tomar decisiones antes de emitir un comando (ej. Tablero de Citas, Resumen de Stock FIFO).
- **Rosa / Gris (Sistemas Externos - External Systems):** Plataformas y servicios ajenos a la solución que interactúan con el dominio como origen o destino de información (ej. Escáneres OBD-II, API Nubefact SUNAT, Pasarela de Pagos Stripe/Culqi).
- **Amarillo Mostaza (Agregados y Entidades Clave - Aggregates):** Unidades de consistencia transaccional y encapsulamiento de invariantes que protegen la lógica de negocio (ej. `WorkOrder`, `InventoryBatch`, `TelemetryStream`).
- **Límites Delimitadores (Bounded Contexts):** Fronteras lingüísticas y estructurales que agrupan los conceptos cohesivos dentro de un subdominio específico.

#### 2.5.1.1. Candidate Context Discovery

El descubrimiento de los contextos candidatos para el ecosistema Atelier se llevó a cabo mediante un riguroso proceso de ocho fases estructuradas durante la sesión de *EventStorming*:

1. **Fase 1: Exploración Caótica de Eventos de Dominio:** Los participantes generaron sin restricciones iniciales todos los eventos concebibles que ocurren a lo largo del ciclo de vida automotriz, desde la adquisición de un repuesto hasta la entrega del auto reparado y la monitorización de telemetría.
2. **Fase 2: Ordenamiento Temporal y Línea de Tiempo:** Se organizaron los eventos en secuencias cronológicas concurrentes para modelar la línea de tiempo principal del taller y los flujos paralelos de los clientes particulares y flotas corporativas.
3. **Fase 3: Identificación de Disparadores y Comandos:** Se identificaron las causas de cada evento de dominio, determinando qué comandos específicos emitidos por actores o sistemas desencadenaron las transiciones de estado.
4. **Fase 4: Formulación de Políticas Reactivas:** Se trazaron las políticas automatizadas que responden a eventos clave, garantizando que los módulos colaboren sin acoplamiento temporal directo.
5. **Fase 5: Modelado de Interfaces de Información y Vistas de Lectura:** Se vincularon las pantallas de las aplicaciones web y móviles con los modelos de lectura requeridos por los mecánicos y administradores.
6. **Fase 6: Detección de Fronteras e Integraciones Externas:** Se aislaron las responsabilidades que deben delegarse a proveedores de infraestructura externa (validación de comprobantes ante SUNAT, almacenamiento telemétrico en la nube y pasarelas de cobro).
7. **Fase 7: Consolidación de Agregados:** Se asociaron los comandos y eventos a sus respectivas raíces de agregado, definiendo qué objetos de negocio son responsables de mantener invariantes transaccionales.
8. **Fase 8: Delimitación de Contextos Candidatos:** Mediante análisis semántico y fronteras lingüísticas, se agruparon los agregados afines, descubriendo ocho *Bounded Contexts* claramente diferenciados más un contexto compartido.

A continuación, la @tbl:candidate-contexts-classification resume la clasificación estratégica de los subdominios descubiertos en el ecosistema Atelier:

| Subdominio / Contexto Candidato | Tipo de Subdominio | Justificación Estratégica y Propósito en el Negocio |
| :--- | :---: | :--- |
| Workshop Operation | Core Domain | Núcleo diferencial de Atelier. Gestiona la operativa MRO, órdenes de trabajo, asignación de bahías y trazabilidad fotográfica en patio. |
| IoT Telemetry | Core Domain | Ventaja competitiva principal. Procesa series de tiempo de escáneres OBD-II para predecir averías vehiculares en tiempo real. |
| Customer & Fleet | Supporting Domain | Soporta la gestión de clientes particulares, flotas comerciales y el padrón de vehículos asociados a telemetría. |
| Inventory | Supporting Domain | Soporta el abastecimiento del taller bajo costeo FIFO riguroso por lotes, garantizando márgenes de ganancia exactos. |
| Human Resources | Supporting Domain | Soporta el control de asistencia mediante geocercas circulares Haversine y el cálculo de planillas de mecánicos. |
| Invoicing | Generic Subdomain | Dominio genérico regulatorio. Emite comprobantes electrónicos (Boletas/Facturas) ante SUNAT vía Capa Anticorrupción con Nubefact. |
| SaaS Billing | Generic Subdomain | Dominio genérico de negocio. Administra suscripciones B2B de los talleres, facturación periódica y pasarelas de pago. |
| IAM & Tenancy | Generic Subdomain | Dominio genérico de seguridad. Gestiona identidades, roles RBAC y el aislamiento estricto multi-inquilino del SaaS. |
: Clasificación Estratégica de Contextos Candidatos de Atelier {#tbl:candidate-contexts-classification}

*Nota.* Clasificación elaborada por el equipo de desarrollo siguiendo los lineamientos de Evans y Vernon para Domain-Driven Design.

#### 2.5.1.2. Domain Message Flows Modeling

Los flujos de mensajes de dominio modelan la interacción dinámica y asíncrona entre los diferentes *Bounded Contexts*. Cada flujo representa un escenario operativo de extremo a extremo, mostrando cómo los eventos de dominio y los comandos atraviesan las fronteras contextuales manteniendo consistencia eventual y bajo acoplamiento.

A continuación, se documentan los seis escenarios operativos fundamentales del ecosistema:

##### Escenario 1: Ingesta de Telemetría IoT y Detección de Anomalías Predictivas

Este flujo modela el ciclo de vida del monitoreo telemático predictivo. Cuando un dispositivo OBD-II transmite lecturas continuas del vehículo, el contexto **IoT Telemetry** ingesta los flujos de datos y evalúa los parámetros del motor frente a modelos analíticos. Al registrarse un valor anómalo, se dispara el evento `falla telemática detectada`, lo que desencadena políticas reactivas hacia **Customer & Fleet** para alertar al conductor y hacia **Workshop Operation** para la apertura de una pre-orden de servicio preventivo.

![Flujo de Mensajes del Dominio: Ingesta de Telemetría IoT y Detección de Anomalías Predictivas](report/assets/strategic-ddd/domain-message-flow-scenario-1.png){#fig:dmf-scenario-1}

*Nota.* Diagrama de secuencia intercontextual que ilustra la propagación del evento de anomalía telemática y la creación de la pre-orden de trabajo preventiva.

##### Escenario 2: Onboarding de Taller y Aprovisionamiento Multi-Tenant

Representa la incorporación de un nuevo taller al ecosistema SaaS. El proceso inicia en **IAM & Tenancy** con el registro del propietario y la verificación de credenciales corporativas, generando el evento `cuenta de usuario creada`. La política asociada delega el aprovisionamiento del espacio de trabajo aislado (*tenant*) y notifica a **SaaS Billing** para activar el periodo de prueba o membresía del plan seleccionado.

![Flujo de Mensajes del Dominio: Onboarding de Taller y Aprovisionamiento Multi-Tenant](report/assets/strategic-ddd/domain-message-flow-scenario-2.png){#fig:dmf-scenario-2}

*Nota.* Interacción entre identidad, gestión de inquilinos y facturación SaaS para la inicialización segura del entorno del taller automotriz.

##### Escenario 3: Generación y Aprobación Digital de Presupuesto MRO

Modela la interacción comercial y de diagnóstico previo a la intervención mecánica. Tras la evaluación del vehículo en patio o el análisis de la alerta telemática, **Workshop Operation** estructura el presupuesto estimando costos de mano de obra y consultando la disponibilidad de repuestos en **Inventory**. Una vez consolidado, se emite el evento `presupuesto mro generado`, permitiendo que el cliente final apruebe el presupuesto digitalmente desde la aplicación móvil *Atelier Driver*.

![Flujo de Mensajes del Dominio: Generación y Aprobación Digital de Presupuesto MRO](report/assets/strategic-ddd/domain-message-flow-scenario-3.png){#fig:dmf-scenario-3}

*Nota.* Flujo colaborativo entre el taller, el cliente y el inventario para la confirmación de presupuestos y reserva preventiva de insumos.

##### Escenario 4: Ejecución de Reparación y Consumo FIFO de Repuestos

Describe el proceso operativo de piso de taller durante el cual los mecánicos ejecutan las tareas asignadas en sus dispositivos móviles. Al requerir partes mecánicas o lubricantes, **Workshop Operation** despacha comandos hacia **Inventory** para ejecutar el consumo contable bajo el algoritmo de Primeras Entradas, Primeras Salidas (FIFO), garantizando la descarga de los lotes correspondientes y disparando alertas si se alcanza el umbral de stock mínimo.

![Flujo de Mensajes del Dominio: Ejecución de Reparación y Consumo FIFO de Repuestos](report/assets/strategic-ddd/domain-message-flow-scenario-4.png){#fig:dmf-scenario-4}

*Nota.* Sincronización entre la ejecución técnica de tareas de mantenimiento y la gestión de lotes de inventario FIFO.

##### Escenario 5: Liquidación y Facturación Electrónica SUNAT

Abarca el cierre económico de la orden de trabajo una vez superadas las pruebas de control de calidad. **Workshop Operation** emite el comando de liquidación hacia el contexto **Invoicing**, el cual estructura el comprobante tributario bajo el estándar UBL 2.1, interactúa con la plataforma Nubefact mediante una Capa Anticorrupción (ACL) y confirma la validez fiscal del documento ante la SUNAT antes de emitir la factura final al cliente.

![Flujo de Mensajes del Dominio: Liquidación y Facturación Electrónica SUNAT](report/assets/strategic-ddd/domain-message-flow-scenario-5.png){#fig:dmf-scenario-5}

*Nota.* Flujo de cierre contable y cumplimiento tributario mediante integración desacoplada con el proveedor de facturación electrónica.

##### Escenario 6: Entrega de Vehículo y Cierre Operativo

Representa el acto formal de entrega del vehículo reparado al cliente en el taller. **Workshop Operation** registra la conformidad del cliente y publica el evento `vehículo entregado al cliente`. Esta notificación desencadena la actualización del estatus en **Customer & Fleet**, solicita la retroalimentación de satisfacción del servicio y notifica a **IoT Telemetry** para restablecer la monitorización telemática predictiva bajo los nuevos parámetros del motor.

![Flujo de Mensajes del Dominio: Entrega de Vehículo y Cierre Operativo](report/assets/strategic-ddd/domain-message-flow-scenario-6.png){#fig:dmf-scenario-6}

*Nota.* Proceso de cierre de ciclo de servicio, entrega física y reactivación del monitoreo telemático vehicular.

#### 2.5.1.3. Bounded Context Canvases

El *Bounded Context Canvas* es una herramienta esencial del diseño estratégico desarrollada por la comunidad de DDD (Nick Tune y DDD Crew). Su objetivo es documentar en una sola página la visión holística de cada contexto: su propósito fundamental, clasificación estratégica, comunicación entrante (eventos y comandos consumidos), comunicación saliente (eventos y comandos publicados), reglas de negocio e invariantes, y agregados clave.

A continuación, se presentan los lienzos detallados para los ocho contextos delimitados del ecosistema Atelier:

##### 1. Bounded Context Canvas: Workshop Operation

Como núcleo operativo del sistema (*Core Domain*), este contexto gobierna la gestión de citas, órdenes de trabajo (OT), asignación de mecánicos a bahías, registro de evidencias fotográficas en foso y control del ciclo de vida de mantenimiento (MRO).

![Bounded Context Canvas: Workshop Operation](report/assets/strategic-ddd/bounded-context-canvas-workshop-operation.png){#fig:bcc-workshop-operation}

*Nota.* Lienzo estratégico del contexto central de operaciones de taller, detallando sus flujos de entrada, salida y raíces de agregado.

##### 2. Bounded Context Canvas: IoT Telemetry

Representa el segundo *Core Domain* de Atelier. Administra la ingesta masiva de lecturas de sensores procedentes de escáneres OBD-II (velocidad, RPM, temperatura de refrigerante, códigos DTC), almacenándolos en hipertablas optimizadas de TimescaleDB y evaluando algoritmos predictivos para la detección temprana de fallas.

![Bounded Context Canvas: IoT Telemetry](report/assets/strategic-ddd/bounded-context-canvas-iot-telemetry.png){#fig:bcc-iot-telemetry}

*Nota.* Lienzo estratégico del contexto de telemetría IoT, describiendo la arquitectura de procesamiento en tiempo real y disparo de alertas predictivas.

##### 3. Bounded Context Canvas: Customer & Fleet

Subdominio de soporte encargado de registrar y gestionar el directorio unificado de conductores particulares, gestores de flotas comerciales y el padrón de vehículos, sirviendo de enlace entre los clientes y el taller automotriz.

![Bounded Context Canvas: Customer & Fleet](report/assets/strategic-ddd/bounded-context-canvas-customer-fleet.png){#fig:bcc-customer-fleet}

*Nota.* Lienzo estratégico del contexto de gestión de clientes y flotas vehiculares.

##### 4. Bounded Context Canvas: Inventory

Subdominio de soporte que controla el aprovisionamiento de repuestos y lubricantes, implementando el algoritmo de costeo FIFO por lotes de adquisición para salvaguardar la rentabilidad contable del taller y gestionar el catálogo de proveedores habituales.

![Bounded Context Canvas: Inventory](report/assets/strategic-ddd/bounded-context-canvas-inventory.png){#fig:bcc-inventory}

*Nota.* Lienzo estratégico del contexto de inventarios y control de compras por lotes bajo valuación FIFO.

##### 5. Bounded Context Canvas: Human Resources

Subdominio de soporte orientado a la administración del talento técnico del taller. Incluye el control de asistencia laboral mediante validación georreferenciada con la fórmula del Haversine sobre geocercas circulares y la liquidación periódica de nóminas de sueldos.

![Bounded Context Canvas: Human Resources](report/assets/strategic-ddd/bounded-context-canvas-human-resources.png){#fig:bcc-human-resources}

*Nota.* Lienzo estratégico del contexto de recursos humanos y asistencia geolocalizada de mecánicos.

##### 6. Bounded Context Canvas: Invoicing

Subdominio genérico encargado del cumplimiento tributario y fiscal. Transforma las liquidaciones de órdenes de trabajo en comprobantes electrónicos homologados bajo la normativa OASIS UBL 2.1 de SUNAT, interactuando con Nubefact a través de adaptadores desacoplados.

![Bounded Context Canvas: Invoicing](report/assets/strategic-ddd/bounded-context-canvas-invoicing.png){#fig:bcc-invoicing}

*Nota.* Lienzo estratégico del contexto de facturación electrónica y cumplimiento fiscal.

##### 7. Bounded Context Canvas: SaaS Billing

Subdominio genérico que gestiona la monetización y el modelo de negocio B2B de Atelier. Administra los planes de suscripción de los talleres mecánicos, facturación recurrente, control de cupos operativos e integración con pasarelas de pago digitales.

![Bounded Context Canvas: SaaS Billing](report/assets/strategic-ddd/bounded-context-canvas-saas-billing.png){#fig:bcc-saas-billing}

*Nota.* Lienzo estratégico del contexto de monetización y suscripciones B2B del SaaS.

##### 8. Bounded Context Canvas: IAM & Tenancy

Subdominio genérico que provee seguridad, autenticación basada en tokens JWT/OAuth 2.0, autorización por roles (RBAC) y la gestión multi-tenant para garantizar el aislamiento criptográfico y lógico de la información entre talleres mecánicos independientes.

![Bounded Context Canvas: IAM & Tenancy](report/assets/strategic-ddd/bounded-context-canvas-iam-tenancy.png){#fig:bcc-iam-tenancy}

*Nota.* Lienzo estratégico del contexto de control de accesos, identidades y gobernanza multi-tenant.

### 2.5.2. *Context Mapping*

El *Context Mapping* (Mapa de Contextos) formaliza las relaciones estructurales, semánticas y de dependencia entre los diferentes *Bounded Contexts* identificados en el ecosistema Atelier. En una arquitectura orientada a eventos y monolítica modular, definir con precisión la dirección de las dependencias (*Upstream* / *Downstream*) y el patrón de integración evita la degradación del modelo y garantiza la autonomía operativa de cada módulo.

Los principales patrones de relación estratégica implementados en la solución corresponden a los preceptos canónicos de DDD:

- **Upstream (U) / Downstream (D):** Define la relación de influencia donde las decisiones del contexto aguas arriba (*Upstream*) impactan directamente en el contexto aguas abajo (*Downstream*).
- **Customer / Supplier (C/S):** El contexto aguas abajo actúa como cliente cuyas necesidades prioritarias condicionan las entregas del contexto proveedor aguas arriba.
- **Anti-Corruption Layer (ACL):** Capa de traducción que aísla el modelo puro del dominio interno frente a esquemas ajenos o dependencias tecnológicas externas (ej. la integración con la API de Nubefact).
- **Open Host Service (OHS) / Published Language (PL):** Protocolo público y estandarizado mediante el cual un contexto ofrece sus capacidades al ecosistema mediante contratos DTO estables y bien documentados.
- **Conformist (CF):** El contexto consumidor acepta y se adapta de manera directa al modelo del contexto proveedor sin intermediar transformaciones semánticas complejas.
- **Shared Kernel (SK):** Núcleo común compartido estrictamente acotado que contiene Value Objects e interfaces transversales utilizadas por todos los contextos (implementado en el módulo `Shared`).

![Diagrama de Context Mapping del Ecosistema Atelier](report/assets/strategic-ddd/context-mapping.png){#fig:context-mapping}

*Nota.* Mapa integral de contextos estratégicos del ecosistema Atelier, representando los tipos de subdominio (Core, Supporting, Generic), los límites de contexto y los patrones de integración U/D, C/S, ACL, OHS/PL y SK.

A continuación, la @tbl:context-mapping-relationships desglosa y fundamenta cada una de las relaciones formales modeladas en el sistema:

| Contexto Upstream (U) | Contexto Downstream (D) | Patrón de Integración | Mecanismo Técnico | Justificación Arquitectónica |
| :--- | :--- | :---: | :--- | :--- |
| IAM & Tenancy | Workshop Operation | OHS / PL | Interfaz interna y tokens JWT | Provee identidad y contexto de inquilino autenticado a las operaciones del taller. |
| IAM & Tenancy | SaaS Billing | OHS / PL | Eventos de dominio (Outbox) | Notifica el registro de nuevas cuentas para activar planes de suscripción. |
| SaaS Billing | Tenancy | C/S | Eventos de cobro y límites | Bloquea o habilita el acceso de los tenants según el estado de pago de su membresía. |
| Customer & Fleet | Workshop Operation | C/S | DTOs de Cita y Vehículo | Suministra los datos del vehículo y cliente necesarios para inicializar la orden MRO. |
| IoT Telemetry | Customer & Fleet | OHS / PL | Eventos telemáticos asíncronos | Transmite anomalías detectadas para desplegarlas en la app móvil *Atelier Driver*. |
| IoT Telemetry | Workshop Operation | OHS / PL | Eventos de alerta de falla | Habilita la apertura proactiva de pre-órdenes preventivas en el taller. |
| Workshop Operation | Inventory | C/S | Comandos y eventos de consumo | Solicita reservas de repuestos y ejecuta bajas contables bajo método FIFO. |
| Workshop Operation | Invoicing | C/S | DTO de liquidación de OT | Provee el desglose económico de mano de obra y repuestos para emisión de comprobantes. |
| Invoicing | SUNAT / Nubefact | ACL | Adaptador HTTP REST JSON v1 | Traduce la factura de dominio interno al formato UBL 2.1 exigido por la autoridad fiscal. |
| Human Resources | Workshop Operation | OHS / PL | Consultas de disponibilidad | Valida que los mecánicos asignados a una orden tengan asistencia registrada en patio. |
| Shared (Transversal) | Todos los Contextos | Shared Kernel (SK) | Biblioteca de tipos inmutables | Comparte tipos fundamentales (`Money`, `Quantity`, `GeoPoint`, `TaxId`) sin duplicidad. |
: Matriz de Relaciones y Patrones de Integración en el Context Mapping {#tbl:context-mapping-relationships}

*Nota.* Matriz elaborada por el equipo para detallar las interacciones intercontextuales de la arquitectura de software.

\newpage