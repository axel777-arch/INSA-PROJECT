# Agri-Insight Beacon
## Final Development Plan and Team Responsibilities

**Project:** Agri-Insight Beacon: Mobile Agricultural Information and Advisory Platform  
**Project Context:** INSA Graduation Project  
**Target Environment:** Ethiopia  
**Technology Stack:** Flutter, Node.js, Express.js, TypeScript, PostgreSQL, Drizzle ORM, Docker  
**Project Approach:** Improve the existing system, preserve working functionality, and implement additional features through coordinated development.

---

## 1. Project Overview

Agri-Insight Beacon is an agricultural information and advisory platform designed to help Ethiopian farmers access relevant, understandable, and trustworthy agricultural information.

Many farmers face challenges accessing agricultural experts, receiving timely crop advice, identifying local market prices, and obtaining information when internet connectivity or digital literacy is limited.

The platform connects farmers, agricultural extension workers, agricultural experts, and administrators through a shared system.

The project is not intended to replace extension workers or agricultural experts. Instead, it provides tools to organize fieldwork, record agricultural information, manage requests, review recommendations, and deliver relevant information through suitable communication channels.

### Our vision

Build a practical, accessible, and reliable agricultural support system that reflects real farming conditions in Ethiopia, including local languages, administrative areas, seasonal farming practices, limited connectivity, and different levels of access to technology.

## 2. Project Objectives

- Help farmers receive relevant agricultural information and submit questions.
- Enable extension workers to register farmers, manage assigned records, record observations, and follow up on agricultural problems.
- Allow experts to review recommendations and provide specialized agricultural guidance.
- Provide secure account management, staff verification, and role-based access.
- Support appropriate information delivery through the mobile application, SMS, USSD, and voice-based interfaces, distinguishing simulations from real telecommunications integrations.
- Provide useful local agricultural information, including market prices, market days, crop calendars, and verified emergency alerts.
- Preserve historical records, recommendation revisions, and case outcomes.
- Improve usability, accessibility, security, and reliability without unnecessarily replacing the existing architecture.

## 3. Existing System and Development Strategy

The existing repository contains a Flutter application, a TypeScript/Express backend, a PostgreSQL database, Drizzle ORM schemas and migrations, and Docker configuration.

The system already contains authentication, farmer profiles, crop management, advisory authoring and review, publishing, message targeting, and SMS, IVR, and USSD simulation components.

However, the previous technical investigation identified several areas requiring further work, including disconnected administrator screens, insecure default farmer credentials, missing farmer-record authorization checks, incomplete field-case integration, and simulated rather than live communication services.

These findings are the starting point for development, not a claim that every issue remains unfixed.

**Development rule:** Inspect the latest repository before changing code. Preserve working features, verify existing fixes, and implement additions within the current architecture wherever practical.

## 4. User Roles and Responsibilities

### 4.1 Farmer

Farmers should have a simple experience appropriate to their access to technology.

Farmers who want to use the application can log in using their assigned login ID, such as their phone number, and a secure password. They can manage permitted profile information, access agricultural information, submit questions, receive responses, and track requests.

Farmers who do not use the application remain supported through extension-worker-assisted registration and appropriate communication channels such as USSD, SMS, and voice services when available.

Farmers should be able to access relevant information without being required to own a smartphone.

### 4.2 Agricultural Extension Worker

Extension workers connect the platform with real agricultural fieldwork.

Their responsibilities include:

- Registering farmers and recording their crops, locations, languages, and contact information.
- Managing farmers assigned to them and coordinating with authorized colleagues when responsibilities overlap.
- Recording field observations, technical information, photographs, and follow-up activities.
- Receiving and organizing farmers' questions.
- Preparing agricultural advisory drafts when necessary.
- Requesting expert assistance and communicating with other extension workers.
- Following cases until the farmer's problem is addressed or further action is recorded.

Extension workers should not need to visit every farmer at fixed intervals merely to identify problems. Farmers should be able to request assistance when needed, while extension workers retain responsibility for necessary field visits and technical follow-up.

