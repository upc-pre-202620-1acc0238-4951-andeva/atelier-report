# Especificación Canónica de Endpoints REST: Invoicing & Compliance

El Bounded Context **Invoicing & Compliance** (`com.andeva.atelier.platform.invoicing`) gobierna la facturación electrónica tributaria bajo el estándar UBL 2.1 exigido por la Superintendencia Nacional de Aduanas y de Administración Tributaria (SUNAT) en Perú, adaptado al Régimen MYPE Tributario para micro y pequeñas empresas mecánicas. Sus responsabilidades comprenden la emisión y firma digital de facturas, boletas de venta y notas de crédito, la comunicación de baja y anulación, la gestión y conciliación de cobros en mostrador o patio, la parametrización de series y correlativos fiscales autorizados por sede, y la generación de balances consolidados de flujo de caja operativo.

---

## 1. Arquitectura de Seguridad y Convenciones Globales

Todos los endpoints documentados en esta especificación se adhieren a los siguientes estándares de la plataforma Atelier:
* **Autenticación:** Cabecera obligatoria `Authorization: Bearer <JWT>`. El token debe incluir los claims `tenant_id`, `membership_id` y la lista de privilegios del usuario (`permissions`).
* **Aislamiento Multi-Inquilino:** La separación lógica y tributaria de los datos se garantiza validando el claim `tenant_id` contenido en el token criptográfico, contrastado con la cabecera opcional `X-Tenant-Id`. Cada comprobante, serie y cobro se encuentra estrictamente asociado al taller emisor.
* **Control de Acceso Basado en Permisos Atómicos:** La autorización a nivel de método se implementa mediante `@PreAuthorize("hasAuthority('...')")` en cada endpoint del controlador Spring Boot.
* **Manejo Estandarizado de Errores (RFC 7807):** Toda condición de error sintáctico, de seguridad o de regla de negocio retorna una carga útil en formato `application/problem+json` con tipo, título, código HTTP, detalle del incidente, marca temporal e identificador único de correlación.
* **Integración con SUNAT:** La plataforma interactúa con SUNAT mediante un Proveedor de Servicios Electrónicos (PSE) homologado o vía canal síncrono directo UBL 2.1 con contingencia mediante Transactional Outbox.

---

## 2. Índice Canónico de Endpoints

| Método | Ruta Relativa | Controlador Java | Permiso Atómico Requerido | Rol Mínimo Sugerido |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/api/v1/invoicing/vouchers` | `ElectronicVouchersController` | `invoicing:invoices:issue_sunat` | Cajero |
| `POST` | `/api/v1/invoicing/vouchers/credit-notes` | `ElectronicVouchersController` | `invoicing:invoices:issue_sunat` | Administrador de Taller |
| `GET` | `/api/v1/invoicing/vouchers/{id}` | `ElectronicVouchersController` | `invoicing:invoices:read` | Asesor de Servicio |
| `GET` | `/api/v1/invoicing/vouchers` | `ElectronicVouchersController` | `invoicing:invoices:read` | Asesor de Servicio |
| `GET` | `/api/v1/invoicing/vouchers/work-orders/{workOrderId}` | `ElectronicVouchersController` | `invoicing:invoices:read` | Asesor de Servicio |
| `POST` | `/api/v1/invoicing/vouchers/{id}/void` | `ElectronicVouchersController` | `invoicing:invoices:issue_sunat` | Administrador de Taller |
| `GET` | `/api/v1/invoicing/vouchers/{id}/pdf` | `ElectronicVouchersController` | `invoicing:invoices:read` | Cajero |
| `GET` | `/api/v1/invoicing/vouchers/{id}/xml` | `ElectronicVouchersController` | `invoicing:invoices:read` | Cajero |
| `GET` | `/api/v1/invoicing/vouchers/{id}/cdr` | `ElectronicVouchersController` | `invoicing:invoices:read` | Cajero |
| `POST` | `/api/v1/invoicing/payments` | `VoucherPaymentsController` | `invoicing:payments:create` | Cajero |
| `GET` | `/api/v1/invoicing/payments/vouchers/{voucherId}` | `VoucherPaymentsController` | `invoicing:invoices:read` | Cajero |
| `GET` | `/api/v1/invoicing/payments/branches/{branchId}` | `VoucherPaymentsController` | `invoicing:invoices:read` | Cajero |
| `POST` | `/api/v1/invoicing/series-configurations` | `SeriesConfigurationsController` | `invoicing:fiscal_config:manage` | Dueño de Taller |
| `GET` | `/api/v1/invoicing/series-configurations/branches/{branchId}` | `SeriesConfigurationsController` | `invoicing:fiscal_config:manage` / `invoicing:invoices:read` | Cajero |
| `PATCH` | `/api/v1/invoicing/series-configurations/{id}/activate` | `SeriesConfigurationsController` | `invoicing:fiscal_config:manage` | Dueño de Taller |
| `PATCH` | `/api/v1/invoicing/series-configurations/{id}/deactivate` | `SeriesConfigurationsController` | `invoicing:fiscal_config:manage` | Dueño de Taller |
| `GET` | `/api/v1/invoicing/financial-reports/cash-flow` | `FinancialReportsController` | `invoicing:cashflow:export_pdf` | Dueño de Taller |
| `GET` | `/api/v1/invoicing/financial-reports/cash-flow/pdf` | `FinancialReportsController` | `invoicing:cashflow:export_pdf` | Dueño de Taller |

---

## 3. Endpoints de ElectronicVouchersController

El controlador `ElectronicVouchersController` administra el ciclo de vida completo de los comprobantes electrónicos con validez tributaria: emisión ante SUNAT, notas de crédito, consulta de expedientes fiscales, anulación y descarga de archivos probatorios (PDF, XML firmado UBL 2.1 y constancia CDR).

### POST /api/v1/invoicing/vouchers

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.invoicing.interfaces.rest.ElectronicVouchersController`
* **Método Java:** `public ResponseEntity<ElectronicVoucherResource> issueVoucher(@RequestHeader("X-Tenant-Id") UUID tenantId, @Valid @RequestBody IssueVoucherRequest request)`

#### Descripción Funcional
Emite un comprobante de pago electrónico oficial (Factura electrónica código 01 o Boleta de venta electrónica código 03) vinculado o no a una orden de trabajo finalizada del taller. Asigna el número correlativo estricto según la serie fiscal de la sede, computa la base imponible y el 18% del Impuesto General a las Ventas (IGV), despacha la trama UBL 2.1 firmada digitalmente hacia el Proveedor de Servicios Electrónicos (PSE) o SUNAT, y almacena las URL de descarga de los artefactos oficiales (XML, PDF y CDR).

#### Seguridad y Autorización
* **Rol Mínimo:** Cajero (ROLE_CASHIER) o Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('invoicing:invoices:issue_sunat')")`
* **Contexto Multi-Inquilino:** El comprobante y sus líneas se vinculan de manera obligatoria al tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:** Ninguno.
* **Query Parameters:** Ninguno.

#### Cuerpo de Petición (Request DTO)
* **Java Record:** `com.andeva.atelier.platform.invoicing.interfaces.rest.resources.requests.IssueVoucherRequest`

| Campo | Tipo Java | Restricciones y Validaciones | Descripción |
| :--- | :--- | :--- | :--- |
| `branchId` | `UUID` | @NotNull | Identificador único de la sede física emisora autorizada |
| `customerId` | `UUID` | @NotNull | Identificador único del cliente adquirente en CRM |
| `workOrderId` | `UUID` | Opcional | Identificador de la orden de trabajo liquidada en patio (nullable para venta directa de mostrador) |
| `voucherType` | `String` | @NotBlank, @Pattern("01|03") | Tipo de comprobante SUNAT (01 = Factura, 03 = Boleta de Venta) |
| `serie` | `String` | @NotBlank, @Size(min = 4, max = 4) | Serie alfanumérica formal autorizada para la sede (ejemplo F001, B001) |
| `customerInfo` | `CustomerFiscalInfoRequest` | @NotNull | Datos tributarios del cliente (RUC o DNI, razón social y domicilio fiscal) |
| `currency` | `String` | @NotBlank, @Size(min = 3, max = 3), @Pattern("PEN|USD") | Divisa legal de la transacción (PEN o USD) |
| `lines` | `List<VoucherLineRequest>` | @NotEmpty | Lista de partidas detalladas de repuestos instalados y servicios de mano de obra |


