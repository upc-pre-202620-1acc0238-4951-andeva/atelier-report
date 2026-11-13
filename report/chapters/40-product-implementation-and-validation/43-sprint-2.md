### 4.2.2. _Sprint 2_

El segundo ciclo constructivo del proyecto Atelier se orienta estratégicamente a la materialización de la experiencia operativa en campo mediante la aplicación móvil nativa Android denominada Atelier Workshop Mobile. Tras culminar exitosamente la totalidad de los servicios web del backend y el portal comercial de captación durante la iteración previa, el esfuerzo de ingeniería se concentra en proveer a los mecánicos de bahía, recepcionistas de patio y encargados de almacén una herramienta ágil, confiable y con capacidad de persistencia local sin conexión obligatoria a internet.

El alcance acordado para este ciclo abarca veintidós historias de usuario que consolidan cincuenta y cinco puntos de historia distribuidos en seis épicas fundamentales del negocio: autenticación institucional, control de asistencia satelital con validación geodésica, recepción pericial vehicular en patio, liquidación y resolución de presupuestos de mantenimiento, ejecución cronometrada de tareas técnicas y abastecimiento de repuestos bajo el método estricto de valoración FIFO por lote. Con el fin de maximizar la efectividad en la captura de asistencias y evitar redundancias operativas, el equipo determinó en la etapa de refinamiento prescindir de la historia US07, concentrando las validaciones de presencia física en los registros biométricos y satelitales de ingreso y salida.

#### 4.2.2.1. Sprint Planning 2

La sesión formal de planificación del Sprint 2 se llevó a cabo el 19 de octubre de 2026 a las 02:00 PM mediante una reunión síncrona virtual en Discord, contando con la participación activa de los cinco integrantes del equipo de ingeniería. La sesión inició con la revisión del balance operativo del ciclo anterior, evaluando la robustez de los contratos RESTful expuestos por el backend y confirmando la viabilidad de la integración móvil con los servicios en producción. Seguidamente, se formuló la meta del sprint bajo criterios SMART y se descompusieron las veintidós historias de usuario en tareas técnicas estimadas en horas de trabajo.

La @tbl:sprint-planning-2 resume las características clave de la sesión de planificación, detallando los antecedentes operativos, los acuerdos retrospectivos, el objetivo de la iteración y los indicadores de esfuerzo comprometidos.

\renewcommand{\arraystretch}{1.2}
\begin{longtable}{| >{\raggedright\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{\dimexpr\textwidth-4.8cm-4\tabcolsep-3\arrayrulewidth\relax} |}
\caption{Sprint Planning 2 - Resumen de la sesión de planificación del Sprint 2} \label{tbl:sprint-planning-2} \\
\hline
\thfirst{Sprint \#} & \thcell{Sprint 2} \\
\hline
\endfirsthead
\hline
\thfirst{Sprint \#} & \thcell{Sprint 2} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
\thspanfirst{2}{Sprint Planning Background} \\
\hline
\textbf{Date} & 2026-10-19 \\
\hline
\textbf{Time} & 02:00 PM - 04:30 PM \\
\hline
\textbf{Location} & Sesión síncrona virtual mediante Discord \\
\hline
\textbf{Prepared By} & Huamani Estefanero, Joel \\
\hline
\textbf{Attendees to planning meeting} & Granda Ibarra, Luis Daniel / Huamani Estefanero, Joel / Rocha Cotrina, Alvaro / Sanchez Santin, Adiel Abdiaz / Teran Zavala, Mauricio Alejandro \\
\hline
\textbf{Sprint 1 Review Summary} & Conclusión y aprobación exitosa del Sprint 1 con el 100\% de cumplimiento en los entregables comprometidos. Se desplegó públicamente el portal comercial Atelier Website en Vercel con dominio activo y optimización SEO, y se completaron, verificaron y documentaron bajo OpenAPI la totalidad de los servicios RESTful del backend distribuidos en los ocho Bounded Contexts y el Shared Kernel en Render mediante contenedores Docker, alcanzando una velocidad de noventa Story Points. \\
\hline
\textbf{Sprint 1 Retrospective Summary} & Balance positivo en la modularización de arquitectura limpia, integración continua y disciplina de diseño guiado por el dominio. Para el segundo ciclo de desarrollo, el equipo acordó concentrar el esfuerzo técnico en la aplicación móvil nativa Android con Jetpack Compose y Kotlin 2.0, robustecer la persistencia local con Room y SQLite para garantizar la operatividad sin conexión en fosa y patio, y aplicar una verificación estricta de criterios BDD Gherkin en cada flujo de usuario. Asimismo, tras revaluar la complejidad técnica del módulo de geocercas satelitales, se acordó consolidar la marcación GPS en las historias US06 y US08, suprimiendo la historia US07 para optimizar el alcance del sprint en cincuenta y cinco Story Points. \\
\hline
\thspanfirst{2}{Sprint Goal \& User Stories} \\
\hline
\textbf{Sprint 2 Goal} & \textbf{Our focus is on} construir y verificar la aplicación móvil nativa Android Atelier Workshop Mobile, implementando los flujos de autenticación e invitación de colaboradores, marcación de asistencia satelital con geocerca geodésica, recepción e inspección pericial vehicular en patio, liquidación automatizada de presupuestos, ejecución cronometrada de tareas en bahía y abastecimiento de repuestos bajo el método FIFO.\newline
\textbf{We believe it delivers} una herramienta de trabajo ágil, robusta y operativa en fosa y patio para mecánicos, recepcionistas y jefes de taller, permitiendo registrar la trazabilidad completa del servicio vehicular desde su arribo hasta la finalización mecánica con soporte de persistencia local sin conexión obligatoria a internet.\newline
\textbf{This will be confirmed when} los usuarios interactúan de forma fluida con las interfaces de usuario en el dispositivo móvil Android, registran asistencias verificadas por GPS, abren órdenes de trabajo con inspección fotográfica 360°, gestionan tareas y rebajan existencias por lotes cronológicos de adquisición, superando las suites de pruebas automatizadas y verificando la sincronización bidireccional con el backend en producción. \\
\hline
\textbf{Sprint 2 Velocity} & 55 \\
\hline
\textbf{Sum of Story Points} & 55 \\
\hline
\end{longtable}

_Nota._ Cuadro de planificación del Sprint 2 adaptado de la guía de Scrum para el proyecto Atelier.

#### 4.2.2.2. Aspect Leaders and Collaborators

Con el propósito de asegurar una clara trazabilidad de responsabilidades, mitigar riesgos de integración en la arquitectura móvil y mantener una comunicación fluida entre los desarrolladores, el equipo estructuró la matriz de liderazgo y colaboración Leadership-and-Collaboration Matrix, denominada LACX. Mediante este instrumento, cada componente funcional del sprint cuenta con un integrante asignado como líder técnico responsable directo de la calidad, pruebas y entrega a tiempo, respaldado por colaboradores que aportan en tareas de soporte, integración de interfaces y aseguramiento de la calidad.

El alcance del Sprint 2 se distribuye en cinco aspectos funcionales y arquitectónicos que abarcan la totalidad de los módulos de la aplicación móvil:

- **Mobile: Autenticación, Acceso Institucional y Gestión de Personal:** Abarca el flujo móvil de registro por invitación de taller, validación de identidad con código OTP de seis dígitos, autenticación con credenciales institucionales y contextualización de la sede operativa del colaborador en la aplicación móvil (historias US01, US02 y US03).
- **Mobile: Control de Asistencia Satelital y Programación de Turnos:** Comprende la marcación móvil de ingreso laboral con validación de geocerca geodésica mediante algoritmo Haversine, registro de salida con liquidación horaria, consulta semanal de turnos laborales asignados y gestión de descargos por tardanza involuntaria (historias US06, US08, US09 y US10).
- **Mobile: Recepción Pericial e Inspección Vehicular en Patio:** Involucra la búsqueda y vinculación rápida de clientes y vehículos por placa o documento fiscal, alta de clientes presenciales, apertura formal de órdenes de trabajo, registro fotográfico 360° del estado de carrocería y gestión de propuestas técnicas adicionales originadas por hallazgos en foso (historias US11, US12, US13, US14, US15 y US44).
- **Mobile: Presupuestos Comerciales y Liquidación de Órdenes:** Contempla el cálculo automatizado en cascada de mano de obra, materiales e impuestos de ley, la imputación supervisada de insumos, la generación y remisión de proformas comerciales en formato digital y el registro formal de la decisión del cliente tras consulta externa (historias US22, US23, US24 y US25).
- **Mobile: Ejecución en Bahía, Cronometraje y Abastecimiento FIFO:** Abarca el panel móvil del mecánico para consulta y priorización de faenas, control cronometrado de labor efectiva con pausas operativas sincronizadas con turnos, catálogo interactivo de repuestos, descargo físico y contable bajo la regla estricta FIFO por lote y reincorporación de materiales al inventario (historias US26, US27, US31, US32 y US33).

La @tbl:aspect-leaders-2 detalla la asignación de roles de liderazgo identificados con la letra L y de colaboración representados por la letra C para cada integrante del equipo en los cinco aspectos del Sprint 2.

\begingroup
\footnotesize
\setlength{\tabcolsep}{2.5pt}
\renewcommand{\arraystretch}{1.2}
\begin{longtable}{| >{\raggedright\arraybackslash}p{2.65cm} | >{\centering\arraybackslash}p{1.75cm} | >{\centering\arraybackslash}p{2.14cm} | >{\centering\arraybackslash}p{2.14cm} | >{\centering\arraybackslash}p{2.14cm} | >{\centering\arraybackslash}p{2.14cm} | >{\centering\arraybackslash}p{2.14cm} |}
\caption{Matriz de Líderes y Colaboradores por Aspecto del Sprint 2 (LACX)} \label{tbl:aspect-leaders-2} \\
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{2.65cm}|}{\textbf{Team Member}\newline\textbf{(Last Name,}\newline\textbf{First Name)}} & \textbf{GitHub}\newline\textbf{Username} & \textbf{Mobile:}\newline\textbf{Autenticación}\newline\textbf{\& Personal}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} & \textbf{Mobile:}\newline\textbf{Asistencia GPS}\newline\textbf{\& Turnos}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} & \textbf{Mobile:}\newline\textbf{Recepción en}\newline\textbf{Patio 360°}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} & \textbf{Mobile:}\newline\textbf{Presupuestos}\newline\textbf{\& Liquidación}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} & \textbf{Mobile:}\newline\textbf{Bahía, Faenas}\newline\textbf{\& Stock FIFO}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} \\
\hline
\endfirsthead
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{2.65cm}|}{\textbf{Team Member}\newline\textbf{(Last Name,}\newline\textbf{First Name)}} & \textbf{GitHub}\newline\textbf{Username} & \textbf{Mobile:}\newline\textbf{Autenticación}\newline\textbf{\& Personal}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} & \textbf{Mobile:}\newline\textbf{Asistencia GPS}\newline\textbf{\& Turnos}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} & \textbf{Mobile:}\newline\textbf{Recepción en}\newline\textbf{Patio 360°}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} & \textbf{Mobile:}\newline\textbf{Presupuestos}\newline\textbf{\& Liquidación}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} & \textbf{Mobile:}\newline\textbf{Bahía, Faenas}\newline\textbf{\& Stock FIFO}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
Granda Ibarra, Luis Daniel & danieltyuyu & C & C & L & C & C \\
\hline
Huamani Estefanero, Joel & shouydev & C & C & C & C & L \\
\hline
Rocha Cotrina, Alvaro & alvarorc24 & C & L & C & C & C \\
\hline
Sanchez Santin, Adiel Abdiaz & xs4el & C & C & C & L & C \\
\hline
Teran Zavala, Mauricio Alejandro & mau-tz & L & C & C & C & C \\
\hline
\end{longtable}
\endgroup