### 4.3 Agricultural Expert

Experts provide specialized agricultural knowledge and oversee recommendations that require professional review.

Their responsibilities include:

- Reviewing submitted advisory drafts.
- Approving, rejecting with an explanation, or requesting revisions or additional information.
- Returning drafts to the responsible extension worker for correction without discarding the existing work.
- Creating expert-authored agricultural information where authorized.
- Responding to escalated agricultural cases.
- Communicating with extension workers and other experts.
- Reviewing relevant field reports and validating information before publication.
- Supporting the verification of agricultural emergency reports and market information where assigned.

### 4.4 Administrator

The administrator manages the platform rather than making ordinary agricultural recommendations.

Responsibilities include:

- Reviewing staff registration applications and submitted credentials.
- Approving or rejecting extension-worker and expert applications, recording the decision and reason.
- Managing accounts, roles, permissions, and account status.
- Maintaining system configuration and authorized geographic or crop reference data.
- Reviewing audit logs and system activity.
- Managing authorized assignments and monitoring operational problems.
- Maintaining administrative records and helping resolve account or system issues.

Sensitive documents must only be accessible to authorized administrators and other explicitly permitted personnel.

## 5. Core Agricultural Advisory Workflow

The primary workflow connects farmer questions, extension-worker activities, expert oversight, and farmer communication.

1. A farmer submits a question through an available channel, or an extension worker records a problem observed in the field.
2. The system records the request, farmer, location, crop, date, and relevant details.
3. The request is assigned to the responsible extension worker or appropriate authorized staff member.
4. The extension worker investigates the problem, records observations, and prepares advice or escalates the case when necessary.
5. If expert review is required, the extension worker submits an advisory draft for review.
6. The expert approves the draft, rejects it with an explanation, or requests revision or further information.
7. A draft requiring revision returns to the responsible author with the previous version and review comments preserved.
8. An authorized expert or administrator publishes approved content according to the system's permissions.
9. The system targets the intended farmers using verified profile information, including relevant crops, administrative areas, language preferences, and eligibility rules.
10. The system records the delivery attempt and available delivery status.
11. The farmer receives the information through the supported channel and can request further assistance where supported.
12. The case is resolved and closed when appropriate, while its history remains available to authorized staff. If further assistance is required, the case can be reopened or linked to a follow-up.

Not every farmer question needs a formal advisory draft. Routine questions can be answered directly by authorized staff when appropriate. Recommendations requiring expert oversight must follow the review process.

## 6. Additional Features

The team will evaluate and implement the following agreed features according to priority and integration readiness.

### Core workflow and management

- Farmer-to-extension-worker assignment and authorized shared coverage.
- Farmer requests, case categorization, status tracking, and follow-up.
- Advisory version history, review comments, revision requests, and searchable archives.
- Staff communication between extension workers, between experts, and between experts and extension workers.
- Staff application forms with appropriate document attachments and administrator verification.
- Working administrator dashboards, account approvals, audit logs, and role-based access control.
- Notifications reflecting real system events and updated records.

### Agricultural information

- Local market directory and market-day information.
- Market prices recorded with commodity, unit, market, source, and observation date.
- Validation and freshness indicators for time-sensitive information.
- Crop-specific advisories and seasonal crop calendars.
- Expert-authored planting, fertilizer, and harvesting reminders.
- Location-relevant weather and emergency information from verified sources.
- A community pest and disease map based on anonymized, expert-confirmed reports.

### Accessibility and farmer support

- Large visual quick-action buttons for common tasks.
- Voice-first interaction where technically supported.
- Improved IVR and USSD simulations, with clear separation from real telecom integrations.
- Offline access to saved advisories and appropriate synchronization when connectivity returns.
- Ask-an-extension-worker functionality with optional photographs and request-status tracking.
- Multilingual interfaces and agricultural information, initially prioritizing agreed Ethiopian languages.
- Responsive web interfaces and improved mobile usability.

