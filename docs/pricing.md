# Atelier Workshop — Estrategia de Precios, Empaquetado y Ecosistema B2B (Pricing & Packaging)

**Document version:** v7.0  
**Last updated:** 2026-09-28  
**Target Products:** Atelier Workshop (B2B SaaS para Talleres Mecánicos MYPE) y Atelier Bussiness (Marketplace B2B de Flotas)  
**Methodology:** Framework *Good-Better-Best-Enterprise*, *Universal Core Access*, *Feature Gating (IoT, AI Reports, Marketplace)* y *Tier Names: Go, Pro, Max, Enterprise* (Skill: `pricing`)  

---

## 1. Filosofía de Producto: Acceso Universal Integral desde el Plan Go

Atelier no comercializa una versión "recortada" o artificialmente inservible en su nivel de entrada. **Cualquier taller que contrata el Plan Go tiene acceso al núcleo completo de los 5 dominios de Atelier Workshop desde el primer día**, pero sujeto a cuotas y límites de escala:

1. **Operaciones de Taller (MRO):** Flujo completo de órdenes de trabajo, desglose de tareas, asignación a mecánicos, cronómetro de mano de obra y aplicación móvil Android nativa *Offline-First* con base de datos SQLite local para uso en fosa o patio.
2. **Control y Costeo de Inventario (Supply Chain):** **¡Incluye el método contable FIFO estricto por lote de adquisición desde el Plan Go!** El taller descarga repuestos descontando el costo real del lote de compra original, protegiendo su margen comercial desde el primer día (con límite de 1 almacén local).
3. **Facturación Electrónica y Cumplimiento Tributario (Billing):** Emisión integrada de boletas y facturas electrónicas oficiales ante SUNAT (estándar UBL 2.1 vía PSE) con una cuota mensual de hasta 100 comprobantes.
4. **Recursos Humanos y Asistencia (HR):** Registro del personal del taller y marcaje de asistencia con verificación perimétrica satelital mediante geocerca (*Haversine*), para hasta 5 operarios.
5. **Gestión de Clientes y Vehículos (CRM):** Historial clínico vehicular y ficha de clientes particulares (`CustomerType.INDIVIDUAL`).
6. **Peritaje Fotográfico en Dos Entidades:**
   * `work_order_images`: Fotografías de recepción perimétrica (golpes previos, rayones, combustible, odómetro) y entrega.
   * `work_order_task_images`: Evidencias probatorias de la labor mecánica en foso tipificadas por `EvidenceType` (`INITIAL_INSPECTION`, `DEFECT`, `IN_PROGRESS`, `COMPLETED`). (Límite: hasta 10 fotos por orden en Go; ilimitadas en Pro, Max y Enterprise).
7. **Bahías de Servicio Físicas Ilimitadas:** Nunca se penaliza el espacio ni el número de elevadores del local.

### 1.1. Política de Acceso Gratuito y Prueba sin Riesgo (14-Day Full Free Trial)

Para acelerar la adopción digital y permitir que el taller valide el valor de la plataforma en su operación diaria sin barreras de entrada, Atelier ofrece una política de **Prueba Gratuita Integral de 14 días** (*14-Day Free Trial*):

* **Acceso completo sin recortes:** El taller disfruta del 100% de las características y capacidades del plan seleccionado (Go, Pro o Max), incluyendo la app móvil para mecánicos, facturación electrónica de prueba, costeo FIFO y telemetría OBD-II (en planes Pro o Max).
* **Cero fricción y sin tarjeta de crédito:** No se solicita número de tarjeta de crédito ni compromiso bancario al registrarse en la plataforma.
* **Aprovisionamiento automático en base de datos:** Al registrarse el taller, la entidad `subscriptions` se crea automáticamente con el estado `status = 'trialing'`, estableciendo la vigencia exacta de 14 días en `current_period_end`.
* **Transición y custodia de datos tras el periodo de prueba:** Si al cumplirse los 14 días el taller decide no ingresar una tarjeta ni abonar la suscripción, la cuenta pasa a estado `incomplete` o `past_due`. El sistema bloquea la creación de nuevas órdenes de trabajo, pero mantiene la totalidad de los datos, historiales de clientes, inventarios y vehículos intactos durante 30 días adicionales, permitiendo que el dueño descargue sus datos o reactive su suscripción en cualquier momento con un solo clic.

---

## 2. Lógica de Desbloqueo y Progresión entre Planes

