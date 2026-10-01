# Product Marketing Context

**Document version:** v1  
**Last updated:** 2026-09-28  

## Product Overview
**One-liner:** Plataforma SaaS B2B integral que profesionaliza y digitaliza talleres mecánicos automotrices MYPE conectando el trabajo en bahía con telemetría IoT OBD-II agnóstica, control de inventario FIFO estricto por lote y facturación electrónica SUNAT nativa.  
**What it does:** Atelier Workshop une el piso de trabajo con la administración contable. Permite a los mecánicos diagnosticar vehículos mediante cualquier escáner OBD-II Bluetooth comercial, documentar reparaciones con fotos inmutables y cronometrar labores desde una app móvil Android *Offline-First* adaptada al foso, mientras el dueño o administrador gestiona órdenes de trabajo, controla repuestos por lote FIFO y emite comprobantes de pago ante SUNAT en menos de dos minutos desde un panel web.  
**Product category:** Software de Gestión para Talleres Mecánicos / Workshop Management System (WMS) / ERP Automotriz y Telemetría MRO.  
**Product type:** B2B SaaS Multi-tenant (Dashboard Web en Angular + Mobile App Android nativa *Offline-First*).  
**Business model:** Suscripción mensual recurrente bajo filosofía de acceso universal al ecosistema desde el nivel inicial (*Go, Pro, Max, Enterprise*): Plan Go (S/ 139/mes o S/ 109/mes anual, plataforma completa con MRO, FIFO por lote, HR, SUNAT y app móvil en fosa, 5 usuarios, 1 sede, cero telemetría, solo clientes particulares); Plan Pro ⭐ (S/ 269/mes o S/ 219/mes anual, 10 usuarios, 1 sede, fotos y SUNAT ilimitados, telemetría IoT hasta 5 vehículos VIP en pantalla pero sin reportes predictivos PDF); Plan Max (S/ 489/mes o S/ 399/mes anual, hasta 25 usuarios, hasta 2 sedes, presencia en marketplace B2B *Atelier Bussiness* para captar flotas, registro de empresas `COMPANY`, hasta 60 Reportes Periciales PDF de Salud Vehicular con *Spring AI*, Suite ERP Automotriz y 15 OBD-II); y Plan Enterprise (cotización a medida por consumo, dimensionado por número de sedes, OBD-II e IA elásticos por API e integración con ERPs corporativos externos como SAP u Oracle). Bahías ilimitadas en todos los planes. Especificación exhaustiva en `.agents/pricing.md`.  

## Target Audience
**Target companies:** Micro y pequeños talleres mecánicos automotrices multimarca independientes (MYPE) de 1 a 5 bahías o elevadores en Lima Metropolitana y centros urbanos de Latinoamérica, con facturación mensual entre S/ 5,000 y S/ 35,000.  
**Decision-makers:** Dueño de taller / Propietario (Segmento 1), Administrador de sede / sucursal y Jefe de patio.  
**Primary use case:** Erradicar el desorden operativo del papel, libretas manchadas y audios de WhatsApp, centralizando la recepción vehicular, el diagnóstico OBD-II, el descargo de inventario y la facturación fiscal en un flujo continuo y verificable.  
**Jobs to be done:**
- *Monitoreo operativo transparente:* "Ayúdame a saber exactamente qué vehículos están en cada bahía, qué repuestos se consumieron y cuánto se cobró, sin perseguir a los mecánicos ni cuadrar notas manuales al final del día."
- *Cierre fiscal ágil:* "Permíteme emitir facturas y boletas electrónicas SUNAT válidas al cerrar la reparación en menos de dos minutos sin pagar un software contable paralelo ni redigitar datos."
- *Respaldo probatorio inmutable:* "Facilítame respaldar cada intervención técnica con fotos periciales y lecturas de sensores computarizados para que el cliente no desconfíe del presupuesto ni reclame por averías previas."  
**Use cases:**
- Recepción pericial ágil por placa vehicular y escaneo de códigos de falla DTC en bahía.
- Formulación de proformas y presupuestos con cálculo en cascada y remisión digital en PDF.
- Descargo físico y contable atómico de existencias bajo costeo estricto FIFO por lote al montar piezas en fosa.
- Cronometraje de mano de obra efectiva con validación perimétrica de presencia física mediante geocerca GPS satelital.
- Liquidación económica inmediata y emisión de comprobantes tributarios UBL 2.1 ante SUNAT vía PSE al entregar el vehículo.

