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

En esta sección se presenta el registro y la evidencia audiovisual de la entrevista de validación realizada para contrastar las funcionalidades implementadas de la aplicación móvil nativa Atelier Workshop Mobile en entorno Android. La sesión combina la demostración guiada de los flujos operativos implementados con la observación directa y la recolección de retroalimentación sobre claridad visual, fluidez de navegación y adecuación al trabajo diario en taller.

La grabación completa de la sesión se encuentra publicada bajo el archivo **upc-pre-202620-1acc0238-4951-andeva-validation-av2.mp4** en el repositorio institucional de OneDrive mediante el enlace [Video de Validación (OneDrive)](https://upcedupe-my.sharepoint.com/:v:/g/personal/u20241e275_upc_edu_pe/IQCQRQCfuCkRQa3nnu0yYI84AU4-p88XucMGEwW7cCKEdks?nav=eyJyZWZlcnJhbEluZm8iOnsicmVmZXJyYWxBcHAiOiJPbmVEcml2ZUZvckJ1c2luZXNzIiwicmVmZXJyYWxBcHBQbGF0Zm9ybSI6IldlYiIsInJlZmVycmFsTW9kZSI6InZpZXciLCJyZWZlcnJhbFZpZXciOiJNeUZpbGVzTGlua0NvcHkifX0&e=az7Ef4). El registro detalla los datos demográficos del participante, la duración de la sesión, la captura de evidencia de la videollamada y la síntesis de las observaciones expresadas durante la interacción.

**Segmento 2: Personal Operativo del Taller**

A continuación se presenta el registro correspondiente a la validación realizada con el representante del equipo técnico operativo del taller:

\begin{table}[H]
\centering
\caption{Entrevista de Validación a Bruno Marcelo Pacheco Díaz}
\label{tbl:entrevista-val-s2-1}
\renewcommand{\arraystretch}{1.3}
\begin{tabularx}{\textwidth}{| p{\dimexpr0.5\textwidth-2\tabcolsep-1.5\arrayrulewidth\relax} | >{\centering\arraybackslash}m{\dimexpr0.5\textwidth-2\tabcolsep-1.5\arrayrulewidth\relax} |}
\hline
\thfirst{Datos del entrevistado} & \multirow{6}{\dimexpr0.5\textwidth-2\tabcolsep-1.5\arrayrulewidth\relax}{\centering\includegraphics[width=0.92\linewidth, height=4.2cm, keepaspectratio]{report/assets/validation-interviews/validation-interview-1.png}} \\
\cline{1-1}
\textbullet\ \textbf{Nombre:} Bruno Marcelo \newline
\textbullet\ \textbf{Apellidos:} Pacheco Díaz \newline
\textbullet\ \textbf{Edad:} 25 años \newline
\textbullet\ \textbf{Distrito:} Chorrillos \newline
\textbullet\ \textbf{Duración:} 00:00 min a 05:30 min
\vspace{2pt}
& \\
\hline
\thspanfirst{2}{Resumen de la entrevista} \\
\hline
\multicolumn{2}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
El participante evaluó el flujo operativo de la aplicación móvil nativa Atelier Workshop Mobile ejecutada en entorno Android. Durante el recorrido guiado revisó la marcación de asistencia mediante validación de perímetro geográfico con tolerancia de quince minutos, el reporte semanal de días laborados, la gestión de tareas técnicas en pausa o asignadas, el inventario de escáneres OBD-II por Bluetooth y las opciones de perfil con sincronización sin conexión. Asimismo, exploró el cambio de sucursal, la recepción de clientes y vehículos por placa o documento de identidad, la disponibilidad de bahías de trabajo, el catálogo con lotes de repuestos y las notificaciones de nuevas tareas. El técnico valoró positivamente la utilidad integral de la aplicación para la gestión diaria del taller, destacando de forma particular la conectividad Bluetooth para escáneres y el control de asistencia por perímetro. Como oportunidad de mejora, sugirió incorporar un tutorial inicial que explique la función de cada botón para facilitar la ruta de aprendizaje al comenzar a utilizar la aplicación.
} \\
\hline
\multicolumn{2}{|p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}|}{%
\textbf{Enlace:} \href{https://upcedupe-my.sharepoint.com/:v:/g/personal/u20241e275_upc_edu_pe/IQCQRQCfuCkRQa3nnu0yYI84AU4-p88XucMGEwW7cCKEdks?nav=eyJyZWZlcnJhbEluZm8iOnsicmVmZXJyYWxBcHAiOiJPbmVEcml2ZUZvckJ1c2luZXNzIiwicmVmZXJyYWxBcHBQbGF0Zm9ybSI6IldlYiIsInJlZmVycmFsTW9kZSI6InZpZXciLCJyZWZlcnJhbFZpZXciOiJNeUZpbGVzTGlua0NvcHkifX0\&e=az7Ef4}{Video de Validación - Entrevista a Bruno Marcelo Pacheco Díaz (OneDrive)}
} \\
\hline
\end{tabularx}
\end{table}

_Nota._ Registro de entrevista de validación correspondiente al Segmento 2.

\newpage

### 4.3.3. _Evaluaciones según heurísticas_

En esta sección se documenta la evaluación formal de la experiencia de usuario de la aplicación móvil nativa Atelier Workshop Mobile. La evaluación adopta el formato estándar establecido en el Anexo E del proyecto, estructurando el análisis en tres dimensiones fundamentales: heurísticas de usabilidad de Jakob Nielsen, principios de arquitectura de información y directrices de diseño inclusivo.

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
\textbf{Curso} & 1ACC0238 Aplicaciones para Dispositivos Móviles \\
\hline
\textbf{NRC} & 4951 \\
\hline
\textbf{Profesores} & Jorge Luis Mayta Guillermo \\
\hline
\textbf{Auditor} & Equipo de Ingeniería Andeva \\
\hline
\textbf{Clientes y Participantes} & Bruno Marcelo Pacheco Díaz \\
\hline
\textbf{Artefactos Evaluados} & Aplicación móvil nativa Android Atelier Workshop Mobile \\
\hline
\end{longtable}

_Nota._ Ficha técnica de la evaluación de experiencia de usuario aplicada sobre el producto móvil.

**Tareas Evaluadas y Tareas Fuera de Alcance**

El alcance de la evaluación comprende la verificación funcional y de interacción de las siguientes tareas operativas en Atelier Workshop Mobile:

- Marcación de ingreso laboral con validación de perímetro geográfico, tolerancia de tardanza de quince minutos y consulta del reporte semanal de asistencia.
- Consulta del listado de tareas técnicas asignadas, en pausa y completadas desde la pantalla de inicio.
- Revisión del inventario de escáneres OBD-II por Bluetooth, filtrado por estado operativo, cambio de estado y desvinculación de unidades asociadas a vehículos.
- Gestión de configuraciones de perfil, verificación de sucursal activa, habilitación de sincronización sin conexión y cierre de sesión.
- Navegación directa para confirmación o cambio de sede y recepción de clientes y vehículos por número de placa o documento nacional de identidad.
- Consulta de la cartera de clientes y vehículos registrados, estado de ocupación de bahías de trabajo, catálogo de repuestos por lotes y alertas de reposición.
- Visualización de notificaciones ante la asignación de nuevas tareas técnicas.

Quedan expresamente excluidas del alcance de esta evaluación las siguientes tareas operativas:

- Captura de códigos de falla y telemetría vehicular en tiempo real acoplada a un vehículo físico en campo.
- Emisión y despacho fiscal directo de comprobantes electrónicos UBL 2.1 hacia la autoridad tributaria.
- Procesamiento de cobros recurrentes de suscripción de talleres mediante pasarelas bancarias externas.
- Evaluación del portal web comercial Atelier Website en navegador de escritorio.

**Escala de Severidad de Problemas**

Para graduar el impacto de los hallazgos identificados durante la interacción y revisión de la interfaz, se aplica la escala estándar de severidad de cuatro niveles:

- **Nivel 1: Problema superficial.** Dificultad estética o de menor impacto que puede ser superada fácilmente por el usuario y ocurre con muy baja frecuencia. No requiere corrección inmediata a menos que exista disponibilidad de tiempo.
- **Nivel 2: Problema menor.** Dificultad operativa que puede presentarse con mayor frecuencia o demanda un esfuerzo adicional de comprensión. Se le asigna prioridad baja para resolución en el siguiente ciclo de despliegue.
- **Nivel 3: Problema mayor.** Fricción que ocurre con frecuencia o bloquea la resolución autónoma por parte del usuario. Es prioritario corregirla antes del lanzamiento.
- **Nivel 4: Problema muy grave.** Defecto crítico que imposibilita al usuario completar una tarea esencial del negocio. Es imperativo subsanarlo de manera inmediata antes de autorizar el paso a producción.

**Tabla Resumen de Problemas Identificados**

A continuación, la @tbl:resumen-evaluacion-heuristicas consolida la relación de incidencias detectadas durante la sesión de validación y la inspección de interfaz, vinculando cada hallazgo con el principio de diseño correspondiente y su nivel de severidad asignado:

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
1 & Ausencia de tutorial inicial y guía contextual sobre la función de botones y módulos & Usabilidad: Ayuda y documentación & 2 \\
\hline
2 & Ambigüedad entre los accesos rápidos de la pantalla de inicio, perfil y navegación directa & Arquitectura de información: Claridad de etiquetado y navegación & 2 \\
\hline
3 & Exposición de identificadores técnicos internos y jerarquía invertida de acciones en escáneres OBD-II & Usabilidad: Correspondencia entre el sistema y el mundo real & 2 \\
\hline
\end{longtable}

_Nota._ Consolidación de problemas de experiencia de usuario clasificados según severidad y principio técnico.

\newpage

**Descripción Detallada de Problemas**

A continuación se presenta el desglose individual de cada incidencia identificada, precisando su contexto de manifestación, impacto en la tarea y la recomendación técnica para su subsanación:

**Problema 1: Ausencia de tutorial inicial y guía contextual sobre la función de botones y módulos**

- **Severidad:** 2 (Problema menor).
- **Heurística o principio violado:** Usabilidad de Nielsen: Ayuda y documentación.
- **Descripción del problema:** La pantalla de inicio de la aplicación concentra tarjetas de jornada laboral y labor técnica, indicadores resumidos, accesos de operaciones de patio, botones superiores de menú y alertas, y una barra de navegación inferior compuesta por cuatro iconos sin etiquetas textuales. Durante la sesión de validación, el entrevistado manifestó que, al interactuar por primera vez con la interfaz, resulta necesario contar con un tutorial inicial que explique qué función cumple cada botón para facilitar la ruta de aprendizaje sin depender de explicaciones verbales previas.
- **Evidencia visual:** Como se muestra en la @fig:heuristica-problema-1, la vista principal carece de un recorrido de inducción inicial o botón de ayuda contextual que oriente sobre el propósito de los controles y la barra inferior iconográfica.

![Pantalla de inicio de Atelier Workshop Mobile sin guía de inducción inicial ni etiquetas en la barra inferior](report/assets/validation-interviews/problem-1.png){#fig:heuristica-problema-1 width=36%}

_Nota._ Captura de la pantalla principal evaluada en Atelier Workshop Mobile.

- **Recomendación de solución:** Implementar un recorrido guiado de inducción en el primer inicio de sesión mediante Jetpack Compose que destaque secuencialmente los controles principales de asistencia, labor técnica, operaciones de patio y navegación inferior. Complementariamente, incorporar etiquetas textuales bajo los iconos de la barra de navegación y un acceso de ayuda rápida desde la cabecera o la sección de perfil.

**Problema 2: Ambigüedad entre los accesos rápidos de la pantalla de inicio, perfil y navegación directa**

- **Severidad:** 2 (Problema menor).
- **Heurística o principio violado:** Arquitectura de información: Claridad de etiquetado y navegación.
- **Descripción del problema:** La aplicación duplica puntos de acceso hacia las mismas funcionalidades operativas entre la pantalla de inicio, el menú lateral, la barra inferior y la vista de perfil. En particular, la opción **Bandeja de notificaciones** se encuentra anidada dentro del bloque de operaciones y sincronización en la pantalla de perfil a pesar de existir un icono de campana en la cabecera superior, y el módulo de escáneres OBD-II figura tanto en operaciones de patio como en la barra inferior, lo que exigió aclaraciones adicionales durante la entrevista sobre el propósito de cada ruta.
- **Evidencia visual:** En la @fig:heuristica-problema-2 se observa la vista de perfil con la bandeja de notificaciones agrupada junto a la cola de sincronización y los permisos del rol, coexistiendo con los accesos equivalentes de la pantalla principal.

![Vista de perfil con acceso a bandeja de notificaciones anidado en operaciones y sincronización](report/assets/validation-interviews/problem-2.png){#fig:heuristica-problema-2 width=36%}

_Nota._ Captura de la sección de perfil y rutas de acceso en Atelier Workshop Mobile.

- **Recomendación de solución:** Reorganizar la arquitectura de navegación para reservar la pantalla de inicio al estado operativo inmediato del técnico, restringiendo el perfil estrictamente a datos de cuenta, sede activa, sincronización sin conexión y cierre de sesión. Asimismo, consolidar la bandeja de notificaciones únicamente en el icono de cabecera para eliminar redundancias de rutas.

**Problema 3: Exposición de identificadores técnicos internos y jerarquía invertida de acciones en escáneres OBD-II**

- **Severidad:** 2 (Problema menor).
- **Heurística o principio violado:** Usabilidad de Nielsen: Correspondencia entre el sistema y el mundo real.
- **Descripción del problema:** En el listado de inventario de escáneres OBD-II, cada tarjeta presenta el protocolo de conectividad mediante la constante técnica interna BLUETOOTH_BLE en lugar de una denominación comprensible para el mecánico automotriz. Adicionalmente, la acción de desvinculación del dispositivo respecto al vehículo asignado recibe mayor énfasis visual mediante un botón con contorno prominente frente al enlace en texto plano para cambiar de estado, invirtiendo la jerarquía esperada entre la operación habitual y la acción de mayor impacto operativo.
- **Evidencia visual:** Como se aprecia en la @fig:heuristica-problema-3, las tarjetas exhiben la cadena técnica BLUETOOTH_BLE junto al botón destacado de desvinculación sin advertencia previa.

![Listado de escáneres OBD-II con identificador técnico BLUETOOTH_BLE y botón de desvinculación destacado](report/assets/validation-interviews/problem-3.png){#fig:heuristica-problema-3 width=36%}

_Nota._ Captura del módulo de inventario de escáneres OBD-II en Atelier Workshop Mobile.

- **Recomendación de solución:** Mapear el enumerado interno de conectividad hacia una etiqueta legible en lenguaje natural, como Bluetooth Low Energy, y ajustar la jerarquía visual de los botones otorgando el estilo principal o secundario al cambio de estado operativo. Para la acción de desvinculación, aplicar un estilo discreto acompañado de un diálogo breve de confirmación antes de desligar el escáner del vehículo.
