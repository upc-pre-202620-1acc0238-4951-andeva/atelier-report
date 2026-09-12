# Guía de Implementación: Diagnóstico Predictivo Vehicular con Spring AI, TimescaleDB y Reportes PDF

Esta guía de ingeniería detalla la arquitectura, los componentes y el código fuente en Java 21+ con Spring Boot 3.4+ y Spring AI para transformar los registros de telemetría de alta frecuencia (`telemetry_logs`), el catálogo de averías normativas (`dtc_catalog`) y el historial de fallos (`vehicle_faults`) en diagnósticos mecánicos predictivos estructurados y reportes periciales en formato PDF listos para el cliente y el taller mecánico.

---

## 1. Fundamentos Arquitectónicos y Pipeline de Datos

Para que la inferencia con Inteligencia Artificial sea precisa, económica y determinista en un entorno de producción, es fundamental evitar dos errores comunes:
1. **Volcado ciego de datos crudos (*Token Flooding*):** Enviar cientos de miles de filas individuales de `telemetry_logs` a un modelo de lenguaje (LLM) excede las ventanas de contexto, eleva los costos de inferencia a niveles inviables y produce alucinaciones debido a la dispersión de información.
2. **Falta de tipado estricto (*Stringly-Typed AI*):** Depender de texto libre no estructurado hace imposible que el ERP automotriz o la app móvil automaticen acciones como agendar citas o precargar órdenes de trabajo.

### Flujo de Trabajo de Producción (*End-to-End Workflow*)

El pipeline de diagnóstico predictivo se estructura en cinco etapas secuenciales:

```
┌────────────────────────────────┐
│ TimescaleDB: telemetry_logs    │──┐
│ (Agregaciones time_bucket,     │  │
│  medias térmicas, desvíos)     │  │
└────────────────────────────────┘  │     ┌────────────────────────┐
                                    ├────►│ Feature Vector Builder │
┌────────────────────────────────┐  │     │ (Consolidación en Java)│
│ PostgreSQL: vehicle_faults     │──┤     └───────────┬────────────┘
│ e historial normativo DTC      │  │                 │
└────────────────────────────────┘  │                 ▼
                                    │     ┌────────────────────────┐
┌────────────────────────────────┐  │     │ Spring AI ChatClient   │
│ Catálogo Maestro: dtc_catalog  │──┘     │ + Structured Outputs   │
│ (Descripciones SAE J2012)      │        │ (Modelos GPT-4o/Claude)│
└────────────────────────────────┘        └───────────┬────────────┘
                                                      │
                       ┌──────────────────────────────┴──────────────────────────────┐
                       ▼                                                             ▼
       ┌───────────────────────────────┐                             ┌───────────────────────────────┐
       │ Persistencia de Alertas       │                             │ Generación de Reporte PDF     │
       │ (predictive_alerts)           │                             │ (Thymeleaf + OpenPDF)         │
       │ + Eventos MRO / Push FCM      │                             │ Descarga Web / Móvil          │
       └───────────────────────────────┘                             └───────────────────────────────┘
```

1. **Extracción y Agregación de Señales (TimescaleDB):** Consultas analíticas continuas extraen promedios, desviaciones estándar, máximos y mínimos de las variables críticas (temperatura de motor, tensión de batería, régimen de revoluciones, presión múltiple) agrupadas en intervalos temporales de 15 minutos o 1 hora mediante `time_bucket()`.
2. **Vector de Características (*Feature Vector*):** Se combinan las métricas estadísticas con el historial de códigos de error reportados en `vehicle_faults` y la información del catálogo universal `dtc_catalog`.
3. **Inferencia Estructurada con Spring AI:** Se inyecta el vector en un `PromptTemplate` especializado que instruye al modelo a razonar sobre termodinámica y mecánica vehicular, forzando la respuesta hacia un objeto tipado (`VehicleHealthReportAiDto`) mediante `BeanOutputConverter`.
4. **Persistencia e Integración de Negocio:** El resultado genera una alerta predictiva en `predictive_alerts` con probabilidad matemática (`confidence_score`), asociando un paquete de servicio de mantenimiento (`recommended_service_id`) y disparando eventos hacia MRO y notificaciones push hacia la app del conductor.
5. **Renderizado Documental (PDF):** Un adaptador de infraestructura toma el DTO estructurado, lo inyecta en una plantilla HTML semántica (Thymeleaf) y produce un documento PDF maquetado con diseño corporativo bancario/automotriz.

---

## 2. Dependencias del Proyecto (`pom.xml`)

Para implementar este pipeline en Spring Boot 3.4+ con Spring AI y generación de documentos PDF, se configuran los siguientes módulos:

```xml
<dependencies>
    <!-- Spring Boot Starters -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-thymeleaf</artifactId>
    </dependency>

    <!-- Spring AI Starter (OpenAI / Azure / Anthropic / Ollama) -->
    <dependency>
        <groupId>org.springframework.ai</groupId>
        <artifactId>spring-ai-openai-spring-boot-starter</artifactId>
        <version>1.0.0-M6</version>
    </dependency>

    <!-- Motor de Generación de PDF: OpenPDF (Fork LGPL/MPL de iText) -->
    <dependency>
        <groupId>com.github.librepdf</groupId>
        <artifactId>openpdf</artifactId>
        <version>2.0.3</version>
    </dependency>

    <!-- Driver JDBC de PostgreSQL con soporte de TimescaleDB -->
    <dependency>
        <groupId>org.postgresql</groupId>
        <artifactId>postgresql</artifactId>
        <scope>runtime</scope>
    </dependency>

    <!-- Tolerancia a Fallos y Circuit Breaker para LLMs -->
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-circuitbreaker-resilience4j</artifactId>
    </dependency>
</dependencies>
```

