# AGRI-INSIGHT BEACON

## Consolidated Project Documentation

### Phase 1: Core Platform and Phase 2: Extended Features

**Institution:** INSA
**Project Type:** Graduation Project
**Country:** Ethiopia
**Technology Stack:** Flutter, Dart, Node.js, Express, TypeScript, PostgreSQL, Drizzle ORM, Docker

---

# 1. Introduction

Agri-Insight Beacon is an agricultural information and advisory platform designed to help Ethiopian farmers access relevant agricultural information and connect with extension workers and agricultural experts.

The system provides a centralized platform for managing farmer profiles, crop information, agricultural advisories, field observations, follow-up activities, support cases, staff verification, notifications, and communication simulations.

The platform follows a role-based approach. Farmers access agricultural information and request assistance, extension workers manage farmer records and field activities, experts review agricultural recommendations and provide specialized guidance, and administrators manage users, permissions, staff verification, and system activities.

The project is developed using Flutter for the mobile application, Node.js and Express with TypeScript for the backend, PostgreSQL for data storage, Drizzle ORM for database access, and Docker for development and service orchestration.

This document consolidates the original platform and the additional features planned for Phase 2. It complements the original project documentation rather than replacing it.

**Implementation note:** The directory structure and feature descriptions in this document are based on the project information provided by the team. Final implementation status must be checked against the latest source code and test results before submission.

# 2. Problem Statement

Many farmers face difficulties accessing timely, reliable, and locally relevant agricultural information. These challenges can be greater for farmers who have limited internet access, use basic mobile phones, speak different local languages, or have difficulty reaching an agricultural extension worker.

Agricultural questions, field observations, recommendations, and follow-up actions may also be difficult to track when information is recorded in separate places.

Agri-Insight Beacon addresses these challenges by organizing farmer information, providing agricultural advisories, supporting communication between farmers and agricultural professionals, and maintaining records of requests, recommendations, decisions, and follow-up activities.

The system is designed to strengthen existing agricultural extension services rather than replace extension workers or expert judgment.

# 3. Project Objectives

The main objectives are to:

1. Provide farmers with relevant agricultural information based on their crops, location, and preferred language.
2. Allow farmers to submit questions and request agricultural assistance.
3. Enable extension workers to register farmers, manage assignments, record observations, and track follow-up activities.
4. Allow agricultural experts to review advisories, request revisions, approve content, and respond to escalated cases.
5. Provide administrators with user management, staff verification, permission management, and audit records.
6. Maintain a history of agricultural recommendations, review decisions, field observations, and support cases.
7. Improve access through multilingual interfaces and low-connectivity communication simulations.
8. Apply authentication, authorization, input validation, and data-protection measures throughout the system.
9. Preserve the existing architecture and functionality while integrating new features incrementally.

# 4. Scope of the Project

## 4.1 Core scope

The project includes:

* Flutter mobile application.
* Node.js, Express, and TypeScript REST API.
* PostgreSQL database with Drizzle ORM.
* User authentication and role-based authorization.
* Farmer profile and crop management.
* Agricultural content creation, review, and publication.
* Farmer targeting based on supported eligibility criteria.
* Field observations and follow-up records.
* Farmer support cases and expert responses.
* Administrative workflows and staff verification.
* Notifications and messaging records.
* SMS, IVR, and USSD simulations where implemented.
* Automated tests, database migrations, seed data, and Docker-based development support.

## 4.2 Out of scope unless separately implemented and approved

The following must not be claimed as completed unless verified in the repository:

* A separate web application.
* Live SMS, IVR, or USSD telecommunications integration.
* Automated AI-based disease diagnosis.
* IoT devices and sensor integration.
* Satellite-based agricultural analytics.
* Payment processing.
* Live weather or market-price integrations without verified data sources.

The original project is mobile-focused. Any web dashboard should be treated as future scope unless the team has explicitly implemented and accepted it.

# 5. System Users and Roles

## 5.1 Farmer

Farmers can:

* Access their accounts when app access is available.
* View relevant agricultural information and published advisories.
* Manage permitted profile details.
* View registered crops and agricultural information.
* Submit questions or assistance requests.
* Receive responses and notifications.
* Follow support-case status where the feature is implemented.

Farmers who do not use the application can still be registered and supported by extension workers through the workflows provided by the system.

## 5.2 Extension Worker

Extension workers can:

* Register farmers, including farmers without application access.
* Record farmers' location, language, contact information, and crops.
* Manage assigned farmers and authorized shared coverage.
* Record field observations and relevant supporting information.
* Record follow-up activities and outcomes.
* Respond to routine questions within their authority.
* Prepare agricultural content drafts.
* Escalate complex agricultural problems to experts.
* Track assigned cases and support activities.

Access to farmer records must follow assignment and authorization rules. Extension workers must not automatically have unrestricted access to every farmer in the system.

## 5.3 Agricultural Expert

Experts can:

* Review submitted agricultural advisories.
* Approve or reject content.
* Request revisions or additional information.
* Provide review comments and reasons for decisions.
* Create specialized agricultural content.
* Respond to escalated farmer cases.
* Provide structured recommendations.
* Review relevant agricultural reports and records.

Only authorized and appropriately reviewed content may be published according to the system's workflow.

## 5.4 System Administrator

Administrators can:

* Review staff applications and supporting documents.
* Approve or reject staff accounts.
* Manage user roles and account status.
* Manage authorized assignments and configuration.
* Review audit records.
* Support system troubleshooting.
* Monitor administrative activities.

Sensitive documents and personal information must only be accessible to authorized users.

# 6. Phase 1: Core Platform

Phase 1 establishes the foundation of Agri-Insight Beacon.

## 6.1 Authentication and account management

The backend manages authentication, account information, session handling, and role-based permissions.

Passwords must be stored using secure password hashing, such as the configured Argon2id implementation. JWT-based authentication must validate tokens and enforce appropriate expiration and authorization rules.

The backend must enforce permissions independently of the mobile interface.

## 6.2 Farmer management

The farmer-management module stores farmer profiles, including supported contact details, preferred language, geographical information, and other relevant agricultural information.

Farmer records can be associated with application accounts when the farmer uses the mobile application. Where supported, farmers without application access can be represented through a farmer record that is not directly linked to a login account.

## 6.3 Crop management

The crop-management module maintains crop information and associations between farmers and their cultivated crops.

These associations support the identification of relevant agricultural content and help extension workers maintain organized farmer records.

## 6.4 Agricultural content management

Authorized users can create and manage agricultural information.

Content may include:

* Advisory title and body.
* Crop or topic.
* Language.
* Relevant location criteria.
* Author and timestamps.
* Review status.
* Publication information.

Content must follow the configured review and publication process.

## 6.5 Content review and publication

The content workflow allows authorized experts to review submitted content.

Possible actions include:

* Approve the content.
* Reject the content with a reason.
* Request revisions.
* Request additional information.

A revision request should return the content to an actionable state while preserving the existing draft and review history. Unapproved content must not be distributed as approved advice.

## 6.6 Targeting agricultural information

The targeting service identifies eligible farmers based on the criteria supported by the system, such as crop, geographical location, preferred language, and alert eligibility.

The system should avoid duplicate recipients and exclude farmers who do not meet the applicable targeting rules.

## 6.7 SMS and IVR simulations

The SMS simulator demonstrates the process of preparing messages, identifying recipients, and recording simulated delivery statuses.

The IVR simulator demonstrates a voice-menu interaction, including language selection and navigation through available options.

USSD simulation can be included where the corresponding service and interface are implemented.

These simulations are for demonstration and testing. They must not be described as real SMS delivery or live telephone calls unless actual telecommunications integration has been implemented and verified.

# 7. Phase 2: Extended Features

Phase 2 extends the core platform by connecting field activities, farmer requests, expert support, administration, and communication into more complete workflows.

## 7.1 Farmer and extension-worker assignments

The system supports assigning farmers to extension workers.

An assignment can identify the primary worker responsible for a farmer and, where supported, temporary or shared coverage.

Assignment changes must be validated and stored consistently. Concurrent assignment operations should use suitable database transactions and locking where necessary.

## 7.2 Registration of farmers without application access

Extension workers should be able to register farmers who do not use the mobile application.

The system should distinguish between farmers with application access and farmers who are managed through extension-worker-assisted workflows.

For farmers who receive application access, account provisioning must follow a secure process. Phone numbers must not be used as permanent passwords. Any temporary credential must be handled safely and replaced through an appropriate credential setup process.

## 7.3 Ethiopian geographical hierarchy

The farmer-registration workflow should support the geographical hierarchy:

**Region → Zone → Woreda → Kebele**

The interface should help users select the appropriate location, and the backend should validate the submitted geographical data.

Location information can support farmer assignment, advisory targeting, and location-specific agricultural information.

