## 2.4. Requirements Specification

La especificación de requisitos consolida las capacidades funcionales, operativas y de integración requeridas por el ecosistema Atelier, traduciendo los hallazgos del levantamiento de necesidades y los modelos de dominio en artefactos ágiles de ingeniería de software. Para el presente desarrollo, la especificación delimita su alcance a dos componentes cardinales de la arquitectura: la aplicación móvil orientada a la gestión operativa en patio y bahías de servicio, denominada Atelier Workshop Mobile, y los servicios e interfaces de programación de aplicaciones del backend centralizado, denominado Atelier Platform Backend. Quedan excluidos de este alcance el portal web institucional y la aplicación orientada a conductores particulares.

Esta sección articula el modelado de escenarios proyectados del servicio automotriz, la formulación de historias de usuario y técnicas, el mapa de impactos y la priorización del catálogo de producto para la solución digital.

### 2.4.1. *User Stories*

Las historias de usuario y las historias técnicas constituyen la unidad básica para la planificación y verificación del comportamiento del software. Cada historia encapsula una necesidad operativa o técnica bajo el estándar formulado por Mike Cohn, complementada con criterios de aceptación estructurados bajo la sintaxis BDD de Gherkin en escenarios comprobables redactados en tiempo presente y tercera persona. La redacción se orienta estrictamente al comportamiento del sistema y a las reglas del negocio automotriz, omitiendo cualquier referencia a elementos gráficos o componentes visuales de interfaz de usuario.

Las historias se agrupan en diez épicas de trabajo: nueve épicas funcionales enfocadas en las operaciones de patio, bahía, diagnóstico telemático, inventario y facturación fiscal de Atelier Workshop Mobile (EP01 a EP09), y una épica técnica enfocada en los contratos RESTful, persistencia y seguridad del backend (EP10). La prioridad de cada historia se clasifica en tres niveles:

- **Alta:** Capacidades indispensables para la operatividad del taller, la integridad transaccional del backend o el cumplimiento tributario, cuya ausencia bloquea el flujo del servicio.
- **Media:** Funcionalidades de optimización logística, control de inventario y soporte operativo que enriquecen la trazabilidad sin paralizar la atención en bahía.
- **Baja:** Herramientas analíticas y métricas avanzadas de supervisión que facilitan la toma de decisiones gerenciales.

La @tbl:catalogo-epicas presenta la matriz consolidada de las diez épicas definidas para el ecosistema Atelier, detallando su identificador, título, área funcional, rol de usuario participante, prioridad asignada y alcance operativo general:

\renewcommand{\arraystretch}{1.2}
\begin{longtable}{| >{\centering\arraybackslash}p{1.8cm} | >{\raggedright\arraybackslash}p{6.8cm} | >{\centering\arraybackslash}p{3.8cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-12.4cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Catálogo Consolidado de Épicas del Ecosistema Atelier} \label{tbl:catalogo-epicas} \\
\hline
\thfirst{Epic ID} & \thcell{Título y Área Funcional} & \thcell{Rol de Usuario} & \thcell{Prioridad} \\
\hline
\endfirsthead
\hline
\thfirst{Epic ID} & \thcell{Título y Área Funcional} & \thcell{Rol de Usuario} & \thcell{Prioridad} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
\textbf{EP01} & \textbf{Autenticación y Control de Acceso Móvil}\newline \textit{Área: Seguridad e Identidad (IAM)} & Personal de taller & Alta \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Alcance:} Gestión de credenciales corporativas, validación de tokens JWT y selección de sucursal de trabajo con aislamiento multi-inquilino.} \\
\hline
\textbf{EP02} & \textbf{Control de Asistencia Satelital y Turnos}\newline \textit{Área: Gestión de Personal (HR)} & Técnico automotriz & Alta \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Alcance:} Marcación laboral de ingreso y salida validada por geocerca GPS satelital con fórmula de Haversine y consulta de turnos programados.} \\
\hline
\textbf{EP03} & \textbf{Recepción Pericial e Inspección en Patio}\newline \textit{Área: Operaciones de Taller y Clientes (CRM/MRO)} & Asesor de servicio & Alta \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Alcance:} Registro de cliente y unidad por placa o VIN, checklist de peritaje visual, captura de evidencias fotográficas y apertura de la orden de trabajo.} \\
\hline
\textbf{EP04} & \textbf{Diagnóstico Electrónico y Telemetría OBD-II}\newline \textit{Área: Telemetría Vehicular IoT} & Técnico automotriz & Alta \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Alcance:} Enlace inalámbrico con escáner OBD-II, lectura de parámetros en tiempo real, extracción de códigos DTC y registro local offline en fosa.} \\
\hline
\textbf{EP05} & \textbf{Presupuestos y Cotizaciones de Mantenimiento}\newline \textit{Área: Operaciones de Taller (MRO)} & Administrador de taller & Alta \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Alcance:} Formulación de presupuestos MRO desglosando mano de obra y repuestos de catálogo, verificación de existencias y aprobación del cliente.} \\
\hline
\textbf{EP06} & \textbf{Ejecución de Tareas en Bahía de Servicio}\newline \textit{Área: Operaciones de Taller (MRO)} & Técnico automotriz & Alta \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Alcance:} Gestión de tareas mecánicas asignadas, cronometraje de horas hombre y registro fotográfico de piezas desmontadas y repuestos nuevos.} \\
\hline
\textbf{EP07} & \textbf{Abastecimiento y Descargo de Repuestos FIFO}\newline \textit{Área: Logística e Inventario} & Personal de taller & Media \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Alcance:} Requisición de repuestos desde la bahía, descargo contable bajo regla estricta FIFO por lote y alertas de stock de seguridad en almacén.} \\
\hline
\textbf{EP08} & \textbf{Facturación Electrónica y Cierre de Servicio}\newline \textit{Área: Facturación y Cumplimiento Fiscal} & Administrador de taller & Alta \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Alcance:} Consolidación de costos de orden de trabajo, emisión de Boletas o Facturas UBL 2.1 ante SUNAT vía Nubefact, cobro y entrega vehicular.} \\
\hline
\textbf{EP09} & \textbf{Monitoreo Operativo de Patio y Gestión Gerencial}\newline \textit{Área: Operaciones y Gestión de Negocio} & Personal directivo de taller & Media \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Alcance:} Supervisión en tiempo real de bahías, parametrización tributaria SUNAT y exportación documental de balances y diagnósticos periciales en formato PDF.} \\
\hline
\textbf{EP10} & \textbf{Servicios e Interfaces RESTful del Backend}\newline \textit{Área: Servicios de Plataforma (API)} & Developer & Alta \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Alcance:} Exposición de endpoints RESTful seguros con autenticación JWT, persistencia transaccional, validación de esquemas y trazabilidad de eventos.} \\
\hline
\end{longtable}

*Nota.* Catálogo consolidado de épicas funcionales para la aplicación móvil Atelier Workshop y épicas técnicas del backend de plataforma.

**Epic 1: Autenticación y Control de Acceso Móvil**

A continuación, se presentan las historias de usuario pertenecientes a la épica número 1, que agrupa todas las funcionalidades de incorporación de colaboradores por invitación, verificación mediante OTP, autenticación corporativa y control de sesiones móviles en Atelier Workshop Mobile.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.5cm} | >{\centering\arraybackslash}p{5.0cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-7.5cm-6\tabcolsep-4\arrayrulewidth\relax} |}
\caption{Épica EP01: Autenticación y Control de Acceso Móvil} \label{tbl:ep01} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endfirsthead
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
EP01 & Personal de taller & Alta \\
\hline
\thfirst{Title} & \multicolumn{2}{p{\dimexpr\textwidth-2.5cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Autenticación y Control de Acceso Móvil} \\
\hline
\thspanfirst{3}{Description} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} personal de taller,\newline \textbf{quiero} registrarme mediante invitación corporativa, validar mi correo con código OTP, autenticarme con mis credenciales y gestionar mi sesión de forma segura,\newline \textbf{para} acceder a las operaciones del taller bajo aislamiento multi-inquilino y proteger la información operativa.} \\
\hline
\end{longtable}

*Nota.* Especificación de la épica EP01 elaborada para el proyecto Atelier.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US01 - Registro y vinculación de colaborador mediante invitación corporativa} \label{tbl:us01} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US01 & Personal de taller & Alta & EP01 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Registro y vinculación de colaborador mediante invitación corporativa} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} colaborador invitado a laborar en el taller,\newline \textbf{quiero} registrar mis datos de identidad y crear mi contraseña a partir del enlace de invitación recibido por correo electrónico,\newline \textbf{para} incorporarme a la sucursal de trabajo asignada con el rol operativo autorizado.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Registro exitoso de colaborador invitado}\newline
\textbf{Dado que} el colaborador recibe un enlace con un token de invitación vigente emitido por la administración del taller,\newline
\textbf{cuando} ingresa sus datos de identidad, define su contraseña corporativa y confirma el registro,\newline
\textbf{entonces} el sistema valida la autenticidad del token, crea la cuenta del colaborador vinculándola al taller y sucursal emisora con el rol asignado,\newline
\textbf{y} marca la invitación como aceptada para impedir su reutilización.\vspace{4pt}\newline
\textbf{Escenario 2: Bloqueo de registro por membresía activa previa en otro taller}\newline
\textbf{Dado que} el usuario mantiene una membresía laboral activa en otro taller automotriz dentro de la plataforma Atelier,\newline
\textbf{cuando} intenta aceptar la invitación para incorporarse a una nueva organización,\newline
\textbf{entonces} el sistema rechaza la solicitud de vinculación por colisión de exclusividad laboral,\newline
\textbf{y} notifica que debe gestionar su desvinculación formal de su taller actual antes de integrarse a una nueva entidad.\vspace{4pt}\newline
\textbf{Escenario 3: Rechazo de invitación vencida o revocada}\newline
\textbf{Dado que} el token de invitación ha superado su período de vigencia de cuarenta y ocho horas o fue revocado por el administrador,\newline
\textbf{cuando} el destinatario intenta completar el formulario de registro,\newline
\textbf{entonces} el sistema invalida la solicitud,\newline
\textbf{y} notifica la caducidad del enlace requiriendo la emisión de una nueva invitación corporativa.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US01.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US02 - Verificación de identidad y correo electrónico mediante código OTP} \label{tbl:us02} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US02 & Personal de taller & Alta & EP01 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Verificación de identidad y correo electrónico mediante código OTP} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} usuario recién registrado en el taller,\newline \textbf{quiero} ingresar el código numérico OTP de seis dígitos despachado a mi correo electrónico institucional,\newline \textbf{para} certificar la titularidad de mi cuenta y habilitar mi acceso operativo a la aplicación móvil.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Validación exitosa y activación de cuenta}\newline
\textbf{Dado que} el sistema ha emitido un código numérico de seis dígitos con vigencia de diez minutos al correo del usuario,\newline
\textbf{cuando} el usuario suministra el código exacto recibido,\newline
\textbf{entonces} el sistema valida la correspondencia del código OTP, registra el correo electrónico como verificado,\newline
\textbf{y} activa la cuenta de usuario habilitándola para iniciar sesión en la aplicación móvil.\vspace{4pt}\newline
\textbf{Escenario 2: Rechazo de código OTP incorrecto o caducado}\newline
\textbf{Dado que} el código suministrado no coincide con el emitido o ha superado su ventana temporal de validez,\newline
\textbf{cuando} se procesa la solicitud de verificación,\newline
\textbf{entonces} el sistema rechaza la activación manteniendo la cuenta en estado pendiente,\newline
\textbf{y} notifica la discrepancia permitiendo solicitar la reemisión de un nuevo código OTP.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US02.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US03 - Inicio de sesión corporativo y contextualización de sede de trabajo} \label{tbl:us03} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US03 & Personal de taller & Alta & EP01 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Inicio de sesión corporativo y contextualización de sede de trabajo} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} personal de taller con cuenta activa y verificada,\newline \textbf{quiero} autenticarme con mi correo institucional y contraseña en la aplicación móvil,\newline \textbf{para} obtener un token de sesión seguro y operar en el contexto de mi sede laboral asignada.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Autenticación exitosa y carga de contexto operativo}\newline
\textbf{Dado que} el colaborador cuenta con credenciales válidas y membresía activa en una sucursal del taller,\newline
\textbf{cuando} envía su correo institucional y contraseña para iniciar sesión,\newline
\textbf{entonces} el sistema valida las credenciales, emite un token de sesión JWT con los permisos de su rol,\newline
\textbf{y} restringe las consultas de bahías, vehículos y órdenes al ámbito exclusivo de su sucursal de adscripción.\vspace{4pt}\newline
\textbf{Escenario 2: Denegación de acceso por credenciales no válidas}\newline
\textbf{Dado que} se ingresa una contraseña incorrecta o un correo no registrado en el sistema,\newline
\textbf{cuando} se solicita la autenticación del usuario,\newline
\textbf{entonces} el sistema deniega el acceso sin emitir credenciales de sesión,\newline
\textbf{y} registra el intento fallido notificando la inconsistencia de los datos suministrados.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US03.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US04 - Cierre de sesión seguro y revocación de credenciales en el dispositivo móvil} \label{tbl:us04} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US04 & Personal de taller & Alta & EP01 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Cierre de sesión seguro y revocación de credenciales en el dispositivo móvil} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} personal de taller,\newline \textbf{quiero} finalizar voluntariamente mi sesión de trabajo en el dispositivo móvil,\newline \textbf{para} revocar los tokens locales e impedir accesos no autorizados a la información operativa del taller.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Cierre voluntario de turno de trabajo}\newline
\textbf{Dado que} el usuario mantiene una sesión autenticada activa en el dispositivo móvil,\newline
\textbf{cuando} solicita formalmente el término de su sesión,\newline
\textbf{entonces} el sistema invalida el token de acceso vigente en el almacén local del dispositivo,\newline
\textbf{y} restablece el estado de la aplicación requiriendo una nueva autenticación para cualquier interacción posterior.\vspace{4pt}\newline
\textbf{Escenario 2: Expiración automática por caducidad de token}\newline
\textbf{Dado que} el token de sesión ha superado su período de validez temporal predefinido sin renovación,\newline
\textbf{cuando} la aplicación móvil intenta realizar una consulta operativa al backend,\newline
\textbf{entonces} el sistema detecta la caducidad del token, revoca los permisos en memoria,\newline
\textbf{y} exige la re-autenticación del usuario para garantizar la seguridad transaccional.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US04.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US05 - Restablecimiento de credenciales de acceso mediante token de verificación} \label{tbl:us05} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US05 & Personal de taller & Media & EP01 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Restablecimiento de credenciales de acceso mediante token de verificación} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} personal de taller,\newline \textbf{quiero} solicitar el restablecimiento de mi contraseña corporativa mediante un token temporal enviado a mi correo institucional,\newline \textbf{para} recuperar el acceso a mis funciones operativas ante olvido de clave sin comprometer la seguridad.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Generación exitosa de solicitud de recuperación}\newline
\textbf{Dado que} el colaborador ingresa un correo electrónico corporativo registrado y activo en el sistema,\newline
\textbf{cuando} solicita la recuperación de su contraseña de acceso,\newline
\textbf{entonces} el sistema genera un token de verificación criptográfico con vigencia temporal limitada de quince minutos,\newline
\textbf{y} despacha las instrucciones de restablecimiento al correo institucional del colaborador.\vspace{4pt}\newline
\textbf{Escenario 2: Rechazo de token expirado o adulterado}\newline
\textbf{Dado que} se intenta ingresar una nueva contraseña utilizando un token cuya vigencia ha expirado o cuyos caracteres son inválidos,\newline
\textbf{cuando} el sistema procesa la confirmación de cambio de clave,\newline
\textbf{entonces} la operación es rechazada conservando inalterada la contraseña previa,\newline
\textbf{y} se notifica la invalidez del token requiriendo una nueva solicitud formal.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US05.

**Epic 2: Control de Asistencia Satelital y Turnos**

A continuación, se presentan las historias de usuario pertenecientes a la épica número 2, que agrupa las funcionalidades de marcación de jornada laboral asistida por geocerca GPS satelital, auditoría perimétrica geodésica, liquidación de jornada efectiva y gestión de turnos y descargos en Atelier Workshop Mobile.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.5cm} | >{\centering\arraybackslash}p{5.0cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-7.5cm-6\tabcolsep-4\arrayrulewidth\relax} |}
\caption{Épica EP02: Control de Asistencia Satelital y Turnos} \label{tbl:ep02} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endfirsthead
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
EP02 & Técnico automotriz & Alta \\
\hline
\thfirst{Title} & \multicolumn{2}{p{\dimexpr\textwidth-2.5cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Control de Asistencia Satelital y Turnos} \\
\hline
\thspanfirst{3}{Description} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} técnico automotriz,\newline \textbf{quiero} registrar mi asistencia de ingreso y salida validando mi ubicación satelital dentro del perímetro del taller y consultar mi cronograma de trabajo,\newline \textbf{para} acreditar mi presencia física en la sucursal asignada y dar seguimiento a mis turnos laborales.} \\
\hline
\end{longtable}

*Nota.* Especificación de la épica EP02 elaborada para el proyecto Atelier.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US06 - Marcación de ingreso laboral con validación de geocerca GPS satelital} \label{tbl:us06} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US06 & Técnico automotriz & Alta & EP02 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Marcación de ingreso laboral con validación de geocerca GPS satelital} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} técnico automotriz,\newline \textbf{quiero} registrar mi ingreso laboral validando mis coordenadas de posicionamiento satelital respecto a la sede asignada,\newline \textbf{para} certificar mi puntualidad y presencia física dentro de las instalaciones del taller automotriz.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Marcación puntual dentro del margen de tolerancia y perímetro de sede}\newline
\textbf{Dado que} el técnico automotriz se sitúa dentro del radio de tolerancia de cien metros respecto al centroide de la sucursal y arriba dentro del margen de gracia de quince minutos de su turno,\newline
\textbf{cuando} registra su entrada laboral en el sistema móvil,\newline
\textbf{entonces} el sistema valida las coordenadas mediante la fórmula de Haversine, registra la marca temporal con calificación de puntualidad,\newline
\textbf{y} vincula el asiento de asistencia al expediente laboral y al turno asignado.\vspace{4pt}\newline
\textbf{Escenario 2: Marcación con tardanza fuera de la ventana de gracia}\newline
\textbf{Dado que} el colaborador se encuentra dentro de la geocerca pero su registro supera el margen de gracia establecido para su turno,\newline
\textbf{cuando} asienta su marcación de entrada en la jornada,\newline
\textbf{entonces} el sistema califica el registro bajo estado de tardanza, computa los minutos de demora acumulados,\newline
\textbf{y} requiere el ingreso de un descargo justificatorio para conocimiento de la administración.\vspace{4pt}\newline
\textbf{Escenario 3: Bloqueo de marcación duplicada en la misma jornada}\newline
\textbf{Dado que} el colaborador ya cuenta con una marcación de ingreso activa y sin salida en la jornada en curso,\newline
\textbf{cuando} intenta registrar un nuevo ingreso sin haber liquidado el turno previo,\newline
\textbf{entonces} el sistema deniega el duplicado notificando la vigencia de una jornada abierta,\newline
\textbf{y} preserva intacto el registro temporal original.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US06.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US07 - Auditoría perimétrica y contingencias de conectividad satelital} \label{tbl:us07} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US07 & Técnico automotriz & Alta & EP02 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Auditoría perimétrica y contingencias de conectividad satelital} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} técnico automotriz,\newline \textbf{quiero} que el sistema audite mi posición geográfica en tiempo de marcación y gestione contingencias de cobertura celular en patio,\newline \textbf{para} garantizar la fiabilidad del cómputo laboral y asegurar el registro de mi asistencia ante pérdidas transitorias de conectividad.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Rechazo estricto por ubicación fuera de la geocerca autorizada}\newline
\textbf{Dado que} las coordenadas satelitales del dispositivo superan el radio perimétrico de cien metros asignado a la sucursal,\newline
\textbf{cuando} el colaborador intenta registrar su asistencia laboral,\newline
\textbf{entonces} el sistema deniega el registro de ingreso por discrepancia geográfica, calcula la distancia excedente en metros,\newline
\textbf{y} notifica la imposibilidad de marcar fuera de los linderos del taller.\vspace{4pt}\newline
\textbf{Escenario 2: Imposibilidad de obtener fijación satelital en el dispositivo}\newline
\textbf{Dado que} el dispositivo móvil no cuenta con señal de posicionamiento satelital o mantiene los servicios de geolocalización desactivados,\newline
\textbf{cuando} se solicita el registro de asistencia,\newline
\textbf{entonces} el sistema bloquea la operación impidiendo el registro sin coordenadas auditables,\newline
\textbf{y} orienta al colaborador a restablecer los permisos de ubicación para continuar.\vspace{4pt}\newline
\textbf{Escenario 3: Sincronización resiliente ante pérdida de cobertura en fosa subterránea}\newline
\textbf{Dado que} el técnico efectúa su marcación en un área de taller con apantallamiento electromagnético sin cobertura de datos móviles,\newline
\textbf{cuando} se registra la asistencia contando con coordenadas satelitales válidas,\newline
\textbf{entonces} el sistema almacena el registro en una cola local protegida con firma criptográfica,\newline
\textbf{y} sincroniza automáticamente el evento con el servidor central al restablecer la conexión de red.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US07.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US08 - Marcación de salida y liquidación de jornada laboral efectiva} \label{tbl:us08} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US08 & Técnico automotriz & Alta & EP02 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Marcación de salida y liquidación de jornada laboral efectiva} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} técnico automotriz,\newline \textbf{quiero} registrar mi salida al término de mis actividades en el taller,\newline \textbf{para} cerrar formalmente el turno diario y liquidar las horas hombre efectivamente laboradas.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Cierre conforme de jornada laboral ordinaria}\newline
\textbf{Dado que} el técnico automotriz mantiene un ingreso activo en la jornada y se ubica dentro del perímetro de la sede,\newline
\textbf{cuando} registra su salida al culminar el horario del turno,\newline
\textbf{entonces} el sistema graba la marca temporal de salida, calcula el tiempo neto trabajado en horas y minutos,\newline
\textbf{y} asienta el registro de asistencia como completado en el expediente del colaborador.\vspace{4pt}\newline
\textbf{Escenario 2: Detección y registro de tiempo extraordinario en faena de bahía}\newline
\textbf{Dado que} el técnico concluye la atención mecánica de un vehículo superando en más de treinta minutos la hora de salida de su turno,\newline
\textbf{cuando} efectúa la marcación de término de faena,\newline
\textbf{entonces} el sistema desglosa las horas de jornada regular y el excedente en calidad de tiempo extraordinario,\newline
\textbf{y} genera una notificación de sobretiempo para liquidación en la nómina periódica.\vspace{4pt}\newline
\textbf{Escenario 3: Rechazo de salida sin marcación de ingreso previa}\newline
\textbf{Dado que} no existe una marcación de entrada registrada para la fecha en curso,\newline
\textbf{cuando} el colaborador intenta marcar la salida laboral,\newline
\textbf{entonces} el sistema rechaza la transacción indicando la inexistencia de una jornada abierta,\newline
\textbf{y} solicita coordinar la regularización de la omisión con la jefatura de taller.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US08.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US09 - Consulta de programación semanal de turnos y márgenes de tolerancia} \label{tbl:us09} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US09 & Técnico automotriz & Media & EP02 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Consulta de programación semanal de turnos y márgenes de tolerancia} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} técnico automotriz,\newline \textbf{quiero} consultar mi calendario de turnos asignados, sucursales de guardia y márgenes de tolerancia,\newline \textbf{para} organizar con anticipación mis jornadas de trabajo y evitar penalizaciones por impuntualidad.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Consulta de cronograma semanal de actividades y descansos}\newline
\textbf{Dado que} la jefatura de taller ha publicado la planificación operativa del ciclo vigente,\newline
\textbf{cuando} el técnico consulta su calendario de asignaciones,\newline
\textbf{entonces} el sistema presenta los turnos programados de lunes a domingo, detallando la sede correspondiente y las horas de entrada y salida,\newline
\textbf{y} resalta los días de descanso obligatorio concedidos.\vspace{4pt}\newline
\textbf{Escenario 2: Advertencia preventiva de inicio de turno y ventana de gracia}\newline
\textbf{Dado que} restan menos de treinta minutos para el inicio del turno asignado al colaborador,\newline
\textbf{cuando} el sistema evalúa la proximidad de la jornada laboral,\newline
\textbf{entonces} despacha un recordatorio operativo indicando el horario de inicio y los quince minutos de gracia tolerados,\newline
\textbf{y} orienta al técnico a presentarse dentro del radio perimétrico del taller.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US09.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US10 - Emisión y seguimiento de descargos justificatorios de tardanza} \label{tbl:us10} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US10 & Técnico automotriz & Media & EP02 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Emisión y seguimiento de descargos justificatorios de tardanza} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} técnico automotriz,\newline \textbf{quiero} sustentar digitalmente los motivos de demoras imprevistas y dar seguimiento a su evaluación por administración,\newline \textbf{para} regularizar mi récord de puntualidad y mitigar deducciones salariales injustificadas.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Registro formal de motivo de descargo en marcación tardía}\newline
\textbf{Dado que} la marcación de ingreso fue calificada bajo condición de tardanza,\newline
\textbf{cuando} el técnico ingresa la fundamentación de su demora en el registro correspondiente,\newline
\textbf{entonces} el sistema almacena el motivo justificatorio vinculado al identificador de la asistencia,\newline
\textbf{y} remite la solicitud de exoneración a la bandeja de revisión de la jefatura de taller.\vspace{4pt}\newline
\textbf{Escenario 2: Notificación del dictamen emitido por la administración}\newline
\textbf{Dado que} la jefatura de taller ha revisado y dictaminado la justificación presentada,\newline
\textbf{cuando} se actualiza el expediente de asistencia en el servidor central,\newline
\textbf{entonces} el sistema actualiza el estado del registro a justificado o desestimado según corresponda,\newline
\textbf{y} notifica al colaborador la resolución con la marca temporal y el identificador del supervisor responsable.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US10.

