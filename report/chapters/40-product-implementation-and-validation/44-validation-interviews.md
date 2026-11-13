## 4.3. Validation Interviews

En esta sección se presenta el proceso de validación cualitativa de las soluciones digitales del ecosistema Atelier mediante entrevistas directas con representantes de los dos segmentos objetivo del negocio. Estas sesiones permiten confrontar los incrementos construidos durante los ciclos de desarrollo con la operativa diaria de los talleres automotrices, evaluando el grado de comprensión de la propuesta de valor comercial y la efectividad de los flujos de trabajo sobre la aplicación móvil de taller.

Las sesiones de evaluación combinan pruebas de usabilidad guiadas sobre tareas representativas y técnicas de observación directa mientras los usuarios interactúan con el portal web comercial Atelier Website y con la aplicación móvil nativa Atelier Workshop Mobile. Con este enfoque, el equipo recoge retroalimentación sobre la claridad de las interfaces, la adecuación del lenguaje técnico automotriz y la fluidez en la transición entre estaciones de trabajo en patio, foso y administración.

### 4.3.1. _Diseño de Entrevistas_

El diseño metodológico de las sesiones de validación delimita los objetivos de indagación, los artefactos digitales evaluados, los flujos de interacción y las tareas asignadas a cada perfil. La formulación contempla dos guías diferenciadas acordes a las responsabilidades de cada segmento:

**Segmento 1: Personal de Gestión y Propietarios del Taller**

Este segmento asume la dirección comercial, el control de ingresos y la coordinación general del taller automotriz. La evaluación se orienta a determinar si la presentación de la propuesta de valor en el portal web resulta convincente, si los planes comerciales responden a su capacidad económica y si la aplicación móvil resuelve de forma ágil las operaciones de recepción vehicular, presupuestos y atención en counter.

1. Elementos incluidos en la sesión:
   - Portal web comercial Atelier Website en su entorno de producción, abordando la propuesta de valor central, el simulador de tarifas por periodicidad de facturación, la sección de preguntas frecuentes y el enlace de registro.
   - Aplicación móvil Atelier Workshop Mobile en dispositivo Android, evaluando los módulos de recepción vehicular en patio, generación digital de proformas y consulta del estado de órdenes de trabajo.

2. Flujos de usuario seleccionados para la validación:
   - Flujo de bienvenida y afiliación de clientes en patio, correspondiente a la historia de usuario US44 y al User Goal 4 del diseño de experiencia.
   - Flujo de creación de orden de trabajo con parametrización inicial de faenas mecánicas, correspondiente a la historia de usuario US12.
   - Flujo de registro fotográfico 360 grados de carrocería para documentación pericial de ingreso, correspondiente a la historia de usuario US13.
   - Flujo de emisión digital de proformas comerciales con cálculo automático de impuestos y desglose de costos, correspondiente a las historias de usuario US22 y US24.
   - Flujo de formalización de la decisión del cliente ante el presupuesto presentado, correspondiente a la historia de usuario US25 y al User Goal 8.

3. Tareas operativas asignadas al entrevistado:
   - Tarea 1: Explorar el portal web comercial, localizar el comparador de suscripciones e identificar los beneficios incluidos en el plan para talleres independientes.
   - Tarea 2: Ingresar a la aplicación móvil con credenciales de prueba y seleccionar la sucursal asignada para la jornada.
   - Tarea 3: Registrar la llegada de un vehículo presencial consultando su placa de rodaje, completando el odómetro actual y adjuntando una captura fotográfica de evidencia en patio.
   - Tarea 4: Configurar dos tareas mecánicas iniciales, generar la proforma digital en formato PDF y verificar el desglose de mano de obra y repuestos.
   - Tarea 5: Asentar en el sistema la aceptación comunicada por el propietario del vehículo para habilitar la intervención técnica en bahía.

**Segmento 2: Personal Operativo del Taller**

Este segmento reúne a los técnicos mecánicos, jefes de foso y encargados de inventario que ejecutan las intervenciones vehiculares y administran los insumos. La sesión se enfoca en medir la facilidad de uso de la aplicación móvil en condiciones de taller, la rapidez de marcación de jornada y la comprensión de los procedimientos de cronometraje de faenas y descargo de repuestos.

1. Elementos incluidos en la sesión:
   - Aplicación móvil Atelier Workshop Mobile ejecutada en smartphone Android de gama media, simulando las condiciones físicas habituales de operación en foso y bahía.

2. Flujos de usuario seleccionados para la validación:
   - Flujo de autenticación corporativa y selección de sede de trabajo, correspondiente a las historias de usuario US01, US02 y US03, y al User Goal 1.
   - Flujo de marcación de ingreso laboral con validación de coordenadas geográficas de la sede, correspondiente a la historia de usuario US06 y al User Goal 3.
   - Flujo de consulta y priorización de tareas técnicas asignadas en bahía, correspondiente a la historia de usuario US26.
   - Flujo de control de cronometraje de labor efectiva con gestión de pausas operativas, correspondiente a la historia de usuario US27 y al User Goal 7.
   - Flujo de búsqueda en catálogo y descargo físico de repuestos bajo el método FIFO por lote, correspondiente a las historias de usuario US31 y US32, y al User Goal 6.
   - Flujo de reporte técnico de hallazgos imprevistos en foso con captura fotográfica, correspondiente a la historia de usuario US14.

