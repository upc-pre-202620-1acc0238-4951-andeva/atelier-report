workspace "Atelier Architecture" "Diagramas de Arquitectura C4 para el Proyecto Atelier" {

    model {
        !include model/actors.dsl
        !include model/external-systems.dsl
        !include model/systems/atelier-core.dsl

        // Relaciones entre actores y el sistema
        manager -> atelier "Gestiona el taller, inventario, facturación y personal B2B usando"
        mechanic -> atelier "Ejecuta órdenes MRO y sincroniza evidencia offline usando"
        driver -> atelier "Visualiza histórico clínico, alertas predictivas y reserva citas usando"
        
        // Relaciones IoT
        obd2_sim -> atelier "Envía telemetría de PIDs y DTCs por red celular a" "TCP/IP"
        
        // Relaciones del sistema hacia sistemas externos
        atelier -> stripe "Procesa cobros recurrentes de suscripciones SaaS B2B usando" "HTTPS/API"
        atelier -> nubefact "Delega la emisión de comprobantes electrónicos B2B y B2C a" "HTTPS/API"
        atelier -> fcm "Envía notificaciones push de diagnósticos a móviles vía" "HTTPS/API"
        atelier -> firebase_storage "Almacena fotos de evidencia directo en la nube vía" "HTTPS/API"
        atelier -> resend "Envía correos transaccionales de OTP, invitaciones y facturas vía" "HTTPS/API"
        atelier -> google_maps "Normaliza direcciones y valida geocercas GPS usando" "HTTPS/API"
        atelier -> google_identity "Valida identidades federadas de Google OAuth2 vía" "HTTPS/API"
        // Relaciones a nivel de Contenedor (Container Level)
        manager -> landing "Explora la propuesta de valor y planes de suscripción usando" "HTTPS"
        driver -> landing "Consulta información de talleres afiliados usando" "HTTPS"
        manager -> webapp "Administra el taller, inventario FIFO, RRHH y finanzas desde escritorio usando" "HTTPS"
        manager -> workshop_mobile "Supervisa operaciones, aprueba presupuestos y gestiona el taller en patio usando" "UI Móvil"
        mechanic -> workshop_mobile "Ejecuta tareas MRO en foso, escanea OBD2 por BLE y captura evidencia usando" "UI Móvil"
        driver -> driver_mobile "Agenda citas, visualiza salud vehicular y aprueba presupuestos usando" "UI Móvil"

        landing -> webapp "Redirige al inicio de sesión y registro de talleres usando" "HTTPS"
        webapp -> api "Consume endpoints RESTful de gestión y reportes vía" "JSON/HTTPS"
        workshop_mobile -> api "Consume endpoints de gestión para dueños y sincroniza órdenes MRO/telemetría vía" "JSON/HTTPS"
        driver_mobile -> api "Envía solicitudes de citas y consultas telemétricas vía" "JSON/HTTPS"
        api -> db "Lee y escribe datos relacionales y series de tiempo telemétricas vía" "JDBC/TCP"

        workshop_mobile -> firebase_storage "Sube fotos de evidencia de reparación directo a la nube vía" "HTTPS"
        webapp -> stripe "Tokeniza datos de tarjetas para suscripciones SaaS usando" "Stripe.js / HTTPS"
        api -> stripe "Procesa cobros de suscripción y valida webhooks idempotentes vía" "HTTPS/API"
        api -> nubefact "Delega la emisión de facturas y boletas electrónicas SUNAT vía" "HTTPS/API"
        api -> resend "Envía correos transaccionales de OTP, invitaciones y comprobantes vía" "HTTPS/API"
        api -> fcm "Envía notificaciones push predictivas a dispositivos móviles vía" "HTTPS/API"
        api -> google_maps "Normaliza direcciones y calcula geocercas de asistencia vía" "HTTPS/API"
        api -> google_identity "Valida certificados públicos y tokens de Google OAuth2 vía" "HTTPS/API"
        webapp -> google_identity "Autentica usuarios mediante Single Sign-On de Google vía" "Google Identity Services / HTTPS"
        workshop_mobile -> google_identity "Autentica mecánicos y personal mediante Google SSO vía" "Google Sign-In SDK / HTTPS"
        driver_mobile -> google_identity "Autentica conductores y propietarios mediante Google SSO vía" "Google Sign-In SDK / HTTPS"
        obd2_sim -> api "Envía telemetría de PIDs y DTCs por red celular vía" "HTTP POST / TCP"

        !include model/components/api-relationships.dsl
        !include model/components/webapp-relationships.dsl
        !include model/components/shared-relationships.dsl
        !include model/components/iam-relationships.dsl
        !include model/components/crm-relationships.dsl
        !include model/components/mro-relationships.dsl
        !include model/components/inventory-relationships.dsl
        !include model/components/hr-relationships.dsl
        !include model/components/invoicing-relationships.dsl
        !include model/components/billing-relationships.dsl

        !include model/deployment/production-environment.dsl
    }

    views {
        !include views/context-views.dsl
        !include views/container-views.dsl
        !include views/component-views.dsl
        !include views/deployment-views.dsl

        styles {
            element "Person" {
                shape Person
                background #08427b
                color #ffffff
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "External" {
                background #999999
                color #ffffff
            }
            element "WebBrowser" {
                shape WebBrowser
                background #438dd5
                color #ffffff
            }
            element "MobileDevicePortrait" {
                shape MobileDevicePortrait
                background #2a72b5
                color #ffffff
            }
            element "BackendApi" {
                shape RoundedBox
                background #1168bd
                color #ffffff
            }
            element "Database" {
                shape Cylinder
                background #1168bd
                color #ffffff
            }
        }
    }
}
