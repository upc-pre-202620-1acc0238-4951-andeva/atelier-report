## 2.4. Requirements Specification

En esta sección se definen los requisitos funcionales del sistema mediante historias de usuario y épicas de negocio, estructuradas bajo los principios del desarrollo ágil de software. Estas especificaciones permiten modelar las interacciones de los usuarios con la plataforma Atelier (sitio web de negocio y aplicación móvil para la gestión de talleres mecánicos), estableciendo criterios de aceptación verificables mediante escenarios en formato Gherkin.

### 2.4.1. *User Stories*

Para la especificación de requisitos del sistema, se formularon historias de usuario que describen las funcionalidades necesarias para satisfacer las operaciones de los talleres mecánicos y la captación de clientes.

Asimismo, se definieron tres niveles de prioridad para las historias de usuario:
* **Alta:** Funcionalidades críticas y esenciales para la operación del taller y la captación comercial inicial, las cuales deben ser desarrolladas en las primeras etapas.
* **Media:** Funcionalidades de soporte operativo importante, cuya ejecución complementa la gestión integral pero no bloquea el flujo básico de trabajo.
* **Baja:** Características complementarias y analíticas avanzadas que optimizan la toma de decisiones y enriquecen la experiencia del usuario.

A continuación, se presentan las historias de usuario organizadas por cada una de sus correspondientes épicas de negocio.

### Epic 1: Sitio web de negocio

A continuación, se presentan las historias de usuario pertenecientes al epic número 1, que agrupa todas las funcionalidades relacionadas con sitio web de negocio de Atelier.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.5cm} | >{\centering\arraybackslash}p{5.0cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-7.5cm-6\tabcolsep-4\arrayrulewidth\relax} |}
\caption{Épica EP01: Sitio web de negocio} \label{tbl:ep01} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endfirsthead
\multicolumn{3}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endhead
\hline \multicolumn{3}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
EP01 & Visitante del sitio web & Alta \\
\hline
\thspanfirst{3}{Title} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Sitio web de negocio} \\
\hline
\thspanfirst{3}{Description} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} visitante del sitio web de negocio,\newline \textbf{quiero} conocer la propuesta de valor, características, calculadora de rentabilidad y planes de suscripción de Atelier,\newline \textbf{para} evaluar la adopción de la plataforma en mi taller automotriz y solicitar una demostración comercial.} \\
\hline
\end{longtable}

*Nota.* Especificación de la épica EP01 elaborada para el proyecto Atelier según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US01 - Visualización de la propuesta de valor y características de la plataforma} \label{tbl:us01} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US01 & Visitante del sitio web & Alta & EP01 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Visualización de la propuesta de valor y características de la plataforma} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} visitante del sitio web de negocio,\newline \textbf{quiero} visualizar las características clave, beneficios operativos y arquitectura de la plataforma Atelier,\newline \textbf{para} comprender cómo la solución digitaliza y optimiza los flujos de trabajo en mi taller automotriz.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Carga exitosa de la sección principal}\newline
\textbf{Dado que} el visitante accede a la dirección pública del sitio web desde un navegador,\newline
\textbf{cuando} se completa la carga del documento inicial,\newline
\textbf{entonces} el sistema presenta el encabezado principal con la propuesta de valor, los pilares de inspección digital y el acceso directo a planes comerciales,\newline
\textbf{y} el tiempo de respuesta se mantiene por debajo de dos segundos.\vspace{4pt}\newline
\textbf{Escenario 2: Navegación adaptable en dispositivos móviles}\newline
\textbf{Dado que} el visitante consulta el sitio web desde un dispositivo de dimensiones compactas,\newline
\textbf{cuando} explora las secciones del sitio web,\newline
\textbf{entonces} el sistema adapta la presentación del contenido manteniendo la totalidad de secciones legibles y accesibles,\newline
\textbf{y} los elementos interactivos conservan un espaciado adecuado.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US01 según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US02 - Simulación de retorno de inversión mediante calculadora de rentabilidad} \label{tbl:us02} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US02 & Visitante del sitio web & Media & EP01 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Simulación de retorno de inversión mediante calculadora de rentabilidad} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} visitante del sitio web de negocio,\newline \textbf{quiero} ingresar la cantidad de bahías y vehículos atendidos en una calculadora interactiva,\newline \textbf{para} proyectar el ahorro mensual en horas hombre y la reducción de pérdidas económicas por repuestos mal registrados.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Cálculo dinámico de ahorro proyectado}\newline
\textbf{Dado que} el visitante define un volumen operativo de 15 vehículos diarios y 4 bahías de trabajo,\newline
\textbf{cuando} solicita calcular la estimación,\newline
\textbf{entonces} el sistema calcula y presenta de forma inmediata el ahorro mensual estimado en horas y el incremento porcentual de facturación,\newline
\textbf{y} las cifras proyectadas se actualizan de forma inmediata.\vspace{4pt}\newline
\textbf{Escenario 2: Restablecimiento de valores por defecto}\newline
\textbf{Dado que} el usuario ha modificado los parámetros de la simulación,\newline
\textbf{cuando} solicita reiniciar los valores de estimación,\newline
\textbf{entonces} el sistema restaura los valores canónicos predefinidos de la industria automotriz,\newline
\textbf{y} las cifras de rentabilidad se recalculan instantáneamente.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US02 según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US03 - Comparación de planes comerciales y esquema de suscripción SaaS} \label{tbl:us03} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US03 & Visitante del sitio web & Alta & EP01 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Comparación de planes comerciales y esquema de suscripción SaaS} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} visitante del sitio web de negocio,\newline \textbf{quiero} comparar los niveles de suscripción Básico, Pro y Taller Líder con su matriz de funcionalidades,\newline \textbf{para} seleccionar el plan comercial que mejor responda al tamaño y presupuesto de mi empresa.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Consulta de matriz comparativa de planes}\newline
\textbf{Dado que} el visitante consulta la oferta comercial de la plataforma,\newline
\textbf{cuando} evalúa los diferentes planes de suscripción,\newline
\textbf{entonces} el sistema presenta los costos mensuales expresados en moneda nacional y dólares, el límite de órdenes activas y la lista detallada de módulos habilitados,\newline
\textbf{y} el plan recomendado se resalta visualmente.\vspace{4pt}\newline
\textbf{Escenario 2: Selección de modalidad de facturación anual}\newline
\textbf{Dado que} el visitante elige la modalidad de facturación con periodicidad anual,\newline
\textbf{cuando} el sistema procesa el cambio de modalidad,\newline
\textbf{entonces} los precios mostrados reflejan un descuento promocional del 15\% sobre la tarifa base,\newline
\textbf{y} se indica claramente el monto total facturado por año.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US03 según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US04 - Envío de formulario de contacto y solicitud de demostración comercial} \label{tbl:us04} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US04 & Visitante del sitio web & Alta & EP01 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Envío de formulario de contacto y solicitud de demostración comercial} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} visitante del sitio web de negocio,\newline \textbf{quiero} registrar mis datos de contacto, RUC y nombre de taller en un formulario digital,\newline \textbf{para} que un asesor comercial se comunique y coordine una sesión guiada de demostración del sistema.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Envío exitoso de solicitud comercial}\newline
\textbf{Dado que} el visitante completa los campos obligatorios de nombre, correo electrónico corporativo, teléfono y RUC válido de 11 dígitos,\newline
\textbf{cuando} envía el formulario de contacto,\newline
\textbf{entonces} el sistema valida la consistencia de los datos, almacena el registro del prospecto y presenta un mensaje de confirmación exitosa,\newline
\textbf{y} despacha una notificación automática al correo ingresado.\vspace{4pt}\newline
\textbf{Escenario 2: Validación de datos incompletos o inválidos}\newline
\textbf{Dado que} el visitante omite ingresar el número telefónico o registra un formato de correo electrónico inválido,\newline
\textbf{cuando} intenta despachar el formulario,\newline
\textbf{entonces} el sistema bloquea el envío, resalta los campos con error mediante indicadores accesibles,\newline
\textbf{y} presenta el mensaje instructivo específico para cada campo requerido.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US04 según la norma APA 7.

### Epic 2: Autenticación y control de acceso

