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

| Sistema de Organización | Ámbito Principal | Aplicación en Atelier Workshop |
| :--- | :---: | :--- |
| Jerárquico | Web de aterrizaje y paneles de control | Muestra resúmenes ejecutivos antes de abrir registros individuales. |
| Secuencial | Flujos operativos y transacciones | Conduce tareas paso a paso en órdenes, altas de personal y facturación. |
| Por tópicos | Navegación modular de la plataforma | Separa las funciones del taller en módulos independientes. |
| Según audiencia | Segmentación por roles del taller | Ajusta la información visible según el puesto de trabajo del usuario. |
| Cronológico | Inventario por lote y registros históricos | Descuenta stock por fecha de entrada y ordena lecturas del escáner. |

: Síntesis de los sistemas de organización en Atelier Workshop {#tbl:sistemas-organizacion-atelier}

*Nota.* Relación entre los esquemas de organización y su función en la plataforma.

**Estructura Jerárquica de la Página Web de Aterrizaje**

La página web de aterrizaje de Atelier Workshop organiza su contenido para presentar el servicio y captar clientes mediante tres niveles de navegación:

1. **Nivel 1 (Entrada y Propuesta de Valor):** Encabezado con navegación global, cambio de idioma y tema visual, junto a una portada con propuesta de valor, botones de descarga y telemetría simulada en tiempo real.

2. **Nivel 2 (Información y Capacidades del Sistema):** Estadísticas del sector automotriz, flujo de tres pasos de trabajo, módulos principales del sistema, diferencias entre la versión web y móvil, y preguntas frecuentes.

3. **Nivel 3 (Decisión y Contacto):** Comparativa de planes de suscripción, información del equipo de desarrollo, formulario de solicitud de demostración y enlaces de contacto directo por mensajería.

La distribución de los contenidos y secciones de la web de aterrizaje se organiza de la siguiente manera:

| Nivel | División | Sección o Bloque | Contenido Principal | Propósito |
| :---: | :---: | :--- | :--- | :--- |
| Nivel 1 | Encabezado | Barra de Navegación | Logotipo, selector de idioma, selector de tema, botón demo y menú móvil. | Mantener acceso persistente a las secciones principales. |
| Nivel 1 | Entrada | Portada Principal | Titular, propuesta de valor, accesos de descarga y telemetría en vivo. | Presentar el producto y captar la atención del visitante. |
| Nivel 2 | Contexto | Cifras del Sector | Estadísticas sobre productividad, antigüedad vehicular e informalidad. | Justificar la necesidad de digitalizar el taller mecánico. |
| Nivel 2 | Explicación | Flujo de Operación | Tres pasos: escaneo vehicular, diagnóstico con fotos y cobro integrado. | Explicar el funcionamiento general de la solución. |
| Nivel 2 | Capacidades | Módulos de Producto | Seis módulos: escaneo vehicular, órdenes, inventario, facturación y evidencias. | Detallar la cobertura técnica de la plataforma. |
| Nivel 2 | Audiencia | Segmentación por Roles | Comparación entre el panel web de gestión y la aplicación móvil de patio. | Mostrar las herramientas específicas para cada puesto. |
| Nivel 3 | Conversión | Planes de Suscripción | Tarifas de los planes Básico, Pro y Multi-Sucursal con solicitud de demo. | Guiar la elección del plan comercial adecuado. |
| Nivel 3 | Soporte | Preguntas Frecuentes | Respuestas sobre compatibilidad vehicular, trabajo sin internet y SUNAT. | Resolver dudas técnicas antes de la contratación. |
| Nivel 3 | Cierre | Contacto e Instalación | Enlaces a instaladores, chat directo y formulario de demostración. | Facilitar la prueba e instalación del sistema. |

: Organización jerárquica de la página web de aterrizaje {#tbl:jerarquia-landing-page}

*Nota.* Distribución de niveles, bloques y funciones de la landing page.

**Estructura Jerárquica de la Plataforma de Gestión del Taller**

La plataforma de gestión de Atelier Workshop organiza sus funciones en cuatro niveles para coordinar la administración y el trabajo en taller:

1. **Nivel 1 (Panel de Control):** Muestra el estado del taller con órdenes activas, ingresos del día, alertas de repuestos agotados y avisos de fallas en vehículos.

2. **Nivel 2 (Módulos de Gestión):** Barra de navegación con accesos a órdenes de trabajo, inventario FIFO por lote, compras a proveedores, facturación electrónica SUNAT, escaneo de fallas y personal.

3. **Nivel 3 (Filtros y Búsqueda):** Opciones para ordenar y filtrar registros por placa vehicular, estado de reparación, fecha de vencimiento o nivel de existencias.

4. **Nivel 4 (Detalle y Transacciones):** Formularios de ingreso, fichas técnicas vehiculares, fotografías periciales de reparaciones y emisión de comprobantes de pago.

La estructura de módulos y herramientas de la plataforma se detalla a continuación:

| Nivel | Área | Módulo o Entorno | Funcionalidades Clave | Perfil Destinatario |
| :---: | :---: | :--- | :--- | :--- |
| Nivel 1 | Visión Global | Panel de Control | Resumen de órdenes activas, ingresos, alertas de stock y avisos. | Propietario y administrador |
| Nivel 2 | Operación | Órdenes de Trabajo | Recepción vehicular, asignación de tareas, fotos periciales y cobro. | Asesor y mecánico |
| Nivel 2 | Existencias | Inventario y Lotes | Catálogo de repuestos, costeo por lote FIFO y descarga automática. | Administrador y almacenero |
| Nivel 2 | Abastecimiento | Compras y Proveedores | Órdenes de compra a proveedores, facturas de compra y recepción. | Propietario y administrador |
| Nivel 2 | Tributación | Facturación Electrónica | Emisión de boletas y facturas SUNAT, descarga de PDF y XML. | Administrador y cajero |
| Nivel 2 | Diagnóstico | Telemetría Vehicular | Conexión a escáner por Bluetooth, lectura de fallas y reporte técnico. | Mecánico y asesor |
| Nivel 2 | Personal | Control de Equipo | Registro de personal, asignación de roles y asistencia en taller. | Propietario y administrador |
| Nivel 3 | Patio y Foso | Bahía de Trabajo | Tareas del día asignadas, registro de fotos y modo sin conexión. | Mecánico de taller |
| Nivel 3 | Configuración | Ajustes del Sistema | Datos fiscales de la sede, plan de suscripción y usuarios del sistema. | Propietario del taller |

: Organización jerárquica de la plataforma de gestión Atelier Workshop {#tbl:jerarquia-aplicacion-atelier}

*Nota.* Estructura de niveles, módulos y perfiles en la plataforma de taller.

#### 3.1.2.2. Labelling Systems



#### 3.1.2.3. SEO Tags and Meta Tags



#### 3.1.2.4. Searching Systems



#### 3.1.2.5. Navigation Systems



\newpage
