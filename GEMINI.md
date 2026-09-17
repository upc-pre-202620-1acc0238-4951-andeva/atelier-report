# GEMINI.md - Contexto y Directrices de Ingeniería para el Proyecto Atelier

Este archivo proporciona el contexto del proyecto, las restricciones del entorno y los estándares de ingeniería para los modelos de Inteligencia Artificial (Gemini y Antigravity CLI) que operan en este repositorio.

---

## 1. Visión General del Proyecto

**Atelier** es una plataforma SaaS B2B multiplataforma diseñada para profesionalizar y digitalizar talleres mecánicos automotrices micro y pequeños (MYPE) en Lima Metropolitana y el mercado latinoamericano.

### Núcleo de Valor y Dominio Tecnológico
- **Ecosistema SaaS B2B:** Compuesto por una aplicación móvil nativa Android de uso rudo (*Atelier Workshop Mobile*) con arquitectura *Offline-First* para mecánicos en bahía/fosa, un panel administrativo web (*Dashboard*) y un backend modular (*Atelier Platform Backend*).
- **Ingesta Telemática IoT:** Diagnóstico vehicular computarizado mediante conectividad Bluetooth con escáneres OBD-II estándar, decodificación de códigos de falla DTC y telemetría de parámetros en vivo (PIDs) complementada con inferencia predictiva (*Spring AI*).
- **Control de Patio y Bahías:** Órdenes de trabajo digitales, evidencias fotográficas periciales inmutables *Direct-to-Cloud*, cronometraje de labor efectiva por tarea y control perimétrico de asistencia mediante geocerca (*Haversine*).
- **Inventario y Finanzas:** Gestión de stock valorizada bajo el método contable **FIFO estricto por lote** (*First-In, First-Out*) y facturación electrónica nativa bajo estándar UBL 2.1 ante la SUNAT (Régimen MYPE Tributario).
- **Arquitectura de Software:** Arquitectura Limpia (*Clean Architecture*) y Diseño Guiado por el Dominio (*Domain-Driven Design*, DDD) hexagonal modular.

---

## 2. Reglas Estrictas del Entorno

### 2.1. Gestor de Paquetes: Uso Exclusivo de `pnpm`
- **Obligatorio:** Utilizar siempre `pnpm` (`pnpm install`, `pnpm add`, `pnpm run <script>`).
- **Prohibido:** Jamás utilizar `npm`, `npx` ni `yarn`.
- **Ejecución remota:** Utilizar `pnpm dlx` en lugar de `npx`.

### 2.2. Flujo Docs as Code Contenerizado
- **Compilación sin dependencias locales:** Todo el reporte académico se compila mediante contenedores oficiales de Docker (`pandoc/extra:3.8.3`, `plantuml`, `structurizr`).
- **Comando de previsualización rápida:**
  ```bash
  make single SRC=report/chapters/XX-seccion/YY-archivo.md
  ```
  Genera el artefacto PDF en `build/single-output.pdf`.
- **Compilación integral del reporte:**
  ```bash
  make pdf
  ```

---

## 3. Directrices de Redacción Académica y Formato (Reporte de Tesis)

Al redactar o modificar cualquier archivo dentro de `report/` o `docs/`, se deben aplicar estrictamente las directrices de `academic-report-writer`:

1. **Voz y Tono Formal:**
   - Redactar en tercera persona del plural («el equipo implementó», «se determinó») o de manera impersonal.
   - Prohibido el uso de primera persona del singular («yo hice») o expresiones coloquiales.
2. **Prohibición Total de Menciones a la Rúbrica («Romper la Cuarta Pared»):**
   - Jamás incluir frases como «según la rúbrica», «cumpliendo los criterios de evaluación» o «para cumplir con el ítem».
   - El reporte es una memoria profesional de ingeniería y arquitectura, no una tarea estudiantil.
3. **Erradicación Total de Rayas Em Dash (`—`):**
   - No usar rayas (`—`) como incisos o aclaraciones. Emplear comas gramaticales sobrias, preposiciones directas o reestructurar la sintaxis.