A continuación, se presentan las historias de usuario pertenecientes al epic número 2, que agrupa todas las funcionalidades relacionadas con autenticación y control de acceso de Atelier.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.5cm} | >{\centering\arraybackslash}p{5.0cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-7.5cm-6\tabcolsep-4\arrayrulewidth\relax} |}
\caption{Épica EP02: Autenticación y control de acceso} \label{tbl:ep02} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endfirsthead
\multicolumn{3}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endhead
\hline \multicolumn{3}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
EP02 & Usuario del sistema & Alta \\
\hline
\thspanfirst{3}{Title} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Autenticación y control de acceso} \\
\hline
\thspanfirst{3}{Description} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} usuario del sistema (dueño o mecánico),\newline \textbf{quiero} iniciar sesión con mis credenciales corporativas, cerrar sesión de forma segura y recuperar mi clave,\newline \textbf{para} acceder a las funcionalidades del taller con protección de datos.} \\
\hline
\end{longtable}

*Nota.* Especificación de la épica EP02 elaborada para el proyecto Atelier según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US05 - Inicio de sesión seguro con credenciales corporativas y control multi-inquilino} \label{tbl:us05} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US05 & Usuario del sistema & Alta & EP02 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Inicio de sesión seguro con credenciales corporativas y control multi-inquilino} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} usuario del sistema (dueño o mecánico),\newline \textbf{quiero} autenticarme mediante mi correo institucional y contraseña encriptada,\newline \textbf{para} ingresar al espacio de trabajo exclusivo de mi taller con los permisos correspondientes a mi rol.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Autenticación exitosa y carga de espacio de trabajo}\newline
\textbf{Dado que} el usuario ingresa su correo electrónico corporativo y contraseña correcta,\newline
\textbf{cuando} solicita el inicio de sesión,\newline
\textbf{entonces} el sistema valida las credenciales, genera un token JWT firmado, identifica el identificador de inquilino del taller y despliega la vista principal asociada a su perfil,\newline
\textbf{y} mantiene la sesión activa de forma segura.\vspace{4pt}\newline
\textbf{Escenario 2: Rechazo por credenciales incorrectas}\newline
\textbf{Dado que} el usuario ingresa una contraseña que no coincide con los registros,\newline
\textbf{cuando} intenta acceder al sistema,\newline
\textbf{entonces} el sistema deniega la autenticación, incrementa el contador de intentos fallidos,\newline
\textbf{y} presenta un mensaje de alerta neutral sin revelar si el error corresponde al correo o a la clave.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US05 según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US06 - Cierre de sesión seguro y revocación de credenciales activas} \label{tbl:us06} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US06 & Usuario del sistema & Media & EP02 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Cierre de sesión seguro y revocación de credenciales activas} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} usuario del sistema,\newline \textbf{quiero} cerrar mi sesión de forma explícita desde el menú de usuario,\newline \textbf{para} revocar las claves temporales y asegurar que ningún tercero utilice la aplicación móvil en el dispositivo compartido.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Cierre voluntario de sesión}\newline
\textbf{Dado que} el usuario mantiene una sesión activa en el dispositivo móvil,\newline
\textbf{cuando} selecciona la opción de finalizar sesión,\newline
\textbf{entonces} el sistema invalida el token JWT local, purga las credenciales en caché y redirige a la vista de autenticación,\newline
\textbf{y} garantiza que los datos sensibles no queden expuestos en memoria.\vspace{4pt}\newline
\textbf{Escenario 2: Cierre forzado por expiración temporal del token}\newline
\textbf{Dado que} el usuario intenta ejecutar una operación habiendo superado el tiempo de validez del token de acceso,\newline
\textbf{cuando} el servicio intercepta la petición,\newline
\textbf{entonces} el sistema detecta la caducidad del token, revoca el acceso,\newline
\textbf{y} notifica al usuario la necesidad de volver a ingresar sus credenciales para continuar.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US06 según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US07 - Recuperación de contraseña mediante enlace seguro por correo electrónico} \label{tbl:us07} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US07 & Usuario del sistema & Media & EP02 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Recuperación de contraseña mediante enlace seguro por correo electrónico} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} usuario del sistema,\newline \textbf{quiero} solicitar la restauración de mi contraseña indicando mi correo electrónico corporativo,\newline \textbf{para} recibir un enlace temporal seguro y restablecer mi clave de acceso en caso de extravío u olvido.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Solicitud de restablecimiento para cuenta existente}\newline
\textbf{Dado que} el usuario solicita el restablecimiento de su clave e ingresa un correo registrado en el sistema,\newline
\textbf{cuando} confirma la solicitud,\newline
\textbf{entonces} el sistema genera un token de un solo uso con vigencia de 15 minutos, lo almacena de forma segura y despacha un correo con el enlace de recuperación,\newline
\textbf{y} informa al usuario sobre el envío de las instrucciones.\vspace{4pt}\newline
\textbf{Escenario 2: Enlace expirado o previamente consumido}\newline
\textbf{Dado que} el usuario utiliza un enlace de recuperación cuya vigencia superó los 15 minutos o que ya fue utilizado,\newline
\textbf{cuando} intenta ingresar la nueva contraseña,\newline
\textbf{entonces} el sistema deniega la modificación, notifica la invalidez del enlace,\newline
\textbf{y} orienta al usuario a generar una nueva solicitud de recuperación.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US07 según la norma APA 7.

### Epic 3: Recepción pericial de vehículos

A continuación, se presentan las historias de usuario pertenecientes al epic número 3, que agrupa todas las funcionalidades relacionadas con recepción pericial de vehículos de Atelier.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.5cm} | >{\centering\arraybackslash}p{5.0cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-7.5cm-6\tabcolsep-4\arrayrulewidth\relax} |}
\caption{Épica EP03: Recepción pericial de vehículos} \label{tbl:ep03} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endfirsthead
\multicolumn{3}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endhead
\hline \multicolumn{3}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
EP03 & Personal de taller & Alta \\
\hline
\thspanfirst{3}{Title} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Recepción pericial de vehículos} \\
\hline
\thspanfirst{3}{Description} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} personal de taller (mecánico o dueño),\newline \textbf{quiero} registrar la placa, odómetro, nivel de combustible, inventario de pertenencias y mapear gráficamente daños sobre una silueta 2D con fotografías,\newline \textbf{para} blindar al taller con un acta pericial inalterable al momento del ingreso.} \\
\hline
\end{longtable}

