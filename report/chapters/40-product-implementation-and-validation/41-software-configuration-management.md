# Capítulo IV: Product Implementation & Validation

## 4.1. Software Configuration Management

La gestión de la configuración de software constituye la disciplina de ingeniería encargada de establecer y preservar la integridad, consistencia y trazabilidad de todos los artefactos de un sistema computacional a lo largo de su ciclo de vida. Para el ecosistema Atelier, este proceso se fundamenta formalmente en los estándares internacionales ISO/IEC/IEEE 12207:2017 e IEEE 828-2012. La aplicación de este marco normativo asegura que cualquier alteración introducida en los modelos de dominio, contratos de interfaces de programación, especificaciones ejecutables de comportamiento, esquemas relacionales particionados y plantillas declarativas de infraestructura sea debidamente identificada, evaluada, controlada y auditada.

La estrategia de gestión de configuración de Atelier opera sobre cuatro pilares metodológicos esenciales:

- **Identificación de la configuración:** Clasificación y catalogación unívoca de los Elementos de Configuración de Software. Estos elementos comprenden las raíces de agregado y objetos de valor del núcleo compartido, los componentes de los ocho contextos acotados del backend, las especificaciones de pruebas BDD en sintaxis Gherkin, las definiciones OpenAPI de servicios RESTful, los esquemas relacionales de persistencia, las hipertablas de series temporales y las plantillas de empaquetado y despliegue de contenedores.
- **Control de la configuración:** Procedimientos sistemáticos para gobernar la incorporación de cambios en las líneas base del proyecto. Toda modificación debe canalizarse a través de ramas de soporte transitorias, someterse a revisiones obligatorias de código por pares mediante solicitudes de extracción y superar conductos automatizados de integración continua antes de autorizar su consolidación.
- **Contabilidad del estado de la configuración:** Registro continuo y auditable de las versiones de cada elemento de configuración. Permite determinar con exactitud qué cambios se incorporaron, por qué colaborador, en qué fecha y bajo qué justificación operativa o historia de usuario del catálogo de producto.
- **Auditorías de la configuración:** Revisiones funcionales y físicas periódicas orientadas a certificar que los componentes construidos cumplen íntegramente con los requisitos funcionales y no funcionales especificados, garantizando que los artefactos binarios desplegados en los entornos de ejecución sean estrictamente deterministas y reproducibles.

El ecosistema Atelier articula cuatro productos digitales interconectados mediante protocolos seguros de red: el backend monolítico modular denominado Atelier Platform API, el portal público y panel administrativo web denominado Atelier Website, la aplicación móvil nativa para mecánicos en bahía de trabajo denominada Atelier Mobile Android junto con su componente multiplataforma de soporte, y la memoria técnica centralizada del proyecto denominada Atelier Report. Las directrices expuestas en esta sección garantizan la gobernanza técnica armónica de todos los productos de la solución.

### 4.1.1. *Software Development Environment Configuration*

El entorno de desarrollo de software congrega el ecosistema de herramientas de hardware, sistemas operativos, plataformas en la nube, compiladores, marcos de desarrollo, bibliotecas y utilitarios requeridos por el equipo de ingeniería para colaborar de manera eficiente y predecible. La estandarización de las estaciones de trabajo mitiga inconsistencias de compilación y asegura que la construcción de artefactos se replique de forma determinista entre los entornos locales y los conductos de entrega en la nube.

La @tbl:development-environment-tools detalla el inventario consolidado de herramientas de software empleadas en el proyecto, clasificadas según su actividad técnica, indicando su versión oficial, su propósito específico dentro del ecosistema Atelier, su modalidad operativa y su enlace formal de referencia o descarga.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\raggedright\arraybackslash}p{2.8cm} | >{\raggedright\arraybackslash}p{2.8cm} | >{\raggedright\arraybackslash}p{6.4cm} | >{\centering\arraybackslash}p{1.4cm} | >{\raggedright\arraybackslash}p{2.0cm} |}
\caption{Configuración Consolidada del Entorno de Desarrollo de Software} \label{tbl:development-environment-tools} \\
\hline
\thfirst{Actividad Técnica} & \thcell{Producto y Versión} & \thcell{Propósito en el Ecosistema Atelier} & \thcell{Tipo} & \thcell{Referencia} \\
\hline
\endfirsthead
\hline
\thfirst{Actividad Técnica} & \thcell{Producto y Versión} & \thcell{Propósito en el Ecosistema Atelier} & \thcell{Tipo} & \thcell{Referencia} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
% --- Actividad 1: Project Management ---
\textbf{Project Management} & Jira Software Cloud \newline v2024.10 & Planificación de sprints, gestión del backlog de producto y seguimiento de tareas de ingeniería en tableros Kanban. & SaaS & atlassian.com \newline jira \\
\cline{2-5}
 & Confluence Cloud \newline v2024.10 & Repositorio central de documentación colaborativa, actas de acuerdos y minutas técnicas de reunión. & SaaS & atlassian.com \newline confluence \\
