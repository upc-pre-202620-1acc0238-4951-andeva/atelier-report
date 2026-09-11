// Relaciones del Bounded Context Inventory & Supply Chain

// Clientes externos hacia controladores REST de Inventory
webapp -> inventory_controllers "Gestiona catálogo de repuestos, ingreso de lotes y órdenes de compra vía" "HTTPS/JSON"
workshop_mobile -> inventory_controllers "Consulta disponibilidad de existencias y alertas de stock en patio vía" "HTTPS/JSON"

// Controladores hacia servicios de aplicación CQRS
inventory_controllers -> inventory_app_services "Despacha comandos de mutación y consultas de lectura a" "In-Memory Call"

// Servicios de aplicación hacia dominio, persistencia, pasarelas y eventos
inventory_app_services -> inventory_domain "Instancia raíces de agregado y ejecuta reglas de negocio FIFO en" "Java Domain Calls"
inventory_app_services -> inventory_persistence "Persiste y recupera agregados de dominio mediante" "Domain Ports"
inventory_app_services -> inventory_external_gateways "Solicita generación de URLs pre-firmadas y validación RUC a" "In-Memory Call"
inventory_app_services -> inventory_event_handlers "Publica eventos de dominio síncronos y transaccionales a" "Spring Events"

// Manejadores de eventos hacia persistencia Outbox
inventory_event_handlers -> inventory_persistence "Registra eventos de integración en outbox_messages mediante" "Domain Ports"

// Adaptadores de persistencia hacia base de datos física
inventory_persistence -> db "Lee y escribe en tablas inventory_items, inventory_batches, suppliers, purchase_orders, purchase_order_items vía" "JDBC/TCP"

// Pasarelas externas hacia almacenamiento en la nube, servicios estatales y módulos
inventory_external_gateways -> firebase_storage "Genera URLs pre-firmadas PUT con expiración de 15 min vía" "HTTPS REST (Puerto 443)"
inventory_external_gateways -> sunat "Consulta estado activo y condición de habido de proveedores vía" "HTTPS/REST"
inventory_external_gateways -> iam_comp "Valida vigencia de suscripción de taller y pertenencia de sede vía" "In-Memory ACL"

// Fachada ACL (Open Host Service) consumida por otros Bounded Contexts
mro_comp -> inventory_facade "Solicita reserva de repuestos con costeo FIFO y deducción final vía" "In-Memory ACL"
invoicing_comp -> inventory_facade "Consulta valorización contable de repuestos para liquidación fiscal vía" "In-Memory ACL"

// Fachada ACL hacia persistencia interna
inventory_facade -> inventory_persistence "Consulta lecturas optimizadas de catálogo y lotes mediante" "Domain Repositories"
