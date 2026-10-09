### 3.1.4. *Mobile Applications UX/UI Design*



#### 3.1.4.1. Mobile Applications Wireframes

En esta sección se presentarán los wireframes de la aplicación, los cuales son bosquejos de baja fidelidad sobre las funcionalidades principales de nuestra solución. El objetivo es mostrar la estructura, distribución de elementos y jerarquía de la información sin la intervención de colores o detalles gráficos. Para el proyecto Atelier Workshop, se han dividido estos wireframes en diez secciones estructurales.

**Sección Autenticación y Bienvenida**

![Wireframes del flujo de inicio de sesión y selección de sede.](report/assets/MobileApplications-Wireframes/autenticacion.png){#fig:wireframe-autenticacion}

Esta imagen presenta el flujo de acceso estructurado en tres pantallas. La primera pantalla muestra un contenedor superior para el isotipo, seguido de un formulario clásico con campos de texto para correo institucional y contraseña, finalizando con un botón primario ancho. La segunda pantalla presenta una lista de opciones utilizando tarjetas (cards) con selectores radiales (radio buttons) para elegir la sede operativa. La tercera pantalla establece el diseño del dashboard del usuario, con un saludo superior, tarjetas de información del turno y un botón de acción principal ("Registrar entrada").

**Sección Marcación de Asistencia**

![Wireframes del módulo de control de asistencia por GPS.](report/assets/MobileApplications-Wireframes/asistencia.png){#fig:wireframe-asistencia}

Esta imagen exhibe la estructura del registro de geolocalización en dos estados. El diseño de las pantallas se divide en una mitad superior que contiene un bloque cuadrado grande reservado para la integración del mapa interactivo y un indicador de radio (geocerca). La mitad inferior organiza la información en tarjetas de texto (distancia, turno asignado y tolerancias) y culmina con un botón fijo en la parte inferior de la pantalla que cambia su estado (habilitado/bloqueado) según la ubicación.

**Sección Recepción y Órdenes de Trabajo**

![Wireframes de recepción vehicular y formulario de orden.](report/assets/MobileApplications-Wireframes/recepcion.png){#fig:wireframe-recepcion}

Esta imagen muestra las tres pantallas del flujo de ingreso. La primera pantalla destaca una barra de búsqueda superior dividida por pestañas (Placa / DNI) y un área amplia para desplegar resultados en forma de lista. La segunda pantalla presenta el formulario estructurado para crear la orden, el cual contiene campos de entrada numérica (kilometraje), un área de texto expansible con ícono de dictado por voz para los síntomas, y una sección de lista interactiva para agregar las tareas iniciales, finalizando con la vista de confirmación del ticket generado.

**Sección Diagnóstico OBD-II**

![Wireframes del escaneo de códigos de falla.](report/assets/MobileApplications-Wireframes/diagnostico.png){#fig:wireframe-obd}

Esta imagen detalla la interfaz técnica de diagnóstico en tres vistas. Inicia con una pantalla que tiene un ícono central grande de estado Bluetooth. La segunda pantalla muestra la estructura de una lista de dispositivos encontrados, organizados en filas con íconos de intensidad de señal a la derecha. La tercera pantalla presenta el resultado del escaneo, organizando los códigos de falla (DTC) en una lista vertical estructurada, donde cada ítem tiene un título en negrita (el código), una descripción y etiquetas de estado alineadas a la derecha.

**Sección Gestión de Tareas**

![Wireframes del listado de tareas y cronómetro operativo.](report/assets/MobileApplications-Wireframes/tareas.png){#fig:wireframe-tareas}

Esta imagen ilustra la distribución operativa del técnico. La primera pantalla implementa un menú de navegación por pestañas (Tabs) en la parte superior para filtrar vehículos, organizando el contenido en tarjetas con información clave. La segunda pantalla (vista de detalle) reserva el espacio central para un temporizador numérico de gran tamaño y una barra de progreso horizontal, seguidos de secciones desplegables o modales para registrar evidencias fotográficas mediante cajas de marcado (checkboxes) e imputar repuestos.

**Sección Inventario y Repuestos**

![Wireframes del catálogo de almacén y consumo.](report/assets/MobileApplications-Wireframes/inventario.png){#fig:wireframe-inventario}

Esta imagen muestra la disposición del catálogo de almacén. La estructura principal recae en una barra de búsqueda superior y una lista vertical de tarjetas. Cada tarjeta de repuesto muestra el nombre alineado a la izquierda y un indicador de stock a la derecha. La pantalla de imputación destaca por su componente de interfaz centrado: un selector de cantidad numérico flanqueado por botones de incremento y decremento redondos (`-` y `+`), optimizado para el uso rápido con guantes en el taller.

**Sección Tablero de Bahías**

![Wireframes de la grilla de control de espacios físicos.](report/assets/MobileApplications-Wireframes/bahias.png){#fig:wireframe-bahias}

Esta imagen presenta la estructura del panel de control de espacios físicos. La pantalla principal utiliza un diseño de cuadrícula (grid) de dos columnas, donde cada bloque representa una bahía o elevador. Visualmente, el wireframe diferencia las bahías ocupadas de las libres mediante la presencia o ausencia de campos de texto en su interior. La segunda pantalla muestra un modal tipo "bottom sheet" (hoja inferior) que emerge para mostrar detalles operativos y un menú desplegable para reasignar el vehículo de espacio.

**Sección Proforma y Resolución**

![Wireframes de cotización y respuesta del cliente.](report/assets/MobileApplications-Wireframes/proforma.png){#fig:wireframe-proforma}

Esta imagen detalla la interfaz comercial de cotizaciones. La primera vista simula un documento estructurado, alineando los conceptos (tareas y repuestos) a la izquierda y los montos a la derecha, sumando subtotales e impuestos en la base. Las pantallas siguientes presentan botones condicionales amplios para aceptar o rechazar el servicio, y muestran un cuadro de diálogo (modal central) con un campo de texto obligatorio para justificar las cancelaciones.

**Sección Emisión SUNAT**

![Wireframes del proceso de facturación electrónica.](report/assets/MobileApplications-Wireframes/sunat.png){#fig:wireframe-sunat}

Esta imagen ilustra la estructura de integración fiscal. Muestra un flujo simple que comienza con un indicador de carga central (spinner). La pantalla de éxito presenta un ícono de verificación grande (check), seguido de una tabla de datos simplificada (clave-valor) que lista el número de comprobante, el total y el código Hash, culminando con botones secundarios esquemáticos para descargar representaciones impresas (PDF/XML).

**Sección Facturación y Entrega**

![Wireframes de la pasarela de cobro y validación de salida.](report/assets/MobileApplications-Wireframes/facturacion.png){#fig:wireframe-facturacion}

Esta imagen exhibe la estructura de cierre del servicio. La primera pantalla divide el cobro: una sección superior con la barra de saldo restante, botones segmentados horizontales para el método de pago, y un campo de entrada numérica. La pantalla final de entrega presenta un checklist estructural en la parte superior, un área rectangular amplia (canvas) vacía designada para la firma táctil, y termina con un bloque cuadrado central cruzado por una "X" (o entramado) que representa el código QR del pase de salida generado.

#### 3.1.4.2. Mobile Applications Wireflow Diagrams

Un wireflow o flujo de pantalla es un diagrama donde se reúnen distintos wireframes realizados cuya finalidad es contar las metas del usuario con la aplicación y cómo las consiguen. Luego, los pasos para la creación de cada diagrama empiezan por la definición de un objetivo del usuario que desea cumplir. Luego, se define el flujo de tareas que deben ser realizadas por el usuario en la aplicación para conseguir dicho objetivo. Y, finalmente, se traducen dichas tareas por pantallas en baja fidelidad (blanco y negro) y, también, se trazan decisiones en botones del wireframe.

- **User Goal 1:** Usuario (Técnico o Administrador) desea iniciar sesión en su cuenta

Primero, se definen las tareas típicas que realizaría un usuario para completar este objetivo:

![Taskflow de inicio de sesión.](report/assets/taskflows/taskflow_1.png){#fig:taskflow-1}

Luego, se muestra el resultado de la traducción de acción a pantallas. A continuación, en este flujo se muestra el proceso para iniciar sesión en la aplicación. El usuario ingresa sus credenciales en la pantalla de login, selecciona su sede de trabajo y finalmente accede a la pantalla principal de su perfil.

![Wireflow de inicio de sesión.](report/assets/wireflows/wireflow_1.png){#fig:wireflow-1}

- **User Goal 2:** Usuario desea recuperar su contraseña olvidada

Primero, se definen las tareas típicas que realizaría un usuario para completar este objetivo:

![Taskflow de recuperación de contraseña.](report/assets/taskflows/taskflow_2.png){#fig:taskflow-2}

Luego, se muestra el resultado de la traducción de acción a pantallas. A continuación, en este flujo se muestra el proceso para recuperar la contraseña de una cuenta. Para ello, el usuario accede a la opción de recuperación, coloca su correo institucional, y mediante un enlace de verificación procede a registrar y confirmar su nueva clave de acceso.

![Wireflow de recuperación de contraseña.](report/assets/wireflows/wireflow_2.png){#fig:wireflow-2}

- **User Goal 3:** Técnico automotriz desea registrar su asistencia mediante geolocalización

Primero, se definen las tareas típicas que realizaría un usuario para completar este objetivo:

![Taskflow de marcación de asistencia.](report/assets/taskflows/taskflow_3.png){#fig:taskflow-3}

Luego, se muestra el resultado de la traducción de acción a pantallas. A continuación, en este flujo se muestra el proceso para registrar la entrada al taller. El técnico accede al módulo de asistencia, el sistema valida su ubicación física dentro de la geocerca permitida y, al confirmar, se registra su hora de ingreso en el sistema.

![Wireflow de marcación de asistencia.](report/assets/wireflows/wireflow_3.png){#fig:wireflow-3}

- **User Goal 4:** Administrador o Asesor desea recibir un vehículo y aperturar una Orden de Trabajo (OT)

Primero, se definen las tareas típicas que realizaría un usuario para completar este objetivo:

![Taskflow de apertura de orden de trabajo.](report/assets/taskflows/taskflow_4.png){#fig:taskflow-4}

Luego, se muestra el resultado de la traducción de acción a pantallas. A continuación, en este flujo se muestra el proceso para la recepción vehicular. El asesor busca el vehículo por su placa, completa el formulario con el kilometraje actual y los síntomas indicados por el cliente, asigna las tareas iniciales y genera el identificador único de la orden.

![Wireflow de apertura de orden de trabajo.](report/assets/wireflows/wireflow_4.png){#fig:wireflow-4}

- **User Goal 5:** Técnico automotriz desea conectar el escáner OBD-II y leer los códigos de falla

Primero, se definen las tareas típicas que realizaría un usuario para completar este objetivo:

![Taskflow de diagnóstico electrónico OBD-II.](report/assets/taskflows/taskflow_5.png){#fig:taskflow-5}

Luego, se muestra el resultado de la traducción de acción a pantallas. A continuación, en este flujo se muestra el proceso para realizar un diagnóstico electrónico. El técnico busca escáneres cercanos por Bluetooth, vincula el dispositivo correcto conectado al auto y ejecuta la lectura para extraer y visualizar los códigos de falla del motor.

![Wireflow de diagnóstico electrónico OBD-II.](report/assets/wireflows/wireflow_5.png){#fig:wireflow-5}

- **User Goal 6:** Técnico automotriz desea imputar (consumir) un repuesto del inventario hacia una tarea activa

Primero, se definen las tareas típicas que realizaría un usuario para completar este objetivo:

![Taskflow de imputación de repuestos.](report/assets/taskflows/taskflow_6.png){#fig:taskflow-6}

Luego, se muestra el resultado de la traducción de acción a pantallas. A continuación, en este flujo se muestra el proceso para asignar repuestos. El técnico, desde la vista de su tarea en progreso, accede al catálogo de inventario, busca el insumo necesario, define la cantidad a consumir y lo agrega directamente a la orden de trabajo.

![Wireflow de imputación de repuestos.](report/assets/wireflows/wireflow_6.png){#fig:wireflow-6}

- **User Goal 7:** Técnico automotriz desea cerrar una tarea completada

Primero, se definen las tareas típicas que realizaría un usuario para completar este objetivo:

![Taskflow de cierre de tarea técnica.](report/assets/taskflows/taskflow_7.png){#fig:taskflow-7}

Luego, se muestra el resultado de la traducción de acción a pantallas. A continuación, en este flujo se muestra el proceso para finalizar una labor. El técnico accede a la pantalla de cierre, verifica que se cumplan las validaciones obligatorias (como el registro de repuestos y captura de fotos de evidencia) y confirma la culminación de la tarea.

![Wireflow de cierre de tarea técnica.](report/assets/wireflows/wireflow_7.png){#fig:wireflow-7}

- **User Goal 8:** Administrador gestiona la resolución de un presupuesto con el cliente

Primero, se definen las tareas típicas que realizaría un usuario para completar este objetivo:

![Taskflow de resolución de presupuesto.](report/assets/taskflows/taskflow_8.png){#fig:taskflow-8}

Luego, se muestra el resultado de la traducción de acción a pantallas. A continuación, en este flujo se muestra el proceso de aprobación comercial. El administrador registra la decisión del cliente sobre la proforma, lo cual permite iniciar los trabajos si es aceptada, o requiere ingresar un motivo de rechazo para cancelar la orden y devolver los repuestos.

![Wireflow de resolución de presupuesto.](report/assets/wireflows/wireflow_8.png){#fig:wireflow-8}

- **User Goal 9:** Administrador desea emitir el comprobante electrónico a SUNAT

Primero, se definen las tareas típicas que realizaría un usuario para completar este objetivo:

![Taskflow de emisión de comprobante fiscal.](report/assets/taskflows/taskflow_9.png){#fig:taskflow-9}

Luego, se muestra el resultado de la traducción de acción a pantallas. A continuación, en este flujo se muestra el proceso de facturación. El administrador procesa la orden completada y el sistema se comunica con el servidor fiscal para generar la boleta o factura, devolviendo la confirmación de éxito con el respectivo código Hash.

![Wireflow de emisión de comprobante fiscal.](report/assets/wireflows/wireflow_9.png){#fig:wireflow-9}

- **User Goal 10:** Administrador desea cobrar el servicio y entregar el vehículo al cliente

Primero, se definen las tareas típicas que realizaría un usuario para completar este objetivo:

![Taskflow de cobro y entrega de vehículo.](report/assets/taskflows/taskflow_10.png){#fig:taskflow-10}

Luego, se muestra el resultado de la traducción de acción a pantallas. A continuación, en este flujo se muestra el proceso final de liberación. El administrador registra los abonos del cliente en la pasarela hasta saldar la cuenta, recolecta la firma digital en pantalla y el sistema genera automáticamente el código QR de pase de salida.

#### 3.1.4.3. Mobile Applications Mock-ups

En esta sección se presentarán los mockups de la aplicación móvil, los cuales son bosquejos de media o alta fidelidad sobre las funcionalidades principales de nuestra solución. Para el diseño de los mockups, se partió de los wireframes realizados previamente.

**Sección Autenticación y Bienvenida**

![Mockups del flujo de Autenticación, inicio de sesión y selección de sede operativa.](report/assets/MobileApplications-Mockups/autenticacion.png){#fig:mockup-autenticacion}

Representa las versiones finales del flujo de acceso a la aplicación para los distintos roles. Se observa la implementación de la paleta de colores corporativa con predominancia del azul sólido y blanco, y el isologotipo de "Atelier Workshop". Incluye la pantalla Splash, el formulario de inicio de sesión con manejo de errores visuales (alertas con fondo rojo claro), y la pantalla de selección de sede que muestra opciones reales (Sede San Isidro, Sede Surquillo, Sede Ate) con indicadores de cantidad de bahías y turnos.

**Sección Marcación de Asistencia**

![Mockups del sistema de marcación de asistencia mediante geocerca GPS.](report/assets/MobileApplications-Mockups/asistencia.png){#fig:mockup-asistencia}

Muestra la versión final del módulo de control de asistencia de los técnicos. Se visualiza la integración de un mapa interactivo que delimita el perímetro del taller mediante una geocerca (círculo azul). La interfaz indica claramente, mediante etiquetas y pines de colores, si el usuario está "Dentro del perímetro" (verde), "Fuera del perímetro" (rojo) o "Sin GPS" (naranja). Además, presenta tarjetas informativas con el turno asignado (ej. 08:00 - 17:00) y el cálculo de la tolerancia de ingreso.

**Sección Recepción y Órdenes de Trabajo**

![Mockups del módulo de recepción vehicular y apertura de órdenes de trabajo.](report/assets/MobileApplications-Mockups/recepcion.png){#fig:mockup-recepcion}

Exhibe el módulo completo para la recepción de vehículos. La interfaz incluye un buscador dual (Placa o DNI/RUC) que, al encontrar coincidencias, despliega información detallada del vehículo (ej. Toyota Hilux 2019, placa ABC-123) y de su propietario. También presenta el formulario final para "Abrir orden" con campos estructurados para el kilometraje actual, ingreso por voz o texto de los síntomas del cliente, y un listado de tareas iniciales, culminando en la pantalla de éxito que genera el identificador único (ej. OT-0424).

**Sección Diagnóstico OBD-II**

![Mockups de la integración con escáner Bluetooth OBD-II y lectura de códigos.](report/assets/MobileApplications-Mockups/diagnostico.png){#fig:mockup-diagnostico}

Presenta el innovador sistema de diagnóstico electrónico completamente diseñado. Incluye las pantallas de búsqueda y vinculación Bluetooth con escáneres (mostrando intensidad de señal en dBm). Destaca la interfaz de "Códigos de falla" que lista los errores extraídos de la computadora (ej. P0301 Fallo de encendido, P0171) con etiquetas de severidad (Actual, Pendiente, Histórico). Además, muestra el "Monitor en tiempo real" que utiliza gráficos de anillo (gauges) y barras de progreso para mostrar métricas en vivo como RPM, temperatura del refrigerante y voltaje, incluyendo alertas críticas.

**Sección Gestión de Tareas**

![Mockups de la vista del técnico, cronómetro de tiempos y cierre de labor con evidencia.](report/assets/MobileApplications-Mockups/tareas.png){#fig:mockup-tareas}

Muestra la interfaz operativa para el técnico automotriz. La pantalla principal "Mis tareas" lista los vehículos asignados agrupados por pestañas (Todas, En curso, Pendientes, Espera). La vista de detalle destaca un cronómetro digital de gran tamaño (ej. 01:25:40) para medir el tiempo real invertido frente al estimado. Finalmente, se visualiza la pantalla de "Cerrar tarea", que implementa validaciones de calidad obligatorias requiriendo confirmación de repuestos consumidos y evidencia fotográfica mediante checkboxes de estado.

**Sección Inventario y Repuestos**

![Mockups del catálogo de repuestos, alertas de stock e imputación a órdenes.](report/assets/MobileApplications-Mockups/inventario.png){#fig:mockup-inventario}

Muestra la versión final del módulo de almacén y consumo. El catálogo principal presenta repuestos categorizados (Bujía NGK Iridium, Aceite 5W-30, Filtro de aire) con etiquetas de inventario dinámicas (verde para stock normal, ámbar para stock bajo, rojo para sin stock). Incluye la interfaz de "Imputar repuesto" con controles numéricos intuitivos (+/-) para añadir productos a una orden en curso, y la vista administrativa detallada de gestión de Lotes FIFO y márgenes de ganancia reales por unidad.

**Sección Tablero de Bahías**

![Mockups del panel de control de bahías y asignación de espacios físicos.](report/assets/MobileApplications-Mockups/bahias.png){#fig:mockup-bahias}

Exhibe el panel administrativo diseñado para el control del espacio físico del taller. El tablero presenta una grilla visual de las bahías (del 1 al 6) codificadas por colores según su estado operativo: azul claro para bahías ocupadas ("En curso"), blanco para bahías disponibles ("Libre"), rojo para pausas ("En espera") y gris para inoperativas ("Mantenimiento"). Incluye el

**Sección Proforma**

![Mockups de la generación de proforma y resumen económico.](report/assets/MobileApplications-Mockups/proforma.png){#fig:mockup-proforma}

Muestra el diseño de la cotización final de los servicios prestados. La vista detalla de manera estructurada los costos desglosados: mano de obra por tareas, repuestos consumidos, el subtotal y el cálculo del IGV. Incorpora botones de acción rápida para enviar el documento directamente por WhatsApp al cliente o descargarlo en formato PDF.

**Sección Resolución del Presupuesto**

![Mockups de la confirmación o rechazo del presupuesto por parte del cliente.](report/assets/MobileApplications-Mockups/resolucion-presupuesto.png){#fig:mockup-resolucion}

Exhibe la interfaz donde el administrador registra la decisión del cliente sobre la proforma enviada. Permite marcar el presupuesto como "Aceptado", lo que habilita el inicio de los trabajos, o como "Rechazado". En caso de cancelación, el flujo despliega un modal para ingresar el motivo del rechazo y notifica la devolución automática de los repuestos al inventario.

**Sección Emisión SUNAT**

![Mockups del proceso de facturación electrónica e integración fiscal.](report/assets/MobileApplications-Mockups/emision-sunat.png){#fig:mockup-sunat}

Presenta la interfaz de comunicación directa con el servidor fiscal para la emisión de comprobantes. El flujo consta de la pantalla de carga "Enviando a SUNAT", seguida por la confirmación de la boleta o factura emitida que detalla el número de comprobante, monto total, código Hash y opciones de descarga. Finalmente, incluye el diseño del estado de advertencia "Comprobante pendiente" en caso de problemas de conectividad.

**Sección Registro de Pago**

![Mockups de la pasarela de cobro y registro de abonos.](report/assets/MobileApplications-Mockups/registro-pago.png){#fig:mockup-pago}

Muestra el diseño del módulo financiero de cobro. La pantalla incorpora un indicador visual del saldo pendiente que se actualiza al registrar pagos fraccionados mediante diferentes métodos (Yape, Tarjeta, Efectivo). Una vez completado el total, la interfaz cambia al estado de éxito con el saldo en cero resaltado en verde, habilitando el botón para proceder a la entrega.

**Sección Entrega del Vehículo**

![Mockups de validación final y generación del pase de salida.](report/assets/MobileApplications-Mockups/entrega-vehiculo.png){#fig:mockup-entrega}

Exhibe el paso final de liberación del vehículo para el cliente. La primera pantalla muestra un checklist de validación (Tareas completadas, Comprobante emitido, Pago completo) e incluye un área interactiva para capturar la firma digital del cliente en el dispositivo. Al confirmar, el sistema genera de forma automática un código QR que funciona como "Pase de salida" validado, liberando oficialmente la bahía.

#### 3.1.4.4. Mobile Applications User Flow Diagrams

Un user flow o trayectoria del usuario es un diagrama que consiste en mostrar el trayecto del usuario representado por un diagrama de flujo e indica el camino que debe seguir el usuario para cumplir con un objetivo en específico en la aplicación. Además, el user flow debe determinar estos pasos para completar una experiencia digital satisfactoria para el usuario.

- **User Goal 1:** Usuario (Técnico o Administrador) desea iniciar sesión en su cuenta

**Happy Path**

En esta ruta esperada, el flujo representa el proceso de inicio de sesión exitoso. El usuario es recibido por la pantalla de login, ingresa sus credenciales corporativas y accede a la pantalla de selección de sede operativa. Al confirmar su local de trabajo, ingresa satisfactoriamente a la pantalla principal (Home).

![Userflow de inicio de sesión exitoso.](report/assets/userflows/userflow_1_happypath.png){#fig:userflow-login-happy}

**Unhappy Paths**

En esta ruta alterna, el usuario ha colocado alguna información de su cuenta erróneamente (contraseña incorrecta). El sistema le prohíbe el acceso y le muestra una alerta visual advirtiendo de los intentos restantes antes del bloqueo temporal.

![Userflow de inicio de sesión con credenciales inválidas.](report/assets/userflows/userflow_1_unhappypath.png){#fig:userflow-login-unhappy}

- **User Goal 2:** Usuario desea recuperar su contraseña olvidada

**Happy Path**

En esta ruta esperada, el usuario no recuerda su clave. Accede a la opción de recuperación desde el inicio de sesión, ingresa su correo institucional y solicita las instrucciones. El sistema valida el correo y envía un enlace. Al acceder al enlace, el usuario ingresa y confirma su nueva contraseña, restableciendo su acceso exitosamente.

![Userflow de recuperación de contraseña exitosa.](report/assets/userflows/userflow_2_happypath.png){#fig:userflow-recovery-happy}

**Unhappy Paths**

En esta ruta alterna, el usuario intenta usar un enlace de recuperación que ya ha expirado por tiempo. La aplicación bloquea el cambio de contraseña mostrando una alerta roja ("El enlace venció") y le obliga a solicitar un nuevo enlace para continuar.

![Userflow de recuperación con enlace expirado.](report/assets/userflows/userflow_2_unhappypath.png){#fig:userflow-recovery-unhappy}

- **User Goal 3:** Técnico automotriz desea registrar su asistencia mediante geolocalización

**Happy Path**

En esta ruta esperada, el técnico se encuentra físicamente en el taller. Accede a la vista de "Registrar entrada" donde el mapa interactivo confirma que se encuentra dentro del perímetro (geocerca en verde). El botón se habilita, y al pulsarlo, el sistema registra su jornada exitosamente, regresándolo a la pantalla principal con su estado actualizado.

![Userflow de marcación de asistencia exitosa.](report/assets/userflows/userflow_3_happypath.png){#fig:userflow-asistencia-happy}

**Unhappy Paths**

En esta ruta alterna, el técnico intenta marcar asistencia pero no cumple con los requisitos tecnológicos o de ubicación. El sistema detecta que el GPS del dispositivo está apagado o que el usuario se encuentra muy lejos del centro del taller, bloqueando el botón de registro de entrada de manera preventiva.

![Userflow de marcación de asistencia bloqueada por GPS.](report/assets/userflows/userflow_3_unhappypath.png){#fig:userflow-asistencia-unhappy}

- **User Goal 4:** Administrador o Asesor desea recibir un vehículo y aperturar una Orden de Trabajo (OT)

**Happy Path**

En esta ruta esperada, el encargado busca el vehículo del cliente ingresando la placa en el sistema. Al encontrar coincidencias, confirma la selección y es dirigido al formulario de apertura. Rellena el kilometraje, los síntomas reportados por el cliente y las tareas a realizar. Al guardar, el sistema le genera el ticket de la orden (ej. OT-0424) exitosamente.

![Userflow de apertura de orden de trabajo.](report/assets/userflows/userflow_4_happypath.png){#fig:userflow-recepcion-happy}

- **User Goal 5:** Técnico automotriz desea conectar el escáner OBD-II y leer los códigos de falla

**Happy Path**

En esta ruta esperada, el técnico accede a la sección OBD-II de la aplicación e inicia la búsqueda de dispositivos Bluetooth cercanos. Selecciona el escáner conectado al vehículo, y una vez vinculado correctamente, accede al menú de lectura y presiona la opción para extraer los códigos de falla del motor, visualizando la lista de errores detectados.

![Userflow de lectura de diagnóstico electrónico.](report/assets/userflows/userflow_5_happypath.png){#fig:userflow-obd-happy}

- **User Goal 6:** Técnico automotriz desea imputar (consumir) un repuesto del inventario hacia una tarea activa

**Happy Path**

En esta ruta esperada, el técnico, mientras ejecuta una tarea, se da cuenta de que necesita repuestos. Accede a la opción de "Imputar", busca el ítem en el catálogo de almacén (ej. bujías), ajusta la cantidad necesaria (ej. 4 unidades) validando que haya stock suficiente, y lo asigna directamente a la orden, volviendo a su cronómetro de tarea.

![Userflow de asignación de repuestos.](report/assets/userflows/userflow_6_happypath.png){#fig:userflow-inventario-happy}

- **User Goal 7:** Técnico automotriz desea cerrar una tarea completada

**Happy Path**

En esta ruta esperada, el técnico ha terminado su labor. Accede a la pantalla de "Cerrar tarea" donde el sistema verifica que todos los requisitos de calidad estén cumplidos (checks verdes en "Foto de labor completada" y "Repuestos consumidos"). Al estar todo en orden, el botón principal se habilita y permite confirmar el cierre técnico.

![Userflow de cierre de tarea validado.](report/assets/userflows/userflow_7_happypath.png){#fig:userflow-cierre-happy}

**Unhappy Paths**

En esta ruta alterna, el técnico intenta cerrar la tarea pero olvidó adjuntar la evidencia fotográfica obligatoria. El sistema detecta la omisión, bloquea el botón principal de confirmación, marca el requisito en rojo ("Falta al menos una foto") y le despliega un botón secundario para forzar la captura fotográfica en ese instante.

![Userflow de cierre de tarea bloqueado por falta de evidencia.](report/assets/userflows/userflow_7_unhappypath.png){#fig:userflow-cierre-unhappy}

- **User Goal 8:** Administrador gestiona la resolución de un presupuesto con el cliente

**Happy Path**

En este flujo esperado, el administrador ha generado la proforma y la ha enviado por WhatsApp. El cliente revisa los costos y acepta el presupuesto. El administrador marca el estado como "Aceptado", lo que cambia el estado de la orden a "En progreso", notificando a los técnicos que ya pueden empezar a trabajar.

![Userflow de aprobación de presupuesto.](report/assets/userflows/userflow_8_happypath.png){#fig:userflow-presupuesto-happy}

**Alternative Path (Rechazo)**

En esta ruta alterna, el cliente decide no realizar el servicio por el costo. El administrador marca la proforma como "Rechazada", lo que despliega un modal obligatorio para registrar el motivo de cancelación ("Precio fuera de presupuesto"). Al confirmar, el sistema cancela la orden y libera los repuestos reservados al inventario.

![Userflow de cancelación y rechazo de presupuesto.](report/assets/userflows/userflow_8_unhappypath.png){#fig:userflow-presupuesto-unhappy}

- **User Goal 9:** Administrador desea emitir el comprobante electrónico a SUNAT

**Happy Path**

En esta ruta esperada, el administrador finaliza la orden y procede con la facturación. El sistema envía la petición ("Enviando a SUNAT") y recibe una respuesta positiva casi de inmediato. Se muestra la pantalla de éxito ("Boleta emitida") con el número de comprobante, el código Hash validado y las opciones para descargar el PDF.

![Userflow de emisión de comprobante electrónico.](report/assets/userflows/userflow_9_happypath.png){#fig:userflow-sunat-happy}

**Unhappy Paths**

En esta ruta alterna, ocurre una falla de conexión con los servidores de SUNAT en el momento de la emisión. Para no detener la operatividad del taller, el sistema reserva el número de comprobante, guarda el registro localmente con el estado "Comprobante pendiente" (alerta naranja) y habilita el botón para proceder con el cobro, programando un reintento automático.

![Userflow de error de conectividad con SUNAT.](report/assets/userflows/userflow_9_unhappypath.png){#fig:userflow-sunat-unhappy}

- **User Goal 10:** Administrador desea cobrar el servicio y entregar el vehículo al cliente

**Happy Path**

En este último flujo esperado, el administrador se encuentra en la pasarela de pagos con un saldo pendiente. Registra el abono del cliente (ej. por Efectivo o Yape) de modo que el saldo llegue a cero. Esto habilita la pantalla de entrega, donde el administrador le pide la firma digital al cliente en la pantalla del celular. Al confirmar, se genera el Código QR de pase de salida.

![Userflow de registro de cobro y emisión de pase de salida.](report/assets/userflows/userflow_10_happypath.png){#fig:userflow-cobro-happy}

#### 3.1.4.5. Mobile Applications Prototyping

En esta sección se presenta el prototipo de la aplicación móvil de Atelier mediante un video que recorre sus pantallas y muestra las principales interacciones. La navegación ilustrada se basa en los flujos de usuario descritos previamente y permite observar cómo se conectan las funcionalidades de la plataforma.

![Prototype](report/assets/Prototype/Atelier_Prototype.png){#fig:prototipo-Atelier}

Prototipo de Atelier: https://upcedupe-my.sharepoint.com/:v:/g/personal/u202417423_upc_edu_pe/IQDQ0LT1SbGJRJ2KmdLUWZOLAZ-mZ6ws9qtsKgoQlFB5MZg?nav=eyJyZWZlcnJhbEluZm8iOnsicmVmZXJyYWxBcHAiOiJPbmVEcml2ZUZvckJ1c2luZXNzIiwicmVmZXJyYWxBcHBQbGF0Zm9ybSI6IldlYiIsInJlZmVycmFsTW9kZSI6InZpZXciLCJyZWZlcnJhbFZpZXciOiJNeUZpbGVzTGlua0NvcHkifX0&e=EMucdj

\newpage
