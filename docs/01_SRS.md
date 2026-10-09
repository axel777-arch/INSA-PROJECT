# Software Requirements Specification (SRS)
## Agri-Insight Beacon — Agricultural Information & Advisory Platform

**Document Version:** 1.0.0  
**Project:** INSA Graduation Project / Agri-Insight Beacon  
**Date:** October 2026  
**Status:** Approved & Implemented  

---

## 1. System Purpose & Scope

### 1.1 Purpose
The **Agri-Insight Beacon Platform** is an enterprise-grade digital agriculture ecosystem designed to bridge communication gaps between agricultural research experts, rural development extension workers, and localized smallholder farmers. The system provides an end-to-end pipeline for drafting agronomic advisories, verifying scientific recommendations through peer-reviewed validation workflows, targeting affected agricultural zones, and delivering actionable intelligence via cross-platform mobile/web apps and low-bandwidth telecom channels (SMS, IVR, USSD).

### 1.2 Core Problem Solved
Smallholder farmers in Ethiopia and East Africa face severe crop yield depreciation and pest infestations (e.g., *Puccinia graminis* teff rust, fall armyworm) due to delayed or untargeted agronomic recommendations. Traditional extension models rely on manual door-to-door visits with limited reach. Conversely, unfiltered digital advisories pose catastrophic crop loss risks if recommendations are unverified. 

Agri-Insight Beacon resolves these systemic bottlenecks by implementing:
1. **Strict Editorial & Approval Governance:** Content cannot reach farmers without cryptographic approval by verified agricultural experts.
2. **Context-Aware Targeting:** Algorithmic matching of advisories based on crop type, geographic zone (Region/Woreda/Kebele), and farmer language preference (e.g., Amharic, Oromo, English).
3. **Multi-Channel Fallback:** Integration of high-fidelity smartphone interfaces with telecom simulation engines for offline/feature-phone access (SMS broadcasts, interactive IVR DTMF trees, and USSD menus).

### 1.3 Target Audience
- **Smallholder Farmers:** View localized crop advisories, register plots, report field anomalies, and receive voice/text alerts.
- **Agricultural Extension Workers (Development Agents):** Onboard farmers, inspect crop diseases, capture field imagery, and submit case diagnoses.
- **Agronomy Specialists & Domain Experts:** Validate agronomic publications, approve/reject field diagnoses, and author pest mitigation directives.
- **System Administrators:** Manage RBAC privileges, inspect audit logs, and oversee system health.

---

## 2. Functional Requirements (FR)

### 2.1 Authentication & User Management (FR-AUTH)
- **FR-AUTH-01 (Multi-Format Identifier Login):** The system shall authenticate users using either their normalized E.164 phone number (`+2519...`), national 10-digit format (`09...`), or case-insensitive registered email address alongside an Argon2id-hashed password.
- **FR-AUTH-02 (Stateless JWT Session Issuance):** Upon successful authentication, the backend shall issue a cryptographically signed HMAC-SHA256 JWT access token (15-minute validity) accompanied by an opaque refresh token stored in PostgreSQL.
- **FR-AUTH-03 (Token Header Propagation):** Protected endpoints shall enforce `Authorization: Bearer <token>` validation, decoding claims (`sub`, `role`) into the active Express request context.
- **FR-AUTH-04 (Role-Specific Self-Registration):** Extension workers and farmers shall register with fullName, phone, password, role, and preferred language (`en`, `am`, `om`).

### 2.2 Agronomic Advisory & Content Lifecycle (FR-CONTENT)
- **FR-CONTENT-01 (Advisory Drafting):** Extension workers and experts can author content items specifying `title`, `body`, `cropId`, `category`, and localized language.
- **FR-CONTENT-02 (Finite State Workflow Transitions):** Content must transition through enforced state gates:
  $$\text{DRAFT} \longrightarrow \text{PENDING\_REVIEW} \longrightarrow \text{APPROVED} \longrightarrow \text{PUBLISHED}$$
  Alternatively, reviewers may transition items to `REJECTED` with mandatory diagnostic comments.
- **FR-CONTENT-03 (Broadcasting Trigger):** Transitioning content to `PUBLISHED` triggers the automated targeting engine, creating master broadcast messages and queuing recipient alerts.
- **FR-CONTENT-04 (Flexible Query Normalization):** The content listing API must accept case-insensitive status queries (`IN_REVIEW`, `in_review`, `in-review`, `PUBLISHED`, `DRAFT`) without schema rejections.
- **FR-CONTENT-05 (Universal Identification):** The content endpoint shall resolve standard RFC-4122 UUIDs and custom string mock identifiers (e.g., `adv-1`) with 404 fallbacks rather than database syntax crashes.

