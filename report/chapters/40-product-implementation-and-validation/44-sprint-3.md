### 4.2.3. _Sprint 3_

El tercer y último ciclo constructivo aborda el desarrollo de la aplicación móvil multiplataforma Atelier Workshop Mobile en Flutter y Dart. Tras haber desplegado los servicios web del backend en la primera iteración y culminado la versión nativa en Android con Kotlin durante el segundo ciclo, el equipo concentra el esfuerzo en construir la solución multiplataforma orientada a dispositivos Android e iOS.

El alcance comprometido abarca veintiuna historias de usuario que suman cincuenta y siete puntos de historia. Estas historias completan el catálogo funcional del producto mediante el diagnóstico vehicular inalámbrico con escáneres OBD-II por Bluetooth Low Energy, el monitoreo de parámetros telemétricos en vivo, la generación de informes periciales asistidos por inteligencia artificial, la emisión de comprobantes electrónicos UBL 2.1 ante la SUNAT, el cobro multimedio en patio, la supervisión de bahías en tiempo real y la persistencia local fuera de línea mediante Drift sobre SQLite.

#### 4.2.3.1. Sprint Planning 3

La sesión formal de planificación del Sprint 3 se realizó el 12 de noviembre de 2026 a las 02:00 PM mediante una reunión síncrona en Discord con los cinco integrantes del equipo. Al iniciar la jornada se revisó el cierre del ciclo anterior y se verificó la estabilidad del binario Android publicado en Firebase App Distribution. Con esa base, el equipo definió la meta de la iteración, distribuyó las veintiuna historias de usuario en Flutter según la especialidad técnica de cada desarrollador y fijó el compromiso de velocidad en cincuenta y siete Story Points.

La @tbl:sprint-planning-3 resume los antecedentes operativos de la sesión, los acuerdos de retrospectiva, el objetivo de la iteración y la carga de esfuerzo comprometida.

\renewcommand{\arraystretch}{1.2}
\begin{longtable}{| >{\raggedright\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{\dimexpr\textwidth-4.8cm-4\tabcolsep-3\arrayrulewidth\relax} |}
\caption{Sprint Planning 3 - Resumen de la sesión de planificación del Sprint 3} \label{tbl:sprint-planning-3} \\
\hline
\thfirst{Sprint \#} & \thcell{Sprint 3} \\
\hline
\endfirsthead
\hline
\thfirst{Sprint \#} & \thcell{Sprint 3} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
\thspanfirst{2}{Sprint Planning Background} \\
\hline
\textbf{Date} & 2026-11-12 \\
\hline
\textbf{Time} & 02:00 PM - 04:30 PM \\
\hline
\textbf{Location} & Sesión síncrona virtual mediante Discord \\
\hline
\textbf{Prepared By} & Huamani Estefanero, Joel \\
\hline
\textbf{Attendees to planning meeting} & Granda Ibarra, Luis Daniel / Huamani Estefanero, Joel / Rocha Cotrina, Alvaro / Sanchez Santin, Adiel Abdiaz / Teran Zavala, Mauricio Alejandro \\
\hline
\textbf{Sprint 2 Review Summary} & Culminación del Sprint 2 con el 100\% de los entregables comprometidos, equivalente a cincuenta y cinco Story Points distribuidos en veintidós historias de usuario. Se implementó la aplicación nativa Android en Kotlin y Jetpack Compose con persistencia local en Room SQLite, cubriendo autenticación institucional, control de asistencia por geocerca Haversine, recepción pericial 360°, cálculo de presupuestos en PDF, ejecución cronometrada de faenas y descargo FIFO. El binario APK firmado se publicó mediante Firebase App Distribution para su validación en dispositivos físicos. \\
\hline
\textbf{Sprint 2 Retrospective Summary} & El equipo valoró positivamente la estabilidad de la arquitectura limpia y la cobertura de seiscientas cincuenta pruebas automatizadas logradas en Android nativo. Para la transición hacia la aplicación multiplataforma en Flutter durante el ciclo final, se acordó aplicar directamente los hallazgos de los spikes SP01 y SP03 utilizando la biblioteca \texttt{flutter\_blue\_plus} para la comunicación con adaptadores ELM327 y Drift sobre SQLite para el almacenamiento local sin conexión. Asimismo, se priorizó la validación de extremo a extremo en la emisión de comprobantes UBL 2.1 con el Proveedor de Servicios Electrónicos antes del cierre del proyecto. \\
\hline
\pagebreak
\thspanfirst{2}{Sprint Goal \& User Stories} \\*
\hline
\textbf{Sprint 3 Goal} & \textbf{Our focus is on} desarrollar y validar la aplicación móvil multiplataforma Atelier Workshop Mobile en Flutter y Dart, implementando el diagnóstico vehicular OBD-II por Bluetooth Low Energy, los informes predictivos con inteligencia artificial, la facturación electrónica UBL 2.1 ante SUNAT, la supervisión en vivo de bahías, el cobro multimedio y la persistencia local fuera de línea con Drift sobre SQLite.\newline
\textbf{We believe it delivers} portabilidad multiplataforma entre Android e iOS manteniendo la paridad funcional del taller, permitiendo diagnosticar fallas electrónicas con respaldo pericial, emitir comprobantes tributarios válidos desde patio y operar con continuidad en zonas sin cobertura de red.\newline
\textbf{This will be confirmed when} la aplicación compilada en Flutter opere de forma fluida en dispositivos físicos, enlace escáneres OBD-II para leer y restablecer códigos DTC con exportación en PDF, emita comprobantes electrónicos UBL 2.1 y supere las suites de pruebas automatizadas junto con las pruebas de aceptación en producción. \\
\hline
\textbf{Sprint 3 Velocity} & 57 \\
\hline
\textbf{Sum of Story Points} & 57 \\
\hline
\end{longtable}

*Nota.* Cuadro de planificación del Sprint 3 adaptado de la guía de Scrum para el proyecto Atelier.

\newpage

#### 4.2.3.2. Aspect Leaders and Collaborators

Para delimitar la propiedad técnica de cada módulo en Flutter y coordinar las entregas entre los cinco desarrolladores, el equipo estructuró la matriz de liderazgo y colaboración LACX correspondiente al tercer ciclo. Cada aspecto funcional asigna un líder técnico encargado de la arquitectura del módulo, la cobertura de pruebas y la integración con el backend, respaldado por los demás integrantes en tareas de interfaz y verificación.

El alcance del Sprint 3 se organiza en cinco aspectos funcionales y arquitectónicos que cubren las veintiuna historias de usuario comprometidas:

- **Flutter: Diagnóstico OBD-II e IA Predictiva:** Comprende el enlace inalámbrico con escáneres OBD-II por Bluetooth Low Energy mediante la biblioteca `flutter_blue_plus`, la lectura y decodificación de códigos de falla DTC, el restablecimiento de alertas en la computadora vehicular y la generación de informes periciales predictivos con inteligencia artificial en PDF, cubriendo las historias US16, US17, US20 y US21.
- **Flutter: Telemetría en Vivo y Operaciones en Fosa:** Abarca el monitoreo dinámico de parámetros PID en tiempo real, el registro fotográfico pericial de desmontaje y montaje de piezas en fosa, la solicitud administrativa de suspensión por pieza defectuosa, el cierre técnico con cómputo de horas hombre efectivas y la supervisión con reasignación de bahías en tiempo real, abarcando las historias US18, US28, US29, US30 y US40.
- **Flutter: Facturación Electrónica SUNAT y Caja:** Involucra la liquidación económica automática en cascada de la orden de trabajo, la emisión de comprobantes tributarios electrónicos UBL 2.1 ante la SUNAT a través del Proveedor de Servicios Electrónicos y la exportación del reporte de flujo de caja en PDF, cubriendo las historias US36, US37 y US41.
- **Flutter: Inventario FIFO, Series Fiscales y Reportes:** Contempla el disparo y desactivación de alertas automáticas de reposición por stock mínimo, la imputación automática de precios de catálogo con conciliación de margen FIFO, la configuración de información fiscal y series SUNAT y la descarga de informes periciales de salud vehicular en PDF, cubriendo las historias US34, US35, US42 y US43.
- **Flutter: Seguridad Móvil, Pagos y Sincronización Drift:** Agrupa el cierre de sesión seguro con revocación de credenciales, el restablecimiento de acceso mediante token de verificación, la persistencia local con Drift sobre SQLite y sincronización diferida en fosa, la recaudación multimedio en mostrador y el pase de salida vehicular tras el pago, abarcando las historias US04, US05, US19, US38 y US39.

La @tbl:aspect-leaders-3 detalla la asignación de roles de liderazgo representados con la letra L y de colaboración indicados con la letra C para cada integrante del equipo en los cinco aspectos del Sprint 3.

\begingroup
\footnotesize
\setlength{\tabcolsep}{2.5pt}
\renewcommand{\arraystretch}{1.2}
\begin{longtable}{| >{\raggedright\arraybackslash}p{2.65cm} | >{\centering\arraybackslash}p{1.75cm} | >{\centering\arraybackslash}p{2.14cm} | >{\centering\arraybackslash}p{2.14cm} | >{\centering\arraybackslash}p{2.14cm} | >{\centering\arraybackslash}p{2.14cm} | >{\centering\arraybackslash}p{2.14cm} |}
\caption{Matriz de Líderes y Colaboradores por Aspecto del Sprint 3 (LACX)} \label{tbl:aspect-leaders-3} \\
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{2.65cm}|}{\textbf{Team Member}\newline\textbf{(Last Name,}\newline\textbf{First Name)}} & \textbf{GitHub}\newline\textbf{Username} & \textbf{Flutter:}\newline\textbf{OBD-II e IA}\newline\textbf{Predictiva}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} & \textbf{Flutter:}\newline\textbf{Telemetría y}\newline\textbf{Fosa en Vivo}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} & \textbf{Flutter:}\newline\textbf{Facturación}\newline\textbf{SUNAT y Caja}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} & \textbf{Flutter:}\newline\textbf{Stock FIFO y}\newline\textbf{Series SUNAT}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} & \textbf{Flutter:}\newline\textbf{Seguridad y}\newline\textbf{Sync Drift}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} \\
\hline
\endfirsthead
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{2.65cm}|}{\textbf{Team Member}\newline\textbf{(Last Name,}\newline\textbf{First Name)}} & \textbf{GitHub}\newline\textbf{Username} & \textbf{Flutter:}\newline\textbf{OBD-II e IA}\newline\textbf{Predictiva}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} & \textbf{Flutter:}\newline\textbf{Telemetría y}\newline\textbf{Fosa en Vivo}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} & \textbf{Flutter:}\newline\textbf{Facturación}\newline\textbf{SUNAT y Caja}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} & \textbf{Flutter:}\newline\textbf{Stock FIFO y}\newline\textbf{Series SUNAT}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} & \textbf{Flutter:}\newline\textbf{Seguridad y}\newline\textbf{Sync Drift}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
Granda Ibarra, Luis Daniel & danieltyuyu & C & L & C & C & C \\
\hline
Huamani Estefanero, Joel & shouydev & L & C & C & C & C \\
\hline
Rocha Cotrina, Alvaro & alvarorc24 & C & C & C & C & L \\
\hline
Sanchez Santin, Adiel Abdiaz & xs4el & C & C & L & C & C \\
\hline
Teran Zavala, Mauricio Alejandro & mau-tz & C & C & C & L & C \\
\hline
\end{longtable}
\endgroup

