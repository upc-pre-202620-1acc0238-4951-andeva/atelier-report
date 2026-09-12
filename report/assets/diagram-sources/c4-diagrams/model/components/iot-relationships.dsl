// Relaciones del Bounded Context IoT Telemetry & Predictive Maintenance

// Clientes externos hacia controladores REST de IoT
webapp -> iot_controllers "Supervisa flotas, configura dispositivos OBD-II, consulta catálogo DTC y genera informes periciales PDF vía" "HTTPS/JSON"
workshop_mobile -> iot_controllers "Registra hardware OBD-II, empareja vehículos y consulta códigos de avería vía" "HTTPS/JSON"
driver_mobile -> iot_controllers "Consulta estado telemático, odómetro, alertas predictivas y reporte de salud vía" "HTTPS/JSON"
obd2_sim -> iot_controllers "Transmite lotes de telemetría por red celular vía" "HTTP POST / TCP"

// Controladores hacia servicios de aplicación CQRS
iot_controllers -> iot_app_services "Delega comandos de ingesta, emparejamiento, fallas, consultas e informes clínicos a" "In-Memory Call"

// Servicios de aplicación hacia dominio, persistencia, pasarelas y eventos
iot_app_services -> iot_domain "Evalúa sobrecalentamiento, fallas eléctricas y reglas SAE J2012 en" "Java Domain Calls"
iot_app_services -> iot_persistence "Persiste lecturas telemáticas y entidades de diagnóstico mediante" "Domain Repositories"
iot_app_services -> iot_external_gateways "Solicita despacho push a FCM, inferencia a Groq AI, renderizado PDF y consulta MRO a" "In-Memory Call"
iot_app_services -> iot_event_handlers "Publica eventos de anomalía detectada e ingesta telemática a" "Spring Events"

// Manejadores de eventos hacia pasarela push
iot_event_handlers -> iot_external_gateways "Dispara notificaciones push inmediatas a conductores vía" "Gateway Calls"

// Adaptadores de persistencia hacia base de datos física (PostgreSQL 16 y TimescaleDB)
iot_persistence -> db "Lee y escribe en obd2_devices, device_installations, vehicle_faults, predictive_alerts, dtc_catalog, telemetry_logs vía" "JDBC/TCP"

// Pasarelas externas hacia FCM, Groq Cloud LPU y capas anticorrupción
iot_external_gateways -> fcm "Despacha notificaciones push de alta prioridad vía" "HTTPS/API"
iot_external_gateways -> groq "Infiere diagnósticos estructurados y correlaciones causales con Llama 3.3 70B vía" "Spring AI / HTTPS"
iot_external_gateways -> mro_comp "Consulta catálogo de servicios preventivos sugeridos en" "In-Memory ACL"
iot_external_gateways -> customer_fleet_comp "Consulta tokens FCM de conductores y dueños en" "In-Memory ACL"

// Fachada OHS consumida por contextos hermanos
mro_comp -> iot_facade "Consulta kilometraje y códigos DTC para órdenes de trabajo vía" "In-Memory ACL"
customer_fleet_comp -> iot_facade "Consulta tacómetro y estado de salud vehicular para flotas vía" "In-Memory ACL"
iot_facade -> iot_persistence "Recupera última métrica e historial telemático en" "Domain Repositories"