\hline
% --- Actividad 2: Requirements Management ---
\textbf{Requirements Management} & Cucumber JVM \newline v7.18.1 & Automatización y comprobación de criterios de aceptación de historias de usuario mediante sintaxis Gherkin. & Biblioteca & cucumber.io \\
\cline{2-5}
 & Pandoc Docs-as-Code \newline v3.8.3 & Motor de transformación de especificaciones de ingeniería en Markdown hacia reportes técnicos formales. & CLI / Docker & pandoc.org \\
\hline
% --- Actividad 3: Product UX/UI Design ---
\textbf{Product UX/UI Design} & Figma \newline v124.5 & Diseño colaborativo de wireframes, guías de estilos, diseño atómico y prototipos interactivos de alta fidelidad. & SaaS & figma.com \\
\cline{2-5}
 & Miro \newline v2024.9 & Modelado colaborativo de sesiones de EventStorming, mapas de empatía y flujos de experiencia de usuario. & SaaS & miro.com \\
\cline{2-5}
 & Material Design 3 \newline v1.3.0 & Lineamientos ergonómicos de interacción táctil y componentes de interfaz para dispositivos móviles de taller. & Biblioteca & m3.material.io \\
\cline{2-5}
 & Tailwind CSS v4 \newline v4.0.0 & Motor de utilidades y tokens de diseño corporativo basados en la directiva de tema corporativo de la plataforma. & Framework & tailwindcss.com \\
\hline
% --- Actividad 4: Software Development ---
\textbf{Software Development} & IntelliJ IDEA Ultimate \newline v2024.2 & Entorno principal de desarrollo para el backend en Java con perfilado de memoria y herramientas JPA avanzadas. & Local & jetbrains.com \newline idea \\
\cline{2-5}
 & Eclipse Temurin JDK \newline v21.0.4 LTS & Entorno de ejecución de Java para construcción del backend monolítico modular con tipos inmutables. & Runtime & adoptium.net \\
\cline{2-5}
 & Spring Boot \newline v3.3.4 & Marco de desarrollo del backend empresarial con soporte de Spring Data JPA, Spring Security y modularidad DDD. & Framework & spring.io \newline spring-boot \\
\cline{2-5}
 & Spring AI \newline v1.0.0-M6 & Marco de inferencia predictiva y salidas estructuradas para diagnóstico vehicular computarizado en taller. & Biblioteca & spring.io \newline spring-ai \\
\cline{2-5}
 & Maven Wrapper \newline v3.9.9 & Herramienta de compilación y resolución determinista de dependencias sin requerir instalación previa en el sistema. & CLI & maven.apache.org \\
\cline{2-5}
 & Visual Studio Code \newline v1.94.2 & Entorno de desarrollo para aplicaciones web, cliente REST y edición de especificaciones en Markdown. & Local & code.visualstudio \newline .com \\
\cline{2-5}
 & Node.js \newline v20.18.0 LTS & Entorno de ejecución JavaScript para empaquetado y herramientas de construcción web en el frontend. & Runtime & nodejs.org \\
\cline{2-5}
 & pnpm \newline v9.12.0 & Gestor de paquetes rápido y eficiente mediante almacenamiento centralizado enlazado por enlaces duros. & CLI & pnpm.io \\
\cline{2-5}
 & Android Studio Ladybug \newline v2024.2.1 & Entorno integrado oficial para compilación, prueba y depuración de la aplicación móvil de taller. & Local & developer.android \newline .com/studio \\
\cline{2-5}
 & Kotlin SDK \newline v2.0.20 & Lenguaje de programación moderno y seguro frente a nulos para la aplicación móvil nativa de taller. & Lenguaje & kotlinlang.org \\
\cline{2-5}
 & Jetpack Compose \newline v1.7.3 & Kit de herramientas declarativo de interfaz reactiva para la experiencia móvil de mecánicos en fosa. & Framework & developer.android \newline .com/compose \\
\cline{2-5}
 & SQLite y Room \newline v2.6.1 & Motor de base de datos embebido para soporte de persistencia local y operación sin conexión en dispositivos móviles. & Biblioteca & developer.android \newline .com/room \\
\cline{2-5}
 & PostgreSQL \newline v16.4 & Sistema gestor de base de datos relacional transaccional con soporte nativo de tipos JSONB y conformidad ACID. & RDBMS & postgresql.org \\
\cline{2-5}
 & TimescaleDB \newline v2.16.1 & Extensión de series temporales para ingesta y particionamiento de telemetría vehicular en hipertablas. & Motor & timescale.com \\
\cline{2-5}
 & DBeaver Community \newline v24.2.1 & Herramienta visual de administración de base de datos, inspección de índices y depuración de consultas SQL. & Local & dbeaver.io \\
\hline
% --- Actividad 5: Software Testing ---
\textbf{Software Testing} & JUnit 5 Jupiter \newline v5.10.3 & Marco estándar para ejecución de pruebas unitarias, parametrizadas y comprobación de aserciones del dominio. & Biblioteca & junit.org \\
\cline{2-5}
 & Mockito \newline v5.13.0 & Marco de simulación para aislar componentes de aplicación mediante dobles de prueba en puertos externos. & Biblioteca & site.mockito.org \\