3. Tareas operativas asignadas al entrevistado:
   - Tarea 1: Iniciar sesión en la aplicación móvil con el correo y confirmar el acceso.
   - Tarea 2: Realizar la marcación de ingreso comprobando que el indicador visual confirme la ubicación dentro del perímetro de la sede de trabajo.
   - Tarea 3: Revisar el panel de tareas asignadas para el turno, identificar la faena con mayor prioridad e iniciar el cronómetro de intervención en bahía.
   - Tarea 4: Registrar una pausa de descanso, verificar la suspensión del contador y reanudar la labor efectiva.
   - Tarea 5: Consultar la disponibilidad de un repuesto en catálogo y realizar el descargo de material verificando la afectación del lote de adquisición más antiguo.
   - Tarea 6: Registrar una propuesta técnica adicional adjuntando una fotografía del defecto detectado en la suspensión del vehículo.

A continuación, la @tbl:diseno-entrevistas-validacion resume la matriz de diseño metodológico de las sesiones de validación para ambos segmentos:

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\raggedright\arraybackslash}p{2.6cm} | >{\raggedright\arraybackslash}p{3.8cm} | >{\raggedright\arraybackslash}p{4.2cm} | >{\raggedright\arraybackslash}p{\dimexpr\textwidth-10.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Matriz de Diseño de Entrevistas de Validación} \label{tbl:diseno-entrevistas-validacion} \\
\hline
\thfirst{Segmento Objetivo} & \thcell{Productos Evaluados} & \thcell{Flujos de Usuario Clave} & \thcell{Aspectos de Observación} \\
\hline
\endfirsthead
\hline
\thfirst{Segmento Objetivo} & \thcell{Productos Evaluados} & \thcell{Flujos de Usuario Clave} & \thcell{Aspectos de Observación} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
Segmento 1: Personal de Gestión y Propietarios de Taller & Portal web comercial Atelier Website y aplicación móvil Atelier Workshop Mobile & Recepción de vehículos en patio, creación de órdenes, proformas comerciales y autorización de presupuestos & Claridad en la propuesta de valor comercial, tiempo requerido para abrir una orden y comprensión del desglose imponible de proformas. \\
\hline
Segmento 2: Personal Operativo del Taller & Aplicación móvil nativa Atelier Workshop Mobile & Marcación de asistencia con validación de posición, cronometraje de faenas, requisición FIFO y reporte de hallazgos & Precisión en la marcacion de presencia laboral, agilidad al operar el cronómetro de bahía y comprensión del descargo de inventario por lote. \\
\hline
\end{longtable}

_Nota._ Matriz elaborada para la planificación de las entrevistas de validación de Atelier.

### 4.3.2. _Registro de Entrevistas_

En esta sección se presentan los registros individuales y la compilación de evidencias de las entrevistas de validación realizadas con representantes de ambos segmentos objetivo. Las sesiones se llevaron a cabo evaluando los incrementos funcionales del portal web comercial Atelier Website y de la aplicación móvil nativa Atelier Workshop Mobile en dispositivos Android.

Conforme a las pautas de registro audiovisual del proyecto, las grabaciones completas de las entrevistas han sido editadas y unificadas en un archivo audiovisual consolidado denominado **upc-pre-202620-1acc0238-4951-andeva-validation-av2.mp4**, publicado en el repositorio institucional de OneDrive en el siguiente enlace: [Video Consolidado de Validación (OneDrive)](https://upcedupe-my.sharepoint.com/:v:/g/personal/u20241e275_upc_edu_pe/IQDQRFe6_07YQ5IyAfsO8-lZASKREUobZCqZ_7w8a7zf0jc). Cada registro detalla los datos demográficos del participante, el intervalo temporal dentro del metraje unificado, un contenedor para la captura de pantalla del fotograma y un resumen descriptivo de las observaciones manifestadas durante la interacción.

**Segmento 1: Personal de Gestión y Propietarios del Taller**

A continuación se presentan las entrevistas correspondientes a los representantes de la gestión administrativa y comercial del taller:

\begin{table}[H]
\centering
\caption{Entrevista de Validación a Jorge Antonio Aguilar Perez}
\label{tbl:entrevista-val-s1-1}
\renewcommand{\arraystretch}{1.3}
\begin{tabularx}{\textwidth}{| p{\dimexpr0.5\textwidth-2\tabcolsep-1.5\arrayrulewidth\relax} | >{\centering\arraybackslash}m{\dimexpr0.5\textwidth-2\tabcolsep-1.5\arrayrulewidth\relax} |}
\hline
\thfirst{Datos del entrevistado} & \thcell{Registro de evidencia audiovisual} \\
\hline
\textbullet\ \textbf{Nombre:} Jorge Antonio \newline
\textbullet\ \textbf{Apellidos:} Aguilar Perez \newline
\textbullet\ \textbf{Edad:} 53 años \newline
\textbullet\ \textbf{Distrito:} Chorrillos \newline
\textbullet\ \textbf{Duración:} 00:00 min a 04:45 min
\vspace{2pt}
& \fbox{\parbox[c][3.8cm][c]{0.90\linewidth}{\centering\footnotesize\textit{[Espacio para captura de pantalla del video de validación]}}} \\
\hline
\thspanfirst{2}{Resumen de la entrevista} \\
\hline
\multicolumn{2}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
El entrevistado evaluó la propuesta comercial del portal web y el flujo de recepción vehicular en la aplicación móvil. Manifestó que la calculadora interactiva de suscripciones resulta clara al proyectar el ahorro mensual frente a sistemas tradicionales. Durante la prueba en el dispositivo móvil, valoró la rapidez con la que se registra un vehículo por su placa de rodaje y la incorporación inmediata de la fotografía pericial en patio. Sugirió hacer más visibles los términos de garantía en la proforma digital antes de enviarla al cliente final.
} \\
\hline
\multicolumn{2}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Enlace:} \href{https://upcedupe-my.sharepoint.com/:v:/g/personal/u20241e275_upc_edu_pe/IQDQRFe6_07YQ5IyAfsO8-lZASKREUobZCqZ_7w8a7zf0jc}{Video de Validación - Entrevista 1 (OneDrive)}
} \\
\hline
\end{tabularx}
\end{table}

