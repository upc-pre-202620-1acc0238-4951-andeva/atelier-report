# Capítulo II: Requirements Development and Software Solution Design

## 2.1. Competidores

En esta sección se identifican, analizan y comparan las principales soluciones tecnológicas existentes en el mercado frente a nuestra propuesta de valor **Atelier** (específicamente a través de su plataforma SaaS B2B **Atelier Workshop**). Este estudio comparativo permite evaluar las fortalezas, debilidades y modelos operativos de los competidores directos e indirectos, con el objetivo de identificar oportunidades estratégicas y ventajas competitivas que permitan resolver eficientemente las necesidades de nuestros segmentos objetivo en el sector de micro y pequeñas empresas (MYPE) de mantenimiento, reparación y operaciones automotrices (MRO).

### 2.1.1. *Análisis Competitivo*

A continuación, en la Tabla \ref{tbl:analisis-competitivo}, se presenta la matriz de análisis comparativo integral entre Atelier Workshop y tres competidores representativos del mercado: **Mi Taller CRM** (competidor directo local en Perú), **OK CAR** (competidor directo regional en Latinoamérica) y **Taller GP** (competidor indirecto internacional de nivel enterprise).

\small
\renewcommand{\arraystretch}{1.25}
\setlength{\tabcolsep}{3.5pt}
\begin{longtable}{| >{\raggedright\arraybackslash}p{2.2cm} | >{\raggedright\arraybackslash}p{3.1cm} | >{\raggedright\arraybackslash}p{3.1cm} | >{\raggedright\arraybackslash}p{3.1cm} | >{\raggedright\arraybackslash}p{\dimexpr\textwidth-11.5cm-10\tabcolsep-6\arrayrulewidth\relax} |}
\caption{Matriz de Análisis Comparativo de Competidores} \label{tbl:analisis-competitivo} \\
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{2.2cm}|}{\textbf{Criterio}} & 
\multicolumn{1}{>{\centering\arraybackslash}p{3.1cm}|}{\vspace{0.1cm}\includegraphics[width=2.4cm, height=0.85cm, keepaspectratio]{report/assets/logos/imagotipo-atelier.jpg}\vspace{0.05cm}\newline \textbf{Atelier Workshop}} & 
\multicolumn{1}{>{\centering\arraybackslash}p{3.1cm}|}{\vspace{0.1cm}\includegraphics[width=2.4cm, height=0.85cm, keepaspectratio]{report/assets/competidores/mitaller.png}\vspace{0.05cm}\newline \textbf{Mi Taller CRM}} & 
\multicolumn{1}{>{\centering\arraybackslash}p{3.1cm}|}{\vspace{0.1cm}\includegraphics[width=2.4cm, height=0.85cm, keepaspectratio]{report/assets/competidores/okcar.jpeg}\vspace{0.05cm}\newline \textbf{OK CAR}} & 
\multicolumn{1}{>{\centering\arraybackslash}p{\dimexpr\textwidth-11.5cm-10\tabcolsep-6\arrayrulewidth\relax}|}{\vspace{0.1cm}\includegraphics[width=2.4cm, height=0.85cm, keepaspectratio]{report/assets/competidores/tallergp.png}\vspace{0.05cm}\newline \textbf{Taller GP}} \\
\hline
\endfirsthead

\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{2.2cm}|}{\textbf{Criterio}} & 
\multicolumn{1}{>{\centering\arraybackslash}p{3.1cm}|}{\textbf{Atelier Workshop}} & 
\multicolumn{1}{>{\centering\arraybackslash}p{3.1cm}|}{\textbf{Mi Taller CRM}} & 
\multicolumn{1}{>{\centering\arraybackslash}p{3.1cm}|}{\textbf{OK CAR}} & 
\multicolumn{1}{>{\centering\arraybackslash}p{\dimexpr\textwidth-11.5cm-10\tabcolsep-6\arrayrulewidth\relax}|}{\textbf{Taller GP}} \\
\hline
\endhead

