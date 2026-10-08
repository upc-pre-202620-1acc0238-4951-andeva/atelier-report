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

**Reporte de colaboración del TB1**

Para la entrega del TB1, el equipo aplicó rigurosamente la metodología Docs as Code integrando los capítulos de diseño de experiencia e interfaz de usuario, y de implementación inicial de producto del Sprint 1. Cada sección se estructuró modularmente en archivos Markdown en el repositorio oficial atelier-report en GitHub, garantizando la trazabilidad continua del trabajo colaborativo.

El flujo de trabajo profundizó el modelo de ramificación GitFlow formalizado en la gestión de configuración. Las contribuciones se integraron sobre la rama develop mediante ramas de características y ramas de estabilización release para cada incremento semántico desde la versión 1.1.0 hasta la versión consolidada 1.2.0. Asimismo, se aseguró la reproducibilidad de compilación con Docker, Pandoc 3.8.3 y LuaLaTeX, renderizando diagramas C4 y esquemas relacionales bajo normas de maquetación académica.

**Distribución de Responsabilidades**

La elaboración, estructuración y maquetación de los capítulos incorporados en el hito TB1 contó con el aporte técnico coordinado de los cinco integrantes del equipo de trabajo, manteniendo correspondencia directa con los registros del control de versiones y el Registro de Versiones del Informe:

- **Huamani Estefanero, Joel (shouydev):** Registró 26 commits en este hito. Lideró la consolidación técnica del informe y la arquitectura de despliegue del ecosistema con diagramas C4 en Structurizr. Formuló los requisitos del portal web comercial, estructuró la sección de Software Configuration Management definiendo la topología multientorno, y redactó integralmente el Sprint 1 con su planificación, backlog, evidencias de ejecución y retrospectiva. Asimismo, coordinó la integración de ramas de lanzamiento de estabilización hacia la rama principal.

- **Teran Zavala, Mauricio Alejandro (mau-tz):** Registró 23 commits. Diseñó las directrices Web Style Guidelines y Mobile Style Guidelines de Atelier, especificando las escalas tipográficas con Satoshi y Albert Sans ExtraBold, y la paleta cromática oficial. Desarrolló integralmente la sección de Landing Page UI Design con wireframes, flujos de usuario y prototipos en alta fidelidad para el portal comercial, y actualizó el registro de versiones para las entregas intermedias.

- **Granda Ibarra, Luis Daniel (danieltyuyu):** Registró 15 commits. Elaboró las directrices generales de diseño en la sección Style Guidelines, consolidando los activos de identidad visual y logotipo de la marca. Diseñó y redactó de forma exhaustiva la sección de Information Architecture del producto, estructurando los esquemas de organización jerárquica, sistemas de etiquetado semántico, mapas de navegación y mecanismos de búsqueda, complementados con la definición técnica de posicionamiento SEO en motores de búsqueda y optimización ASO en tiendas de aplicaciones móviles.

- **Rocha Cotrina, Alvaro (alvarorc24):** Registró 14 commits. Desarrolló la sección Mobile Applications UX/UI Design, elaborando los wireframes, mockups en alta fidelidad, diagramas de flujo de usuario, taskflows y wireflows para la aplicación móvil nativa Atelier Mobile Android en bahías mecánicas. Validó la consistencia visual de los componentes con el sistema de diseño corporativo y colaboró en la catalogación y verificación del inventario de herramientas de desarrollo, pruebas automatizadas y compilación contenerizada con Docker y Pandoc.

- **Sanchez Santin, Adiel Abdiaz (xs4el):** Registró 8 commits. Formuló y formalizó las guías de estilo de codificación multiplataforma y gobernanza de código en la sección de Software Configuration Management. Gestionó la integración y fusión de las ramas de características de configuración de software y de estabilización hacia la rama develop. Actualizó y sincronizó los registros de Student Outcomes y el registro de versiones del informe para la versión 1.1.5.

**Evidencias Gráficas de Colaboración en GitHub para el TB1**

Las siguientes figuras certifican la trazabilidad, la frecuencia de commits y la colaboración del equipo en el repositorio de documentación durante el ciclo de desarrollo correspondiente al hito TB1.

***Métricas de Contribuidores y Frecuencia de Commits en GitHub para el TB1***

![](report/assets/collaboration-insights/tb1-github-contributors.png){width=78%}

*Nota.* Gráfico de contribuciones individuales del repositorio atelier-report en GitHub durante el hito TB1.

***Red de Ramas e Integraciones en GitHub para el TB1***

![](report/assets/collaboration-insights/tb1-github-network-frequency.png){width=100%}

*Nota.* Grafo de commits y ramas integradas sobre el historial del repositorio en GitHub durante el hito TB1.

***Registro Cronológico de Commits en GitHub para el TB1***

![](report/assets/collaboration-insights/tb1-github-commits-log.png){width=100%}

*Nota.* Registro cronológico de commits que certifica la autoría y coherencia con el registro de versiones del informe para el hito TB1.

\newpage