# System Architecture & Design Specification
## Agri-Insight Beacon Platform

**Document Version:** 1.0.0  
**Target Audience:** Software Architects, Lead Engineers, Technical Evaluators  
**Last Updated:** October 2026  

---

## 1. High-Level System Architecture

Agri-Insight Beacon employs a **decoupled multi-tier client-server architecture** designed for high modularity, fault tolerance, and cross-platform flexibility:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                              │
│                                                                        │
│   ┌──────────────────────────┐         ┌───────────────────────────┐   │
│   │   Flutter Web Browser    │         │  Flutter Mobile (Android) │   │
│   │   (Chrome / CanvasKit)   │         │  (Native Dalvik / ARM)    │   │
│   └────────────┬─────────────┘         └─────────────┬─────────────┘   │
└────────────────┼─────────────────────────────────────┼─────────────────┘
                 │ HTTP / REST (JSON)                  │
                 ▼                                     ▼
┌────────────────────────────────────────────────────────────────────────┐
│                         API GATEWAY / INGRESS                          │
│   - CORS Origins Middleware (Localhost / Wildcard Port Matching)       │
│   - Request Logger Middleware (Timing, Method, URL, Body Trace)        │
│   - JWT Bearer Authentication & RBAC Permission Filter                 │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼────────────────────────────────────┐
│                      EXPRESS.JS APPLICATION TIER                       │
│                                                                        │
│   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌─────────┐ │
│   │ Auth Module  │   │ Content Mod. │   │ Farmers Mod. │   │ Crops   │ │
│   └──────┬───────┘   └──────┬───────┘   └──────┬───────┘   └────┬────┘ │
│   ┌──────┴───────┐   ┌──────┴───────┐   ┌──────┴───────┐   ┌────┴────┐ │
│   │ Simulators   │   │ Targeting    │   │ Messaging    │   │ Audit   │ │
│   │ (IVR / USSD) │   │ Engine       │   │ Service      │   │ Logger  │ │
│   └──────────────┘   └──────────────┘   └──────────────┘   └─────────┘ │
│                                                                        │
│   ┌────────────────────────────────────────────────────────────────┐   │
│   │ Central Error Middleware (Zod Issues, AppError, Status Envelopes)│
│   └────────────────────────────────────────────────────────────────┘   │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ SQL (Drizzle ORM via pg.Pool)
┌───────────────────────────────────▼────────────────────────────────────┐
│                         PERSISTENCE LAYER                              │
│                                                                        │
│   ┌────────────────────────────────────────────────────────────────┐   │
│   │                     PostgreSQL 16 Database                     │   │
│   │  Tables: users, content, content_reviews, crops, farmers,      │   │
│   │          farmer_crops, messages, message_recipients,           │   │
│   │          audit_logs, refresh_tokens                            │   │
│   └────────────────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Frontend Architecture (Flutter Client)

### 2.1 Directory Structure & Layering
The Flutter client in `/mobile/lib` follows a **feature-first clean layered architecture**:

```
mobile/lib/
├── core/                       # Shared platform infrastructure
│   ├── config/                 # AppConfig, UserSession, Environment
│   ├── constants/              # AppSizes, AppStrings
│   ├── routing/                # AppRouter (route names, Navigator 2.0 map)
│   ├── theme/                  # AppColors, AppTheme
│   ├── utils/                  # Cross-platform utilities
│   │   ├── platform_image.dart      # Conditional export switch
│   │   ├── platform_image_io.dart   # Native File image renderer
│   │   └── platform_image_web.dart  # Web-safe Image.network renderer
│   └── widgets/                # Atomic UI design system (AppButton, AppTextField)
├── features/                   # Independent business domains
│   ├── admin/                  # Admin user management & audit logs
│   ├── agricultural_expert/    # Expert review queues & field case diagnostics
│   ├── auth/                   # Login, Registration, Splash screen
│   ├── content/                # Advisory lists and authoring forms
│   ├── extension_worker/       # Farmer management, observations, crop records
│   ├── farmer/                 # Farmer dashboard, alerts, profile
│   └── simulator/              # Telecom simulation (IVR dialer, SMS console)
├── models/                     # Immutable data transfer models (fromJson / toJson)
└── services/                   # Centralized API clients & repository abstractions
    ├── api_client.dart         # Singleton HTTP client with debug logging & error mapping
    ├── auth_service.dart       # Session state, JWT storage & profile retrieval
    ├── content_service.dart    # Advisory CRUD & workflow endpoints
    ├── farmer_service.dart     # Farmer plot management
    └── messaging_service.dart  # SMS / broadcast dispatches
```