\hline
\multicolumn{5}{|c|}{\textbf{Perfil Empresarial y Propuesta de Valor}} \\*
\hline
\textbf{Overview} 
& Startup peruana originada en la Universidad Peruana de Ciencias Aplicadas (UPC) en 2026, enfocada en profesionalizar y digitalizar talleres automotrices MYPE mediante telemetría IoT y gestión operativa. Su producto Atelier Workshop es un ecosistema SaaS B2B nativo en la nube que integra el flujo de bahía con administración contable.
& Startup peruana fundada en 2022 en Lima, orientada a digitalizar talleres mecánicos independientes. Resuelve el desorden administrativo centralizando órdenes de trabajo, control de inventario simple y arqueo de caja en una plataforma web en la nube.
& Startup mexicana fundada en 2019, con presencia regional en 6 países (México, Colombia, Perú, Chile, Argentina y Ecuador). Digitaliza talleres medianos y grandes centralizando operaciones administrativas y relación comercial con clientes.
& Empresa española fundada en 2008 en Valencia, con más de 15 años de trayectoria en el mercado europeo y latinoamericano. ERP robusto diseñado para redes de talleres, franquicias y operadores automotrices de gran escala. \\
\hline
\textbf{Ventaja Competitiva} 
& Única solución en el mercado peruano que combina gestión SaaS B2B con ingesta telemática IoT hardware-agnostic (compatible con escáneres OBD-II comerciales) para lectura de PIDs y DTCs en tiempo real. Incluye facturación SUNAT nativa (Régimen MYPE), costeo FIFO estricto por lote, órdenes móviles con fotos inmutables Direct-to-Cloud y cronómetro con geocerca.
& Adaptación al mercado peruano con facturación electrónica SUNAT nativa, alertas de servicio y soporte técnico local con tiempo de respuesta menor a 2 horas. Presenta una curva de aprendizaje reducida con onboarding en menos de 15 minutos.
& Aplicación móvil para clientes finales orientada a la fidelización. Cuenta con un módulo de Proyección de Servicios que calcula fechas estimadas de mantenimiento según promedios de kilometraje histórico, sin conexión física al vehículo.
& Escalabilidad enterprise con soporte para más de 50 sucursales, gestión de roles granulares, consolidación contable multi-empresa y certificación internacional de seguridad ISO 27001 para grandes operadores. \\
\hline

\multicolumn{5}{|c|}{\textbf{Perfil de Marketing}} \\*
\hline
\textbf{Mercado Objetivo} 
& Talleres mecánicos multimarca independientes de pequeña y mediana escala (1 a 5 bahías o puestos de trabajo) en Lima Metropolitana, gestionados por dueños o administradores (decisores B2B) y operados por mecánicos en bahía (operarios B2B).
& Talleres mecánicos multimarca independientes pequeños y medianos en Lima Metropolitana (1 a 5 elevadores), dedicados a vehículos particulares y motocicletas, con facturación mensual entre S/ 5,000 y S/ 30,000.
& Talleres multimarca medianos y grandes (2 a 10 elevadores) en zonas urbanas de Latinoamérica, con facturación mensual superior a \$8,000 USD y nóminas de entre 5 y 20 colaboradores.
& Cadenas de talleres, concesionarias y grupos automotrices (3 a 50 sucursales) en España y Latinoamérica, con facturación superior a €50,000 mensuales que requieren consolidación financiera centralizada. \\
\hline
\textbf{Estrategias de Marketing} 
& Marketing digital B2B enfocado en dueños de taller (LinkedIn, Meta Ads, Google Search), demostraciones prácticas con emuladores telemétricos CAN Bus/OBD-II, programa piloto de prueba gratuita por 14 días y alianzas con importadores de herramientas de diagnóstico.
& Marketing digital B2B en redes sociales (Facebook e Instagram) con difusión de casos de éxito de talleres locales en Lima, demostraciones guiadas por videollamada y programa de referidos por meses de servicio gratuito.
& Estrategia híbrida con pauta digital en Google Ads y Meta, participación en ferias automotrices regionales (Expo Mecánica México, Automecánica Bogotá), webinars semanales y red de talleres embajadores.
& Venta consultiva corporativa B2B de ciclo largo, participación en ferias industriales internacionales y alianzas con firmas consultoras automotrices; no emplea publicidad masiva en medios digitales. \\
\hline

