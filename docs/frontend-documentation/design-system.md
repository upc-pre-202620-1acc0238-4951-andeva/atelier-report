# Atelier Workshop — Sistema de Diseño Canónico (Design System)

Este documento define la guía oficial y práctica de diseño visual para el ecosistema de **Atelier Workshop**, aplicable primordialmente en la aplicación web de gestión de talleres ([`atelier-workshop-webapp`](../../docs/atelier-documentation.md)) y como estándar de identidad visual para todas las interfaces del producto.

Está diseñado específicamente para integrarse de forma directa y sin fricciones con **Tailwind CSS v4**, aprovechando las clases nativas de Tailwind para escalas de tamaño (`text-sm`, `text-xl`), radios de borde (`rounded-md`, `rounded-xl`, `rounded-2xl`) y espaciados (`p-4`, `gap-3`), sin inventar configuraciones complejas e innecesarias.

Todos los activos vectoriales, logomarcas y fuentes tipográficas residen en [`docs/frontend-documentation/branding/`](branding/).

---

## 1. Identidad Visual de Marca y Logomarca

La identidad visual de **Atelier Workshop** se compone de los siguientes elementos contenidos en la carpeta [`branding/`](branding/):

### 1.1 Anatomía del Isotipo (El Símbolo)
El isotipo de Atelier Workshop representa formalmente el **perfil técnico de un mecánico automotriz profesional**:
* **Significado y Concepto:** La silueta estilizada combina una gorra de trabajo industrial con visera, lentes de protección pericial y cuello de overol técnico. Encarna la dignidad de la labor en foso y elevador, la precisión de la ingeniería automotriz y la evolución digital del taller mecánico hacia la telemetría inteligente y el diagnóstico predictivo.
* **Archivos vectoriales y variantes oficiales disponibles:**
  * [`branding/atelier-workshop-isotipo-blue.svg`](branding/atelier-workshop-isotipo-blue.svg) / [`.png`](branding/atelier-workshop-isotipo-blue.png): Isotipo oficial en azul primario de marca (`#0071EB`) con silueta calada de alto impacto visual.
  * [`branding/atelier-workshop-isotipo-black.svg`](branding/atelier-workshop-isotipo-black.svg) / [`.png`](branding/atelier-workshop-isotipo-black.png): Isotipo oficial en negro neutro (`#262626`) para interfaces monocromáticas, documentos impresos o sellos técnicos.
  * [`branding/atelier-workshop-icon.svg`](branding/atelier-workshop-icon.svg) / [`.png`](branding/atelier-workshop-icon.png) / [`.ico`](branding/atelier-workshop-icon.ico): Isotipo blanco dentro de un contenedor redondeado (*squircle*) en azul primario (`#0071EB`) con radio de 110px, optimizado para el favicon de navegadores web y accesos directos de la aplicación.

### 1.2 Anatomía del Imagotipo (Isotipo en Squircle + Texto «Atelier Workshop»)
El imagotipo principal integra el símbolo gráfico y el bloque de texto corporativo a dos líneas:
* **Construcción:** A la izquierda se sitúa el isotipo blanco enmarcado en el contenedor redondeado (*squircle*) azul o negro. A su derecha se despliega el logotipo en dos líneas horizontales alineadas a la izquierda: «**Atelier**» en la línea superior y «**Workshop**» en la línea inferior.
* **Tipografía del Imagotipo:** El texto del imagotipo utiliza la fuente **Albert Sans ExtraBold** ([`branding/albert-sans/AlbertSans-ExtraBold.ttf`](branding/albert-sans/AlbertSans-ExtraBold.ttf)). Sus trazos geométricos contundentes, grosores uniformes y apertura moderna transmiten autoridad técnica, robustez industrial y confianza en el software de gestión.
* **Archivos vectoriales y variantes disponibles:**
  * [`branding/atelier-workshop-imagotipo-blue.svg`](branding/atelier-workshop-imagotipo-blue.svg) / [`.png`](branding/atelier-workshop-imagotipo-blue.png): Imagotipo oficial en azul Atelier (`#0071EB`) para fondos claros y encabezados de la aplicación web.
  * [`branding/atelier-workshop-imagotipo-black.svg`](branding/atelier-workshop-imagotipo-black.svg) / [`.png`](branding/atelier-workshop-imagotipo-black.png): Variante en negro puro (`#262626`) para contrastes altos o entornos monocromáticos.

---

## 2. Paleta Cromática y Color de Acento

La paleta cromática oficial de Atelier Workshop parte de las definiciones consignadas en [`branding/pallette.txt`](branding/pallette.txt), estructuradas para el rigor operativo del taller:

| Variable | Valor Hex | Muestra | ¿Para qué se usa en el producto? |
| :--- | :--- | :---: | :--- |
| `primary` | `#0071EB` | `■` | **Azul Eléctrico Atelier:** Botones principales de acción, isotipo corporativo, pestañas activas de navegación y cabeceras de módulos MRO. |
| `primary-dark` | `#031A6B` | `■` | **Azul Marino Profundo:** Estados hover de botones primarios (`hover:bg-primary-dark`), barras laterales oscuras y bordes de selección activa. |
| `primary-soft` | `#69B1FF` | `■` | **Azul Celeste Suave:** Fondos tenues para insignias de estado (*badges* de vehículos en bahía), selección secundaria y estados de foco. |
| `accent` | `#F68B01` | `■` | **Naranja Ámbar de Acento:** Llamadas a la acción de alta prioridad, alertas de telemetría IoT, órdenes de trabajo con vicios ocultos detectados y acciones críticas. |
| `accent-dark` | `#D87900` | `■` | **Ámbar Oscuro:** Estados hover de botones de acento (`hover:bg-accent-dark`). |
| `accent-soft` | `#FFCD69` | `■` | **Ámbar Dorado Suave:** Fondo de tarjetas de atención prioritaria, etiquetas de mantenimiento preventivo y alertas predictivas intermedias. |
| `surface-black` | `#262626` | `■` | **Fondo oscuro:** Fondo principal de la aplicación en modo nocturno (`dark`), reduciendo la fatiga visual del personal en piso o turnos extendidos. |
| `surface-white` | `#F8F8FA` | `■` | **Fondo claro:** Fondo principal en modo claro (`light`). Tono tenue calibrado para evitar deslumbramiento visual bajo luz artificial de taller. |
| `card-black` | `#272727` | `■` | **Tarjeta oscura:** Contenedores de órdenes de trabajo, módulos de inventario FIFO y paneles flotantes en modo oscuro. |
| `card-white` | `#FFFFFF` | `■` | **Tarjeta clara:** Contenedores de órdenes de trabajo, tablas y tarjetas analíticas en modo claro. |
| `text-black` | `#262626` | `■` | **Texto oscuro:** Tipografía principal de lectura en modo claro. |
| `text-white` | `#FFFFFF` | `■` | **Texto blanco:** Tipografía principal en modo oscuro y sobre botones con fondos sólidos primarios o acentos. |
| `text-subtitles` | `#C6C6C6` | `■` | **Subtítulos y Metadatos:** Textos secundarios, kilometrajes, números de chasis (VIN), códigos de repuestos y marcas temporales. |
| `border-card-dark` | `#EBEBEB` | `■` | **Bordes oscuros:** Líneas divisorias y bordes de tarjetas sobre fondo negro. |
| `border-card-light` | `#C6C6C6` | `■` | **Bordes claros:** Líneas divisorias y bordes de tarjetas sobre fondo blanco. |
| `success` | `#3AC530` | `■` | **Éxito Operativo:** Órdenes de trabajo finalizadas y liquidadas, stock disponible verificado y telemetría en estado óptimo. |
| `error` | `#FB2C36` | `■` | **Error Crítico:** Códigos de falla de motor severos (DTC confirmados), anomalías de sobrecalentamiento, desconexión de escáneres OBD2 y roturas de stock. |
| `warning` | `#F0B100` | `■` | **Advertencia Preventiva:** Niveles mínimos de stock en lotes FIFO, servicios programados por vencer y alertas predictivas de desgaste. |

---

## 3. Tipografía Oficial: Satoshi y Albert Sans ExtraBold

El sistema tipográfico de Atelier Workshop responde a exigencias de legibilidad técnica y rendimiento web:

1. **Albert Sans ExtraBold:** Uso exclusivo de marca para el texto del imagotipo («Atelier Workshop»), ubicada en [`branding/albert-sans/AlbertSans-ExtraBold.ttf`](branding/albert-sans/AlbertSans-ExtraBold.ttf). Se declara como `@font-face` con `font-family: 'Albert Sans'` y peso `800` (ExtraBold), configurada en `@theme` como `--font-imagotipo` y utilizable directamente con la clase utilitaria `font-imagotipo`.
2. **Satoshi:** Tipografía oficial para el 100% de la interfaz de usuario (UI), ubicada en formato WOFF2 optimizado en [`branding/satoshi/`](branding/satoshi/).
   * **Carga optimizada en `global.css`:**
     * `font-display: swap`: Garantiza el renderizado inmediato del texto mediante una tipografía del sistema mientras se descargan los archivos WOFF2, eliminando el parpadeo de texto invisible (*Flash of Invisible Text*).
     * `unicode-range` (subconjunto latino): Filtra la fuente para cargar únicamente el abecedario latino, caracteres acentuados en español (`á, é, í, ó, ú`, `ñ`), signos de puntuación y monedas (`S/`, `$`, `€`). Esto reduce el peso de descarga a solo ~25-40 KB.
     * `font-weight: 300 900` (Variable Font): Un único archivo (`Satoshi-Variable.woff2`) proporciona fluidamente todos los pesos tipográficos (Light, Regular, Medium, Bold, Black) sin requerir peticiones de red adicionales.
   * **Integración con Tailwind v4:** Se asigna como la fuente sans-serif por defecto mediante la clase estándar `font-sans`.
   * **Escala de tamaños:** Utiliza las clases utilitarias nativas de Tailwind CSS: `text-xs`, `text-sm`, `text-base`, `text-lg`, `text-xl`, `text-2xl`, `text-3xl`, `text-4xl`, etc.

---

## 4. ¿Cómo Funciona Tailwind CSS v4 con Nuestros Colores?

### 4.1 ¿Qué es la directiva `@theme`?
En versiones anteriores de Tailwind (v3) era necesario mantener un archivo JavaScript externo (`tailwind.config.js`).

En **Tailwind CSS v4**, la configuración se realiza directamente en código CSS nativo mediante el bloque `@theme`.

Al declarar los tokens de Atelier Workshop dentro del bloque `@theme`:
```css
@theme {
  --font-sans: 'Satoshi', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  --font-imagotipo: 'Albert Sans', 'Satoshi', sans-serif;

  --color-primary: #0071EB;
  --color-primary-dark: #031A6B;
  --color-primary-soft: #69B1FF;

  --color-accent: #F68B01;
  --color-accent-dark: #D87900;
  --color-accent-soft: #FFCD69;

  --color-surface-black: #262626;
  --color-surface-white: #F8F8FA;

  --color-card-black: #272727;
  --color-card-white: #FFFFFF;

  --color-text-black: #262626;
  --color-text-white: #FFFFFF;
  --color-text-subtitles: #C6C6C6;

  --color-border-card-dark: #EBEBEB;
  --color-border-card-light: #C6C6C6;

  --color-success: #3AC530;
  --color-error: #FB2C36;
  --color-warning: #F0B100;
}
```

El compilador de Tailwind v4 interpreta automáticamente estas propiedades personalizadas y **genera al vuelo todas las clases utilitarias del framework**:
* Clases de fondo: `bg-primary`, `bg-accent`, `bg-card-white`, `bg-surface-black`.
* Clases de texto: `text-primary`, `text-accent`, `text-text-black`, `text-text-subtitles`.
* Clases de borde: `border-primary`, `border-border-card-light`, `border-border-card-dark`.
* Clases de tipografía: `font-sans`, `font-imagotipo`.

---

## 5. Guía Rápida de Clases en Tailwind (Cheat Sheet)

Relación directa de clases utilitarias para construir interfaces en React, Astro o HTML:

### 5.1 Fondos (`bg-*`)
* `bg-primary` → Fondo azul eléctrico corporativo (`#0071EB`).
* `hover:bg-primary-dark` → Hover del botón primario (`#031A6B`).
* `bg-primary-soft` → Fondo azul celeste para insignias de bahía asignada o diagnósticos en curso (`#69B1FF`).
* `bg-accent` → Fondo naranja ámbar para acciones críticas o alertas periciales (`#F68B01`).
* `hover:bg-accent-dark` → Hover de botones de acento (`#D87900`).
* `bg-accent-soft` → Fondo ámbar suave para etiquetas de tareas con hallazgos imprevistos (`#FFCD69`).
* `bg-surface-white` → Fondo general en modo claro (`#F8F8FA`).
* `bg-surface-black` → Fondo general en modo nocturno (`#262626`).
* `bg-card-white` → Fondo de tarjeta o tabla en modo claro (`#FFFFFF`).
* `bg-card-black` → Fondo de tarjeta o contenedor en modo oscuro (`#272727`).
* `bg-success`, `bg-error`, `bg-warning` → Fondos para estados semánticos del sistema.

### 5.2 Textos (`text-*`)
* `text-primary` → Texto azul corporativo para enlaces, subtítulos activos y métricas clave (`#0071EB`).
* `text-accent` → Texto ámbar para resaltar averías predictivas y presupuestos urgentes (`#F68B01`).
* `text-text-black` → Tipografía de lectura principal en modo claro (`#262626`).
* `text-text-white` → Tipografía principal en modo oscuro y sobre botones de fondo oscuro (`#FFFFFF`).
* `text-text-subtitles` → Metadatos técnicos, VINs, kilometrajes y horas de mano de obra (`#C6C6C6`).
* `text-success`, `text-error`, `text-warning` → Textos para estados del vehículo y de inventario.

