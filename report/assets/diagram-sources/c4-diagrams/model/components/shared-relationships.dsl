// Relaciones del Bounded Context Shared

// Clientes externos hacia componentes perimetrales
webapp -> shared_perimeter "Envía peticiones HTTP REST de gestión con Bearer JWT vía" "HTTPS/JSON"
workshop_mobile -> shared_perimeter "Envía peticiones REST de gestión en patio y sincroniza órdenes MRO vía" "HTTPS/JSON"
driver_mobile -> shared_perimeter "Envía solicitudes telemétricas y de citas vía" "HTTPS/JSON"
webapp -> shared_openapi "Consulta contratos OpenAPI y esquemas vía" "HTTPS/JSON"

// Propagación de trazabilidad y seguridad hacia módulos de negocio
shared_perimeter -> iam_comp "Propaga Correlation-ID y contexto de seguridad a" "FilterChain"
shared_perimeter -> mro_comp "Propaga Correlation-ID y contexto de seguridad a" "FilterChain"
shared_perimeter -> inventory_comp "Propaga Correlation-ID y contexto de seguridad a" "FilterChain"

// Delegación a ensambladores REST
mro_comp -> shared_assemblers "Convierte Result a ResponseEntity usando" "In-Memory Call"
inventory_comp -> shared_assemblers "Convierte Result a ResponseEntity usando" "In-Memory Call"
invoicing_comp -> shared_assemblers "Convierte Result a ResponseEntity usando" "In-Memory Call"

// Implementación de contratos CQRS
iam_comp -> shared_cqrs "Implementa contratos CommandHandler y QueryHandler de" "Java Interface"
mro_comp -> shared_cqrs "Implementa contratos CommandHandler y QueryHandler de" "Java Interface"
inventory_comp -> shared_cqrs "Implementa contratos CommandHandler y QueryHandler de" "Java Interface"

// Herencia de Aggregate Root y uso de Value Objects
iam_comp -> shared_domain "Hereda de AbstractDomainAggregateRoot y usa Value Objects de" "Java Inheritance"
mro_comp -> shared_domain "Hereda de AbstractDomainAggregateRoot y usa Value Objects de" "Java Inheritance"
customer_fleet_comp -> shared_domain "Hereda de AbstractDomainAggregateRoot y usa Value Objects de" "Java Inheritance"

// Herencia de superclase de persistencia y convertidores JPA
mro_comp -> shared_persistence "Extiende AuditableAbstractPersistenceEntity y usa convertidores de" "JPA Inheritance"
inventory_comp -> shared_persistence "Extiende AuditableAbstractPersistenceEntity y usa convertidores de" "JPA Inheritance"
invoicing_comp -> shared_persistence "Extiende AuditableAbstractPersistenceEntity y usa convertidores de" "JPA Inheritance"

// Despacho transaccional de eventos de dominio hacia Outbox
mro_comp -> shared_outbox "Despacha eventos de dominio usando" "DomainEventPublisher Port"
invoicing_comp -> shared_outbox "Despacha eventos de dominio usando" "DomainEventPublisher Port"

// Persistencia física en base de datos
shared_outbox -> db "Inserta registros en outbox_messages vía" "JDBC/JSONB"
shared_persistence -> db "Aplica mapeos relacionales y estrategia física de tablas vía" "JDBC/TCP"