_Nota._ Matriz de liderazgo y colaboración del Sprint 2 adaptada de la guía del proyecto Atelier.

#### 4.2.2.3. Sprint Backlog 2

El Sprint Backlog del segundo ciclo de desarrollo reúne el catálogo integral de las veintidós historias de usuario seleccionadas para implementar las capacidades operativas de la aplicación móvil nativa Atelier Workshop Mobile, con una asignación total de cincuenta y cinco puntos de historia equivalentes a ciento sesenta y cinco horas de trabajo estimadas a razón de tres horas por Story Point. En el estado actual del tablero en Jira Software, se encuentran registradas y culminadas quince tareas técnicas correspondientes a las historias US26, US27, US31, US32 y US33 por un total de cuarenta y cinco horas, mientras que las diecisiete historias restantes mantienen únicamente su asignación de responsable a la espera del registro de sus subtareas.

Cada historia de usuario se articula en tareas complementarias de diseño de interfaz reactiva con Jetpack Compose, desarrollo de ViewModels y casos de uso bajo Arquitectura Limpia, persistencia local con entidades y DAOs en Room SQLite para soporte sin conexión, e integración de contratos con la API RESTful del backend.

El control del avance operativo y el seguimiento de las historias del sprint se gestionaron de manera interactiva mediante el tablero ágil en Jira Software, el cual se encuentra disponible para auditoría y consulta a través del enlace público oficial: [Tablero del Sprint 2 en Jira Software](https://andeva.atlassian.net/?continue=https%3A%2F%2Fandeva.atlassian.net%2Fwelcome%2Fsoftware%3FprojectId%3D10001&atlOrigin=eyJpIjoiZTAzNjYwMTQwNjVmNDVjY2ExOGUxZDkyMTBlMTUzNGIiLCJwIjoiamlyYS1zb2Z0d2FyZSJ9).

![Tablero del Sprint 2 en Jira Software](report/assets/sprint-2/table-jira-sprint-2.png){#fig:table-jira-sprint-2 width=90%}

_Nota._ Captura de pantalla del tablero ágil del Sprint 2 en Jira Software evidenciando las veintidós historias de usuario culminadas en la columna de finalizadas.

La @tbl:sprint-backlog-2 consolida la distribución detallada de tareas, sus estimaciones en horas, los integrantes asignados y su estado final de culminación.

\begingroup
\scriptsize
\setlength{\tabcolsep}{2pt}
\renewcommand{\arraystretch}{1.2}
\begin{longtable}{| >{\centering\arraybackslash}p{0.9cm} | >{\raggedright\arraybackslash}p{2.8cm} | >{\centering\arraybackslash}p{1.0cm} | >{\centering\arraybackslash}p{1.6cm} | >{\raggedright\arraybackslash}p{4.4cm} | >{\centering\arraybackslash}p{1.0cm} | >{\raggedright\arraybackslash}p{2.1cm} | >{\centering\arraybackslash}p{1.1cm} |}
\caption{Sprint Backlog del Sprint 2 y Estado de Ejecución de Ítems} \label{tbl:sprint-backlog-2} \\
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{0.9cm}|}{\textbf{Sprint \#}} & \multicolumn{7}{c|}{\textbf{Sprint 2}} \\
\hline
\multicolumn{2}{|c|}{\textbf{User Story}} & \multicolumn{6}{c|}{\textbf{Work-Item / Task}} \\
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{0.9cm}|}{\textbf{Id}} & \multicolumn{1}{>{\centering\arraybackslash}p{2.8cm}|}{\textbf{Title}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.0cm}|}{\textbf{Id}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.6cm}|}{\textbf{Title}} & \multicolumn{1}{>{\centering\arraybackslash}p{4.4cm}|}{\textbf{Description}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.0cm}|}{\textbf{Estimation}\newline\textbf{(Hours)}} & \multicolumn{1}{>{\centering\arraybackslash}p{2.1cm}|}{\textbf{Assigned}\newline\textbf{To}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.1cm}|}{\textbf{Status}} \\
\hline
\endfirsthead
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{0.9cm}|}{\textbf{Sprint \#}} & \multicolumn{7}{c|}{\textbf{Sprint 2}} \\
\hline
\multicolumn{2}{|c|}{\textbf{User Story}} & \multicolumn{6}{c|}{\textbf{Work-Item / Task}} \\
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{0.9cm}|}{\textbf{Id}} & \multicolumn{1}{>{\centering\arraybackslash}p{2.8cm}|}{\textbf{Title}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.0cm}|}{\textbf{Id}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.6cm}|}{\textbf{Title}} & \multicolumn{1}{>{\centering\arraybackslash}p{4.4cm}|}{\textbf{Description}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.0cm}|}{\textbf{Estimation}\newline\textbf{(Hours)}} & \multicolumn{1}{>{\centering\arraybackslash}p{2.1cm}|}{\textbf{Assigned}\newline\textbf{To}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.1cm}|}{\textbf{Status}} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US01 & Registro y vinculación de colaborador mediante invitación corporativa &  &  &  &  & Teran Zavala, Mauricio Alejandro &  \\
\hline
US02 & Verificación de identidad y correo electrónico mediante código OTP &  &  &  &  & Teran Zavala, Mauricio Alejandro &  \\
\hline
US03 & Inicio de sesión corporativo y contextualización de sede de trabajo &  &  &  &  & Teran Zavala, Mauricio Alejandro &  \\
\hline
US06 & Marcación de ingreso laboral con validación de geocerca GPS satelital &  &  &  &  & Rocha Cotrina, Alvaro &  \\
\hline
US08 & Marcación de salida y liquidación de jornada laboral efectiva &  &  &  &  & Rocha Cotrina, Alvaro &  \\
\hline
US09 & Consulta de programación semanal de turnos y márgenes de tolerancia &  &  &  &  & Rocha Cotrina, Alvaro &  \\
\hline
US10 & Emisión y seguimiento de descargos justificatorios de tardanza &  &  &  &  & Rocha Cotrina, Alvaro &  \\
\hline
US11 & Búsqueda y vinculación de cliente y vehículo por placa o documento &  &  &  &  & Granda Ibarra, Luis Daniel &  \\
\hline
US12 & Apertura de orden de trabajo y parametrización de tareas iniciales &  &  &  &  & Granda Ibarra, Luis Daniel &  \\
\hline
US13 & Registro pericial de evidencias fotográficas de recepción vehicular &  &  &  &  & Granda Ibarra, Luis Daniel &  \\
\hline
US14 & Generación de propuesta de tarea adicional por hallazgo en foso &  &  &  &  & Granda Ibarra, Luis Daniel &  \\
\hline
US15 & Notificación y aprobación de propuesta técnica con el cliente &  &  &  &  & Granda Ibarra, Luis Daniel &  \\
\hline
US44 & Alta y afiliación de clientes en taller según tenencia previa de cuenta en la plataforma &  &  &  &  & Granda Ibarra, Luis Daniel &  \\
\hline
US22 & Cómputo automático en cascada de costos de tareas e impuestos &  &  &  &  & Sanchez Santin, Adiel Abdiaz &  \\
\hline
US23 & Imputación de repuestos a tareas y supervisión administrativa &  &  &  &  & Sanchez Santin, Adiel Abdiaz &  \\
\hline
US24 & Generación y remisión digital de proforma comercial en PDF &  &  &  &  & Sanchez Santin, Adiel Abdiaz &  \\
\hline
US25 & Formalización de resolución de presupuesto tras comunicación externa &  &  &  &  & Sanchez Santin, Adiel Abdiaz &  \\
\hline
US26 & Consulta y priorización de tareas mecánicas asignadas en bahía & AT-280 & UI Compose & Maquetar la interfaz de la bandeja de faenas mecánicas en bahía con indicadores de prioridad y estado & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
& & AT-281 & Room Local & Implementar la persistencia local en Room SQLite y repositorio offline-first para faenas en bahía & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
& & AT-282 & ViewModel & Integrar el consumo reactivo y ordenamiento de faenas mecánicas asignadas con soporte sin conexión & 2 & Huamani Estefanero, Joel & Done \\
\hline
US27 & Cronometraje de labor efectiva, pausas operativas y sincronización con turnos laborales & AT-283 & UI Compose & Maquetar el cronómetro de labor en foso con controles interactivos de inicio, pausa y culminación & 3 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
& & AT-284 & Dominio & Implementar el cómputo de horas hombre efectivas y suspensión automática al cumplirse el fin de turno & 3 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
& & AT-285 & Persistencia & Integrar la persistencia de intervalos de tiempo y sincronización con turnos laborales & 3 & Huamani Estefanero, Joel & Done \\
\hline
US31 & Búsqueda y consulta de disponibilidad de repuestos en catálogo & AT-286 & UI Compose & Maquetar el catálogo móvil de repuestos con navegación por categorías y buscador reactivo & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
& & AT-287 & ViewModel & Implementar filtros por SKU, categoría y marca con consulta de existencias y precios en Android & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
& & AT-288 & Navegación & Integrar la navegación fluida y manejo de back handler en la consulta de inventario móvil & 2 & Huamani Estefanero, Joel & Done \\
\hline
US32 & Descargo contable y físico automatizado mediante regla estricta FIFO por lote & AT-289 & UI Compose & Maquetar el diálogo modal de imputación y descargo de repuestos con control de cantidad y validación de stock & 5 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
& & AT-290 & Algoritmo & Implementar la lógica de consumo estricto de lotes FIFO con validación de saldo no negativo & 5 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
& & AT-291 & Persistencia & Integrar la valorización del costo real de salida y persistencia del descargo en la orden de trabajo & 5 & Huamani Estefanero, Joel & Done \\
\hline
US33 & Reincorporación lógica de materiales a inventario por remoción en tarea técnica & AT-292 & UI Compose & Maquetar la acción y confirmación de remoción de repuestos en el detalle de la tarea mecánica & 3 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
& & AT-293 & Algoritmo & Implementar la restitución lógica de existencias al lote cronológico original del almacén & 3 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
& & AT-294 & Dominio & Integrar el recálculo automático y rebaja del costo imputado en la orden de trabajo móvil & 3 & Huamani Estefanero, Joel & Done \\
\hline
\end{longtable}
\endgroup