### 2.2 Cross-Platform Image Handling (`kIsWeb` Abstraction)
On desktop and mobile operating systems, Flutter reads local files directly via `dart:io` `File`. On modern Web browsers, `dart:io` lacks direct filesystem access and throws a fatal runtime assertion:
$$\text{Assertion failed: !kIsWeb ("Image.file is not supported on Flutter Web...")}$$

To eliminate this vulnerability, Agri-Insight Beacon implements an abstraction barrier:

```dart
// mobile/lib/core/utils/platform_image.dart
export 'platform_image_web.dart'
    if (dart.library.io) 'platform_image_io.dart';
```

1. **Native Implementation (`platform_image_io.dart`):** Compiles only when `dart.library.io` is available, calling `Image.file(File(path))`.
2. **Web Implementation (`platform_image_web.dart`):** Compiles when targeting web browsers, delegating safely to `Image.network(path)`.
3. **Consumer Screen (`field_case_response_screen.dart`):**
   ```dart
   if (kIsWeb) {
     if (file.path.startsWith('http://') || file.path.startsWith('blob:')) {
       return Image.network(file.path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imageFallback());
     }
     return FutureBuilder<Uint8List>(
       future: file.readAsBytes(),
       builder: (context, snapshot) {
         if (snapshot.hasData) return Image.memory(snapshot.data!, fit: BoxFit.cover);
         if (snapshot.hasError) return _imageFallback();
         return _imageLoading();
       },
     );
   } else {
     return renderPlatformFileImage(file.path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imageFallback());
   }
   ```