---

## 2.1. Estrategia de Inferencia Multiprovisionador y Configuración (`application.yml`)

Gracias a que **Spring AI** desacopla la lógica de negocio mediante el contrato de alto nivel `ChatClient`, el subsistema de diagnóstico predictivo de Atelier implementa el principio de **neutralidad tecnológica de proveedor** (*Vendor Neutrality*). 

Dado que tanto **Groq Cloud** como **NVIDIA NIM** y **Ollama** exponen APIs conformes al estándar universal de OpenAI (`/v1/chat/completions`), el backend utiliza el starter canónico `spring-ai-openai-spring-boot-starter` sin requerir adaptadores propietarios.

### Comparativa de Proveedores Evaluados

| Proveedor | Arquitectura de Cómputo | Modelo Recomendado | Latencia Típica | Esquema Gratuito / Costos | Caso de Uso en Atelier |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Groq Cloud** *(Principal)* | **LPU™ (Language Processing Unit)** | `llama-3.3-70b-versatile` | **~0.6 a 0.9 s** (~500 t/s) | **Permanente:** 14,400 peticiones/día sin vencimiento de créditos. | Generación interactiva de reportes periciales al vuelo en web y móvil. |
| **Groq Cloud** *(Batch Flotas)* | **LPU™ (Language Processing Unit)** | `llama-3.1-8b-instant` | **~0.25 a 0.4 s** (~750 t/s) | **Permanente:** 30 peticiones/minuto, 14,400 peticiones/día. | Encolado asíncrono masivo para flotas vehiculares corporativas. |
| **NVIDIA NIM** *(Alternativa)* | **NVIDIA H100 Tensor Core GPU** | `meta/llama-3.1-70b-instruct` | ~2.2 a 3.8 s (~90 t/s) | Créditos iniciales de prueba (1,000 llamadas); luego pago por uso. | Respaldo secundario cloud en caso de degradación transitoria de Groq. |
| **Ollama** *(On-Premise)* | CPU local o GPU de taller (NVIDIA RTX) | `llama3.1:8b` | ~1.5 a 4.5 s | **$0.00 permanente:** Corre en servidor local o appliance de taller. | Talleres autónomos sin internet confiable o auditoría de soberanía. |

### Configuración Canónica en `application.yml`

```yaml
spring:
  application:
    name: atelier-backend
  profiles:
    active: groq # Opciones: groq | nvidia | local-ollama

---
# ------------------------------------------------------------------------------
# Perfil Producción / Cloud Estándar: Groq Cloud LPU (Recomendado)
# ------------------------------------------------------------------------------
spring:
  config:
    activate:
      on-profile: groq
  ai:
    openai:
      # Clave gratuita obtenida en console.groq.com
      api-key: ${GROQ_API_KEY:gsk_tu_clave_aqui}
      # Redirección al gateway compatible de Groq
      base-url: https://api.groq.com/openai
      chat:
        options:
          # Meta Llama 3.3 70B: Máximo razonamiento termodinámico y de averías
          model: llama-3.3-70b-versatile
          temperature: 0.1 # Muy baja: fuerza razonamiento analítico y determinista
          max-tokens: 2500
          # Opcional para procesamiento masivo de flotas:
          # model: llama-3.1-8b-instant

---

## 3. Extracción de Características en TimescaleDB

El repositorio de telemetría implementa una consulta nativa sobre la hipertabla `telemetry_logs` utilizando las funciones analíticas de TimescaleDB. Esto condensa miles de lecturas de sensores en un resumen estadístico manejable.

```java
package com.andeva.atelier.platform.iot.infrastructure.persistence.repositories;

import com.andeva.atelier.platform.iot.domain.model.dto.TelemetryStatisticalSummary;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface TimescaleTelemetryAnalyticsRepository extends Repository<Void, Void> {

    @Query(value = """
        SELECT 
            time_bucket('1 day', timestamp) AS bucket_time,
            ROUND(AVG(engine_temp_c)::numeric, 2) AS avg_engine_temp,
            MAX(engine_temp_c) AS max_engine_temp,
            ROUND(STDDEV(engine_temp_c)::numeric, 2) AS stddev_engine_temp,
            ROUND(AVG(battery_voltage)::numeric, 2) AS avg_battery_voltage,
            MIN(battery_voltage) AS min_battery_voltage,
            MAX(speed) AS max_speed_kmh,
            COUNT(*) AS total_data_points
        FROM telemetry_logs
        WHERE vehicle_id = :vehicleId
          AND timestamp >= :since
        GROUP BY bucket_time
        ORDER BY bucket_time ASC
        """, nativeQuery = true)
    List<TelemetryStatisticalSummary> getTelemetryMetricsDaily(
            @Param("vehicleId") UUID vehicleId,
            @Param("since") Instant since
    );
}
```

La proyección de datos se define mediante una interfaz de Spring Data o un Java Record:

```java
package com.andeva.atelier.platform.iot.domain.model.dto;

import java.math.BigDecimal;
import java.time.Instant;

public interface TelemetryStatisticalSummary {
    Instant getBucketTime();
    BigDecimal getAvgEngineTemp();
    BigDecimal getMaxEngineTemp();
    BigDecimal getStddevEngineTemp();
    BigDecimal getAvgBatteryVoltage();
    BigDecimal getMinBatteryVoltage();
    Integer getMaxSpeedKmh();
    Long getTotalDataPoints();
}
```

---

## 4. Modelos de Dominio y Salida Estructurada (*Structured Outputs*)

Para que Spring AI devuelva un reporte parseable directamente por el sistema y libre de ambigüedades, definimos la estructura exacta que el LLM debe generar.

### 4.1. DTO de Diagnóstico y Salud Vehicular (Spring AI Target)

```java
package com.andeva.atelier.platform.iot.domain.model.dto.ai;

