# Especificacion Canonica de Endpoints: CRM & Fleet Context

Este documento constituye la referencia tecnica y exhaustiva de los 22 endpoints expuestos por el Bounded Context **Customer and Fleet Management (CRM)** (`com.andeva.atelier.platform.crm`) dentro de la plataforma SaaS **Atelier Platform Backend**.

## 1. Arquitectura de Cartera de Clientes, Parque Automotor y Flotas Comerciales

El modulo CRM & Fleet administra la relacion con clientes particulares y corporativos, gobierna la trazabilidad tecnica del parque automotor como activo global universal y articula convenios de flotas comerciales B2B y bitacoras de atencion.

### 1.1. Principios Fundamentales del Diseno de Dominio
1. **Aislamiento Multi-Inquilino en Clientes:** La cartera de clientes se segmenta estrictamente por taller mediante la clave foranea `tenantId`. Cada taller es soberano de sus registros de clientes, contactos y condiciones comerciales acordadas.
2. **Activo Vehicular Universal y Cadena de Custodia:** A diferencia de los clientes, la entidad `Vehicle` representa un activo fisico en el mundo real que carece de `tenantId` propio. Su unicidad se garantiza a nivel nacional por placa de rodaje y numero de chasis VIN (ISO 3779). La relacion con los clientes y talleres se materializa a traves de la entidad de trazabilidad `VehicleOwnership`, preservando el historico cronologico inmutable de tenencia y traspasos.
3. **Flotas Comerciales Corporativas (B2B):** Permite agrupar unidades vehiculares bajo convenios empresariales con clientes de tipo persona juridica (`COMPANY`), habilitando tarifas corporativas y gestion centralizada de mantenimiento.
4. **Invariante de Odometria:** Toda actualizacion de kilometraje valida de forma determinista la no regresion del odometro para salvaguardar la transparencia pericial y advertir inconsistencias mecanicas.
5. **Estandar de Errores RFC 7807:** Toda anomalia de validacion sintactica o conflicto de negocio produce respuestas estandarizadas bajo el formato `ProblemDetail`.

### 1.2. Catalogo Maestro de Endpoints de CRM & Fleet

| No. | Seccion | Metodo | Ruta | Controlador | Metodo Java | Permiso Requerido |
| :---: | :---: | :---: | :--- | :--- | :--- | :--- |
| 1 | 2.1 | `GET` | `/api/v1/crm/customers` | `CustomersController` | `getCustomers()` | `@PreAuthorize("hasAuthority('crm:customers:read')")` |
| 2 | 2.2 | `POST` | `/api/v1/crm/customers` | `CustomersController` | `createCustomer()` | `@PreAuthorize("hasAuthority('crm:customers:create')")` |
| 3 | 2.3 | `GET` | `/api/v1/crm/customers/{id}` | `CustomersController` | `getCustomerById()` | `@PreAuthorize("hasAuthority('crm:customers:read')")` |
| 4 | 2.4 | `PUT` | `/api/v1/crm/customers/{id}` | `CustomersController` | `updateCustomer()` | `@PreAuthorize("hasAuthority('crm:customers:update')")` |
| 5 | 2.5 | `GET` | `/api/v1/crm/customers/by-document?type={type}&number={number}` | `CustomersController` | `getCustomerByDocument()` | `@PreAuthorize("hasAuthority('crm:customers:read')")` |
| 6 | 2.6 | `POST` | `/api/v1/crm/customers/{id}/archive` | `CustomersController` | `archiveCustomer()` | `@PreAuthorize("hasAuthority('crm:customers:update')")` |
| 7 | 3.1 | `GET` | `/api/v1/crm/vehicles` | `VehiclesController` | `getVehicles()` | `@PreAuthorize("hasAuthority('crm:vehicles:read')")` |
| 8 | 3.2 | `POST` | `/api/v1/crm/vehicles` | `VehiclesController` | `registerVehicle()` | `@PreAuthorize("hasAuthority('crm:vehicles:create')")` |
| 9 | 3.3 | `GET` | `/api/v1/crm/vehicles/{id}` | `VehiclesController` | `getVehicleById()` | `@PreAuthorize("hasAuthority('crm:vehicles:read')")` |
| 10 | 3.4 | `PUT` | `/api/v1/crm/vehicles/{id}` | `VehiclesController` | `updateVehicle()` | `@PreAuthorize("hasAuthority('crm:vehicles:update')")` |
| 11 | 3.5 | `GET` | `/api/v1/crm/vehicles/by-plate/{plate}` | `VehiclesController` | `getVehicleByPlate()` | `@PreAuthorize("hasAuthority('crm:vehicles:read')")` |
| 12 | 3.6 | `GET` | `/api/v1/crm/vehicles/by-vin/{vin}` | `VehiclesController` | `getVehicleByVin()` | `@PreAuthorize("hasAuthority('crm:vehicles:read')")` |
| 13 | 3.7 | `PUT` | `/api/v1/crm/vehicles/{id}/mileage` | `VehiclesController` | `updateMileage()` | `@PreAuthorize("hasAuthority('crm:vehicles:update')")` |
| 14 | 3.8 | `POST` | `/api/v1/crm/vehicles/{id}/transfer-ownership` | `VehiclesController` | `transferOwnership()` | `@PreAuthorize("hasAuthority('crm:vehicles:update')")` |
| 15 | 4.1 | `GET` | `/api/v1/crm/fleets` | `FleetsController` | `getFleets()` | `@PreAuthorize("hasAuthority('crm:fleets:manage')")` |
| 16 | 4.2 | `POST` | `/api/v1/crm/fleets` | `FleetsController` | `createFleet()` | `@PreAuthorize("hasAuthority('crm:fleets:manage')")` |
| 17 | 4.3 | `GET` | `/api/v1/crm/fleets/{id}` | `FleetsController` | `getFleetById()` | `@PreAuthorize("hasAuthority('crm:fleets:manage')")` |
| 18 | 4.4 | `PUT` | `/api/v1/crm/fleets/{id}` | `FleetsController` | `updateFleet()` | `@PreAuthorize("hasAuthority('crm:fleets:manage')")` |
| 19 | 4.5 | `POST` | `/api/v1/crm/fleets/{id}/vehicles` | `FleetsController` | `addVehicleToFleet()` | `@PreAuthorize("hasAuthority('crm:fleets:manage')")` |
| 20 | 4.6 | `DELETE` | `/api/v1/crm/fleets/{id}/vehicles/{vehicleId}` | `FleetsController` | `removeVehicleFromFleet()` | `@PreAuthorize("hasAuthority('crm:fleets:manage')")` |
| 21 | 5.1 | `GET` | `/api/v1/crm/customers/{customerId}/notes` | `CustomerNotesController` | `getCustomerNotes()` | `@PreAuthorize("hasAuthority('crm:customers:read')")` |
| 22 | 5.2 | `POST` | `/api/v1/crm/customers/{customerId}/notes` | `CustomerNotesController` | `createCustomerNote()` | `@PreAuthorize("hasAuthority('crm:customers:update')")` |

---

## 2. Endpoints de Clientes (CustomersController)

### 2.1. [GET] /api/v1/crm/customers