_Nota._ Matriz consolidada del Sprint Backlog del Sprint 2 adaptada de Jira Software para el proyecto Atelier.

#### 4.2.2.4. Development Evidence for Sprint Review

Durante el segundo ciclo constructivo, el equipo completó la implementación integral de la aplicación móvil nativa Android denominada Atelier Workshop Mobile. Este desarrollo concentra el soporte operacional del ecosistema en el entorno físico del taller automotriz, dotando a los mecánicos de bahía, recepcionistas de patio y encargados de inventario de una herramienta interactiva, robusta y con capacidad de persistencia local para asegurar la continuidad de las operaciones en áreas con pérdida de conectividad a internet.

El repositorio oficial que alberga la totalidad del código fuente de la aplicación móvil se encuentra disponible en GitHub mediante el siguiente enlace:

- **Repositorio de la Aplicación Móvil Android (Atelier Workshop Mobile):** [https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier-mobile-android](https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier-mobile-android)

La aplicación fue desarrollada sobre la plataforma Kotlin 2.0 y el marco declarativo Jetpack Compose con directivas de diseño Material 3. La arquitectura adopta los principios de Arquitectura Limpia organizada bajo el enfoque Feature-First, delimitando responsabilidades entre las capas de presentación, aplicación, dominio e infraestructura mediante inyección de dependencias con Dagger Hilt y el procesador KSP. La persistencia local y el soporte fuera de línea se fundamentan en bases de datos relacionales SQLite administradas a través de Room, combinadas con colas de mutaciones diferidas en segundo plano gestionadas por WorkManager.

El alcance construido abarca los módulos operativos centrales de la plataforma:

- **Autenticación, Acceso Institucional y Contexto de Sede:** Flujo de registro mediante invitación, verificación de identidad con código numérico OTP de seis dígitos, autenticación con credenciales institucionales, almacenamiento cifrado de tokens JWT de acceso y refresco en DataStore Preferences, y contextualización dinámica de la sede operativa activa del colaborador.
- **Control de Asistencia Satelital y Turnos:** Captura de coordenadas geodésicas en tiempo real mediante Play Services Location, validación perimétrica de presencia física empleando el algoritmo matemático de distancia Haversine frente a la sede asignada, registro de marcas de ingreso y salida con liquidación horaria de jornada, consulta semanal de turnos y formulación de descargos por tardanzas justificadas.
- **Recepción Pericial e Inspección Vehicular en Patio:** Búsqueda reactiva de vehículos y clientes por placa de rodaje o documento fiscal en base de datos local y remota, afiliación de nuevos clientes presenciales, registro formal de órdenes de trabajo, captura fotográfica pericial de carrocería en 360 grados mediante CameraX con carga asíncrona hacia almacenamiento en la nube, y documentación de averías imprevistas detectadas en fosa.
- **Presupuestos Comerciales y Liquidación de Órdenes:** Motor aritmético de cálculo en cascada de mano de obra técnica, materiales e impuestos de ley, imputación supervisada de repuestos, generación y renderizado documental de proformas comerciales digitales en formato PDF para remisión directa, y registro formal de la resolución comunicada por el cliente.
- **Ejecución en Bahía, Cronometraje y Abastecimiento FIFO:** Panel móvil del técnico para priorización de faenas asignadas por orden de trabajo, cronómetro reactivo de labor efectiva con persistencia ante interrupciones de sesión, catálogo interactivo de repuestos en bodega, descargo físico y contable bajo la regla estricta FIFO por lote de adquisición más antiguo, y restitución de existencias ante descarte técnico.

La @tbl:development-evidence-mobile detalla la relación cronológica completa de los doscientos veintiún commits registrados en la rama principal del repositorio de la aplicación móvil Android correspondientes al ciclo constructivo del Sprint 2.

