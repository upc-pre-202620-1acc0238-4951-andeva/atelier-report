## 4.2. Landing Page & Mobile Application Implementation

En esta sección se expone y evidencia el proceso formal de construcción, aseguramiento de la calidad, documentación técnica y despliegue continuo de los productos de software que integran el ecosistema Atelier. La solución articula tres componentes de valor complementarios: Landing Page, Backend y las aplicaciones móviles. Para asegurar un flujo de entrega predecible y disciplinado, el desarrollo se organiza en iteraciones consecutivas bajo el marco ágil Scrum, complementado con prácticas de ingeniería como integración continua, pruebas automatizadas deterministas y arquitectura limpia modular. Cada iteración documenta de manera exhaustiva sus eventos de planificación, diseño, evidencias de desarrollo y verificación de despliegue.

### 4.2.1. *Sprint 1*

El primer ciclo de desarrollo tiene como propósito estratégico sentar las bases tecnológicas y comerciales de la plataforma Atelier. Por un lado, se prioriza el despliegue del portal web comercial, concebido como el punto de contacto primario para captar dueños y administradores de talleres automotrices independientes mediante la presentación de la propuesta de valor y las opciones de suscripción. Por otro lado, se implementa la totalidad de los contratos y servicios RESTful centrales del backend a lo largo de los ocho Bounded Contexts, estableciendo los modelos de dominio, las invariantes de negocio y los esquemas de persistencia en PostgreSQL y TimescaleDB.

#### 4.2.1.1. Sprint Planning 1

La sesión de planificación del Sprint 1 se llevó a cabo el 2 de octubre de 2026 a las 02:00 PM mediante una reunión síncrona virtual en Discord, con la participación activa de los cinco integrantes del equipo Andeva. Durante la sesión se evaluaron los aprendizajes de la fase previa de descubrimiento y arquitectura estratégica, se formuló la meta unificada del sprint bajo criterios SMART y se descompuso el alcance en tareas de ingeniería. En la @tbl:sprint-planning-1 se presenta el resumen estructurado de la sesión, detallando el contexto operativo, los acuerdos retrospectivos, el Sprint Goal y los indicadores de esfuerzo comprometidos.

\renewcommand{\arraystretch}{1.2}
\begin{longtable}{| >{\raggedright\arraybackslash}p{4.8cm} | >{\raggedright\arraybackslash}p{\dimexpr\textwidth-4.8cm-4\tabcolsep-3\arrayrulewidth\relax} |}
\caption{Sprint Planning 1 - Resumen de la sesión de planificación del Sprint 1} \label{tbl:sprint-planning-1} \\
\hline
\thfirst{Sprint \#} & \thcell{Sprint 1} \\
\hline
\endfirsthead
\hline
\thfirst{Sprint \#} & \thcell{Sprint 1} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
\thspanfirst{2}{Sprint Planning Background} \\
\hline
\textbf{Date} & 2026-10-02 \\
\hline
\textbf{Time} & 02:00 PM - 04:30 PM \\
\hline
\textbf{Location} & Sesión síncrona virtual mediante Discord \\
\hline
\textbf{Prepared By} & Huamani Estefanero, Joel \\
\hline
\textbf{Attendees to planning meeting} & Granda Ibarra, Luis Daniel / Huamani Estefanero, Joel / Rocha Cotrina, Alvaro / Sanchez Santin, Adiel Abdiaz / Teran Zavala, Mauricio Alejandro \\
\hline
\textbf{Sprint 0 Review Summary} & Conclusión y aprobación formal de la fase de descubrimiento e ideación. Se consolidaron el perfil de la solución, los arquetipos de usuario, el mapeo de experiencia y la especificación de requisitos en el Product Backlog. Asimismo, se completó el diseño estratégico bajo Domain-Driven Design delimitando los ocho Bounded Contexts y el Shared Kernel, estableciendo los cimientos de la arquitectura limpia para el inicio de la fase constructiva. \\
\hline
\textbf{Sprint 0 Retrospective Summary} & Evaluación positiva de la cohesión del equipo y consenso en el lenguaje ubicuo. Como mejoras para la fase constructiva, se acordó estandarizar el gestor de paquetes pnpm, adoptar el flujo Git Flow con ramas feature, emplear contenedores Docker para compilaciones deterministas y coordinar sincronizaciones diarias en Discord. \\
\hline
\thspanfirst{2}{Sprint Goal \& User Stories} \\
\hline
\textbf{Sprint 1 Goal} & \textbf{Our focus is on} desplegar públicamente el portal web comercial de captación e implementar y verificar los contratos y servicios RESTful del backend para los ocho Bounded Contexts del ecosistema Atelier.\newline
\textbf{We believe it delivers} una experiencia interactiva y transparente para que los dueños de talleres automotrices conozcan el valor diferencial, comparen planes y activen su prueba gratuita de catorce días, proveyendo una plataforma de servicios desacoplada, verificada y documentada.\newline
\textbf{This will be confirmed when} los visitantes interactúan con el portal web comercial explorando tarifas, consultando dudas y transitando al registro, y cuando el 100\% de los endpoints técnicos superan sus pruebas de integración automatizadas y se encuentran documentados bajo OpenAPI. \\
\hline
\textbf{Sprint 1 Velocity} & 90 \\
\hline
\textbf{Sum of Story Points} & 90 \\
\hline
\end{longtable}

*Nota.* Cuadro de planificación del Sprint 1 adaptado de la guía de Scrum para el proyecto Atelier.

\newpage

#### 4.2.1.2. Aspect Leaders and Collaborators

Para optimizar la coordinación técnica, mitigar riesgos de integración y garantizar una comunicación efectiva durante la ejecución del primer ciclo constructivo, el equipo estructuró la matriz de liderazgo y colaboración Leadership-and-Collaboration Matrix, denominada LACX. Este artefacto formal delimita la propiedad técnica de cada componente funcional y arquitectónico del sprint, designando a un integrante como líder responsable de la completitud y calidad del entregable, y a los demás especialistas del área como colaboradores directos.

El alcance del Sprint 1 se distribuye en cinco aspectos funcionales y arquitectónicos cohesivos que articulan tanto el portal comercial como la plataforma de servicios:

- **Website: Propuesta de Valor y Experiencia de Usuario Core:** Abarca el diseño responsive de la página de aterrizaje, la presentación del catálogo de capacidades operativas de Atelier y la navegación inicial de los visitantes.
- **Website: Planes Comerciales y Tarifario Dinámico:** Comprende el modelado interactivo de precios, la selección de periodicidad mensual o anual y la simulación dinámica de ahorro y retorno de inversión para el taller automotriz.
- **Website: Centro de Preguntas Frecuentes y Conversión de Registro:** Incluye el acordeón interactivo de resolución de dudas técnicas y la pasarela de captación que guía al usuario hacia la activación de su prueba gratuita de catorce días.
- **Backend: Shared Kernel, IAM, IoT Telemetría y Facturación:** Contempla la base arquitectónica de la plataforma, el control de acceso con tokens JWT, la ingesta telemática vehicular en series temporales con TimescaleDB, la inferencia con Spring AI, la facturación electrónica UBL 2.1 y la integración de suscripciones con Stripe.
- **Backend: CRM, MRO, Inventario FIFO y Recursos Humanos:** Involucra los servicios para la gestión de clientes y vehículos, el ciclo de vida de órdenes de trabajo y faenas cronometradas en fosa, el catálogo y descargo de repuestos bajo el método de valoración de lotes FIFO, la marcación de asistencia con validación geodésica Haversine y la persistencia local para escenarios sin conectividad.

La @tbl:aspect-leaders-1 detalla la asignación de roles de liderazgo identificados con la letra L y de colaboración representados por la letra C para cada integrante del equipo en los cinco aspectos del Sprint 1.

\begingroup
\footnotesize
\setlength{\tabcolsep}{2.5pt}
\renewcommand{\arraystretch}{1.2}
\begin{longtable}{| >{\raggedright\arraybackslash}p{2.65cm} | >{\centering\arraybackslash}p{1.75cm} | >{\centering\arraybackslash}p{2.14cm} | >{\centering\arraybackslash}p{2.14cm} | >{\centering\arraybackslash}p{2.14cm} | >{\centering\arraybackslash}p{2.14cm} | >{\centering\arraybackslash}p{2.14cm} |}
\caption{Matriz de Líderes y Colaboradores por Aspecto del Sprint 1 (LACX)} \label{tbl:aspect-leaders-1} \\
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{2.65cm}|}{\textbf{Team Member}\newline\textbf{(Last Name,}\newline\textbf{First Name)}} & \textbf{GitHub}\newline\textbf{Username} & \textbf{Website:}\newline\textbf{Propuesta de}\newline\textbf{Valor \& UI}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} & \textbf{Website:}\newline\textbf{Planes \&}\newline\textbf{Tarifas}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} & \textbf{Website:}\newline\textbf{FAQ \&}\newline\textbf{Conversión}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} & \textbf{Backend:}\newline\textbf{Shared, IAM,}\newline\textbf{IoT \& Billing}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} & \textbf{Backend:}\newline\textbf{CRM, MRO,}\newline\textbf{Stock \& HR}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} \\
\hline
\endfirsthead
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{2.65cm}|}{\textbf{Team Member}\newline\textbf{(Last Name,}\newline\textbf{First Name)}} & \textbf{GitHub}\newline\textbf{Username} & \textbf{Website:}\newline\textbf{Propuesta de}\newline\textbf{Valor \& UI}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} & \textbf{Website:}\newline\textbf{Planes \&}\newline\textbf{Tarifas}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} & \textbf{Website:}\newline\textbf{FAQ \&}\newline\textbf{Conversión}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} & \textbf{Backend:}\newline\textbf{Shared, IAM,}\newline\textbf{IoT \& Billing}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} & \textbf{Backend:}\newline\textbf{CRM, MRO,}\newline\textbf{Stock \& HR}\newline\textbf{Leader (L) /}\newline\textbf{Collaborator~(C)} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
Granda Ibarra, Luis Daniel & danieltyuyu & L & C & C & - & - \\
\hline
Huamani Estefanero, Joel & shouydev & - & - & - & L & C \\
\hline
Rocha Cotrina, Alvaro & alvarorc24 & C & C & L & - & - \\
\hline
Sanchez Santin, Adiel Abdiaz & xs4el & - & - & - & C & L \\
\hline
Teran Zavala, Mauricio Alejandro & mau-tz & C & L & C & - & - \\
\hline
\end{longtable}
\endgroup

*Nota.* Matriz de liderazgo y colaboración del Sprint 1 adaptada de la guía del proyecto Atelier.

#### 4.2.1.3. Sprint Backlog 1

El Sprint Backlog del primer ciclo de desarrollo consolida el conjunto de historias seleccionadas por el equipo para materializar el objetivo del sprint. Dicho objetivo se concentró en publicar la página de aterrizaje comercial e implementar la totalidad de los contratos e interfaces RESTful del backend distribuidos a lo largo de los ocho Bounded Contexts, complementados por tres spikes de mitigación técnica. Esta estrategia constructiva permitió asegurar que la plataforma provea una base de servicios operativa, desacoplada y verificada antes de emprender las interfaces cliente de los siguientes ciclos.

