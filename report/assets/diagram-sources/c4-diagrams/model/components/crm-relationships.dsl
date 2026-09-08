// Relaciones del Bounded Context Customer & Fleet Management (CRM)

// Clientes externos hacia controladores REST de CRM
webapp -> crm_controllers "Envía peticiones para gestión de clientes, flotas, vehículos y citas vía" "HTTPS/JSON"
workshop_mobile -> crm_controllers "Consulta clientes y registra arribo de vehículos a bahía vía" "HTTPS/JSON"
driver_mobile -> crm_controllers "Agenda citas técnicas y consulta fichas vehiculares vía" "HTTPS/JSON"

// Controladores hacia servicios de aplicación CQRS
crm_controllers -> crm_app_services "Despacha comandos de mutación y consultas de lectura a" "In-Memory Call"

// Servicios de aplicación hacia dominio, persistencia, pasarelas y eventos
crm_app_services -> crm_domain "Instancia raíces de agregado y ejecuta invariantes de negocio en" "Java Domain Calls"
crm_app_services -> crm_persistence "Persiste y recupera agregados de dominio mediante" "Domain Ports"
crm_app_services -> crm_external_gateways "Delega normalización de direcciones y validación de cuotas a" "In-Memory Call"
crm_app_services -> crm_event_handlers "Publica eventos de dominio síncronos y transaccionales a" "Spring Events"
crm_app_services -> iam_comp "Valida contexto de taller activo y pertenencia de sede vía" "In-Memory ACL"

// Manejadores de eventos hacia pasarelas externas
crm_event_handlers -> crm_external_gateways "Dispara despacho de notificaciones push móviles vía" "In-Memory Call"

// Adaptadores de persistencia hacia base de datos física
crm_persistence -> db "Lee y escribe en tablas customers, vehicles, vehicle_ownerships, appointments vía" "JDBC/TCP"

// Pasarelas externas hacia sistemas externos y módulos
crm_external_gateways -> google_maps "Normaliza y geocodifica direcciones corporativas de flotas vía" "HTTPS REST (Puerto 443)"
crm_external_gateways -> fcm "Despacha notificaciones push móviles hacia Atelier Driver vía" "HTTPS REST (Puerto 443)"
crm_external_gateways -> billing_comp "Valida límites de cuotas de clientes y vehículos según plan SaaS vía" "In-Memory Call"

// Fachada ACL (Open Host Service) consumida por otros Bounded Contexts
mro_comp -> crm_facade "Consulta ficha técnica vehicular y titular para órdenes MRO vía" "In-Memory ACL"
invoicing_comp -> crm_facade "Obtiene datos fiscales de facturación de clientes particulares y corporativos vía" "In-Memory ACL"
iot_comp -> crm_facade "Valida asociación de vehículo y propietario para flujo telemétrico vía" "In-Memory ACL"

// Fachada ACL hacia persistencia interna
crm_facade -> crm_persistence "Consulta lecturas optimizadas de agregados mediante" "Domain Repositories"
