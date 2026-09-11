# Arquitectura de Telemetría OBD2 en Atelier

Atelier utiliza el puerto OBD2 (On-Board Diagnostics) de los vehículos para extraer datos telemétricos en tiempo real (PIDs) y códigos de falla (DTC). Esta información es el pilar para ofrecer el servicio de mantenimiento preventivo y predictivo.

Es importante destacar que el taller mecánico es quien provee, configura e instala los dispositivos OBD2 en los vehículos de los clientes que contratan el servicio. Estos dispositivos están preconfigurados por el taller para enrutar sus datos de manera encriptada y exclusiva hacia el ecosistema de servidores de Atelier. Un OBD2 comercial comprado por un conductor por su cuenta no se vinculará mágicamente con la plataforma de Atelier.

Atelier soporta dos arquitecturas principales de conectividad OBD2:

## 1. Dispositivos OBD2 con Tarjeta SIM (Conexión Directa)

En este modelo, el dispositivo OBD2 cuenta con su propio módem de conectividad celular (IoT/M2M) y una tarjeta SIM insertada.

* **Flujo de Datos:** El OBD2 extrae la información de la computadora del vehículo (ECU) y la transmite directamente a los servidores de Atelier (backend) a través de la red de telefonía móvil de manera autónoma.
* **Ventajas:**
  * **Independencia absoluta:** Funciona sin importar si el conductor lleva su teléfono en el vehículo, si el celular tiene batería o si la app está abierta.
  * **Confiabilidad:** Garantiza la recolección ininterrumpida de datos mientras el auto esté encendido y con señal celular.
* **Consideraciones:** Implica un costo operativo mensual por el plan de datos M2M asociado a la SIM.

## 2. Dispositivos OBD2 con Bluetooth/WiFi (Smartphone como Gateway)

En este modelo, el dispositivo no tiene acceso directo a internet, sino que se comunica localmente.

* **Flujo de Datos:** 
  1. El OBD2 extrae los datos y los envía al smartphone del conductor mediante Bluetooth (BLE) o WiFi local.
  2. La aplicación respectiva (ya sea **Atelier Driver** en el celular del conductor si el auto está en la calle, o **Atelier Workshop** en la tablet del mecánico si el auto está siendo inspeccionado en el taller) captura estos datos actuando como una puerta de enlace (*gateway*) vía Bluetooth.
  3. La aplicación retransmite la información a los servidores de Atelier (backend) usando la red WiFi o el plan de datos 4G/5G del dispositivo móvil.
* **Ventajas:**
  * **Hardware económico:** Los scanners Bluetooth/WiFi son considerablemente más baratos.
  * **Sin pago de datos M2M:** Al aprovechar el internet del teléfono del conductor, el taller evita el costo mensual de la línea celular.
  * **Resiliencia (Offline-First Batching con SQLite):** Si el dispositivo móvil carece de plan de datos activo o transita por zonas sin cobertura, la app resguarda la telemetría en una base de datos local relacional **SQLite** (gestionada mediante **Room** en Android/Kotlin y **Drift** en Flutter) y efectúa una sincronización masiva en bloque (*Batching*) hacia la API de Atelier / TimescaleDB tan pronto recupera la conexión a internet, previniendo la pérdida de métricas y salvaguardando la integridad del historial analítico.
* **Consideraciones:**
  * Requiere que el teléfono del conductor esté en el auto, encendido, con Bluetooth activo, y que la app de Atelier tenga permisos del sistema operativo para ejecutarse en segundo plano sin ser bloqueada por el ahorro de batería.
  * **Caso de Uso Especial: Flotas de Empresas.** Cuando el cliente del taller es una empresa con una flota vehicular y eligen OBD2 BLE/WiFi, el dueño de la flota no es quien conduce los vehículos. En este escenario, la app Atelier Driver incorpora perfiles de "Conductor de Flota". El empleado que maneja el vehículo se loguea en la app con este rol, y su teléfono funciona única y exclusivamente como el *gateway* para transmitir los datos de ese vehículo durante su turno. El dueño de la empresa, desde su cuenta principal (ya sea web o en su propia app), puede visualizar de manera centralizada la telemetría, alertas y ubicación de toda su flota, recibiendo los datos sin estar presente en cada vehículo.

## Procesamiento de Alertas

El motor de diagnóstico de Atelier reside en el servidor en la nube. Independientemente de si los datos viajaron vía SIM o vía Gateway (App), una vez que llegan a nuestra infraestructura, se analizan constantemente. 

Si el sistema detecta una desviación grave en los datos en tiempo real (PIDs) o si la ECU del auto reporta un código de error (DTC), Atelier genera una alerta automática. Esta alerta es enviada **simultáneamente** al tablero de administración del taller (Atelier Workshop) y al teléfono del cliente (Atelier Driver), garantizando transparencia inmediata y permitiendo que cualquiera de las dos partes inicie el agendamiento de la reparación preventiva.

---

## 3. Implementación de Demostración y Prueba de Concepto (Laboratorio)

Tal como se establece en `docs/atelier-architecture-guide.md` y en el Diagrama de Despliegue del reporte de arquitectura (Sección 2.5.3.4), mientras que el diseño arquitectónico objetivo soporta dongles comerciales OBD-II (ELM327 BLE y rastreadores telemáticos 4G LTE Cat-M1 / NB-IoT), la validación académica en aula y laboratorio prescinde de vehículos físicos y hardware industrial costoso mediante:
1. **Emulador de Hardware Comercial con SIM (Tipo A):** Prototipo embebido basado en microcontrolador ESP32 con firmware en C/C++ (FreeRTOS) y módulo celular SIM800L, que emite tramas JSON telemétricas directamente al endpoint `/api/v1/telemetry`.
2. **Simulador de Señales ECU / PIDs (Tipo B):** Generador de tramas y comandos AT estándar ELM327 (RPM `010C`, velocidad `010D`, temperatura de refrigerante `0105`, DTCs) transmitidos por Bluetooth hacia las aplicaciones móviles de Atelier.
Esto comprueba que la capa de ingestión y analítica en la nube es 100% independiente del fabricante del hardware telemático.