## Personas
| Persona | Cares about | Challenge | Value we promise |
|---------|-------------|-----------|------------------|
| **Pedro Suárez** *(Dueño / Administrador de Taller - Decision Maker & Financial Buyer)* | Rentabilidad del taller, evitar fugas de dinero en repuestos, formalización sin multas de SUNAT y fidelización de clientes con trato honesto. | Sobrecarga al gestionar solo presupuestos, compras y caja; clientes que desconfían de costos; dificultad para atender flotas corporativas por falta de reportes formales. | Control total del taller desde un panel web intuitivo, facturación SUNAT en dos clics y reportes periciales que cierran contratos con flotas. |
| **Andrés Vílchez** *(Técnico Mecatrónico / Mecánico de Bahía - User & Internal Champion)* | Resolver averías mecánicas complejas, que sus horas trabajadas se reconozcan para bonificaciones justas y evitar reclamos injustos. | Órdenes en papel manchadas e ilegibles, pérdida de señal en fosas de servicio, tiempos muertos esperando repuestos y usar su celular personal para fotos de respaldo. | App móvil Android de uso rudo que funciona sin internet en el foso, conexión directa con escáneres OBD-II comerciales y registro inmutable de evidencias que respalda su labor. |
| **Asesor de Servicio / Recepcionista** *(Front-Desk / User secundario en talleres estructurados)* | Atención rápida de clientes en mostrador, agendamiento ordenado y entrega vehicular sin fricciones de cobranza. | Transcripción manual de datos de clientes y vehículos, consultar disponibilidad de bahías a gritos en patio y demoras en autorización de presupuestos. | Búsqueda inmediata por placa o documento, visualización en tiempo real de bahías disponibles y emisión de pases de salida al confirmar pago. |

## Problems & Pain Points
**Core problem:** El taller mecánico tradicional opera a ciegas y desarticulado: la administración vive desconectada de lo que ocurre físicamente en la bahía o fosa, dependiendo de libretas de papel manchadas de grasa y chats informales de WhatsApp, lo que provoca mermas de inventario, pérdida de horas productivas y fricción constante con clientes que desconfían de los cobros.  
**Why alternatives fall short:**
- *CRMs administrativos locales (ej. Mi Taller CRM):* Son herramientas puramente web de escritorio, ciegas a la computadora del vehículo (sin ingesta OBD-II), carecen de aplicación móvil nativa para la fosa y aplican control de almacén genérico sin costeo contable por lote.
- *Software regional para talleres (ej. OK CAR):* No ofrece facturación nativa para Perú ante SUNAT, cobra tarifas en dólares con altos costos de implementación inicial ($150 USD) y sus alertas preventivas son cálculos teóricos de kilometraje sin conexión física a los sensores vehiculares.
- *ERPs corporativos extranjeros (ej. Taller GP):* Costos desproporcionados (€80 a €200 mensuales más consultoría europea), parametrización compleja de semanas y total desalineación con la normativa tributaria local de la microempresa peruana.
- *Hojas de cálculo y notas en papel:* Información fragmentada, alta tasa de error en cuadres contables, piezas que desaparecen del inventario y nulo respaldo legal o pericial frente a quejas.  
**What it costs them:** Hasta 15 horas semanales de sobrecarga administrativa en cálculos manuales, 40% de tiempos muertos en bahías esperando autorizaciones o repuestos, y entre 5% y 10% de pérdida en márgenes por repuestos no imputados o valorizados erróneamente.  
**Emotional tension:** Agotamiento y estrés del dueño al final de la jornada intentando cuadrar números; temor recurrente a multas o contingencias tributarias ante SUNAT; y desgaste del mecánico al sentirse cuestionado por clientes o supervisores sobre la legitimidad de su trabajo.

## Competitive Landscape
**Direct:** Mi Taller CRM (Perú) — falls short because es una plataforma web para oficina sin aplicativo móvil nativo de bahía, carece de conexión con hardware de diagnóstico OBD-II y su inventario no maneja costeo contable por lote FIFO.  
**Secondary:** OK CAR (México / Regional) — falls short because no emite comprobantes electrónicos SUNAT, factura en dólares con tarifas inaccesibles para MYPEs independientes y su mantenimiento preventivo es una estimación teórica desvinculada de la telemetría real del motor.  
**Indirect:** Cuadernos en papel, notas de mostrador y chats de WhatsApp — falls short because fomentan el extravío de información, no permiten trazabilidad contable, generan desconfianza en el cliente y vuelven imposible auditar el rendimiento real del personal técnico.