**Listado Paginado y Filtrado de Cartera de Clientes**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.CustomersController`
- **Metodo Java:** `public ResponseEntity<Page<CustomerResource>> getCustomers(@RequestParam(required = false) String type, @RequestParam(required = false) String search, @RequestParam(required = false) String status, @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "20") int size)`
- **Ruta Base:** `/api/v1/crm/customers`
- **Ruta Completa:** `/api/v1/crm/customers`
- **Proposito:** Retorna una vista paginada de la cartera de clientes (personas naturales y juridicas) correspondiente al taller en sesion. Permite aplicar filtros por tipologia legal (INDIVIDUAL o COMPANY), termino de busqueda textual sobre nombres, razon social o documento de identidad fiscal, y estado comercial.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:customers:read')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto por inquilino. Resuelve el tenantId desde los claims del token JWT e inyecta el filtro en el repositorio JPA.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
| Parametro | Tipo | Requerido | Valor por Defecto | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `type` | `String` | No | Todos | Tipologia legal del cliente (INDIVIDUAL o COMPANY) |
| `search` | `String` | No | Ninguno | Termino de coincidencia sobre nombre, razon social o taxId |
| `status` | `String` | No | ACTIVE | Estado comercial del cliente (ACTIVE o INACTIVE) |
| `page` | `int` | No | 0 | Indice de pagina de resultados basado en cero |
| `size` | `int` | No | 20 | Cantidad maxima de registros por pagina solicitada |

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `org.springframework.data.domain.Page<com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.CustomerResource>`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `content` | `List<CustomerResource>` | Coleccion de recursos de clientes de la pagina solicitada |
| `page` | `int` | Numero de pagina actual retornada |
| `size` | `int` | Tamano maximo de pagina configurado |
| `totalElements` | `long` | Cantidad total de clientes coincidentes en la base de datos |
| `totalPages` | `int` | Cantidad total de paginas calculadas segun el tamano |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "content": [
    {
      "id": "018f6c50-7e12-7000-8000-000000000001",
      "tenantId": "018f6c40-7e12-7000-8000-000000000001",
      "type": "INDIVIDUAL",
      "firstName": "Juan Jose",
      "lastName": "Perez Rodriguez",
      "companyName": null,
      "taxId": "47891234",
      "email": "juan.perez@gmail.com",
      "phone": "+51998877665",
      "status": "ACTIVE",
      "createdAt": "2026-10-01T16:30:00Z"
    },
    {
      "id": "018f6c50-7e12-7000-8000-000000000002",
      "tenantId": "018f6c40-7e12-7000-8000-000000000001",
      "type": "COMPANY",
      "firstName": null,
      "lastName": null,
      "companyName": "TRANSPORTES Y LOGISTICA LIMA NORTE S.A.C.",
      "taxId": "20554433221",
      "email": "flota@transporteslimanorte.pe",
      "phone": "+51911223344",
      "status": "ACTIVE",
      "createdAt": "2026-10-01T16:30:00Z"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 2,
  "totalPages": 1
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `401 Unauthorized` | `AuthenticationException` | Token ausente, invalido o expirado |
| `403 Forbidden` | `AccessDeniedException` | El usuario carece de la autoridad de seguridad crm:customers:read |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/unauthorized",
  "title": "Peticion No Autenticada",
  "status": 401,
  "detail": "Se requiere un token Bearer valido para consultar la cartera de clientes",
  "instance": "/api/v1/crm/customers",
  "code": "UNAUTHORIZED",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 2.2. [POST] /api/v1/crm/customers

**Alta y Registro de Nuevo Cliente en el Taller**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.CustomersController`
- **Metodo Java:** `public ResponseEntity<CustomerResource> createCustomer(@Valid @RequestBody CreateCustomerResource resource)`
- **Ruta Base:** `/api/v1/crm/customers`
- **Ruta Completa:** `/api/v1/crm/customers`
- **Proposito:** Da de alta a un nuevo cliente en el taller automotriz. Valida las reglas de integridad para personas naturales (exigiendo DNI de 8 digitos, nombres y apellidos) o personas juridicas (exigiendo RUC corporativo de 11 digitos y razon social), comprobando la no existencia previa de dicho documento fiscal en la cartera del taller.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:customers:create')")`
- **Aislamiento Multi-Inquilino:** Asigna de manera forzosa el tenantId resuelto del token JWT al nuevo registro de cliente.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.requests.CreateCustomerResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `type` | `String` | Si | `@NotBlank, @Pattern(regexp = "^(INDIVIDUAL|COMPANY)$")` | Tipologia legal del cliente a registrar |
| `firstName` | `String` | Condicional | `@Size(max = 100)` | Nombres de pila (obligatorio si el tipo es INDIVIDUAL) |
| `lastName` | `String` | Condicional | `@Size(max = 100)` | Apellidos completos (obligatorio si el tipo es INDIVIDUAL) |
| `companyName` | `String` | Condicional | `@Size(max = 150)` | Razon social legal (obligatoria si el tipo es COMPANY) |
| `taxId` | `String` | Si | `@NotBlank, @Pattern(regexp = "^(\d{8}|(10|20)\d{9})$")` | Documento de identidad fiscal (DNI de 8 digitos o RUC de 11 digitos) |
| `email` | `String` | Si | `@NotBlank, @Email, @Size(max = 150)` | Correo electronico de notificaciones del cliente |
| `phone` | `String` | Si | `@NotBlank, @Pattern(regexp = "^\+?[0-9]{9,15}$")` | Telefono movil o fijo de contacto |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "type": "INDIVIDUAL",
  "firstName": "Juan Jose",
  "lastName": "Perez Rodriguez",
  "companyName": null,
  "taxId": "47891234",
  "email": "juan.perez@gmail.com",
  "phone": "+51998877665"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.CustomerResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador universal asignado al cliente |
| `tenantId` | `UUID` | Identificador del taller automotriz |
| `type` | `String` | Tipologia legal del cliente |
| `firstName` | `String` | Nombres de pila registrados |
| `lastName` | `String` | Apellidos registrados |
| `companyName` | `String` | Razon social registrada |
| `taxId` | `String` | Documento de identidad tributario |
| `email` | `String` | Correo electronico registrado |
| `phone` | `String` | Numero telefonico |
| `status` | `String` | Estado comercial inicial (ACTIVE) |
| `createdAt` | `Instant` | Marca temporal de alta en UTC |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c50-7e12-7000-8000-000000000001",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "type": "INDIVIDUAL",
  "firstName": "Juan Jose",
  "lastName": "Perez Rodriguez",
  "companyName": null,
  "taxId": "47891234",
  "email": "juan.perez@gmail.com",
  "phone": "+51998877665",
  "status": "ACTIVE",
  "createdAt": "2026-10-01T16:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | El documento de identidad no cumple el patron numerico o faltan nombres/razon social requeridos |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Falta de autoridad crm:customers:create |
| `409 Conflict` | `CustomerTaxIdAlreadyExistsException` | Ya existe un cliente registrado con ese documento de identidad en este taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/customer-tax-id-exists",
  "title": "Documento de Identidad Duplicado",
  "status": 409,
  "detail": "El documento 47891234 ya se encuentra registrado en la cartera de clientes de este taller",
  "instance": "/api/v1/crm/customers",
  "code": "CUSTOMER_TAX_ID_ALREADY_EXISTS",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 2.3. [GET] /api/v1/crm/customers/{id}

**Detalle Completo de Ficha de Cliente por Identificador**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.CustomersController`
- **Metodo Java:** `public ResponseEntity<CustomerResource> getCustomerById(@PathVariable UUID id)`
- **Ruta Base:** `/api/v1/crm/customers`
- **Ruta Completa:** `/api/v1/crm/customers/{id}`
- **Proposito:** Consulta los datos integrales de la ficha comercial y de contacto de un cliente mediante su identificador universal. Comprueba que el registro pertenezca estrictamente al taller autenticado para garantizar aislamiento de datos.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST) o Asesor de Servicio
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:customers:read')")`
- **Aislamiento Multi-Inquilino:** Aislamiento multi-inquilino estricto. Valida que customer.tenantId coincida con session.tenantId.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Si | Identificador universal del cliente |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.CustomerResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador universal del cliente |
| `tenantId` | `UUID` | Identificador del taller titular |
| `type` | `String` | Tipologia legal del cliente |
| `firstName` | `String` | Nombres registrados |
| `lastName` | `String` | Apellidos registrados |
| `companyName` | `String` | Razon social registrada |
| `taxId` | `String` | Documento fiscal de identidad |
| `email` | `String` | Correo electronico |
| `phone` | `String` | Numero telefonico |
| `status` | `String` | Estado comercial |
| `createdAt` | `Instant` | Marca temporal de registro |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c50-7e12-7000-8000-000000000001",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "type": "INDIVIDUAL",
  "firstName": "Juan Jose",
  "lastName": "Perez Rodriguez",
  "companyName": null,
  "taxId": "47891234",
  "email": "juan.perez@gmail.com",
  "phone": "+51998877665",
  "status": "ACTIVE",
  "createdAt": "2026-10-01T16:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o expirado |
| `403 Forbidden` | `AccessDeniedException` | Falta del permiso crm:customers:read |
| `404 Not Found` | `CustomerNotFoundException` | El cliente no existe o pertenece a otro taller automotriz |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/customer-not-found",
  "title": "Cliente No Encontrado",
  "status": 404,
  "detail": "No se encontro ningun cliente con el identificador 018f6c50-7e12-7000-8000-000000000001 en este taller",
  "instance": "/api/v1/crm/customers/018f6c50-7e12-7000-8000-000000000001",
  "code": "CUSTOMER_NOT_FOUND",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 2.4. [PUT] /api/v1/crm/customers/{id}

**Actualizacion de Datos Personales y Canales de Contacto**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.CustomersController`
- **Metodo Java:** `public ResponseEntity<CustomerResource> updateCustomer(@PathVariable UUID id, @Valid @RequestBody UpdateCustomerResource resource)`
- **Ruta Base:** `/api/v1/crm/customers`
- **Ruta Completa:** `/api/v1/crm/customers/{id}`
- **Proposito:** Actualiza los canales de contacto directo (telefono y correo electronico) y datos demograficos del cliente. El documento de identidad fiscal (taxId) y la tipologia legal permanecen inmutables para garantizar consistencia con los historiales de facturacion electronica SUNAT.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:customers:update')")`
- **Aislamiento Multi-Inquilino:** Verifica pertenencia del cliente al tenantId en sesion antes de aplicar cambios.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Si | Identificador universal del cliente a modificar |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.requests.UpdateCustomerResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `firstName` | `String` | No | `@Size(max = 100)` | Nombres actualizados (si aplica a individual) |
| `lastName` | `String` | No | `@Size(max = 100)` | Apellidos actualizados (si aplica a individual) |
| `companyName` | `String` | No | `@Size(max = 150)` | Razon social actualizada (si aplica a empresa) |
| `email` | `String` | Si | `@NotBlank, @Email, @Size(max = 150)` | Correo electronico actualizado |
| `phone` | `String` | Si | `@NotBlank, @Pattern(regexp = "^\+?[0-9]{9,15}$")` | Telefono movil o fijo actualizado |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "firstName": "Juan Jose",
  "lastName": "Perez Rodriguez",
  "companyName": null,
  "email": "juan.perez.nuevo@gmail.com",
  "phone": "+51998877660"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.CustomerResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador universal del cliente |
