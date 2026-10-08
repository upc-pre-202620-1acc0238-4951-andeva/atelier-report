# Especificacion Canonica de Endpoints: CRM & Fleet Context

Este documento constituye la referencia tecnica y exhaustiva de los 22 endpoints expuestos por el Bounded Context **Customer and Fleet Management (CRM)** (`com.andeva.atelier.platform.crm`) dentro de la plataforma SaaS **Atelier Platform Backend**.

## 1. Arquitectura de Cartera de Clientes, Parque Automotor y Flotas Comerciales

El modulo CRM & Fleet administra la relacion con clientes particulares y corporativos, gobierna la trazabilidad tecnica del parque automotor como activo global universal y articula convenios de flotas comerciales B2B y bitacoras de atencion.

### 1.1. Principios Fundamentales del Diseno de Dominio
1. **Aislamiento Multi-Inquilino en Clientes:** La cartera de clientes se segmenta estrictamente por taller mediante la clave foranea `tenantId`. Cada taller es soberano de sus registros de clientes, contactos y condiciones comerciales acordadas.
2. **Activo Vehicular Universal y Cadena de Custodia:** A diferencia de los clientes, la entidad `Vehicle` representa un activo fisico en el mundo real que carece de `tenantId` propio. Su unicidad se garantiza a nivel nacional por placa de rodaje y numero de chasis VIN (ISO 3779). La relacion con los clientes y talleres se materializa a traves de la entidad de trazabilidad `VehicleOwnership`, preservando el historico cronologico inmutable de tenencia y traspasos.
3. **Flotas Comerciales Corporativas (B2B):** Permite agrupar unidades vehiculares bajo convenios empresariales con clientes de tipo persona juridica (`COMPANY`), habilitando tarifas corporativas y gestion centralizada de mantenimiento.
4. **Invariante de Odometria e Integridad Pericial:** Toda actualizacion de kilometraje valida de forma determinista la no regresion del odometro para salvaguardar la transparencia pericial y advertir inconsistencias mecanicas.
5. **Estandar de Errores RFC 7807:** Toda anomalia de validacion sintactica o conflicto de negocio produce respuestas estandarizadas bajo el formato `ProblemDetail`.

### 1.2. Catalogo Maestro de Endpoints de CRM & Fleet

| No. | Seccion | Metodo | Ruta | Controlador | Metodo Java | Permiso Requerido |
| :---: | :---: | :---: | :--- | :--- | :--- | :--- |
| 1 | 2.1 | `POST` | `/api/v1/customers/individuals` | `CustomersController` | `registerIndividualCustomer()` | `@PreAuthorize("hasAuthority('crm:customers:create')")` |
| 2 | 2.2 | `POST` | `/api/v1/customers/companies` | `CustomersController` | `registerCompanyCustomer()` | `@PreAuthorize("hasAuthority('crm:customers:create')")` |
| 3 | 2.3 | `GET` | `/api/v1/customers` | `CustomersController` | `getCustomers()` | `@PreAuthorize("hasAuthority('crm:customers:read')")` |
| 4 | 2.4 | `GET` | `/api/v1/customers/{customerId}` | `CustomersController` | `getCustomerById()` | `@PreAuthorize("hasAuthority('crm:customers:read')")` |
| 5 | 2.5 | `PUT` | `/api/v1/customers/{customerId}/contact` | `CustomersController` | `updateCustomerContact()` | `@PreAuthorize("hasAuthority('crm:customers:update')")` |
| 6 | 2.6 | `GET` | `/api/v1/customers/{customerId}/vehicles` | `CustomersController` | `getCustomerVehicles()` | `@PreAuthorize("hasAuthority('crm:customers:read')")` |
| 7 | 3.1 | `POST` | `/api/v1/vehicles` | `VehiclesController` | `registerVehicle()` | `@PreAuthorize("hasAuthority('crm:vehicles:create')")` |
| 8 | 3.2 | `GET` | `/api/v1/vehicles/{vehicleId}` | `VehiclesController` | `getVehicleById()` | `@PreAuthorize("hasAuthority('crm:vehicles:read')")` |
| 9 | 3.3 | `GET` | `/api/v1/vehicles/by-plate/{plate}` | `VehiclesController` | `getVehicleByPlate()` | `@PreAuthorize("hasAuthority('crm:vehicles:read')")` |
| 10 | 3.4 | `POST` | `/api/v1/vehicles/{vehicleId}/ownerships` | `VehiclesController` | `transferOwnership()` | `@PreAuthorize("hasAuthority('crm:vehicles:update')")` |
| 11 | 3.5 | `GET` | `/api/v1/vehicles/{vehicleId}/ownerships` | `VehiclesController` | `getVehicleOwnershipHistory()` | `@PreAuthorize("hasAuthority('crm:vehicles:read')")` |
| 12 | 3.6 | `GET` | `/api/v1/vehicles/my-vehicles` | `VehiclesController` | `getMyVehicles()` | `@PreAuthorize("isAuthenticated()")` |
| 13 | 4.1 | `POST` | `/api/v1/appointments` | `AppointmentsController` | `scheduleAppointment()` | `@PreAuthorize("hasAuthority('crm:appointments:create')")` |
| 14 | 4.2 | `GET` | `/api/v1/appointments` | `AppointmentsController` | `getAppointments()` | `@PreAuthorize("hasAuthority('crm:appointments:read')")` |
| 15 | 4.3 | `GET` | `/api/v1/appointments/{appointmentId}` | `AppointmentsController` | `getAppointmentById()` | `@PreAuthorize("hasAuthority('crm:appointments:read')")` |
| 16 | 4.4 | `POST` | `/api/v1/appointments/{appointmentId}/confirm` | `AppointmentsController` | `confirmAppointment()` | `@PreAuthorize("hasAuthority('crm:appointments:manage')")` |
| 17 | 4.5 | `POST` | `/api/v1/appointments/{appointmentId}/arrive` | `AppointmentsController` | `recordArrival()` | `@PreAuthorize("hasAuthority('crm:appointments:manage')")` |
| 18 | 4.6 | `POST` | `/api/v1/appointments/{appointmentId}/reschedule` | `AppointmentsController` | `rescheduleAppointment()` | `@PreAuthorize("hasAuthority('crm:appointments:manage')")` |
| 19 | 4.7 | `POST` | `/api/v1/appointments/{appointmentId}/cancel` | `AppointmentsController` | `cancelAppointment()` | `@PreAuthorize("hasAuthority('crm:appointments:manage')")` |
| 20 | 5.1 | `POST` | `/api/v1/customers/{customerId}/memberships` | `CustomerMembershipsController` | `addCompanyMember()` | `@PreAuthorize("hasAuthority('crm:customers:manage')")` |
| 21 | 5.2 | `GET` | `/api/v1/customers/{customerId}/memberships` | `CustomerMembershipsController` | `getCompanyMembers()` | `@PreAuthorize("hasAuthority('crm:customers:read')")` |
| 22 | 5.3 | `DELETE` | `/api/v1/customers/{customerId}/memberships/{userId}` | `CustomerMembershipsController` | `revokeCompanyMember()` | `@PreAuthorize("hasAuthority('crm:customers:manage')")` |

---

## 2. Endpoints de Gestion de Clientes (CustomersController)

### 2.1. [POST] /api/v1/customers/individuals

**Alta de Cliente Particular (Persona Natural)**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.CustomersController`
- **Metodo Java:** `public ResponseEntity<CustomerResource> registerIndividualCustomer(@Valid @RequestBody CreateIndividualCustomerResource resource)`
- **Ruta Base:** `/api/v1/customers`
- **Ruta Completa:** `/api/v1/customers/individuals`
- **Proposito:** Registra a una persona natural como cliente del taller automotriz. Valida la unicidad nacional del documento nacional de identidad DNI ante la autoridad registral, valida el formato del correo electronico y el numero telefonico. Asocia de forma inmutable el identificador de inquilino del taller autenticado e inicializa el estado activo del titular.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST), Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Administrador (ROLE_WORKSHOP_ADMINISTRATOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:customers:create')")`
- **Aislamiento Multi-Inquilino:** Asigna el `tenantId` de forma automatica y determinista a partir de los claims del token JWT Bearer autenticado en el contexto de seguridad.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.requests.CreateIndividualCustomerResource`

```java
package com.andeva.atelier.platform.crm.interfaces.rest.resources.requests;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record CreateIndividualCustomerResource(
    @NotBlank(message = "El nombre de pila es obligatorio")
    @Size(min = 2, max = 100, message = "El nombre debe contener entre 2 y 100 caracteres")
    String firstName,

    @NotBlank(message = "El apellido es obligatorio")
    @Size(min = 2, max = 100, message = "El apellido debe contener entre 2 y 100 caracteres")
    String lastName,

    @NotBlank(message = "El documento de identidad es obligatorio")
    @Pattern(regexp = "^[0-9]{8}$", message = "El DNI debe estar compuesto exactamente por 8 digitos numericos")
    String taxId,

    @NotBlank(message = "El correo electronico es obligatorio")
    @Email(message = "El formato de correo electronico es invalido")
    String email,

    @NotBlank(message = "El numero telefonico es obligatorio")
    @Pattern(regexp = "^\+?[0-9]{9,15}$", message = "El telefono debe cumplir con formato internacional E.164")
    String phone
) {}
```

- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `firstName` | `String` | Si | `@NotBlank, @Size(min = 2, max = 100)` | Nombres de pila de la persona natural |
| `lastName` | `String` | Si | `@NotBlank, @Size(min = 2, max = 100)` | Apellidos completos del cliente titular |
| `taxId` | `String` | Si | `@NotBlank, @Pattern(regexp = "^[0-9]{8}$")` | Documento Nacional de Identidad DNI de 8 digitos |
| `email` | `String` | Si | `@NotBlank, @Email` | Correo electronico personal para notificaciones |
| `phone` | `String` | Si | `@NotBlank, @Pattern(regexp = "^\+?[0-9]{9,15}$")` | Telefono celular en formato estandar E.164 |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "firstName": "Juan Alberto",
  "lastName": "Perez Rodriguez",
  "taxId": "45871234",
  "email": "juan.perez@gmail.com",
  "phone": "+51987654321"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Cabecera de Ubicacion:** `Location: /api/v1/customers/018f6c40-7e12-7000-8000-000000000050`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.CustomerResource`