## 7.4 Field observations

Extension workers can record observations about agricultural problems encountered during field activities or farmer interactions.

Depending on the implemented schema and interface, an observation may include:

* Farmer and responsible extension worker.
* Observation date.
* Crop or agricultural topic.
* Description of the observed problem.
* Severity or priority.
* Location or GPS coordinates.
* Supporting photographs or attachments.
* Recommended next action.

Observations should be stored as structured records so that authorized staff can review them and track related actions.

## 7.5 Follow-up records

Follow-up records document the actions taken after an observation, farmer question, or agricultural recommendation.

They may include the responsible staff member, action description, scheduled date, status, and outcome.

Follow-up history helps the team determine whether a farmer's problem has received attention and whether further assistance is needed.

## 7.6 Farmer questions and support cases

The system supports a structured process for handling farmer questions and agricultural problems.

A case may originate from a farmer request, an extension-worker observation, or another authorized workflow.

A case should contain the relevant farmer, crop or topic, location where known, description, assigned staff, current status, and history of actions.

The proposed case statuses are:

* `OPEN`
* `ASSIGNED`
* `IN_PROGRESS`
* `RESOLVED`
* `CLOSED`

The backend should validate status transitions instead of accepting arbitrary status changes.

## 7.7 Case escalation and expert response

When an extension worker encounters a problem requiring specialized guidance, the observation or request can be escalated to an expert.

The escalation workflow should:

1. Create or link the relevant support case.
2. Preserve the original observation or request.
3. Notify the appropriate expert or expert queue.
4. Allow the expert to review the available information.
5. Record a structured response or request for more information.
6. Update the case status and history.
7. Make the response available to authorized participants.
8. Record follow-up actions where needed.

The system should preserve the relationship between the original observation, case, expert response, and follow-up records.

## 7.8 Staff application and verification

Staff verification allows administrators to review applications for roles that require institutional approval.

The workflow should include:

* Submission of the required application information.
* Upload of supporting documents where required.
* A pending status while verification is in progress.
* Administrative approval or rejection.
* A decision reason and timestamp.
* Appropriate role activation following approval.

Pending or rejected applicants must not receive permissions reserved for verified staff.

## 7.9 Advisory revisions and version history

The system should preserve review decisions and previous versions of agricultural content.

When an expert requests a revision, the author should be able to understand what needs to change and update the draft.

The workflow must preserve relevant review comments and ensure that revised content can be resubmitted for another review.

## 7.10 Notifications

Notifications inform users about relevant system events.

Examples include:

* A farmer has been assigned to an extension worker.
* A field observation has been escalated.
* A case has been assigned to an expert.
* An expert has responded to a case.
* An advisory has been approved or returned for revision.
* New approved agricultural information is available.

Notifications should be generated by actual backend events and must only expose information to authorized recipients.

## 7.11 Staff communication

Where implemented, staff communication should support coordination between extension workers, experts, and administrators.

Communication should be associated with the relevant case, advisory, or workflow whenever possible. This makes discussions easier to find and preserves the context of decisions.

## 7.12 Multilingual and accessible mobile experience

The supplied project structure identifies English, Amharic, and Afaan Oromoo as supported application languages.

The mobile application should provide:

* A clear language-selection flow.
* Consistent translations for essential screens.
* Readable text and accessible contrast.
* Simple navigation and recognizable actions.
* Clear loading, empty, success, and error states.
* Forms that explain validation problems.
* Useful feedback when network requests fail.

Additional languages should only be presented as supported after translations and the relevant screens have been verified.

## 7.13 Offline access

Where offline functionality is implemented, the application should allow access to previously saved or cached advisories without an active connection.

Offline content must be distinguishable from current online content. The interface should indicate when the content was last updated.

Synchronization should handle network failures and avoid silently losing user-created information.

## 7.14 Market information and agricultural calendars

Market information may include commodity, price, unit, market location, source, observation date, and freshness status.

Crop calendars and reminders may provide information about planting, fertilizer application, harvesting, and other crop-related activities.

These features require suitable data sources and validation. They must be identified as planned unless the database, user interface, and complete data workflow are implemented.

## 7.15 Weather and emergency information

Weather-related information and emergency agricultural alerts can help farmers understand relevant risks.

Such information must have an identifiable source, timestamp, and responsible validation process. Unverified reports should not be presented as official or confirmed emergency advice.

# 8. Main End-to-End Workflows

## 8.1 Farmer assistance workflow