Features involving external data or telecommunications must clearly indicate whether they are operational integrations or demonstrations.

## 7. Team Responsibilities

**Important:** Hanifa is not a member of the current team. The project is developed by a 5-member team.

### Team Members

| # | Full Name | CTC Number | Classroom Number |
|---|-----------|------------|------------------|
| 1 | Eldana Babu | CTC-3321-26 | 3003 |
| 2 | Etsegenet Amsalu | CTC-1495-26 | 3003 |
| 3 | Ezra Ambaw | CTC-2682-26 | 3003 |
| 4 | Hawi Jarso | CTC-3472-26 | 3003 |
| 5 | Fuad Yibrie | CTC-0345-26 | 3003 |

### Member 1: Authentication, User Accounts, Authorization, Password Provisioning, and Shared Media Contract

**Assigned member:** Eldana Babu

**Primary objective:** Establish a secure authentication backbone, manage user accounts and staff provisioning, enforce server-side role authorization, and provide the shared media/attachment contract across workflows.

**Main areas of the repository:**

- `backend/src/modules/auth/`
- `backend/src/middleware/auth.ts`
- `backend/src/services/` (password hashing and token management)
- `database/schema/users.ts`
- Shared media storage and access primitives (`FR-MEDIA`, `canAccessFarmer`)
- `mobile/lib/features/auth/`
- `mobile/lib/services/auth_service.dart`

**Deliverables:**

- Secure credential management, eliminating phone-number-as-password vulnerabilities.
- Server-side password hashing (`hashPassword`) and JWT token lifecycle.
- Role-based authorization middleware protecting sensitive endpoints by role and record scope.
- Shared attachment/photo upload contract for observations, field cases, and document submissions.
- Core user management and authentication state persistence.

**Acceptance criteria:** Users authenticate securely with hashed passwords; JWT tokens contain valid roles and permissions; unauthenticated and unauthorized requests to protected endpoints return 401/403; shared media attachments conform to the agreed contract.

### Member 2: Farmer Management, Crop Associations, Farmer-Worker Assignments, Field Observations, and Follow-Up Records

**Assigned member:** Etsegenet Amsalu

**Primary objective:** Deliver reliable farmer profile management supporting both app and basic-phone farmers, crop associations, extension-worker assignments with concurrency protection, structured field observation logging with photo attachments, follow-up records, and seamless escalation into expert cases.

**Main areas of the repository:**

- `backend/src/modules/farmers/`
- `backend/src/modules/observations/`
- `backend/src/modules/followups/`
- `database/schema/farmers.ts`
- `database/schema/farmerWorkerAssignments.ts`
- `database/schema/fieldObservations.ts`
- `database/schema/followUpRecords.ts`
- `mobile/lib/features/extension_worker/screens/register_farmer_flow.dart`
- `mobile/lib/features/extension_worker/`

**Deliverables:**

- Comprehensive farmer profiles supporting both smartphone users and basic-phone farmers (`hasAppAccess: false`, nullable `userId`).
- Dual-mode farmer registration flow with one-time temporary password display for app-enabled accounts.
- Hierarchical Ethiopian administrative location selection (Region → Zone → Woreda → Kebele).
- Crop-to-farmer association management.
- Farmer-to-extension-worker assignment engine supporting primary and temporary coverage with database row-level locking (`FOR UPDATE`) to prevent assignment race conditions.
- Technical field observation recording with crop tags, GPS/location context, photo attachments, and severity levels.
- Longitudinal follow-up records tracking ongoing field interventions and outcomes.
- Automatic escalation bridge: escalating an observation creates a tracked case in `cases` and dispatches notification alerts to agricultural experts.

**Acceptance criteria:** Extension workers can register both smartphone and basic-phone farmers; assignments prevent concurrent race conditions; field observations and follow-up visits record accurately with attachments; escalated observations automatically generate expert cases and notify active experts.

### Member 3: Staff Verification, Administration, Advisory Review Lifecycle, and Security

**Assigned member:** Ezra Ambaw

