-- ==============================================================================
-- ATELIER PLATFORM — DDL Y SEED DATA DEL SISTEMA DE FACTURACIÓN Y SUSCRIPCIONES
-- Bounded Context: SaaS Billing & Subscriptions (com.andeva.atelier.platform.billing)
-- Motor de Base de Datos: PostgreSQL 15+ (Compatible con TimescaleDB y Docker)
-- Archivo: docs/schema-billing-atelier.sql
-- ==============================================================================
-- Propósito: Esquema de base de datos listo para copiar y pegar en psql, DBeaver,
-- pgAdmin o pipelines de migración (Flyway / Liquibase). Define el catálogo de planes
-- comerciales (Go, Pro, Max, Enterprise), características modulares paquetizadas,
-- contratos de suscripción multi-inquilino, comprobantes contables y cerrojos de
-- idempotencia de Stripe Webhooks, incluyendo el seed data oficial de lanzamiento.
-- ==============================================================================

-- 1. HABILITACIÓN DE EXTENSIONES CRIPTOGRÁFICAS
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==============================================================================
-- 2. TABLA: plans (Catálogo Maestro de Planes Comerciales y Cuotas Operativas)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS plans (
    id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stripe_price_id             VARCHAR(100) NOT NULL UNIQUE,
    name                        VARCHAR(100) NOT NULL,
    tier                        VARCHAR(20)  NOT NULL,
    price                       DECIMAL(10,2) NOT NULL,
    currency                    VARCHAR(3)   NOT NULL DEFAULT 'PEN',
    billing_cycle               VARCHAR(20)  NOT NULL,
    max_branches                INTEGER      NOT NULL,
    max_active_staff            INTEGER      NOT NULL,
    max_active_obd2_devices     INTEGER      NOT NULL DEFAULT 0,
    max_photos_per_work_order   INTEGER      NOT NULL DEFAULT 10,
    max_monthly_ai_reports      INTEGER      NOT NULL DEFAULT 0,
    company_registration_allowed BOOLEAN     NOT NULL DEFAULT false,
    multi_warehouse_allowed     BOOLEAN      NOT NULL DEFAULT false,
    marketplace_listed          BOOLEAN      NOT NULL DEFAULT false,
    max_monthly_work_orders     INTEGER      NOT NULL,
    iot_telemetry_enabled       BOOLEAN      NOT NULL DEFAULT false,
    ai_diagnostics_enabled      BOOLEAN      NOT NULL DEFAULT false,
    is_active                   BOOLEAN      NOT NULL DEFAULT true,
    created_at                  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    version                     BIGINT       NOT NULL DEFAULT 0,
    deleted_at                  TIMESTAMPTZ  DEFAULT NULL,

    -- Restricciones de Dominio (Invariantes de Negocio)
    CONSTRAINT chk_plans_tier CHECK (tier IN ('GO', 'PRO', 'MAX', 'ENTERPRISE')),
    CONSTRAINT chk_plans_cycle CHECK (billing_cycle IN ('MONTHLY', 'YEARLY')),
    CONSTRAINT chk_plans_currency CHECK (currency IN ('PEN', 'USD')),
    CONSTRAINT chk_plans_price CHECK (price >= 0.00),
    CONSTRAINT chk_plans_max_branches CHECK (max_branches > 0 OR max_branches = -1),
    CONSTRAINT chk_plans_max_staff CHECK (max_active_staff > 0 OR max_active_staff = -1),
    CONSTRAINT chk_plans_max_orders CHECK (max_monthly_work_orders > 0 OR max_monthly_work_orders = -1)
);

-- Índices B-Tree para el catálogo de planes
CREATE INDEX IF NOT EXISTS idx_plans_tier ON plans(tier);
CREATE INDEX IF NOT EXISTS idx_plans_tier_active ON plans(tier, is_active);
CREATE INDEX IF NOT EXISTS idx_plans_stripe_price ON plans(stripe_price_id);

