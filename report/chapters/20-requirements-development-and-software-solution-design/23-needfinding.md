## 2.3. *Needfinding*



### 2.3.1. *User Personas*

En esta sección se describen dos User Personas que representan los segmentos clave a los que está dirigida la plataforma Atelier: los Propietarios y Administradores de Talleres, así como el Personal Operativo integrado por Técnicos y Mecánicos. A través de estos perfiles se profundiza en sus necesidades, motivaciones, frustraciones y hábitos digitales, con la finalidad de diseñar una solución bajo el modelo Software as a Service (SaaS) y principio Bring Your Own Device (BYOD) que optimice la gestión del negocio, reduzca los tiempos muertos y facilite el monitoreo preventivo mediante la lectura de datos OBD2.

**Segmento 1**

![User Persona 1](../../assets/NeedFinding/User-Personas/User-Persona-Cesar-Nikolay.png)

El User Persona de Jorge Aguilar representa al Segmento 1: Personal de Gestión y Propietarios de Taller. A sus 53 años y con más de tres décadas de experiencia en el rubro automotriz, Jorge lidera de forma independiente un servicio mecánico de campo enfocado en maquinaria y unidades estacionarias. Su día a día combina la ejecución técnica con la administración general del negocio, por lo que busca herramientas sencillas que le permitan mantener una comunicación transparente con sus clientes y recomendar mantenimientos preventivos oportunos. Su principal motivación es garantizar la rentabilidad y reputación de su empresa, mientras que sus mayores frustraciones radican en la sobrecarga de trabajo al gestionar la operación en solitario, la resistencia de algunos clientes a realizar mantenimientos antes de una avería grave y la falta de visibilidad del estado de los vehículos cuando no se encuentra presente en el lugar.

**Segmento 2**

![User Persona 2](../../assets/NeedFinding/User-Personas/User-Persona-Jorge-Aguilar.png)

Por otro lado, el User Persona de Nicolai encarna al Segmento 2: Personal Operativo del Taller. Como técnico especialista en diagnóstico y mantenimiento de 23 años, Nicolai trabaja en un entorno de alta exigencia donde utiliza escáneres computarizados para la lectura de flujos de datos por puerto OBD2. Altamente familiarizado con el uso de smartphones Android, busca optimizar su flujo de trabajo y reducir los tiempos muertos causados por la desorganización en la aprobación de repuestos o presupuestos. Sus metas profesionales se centran en obtener certificaciones en mecatrónica automotriz y ascender hacia la gestión de centros de servicio estandarizados. No obstante, se enfrenta a la imprecisión del registro manual de sus tiempos de reparación, la falta de señal en fosos de inspección y el uso de canales de comunicación informales que traspapelan la información técnica, obligándolo a guardar respaldos fotográficos en su teléfono personal para evidenciar el volumen real de sus tareas completadas.

### 2.3.2. *User Task Matrix*



### 2.3.3. *User Journey Mapping*



### 2.3.4. *Empathy Mapping*



### 2.3.5. *Big Picture EventStorming*

Como parte fundamental de la fase de exploración y comprensión de necesidades (*Needfinding*), el equipo llevó a cabo un taller colaborativo de **Big Picture EventStorming**. Esta dinámica, concebida por Alberto Brandolini, tuvo como propósito construir un modelo mental compartido y sinérgico entre todos los integrantes sobre la totalidad del ciclo de vida operativo del ecosistema **Atelier**, identificando las interacciones entre los diferentes actores, los puntos de fricción (*hotspots*), los cuellos de botella en la gestión de talleres y las oportunidades para la automatización mediante telemetría IoT.

A diferencia del modelado detallado a nivel de diseño de software, el nivel *Big Picture* se enfoca en la visión panorámica del negocio, permitiendo alinear la comprensión del flujo de valor antes de formular límites técnicos rígidos. El resultado de esta exploración integral en la herramienta colaborativa Miro se sintetiza en la @fig:big-picture-eventstorming.

