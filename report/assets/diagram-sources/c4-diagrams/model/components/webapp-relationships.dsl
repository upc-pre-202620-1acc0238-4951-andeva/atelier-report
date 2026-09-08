// Relaciones del usuario Personal de Gestión hacia la Web Application
manager -> shell_comp "Navega entre módulos y selecciona la sucursal activa usando" "UI Web"
manager -> auth_guard_comp "Inicia sesión y autentica permisos RBAC usando" "UI Web"
manager -> dashboard_comp "Consulta métricas financieras y operativas usando" "UI Web"
manager -> mro_console_comp "Supervisa y asigna órdenes de trabajo usando" "UI Web"
manager -> inventory_comp_ui "Administra stock FIFO y compras de lotes usando" "UI Web"
manager -> invoicing_comp_ui "Emite comprobantes tributarios SUNAT usando" "UI Web"
manager -> subscription_comp_ui "Gestiona el plan de suscripción del taller usando" "UI Web"
manager -> hr_comp_ui "Administra empleados, turnos y nóminas usando" "UI Web"
manager -> customers_comp_ui "Gestiona clientes, flotas y citas de recepción usando" "UI Web"

// Enrutamiento y control de acceso interno en Angular
shell_comp -> auth_guard_comp "Valida sesión activa y privilegios de ruta usando" "TypeScript"
shell_comp -> dashboard_comp "Enruta hacia" "Angular Router"
shell_comp -> mro_console_comp "Enruta hacia" "Angular Router"
shell_comp -> inventory_comp_ui "Enruta hacia" "Angular Router"
shell_comp -> invoicing_comp_ui "Enruta hacia" "Angular Router"
shell_comp -> subscription_comp_ui "Enruta hacia" "Angular Router"
shell_comp -> hr_comp_ui "Enruta hacia" "Angular Router"
shell_comp -> customers_comp_ui "Enruta hacia" "Angular Router"

// Comunicación de componentes visuales con la capa de datos y estado
dashboard_comp -> api_client_comp "Solicita métricas analíticas usando" "Signals y RxJS"
mro_console_comp -> api_client_comp "Solicita y actualiza órdenes de trabajo usando" "Signals y RxJS"
inventory_comp_ui -> api_client_comp "Consulta inventario y registra lotes usando" "Signals y RxJS"
invoicing_comp_ui -> api_client_comp "Envía solicitudes de emisión fiscal usando" "Signals y RxJS"
subscription_comp_ui -> api_client_comp "Notifica tokens de pago y consulta planes usando" "Signals y RxJS"
hr_comp_ui -> api_client_comp "Solicita datos de personal y asistencia usando" "Signals y RxJS"
customers_comp_ui -> api_client_comp "Registra clientes y consulta agenda usando" "Signals y RxJS"
auth_guard_comp -> api_client_comp "Envía credenciales y solicita renovación de tokens usando" "Signals y RxJS"

// Llamadas salientes desde Web Application
api_client_comp -> api "Transmite peticiones RESTful autenticadas con Bearer JWT vía" "JSON/HTTPS"
subscription_comp_ui -> stripe "Tokeniza datos de tarjetas bancarias directamente vía" "Stripe.js / HTTPS"
auth_guard_comp -> google_identity "Autentica usuarios mediante Single Sign-On y obtiene ID Token vía" "Google Identity Services / HTTPS"
