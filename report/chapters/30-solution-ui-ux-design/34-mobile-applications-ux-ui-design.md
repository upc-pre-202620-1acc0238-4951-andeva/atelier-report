### 3.1.4. *Mobile Applications UX/UI Design*



#### 3.1.4.1. Mobile Applications Wireframes



#### 3.1.4.2. Mobile Applications Wireflow Diagrams



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



\newpage