**Epic 3: Recepción Pericial e Inspección en Patio**

A continuación, se presentan las historias de usuario pertenecientes a la épica número 3, que agrupa las funcionalidades de búsqueda de cliente y vehículo, apertura de órdenes de trabajo por el administrador, registro fotográfico pericial de recepción en patio y el ciclo de propuestas de tareas sobrevenidas en bahía dentro de Atelier Workshop Mobile.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.5cm} | >{\centering\arraybackslash}p{5.0cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-7.5cm-6\tabcolsep-4\arrayrulewidth\relax} |}
\caption{Épica EP03: Recepción Pericial e Inspección en Patio} \label{tbl:ep03} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endfirsthead
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
EP03 & Administrador de taller & Alta \\
\hline
\thfirst{Title} & \multicolumn{2}{p{\dimexpr\textwidth-2.5cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Recepción Pericial e Inspección en Patio} \\
\hline
\thspanfirst{3}{Description} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} administrador de taller,\newline \textbf{quiero} identificar al cliente y vehículo, aperturar la orden de trabajo con sus tareas técnicas, capturar fotos periciales de recepción y gestionar propuestas de reparación sobrevenidas,\newline \textbf{para} formalizar el ingreso a la sucursal, respaldar el estado inicial del automóvil y autorizar trabajos adicionales con evidencia probatoria.} \\
\hline
\end{longtable}

*Nota.* Especificación de la épica EP03 elaborada para el proyecto Atelier.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US11 - Búsqueda y vinculación de cliente y vehículo por placa o documento} \label{tbl:us11} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US11 & Asesor de servicio & Alta & EP03 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Búsqueda y vinculación de cliente y vehículo por placa o documento} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} asesor de servicio,\newline \textbf{quiero} consultar o registrar los datos de identidad del cliente y la ficha técnica del vehículo mediante su placa o documento fiscal,\newline \textbf{para} recuperar el historial de atenciones previas o incorporar una nueva unidad al catálogo del taller.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Identificación y carga de unidad recurrente}\newline
\textbf{Dado que} la placa vehicular o el documento fiscal del propietario ya existen registrados en la plataforma del taller,\newline
\textbf{cuando} el personal de atención efectúa la búsqueda en el módulo de recepción,\newline
\textbf{entonces} el sistema recupera la ficha completa del cliente y las características técnicas del automóvil,\newline
\textbf{y} vincula automáticamente la información al nuevo registro de atención.\vspace{4pt}\newline
\textbf{Escenario 2: Alta de nuevo cliente y unidad en primer ingreso}\newline
\textbf{Dado que} la placa consultada no cuenta con antecedentes registrados en la empresa,\newline
\textbf{cuando} el usuario registra los datos del cliente y los datos técnicos de la unidad vehicular,\newline
\textbf{entonces} el sistema valida la consistencia de los datos suministrados,\newline
\textbf{y} crea las fichas correspondientes en el espacio de trabajo del taller dejándolas disponibles para la orden de servicio.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US11.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US12 - Apertura de orden de trabajo y parametrización de tareas iniciales} \label{tbl:us12} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US12 & Administrador de taller & Alta & EP03 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Apertura de orden de trabajo y parametrización de tareas iniciales} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} administrador de taller,\newline \textbf{quiero} crear la orden de trabajo asentando el kilometraje de odómetro, el resumen diagnóstico inicial y programar las tareas técnicas a realizar,\newline \textbf{para} formalizar el ingreso del vehículo a la sucursal y delegar las faenas a los mecánicos responsables.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Creación de orden de trabajo con kilometraje y diagnóstico}\newline
\textbf{Dado que} el vehículo y el cliente han sido seleccionados para el servicio,\newline
\textbf{cuando} el administrador asienta el kilometraje actual del odómetro y el resumen de síntomas manifestados por el propietario,\newline
\textbf{entonces} el sistema genera el correlativo secuencial único de la orden de trabajo vinculándola a la sucursal,\newline
\textbf{y} asocia la cita previa correspondiente en caso de haber sido reservada con anterioridad.\vspace{4pt}\newline
\textbf{Escenario 2: Desglose de tareas técnicas y asignación a mecánico}\newline
\textbf{Dado que} la orden de trabajo ha sido inicializada en el sistema,\newline
\textbf{cuando} el administrador añade las tareas mecánicas requeridas especificando el servicio base, la bahía de trabajo y el mecánico asignado,\newline
\textbf{entonces} el sistema instancia cada tarea en estado pendiente con su precio de mano de obra y horas estimadas,\newline
\textbf{y} habilita la orden para el inicio de las labores en el taller.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US12.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US13 - Registro pericial de evidencias fotográficas de recepción vehicular} \label{tbl:us13} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US13 & Administrador de taller & Media & EP03 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Registro pericial de evidencias fotográficas de recepción vehicular} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} administrador de taller,\newline \textbf{quiero} registrar evidencias fotográficas del estado exterior de la carrocería del vehículo en el patio y vincularlas a la orden de trabajo,\newline \textbf{para} blindar legalmente a la empresa constatando averías o raspones preexistentes antes de iniciar el servicio.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Carga de evidencias fotográficas de recepción en patio}\newline
\textbf{Dado que} el vehículo se encuentra en el área de recepción y cuenta con una orden de trabajo aperturada,\newline
\textbf{cuando} el personal captura fotografías de los paneles exteriores del vehículo agregando una descripción del daño observado,\newline
\textbf{entonces} el sistema almacena las imágenes vinculándolas unívocamente a la cabecera de la orden de trabajo,\newline
\textbf{y} registra la marca temporal exacta de la captura pericial.\vspace{4pt}\newline
\textbf{Escenario 2: Consulta del expediente fotográfico de recepción}\newline
\textbf{Dado que} una orden de trabajo posee registros fotográficos periciales asociados,\newline
\textbf{cuando} se consulta el detalle pericial de la unidad en servicio,\newline
\textbf{entonces} el sistema presenta la galería ordenada de imágenes con sus notas descriptivas,\newline
\textbf{y} certifica el estado físico en el que el vehículo fue recibido en el establecimiento.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US13.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US14 - Generación de propuesta de tarea adicional por hallazgo en foso} \label{tbl:us14} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US14 & Técnico automotriz & Alta & EP03 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Generación de propuesta de tarea adicional por hallazgo en foso} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} técnico automotriz,\newline \textbf{quiero} registrar una propuesta de tarea adicional con nivel de severidad y fotografía probatoria al hallar un defecto imprevisto en bahía,\newline \textbf{para} reportar al administrador la necesidad de una reparación adicional no identificada en el diagnóstico inicial.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Creación conforme de propuesta con evidencia de daño}\newline
\textbf{Dado que} el técnico automotriz se encuentra ejecutando una labor en bahía y descubre una fuga o rotura no prevista en la orden,\newline
\textbf{cuando} registra la propuesta de tarea indicando el servicio sugerido, calificación de severidad y adjuntando la fotografía del desperfecto,\newline
\textbf{entonces} el sistema crea la propuesta técnica vinculada a la orden de trabajo en estado pendiente de revisión,\newline
\textbf{y} emite una notificación de advertencia en el panel de supervisión del administrador del taller.\vspace{4pt}\newline
\textbf{Escenario 2: Denegación de propuesta ante omisión de evidencia fotográfica}\newline
\textbf{Dado que} el técnico intenta despachar una propuesta técnica calificada con severidad crítica,\newline
\textbf{cuando} envía el formulario sin adjuntar la captura fotográfica del componente dañado,\newline
\textbf{entonces} el sistema bloquea el registro exigiendo la evidencia probatoria obligatoria,\newline
\textbf{y} orienta al colaborador a capturar la imagen de la falla antes de proceder.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US14.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US15 - Notificación y aprobación de propuesta técnica con el cliente} \label{tbl:us15} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US15 & Administrador de taller & Alta & EP03 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Notificación y aprobación de propuesta técnica con el cliente} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} administrador de taller,\newline \textbf{quiero} remitir la propuesta técnica con su respaldo fotográfico al cliente y asentar su veredicto de aprobación o rechazo,\newline \textbf{para} obtener la conformidad del propietario e incorporar la labor autorizada como tarea activa en la orden de trabajo.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Aprobación de propuesta y adición automática a la orden de trabajo}\newline
\textbf{Dado que} el cliente ha revisado la notificación digital con la evidencia fotográfica de la avería y autoriza la reparación complementaria,\newline
\textbf{cuando} el administrador asienta la resolución favorable en el sistema,\newline
\textbf{entonces} el sistema actualiza la propuesta a estado aprobado,\newline
\textbf{y} genera automáticamente una nueva tarea técnica en estado pendiente dentro de la orden de trabajo recalculando el presupuesto proyectado.\vspace{4pt}\newline
\textbf{Escenario 2: Desestimación de propuesta adicional por parte del cliente}\newline
\textbf{Dado que} el cliente opta por no autorizar la intervención correctiva sobrevenida,\newline
\textbf{cuando} el administrador registra la desestimación ingresando las observaciones del propietario,\newline
\textbf{entonces} el sistema actualiza la propuesta a estado rechazado conservando el historial técnico y la imagen,\newline
\textbf{y} mantiene inalterada la estructura de tareas y costos de la orden de trabajo.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US15.

**Epic 4: Diagnóstico Electrónico y Telemetría OBD-II**

A continuación, se presentan las historias de usuario pertenecientes a la épica número 4, que agrupa las funcionalidades de enlace inalámbrico con escáneres OBD-II, extracción de códigos DTC, monitoreo telemétrico de sensores en vivo, resiliencia offline en fosa y generación de diagnósticos predictivos con inteligencia artificial y reportes en PDF en Atelier Workshop Mobile.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.5cm} | >{\centering\arraybackslash}p{5.0cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-7.5cm-6\tabcolsep-4\arrayrulewidth\relax} |}
\caption{Épica EP04: Diagnóstico Electrónico y Telemetría OBD-II} \label{tbl:ep04} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endfirsthead
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
EP04 & Técnico automotriz & Alta \\
\hline
\thfirst{Title} & \multicolumn{2}{p{\dimexpr\textwidth-2.5cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Diagnóstico Electrónico y Telemetría OBD-II} \\
\hline
\thspanfirst{3}{Description} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} técnico automotriz,\newline \textbf{quiero} enlazar el escáner telemático al puerto OBD-II, leer códigos DTC, monitorear sensores en vivo y generar reportes predictivos con inteligencia artificial en un período seleccionado,\newline \textbf{para} identificar fallas con precisión instrumental, contrastar las recomendaciones del modelo con mi criterio pericial y emitir diagnósticos en PDF para el cliente.} \\
\hline
\end{longtable}

*Nota.* Especificación de la épica EP04 elaborada para el proyecto Atelier.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US16 - Enlace inalámbrico y sincronización de escáner OBD-II en bahía} \label{tbl:us16} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US16 & Técnico automotriz & Alta & EP04 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Enlace inalámbrico y sincronización de escáner OBD-II en bahía} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} técnico automotriz,\newline \textbf{quiero} conectar la aplicación móvil al adaptador telemático acoplado en el puerto OBD-II del automóvil,\newline \textbf{para} habilitar el canal de comunicación bidireccional con la unidad de control del motor.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Emparejamiento inalámbrico exitoso con la computadora del auto}\newline
\textbf{Dado que} el adaptador telemático se encuentra encendido en el puerto OBD-II y el vehículo mantiene el encendido en contacto,\newline
\textbf{cuando} el técnico inicia la vinculación desde el dispositivo móvil,\newline
\textbf{entonces} el sistema establece el enlace seguro mediante comandos de inicialización estándar,\newline
\textbf{y} confirma la lectura del protocolo de comunicación vehicular y el número de identificación del chasis.\vspace{4pt}\newline
\textbf{Escenario 2: Notificación ante interrupción de señal o falta de contacto}\newline
\textbf{Dado que} el conmutador de encendido del vehículo se encuentra apagado o el adaptador experimenta una caída de tensión,\newline
\textbf{cuando} se intenta iniciar el enlace de diagnóstico,\newline
\textbf{entonces} el sistema notifica la ausencia de respuesta por parte de la computadora automotriz,\newline
\textbf{y} orienta al técnico a comprobar la alimentación eléctrica del conector y la posición del interruptor de encendido.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US16.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US17 - Extracción y decodificación de códigos de falla computarizados} \label{tbl:us17} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US17 & Técnico automotriz & Alta & EP04 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Extracción y decodificación de códigos de falla computarizados} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} técnico automotriz,\newline \textbf{quiero} interrogar la memoria de averías de la unidad de control vehicular para extraer los códigos de error almacenados y sus datos de cuadro congelado,\newline \textbf{para} determinar los circuitos y actuadores mecánicos que originaron el encendido del testigo de fallo de motor.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Detección y decodificación de anomalías electrónicas}\newline
\textbf{Dado que} la computadora del motor mantiene averías registradas en su memoria no volátil,\newline
\textbf{cuando} el técnico ejecuta el escaneo pericial de códigos de diagnóstico,\newline
\textbf{entonces} el sistema extrae los identificadores de falla alfanuméricos, su descripción normalizada y las variables motrices capturadas en el instante del fallo,\newline
\textbf{y} los asocia automáticamente al expediente de diagnóstico de la orden de trabajo activa.\vspace{4pt}\newline
\textbf{Escenario 2: Confirmación de sistema motriz sin registros de avería}\newline
\textbf{Dado que} el vehículo no presenta desperfectos almacenados ni testigos de alerta activos,\newline
\textbf{cuando} se finaliza la secuencia de interrogación electrónica,\newline
\textbf{entonces} el sistema certifica la ausencia de códigos de anomalía en la memoria de la unidad de control,\newline
\textbf{y} asienta el resultado conforme en el registro de peritaje.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US17.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US18 - Monitoreo dinámico de parámetros telemétricos en tiempo real} \label{tbl:us18} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US18 & Técnico automotriz & Media & EP04 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Monitoreo dinámico de parámetros telemétricos en tiempo real} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} técnico automotriz,\newline \textbf{quiero} supervisar flujos continuos de revoluciones de motor, temperatura de refrigerante, presión de admisión y voltaje eléctrico en la unidad intervenida,\newline \textbf{para} analizar el comportamiento térmico y dinámico del propulsor bajo condiciones de prueba.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Recepción continua y cálculo de métricas en ralentí y marcha}\newline
\textbf{Dado que} el motor del vehículo se encuentra en operación de prueba en la bahía de servicio,\newline
\textbf{cuando} el técnico activa la lectura en tiempo real de los canales de telemetría seleccionados,\newline
\textbf{entonces} el sistema procesa periódicamente las tramas de datos actualizando los valores numéricos instantáneos,\newline
\textbf{y} resalta con indicadores de precaución cualquier lectura que rebase los umbrales nominales de operación del fabricante.\vspace{4pt}\newline
\textbf{Escenario 2: Congelamiento de datos instantáneos para análisis pericial}\newline
\textbf{Dado que} se observa una oscilación anómala en la temperatura o en el voltaje del alternador durante la aceleración,\newline
\textbf{cuando} el técnico instruye la fijación temporal de la muestra telemétrica,\newline
\textbf{entonces} el sistema congela el conjunto de parámetros instantáneos,\newline
\textbf{y} permite vincular la instantánea de datos como anexo técnico probatorio de la orden de trabajo.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US18.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US19 - Almacenamiento local resiliente y sincronización diferida en fosa} \label{tbl:us19} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US19 & Técnico automotriz & Alta & EP04 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Almacenamiento local resiliente y sincronización diferida en fosa} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} técnico automotriz,\newline \textbf{quiero} registrar diagnósticos computarizados y lecturas de telemetría de forma autónoma sin depender de conectividad a internet en áreas apantalladas o fosas subterráneas,\newline \textbf{para} garantizar la continuidad operativa del escaneo y sincronizar los resultados al recuperar enlace de datos.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Persistencia local de registros telemétricos en zona desconectada}\newline
\textbf{Dado que} la bahía de servicio o fosa de inspección carece de señal de red inalámbrica o cobertura de telefonía móvil,\newline
\textbf{cuando} el técnico finaliza la extracción de datos computarizados del vehículo,\newline
\textbf{entonces} el sistema resguarda íntegramente las tramas de telemetría y códigos de fallo en la base de datos local del dispositivo móvil,\newline
\textbf{y} mantiene el expediente en cola con estado de sincronización pendiente.\vspace{4pt}\newline
\textbf{Escenario 2: Sincronización automática en bloque con el servidor central}\newline
\textbf{Dado que} el dispositivo móvil restablece la conectividad con la red del taller al salir de la fosa,\newline
\textbf{cuando} el servicio de sincronización en segundo plano detecta enlace estable a internet,\newline
\textbf{entonces} el sistema despacha automáticamente el lote de registros telemétricos pendientes hacia la plataforma central,\newline
\textbf{y} actualiza la orden de trabajo en la nube preservando la marca temporal original de captura en el foso.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US19.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US20 - Borrado y verificación de restablecimiento de fallas en la computadora} \label{tbl:us20} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US20 & Técnico automotriz & Media & EP04 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Borrado y verificación de restablecimiento de fallas en la computadora} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} técnico automotriz,\newline \textbf{quiero} transmitir el comando de borrado de códigos de avería a la unidad de control y comprobar el apagado de testigos tras completar la reparación física,\newline \textbf{para} validar el éxito de la intervención mecánica y asegurar la entrega del vehículo en estado óptimo.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Restablecimiento exitoso de memoria de averías y comprobación}\newline
\textbf{Dado que} la intervención mecánica correctiva ha finalizado satisfactoriamente y el motor se encuentra apagado con el conmutador en contacto,\newline
\textbf{cuando} el técnico confirma la orden de borrado de códigos de error,\newline
\textbf{entonces} el sistema transmite la instrucción normalizada de limpieza a la computadora vehicular, efectúa una re-interrogación inmediata,\newline
\textbf{y} confirma que la memoria de averías quedó vacía y el testigo de advertencia se encuentra apagado.\vspace{4pt}\newline
\textbf{Escenario 2: Detección de persistencia de fallo por subsistencia de avería física}\newline
\textbf{Dado que} el componente mecánico o sensor reemplazado presenta un problema de cableado o defecto no subsanado,\newline
\textbf{cuando} se ejecuta la secuencia de borrado de códigos,\newline
\textbf{entonces} el sistema detecta la reaparición inmediata del código de avería en la comprobación posterior,\newline
\textbf{y} notifica al técnico la persistencia de la condición anómala requiriendo una nueva revisión física del circuito.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US20.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US21 - Generación de informe pericial predictivo con inteligencia artificial y exportación en PDF} \label{tbl:us21} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US21 & Técnico automotriz & Alta & EP04 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Generación de informe pericial predictivo con inteligencia artificial y exportación en PDF} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} técnico automotriz,\newline \textbf{quiero} solicitar un diagnóstico predictivo asistido por inteligencia artificial seleccionando una ventana temporal de telemetría y generar un reporte en PDF,\newline \textbf{para} contrastar las recomendaciones del modelo con mi criterio mecánico profesional y emitir un dictamen pericial preventivo de alta precisión para el cliente.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Generación de dictamen predictivo sobre período telemétrico seleccionado}\newline
\textbf{Dado que} el vehículo cuenta con registros de telemetría y fallos capturados a lo largo de un período de tiempo definido por el técnico,\newline
\textbf{cuando} el técnico solicita el análisis predictivo para la ventana temporal seleccionada,\newline
\textbf{entonces} el sistema procesa las variables termodinámicas y códigos de avería mediante el modelo de inteligencia artificial, calcula el índice de salud vehicular y el nivel de certeza del diagnóstico,\newline
\textbf{y} presenta las anomalías proyectadas con los servicios correctivos sugeridos para validación del técnico.\vspace{4pt}\newline
\textbf{Escenario 2: Emisión y descarga de reporte pericial en formato PDF}\newline
\textbf{Dado que} el técnico ha revisado las recomendaciones del modelo y ratificado el diagnóstico según su criterio profesional,\newline
\textbf{cuando} confirma la generación del informe formal de salud vehicular,\newline
\textbf{entonces} el sistema renderiza un documento estructurado en formato PDF que consolida el historial de códigos DTC, curvas estadísticas de sensores, el dictamen pericial y las recomendaciones de mantenimiento,\newline
\textbf{y} lo vincula como anexo documental a la orden de trabajo para su remisión al cliente.\vspace{4pt}\newline
\textbf{Escenario 3: Notificación de telemetría insuficiente para inferencia predictiva}\newline
\textbf{Dado que} la unidad vehicular carece de suficientes tramas telemétricas continuas en el rango de fechas seleccionado,\newline
\textbf{cuando} se solicita la ejecución del modelo de inteligencia artificial,\newline
\textbf{entonces} el sistema advierte que el volumen de datos muestreados es insuficiente para emitir un diagnóstico predictivo confiable,\newline
\textbf{y} orienta al técnico a ampliar la ventana de tiempo o realizar un escaneo directo en bahía.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US21.