\cline{2-5}
 & AssertJ \newline v3.26.3 & Biblioteca de aserciones fluidas para validación legible de condiciones de prueba en el backend. & Biblioteca & assertj.github.io \\
\cline{2-5}
 & Postman \newline v11.15.0 & Plataforma de diseño, ejecución de colecciones y validación automatizada de contratos de APIs RESTful. & SaaS / Local & postman.com \\
\hline
% --- Actividad 6: Software Documentation ---
\textbf{Software Documentation} & Docker Community Engine \newline v27.3.1 & Plataforma de virtualización ligera para empaquetar servicios de backend y aislar herramientas de reporte. & Runtime & docker.com \\
\cline{2-5}
 & PlantUML \newline v1.2024.6 & Herramienta declarativa para modelado de diagramas de secuencia, clases de dominio y máquinas de estado. & CLI / Jar & plantuml.com \\
\cline{2-5}
 & Structurizr CLI \newline v2024.03.03 & Compilador de arquitectura de software para visualización de vistas del Modelo C4 a partir de código DSL. & CLI & structurizr.com \\
\cline{2-5}
 & Eisvogel LaTeX \newline v2.5.0 & Plantilla tipográfica para compilación formal de documentos técnicos mediante el procesador LuaLaTeX. & Template & github.com \newline /wandmalfarbe \\
\hline
\end{longtable}

*Nota.* Inventario de herramientas y plataformas homologadas para el ciclo de vida del software en Atelier.

El equipo adoptó pnpm como gestor exclusivo de dependencias en el ecosistema web con el propósito de optimizar el consumo de disco y erradicar dependencias fantasma. Para la base de datos se seleccionó la combinación de PostgreSQL 16 con la extensión TimescaleDB, permitiendo procesar transacciones de gestión de taller en esquemas relacionales y almacenar flujos continuos de parámetros OBD-II vehiculares sobre hipertablas optimizadas. Toda la documentación técnica formal se genera bajo el enfoque de documentación como código mediante contenedores Docker, garantizando independencia absoluta de herramientas instaladas de forma manual en los equipos de los ingenieros.

### 4.1.2. *Source Code Management*

El control de versiones del código fuente se gestiona a través de la plataforma GitHub en la organización oficial del proyecto. Esta plataforma provee custodia distribuida, auditoría granular de aportes mediante commits firmados y mecanismos de revisión colaborativa de código antes de su integración definitiva.

El desarrollo del ecosistema se distribuye en cuatro repositorios especializados:

- **Atelier Platform API:**  
  `https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier-platform`  
  Aloja el código del backend monolítico modular desarrollado en Spring Boot y Java 21, incluyendo las capas de dominio, aplicación, interfaz e infraestructura de los ocho contextos acotados y del núcleo compartido, así como las suites completas de pruebas unitarias y de integración.
- **Atelier Report:**  
  `https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier-report`  
  Centraliza la memoria técnica del proyecto bajo el paradigma de documentación como código en archivos Markdown, junto con las definiciones de arquitectura en Structurizr DSL, diagramas PlantUML, filtros Lua y scripts de compilación automatizada en Docker.
- **Atelier Website:**  
  `https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier-website`  
  Contiene la solución web integral del sistema que fusiona el portal institucional de captación comercial y el panel administrativo para asesores de servicio y dueños de taller, construido en React con Vite y estilizado mediante Tailwind CSS v4.
- **Atelier Mobile Android:**  
  `https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier-mobile-android`  
  Aloja la aplicación móvil nativa para dispositivos Android destinada a los mecánicos en bahía de trabajo, incorporando arquitectura desacoplada sin conexión obligatoria a la red mediante SQLite y comunicación Bluetooth con escáneres vehiculares OBD-II. Asimismo, el proyecto contempla el repositorio complementario `https://github.com/upc-pre-202620-1acc0238-4951-andeva/atelier-mobile-crossplatform` reservado para la extensión multiplataforma de la experiencia del conductor.

**Flujo de Ramificación GitFlow**

La gestión de ramas adopta el modelo formal GitFlow propuesto por Vincent Driessen, estructurando el ciclo de vida del código en ramas permanentes y ramas temporales de soporte:

- **Rama main:** Representa el estado oficial de producción. Cada versión integrada en esta rama debe ser estable, contar con pruebas aprobadas y corresponder a una liberación etiquetada. Las modificaciones directas sobre esta rama quedan terminantemente restringidas.
- **Rama develop:** Rama central de integración continua. Alberga los desarrollos validados que formarán parte de la siguiente versión del software. Todos los desarrolladores sincronizan sus líneas de trabajo a partir de esta rama.
- **Ramas feature:** Ramas transitorias creadas para implementar historias de usuario, capacidades técnicas o mejoras puntuales. Nacen a partir de la rama develop y adoptan la convención nominal `feature/<contexto-o-modulo>-<descripcion-corta>`, alineada directamente con los contextos acotados del sistema. Por ejemplo, `feature/iam-rbac-tenancy`, `feature/crm-fleet-onboarding`, `feature/operations-work-orders`, `feature/inventory-fifo-allocation`, `feature/hr-geofence-clocking`, `feature/invoicing-sunat-ubl`, `feature/billing-stripe-subscriptions` o `feature/iot-timescale-telemetry`. Al finalizar el desarrollo y superar las revisiones requeridas, se fusionan de retorno a la rama develop mediante solicitudes de extracción aprobadas.
- **Ramas release:** Ramas destinadas a la estabilización previa a un despliegue de versión. Nacen de la rama develop bajo la nomenclatura `release/v<version>`, como `release/v1.0.0`. Durante su vigencia solo se permiten correcciones menores y preparación de metadatos de entrega. Una vez validada, la rama se fusiona en la rama main y se propaga simultáneamente a la rama develop.
- **Ramas hotfix:** Ramas urgentes destinadas a solventar defectos críticos detectados en el entorno de producción. Se originan directamente de la rama main bajo el formato `hotfix/v<version>`, por ejemplo `hotfix/v1.0.1`. Una vez corregida la anomalía, se fusionan de inmediato tanto en la rama main como en la rama develop.

