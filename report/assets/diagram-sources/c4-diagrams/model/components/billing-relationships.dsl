// Relaciones del Bounded Context SaaS Billing & Subscriptions

// Clientes externos hacia controladores REST de Billing
webapp -> billing_controllers "Administra planes, inicia checkout y consulta facturas vía" "HTTPS/JSON"
workshop_mobile -> billing_controllers "Consulta estado de membresía y cuotas operativas vigentes vía" "HTTPS/JSON"
stripe -> billing_controllers "Envía notificaciones asíncronas de cobro y cambios de estado vía" "HTTPS Webhooks"

// Controladores hacia servicios de aplicación CQRS
billing_controllers -> billing_app_services "Despacha comandos de contratación/cancelación y consultas a" "In-Memory Call"

// Servicios de aplicación hacia dominio, persistencia, pasarelas y eventos
billing_app_services -> billing_domain "Ejecuta validación de cuotas, invariantes y reglas de negocio en" "Java Domain Calls"
billing_app_services -> billing_persistence "Persiste y recupera agregados de suscripción y facturas mediante" "Domain Repositories"
billing_app_services -> billing_external_gateways "Solicita sesiones de Checkout y portales en Stripe, y correos a Resend a" "In-Memory Call"
billing_app_services -> billing_event_handlers "Publica eventos de dominio y notificaciones de webhook a" "Spring Events"

// Manejadores de eventos hacia persistencia e invalidación de caché
billing_event_handlers -> billing_persistence "Registra eventos de webhook para control estricto de idempotencia en" "Domain Ports"
billing_event_handlers -> billing_facade "Invalida reactivamente la memoria en caché ante cambios de suscripción en" "Cache Evict"

// Adaptadores de persistencia hacia base de datos física
billing_persistence -> db "Lee y escribe en plans, plan_features, subscriptions, invoices, stripe_events vía" "JDBC/TCP"

// Pasarelas externas hacia Stripe y Resend
billing_external_gateways -> stripe "Genera Checkout Sessions, Customer Portals y consulta facturas vía" "HTTPS REST (Puerto 443)"
billing_external_gateways -> resend "Despacha correos con recibos y alertas de regularización de cobros vía" "HTTPS/API"
billing_external_gateways -> iam_comp "Consulta datos fiscales del taller para inicializar sesiones de cobro vía" "In-Memory ACL"

// Fachada OHS consumida por contextos hermanos
iam_comp -> billing_facade "Consulta límites de sucursales y personal antes de registrar recursos vía" "In-Memory ACL"
mro_comp -> billing_facade "Verifica membresía activa y permisos de módulos avanzados vía" "In-Memory ACL"
billing_facade -> billing_persistence "Consulta cuotas y vigencia de suscripción en" "Domain Repositories"