```java
package com.andeva.atelier.platform.crm.interfaces.rest.resources.responses;

import java.time.Instant;
import java.util.UUID;

public record CustomerResource(
    UUID id,
    UUID tenantId,
    String type,
    String displayName,
    String taxId,
    String email,
    String phone,
    String status,
    Instant createdAt
) {}
```

- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador universal asignado al cliente |
| `tenantId` | `UUID` | Identificador del taller automotriz titular |
| `type` | `String` | Tipo de personeria juridica (`INDIVIDUAL` o `COMPANY`) |
| `displayName` | `String` | Nombre consolidado para presentacion visual en interfaz |
| `taxId` | `String` | Documento de identidad fiscal registrado |
| `email` | `String` | Correo electronico registrado |
| `phone` | `String` | Telefono celular de contacto directo |
| `status` | `String` | Estado operativo del cliente (`ACTIVE`, `INACTIVE`) |
| `createdAt` | `Instant` | Marca temporal ISO-8601 de creacion en el sistema |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000050",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "type": "INDIVIDUAL",
  "displayName": "Juan Alberto Perez Rodriguez",
  "taxId": "45871234",
  "email": "juan.perez@gmail.com",
  "phone": "+51987654321",
  "status": "ACTIVE",
  "createdAt": "2026-10-03T10:15:30Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | El DNI no contiene 8 digitos o el formato de correo es sintacticamente invalido |
| `409 Conflict` | `CustomerTaxIdAlreadyExistsException` | Ya existe un cliente registrado en este taller con el mismo numero de DNI |
| `409 Conflict` | `CustomerEmailAlreadyExistsException` | La direccion de correo electronico ya se encuentra asignada a otro cliente del taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/customer-tax-id-already-exists",
  "title": "Conflicto de Identidad Fiscal",
  "status": 409,
  "detail": "El documento DNI 45871234 ya se encuentra registrado para un cliente en este taller",
  "instance": "/api/v1/customers/individuals",
  "code": "CUSTOMER_TAX_ID_ALREADY_EXISTS",
  "timestamp": "2026-10-03T10:15:30Z"
}
```

---

### 2.2. [POST] /api/v1/customers/companies

**Alta de Cliente Corporativo o Empresa con Flota**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.CustomersController`
- **Metodo Java:** `public ResponseEntity<CustomerResource> registerCompanyCustomer(@Valid @RequestBody CreateCompanyCustomerResource resource)`
- **Ruta Base:** `/api/v1/customers`
- **Ruta Completa:** `/api/v1/customers/companies`
- **Proposito:** Registra a una persona juridica o empresa comercial con flota vehicular en la cartera del taller. Valida el numero de Registro Unico de Contribuyentes RUC de 11 digitos que inicie con 10 o 20, la razon social formal, el correo de administracion de flota y el telefono institucional. Habilita a la entidad para suscribir contratos de flota y delegar miembros autorizados.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Administrador (ROLE_WORKSHOP_ADMINISTRATOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:customers:create')")`
- **Aislamiento Multi-Inquilino:** Asigna el `tenantId` de forma automatica y determinista a partir de los claims del token JWT Bearer autenticado.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.requests.CreateCompanyCustomerResource`

```java
package com.andeva.atelier.platform.crm.interfaces.rest.resources.requests;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record CreateCompanyCustomerResource(
    @NotBlank(message = "La razon social de la empresa es obligatoria")
    @Size(min = 3, max = 150, message = "La razon social debe contener entre 3 y 150 caracteres")
    String companyName,

    @NotBlank(message = "El numero de RUC es obligatorio")
    @Pattern(regexp = "^(10|20)[0-9]{9}$", message = "El RUC corporativo debe contener exactamente 11 digitos e iniciar con 10 o 20")
    String taxId,

    @NotBlank(message = "El correo corporativo es obligatorio")
    @Email(message = "El formato de correo electronico es invalido")
    String email,

    @NotBlank(message = "El telefono corporativo es obligatorio")
    @Pattern(regexp = "^\+?[0-9]{9,15}$", message = "El telefono debe cumplir con formato internacional E.164")
    String phone
) {}
```

- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `companyName` | `String` | Si | `@NotBlank, @Size(min = 3, max = 150)` | Razon social o denominacion formal de la empresa |
| `taxId` | `String` | Si | `@NotBlank, @Pattern(regexp = "^(10|20)[0-9]{9}$")` | RUC de 11 digitos numericos formalmente inscrito ante SUNAT |
| `email` | `String` | Si | `@NotBlank, @Email` | Correo electronico institucional de administracion de flota |
| `phone` | `String` | Si | `@NotBlank, @Pattern(regexp = "^\+?[0-9]{9,15}$")` | Telefono o central telefonica corporativa en formato E.164 |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "companyName": "TRANSPORTES LOGISTICOS DEL PACIFICO S.A.C.",
  "taxId": "20556789012",
  "email": "operaciones@transpacifico.pe",
  "phone": "+5114567890"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Cabecera de Ubicacion:** `Location: /api/v1/customers/018f6c40-7e12-7000-8000-000000000051`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.CustomerResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador universal asignado a la empresa cliente |
| `tenantId` | `UUID` | Identificador del taller automotriz titular |
| `type` | `String` | Tipo de personeria juridica (`COMPANY`) |
| `displayName` | `String` | Razon social proyectada para listados comerciales |
| `taxId` | `String` | Numero de RUC corporativo registrado |
| `email` | `String` | Correo institucional registrado |
| `phone` | `String` | Central telefonica registrada |
| `status` | `String` | Estado operativo del cliente (`ACTIVE`) |
| `createdAt` | `Instant` | Marca temporal ISO-8601 de creacion |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000051",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "type": "COMPANY",
  "displayName": "TRANSPORTES LOGISTICOS DEL PACIFICO S.A.C.",
  "taxId": "20556789012",
  "email": "operaciones@transpacifico.pe",
  "phone": "+5114567890",
  "status": "ACTIVE",
  "createdAt": "2026-10-03T11:00:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | El RUC no inicia con 10 o 20, o no contiene exactamente 11 digitos numericos |
| `409 Conflict` | `CustomerTaxIdAlreadyExistsException` | Ya existe un cliente empresarial registrado en este taller con el mismo numero de RUC |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/customer-tax-id-already-exists",
  "title": "Conflicto de RUC Corporativo",
  "status": 409,
  "detail": "El RUC 20556789012 ya se encuentra registrado para otra empresa en este taller",
  "instance": "/api/v1/customers/companies",
  "code": "CUSTOMER_TAX_ID_ALREADY_EXISTS",
  "timestamp": "2026-10-03T11:00:00Z"
}
```

---

### 2.3. [GET] /api/v1/customers

**Listado de Clientes Adscritos al Taller**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.CustomersController`
- **Metodo Java:** `public ResponseEntity<List<CustomerResource>> getCustomers(@RequestParam(required = false) String type, @RequestParam(required = false) String search, @RequestParam(required = false) String status, @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "20") int size)`
- **Ruta Base:** `/api/v1/customers`
- **Ruta Completa:** `/api/v1/customers`
- **Proposito:** Consulta el padron de clientes adscritos al taller en sesion. Permite filtrar de forma parametrizable por tipo de cliente (natural o empresa), estado operativo y termino de busqueda textual sobre nombres, razon social o documento de identidad. Retorna colecciones acotadas por limites de desplazamiento.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST), Asesor de Servicio (ROLE_SERVICE_ADVISOR), Mecanico Jefe (ROLE_CHIEF_MECHANIC) o Administrador (ROLE_WORKSHOP_ADMINISTRATOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:customers:read')")`
- **Aislamiento Multi-Inquilino:** Filtra de forma estricta por el `tenantId` obtenido de los claims del token JWT Bearer.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `type` | `String` | No | Filtro por tipo de personeria (`INDIVIDUAL` o `COMPANY`) |
| `search` | `String` | No | Termino de busqueda parcial sobre nombres, razon social o documento fiscal |
| `status` | `String` | No | Filtro por estado operativo (`ACTIVE` o `INACTIVE`) |
| `page` | `int` | No | Indice ordinal base cero del bloque de registros. Valor predeterminado 0 |
| `size` | `int` | No | Tamano del bloque de registros solicitados. Valor predeterminado 20 |

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP de consulta `GET` sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `List<com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.CustomerResource>`
- **Definicion de Campos Proyectados:** Lista estructurada de registros `CustomerResource`.