\begingroup
\scriptsize
\setlength{\tabcolsep}{2.5pt}
\renewcommand{\arraystretch}{1.15}
\begin{longtable}{| >{\raggedright\arraybackslash}p{2.6cm} | >{\centering\arraybackslash}p{1.4cm} | >{\centering\arraybackslash}p{1.6cm} | >{\raggedright\arraybackslash}p{4.4cm} | >{\raggedright\arraybackslash}p{3.4cm} | >{\centering\arraybackslash}p{1.8cm} |}
\caption{Evidencias de Desarrollo del Repositorio de Aplicación Móvil Android (Sprint 2)} \label{tbl:development-evidence-mobile} \\
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{2.6cm}|}{\textbf{Repository}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.4cm}|}{\textbf{Branch}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.6cm}|}{\textbf{Commit Id}} & \multicolumn{1}{>{\centering\arraybackslash}p{4.4cm}|}{\textbf{Commit Message}} & \multicolumn{1}{>{\centering\arraybackslash}p{3.4cm}|}{\textbf{Commit Message Body}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.8cm}|}{\textbf{Commited on (Date)}} \\
\hline
\endfirsthead
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{2.6cm}|}{\textbf{Repository}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.4cm}|}{\textbf{Branch}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.6cm}|}{\textbf{Commit Id}} & \multicolumn{1}{>{\centering\arraybackslash}p{4.4cm}|}{\textbf{Commit Message}} & \multicolumn{1}{>{\centering\arraybackslash}p{3.4cm}|}{\textbf{Commit Message Body}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.8cm}|}{\textbf{Commited on (Date)}} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{0bee07f} & Merge branch 'release/\allowbreak 0.20.0' & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{3ee930b} & Merge branch 'feature/\allowbreak ui-corrections' into develop & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{468ebd2} & chore(git): ignore codegraph cache directory. & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{a226ed5} & feat(main): integrate admin dashboard, obd hub, notifications and offline queue screens. & Wire administrative attendance and dashboard screens, more hub with quick action grid, notifications center with read state management, OBD live metrics and ... & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{db58311} & feat(attendance): add employee dashboard and supervisor daily review flow. & Add daily branch attendance inspection for supervisors with justification approval/\allowbreak rejection, provide employee dashboard overview, and update attendance navi... & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{1aec31f} & feat(diagnostics): add obd device registration and status use cases. & Support OBD-II IoT scanner lifecycle with device registration and operational status updates against IoT microservice endpoints. & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{d81fda8} & feat(bays): add bay creation use case and management screen. & Introduce physical workshop bays management, create bay use case, local Room caching in BayDao, and interactive bays overview screen with status indicators. & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{422e828} & feat(tasks,inventory): improve task part charging dialogs and inventory catalog navigation. & Polish task details and part charging dialog with stock validation and quantity controls, integrate quick camera action for task evidence, and support catalo... & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{a35b0ea} & feat(workorders): refine quotation summary, work order details and dialog interactions. & Implement modal dialogs for intake photos, vehicle handover, mileage verification and bay assignment, enhance quotation cascade breakdown display, improve se... & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{c447b31} & feat(reception): enrich vehicle search, customer cache and registration flow. & Provide reactive Room observation for customers and vehicles, implement vehicle references enrichment, modernize vehicle search with status filter chips and ... & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{6c4bf39} & feat(auth): enhance branch selection with assigned branch badge and session fallback. & Mark branch choice pending when employee profile has no branch assigned, highlight current branch with badge, and preselect active branch from current session. & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{f4ee106} & feat(designsystem): add grouped card, selection card and capsule bottom navigation. & Upgrade AtelierNavigationBar to a floating capsule design with animated active state, introduce AtelierGroupedCard, AtelierMainTopBar and AtelierSelectionCar... & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{41c84a5} & feat(core): harden sync concurrency, supabase upload handling and push history. & Enforce thread-safe single sync execution with Mutex in SyncProcessor, exclude operations waiting for dependencies in nextAttemptAt, extract error messages f... & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{be7c045} & chore(git): ignore release apks and build outputs. & Add release APKs directory and artifact patterns to .gitignore to prevent compiled binaries from polluting the repository working tree. & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{383f6f0} & docs(storage): update supabase storage bucket and rls policies documentation. & Update documentation across mobile integration and offline sync to reflect the configured Supabase storage bucket (atelier-evidence) and RLS policy requireme... & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{5b0bbf3} & Merge branch 'feature/\allowbreak login' into develop & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{8ef4312} & chore: remove empty file & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{3157eec} & docs(auth): record notification and sign-out improvements & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{aef4471} & fix(auth): cap remote revocation time on sign-out & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{def6d45} & fix(auth): ask for notification permission once per sign-in & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{e4da415} & docs(auth): record sign-out and geofence emulator results & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{1d72bad} & docs(auth): record valid login and notification prompt results & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{e0a11b1} & docs(auth): record emulator test results for login and registration & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{419da08} & fix(auth): treat 404 on reset password as invalid link & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{744f44c} & docs(auth): record EP01 flows and update roadmap & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{e574705} & test(auth): cover password reset notice on login & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{38f20d9} & feat(auth): request notification permission after sign-in & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{f7033f2} & feat(auth): connect forgot password action on login & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{91f7a24} & feat(auth): add forgot and reset password routes & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{3d4a2aa} & feat(auth): add reset password screen & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{46cbd62} & feat(auth): add forgot password screen & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{7efc82e} & test(auth): cover reset password token extraction and expired token & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{7f9fcda} & test(auth): cover forgot password success, 400 and network error & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{e286ad2} & feat(auth): add reset password state and view model & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{59c8836} & feat(auth): add forgot password state and view model & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{274ded0} & docs(auth): add EP01 login and registration plan & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{d2a86ff} & docs(roadmap): document main bottom navigation and pending items & - & 02/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{fdaf502} & feat(main): add permission-based bottom navigation & Wrap the session NavHost in a Scaffold with MainNavigationBar, shown only on each tab's root screen. MainTab.tabsFor(session) picks the tabs by permission, n... & 02/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{1311209} & feat(designsystem): add navigation bar and tab icons & Add AtelierNavigationBar, the 80dp M3 bar from the gallery with a single sliding "lamp" indicator (380ms ease-out, snaps when animations are off) and an opti... & 02/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{c20f1d2} & feat(attendance): enforce geofence and complete attendance flow & - & 02/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{0e3c09d} & Merge branch 'release/\allowbreak 0.17.0' & - & 01/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{3f5d827} & Merge branch 'feature/\allowbreak quotation-ui' into develop & - & 01/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{4f5a748} & docs(roadmap): update step 6 with EP05 presentation deliverables & - & 01/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{381412d} & test(workorders): cover cascade breakdown, part charging, PDF proforma and quotation resolution & - & 01/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{7b6f42f} & feat(workorders): implement cascade cost engine, part charging, PDF proforma and quotation resolution & - & 01/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{3cdeead} & Merge branch 'feature/\allowbreak movil' into develop & - & 30/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{196c11d} & feat: implement core inventory, tasks, and work orders features with local database support. & - & 30/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{a8ae918} & Merge branch 'feature/\allowbreak tasks-inventory-ui' into develop & - & 29/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{cbad078} & docs(traceability): record backend findings H36-H39 from emulator testing & - & 29/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{03e35eb} & docs(tasks-inventory): update roadmap and traceability with EP06 and EP07 presentation deliverables & - & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{c71fc85} & feat(navigation): add debug-only entry points to tasks and inventory from attendance & Provisional access until main gets its permission-based NavigationBar. & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{fad3f5b} & test(tasks): cover part charge, stock conflict, return and quantity edit in TaskDetailViewModel & - & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{6beaf28} & feat(tasks): wire parts section and dialogs into TaskDetailScreen & - & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{5950e66} & feat(tasks): integrate charge, edit and RemovePartFromTaskUseCase in TaskDetailViewModel with origin batch restoration & - & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{a0c1653} & feat(tasks): add charged parts section and part dialogs for charge, edit and return & - & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{b2f2a58} & test(inventory): add unit tests for PartDetailViewModel FIFO ordering & - & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{89aa64e} & feat(inventory): build PartDetailScreen UI with batch details and next-batch indicator & - & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{0be1a19} & feat(inventory): implement PartDetailViewModel with chronological FIFO batches & - & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{6ef40a3} & feat(inventory): create PartDetailUiState and FIFO batch timeline component & - & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{3e546a9} & test(inventory): add unit tests for PartsCatalogViewModel and money formatting & - & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{26928da} & feat(inventory): build PartsCatalogScreen UI with parts cards and register inventory nav graph & - & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{3734e80} & feat(inventory): implement PartsCatalogViewModel with reactive SKU search and out-of-stock check & - & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{74c4e2b} & feat(inventory): create PartsCatalogUiState and item category filter chips & - & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{8daa195} & test(tasks): add unit tests for TaskDetailViewModel chronometer, pause and completion & Also fixes the MyTasksViewModelTest helper (value class cannot be vararg). & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{67b9e69} & feat(tasks): build TaskDetailScreen with dynamic chronometer timer and complete dialog & - & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{6a3a1f5} & feat(tasks): implement TaskDetailViewModel with elapsed time and pause handling & - & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{d0d8719} & feat(tasks): create TaskDetailUiState and pause reason modal components & - & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{f6aa76c} & test(tasks): add unit tests for MyTasksViewModel covering permissions and offline cache & - & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{1f59a86} & feat(tasks): build MyTasksScreen with task cards and register tasks nav graph & - & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{b99e4e4} & feat(tasks): add MyTasksViewModel with Room reactive caching and strings & - & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{eb38fc8} & feat(attendance): improve geofence attendance screen & - & 27/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{7ff3997} & Merge branch 'feature/\allowbreak reception-workorders-ui' into develop & - & 27/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{8c9669a} & feat: add gradle version catalog and branding documentation. & - & 27/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{a090dd5} & docs(ep03): update roadmap with the reception and work orders ui. & mark the presentation layer of step 6 as delivered for us11, us12, us13, us14, us15 and us44. list each screen with the use cases it uses and the decisions t... & 27/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{fc55752} & feat(us15): add proposals approval panel. & add the advisor panel that lists the proposals of a work order with their photo, severity and status. the advisor can email the proposal to the customer, reg... & 27/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{8adaaca} & feat(us14): add field finding report screen. & add the screen to report a finding in the pit or bay: severity, technical description, a required photo and an optional suggested service. the send button st... & 27/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{a1ad17b} & feat(us13): add reception photo gallery with camera capture. & add the intake gallery: a grid of inspection panels (front, rear, sides, roof, dashboard and others) where each tap opens the system camera, asking for the c... & 27/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{08861cb} & feat(us12): add work order opening form. & add the work order opening screen: mileage, fuel level, reason and the initial tasks with an optional mechanic. if the vehicle already has a draft order (an ... & 27/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{1630347} & feat(us11): add vehicle search and appointments ui. & add the reception search screen: look up a vehicle by plate or a customer by document, show the owner and the customer's vehicles, and send first-time visits... & 27/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{695d596} & feat(us44): add customer affiliation and registration ui. & add the reception navigation graph with the affiliation screen (email lookup, affiliate or walk-in step) and the customer and vehicle registration screen. th... & 27/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{c3dd68d} & feat(US3): add post-login branch selection flow & - & 27/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{c35320e} & Merge tag '0.12.0' into develop & Release 0.12.0. 0.12.0 & 26/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{fa16504} & Merge branch 'release/\allowbreak 0.12.0' & - & 26/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{d80a49c} & Merge branch 'develop' of github.com:upc-pre-202620-1acc0238-4951-andeva/\allowbreak atelier-mobile-android into develop & - & 26/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{c97b2b9} & Merge branch 'feature/\allowbreak bays-board-hardening' into develop & - & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{92021be} & Merge branch 'feature/\allowbreak team' into develop & - & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{34bb6d6} & Merge branch 'feature/\allowbreak reports' into develop & - & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{205743c} & Merge branch 'feature/\allowbreak cashier' into develop & - & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{874ede1} & test(bays): stop board observers before closing the test database. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{39fdfc3} & fix(bays): keep the board alive on an unreadable order detail. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{35ce46d} & docs: record team gaps and mark step 9. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{4a6cd8a} & feat(team): add team use cases. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{29c4e02} & fix(team): treat an unreadable history as a failure. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{91c1601} & fix(team): treat unreadable responses as failed days. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{d5671a1} & feat(team): add team attendance repository. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{8828e6c} & docs: record attendance presentation progress in roadmap & - & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{63a1f98} & feat(attendance): wire attendance navigation and location permission & - & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{db448ef} & feat(attendance): add attendance and shift schedule screen & - & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{64249a1} & feat(attendance): add attendance presentation state and actions & - & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{b6c4559} & feat(team): define team attendance domain. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{f03c01b} & docs: record cash flow backend gap. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{51c76ab} & fix(reports): reject a blank fleet customer. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{b2bad94} & docs: record reports gap and mark step 9 reports. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{0959ba1} & feat(reports): add report use cases. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{e5bf06f} & fix(reports): never invent a report currency. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{abe91a4} & feat(reports): add cash flow and fleet health reports. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{088d018} & docs: align cashier gaps with final review. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{27d2272} & fix(cashier): refuse payments on inactive vouchers and harden mappings. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{f6fcc6a} & fix(cashier): require real line descriptions and skip free items. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{85266aa} & fix(cashier): treat empty or 5xx responses as unknown outcomes. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{1d50b58} & fix(cashier): serialize issuing and payments per order and voucher. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{7d4b991} & docs: record cashier gaps and mark step 9 cashier. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{cda191c} & feat(cashier): add cashier use cases. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{fd332df} & feat(reception): read a customer online. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{ecda076} & feat(workorders): start, complete and cancel work orders. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{c1a6454} & feat(cashier): configure fiscal series. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{b8ad42e} & fix(cashier): keep the issue outcome and never cache invented amounts. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{0c8a2ca} & fix(cashier): never invent voucher amounts or currency. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{7a422d1} & feat(cashier): add payments, exit pass and vehicle handover. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{844ad05} & fix(cashier): keep voucher amounts and issue outcome on mapping errors. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{4f02b91} & feat(cashier): issue sunat vouchers from work orders. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{2857b91} & feat(cashier): build voucher draft from work order. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{6c3be9a} & feat(cashier): define voucher and payment domain. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{d0ca3a1} & Merge tag '0.11.0' into develop & Release 0.11.0. 0.11.0 & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{3727d7f} & Merge branch 'release/\allowbreak 0.11.0' & - & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{531e5ec} & Merge branch 'feature/\allowbreak bays' into develop & - & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{bf83ef6} & docs: clarify bays use cases in roadmap. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{55166b1} & refactor(bays): own the bay cache scope. & The "bays:\{branchId\}" cache\_metadata scope now lives in bays (BayCacheScope) and tasks imports it, so bays no longer depends on the tasks implementation. Co-... & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{60a76e9} & fix(bays): cache the work order header loaded by the board. & loadTasks already fetched the full work order and discarded the header, so a board opened before the work order list was refreshed showed occupied bays witho... & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{8ba14a3} & fix(bays): share one bay repository so reassignments refresh the board. & BayRepositoryImpl holds the mechanicChanges signal, so it must be a singleton. otherwise the observe and reassign use cases got different instances. reassign... & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{70d72fe} & docs: record bays gaps and mark step 9 bays. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{24c68ab} & feat(bays): add bay board use cases. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{2cf7007} & fix(bays): emit bay board before order details load. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{2df541d} & feat(bays): add bay board repository. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{e76bdbc} & refactor(bays): move work bay service from tasks. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{ab992dc} & feat(bays): define bay board domain. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{d1ae65e} & Merge tag '0.10.0' into develop & Release 0.10.0. 0.10.0 & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{d99b1cd} & Merge branch 'release/\allowbreak 0.10.0' & - & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{6efe686} & Merge branch 'feature/\allowbreak diagnostics' into develop & - & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{89585e5} & docs: mark step 8 in roadmap. & Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{35be54e} & feat(diagnostics): add obd-ii link, fault codes, telemetry queue and ai health reports. & Domain, application and infrastructure for US16-US21 and US43 E1: ELM327 over Bluetooth SPP, live telemetry batched through the offline queue, DTC scan and c... & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{a21ecec} & docs: record iot gaps and elm327 commands for step 8. & Add H16-H23 to the traceability gaps and the extra ELM327 commands used by the diagnostics feature. Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{b8b7b02} & docs: record auth presentation scope in roadmap & - & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{21ef029} & feat(auth): wire the auth navigation graph & - & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{29356f0} & feat(designsystem): add atelier fonts & - & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{f088003} & feat(auth): add email verification code screen & - & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{2326a92} & feat(auth): add invitation registration screen & - & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{5a16023} & feat(auth): add login screen & - & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{320dfa0} & feat(designsystem): add Atelier theme, typography and fonts. & - & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{c0ddc4d} & feat(designsystem): add base components and UiText. & - & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{8a88bcb} & Merge tag '0.8.0' into develop & Release 0.8.0. 0.8.0 & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{433855c} & Merge branch 'release/\allowbreak 0.8.0' & - & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{1bd015b} & Merge branch 'feature/\allowbreak inventory' into develop & - & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{23efa23} & docs: mark step 7 in roadmap. & list the inventory pieces ready for the ui team and what stays out of this step. Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{d4a72df} & feat(inventory): add catalog, batches, alerts and purchase order reception. & the catalog is cached page by page and searched online or offline by name or sku, batches are kept in fifo order, alerts come from the backend or the cached ... & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{d946abf} & docs: record inventory backend behavior for step 7. & items are paged in memory, batches come newest first with exhausted ones, alerts are computed and resolve does nothing, low stock pushes repeat and receive a... & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{5ee162d} & Merge tag '0.7.0' into develop & Release 0.7.0. 0.7.0 & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{4c781e3} & Merge branch 'release/\allowbreak 0.7.0' & - & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{4e081a9} & Merge branch 'feature/\allowbreak reception-workorders' into develop & - & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{7a396db} & docs: mark step 6 in roadmap. & list the reception and work order pieces ready for the ui team, add photo capture and pdf downloader to the core tree, and fix the profitability response typ... & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{b077048} & feat(auth): accept the full email link as token. & invitation and reset emails link to the web app (h1), so the token is read from the url. Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{e7c049c} & feat(reception, workorders): add step 6 domain, use cases and data layer. & reception covers plate and customer search, walk-in and company sign-up, affiliation, the branch agenda and appointment arrival, which waits for the async wo... & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{49cffe9} & refactor(core): extract photo capture and add pdf downloader. & photo capture holds the compress, upload and attach queue flow shared by task evidence, intake photos and proposals. pdf downloader saves backend pdfs in cac... & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{9a88575} & fix(tasks): reload task after updating part quantity. & the put response is built by hand on the backend (h9), so the task is fetched again. Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{80bc8ad} & fix(attendance): only 404 means no attendance today. & other status-today errors now fail the refresh instead of reading as no attendance. Co-Authored-By: Claude Opus 5.5 \textless{}noreply@anthropic.com\textgreater{} & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{a3561bd} & docs: record backend answers for open gaps. & close h2, h3, h4, h7 and h8 against atelier-platform 1.2.0 and add h9 to h11. note that r3 and r4 shipped in 1.1.0, that voucher types travel as sunat codes,... & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{cbd75bb} & Merge tag '0.6.0' into develop & Release 0.6.0. 0.6.0 & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{a250bcb} & Merge branch 'release/\allowbreak 0.6.0' & - & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{b1de817} & Merge branch 'feature/\allowbreak tasks' into develop & - & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{b809ba4} & test(tasks): add comprehensive test suite. & Add unit and integration tests for task domain rules, Room TaskDao, sync handlers, and repository. & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{edd49e1} & feat(tasks): add task workflow use cases. & Add Clean Architecture UseCases for task transitions, suspension, parts imputation, and photo evidence. & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{31d130c} & feat(tasks): implement api, sync, and repo. & Implement Retrofit services, photo evidence capture, sync handler, and task repository. & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{5dd2e83} & feat(tasks): add task dao, mappers, and module. & Add TaskDao queries for mechanic tasks, entity mapping to domain, and Hilt DAO provider. & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{4c25b90} & feat(tasks): define domain models and rules. & Define DDD domain models, evidence kinds, pause reasons, and repository interface for tasks. & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{8bd34dc} & feat(core): add bay and vehicle lookup daos. & Register BayDao and VehicleDao in AppDatabase and add lookup queries in pending uploads. & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{9ab4b12} & docs: update tasks traceability and roadmap. & Document mechanic tasks endpoints, offline evidence queue, and mark Step 5 in roadmap. & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{6561bb6} & Merge branch 'release/\allowbreak 0.5.0' & - & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{2e5fa07} & Merge tag '0.5.0' into develop & Release 0.5.0. 0.5.0 & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{1c76f74} & Merge branch 'feature/\allowbreak attendance' into develop & - & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{b1a1334} & test(attendance): add comprehensive test suite. & Add unit and integration tests for attendance domain rules, DAOs, handlers, use cases, and repository. & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{ba3b275} & feat(attendance): add clock and shift use cases. & Add Clean Architecture UseCases for clock-in, clock-out, justifications, and schedule observers. & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{919eaaa} & feat(attendance): implement sync, api and repo. & Implement Retrofit services, FusedLocationProvider, sync operation handlers, and repository. & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{582c565} & feat(attendance): add room daos and mappers. & Integrate AttendanceDao, BranchDao, and ShiftDao into AppDatabase with entity mappers. & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{5919c3e} & feat(attendance): define domain models and rules. & Define DDD domain models, geofencing rules, exceptions, and repository interface for attendance. & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{3835428} & refactor(core): share employee service and clock. & Move EmployeeService to core shared network, add ClockModule, and introduce BusinessTime utility. & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{97937cf} & docs: update attendance traceability and roadmap. & Document attendance endpoints, sync handlers, geofence, and update step 4 in roadmap. & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{88f3302} & Merge tag '0.4.0' into develop & Release 0.4.0. 0.4.0 & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{47dd96c} & Merge branch 'release/\allowbreak 0.4.0' & - & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{86f4ff3} & Merge branch 'feature/\allowbreak main' into develop & - & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{52a2543} & feat(main): add navigation and sync use cases. & Add Clean Architecture UseCases for main navigation, session observation, push inbox, and sync queue. & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{41c64f7} & feat(main): implement sync operation repository. & Define domain models, repository contract, Hilt module, and implementation for pending sync items. & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{25db62e} & feat(core): extend session and sync operations. & Extend Session with tab calculation and expose pending operation queries in PendingOperationDao. & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{074c6ef} & docs: update roadmap step 3 main in progress. & Update status for Step 3 (main) in the construction roadmap. & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{4d79626} & Merge tag '0.3.0' into develop & Release 0.3.0. 0.3.0 & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{0c44f29} & Merge branch 'release/\allowbreak 0.3.0' & - & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{068dba5} & Merge branch 'feature/\allowbreak auth' into develop & - & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{41f4da1} & test(auth): add unit tests for repository. & Add unit tests verifying AuthRepositoryImpl behavior, sign-in, token refresh, and sign-out logic. & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{9f422e5} & feat(auth): add authentication use cases. & Add Clean Architecture UseCases for authentication, password reset, and invitation acceptance. & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{d353758} & feat(auth): implement remote api and repository. & Implement Retrofit auth services, Google ID token provider, Hilt DI modules, and repository. & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{aaac16c} & feat(auth): define domain models and repository. & Define domain contracts, invitation models, and validation rules for authentication. & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{ecf9210} & docs: update auth traceability and roadmap. & Document auth feature endpoints, permissions, and mark Step 2 in progress. & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{0492a30} & Merge tag '0.2.0' into develop & Release 0.2.0. 0.2.0 & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{543716b} & Merge branch 'release/\allowbreak 0.2.0' & - & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{198c692} & Merge branch 'feature/\allowbreak core' into develop & - & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{688b4cd} & docs: add development roadmap and guidelines. & Add 07-roadmap.md and link it across AGENTS.md and docs/\allowbreak README.md. & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{0268aca} & feat(app): bootstrap application and navigation. & Bootstrap application with Hilt, configure permissions in AndroidManifest, and setup authenticated routing. & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{7d2dcf6} & feat(core): configure di, media, and push. & Configure Hilt dependency injection, Supabase storage uploader, and Firebase push notification routing. & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{bf24b4e} & feat(sync): implement offline sync engine. & Implement offline sync processor, pending operation queue, WorkManager scheduler, and tests. & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{94e751a} & feat(data): setup room database and entities. & Setup Room database schema version 1 and local entities for all workshop domains. & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{3a2d19f} & feat(core): implement network client and auth. & Add Retrofit interceptors, token refresh mechanism, session management, and connectivity observers. & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{4e6a5d9} & feat(core): implement domain models and session. & Define core DDD domain models, money representation, permissions, and session authorization. & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{eb9e73d} & docs: update architecture and offline sync guides. & Update mobile architecture and offline sync documentation. & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{bcf3b27} & docs(brand): add design system and assets. & Introduce brand identity documentation, typography assets, logos, and style sheets. & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{2208683} & Merge branch 'release/\allowbreak 0.1.1' & - & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{effc6bd} & Merge tag '0.1.1' into develop & Release 0.1.1. 0.1.1 & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{7e60204} & refactor: clean up legacy package structure. & Move navigation and designsystem files from legacy tech.andeva namespace to com.andeva.atelier.mobile. & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{a9dd0ae} & Merge branch 'release/\allowbreak 0.1.0' & - & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{371c95c} & Merge tag '0.1.0' into develop & Release 0.1.0 0.1.0 & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{ddc0d9e} & chore: setup dependencies and package structure & Add core libraries, plugins, documentation, and refactor package namespace to com.andeva.atelier.mobile. & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{933323c} & chore: set up app foundation dependencies & - & 22/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{9e8a78e} & initial commit & - & 22/\allowbreak 10/\allowbreak 2026 \\ \hline
\end{longtable}
\endgroup

