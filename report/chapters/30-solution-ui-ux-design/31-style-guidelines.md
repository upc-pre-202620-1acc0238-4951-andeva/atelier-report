# Capítulo III: Solution UI/UX Design

## 3.1. Product Design

El diseño de producto de Atelier Workshop se plantea como una experiencia digital integral, moderna y confiable, orientada a profesionalizar la gestión de los talleres automotrices y conectar el mantenimiento predictivo mediante telemetría IoT con escáneres OBD-II. La propuesta visual y funcional responde a dos entornos operativos complementarios: la administración de órdenes de trabajo, control de inventario FIFO y facturación en la plataforma web, y la ejecución de diagnósticos técnicos con evidencias fotográficas en la aplicación móvil de bahía. Por ello, el diseño prioriza interfaces de alta legibilidad, elementos táctiles ergonómicos y una navegación intuitiva que reduce la carga cognitiva del personal técnico, transmitiendo precisión ingenieril, orden operativo y respaldo profesional.

### 3.1.1. *Style Guidelines*

Las directrices de estilo de Atelier Workshop definen los criterios visuales que guían la identidad de la plataforma en la aplicación web de gestión y la aplicación móvil de bahía. La propuesta visual se basa en una estética sobria, industrial y funcional, diseñada para operar con claridad bajo condiciones de iluminación variables en el taller. Para ello, se emplea una paleta cromática basada en azul eléctrico como tono principal, tonos neutros de alto contraste para modos diurno y nocturno, un acento ámbar para alertas prioritarias y la tipografía Satoshi para optimizar la legibilidad en pantallas de diversa resolución.

#### 3.1.1.1. General Style Guidelines

La identidad visual general de Atelier Workshop se fundamenta en un enfoque minimalista, moderno y funcional, adaptado al trabajo operativo y administrativo del taller automotriz. Las decisiones de branding, tipografía, paleta de colores, espaciado y elementos táctiles buscan consolidar una experiencia de usuario ágil y coherente.

**Branding e Identidad de Marca**

La marca Atelier Workshop refleja la transición del taller tradicional hacia un centro de diagnóstico computarizado y gestión digitalizada. Los elementos que integran su identidad visual se detallan a continuación:

- **Concepto de Marca:** Atelier Workshop encarna la dignidad del oficio mecánico, la precisión técnica y la evolución hacia el mantenimiento predictivo mediante telemetría en tiempo real.

- **Anatomía del Isotipo:** El isotipo de la marca representa formalmente el perfil técnico de un mecánico automotriz profesional. Su diseño estilizado sintetiza una gorra de trabajo industrial con visera, lentes de protección pericial y el cuello de un overol técnico. Esta composición simboliza la experiencia en bahía y la precisión en el diagnóstico automotriz. Asimismo, se presentan las variantes cromáticas oficiales diseñadas para los diferentes entornos de contraste de la aplicación.

