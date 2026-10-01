# Especificacion Canonica de Endpoints: IAM & Tenancy Context

Este documento constituye la referencia tecnica y exhaustiva de los 28 endpoints expuestos por el Bounded Context **Identity and Access Management (IAM) & Tenancy** (`com.andeva.atelier.platform.iam`) dentro de la plataforma SaaS **Atelier Platform Backend**.

## 1. Arquitectura de Seguridad y Aislamiento Multi-Inquilino

El modulo IAM & Tenancy gobierna el aprovisionamiento corporativo de los talleres automotrices, la autenticacion universal federada y local, y la autorizacion granular mediante un modelo hibrido de Control de Acceso Basado en Roles (RBAC).

### 1.1. Principios Fundamentales de Seguridad
1. **Tokens JWT Contextuales y Enriquecidos:** Durante la autenticacion, el componente `BearerTokenService` compila la union de permisos de todos los roles asignados al colaborador, inyectando en los claims el `userId`, el `tenantId` activo y la coleccion de autoridades. El filtro `BearerAuthorizationRequestFilter` ejecuta la autorizacion perimetral en memoria con coste temporal O(1).
2. **Aislamiento Multi-Inquilino de Primer Nivel:** Todo recurso operativo se particiona estrictamente mediante el `tenantId`. Los controladores resuelven este valor a partir del token JWT autenticado o validan su coincidencia con los parametros de ruta para impedir accesos cruzados entre talleres.
3. **Despacho Resiliente de Correo:** Toda notificacion saliente (tokens OTP, invitaciones de colaboradores y enlaces de restablecimiento de clave) se delega a la API HTTPS de Resend, erradicando los bloqueos por politicas anti-spam en puertos SMTP tradicionales.
4. **Respuestas de Error Estandarizadas (RFC 7807):** Cualquier excepcion tecnica o de dominio es interceptada por el manejador global, proyectandose como un objeto `ProblemDetail` estructurado con tipo, titulo, estado HTTP, codigo interno y marca temporal.

### 1.2. Catalogo Maestro de Endpoints de IAM & Tenancy

| No. | Seccion | Metodo | Ruta | Controlador | Metodo Java | Permiso Requerido |
| :---: | :---: | :---: | :--- | :--- | :--- | :--- |
| 1 | 2.1 | `POST` | `/api/v1/auth/sign-up` | `AuthenticationController` | `signUp()` | `PermitAll` |
| 2 | 2.2 | `POST` | `/api/v1/auth/sign-in` | `AuthenticationController` | `signIn()` | `PermitAll` |
| 3 | 2.3 | `POST` | `/api/v1/auth/google-sign-in` | `AuthenticationController` | `googleSignIn()` | `PermitAll` |
| 4 | 2.4 | `POST` | `/api/v1/auth/verify-email` | `AuthenticationController` | `verifyEmail()` | `PermitAll` |
| 5 | 2.5 | `POST` | `/api/v1/auth/forgot-password` | `AuthenticationController` | `forgotPassword()` | `PermitAll` |
| 6 | 2.6 | `POST` | `/api/v1/auth/reset-password` | `AuthenticationController` | `resetPassword()` | `PermitAll` |
| 7 | 3.1 | `GET` | `/api/v1/tenants/current` | `TenantsController` | `getCurrentTenant()` | `@PreAuthorize("hasAuthority('iam:tenants:read')")` |
| 8 | 3.2 | `PUT` | `/api/v1/tenants/current` | `TenantsController` | `updateCurrentTenant()` | `@PreAuthorize("hasAuthority('iam:tenants:update')")` |
| 9 | 4.1 | `GET` | `/api/v1/branches` | `BranchesController` | `getBranches()` | `@PreAuthorize("hasAuthority('iam:branches:read')")` |
| 10 | 4.2 | `POST` | `/api/v1/branches` | `BranchesController` | `createBranch()` | `@PreAuthorize("hasAuthority('iam:branches:manage')")` |
| 11 | 4.3 | `GET` | `/api/v1/branches/{id}` | `BranchesController` | `getBranchById()` | `@PreAuthorize("hasAuthority('iam:branches:read')")` |
| 12 | 4.4 | `PUT` | `/api/v1/branches/{id}/location` | `BranchesController` | `updateBranchLocation()` | `@PreAuthorize("hasAuthority('iam:branches:manage')")` |
| 13 | 5.1 | `POST` | `/api/v1/invitations/tenant/{tenantId}` | `InvitationsController` | `inviteStaff()` | `@PreAuthorize("hasAuthority('iam:members:invite')")` |
| 14 | 5.2 | `GET` | `/api/v1/invitations/validate?token={token}` | `InvitationsController` | `validateInvitationToken()` | `PermitAll` |
| 15 | 5.3 | `POST` | `/api/v1/invitations/accept` | `InvitationsController` | `acceptInvitation()` | `PermitAll` |
| 16 | 6.1 | `GET` | `/api/v1/tenants/{tenantId}/memberships` | `MembershipsController` | `getMemberships()` | `@PreAuthorize("hasAuthority('iam:members:read')")` |
| 17 | 6.2 | `GET` | `/api/v1/tenants/{tenantId}/memberships/{id}` | `MembershipsController` | `getMembershipById()` | `@PreAuthorize("hasAuthority('iam:members:read')")` |
| 18 | 6.3 | `PUT` | `/api/v1/tenants/{tenantId}/memberships/{id}/roles` | `MembershipsController` | `assignRoles()` | `@PreAuthorize("hasAuthority('iam:members:manage_roles')")` |
| 19 | 6.4 | `PUT` | `/api/v1/tenants/{tenantId}/memberships/{id}/compensation` | `MembershipsController` | `updateCompensation()` | `@PreAuthorize("hasAuthority('iam:members:compensate')")` |
| 20 | 6.5 | `DELETE` | `/api/v1/tenants/{tenantId}/memberships/{id}` | `MembershipsController` | `deactivateMembership()` | `@PreAuthorize("hasAuthority('iam:members:manage_roles')")` |
| 21 | 7.1 | `GET` | `/api/v1/tenants/{tenantId}/roles` | `RolesController` | `getRoles()` | `@PreAuthorize("hasAuthority('iam:roles:read')")` |
| 22 | 7.2 | `POST` | `/api/v1/tenants/{tenantId}/roles` | `RolesController` | `createRole()` | `@PreAuthorize("hasAuthority('iam:roles:create')")` |
| 23 | 7.3 | `PUT` | `/api/v1/tenants/{tenantId}/roles/{roleId}/permissions` | `RolesController` | `updateRolePermissions()` | `@PreAuthorize("hasAuthority('iam:roles:create')")` |
| 24 | 7.4 | `POST` | `/api/v1/tenants/{tenantId}/roles/{roleId}/reset-defaults` | `RolesController` | `resetRoleToDefaults()` | `@PreAuthorize("hasAuthority('iam:roles:create')")` |
| 25 | 7.5 | `DELETE` | `/api/v1/tenants/{tenantId}/roles/{roleId}` | `RolesController` | `deleteRole()` | `@PreAuthorize("hasAuthority('iam:roles:create')")` |
| 26 | 7.6 | `GET` | `/api/v1/permissions` | `RolesController` | `getAllPermissions()` | `@PreAuthorize("hasAuthority('iam:permissions:read')")` |
| 27 | 8.1 | `GET` | `/api/v1/users/me` | `UsersController` | `getCurrentUser()` | `@PreAuthorize("isAuthenticated()")` |
| 28 | 8.2 | `PUT` | `/api/v1/users/me/profile` | `UsersController` | `updateProfile()` | `@PreAuthorize("isAuthenticated()")` |

---

## 2. Endpoints de Autenticacion (AuthenticationController)

### 2.1. [POST] /api/v1/auth/sign-up

**Registro de Taller y Cuenta Titular de Administrador**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.AuthenticationController`
- **Metodo Java:** `public ResponseEntity<TenantResource> signUp(@Valid @RequestBody CreateTenantResource resource)`
- **Ruta Base:** `/api/v1/auth`
- **Ruta Completa:** `/api/v1/auth/sign-up`
- **Proposito:** Procesa el registro fundacional de una nueva empresa de taller automotriz en Atelier Platform. Valida la unicidad nacional del RUC ante SUNAT, provisiona la entidad Tenant en estado activo, clona los ocho roles de sistema con sus permisos de fabrica para el nuevo inquilino e instancia la cuenta de usuario del administrador principal vinculada a la membresia inicial.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Publico (Sin autenticacion previa)
- **Rol Minimo Requerido:** Publico (Anonimo)
- **Permiso Atomico:** `PermitAll`
- **Aislamiento Multi-Inquilino:** Punto de entrada fundacional. Genera un nuevo TenantId universal en la base de datos y asocia todas las entidades hijas al nuevo espacio aislado.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.requests.CreateTenantResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `name` | `String` | Si | `@NotBlank, @Size(max = 100)` | Nombre comercial o de fantasia del taller automotriz |
| `legalName` | `String` | Si | `@NotBlank, @Size(max = 150)` | Razon social formal inscrita ante la autoridad tributaria SUNAT |
| `taxId` | `String` | Si | `@NotBlank, @Pattern(regexp = "^(10|20)\d{9}$")` | Numero de RUC valido de 11 digitos numericos |
| `adminEmail` | `String` | Si | `@NotBlank, @Email, @Size(max = 150)` | Correo electronico corporativo del titular que fungira como usuario inicial |
| `adminPassword` | `String` | Si | `@NotBlank, @Size(min = 8, max = 64)` | Contrasena en texto plano que sera cifrada mediante BCrypt con coste 12 |
| `adminFirstName` | `String` | Si | `@NotBlank, @Size(max = 100)` | Nombres de pila del titular administrador |
| `adminLastName` | `String` | Si | `@NotBlank, @Size(max = 100)` | Apellidos completos del titular administrador |
| `adminPhone` | `String` | Si | `@NotBlank, @Pattern(regexp = "^\+?[0-9]{9,15}$")` | Numero telefonico movil de contacto directo para alertas |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "name": "Taller Mecanico Precision Motors",
  "legalName": "PRECISION MOTORS S.A.C.",
  "taxId": "20608912345",
  "adminEmail": "gerencia@precisionmotors.pe",
  "adminPassword": "PasswordSeguro2026*",
  "adminFirstName": "Carlos Alberto",
  "adminLastName": "Mendoza Flores",
  "adminPhone": "+51987654321"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.TenantResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador universal asignado al taller automotriz |
| `name` | `String` | Nombre comercial registrado |
| `legalName` | `String` | Razon social inscrita |
| `taxId` | `String` | RUC validado |
| `status` | `String` | Estado operativo del taller (ACTIVE o PENDING) |
| `stripeCustomerId` | `String` | Identificador asignado en Stripe (null al inicio) |
| `createdAt` | `Instant` | Marca temporal de registro en formato ISO 8601 UTC |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000001",
  "name": "Taller Mecanico Precision Motors",
  "legalName": "PRECISION MOTORS S.A.C.",
  "taxId": "20608912345",
  "status": "ACTIVE",
  "stripeCustomerId": null,
  "createdAt": "2026-10-01T16:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | El formato del RUC no coincide con el patron de 11 digitos o faltan campos obligatorios |
| `409 Conflict` | `TenantTaxIdAlreadyExistsException` | El numero de RUC ya se encuentra registrado por otro taller automotriz |
| `409 Conflict` | `UserAlreadyExistsException` | La direccion de correo del administrador ya pertenece a una cuenta activa en el sistema |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/tenant-tax-id-already-exists",
  "title": "Conflicto de Identidad Tributaria",
  "status": 409,
  "detail": "El RUC 20608912345 ya se encuentra registrado para otro taller en el sistema",
  "instance": "/api/v1/auth/sign-up",
  "code": "TENANT_TAX_ID_ALREADY_EXISTS",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 2.2. [POST] /api/v1/auth/sign-in

**Autenticacion con Credenciales Locales**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.AuthenticationController`
- **Metodo Java:** `public ResponseEntity<AuthenticatedUserResource> signIn(@Valid @RequestBody SignInResource resource)`
- **Ruta Base:** `/api/v1/auth`
- **Ruta Completa:** `/api/v1/auth/sign-in`
- **Proposito:** Autentica a un usuario mediante sus credenciales locales (correo electronico y contrasena). Comprueba el hash criptografico BCrypt, valida el estado de la cuenta, resuelve el taller activo y membresias laborales, compila la union de permisos en memoria y emite un token JWT enriquecido para autorizacion O(1).

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Publico (Sin autenticacion previa)
- **Rol Minimo Requerido:** Publico (Anonimo)
- **Permiso Atomico:** `PermitAll`
- **Aislamiento Multi-Inquilino:** Resuelve el tenantId predeterminado del colaborador a traves de su membresia activa y lo inyecta como claim en el token JWT.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.requests.SignInResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `email` | `String` | Si | `@NotBlank, @Email` | Correo electronico registrado de la cuenta de acceso |
| `password` | `String` | Si | `@NotBlank` | Contrasena en texto plano para cotejo criptografico |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "email": "gerencia@precisionmotors.pe",
  "password": "PasswordSeguro2026*"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.AuthenticatedUserResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `userId` | `UUID` | Identificador universal de la cuenta de usuario |