COMMENT ON TABLE plans IS 'Catálogo comercial de planes de suscripción SaaS ofertados a los talleres mecánicos.';
COMMENT ON COLUMN plans.tier IS 'Nivel comercial: GO, PRO, MAX, ENTERPRISE';
COMMENT ON COLUMN plans.max_active_obd2_devices IS 'Límite de escáneres OBD-II activos en vehículos de clientes (0 en Go, 5 en Pro, 15 en Max, -1 Enterprise).';
COMMENT ON COLUMN plans.max_photos_per_work_order IS 'Tope de fotos por orden en work_order_images y tareas (10 en Go, -1 ilimitado en Pro/Max/Enterprise).';
COMMENT ON COLUMN plans.max_monthly_ai_reports IS 'Cupo mensual de Reportes PDF de Salud Vehicular asistidos por IA (0 en Go/Pro, 60 en Max, -1 Enterprise).';
COMMENT ON COLUMN plans.company_registration_allowed IS 'Habilitación para registrar empresas y flotas CustomerType.COMPANY (false en Go/Pro, true en Max/Enterprise).';
COMMENT ON COLUMN plans.multi_warehouse_allowed IS 'Habilitación para gestión multi-almacén FIFO inter-sede (false en Go/Pro, true en Max/Enterprise).';
COMMENT ON COLUMN plans.marketplace_listed IS 'Presencia y verificación en el marketplace B2B Atelier Bussiness (false en Go/Pro, true en Max/Enterprise).';

-- ==============================================================================
-- 3. TABLA: plan_features (Desglose de Capacidades Modulares por Plan)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS plan_features (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_id         UUID NOT NULL,
    feature_key     VARCHAR(50) NOT NULL,
    description     VARCHAR(255) NOT NULL,
    is_enabled      BOOLEAN NOT NULL DEFAULT true,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_plan_features_plan FOREIGN KEY (plan_id) REFERENCES plans(id) ON DELETE CASCADE,
    CONSTRAINT uk_plan_features_plan_key UNIQUE (plan_id, feature_key),
    CONSTRAINT chk_feature_key_not_empty CHECK (LENGTH(TRIM(feature_key)) > 0)
);

CREATE INDEX IF NOT EXISTS idx_plan_features_plan ON plan_features(plan_id);
CREATE INDEX IF NOT EXISTS idx_plan_features_lookup ON plan_features(plan_id, feature_key, is_enabled);

COMMENT ON TABLE plan_features IS 'Desglose granular de funcionalidades y banderas técnicas habilitadas por plan.';

-- ==============================================================================
-- 4. TABLA: subscriptions (Contratos de Suscripción Multi-Inquilino)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS subscriptions (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               UUID NOT NULL UNIQUE,
    plan_id                 UUID NOT NULL,
    stripe_customer_id      VARCHAR(100) NOT NULL,
    stripe_sub_id           VARCHAR(100) NOT NULL,
    status                  VARCHAR(20)  NOT NULL DEFAULT 'trialing',
    current_period_start    TIMESTAMPTZ  NOT NULL,
    current_period_end      TIMESTAMPTZ  NOT NULL,
    cancel_at_period_end    BOOLEAN      NOT NULL DEFAULT false,
    canceled_at             TIMESTAMPTZ  DEFAULT NULL,
    trial_end_date          TIMESTAMPTZ  DEFAULT NULL,
    created_at              TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    version                 BIGINT       NOT NULL DEFAULT 0,
    deleted_at              TIMESTAMPTZ  DEFAULT NULL,

    CONSTRAINT fk_subscriptions_plan FOREIGN KEY (plan_id) REFERENCES plans(id),
    CONSTRAINT chk_subscriptions_status CHECK (status IN ('trialing', 'active', 'past_due', 'canceled', 'unpaid', 'incomplete')),
    CONSTRAINT chk_subscriptions_period CHECK (current_period_end >= current_period_start)
);