*Nota.* Especificación de la épica EP03 elaborada para el proyecto Atelier según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US08 - Registro inicial de vehículo con odómetro, combustible y geocerca perimétrica} \label{tbl:us08} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US08 & Personal de taller & Alta & EP03 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Registro inicial de vehículo con odómetro, combustible y geocerca perimétrica} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} personal de taller (mecánico o dueño),\newline \textbf{quiero} registrar la placa del vehículo, kilometraje actual, nivel de combustible y validar la ubicación GPS,\newline \textbf{para} asentar el acta pericial de ingreso y confirmar que el vehículo se encuentra físicamente dentro del taller.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Registro pericial dentro de la geocerca autorizada}\newline
\textbf{Dado que} el personal de taller ingresa una placa vehicular válida, kilometraje de 45200 km y nivel de combustible en tres cuartos de tanque, mientras el dispositivo móvil adquiere ubicación GPS con precisión horizontal inferior a 15 metros,\newline
\textbf{cuando} confirma el registro de ingreso vehicular,\newline
\textbf{entonces} el sistema verifica que las coordenadas se ubiquen a una distancia menor o igual a 50 metros del perímetro del taller mediante cálculo local de Haversine,\newline
\textbf{y} genera el expediente de recepción en estado Registrado vinculando la marca temporal exacta.\vspace{4pt}\newline
\textbf{Escenario 2: Rechazo o advertencia por ubicación fuera del taller}\newline
\textbf{Dado que} el operario intenta registrar el ingreso mientras las coordenadas GPS indican una separación superior a 120 metros de la sede registrada,\newline
\textbf{cuando} intenta guardar el registro inicial,\newline
\textbf{entonces} el sistema bloquea la confirmación pericial,\newline
\textbf{y} informa que el vehículo debe encontrarse físicamente en las instalaciones del taller para aperturar el expediente de ingreso.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US08 según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US09 - Checklist de inventario vehicular y objetos de valor en custodia} \label{tbl:us09} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US09 & Personal de taller & Media & EP03 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Checklist de inventario vehicular y objetos de valor en custodia} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} personal de taller,\newline \textbf{quiero} completar una lista de verificación de accesorios de seguridad, estado de cristales y objetos personales,\newline \textbf{para} deslindar responsabilidades del taller frente a reclamos por pérdidas o deterioros preexistentes.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Registro completo de inventario de accesorios}\newline
\textbf{Dado que} el personal de taller evalúa la presencia de llanta de repuesto, gata hidráulica, llave de ruedas, triángulo de seguridad y radio de fábrica,\newline
\textbf{cuando} marca los estados correspondientes e ingresa una nota sobre la presencia de herramientas adicionales en la maletera,\newline
\textbf{entonces} el sistema consolida la lista de verificación, fija la fecha y hora de constatación,\newline
\textbf{y} vincula el inventario al expediente de ingreso vehicular.\vspace{4pt}\newline
\textbf{Escenario 2: Observación de accesorio ausente o deteriorado}\newline
\textbf{Dado que} el vehículo no presenta la gata hidráulica y el espejo retrovisor derecho muestra trizaduras,\newline
\textbf{cuando} el personal registra el estado como No Disponible y Dañado respectivamente,\newline
\textbf{entonces} el sistema resalta los elementos observados en el acta de recepción,\newline
\textbf{y} exige la confirmación explícita del operario para incluir la observación en el reporte final.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US09 según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US10 - Mapeo interactivo de abolladuras y rayones sobre silueta vehicular 2D} \label{tbl:us10} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US10 & Personal de taller & Alta & EP03 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Mapeo interactivo de abolladuras y rayones sobre silueta vehicular 2D} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} personal de taller,\newline \textbf{quiero} marcar puntos de daño sobre una silueta gráfica interactiva que represente las vistas frontal, posterior y laterales del auto,\newline \textbf{para} documentar con precisión visual la ubicación y severidad de cada avería de carrocería previa al servicio.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Marcado de punto de daño con severidad}\newline
\textbf{Dado que} el personal de taller inspecciona el parachoques delantero y constata un raspón de pintura,\newline
\textbf{cuando} señala la ubicación del daño en la región frontal de la silueta vehicular y clasifica la severidad como Rayón Leve,\newline
\textbf{entonces} el sistema posiciona un indicador gráfico numerado sobre la imagen,\newline
\textbf{y} habilita la opción inmediata de adjuntar una fotografía de respaldo pericial.\vspace{4pt}\newline
\textbf{Escenario 2: Eliminación o ajuste de un marcador erróneo}\newline
\textbf{Dado que} se ha registrado un punto de daño en una posición equivocada de la silueta,\newline
\textbf{cuando} el operario selecciona el marcador registrado y solicita su remoción,\newline
\textbf{entonces} el sistema retira el punto pericial de la silueta,\newline
\textbf{y} reordena el correlativo numérico de los daños restantes sin alterar las observaciones confirmadas.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US10 según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US11 - Captura y vinculación de fotografías de daños con CameraX y modo desconectado} \label{tbl:us11} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US11 & Personal de taller & Media & EP03 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Captura y vinculación de fotografías de daños con CameraX y modo desconectado} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} personal de taller,\newline \textbf{quiero} capturar fotografías de los daños exteriores mediante la cámara del dispositivo móvil gestionada por CameraX,\newline \textbf{para} adjuntar evidencia visual inalterable al expediente pericial incluso cuando no haya señal de internet en la fosa.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Captura fotográfica con compresión automática}\newline
\textbf{Dado que} el personal de taller activa el módulo de captura pericial fotográfica vinculado al marcador de daño,\newline
\textbf{cuando} captura la imagen fotográfica del daño,\newline
\textbf{entonces} el sistema procesa la captura en segundo plano reduciendo la resolución a Full HD (1920x1080) JPEG con 80\% de calidad sin pérdida de nitidez pericial,\newline
\textbf{y} asocia la imagen al marcador de daño correspondiente.\vspace{4pt}\newline
\textbf{Escenario 2: Captura en zona de fosa sin conexión a internet}\newline
\textbf{Dado que} el dispositivo móvil se encuentra operando en un sótano o fosa sin cobertura de datos móviles ni Wi-Fi,\newline
\textbf{cuando} el personal captura tres fotografías consecutivas de la parte inferior de la carrocería,\newline
\textbf{entonces} el sistema almacena las imágenes cifradas en el almacenamiento local SQLite del dispositivo,\newline
\textbf{y} marca las entidades fotográficas con estado de sincronización pendiente para su posterior despacho en segundo plano.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US11 según la norma APA 7.

### Epic 4: Diagnóstico vehicular y monitoreo de fallas

A continuación, se presentan las historias de usuario pertenecientes al epic número 4, que agrupa todas las funcionalidades relacionadas con diagnóstico vehicular y monitoreo de fallas de Atelier.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.5cm} | >{\centering\arraybackslash}p{5.0cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-7.5cm-6\tabcolsep-4\arrayrulewidth\relax} |}
\caption{Épica EP04: Diagnóstico vehicular y monitoreo de fallas} \label{tbl:ep04} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endfirsthead
\multicolumn{3}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endhead
\hline \multicolumn{3}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
EP04 & Mecánico técnico & Alta \\
\hline
\thspanfirst{3}{Title} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Diagnóstico vehicular y monitoreo de fallas} \\
\hline
\thspanfirst{3}{Description} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} mecánico técnico de patio,\newline \textbf{quiero} ejecutar un escaneo computarizado simulado del motor, visualizar códigos de falla DTC estandarizados y monitorear telemetría en tiempo real,\newline \textbf{para} determinar con precisión técnica las averías del vehículo.} \\
\hline
\end{longtable}