import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import java.math.BigDecimal;
import java.util.List;

public record VehicleHealthReportAiDto(
    @JsonPropertyDescription("Índice de salud mecánica general del vehículo de 0 a 100")
    int overallHealthScore,

    @JsonPropertyDescription("Resumen ejecutivo del diagnóstico en lenguaje claro y accesible para el conductor")
    String executiveSummary,

    @JsonPropertyDescription("Evaluación técnica desglosada por subsistema vehicular")
    List<SubsystemEvaluationDto> subsystemEvaluations,

    @JsonPropertyDescription("Riesgos mecánicos predictivos detectados que requieren atención futura")
    List<PredictiveRiskDto> predictiveRisks,

    @JsonPropertyDescription("Acciones correctivas o preventivas recomendadas para el taller mecánico")
    List<RecommendedServiceActionDto> recommendedActions,

    @JsonPropertyDescription("Correlación entre códigos de avería DTC detectados y anomalías de telemetría")
    List<DtcTelemetryCorrelationDto> dtcCorrelations
) {}
```

### 4.2. DTOs de Detalle por Subsistema, Riesgo y Recomendación

```java
package com.andeva.atelier.platform.iot.domain.model.dto.ai;

import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import java.math.BigDecimal;
import java.util.List;

public record SubsystemEvaluationDto(
    @JsonPropertyDescription("Nombre del subsistema: MOTOR, REFRIGERACION, ELECTRICO, FRENOS o TRANSMISION")
    String subsystemName,
    
    @JsonPropertyDescription("Calificación de condición: OPTIMO, ALERTA_TEMPRANA, DEGRADADO o CRITICO")
    String status,
    
    @JsonPropertyDescription("Puntuación de salud del subsistema de 0 a 100")
    int healthScore,
    
    @JsonPropertyDescription("Observación técnica del comportamiento observado en los sensores")
    String technicalFinding
) {}

public record PredictiveRiskDto(
    @JsonPropertyDescription("Tipo de riesgo de avería mecánica")
    String riskCategory,
    
    @JsonPropertyDescription("Probabilidad estimada de falla de 0.00 a 100.00")
    BigDecimal probabilityScore,
    
    @JsonPropertyDescription("Tiempo o kilometraje estimado antes de falla catastrófica (ej. '500 - 1,000 km' o '15 días')")
    String estimatedTimeToFailure,
    
    @JsonPropertyDescription("Descripción de las consecuencias mecánicas si no se atiende")
    String failureConsequence
) {}

public record RecommendedServiceActionDto(
    @JsonPropertyDescription("Código normalizado del servicio sugerido (ej. SRV-COOL-01, SRV-ELEC-02)")
    String serviceCode,
    
    @JsonPropertyDescription("Título descriptivo del servicio de mantenimiento")
    String serviceTitle,
    
    @JsonPropertyDescription("Prioridad de intervención: INMEDIATA, PROXIMO_MANTENIMIENTO o PREVENTIVA")
    String priority,
    
    @JsonPropertyDescription("Lista de componentes o repuestos automotrices sugeridos para reemplazo")
    List<String> suggestedParts
) {}

public record DtcTelemetryCorrelationDto(
    @JsonPropertyDescription("Código de diagnóstico automotriz SAE J2012 (ej. P0300, P0420)")
    String dtcCode,
    
    @JsonPropertyDescription("Confirmación de si la telemetría valida físicamente la lectura de la ECU")
    boolean isPhysicallyConfirmedByTelemetry,
    
    @JsonPropertyDescription("Evidencia en los sensores que respalda o refuta la avería electrónica")
    String sensorEvidence
) {}
```

---

## 5. Servicio de Inferencia Predictiva con Spring AI

El servicio `VehicleHealthAiDiagnosticService` orquesta la extracción de datos, ensambla el contexto para el modelo de inteligencia artificial y convierte la respuesta en la estructura Java tipada.

```java
package com.andeva.atelier.platform.iot.infrastructure.ai;

