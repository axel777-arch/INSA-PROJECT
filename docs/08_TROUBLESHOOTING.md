# Maintenance & Troubleshooting Guide
## Agri-Insight Beacon Platform

**Document Version:** 1.0.0  
**Target Audience:** DevOps Engineers, Support Specialists, Developers  
**Last Updated:** October 2026  

---

## 1. Logging & Observability Infrastructure

Agri-Insight Beacon includes real-time diagnostics on both the server and client tiers to accelerate issue isolation:

### 1.1 Express Backend Diagnostics
All incoming HTTP requests and errors are routed through dedicated logging middleware:
- **Request Logger ([requestLogger](file:///c:/Insa/grad_project/INSA-PROJECT/backend/src/middleware/logger.middleware.ts)):**
  Prints timestamp, method, target URL, and response latency. Request bodies are printed for non-GET requests with sensitive credentials (`password`) redacted.
  ```text
  [API REQUEST]  2026-10-08T17:19:23.658Z
    POST /api/auth/login
    Body: {"identifier":"expert@agri-insight.et","password":"[REDACTED]"}
  [API RESPONSE] POST /api/auth/login → 200 (121ms)
  ```
- **Error Middleware ([errorHandler](file:///c:/Insa/grad_project/INSA-PROJECT/backend/src/middleware/error.middleware.ts)):**
  Whenever an invalid payload triggers a `400 Bad Request`, the terminal outputs an error block detailing the rejected field and expected values:
  ```text
  ❌ [400 VALIDATION FAILURE] GET /api/content?status=invalid_status
     Field Errors:
  {
      "status": [
          "Invalid option: expected one of \"DRAFT\"|\"PENDING_REVIEW\"|\"APPROVED\"|\"PUBLISHED\"|\"REJECTED\""
      ]
  }
     Specific Issues:
  [
      {
          "path": "status",
          "code": "invalid_value",
          "message": "Invalid option: expected one of \"DRAFT\"|\"PENDING_REVIEW\"|\"APPROVED\"|\"PUBLISHED\"|\"REJECTED\""
      }
  ]
  ```

### 1.2 Flutter Client Interceptor Logging
The Flutter client's [ApiClient](file:///c:/Insa/grad_project/INSA-PROJECT/mobile/lib/services/api_client.dart) prints structured messages in debug mode:
- **Outgoing Requests:** `🌐 [API CLIENT] POST http://localhost:3000/api/auth/login (Auth: false)`
- **Request Bodies:** `   Request Body: {"identifier":"admin@gmail.com","password":"..."}`
- **Successful Responses:** `✅ [API CLIENT] POST http://localhost:3000/api/auth/login -> 200`
- **Error Responses:**
  ```text
  ⚠️ [API CLIENT ERROR] POST http://localhost:3000/api/auth/login
     Status: 401
     Error Message: Invalid credentials or unregistered account
     Details: null
     Raw Response: {"success":false,"message":"Invalid credentials or unregistered account",...}
  ```

---

## 2. Incident Response & Troubleshooting Matrix

| Symptom / Error Message | Root Cause | Immediate Remediation Step |
| :--- | :--- | :--- |
| **`401 Unauthorized` on Login** | 1. Using incorrect password.<br>2. Phone number formatting mismatch (`09...` vs `+2519...`).<br>3. Uppercase email in database search. | 1. Use verified seeded accounts (`admin@gmail.com` / `Admin$2026`).<br>2. Backend normalizes both `09` and `+2519` formats automatically.<br>3. Verify terminal log: check whether failure is `Non-existent user` or `Password mismatch`. |
| **`400 Bad Request` on Content API** | 1. Sending unmapped `status` query string.<br>2. Strict UUID rejection on custom string ID (e.g. `adv-1`). | 1. Ensure `contentStatusQuerySchema` in `content.schema.ts` maps `IN_REVIEW` $\rightarrow$ `PENDING_REVIEW`.<br>2. Confirm `idParamSchema` permits string identifiers (`z.string().trim().min(1)`). |
| **`Assertion failed: !kIsWeb` on Image Preview** | Invoking native `Image.file(File(path))` directly on Flutter Web. | 1. Remove `import 'dart:io'` from the widget.<br>2. Import [platform_image.dart](file:///c:/Insa/grad_project/INSA-PROJECT/mobile/lib/core/utils/platform_image.dart).<br>3. Use `Image.network` for web URLs or `Image.memory` via `file.readAsBytes()` for `XFile` instances. |
| **CORS Error: `No 'Access-Control-Allow-Origin' header`** | Flutter Web client running on an unapproved port (e.g. `8080` vs `3000`). | In `backend/src/app.ts`, ensure CORS middleware includes dynamic localhost matching: `/^https?:\/\/(localhost\|127\.0\.0\.1)(:\d+)?$/`. |
| **`Database connection failed: connect ECONNREFUSED 127.0.0.1:5433`** | PostgreSQL Docker container is stopped or port `5433` is blocked. | Run `docker compose ps`. If stopped, execute `docker compose up -d postgres` and wait for healthy status. |
| **`No inputs were found in config file 'tsconfig.json'`** | Root `tsconfig.json` specifies `"rootDir": "src"` but sources are in `backend/src/`. | Update root `tsconfig.json` `include` array to: `["database/**/*.ts", "drizzle.config.ts", "backend/src/**/*.ts"]`. |
| **`Network error or backend down` in Flutter App** | Mobile emulator attempting to connect to `localhost:3000` instead of gateway IP. | On Android Emulator, configure API base URL to `http://10.0.2.2:3000/api`. On Web, use `http://localhost:3000/api`. |

---

## 3. Database Recovery & Clean Re-Seeding

If the local database enters an inconsistent state, reset it with this clean procedure:

```bash
# 1. Stop containers and destroy PostgreSQL persistent volume
docker compose down -v

# 2. Re-create container and wait for healthy check
docker compose up -d postgres

# 3. Apply DDL schema and seed fresh baseline records
cd backend
npm run db:migrate
npm run db:seed
```
This restores all test accounts, crops, and sample advisories to their initial state.