*Nota.* Especificación de la épica EP04 elaborada para el proyecto Atelier según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US12 - Escaneo computarizado simulado y visualización de códigos DTC} \label{tbl:us12} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US12 & Mecánico técnico & Alta & EP04 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Escaneo computarizado simulado y visualización de códigos DTC} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} mecánico técnico de patio,\newline \textbf{quiero} ejecutar un escaneo computarizado que inyecte un perfil de diagnóstico estandarizado,\newline \textbf{para} identificar de forma inmediata los códigos de falla OBD-II (DTCs) activos e históricos en los módulos del vehículo.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Detección de fallas motrices simuladas}\newline
\textbf{Dado que} el mecánico técnico inicia la secuencia de escaneo computarizado sobre el vehículo asignado,\newline
\textbf{cuando} el sistema procesa la rutina de simulación de diagnóstico motriz,\newline
\textbf{entonces} el sistema despliega los códigos activos detectados (como P0300 Fallo de encendido aleatorio y P0420 Baja eficiencia de catalizador), la gravedad del fallo y la descripción técnica de la avería,\newline
\textbf{y} asocia los hallazgos a la orden de trabajo.\vspace{4pt}\newline
\textbf{Escenario 2: Vehículo sin códigos de anomalía registrados}\newline
\textbf{Dado que} el mecánico ejecuta el escaneo sobre un perfil de mantenimiento preventivo sin averías,\newline
\textbf{cuando} finaliza la rutina de lectura diagnóstica,\newline
\textbf{entonces} el sistema informa que todos los subsistemas de motor, transmisión y frenos operan dentro de parámetros nominales,\newline
\textbf{y} registra el estado de diagnóstico como Sin Códigos Activos.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US12 según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US13 - Consulta de ficha técnica de resolución para códigos de falla} \label{tbl:us13} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US13 & Mecánico técnico & Baja & EP04 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Consulta de ficha técnica de resolución para códigos de falla} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} mecánico técnico,\newline \textbf{quiero} seleccionar un código DTC detectado y consultar sus causas probables y pruebas recomendadas,\newline \textbf{para} guiar el procedimiento de reparación de forma estandarizada y reducir el tiempo de investigación.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Despliegue de guía de diagnóstico para código P0300}\newline
\textbf{Dado que} el listado de diagnóstico muestra el código P0300 detectado en el motor,\newline
\textbf{cuando} el mecánico consulta la ficha técnica del código de anomalía detectado,\newline
\textbf{entonces} el sistema despliega la información con causas probables (bujías desgastadas, bobina defectuosa, baja presión de combustible) y la secuencia recomendada de comprobaciones mecánicas,\newline
\textbf{y} facilita la derivación directa a cotización de repuestos.\vspace{4pt}\newline
\textbf{Escenario 2: Consulta sin conectividad a internet}\newline
\textbf{Dado que} el mecánico consulta la guía técnica en fosa operando en modo desconectado,\newline
\textbf{cuando} solicita el detalle de un código estándar SAE J2012,\newline
\textbf{entonces} el sistema recupera la ficha desde la base de datos SQLite local preinstalada,\newline
\textbf{y} despliega la información completa sin experimentar demoras de red.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US13 según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US14 - Monitoreo de parámetros motrices en tiempo real mediante gráficas dinámicas} \label{tbl:us14} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US14 & Mecánico técnico & Media & EP04 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Monitoreo de parámetros motrices en tiempo real mediante gráficas dinámicas} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} mecánico técnico,\newline \textbf{quiero} visualizar gráficas temporales de RPM, temperatura de refrigerante y voltaje de batería,\newline \textbf{para} evaluar el comportamiento dinámico del motor en ralentí y marcha antes de emitir el dictamen de reparación.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Renderizado dinámico de curvas de telemetría}\newline
\textbf{Dado que} el mecánico activa la visualización en vivo de sensores con el motor en prueba,\newline
\textbf{cuando} el simulador emite tramas temporales continuas a intervalos de 500 milisegundos,\newline
\textbf{entonces} el sistema actualiza en tiempo real las gráficas continuas de revoluciones por minuto y temperatura térmica,\newline
\textbf{y} identifica visualmente con estado de precaución cualquier fluctuación que supere los umbrales de seguridad predefinidos.\vspace{4pt}\newline
\textbf{Escenario 2: Pausa y congelamiento de tramas para análisis}\newline
\textbf{Dado que} se detecta un pico anómalo de temperatura durante la aceleración simulada,\newline
\textbf{cuando} el mecánico congela la reproducción de la señal gráfica,\newline
\textbf{entonces} el sistema congela los valores instantáneos para su posterior análisis,\newline
\textbf{y} permite exportar la captura de métricas como anexo técnico de la orden de trabajo.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US14 según la norma APA 7.

### Epic 5: Gestión y seguimiento de órdenes de trabajo

A continuación, se presentan las historias de usuario pertenecientes al epic número 5, que agrupa todas las funcionalidades relacionadas con gestión y seguimiento de órdenes de trabajo de Atelier.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.5cm} | >{\centering\arraybackslash}p{5.0cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-7.5cm-6\tabcolsep-4\arrayrulewidth\relax} |}
\caption{Épica EP05: Gestión y seguimiento de órdenes de trabajo} \label{tbl:ep05} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endfirsthead
\multicolumn{3}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endhead
\hline \multicolumn{3}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
EP05 & Personal de taller & Alta \\
\hline
\thspanfirst{3}{Title} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Gestión y seguimiento de órdenes de trabajo} \\
\hline
\thspanfirst{3}{Description} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} personal de taller (mecánico o dueño),\newline \textbf{quiero} aperturar órdenes de trabajo, asignar mecánicos por tarea, registrar tiempos de labor y actualizar estados en un tablero Kanban,\newline \textbf{para} mantener trazabilidad operativa y control de calidad antes de la entrega.} \\
\hline
\end{longtable}

*Nota.* Especificación de la épica EP05 elaborada para el proyecto Atelier según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US15 - Apertura formal y asignación correlativa de orden de trabajo} \label{tbl:us15} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US15 & Personal de taller & Alta & EP05 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Apertura formal y asignación correlativa de orden de trabajo} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} personal de taller (dueño o mecánico),\newline \textbf{quiero} crear formalmente una orden de trabajo asociada a la placa del vehículo recibido,\newline \textbf{para} iniciar el expediente de seguimiento operativo y fijar el estado inicial en el flujo del taller.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Creación de orden tras recepción pericial}\newline
\textbf{Dado que} un vehículo cuenta con el acta pericial de ingreso y checklist inicial completados,\newline
\textbf{cuando} el usuario confirma la apertura de la orden de trabajo para el servicio solicitado,\newline
\textbf{entonces} el sistema genera un código correlativo único (ejemplo OT-2026-0042), fija el estado en Registrado y transiciona la orden a En Diagnóstico,\newline
\textbf{y} vincula al cliente y vehículo en el expediente operativo.\vspace{4pt}\newline
\textbf{Escenario 2: Intento de apertura sin acta pericial previa}\newline
\textbf{Dado que} el usuario intenta aperturar una orden para un vehículo que no ha completado el checklist pericial de ingreso,\newline
\textbf{cuando} solicita generar la orden de trabajo,\newline
\textbf{entonces} el sistema bloquea la creación,\newline
\textbf{y} notifica que es mandatorio registrar el estado físico inicial y kilometraje del vehículo antes de habilitar labores de patio.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US15 según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US16 - Asignación de tareas operativas y mecánico responsable por especialidad} \label{tbl:us16} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US16 & Dueño de taller & Alta & EP05 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Asignación de tareas operativas y mecánico responsable por especialidad} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} dueño de taller,\newline \textbf{quiero} desglosar las labores mecánicas en tareas específicas y asignar a cada una un mecánico responsable,\newline \textbf{para} balancear la carga de trabajo en patio y definir responsables directos por cada actividad.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Asignación individual de tarea mecánica}\newline
\textbf{Dado que} la orden de trabajo autorizada incluye la tarea de cambio de pastillas de freno y purgado de líquido,\newline
\textbf{cuando} el administrador selecciona al mecánico técnico especialista en frenos y define un tiempo estimado de 90 minutos,\newline
\textbf{entonces} el sistema registra la asignación en la base de datos,\newline
\textbf{y} actualiza la lista de tareas pendientes en el dispositivo móvil del operario designado.\vspace{4pt}\newline
\textbf{Escenario 2: Notificación al mecánico en dispositivo móvil}\newline
\textbf{Dado que} se asigna una nueva tarea correctiva a un mecánico con sesión activa,\newline
\textbf{cuando} el sistema despacha la actualización operativa,\newline
\textbf{entonces} la aplicación móvil del mecánico actualiza su bandeja de tareas asignadas,\newline
\textbf{y} muestra la placa, bahía designada y hora límite sugerida de culminación.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US16 según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US17 - Monitoreo del ciclo de vida de órdenes mediante tablero visual Kanban} \label{tbl:us17} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US17 & Personal de taller & Alta & EP05 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Monitoreo del ciclo de vida de órdenes mediante tablero visual Kanban} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} personal de taller (dueño o mecánico),\newline \textbf{quiero} visualizar las órdenes de trabajo distribuidas en columnas de estado operativo,\newline \textbf{para} identificar cuellos de botella en patio y supervisar el avance de cada vehículo en tiempo real.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Transición de orden entre estados operativos}\newline
\textbf{Dado que} una orden de trabajo culmina la etapa de diagnóstico y cuenta con presupuesto aprobado por el cliente,\newline
\textbf{cuando} el personal de taller transiciona la orden de trabajo desde el estado Cotizado hacia En Reparación,\newline
\textbf{entonces} el sistema valida que se cumplan las precondiciones de autorización,\newline
\textbf{y} actualiza el estado de la orden en todas las instancias concurrentes.\vspace{4pt}\newline
\textbf{Escenario 2: Restricción de salto de estado ilegal}\newline
\textbf{Dado que} un usuario intenta transicionar una orden desde estado Registrado directamente a Control de Calidad sin pasar por diagnóstico ni reparación,\newline
\textbf{cuando} ejecuta la acción en el tablero,\newline
\textbf{entonces} el sistema rechaza la transición de estado,\newline
\textbf{y} informa las precondiciones operativas pendientes que deben cumplirse secuencialmente.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US17 según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US18 - Control de tiempos de labor efectiva y registro de finalización con control de calidad} \label{tbl:us18} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US18 & Mecánico técnico & Alta & EP05 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Control de tiempos de labor efectiva y registro de finalización con control de calidad} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} mecánico técnico,\newline \textbf{quiero} marcar el inicio, pausa y finalización de cada tarea asignada en mi aplicación móvil,\newline \textbf{para} registrar las horas efectivas invertidas y remitir el vehículo a inspección de control de calidad.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Marcado de tiempo de trabajo efectivo}\newline
\textbf{Dado que} el mecánico se dispone a iniciar el desmontaje del sistema de frenos,\newline
\textbf{cuando} activa el cronómetro de inicio de labor en la tarea asignada,\newline
\textbf{entonces} el sistema registra la marca de tiempo de inicio exacta,\newline
\textbf{y} fija el estado de la tarea en En Ejecución contabilizando el tiempo en segundo plano.\vspace{4pt}\newline
\textbf{Escenario 2: Finalización de tareas y pase a control de calidad}\newline
\textbf{Dado que} el operario culmina la última tarea mecánica asignada en la orden,\newline
\textbf{cuando} registra el cierre de la actividad con una nota de conformidad,\newline
\textbf{entonces} el sistema calcula el tiempo total de mano de obra efectiva consumida,\newline
\textbf{y} transiciona la orden de trabajo a la etapa de Control de Calidad notificando al jefe de taller o dueño.\vspace{4pt}\newline
\textbf{Escenario 3: No conformidad y reproceso en control de calidad}\newline
\textbf{Dado que} el vehículo se encuentra en Control de Calidad pero el jefe de taller o dueño detecta un chirrido residual durante la prueba de frenado,\newline
\textbf{cuando} registra el dictamen de inspección como Rechazado con la nota técnica de desajuste de mordaza,\newline
\textbf{entonces} el sistema revierte el estado de la orden a En Reparación,\newline
\textbf{y} reabre la tarea específica y despacha una alerta prioritaria al dispositivo móvil del mecánico responsable.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US18 según la norma APA 7.