_Nota._ Registro de entrevista de validación correspondiente al Segmento 1.

\begin{table}[H]
\centering
\caption{Entrevista de Validación a Marcelo Alejandro Silva Ramos}
\label{tbl:entrevista-val-s1-2}
\renewcommand{\arraystretch}{1.3}
\begin{tabularx}{\textwidth}{| p{\dimexpr0.5\textwidth-2\tabcolsep-1.5\arrayrulewidth\relax} | >{\centering\arraybackslash}m{\dimexpr0.5\textwidth-2\tabcolsep-1.5\arrayrulewidth\relax} |}
\hline
\thfirst{Datos del entrevistado} & \thcell{Registro de evidencia audiovisual} \\
\hline
\textbullet\ \textbf{Nombre:} Marcelo Alejandro \newline
\textbullet\ \textbf{Apellidos:} Silva Ramos \newline
\textbullet\ \textbf{Edad:} 63 años \newline
\textbullet\ \textbf{Distrito:} Chorrillos \newline
\textbullet\ \textbf{Duración:} 04:45 min a 09:20 min
\vspace{2pt}
& \fbox{\parbox[c][3.8cm][c]{0.90\linewidth}{\centering\footnotesize\textit{[Espacio para captura de pantalla del video de validación]}}} \\
\hline
\thspanfirst{2}{Resumen de la entrevista} \\
\hline
\multicolumn{2}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
El participante revisó la presentación de planes en el sitio web y la emisión de presupuestos en la aplicación móvil. Destacó como fortaleza la presentación limpia del desglose de mano de obra y repuestos en el documento generado. Señaló que en la rutina diaria de taller es vital que el cliente pueda autorizar trabajos adicionales sin acudir físicamente al local, por lo que consideró muy conveniente el registro formal de aprobación remota. Expresó dudas sobre la visualización de proformas en pantallas pequeñas de clientes mayores, recomendando tipografías más contrastadas.
} \\
\hline
\multicolumn{2}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Enlace:} \href{https://upcedupe-my.sharepoint.com/:v:/g/personal/u20241e275_upc_edu_pe/IQDQRFe6_07YQ5IyAfsO8-lZASKREUobZCqZ_7w8a7zf0jc}{Video de Validación - Entrevista 2 (OneDrive)}
} \\
\hline
\end{tabularx}
\end{table}

_Nota._ Registro de entrevista de validación correspondiente al Segmento 1.

\begin{table}[H]
\centering
\caption{Entrevista de Validación a Carlos Alberto Mendoza Rivas}
\label{tbl:entrevista-val-s1-3}
\renewcommand{\arraystretch}{1.3}
\begin{tabularx}{\textwidth}{| p{\dimexpr0.5\textwidth-2\tabcolsep-1.5\arrayrulewidth\relax} | >{\centering\arraybackslash}m{\dimexpr0.5\textwidth-2\tabcolsep-1.5\arrayrulewidth\relax} |}
\hline
\thfirst{Datos del entrevistado} & \thcell{Registro de evidencia audiovisual} \\
\hline
\textbullet\ \textbf{Nombre:} Carlos Alberto \newline
\textbullet\ \textbf{Apellidos:} Mendoza Rivas \newline
\textbullet\ \textbf{Edad:} 48 años \newline
\textbullet\ \textbf{Distrito:} San Juan de Miraflores \newline
\textbullet\ \textbf{Duración:} 09:20 min a 14:10 min
\vspace{2pt}
& \fbox{\parbox[c][3.8cm][c]{0.90\linewidth}{\centering\footnotesize\textit{[Espacio para captura de pantalla del video de validación]}}} \\
\hline
\thspanfirst{2}{Resumen de la entrevista} \\
\hline
\multicolumn{2}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
El entrevistado comprobó la navegación comercial y la creación de órdenes de trabajo. Indicó que la diferenciación de estados entre orden activa y proforma en espera evita confusiones operativas con los mecánicos. Como oportunidad de mejora, sugirió agregar una confirmación rápida al afiliar clientes presenciales para verificar que el número de contacto esté completo antes de generar la cotización.
} \\
\hline
\multicolumn{2}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Enlace:} \href{https://upcedupe-my.sharepoint.com/:v:/g/personal/u20241e275_upc_edu_pe/IQDQRFe6_07YQ5IyAfsO8-lZASKREUobZCqZ_7w8a7zf0jc}{Video de Validación - Entrevista 3 (OneDrive)}
} \\
\hline
\end{tabularx}
\end{table}