1. A farmer submits a question, or an extension worker records a request on behalf of a farmer.
2. The system stores the request and relevant farmer, crop, language, and location details.
3. The request is assigned to an authorized extension worker or support queue.
4. The extension worker reviews the request and records observations where necessary.
5. The worker provides an appropriate response or escalates the problem to an expert.
6. An escalated case appears in the appropriate expert queue.
7. The expert records guidance, requests more information, or recommends a further action.
8. The system updates the case history and notifies authorized participants.
9. Follow-up activities are recorded where necessary.
10. The case is resolved or closed when the agreed completion conditions are satisfied.

Routine questions do not always need to become formal cases. The workflow should allow authorized staff to respond directly when appropriate.

## 8.2 Advisory review and publication workflow

1. An authorized user creates an agricultural advisory draft.
2. The draft is submitted for review.
3. An authorized expert reviews the content.
4. The expert approves it, rejects it with a reason, or requests revision.
5. If revision is requested, the author updates the draft while preserving the review history.
6. The revised content is resubmitted and reviewed.
7. Once the required conditions are satisfied, an authorized user publishes the advisory.
8. The targeting service identifies eligible farmers.
9. The system records message and recipient information.
10. Delivery results are displayed according to the actual communication channel used, with simulated results clearly labelled.

## 8.3 Staff verification workflow

1. A staff applicant submits the required information and documents.
2. The application remains pending until reviewed.
3. An authorized administrator examines the application.
4. The administrator approves or rejects it and records the decision reason and timestamp.
5. The account receives the appropriate status and permissions only after the required approval.
6. The administrative decision is recorded in the audit trail.

# 9. High-Level System Architecture

Agri-Insight Beacon uses a modular backend architecture. The Flutter application communicates with the Express REST API, which validates requests, checks authentication and permissions, applies business rules, and accesses PostgreSQL through Drizzle ORM.

The main layers are:

**Mobile presentation layer:** Provides role-based screens, forms, localization, navigation, and user feedback.

**API layer:** Handles HTTP requests, request validation, authentication, authorization, and error responses.

**Business logic layer:** Implements farmer management, advisory workflows, targeting, cases, observations, assignments, notifications, and communication simulations.

**Database layer:** Stores user accounts, farmer profiles, crops, content, reviews, cases, observations, follow-ups, messages, notifications, and audit records.

**Development environment:** Uses Docker and Docker Compose where configured to provide a repeatable local development setup.

# 10. High-Level Project Directory Structure

The following structure is based on the directory information supplied by the project team. Exact filenames should be confirmed against the current repository.

```text
INSA-PROJECT/
├── backend/
│   ├── src/
│   │   ├── config/
│   │   ├── db/
│   │   ├── middleware/
│   │   ├── modules/
│   │   ├── services/
│   │   ├── app.ts
│   │   └── server.ts
│   └── tests/
├── database/
│   ├── migrations/
│   ├── schema/
│   └── seed.ts
├── mobile/
│   ├── lib/
│   │   ├── core/
│   │   ├── features/
│   │   ├── models/
│   │   ├── services/
│   │   └── main.dart
│   └── test/
├── docs/
├── docker-compose.yml
├── Dockerfile
└── drizzle.config.ts
```

## 10.1 Backend directory

The backend contains the Express application, configuration, middleware, domain modules, services, and automated tests.

* `config/`: environment and permission configuration.
* `db/`: database connection and runtime database access.
* `middleware/`: authentication, authorization, logging, and error handling.
* `modules/`: domain routes, controllers, and services.
* `services/`: reusable business logic, targeting, and communication simulators.
* `app.ts`: application configuration and route mounting.
* `server.ts`: server startup and lifecycle.
* `tests/`: backend unit, integration, and end-to-end tests.

## 10.2 Database directory

The database directory contains Drizzle schema definitions, migration files, and seed data.

* `schema/`: table and relationship definitions.
* `migrations/`: ordered database changes.
* `seed.ts`: demo data for development and testing.

## 10.3 Mobile directory

The mobile directory contains the Flutter application.

* `core/`: routing, localization, themes, and shared widgets.
* `features/`: role-specific screens and workflows.
* `models/`: Dart data models.
* `services/`: API clients and state-related services.
* `main.dart`: Flutter entry point.
* `test/`: widget and unit tests.

# 11. Backend Technical Design

## 11.1 Core server files

**`app.ts`** configures the Express application, middleware, CORS settings, and route mounting.