**Epic 5: Presupuestos y Cotizaciones de Mantenimiento**

A continuación, se presentan las historias de usuario pertenecientes a la épica número 5, que agrupa las funcionalidades de cálculo automático en cascada de costos, supervisión de imputación de repuestos por el personal, emisión de proformas en PDF y formalización de aprobaciones comerciales en Atelier Workshop Mobile.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.5cm} | >{\centering\arraybackslash}p{5.0cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-7.5cm-6\tabcolsep-4\arrayrulewidth\relax} |}
\caption{Épica EP05: Presupuestos y Cotizaciones de Mantenimiento} \label{tbl:ep05} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endfirsthead
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
EP05 & Administrador de taller & Alta \\
\hline
\thfirst{Title} & \multicolumn{2}{p{\dimexpr\textwidth-2.5cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Presupuestos y Cotizaciones de Mantenimiento} \\
\hline
\thspanfirst{3}{Description} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} administrador de taller,\newline \textbf{quiero} disponer del cálculo automático de costos de tareas y repuestos, auditar asignaciones de almacén y asentar la conformidad del cliente,\newline \textbf{para} garantizar la transparencia tarifaria del taller y formalizar el inicio de labores tras la aceptación de la cotización.} \\
\hline
\end{longtable}

*Nota.* Especificación de la épica EP05 elaborada para el proyecto Atelier.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US22 - Cómputo automático en cascada de costos de tareas e impuestos} \label{tbl:us22} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US22 & Administrador de taller & Alta & EP05 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Cómputo automático en cascada de costos de tareas e impuestos} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} administrador de taller,\newline \textbf{quiero} que el sistema calcule automáticamente el precio de cada tarea, el subtotal acumulado, el impuesto de ley y el total general,\newline \textbf{para} eliminar discrepancias aritméticas manuales y mantener la integridad contable de la orden de trabajo.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Cálculo en cascada por adición de servicios y repuestos}\newline
\textbf{Dado que} una orden de trabajo incluye tareas técnicas con tarifas base de mano de obra y productos imputados con precio unitario y cantidad,\newline
\textbf{cuando} el sistema procesa los valores de la orden,\newline
\textbf{entonces} calcula el precio de cada tarea sumando la tarifa base del servicio y el importe total de sus productos asociados,\newline
\textbf{y} liquida el subtotal de la orden como la sumatoria de los precios de sus tareas, calculando el dieciocho por ciento de impuesto y el monto total final.\vspace{4pt}\newline
\textbf{Escenario 2: Recálculo dinámico ante variaciones de insumos o mano de obra}\newline
\textbf{Dado que} se modifica la cantidad de un repuesto asignado o se incorpora una labor mecánica complementaria,\newline
\textbf{cuando} se confirman las modificaciones en la tarea correspondiente,\newline
\textbf{entonces} el sistema actualiza automáticamente el precio individual de la tarea intervenida,\newline
\textbf{y} propaga el recálculo inmediato hacia el subtotal, impuesto y total de la cabecera de la orden de trabajo.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US22.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US23 - Imputación de repuestos a tareas y supervisión administrativa} \label{tbl:us23} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US23 & Personal de taller & Alta & EP05 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Imputación de repuestos a tareas y supervisión administrativa} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} personal de taller (mecánico o administrador),\newline \textbf{quiero} agregar productos del catálogo a una tarea mecánica y alertar a la administración sobre consumos realizados en bahía,\newline \textbf{para} aprovisionar los materiales necesarios y permitir al administrador auditar o retirar piezas no aplicables reintegrándolas al almacén.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Imputación de repuesto por el mecánico con alerta de supervisión}\newline
\textbf{Dado que} el mecánico requiere instalar un componente de almacén para ejecutar la labor asignada en bahía,\newline
\textbf{cuando} selecciona el producto del catálogo y registra la cantidad requerida en la tarea técnica,\newline
\textbf{entonces} el sistema vincula el artículo a la tarea actualizando su costo acumulado,\newline
\textbf{y} despacha una notificación de supervisión al panel del administrador de taller detallando el ítem, la tarea y la orden receptora.\vspace{4pt}\newline
\textbf{Escenario 2: Retiro de producto improcedente por el administrador y reintegro a almacén}\newline
\textbf{Dado que} el administrador evalúa el repuesto imputado por el mecánico y constata tras coordinación verbal que la pieza no corresponde a la especificación del vehículo,\newline
\textbf{cuando} el administrador remueve el producto de la tarea técnica,\newline
\textbf{entonces} el sistema desvincula el artículo de la tarea recalculando los importes hacia la baja,\newline
\textbf{y} reintegra de forma lógica las unidades retiradas al inventario disponible del almacén.\vspace{4pt}\newline
\textbf{Escenario 3: Imputación directa de materiales por el administrador}\newline
\textbf{Dado que} el administrador formula la programación de materiales de una orden de trabajo,\newline
\textbf{cuando} asocia directamente los repuestos requeridos a las tareas correspondientes,\newline
\textbf{entonces} el sistema efectúa la afectación de existencias y actualiza los costos presupuestados sin requerir confirmación adicional.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US23.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US24 - Generación y remisión digital de proforma comercial en PDF} \label{tbl:us24} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US24 & Administrador de taller & Media & EP05 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Generación y remisión digital de proforma comercial en PDF} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} administrador de taller,\newline \textbf{quiero} generar un documento de cotización estructurado en formato PDF y remitirlo digitalmente al cliente,\newline \textbf{para} proporcionarle un desglose claro de mano de obra, repuestos y costos totales previo a solicitar su conformidad.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Generación de proforma comercial estandarizada en PDF}\newline
\textbf{Dado que} la orden de trabajo cuenta con sus tareas técnicas y repuestos debidamente costeados,\newline
\textbf{cuando} el administrador solicita la exportación de la proforma comercial,\newline
\textbf{entonces} el sistema genera un archivo PDF formal con los datos fiscales del taller, ficha del auto, tabla desglosada de tareas y piezas, subtotal, impuesto y plazo de validez,\newline
\textbf{y} lo almacena como anexo documental descargable en el expediente de la orden.\vspace{4pt}\newline
\textbf{Escenario 2: Despacho digital de cotización al contacto del cliente}\newline
\textbf{Dado que} el documento PDF de cotización ha sido generado conforme,\newline
\textbf{cuando} el administrador confirma el envío digital hacia el cliente,\newline
\textbf{entonces} el sistema remite el enlace seguro de acceso por mensajería o correo electrónico,\newline
\textbf{y} asienta el registro de proforma entregada dejando la orden lista para la consulta de aceptación.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US24.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US25 - Formalización de resolución de presupuesto tras comunicación externa} \label{tbl:us25} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US25 & Administrador de taller & Alta & EP05 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Formalización de resolución de presupuesto tras comunicación externa} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} administrador de taller,\newline \textbf{quiero} asentar en el sistema la decisión de aceptación o desistimiento comunicada externamente por el cliente,\newline \textbf{para} habilitar el inicio formal de las faenas mecánicas en bahía o cancelar la orden liberando los materiales.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Asentamiento de conformidad externa y transición a orden en progreso}\newline
\textbf{Dado que} el cliente manifiesta verbalmente, por llamada o mensajería su aceptación de los costos y condiciones de la cotización remitida,\newline
\textbf{cuando} el administrador registra la conformidad del propietario en la plataforma móvil,\newline
\textbf{entonces} el sistema actualiza el estado de la orden de trabajo a en progreso,\newline
\textbf{y} habilita formalmente las tareas asignadas para que los mecánicos inicien el cronometraje y ejecución en bahía.\vspace{4pt}\newline
\textbf{Escenario 2: Asentamiento de desistimiento del cliente y cancelación de orden}\newline
\textbf{Dado que} el cliente comunica externamente que no autoriza los trabajos cotizados,\newline
\textbf{cuando} el administrador asienta el rechazo en el sistema especificando el motivo del desistimiento,\newline
\textbf{entonces} el sistema actualiza el estado de la orden de trabajo a cancelada,\newline
\textbf{y} libera automáticamente las reservas de repuestos reintegrándolos a disponibilidad en almacén y disponiendo el vehículo para retiro.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US25.

**Epic 6: Ejecución de Tareas en Bahía de Servicio**

A continuación, se presentan las historias de usuario pertenecientes a la épica número 6, que agrupa las funcionalidades de consulta y priorización de labores mecánicas en bahía, cronometraje de labor efectiva, pausas operativas por turno o refrigerio con validación contra turnos laborales, registro fotográfico pericial de desmontaje y montaje en foso (`work_order_task_images`), solicitud y validación administrativa de suspensiones por piezas defectuosas y cierre técnico de faenas en Atelier Workshop Mobile.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.5cm} | >{\centering\arraybackslash}p{5.0cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-7.5cm-6\tabcolsep-4\arrayrulewidth\relax} |}
\caption{Épica EP06: Ejecución de Tareas en Bahía de Servicio} \label{tbl:ep06} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endfirsthead
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
EP06 & Técnico automotriz & Alta \\
\hline
\thfirst{Title} & \multicolumn{2}{p{\dimexpr\textwidth-2.5cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Ejecución de Tareas en Bahía de Servicio} \\
\hline
\thspanfirst{3}{Description} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} técnico automotriz,\newline \textbf{quiero} gestionar mis tareas mecánicas asignadas en bahía, cronometrar tiempos efectivos de mano de obra con pausas auditadas y capturar evidencias fotográficas del desmontaje y montaje de piezas,\newline \textbf{para} garantizar una ejecución metódica del servicio, sustentar pericialmente el trabajo ante el cliente y transparentar las horas hombre laboradas.} \\
\hline
\end{longtable}

*Nota.* Especificación de la épica EP06 elaborada para el proyecto Atelier.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US26 - Consulta y priorización de tareas mecánicas asignadas en bahía} \label{tbl:us26} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US26 & Técnico automotriz & Alta & EP06 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Consulta y priorización de tareas mecánicas asignadas en bahía} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} técnico automotriz,\newline \textbf{quiero} consultar en mi dispositivo móvil el listado ordenado de tareas mecánicas asignadas a mi nombre en las distintas órdenes de trabajo,\newline \textbf{para} organizar las intervenciones del día según prioridad operativa y preparar las herramientas necesarias.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Consulta de asignaciones activas de la jornada}\newline
\textbf{Dado que} el técnico automotriz inicia sesión en Atelier Workshop Mobile dentro de su sucursal de trabajo,\newline
\textbf{cuando} accede a la sección de asignaciones operativas en bahía,\newline
\textbf{entonces} el sistema presenta las tareas pendientes y en progreso asignadas a su identificador de colaborador,\newline
\textbf{y} muestra para cada labor la placa vehicular, el servicio solicitado, el tiempo estimado de mano de obra y la bahía asignada.\vspace{4pt}\newline
\textbf{Escenario 2: Notificación en tiempo real de nueva labor asignada}\newline
\textbf{Dado que} el administrador de taller asigna una nueva tarea de mantenimiento a un mecánico en turno,\newline
\textbf{cuando} el sistema asienta la delegación de la labor técnica,\newline
\textbf{entonces} emite una alerta inmediata al dispositivo móvil del operario,\newline
\textbf{y} actualiza de manera automática su cola de trabajo incorporando la tarea con sus instrucciones técnicas.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US26.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US27 - Cronometraje de labor efectiva, pausas operativas y sincronización con turnos laborales} \label{tbl:us27} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US27 & Técnico automotriz & Alta & EP06 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Cronometraje de labor efectiva, pausas operativas y sincronización con turnos laborales} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} técnico automotriz,\newline \textbf{quiero} registrar el inicio de labor en bahía, pausar el cronómetro por refrigerio o fin de turno y sincronizar la suspensión con mi horario laboral validado,\newline \textbf{para} garantizar un cómputo exacto de horas hombre efectivas, notificar mis pausas a la supervisión e impedir registros anómalos fuera de mi turno.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Inicio formal de cronometraje en bahía de servicio}\newline
\textbf{Dado que} la tarea técnica se encuentra asignada al operario y el vehículo está posicionado en la bahía de trabajo,\newline
\textbf{cuando} el técnico confirma el inicio de la intervención mecánica en el dispositivo móvil,\newline
\textbf{entonces} el sistema actualiza el estado de la tarea a en progreso, registra la marca temporal exacta de inicio,\newline
\textbf{y} activa el cronómetro continuo de horas hombre efectivas computando los tiempos de labor.\vspace{4pt}\newline
\textbf{Escenario 2: Pausa por horario de refrigerio con notificación al supervisor}\newline
\textbf{Dado que} el técnico automotriz interrumpe temporalmente la intervención por su período de refrigerio habitual,\newline
\textbf{cuando} instruye la pausa operativa en la plataforma móvil,\newline
\textbf{entonces} el sistema detiene inmediatamente el cómputo de horas hombre efectivas acumulando los segundos transcurridos,\newline
\textbf{y} emite una notificación de alerta al administrador con la hora exacta y el colaborador en refrigerio para auditar la legitimidad del intervalo.\vspace{4pt}\newline
\textbf{Escenario 3: Bloqueo de pausa anticipada por presunto fin de turno ante turno vigente}\newline
\textbf{Dado que} el técnico intenta pausar su labor bajo la justificación de culminación de jornada a las cuatro de la tarde, pero el registro de turnos asignados en gestión de personal establece su horario de salida a las cinco de la tarde,\newline
\textbf{cuando} envía la instrucción de pausa por fin de turno,\newline
\textbf{entonces} el sistema contrasta la hora del servidor contra el horario del turno asignado,\newline
\textbf{y} rechaza la instrucción por inconsistencia horaria, manteniendo la tarea en progreso y alertando al administrador del intento de pausa prematura.\vspace{4pt}\newline
\textbf{Escenario 4: Pausa automática por fin de turno laboral o marcación de salida mediante eventos de dominio}\newline
\textbf{Dado que} culmina la franja horaria configurada en el turno de trabajo o el técnico registra su marcación de salida laboral en el sistema de asistencia,\newline
\textbf{cuando} el contexto de gestión de personal publica el evento de salida laboral procesado a través de la capa anticorrupción,\newline
\textbf{entonces} el sistema de operaciones pausa automáticamente la tarea activa del operario deteniendo el cronómetro,\newline
\textbf{y} notifica al administrador del cese automático de faena consolidando el tiempo efectivo acumulado de la jornada.\vspace{4pt}\newline
\textbf{Escenario 5: Reanudación de la faena tras pausa operativa}\newline
\textbf{Dado que} una tarea se encuentra pausada por refrigerio o por cambio de guardia laboral y el técnico retorna a la bahía,\newline
\textbf{cuando} confirma la reanudación de la labor técnica en el dispositivo,\newline
\textbf{entonces} el sistema reactiva el cronómetro sumando el nuevo tiempo al acumulado previo,\newline
\textbf{y} notifica al supervisor el reinicio de los trabajos en bahía.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US27.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US28 - Registro fotográfico pericial de desmontaje y montaje de piezas en foso} \label{tbl:us28} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US28 & Técnico automotriz & Alta & EP06 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Registro fotográfico pericial de desmontaje y montaje de piezas en foso} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} técnico automotriz,\newline \textbf{quiero} capturar fotografías de la pieza desgastada desmontada y del repuesto nuevo instalado en la tarea técnica,\newline \textbf{para} vincular las evidencias en el registro de tareas y respaldar pericialmente la ejecución física del servicio ante el cliente.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Captura de fotografía de pieza defectuosa desmontada}\newline
\textbf{Dado que} el técnico automotriz extrae un componente mecánico severamente deteriorado durante la ejecución de la tarea,\newline
\textbf{cuando} registra la evidencia fotográfica clasificándola como defecto en la aplicación móvil,\newline
\textbf{entonces} el sistema almacena la fotografía vinculada a la tarea específica,\newline
\textbf{y} genera la marca temporal probatoria del hallazgo en el registro técnico.\vspace{4pt}\newline
\textbf{Escenario 2: Captura de evidencia de repuesto nuevo instalado}\newline
\textbf{Dado que} el operario concluye el montaje del nuevo repuesto en el conjunto mecánico del vehículo,\newline
\textbf{cuando} captura la fotografía de comprobación tipificándola como labor completada,\newline
\textbf{entonces} el sistema anexa la imagen al registro de evidencias de la tarea técnica,\newline
\textbf{y} consolida el expediente visual para sustentar la liquidación y entrega final al cliente.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US28.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US29 - Solicitud y validación administrativa de suspensión por pieza defectuosa indispensable} \label{tbl:us29} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US29 & Personal de taller & Alta & EP06 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Solicitud y validación administrativa de suspensión por pieza defectuosa indispensable} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} personal de taller,\newline \textbf{quiero} gestionar la solicitud de suspensión técnica cuando una pieza de recambio suministrada presente defecto insalvable que impida continuar la faena,\newline \textbf{para} que el administrador audite la justificación técnica y autorice formalmente el pase a espera o desestime la pausa obligando a continuar en progreso.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Solicitud de suspensión por defecto insalvable de pieza y aprobación administrativa a estado en espera}\newline
\textbf{Dado que} el técnico automotriz constata durante la faena que el repuesto suministrado presenta un defecto de fabricación o daño físico crítico que impide continuar el ensamblaje de la tarea,\newline
\textbf{cuando} emite la solicitud de suspensión especificando la justificación técnica de la pieza defectuosa y el ítem faltante a reponer,\newline
\textbf{entonces} el sistema notifica inmediatamente al administrador con el detalle probatorio de la avería,\newline
\textbf{y} al validar el supervisor que la causa es razonable e incapacitante para continuar, aprueba la suspensión transicionando la tarea al estado en espera y congelando el cronómetro.\vspace{4pt}\newline
\textbf{Escenario 2: Desestimación de la suspensión por el administrador y continuidad obligatoria en progreso}\newline
\textbf{Dado que} el administrador evalúa la justificación técnica enviada por el operario y constata que la observación de la pieza no bloquea la continuidad ni compromete la seguridad del ensamblaje,\newline
\textbf{cuando} el administrador rechaza la solicitud de suspensión en la plataforma,\newline
\textbf{entonces} el sistema mantiene la tarea inalterada en estado en progreso,\newline
\textbf{y} continúa el cronometraje ininterrumpido notificando al operario la resolución denegatoria para proseguir con la faena asignada.\vspace{4pt}\newline
\textbf{Escenario 3: Reanudación de la faena tras suministro del repuesto conforme}\newline
\textbf{Dado que} la tarea se encuentra formalmente en estado en espera y el área de almacén entrega la pieza sustituta en óptimas condiciones físicas,\newline
\textbf{cuando} el técnico confirma la recepción del repuesto idóneo e instruye la reanudación del trabajo,\newline
\textbf{entonces} el sistema restituye la tarea al estado en progreso reactivando el cronómetro de horas hombre,\newline
\textbf{y} consolida los minutos acumulados en suspensión dentro del expediente de la orden de trabajo.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US29.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US30 - Cierre técnico de tarea con cómputo de horas hombre efectivas} \label{tbl:us30} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US30 & Técnico automotriz & Alta & EP06 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Cierre técnico de tarea con cómputo de horas hombre efectivas} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} técnico automotriz,\newline \textbf{quiero} registrar la finalización formal de la faena mecánica en la aplicación móvil,\newline \textbf{para} cerrar el cómputo de horas hombre reales trabajadas y habilitar la orden para el control de calidad.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Cierre técnico conforme de la labor mecánica}\newline
\textbf{Dado que} el técnico ha completado el ensamblaje, pruebas mecánicas y adjuntado las evidencias fotográficas de montaje,\newline
\textbf{cuando} confirma la culminación de la tarea en el dispositivo móvil,\newline
\textbf{entonces} el sistema detiene definitivamente el cronómetro, liquida las horas hombre efectivas en formato decimal,\newline
\textbf{y} actualiza el estado de la tarea a completada registrando la marca temporal de cierre.\vspace{4pt}\newline
\textbf{Escenario 2: Transición automática de la orden ante culminación de todas las tareas}\newline
\textbf{Dado que} el técnico finaliza la última tarea pendiente perteneciente a una orden de trabajo,\newline
\textbf{cuando} se asienta el cierre técnico de dicha labor,\newline
\textbf{entonces} el sistema constata que la totalidad de tareas mecánicas se encuentran culminadas,\newline
\textbf{y} actualiza el estado de la orden de trabajo notificando al supervisor que el vehículo está listo para la inspección final de calidad.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US30.

**Epic 7: Abastecimiento y Descargo de Repuestos FIFO**