\multicolumn{5}{|c|}{\textbf{Perfil de Producto y Modelo Operativo}} \\*
\hline
\textbf{Productos y Servicios} 
& Ecosistema SaaS B2B multiplataforma compuesto por un Dashboard Web gerencial (finanzas, inventario FIFO, agenda de bahías y SUNAT) y una Mobile App Android de uso rudo y arquitectura Offline-First para mecánicos en bahía (órdenes digitales, fotos inmutables, geocerca e ingesta OBD-II).
& Plataforma web responsive de gestión que incluye órdenes de servicio, inventario simple, caja y facturación electrónica SUNAT. No dispone de aplicación nativa móvil ni de conectividad con escáneres OBD-II.
& Software web y aplicación móvil (iOS y Android) para taller y cliente final: órdenes de trabajo, inventario, facturación internacional (México y Colombia), pasarela de pagos y proyección teórica de servicios.
& ERP web desktop-first: agenda multi-sucursal, órdenes de reparación, facturación, stock avanzado, campañas de fidelización por SMS/correo e integración contable con sistemas externos (Sage y ContaPlus). \\
\hline
\textbf{Precios y Costos} 
& Suscripción SaaS mensual escalonada por bahías: Plan Básico desde S/ 149/mes (ERP operativo + órdenes móviles + facturación SUNAT) y Plan Pro desde S/ 279/mes (ingesta telemática OBD-II + fotos inmutables + módulo FIFO avanzado). Onboarding y soporte incluidos.
& Suscripción mensual desde S/ 129.99 (Plan Básico) hasta S/ 249.99 (Plan Empresarial) sin costo de implementación inicial. Alertas por mensaje de texto y módulo de reportes avanzados se comercializan como add-ons de S/ 30/mes.
& Suscripción mensual entre \$37 USD (~S/ 140) y \$97 USD (~S/ 370) según el volumen de órdenes. Cobro de \$150 USD por implementación inicial y capacitación. Módulo contable con costo extra de \$25 USD/mes.
& Precios no publicados bajo cotización corporativa personalizada. Rango estimado de €80 a €200/mes (~S/ 320 a S/ 800) con costo de consultoría e implementación inicial entre €500 y €1,500. \\
\hline
\textbf{Canales de Distribución} 
& Distribución 100\% SaaS en la nube con venta directa digital (portal web y demostraciones remotas) y venta asistida para talleres medianos. Activación en menos de 48 horas con capacitación remota y soporte técnico local.
& SaaS en la nube mediante autoservicio digital (registro web directo y cobro recurrente por pasarela) y demostraciones virtuales. No cuenta con canales físicos de distribución.
& SaaS en la nube comercializado mediante venta digital directa en portal web y representantes comerciales locales en países seleccionados de la región.
& SaaS en la nube con proceso de venta consultiva asistida, operado mediante partners y consultores autorizados en Europa y ventas remotas en Latinoamérica. \\
\hline