_Nota._ Registro de entrevista de validación correspondiente al Segmento 1.

\newpage

**Segmento 2: Personal Operativo del Taller**

A continuación se presentan las entrevistas efectuadas a técnicos mecánicos y especialistas de patio:

\begin{table}[H]
\centering
\caption{Entrevista de Validación a César Nikolay Montero Vega}
\label{tbl:entrevista-val-s2-1}
\renewcommand{\arraystretch}{1.3}
\begin{tabularx}{\textwidth}{| p{\dimexpr0.5\textwidth-2\tabcolsep-1.5\arrayrulewidth\relax} | >{\centering\arraybackslash}m{\dimexpr0.5\textwidth-2\tabcolsep-1.5\arrayrulewidth\relax} |}
\hline
\thfirst{Datos del entrevistado} & \thcell{Registro de evidencia audiovisual} \\
\hline
\textbullet\ \textbf{Nombre:} César Nikolay \newline
\textbullet\ \textbf{Apellidos:} Montero Vega \newline
\textbullet\ \textbf{Edad:} 23 años \newline
\textbullet\ \textbf{Distrito:} Chorrillos \newline
\textbullet\ \textbf{Duración:} 14:10 min a 18:50 min
\vspace{2pt}
& \fbox{\parbox[c][3.8cm][c]{0.90\linewidth}{\centering\footnotesize\textit{[Espacio para captura de pantalla del video de validación]}}} \\
\hline
\thspanfirst{2}{Resumen de la entrevista} \\
\hline
\multicolumn{2}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
El técnico interactuó con la aplicación móvil en tareas de marcación laboral y asignación de trabajos mecánicos. Resaltó la confirmación visual de la geocerca satelital al registrar la asistencia, indicando que elimina discusiones sobre horas de llegada. Al operar el cronómetro de faenas, valoró que el botón de pausa sea de gran tamaño y fácilmente presionable. Observó que en fosos profundos con poca luz convendría reforzar las alertas sonoras al terminar una tarea técnica.
} \\
\hline
\multicolumn{2}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Enlace:} \href{https://upcedupe-my.sharepoint.com/:v:/g/personal/u20241e275_upc_edu_pe/IQDQRFe6_07YQ5IyAfsO8-lZASKREUobZCqZ_7w8a7zf0jc}{Video de Validación - Entrevista 4 (OneDrive)}
} \\
\hline
\end{tabularx}
\end{table}

_Nota._ Registro de entrevista de validación correspondiente al Segmento 2.

\begin{table}[H]
\centering
\caption{Entrevista de Validación a Bruno Marcelo Pacheco Díaz}
\label{tbl:entrevista-val-s2-2}
\renewcommand{\arraystretch}{1.3}
\begin{tabularx}{\textwidth}{| p{\dimexpr0.5\textwidth-2\tabcolsep-1.5\arrayrulewidth\relax} | >{\centering\arraybackslash}m{\dimexpr0.5\textwidth-2\tabcolsep-1.5\arrayrulewidth\relax} |}
\hline
\thfirst{Datos del entrevistado} & \thcell{Registro de evidencia audiovisual} \\
\hline
\textbullet\ \textbf{Nombre:} Bruno Marcelo \newline
\textbullet\ \textbf{Apellidos:} Pacheco Díaz \newline
\textbullet\ \textbf{Edad:} 25 años \newline
\textbullet\ \textbf{Distrito:} Chorrillos \newline
\textbullet\ \textbf{Duración:} 00:04 min a 05:37 min
\vspace{2pt}
& \includegraphics[width=0.92\linewidth, height=3.8cm, keepaspectratio]{report/assets/validation-Interviews/Interview-of-Bruno-Pacheco.png} \\
\hline
\thspanfirst{2}{Resumen de la entrevista} \\
\hline
\multicolumn{2}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
El entrevistado evaluó la aplicación móvil y comentó que todo le pareció bien. Como recomendación, sugirió que debería existir un tutorial que explique cómo usar la aplicación móvil.
} \\
\hline
\multicolumn{2}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Enlace:} \href{https://drive.google.com/file/d/1ZH1HuE0QIzWRkkK1NiSFh7Vrv-WmKWCJ/view?usp=sharing}{Video de Validación - Entrevista 5 (OneDrive)}
} \\
\hline
\end{tabularx}
\end{table}