| `email` | `String` | Correo electronico de la cuenta autenticada |
| `fullName` | `String` | Nombre completo resuelto desde el perfil |
| `token` | `String` | Token Bearer JWT firmado con algoritmo HMAC-SHA256 |
| `tokenType` | `String` | Esquema de autorizacion HTTP (Bearer) |
| `activeTenant` | `TenantSummaryResource` | Objeto resumen con id, nombre y taxId del taller activo |
| `permissions` | `List<String>` | Lista unificada de codigos de permisos atómicos asignados |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "userId": "018f6c40-7e12-7000-8000-000000000002",
  "email": "gerencia@precisionmotors.pe",
  "fullName": "Carlos Alberto Mendoza Flores",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIwMThmNmM0MC03ZTEyLTcwMDAtODAwMC0wMDAwMDAwMDAwMDIiLCJ0ZW5hbnRJZCI6IjAxOGY2YzQwLTdlMTItNzAwMC04MDAwLTAwMDAwMDAwMDAwMSIsInBlcm1pc3Npb25zIjpbImlhbTp0ZW5hbnRzOnJlYWQiLCJpYW06dGVuYW50czp1cGRhdGUiLCJpYW06YnJhbmNoZXM6cmVhZCJdfQ.signature",
  "tokenType": "Bearer",
  "activeTenant": {
    "id": "018f6c40-7e12-7000-8000-000000000001",
    "name": "Taller Mecanico Precision Motors",
    "taxId": "20608912345"
  },
  "permissions": [
    "iam:tenants:read",
    "iam:tenants:update",
    "iam:branches:read",
    "iam:branches:manage",
    "iam:members:read",
    "iam:members:invite",
    "iam:members:manage_roles"
  ]
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Sintaxis de correo electronico invalida o contrasena vacia |
| `401 Unauthorized` | `InvalidCredentialsException` | Credenciales invalidas por discordancia de correo o clave |
| `403 Forbidden` | `AccountSuspendedException` | La cuenta de usuario se encuentra suspendida o pendiente de activacion |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-credentials",
  "title": "Credenciales Incorrectas",
  "status": 401,
  "detail": "El correo o la contrasena ingresada no coinciden con ningun registro activo",
  "instance": "/api/v1/auth/sign-in",
  "code": "INVALID_CREDENTIALS",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 2.3. [POST] /api/v1/auth/google-sign-in

**Autenticacion Federada con Google OAuth2**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.AuthenticationController`
- **Metodo Java:** `public ResponseEntity<AuthenticatedUserResource> googleSignIn(@Valid @RequestBody GoogleSignInResource resource)`
- **Ruta Base:** `/api/v1/auth`
- **Ruta Completa:** `/api/v1/auth/google-sign-in`
- **Proposito:** Valida criptograficamente el token de identidad OpenID Connect (idToken) emitido por Google Identity Services. Si el usuario existe, sincroniza su sesion. Si no existe, aprovisiona automaticamente una cuenta federada de conductor o usuario con estado verificado y emite el token JWT Bearer de plataforma.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Publico (Sin autenticacion previa)
- **Rol Minimo Requerido:** Publico (Anonimo)
- **Permiso Atomico:** `PermitAll`
- **Aislamiento Multi-Inquilino:** Asocia el usuario federado con su taller activo si registra membresias previas o genera un perfil global de cliente.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.requests.GoogleSignInResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `idToken` | `String` | Si | `@NotBlank` | Token criptografico JWT OpenID emitido por Google Identity |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "idToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEyMzQ1NiJ9.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJzdWIiOiIxMDk4NzY1NDMyMSIsImVtYWlsIjoiY2FybG9zLm1lbmRvemFAZ21haWwuY29tIn0.signature"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.AuthenticatedUserResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `userId` | `UUID` | Identificador de la cuenta de usuario federada |
| `email` | `String` | Correo electronico verificado por Google |
| `fullName` | `String` | Nombre extraido de los metadatos de Google |
| `token` | `String` | Token Bearer JWT emitido por Atelier |
| `tokenType` | `String` | Esquema Bearer |
| `activeTenant` | `TenantSummaryResource` | Taller vinculado (o null si es conductor independiente) |
| `permissions` | `List<String>` | Lista de permisos atómicos asignados |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "userId": "018f6c40-7e12-7000-8000-000000000003",
  "email": "carlos.mendoza@gmail.com",
  "fullName": "Carlos Mendoza",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIwMThmNmM0MC03ZTEyLTcwMDAtODAwMC0wMDAwMDAwMDAwMDMiLCJhdXRob3JpdGllcyI6WyJjcm06dmVoaWNsZXM6cmVhZCJdfQ.signature",
  "tokenType": "Bearer",
  "activeTenant": null,
  "permissions": [
    "crm:vehicles:read"
  ]
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | El token de Google esta ausente o en blanco |
| `401 Unauthorized` | `InvalidGoogleTokenException` | Firma digital del token de Google invalida, expirada o rechazada por la API de Google |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-google-token",
  "title": "Token de Google Rechazado",
  "status": 401,
  "detail": "La firma del token de identidad no pudo ser verificada contra las claves publicas de Google",
  "instance": "/api/v1/auth/google-sign-in",
  "code": "INVALID_GOOGLE_TOKEN",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 2.4. [POST] /api/v1/auth/verify-email

**Activacion de Cuenta con Token de Verificacion**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.AuthenticationController`
- **Metodo Java:** `public ResponseEntity<MessageResponseResource> verifyEmail(@Valid @RequestBody VerifyEmailResource resource)`
- **Ruta Base:** `/api/v1/auth`
- **Ruta Completa:** `/api/v1/auth/verify-email`
- **Proposito:** Confirma la titularidad del correo electronico ingresado durante el registro mediante el canje de un token criptografico o codigo OTP numerico de seis digitos. Al validarse, transiciona el estado del usuario de PENDING_VERIFICATION a ACTIVE.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Publico (Sin autenticacion previa)
- **Rol Minimo Requerido:** Publico (Anonimo)
- **Permiso Atomico:** `PermitAll`
- **Aislamiento Multi-Inquilino:** Opera sobre el registro global de usuarios sin requerir contexto de inquilino.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.requests.VerifyEmailResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `token` | `String` | Si | `@NotBlank, @Size(min = 6, max = 128)` | Token seguro o codigo OTP de verificacion remitido por correo |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "token": "849201"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.MessageResponseResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `message` | `String` | Mensaje de confirmacion operativa de la verificacion |
| `timestamp` | `Instant` | Marca de tiempo de procesamiento en UTC |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "message": "Cuenta verificada y activada exitosamente",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `InvalidVerificationTokenException` | El token proporcionado no existe o ya fue consumido |
| `410 Gone` | `TokenExpiredException` | El token de activacion ha superado su ventana temporal de vigencia de 24 horas |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-verification-token",
  "title": "Token de Verificacion Invalido",
  "status": 400,
  "detail": "El codigo ingresado no coincide con ningun token pendiente de canje o ya fue utilizado",
  "instance": "/api/v1/auth/verify-email",
  "code": "INVALID_VERIFICATION_TOKEN",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 2.5. [POST] /api/v1/auth/forgot-password

