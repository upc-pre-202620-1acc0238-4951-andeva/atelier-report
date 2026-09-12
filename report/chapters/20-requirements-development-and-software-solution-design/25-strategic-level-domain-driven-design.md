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

1. **Fase 1: Exploración Caótica de Eventos de Dominio:** Los participantes generaron sin restricciones iniciales todos los eventos concebibles que ocurren a lo largo del ciclo de vida automotriz (@fig:es-step-1).

![EventStorming Paso 1: Recolección de Eventos del Dominio](/assets/strategic-ddd/event-storming-step-1-events.png){#fig:es-step-1}

*Nota.* Lluvia de ideas inicial con notas adhesivas naranjas registrando los eventos consumados del dominio automotriz en participio pasado.

2. **Fase 2: Ordenamiento Temporal y Línea de Tiempo:** Se organizaron los eventos en secuencias cronológicas concurrentes para modelar la línea de tiempo principal del taller y los flujos de soporte (@fig:es-step-2-1 y @fig:es-step-2-2).

![EventStorming Paso 2: Línea de Tiempo - Identidad, Clientes, Telemetría y Operaciones](/assets/strategic-ddd/event-storming-step-2-timeline-1.png){#fig:es-step-2-1}

*Nota.* Secuenciación temporal de eventos para los carriles operativos principales.

![EventStorming Paso 2: Línea de Tiempo - Inventario, Asistencia, Facturación y Suscripción](/assets/strategic-ddd/event-storming-step-2-timeline-2.png){#fig:es-step-2-2}

*Nota.* Secuenciación temporal de eventos para los carriles de soporte administrativo y financiero.

3. **Fase 3: Identificación de Disparadores y Comandos:** Se identificaron las causas de cada evento de dominio, determinando qué comandos específicos en color azul emitidos por actores o sistemas desencadenaron las transiciones de estado (@fig:es-step-3-1 y @fig:es-step-3-2).

![EventStorming Paso 3: Identificación de Comandos (Parte 1)](/assets/strategic-ddd/event-storming-step-3-commands-1.png){#fig:es-step-3-1}

*Nota.* Inserción de notas azules correspondientes a las intenciones de usuario y directivas del sistema.

![EventStorming Paso 3: Identificación de Comandos (Parte 2)](/assets/strategic-ddd/event-storming-step-3-commands-2.png){#fig:es-step-3-2}

*Nota.* Mapeo de comandos para los flujos de almacén, recursos humanos, facturación y cobros.

4. **Fase 4: Formulación de Políticas Reactivas y Actores:** Se asociaron los roles de usuario (notas amarillas) y las políticas reactivas en color morado que rigen la interacción intermodular sin acoplamiento temporal directo (@fig:es-step-4-1 y @fig:es-step-4-2).

![EventStorming Paso 4: Políticas Reactivas y Actores (Parte 1)](/assets/strategic-ddd/event-storming-step-4-policies-actors-1.png){#fig:es-step-4-1}

*Nota.* Vinculación de actores operativos y formulación de reglas condicionales "Cuando [Evento], Entonces [Comando]".

![EventStorming Paso 4: Políticas Reactivas y Actores (Parte 2)](/assets/strategic-ddd/event-storming-step-4-policies-actors-2.png){#fig:es-step-4-2}

*Nota.* Mapeo de políticas para la validación georreferenciada de asistencia y disparo de liquidación contable.

5. **Fase 5: Modelado de Interfaces de Información y Vistas de Lectura:** Se estructuraron los modelos de lectura en notas verdes (*Read Models*) necesarios para que los usuarios tomen decisiones operativas informadas antes de emitir un comando (@fig:es-step-5-1 y @fig:es-step-5-2).

![EventStorming Paso 5: Modelos de Lectura (Read Models) (Parte 1)](/assets/strategic-ddd/event-storming-step-5-read-models-1.png){#fig:es-step-5-1}

*Nota.* Proyecciones visuales requeridas en la interfaz de usuario para la asignación de bahías y seguimiento de fallas.

![EventStorming Paso 5: Modelos de Lectura (Read Models) (Parte 2)](/assets/strategic-ddd/event-storming-step-5-read-models-2.png){#fig:es-step-5-2}

*Nota.* Vistas informativas para el control de asistencia, saldos de stock FIFO y tarifas de suscripción.

6. **Fase 6: Detección de Fronteras e Integraciones Externas:** Se aislaron las responsabilidades delegadas a plataformas y servicios externos mediante notas rosas (@fig:es-step-6-1 y @fig:es-step-6-2).

![EventStorming Paso 6: Detección de Sistemas Externos (Parte 1)](/assets/strategic-ddd/event-storming-step-6-external-systems-1.png){#fig:es-step-6-1}

*Nota.* Identificación de hardware OBD-II, Firebase Storage y servicios de mensajería externa.

![EventStorming Paso 6: Detección de Sistemas Externos (Parte 2)](/assets/strategic-ddd/event-storming-step-6-external-systems-2.png){#fig:es-step-6-2}

*Nota.* Delimitación de fronteras de integración hacia Nubefact (SUNAT), Stripe y Google Maps Geolocation.

7. **Fase 7: Consolidación de Agregados:** Se delimitaron las unidades de consistencia transaccional e invariantes mediante notas amarillo mostaza (*Aggregates*) (@fig:es-step-7-1 y @fig:es-step-7-2).

![EventStorming Paso 7: Consolidación de Agregados (Parte 1)](/assets/strategic-ddd/event-storming-step-7-aggregates-1.png){#fig:es-step-7-1}

*Nota.* Identificación de raíces de agregado clave como `WorkOrder`, `Vehicle`, `Appointment` y `DiagnosticAlert`.

![EventStorming Paso 7: Consolidación de Agregados (Parte 2)](/assets/strategic-ddd/event-storming-step-7-aggregates-2.png){#fig:es-step-7-2}

*Nota.* Identificación de agregados para gestión de lotes FIFO, planillas laborales y comprobantes fiscales.

8. **Fase 8: Delimitación de Bounded Contexts:** A partir de la cohesión semántica y transaccional, se trazaron los límites contextuales definitivos que agrupan los subdominios del sistema (@fig:es-step-8).

![EventStorming Paso 8: Delimitación de Bounded Contexts y Flujos de Mensajes](/assets/strategic-ddd/event-storming-step-8-bounded-contexts.png){#fig:es-step-8}

*Nota.* Agrupación final de los ocho Bounded Contexts y visualización de los canales de comunicación asíncrona.

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

A continuación, se documentan los seis escenarios operativos fundamentales del ecosistema Atelier:

**Escenario 1: Detección de Falla Telemática y Alerta Preventiva**

Este flujo modela el ciclo de vida del monitoreo telemático vehicular continuo. Cuando el escáner OBD-II emite lecturas de parámetros del motor, el contexto **IoT Telemetry** ingesta los flujos y evalúa posibles desviaciones críticas. Al detectarse una anomalía, se genera el evento `código de falla fue detectado`, desencadenando la emisión de una alerta preventiva hacia **Customer & Fleet** para informar al conductor y coordinar la cita de revisión, y hacia **Workshop Operation** para la apertura de la orden correspondiente.

![Flujo de Mensajes: Escenario 1 - Detección de Falla Telemática y Alerta Preventiva](/assets/strategic-ddd/domain-message-flow-scenario-1.png){#fig:dmf-scenario-1}

*Nota.* Diagrama de flujo de mensajes intercontextual para la captura telemática y generación de alertas preventivas.

**Escenario 2: Recepción del Vehículo y Diagnóstico de Taller**

Modela la llegada del vehículo al taller automotriz. El asesor de servicio registra la recepción pericial capturando las evidencias fotográficas de carrocería y kilometraje. Al formalizarse el ingreso, **Workshop Operation** genera la orden de trabajo, vincula la cita confirmada proveniente de **Customer & Fleet**, asigna la bahía correspondiente y encarga al mecánico el diagnóstico computarizado por puerto OBD-II.

![Flujo de Mensajes: Escenario 2 - Recepción del Vehículo y Diagnóstico de Taller](/assets/strategic-ddd/domain-message-flow-scenario-2.png){#fig:dmf-scenario-2}

*Nota.* Diagrama de flujo de mensajes intercontextual para la recepción, apertura de orden y asignación diagnóstica.

**Escenario 3: Preparación y Aprobación de Presupuesto**

Abarca la formulación de la propuesta técnico-económica de reparación (MRO). Concluida la inspección, el personal de taller elabora el presupuesto calculando los costos de mano de obra y consultando la disponibilidad de repuestos en el contexto **Inventory**. Una vez estructurada la cotización, se emite para que el cliente la revise y la autorice digitalmente desde la aplicación móvil *Atelier Driver*.

![Flujo de Mensajes: Escenario 3 - Preparación y Aprobación de Presupuesto](/assets/strategic-ddd/domain-message-flow-scenario-3.png){#fig:dmf-scenario-3}

*Nota.* Diagrama de flujo de mensajes intercontextual para la verificación de insumos y aprobación formal del presupuesto.

**Escenario 4: Reserva y Despacho de Repuestos por FIFO**

Describe el flujo de piso durante el desensamble y sustitución de piezas. Al autorizarse el trabajo, **Workshop Operation** remite el comando de reserva hacia **Inventory**, contexto que bloquea las unidades requeridas y las descarga contablemente imputando el costo del lote más antiguo disponible bajo el método FIFO. Si el nivel de inventario alcanza el límite de seguridad, el contexto emite automáticamente una alerta de reabastecimiento hacia el módulo de proveedores.

![Flujo de Mensajes: Escenario 4 - Reserva y Despacho de Repuestos por FIFO](/assets/strategic-ddd/domain-message-flow-scenario-4.png){#fig:dmf-scenario-4}

*Nota.* Diagrama de flujo de mensajes intercontextual para la reserva física y liquidación contable de insumos por FIFO.

**Escenario 5: Control de Calidad y Finalización de Reparación**

Representa la verificación técnica posterior a la ejecución mecánica. El técnico mecánico reporta el fin de sus tareas asignadas y adjunta la evidencia fotográfica del trabajo realizado. El Jefe de Taller realiza las pruebas de validación técnica (*Quality Gate*); una vez certificada la conformidad del estándar de calidad, se emite el evento de culminación de reparación para habilitar el cierre administrativo.

![Flujo de Mensajes: Escenario 5 - Control de Calidad y Finalización de Reparación](/assets/strategic-ddd/domain-message-flow-scenario-5.png){#fig:dmf-scenario-5}

*Nota.* Diagrama de flujo de mensajes intercontextual para la aprobación pericial y cierre técnico de la orden de trabajo.

**Escenario 6: Entrega de Vehículo y Facturación Electrónica SUNAT**

Comprende el acto formal de liquidación, facturación fiscal y entrega final al cliente. Con la orden cerrada, se envían los conceptos liquidados al contexto **Invoicing**, el cual estructura el comprobante de pago electrónico bajo el estándar UBL 2.1 y lo valida ante la SUNAT mediante la Capa Anticorrupción de Nubefact. Tras la confirmación del pago y la obtención de la Constancia de Recepción (CDR), se efectúa la entrega física de la unidad y se reactiva la monitorización telemática.

![Flujo de Mensajes: Escenario 6 - Entrega de Vehículo y Facturación Electrónica SUNAT](/assets/strategic-ddd/domain-message-flow-scenario-6.png){#fig:dmf-scenario-6}

*Nota.* Diagrama de flujo de mensajes intercontextual para la liquidación tributaria ante SUNAT y entrega formal del vehículo.

#### 2.5.1.3. Bounded Context Canvases

El *Bounded Context Canvas* es una herramienta esencial del diseño estratégico desarrollada por la comunidad de DDD (Nick Tune y DDD Crew). Su objetivo es documentar en una sola página la visión holística de cada contexto: su propósito fundamental, clasificación estratégica, comunicación entrante (eventos y comandos consumidos), comunicación saliente (eventos y comandos publicados), reglas de negocio e invariantes, y agregados clave.

A continuación, se presentan los lienzos detallados para los ocho contextos delimitados del ecosistema Atelier:

**Bounded Context Canvas: Workshop Operation**

Como núcleo operativo del sistema (*Core Domain*), este contexto gobierna la gestión de citas, órdenes de trabajo (OT), asignación de mecánicos a bahías, registro de evidencias fotográficas en foso y control del ciclo de vida de mantenimiento (MRO).

![Bounded Context Canvas: Workshop Operation](/assets/strategic-ddd/bounded-context-canvas-workshop-operation.png){#fig:bcc-workshop-operation}

*Nota.* Lienzo estratégico del contexto central de operaciones de taller, detallando sus flujos de entrada, salida y raíces de agregado.

**Bounded Context Canvas: IoT Telemetry**

Representa el segundo *Core Domain* de Atelier. Administra la ingesta masiva de lecturas de sensores procedentes de escáneres OBD-II (velocidad, RPM, temperatura de refrigerante, códigos DTC), almacenándolos en hipertablas optimizadas de TimescaleDB y evaluando algoritmos predictivos para la detección temprana de fallas.

![Bounded Context Canvas: IoT Telemetry](/assets/strategic-ddd/bounded-context-canvas-iot-telemetry.png){#fig:bcc-iot-telemetry}

*Nota.* Lienzo estratégico del contexto de telemetría IoT, describiendo la arquitectura de procesamiento en tiempo real y disparo de alertas predictivas.

**Bounded Context Canvas: Customer & Fleet**

Subdominio de soporte encargado de registrar y gestionar el directorio unificado de conductores particulares, gestores de flotas comerciales y el padrón de vehículos, sirviendo de enlace entre los clientes y el taller automotriz.

![Bounded Context Canvas: Customer & Fleet](/assets/strategic-ddd/bounded-context-canvas-customer-fleet.png){#fig:bcc-customer-fleet}

*Nota.* Lienzo estratégico del contexto de gestión de clientes y flotas vehiculares.

**Bounded Context Canvas: Inventory**

Subdominio de soporte que controla el aprovisionamiento de repuestos y lubricantes, implementando el algoritmo de costeo FIFO por lotes de adquisición para salvaguardar la rentabilidad contable del taller y gestionar el catálogo de proveedores habituales.

![Bounded Context Canvas: Inventory](/assets/strategic-ddd/bounded-context-canvas-inventory.png){#fig:bcc-inventory}

*Nota.* Lienzo estratégico del contexto de inventarios y control de compras por lotes bajo valuación FIFO.

**Bounded Context Canvas: Human Resources**

Subdominio de soporte orientado a la administración del talento técnico del taller. Incluye el control de asistencia laboral mediante validación georreferenciada con la fórmula del Haversine sobre geocercas circulares y la liquidación periódica de nóminas de sueldos.

![Bounded Context Canvas: Human Resources](/assets/strategic-ddd/bounded-context-canvas-human-resources.png){#fig:bcc-human-resources}

*Nota.* Lienzo estratégico del contexto de recursos humanos y asistencia geolocalizada de mecánicos.

**Bounded Context Canvas: Invoicing**

Subdominio genérico encargado del cumplimiento tributario y fiscal. Transforma las liquidaciones de órdenes de trabajo en comprobantes electrónicos homologados bajo la normativa OASIS UBL 2.1 de SUNAT, interactuando con Nubefact a través de adaptadores desacoplados.

![Bounded Context Canvas: Invoicing](/assets/strategic-ddd/bounded-context-canvas-invoicing.png){#fig:bcc-invoicing}

*Nota.* Lienzo estratégico del contexto de facturación electrónica y cumplimiento fiscal.

**Bounded Context Canvas: SaaS Billing**

Subdominio genérico que gestiona la monetización y el modelo de negocio B2B de Atelier. Administra los planes de suscripción de los talleres mecánicos, facturación recurrente, control de cupos operativos e integración con pasarelas de pago digitales.

![Bounded Context Canvas: SaaS Billing](/assets/strategic-ddd/bounded-context-canvas-saas-billing.png){#fig:bcc-saas-billing}

*Nota.* Lienzo estratégico del contexto de monetización y suscripciones B2B del SaaS.

**Bounded Context Canvas: IAM & Tenancy**

Subdominio genérico que provee seguridad, autenticación basada en tokens JWT/OAuth 2.0, autorización por roles (RBAC) y la gestión multi-tenant para garantizar el aislamiento criptográfico y lógico de la información entre talleres mecánicos independientes.

![Bounded Context Canvas: IAM & Tenancy](/assets/strategic-ddd/bounded-context-canvas-iam-tenancy.png){#fig:bcc-iam-tenancy}

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

![Diagrama de Context Mapping del Ecosistema Atelier](/assets/strategic-ddd/context-mapping.png){#fig:context-mapping}

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