**Versionamiento Semántico**

El control de versiones de todos los componentes de software adopta la especificación Semantic Versioning 2.0.0. Cada versión se define mediante tres números enteros bajo el formato `MAJOR.MINOR.PATCH`:

- **MAJOR:** Se incrementa ante modificaciones estructurales que rompen la compatibilidad hacia atrás en los contratos de interfaces de programación o esquemas relacionales.
- **MINOR:** Se incrementa ante la incorporación de nuevas capacidades o contextos funcionales que conservan compatibilidad total con versiones anteriores.
- **PATCH:** Se incrementa ante correcciones de errores y optimizaciones internas que no alteran los contratos existentes ni introducen nueva funcionalidad.

El avance del ecosistema a lo largo del desarrollo ágil se traduce en las siguientes líneas base de versión:

- **Versión v0.1.0:** Línea base inicial correspondiente a la estabilización del núcleo compartido, gestión de identidad y control de acceso multi-inquilino, y gestión de clientes y flotas vehiculares en el primer sprint.
- **Versión v0.2.0:** Incorporación de las operaciones de taller en bahía de trabajo, órdenes de servicio, peritaje fotográfico y control de inventario valorizado por lotes FIFO en el segundo sprint.
- **Versión v1.0.0:** Versión candidata a producción y liberación oficial, integrando los módulos de control de personal con geocerca perimétrica Haversine, facturación electrónica fiscal SUNAT UBL 2.1, suscripciones SaaS con pasarela Stripe y telemetría vehicular IoT sobre hipertablas TimescaleDB en el tercer sprint.

Cada versión consolidada en la rama main se inmuta mediante una etiqueta firmada en Git a través del comando `git tag -a v1.0.0 -m "Release v1.0.0 - Atelier Production Version"`.

**Convención de Mensajes de Commit**

Los registros de cambios siguen de forma estricta la especificación Conventional Commits v1.0.0. Esta norma establece una estructura clara que facilita la auditoría del repositorio y permite generar registros de cambios automatizados. El formato adoptado se define como:

```text
<tipo>(<alcance>): <descripcion concisa en tiempo presente y minusculas>
```

Los tipos de commit permitidos en el proyecto son los siguientes:

- **feat:** Adición de una nueva funcionalidad visible para el usuario o nuevo servicio de aplicación.
- **fix:** Corrección de un fallo funcional o error detectado en una prueba.
- **refactor:** Modificación del código fuente que no altera el comportamiento funcional ni corrige un error, orientada a optimizar el diseño interno o aplicar principios de arquitectura limpia.
- **test:** Adición o corrección de pruebas unitarias, de integración o suites de comportamiento BDD.
- **docs:** Cambios exclusivos en archivos de documentación técnica, reportes o diagramas.
- **chore:** Tareas accesorias de mantenimiento como actualización de dependencias, scripts de construcción o configuración de herramientas.
- **perf:** Ajustes de código enfocados puntualmente en mejorar el rendimiento o reducir tiempos de respuesta.
- **ci:** Modificaciones en archivos de configuración de conductos de integración y entrega continua.

Los alcances autorizados corresponden directamente a los contextos acotados y componentes de la solución: `iam`, `crm`, `operations`, `inventory`, `hr`, `invoicing`, `billing`, `iot`, `report` y `config`. A continuación se ilustran ejemplos representativos de commits generados por el equipo:

- `feat(inventory): implement fifo batch allocation domain service`
- `feat(iot): add timescale hypertable chunk retention policy for telemetry logs`
- `fix(hr): correct haversine earth radius calculation in geofence evaluator`
- `feat(invoicing): map electronic voucher to nubefact json ubl 2.1 payload`
- `test(operations): verify direct-to-cloud inspection image persistence`
- `docs(report): update software configuration management section`

**Políticas de Protección de Ramas**

Para preservar la calidad del código y evitar regresiones en las ramas principales, el repositorio en GitHub tiene configuradas reglas de protección estrictas:

- Prohibición terminante de subidas directas a las ramas main y develop.
- Requisito obligatorio de someter toda integración a través de una solicitud de extracción con al menos una aprobación formal de otro miembro del equipo.
- Verificación exitosa de los conductos automáticos de integración continua en GitHub Actions, exigiendo compilación sin advertencias críticas y ejecución íntegra de pruebas unitarias antes de autorizar la fusión.
- Aplicación de fusión mediante combinación lineal para mantener un historial limpio y legible en la rama troncal.