A continuación, se presentan las historias de usuario pertenecientes a la épica número 7, que agrupa las funcionalidades de consulta de catálogo de repuestos, descargo físico y contable bajo algoritmo FIFO por lotes de adquisición (`inventory_batches`), reincorporación lógica de materiales a inventario, alertas preventivas de quiebre de stock e imputación automática de precios de venta en Atelier Workshop Mobile.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.5cm} | >{\centering\arraybackslash}p{5.0cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-7.5cm-6\tabcolsep-4\arrayrulewidth\relax} |}
\caption{Épica EP07: Abastecimiento y Descargo de Repuestos FIFO} \label{tbl:ep07} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endfirsthead
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
EP07 & Personal de taller & Media \\
\hline
\thfirst{Title} & \multicolumn{2}{p{\dimexpr\textwidth-2.5cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Abastecimiento y Descargo de Repuestos FIFO} \\
\hline
\thspanfirst{3}{Description} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} personal de taller,\newline \textbf{quiero} consultar existencias de catálogo, liquidar descargos bajo la regla contable FIFO por lote, restituir materiales no utilizados y liquidar precios automáticos,\newline \textbf{para} preservar la exactitud del kardex valorizado, calcular márgenes comerciales reales y prevenir quiebres de inventario que interrumpan los servicios.} \\
\hline
\end{longtable}

*Nota.* Especificación de la épica EP07 elaborada para el proyecto Atelier.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US31 - Búsqueda y consulta de disponibilidad de repuestos en catálogo} \label{tbl:us31} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US31 & Personal de taller & Alta & EP07 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Búsqueda y consulta de disponibilidad de repuestos en catálogo} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} personal de taller (técnico o administrador),\newline \textbf{quiero} buscar piezas por SKU, categoría o denominación comercial para verificar existencias físicas y precio,\newline \textbf{para} determinar la viabilidad inmediata de su instalación en bahía sin requerir verificación manual en anaquel.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Búsqueda exitosa con saldo disponible positivo}\newline
\textbf{Dado que} el usuario ingresa el código SKU o término comercial de un repuesto activo en la plataforma móvil,\newline
\textbf{cuando} ejecuta la consulta en el catálogo de inventario,\newline
\textbf{entonces} el sistema presenta la denominación comercial del artículo, el código SKU, la categoría automotriz, el precio de venta unitario y el stock total consolidado disponible,\newline
\textbf{y} habilita la selección del material para su consumo en órdenes de trabajo activas.\vspace{4pt}\newline
\textbf{Escenario 2: Restricción de selección ante repuesto con saldo en cero}\newline
\textbf{Dado que} un artículo del catálogo registra un stock total consolidado en cero unidades en el almacén del taller,\newline
\textbf{cuando} el colaborador consulta el artículo en el listado de materiales,\newline
\textbf{entonces} el sistema visualiza la partida resaltando el indicador de existencia agotada,\newline
\textbf{y} bloquea la selección para adición inmediata en tareas mecánicas indicando que requiere orden de reabastecimiento.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US31.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US32 - Descargo contable y físico automatizado mediante regla estricta FIFO por lote} \label{tbl:us32} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US32 & Personal de taller & Alta & EP07 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Descargo contable y físico automatizado mediante regla estricta FIFO por lote} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} personal de taller (técnico o administrador),\newline \textbf{quiero} registrar el consumo de repuestos en una tarea mecánica rebajando los lotes cronológicos de adquisición más antiguos,\newline \textbf{para} valorizar con exactitud el costo de ventas bajo el método FIFO e impedir la asignación de materiales inexistentes.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Descargo cronológico FIFO a partir del lote más antiguo}\newline
\textbf{Dado que} existen múltiples lotes de adquisición para un juego de pastillas de freno con distintas fechas de ingreso,\newline
\textbf{cuando} el usuario confirma la instalación de dos unidades en la tarea mecánica asignada,\newline
\textbf{entonces} el sistema identifica el lote con saldo remanente positivo y fecha de ingreso más antigua,\newline
\textbf{y} deduce las unidades de dicho lote actualizando su saldo remanente, rebaja el stock consolidado del artículo y asienta la imputación en la orden de trabajo.\vspace{4pt}\newline
\textbf{Escenario 2: Imputación multi-lote ante saldo parcial en lote inicial}\newline
\textbf{Dado que} la cantidad de aceite requerida para el servicio es de cuatro galones, pero el lote FIFO más antiguo solo cuenta con un saldo de un galón disponible,\newline
\textbf{cuando} se procesa el consumo en la tarea técnica,\newline
\textbf{entonces} el sistema agota completamente el saldo del lote inicial transicionándolo a cero remanente,\newline
\textbf{y} descuenta los tres galones restantes del siguiente lote cronológicamente subsiguiente, vinculando ambos orígenes al costo real de la faena.\vspace{4pt}\newline
\textbf{Escenario 3: Bloqueo de descargo por saldo insuficiente en almacén}\newline
\textbf{Dado que} el operario intenta imputar cinco unidades de un filtro cuya existencia física consolidada en almacén es de solo dos unidades,\newline
\textbf{cuando} solicita confirmar el descargo de inventario,\newline
\textbf{entonces} el sistema rechaza la transacción impidiendo saldos negativos,\newline
\textbf{y} notifica la falta de existencias suficientes para completar la cantidad especificada.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US32.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US33 - Reincorporación lógica de materiales a inventario por remoción en tarea técnica} \label{tbl:us33} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US33 & Administrador de taller & Media & EP07 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Reincorporación lógica de materiales a inventario por remoción en tarea técnica} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} administrador de taller,\newline \textbf{quiero} revertir la asignación de un repuesto registrado erróneamente en una tarea técnica y devolverlo a disponibilidad de almacén,\newline \textbf{para} corregir el presupuesto de la orden y reintegrar las unidades a los lotes físicos de inventario.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Reintegro exitoso de repuesto al lote de procedencia}\newline
\textbf{Dado que} el administrador coordina con el mecánico la no aplicación de un repuesto previamente asignado a una tarea en bahía,\newline
\textbf{cuando} el administrador ejecuta la eliminación del material en el desglose de productos de la faena,\newline
\textbf{entonces} el sistema cancela la imputación del artículo en la tarea recalculando el precio de la orden,\newline
\textbf{y} repone de forma inmediata las unidades al saldo remanente del lote físico correspondiente e incrementa el stock total disponible en almacén.\vspace{4pt}\newline
\textbf{Escenario 2: Auditoría y trazabilidad del reintegro de materiales}\newline
\textbf{Dado que} se concreta la reversión de un repuesto desde una orden de trabajo activa,\newline
\textbf{cuando} el sistema asienta el retorno físico de las piezas al inventario,\newline
\textbf{entonces} genera un registro de auditoría con la identidad del administrador, la marca temporal exacta y la orden origen,\newline
\textbf{y} actualiza el estado del inventario para su consulta inmediata en la plataforma móvil.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US33.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US34 - Disparo y desactivación de alertas automáticas de reposición por stock mínimo} \label{tbl:us34} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US34 & Administrador de taller & Media & EP07 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Disparo y desactivación de alertas automáticas de reposición por stock mínimo} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} administrador de taller,\newline \textbf{quiero} recibir alertas cuando el stock de un repuesto alcance el umbral mínimo configurado y que se desactiven al ingresar nuevas compras,\newline \textbf{para} gestionar oportunamente las adquisiciones a proveedores antes de que ocurra una rotura operativa en bahía.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Disparo de alerta crítica por consumo bajo el umbral de seguridad}\newline
\textbf{Dado que} un ítem de alta rotación posee un umbral de seguridad establecido en diez unidades y el saldo disponible se reduce a nueve tras un descargo en bahía,\newline
\textbf{cuando} el sistema asienta la transacción de salida en el inventario,\newline
\textbf{entonces} detecta que el stock consolidado es menor o igual al valor mínimo permitido,\newline
\textbf{y} emite una notificación de advertencia al administrador del taller marcando el artículo en estado de reposición requerida.\vspace{4pt}\newline
\textbf{Escenario 2: Desactivación automática de la alerta tras recepción de compra}\newline
\textbf{Dado que} un repuesto mantiene activa una alerta por nivel crítico de existencias y se asienta la recepción de un nuevo lote procedente de una orden de compra,\newline
\textbf{cuando} el sistema procesa el ingreso de mercadería elevando el stock disponible por encima del umbral mínimo,\newline
\textbf{entonces} cancela de forma automática la condición de advertencia en el catálogo,\newline
\textbf{y} remueve la alerta de la bandeja de notificaciones operativas.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US34.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US35 - Imputación automática de precios de venta de catálogo y conciliación de margen FIFO} \label{tbl:us35} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US35 & Personal de taller & Alta & EP07 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Imputación automática de precios de venta de catálogo y conciliación de margen FIFO} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} personal de taller (técnico o administrador),\newline \textbf{quiero} que el sistema replique automáticamente el precio base del catálogo al registrar productos en tareas y concilie el costo de adquisición de los lotes consumidos,\newline \textbf{para} garantizar un cobro transparente y uniforme al cliente, automatizar los importes de la orden y registrar la rentabilidad bruta real del servicio.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Replicación automática de precio de catálogo y cálculo de importe de tarea}\newline
\textbf{Dado que} el operario añade tres bujías de encendido a una tarea técnica y el catálogo registra para dicho artículo un precio base de doce soles,\newline
\textbf{cuando} el sistema asienta la asignación del repuesto a la faena mecánica,\newline
\textbf{entonces} asigna de forma automática el precio unitario en doce soles copiando el valor base de catálogo sin ingreso manual,\newline
\textbf{y} liquida el importe total de la línea en treinta y seis soles, sumándolo automáticamente al costo base del servicio para determinar el precio final de la tarea y actualizar el subtotal de la orden de trabajo.\vspace{4pt}\newline
\textbf{Escenario 2: Conciliación de margen comercial ante consumo multi-lote con costos dispares}\newline
\textbf{Dado que} el consumo de tres unidades de un repuesto agota dos unidades de un lote antiguo con costo de adquisición de cinco soles y toma una unidad de un lote nuevo con costo de siete soles,\newline
\textbf{cuando} el motor de inventario ejecuta la asignación física de existencias bajo la regla FIFO,\newline
\textbf{entonces} mantiene inalterable el precio unitario uniforme de venta de doce soles por cada unidad facturada al cliente,\newline
\textbf{y} calcula en la contabilidad interna de la orden un costo de ventas total de diecisiete soles, registrando una ganancia bruta de diecinueve soles para el taller.\vspace{4pt}\newline
\textbf{Escenario 3: Inmutabilidad del precio asignado ante variaciones posteriores del catálogo}\newline
\textbf{Dado que} una orden de trabajo mantiene repuestos asignados con un precio unitario de doce soles y con posterioridad la administración actualiza el precio base del catálogo a catorce soles,\newline
\textbf{cuando} el personal consulta o liquida la faena previamente acordada,\newline
\textbf{entonces} el sistema conserva inalterado el precio unitario de doce soles registrado al momento de la imputación,\newline
\textbf{y} preserva la integridad económica de la cotización pactada con el cliente impidiendo incrementos no autorizados.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US35.

**Epic 8: Facturación Electrónica y Cierre de Servicio**

A continuación, se presentan las historias de usuario pertenecientes a la épica número 8, que agrupa las funcionalidades de liquidación económica automática en cascada de la orden de trabajo, emisión de comprobantes tributarios UBL 2.1 validados por SUNAT vía PSE, amortización de pagos multi-medio en mostrador y transición de la orden a pagada con pase de salida en Atelier Workshop Mobile.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.5cm} | >{\centering\arraybackslash}p{5.0cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-7.5cm-6\tabcolsep-4\arrayrulewidth\relax} |}
\caption{Épica EP08: Facturación Electrónica y Cierre de Servicio} \label{tbl:ep08} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endfirsthead
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
EP08 & Administrador de taller & Alta \\
\hline
\thfirst{Title} & \multicolumn{2}{p{\dimexpr\textwidth-2.5cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Facturación Electrónica y Cierre de Servicio} \\
\hline
\thspanfirst{3}{Description} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} administrador de taller,\newline \textbf{quiero} liquidar automáticamente los importes de la orden, emitir comprobantes tributarios UBL 2.1 ante SUNAT, amortizar cobros y transicionar la orden a pagada,\newline \textbf{para} garantizar el cumplimiento fiscal, certificar el abono dinerario del servicio y finalizar la custodia legal del vehículo.} \\
\hline
\end{longtable}

*Nota.* Especificación de la épica EP08 elaborada para el proyecto Atelier.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US36 - Liquidación económica automática en cascada de la orden de trabajo} \label{tbl:us36} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US36 & Administrador de taller & Alta & EP08 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Liquidación económica automática en cascada de la orden de trabajo} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} administrador de taller,\newline \textbf{quiero} que el sistema calcule automáticamente los importes consolidados de la orden de trabajo sumando los precios de tareas y repuestos,\newline \textbf{para} disponer del importe exacto a cobrar y alimentar la base del comprobante electrónico sin digitación manual.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Cálculo automático en cascada de tareas, subtotal, impuesto y total de orden}\newline
\textbf{Dado que} la orden de trabajo acumula tareas mecánicas con costos base de servicio y productos consumidos imputados,\newline
\textbf{cuando} el sistema procesa la liquidación económica de la orden,\newline
\textbf{entonces} calcula el precio de cada tarea sumando el costo base del servicio y el importe total de sus productos,\newline
\textbf{y} totaliza el subtotal de la orden sumando los precios de todas sus tareas, liquida el dieciocho por ciento de impuesto y determina el monto total final que alimenta el valor a cobrar en el comprobante electrónico.\vspace{4pt}\newline
\textbf{Escenario 2: Actualización reactiva de importes ante modificaciones operativas}\newline
\textbf{Dado que} una tarea mecánica en ejecución incorpora un nuevo repuesto o registra una variación de alcance autorizada,\newline
\textbf{cuando} se asienta la modificación del material en la faena,\newline
\textbf{entonces} el sistema recalcula de manera inmediata y reactiva el precio de la tarea afectada,\newline
\textbf{y} actualiza en cascada el subtotal, el impuesto y el importe total general de la orden de trabajo conservando la consistencia contable.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US36.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US37 - Emisión de comprobantes tributarios electrónicos UBL 2.1 ante SUNAT vía PSE} \label{tbl:us37} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US37 & Administrador de taller & Alta & EP08 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Emisión de comprobantes tributarios electrónicos UBL 2.1 ante SUNAT vía PSE} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} administrador de taller,\newline \textbf{quiero} emitir Boletas de Venta o Facturas Electrónicas con numeración correlativa estricta y enviarlas a SUNAT mediante el proveedor PSE,\newline \textbf{para} otorgar comprobantes con plena validez fiscal y obtener la Constancia de Recepción oficial.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Emisión exitosa de Factura Electrónica a empresa}\newline
\textbf{Dado que} el cliente corporativo cuenta con un RUC de once dígitos en condición de activo y habido en el padrón tributario,\newline
\textbf{cuando} el administrador confirma la emisión de la Factura Electrónica vinculada a la orden de trabajo,\newline
\textbf{entonces} el sistema incrementa el correlativo de la serie autorizada de la sede física, estructura el documento bajo el estándar UBL 2.1 y lo transmite al proveedor de servicios electrónicos,\newline
\textbf{y} almacena la Constancia de Recepción aprobada por SUNAT, el resumen hash de la firma digital y los enlaces a los archivos PDF y XML.\vspace{4pt}\newline
\textbf{Escenario 2: Emisión exitosa de Boleta de Venta a persona natural}\newline
\textbf{Dado que} el cliente es una persona natural registrada con Documento Nacional de Identidad de ocho dígitos,\newline
\textbf{cuando} el administrador confirma la emisión de la Boleta de Venta Electrónica,\newline
\textbf{entonces} el sistema asigna el correlativo secuencial de la serie de boletas, envía el comprobante al servicio de facturación fiscal,\newline
\textbf{y} vincula el documento con su representación impresa conteniendo el código QR de verificación tributaria.\vspace{4pt}\newline
\textbf{Escenario 3: Manejo de contingencia ante intermitencia del servicio fiscal}\newline
\textbf{Dado que} el servicio externo del proveedor de servicios electrónicos o SUNAT experimenta una interrupción temporal de comunicaciones,\newline
\textbf{cuando} se envía la instrucción de emisión del comprobante,\newline
\textbf{entonces} el sistema guarda el comprobante en estado emitido con su correlativo formal reservado sin duplicar numeraciones,\newline
\textbf{y} programa el reintento automático asíncrono para obtener la confirmación tributaria una vez normalizada la red.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US37.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US38 - Recaudación y amortización de pagos multi-medio en mostrador y patio} \label{tbl:us38} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US38 & Administrador de taller & Alta & EP08 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Recaudación y amortización de pagos multi-medio en mostrador y patio} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} administrador de taller,\newline \textbf{quiero} registrar abonos dinerarios totales o parciales indicando el medio de pago y código de operación bancario,\newline \textbf{para} amortizar el saldo adeudado del comprobante fiscal y conciliar la recaudación de la jornada.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Pago íntegro con tarjeta o billetera digital}\newline
\textbf{Dado que} el cliente abona el total facturado mediante tarjeta de débito o billetera digital interoperable,\newline
\textbf{cuando} el administrador asienta el cobro registrando el medio financiero y la referencia de transacción de la operación,\newline
\textbf{entonces} el sistema crea el registro de pago vinculado al comprobante fiscal,\newline
\textbf{y} actualiza el estado de cobro a completado al extinguir en su totalidad la deuda monetaria.\vspace{4pt}\newline
\textbf{Escenario 2: Amortización fraccionada con combinación de medios de pago}\newline
\textbf{Dado que} el cliente abona una parte del importe en efectivo en patio y el monto restante mediante transferencia bancaria,\newline
\textbf{cuando} el administrador registra sucesivamente cada pago parcial en la plataforma móvil,\newline
\textbf{entonces} el sistema descuenta de forma acumulativa cada abono del saldo exigible del comprobante,\newline
\textbf{y} mantiene la liquidación en estado pendiente hasta que el importe recaudado iguale el valor total facturado.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US38.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US39 - Transición a orden pagada, emisión de pase de salida vehicular y entrega en patio} \label{tbl:us39} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US39 & Asesor de servicio & Alta & EP08 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Transición a orden pagada, emisión de pase de salida vehicular y entrega en patio} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} asesor de servicio,\newline \textbf{quiero} verificar la culminación de tareas, validar la amortización total del pago y registrar la conformidad de entrega del cliente,\newline \textbf{para} transicionar la orden a pagada, emitir el pase de salida vehicular y extinguir la custodia legal del taller.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Transición automática de orden a completada al culminar todas sus tareas}\newline
\textbf{Dado que} el operario en bahía registra el cierre técnico de la última tarea mecánica pendiente de la orden de trabajo,\newline
\textbf{cuando} el sistema constata que el cien por ciento de las faenas se encuentran en estado completada,\newline
\textbf{entonces} transiciona automáticamente el estado de la orden de trabajo a completada,\newline
\textbf{y} notifica al asesor de servicio que el vehículo se encuentra listo para retiro e inspección de calidad previa a la liquidación.\vspace{4pt}\newline
\textbf{Escenario 2: Transición a orden pagada y emisión de pase de salida tras liquidación total}\newline
\textbf{Dado que} la orden de trabajo se encuentra completada y los abonos de pago cubren la totalidad del importe facturado en el comprobante fiscal,\newline
\textbf{cuando} el asesor de servicio confirma la entrega en patio y captura la firma de conformidad del cliente en el dispositivo móvil,\newline
\textbf{entonces} el sistema transiciona el estado de la orden de trabajo a pagada,\newline
\textbf{y} genera el pase de salida vehicular digital habilitando el retiro físico de la unidad y liberando la bahía asignada.\vspace{4pt}\newline
\textbf{Escenario 3: Restricción de salida vehicular ante orden no cancelada}\newline
\textbf{Dado que} una orden de trabajo permanece en estado completada pero mantiene saldo económico pendiente de pago en el comprobante fiscal,\newline
\textbf{cuando} el usuario intenta expedir el pase de salida vehicular,\newline
\textbf{entonces} el sistema bloquea la emisión de la autorización de salida,\newline
\textbf{y} notifica que la orden de trabajo debe transicionar al estado pagada mediante la cancelación previa de la deuda.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US39.

**Epic 9: Monitoreo Operativo de Patio y Gestión Gerencial**

A continuación, se presentan la especificación de la épica número 9 y sus correspondientes historias de usuario, orientadas a la supervisión visual del flujo vehicular en patio, la reasignación de bahías de servicio, la parametrización fiscal ante SUNAT y la exportación documental de balances contables y diagnósticos periciales asistidos por IA en formato PDF para el personal directivo del taller automotriz.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.5cm} | >{\centering\arraybackslash}p{5.0cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-7.5cm-6\tabcolsep-4\arrayrulewidth\relax} |}
\caption{Épica EP09: Monitoreo Operativo de Patio y Gestión Gerencial} \label{tbl:ep09} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endfirsthead
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
EP09 & Personal directivo de taller & Media \\
\hline
\thfirst{Title} & \multicolumn{2}{p{\dimexpr\textwidth-2.5cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Monitoreo Operativo de Patio y Gestión Gerencial} \\
\hline
\thspanfirst{3}{Description} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} personal directivo de taller (dueño y administrador),\newline \textbf{quiero} supervisar el estado de las bahías en tiempo real, configurar parámetros fiscales SUNAT y exportar reportes de flujo de caja e informes periciales en formato PDF,\newline \textbf{para} optimizar el flujo físico de unidades en patio y gobernar la gestión financiera y comercial del negocio automotriz.} \\
\hline
\end{longtable}