**`server.ts`** initializes the server and required runtime connections.

**`env.ts`** manages and validates environment configuration, including database settings and secrets where present.

**`permissions.ts`** defines role-based permission constants for `ADMIN`, `EXPERT`, `EXTENSION_WORKER`, and `FARMER`.

## 11.2 Middleware

* `auth.middleware.ts`: validates authentication tokens and establishes the trusted request identity.
* `role.middleware.ts`: checks permissions required for protected operations.
* `error.middleware.ts`: handles errors consistently without exposing sensitive internal information.
* `logger.middleware.ts`: records useful system events while avoiding secrets and unnecessary personal information.

Role checks and resource-level authorization are both required. For example, an extension worker must not access a farmer's records merely because the worker has an extension-worker role.

## 11.3 Domain modules

The supplied backend structure identifies the following modules:

* **Authentication:** account access, credentials, token handling, and session-related operations.
* **Farmers:** farmer profiles, farmer registration, and authorized farmer access.
* **Crops:** crop catalog and farmer-crop relationships.
* **Content:** agricultural content creation, review, revision, approval, and publication.
* **Cases:** farmer support requests, assignments, status transitions, and responses.
* **Observations:** field observation records and escalation.
* **Follow-ups:** follow-up actions, dates, and outcomes.
* **Messaging:** message records, recipients, and channel-related operations.
* **Notifications:** event-based notifications and recipient state.
* **Admin:** user administration, staff verification, and audit-related functions.

## 11.4 Targeting and simulator services

The targeting engine should separate crop, location, and language filtering into testable logic.

The SMS, IVR, and USSD services should manage their respective simulation flows and record the results consistently. A future live telecom integration should use a clearly separated provider interface rather than treating a simulation as real delivery.

# 12. Database Design

The project uses PostgreSQL and Drizzle ORM. The following entities are identified in the supplied technical structure.

| Entity or schema             | Purpose                                                                      |
| ---------------------------- | ---------------------------------------------------------------------------- |
| `users.ts`                   | Accounts, roles, credentials, approval state, and timestamps                 |
| `farmers.ts`                 | Farmer profiles, language, geography, and application-account linkage        |
| `crops.ts`                   | Agricultural crop catalog                                                    |
| `farmerCrops.ts`             | Relationships between farmers and crops                                      |
| `farmerWorkerAssignments.ts` | Farmer-to-extension-worker assignments and authorized coverage               |
| `content.ts`                 | Advisory content, status, authorship, and publication information            |
| `contentReviews.ts`          | Review decisions, comments, reviewers, and timestamps                        |
| `cases.ts`                   | Support cases, assignments, status, and resolution information               |
| `fieldObservations.ts`       | Field observations, crop tags, location, severity, and attachment references |
| `followUpRecords.ts`         | Follow-up actions and outcomes                                               |
| `messages.ts`                | Message and communication history                                            |
| `messageRecipients.ts`       | Recipient-specific message status                                            |
| `notifications.ts`           | In-app notifications and read state                                          |
| `auditLogs.ts`               | Records of significant system and administrative actions                     |

The exact columns, constraints, and relationships must be verified in the actual schema files and migrations.

## 12.1 Database integrity requirements

The database design should:

* Use primary and foreign keys for relationships.
* Apply unique constraints where identifiers must be unique.
* Validate required fields and permitted status values.
* Use transactions for operations involving several related records.
* Preserve migration history and coordinate shared schema changes.
* Avoid storing plain-text passwords or unnecessary sensitive information.
* Use clearly identified demo data for development and testing.

For example, escalating an observation may involve creating a case and a notification. These related changes should be handled safely so the system does not leave inconsistent records if one step fails.

# 13. Flutter Mobile Application

## 13.1 Core files

The supplied mobile structure includes:

* `main.dart`: application entry point and initialization.
* `app_router.dart`: route definitions and role-aware navigation.
* `app_theme.dart`: shared visual styling.
* `app_locale.dart`: localization management.
* `ethiopian_location_selector.dart`: reusable geographical selection interface.

## 13.2 Networking services

* `api_client.dart`: shared HTTP configuration, authentication headers, and error handling.
* `auth_service.dart`: login, logout, session restoration, and current-user information.
* `farmer_service.dart`: farmer profiles, crop assignments, and locations.
* `content_service.dart`: advisory retrieval, creation, and review operations.
* `observation_service.dart`: observations, attachments where supported, follow-ups, and escalation.
* `admin_service.dart`: administrative operations and staff verification.
* `messaging_service.dart`: message and simulator operations.
* `notification_service.dart`: retrieving and updating notification state.