**Ejemplo de Carga Util JSON (Response):**
```json
[
  {
    "id": "018f6c40-7e12-7000-8000-000000000050",
    "tenantId": "018f6c40-7e12-7000-8000-000000000001",
    "type": "INDIVIDUAL",
    "displayName": "Juan Alberto Perez Rodriguez",
    "taxId": "45871234",
    "email": "juan.perez@gmail.com",
    "phone": "+51987654321",
    "status": "ACTIVE",
    "createdAt": "2026-10-03T10:15:30Z"
  },
  {
    "id": "018f6c40-7e12-7000-8000-000000000051",
    "tenantId": "018f6c40-7e12-7000-8000-000000000001",
    "type": "COMPANY",
    "displayName": "TRANSPORTES LOGISTICOS DEL PACIFICO S.A.C.",
    "taxId": "20556789012",
    "email": "operaciones@transpacifico.pe",
    "phone": "+5114567890",
    "status": "ACTIVE",
    "createdAt": "2026-10-03T11:00:00Z"
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `IllegalArgumentException` | Parametro de filtro o rango de bloque con valor negativo no valido |

---

### 2.4. [GET] /api/v1/customers/{customerId}

**Detalle Individual de Cliente por Identificador**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.CustomersController`
- **Metodo Java:** `public ResponseEntity<CustomerResource> getCustomerById(@PathVariable UUID customerId)`
- **Ruta Base:** `/api/v1/customers`
- **Ruta Completa:** `/api/v1/customers/{customerId}`
- **Proposito:** Obtiene la ficha tecnica y comercial completa de un cliente por su identificador universal. Valida la pertenencia del cliente al espacio aislado del taller autenticado.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST), Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Administrador (ROLE_WORKSHOP_ADMINISTRATOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:customers:read')")`
- **Aislamiento Multi-Inquilino:** Verifica que el cliente pertenezca al `tenantId` en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `customerId` | `UUID` | Si | Identificador universal del cliente a consultar |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP de consulta `GET` sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.CustomerResource`
- **Definicion de Campos Proyectados:** Coincide con la especificacion del recurso `CustomerResource`.

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000050",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "type": "INDIVIDUAL",
  "displayName": "Juan Alberto Perez Rodriguez",
  "taxId": "45871234",
  "email": "juan.perez@gmail.com",
  "phone": "+51987654321",
  "status": "ACTIVE",
  "createdAt": "2026-10-03T10:15:30Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `404 Not Found` | `CustomerNotFoundException` | No existe ningun cliente en este taller con el identificador UUID provisto |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/customer-not-found",
  "title": "Cliente No Encontrado",
  "status": 404,
  "detail": "No se encontro ningun cliente con identificador 018f6c40-7e12-7000-8000-000000000099 en este taller",
  "instance": "/api/v1/customers/018f6c40-7e12-7000-8000-000000000099",
  "code": "CUSTOMER_NOT_FOUND",
  "timestamp": "2026-10-03T11:30:00Z"
}
```

---

### 2.5. [PUT] /api/v1/customers/{customerId}/contact

**Actualizacion de Canales de Contacto Directo**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.CustomersController`
- **Metodo Java:** `public ResponseEntity<CustomerResource> updateCustomerContact(@PathVariable UUID customerId, @Valid @RequestBody UpdateCustomerContactResource resource)`
- **Ruta Base:** `/api/v1/customers`
- **Ruta Completa:** `/api/v1/customers/{customerId}/contact`
- **Proposito:** Actualiza los canales de comunicacion directa (correo electronico y numero telefonico) del cliente. Valida la sintaxis del nuevo correo y la conformidad del numero telefonico bajo formato internacional. Emite un evento de dominio interno para actualizar fichas de atencion abiertas.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST), Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Administrador (ROLE_WORKSHOP_ADMINISTRATOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:customers:update')")`
- **Aislamiento Multi-Inquilino:** Verifica que el cliente pertenezca al taller autenticado antes de aplicar la modificacion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `customerId` | `UUID` | Si | Identificador universal del cliente a actualizar |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.requests.UpdateCustomerContactResource`

```java
package com.andeva.atelier.platform.crm.interfaces.rest.resources.requests;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record UpdateCustomerContactResource(
    @NotBlank(message = "El correo electronico es obligatorio")
    @Email(message = "El formato de correo electronico es invalido")
    String email,

    @NotBlank(message = "El numero telefonico es obligatorio")
    @Pattern(regexp = "^\+?[0-9]{9,15}$", message = "El telefono debe cumplir con formato internacional E.164")
    String phone
) {}
```

- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `email` | `String` | Si | `@NotBlank, @Email` | Nueva direccion de correo electronico verificada |
| `phone` | `String` | Si | `@NotBlank, @Pattern(regexp = "^\+?[0-9]{9,15}$")` | Nuevo numero telefonico en formato E.164 |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "email": "juan.perez.actualizado@gmail.com",
  "phone": "+51999888777"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.CustomerResource`
- **Definicion de Campos Proyectados:** Coincide con la especificacion del recurso `CustomerResource`.

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000050",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "type": "INDIVIDUAL",
  "displayName": "Juan Alberto Perez Rodriguez",
  "taxId": "45871234",
  "email": "juan.perez.actualizado@gmail.com",
  "phone": "+51999888777",
  "status": "ACTIVE",
  "createdAt": "2026-10-03T10:15:30Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | El nuevo correo o numero telefonico presenta un formato sintacticamente invalido |
| `404 Not Found` | `CustomerNotFoundException` | El cliente especificado no existe en el registro del taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/customer-not-found",
  "title": "Cliente No Encontrado",
  "status": 404,
  "detail": "No se puede actualizar el contacto debido a que el cliente no existe en este taller",
  "instance": "/api/v1/customers/018f6c40-7e12-7000-8000-000000000099/contact",
  "code": "CUSTOMER_NOT_FOUND",
  "timestamp": "2026-10-03T11:45:00Z"
}
```

---

### 2.6. [GET] /api/v1/customers/{customerId}/vehicles

**Listado de Vehiculos Bajo Titularidad del Cliente**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.CustomersController`
- **Metodo Java:** `public ResponseEntity<List<VehicleResource>> getCustomerVehicles(@PathVariable UUID customerId)`
- **Ruta Base:** `/api/v1/customers`
- **Ruta Completa:** `/api/v1/customers/{customerId}/vehicles`
- **Proposito:** Consulta todas las unidades vehiculares del parque automotor universal que se encuentran bajo la custodia y titularidad activa del cliente indicado en la actualidad. Mapea la relacion materializada en la entidad de custodia `VehicleOwnership`.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST), Asesor de Servicio (ROLE_SERVICE_ADVISOR), Mecanico Jefe (ROLE_CHIEF_MECHANIC) o Tecnico Mecanico (ROLE_MECHANIC)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:customers:read')")`
- **Aislamiento Multi-Inquilino:** Verifica que el cliente pertenezca al taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `customerId` | `UUID` | Si | Identificador universal del cliente titular |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP de consulta `GET` sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `List<com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.VehicleResource>`

```java
package com.andeva.atelier.platform.crm.interfaces.rest.resources.responses;

import java.util.UUID;

public record VehicleResource(
    UUID id,
    String plate,
    String vin,
    String brand,
    String model,
    int year,
    String engineType,
    UUID currentOwnerId,
    String currentOwnerName
) {}
```

- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador universal asignado al vehiculo automotor |
| `plate` | `String` | Placa de rodaje normalizada sin guiones |
| `vin` | `String` | Numero de chasis estandarizado segun norma ISO 3779 |
| `brand` | `String` | Marca del fabricante del vehiculo |
| `model` | `String` | Modelo comercial del automovil |
| `year` | `int` | Ano de fabricacion vehicular |
| `engineType` | `String` | Motorizacion (`GASOLINE`, `DIESEL`, `ELECTRIC`, `HYBRID`) |
| `currentOwnerId` | `UUID` | Identificador universal del cliente titular vigente |
| `currentOwnerName` | `String` | Nombre o razon social del titular vigente |

