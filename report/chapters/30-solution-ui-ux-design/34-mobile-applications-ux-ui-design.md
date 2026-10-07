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



#### 3.1.4.5. Mobile Applications Prototyping



\newpage
