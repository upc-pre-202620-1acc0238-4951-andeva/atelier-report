component api "Components-API" "Diagrama de Componentes de la API Central de Atelier" {
    include *
    exclude shared_perimeter shared_assemblers shared_cqrs shared_domain shared_persistence shared_outbox shared_openapi
    exclude iam_perimeter iam_controllers iam_app_services iam_security_services iam_domain iam_persistence iam_facade iam_external_gateways
    exclude crm_controllers crm_app_services crm_event_handlers crm_domain crm_persistence crm_facade crm_external_gateways
    exclude mro_controllers mro_app_services mro_event_handlers mro_domain mro_persistence mro_facade mro_external_gateways
    exclude inventory_controllers inventory_app_services inventory_event_handlers inventory_domain inventory_persistence inventory_facade inventory_external_gateways
    exclude hr_controllers hr_app_services hr_event_handlers hr_domain hr_persistence hr_facade hr_external_gateways
    exclude invoicing_controllers invoicing_app_services invoicing_event_handlers invoicing_domain invoicing_persistence invoicing_facade invoicing_external_gateways
    exclude billing_controllers billing_app_services billing_event_handlers billing_domain billing_persistence billing_facade billing_external_gateways
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

component api "component-level-diagram-crm" "Diagrama de Componentes C4 (Nivel 3) para el Bounded Context Customer & Fleet Management (CRM) en API Application" {
    include crm_controllers crm_app_services crm_event_handlers crm_domain crm_persistence crm_facade crm_external_gateways
    include webapp workshop_mobile driver_mobile db google_maps fcm
    include iam_comp mro_comp invoicing_comp billing_comp iot_comp
    autoLayout tb 250 200
}

component api "component-level-diagram-mro" "Diagrama de Componentes C4 (Nivel 3) para el Bounded Context Workshop Operations (MRO) en API Application" {
    include mro_controllers mro_app_services mro_event_handlers mro_domain mro_persistence mro_facade mro_external_gateways
    include webapp workshop_mobile db firebase_storage
    include customer_fleet_comp iam_comp inventory_comp invoicing_comp iot_comp
    autoLayout tb 250 200
}

component api "component-level-diagram-inventory" "Diagrama de Componentes C4 (Nivel 3) para el Bounded Context Inventory & Supply Chain en API Application" {
    include inventory_controllers inventory_app_services inventory_event_handlers inventory_domain inventory_persistence inventory_facade inventory_external_gateways
    include webapp workshop_mobile db firebase_storage sunat
    include mro_comp invoicing_comp iam_comp
    autoLayout tb 250 200
}

component api "component-level-diagram-hr" "Diagrama de Componentes C4 (Nivel 3) para el Bounded Context Human Resources Management en API Application" {
    include hr_controllers hr_app_services hr_event_handlers hr_domain hr_persistence hr_facade hr_external_gateways
    include webapp workshop_mobile db resend google_maps
    include mro_comp iam_comp
    autoLayout tb 250 200
}

component api "component-level-diagram-invoicing" "Diagrama de Componentes C4 (Nivel 3) para el Bounded Context Invoicing & Compliance en API Application" {
    include invoicing_controllers invoicing_app_services invoicing_event_handlers invoicing_domain invoicing_persistence invoicing_facade invoicing_external_gateways
    include webapp workshop_mobile db nubefact resend sunat
    include mro_comp customer_fleet_comp inventory_comp hr_comp iam_comp
    autoLayout tb 250 200
}

component api "component-level-diagram-billing" "Diagrama de Componentes C4 (Nivel 3) para el Bounded Context SaaS Billing & Subscriptions en API Application" {
    include billing_controllers billing_app_services billing_event_handlers billing_domain billing_persistence billing_facade billing_external_gateways
    include webapp workshop_mobile db stripe resend
    include iam_comp mro_comp
    autoLayout tb 250 200
}




