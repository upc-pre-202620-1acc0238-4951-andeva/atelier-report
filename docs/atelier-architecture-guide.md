# Arquitectura y Estrategia de Implementación de "Atelier" (SaaS)

## 1. Visión Comercial: Modelo "Hardware Agnostic" (SaaS Puro)

Atelier es una plataforma SaaS (Software as a Service) pura. **No vende, no ensambla y no distribuye hardware.** El modelo de negocio se basa en el principio **BYOD** (Bring Your Own Device). El cliente (dueño del taller o flota) adquiere su propio hardware y Atelier proporciona la plataforma en la nube, las aplicaciones y el manual de configuración.

### Los Dos Tipos de Dispositivos Soportados

Para abarcar todo el mercado, Atelier soporta los dos ecosistemas de telemetría existentes:

1. **OBD2 con SIM (Standalone / Independientes):**
   - **Cómo funcionan:** Tienen un módem GSM/4G interno. Envían datos de telemetría directo al backend de Atelier sin pasar por un celular.
   - **Planes de Datos:** Requieren una tarjeta SIM. **El cliente (dueño del taller/flota) es quien compra la SIM y paga el plan de datos mensual.** Al ser solo texto, consumen unos ~30MB al mes (planes M2M muy económicos).
   - **Configuración:** Mediante un manual provisto por Atelier, el cliente envía un SMS al dispositivo para indicarle la IP/Dominio de nuestro servidor.
   - **Uso ideal:** Flotas empresariales o talleres grandes que requieren rastreo 24/7 sin depender del teléfono del chofer.

2. **OBD2 Bluetooth / WiFi (Dependientes):**
   - **Cómo funcionan:** Escáneres económicos (aprox. $10, con chip ELM327) que se conectan por Bluetooth al celular del mecánico o conductor.
   - **Planes de Datos:** No requieren SIM propia. Utilizan el internet del celular del usuario (la App Móvil sirve de puente).
   - **Uso ideal:** Talleres pequeños, inspecciones rápidas, o consumidores finales que no quieren pagar mensualidades de líneas telefónicas extra.

---

## 2. Fase 1:

Para cumplir con el requerimiento académico de usar **Kotlin y Flutter**. Se desarrollará exactamente la misma aplicación ("Atelier Workshop") en ambas tecnologías, permitiendo evaluar al final del curso cuál se queda para producción.

### App: "Atelier Workshop"

La aplicación unificará a los dos segmentos objetivo utilizando Control de Acceso Basado en Roles (RBAC), evitando el doble desarrollo a nivel de producto.

1. **Login y Backend (Java):** El servidor (Spring Boot) devuelve un token JWT con el rol del usuario (`MANAGER` o `MECHANIC`).
2. **Vista del Segmento de Gestión (Dueños/Admin):** Muestra dashboards financieros, control de inventario, facturación, lista de vehículos y gestión operativa.
3. **Vista del Segmento Operativo (Mecánicos/Asesores):** Oculta finanzas. Muestra autos asignados, registro de actividades y una interfaz para conectarse al OBD2 Bluetooth, escanear errores y enviar telemetría a la nube.

### A. Implementación en Flutter (Multiplataforma)

- **Alcance:** iOS, Android, y opcionalmente Web (perfecto para que el Manager vea todo en su computadora).
- **Persistencia Local (Offline-First):** Base de datos relacional embebida **SQLite** mediante **Drift** (sobre SQLite), gestionando tablas locales para catálogos y la cola `pending_sync_events`.
- **Módulo Bluetooth (Recurso Interno):** Se usarán paquetes como `flutter_bluetooth_serial` o `flutter_blue_plus`. Para efectos de demostración académica (sin un auto real en el salón), la aplicación se conectará a un "simulador OBD2" (que puede ser un script en una laptop o un escáner ELM327 conectado a un simulador de ECU) enviando PIDs falsos.
- **Procesamiento OBD2:** El código enviará PIDs estándar en hexadecimal (ej. `010C` para RPM) al dispositivo, parseará la respuesta y la enviará al backend Java como JSON.

### B. Implementación en Kotlin (Android Nativo)

- **Alcance:** Android (Ideal para las tablets de trabajo rudo dentro de los talleres).
- **Persistencia Local (Offline-First):** **Room Database** (Android Jetpack) como ORM reactivo sobre **SQLite**. Provee verificación estricta de consultas SQL en tiempo de compilación, cero boilerplate y mapeo directo con Kotlin Coroutines y `Flow` hacia la UI.
- **Módulo Bluetooth:** Uso de `BluetoothAdapter` y `BluetoothSocket` junto con **Coroutines** y **Flows** para lograr una lectura asíncrona altamente estable.
- **Procesamiento OBD2:** Background Services (Servicios en segundo plano) muy estables que mantienen la conexión con el vehículo aunque la app se minimice.

