### 3.1.2. *Information Architecture*

La arquitectura de información de Atelier Workshop organiza el contenido de la página web pública y de la plataforma de gestión de taller, compuesta por la aplicación web y la aplicación móvil. La estructura reduce la carga mental de los usuarios y les permite acceder a las funciones administrativas y de diagnóstico sin pasos innecesarios.

#### 3.1.2.1. Organization Systems

El sistema agrupa los datos y herramientas mediante cinco esquemas de organización:

**Sistema Jerárquico**

Ordena el contenido desde resúmenes generales hasta datos específicos. En la web de aterrizaje, el usuario avanza desde la propuesta de valor inicial hacia los detalles técnicos y los planes de suscripción. En la aplicación del taller, el nivel superior presenta tableros con métricas de operación y finanzas, desde donde se accede a listas de órdenes, repuestos o clientes.

**Sistema Secuencial**

Guía al usuario en procesos lineales con pasos obligatorios. Este esquema se utiliza en la explicación del servicio dentro de la web de aterrizaje, en la invitación y registro del personal, en la apertura de órdenes de trabajo con fotografías de ingreso, y en la emisión de comprobantes ante la SUNAT.

**Sistema por Tópicos o Categorías**

Distribuye las funciones en módulos independientes según el área de trabajo: órdenes de servicio, inventario de repuestos, proveedores, facturación electrónica, telemetría vehicular y gestión de personal.

**Sistema según Audiencia**

Separa las vistas y herramientas según el rol del usuario:

- **Personal de Gestión:** Dueños, administradores y asesores revisan reportes financieros, valuación de inventario por primeras entradas y primeras salidas, y emisión de comprobantes de pago.

- **Personal Operativo:** Mecánicos y técnicos consultan sus tareas asignadas, lecturas de sensores vehiculares por Bluetooth, fotografías de fallas y registros sin conexión a internet en bahías o fosos.

**Sistema Cronológico**

Ordena los registros por fecha y hora. Se aplica en el método contable FIFO, donde el stock más antiguo se descuenta primero al usar repuestos en una orden. También organiza las lecturas del escáner vehicular, el control de asistencia del personal y el archivo de comprobantes emitidos.

A continuación se resume la aplicación de estos esquemas en la plataforma:

\begin{table}[htpb]
\centering
\small
\renewcommand{\arraystretch}{1.25}
\caption{Síntesis de los Sistemas de Organización en Atelier Workshop}
\label{tbl:sistemas-organizacion-atelier}
\begin{tabularx}{\textwidth}{| >{\centering\arraybackslash}m{3.2cm} | >{\centering\arraybackslash}m{3.8cm} | X |}
\hline
\thfirst{Sistema de Organización} & \thcell{Ámbito Principal} & \thcell{Aplicación en Atelier Workshop} \\
\hline
Jerárquico & Web de aterrizaje y paneles de control & Muestra resúmenes ejecutivos antes de abrir registros individuales. \\
\hline
Secuencial & Flujos operativos y transacciones & Conduce tareas paso a paso en órdenes, altas de personal y facturación. \\
\hline
Por tópicos & Navegación modular de la plataforma & Separa las funciones del taller en módulos independientes. \\
\hline
Según audiencia & Segmentación por roles del taller & Ajusta la información visible según el puesto de trabajo del usuario. \\
\hline
Cronológico & Inventario por lote y registros históricos & Descuenta stock por fecha de entrada y ordena lecturas del escáner. \\
\hline
\end{tabularx}
\end{table}

*Nota.* Relación entre los esquemas de organización y su función en la plataforma.

**Estructura Jerárquica de la Página Web de Aterrizaje**

La página web de aterrizaje de Atelier Workshop organiza su contenido para presentar el servicio y captar clientes mediante tres niveles de navegación:

1. **Nivel 1 (Entrada y Propuesta de Valor):** Encabezado con navegación global, cambio de idioma y tema visual, junto a una portada con propuesta de valor, botones de descarga y telemetría simulada en tiempo real.

2. **Nivel 2 (Información y Capacidades del Sistema):** Estadísticas del sector automotriz, flujo de tres pasos de trabajo, módulos principales del sistema, diferencias entre la versión web y móvil, y preguntas frecuentes.

3. **Nivel 3 (Decisión y Contacto):** Comparativa de planes de suscripción, información del equipo de desarrollo, formulario de solicitud de demostración y enlaces de contacto directo por mensajería.

La distribución de los contenidos y secciones de la web de aterrizaje se organiza de la siguiente manera:

\begin{table}[htpb]
\centering
\small
\renewcommand{\arraystretch}{1.25}
\caption{Organización Jerárquica de la Página Web de Aterrizaje}
\label{tbl:jerarquia-landing-page}
\begin{tabularx}{\textwidth}{| >{\centering\arraybackslash}m{1.8cm} | >{\centering\arraybackslash}m{2.2cm} | >{\centering\arraybackslash}m{2.5cm} | X | X |}
\hline
\thfirst{Nivel} & \thcell{División} & \thcell{Sección o Bloque} & \thcell{Contenido Principal} & \thcell{Propósito} \\
\hline
\multirow{2}{=}{\centering Nivel 1} & Encabezado & Barra de Navegación & Logotipo, selector de idioma, selector de tema, botón demo y menú móvil. & Mantener acceso persistente a las secciones principales. \\
\cline{2-5}
& Entrada & Portada Principal & Titular, propuesta de valor, accesos de descarga y telemetría en vivo. & Presentar el producto y captar la atención del visitante. \\
\hline
\multirow{4}{=}{\centering Nivel 2} & Contexto & Cifras del Sector & Estadísticas sobre productividad, antigüedad vehicular e informalidad. & Justificar la necesidad de digitalizar el taller mecánico. \\
\cline{2-5}
& Explicación & Flujo de Operación & Tres pasos: escaneo vehicular, diagnóstico con fotos y cobro integrado. & Explicar el funcionamiento general de la solución. \\
\cline{2-5}
& Capacidades & Módulos de Producto & Seis módulos: escaneo vehicular, órdenes, inventario, facturación y evidencias. & Detallar la cobertura técnica de la plataforma. \\
\cline{2-5}
& Audiencia & Segmentación por Roles & Comparación entre el panel web de gestión y la aplicación móvil de patio. & Mostrar las herramientas específicas para cada puesto. \\
\hline
\multirow{3}{=}{\centering Nivel 3} & Conversión & Planes de Suscripción & Tarifas de los planes Básico, Pro y Multi-Sucursal con solicitud de demo. & Guiar la elección del plan comercial adecuado. \\
\cline{2-5}
& Soporte & Preguntas Frecuentes & Respuestas sobre compatibilidad vehicular, trabajo sin internet y SUNAT. & Resolver dudas técnicas antes de la contratación. \\
\cline{2-5}
& Cierre & Contacto e Instalación & Enlaces a instaladores, chat directo y formulario de demostración. & Facilitar la prueba e instalación del sistema. \\
\hline
\end{tabularx}
\end{table}

*Nota.* Distribución de niveles, bloques y funciones de la landing page.

**Estructura Jerárquica de la Plataforma de Gestión del Taller**

La plataforma de gestión de Atelier Workshop organiza sus funciones en cuatro niveles para coordinar la administración y el trabajo en taller:

1. **Nivel 1 (Panel de Control):** Muestra el estado del taller con órdenes activas, ingresos del día, alertas de repuestos agotados y avisos de fallas en vehículos.

2. **Nivel 2 (Módulos de Gestión):** Barra de navegación con accesos a órdenes de trabajo, inventario FIFO por lote, compras a proveedores, facturación electrónica SUNAT, escaneo de fallas y personal.