_Nota._ Registro de entrevista de validación correspondiente al Segmento 2.

\begin{table}[H]
\centering
\caption{Entrevista de Validación a Angie Karol Choque Pura}
\label{tbl:entrevista-val-s2-3}
\renewcommand{\arraystretch}{1.3}
\begin{tabularx}{\textwidth}{| p{\dimexpr0.5\textwidth-2\tabcolsep-1.5\arrayrulewidth\relax} | >{\centering\arraybackslash}m{\dimexpr0.5\textwidth-2\tabcolsep-1.5\arrayrulewidth\relax} |}
\hline
\thfirst{Datos del entrevistado} & \thcell{Registro de evidencia audiovisual} \\
\hline
\textbullet\ \textbf{Nombre:} Angie Karol \newline
\textbullet\ \textbf{Apellidos:} Choque Pura \newline
\textbullet\ \textbf{Edad:} 25 años \newline
\textbullet\ \textbf{Distrito:} Santiago de Surco \newline
\textbullet\ \textbf{Duración:} 23:30 min a 28:15 min
\vspace{2pt}
& \fbox{\parbox[c][3.8cm][c]{0.90\linewidth}{\centering\footnotesize\textit{[Espacio para captura de pantalla del video de validación]}}} \\
\hline
\thspanfirst{2}{Resumen de la entrevista} \\
\hline
\multicolumn{2}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
La entrevistada evaluó la búsqueda de repuestos en catálogo y el procedimiento de descargo por lote cronológico FIFO. Señaló que la identificación automática del lote más antiguo reduce equivocaciones en el inventario físico del taller. Como aspecto de mejora, mencionó que al buscar piezas por código numérico se debería permitir ingresar fragmentos parciales del código para agilizar la respuesta en el almacén.
} \\
\hline
\multicolumn{2}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Enlace:} \href{https://upcedupe-my.sharepoint.com/:v:/g/personal/u20241e275_upc_edu_pe/IQDQRFe6_07YQ5IyAfsO8-lZASKREUobZCqZ_7w8a7zf0jc}{Video de Validación - Entrevista 6 (OneDrive)}
} \\
\hline
\end{tabularx}
\end{table}

_Nota._ Registro de entrevista de validación correspondiente al Segmento 2.

\newpage

### 4.3.3. _Evaluaciones según heurísticas_

En esta sección se documenta la evaluación formal de la experiencia de usuario de las soluciones digitales Atelier Website y Atelier Workshop Mobile. La evaluación adopta el formato estándar establecido en el Anexo E del proyecto, estructurando el análisis en tres dimensiones fundamentales: heurísticas de usabilidad de Jakob Nielsen, principios de arquitectura de información y directrices de diseño inclusivo.

**Ficha Técnica de Evaluación Heurística**

\renewcommand{\arraystretch}{1.2}
\begin{longtable}{| >{\raggedright\arraybackslash}p{4.2cm} | >{\raggedright\arraybackslash}p{\dimexpr\textwidth-4.2cm-4\tabcolsep-3\arrayrulewidth\relax} |}
\caption{Ficha Técnica de Evaluación de Experiencia de Usuario según Heurísticas} \label{tbl:ficha-tecnica-heuristicas} \\
\hline
\thfirst{Campo de Información} & \thcell{Detalle Registrado} \\
\hline
\endfirsthead
\hline
\thfirst{Campo de Información} & \thcell{Detalle Registrado} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
\textbf{Carrera} & Ingeniería de Software \\
\hline
\textbf{Curso} & 1acc0238 Aplicaciones para dispositivos móviles \\
\hline
\textbf{NRC} & 4951 \\
\hline
\textbf{Profesores} & Todos \\
\hline
\textbf{Auditor} & Equipo de Ingeniería Andeva (Atelier Software Team) \\
\hline
\textbf{Clientes y Participantes} & Jorge Antonio Aguilar Perez, Marcelo Alejandro Silva Ramos, Carlos Alberto Mendoza Rivas, César Nikolay Montero Vega, Bruno Marcelo Pacheco Díaz y Angie Karol Choque Pura \\
\hline
\textbf{Artefactos Evaluados} & Portal web comercial Atelier Website y aplicación móvil nativa Android Atelier Workshop Mobile \\
\hline
\end{longtable}

_Nota._ Ficha técnica estructurada según el estándar del proyecto para evaluación de experiencia de usuario.

**Tareas Evaluadas y Tareas Fuera de Alcance**

El alcance de la presente evaluación comprende la verificación técnica y de interacción de las siguientes tareas clave:

1. Registro e inicio de sesión institucional con validación de código numérico OTP.
2. Marcación de asistencia satelital con verificación de geocerca geodésica.
3. Búsqueda y vinculación vehicular por placa de rodaje en patio.
4. Creación de orden de trabajo y registro de evidencias periciales fotográficas en 360 grados.
5. Emisión de proforma comercial digital en formato PDF con cálculo imponible automático.
6. Notificación y registro formal de la resolución de presupuesto comunicada por el cliente.
7. Consulta, priorización y control de cronómetro de tareas mecánicas en bahía con pausas operativas.
8. Búsqueda de piezas en catálogo de almacén y descargo de inventario bajo el método estricto FIFO por lote.

Quedan expresamente excluidas del alcance de esta versión las siguientes tareas operativas:

1. Captura de parámetros sensoriales en vivo mediante escáner OBD2 acoplado a Bluetooth.
2. Emisión y despacho fiscal directo de comprobantes electrónicos UBL 2.1 hacia la autoridad tributaria.
3. Procesamiento de cobros recurrentes de suscripción de talleres mediante pasarelas bancarias externas.
4. Parametrización avanzada de múltiples sucursales simultáneas desde la aplicación móvil.

**Escala de Severidad de Problemas**

Para graduar el impacto de los hallazgos identificados durante la interacción de los usuarios, se aplica la escala estándar de severidad de cuatro niveles:

- **Nivel 1 (Problema superficial):** Dificultad estética o de menor impacto que puede ser superada fácilmente por el usuario y ocurre con muy baja frecuencia. No requiere corrección inmediata a menos que exista disponibilidad de tiempo.
- **Nivel 2 (Problema menor):** Dificultad operativa que puede presentarse con mayor frecuencia o demanda un esfuerzo adicional de comprensión. Se le asigna prioridad baja para resolución en el siguiente ciclo de despliegue.
- **Nivel 3 (Problema mayor):** Fricción que ocurre con frecuencia o bloquea la resolución autónoma por parte del usuario. Es prioritario corregirla antes del lanzamiento.
- **Nivel 4 (Problema muy grave):** Defecto crítico que imposibilita al usuario completar una tarea esencial del negocio. Es imperativo subsanarlo de manera inmediata antes de autorizar el paso a producción.

**Tabla Resumen de Problemas Identificados**