### 4.1.3. *Source Code Style Guide & Conventions*

El mantenimiento a largo plazo de una base de código heterogénea exige homogeneidad sintáctica y conceptual. El equipo estableció un conjunto integral de guías de estilo y normas de codificación para cada lenguaje y tecnología participante en la solución, garantizando que el código sea predecible y fácil de auditar.

**Principio Rector de Nomenclatura en Inglés**

Como directriz obligatoria para todos los componentes de software del ecosistema, **todos los identificadores de código se escriben enteramente en idioma inglés**. Esta regla aplica sin excepciones a nombres de paquetes, clases, interfaces, métodos, variables, atributos de base de datos, rutas de servicios RESTful, nombres de ramas y mensajes de commit. Los conceptos del negocio automotriz se modelan empleando sus equivalentes formales en inglés dentro del lenguaje ubicuo, tales como WorkOrder, Customer, Vehicle, InventoryBatch, EmployeeProfile, ElectronicVoucher, SubscriptionPlan y TelemetryRecord.

**Directrices para Java y Spring Boot en el Backend**

El desarrollo del backend en Java adopta las directrices de la guía de estilo Google Java Style Guide con una sangría configurada de 4 espacios y un límite de línea de 120 caracteres. Se aplican las siguientes reglas arquitectónicas fundamentadas en el diseño táctico de Domain-Driven Design:

- **Nombres de elementos:** Clases, interfaces y enumeraciones se nombran en `UpperCamelCase`. Métodos y atributos se definen en `lowerCamelCase`. Constantes inmutables se declaran en `UPPER_SNAKE_CASE`.
- **Inmutabilidad y tipos de datos:** Se hace uso extensivo de la palabra reservada `record` de Java para definir objetos de valor inmutables como `Money`, `Quantity`, `Mileage`, `GeoPoint`, `DistanceMeters` y `TaxId`, identificadores fuertemente tipados como `TenantId`, `BranchId`, `CustomerId`, `VehicleId` y `UserId`, recursos de interfaz pública, comandos de aplicación, consultas y eventos de dominio. Los registros garantizan inmutabilidad inherente y ausencia de efectos colaterales.
- **Encapsulamiento de agregados en DDD:** Las entidades y agregados de dominio heredan de la clase base `AbstractDomainAggregateRoot` y prohíben el uso de métodos de asignación anémicos. Toda alteración de estado debe ejecutarse mediante métodos de negocio expresivos que validen las invariantes del modelo y registren los eventos correspondientes mediante `registerDomainEvent`, por ejemplo `workOrder.completeDiagnosis(...)` en lugar de mutaciones directas.
- **Uso disciplinado de Lombok:** Lombok se restringe al uso de anotaciones inocuas como `@Getter` y constructores con visibilidad protegida requeridos por los mecanismos de persistencia JPA, evitando anotaciones que vulneren el encapsulamiento del dominio.
- **Estructuración hexagonal de paquetes:** Cada contexto acotado se divide internamente en cuatro paquetes canónicos que reflejan la arquitectura limpia: `domain` para el núcleo del negocio libre de dependencias de frameworks, `application` para casos de uso y orquestación transaccional con retorno monádico `Result<T, ApplicationError>`, `interfaces` para controladores REST y recursos públicos, e `infrastructure` para adaptadores de persistencia JPA, clientes HTTP y pasarelas externas.
- **Manejo monetario y geográfico:** Los cálculos financieros utilizan la clase `BigDecimal` con redondeo bancario legal hacia el par más cercano a dos decimales. La evaluación de geocercas satelitales implementa el cálculo ortodrómico de Haversine con el radio esférico de la Tierra de 6,371,000 metros.

**Directrices para Kotlin y Jetpack Compose en la Aplicación Móvil**

La aplicación móvil nativa desarrollada para el sistema operativo Android sigue las pautas de la guía oficial Kotlin Coding Conventions y las recomendaciones de Google para Jetpack Compose:

- **Funciones de interfaz declarativa:** Toda función composable que renderice elementos visuales se nombra con `UpperCamelCase` y no retorna ningún valor, por ejemplo `MechanicBayTaskCard()`.
- **Flujos unidireccionales de datos:** La lógica de presentación adopta el patrón Model-View-Intent. Las pantallas observan flujos inmutables expuestos mediante `StateFlow` y propagan intenciones de usuario hacia el modelo de vista mediante eventos fuertemente tipados.
- **Operatividad sin conexión en fosa:** La persistencia local en dispositivos de taller se gestiona mediante la biblioteca Room sobre SQLite, manteniendo una réplica local de órdenes de trabajo, listas de comprobación y lecturas telemáticas que se sincronizan con el backend cuando se restablece la conectividad de red.
- **Manejo de asincronía:** Se emplean corrutinas de Kotlin gestionadas dentro de ámbitos estructurados vinculados al ciclo de vida del componente visual, garantizando la cancelación oportuna de operaciones ante cambios de pantalla.

