## 1.3. Segmentos Objetivo

En la fase inicial del proyecto, el ecosistema "Atelier Workshop" está circunscrito al modelo Business-to-Business. Por consiguiente, los segmentos objetivo desarrollados y abordados en este documento se enfocan exclusivamente en los actores internos de la micro, pequeña y mediana empresa del sector de mantenimiento automotriz.

Cabe destacar que existe un futuro segmento **Propietarios de Vehículos** planificado para la segunda fase del producto. Sin embargo, este tercer segmento no se contempla actualmente en la documentación de negocio, diseño UX, ni historias de usuario de este proyecto.

Dentro del taller mecánico interactúan dos perfiles con características demográficas, tecnológicas y socioeconómicas diametralmente opuestas. El éxito de la adopción del software SaaS y la telemetría IoT depende de una interfaz que reconcilie estas diferencias. A continuación, se detalla el perfilamiento estadístico de los dos segmentos abordados, basado en estudios del mercado latinoamericano y peruano.

**Segmento 1: Personal de Gestión y Propietarios del Taller**

Este segmento está conformado por los dueños y los administradores de sucursal. Son los toman decisiones, quienes asumen el riesgo financiero del negocio, controlan el inventario, dividen las órdenes de trabajo y gestionan los pagos.

**Características Demográficas y Estructura:** El perfil predominante refleja a un "migrante digital". Según estudios del sector MYPE en el Perú, el 51% de los empleadores y dueños se ubican en el rango de 45 a 64 años. Existe una marcada predominancia masculina en cargos directivos industriales (62%), y el 60% de estas organizaciones opera bajo una estructura estrictamente familiar, lo que centraliza la toma de decisiones financieras [@fundaciontelefonica2023sociedad; @inei2024internet_trimestre]. Muchos iniciaron su trayectoria como técnicos empíricos, por lo que carecen de educación formal en finanzas o ciencia de datos, priorizando la operatividad manual sobre la estrategia a largo plazo.

**Adopción Tecnológica y Madurez Digital:** Contrario a la creencia popular, el acceso a hardware no es una barrera: el 95.3% de los hogares a nivel nacional cuenta con acceso a telefonía móvil inteligente [@inei2024internet_trimestre], y casi un 70% de las MYPEs urbanas utilizan aplicaciones de banca y pagos digitales para transacciones cotidianas [@araoz2026billeteras]. Sin embargo, la madurez digital para tecnologías complejas es críticamente baja, ponderándose en apenas 1.75 sobre 5 [@fundaciontelefonica2023sociedad]. Para el 57.6% de dueños que ha intentado usar un software de gestión, la percepción general es de frustración por la complejidad de la interfaz. Por ello, exigirán que el panel de administración de Atelier sea altamente intuitivo, demostrando retornos de inversión palpables.

**Contexto Económico y Laboral:** Operan en un sector asediado por la informalidad, la cual supera el 70% a nivel nacional en servicios y comercio [@inei2024internet_trimestre]. Muchos ven la evasión tributaria como método de supervivencia, lo que limita su capacidad de facturar y acceder a contratos lucrativos con flotas corporativas. Atelier representa para ellos una herramienta de transición para formalizarse bajo el Régimen MYPE Tributario, automatizar el control de almacenes y maximizar márgenes de ganancia.

**Segmento 2: Personal Operativo del Taller**

Este segmento está constituido por el personal técnico y el equipo de primera línea del taller. Responsables de alimentar el ERP con datos físicos, recibir vehículos, ejecutar tareas y conectar dispositivos OBD-II.

**Características Demográficas y Formación Académica:** Presentan un perfil de "nativo o migrante digital temprano". Se concentran mayoritariamente en cohortes de jóvenes de 19 a 24 años y adultos jóvenes de 25 a 40 años. Debido a la sofisticación de los sistemas de inyección electrónica, el mecánico empírico está siendo desplazado por profesionales egresados de Educación Superior Técnica. Aunque el rubro sigue fuertemente masculinizado, sobre el 90%, su nivel de especialización es alto y en constante evolución.

**Adopción Tecnológica y Uso de Dispositivos Móviles:** La alfabetización digital es excepcional: el 96.4% de la población con educación superior técnica en el país utiliza activamente internet, y más del 91% accede primariamente desde un smartphone [@inei2024internet_trimestre]. Los técnicos ya están habituados a interactuar con hardware complejo, como escáneres OBD-II multimarca. Sin embargo, un hallazgo crucial revela que el 49.1% de usuarios móviles en el país accede a internet sin un plan de datos activo constante, dependiendo de redes Wi-Fi [@inei2024internet_rural]. Esto exige de forma obligatoria que la aplicación móvil de Atelier aplique una arquitectura *Offline-First* para evitar interrupciones de uso en fosos o zonas del taller sin cobertura.

**Contexto Laboral y Económico:** Este grupo enfrenta condiciones laborales precarias y alta rotación. Los sueldos en el sector MYPE independiente promedian entre S/ 1,200 y S/ 2,800 mensuales, escalando a topes formales de S/ 4,000 solo en grandes concesionarias [@revolle2022senati]. La adopción de Atelier por este segmento está fuertemente incentivada si el sistema registra inmutablemente sus tiempos de reparación y órdenes finalizadas, permitiendo a la gerencia implementar esquemas de bonificaciones transparentes y meritocráticas.

\newpage