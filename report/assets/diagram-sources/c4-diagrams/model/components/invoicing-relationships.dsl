// Relaciones del Bounded Context Invoicing & Compliance

// Clientes externos hacia controladores REST de Invoicing
webapp -> invoicing_controllers "Administra comprobantes, registra cobros y supervisa flujo de caja vía" "HTTPS/JSON"
workshop_mobile -> invoicing_controllers "Consulta estado de liquidación de órdenes y registra cobros en mostrador vía" "HTTPS/JSON"

// Controladores hacia servicios de aplicación CQRS
invoicing_controllers -> invoicing_app_services "Despacha comandos de emisión/pago y consultas financieras a" "In-Memory Call"

// Servicios de aplicación hacia dominio, persistencia, pasarelas y eventos
invoicing_app_services -> invoicing_domain "Ejecuta cálculo tributario de IGV y validación de reglas SUNAT en" "Java Domain Calls"
invoicing_app_services -> invoicing_persistence "Persiste y recupera agregados de comprobantes, pagos y series mediante" "Domain Repositories & Pessimistic Lock"
invoicing_app_services -> invoicing_external_gateways "Solicita despacho fiscal a Nubefact, envío de correos y consulta CRM a" "In-Memory Call"
invoicing_app_services -> invoicing_event_handlers "Publica eventos de dominio síncronos y transaccionales a" "Spring Events"

// Manejadores de eventos hacia persistencia Outbox
invoicing_event_handlers -> invoicing_persistence "Registra eventos de integración en outbox_messages mediante" "Domain Ports"

// Adaptadores de persistencia hacia base de datos física
invoicing_persistence -> db "Lee y escribe en electronic_vouchers, voucher_lines, voucher_payments, sunat_series_configurations vía" "JDBC/TCP"

// Pasarelas externas hacia servicios tributarios, mensajería y módulos hermanos
invoicing_external_gateways -> nubefact "Transmite tramas JSON V1 y recibe CDR/PDF/XML con certificado digital vía" "HTTPS REST (Puerto 443)"
invoicing_external_gateways -> resend "Envía comprobantes electrónicos PDF y XML UBL 2.1 por correo vía" "HTTPS/API"
invoicing_external_gateways -> sunat "Valida condición de contribuyente y padrón RUC vía" "HTTPS/REST"
invoicing_external_gateways -> customer_fleet_comp "Consulta razón social, documento y domicilio fiscal en CRM vía" "In-Memory ACL"
invoicing_external_gateways -> inventory_comp "Consulta órdenes de compra recibidas para cómputo de flujo de caja vía" "In-Memory ACL"
invoicing_external_gateways -> hr_comp "Consulta planillas salariales liquidadas para cómputo de flujo de caja vía" "In-Memory ACL"

// Fachada ACL (Open Host Service) consumida por Workshop Operations
mro_comp -> invoicing_facade "Solicita facturación y liquidación fiscal de órdenes de trabajo culminadas vía" "In-Memory ACL"

// Fachada ACL hacia servicios de aplicación
invoicing_facade -> invoicing_app_services "Delega emisión de comprobantes y amortización de pagos a" "In-Memory Call"