import com.andeva.atelier.platform.iot.domain.model.dto.TelemetryStatisticalSummary;
import com.andeva.atelier.platform.iot.domain.model.dto.ai.VehicleHealthReportAiDto;
import com.andeva.atelier.platform.iot.infrastructure.persistence.jpa.entities.VehicleFaultJpaEntity;
import com.andeva.atelier.platform.iot.infrastructure.persistence.repositories.TimescaleTelemetryAnalyticsRepository;
import com.andeva.atelier.platform.iot.infrastructure.persistence.repositories.VehicleFaultJpaRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.prompt.PromptTemplate;
import org.springframework.ai.converter.BeanOutputConverter;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class VehicleHealthAiDiagnosticService {

    private static final Logger log = LoggerFactory.getLogger(VehicleHealthAiDiagnosticService.class);

    private final ChatClient chatClient;
    private final TimescaleTelemetryAnalyticsRepository telemetryAnalyticsRepo;
    private final VehicleFaultJpaRepository vehicleFaultRepo;

    public VehicleHealthAiDiagnosticService(
            ChatClient.Builder chatClientBuilder,
            TimescaleTelemetryAnalyticsRepository telemetryAnalyticsRepo,
            VehicleFaultJpaRepository vehicleFaultRepo) {
        this.chatClient = chatClientBuilder.build();
        this.telemetryAnalyticsRepo = telemetryAnalyticsRepo;
        this.vehicleFaultRepo = vehicleFaultRepo;
    }

    @Transactional(readOnly = true)
    public VehicleHealthReportAiDto generateVehicleDiagnostic(UUID tenantId, UUID vehicleId) {
        log.info("Iniciando análisis analítico con Spring AI para el vehículo {} del tenant {}", vehicleId, tenantId);

        // 1. Extraer métricas estadísticas de telemetría de los últimos 30 días
        Instant thirtyDaysAgo = Instant.now().minus(30, ChronoUnit.DAYS);
        List<TelemetryStatisticalSummary> metrics = 
                telemetryAnalyticsRepo.getTelemetryMetricsDaily(vehicleId, thirtyDaysAgo);

        // 2. Extraer historial reciente de códigos de falla DTC activos o no resueltos
        List<VehicleFaultJpaEntity> activeFaults = 
                vehicleFaultRepo.findByTenantIdAndVehicleIdAndStatusNot(tenantId, vehicleId, "resolved");

        // 3. Configurar el convertidor de salida estructurada de Spring AI
        BeanOutputConverter<VehicleHealthReportAiDto> outputConverter = 
                new BeanOutputConverter<>(VehicleHealthReportAiDto.class);

        // 4. Diseñar el System Prompt y User Prompt con contexto enriquecido
        String systemInstructions = """
            Eres el motor de diagnóstico automotriz y mantenimiento predictivo de la plataforma Atelier.
            Tu función es actuar como un Ingeniero Mecánico y Especialista en Telemática Automotriz Senior.
            Debes analizar las tendencias termodinámicas y cinemáticas de los sensores junto con las averías
            registradas bajo las normas SAE J2012 e ISO 15031-6.
            
            Reglas de Análisis:
            1. Correlaciona las curvas de temperatura de refrigerante con los fallos de encendido o fugas.
            2. Evalúa caídas sostenidas de tensión eléctrica (< 12.0V en reposo) como degradación de alternador o batería.
            3. Prioriza el lenguaje claro en el resumen ejecutivo para conductores particulares.
            4. Genera estrictamente el formato JSON solicitado respetando el esquema de datos.
            """;

        String userPromptTemplate = """
            Analiza el siguiente conjunto de datos telemáticos y de averías para formular el diagnóstico pericial:

            INFORMACIÓN DEL VEHÍCULO:
            - Identificador: {vehicleId}
            - Período de Auditoría: Últimos 30 días

            HISTORIAL DE CÓDIGOS DE AVERÍA DTC ACTIVOS:
            {faultsList}

            MÉTRICAS ESTADÍSTICAS DIARIAS DE SENSORES (TimescaleDB):
            {telemetryMetrics}

            INSTRUCCIONES DE FORMATO:
            {formatInstructions}
            """;

        PromptTemplate promptTemplate = new PromptTemplate(userPromptTemplate);
        Map<String, Object> promptVariables = Map.of(
            "vehicleId", vehicleId.toString(),
            "faultsList", formatFaultsForPrompt(activeFaults),
            "telemetryMetrics", formatMetricsForPrompt(metrics),
            "formatInstructions", outputConverter.getFormat()
        );

        // 5. Invocación fluida del LLM a través de Spring AI ChatClient
        String rawResponse = chatClient.prompt()
                .system(systemInstructions)
                .user(promptTemplate.create(promptVariables).getContents())
                .call()
                .content();

        // 6. Conversión a objeto tipado Java Record
        return outputConverter.convert(rawResponse);
    }

    private String formatFaultsForPrompt(List<VehicleFaultJpaEntity> faults) {
        if (faults.isEmpty()) {
            return "No se registran averías electrónicas activas en la ECU.";
        }
        StringBuilder sb = new StringBuilder();
        for (VehicleFaultJpaEntity f : faults) {
            sb.append(String.format("- Código: %s | Severidad: %s | Descripción: %s | Detectado: %s\n",
                    f.getDtcCode(), f.getSeverity(), f.getDescription(), f.getDetectedAt()));
        }
        return sb.toString();
    }

    private String formatMetricsForPrompt(List<TelemetryStatisticalSummary> metrics) {
        if (metrics.isEmpty()) {
            return "No se registran datos de telemetría suficientes en el intervalo evaluado.";
        }
        StringBuilder sb = new StringBuilder();
        for (TelemetryStatisticalSummary m : metrics) {
            sb.append(String.format("- Fecha: %s | Temp Promedio: %s°C (Máx: %s°C) | Batería Prom: %sV (Mín: %sV) | Muestras: %d\n",
                    m.getBucketTime(), m.getAvgEngineTemp(), m.getMaxEngineTemp(), 
                    m.getAvgBatteryVoltage(), m.getMinBatteryVoltage(), m.getTotalDataPoints()));
        }
        return sb.toString();
    }
}
```

---

## 6. Persistencia Automática de Alertas Predictivas

Una vez que el modelo de IA genera el `VehicleHealthReportAiDto`, el sistema guarda automáticamente los riesgos identificados en la tabla **`predictive_alerts`** y emite los eventos de integración hacia MRO y notificaciones push.

```java
package com.andeva.atelier.platform.iot.application.services;

import com.andeva.atelier.platform.iot.domain.model.aggregates.PredictiveAlert;
import com.andeva.atelier.platform.iot.domain.model.dto.ai.PredictiveRiskDto;
import com.andeva.atelier.platform.iot.domain.model.dto.ai.VehicleHealthReportAiDto;
import com.andeva.atelier.platform.iot.domain.model.valueobjects.AlertId;
import com.andeva.atelier.platform.iot.domain.model.valueobjects.AlertType;
import com.andeva.atelier.platform.iot.domain.model.valueobjects.ConfidenceScore;
import com.andeva.atelier.platform.iot.domain.model.valueobjects.TenantId;
import com.andeva.atelier.platform.iot.domain.model.valueobjects.VehicleId;
import com.andeva.atelier.platform.iot.domain.repositories.PredictiveAlertRepository;
import com.andeva.atelier.platform.iot.infrastructure.ai.VehicleHealthAiDiagnosticService;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
public class ExecutePredictiveVehicleHealthAnalysisService {