4. **Prohibición de Paréntesis Traductores, Explicativos o en Encabezados:**
   - Quedan prohibidas duplicaciones como `levantamiento de necesidades (Needfinding)`, `códigos de falla (DTC)`, `mapeo de experiencia (User Journey Mapping)`.
   - Prohibido el uso de paréntesis en títulos y subtítulos como `(Problem Statements)` o `(Task Proposals)`. Emplear redacción directa articulada con preposiciones o dos puntos.
   - Prohibidos los incisos de ejemplos entre paréntesis («por ejemplo, ...», «ej. ...»).
   - Los paréntesis quedan reservados estrictamente a citas bibliográficas APA 7, referencias cruzadas Pandoc (`@fig:...`, `@tbl:...`), signaturas de métodos (`metodo()`) y restricciones matemáticas formales.
5. **Prohibición Estricta de Punto y Coma (`;`):**
   - Prohibido el uso de punto y coma (`;`) tanto en prosa corrida como en celdas de tablas.
   - En prosa, fragmentar las oraciones compuestas en enunciados independientes mediante punto seguido (`.`).
   - En tablas, estructurar múltiples elementos o responsabilidades mediante saltos de línea (`\newline` en LaTeX o saltos en Markdown) o viñetas con guion (`- `).
6. **Normalización Terminológica y Traducciones (Anexo F):**
   - Emplear traducciones técnicas formales: *Biblioteca* (nunca librería), *Requisito* (nunca requerimiento), *Aplicación* (nunca aplicativo), *Obtener* (nunca elicitar), *Despliegue/Desplegar* (nunca deploy/deployar).
   - Prohibidas las mutaciones verbales en espanglish (*testear, comitear, buildear*).
   - Para el historial de control de versiones de GitHub, emplear de forma técnica el término **«commit»** (en minúsculas o cursiva según contexto, evitando perífrasis confusas).
7. **Figuras en Secciones del Prefacio (Front-Matter):**
   - En secciones introductorias o colaborativas del prefacio (*Project Report Collaboration Insights*), las capturas no deben numerarse como figuras formales (sin `{#fig:...}` ni rótulos de «Figura X»). Deben presentarse con título descriptivo en negrita (`**...**`), imagen centrada y nota explicativa concisa.
8. **Notas de Tablas y Figuras:**
   - Extensión estricta de **1 a 2 líneas**.
   - No incluir frases como «según la norma APA 7» ni referencias a la rúbrica; limitarse a la fuente o descripción del contenido.
9. **Jerarquía Estricta de Títulos:**
   - Solo los encabezados principales del estándar llevan marcadores Markdown (`## 2.4.`, `### 2.4.1.`, `### 2.4.2.`, `### 2.4.3.`).
   - Los subtítulos de historias individuales o artefactos no numerados deben usar negrita en línea (`**...**`).
10. **Límite de Esfuerzo en Historias:**
   - Ninguna historia de usuario o técnica puede superar los **5 Story Points** (escala permitida: 1, 2, 3 o 5 SP).

---

## 4. Estructura de Directorios

```text
├── .agents/          # Habilidades (skills) de ingeniería y patrones de arquitectura
├── build/            # Salidas compiladas en PDF (single-output.pdf, reporte completo)
├── docs/             # Especificaciones técnicas, arquitectura y esquemas de base de datos
│   ├── atelier-architecture-guide.md
│   ├── atelier-database-schema.md
│   ├── atelier-documentation.md
│   ├── how-to-use.md
│   └── project-statement.md
├── pandoc/           # Configuración de compilación Pandoc, filtros Lua, CSL y plantillas
│   ├── report.yaml   # Configuración base (márgenes, APA 7, captions, lualatex)
│   └── filters/      # Filtros Lua para tablas, cabeceras y referencias
├── report/           # Contenido fuente del reporte académico (Docs as Code)
│   ├── front-matter/ # Portada, abstract, student outcomes, metas SMART
│   ├── chapters/     # Capítulos I (Presentación), II (Requisitos), III (Arquitectura DDD)
│   ├── back-matter/  # Conclusiones, glosario, bibliografía
│   └── assets/       # Diagramas, fotografías, mockups e imagotipos
└── scripts/          # Automatizaciones, validadores y scripts de ingesta
```
