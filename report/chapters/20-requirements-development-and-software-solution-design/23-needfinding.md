## 2.3. *Needfinding*

El proceso de Needfinding constituye la fase metodológica orientada a descubrir, comprender y estructurar las necesidades reales, expectativas operativas y fricciones latentes de los usuarios que integran el ecosistema del taller automotriz. A través de este análisis, se transforma la evidencia empírica recolectada en el trabajo de campo en una base sólida para el diseño de la solución tecnológica, garantizando que cada capacidad de la plataforma responda a una problemática constatada en el entorno laboral.

Para articular estos hallazgos de forma rigurosa, en esta sección se presentan y analizan los artefactos analíticos desarrollados por el equipo de ingeniería: **User Personas**, **User Task Matrix**, **User Journey Mapping**, **Empathy Mapping**, **Big Picture EventStorming** y **Ubiquitous Language**.

### 2.3.1. *User Personas*

En esta sección se desarrollan las fichas de User Persona representativas de los dos segmentos objetivo del ecosistema Atelier: el Personal de Gestión y Propietarios del Taller (Segmento 1) y el Personal Operativo del Taller (Segmento 2). La construcción de estos perfiles sintetiza de manera directa los hallazgos cuantitativos y cualitativos obtenidos en el consolidado de entrevistas de la @tbl:analisis-entrevistas-segmento-1 y la @tbl:analisis-entrevistas-segmento-2, complementados con las brechas detectadas en la matriz de competidores de la @tbl:analisis-competitivo.

Por un lado, el análisis de la competencia evidenció que las soluciones actuales en el mercado peruano y regional, tales como Mi Taller CRM u OK CAR, presentan interfaces web rígidas para escritorio y carecen de conexión telemática directa con la computadora del vehículo. Por otro lado, la investigación de campo constató que el personal directivo asume una sobrecarga administrativa manual mientras gestiona el negocio mediante teléfonos móviles Android y canales como WhatsApp. En paralelo, los técnicos de patio operan bajo métodos tradicionales basados en papel, padeciendo tiempos muertos logísticos y experimentando caídas de señal en fosos de inspección.

A partir de estas premisas, se diseñaron dos fichas de arquetipos utilizando la herramienta especializada UXPressia. Cada ficha modela exhaustivamente la demografía, entorno laboral, metas, frustraciones, habilidades técnicas, canales de comunicación, tecnologías empleadas y marcas de influencia.

**Segmento 1: Personal de Gestión y Propietarios del Taller**

El primer arquetipo representa al dueño y administrador de la micro o pequeña empresa automotriz, encarnado en la figura de **Pedro Suárez**. En la @fig:user-persona-pedro-suarez se detalla su ficha de caracterización integral:

![User Persona 1: Pedro Suárez - Personal de Gestión y Propietarios del Taller](report/assets/NeedFinding/User-Personas/User-Persona-Pedro-Suárez.png){#fig:user-persona-pedro-suarez}

*Nota.* Ficha de User Persona elaborada en la herramienta UXPressia correspondiente al Segmento 1, sintetizada a partir del consolidado estadístico de entrevistas y la evaluación del panorama competitivo.

El perfil de Pedro Suárez sintetiza la tensión operativa existente entre una dilatada trayectoria técnica de más de tres décadas y la necesidad ineludible de conducir la administración integral de su negocio. Pedro combina la atención directa y el servicio de campo itinerante con la gestión de presupuestos y cobranzas, modelo en el cual su principal factor de fidelización es el asesoramiento honesto y el mantenimiento preventivo orientado a evitar averías costosas en las unidades de sus clientes.

No obstante, su principal fricción radica en absorber en solitario tareas de control de inventarios, cuadre de caja y facturación manual, lo cual le genera sobrecarga y le resta horas productivas en la bahía de servicio. Al operar habitualmente mediante su teléfono inteligente Android y coordinar pedidos vía WhatsApp, la viabilidad de su negocio depende de incorporar una plataforma SaaS ligera que automatice el seguimiento de servicios y la facturación electrónica bajo el Régimen MYPE Tributario, reduciendo la dependencia del papel sin imponer una curva de aprendizaje compleja.

**Segmento 2: Personal Operativo del Taller**

El segundo arquetipo corresponde a los técnicos de mantenimiento y diagnóstico que ejecutan el trabajo directo sobre las unidades vehiculares, encarnado en la figura de **Andrés Vílchez**. En la @fig:user-persona-andres-vilchez se ilustra su ficha analítica:

![User Persona 2: Andrés Vílchez - Personal Operativo del Taller](report/assets/NeedFinding/User-Personas/User-Persona-Andrés-Vílchez.png){#fig:user-persona-andres-vilchez}

*Nota.* Ficha de User Persona elaborada en la herramienta UXPressia correspondiente al Segmento 2, sintetizada a partir del consolidado estadístico de entrevistas y la evaluación del panorama competitivo.

El perfil de Andrés Vílchez refleja la realidad del técnico joven egresado de carreras de mecatrónica y mecánica automotriz, caracterizado por su destreza en el manejo de escáneres multimarca, lectura de códigos DTC y diagnóstico de sistemas de inyección electrónica. A pesar de su fluidez digital nativa y su disposición a operar bajo procedimientos rigurosos para evitar roturas de componentes bajo presión, su ritmo de trabajo diario se ve afectado por tiempos muertos derivados de demoras en la aprobación de presupuestos o abastecimiento tardío de repuestos.

Asimismo, Andrés depende obligatoriamente de órdenes de trabajo físicas en papel y carece de un sistema formal para acreditar las horas reales invertidas en cada labor, viéndose en la necesidad de tomar fotografías con su teléfono personal para respaldar su desempeño ante posibles observaciones. Esta situación exige una aplicación móvil de uso rudo para la bahía con arquitectura *Offline-First*, capaz de sincronizar datos cuando se trabaja en fosos sin cobertura y de registrar evidencias fotográficas y mediciones telemétricas OBD-II de forma transparente e inmutable.

### 2.3.2. *User Task Matrix*

En esta sección se presenta el User Task Matrix, artefacto analítico que concentra y evalúa las actividades habituales que desempeñan los arquetipos de usuario, representados por **Pedro Suárez** en la gestión del negocio y **Andrés Vílchez** en la labor técnica operativa, para alcanzar sus objetivos laborales cotidianos. En el marco de Needfinding, las tareas analizadas corresponden a los procedimientos habituales que los actores ejecutan en el taller mecánico con independencia de cualquier solución de software.

En la @tbl:user-task-matrix se detalla la matriz comparativa consolidada, clasificando cada tarea según su escala de frecuencia (Diaria, Semanal, Mensual, Ocasional o Constante) y su nivel de importancia operativa (Crítica, Alta, Media o Baja):

\begin{table}[H]
\centering
\small
\renewcommand{\arraystretch}{1.2}
\caption{User Task Matrix de los Arquetipos de Usuario}
\label{tbl:user-task-matrix}
\begin{tabularx}{\textwidth}{| p{5.5cm} | >{\centering\arraybackslash}X | >{\centering\arraybackslash}X | >{\centering\arraybackslash}X | >{\centering\arraybackslash}X |}
\hline
\multirow{2}{*}{\textbf{Tarea del Taller Automotriz}} & \multicolumn{2}{c|}{\textbf{Pedro Suárez (Gestión)}} & \multicolumn{2}{c|}{\textbf{Andrés Vílchez (Operativo)}} \\
\cline{2-5}
& \textbf{Frecuencia} & \textbf{Importancia} & \textbf{Frecuencia} & \textbf{Importancia} \\
\hline
Recepción presencial de vehículos y registro del motivo de ingreso en orden física & Diaria & Crítica & N/A & N/A \\
\hline
Inspección visual y diagnóstico computarizado con escáner automotriz & Ocasional & Alta & Diaria & Crítica \\
\hline
Elaboración manual de presupuestos y cotizaciones de reparación & Diaria & Alta & N/A & N/A \\
\hline
Coordinación telefónica y confirmación de presupuestos con el cliente & Constante & Crítica & N/A & N/A \\
\hline
Espera de autorización de presupuestos o entrega de repuestos en bahía & Constante & Media & Constante & Alta \\
\hline
Búsqueda, cotización y compra de repuestos a distribuidores locales & Diaria & Crítica & N/A & N/A \\
\hline
Solicitud y retiro de repuestos e insumos en el almacén del taller & Semanal & Media & Constante & Alta \\
\hline
Ejecución física de servicios mecánicos, afinamiento y reparación eléctrica & Ocasional & Media & Diaria & Crítica \\
\hline
Pruebas de funcionamiento, control de calidad y borrado de fallas & Ocasional & Alta & Diaria & Alta \\
\hline
Captura de fotografías con celular personal de piezas dañadas o faltantes & Ocasional & Media & Diaria & Media \\
\hline
Apunte manual de horas laboradas y firma de la orden de trabajo física & Diaria & Media & Diaria & Alta \\
\hline
Cobro directo al cliente, cuadre diario de caja y emisión de comprobantes & Diaria & Crítica & N/A & N/A \\
\hline
Entrega física del vehículo y orientación técnica preventiva al cliente & Diaria & Alta & Ocasional & Media \\
\hline
Consulta de diagramas técnicos y manuales de taller en internet & Ocasional & Media & Ocasional & Alta \\
\hline
\end{tabularx}
\end{table}

*Nota.* Consolidado comparativo de tareas operativas y administrativas habituales en el taller mecánico evaluadas según su nivel de recurrencia e impacto. N/A indica que la tarea no forma parte de las responsabilidades habituales del arquetipo.

**Análisis de Tareas con Mayor Frecuencia e Importancia**

La evaluación de la matriz confirma que las tareas de mayor frecuencia e impacto crítico en el perfil de Pedro Suárez se concentran en la gestión comercial y financiera del negocio. Actividades como la recepción presencial de unidades, la cotización manual, la compra de repuestos a distribuidores y el cobro o cuadre de caja se ejecutan con periodicidad diaria y prioridad crítica. Esta concentración evidencia que el administrador asume la totalidad de las responsabilidades mercantiles y de caja, convirtiéndose en el principal cuello de botella operativo cuando se acumulan consultas simultáneas o trámites de proveedores.

Por su parte, en el perfil de Andrés Vílchez las actividades de máxima criticidad y frecuencia diaria se centran en el trabajo técnico dentro de la bahía: el diagnóstico computarizado con escáner multimarca y la ejecución física de reparaciones mecánicas y eléctricas. No obstante, la tarea que mayor fricción genera en su jornada es la espera forzosa por aprobación de presupuestos o abastecimiento de piezas, la cual ostenta una frecuencia constante e importancia alta; esta inactividad involuntaria inmoviliza vehículos en los elevadores y merma directamente sus métricas de rendimiento diario.

**Coincidencias Operativas entre Arquetipos**

Al contrastar la dinámica de ambos perfiles, la principal coincidencia radica en la dependencia crítica de la cadena de repuestos y suministros para la continuidad operativa del taller. Mientras que Pedro debe coordinar precios y compras para resguardar la rentabilidad del negocio, Andrés requiere que los insumos lleguen oportunamente al puesto de trabajo para no interrumpir el montaje de componentes. Asimismo, ambos coinciden en el uso intensivo de canales informales como llamadas telefónicas y mensajería instantánea para coordinar avances, asumiendo el riesgo latente de traspapelar especificaciones técnicas o acuerdos verbales.

**Diferencias Sustanciales entre Arquetipos**

La disparidad más notoria se manifiesta en la estricta división del trabajo entre la gestión administrativa y la ejecución mecánica. Pedro absorbe el trato comercial directo con los clientes, la negociación con distribuidores de autopartes, la facturación y la cobranza, tareas en las que Andrés no interviene. En contraposición, Andrés concentra sus esfuerzos en la manipulación de herramientas de diagnóstico, el desmontaje mecánico y el registro manual de horas en órdenes físicas en papel, debiendo recurrir a su teléfono móvil personal para registrar evidencias fotográficas preventivas ante posibles reclamos de piezas deterioradas.

### 2.3.3. *User Journey Mapping*

User Journey Mapping sintetiza el recorrido cronológico y emocional que experimentan los actores clave en el ejercicio diario de sus actividades dentro del taller automotriz independiente. Esta técnica gráfica descompone el ciclo completo de atención en etapas consecutivas para contrastar las metas del usuario, sus puntos de contacto, los canales de interacción y las fricciones que condicionan su estado de ánimo en la situación operativa actual previa a la incorporación de una solución tecnológica.

El recorrido integral estructurado en la plataforma colaborativa UXPressia abarca cinco fases canónicas del servicio automotriz: Aware para la recepción de solicitudes y coordinación de citas, Join para el arribo de la unidad e inspección diagnóstica, Use para la cotización de repuestos y aprobación comercial, Develop para la ejecución técnica en bahía con pruebas de ruta, y Leave para la liquidación administrativa, entrega del vehículo y cierre de orden. La modelación se efectuó de manera directa para cada arquetipo representativo desarrollado en la misma herramienta, vinculando a Pedro Suárez (@fig:user-persona-pedro-suarez) en la dimensión de gestión y a Andrés Vílchez (@fig:user-persona-andres-vilchez) en la dimensión operativa.

**Segmento 1: Personal de Gestión y Propietarios de Taller: Pedro Suárez**

El recorrido del administrador de taller (@fig:user-journey-mapping-pedro-suarez) refleja las vicisitudes del propietario que asume en simultáneo la dirección comercial, la coordinación logística y el control financiero del negocio sin respaldo de sistemas automatizados.

![Customer Journey Map del Administrador de Taller: Pedro Suárez](report/assets/NeedFinding/Journey-Mapping/user-journey-mapping-1.png){#fig:user-journey-mapping-pedro-suarez}

*Nota.* Mapeo de la experiencia del administrador de taller elaborado en UXPressia a través de las cinco etapas del servicio automotriz actual.

En la etapa inicial Aware, Pedro gestiona llamadas telefónicas y mensajes dispersos en su smartphone personal para coordinar citas. La falta de una agenda centralizada ocasiona cruces de horarios y descoordinación entre atenciones en taller y visitas de campo, manteniendo un estado anímico neutral. Al recibir e inspeccionar la unidad en Join, experimenta satisfacción profesional gracias a su vocación de servicio; no obstante, el registro manual de fallas en libretas o cuadernos físicos genera vacíos informativos sobre el historial de mantenimiento previo del vehículo.

El punto crítico de mayor fricción se desata en la fase de cotización Use, donde el ánimo del usuario decae en una marcada frustración. La carga administrativa al cotizar manualmente con múltiples proveedores de repuestos y calcular la mano de obra por WhatsApp demora la entrega de presupuestos, propiciando la pérdida de clientes impacientes. Durante la reparación en Develop, la necesidad de supervisar el trabajo técnico mientras atiende consultas comerciales simultáneas genera un desgaste solitario y un estado de alerta permanente. Finalmente, en Leave, Pedro recupera la tranquilidad y confianza al resolver la avería, aunque enfrenta dificultades para emitir comprobantes de pago inmediatos y cierta resistencia de los clientes a costear mantenimientos preventivos.

**Segmento 2: Personal Operativo del Taller: Andrés Vílchez**

El recorrido del técnico automotriz (@fig:user-journey-mapping-andres-vilchez) ilustra la rutina en la bahía de servicio y revela cómo las deficiencias logísticas del taller impactan negativamente en su productividad y bienestar laboral.

![Customer Journey Map del Técnico Mecánico Automotriz: Andrés Vílchez](report/assets/NeedFinding/Journey-Mapping/user-journey-mapping-2.png){#fig:user-journey-mapping-andres-vilchez}

*Nota.* Mapeo de la experiencia de diagnóstico y reparación técnica elaborado en UXPressia para el perfil operativo en bahía de servicio.

En el inicio de su jornada en Aware, Andrés recibe del jefe de taller una orden de trabajo en papel. La ilegibilidad de las anotaciones, las manchas de grasa y la omisión de detalles sobre los síntomas del vehículo generan incertidumbre operativa con un estado de ánimo neutral. En la inspección Join, conecta el escáner computarizado al puerto OBD-II del vehículo para leer códigos DTC, manifestando un interés técnico genuino; sin embargo, la falta de cobertura inalámbrica en zonas profundas del taller o fosas de servicio le impide consultar manuales y diagramas eléctricos en línea.

La fase más crítica para el mecánico acontece durante la gestión de suministros en Use. Tras solicitar repuestos mediante mensajes de WhatsApp, Andrés se ve forzado a esperar varias horas a que el cliente apruebe la compra y el proveedor despache la pieza. Estos tiempos muertos prolongados le provocan profunda molestia, pues bloquean inútilmente los elevadores hidráulicos y paralizan su ritmo productivo. En la ejecución mecánica en Develop, experimenta alta tensión y estrés operativo, ya que debe apresurar el desmontaje y montaje para recuperar el tiempo perdido sin cometer fallas mecánicas. En la culminación del servicio en Leave, experimenta serenidad al concluir las tareas, a pesar de la incomodidad que supone saturar su teléfono personal con fotografías probatorias y registrar horas laboradas en cuadernos físicos.

### 2.3.4. *Empathy Mapping*

Empathy Mapping complementa la comprensión fenomenológica de los usuarios clave al situar en el centro de la reflexión a los arquetipos formulados. Para su construcción en la plataforma colaborativa UXPressia, el equipo consolidó los testimonios recogidos durante las entrevistas de campo y formuló observaciones guiadas por interrogantes clave: con quién se empatiza, qué metas necesita cumplir, qué aspectos observa en su entorno, qué comentarios escucha de clientes o colegas, qué actitudes manifiesta públicamente, y cuáles son sus preocupaciones y aspiraciones más profundas. A partir de esta exploración, se identificaron los dolores y ganancias esperadas de cada perfil.

**Segmento 1: Personal de Gestión y Propietarios del Taller: Pedro Suárez**

El mapa de empatía de Pedro Suárez (@fig:empathy-mapping-pedro-suarez) profundiza en la perspectiva del administrador que atiende servicios de forma itinerante y gestiona la rentabilidad global de su taller.

![Empathy Mapping del Administrador de Taller: Pedro Suárez](report/assets/NeedFinding/Empathy-Mapping/Empathy%20Mapping-Pedro-Suarez.png){#fig:empathy-mapping-pedro-suarez}

*Nota.* Mapa de empatía elaborado en UXPressia para caracterizar las motivaciones y fricciones del administrador de taller automotriz.

El análisis revela que Pedro percibe la frustración de clientes que acuden únicamente ante fallas mecánicas graves por haber postergado mantenimientos preventivos. Mientras escucha quejas por costos imprevistos de reparación, experimenta en solitario el desgaste de calcular presupuestos en notas manuales y la incertidumbre de perder oportunidades comerciales por no contar con una plataforma que centralice el historial de fallas y agilice cotizaciones transparentes.

**Segmento 2: Personal Operativo del Taller: Andrés Vílchez**

El mapa de empatía de Andrés Vílchez (@fig:empathy-mapping-andres-vilchez) captura las vivencias del técnico especializado que labora directamente en las bahías y fosas de servicio.

![Empathy Mapping del Técnico Mecánico Automotriz: Andrés Vílchez](report/assets/NeedFinding/Empathy-Mapping/Empathy%20Mapping-Andres-Vilchez.png){#fig:empathy-mapping-andres-vilchez}

*Nota.* Mapa de empatía elaborado en UXPressia para sintetizar las percepciones y demandas operativas del técnico mecánico automotriz.

Andrés manifiesta incomodidad ante la desorganización de los canales informales de mensajería y la inactividad involuntaria cuando los vehículos ocupan elevadores esperando repuestos. En su día a día, valora resolver averías complejas mediante escáneres multimarca y busca una herramienta digital que funcione sin conexión en fosas de servicio, valide con objetividad sus horas de trabajo técnico y sustituya el registro manual de evidencias fotográficas en su dispositivo personal.


### 2.3.5. *Big Picture EventStorming*

Como cierre analítico de la fase de Needfinding, el equipo desarrolló un taller colaborativo de Big Picture EventStorming utilizando la plataforma virtual Miro. Esta dinámica metodológica, concebida por Alberto Brandolini, permite explorar visualmente el dominio integral del servicio automotriz independiente, reuniendo en una misma conversación a expertos del negocio, analistas e ingenieros de software para alinear el entendimiento del flujo operativo, identificar eventos de relevancia y detectar puntos críticos de fricción antes de abordar especificaciones técnicas formales.

El desarrollo del taller siguió un proceso estructurado en etapas secuenciales:

- **Generación masiva de eventos de dominio:** El equipo identificó los hechos significativos que ocurren en la vida real del taller y del conductor, redactándolos en participio pasado sobre tarjetas adhesivas naranjas, desde la omisión de mantenimientos preventivos hasta la liquidación final del servicio.
- **Ordenamiento cronológico y narrativa inversa:** Los eventos se secuenciaron sobre una línea de tiempo horizontal de izquierda a derecha, aplicando una revisión en sentido inverso para detectar hechos omitidos, dependencias operativas y consecuencias no deseadas.
- **Asignación de actores y carriles de responsabilidad:** Se incorporaron tarjetas amarillas para representar a los actores participantes y segmentar el recorrido en carriles funcionales: Conductor, Asesor de Servicio y Mecánico / Jefe de Taller.
- **Identificación de etapas y puntos críticos:** El flujo completo se organizó en tres macro-etapas del negocio, señalando mediante rombos morados de interrogación las zonas de incertidumbre, cuellos de botella e ineficiencias operativas conocidas como hotspots.

La @fig:big-picture-flujo-eventos expone la recolección exhaustiva de los treinta y dos eventos de dominio estructurados a lo largo de la línea temporal de exploración en Miro.

![Recolección y Flujo Cronológico de Eventos de Dominio en Miro](report/assets/strategic-ddd/big-picture-01-flujo-eventos.png){#fig:big-picture-flujo-eventos}

*Nota.* Vista de la recolección y secuencia de eventos de dominio en participio pasado formulados durante el taller en Miro.

Posteriormente, la @fig:big-picture-actores-puntos-criticos ilustra la estructuración del dominio en carriles de actores, delimitando las tres macro-etapas operativas y los tres puntos críticos descubiertos.

![Estructuración por Carriles de Actores, Etapas del Proceso y Puntos Críticos](report/assets/strategic-ddd/big-picture-02-actores-puntos-criticos.png){#fig:big-picture-actores-puntos-criticos}

*Nota.* Estructura por carriles de actores, etapas operativas y puntos críticos en el [Tablero de Miro: Big Picture EventStorming](https://miro.com/app/board/uXjVHq7YYWw=/?share_link_id=20364641152).

A partir de esta estructuración, el análisis del negocio identificó tres etapas clave y sus correspondientes focos de fricción operativa:

**Prevención, Detección y Decisión de Actuar: Conductor**

El carril del conductor evidencia dos dinámicas paralelas en la operativa actual. En el nivel pasivo superior, se manifiesta el deterioro gradual del vehículo ocasionado por la omisión de revisiones periódicas, la falta de historiales actualizados y el desinterés ante desgastes iniciales, lo cual agrava la avería. En el carril de acción, el conductor percibe los síntomas pero posterga la atención hasta que la falla inmoviliza la unidad, viéndose forzado a buscar un taller y solicitar una cita de urgencia.

El primer punto crítico emerge en la entrega del vehículo al taller. En este hito convergen la desconfianza del usuario sobre el diagnóstico real, la falta de información verificable del estado del motor y la incertidumbre respecto al costo final de la reparación, lo que condiciona negativamente el inicio de la relación de servicio.

**Recepción, Diagnóstico y Autorización: Asesor de Servicio**

Esta etapa abarca la apertura formal de la orden de trabajo, la inspección técnica física, el registro computarizado de fallas y la formulación del presupuesto de mantenimiento MRO. Tras el envío de la propuesta económica y su autorización por parte del cliente, el personal verifica la disponibilidad de insumos en el almacén del taller.

El segundo punto crítico, identificado como el principal cuello de botella logístico, ocurre entre la solicitud y recepción de repuestos. La dependencia de cotizaciones telefónicas manuales con distribuidores externos y las demoras en la aprobación de costos por parte del cliente generan tiempos muertos prolongados que paralizan los puestos de trabajo y retienen vehículos desarmados en las bahías.

**Reparación, Control de Calidad y Cierre: Mecánico / Jefe de Taller**

La fase técnica final comprende la asignación de tareas al puesto mecánico, la ejecución de labores de desmontaje y sustitución de piezas averiadas, y la aprobación de pruebas de ruta y calidad. Una vez superadas las pruebas, se notifica la culminación del trabajo al cliente, se efectúa el cobro, se entrega el vehículo y se procede al cierre administrativo del servicio.

El tercer punto crítico se ubica en el cierre formal de la atención. La liquidación manual de pagos y la emisión desarticulada de comprobantes tributarios dificultan el control de caja del taller, mientras que la falta de un canal automatizado de seguimiento posventa rompe el vínculo preventivo con el conductor, reiniciando el ciclo reactivo de averías mecánicas.

**Articulación con los Contextos Delimitados de Atelier**

El entendimiento visual alcanzado en el Big Picture EventStorming sienta las bases funcionales para modular la arquitectura del backend de Atelier en contextos delimitados altamente cohesivos:

- La captación de síntomas y prevención telemática orienta el alcance de IoT Telemetry & Predictive Maintenance y Customer & Fleet Management.
- La apertura de órdenes de trabajo, peritaje fotográfico y distribución de tareas mecánicas fundamenta el contexto Workshop Operations.
- La adquisición, costeo por lote FIFO y recepción de repuestos articula el contexto Inventory & Supply Chain.
- El control de jornada laboral y asignación de técnicos en bahías guía el contexto Human Resources Management.
- La liquidación de costos, registro de cobros y emisión de comprobantes electrónicos UBL 2.1 ante SUNAT estructura el contexto Invoicing & Compliance.

### 2.3.6. *Ubiquitous Language*

La consolidación de un Lenguaje Ubicuo (*Ubiquitous Language*) constituye uno de los pilares esenciales de *Domain-Driven Design* propuestos por @evans2003ddd. Este artefacto establece un vocabulario formal, compartido y riguroso entre los especialistas del negocio automotriz y el equipo de ingeniería de software, erradicando ambigüedades interpretativas y sobrecostos de traducción en el desarrollo del sistema.

Conforme a las directrices de modelado estratégico, el glosario incorpora exclusivamente términos propios del dominio del negocio automotriz, la gestión operativa de talleres mecánicos y la telemetría vehicular, prescindiendo deliberadamente de tecnicismos propios de la infraestructura de software. La @tbl:ubiquitous-language consolida los términos fundamentales en inglés con sus correspondientes definiciones formales en español y su contexto delimitado de aplicación:

| Término en el Dominio | Definición Formal y Regla de Negocio Asociada | Contexto Delimitado / Ámbito |
| :---: | :--- | :---: |
| Work Order | Documento maestro que registra el ingreso de una unidad al taller, centralizando los síntomas reportados, el peritaje inicial de recepción, las tareas mecánicas asignadas, los repuestos requeridos y el estado general del servicio. | Workshop Operations |
| Work Order Task | Unidad atómica de labor mecánica o eléctrica asignada a un técnico específico dentro de una orden de trabajo, vinculada a una tasa de mano de obra y sujeta a verificación de calidad. | Workshop Operations |
| MRO Estimate | Propuesta económica formal elaborada tras el diagnóstico que desglosa los costos estimados de mano de obra e insumos requeridos, cuya ejecución exige la autorización expresa del cliente. | Workshop Operations |
| Service Bay | Espacio físico delimitado dentro del taller automotriz equipado con elevador hidráulico o fosa de inspección para la intervención técnica simultánea de un vehículo. | Workshop Operations |
| Inspection Checklist | Protocolo sistemático de peritaje visual y funcional ejecutado al ingresar un vehículo para registrar daños preexistentes en carrocería, desgaste de neumáticos, niveles de fluidos y pertenencias a bordo. | Workshop Operations |
| OBD-II Telemetry | Flujo continuo de parámetros operativos estandarizados del motor capturados en tiempo real desde el puerto de diagnóstico a bordo del vehículo, tales como temperatura del refrigerante, revoluciones por minuto y velocidad. | IoT Telemetry |
| Diagnostic Trouble Code | Código alfanumérico estandarizado generado por la computadora del vehículo para identificar una anomalía o falla puntual en subsistemas mecánicos, eléctricos o de control de emisiones. | IoT Telemetry |
| Predictive Fault Alert | Notificación temprana emitida cuando el análisis de series temporales de telemetría detecta desviaciones críticas en los parámetros del motor, advirtiendo una falla potencial antes de que ocurra una avería inmovilizante. | IoT Telemetry |
| Freeze Frame Data | Registro instantáneo de parámetros operativos del motor almacenados automáticamente por la computadora del vehículo en el milisegundo exacto en que se registró un código de falla. | IoT Telemetry |
| Inventory Item | Componente mecánico, autoparte de recambio o insumo consumible catalogado en el almacén del taller para su utilización en órdenes de trabajo o comercialización directa. | Inventory & Supply Chain |
| Inventory Batch | Lote homogéneo de repuestos o insumos ingresado al almacén en una misma fecha, bajo un costo de adquisición unitario específico y respaldado por una factura de compra del distribuidor. | Inventory & Supply Chain |
| FIFO Inventory Valuation | Regla contable de valuación en la que los repuestos e insumos se descargan física y económicamente según el orden cronológico de su ingreso, consumiendo siempre el lote más antiguo disponible. | Inventory & Supply Chain |
| Safety Stock Threshold | Nivel mínimo de existencia predeterminado para un repuesto o insumo en el almacén, por debajo del cual se emite una orden de reabastecimiento para prevenir interrupciones en los puestos de trabajo. | Inventory & Supply Chain |
| Vehicle Fleet | Conjunto organizado de unidades vehiculares pertenecientes a una misma empresa o cliente corporativo, sujetas a calendarios de mantenimiento preventivo y monitoreo telemático unificado. | Customer & Fleet Management |
| Service Appointment | Reserva programada de fecha, horario y puesto de trabajo para el ingreso de un vehículo al taller con fines de mantenimiento preventivo o revisión correctiva. | Customer & Fleet Management |
| Vehicle Identification Number | Código alfanumérico único de diecisiete caracteres grabado en el chasis del vehículo que identifica de manera universal su fabricante, país de origen, modelo, motorización y año de fabricación. | Customer & Fleet Management |
| Geofenced Clock-in | Marcación de jornada laboral validada mediante coordenadas satelitales que certifica la presencia física del técnico dentro de las instalaciones del taller automotriz al momento de registrar su asistencia. | Human Resources |
| Work Shift | Jornada programada que establece los turnos de atención, horarios de refrigerio y disponibilidad de los técnicos en cada sucursal del taller mecánico. | Human Resources |
| Electronic Tax Receipt | Comprobante de pago con validez fiscal emitido ante la administración tributaria bajo el estándar UBL 2.1 para respaldar los servicios mecánicos prestados y repuestos consumidos en una orden de trabajo. | Invoicing & Compliance |
: Glosario de Lenguaje Ubicuo del Dominio Automotriz {#tbl:ubiquitous-language}

*Nota.* Glosario de términos del negocio automotriz y telemetría clasificados por contexto delimitado según las directrices de Domain-Driven Design.

\newpage