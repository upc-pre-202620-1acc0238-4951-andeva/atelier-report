# Ecosistema Atelier: Desglose del Producto

## 1. El Problema y Nuestra Solución Core
Atelier nace con el propósito de **transformar radicalmente el modelo operativo tradicional de los talleres automotrices**, evolucionándolo de un enfoque puramente **reactivo** (reparar cuando el vehículo ya está averiado) a un modelo **preventivo e inteligente**.

Este salto tecnológico se logra a través de la integración de nuestro software con dispositivos **OBD2**. Nuestro *feature* principal es el **mantenimiento preventivo**, el cual genera un impacto directo en dos frentes:

* **Para los Talleres Mecánicos (B2B):** Logra la fidelización absoluta del cliente al ofrecer un servicio proactivo. Además, Atelier funciona como un potente sistema ERP y MRO que otorga control total del negocio, abarcando ámbitos administrativos (control de personal, inventario, gestión de citas, órdenes de trabajo) y económicos (módulos de facturación y cobranza).
* **Para los Conductores/Clientes (B2C / B2B2C):** Representa una reducción drástica en costos, al evitar y prevenir averías graves que terminarían siendo reparaciones costosas.

## 2. Modelo de Negocio y Hardware
Es imperativo aclarar que **Andeva NO vende hardware**. 
* **El Software:** Nosotros ofrecemos Atelier como un **Software as a Service (SaaS)** a través de modelos de suscripción mensual o anual con diferentes planes para el taller.
* **El Hardware (OBD2):** El taller es responsable de adquirir el modelo de dispositivo OBD2 que prefiera del mercado. Atelier está construido para **reconocer y anclarse a cualquier dispositivo OBD2**.
* **Instalación y Telemetría:** Proveemos los manuales de instrucción al taller para que puedan instalar los dispositivos en los vehículos de los clientes que contraten el servicio de telemetría. 

**Tipos de conexión OBD2 soportados:**
1. **Con tarjeta SIM:** Los datos del vehículo se mandan directamente a nuestro servidor de manera independiente.
2. **Con Bluetooth (BLE) / WiFi:** Los datos son enviados a través de la aplicación móvil del conductor, la cual actúa como *gateway* o puerta de enlace hacia nuestro servidor.

---

## 3. Arquitectura del Producto: Las Dos Caras de Atelier
Similar a plataformas de ecosistemas bilaterales (como Uber o Rappi), Atelier se divide en dos grandes aplicaciones para conectar a los talleres con sus clientes.

### Fase 1: Atelier Workshop
Es el pilar operativo del ecosistema, diseñado específicamente para los **dos segmentos B2B: Personal de Gestión** (dueños, administradores, recepcionistas) y **Personal Operativo** (mecánicos, técnicos de patio, asesores de servicio).

> [!IMPORTANT]
> **REGLA FUNDAMENTAL DE PRODUCTO Y ARQUITECTURA (Asimetría WebApp vs. Mobile Workshop):**
> * **Atelier Workshop sirve a ambos segmentos B2B:**
>   1. **Atelier Workshop WebApp (Escritorio):** Diseñada para **Personal de Gestión** (dueños, administradores y recepcionistas). Concentra la administración general del taller, finanzas, inventario FIFO, facturación electrónica SUNAT UBL 2.1 y planillas de RRHH. **La WebApp NO posee herramientas exclusivas de patio/piso de taller** (como escaneo Bluetooth BLE de OBD2, registro fotográfico en foso ni sincronización offline-first), ya que no tienen ninguna lógica ni utilidad para un usuario sentado frente a un escritorio.
>   2. **Atelier Workshop Mobile (Smartphones y Tablets):** Es la aplicación unificada para **AMBOS segmentos B2B**:
>      - **Para Dueños y Administradores:** Contiene **TODO lo que tiene la WebApp** (supervisión de órdenes, aprobación de presupuestos, métricas financieras, catálogo de inventario y estado del personal), permitiéndoles operar el taller en patio o fuera de la sede.
>      - **Para Mecánicos y Personal Operativo (en constante movimiento físico):** Es su **ÚNICA herramienta de trabajo**, dotada de capacidades exclusivas de patio que no están en la Web: lectura telemétrica OBD-II directa por Bluetooth Low Energy (BLE), captura fotográfica de evidencias de desarme/armado y soporte *Offline-First* con base de datos local SQLite (`Room` / `Drift`) para operar en fosos y zonas sin cobertura.

* **Aplicación Web:** Un portal de gestión integral donde converge toda la administración de escritorio del taller.
  * **RBAC y Multi-tenant:** Las vistas y permisos están estrictamente segmentados: el personal operativo (mecánicos) no accede a la web de escritorio; un administrador de sucursal tiene visión sobre el local asignado; y el dueño posee el control maestro y vista de todas sus sucursales.
* **Aplicación Móvil Cross-Platform:** Versión unificada que cubre a ambos segmentos mediante RBAC: gestión completa para administradores en patio y herramientas de piso para mecánicos en bahías.
  * **Soporte Offline-First:** Diseñado para funcionar sin conexión en fosas o zonas sin cobertura mediante base de datos relacional local sobre **SQLite** (`Room` / `Drift`), sincronizando en bloque (*Batching*) al reconectar a la red.

### Fase 2: Atelier Driver
Es la aplicación orientada al **Segmento 3: Propietarios de Vehículos (Particulares y Flotas)** (es decir, personas particulares con un vehículo o empresas con una flota de vehículos).
* **NOTA PARA DOCUMENTACIÓN (Regla AI):** Al igual que se especifica en la documentación principal, este tercer segmento de clientes finales pertenece a la Fase 2 y **NO SE CONTEMPLA** en la documentación de negocio del proyecto (historias de usuario, diseño UX, problem statement, etc.). **Sin embargo, sí se contempla y se modela explícitamente** en las secciones de Arquitectura de Software (2.5.3) y Tactical-Level Domain-Driven Design (2.6) para asegurar que el backend y los modelos escalen correctamente.

* **Aplicación Móvil Cross-Platform:** El canal de comunicación y control del cliente.
* **Para vehículos CON el servicio OBD2 activo:**
  * El conductor puede visualizar el estado de salud de su carro en tiempo real gracias a los datos enviados por el OBD2.
  * Recibe las alertas preventivas generadas por el sistema.
  * Si el OBD2 es Bluetooth/WiFi, la app de Atelier Driver permanece en segundo plano funcionando como *gateway* hacia el servidor.
  * **Telemetría Offline (Batching):** Entendiendo que el 49.1% de usuarios carece de datos móviles constantes, la app en modo offline lee los datos Bluetooth y los guarda localmente. Al detectar Wi-Fi, los empaqueta y los dispara en bloque hacia los servidores predictivos.
  * Capacidad de agendar citas en el taller de manera automatizada.
* **Para vehículos SIN el servicio OBD2 activo (o no vinculados):**
  * Un conductor puede registrar cualquier vehículo, incluso si no desea pagar por el servicio de OBD2 y las alertas preventivas.
  * En este escenario, la app sigue siendo sumamente útil: permite agendar citas con el taller, visualizar estimaciones de costos para las órdenes de trabajo, y acceder al historial completo del vehículo (registros pasados, citas, órdenes de trabajo finalizadas, e incluso alertas pasadas en caso de que el vehículo alguna vez haya gozado del servicio de telemetría).
  * En conclusión, la app Driver funciona como la interfaz de usuario del ERP del taller, fidelizando al cliente a través de la transparencia y la facilidad de gestión de su propio vehículo.