3. **Nivel 3 (Filtros y Búsqueda):** Opciones para ordenar y filtrar registros por placa vehicular, estado de reparación, fecha de vencimiento o nivel de existencias.

4. **Nivel 4 (Detalle y Transacciones):** Formularios de ingreso, fichas técnicas vehiculares, fotografías periciales de reparaciones y emisión de comprobantes de pago.

La estructura de módulos y herramientas de la plataforma se detalla a continuación:

\begin{table}[htpb]
\centering
\small
\renewcommand{\arraystretch}{1.25}
\caption{Organización Jerárquica de la Plataforma de Gestión Atelier Workshop}
\label{tbl:jerarquia-aplicacion-atelier}
\begin{tabularx}{\textwidth}{| >{\centering\arraybackslash}m{1.8cm} | >{\centering\arraybackslash}m{2.5cm} | >{\centering\arraybackslash}m{2.5cm} | X | >{\centering\arraybackslash}m{2.6cm} |}
\hline
\thfirst{Nivel} & \thcell{Área} & \thcell{Módulo o Entorno} & \thcell{Funcionalidades Clave} & \thcell{Perfil Destinatario} \\
\hline
Nivel 1 & Visión Global & Panel de Control & Resumen de órdenes activas, ingresos, alertas de stock y avisos. & Propietario y administrador \\
\hline
\multirow{6}{=}{\centering Nivel 2} & Operación & Órdenes de Trabajo & Recepción vehicular, asignación de tareas, fotos periciales y cobro. & Asesor y mecánico \\
\cline{2-5}
& Existencias & Inventario y Lotes & Catálogo de repuestos, costeo por lote FIFO y descarga automática. & Administrador y almacenero \\
\cline{2-5}
& Abastecimiento & Compras y Proveedores & Órdenes de compra a proveedores, facturas de compra y recepción. & Propietario y administrador \\
\cline{2-5}
& Tributación & Facturación Electrónica & Emisión de boletas y facturas SUNAT, descarga de PDF y XML. & Administrador y cajero \\
\cline{2-5}
& Diagnóstico & Telemetría Vehicular & Conexión a escáner por Bluetooth, lectura de fallas y reporte técnico. & Mecánico y asesor \\
\cline{2-5}
& Personal & Control de Equipo & Registro de personal, asignación de roles y asistencia en taller. & Propietario y administrador \\
\hline
\multirow{2}{=}{\centering Nivel 3} & Patio y Foso & Bahía de Trabajo & Tareas del día asignadas, registro de fotos y modo sin conexión. & Mecánico de taller \\
\cline{2-5}
& Configuración & Ajustes del Sistema & Datos fiscales de la sede, plan de suscripción y usuarios del sistema. & Propietario del taller \\
\hline
\end{tabularx}
\end{table}

*Nota.* Estructura de niveles, módulos y perfiles en la plataforma de taller.

#### 3.1.2.2. Labelling Systems

El sistema de etiquetado de Atelier Workshop traduce los conceptos técnicos del modelo de dominio a términos claros, breves y familiares para los trabajadores del taller automotriz. En lugar de exponer nombres de ingeniería de software como Identity and Access Management, MRO Work Orders o Ingestion IoT Telemetry, la interfaz utiliza palabras directas que describen la función sin tecnicismos innecesarios.

El diseño de las etiquetas se rige por tres principios:

- **Consistencia:** Se emplean los mismos nombres en botones, menús, estados y mensajes de confirmación tanto en la web como en la aplicación móvil. Por ejemplo, las acciones Nueva Orden, Registrar Entrada y Ver Detalle conservan su redacción en todas las pantallas.

- **Simplicidad:** Los textos se reducen a una o dos palabras clave para agilizar la lectura de mecánicos y administradores en entornos de taller con distracciones visuales. Términos como Stock Crítico, Fecha de Lote y Falla Activa sustituyen explicaciones complejas.