### Epic 6: Cotización y aprobación de presupuestos

A continuación, se presentan las historias de usuario pertenecientes al epic número 6, que agrupa todas las funcionalidades relacionadas con cotización y aprobación de presupuestos de Atelier.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.5cm} | >{\centering\arraybackslash}p{5.0cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-7.5cm-6\tabcolsep-4\arrayrulewidth\relax} |}
\caption{Épica EP06: Cotización y aprobación de presupuestos} \label{tbl:ep06} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endfirsthead
\multicolumn{3}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endhead
\hline \multicolumn{3}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
EP06 & Dueño de taller & Alta \\
\hline
\thspanfirst{3}{Title} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Cotización y aprobación de presupuestos} \\
\hline
\thspanfirst{3}{Description} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} dueño de taller,\newline \textbf{quiero} estructurar cotizaciones desglosadas con repuestos y mano de obra, gestionar aprobaciones y adendar averías ocultas,\newline \textbf{para} transparentar costos y asegurar la autorización formal de los trabajos.} \\
\hline
\end{longtable}

*Nota.* Especificación de la épica EP06 elaborada para el proyecto Atelier según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US19 - Elaboración de presupuesto con desglose de repuestos, mano de obra y margen comercial} \label{tbl:us19} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US19 & Dueño de taller & Alta & EP06 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Elaboración de presupuesto con desglose de repuestos, mano de obra y margen comercial} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} dueño de taller,\newline \textbf{quiero} estructurar una cotización detallando repuestos necesarios, margen comercial, horas de mano de obra e impuestos,\newline \textbf{para} presentar al cliente una propuesta económica formal, transparente y rentable.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Cálculo automático de subtotales, margen e IGV}\newline
\textbf{Dado que} el administrador agrega dos amortiguadores delanteros con costo unitario de compra de S/ 180, aplica un margen comercial del 25\% e incorpora 3 horas de mano de obra a S/ 60 por hora,\newline
\textbf{cuando} solicita el cálculo del presupuesto,\newline
\textbf{entonces} el sistema calcula el costo total de repuestos con margen (S/ 450), mano de obra (S/ 180), subtotal gravado (S/ 630) y el 18\% del Impuesto General a las Ventas (S/ 113.40),\newline
\textbf{y} presenta el importe total de la cotización en S/ 743.40.\vspace{4pt}\newline
\textbf{Escenario 2: Alerta por repuesto sin existencias en almacén}\newline
\textbf{Dado que} el administrador intenta cotizar un kit de distribución cuya existencia en almacén figura en cero unidades,\newline
\textbf{cuando} añade la partida a la cotización,\newline
\textbf{entonces} el sistema marca la línea con una advertencia de compra contra pedido a proveedor local,\newline
\textbf{y} permite conservar la partida en el presupuesto indicando plazo estimado de suministro.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US19 según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US20 - Gestión de aprobación total, parcial o desestimiento de cotización por el cliente} \label{tbl:us20} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US20 & Dueño de taller & Alta & EP06 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Gestión de aprobación total, parcial o desestimiento de cotización por el cliente} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} dueño de taller,\newline \textbf{quiero} registrar la decisión del cliente sobre el presupuesto presentado, permitiendo aprobaciones parciales de partidas urgentes,\newline \textbf{para} autorizar los trabajos contratados o liquidar únicamente los costos periciales en caso de desistimiento.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Aprobación total de la propuesta}\newline
\textbf{Dado que} el cliente aprueba la totalidad de las partidas cotizadas mediante firma presencial o confirmación digital,\newline
\textbf{cuando} el administrador registra la aprobación completa,\newline
\textbf{entonces} el sistema fija el estado de la orden en Autorizado,\newline
\textbf{y} libera las tareas mecánicas para su ejecución en patio.\vspace{4pt}\newline
\textbf{Escenario 2: Desestimiento del servicio y cobro de diagnóstico pericial}\newline
\textbf{Dado que} el cliente desiste de realizar las reparaciones mayores presupuestadas,\newline
\textbf{cuando} el administrador selecciona la opción de Desestimado por Cliente,\newline
\textbf{entonces} el sistema cancela las tareas mecánicas presupuestadas, genera la cuenta por cobrar únicamente por concepto de inspección pericial y diagnóstico escaneado,\newline
\textbf{y} prepara el pase de salida vehicular.\vspace{4pt}\newline
\textbf{Escenario 3: Aprobación parcial de partidas prioritarias}\newline
\textbf{Dado que} el cliente solicita realizar de inmediato el cambio de frenos pero aplazar el cambio de amortiguadores para la siguiente quincena por restricciones de liquidez,\newline
\textbf{cuando} el administrador excluye las partidas no autorizadas y confirma la aprobación parcial,\newline
\textbf{entonces} el sistema recalcula los montos económicos de la orden, transiciona el estado a Autorizado Parcial liberando solo las tareas aprobadas en bahía,\newline
\textbf{y} archiva las partidas postergadas como recomendaciones técnicas pendientes para futuros servicios.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US20 según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US21 - Reporte de averías ocultas imprevistas con adenda y deslinde de responsabilidad} \label{tbl:us21} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US21 & Personal de taller & Media & EP06 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Reporte de averías ocultas imprevistas con adenda y deslinde de responsabilidad} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} personal de taller (mecánico o dueño),\newline \textbf{quiero} reportar averías ocultas descubiertas durante el desmontaje y generar una adenda presupuestal con acta de deslinde si el cliente la rechaza,\newline \textbf{para} formalizar imprevistos mecánicos y proteger legalmente al taller.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Detección y adición de avería imprevista}\newline
\textbf{Dado que} el mecánico desmonta el tambor de frenos y descubre un cilindro de rueda con fuga severa de líquido que no era visible en la recepción inicial,\newline
\textbf{cuando} registra el hallazgo adjuntando fotografía de respaldo y justificación técnica,\newline
\textbf{entonces} el sistema congela temporalmente la tarea afectada, genera un anexo de cotización adicional,\newline
\textbf{y} notifica al administrador para gestionar la autorización del cliente.\vspace{4pt}\newline
\textbf{Escenario 2: Aprobación de la adenda por el cliente}\newline
\textbf{Dado que} el cliente autoriza el presupuesto complementario para la reparación de la avería oculta,\newline
\textbf{cuando} el administrador confirma la aceptación de la adenda en el sistema,\newline
\textbf{entonces} el sistema incorpora el nuevo repuesto y mano de obra a la orden principal,\newline
\textbf{y} reanuda la ejecución operativa en la bahía de trabajo.\vspace{4pt}\newline
\textbf{Escenario 3: Rechazo de avería crítica y generación de deslinde de responsabilidad}\newline
\textbf{Dado que} el cliente decide no autorizar la reparación del cilindro de rueda con fuga pese al riesgo inminente de pérdida de frenado,\newline
\textbf{cuando} el administrador registra la negativa formal del cliente en el expediente,\newline
\textbf{entonces} el sistema genera un Acta de Advertencia de Riesgo Mecánico y Deslinde de Responsabilidad para firma obligatoria del cliente,\newline
\textbf{y} reanuda únicamente las tareas previamente contratadas dejando constancia documental inalterable.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US21 según la norma APA 7.

