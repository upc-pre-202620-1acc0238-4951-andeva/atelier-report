// Relaciones del Bounded Context Human Resources Management

// Clientes externos hacia controladores REST de HR
webapp -> hr_controllers "Administra turnos, supervisa asistencias y gestiona planillas de personal vía" "HTTPS/JSON"
workshop_mobile -> hr_controllers "Registra marcación de ingreso/salida con coordenadas GPS y consulta estado vía" "HTTPS/JSON"

// Controladores hacia servicios de aplicación CQRS
hr_controllers -> hr_app_services "Despacha comandos de mutación y consultas de lectura a" "In-Memory Call"

// Servicios de aplicación hacia dominio, persistencia, pasarelas y eventos
hr_app_services -> hr_domain "Ejecuta validaciones de geocerca satelital y cómputo de liquidación en" "Java Domain Calls"
hr_app_services -> hr_persistence "Persiste y recupera agregados de turnos, asistencia y nómina mediante" "Domain Ports"
hr_app_services -> hr_external_gateways "Solicita envío de boletas por correo y consulta datos de sedes a" "In-Memory Call"
hr_app_services -> hr_event_handlers "Publica eventos de dominio síncronos y transaccionales a" "Spring Events"

// Manejadores de eventos hacia persistencia Outbox
hr_event_handlers -> hr_persistence "Registra eventos de integración en outbox_messages mediante" "Domain Ports"

// Adaptadores de persistencia hacia base de datos física
hr_persistence -> db "Lee y escribe en tablas work_shifts, attendance_records, payroll_payments, payroll_items, employee_profiles vía" "JDBC/TCP"

// Pasarelas externas hacia servicios de mensajería, geolocalización y módulos hermanos
hr_external_gateways -> resend "Envía boletas de pago PDF y notificaciones transaccionales vía" "HTTPS REST (Puerto 443)"
hr_external_gateways -> google_maps "Resuelve geocodificación y coordenadas de sedes físicas vía" "HTTPS/REST"
hr_external_gateways -> iam_comp "Valida membresía del empleado y obtiene centroide de sede vía" "In-Memory ACL"
hr_external_gateways -> mro_comp "Consulta comisiones devengadas por técnico en reparaciones culminadas vía" "In-Memory ACL"

// Fachada ACL (Open Host Service) consumida por otros Bounded Contexts
mro_comp -> hr_facade "Verifica presencia activa de mecánicos en patio para asignación de órdenes vía" "In-Memory ACL"

// Fachada ACL hacia persistencia interna
hr_facade -> hr_persistence "Consulta marcación abierta y turno activo del colaborador mediante" "Domain Repositories"