## 13.3 Role-based screens

The directory structure identifies the following screen groups.

**Authentication and onboarding**

* `login_screen.dart`
* `register_screen.dart`
* `choose_language_screen.dart`
* `pending_approval_screen.dart`

**Farmer experience**

* `farmer_main_layout.dart`
* `farmer_home_screen.dart`
* `farmer_profile_screen.dart`
* `farm_map_widget.dart`

**Extension-worker experience**

* `extension_main_layout.dart`
* `register_farmer_flow.dart`
* `farmer_management_screen.dart`
* `field_observation_screen.dart`
* `crop_recording_screen.dart`

**Expert experience**

* `expert_main_layout.dart`
* `content_review_list_screen.dart`
* `content_review_details_screen.dart`
* `advisory_approval_screen.dart`
* `field_case_response_screen.dart`

**Administrator experience**

* `admin_main_layout.dart`
* `admin_user_management_screen.dart`
* `admin_user_approvals_screen.dart`
* `admin_audit_logs_screen.dart`

**Communication simulations**

* `sms_simulator_screen.dart`
* `ivr_simulator_screen.dart`

A USSD screen should be listed as implemented only if it exists in the latest mobile repository.

# 14. API and Integration Requirements

Exact endpoint URLs must be documented from the current backend route definitions. At a functional level, the API should support the following areas where implemented:

| API area       | Operations to verify                                                                |
| -------------- | ----------------------------------------------------------------------------------- |
| Authentication | Login, account provisioning, current-user profile, and supported session operations |
| Farmers        | Create, retrieve, update, and search authorized farmer records                      |
| Crops          | Retrieve crops and manage farmer-crop associations                                  |
| Assignments    | Assign workers, update coverage, and retrieve authorized assignments                |
| Observations   | Create and retrieve observations and escalate relevant records                      |
| Follow-ups     | Create, update, and retrieve follow-up records                                      |
| Cases          | Create, assign, update status, respond, and retrieve case history                   |
| Content        | Create drafts, submit for review, request revisions, approve, and publish           |
| Messaging      | Create messages, identify recipients, and retrieve simulation results               |
| Notifications  | Retrieve notifications and update read state                                        |
| Administration | Verify staff applications, manage authorized accounts, and inspect audit records    |

The mobile application and backend must agree on field names, required values, nullability, timestamps, status enums, and error formats.

Protected API operations must use the authenticated user's identity and validate access to the specific resource. The backend must not trust an arbitrary user ID supplied by the mobile application as proof of authorization.

# 15. Security and Privacy

Security must be considered across the backend, database, and mobile application.

## 15.1 Authentication

* Hash passwords using the configured secure password-hashing implementation.
* Never log or store raw passwords.
* Validate JWT signatures and expiration.
* Keep signing secrets outside source control.
* Handle expired or invalid sessions safely.

## 15.2 Authorization

* Enforce permissions on the backend.
* Validate resource ownership and assignment-based access.
* Restrict staff documents and sensitive farmer information.
* Prevent unauthorized case access and cross-user data leakage.

## 15.3 Input validation and error handling

* Validate external input on the server.
* Reject invalid status transitions and malformed requests.
* Use safe database access patterns.
* Return consistent error responses.
* Avoid exposing stack traces, secrets, or database internals.

## 15.4 Audit records

Significant actions should be recorded, including role changes, staff verification decisions, content publication, assignment changes, and important case updates.

Audit logs should contain enough information to investigate actions without unnecessarily copying private information into log records.

# 16. Testing and Acceptance Criteria

## 16.1 Backend tests

The backend test suite should verify that:

1. Unauthenticated requests cannot access protected endpoints.
2. Users with insufficient permissions cannot perform restricted actions.
3. Extension workers cannot access unauthorized farmer records.
4. Unverified staff cannot use permissions that require approval.
5. Unapproved content cannot be published.
6. Revision requests preserve drafts and review history.
7. Targeting excludes ineligible recipients and avoids duplicate recipients.
8. Assignment changes remain consistent during concurrent operations.
9. Observation escalation creates or links the appropriate case and notification.
10. Invalid case-status transitions are rejected.
11. Simulator results are clearly represented as simulated.
12. Important administrative actions create the required audit records.

## 16.2 Flutter tests

The mobile test suite should verify:

* Login and session restoration.
* Role-aware navigation.
* Farmer registration and profile validation.
* Content review and revision screens.
* Observation and case workflows.
* Form validation and error handling.
* Language selection and translation coverage.
* Offline advisory access where implemented.
* Loading, empty, success, and failure states.

## 16.3 End-to-end testing

The team should test the entire system using the following sequence:

1. Start PostgreSQL and the backend using the documented setup.
2. Apply migrations and load demo data.
3. Sign in using test accounts for each role.
4. Register a farmer and associate crops and an extension worker.
5. Record a field observation.
6. Escalate the observation to a case.
7. Confirm that an authorized expert can view and respond to the case.
8. Create an agricultural advisory draft.
9. Request a revision and verify that the review history remains available.
10. Approve and publish the advisory.
11. Run the targeting process and communication simulator.
12. Verify recipient statuses and notification behavior.
13. Test unauthorized access attempts.
14. Review audit records and automated test results.

Any failed test or incomplete workflow should be recorded and fixed or documented before the final demonstration.

# 17. Team Responsibilities

The current team structure provided for this phase contains five members.

## Member 1: Eldana Babu

**Student ID:** CTC-3321-26
**Classroom:** 3003

**Main responsibility:** Authentication, user accounts, authorization, credential provisioning, and shared media-access contracts.

Key tasks:

* Maintain authentication and token-handling logic.
* Ensure passwords are securely hashed.
* Implement and verify role and resource authorization.
* Coordinate shared authentication and attachment contracts.
* Check that protected routes return appropriate unauthorized or forbidden responses.
* Support secure access to uploaded media.

**Acceptance criteria:** Credentials are securely managed, tokens are validated, permissions are enforced, and unauthorized users cannot access protected resources.

## Member 2: Etsegenet Amsalu

**Student ID:** CTC-1495-26
**Classroom:** 3003

**Main responsibility:** Farmer management, crops, worker assignments, field observations, and follow-up records.

Key tasks:

* Maintain farmer profiles and crop associations.
* Support registration of farmers with and without application access.
* Implement the Ethiopian geographical hierarchy.
* Manage farmer-to-worker assignments and authorized coverage.
* Record field observations and relevant attachments.
* Maintain follow-up history.
* Connect escalated observations to support cases.

**Acceptance criteria:** Both farmer-registration paths work where implemented, assignments remain consistent, observations and follow-ups are stored correctly, and escalation preserves the relationship between records.

## Member 3: Ezra Ambaw

**Student ID:** CTC-2682-26
**Classroom:** 3003

**Main responsibility:** Staff verification, administrative workflows, advisory review, revision history, and publication security.

Key tasks:

* Maintain staff application and verification workflows.
* Restrict permissions for pending staff.
* Record administrative decisions and reasons.
* Implement or maintain advisory review and revision behavior.
* Preserve review comments and content history.
* Ensure publication rules are enforced.
* Maintain relevant audit records.

**Acceptance criteria:** Staff verification is enforced, administrative decisions are traceable, revisions preserve history, and unapproved content cannot be published.

## Member 4: Hawi Jarso

**Student ID:** CTC-3472-26
**Classroom:** 3003

**Main responsibility:** Farmer cases, escalation, expert responses, case history, and notifications.

Key tasks:

* Implement or maintain case creation and assignment.
* Enforce valid case-status transitions.
* Provide expert case-response workflows.
* Preserve case events and communication history.
* Connect observation escalation to the expert queue.
* Generate notifications for relevant assignments, escalations, and responses.
* Verify that users cannot access unauthorized cases.

**Acceptance criteria:** Cases move through valid states, experts receive the appropriate cases, responses are recorded, notifications work, and access controls prevent data leakage.

## Member 5: Fuad Yibrie

**Student ID:** CTC-0345-26
**Classroom:** 3003

**Main responsibility:** Farmer mobile experience, localization, offline support, communication simulators, and integration testing.

Key tasks:

* Maintain the farmer dashboard and mobile navigation.
* Improve readability and accessibility.
* Verify English, Amharic, and Afaan Oromoo support.
* Implement or maintain cached advisory access where agreed.
* Support farmer questions and extension-worker contact workflows.
* Maintain SMS and IVR simulations and USSD simulation where implemented.
* Support end-to-end testing and document known integration issues.

**Acceptance criteria:** Supported language selection works, farmer workflows are usable, offline information is clearly labelled where available, and simulators never claim that real telecommunications occurred.

## Shared responsibilities

All members must:

* Inspect the latest repository before changing code.
* Preserve working functionality and the existing architecture.
* Coordinate schemas, migrations, endpoints, enums, and permissions.
* Use feature branches and pull requests according to the team workflow.
* Add or update tests for changes.
* Avoid committing credentials, secrets, or real personal data.
* Report modified files, migrations, endpoints, tests, and outstanding issues.
* Verify whether a feature already exists before implementing a duplicate.
* Keep the documentation consistent with the actual code.

# 18. Development and Integration Plan

The recommended integration process is divided into five stages.

## Stage 1: Repository verification

Inspect the current source code, screens, backend routes, database schemas, migrations, tests, and known defects.

Classify features as working, partially working, broken, missing, or planned.

## Stage 2: Shared contracts and security

Agree on shared data models, endpoint structures, status values, permissions, attachment behavior, and error responses.

Complete and test critical authentication and resource-access rules before connecting additional workflows.

## Stage 3: Core workflow integration

Connect farmer registration, worker assignments, field observations, follow-ups, support cases, expert responses, advisory review, and notifications.

## Stage 4: Accessibility and communication

Verify supported languages, offline behavior, and the SMS, IVR, and USSD simulation flows included in the current implementation.

## Stage 5: End-to-end validation

Run migrations, prepare demo data, execute automated tests, verify role permissions, and rehearse the complete demonstration.

Each feature is complete only when its interface, backend logic, database behavior, permissions, error handling, and tests are appropriately connected.

# 19. Local Setup and Deployment

The exact commands must be taken from the project's current configuration files. The general setup sequence is:

1. Install the required Node.js and Flutter SDK versions.
2. Configure local environment variables using the project's sanitized example file.
3. Start the PostgreSQL database and backend using the documented Docker configuration or approved local setup.
4. Apply database migrations using the repository's Drizzle migration scripts.
5. Load demo data only in the intended development or testing environment.
6. Start the backend and confirm that it initializes correctly.
7. Configure the Flutter application with the appropriate API base URL.
8. Run the Flutter application on the selected emulator or device.
9. Execute backend and Flutter tests.

The final repository documentation should provide the exact commands from `package.json`, `pubspec.yaml`, `drizzle.config.ts`, `Dockerfile`, and `docker-compose.yml`.

Secrets must not be included in the documentation or committed to the repository.

# 20. Final Demonstration Plan

The final presentation should demonstrate one connected workflow.

1. Introduce the agricultural problem and explain the system's roles.
2. Sign in as an extension worker.
3. Register or open a farmer profile and show the crop and location information.
4. Record a field observation and escalate it to a support case.
5. Sign in as an expert and show the case, response, and status update.
6. Create an agricultural advisory draft.
7. Demonstrate a revision request and preserved review comments.
8. Approve and publish the revised advisory.
9. Show the targeting process and run the SMS or IVR simulator.
10. Clearly identify simulated communication results.
11. Demonstrate staff verification or audit history if implemented.
12. Finish by showing test results, the database structure, and known limitations.

The demonstration should prioritize working end-to-end behavior over the number of screens shown.

# 21. Limitations and Future Improvements

Potential future improvements include:

* Live SMS, IVR, and USSD integrations with suitable providers.
* Additional verified language support.
* More robust offline synchronization.
* Verified market-price and weather integrations.
* Crop calendars and agricultural reminders.
* Carefully validated emergency alerts.
* Improved reporting and analytics.
* Additional agricultural data integrations.
* A web dashboard if it is formally added to the project scope.
* Production monitoring, backup, recovery, and operational security improvements.

These items must be labelled as future work unless they have been implemented and verified.

# 22. Final Readiness Checklist

Before submission, confirm the following:

* The original documentation remains unchanged.
* This consolidated document is saved as a separate file.
* The current five-member team list is correct.
* The directory structure matches the latest repository.
* All stated features have been checked against the source code.
* Migrations work from a clean database.
* Authentication and resource permissions have been tested.
* Farmer registration, assignments, observations, and follow-ups work as expected.
* Case escalation and expert responses work end to end.
* Advisory revisions preserve the relevant history.
* Publication and targeting enforce the required rules.
* Notifications are connected to real system events.
* Communication simulations are clearly labelled.
* Localization and offline claims have been verified.
* Automated tests have been run and failures documented.
* No secrets or unnecessary personal information are committed.
* The final demonstration has been rehearsed.
* Remaining limitations are honestly documented.

---

**End of Consolidated Project Documentation**