## Differentiation
**Key differentiators:**
- *Telemetría OBD-II selectiva como centro de ingresos:* Permite al taller instalar adaptadores estándar (Bluetooth o SIM) en vehículos clave de clientes, ofreciéndoles un servicio de monitoreo preventivo por suscripción mensual.
- *Arquitectura Offline-First y peritaje gráfico en dos niveles:* Atelier Workshop Mobile (disponible en todos los planes) persiste datos en SQLite y gestiona evidencias fotográficas *Direct-to-Cloud* en dos entidades formales: peritaje de recepción/entrega (`work_order_images`) y peritaje técnico de desmontaje y montaje en foso (`work_order_task_images`) según tipología (`INITIAL_INSPECTION`, `DEFECT`, `IN_PROGRESS`, `COMPLETED`).
- *Facturación electrónica SUNAT nativa (Régimen MYPE Tributario):* Emisión de boletas y facturas electrónicas UBL 2.1 integradas al cierre de la orden en menos de dos minutos, eliminando la necesidad de contratar un sistema contable por separado.
- *Control de inventario FIFO estricto por lote:* Descarga contable y física que liquida existencias según el costo real de adquisición de cada lote, protegiendo el margen comercial frente a la inflación de repuestos.
- *Portal B2B Atelier Bussiness para Flotas y Mantenimiento Predictivo IA:* Portal web corporativo dedicado para que clientes con flotas aprueben proformas y monitoreen unidades, complementado con modelos de IA (*Spring AI*) para detección temprana de fallas.  
**How we do it differently:** Unificamos en un solo ecosistema continuo el diagnóstico computarizado del vehículo, la ejecución en fosa, el almacén y el cumplimiento fiscal, adaptando la experiencia a dos interfaces creadas a medida: panel web para gestión y app móvil ruda para el mecánico.  
**Why that's better:** Reduce la duplicidad de digitación, acelera la recepción vehicular en un 40%, transparenta el presupuesto ante el conductor y formaliza la operación del taller sin elevar sus costos fijos.  
**Why customers choose us:** Porque está diseñado específicamente para las condiciones reales del taller peruano: funciona en fosas sin cobertura, cobra tarifas accesibles en soles, resuelve la tributación SUNAT y no requiere equipos informáticos sofisticados en la zona de trabajo.

## Objections
| Objection | Response |
|-----------|----------|
| *"Mis mecánicos no van a querer usar su celular o se va a ensuciar de grasa en el foso."* | La aplicación móvil está optimizada para la fosa: interfaz de alto contraste, botones amplios, flujo de pocos toques y diagnóstico rápido por Bluetooth. Además, registra objetivamente sus tiempos y respalda su trabajo técnico con evidencias fotográficas, facilitando bonificaciones por productividad sin discusiones. |
| *"Ya llevo años trabajando con libretas y Excel sin pagar mensualidades; un software es un gasto innecesario."* | Una suscripción a Atelier Workshop cuesta desde S/ 149 al mes, monto menor al margen de ganancia de un solo servicio mecánico mensual. A cambio, te ahorra el costo de un software de facturación electrónica independiente, evita pérdidas por repuestos no registrados y te permite cerrar contratos lucrativos con flotas de empresas que exigen reportes técnicos formales. |
| *"En las fosas y zonas profundas del taller se corta el internet y los datos móviles."* | Atelier Workshop Mobile está desarrollado bajo una arquitectura *Offline-First* nativa. Los mecánicos pueden escanear el vehículo, actualizar tareas y tomar fotos periciales sin ninguna conexión a internet; en cuanto el dispositivo detecta señal en el patio o la oficina, sincroniza todos los registros automáticamente sin pérdida de datos. |

**Anti-persona:** Talleres mecánicos estrictamente informales que rechazan toda posibilidad de emitir comprobantes de pago o bancarizar sus cobros; y grandes concesionarias automotrices corporativas (más de 50 sucursales) que exigen sistemas integrados a ERPs corporativos pesados como SAP con equipos de consultoría dedicados.