### 2.3 Field Case Escalation & Diagnostics (FR-CASE)
- **FR-CASE-01 (Case Escalation):** Extension workers can document acute field anomalies with severity tags, crop symptoms, and geographic coordinates.
- **FR-CASE-02 (Expert Diagnostic Feedback):** Agronomy experts can review escalated cases in [FieldCaseResponseScreen](file:///c:/Insa/grad_project/INSA-PROJECT/mobile/lib/features/agricultural_expert/screens/field_case_response_screen.dart), enter confirmed diagnoses, author farmer-visible recommendations, and store internal peer notes.

### 2.4 Cross-Platform Media Attachments (FR-MEDIA)
- **FR-MEDIA-01 (Cross-Platform Photo Ingestion):** The client must allow image selection via camera or file picker on Android, iOS, and Flutter Web.
- **FR-MEDIA-02 (Web-Safe Image Decoding):** On Flutter Web (`kIsWeb == true`), the UI must decode image bytes in-memory using `Image.memory(bytes)` or blob URLs via `Image.network(url)`, avoiding unsupported `dart:io` `Image.file(File(...))` crashes.
- **FR-MEDIA-03 (Native File Rendering):** On native desktop/mobile platforms, local disk images must render via platform-abstracted file streams.
- **FR-MEDIA-04 (Defensive Media UI):** Any broken, missing, or corrupted image payload must display a non-fatal `Icons.broken_image` fallback without widget tree disruptions.

### 2.5 Farmer Plot Management & Crop Records (FR-FARMER)
- **FR-FARMER-01 (Profile Management):** Maintain farmer location data (`region`, `zone`, `woreda`, `kebele`) and notification alert preferences (`alertEnabled`).
- **FR-FARMER-02 (Crop Associations):** Link farmers to one or more active crop records in the `farmer_crops` junction table.

### 2.6 Telecom Simulation & Multi-Channel Delivery (FR-TELECOM)
- **FR-TELECOM-01 (SMS Broadcast Engine):** Queue and track delivery states (`QUEUED` $\rightarrow$ `SENT` $\rightarrow$ `DELIVERED`) for targeted farmers.
- **FR-TELECOM-02 (IVR Voice DTMF Tree):** Simulate interactive voice response sessions enabling farmers to dial digits (`1`, `2`, `*`) to listen to audio advisory transcripts.
- **FR-TELECOM-03 (USSD Navigation Callback):** Provide session-based USSD callback menu traversal (`*123#`) for quick advisory lookup without data connection.

---

## 3. Non-Functional Requirements (NFR)

### 3.1 Security & Cryptography (NFR-SEC)
- **NFR-SEC-01 (Argon2id Password Storage):** Passwords must be hashed using Argon2id with memory cost $\ge 65536$ KB, iterations $\ge 3$, parallelism $\ge 4$. Plaintext passwords must never be logged or persisted.
- **NFR-SEC-02 (Cross-Origin Resource Sharing):** Express CORS middleware must dynamically validate origins, permitting development ports (`http://localhost:*`, `http://127.0.0.1:*`) and explicit production domains while blocking unauthorized third-party origins.
- **NFR-SEC-03 (Zero Information Leakage):** Public API error envelopes must suppress raw stack traces and internal SQL queries, exposing only user-safe operational messages.
- **NFR-SEC-04 (Input Sanitization & Schema Defense):** All request bodies, query strings, and route parameters must be validated by Zod schemas at controller entry points.

### 3.2 Performance & Scalability (NFR-PERF)
- **NFR-PERF-01 (API Response Latency):** Core REST endpoints (`/api/content`, `/api/crops`, `/api/auth/login`) must achieve 95th percentile latency below 200 ms under typical loads.
- **NFR-PERF-02 (Database Connection Pooling):** PostgreSQL access through `pg.Pool` must maintain pool bounds (maximum 20 connections, idle timeout 30,000 ms) to avoid connection starvation.

### 3.3 Cross-Platform Compatibility (NFR-COMPAT)
- **NFR-COMPAT-01 (Compilation Parity):** The Flutter codebase must compile to JavaScript/CanvasKit for Web without referencing platform-exclusive packages (`dart:io` top-level imports).
- **NFR-COMPAT-02 (Responsive UI):** Client layouts must adapt seamlessly between 360 px mobile viewport screens and widescreen desktop browser displays.

### 3.4 Reliability & Resilience (NFR-REL)
- **NFR-REL-01 (Defensive Client Handling):** All Flutter network services must encapsulate requests in try-catch handlers that catch `SocketException`, `ClientException`, and parse HTTP 4xx/5xx responses into `ApiException` envelopes.
- **NFR-REL-02 (Offline Mock Fallback):** Advisory feeds and farmer management screens must fall back to local cached mock models if the backend server becomes unreachable.

---

## 4. Role-Based Access Control (RBAC) Matrix

The system implements strict permission validation via `requirePermission(...)` middleware:

| Feature / Action | API Route / Resource | Farmer (`FARMER`) | Extension Worker (`EXTENSION_WORKER`) | Agricultural Expert (`EXPERT`) | Administrator (`ADMIN`) |
| :--- | :--- | :---: | :---: | :---: | :---: |
| **Authenticate & Refresh** | `POST /api/auth/login` | ✅ | ✅ | ✅ | ✅ |
| **View Published Advisories** | `GET /api/content?status=PUBLISHED` | ✅ | ✅ | ✅ | ✅ |
| **View Drafts / In-Review Content**| `GET /api/content?status=IN_REVIEW` | ❌ | ✅ | ✅ | ✅ |
| **Draft New Advisory** | `POST /api/content` | ❌ | ✅ | ✅ | ✅ |
| **Submit Content for Review** | `POST /api/content/:id/submit-review` | ❌ | ✅ | ✅ | ❌ |
| **Approve / Reject Advisory** | `POST /api/content/:id/approve` | ❌ | ❌ | ✅ | ✅ |
| **Publish Content Broadcast** | `POST /api/content/:id/publish` | ❌ | ❌ | ✅ | ✅ |
| **Submit Field Case Diagnosis** | `POST /api/cases/:id/response` | ❌ | ❌ | ✅ | ✅ |
| **Register & View Farmers** | `GET /api/farmers`, `POST /api/farmers` | ❌ | ✅ | ✅ | ✅ |
| **Manage Crop Master Catalog** | `POST /api/crops` | ❌ | ❌ | ❌ | ✅ |
| **Inspect System Audit Logs** | `GET /api/admin/audit-logs` | ❌ | ❌ | ❌ | ✅ |
| **Trigger IVR / USSD Simulators**| `POST /api/simulation/*` | ✅ | ✅ | ✅ | ✅ |
