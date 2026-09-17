# Project Report Collaboration Insights {- .unlisted}

**Enlace a los repositorios y organización de GitHub**

- **Organización de GitHub de andeva:** [upc-pre-202620-1acc0238-4951-andeva](https://github.com/upc-pre-202620-1acc0238-4951-andeva)

- **Repositorio de GitHub del reporte:** [atelier-report](https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier-report)

- **Repositorio de GitHub del website:** [atelier-website](https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier-website)

- **Repositorio de GitHub del platform:** [atelier-platform](https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier-platform)

- **Repositorio de GitHub del mobile native:** [atelier-mobile-android](https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier-mobile-android)

- **Repositorio de GitHub del mobile crossplatform:** [atelier-mobile-crossplatform](https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier-mobile-crossplatform)

**Reporte de colaboración del AV1**

Para la elaboración del presente informe técnico, el equipo adoptó de manera integral la metodología Docs as Code, tratando la documentación con el mismo rigor técnico y disciplina que el desarrollo de software. Los archivos fuente se estructuraron modularmente en formato Markdown dentro del repositorio oficial atelier-report en GitHub, permitiendo una trazabilidad completa de cada modificación.

El flujo de trabajo se apoyó en un modelo de ramas estructurado. La integración continua de artefactos se centralizó en la rama principal develop a través de ramas de características feature y ramas de estabilización release para cada versión intermedia, aplicando un esquema de versionamiento semántico que abarcó desde la versión inicial 0.8.0 hasta la versión 0.42.0. Asimismo, para asegurar la paridad tipográfica y eliminar discrepancias entre sistemas operativos, el equipo utilizó un entorno de compilación contenerizado en Docker basado en Pandoc 3.8.3, LuaLaTeX y filtros Lua automatizados para las normas APA 7 en tablas y figuras, complementado con motores de renderizado PlantUML y Structurizr para diagramas C4 y UML.

**Distribución de Responsabilidades**

La redacción y diagramación del informe contó con la participación activa de los cinco integrantes del equipo de trabajo, asignando responsabilidades técnicas según el perfil de especialización y manteniendo correspondencia estricta con el Registro de Versiones del Informe:

- **Huamani Estefanero, Joel (shouydev):** Registró 41 commits en la rama principal develop. Lideró la arquitectura de la solución documental y la definición del producto Atelier. Redactó los antecedentes y la problemática mediante la técnica 5W2H, elaboró la especificación técnica y de persistencia de los Bounded Contexts del backend como IAM, CRM, MRO, Inventory, HR, Invoicing, SaaS Billing e IoT, reformuló y reestructuró integralmente la especificación de requisitos con 10 Épicas, 43 Historias de Usuario como 24 Techincal Stories bajo formato BDD Gherkin y el Product Backlog, y configuró los filtros Lua y macros tipográficas en LaTeX para la compilación del reporte.

- **Teran Zavala, Mauricio Alejandro (mau-tz):** Registró 21 commits. Diseñó la metodología de Needfinding y las guías de pautas para las entrevistas a profundidad. Realizó la transcripción y tabulación de hallazgos cualitativos, consolidó los perfiles de User Persona para el personal de gestión y el personal operativo del taller, y estructuró los diagramas de Empathy Mapping respectivos.

- **Granda Ibarra, Luis Daniel (danieltyuyu):** Registró 17 commits. Desarrolló el proceso Lean UX formulando los enunciados de problema, supuestos e hipótesis, así como la consolidación de la matriz Lean UX Canvas. Adicionalmente, elaboró la investigación de competidores directos e indirectos, el análisis de estrategias de diferenciación comercial, los mapas de Customer Journey Mapping y los diagramas de Impact Mapping para la especificación de requisitos.

- **Rocha Cotrina, Alvaro (alvarorc24):** Registró 10 commits. Estructuró y normalizó la User Task Matrix para ambos segmentos objetivo del taller, auditó y corrigió las rutas relativas de activos visuales para asegurar la compilación del informe en Pandoc, y formuló sus metas profesionales de desarrollo.

- **Sanchez Santin, Adiel Abdiaz (xs4el):** Registró 7 commits. Facilitó y documentó la sesión inicial de Big Picture EventStorming, estableciendo el lenguaje ubicuo del dominio. Diseñó los ocho Bounded Context Canvases, el mapa de relaciones estratégicas de contextos (Context Mapping) y los flujos de mensajes de dominio (Domain Message Flows).

\newpage

**Evidencias Gráficas de Colaboración en GitHub**

Las siguientes figuras certifican la trazabilidad, la frecuencia de commits y la colaboración del equipo en el repositorio de documentación durante el ciclo de desarrollo del informe.

***Métricas de Contribuidores y Frecuencia de Commits en GitHub***

![](report/assets/collaboration-insights/av1-github-contributors.png){width=100%}

*Nota.* Gráfico de contribuciones individuales del repositorio atelier-report en GitHub.

***Red de Ramas e Integraciones en GitHub***

![](report/assets/collaboration-insights/av1-github-network-frequency.png){width=100%}

*Nota.* Grafo de commits y ramas integradas sobre el historial del repositorio en GitHub.

***Registro Cronológico de Commits en GitHub***

![](report/assets/collaboration-insights/av1-github-commits-log.png){width=100%}

*Nota.* Registro cronológico de commits que certifica la autoría y coherencia con el registro de versiones del informe.

\newpage