*Nota.* Matriz de liderazgo y colaboración del Sprint 3 adaptada de la guía del proyecto Atelier.

\newpage

#### 4.2.3.3. Sprint Backlog 3

El Sprint Backlog del tercer ciclo reúne las veintiuna historias de usuario seleccionadas para completar la aplicación móvil multiplataforma Atelier Workshop Mobile en Flutter y Dart. La asignación suma cincuenta y siete puntos de historia, equivalentes a ciento setenta y una horas de trabajo estimadas a razón de tres horas por Story Point.

Cada historia de usuario se descompone en tareas de diseño de interfaz en Flutter, lógica de estado y casos de uso bajo arquitectura limpia, persistencia local con Drift sobre SQLite y consumo de la API RESTful del backend. El avance de las historias y la gestión de subtareas se centralizan en Jira Software mediante el enlace oficial del proyecto: [Tablero del Sprint 3 en Jira Software](https://andeva.atlassian.net/?continue=https%3A%2F%2Fandeva.atlassian.net%2Fwelcome%2Fsoftware%3FprojectId%3D10001&atlOrigin=eyJpIjoiZTAzNjYwMTQwNjVmNDVjY2ExOGUxZDkyMTBlMTUzNGIiLCJwIjoiamlyYS1zb2Z0d2FyZSJ9).

![Tablero del Sprint 3 en Jira Software](report/assets/sprint-3/table-jira-sprint-3.png){#fig:table-jira-sprint-3 width=90%}

*Nota.* Captura de pantalla del tablero ágil del Sprint 3 en Jira Software mostrando las veintiuna historias de usuario distribuidas entre las columnas To Do y Done.

La @tbl:sprint-backlog-3 presenta el Sprint Backlog consolidado del Sprint 3 con las veintiuna historias de usuario, el desglose de sus sesenta y tres subtareas técnicas sincronizadas con Jira Software, las estimaciones horarias y el estado completado de cada ítem.

\begingroup
\scriptsize
\setlength{\tabcolsep}{2pt}
\renewcommand{\arraystretch}{1.2}
\begin{longtable}{| >{\centering\arraybackslash}p{0.9cm} | >{\raggedright\arraybackslash}p{2.8cm} | >{\centering\arraybackslash}p{1.0cm} | >{\centering\arraybackslash}p{1.6cm} | >{\raggedright\arraybackslash}p{4.4cm} | >{\centering\arraybackslash}p{1.0cm} | >{\raggedright\arraybackslash}p{2.1cm} | >{\centering\arraybackslash}p{1.1cm} |}
\caption{Sprint Backlog del Sprint 3 y Estado de Ejecución de Ítems} \label{tbl:sprint-backlog-3} \\
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{0.9cm}|}{\textbf{Sprint \#}} & \multicolumn{7}{c|}{\textbf{Sprint 3}} \\
\hline
\multicolumn{2}{|c|}{\textbf{User Story}} & \multicolumn{6}{c|}{\textbf{Work-Item / Task}} \\
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{0.9cm}|}{\textbf{Id}} & \multicolumn{1}{>{\centering\arraybackslash}p{2.8cm}|}{\textbf{Title}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.0cm}|}{\textbf{Id}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.6cm}|}{\textbf{Title}} & \multicolumn{1}{>{\raggedright\arraybackslash}p{4.4cm}|}{\textbf{Description}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.0cm}|}{\textbf{Estimation}\newline\textbf{(Hours)}} & \multicolumn{1}{>{\centering\arraybackslash}p{2.1cm}|}{\textbf{Assigned}\newline\textbf{To}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.1cm}|}{\textbf{Status}} \\
\hline
\endfirsthead
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{0.9cm}|}{\textbf{Sprint \#}} & \multicolumn{7}{c|}{\textbf{Sprint 3}} \\
\hline
\multicolumn{2}{|c|}{\textbf{User Story}} & \multicolumn{6}{c|}{\textbf{Work-Item / Task}} \\
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{0.9cm}|}{\textbf{Id}} & \multicolumn{1}{>{\centering\arraybackslash}p{2.8cm}|}{\textbf{Title}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.0cm}|}{\textbf{Id}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.6cm}|}{\textbf{Title}} & \multicolumn{1}{>{\raggedright\arraybackslash}p{4.4cm}|}{\textbf{Description}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.0cm}|}{\textbf{Estimation}\newline\textbf{(Hours)}} & \multicolumn{1}{>{\centering\arraybackslash}p{2.1cm}|}{\textbf{Assigned}\newline\textbf{To}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.1cm}|}{\textbf{Status}} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US04 & Cierre de sesión seguro y revocación de credenciales en el dispositivo móvil & AT-336 & Pruebas & Agregar pruebas unitarias y de flujo para cierre de sesión y limpieza temporal & 1 & Rocha Cotrina, Alvaro & Done \\
\cline{3-8}
& & AT-337 & Dominio & Implementar limpieza de caché temporal y conteo de operaciones pendientes del dispositivo para cierre seguro & 1 & Rocha Cotrina, Alvaro & Done \\
\cline{3-8}
& & AT-338 & Auth / UI & Integrar la revocación de credenciales en el repositorio de autenticación y banner de pendientes al iniciar sesión & 1 & Rocha Cotrina, Alvaro & Done \\
\hline
US05 & Restablecimiento de credenciales de acceso mediante token de verificación & AT-339 & UI Flutter & Maquetar pantallas de solicitud y restablecimiento de contraseña con sus ViewModels y estados UI & 2 & Rocha Cotrina, Alvaro & Done \\
\cline{3-8}
& & AT-340 & Pruebas & Agregar pruebas de recuperación y restablecimiento de contraseña mediante enlace con token & 2 & Rocha Cotrina, Alvaro & Done \\
\cline{3-8}
& & AT-341 & Navegación & Implementar bandeja de enlaces profundos y rutas de recuperación en el grafo de autenticación & 2 & Rocha Cotrina, Alvaro & Done \\
\hline
US16 & Enlace inalámbrico y sincronización de escáner OBD-II en bahía & AT-324 & BLE / Parser & Implementar el enlace ELM327 por Bluetooth Low Energy y parser de respuestas OBD-II en Flutter & 3 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
& & AT-325 & UI Flutter & Maquetar la pestaña de dispositivos en el centro de diagnóstico con pruebas de protocolo y enlace & 3 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
& & AT-326 & Casos de Uso & Implementar los casos de uso de registro y actualización de estado de escáneres OBD-II contra la API IoT & 3 & Huamani Estefanero, Joel & Done \\
\hline
US17 & Extracción y decodificación de códigos de falla computarizados & AT-327 & UI Flutter & Maquetar pantalla de fallas vehiculares y ViewModel de diagnóstico para listar y consultar códigos por vehículo & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
& & AT-328 & Pruebas & Agregar pruebas unitarias y de widgets para el parser de códigos de falla y las pantallas correspondientes & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
& & AT-329 & Dominio & Implementar la decodificación de códigos de falla, mapeo local y encolado en el manejador de sincronización & 2 & Huamani Estefanero, Joel & Done \\
\hline
US18 & Monitoreo dinámico de parámetros telemétricos en tiempo real & AT-351 & UI Flutter & Maquetar pantalla de telemetría en vivo con congelamiento de valores, alertas y acceso desde el centro de diagnóstico & 3 & Granda Ibarra, Luis Daniel & Done \\
\cline{3-8}
& & AT-352 & API / Dominio & Implementar endpoint, esquema de transferencia, repositorio y caso de uso para lectura telemétrica en vivo & 3 & Granda Ibarra, Luis Daniel & Done \\
\cline{3-8}
& & AT-353 & Pruebas & Agregar pruebas de ViewModel de telemetría en vivo, contenido visual y flujo de extremo a extremo & 3 & Granda Ibarra, Luis Daniel & Done \\
\hline
US19 & Almacenamiento local resiliente y sincronización diferida en fosa & AT-342 & Pruebas & Agregar pruebas de persistencia local resiliente y sincronización diferida en fosa & 3 & Rocha Cotrina, Alvaro & Done \\
\cline{3-8}
& & AT-343 & Sync Hook & Implementar gancho previo a la sincronización en el procesador para volcar lecturas pendientes & 3 & Rocha Cotrina, Alvaro & Done \\
\cline{3-8}
& & AT-344 & Drift Local & Actualizar esquema Drift en SQLite para aislar lecturas telemétricas en fosa por técnico & 3 & Rocha Cotrina, Alvaro & Done \\
\hline
US20 & Borrado y verificación de restablecimiento de fallas en la computadora & AT-330 & ViewModel & Integrar los controles de borrado de fallas y actualización de estado en el ViewModel y hojas modales de diagnóstico & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
& & AT-331 & BLE / OBD & Implementar la limpieza de códigos de falla en la computadora vehicular mediante comando OBD-II y verificación posterior & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
& & AT-332 & Pruebas & Validar el flujo de restablecimiento y verificación de fallas mediante pruebas automatizadas de pantallas & 2 & Huamani Estefanero, Joel & Done \\
\hline
US21 & Generación de informe pericial predictivo con inteligencia artificial y exportación en PDF & AT-333 & UI Flutter & Maquetar pantalla de informe de salud IA y pestaña de alertas para generar y visualizar el diagnóstico predictivo & 5 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
& & AT-334 & Pruebas & Agregar pruebas de casos de uso, repositorio y pantallas de diagnóstico predictivo & 5 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
& & AT-335 & Dominio & Implementar las alertas predictivas con DAO local en Drift, consulta por taller y conversión a cita & 5 & Huamani Estefanero, Joel & Done \\
\hline
US28 & Registro fotográfico pericial de desmontaje y montaje de piezas en foso & AT-354 & Pruebas & Agregar textos de localización y pruebas de extremo a extremo para el registro fotográfico en foso & 2 & Granda Ibarra, Luis Daniel & Done \\
\cline{3-8}
& & AT-355 & Persistencia & Integrar la sección de evidencias sincronizadas y en cola dentro del detalle de tarea & 2 & Granda Ibarra, Luis Daniel & Done \\
\cline{3-8}
& & AT-356 & Cámara / UI & Maquetar la hoja de captura de evidencias con cámara y galería en el módulo de tareas & 2 & Granda Ibarra, Luis Daniel & Done \\
\hline
US29 & Solicitud y validación administrativa de suspensión por pieza defectuosa indispensable & AT-357 & Dominio & Implementar modelo de suspensión pendiente y búsqueda de suspensiones activas en órdenes de trabajo y panel & 2 & Granda Ibarra, Luis Daniel & Done \\
\cline{3-8}
& & AT-358 & Pruebas & Agregar pruebas de revisión administrativa de suspensiones en detalle de orden y flujo completo & 2 & Granda Ibarra, Luis Daniel & Done \\
\cline{3-8}
& & AT-359 & Push / UI & Maquetar hojas de solicitud, revisión y reanudación de suspensiones con navegación desde notificaciones push & 2 & Granda Ibarra, Luis Daniel & Done \\
\hline
US30 & Cierre técnico de tarea con cómputo de horas hombre efectivas & AT-360 & Dominio & Integrar el cómputo de horas hombre efectivas y actualización de estado en tareas técnicas & 2 & Granda Ibarra, Luis Daniel & Done \\
\cline{3-8}
& & AT-361 & UI Flutter & Implementar el botón de finalizar tarea en el dock de acción y hoja inferior de cierre técnico & 2 & Granda Ibarra, Luis Daniel & Done \\
\cline{3-8}
& & AT-362 & Pruebas & Agregar textos internacionalizados y pruebas de extremo a extremo para el cierre técnico de tarea & 2 & Granda Ibarra, Luis Daniel & Done \\
\hline
US34 & Disparo y desactivación de alertas automáticas de reposición por stock mínimo & AT-375 & Pruebas & Agregar pruebas de la bandeja de alertas de stock y recepción de compra & 2 & Teran Zavala, Mauricio Alejandro & Done \\
\cline{3-8}
& & AT-376 & Alertas UI & Maquetar pantalla de alertas de stock con ViewModel observando caché y apertura desde notificación de stock mínimo & 2 & Teran Zavala, Mauricio Alejandro & Done \\
\cline{3-8}
& & AT-377 & Cámara / API & Implementar recepción de compra con comprobante, fecha y foto de cámara en el detalle de orden emitida & 2 & Teran Zavala, Mauricio Alejandro & Done \\
\hline
US35 & Imputación automática de precios de venta de catálogo y conciliación de margen FIFO & AT-378 & Pruebas & Validar el cálculo de rentabilidad y margen FIFO en la orden de trabajo & 3 & Teran Zavala, Mauricio Alejandro & Done \\
\cline{3-8}
& & AT-379 & ViewModel & Implementar ViewModel de rentabilidad con cálculo en línea de ingreso por repuestos, costo FIFO y ganancia bruta & 3 & Teran Zavala, Mauricio Alejandro & Done \\
\cline{3-8}
& & AT-380 & UI Flutter & Maquetar tarjeta de rentabilidad en el detalle de la orden de trabajo con desglose por repuesto & 3 & Teran Zavala, Mauricio Alejandro & Done \\
\hline
US36 & Liquidación económica automática en cascada de la orden de trabajo & AT-366 & UI Flutter & Integrar el botón flotante de cobro y diálogo de liquidación en el detalle de orden de trabajo & 3 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
& & AT-367 & Dominio & Implementar sección de resumen de cotización con el desglose automático de liquidación económica en cascada & 3 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
& & AT-368 & Pruebas & Agregar pruebas de pantallas de órdenes y flujo de extremo a extremo para liquidación en cascada & 3 & Sanchez Santin, Adiel Abdiaz & Done \\
\hline
US37 & Emisión de comprobantes tributarios electrónicos UBL 2.1 ante SUNAT vía PSE & AT-369 & Pruebas & Agregar pruebas unitarias y flujo de extremo a extremo de facturación electrónica SUNAT & 5 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
& & AT-370 & Casos de Uso & Implementar casos de uso de emisión, nota de crédito, anulación, refresco de estado y descarga PDF de comprobantes & 5 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
& & AT-371 & SUNAT / UI & Maquetar gestión de comprobantes SUNAT, hoja de emisión UBL 2.1 y soporte de código QR en caja & 5 & Sanchez Santin, Adiel Abdiaz & Done \\
\hline
US38 & Recaudación y amortización de pagos multi-medio en mostrador y patio & AT-345 & ViewModel & Implementar la lógica de amortización y registro de pagos multimedio en el ViewModel de cobro & 3 & Rocha Cotrina, Alvaro & Done \\
\cline{3-8}
& & AT-346 & Checkout UI & Maquetar hojas modales y pantalla de cobro de orden de trabajo para el paso de recaudación multimedio & 3 & Rocha Cotrina, Alvaro & Done \\
\cline{3-8}
& & AT-347 & Pruebas & Agregar pruebas de ViewModel y flujo de extremo a extremo para recaudación multimedio & 3 & Rocha Cotrina, Alvaro & Done \\
\hline
US39 & Transición a orden pagada, emisión de pase de salida vehicular y entrega en patio & AT-348 & Checkout UI & Maquetar los pasos de pase de salida vehicular y confirmación de entrega en la pantalla de cobro & 2 & Rocha Cotrina, Alvaro & Done \\
\cline{3-8}
& & AT-349 & ViewModel & Implementar la transición a orden pagada, emisión de pase de salida y entrega en el ViewModel de cobro & 2 & Rocha Cotrina, Alvaro & Done \\
\cline{3-8}
& & AT-350 & Pruebas & Agregar pruebas de cierre de orden, pase de salida y entrega en patio & 2 & Rocha Cotrina, Alvaro & Done \\
\hline
US40 & Supervisión y reasignación de bahías de servicio en tiempo real & AT-363 & ViewModel & Integrar la asignación de bahías en el ViewModel de detalle de orden y accesos desde el panel de piso & 3 & Granda Ibarra, Luis Daniel & Done \\
\cline{3-8}
& & AT-364 & Bahías UI & Maquetar tablero de ocupación de bahías y registrar rutas de navegación correspondientes & 3 & Granda Ibarra, Luis Daniel & Done \\
\cline{3-8}
& & AT-365 & Pruebas & Agregar pruebas de ViewModel del tablero de bahías, contenido visual y flujo de supervisión & 3 & Granda Ibarra, Luis Daniel & Done \\
\hline
US41 & Exportación de reporte de flujo de caja en PDF para auditoría contable externa & AT-372 & Pruebas & Agregar pruebas de pantalla y ViewModel de reportes junto con el flujo de reporte de flujo de caja & 3 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
& & AT-373 & PDF / API & Implementar descarga de PDF de flujo de caja en el descargador remoto y ViewModel de reportes & 3 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
& & AT-374 & Reportes UI & Maquetar pantalla de reportes con filtro por sede y acciones de abrir y compartir PDF & 3 & Sanchez Santin, Adiel Abdiaz & Done \\
\hline
US42 & Configuración de información fiscal y series SUNAT con PSE administrado por la plataforma & AT-381 & Pruebas & Agregar pruebas del ViewModel de series fiscales y configuración de series por sede & 3 & Teran Zavala, Mauricio Alejandro & Done \\
\cline{3-8}
& & AT-382 & Series UI & Maquetar pantalla de series fiscales y registrar ruta de configuración fiscal en el grafo de caja & 3 & Teran Zavala, Mauricio Alejandro & Done \\
\cline{3-8}
& & AT-383 & ViewModel & Implementar ViewModel de series fiscales y gestión de series de factura y boleta con validación de duplicados & 3 & Teran Zavala, Mauricio Alejandro & Done \\
\hline
US43 & Descarga y remisión de informe pericial de salud vehicular en PDF para clientes y flotas & AT-384 & Reportes UI & Agregar sección Salud de flota en la pantalla de reportes con búsqueda de cliente y descarga de PDF consolidado & 3 & Teran Zavala, Mauricio Alejandro & Done \\
\cline{3-8}
& & AT-385 & PDF / API & Implementar descarga y compartido de PDF de salud vehicular en la pantalla de informe IA y su ViewModel & 3 & Teran Zavala, Mauricio Alejandro & Done \\
\cline{3-8}
& & AT-386 & Permisos & Actualizar validación de permisos de acceso y documentación de paridad funcional & 3 & Teran Zavala, Mauricio Alejandro & Done \\
\hline
\end{longtable}
\endgroup