```json
{
  "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
  "customerId": "c1d2e3f4-a5b6-4789-0123-456789abcdef",
  "workOrderId": "d4e5f6a7-b8c9-4012-3456-7890abcdef78",
  "voucherType": "01",
  "serie": "F001",
  "customerInfo": {
    "taxId": "20608945231",
    "legalName": "TRANSPORTE Y LOGISTICA SANTA ROSA S.A.C.",
    "fiscalAddress": "Av. Nicolas Arriola 1845, La Victoria, Lima",
    "documentType": "6"
  },
  "currency": "PEN",
  "lines": [
    {
      "itemId": "e1f2a3b4-c5d6-4789-0123-456789abcdef",
      "itemType": "SERVICE",
      "description": "Servicio de Mantenimiento Preventivo de Frenos y Cambio de Pastillas",
      "quantity": 1,
      "unitPriceWithIgv": 180
    },
    {
      "itemId": "f2a3b4c5-d6e7-4890-1234-567890abcdef",
      "itemType": "PRODUCT",
      "description": "Pastillas de Freno Delanteras Ceramicas Bosch",
      "quantity": 1,
      "unitPriceWithIgv": 240
    }
  ]
}
```
#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `201 CREATED`
* **Java Record:** `com.andeva.atelier.platform.invoicing.interfaces.rest.resources.responses.ElectronicVoucherResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador único universal del comprobante fiscal emitido |
| `tenantId` | `UUID` | Identificador del taller automotriz emisor |
| `branchId` | `UUID` | Sede física emisora |
| `customerId` | `UUID` | Identificador del cliente receptor |
| `workOrderId` | `UUID` | Orden de trabajo vinculada |
| `voucherType` | `String` | Tipo tributario (01 = Factura, 03 = Boleta) |
| `serie` | `String` | Serie fiscal |
| `number` | `int` | Número correlativo asignado por la sede |
| `subtotal` | `BigDecimal` | Valor venta o base gravada sin IGV |
| `igvAmount` | `BigDecimal` | Importe del IGV liquidado (18%) |
| `totalAmount` | `BigDecimal` | Importe total facturado al cliente |
| `currency` | `String` | Divisa legal |
| `status` | `String` | Estado formal (ACCEPTED_SUNAT) |
| `customerInfo` | `CustomerFiscalInfoResponse` | Datos tributarios del cliente |
| `digitalReceipts` | `DigitalReceiptUrlsResponse` | Enlaces a PDF, XML y CDR |
| `sunatResponse` | `SunatResponseDto` | Código de respuesta de SUNAT y hash de firma digital |
| `lines` | `List<VoucherLineResource>` | Partidas desglosadas con valores unitarios y tributos |
| `payments` | `List<VoucherPaymentResource>` | Amortizaciones de pago asentadas |
| `issuedAt` | `Instant` | Marca temporal UTC de emisión oficial |


```json
{
  "id": "a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d",
  "tenantId": "8f14e45f-97d8-4f40-8b1b-5e4c4c2c1a1a",
  "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
  "customerId": "c1d2e3f4-a5b6-4789-0123-456789abcdef",
  "workOrderId": "d4e5f6a7-b8c9-4012-3456-7890abcdef78",
  "voucherType": "01",
  "serie": "F001",
  "number": 1042,
  "subtotal": 355.93,
  "igvAmount": 64.07,
  "totalAmount": 420,
  "currency": "PEN",
  "status": "ACCEPTED_SUNAT",
  "customerInfo": {
    "taxId": "20608945231",
    "legalName": "TRANSPORTE Y LOGISTICA SANTA ROSA S.A.C.",
    "fiscalAddress": "Av. Nicolas Arriola 1845, La Victoria, Lima",
    "documentType": "6"
  },
  "digitalReceipts": {
    "pdfUrl": "https://storage.atelier.pe/vouchers/20608945231/F001-00001042.pdf",
    "xmlUrl": "https://storage.atelier.pe/vouchers/20608945231/20608945231-01-F001-00001042.xml",
    "cdrUrl": "https://storage.atelier.pe/vouchers/20608945231/R-20608945231-01-F001-00001042.xml"
  },
  "sunatResponse": {
    "responseCode": "0",
    "description": "La Factura numero F001-00001042 ha sido aceptada por SUNAT",
    "digitalSignatureHash": "4f5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c"
  },
  "lines": [
    {
      "id": "b2c3d4e5-f6a7-4b8c-9d0e-1f2a3b4c5d6e",
      "itemType": "SERVICE",
      "description": "Servicio de Mantenimiento Preventivo de Frenos y Cambio de Pastillas",
      "quantity": 1,
      "unitValue": 152.54,
      "unitPrice": 180,
      "igvAmount": 27.46,
      "totalLine": 180
    },
    {
      "id": "c3d4e5f6-a7b8-4c9d-0e1f-2a3b4c5d6e7f",
      "itemType": "PRODUCT",
      "description": "Pastillas de Freno Delanteras Ceramicas Bosch",
      "quantity": 1,
      "unitValue": 203.39,
      "unitPrice": 240,
      "igvAmount": 36.61,
      "totalLine": 240
    }
  ],
  "payments": [],
  "issuedAt": "2026-10-01T16:00:00Z"
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 400 Bad Request | `https://api.atelier.pe/errors/invalid-tax-id` | `InvalidTaxIdException` | El RUC o DNI receptor no cumple con el algoritmo de validación de módulo 11 de SUNAT |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso invoicing:invoices:issue_sunat denegado |
| 404 Not Found | `https://api.atelier.pe/errors/series-not-found` | `SeriesNotFoundException` | La serie fiscal configurada no existe para esta sede física |
| 409 Conflict | `https://api.atelier.pe/errors/correlative-exhausted` | `CorrelativeExhaustedException` | La serie ha alcanzado el límite máximo de numeración correlativa permitida |
| 502 Bad Gateway | `https://api.atelier.pe/errors/sunat-error` | `SunatIntegrationException` | Falla de comunicación con los servicios del PSE o rechazo síncrono del webservice de SUNAT |


```json
{
  "type": "https://api.atelier.pe/errors/invalid-tax-id",
  "title": "Documento Tributario Invalido",
  "status": 400,
  "detail": "El numero de RUC 20608945239 no cumple con el digito verificador modulo 11 exigido por SUNAT.",
  "instance": "/api/v1/invoicing/vouchers",
  "timestamp": "2026-10-01T16:01:00Z",
  "correlationId": "req-vouch-400-01"
}
```

---

### POST /api/v1/invoicing/vouchers/credit-notes

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.invoicing.interfaces.rest.ElectronicVouchersController`
* **Método Java:** `public ResponseEntity<ElectronicVoucherResource> issueCreditNote(@RequestHeader("X-Tenant-Id") UUID tenantId, @Valid @RequestBody IssueCreditNoteRequest request)`

#### Descripción Funcional
Emite una nota de crédito electrónica (código SUNAT 07) vinculada formalmente a una factura o boleta de venta previamente aceptada. Permite anular operaciones, conceder descuentos por pronto pago o registrar devoluciones de repuestos defectuosos.

#### Seguridad y Autorización
* **Rol Mínimo:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueño de Taller (ROLE_WORKSHOP_OWNER).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('invoicing:invoices:issue_sunat')")`
* **Contexto Multi-Inquilino:** Valida que el comprobante de referencia pertenezca al tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:** Ninguno.
* **Query Parameters:** Ninguno.

#### Cuerpo de Petición (Request DTO)
* **Java Record:** `com.andeva.atelier.platform.invoicing.interfaces.rest.resources.requests.IssueCreditNoteRequest`

| Campo | Tipo Java | Restricciones y Validaciones | Descripción |
| :--- | :--- | :--- | :--- |
| `branchId` | `UUID` | @NotNull | Identificador único de la sede emisora |
| `customerId` | `UUID` | @NotNull | Identificador único del cliente receptor |
| `referenceVoucherId` | `UUID` | @NotNull | Identificador único del comprobante origen afectado |
| `serie` | `String` | @NotBlank, @Size(min = 4, max = 4) | Serie fiscal autorizada para notas de crédito (ejemplo FC01 o BC01) |
| `reason` | `String` | @NotBlank | Código de motivo formal según catálogo 09 de SUNAT (01 = Anulación de la operación) |
| `reasonDescription` | `String` | @NotBlank, @Size(max = 250) | Glosa descriptiva detallada del motivo de la nota de crédito |
| `lines` | `List<VoucherLineRequest>` | @NotEmpty | Partidas afectadas por la nota de crédito |


```json
{
  "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
  "customerId": "c1d2e3f4-a5b6-4789-0123-456789abcdef",
  "referenceVoucherId": "a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d",
  "serie": "FC01",
  "reason": "01",
  "reasonDescription": "Anulacion total de la factura F001-00001042 por error en el detalle de servicios",
  "lines": [
    {
      "itemId": "e1f2a3b4-c5d6-4789-0123-456789abcdef",
      "itemType": "SERVICE",
      "description": "Servicio de Mantenimiento Preventivo de Frenos y Cambio de Pastillas",
      "quantity": 1,
      "unitPriceWithIgv": 180
    },
    {
      "itemId": "f2a3b4c5-d6e7-4890-1234-567890abcdef",
      "itemType": "PRODUCT",
      "description": "Pastillas de Freno Delanteras Ceramicas Bosch",
      "quantity": 1,
      "unitPriceWithIgv": 240
    }
  ]
}
```
#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `201 CREATED`
* **Java Record:** `com.andeva.atelier.platform.invoicing.interfaces.rest.resources.responses.ElectronicVoucherResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador único de la nota de crédito |
| `tenantId` | `UUID` | Taller emisor |
| `branchId` | `UUID` | Sede física |
| `customerId` | `UUID` | Cliente receptor |
| `workOrderId` | `UUID` | Orden vinculada |
| `voucherType` | `String` | Código 07 (Nota de Crédito) |
| `serie` | `String` | Serie fiscal FC01 |
| `number` | `int` | Número correlativo asignado |
| `subtotal` | `BigDecimal` | Base imponible |
| `igvAmount` | `BigDecimal` | IGV liquidado |
| `totalAmount` | `BigDecimal` | Monto total acreditado |
| `currency` | `String` | Divisa legal |
| `status` | `String` | Estado formal ACCEPTED_SUNAT |
| `customerInfo` | `CustomerFiscalInfoResponse` | Datos del cliente |
| `digitalReceipts` | `DigitalReceiptUrlsResponse` | Enlaces a PDF, XML y CDR |
| `sunatResponse` | `SunatResponseDto` | Respuesta de SUNAT |
| `lines` | `List<VoucherLineResource>` | Partidas desglosadas |
| `payments` | `List<VoucherPaymentResource>` | Pagos vinculados |
| `issuedAt` | `Instant` | Marca temporal de emisión |


```json
{
  "id": "d5e6f7a8-b9c0-4123-8901-234567abcdef",
  "tenantId": "8f14e45f-97d8-4f40-8b1b-5e4c4c2c1a1a",
  "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
  "customerId": "c1d2e3f4-a5b6-4789-0123-456789abcdef",
  "workOrderId": "d4e5f6a7-b8c9-4012-3456-7890abcdef78",
  "voucherType": "07",
  "serie": "FC01",
  "number": 12,
  "subtotal": 355.93,
  "igvAmount": 64.07,
  "totalAmount": 420,
  "currency": "PEN",
  "status": "ACCEPTED_SUNAT",
  "customerInfo": {
    "taxId": "20608945231",
    "legalName": "TRANSPORTE Y LOGISTICA SANTA ROSA S.A.C.",
    "fiscalAddress": "Av. Nicolas Arriola 1845, La Victoria, Lima",
    "documentType": "6"
  },
  "digitalReceipts": {
    "pdfUrl": "https://storage.atelier.pe/vouchers/20608945231/FC01-00000012.pdf",
    "xmlUrl": "https://storage.atelier.pe/vouchers/20608945231/20608945231-07-FC01-00000012.xml",
    "cdrUrl": "https://storage.atelier.pe/vouchers/20608945231/R-20608945231-07-FC01-00000012.xml"
  },
  "sunatResponse": {
    "responseCode": "0",
    "description": "La Nota de Credito numero FC01-00000012 ha sido aceptada por SUNAT",
    "digitalSignatureHash": "9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b"
  },
  "lines": [
    {
      "id": "e6f7a8b9-c0d1-4234-9012-345678abcdef",
      "itemType": "SERVICE",
      "description": "Servicio de Mantenimiento Preventivo de Frenos y Cambio de Pastillas",
      "quantity": 1,
      "unitValue": 152.54,
      "unitPrice": 180,
      "igvAmount": 27.46,
      "totalLine": 180
    }
  ],
  "payments": [],
  "issuedAt": "2026-10-01T16:15:00Z"
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 400 Bad Request | `https://api.atelier.pe/errors/invalid-amount` | `InvalidVoucherAmountException` | El importe de la nota de crédito supera el saldo total del comprobante de referencia |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso denegado para emitir notas de crédito |
| 404 Not Found | `https://api.atelier.pe/errors/reference-not-found` | `CreditNoteReferenceNotFoundException` | El comprobante fiscal de referencia no existe en el taller |
| 409 Conflict | `https://api.atelier.pe/errors/voucher-immutable` | `VoucherImmutableException` | El comprobante de referencia ya fue anulado o se encuentra en estado inválido |
| 502 Bad Gateway | `https://api.atelier.pe/errors/sunat-error` | `SunatIntegrationException` | Rechazo del PSE o indisponibilidad en los servidores de SUNAT |


```json
{
  "type": "https://api.atelier.pe/errors/reference-not-found",
  "title": "Comprobante de Referencia No Encontrado",
  "status": 404,
  "detail": "No se encontro el comprobante original con identificador a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c99.",
  "instance": "/api/v1/invoicing/vouchers/credit-notes",
  "timestamp": "2026-10-01T16:16:00Z",
  "correlationId": "req-nc-404-01"
}
```

---

### GET /api/v1/invoicing/vouchers/{id}

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.invoicing.interfaces.rest.ElectronicVouchersController`
* **Método Java:** `public ResponseEntity<ElectronicVoucherResource> getVoucherById(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("id") UUID id)`

#### Descripción Funcional
Recupera la representación digital completa de un comprobante electrónico (factura, boleta o nota de crédito) por su identificador único universal, incluyendo líneas desglosadas, enlaces oficiales de descarga y pagos asociados.

#### Seguridad y Autorización
* **Rol Mínimo:** Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Cajero (ROLE_CASHIER).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('invoicing:invoices:read')")`
* **Contexto Multi-Inquilino:** Valida pertenencia estricta del comprobante al tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `id` (UUID): Identificador único universal del comprobante
* **Query Parameters:** Ninguno.

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `com.andeva.atelier.platform.invoicing.interfaces.rest.resources.responses.ElectronicVoucherResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del comprobante |
| `tenantId` | `UUID` | Identificador del taller |
| `branchId` | `UUID` | Identificador de la sede |
| `customerId` | `UUID` | Identificador del cliente |
| `workOrderId` | `UUID` | Orden de trabajo origen |
| `voucherType` | `String` | Tipo fiscal |
| `serie` | `String` | Serie fiscal |
| `number` | `int` | Número correlativo |
| `subtotal` | `BigDecimal` | Base imponible sin IGV |
| `igvAmount` | `BigDecimal` | Monto del IGV |
| `totalAmount` | `BigDecimal` | Total facturado |
| `currency` | `String` | Divisa |
| `status` | `String` | Estado formal |
| `customerInfo` | `CustomerFiscalInfoResponse` | Datos del cliente |
| `digitalReceipts` | `DigitalReceiptUrlsResponse` | Enlaces a PDF, XML y CDR |
| `sunatResponse` | `SunatResponseDto` | Detalle de respuesta de SUNAT |
| `lines` | `List<VoucherLineResource>` | Partidas desglosadas |
| `payments` | `List<VoucherPaymentResource>` | Pagos registrados |
| `issuedAt` | `Instant` | Marca temporal de emisión |


```json
{
  "id": "a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d",
  "tenantId": "8f14e45f-97d8-4f40-8b1b-5e4c4c2c1a1a",
  "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
  "customerId": "c1d2e3f4-a5b6-4789-0123-456789abcdef",
  "workOrderId": "d4e5f6a7-b8c9-4012-3456-7890abcdef78",
  "voucherType": "01",
  "serie": "F001",
  "number": 1042,
  "subtotal": 355.93,
  "igvAmount": 64.07,
  "totalAmount": 420,
  "currency": "PEN",
  "status": "ACCEPTED_SUNAT",
  "customerInfo": {
    "taxId": "20608945231",
    "legalName": "TRANSPORTE Y LOGISTICA SANTA ROSA S.A.C.",
    "fiscalAddress": "Av. Nicolas Arriola 1845, La Victoria, Lima",
    "documentType": "6"
  },
  "digitalReceipts": {
    "pdfUrl": "https://storage.atelier.pe/vouchers/20608945231/F001-00001042.pdf",
    "xmlUrl": "https://storage.atelier.pe/vouchers/20608945231/20608945231-01-F001-00001042.xml",
    "cdrUrl": "https://storage.atelier.pe/vouchers/20608945231/R-20608945231-01-F001-00001042.xml"
  },
  "sunatResponse": {
    "responseCode": "0",
    "description": "La Factura numero F001-00001042 ha sido aceptada por SUNAT",
    "digitalSignatureHash": "4f5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c"
  },
  "lines": [
    {
      "id": "b2c3d4e5-f6a7-4b8c-9d0e-1f2a3b4c5d6e",
      "itemType": "SERVICE",
      "description": "Servicio de Mantenimiento Preventivo de Frenos y Cambio de Pastillas",
      "quantity": 1,
      "unitValue": 152.54,
      "unitPrice": 180,
      "igvAmount": 27.46,
      "totalLine": 180
    }
  ],
  "payments": [],
  "issuedAt": "2026-10-01T16:00:00Z"
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso invoicing:invoices:read denegado |
| 404 Not Found | `https://api.atelier.pe/errors/voucher-not-found` | `VoucherNotFoundException` | El comprobante solicitado no existe o no corresponde a este taller |


```json
{
  "type": "https://api.atelier.pe/errors/voucher-not-found",
  "title": "Comprobante No Encontrado",
  "status": 404,
  "detail": "No se encontro el comprobante electronico con identificador a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c99.",
  "instance": "/api/v1/invoicing/vouchers/a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c99",
  "timestamp": "2026-10-01T16:17:00Z",
  "correlationId": "req-vouch-get-404-01"
}
```

---

### GET /api/v1/invoicing/vouchers

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.invoicing.interfaces.rest.ElectronicVouchersController`
* **Método Java:** `public ResponseEntity<Page<ElectronicVoucherResource>> listVouchers(@RequestHeader("X-Tenant-Id") UUID tenantId, @RequestParam(value = "branchId", required = false) UUID branchId, @RequestParam(value = "voucherType", required = false) String voucherType, @RequestParam(value = "serie", required = false) String serie, @RequestParam(value = "status", required = false) String status, @RequestParam(value = "startDate", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate, @RequestParam(value = "endDate", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate, Pageable pageable)`

#### Descripción Funcional
Lista de forma segmentada y filtrada el catálogo de comprobantes fiscales emitidos por el taller. Permite filtrar por sede emisora, tipo de documento, serie, estado fiscal y rango cronológico de fechas.

#### Seguridad y Autorización
* **Rol Mínimo:** Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Cajero (ROLE_CASHIER).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('invoicing:invoices:read')")`
* **Contexto Multi-Inquilino:** Aplica filtro estricto por tenant_id en la consulta relacional.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:** Ninguno.
* **Query Parameters:**
  * `branchId` (UUID, Opcional): Filtro por sucursal física emisora
  * `voucherType` (String, Opcional): Filtro por tipo de comprobante (01, 03, 07, 08)
  * `serie` (String, Opcional): Filtro por serie fiscal
  * `status` (String, Opcional): Filtro por estado (ACCEPTED_SUNAT, REJECTED_SUNAT, VOIDED)
  * `startDate` (LocalDate, Opcional): Fecha inicial de emisión en formato YYYY-MM-DD
  * `endDate` (LocalDate, Opcional): Fecha final de emisión en formato YYYY-MM-DD
  * `page` (int, Opcional): Índice de desplazamiento comenzando en cero
  * `size` (int, Opcional): Cantidad de registros por bloque

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `Page<com.andeva.atelier.platform.invoicing.interfaces.rest.resources.responses.ElectronicVoucherResource>`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del comprobante |
| `voucherType` | `String` | Tipo tributario |
| `serie` | `String` | Serie |
| `number` | `int` | Correlativo |
| `totalAmount` | `BigDecimal` | Monto total |
| `status` | `String` | Estado formal |


```json
{
  "content": [
    {
      "id": "a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d",
      "voucherType": "01",
      "serie": "F001",
      "number": 1042,
      "subtotal": 355.93,
      "igvAmount": 64.07,
      "totalAmount": 420,
      "currency": "PEN",
      "status": "ACCEPTED_SUNAT",
      "issuedAt": "2026-10-01T16:00:00Z"
    }
  ],
  "pageable": {
    "pageNumber": 0,
    "pageSize": 20
  },
  "totalElements": 1,
  "totalPages": 1
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso denegado para consultar comprobantes |


```json
{
  "type": "https://api.atelier.pe/errors/unauthorized",
  "title": "No Autorizado",
  "status": 401,
  "detail": "Se requiere autenticacion para consultar la lista de comprobantes.",
  "instance": "/api/v1/invoicing/vouchers",
  "timestamp": "2026-10-01T16:18:00Z",
  "correlationId": "req-vouch-list-401-01"
}
```

---

### GET /api/v1/invoicing/vouchers/work-orders/{workOrderId}

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.invoicing.interfaces.rest.ElectronicVouchersController`
* **Método Java:** `public ResponseEntity<List<ElectronicVoucherResource>> getVouchersByWorkOrder(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("workOrderId") UUID workOrderId)`

#### Descripción Funcional
Recupera el listado de todos los comprobantes fiscales vinculados formalmente a una orden de trabajo específica de MRO, incluyendo facturas preliminares, boletas y notas de crédito asociadas.

#### Seguridad y Autorización
* **Rol Mínimo:** Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Cajero (ROLE_CASHIER).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('invoicing:invoices:read')")`
* **Contexto Multi-Inquilino:** Valida que la orden de trabajo pertenezca al tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `workOrderId` (UUID): Identificador único de la orden de trabajo consultada
* **Query Parameters:** Ninguno.

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `List<com.andeva.atelier.platform.invoicing.interfaces.rest.resources.responses.ElectronicVoucherResource>`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del comprobante |
| `workOrderId` | `UUID` | Orden vinculada |
| `voucherType` | `String` | Tipo tributario |
| `serie` | `String` | Serie |
| `number` | `int` | Correlativo |
| `totalAmount` | `BigDecimal` | Total facturado |
| `status` | `String` | Estado formal |


```json
[
  {
    "id": "a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d",
    "workOrderId": "d4e5f6a7-b8c9-4012-3456-7890abcdef78",
    "voucherType": "01",
    "serie": "F001",
    "number": 1042,
    "subtotal": 355.93,
    "igvAmount": 64.07,
    "totalAmount": 420,
    "currency": "PEN",
    "status": "ACCEPTED_SUNAT",
    "issuedAt": "2026-10-01T16:00:00Z"
  }
]
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso denegado para consultar comprobantes |
| 404 Not Found | `https://api.atelier.pe/errors/work-order-not-found` | `WorkOrderNotFoundException` | La orden de trabajo indicada no existe en el taller |


```json
{
  "type": "https://api.atelier.pe/errors/work-order-not-found",
  "title": "Orden de Trabajo No Encontrada",
  "status": 404,
  "detail": "No se encontro la orden de trabajo especificada con identificador d4e5f6a7-b8c9-4012-3456-7890abcdef99.",
  "instance": "/api/v1/invoicing/vouchers/work-orders/d4e5f6a7-b8c9-4012-3456-7890abcdef99",
  "timestamp": "2026-10-01T16:19:00Z",
  "correlationId": "req-vouch-wo-404-01"
}
```

---

### POST /api/v1/invoicing/vouchers/{id}/void

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.invoicing.interfaces.rest.ElectronicVouchersController`
* **Método Java:** `public ResponseEntity<ElectronicVoucherResource> voidVoucher(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("id") UUID id, @Valid @RequestBody VoidVoucherRequest request)`

#### Descripción Funcional
Comunica la baja formal y anulación del comprobante ante SUNAT dentro del plazo regulatorio permitido (hasta 7 días calendario para facturas). Cambia el estado a VOIDED, registra la causa documentada de anulación y anula la exigibilidad fiscal del saldo pendiente.

#### Seguridad y Autorización
* **Rol Mínimo:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueño de Taller (ROLE_WORKSHOP_OWNER).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('invoicing:invoices:issue_sunat')")`
* **Contexto Multi-Inquilino:** Valida que el comprobante pertenezca al taller autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `id` (UUID): Identificador único del comprobante que se desea dar de baja
* **Query Parameters:** Ninguno.

#### Cuerpo de Petición (Request DTO)
* **Java Record:** `com.andeva.atelier.platform.invoicing.interfaces.rest.resources.requests.VoidVoucherRequest`

| Campo | Tipo Java | Restricciones y Validaciones | Descripción |
| :--- | :--- | :--- | :--- |
| `reason` | `String` | @NotBlank, @Size(max = 250) | Motivo formal que sustenta la comunicación de baja o anulación ante SUNAT |


```json
{
  "reason": "Error en el numero de RUC del cliente emisor consignado en mostrador"
}
```
#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `com.andeva.atelier.platform.invoicing.interfaces.rest.resources.responses.ElectronicVoucherResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del comprobante |
| `serie` | `String` | Serie fiscal |
| `number` | `int` | Correlativo |
| `status` | `String` | Estado actualizado a VOIDED |
| `totalAmount` | `BigDecimal` | Monto total |


```json
{
  "id": "a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d",
  "tenantId": "8f14e45f-97d8-4f40-8b1b-5e4c4c2c1a1a",
  "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
  "customerId": "c1d2e3f4-a5b6-4789-0123-456789abcdef",
  "workOrderId": "d4e5f6a7-b8c9-4012-3456-7890abcdef78",
  "voucherType": "01",
  "serie": "F001",
  "number": 1042,
  "subtotal": 355.93,
  "igvAmount": 64.07,
  "totalAmount": 420,
  "currency": "PEN",
  "status": "VOIDED",
  "issuedAt": "2026-10-01T16:00:00Z"
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 400 Bad Request | `https://api.atelier.pe/errors/invalid-argument` | `MethodArgumentNotValidException` | Motivo de anulación ausente o vacío |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso denegado para anular comprobantes |
| 404 Not Found | `https://api.atelier.pe/errors/voucher-not-found` | `VoucherNotFoundException` | El comprobante no existe |
| 409 Conflict | `https://api.atelier.pe/errors/voucher-immutable` | `VoucherImmutableException` | El comprobante ya fue anulado o se venció el plazo legal de comunicación de baja ante SUNAT |
| 502 Bad Gateway | `https://api.atelier.pe/errors/sunat-error` | `SunatIntegrationException` | Rechazo de la comunicación de baja por el webservice de SUNAT |


```json
{
  "type": "https://api.atelier.pe/errors/voucher-immutable",
  "title": "Comprobante Inmutable",
  "status": 409,
  "detail": "No se puede anular el comprobante debido a que han transcurrido mas de 7 dias calendario desde su emision ante SUNAT.",
  "instance": "/api/v1/invoicing/vouchers/a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d/void",
  "timestamp": "2026-10-01T16:20:00Z",
  "correlationId": "req-void-409-01"
}
```

---

### GET /api/v1/invoicing/vouchers/{id}/pdf

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.invoicing.interfaces.rest.ElectronicVouchersController`
* **Método Java:** `public ResponseEntity<byte[]> downloadVoucherPdf(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("id") UUID id)`

#### Descripción Funcional
Descarga el archivo PDF oficial que contiene la representación impresa del comprobante fiscal, formateado con el imagotipo del taller, código QR tributario y glosas de ley exigidas por SUNAT.

#### Seguridad y Autorización
* **Rol Mínimo:** Cajero (ROLE_CASHIER) o Asesor de Servicio (ROLE_SERVICE_ADVISOR).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('invoicing:invoices:read')")`
* **Contexto Multi-Inquilino:** Valida pertenencia del comprobante al tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `id` (UUID): Identificador único del comprobante electrónico
* **Query Parameters:** Ninguno.

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `Content-Type` | `Header` | Cabecera MIME application/pdf |
| `Content-Disposition` | `Header` | Adjunto de descarga con nombre de archivo F001-00001042.pdf |


```text
%PDF-1.4 ... [Contenido binario compilado de representacion impresa de comprobante fiscal]
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso invoicing:invoices:read denegado |
| 404 Not Found | `https://api.atelier.pe/errors/voucher-not-found` | `VoucherNotFoundException` | Comprobante no encontrado |


```json
{
  "type": "https://api.atelier.pe/errors/voucher-not-found",
  "title": "Comprobante No Encontrado",
  "status": 404,
  "detail": "No se encontro el comprobante para generar la representacion impresa PDF.",
  "instance": "/api/v1/invoicing/vouchers/a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c99/pdf",
  "timestamp": "2026-10-01T16:21:00Z",
  "correlationId": "req-pdf-404-01"
}
```

---

### GET /api/v1/invoicing/vouchers/{id}/xml

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.invoicing.interfaces.rest.ElectronicVouchersController`
* **Método Java:** `public ResponseEntity<byte[]> downloadVoucherXml(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("id") UUID id)`

#### Descripción Funcional
Descarga el archivo XML firmado criptográficamente bajo el estándar UBL 2.1 con el certificado digital de la empresa, el cual constituye el valor probatorio legal del comprobante.

#### Seguridad y Autorización
* **Rol Mínimo:** Cajero (ROLE_CASHIER) o Asesor de Servicio (ROLE_SERVICE_ADVISOR).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('invoicing:invoices:read')")`
* **Contexto Multi-Inquilino:** Valida pertenencia del comprobante al tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `id` (UUID): Identificador único del comprobante electrónico
* **Query Parameters:** Ninguno.

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `Content-Type` | `Header` | Cabecera MIME application/xml con codificación UTF-8 |
| `Content-Disposition` | `Header` | Adjunto de descarga con nombre de archivo 20608945231-01-F001-00001042.xml |


```text
<?xml version="1.0" encoding="UTF-8"?>
<Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"> ... </Invoice>
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso denegado |
| 404 Not Found | `https://api.atelier.pe/errors/voucher-not-found` | `VoucherNotFoundException` | Comprobante no encontrado |


```json
{
  "type": "https://api.atelier.pe/errors/voucher-not-found",
  "title": "Comprobante No Encontrado",
  "status": 404,
  "detail": "No se encontro el comprobante para descargar el archivo XML firmado.",
  "instance": "/api/v1/invoicing/vouchers/a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c99/xml",
  "timestamp": "2026-10-01T16:22:00Z",
  "correlationId": "req-xml-404-01"
}
```

---

### GET /api/v1/invoicing/vouchers/{id}/cdr

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.invoicing.interfaces.rest.ElectronicVouchersController`
* **Método Java:** `public ResponseEntity<byte[]> downloadVoucherCdr(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("id") UUID id)`

#### Descripción Funcional
Descarga la Constancia de Recepción (CDR) oficial devuelta por SUNAT tras la aceptación satisfactoria del comprobante electrónico, la cual certifica la validez fiscal ante cualquier auditoría tributaria.

#### Seguridad y Autorización
* **Rol Mínimo:** Cajero (ROLE_CASHIER) o Asesor de Servicio (ROLE_SERVICE_ADVISOR).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('invoicing:invoices:read')")`
* **Contexto Multi-Inquilino:** Valida que el comprobante pertenezca al tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `id` (UUID): Identificador único del comprobante electrónico
* **Query Parameters:** Ninguno.

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `Content-Type` | `Header` | Cabecera MIME application/xml con codificación UTF-8 |
| `Content-Disposition` | `Header` | Adjunto de descarga con nombre de archivo R-20608945231-01-F001-00001042.xml |


```text
<?xml version="1.0" encoding="UTF-8"?>
<ApplicationResponse xmlns="urn:oasis:names:specification:ubl:schema:xsd:ApplicationResponse-2"> ... </ApplicationResponse>
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso denegado |
| 404 Not Found | `https://api.atelier.pe/errors/voucher-not-found` | `VoucherNotFoundException` | Comprobante no encontrado o CDR no disponible aún |


```json
{
  "type": "https://api.atelier.pe/errors/voucher-not-found",
  "title": "CDR No Disponible",
  "status": 404,
  "detail": "La constancia de recepcion CDR de SUNAT aun no ha sido devuelta para este comprobante.",
  "instance": "/api/v1/invoicing/vouchers/a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c99/cdr",
  "timestamp": "2026-10-01T16:23:00Z",
  "correlationId": "req-cdr-404-01"
}
```

---

## 4. Endpoints de VoucherPaymentsController

El controlador `VoucherPaymentsController` centraliza el asentamiento financiero de amortizaciones y liquidaciones dinerarias percibidas contra comprobantes electrónicos de venta, permitiendo controlar la caja diaria por sede y cuadrar los saldos cobrados.

### POST /api/v1/invoicing/payments

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.invoicing.interfaces.rest.VoucherPaymentsController`
* **Método Java:** `public ResponseEntity<VoucherPaymentResource> registerPayment(@RequestHeader("X-Tenant-Id") UUID tenantId, @Valid @RequestBody RegisterPaymentRequest request)`

#### Descripción Funcional
Asienta y registra un cobro dinerario efectivo o electrónico (efectivo, tarjeta de crédito, tarjeta de débito, transferencia bancaria, Yape o Plin) contra el saldo insoluto de un comprobante de pago emitido. Valida que el monto del abono no exceda la deuda pendiente del comprobante, actualiza el estado de cobranza y genera la partida de arqueo para la caja de la sede.

#### Seguridad y Autorización
* **Rol Mínimo:** Cajero (ROLE_CASHIER) o Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('invoicing:payments:create')")`
* **Contexto Multi-Inquilino:** Valida que el comprobante pertenezca al tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:** Ninguno.
* **Query Parameters:** Ninguno.

#### Cuerpo de Petición (Request DTO)
* **Java Record:** `com.andeva.atelier.platform.invoicing.interfaces.rest.resources.requests.RegisterPaymentRequest`

| Campo | Tipo Java | Restricciones y Validaciones | Descripción |
| :--- | :--- | :--- | :--- |
| `voucherId` | `UUID` | @NotNull | Identificador único del comprobante electrónico amortizado |
| `amount` | `BigDecimal` | @NotNull, @Positive | Importe monetario del cobro recibido estrictamente positivo |
| `currency` | `String` | @NotBlank, @Size(min = 3, max = 3), @Pattern("PEN|USD") | Divisa del abono recibido |
| `paymentMethod` | `String` | @NotBlank, @Pattern("cash|credit_card|debit_card|bank_transfer|yape|plin") | Modalidad o instrumento de recaudación utilizado en mostrador |
| `transactionReference` | `String` | Opcional, @Size(max = 100) | Código de operación bancaria, número de voucher POS o identificador de billetera móvil |


```json
{
  "voucherId": "a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d",
  "amount": 420,
  "currency": "PEN",
  "paymentMethod": "yape",
  "transactionReference": "YAPE-8923412"
}
```
#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `201 CREATED`
* **Java Record:** `com.andeva.atelier.platform.invoicing.interfaces.rest.resources.responses.VoucherPaymentResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador único de la transacción de pago |
| `voucherId` | `UUID` | Comprobante amortizado |
| `amount` | `BigDecimal` | Monto liquidado |
| `currency` | `String` | Divisa del cobro |
| `paymentMethod` | `String` | Modalidad de recaudación |
| `transactionReference` | `String` | Referencia bancaria o digital |
| `status` | `String` | Estado formal de la transacción (COMPLETED) |
| `paidAt` | `Instant` | Marca temporal UTC de recepción del dinero |


```json
{
  "id": "f3a4b5c6-d7e8-4901-2345-678901abcdef",
  "voucherId": "a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d",
  "amount": 420,
  "currency": "PEN",
  "paymentMethod": "yape",
  "transactionReference": "YAPE-8923412",
  "status": "COMPLETED",
  "paidAt": "2026-10-01T16:25:00Z"
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 400 Bad Request | `https://api.atelier.pe/errors/invalid-argument` | `MethodArgumentNotValidException` | Importe no positivo o modalidad de pago no reconocida |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso invoicing:payments:create no concedido |
| 404 Not Found | `https://api.atelier.pe/errors/voucher-not-found` | `VoucherNotFoundException` | El comprobante a amortizar no existe |
| 409 Conflict | `https://api.atelier.pe/errors/voucher-already-paid` | `VoucherAlreadyPaidException` | El monto ingresado excede el saldo pendiente o el comprobante ya está cancelado |


```json
{
  "type": "https://api.atelier.pe/errors/voucher-already-paid",
  "title": "Comprobante Totalmente Pagado",
  "status": 409,
  "detail": "El comprobante F001-00001042 ya cuenta con el saldo total amortizado y no admite nuevos pagos.",
  "instance": "/api/v1/invoicing/payments",
  "timestamp": "2026-10-01T16:26:00Z",
  "correlationId": "req-pay-vouch-409-01"
}
```

---

### GET /api/v1/invoicing/payments/vouchers/{voucherId}

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.invoicing.interfaces.rest.VoucherPaymentsController`
* **Método Java:** `public ResponseEntity<List<VoucherPaymentResource>> getPaymentsByVoucher(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("voucherId") UUID voucherId)`

#### Descripción Funcional
Consulta y lista el historial completo de amortizaciones y cobros aplicados a un comprobante fiscal en particular, permitiendo verificar pagos parciales, saldos pendientes y medios de pago utilizados.

#### Seguridad y Autorización
* **Rol Mínimo:** Cajero (ROLE_CASHIER) o Asesor de Servicio (ROLE_SERVICE_ADVISOR).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('invoicing:invoices:read')")`
* **Contexto Multi-Inquilino:** Valida que el comprobante pertenezca al tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `voucherId` (UUID): Identificador único del comprobante electrónico consultado
* **Query Parameters:** Ninguno.

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `List<com.andeva.atelier.platform.invoicing.interfaces.rest.resources.responses.VoucherPaymentResource>`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del pago |
| `voucherId` | `UUID` | Comprobante asociado |
| `amount` | `BigDecimal` | Importe del abono |
| `currency` | `String` | Divisa del abono |
| `paymentMethod` | `String` | Medio de pago |
| `transactionReference` | `String` | Constancia u operación |
| `status` | `String` | Estado formal |
| `paidAt` | `Instant` | Fecha y hora de pago |


```json
[
  {
    "id": "f3a4b5c6-d7e8-4901-2345-678901abcdef",
    "voucherId": "a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d",
    "amount": 420,
    "currency": "PEN",
    "paymentMethod": "yape",
    "transactionReference": "YAPE-8923412",
    "status": "COMPLETED",
    "paidAt": "2026-10-01T16:25:00Z"
  }
]
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso denegado |
| 404 Not Found | `https://api.atelier.pe/errors/voucher-not-found` | `VoucherNotFoundException` | Comprobante no encontrado |


```json
{
  "type": "https://api.atelier.pe/errors/voucher-not-found",
  "title": "Comprobante Inexistente",
  "status": 404,
  "detail": "No se encontro el comprobante especificado para consultar abonos.",
  "instance": "/api/v1/invoicing/payments/vouchers/a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c99",
  "timestamp": "2026-10-01T16:27:00Z",
  "correlationId": "req-pay-vouch-404-01"
}
```

---

### GET /api/v1/invoicing/payments/branches/{branchId}

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.invoicing.interfaces.rest.VoucherPaymentsController`
* **Método Java:** `public ResponseEntity<List<VoucherPaymentResource>> getPaymentsByBranchAndDate(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("branchId") UUID branchId, @RequestParam(value = "date", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date)`

#### Descripción Funcional
Recupera el arqueo consolidado de cobros recaudados en una sede física específica durante una jornada operativa. Permite al cajero y administrador cuadrar la caja física confrontando efectivo y abonos digitales.

#### Seguridad y Autorización
* **Rol Mínimo:** Cajero (ROLE_CASHIER) o Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('invoicing:invoices:read')")`
* **Contexto Multi-Inquilino:** Valida que la sucursal física pertenezca al tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `branchId` (UUID): Identificador único de la sede física consultada
* **Query Parameters:**
  * `date` (LocalDate, Opcional): Fecha del arqueo de cobros en formato YYYY-MM-DD. Si se omite, asume la fecha actual

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `List<com.andeva.atelier.platform.invoicing.interfaces.rest.resources.responses.VoucherPaymentResource>`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del cobro |
| `voucherId` | `UUID` | Comprobante cancelado |
| `amount` | `BigDecimal` | Monto recaudado |
| `currency` | `String` | Divisa |
| `paymentMethod` | `String` | Medio de recaudación |
| `transactionReference` | `String` | Referencia bancaria o digital |
| `status` | `String` | Estado formal |
| `paidAt` | `Instant` | Marca temporal del cobro |


```json
[
  {
    "id": "f3a4b5c6-d7e8-4901-2345-678901abcdef",
    "voucherId": "a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d",
    "amount": 420,
    "currency": "PEN",
    "paymentMethod": "yape",
    "transactionReference": "YAPE-8923412",
    "status": "COMPLETED",
    "paidAt": "2026-10-01T16:25:00Z"
  }
]
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso denegado para consultar arqueo |
| 404 Not Found | `https://api.atelier.pe/errors/branch-not-found` | `BranchNotFoundException` | La sucursal indicada no existe |


```json
{
  "type": "https://api.atelier.pe/errors/branch-not-found",
  "title": "Sede No Encontrada",
  "status": 404,
  "detail": "No se encontro la sede física especificada para consultar el arqueo de pagos.",
  "instance": "/api/v1/invoicing/payments/branches/b8c3d9a1-4567-4e89-9123-abcdef012999",
  "timestamp": "2026-10-01T16:28:00Z",
  "correlationId": "req-pay-br-404-01"
}
```

---

## 5. Endpoints de SeriesConfigurationsController

El controlador `SeriesConfigurationsController` gestiona la configuración soberana de las series alfanuméricas autorizadas por SUNAT para cada sucursal física del taller, garantizando el avance correlativo estricto y la trazabilidad fiscal inmutable.

### POST /api/v1/invoicing/series-configurations

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.invoicing.interfaces.rest.SeriesConfigurationsController`
* **Método Java:** `public ResponseEntity<SeriesConfigurationResource> configureSeries(@RequestHeader("X-Tenant-Id") UUID tenantId, @Valid @RequestBody ConfigureSeriesRequest request)`

#### Descripción Funcional
Parametriza y da de alta una nueva serie alfanumérica de facturación electrónica autorizada por SUNAT para una sede física específica del taller automotriz. Establece el tipo de comprobante asociado y el correlativo inicial para garantizar la correlatividad estricta.

#### Seguridad y Autorización
* **Rol Mínimo:** Dueño de Taller (ROLE_WORKSHOP_OWNER).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('invoicing:fiscal_config:manage')")`
* **Contexto Multi-Inquilino:** Valida que la sucursal física pertenezca de forma soberana al tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `Content-Type: application/json`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:** Ninguno.
* **Query Parameters:** Ninguno.

#### Cuerpo de Petición (Request DTO)
* **Java Record:** `com.andeva.atelier.platform.invoicing.interfaces.rest.resources.requests.ConfigureSeriesRequest`

| Campo | Tipo Java | Restricciones y Validaciones | Descripción |
| :--- | :--- | :--- | :--- |
| `branchId` | `UUID` | @NotNull | Identificador único de la sede física autorizada para emitir la serie |
| `voucherType` | `String` | @NotBlank, @Pattern("01|03|07|08") | Tipo tributario de comprobante (01 = Factura, 03 = Boleta, 07 = NC, 08 = ND) |
| `serie` | `String` | @NotBlank, @Size(min = 4, max = 4) | Código alfanumérico formal de 4 caracteres (ejemplo F001, B001, FC01, BC01) |
| `initialCorrelative` | `int` | @Min(0) | Último correlativo numérico emitido previamente o cero para series nuevas |


```json
{
  "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
  "voucherType": "01",
  "serie": "F001",
  "initialCorrelative": 0
}
```
#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `201 CREATED`
* **Java Record:** `com.andeva.atelier.platform.invoicing.interfaces.rest.resources.responses.SeriesConfigurationResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador único de la configuración de serie fiscal |
| `tenantId` | `UUID` | Taller titular de la serie |
| `branchId` | `UUID` | Sede física titular |
| `voucherType` | `String` | Tipo de comprobante SUNAT |
| `serie` | `String` | Serie alfanumérica |
| `currentCorrelative` | `int` | Correlativo actual en curso |
| `isActive` | `boolean` | Vigencia operativa de la serie |


```json
{
  "id": "c4d5e6f7-a8b9-4012-3456-7890abcdef12",
  "tenantId": "8f14e45f-97d8-4f40-8b1b-5e4c4c2c1a1a",
  "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
  "voucherType": "01",
  "serie": "F001",
  "currentCorrelative": 0,
  "isActive": true
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 400 Bad Request | `https://api.atelier.pe/errors/invalid-argument` | `MethodArgumentNotValidException` | Serie con formato no admitido o correlativo negativo |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso invoicing:fiscal_config:manage denegado |
| 404 Not Found | `https://api.atelier.pe/errors/branch-not-found` | `BranchNotFoundException` | La sede física indicada no existe en el taller |
| 409 Conflict | `https://api.atelier.pe/errors/series-exists` | `InvoicingDomainException` | La serie ya se encuentra registrada para esta sede física y tipo de documento |


```json
{
  "type": "https://api.atelier.pe/errors/series-exists",
  "title": "Serie Ya Configurada",
  "status": 409,
  "detail": "La serie F001 para comprobantes tipo 01 ya se encuentra registrada en la sede física especificada.",
  "instance": "/api/v1/invoicing/series-configurations",
  "timestamp": "2026-10-01T16:30:00Z",
  "correlationId": "req-ser-409-01"
}
```

---

### GET /api/v1/invoicing/series-configurations/branches/{branchId}

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.invoicing.interfaces.rest.SeriesConfigurationsController`
* **Método Java:** `public ResponseEntity<List<SeriesConfigurationResource>> getSeriesByBranch(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("branchId") UUID branchId)`

#### Descripción Funcional
Recupera el catálogo de todas las series de facturación electrónica configuradas para una sucursal física determinada, incluyendo su estado de actividad y último correlativo emitido.

#### Seguridad y Autorización
* **Rol Mínimo:** Cajero (ROLE_CASHIER) o Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('invoicing:fiscal_config:manage o invoicing:invoices:read')")`
* **Contexto Multi-Inquilino:** Valida que la sucursal física pertenezca al tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `branchId` (UUID): Identificador único de la sede física consultada
* **Query Parameters:** Ninguno.

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `List<com.andeva.atelier.platform.invoicing.interfaces.rest.resources.responses.SeriesConfigurationResource>`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la configuración |
| `tenantId` | `UUID` | Identificador del taller |
| `branchId` | `UUID` | Identificador de la sede |
| `voucherType` | `String` | Tipo fiscal |
| `serie` | `String` | Serie autorizada |
| `currentCorrelative` | `int` | Último número correlativo emitido |
| `isActive` | `boolean` | Disponibilidad operativa |


```json
[
  {
    "id": "c4d5e6f7-a8b9-4012-3456-7890abcdef12",
    "tenantId": "8f14e45f-97d8-4f40-8b1b-5e4c4c2c1a1a",
    "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
    "voucherType": "01",
    "serie": "F001",
    "currentCorrelative": 1042,
    "isActive": true
  },
  {
    "id": "d5e6f7a8-b9c0-4123-4567-890abcdef123",
    "tenantId": "8f14e45f-97d8-4f40-8b1b-5e4c4c2c1a1a",
    "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
    "voucherType": "03",
    "serie": "B001",
    "currentCorrelative": 512,
    "isActive": true
  }
]
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso denegado para consultar configuraciones de series |
| 404 Not Found | `https://api.atelier.pe/errors/branch-not-found` | `BranchNotFoundException` | La sucursal indicada no existe |


```json
{
  "type": "https://api.atelier.pe/errors/branch-not-found",
  "title": "Sede No Encontrada",
  "status": 404,
  "detail": "No se encontro la sede física especificada para listar series fiscales.",
  "instance": "/api/v1/invoicing/series-configurations/branches/b8c3d9a1-4567-4e89-9123-abcdef012999",
  "timestamp": "2026-10-01T16:31:00Z",
  "correlationId": "req-ser-list-404-01"
}
```

---

### PATCH /api/v1/invoicing/series-configurations/{id}/activate

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.invoicing.interfaces.rest.SeriesConfigurationsController`
* **Método Java:** `public ResponseEntity<Void> activateSeries(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("id") UUID id)`

#### Descripción Funcional
Habilita operativamente una serie fiscal que se encontraba desactivada, permitiendo la emisión continua de comprobantes con sus correlativos correlacionados.

#### Seguridad y Autorización
* **Rol Mínimo:** Dueño de Taller (ROLE_WORKSHOP_OWNER).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('invoicing:fiscal_config:manage')")`
* **Contexto Multi-Inquilino:** Valida pertenencia de la serie al tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `id` (UUID): Identificador único de la configuración de serie a habilitar
* **Query Parameters:** Ninguno.

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `204 NO CONTENT`
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso denegado para activar series |
| 404 Not Found | `https://api.atelier.pe/errors/series-not-found` | `SeriesNotFoundException` | La serie solicitada no existe en el taller |


```json
{
  "type": "https://api.atelier.pe/errors/series-not-found",
  "title": "Serie No Encontrada",
  "status": 404,
  "detail": "No se encontro la serie fiscal con identificador c4d5e6f7-a8b9-4012-3456-7890abcdef99.",
  "instance": "/api/v1/invoicing/series-configurations/c4d5e6f7-a8b9-4012-3456-7890abcdef99/activate",
  "timestamp": "2026-10-01T16:32:00Z",
  "correlationId": "req-ser-act-404-01"
}
```

---

### PATCH /api/v1/invoicing/series-configurations/{id}/deactivate

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.invoicing.interfaces.rest.SeriesConfigurationsController`
* **Método Java:** `public ResponseEntity<Void> deactivateSeries(@RequestHeader("X-Tenant-Id") UUID tenantId, @PathVariable("id") UUID id)`

#### Descripción Funcional
Deshabilita temporal o permanentemente una serie de comprobantes para impedir la emisión de nuevas facturas o boletas bajo su numeración, manteniendo intacto su historial previo.

#### Seguridad y Autorización
* **Rol Mínimo:** Dueño de Taller (ROLE_WORKSHOP_OWNER).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('invoicing:fiscal_config:manage')")`
* **Contexto Multi-Inquilino:** Valida pertenencia de la serie al tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:**
  * `id` (UUID): Identificador único de la serie fiscal a inhabilitar
* **Query Parameters:** Ninguno.

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `204 NO CONTENT`
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso denegado para desactivar series |
| 404 Not Found | `https://api.atelier.pe/errors/series-not-found` | `SeriesNotFoundException` | Serie no encontrada |


```json
{
  "type": "https://api.atelier.pe/errors/series-not-found",
  "title": "Serie Inexistente",
  "status": 404,
  "detail": "No se encontro la serie fiscal para su inhabilitacion operativa.",
  "instance": "/api/v1/invoicing/series-configurations/c4d5e6f7-a8b9-4012-3456-7890abcdef99/deactivate",
  "timestamp": "2026-10-01T16:33:00Z",
  "correlationId": "req-ser-deact-404-01"
}
```

---

## 6. Endpoints de FinancialReportsController

El controlador `FinancialReportsController` proporciona el estado de movimientos y balance de flujo de caja operativo del taller mecánico, integrando cobros a clientes por órdenes liquidadas y egresos por compras de repuestos y sueldos de mecánicos en formatos interactivo (JSON) y oficial (PDF).

### GET /api/v1/invoicing/financial-reports/cash-flow

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.invoicing.interfaces.rest.FinancialReportsController`
* **Método Java:** `public ResponseEntity<CashFlowReportResource> getCashFlowReport(@RequestHeader("X-Tenant-Id") UUID tenantId, @RequestParam("startDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate, @RequestParam("endDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate, @RequestParam(value = "branchId", required = false) UUID branchId)`

#### Descripción Funcional
Genera y consolida el reporte interactivo de flujo de caja operativo del taller en formato JSON estructurado. Integra cronológicamente los cobros percibidos en taller por comprobantes cancelados (+), las compras de repuestos recibidas de proveedores (-) y las nóminas de sueldos desembolsadas a los colaboradores (-), calculando el saldo acumulado progresivo para renderizado dinámico en el Frontend.

#### Seguridad y Autorización
* **Rol Mínimo:** Dueño de Taller (ROLE_WORKSHOP_OWNER) o Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('invoicing:cashflow:export_pdf')")`
* **Contexto Multi-Inquilino:** Agrega transaccionalmente solo movimientos asociados al tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:** Ninguno.
* **Query Parameters:**
  * `startDate` (LocalDate, Requerido): Fecha inicial de cómputo contable en formato YYYY-MM-DD
  * `endDate` (LocalDate, Requerido): Fecha final de cómputo contable en formato YYYY-MM-DD
  * `branchId` (UUID, Opcional): Identificador de la sede física si se desea segmentar el flujo

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
* **Java Record:** `com.andeva.atelier.platform.invoicing.interfaces.rest.resources.responses.CashFlowReportResource`

| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `tenantId` | `UUID` | Identificador del taller automotriz |
| `branchId` | `UUID` | Sede física filtrada (o nulo para balance global) |
| `startDate` | `LocalDate` | Fecha inicial |
| `endDate` | `LocalDate` | Fecha final |
| `totalIncome` | `BigDecimal` | Ingresos totales percibidos (+) |
| `totalExpenses` | `BigDecimal` | Egresos operativos totales (-) |
| `netCashFlow` | `BigDecimal` | Flujo de caja neto resultante |
| `currency` | `String` | Divisa legal del reporte |
| `movements` | `List<CashFlowMovementResource>` | Detalle cronológico de movimientos financieros |


```json
{
  "tenantId": "8f14e45f-97d8-4f40-8b1b-5e4c4c2c1a1a",
  "branchId": "b8c3d9a1-4567-4e89-9123-abcdef012345",
  "startDate": "2026-09-01",
  "endDate": "2026-09-30",
  "totalIncome": 18450,
  "totalExpenses": 8936,
  "netCashFlow": 9514,
  "currency": "PEN",
  "movements": [
    {
      "transactionId": "f3a4b5c6-d7e8-4901-2345-678901abcdef",
      "movementDate": "2026-09-02T10:15:00Z",
      "type": "INCOME",
      "category": "CLIENT_PAYMENT",
      "concept": "Cobro de Factura F001-00001040",
      "referenceNumber": "F001-00001040",
      "amount": 420,
      "runningBalance": 420
    },
    {
      "transactionId": "d4e5f6a7-b8c9-4012-3456-7890abcdef34",
      "movementDate": "2026-09-30T15:20:00Z",
      "type": "EXPENSE",
      "category": "PAYROLL_DISBURSEMENT",
      "concept": "Desembolso de Planilla Setiembre - Juan Perez",
      "referenceNumber": "BCP-OP-8923412093",
      "amount": 2886,
      "runningBalance": 9514
    }
  ]
}
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 400 Bad Request | `https://api.atelier.pe/errors/invalid-date-range` | `InvoicingDomainException` | La fecha inicial es posterior a la fecha final |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso invoicing:cashflow:export_pdf denegado |


```json
{
  "type": "https://api.atelier.pe/errors/invalid-date-range",
  "title": "Rango Invalido",
  "status": 400,
  "detail": "La fecha de inicio 2026-10-01 no puede ser posterior a la fecha de corte 2026-09-01.",
  "instance": "/api/v1/invoicing/financial-reports/cash-flow",
  "timestamp": "2026-10-01T16:34:00Z",
  "correlationId": "req-rep-cf-400-01"
}
```

---

### GET /api/v1/invoicing/financial-reports/cash-flow/pdf

#### Identidad Técnica
* **Controlador:** `com.andeva.atelier.platform.invoicing.interfaces.rest.FinancialReportsController`
* **Método Java:** `public ResponseEntity<byte[]> exportCashFlowPdf(@RequestHeader("X-Tenant-Id") UUID tenantId, @RequestParam("startDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate, @RequestParam("endDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate, @RequestParam(value = "branchId", required = false) UUID branchId)`

#### Descripción Funcional
Genera y descarga el informe oficial en PDF del balance y flujo de caja del taller mediante el motor OpenPDF. Presenta cabecera corporativa, sumatoria de ingresos y egresos, tabla cronológica detallada de movimientos y saldo progresivo final para presentación ante la gerencia.

#### Seguridad y Autorización
* **Rol Mínimo:** Dueño de Taller (ROLE_WORKSHOP_OWNER) o Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR).
* **Permiso Atómico:** `@PreAuthorize("hasAuthority('invoicing:cashflow:export_pdf')")`
* **Contexto Multi-Inquilino:** Compila exclusivamente la información financiera del tenant_id autenticado.

#### Parámetros de Petición
* **Headers Obligatorios:**
  * `Authorization: Bearer <JWT>`
  * `X-Tenant-Id: <UUID>`
* **Path Variables:** Ninguno.
* **Query Parameters:**
  * `startDate` (LocalDate, Requerido): Fecha inicial de cómputo contable en formato YYYY-MM-DD
  * `endDate` (LocalDate, Requerido): Fecha final de cómputo contable en formato YYYY-MM-DD
  * `branchId` (UUID, Opcional): Identificador de sede física opcional

#### Cuerpo de Respuesta (Response DTO)
* **Estado HTTP:** `200 OK`
| Campo | Tipo Java | Descripción |
| :--- | :--- | :--- |
| `Content-Type` | `Header` | Cabecera MIME application/pdf |
| `Content-Disposition` | `Header` | Adjunto de descarga con nombre de archivo cash-flow-2026-09-01-2026-09-30.pdf |


```text
%PDF-1.4 ... [Contenido binario oficial compilado de informe financiero OpenPDF]
```
#### Errores y Excepciones Semánticas (RFC 7807)

| Código HTTP | Error Type URI | Excepción de Dominio Java | Causa Operativa |
| :--- | :--- | :--- | :--- |
| 400 Bad Request | `https://api.atelier.pe/errors/invalid-date-range` | `InvoicingDomainException` | Rango de fechas erróneo |
| 401 Unauthorized | `https://api.atelier.pe/errors/unauthorized` | `AuthenticationException` | Token JWT ausente o inválido |
| 403 Forbidden | `https://api.atelier.pe/errors/forbidden` | `AccessDeniedException` | Permiso denegado para exportar reporte financiero |


```json
{
  "type": "https://api.atelier.pe/errors/invalid-date-range",
  "title": "Rango Invalido",
  "status": 400,
  "detail": "La fecha inicial especificada no puede exceder a la fecha de finalizacion.",
  "instance": "/api/v1/invoicing/financial-reports/cash-flow/pdf",
  "timestamp": "2026-10-01T16:35:00Z",
  "correlationId": "req-rep-pdf-400-01"
}
```

---