_Nota._ Registro cronológico de commits de implementación en el repositorio oficial de la aplicación móvil Android.

#### 4.2.2.5. Testing Suite Evidence for Sprint Review

Para asegurar la robustez arquitectónica, el cumplimiento determinista de las reglas de negocio y la ausencia de regresiones en la aplicación móvil, el equipo implementó una estrategia integral de aseguramiento de la calidad automatizada durante el segundo ciclo constructivo. Esta estrategia se articula sobre la pirámide de pruebas, combinando suites unitarias sobre la lógica de dominio y modelos de vista, pruebas de integración con persistencia relacional en memoria y simulación de contratos de red, y pruebas de aceptación orientadas a comportamiento bajo la metodología Behavior-Driven Development.

El repositorio oficial que alberga la infraestructura de pruebas automatizadas y el código fuente de la aplicación móvil se encuentra disponible en GitHub mediante el siguiente enlace:

- **Repositorio de Pruebas Automatizadas (Atelier Workshop Mobile):** [https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier-mobile-android](https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier-mobile-android) en el directorio `app/src/test/java`.

El ecosistema de pruebas automatizadas de la aplicación móvil se implementó utilizando el marco JUnit 4 en conjunto con MockK para la suplantación controlada de dependencias, Kotlinx Coroutines Test con el despachador runTest para la verificación de flujos asíncronos y StateFlow, y MockWebServer de OkHttp para interceptar y validar solicitudes RESTful sin dependencias de red externa. Asimismo, se incorporaron las bibliotecas AndroidX Room Testing para certificar las transacciones y consultas SQL en bases de datos SQLite efímeras, AndroidX Work Testing para validar la ejecución diferida de la cola de sincronización fuera de línea, y Robolectric para ejecutar pruebas que involucran componentes del SDK de Android directamente sobre la máquina virtual Java sin requerir emuladores pesados.

La suite automatizada abarca un total de noventa clases de prueba y seiscientas cincuenta pruebas automatizadas organizadas según los trece módulos funcionales y arquitectónicos de la solución:

- **Núcleo Compartido y Persistencia Fuera de Línea (14 clases de prueba, 55 pruebas):** Verifican la decodificación de reclamos en tokens JWT, el almacenamiento seguro de credenciales en DataStore Preferences, el interceptor de red con refresco transparente ante expiración de sesión, la encapsulación funcional de respuestas con ApiResult, el servicio de carga de evidencias periciales hacia Supabase Storage, el enrutador de notificaciones push de Firebase Cloud Messaging, las utilidades de formateo monetario y el procesamiento determinista de la cola de sincronización diferida mediante WorkManager.
- **Autenticación y Control de Acceso (10 clases de prueba, 64 pruebas):** Validan las reglas de dominio para contraseñas seguras, los modelos de vista para inicio de sesión con correo corporativo y proveedor federado de Google, la vinculación de colaboradores a partir de invitaciones, la verificación de identidad mediante código numérico de seis dígitos, el restablecimiento de contraseñas y la selección de la sede de trabajo activa.
- **Control de Asistencia Satelital y Turnos (6 clases de prueba, 32 pruebas):** Comprueban las entidades de dominio de asistencia laboral, el cálculo de distancia geodésica mediante la fórmula matemática de Haversine frente a las coordenadas de la sucursal, la persistencia de eventos de marcación de ingreso y salida en Room, y los casos de uso para consulta de turnos y justificación de tardanzas.
- **Recepción Pericial e Inspección en Patio (7 clases de prueba, 59 pruebas):** Evalúan la búsqueda reactiva de vehículos por placa y documento fiscal en caché local y remota, el alta de clientes presenciales, la vinculación vehicular, el estado de la interfaz de usuario en patio y el registro de kilometraje y combustible.
- **Órdenes de Trabajo y Presupuestos (9 clases de prueba, 100 pruebas):** Verifican la apertura formal de órdenes de trabajo, la galería de evidencias fotográficas en 360 grados, el motor de cálculo aritmético en cascada de mano de obra y piezas, la generación y descarga de proformas digitales en formato PDF mediante PdfDownloader, y el panel para registrar la resolución comercial del cliente.
- **Ejecución y Cronometraje de Faenas en Bahía (9 clases de prueba, 72 pruebas):** Validan la consulta y ordenamiento de tareas por prioridad operativa, el cronómetro reactivo de labor efectiva con persistencia del tiempo acumulado ante cierres inesperados, la imputación de materiales a la tarea técnica y la sincronización de evidencias de averías detectadas en fosa.
- **Inventario y Abastecimiento FIFO (6 clases de prueba, 48 pruebas):** Aseguran el comportamiento del catálogo de repuestos, el filtrado dinámico por categoría y código, la consulta de existencias físicas y la ejecución del algoritmo de descargo contable bajo la regla estricta FIFO por lote de adquisición más antiguo.
- **Gestión de Bahías y Fosos (5 clases de prueba, 22 pruebas):** Verifican el tablero de monitoreo de bahías, los accesos a datos mediante DAO en SQLite, la asignación dinámica de mecánicos a bahías de servicio y los casos de uso para administrar la capacidad instalada del taller.
- **Diagnóstico Electrónico y Telemetría (9 clases de prueba, 50 pruebas):** Validan el registro y vinculación de escáneres OBD2 por Bluetooth Low Energy, el intérprete de comandos ELM327 y códigos de avería electrónica DTC, las sesiones de monitoreo telemático en vivo y la persistencia de informes de salud vehicular.
- **Caja y Cobranza (6 clases de prueba, 92 pruebas):** Evalúan las validaciones de balance de caja, la generación de comprobantes de pago, la persistencia de borradores de facturación y el registro transaccional de cobros.
- **Gestión de Personal y Equipos (5 clases de prueba, 32 pruebas):** Comprueban el panel de presencia de colaboradores, los transformadores de datos de asistencia remota y la sincronización de calendarios laborales semanales.
- **Reportes Operativos (3 clases de prueba, 14 pruebas):** Verifican las funciones de agregación estadística, la liquidación de horas laborales por periodos y los indicadores de rendimiento de patio y bahía.
- **Navegación y Cola de Sincronización (1 clase de prueba, 10 pruebas):** Certifica la visualización de operaciones pendientes fuera de línea y la navegación condicional en la barra principal según los permisos de rol del colaborador autenticado.

**Especificación de Pruebas de Aceptación BDD (Gherkin Feature Files)**

Para formalizar los criterios de aceptación de las historias de usuario construidas durante el segundo ciclo constructivo, el equipo elaboró las especificaciones de comportamiento en lenguaje Gherkin. Estas definiciones documentan de forma ejecutable los escenarios de éxito y las excepciones operativas previstas para la aplicación móvil:

```gherkin
Feature: Marcacion de ingreso laboral con validacion de geocerca GPS satelital (US06)
  Como mecanico o colaborador operativo del taller
  Quiero registrar mi marcacion de ingreso desde la aplicacion movil
  Para acreditar mi asistencia validando que me encuentro fisicamente en la sede de trabajo

  Scenario: Marcacion exitosa dentro del perimetro delimitado de la sede
    Given que el colaborador ha iniciado sesion con credenciales activas
    And que la sede de trabajo asignada registra coordenadas de latitud -12.1200 y longitud -77.0300
    And que el dispositivo movil reporta coordenadas con precision satelital de 10 metros
    When el colaborador presiona el boton de registro de ingreso
    Then el sistema calcula la distancia geodesica mediante el algoritmo de Haversine
    And verifica que la distancia resultante de 25 metros se encuentra dentro del radio permitido de 100 metros
    And almacena la marcacion de ingreso en la base de datos local Room
    And despacha la transaccion al servicio central de recursos humanos respondiendo HTTP 201 Created

  Scenario: Rechazo de marcacion por encontrarse fuera del perimetro geofisico
    Given que el colaborador se encuentra a una distancia de 350 metros respecto a la sucursal
    When el colaborador intenta registrar su ingreso desde la aplicacion movil
    Then el sistema bloquea el registro por violacion del radio de tolerancia geofisico
    And presenta un mensaje informativo advirtiendo que la marcacion solo es valida dentro de la sede
    And no genera ningun registro de asistencia en el servidor
```

```gherkin
Feature: Registro pericial de evidencias fotograficas de recepcion vehicular 360 grados (US13)
  Como recepcionista de patio del taller automotriz
  Quiero registrar fotografias periciales de los cuatro angulos del vehiculo al momento de ingresar
  Para documentar de forma inmutable el estado inicial de la carroceria y respaldar la atencion

  Scenario: Captura pericial completa de recepcion vehicular en patio
    Given una orden de trabajo recien abierta para el vehiculo con placa "ABC-123"
    And la camara del dispositivo movil habilitada mediante CameraX
    When el recepcionista captura cuatro fotografias correspondientes al frontal, posterior y laterales
    Then la aplicacion comprime las imagenes localmente y genera miniaturas visuales en cuadricula
    And almacena las rutas locales en SQLite con estado pendiente de subida
    And transfiere los archivos multipart hacia el bucket de almacenamiento seguro en la nube
    And asocia los enlaces permanentes de las imagenes al registro de inspeccion de la orden de trabajo

  Scenario: Restriccion ante intento de superar el limite de capturas permitido
    Given que la orden de trabajo ya cuenta con ocho fotografias periciales registradas
    When el usuario intenta activar el obturador de camara para añadir una fotografia adicional
    Then la aplicacion deshabilita el boton de captura
    And muestra una alerta indicando que se ha alcanzado la capacidad maxima de evidencias por orden
```

```gherkin
Feature: Computo en cascada de costos y emision de proforma digital en PDF (US22 y US24)
  Como asesor de servicio o administrador del taller
  Quiero calcular el presupuesto de la orden y generar el documento digital de cotizacion
  Para enviar una propuesta formal y transparente al cliente previo a iniciar las faenas

  Scenario: Calculo automatico en cascada y generacion de proforma en PDF
    Given una orden de trabajo con una tarea de mano de obra valorizada en 150.00 PEN
    And dos repuestos imputados con precios unitarios de 80.00 PEN y 120.00 PEN
    When el usuario solicita la emision de la proforma comercial
    Then el sistema totaliza el costo de mano de obra en 150.00 PEN
    And totaliza el costo de materiales y repuestos en 200.00 PEN
    And computa el subtotal gravable en 350.00 PEN
    And aplica el impuesto general a las ventas del 18 por ciento equivalente a 63.00 PEN
    And determina el importe total a cobrar en 413.00 PEN
    And compila el archivo digital en formato PDF estructurando membrete, tareas y costos
    And habilita el envio del documento mediante las aplicaciones de mensajeria del dispositivo
```

```gherkin
Feature: Descargo contable y fisico automatizado mediante regla estricta FIFO por lote (US32)
  Como mecanico en bahia o encargado de almacen
  Quiero descargar repuestos para una tarea mecanica en ejecucion
  Para rebajar las existencias de bodega valorizando el consumo segun el lote mas antiguo

  Scenario: Descargo de repuestos rebajando unidades del lote cronologico mas antiguo
    Given el repuesto "Filtro de Aceite Sintetico" con saldo total de 8 unidades en dos lotes
    And el lote "LOTE-202610-A" ingresado el 23 de octubre con 3 unidades a costo unitario de 30.00 PEN
    And el lote "LOTE-202610-B" ingresado el 28 de octubre con 5 unidades a costo unitario de 35.00 PEN
    When el mecanico efectua la requisicion de 4 unidades para la tarea asignada
    Then el sistema agota completamente las 3 unidades del lote mas antiguo "LOTE-202610-A" a 30.00 PEN
    And toma 1 unidad del siguiente lote "LOTE-202610-B" a 35.00 PEN
    And calcula el costo total imputado a la orden en 125.00 PEN
    And actualiza el inventario disponible de bodega a 4 unidades remanentes en el lote "LOTE-202610-B"
    And asienta la transaccion en el kardex contable local y remoto
```

**Registro de Commits de Pruebas Automatizadas**

La @tbl:testing-evidence-commits-mobile presenta la relación cronológica de los trece commits etiquetados expresamente para el diseño, implementación y verificación de la suite de pruebas automatizadas en el repositorio de la aplicación móvil Android.