| `tenantId` | `UUID` | Identificador del taller |
| `type` | `String` | Tipologia legal del cliente |
| `firstName` | `String` | Nombres actualizados |
| `lastName` | `String` | Apellidos actualizados |
| `companyName` | `String` | Razon social |
| `taxId` | `String` | Documento fiscal inmutable |
| `email` | `String` | Correo electronico modificado |
| `phone` | `String` | Telefono modificado |
| `status` | `String` | Estado comercial |
| `createdAt` | `Instant` | Fecha de creacion original |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c50-7e12-7000-8000-000000000001",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "type": "INDIVIDUAL",
  "firstName": "Juan Jose",
  "lastName": "Perez Rodriguez",
  "companyName": null,
  "taxId": "47891234",
  "email": "juan.perez.nuevo@gmail.com",
  "phone": "+51998877660",
  "status": "ACTIVE",
  "createdAt": "2026-10-01T16:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Sintaxis de correo invalida o telefono disconforme con el patron internacional |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Falta del permiso crm:customers:update |
| `404 Not Found` | `CustomerNotFoundException` | Ficha de cliente no encontrada en el taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-request-payload",
  "title": "Datos de Contacto Invalidos",
  "status": 400,
  "detail": "La direccion de correo electronico especificada no cumple con el formato RFC 5322",
  "instance": "/api/v1/crm/customers/018f6c50-7e12-7000-8000-000000000001",
  "code": "INVALID_REQUEST_PAYLOAD",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 2.5. [GET] /api/v1/crm/customers/by-document?type={type}&number={number}

**Busqueda Univoca de Cliente por Tipo y Numero de Documento**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.CustomersController`
- **Metodo Java:** `public ResponseEntity<CustomerResource> getCustomerByDocument(@RequestParam String type, @RequestParam String number)`
- **Ruta Base:** `/api/v1/crm/customers`
- **Ruta Completa:** `/api/v1/crm/customers/by-document?type={type}&number={number}`
- **Proposito:** Localiza de forma veloz y unívoca a un cliente en la cartera del taller mediante su documento fiscal de identidad (DNI o RUC). Diseñado para la atencion rapida en counter y el autocompletado en patio.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST) o Asesor de Servicio
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:customers:read')")`
- **Aislamiento Multi-Inquilino:** Filtra la busqueda combinando el tenantId activo con el taxId ingresado.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
| Parametro | Tipo | Requerido | Valor por Defecto | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `type` | `String` | Si | Ninguno | Tipo de documento oficial (DNI o RUC) |
| `number` | `String` | Si | Ninguno | Numero del documento (8 digitos para DNI u 11 para RUC) |

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.CustomerResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador universal del cliente |
| `tenantId` | `UUID` | Identificador del taller |
| `type` | `String` | Tipologia legal |
| `firstName` | `String` | Nombres registrados |
| `lastName` | `String` | Apellidos registrados |
| `companyName` | `String` | Razon social registrada |
| `taxId` | `String` | Documento fiscal localizado |
| `email` | `String` | Correo electronico de contacto |
| `phone` | `String` | Telefono de contacto |
| `status` | `String` | Estado comercial |
| `createdAt` | `Instant` | Fecha de registro |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c50-7e12-7000-8000-000000000001",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "type": "INDIVIDUAL",
  "firstName": "Juan Jose",
  "lastName": "Perez Rodriguez",
  "companyName": null,
  "taxId": "47891234",
  "email": "juan.perez@gmail.com",
  "phone": "+51998877665",
  "status": "ACTIVE",
  "createdAt": "2026-10-01T16:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `IllegalArgumentException` | Parametros type o number ausentes o con formato disconforme |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Permiso crm:customers:read insuficiente |
| `404 Not Found` | `CustomerNotFoundException` | No existe ningun cliente con ese documento registrado en este taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/customer-not-found",
  "title": "Cliente No Localizado",
  "status": 404,
  "detail": "No se encontro ningun cliente registrado con el documento 47891234 en el taller activo",
  "instance": "/api/v1/crm/customers/by-document?type=DNI&number=47891234",
  "code": "CUSTOMER_NOT_FOUND",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 2.6. [POST] /api/v1/crm/customers/{id}/archive

**Archivo o Pase a Inactividad Comercial de Ficha de Cliente**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.CustomersController`
- **Metodo Java:** `public ResponseEntity<CustomerResource> archiveCustomer(@PathVariable UUID id)`
- **Ruta Base:** `/api/v1/crm/customers`
- **Ruta Completa:** `/api/v1/crm/customers/{id}/archive`
- **Proposito:** Transiciona el estado comercial del cliente a INACTIVE. Impide la generacion de nuevas cotizaciones, ordenes de trabajo o agendamiento de citas futuras, preservando de manera inalterada todo el historico transaccional. La operacion es rechazada si el cliente posee ordenes de trabajo abiertas en patio.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueno (ROLE_WORKSHOP_OWNER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:customers:update')")`
- **Aislamiento Multi-Inquilino:** Verifica pertenencia del cliente al tenantId en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Si | Identificador universal del cliente a archivar |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.CustomerResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del cliente |
| `tenantId` | `UUID` | Identificador del taller |
| `type` | `String` | Tipologia legal |
| `firstName` | `String` | Nombres registrados |
| `lastName` | `String` | Apellidos registrados |
| `companyName` | `String` | Razon social registrada |
| `taxId` | `String` | Documento fiscal |
| `email` | `String` | Correo electronico |
| `phone` | `String` | Telefono |
| `status` | `String` | Estado actualizado (INACTIVE) |
| `createdAt` | `Instant` | Fecha de creacion |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c50-7e12-7000-8000-000000000001",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "type": "INDIVIDUAL",
  "firstName": "Juan Jose",
  "lastName": "Perez Rodriguez",
  "companyName": null,
  "taxId": "47891234",
  "email": "juan.perez@gmail.com",
  "phone": "+51998877665",
  "status": "INACTIVE",
  "createdAt": "2026-10-01T16:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Permiso insuficiente para archivar clientes |
| `404 Not Found` | `CustomerNotFoundException` | Cliente no encontrado en el taller |
| `409 Conflict` | `CustomerHasActiveWorkOrdersException` | No se puede archivar un cliente que mantiene ordenes de trabajo en ejecucion en el taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/customer-has-active-work-orders",
  "title": "Conflicto Operativo",
  "status": 409,
  "detail": "El cliente mantiene una orden de trabajo activa en foso. Cierre o cancele la orden antes de archivarlo",
  "instance": "/api/v1/crm/customers/018f6c50-7e12-7000-8000-000000000001/archive",
  "code": "CUSTOMER_HAS_ACTIVE_WORK_ORDERS",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

## 3. Endpoints del Parque Automotor (VehiclesController)

### 3.1. [GET] /api/v1/crm/vehicles