- **Claridad de Estado:** Los indicadores comunican de forma precisa la situación de los vehículos, los repuestos y la red. Estados como En Diagnóstico, En Reparación, Listo para Entrega, Sincronizado y Sin Conexión permiten conocer el avance del trabajo de un vistazo.

**Etiquetado en la Página Web de Aterrizaje**

En la web de aterrizaje pública, las etiquetas guían a los dueños de taller desde la propuesta de valor hasta la contratación del servicio:

- **Inicio:** Encabezado y portada con la promesa de valor central de la plataforma.

- **Cómo Funciona:** Explicación del flujo de trabajo en tres pasos: Escanea, Decide y Cobra.

- **Producto:** Cuadrícula con las herramientas principales del sistema, incluyendo escáner vehicular, órdenes de trabajo, inventario FIFO y facturación SUNAT.

- **Roles:** Sección que compara el panel web administrativo con la aplicación móvil de bahía.

- **Precios:** Resumen de tarifas y coberturas para los planes Básico, Pro y Multi-Sucursal.

- **Preguntas Frecuentes:** Acordeón con respuestas sobre compatibilidad con vehículos, operación sin internet y homologación fiscal.

- **Pedir Demo e Instalar App:** Botones de acción directa para solicitar una demostración o descargar el instalador móvil.

**Etiquetado en la Aplicación Web de Gestión**

En la versión de escritorio para computadoras, las etiquetas estructuran la administración general del taller y el cumplimiento tributario:

- **Panel de Control:** Tablero con indicadores diarios de órdenes activas, ingresos económicos y alertas de piezas agotadas.

- **Órdenes de Trabajo:** Registro, seguimiento y liquidación de servicios automotrices.

- **Inventario FIFO:** Control de existencias ordenadas por lote según su orden de llegada.

- **Compras y Proveedores:** Registro de órdenes de compra, comprobantes de pago recibidos y altas de mercadería.

- **Facturación SUNAT:** Emisión de boletas y facturas electrónicas oficiales con descarga de archivos digitales.

- **Personal:** Directorio de trabajadores, roles de acceso y registro de asistencia en el local.

- **Configuración:** Ajustes fiscales de la sede, gestión del plan de suscripción y datos de cuenta.

**Etiquetado en la Aplicación Móvil de Bahía y Foso**

En la aplicación móvil para mecánicos y personal de patio, las etiquetas responden a condiciones de uso con guantes, poca luz y conectividad intermitente:

- **Marcar Asistencia:** Registro de entrada y salida mediante geocerca perimétrica del taller.

- **Mis Tareas:** Lista de intervenciones mecánicas asignadas al técnico durante su jornada.

- **Iniciar Labor, Pausar y Finalizar:** Botones de control temporal para registrar las horas efectivas dedicadas a cada reparación.

- **Escáner OBD-II:** Conexión inalámbrica por Bluetooth con el escáner del vehículo.

- **Códigos de Falla:** Detección y lista de averías electrónicas identificadas en el motor o transmisión.

- **Telemetría en Vivo:** Lectura de sensores en tiempo real como temperatura del refrigerante, revoluciones y voltaje de batería.

- **Registrar Hallazgo:** Captura de fotografías periciales para documentar daños ocultos y proponer nuevas tareas al cliente.

- **Estado de Red:** Etiquetas visuales En Línea, Sincronizando y Sin Conexión para informar el estado de los datos guardados en el teléfono.


#### 3.1.2.3. SEO Tags and Meta Tags

En el ecosistema de Atelier Workshop, las etiquetas de optimización para motores de búsqueda (SEO) y las metaetiquetas se configuran para posicionar el producto en navegadores web y tiendas de aplicaciones móviles. El objetivo radica en atraer a propietarios de talleres mecánicos que buscan soluciones de digitalización y gestión automotriz.

Para la página web de aterrizaje pública, las etiquetas se enfocan en comunicar el núcleo de valor comercial y técnico:

- **Título (Title):** Atelier Workshop | Software de Gestión y Diagnóstico para Talleres Mecánicos
- **Descripción Meta (Meta Description):** Digitaliza tu taller mecánico con Atelier Workshop. Controla órdenes de trabajo, inventario FIFO, facturación electrónica SUNAT y telemetría OBD-II en tiempo real.
- **Palabras Clave (Keywords):** software taller mecánico, gestión automotriz, órdenes de trabajo, inventario FIFO, facturación electrónica, telemetría OBD-II, escáner Bluetooth, SUNAT.
- **Autor (Author):** Atelier Workshop

Para la aplicación móvil dirigida al personal técnico en patio y foso, se implementa la optimización para tiendas de aplicaciones (ASO) a fin de destacar su funcionalidad operativa y fuera de línea:

- **Título de la Aplicación (Title):** Atelier Workshop: Mecánico y OBD-II
- **Descripción Corta (Meta Description):** Aplicación móvil para mecánicos. Registra labores, toma fotos periciales y lee códigos de falla con el escáner Bluetooth sin depender de internet.
- **Palabras Clave (Keywords):** mecánico, taller, OBD-II, códigos de falla, escáner automotriz, diagnóstico, orden de trabajo.

#### 3.1.2.4. Searching Systems

El sistema de búsqueda en Atelier Workshop facilita la recuperación rápida de información operativa y técnica dentro del flujo diario del taller. La barra de búsqueda global y los filtros modulares reducen el tiempo de consulta en catálogos extensos.

Las funciones principales de búsqueda incluyen:

- **Búsqueda por Placa Vehicular:** Permite localizar de inmediato el historial de reparaciones, órdenes de trabajo activas y registros de diagnóstico asociados a un vehículo específico.
- **Filtros por Estado de Orden:** Facilita la vista rápida de los vehículos en recepción, en diagnóstico, en reparación, listos para entrega o cobrados.
- **Búsqueda de Inventario y Repuestos:** Ubica piezas por código de fabricante, nombre o lote, advirtiendo sobre el nivel crítico de existencias bajo el método FIFO.
- **Filtros Temporales e Históricos:** Permite consultar los comprobantes de pago emitidos para la SUNAT, las órdenes finalizadas y las horas laboradas por el personal dentro de un rango de fechas.

#### 3.1.2.5. Navigation Systems

El sistema de navegación de Atelier Workshop asegura que los usuarios mantengan el contexto de su ubicación en la plataforma y accedan a las herramientas con el menor número de interacciones. Se aplican diferentes componentes de navegación según el dispositivo y el perfil del usuario.

**Navegación Global:**

- **Barra de Navegación Web (Top Navigation):** Presente en la página de aterrizaje, ofrece acceso inmediato a la propuesta de valor, los módulos del sistema, los planes de suscripción y el portal de acceso al panel administrativo.
- **Menú Lateral (Sidebar):** Ubicado en la aplicación web de gestión, agrupa los módulos principales en categorías lógicas (Operación, Abastecimiento, Tributación, Personal) para que el administrador cambie de contexto sin perder de vista los indicadores del taller.
- **Barra Inferior Móvil (Bottom Navigation):** Implementada en la aplicación móvil de bahía, dispone botones anchos y de fácil alcance pulgar para las herramientas clave del mecánico: Mis Tareas, Escáner, Hallazgos y Perfil.

**Navegación Local y Contextual:**

- **Pestañas (Tabs):** Organizan la información dentro de un mismo módulo, como la separación entre boletas y facturas en facturación electrónica o entre parámetros en vivo y fallas DTC en el escáner.
- **Navegación por Migas de Pan (Breadcrumbs):** Indica la ruta jerárquica al visualizar detalles profundos, como el desglose de una orden de trabajo o el lote específico de un repuesto, y permite regresar al listado anterior de un solo toque.

\newpage