*Nota.* Especificación de la épica EP09 elaborada para el proyecto Atelier.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US40 - Supervisión y reasignación de bahías de servicio en tiempo real} \label{tbl:us40} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US40 & Administrador de taller & Media & EP09 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Supervisión y reasignación de bahías de servicio en tiempo real} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} administrador de taller,\newline \textbf{quiero} visualizar la ocupación de las bahías mecánicas y transferir una orden de trabajo hacia un puesto desocupado,\newline \textbf{para} asegurar la continuidad de las tareas ante imprevistos, averías en elevadores o redistribución de labores en patio.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Reasignación exitosa de bahía por contingencia mecánica}\newline
\textbf{Dado que} una orden de trabajo se encuentra en ejecución en la bahía de servicio número uno y surge una eventualidad que exige reubicar el vehículo,\newline
\textbf{cuando} el administrador selecciona una bahía de destino desocupada de tipo compatible y confirma el traslado en el sistema,\newline
\textbf{entonces} el sistema actualiza la asignación de la orden de trabajo hacia la nueva bahía, libera el puesto de origen dejándolo disponible,\newline
\textbf{y} notifica en tiempo real al técnico mecánico responsable para continuar las tareas en la nueva ubicación.\vspace{4pt}\newline
\textbf{Escenario 2: Restricción de reasignación hacia bahía ocupada o inhabilitada}\newline
\textbf{Dado que} el administrador intenta trasladar un vehículo hacia un puesto físico que se encuentra ocupado por otra unidad o bajo mantenimiento preventivo,\newline
\textbf{cuando} solicita la reasignación en el tablero de patio,\newline
\textbf{entonces} el sistema bloquea la operación indicando la indisponibilidad de la bahía seleccionada,\newline
\textbf{y} mantiene la asignación previa del vehículo y sus faenas sin alterar los registros de ejecución.\vspace{4pt}\newline
\textbf{Escenario 3: Despliegue en tiempo real del tablero de ocupación de bahías}\newline
\textbf{Dado que} el personal de supervisión ingresa al módulo de monitoreo de patio de la sucursal activa,\newline
\textbf{cuando} el sistema consulta el estado de la infraestructura del taller,\newline
\textbf{entonces} despliega la lista consolidada de bahías con su indicador de disponibilidad (disponible, ocupada o en mantenimiento),\newline
\textbf{y} muestra en las bahías ocupadas la placa del vehículo en atención, el mecánico a cargo y el tiempo transcurrido de labor.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US40.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US41 - Exportación de reporte de flujo de caja en PDF para auditoría contable} \label{tbl:us41} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US41 & Dueño de taller & Alta & EP09 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Exportación de reporte de flujo de caja en PDF para auditoría contable} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} dueño de taller,\newline \textbf{quiero} generar y descargar el reporte consolidado de flujo de caja e ingresos fiscales en formato PDF,\newline \textbf{para} entregarlo al contador externo de la empresa y facilitar la liquidación tributaria sin requerir que acceda a la plataforma Atelier.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Descarga exitosa de flujo de caja mensual en documento PDF}\newline
\textbf{Dado que} el dueño de taller accede al módulo financiero seleccionando el mes fiscal y la sucursal de atención,\newline
\textbf{cuando} solicita la exportación del estado de flujo de caja en formato PDF,\newline
\textbf{entonces} el sistema consolida los cobros registrados y comprobantes electrónicos emitidos en el intervalo, compila el archivo PDF con membrete institucional, desglose de ingresos por mano de obra y repuestos y total de IGV retenido,\newline
\textbf{y} descarga el documento listo para su remisión al estudio contable externo.\vspace{4pt}\newline
\textbf{Escenario 2: Reporte multisede consolidado para balance anual}\newline
\textbf{Dado que} la empresa automotriz opera múltiples sucursales físicas y se requiere consolidar el ejercicio contable,\newline
\textbf{cuando} el dueño selecciona la opción de balance corporativo para un rango de fechas personalizado,\newline
\textbf{entonces} el sistema agrega los flujos de caja de todas las sedes discriminando la recaudación por taller,\newline
\textbf{y} emite el documento PDF consolidado con los totales generales de facturación y tributos.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US41.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US42 - Configuración de información fiscal, series SUNAT y enlace con PSE} \label{tbl:us42} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US42 & Dueño de taller & Alta & EP09 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Configuración de información fiscal, series SUNAT y enlace con PSE} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} dueño de taller,\newline \textbf{quiero} registrar la razón social, RUC, series correlativas autorizadas y el token de conexión con el PSE Nubefact,\newline \textbf{para} asegurar la validez legal y tributaria de los comprobantes electrónicos emitidos ante la SUNAT.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Vinculación exitosa de credenciales tributarias y activación de series}\newline
\textbf{Dado que} el dueño de taller ingresa el RUC, razón social y el token de autenticación provisto por el PSE Nubefact,\newline
\textbf{cuando} el sistema valida la conectividad con el servidor fiscal y constata la condición activa del contribuyente,\newline
\textbf{entonces} activa las series alfanuméricas autorizadas vinculándolas a la sucursal de trabajo,\newline
\textbf{y} habilita la expedición regular de comprobantes electrónicos en las órdenes de servicio.\vspace{4pt}\newline
\textbf{Escenario 2: Detección preventiva de credenciales fiscales erróneas}\newline
\textbf{Dado que} se ingresa un token de autenticación PSE revocado o un RUC que no corresponde a la empresa,\newline
\textbf{cuando} el servicio ejecuta la prueba de comunicación tributaria,\newline
\textbf{entonces} bloquea la activación de la serie informando el fallo de autenticación con el proveedor fiscal,\newline
\textbf{y} previene la emisión de comprobantes no homologados ante SUNAT.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US42.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US43 - Descarga y remisión de informe pericial de salud vehicular en PDF} \label{tbl:us43} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
US43 & Dueño de taller & Media & EP09 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Descarga y remisión de informe pericial de salud vehicular en PDF} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} dueño de taller,\newline \textbf{quiero} descargar en formato PDF el informe pericial de salud vehicular generado por el modelo de IA a partir de telemetría y códigos DTC,\newline \textbf{para} remitirlo al cliente o gestor de flota corporativa y justificar técnicamente el presupuesto de mantenimiento preventivo.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Generación y descarga de informe pericial en PDF maquetado}\newline
\textbf{Dado que} se completó la inferencia del modelo generativo con los datos de telemetría y códigos de avería del vehículo,\newline
\textbf{cuando} el dueño de taller solicita la descarga documental del informe de salud automotriz,\newline
\textbf{entonces} el sistema compila un documento PDF institucional con membrete, semáforos de criticidad por subsistema, averías explicadas en lenguaje accesible y recomendaciones preventivas,\newline
\textbf{y} genera el archivo descargable para su envío directo al cliente por medios digitales.\vspace{4pt}\newline
\textbf{Escenario 2: Consolidado ejecutivo para flota corporativa}\newline
\textbf{Dado que} una empresa de transporte mantiene múltiples unidades atendidas en el taller,\newline
\textbf{cuando} el dueño solicita el diagnóstico consolidado de la flota vehicular,\newline
\textbf{entonces} el sistema emite un informe agrupado en PDF destacando los vehículos en estado crítico y el presupuesto preventivo asociado,\newline
\textbf{y} habilita la remisión formal al responsable de mantenimiento de la flota comercial.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US43.

**Epic 10: Servicios e Interfaces RESTful del Backend**

A continuación, se presentan la especificación de la épica número 10 y su conjunto de historias técnicas, formuladas bajo la perspectiva de desarrollador de backend. Esta sección define los contratos de servicio, endpoints RESTful, validaciones semánticas, políticas de seguridad perimetral y respuestas normalizadas que sustentan la lógica de negocio y la integración de las interfaces cliente de Atelier.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.5cm} | >{\centering\arraybackslash}p{5.0cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-7.5cm-6\tabcolsep-4\arrayrulewidth\relax} |}
\caption{Épica EP10: Servicios e Interfaces RESTful del Backend} \label{tbl:ep10} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endfirsthead
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
EP10 & Developer & Alta \\
\hline
\thfirst{Title} & \multicolumn{2}{p{\dimexpr\textwidth-2.5cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Servicios e Interfaces RESTful del Backend} \\
\hline
\thspanfirst{3}{Description} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} Developer,\newline \textbf{quiero} implementar endpoints RESTful seguros, estandarizados bajo el protocolo HTTP y con contratos JSON normalizados en la capa de interfaces del backend,\newline \textbf{para} proveer servicios transaccionales de alta disponibilidad, aislamiento multi-inquilino y respuesta predecible a las aplicaciones web y móviles de la plataforma Atelier.} \\
\hline
\end{longtable}