**Directrices para TypeScript y React en la Aplicación Web**

El frontend administrativo y el portal público se desarrollan bajo la guía Google TypeScript Style Guide y las convenciones de Airbnb:

- **Tipado estricto:** La configuración del compilador mantiene habilitada la bandera de rigurosidad de tipos, prohibiendo el uso del tipo `any` sin justificación explícita.
- **Componentes y funciones:** Los componentes visuales de React se estructuran como funciones flecha y se nombran en `UpperCamelCase`. Las funciones utilitarias y ganchos personalizados se definen en `lowerCamelCase` con el prefijo canónico `use`.
- **Herramientas de calidad:** Se utiliza ESLint para el análisis estático continuo y Prettier como formateador automático de código integrado en los ganchos locales previos a cada commit.

**Convenciones para Hojas de Estilo y Tokens de Diseño en Tailwind CSS v4**

El diseño visual se gobierna mediante la directiva corporativa `@theme` de Tailwind CSS v4, abstrayendo estilos arbitrarios en tokens semánticos normalizados:

- **Paleta cromática institucional:** Azul eléctrico como color de acción principal (`#0071EB`), azul marino profundo para fondos estructurales y contraste tipográfico (`#031A6B`), y naranja ámbar para acentos de advertencia y estados operativos (`#F68B01`).
- **Tipografía corporativa:** Fuente Satoshi Variable para todos los textos de interfaz y cuerpo de lectura, y fuente Albert Sans en peso ExtraBold para la marca institucional e isotipos de cabecera.
- **Composición de clases:** Se prioriza el ordenamiento estándar de utilidades de diseño desde posicionamiento y disposición espacial hasta tipografía y efectos interactivos.

**Convenciones para Especificaciones de Comportamiento BDD en Gherkin**

Los archivos de especificación con extensión `.feature` se estructuran conforme a los estándares de legibilidad de Gherkin:

- Cada archivo define una característica principal encabezada por la palabra clave `Feature`, seguida de una breve descripción del beneficio comercial.
- Los escenarios se articulan mediante las cláusulas `Scenario`, `Given`, `When`, `Then` y `And`.
- La redacción se expresa en tiempo presente y tercera persona impersonal, enfocándose exclusivamente en el comportamiento observable del sistema y omitiendo referencias a elementos gráficos o componentes de pantalla.

**Convenciones para Bases de Datos Relacionales en PostgreSQL**

El esquema relacional implementado en PostgreSQL y TimescaleDB se adhiere a pautas estrictas de modelado:

- Tablas y columnas se definen en minúsculas utilizando la convención `snake_case`.
- Los nombres de las tablas se redactan siempre en plural para representar colecciones de registros, por ejemplo `customers`, `vehicles`, `work_orders`, `inventory_batches`, `electronic_vouchers` y `subscriptions`.
- Las claves primarias se identifican con la columna `id` mediante identificadores universales únicos. Las claves foráneas adoptan el nombre singular de la tabla referenciada seguido del sufijo `_id`, como `customer_id` o `vehicle_id`.
- Las restricciones se bautizan con prefijos normalizados: `fk_` para claves foráneas, `uk_` para restricciones de unicidad y `chk_` para restricciones de validación condicional.
- Para la tabla de telemetría masiva `telemetry_logs`, se configura una hipertabla particionada automáticamente en bloques temporales de siete días, aplicando compresión columnar a partir de los treinta días de antigüedad para garantizar alto rendimiento de inserción y consulta analítica.

### 4.1.4. *Software Deployment Configuration*

La configuración del despliegue describe la arquitectura de infraestructura, los entornos de ejecución y los procedimientos técnicos paso a paso para transformar el código fuente almacenado en GitHub en artefactos ejecutables en producción.

**Estrategia y Topología Multientorno**

El ecosistema Atelier implementa una estrategia de dos entornos complementarios concebidos para aislar el desarrollo de la operación productiva:

- **Entorno de desarrollo local y pruebas:** Entorno autocontenido ejecutado en la estación del ingeniero mediante Docker Compose. Orquesta una instancia de base de datos con PostgreSQL 16 y la extensión TimescaleDB en el puerto 5432 con volumen nombrado para persistencia local. El backend Spring Boot se ejecuta con el perfil `local` en el puerto 8080, mientras que la interfaz web se sirve mediante el servidor de desarrollo Vite en el puerto 5173 con un proxy inverso apuntando hacia los servicios del backend. La aplicación móvil se conecta al entorno local mediante reenvío de puertos mediante el comando `adb reverse tcp:8080 tcp:8080` en dispositivos conectados por cable o red local.
- **Entorno de producción en la nube:** Topología distribuida de alta disponibilidad basada en plataformas modernas como servicio:
  - **Backend PaaS:** Alojado en Render Cloud Platform ejecutando la aplicación Spring Boot en un contenedor Linux optimizado sobre Alpine JRE de Eclipse Temurin. Dispone de certificados TLS gestionados y comprobación periódica de vitalidad a través del endpoint `/actuator/health`.
  - **Base de datos DBaaS:** Clúster administrado en Aiven operando PostgreSQL 16 con la extensión TimescaleDB activa. Exige cifrado en tránsito mediante conexiones TLS obligatorias y aplica cifrado en reposo bajo el estándar AES-256.
  - **Frontend y portal público en CDN:** Alojado en la plataforma perimetral global de Vercel. Provee distribución perimetral de contenido, compresión Brotli y almacenamiento inmutable de archivos estáticos compilados con hash.
  - **Distribución de aplicación móvil:** Paquetes optimizados en formato APK compilados en modo Release, firmados criptográficamente mediante el almacén de claves corporativo y distribuidos a las tabletas y teléfonos de uso rudo en las bahías del taller.
  - **Servicios externos integrados:** Proveedor de servicios electrónicos Nubefact para facturación tributaria con comprobantes UBL 2.1 ante la SUNAT, pasarela Stripe para liquidación de suscripciones SaaS de talleres mecánicos con validación de firmas en webhooks, Google Cloud Storage para custodia de evidencias periciales inmutables y Firebase Cloud Messaging para notificaciones push predictivas hacia los mecánicos y clientes.