\multicolumn{5}{|c|}{\textbf{Análisis FODA Comparativo (SWOT)}} \\*
\hline
\textbf{Fortalezas} 
& Integración telemática OBD-II genérica en tiempo real; facturación SUNAT nativa (RMT) integrada al cierre de órdenes; registro fotográfico inmutable en la nube; inventario valorizado por FIFO estricto; doble interfaz especializada por rol B2B.
& Reconocimiento de marca local con más de 80 talleres activos en Lima; facturación SUNAT madura y actualizada; soporte técnico local rápido; interfaz web simplificada para administradores.
& Fuerte posicionamiento de marca en 6 países de Latinoamérica; app móvil atractiva para clientes finales; módulo de proyección preventiva por historial; amplia base de clientes regionales.
& Solución enterprise consolidada con más de 15 años de trayectoria; capacidad para gestionar redes de más de 50 sucursales; certificación de seguridad ISO 27001; integración contable avanzada. \\
\hline
\textbf{Debilidades} 
& Startup en fase de lanzamiento en proceso de construcción de tracción inicial; presupuesto comercial más acotado que competidores internacionales; requiere acompañamiento inicial para afianzar el hábito del operario en bahía.
& Ausencia total de integración con hardware telemático OBD-II; carece de aplicación móvil nativa (solo web móvil responsive); control de inventario básico sin costeo contable por lote.
& Inexistencia de telemetría real en vivo (mantenimiento estimado únicamente por fechas teóricas); falta de facturación electrónica para Perú (SUNAT); soporte técnico centralizado en México sin presencia local.
& Enfoque puramente administrativo sin conexión técnica vehicular; precios y tiempos de implantación inaccesibles para talleres independientes MYPE; desalineado con normativas tributarias peruanas. \\
\hline
\textbf{Oportunidades} 
& Alta penetración de vehículos con puerto OBD-II estándar en Lima Metropolitana; demanda de formalización tributaria y control financiero en talleres MYPE; programas de aceleración universitaria e institucional.
& Crecimiento de talleres de motos y vehículos ligeros en zonas urbanas; adopción masiva de pagos digitales en talleres informales; alianzas comerciales con redes mecánicas locales.
& Demanda de profesionalización en talleres medianos en el mercado peruano; integración con pasarelas de pago locales; potencial desarrollo de módulos de hardware a futuro.
& Expansión de franquicias y cadenas automotrices en centros urbanos principales; demanda de herramientas ERP con consolidación multi-sucursal. \\
\hline
\textbf{Amenazas} 
& Competidores regionales o locales que intenten incorporar módulos telemétricos o apliquen guerra de precios; resistencia cultural de dueños tradicionales a abandonar registros en papel o Excel.
& Entrada de Atelier Workshop con propuesta tecnológica superior en diagnóstico telemétrico y control de bahía; pérdida de clientes ante soluciones integrales con hardware.
& Pérdida de competitividad en el mercado peruano por la falta de facturación electrónica SUNAT nativa; encarecimiento de tarifas por devaluación del tipo de cambio frente al dólar.
& Desplazamiento frente a soluciones SaaS ligeras, ágiles y económicas que resuelven las necesidades del taller independiente sin costos de consultoría europea. \\
\hline
\end{longtable}
\normalsize

*Nota.* Elaboración propia basada en la investigación de mercado y análisis de competidores del ecosistema automotriz (2026).

### 2.1.2. *Estrategias y Tácticas frente a Competidores*

En la Tabla \ref{tbl:estrategias-tacticas-competidores} se detallan las tácticas diferenciadoras, las fortalezas que enfrentamos y las debilidades que aprovecharemos de cada competidor evaluado para posicionar estratégicamente a **Atelier Workshop** en el mercado automotriz peruano.

\small
\renewcommand{\arraystretch}{1.3}
\setlength{\tabcolsep}{4pt}
\begin{longtable}{| >{\centering\arraybackslash}p{3.0cm} | >{\raggedright\arraybackslash}p{3.9cm} | >{\raggedright\arraybackslash}p{3.9cm} | >{\raggedright\arraybackslash}p{\dimexpr\textwidth-10.8cm-8\tabcolsep-5\arrayrulewidth\relax} |}
\caption{Matriz de Estrategias y Tácticas frente a Competidores} \label{tbl:estrategias-tacticas-competidores} \\
\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{3.0cm}|}{\textbf{Competidores}} & 
\multicolumn{1}{>{\centering\arraybackslash}p{3.9cm}|}{\textbf{Táctica Diferenciadora}} & 
\multicolumn{1}{>{\centering\arraybackslash}p{3.9cm}|}{\textbf{Fortalezas Enfrentadas}} & 
\multicolumn{1}{>{\centering\arraybackslash}p{\dimexpr\textwidth-10.8cm-8\tabcolsep-5\arrayrulewidth\relax}|}{\textbf{Debilidad Aprovechada}} \\
\hline
\endfirsthead