**Solicitud de Restablecimiento de Contrasena**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.AuthenticationController`
- **Metodo Java:** `public ResponseEntity<MessageResponseResource> forgotPassword(@Valid @RequestBody ForgotPasswordResource resource)`
- **Ruta Base:** `/api/v1/auth`
- **Ruta Completa:** `/api/v1/auth/forgot-password`
- **Proposito:** Inicia el flujo seguro de recuperacion de credenciales olvidadas. Localiza al usuario por su correo, genera un token criptografico efimero de restablecimiento con vigencia de 15 minutos y delega su despacho a la API HTTPS de Resend para notificar al titular sin bloquear hilos de ejecucion.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Publico (Sin autenticacion previa)
- **Rol Minimo Requerido:** Publico (Anonimo)
- **Permiso Atomico:** `PermitAll`
- **Aislamiento Multi-Inquilino:** Busqueda global por direccion de correo electronico sin exponer la existencia previa de la cuenta por motivos de seguridad.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.requests.ForgotPasswordResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `email` | `String` | Si | `@NotBlank, @Email` | Direccion de correo electronico de la cuenta a restablecer |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "email": "carlos.mendoza@precisionmotors.pe"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.MessageResponseResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `message` | `String` | Mensaje confirmando el procesamiento de la solicitud |
| `timestamp` | `Instant` | Marca de tiempo de procesamiento en UTC |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "message": "Si el correo existe en el sistema, se ha enviado un enlace seguro para restablecer la contrasena",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Direccion de correo electronico sintacticamente invalida |
| `404 Not Found` | `UserNotFoundException` | Usuario no registrado (manejado internamente con respuesta 200 para evitar enumeracion) |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-request-payload",
  "title": "Peticion Invalida",
  "status": 400,
  "detail": "El formato del correo electronico proporcionado no cumple con el estandar RFC 5322",
  "instance": "/api/v1/auth/forgot-password",
  "code": "INVALID_REQUEST_PAYLOAD",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 2.6. [POST] /api/v1/auth/reset-password

**Confirmacion y Actualizacion de Nueva Contrasena**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.AuthenticationController`
- **Metodo Java:** `public ResponseEntity<MessageResponseResource> resetPassword(@Valid @RequestBody ResetPasswordResource resource)`
- **Ruta Base:** `/api/v1/auth`
- **Ruta Completa:** `/api/v1/auth/reset-password`
- **Proposito:** Valida el token de recuperacion entregado por el usuario y actualiza el hash de la contrasena mediante BCrypt con factor de coste 12. Invalida inmediatamente el token consumido y revoca sesiones previas para garantizar la integridad de la cuenta.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Publico (Sin autenticacion previa)
- **Rol Minimo Requerido:** Publico (Anonimo)
- **Permiso Atomico:** `PermitAll`
- **Aislamiento Multi-Inquilino:** Opera sobre el registro universal de usuarios.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.requests.ResetPasswordResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `token` | `String` | Si | `@NotBlank` | Token criptografico recibido mediante el enlace de recuperacion |
| `newPassword` | `String` | Si | `@NotBlank, @Size(min = 8, max = 64)` | Nueva contrasena en texto plano elegida por el usuario |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "token": "tok_rec_018f6c40abcd70008000000000000099",
  "newPassword": "NuevoPasswordSeguro2026*"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.MessageResponseResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `message` | `String` | Mensaje confirmando la actualizacion de la credencial |
| `timestamp` | `Instant` | Marca de tiempo de procesamiento en UTC |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "message": "Contrasena actualizada exitosamente. Puede iniciar sesion con sus nuevas credenciales",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | La nueva contrasena no cumple con los requisitos minimos de complejidad o longitud |
| `400 Bad Request` | `InvalidVerificationTokenException` | El token de restablecimiento es invalido o ya fue utilizado previamente |
| `410 Gone` | `TokenExpiredException` | El token de restablecimiento ha expirado (ventana de 15 minutos superada) |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/token-expired",
  "title": "Token de Restablecimiento Expirado",
  "status": 410,
  "detail": "El token de recuperacion ha superado su vigencia de 15 minutos. Solicite un nuevo enlace",
  "instance": "/api/v1/auth/reset-password",
  "code": "TOKEN_EXPIRED",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

## 3. Endpoints de Gestion de Talleres (TenantsController)

### 3.1. [GET] /api/v1/tenants/current