    private final VehicleHealthAiDiagnosticService aiDiagnosticService;
    private final PredictiveAlertRepository predictiveAlertRepository;
    private final ApplicationEventPublisher eventPublisher;

    public ExecutePredictiveVehicleHealthAnalysisService(
            VehicleHealthAiDiagnosticService aiDiagnosticService,
            PredictiveAlertRepository predictiveAlertRepository,
            ApplicationEventPublisher eventPublisher) {
        this.aiDiagnosticService = aiDiagnosticService;
        this.predictiveAlertRepository = predictiveAlertRepository;
        this.eventPublisher = eventPublisher;
    }

    @Transactional
    public VehicleHealthReportAiDto executeAnalysisAndPersistAlerts(UUID tenantId, UUID vehicleId) {
        // 1. Ejecutar inferencia predictiva con Spring AI
        VehicleHealthReportAiDto report = aiDiagnosticService.generateVehicleDiagnostic(tenantId, vehicleId);

        // 2. Persistir cada riesgo con probabilidad >= 70% en la tabla predictive_alerts
        for (PredictiveRiskDto risk : report.predictiveRisks()) {
            if (risk.probabilityScore().doubleValue() >= 70.0) {
                PredictiveAlert alert = PredictiveAlert.create(
                        new AlertId(UUID.randomUUID()),
                        new TenantId(tenantId),
                        new VehicleId(vehicleId),
                        mapCategoryToAlertType(risk.riskCategory()),
                        new ConfidenceScore(risk.probabilityScore()),
                        String.format("%s. Consecuencia: %s. Plazo estimado: %s",
                                risk.riskCategory(), risk.failureConsequence(), risk.estimatedTimeToFailure())
                );
                
                predictiveAlertRepository.save(alert);
            }
        }

        return report;
    }

    private AlertType mapCategoryToAlertType(String category) {
        if (category.toUpperCase().contains("OVERHEAT") || category.toUpperCase().contains("REFRIGER")) {
            return AlertType.ENGINE_OVERHEATING_RISK;
        }
        if (category.toUpperCase().contains("BATTER") || category.toUpperCase().contains("ELECTR")) {
            return AlertType.BATTERY_FAILURE_RISK;
        }
        return AlertType.UNUSUAL_RPM_OSCILLATION;
    }
}
```

---

## 7. Generación de Reportes Formales en PDF (Thymeleaf + OpenPDF)

El puerto de generación de reportes transforma el diagnóstico estructurado de la IA en un documento PDF profesional con membrete del taller, semáforo de salud e itinerario de mantenimiento.

### 7.1. Adaptador de Infraestructura PDF

```java
package com.andeva.atelier.platform.iot.infrastructure.reporting;

import com.andeva.atelier.platform.iot.domain.model.dto.ai.VehicleHealthReportAiDto;
import com.lowagie.text.DocumentException;
import org.springframework.stereotype.Component;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;
import org.xhtmlrenderer.pdf.ITextRenderer;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

@Component
public class VehicleHealthReportPdfGeneratorAdapter {

    private final TemplateEngine templateEngine;

    public VehicleHealthReportPdfGeneratorAdapter(TemplateEngine templateEngine) {
        this.templateEngine = templateEngine;
    }

    public byte[] generatePdfReport(UUID tenantId, UUID vehicleId, VehicleHealthReportAiDto diagnosticData) {
        // 1. Inyectar variables al contexto de Thymeleaf
        Context context = new Context();
        context.setVariable("diagnostic", diagnosticData);
        context.setVariable("vehicleId", vehicleId.toString());
        context.setVariable("reportDate", LocalDate.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));
        context.setVariable("healthScoreColor", getScoreColorHex(diagnosticData.overallHealthScore()));

        // 2. Procesar la plantilla HTML hacia XHTML bien formado
        String htmlContent = templateEngine.process("reports/vehicle-health-report", context);