A continuación, la @tbl:resumen-evaluacion-heuristicas consolida la relación de incidencias detectadas, vinculando cada hallazgo con el principio de diseño correspondiente y su nivel de severidad asignado:

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\centering\arraybackslash}p{0.8cm} | >{\raggedright\arraybackslash}p{6.4cm} | >{\raggedright\arraybackslash}p{5.4cm} | >{\centering\arraybackslash}p{\dimexpr\textwidth-12.6cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Tabla Resumen de Evaluación de Experiencia de Usuario según Heurísticas} \label{tbl:resumen-evaluacion-heuristicas} \\
\hline
\thfirst{\#} & \thcell{Problema Identificado} & \thcell{Heurística o Principio Violado} & \thcell{Escala de Severidad} \\
\hline
\endfirsthead
\hline
\thfirst{\#} & \thcell{Problema Identificado} & \thcell{Heurística o Principio Violado} & \thcell{Escala de Severidad} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
1 & Ausencia de indicador visual de sincronización pendiente al operar sin conexión & Usabilidad: Visibilidad del estado del sistema & 3 \\
\hline
2 & Falta de diálogo de confirmación previo a descartar el cronómetro de una tarea & Usabilidad: Prevención de errores & 3 \\
\hline
3 & Inexistencia de opción para revertir un descargo de repuesto por lote equivocado & Usabilidad: Control y libertad del usuario & 3 \\
\hline
4 & Contraste tipográfico insuficiente en textos secundarios en entornos con alta luz solar & Diseño inclusivo: Considerar la situación & 2 \\
\hline
5 & Ausencia de soporte para búsqueda de repuestos mediante fragmentos parciales de código & Arquitectura de información: Organización y búsqueda & 2 \\
\hline
6 & Nomenclatura contable compleja en el desglose de proforma para clientes particulares & Usabilidad: Correspondencia entre el sistema y el mundo real & 2 \\
\hline
7 & Imágenes del portal comercial sin textos descriptivos para tecnologías de asistencia & Diseño inclusivo: Proporcionar experiencias comparables & 2 \\
\hline
8 & Selector de fotografías periciales sin aviso previo del tope máximo de archivos & Arquitectura de información: Claridad de etiquetado y navegación & 1 \\
\hline
\end{longtable}

_Nota._ Consolidación de problemas de experiencia de usuario clasificados según severidad y principio técnico.

\newpage

**Descripción Detallada de Problemas**

A continuación se presenta el desglose individual de cada incidencia identificada, precisando su contexto de manifestación, impacto en la tarea y la recomendación técnica para su subsanación:

**Problema 1: Ausencia de indicador visual de sincronización pendiente al operar sin conexión**

- **Severidad:** 3 (Problema mayor).
- **Heurística o principio violado:** Usabilidad de Nielsen: Visibilidad del estado del sistema.
- **Descripción del problema:** Al registrar una inspección pericial o iniciar una tarea mecánica en áreas del taller sin cobertura de red inalámbrica, como fosos de alineamiento o sótanos, la aplicación móvil guarda la información localmente en SQLite pero no presenta una insignia gráfica visible que advierta al usuario que los cambios se encuentran pendientes de sincronización con el servidor central. Esta omisión genera incertidumbre en el mecánico, quien intenta reenviar la orden repetidamente creyendo que la acción no fue procesada.
- **Evidencia visual:**

\begin{center}
\fbox{\parbox[c][3.2cm][c]{0.92\linewidth}{\centering\footnotesize\textit{[Espacio para captura de pantalla: Cabecera de la aplicación móvil sin indicador de sincronización pendiente en fosa]}}}
\end{center}

- **Recomendación de solución:** Implementar una barra de estado contextual en la parte superior de la pantalla mediante Jetpack Compose. Dicho componente debe reflejar un icono de nube con flechas circulares en tono ámbar cuando existan mutaciones almacenadas en la base de datos Room pendientes de despacho, cambiando a un icono verde de confirmación una vez que el servicio en segundo plano sincronice exitosamente los datos con la API RESTful.

**Problema 2: Falta de diálogo de confirmación previo a descartar el cronómetro de una tarea**

- **Severidad:** 3 (Problema mayor).
- **Heurística o principio violado:** Usabilidad de Nielsen: Prevención de errores.
- **Descripción del problema:** Durante el cronometraje de faenas mecánicas en bahía, el botón para detener y descartar la medición de labor se encuentra adyacente al control de pausa operativa. Si el técnico presiona por equivocación el botón de reinicio mientras manipula el teléfono con guantes de nitrilo, el conteo acumulado de minutos se pierde de forma inmediata sin solicitar confirmación, distorsionando el registro de productividad laboral del turno.
- **Evidencia visual:**

\begin{center}
\fbox{\parbox[c][3.2cm][c]{0.92\linewidth}{\centering\footnotesize\textit{[Espacio para captura de pantalla: Panel de cronómetro de bahía con botones contiguos de pausa y reinicio]}}}
\end{center}

- **Recomendación de solución:** Introducir un diálogo modal de confirmación con doble acción que requiera ratificar la cancelación del cronometraje activo. Adicionalmente, se recomienda reubicar el botón de detención definitiva separándolo físicamente del control de pausa y aplicar un retraso de pulsación prolongada de dos segundos para prevenir ejecuciones accidentales en el área de trabajo.

**Problema 3: Inexistencia de opción para revertir un descargo de repuesto por lote equivocado**

- **Severidad:** 3 (Problema mayor).
- **Heurística o principio violado:** Usabilidad de Nielsen: Control y libertad del usuario.
- **Descripción del problema:** Al efectuar el despacho de materiales desde el catálogo móvil, si el encargado selecciona por error un insumo similar o digita una cantidad mayor a la solicitada por el mecánico, el sistema aplica la imputación contable al lote FIFO más antiguo sin ofrecer una vía directa de anulación dentro de los primeros minutos tras la acción. Para corregir la equivocación, el usuario debe salir del módulo de despacho y registrar un movimiento manual de reincorporación, incrementando el tiempo de operación en almacén.
- **Evidencia visual:**

\begin{center}
\fbox{\parbox[c][3.2cm][c]{0.92\linewidth}{\centering\footnotesize\textit{[Espacio para captura de pantalla: Pantalla de confirmación de descargo FIFO sin acción de deshacer]}}}
\end{center}

- **Recomendación de solución:** Añadir un mensaje emergente de tipo barra de aviso temporal con la acción explícita de deshacer, activo durante diez segundos posteriores a la transacción. Esta acción debe revertir atómicamente la mutación en la base de datos local y restituir las cantidades al lote cronológico original antes del cierre del lote de trabajo.

**Problema 4: Contraste tipográfico insuficiente en textos secundarios en entornos con alta luz solar**

- **Severidad:** 2 (Problema menor).
- **Heurística o principio violado:** Diseño inclusivo: Considerar la situación y contexto operativo.
- **Descripción del problema:** En patios abiertos de recepción vehicular expuestos a radiación solar intensa, los textos descriptivos secundarios de las tarjetas de vehículos (como el código de motor y el año de fabricación) presentan una relación de contraste cromático de 3.2:1 con respecto al fondo, situándose por debajo del estándar accesible. Esto obliga al recepcionista a forzar la vista o buscar zonas techadas para verificar los datos de la unidad.
- **Evidencia visual:**

\begin{center}
\fbox{\parbox[c][3.2cm][c]{0.92\linewidth}{\centering\footnotesize\textit{[Espacio para captura de pantalla: Tarjeta de recepción vehicular en patio con bajo contraste en textos auxiliares]}}}
\end{center}

- **Recomendación de solución:** Ajustar los tokens de color del sistema de diseño en la directiva de estilos móviles, elevando el valor de luminancia de los textos secundarios para alcanzar una relación de contraste mínima de 4.5:1 conforme a las pautas de accesibilidad WCAG 2.1 nivel AA. Asimismo, habilitar la detección de sensores de luminosidad del dispositivo para elevar dinámicamente el brillo del componente en patios exteriores.

**Problema 5: Ausencia de soporte para búsqueda de repuestos mediante fragmentos parciales de código**

- **Severidad:** 2 (Problema menor).
- **Heurística o principio violado:** Arquitectura de información: Organización y búsqueda.
- **Descripción del problema:** El campo de búsqueda en el catálogo de almacén requiere ingresar la secuencia alfanumérica exacta de la pieza o su denominación completa para mostrar resultados. Cuando el técnico conoce únicamente los dígitos centrales del código de parte del fabricante, la consulta retorna una lista vacía, impidiendo localizar el repuesto con agilidad.
- **Evidencia visual:**

\begin{center}
\fbox{\parbox[c][3.2cm][c]{0.92\linewidth}{\centering\footnotesize\textit{[Espacio para captura de pantalla: Buscador de catálogo con mensaje de coincidencia no encontrada ante código parcial]}}}
\end{center}

- **Recomendación de solución:** Optimizar la consulta en el DAO de Room incorporando el operador de concordancia parcial sobre los campos de código de parte y descripción comercial. Complementariamente, incorporar un mecanismo de sugerencias automáticas a partir del tercer carácter ingresado en la barra de texto.

**Problema 6: Nomenclatura contable compleja en el desglose de proforma para clientes particulares**

- **Severidad:** 2 (Problema menor).
- **Heurística o principio violado:** Usabilidad de Nielsen: Correspondencia entre el sistema y el mundo real.
- **Descripción del problema:** La proforma digital emitida para consulta del cliente final utiliza etiquetas tributarias técnicas como base gravable imponible y valor de afectación en lugar de términos cotidianos comprensibles como subtotal de mano de obra y costo de piezas. Los propietarios particulares manifestaron confusión al interpretar el monto total a cancelar en la entrevista de validación.
- **Evidencia visual:**

\begin{center}
\fbox{\parbox[c][3.2cm][c]{0.92\linewidth}{\centering\footnotesize\textit{[Espacio para captura de pantalla: Desglose de proforma comercial en PDF con terminología fiscal compleja]}}}
\end{center}

- **Recomendación de solución:** Simplificar el membrete de la plantilla de cotización generada con OpenPDF, presentando un resumen jerárquico articulado en conceptos claros: mano de obra técnica, repuestos e insumos, e impuesto general a las ventas. La información fiscal detallada debe conservarse únicamente en la sección de pie de página destinada a fines contables formales.

**Problema 7: Imágenes del portal comercial sin textos descriptivos para tecnologías de asistencia**

- **Severidad:** 2 (Problema menor).
- **Heurística o principio violado:** Diseño inclusivo: Proporcionar experiencias comparables.
- **Descripción del problema:** En el portal web comercial Atelier Website, diversas imágenes ilustrativas de los módulos de diagnóstico telemático y telemetría predictiva carecen del atributo textual descriptivo en su marcado HTML. En consecuencia, los lectores de pantalla utilizados por usuarios con discapacidad visual omiten la explicación del contenido gráfico, limitando la comprensión integral de las funciones presentadas.
- **Evidencia visual:**

\begin{center}
\fbox{\parbox[c][3.2cm][c]{0.92\linewidth}{\centering\footnotesize\textit{[Espacio para captura de pantalla: Código de marcado del portal web con etiquetas de imagen sin atributo de texto alternativo]}}}
\end{center}

- **Recomendación de solución:** Añadir textos alternativos específicos y concisos en todas las etiquetas de imagen del portal comercial, describiendo con exactitud la escena operativa o el diagrama de software que se ilustra. Para elementos puramente decorativos, aplicar el atributo vacío correspondiente a fin de que las herramientas de accesibilidad los ignoren sin emitir alertas de lectura.

**Problema 8: Selector de fotografías periciales sin aviso previo del tope máximo de archivos**

- **Severidad:** 1 (Problema superficial).
- **Heurística o principio violado:** Arquitectura de información: Claridad de etiquetado y navegación.
- **Descripción del problema:** Durante el registro pericial de recepción en patio, la cuadrícula de captura fotográfica permite al recepcionista tomar imágenes de forma sucesiva sin indicar anticipadamente cuál es el número máximo de fotografías admitidas por orden. Al alcanzar la octava fotografía, el botón de captura se desactiva sin un mensaje informativo que comunique que se ha completado el cupo permitido.
- **Evidencia visual:**

\begin{center}
\fbox{\parbox[c][3.2cm][c]{0.92\linewidth}{\centering\footnotesize\textit{[Espacio para captura de pantalla: Cuadrícula pericial de recepción con botón de captura desactivado sin mensaje explicativo]}}}
\end{center}

- **Recomendación de solución:** Incorporar un contador visual permanente en la cabecera de la cuadrícula fotográfica, indicando la cantidad de capturas registradas frente al total permitido. Al completar el límite, el sistema debe presentar un aviso informativo breve que señale que la documentación pericial del vehículo ha alcanzado la capacidad establecida para la orden.