El control del avance operativo y el seguimiento de las historias del sprint se gestionaron de manera interactiva mediante el tablero ágil en Jira Software, el cual se encuentra disponible para auditoría y consulta a través del enlace público oficial: [Tablero del Sprint 1 en Jira Software](https://andeva.atlassian.net/?continue=https%3A%2F%2Fandeva.atlassian.net%2Fwelcome%2Fsoftware%3FprojectId%3D10001&atlOrigin=eyJpIjoiZTAzNjYwMTQwNjVmNDVjY2ExOGUxZDkyMTBlMTUzNGIiLCJwIjoiamlyYS1zb2Z0d2FyZSJ9).

![Tablero del Sprint 1 en Jira Software](report/assets/sprint-1/table-jira-sprint-1.png){#fig:table-jira-sprint-1}

La @tbl:sprint-backlog-1 presenta la matriz consolidada del Sprint Backlog del Sprint 1, detallando las cuatro historias de usuario del portal web, las veinticuatro historias técnicas del backend y los tres spikes de arquitectura. Las historias se desglosan en ciento treinta y tres tareas registradas en Jira Software, cuya estimación conjunta asciende a doscientas setenta horas a razón de tres horas por Story Point, junto con su asignación individual y su estado final de culminación.

\begingroup
\scriptsize
\setlength{\tabcolsep}{2pt}
\renewcommand{\arraystretch}{1.2}
\begin{longtable}{| >{\centering\arraybackslash}p{0.9cm} | >{\raggedright\arraybackslash}p{2.8cm} | >{\centering\arraybackslash}p{1.0cm} | >{\centering\arraybackslash}p{1.6cm} | >{\raggedright\arraybackslash}p{4.4cm} | >{\centering\arraybackslash}p{1.0cm} | >{\raggedright\arraybackslash}p{2.1cm} | >{\centering\arraybackslash}p{1.1cm} |}
\caption{Sprint Backlog del Sprint 1 y Estado de Ejecución de Ítems} \label{tbl:sprint-backlog-1} \\
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{0.9cm}|}{\textbf{Sprint \#}} & \multicolumn{7}{c|}{\textbf{Sprint 1}} \\
\hline
\multicolumn{2}{|c|}{\textbf{User Story}} & \multicolumn{6}{c|}{\textbf{Work-Item / Task}} \\
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{0.9cm}|}{\textbf{Id}} & \multicolumn{1}{>{\centering\arraybackslash}p{2.8cm}|}{\textbf{Title}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.0cm}|}{\textbf{Id}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.6cm}|}{\textbf{Title}} & \multicolumn{1}{>{\centering\arraybackslash}p{4.4cm}|}{\textbf{Description}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.0cm}|}{\textbf{Estimation}\newline\textbf{(Hours)}} & \multicolumn{1}{>{\centering\arraybackslash}p{2.1cm}|}{\textbf{Assigned}\newline\textbf{To}} & \multicolumn{1}{>{\centering\arraybackslash}p{1.1cm}|}{\textbf{Status}} \\
\hline
\endfirsthead
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{0.9cm}|}{\textbf{Sprint \#}} & \multicolumn{7}{c|}{\textbf{Sprint 1}} \\
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
US45 & Presentación de la propuesta de valor central del ecosistema Atelier & AT-190 & Contenido & Redactar y estructurar el planteamiento del problema operativo, pérdidas por inventario y desorden, frente a los beneficios de Atelier & 1 & Rocha Cotrina, Alvaro & Done \\
\cline{3-8}
 &  & AT-191 & Diseño UX/UI & Diseñar el wireframe y la jerarquía visual de la sección de capacidades tecnológicas diferenciales: Offline, OBD-II e IA & 2 & Rocha Cotrina, Alvaro & Done \\
\cline{3-8}
 &  & AT-192 & Frontend & Integrar los bloques informativos de la propuesta de valor y la validez de los comprobantes tributarios en la interfaz de bienvenida & 2 & Rocha Cotrina, Alvaro & Done \\
\cline{3-8}
 &  & AT-193 & QA & Verificar la correcta visualización y legibilidad de los mensajes clave enfocados en el dueño de taller & 1 & Rocha Cotrina, Alvaro & Done \\
\hline
US46 & Exploración y comparativa dinámica de planes comerciales según periodicidad de facturación & AT-194 & Contenido & Redactar y estructurar los textos comparativos de precios, montos anualizados y beneficios acumulativos para los Planes Go, Pro y Max & 2 & Teran Zavala, Mauricio Alejandro & Done \\
\cline{3-8}
 &  & AT-195 & Diseño UX/UI & Diseñar los componentes interactivos de alternancia toggle switch entre las frecuencias de facturación mensual y anual en la interfaz web & 2 & Teran Zavala, Mauricio Alejandro & Done \\
\cline{3-8}
 &  & AT-196 & Frontend & Implementar la lógica de actualización dinámica de tarifas y el despliegue visual de los mensajes de ahorro y renovación flexible & 3 & Teran Zavala, Mauricio Alejandro & Done \\
\cline{3-8}
 &  & AT-197 & QA & Validar la precisión de los montos calculados de planes mensuales frente a anuales con descuento y el correcto comportamiento del selector de planes & 2 & Teran Zavala, Mauricio Alejandro & Done \\
\hline
US47 & Resolución interactiva de dudas operativas y condiciones del servicio & AT-101 & Contenido & Redactar y estructurar las respuestas a las dudas operativas más comunes & 1 & Granda Ibarra, Luis Daniel & Done \\
\cline{3-8}
 &  & AT-102 & Frontend & Desarrollar el componente interactivo tipo acordeón para las dudas & 2 & Granda Ibarra, Luis Daniel & Done \\
\cline{3-8}
 &  & AT-103 & Frontend & Aplicar estilos visuales con Tailwind y animaciones de transición al acordeón & 2 & Granda Ibarra, Luis Daniel & Done \\
\cline{3-8}
 &  & AT-104 & QA & Verificar el correcto funcionamiento del clic en las preguntas & 1 & Granda Ibarra, Luis Daniel & Done \\
\hline
US48 & Redirección y transición hacia el flujo de registro de prueba gratuita en la aplicación principal & AT-97 & Diseño & Diseñar y definir los botones Call to Action para activar la prueba gratuita & 2 & Granda Ibarra, Luis Daniel & Done \\
\cline{3-8}
 &  & AT-98 & Frontend & Maquetar e implementar los botones de redirección en el Hero y en la sección de Precios & 2 & Granda Ibarra, Luis Daniel & Done \\
\cline{3-8}
 &  & AT-99 & Frontend & Configurar el enrutamiento para transicionar al flujo de alta conservando el ID del plan seleccionado & 3 & Granda Ibarra, Luis Daniel & Done \\
\cline{3-8}
 &  & AT-100 & QA & Validar que la redirección funcione en Mobile y Desktop sin pedir tarjeta de crédito & 2 & Granda Ibarra, Luis Daniel & Done \\
\hline
TS01 & Autenticación de credenciales y expedición de tokens JWT & AT-198 & Endpoint REST & Exponer endpoint REST POST /api/v1/auth/sign-in en AuthenticationController & 1 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-199 & Autenticación & Implementar AuthenticateUserCommand en UserCommandServiceImpl con verificación BCrypt y rechazo HTTP 401 & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-200 & Tokens JWT & Emitir par de tokens JWT de acceso y renovación con contexto de inquilino en BearerTokenServiceImpl & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-201 & Pruebas unitarias & Implementar pruebas unitarias de autenticación exitosa y rechazo de credenciales inválidas & 1 & Huamani Estefanero, Joel & Done \\
\hline
TS02 & Registro fundacional de organización y aprovisionamiento de inquilino & AT-202 & Endpoint REST & Exponer endpoint REST POST /api/v1/auth/sign-up en AuthenticationController & 1 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-203 & Servicio de aplicación & Orquestar alta atómica de inquilino y administrador en TenantCommandServiceImpl con rechazo HTTP 409 por RUC duplicado & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-204 & Persistencia & Mapear TenantPersistenceEntity, UserPersistenceEntity y TenantMembershipPersistenceEntity en PostgreSQL & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-205 & Pruebas unitarias & Implementar pruebas unitarias de aprovisionamiento de inquilino y colisión tributaria & 1 & Huamani Estefanero, Joel & Done \\
\hline
TS03 & Verificación de correo y activación mediante código OTP & AT-206 & Endpoint REST & Exponer endpoint REST POST /api/v1/auth/verify-email en AuthenticationController & 1 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-207 & Validación OTP & Validar código OTP de seis dígitos con vigencia de quince minutos en VerifyEmailTokenCommand y rechazo HTTP 400 & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-208 & Persistencia y correo & Persistir VerificationTokenPersistenceEntity y despachar el código OTP mediante ResendEmailAdapter & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-209 & Pruebas unitarias & Implementar pruebas unitarias de activación de cuenta y rechazo de OTP caducado & 1 & Huamani Estefanero, Joel & Done \\
\hline
TS04 & Emisión y despacho de invitaciones corporativas de personal & AT-210 & Endpoint REST & Exponer endpoint REST POST /api/v1/invitations/tenant/\{tenantId\} protegido por rol administrador & 1 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-211 & Servicio de aplicación & Implementar InvitationCommandServiceImpl con token firmado de 48 horas y rechazo HTTP 409 por invitación pendiente & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-212 & Persistencia y correo & Mapear InvitationPersistenceEntity y despachar correo transaccional mediante ResendEmailAdapter & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-213 & Pruebas unitarias & Implementar pruebas unitarias de emisión de invitaciones y duplicidad pendiente & 1 & Huamani Estefanero, Joel & Done \\
\hline
TS05 & Alta de sucursales operativas y delimitación de geocercas & AT-214 & Endpoint REST & Exponer endpoint REST POST /api/v1/branches en BranchesController con validación de coordenadas WGS84 & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-215 & Servicio de aplicación & Implementar BranchCommandServiceImpl validando la cuota de suscripción con SubscriptionQuotaPort y rechazo HTTP 422 & 3 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-216 & Persistencia & Mapear BranchPersistenceEntity con GeoPointEmbeddable y radio perimétrico de geocerca & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-217 & Pruebas unitarias & Implementar pruebas unitarias de alta de sucursales y coordenadas fuera de rango & 2 & Huamani Estefanero, Joel & Done \\
\hline
TS06 & Alta de clientes individuales con validación de identidad & AT-105 & Endpoint REST & Exponer controlador REST POST clientes individuales con validacion DNI & 2 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-153 & Servicio de aplicación & Implementar orquestacion en CustomerCommandService y unicidad scoped al inquilino HTTP 409 & 3 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-154 & Persistencia & Mapear entidad JPA IndividualCustomerPersistenceEntity y repositorio en PostgreSQL & 2 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-155 & Pruebas unitarias & Implementar pruebas unitarias BDD para alta de clientes y colision de identidad & 2 & Sanchez Santin, Adiel Abdiaz & Done \\
\hline
TS07 & Registro técnico de vehículos con homologación de placa y VIN & AT-142 & Endpoint REST & Exponer endpoint REST POST registro vehicular con validacion ISO 3779 & 2 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-156 & Homologación de flota & Implementar homologacion de flota en VehicleFleetService y enlace de cliente custodio & 3 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-157 & Persistencia & Configurar entidad VehiclePersistenceEntity y constraint UNIQUE de VIN por taller & 2 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-158 & Pruebas unitarias & Implementar pruebas unitarias verificando rechazo HTTP 400 por VIN o placa invalidos & 2 & Sanchez Santin, Adiel Abdiaz & Done \\
\hline
TS08 & Agendamiento y reserva de citas de mantenimiento & AT-143 & Endpoint REST & Exponer endpoint REST POST agendamiento de citas de mantenimiento & 1 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-159 & Motor de agendamiento & Implementar motor AppointmentSchedulingService evaluando capacidad y cupo de patio HTTP 409 & 2 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-160 & Persistencia & Mapear entidad AppointmentPersistenceEntity en estado inicial SCHEDULED y confirmar cita & 2 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-161 & Pruebas unitarias & Implementar pruebas unitarias de deteccion de sobreposicion horaria y franja disponible & 1 & Sanchez Santin, Adiel Abdiaz & Done \\
\hline
TS09 & Registro de arribo a patio y apertura automática de orden & AT-144 & Endpoint REST & Exponer endpoint REST POST recepcion vehicular y check-in a patio & 1 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-162 & Transición de cita & Implementar transicion de cita a CHECKED\_IN y rechazo de citas atendidas o canceladas HTTP 422 & 2 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-163 & Evento de dominio & Orquestar despacho de AppointmentCheckedInEvent y apertura automatica de orden en borrador & 2 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-164 & Pruebas unitarias & Implementar pruebas unitarias de transicion de recepcion y generacion reactiva de orden & 1 & Sanchez Santin, Adiel Abdiaz & Done \\
\hline
TS10 & Apertura y parametrización de órdenes de trabajo en taller & AT-145 & Endpoint REST & Exponer endpoint REST POST apertura de ordenes de trabajo en taller & 1 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-165 & Control de concurrencia & Implementar WorkOrderConcurrencyService para bloquear apertura en vehiculo con orden activa HTTP 409 & 2 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-166 & Correlativo y persistencia & Generar correlativo secuencial unico OT-YYYYMM-XXXX y persistir WorkOrderPersistenceEntity & 2 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-167 & Pruebas unitarias & Implementar pruebas unitarias de validacion concurrente de patio y estados de orden & 1 & Sanchez Santin, Adiel Abdiaz & Done \\
\hline
TS11 & Asignación y conmutación de bahías de servicio en orden & AT-146 & Endpoint REST & Exponer endpoint REST PUT asignacion y conmutacion de bahias & 3 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-168 & Asignación de bahía & Implementar ServiceBayAllocationService y rechazo de bahia ocupada con codigo HTTP 409 & 4 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-169 & Conmutación de estado & Conmutar concurrentemente bahia a estado OCCUPIED en base de datos y actualizar orden & 4 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-170 & Pruebas unitarias & Implementar pruebas unitarias de concurrencia y asignacion atomica de bahias & 4 & Sanchez Santin, Adiel Abdiaz & Done \\
\hline
TS12 & Incorporación de tareas técnicas a la orden de trabajo & AT-147 & Endpoint REST & Exponer endpoint REST POST incorporacion de labores mecanicas a orden & 3 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-171 & Cálculo de subtotal & Copiar tarifa base de catalogo, inicializar tarea en PENDING y recalcular subtotal acumulado & 4 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-172 & Regla de inmutabilidad & Validar regla de inmutabilidad rechazando mutaciones sobre ordenes cerradas o pagadas HTTP 422 & 4 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-173 & Pruebas unitarias & Implementar pruebas unitarias de calculo aritmetico de subtotales y reglas de ciclo de vida & 4 & Sanchez Santin, Adiel Abdiaz & Done \\
\hline
TS13 & Control cronometrado y finalización técnica de faenas & AT-148 & Endpoint REST & Exponer endpoint REST POST reporte de finalizacion de faena mecanica & 2 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-174 & Validación de estado & Validar precondicion de faena en progreso IN\_PROGRESS denegando tareas pendientes HTTP 422 & 3 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-175 & Cierre de faena & Sellar estampa fin, computar duracion efectiva en minutos y transicionar orden a COMPLETED & 2 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-176 & Pruebas unitarias & Implementar pruebas unitarias de medicion de labor efectiva y cierre automatico de orden & 2 & Sanchez Santin, Adiel Abdiaz & Done \\
\hline
TS14 & Requisición y descargo de repuestos bajo método FIFO & AT-149 & Endpoint REST & Exponer endpoint REST POST requisicion e imputacion de repuestos a tarea & 1 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-177 & Motor FIFO & Implementar FifoAllocationEngine consumiendo lotes fisicos por antiguedad arrival\_date ASC & 2 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-178 & Validación de existencias & Validar existencias consolidadas con HTTP 409 y recalcular importes COGS de faena y orden & 2 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-179 & Pruebas unitarias & Implementar pruebas unitarias de asignacion parcial y total de existencias bajo orden FIFO & 1 & Sanchez Santin, Adiel Abdiaz & Done \\
\hline
TS15 & Catálogo de repuestos con precio base y umbral crítico & AT-150 & Endpoint REST & Exponer endpoint REST POST catalogo de repuestos con precio base y SKU & 2 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-180 & Unicidad de SKU & Implementar validacion de unicidad de SKU scoped al taller respondiendo HTTP 409 ante colision & 3 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-181 & Persistencia & Mapear PartPersistenceEntity, inicializar stock contable en cero y persistir en tabla parts & 2 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-182 & Pruebas unitarias & Implementar pruebas unitarias de catalogo de repuestos y validacion de umbrales criticos & 2 & Sanchez Santin, Adiel Abdiaz & Done \\
\hline
TS16 & Ingreso y valorización de lotes por adquisición & AT-151 & Endpoint REST & Exponer endpoint REST POST ingreso de lotes de repuestos por compra & 2 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-183 & Validación numérica & Validar valores numericos estrictamente positivos @Positive respondiendo HTTP 400 ante invalidos & 3 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-184 & Persistencia de lotes & Persistir InventoryBatchPersistenceEntity, encolar en FIFO e incrementar stock contable & 2 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-185 & Pruebas unitarias & Implementar pruebas unitarias de asentamiento de lotes y consistencia de inventario valorizado & 2 & Sanchez Santin, Adiel Abdiaz & Done \\
\hline
TS17 & Marcación geodésica de jornada laboral con validación Haversine & AT-152 & Endpoint REST & Exponer endpoint REST POST marcacion satelital de asistencia laboral & 1 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-186 & Cálculo Haversine & Implementar HaversineGeofencingService con formula geodesica de radio terrestre 6371 km & 1 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-187 & Validación de geocerca & Validar pertenencia a geocerca con rechazo HTTP 422 y calificar puntualidad ON\_TIME vs LATE & 2 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-188 & Persistencia y eventos & Mapear AttendanceRecordPersistenceEntity, estampa inmutable y publicar EmployeeClockedInEvent & 1 & Sanchez Santin, Adiel Abdiaz & Done \\
\cline{3-8}
 &  & AT-189 & Pruebas unitarias & Implementar pruebas unitarias de calculo geodesico Haversine y precision de geocerca & 1 & Sanchez Santin, Adiel Abdiaz & Done \\
\hline
TS18 & Emisión y timbrado de comprobantes electrónicos UBL 2.1 & AT-218 & Endpoint REST & Exponer endpoint REST POST /api/v1/invoicing/vouchers en ElectronicVouchersController & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-219 & Cálculo tributario & Reservar correlativo con SeriesCorrelativeService y calcular IGV de 18 por ciento en PeruvianTaxCalculationEngine & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-220 & Integración SUNAT & Generar XML UBL 2.1, transmitirlo vía NubefactPseFiscalAdapter y almacenar la constancia CDR en Firebase & 3 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-221 & Pruebas unitarias & Implementar pruebas unitarias de emisión de comprobantes y rechazo HTTP 422 por orden no completada & 2 & Huamani Estefanero, Joel & Done \\
\hline
TS19 & Registro transaccional de pagos y liquidación de comprobantes & AT-222 & Endpoint REST & Exponer endpoint REST POST /api/v1/invoicing/payments en VoucherPaymentsController & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-223 & Servicio de aplicación & Implementar amortización de saldo en VoucherPaymentCommandServiceImpl con rechazo HTTP 400 por sobrepago & 3 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-224 & Persistencia y eventos & Mapear VoucherPaymentPersistenceEntity y publicar el evento de liquidación total hacia Operations & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-225 & Pruebas unitarias & Implementar pruebas unitarias de pago total, pago parcial y abono excedente & 2 & Huamani Estefanero, Joel & Done \\
\hline
TS20 & Ingesta masiva de telemetría vehicular IoT en series temporales & AT-226 & Endpoint REST & Exponer endpoint REST POST /api/v1/iot/telemetry/batch con validación de lote de 1 a 100 lecturas & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-227 & Servicio de aplicación & Implementar TelemetryIngestionCommandServiceImpl con respuesta asíncrona HTTP 202 & 3 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-228 & Hipertabla TimescaleDB & Insertar lotes en la hipertabla TimescaleDB mediante TimescaleBatchJdbcClientPort y TelemetryLogPersistenceEntity & 4 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-229 & Detección de anomalías & Evaluar umbrales críticos con PredictiveAnomalyDetectionEngine y notificar alertas mediante FCM & 3 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-230 & Pruebas unitarias & Implementar pruebas unitarias de ingesta de ráfagas y rechazo HTTP 400 por lote inválido & 3 & Huamani Estefanero, Joel & Done \\
\hline
TS21 & Registro y catalogación de códigos de avería electrónica DTC & AT-231 & Endpoint REST & Exponer endpoint REST POST /api/v1/iot/faults en VehicleFaultsController & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-232 & Validación DTC & Validar formato SAE J2012 en DtcCodeEvaluationService con rechazo HTTP 400 & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-233 & Persistencia & Mapear VehicleFaultPersistenceEntity y DtcCatalogEntryPersistenceEntity en PostgreSQL & 3 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-234 & Pruebas unitarias & Implementar pruebas unitarias de registro de fallas y nomenclatura DTC inválida & 2 & Huamani Estefanero, Joel & Done \\
\hline
TS22 & Generación de informe pericial asistido por IA predictiva & AT-235 & Endpoint REST & Exponer endpoint REST POST /api/v1/iot/health-reports/generate en VehicleHealthReportsController & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-236 & Consolidación de datos & Consolidar telemetría con TimescaleTelemetryAnalyticsRepository y fallas DTC activas con rechazo HTTP 422 & 3 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-237 & Integración Spring AI & Integrar Spring AI con Groq en GroqSpringAiDiagnosticAdapter mediante prompt estructurado & 4 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-238 & Dictamen pericial & Persistir el dictamen pericial y responder HTTP 201 con cabecera Location & 3 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-239 & Pruebas unitarias & Implementar pruebas unitarias de generación de informe y datos sensoriales insuficientes & 3 & Huamani Estefanero, Joel & Done \\
\hline
TS23 & Descarga documental de estado de flujo de caja en formato PDF & AT-240 & Endpoint REST & Exponer endpoint REST GET /api/v1/invoicing/financial-reports/cash-flow/pdf con cabecera Content-Disposition & 1 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-241 & Consulta financiera & Consolidar ingresos y egresos en CashFlowQueryServiceImpl con rechazo HTTP 400 por rango invertido & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-242 & Generación PDF & Renderizar el documento PDF de flujo de caja con OpenPdfCashFlowReportAdapter & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-243 & Pruebas unitarias & Implementar pruebas unitarias de exportación PDF y validación de fechas & 1 & Huamani Estefanero, Joel & Done \\
\hline
TS24 & Descarga documental de informe pericial de salud vehicular en PDF & AT-244 & Endpoint REST & Exponer endpoint REST GET /api/v1/iot/health-reports/\{reportId\}/pdf en VehicleHealthReportsController & 1 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-245 & Consulta de informe & Resolver el informe en VehicleHealthReportQueryServiceImpl con respuesta HTTP 404 ProblemDetail & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-246 & Generación PDF & Renderizar el PDF con membrete y semáforos de criticidad en OpenPdfVehicleHealthReportGeneratorAdapter & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-247 & Pruebas unitarias & Implementar pruebas unitarias de descarga de informe e identificador inexistente & 1 & Huamani Estefanero, Joel & Done \\
\hline
SP01 & Telemetría Bluetooth OBD-II e Inferencia Predictiva con Spring AI & AT-248 & Bibliotecas BLE & Evaluar bibliotecas BLE en Flutter con flutter\_blue\_plus y canales nativos para escáneres ELM327 & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-249 & Decodificador OBD-II & Validar el decodificador de tramas PID y códigos DTC bajo la norma SAE J2012 & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-250 & Inferencia Spring AI & Evaluar la inferencia asistida por Spring AI con prompts estructurados y latencia de respuesta & 3 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-251 & Permisos móviles & Auditar permisos de radiofrecuencia y almacenamiento en Android 14 e iOS 18 & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-252 & Latencia TimescaleDB & Medir latencia de red y rendimiento de inserción en hipertablas TimescaleDB & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-253 & Prototipo & Construir el prototipo funcional OBD-II con informe predictivo en rama experimental & 3 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-254 & Informe y estimación & Consolidar el informe técnico y estimar el esfuerzo de las historias de diagnóstico & 1 & Huamani Estefanero, Joel & Done \\
\hline
SP02 & Pasarela de Pagos Stripe y Webhooks Asíncronos para Suscripciones SaaS & AT-255 & Stripe Billing & Revisar la documentación de Stripe Billing y Stripe Checkout para suscripciones SaaS & 1 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-256 & SDK stripe-java & Evaluar el SDK stripe-java en Spring Boot con creación programática de clientes y sesiones & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-257 & Webhooks & Implementar el controlador de webhooks con verificación Stripe-Signature e idempotencia de eventos & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-258 & Auditoría PCI-DSS & Auditar el flujo de tokenización y certificar el nivel de cumplimiento SAQ-A & 1 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-259 & Prototipo & Construir el prototipo de suscripción con tarjetas de prueba y habilitación de cupos & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-260 & Informe y estimación & Consolidar costos de transacción y estimar la épica de suscripciones SaaS & 1 & Huamani Estefanero, Joel & Done \\
\hline
SP03 & Persistencia Relacional Local SQLite 3 y Sincronización Offline-First en Fosa & AT-261 & Motor SQLite 3 & Evaluar el desempeño de SQLite 3 en Flutter frente a almacenes clave-valor & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-262 & Cola de mutaciones & Diseñar la cola local de mutaciones sin conexión con marcas cronológicas inmutables & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-263 & Resolución de conflictos & Definir la resolución determinista de conflictos de concurrencia por marcas temporales & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-264 & Sincronización & Prototipar la sincronización con reintentos exponenciales sin duplicar peticiones HTTP & 2 & Huamani Estefanero, Joel & Done \\
\cline{3-8}
 &  & AT-265 & Informe y dimensionamiento & Documentar las directrices offline-first y dimensionar el almacenamiento local & 1 & Huamani Estefanero, Joel & Done \\
\hline
\end{longtable}
\endgroup

*Nota.* Estructura del Sprint Backlog del Sprint 1 adaptada de la guía de Scrum para el proyecto Atelier.

#### 4.2.1.4. Development Evidence for Sprint Review

Durante el primer ciclo constructivo, el equipo completó el desarrollo integral de la página de aterrizaje comercial de la solución y la infraestructura fundacional de servicios web del backend de Atelier Platform. La implementación se ejecutó sobre dos repositorios independientes con el propósito de garantizar un desacoplamiento estricto entre la experiencia web y la lógica de dominio empresarial:

- **Repositorio del Portal Comercial (Landing Page):** [https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier-website](https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier-website)
- **Repositorio de la Plataforma de Servicios Web (Backend):** [https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier-platform](https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier-platform)

En el ámbito del portal comercial (`atelier-website`), el equipo estructuró una aplicación web moderna y accesible basada en HTML5 semántico, JavaScript modular y maquetación responsiva mediante los tokens de diseño de Tailwind CSS v4. La interfaz incorpora tipografías corporativas optimizadas (Satoshi y Albert Sans) alojadas de forma local, soporte nativo de Progressive Web App con Service Worker para funcionamiento sin conexión, y un diccionario de internacionalización ligero para alternancia dinámica entre español e inglés. El portal expone la propuesta de valor central de Atelier a través de una sección principal interactiva con maqueta de dispositivo móvil, demostración en tiempo real de telemetría vehicular OBD-II, comparativa visual antes y después del impacto operativo en talleres mecánicos, catálogo de planes tarifarios con simulación de ahorro anual, centro de preguntas frecuentes con navegación por acordeón y modal de conversión hacia el registro de prueba gratuita de catorce días.

La @tbl:development-evidence-website detalla la relación completa de los treinta commits registrados en el repositorio del portal comercial correspondientes a las actividades de maquetación, estilización, interactividad, internacionalización y soporte fuera de línea del Sprint 1.

\begingroup
\scriptsize
\setlength{\tabcolsep}{2.5pt}
\renewcommand{\arraystretch}{1.15}
\begin{longtable}{| >{\raggedright\arraybackslash}p{2.6cm} | >{\centering\arraybackslash}p{1.4cm} | >{\centering\arraybackslash}p{1.6cm} | >{\raggedright\arraybackslash}p{4.4cm} | >{\raggedright\arraybackslash}p{3.4cm} | >{\centering\arraybackslash}p{1.8cm} |}
\caption{Evidencias de Desarrollo del Repositorio de Landing Page (Sprint 1)} \label{tbl:development-evidence-website} \\
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
andeva-upc/\allowbreak atelier-website & main & \texttt{344e062} & Merge pull request \#2 from upc-pre-202620-1acc0238-4951-andeva/\allowbreak develop & Develop & 08/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{20ae0a6} & refactor: bump service worker cache version, add asset loading checks for intro, and use ThreadingTCPServer. & - & 07/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{6715f4f} & Merge pull request \#4 from upc-pre-202620-1acc0238-4951-andeva/\allowbreak feature/\allowbreak navbar & chore: add IDE configuration for GitFlow helper & 07/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{bf6a73e} & chore: add IDE configuration for GitFlow helper & - & 07/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{f11f80d} & chore: add JetBrains IDE configuration files & - & 07/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{08f6f63} & feat(i18n): add pricing, faq, and demo translations & - & 06/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{6f776cb} & feat(js): add logic for pricing, faq accordion, and demo modal & - & 06/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{cbc30f2} & feat(html): add pricing, faq, install, and demo modal sections & - & 06/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{7ff7427} & feat(js): add PWA manifest and offline cache & - & 05/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{8994ae1} & feat(js): addpwa install and whatsapp links & - & 05/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{c36bf92} & feat(i18n): add product and team for both idioms & - & 05/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{15e8e40} & feat(style): add Tailwind utilities and theme styling & - & 05/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{0bbe73d} & feat(html) :add product, roles, and team landing sections & - & 05/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{df04c82} & Merge pull request \#1 from upc-pre-202620-1acc0238-4951-andeva/\allowbreak feature/\allowbreak part1-base-hero & Feature/\allowbreak part1 base hero & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{2732a6e} & feat(js): add scroll effects, live telemetry demo and intro animation & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{1019106} & feat(js): add theme toggle, language switch and mobile drawer & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{991c012} & feat(i18n): add ES and EN dictionary for navigation, hero, stats, comparison and steps & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{5bbdb5c} & feat(html): add how-it-works section & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{db88719} & feat(html): add context stats and before/\allowbreak after comparison & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{d48ac37} & feat(html): add hero section with phone mockup & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{4514c8f} & feat(html): add document head, intro overlay, navigation and drawer & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{893050e} & feat(style): add dark-mode adaptations, responsive rules and mobile drawer & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{1b13b49} & feat(style): add hero, stats and how-it-works layout & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{aed1b98} & feat(style): add navigation, buttons and typography & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{2a673a1} & feat(style): add Tailwind v4 theme tokens and base styles & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{1c9b434} & feat(assets): vendor Phosphor icons for offline use & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{59a7f3d} & feat(assets): add brand logos, isotipo, favicon and intro masks & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{506fb0d} & feat(assets): add Satoshi and Albert Sans fonts served locally & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{229d10f} & chore: add pnpm manifest, lockfile and local dev server & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-website & main & \texttt{d2e065d} & chore: initialize repository & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
\end{longtable}
\endgroup


*Nota.* Registro cronológico de commits de implementación en el repositorio oficial de la página de aterrizaje.

En el ámbito de la plataforma transaccional (`atelier-platform`), el equipo implementó la totalidad de los contratos de servicio web y módulos de dominio distribuidos en los ocho Bounded Contexts y el núcleo compartido. La arquitectura adoptó los principios de Arquitectura Limpia y Diseño Guiado por el Dominio hexagonal sobre Spring Boot 3 y Java 25. La solución articula segregación de responsabilidades mediante comandos y consultas CQRS, persistencia relacional en PostgreSQL 16, almacenamiento de series temporales en hipertablas de TimescaleDB, autenticación stateless con tokens JWT, validación perimétrica geodésica mediante fórmula de Haversine para control de jornada laboral, valoración y descargo de inventario bajo el método contable FIFO estricto, facturación electrónica nativa UBL 2.1 ante SUNAT, e ingesta telemática vehicular complementada con inferencia predictiva asistida por Spring AI.

La @tbl:development-evidence-backend presenta la relación consolidada de los noventa y ocho commits de desarrollo e integración de los servicios web del backend registrados durante el Sprint 1.

\begingroup
\scriptsize
\setlength{\tabcolsep}{2.5pt}
\renewcommand{\arraystretch}{1.15}
\begin{longtable}{| >{\raggedright\arraybackslash}p{2.6cm} | >{\centering\arraybackslash}p{1.4cm} | >{\centering\arraybackslash}p{1.6cm} | >{\raggedright\arraybackslash}p{4.4cm} | >{\raggedright\arraybackslash}p{3.4cm} | >{\centering\arraybackslash}p{1.8cm} |}
\caption{Evidencias de Desarrollo del Repositorio de Backend y Servicios Web (Sprint 1)} \label{tbl:development-evidence-backend} \\
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
andeva-upc/\allowbreak atelier-platform & main & \texttt{5513f20} & fix(deploy): increase Metaspace to 220MB and balance heap within 512MB RAM & - & 08/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{d3576e3} & fix(deploy): optimize memory for Render 512MB and fix servlet context path & - & 08/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{ac36ee8} & Merge tag '1.0.0' into develop & Release 1.0.0 1.0.0 & 08/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{9b02a9e} & Merge branch 'release/\allowbreak 1.0.0' & - & 08/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{d7ff62d} & Merge branch 'feature/\allowbreak context-facade' into develop & - & 08/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{e2d7820} & feat: add Dockerfile and container configuration. & Introduce a production-ready multi-stage Docker build for the application using Eclipse Temurin OpenJDK 25 on Ubuntu Noble LTS, along with security and environment variable updates. & 08/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{70c4d85} & chore: update Stripe price IDs in billing schema. & Update seed data in the billing schema reference script with official production/\allowbreak sandbox Stripe Price IDs for Go, Pro, and Max subscription tiers across monthly and yearly cycles. & 08/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{8406720} & feat: wire cross-context ACLs and controllers. & Connect inter-boundary Anti-Corruption Layers (ACL), external event listeners, and quota adapters across CRM, HR, IAM, Inventory, Invoicing, IoT, and Workshop Operations, aligning REST controllers and profiles. & 08/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{e8be27d} & docs: remove temporary documentation notes. & Remove temporary tracking notes and invoicing prompts from the backend documentation directory to maintain clean documentation. & 08/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{b266f1c} & Merge tag '0.8.0' into develop & Release 0.8.0 0.8.0 & 07/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{da45159} & Merge branch 'release/\allowbreak 0.8.0' & - & 07/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{3862d26} & Merge branch 'feature/\allowbreak bounded-controllers' into develop & - & 07/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{ce8ccc6} & feat: add Invoicing and IoT bounded contexts. & Implement the full domain-driven architectures for the Invoicing \& Compliance bounded context (SUNAT e-invoicing, UBL 2.1, CDR processing) and the IoT Telemetry \& Predictive Maintenance bounded context (TimescaleDB... & 07/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{82cd27f} & refactor: update API specs and prune endpoints. & Synchronize REST API documentation across all eight bounded contexts, document backend tracking issues, and remove deprecated standalone user management controller endpoints and redundant billing request DTOs. & 07/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{9933761} & Merge branch 'release/\allowbreak 0.7.0' & - & 06/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{ef7c13d} & Merge tag '0.7.0' into develop & - & 06/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{c656620} & Merge branch 'feature/\allowbreak human-resources' into develop & - & 06/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{700812e} & feat(hr): implement REST controllers, resources and assemblers for 27 canonical endpoints & - & 06/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{9c87ea6} & feat(hr): implement application command and query services, outbox publisher, ACL gateways and OHS facade & - & 06/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{b513ee2} & feat(hr): implement infrastructure persistence entities, converters, spring data repositories and adapters & - & 06/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{0d55879} & feat(hr): implement domain layer aggregates, value objects, domain services, events and repositories & - & 06/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{987e5dd} & feat(shared): introduce TenantMembershipId strongly-typed value object & - & 06/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{4d5026d} & Merge tag '0.6.0' into develop & - & 06/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{5e11cdc} & Merge branch 'release/\allowbreak 0.6.0' & - & 06/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{322b4cb} & Merge branch 'feature/\allowbreak inventory-supply-chain' into develop & - & 06/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{dc2df34} & fix(inventory): configure outbox fallback execution and transactional boundary for stock reservations & - & 06/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{5c05d52} & refactor(inventory): optimize outbox event delivery, domain event dispatching, and CQRS query decoupling & - & 05/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{cb562c3} & feat(inventory): implement canonical REST controllers exposing 22 inventory and supply chain endpoints & - & 05/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{9e227f7} & feat(inventory): implement interface resources, assemblers, and inbound OHS context facade & - & 05/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{faae260} & feat(inventory): implement application event handlers, transactional outbox publisher, and outbound ACL gateways & - & 05/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{90241e0} & feat(inventory): implement application command and query services with transactional orchestration & - & 05/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{26a0dcc} & feat(inventory): implement Spring Data repositories, persistence assemblers, and domain repository adapters & - & 05/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{98949d0} & feat(inventory): implement JPA persistence entities and attribute converters & - & 05/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{12576a3} & feat(inventory): implement domain commands, queries, domain services, and repository ports & - & 05/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{88e324e} & feat(inventory): implement domain aggregates and dependent entities with FIFO state machines & - & 05/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{e78bc33} & feat(inventory): define domain identifiers, value objects, and enumerations & - & 05/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{045fca8} & Merge tag '0.5.0' into develop & - & 05/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{0158586} & Merge branch 'release/\allowbreak 0.5.0' & - & 05/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{2bbe325} & Merge branch 'feature/\allowbreak workshop-operations' into develop & - & 05/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{f668308} & fix(operations): add autowired annotation to work order command service constructor & - & 05/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{598c185} & fix(operations): resolve task repository lookups, cascade persistence, outbox propagation, and bay releases & - & 05/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{a5a4152} & feat(operations): implement canonical REST controllers exposing 36 operations endpoints & - & 05/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{01d3cc4} & feat(operations): implement interface resources, assemblers, and inbound OHS context facade & - & 05/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{59d9554} & feat(operations): implement application event handlers, transactional outbox relays, and outbound ACL adapters & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{00db481} & feat(operations): implement application command and query services with deterministic orchestration & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{e454248} & feat(operations): implement Spring Data repositories, persistence assemblers, and domain repository adapters & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{41cfe07} & feat(operations): implement JPA persistence entities and attribute converters & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{e7c52b2} & feat(operations): implement domain commands, queries, domain services, and repository ports & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{180c1da} & feat(operations): implement domain aggregates and dependent entities with deterministic state machines & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{4e8af32} & feat(operations): define domain identifiers, value objects, and enumerations & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{38a737e} & Merge tag '0.4.0' into develop & feat(crm): release 0.4.0 with canonical CRM customer \& fleet domain and 22 endpoints 0.4.0 & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{2143f6c} & Merge branch 'release/\allowbreak 0.4.0' & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{2dd881d} & Merge branch 'feature/\allowbreak crm-customer-fleet' into develop & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{e393a87} & feat(crm): align interface and domain layers with 22 canonical endpoints & - & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{9e234cf} & fix(crm): enhance persistence entities and adapters for domain assigned identifiers & - & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{0711e4b} & feat(crm): implement REST interfaces, resources, assemblers, and ACL facade & - & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{48ca15d} & feat(crm): implement application command and query services with event handlers & - & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{ebcf712} & feat(crm): implement infrastructure persistence adapters and external clients & - & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{ddff895} & feat(crm): implement domain aggregates, value objects, domain events, and ports & - & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{e7b0607} & Merge pull request \#2 from upc-pre-202620-1acc0238-4951-andeva/\allowbreak develop & Merge tag '0.3.0' into develop & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{cfdf145} & Merge tag '0.3.0' into develop & version 0.3.0 & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{3bfa961} & Merge branch 'release/\allowbreak 0.3.0' & - & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{d120cfc} & Merge branch 'feature/\allowbreak external-billing' into develop \# Please enter a commit message to explain why this merge is necessary, \# especially if it merges an updated upstream into a topic branch. \# \# Lines starting with '\#' will be ignored, and an empty message aborts \# the commit. & - & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{8c39fe3} & feat(i18n): localize validation and exceptions. & Implement dynamic internationalization across Bean Validation annotations and REST exception handlers using Spring MessageSource and Accept-Language header resolution, supporting English and Spanish locales. & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{5f3cccc} & Merge pull request \#1 from upc-pre-202620-1acc0238-4951-andeva/\allowbreak develop & Merge tag '0.2.0' into develop & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{6f2efca} & Merge tag '0.2.0' into develop & version 0.2.0 & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{20b63ed} & Merge branch 'release/\allowbreak 0.2.0' & - & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{84b2297} & Merge branch 'feature/\allowbreak billing' into develop & \# Conflicts: \# src/\allowbreak main/\allowbreak java/\allowbreak com/\allowbreak andeva/\allowbreak atelier/\allowbreak platform/\allowbreak iam/\allowbreak infrastructure/\allowbreak external/\allowbreak quota/\allowbreak SubscriptionQuotaAdapter.java \# src/\allowbreak main/\allowbreak java/\allowbreak com/\allowbreak andeva/\allowbreak atelier/\allowbreak platform/\allowbreak iam/\allowbreak infrastructure/\allowbreak security/\allowbreak configuration/\allowbreak WebSecurit... & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{4a0d52d} & feat: integrate billing with IAM and security. & Connect the Billing bounded context with IAM and platform security, enabling Spring scheduling and caching annotations, wiring the SubscriptionQuotaAdapter to SubscriptionContextFacade, permitting billing webhook and... & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{69005a5} & feat(billing): add REST controllers and ACL. & Establish the Interfaces Layer for the Billing \& Subscriptions bounded context, delivering REST controllers for subscription plans, tenant subscriptions, SaaS invoices, and Stripe webhook handling, along with... & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{a523591} & feat(billing): implement infrastructure layer. & Establish the Infrastructure Layer for the Billing \& Subscriptions bounded context, implementing Stripe payment gateway and webhook verification adapters, Caffeine quota caching, Resend email notifications, JPA... & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{c9db48d} & feat(billing): implement application services. & Implement the Application Layer for the Billing \& Subscriptions bounded context, delivering CQRS command and query services for plans, tenant subscriptions, SaaS invoices, Stripe webhook idempotency, event handlers,... & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{e5c3544} & feat(billing): implement domain layer components. & Introduce the DDD Domain Layer for the Billing \& Subscriptions bounded context, providing aggregates, entities, value objects, domain services, domain events, CQRS command/\allowbreak query records, exceptions, and repository... & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{4fd25c6} & feat(iam): add localized domain error messages. & Add internationalized (i18n) error message translations in English and Spanish for all IAM and Tenancy domain exceptions, including tenants, branches, users, authentication credentials, verification tokens, roles,... & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{159ce6b} & feat(shared): add Result and TaxId helpers. & Enhance Result monad with getOrThrow() and getError() convenience methods, and introduce TaxId.of(value) factory method with automatic type inference for Peruvian DNI and RUC identification documents. & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{b6dad09} & feat(iam): implement REST controllers and ACL. & Establish the Interfaces Layer for the IAM bounded context, delivering REST controllers with OpenAPI documentation, request/\allowbreak response DTO resources, command/\allowbreak resource assemblers, outbound integration events, and the... & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{2dfa141} & feat(iam): implement infrastructure and security. & Establish the Infrastructure Layer for the IAM bounded context, providing Spring Security with JWT Bearer authentication, external adapters for Resend email and Google OAuth, JPA persistence entities, Spring Data... & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{7a9b3c2} & feat(iam): implement application layer services. & Implement the Application Layer for the IAM bounded context, providing CQRS command and query services for tenants, users, roles, memberships, branches, and invitations, along with anti-corruption layer facades,... & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{5f47e96} & feat(iam): implement domain layer components. & Introduce the DDD Domain Layer for the Identity \& Access Management (IAM) bounded context, implementing aggregates, entities, value objects, domain events, CQRS command/\allowbreak query records, exceptions, and repository... & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{e775b7a} & feat(iam): add localized domain error messages. & Add internationalized (i18n) error message translations in English and Spanish for all IAM and Tenancy domain exceptions, including tenants, branches, users, authentication credentials, verification tokens, roles,... & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{2291afc} & feat(shared): add Result and TaxId helpers. & Enhance Result monad with getOrThrow() and getError() convenience methods, and introduce TaxId.of(value) factory method with automatic type inference for Peruvian DNI and RUC identification documents. & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{f20089d} & feat(iam): implement REST controllers and ACL. & Establish the Interfaces Layer for the IAM bounded context, delivering REST controllers with OpenAPI documentation, request/\allowbreak response DTO resources, command/\allowbreak resource assemblers, outbound integration events, and the... & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{a0a32e2} & feat(iam): implement infrastructure and security. & Establish the Infrastructure Layer for the IAM bounded context, providing Spring Security with JWT Bearer authentication, external adapters for Resend email and Google OAuth, JPA persistence entities, Spring Data... & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{75ea030} & feat(iam): implement application layer services. & Implement the Application Layer for the IAM bounded context, providing CQRS command and query services for tenants, users, roles, memberships, branches, and invitations, along with anti-corruption layer facades,... & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{12e8c6c} & feat(iam): implement domain layer components. & Introduce the DDD Domain Layer for the Identity \& Access Management (IAM) bounded context, implementing aggregates, entities, value objects, domain events, CQRS command/\allowbreak query records, exceptions, and repository... & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{21bda4d} & Merge tag '0.1.0' into develop & version 0.1.0 & 02/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{bc6832f} & Merge branch 'release/\allowbreak 0.1.0' & - & 02/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{8ae502b} & Merge branch 'feature/\allowbreak shared' into develop & - & 02/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{a7e045c} & docs: add javadoc to main application class. & Add class-level Javadoc with author attribution to the primary Spring Boot application entry point class. & 02/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{852cf82} & feat(shared): implement REST interfaces layer. & Establish the REST Interfaces Layer for the Shared Kernel bounded context, introducing RFC 7807 compliant error responses, correlation ID request tracing via servlet filter, centralized GlobalExceptionHandler, and... & 02/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{54b4382} & feat(shared): implement infrastructure layer. & Establish the Infrastructure Layer for the Shared Kernel bounded context, featuring JPA persistence base classes and attribute converters, a transactional Outbox pattern event publisher, OpenAPI 3.0 configuration,... & 02/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{6f63ac8} & feat(shared): add CQRS handlers and Result type. & Introduce the Application Layer abstractions for the Shared Kernel, including CQRS command and query handler contracts, domain event publishing interfaces, functional Result and ApplicationError types, and pagination... & 02/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{7fe4056} & feat(shared): add domain model and value objects. & Introduce the DDD Domain Layer for the Shared Kernel bounded context, providing base domain event abstractions, domain exceptions, an abstract aggregate root with event registration, and foundational immutable value... & 02/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{9ceaf1c} & chore: ignore codegraph and superpowers folders. & Add .codegraph and .superpowers tooling artifacts and metadata directories to .gitignore to prevent accidental repository tracking. & 02/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{4045030} & feat(shared): configure docker and i18n bundles & Configure local database container infrastructure with TimescaleDB, set up internationalization (i18n) error messages for the Shared Kernel, update JPA physical naming strategy, and prune obsolete docs. & 02/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{9fd0b84} & initial commit & - & 02/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{7fb8374} & initial commit & - & 02/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{88c171f} & Initial commit & - & 02/\allowbreak 10/\allowbreak 2026 \\
\hline
\end{longtable}
\endgroup


*Nota.* Registro cronológico de commits de implementación para los servicios web del backend en atelier-platform.


#### 4.2.1.5. Testing Suite Evidence for Sprint Review

Para asegurar la solidez arquitectónica, el cumplimiento de las invariantes de negocio y la ausencia de regresiones en los servicios web, el equipo implementó una estrategia integral de aseguramiento de la calidad automatizada durante el primer ciclo constructivo. Esta estrategia se articula sobre la pirámide de pruebas mediante suites unitarias, suites de integración con infraestructura real y pruebas de aceptación orientadas a comportamiento bajo la metodología Behavior-Driven Development.

El repositorio oficial que alberga la infraestructura de pruebas automatizadas y el código fuente de los servicios se encuentra disponible en GitHub a través del siguiente enlace:

- **Repositorio de Pruebas Automatizadas (Atelier Platform):** [https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier-platform](https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier-platform) en el directorio `src/test/java`.

El ecosistema de pruebas automatizadas del backend se diseñó utilizando el framework JUnit 5 en conjunto con Mockito, AssertJ, Spring Boot Test y la biblioteca Testcontainers. Esta última permite instanciar contenedores efímeros de PostgreSQL 16 y TimescaleDB durante la ejecución del ciclo de pruebas, posibilitando que las consultas JPA complejas, las funciones de agregación temporal y los procedimientos transaccionales se verifiquen contra un motor relacional real en lugar de emulaciones en memoria.

La suite automatizada abarca un total de ciento noventa y ocho clases de prueba organizadas según la estructura modular de Bounded Contexts:

- **Shared Kernel (15 clases de prueba):** Verifican los manejadores de comandos y consultas del bus CQRS, los objetos de valor inmutables comunes, las entidades auditables con sellos temporales, el patrón transaccional Outbox, la paginación normalizada y los filtros de correlación en solicitudes HTTP.
- **Identity and Access Management (30 clases de prueba):** Validan la autenticación de usuarios con tokens JWT, el aprovisionamiento de organizaciones inquilinas, la verificación de correos con códigos OTP de seis dígitos, la emisión de invitaciones corporativas de personal y el cálculo perimétrico de geocercas en sucursales.
- **Customer Relationship Management (12 clases de prueba):** Evalúan el registro de clientes con validación de identidad por DNI, el alta de vehículos con homologación de número de identificación vehicular bajo la norma ISO 3779, y el agendamiento formal de citas de mantenimiento.
- **Workshop Operations (8 clases de prueba):** Verifican la apertura de órdenes de trabajo, la conmutación y asignación de bahías de servicio, el cronometraje de faenas técnicas efectivas y la incorporación de repuestos a tareas.
- **Inventory and Supply Chain (24 clases de prueba):** Aseguran el comportamiento del motor contable de valoración y requisición por capas FIFO, el control de umbrales críticos de existencias y el ingreso de lotes de repuestos con costo unitario de adquisición.
- **Human Resources and Staff Management (24 clases de prueba):** Validan la marcación geodésica de jornada laboral empleando la fórmula del semiverseno o Haversine, la tolerancia de distancia respecto a la sucursal y la inmutabilidad de los registros de asistencia.
- **Invoicing and Compliance (24 clases de prueba):** Comprueban el motor de liquidación tributaria, la generación de comprobantes de pago electrónicos bajo el formato UBL 2.1 para la SUNAT, el registro transaccional de pagos y la emisión del estado de flujo de caja en formato PDF.
- **IoT Telemetry and Predictive Maintenance (31 clases de prueba):** Evalúan la ingesta masiva de paquetes telemáticos en hipertablas de TimescaleDB, la catalogación de códigos de avería electrónica OBD-II, y la generación pericial de informes de salud vehicular con asistencia de inteligencia artificial predictiva mediante Spring AI.
- **SaaS Billing and Subscriptions (29 clases de prueba):** Verifican los planes de suscripción, las cuotas de uso por taller, la simulación de cobros recurrentes y el procesamiento asíncrono de eventos de pasarela de pago.
- **Contexto de Aplicación (1 clase de prueba):** Certifica la inicialización coherente del contenedor de inyección de dependencias y la configuración de contexto de Spring Boot.

**Especificación de Pruebas de Aceptación BDD (Gherkin Feature Files)**

Para formalizar los criterios de aceptación de las historias de usuario implementadas en el sprint, el equipo elaboró las especificaciones de comportamiento en lenguaje Gherkin. Estas definiciones documentan de forma ejecutable los escenarios de éxito y las excepciones de negocio previstas para los servicios:

```gherkin
Feature: Registro fundacional de organizacion e inquilino (US01)
  Como propietario de taller mecanico automotriz
  Quiero registrar mi cuenta corporativa y los datos de mi taller
  Para acceder a los servicios de gestion operativa de Atelier

  Scenario: Registro exitoso de nuevo inquilino con credenciales validas
    Given que el RUC "20601234567" no se encuentra registrado en la plataforma
    And que el correo electronico "admin@tallerperez.pe" esta disponible
    When el propietario envia la solicitud de registro con datos validos
    Then el sistema crea la organizacion con estado pendiente de activacion
    And despacha un codigo de verificacion OTP de 6 digitos al correo registrado
    And responde con el codigo de estado HTTP 201 Created

  Scenario: Intento de registro con RUC corporativo duplicado
    Given que existe una organizacion registrada con el RUC "20601234567"
    When el propietario solicita el registro con dicho RUC
    Then el sistema rechaza la transaccion por conflicto de identidad
    And responde con el codigo de estado HTTP 409 Conflict y detalle estandarizado RFC 7807
```

```gherkin
Feature: Registro de vehiculo con homologacion de VIN (US02)
  Como recepcionista del taller automotriz
  Quiero registrar los datos tecnicos del vehiculo vinculado al cliente
  Para habilitar la apertura de ordenes de trabajo y seguimiento de mantenimiento

  Scenario: Registro exitoso de vehiculo con VIN valido segun norma ISO 3779
    Given un cliente previamente registrado con identificador valido
    And una placa automotriz "ABC-123" que no registra duplicidad en el taller
    When el recepcionista registra el vehiculo con VIN "1HGCR2F83HA123456" de 17 caracteres
    Then el sistema valida la estructura del VIN y almacena la ficha tecnica
    And vincula la propiedad del vehiculo al cliente especificado
    And responde con el codigo de estado HTTP 201 Created

  Scenario: Rechazo de registro por estructura de VIN invalida
    Given un cliente registrado en la sucursal activa
    When el recepcionista ingresa un VIN con longitud menor a 17 caracteres alfanumericos
    Then el sistema interrumpe el procesamiento por error de validacion de formato
    And responde con el codigo de estado HTTP 422 Unprocessable Entity
```

```gherkin
Feature: Requisicion y descargo de repuestos bajo metodo FIFO (US04)
  Como jefe de taller o mecanico asignado
  Quiero requisar piezas de repuesto para una orden de trabajo activa
  Para descargar el inventario valorizando el costo segun el orden cronologico de compra

  Scenario: Descargo automatico consumiendo el lote con mayor antiguedad
    Given un repuesto con inventario disponible en dos lotes de compra
    And el lote "LOTE-001" ingreso primero con costo unitario de 50.00 PEN y 5 unidades
    And el lote "LOTE-002" ingreso despues con costo unitario de 55.00 PEN y 10 unidades
    When el mecanico solicita 3 unidades del repuesto para la tarea operativa
    Then el sistema descuenta las 3 unidades exclusivamente del lote "LOTE-001"
    And asigna un costo unitario de 50.00 PEN a la requisicion de la orden
    And actualiza el saldo disponible del lote "LOTE-001" a 2 unidades
    And responde con el codigo de estado HTTP 201 Created
```

**Registro de Commits de Pruebas Automatizadas**

La @tbl:testing-evidence-commits presenta la relación cronológica de los catorce commits etiquetados expresamente para el diseño, refactorización y ejecución de la suite de pruebas unitarias y de integración en el repositorio de la plataforma backend.

\begingroup
\scriptsize
\setlength{\tabcolsep}{2.5pt}
\renewcommand{\arraystretch}{1.15}
\begin{longtable}{| >{\raggedright\arraybackslash}p{2.6cm} | >{\centering\arraybackslash}p{1.4cm} | >{\centering\arraybackslash}p{1.6cm} | >{\raggedright\arraybackslash}p{4.4cm} | >{\raggedright\arraybackslash}p{3.4cm} | >{\centering\arraybackslash}p{1.8cm} |}
\caption{Registro de Commits de Pruebas Automatizadas (Sprint 1)} \label{tbl:testing-evidence-commits} \\
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
andeva-upc/\allowbreak atelier-platform & main & \texttt{15dd3a4} & test: add unit tests for CRM, HR and Operations. & Implement comprehensive unit test coverage across CRM, Human Resources, Inventory, and Workshop Operations bounded contexts, verifying ACL context facades, domain services, external adapters, event handlers, and REST... & 08/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{eb97155} & test: add unit tests for Invoicing and IoT. & Implement comprehensive automated unit test coverage across all layers of the Invoicing \& Compliance and IoT Telemetry \& Predictive Maintenance bounded contexts, and update controller tests for subscriptions,... & 07/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{ba9f0af} & test(inventory): implement comprehensive domain, aggregate, FIFO engine, and application unit test suite & - & 05/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{a6bac4d} & test(operations): implement comprehensive domain, aggregate, and application unit test suite & - & 05/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{80635fd} & test(crm): remove REST endpoint simulation integration tests & - & 04/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{de53548} & test(crm): remove internal database persistence integration tests & - & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{01ec190} & test(crm): add end-to-end HTTP REST endpoint integration test with PostgreSQL persistence & - & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{4eb26dd} & test(crm): add REST controller endpoint simulation integration test suite & - & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{2932514} & test(crm): add end-to-end database persistence integration test suite & - & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{6e6138e} & test(crm): implement comprehensive unit and aggregate test suites & - & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{1378db4} & test(billing): add comprehensive test suite. & Implement full unit test coverage across all layers of the Billing \& Subscriptions bounded context (Domain, Application, Infrastructure, and Interfaces) verifying plan aggregates, subscription lifecycles, quota... & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{4a71c67} & test(iam): add comprehensive unit test suite. & Implement full unit test coverage across all layers of the IAM bounded context, verifying domain aggregates and business invariants, CQRS command/\allowbreak query services, TenancyContextFacade ACL, persistence adapters and... & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{debd8b3} & test(iam): add comprehensive unit test suite. & Implement full unit test coverage across all layers of the IAM bounded context, verifying domain aggregates and business invariants, CQRS command/\allowbreak query services, TenancyContextFacade ACL, persistence adapters and... & 03/\allowbreak 10/\allowbreak 2026 \\
\hline
andeva-upc/\allowbreak atelier-platform & main & \texttt{22cdefd} & test(shared): add unit tests for shared kernel. & Implement comprehensive automated unit test coverage across all layers of the Shared Kernel bounded context (Domain, Application, Infrastructure, and Interfaces) verifying value objects, CQRS handlers, Result monad,... & 02/\allowbreak 10/\allowbreak 2026 \\
\hline
\end{longtable}
\endgroup


*Nota.* Registro cronológico de commits etiquetados para la suite de pruebas automatizadas en el repositorio atelier-platform.


#### 4.2.1.6. Execution Evidence for Sprint Review

Durante el primer ciclo constructivo, el equipo completó la puesta en marcha operativa y la verificación funcional de los dos componentes principales de la solución: el portal comercial de la solución denominado Atelier Workshop y la plataforma de servicios web del backend denominada Atelier Platform. Ambos productos fueron desplegados en entornos de producción en la nube accesibles públicamente, permitiendo validar la experiencia de navegación del usuario, la coherencia visual del sistema de diseño y la operatividad de los servicios web en tiempo real.

En el ámbito del portal web, se desplegó la versión funcional de la página de aterrizaje en el dominio de producción \texttt{https://atelier.andeva.tech}. La interfaz implementa una arquitectura responsiva orientada a la conversión de talleres mecánicos automotrices, integrando la paleta cromática oficial de la marca, las fuentes tipográficas Satoshi y Albert Sans, un selector de idioma bilingüe y un conmutador de tema visual entre modos claro y oscuro. La vista presenta de forma estructurada la propuesta de valor de la plataforma, destacando el diagnóstico computarizado con escáneres OBD-II, el control de repuestos bajo el método contable FIFO y la emisión de comprobantes fiscales electrónicos válidos ante la SUNAT, tal como se ilustra en la @fig:execution-evidence-website.

![Vista principal y propuesta de valor del portal comercial Atelier Workshop en entorno de producción](report/assets/deploy/result-deploy-website.png){#fig:execution-evidence-website}

*Nota.* Captura de pantalla de la interfaz comercial desplegada en el dominio de producción, ilustrando la navegación principal, la propuesta de valor y las maquetas de la aplicación móvil.

En el ámbito de la plataforma de servicios web, se verificó la disponibilidad y el correcto funcionamiento del backend a través de la consola interactiva Swagger UI, desplegada en el entorno de producción \texttt{https://atelier-platform.onrender.com/swagger-ui/index.html}. La interfaz permite a los desarrolladores y evaluadores interactuar directamente con los endpoints de la API, enviar solicitudes HTTP con cabeceras de autorización Bearer basadas en tokens JWT y examinar las respuestas estructuradas en formato JSON. La @fig:execution-evidence-platform exhibe la consola interactiva evidenciando la operatividad de los módulos de alertas de inventario para el reabastecimiento de piezas, la configuración de series fiscales para comprobantes de pago y la gestión de membresías de personal con asignación de roles de seguridad.

![Consola interactiva de servicios web Swagger UI para Atelier Platform en entorno de producción](report/assets/deploy/result-deploy-platform-2.png){#fig:execution-evidence-platform width=70%}

*Nota.* Captura de pantalla de la consola interactiva Swagger UI desplegada en Render, evidenciando los endpoints operativos de alertas de inventario, series de facturación y miembros del personal.

Con el propósito de exhibir de manera dinámica y detallada la navegación, interactividad y ejecución de los productos desarrollados durante el primer ciclo constructivo, el equipo grabó una demostración audiovisual completa.

- **Enlace al Video Demostrativo del Sprint 1:** [SPRINT-1](https://upcedupe-my.sharepoint.com/:v:/g/personal/u20241e275_upc_edu_pe/IQCD-Gn0wBCBTYaWOn8opD3sAaPClZ4085AzEHxwfyMSRVI?nav=eyJyZWZlcnJhbEluZm8iOnsicmVmZXJyYWxBcHAiOiJPbmVEcml2ZUZvckJ1c2luZXNzIiwicmVmZXJyYWxBcHBQbGF0Zm9ybSI6IldlYiIsInJlZmVycmFsTW9kZSI6InZpZXciLCJyZWZlcnJhbFZpZXciOiJNeUZpbGVzTGlua0NvcHkifX0&e=cLtbjZ)

\newpage

#### 4.2.1.7. Services Documentation Evidence for Sprint Review

Durante el primer ciclo de desarrollo, el equipo completó la especificación técnica y documentación interactiva de la totalidad de los servicios web del backend de Atelier Platform. Esta infraestructura se encuentra estandarizada bajo la especificación OpenAPI 3.1 y se expone interactivamente mediante la interfaz Swagger UI a través de la biblioteca Springdoc OpenAPI (`springdoc-openapi-starter-webmvc-ui`).

La documentación abarca veinticuatro endpoints canónicos distribuidos en los ocho Bounded Contexts del backend, definiendo de forma exhaustiva los esquemas de transferencia DTO, las cabeceras de autorización con tokens JWT, los parámetros de consulta y ruta, los códigos de estado HTTP y los modelos de error estandarizados bajo el formato RFC 7807 (`ProblemDetail`).

El repositorio oficial que alberga la implementación y la configuración de los servicios web se encuentra disponible en GitHub a través del siguiente enlace:

- **Repositorio de Web Services (Atelier Platform Backend):** [https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier-platform](https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier-platform)

Asimismo, el entorno de exploración interactivo de la API en producción se encuentra desplegado y accesible públicamente bajo la siguiente dirección:

- **Consola Interactiva Swagger UI en Producción:** [https://atelier-platform.onrender.com/swagger-ui/index.html](https://atelier-platform.onrender.com/swagger-ui/index.html)

La @tbl:services-documentation-1 presenta la relación completa de los veinticuatro endpoints RESTful documentados en el Sprint 1, detallando las acciones implementadas, los métodos HTTP, las rutas de acceso, la especificación de parámetros de entrada, los formatos de respuesta y el enlace directo hacia la operación en Swagger UI en el entorno de producción.

\begingroup
\scriptsize
\setlength{\tabcolsep}{2.5pt}
\renewcommand{\arraystretch}{1.15}
\begin{longtable}{| >{\raggedright\arraybackslash}p{2.3cm} | >{\raggedright\arraybackslash}p{3.5cm} | >{\raggedright\arraybackslash}p{3.2cm} | >{\raggedright\arraybackslash}p{4.4cm} | >{\centering\arraybackslash}p{2.1cm} |}
\caption{Catálogo de Endpoints RESTful y Especificación OpenAPI del Sprint 1} \label{tbl:services-documentation-1} \\
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{2.3cm}|}{\textbf{Endpoint / Acción}} & \multicolumn{1}{>{\centering\arraybackslash}p{3.5cm}|}{\textbf{Método y Ruta}} & \multicolumn{1}{>{\centering\arraybackslash}p{3.2cm}|}{\textbf{Parámetros de Entrada}} & \multicolumn{1}{>{\centering\arraybackslash}p{4.4cm}|}{\textbf{Respuesta y Código HTTP}} & \multicolumn{1}{>{\centering\arraybackslash}p{2.1cm}|}{\textbf{Enlace OpenAPI}} \\
\hline
\endfirsthead
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{2.3cm}|}{\textbf{Endpoint / Acción}} & \multicolumn{1}{>{\centering\arraybackslash}p{3.5cm}|}{\textbf{Método y Ruta}} & \multicolumn{1}{>{\centering\arraybackslash}p{3.2cm}|}{\textbf{Parámetros de Entrada}} & \multicolumn{1}{>{\centering\arraybackslash}p{4.4cm}|}{\textbf{Respuesta y Código HTTP}} & \multicolumn{1}{>{\centering\arraybackslash}p{2.1cm}|}{\textbf{Enlace OpenAPI}} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
\multicolumn{5}{|l|}{\textbf{Bounded Context 1: Identity and Access Management (IAM) \& Tenancy}} \\
\hline
TS01: Autenticación de credenciales de usuario & \texttt{POST} \newline \texttt{/api/v1/auth/} \newline \texttt{sign-in} & Body JSON: \newline \texttt{email}, \texttt{password} & \texttt{200 OK} \newline \textbf{AuthenticatedUserResource:} \newline \texttt{id}, \texttt{fullName}, \texttt{email}, \texttt{role}, \texttt{tenantId}, \texttt{token}, \texttt{refreshToken} & \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/Authentication/signIn}{\texttt{auth/sign-in}} \\
\hline
TS02: Registro fundacional de organización e inquilino & \texttt{POST} \newline \texttt{/api/v1/auth/} \newline \texttt{sign-up} & Body JSON: \newline \texttt{ruc}, \texttt{businessName}, \texttt{ownerFirstName}, \texttt{ownerLastName}, \texttt{ownerEmail}, \texttt{password} & \texttt{201 Created} \newline \textbf{TenantResource:} \newline \texttt{id}, \texttt{ruc}, \texttt{businessName}, \texttt{status}, \texttt{createdAt} & \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/Authentication/signUp}{\texttt{auth/sign-up}} \\
\hline
TS03: Verificación de correo mediante código OTP & \texttt{POST} \newline \texttt{/api/v1/auth/} \newline \texttt{verify-email} & Body JSON: \newline \texttt{email}, \texttt{otpCode} (6 dígitos) & \texttt{200 OK} \newline \textbf{MessageResponseResource:} \newline mensaje de confirmación y estado de activación & \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/Authentication/verifyEmail}{\texttt{auth/verify-email}} \\
\hline
TS04: Despacho de invitaciones corporativas de personal & \texttt{POST} \newline \texttt{/api/v1/invitations/} \newline \texttt{tenant/\{tenantId\}} & Header: \texttt{Authorization} \newline Path: \texttt{tenantId} (UUID) \newline Body JSON: \texttt{email}, \texttt{roleName}, \texttt{branchId} & \texttt{201 Created} \newline \textbf{InvitationResource:} \newline \texttt{id}, \texttt{email}, \texttt{roleName}, \texttt{token}, \texttt{status}, \texttt{expiresAt} & \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/Invitations/inviteStaff}{\texttt{invitations/}} \newline \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/Invitations/inviteStaff}{\texttt{invite}} \\
\hline
TS05: Alta de sucursales con geocercas Haversine & \texttt{POST} \newline \texttt{/api/v1/branches} & Header: \texttt{Authorization} \newline Body JSON: \texttt{name}, \texttt{address}, \texttt{latitude}, \texttt{longitude}, \texttt{geofenceRadiusMeters} & \texttt{201 Created} \newline \textbf{BranchResource:} \newline \texttt{id}, \texttt{name}, \texttt{address}, \texttt{latitude}, \texttt{longitude}, \texttt{radiusMeters} & \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/Branches/createBranch}{\texttt{branches/}} \newline \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/Branches/createBranch}{\texttt{create}} \\
\hline
\multicolumn{5}{|l|}{\textbf{Bounded Context 2: Customer Relationship Management (CRM) \& Fleet}} \\
\hline
TS06: Alta de clientes individuales con DNI & \texttt{POST} \newline \texttt{/api/v1/customers/} \newline \texttt{individuals} & Header: \texttt{Authorization} \newline Body JSON: \texttt{documentNumber} (DNI), \texttt{firstName}, \texttt{lastName}, \texttt{email}, \texttt{phoneNumber} & \texttt{201 Created} \newline \textbf{CustomerResource:} \newline \texttt{id}, \texttt{fullName}, \texttt{documentNumber}, \texttt{email}, \texttt{phone}, \texttt{status} & \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/Customers/registerIndividualCustomer}{\texttt{customers/}} \newline \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/Customers/registerIndividualCustomer}{\texttt{indiv}} \\
\hline
TS07: Registro técnico de vehículos con VIN y placa & \texttt{POST} \newline \texttt{/api/v1/vehicles} & Header: \texttt{Authorization} \newline Body JSON: \texttt{plate}, \texttt{vin} (ISO 3779), \texttt{brand}, \texttt{model}, \texttt{year}, \texttt{customerId} & \texttt{201 Created} \newline \textbf{VehicleResource:} \newline \texttt{id}, \texttt{plate}, \texttt{vin}, \texttt{brand}, \texttt{model}, \texttt{year}, \texttt{currentOwnerId} & \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/Vehicles/registerVehicle}{\texttt{vehicles/}} \newline \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/Vehicles/registerVehicle}{\texttt{create}} \\
\hline
TS08: Agendamiento de citas de mantenimiento & \texttt{POST} \newline \texttt{/api/v1/appointments} & Header: \texttt{Authorization} \newline Body JSON: \texttt{customerId}, \texttt{vehicleId}, \texttt{branchId}, \texttt{scheduledAt}, \texttt{notes} & \texttt{201 Created} \newline \textbf{AppointmentResource:} \newline \texttt{id}, \texttt{customerId}, \texttt{vehicleId}, \texttt{branchId}, \texttt{scheduledAt}, \texttt{status} & \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/Appointments/scheduleAppointment}{\texttt{appointments/}} \newline \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/Appointments/scheduleAppointment}{\texttt{new}} \\
\hline
TS09: Arribo a patio y apertura de orden & \texttt{POST} \newline \texttt{/api/v1/appointments/} \newline \texttt{\{id\}/arrive} & Header: \texttt{Authorization} \newline Path: \texttt{id} (UUID cita) \newline Body JSON: \texttt{mileage}, \texttt{fuelLevel} & \texttt{200 OK} \newline \textbf{AppointmentArrivalResource:} \newline \texttt{appointmentId}, \texttt{arrivedAt}, \texttt{generatedWorkOrderId} & \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/Appointments/recordArrival}{\texttt{appointments/}} \newline \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/Appointments/recordArrival}{\texttt{arrive}} \\
\hline
\multicolumn{5}{|l|}{\textbf{Bounded Context 3: Workshop Operations (MRO)}} \\
\hline
TS10: Apertura de órdenes de trabajo en taller & \texttt{POST} \newline \texttt{/api/v1/work-orders} & Header: \texttt{Authorization} \newline Body JSON: \texttt{vehicleId}, \texttt{customerId}, \texttt{branchId}, \texttt{mileage}, \texttt{diagnosisNotes} & \texttt{201 Created} \newline \textbf{WorkOrderResource:} \newline \texttt{id}, \texttt{orderNumber}, \texttt{vehicleId}, \texttt{status}, \texttt{openedAt} & \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/WorkOrders/createWorkOrder}{\texttt{orders/}} \newline \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/WorkOrders/createWorkOrder}{\texttt{create}} \\
\hline
TS11: Asignación y conmutación de bahías & \texttt{PUT} \newline \texttt{/api/v1/work-orders/} \newline \texttt{\{id\}/bay} & Header: \texttt{Authorization} \newline Path: \texttt{id} (UUID orden) \newline Body JSON: \texttt{bayId} (UUID bahía) & \texttt{200 OK} \newline \textbf{WorkOrderResource:} \newline \texttt{id}, \texttt{orderNumber}, \texttt{assignedBayId}, \texttt{bayAssignedAt}, \texttt{status} & \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/WorkOrders/assignBay}{\texttt{orders/assign-}} \newline \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/WorkOrders/assignBay}{\texttt{bay}} \\
\hline
TS12: Incorporación de tareas a orden de trabajo & \texttt{POST} \newline \texttt{/api/v1/work-orders/} \newline \texttt{\{id\}/tasks} & Header: \texttt{Authorization} \newline Path: \texttt{id} (UUID orden) \newline Body JSON: \texttt{serviceId}, \texttt{description}, \texttt{mechanicId}, \texttt{estimatedMinutes} & \texttt{201 Created} \newline \textbf{TaskResource:} \newline \texttt{id}, \texttt{workOrderId}, \texttt{description}, \texttt{mechanicId}, \texttt{status}, \texttt{estimatedMinutes} & \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/WorkOrders/addTask}{\texttt{orders/}} \newline \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/WorkOrders/addTask}{\texttt{add-task}} \\
\hline
TS13: Control cronometrado y cierre de faenas & \texttt{POST} \newline \texttt{/api/v1/tasks/} \newline \texttt{\{id\}/complete} & Header: \texttt{Authorization} \newline Path: \texttt{id} (UUID tarea) \newline Body JSON: \texttt{technicalObservations}, \texttt{completionTimestamp} & \texttt{200 OK} \newline \textbf{TaskResource:} \newline \texttt{id}, \texttt{status}: COMPLETED, \texttt{effectiveDurationMinutes}, \texttt{completedAt} & \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/Tasks/completeTask}{\texttt{tasks/}} \newline \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/Tasks/completeTask}{\texttt{complete}} \\
\hline
TS14: Requisición de repuestos bajo método FIFO & \texttt{POST} \newline \texttt{/api/v1/tasks/} \newline \texttt{\{id\}/products} & Header: \texttt{Authorization} \newline Path: \texttt{id} (UUID tarea) \newline Body JSON: \texttt{inventoryItemId}, \texttt{quantity} & \texttt{201 Created} \newline \textbf{TaskProductResource:} \newline \texttt{id}, \texttt{taskId}, \texttt{inventoryItemId}, \texttt{quantity}, \texttt{allocatedBatchId}, \texttt{unitCost} & \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/Tasks/addTaskProduct}{\texttt{tasks/add-}} \newline \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/Tasks/addTaskProduct}{\texttt{product}} \\
\hline
\multicolumn{5}{|l|}{\textbf{Bounded Context 4: Inventory \& Supply Chain}} \\
\hline
TS15: Catálogo de repuestos y umbrales críticos & \texttt{POST} \newline \texttt{/api/v1/inventory/} \newline \texttt{items} & Header: \texttt{Authorization} \newline Body JSON: \texttt{sku}, \texttt{name}, \texttt{brand}, \texttt{unitPrice}, \texttt{minimumThreshold} & \texttt{201 Created} \newline \textbf{InventoryItemResource:} \newline \texttt{id}, \texttt{sku}, \texttt{name}, \texttt{unitPrice}, \texttt{stockQuantity}, \texttt{minimumThreshold} & \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/InventoryItems/createInventoryItem}{\texttt{inventory/}} \newline \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/InventoryItems/createInventoryItem}{\texttt{items}} \\
\hline
TS16: Ingreso de lotes valorizados por adquisición & \texttt{POST} \newline \texttt{/api/v1/inventory/} \newline \texttt{items/\{id\}/batches} & Header: \texttt{Authorization} \newline Path: \texttt{id} (UUID repuesto) \newline Body JSON: \texttt{batchNumber}, \texttt{quantity}, \texttt{unitCost}, \texttt{supplierId}, \texttt{acquiredAt} & \texttt{201 Created} \newline \textbf{InventoryBatchResource:} \newline \texttt{id}, \texttt{itemId}, \texttt{batchNumber}, \texttt{quantityAvailable}, \texttt{unitCost}, \texttt{valuationMethod} & \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/InventoryBatches/addBatch}{\texttt{inventory/}} \newline \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/InventoryBatches/addBatch}{\texttt{batches}} \\
\hline
\multicolumn{5}{|l|}{\textbf{Bounded Context 5: Human Resources \& Staff Management}} \\
\hline
TS17: Marcación geodésica con validación Haversine & \texttt{POST} \newline \texttt{/api/v1/hr/} \newline \texttt{attendances/clock-in} & Header: \texttt{Authorization} \newline Body JSON: \texttt{branchId}, \texttt{latitude}, \texttt{longitude}, \texttt{timestamp} & \texttt{201 Created} \newline \textbf{AttendanceResource:} \newline \texttt{id}, \texttt{staffId}, \texttt{clockInTime}, \texttt{geofenceValidated}, \texttt{distanceMeters}, \texttt{status} & \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/Attendance/recordClockIn}{\texttt{hr/clock-in}} \\
\hline
\multicolumn{5}{|l|}{\textbf{Bounded Context 6: Invoicing \& Compliance}} \\
\hline
TS18: Emisión de comprobantes electrónicos UBL 2.1 & \texttt{POST} \newline \texttt{/api/v1/invoicing/} \newline \texttt{vouchers} & Header: \texttt{Authorization} \newline Body JSON: \texttt{workOrderId}, \texttt{voucherType}, \texttt{series}, \texttt{customerDoc}, \texttt{items} & \texttt{201 Created} \newline \textbf{ElectronicVoucherResource:} \newline \texttt{id}, \texttt{series}, \texttt{number}, \texttt{totalAmount}, \texttt{hashSunat}, \texttt{sunatStatus} & \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/ElectronicVouchers/issueVoucher}{\texttt{invoicing/}} \newline \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/ElectronicVouchers/issueVoucher}{\texttt{vouchers}} \\
\hline
TS19: Registro de pagos y liquidación de facturas & \texttt{POST} \newline \texttt{/api/v1/invoicing/} \newline \texttt{payments} & Header: \texttt{Authorization} \newline Body JSON: \texttt{voucherId}, \texttt{paymentMethod}, \texttt{amount}, \texttt{referenceCode} & \texttt{201 Created} \newline \textbf{PaymentResource:} \newline \texttt{id}, \texttt{voucherId}, \texttt{amount}, \texttt{paymentMethod}, \texttt{balanceRemaining}, \texttt{settledAt} & \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/VoucherPayments/recordPayment}{\texttt{invoicing/}} \newline \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/VoucherPayments/recordPayment}{\texttt{payments}} \\
\hline
TS23: Exportación de flujo de caja en formato PDF & \texttt{GET} \newline \texttt{/api/v1/invoicing/} \newline \texttt{financial-reports/} \newline \texttt{cash-flow/pdf} & Header: \texttt{Authorization} \newline Query: \texttt{branchId}, \texttt{startDate}, \texttt{endDate} & \texttt{200 OK} \newline \texttt{application/pdf}: \newline flujo binario del documento de balance financiero consolidado & \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/FinancialReports/exportCashFlowPdf}{\texttt{invoicing/}} \newline \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/FinancialReports/exportCashFlowPdf}{\texttt{cash-flow}} \\
\hline
\multicolumn{5}{|l|}{\textbf{Bounded Context 7: IoT Telemetry \& Predictive Maintenance}} \\
\hline
TS20: Ingesta masiva telemática en series temporales & \texttt{POST} \newline \texttt{/api/v1/iot/} \newline \texttt{telemetry/batch} & Header: \texttt{Authorization} \newline Body JSON: \texttt{deviceIdentifier}, \texttt{records} (\texttt{timestamp}, \texttt{rpm}, \texttt{speedKmh}, \texttt{engineTempC}, \texttt{fuelLevelPercent}) & \texttt{202 Accepted} \newline \textbf{BatchIngestionResponse:} \newline \texttt{ingestedRecordsCount}, \texttt{persistedHypertable}: true, \texttt{ingestedAt} & \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/TelemetryIngestion/ingestTelemetryBatch}{\texttt{iot/}} \newline \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/TelemetryIngestion/ingestTelemetryBatch}{\texttt{telemetry/}} \newline \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/TelemetryIngestion/ingestTelemetryBatch}{\texttt{batch}} \\
\hline
TS21: Registro y catalogación de fallas DTC & \texttt{POST} \newline \texttt{/api/v1/iot/faults} & Header: \texttt{Authorization} \newline Body JSON: \texttt{vehicleId}, \texttt{dtcCode} (OBD-II), \texttt{severity}, \texttt{detectedAt} & \texttt{201 Created} \newline \textbf{VehicleFaultResource:} \newline \texttt{id}, \texttt{vehicleId}, \texttt{dtcCode}, \texttt{subsystem}, \texttt{description}, \texttt{status} & \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/VehicleFaults/registerVehicleFault}{\texttt{iot/faults}} \\
\hline
TS22: Generación pericial con IA predictiva Spring AI & \texttt{POST} \newline \texttt{/api/v1/iot/} \newline \texttt{health-reports/} \newline \texttt{generate} & Header: \texttt{Authorization} \newline Body JSON: \texttt{vehicleId}, \texttt{analysisHorizonDays}, \texttt{includePredictiveAi} & \texttt{201 Created} \newline \textbf{VehicleHealthReportResource:} \newline \texttt{id}, \texttt{vehicleId}, \texttt{healthScore}, \texttt{criticalAlerts}, \texttt{predictiveInsights} & \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/VehicleHealthReports/generateHealthReport}{\texttt{iot/health-}} \newline \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/VehicleHealthReports/generateHealthReport}{\texttt{reports}} \\
\hline
TS24: Descarga de informe de salud vehicular en PDF & \texttt{GET} \newline \texttt{/api/v1/iot/} \newline \texttt{health-reports/} \newline \texttt{\{id\}/pdf} & Header: \texttt{Authorization} \newline Path: \texttt{id} (UUID informe) & \texttt{200 OK} \newline \texttt{application/pdf}: \newline flujo binario del informe pericial estructurado con diagnóstico predictivo & \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/VehicleHealthReports/downloadHealthReportPdf}{\texttt{iot/health-}} \newline \href{https://atelier-platform.onrender.com/swagger-ui/index.html\#/VehicleHealthReports/downloadHealthReportPdf}{\texttt{pdf}} \\
\hline
\end{longtable}
\endgroup

*Nota.* Especificación técnica y catálogo de endpoints RESTful del backend documentados en OpenAPI 3.1 para el Sprint 1.

**Registro de Commits de Documentación de Servicios Web**

La @tbl:services-documentation-commits detalla la relación de commits asociados al diseño, implementación de controladores y actualización de la especificación OpenAPI en el repositorio oficial de backend.

\begingroup
\small
\setlength{\tabcolsep}{4pt}
\renewcommand{\arraystretch}{1.2}
\begin{longtable}{| >{\raggedright\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\raggedright\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.4cm} | >{\centering\arraybackslash}p{2.0cm} |}
\caption{Registro de Commits de Documentación de Servicios Web (Sprint 1)} \label{tbl:services-documentation-commits} \\
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{4.2cm}|}{\textbf{Repositorio}} & \multicolumn{1}{>{\centering\arraybackslash}p{2.2cm}|}{\textbf{Rama}} & \multicolumn{1}{>{\centering\arraybackslash}p{4.2cm}|}{\textbf{Componente / Bounded Context}} & \multicolumn{1}{>{\centering\arraybackslash}p{2.4cm}|}{\textbf{ID de Commit}} & \multicolumn{1}{>{\centering\arraybackslash}p{2.0cm}|}{\textbf{Estado}} \\
\hline
\endfirsthead
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{4.2cm}|}{\textbf{Repositorio}} & \multicolumn{1}{>{\centering\arraybackslash}p{2.2cm}|}{\textbf{Rama}} & \multicolumn{1}{>{\centering\arraybackslash}p{4.2cm}|}{\textbf{Componente / Bounded Context}} & \multicolumn{1}{>{\centering\arraybackslash}p{2.4cm}|}{\textbf{ID de Commit}} & \multicolumn{1}{>{\centering\arraybackslash}p{2.0cm}|}{\textbf{Estado}} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
atelier-platform & \texttt{main} & IAM \& Tenancy (TS01 a TS05) & \texttt{b6dad09} & Verificado \\
\hline
atelier-platform & \texttt{main} & CRM \& Fleet Management (TS06 a TS09) & \texttt{0711e4b} & Verificado \\
\hline
atelier-platform & \texttt{main} & Workshop Operations MRO (TS10 a TS14) & \texttt{a5a4152} & Verificado \\
\hline
atelier-platform & \texttt{main} & Inventory \& Supply Chain (TS15, TS16) & \texttt{cb562c3} & Verificado \\
\hline
atelier-platform & \texttt{main} & Human Resources (TS17) & \texttt{700812e} & Verificado \\
\hline
atelier-platform & \texttt{main} & Invoicing \& Compliance (TS18, TS19, TS23) & \texttt{ce8ccc6} & Verificado \\
\hline
atelier-platform & \texttt{main} & IoT Telemetry \& AI (TS20 a TS22, TS24) & \texttt{ce8ccc6} & Verificado \\
\hline
atelier-platform & \texttt{main} & Consolidación y Poda OpenAPI & \texttt{82cd27f} & Verificado \\
\hline
\end{longtable}
\endgroup