**Consulta del Perfil Corporativo del Taller en Sesion**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.TenantsController`
- **Metodo Java:** `public ResponseEntity<TenantResource> getCurrentTenant()`
- **Ruta Base:** `/api/v1/tenants`
- **Ruta Completa:** `/api/v1/tenants/current`
- **Proposito:** Recupera los datos corporativos, fiscales y de suscripcion del taller mecanico correspondiente a la sesion del usuario autenticado. El tenantId se resuelve de forma transparente a partir de los claims del token JWT, impidiendo consultas foraneas entre talleres.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Cualquier rol activo del taller
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('iam:tenants:read')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto. El tenantId se extrae del token JWT en memoria y delimita la busqueda.

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
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.TenantResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador universal del taller automotriz |
| `name` | `String` | Nombre comercial del taller |
| `legalName` | `String` | Razon social inscrita en SUNAT |
| `taxId` | `String` | Numero de RUC registrado |
| `status` | `String` | Estado operativo (ACTIVE o SUSPENDED) |
| `stripeCustomerId` | `String` | Identificador del cliente en Stripe Billing |
| `createdAt` | `Instant` | Fecha y hora de registro en UTC |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000001",
  "name": "Taller Mecanico Precision Motors",
  "legalName": "PRECISION MOTORS S.A.C.",
  "taxId": "20608912345",
  "status": "ACTIVE",
  "stripeCustomerId": "cus_Pn84Jkl921MxZ",
  "createdAt": "2026-10-01T16:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `401 Unauthorized` | `AuthenticationException` | Token JWT ausente, invalido o expirado |
| `403 Forbidden` | `AccessDeniedException` | El usuario no ostenta el permiso iam:tenants:read |
| `404 Not Found` | `TenantNotFoundException` | El taller referenciado en el token ya no existe en la base de datos |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/tenant-not-found",
  "title": "Taller No Encontrado",
  "status": 404,
  "detail": "No se localizo ningun taller activo con el identificador contenido en el token de autorizacion",
  "instance": "/api/v1/tenants/current",
  "code": "TENANT_NOT_FOUND",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 3.2. [PUT] /api/v1/tenants/current

**Actualizacion de Denominacion Comercial y Razon Social**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.TenantsController`
- **Metodo Java:** `public ResponseEntity<TenantResource> updateCurrentTenant(@Valid @RequestBody UpdateTenantProfileResource resource)`
- **Ruta Base:** `/api/v1/tenants`
- **Ruta Completa:** `/api/v1/tenants/current`
- **Proposito:** Permite al titular legal o administrador del taller actualizar la denominacion comercial de la empresa y la razon social formal. El numero de RUC (taxId) permanece inmutable para salvaguardar la integridad de las series de facturacion electronica UBL 2.1.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Dueno de Taller (ROLE_WORKSHOP_OWNER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('iam:tenants:update')")`
- **Aislamiento Multi-Inquilino:** Modifica exclusivamente el registro Tenant correspondiente al tenantId resuelto en el contexto de seguridad.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.requests.UpdateTenantProfileResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `name` | `String` | Si | `@NotBlank, @Size(max = 100)` | Nuevo nombre comercial o de fantasia del taller |
| `legalName` | `String` | Si | `@NotBlank, @Size(max = 150)` | Nueva razon social legal inscrita en SUNAT |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "name": "Precision Motors Centro Automotriz Integral",
  "legalName": "PRECISION MOTORS ASOCIADOS S.A.C."
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.TenantResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador universal del taller |
| `name` | `String` | Nombre comercial actualizado |
| `legalName` | `String` | Razon social actualizada |
| `taxId` | `String` | RUC inmutable del taller |
| `status` | `String` | Estado operativo |
| `stripeCustomerId` | `String` | Identificador de Stripe |
| `createdAt` | `Instant` | Fecha y hora de alta original |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000001",
  "name": "Precision Motors Centro Automotriz Integral",
  "legalName": "PRECISION MOTORS ASOCIADOS S.A.C.",
  "taxId": "20608912345",
  "status": "ACTIVE",
  "stripeCustomerId": "cus_Pn84Jkl921MxZ",
  "createdAt": "2026-10-01T16:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Campos name o legalName en blanco o que exceden la longitud maxima |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | El usuario no ostenta el rol de Dueno ni el permiso iam:tenants:update |
| `404 Not Found` | `TenantNotFoundException` | Taller no encontrado en el sistema |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/forbidden-access",
  "title": "Operacion No Autorizada",
  "status": 403,
  "detail": "Se requiere el permiso de gobernanza iam:tenants:update para modificar la identidad corporativa",
  "instance": "/api/v1/tenants/current",
  "code": "ACCESS_DENIED",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

## 4. Endpoints de Sedes y Geocercas (BranchesController)

### 4.1. [GET] /api/v1/branches

**Listado de Sedes Operativas del Taller**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.BranchesController`
- **Metodo Java:** `public ResponseEntity<List<BranchResource>> getBranches()`
- **Ruta Base:** `/api/v1/branches`
- **Ruta Completa:** `/api/v1/branches`
- **Proposito:** Retorna la coleccion completa de sedes fisicas y locales operativos pertenecientes al taller en sesion. Incluye sus codigos de anexo SUNAT, coordenadas geograficas WGS84, radio perimetrico de geocerca en metros y estado de actividad.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Cualquier colaborador activo del taller
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('iam:branches:read')")`
- **Aislamiento Multi-Inquilino:** Filtra estrictamente por el tenantId obtenido de las credenciales de sesion.

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
- **Registro Java DTO:** `List<com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.BranchResource>`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador universal de la sede fisica |
| `tenantId` | `UUID` | Identificador del taller titular |
| `name` | `String` | Nombre descriptivo de la sucursal |
| `sunatCode` | `String` | Codigo de anexo tributario de cuatro digitos asignado por SUNAT |
| `latitude` | `Double` | Latitud geografica en grados decimales (WGS84) |
| `longitude` | `Double` | Longitud geografica en grados decimales (WGS84) |
| `geofenceRadiusMeters` | `int` | Radio perimetrico en metros para validacion de asistencia |
| `isActive` | `boolean` | Bandera de operatividad comercial de la sede |

**Ejemplo de Carga Util JSON (Response):**
```json
[
  {
    "id": "018f6c40-7e12-7000-8000-000000000005",
    "tenantId": "018f6c40-7e12-7000-8000-000000000001",
    "name": "Sede Principal Surquillo",
    "sunatCode": "0001",
    "latitude": -12.11234567,
    "longitude": -77.01987654,
    "geofenceRadiusMeters": 60,
    "isActive": true
  },
  {
    "id": "018f6c40-7e12-7000-8000-000000000006",
    "tenantId": "018f6c40-7e12-7000-8000-000000000001",
    "name": "Sucursal Express La Molina",
    "sunatCode": "0002",
    "latitude": -12.08123456,
    "longitude": -76.9456789,
    "geofenceRadiusMeters": 45,
    "isActive": true
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `401 Unauthorized` | `AuthenticationException` | Token Bearer ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Falta de autoridad de seguridad iam:branches:read |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/unauthorized",
  "title": "Autenticacion Requerida",
  "status": 401,
  "detail": "La peticion carece de cabecera de autorizacion valida para acceder al catalogo de sedes",
  "instance": "/api/v1/branches",
  "code": "UNAUTHORIZED",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 4.2. [POST] /api/v1/branches

**Creacion de Nueva Sede Operativa con Geocerca GPS**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.BranchesController`
- **Metodo Java:** `public ResponseEntity<BranchResource> createBranch(@Valid @RequestBody CreateBranchResource resource)`
- **Ruta Base:** `/api/v1/branches`
- **Ruta Completa:** `/api/v1/branches`
- **Proposito:** Registra una nueva sede fisica de operaciones para el taller. Configura el codigo de anexo tributario de SUNAT y establece las coordenadas geograficas satelitales junto con el radio perimetrico en metros para el control de asistencia del personal mediante la formula del Haversine.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueno (ROLE_WORKSHOP_OWNER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('iam:branches:manage')")`
- **Aislamiento Multi-Inquilino:** Asigna de manera forzosa el tenantId activo a la nueva sede creada.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.requests.CreateBranchResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `name` | `String` | Si | `@NotBlank, @Size(max = 100)` | Nombre o denominacion comercial de la sede |
| `sunatCode` | `String` | No | `@Pattern(regexp = "^\d{4}$")` | Codigo oficial de establecimiento anexo declarado ante SUNAT |
| `latitude` | `Double` | Si | `@NotNull, @DecimalMin("-90.0"), @DecimalMax("90.0")` | Latitud del centroide del taller en coordenadas WGS84 |
| `longitude` | `Double` | Si | `@NotNull, @DecimalMin("-180.0"), @DecimalMax("180.0")` | Longitud del centroide del taller en coordenadas WGS84 |
| `geofenceRadiusMeters` | `int` | Si | `@Min(10), @Max(1000)` | Radio perimetrico circular en metros para control de asistencia |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "name": "Sucursal Norte Los Olivos",
  "sunatCode": "0003",
  "latitude": -11.99123456,
  "longitude": -77.07123456,
  "geofenceRadiusMeters": 50
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.BranchResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador asignado a la nueva sede |
| `tenantId` | `UUID` | Identificador del taller titular |
| `name` | `String` | Nombre de la sede |
| `sunatCode` | `String` | Codigo de anexo tributario |
| `latitude` | `Double` | Latitud registrada |
| `longitude` | `Double` | Longitud registrada |
| `geofenceRadiusMeters` | `int` | Radio de geocerca perimetrica |
| `isActive` | `boolean` | Estado activo de la sede (true) |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000007",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "name": "Sucursal Norte Los Olivos",
  "sunatCode": "0003",
  "latitude": -11.99123456,
  "longitude": -77.07123456,
  "geofenceRadiusMeters": 50,
  "isActive": true
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Coordenadas fuera de rango geodesico o radio menor a 10 metros |
| `401 Unauthorized` | `AuthenticationException` | Credenciales invalidas o ausentes |
| `403 Forbidden` | `AccessDeniedException` | Falta del permiso iam:branches:manage |
| `409 Conflict` | `BranchSunatCodeAlreadyExistsException` | El codigo de establecimiento anexo ya fue registrado en otra sede del taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/branch-sunat-code-exists",
  "title": "Codigo Anexo Duplicado",
  "status": 409,
  "detail": "El codigo SUNAT 0003 ya se encuentra registrado para otra sede fisica del taller",
  "instance": "/api/v1/branches",
  "code": "BRANCH_SUNAT_CODE_EXISTS",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 4.3. [GET] /api/v1/branches/{id}

**Detalle Individual de Sede Operativa**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.BranchesController`
- **Metodo Java:** `public ResponseEntity<BranchResource> getBranchById(@PathVariable UUID id)`
- **Ruta Base:** `/api/v1/branches`
- **Ruta Completa:** `/api/v1/branches/{id}`
- **Proposito:** Consulta los parametros especificos, identificador fiscal, coordenadas GPS y radio perimetrico de una sede fisica determinada perteneciente al taller en sesion.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Cualquier colaborador activo del taller
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('iam:branches:read')")`
- **Aislamiento Multi-Inquilino:** Comprueba que la sede solicitada pertenezca rigurosamente al tenantId del token en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Si | Identificador universal de la sede fisica solicitada |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.BranchResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la sede fisica |
| `tenantId` | `UUID` | Identificador del taller |
| `name` | `String` | Nombre de la sucursal |
| `sunatCode` | `String` | Codigo de anexo fiscal SUNAT |
| `latitude` | `Double` | Coordenada latitud WGS84 |
| `longitude` | `Double` | Coordenada longitud WGS84 |
| `geofenceRadiusMeters` | `int` | Radio perimetrico de cobertura en metros |
| `isActive` | `boolean` | Estado operativo de la sucursal |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000005",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "name": "Sede Principal Surquillo",
  "sunatCode": "0001",
  "latitude": -12.11234567,
  "longitude": -77.01987654,
  "geofenceRadiusMeters": 60,
  "isActive": true
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Acceso denegado a sedes de otro taller o sin permiso |
| `404 Not Found` | `BranchNotFoundException` | No existe la sede con el identificador provisto para este taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/branch-not-found",
  "title": "Sede No Encontrada",
  "status": 404,
  "detail": "La sede con identificador 018f6c40-7e12-7000-8000-000000000005 no existe o no pertenece a este taller",
  "instance": "/api/v1/branches/018f6c40-7e12-7000-8000-000000000005",
  "code": "BRANCH_NOT_FOUND",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 4.4. [PUT] /api/v1/branches/{id}/location

**Actualizacion de Coordenadas Satelitales y Geocerca**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.BranchesController`
- **Metodo Java:** `public ResponseEntity<BranchResource> updateBranchLocation(@PathVariable UUID id, @Valid @RequestBody UpdateBranchLocationResource resource)`
- **Ruta Base:** `/api/v1/branches`
- **Ruta Completa:** `/api/v1/branches/{id}/location`
- **Proposito:** Actualiza las coordenadas geograficas satelitales (latitud y longitud WGS84) y el radio perimetrico en metros de una sede operativa existente. Reajusta el margen de tolerancia para la marcacion de asistencia movil del personal de bahia.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueno (ROLE_WORKSHOP_OWNER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('iam:branches:manage')")`
- **Aislamiento Multi-Inquilino:** Verifica que la sede a modificar pertenezca al tenantId autenticado.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `id` | `UUID` | Si | Identificador de la sede fisica a actualizar |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.requests.UpdateBranchLocationResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `latitude` | `Double` | Si | `@NotNull, @DecimalMin("-90.0"), @DecimalMax("90.0")` | Nueva latitud del centroide del local |
| `longitude` | `Double` | Si | `@NotNull, @DecimalMin("-180.0"), @DecimalMax("180.0")` | Nueva longitud del centroide del local |
| `geofenceRadiusMeters` | `int` | Si | `@Min(10), @Max(1000)` | Nuevo radio perimetrico en metros |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "latitude": -12.1124,
  "longitude": -77.0199,
  "geofenceRadiusMeters": 75
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.BranchResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la sede fisica |
| `tenantId` | `UUID` | Identificador del taller |
| `name` | `String` | Nombre de la sede |
| `sunatCode` | `String` | Codigo de anexo tributario |
| `latitude` | `Double` | Latitud actualizada |
| `longitude` | `Double` | Longitud actualizada |
| `geofenceRadiusMeters` | `int` | Radio perimetrico actualizado |
| `isActive` | `boolean` | Estado activo de la sede |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000005",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "name": "Sede Principal Surquillo",
  "sunatCode": "0001",
  "latitude": -12.1124,
  "longitude": -77.0199,
  "geofenceRadiusMeters": 75,
  "isActive": true
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Radio perimetrico menor a 10 metros o coordenadas invalidas |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | El usuario carece del permiso iam:branches:manage |
| `404 Not Found` | `BranchNotFoundException` | Sede fisica no localizada dentro del taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-geofence",
  "title": "Parametros Geodesicos Invalidos",
  "status": 400,
  "detail": "El radio perimetrico debe ser de al menos 10 metros para garantizar precision GPS",
  "instance": "/api/v1/branches/018f6c40-7e12-7000-8000-000000000005/location",
  "code": "INVALID_GEOFENCE_RADIUS",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

## 5. Endpoints de Invitaciones de Personal (InvitationsController)

### 5.1. [POST] /api/v1/invitations/tenant/{tenantId}

**Emision de Invitacion Formal de Personal por Correo Electronico**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.InvitationsController`
- **Metodo Java:** `public ResponseEntity<InvitationResource> inviteStaff(@PathVariable UUID tenantId, @Valid @RequestBody InviteStaffResource resource)`
- **Ruta Base:** `/api/v1/invitations`
- **Ruta Completa:** `/api/v1/invitations/tenant/{tenantId}`
- **Proposito:** Emite una invitacion formal de contratacion e incorporacion laboral dirigida a un colaborador. Genera un token criptografico unívoco con expiracion a 7 dias, asigna el rol predeterminado de destino y despacha de manera asincrona el correo de onboarding utilizando la API HTTPS de Resend.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueno (ROLE_WORKSHOP_OWNER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('iam:members:invite')")`
- **Aislamiento Multi-Inquilino:** Verifica que el tenantId de la ruta coincida estrictamente con el tenantId del administrador emisor.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `tenantId` | `UUID` | Si | Identificador del taller automotriz que emite la vacante |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.requests.InviteStaffResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `email` | `String` | Si | `@NotBlank, @Email, @Size(max = 150)` | Correo electronico de destino del futuro empleado |
| `roleId` | `UUID` | Si | `@NotNull` | Identificador del rol de fabrica o personalizado que asumira al aceptar |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "email": "pedro.mecanico@gmail.com",
  "roleId": "018f6c40-7e12-7000-8000-000000000010"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.InvitationResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador universal de la invitacion creada |
| `tenantId` | `UUID` | Identificador del taller emisor |
| `email` | `String` | Correo electronico del destinatario |
| `status` | `String` | Estado inicial (PENDING) |
| `expiresAt` | `Instant` | Marca de tiempo limite de validez (7 dias posteriores) |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000020",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "email": "pedro.mecanico@gmail.com",
  "status": "PENDING",
  "expiresAt": "2026-10-08T16:30:00Z"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Direccion de correo invalida o roleId ausente |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | El usuario carece del permiso iam:members:invite |
| `404 Not Found` | `RoleNotFoundException` | El rol especificado por roleId no existe en el taller |
| `409 Conflict` | `UserAlreadyMemberException` | El correo especificado ya posee una membresia activa en este taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/user-already-member",
  "title": "Colaborador Ya Afiliado",
  "status": 409,
  "detail": "El correo pedro.mecanico@gmail.com ya cuenta con una membresia laboral activa en este taller",
  "instance": "/api/v1/invitations/tenant/018f6c40-7e12-7000-8000-000000000001",
  "code": "USER_ALREADY_MEMBER",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 5.2. [GET] /api/v1/invitations/validate?token={token}

**Validacion de Token Criptografico de Invitacion**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.InvitationsController`
- **Metodo Java:** `public ResponseEntity<InvitationValidationResource> validateInvitationToken(@RequestParam String token)`
- **Ruta Base:** `/api/v1/invitations`
- **Ruta Completa:** `/api/v1/invitations/validate?token={token}`
- **Proposito:** Verifica la validez y vigencia de un token de invitacion antes de presentar el formulario de registro en la aplicacion cliente. Retorna los metadatos contextuales (nombre del taller y rol propuesto) para brindar certeza al colaborador invitado.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Publico (Sin autenticacion previa)
- **Rol Minimo Requerido:** Publico (Anonimo)
- **Permiso Atomico:** `PermitAll`
- **Aislamiento Multi-Inquilino:** Resuelve el taller emisor a partir de la relacion foranea de la invitacion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
| Parametro | Tipo | Requerido | Valor por Defecto | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `token` | `String` | Si | Ninguno | Token criptografico unico recibido en el enlace de correo |

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.InvitationValidationResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `valid` | `boolean` | Indica si la invitacion es autentica y redimible |
| `email` | `String` | Correo electronico destinatario registrado |
| `tenantName` | `String` | Nombre comercial del taller que invita |
| `roleName` | `String` | Nombre del rol laboral predeterminado que sera asignado |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "valid": true,
  "email": "pedro.mecanico@gmail.com",
  "tenantName": "Taller Mecanico Precision Motors",
  "roleName": "Tecnico Mecanico"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MissingServletRequestParameterException` | Parametro token ausente en la URL |
| `404 Not Found` | `InvitationNotFoundException` | Token inexistente o revocado |
| `410 Gone` | `InvitationExpiredException` | La invitacion ha superado los 7 dias de vigencia |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invitation-expired",
  "title": "Invitacion Caducada",
  "status": 410,
  "detail": "La invitacion laboral ha superado el plazo maximo de 7 dias. Solicite un nuevo envio al administrador",
  "instance": "/api/v1/invitations/validate?token=tok_inv_expired_0123",
  "code": "INVITATION_EXPIRED",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 5.3. [POST] /api/v1/invitations/accept

**Aceptacion de Invitacion y Registro de Credenciales**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.InvitationsController`
- **Metodo Java:** `public ResponseEntity<AuthenticatedUserResource> acceptInvitation(@Valid @RequestBody AcceptInvitationResource resource)`
- **Ruta Base:** `/api/v1/invitations`
- **Ruta Completa:** `/api/v1/invitations/accept`
- **Proposito:** Completa el proceso de onboarding del colaborador. Valida el token, crea la cuenta de usuario con contrasena cifrada BCrypt si no existia, instancia la membresia TenantMembership asociada al taller con el rol acordado, transiciona la invitacion a ACCEPTED y emite el token JWT Bearer de acceso inmediato.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Publico (Sin autenticacion previa)
- **Rol Minimo Requerido:** Publico (Anonimo)
- **Permiso Atomico:** `PermitAll`
- **Aislamiento Multi-Inquilino:** Vincula al usuario con el tenantId de la invitacion redimida.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.requests.AcceptInvitationResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `token` | `String` | Si | `@NotBlank` | Token criptografico de la invitacion |
| `password` | `String` | Si | `@NotBlank, @Size(min = 8, max = 64)` | Contrasena elegida por el colaborador |
| `firstName` | `String` | Si | `@NotBlank, @Size(max = 100)` | Nombres del empleado |
| `lastName` | `String` | Si | `@NotBlank, @Size(max = 100)` | Apellidos del empleado |
| `phone` | `String` | No | `@Pattern(regexp = "^\+?[0-9]{9,15}$")` | Numero telefonico movil |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "token": "tok_inv_018f6c407e1270008000000000000055",
  "password": "ColaboradorSeguro2026*",
  "firstName": "Pedro Juan",
  "lastName": "Ramirez Quispe",
  "phone": "+51912345678"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.AuthenticatedUserResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `userId` | `UUID` | Identificador asignado al colaborador |
| `email` | `String` | Correo verificado del colaborador |
| `fullName` | `String` | Nombre completo |
| `token` | `String` | Token Bearer JWT de sesion inmediata |
| `tokenType` | `String` | Esquema Bearer |
| `activeTenant` | `TenantSummaryResource` | Taller al que fue adscrito |
| `permissions` | `List<String>` | Lista de permisos atómicos asignados por su rol |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "userId": "018f6c40-7e12-7000-8000-000000000030",
  "email": "pedro.mecanico@gmail.com",
  "fullName": "Pedro Juan Ramirez Quispe",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIwMThmNmM0MC03ZTEyLTcwMDAtODAwMC0wMDAwMDAwMDAwMzAiLCJhdXRob3JpdGllcyI6WyJvcGVyYXRpb25zOnRhc2tzOnRyYWNrX3RpbWUiXX0.signature",
  "tokenType": "Bearer",
  "activeTenant": {
    "id": "018f6c40-7e12-7000-8000-000000000001",
    "name": "Taller Mecanico Precision Motors",
    "taxId": "20608912345"
  },
  "permissions": [
    "operations:tasks:read",
    "operations:tasks:track_time",
    "operations:tasks:upload_photos",
    "operations:tasks:complete",
    "hr:attendance:clock_in",
    "hr:attendance:clock_out",
    "hr:attendance:read_own"
  ]
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Contrasena no cumple requisitos minimos de seguridad |
| `404 Not Found` | `InvitationNotFoundException` | El token de invitacion no existe o fue revocado |
| `409 Conflict` | `InvitationAlreadyAcceptedException` | La invitacion ya fue consumida previamente |
| `410 Gone` | `InvitationExpiredException` | La invitacion ha superado los 7 dias de vigencia |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invitation-already-accepted",
  "title": "Invitacion Ya Aceptada",
  "status": 409,
  "detail": "La invitacion proporcionada ya fue redimida y la cuenta se encuentra activa",
  "instance": "/api/v1/invitations/accept",
  "code": "INVITATION_ALREADY_ACCEPTED",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

## 6. Endpoints de Membresias Laborales (MembershipsController)

### 6.1. [GET] /api/v1/tenants/{tenantId}/memberships

**Listado del Personal Adscrito al Taller**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.MembershipsController`
- **Metodo Java:** `public ResponseEntity<List<MembershipResource>> getMemberships(@PathVariable UUID tenantId)`
- **Ruta Base:** `/api/v1/tenants`
- **Ruta Completa:** `/api/v1/tenants/{tenantId}/memberships`
- **Proposito:** Retorna el padron integro de colaboradores vinculados al taller especificado. Incluye datos biográficos del empleado, su correo electronico, estado laboral, esquema remunerativo (fijo u horario) y la coleccion de roles asignados.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Mecanico Jefe (ROLE_CHIEF_MECHANIC), Administrador o Dueno
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('iam:members:read')")`
- **Aislamiento Multi-Inquilino:** Valida que el tenantId de la ruta coincida con el inquilino en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `tenantId` | `UUID` | Si | Identificador universal del taller |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `List<com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.MembershipResource>`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la membresia laboral |
| `tenantId` | `UUID` | Identificador del taller empleador |
| `userId` | `UUID` | Identificador de la cuenta de usuario |
| `employeeName` | `String` | Nombre completo del colaborador |
| `email` | `String` | Correo electronico laboral o de acceso |
| `status` | `String` | Estado laboral (ACTIVE o INACTIVE) |
| `salaryType` | `String` | Modalidad de pago (FIXED u HOURLY) |
| `baseSalary` | `BigDecimal` | Monto salarial nominal |
| `currency` | `String` | Moneda de pago (PEN o USD) |
| `roles` | `List<RoleResource>` | Lista de roles asignados a la membresia |

**Ejemplo de Carga Util JSON (Response):**
```json
[
  {
    "id": "018f6c40-7e12-7000-8000-000000000040",
    "tenantId": "018f6c40-7e12-7000-8000-000000000001",
    "userId": "018f6c40-7e12-7000-8000-000000000030",
    "employeeName": "Pedro Juan Ramirez Quispe",
    "email": "pedro.mecanico@gmail.com",
    "status": "ACTIVE",
    "salaryType": "HOURLY",
    "baseSalary": 25.5,
    "currency": "PEN",
    "roles": [
      {
        "id": "018f6c40-7e12-7000-8000-000000000010",
        "name": "Tecnico Mecanico",
        "description": "Ejecucion directa de labores mecanicas y diagnostico en bahia",
        "isSystemRole": true,
        "permissions": [
          "operations:tasks:track_time",
          "operations:tasks:complete",
          "hr:attendance:clock_in"
        ]
      }
    ]
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | El usuario carece del permiso iam:members:read |
| `404 Not Found` | `TenantNotFoundException` | Taller no encontrado en el sistema |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/access-denied",
  "title": "Acceso Denegado",
  "status": 403,
  "detail": "No cuenta con privilegios para consultar la planilla y membresias laborales del taller",
  "instance": "/api/v1/tenants/018f6c40-7e12-7000-8000-000000000001/memberships",
  "code": "ACCESS_DENIED",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 6.2. [GET] /api/v1/tenants/{tenantId}/memberships/{id}

**Consulta de Ficha Laboral Individual de Colaborador**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.MembershipsController`
- **Metodo Java:** `public ResponseEntity<MembershipResource> getMembershipById(@PathVariable UUID tenantId, @PathVariable UUID id)`
- **Ruta Base:** `/api/v1/tenants`
- **Ruta Completa:** `/api/v1/tenants/{tenantId}/memberships/{id}`
- **Proposito:** Recupera la ficha contractual detallada de un miembro especifico adscrito al taller. Expone sus roles, condiciones de sueldo pactadas y estado operativo.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Mecanico Jefe, Administrador o Dueno
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('iam:members:read')")`
- **Aislamiento Multi-Inquilino:** Comprueba que la membresia pertenezca al taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `tenantId` | `UUID` | Si | Identificador del taller |
| `id` | `UUID` | Si | Identificador universal de la membresia laboral |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.MembershipResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la membresia |
| `tenantId` | `UUID` | Identificador del taller |
| `userId` | `UUID` | Identificador de la cuenta de usuario |
| `employeeName` | `String` | Nombre completo del colaborador |
| `email` | `String` | Correo electronico de acceso |
| `status` | `String` | Estado laboral |
| `salaryType` | `String` | Modalidad de sueldo |
| `baseSalary` | `BigDecimal` | Monto salarial nominal |
| `currency` | `String` | Moneda de remuneracion |
| `roles` | `List<RoleResource>` | Roles asignados |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000040",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "userId": "018f6c40-7e12-7000-8000-000000000030",
  "employeeName": "Pedro Juan Ramirez Quispe",
  "email": "pedro.mecanico@gmail.com",
  "status": "ACTIVE",
  "salaryType": "HOURLY",
  "baseSalary": 25.5,
  "currency": "PEN",
  "roles": [
    {
      "id": "018f6c40-7e12-7000-8000-000000000010",
      "name": "Tecnico Mecanico",
      "description": "Ejecucion directa de labores mecanicas y diagnostico en bahia",
      "isSystemRole": true,
      "permissions": [
        "operations:tasks:track_time",
        "operations:tasks:complete",
        "hr:attendance:clock_in"
      ]
    }
  ]
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Permiso iam:members:read insuficiente |
| `404 Not Found` | `MembershipNotFoundException` | Membresia laboral no localizada en este taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/membership-not-found",
  "title": "Membresia No Encontrada",
  "status": 404,
  "detail": "La membresia con identificador 018f6c40-7e12-7000-8000-000000000040 no existe en el taller especificado",
  "instance": "/api/v1/tenants/018f6c40-7e12-7000-8000-000000000001/memberships/018f6c40-7e12-7000-8000-000000000040",
  "code": "MEMBERSHIP_NOT_FOUND",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 6.3. [PUT] /api/v1/tenants/{tenantId}/memberships/{id}/roles

**Asignacion y Revocacion Dinamica de Roles de Seguridad**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.MembershipsController`
- **Metodo Java:** `public ResponseEntity<MembershipResource> assignRoles(@PathVariable UUID tenantId, @PathVariable UUID id, @Valid @RequestBody AssignRolesResource resource)`
- **Ruta Base:** `/api/v1/tenants`
- **Ruta Completa:** `/api/v1/tenants/{tenantId}/memberships/{id}/roles`
- **Proposito:** Modifica de forma atomica el conjunto de roles (relacion M:N) asignados a un colaborador del taller. Actualiza la tabla asociativa membership_roles, recalculando las facultades que seran inyectadas en sus proximos tokens de autenticacion.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueno (ROLE_WORKSHOP_OWNER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('iam:members:manage_roles')")`
- **Aislamiento Multi-Inquilino:** Verifica pertenencia del colaborador y de cada rol al tenantId en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `tenantId` | `UUID` | Si | Identificador del taller |
| `id` | `UUID` | Si | Identificador de la membresia a reconfigurar |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.requests.AssignRolesResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `roleIds` | `List<UUID>` | Si | `@NotEmpty` | Lista de identificadores de roles a vincular a la membresia |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "roleIds": [
    "018f6c40-7e12-7000-8000-000000000010",
    "018f6c40-7e12-7000-8000-000000000011"
  ]
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.MembershipResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la membresia |
| `tenantId` | `UUID` | Identificador del taller |
| `userId` | `UUID` | Identificador del usuario |
| `employeeName` | `String` | Nombre completo |
| `email` | `String` | Correo electronico |
| `status` | `String` | Estado laboral |
| `salaryType` | `String` | Tipo de salario |
| `baseSalary` | `BigDecimal` | Salario base |
| `currency` | `String` | Moneda |
| `roles` | `List<RoleResource>` | Lista actualizada de roles asignados |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000040",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "userId": "018f6c40-7e12-7000-8000-000000000030",
  "employeeName": "Pedro Juan Ramirez Quispe",
  "email": "pedro.mecanico@gmail.com",
  "status": "ACTIVE",
  "salaryType": "HOURLY",
  "baseSalary": 25.5,
  "currency": "PEN",
  "roles": [
    {
      "id": "018f6c40-7e12-7000-8000-000000000010",
      "name": "Tecnico Mecanico",
      "description": "Ejecucion directa de labores mecanicas",
      "isSystemRole": true,
      "permissions": [
        "operations:tasks:track_time",
        "operations:tasks:complete"
      ]
    },
    {
      "id": "018f6c40-7e12-7000-8000-000000000011",
      "name": "Encargado de Inventario",
      "description": "Custodia fisica y valoracion FIFO de autopartes",
      "isSystemRole": true,
      "permissions": [
        "inventory:batches:receive",
        "inventory:batches:dispatch_fifo"
      ]
    }
  ]
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Lista de roleIds vacia o nula |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Falta de autoridad iam:members:manage_roles |
| `404 Not Found` | `RoleNotFoundException` | Uno o mas roleIds no existen en el catalogo del taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/role-not-found",
  "title": "Rol Inexistente",
  "status": 404,
  "detail": "Uno de los roles seleccionados no existe en el catalogo del taller o fue eliminado",
  "instance": "/api/v1/tenants/018f6c40-7e12-7000-8000-000000000001/memberships/018f6c40-7e12-7000-8000-000000000040/roles",
  "code": "ROLE_NOT_FOUND",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 6.4. [PUT] /api/v1/tenants/{tenantId}/memberships/{id}/compensation

**Actualizacion del Esquema de Remuneracion Salarial**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.MembershipsController`
- **Metodo Java:** `public ResponseEntity<MembershipResource> updateCompensation(@PathVariable UUID tenantId, @PathVariable UUID id, @Valid @RequestBody UpdateCompensationResource resource)`
- **Ruta Base:** `/api/v1/tenants`
- **Ruta Completa:** `/api/v1/tenants/{tenantId}/memberships/{id}/compensation`
- **Proposito:** Actualiza las condiciones economicas contractuales del colaborador (modalidad de salario fijo mensual o tarifa por hora hombre y moneda de curso legal). Este endpoint esta reservado con exclusividad al Dueno del taller por razones de confidencialidad de planilla.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Exclusivo Dueno de Taller (ROLE_WORKSHOP_OWNER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('iam:members:compensate')")`
- **Aislamiento Multi-Inquilino:** Aislamiento estricto dentro del taller en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `tenantId` | `UUID` | Si | Identificador del taller |
| `id` | `UUID` | Si | Identificador de la membresia del colaborador |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.requests.UpdateCompensationResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `salaryType` | `String` | Si | `@NotBlank, @Pattern(regexp = "^(FIXED|HOURLY)$")` | Modalidad de compensacion salarial |
| `baseSalary` | `BigDecimal` | Si | `@NotNull, @DecimalMin("0.00")` | Monto salarial nominal o tarifa por hora |
| `currency` | `String` | Si | `@NotBlank, @Pattern(regexp = "^(PEN|USD)$")` | Codigo de moneda ISO-4217 |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "salaryType": "FIXED",
  "baseSalary": 2800,
  "currency": "PEN"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.MembershipResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador de la membresia |
| `tenantId` | `UUID` | Identificador del taller |
| `userId` | `UUID` | Identificador del usuario |
| `employeeName` | `String` | Nombre completo |
| `email` | `String` | Correo electronico |
| `status` | `String` | Estado laboral |
| `salaryType` | `String` | Modalidad de salario actualizada |
| `baseSalary` | `BigDecimal` | Monto salarial actualizado |
| `currency` | `String` | Moneda de liquidacion |
| `roles` | `List<RoleResource>` | Roles asignados |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000040",
  "tenantId": "018f6c40-7e12-7000-8000-000000000001",
  "userId": "018f6c40-7e12-7000-8000-000000000030",
  "employeeName": "Pedro Juan Ramirez Quispe",
  "email": "pedro.mecanico@gmail.com",
  "status": "ACTIVE",
  "salaryType": "FIXED",
  "baseSalary": 2800,
  "currency": "PEN",
  "roles": [
    {
      "id": "018f6c40-7e12-7000-8000-000000000010",
      "name": "Tecnico Mecanico",
      "description": "Ejecucion directa de labores mecanicas",
      "isSystemRole": true,
      "permissions": [
        "operations:tasks:track_time",
        "operations:tasks:complete"
      ]
    }
  ]
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Monto salarial negativo o tipo de compensacion invalido |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | El usuario no es Dueno de Taller o carece del permiso iam:members:compensate |
| `404 Not Found` | `MembershipNotFoundException` | Membresia laboral no localizada |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/forbidden-access",
  "title": "Acceso Privilegiado Requerido",
  "status": 403,
  "detail": "La gestion de compensaciones salariales es de caracter exclusivo para el Dueno del Taller",
  "instance": "/api/v1/tenants/018f6c40-7e12-7000-8000-000000000001/memberships/018f6c40-7e12-7000-8000-000000000040/compensation",
  "code": "ACCESS_DENIED",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 6.5. [DELETE] /api/v1/tenants/{tenantId}/memberships/{id}

**Desactivacion Laboral de Membresia en el Taller**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.MembershipsController`
- **Metodo Java:** `public ResponseEntity<Void> deactivateMembership(@PathVariable UUID tenantId, @PathVariable UUID id)`
- **Ruta Base:** `/api/v1/tenants`
- **Ruta Completa:** `/api/v1/tenants/{tenantId}/memberships/{id}`
- **Proposito:** Desvincula laboralmente al colaborador del taller mediante borrado logico (Soft Delete) y cambio de estado a INACTIVE. Invalida de forma inmediata la emision de nuevos tokens de acceso para ese taller.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueno (ROLE_WORKSHOP_OWNER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('iam:members:manage_roles')")`
- **Aislamiento Multi-Inquilino:** Asegura que no se desactive a miembros de otros talleres.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `tenantId` | `UUID` | Si | Identificador del taller |
| `id` | `UUID` | Si | Identificador de la membresia laboral a desactivar |

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
| `403 Forbidden` | `AccessDeniedException` | Falta del permiso iam:members:manage_roles |
| `404 Not Found` | `MembershipNotFoundException` | Membresia laboral no encontrada |
| `409 Conflict` | `CannotDeactivateLastOwnerException` | No es posible desactivar la membresia del unico Dueno registrado en el taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/cannot-deactivate-last-owner",
  "title": "Conflicto de Gobernanza",
  "status": 409,
  "detail": "No se puede dar de baja al unico titular legal (Dueno) registrado en el taller",
  "instance": "/api/v1/tenants/018f6c40-7e12-7000-8000-000000000001/memberships/018f6c40-7e12-7000-8000-000000000040",
  "code": "CANNOT_DEACTIVATE_LAST_OWNER",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

## 7. Endpoints de Roles y Permisos RBAC (RolesController)

### 7.1. [GET] /api/v1/tenants/{tenantId}/roles

**Consulta del Catalogo de Roles del Taller**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.RolesController`
- **Metodo Java:** `public ResponseEntity<List<RoleResource>> getRoles(@PathVariable UUID tenantId)`
- **Ruta Base:** `/api/v1/tenants`
- **Ruta Completa:** `/api/v1/tenants/{tenantId}/roles`
- **Proposito:** Retorna el catalogo consolidado de roles disponibles para el taller especificado. Incluye tanto los roles de fabrica aprovisionados al registrarse la empresa (isSystemRole = true) como los roles a medida creados por el taller (isSystemRole = false), desglosando los permisos concedidos a cada uno.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueno (ROLE_WORKSHOP_OWNER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('iam:roles:read')")`
- **Aislamiento Multi-Inquilino:** Filtra estrictamente por el tenantId en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Accept: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `tenantId` | `UUID` | Si | Identificador del taller |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `List<com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.RoleResource>`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador universal del rol |
| `name` | `String` | Nombre formal del rol de seguridad |
| `description` | `String` | Descripcion operativa del perfil |
| `isSystemRole` | `boolean` | Bandera que indica si es plantilla de fabrica protegida |
| `permissions` | `List<String>` | Codigos de permisos atómicos asignados |

**Ejemplo de Carga Util JSON (Response):**
```json
[
  {
    "id": "018f6c40-7e12-7000-8000-000000000010",
    "name": "Tecnico Mecanico",
    "description": "Ejecucion directa de labores mecanicas y diagnostico en bahia",
    "isSystemRole": true,
    "permissions": [
      "operations:tasks:read",
      "operations:tasks:track_time",
      "operations:tasks:upload_photos",
      "operations:tasks:complete",
      "hr:attendance:clock_in",
      "hr:attendance:clock_out",
      "hr:attendance:read_own"
    ]
  },
  {
    "id": "018f6c40-7e12-7000-8000-000000000015",
    "name": "Asistente de Lubricacion y Llantas",
    "description": "Personal de bahia enfocado en cambio de fluidos y mantenimiento rapido",
    "isSystemRole": false,
    "permissions": [
      "operations:tasks:read",
      "operations:tasks:track_time",
      "operations:tasks:complete",
      "hr:attendance:clock_in",
      "hr:attendance:clock_out"
    ]
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Permiso iam:roles:read insuficiente |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/access-denied",
  "title": "Permisos Insuficientes",
  "status": 403,
  "detail": "Se requiere la facultad iam:roles:read para auditar los roles y permisos del taller",
  "instance": "/api/v1/tenants/018f6c40-7e12-7000-8000-000000000001/roles",
  "code": "ACCESS_DENIED",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 7.2. [POST] /api/v1/tenants/{tenantId}/roles

**Creacion de Rol Personalizado por Taller**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.RolesController`
- **Metodo Java:** `public ResponseEntity<RoleResource> createRole(@PathVariable UUID tenantId, @Valid @RequestBody CreateRoleResource resource)`
- **Ruta Base:** `/api/v1/tenants`
- **Ruta Completa:** `/api/v1/tenants/{tenantId}/roles`
- **Proposito:** Permite a la gerencia del taller disenar y dar de alta un nuevo rol personalizado (isSystemRole = false), combinando un conjunto arbitrario de permisos atómicos del catalogo transversal para adaptarse a su estructura organizativa.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueno (ROLE_WORKSHOP_OWNER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('iam:roles:create')")`
- **Aislamiento Multi-Inquilino:** Asigna de manera forzosa el tenantId a la nueva fila creada en la tabla roles.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `tenantId` | `UUID` | Si | Identificador del taller creador |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.requests.CreateRoleResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `name` | `String` | Si | `@NotBlank, @Size(max = 100)` | Nombre descriptivo del rol personalizado |
| `description` | `String` | No | `@Size(max = 255)` | Explicacion de las funciones del perfil |
| `permissionIds` | `List<UUID>` | Si | `@NotEmpty` | Lista de identificadores de permisos atómicos a conceder |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "name": "Asistente de Lubricacion y Llantas",
  "description": "Personal de bahia enfocado en cambio de fluidos y mantenimiento rapido",
  "permissionIds": [
    "018f6c45-aaaa-7000-8000-000000000001",
    "018f6c45-bbbb-7000-8000-000000000002",
    "018f6c45-cccc-7000-8000-000000000003"
  ]
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `201 Created`
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.RoleResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador asignado al nuevo rol |
| `name` | `String` | Nombre del rol |
| `description` | `String` | Descripcion del rol |
| `isSystemRole` | `boolean` | Bandera de sistema (false para personalizados) |
| `permissions` | `List<String>` | Lista de codigos de permisos asociados |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000015",
  "name": "Asistente de Lubricacion y Llantas",
  "description": "Personal de bahia enfocado en cambio de fluidos y mantenimiento rapido",
  "isSystemRole": false,
  "permissions": [
    "operations:tasks:read",
    "operations:tasks:track_time",
    "operations:tasks:complete"
  ]
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Nombre en blanco o lista de permissionIds vacia |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Falta del permiso iam:roles:create |
| `404 Not Found` | `PermissionNotFoundException` | Uno o mas permissionIds no existen en el catalogo global |
| `409 Conflict` | `RoleNameAlreadyExistsException` | Ya existe un rol con esa denominacion en el taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/role-name-exists",
  "title": "Nombre de Rol Duplicado",
  "status": 409,
  "detail": "Ya existe un rol registrado con la denominacion Asistente de Lubricacion y Llantas en este taller",
  "instance": "/api/v1/tenants/018f6c40-7e12-7000-8000-000000000001/roles",
  "code": "ROLE_NAME_ALREADY_EXISTS",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 7.3. [PUT] /api/v1/tenants/{tenantId}/roles/{roleId}/permissions

**Actualizacion Soberana de Permisos de un Rol**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.RolesController`
- **Metodo Java:** `public ResponseEntity<RoleResource> updateRolePermissions(@PathVariable UUID tenantId, @PathVariable UUID roleId, @Valid @RequestBody UpdateRolePermissionsResource resource)`
- **Ruta Base:** `/api/v1/tenants`
- **Ruta Completa:** `/api/v1/tenants/{tenantId}/roles/{roleId}/permissions`
- **Proposito:** Permite al administrador o dueno reconfigurar soberanamente el conjunto de permisos de cualquier rol de su taller, ya sea de fabrica o personalizado. Actualiza la tabla role_permissions para que los miembros con este rol adopten de inmediato los nuevos privilegios en sus siguientes sesiones.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueno (ROLE_WORKSHOP_OWNER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('iam:roles:create')")`
- **Aislamiento Multi-Inquilino:** Verifica que el rol pertenezca rigurosamente al tenantId autenticado.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `tenantId` | `UUID` | Si | Identificador del taller |
| `roleId` | `UUID` | Si | Identificador del rol cuyos permisos se modificaran |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.requests.UpdateRolePermissionsResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `permissionIds` | `List<UUID>` | Si | `@NotEmpty` | Lista definitiva de identificadores de permisos a conceder al rol |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "permissionIds": [
    "018f6c45-aaaa-7000-8000-000000000001",
    "018f6c45-dddd-7000-8000-000000000004"
  ]
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.RoleResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del rol |
| `name` | `String` | Nombre del rol |
| `description` | `String` | Descripcion del rol |
| `isSystemRole` | `boolean` | Indicador de rol de fabrica |
| `permissions` | `List<String>` | Nueva lista de codigos de permisos asociados |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000015",
  "name": "Asistente de Lubricacion y Llantas",
  "description": "Personal de bahia enfocado en cambio de fluidos y mantenimiento rapido",
  "isSystemRole": false,
  "permissions": [
    "operations:tasks:read",
    "operations:tasks:track_time"
  ]
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Lista de permissionIds vacia |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Falta del permiso de administracion de roles |
| `404 Not Found` | `RoleNotFoundException` | El rol no existe o pertenece a otro taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/role-not-found",
  "title": "Rol No Encontrado",
  "status": 404,
  "detail": "No se localizo ningun rol con el identificador proporcionado dentro del taller en sesion",
  "instance": "/api/v1/tenants/018f6c40-7e12-7000-8000-000000000001/roles/018f6c40-7e12-7000-8000-000000000015/permissions",
  "code": "ROLE_NOT_FOUND",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 7.4. [POST] /api/v1/tenants/{tenantId}/roles/{roleId}/reset-defaults

**Restablecimiento de Rol de Fabrica a Permisos Predeterminados**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.RolesController`
- **Metodo Java:** `public ResponseEntity<RoleResource> resetRoleToDefaults(@PathVariable UUID tenantId, @PathVariable UUID roleId)`
- **Ruta Base:** `/api/v1/tenants`
- **Ruta Completa:** `/api/v1/tenants/{tenantId}/roles/{roleId}/reset-defaults`
- **Proposito:** Restituye los permisos predeterminados de fábrica de un rol del sistema (isSystemRole = true). Permite al taller revertir personalizaciones previas y adoptar nuevamente la configuracion estandar automotriz recomendada por Atelier.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueno (ROLE_WORKSHOP_OWNER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('iam:roles:create')")`
- **Aislamiento Multi-Inquilino:** Opera exclusivamente sobre roles pertenecientes al tenantId autenticado.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `tenantId` | `UUID` | Si | Identificador del taller |
| `roleId` | `UUID` | Si | Identificador del rol de fabrica a restablecer |

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
No aplica (Peticion HTTP sin cuerpo de entrada).

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.RoleResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador del rol |
| `name` | `String` | Nombre del rol |
| `description` | `String` | Descripcion del rol |
| `isSystemRole` | `boolean` | Bandera de sistema (true) |
| `permissions` | `List<String>` | Lista restaurada de permisos originales de fabrica |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000010",
  "name": "Tecnico Mecanico",
  "description": "Ejecucion directa de labores mecanicas y diagnostico en bahia",
  "isSystemRole": true,
  "permissions": [
    "operations:tasks:read",
    "operations:tasks:track_time",
    "operations:tasks:upload_photos",
    "operations:tasks:hold_request",
    "operations:tasks:complete",
    "operations:bays:read",
    "inventory:parts:read",
    "hr:attendance:clock_in",
    "hr:attendance:clock_out",
    "hr:attendance:read_own",
    "hr:justifications:create",
    "iot:devices:read",
    "iot:installations:manage",
    "iot:telemetry:ingest",
    "iot:telemetry:read",
    "iot:faults:read",
    "iot:faults:resolve",
    "iot:alerts:read",
    "iot:alerts:acknowledge",
    "iot:health_reports:generate",
    "iot:health_reports:read"
  ]
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `IllegalArgumentException` | El rol solicitado no es un rol de fabrica (isSystemRole es false) |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Falta del permiso iam:roles:create |
| `404 Not Found` | `RoleNotFoundException` | Rol no encontrado en el taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/not-a-system-role",
  "title": "Rol No Es de Sistema",
  "status": 400,
  "detail": "La operacion de restablecimiento a valores predeterminados solo aplica a roles aprovisionados de fabrica",
  "instance": "/api/v1/tenants/018f6c40-7e12-7000-8000-000000000001/roles/018f6c40-7e12-7000-8000-000000000015/reset-defaults",
  "code": "NOT_A_SYSTEM_ROLE",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 7.5. [DELETE] /api/v1/tenants/{tenantId}/roles/{roleId}

**Eliminacion de Rol Personalizado del Taller**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.RolesController`
- **Metodo Java:** `public ResponseEntity<Void> deleteRole(@PathVariable UUID tenantId, @PathVariable UUID roleId)`
- **Ruta Base:** `/api/v1/tenants`
- **Ruta Completa:** `/api/v1/tenants/{tenantId}/roles/{roleId}`
- **Proposito:** Elimina de forma permanente un rol personalizado que ha dejado de ser necesario. Impide la eliminacion si el rol es de fábrica (isSystemRole = true) o si se encuentra actualmente asignado a una o mas membresías activas.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueno (ROLE_WORKSHOP_OWNER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('iam:roles:create')")`
- **Aislamiento Multi-Inquilino:** Verifica pertenencia del rol al tenantId en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`

**Parametros de Ruta (Path Parameters):**
| Parametro | Tipo | Requerido | Descripcion |
| :--- | :--- | :---: | :--- |
| `tenantId` | `UUID` | Si | Identificador del taller |
| `roleId` | `UUID` | Si | Identificador del rol a eliminar |

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
| `403 Forbidden` | `AccessDeniedException` | Permiso insuficiente |
| `404 Not Found` | `RoleNotFoundException` | El rol no existe en el taller |
| `409 Conflict` | `SystemRoleImmutableException` | Los roles de sistema de fabrica no pueden ser eliminados |
| `409 Conflict` | `RoleInUseException` | El rol personalizado se encuentra asignado a colaboradores activos en el taller |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/role-in-use",
  "title": "Rol en Uso Activo",
  "status": 409,
  "detail": "No se puede eliminar el rol porque se encuentra asignado a una o mas membresias activas del personal",
  "instance": "/api/v1/tenants/018f6c40-7e12-7000-8000-000000000001/roles/018f6c40-7e12-7000-8000-000000000015",
  "code": "ROLE_IN_USE",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 7.6. [GET] /api/v1/permissions

**Consulta del Catalogo Transversal de Permisos Atomicos**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.RolesController`
- **Metodo Java:** `public ResponseEntity<List<PermissionResource>> getAllPermissions()`
- **Ruta Base:** `/api/v1/permissions`
- **Ruta Completa:** `/api/v1/permissions`
- **Proposito:** Retorna el catalogo global e inmutable de permisos atómicos definidos en la plataforma Atelier. Proporciona la lista de capacidades tecnicas ordenadas por modulo (iam, crm, operations, inventory, hr, invoicing, billing, iot) para alimentar la interfaz de configuracion de roles personalizados.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Administrador de Taller (ROLE_WORKSHOP_ADMINISTRATOR) o Dueno (ROLE_WORKSHOP_OWNER)
- **Permiso Atomico:** `@PreAuthorize("hasAuthority('iam:permissions:read')")`
- **Aislamiento Multi-Inquilino:** Catalogo global de lectura transversal a todos los inquilinos.

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
- **Registro Java DTO:** `List<com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.PermissionResource>`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador universal del permiso |
| `name` | `String` | Codigo estandar del permiso atomico (ej. iam:tenants:read) |
| `description` | `String` | Descripcion de la facultad tecnica conferida |
| `category` | `String` | Modulo funcional de pertenencia (iam, crm, operations, etc.) |

**Ejemplo de Carga Util JSON (Response):**
```json
[
  {
    "id": "018f6c45-aaaa-7000-8000-000000000001",
    "name": "iam:tenants:read",
    "description": "Consultar perfil y configuracion corporativa del taller",
    "category": "iam"
  },
  {
    "id": "018f6c45-aaaa-7000-8000-000000000002",
    "name": "crm:customers:read",
    "description": "Buscar y consultar fichas de clientes y contactos",
    "category": "crm"
  },
  {
    "id": "018f6c45-aaaa-7000-8000-000000000003",
    "name": "operations:work_orders:create",
    "description": "Aperturar nuevas ordenes de trabajo en patio de servicio",
    "category": "operations"
  }
]
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `403 Forbidden` | `AccessDeniedException` | Falta del permiso iam:permissions:read |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/access-denied",
  "title": "Acceso Denegado",
  "status": 403,
  "detail": "Se requiere la autoridad iam:permissions:read para inspeccionar el catalogo de permisos",
  "instance": "/api/v1/permissions",
  "code": "ACCESS_DENIED",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

## 8. Endpoints de Cuenta de Usuario (UsersController)

### 8.1. [GET] /api/v1/users/me

**Consulta de Perfil de la Cuenta de Usuario Autenticado**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.UsersController`
- **Metodo Java:** `public ResponseEntity<AuthenticatedUserResource> getCurrentUser()`
- **Ruta Base:** `/api/v1/users`
- **Ruta Completa:** `/api/v1/users/me`
- **Proposito:** Retorna los datos de sesion, identificador universal, nombres, correo electronico y autoridades concedidas al usuario que efectua la llamada, resolviendo su identidad desde el SecurityContext sin requerir parametros de ruta.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Cualquier usuario autenticado
- **Permiso Atomico:** `@PreAuthorize("isAuthenticated()")`
- **Aislamiento Multi-Inquilino:** Resuelve el perfil global y asocia el taller activo desde el token JWT.

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
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.AuthenticatedUserResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `userId` | `UUID` | Identificador de la cuenta de usuario |
| `email` | `String` | Correo electronico verificado de acceso |
| `fullName` | `String` | Nombre completo del usuario |
| `token` | `String` | Token Bearer JWT activo |
| `tokenType` | `String` | Esquema Bearer |
| `activeTenant` | `TenantSummaryResource` | Taller activo en la sesion actual |
| `permissions` | `List<String>` | Lista de codigos de permisos asignados |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "userId": "018f6c40-7e12-7000-8000-000000000002",
  "email": "gerencia@precisionmotors.pe",
  "fullName": "Carlos Alberto Mendoza Flores",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.active_jwt_token.signature",
  "tokenType": "Bearer",
  "activeTenant": {
    "id": "018f6c40-7e12-7000-8000-000000000001",
    "name": "Taller Mecanico Precision Motors",
    "taxId": "20608912345"
  },
  "permissions": [
    "iam:tenants:read",
    "iam:tenants:update",
    "iam:branches:read",
    "iam:branches:manage",
    "iam:members:read",
    "iam:members:invite",
    "iam:members:manage_roles"
  ]
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o expirado |
| `404 Not Found` | `UserNotFoundException` | La cuenta de usuario asociada al token ya no existe en el sistema |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/user-not-found",
  "title": "Usuario No Localizado",
  "status": 404,
  "detail": "La cuenta de usuario vinculada a la sesion no fue encontrada en la base de datos",
  "instance": "/api/v1/users/me",
  "code": "USER_NOT_FOUND",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

### 8.2. [PUT] /api/v1/users/me/profile

**Actualizacion de Datos Demograficos y Contacto del Perfil**

#### Identidad Tecnica
- **Controlador:** `com.andeva.atelier.platform.iam.interfaces.rest.controllers.UsersController`
- **Metodo Java:** `public ResponseEntity<UserProfileResource> updateProfile(@Valid @RequestBody UpdateProfileResource resource)`
- **Ruta Base:** `/api/v1/users`
- **Ruta Completa:** `/api/v1/users/me/profile`
- **Proposito:** Permite al usuario autenticado modificar sus datos demograficos de perfil personal (nombres, apellidos y telefono de contacto). La direccion de correo electronico permanece inalterada para no comprometer el mecanismo principal de autenticacion.

#### Seguridad y Autorizacion
- **Nivel de Acceso:** Autenticado
- **Rol Minimo Requerido:** Cualquier usuario autenticado
- **Permiso Atomico:** `@PreAuthorize("isAuthenticated()")`
- **Aislamiento Multi-Inquilino:** Afecta exclusivamente a la entidad Profile del usuario en sesion.

#### Parametros de Invocacion
**Cabeceras HTTP (Headers):**
- `Authorization: Bearer <jwt_token>`
- `Content-Type: application/json`

**Parametros de Ruta (Path Parameters):**
No aplica (Sin parametros en la ruta).

**Parametros de Consulta (Query Parameters):**
No aplica (Sin parametros de consulta en la URL).

#### Recurso de Peticion (Request Body)
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.requests.UpdateProfileResource`
- **Definicion de Campos:**
| Campo | Tipo de Dato | Requerido | Validaciones Jakarta | Descripcion |
| :--- | :--- | :---: | :--- | :--- |
| `firstName` | `String` | Si | `@NotBlank, @Size(max = 100)` | Nombres del usuario |
| `lastName` | `String` | Si | `@NotBlank, @Size(max = 100)` | Apellidos del usuario |
| `phone` | `String` | No | `@Pattern(regexp = "^\+?[0-9]{9,15}$")` | Telefono movil de contacto |

**Ejemplo de Carga Util JSON (Request):**
```json
{
  "firstName": "Carlos Alberto",
  "lastName": "Mendoza Flores",
  "phone": "+51987654321"
}
```

#### Recurso de Respuesta (Response Body)
- **Estado HTTP Exitoso:** `200 OK`
- **Registro Java DTO:** `com.andeva.atelier.platform.iam.interfaces.rest.resources.responses.UserProfileResource`
- **Definicion de Campos Proyectados:**
| Campo | Tipo de Dato | Descripcion |
| :--- | :--- | :--- |
| `id` | `UUID` | Identificador universal del perfil de usuario |
| `email` | `String` | Correo electronico de la cuenta |
| `firstName` | `String` | Nombres actualizados |
| `lastName` | `String` | Apellidos actualizados |
| `phone` | `String` | Telefono actualizado |
| `avatarUrl` | `String` | URL publica de la foto de perfil en el bucket S3 |

**Ejemplo de Carga Util JSON (Response):**
```json
{
  "id": "018f6c40-7e12-7000-8000-000000000002",
  "email": "gerencia@precisionmotors.pe",
  "firstName": "Carlos Alberto",
  "lastName": "Mendoza Flores",
  "phone": "+51987654321",
  "avatarUrl": "https://s3.us-east-1.amazonaws.com/atelier-avatars/profiles/018f6c40-0002.png"
}
```

#### Errores y Excepciones de Dominio (RFC 7807)
| Codigo HTTP | Excepcion Mapeada | Causa Funcional |
| :---: | :--- | :--- |
| `400 Bad Request` | `MethodArgumentNotValidException` | Nombres o apellidos en blanco o formato de telefono invalido |
| `401 Unauthorized` | `AuthenticationException` | Token ausente o invalido |
| `404 Not Found` | `UserNotFoundException` | Cuenta de usuario no localizada |

**Ejemplo de Carga Util de Error (RFC 7807 ProblemDetail):**
```json
{
  "type": "https://api.atelier.pe/errors/invalid-request-payload",
  "title": "Datos de Perfil Invalidos",
  "status": 400,
  "detail": "El formato del numero telefonico movil no coincide con un patron internacional valido",
  "instance": "/api/v1/users/me/profile",
  "code": "INVALID_REQUEST_PAYLOAD",
  "timestamp": "2026-10-01T16:30:00Z"
}
```

---