### 5.3 Bordes (`border-*`)
* `border-primary` → Borde azul para tarjetas seleccionadas o inputs en foco.
* `border-accent` → Borde ámbar para tareas con hallazgos periciales pendientes de aprobación.
* `border-border-card-light` → Borde sutil para tarjetas en modo claro (`#C6C6C6`).
* `border-border-card-dark` → Borde divisorio para tarjetas en modo oscuro (`#EBEBEB`).

### 5.4 Modo Claro y Modo Oscuro Sencillo
Para garantizar alternancia fluida entre el modo diurno y nocturno del taller, se utiliza el modificador estándar `dark:` de Tailwind:

```html
<!-- Componente Canónico: Tarjeta de Orden de Trabajo MRO -->
<div class="bg-card-white dark:bg-card-black border border-border-card-light dark:border-border-card-dark text-text-black dark:text-text-white rounded-2xl p-6 shadow-sm transition-colors">
  <div class="flex items-center justify-between">
    <span class="bg-accent-soft text-accent-dark dark:text-text-black px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider">
      Alerta Telemetría IoT
    </span>
    <span class="text-text-subtitles text-xs font-mono">VIN: 1HGCR2F83HA00192</span>
  </div>

  <h3 class="text-xl font-bold mt-3">Orden #OT-2026-084 · Toyota Hilux 2.8 TDI</h3>
  <p class="text-text-subtitles text-sm mt-1">Bahía 3 · Mecánico: Carlos Mendoza · Código DTC: P0301</p>

  <div class="mt-5 pt-4 border-t border-border-card-light/40 dark:border-border-card-dark/20 flex items-center justify-between">
    <div>
      <span class="block text-xs text-text-subtitles uppercase">Presupuesto MRO</span>
      <span class="text-2xl font-extrabold text-primary">S/ 485.00</span>
    </div>

    <div class="flex gap-2">
      <button class="border border-border-card-light dark:border-border-card-dark text-text-black dark:text-text-white px-4 py-2 rounded-xl text-sm font-semibold hover:bg-surface-white dark:hover:bg-surface-black transition-colors">
        Ver Evidencias
      </button>
      <button class="bg-primary hover:bg-primary-dark text-text-white px-5 py-2 rounded-xl text-sm font-semibold shadow-sm transition-colors">
        Aprobar Tarea
      </button>
    </div>
  </div>
</div>
```

---

## 6. Archivo Único Listo para Usar: `global.css`

Todo el sistema de diseño se consolida en un **único archivo maestro de estilos** preparado para ser copiado directamente a la base de código de la aplicación:

👉 **[`styles/global.css`](styles/global.css)**