CREATE INDEX IF NOT EXISTS idx_subscriptions_tenant ON subscriptions(tenant_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_subscriptions_stripe_sub ON subscriptions(stripe_sub_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_plan ON subscriptions(plan_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_period_end ON subscriptions(current_period_end);

COMMENT ON TABLE subscriptions IS 'Contratos de suscripción recurrente que vinculan a un taller con su plan comercial.';

-- ==============================================================================
-- 5. TABLA: saas_invoices (Recaudación B2B y Comprobantes Contables de Plataforma)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS saas_invoices (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id         UUID NOT NULL,
    tenant_id               UUID NOT NULL,
    stripe_invoice_id       VARCHAR(100) NOT NULL UNIQUE,
    amount_paid             DECIMAL(10,2) NOT NULL,
    currency                VARCHAR(3)   NOT NULL DEFAULT 'PEN',
    status                  VARCHAR(20)  NOT NULL,
    invoice_pdf_url         VARCHAR(255) DEFAULT NULL,
    hosted_invoice_url      VARCHAR(255) DEFAULT NULL,
    paid_at                 TIMESTAMPTZ  DEFAULT NULL,
    created_at              TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    version                 BIGINT       NOT NULL DEFAULT 0,
    deleted_at              TIMESTAMPTZ  DEFAULT NULL,

    CONSTRAINT fk_saas_invoices_subscription FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE CASCADE,
    CONSTRAINT chk_saas_invoices_status CHECK (status IN ('draft', 'open', 'paid', 'uncollectible', 'void')),
    CONSTRAINT chk_saas_invoices_amount CHECK (amount_paid >= 0.00),
    CONSTRAINT chk_saas_invoices_currency CHECK (currency IN ('PEN', 'USD'))
);

CREATE INDEX IF NOT EXISTS idx_saas_invoices_subscription ON saas_invoices(subscription_id);
CREATE INDEX IF NOT EXISTS idx_saas_invoices_tenant_paid ON saas_invoices(tenant_id, paid_at);
CREATE INDEX IF NOT EXISTS idx_saas_invoices_status ON saas_invoices(status);
CREATE INDEX IF NOT EXISTS idx_saas_invoices_stripe ON saas_invoices(stripe_invoice_id);

COMMENT ON TABLE saas_invoices IS 'Recibos contables oficiales emitidos por Andeva por el servicio SaaS.';

-- ==============================================================================
-- 6. TABLA: stripe_webhook_events (Deduplicación e Idempotencia de Webhooks)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS stripe_webhook_events (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stripe_event_id         VARCHAR(100) NOT NULL UNIQUE,
    type                    VARCHAR(100) NOT NULL,
    payload                 TEXT         NOT NULL,
    status                  VARCHAR(20)  NOT NULL DEFAULT 'pending',
    processed_at            TIMESTAMPTZ  DEFAULT NULL,
    error_message           VARCHAR(500) DEFAULT NULL,
    created_at              TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_stripe_events_status CHECK (status IN ('pending', 'processed', 'failed', 'ignored'))
);

CREATE INDEX IF NOT EXISTS idx_stripe_events_status ON stripe_webhook_events(status, processed_at);
CREATE INDEX IF NOT EXISTS idx_stripe_events_type ON stripe_webhook_events(type);

COMMENT ON TABLE stripe_webhook_events IS 'Cerrojo de concurrencia e idempotencia para eventos asíncronos de Stripe.';

-- ==============================================================================
-- 7. SEED DATA OFICIAL: CATÁLOGO DE PLANES COMERCIALES (v7.0)
-- ==============================================================================

-- Limpieza preventiva de datos previos de seed si existen
DELETE FROM plan_features;
DELETE FROM plans;

-- INSERCIÓN DE LOS 4 PLANES (FRECUENCIA MENSUAL Y ANUAL)
INSERT INTO plans (
    id, stripe_price_id, name, tier, price, currency, billing_cycle,
    max_branches, max_active_staff, max_active_obd2_devices,
    max_photos_per_work_order, max_monthly_ai_reports,
    company_registration_allowed, multi_warehouse_allowed, marketplace_listed,
    max_monthly_work_orders, iot_telemetry_enabled, ai_diagnostics_enabled,
    is_active
) VALUES
-- -----------------------------------------------------------------------------
-- PLAN GO (Taller Inicial)
-- -----------------------------------------------------------------------------
(
    'a0000001-0000-0000-0000-000000000001',
    'price_go_monthly',
    'Go',
    'GO',
    139.00,
    'PEN',
    'MONTHLY',
    1,   -- 1 sede física principal
    5,   -- 5 colaboradores activos simultáneos
    0,   -- 0 dispositivos OBD-II (telemetría deshabilitada)
    10,  -- Hasta 10 fotos por orden de trabajo
    0,   -- 0 reportes de IA
    false, -- Solo clientes particulares INDIVIDUAL (empresas bloqueadas)
    false, -- 1 almacén local autónomo (sin transferencias multi-sede)
    false, -- No listado en Atelier Bussiness
    50,  -- Hasta 50 órdenes de trabajo mensuales
    false, -- Sin telemetría
    false, -- Sin IA predictiva
    true
),
(
    'a0000001-0000-0000-0000-000000000002',
    'price_go_yearly',
    'Go',
    'GO',
    1308.00, -- Equivalente a S/ 109.00 / mes (Ahorro de S/ 360 / año)
    'PEN',
    'YEARLY',
    1,
    5,
    0,
    10,
    0,
    false,
    false,
    false,
    50,
    false,
    false,
    true
),

-- -----------------------------------------------------------------------------
-- PLAN PRO (Taller Avanzado — Recomendado ⭐)
-- -----------------------------------------------------------------------------
(
    'b0000002-0000-0000-0000-000000000001',
    'price_pro_monthly',
    'Pro',
    'PRO',
    269.00,
    'PEN',
    'MONTHLY',
    1,   -- 1 sede física
    10,  -- 10 colaboradores activos simultáneos
    5,   -- Hasta 5 dispositivos OBD-II activos en clientes VIP
    -1,  -- Fotos ilimitadas en órdenes y tareas
    0,   -- Sin reportes periciales PDF de IA (monitoreo solo en pantalla)
    false, -- Solo clientes particulares INDIVIDUAL
    false, -- 1 almacén local autónomo
    false, -- No listado en Atelier Bussiness
    180, -- Hasta 180 órdenes de trabajo mensuales
    true,  -- Telemetría en tiempo real y lectura de DTCs activa
    false, -- Sin motor de reportes predictivos PDF
    true
),
(
    'b0000002-0000-0000-0000-000000000002',
    'price_pro_yearly',
    'Pro',
    'PRO',
    2628.00, -- Equivalente a S/ 219.00 / mes (Ahorro de S/ 600 / año)
    'PEN',
    'YEARLY',
    1,
    10,
    5,
    -1,
    0,
    false,
    false,
    false,
    180,
    true,
    false,
    true
),

-- -----------------------------------------------------------------------------
-- PLAN MAX (Redes de Talleres, ERP Automotriz & Captación B2B)
-- -----------------------------------------------------------------------------
(
    'c0000003-0000-0000-0000-000000000001',
    'price_max_monthly',
    'Max',
    'MAX',
    489.00,
    'PEN',
    'MONTHLY',
    3,   -- Hasta 3 sedes físicas incluidas
    25,  -- Hasta 25 colaboradores activos distribuidos
    15,  -- Hasta 15 dispositivos OBD-II activos en flotas
    -1,  -- Fotos ilimitadas
    60,  -- Hasta 60 Reportes PDF de Salud Vehicular con IA al mes
    true,  -- Habilitado para registrar clientes COMPANY y flotas corporativas
    true,  -- Suite ERP Automotriz con transferencias multi-almacén FIFO
    true,  -- Taller verificado y listado en Atelier Bussiness
    -1,  -- Órdenes de trabajo mensuales ilimitadas
    true,  -- Telemetría OBD-II en tiempo real activa
    true,  -- Diagnóstico predictivo con IA (Spring AI) activo
    true
),
(
    'c0000003-0000-0000-0000-000000000002',
    'price_max_yearly',
    'Max',
    'MAX',
    4788.00, -- Equivalente a S/ 399.00 / mes (Ahorro de S/ 1,080 / año)
    'PEN',
    'YEARLY',
    3,
    25,
    15,
    -1,
    60,
    true,
    true,
    true,
    -1,
    true,
    true,
    true
),

-- -----------------------------------------------------------------------------
-- PLAN ENTERPRISE (Grandes Cadenas, Concesionarios & Flotas Masivas)
-- -----------------------------------------------------------------------------
(
    'd0000004-0000-0000-0000-000000000001',
    'price_enterprise_custom',
    'Enterprise',
    'ENTERPRISE',
    0.00, -- Tarificación elástica personalizada por consumo ("Contactar Ventas")
    'PEN',
    'MONTHLY',
    -1,  -- Sedes físicas ilimitadas o a medida
    -1,  -- Colaboradores ilimitados
    -1,  -- Dispositivos OBD-II elásticos por volumen
    -1,  -- Fotos ilimitadas
    -1,  -- Reportes de IA ilimitados a medida
    true,  -- Registro de flotas y empresas corporativas
    true,  -- ERP multi-sede y conector externo (SAP, Oracle, Odoo)
    true,  -- Posicionamiento VIP destacado en Atelier Bussiness
    -1,  -- Órdenes ilimitadas
    true,  -- Telemetría elástica
    true,  -- IA elástica administrada por API
    true
);

-- ==============================================================================
-- 8. SEED DATA DE CARACTERÍSTICAS MODULARES (plan_features)
-- ==============================================================================

-- Inserción de capacidades para Plan Go (id: a0000001-...)
INSERT INTO plan_features (plan_id, feature_key, description, is_enabled)
SELECT p.id, f.key, f.desc, f.enabled
FROM plans p
CROSS JOIN (VALUES
    ('MRO_CORE', 'Gestión completa de órdenes de trabajo y tareas en fosa', true),
    ('MOBILE_APP_OFFLINE', 'Aplicación móvil Android Offline-First con base de datos SQLite', true),
    ('FIFO_INVENTORY', 'Valorización contable FIFO estricta por lote de compra (1 almacén)', true),
    ('SUNAT_E_INVOICING', 'Facturación electrónica SUNAT UBL 2.1 (hasta 100 comprobantes/mes)', true),
    ('HR_ATTENDANCE_HAVERSINE', 'Control de asistencia con geocerca satelital Haversine (5 usuarios)', true),
    ('INDIVIDUAL_CUSTOMERS', 'Registro y gestión clínica de clientes particulares', true),
    ('OBD2_TELEMETRY', 'Telemetría vehicular OBD-II en tiempo real', false),
    ('AI_HEALTH_REPORTS', 'Generación de reportes periciales en PDF con Inteligencia Artificial', false),
    ('COMPANY_FLEET_MANAGEMENT', 'Registro de empresas y administración de flotas corporativas', false),
    ('ATELIER_BUSSINESS_MARKETPLACE', 'Presencia y captación en el directorio B2B Atelier Bussiness', false),
    ('MULTI_WAREHOUSE_TRANSFERS', 'Transferencias de repuestos inter-sede y multi-almacén', false)
) AS f(key, desc, enabled)
WHERE p.tier = 'GO';

-- Inserción de capacidades para Plan Pro (id: b0000002-...)
INSERT INTO plan_features (plan_id, feature_key, description, is_enabled)
SELECT p.id, f.key, f.desc, f.enabled
FROM plans p
CROSS JOIN (VALUES
    ('MRO_CORE', 'Gestión completa de órdenes de trabajo y tareas en fosa', true),
    ('MOBILE_APP_OFFLINE', 'Aplicación móvil Android Offline-First con base de datos SQLite', true),
    ('FIFO_INVENTORY', 'Valorización contable FIFO estricta por lote de compra (1 almacén)', true),
    ('SUNAT_E_INVOICING', 'Facturación electrónica SUNAT UBL 2.1 ilimitada sin tope', true),
    ('HR_ATTENDANCE_HAVERSINE', 'Control de asistencia con geocerca satelital Haversine (10 usuarios)', true),
    ('INDIVIDUAL_CUSTOMERS', 'Registro y gestión clínica de clientes particulares', true),
    ('UNLIMITED_EVIDENCE_PHOTOS', 'Peritaje fotográfico ilimitado en órdenes y tareas de fosa', true),
    ('BAY_SCHEDULING_BOARD', 'Tablero visual interactivo de disponibilidad y reserva de bahías', true),
    ('OBD2_TELEMETRY', 'Telemetría vehicular OBD-II en tiempo real (5 escáneres activos VIP)', true),
    ('AI_HEALTH_REPORTS', 'Generación de reportes periciales en PDF con Inteligencia Artificial', false),
    ('COMPANY_FLEET_MANAGEMENT', 'Registro de empresas y administración de flotas corporativas', false),
    ('ATELIER_BUSSINESS_MARKETPLACE', 'Presencia y captación en el directorio B2B Atelier Bussiness', false),
    ('MULTI_WAREHOUSE_TRANSFERS', 'Transferencias de repuestos inter-sede y multi-almacén', false)
) AS f(key, desc, enabled)
WHERE p.tier = 'PRO';

-- Inserción de capacidades para Plan Max (id: c0000003-...)
INSERT INTO plan_features (plan_id, feature_key, description, is_enabled)
SELECT p.id, f.key, f.desc, f.enabled
FROM plans p
CROSS JOIN (VALUES
    ('MRO_CORE', 'Gestión completa de órdenes de trabajo y tareas en fosa', true),
    ('MOBILE_APP_OFFLINE', 'Aplicación móvil Android Offline-First con base de datos SQLite', true),
    ('FIFO_INVENTORY', 'Valorización contable FIFO estricta por lote de compra', true),
    ('SUNAT_E_INVOICING', 'Facturación electrónica SUNAT UBL 2.1 ilimitada', true),
    ('HR_ATTENDANCE_HAVERSINE', 'Control de asistencia con geocerca satelital Haversine (25 usuarios)', true),
    ('UNLIMITED_EVIDENCE_PHOTOS', 'Peritaje fotográfico ilimitado en órdenes y tareas de fosa', true),
    ('BAY_SCHEDULING_BOARD', 'Tablero visual interactivo de disponibilidad de bahías en múltiples sedes', true),
    ('OBD2_TELEMETRY', 'Telemetría vehicular OBD-II de flotas (15 escáneres activos en tiempo real)', true),
    ('AI_HEALTH_REPORTS', 'Generación de reportes periciales PDF con Spring AI (hasta 60 reportes/mes)', true),
    ('COMPANY_FLEET_MANAGEMENT', 'Registro legal de empresas (CustomerType.COMPANY) y flotas corporativas', true),
    ('ATELIER_BUSSINESS_MARKETPLACE', 'Taller verificado y listado en el marketplace B2B Atelier Bussiness', true),
    ('MULTI_WAREHOUSE_TRANSFERS', 'Suite ERP Automotriz: multi-almacén FIFO inter-sede y traspasos', true),
    ('WHITE_LABEL_REPORTS', 'Reportes PDF y presupuestos con membrete y logotipo propio del taller', true)
) AS f(key, desc, enabled)
WHERE p.tier = 'MAX';

-- Inserción de capacidades para Plan Enterprise (id: d0000004-...)
INSERT INTO plan_features (plan_id, feature_key, description, is_enabled)
SELECT p.id, f.key, f.desc, f.enabled
FROM plans p
CROSS JOIN (VALUES
    ('MRO_CORE', 'Gestión completa de órdenes de trabajo y tareas en fosa', true),
    ('MOBILE_APP_OFFLINE', 'Aplicación móvil Android Offline-First con base de datos SQLite', true),
    ('FIFO_INVENTORY', 'Valorización contable FIFO estricta por lote de compra', true),
    ('SUNAT_E_INVOICING', 'Facturación electrónica SUNAT UBL 2.1 ilimitada', true),
    ('HR_ATTENDANCE_HAVERSINE', 'Control de asistencia con geocerca satelital Haversine ilimitado', true),
    ('UNLIMITED_EVIDENCE_PHOTOS', 'Peritaje fotográfico ilimitado con retención extendida', true),
    ('BAY_SCHEDULING_BOARD', 'Tablero visual interactivo multisede consolidado', true),
    ('OBD2_TELEMETRY', 'Telemetría vehicular OBD-II elástica con partición dedicada en TimescaleDB', true),
    ('AI_HEALTH_REPORTS', 'Reportes periciales PDF con IA ilimitados a medida', true),
    ('COMPANY_FLEET_MANAGEMENT', 'Gestión integral de empresas, contratos corporativos y flotas masivas', true),
    ('ATELIER_BUSSINESS_MARKETPLACE', 'Posicionamiento VIP prioritario en Atelier Bussiness', true),
    ('MULTI_WAREHOUSE_TRANSFERS', 'Suite ERP Automotriz multi-sede consolidada', true),
    ('ERP_CONNECTOR_EXTERNAL', 'Conector e integración bidireccional hacia ERP externo (SAP, Oracle, Odoo)', true),
    ('DEDICATED_SLA_SUPPORT', 'Gerente de cuenta dedicado y SLA garantizado inferior a 1 hora (24/7)', true)
) AS f(key, desc, enabled)
WHERE p.tier = 'ENTERPRISE';

-- ==============================================================================
-- 9. VISTAS DE DIAGNÓSTICO Y CONSULTA RÁPIDA
-- ==============================================================================

-- Vista consolidada del catálogo comercial activo
CREATE OR REPLACE VIEW v_active_plans_summary AS
SELECT
    tier,
    name,
    billing_cycle,
    currency,
    price,
    max_branches AS sedes,
    max_active_staff AS usuarios,
    max_monthly_work_orders AS max_ot_mes,
    CASE WHEN max_photos_per_work_order = -1 THEN 'Ilimitadas' ELSE max_photos_per_work_order::TEXT END AS fotos_ot,
    max_active_obd2_devices AS obd2_activos,
    max_monthly_ai_reports AS reportes_ia_mes,
    company_registration_allowed AS flotas_b2b,
    marketplace_listed AS en_marketplace_b2b,
    multi_warehouse_allowed AS multi_almacen_fifo,
    stripe_price_id
FROM plans
WHERE is_active = true
ORDER BY
    CASE tier
        WHEN 'GO' THEN 1
        WHEN 'PRO' THEN 2
        WHEN 'MAX' THEN 3
        WHEN 'ENTERPRISE' THEN 4
    END,
    billing_cycle ASC;

-- ==============================================================================
-- 10. COMPROBACIÓN INMEDIATA DEL ESQUEMA
-- ==============================================================================
SELECT 'Catálogo comercial de planes cargado exitosamente:' AS status;
SELECT * FROM v_active_plans_summary;