### Epic 7: Control de repuestos y kardex de inventario

A continuación, se presentan las historias de usuario pertenecientes al epic número 7, que agrupa todas las funcionalidades relacionadas con control de repuestos y kardex de inventario de Atelier.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.5cm} | >{\centering\arraybackslash}p{5.0cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-7.5cm-6\tabcolsep-4\arrayrulewidth\relax} |}
\caption{Épica EP07: Control de repuestos y kardex de inventario} \label{tbl:ep07} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endfirsthead
\multicolumn{3}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endhead
\hline \multicolumn{3}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
EP07 & Personal de taller & Media \\
\hline
\thspanfirst{3}{Title} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Control de repuestos y kardex de inventario} \\
\hline
\thspanfirst{3}{Description} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} personal de taller (dueño o mecánico),\newline \textbf{quiero} consultar el catálogo de repuestos con ubicación física, descontar piezas consumidas por orden y recibir alertas automáticas de reposición crítica,\newline \textbf{para} mantener abastecido el almacén y evitar demoras operativas.} \\
\hline
\end{longtable}

*Nota.* Especificación de la épica EP07 elaborada para el proyecto Atelier según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US22 - Consulta de catálogo de repuestos con ubicación en anaquel y precio} \label{tbl:us22} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US22 & Personal de taller & Media & EP07 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Consulta de catálogo de repuestos con ubicación en anaquel y precio} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} personal de taller (dueño o mecánico),\newline \textbf{quiero} buscar repuestos por código de parte o descripción para conocer stock disponible y anaquel físico,\newline \textbf{para} ubicar rápidamente las piezas requeridas sin consultar registros físicos.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Búsqueda exitosa con stock positivo}\newline
\textbf{Dado que} el usuario busca el filtro de aceite mediante el código de fabricante o texto descriptivo,\newline
\textbf{cuando} ejecuta la consulta en el módulo de repuestos,\newline
\textbf{entonces} el sistema presenta el artículo, unidades disponibles en almacén, estante físico (ejemplo Estante B, Nivel 3) y precio unitario,\newline
\textbf{y} muestra el historial de movimientos recientes.\vspace{4pt}\newline
\textbf{Escenario 2: Búsqueda sin coincidencias en catálogo}\newline
\textbf{Dado que} el usuario ingresa un código de pieza inexistente en la base de datos,\newline
\textbf{cuando} ejecuta la búsqueda,\newline
\textbf{entonces} el sistema informa que no se hallaron registros coincidentes,\newline
\textbf{y} habilita la opción de registrar un nuevo ítem en el catálogo o gestionar una compra directa a pedido.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US22 según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US23 - Descuento automático de inventario y registro en Kardex por orden de trabajo} \label{tbl:us23} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US23 & Mecánico técnico & Alta & EP07 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Descuento automático de inventario y registro en Kardex por orden de trabajo} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} mecánico técnico,\newline \textbf{quiero} registrar la salida de repuestos y fluidos vinculándolos a la orden de trabajo en ejecución,\newline \textbf{para} rebajar el inventario en tiempo real y asegurar la trazabilidad del consumo de materiales.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Despacho exitoso de repuesto asignado con método FIFO}\newline
\textbf{Dado que} el mecánico retira 4 bujías de encendido autorizadas en la orden de trabajo activa,\newline
\textbf{cuando} confirma el consumo de los materiales en la aplicación móvil,\newline
\textbf{entonces} el sistema descuenta 4 unidades del inventario físico aplicando el método FIFO sobre el lote de adquisición más antiguo activo, genera el asiento de salida en el Kardex valorizado,\newline
\textbf{y} asocia el consumo a la orden de trabajo impidiendo duplicidades.\vspace{4pt}\newline
\textbf{Escenario 2: Bloqueo de retiro por stock insuficiente}\newline
\textbf{Dado que} el operario intenta registrar el retiro de 5 litros de aceite sintético cuando el inventario registra un saldo de solo 2 litros,\newline
\textbf{cuando} solicita confirmar el egreso de almacén,\newline
\textbf{entonces} el sistema bloquea la transacción de descuento,\newline
\textbf{y} alerta la inconsistencia de inventario notificando al administrador del taller.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US23 según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US24 - Configuración y disparo de alertas preventivas de stock mínimo} \label{tbl:us24} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US24 & Dueño de taller & Baja & EP07 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Configuración y disparo de alertas preventivas de stock mínimo} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} dueño de taller,\newline \textbf{quiero} definir umbrales de existencias mínimas para piezas de alta rotación (filtros, pastillas, lubricantes),\newline \textbf{para} recibir alertas tempranas antes de que ocurra una rotura de stock que paralice los servicios.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Generación de alerta por consumo bajo el umbral}\newline
\textbf{Dado que} un tipo de filtro de combustible posee un umbral mínimo fijado en 5 unidades y un retiro de almacén reduce el saldo disponible a 4 unidades,\newline
\textbf{cuando} se confirma el movimiento de salida en el inventario,\newline
\textbf{entonces} el sistema detecta la condición crítica, marca el artículo con indicador de Stock Crítico,\newline
\textbf{y} despacha una notificación en la bandeja de gestión del administrador.\vspace{4pt}\newline
\textbf{Escenario 2: Normalización del estado tras reabastecimiento}\newline
\textbf{Dado que} el administrador ingresa una factura de compra a proveedor incorporando 20 unidades del filtro observado,\newline
\textbf{cuando} guarda la recepción de mercadería,\newline
\textbf{entonces} el sistema actualiza el saldo a 24 unidades, registra el ingreso en el Kardex,\newline
\textbf{y} desactiva automáticamente la alerta preventiva de stock crítico.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US24 según la norma APA 7.

### Epic 8: Facturación, cobranza y entrega vehicular

A continuación, se presentan las historias de usuario pertenecientes al epic número 8, que agrupa todas las funcionalidades relacionadas con facturación, cobranza y entrega vehicular de Atelier.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.5cm} | >{\centering\arraybackslash}p{5.0cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-7.5cm-6\tabcolsep-4\arrayrulewidth\relax} |}
\caption{Épica EP08: Facturación, cobranza y entrega vehicular} \label{tbl:ep08} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endfirsthead
\multicolumn{3}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endhead
\hline \multicolumn{3}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
EP08 & Dueño de taller & Alta \\
\hline
\thspanfirst{3}{Title} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Facturación, cobranza y entrega vehicular} \\
\hline
\thspanfirst{3}{Description} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} dueño de taller,\newline \textbf{quiero} liquidar órdenes de trabajo, emitir comprobantes de pago electrónicos ante SUNAT, registrar cobranzas y formalizar el check-out vehicular con firma de conformidad en la app móvil,\newline \textbf{para} asegurar el cobro y cerrar formalmente la custodia legal del auto.} \\
\hline
\end{longtable}