\begingroup
\scriptsize
\setlength{\tabcolsep}{2.5pt}
\renewcommand{\arraystretch}{1.15}
\begin{longtable}{| >{\raggedright\arraybackslash}p{2.6cm} | >{\centering\arraybackslash}p{1.4cm} | >{\centering\arraybackslash}p{1.6cm} | >{\raggedright\arraybackslash}p{4.4cm} | >{\raggedright\arraybackslash}p{3.4cm} | >{\centering\arraybackslash}p{1.8cm} |}
\caption{Registro de Commits de Pruebas Automatizadas (Sprint 2)} \label{tbl:testing-evidence-commits-mobile} \\
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{2.6cm}|}{\textbf{Repository}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.4cm}|}{\textbf{Branch}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.6cm}|}{\textbf{Commit Id}} & \multicolumn{1}{>{\centering\arraybackslash}p{4.4cm}|}{\textbf{Commit Message}} & \multicolumn{1}{>{\centering\arraybackslash}p{3.4cm}|}{\textbf{Commit Message Body}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.8cm}|}{\textbf{Commited on (Date)}} \\
\hline
\endfirsthead
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{2.6cm}|}{\textbf{Repository}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.4cm}|}{\textbf{Branch}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.6cm}|}{\textbf{Commit Id}} & \multicolumn{1}{>{\centering\arraybackslash}p{4.4cm}|}{\textbf{Commit Message}} & \multicolumn{1}{>{\centering\arraybackslash}p{3.4cm}|}{\textbf{Commit Message Body}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.8cm}|}{\textbf{Commited on (Date)}} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{e574705} & test(auth): cover password reset notice on login & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{7efc82e} & test(auth): cover reset password token extraction and expired token & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{7f9fcda} & test(auth): cover forgot password success, 400 and network error & - & 10/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{381412d} & test(workorders): cover cascade breakdown, part charging, PDF proforma and quotation resolution & - & 01/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{fad3f5b} & test(tasks): cover part charge, stock conflict, return and quantity edit in TaskDetailViewModel & - & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{b2f2a58} & test(inventory): add unit tests for PartDetailViewModel FIFO ordering & - & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{3e546a9} & test(inventory): add unit tests for PartsCatalogViewModel and money formatting & - & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{8daa195} & test(tasks): add unit tests for TaskDetailViewModel chronometer, pause and completion & Also fixes the MyTasksViewModelTest helper (value class cannot be vararg). & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{f6aa76c} & test(tasks): add unit tests for MyTasksViewModel covering permissions and offline cache & - & 28/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{874ede1} & test(bays): stop board observers before closing the test database. & - & 25/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{b809ba4} & test(tasks): add comprehensive test suite. & Add unit and integration tests for task domain rules, Room TaskDao, sync handlers, and repository. - TaskDomainTest.kt: Task transitions, labor duration calc... & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{b1a1334} & test(attendance): add comprehensive test suite. & Add unit and integration tests for attendance domain rules, DAOs, handlers, use cases, and repository. - AttendanceDomainTest.kt: Geofence bounds, shift sche... & 24/\allowbreak 10/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier-mobile-android & main & \texttt{41f4da1} & test(auth): add unit tests for repository. & Add unit tests verifying AuthRepositoryImpl behavior, sign-in, token refresh, and sign-out logic. - AuthRepositoryImplTest.kt: Test suite mocking remote serv... & 23/\allowbreak 10/\allowbreak 2026 \\ \hline
\end{longtable}
\endgroup

_Nota._ Registro cronológico de commits etiquetados para la suite de pruebas automatizadas en el repositorio atelier-mobile-android.

#### 4.2.2.6. Execution Evidence for Sprint Review

Durante el segundo ciclo constructivo, el equipo completó la puesta en marcha operativa y la verificación funcional de la aplicación móvil nativa Android denominada Atelier Workshop Mobile. La solución fue compilada, empaquetada y distribuida mediante la plataforma Firebase App Distribution, permitiendo a los miembros del equipo y a los usuarios evaluadores instalar el artefacto ejecutable en dispositivos móviles físicos y emuladores para validar la fluidez de las interfaces de usuario, la persistencia local de datos y la capacidad de sincronización con el backend en tiempo real.

La verificación de ejecución se articuló de manera diferenciada para los dos segmentos objetivo del negocio, comprobando que las interfaces respondan a las responsabilidades operativas y al entorno físico de cada perfil:

En el ámbito del segmento de gestión y administración, se validó la experiencia para el perfil de propietarios y jefes de taller, representado por el arquetipo Pedro Suárez. La interfaz concentra la gobernanza comercial del taller en un panel de control interactivo que exhibe métricas consolidadas sobre órdenes de trabajo activas, cotizaciones pendientes de resolución con el cliente, disponibilidad de bahías mecánicas, alertas de stock mínimo para repuestos y control de personal presente en sede. Asimismo, la vista incorpora accesos directos para la búsqueda rápida de unidades por placa de rodaje y la afiliación de clientes presenciales en patio, tal como se ilustra en la @fig:execution-evidence-mobile-management.

