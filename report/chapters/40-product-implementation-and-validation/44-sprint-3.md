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

La @tbl:sprint-backlog-3 presenta la maqueta base del Sprint Backlog del Sprint 3 con las veintiuna historias de usuario y sus responsables asignados, lista para registrar el desglose de subtareas, estimaciones horarias y estados conforme avance el tablero en Jira Software.

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
US04 & Cierre de sesión seguro y revocación de credenciales en el dispositivo móvil &  &  &  &  & Rocha Cotrina, Alvaro &  \\
\hline
US05 & Restablecimiento de credenciales de acceso mediante token de verificación &  &  &  &  & Rocha Cotrina, Alvaro &  \\
\hline
US16 & Enlace inalámbrico y sincronización de escáner OBD-II en bahía &  &  &  &  & Huamani Estefanero, Joel &  \\
\hline
US17 & Extracción y decodificación de códigos de falla computarizados &  &  &  &  & Huamani Estefanero, Joel &  \\
\hline
US18 & Monitoreo dinámico de parámetros telemétricos en tiempo real &  &  &  &  & Granda Ibarra, Luis Daniel &  \\
\hline
US19 & Almacenamiento local resiliente y sincronización diferida en fosa &  &  &  &  & Rocha Cotrina, Alvaro &  \\
\hline
US20 & Borrado y verificación de restablecimiento de fallas en la computadora &  &  &  &  & Huamani Estefanero, Joel &  \\
\hline
US21 & Generación de informe pericial predictivo con inteligencia artificial y exportación en PDF &  &  &  &  & Huamani Estefanero, Joel &  \\
\hline
US28 & Registro fotográfico pericial de desmontaje y montaje de piezas en fosa &  &  &  &  & Granda Ibarra, Luis Daniel &  \\
\hline
US29 & Solicitud y validación administrativa de suspensión por pieza defectuosa indispensable &  &  &  &  & Granda Ibarra, Luis Daniel &  \\
\hline
US30 & Cierre técnico de tarea con cómputo de horas hombre efectivas &  &  &  &  & Granda Ibarra, Luis Daniel &  \\
\hline
US34 & Disparo y desactivación de alertas automáticas de reposición por stock mínimo &  &  &  &  & Teran Zavala, Mauricio Alejandro &  \\
\hline
US35 & Imputación automática de precios de venta de catálogo y conciliación de margen FIFO &  &  &  &  & Teran Zavala, Mauricio Alejandro &  \\
\hline
US36 & Liquidación económica automática en cascada de la orden de trabajo &  &  &  &  & Sanchez Santin, Adiel Abdiaz &  \\
\hline
US37 & Emisión de comprobantes tributarios electrónicos UBL 2.1 ante SUNAT vía PSE &  &  &  &  & Sanchez Santin, Adiel Abdiaz &  \\
\hline
US38 & Recaudación y amortización de pagos multi-medio en mostrador y patio &  &  &  &  & Rocha Cotrina, Alvaro &  \\
\hline
US39 & Transición a orden pagada, emisión de pase de salida vehicular y entrega en patio &  &  &  &  & Rocha Cotrina, Alvaro &  \\
\hline
US40 & Supervisión y reasignación de bahías de servicio en tiempo real &  &  &  &  & Granda Ibarra, Luis Daniel &  \\
\hline
US41 & Exportación de reporte de flujo de caja en PDF para auditoría contable externa &  &  &  &  & Sanchez Santin, Adiel Abdiaz &  \\
\hline
US42 & Configuración de información fiscal y series SUNAT con PSE administrado por la plataforma &  &  &  &  & Teran Zavala, Mauricio Alejandro &  \\
\hline
US43 & Descarga y remisión de informe pericial de salud vehicular en PDF para clientes y flotas &  &  &  &  & Teran Zavala, Mauricio Alejandro &  \\
\hline
\end{longtable}
\endgroup

*Nota.* Estructura base del Sprint Backlog del Sprint 3 con las veintiuna historias de usuario y sus responsables asignados.