*Nota.* Especificación de la épica EP08 elaborada para el proyecto Atelier según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US25 - Liquidación económica consolidada de la orden de trabajo} \label{tbl:us25} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US25 & Dueño de taller & Alta & EP08 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Liquidación económica consolidada de la orden de trabajo} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} dueño de taller,\newline \textbf{quiero} generar la pre-liquidación con el cómputo final de repuestos despachados y horas efectivas de mano de obra,\newline \textbf{para} conciliar los importes antes de la emisión del comprobante de pago electrónico.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Generación de pre-liquidación conforme}\newline
\textbf{Dado que} todas las tareas mecánicas de la orden concluyeron satisfactoriamente y superaron el control de calidad,\newline
\textbf{cuando} el administrador solicita la liquidación de la cuenta,\newline
\textbf{entonces} el sistema totaliza los costos de repuestos consumidos, aplica la tarifa de mano de obra real, calcula el subtotal gravado y el 18\% del IGV,\newline
\textbf{y} presenta el resumen consolidado para su validación final.\vspace{4pt}\newline
\textbf{Escenario 2: Detección de discrepancias en materiales}\newline
\textbf{Dado que} se detecta que un repuesto retirado de almacén no figuraba en el presupuesto autorizado,\newline
\textbf{cuando} se procesa la pre-liquidación,\newline
\textbf{entonces} el sistema resalta la partida no presupuestada como observación pendiente,\newline
\textbf{y} exige la justificación técnica del administrador antes de proceder a la facturación.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US25 según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US26 - Emisión de comprobante de pago electrónico (Boleta con DNI o Factura con RUC) ante SUNAT} \label{tbl:us26} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US26 & Dueño de taller & Alta & EP08 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Emisión de comprobante de pago electrónico (Boleta con DNI o Factura con RUC) ante SUNAT} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} dueño de taller,\newline \textbf{quiero} emitir boletas de venta con DNI o facturas con RUC conforme al estándar UBL 2.1 validado por SUNAT,\newline \textbf{para} cumplir las obligaciones tributarias y entregar un comprobante fiscalmente válido al cliente.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Emisión exitosa de Factura Electrónica a empresa}\newline
\textbf{Dado que} el cliente solicita Factura Electrónica y proporciona un número de RUC de 11 dígitos con estado Habido y Activo según padrón SUNAT,\newline
\textbf{cuando} el administrador confirma la emisión del comprobante,\newline
\textbf{entonces} el sistema estructura el payload JSON UBL 2.1, lo transmite al Proveedor de Servicios Electrónicos (Nubefact), obtiene la Constancia de Recepción (CDR) aprobada por SUNAT con código hash y firma digital,\newline
\textbf{y} asocia el PDF y XML al expediente de la orden.\vspace{4pt}\newline
\textbf{Escenario 2: Emisión exitosa de Boleta de Venta a persona natural}\newline
\textbf{Dado que} el cliente es una persona natural que proporciona su documento nacional de identidad (DNI) de 8 dígitos,\newline
\textbf{cuando} el administrador confirma la emisión de la Boleta de Venta Electrónica,\newline
\textbf{entonces} el sistema valida el formato numérico del DNI, transmite el comprobante a SUNAT obteniendo CDR aprobado,\newline
\textbf{y} genera la representación gráfica imprimible con código QR de verificación fiscal.\vspace{4pt}\newline
\textbf{Escenario 3: Falla de comunicación con el servicio tributario}\newline
\textbf{Dado que} el servicio externo de SUNAT presenta intermitencia o responde con código de error HTTP 503,\newline
\textbf{cuando} se transmite el comprobante electrónico,\newline
\textbf{entonces} el sistema captura la excepción, almacena el comprobante en la cola de contingencia local,\newline
\textbf{y} alerta al administrador que el documento se encuentra en estado Pendiente de Envío programando su reintento automático.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US26 según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US27 - Registro de cobranza por múltiples medios y desglose de detracciones SPOT} \label{tbl:us27} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US27 & Dueño de taller & Alta & EP08 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Registro de cobranza por múltiples medios y desglose de detracciones SPOT} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} dueño de taller,\newline \textbf{quiero} registrar los pagos recibidos combinando efectivo, transferencias, billeteras digitales (Yape/Plin), tarjetas POS o vouchers de detracción,\newline \textbf{para} saldar la cuenta por cobrar y habilitar el pase de salida vehicular.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Pago íntegro mediante billetera digital o POS}\newline
\textbf{Dado que} el cliente efectúa el pago total de S/ 450 mediante transferencia Yape o tarjeta de débito en terminal POS,\newline
\textbf{cuando} el administrador registra el medio de pago, ingresa el número de operación bancaria y confirma el cobro,\newline
\textbf{entonces} el sistema fija el saldo pendiente de la orden en S/ 0.00, emite el recibo de caja numerado,\newline
\textbf{y} habilita la autorización de entrega física del vehículo.\vspace{4pt}\newline
\textbf{Escenario 2: Pago mixto con comprobante sujeto a detracción SPOT}\newline
\textbf{Dado que} una empresa abona una factura de S/ 1200 desglosando el 90\% (S/ 1080) vía transferencia a cuenta corriente y el 10\% (S/ 120) mediante constancia de detracción al Banco de la Nación,\newline
\textbf{cuando} el administrador registra ambos abonos con sus respectivos números de operación,\newline
\textbf{entonces} el sistema consolida ambas transacciones, extingue la cuenta por cobrar,\newline
\textbf{y} registra el voucher de detracción para la declaración tributaria mensual.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US27 según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US28 - Registro digital de check-out, odómetro de salida y firma de conformidad en la aplicación móvil} \label{tbl:us28} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US28 & Dueño de taller & Alta & EP08 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Registro digital de check-out, odómetro de salida y firma de conformidad en la aplicación móvil} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} dueño de taller,\newline \textbf{quiero} registrar el kilometraje final de salida en la aplicación móvil, verificar la devolución de pertenencias y capturar la firma digital de conformidad del cliente en el dispositivo,\newline \textbf{para} cerrar formalmente la orden de trabajo y transferir la custodia del vehículo con respaldo digital inalterable.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Entrega física y cierre definitivo de orden con conformidad}\newline
\textbf{Dado que} la orden cuenta con saldo cero en caja y pase de entrega vehicular emitido,\newline
\textbf{cuando} el administrador registra el odómetro final de entrega con recorrido en prueba de ruta inferior a 10 kilómetros, constata la restitución de todas las pertenencias del inventario inicial y captura la firma digital de conformidad del cliente en el dispositivo móvil,\newline
\textbf{entonces} el sistema emite el Acta de Entrega y Conformidad en formato PDF, finaliza la custodia del taller,\newline
\textbf{y} fija el estado definitivo de la orden de trabajo en Cerrada.\vspace{4pt}\newline
\textbf{Escenario 2: Bloqueo de entrega por saldo pendiente de pago}\newline
\textbf{Dado que} un vehículo concluyó la reparación pero mantiene un saldo no liquidado de S/ 150 en caja,\newline
\textbf{cuando} el operario intenta generar el pase de entrega vehicular,\newline
\textbf{entonces} el sistema bloquea la emisión del acta de salida,\newline
\textbf{y} indica que la orden debe registrar cobranza total antes de permitir la firma de entrega física.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US28 según la norma APA 7.

### Epic 9: Analítica y métricas de desempeño

A continuación, se presentan las historias de usuario pertenecientes al epic número 9, que agrupa todas las funcionalidades relacionadas con analítica y métricas de desempeño de Atelier.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.5cm} | >{\centering\arraybackslash}p{5.0cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-7.5cm-6\tabcolsep-4\arrayrulewidth\relax} |}
\caption{Épica EP09: Analítica y métricas de desempeño} \label{tbl:ep09} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endfirsthead
\multicolumn{3}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endhead
\hline \multicolumn{3}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
EP09 & Dueño de taller & Baja \\
\hline
\thspanfirst{3}{Title} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Analítica y métricas de desempeño} \\
\hline
\thspanfirst{3}{Description} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} dueño de taller,\newline \textbf{quiero} visualizar paneles con indicadores de facturación, ticket promedio, margen de ganancia y productividad de los mecánicos,\newline \textbf{para} tomar decisiones financieras y comerciales fundamentadas.} \\
\hline
\end{longtable}