*Nota.* Especificación de la épica EP10 elaborada para el proyecto Atelier.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia Técnica TS01 - Autenticación de credenciales y expedición de tokens JWT} \label{tbl:ts01} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
TS01 & Developer & Alta & EP10 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Autenticación de credenciales y expedición de tokens JWT (\texttt{POST /api/v1/auth/sign-in})} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} Developer,\newline \textbf{quiero} exponer el endpoint RESTful \texttt{POST /api/v1/auth/sign-in} con verificación criptográfica de credenciales,\newline \textbf{para} autenticar al usuario y expedir tokens JWT de acceso y renovación con contexto de inquilino validado.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Autenticación exitosa y emisión de par de tokens}\newline
\textbf{Dado que} la API recibe una solicitud HTTP POST con cuerpo JSON válido conteniendo correo electrónico y contraseña registrados,\newline
\textbf{cuando} el servicio de autenticación valida las credenciales y corrobora que la cuenta y la membresía laboral se encuentran activas,\newline
\textbf{entonces} responde con código HTTP 200 OK retornando el identificador del usuario, la razón social del taller y los tokens JWT de acceso y renovación,\newline
\textbf{y} asienta el evento de acceso exitoso en la bitácora de auditoría.\vspace{4pt}\newline
\textbf{Escenario 2: Rechazo por credenciales erróneas o cuenta inexistente}\newline
\textbf{Dado que} la API recibe una solicitud HTTP POST con una clave incorrecta o un correo no registrado,\newline
\textbf{cuando} el subsistema de seguridad verifica la correspondencia criptográfica del hash de la contraseña,\newline
\textbf{entonces} responde con código HTTP 401 Unauthorized y un cuerpo estructurado con el mensaje de credenciales no válidas,\newline
\textbf{y} bloquea la generación de cualquier token de sesión.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia técnica TS01.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia Técnica TS02 - Registro fundacional de organización y aprovisionamiento de inquilino} \label{tbl:ts02} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
TS02 & Developer & Alta & EP10 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Registro fundacional de organización y aprovisionamiento de inquilino (\texttt{POST /api/v1/auth/sign-up})} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} Developer,\newline \textbf{quiero} exponer el endpoint RESTful \texttt{POST /api/v1/auth/sign-up} para crear atómicamente el taller y el usuario administrador,\newline \textbf{para} aprovisionar el inquilino en la base de datos con aislamiento multi-inquilino y despachar el código OTP de verificación.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Aprovisionamiento exitoso de nuevo taller automotriz}\newline
\textbf{Dado que} se recibe una petición HTTP POST con el RUC de la empresa, denominación comercial y los datos de identidad y contraseña del titular del taller,\newline
\textbf{cuando} el servicio comprueba que ni el RUC ni el correo electrónico existen previamente en la plataforma,\newline
\textbf{entonces} persiste atómicamente el registro del inquilino, crea la cuenta del administrador con membresía activa,\newline
\textbf{y} responde con código HTTP 201 Created despachando un código OTP de seis dígitos al correo electrónico registrado.\vspace{4pt}\newline
\textbf{Escenario 2: Rechazo por duplicidad de documento tributario}\newline
\textbf{Dado que} se recibe una solicitud con un RUC que ya se encuentra registrado por otra empresa automotriz,\newline
\textbf{cuando} el validador de dominio detecta la colisión de unicidad tributaria,\newline
\textbf{entonces} responde con código HTTP 409 Conflict y el detalle del recurso en conflicto,\newline
\textbf{y} revierte cualquier operación de persistencia asociada.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia técnica TS02.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia Técnica TS03 - Verificación de correo y activación mediante código OTP} \label{tbl:ts03} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
TS03 & Developer & Alta & EP10 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Verificación de correo y activación mediante código OTP (\texttt{POST /api/v1/auth/verify-email})} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} Developer,\newline \textbf{quiero} exponer el endpoint RESTful \texttt{POST /api/v1/auth/verify-email} para validar el código numérico recibido por correo,\newline \textbf{para} transicionar la cuenta del usuario a estado verificado y autorizar su acceso formal a los servicios del sistema.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Verificación satisfactoria de código OTP vigente}\newline
\textbf{Dado que} se recibe una petición HTTP POST con el correo electrónico del usuario y el código OTP de seis dígitos antes de su vencimiento,\newline
\textbf{cuando} el servicio valida la firma temporal y la coincidencia exacta con el código emitido,\newline
\textbf{entonces} conmuta la cuenta a estado verificado, anula el código OTP para evitar reutilizaciones,\newline
\textbf{y} responde con código HTTP 200 OK habilitando el acceso a la plataforma.\vspace{4pt}\newline
\textbf{Escenario 2: Rechazo de código OTP caducado o discrepante}\newline
\textbf{Dado que} se recibe un código OTP numérico que no coincide con el registrado o que superó su ventana de vigencia de quince minutos,\newline
\textbf{cuando} el servicio efectúa la comprobación criptográfica,\newline
\textbf{entonces} responde con código HTTP 400 Bad Request detallando la anomalía,\newline
\textbf{y} mantiene la cuenta en estado pendiente de verificación.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia técnica TS03.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia Técnica TS04 - Emisión y despacho de invitaciones corporativas de personal} \label{tbl:ts04} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
TS04 & Developer & Media & EP10 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Emisión y despacho de invitaciones corporativas de personal (\texttt{POST /api/v1/tenants/\{tenantId\}/invitations})} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} Developer,\newline \textbf{quiero} exponer el endpoint RESTful \texttt{POST /api/v1/tenants/\{tenantId\}/invitations} protegido por perfil de administrador,\newline \textbf{para} generar tokens de invitación firmados y enviar correos transaccionales a nuevos colaboradores del taller.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Emisión exitosa de invitación laboral}\newline
\textbf{Dado que} un usuario autenticado con rol administrativo envía una petición HTTP POST con el correo electrónico del colaborador, rol asignado y sucursal de destino,\newline
\textbf{cuando} el servicio valida que el destinatario no posee una membresía activa en el taller ni una invitación previa vigente,\newline
\textbf{entonces} genera un token criptográfico con vigencia de cuarenta y ocho horas, despacha el correo mediante la API de Resend,\newline
\textbf{y} responde con código HTTP 201 Created retornando los metadatos de la invitación.\vspace{4pt}\newline
\textbf{Escenario 2: Denegación de emisión por invitación pendiente duplicada}\newline
\textbf{Dado que} se intenta emitir una invitación hacia un correo electrónico que ya cuenta con una invitación pendiente en la misma organización,\newline
\textbf{cuando} el validador de dominio constata la existencia de la invitación activa,\newline
\textbf{entonces} responde con código HTTP 409 Conflict informando la duplicidad,\newline
\textbf{y} bloquea la generación de un nuevo token.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia técnica TS04.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia Técnica TS05 - Alta de sucursales operativas y delimitación de geocercas satelitales} \label{tbl:ts05} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
TS05 & Developer & Media & EP10 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Alta de sucursales operativas y delimitación de geocercas (\texttt{POST /api/v1/tenants/\{tenantId\}/branches})} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} Developer,\newline \textbf{quiero} exponer el endpoint RESTful \texttt{POST /api/v1/tenants/\{tenantId\}/branches},\newline \textbf{para} registrar sedes físicas con código tributario SUNAT, coordenadas geográficas WGS84 y radio perimétrico en metros.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Registro exitoso de sucursal física con geocerca válida}\newline
\textbf{Dado que} se recibe una petición HTTP POST con nombre de sucursal, código tributario de anexo SUNAT, latitud, longitud y radio en metros no inferior a cincuenta,\newline
\textbf{cuando} el servicio de infraestructura valida los límites de suscripción del taller y la consistencia geodésica de las coordenadas,\newline
\textbf{entonces} persiste la sucursal vinculada a la organización,\newline
\textbf{y} responde con código HTTP 201 Created retornando el identificador y los datos del local registrado.\vspace{4pt}\newline
\textbf{Escenario 2: Rechazo por coordenadas geográficas fuera de rango}\newline
\textbf{Dado que} la solicitud contiene valores de latitud o longitud fuera de los rangos válidos o un radio perimétrico negativo,\newline
\textbf{cuando} el componente de validación inspecciona el cuerpo de la petición,\newline
\textbf{entonces} responde con código HTTP 422 Unprocessable Entity detallando los errores de esquema,\newline
\textbf{y} descarta la persistencia de la sucursal.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia técnica TS05.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia Técnica TS06 - Alta de clientes individuales con validación de identidad} \label{tbl:ts06} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
TS06 & Developer & Alta & EP10 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Alta de clientes individuales con validación de identidad (\texttt{POST /api/v1/customers/individuals})} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} Developer,\newline \textbf{quiero} exponer el endpoint RESTful \texttt{POST /api/v1/customers/individuals},\newline \textbf{para} incorporar personas naturales a la cartera de clientes con validación formal de DNI y canales de contacto directo.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Alta exitosa de cliente persona natural}\newline
\textbf{Dado que} se recibe una petición HTTP POST autenticada con cabecera de inquilino que incluye tipo de documento, número de DNI de ocho dígitos, nombres, apellidos y teléfono,\newline
\textbf{cuando} el servicio comprueba que el cliente no se encuentra registrado en el taller bajo el mismo documento,\newline
\textbf{entonces} persiste el registro del cliente en la base de datos,\newline
\textbf{y} responde con código HTTP 201 Created retornando el recurso creado.\vspace{4pt}\newline
\textbf{Escenario 2: Conflicto por documento de identidad duplicado en la organización}\newline
\textbf{Dado que} se envía una petición con un número de documento que ya pertenece a un cliente registrado en el mismo taller,\newline
\textbf{cuando} el repositorio ejecuta la comprobación de unicidad scoped al inquilino,\newline
\textbf{entonces} responde con código HTTP 409 Conflict retornando el identificador del cliente preexistente,\newline
\textbf{y} no genera registros redundantes.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia técnica TS06.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia Técnica TS07 - Registro técnico de vehículos con homologación de placa y VIN} \label{tbl:ts07} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
TS07 & Developer & Alta & EP10 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Registro técnico de vehículos con homologación de placa y VIN (\texttt{POST /api/v1/vehicles})} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} Developer,\newline \textbf{quiero} exponer el endpoint RESTful \texttt{POST /api/v1/vehicles},\newline \textbf{para} dar de alta unidades en el parque automotor validando la placa de rodaje y el número de chasis según norma ISO 3779.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Registro exitoso de automóvil con validación técnica}\newline
\textbf{Dado que} se recibe una petición HTTP POST con placa de rodaje válida, número VIN de diecisiete caracteres alfanuméricos, marca, modelo, año y kilometraje actual,\newline
\textbf{cuando} el servicio de gestión de flotas valida la estructura del VIN y la normalización de la placa en mayúsculas,\newline
\textbf{entonces} almacena el vehículo asociándolo opcionalmente al cliente custodio inicial,\newline
\textbf{y} responde con código HTTP 201 Created con el recurso del vehículo registrado.\vspace{4pt}\newline
\textbf{Escenario 2: Rechazo por formato de VIN o placa inválidos}\newline
\textbf{Dado que} la solicitud contiene un VIN con longitud diferente a diecisiete caracteres o caracteres no permitidos,\newline
\textbf{cuando} el validador sintáctico procesa los campos de entrada,\newline
\textbf{entonces} responde con código HTTP 400 Bad Request describiendo la infracción de formato,\newline
\textbf{y} desestima el registro.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia técnica TS07.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia Técnica TS08 - Agendamiento y reserva de citas de mantenimiento} \label{tbl:ts08} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
TS08 & Developer & Media & EP10 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Agendamiento y reserva de citas de mantenimiento (\texttt{POST /api/v1/appointments})} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} Developer,\newline \textbf{quiero} exponer el endpoint RESTful \texttt{POST /api/v1/appointments},\newline \textbf{para} programar atenciones preventivas y correctivas verificando la disponibilidad horaria en la sucursal de destino.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Agendamiento exitoso de cita técnica}\newline
\textbf{Dado que} se recibe una petición HTTP POST con identificadores de cliente y vehículo, fecha y hora futura de atención, sucursal y motivo de servicio,\newline
\textbf{cuando} el servicio corrobora la disponibilidad horaria dentro de la jornada laboral de la sede física,\newline
\textbf{entonces} genera la cita en estado programada,\newline
\textbf{y} responde con código HTTP 201 Created despachando la confirmación preliminar.\vspace{4pt}\newline
\textbf{Escenario 2: Rechazo por sobreposición o indisponibilidad horaria}\newline
\textbf{Dado que} la solicitud especifica una franja horaria que ya ha alcanzado el límite máximo de atenciones simultáneas en la sucursal,\newline
\textbf{cuando} el motor de agendamiento evalúa la capacidad de patio,\newline
\textbf{entonces} responde con código HTTP 409 Conflict informando la falta de cupo,\newline
\textbf{y} sugiere la siguiente franja horaria disponible.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia técnica TS08.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia Técnica TS09 - Registro de arribo a patio y apertura automática de orden} \label{tbl:ts09} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
TS09 & Developer & Alta & EP10 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Registro de arribo a patio y apertura automática de orden (\texttt{POST /api/v1/appointments/\{id\}/check-in})} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} Developer,\newline \textbf{quiero} exponer el endpoint RESTful \texttt{POST /api/v1/appointments/\{id\}/check-in},\newline \textbf{para} registrar el ingreso físico del automóvil al patio y disparar la creación automática de la orden de trabajo.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Arribo exitoso y apertura de orden de trabajo}\newline
\textbf{Dado que} el asesor de servicio envía una petición HTTP POST con el kilometraje y nivel de combustible de recepción del vehículo,\newline
\textbf{cuando} el servicio de citas verifica que la cita se encuentra en estado programada o confirmada,\newline
\textbf{entonces} transiciona la cita a estado en recepción, despacha un evento de dominio y abre una nueva orden de trabajo en estado borrador vinculando al vehículo y asesor,\newline
\textbf{y} responde con código HTTP 200 OK retornando los identificadores de la cita y de la orden generada.\vspace{4pt}\newline
\textbf{Escenario 2: Rechazo por cita cancelada o previamente atendida}\newline
\textbf{Dado que} se intenta procesar el arribo sobre una cita que ya fue atendida con anterioridad o que se encuentra en estado cancelada,\newline
\textbf{cuando} el servicio comprueba la máquina de estados de la cita,\newline
\textbf{entonces} responde con código HTTP 422 Unprocessable Entity indicando la inviabilidad de la transición,\newline
\textbf{y} no altera los registros de operaciones.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia técnica TS09.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia Técnica TS10 - Apertura y parametrización de órdenes de trabajo en taller} \label{tbl:ts10} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
TS10 & Developer & Alta & EP10 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Apertura y parametrización de órdenes de trabajo en taller (\texttt{POST /api/v1/work-orders})} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} Developer,\newline \textbf{quiero} exponer el endpoint RESTful \texttt{POST /api/v1/work-orders},\newline \textbf{para} abrir órdenes de servicio registrando vehículo, sucursal, asesor responsable, kilometraje y notas de recepción.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Creación formal de orden de trabajo}\newline
\textbf{Dado que} se recibe una petición HTTP POST con los identificadores de vehículo, cliente, sucursal, kilometraje de entrada e inventario visual de recepción,\newline
\textbf{cuando} el servicio de operaciones MRO valida la existencia de los recursos y la integridad de los datos de ingreso,\newline
\textbf{entonces} persiste la orden de trabajo en estado borrador asignando un correlativo operativo secuencial único,\newline
\textbf{y} responde con código HTTP 201 Created con el detalle de la orden.\vspace{4pt}\newline
\textbf{Escenario 2: Rechazo por orden de trabajo activa preexistente}\newline
\textbf{Dado que} se intenta abrir una orden de trabajo para un vehículo que ya mantiene otra orden en estado abierta o en progreso dentro del taller,\newline
\textbf{cuando} el repositorio constata la existencia de un servicio activo no finiquitado para dicha placa,\newline
\textbf{entonces} responde con código HTTP 409 Conflict señalando la orden en curso,\newline
\textbf{y} bloquea la apertura duplicada.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia técnica TS10.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia Técnica TS11 - Asignación y conmutación de bahías de servicio en orden} \label{tbl:ts11} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
TS11 & Developer & Media & EP10 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Asignación y conmutación de bahías de servicio en orden (\texttt{PUT /api/v1/work-orders/\{id\}/bay})} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} Developer,\newline \textbf{quiero} exponer el endpoint RESTful \texttt{PUT /api/v1/work-orders/\{id\}/bay},\newline \textbf{para} vincular una bahía de servicio a la orden de trabajo y actualizar concurrentemente los estados de ocupación de patio.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Asignación exitosa de bahía desocupada}\newline
\textbf{Dado que} se envía una petición HTTP PUT con el identificador de una bahía disponible compatible con el tipo de intervención requerida,\newline
\textbf{cuando} el servicio de operaciones comprueba que la bahía se encuentra desocupada en la sucursal,\newline
\textbf{entonces} actualiza la orden de trabajo vinculando el puesto físico y conmuta el estado de la bahía a ocupada,\newline
\textbf{y} responde con código HTTP 200 OK con el recurso actualizado.\vspace{4pt}\newline
\textbf{Escenario 2: Conflicto por intento de asignación a bahía ocupada}\newline
\textbf{Dado que} se envía la petición apuntando a una bahía que ya aloja a otro vehículo en ejecución,\newline
\textbf{cuando} el gestor de concurrencia detecta el estado ocupado del puesto,\newline
\textbf{entonces} responde con código HTTP 409 Conflict informando la indisponibilidad de la bahía,\newline
\textbf{y} mantiene inalterada la asignación previa de la orden.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia técnica TS11.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia Técnica TS12 - Incorporación de tareas técnicas a la orden de trabajo} \label{tbl:ts12} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
TS12 & Developer & Alta & EP10 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Incorporación de tareas técnicas a la orden de trabajo (\texttt{POST /api/v1/work-orders/\{id\}/tasks})} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} Developer,\newline \textbf{quiero} exponer el endpoint RESTful \texttt{POST /api/v1/work-orders/\{id\}/tasks},\newline \textbf{para} anexar labores mecánicas a la orden copiando el precio base del servicio y recalculando el subtotal acumulado.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Inclusión exitosa de tarea técnica con servicio de catálogo}\newline
\textbf{Dado que} se recibe una petición HTTP POST con el identificador de un servicio del catálogo, mecánico asignado y notas técnicas complementarias,\newline
\textbf{cuando} el servicio verifica que la orden está en estado borrador o en progreso, copia el precio base del servicio a la tarea y crea el registro en estado pendiente,\newline
\textbf{entonces} recalcula el subtotal acumulado de la orden sumando el precio de la nueva faena,\newline
\textbf{y} responde con código HTTP 201 Created con el recurso de la tarea creada.\vspace{4pt}\newline
\textbf{Escenario 2: Rechazo por adición de tarea en orden completada}\newline
\textbf{Dado que} se intenta agregar una tarea a una orden que se encuentra en estado completada, pagada o cancelada,\newline
\textbf{cuando} el servicio valida las invariantes de inmutabilidad del ciclo de vida,\newline
\textbf{entonces} responde con código HTTP 422 Unprocessable Entity denegando la mutación,\newline
\textbf{y} no modifica la composición de la orden.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia técnica TS12.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia Técnica TS13 - Control cronometrado y finalización técnica de faenas} \label{tbl:ts13} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
TS13 & Developer & Alta & EP10 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Control cronometrado y finalización técnica de faenas (\texttt{POST /api/v1/tasks/\{id\}/complete})} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} Developer,\newline \textbf{quiero} exponer el endpoint RESTful \texttt{POST /api/v1/tasks/\{id\}/complete},\newline \textbf{para} culminar técnicamente una tarea mecánica, registrar la duración efectiva y evaluar la transición automática de la orden a completada.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Cierre técnico de tarea y verificación de orden completada}\newline
\textbf{Dado que} el mecánico asignado envía una petición HTTP POST para marcar la tarea como culminada,\newline
\textbf{cuando} el servicio valida que la labor se encontraba en progreso, sella la estampa cronológica de fin y calcula la duración real,\newline
\textbf{entonces} conmuta la tarea a completada, constata si todas las demás tareas de la orden están culminadas para transicionar la orden a completada automáticamente,\newline
\textbf{y} responde con código HTTP 200 OK con el recurso actualizado.\vspace{4pt}\newline
\textbf{Escenario 2: Rechazo de finalización sobre tarea no iniciada}\newline
\textbf{Dado que} se intenta completar una labor mecánica que permanece en estado pendiente sin haber iniciado previamente su ejecución,\newline
\textbf{cuando} el motor de estados de tareas valida la precondición operativa,\newline
\textbf{entonces} responde con código HTTP 422 Unprocessable Entity indicando que la labor debe iniciarse antes de su cierre,\newline
\textbf{y} descarta la transacción.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia técnica TS13.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia Técnica TS14 - Requisición y descargo de repuestos bajo método FIFO} \label{tbl:ts14} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
TS14 & Developer & Alta & EP10 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Requisición y descargo de repuestos bajo método FIFO (\texttt{POST /api/v1/tasks/\{id\}/products})} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} Developer,\newline \textbf{quiero} exponer el endpoint RESTful \texttt{POST /api/v1/tasks/\{id\}/products},\newline \textbf{para} vincular repuestos a una faena, asignando el precio base del catálogo al cliente y descargando existencias de lotes bajo orden FIFO estricto.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Descargo exitoso de repuesto con stock suficiente}\newline
\textbf{Dado que} se recibe una petición HTTP POST con el identificador del ítem de inventario y la cantidad requerida para la faena,\newline
\textbf{cuando} el servicio de almacén verifica stock global suficiente, copia el precio base del repuesto como precio unitario a cobrar y deduce físicamente las unidades de los lotes de compra según su antigüedad de ingreso FIFO,\newline
\textbf{entonces} vincula el repuesto a la tarea, recalcula el importe de la faena y el subtotal de la orden de trabajo,\newline
\textbf{y} responde con código HTTP 201 Created retornando el detalle de la asignación.\vspace{4pt}\newline
\textbf{Escenario 2: Rechazo por insuficiencia de existencias en almacén}\newline
\textbf{Dado que} la cantidad solicitada supera el inventario disponible consolidado en los lotes activos de la sucursal,\newline
\textbf{cuando} el asignador de stock evalúa la disponibilidad,\newline
\textbf{entonces} responde con código HTTP 409 Conflict indicando el stock disponible insuficiente,\newline
\textbf{y} no afecta las existencias de inventario ni modifica la tarea.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia técnica TS14.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia Técnica TS15 - Catálogo de repuestos e insumos con precio base y umbral crítico} \label{tbl:ts15} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
TS15 & Developer & Media & EP10 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Catálogo de repuestos con precio base y umbral crítico (\texttt{POST /api/v1/inventory/items})} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} Developer,\newline \textbf{quiero} exponer el endpoint RESTful \texttt{POST /api/v1/inventory/items},\newline \textbf{para} dar de alta repuestos e insumos registrando código SKU, descripción, precio base al público y umbral mínimo de seguridad.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Alta exitosa de artículo en catálogo}\newline
\textbf{Dado que} se recibe una petición HTTP POST con código SKU, descripción, marca, categoría, precio base de venta mayor a cero y nivel de stock mínimo de seguridad,\newline
\textbf{cuando} el servicio comprueba que el SKU no existe previamente en la organización del taller,\newline
\textbf{entonces} persiste el artículo de inventario con stock contable en cero a la espera de recepciones por compra,\newline
\textbf{y} responde con código HTTP 201 Created retornando los datos del recurso creado.\vspace{4pt}\newline
\textbf{Escenario 2: Rechazo por colisión de SKU dentro de la organización}\newline
\textbf{Dado que} se envía una petición con un código SKU que ya fue asignado a otro producto en el mismo taller,\newline
\textbf{cuando} la restricción de integridad scoped al inquilino detecta la duplicidad,\newline
\textbf{entonces} responde con código HTTP 409 Conflict informando la colisión del código de parte,\newline
\textbf{y} deniega el guardado.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia técnica TS15.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia Técnica TS16 - Ingreso y valorización de lotes de repuestos por adquisición} \label{tbl:ts16} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
TS16 & Developer & Alta & EP10 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Ingreso y valorización de lotes por adquisición (\texttt{POST /api/v1/inventory/items/\{id\}/batches})} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} Developer,\newline \textbf{quiero} exponer el endpoint RESTful \texttt{POST /api/v1/inventory/items/\{id\}/batches},\newline \textbf{para} asentar ingresos físicos de mercadería registrando costo unitario de compra y cantidad recibida para la cola de consumo FIFO.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Asentamiento exitoso de lote de compras}\newline
\textbf{Dado que} se recibe una petición HTTP POST con el identificador del ítem, costo unitario de compra mayor a cero y cantidad de unidades ingresadas,\newline
\textbf{cuando} el servicio de logística valida la existencia del producto y la validez económica de los importes,\newline
\textbf{entonces} crea el lote con estampa de tiempo actual, incrementa el stock contable total del artículo y posiciona el lote en la cola de consumo FIFO,\newline
\textbf{y} responde con código HTTP 201 Created con el recurso del lote generado.\vspace{4pt}\newline
\textbf{Escenario 2: Rechazo por costo unitario de compra o cantidad negativa}\newline
\textbf{Dado que} la solicitud contiene un costo unitario o una cantidad de unidades menor o igual a cero,\newline
\textbf{cuando} el interceptor de validación analiza los campos numéricos,\newline
\textbf{entonces} responde con código HTTP 400 Bad Request detallando los errores de restricción,\newline
\textbf{y} no altera los registros de almacén.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia técnica TS16.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia Técnica TS17 - Marcación geodésica de jornada laboral con validación Haversine} \label{tbl:ts17} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
TS17 & Developer & Alta & EP10 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Marcación geodésica de jornada laboral con validación Haversine (\texttt{POST /api/v1/hr/attendances/clock-in})} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} Developer,\newline \textbf{quiero} exponer el endpoint RESTful \texttt{POST /api/v1/hr/attendances/clock-in},\newline \textbf{para} registrar la asistencia del personal comprobando la proximidad satelital a la sucursal mediante la fórmula de Haversine.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Marcación exitosa de ingreso dentro del radio perimétrico}\newline
\textbf{Dado que} un colaborador autenticado envía una petición HTTP POST con su membresía, latitud y longitud GPS capturadas en su dispositivo móvil,\newline
\textbf{cuando} el servicio calcula la distancia geodésica respecto a la sucursal asignada mediante la fórmula de Haversine y corrobora que no supera el radio de tolerancia configurado,\newline
\textbf{entonces} asienta la marcación de ingreso laboral con estampa cronológica inmutable,\newline
\textbf{y} responde con código HTTP 201 Created confirmando el registro de asistencia.\vspace{4pt}\newline
\textbf{Escenario 2: Rechazo de marcación por ubicación fuera de la geocerca}\newline
\textbf{Dado que} las coordenadas GPS enviadas sitúan al colaborador fuera del radio perimétrico autorizado de la sede física,\newline
\textbf{cuando} el algoritmo de Haversine constata la desviación espacial,\newline
\textbf{entonces} responde con código HTTP 422 Unprocessable Entity indicando la distancia excedente,\newline
\textbf{y} rechaza el registro de la marcación laboral.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia técnica TS17.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia Técnica TS18 - Emisión y timbrado de comprobantes electrónicos UBL 2.1} \label{tbl:ts18} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
TS18 & Developer & Alta & EP10 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Emisión y timbrado de comprobantes electrónicos UBL 2.1 (\texttt{POST /api/v1/invoicing/vouchers})} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} Developer,\newline \textbf{quiero} exponer el endpoint RESTful \texttt{POST /api/v1/invoicing/vouchers},\newline \textbf{para} generar Boletas o Facturas electrónicas desde órdenes completadas, calculando impuestos y transmitiendo el XML UBL 2.1 a SUNAT.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Emisión exitosa de comprobante tributario}\newline
\textbf{Dado que} se recibe una petición HTTP POST con el identificador de una orden de trabajo completada, tipo de comprobante (Boleta o Factura) y datos fiscales del receptor,\newline
\textbf{cuando} el servicio de facturación reserva el correlativo fiscal de la serie, calcula la base imponible y el dieciocho por ciento de IGV, genera el XML firmado UBL 2.1 y lo despacha al PSE Nubefact,\newline
\textbf{entonces} persiste el comprobante electrónico enlazado a la orden y almacena el enlace de descarga del archivo XML y la constancia de recepción CDR,\newline
\textbf{y} responde con código HTTP 201 Created con el resumen del comprobante emitido.\vspace{4pt}\newline
\textbf{Escenario 2: Rechazo de emisión por orden de trabajo no completada}\newline
\textbf{Dado que} se intenta emitir un comprobante fiscal para una orden de trabajo que aún mantiene faenas en estado pendiente o en progreso,\newline
\textbf{cuando} el servicio valida las reglas de facturación del taller,\newline
\textbf{entonces} responde con código HTTP 422 Unprocessable Entity indicando que la orden no ha culminado sus labores técnicas,\newline
\textbf{y} no consume ningún número correlativo fiscal.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia técnica TS18.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia Técnica TS19 - Registro transaccional de pagos y liquidación de comprobantes} \label{tbl:ts19} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
TS19 & Developer & Alta & EP10 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Registro transaccional de pagos y liquidación de comprobantes (\texttt{POST /api/v1/invoicing/payments})} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} Developer,\newline \textbf{quiero} exponer el endpoint RESTful \texttt{POST /api/v1/invoicing/payments},\newline \textbf{para} registrar cobros sobre un comprobante fiscal, actualizando el saldo adeudado y conmutando la orden a pagada al cubrirse el importe íntegro.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Pago total del comprobante y liberación de pase de salida}\newline
\textbf{Dado que} se recibe una petición HTTP POST con el identificador del comprobante, método de pago e importe que salda el cien por ciento de la deuda pendiente,\newline
\textbf{cuando} el servicio registra la transacción financiera, deduce el saldo del comprobante hasta cero y transiciona la orden de trabajo vinculada a estado pagada,\newline
\textbf{entonces} emite digitalmente el pase de salida vehicular y libera la bahía ocupada,\newline
\textbf{y} responde con código HTTP 201 Created con la confirmación de la liquidación total.\vspace{4pt}\newline
\textbf{Escenario 2: Rechazo por abono monetario superior al saldo adeudado}\newline
\textbf{Dado que} la solicitud especifica un monto de pago que excede el saldo remanente pendiente de liquidar en el comprobante electrónico,\newline
\textbf{cuando} el componente de validación financiera compara los importes,\newline
\textbf{entonces} responde con código HTTP 400 Bad Request informando que el abono supera la deuda,\newline
\textbf{y} revierte el registro del cobro.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia técnica TS19.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia Técnica TS20 - Ingesta masiva de telemetría vehicular IoT en series temporales} \label{tbl:ts20} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
TS20 & Developer & Media & EP10 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Ingesta masiva de telemetría vehicular IoT (\texttt{POST /api/v1/iot/telemetry/batch})} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} Developer,\newline \textbf{quiero} exponer el endpoint RESTful \texttt{POST /api/v1/iot/telemetry/batch},\newline \textbf{para} recibir ráfagas de telemetría OBD-II e insertarlas de forma reactiva en la hipertabla TimescaleDB para análisis sensorial predictivo.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Ingesta exitosa de ráfaga de telemetría sensorial}\newline
\textbf{Dado que} se recibe una petición HTTP POST autenticada con token de dispositivo que contiene entre una y cien lecturas de sensores (RPM, velocidad, temperatura del refrigerante y voltaje) con estampas de tiempo,\newline
\textbf{cuando} el controlador valida la estructura del payload y persiste concurrentemente el lote de mediciones en la hipertabla de TimescaleDB,\newline
\textbf{entonces} evalúa si algún parámetro sobrepasa los umbrales críticos de seguridad del motor,\newline
\textbf{y} responde de forma asíncrona con código HTTP 202 Accepted confirmando la ingesta de las muestras.\vspace{4pt}\newline
\textbf{Escenario 2: Rechazo por lote vacío o ráfaga que excede el límite}\newline
\textbf{Dado que} la solicitud contiene un arreglo de telemetría sin elementos o con más de cien lecturas por paquete,\newline
\textbf{cuando} el validador perimetral inspecciona el tamaño de la carga útil,\newline
\textbf{entonces} responde con código HTTP 400 Bad Request señalando la infracción de volumen de datos,\newline
\textbf{y} no procesa la inserción en la base de datos de series temporales.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia técnica TS20.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia Técnica TS21 - Registro y catalogación de códigos de avería electrónica DTC} \label{tbl:ts21} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
TS21 & Developer & Media & EP10 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Registro y catalogación de códigos de avería electrónica DTC (\texttt{POST /api/v1/iot/faults})} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} Developer,\newline \textbf{quiero} exponer el endpoint RESTful \texttt{POST /api/v1/iot/faults},\newline \textbf{para} registrar códigos de falla electrónica DTC estandarizados bajo norma SAE J2012 vinculados a la ficha vehicular para diagnóstico en patio.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Registro exitoso de código de falla vehicular DTC}\newline
\textbf{Dado que} se recibe una petición HTTP POST con el identificador del vehículo, código DTC normativo de cinco caracteres, descripción de la falla y nivel de criticidad,\newline
\textbf{cuando} el servicio comprueba la validez del identificador del automóvil y la existencia del subsistema de diagnóstico,\newline
\textbf{entonces} registra la avería electrónica en estado activa asociada a la ficha del vehículo para su atención en bahía,\newline
\textbf{y} responde con código HTTP 201 Created con el recurso de la falla asentada.\vspace{4pt}\newline
\textbf{Escenario 2: Rechazo por formato de código DTC no estandarizado}\newline
\textbf{Dado que} se envía una petición con un código de falla que no sigue el formato normativo de cinco caracteres iniciando con las letras P, B, C o U,\newline
\textbf{cuando} la expresión regular de validación analiza el patrón textual,\newline
\textbf{entonces} responde con código HTTP 400 Bad Request indicando la anomalía de nomenclatura,\newline
\textbf{y} descarta el guardado de la falla.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia técnica TS21.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia Técnica TS22 - Generación de informe pericial asistido por IA predictiva} \label{tbl:ts22} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
TS22 & Developer & Alta & EP10 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Generación de informe pericial asistido por IA predictiva (\texttt{POST /api/v1/iot/vehicles/\{id\}/health-reports/generate})} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} Developer,\newline \textbf{quiero} exponer el endpoint RESTful \texttt{POST /api/v1/iot/vehicles/\{id\}/health-reports/generate},\newline \textbf{para} extraer telemetría sensorial y fallas DTC, invocar al modelo de inteligencia artificial vía Spring AI y persistir el dictamen pericial con resumen y recomendaciones preventivas.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Generación exitosa de informe de salud vehicular con IA}\newline
\textbf{Dado que} se recibe una petición HTTP POST con el identificador del vehículo y los parámetros de ponderación de diagnóstico,\newline
\textbf{cuando} el servicio extrae las series de telemetría de TimescaleDB y las fallas DTC activas, formula el prompt estructurado e invoca al modelo de lenguaje a través de Spring AI,\newline
\textbf{entonces} el modelo genera el dictamen estructurado con semáforo de criticidad y recomendaciones de mantenimiento preventivo,\newline
\textbf{y} la API persiste el informe de salud, emite la cabecera \texttt{Location} y responde con código HTTP 201 Created con el resumen pericial.\vspace{4pt}\newline
\textbf{Escenario 2: Rechazo por datos de telemetría o fallas insuficientes}\newline
\textbf{Dado que} se solicita generar el informe para un vehículo que carece de registros de telemetría y códigos DTC en el intervalo de evaluación,\newline
\textbf{cuando} el servicio corrobora la disponibilidad de datos de entrada previa a la inferencia con el modelo generativo,\newline
\textbf{entonces} responde con código HTTP 422 Unprocessable Entity indicando la falta de información sensorial para el análisis predictivo,\newline
\textbf{y} no ejecuta llamadas externas hacia el proveedor de inteligencia artificial.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia técnica TS22.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia Técnica TS23 - Descarga documental de estado de flujo de caja en formato PDF} \label{tbl:ts23} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
TS23 & Developer & Media & EP10 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Descarga documental de estado de flujo de caja en formato PDF (\texttt{GET /api/v1/invoicing/financial-reports/cash-flow/pdf})} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} Developer,\newline \textbf{quiero} exponer el endpoint RESTful \texttt{GET /api/v1/invoicing/financial-reports/cash-flow/pdf},\newline \textbf{para} compilar y transmitir el balance de flujo de caja en un documento binario PDF para su uso por contadores externos.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Transmisión binaria exitosa de documento PDF de flujo de caja}\newline
\textbf{Dado que} se recibe una petición HTTP GET con parámetros de consulta que especifican fecha inicial, fecha final y sucursal,\newline
\textbf{cuando} el servicio compila los registros de ingresos y egresos fiscales del intervalo y genera la plantilla tipográfica en formato binario PDF,\newline
\textbf{entonces} la API responde con código HTTP 200 OK, cabecera \texttt{Content-Type: application/pdf} y cabecera \texttt{Content-Disposition} que define el nombre del archivo descargable,\newline
\textbf{y} transmite el flujo de bytes del documento para su descarga directa.\vspace{4pt}\newline
\textbf{Escenario 2: Rechazo por rango de fechas temporalmente invertido}\newline
\textbf{Dado que} los parámetros de consulta contienen una fecha de inicio posterior a la fecha de fin,\newline
\textbf{cuando} el validador de parámetros inspecciona los argumentos temporales de la petición,\newline
\textbf{entonces} la API responde con código HTTP 400 Bad Request detallando la incoherencia cronológica del intervalo,\newline
\textbf{y} no inicia la compilación del reporte PDF.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia técnica TS23.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia Técnica TS24 - Descarga documental de informe pericial de salud vehicular en PDF} \label{tbl:ts24} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
TS24 & Developer & Media & EP10 \\
\hline
\thfirst{Title} & \multicolumn{3}{p{\dimexpr\textwidth-2.2cm-4\tabcolsep-3\arrayrulewidth\relax}|}{Descarga documental de informe pericial de salud vehicular en PDF (\texttt{GET /api/v1/iot/vehicles/\{vehicleId\}/health-reports/\{reportId\}/pdf})} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} Developer,\newline \textbf{quiero} exponer el endpoint RESTful \texttt{GET /api/v1/iot/vehicles/\{vehicleId\}/health-reports/\{reportId\}/pdf},\newline \textbf{para} transmitir el archivo binario PDF maquetado con el dictamen pericial generado por IA y recomendaciones preventivas.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Descarga exitosa de dictamen pericial en documento PDF}\newline
\textbf{Dado que} se recibe una petición HTTP GET con identificadores válidos de vehículo e informe pericial previamente generado,\newline
\textbf{cuando} el servicio de infraestructura renderiza la plantilla documental incorporando membrete del taller, semáforos de criticidad y recomendaciones de IA,\newline
\textbf{entonces} la API responde con código HTTP 200 OK con cabecera \texttt{Content-Type: application/pdf} y cabecera \texttt{Content-Disposition} para descarga adjunta,\newline
\textbf{y} transmite el documento binario completo.\vspace{4pt}\newline
\textbf{Escenario 2: Notificación de recurso no encontrado por informe inexistente}\newline
\textbf{Dado que} se solicita el documento PDF para un identificador de informe que no existe o que no corresponde al vehículo indicado,\newline
\textbf{cuando} el repositorio ejecuta la búsqueda scoped en la base de datos,\newline
\textbf{entonces} la API responde con código HTTP 404 Not Found y una estructura \texttt{ProblemDetail} describiendo el recurso faltante,\newline
\textbf{y} no genera ningún archivo binario.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia técnica TS24.

