deploymentEnvironment "Production" {
    deploymentNode "Dispositivo del Personal de Gestión" "Estación de trabajo o laptop en la oficina o recepción del taller." "Windows, macOS o Linux" {
        deploymentNode "Navegador Web" "Google Chrome, Mozilla Firefox o Microsoft Edge." "Web Browser" {
            containerInstance webapp
        }
    }

    deploymentNode "Dispositivo Móvil del Taller" "Tablet o smartphone de uso rudo en bahías mecánicas." "Android OS o iOS" {
        containerInstance workshop_mobile
    }

    deploymentNode "Dispositivo Móvil del Conductor" "Smartphone personal del propietario de vehículo o chofer de flota." "Android OS o iOS" {
        containerInstance driver_mobile
    }

    deploymentNode "Vehículo del Cliente" "Entorno automotriz y unidad de control electrónico ECU." "SAE J1962 OBD-II" {
        deploymentNode "Scanner OBD2 Bluetooth" "Dongle electrónico conectado al puerto OBD-II vehicular." "ELM327 BLE" {
            ble_dongle = infrastructureNode "Lector BLE" "Extrae parámetros de telemetría PIDs y códigos DTC." "Bluetooth 5.0"
        }
        deploymentNode "Dispositivo OBD2 Autónomo con SIM" "Módulo telemático independiente con módem celular." "Microcontrolador 4G LTE" {
            softwareSystemInstance obd2_sim
        }
    }

    deploymentNode "Vercel Cloud Platform" "Red global de distribución perimetral y alojamiento estático." "Vercel Edge CDN" {
        deploymentNode "Vercel Edge Network" "Servidores perimetrales con terminación TLS automática." "CDN Edge Server" {
            containerInstance landing
        }
    }

    deploymentNode "Render Cloud Platform" "Plataforma PaaS para ejecución de servicios contenerizados." "Linux Ubuntu Container" {
        deploymentNode "API Web Service" "Instancia en la nube ejecutando el backend monolítico modular." "Docker, Eclipse Temurin OpenJDK 24" {
            containerInstance api
        }
    }

    deploymentNode "Aiven Cloud Platform" "Servicio administrado de base de datos de alta disponibilidad en la nube." "Aiven Managed DBaaS" {
        deploymentNode "Database Cluster" "Nodo primario de base de datos relacional y de series de tiempo." "PostgreSQL 16, TimescaleDB" {
            containerInstance db
        }
    }

    deploymentNode "Google Cloud Platform" "Infraestructura de almacenamiento de objetos y mensajería en la nube." "GCP" {
        firebase_storage_node = infrastructureNode "Firebase Cloud Storage" "Bucket seguro para fotos y evidencias de peritaje vehicular." "Google Cloud Storage Bucket"
        firebase_fcm_node = infrastructureNode "Firebase Cloud Messaging" "Servicio en la nube para el enrutamiento de notificaciones push." "Google Cloud Pub/Sub"
    }

    deploymentNode "Infraestructura Externa SaaS" "Servicios de terceros consumidos mediante APIs seguras." "Cloud SaaS" {
        softwareSystemInstance stripe
        softwareSystemInstance nubefact
        softwareSystemInstance resend
        softwareSystemInstance google_maps
        softwareSystemInstance google_identity
    }

    // Interacciones de hardware y servicios cloud específicos de despliegue
    workshop_mobile -> ble_dongle "Lee parámetros de telemetría PIDs y códigos DTC vía" "Bluetooth BLE"
    driver_mobile -> ble_dongle "Lee telemetría y diagnósticos en tiempo real vía" "Bluetooth BLE"
    workshop_mobile -> firebase_storage_node "Sube imágenes y evidencias de peritaje vehicular vía" "HTTPS REST"
    api -> firebase_fcm_node "Envía notificaciones push predictivas vía" "HTTPS REST"
}