**Catalogo Paginado de Vehiculos Registrados**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.VehiclesController`
- **Metodo Java:** `public ResponseEntity<Page<VehicleResource>> getVehicles(@RequestParam(required = false) String search, @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "20") int size)`
- **Ruta Base:** `/api/v1/crm/vehicles`
- **Ruta Completa:** `/api/v1/crm/vehicles`
- **Proposito:** Retorna el listado paginado del parque automotor atendido en el taller o vinculado a su cartera de clientes. Permite aplicar busquedas parciales por placa de rodaje, marca, modelo o titular.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Tecnico Mecanico (ROLE_MECHANIC) o Recepcionista (ROLE_RECEPTIONIST)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:vehicles:read')")`
- **Aislamiento Multi-Inquilino:** El vehiculo es un activo global independiente de inquilino. Este endpoint filtra aquellos vehiculos que mantienen historial de custodia o atencion en el taller del usuario.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
| Parametro | Tipo | Requerido | Valor por Defecto | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `search` | `String` | No | Ninguno | Termino de coincidencia sobre placa, VIN, marca o modelo |
| `page` | `int` | No | 0 | Indice de pagina de resultados basado en cero |
| `size` | `int` | No | 20 | Cantidad maxima de registros por pagina |

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `org.springframework.data.domain.Page<com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.VehicleResource>`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `content` | `List<VehicleResource>` | Lista de vehiculos correspondientes a la pagina solicitada |
| `page` | `int` | Indice de la pagina actual |
| `size` | `int` | Registros por pagina |
| `totalElements` | `long` | Total de vehiculos encontrados |
| `totalPages` | `int` | Total de paginas disponibles |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "content": [
    {
      "id": "018f6c50-7e12-7000-8000-000000000010",
      "plate": "ABC123",
      "vin": "9BD11122233344455",
      "brand": "Toyota",
      "model": "Corolla Sedan",
      "year": 2021,
      "engineType": "GASOLINE",
      "currentMileage": 45200,
      "currentOwnerId": "018f6c50-7e12-7000-8000-000000000001",
      "currentOwnerName": "Juan Jose Perez Rodriguez",
      "createdAt": "2026-10-01T16:30:00Z"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 1,
  "totalPages": 1
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Falta del permiso crm:vehicles:read |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/unauthorized",
  "title": "No Autorizado",
  "status": 401,
  "detail": "Se requiere autenticacion valida para consultar el parque automotor",
  "instance": "/api/v1/crm/vehicles",
  "code": "UNAUTHORIZED",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 3.2. [POST] /api/v1/crm/vehicles

**Registro Universal de Activo Vehicular y Asignacion de Titular Inicial**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.VehiclesController`
- **Metodo Java:** `public ResponseEntity<VehicleResource> registerVehicle(@Valid @RequestBody RegisterVehicleResource resource)`
- **Ruta Base:** `/api/v1/crm/vehicles`
- **Ruta Completa:** `/api/v1/crm/vehicles`
- **Proposito:** Registra formalmente un automovil en el catalogo universal de la plataforma y crea el primer registro cronologico de tenencia vinculado a un cliente del taller. Garantiza unicidad nacional por placa de rodaje y numero de chasis VIN segun norma ISO 3779.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:vehicles:create')")`
- **Aislamiento Multi-Inquilino:** El activo automotor se crea a nivel global y su custodia inicial se asocia al customerId adscrito al taller.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.requests.RegisterVehicleResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `plate` | `String` | Si | `@NotBlank, @Pattern(regexp = "^[A-Z0-9]{6}$")` | Placa oficial de rodaje de seis caracteres alfanumericos sin guiones |
| `vin` | `String` | No | `@Pattern(regexp = "^[A-HJ-NPR-Z0-9]{17}$")` | Numero de identificacion vehicular de 17 caracteres segun ISO 3779 |
| `brand` | `String` | Si | `@NotBlank, @Size(max = 50)` | Marca automotriz (ej. Toyota, Nissan, Hyundai) |
| `model` | `String` | Si | `@NotBlank, @Size(max = 50)` | Modelo comercial de la unidad |
| `year` | `int` | Si | `@NotNull, @Min(1950), @Max(2030)` | Ano de fabricacion del vehiculo |
| `engineType` | `String` | Si | `@NotBlank, @Pattern(regexp = "^(GASOLINE|DIESEL|ELECTRIC|HYBRID)$")` | Tipo de motorizacion y combustible |
| `initialMileage` | `Integer` | No | `@Min(0)` | Kilometraje reportado al momento del registro |
| `initialOwnerId` | `UUID` | Si | `@NotNull` | Identificador del cliente titular inicial de la unidad |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "plate": "ABC123",
  "vin": "9BD11122233344455",
  "brand": "Toyota",
  "model": "Corolla Sedan",
  "year": 2021,
  "engineType": "GASOLINE",
  "initialMileage": 45200,
  "initialOwnerId": "018f6c50-7e12-7000-8000-000000000001"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.VehicleResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador universal asignado al automotor |
| `plate` | `String` | Placa de rodaje normalizada |
| `vin` | `String` | Numero de chasis VIN registrado |
| `brand` | `String` | Marca automotriz |
| `model` | `String` | Modelo del vehiculo |
| `year` | `int` | Ano de fabricacion |
| `engineType` | `String` | Tipo de motorizacion |
| `currentMileage` | `Integer` | Kilometraje actual registrado |
| `currentOwnerId` | `UUID` | Identificador del cliente titular |
| `currentOwnerName` | `String` | Nombre completo o razon social del titular |
| `createdAt` | `Instant` | Marca temporal de alta en UTC |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c50-7e12-7000-8000-000000000010",
  "plate": "ABC123",
  "vin": "9BD11122233344455",
  "brand": "Toyota",
  "model": "Corolla Sedan",
  "year": 2021,
  "engineType": "GASOLINE",
  "currentMileage": 45200,
  "currentOwnerId": "018f6c50-7e12-7000-8000-000000000001",
  "currentOwnerName": "Juan Jose Perez Rodriguez",
  "createdAt": "2026-10-01T16:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Formato de placa no conforme con el patron peruano o VIN disconforme con ISO 3779 |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Falta de autoridad crm:vehicles:create |
| `404 Not Found` | `CustomerNotFoundException` | El cliente especificado en initialOwnerId no existe en este taller |
| `409 Conflict` | `VehiclePlateAlreadyExistsException` | Ya existe un vehiculo registrado a nivel nacional con la placa indicada |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/vehicle-plate-exists",
  "title": "Placa de Rodaje Ya Registrada",
  "status": 409,
  "detail": "La placa ABC123 ya se encuentra registrada en el catalogo universal de vehiculos",
  "instance": "/api/v1/crm/vehicles",
  "code": "VEHICLE_PLATE_ALREADY_EXISTS",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 3.3. [GET] /api/v1/crm/vehicles/{id}

**Ficha Tecnica Integral de Vehiculo por Identificador**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.VehiclesController`
- **Metodo Java:** `public ResponseEntity<VehicleResource> getVehicleById(@PathVariable UUID id)`
- **Ruta Base:** `/api/v1/crm/vehicles`
- **Ruta Completa:** `/api/v1/crm/vehicles/{id}`
- **Proposito:** Consulta los datos tecnicos completos de la unidad vehicular por su identificador universal. Proyecta placa, numero de chasis, motorizacion, odometro consolidado y los datos del custodio legal vigente.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Tecnico Mecanico (ROLE_MECHANIC), Asesor de Servicio o Recepcionista
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:vehicles:read')")`
- **Aislamiento Multi-Inquilino:** Activo global consultable para operaciones de recepcion e ingreso a bahia.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Si | Identificador universal del vehiculo |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.VehicleResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador universal del automovil |
| `plate` | `String` | Placa oficial de rodaje |
| `vin` | `String` | Numero de chasis VIN |
| `brand` | `String` | Marca automotriz |
| `model` | `String` | Modelo del vehiculo |
| `year` | `int` | Ano de fabricacion |
| `engineType` | `String` | Motorizacion |
| `currentMileage` | `Integer` | Ultimo kilometraje registrado |
| `currentOwnerId` | `UUID` | Identificador del propietario vigente |
| `currentOwnerName` | `String` | Nombre del propietario vigente |
| `createdAt` | `Instant` | Fecha de registro original |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c50-7e12-7000-8000-000000000010",
  "plate": "ABC123",
  "vin": "9BD11122233344455",
  "brand": "Toyota",
  "model": "Corolla Sedan",
  "year": 2021,
  "engineType": "GASOLINE",
  "currentMileage": 45200,
  "currentOwnerId": "018f6c50-7e12-7000-8000-000000000001",
  "currentOwnerName": "Juan Jose Perez Rodriguez",
  "createdAt": "2026-10-01T16:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Permiso crm:vehicles:read insuficiente |
| `404 Not Found` | `VehicleNotFoundException` | Vehiculo no localizado con el identificador proporcionado |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/vehicle-not-found",
  "title": "Vehiculo No Encontrado",
  "status": 404,
  "detail": "No se encontro ningun vehiculo registrado con el identificador 018f6c50-7e12-7000-8000-000000000010",
  "instance": "/api/v1/crm/vehicles/018f6c50-7e12-7000-8000-000000000010",
  "code": "VEHICLE_NOT_FOUND",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 3.4. [PUT] /api/v1/crm/vehicles/{id}

**Actualizacion de Especificaciones Tecnicas y Motorizacion**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.VehiclesController`
- **Metodo Java:** `public ResponseEntity<VehicleResource> updateVehicle(@PathVariable UUID id, @Valid @RequestBody UpdateVehicleResource resource)`
- **Ruta Base:** `/api/v1/crm/vehicles`
- **Ruta Completa:** `/api/v1/crm/vehicles/{id}`
- **Proposito:** Actualiza los atributos tecnicos del automovil (marca, modelo, ano de fabricacion, motorizacion y VIN). La placa de rodaje se mantiene estrictamente inmutable para salvaguardar la cadena ininterrumpida de custodia legal.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:vehicles:update')")`
- **Aislamiento Multi-Inquilino:** Opera sobre el activo vehicular universal validando que el taller posea custodia vigente o historica.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Si | Identificador universal del automovil a modificar |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.requests.UpdateVehicleResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `brand` | `String` | Si | `@NotBlank, @Size(max = 50)` | Marca automotriz |
| `model` | `String` | Si | `@NotBlank, @Size(max = 50)` | Modelo de la unidad |
| `year` | `int` | Si | `@NotNull, @Min(1950), @Max(2030)` | Ano de fabricacion |
| `engineType` | `String` | Si | `@NotBlank, @Pattern(regexp = "^(GASOLINE|DIESEL|ELECTRIC|HYBRID)$")` | Tipo de combustible |
| `vin` | `String` | No | `@Pattern(regexp = "^[A-HJ-NPR-Z0-9]{17}$")` | Numero de serie de chasis (VIN ISO 3779) |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "brand": "Toyota",
  "model": "Corolla Altis",
  "year": 2021,
  "engineType": "HYBRID",
  "vin": "9BD11122233344455"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.VehicleResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del vehiculo |
| `plate` | `String` | Placa inmutable |
| `vin` | `String` | VIN actualizado |
| `brand` | `String` | Marca actualizada |
| `model` | `String` | Modelo actualizado |
| `year` | `int` | Ano actualizado |
| `engineType` | `String` | Motorizacion actualizada |
| `currentMileage` | `Integer` | Kilometraje actual |
| `currentOwnerId` | `UUID` | Titular vigente |
| `currentOwnerName` | `String` | Nombre del titular |
| `createdAt` | `Instant` | Fecha de alta original |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c50-7e12-7000-8000-000000000010",
  "plate": "ABC123",
  "vin": "9BD11122233344455",
  "brand": "Toyota",
  "model": "Corolla Altis",
  "year": 2021,
  "engineType": "HYBRID",
  "currentMileage": 45200,
  "currentOwnerId": "018f6c50-7e12-7000-8000-000000000001",
  "currentOwnerName": "Juan Jose Perez Rodriguez",
  "createdAt": "2026-10-01T16:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Ano fuera de rango o tipo de motorizacion no reconocido |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Falta del permiso crm:vehicles:update |
| `404 Not Found` | `VehicleNotFoundException` | Vehiculo no encontrado |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-request-payload",
  "title": "Especificaciones Invalidas",
  "status": 400,
  "detail": "El tipo de motorizacion ingresado no corresponde a ninguna de las opciones permitidas",
  "instance": "/api/v1/crm/vehicles/018f6c50-7e12-7000-8000-000000000010",
  "code": "INVALID_REQUEST_PAYLOAD",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 3.5. [GET] /api/v1/crm/vehicles/by-plate/{plate}

**Busqueda Rapida de Automotor por Placa de Rodaje Nacional**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.VehiclesController`
- **Metodo Java:** `public ResponseEntity<VehicleResource> getVehicleByPlate(@PathVariable String plate)`
- **Ruta Base:** `/api/v1/crm/vehicles`
- **Ruta Completa:** `/api/v1/crm/vehicles/by-plate/{plate}`
- **Proposito:** Permite al recepcionista o mecanico buscar un automovil ingresando su placa de rodaje. Normaliza la cadena removiendo espacios y guiones y convirtiendola a mayusculas para ejecutar una busqueda O(1) sobre el indice B-Tree unico.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Tecnico Mecanico (ROLE_MECHANIC) o Recepcionista (ROLE_RECEPTIONIST)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:vehicles:read')")`
- **Aislamiento Multi-Inquilino:** Consulta sobre el padron universal automotriz.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `plate` | `String` | Si | Placa de rodaje normalizada de 6 caracteres alfanumericos (ej. ABC123) |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.VehicleResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del vehiculo |
| `plate` | `String` | Placa de rodaje coincidente |
| `vin` | `String` | Numero de chasis VIN |
| `brand` | `String` | Marca automotriz |
| `model` | `String` | Modelo del vehiculo |
| `year` | `int` | Ano de fabricacion |
| `engineType` | `String` | Motorizacion |
| `currentMileage` | `Integer` | Kilometraje reportado |
| `currentOwnerId` | `UUID` | Identificador del propietario vigente |
| `currentOwnerName` | `String` | Nombre del propietario |
| `createdAt` | `Instant` | Fecha de registro |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c50-7e12-7000-8000-000000000010",
  "plate": "ABC123",
  "vin": "9BD11122233344455",
  "brand": "Toyota",
  "model": "Corolla Sedan",
  "year": 2021,
  "engineType": "GASOLINE",
  "currentMileage": 45200,
  "currentOwnerId": "018f6c50-7e12-7000-8000-000000000001",
  "currentOwnerName": "Juan Jose Perez Rodriguez",
  "createdAt": "2026-10-01T16:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `IllegalArgumentException` | Formato de placa invalido (longitud distinta a 6 caracteres) |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Permiso crm:vehicles:read insuficiente |
| `404 Not Found` | `VehicleNotFoundException` | No existe ningun vehiculo registrado con la placa especificada |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/vehicle-not-found",
  "title": "Vehiculo No Localizado",
  "status": 404,
  "detail": "No se encontro ningun automotor registrado con la placa de rodaje ABC123",
  "instance": "/api/v1/crm/vehicles/by-plate/ABC123",
  "code": "VEHICLE_NOT_FOUND",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 3.6. [GET] /api/v1/crm/vehicles/by-vin/{vin}

**Busqueda de Automotor por Numero de Identificacion Vehicular**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.VehiclesController`
- **Metodo Java:** `public ResponseEntity<VehicleResource> getVehicleByVin(@PathVariable String vin)`
- **Ruta Base:** `/api/v1/crm/vehicles`
- **Ruta Completa:** `/api/v1/crm/vehicles/by-vin/{vin}`
- **Proposito:** Consulta y recupera los datos de un automotor utilizando su numero de chasis VIN estandarizado segun ISO 3779. Esencial para peritajes tecnicos y cotejo contra las lecturas computarizadas del escanner OBD-II.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Tecnico Mecanico (ROLE_MECHANIC) o Asesor de Servicio
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:vehicles:read')")`
- **Aislamiento Multi-Inquilino:** Busqueda sobre el registro universal de vehiculos.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `vin` | `String` | Si | Numero de chasis VIN de 17 caracteres alfanumericos (ISO 3779) |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.VehicleResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del vehiculo |
| `plate` | `String` | Placa oficial de rodaje |
| `vin` | `String` | VIN localizado |
| `brand` | `String` | Marca automotriz |
| `model` | `String` | Modelo del vehiculo |
| `year` | `int` | Ano de fabricacion |
| `engineType` | `String` | Tipo de combustible |
| `currentMileage` | `Integer` | Kilometraje reportado |
| `currentOwnerId` | `UUID` | Titular vigente |
| `currentOwnerName` | `String` | Nombre del titular |
| `createdAt` | `Instant` | Fecha de registro |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c50-7e12-7000-8000-000000000010",
  "plate": "ABC123",
  "vin": "9BD11122233344455",
  "brand": "Toyota",
  "model": "Corolla Sedan",
  "year": 2021,
  "engineType": "GASOLINE",
  "currentMileage": 45200,
  "currentOwnerId": "018f6c50-7e12-7000-8000-000000000001",
  "currentOwnerName": "Juan Jose Perez Rodriguez",
  "createdAt": "2026-10-01T16:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `IllegalArgumentException` | El VIN no posee exactamente 17 caracteres o contiene letras prohibidas (I, O, Q) |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Falta del permiso crm:vehicles:read |
| `404 Not Found` | `VehicleNotFoundException` | No se encontro ningun automovil con el VIN indicado |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/vehicle-not-found",
  "title": "VIN No Registrado",
  "status": 404,
  "detail": "No se encontro ningun vehiculo registrado con el VIN 9BD11122233344455",
  "instance": "/api/v1/crm/vehicles/by-vin/9BD11122233344455",
  "code": "VEHICLE_NOT_FOUND",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 3.7. [PUT] /api/v1/crm/vehicles/{id}/mileage

**Actualizacion de Lectura de Odometro y Kilometraje**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.VehiclesController`
- **Metodo Java:** `public ResponseEntity<VehicleResource> updateMileage(@PathVariable UUID id, @Valid @RequestBody UpdateMileageResource resource)`
- **Ruta Base:** `/api/v1/crm/vehicles`
- **Ruta Completa:** `/api/v1/crm/vehicles/{id}/mileage`
- **Proposito:** Registra una nueva lectura de kilometraje para el automotor capturada durante la recepcion pericial o extraida mediante telemetria OBD-II. Valida la invariante de no regresion para impedir alteraciones fraudulentas de odometro.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Tecnico Mecanico (ROLE_MECHANIC) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:vehicles:update')")`
- **Aislamiento Multi-Inquilino:** Actualiza el odometro dentro del contexto de atencion del taller.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Si | Identificador del vehiculo |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.requests.UpdateMileageResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `mileage` | `Integer` | Si | `@NotNull, @Min(0)` | Nueva lectura de kilometraje en unidades enteras |
| `recordedAt` | `String` | Si | `@NotBlank` | Marca temporal en formato ISO 8601 UTC en que se tomo la lectura |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "mileage": 48500,
  "recordedAt": "2026-10-01T16:30:00Z"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.VehicleResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del vehiculo |
| `plate` | `String` | Placa oficial de rodaje |
| `vin` | `String` | Numero de chasis VIN |
| `brand` | `String` | Marca automotriz |
| `model` | `String` | Modelo del vehiculo |
| `year` | `int` | Ano de fabricacion |
| `engineType` | `String` | Motorizacion |
| `currentMileage` | `Integer` | Kilometraje actualizado (48500 km) |
| `currentOwnerId` | `UUID` | Titular vigente |
| `currentOwnerName` | `String` | Nombre del titular |
| `createdAt` | `Instant` | Fecha de creacion |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c50-7e12-7000-8000-000000000010",
  "plate": "ABC123",
  "vin": "9BD11122233344455",
  "brand": "Toyota",
  "model": "Corolla Sedan",
  "year": 2021,
  "engineType": "GASOLINE",
  "currentMileage": 48500,
  "currentOwnerId": "018f6c50-7e12-7000-8000-000000000001",
  "currentOwnerName": "Juan Jose Perez Rodriguez",
  "createdAt": "2026-10-01T16:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Kilometraje negativo o marca temporal en formato invalido |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Falta del permiso crm:vehicles:update |
| `404 Not Found` | `VehicleNotFoundException` | Vehiculo no localizado |
| `422 Unprocessable Entity` | `InvalidMileageException` | El kilometraje ingresado es menor al kilometraje historico previamente registrado (invariante de no regresion) |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-mileage-regression",
  "title": "Regresion de Odometro Detectada",
  "status": 422,
  "detail": "La lectura ingresada (40000 km) es inferior al ultimo kilometraje verificado (45200 km)",
  "instance": "/api/v1/crm/vehicles/018f6c50-7e12-7000-8000-000000000010/mileage",
  "code": "MILEAGE_LOWER_THAN_PREVIOUS",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 3.8. [POST] /api/v1/crm/vehicles/{id}/transfer-ownership

**Traspaso Formal de Custodia o Titularidad Vehicular**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.VehiclesController`
- **Metodo Java:** `public ResponseEntity<VehicleResource> transferOwnership(@PathVariable UUID id, @Valid @RequestBody TransferOwnershipResource resource)`
- **Ruta Base:** `/api/v1/crm/vehicles`
- **Ruta Completa:** `/api/v1/crm/vehicles/{id}/transfer-ownership`
- **Proposito:** Formaliza la transferencia de custodia o titularidad automotriz hacia un nuevo cliente comercial. Cierra la tenencia previa en la tabla vehicle_ownerships estampando la fecha de fin e inaugura un nuevo periodo activo sin fecha de culminacion.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Administrador de Taller
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:vehicles:update')")`
- **Aislamiento Multi-Inquilino:** Verifica que el nuevo titular (newOwnerId) este registrado como cliente en el taller activo.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Si | Identificador del vehiculo cuya titularidad se transfiere |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.requests.TransferOwnershipResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `newOwnerId` | `UUID` | Si | `@NotNull` | Identificador del nuevo cliente titular que adquiere la custodia |
| `transferDate` | `LocalDate` | Si | `@NotNull` | Fecha formal del traspaso (formato ISO YYYY-MM-DD) |
| `reason` | `String` | No | `@Size(max = 255)` | Motivo descriptivo del traspaso (ej. compraventa, cesion corporativa) |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "newOwnerId": "018f6c50-7e12-7000-8000-000000000002",
  "transferDate": "2026-10-01",
  "reason": "Venta y cesion formal de flota particular a corporativa"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.VehicleResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del vehiculo |
| `plate` | `String` | Placa oficial de rodaje |
| `vin` | `String` | Numero de chasis VIN |
| `brand` | `String` | Marca automotriz |
| `model` | `String` | Modelo del vehiculo |
| `year` | `int` | Ano de fabricacion |
| `engineType` | `String` | Motorizacion |
| `currentMileage` | `Integer` | Kilometraje registrado |
| `currentOwnerId` | `UUID` | Nuevo titular asignado tras la transferencia |
| `currentOwnerName` | `String` | Razon social o nombre del nuevo titular |
| `createdAt` | `Instant` | Fecha de creacion original |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c50-7e12-7000-8000-000000000010",
  "plate": "ABC123",
  "vin": "9BD11122233344455",
  "brand": "Toyota",
  "model": "Corolla Sedan",
  "year": 2021,
  "engineType": "GASOLINE",
  "currentMileage": 48500,
  "currentOwnerId": "018f6c50-7e12-7000-8000-000000000002",
  "currentOwnerName": "TRANSPORTES Y LOGISTICA LIMA NORTE S.A.C.",
  "createdAt": "2026-10-01T16:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `VehicleAlreadyOwnedException` | El cliente especificado ya es el custodio vigente del vehiculo |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Permiso insuficiente para transferir titularidad |
| `404 Not Found` | `VehicleNotFoundException` | Vehiculo no encontrado |
| `404 Not Found` | `CustomerNotFoundException` | El nuevo cliente titular no existe en este taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/vehicle-already-owned",
  "title": "Traspaso Invalido",
  "status": 400,
  "detail": "El vehiculo ya se encuentra registrado bajo la titularidad de este cliente",
  "instance": "/api/v1/crm/vehicles/018f6c50-7e12-7000-8000-000000000010/transfer-ownership",
  "code": "VEHICLE_ALREADY_OWNED_BY_CUSTOMER",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

## 4. Endpoints de Flotas Comerciales B2B (FleetsController)

### 4.1. [GET] /api/v1/crm/fleets

**Listado de Flotas Corporativas Comerciales del Taller**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.FleetsController`
- **Metodo Java:** `public ResponseEntity<List<FleetResource>> getFleets()`
- **Ruta Base:** `/api/v1/crm/fleets`
- **Ruta Completa:** `/api/v1/crm/fleets`
- **Proposito:** Retorna el catalogo integro de cuentas de flotas comerciales corporativas (B2B) atendidas por el taller automotriz. Expone la empresa titular, el conteo total de vehiculos afiliados, los datos del gestor logistico institucional y el estado operativo del convenio.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Administrador de Taller
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:fleets:manage')")`
- **Aislamiento Multi-Inquilino:** Filtra de manera estricta por el tenantId del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `List<com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.FleetResource>`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador universal de la cuenta de flota |
| `tenantId` | `UUID` | Identificador del taller titular |
| `customerId` | `UUID` | Identificador de la empresa cliente propietaria |
| `name` | `String` | Denominacion de la flota o division corporativa |
| `corporateTaxId` | `String` | RUC de la empresa titular |
| `contactPerson` | `String` | Nombres del gestor de flota o supervisor de operaciones |
| `contactEmail` | `String` | Correo electronico de contacto del gestor |
| `contactPhone` | `String` | Telefono directo del gestor |
| `vehicleCount` | `int` | Cantidad total de vehiculos vinculados a la flota |
| `status` | `String` | Estado de la cuenta corporativa (ACTIVE o SUSPENDED) |
| `createdAt` | `Instant` | Marca temporal de registro en UTC |

**Ejemplo de Carga Util JSON (Response):**
```json
[
  {
    "id": "018f6c50-7e12-7000-8000-000000000020",
    "tenantId": "018f6c40-7e12-7000-8000-000000000001",
    "customerId": "018f6c50-7e12-7000-8000-000000000002",
    "name": "Flota Distribucion Metropolitana",
    "corporateTaxId": "20554433221",
    "contactPerson": "Ing. Miguel Angel Soto Valdivia",
    "contactEmail": "msoto@transporteslimanorte.pe",
    "contactPhone": "+51988112233",
    "vehicleCount": 12,
    "status": "ACTIVE",
    "createdAt": "2026-10-01T16:30:00Z"
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Falta del permiso crm:fleets:manage |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/access-denied",
  "title": "Permisos Insuficientes",
  "status": 403,
  "detail": "Se requiere la autoridad crm:fleets:manage para administrar cuentas de flotas comerciales",
  "instance": "/api/v1/crm/fleets",
  "code": "ACCESS_DENIED",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 4.2. [POST] /api/v1/crm/fleets

**Creacion de Cuenta de Flota Corporativa B2B**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.FleetsController`
- **Metodo Java:** `public ResponseEntity<FleetResource> createFleet(@Valid @RequestBody CreateFleetResource resource)`
- **Ruta Base:** `/api/v1/crm/fleets`
- **Ruta Completa:** `/api/v1/crm/fleets`
- **Proposito:** Registra una nueva cuenta de flota comercial vinculada a una empresa cliente (tipo COMPANY). Permite formalizar acuerdos de facturacion mensual, atencion prioritaria en bahia y tarifas corporativas preacordadas.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Administrador de Taller
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:fleets:manage')")`
- **Aislamiento Multi-Inquilino:** Asigna el tenantId en sesion y valida que la empresa pertenezca a la cartera del taller.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.requests.CreateFleetResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `customerId` | `UUID` | Si | `@NotNull` | Identificador de la empresa cliente (debe ser de tipo COMPANY) |
| `name` | `String` | Si | `@NotBlank, @Size(max = 100)` | Nombre de la flota corporativa (ej. Flota Reparto Callao) |
| `contactPerson` | `String` | Si | `@NotBlank, @Size(max = 100)` | Nombres del responsable de logistica de la empresa |
| `contactEmail` | `String` | Si | `@NotBlank, @Email, @Size(max = 150)` | Correo electronico de contacto del supervisor |
| `contactPhone` | `String` | Si | `@NotBlank, @Pattern(regexp = "^\+?[0-9]{9,15}$")` | Telefono directo del supervisor |
| `notes` | `String` | No | `@Size(max = 500)` | Notas comerciales o condiciones especiales pactadas |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "customerId": "018f6c50-7e12-7000-8000-000000000002",
  "name": "Flota Distribucion Metropolitana",
  "contactPerson": "Ing. Miguel Angel Soto Valdivia",
  "contactEmail": "msoto@transporteslimanorte.pe",
  "contactPhone": "+51988112233",
  "notes": "Tarifa preferencial de mano de obra con 15 por ciento de descuento corporativo"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.FleetResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la flota creada |
| `tenantId` | `UUID` | Identificador del taller |
| `customerId` | `UUID` | Identificador de la empresa titular |
| `name` | `String` | Nombre de la flota |
| `corporateTaxId` | `String` | RUC de la empresa cliente |
| `contactPerson` | `String` | Responsable de flota |
| `contactEmail` | `String` | Correo del responsable |
| `contactPhone` | `String` | Telefono del responsable |
| `vehicleCount` | `int` | Vehiculos iniciales (0) |
| `status` | `String` | Estado inicial (ACTIVE) |
| `createdAt` | `Instant` | Marca temporal de alta en UTC |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c50-7e12-7000-8000-000000000020",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "customerId": "018f6c50-7e12-7000-8000-000000000002",
  "name": "Flota Distribucion Metropolitana",
  "corporateTaxId": "20554433221",
  "contactPerson": "Ing. Miguel Angel Soto Valdivia",
  "contactEmail": "msoto@transporteslimanorte.pe",
  "contactPhone": "+51988112233",
  "vehicleCount": 0,
  "status": "ACTIVE",
  "createdAt": "2026-10-01T16:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Campos obligatorios ausentes o formato de correo invalido |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Falta de autoridad crm:fleets:manage |
| `404 Not Found` | `CustomerNotFoundException` | La empresa cliente especificada no existe en el taller |
| `409 Conflict` | `FleetAlreadyExistsException` | Ya existe una flota registrada con esa misma denominacion para esta empresa |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/fleet-already-exists",
  "title": "Flota Ya Registrada",
  "status": 409,
  "detail": "La empresa ya registra una flota con el nombre Flota Distribucion Metropolitana",
  "instance": "/api/v1/crm/fleets",
  "code": "FLEET_ALREADY_EXISTS_FOR_CUSTOMER",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 4.3. [GET] /api/v1/crm/fleets/{id}

**Detalle de Cuenta de Flota Corporativa por Identificador**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.FleetsController`
- **Metodo Java:** `public ResponseEntity<FleetResource> getFleetById(@PathVariable UUID id)`
- **Ruta Base:** `/api/v1/crm/fleets`
- **Ruta Completa:** `/api/v1/crm/fleets/{id}`
- **Proposito:** Consulta los datos de gestion de una flota corporativa especifica, incluyendo canales de atencion del supervisor, cantidad de unidades adscritas y estado operativo.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Administrador
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:fleets:manage')")`
- **Aislamiento Multi-Inquilino:** Verifica que la flota pertenezca estrictamente al taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Si | Identificador universal de la cuenta de flota |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.FleetResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la flota |
| `tenantId` | `UUID` | Identificador del taller |
| `customerId` | `UUID` | Identificador de la empresa cliente |
| `name` | `String` | Nombre de la flota |
| `corporateTaxId` | `String` | RUC de la empresa |
| `contactPerson` | `String` | Responsable de la flota |
| `contactEmail` | `String` | Correo del responsable |
| `contactPhone` | `String` | Telefono de contacto |
| `vehicleCount` | `int` | Cantidad de automotores asignados |
| `status` | `String` | Estado de la cuenta corporativa |
| `createdAt` | `Instant` | Marca temporal de registro |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c50-7e12-7000-8000-000000000020",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "customerId": "018f6c50-7e12-7000-8000-000000000002",
  "name": "Flota Distribucion Metropolitana",
  "corporateTaxId": "20554433221",
  "contactPerson": "Ing. Miguel Angel Soto Valdivia",
  "contactEmail": "msoto@transporteslimanorte.pe",
  "contactPhone": "+51988112233",
  "vehicleCount": 12,
  "status": "ACTIVE",
  "createdAt": "2026-10-01T16:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Falta del permiso crm:fleets:manage |
| `404 Not Found` | `FleetNotFoundException` | Cuenta de flota no encontrada en este taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/fleet-not-found",
  "title": "Flota No Encontrada",
  "status": 404,
  "detail": "No se encontro ninguna flota corporativa con el identificador 018f6c50-7e12-7000-8000-000000000020",
  "instance": "/api/v1/crm/fleets/018f6c50-7e12-7000-8000-000000000020",
  "code": "FLEET_NOT_FOUND",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 4.4. [PUT] /api/v1/crm/fleets/{id}

**Actualizacion de Datos Corporativos de Flota**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.FleetsController`
- **Metodo Java:** `public ResponseEntity<FleetResource> updateFleet(@PathVariable UUID id, @Valid @RequestBody UpdateFleetResource resource)`
- **Ruta Base:** `/api/v1/crm/fleets`
- **Ruta Completa:** `/api/v1/crm/fleets/{id}`
- **Proposito:** Actualiza los canales de contacto institucional, el supervisor operativo o las notas del acuerdo corporativo de la flota comercial.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Administrador de Taller
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:fleets:manage')")`
- **Aislamiento Multi-Inquilino:** Verifica pertenencia de la flota al tenantId del token en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Si | Identificador de la flota a actualizar |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.requests.UpdateFleetResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `name` | `String` | Si | `@NotBlank, @Size(max = 100)` | Nombre actualizado de la flota |
| `contactPerson` | `String` | Si | `@NotBlank, @Size(max = 100)` | Responsable actualizado |
| `contactEmail` | `String` | Si | `@NotBlank, @Email, @Size(max = 150)` | Correo actualizado |
| `contactPhone` | `String` | Si | `@NotBlank, @Pattern(regexp = "^\+?[0-9]{9,15}$")` | Telefono actualizado |
| `notes` | `String` | No | `@Size(max = 500)` | Notas comerciales o de convenio |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "name": "Flota Distribucion Lima y Callao",
  "contactPerson": "Ing. Miguel Angel Soto Valdivia",
  "contactEmail": "msoto@transporteslimanorte.pe",
  "contactPhone": "+51988112299",
  "notes": "Tarifa preferencial actualizada con pago a 30 dias previa emision de factura electronica"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.FleetResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la flota |
| `tenantId` | `UUID` | Identificador del taller |
| `customerId` | `UUID` | Identificador de la empresa |
| `name` | `String` | Nombre actualizado |
| `corporateTaxId` | `String` | RUC de la empresa |
| `contactPerson` | `String` | Responsable actualizado |
| `contactEmail` | `String` | Correo actualizado |
| `contactPhone` | `String` | Telefono actualizado |
| `vehicleCount` | `int` | Cantidad de automotores |
| `status` | `String` | Estado operativo |
| `createdAt` | `Instant` | Fecha de creacion original |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c50-7e12-7000-8000-000000000020",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "customerId": "018f6c50-7e12-7000-8000-000000000002",
  "name": "Flota Distribucion Lima y Callao",
  "corporateTaxId": "20554433221",
  "contactPerson": "Ing. Miguel Angel Soto Valdivia",
  "contactEmail": "msoto@transporteslimanorte.pe",
  "contactPhone": "+51988112299",
  "vehicleCount": 12,
  "status": "ACTIVE",
  "createdAt": "2026-10-01T16:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Campos obligatorios vacios o sintaxis de correo invalida |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Permiso crm:fleets:manage insuficiente |
| `404 Not Found` | `FleetNotFoundException` | Flota no encontrada |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-request-payload",
  "title": "Actualizacion Invalida",
  "status": 400,
  "detail": "El formato del correo electronico proporcionado no cumple con el estandar RFC 5322",
  "instance": "/api/v1/crm/fleets/018f6c50-7e12-7000-8000-000000000020",
  "code": "INVALID_REQUEST_PAYLOAD",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 4.5. [POST] /api/v1/crm/fleets/{id}/vehicles

**Vinculacion de Vehiculo a la Flota Comercial**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.FleetsController`
- **Metodo Java:** `public ResponseEntity<FleetResource> addVehicleToFleet(@PathVariable UUID id, @Valid @RequestBody AddVehicleToFleetResource resource)`
- **Ruta Base:** `/api/v1/crm/fleets`
- **Ruta Completa:** `/api/v1/crm/fleets/{id}/vehicles`
- **Proposito:** Incorpora una unidad automotriz al padron operativo de la flota comercial, asociandole opcionalmente un identificador o codigo interno empresarial de unidad (ej. MOVIL-04) para facilitar el control de ruta.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Administrador de Taller
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:fleets:manage')")`
- **Aislamiento Multi-Inquilino:** Comprueba que la flota pertenezca al taller en sesion y que el vehiculo exista en el catalogo.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Si | Identificador de la flota a la que se anade el automovil |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.requests.AddVehicleToFleetResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `vehicleId` | `UUID` | Si | `@NotNull` | Identificador del vehiculo a incorporar a la flota |
| `internalFleetCode` | `String` | No | `@Size(max = 30)` | Codigo o identificador interno de la empresa (ej. MOVIL-12) |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "vehicleId": "018f6c50-7e12-7000-8000-000000000010",
  "internalFleetCode": "MOVIL-12"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.FleetResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la flota |
| `tenantId` | `UUID` | Identificador del taller |
| `customerId` | `UUID` | Identificador de la empresa titular |
| `name` | `String` | Nombre de la flota |
| `corporateTaxId` | `String` | RUC de la empresa |
| `contactPerson` | `String` | Responsable de flota |
| `contactEmail` | `String` | Correo del responsable |
| `contactPhone` | `String` | Telefono del responsable |
| `vehicleCount` | `int` | Total de vehiculos actualizado (incrementado en 1) |
| `status` | `String` | Estado de la cuenta |
| `createdAt` | `Instant` | Fecha de creacion |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c50-7e12-7000-8000-000000000020",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "customerId": "018f6c50-7e12-7000-8000-000000000002",
  "name": "Flota Distribucion Metropolitana",
  "corporateTaxId": "20554433221",
  "contactPerson": "Ing. Miguel Angel Soto Valdivia",
  "contactEmail": "msoto@transporteslimanorte.pe",
  "contactPhone": "+51988112233",
  "vehicleCount": 13,
  "status": "ACTIVE",
  "createdAt": "2026-10-01T16:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | vehicleId ausente o en blanco |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Falta del permiso crm:fleets:manage |
| `404 Not Found` | `FleetNotFoundException` | Flota no encontrada |
| `404 Not Found` | `VehicleNotFoundException` | El vehiculo especificado no existe en el sistema |
| `409 Conflict` | `VehicleAlreadyInFleetException` | El vehiculo ya se encuentra adscrito a esta flota corporativa |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/vehicle-already-in-fleet",
  "title": "Vehiculo Ya Afiliado",
  "status": 409,
  "detail": "El vehiculo con identificador 018f6c50-7e12-7000-8000-000000000010 ya forma parte de esta flota",
  "instance": "/api/v1/crm/fleets/018f6c50-7e12-7000-8000-000000000020/vehicles",
  "code": "VEHICLE_ALREADY_IN_FLEET",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 4.6. [DELETE] /api/v1/crm/fleets/{id}/vehicles/{vehicleId}

**Desvinculacion de Unidad Vehicular de la Flota Corporativa**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.FleetsController`
- **Metodo Java:** `public ResponseEntity<Void> removeVehicleFromFleet(@PathVariable UUID id, @PathVariable UUID vehicleId)`
- **Ruta Base:** `/api/v1/crm/fleets`
- **Ruta Completa:** `/api/v1/crm/fleets/{id}/vehicles/{vehicleId}`
- **Proposito:** Retira una unidad vehicular del padron de la flota corporativa cuando es dada de baja, vendida o reasignada por la empresa titular.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Administrador de Taller
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:fleets:manage')")`
- **Aislamiento Multi-Inquilino:** Verifica pertenencia de la flota al taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Si | Identificador de la flota corporativa |
| `vehicleId` | `UUID` | Si | Identificador del vehiculo a desvincular |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `204 No Content`
Sin cuerpo de respuesta en la carga util.

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Falta del permiso crm:fleets:manage |
| `404 Not Found` | `FleetNotFoundException` | Flota no encontrada |
| `404 Not Found` | `FleetVehicleNotFoundException` | El vehiculo no pertenece a la flota especificada |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/fleet-vehicle-not-found",
  "title": "Unidad No Vinculada",
  "status": 404,
  "detail": "El vehiculo especificado no se encuentra registrado en el padron de esta flota",
  "instance": "/api/v1/crm/fleets/018f6c50-7e12-7000-8000-000000000020/vehicles/018f6c50-7e12-7000-8000-000000000010",
  "code": "FLEET_VEHICLE_NOT_FOUND",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

## 5. Endpoints de Bitacora y Notas de Cliente (CustomerNotesController)

### 5.1. [GET] /api/v1/crm/customers/{customerId}/notes

**Listado Cronologico de Notas y Observaciones de Bitacora**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.CustomerNotesController`
- **Metodo Java:** `public ResponseEntity<List<CustomerNoteResource>> getCustomerNotes(@PathVariable UUID customerId)`
- **Ruta Base:** `/api/v1/crm/customers`
- **Ruta Completa:** `/api/v1/crm/customers/{customerId}/notes`
- **Proposito:** Recupera la coleccion cronologica inmutable de notas, apreciaciones cualitativas, acuerdos de trato preferencial y recordatorios comerciales formulados por el equipo sobre el cliente.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST) o Asesor de Servicio
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:customers:read')")`
- **Aislamiento Multi-Inquilino:** Comprueba que el cliente pertenezca al taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `customerId` | `UUID` | Si | Identificador universal del cliente |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `List<com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.CustomerNoteResource>`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la nota de bitacora |
| `customerId` | `UUID` | Identificador del cliente observado |
| `authorUserId` | `UUID` | Identificador del colaborador autor de la nota |
| `authorName` | `String` | Nombre completo del colaborador autor |
| `content` | `String` | Texto descriptivo de la observacion |
| `category` | `String` | Categoria de la nota (SERVICE, BILLING, PREFERENCE o GENERAL) |
| `createdAt` | `Instant` | Marca temporal de registro en UTC |

**Ejemplo de Carga Util JSON (Response):**
```json
[
  {
    "id": "018f6c50-7e12-7000-8000-000000000030",
    "customerId": "018f6c50-7e12-7000-8000-000000000001",
    "authorUserId": "018f6c40-7e12-7000-8000-000000000002",
    "authorName": "Carlos Alberto Mendoza Flores",
    "content": "Cliente solicita recepcion prioritaria a primera hora los dias sabados. Exige lubricante sintetico 5W-30 especificacion Dexos 1",
    "category": "PREFERENCE",
    "createdAt": "2026-10-01T16:30:00Z"
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Falta del permiso crm:customers:read |
| `404 Not Found` | `CustomerNotFoundException` | Cliente no encontrado en este taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/customer-not-found",
  "title": "Cliente No Encontrado",
  "status": 404,
  "detail": "No existe ningun cliente registrado con el identificador 018f6c50-7e12-7000-8000-000000000001",
  "instance": "/api/v1/crm/customers/018f6c50-7e12-7000-8000-000000000001/notes",
  "code": "CUSTOMER_NOT_FOUND",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 5.2. [POST] /api/v1/crm/customers/{customerId}/notes

**Incorporacion de Nueva Nota u Observacion de Servicio en Bitacora**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.CustomerNotesController`
- **Metodo Java:** `public ResponseEntity<CustomerNoteResource> createCustomerNote(@PathVariable UUID customerId, @Valid @RequestBody CreateCustomerNoteResource resource)`
- **Ruta Base:** `/api/v1/crm/customers`
- **Ruta Completa:** `/api/v1/crm/customers/{customerId}/notes`
- **Proposito:** Agrega una nueva nota cualitativa a la ficha del cliente. Asocia de forma automatica e inmutable la identidad del autor (authorUserId y authorName) extraida directamente del token JWT autenticado.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:customers:update')")`
- **Aislamiento Multi-Inquilino:** Verifica pertenencia del cliente al tenantId en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `customerId` | `UUID` | Si | Identificador del cliente a quien se adjunta la nota |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.requests.CreateCustomerNoteResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `content` | `String` | Si | `@NotBlank, @Size(max = 1000)` | Cuerpo de la observacion o recordatorio |
| `category` | `String` | Si | `@NotBlank, @Pattern(regexp = "^(SERVICE|BILLING|PREFERENCE|GENERAL)$")` | Clasificacion tematica de la nota |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "content": "Cliente solicita recepcion prioritaria a primera hora los dias sabados. Exige lubricante sintetico 5W-30 especificacion Dexos 1",
  "category": "PREFERENCE"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.CustomerNoteResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador asignado a la nueva nota |
| `customerId` | `UUID` | Identificador del cliente |
| `authorUserId` | `UUID` | Identificador del usuario autor |
| `authorName` | `String` | Nombre resuelto del usuario autor |
| `content` | `String` | Contenido de la nota |
| `category` | `String` | Categoria de la observacion |
| `createdAt` | `Instant` | Marca temporal de registro en UTC |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c50-7e12-7000-8000-000000000030",
  "customerId": "018f6c50-7e12-7000-8000-000000000001",
  "authorUserId": "018f6c40-7e12-7000-8000-000000000002",
  "authorName": "Carlos Alberto Mendoza Flores",
  "content": "Cliente solicita recepcion prioritaria a primera hora los dias sabados. Exige lubricante sintetico 5W-30 especificacion Dexos 1",
  "category": "PREFERENCE",
  "createdAt": "2026-10-01T16:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Contenido en blanco o categoria no reconocida |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Falta del permiso crm:customers:update |
| `404 Not Found` | `CustomerNotFoundException` | Cliente no encontrado en este taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-request-payload",
  "title": "Nota Invalida",
  "status": 400,
  "detail": "La categoria especificada no corresponde a ninguno de los valores admitidos (SERVICE, BILLING, PREFERENCE, GENERAL)",
  "instance": "/api/v1/crm/customers/018f6c50-7e12-7000-8000-000000000001/notes",
  "code": "INVALID_REQUEST_PAYLOAD",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