**Spike Stories: Investigación y Reducción de Incertidumbre Técnica**

En el marco del desarrollo ágil de Atelier, las historias de tipo *Spike* corresponden a actividades de investigación técnica, análisis arquitectónico y pruebas de concepto orientadas a reducir la incertidumbre en componentes críticos antes de su implementación definitiva en el flujo de valor. Aunque no generan de forma directa un incremento funcional terminado para el usuario final, resultan fundamentales para evaluar la viabilidad de bibliotecas externas, validar restricciones de hardware móvil, medir tiempos de respuesta y acotar el esfuerzo requerido en el backlog del proyecto.

A continuación, se especifican tres *Spike Stories* formuladas para los desafíos de mayor complejidad técnica de la plataforma Atelier: la telemetría vehicular Bluetooth OBD-II asistida por modelos generativos de inteligencia artificial, el procesamiento recurrente de cobros mediante Stripe Billing y la arquitectura de sincronización resiliente *offline-first* sobre SQLite 3 en ambientes de fosa mecánica.

**Spike SP01: Investigación y Prototipado de Telemetría Bluetooth OBD-II e Inferencia Predictiva con Spring AI**

**Contexto Técnico y Motivación:**

Atelier Workshop Mobile es una aplicación multiplataforma desarrollada en Flutter y Dart orientada a dispositivos móviles Android e iOS para personal técnico de patio, mientras que la plataforma backend opera como un monolito modular implementado en Spring Boot con Java 21, persistencia relacional en PostgreSQL 16 y series temporales sobre TimescaleDB. La funcionalidad de diagnóstico predictivo exige enlazar de forma inalámbrica los dispositivos móviles de los mecánicos con adaptadores OBD-II mediante Bluetooth Low Energy (BLE) y protocolo serie ELM327, capturando parámetros cinemáticos estandarizados bajo la norma SAE J1979 (tales como revoluciones por minuto, temperatura del refrigerante y presiones de admisión) y códigos de falla electrónica DTC según la especificación SAE J2012.

Dicha información debe transmitirse hacia la API central para su inserción en hipertablas y su análisis mediante el framework Spring AI conectado a un modelo fundacional de lenguaje, con el propósito de generar diagnósticos preventivos y recomendaciones automotrices. La presente investigación es indispensable para reducir la incertidumbre asociada a la estabilidad del enlace BLE en entornos de fosa con alta interferencia electromagnética, el consumo energético en dispositivos móviles de gama de entrada y la latencia y calidad semántica del dictamen generado por la inteligencia artificial.

**Spike Story:**

\textbf{Como} equipo de desarrollo móvil y backend,\newline
\textbf{quiero} investigar y construir una prueba de concepto que enlace un adaptador Bluetooth OBD-II en Flutter y procese la telemetría vehicular mediante Spring AI en el backend,\newline
\textbf{para} determinar la viabilidad técnica de la comunicación inalámbrica, medir la latencia de inferencia y estimar el esfuerzo de desarrollo para el módulo de diagnóstico predictivo.

**Criterios de Aceptación (Given-When-Then):**

1. *Evaluación de bibliotecas BLE en Flutter:*
   - **Dado que** el equipo necesita establecer comunicación serial con escáneres ELM327 en Android e iOS,
   - **cuando** el desarrollador analiza las librerías móviles disponibles (`flutter_blue_plus` y canales nativos en Kotlin y Swift),
   - **entonces** documenta la compatibilidad de conexión, permisos de escaneo y mecanismos de reconexión automática en un informe técnico compartido.

2. *Validación del decodificador de tramas OBD-II y códigos DTC:*
   - **Dado** el flujo de respuestas hexadecimales emitidas por la computadora del vehículo,
   - **cuando** el desarrollador implementa las rutinas de conversión de parámetros PID estándar y códigos DTC bajo la norma SAE J2012,
   - **entonces** verifica la exactitud matemática de las lecturas físicas e incorpora los algoritmos de conversión en el prototipo.

3. *Evaluación de la inferencia asistida por IA con Spring AI:*
   - **Dado** el backend Spring Boot configurado con el starter de Spring AI,
   - **cuando** el desarrollador formula prompts estructurados alimentados con lecturas de telemetría y fallas activas,
   - **entonces** evalúa la coherencia de las recomendaciones mecánicas emitidas por el modelo de lenguaje, la estructura de la respuesta JSON y el tiempo promedio de respuesta.

4. *Análisis de seguridad y permisos en el sistema operativo móvil:*
   - **Dado** el requerimiento de acceder a periféricos de radiofrecuencia y almacenamiento local,
   - **cuando** el equipo audita las directivas de seguridad en Android 14 y iOS 18,
   - **entonces** define la configuración mínima requerida en los manifiestos de la aplicación móvil evitando solicitar permisos innecesarios al usuario.

5. *Evaluación de latencia y persistencia temporal en TimescaleDB:*
   - **Dado** el volumen de telemetría transmitido en ráfagas de alta densidad temporal,
   - **cuando** el desarrollador ejecuta pruebas de carga hacia el endpoint de ingesta masiva,
   - **entonces** mide la latencia de red y el rendimiento de inserción en hipertablas documentando los umbrales máximos sugeridos por paquete.

6. *Construcción del prototipo funcional de prueba de concepto:*
   - **Dado** el objetivo de mitigar riesgos técnicos previo al desarrollo formal,
   - **cuando** el equipo desarrolla un prototipo funcional mínimo capaz de escanear un adaptador OBD-II, leer tres parámetros en vivo y recibir un informe predictivo procesado por Spring AI,
   - **entonces** el código fuente se registra en una rama experimental del repositorio de control de versiones.

7. *Estimación de esfuerzo y dependencias:*
   - **Dado** el informe consolidado de la prueba de concepto,
   - **cuando** el equipo desglosa la implementación en tareas móviles y de backend,
   - **entonces** calcula la estimación de esfuerzo en horas hombre para las historias de usuario de diagnóstico en el backlog.

**Definition of Done (DoD):**

- El código fuente de la prueba de concepto se encuentra debidamente versionado en la rama experimental del repositorio.
- El informe técnico con conclusiones de viabilidad y arquitectura se comparte y revisa en sesión de refinamiento con el equipo.
- Los hallazgos sobre latencia y formatos de prompt se traducen en criterios de aceptación para las historias de implementación.
- La ejecución de la investigación se completa dentro de un límite temporal acotado de dieciséis horas laborables.

**Spike SP02: Investigación de la Pasarela de Pagos Stripe y Webhooks Asíncronos para Suscripciones SaaS**

**Contexto Técnico y Motivación:**

Atelier se comercializa como una solución SaaS multi-inquilino en la que cada taller automotriz contrata un plan de suscripción que delimita sus capacidades operativas (número de bahías físicas, colaboradores y sucursales habilitadas). La monetización de la plataforma exige procesar transacciones periódicas de cobro recurrente con tarjetas de crédito y débito asegurando el cumplimiento estricto del estándar de seguridad para la industria de tarjetas de pago (PCI-DSS).

El backend en Spring Boot y Java 21 debe comunicarse con la API de Stripe mediante la biblioteca oficial `stripe-java`, en tanto que las aplicaciones cliente deben posibilitar el inicio del flujo de pago sin exponer datos bancarios sensibles en los servidores del sistema. Asimismo, la arquitectura debe resolver la recepción asíncrona e idempotente de eventos vía webhooks (`customer.subscription.updated`, `invoice.payment_succeeded`, `invoice.payment_failed`) para habilitar o suspender de forma automatizada las cuotas operativas del taller sin requerir intervención manual de soporte.

**Spike Story:**

\textbf{Como} equipo de desarrollo web, móvil y backend,\newline
\textbf{quiero} investigar y prototipar la integración de Stripe Billing y el procesamiento de webhooks asíncronos en Spring Boot,\newline
\textbf{para} comprender las exigencias de seguridad PCI-DSS, resolver la conciliación transaccional idempotente y estimar el esfuerzo de integración para la gestión de suscripciones SaaS.

**Criterios de Aceptación (Given-When-Then):**

1. *Revisión de documentación de Stripe Billing y Checkout:*
   - **Dado que** la plataforma requiere cobros recurrentes automáticos para los planes de los talleres,
   - **cuando** el desarrollador analiza la API de Stripe Billing y los flujos alojados de Stripe Checkout,
   - **entonces** documenta la arquitectura de integración más conveniente para el modelo de suscripciones en un informe técnico.

2. *Evaluación del SDK de Stripe en Spring Boot:*
   - **Dado** el backend Spring Boot utilizando Java 21,
   - **cuando** el desarrollador incorpora la dependencia `stripe-java` y ejecuta pruebas de creación programática de clientes y sesiones de pago,
   - **entonces** documenta la configuración de claves criptográficas y variables de entorno requeridas.

3. *Manejo e idempotencia de webhooks de notificación de pagos:*
   - **Dado que** Stripe transmite los estados de pago de manera asíncrona mediante peticiones HTTP POST,
   - **cuando** el desarrollador implementa un controlador de webhooks que verifica la firma digital `Stripe-Signature`,
   - **entonces** comprueba la deduplicación de eventos y la persistencia transaccional del estado de suscripción del inquilino en la base de datos.

4. *Auditoría de cumplimiento normativo PCI-DSS:*
   - **Dado** el requerimiento de seguridad de no almacenar números de tarjeta en la infraestructura de Atelier,
   - **cuando** el equipo analiza el flujo de tokenización del lado del cliente provisto por Stripe,
   - **entonces** certifica que la plataforma califica para el nivel de cumplimiento simplificado SAQ-A sin almacenamiento de datos bancarios.

5. *Construcción del prototipo funcional de suscripción:*
   - **Dado** el entorno de pruebas de Stripe con tarjetas de test simuladas,
   - **cuando** el desarrollador ejecuta un ciclo completo de suscripción, recepción de webhook de éxito y habilitación automática de cupos de bahía,
   - **entonces** el flujo concluye satisfactoriamente y el código del prototipo se registra en una rama del repositorio.

6. *Estimación de esfuerzo y comisiones de pasarela:*
   - **Dado** el informe de la investigación técnica,
   - **cuando** se tabulan los costos por transacción de Stripe y las horas requeridas para la implementación completa,
   - **entonces** el equipo define la estimación formal en puntos de historia para la épica de suscripciones SaaS.

**Definition of Done (DoD):**

- El código de la prueba de concepto con Stripe y validación de webhooks se encuentra registrado en el repositorio.
- El informe con los lineamientos de seguridad PCI-DSS y gestión de reintentos de cobro se revisa con el equipo de arquitectura.
- Se definen las historias de usuario de implementación en el backlog a partir de los hallazgos técnicos.
- La investigación se completa en un tiempo límite de doce horas de trabajo técnico

**Spike SP03: Persistencia Relacional Local SQLite 3 y Sincronización Offline-First en Fosa de Taller**

**Contexto Técnico y Motivación:**

Las labores mecánicas de mantenimiento y reparación en talleres automotrices se realizan frecuentemente en zonas con cobertura inalámbrica nula o inestable, tales como fosas de alineación subterráneas o patios con cerramientos metálicos. Para evitar la detención de las actividades operativas del personal técnico al registrar mediciones, cronometrar faenas o solicitar repuestos, la aplicación móvil Atelier Workshop Mobile adopta un diseño *offline-first* sustentado en una base de datos relacional local embebida sobre SQLite 3.

Este enfoque arquitectónico exige comprobar la persistencia atómica de mutaciones locales (apertura de tarea, pausa cronometrada, registro de evidencias fotográficas) en esquemas espejo desacoplados, así como la sincronización bidireccional determinista cuando el teléfono inteligente recupera conectividad con el backend central en Spring Boot. El spike busca evaluar la integridad de la cola de transacciones locales pendientes, la política de resolución de conflictos de concurrencia y el impacto en el consumo de memoria en dispositivos móviles de recursos moderados.

**Spike Story:**

\textbf{Como} equipo de desarrollo móvil y de datos,\newline
\textbf{quiero} investigar y prototipar el motor de persistencia relacional local en SQLite 3 y el protocolo de sincronización bidireccional con reintentos exponenciales,\newline
\textbf{para} certificar que los mecánicos puedan operar de forma ininterrumpida sin conexión a internet y sincronizar las órdenes de trabajo sin pérdida ni duplicidad de información.

**Criterios de Aceptación (Given-When-Then):**

1. *Evaluación del motor relacional embebido en Flutter:*
   - **Dado que** la aplicación móvil requiere almacenar esquemas relacionales complejos localmente,
   - **cuando** el desarrollador evalúa el desempeño de SQLite 3 en Flutter frente a almacenes clave-valor no relacionales,
   - **entonces** documenta la velocidad de consulta, soporte de migraciones automáticas y consistencia transaccional en un informe técnico.

2. *Diseño y validación de la cola de mutaciones sin conexión:*
   - **Dado que** un técnico efectúa intervenciones mecánicas en estado de desconexión de red,
   - **cuando** el prototipo registra los comandos de cambio con marcas cronológicas inmutables en la tabla de transacciones pendientes,
   - **entonces** constata que las modificaciones queden resguardadas atómicamente a la espera de la conectividad.

3. *Resolución determinista de conflictos de concurrencia:*
   - **Dado que** una labor técnica fue pausada localmente en fosa mientras un supervisor modificó su estado desde el panel web,
   - **cuando** el motor de sincronización procesa los eventos pendientes al reanudarse la red,
   - **entonces** aplica la regla de resolución basada en marcas temporales auditables preservando la coherencia del estado del servicio.

4. *Prueba de concepto de sincronización con retroceso exponencial:*
   - **Dado** un escenario de red inestable con microcortes continuos de señal celular,
   - **cuando** el servicio en segundo plano procesa la cola de sincronización aplicando reintentos progresivos,
   - **entonces** comprueba que todos los registros locales pendientes se transmitan ordenadamente al backend sin duplicar peticiones HTTP.

5. *Documentación técnica y dimensionamiento de almacenamiento:*
   - **Dado** el análisis de rendimiento en dispositivos físicos de prueba,
   - **cuando** el equipo mide el uso de almacenamiento y consumo de memoria del motor SQLite 3,
   - **entonces** formaliza las directrices de diseño *offline-first* y dimensiona el esfuerzo de desarrollo en el backlog.

**Definition of Done (DoD):**

- El código de la prueba de concepto con SQLite 3 y cola de sincronización se encuentra versionado en la rama de investigación del repositorio.
- Se documenta la estrategia de caché local de permisos RBAC y el protocolo de reintentos en el informe técnico compartido.
- Las conclusiones y métricas de desempeño se utilizan para refinar las historias de usuario de ejecución en bahía.
- El spike se concluye en un plazo no mayor a catorce horas laborables dentro del sprint.

### 2.4.2. *Impact Mapping*

El Impact Mapping constituye una técnica visual de planificación estratégica colaborativa formulada por Gojko Adzic, orientada a alinear de manera directa las decisiones de diseño e ingeniería de software con los objetivos globales del modelo de negocio digital. Este artefacto previene la construcción de características innecesarias o desarticuladas, asegurando que cada componente técnico y cada requerimiento funcional justifiquen su existencia mediante una cadena causal ininterrumpida. Dicha articulación conecta las metas cuantificables de la organización, los actores clave involucrados en los procesos, los cambios observables de comportamiento requeridos y las capacidades del software destinadas a provocar dichas transformaciones.

Para articular esta visión estratégica, el equipo de ingeniería desarrolló los mapas de impacto utilizando la plataforma especializada UXPressia, herramienta en la cual se elaboraron previamente las fichas de caracterización de los arquetipos de usuario presentadas en la Sección 2.3.1. A través de este entorno, se estructuraron dos mapas de impacto diferenciados que responden a las dinámicas particulares de los dos segmentos objetivo del ecosistema Atelier: el Personal de Gestión y Propietarios del Taller, representado por Pedro Suárez, y el Personal Operativo del Taller, personificado por Andrés Vílchez.

La arquitectura analítica de cada mapa de impacto se fundamenta en cuatro niveles estructurales jerárquicos:

- **Business Goals:** Definen el «¿Por qué?» del producto mediante enunciados cuantitativos formulados bajo criterios SMART (Específicos, Medibles, Alcanzables, Relevantes y con Horizonte Temporal definido). Estas metas condensan los desafíos económicos y de productividad que la plataforma debe resolver para asegurar la rentabilidad del taller.
- **Actores:** Identifican el «¿Quién?» hace posible el alcance de la meta, integrando a los User Personas modelados a partir del trabajo de campo e investigación de mercado.
- **Impactos:** Describen el «¿Cómo?» deben comportarse o cambiar sus hábitos de trabajo los actores para viabilizar el cumplimiento de las metas, respondiendo a la pregunta sobre qué deben empezar a hacer, dejar de hacer o realizar de manera distinta en su rutina diaria.
- **Deliverables & User Stories:** Responden al «¿Qué?» puede implementar la plataforma digital para catalizar los impactos deseados, materializándose en módulos de software que se traducen formalmente en las historias de usuario y técnicas que componen el catálogo de producto.

**Metas de Negocio Cuantitativas Bajo Criterios SMART**

Con el propósito de orientar el desarrollo hacia resultados de alto impacto organizacional, se establecieron dos metas estratégicas de negocio:

1. **Meta SMART 1 (Gestión Administrativa y Financiera):** Reducir en 50% el tiempo promedio invertido en tareas administrativas rutinarias (elaboración manual de proformas, cuadres de inventario y facturación tributaria) en los talleres automotrices afiliados durante un periodo de seis meses contados a partir del despliegue productivo del ecosistema. Esta meta atiende de forma directa la saturación laboral del dueño de taller, liberando horas hombre gerenciales para la atención personalizada y la captación de clientes.
2. **Meta SMART 2 (Eficiencia Operativa en Bahía y Diagnóstico):** Reducir en 40% los tiempos muertos en bahía de mantenimiento y acortar el diagnóstico vehicular inicial en 35% durante los primeros seis meses de adopción tecnológica, eliminando transcripciones en papel y agilizando la autorización de trabajos mediante telemetría en tiempo real y arquitectura con sincronización local resiliente.

**Impact Mapping del Personal de Gestión y Propietarios del Taller (Pedro Suárez)**

El primer mapa de impacto se concentra en el segmento directivo y administrativo encarnado en Pedro Suárez. Tal como se analizó en la matriz de tareas de la Sección 2.3.2, Pedro asume en solitario la doble responsabilidad de coordinar el servicio de patio y gestionar la contabilidad del negocio, convirtiéndose en el cuello de botella cuando se acumulan cotizaciones pendientes o trámites ante la autoridad tributaria.

En la @fig:impact-mapping-pedro-suarez se presenta el mapa de impacto correspondiente a Pedro Suárez desarrollado en la herramienta UXPressia:

![Impact Mapping para el Personal de Gestión del Taller - Pedro Suárez](report/assets/NeedFinding/Impact-Mapping/Impact-map-Pedro-Suarez.png){#fig:impact-mapping-pedro-suarez width=100%}

*Nota.* Mapa de impacto elaborado en la herramienta UXPressia para el arquetipo Pedro Suárez, conectando metas de negocio con entregables de software. Elaboración propia (2026).

\newpage

A partir de la Meta SMART 1, el mapa de Pedro Suárez desglosa tres trayectorias de impacto hacia el software:

- **Impacto 1 (Cotizaciones Ágiles):** Pedro necesita estructurar presupuestos comerciales en pocos minutos a partir de costos vigentes y existencias reales, evitando cotizaciones manuales en talonarios que provocan errores de cálculo o desfases de precios. Para facilitar este cambio, la plataforma provee como entregable el módulo web de cotizaciones rápidas con costeo bajo regla FIFO, el cual se instrumenta funcionalmente en las historias US22 y US24 mediante el cómputo automático de impuestos y la generación de proformas digitales en PDF.
- **Impacto 2 (Continuidad de Cadena de Suministro):** El administrador debe evitar que los vehículos queden inmovilizados en los elevadores por quiebres de existencias imprevistos durante la intervención mecánica. El entregable asociado comprende el sistema de alertas de stock mínimo y reposición en inventario, soportado operativamente por la historia US31 para la consulta en tiempo real del catálogo de repuestos y su disponibilidad en almacén.
- **Impacto 3 (Cumplimiento Fiscal Integrado):** Pedro requiere liquidar y facturar los servicios prestados con un solo clic al declarar la orden concluida, eliminando el retrabajo de reingresar comprobantes en los portales web de la administración tributaria. El entregable tecnológico consiste en el motor nativo de emisión electrónica bajo el estándar UBL 2.1 ante SUNAT, materializado en las historias US37 y US38 para la emisión automatizada de comprobantes tributarios y el registro transaccional de pagos.

La @tbl:impact-mapping-pedro sintetiza la alineación estratégica derivada del mapa de impacto para el perfil de gestión en función de la Meta SMART 1 (Reducción del 50% en tareas administrativas):

| Impacto Deseado | Entregable del Sistema | Historia de Usuario Formulada (UXPressia) | Historias en Catálogo |
| :----- | :----- | :------- | :---: |
| Armar presupuestos en minutos con precios y repuestos reales. | Módulo web de cotizaciones rápidas con costeo FIFO. | Como dueño de taller, quiero generar cotizaciones automáticas con el stock real, para enviar presupuestos al cliente en pocos minutos. | US22, US24 |
| Evitar quedarse sin repuestos clave a mitad de una reparación. | Alertas de stock mínimo en inventario. | Como dueño de taller, quiero recibir avisos cuando un repuesto se esté agotando, para reponerlo a tiempo y no frenar el taller. | US31, US33 |
| Facturar en un clic al cerrar la orden sin entrar a la página de SUNAT. | Emisión electrónica SUNAT nativa (UBL 2.1). | Como dueño de taller, quiero emitir boletas y facturas directo desde la orden terminada, para cobrar rápido y cumplir con SUNAT sin doble trabajo. | US37, US38 |
: Matriz de Trazabilidad de Impact Mapping para Pedro Suárez {#tbl:impact-mapping-pedro}

*Nota.* Alineación causal entre impactos esperados, entregables e historias de usuario de gestión.

\newpage

**Impact Mapping del Personal Operativo del Taller (Andrés Vílchez)**

El segundo mapa de impacto se orienta a optimizar la labor del personal técnico de patio personificado por Andrés Vílchez. Como se documentó en las entrevistas de la Sección 2.2 y el mapa de empatía de la Sección 2.3.4, la principal frustración de los mecánicos radica en la inactividad involuntaria producida por esperas de autorización o demoras en la inspección física tradicional con libretas manuales.

En la @fig:impact-mapping-andres-vilchez se ilustra el mapa de impacto de Andrés Vílchez diseñado en la herramienta UXPressia:

![Impact Mapping para el Personal Operativo del Taller - Andrés Vílchez](report/assets/NeedFinding/Impact-Mapping/Impact-map-Andres-Vilchez.png){#fig:impact-mapping-andres-vilchez width=100%}

*Nota.* Mapa de impacto elaborado en la herramienta UXPressia para el arquetipo Andrés Vílchez, conectando metas de patio con entregables de software. Elaboración propia (2026).

\newpage

En función de la Meta SMART 2, el mapa de Andrés estructura tres líneas de impacto operativo directo en bahía:

- **Impacto 1 (Digitalización del Diagnóstico Computarizado):** El mecánico debe realizar el escaneo de la unidad sin recurrir a anotaciones manuales ni hojas volantes de papel, obteniendo los códigos de avería de manera directa en su dispositivo móvil de trabajo. El entregable corresponde al escaneo OBD-II automático en la aplicación móvil Atelier Workshop Mobile, el cual se viabiliza mediante las historias US16, US17 y US18 que gestionan el enlace inalámbrico Bluetooth, la decodificación de parámetros cinemáticos bajo norma SAE J1979 y el registro de fallas DTC.
- **Impacto 2 (Operatividad Ininterrumpida en Fosas):** Andrés necesita continuar registrando avances, checklists periciales y tiempos laborados aun cuando descienda a fosas de inspección o trabaje en zonas del patio sin cobertura de red inalámbrica, impidiendo que el aplicativo se bloquee. El entregable consiste en la arquitectura móvil con soporte local resiliente y sincronización automática, sustentado en la historia US19 y respaldado técnicamente por el spike SP03.
- **Impacto 3 (Notificación Inmediata de Autorizaciones):** El técnico de bahía debe enterarse de forma instantánea en el momento exacto en que un cliente aprueba un presupuesto o cuando un repuesto requerido ingresa al área de trabajo, suprimiendo traslados innecesarios a la recepción. El entregable corresponde al subsistema de notificaciones en tiempo real, operativizado a través de las historias US25 y US26 para la formalización de tareas y la priorización del plan de faenas en el puesto de trabajo.

La @tbl:impact-mapping-andres sintetiza la alineación estratégica derivada del mapa de impacto para el perfil operativo de bahía en función de la Meta SMART 2 (Reducción del 40% en tiempos muertos y 35% en diagnósticos iniciales):

| Impacto Deseado | Entregable del Sistema | Historia de Usuario Formulada (UXPressia) | Historias en Catálogo |
| :----- | :----- | :------- | :---: |
| Diagnosticar sin anotar a mano ni usar papel. | Escaneo OBD-II automático en la app móvil. | Como mecánico, quiero escanear el auto desde la app y ver los códigos de falla al instante, para no perder tiempo anotando a mano. | US16, US17 |
| Usar la app en fosas o zonas sin internet sin que se cuelgue. | Modo Offline-First con sincronización automática. | Como mecánico, quiero registrar mis avances sin internet, para que mi trabajo no se detenga en zonas sin señal. | US19, SP03 |
| Enterarse al momento cuando aprueban un presupuesto o llega un repuesto. | Notificaciones push en tiempo real. | Como mecánico, quiero recibir una alerta en mi celular cuando el cliente apruebe el trabajo, para empezar a reparar sin esperar confirmaciones. | US25, US26 |
: Matriz de Trazabilidad de Impact Mapping para Andrés Vílchez {#tbl:impact-mapping-andres}

*Nota.* Alineación causal entre impactos esperados, entregables e historias de usuario técnicas.

\newpage

**Articulación Metodológica con el Catálogo de Producto**

La formulación de los mapas de impacto en UXPressia asegura que el conjunto de historias de usuario y técnicas que integran la Sección 2.4.1 no obedezca a una acumulación arbitraria de funcionalidades, sino a una respuesta deliberada frente a cuellos de botella reales identificados en la labor de campo. Cada entregable modelado en esta sección se descompone en requerimientos comprobables con criterios de aceptación en sintaxis Gherkin, los cuales son posteriormente ponderados por valor de negocio y capacidad de entrega en el Product Backlog de la Sección 2.4.3. Esta trazabilidad bidireccional garantiza que la evolución técnica del software se mantenga permanentemente anclada al beneficio tangible de los usuarios y a la sostenibilidad financiera de los talleres mecánicos.

![Impact Map: Segmento 1 - Pedro Suárez](report/assets/NeedFinding/Impact-Mapping/Impact-map-Pedro-Suarez.png)

El mapa de impacto del primer segmento objetivo nos ayudó a entender cómo el dueño o administrador del taller tiene un rol crítico como cuello de botella administrativo. Nos permitió identificar oportunidades clave para reducir su carga operativa, como la necesidad de generar cotizaciones automatizadas con precios reales y la integración de facturación electrónica. Asimismo, nos permitió extender el alcance de la plataforma al contemplar módulos vitales para la rentabilidad del negocio, tales como el sistema de alertas de stock mínimo para evitar el desabastecimiento durante las reparaciones.

**Segmento 2: Personal Operativo y Técnicos de Bahía**

![Impact Map: Segmento 2 - Andrés Vílchez](report/assets/NeedFinding/Impact-Mapping/Impact-map-Andres-Vilchez.png)

El mapa de impacto del segundo segmento objetivo evidenció cómo el mecánico de bahía es fundamental para cumplir la meta de reducir los tiempos muertos operativos. A través de este análisis, identificamos oportunidades tecnológicas urgentes en su entorno de trabajo, como la necesidad de contar con una aplicación móvil *Offline-First* que soporte la pérdida de señal en fosas y herramientas de diagnóstico automático OBD-II. Esto nos permitió orientar los entregables hacia la inmediatez, incorporando notificaciones push para la aprobación de presupuestos y recepción de repuestos, agilizando así el flujo de servicio.
### 2.4.3. *Product Backlog*

El *Product Backlog* consolida el catálogo priorizado y estimado de todos los incrementos funcionales (User Stories), servicios de plataforma (Technical Stories) y actividades de mitigación de incertidumbre técnica (Spikes) que componen el ecosistema Atelier. Las estimaciones relativas fueron determinadas mediante la técnica de *Planning Poker* bajo la serie de Fibonacci modificada, estableciendo como regla metodológica un límite máximo de 5 puntos de historia (1, 2, 3 o 5 SP) para asegurar un flujo de entrega continua y predecible sin historias sobredimensionadas.

La priorización de las incidencias está determinada estrictamente por el retorno de valor de negocio (*Business Value*) percibido por los usuarios y propietarios del taller automotriz. Por ello, el catálogo está liderado por las capacidades nucleares del servicio: recepción e inspección pericial vehicular, diagnóstico telemático OBD-II, órdenes de trabajo, ejecución en bahía, abastecimiento FIFO de repuestos y facturación electrónica UBL 2.1 ante SUNAT; mientras que las historias de infraestructura de acceso, identidad y control satelital se ubican como habilitadores operativos transversales. La planificación abarca tres sprints de desarrollo, considerando la puesta en marcha del sitio web estático (*Landing Page*) y el producto mínimo viable (MVP) de patio desde el primer sprint.

A continuación, la @tbl:product-backlog presenta la matriz consolidada del *Product Backlog* del ecosistema Atelier:

\renewcommand{\arraystretch}{1.2}
\begin{longtable}{| >{\centering\arraybackslash}p{1.5cm} | >{\centering\arraybackslash}p{2.2cm} | >{\raggedright\arraybackslash}p{\dimexpr\textwidth-9.5cm-10\tabcolsep-6\arrayrulewidth\relax} | >{\centering\arraybackslash}p{3.6cm} | >{\centering\arraybackslash}p{2.2cm} |}
\caption{Product Backlog Priorizado del Ecosistema Atelier} \label{tbl:product-backlog} \\
\hline
\thfirst{\# Orden} & \thcell{User Story Id} & \thcell{Título} & \thcell{Story Points\newline (1 / 2 / 3 / 5 / 8)} & \thcell{Sprint} \\
\hline
\endfirsthead
\hline
\thfirst{\# Orden} & \thcell{User Story Id} & \thcell{Título} & \thcell{Story Points\newline (1 / 2 / 3 / 5 / 8)} & \thcell{Sprint} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
1 & US11 & Búsqueda y vinculación de cliente y vehículo por placa o documento & 2 & Sprint 1 \\
\hline
2 & US12 & Apertura de orden de trabajo y parametrización de tareas iniciales & 3 & Sprint 1 \\
\hline
3 & TS04 & Búsqueda y vinculación de clientes con verificación tributaria (\texttt{POST /api/v1/crm/customers}) & 2 & Sprint 1 \\
\hline
4 & TS05 & Apertura transaccional de orden de trabajo (\texttt{POST /api/v1/operations/work-orders}) & 3 & Sprint 1 \\
\hline
5 & US16 & Enlace inalámbrico y sincronización de escáner OBD-II en bahía & 3 & Sprint 1 \\
\hline
6 & US17 & Extracción y decodificación de códigos de falla computarizados & 2 & Sprint 1 \\
\hline
7 & US18 & Monitoreo dinámico de parámetros telemétricos en tiempo real & 3 & Sprint 1 \\
\hline
8 & TS18 & Ingesta masiva y persistencia de telemetría OBD-II (\texttt{POST /api/v1/iot/telemetry/ingest}) & 3 & Sprint 1 \\
\hline
9 & TS19 & Extracción y almacenamiento de códigos de falla DTC (\texttt{POST /api/v1/iot/vehicles/\{id\}/dtc-records}) & 3 & Sprint 1 \\
\hline
10 & SP01 & Telemetría Bluetooth OBD-II e Inferencia Predictiva con Spring AI & 5 & Sprint 1 \\
\hline
11 & US26 & Consulta y priorización de tareas mecánicas asignadas en bahía & 2 & Sprint 1 \\
\hline
12 & US27 & Cronometraje de labor efectiva, pausas operativas y sincronización con turnos laborales & 3 & Sprint 1 \\
\hline
13 & TS08 & Actualización y transición de estados operativos de tarea (\texttt{PATCH /api/v1/operations/tasks/\{id\}/status}) & 2 & Sprint 1 \\
\hline
14 & US31 & Búsqueda y consulta de disponibilidad de repuestos en catálogo & 2 & Sprint 1 \\
\hline
15 & TS10 & Búsqueda de repuestos y validación de stock disponible (\texttt{GET /api/v1/inventory/items}) & 2 & Sprint 1 \\
\hline
16 & US13 & Registro pericial de evidencias fotográficas de recepción vehicular & 2 & Sprint 1 \\
\hline
17 & US22 & Cómputo automático en cascada de costos de tareas e impuestos & 3 & Sprint 1 \\
\hline
18 & SP02 & Pasarela de Pagos Stripe y Webhooks Asíncronos para Suscripciones SaaS & 3 & Sprint 1 \\
\hline
19 & SP03 & Persistencia Relacional Local SQLite 3 y Sincronización Offline-First en Fosa & 3 & Sprint 1 \\
\hline
20 & US06 & Marcación de ingreso laboral con validación de geocerca GPS satelital & 3 & Sprint 1 \\
\hline
21 & TS16 & Marcación satelital de ingreso con validación Haversine (\texttt{POST /api/v1/hr/attendance/clock-in}) & 3 & Sprint 1 \\
\hline
22 & US08 & Marcación de salida y liquidación de jornada laboral efectiva & 2 & Sprint 1 \\
\hline
23 & US07 & Auditoría perimétrica y contingencias de conectividad satelital & 2 & Sprint 1 \\
\hline
24 & US01 & Registro y vinculación de colaborador mediante invitación corporativa & 2 & Sprint 1 \\
\hline
25 & US02 & Verificación de identidad y correo electrónico mediante código OTP & 2 & Sprint 1 \\
\hline
26 & US03 & Inicio de sesión corporativo y contextualización de sede de trabajo & 3 & Sprint 1 \\
\hline
27 & TS01 & Autenticación de credenciales y expedición de tokens JWT (\texttt{POST /api/v1/auth/sign-in}) & 2 & Sprint 1 \\
\hline
28 & TS02 & Vinculación de colaborador mediante aceptación de invitación (\texttt{POST /api/v1/iam/memberships/accept-invitation}) & 2 & Sprint 1 \\
\hline
29 & TS03 & Registro y aprovisionamiento de sucursal de taller (\texttt{POST /api/v1/iam/workshops/\{id\}/branches}) & 2 & Sprint 1 \\
\hline
30 & US24 & Generación y remisión digital de proforma comercial en PDF & 3 & Sprint 2 \\
\hline
31 & US25 & Formalización de resolución de presupuesto tras comunicación externa & 2 & Sprint 2 \\
\hline
32 & TS06 & Parametrización y agregación de tareas mecánicas (\texttt{POST /api/v1/operations/work-orders/\{id\}/tasks}) & 3 & Sprint 2 \\
\hline
33 & TS07 & Formulación y cálculo de presupuesto de mantenimiento (\texttt{POST /api/v1/operations/quotes}) & 3 & Sprint 2 \\
\hline
34 & US30 & Cierre técnico de tarea con cómputo de horas hombre efectivas & 2 & Sprint 2 \\
\hline
35 & TS09 & Registro de intervalos y cronometraje de horas hombre (\texttt{POST /api/v1/operations/tasks/\{id\}/time-logs}) & 2 & Sprint 2 \\
\hline
36 & US32 & Descargo contable y físico automatizado mediante regla estricta FIFO por lote & 5 & Sprint 2 \\
\hline
37 & TS11 & Descargo atómico de existencias bajo regla estricta FIFO (\texttt{POST /api/v1/inventory/movements/fifo-dispatch}) & 5 & Sprint 2 \\
\hline
38 & US35 & Imputación automática de precios de venta de catálogo y conciliación de margen FIFO & 3 & Sprint 2 \\
\hline
39 & US21 & Generación de informe pericial predictivo con inteligencia artificial y exportación en PDF & 5 & Sprint 2 \\
\hline
40 & TS20 & Inferencia predictiva y generación de reporte con Spring AI (\texttt{POST /api/v1/iot/vehicles/\{id\}/health-reports/generate}) & 5 & Sprint 2 \\
\hline
41 & US14 & Generación de propuesta de tarea adicional por hallazgo en foso & 3 & Sprint 2 \\
\hline
42 & US15 & Notificación y aprobación de propuesta técnica con el cliente & 2 & Sprint 2 \\
\hline
43 & US28 & Registro fotográfico pericial de desmontaje y montaje de piezas en foso & 2 & Sprint 2 \\
\hline
44 & US29 & Solicitud y validación administrativa de suspensión por pieza defectuosa indispensable & 2 & Sprint 2 \\
\hline
45 & US33 & Reincorporación lógica de materiales a inventario por remoción en tarea técnica & 3 & Sprint 2 \\
\hline
46 & US34 & Disparo y desactivación de alertas automáticas de reposición por stock mínimo & 2 & Sprint 2 \\
\hline
47 & US23 & Imputación de repuestos a tareas y supervisión administrativa & 2 & Sprint 2 \\
\hline
48 & US09 & Consulta de programación semanal de turnos y márgenes de tolerancia & 2 & Sprint 2 \\
\hline
49 & US10 & Emisión y seguimiento de descargos justificatorios de tardanza & 1 & Sprint 2 \\
\hline
50 & TS17 & Marcación satelital de salida y cómputo de jornada (\texttt{POST /api/v1/hr/attendance/clock-out}) & 2 & Sprint 2 \\
\hline
51 & US36 & Liquidación económica automática en cascada de la orden de trabajo & 3 & Sprint 3 \\
\hline
52 & US37 & Emisión de comprobantes tributarios electrónicos UBL 2.1 ante SUNAT vía PSE & 5 & Sprint 3 \\
\hline
53 & TS12 & Emisión de comprobantes tributarios electrónicos UBL 2.1 (\texttt{POST /api/v1/invoicing/electronic-vouchers/issue}) & 5 & Sprint 3 \\
\hline
54 & US38 & Recaudación y amortización de pagos multi-medio en mostrador y patio & 3 & Sprint 3 \\
\hline
55 & TS13 & Registro transaccional de pagos multi-medio y amortización (\texttt{POST /api/v1/invoicing/electronic-vouchers/\{id\}/payments}) & 3 & Sprint 3 \\
\hline
56 & US39 & Transición a orden pagada, emisión de pase de salida vehicular y entrega en patio & 2 & Sprint 3 \\
\hline
57 & TS14 & Emisión y validación de pase de salida vehicular (\texttt{POST /api/v1/operations/work-orders/\{id\}/gate-passes}) & 2 & Sprint 3 \\
\hline
58 & US40 & Supervisión y reasignación de bahías de servicio en tiempo real & 3 & Sprint 3 \\
\hline
59 & TS15 & Consulta en tiempo real del estado de bahías de servicio (\texttt{GET /api/v1/operations/workshops/\{id\}/service-bays/live-status}) & 3 & Sprint 3 \\
\hline
60 & US41 & Exportación de reporte de flujo de caja en PDF para auditoría contable externa & 3 & Sprint 3 \\
\hline
61 & TS23 & Descarga documental de balance de flujo de caja en formato PDF (\texttt{GET /api/v1/invoicing/financial-reports/cash-flow/pdf}) & 2 & Sprint 3 \\
\hline
62 & US42 & Configuración de información fiscal corporativa, series SUNAT y enlace con PSE Nubefact & 3 & Sprint 3 \\
\hline
63 & TS21 & Configuración de series fiscales y credenciales PSE (\texttt{PUT /api/v1/invoicing/tax-configurations}) & 3 & Sprint 3 \\
\hline
64 & US43 & Descarga y remisión de informe pericial de salud vehicular en PDF para clientes y flotas & 3 & Sprint 3 \\
\hline
65 & TS24 & Descarga documental de informe pericial de salud vehicular en formato PDF (\texttt{GET /api/v1/iot/vehicles/\{id\}/health-reports/\{reportId\}/pdf}) & 2 & Sprint 3 \\
\hline
66 & TS22 & Generación de informe pericial predictivo desde orden de trabajo (\texttt{POST /api/v1/operations/work-orders/\{id\}/generate-diagnostic-report}) & 5 & Sprint 3 \\
\hline
67 & US19 & Almacenamiento local resiliente y sincronización diferida en fosa & 3 & Sprint 3 \\
\hline
68 & US20 & Borrado y verificación de restablecimiento de fallas en la computadora & 2 & Sprint 3 \\
\hline
69 & US04 & Cierre de sesión seguro y revocación de credenciales en el dispositivo móvil & 1 & Sprint 3 \\
\hline
70 & US05 & Restablecimiento de credenciales de acceso mediante token de verificación & 2 & Sprint 3 \\
\hline
\end{longtable}

La @tbl:sprint-velocity-summary sintetiza la distribución global del esfuerzo estimado y el balance de velocidad proyectada a lo largo de las tres iteraciones del proyecto:

| Sprint | Alcance Operativo y Hito Académico | Puntos US | Puntos TS / SP | Total SP |
|:---:|:----------|:---:|:---:|:---:|
| Sprint 1 | Despliegue de Landing Page, MVP de Patio y Servicios Core | 39 | 35 | 74 |
| Sprint 2 | Gestión Integral MRO, Descargo FIFO por Lote y Diagnóstico IA | 39 | 20 | 59 |
| Sprint 3 | Facturación Electrónica UBL 2.1 SUNAT, Cierre y Monitoreo | 33 | 25 | 58 |
| **Total** | Consolidado del Catálogo de Producto Atelier | 111 | 80 | 191 |
: Resumen Consolidado de Capacidad y Velocidad por Sprint {#tbl:sprint-velocity-summary}

*Nota.* Consolidación de esfuerzo estimado y balance de velocidad por iteración.

En la @fig:jira-product-backlog se presenta el tablero del *Product Backlog* priorizado y estimado para el ecosistema Atelier en la herramienta de gestión ágil Jira Software:

![Tablero del Product Backlog del Ecosistema Atelier en Jira Software](report/assets/product-backlog/product-backlog-atelier.png){#fig:jira-product-backlog width=100%}

*Nota.* Tablero interactivo del Product Backlog estructurado por sprints y gestionado colaborativamente en [Jira Software](https://andeva.atlassian.net/jira/software/projects/AT/boards/2/backlog). Elaboración propia (2026).


\newpage