![Isotipo oficial de Atelier Workshop en sus variantes cromáticas](report/assets/logo-tipo-colores/isotipo-variantes.png){#fig:isotipo-atelier}

*Nota.* Variantes del isotipo oficial en modos claro, oscuro y configuraciones de alto contraste.

- **Anatomía del Imagotipo:** El imagotipo principal integra el isotipo corporativo enmarcado dentro de un contenedor redondeado con esquinas suavizadas, acompañado del bloque tipográfico institucional a dos líneas horizontales alineadas a la izquierda: Atelier en la línea superior y Workshop en la línea inferior.

![Imagotipo principal de Atelier Workshop con isotipo en contenedor redondeado](report/assets/logo-tipo-colores/imagotipo-squircle.png){#fig:imagotipo-squircle-atelier}

*Nota.* Imagotipo principal para encabezados del sistema web y aplicaciones institucionales.

Se dispone asimismo de una variante secundaria con isotipo calado directo orientada a fondos neutros y entornos monocromáticos.

![Imagotipo secundario de Atelier Workshop con isotipo calado](report/assets/logo-tipo-colores/imagotipo-calado.png){#fig:imagotipo-calado-atelier}

*Nota.* Imagotipo secundario en configuraciones monocromáticas y azul corporativo.

- **Patrón Gráfico de Identidad:** La identidad visual incorpora una trama geométrica basada en la repetición lineal del isotipo corporativo, empleada como textura de soporte en fondos de pantallas de autenticación, portadas de módulos y recursos gráficos institucionales.

![Patrón gráfico de identidad visual de Atelier Workshop](report/assets/logo-tipo-colores/patron-identidad.png){#fig:patron-identidad-atelier}

*Nota.* Trama gráfica de soporte visual desarrollada a partir de la silueta del isotipo de marca.

**Sistema Tipográfico**

El sistema tipográfico de Atelier Workshop responde a criterios de rendimiento visual, legibilidad técnica y adaptabilidad responsiva en múltiples plataformas:

- **Albert Sans ExtraBold:** Fuente geométrica de trazo contundente utilizada de manera exclusiva en el imagotipo corporativo para las palabras Atelier y Workshop, proyectando solidez y autoridad en la marca.

- **Satoshi:** Tipografía sans-serif variable utilizada para el 100% de la interfaz de usuario en la aplicación web y móvil. Su diseño neutro, proporciones equilibradas y óptimo espaciado interno permiten una lectura fluida de descripciones mecánicas, números de identificación vehicular y tablas de repuestos.

![Escala tipográfica de la interfaz de usuario con la fuente Satoshi](report/assets/logo-tipo-colores/tipografia-satoshi.png){#fig:tipografia-satoshi-atelier}

*Nota.* Escala de pesos visuales de la tipografía Satoshi para títulos, subtítulos y cuerpo de texto.

A continuación se describe la jerarquía tipográfica oficial adoptada en el ecosistema, especificando los pesos, tamaños y funciones correspondientes a cada nivel de texto:

| Nivel Tipográfico | Familia y Peso | Tamaño y Escala | Uso Principal en la Interfaz |
| :--- | :---: | :---: | :--- |
| Imagotipo de Marca | Albert Sans ExtraBold | 28 px a 36 px | Bloque de texto corporativo Atelier Workshop en cabeceras. |
| Títulos Principales (H1) | Satoshi Bold | 24 px a 30 px | Encabezados principales de módulos, vistas y pantallas operativas. |
| Títulos de Sección (H2) | Satoshi Bold | 20 px a 22 px | Títulos de tarjetas de órdenes de trabajo y bloques de inventario. |
| Subtítulos de Tarjeta (H3) | Satoshi Medium | 16 px a 18 px | Nombres de clientes, modelos vehiculares y fases de servicio. |
| Cuerpo de Texto General | Satoshi Regular | 14 px a 15 px | Párrafos descriptivos, diagnósticos y notas periciales. |
| Metadatos y Datos Técnicos | Satoshi Medium | 12 px a 13 px | Números VIN, kilometrajes, códigos DTC y marcas temporales. |
| Microtextos y Etiquetas | Satoshi Bold | 10 px a 11 px | Insignias de estado en bahía, badges de lotes FIFO y alertas. |
: Jerarquía tipográfica del ecosistema Atelier Workshop {#tbl:jerarquia-tipografica}

*Nota.* Elaboración propia.

**Paleta Cromática Oficial y Tokens Semánticos**

La paleta cromática de Atelier Workshop está diseñada para garantizar un contraste ergonómico óptimo en ambientes de taller con iluminación artificial o luz solar directa, ofreciendo compatibilidad nativa con modos claro y oscuro.

![Paleta cromática oficial y tokens del sistema de diseño](report/assets/logo-tipo-colores/paleta-colores.png){#fig:paleta-colores-atelier}

*Nota.* Matriz cromática que ilustra colores primarios, colores de acento, superficies y estados semánticos.

A continuación se presenta el catálogo oficial de tokens cromáticos, su valor hexadecimal y su rol dentro del producto:

| Nombre del Token | Valor Hex | Muestra | Rol y Aplicación en la Interfaz |
| :--- | :---: | :---: | :--- |
| Azul Eléctrico (Primary) | `#0071EB` | ■ Azul | Botones primarios, isotipo corporativo, pestañas activas y cabeceras. |
| Azul Marino (Primary Dark) | `#031A6B` | ■ Marino | Estados de interacción hover en botones primarios y barras laterales oscuras. |
| Azul Celeste (Primary Soft) | `#69B1FF` | ■ Celeste | Fondos sutiles de insignias de estado para unidades en proceso de diagnóstico. |
| Naranja Ámbar (Accent) | `#F68B01` | ■ Ámbar | Botones de acción crítica, alertas de telemetría y hallazgos periciales urgentes. |
| Ámbar Oscuro (Accent Dark) | `#D87900` | ■ Dorado | Estados de interacción hover en botones de acento y avisos prioritarios. |
| Ámbar Suave (Accent Soft) | `#FFCD69` | ■ Suave | Fondo de etiquetas de mantenimiento preventivo y alertas predictivas. |
| Fondo Oscuro (Surface Black) | `#262626` | ■ Negro | Fondo principal de la interfaz en modo oscuro para evitar fatiga visual. |
| Fondo Claro (Surface White) | `#F8F8FA` | ■ Gris C | Fondo principal en modo claro, calibrado para reducir el deslumbramiento. |
| Tarjeta Oscura (Card Black) | `#272727` | ■ Oscuro | Contenedores modulares, tablas y paneles flotantes en modo oscuro. |
| Tarjeta Clara (Card White) | `#FFFFFF` | ■ Blanco | Contenedores de órdenes de trabajo, formularios y tarjetas en modo claro. |
| Texto Oscuro (Text Black) | `#262626` | ■ Negro | Tipografía principal de lectura y títulos sobre fondos claros. |
| Texto Claro (Text White) | `#FFFFFF` | ■ Blanco | Tipografía principal en modo oscuro y sobre botones de fondo sólido. |
| Subtítulos (Text Subtitles) | `#C6C6C6` | ■ Gris | Metadatos técnicos, números de serie, fechas y códigos de repuestos. |
| Borde Claro (Border Light) | `#C6C6C6` | ■ Borde C | Líneas divisorias y delimitadores de tarjetas sobre fondos claros. |
| Borde Oscuro (Border Dark) | `#EBEBEB` | ■ Borde O | Bordes divisorios sutiles para tarjetas y paneles sobre fondo negro. |
| Éxito (Success) | `#3AC530` | ■ Verde | Órdenes de trabajo liquidadas, stock disponible y telemetría óptima. |
| Error Crítico (Error) | `#FB2C36` | ■ Rojo | Códigos DTC confirmados, anomalías de motor y desconexión OBD-II. |
| Advertencia (Warning) | `#F0B100` | ■ Amarillo | Alerta de stock mínimo en lote FIFO y mantenimientos próximos a vencer. |
: Paleta cromática oficial y tokens del sistema de diseño {#tbl:paleta-colores}

*Nota.* Elaboración propia.

**Espaciado y Sistema de Retícula**

El dimensionamiento espacial de las interfaces sigue un sistema modular basado en una unidad base de 8 píxeles o puntos independientes de densidad, garantizando armonía y consistencia visual:

- **Microespaciado (8 dp / 8 px):** Utilizado para separar iconos de sus etiquetas de texto y para márgenes internos en botones compactos.

- **Espaciado Estándar (16 dp / 16 px):** Distancia predeterminada entre elementos relacionados dentro de una tarjeta, margen lateral de pantalla en dispositivos móviles y separación entre campos de formularios.

- **Espaciado de Sección (24 dp / 24 px):** Separación vertical entre bloques funcionales dentro de un módulo, como la distancia entre la cabecera del vehículo y la lista de tareas asignadas.

- **Espaciado Generoso (32 dp a 48 dp / 32 px a 48 px):** Separación entre contenedores mayores y márgenes perimétricos en paneles de escritorio.

**Tono de la Comunicación**

El lenguaje utilizado en las interfaces de Atelier Workshop se rige por los siguientes principios:

- **Técnico y Preciso:** Emplea terminología formal del sector automotriz e informático, evitando términos coloquiales o ambiguos en lecturas de sensores, diagnósticos de motor y estados de liquidación contable.

- **Asertivo y Conciso:** Proporciona instrucciones directas y resúmenes concretos para que el personal en bahía tome decisiones operativas inmediatas sin fricción de lectura.

- **Profesional y Accesible:** Mantiene un trato formal y respetuoso hacia dueños de taller, técnicos mecánicos y conductores de vehículos.

**Botones y Elementos Interactivos**

Los elementos interactivos del sistema están diseñados para facilitar la manipulación rápida y precisa en estaciones de trabajo y dispositivos móviles:

- **Dimensiones de Contacto Táctil:** Los botones principales presentan una altura mínima de 48 dp y un área táctil mínima de 48 dp por 48 dp, garantizando pulsaciones cómodas incluso al utilizar guantes de trabajo en el taller.

- **Radios de Borde:** Los botones y tarjetas emplean esquinas redondeadas con radios de 12 px (rounded-xl) y 16 px (rounded-2xl), generando una estética moderna y ergonómica.

- **Estados Interactivos Claros:** Todo componente interactivo cuenta con estados visualmente diferenciados para reposo normal, interacción hover, pulsación activa, estado deshabilitado y foco por teclado.

- **Elevación y Profundidad:** Se aplican sombras sutiles con niveles de elevación de 2 dp a 4 dp para distinguir modales flotantes, paneles desplegables y tarjetas activas sobre la superficie base.

#### 3.1.1.2. Web Style Guidelines



#### 3.1.1.3. Mobile Style Guidelines



\newpage

