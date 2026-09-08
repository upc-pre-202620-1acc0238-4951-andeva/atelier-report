component api "Components-API" "Diagrama de Componentes de la API Central de Atelier" {
    include *
    exclude shared_perimeter shared_assemblers shared_cqrs shared_domain shared_persistence shared_outbox shared_openapi
    exclude iam_perimeter iam_controllers iam_app_services iam_security_services iam_domain iam_persistence iam_facade iam_external_gateways
    autoLayout tb 250 200
}

component webapp "Components-WebApp" "Diagrama de Componentes de la Aplicación Web de Atelier" {
    include *
    autoLayout tb 250 200
}

component api "component-level-diagram-shared" "Diagrama de Componentes C4 (Nivel 3) para el Bounded Context Shared en API Application" {
    include shared_perimeter shared_assemblers shared_cqrs shared_domain shared_persistence shared_outbox shared_openapi
    include webapp workshop_mobile driver_mobile db
    include iam_comp mro_comp inventory_comp invoicing_comp customer_fleet_comp
    autoLayout tb 250 200
}

component api "component-level-diagram-iam" "Diagrama de Componentes C4 (Nivel 3) para el Bounded Context IAM & Tenancy en API Application" {
    include iam_perimeter iam_controllers iam_app_services iam_security_services iam_domain iam_persistence iam_facade iam_external_gateways
    include webapp workshop_mobile driver_mobile db resend google_identity
    include mro_comp customer_fleet_comp hr_comp invoicing_comp billing_comp
    autoLayout tb 250 200
}