**Ejemplo de Carga Util JSON (Response):**
```json
[
  {
    "id": "018f6c40-7e12-7000-8000-000000000070",
    "plate": "ABC123",
    "vin": "1HGCR2F83HA000123",
    "brand": "Toyota",
    "model": "Corolla",
    "year": 2021,
    "engineType": "GASOLINE",
    "currentOwnerId": "018f6c40-7e12-7000-8000-000000000050",
    "currentOwnerName": "Juan Alberto Perez Rodriguez"
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `404 Not Found` | `CustomerNotFoundException` | El cliente especificado no existe en el registro del taller |

---

## 3. Endpoints del Parque Automotor y Titularidad (VehiclesController)

### 3.1. [POST] /api/v1/vehicles

**Alta Global de Vehiculo y Asignacion de Titular Inicial**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.VehiclesController`
- **Metodo Java:** `public ResponseEntity<VehicleResource> registerVehicle(@Valid @RequestBody CreateVehicleResource resource)`
- **Ruta Base:** `/api/v1/vehicles`
- **Ruta Completa:** `/api/v1/vehicles`
- **Proposito:** Da de alta una unidad automotriz en el catalogo universal de vehiculos de la plataforma. Registra la placa de rodaje alfanumerica normalizada, numero de chasis VIN segun la norma ISO 3779, marca, modelo, ano de fabricacion y motorizacion. Asigna inmediatamente al cliente titular inicial en el taller mediante la creacion de un registro de custodia en `VehicleOwnership`.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST), Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Mecanico Jefe (ROLE_CHIEF_MECHANIC)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:vehicles:create')")`
- **Aislamiento Multi-Inquilino:** Verifica que el cliente titular inicial indicado pertenezca al `tenantId` en sesion. El vehiculo se persiste en el catalogo universal y queda vinculado operativamente al taller a traves de la relacion de custodia del cliente.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.requests.CreateVehicleResource`

```java
package com.andeva.atelier.platform.crm.interfaces.rest.resources.requests;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.util.UUID;

public record CreateVehicleResource(
    @NotBlank(message = "La placa de rodaje es obligatoria")
    @Pattern(regexp = "^[A-Z0-9]{3}-?[A-Z0-9]{3}$", message = "La placa vehicular debe tener un formato estandar alfanumerico de 6 caracteres")
    String plate,

    @Pattern(regexp = "^[A-HJ-NPR-Z0-9]{17}$", message = "El VIN debe cumplir con la norma ISO 3779 (17 caracteres alfanumericos excluyendo I, O, Q)")
    String vin,

    @NotBlank(message = "La marca del vehiculo es obligatoria")
    @Size(min = 2, max = 50, message = "La marca debe contener entre 2 y 50 caracteres")
    String brand,

    @NotBlank(message = "El modelo del vehiculo es obligatorio")
    @Size(min = 1, max = 50, message = "El modelo debe contener entre 1 y 50 caracteres")
    String model,

    @NotNull(message = "El ano del modelo de fabricacion es obligatorio")
    @Min(value = 1950, message = "El ano de fabricacion no puede ser anterior a 1950")
    Integer year,

    @NotBlank(message = "El tipo de motorizacion es obligatorio")
    @Pattern(regexp = "^(GASOLINE|DIESEL|ELECTRIC|HYBRID)$", message = "El tipo de motorizacion debe ser GASOLINE, DIESEL, ELECTRIC o HYBRID")
    String engineType,

    @NotNull(message = "El identificador del cliente titular inicial es obligatorio")
    UUID initialOwnerId
) {}
```

- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `plate` | `String` | Si | `@NotBlank, @Pattern(regexp = "^[A-Z0-9]{3}-?[A-Z0-9]{3}$")` | Placa de rodaje de 6 caracteres alfanumericos |
| `vin` | `String` | No | `@Pattern(regexp = "^[A-HJ-NPR-Z0-9]{17}$")` | Numero de identificacion vehicular VIN segun ISO 3779 |
| `brand` | `String` | Si | `@NotBlank, @Size(min = 2, max = 50)` | Marca automotriz del vehiculo |
| `model` | `String` | Si | `@NotBlank, @Size(min = 1, max = 50)` | Modelo de fabricacion comercial |
| `year` | `Integer` | Si | `@NotNull, @Min(1950)` | Ano de modelo de fabricacion |
| `engineType` | `String` | Si | `@NotBlank, @Pattern(regexp = "^(GASOLINE|DIESEL|ELECTRIC|HYBRID)$")` | Tipo de motorizacion vehicular |
| `initialOwnerId` | `UUID` | Si | `@NotNull` | Identificador universal del cliente titular inicial |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "plate": "ABC123",
  "vin": "1HGCR2F83HA000123",
  "brand": "Toyota",
  "model": "Corolla",
  "year": 2021,
  "engineType": "GASOLINE",
  "initialOwnerId": "018f6c40-7e12-7000-8000-000000000050"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Cabecera de Ubicacion:** `Location: /api/v1/vehicles/018f6c40-7e12-7000-8000-000000000070`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.VehicleResource`

```java
package com.andeva.atelier.platform.crm.interfaces.rest.resources.responses;

import java.util.UUID;

public record VehicleResource(
    UUID id,
    String plate,
    String vin,
    String brand,
    String model,
    int year,
    String engineType,
    UUID currentOwnerId,
    String currentOwnerName
) {}
```

- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador universal del vehiculo en la plataforma |
| `plate` | `String` | Placa de rodaje normalizada |
| `vin` | `String` | Numero VIN registrado |
| `brand` | `String` | Marca del fabricante |
| `model` | `String` | Modelo comercial |
| `year` | `int` | Ano de fabricacion |
| `engineType` | `String` | Motorizacion vehicular |
| `currentOwnerId` | `UUID` | Identificador del cliente propietario actual |
| `currentOwnerName` | `String` | Nombre o razon social del propietario actual |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000070",
  "plate": "ABC123",
  "vin": "1HGCR2F83HA000123",
  "brand": "Toyota",
  "model": "Corolla",
  "year": 2021,
  "engineType": "GASOLINE",
  "currentOwnerId": "018f6c40-7e12-7000-8000-000000000050",
  "currentOwnerName": "Juan Alberto Perez Rodriguez"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | La placa no cumple el patron alfanumerico o el VIN no cumple con la norma ISO 3779 |