A medida que el taller actualiza de plan, no solo se expanden las capacidades cuantitativas, sino que **se desbloquean tres pilares estratégicos de alto valor**:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        ESCALERA DE DESBLOQUEO                          │
│                                                                        │
│  [ENTERPRISE]  ► Conector ERP Externo (SAP) + IA/IoT Elástica + SLA 1h │
│       ▲                                                                │
│    [MAX]       ► Reportes PDF IA + Presencia en Atelier Bussiness      │
│       ▲          + Registro de Empresas B2B + Suite ERP Automotriz     │
│    [PRO]       ► Ingesta IoT OBD-II (5 autos) + Fotos/SUNAT Ilimitado  │
│       ▲          (Sin motor de reportes predictivos PDF)               │
│     [GO]       ► Núcleo Completo (MRO, FIFO, SUNAT, HR, App Fosa)      │
│                  (Solo B2C, 0 OBD-II, cuotas de entrada)               │
└────────────────────────────────────────────────────────────────────────┘
```

### A. Desbloqueo de Telemetría IoT vs. Motor de Reportes Predictivos PDF
- **Plan Go:** **Cero telemetría (0 dispositivos OBD-II).** Operación digital interna sin escáneres en tiempo real.
- **Plan Pro:** **Desbloquea la telemetría IoT en tiempo real** (hasta 5 vehículos OBD-II activos para clientes VIP, lectura/borrado de DTCs y parámetros PIDs en vivo), **PERO SIN el motor de generación de Reportes Periciales Ejecutivos en PDF**. El mecánico o dueño ve los datos y anomalías en pantalla en vivo, pero no puede generar ni exportar el informe formal documentado.
- **Plan Max:** **Desbloquea el Motor de Reportes Periciales de Salud Vehicular y Diagnóstico Predictivo en PDF** (`GenerateVehicleHealthReportCommand` / `ExportVehicleHealthReportPdfQuery` asistidos por *Spring AI*, OpenPDF y Thymeleaf), con una cuota de **hasta 60 reportes/análisis predictivos al mes**. El taller puede imprimir o remitir a clientes corporativos un informe pericial de alta gama con evaluación probabilística de fallas y recomendaciones de servicio.

### B. El Rol de *Atelier Bussiness*: Marketplace B2B de Captación de Clientes
- **Atelier Bussiness** es el portal y directorio B2B donde empresas propietarias de flotas vehiculares (distribuidoras, empresas de logística, flotas de taxis, arrendadoras) buscan y contratan talleres mecánicos calificados y digitalizados en Lima.
- **El beneficio exclusivo del Plan Max no es solo un portal privado, sino la OPORTUNIDAD DE APARECER LISTADO Y VERIFICADO EN ATELIER BUSSINESS:**
  * El taller en Plan Max obtiene presencia destacada en el directorio corporativo de *Atelier Bussiness*.
  * Las empresas con flotas que navegan la red descubren el taller, solicitan cotizaciones y contratan sus servicios de mantenimiento corporativo directamente.
  * Al desbloquear el Plan Max, el taller queda habilitado para registrar legalmente a esas empresas como clientes corporativos B2B (`CustomerType.COMPANY`) y gestionar sus cuentas y vehículos.

### C. La Suite ERP Automotriz de Atelier (Plan Max) vs. Conexión Externa (Enterprise)
- **Plan Max (Atelier ERP Suite):** Incorpora la suite ERP automotriz completa desarrollada para la red del taller:
  1. *Multi-Almacén FIFO Inter-Sede:* Kardex valorizado consolidado entre locales y transferencias de repuestos.
  2. *Módulo Financiero Corporativo:* Cuentas por Cobrar (CxC) y Cuentas por Pagar (CxP) para liquidar créditos a 15 o 30 días con flotas.
  3. *Centros de Costo:* Rentabilidad operativa separada por sucursal física.
- **Plan Enterprise (Conector ERP Externo):** Diseñado para empresas o concesionarias que ya poseen un ERP corporativo de gran escala (SAP, Oracle, Odoo, NetSuite) y requieren que Atelier se conecte como subsistema satélite mediante APIs bidireccionales y webhooks.

---

## 3. Estructura de Planes: Go, Pro, Max y Enterprise (v7.0)

```
┌───────────────────┬───────────────────┬───────────────────┬───────────────────┐
│      PLAN GO      │     PLAN PRO ⭐   │     PLAN MAX      │  PLAN ENTERPRISE  │
│  (Taller Inicial) │ (Taller Avanzado) │  (Redes, ERP &    │ (Grandes Cadenas  │
│                   │                   │      Flotas)      │    y Concesiones) │
├───────────────────┼───────────────────┼───────────────────┼───────────────────┤
│  S/ 139 / mes     │  S/ 269 / mes     │  S/ 489 / mes     │ A Medida / Consumo│
│  (S/ 109/m anual) │  (S/ 219/m anual) │  (S/ 399/m anual) │ (Contactar Ventas)│
├───────────────────┼───────────────────┼───────────────────┼───────────────────┤
│ 5 usuarios        │ 10 usuarios       │ Hasta 25 usuarios │ Usuarios a medida │
│ Bahías ilimitadas │ Bahías ilimitadas │ Bahías ilimitadas │ Bahías ilimitadas │
│ 1 sede física     │ 1 sede física     │ Hasta 2 sedes     │ Sedes a medida    │
│ Solo Particulares │ Solo Particulares │ Empresas & Flotas │ Empresas & Flotas │
│ (INDIVIDUAL)      │ (INDIVIDUAL)      │ (COMPANY)         │ (COMPANY)         │
│ App móvil en fosa │ App móvil en fosa │ App móvil en fosa │ App móvil en fosa │
│ 10 fotos / orden  │ Fotos ilimitadas  │ Fotos ilimitadas  │ Fotos ilimitadas  │
│ Costeo FIFO lote  │ Costeo FIFO lote  │ Atelier ERP Suite │ Conexión a ERP ext│
│ Cero telemetría(0)│ 5 OBD-II activos  │ 15 OBD-II activos │ OBD-II elástico   │
│ Pulso ruta: —     │ Pulso: cada 30s   │ Pulso: cada 15s   │ Pulso a medida    │
│ Sin Reportes PDF  │ Sin Reportes PDF  │ 60 Reportes PDF/m │ Reportes ilimitados│
│ Sin IA            │ Sin IA            │ Con Spring AI     │ IA Elástica API   │
│ —                 │ —                 │ Listado en        │ Destacado VIP en  │
│                   │                   │ Atelier Bussiness │ Atelier Bussiness │
│ SUNAT 100 comp./m │ SUNAT ilimitado   │ SUNAT ilimitado   │ SUNAT ilimitado   │
│ Soporte Web/Email │ WhatsApp Priorit. │ Asistido (SLA <4h)│ Gerente (SLA < 1h)│
└───────────────────┴───────────────────┴───────────────────┴───────────────────┘
```

---

### Plan 1: Plan Go (Taller Inicial) — *El Ecosistema Completo de Entrada*
*Para talleres independientes que buscan operar con rigor profesional, costear repuestos por FIFO, dar app móvil a sus mecánicos y facturar ante SUNAT desde el primer día.*
- **Precio:** **S/ 139 al mes** (o **S/ 109 al mes** facturado anualmente: S/ 1,308 / año — **ahorro de S/ 360**).
- **Usuarios Concurrentes:** **5 usuarios de acceso** (1 Dueño, 1 Asesor de Servicio y 3 Mecánicos).
- **Sedes Físicas:** **1 sede**.
- **Bahías de Servicio:** **Ilimitadas**.
- **App Móvil Android *Offline-First*:** **Incluida para todos los mecánicos en fosa** con base de datos SQLite local.
- **Inventario y Costeo:** **Método FIFO estricto por lote de compra incluido** (1 almacén local, catálogo de repuestos y alertas de stock mínimo).
- **Tipo de Clientes Permitidos:** **Solo Personas Naturales (`CustomerType.INDIVIDUAL`).**
- **Peritaje Fotográfico:** Hasta **10 fotos por orden de trabajo** (distribuidas entre `work_order_images` y `work_order_task_images`). Almacenamiento base: 5 GB.
- **Telemetría e Ingesta OBD-II:** **Cero (0 dispositivos).** No incluye escáneres ni telemetría.
- **Reportes de Salud Vehicular PDF:** **No incluidos**.
- **Facturación Electrónica SUNAT:** Hasta **100 comprobantes mensuales** (Boletas y Facturas electrónicas UBL 2.1).
- **Soporte:** Correo electrónico y mesa de ayuda web (respuesta garantizada en 24 horas).

---

### Plan 2: Plan Pro (Taller Avanzado) — *Telemetría IoT VIP + Límites Removidos* ⭐ **(RECOMENDADO)**
*Para talleres consolidados de 1 sede que buscan telemetría en tiempo real para sus mejores clientes, facturación y fotos sin tope, y agendamiento de bahías.*
- **Precio:** **S/ 269 al mes** (o **S/ 219 al mes** facturado anualmente: S/ 2,628 / año — **ahorro de S/ 600, más de 2 meses gratis**).
- **Usuarios Concurrentes:** **10 usuarios** con control de acceso por roles (Dueño, Administrador, Asesores y Mecánicos).
- **Sedes Físicas:** **1 sede**.
- **Bahías de Servicio:** **Ilimitadas**.
- **App Móvil Android *Offline-First*:** **Uso rudo completo**.
- **Tipo de Clientes Permitidos:** **Solo Personas Naturales (`CustomerType.INDIVIDUAL`).** Bloqueado el registro de empresas.
- **Telemetría e Ingesta OBD-II (VIP):**
  - Hasta **5 dispositivos OBD-II activos** registrados en vehículos particulares VIP.
  - *Frecuencia en ruta (tráfico):* 1 lectura cada **30 segundos**.
  - *Frecuencia en bahía (diagnóstico en taller):* 1 lectura cada **2 segundos** en tiempo real.
  - Lectura y borrado de códigos DTC con catálogo explicativo.
  - Alertas push telemáticas por Firebase Cloud Messaging en tiempo real hacia el taller y el conductor.
- **Reportes de Salud Vehicular PDF:** **No incluidos** (el taller monitorea y visualiza DTCs y PIDs en pantalla en vivo, pero no cuenta con el motor de exportación de reportes periciales en PDF).
- **Respaldo Fotográfico Ilimitado:** **Fotos ilimitadas** en `work_order_images` y `work_order_task_images` con tipología pericial inmutable (`INITIAL_INSPECTION`, `DEFECT`, `IN_PROGRESS`, `COMPLETED`). Almacenamiento: 30 GB.
- **Costeo y Valorización FIFO Estricto por Lote:** Ilimitado para todo el catálogo de piezas.
- **Facturación Electrónica SUNAT Ilimitada:** Comprobantes electrónicos UBL 2.1 sin tope mensual.
- **Tablero Visual de Disponibilidad de Bahías:** Agendamiento inteligente y reducción de tiempos muertos.
- **Soporte Prioritario:** Canal directo de atención vía WhatsApp en horario laboral de taller.

---

### Plan 3: Plan Max (Redes de Talleres, ERP Automotriz & Captación B2B) — *Reportes IA y Atelier Bussiness*
*Para talleres en crecimiento con hasta 2 sedes que buscan captar clientes corporativos a través de Atelier Bussiness, emitir reportes predictivos en PDF y gestionar múltiples almacenes con ERP.*
- **Precio:** **S/ 489 al mes** (o **S/ 399 al mes** facturado anualmente: S/ 4,788 / año — **ahorro de S/ 1,080**).
- **Usuarios Concurrentes:** Hasta **25 usuarios** distribuidos entre sus sedes.
- **Sedes Físicas Incluidas:** **Hasta 2 sedes físicas incluidas** (Sede Principal + 1 Sucursal).
- **Bahías de Servicio:** **Ilimitadas** en ambas sedes.
- **Presencia Comercial en *Atelier Bussiness* (INCLUIDO):**
  - El taller **aparece listado y verificado en el marketplace B2B *Atelier Bussiness***, permitiendo que empresas con flotas vehiculares descubran el taller, soliciten cotizaciones y contraten sus servicios de mantenimiento corporativo.
- **Tipo de Clientes Permitidos:** **Habilitado el registro de Empresas (`CustomerType.COMPANY`) y Flotas Corporativas**, además de particulares.
- **Motor de Reportes Periciales PDF con Inteligencia Artificial (*Spring AI*):**
  - **Hasta 60 Reportes Periciales de Salud Vehicular en PDF al mes** (`ExportVehicleHealthReportPdfQuery` maquetados con OpenPDF y Thymeleaf), que integran series temporales de TimescaleDB, correlación de fallas DTC y recomendaciones predictivas de servicio para entregar al cliente o a la empresa de flota.
- **Suite ERP Automotriz Completa (Atelier ERP):**
  - *Multi-Almacén FIFO Inter-Sede:* Control consolidado de existencias, transferencias inter-sucursales y descargo FIFO por lote unificado.
  - *Módulo Financiero Corporativo:* Cuentas por Cobrar (CxC) y Cuentas por Pagar (CxP) para gestionar líneas de crédito comerciales con flotas.
  - *Kardex Valorizado Formal:* Reportes contables auxiliares para SUNAT y contadores externos.
  - *Centros de Costo:* Análisis de rentabilidad operativa separada por sucursal física.
- **Telemetría e Ingesta OBD-II de Flotas:**
  - Bolsa consolidada de hasta **15 dispositivos OBD-II activos** para vehículos de flotas.
  - *Frecuencia en ruta:* 1 lectura cada **15 segundos** (series temporales en TimescaleDB).
  - *Frecuencia en bahía:* 1 lectura por **segundo** (1 Hz).
- **Respaldo Fotográfico:** **Fotos ilimitadas** en `work_order_images` y `work_order_task_images` (100 GB cloud).
- **Marca Blanca en Reportes (*White-Label*):** Reportes PDF de salud vehicular y presupuestos con logotipo corporativo del taller.
- **Soporte Técnico Asistido:** Atención prioritaria con SLA de respuesta inferior a 4 horas y onboarding asistido.

---

### Plan 4: Plan Enterprise (Grandes Cadenas, Concesionarios & Flotas Masivas) — *Tarificación Elástica y a Medida*
*Para cadenas mecánicas con 3 o más sedes, concesionarias y operadores de flotas corporativas que requieren conectores con su ERP central, telemetría masiva e IA elástica.*
- **Modelo de Precios:** **Cotización personalizada basada en consumo real ("Contactar Ventas")**.
- **Esquema de Tarificación Híbrido:**
  * **Sedes Físicas:** Tarifa base dimensionada según el número exacto de locales (3, 5, 10 o más sedes).
  * **Usuarios Concurrentes:** Usuarios ilimitados o por tramos corporativos.
  * **Presencia Destacada VIP en *Atelier Bussiness*:** Posicionamiento preferencial en el marketplace para captación corporativa.
  * **Reportes de Salud Vehicular PDF con IA:** **Ilimitados** con plantillas y membretes corporativos a medida.
  * **Telemetría OBD-II Elástica por Consumo:** Paquetes elásticos de 25, 50, 100 o más dispositivos OBD-II con costo decreciente por volumen y particiones dedicadas en TimescaleDB.
  * **Inteligencia Artificial Elástica Gestionada por API:** Facturación por volumen real de análisis predictivos de *Spring AI* administrados directamente por la infraestructura de Atelier (sin intermediación de claves de terceros).
  * **Conectividad con ERPs Corporativos Externos:** Conectores e integración bidireccional mediante APIs y webhooks hacia sistemas centrales como SAP, Oracle, Odoo, NetSuite o Microsoft Dynamics.
  * **Seguridad y Soporte Dedicado:** Almacenamiento cloud exclusivo, Single Sign-On (SSO/SAML), gerente de cuenta asignado (*Dedicated Customer Success Manager*) y SLA de soporte técnico garantizado inferior a 1 hora.

---

## 4. Matriz Comparativa Exhaustiva de Características

| Dimensión / Módulo | Plan Go (S/ 139/m) | Plan Pro ⭐ (S/ 269/m) | Plan Max (S/ 489/m) | Plan Enterprise (A Medida) |
| :--- | :---: | :---: | :---: | :---: |
| **Usuarios Concurrentes** | **5 usuarios** | **10 usuarios** | **Hasta 25 usuarios** | **Ilimitados / A medida** |
| **Bahías de Servicio Físicas**| **Ilimitadas** | **Ilimitadas** | **Ilimitadas** | **Ilimitadas** |
| **Sedes Físicas** | **1 sede** | **1 sede** | **Hasta 2 sedes** | **3 o más sedes a medida** |
| **App Móvil Android en Fosa** | **✓ Incluida para todos** | **✓ Incluida para todos** | **✓ Incluida para todos** | **✓ Incluida para todos** |
| **Costeo FIFO por Lote** | **✓ Incluido (1 almacén)**| **✓ Incluido (1 almacén)**| **✓ Suite ERP Multi-Sede**| **✓ Conexión a ERP ext.** |
| **Registro de Empresas / Flotas** | **Bloqueado (Solo B2C)** | **Bloqueado (Solo B2C)** | **✓ Habilitado (B2B)** | **✓ Habilitado (B2B)** |
| **Presencia en *Atelier Bussiness***| — | — | **✓ Listado y Verificado** | **✓ Destacado VIP** |
| **Fotos `work_order_images`** | Hasta 10 fotos en total | **Ilimitadas** | **Ilimitadas** | **Ilimitadas** |
| **Fotos `work_order_task_images`**| (entre ambas entidades) | **Ilimitadas (`EvidenceType`)**| **Ilimitadas (`EvidenceType`)**| **Ilimitadas (`EvidenceType`)**|
| **Espacio Cloud de Imágenes** | 5 GB | 30 GB | 100 GB | Dedicado / Ilimitado |
| **Dispositivos OBD-II Activos** | **Cero (0)** | **Hasta 5 vehículos** | **Hasta 15 vehículos** | **Elástico por volumen** |
| **Frecuencia muestreo en ruta** | — | Cada 30 segundos | Cada 15 segundos | Configurable (5s-15s) |
| **Frecuencia muestreo en bahía**| — | Cada 2 segundos | Cada 1 segundo (1 Hz) | 1 Hz continuo |
| **Reportes de Salud Vehicular PDF**| — | — | **Hasta 60 Reportes PDF/m**| **Ilimitados a medida** |
| **Inteligencia Artificial (*Spring AI*)**| — | — | **✓ Modelos Predictivos** | **✓ IA Elástica por API** |
| **Facturación SUNAT (UBL 2.1)** | Hasta 100 comp./mes | **Ilimitada** | **Ilimitada** | **Ilimitada** |
| **Tablero de Bahías y Citas** | — | ✓ | ✓ | ✓ |
| **Marca Blanca (*White-Label*)**| — | — | ✓ | ✓ Totalmente corporativo |
| **Nivel de Soporte y SLA** | Correo (24h) | WhatsApp prioritario | Asistido (SLA < 4h) | Gerente dedicado (SLA < 1h)|

---

## 5. Diseño y Especificación de Cards de Precios para el Website de Atelier Workshop (SaaS Pricing Cards)

Esta sección define el diseño, jerarquía visual, textos comerciales (*copywriting*) y especificación técnica de componentes para la página de precios (*Pricing Page*) del portal web de **Atelier Workshop**. El diseño sigue los mejores estándares de la industria SaaS B2B moderna (como Linear, Stripe, Shopify y Gusto), utilizando un lenguaje 100% comprensible para dueños y administradores de talleres mecánicos, enfocado en **beneficios reales de negocio** y **sin restricciones negativas**.

---

### 5.1. Cabecera y Selector de Frecuencia (*Above the Fold*)

* **Título Principal (*H1*):** «Planes transparentes pensados para hacer crecer y rentabilizar tu taller»
* **Bajada (*Subheading*):** «Desde el control total de repuestos y órdenes de trabajo hasta escaneo vehicular en vivo y reportes inteligentes con Inteligencia Artificial. Todo lo que necesitas para trabajar con orden, ganar más y fidelizar a tus clientes.»
* **Insignias de Confianza (*Trust Signals*):**
  * 🛡️ **14 días de prueba gratuita** con acceso completo. Sin necesidad de ingresar tarjeta de crédito.
  * ⚡ **Listo para usar en 15 minutos.** Te acompañamos en la configuración inicial de tu taller.
  * 🔓 **Sin contratos forzosos.** Cambia de plan o cancela cuando quieras con un solo clic.
* **Selector Interactivo de Facturación (*Billing Frequency Toggle*):**
  ```
  ┌──────────────────────────────────────────────────────────────┐
  │   ( ) Facturación Mensual   │   (•) Facturación Anual ⭐   │
  │                             │       Ahorra hasta un 22%    │
  │                             │       (Más de 2 meses gratis)│
  └──────────────────────────────────────────────────────────────┘
  ```

---

### 5.2. Formato Visual de las 4 Cards Comerciales

```
┌─────────────────────────┬─────────────────────────┬─────────────────────────┬─────────────────────────┐
│         PLAN GO         │       PLAN PRO ⭐       │        PLAN MAX         │     PLAN ENTERPRISE     │
├─────────────────────────┼─────────────────────────┼─────────────────────────┼─────────────────────────┤
│ [Para Empezar]          │ [MÁS POPULAR ⭐]         │ [Redes & Flotas 🔥]     │ [Corporativo & Cadenas] │
│                         │                         │                         │                         │
│ Para talleres que       │ Para talleres que       │ Para talleres que       │ Para redes de talleres, │
│ quieren dejar el papel  │ quieren brindar un      │ atienden empresas con   │ concesionarias y        │
│ y el Excel, saber       │ servicio moderno con    │ flotas, tienen varias   │ empresas de transporte  │
│ cuánto ganan en cada    │ escaneo en pantalla y   │ sedes y quieren cerrar  │ que necesitan conectar  │
│ auto y emitir boletas   │ agilizar la entrega sin │ presupuestos con infor- │ sus sistemas y recibir  │
│ y facturas SUNAT.       │ límites de fotos.       │ mes con Inteligencia Art│ atención personalizada. │
│                         │                         │                         │                         │
│ S/ 109 / mes            │ S/ 219 / mes            │ S/ 399 / mes            │ Cotización a Medida     │
│ S/ 139 si pagas mensual │ S/ 269 si pagas mensual │ S/ 489 si pagas mensual │ Planes y capacidades    │
│ Facturado S/ 1,308/año  │ Facturado S/ 2,628/año  │ Facturado S/ 4,788/año  │ adaptadas a tu volumen  │
│ (Ahorras S/ 360 al año) │ (Ahorras S/ 600 al año) │ (Ahorras S/ 1,080/año)  │ de vehículos y locales  │
│                         │                         │                         │                         │
│ [Empezar Prueba Gratis] │ [Probar Plan Pro Gratis]│ [Empezar con Plan Max]  │ [Hablar con un Asesor]  │
│ (Sin tarjeta de crédito)│ (14 días gratis)        │ (14 días gratis)        │ (Demostración guiada)   │
├─────────────────────────┼─────────────────────────┼─────────────────────────┼─────────────────────────┤
│ CAPACIDAD INCLUIDA:     │ CAPACIDAD INCLUIDA:     │ CAPACIDAD INCLUIDA:     │ CAPACIDAD INCLUIDA:     │
│ • Hasta 5 personas en   │ • Hasta 10 personas en  │ • Hasta 25 personas en  │ • Equipo ilimitado      │
│   tu equipo de trabajo  │   tu equipo de trabajo  │   tu equipo de trabajo  │ • Sedes ilimitadas      │
│ • 1 taller o local      │ • 1 taller o local      │ • Hasta 3 talleres      │ • Órdenes ilimitadas    │
│ • Hasta 50 órdenes / mes│ • Hasta 180 órdenes/ mes│ • Órdenes ilimitadas    │ • Escáneres ilimitados  │
│ • Elevadores ilimitados │ • Elevadores ilimitados │ • Elevadores ilimitados │ • Elevadores ilimitados │
├─────────────────────────┼─────────────────────────┼─────────────────────────┼─────────────────────────┤
│ LO QUE INCLUYE:         │ TODO LO DE GO, Y ADEMÁS:│ TODO LO DE PRO, Y ADEMÁS│ TODO LO DE MAX, Y ADEMÁS│
│                         │                         │                         │                         │
│ ✓ App móvil para tus    │ ✓ Escaneo vehicular en  │ ✓ Perfil verificado en  │ ✓ Conexión directa a    │
│   mecánicos (funciona   │   vivo (monitorea hasta │   la red de clientes    │   los sistemas contables│
│   sin internet en fosas │   5 autos a la vez)     │   Atelier Bussiness     │   de tu empresa         │
│   y sótanos)            │ ✓ Lectura de fallas y   │ ✓ Atiende y factura a   │   (SAP, Oracle, otros)  │
│ ✓ Control exacto de     │   apagado de luces de   │   empresas con flotas de│ ✓ Monitoreo vehicular   │
│   repuestos y costo real│   testigo en segundos   │   vehículos             │   continuo a gran escala│
│   por reparación        │ ✓ Fotos y evidencias    │ ✓ 60 reportes de salud  │ ✓ Diagnósticos con      │
│ ✓ Emisión de boletas y  │   ilimitadas por orden  │   vehicular con Intelige│   Inteligencia Artific. │
│   facturas SUNAT        │ ✓ Boletas y facturas    │   Artific. al mes       │   sin límites           │
│   (hasta 100 al mes)    │   SUNAT ilimitadas      │ ✓ Presupuestos e infor- │ ✓ Máxima visibilidad    │
│ ✓ Control de asistencia │ ✓ Calendario visual de  │   mes con tu propio logo│   para captar flotas en │
│   por GPS para tu equipo│   bahías y citas para   │ ✓ Control multi-sucursal│   Atelier Bussiness     │
│ ✓ Historial completo de │   organizar tu patio    │   y traspaso de repuest.│ ✓ Inicio de sesión      │
│   autos y clientes      │ ✓ Alertas automáticas de│ ✓ Control de cuentas por│   empresarial seguro    │
│ ✓ Hasta 10 fotos por    │   fallas en el motor    │   cobrar a flotas       │ ✓ Asesor exclusivo para │
│   vehículo              │ ✓ Atención directa y    │ ✓ Monitorea hasta 15    │   tu negocio            │
│ ✓ Soporte por correo en │   prioritaria por       │   vehículos en simultán.│ ✓ Soporte garantizado   │
│   menos de 24 horas     │   WhatsApp              │ ✓ Soporte en < 4 horas  │   24/7 en menos de 1 h  │
└─────────────────────────┴─────────────────────────┴─────────────────────────┴─────────────────────────┘
```

---

### 5.3. Sección de Preguntas Frecuentes Comerciales (*Pricing FAQ*)

Esta sección responde a las dudas y preocupaciones más comunes de los dueños de talleres, sin tecnicismos y con total transparencia:

1. **¿Qué ocurre si mi taller crece y supero el límite de órdenes de trabajo o personal de mi plan?**
   * Tu taller nunca se detiene. Si llegas al límite de órdenes o necesitas añadir más integrantes a tu equipo, el sistema te avisará de manera amigable para que puedas actualizar tu plan al instante con un solo clic, pagando únicamente la diferencia proporcional de los días restantes.
2. **¿Puedo cambiar de plan o cancelar en cualquier momento?**
   * Sí, con total libertad. Puedes subir o bajar de plan cuando lo necesites directamente desde tu panel de configuración. Si decides cancelar, tu servicio continuará activo hasta que finalice el período ya pagado y siempre podrás descargar todos tus historiales, clientes y datos en Excel o PDF.
3. **¿Cómo me ayuda la presencia en la red *Atelier Bussiness* (Plan Max) a conseguir más clientes?**
   * Al contar con el Plan Max, tu taller aparece en el directorio de talleres verificados de *Atelier Bussiness*. En este portal, empresas de transporte, distribución y servicios buscan talleres de confianza en su zona para realizar el mantenimiento preventivo y correctivo de sus flotas de vehículos, lo que te permite cerrar contratos recurrentes y de alto valor.
4. **¿Necesito comprar equipos o escáneres costosos para usar el diagnóstico en vivo?**
   * No. Atelier es compatible con escáneres vehiculares estándar Bluetooth de bajo costo que puedes conseguir en cualquier tienda especializada. Solo lo conectas al puerto de diagnóstico del vehículo y la aplicación de tu taller lo reconocerá de inmediato para mostrarte la información en pantalla.
5. **¿Cómo me ayudan los reportes con Inteligencia Artificial a cerrar presupuestos?**
   * Cuando un cliente o empresa deja su vehículo en tu taller, la Inteligencia Artificial analiza los datos del auto y redacta un informe claro y visual con el logo de tu taller. Este informe explica en palabras sencillas el estado de los componentes, respalda la necesidad del cambio de repuestos y recomienda servicios preventivos, lo que genera una enorme confianza en el cliente y facilita la aprobación del presupuesto.
6. **¿Mis mecánicos necesitan conexión a internet permanente para usar la aplicación en el taller?**
   * No. Sabemos que en fosas mecánicas, sótanos o ciertas zonas del taller la señal de internet puede ser débil o nula. La aplicación móvil de Atelier está diseñada para que tus mecánicos puedan consultar sus tareas, registrar tiempos y tomar notas sin internet. Apenas el teléfono detecte conexión Wi-Fi o datos móviles, toda la información se sincroniza automáticamente con el sistema principal.
7. **¿Cómo me ayuda el control exacto de repuestos a ganar más dinero?**
   * Muchos talleres pierden dinero porque compran repuestos a precios distintos y los cobran al cliente con un cálculo aproximado. Atelier descuenta cada pieza con el precio real que pagaste por ella en su momento, mostrándote en pantalla tu margen de ganancia exacto por cada reparación para que nunca vendas a pérdida ni te quedes sin stock sin darte cuenta.
8. **¿Qué métodos de pago tienen disponibles?**
   * Aceptamos todas las tarjetas de crédito y débito (Visa, Mastercard, American Express) procesadas de manera segura y encriptada. Para los planes anuales de empresas también aceptamos transferencias bancarias directas (BCP, BBVA, Interbank) con emisión inmediata de factura electrónica.
9. **¿Cómo funciona la prueba gratuita de 14 días y qué ocurre si no pago al finalizar?**
   * Puedes registrar tu taller y comenzar a usar Atelier de inmediato por 14 días completos con todas las funciones del plan que elijas, sin necesidad de ingresar tarjeta de crédito ni datos bancarios. Si al terminar los 14 días decides no suscribirte, no se te cobrará absolutamente nada. Tu información, clientes y registros históricos no se eliminan. Tu cuenta simplemente pasará a modo de consulta y podrás activarla cuando desees continuar operando.