**Primary objective:** Secure staff onboarding through document verification, administrative oversight, audit trail logging, and management of the formal advisory review lifecycle (`NEEDS_REVISION`, versioning, review comments).

**Main areas of the repository:**

- `backend/src/modules/admin/`
- `backend/src/modules/content/`
- `database/schema/content.ts` & `database/schema/contentReviews.ts`
- `database/schema/auditLogs.ts`
- `mobile/lib/features/admin/`
- `mobile/lib/features/content/` & `mobile/lib/features/agricultural_expert/`

**Deliverables:**

- Staff application verification for extension workers and experts, requiring document uploads and admin review before granting account access.
- Administrator approval and rejection workflows recording timestamps, reviewer ID, and feedback notes.
- Audit logging system tracking sensitive administrative and authorization actions.
- Structured advisory review lifecycle allowing experts to approve, reject, or request revisions (`NEEDS_REVISION`) with preserved version history and feedback comments.
- Publishing controls ensuring only verified, expert-approved agricultural content is targeted to farmers.

**Acceptance criteria:** Pending staff applications cannot access protected staff features until approved; all admin actions generate audit log entries; advisory revision requests preserve prior drafts and review comments without losing history.

### Member 4: Farmer Cases, Case Escalation, Expert Diagnostic Responses, and System Notifications

**Assigned member:** Hawi Jarso

**Primary objective:** Connect farmer and field-escalated agricultural issues with expert diagnostics (`FieldCaseResponseScreen`), case communications, status tracking, and automated system notifications.

**Main areas of the repository:**

- `backend/src/modules/cases/`
- `backend/src/modules/notifications/`
- `database/schema/cases.ts`
- `database/schema/notifications.ts`
- `mobile/lib/features/cases/`
- `mobile/lib/features/agricultural_expert/screens/field_case_response_screen.dart`
- `mobile/lib/features/notifications/`

**Deliverables:**

- Case management workflow supporting statuses: `OPEN`, `ASSIGNED`, `IN_PROGRESS`, `RESOLVED`, `CLOSED`.
- Expert diagnostic response screen (`FieldCaseResponseScreen`) enabling experts to author structured advice and recommendations for field cases.
- Case event logging and communication thread tracking between farmers, extension workers, and experts.
- System-wide notification engine (`createNotification`, `notifyRoles`) dispatching alerts for case escalations, assignments, and advisory publications.
- Seamless intake of escalated field observations created by extension workers.

**Acceptance criteria:** Escalated cases appear in the expert queue; experts can respond with structured diagnoses; status transitions reflect accurately; notifications are delivered to appropriate roles without cross-tenant leakage.

### Member 5: Farmer Mobile Experience, Multilingual Localization, Offline Support, and Telecom Simulators

**Assigned member:** Fuad Yibrie

**Primary objective:** Maximize accessibility and usability for Ethiopian farmers through a visual, multilingual mobile dashboard, offline advisory storage, an "Ask an Extension Worker" flow, and realistic telecom simulations (SMS, USSD, IVR).

**Main areas of the repository:**

- `mobile/lib/features/farmer/`
- `mobile/lib/features/simulator/`
- `mobile/lib/core/localization/` / `l10n/`
- `backend/src/modules/simulation/`
- `backend/src/services/sms/`, `backend/src/services/ussd/`, `backend/src/services/ivr/`
- Offline local caching and sync services

**Deliverables:**

- Accessible, high-contrast farmer dashboard tailored for low-literacy users with prominent quick-action tiles.
- Multilingual interface support prioritizing Ethiopian national and regional working languages (Amharic, Afaan Oromoo, Tigrinya, English).
- Offline advisory library caching published content for viewing in areas with unreliable internet connectivity.
- "Ask an Extension Worker" screen allowing farmers to submit questions and request field visits.
- Realistic telecom simulation endpoints and mobile testbeds for USSD menus, SMS push advisories, and IVR voice prompts, clearly labeled as simulations.