| `404 Not Found` | `CustomerNotFoundException` | El cliente especificado en initialOwnerId no existe en este taller |
| `409 Conflict` | `VehiclePlateAlreadyExistsException` | La placa de rodaje ya se encuentra registrada en el parque automotor universal |
| `409 Conflict` | `VehicleVinAlreadyExistsException` | El numero de chasis VIN ya se encuentra asignado a otra unidad vehicular registrada |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/vehicle-plate-already-exists",
  "title": "Conflicto de Placa Vehicular",
  "status": 409,
  "detail": "La placa de rodaje ABC123 ya se encuentra registrada en el sistema",
  "instance": "/api/v1/vehicles",
  "code": "VEHICLE_PLATE_ALREADY_EXISTS",
  "timestamp": "2026-10-03T12:00:00Z"
}
```

---

### 3.2. [GET] /api/v1/vehicles/{vehicleId}

**Consulta Tecnica Integral de Vehiculo por Identificador**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.VehiclesController`
- **Metodo Java:** `public ResponseEntity<VehicleResource> getVehicleById(@PathVariable UUID vehicleId)`
- **Ruta Base:** `/api/v1/vehicles`
- **Ruta Completa:** `/api/v1/vehicles/{vehicleId}`
- **Proposito:** Consulta la ficha tecnica completa y los datos del propietario vigente de un vehiculo automotor a partir de su identificador universal.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST), Asesor de Servicio (ROLE_SERVICE_ADVISOR), Mecanico Jefe (ROLE_CHIEF_MECHANIC) o Tecnico Mecanico (ROLE_MECHANIC)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:vehicles:read')")`
- **Aislamiento Multi-Inquilino:** Entidad universal del parque automotor. Permite el acceso de lectura a colaboradores autenticados.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `vehicleId` | `UUID` | Si | Identificador universal del vehiculo a consultar |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP de consulta `GET` sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.VehicleResource`
- **Definicion de Campos Proyectados:** Coincide con la especificacion del recurso `VehicleResource`.

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000070",
  "plate": "ABC123",
  "vin": "1HGCR2F83HA000123",
  "brand": "Toyota",
  "model": "Corolla",
  "year": 2021,
  "engineType": "GASOLINE",
  "currentOwnerId": "018f6c40-7e12-7000-8000-000000000050",
  "currentOwnerName": "Juan Alberto Perez Rodriguez"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `404 Not Found` | `VehicleNotFoundException` | No existe ningun vehiculo registrado con el identificador UUID provisto |

---

### 3.3. [GET] /api/v1/vehicles/by-plate/{plate}

**Busqueda Rapida de Vehiculo por Placa de Rodaje**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.VehiclesController`
- **Metodo Java:** `public ResponseEntity<VehicleResource> getVehicleByPlate(@PathVariable String plate)`
- **Ruta Base:** `/api/v1/vehicles`
- **Ruta Completa:** `/api/v1/vehicles/by-plate/{plate}`
- **Proposito:** Permite la busqueda expedita de una unidad vehicular mediante su placa de rodaje para la recepcion agil en patio o fosa. Normaliza la entrada eliminando guiones y convirtiendo a mayusculas de forma previa a la consulta.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST), Asesor de Servicio (ROLE_SERVICE_ADVISOR), Mecanico Jefe (ROLE_CHIEF_MECHANIC) o Tecnico Mecanico (ROLE_MECHANIC)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:vehicles:read')")`
- **Aislamiento Multi-Inquilino:** Entidad universal del parque automotor. Acceso autorizado para usuarios con credenciales activas del taller.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `plate` | `String` | Si | Placa de rodaje alfanumerica normalizada de 6 caracteres (ej. `ABC123`) |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP de consulta `GET` sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.VehicleResource`
- **Definicion de Campos Proyectados:** Coincide con la especificacion del recurso `VehicleResource`.

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000070",
  "plate": "ABC123",
  "vin": "1HGCR2F83HA000123",
  "brand": "Toyota",
  "model": "Corolla",
  "year": 2021,
  "engineType": "GASOLINE",
  "currentOwnerId": "018f6c40-7e12-7000-8000-000000000050",
  "currentOwnerName": "Juan Alberto Perez Rodriguez"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `404 Not Found` | `VehicleNotFoundException` | La placa de rodaje no se encuentra registrada en la base de datos nacional de vehiculos |

---

### 3.4. [POST] /api/v1/vehicles/{vehicleId}/ownerships

**Traspaso Formal de Titularidad Vehicular**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.VehiclesController`
- **Metodo Java:** `public ResponseEntity<VehicleOwnershipResource> transferOwnership(@PathVariable UUID vehicleId, @Valid @RequestBody TransferVehicleOwnershipResource resource)`
- **Ruta Base:** `/api/v1/vehicles`
- **Ruta Completa:** `/api/v1/vehicles/{vehicleId}/ownerships`
- **Proposito:** Formaliza el cambio de titularidad de un vehiculo entre clientes. Finaliza el periodo de custodia vigente asignando la fecha de cese y crea un nuevo periodo de custodia activo vinculado al nuevo propietario, preservando de forma ininterrumpida la cadena de custodia legal y pericial.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Administrador (ROLE_WORKSHOP_ADMINISTRATOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:vehicles:update')")`
- **Aislamiento Multi-Inquilino:** Verifica que el nuevo cliente titular pertenezca al taller en sesion antes de formalizar la cesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `vehicleId` | `UUID` | Si | Identificador universal del vehiculo objeto del traspaso |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.requests.TransferVehicleOwnershipResource`

```java
package com.andeva.atelier.platform.crm.interfaces.rest.resources.requests;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PastOrPresent;
import java.time.LocalDate;
import java.util.UUID;

public record TransferVehicleOwnershipResource(
    @NotNull(message = "El identificador del nuevo cliente titular es obligatorio")
    UUID newOwnerId,

    @NotNull(message = "La fecha formal de traspaso de custodia es obligatoria")
    @PastOrPresent(message = "La fecha de traspaso no puede ser una fecha futura")
    LocalDate transferDate
) {}
```

- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `newOwnerId` | `UUID` | Si | `@NotNull` | Identificador universal del cliente adquirente |
| `transferDate` | `LocalDate` | Si | `@NotNull, @PastOrPresent` | Fecha del traspaso legal de la unidad vehicular |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "newOwnerId": "018f6c40-7e12-7000-8000-000000000051",
  "transferDate": "2026-10-03"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Cabecera de Ubicacion:** `Location: /api/v1/vehicles/018f6c40-7e12-7000-8000-000000000070/ownerships/018f6c40-7e12-7000-8000-000000000085`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.VehicleOwnershipResource`

```java
package com.andeva.atelier.platform.crm.interfaces.rest.resources.responses;

import java.time.LocalDate;
import java.util.UUID;

public record VehicleOwnershipResource(
    UUID id,
    UUID vehicleId,
    UUID customerId,
    String ownerName,
    LocalDate startDate,
    LocalDate endDate,
    boolean isCurrent
) {}
```

- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador universal del registro de titularidad |
| `vehicleId` | `UUID` | Identificador universal del vehiculo automotor |
| `customerId` | `UUID` | Identificador universal del cliente titular |
| `ownerName` | `String` | Nombre o razon social del titular |
| `startDate` | `LocalDate` | Fecha de inicio del periodo de custodia legal |
| `endDate` | `LocalDate` | Fecha de cese de custodia (nulo para el custodio vigente) |
| `isCurrent` | `boolean` | Indicador booleano de vigencia de titularidad |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000085",
  "vehicleId": "018f6c40-7e12-7000-8000-000000000070",
  "customerId": "018f6c40-7e12-7000-8000-000000000051",
  "ownerName": "TRANSPORTES LOGISTICOS DEL PACIFICO S.A.C.",
  "startDate": "2026-10-03",
  "endDate": null,
  "isCurrent": true
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `VehicleAlreadyOwnedByCustomerException` | El vehiculo ya se encuentra actualmente bajo la titularidad del cliente especificado |
| `400 Bad Request` | `IllegalArgumentException` | La fecha de traspaso es futura o anterior a la fecha de inicio del propietario actual |
| `404 Not Found` | `VehicleNotFoundException` | El vehiculo indicado no existe en el sistema |
| `404 Not Found` | `CustomerNotFoundException` | El nuevo cliente propietario no existe en el taller en sesion |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/vehicle-already-owned",
  "title": "Traspaso No Permitido",
  "status": 400,
  "detail": "El vehiculo ya se encuentra actualmente bajo la titularidad del cliente adquirente",
  "instance": "/api/v1/vehicles/018f6c40-7e12-7000-8000-000000000070/ownerships",
  "code": "VEHICLE_ALREADY_OWNED_BY_CUSTOMER",
  "timestamp": "2026-10-03T12:15:00Z"
}
```

---

### 3.5. [GET] /api/v1/vehicles/{vehicleId}/ownerships

**Historial Cronologico de Propietarios y Cadena de Custodia**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.VehiclesController`
- **Metodo Java:** `public ResponseEntity<List<VehicleOwnershipResource>> getVehicleOwnershipHistory(@PathVariable UUID vehicleId)`
- **Ruta Base:** `/api/v1/vehicles`
- **Ruta Completa:** `/api/v1/vehicles/{vehicleId}/ownerships`
- **Proposito:** Consulta el historico ordenado cronologicamente de todos los titulares y custodios que ha tenido la unidad automotor a lo largo de su ciclo de vida util, garantizando trazabilidad pericial y transparencia.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST), Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Mecanico Jefe (ROLE_CHIEF_MECHANIC)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:vehicles:read')")`
- **Aislamiento Multi-Inquilino:** Entidad universal. Acceso concedido a usuarios autenticados del taller.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `vehicleId` | `UUID` | Si | Identificador universal del vehiculo automotor |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP de consulta `GET` sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `List<com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.VehicleOwnershipResource>`
- **Definicion de Campos Proyectados:** Lista estructurada de registros `VehicleOwnershipResource`.

**Ejemplo de Carga Util JSON (Response):**
```json
[
  {
    "id": "018f6c40-7e12-7000-8000-000000000084",
    "vehicleId": "018f6c40-7e12-7000-8000-000000000070",
    "customerId": "018f6c40-7e12-7000-8000-000000000050",
    "ownerName": "Juan Alberto Perez Rodriguez",
    "startDate": "2021-05-10",
    "endDate": "2026-10-03",
    "isCurrent": false
  },
  {
    "id": "018f6c40-7e12-7000-8000-000000000085",
    "vehicleId": "018f6c40-7e12-7000-8000-000000000070",
    "customerId": "018f6c40-7e12-7000-8000-000000000051",
    "ownerName": "TRANSPORTES LOGISTICOS DEL PACIFICO S.A.C.",
    "startDate": "2026-10-03",
    "endDate": null,
    "isCurrent": true
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `404 Not Found` | `VehicleNotFoundException` | El vehiculo indicado no existe en el sistema |

---

### 3.6. [GET] /api/v1/vehicles/my-vehicles

**Consulta de Vehiculos del Conductor Autenticado**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.VehiclesController`
- **Metodo Java:** `public ResponseEntity<List<VehicleResource>> getMyVehicles()`
- **Ruta Base:** `/api/v1/vehicles`
- **Ruta Completa:** `/api/v1/vehicles/my-vehicles`
- **Proposito:** Consulta las unidades vehiculares registradas o asignadas bajo custodia activa del usuario autenticado en la sesion movil o web. Resuelve de forma directa el identificador de usuario a partir del token JWT para su renderizacion en la aplicacion de clientes y choferes.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Usuario autenticado en la plataforma
- **Permiso Atomico:** `@PreAuthorize("isAuthenticated()")`
- **Aislamiento Multi-Inquilino:** Vincula de forma directa el `userId` autenticado con los clientes de tipo natural o miembros de flotas corporativas donde posee membresia autorizada.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP de consulta `GET` sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `List<com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.VehicleResource>`
- **Definicion de Campos Proyectados:** Lista estructurada de registros `VehicleResource`.

**Ejemplo de Carga Util JSON (Response):**
```json
[
  {
    "id": "018f6c40-7e12-7000-8000-000000000070",
    "plate": "ABC123",
    "vin": "1HGCR2F83HA000123",
    "brand": "Toyota",
    "model": "Corolla",
    "year": 2021,
    "engineType": "GASOLINE",
    "currentOwnerId": "018f6c40-7e12-7000-8000-000000000050",
    "currentOwnerName": "Juan Alberto Perez Rodriguez"
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `401 Unauthorized` | `AuthenticationCredentialsNotFoundException` | La peticion carece del encabezado de autorizacion Bearer o el token ha expirado |

---

## 4. Endpoints de Citas Previas e Inspeccion (AppointmentsController)

### 4.1. [POST] /api/v1/appointments

**Agendamiento de Cita Previa de Inspeccion o Mantenimiento**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.AppointmentsController`
- **Metodo Java:** `public ResponseEntity<AppointmentResource> scheduleAppointment(@Valid @RequestBody ScheduleAppointmentResource resource)`
- **Ruta Base:** `/api/v1/appointments`
- **Ruta Completa:** `/api/v1/appointments`
- **Proposito:** Agenda formalmente una cita previa de recepcion para mantenimiento o evaluacion tecnica en una sede fisica del taller. Comprueba la validez de la franja horaria disponible, verifica la pertenencia del cliente y vehiculo, valida que la fecha solicitada sea estrictamente posterior al momento actual y crea la cita en estado inicial `PENDING`.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST), Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Conductor autenticado
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:appointments:create')")`
- **Aislamiento Multi-Inquilino:** Asocia el `tenantId` a partir del token JWT autenticado y corrobora que la sede fisica `branchId` corresponda a dicho inquilino.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.requests.ScheduleAppointmentResource`

```java
package com.andeva.atelier.platform.crm.interfaces.rest.resources.requests;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.UUID;

