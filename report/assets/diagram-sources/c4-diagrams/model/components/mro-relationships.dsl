// Relaciones del Bounded Context Workshop Operations (MRO)

// Clientes externos hacia controladores REST de MRO
webapp -> mro_controllers "Envía comandos de apertura de OTs, asignación de bahías y liquidación vía" "HTTPS/JSON"
workshop_mobile -> mro_controllers "Registra avance de tareas, pausas técnicas y solicita URLs pre-firmadas vía" "HTTPS/JSON"

// Controladores hacia servicios de aplicación CQRS
mro_controllers -> mro_app_services "Despacha comandos de mutación y consultas de lectura a" "In-Memory Call"

// Servicios de aplicación hacia dominio, persistencia, pasarelas y eventos
mro_app_services -> mro_domain "Instancia raíces de agregado y ejecuta invariantes de negocio en" "Java Domain Calls"
mro_app_services -> mro_persistence "Persiste y recupera agregados de dominio mediante" "Domain Ports"
mro_app_services -> mro_external_gateways "Solicita generación de URLs pre-firmadas y validaciones ACL a" "In-Memory Call"
mro_app_services -> mro_event_handlers "Publica eventos de dominio síncronos y transaccionales a" "Spring Events"

// Manejadores de eventos hacia persistencia Outbox
mro_event_handlers -> mro_persistence "Registra eventos de integración en outbox_messages mediante" "Domain Ports"

// Adaptadores de persistencia hacia base de datos física
mro_persistence -> db "Lee y escribe en tablas work_orders, work_bays, work_order_tasks, task_proposals vía" "JDBC/TCP"

// Pasarelas externas hacia almacenamiento en la nube y módulos adyacentes
mro_external_gateways -> firebase_storage "Genera URLs pre-firmadas PUT con expiración de 15 min vía" "HTTPS REST (Puerto 443)"
mro_external_gateways -> customer_fleet_comp "Consulta titularidad vehicular activa y citas de recepción vía" "In-Memory ACL"
mro_external_gateways -> iam_comp "Valida vigencia de suscripción de taller y estado de mecánicos vía" "In-Memory ACL"
mro_external_gateways -> inventory_comp "Solicita reservas de repuestos y deduce stock FIFO tras liquidación vía" "In-Memory ACL"

// Fachada ACL (Open Host Service) consumida por otros Bounded Contexts
invoicing_comp -> mro_facade "Obtiene detalle de servicios y piezas de OTs liquidadas para comprobante SUNAT vía" "In-Memory ACL"
iot_comp -> mro_facade "Asocia códigos de falla telemétricos DTC con tareas de mantenimiento vía" "In-Memory ACL"
customer_fleet_comp -> mro_facade "Consulta historial clínico de reparaciones y kilometraje registrado vía" "In-Memory ACL"

// Fachada ACL hacia persistencia interna
mro_facade -> mro_persistence "Consulta lecturas optimizadas de órdenes de trabajo y bahías mediante" "Domain Repositories"