*Nota.* Registro cronológico de control de versiones para la documentación OpenAPI en el repositorio atelier-platform.

#### 4.2.1.8. Software Deployment Evidence for Sprint Review

Durante el primer ciclo constructivo, el equipo implementó y automatizó el proceso de despliegue continuo en la nube para los dos productos principales que conforman el núcleo de la solución: el portal comercial de la solución denominado Atelier Workshop y la plataforma de servicios web del backend denominada Atelier Platform. Las actividades abarcaron la creación y configuración de cuentas en proveedores de infraestructura en la nube, el aprovisionamiento de recursos computacionales, la inyección segura de variables de entorno y secretos criptográficos, así como la vinculación de dominios canónicos con certificados SSL y TLS para el acceso público seguro.

**Despliegue del Portal Comercial en Vercel**

El portal comercial correspondiente a la página de aterrizaje de la solución se desplegó sobre la plataforma Vercel, aprovechando su red global de distribución de contenido y su integración nativa con repositorios de GitHub. A continuación, se detallan los pasos técnicos ejecutados durante el proceso de despliegue:

**Paso 1: Consolidación del repositorio de código fuente en GitHub.** El equipo aseguró la integración y validación previa de todos los activos estáticos, hojas de estilo Tailwind CSS y manifiestos de la aplicación en la rama principal \texttt{main} del repositorio \texttt{atelier-website}, tras la aprobación de la solicitud de extracción respectiva, tal como se ilustra en la @fig:deploy-website-step-1.