---

### Estrategia de Sincronización Móvil (Offline-First)

Tanto la implementación en Flutter como en Kotlin compartirán la misma base arquitectónica para operar en zonas sin internet (fosos de taller y calles sin cobertura, afectando al 49.1% de usuarios móviles sin plan de datos activo):
1. **Caché Local Relacional (Lectura con SQLite):** Se estandariza el motor relacional embebido **SQLite** para ambas plataformas: implementado mediante **Room Database** en Android (Kotlin) para garantizar consultas verificadas en compilación y reactividad con `Flow`, y mediante **Drift** en Flutter. Almacenarán catálogos estáticos y el historial de órdenes para que la interfaz cargue instantáneamente y sin depender de llamadas directas a red.
2. **Sync Queue (Escritura):** Toda interacción de modificación de estado (marcar tarea completada, pedir cita) se registrará como un evento local en la tabla `pending_sync_events`.
3. **Background Sync:** Al detectar que el dispositivo se conecta a una red Wi-Fi o 4G/5G, un *Worker* procesa en bloque (batch) todos los eventos encolados hacia el servidor en la nube (Spring Boot) asegurando la *Consistencia Eventual*.
4. **Deferred Uploads:** Toda evidencia visual recolectada offline se guardará primero de forma local y se subirá asíncronamente a Firebase Storage antes de sincronizar la URL a la base de datos relacional.

---

## 3. Fase 2:

En esta fase entraría en juego la aplicación orientada al **Segmento 3: Propietarios de Vehículos (Particulares y Flotas)** (Atelier Driver). 
* **NOTA CRÍTICA DE DOCUMENTACIÓN (Regla AI):** Como se establece en el resto de la documentación base, este segmento 3 está **fuera del alcance** para la documentación de negocio actual (User Stories, UX). Sin embargo, a nivel de **Arquitectura (2.5.3)** y **Domain-Driven Design (2.6)**, sí modelaremos las interacciones, contenedores y dominios de esta aplicación para garantizar que el diseño backend soporte esta fase futura.

En el curso de IoT, demostrarás la ingesta de los dispositivos **OBD2 con SIM (Tipo A)** que interactuarán con este segmento.

> [!NOTE]
> **Alineación con el Diagrama de Despliegue (Reporte - Sección 2.5.3.4):**  
> En el **Deployment Diagram** de la arquitectura de software se define y modela un entorno de producción comercial real (vehículo físico con puerto SAE J1962, ECU automotriz, escáneres OBD-II comerciales Bluetooth BLE y dongles telemáticos comerciales 4G LTE Cat-M1 / NB-IoT). Sin embargo, para fines de la **prueba de concepto (PoC), validación en laboratorio y entrega académica**, el despliegue físico vehicular se implementa y opera mediante el **Emulador de Hardware Comercial** y el **Simulador de Señales ECU/PIDs** detallados a continuación.

### Emulador de Hardware Comercial (Prueba de Concepto Académica)

Para no comprar un equipo costoso, ensamblarás un hardware que simulará ser un equipo de rastreo comercial.

1. **Componentes:** Microcontrolador (ej. ESP32), un módulo GSM/GPRS (ej. SIM800L) y un transceptor CAN Bus para leer un motor (o potenciómetros para simular variables como RPM y temperatura en clase).
2. **Firmware (C/C++ sobre FreeRTOS):** Escribirás un programa que recopile datos o señales simuladas, los serialice a formato JSON y utilice el módem SIM para emitir peticiones HTTP POST directamente al endpoint de ingesta de la API en Java (`/api/v1/telemetry`).
3. **Logro:** Demostrarás que el backend de Atelier es verdaderamente "Hardware Agnostic", procesando de manera idéntica los paquetes telemétricos tanto de un prototipo embebido educativo como de un dispositivo telemático comercial B2B.

---

## 4. Fase 3:

Una vez terminada se desarrollará el tercer pilar del negocio para expandir el mercado al consumidor final.

### App: "Atelier Driver" (Para clientes/dueños de los autos)

- **Funciones:** El cliente final descarga la app para ver el historial clínico de su auto, agendar citas en el taller, aprobar presupuestos, y recibir notificaciones IoT predictivas (ej. "Tu OBD2 detecta fallo en cilindro 3, agenda aquí").
- **Recomendación Tecnológica:** **Flutter**.
  - _¿Por qué no React Native?_ Tras la Fase 1, el equipo ya dominará Flutter. Podrán **reutilizar código** (paquetes compartidos de modelos, autenticación, y conexión al backend Java) entre "Atelier Workshop" y "Atelier Driver". Además, Flutter garantiza despliegue inmediato y de alta calidad tanto en iPhone como en Android sin curva de aprendizaje adicional.