\hline
\multicolumn{1}{|>{\centering\arraybackslash}p{3.0cm}|}{\textbf{Competidores}} & 
\multicolumn{1}{>{\centering\arraybackslash}p{3.9cm}|}{\textbf{Táctica Diferenciadora}} & 
\multicolumn{1}{>{\centering\arraybackslash}p{3.9cm}|}{\textbf{Fortalezas Enfrentadas}} & 
\multicolumn{1}{>{\centering\arraybackslash}p{\dimexpr\textwidth-10.8cm-8\tabcolsep-5\arrayrulewidth\relax}|}{\textbf{Debilidad Aprovechada}} \\
\hline
\endhead

\vspace{0.15cm}
\includegraphics[width=2.7cm, height=0.9cm, keepaspectratio]{report/assets/competidores/mitaller.png}
\vspace{0.1cm} \newline
\textbf{Mi Taller CRM}
\vspace{0.15cm}
& Posicionarse como la evolución operativa del taller: mientras Mi Taller CRM ofrece digitalización puramente administrativa en web, Atelier Workshop conecta la administración con el vehículo en la bahía de servicio mediante telemetría OBD-II agnóstica y órdenes móviles Offline-First con fotos Direct-to-Cloud.
& Reconocimiento y confianza local de más de 80 talleres en Lima junto con facturación SUNAT madura. Atelier neutraliza esta ventaja ofreciendo facturación electrónica SUNAT nativa bajo el Régimen MYPE Tributario (RMT) integrada al cierre de orden sin fricción.
& Mi Taller CRM es ciego al estado físico del vehículo (el mecánico debe diagnosticar por separado y redigitar datos). Atelier elimina la transcripción manual leyendo DTCs y PIDs directamente, acelerando la recepción en al menos 40\% y respaldando al taller con fotos inmutables. \\
\hline

\vspace{0.15cm}
\includegraphics[width=2.7cm, height=0.9cm, keepaspectratio]{report/assets/competidores/okcar.jpeg}
\vspace{0.1cm} \newline
\textbf{OK CAR}
\vspace{0.15cm}
& Confrontar su proyección teórica con diagnóstico telemétrico real: OK CAR basa el preventivo en estimaciones de fechas, mientras que Atelier Workshop procesa lecturas en tiempo real de los sensores del motor y códigos de falla activos, sumando cumplimiento tributario local directo.
& Posicionamiento en 6 países y aplicativo pulido. Atelier contrarresta esto mediante una aplicación móvil Android de uso rudo diseñada para la bahía de servicio (alto contraste, pocos toques, Offline-First), adaptada a las condiciones hostiles de fosas y talleres mecánicos.
& OK CAR carece de facturación SUNAT para Perú (obliga al taller a usar un software contable paralelo) y su predictivo carece de sustento telemétrico. Atelier resuelve esto con una solución todo-en-uno que factura en soles y emite alertas mecánicas precisas sin costos en dólares. \\
\hline

\vspace{0.15cm}
\includegraphics[width=2.7cm, height=0.9cm, keepaspectratio]{report/assets/competidores/tallergp.png}
\vspace{0.1cm} \newline
\textbf{Taller GP}
\vspace{0.15cm}
& Ofrecer agilidad, bajo costo e integración técnica para el 90\% del mercado independiente: mientras Taller GP requiere semanas de implantación y miles de euros de inversión para cadenas corporativas, Atelier Workshop se implementa en menos de 48 horas a costo MYPE.
& Trayectoria de más de 15 años, solidez enterprise y certificación ISO 27001. Atelier responde implementando una arquitectura de software modular guiada por el dominio (DDD), que asegura alta disponibilidad, resiliencia y separación limpia de módulos.
& Elevados costos de implementación, procesos lentos de onboarding, ausencia de facturación SUNAT y desvinculación del diagnóstico en bahía. Atelier capitaliza este vacío atendiendo a talleres independientes que buscan modernizarse sin tarifas de consultoría europea. \\
\hline
\end{longtable}
\normalsize

*Nota.* Elaboración propia (2026).

\newpage