```css
/**
 * Atelier Workshop — Archivo Maestro de Estilos Globales (Tailwind CSS v4)
 * -----------------------------------------------------------------------------
 * Este es el ÚNICO archivo CSS que necesitas copiar y pegar en tus proyectos web:
 *   - En atelier-workshop-webapp: src/styles/global.css (se importa en main.tsx / App.tsx)
 *
 * Contiene:
 *   1. Importación oficial del motor de Tailwind CSS v4.
 *   2. Carga optimizada de Satoshi y Albert Sans ExtraBold (WOFF2 / TTF, font-display: swap, unicode-range).
 *   3. Bloque @theme con todos los colores corporativos de Atelier Workshop y acentos.
 *   4. Estilo base global para el body.
 */

/* =============================================================================
   1. Importación del Motor de Tailwind CSS v4
   ============================================================================= */
@import "tailwindcss";

/* =============================================================================
   2. Carga Optimizada de Tipografías Oficiales (Satoshi & Albert Sans ExtraBold)
   ============================================================================= */

/* Fuente Variable Normal (Satoshi: pesos 300 a 900 en un solo archivo) */
@font-face {
  font-family: 'Satoshi';
  font-style: normal;
  font-weight: 300 900;
  font-display: swap;
  src: url('/fonts/satoshi/Satoshi-Variable.woff2') format('woff2-variations'),
       url('/fonts/satoshi/Satoshi-Variable.woff2') format('woff2');
  unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+0304, U+0308, U+0329, U+2000-206F, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD;
}

/* Fuente Variable Cursiva (Satoshi: pesos 300 a 900 en un solo archivo) */
@font-face {
  font-family: 'Satoshi';
  font-style: italic;
  font-weight: 300 900;
  font-display: swap;
  src: url('/fonts/satoshi/Satoshi-VariableItalic.woff2') format('woff2-variations'),
       url('/fonts/satoshi/Satoshi-VariableItalic.woff2') format('woff2');
  unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+0304, U+0308, U+0329, U+2000-206F, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD;
}

/* Tipografía de Marca para el Imagotipo (Albert Sans ExtraBold - TTF) */
@font-face {
  font-family: 'Albert Sans';
  font-style: normal;
  font-weight: 800;
  font-display: swap;
  src: url('/fonts/albert-sans/AlbertSans-ExtraBold.ttf') format('truetype');
  unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+0304, U+0308, U+0329, U+2000-206F, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD;
}

/* =============================================================================
   3. Configuración del Tema de Tailwind CSS v4 (@theme)
   ============================================================================= */
@theme {
  --font-sans: 'Satoshi', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  --font-imagotipo: 'Albert Sans', 'Satoshi', sans-serif;

  /* Colores Primarios (Atelier Electric Blue & Deep Navy) */
  --color-primary: #0071EB;
  --color-primary-dark: #031A6B;
  --color-primary-soft: #69B1FF;

  /* Colores de Acento (Atelier Amber Orange & Gold) */
  --color-accent: #F68B01;
  --color-accent-dark: #D87900;
  --color-accent-soft: #FFCD69;

  /* Superficies (Fondos) */
  --color-surface-black: #262626;
  --color-surface-white: #F8F8FA;

  /* Tarjetas y Paneles (Cards) */
  --color-card-black: #272727;
  --color-card-white: #FFFFFF;

  /* Textos */
  --color-text-black: #262626;
  --color-text-white: #FFFFFF;
  --color-text-subtitles: #C6C6C6;

  /* Bordes de Tarjetas */
  --color-border-card-dark: #EBEBEB;
  --color-border-card-light: #C6C6C6;

  /* Estados Funcionales del Sistema */
  --color-success: #3AC530;
  --color-error: #FB2C36;
  --color-warning: #F0B100;
}

/* =============================================================================
   4. Configuración Base Global
   ============================================================================= */
body {
  font-family: var(--font-sans);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
```

*(Nota técnica: para proyectos que prefieran modularización física de estilos, en la carpeta [`styles/`](styles/) se conservan por separado [`styles/typography.css`](styles/typography.css), [`styles/theme.css`](styles/theme.css) y [`styles/index.css`](styles/index.css)).*

---

## 7. ¿Dónde se Pega y Cómo se Usa en tus Proyectos?

### 7.1 En la Aplicación Web (`atelier-workshop-webapp` - React 19 + Vite 6)
1. Copias los directorios de fuentes desde [`branding/`](branding/):
   - `branding/satoshi/` $\rightarrow$ `public/fonts/satoshi/`
   - `branding/albert-sans/` $\rightarrow$ `public/fonts/albert-sans/`
2. Copias el archivo [`styles/global.css`](styles/global.css) a `src/styles/global.css`.
3. En el punto de entrada de la aplicación (`src/main.tsx`), importas el archivo:
   ```tsx
   import React from 'react';
   import ReactDOM from 'react-dom/client';
   import App from './App';
   import './styles/global.css';

   ReactDOM.createRoot(document.getElementById('root')!).render(
     <React.StrictMode>
       <App />
     </React.StrictMode>
   );
   ```
4. En tu `index.html` vinculas el favicon corporativo:
   ```html
   <link rel="icon" type="image/svg+xml" href="/branding/atelier-workshop-icon.svg" />
   ```

### 7.2 En Proyectos Astro / SSR / Documentación
1. Copias las carpetas de fuentes a `public/fonts/satoshi/` y `public/fonts/albert-sans/`.
2. Copias [`styles/global.css`](styles/global.css) a `src/styles/global.css`.
3. En la plantilla base (`src/layouts/Layout.astro`):
   ```astro
   ---
   import '../styles/global.css';
   ---
   <html lang="es">
     <head>
       <meta charset="UTF-8" />
       <link rel="icon" type="image/svg+xml" href="/branding/atelier-workshop-icon.svg" />
     </head>
     <body class="bg-surface-white dark:bg-surface-black text-text-black dark:text-text-white">
       <slot />
     </body>
   </html>
   ```

Con esta única importación, la totalidad de las clases utilitarias de Tailwind v4 (`bg-primary`, `hover:bg-primary-dark`, `text-accent`, `bg-card-white`, `dark:bg-card-black`, `rounded-2xl`, etc.) quedan disponibles y configuradas de manera inmediata en todo el proyecto.
