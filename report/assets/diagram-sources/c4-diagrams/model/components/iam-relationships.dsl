// Relaciones del Bounded Context IAM & Tenancy

// Clientes externos hacia componentes perimetrales de IAM
webapp -> iam_perimeter "Envía peticiones de autenticación y gestión con Bearer JWT vía" "HTTPS/JSON"
workshop_mobile -> iam_perimeter "Envía credenciales de personal y solicitudes de token vía" "HTTPS/JSON"
driver_mobile -> iam_perimeter "Envía credenciales de conductores y solicitudes de acceso vía" "HTTPS/JSON"

// Perímetro hacia seguridad y controladores
iam_perimeter -> iam_security_services "Valida firmas JWT y extrae claims de tenant/rol con" "In-Memory Call"
iam_perimeter -> iam_controllers "Canaliza peticiones autenticadas y autorizadas hacia" "FilterChain"

// Controladores hacia servicios de aplicación
iam_controllers -> iam_app_services "Despacha comandos de mutación y consultas de lectura a" "In-Memory Call"

// Servicios de aplicación hacia servicios criptográficos, dominio y persistencia
iam_app_services -> iam_security_services "Cifra contraseñas con BCrypt y genera tokens JWT con" "In-Memory Call"
iam_app_services -> iam_domain "Instancia raíces de agregado y ejecuta reglas de negocio en" "Java Domain Calls"
iam_app_services -> iam_persistence "Persiste y recupera agregados de dominio mediante" "Domain Ports"
iam_app_services -> iam_external_gateways "Delega despacho de correos y validación SSO a" "In-Memory Call"

// Adaptadores de persistencia hacia base de datos física
iam_persistence -> db "Lee y escribe en tablas tenants, users, branches, roles, etc. vía" "JDBC/TCP"

// Pasarelas externas hacia servicios de nube
iam_external_gateways -> resend "Despacha correos de OTP, invitaciones y reseteo vía" "HTTPS REST (Puerto 443)"
iam_external_gateways -> google_identity "Verifica tokens de Google Single Sign-On vía" "HTTPS (Puerto 443)"

// Fachada ACL (Open Host Service) consumida por otros Bounded Contexts
mro_comp -> iam_facade "Valida taller activo y membresía de mecánicos vía" "In-Memory ACL"
customer_fleet_comp -> iam_facade "Consulta configuración de taller y sede vía" "In-Memory ACL"
hr_comp -> iam_facade "Consulta geocercas oficiales de sede para asistencia vía" "In-Memory ACL"
invoicing_comp -> iam_facade "Valida RUC y razón social de taller emisor vía" "In-Memory ACL"
billing_comp -> iam_facade "Verifica propietario y estado de suscripción de taller vía" "In-Memory ACL"

// Fachada ACL hacia persistencia interna
iam_facade -> iam_persistence "Consulta lecturas optimizadas de agregados mediante" "Domain Repositories"