*Nota.* Matriz consolidada del Sprint Backlog del Sprint 3 adaptada de Jira Software para el proyecto Atelier.

\newpage

#### 4.2.3.4. Development Evidence for Sprint Review

Durante el tercer ciclo constructivo, el equipo completó la implementación de la aplicación móvil multiplataforma Atelier Workshop Mobile en Flutter y Dart. La solución se estructuró bajo una arquitectura modular orientada a funcionalidades y capas limpias, integrando Drift sobre SQLite para persistencia local sin conexión, GetIt para inyección de dependencias, WorkManager para sincronización diferida en segundo plano, Universal BLE para comunicación Bluetooth Low Energy con escáneres OBD-II ELM327, Geolocator para validación geodésica y Firebase Cloud Messaging para notificaciones en tiempo real.

El código fuente completo, los módulos de dominio y las interfaces multiplataforma se encuentran alojados en el repositorio oficial de GitHub:

- **Repositorio de la Aplicación Multiplataforma (Flutter):** [https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier_mobile_crossplatform](https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier_mobile_crossplatform)

La @tbl:development-evidence-flutter consolida el historial cronológico de los 216 commits integrados en la rama principal del repositorio durante el Sprint 3.

\begingroup
\scriptsize
\setlength{\tabcolsep}{2.5pt}
\renewcommand{\arraystretch}{1.15}
\begin{longtable}{| >{\raggedright\arraybackslash}p{2.6cm} | >{\centering\arraybackslash}p{1.4cm} | >{\centering\arraybackslash}p{1.6cm} | >{\raggedright\arraybackslash}p{4.4cm} | >{\raggedright\arraybackslash}p{3.4cm} | >{\centering\arraybackslash}p{1.8cm} |}
\caption{Evidencias de Desarrollo del Repositorio de Aplicación Multiplataforma Flutter (Sprint 3)} \label{tbl:development-evidence-flutter} \\
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
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{d469922} & docs: marcar us34, us35, us42 y us43 como portadas en la presentación & Actualiza la paridad con Android, el plan de port y el roadmap. & 26/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{6c940e6} & feat(reports,diagnostics): PDF de salud vehicular y consolidado de flota (US43) & - AiHealthReportScreen: tarjeta "Informe en PDF" con Abrir y Compartir (solo en línea, iot:health\_reports:read). - ReportsScreen: sección "Salud de flota" co... & 26/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{68ce848} & feat(cashier): configuración de series fiscales por sede & Agrega FiscalSeriesScreen: lista las series de la sede, permite agregar una (factura F… o boleta B…, correlativo inicial opcional) y activar o desactivar las... & 26/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{97a4db7} & feat(workorders): tarjeta de rentabilidad con costo FIFO en la orden & Agrega WorkOrderProfitabilityCard con su ProfitabilityViewModel: ingreso por repuestos, costo de ventas FIFO, ganancia bruta y desglose por repuesto (la gana... & 26/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{0219d6b} & feat(inventory): alertas de stock mínimo y recepción de compra con foto & - StockAlertsScreen con ViewModel que observa la caché: la alerta desaparece sola al recibir la compra. - El push LOW\_STOCK abre la bandeja de alertas. - Rec... & 26/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{d424fac} & feat(presentation): agregar textos y rutas para us34, us35, us42 y us43 & Agrega las cadenas en español de las cuatro historias, las rutas stockAlerts y fiscalSeries, y las entradas "Alertas de stock" y "Series SUNAT" en la hoja de... & 26/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{85ee217} & Merge branch 'feature/\allowbreak sprint3-us18-us28-us29-us30-us40' into develop & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{e912301} & Merge branch 'develop' into feature/\allowbreak sprint3-us18-us28-us29-us30-us40 & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{f21b896} & docs(sprint3): update traceability, offline sync and parity for US04, US05, US19, US38 and US39 & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{07b727c} & test(sprint3): add tests for US04, US05, US19, US38 and US39 flows & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{ac979f9} & feat(cashier): port paid transition, exit pass and vehicle handover steps (US39) & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{295b3b6} & feat(cashier): port multi-method payments step in work order checkout (US38) & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{336771e} & feat(auth): port password recovery and reset with emailed token link (US05) & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{17ce509} & feat(auth): port secure sign-out, temp cleanup and device pending banner (US04) & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{adf7482} & feat(diagnostics): keep pit telemetry per technician and flush pending readings before sync (US19) & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{bbf9272} & docs(parity): flag the audit sections superseded by sprint 3. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{e565bce} & docs(roadmap): record sprint 3 presentation for US18, US28, US29, US30 and US40. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{97ba40f} & test(sprint3): add end-to-end tests for US18, US28, US29, US30 and US40. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{f2c4625} & test(diagnostics): cover live telemetry view model and content. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{4730cb8} & feat(attendance): mention live telemetry in the OBD shortcut. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{85ad47a} & feat(diagnostics): inject live telemetry view model dependencies. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{77508bd} & feat(diagnostics): register live telemetry destination. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{fe02fc9} & feat(diagnostics): add live telemetry entry and pending chip to the hub. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{cdb2828} & feat(diagnostics): observe vehicle sync state in the hub view model. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{1b22c5f} & feat(diagnostics): add remote telemetry and sync state to the hub state. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{4c58159} & feat(navigation): add live telemetry route. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{10d188c} & feat(diagnostics): add live telemetry screen with freeze and alerts (US18). & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{9850e21} & feat(diagnostics): add live telemetry view model. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{2c3d076} & feat(diagnostics): add live telemetry UI state. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{ddd0101} & feat(i18n): add live telemetry strings (US18). & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{ad526bf} & feat(diagnostics): register latest telemetry use case. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{4482f98} & feat(diagnostics): add get latest telemetry use case. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{96cb6e0} & feat(diagnostics): read latest telemetry through the repository. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{f5fd47f} & feat(diagnostics): add latest telemetry endpoint. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{9a324b8} & feat(diagnostics): add latest telemetry DTO. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{ceeb838} & feat(navigation): open the task from suspension review pushes (US29). & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{9ab0a39} & feat(main): inject pending suspension lookup into the dashboard. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{3cbaca3} & feat(main): show suspension decisions on the dashboard. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{14796fa} & feat(main): load pending suspensions in the dashboard view model. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{708bba9} & feat(main): add pending suspensions to the dashboard state. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{f2b7cb3} & test(workorders): cover suspension review from order detail. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{06672e9} & feat(workorders): inject suspension and bay use cases into view models. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{f08bf65} & feat(workorders): wire suspension and bay actions into order detail. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{1610d01} & feat(workorders): handle suspensions and bay assignment in the order view model. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{4eccb47} & feat(workorders): add suspension review and bay assignment sheets. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{cfa0dfb} & feat(workorders): add suspension review and resume controls to task blocks. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{ea4b199} & feat(workorders): extend order detail state for suspensions and bay assignment. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{ff4ba02} & refactor(workorders): allow replacing tasks when copying order detail. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{defe73e} & feat(workorders): show suspension review chip in the order list. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{005a6df} & feat(workorders): load pending suspensions after refreshing orders. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{f837009} & feat(workorders): track orders with pending suspensions in the list state. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{d6d5289} & feat(workorders): find pending suspensions across active orders (US29). & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{847fc98} & feat(workorders): add pending suspension model. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{4122ce2} & test(bays): cover bay board view model and content. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{3d76f66} & feat(attendance): add bay board shortcut to the floor hub. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{f94397f} & feat(main): add bays entry to the modules sheet. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{1ec2ff1} & feat(navigation): set up bays presentation. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{0b11a32} & feat(bays): register bay board route and view model. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{b2a5a5e} & feat(navigation): add bays route. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{c7eded6} & feat(bays): add bay occupancy board screen (US40). & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{0b6ac36} & feat(bays): add bay detail and creation sheets. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{a6b3f64} & feat(bays): add bay board view model with visible-only polling. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{c415c5f} & feat(bays): add bay board UI state with status filters. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{541ba66} & feat(bays): add bay type and status labels. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{7b686d5} & feat(i18n): add bay board feedback strings (US40). & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{bcb5673} & feat(bays): register bay management use cases. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{13c3b33} & feat(bays): add release bay use case. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{3bb87ce} & feat(bays): add restore bay use case. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{68aa91d} & feat(bays): add set bay maintenance use case. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{58da4a5} & feat(bays): add create work bay use case. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{9c7613a} & feat(bays): support bay management operations in the repository. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{67ccb68} & feat(bays): add invalid bay input exception. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{49ed5b7} & feat(bays): add create, maintenance, restore and release endpoints. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{8d23873} & feat(bays): add create and maintenance request DTOs. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{f0725d4} & feat(tasks): wire sprint 3 sheets and controls into the task detail screen. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{c829ac9} & feat(tasks): handle completion, suspension and evidence in the task view model. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{a4a269f} & feat(tasks): add finish task button to the pit action dock (US30). & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{76c2c6f} & feat(tasks): add synced and queued evidence section (US28). & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{a39d961} & feat(tasks): add evidence capture sheet with camera and gallery (US28). & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{6050060} & feat(tasks): add completion and suspension bottom sheets (US29, US30). & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{e5d6b3c} & feat(tasks): add completion, suspension and evidence callbacks to task actions. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{889bb7f} & feat(tasks): extend task detail state with completion, suspension and evidence forms. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{ae67aea} & feat(i18n): add task completion and gallery picker strings (US28, US30). & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{c042a22} & Merge tag '0.12.0' into develop & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{006136c} & Merge branch 'release/\allowbreak 0.12.0' & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{6568f39} & Merge branch 'feature/\allowbreak sprint3-us36-us37-us41' into develop & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{4b842ce} & test(sprint3): add end-to-end tests for US36, US37, and US41 flows. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{b79c5a8} & feat(reports): port cash flow PDF open and share actions (US41). & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{f33809e} & feat(cashier): port SUNAT vouchers management and order invoicing step (US37). & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{5d030ff} & feat(workorders): port cascade liquidation breakdown and checkout fab (US36). & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{aa6973d} & Merge tag '0.11.0' into develop & Release 0.11.0 0.11.0 & 24/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{08b6452} & Merge branch 'release/\allowbreak 0.11.0' & - & 24/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{5ab6f7c} & Merge branch 'feature/\allowbreak presentation' into develop & - & 24/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{358fc0e} & feat(navigation): wire app navigation, root navigator, and main entrypoint. & Add navigation host, presentation setup, root navigator, and tests. & 24/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{542ce37} & feat(cashier): update voucher dao and cashier presentation. & Update voucher DAO generated code, cashier presentation, and tests. & 24/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{dfd60f0} & feat(reports): add reports presentation and tests. & Add reports presentation layer and widget tests. & 24/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{627c734} & feat(diagnostics): add obd management, predictive alerts, and presentation. & Add OBD protocol/\allowbreak management, predictive alerts, presentation, and tests. & 24/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{4925688} & feat(inventory): add supplier, purchase order, and batch management. & Add supplier, PO, and FIFO batch use cases, DTOs, presentation, and tests. & 24/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{d223b38} & feat(tasks): add task reopen flow and presentation. & Add reopen task use case, presentation, and parity tests. & 24/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{b7951c2} & feat(workorders): add service catalog management and presentation. & Add service CRUD use cases, membership API, presentation, and parity tests. & 24/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{dc69789} & feat(reception): add appointment management, customer updates, and presentation. & Add appointment lifecycle use cases, DTOs, presentation, and parity tests. & 24/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{0f4bfd6} & feat(main): update push history, sync now, and main shell. & Add push notification use cases, sync now, main presentation, and tests. & 24/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{83f16f9} & feat(attendance): update clock-in flow, geofence, and presentation. & Update attendance use cases, domain models, presentation, probe, and tests. & 24/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{0e08abe} & feat(auth): update auth validation, notification gateway, and presentation. & Update auth domain/\allowbreak infrastructure, presentation layer, and tests. & 24/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{288e954} & feat(i18n): update spanish localization strings. & Update app\_es.arb and generated localization files. & 24/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{1a09edf} & feat(core): update database schema, sync engine, notifications, and design system. & Update Drift schema/\allowbreak migrations, sync processor, push inbox/\allowbreak router, and core tests. & 24/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{3414959} & docs: update architecture, roadmap, and offline sync documentation. & Update mobile integration, architecture, offline sync, and roadmap docs. & 24/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{e2d922d} & build(deps): update pubspec dependencies and assets. & Update package dependencies, lockfile, and application assets. & 24/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{e4209b4} & Merge branch 'release/\allowbreak 0.10.0' & - & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{3f57db3} & Merge tag '0.10.0' into develop & Release 0.10.0 0.10.0 & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{27fb33c} & chore(release): bump version to 0.10.0. & - & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{480d869} & Merge branch 'feature/\allowbreak support' into develop & - & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{3440eb5} & docs(support): mark step 9 complete and document cashier offline sync rules. & Update offline sync policies regarding cashier and mark Step 9 as completed in the master implementation roadmap. * Modified: docs/\allowbreak 06-offline-sync.md with vo... & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{7497dcf} & test(support): add unit and integration test suites for step 9. & Add comprehensive test coverage for all support domains, repositories, Drift DAOs, use cases, and DI wiring. * Added: 25+ unit and integration test suites co... & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{cb6dc03} & feat(core): wire support dependencies and add integration smoke probe. & Register all step 9 support module dependencies into the service locator and provide an executable integration smoke probe. * Modified: lib/\allowbreak core/\allowbreak di/\allowbreak dependenc... & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{f946269} & feat(team): add branch daily attendance and justification workflows. & Implement branch-wide attendance inspection and justification review workflows for team management. * Added: TeamAttendance, CollaboratorAttendance and justi... & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{9d50ac1} & feat(reports): add cash flow summary and fleet health pdf export. & Add financial cash flow summary parsing and PDF export capabilities for cash flow reports and diagnostics fleet health. * Added: CashFlow domain models and m... & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{473c473} & feat(cashier): add vouchers, payments, series and vehicle delivery. & Implement cashier domain capabilities including SUNAT series configuration, voucher drafting with line taxes, payment registration, and work order handover/\allowbreak e... & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{a90eb93} & feat(bays): add bay board, polling, assignment and mechanic transfer. & Implement work bay monitoring board with auto-refresh polling, bay reassignment, and mechanic reallocation across active bays. * Added: BayBoard and WorkBay... & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{472c3b4} & build(deps): add fake\_async dev dependency and expand sync mock server. & Add fake\_async dependency for microtask timer testing and expand the mock sync server to support invoicing, vouchers, payment transactions, series configurat... & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{5ff700b} & Merge tag '0.9.0' into develop & Release 0.9.0 0.9.0 & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{b25bd65} & Merge branch 'release/\allowbreak 0.9.0' & - & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{ba9a545} & chore(release): bump version to 0.9.0. & - & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{5225c84} & Merge branch 'feature/\allowbreak diagnostics' into develop & - & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{2fbe6a5} & docs(diagnostics): mark step 8 done with verification notes. & - & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{306fe7d} & test(diagnostics): add emulator probe with simulated ecu. & - & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{554feab} & feat(diagnostics): add use cases and dependency wiring. & - & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{8594a89} & feat(diagnostics): add telemetry, fault and report data layer. & - & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{8899f5b} & feat(diagnostics): add spp and ble transports with native bridge. & - & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{5ade8c5} & feat(diagnostics): add elm327 link and live diagnostic session. & - & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{972e7b8} & feat(diagnostics): add obd domain models, parser and contracts. & - & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{074912d} & Merge tag '0.8.0' into develop & Release 0.8.0 0.8.0 & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{d66d294} & Merge branch 'release/\allowbreak 0.8.0' & - & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{3408f1a} & chore(release): bump version to 0.8.0. & - & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{51a6222} & Merge branch 'feature/\allowbreak inventory' into develop & - & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{209f43c} & docs(inventory): document cache freshness rules and mark roadmap progress. & - update traceability with inventory and purchase orders endpoints. - document inventory TTL cache policies and offline behavior in offline sync docs. - mark... & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{c6309e7} & test(inventory): add unit tests, mock server endpoints, and device probe. & - add unit test suites for inventory use cases, DAOs, and repository caching. - implement catalog search, batch listing, stock alerts, valuation, and purchas... & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{2b8df4a} & feat(core): register inventory dependencies module. & - wire setupInventoryDependencies into global setupDependencies locator. - expose InventoryRepository, use cases, and InventoryApi to the DI container. & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{8556d5f} & feat(inventory): implement catalog, stock observation, and batch tracking. & - define Part, Batch, PurchaseOrder, and stock alert domain models and validation rules. - implement application use cases for catalog search, stock alerts,... & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{c010729} & feat(core): add part and batch daos to app database. & - register PartDao and BatchDao in Drift AppDatabase schema. - regenerate Drift database classes for local inventory caching. - remove redundant InventoryApi... & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{be23916} & Merge tag '0.7.0' into develop & Release 0.7.0 0.7.0 & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{cd0bc9f} & Merge branch 'release/\allowbreak 0.7.0' & - & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{16179c0} & chore(release): bump version to 0.7.0. & - & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{0c52da2} & Merge branch 'feature/\allowbreak reception-workorders' into develop & - & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{c62233d} & test(tasks): add missing session guard test for refreshMyTasks. & - verify that refreshMyTasks throws StateError and aborts network queries when session is empty. & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{01e9b9f} & docs(reception,workorders): document offline sync contracts and mark roadmap progress. & - update docs/\allowbreak 06-offline-sync.md with reception cache policies, work order sync operations, and conflict resolution rules. - mark Paso 4 (Recepción) and Paso... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{72ee70e} & test(reception,workorders): add unit test suites and integration mock probe. & - add comprehensive unit tests for reception use cases, repository caching, and Drift persistence. - add unit tests for work order transitions, proposal sync... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{318f7e9} & feat(core): register reception and workorders dependency injection modules. & - connect setupReceptionDependencies() and setupWorkOrdersDependencies() within global setupDependencies(). - register repository contracts, use cases, and r... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{b11bb64} & feat(workorders): implement order lifecycle, quotation, and offline sync processor. & - define WorkOrder, Proposal, and WorkOrderAudit domain models with validation rules. - implement use cases for opening, updating, starting, cancelling, comp... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{8493c4d} & feat(reception): implement customer, vehicle, and appointment management. & - define domain models, validation rules, and use cases for customer registration (individual/\allowbreak company), vehicle management, and appointment handling. - build... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{1773d0f} & refactor(tasks): extract work order task mappers and integrate shared money parsing. & - extract WorkOrderTaskMapper from TaskRepositoryImpl to allow reuse across tasks and workorders features. - replace local \_toMoney parsing logic with Money.... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{5caf3a2} & feat(core): add drift tables for reception and work orders with employee branch queries. & - add Money.orNull helper for parsing nullable monetary values cleanly without exceptions. - expand EmployeeProfileDto with membership, title, and status fie... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{965277f} & Merge tag '0.6.1' into develop & Release 0.6.1 0.6.1 & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{c761a61} & Merge branch 'release/\allowbreak 0.6.1' & - & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{e75d335} & chore(release): bump version to 0.6.1. & - & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{5b0ebb0} & Merge branch 'feature/\allowbreak tasks-closure' into develop & - & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{6909ad2} & docs(tasks): document probe validation findings and precision rules. & - record Decimal precision requirements for financial and quantity domain models. - update roadmap and sync architecture with integration probe findings and... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{5c392fc} & test(tasks): update unit tests for decimal inputs and add mock server probe. & - update use case, domain, and repository unit tests with Decimal instances. - update tasks test environment and assertions. - extend sync mock server with t... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{130c5e8} & fix(tasks): resolve absolute evidence paths and update dtos with decimal mapping. & - resolve local evidence photos to absolute paths in TaskRepositoryImpl so thumbnails persist correctly across restarts. - parse decimal fields across WorkBa... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{e775593} & refactor(tasks): use decimal precision for labor hours, quantities, and pricing. & - switch LaborTime, PartOption, TaskProduct, and validation rules to Decimal to prevent floating-point inaccuracies. - update use cases (suggest\_labor\_hours,... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{593e969} & refactor(core): add decimal parser, stream combiner, and session timer cleanup. & - introduce JsonDecimal helper to convert incoming integer, double, or string values cleanly to Decimal without floating-point inaccuracies. - introduce comb... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{8fa3a0c} & Merge tag '0.6.0' into develop & Release 0.6.0 0.6.0 & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{f2025fb} & Merge branch 'release/\allowbreak 0.6.0' & - & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{5f14b2e} & chore(release): bump version to 0.6.0. & - & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{69e1cc4} & Merge branch 'feature/\allowbreak tasks' into develop & - & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{2046308} & docs(tasks): mark step 5 completed in roadmap. & Update development roadmap marking tasks feature as implemented. - Document Step 5 completion with 18 use cases, DAOs, APIs, and sync handler. - Note Clean A... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{54e415d} & test(tasks): add architecture, domain, use case, and dao test suites. & Add unit, integration, and architecture tests for tasks feature. - Add architecture test verifying DDD boundary constraints. - Add domain tests for labor tim... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{a76ff19} & feat(tasks): implement repository, apis, evidence sync, and di. & Add repository implementation, APIs, DTOs, offline sync handler, and DI. - Add TaskRepositoryImpl with bay and vehicle cache enrichment. - Add TaskApi, Inven... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{286567c} & feat(tasks): implement domain models, validations, and use cases. & Add domain entities, value objects, and application use cases for tasks. - Add Task, TaskDetail, TaskProduct, TaskEvidence, and PendingEvidence models. - Add... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{b60fed8} & feat(db): register task, vehicle, and bay daos with drift tables. & Add Drift DAOs and query extensions for tasks, vehicles, and work bays. - Add TaskDao with weighted status ordering and TaskWithRefs joins. - Add VehicleDao... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{3d293db} & Merge tag '0.5.0' into develop & Release 0.5.0 0.5.0 & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{f64c2d4} & Merge branch 'release/\allowbreak 0.5.0' & - & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{1350b72} & chore(release): bump version to 0.5.0. & - & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{cf06abf} & Merge branch 'feature/\allowbreak attendance' into develop & - & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{33626a2} & test(attendance): add unit and regression tests for attendance. & Add unit tests covering attendance domain rules, application use cases, Drift DAOs, repository cache/\allowbreak remote logic, and sync handlers. Added: - test/\allowbreak features/\allowbreak ... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{fd5a2c4} & docs(attendance): document android location manager and consent dialog. & Document Android-specific geolocator location settings to bypass Google Location Accuracy consent prompts. Modified: - docs/\allowbreak 04-mobile-integration.md: documen... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{3038a43} & feat(app): register attendance dependencies and add test probe. & Register setupAttendanceDependencies into GetIt service locator and add manual attendance probe. Added: - integration\_probe/\allowbreak attendance\_probe\_main.dart: probe... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{f856340} & feat(attendance): implement domain models, use cases, and repositories. & Add complete domain, application, and infrastructure layers for attendance tracking and shift management. Added: - lib/\allowbreak features/\allowbreak attendance/\allowbreak domain/\allowbreak : models fo... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{999e43f} & feat(core): extend database tables, sync processor, and business time. & Add core database tables and DAOs for attendance, branches, and shifts, handle cascade sync failures, and add date arithmetic helpers. Added: - lib/\allowbreak core/\allowbreak data... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{3e889ea} & docs(attendance): update traceability, sync rules, and roadmap. & Update project documentation reflecting the completion of step 4 (attendance and shifts). Modified: - docs/\allowbreak 03-traceability.md: document attendance endpoints... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{31b5791} & Merge tag '0.4.0' into develop & Release 0.4.0 0.4.0 & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{e9fa68c} & Merge branch 'release/\allowbreak 0.4.0' & - & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{79491fd} & chore(release): bump version to 0.4.0. & - & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{68a3cf6} & Merge branch 'feature/\allowbreak main' into develop & - & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{acce6a9} & test(main): add unit tests for sync queue and main feature use cases. & Add unit tests covering session stream emission, pending operations cascade discard and retry, local change notifier sync listener, and main feature reposito... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{68f0334} & feat(app): register main feature dependencies in service locator. & Register setupMainDependencies into the global service locator setup. Modified: - lib/\allowbreak core/\allowbreak di/\allowbreak dependency\_injection.dart: wire main repositories and use cases. & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{c90a252} & feat(main): implement domain models, use cases, and repositories. & Add domain entities, repository contracts, and use cases for the main shell and background sync queue state. Added: - lib/\allowbreak features/\allowbreak main/\allowbreak domain/\allowbreak : pending oper... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{99bc721} & feat(core): enhance queue operations, push domain, and session stream. & Add core support for session observation streams, cascade operation discarding, and push destination domain abstraction. Added: - lib/\allowbreak core/\allowbreak domain/\allowbreak push\_destin... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{2b5c69a} & docs(main): update architecture, sync rules, and roadmap for main. & Update project documentation reflecting the completion of step 3 (main shell and background state). Modified: - docs/\allowbreak 05-flutter-architecture.md: clarify navi... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{544e824} & Merge tag '0.3.0' into develop & Release 0.3.0 0.3.0 & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{532c598} & Merge branch 'release/\allowbreak 0.3.0' & - & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{817d7f7} & chore(release): bump version to 0.3.0. & - & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{e500672} & Merge branch 'feature/\allowbreak auth' into develop & - & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{b857a48} & test(auth): add unit test coverage for auth and session workflows. & Add unit tests covering authentication repositories, Google Sign-In use case, input validation, notification requester, session management updates, and token... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{6a604f4} & feat(app): wire auth dependencies, update app root, and add l10n. & Wire the authentication dependencies into the service locator, handle branch selection state in AppRoot, and introduce localization keys for session states.... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{185e345} & feat(auth): implement domain models, use cases, and repositories. & Add complete domain, application, and infrastructure layers for user authentication, Google Sign-In, password recovery, email verification, branch selection,... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{9828251} & feat(core): extend session, token refresher, and branch remote api. & Extend core infrastructure to support branch assignment within the active session, reactive token refreshing, and branch remote DTOs/\allowbreak APIs. Added: - lib/\allowbreak core/\allowbreak ... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{7062ed3} & docs(auth): update traceability, architecture, and roadmap for auth. & Update project documentation reflecting the completion of the authentication and session management layer (Step 2 of roadmap). Modified: - docs/\allowbreak 03-traceabili... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{109876e} & Merge tag '0.2.0' into develop & Release 0.2.0 0.2.0 & 05/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{31c24f2} & Merge branch 'release/\allowbreak 0.2.0' & - & 05/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{8e9058d} & chore(release): bump version to 0.2.0. & Prepare 0.2.0 release with Step 1 core capabilities. & 05/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{0886c97} & Merge branch 'feature/\allowbreak core' into develop & - & 05/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{65f50ab} & test(core): add test coverage for session, database, sync, media, and navigation. & Add unit, integration, and concurrency tests covering the full Step 1 core surface, including two-connection SQLite sync, token refresh races, pending operat... & 05/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{00869d4} & feat(app): configure dependency injection, app root navigator, and bootstrap. & Wire get\_it service locator with all core singletons and workers, implement AppRoot multi-engine session observer, and expand Spanish localization strings. A... & 05/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{8511c76} & feat(network): implement authenticated client, background sync, and media services. & Implement resilient HTTP networking with automatic JWT refresh synchronization, Workmanager background sync workers, photo compression with Supabase storage... & 05/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{4329b11} & feat(db): establish drift database schema, session storage, and feature tables. & Set up Drift SQLite database with schema v1, multi-isolate SQLite connection, cross-isolate advisory locking, session credentials store, and 19 feature table... & 05/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{212befb} & feat(domain): define session, permissions, money, and error primitives. & Implement core domain entities and value objects free from platform and UI dependencies, including Session with permission/\allowbreak plan checks, Money representation,... & 05/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{77d911c} & docs(core): update architecture, offline sync, and roadmap progress. & Refine core architectural guidelines, multi-isolate synchronization notes, and mark step 1 (Núcleo core) completed on Android emulator in roadmap. Modified:... & 05/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{0c2b911} & Merge tag '0.1.0' into develop & Release 0.1.0 0.1.0 & 05/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{9bf589d} & Merge branch 'release/\allowbreak 0.1.0' & - & 05/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{0e5a320} & Merge branch 'feature/\allowbreak foundations' into develop & - & 05/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{2e0a155} & feat(app): implement bootstrap runner, config parser, and localization. & Implement application entrypoint parsing environment dart-define values, configuring Spanish localization delegates, and rendering the foundation bootstrap s... & 05/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{996e1a3} & build(platform): set up android and ios manifests, bundle ids, and launcher assets. & Align native Android and iOS configurations with the Atelier organization identity, target API levels, permissions, custom fonts, and app launcher icons. Add... & 05/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{bbdcaf1} & build(core): configure dependencies, build runner, and environment profiles. & Define production and dev dependencies according to the course architecture guidelines, configure drift code generator settings, strict lint analysis, and gi... & 05/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{c89514f} & docs(architecture): add project guides, api specs, and agent instructions. & Establish authoritative documentation, requirements traceability, API contracts, and agent guidelines for cross-platform Flutter development. Added: - docs/\allowbreak ... & 05/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{2d8442d} & initial commit & - & 05/\allowbreak 11/\allowbreak 2026 \\ \hline
\end{longtable}
\endgroup

*Nota.* Registro cronológico de commits de implementación para la aplicación multiplataforma en atelier\_mobile\_crossplatform.

\newpage

#### 4.2.3.5. Testing Suite Evidence for Sprint Review

Para asegurar la confiabilidad de la aplicación multiplataforma en Flutter y Dart, el equipo ejecutó una estrategia de pruebas automatizadas basada en `flutter_test`, `mocktail`, `fake_async` y bases de datos Drift en memoria sobre SQLite. Esta cobertura verifica la lógica de dominio, los casos de uso, los manejadores de sincronización fuera de línea, los modelos de vista y la interacción de widgets en pantalla.

El código fuente de la suite de pruebas automatizadas se encuentra alojado en GitHub:

- **Repositorio de Pruebas Automatizadas (Flutter):** [https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier_mobile_crossplatform](https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier_mobile_crossplatform) en el directorio `test/`.

La suite integral reúne ciento dieciocho archivos de prueba y un total de mil ciento ocho casos automatizados distribuidos por módulo funcional:

- **Núcleo, Red y Persistencia Drift (23 archivos, 180 pruebas):** Verifican el cliente HTTP, el almacenamiento seguro de credenciales, los esquemas y DAOs de Drift sobre SQLite, la cola de sincronización fuera de línea, la compresión multimedia y la gestión de sesiones.
- **Diagnóstico Electrónico y Telemetría OBD-II (18 archivos, 131 pruebas):** Validan el enlace Bluetooth Low Energy con `universal_ble`, el intérprete de comandos ELM327, la decodificación de códigos DTC, el monitoreo de parámetros en vivo, el simulador de ECU e informes periciales con inteligencia artificial.
- **Ejecución de Faenas en Bahía (11 archivos, 129 pruebas):** Comprueban las reglas de dominio de tareas, el cronómetro de labor efectiva, las pausas operativas, la imputación de repuestos y la persistencia local en `TaskDao`.
- **Inventario y Valoración FIFO (10 archivos, 107 pruebas):** Evalúan el catálogo de repuestos, el disparo de alertas de stock mínimo, la recepción de compras y el descargo contable por lotes cronológicos FIFO.
- **Asistencia Satelital y Turnos (9 archivos, 97 pruebas):** Validan el cálculo geodésico Haversine, la marcación de ingreso y salida, la consulta semanal de turnos y los descargos por tardanza.
- **Caja, Liquidación y Facturación SUNAT (9 archivos, 80 pruebas):** Verifican la liquidación económica en cascada, la emisión de comprobantes electrónicos UBL 2.1, las series fiscales y la recaudación multimedio.
- **Navegación Principal y Centro de Notificaciones (8 archivos, 83 pruebas):** Comprueban la navegación condicionada por permisos de rol, la bandeja de notificaciones y la vista de cola pendiente de sincronización.
- **Recepción Pericial e Inspección en Patio (5 archivos, 78 pruebas):** Evalúan la búsqueda reactiva por placa o documento, el alta de clientes presenciales y la vinculación vehicular.
- **Autenticación y Seguridad de Acceso (7 archivos, 74 pruebas):** Validan el inicio de sesión, la renovación de tokens JWT, el cierre seguro y el restablecimiento de credenciales.
- **Órdenes de Trabajo y Proformas (8 archivos, 68 pruebas):** Verifican la apertura de órdenes, la descarga de proformas en PDF, las evidencias fotográficas y la revisión de suspensiones.
- **Reportes Operativos en PDF (3 archivos, 22 pruebas):** Comprueban la generación y exportación del flujo de caja y los informes periciales de salud vehicular.
- **Gestión de Bahías, Equipos y Soporte (4 archivos, 33 pruebas):** Validan el tablero de bahías en tiempo real, la asistencia diaria de equipo y las utilidades de soporte.
- **Suites Integradas de Extremo a Extremo (3 archivos, 26 pruebas):** Verifican de forma integrada los flujos completos del Sprint 3 para `US18`, `US28`, `US29`, `US30`, `US36`, `US37`, `US40` y `US41`.

**Especificación de Pruebas de Aceptación BDD (Gherkin Feature Files)**

Los escenarios de aceptación en sintaxis Gherkin formalizan el comportamiento esperado para las capacidades críticas del tercer ciclo:

```gherkin
Feature: Enlace inalambrico OBD-II y decodificacion de codigos DTC (US16 y US17)
  Como tecnico mecanico en bahia
  Quiero enlazar un escaner OBD-II por Bluetooth Low Energy y leer los codigos de falla
  Para diagnosticar averias electronicas del vehiculo desde la aplicacion Flutter

  Scenario: Vinculacion exitosa y lectura de codigos DTC
    Given que el dispositivo movil tiene el Bluetooth habilitado
    And un adaptador ELM327 se encuentra dentro del rango de cobertura
    When el mecanico selecciona el escaner y solicita la lectura de diagnostico
    Then la aplicacion establece la sesion BLE mediante universal_ble
    And decodifica los codigos DTC reportados por la unidad de control electronico
    And almacena la sesion de diagnostico en Drift y la sincroniza con el backend
```

```gherkin
Feature: Generacion de informe pericial predictivo con IA en PDF (US21)
  Como tecnico mecanico o jefe de taller
  Quiero generar un informe pericial predictivo a partir de la telemetria capturada
  Para entregar al cliente un diagnostico tecnico respaldado en formato PDF

  Scenario: Generacion y exportacion de informe pericial en PDF
    Given una sesion de diagnostico OBD-II completada con codigos DTC y parametros PID
    When el usuario solicita generar el informe pericial predictivo
    Then el backend procesa la telemetria mediante el motor de inteligencia artificial
    And la aplicacion descarga el documento PDF resultante y habilita su visualizacion y envio
```

```gherkin
Feature: Emision de comprobantes tributarios electronicos UBL 2.1 ante SUNAT (US37)
  Como administrador o cajero del taller
  Quiero emitir boletas o facturas electronicas al liquidar una orden de trabajo
  Para cumplir con la normativa tributaria vigente de la SUNAT

  Scenario: Emision exitosa de factura electronica UBL 2.1
    Given una orden de trabajo liquidada con datos fiscales del cliente validados
    And una serie de facturacion electronica activa en la sede
    When el cajero confirma la emision del comprobante electronico
    Then el sistema envia el documento UBL 2.1 al Proveedor de Servicios Electronicos
    And registra el comprobante aceptado con su codigo hash y habilita el pase de salida
```

```gherkin
Feature: Almacenamiento local resiliente y sincronizacion diferida en fosa (US19)
  Como tecnico mecanico trabajando en fosa sin cobertura de red
  Quiero registrar lecturas y avances de faena aunque no exista conexion a internet
  Para continuar operando sin perdida de datos hasta recuperar conectividad

  Scenario: Encolamiento en Drift y sincronizacion automatica al recuperar red
    Given que el dispositivo movil se encuentra sin conexion a internet
    When el mecanico registra una lectura de diagnostico o evidencia tecnica
    Then la aplicacion persiste la operacion en la cola local de Drift sobre SQLite
    And al detectar reconexion mediante connectivity_plus WorkManager despacha la cola pendiente
```

**Registro de Commits de Pruebas Automatizadas**

La @tbl:testing-evidence-commits-flutter presenta los 17 commits dedicados al diseño, implementación y verificación de la suite de pruebas automatizadas en el repositorio multiplataforma.

\begingroup
\scriptsize
\setlength{\tabcolsep}{2.5pt}
\renewcommand{\arraystretch}{1.15}
\begin{longtable}{| >{\raggedright\arraybackslash}p{2.6cm} | >{\centering\arraybackslash}p{1.4cm} | >{\centering\arraybackslash}p{1.6cm} | >{\raggedright\arraybackslash}p{4.4cm} | >{\raggedright\arraybackslash}p{3.4cm} | >{\centering\arraybackslash}p{1.8cm} |}
\caption{Registro de Commits de Pruebas Automatizadas (Sprint 3)} \label{tbl:testing-evidence-commits-flutter} \\
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
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{07b727c} & test(sprint3): add tests for US04, US05, US19, US38 and US39 flows & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{97ba40f} & test(sprint3): add end-to-end tests for US18, US28, US29, US30 and US40. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{f2c4625} & test(diagnostics): cover live telemetry view model and content. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{f2b7cb3} & test(workorders): cover suspension review from order detail. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{4122ce2} & test(bays): cover bay board view model and content. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{4b842ce} & test(sprint3): add end-to-end tests for US36, US37, and US41 flows. & - & 25/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{7497dcf} & test(support): add unit and integration test suites for step 9. & Add comprehensive test coverage for all support domains, repositories, Drift DAOs, use cases, and DI wiring. * Added: 25+ unit and integration test suites co... & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{306fe7d} & test(diagnostics): add emulator probe with simulated ecu. & - & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{c6309e7} & test(inventory): add unit tests, mock server endpoints, and device probe. & - add unit test suites for inventory use cases, DAOs, and repository caching. - implement catalog search, batch listing, stock alerts, valuation, and purchas... & 07/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{c62233d} & test(tasks): add missing session guard test for refreshMyTasks. & - verify that refreshMyTasks throws StateError and aborts network queries when session is empty. & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{72ee70e} & test(reception,workorders): add unit test suites and integration mock probe. & - add comprehensive unit tests for reception use cases, repository caching, and Drift persistence. - add unit tests for work order transitions, proposal sync... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{5c392fc} & test(tasks): update unit tests for decimal inputs and add mock server probe. & - update use case, domain, and repository unit tests with Decimal instances. - update tasks test environment and assertions. - extend sync mock server with t... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{54e415d} & test(tasks): add architecture, domain, use case, and dao test suites. & Add unit, integration, and architecture tests for tasks feature. - Add architecture test verifying DDD boundary constraints. - Add domain tests for labor tim... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{33626a2} & test(attendance): add unit and regression tests for attendance. & Add unit tests covering attendance domain rules, application use cases, Drift DAOs, repository cache/\allowbreak remote logic, and sync handlers. Added: - test/\allowbreak features/\allowbreak ... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{acce6a9} & test(main): add unit tests for sync queue and main feature use cases. & Add unit tests covering session stream emission, pending operations cascade discard and retry, local change notifier sync listener, and main feature reposito... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{b857a48} & test(auth): add unit test coverage for auth and session workflows. & Add unit tests covering authentication repositories, Google Sign-In use case, input validation, notification requester, session management updates, and token... & 06/\allowbreak 11/\allowbreak 2026 \\ \hline
andeva-upc/\allowbreak atelier\_mobile\_crossplatform & main & \texttt{65f50ab} & test(core): add test coverage for session, database, sync, media, and navigation. & Add unit, integration, and concurrency tests covering the full Step 1 core surface, including two-connection SQLite sync, token refresh races, pending operat... & 05/\allowbreak 11/\allowbreak 2026 \\ \hline
\end{longtable}
\endgroup

*Nota.* Registro cronológico de commits etiquetados para la suite de pruebas automatizadas en el repositorio atelier\_mobile\_crossplatform.

\newpage

#### 4.2.3.6. Execution Evidence for Sprint Review

Durante el tercer ciclo constructivo, el equipo completó la puesta en marcha y verificación funcional de la aplicación móvil multiplataforma Atelier Workshop Mobile desarrollada en Flutter y Dart. El binario compilado se distribuyó mediante Firebase App Distribution para validar en dispositivos físicos Android la fluidez de las pantallas, la persistencia local con Drift sobre SQLite y el enlace con los servicios en producción.

La validación operativa cubrió ambos segmentos de negocio definidos para el taller:

En el segmento de gestión y administración, representado por Pedro Suárez en Taller Suárez Automotriz, se comprobó la operatividad del panel principal en Flutter. La vista concentra las métricas diarias de vehículos en bahía, listos y en turno, la sucursal activa, los accesos directos para consultar placas y registrar ingresos presenciales en patio, el conteo de órdenes activas y la disponibilidad de bahías de trabajo con navegación inferior tipo cápsula, tal como se muestra en la @fig:execution-evidence-flutter-management.

![Vista principal del panel administrativo en Flutter para propietarios y gestores de taller](report/assets/deploy/result-deploy-mobile-crossplatform-2.jpeg){#fig:execution-evidence-flutter-management width=32%}

*Nota.* Captura de pantalla de la aplicación multiplataforma Flutter en dispositivo físico evidenciando el panel administrativo con métricas de patio y accesos de recepción.

En el segmento operativo de taller, representado por Andrés Vílchez, se verificó la interfaz de trabajo técnico en modo oscuro para mecánicos de bahía y foso. La pantalla exhibe las tareas pendientes y en curso, el contador de escáneres OBD activos, el estado de la jornada laboral y los accesos de piso con el módulo de diagnóstico OBD-II para telemetría en vivo, lectura de códigos DTC e informe asistido por inteligencia artificial, según se ilustra en la @fig:execution-evidence-flutter-operative.

![Vista principal del panel operativo en Flutter para técnicos mecánicos en foso y bahía](report/assets/deploy/result-deploy-mobile-crossplatform-3.jpeg){#fig:execution-evidence-flutter-operative width=32%}

*Nota.* Captura de pantalla de la aplicación multiplataforma Flutter en dispositivo físico mostrando el panel técnico con estado de jornada, contadores OBD y accesos de piso.

Para evidenciar la navegación completa entre los distintos módulos en ambos perfiles junto con la distribución en Firebase, el equipo grabó una demostración audiovisual del tercer sprint.

- **Enlace al Video Demostrativo del Sprint 3:** [Demostración Audiovisual del Sprint 3 (Microsoft Stream / OneDrive)](https://upcedupe-my.sharepoint.com/:v:/g/personal/u20241e275_upc_edu_pe/IQAp-Q81TQZZQ5fVqF96Qy72AcnS0Sy59DsNA8vx1-a4hO4?nav=eyJyZWZlcnJhbEluZm8iOnsicmVmZXJyYWxBcHAiOiJPbmVEcml2ZUZvckJ1c2luZXNzIiwicmVmZXJyYWxBcHBQbGF0Zm9ybSI6IldlYiIsInJlZmVycmFsTW9kZSI6InZpZXciLCJyZWZlcnJhbFZpZXciOiJNeUZpbGVzTGlua0NvcHkifX0&e=nVwqeY)

\newpage

#### 4.2.3.7. Services Documentation Evidence for Sprint Review

Durante el tercer ciclo constructivo, la documentación técnica de servicios web y la especificación de contratos de interfaz bajo OpenAPI 3.1 no experimentaron modificaciones ni adiciones, debido a que la totalidad de los servicios web del backend de la plataforma fueron implementados, documentados y desplegados durante el Sprint 1.

El esfuerzo técnico del equipo en este ciclo se enfocó íntegramente en el desarrollo, pruebas automatizadas, persistencia local con Drift y despliegue de la aplicación móvil multiplataforma en Flutter. Para la consulta de los veinticuatro endpoints RESTful canónicos, esquemas DTO de intercambio y la consola interactiva Swagger UI en producción, referirse a la sección 4.2.1.7 del primer ciclo constructivo.

\newpage

#### 4.2.3.8. Software Deployment Evidence for Sprint Review

Durante el tercer ciclo constructivo, el equipo empaquetó y distribuyó la aplicación móvil multiplataforma Atelier Workshop Mobile compilada desde Flutter hacia Firebase App Distribution. Este flujo permitió generar el artefacto ejecutable de producción para Android y habilitar su descarga controlada por parte de los evaluadores.

**Paso 1: Consolidación y etiquetado del repositorio multiplataforma en GitHub.** Se integraron los módulos finales, activos y pruebas automatizadas en la rama principal `main` del repositorio `atelier_mobile_crossplatform`, publicando la etiqueta correspondiente al release 0.15.0 con un total de doscientos treinta y cinco commits acumulados en la rama, tal como se aprecia en la @fig:deploy-flutter-step-1.

![Consolidación de la rama principal del repositorio atelier\_mobile\_crossplatform en GitHub](report/assets/deploy/deploy-app-crossplatform-1.png){#fig:deploy-flutter-step-1 width=75%}

*Nota.* Vista del repositorio oficial atelier\_mobile\_crossplatform en GitHub mostrando la rama principal, los cinco colaboradores y las dieciséis etiquetas publicadas.

**Paso 2: Compilación del paquete APK de producción en Flutter.** Desde la terminal del proyecto se ejecutó el comando `flutter build apk --release --dart-define-from-file=config/dev.json`, ejecutando la optimización de íconos vectoriales y la tarea Gradle `assembleRelease` hasta generar el binario `app-release.apk` de 88.7 megabytes, como se ilustra en la @fig:deploy-flutter-step-2.

![Compilación exitosa del binario APK de producción mediante Flutter CLI](report/assets/deploy/deploy-app-crossplatform-2.png){#fig:deploy-flutter-step-2 width=80%}

*Nota.* Salida de consola confirmando la generación del artefacto app-release.apk en modo release tras la compilación con Gradle.

**Paso 3: Carga de la compilación y registro de evaluadores en App Distribution.** En la consola de Firebase App Distribution se subió la compilación `0.10.0 (1)` el 27 de noviembre de 2026 a las 6:19:18 p.m. UTC-5 y se asignaron las direcciones institucionales `u20241e275@upc.edu.pe` y `pcsijmay@upc.edu.pe` como verificadores autorizados, según se muestra en la @fig:deploy-flutter-step-3.

![Carga del artefacto ejecutable y asignación de verificadores en Firebase App Distribution](report/assets/deploy/deploy-app-crossplatform-3.png){#fig:deploy-flutter-step-3 width=75%}

*Nota.* Consola de Firebase App Distribution exhibiendo la versión 0.10.0 (1) y los dos correos institucionales agregados para validación.

**Paso 4: Verificación de publicación activa en Firebase Console.** Se comprobó la disponibilidad del lanzamiento `0.10.0 (1)` en el panel de versiones distribuidas, registrando dos invitados y una invitación aceptada para iniciar las pruebas en dispositivo, tal como se observa en la @fig:deploy-flutter-step-4.

![Panel de control de la versión publicada en Firebase App Distribution](report/assets/deploy/deploy-app-crossplatform-4.png){#fig:deploy-flutter-step-4 width=80%}

*Nota.* Panel de versiones de Firebase App Distribution confirmando el estado activo de la compilación 0.10.0 (1) y las métricas de invitación.

**Paso 5: Notificación por correo electrónico para descarga de la compilación.** Los evaluadores recibieron la notificación oficial de Firebase App Distribution para la aplicación `Atelier` con identificador `com.andeva.atelier.mobile`, incluyendo el acceso directo `Download the latest build` y el enlace de instalación mediante Firebase App Tester, según se exhibe en la @fig:result-deploy-flutter-1.

![Notificación por correo electrónico recibida por los evaluadores para descargar la aplicación Flutter](report/assets/deploy/result-deploy-mobile-crossplatform-1.png){#fig:result-deploy-flutter-1 width=60%}

*Nota.* Correo electrónico remitido por Firebase App Distribution con el botón de descarga para la versión 0.10.0 (1).

\newpage

#### 4.2.3.9. Team Collaboration Insights during Sprint

Durante el tercer ciclo constructivo, el equipo mantuvo la dinámica de trabajo colaborativo bajo Git Flow sobre el repositorio oficial `atelier_mobile_crossplatform`, integrando las funcionalidades en ramas dedicadas con revisión previa antes de consolidar cada incremento en la rama principal `main`. El seguimiento de las métricas de contribución se realizó mediante GitHub Insights y el tablero del Sprint 3 en Jira Software.

**Analíticos de Colaboración en el Repositorio Multiplataforma Flutter**

La @fig:collab-insights-flutter-sprint-3 presenta el reporte de contribuciones por autor obtenido de GitHub Insights para el último mes de actividad del repositorio, comprendido entre el 24 de octubre y el 21 de noviembre de 2026, evidenciando la participación directa de los cinco integrantes del equipo.

![Analíticos de contribución y commits por autor en el repositorio de la aplicación multiplataforma Flutter](report/assets/sprint-3/commits-mobile-crossplatform-sprint-3.png){#fig:collab-insights-flutter-sprint-3 width=75%}

*Nota.* Gráfico de contribuciones semanales y detalle individual de commits en la rama principal del repositorio atelier\_mobile\_crossplatform obtenido de GitHub Insights.

La distribución de aportes reflejada en los analíticos guarda correspondencia con la matriz de liderazgo y colaboración asignada para este ciclo:

- **Joel Huamani Estefanero (`shouydev`):** Como líder de arquitectura y del módulo de diagnóstico OBD-II e inteligencia artificial, registró ciento siete commits con 187,854 líneas añadidas y 5,037 eliminadas. Implementó la estructura base en Flutter, la base de datos local con Drift sobre SQLite, las colas de sincronización fuera de línea, el enlace Bluetooth Low Energy con `universal_ble` para adaptadores ELM327 y la generación de informes periciales con inteligencia artificial.
- **Luis Daniel Granda Ibarra (`danieltyuyu`):** Como líder de telemetría en vivo y operaciones en fosa, aportó sesenta y ocho commits con 5,781 líneas añadidas y 102 eliminadas. Desarrolló el monitoreo dinámico de parámetros PID, el registro fotográfico pericial de desmontaje y montaje, las solicitudes de suspensión por pieza defectuosa, el cierre técnico con horas hombre y la supervisión en vivo de bahías.
- **Alvaro Rocha Cotrina (`alvarorc24`):** Como líder de seguridad móvil, pagos y sincronización Drift, sumó siete commits con 16,642 líneas añadidas y 127 eliminadas. Implementó el cierre de sesión seguro, el restablecimiento de acceso por token, la persistencia resiliente en fosa, la recaudación multimedio y el pase de salida vehicular.
- **Mauricio Alejandro Teran Zavala (`mau-tz`):** Como líder de inventario FIFO, series fiscales y reportes, registró seis commits con 5,548 líneas añadidas y 745 eliminadas. Desarrolló las alertas de reposición por stock mínimo, la conciliación de margen FIFO con precios de catálogo, la configuración de series SUNAT y la exportación de informes de salud vehicular en PDF.
- **Adiel Abdiaz Sanchez Santin (`xs4el`):** Como líder de facturación electrónica SUNAT y caja, aportó cuatro commits con 5,105 líneas añadidas y 58 eliminadas. Implementó la liquidación económica en cascada de órdenes de trabajo, la emisión de comprobantes electrónicos UBL 2.1 mediante Proveedor de Servicios Electrónicos y la exportación del flujo de caja en PDF.

Los analíticos confirman una participación efectiva de los cinco integrantes del equipo sobre el cliente multiplataforma en Flutter, cerrando el ciclo final del proyecto con trazabilidad completa entre los compromisos de Jira Software y el historial de versiones en GitHub.