![Big Picture EventStorming del Ecosistema Atelier](report/assets/strategic-ddd/big-picture-event-storming.png){#fig:big-picture-eventstorming}

*Nota.* Vista panorámica del taller de Big Picture EventStorming elaborado por el equipo en Miro, trazando los eventos de dominio desde la ingesta de telemetría hasta el cierre de la orden de trabajo.

El recorrido del dominio modelado en el Big Picture abarca los siguientes momentos clave de la operativa automotriz:

1. **Aprovisionamiento y Configuración:** Registro inicial del taller mecánico, definición de sucursales, alta de bahías de servicio y configuración de planes de suscripción.
2. **Monitoreo Telemático Continuo:** Ingesta en tiempo real de flujos de datos vehiculares provenientes de escáneres OBD-II y evaluación analítica de umbrales críticos de temperatura, presión y códigos DTC.
3. **Recepción e Inspección Diagnóstica:** Generación de citas, ingreso del vehículo a patio, inspección visual con evidencia fotográfica y formulación del presupuesto de mantenimiento (MRO).
4. **Aprobación Digital y Asignación Operativa:** Validación del presupuesto por parte del cliente desde la app móvil y distribución de tareas específicas a los técnicos mecánicos según especialidad.
5. **Ejecución Mecánica y Abastecimiento FIFO:** Registro del avance de reparación en patio móvil y descarga contable de repuestos y fluidos bajo el método de Primeras Entradas, Primeras Salidas (FIFO).
6. **Liquidación y Cumplimiento Tributario:** Consolidación de costos de mano de obra e insumos, emisión electrónica de Boletas o Facturas UBL 2.1 validadas ante SUNAT.
7. **Entrega y Seguimiento Predictivo:** Devolución del vehículo reparado al cliente, solicitud de retroalimentación de servicio y reactivación del monitoreo telemático predictivo.

### 2.3.6. *Ubiquitous Language*

Uno de los aportes más trascendentales de *Domain-Driven Design* es la consolidación de un **Lenguaje Ubicuo** (*Ubiquitous Language*). Este lenguaje consiste en un vocabulario compartido, riguroso y sin ambigüedades, adoptado de manera unánime tanto por los expertos del dominio automotriz (mecánicos, administradores de taller) como por los ingenieros de software, analistas y diseñadores de UX.

El empleo de un lenguaje ubicuo erradica las fallas de comunicación y la sobrecarga de traducción en el código fuente, garantizando que los nombres de las clases, métodos, eventos, comandos y tablas de base de datos reflejen exactamente la terminología del negocio. La @tbl:ubiquitous-language recopila los términos esenciales del ecosistema Atelier, su definición formal y el ámbito de aplicación correspondiente:

| Término en el Dominio | Definición Formal y Regla de Negocio Asociada | Ámbito / Contexto |
| :--- | :--- | :---: |
| Atelier Workshop | Plataforma digital orientada a la gestión B2B de talleres automotrices, disponible en WebApp (escritorio para gestión) y Mobile (patio para mecánicos). | Transversal B2B |
| Atelier Driver | Aplicación móvil orientada a clientes particulares y administradores de flotas para seguimiento telemático, aprobación de presupuestos y citas. | Transversal B2C |
| Orden de Trabajo (OT) | Documento y raíz de agregado que centraliza la ejecución técnica, evidencias fotográficas, tareas y consumo de insumos de una intervención. | Workshop Operation |
| Tarea MRO | Unidad atómica de trabajo mecánico asignada a un técnico específico dentro de una Orden de Trabajo, con seguimiento de estados y horas hombre. | Workshop Operation |
| Presupuesto MRO | Propuesta económica preliminar estructurada tras el diagnóstico que detalla costos de mano de obra y repuestos para aprobación del cliente. | Workshop Operation |
| Telemetría OBD-II | Flujo continuo de parámetros vehiculares normalizados (velocidad, RPM, temperatura) capturados desde el puerto de diagnóstico a bordo del motor. | IoT Telemetry |
| DTC (Diagnostic Trouble Code) | Código estandarizado alfanumérico generado por la ECU del vehículo para señalar una falla específica en alguno de sus subsistemas mecánicos. | IoT Telemetry |
| Lote de Inventario (Batch) | Conjunto homogéneo de repuestos o insumos adquiridos en una misma fecha y costo de compra, con stock físico y número de factura asociado. | Inventory |
| Método FIFO | Regla contable estricta de Primeras Entradas, Primeras Salidas donde los repuestos se descargan siempre del lote más antiguo disponible. | Inventory |
| Geocerca Circular | Zona geográfica delimitada por un radio en metros alrededor de una coordenada satelital para control de asistencia de mecánicos en patio. | Human Resources |
| Comprobante Electrónico (CPE) | Documento tributario formal (Boleta o Factura) emitido bajo el estándar UBL 2.1 ante SUNAT mediante la integración con Nubefact. | Invoicing |
| Tenant (Inquilino) | Instancia lógica aislada correspondiente a una empresa o taller automotriz que garantiza privacidad y confidencialidad multi-tenant absoluta. | IAM & Tenancy |
| Transactional Outbox | Patrón arquitectónico de persistencia transaccional que asegura la entrega garantizada y asíncrona de eventos de dominio intermodulares. | Shared / Plataforma |
: Glosario de Lenguaje Ubicuo del Ecosistema Atelier {#tbl:ubiquitous-language}

*Nota.* Tabla de terminología canónica elaborada por el equipo para alinear la comunicación técnica y de negocio.

\newpage