# REST API & Interface Specification
## Agri-Insight Beacon Platform

**Base URL (Localhost):** `http://localhost:3000/api`  
**Base URL (Android Emulator):** `http://10.0.2.2:3000/api`  
**Protocol:** HTTP/1.1 over TCP / JSON  
**Specification Format:** OpenAPI / Postman-aligned REST  
**Last Updated:** October 2026  

---

## 1. Authentication & Security Flow

All protected endpoints require an HMAC-SHA256 JWT access token transmitted via the HTTP `Authorization` header:

```http
Authorization: Bearer <jwt_access_token>
```

### 1.1 Token Issuance & Refresh Pattern
1. **Client Authenticates:** Client submits `identifier` (phone/email) and `password` to `POST /api/auth/login`.
2. **Access Token Issued:** The backend returns an access token (`accessToken`, 15-minute validity) containing claims `{ sub: "<userId>", role: "<UserRole>", type: "access" }`.
3. **Session Persistence:** The Flutter client stores the token in memory (`ApiClient._authToken`) and writes it to `SharedPreferences`.
4. **Header Injection:** [ApiClient](file:///c:/Insa/grad_project/INSA-PROJECT/mobile/lib/services/api_client.dart) injects `Authorization: Bearer <token>` into all subsequent requests.
5. **Session Expiry / Rejection:** If the token is missing or expired, the backend returns `401 Unauthorized` with `{"error": {"code": "UNAUTHENTICATED"}}`. The client catches this and routes to the login screen.

---

## 2. Standardized Error Response Envelope

All error responses emitted by the Express backend adhere to a unified dual-envelope schema supporting modern and legacy consumer parsers:

```json
{
  "success": false,
  "message": "Human-readable description of error",
  "errors": [
    {
      "path": "status",
      "code": "invalid_value",
      "message": "Invalid option: expected one of \"DRAFT\"|\"PENDING_REVIEW\"|\"APPROVED\"|\"PUBLISHED\"|\"REJECTED\""
    }
  ],
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable description of error",
    "details": []
  }
}
```

### Error Code Reference Matrix
| HTTP Status | Error Code | Description / Trigger Cause |
| :---: | :--- | :--- |
| **`400 Bad Request`** | `VALIDATION_ERROR` | Schema rejection by Zod (missing body, invalid property types, unparseable status). |
| **`401 Unauthorized`** | `UNAUTHENTICATED` | Missing or invalid `Bearer` JWT token. |
| **`401 Unauthorized`** | `INVALID_CREDENTIALS` | Identifier not found or password mismatch on `/api/auth/login`. |
| **`403 Forbidden`** | `FORBIDDEN` | Caller lacks required RBAC role permission. |
| **`404 Not Found`** | `NOT_FOUND` | Content, farmer, or crop resource does not exist. |
| **`409 Conflict`** | `INVALID_TRANSITION` | Attempted illegal content workflow step (e.g. `DRAFT` $\rightarrow$ `PUBLISHED`). |
| **`500 Internal Error`**| `INTERNAL_SERVER_ERROR`| Unhandled server-side exception. |

---

## 3. Complete Endpoint Reference

### 3.1 Authentication Module (`/api/auth`)

#### `POST /api/auth/login`
Authenticates a user and issues JWT tokens.

- **Access Level:** Public
- **Request Body (JSON):**
  ```json
  {
    "identifier": "expert@gmail.com",
    "password": "Expert$2026"
  }
  ```
  *(Note: Accepts `identifier`, `email`, `phone`, or `username` as the login key).*
- **Success Response (`200 OK`):**
  ```json
  {
    "accessToken": "eyJhbGciOiJIUzI1Ni...",
    "token": "eyJhbGciOiJIUzI1Ni...",
    "user": {
      "id": "b1000000-0000-4000-8000-000000000002",
      "full_name": "Dr. Abebe Bekele",
      "phone": "+251912000001",
      "email": "expert@gmail.com",
      "role": "EXPERT",
      "preferred_language": "en"
    }
  }
  ```
- **Error Responses:**
  - `400 Bad Request`: Missing body or empty identifier (`"Request body is missing"`).
  - `401 Unauthorized`: User not found or password mismatch (`"Invalid credentials or unregistered account"`).

#### `POST /api/auth/register`
Self-registers a new Farmer or Extension Worker account.

- **Access Level:** Public
- **Request Body (JSON):**
  ```json
  {
    "fullName": "Dawit Haile",
    "phone": "+251911445566",
    "password": "Password$2026",
    "role": "FARMER",
    "preferredLanguage": "am"
  }
  ```
- **Success Response (`201 Created`):**
  ```json
  {
    "success": true,
    "user": {
      "id": "c2000000-0000-4000-8000-000000000005",
      "fullName": "Dawit Haile",
      "phone": "+251911445566",
      "role": "FARMER"
    }
  }
  ```

#### `GET /api/auth/me`
Retrieves current authenticated session profile.

- **Access Level:** Authenticated (`Bearer <token>`)
- **Success Response (`200 OK`):** User object matching active session.

---

### 3.2 Agricultural Content & Advisories (`/api/content`)

#### `GET /api/content`
Lists agricultural advisories with optional demographic/status filtering.

- **Access Level:** Authenticated
- **Query Parameters:**
  - `status` (string, optional): Case-insensitive. Supports `IN_REVIEW`, `in_review`, `in-review` (maps to `PENDING_REVIEW`), `DRAFT`, `APPROVED`, `PUBLISHED`, `REJECTED`.
  - `cropId` (uuid, optional): Filter by associated crop.
  - `language` (string, optional): Locale filter (`en`, `am`, `om`).
- **Success Response (`200 OK`):**
  ```json
  [
    {
      "id": "465026eb-aa48-4956-8378-1b7eac3cd5a5",
      "title": "Critical Teff Rust Advisory",
      "body": "Early signs of rust detected. Apply recommended fungicide immediately.",
      "cropId": "a1000000-0000-4000-8000-000000000001",
      "category": "Disease Alert",
      "status": "PUBLISHED",
      "authorId": "b1000000-0000-4000-8000-000000000002",
      "approvedBy": "b1000000-0000-4000-8000-000000000001",
      "createdAt": "2026-10-08T17:19:23.785Z",
      "updatedAt": "2026-10-08T17:19:23.950Z"
    }
  ]
  ```

#### `GET /api/content/:id`
Retrieves an advisory by ID. Supports both UUIDs and custom string mock IDs (e.g. `adv-1`).

- **Access Level:** Authenticated
- **Route Parameters:**
  - `id` (string, required): Permitted format: `z.string().trim().min(1)`.
- **Success Response (`200 OK`):** Single content item.
- **Not Found Response (`404 Not Found`):**
  ```json
  {
    "success": false,
    "message": "Content with id \"adv-1\" was not found.",
    "errors": [],
    "error": { "code": "NOT_FOUND", "message": "Content with id \"adv-1\" was not found.", "details": [] }
  }
  ```
  *(Note: Handled with 404 instead of throwing a PostgreSQL syntax error crash).*

#### `POST /api/content`
Drafts a new agronomic advisory item.

- **Access Level:** `EXTENSION_WORKER`, `EXPERT`, `ADMIN`
- **Request Body (JSON):**
  ```json
  {
    "title": "Fall Armyworm Maize Inspection Guide",
    "body": "Check whorls of young maize plants for ragged leaves and sawdust-like frass.",
    "cropId": "a1000000-0000-4000-8000-000000000002",
    "category": "Pest & Disease"
  }
  ```
- **Success Response (`201 Created`):** Returns newly created item in `DRAFT` status.

#### `POST /api/content/:id/submit-review`
Submits a drafted advisory to the expert validation queue.

- **Access Level:** `EXTENSION_WORKER`, `EXPERT`
- **Success Response (`200 OK`):** Updated item with `status: "PENDING_REVIEW"`.
- **Error Response (`409 Conflict`):** Invalid transition if item is not currently `DRAFT`.

#### `POST /api/content/:id/approve`
Approves an advisory item for broadcast publishing.

- **Access Level:** `EXPERT`, `ADMIN`
- **Success Response (`200 OK`):** Updated item with `status: "APPROVED"`.

#### `POST /api/content/:id/reject`
Rejects an advisory with mandatory feedback.

- **Access Level:** `EXPERT`
- **Request Body:** `{"comment": "Dosage instructions must specify milliliters per liter of water."}`
- **Success Response (`200 OK`):** Updated item with `status: "REJECTED"`.

#### `POST /api/content/:id/publish`
Publishes approved content and triggers automated farmer targeting and alert broadcast.

- **Access Level:** `EXPERT`, `ADMIN`
- **Success Response (`200 OK`):** Updated item with `status: "PUBLISHED"`.

---

### 3.3 Crop Master Catalog (`/api/crops`)

#### `GET /api/crops`
Returns all active crops in the master catalog.

- **Access Level:** Authenticated
- **Success Response (`200 OK`):**
  ```json
  [
    {
      "id": "a1000000-0000-4000-8000-000000000001",
      "name": "Teff",
      "description": "Indigenous Ethiopian cereal grain",
      "active": true
    },
    {
      "id": "a1000000-0000-4000-8000-000000000002",
      "name": "Maize",
      "description": "High-yield staple crop",
      "active": true
    }
  ]
  ```

#### `POST /api/crops`
Creates a new crop catalog entry.

- **Access Level:** `ADMIN` (`requirePermission('crop:manage')`)
- **Request Body:** `{"name": "Chickpeas", "description": "Legume rotation crop", "active": true}`
- **Success Response (`201 Created`):** Newly created crop object.

---

### 3.4 Farmers & Extension Operations (`/api/farmers`)

#### `GET /api/farmers`
Lists registered smallholder farmers joined with user identities.

- **Access Level:** `EXTENSION_WORKER`, `EXPERT`, `ADMIN`
- **Success Response (`200 OK`):** Array of farmer records including `userId`, `region`, `zone`, `woreda`, `kebele`, `alertEnabled`, and user details.

#### `POST /api/farmers`
Onboards a new farmer profile linked to an existing user ID.

- **Access Level:** `EXTENSION_WORKER`, `ADMIN`
- **Request Body:**
  ```json
  {
    "userId": "b871d0e1-6a26-4fcf-93ac-91181f23d7e7",
    "region": "Oromia",
    "zone": "East Shewa",
    "woreda": "Ada'a",
    "kebele": "02",
    "alertEnabled": true
  }
  ```
- **Success Response (`201 Created`):** Newly created farmer profile.

#### `POST /api/farmers/:id/crops`
Associates a crop with a farmer's plot.

- **Access Level:** `EXTENSION_WORKER`, `ADMIN`
- **Request Body:** `{"cropId": "a1000000-0000-4000-8000-000000000001"}`
- **Success Response (`201 Created`):** Confirmation of association.

---

### 3.5 Simulators & Multi-Channel Delivery

#### `POST /api/simulation/ivr/start`
Initiates an interactive voice response simulation session.

- **Access Level:** Public / Authenticated
- **Request Body:** `{"phone": "+251911223344"}`
- **Success Response (`200 OK`):**
  ```json
  {
    "sessionId": "ivr_pz94pdme",
    "status": "CONNECTED",
    "prompt": "Welcome to Agri-Insight Voice Beacon. Press 1 for Teff, 2 for Maize, * to exit."
  }
  ```

#### `POST /api/simulation/ivr/dtmf`
Sends a keypad DTMF tone to traverse the IVR tree.

- **Access Level:** Public / Authenticated
- **Request Body:** `{"sessionId": "ivr_pz94pdme", "key": "1"}`
- **Success Response (`200 OK`):** Next menu step or audio advisory playback transcript.

#### `POST /api/ussd`
Simulates a telecom USSD menu callback session.

- **Access Level:** Public / Authenticated
- **Request Body:**
  ```json
  {
    "sessionId": "ussd-session-98",
    "serviceCode": "*123#",
    "phoneNumber": "+251911000001",
    "text": ""
  }
  ```
- **Success Response (`200 OK`):** USSD prompt text (e.g. `CON Welcome to Agri-Insight Beacon:\n1. Latest Advisories\n2. Pest Reports`).

---

### 3.6 Administration & System Operations

#### `GET /api/health`
Liveness and readiness health check.

- **Access Level:** Public
- **Success Response (`200 OK`):**
  ```json
  {
    "status": "ok",
    "timestamp": "2026-10-08T18:00:00.000Z"
  }
  ```

#### `GET /api/admin/audit-logs`
Retrieves system security and operational audit logs.

- **Access Level:** `ADMIN`
- **Success Response (`200 OK`):** Array of audit log records with timestamps, actors, actions, and metadata.
