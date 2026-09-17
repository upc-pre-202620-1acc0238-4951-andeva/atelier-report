# AGENTS.md - Protocolos de Operación para Agentes Autónomos (Atelier)

Este documento define los protocolos de trabajo, roles especializados, habilidades y compuertas de calidad (*quality gates*) para los agentes de Inteligencia Artificial que colaboran en el repositorio **Atelier Report**.

---

## 1. Roles Especializados y Subagentes

El ecosistema de desarrollo cuenta con perfiles especializados para tareas complejas:

| Perfil / Agente | Enfoque Principal | Herramientas y Responsabilidades |
| :--- | :--- | :--- |
| **agent-architect** | Arquitectura y Diseño | Modelado de dominios DDD, esquemas PostgreSQL/TimescaleDB, diseño de APIs REST y patrones de resiliencia. |
| **agent-reviewer** | Calidad y Auditoría Técnica | Auditoría de código, verificación de normas académicas (APA 7), detección de inconsistencias y seguridad. |
| **agent-debugger** | Diagnóstico y Hotfixes | Análisis de causa raíz en errores de compilación Pandoc/LaTeX, dependencias o scripts de automatización. |
| **agent-refactorer** | Código Limpio y Estilo | Simplificación de macros LaTeX, normalización de tablas, balance tipográfico y legibilidad de prosa. |
| **agent-tester** | QA y Validación | Verificación de suites de prueba, validación de criterios BDD Gherkin y consistencia de esquemas. |
| **research** | Exploración y Lectura | Análisis exploratorio de fuentes, documentación en `/docs` y recuperación de referencias bibliográficas. |

---

## 2. Catálogo de Habilidades (*Skills*) Activas

Antes de realizar modificaciones sustanciales, los agentes deben consultar y activar las habilidades pertinentes:

- **academic-report-writer:** Directrices mandatorias de redacción académica, estilo formal, erradicación de «markdown soup» y moderación visual de tablas/figuras para el reporte de tesis.
- **academic-report-reviewer:** Auditoría rigurosa para detectar violaciones a las normas de redacción (comillas invertidas excesivas, rayas `—`, menciones a la rúbrica, notas extensas).
- **ddd-strategic-design:** Diseño estratégico en DDD (subdominios, contextos acotados, lenguaje ubicuo y mapas de contexto).
- **architecture-patterns:** Implementación de Arquitectura Limpia, Arquitectura Hexagonal y patrones tácticos de dominio.
- **api-designer / rest-api-design:** Especificaciones OpenAPI, modelado de recursos RESTful, convenciones HTTP y códigos de estado.
- **postgres:** Buenas prácticas relacionales, particionamiento de telemetría con hipertablas en TimescaleDB y optimización de consultas.
- **user-story:** Estructuración de historias bajo formato Mike Cohn y criterios de aceptación BDD en sintaxis Gherkin verificable.

---

## 3. Protocolo de Verificación Determinista (*Verification Loop*)

Ninguna tarea sobre el reporte se considera completada sin superar el ciclo de verificación determinista:

```
[ Modificación de Contenido ] 
            ↓
[ Compilación con Docker: make single SRC=report/.../archivo.md ]
            ↓
[ Verificación de Código de Salida (Exit Code 0) ]
            ↓
[ Inspección Visual y Geométrica (pdftoppm / pdftotext -bbox-layout) ]
            ↓
[ Entrega y Comunicación al Usuario ]
```

### Reglas de Verificación Técnica
1. **Compilación Docker:** Comprobar siempre que `make single SRC=...` finalice con código de salida `0`.
2. **Inspección de Sangrías y Geometría:** Para tablas complejas (`longtable`), verificar mediante `pdftotext -bbox-layout` que la coordenada `xMin` de títulos y contenidos coincida exactamente con el margen de la página (`72.00 pt` para márgenes de 1 pulgada).
3. **Inspección Visual:** Convertir las páginas generadas a imagen PNG mediante `pdftoppm` y visualizarlas con `view_file` para certificar alineación y estética visual.

---

## 4. Compuertas de Calidad (*Quality Gates*)

Cualquier propuesta o cambio debe superar la siguiente lista de control obligatoria:

- [ ] **Cero menciones a la evaluación:** Prohibida cualquier alusión a «según la rúbrica», «criterios de evaluación» o «para cumplir con el ítem».
- [ ] **Cero rayas em dash (`—`):** Queda terminantemente prohibido el uso de guiones largos (`—`) en notas, descripciones o párrafos narrativos.
- [ ] **Cero punto y coma (`;`):** Prohibido el uso de punto y coma tanto en prosa corrida como en celdas de tablas; usar punto seguido o viñetas.
- [ ] **Cero abuso de paréntesis:** Prohibidos paréntesis traductores, explicativos de ejemplos o en encabezados/subtítulos.
- [ ] **Figuras sin numeración en Front-Matter:** Las capturas de prefacios (ej. analíticos de colaboración) no llevan `{#fig:...}` ni rótulos de «Figura X».
- [ ] **Terminología formal Anexo F:** Uso estricto de *Biblioteca*, *Requisito*, *Aplicación*, *Despliegue*, y el término técnico *commit* para registros de control de versiones.
- [ ] **Sin notas redundantes sobre APA 7:** Las notas de tablas y figuras deben limitarse a la fuente o descripción del contenido, omitiendo la frase «según la norma APA 7».
- [ ] **Notas concisas:** Longitud estricta de 1 a 2 líneas en notas de tablas y figuras (`*Nota.* ...`).
- [ ] **Jerarquía de títulos:** Solo `## 2.4.`, `### 2.4.1.`, `### 2.4.2.` y `### 2.4.3.` emplean marcadores `#`. Subtítulos menores usan negrita en línea (`**...**`).
- [ ] **Tope de Story Points:** Toda historia de usuario o técnica debe estar acotada a $\le 5$ SP (1, 2, 3 o 5).
- [ ] **Estricto pnpm:** Nunca usar comandos `npm`, `npx` o `yarn`.

---

## 5. Comunicación con el Usuario

- Mantener respuestas concisas, estructuradas y en Markdown.
- Proporcionar siempre enlaces clickeables a los archivos y símbolos de código utilizando el esquema `file://` (ej. `[24-requirements-specification.md](file:///home/shouy/development/atelier-report/report/chapters/20-requirements-development-and-software-solution-design/24-requirements-specification.md)`).
- Evitar suposiciones sobre intenciones ambiguas; solicitar clarificación cuando sea necesario.