*Nota.* Especificación de la épica EP09 elaborada para el proyecto Atelier según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US29 - Visualización de panel gerencial con indicadores financieros y facturación mensual} \label{tbl:us29} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US29 & Dueño de taller & Baja & EP09 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Visualización de panel gerencial con indicadores financieros y facturación mensual} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} dueño de taller,\newline \textbf{quiero} consultar un tablero con métricas de facturación acumulada, ticket promedio e ingresos desglosados por repuestos y servicios,\newline \textbf{para} evaluar la salud financiera del taller y tomar decisiones de precios.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Consulta de métricas del mes en curso}\newline
\textbf{Dado que} el administrador accede al módulo de analítica seleccionando el periodo mensual actual,\newline
\textbf{cuando} solicita la consolidación de indicadores,\newline
\textbf{entonces} el sistema procesa las órdenes liquidadas y presenta la facturación total en soles, el margen bruto estimado y el ticket promedio por vehículo atendido,\newline
\textbf{y} despliega una gráfica comparativa respecto al mes precedente.\vspace{4pt}\newline
\textbf{Escenario 2: Filtrado por rango de fechas personalizado}\newline
\textbf{Dado que} el administrador define un intervalo específico de fechas para auditar una campaña comercial,\newline
\textbf{cuando} aplica el filtro temporal,\newline
\textbf{entonces} el sistema recalcula de forma inmediata todos los agregados financieros,\newline
\textbf{y} habilita la opción de exportar el resumen en formato estructurado.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US29 según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US30 - Reporte de productividad operativa y horas efectivas por mecánico} \label{tbl:us30} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US30 & Dueño de taller & Baja & EP09 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Reporte de productividad operativa y horas efectivas por mecánico} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} dueño de taller,\newline \textbf{quiero} analizar el rendimiento individual de cada mecánico comparando horas estimadas contra horas reales de trabajo,\newline \textbf{para} premiar la eficiencia operativa y detectar necesidades de capacitación técnica.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Despliegue de rendimiento por operario}\newline
\textbf{Dado que} el administrador selecciona la vista de productividad del personal operativo,\newline
\textbf{cuando} solicita el reporte de desempeño,\newline
\textbf{entonces} el sistema despliega la lista de mecánicos, total de tareas culminadas, promedio de cumplimiento de tiempos estándar y porcentaje de no conformidades en control de calidad,\newline
\textbf{y} resalta a los colaboradores con mayor índice de productividad.\vspace{4pt}\newline
\textbf{Escenario 2: Identificación de desviaciones recurrentes de tiempo}\newline
\textbf{Dado que} un mecánico presenta un sobretiempo superior al 30\% de forma sostenida en servicios de embrague,\newline
\textbf{cuando} el sistema evalúa las métricas operativas acumuladas,\newline
\textbf{entonces} identifica la especialidad con un estado de alerta por desviación de tiempo estándar,\newline
\textbf{y} sugiere la revisión de procedimientos o reajuste de tarifas horarias.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US30 según la norma APA 7.

### Epic 10: Configuración y administración del taller

A continuación, se presentan las historias de usuario pertenecientes al epic número 10, que agrupa todas las funcionalidades relacionadas con configuración y administración del taller de Atelier.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.5cm} | >{\centering\arraybackslash}p{5.0cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-7.5cm-6\tabcolsep-4\arrayrulewidth\relax} |}
\caption{Épica EP10: Configuración y administración del taller} \label{tbl:ep10} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endfirsthead
\multicolumn{3}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Epic ID} & \thcell{User} & \thcell{Priority} \\
\hline
\endhead
\hline \multicolumn{3}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
EP10 & Dueño de taller & Media \\
\hline
\thspanfirst{3}{Title} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Configuración y administración del taller} \\
\hline
\thspanfirst{3}{Description} \\
\hline
\multicolumn{3}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} dueño de taller,\newline \textbf{quiero} configurar la información fiscal y comercial de mi taller, fijar las coordenadas perimétricas para la geocerca y gestionar al equipo de mecánicos,\newline \textbf{para} gobernar la operación del taller y personalizar los comprobantes impresos.} \\
\hline
\end{longtable}

*Nota.* Especificación de la épica EP10 elaborada para el proyecto Atelier según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US31 - Configuración de información fiscal del taller y coordenadas de geocerca perimétrica} \label{tbl:us31} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US31 & Dueño de taller & Media & EP10 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Configuración de información fiscal del taller y coordenadas de geocerca perimétrica} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} dueño de taller,\newline \textbf{quiero} registrar la razón social, RUC, dirección fiscal y fijar las coordenadas GPS de la sede en un mapa interactivo,\newline \textbf{para} personalizar los comprobantes electrónicos y definir el perímetro de validación de ingresos vehiculares.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Actualización de datos corporativos y punto perimétrico}\newline
\textbf{Dado que} el administrador ingresa el RUC del taller, domicilio fiscal, logotipo corporativo y selecciona en el mapa la ubicación geográfica de la sede fijando un radio de tolerancia de 50 metros,\newline
\textbf{cuando} guarda la configuración general,\newline
\textbf{entonces} el sistema valida la estructura de los datos fiscales, almacena las coordenadas de referencia (latitud y longitud),\newline
\textbf{y} actualiza los encabezados de los comprobantes impresos.\vspace{4pt}\newline
\textbf{Escenario 2: Validación de coordenadas geográficas inconsistentes}\newline
\textbf{Dado que} se intentan ingresar coordenadas con valores fuera del rango geodésico válido o radio perimétrico negativo,\newline
\textbf{cuando} solicita guardar los cambios,\newline
\textbf{entonces} el sistema rechaza la operación,\newline
\textbf{y} señala los campos numéricos inválidos solicitando su corrección inmediata.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US31 según la norma APA 7.

\renewcommand{\arraystretch}{1.3}
\begin{longtable}{| >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{4.2cm} | >{\centering\arraybackslash}p{2.2cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-8.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Historia de Usuario US32 - Gestión de personal operativo, especialidades y credenciales de acceso} \label{tbl:us32} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endfirsthead
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continuación de la página anterior}} \\
\hline
\thfirst{Story ID} & \thcell{User} & \thcell{Priority} & \thcell{Epic} \\
\hline
\endhead
\hline \multicolumn{4}{r}{\textit{Continúa en la siguiente página}} \\
\endfoot
\hline
\endlastfoot
US32 & Dueño de taller & Media & EP10 \\
\hline
\thspanfirst{4}{Title} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{Gestión de personal operativo, especialidades y credenciales de acceso} \\
\hline
\thspanfirst{4}{Description} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{\textbf{Como} dueño de taller,\newline \textbf{quiero} registrar a los mecánicos asignándoles especialidad técnica (frenos, motor, suspensión, electricidad) y credenciales de acceso,\newline \textbf{para} autorizar su ingreso a la aplicación móvil y habilitarlos en la distribución de tareas de patio.} \\
\hline
\thspanfirst{4}{Acceptance Criteria} \\
\hline
\multicolumn{4}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Escenario 1: Alta exitosa de nuevo mecánico técnico}\newline
\textbf{Dado que} el administrador ingresa el nombre, documento de identidad, correo corporativo y especialidad de un nuevo mecánico técnico,\newline
\textbf{cuando} confirma el registro del colaborador,\newline
\textbf{entonces} el sistema crea la cuenta de usuario vinculada a la organización con el rol operativo Mecánico técnico,\newline
\textbf{y} despacha una clave temporal al correo del trabajador habilitándolo en el selector de tareas.\vspace{4pt}\newline
\textbf{Escenario 2: Desactivación de cuenta de operario cesado}\newline
\textbf{Dado que} un mecánico concluye su relación laboral con la empresa,\newline
\textbf{cuando} el administrador cambia el estado del trabajador a Inactivo,\newline
\textbf{entonces} el sistema revoca inmediatamente los tokens JWT activos del usuario, lo excluye de futuras asignaciones de tareas,\newline
\textbf{y} preserva íntegramente su historial de intervenciones mecánicas en órdenes concluidas.%
} \\
\hline
\end{longtable}

*Nota.* Criterios de aceptación estructurados en formato BDD Gherkin para la historia US32 según la norma APA 7.

### 2.4.2. *Impact Mapping*



### 2.4.3. *Product Backlog*



\newpage