## Switching Dynamics
**Push:** Fugas inexplicables de dinero en repuestos extraviados, clientes molestos que reclaman cobros indebidos por falta de evidencias fotográficas, horas perdidas los fines de semana cuadrando libretas y temor constante a sanciones tributarias de SUNAT.  
**Pull:** Control centralizado del taller desde cualquier dispositivo, presupuestos con respaldo telemático OBD-II que proyectan profesionalismo, fotos del antes y después guardadas en la nube, y facturación automática en dos clics.  
**Habit:** La inercia de anotar en papelitos o pizarras de tiza, el hábito de coordinar cotizaciones y compras mediante mensajes de voz en WhatsApp, y la resistencia al cambio de mecánicos veteranos.  
**Anxiety:** Miedo a que la plataforma sea difícil de entender para colaboradores que son "migrantes digitales", temor a perder información si falla la conexión, y preocupación por interrumpir la atención diaria durante el periodo de adopción.

## Customer Language
**How they describe the problem:**
- *"Mi dolor de cabeza es cuando se dañan las herramientas o se demoran con los repuestos y se me acumulan los carros una semana."*
- *"Los clientes desconfían de entrada; piensan que uno les inventa fallas mecánicas o les cambia repuestos buenos por viejos."*
- *"En el foso no entra la señal del teléfono y tengo que subir a cada rato para coordinar o buscar información."*
- *"Tengo que andar persiguiendo al mecánico para saber cuánto tiempo real le metió a la reparación y poder cobrar lo justo."*  
**How they describe us:**
- *"Una herramienta que lee el escáner al toque y le manda la evidencia de la pieza rota al cliente para que autorice el trabajo sin dudar."*
- *"Un sistema que me dice clarito cuánto estoy ganando por cada servicio sin enredarme con la contabilidad."*
- *"Un panel que saca la boleta o factura de la SUNAT directamente de la orden terminada para no pagar dos programas distintos."*  
**Words to use:** Taller automotriz, bahía de servicio, fosa, orden de trabajo, proforma, comprobante electrónico SUNAT, escáner OBD-II, códigos de falla DTC, parámetros telemétricos en vivo, repuestos por lote, horas hombre efectivas, evidencia fotográfica inmutable.  
**Words to avoid:** Carrocería cosmética, taller artesanal, aplicativo (emplear siempre *aplicación* o *software*), comitear, buildear, jerga informática abstracta desvinculada del lenguaje mecánico.  
**Glossary:**
| Term | Meaning |
|------|---------|
| **OBD-II** | Puerto de diagnóstico a bordo (*On-Board Diagnostics II*) obligatorio en vehículos para extraer telemetría y diagnósticos de la computadora del motor. |
| **DTC** | Código de problema de diagnóstico (*Diagnostic Trouble Code*) generado por la ECU vehicular ante anomalías de sensores o actuadores. |
| **PID** | Identificador de parámetro telemétrico (*Parameter ID*) que reporta lecturas de sensores en tiempo real (RPM, temperatura, presión de combustible). |
| **Bahía de Servicio** | Puesto de trabajo físico o elevador hidráulico en el taller asignado a la intervención mecánica de una unidad vehicular. |
| **Fosa** | Estructura subterránea que permite al técnico inspeccionar los componentes inferiores del chasis y transmisión sin requerir elevador. |
| **FIFO por Lote** | Método contable (*First-In, First-Out*) donde los repuestos más antiguos en almacén son los primeros en descargarse a su costo exacto de compra. |
| **RMT** | Régimen MYPE Tributario normado por SUNAT para micro y pequeñas empresas comerciales y de servicios. |
| **Haversine** | Algoritmo trigonométrico geodésico utilizado para calcular distancias precisas y verificar que el marcaje de asistencia ocurra dentro de las coordenadas del taller. |

## Brand Voice
**Tone:** Profesional, honesto, empático y respetuoso de la experiencia técnica del mecánico y del esfuerzo financiero del microempresario automotriz.  
**Style:** Práctico, directo, enfocado en rentabilidad y productividad operativa, sin rodeos burocráticos ni tecnicismos informáticos vacíos.  
**Personality:** Robusto, confiable, transparente, pragmático y cercano a la realidad del taller peruano.