**Procedimientos de Despliegue Automatizado por Producto**

A continuación se documentan los procedimientos de construcción y despliegue para cada componente del sistema:

**1. Despliegue del Backend RESTful: Atelier Platform API**

El despliegue del servicio central del backend se ejecuta a través del siguiente conducto determinista:

- **Compilación del artefacto:** En el entorno de integración continua se ejecuta la herramienta Maven Wrapper para compilar las fuentes y generar el archivo empaquetado ejecutable:
  ```bash
  ./mvnw clean package -DskipTests
  ```
- **Contenedorización en múltiples etapas:** Se construye una imagen Docker utilizando una estrategia de dos fases que minimiza la superficie de ataque y el tamaño final del contenedor de producción:
  ```dockerfile
  FROM eclipse-temurin:21-jdk-alpine AS builder
  WORKDIR /app
  COPY .mvn/ .mvn
  COPY mvnw pom.xml ./
  RUN ./mvnw dependency:go-offline
  COPY src ./src
  RUN ./mvnw clean package -DskipTests

  FROM eclipse-temurin:21-jre-alpine
  WORKDIR /app
  RUN addgroup -S atelier && adduser -S atelier -G atelier
  USER atelier:atelier
  COPY --from=builder /app/target/*.jar app.jar
  EXPOSE 8080
  ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]
  ```
- **Inyección de variables de entorno de producción:** En el panel de control de Render se configuran los secretos requeridos para la ejecución segura:
  - `SPRING_PROFILES_ACTIVE`: `prod`
  - `DATABASE_URL`: `jdbc:postgresql://<host-aiven>:5432/atelier_db?sslmode=require`
  - `DATABASE_USERNAME` y `DATABASE_PASSWORD`: Credenciales de acceso al servicio gestionado.
  - `JWT_SECRET`: Clave simétrica de 256 bits para firma de tokens HMAC-SHA256.
  - `NUBEFACT_API_URL` y `NUBEFACT_TOKEN`: Credenciales de facturación electrónica tributaria ante SUNAT.
  - `STRIPE_API_KEY` y `STRIPE_WEBHOOK_SECRET`: Credenciales para procesamiento de suscripciones SaaS.
  - `GCP_PROJECT_ID` y `FIREBASE_STORAGE_BUCKET`: Credenciales de custodia pericial en la nube.
- **Activación del despliegue:** La incorporación de cambios en la rama main dispara automáticamente la reconstrucción de la imagen en la plataforma Render y comprueba el arranque exitoso en el endpoint de salud de Spring Boot Actuator.

**2. Despliegue de la Aplicación Web y Portal Institucional: Atelier Website**

La solución web se compila y distribuye en la red global de entrega de contenidos de Vercel siguiendo estos pasos:

- **Instalación determinista de dependencias:** Haciendo uso exclusivo del gestor pnpm con bloqueo estricto de versiones:
  ```bash
  pnpm install --frozen-lockfile
  ```
- **Compilación de la aplicación:** Se ejecuta el proceso de construcción optimizado de Vite:
  ```bash
  pnpm run build
  ```
  Este comando procesa las fuentes en TypeScript, optimiza las hojas de estilo mediante el compilador de Tailwind CSS v4 y empaqueta las tipografías Satoshi y Albert Sans en el directorio `dist/`.
- **Configuración perimetral de enrutamiento:** El archivo `vercel.json` gestiona la redirección hacia la aplicación de página única y asigna cabeceras de caché inmutables a los activos versionados con hash:
  ```json
  {
    "rewrites": [
      { "source": "/(.*)", "destination": "/index.html" }
    ],
    "headers": [
      {
        "source": "/assets/(.*)",
        "headers": [
          { "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }
        ]
      }
    ]
  }
  ```

**3. Despliegue de la Aplicación Móvil de Taller: Atelier Mobile Android**

La distribución de la aplicación nativa para dispositivos Android se realiza mediante el sistema de compilación Gradle:

- **Custodia del almacén de claves de producción:** Se genera y resguarda el archivo criptográfico de firma `release.keystore`:
  ```bash
  keytool -genkey -v -keystore release.keystore -alias atelier -keyalg RSA -keysize 2048 -validity 10000
  ```