public record ScheduleAppointmentResource(
    @NotNull(message = "El identificador de la sede fisica de atencion es obligatorio")
    UUID branchId,

    @NotNull(message = "El identificador del cliente titular es obligatorio")
    UUID customerId,

    @NotNull(message = "El identificador del vehiculo es obligatorio")
    UUID vehicleId,

    @NotNull(message = "La fecha y hora acordada para la cita es obligatoria")
    @Future(message = "La cita tecnica debe agendarse para una fecha y hora futura")
    Instant scheduledAt,

    @Min(value = 15, message = "La duracion estimada de recepcion minima es de 15 minutos")
    int estimatedDurationMinutes,

    @NotBlank(message = "El motivo de la cita es obligatorio")
    @Size(min = 5, max = 500, message = "El motivo debe contener entre 5 y 500 caracteres")
    String reason
) {}
```

- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `branchId` | `UUID` | Si | `@NotNull` | Identificador universal de la sede fisica de atencion |
| `customerId` | `UUID` | Si | `@NotNull` | Identificador universal del cliente titular |
| `vehicleId` | `UUID` | Si | `@NotNull` | Identificador universal de la unidad vehicular |
| `scheduledAt` | `Instant` | Si | `@NotNull, @Future` | Marca temporal UTC pactada para la atencion |
| `estimatedDurationMinutes` | `int` | Si | `@Min(15)` | Estimacion pericial de duracion en minutos |
| `reason` | `String` | Si | `@NotBlank, @Size(min = 5, max = 500)` | Descripcion textual del motivo o falla manifestada |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "branchId": "018f6c40-7e12-7000-8000-000000000010",
  "customerId": "018f6c40-7e12-7000-8000-000000000050",
  "vehicleId": "018f6c40-7e12-7000-8000-000000000070",
  "scheduledAt": "2026-10-15T14:30:00Z",
  "estimatedDurationMinutes": 60,
  "reason": "Mantenimiento preventivo de los 10000 km y revision de frenos delanteros"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Cabecera de Ubicacion:** `Location: /api/v1/appointments/018f6c40-7e12-7000-8000-000000000090`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.AppointmentResource`

```java
package com.andeva.atelier.platform.crm.interfaces.rest.resources.responses;

import java.time.Instant;
import java.util.UUID;

public record AppointmentResource(
    UUID id,
    UUID tenantId,
    UUID branchId,
    UUID customerId,
    String customerName,
    UUID vehicleId,
    String vehiclePlate,
    Instant scheduledAt,
    int estimatedDurationMinutes,
    String reason,
    String status,
    String cancellationReason
) {}
```

- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador universal asignado a la cita previa |
| `tenantId` | `UUID` | Identificador del taller automotriz titular |
| `branchId` | `UUID` | Sede fisica de atencion programada |
| `customerId` | `UUID` | Identificador del cliente solicitante |
| `customerName` | `String` | Nombre o razon social del cliente |
| `vehicleId` | `UUID` | Identificador de la unidad automotor |
| `vehiclePlate` | `String` | Placa de rodaje vehicular |
| `scheduledAt` | `Instant` | Fecha y hora UTC acordada para la recepcion |
| `estimatedDurationMinutes` | `int` | Duracion proyectada de recepcion |
| `reason` | `String` | Motivo declarado del servicio |
| `status` | `String` | Estado operativo (`PENDING`, `CONFIRMED`, `ARRIVED`, `CANCELED`) |
| `cancellationReason` | `String` | Motivo de cancelacion en caso aplique (nulo inicialmente) |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000090",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "branchId": "018f6c40-7e12-7000-8000-000000000010",
  "customerId": "018f6c40-7e12-7000-8000-000000000050",
  "customerName": "Juan Alberto Perez Rodriguez",
  "vehicleId": "018f6c40-7e12-7000-8000-000000000070",
  "vehiclePlate": "ABC123",
  "scheduledAt": "2026-10-15T14:30:00Z",
  "estimatedDurationMinutes": 60,
  "reason": "Mantenimiento preventivo de los 10000 km y revision de frenos delanteros",
  "status": "PENDING",
  "cancellationReason": null
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `AppointmentPastDateException` | La fecha solicitada no es posterior a la marca temporal actual |
| `404 Not Found` | `CustomerNotFoundException` | El cliente especificado no existe en este taller |
| `404 Not Found` | `VehicleNotFoundException` | El vehiculo automotor indicado no se encuentra registrado |
| `404 Not Found` | `BranchNotFoundException` | La sede fisica solicitada no pertenece a este taller |
| `409 Conflict` | `AppointmentSlotUnavailableException` | La capacidad horaria de recepcion de la sede fisica se encuentra copada |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/appointment-slot-unavailable",
  "title": "Franja Horaria No Disponible",
  "status": 409,
  "detail": "La sede fisica no dispone de cupos de recepcion disponibles para la fecha y hora seleccionada",
  "instance": "/api/v1/appointments",
  "code": "APPOINTMENT_SLOT_UNAVAILABLE",
  "timestamp": "2026-10-03T12:30:00Z"
}
```

---

### 4.2. [GET] /api/v1/appointments

**Busqueda Filtrada de Citas Previas**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.AppointmentsController`
- **Metodo Java:** `public ResponseEntity<List<AppointmentResource>> getAppointments(@RequestParam(required = false) UUID branchId, @RequestParam(required = false) LocalDate date, @RequestParam(required = false) String status)`
- **Ruta Base:** `/api/v1/appointments`
- **Ruta Completa:** `/api/v1/appointments`
- **Proposito:** Consulta el calendario operativo de citas previas del taller. Permite acotar la busqueda por sede fisica, dia calendario (formato ISO-8601 `YYYY-MM-DD`) y estado operativo del flujo de atencion.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST), Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Administrador (ROLE_WORKSHOP_ADMINISTRATOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:appointments:read')")`
- **Aislamiento Multi-Inquilino:** Filtra estrictamente por el `tenantId` resuelto desde las credenciales del token JWT.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `branchId` | `UUID` | No | Filtro opcional por identificador de sede fisica |
| `date` | `LocalDate` | No | Fecha especifica en formato ISO-8601 (`YYYY-MM-DD`) |
| `status` | `String` | No | Estado de cita (`PENDING`, `CONFIRMED`, `ARRIVED`, `CANCELED`) |

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP de consulta `GET` sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `List<com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.AppointmentResource>`
- **Definicion de Campos Proyectados:** Coleccion estructurada de registros `AppointmentResource`.

**Ejemplo de Carga Util JSON (Response):**
```json
[
  {
    "id": "018f6c40-7e12-7000-8000-000000000090",
    "tenantId": "018f6c40-7e12-7000-8000-000000000001",
    "branchId": "018f6c40-7e12-7000-8000-000000000010",
    "customerId": "018f6c40-7e12-7000-8000-000000000050",
    "customerName": "Juan Alberto Perez Rodriguez",
    "vehicleId": "018f6c40-7e12-7000-8000-000000000070",
    "vehiclePlate": "ABC123",
    "scheduledAt": "2026-10-15T14:30:00Z",
    "estimatedDurationMinutes": 60,
    "reason": "Mantenimiento preventivo de los 10000 km y revision de frenos delanteros",
    "status": "PENDING",
    "cancellationReason": null
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `IllegalArgumentException` | Formato de fecha invalido o estado no reconocido |

---

### 4.3. [GET] /api/v1/appointments/{appointmentId}

**Detalle Individual de Cita por Identificador**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.AppointmentsController`
- **Metodo Java:** `public ResponseEntity<AppointmentResource> getAppointmentById(@PathVariable UUID appointmentId)`
- **Ruta Base:** `/api/v1/appointments`
- **Ruta Completa:** `/api/v1/appointments/{appointmentId}`
- **Proposito:** Consulta la informacion descriptiva y tecnica completa de una cita de atencion programada mediante su identificador universal.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST), Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Mecanico Jefe (ROLE_CHIEF_MECHANIC)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:appointments:read')")`
- **Aislamiento Multi-Inquilino:** Verifica que la cita pertenezca al `tenantId` del taller autenticado.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `appointmentId` | `UUID` | Si | Identificador universal de la cita programada |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP de consulta `GET` sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.AppointmentResource`
- **Definicion de Campos Proyectados:** Coincide con la especificacion del recurso `AppointmentResource`.

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000090",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "branchId": "018f6c40-7e12-7000-8000-000000000010",
  "customerId": "018f6c40-7e12-7000-8000-000000000050",
  "customerName": "Juan Alberto Perez Rodriguez",
  "vehicleId": "018f6c40-7e12-7000-8000-000000000070",
  "vehiclePlate": "ABC123",
  "scheduledAt": "2026-10-15T14:30:00Z",
  "estimatedDurationMinutes": 60,
  "reason": "Mantenimiento preventivo de los 10000 km y revision de frenos delanteros",
  "status": "PENDING",
  "cancellationReason": null
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `404 Not Found` | `AppointmentNotFoundException` | La cita especificada no existe en este taller automotriz |

---

### 4.4. [POST] /api/v1/appointments/{appointmentId}/confirm

**Confirmacion Formal de Cita por Recepcion**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.AppointmentsController`
- **Metodo Java:** `public ResponseEntity<AppointmentResource> confirmAppointment(@PathVariable UUID appointmentId)`
- **Ruta Base:** `/api/v1/appointments`
- **Ruta Completa:** `/api/v1/appointments/{appointmentId}/confirm`
- **Proposito:** Transiciona formalmente el estado de una cita de `PENDING` a `CONFIRMED`. Representa la validacion telefonica o digital efectuada por el personal de recepcion, bloqueando definitivamente el espacio de atencion en bahia.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:appointments:manage')")`
- **Aislamiento Multi-Inquilino:** Verifica que la cita pertenezca al `tenantId` en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `appointmentId` | `UUID` | Si | Identificador universal de la cita a confirmar |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
No aplica (Operacion idempotente de transicion de estado sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.AppointmentResource`
- **Definicion de Campos Proyectados:** Coincide con la especificacion del recurso `AppointmentResource` con campo `status` actualizado a `CONFIRMED`.

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000090",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "branchId": "018f6c40-7e12-7000-8000-000000000010",
  "customerId": "018f6c40-7e12-7000-8000-000000000050",
  "customerName": "Juan Alberto Perez Rodriguez",
  "vehicleId": "018f6c40-7e12-7000-8000-000000000070",
  "vehiclePlate": "ABC123",
  "scheduledAt": "2026-10-15T14:30:00Z",
  "estimatedDurationMinutes": 60,
  "reason": "Mantenimiento preventivo de los 10000 km y revision de frenos delanteros",
  "status": "CONFIRMED",
  "cancellationReason": null
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `AppointmentInvalidStateTransitionException` | La cita no se encuentra en estado PENDING para ser confirmada |
| `404 Not Found` | `AppointmentNotFoundException` | La cita especificada no existe en el taller |

---

### 4.5. [POST] /api/v1/appointments/{appointmentId}/arrive

**Registro de Arribo Fisico del Automovil a Recepcion**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.AppointmentsController`
- **Metodo Java:** `public ResponseEntity<AppointmentResource> recordArrival(@PathVariable UUID appointmentId)`
- **Ruta Base:** `/api/v1/appointments`
- **Ruta Completa:** `/api/v1/appointments/{appointmentId}/arrive`
- **Proposito:** Registra la presencia fisica del automovil y su conductor en la zona de recepcion del taller. Transiciona el estado a `ARRIVED` y publica un evento de integracion de dominio que habilita en el Bounded Context Workshop Operations la apertura de la Orden de Trabajo preliminar y el inicio del inventario de recepcion pericial.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST) o Asesor de Servicio (ROLE_SERVICE_ADVISOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:appointments:manage')")`
- **Aislamiento Multi-Inquilino:** Verifica la pertenencia de la cita al `tenantId` autenticado.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `appointmentId` | `UUID` | Si | Identificador universal de la cita cuyo vehiculo ha arribado |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
No aplica (Accion de transicion de estado sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.AppointmentResource`
- **Definicion de Campos Proyectados:** Coincide con la especificacion del recurso `AppointmentResource` con campo `status` actualizado a `ARRIVED`.

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000090",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "branchId": "018f6c40-7e12-7000-8000-000000000010",
  "customerId": "018f6c40-7e12-7000-8000-000000000050",
  "customerName": "Juan Alberto Perez Rodriguez",
  "vehicleId": "018f6c40-7e12-7000-8000-000000000070",
  "vehiclePlate": "ABC123",
  "scheduledAt": "2026-10-15T14:30:00Z",
  "estimatedDurationMinutes": 60,
  "reason": "Mantenimiento preventivo de los 10000 km y revision de frenos delanteros",
  "status": "ARRIVED",
  "cancellationReason": null
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `AppointmentAlreadyArrivedException` | El vehiculo ya habia registrado previamente su arribo a recepcion |
| `400 Bad Request` | `AppointmentInvalidStateTransitionException` | La cita se encuentra en estado cancelado y no admite arribos |
| `404 Not Found` | `AppointmentNotFoundException` | La cita especificada no existe |

---

### 4.6. [POST] /api/v1/appointments/{appointmentId}/reschedule

**Reprogramacion de Fecha y Hora de Cita**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.AppointmentsController`
- **Metodo Java:** `public ResponseEntity<AppointmentResource> rescheduleAppointment(@PathVariable UUID appointmentId, @Valid @RequestBody RescheduleAppointmentResource resource)`
- **Ruta Base:** `/api/v1/appointments`
- **Ruta Completa:** `/api/v1/appointments/{appointmentId}/reschedule`
- **Proposito:** Modifica la fecha y hora acordada para una cita tecnica no ejecutada. Comprueba que la unidad vehicular no haya ingresado fisicamente al taller, valida la disponibilidad de la nueva fecha solicitada y actualiza la programacion.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST), Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Conductor autenticado
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:appointments:manage')")`
- **Aislamiento Multi-Inquilino:** Valida la pertenencia de la cita al `tenantId` autenticado.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `appointmentId` | `UUID` | Si | Identificador universal de la cita a reprogramar |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.requests.RescheduleAppointmentResource`

```java
package com.andeva.atelier.platform.crm.interfaces.rest.resources.requests;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotNull;
import java.time.Instant;

public record RescheduleAppointmentResource(
    @NotNull(message = "La nueva fecha y hora programada es obligatoria")
    @Future(message = "La nueva fecha de la cita debe ser futura")
    Instant newScheduledAt
) {}
```

- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `newScheduledAt` | `Instant` | Si | `@NotNull, @Future` | Nueva marca temporal UTC acordada para la cita |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "newScheduledAt": "2026-10-18T10:00:00Z"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.AppointmentResource`
- **Definicion de Campos Proyectados:** Coincide con la especificacion del recurso `AppointmentResource` con campo `scheduledAt` actualizado.

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000090",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "branchId": "018f6c40-7e12-7000-8000-000000000010",
  "customerId": "018f6c40-7e12-7000-8000-000000000050",
  "customerName": "Juan Alberto Perez Rodriguez",
  "vehicleId": "018f6c40-7e12-7000-8000-000000000070",
  "vehiclePlate": "ABC123",
  "scheduledAt": "2026-10-18T10:00:00Z",
  "estimatedDurationMinutes": 60,
  "reason": "Mantenimiento preventivo de los 10000 km y revision de frenos delanteros",
  "status": "CONFIRMED",
  "cancellationReason": null
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `AppointmentPastDateException` | La nueva fecha solicitada es anterior al momento actual |
| `400 Bad Request` | `AppointmentAlreadyArrivedException` | No se puede reprogramar una cita de un vehiculo que ya arribo al taller |
| `404 Not Found` | `AppointmentNotFoundException` | La cita especificada no existe |
| `409 Conflict` | `AppointmentSlotUnavailableException` | La nueva franja horaria solicitada no cuenta con capacidad disponible |

---

### 4.7. [POST] /api/v1/appointments/{appointmentId}/cancel

**Cancelacion Justificada de Cita Previa**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.AppointmentsController`
- **Metodo Java:** `public ResponseEntity<AppointmentResource> cancelAppointment(@PathVariable UUID appointmentId, @Valid @RequestBody CancelAppointmentResource resource)`
- **Ruta Base:** `/api/v1/appointments`
- **Ruta Completa:** `/api/v1/appointments/{appointmentId}/cancel`
- **Proposito:** Cancela una cita previa antes de su atencion material. Exige un motivo justificado que queda registrado en la bitacora de atencion del cliente y libera de inmediato la capacidad de recepcion de la sede fisica.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST), Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Conductor titular
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:appointments:manage')")`
- **Aislamiento Multi-Inquilino:** Verifica que la cita pertenezca al taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `appointmentId` | `UUID` | Si | Identificador universal de la cita a cancelar |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.requests.CancelAppointmentResource`

```java
package com.andeva.atelier.platform.crm.interfaces.rest.resources.requests;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CancelAppointmentResource(
    @NotBlank(message = "El motivo de cancelacion es obligatorio")
    @Size(min = 5, max = 250, message = "La justificacion debe contener entre 5 y 250 caracteres")
    String reason
) {}
```

- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `reason` | `String` | Si | `@NotBlank, @Size(min = 5, max = 250)` | Motivo justificado de la cancelacion de la cita |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "reason": "El cliente tuvo una emergencia de viaje laboral y solicito anular la reserva"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.AppointmentResource`
- **Definicion de Campos Proyectados:** Coincide con la especificacion del recurso `AppointmentResource` con campo `status` actualizado a `CANCELED` y `cancellationReason` registrado.

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000090",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "branchId": "018f6c40-7e12-7000-8000-000000000010",
  "customerId": "018f6c40-7e12-7000-8000-000000000050",
  "customerName": "Juan Alberto Perez Rodriguez",
  "vehicleId": "018f6c40-7e12-7000-8000-000000000070",
  "vehiclePlate": "ABC123",
  "scheduledAt": "2026-10-15T14:30:00Z",
  "estimatedDurationMinutes": 60,
  "reason": "Mantenimiento preventivo de los 10000 km y revision de frenos delanteros",
  "status": "CANCELED",
  "cancellationReason": "El cliente tuvo una emergencia de viaje laboral y solicito anular la reserva"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `AppointmentAlreadyArrivedException` | No se puede cancelar una cita de una unidad vehicular que ya ingreso a taller |
| `404 Not Found` | `AppointmentNotFoundException` | La cita especificada no existe |

---

## 5. Endpoints de Membresias de Flotas Comerciales (CustomerMembershipsController)

### 5.1. [POST] /api/v1/customers/{customerId}/memberships

**Delegacion e Incorporacion de Miembro a Flota Corporativa**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.CustomerMembershipsController`
- **Metodo Java:** `public ResponseEntity<CustomerMembershipResource> addCompanyMember(@PathVariable UUID customerId, @Valid @RequestBody InviteCustomerMemberResource resource)`
- **Ruta Base:** `/api/v1/customers/{customerId}/memberships`
- **Ruta Completa:** `/api/v1/customers/{customerId}/memberships`
- **Proposito:** Registra formalmente a un usuario como miembro autorizado o delegado operativo en la flota comercial de un cliente empresarial de tipo `COMPANY`. Confiere atribuciones delegadas (`FLEET_ADMIN` para gestion y agendamiento general de todas las unidades, o `FLEET_OPERATOR` para conduccion y recepcion de unidades asignadas).

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR), Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Administrador Corporativo de Flota
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:customers:manage')")`
- **Aislamiento Multi-Inquilino:** Verifica que el cliente corporativo pertenezca al `tenantId` en sesion y que corresponda a una persona juridica.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `customerId` | `UUID` | Si | Identificador universal del cliente corporativo titular de la flota |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.requests.InviteCustomerMemberResource`

```java
package com.andeva.atelier.platform.crm.interfaces.rest.resources.requests;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import java.util.UUID;

public record InviteCustomerMemberResource(
    @NotNull(message = "El identificador del usuario delegado es obligatorio")
    UUID userId,

    @NotBlank(message = "El rol de flota es obligatorio")
    @Pattern(regexp = "^(FLEET_ADMIN|FLEET_OPERATOR)$", message = "El rol de flota debe ser FLEET_ADMIN o FLEET_OPERATOR")
    String role
) {}
```

- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `userId` | `UUID` | Si | `@NotNull` | Identificador universal del usuario a delegar en la flota |
| `role` | `String` | Si | `@NotBlank, @Pattern(regexp = "^(FLEET_ADMIN|FLEET_OPERATOR)$")` | Rol operativo concedido (`FLEET_ADMIN`, `FLEET_OPERATOR`) |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "userId": "018f6c40-7e12-7000-8000-000000000025",
  "role": "FLEET_OPERATOR"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Cabecera de Ubicacion:** `Location: /api/v1/customers/018f6c40-7e12-7000-8000-000000000051/memberships/018f6c40-7e12-7000-8000-000000000095`
- **Registro Java DTO:** `com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.CustomerMembershipResource`

```java
package com.andeva.atelier.platform.crm.interfaces.rest.resources.responses;

import java.time.Instant;
import java.util.UUID;

public record CustomerMembershipResource(
    UUID id,
    UUID customerId,
    UUID userId,
    String role,
    String status,
    Instant createdAt
) {}
```

- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador universal del registro de membresia de flota |
| `customerId` | `UUID` | Identificador de la empresa cliente |
| `userId` | `UUID` | Identificador universal del colaborador delegado |
| `role` | `String` | Rol concedido en la flota (`FLEET_ADMIN`, `FLEET_OPERATOR`) |
| `status` | `String` | Estado operativo de la membresia (`ACTIVE`, `REVOKED`) |
| `createdAt` | `Instant` | Fecha y hora UTC de concesion de acceso |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000095",
  "customerId": "018f6c40-7e12-7000-8000-000000000051",
  "userId": "018f6c40-7e12-7000-8000-000000000025",
  "role": "FLEET_OPERATOR",
  "status": "ACTIVE",
  "createdAt": "2026-10-03T13:00:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Rol de flota no reconocido o campos faltantes |
| `404 Not Found` | `CustomerNotFoundException` | El cliente corporativo no existe en el taller |
| `404 Not Found` | `UserNotFoundException` | El usuario especificado en userId no existe en la plataforma |
| `409 Conflict` | `CustomerMembershipAlreadyExistsException` | El usuario ya se encuentra registrado activamente como miembro de esta flota |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/customer-membership-already-exists",
  "title": "Membresia de Flota Ya Existente",
  "status": 409,
  "detail": "El usuario ya figura como miembro activo con permisos delegados sobre la flota corporativa",
  "instance": "/api/v1/customers/018f6c40-7e12-7000-8000-000000000051/memberships",
  "code": "CUSTOMER_MEMBERSHIP_ALREADY_EXISTS",
  "timestamp": "2026-10-03T13:00:00Z"
}
```

---

### 5.2. [GET] /api/v1/customers/{customerId}/memberships

**Listado de Miembros Autorizados de la Flota Corporativa**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.CustomerMembershipsController`
- **Metodo Java:** `public ResponseEntity<List<CustomerMembershipResource>> getCompanyMembers(@PathVariable UUID customerId)`
- **Ruta Base:** `/api/v1/customers/{customerId}/memberships`
- **Ruta Completa:** `/api/v1/customers/{customerId}/memberships`
- **Proposito:** Consulta el listado completo de usuarios autorizados, choferes y administradores vinculados a la flota de un cliente corporativo.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Recepcionista (ROLE_RECEPTIONIST), Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:customers:read')")`
- **Aislamiento Multi-Inquilino:** Verifica que el cliente pertenezca al taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `customerId` | `UUID` | Si | Identificador universal del cliente corporativo |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP de consulta `GET` sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `List<com.andeva.atelier.platform.crm.interfaces.rest.resources.responses.CustomerMembershipResource>`
- **Definicion de Campos Proyectados:** Lista estructurada de registros `CustomerMembershipResource`.

**Ejemplo de Carga Util JSON (Response):**
```json
[
  {
    "id": "018f6c40-7e12-7000-8000-000000000095",
    "customerId": "018f6c40-7e12-7000-8000-000000000051",
    "userId": "018f6c40-7e12-7000-8000-000000000025",
    "role": "FLEET_OPERATOR",
    "status": "ACTIVE",
    "createdAt": "2026-10-03T13:00:00Z"
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `404 Not Found` | `CustomerNotFoundException` | El cliente especificado no existe en el taller |

---

### 5.3. [DELETE] /api/v1/customers/{customerId}/memberships/{userId}

**Revocacion de Permisos de Miembro de la Flota**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.crm.interfaces.rest.controllers.CustomerMembershipsController`
- **Metodo Java:** `public ResponseEntity<Void> revokeCompanyMember(@PathVariable UUID customerId, @PathVariable UUID userId)`
- **Ruta Base:** `/api/v1/customers/{customerId}/memberships`
- **Ruta Completa:** `/api/v1/customers/{customerId}/memberships/{userId}`
- **Proposito:** Revoca de forma definitiva las facultades delegadas de un usuario sobre la flota comercial corporativa. Transiciona el estado de la membresia a `REVOKED` impidiendo el agendamiento o retiro de vehiculos por parte de dicho chofer o administrador.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR), Asesor de Servicio (ROLE_SERVICE_ADVISOR) o Administrador Corporativo de Flota
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('crm:customers:manage')")`
- **Aislamiento Multi-Inquilino:** Verifica que el cliente corporativo pertenezca al taller autenticado.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `customerId` | `UUID` | Si | Identificador universal del cliente corporativo |
| `userId` | `UUID` | Si | Identificador del usuario colaborador a revocar |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
No aplica (Accion HTTP de revocacion `DELETE` sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `204 No Content`
- **Cuerpo de Respuesta:** Vacio (Sin contenido conforme a la semantica REST HTTP 204).

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `404 Not Found` | `CustomerNotFoundException` | El cliente corporativo no existe en este taller |
| `404 Not Found` | `CustomerMembershipNotFoundException` | No existe una membresia activa que vincule al usuario con esta flota |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/customer-membership-not-found",
  "title": "Membresia de Flota No Encontrada",
  "status": 404,
  "detail": "El usuario no cuenta con una membresia activa sobre la flota comercial especificada",
  "instance": "/api/v1/customers/018f6c40-7e12-7000-8000-000000000051/memberships/018f6c40-7e12-7000-8000-000000000025",
  "code": "CUSTOMER_MEMBERSHIP_NOT_FOUND",
  "timestamp": "2026-10-03T13:30:00Z"
}
```