## Proof Points
**Metrics:**
- Reducción del 50% en el tiempo dedicado a tareas administrativas y cuadres manuales.
- Aceleración del 40% en el proceso de recepción vehicular mediante escaneo y vinculación automática por placa.
- Reducción del 75% en el tiempo de liquidación de órdenes y emisión de comprobantes SUNAT (menos de 2 minutos).
- Tasa de ocupación efectiva de bahías proyectada al 85% y reducción de tiempos muertos entre turnos a menos de 15 minutos.  
**Customers:** Micro y pequeños talleres mecánicos multimarca independientes en Lima Metropolitana (Chorrillos, Surquillo, San Juan de Miraflores, Los Olivos).  
**Testimonials:**
> *"Para nosotros la puntualidad y el orden son sagrados. Si la tecnología me ayuda a que el cliente entienda la falla con claridad y no se me tranquen los trabajos en el patio, el negocio avanza seguro."* — Marcelo Silva Ramos, Propietario de Taller Automotriz (Chorrillos, Lima).  
> *"Cuando entra un vehículo con una falla difícil, lo que uno necesita es que el escáner enlace al instante y que las fotos de la reparación queden registradas para que nadie dude de la chamba realizada."* — César Montero Vega, Técnico Mecatrónico Automotriz.  
**Value themes:**
| Theme | Proof |
|-------|-------|
| Diagnóstico telemático accesible | Integración hardware-agnostic con escáneres OBD-II Bluetooth comerciales de bajo costo para lectura inmediata de DTCs y PIDs. |
| Continuidad operativa en bahía y fosa | Arquitectura *Offline-First* nativa con almacenamiento local SQLite y sincronización bidireccional tolerante a fallas de red. |
| Cumplimiento fiscal y orden contable | Facturación electrónica UBL 2.1 nativa bajo Régimen MYPE Tributario ante SUNAT y descargo de existencias por lote FIFO. |

## Goals
**Business goal:** Posicionar a Atelier Workshop como la solución SaaS B2B estándar de gestión operativa y telemetría diagnóstica para talleres mecánicos MYPE en el Perú, alcanzando más de 100 talleres suscritos activos en su primer año de operación comercial.  
**Conversion action:** Solicitar una demostración técnica guiada de 15 minutos con escaneo OBD-II en vivo o activar una prueba piloto gratuita de 14 días con acompañamiento e importación de catálogo inicial.  
**Current metrics:** Fase de validación académica y prototipado MVP con 70 historias de usuario y técnicas priorizadas, arquitectura modular DDD hexagonal testeada y validación de campo con talleres mecánicos en Lima Metropolitana.

## Changelog
*Newest first. One line per revision: what changed and why.*
- v1.7 (2026-09-28) — Refined pricing model to v7.0: guaranteed full core suite in Go (Billing, HR, MRO, CRM, and FIFO batch inventory from day 1 with operational limits); Pro unlocks IoT live telemetry without PDF report generation; Max unlocks Spring AI predictive vehicle health PDF reports, listed presence in the Atelier Bussiness B2B fleet marketplace, full Atelier ERP suite, and company registration aligned with `.agents/pricing.md`.
- v1.6 (2026-09-28) — Renamed tiers to Go, Pro, Max, and Enterprise; formalized universal ecosystem access from Go (full workshop operations platform); integrated complete Atelier ERP Suite in Max; and reserved external corporate ERP connectors for Enterprise aligned with `.agents/pricing.md` v6.0.
- v1.5 (2026-09-28) — Refined pricing model to v5.0: restricted company/fleet registration exclusively to Plus and Enterprise (Pro blocked for companies), standardized portal name to Atelier Bussiness, established Atelier-managed elastic API for Enterprise AI (no BYOK), and formalized distinction between multi-warehouse FIFO and enterprise ERP integration aligned with `.agents/pricing.md`.
- v1.4 (2026-09-28) — Refined pricing model to v4.0 with 4 tiers (Básico, Pro, Plus, Enterprise): removed Haversine from tier differentiation, scaled OBD-II to sustainable volumes (0, 5, 15, elastic), introduced monthly AI inference allowance (60 queries/mo in Plus), specified work_order_images and work_order_task_images, and established elastic Enterprise tier aligned with `.agents/pricing.md`.
- v1.3 (2026-09-28) — Updated pricing model to v3.0: unlimited bays across all tiers, zero telemetry in Basic, 10 photos/order in Basic, capped Plus to 2 branches (+S/ 150/mo add-on), pooled 100 OBD-II devices, and introduced Atelier Business B2B fleet portal in Plus.
- v1.2 (2026-09-28) — Updated to universal mobile app across all tiers, dual-level photos (work_orders & work_order_tasks), minimum 5 and 10 user thresholds, and IoT OBD-II monetization limits (registered vehicles and polling frequency) aligned with `.agents/pricing.md` v2.0.
- v1.1 (2026-09-28) — Refined pricing model to 3-tier Good-Better-Best structure (Básico, Pro, Pro Plus) aligned with `.agents/pricing.md`.
- v1 (2026-09-28) — Initial context for Atelier Workshop (B2B SaaS).