- **Configuración de firma en Gradle:** En el archivo `android/key.properties` no versionado se definen las referencias al almacén de claves, contraseñas y alias de producción.
- **Generación del paquete optimizado:** Se compila el paquete de instalación ejecutable para dispositivos mediante el comando:
  ```bash
  ./gradlew assembleRelease
  ```
- **Verificación criptográfica y distribución:** Se valida la alineación binaria de 4 bytes mediante la utilidad `zipalign` y se verifica la firma digital con `apksigner`. El archivo APK resultante se instala en los dispositivos de bahía o se carga en la pista interna de distribución para pruebas operativas de los mecánicos.

**Diagrama de Despliegue del Modelo C4**

Para ilustrar de forma formal y comprensible la distribución física y lógica de todos los componentes de software sobre la infraestructura de hardware y plataformas en la nube, la @fig:deployment-diagram-atelier-scm presenta el Diagrama de Despliegue del Modelo C4 correspondiente al ecosistema productivo de Atelier.

![Diagrama de Despliegue del Modelo C4 de la Infraestructura de Atelier](report/assets/c4-diagrams/deployment-diagram-atelier.png){#fig:deployment-diagram-atelier-scm}

*Nota.* Topología física y lógica de despliegue multientorno del ecosistema Atelier generada mediante Structurizr DSL y PlantUML.

La @tbl:deployment-topology-nodes resume el catálogo formal de nodos físicos y entornos de ejecución modelados en el diagrama de despliegue, especificando su rol técnico, tecnología base y protocolos seguros de comunicación empleados.

\renewcommand{\arraystretch}{1.25}
\begin{longtable}{| >{\raggedright\arraybackslash}p{3.8cm} | >{\raggedright\arraybackslash}p{3.5cm} | >{\raggedright\arraybackslash}p{5.1cm} | >{\raggedright\arraybackslash}p{3.0cm} |}
\caption{Catálogo de Nodos y Entornos de Despliegue de Atelier} \label{tbl:deployment-topology-nodes} \\
\hline
\thfirst{Nodo o Entorno} & \thcell{Tecnología y Runtime} & \thcell{Componente Desplegado} & \thcell{Protocolo de Enlace} \\
\hline
\endfirsthead
\hline
\thfirst{Nodo o Entorno} & \thcell{Tecnología y Runtime} & \thcell{Componente Desplegado} & \thcell{Protocolo de Enlace} \\
\hline
\endhead
\hline
\endfoot
\hline
\endlastfoot
\textbf{Estación de Personal de Gestión} & Estación PC / Laptop \newline Navegador Web & Instancia cliente de la aplicación web administrativa Atelier Website & HTTPS / TLS 1.3 \newline puerto 443 \\
\hline
\textbf{Dispositivo Móvil de Taller} & Smartphone / Tablet \newline Android OS 10 o superior & Aplicación móvil nativa de bahía Atelier Mobile Android con persistencia SQLite & HTTPS / TLS 1.3 \newline Bluetooth Low Energy \\
\hline
\textbf{Unidad de Control del Vehículo} & Puerto SAE J1962 \newline Dongle ELM327 BLE & Emisor telemático de parámetros vehiculares y códigos de falla OBD-II & Protocolo Bluetooth BLE \newline 2.4 GHz industrial \\
\hline
\textbf{Plataforma CDN Perimetral} & Vercel Edge Network \newline Servidores Anycast & Artefactos estáticos de Atelier Website para el portal comercial y la aplicación web administrativa & HTTPS / TLS 1.3 \newline Compresión Brotli \\
\hline
\textbf{Contenedor PaaS de Backend} & Render Cloud Platform \newline Contenedor Linux Alpine & Monolito modular Spring Boot 3.3.4 ejecutando en Eclipse Temurin JRE 21 & HTTPS interno \newline Conexión JDBC sobre TLS \\
\hline
\textbf{Clúster DBaaS Gestionado} & Aiven Cloud Platform \newline PostgreSQL 16 y TimescaleDB & Base de datos relacional para entidades transaccionales e hipertablas IoT & JDBC sobre TLS/SSL \newline puerto 5432 cifrado \\
\hline
\textbf{Custodia de Evidencias en Nube} & Google Cloud Platform \newline Google Cloud Storage & Almacenamiento seguro de evidencias fotográficas periciales de bahía & HTTPS REST API \newline Cifrado AES-256 \\
\hline
\textbf{Plataforma de Facturación Fiscal} & Nubefact PSE Cloud \newline Servidor Tributario & Emisión y firma digital de facturas y boletas electrónicas UBL 2.1 & HTTPS REST API \newline Tokens Bearer seguros \\
\hline
\textbf{Pasarela de Pagos Digitales} & Stripe Cloud \newline Infraestructura PCI-DSS & Procesamiento de suscripciones SaaS de talleres mecánicos y cobros en línea & HTTPS REST API \newline Webhooks con HMAC \\
\hline
\end{longtable}

*Nota.* Especificación técnica de los nodos de infraestructura del diagrama de despliegue de Atelier.

\newpage