### 2.3 State Management & Resilience
- **UserSession & SharedPreferences:** Session authentication tokens are held in a global runtime singleton [UserSession](file:///c:/Insa/grad_project/INSA-PROJECT/mobile/lib/core/config/user_session.dart) and mirrored to persistent `SharedPreferences` for transparent recovery on browser reloads.
- **Fail-Safe Offline Caching:** If a network failure occurs, [ContentService](file:///c:/Insa/grad_project/INSA-PROJECT/mobile/lib/services/content_service.dart) and [FarmerService](file:///c:/Insa/grad_project/INSA-PROJECT/mobile/lib/services/farmer_service.dart) intercept the exception and supply pre-configured offline mock models, preventing app termination.

---

## 3. Backend Architecture (Express & Node.js)

### 3.1 Five-Stage Request Pipeline
Every request entering the Express backend passes through five deterministic processing stages:

```
Client Request
      │
      ▼
┌──────────────┐
│    Router    │  Matches HTTP Verb and Path (e.g. POST /api/content/:id/approve)
└──────┬───────┘
      │
      ▼
┌──────────────┐
│  Middleware  │  requireAuth (JWT verify) + requirePermission ('content:approve')
└──────┬───────┘
      │
      ▼
┌──────────────┐
│  Validator   │  Zod Schema safeParse (Body, Query, Params) -> Returns 400 on error
└──────┬───────┘
      │
      ▼
┌──────────────┐
│  Controller  │  Orchestrates business flow, maps HTTP status codes (200, 201)
└──────┬───────┘
      │
      ▼
┌──────────────┐
│   Service    │  Workflow state assertion, Drizzle ORM execution, Database transaction
└──────┬───────┘
      │
      ▼
Client Response / Next(err) to Error Handler
```

### 3.2 Zod Validation & Schema Normalization
Validation occurs before business logic execution. For example, status query parameters are sanitized via functional transformations:

```typescript
// backend/src/modules/content/content.schema.ts
export const contentStatusQuerySchema = z
  .string()
  .transform((val) => {
    const normalized = val.trim().toUpperCase().replace(/-/g, "_");
    if (normalized === "IN_REVIEW") return "PENDING_REVIEW";
    return normalized;
  })
  .pipe(z.enum(contentStatusEnum.enumValues));
```
This guarantees that queries using `status=in-review`, `status=in_review`, or `status=IN_REVIEW` are mapped to the PostgreSQL database enum `PENDING_REVIEW`.

### 3.3 Centralized Error Middleware
Unhandled exceptions and schema violations are caught by [errorHandler](file:///c:/Insa/grad_project/INSA-PROJECT/backend/src/middleware/error.middleware.ts):
- **ZodError:** Formats field and form errors and prints a detailed development diagnostics box to stdout before returning HTTP 400.
- **AppError / ContentNotFoundError:** Returns HTTP 404/409 with unified envelopes.
- **Unhandled Failures:** Catches all unexpected promise rejections, logs them with timestamp and route info, and emits a safe HTTP 500 payload.

---

## 4. Annotated Directory Tree

```
INSA-PROJECT/
├── backend/                             # Express REST API Server
│   ├── package.json                     # Node.js dependencies & scripts
│   ├── tsconfig.json                    # TypeScript compiler configuration
│   ├── drizzle.config.ts                # Drizzle ORM CLI configuration
│   ├── tests/                           # Integration test suites
│   │   └── e2e-workflow.test.ts         # Full end-to-end lifecycle automated tests
│   └── src/
│       ├── app.ts                       # Express application assembly & CORS
│       ├── server.ts                    # HTTP server listener & DB init
│       ├── config/                      # Environment schema & RBAC permissions
│       ├── db/                          # Database connection pool & schemas
│       ├── middleware/                  # Auth, role, logging, error handlers
│       ├── modules/                     # Domain modules (Controller, Service, Routes)
│       │   ├── admin/                   # Audit log inspection & administrative routes
│       │   ├── auth/                    # Login, register, token issuance
│       │   ├── content/                 # Advisory lifecycle, workflows, review gates
│       │   ├── crops/                   # Crop master data
│       │   ├── farmers/                 # Farmer profile & plot management
│       │   ├── messaging/               # SMS broadcast dispatchers
│       │   └── simulation/              # IVR dialer and session simulators
│       ├── services/                    # Shared system services (Targeting, USSD)
│       └── utils/                       # AppError classes and utility helpers
├── database/                            # Shared Database Resources
│   ├── schema/                          # Drizzle schema definitions
│   │   ├── users.ts                     # User identities & role enums
│   │   ├── content.ts                   # Advisories & contentStatusEnum
│   │   ├── contentReviews.ts            # Expert audit trail & rejection remarks
│   │   ├── crops.ts                     # Agricultural crop catalog
│   │   ├── farmers.ts                   # Farmer demographic & region data
│   │   ├── farmerCrops.ts               # Farmer-crop junction table
│   │   ├── messages.ts                  # Master broadcast notifications
│   │   ├── messageRecipients.ts         # Recipient delivery states (QUEUED/SENT)
│   │   └── auditLogs.ts                 # Security and workflow audit log entries
│   └── seed.ts                          # Deterministic database seeder script
├── mobile/                              # Flutter Client Application
│   ├── pubspec.yaml                     # Flutter dependencies (http, file_picker, etc.)
│   ├── analysis_options.yaml            # Dart static analysis lint rules
│   ├── test/                            # Unit & widget test suites
│   │   ├── widget_test.dart             # Smoke test
│   │   └── services/                    # Service tests (ApiClient, AuthService, etc.)
│   └── lib/                             # Application source code (see Section 2.1)
├── docs/                                # Enterprise documentation suite (SRS, Architecture, etc.)
├── docker-compose.yml                   # PostgreSQL container orchestration
├── Dockerfile                           # Multi-stage production container build
├── tsconfig.json                        # Root TypeScript project references
└── Agri-Insight_API.postman_*.json      # Postman collection & environment test assets
```