![Vista principal del panel administrativo para propietarios y gestores de taller en Atelier Workshop Mobile](report/assets/deploy/result-deploy-mobile-android-2.jpeg){#fig:execution-evidence-mobile-management width=45%}

_Nota._ Captura de pantalla de la aplicación móvil Android en dispositivo físico, evidenciando el panel de control para el perfil de gestión con métricas de órdenes, bahías, existencias y accesos de recepción en patio.

En el ámbito del personal operativo de taller, se comprobó la experiencia para el perfil de mecánicos de bahía y foso, representado por el arquetipo Andrés Vílchez. La interfaz adopta un diseño ergonómico de uso rudo en modo oscuro, optimizado para la legibilidad bajo reflectores intensos y la interacción mediante zonas de pulsación amplias. El panel presenta el estado de la jornada laboral activa en la sucursal asignada, la faena técnica en curso con cronómetro de labor efectiva, la lista de tareas priorizadas por realizar y las herramientas de patio para diagnóstico telemático OBD-II, reporte de averías imprevistas con evidencia fotográfica y consulta de repuestos en bodega con valoración FIFO, según se exhibe en la @fig:execution-evidence-mobile-operative.

![Vista principal del panel operativo para técnicos mecánicos en foso y bahía en Atelier Workshop Mobile](report/assets/deploy/result-deploy-mobile-android-3.jpeg){#fig:execution-evidence-mobile-operative width=38%}

_Nota._ Captura de pantalla de la aplicación móvil Android en dispositivo físico, evidenciando el panel de trabajo técnico con estado de jornada, cronómetro de faena activa y herramientas de patio.

Con el propósito de exhibir de manera dinámica y detallada la navegación, interactividad y ejecución de la aplicación móvil en ambos perfiles operativos, complementando con la demostración de la distribución mediante Firebase App Distribution, el equipo grabó una presentación audiovisual completa.

- **Enlace al Video Demostrativo del Sprint 2:** [Demostración Audiovisual del Sprint 2 (Microsoft Stream / OneDrive)](https://upcedupe-my.sharepoint.com/:v:/g/personal/u20241e275_upc_edu_pe/IQAuVHyQwBkXSqgICZyTHABqAS8JEDlujs-J4eJpfciKy2U?nav=eyJyZWZlcnJhbEluZm8iOnsicmVmZXJyYWxBcHAiOiJPbmVEcml2ZUZvckJ1c2luZXNzIiwicmVmZXJyYWxBcHBQbGF0Zm9ybSI6IldlYiIsInJlZmVycmFsTW9kZSI6InZpZXciLCJyZWZlcnJhbFZpZXciOiJNeUZpbGVzTGlua0NvcHkifX0&e=erHMlT)

#### 4.2.2.7. Services Documentation Evidence for Sprint Review

Durante el segundo ciclo constructivo, la documentación técnica de servicios web y la especificación de contratos de interfaz bajo OpenAPI 3.1 no experimentaron modificaciones ni adiciones, debido a que la totalidad de los servicios web del backend de la plataforma (Atelier Platform) fue implementada, documentada e integrada de manera exhaustiva durante el primer ciclo constructivo.

#### 4.2.2.8. Software Deployment Evidence for Sprint Review

Durante el segundo ciclo constructivo, el equipo implementó y automatizó el proceso de distribución y despliegue continuo de la aplicación móvil nativa Atelier Workshop Mobile mediante la plataforma Firebase App Distribution de Google Cloud. Esta infraestructura de distribución permite a los desarrolladores compilar binarios firmados y ponerlos a disposición inmediata de los evaluadores, mecánicos y jefes de taller autorizados, facilitando la instalación en dispositivos físicos Android y emuladores sin intermediación de tiendas comerciales públicas.

El flujo de despliegue abarcó la configuración del proyecto en Firebase Console, la incorporación del manifiesto de servicios de Google, la creación de un almacén criptográfico de claves de producción (Keystore), la vinculación de huellas digitales de seguridad SHA-1 y SHA-256, la compilación de la variante Release ofuscada mediante R8 y la emisión de invitaciones controladas a los evaluadores. A continuación, se detallan los pasos técnicos ejecutados:

**Paso 1: Consolidación y etiquetado del repositorio en GitHub.** El equipo aseguró la integración y validación previa de todo el código Kotlin, recursos de diseño y pruebas unitarias en la rama principal \texttt{main} del repositorio \texttt{atelier-mobile-android}. Se formalizó el release 1.0.0 generando la etiqueta canónica en el historial de control de versiones, tal como se aprecia en la @fig:deploy-app-step-1.

![Consolidación de la rama principal del repositorio atelier-mobile-android en GitHub](report/assets/deploy/deploy-app-android-1.png){#fig:deploy-app-step-1 width=75%}

_Nota._ Vista del repositorio oficial atelier-mobile-android en GitHub evidenciando la rama principal y las etiquetas de versión generadas.

**Paso 2: Selección de la plataforma Android en Firebase Console.** Se accedió al panel de control del proyecto \texttt{atelier-platform} en Firebase, alojado bajo el plan Spark, y se seleccionó la plataforma Android dentro de las opciones de clientes compatibles para iniciar el alta de la aplicación, como se ilustra en la @fig:deploy-app-step-2.

![Selección de la plataforma Android en la consola de Firebase](report/assets/deploy/deploy-app-android-2.png){#fig:deploy-app-step-2 width=75%}

_Nota._ Consola principal del proyecto atelier-platform en Firebase destacando la selección del entorno Android.

**Paso 3: Registro de la aplicación móvil en el proyecto.** Se registró la aplicación asignando el nombre de paquete canónico \texttt{com.andeva.atelier.mobile} y el alias descriptivo \texttt{Atelier Workshop}, vinculando formalmente el cliente móvil al ecosistema en la nube, según se muestra en la @fig:deploy-app-step-3.

![Registro del identificador de paquete y alias de la aplicación en Firebase](report/assets/deploy/deploy-app-android-3.png){#fig:deploy-app-step-3 width=75%}

_Nota._ Formulario de registro de aplicación en Firebase con el nombre de paquete com.andeva.atelier.mobile y el alias corporativo.

**Paso 4: Descarga del archivo de configuración google-services.json.** Firebase generó el manifiesto de configuración específico para la aplicación, conteniendo el identificador de cliente, el identificador del proyecto y las claves de acceso requeridas por las bibliotecas de Google Services, tal como se observa en la @fig:deploy-app-step-4.

![Descarga del archivo de configuración google-services.json provisto por Firebase](report/assets/deploy/deploy-app-android-4.png){#fig:deploy-app-step-4 width=75%}

_Nota._ Asistente de descarga del manifiesto de configuración google-services.json para su incorporación en el proyecto Android.

**Paso 5: Incorporación de google-services.json en el módulo de la aplicación.** En Android Studio, se ubicó el archivo \texttt{google-services.json} directamente en la raíz del módulo \texttt{app/}, asegurando que el plugin de Gradle procese los metadatos durante las fases de precompilación, como se exhibe en la @fig:deploy-app-step-5.

![Ubicación del archivo google-services.json en el directorio raíz del módulo app](report/assets/deploy/deploy-app-android-5.png){#fig:deploy-app-step-5 width=40%}

_Nota._ Estructura de directorios en Android Studio mostrando la ubicación del archivo google-services.json dentro del módulo app.

**Paso 6: Apertura del asistente de compilación de binarios firmados.** Para preparar el artefacto instalable, se accedió al menú principal de Android Studio a través de la ruta \texttt{Build} > \texttt{Generate Signed App Bundle or APK...}, tal como se ilustra en la @fig:deploy-app-step-6.

![Menú de generación de ejecutables firmados en Android Studio](report/assets/deploy/deploy-app-android-6.png){#fig:deploy-app-step-6 width=65%}

_Nota._ Menú de compilación de Android Studio para inicializar la generación de paquetes firmados.

**Paso 7: Selección del formato ejecutable APK para distribución.** Dentro del asistente, se seleccionó la modalidad APK en lugar del formato de paquete para tienda comercial, permitiendo generar un archivo binario autónomo que los evaluadores puedan instalar directamente en sus terminales, según se aprecia en la @fig:deploy-app-step-7.

![Selección de la modalidad APK firmado para distribución directa](report/assets/deploy/deploy-app-android-7.png){#fig:deploy-app-step-7 width=50%}

_Nota._ Ventana de selección del tipo de paquete firmado eligiendo la opción de APK para instalación directa.

**Paso 8: Generación del almacén criptográfico de claves de producción.** Se creó un nuevo almacén seguro denominado \texttt{atelier-release.jks} con el alias \texttt{atelier}, una validez de veinticinco años y el certificado corporativo expedido a nombre de Joel Huamani Estefanero para la organización Andeva en Lima, Perú, tal como se muestra en la @fig:deploy-app-step-8.

![Creación del nuevo almacén criptográfico Keystore para la firma del release](report/assets/deploy/deploy-app-android-8.png){#fig:deploy-app-step-8 width=50%}

_Nota._ Formulario de creación del almacén de claves criptográficas atelier-release.jks con vigencia de 25 años.

**Paso 9: Vinculación de huellas digitales SHA en Firebase Console.** Para habilitar la verificación de identidad criptográfica en los servicios en la nube, se extrajeron las huellas digitales SHA-1 y SHA-256 del certificado generado y se vincularon en la ficha técnica de la aplicación dentro de Firebase Console, según se evidencia en la @fig:deploy-app-step-9.

![Asociación de huellas digitales SHA-1 y SHA-256 en la ficha de la app en Firebase](report/assets/deploy/deploy-app-android-9.png){#fig:deploy-app-step-9 width=70%}

_Nota._ Panel de configuración del SDK en Firebase Console mostrando la vinculación de los certificados criptográficos SHA-1 y SHA-256.

**Paso 10: Configuración de credenciales de firma en Android Studio.** Se asoció la ruta física del almacén \texttt{atelier-release.jks}, el alias \texttt{atelier} y las contraseñas de protección al módulo \texttt{Atelier\_Workshop.app}, habilitando el proceso de firmado automático, como se ilustra en la @fig:deploy-app-step-10.

![Configuración del almacén de firmas y alias en el asistente de Android Studio](report/assets/deploy/deploy-app-android-10.png){#fig:deploy-app-step-10 width=50%}

_Nota._ Asistente de firma de Android Studio configurado con la ruta del keystore y el alias atelier.

**Paso 11: Compilación de la variante Release optimizada con R8.** Se seleccionó la variante de compilación \texttt{release} y la carpeta de destino del módulo, ejecutando el proceso de minificación de código, optimización de recursos y ofuscación mediante R8 para generar el archivo \texttt{app-release.apk}, tal como se aprecia en la @fig:deploy-app-step-11.

![Selección de la variante Release para la compilación del binario APK](report/assets/deploy/deploy-app-android-11.png){#fig:deploy-app-step-11 width=50%}

_Nota._ Diálogo de selección de la variante release y directorio de salida para la compilación optimizada.

**Paso 12: Carga del paquete APK y alta de evaluadores en App Distribution.** En la consola de Firebase App Distribution, se subió el binario correspondiente a la versión 1.0 (código de versión 1) compilado el 10 de noviembre de 2026, y se registró a los evaluadores del proyecto mediante su correo institucional, como se exhibe en la @fig:deploy-app-step-12.

![Carga del artefacto ejecutable y asignación de evaluadores en Firebase App Distribution](report/assets/deploy/deploy-app-android-12.png){#fig:deploy-app-step-12 width=75%}

_Nota._ Consola de App Distribution mostrando la versión 1.0 (1) y la adición del evaluador u20241e275@upc.edu.pe.

**Paso 13: Verificación del release distribuido en la consola de Firebase.** Se confirmó la publicación activa del release 1.0 (1) en el panel de versiones de Firebase App Distribution, exhibiendo el estado de la invitación y los canales de retroalimentación habilitados, tal como se ilustra en la @fig:deploy-app-step-13.

![Panel de control de versiones distribuidas en Firebase App Distribution](report/assets/deploy/deploy-app-android-13.png){#fig:deploy-app-step-13 width=80%}

_Nota._ Vista de la versión 1.0 (1) en Firebase App Distribution confirmando la distribución activa y el correo de contacto.

**Paso 14: Notificación por correo electrónico y guía de instalación para evaluadores.** Los evaluadores recibieron una invitación por correo electrónico emitida por Firebase con las instrucciones detalladas para aceptar la prueba, habilitar orígenes desconocidos en el dispositivo Android y descargar la aplicación Atelier Workshop para iniciar las sesiones de validación, según se muestra en la @fig:result-deploy-mobile-1.

![Notificación por correo electrónico recibida por los evaluadores para instalar la aplicación](report/assets/deploy/result-deploy-mobile-android-1.png){#fig:result-deploy-mobile-1 width=80%}

_Nota._ Correo de invitación de Firebase App Distribution con el procedimiento guiado de descarga e instalación para los evaluadores.

#### 4.2.2.9. Team Collaboration Insights during Sprint

Durante el segundo ciclo constructivo, el equipo profundizó la dinámica ágil multidisciplinaria para alcanzar la meta del sprint, concentrando el esfuerzo colectivo en la construcción de la aplicación móvil nativa Atelier Workshop Mobile. Para asegurar la transparencia, la trazabilidad del código y la distribución equitativa de las responsabilidades técnicas, el equipo utilizó de manera permanente las herramientas de analíticos de GitHub Insights sobre el repositorio oficial de la aplicación y el tablero ágil en Jira Software.

La disciplina de ingeniería de software se articuló mediante el flujo de trabajo Git Flow, organizando el desarrollo en ramas por funcionalidad derivadas de \texttt{develop}, ejecutando revisiones de pares mediante solicitudes de extracción con análisis estático previo y consolidando los incrementos verificados en la rama principal \texttt{main}. Esta metodología evitó colisiones en la integración de componentes de interfaz y garantizó que cada funcionalidad incorporada mantenga las pruebas automatizadas en estado verde.

**Analíticos de Colaboración en el Repositorio Atelier Workshop Mobile**

La implementación de la aplicación móvil nativa Android en el repositorio \texttt{atelier-mobile-android} registró un total de doscientos veintiún commits en la rama principal distribuidos durante el mes de desarrollo. La @fig:collab-insights-mobile-sprint-2 exhibe el reporte cuantitativo de contribuciones por autor provisto por GitHub Insights, evidenciando la actividad sostenida del equipo a lo largo de las semanas de trabajo.

![Analíticos de contribución y commits por autor en el repositorio de la aplicación móvil Android](report/assets/sprint-2/commits-mobile-android-sprint-2.png){#fig:collab-insights-mobile-sprint-2 width=70%}

_Nota._ Gráfico de contribuciones semanales y registro individual de commits en la rama principal del repositorio atelier-mobile-android obtenido de GitHub Insights.

La interpretación técnica de estos analíticos refleja una distribución de responsabilidades armónica y alineada con la matriz de liderazgo y colaboración establecida para el segundo sprint:

- **Joel Huamani Estefanero (\texttt{shouydev}):** Como líder técnico de arquitectura y Bounded Contexts fundacionales, asumió el diseño estructural de la solución bajo Clean Architecture, la inyección de dependencias con Hilt, la capa de persistencia local en SQLite mediante Room con colas de sincronización fuera de línea, la integración de la cámara pericial con CameraX, el cliente de red con Retrofit 2 y el protocolo de diagnóstico vehicular mediante Bluetooth Low Energy con adaptadores ELM327 OBD-II. Su liderazgo se refleja en ciento dos commits y más de cuarenta y seis mil líneas de código estructuradas.
- **Luis Granda Ibarra (\texttt{danieltyuyu}):** Como líder técnico de interfaz y experiencia de usuario en móvil, implementó el sistema de diseño sobre Jetpack Compose Material 3 con paleta en modo oscuro de uso rudo para talleres, diseñando los componentes de recepción pericial en 360 grados, el panel de patio, las vistas ergonómicas para mecánicos en bahía y el cronómetro reactivo de labor efectiva. Su labor acumuló cincuenta y un commits y más de quince mil líneas de interfaz reactiva.
- **Mauricio Teran Zavala (\texttt{mau-tz}):** Como colaborador en los módulos de inventario y navegación, desarrolló las pantallas de catálogo de repuestos con filtrado en tiempo real, la recepción de lotes de compra, la lógica de presentación del consumo FIFO y la barra de navegación principal condicionada según los roles de seguridad del usuario autenticado, registrando trece commits y más de cuatro mil seiscientas líneas.
- **Alvaro Rocha Cotrina (\texttt{alvarorc24}):** Como colaborador en los módulos de personal y autenticación, apoyó la implementación de las vistas de marcación de ingreso laboral con validación geodésica satelital, los formularios de solicitud de justificación por tardanza y los flujos de inicio de sesión con recuperación de contraseña, aportando seis commits y más de mil cien líneas.
- **Adiel Sanchez Santin (\texttt{xs4el}):** Como especialista de soporte en contratos de backend, verificó la consistencia entre los esquemas DTO consumidos por la aplicación móvil y los endpoints RESTful provistos por la plataforma en la nube, garantizando la paridad de tipos de datos y la gestión de errores HTTP RFC 7807, registrando tres commits técnicos de homologación.

En conclusión, los analíticos demuestran una ejecución sincronizada, con una distribución efectiva del trabajo entre todos los integrantes del equipo y un estricto cumplimiento de los estándares de calidad de software y cobertura de pruebas establecidos para el proyecto.

\newpage