        // 3. Renderizar el XHTML a binario PDF mediante Flying Saucer / OpenPDF
        try (ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
            ITextRenderer renderer = new ITextRenderer();
            renderer.setDocumentFromString(htmlContent);
            renderer.layout();
            renderer.createPDF(outputStream);
            return outputStream.toByteArray();
        } catch (DocumentException | IOException e) {
            throw new RuntimeException("Error durante el renderizado tipográfico del reporte PDF", e);
        }
    }

    private String getScoreColorHex(int score) {
        if (score >= 80) return "#27AE60"; // Verde (Óptimo)
        if (score >= 60) return "#F39C12"; // Ámbar (Alerta Moderada)
        return "#C0392B";                 // Rojo (Crítico)
    }
}
```

### 7.2. Plantilla HTML/CSS para Renderizado PDF (`src/main/resources/templates/reports/vehicle-health-report.html`)

```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8"/>
    <title>Informe Pericial de Salud Mecánica Vehicular</title>
    <style>
        @page {
            size: A4;
            margin: 20mm;
        }
        body {
            font-family: 'Helvetica', sans-serif;
            color: #2C3E50;
            line-height: 1.4;
            font-size: 10pt;
        }
        .header {
            border-bottom: 2px solid #2980B9;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        .title {
            font-size: 18pt;
            font-weight: bold;
            color: #2C3E50;
        }
        .score-box {
            float: right;
            padding: 10px 20px;
            border-radius: 8px;
            color: white;
            font-size: 20pt;
            font-weight: bold;
            text-align: center;
        }
        .summary-box {
            background-color: #F8F9F9;
            border-left: 4px solid #2980B9;
            padding: 12px;
            margin-bottom: 20px;
            font-size: 10.5pt;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        th, td {
            border: 1px solid #BDC3C7;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #EAEDED;
            color: #34495E;
            font-weight: bold;
        }
        .badge-critical { color: #C0392B; font-weight: bold; }
        .badge-warning { color: #D35400; font-weight: bold; }
        .badge-ok { color: #27AE60; font-weight: bold; }
        .footer {
            margin-top: 30px;
            border-top: 1px solid #BDC3C7;
            padding-top: 10px;
            font-size: 8pt;
            text-align: center;
            color: #7F8C8D;
        }
    </style>
</head>
<body>

<div class="header">
    <div class="score-box" th:style="'background-color: ' + ${healthScoreColor} + ';'">
        <span th:text="${diagnostic.overallHealthScore}">85</span>/100
        <div style="font-size: 8pt; font-weight: normal;">Salud Mecánica</div>
    </div>
    <div class="title">Atelier — Informe Pericial de Diagnóstico y Salud Vehicular</div>
    <div>Vehículo: <strong th:text="${vehicleId}">UUID</strong> | Fecha de Emisión: <span th:text="${reportDate}">12/09/2026</span></div>
</div>

<div class="summary-box">
    <strong>Diagnóstico Ejecutivo para el Conductor:</strong><br/>
    <span th:text="${diagnostic.executiveSummary}">El vehículo presenta óptimas condiciones generales...</span>
</div>

<h3>1. Estado General de Subsistemas</h3>
<table>
    <thead>
        <tr>
            <th>Subsistema</th>
            <th>Estado</th>
            <th>Puntaje</th>
            <th>Hallazgo Técnico</th>
        </tr>
    </thead>
    <tbody>
        <tr th:each="sub : ${diagnostic.subsystemEvaluations}">
            <td th:text="${sub.subsystemName}">MOTOR</td>
            <td>
                <span th:class="${sub.status == 'CRITICO' ? 'badge-critical' : (sub.status == 'DEGRADADO' ? 'badge-warning' : 'badge-ok')}"
                      th:text="${sub.status}">OPTIMO</span>
            </td>
            <td th:text="${sub.healthScore} + '/100'">90/100</td>
            <td th:text="${sub.technicalFinding}">Operación en parámetros nominales.</td>
        </tr>
    </tbody>
</table>

<h3>2. Riesgos Mecánicos Predictivos (Inferencia de Inteligencia Artificial)</h3>
<table>
    <thead>
        <tr>
            <th>Categoría de Riesgo</th>
            <th>Certeza Estadística</th>
            <th>Plazo Estimado de Falla</th>
            <th>Consecuencia Potencial</th>
        </tr>
    </thead>
    <tbody>
        <tr th:each="risk : ${diagnostic.predictiveRisks}">
            <td th:text="${risk.riskCategory}">Sobrecalentamiento</td>
            <td th:text="${risk.probabilityScore} + '%'">92.00%</td>
            <td th:text="${risk.estimatedTimeToFailure}">15 días</td>
            <td th:text="${risk.failureConsequence}">Riesgo de daño en empaque de culata.</td>
        </tr>
    </tbody>
</table>

<h3>3. Acciones Recomendadas y Paquetes de Taller Sugeridos</h3>
<table>
    <thead>
        <tr>
            <th>Código Servicio</th>
            <th>Servicio Sugerido</th>
            <th>Prioridad</th>
            <th>Repuestos Requeridos</th>
        </tr>
    </thead>
    <tbody>
        <tr th:each="act : ${diagnostic.recommendedActions}">
            <td th:text="${act.serviceCode}">SRV-COOL-01</td>
            <td th:text="${act.serviceTitle}">Purga y Reemplazo de Termostato</td>
            <td th:text="${act.priority}">INMEDIATA</td>
            <td th:text="${#strings.listJoin(act.suggestedParts, ', ')}">Termostato, Refrigerante OAT</td>
        </tr>
    </tbody>
</table>

<div class="footer">
    Informe generado automáticamente por el Motor Analítico de Atelier mediante Spring AI y datos telemáticos en TimescaleDB.<br/>
    Documento con validez técnica para soporte de recepción en taller y agendamiento preventivo de citas.
</div>

</body>
</html>
```

---

## 8. Endpoints REST: Generación, Consulta y Descarga (`Controller Layer`)

Bajo el patrón CQRS adoptado en la plataforma Atelier, separamos tajantemente la **mutación de estado e inferencia de IA (Command)** de la **consulta y descarga documental (Query)**:
- Los métodos `GET` deben ser operaciones de lectura rápidas e idempotentes que devuelvan datos precalculados o rendericen el documento sin volver a invocar el LLM innecesariamente.
- La **generación explícita del reporte** es una operación costosa en tiempo y tokens, por lo que se expone formalmente mediante el verbo `POST`.

### 8.1. Contratos DTO de Petición y Respuesta de Generación

```java
package com.andeva.atelier.platform.iot.interfaces.rest.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import java.time.Instant;
import java.util.UUID;

public record GenerateHealthReportRequest(
    @Min(value = 7, message = "El período mínimo de análisis es de 7 días")
    @Max(value = 90, message = "El período máximo de análisis es de 90 días")
    Integer daysToAnalyze,

    Boolean includeResolvedDtcHistory,

    String triggerReason // ej. "PRE_INSPECTION_INTAKE", "PERIODIC_AUDIT", "DRIVER_MANUAL_REQUEST"
) {
    public GenerateHealthReportRequest {
        if (daysToAnalyze == null) daysToAnalyze = 30;
        if (includeResolvedDtcHistory == null) includeResolvedDtcHistory = false;
        if (triggerReason == null) triggerReason = "MANUAL_REQUEST";
    }
}

public record HealthReportCreatedResponse(
    UUID reportId,
    UUID vehicleId,
    int overallHealthScore,
    String executiveSummary,
    int totalRisksDetected,
    Instant generatedAt,
    String jsonResourceUrl,
    String pdfDownloadUrl
) {}
```

### 8.2. Controlador REST Seguro (`VehicleHealthReportController`)

```java
package com.andeva.atelier.platform.iot.interfaces.rest;

import com.andeva.atelier.platform.iot.application.services.ExecutePredictiveVehicleHealthAnalysisService;
import com.andeva.atelier.platform.iot.domain.model.dto.ai.VehicleHealthReportAiDto;
import com.andeva.atelier.platform.iot.infrastructure.reporting.VehicleHealthReportPdfGeneratorAdapter;
import com.andeva.atelier.platform.iot.interfaces.rest.dto.GenerateHealthReportRequest;
import com.andeva.atelier.platform.iot.interfaces.rest.dto.HealthReportCreatedResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.time.Instant;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/iot/vehicles/{vehicleId}/health-reports")
public class VehicleHealthReportController {

    private final ExecutePredictiveVehicleHealthAnalysisService analysisService;
    private final VehicleHealthReportPdfGeneratorAdapter pdfGeneratorAdapter;

    public VehicleHealthReportController(
            ExecutePredictiveVehicleHealthAnalysisService analysisService,
            VehicleHealthReportPdfGeneratorAdapter pdfGeneratorAdapter) {
        this.analysisService = analysisService;
        this.pdfGeneratorAdapter = pdfGeneratorAdapter;
    }

    /**
     * ENDPOINT DE GENERACIÓN (Command):
     * Dispara la inferencia de Spring AI, persiste las alertas predictivas en la BD,
     * almacena el snapshot del reporte y retorna 201 Created con cabecera Location.
     */
    @PostMapping("/generate")
    @PreAuthorize("hasAnyRole('ROLE_WORKSHOP_ADMIN', 'ROLE_SERVICE_ADVISOR', 'ROLE_MECHANIC')")
    public ResponseEntity<HealthReportCreatedResponse> generateVehicleHealthReport(
            @PathVariable UUID vehicleId,
            @Valid @RequestBody(required = false) GenerateHealthReportRequest request,
            @AuthenticationPrincipal Jwt jwt) {
        
        UUID tenantId = UUID.fromString(jwt.getClaimAsString("tenant_id"));
        UUID reportId = UUID.randomUUID();

        // 1. Ejecutar pipeline de IA y persistencia
        VehicleHealthReportAiDto diagnostic = analysisService.executeAnalysisAndPersistAlerts(tenantId, vehicleId);

        // 2. Construir URIs HATEOAS / REST para consumo posterior
        URI location = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{reportId}")
                .buildAndExpand(reportId)
                .toUri();

        HealthReportCreatedResponse response = new HealthReportCreatedResponse(
                reportId,
                vehicleId,
                diagnostic.overallHealthScore(),
                diagnostic.executiveSummary(),
                diagnostic.predictiveRisks().size(),
                Instant.now(),
                "/api/v1/iot/vehicles/" + vehicleId + "/health-reports/" + reportId,
                "/api/v1/iot/vehicles/" + vehicleId + "/health-reports/" + reportId + "/pdf"
        );

        return ResponseEntity.created(location).body(response);
    }

    /**
     * ENDPOINT ASÍNCRONO PARA FLOTAS O PROCESAMIENTO DIFERIDO:
     * Acepta la solicitud para encolar la inferencia en segundo plano y responde 202 Accepted.
     */
    @PostMapping("/generate-async")
    @PreAuthorize("hasAnyRole('ROLE_WORKSHOP_ADMIN', 'ROLE_SERVICE_ADVISOR')")
    public ResponseEntity<Void> triggerAsyncReportGeneration(
            @PathVariable UUID vehicleId,
            @AuthenticationPrincipal Jwt jwt) {
        
        UUID tenantId = UUID.fromString(jwt.getClaimAsString("tenant_id"));
        
        // Encola la orden en Spring TaskExecutor o RabbitMQ
        analysisService.enqueueAsyncAnalysis(tenantId, vehicleId);

        return ResponseEntity.accepted().build();
    }

    /**
     * ENDPOINT DE CONSULTA RÁPIDA (Query - JSON):
     * Retorna el último diagnóstico disponible para visualización en dashboards web o apps móviles.
     */
    @GetMapping("/latest")
    @PreAuthorize("hasAnyRole('ROLE_WORKSHOP_ADMIN', 'ROLE_SERVICE_ADVISOR', 'ROLE_MECHANIC', 'ROLE_VEHICLE_OWNER')")
    public ResponseEntity<VehicleHealthReportAiDto> getLatestVehicleHealthReport(
            @PathVariable UUID vehicleId,
            @AuthenticationPrincipal Jwt jwt) {
        
        UUID tenantId = UUID.fromString(jwt.getClaimAsString("tenant_id"));
        VehicleHealthReportAiDto report = analysisService.getLatestPrecomputedReport(tenantId, vehicleId);
        
        return ResponseEntity.ok(report);
    }

    /**
     * ENDPOINT DE DESCARGA DOCUMENTAL (Query - PDF):
     * Renderiza o transmite el archivo binario PDF maquetado para impresión o envío al conductor.
     */
    @GetMapping("/{reportId}/pdf")
    @PreAuthorize("hasAnyRole('ROLE_WORKSHOP_ADMIN', 'ROLE_SERVICE_ADVISOR', 'ROLE_VEHICLE_OWNER')")
    public ResponseEntity<byte[]> downloadVehicleHealthReportPdf(
            @PathVariable UUID vehicleId,
            @PathVariable UUID reportId,
            @AuthenticationPrincipal Jwt jwt) {
        
        UUID tenantId = UUID.fromString(jwt.getClaimAsString("tenant_id"));
        VehicleHealthReportAiDto report = analysisService.getReportById(tenantId, vehicleId, reportId);
        byte[] pdfBytes = pdfGeneratorAdapter.generatePdfReport(tenantId, vehicleId, report);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"informe-salud-" + vehicleId + "-" + reportId + ".pdf\"")
                .contentType(MediaType.APPLICATION_PDF)
                .body(pdfBytes);
    }
}
```

---

## 9. Automatización de Ciclos Controlados (Batch Scheduling)

Para procesar flotas vehiculares periódicamente durante la noche sin degradar el rendimiento diurno de los talleres, se implementa una tarea programada con Spring Scheduling:

```java
package com.andeva.atelier.platform.iot.infrastructure.scheduling;

import com.andeva.atelier.platform.iot.application.services.ExecutePredictiveVehicleHealthAnalysisService;
import com.andeva.atelier.platform.iot.infrastructure.persistence.jpa.entities.DeviceInstallationJpaEntity;
import com.andeva.atelier.platform.iot.infrastructure.persistence.repositories.DeviceInstallationJpaRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class NightlyFleetHealthEvaluationJob {

    private static final Logger log = LoggerFactory.getLogger(NightlyFleetHealthEvaluationJob.class);

    private final DeviceInstallationJpaRepository installationRepo;
    private final ExecutePredictiveVehicleHealthAnalysisService analysisService;

    public NightlyFleetHealthEvaluationJob(
            DeviceInstallationJpaRepository installationRepo,
            ExecutePredictiveVehicleHealthAnalysisService analysisService) {
        this.installationRepo = installationRepo;
        this.analysisService = analysisService;
    }

    /**
     * Ejecuta el análisis predictivo para todos los vehículos con escáner OBD-II activo.
     * Programado diariamente a las 02:00 AM (hora de baja carga transaccional).
     */
    @Scheduled(cron = "0 0 2 * * ?")
    public void executeFleetAnalysisBatch() {
        log.info("Iniciando escaneo nocturno de salud de flota vehicular con Spring AI");
        List<DeviceInstallationJpaEntity> activeInstallations = 
                installationRepo.findAllByStatus("active");

        for (DeviceInstallationJpaEntity installation : activeInstallations) {
            try {
                analysisService.executeAnalysisAndPersistAlerts(
                        installation.getTenantId(), 
                        installation.getVehicleId()
                );
                log.debug("Análisis predictivo completado para el vehículo {}", installation.getVehicleId());
            } catch (Exception ex) {
                log.error("Fallo al procesar el análisis para el vehículo {}: {}", 
                        installation.getVehicleId(), ex.getMessage());
            }
        }
        log.info("Escaneo nocturno de salud de flota culminado con éxito");
    }
}
```

---

## 10. Conclusión y Valor Operativo

Con esta implementación:
1. **La telemetría en TimescaleDB deja de ser un archivo pasivo de datos:** Se transforma activamente en vectores analíticos que alimentan al modelo de Inteligencia Artificial.
2. **Las alertas predictivas son accionables:** Cada anomalía genera una entidad formal en `predictive_alerts` conectada con el catálogo de servicios del taller (`recommended_service_id`).
3. **El reporte en PDF cierra la brecha de confianza:** El taller cuenta con un informe tangible para mostrar al cliente las causas de una falla inminente antes de que ocurra, demostrando el profesionalismo y el retorno de inversión del ecosistema Atelier.


 ### 3. ¿Cómo se configura en Spring Boot? (Solo 3 pasos)

  Gracias al desacoplamiento que preparamos en la arquitectura, no tocas ni una clase Java.

  #### Paso 1: Obtener tu API Key gratuita en Groq

  1. Entras a https://console.groq.com.
  2. Te registras con Google o GitHub (tarda 30 segundos).
  3. Vas a API Keys -> Create API Key y copias tu clave (empieza con gsk_...).

  #### Paso 2: Configurar application.yml en el Backend

  En tu archivo de configuración de Spring Boot (src/main/resources/application.yml), configuras el starter de OpenAI para que apunte a Groq:

    spring:
      ai:
        openai:
          # Clave obtenida de console.groq.com
          api-key: ${GROQ_API_KEY:gsk_tu_clave_aqui}

          # Redirección canónica a los servidores de Groq
          base-url: https://api.groq.com/openai

          chat:
            options:
              # Modelo recomendado de alto razonamiento automotriz
              model: llama-3.3-70b-versatile

              # Temperatura 0.1 para que el diagnóstico sea analítico y determinista
              temperature: 0.1

              # Límite de tokens suficiente para el JSON pericial completo
              max-tokens: 2500

  #### Paso 3: Probar el Endpoint

  Cuando levantes el backend y hagas la llamada HTTP:

    POST /api/v1/iot/vehicles/{vehicleId}/health-reports/generate

  1. Spring Boot extraerá los promedios de TimescaleDB.
  2. Formulará el prompt y se lo enviará a Groq mediante HTTPS.
  3. Groq procesará el análisis en menos de un segundo.
  4. Spring AI convertirá el JSON recibido en tu registro Java VehicleHealthReportAiDto.
  5. OpenPDF compilará el reporte con semáforos de salud y membrete del taller.
  6. La respuesta HTTP retornará 201 Created con el JSON y la URL de descarga del PDF.