**Acceptance criteria:** Farmers can navigate core features in their preferred language; saved advisories remain accessible offline; questions can be submitted from the mobile interface; telecom simulators demonstrate realistic menu navigation and message delivery without claiming live telco integration.

## 8. Shared Development Rules

All members must follow these rules:

1. Inspect the latest repository and documentation before making changes.
2. Preserve existing working features and use the current architecture unless a justified change is approved.
3. Do not overwrite the original README or delete existing documentation.
4. Coordinate changes to shared database schemas, migrations, models, API contracts, and permissions.
5. Use separate Git branches and meaningful commits.
6. Validate request data on the backend and enforce authorization on the server.
7. Never store passwords in plain text or use a phone number as a permanent password.
8. Protect uploaded documents, personal data, and farmer locations.
9. Avoid fake success messages, disconnected buttons, and hard-coded data presented as live system records.
10. Label mock data and simulated integrations clearly.
11. Add or update tests for new functionality and regression risks.
12. Document new environment variables, migration steps, endpoints, and known limitations.
13. Do not duplicate an existing feature without checking whether it can be extended.
14. Each member must report modified files, migrations, endpoints, tests, and remaining issues before integration.

## 9. Shared Database and API Coordination

Before implementation, the team must agree on shared contracts for:

- User identities, roles, account status, and staff applications.
- Farmer profiles, crop assignments, geographic responsibility, and authorized shared coverage.
- Requests, field observations, attachments, cases, and case status transitions.
- Advisory versions, review comments, approval, publication, and targeting.
- Notifications, message recipients, and communication delivery status.
- Markets, market prices, crop calendars, and verified agricultural reports.

Database changes must use coordinated Drizzle schemas and migrations. Do not independently create duplicate tables or conflicting field names.

Existing endpoints should be extended where suitable. New endpoints should follow the repository's existing authentication, validation, error-handling, and response conventions.

## 10. Implementation and Integration Order

### Phase 1: Repository verification and coordination

- Inspect the current branch and working tree.
- Verify which previous defects are already fixed.
- Agree on shared database changes and API contracts.
- Establish separate development branches and testing expectations.

### Phase 2: Core data and security

- Complete secure farmer registration and assignment.
- Implement staff application verification.
- Enforce record-level authorization.
- Establish request, case, and advisory workflow contracts.

### Phase 3: Core workflow integration

- Connect requests, field observations, advisory drafts, expert review, revisions, and publication.
- Implement staff communication and case tracking.
- Connect notifications and recipient targeting to real backend records.

### Phase 4: Agricultural information and accessibility

- Add market information, crop calendars, seasonal reminders, and verified reports.
- Improve dashboards, multilingual support, offline access, and communication simulations.
- Integrate voice-first and quick-action interfaces within realistic technical limits.

### Phase 5: End-to-end validation

- Test registration, approval, authentication, and role permissions.
- Test the complete advisory lifecycle, including revision and publication.
- Test delivery targeting, notifications, case closure, and reopening.
- Test offline behavior, localization, and simulated communication flows.
- Verify that existing functionality still works after integration.

## 11. Definition of Done

A feature is not complete simply because its screen exists.

A feature is considered complete when:

- The UI is connected to the appropriate backend operation.
- The backend validates input and checks permissions.
- Database changes are migrated correctly.
- Loading, empty, success, and error states are handled.
- Relevant tests pass.
- Existing functionality has not regressed.
- The behavior is documented, including any simulation or external dependency.
- The team can demonstrate the feature using a realistic Ethiopian agricultural scenario.

## 12. Project Commitment

Agri-Insight Beacon will be developed as a practical agricultural support system, not merely as a collection of screens.

Our priority is to connect the work of farmers, extension workers, experts, and administrators into a coherent, secure, and useful service. We will improve the existing system incrementally, validate its behavior, and prioritize features that address genuine agricultural information and communication needs in Ethiopia.

**The final goal is a working end-to-end system that can be demonstrated, tested, explained, and evaluated honestly.**
