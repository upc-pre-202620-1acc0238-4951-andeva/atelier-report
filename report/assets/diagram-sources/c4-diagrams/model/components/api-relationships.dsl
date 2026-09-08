// Relaciones de contenedores clientes hacia los componentes internos de API Application
webapp -> iam_comp "Autentica usuarios y gestiona permisos vía" "JSON/HTTPS"
webapp -> customer_fleet_comp "Registra clientes, flotas y agenda citas vía" "JSON/HTTPS"
webapp -> mro_comp "Supervisa y administra órdenes de trabajo vía" "JSON/HTTPS"
webapp -> inventory_comp "Gestiona inventario FIFO y compras de lotes vía" "JSON/HTTPS"
webapp -> hr_comp "Consulta planillas y asistencia del personal vía" "JSON/HTTPS"
webapp -> invoicing_comp "Solicita emisión de facturas y boletas SUNAT vía" "JSON/HTTPS"
webapp -> billing_comp "Administra planes y métodos de pago del taller vía" "JSON/HTTPS"

workshop_mobile -> iam_comp "Autentica credenciales de personal (gestión y operativo) vía" "JSON/HTTPS"
workshop_mobile -> mro_comp "Supervisa y sincroniza tareas, estados y evidencias vía" "JSON/HTTPS"
workshop_mobile -> customer_fleet_comp "Consulta clientes, flotas y agenda citas en patio vía" "JSON/HTTPS"
workshop_mobile -> inventory_comp "Consulta stock de repuestos y alertas FIFO en patio vía" "JSON/HTTPS"
workshop_mobile -> hr_comp "Envía coordenadas GPS para marcación de entrada y salida vía" "JSON/HTTPS"
workshop_mobile -> telemetry_comp "Transmite telemetría de diagnósticos por Bluetooth vía" "JSON/HTTPS"

driver_mobile -> iam_comp "Autentica conductores y propietarios vía" "JSON/HTTPS"
driver_mobile -> customer_fleet_comp "Consulta histórico y solicita citas vía" "JSON/HTTPS"
driver_mobile -> mro_comp "Aprueba presupuestos de mantenimiento vía" "JSON/HTTPS"
driver_mobile -> telemetry_comp "Visualiza estado de salud vehicular y alertas vía" "JSON/HTTPS"

obd2_sim -> telemetry_comp "Envía paquetes telemétricos por red celular vía" "HTTP POST / TCP"

// Relaciones intermodulares en memoria (Monolito Modular)
customer_fleet_comp -> mro_comp "Convierte citas confirmadas en órdenes de trabajo usando" "In-Memory Call"
mro_comp -> inventory_comp "Reserva y descuenta repuestos por lotes FIFO usando" "Domain Event"
mro_comp -> outbox_comp "Registra eventos de integración en outbox_messages usando" "ACID Transaction"
invoicing_comp -> outbox_comp "Registra emisión tributaria pendiente en outbox_messages usando" "ACID Transaction"

// Relaciones de componentes hacia la base de datos central
iam_comp -> db "Lee y escribe cuentas, roles y tokens vía" "JDBC/TCP"
customer_fleet_comp -> db "Lee y escribe clientes, vehículos y citas vía" "JDBC/TCP"
mro_comp -> db "Lee y escribe órdenes, tareas y presupuestos vía" "JDBC/TCP"
inventory_comp -> db "Lee y escribe catálogo, lotes y movimientos FIFO vía" "JDBC/TCP"
hr_comp -> db "Lee y escribe asistencias, sucursales y turnos vía" "JDBC/TCP"
invoicing_comp -> db "Lee y escribe comprobantes electrónicos vía" "JDBC/TCP"
billing_comp -> db "Lee y escribe suscripciones e historial de cobros vía" "JDBC/TCP"
telemetry_comp -> db "Escribe telemetría en hipertablas vía" "JDBC/TCP"
outbox_comp -> db "Lee mensajes pendientes y actualiza estados de despacho vía" "JDBC/TCP"

// Relaciones de componentes hacia sistemas externos
iam_comp -> resend "Envía correos de invitación y códigos OTP vía" "HTTPS/API"
hr_comp -> google_maps "Valida distancias contra la sucursal por fórmula Haversine vía" "HTTPS/API"
invoicing_comp -> nubefact "Delega validación fiscal de comprobantes SUNAT vía" "HTTPS/API"
billing_comp -> stripe "Procesa cobros y valida webhooks idempotentes vía" "HTTPS/API"
telemetry_comp -> fcm "Dispara notificaciones push preventivas y predictivas vía" "HTTPS/API"
outbox_comp -> resend "Despacha notificaciones por correo asíncronas vía" "HTTPS/API"
outbox_comp -> nubefact "Despacha comprobantes tributarios asíncronos vía" "HTTPS/API"