![Consolidación de la rama principal del repositorio atelier-website](report/assets/deploy/deploy-website-1.png){#fig:deploy-website-step-1 width=80%}

*Nota.* Vista del repositorio oficial atelier-website en GitHub en la rama principal tras la integración de los cambios del primer ciclo.

**Paso 2: Inicialización del aprovisionamiento en Vercel.** Se accedió a la consola de administración de Vercel y se desplegó el menú contextual de creación de recursos para iniciar el flujo de importación de un nuevo proyecto, como se observa en la @fig:deploy-website-step-2.

![Inicio de creación de proyecto en la consola de Vercel](report/assets/deploy/deploy-website-2.png){#fig:deploy-website-step-2 width=45%}

*Nota.* Captura del menú de acciones de Vercel para la incorporación de un nuevo proyecto en el espacio de trabajo.

**Paso 3: Selección e importación del repositorio.** A través del buscador de repositorios de Vercel, se localizó el proyecto \texttt{atelier-website} dentro de la organización oficial y se procedió a su importación, como se muestra en la @fig:deploy-website-step-3.

![Importación del repositorio atelier-website en Vercel](report/assets/deploy/deploy-website-3.png){#fig:deploy-website-step-3 width=60%}

*Nota.* Búsqueda y selección del repositorio atelier-website desde la organización del equipo en la interfaz de Vercel.

**Paso 4: Configuración de compilación y parámetros de proyecto.** Se asignó el nombre canónico \texttt{atelier-website}, se seleccionó la rama \texttt{main} como fuente de despliegue continuo, se definió el directorio raíz en \texttt{./} y se conservó el perfil predeterminado para aplicaciones estáticas, tal como se aprecia en la @fig:deploy-website-step-4.

![Configuración del nuevo proyecto en Vercel](report/assets/deploy/deploy-website-4.png){#fig:deploy-website-step-4 width=65%}

*Nota.* Parámetros de configuración del proyecto en Vercel incluyendo nombre, rama fuente y directorio raíz.

**Paso 5: Ejecución y verificación del despliegue inicial.** La plataforma ejecutó la construcción automatizada de los activos y generó el despliegue preliminar exitoso, mostrando la previsualización del portal en modo oscuro y confirmando la correcta distribución de los recursos, tal como se evidencia en la @fig:deploy-website-step-5.

![Confirmación de despliegue exitoso del portal web en Vercel](report/assets/deploy/deploy-website-5.png){#fig:deploy-website-step-5 width=65%}

*Nota.* Pantalla de confirmación de despliegue exitoso en el espacio de trabajo de Vercel con previsualización del portal.

**Paso 6: Vinculación del dominio canónico personalizado.** Se configuró el dominio corporativo \texttt{atelier.andeva.tech} en la sección de dominios del proyecto, asociándolo directamente al entorno de producción, según se observa en la @fig:deploy-website-step-6.

![Asignación de dominio personalizado en Vercel](report/assets/deploy/deploy-website-6.png){#fig:deploy-website-step-6 width=55%}

*Nota.* Formulario de configuración de dominios en Vercel asociando el subdominio canónico al entorno de producción.

**Paso 7: Validación de registros DNS y certificados SSL.** Se verificó la propagación de los registros DNS y la emisión de los certificados de seguridad, alcanzando el estado de configuración válida tanto para el dominio principal de producción como para el subdominio de desarrollo, como se muestra en la @fig:deploy-website-step-7.

![Verificación y estado activo del dominio de producción en Vercel](report/assets/deploy/deploy-website-7.png){#fig:deploy-website-step-7 width=85%}

*Nota.* Panel de dominios en Vercel evidenciando la configuración válida y activa de los dominios asociados al proyecto.

**Despliegue de la Plataforma de Servicios Web en Render**

La plataforma de servicios web de Atelier Platform se desplegó sobre el proveedor de computación en la nube Render como un servicio web basado en contenedores Docker. Este enfoque garantiza la portabilidad de las dependencias, la consistencia entre entornos y la correcta inicialización de la máquina virtual de Java. A continuación, se detallan los pasos técnicos ejecutados:

**Paso 1: Preparación del repositorio y artefactos de contenedor.** En el repositorio \texttt{atelier-platform}, el equipo preparó el archivo Dockerfile para la construcción en múltiples etapas con Eclipse Temurin OpenJDK 25, configuró los parámetros de la memoria Metaspace y Heap adaptados al límite de 512 megabytes de memoria de la instancia y publicó el release oficial 1.0.0, tal como se exhibe en la @fig:deploy-platform-step-0.

![Repositorio atelier-platform y configuración de contenedor en GitHub](report/assets/deploy/deploy-platform-0.png){#fig:deploy-platform-step-0 width=80%}

*Nota.* Vista del repositorio atelier-platform en GitHub exhibiendo los archivos de configuración Docker y la etiqueta de la versión inicial.

**Paso 2: Acceso al espacio de trabajo corporativo en Render.** Se ingresó a la consola principal de Render dentro del espacio de trabajo del equipo para gestionar los proyectos e infraestructura activa, según se observa en la @fig:deploy-platform-step-1.

![Panel principal de gestión de proyectos en Render](report/assets/deploy/deploy-platform-1.png){#fig:deploy-platform-step-1 width=80%}

*Nota.* Panel general de Render correspondiente al espacio de trabajo del equipo con la vista de proyectos aprovisionados.

**Paso 3: Creación del proyecto y definición del entorno.** Se creó el proyecto denominado \texttt{atelier-prod-v1} y se estableció el entorno de trabajo \texttt{Production} para alojar los servicios en vivo de la plataforma, como se ilustra en la @fig:deploy-platform-step-2.

![Creación del proyecto atelier-prod-v1 en Render](report/assets/deploy/deploy-platform-2.png){#fig:deploy-platform-step-2 width=50%}

*Nota.* Ventana modal de creación del proyecto en Render definiendo el nombre canónico y el entorno inicial.

**Paso 4: Inicialización del entorno de producción.** Una vez creado el entorno \texttt{Production} dentro del proyecto \texttt{atelier-prod-v1}, se habilitó la interfaz para la creación de nuevos servicios, tal como se aprecia en la @fig:deploy-platform-step-3.

![Vista del entorno de producción preparado para nuevos servicios](report/assets/deploy/deploy-platform-3.png){#fig:deploy-platform-step-3 width=80%}

*Nota.* Vista del entorno de producción en Render previa a la creación del primer servicio web de la plataforma.

**Paso 5: Selección del tipo de servicio web.** Dentro del catálogo de recursos de Render, se seleccionó la opción de servicios web dinámicos, idónea para servidores de aplicaciones, microservicios y APIs RESTful, como se muestra en la @fig:deploy-platform-step-4.

![Selección del tipo de servicio Web Services en Render](report/assets/deploy/deploy-platform-4.png){#fig:deploy-platform-step-4 width=80%}

*Nota.* Menú de selección del tipo de servicio en Render destacando la categoría de aplicaciones web y servidores de API.

**Paso 6: Conexión con el repositorio de servicios web.** A través de la integración con el proveedor Git, se seleccionó el repositorio oficial \texttt{atelier-platform} dentro de la organización del equipo, tal como se evidencia en la @fig:deploy-platform-step-5.

![Selección del repositorio atelier-platform en Render](report/assets/deploy/deploy-platform-5.png){#fig:deploy-platform-step-5 width=65%}

*Nota.* Interfaz de conexión de Render vinculando el repositorio oficial de la plataforma de servicios web.

**Paso 7: Configuración de la instancia y entorno de ejecución Docker.** Se asignó el nombre \texttt{atelier-platform-1}, se seleccionó el entorno de ejecución Docker, se vinculó la rama principal \texttt{main}, se eligió la región geográfica de Oregón en Estados Unidos y se seleccionó el plan de recursos informáticos de 512 megabytes de memoria RAM y media unidad de procesamiento central, como se observa en la @fig:deploy-platform-step-6.

![Configuración del servicio web basado en Docker en Render](report/assets/deploy/deploy-platform-6.png){#fig:deploy-platform-step-6 width=80%}

*Nota.* Formulario de configuración de parámetros de despliegue en Render incluyendo entorno Docker, rama y región geográfica.

**Paso 8: Inyección segura de variables de entorno y credenciales.** Se configuraron las variables de entorno necesarias para la operación de la aplicación en producción, incluyendo el perfil activo de Spring Boot, el puerto de escucha, la ruta base del servlet, los parámetros de conexión JDBC hacia la base de datos relacional y el tamaño máximo del pool de conexiones, tal como se muestra en la @fig:deploy-platform-step-7.

![Configuración de variables de entorno seguras en Render](report/assets/deploy/deploy-platform-7.png){#fig:deploy-platform-step-7 width=80%}

*Nota.* Panel de variables de entorno en Render conteniendo las claves de configuración de la base de datos y del servidor.

**Paso 9: Despliegue exitoso y verificación de trazas de ejecución en vivo.** Render completó la construcción de la imagen de contenedor y puso en marcha el servicio con el estado \texttt{Deploy succeeded | Live}. Las trazas del registro de eventos en vivo confirmaron la inicialización exitosa de los módulos de la aplicación, la conexión con Firebase y la apertura del contenedor embebido Tomcat, alcanzando la operatividad total del backend, tal como se ilustra en la @fig:result-deploy-platform-1.

![Confirmación de despliegue exitoso y trazas de ejecución en vivo en Render](report/assets/deploy/result-deploy-platform-1.png){#fig:result-deploy-platform-1 width=80%}

*Nota.* Panel de despliegue en Render exhibiendo el estado exitoso y los registros del arranque del servidor Tomcat y módulos de Spring Boot.

#### 4.2.1.9. Team Collaboration Insights during Sprint

Durante el primer ciclo constructivo, el equipo implementó una dinámica de trabajo ágil basada en la especialización técnica por componentes y el cumplimiento riguroso de la matriz de liderazgo y colaboración establecida al inicio del proyecto. Para monitorear la equidad del esfuerzo colectivo, la cadencia de entrega y la trazabilidad de cada incremento de software, el equipo utilizó de manera continua las métricas de contribución y analíticos provistos por GitHub Insights sobre los repositorios oficiales de la plataforma y del portal comercial.

Todos los integrantes del equipo participaron activamente en la implementación de los productos digitales correspondientes a este ciclo, manteniendo una disciplina estricta de control de versiones mediante ramas por funcionalidad, revisiones por pares en solicitudes de extracción y sincronizaciones técnicas periódicas a través de canales de comunicación dedicados. Esta organización garantizó un desacoplamiento efectivo entre la experiencia web y la lógica de dominio empresarial, evitando dependencias cruzadas o bloqueos en el flujo de integración continua.

**Analíticos de Colaboración en el Repositorio de Servicios Web Atelier Platform**

La implementación de los servicios web del backend en el repositorio \texttt{atelier-platform} estuvo a cargo de los dos especialistas de backend del equipo: Joel Huamani Estefanero, identificado con el usuario \texttt{shouydev} en GitHub, y Adiel Sanchez Santin, identificado con el usuario \texttt{xs4el}. Como se evidencia en la @fig:collab-insights-backend, ambos integrantes alcanzaron un balance cuantitativo perfecto en la frecuencia de aportes, registrando exactamente cuarenta y un commits cada uno en la rama principal, lo que demuestra una paridad total en el compromiso y avance técnico del componente.

![Analíticos de contribución y commits por autor en el repositorio de servicios web de Atelier Platform](report/assets/sprint-1/commits-backend-sprint-1.png){#fig:collab-insights-backend width=70%}

*Nota.* Gráfico de contribuciones semanales y registro individual de commits en la rama principal del repositorio atelier-platform obtenido de GitHub Insights.

La interpretación técnica de estos analíticos refleja una distribución de responsabilidades armónica y complementaria:

- **Joel Huamani Estefanero (\texttt{shouydev}):** Como líder técnico de los Bounded Contexts fundacionales, asumió la arquitectura base de la solución, el núcleo compartido, el aprovisionamiento multi-inquilino en IAM, la ingesta telemática de alta frecuencia en TimescaleDB, la emisión de comprobantes electrónicos UBL 2.1 ante la SUNAT y la integración de suscripciones recurrentes. Su volumen de líneas añadidas refleja la generación inicial de arquetipos, entidades de persistencia y configuraciones de seguridad del sistema.
- **Adiel Sanchez Santin (\texttt{xs4el}):** Como líder técnico de los Bounded Contexts operativos, implementó los módulos de gestión de relaciones con clientes y flota de vehículos, administración integral de órdenes de trabajo en taller, control de inventario valorizado por lote bajo el método FIFO y gestión de asistencia del personal con validación geodésica. Su labor consolidó la lógica de negocio y las invariantes del dominio automotriz con un aporte simétrico de commits.

**Analíticos de Colaboración en el Repositorio del Portal Comercial Atelier Website**

La construcción del portal comercial en el repositorio \texttt{atelier-website} fue ejecutada de manera coordinada por los tres integrantes asignados al frente web: Luis Granda Ibarra, identificado con el usuario \texttt{danieltyuyu} en GitHub, Mauricio Teran Zavala, identificado con el usuario \texttt{mau-tz}, y Alvaro Rocha Cotrina, identificado con el usuario \texttt{alvarorc24}. La @fig:collab-insights-website ilustra la distribución de contribuciones a lo largo del sprint, evidenciando la participación efectiva y complementaria de los tres colaboradores según sus roles de liderazgo funcional.

![Analíticos de contribución y commits por autor en el repositorio del portal comercial de Atelier](report/assets/sprint-1/commits-website-sprint-1.png){#fig:collab-insights-website width=65%}

*Nota.* Gráfico de contribuciones semanales y registro individual de commits en la rama principal del repositorio atelier-website obtenido de GitHub Insights.

La interpretación de las métricas en este repositorio sustenta el avance de los aspectos asignados en la matriz de colaboración:

- **Luis Granda Ibarra (\texttt{danieltyuyu}):** Asumió el liderazgo del diseño visual y la experiencia de usuario del portal, registrando diecinueve commits y más de seis mil líneas de código. Su trabajo comprendió la estructura fundamental en HTML5, la configuración del sistema de diseño con Tailwind CSS v4, la adaptación de temas visuales claro y oscuro, y la habilitación de la arquitectura PWA con almacenamiento en caché fuera de línea.
- **Mauricio Teran Zavala (\texttt{mau-tz}):** Como líder del módulo de planes y tarifas comerciales, aportó cinco commits enfocados en la interactividad del tarifario dinámico, permitiendo a los usuarios conmutar entre esquemas de cobro mensual y anual y visualizar estimaciones cuantitativas de ahorro para sus talleres.
- **Alvaro Rocha Cotrina (\texttt{alvarorc24}):** Lideró el centro de soporte, la sección de preguntas frecuentes y los formularios de conversión, contribuyendo con tres commits y más de seiscientas líneas orientadas a la experiencia de contacto, la integración del selector de idioma bilingüe y la accesibilidad web.

En síntesis, los analíticos de colaboración demuestran una ejecución sincronizada, con una distribución equitativa de la carga de trabajo entre todos los miembros del equipo y un estricto cumplimiento de los estándares de desarrollo de software establecidos para el proyecto.

\newpage

