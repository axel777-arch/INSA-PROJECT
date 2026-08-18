
# AGRI-INSIGHT BEACON
REVISED COMPLETE PROJECT DOCUMENTATION

CTC / INSA MVP Documentation
Team: ONE development team — 6 members
Work split: 2 Frontend/Mobile + 4 Backend
Current client scope: MOBILE APPLICATION ONLY

IMPORTANT:
This document replaces the previous team structure and scope. There are NOT six teams. There is one team of six developers. The current MVP is a mobile application; a web interface is not being developed now. Flutter/Dart may technically support web in the future, but web is outside the current deliverable.

The document is intentionally separated into two parts:
PART A — CONCEPT & SUBMISSION
PART B — TECHNICAL IMPLEMENTATION

Part A explains what the project is, MVP scope, actors, problem, features, deliverables and submission requirements.
Part B explains how the six developers build, structure, test, version-control and integrate the software.

# PART A — CONCEPT & SUBMISSION

### A1. Project Concept

Agri-Insight Beacon is a software platform designed to help deliver relevant, expert-reviewed agricultural information to farmers.

The MVP focuses on the software workflow rather than building a complete agricultural service operation.

Core idea:
1. A farmer has a profile containing information such as location, language and crops.
2. Agricultural information is created in the system.
3. The information goes through an approval/review workflow.
4. The system can identify farmers for whom the information is relevant.
5. The mobile application provides the farmer-facing experience.
6. The system demonstrates how notifications/alerts can be delivered through an SMS simulator and how an IVR-style interaction can be demonstrated without requiring a real telecom integration.

The development team builds the application and backend. Agricultural experts/domain specialists are responsible for validating agricultural content when available; the software must support that workflow but the developers do not invent agricultural advice.

### A2. Problem Statement

Farmers may not always receive agricultural information that is relevant to their crop, location or preferred language. A large amount of agricultural information can also be difficult to organize and deliver through one structured system.

Agri-Insight Beacon addresses the software-side problem by providing:
- structured farmer profiles
- agricultural information management
- expert review/approval workflow
- targeted information delivery
- mobile access
- communication simulation for SMS/IVR
- role-based access to the software

The MVP demonstrates the digital system, not the entire real-world agricultural extension infrastructure.

### A3. Target Users / Actors

The software supports these roles:

FARMER
- Uses the mobile application.
- Maintains profile information.
- Views relevant agricultural information.
- Receives/reads alerts.
- Uses the app according to the permissions assigned to the account.

EXTENSION WORKER
- Works with farmer/content information where included in the MVP.
- Can manage the operational workflow assigned to the role.

AGRICULTURAL EXPERT
- Reviews agricultural content.
- Approves or rejects content where the workflow requires expert validation.

ADMIN
- Manages users/roles and system-level configuration where required.

Important:
These are application roles, NOT separate development teams.

### A4. MVP Definition

MVP means the smallest complete version that demonstrates the project's main value and technical capability.

MUST BE IN THE MVP:
- Flutter mobile application
- User authentication
- Role-based access
- Farmer profile
- Crop information
- Location information
- Preferred language
- Agricultural content/advisory records
- Content review/approval workflow
- Relevant farmer targeting
- Mobile display of agricultural information
- SMS simulator
- IVR simulator
- Backend REST API
- PostgreSQL database
- Input validation
- Error handling
- Basic audit logging
- Automated tests for critical workflows

MVP DOES NOT INCLUDE:
- Separate web interface
- Production SMS/telecom integration
- Production IVR/telecom integration
- AI crop diagnosis
- Machine-learning prediction
- IoT/sensor integration
- Satellite analytics
- Payment system
- Complex recommendation AI
- Microservices
- Large-scale production infrastructure

The goal is a coherent working application, not a collection of unfinished advanced features.

### A5. Features to Demonstrate

1. Authentication
A user can log in and the system determines the user's role.

2. Farmer Profile
A farmer can have location, language and crop information.

3. Agricultural Information
Authorized users can create/manage agricultural content.

4. Expert Review
Content can move through a controlled review/approval workflow.

5. Targeting
Approved information can be associated with farmers according to fields such as crop, location and language.

6. Mobile Experience
The farmer interacts with the system through Flutter.

7. SMS Simulation
The team demonstrates how an approved message would be selected and sent without using a real telecom provider.

8. IVR Simulation
The team demonstrates a voice-menu interaction without requiring a real telecom provider.

9. Role-Based Access
The backend controls which actions each role can perform.

The demo should show one connected workflow rather than unrelated screens.

### A6. What Developers Build vs. What Domain Experts Provide

DEVELOPERS BUILD:
- Mobile UI
- Navigation
- Forms
- API integration
- Authentication
- Backend
- Database
- Content workflow
- Targeting logic
- SMS simulator
- IVR simulator
- Role/permission enforcement
- Validation
- Testing
- GitHub/CI
- Deployment-ready project structure

DOMAIN EXPERTS PROVIDE/VALIDATE:
- Agricultural terminology
- Agricultural content
- Whether advice is appropriate
- Review/approval decisions
- Domain-specific rules

The developer team should never create fake agricultural recommendations and present them as expert advice.

### A7. Submission Requirements

The project README must contain:
- Project title
- Short description
- Problem the project solves
- Main features planned
- Full name of each team member
- CTC number of each team member
- Classroom number of each team member

Repository requirements:
- Create a professional, meaningful GitHub repository.
- Invite `insa-ctc-devhub` as a collaborator as required by the supplied CTC instruction.

Before submission:
- README completed
- All six members listed
- CTC numbers added
- Classroom numbers added
- Repository accessible
- `insa-ctc-devhub` invited
- MVP features work
- No secrets committed
- Demo flow rehearsed

### A8. Team Structure — ONE Team of Six

There is one team with six members.

FRONTEND / MOBILE — 2 MEMBERS
- Member 1: Eldana Babu — Mobile UI & Navigation
- Member 2: Etsegenet Amsalu — Mobile State, Forms & API Integration

BACKEND — 4 MEMBERS
- Member 3: Ezra Ambaw — Backend Foundation, Authentication & Security
- Member 4: Hanifa Seid — Database, Farmers & Crops
- Member 5: Hawi Jarso — Agricultural Content, Review & Targeting
- Member 6: Fuad Yibrie — Messaging Simulation, API Integration, Testing & CI

This is a responsibility split, not six independent teams. All six members coordinate through one repository, one main branch and Pull Requests.

### A9. 2:4 Work Distribution

FRONTEND/MOBILE: 2 developers
- Flutter project
- screens
- navigation
- forms
- client-side state
- API client
- authentication screens
- farmer-facing workflows
- simulator screens
- UI testing

BACKEND: 4 developers
- Node/Express/TypeScript
- PostgreSQL
- Drizzle ORM
- authentication/authorization
- farmer/crop data
- agricultural content
- review workflow
- targeting
- SMS/IVR simulation services
- API tests
- CI
- backend integration

The backend has four developers because most of the project's business logic, persistence, security and integration complexity lives there.

### A10. Out-of-Scope Features Kept for Later

The following may be documented as future expansion but should not consume MVP development time:
- Real telecom SMS gateway
- Real IVR/voice gateway
- AI agricultural assistant
- Crop disease image recognition
- IoT sensor integration
- Weather-provider integration
- Market-price integrations
- Satellite data
- Advanced analytics
- Web dashboard
- Multi-service/microservice architecture

If a future feature does not help complete the MVP demo, it stays outside the current sprint.

# PART B — TECHNICAL IMPLEMENTATION

### B1. Technology Stack

BACKEND
- Node.js
- TypeScript
- Express
- Drizzle ORM
- PostgreSQL
- Zod
- JWT/session mechanism
- Argon2id for password hashing

MOBILE
- Flutter
- Dart
- Flutter Material/Cupertino as appropriate
- HTTP/Dio-style API client

TESTING
- Vitest or Jest
- Supertest for API testing
- Flutter test for mobile

DEVOPS
- Git
- GitHub
- GitHub Actions
- Docker / Docker Compose for local PostgreSQL

ARCHITECTURE
Use a modular monolith for the MVP. It keeps the backend organized while avoiding the operational complexity of microservices.

### B2. Why Flutter Instead of a Separate Web Frontend

The current product target is mobile only.

Flutter is used because:
- the team can build the mobile application with Dart
- the codebase can potentially be extended to web later
- UI logic can be organized by feature
- one Flutter technology is sufficient for the current client target

Important:
Do NOT create a React web application for this MVP.
Do NOT spend time building a separate web dashboard.

If the project is later expanded to web, Flutter web can be evaluated then.

### B3. Repository Structure

```text
agri-insight-beacon/
│
├── backend/
│   ├── src/
│   │   ├── config/
│   │   ├── middleware/
│   │   ├── modules/
│   │   │   ├── auth/
│   │   │   ├── farmers/
│   │   │   ├── crops/
│   │   │   ├── content/
│   │   │   └── messaging/
│   │   ├── services/
│   │   │   ├── targeting/
│   │   │   ├── sms/
│   │   │   └── ivr/
│   │   ├── utils/
│   │   ├── app.ts
│   │   └── server.ts
│   ├── tests/
│   ├── package.json
│   └── tsconfig.json
│
├── mobile/
│   ├── lib/
│   │   ├── core/
│   │   ├── models/
│   │   ├── services/
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   ├── farmer/
│   │   │   ├── content/
│   │   │   ├── alerts/
│   │   │   └── simulator/
│   │   └── main.dart
│   ├── test/
│   └── pubspec.yaml
│
├── database/
│   ├── schema/
│   │   ├── index.ts
│   │   ├── users.ts
│   │   ├── farmers.ts
│   │   ├── crops.ts
│   │   ├── farmerCrops.ts
│   │   ├── content.ts
│   │   ├── contentReviews.ts
│   │   ├── messages.ts
│   │   ├── messageRecipients.ts
│   │   └── auditLogs.ts
│   ├── migrations/
│   └── seed/
│
├── docs/
│   ├── concept.md
│   ├── architecture.md
│   ├── database.md
│   ├── api.md
│   ├── github-workflow.md
│   ├── team-responsibilities.md
│   └── demo-script.md
│
├── .github/
│   └── workflows/
├── docker-compose.yml
├── .env.example
├── .gitignore
└── README.md

```

### B4. Folder Responsibilities

backend/src/config/

* environment configuration
* database configuration
* application settings

backend/src/middleware/

* authentication
* role authorization
* request validation
* centralized error handling

backend/src/modules/

* feature-specific business logic
* routes/controllers/services/schemas/types
* barrel files (index.ts) for clean importing

backend/src/services/

* reusable cross-module services
* targeting and communication adapters

database/schema/

* Drizzle schema definitions (camelCase naming convention)

database/migrations/

* migration history

database/seed/

* fake/demo data only

mobile/lib/features/

* feature-specific Flutter screens, state and UI logic

mobile/lib/services/

* API/network services

mobile/lib/core/

* shared constants, configuration, reusable infrastructure

docs/

* technical and project documentation

.github/workflows/

* automated CI checks

### B5. Backend Member 3 — Foundation, Authentication & Security

Primary Owner: Ezra Ambaw
Files:

* backend/src/config/
* backend/src/middleware/
* backend/src/modules/auth/
* database/schema/auditLogs.ts

Tasks:

1. Bootstrap Express + TypeScript.
2. Configure environment variables.
3. Configure database connection dependency.
4. Create users schema with agreed roles.
5. Implement registration.
6. Hash passwords using Argon2id.
7. Implement login.
8. Implement token/session validation.
9. Implement authentication middleware.
10. Implement role authorization middleware.
11. Add /auth/me.
12. Add validation.
13. Add safe error handling.
14. Add authentication tests.
15. Document authentication contract.

Roles:

* FARMER
* EXTENSION_WORKER
* EXPERT
* ADMIN

Security rule:
The backend, not Flutter, is responsible for enforcing permissions.

### B6. Backend Member 4 — Database, Farmers & Crops

Primary Owner: Hanifa Seid
Files:

* database/schema/users.ts
* database/schema/farmers.ts
* database/schema/crops.ts
* database/schema/farmerCrops.ts
* database/migrations/
* database/seed/
* backend/src/modules/farmers/
* backend/src/modules/crops/

Tasks:

1. Design PostgreSQL relational model.
2. Create farmer schema.
3. Create crop schema.
4. Create farmerCrops relation.
5. Add indexes/constraints.
6. Generate Drizzle migrations.
7. Test migrations on a clean database.
8. Create safe demo seed data.
9. Implement farmer CRUD APIs required by MVP.
10. Implement crop APIs.
11. Implement farmer-crop assignment.
12. Validate input.
13. Add database/API tests.
14. Publish the stable farmer response contract for mobile and messaging logic.

Important:
Do not add unrelated entities just because they may be useful later. Build the data needed by the MVP.

### B7. Backend Member 5 — Agricultural Content, Review & Targeting

Primary Owner: Hawi Jarso
Files:

* backend/src/modules/content/
* database/schema/content.ts
* database/schema/contentReviews.ts
* content workflow tests

Tasks:

1. Create content schema.
2. Create content review schema.
3. Implement draft creation.
4. Implement content editing.
5. Implement submit-for-review.
6. Implement expert approval.
7. Implement rejection with reason.
8. Implement publish/archive status.
9. Enforce status transitions.
10. Add authorization to review/publish endpoints.
11. Document content API contracts.

Content flow:
DRAFT → IN_REVIEW → APPROVED → PUBLISHED
DRAFT → IN_REVIEW → REJECTED
REJECTED → DRAFT
PUBLISHED → ARCHIVED

### B8. Backend Member 6 — Messaging Simulation, Integration, Testing & CI

Primary Owner: Fuad Yibrie
Files:

* backend/src/modules/messaging/
* backend/src/services/targeting/
* backend/src/services/sms/
* backend/src/services/ivr/
* database/schema/messages.ts
* database/schema/messageRecipients.ts

Tasks:

1. Create message schema.
2. Create message-recipient schema.
3. Implement message creation.
4. Connect approved content to targeting service.
5. Create targeting rules based on available farmer fields (crop, location, language).
6. Implement SmsProvider interface.
7. Implement SmsSimulator.
8. Record QUEUED/SENT/DELIVERED/FAILED states.
9. Implement VoiceProvider interface.
10. Implement IvrSimulator.
11. Provide APIs the Flutter app can call to demonstrate the simulators.
12. Add integration tests.
13. Configure GitHub Actions.
14. Run backend lint/test/build in CI.
15. Coordinate backend integration bugs.

Do not connect to a real telecom provider in the MVP.

### B9. Frontend Member 1 — Flutter UI & Navigation

Primary Owner: Eldana Babu
Files:

* mobile/lib/features/
* mobile/lib/core/ UI/navigation portions

Tasks:

1. Bootstrap Flutter project.
2. Create application theme.
3. Create navigation structure.
4. Build login/register UI.
5. Build farmer home screen.
6. Build farmer profile screen.
7. Build agricultural information list/detail screens.
8. Build alert/information screens.
9. Build loading/empty/error states.
10. Build role-aware navigation.
11. Create reusable buttons, fields, cards and layouts.
12. Keep screens connected to service interfaces rather than hard-coding backend logic.
13. Add widget tests for critical screens.

UI should not contain business authorization logic. It should only reflect the permissions already provided by the authenticated backend session.

### B10. Frontend Member 2 — Flutter State, Forms & API Integration

Primary Owner: Etsegenet Amsalu
Files:

* mobile/lib/services/
* mobile/lib/models/
* feature state/form logic

Tasks:

1. Define Dart models matching backend contracts.
2. Build API client.
3. Implement authentication API integration.
4. Store/refresh authentication state according to chosen auth approach.
5. Connect farmer profile APIs.
6. Connect content/information APIs.
7. Connect alerts.
8. Build SMS simulator screen.
9. Build IVR simulator screen.
10. Implement form validation.
11. Handle API errors.
12. Handle loading/retry states.
13. Add Flutter tests.
14. Coordinate API contract changes with backend members.

No API endpoint URLs should be scattered across UI widgets. Centralize them in the service layer.

### B11. Exact Database Model

users

* id UUID primary key
* full_name
* phone/email as appropriate
* password_hash
* role
* preferred_language
* created_at
* updated_at

farmers

* id UUID primary key
* user_id
* region
* zone
* woreda
* kebele
* latitude/longitude if used
* alert_enabled
* created_at
* updated_at

crops

* id UUID primary key
* name
* description
* active

farmerCrops

* farmer_id
* crop_id

content

* id UUID
* title
* body
* crop_id or target metadata
* language
* location metadata if needed
* status
* created_by
* approved_by
* approved_at
* created_at
* updated_at

contentReviews

* id
* content_id
* reviewer_id
* decision
* comment
* created_at

messages

* id
* content_id
* channel
* status
* created_by
* created_at

messageRecipients

* id
* message_id
* farmer_id
* delivery_status
* delivered_at
* failure_reason

auditLogs

* id
* actor_user_id
* action
* entity_type
* entity_id
* metadata
* created_at

Note:
A help-request/assistance subsystem is intentionally NOT part of this MVP schema.

### B12. REST API Contract

API prefix:
/api

AUTH

* POST /api/auth/register
* POST /api/auth/login
* GET /api/auth/me

FARMERS

* POST /api/farmers
* GET /api/farmers
* GET /api/farmers/:id
* PATCH /api/farmers/:id

CROPS

* GET /api/crops
* POST /api/crops
* POST /api/farmers/:id/crops

CONTENT

* POST /api/content
* GET /api/content
* GET /api/content/:id
* PATCH /api/content/:id
* POST /api/content/:id/submit-review
* POST /api/content/:id/approve
* POST /api/content/:id/reject
* POST /api/content/:id/publish

MESSAGING

* POST /api/messages
* GET /api/messages/:id
* GET /api/messages/:id/recipients

SIMULATION

* POST /api/simulation/sms
* POST /api/simulation/ivr/session

Every endpoint must:

* validate input
* authenticate where necessary
* enforce role permissions
* return consistent errors
* have tests for important rules

### B13. SMS Simulator Technical Flow

```text
Approved content
→ targeting service
→ identify matching farmers
→ create message
→ create recipients
→ SmsSimulator
→ update delivery status
→ mobile app displays simulation result.

Provider abstraction:

SmsProvider
  └── SmsSimulator
  └── FutureRealSmsProvider

The simulator must not send real SMS messages.

Example simulated result:
{
  "farmerId": "demo-id",
  "phone": "+251...",
  "status": "DELIVERED",
  "message": "Demo agricultural information"
}

Use fake/demo numbers in development.

```

### B14. IVR Simulator Technical Flow

```text
The IVR simulator represents the software behavior of a future voice system.

Example:
Start session
→ choose language
→ main menu
→ choose agricultural information
→ choose crop/topic
→ display or simulate spoken response
→ optionally show next menu.

Provider abstraction:

VoiceProvider
  └── IvrSimulator
  └── FutureRealVoiceProvider

The MVP does not require a real phone call or telecom permission. The simulator demonstrates the application logic and state transitions.

```

### B15. Mobile Architecture

```text
Recommended structure:

mobile/lib/
├── core/
│   ├── constants/
│   ├── config/
│   ├── routing/
│   └── widgets/
├── models/
├── services/
│   ├── api_client.dart
│   ├── auth_service.dart
│   ├── farmer_service.dart
│   ├── content_service.dart
│   └── messaging_service.dart
├── features/
│   ├── auth/
│   ├── farmer/
│   ├── content/
│   ├── alerts/
│   └── simulator/
└── main.dart

Dependency direction:
UI → feature/state logic → service → API → backend.

Do not:
UI → direct SQL
UI → hard-coded authorization
UI → scattered HTTP requests

```

### B16. GitHub Repository Setup

Repository:
agri-insight-beacon

Initial setup:

1. Create repository.
2. Add README.md.
3. Add .gitignore.
4. Add .env.example.
5. Invite insa-ctc-devhub.
6. Add all six members.
7. Protect main.
8. Require Pull Requests.
9. Require CI before merge when CI is configured.
10. Create GitHub Issues.
11. Assign issues to individual members.

Recommended labels:

* area:mobile
* area:backend
* area:database
* area:security
* area:testing
* type:feature
* type:bug
* type:docs
* priority:high
* priority:medium
* priority:low

### B17. Branch Strategy

ONE main branch:
main

Every developer works in a feature/fix/docs branch.

Examples:

* feature/14-farmer-profile
* feature/25-content-approval
* feature/31-sms-simulator
* feature/40-flutter-login
* fix/45-auth-token
* docs/8-api-contract

No direct pushes to main.

Flow:
main
↓
feature/issue-number-short-name
↓
commit
↓
push
↓
Pull Request
↓
review + CI
↓
merge to main

### B18. Exact Developer Git Workflow

First time:

1. git clone <REPOSITORY_URL>
2. cd agri-insight-beacon
3. git status

Start a new task:

1. git checkout main
2. git pull origin main
3. git checkout -b feature/XX-short-name

Work only on the assigned issue.

Before commit:

1. git status
2. git diff

Run the appropriate formatter/linter/tests.

Commit:

1. git add 
2. git commit -m "feat: implement farmer profile"

Push:

1. git push -u origin feature/XX-short-name

Open Pull Request.

After merge:

1. git checkout main
2. git pull origin main
3. git branch -d feature/XX-short-name
4. git push origin --delete feature/XX-short-name

### B19. Pull Request Rules

PR title:
feat: implement farmer profile (#14)

PR description must include:

* Issue being completed
* What changed
* Why it changed
* Files/modules changed
* How it was tested
* Screenshots for mobile UI changes
* Dependencies or API changes
* Known limitations

Before merge:

* Issue linked
* Tests pass
* No secrets
* No unrelated changes
* API contract updated if changed
* Database docs/migration included if schema changed
* Reviewer approved
* CI passes

The developer who wrote the code should not simply self-approve and merge without the agreed review process.

### B20. Merge Conflicts

If a conflict happens:

1. Do not delete the other person's code blindly.
2. Check which files conflict.
3. If it is a shared API/database file, coordinate with the owner.
4. Update your local main:
git checkout main
git pull origin main
5. Return to branch:
git checkout feature/XX-name
6. Merge main:
git merge main
7. Resolve conflict markers.
8. Run formatter.
9. Run tests.
10. Commit the resolution.
11. Push.
12. Ask for review again if behavior changed.

### B21. Database Migration Workflow

When schema changes:

1. Open/update the GitHub issue.
2. Announce the schema change in the team communication channel.
3. Update Drizzle schema.
4. Generate migration.
5. Inspect generated SQL.
6. Run migration locally.
7. Test on a clean database.
8. Update database documentation.
9. Commit schema + migration together.
10. Open PR.
11. Backend members review.
12. Merge.
13. Tell frontend member(s) if API response changes.

Never:

* commit database passwords
* delete migration history to hide errors
* make undocumented shared schema changes

### B22. Local Environment Setup

Required:

* Git
* Node.js LTS
* npm
* PostgreSQL or Docker
* VS Code/IDE
* Flutter SDK
* Android Studio/emulator or physical Android test device
* GitHub account

Backend:

1. cd backend
2. npm install

Create backend/.env from .env.example.

Example:
DATABASE_URL=postgresql://...
JWT_SECRET=...
PORT=4000

Mobile:

1. cd mobile
2. flutter pub get
3. flutter doctor

Do not commit .env.

### B23. Docker PostgreSQL

Recommended:
docker compose up -d

Then:

* verify PostgreSQL is running
* run Drizzle migrations
* run demo seed
* start backend

Stop:
docker compose down

The repository should make it possible for a new member to reproduce the database environment without manually creating tables.

### B24. Testing Strategy

Backend:

* unit tests for business rules
* API/integration tests
* authentication tests
* authorization tests
* database/migration tests where useful
* targeting tests
* simulator tests

Mobile:

* widget tests
* form validation tests
* service/API tests where appropriate
* navigation/auth state tests

Critical Tests:

1. Unauthenticated users cannot access protected endpoints.
2. Wrong roles cannot approve/publish content.
3. Unapproved content cannot be published.
4. Disabled-alert farmers are excluded from targeting.
5. Crop mismatch is excluded.
6. Targeting returns unique farmers.
7. SMS simulator records status.
8. IVR simulator follows valid state transitions.

### B25. Security Rules

Authentication:

* Passwords hashed
* No password hashes returned to client
* Tokens/session handled securely
* Sensitive data not logged

Authorization:

* Backend checks role
* Backend checks resource permissions

Validation:

* Request bodies validated
* Query parameters validated
* IDs validated

Secrets:

* .env ignored
* .env.example uses placeholders
* No API keys in source

Database:

* ORM/parameterized queries
* Foreign keys
* Constraints
* Safe demo data only

Do not assume the Flutter app is trusted.

### B26. Error Response Standard

Example:
{
"error": {
"code": "VALIDATION_ERROR",
"message": "Invalid request",
"details": []
}
}

Use:

* 400: invalid input
* 401: unauthenticated
* 403: forbidden
* 404: not found
* 409: conflict
* 500: unexpected server error

Do not expose stack traces or secrets to clients.

### B27. Suggested GitHub Issues

Foundation:

* #1: Repository + README
* #2: Backend bootstrap
* #3: Database connection
* #4: Drizzle migration setup
* #5: Authentication
* #6: Authorization middleware
* #7: GitHub Actions CI

Database / Farmers:

* #10: User/farmer schema
* #11: Crop schema
* #12: Farmer CRUD
* #13: Crop assignment
* #14: Seed/demo data

Content:

* #20: Content schema
* #21: Content CRUD
* #22: Review workflow
* #23: Expert approval
* #24: Rejection workflow
* #25: Publish workflow

Messaging:

* #30: Message schema
* #31: Recipient tracking
* #32: Targeting service
* #33: SMS simulator
* #34: IVR simulator
* #35: Messaging integration tests

Mobile:

* #40: Flutter project setup
* #41: Navigation/theme
* #42: Login/register
* #43: Farmer profile
* #44: Agricultural information
* #45: Alerts
* #46: SMS simulator UI
* #47: IVR simulator UI
* #48: API integration/state management
* #49: Mobile tests

Release:

* #55: End-to-end integration
* #56: Security review
* #57: Final QA
* #58: README/documentation
* #59: Demo rehearsal
* #60: Release/code freeze

### B28. Issue Template

Objective:
What exactly will be built?

Owner:
Member:
Area: Backend / Mobile

Dependencies:

* Issue #
* API/schema dependency

Files / Modules:
List expected files.

Testing:

* Unit/API/widget test
* Manual test

Notes:
Known constraints or decisions.

### B29. Definition of Done

An issue is DONE when:

* acceptance criteria are met
* code is on a feature branch
* tests pass
* validation exists
* authorization exists where needed
* no secrets are committed
* documentation is updated when necessary
* PR is reviewed
* CI passes
* PR is merged to main
* GitHub Issue is moved to DONE

'Works on my machine' is not enough.

### B30. Integration Order

Phase 1 — Foundation

* Backend bootstrap
* Database
* Authentication
* Flutter bootstrap

Phase 2 — Farmer Data

* Farmers
* Crops
* Seed data
* Flutter farmer profile

Phase 3 — Agricultural Content

* Content CRUD
* Review/approval
* Mobile information screens

Phase 4 — Targeting & Messaging

* Targeting
* SMS simulator
* IVR simulator
* Mobile simulator screens

Phase 5 — Integration

* Authentication
* farmer data
* content
* targeting
* simulators
* end-to-end flow

Phase 6 — QA / RELEASE

* security
* tests
* bug fixing
* README
* demo
* code freeze

### B31. Seven-Day Practical Work Plan

Day 1
Backend:

* repository/bootstrap
* database connection
* users/auth foundation
* farmer/crop schema
Mobile:
* Flutter project
* navigation/theme
* login screen skeleton

Day 2
Backend:

* authentication
* farmer/crop APIs
* migrations/seeds
Mobile:
* authentication integration
* farmer profile UI

Day 3
Backend:

* content CRUD
* review/approval workflow
Mobile:
* agricultural information screens
* API integration

Day 4
Backend:

* targeting
* message schemas
* SMS simulator
Mobile:
* alerts
* SMS simulator UI

Day 5
Backend:

* IVR simulator
* integration tests
* CI
Mobile:
* IVR simulator UI
* loading/error/empty states

Day 6
Whole team:

* end-to-end integration
* security checks
* bug fixing
* remove non-MVP features

Day 7
Whole team:

* clean setup test
* final README
* GitHub review
* demo rehearsal
* screenshots
* code freeze

If the real deadline is shorter, compress the schedule but do not add scope.

### B32. Final End-to-End Demo

Recommended demo:

1. Open Flutter mobile application.
2. Log in with a demo account.
3. Show farmer profile.
4. Show crop/location/language.
5. Show agricultural information.
6. Demonstrate approved content.
7. Show that targeting identifies a matching farmer.
8. Open SMS simulator.
9. Demonstrate a simulated delivery.
10. Open IVR simulator.
11. Demonstrate language/menu selection.
12. Show role-based access by switching demo account/role where appropriate.
13. Show backend/API/database relationship briefly.
14. Show GitHub repository, Issues, PRs and CI.
15. Explain that real telecom integration and web are future scope.

The demonstration should prove one complete technical workflow.

### B33. Final Submission Checklist

Concept:

* Project title
* Problem
* MVP
* Main features
* Scope boundaries
* Six members
* CTC numbers
* Classroom numbers

Mobile:

* Flutter app builds
* Login works
* Farmer profile works
* Information works
* Alerts work
* SMS simulator works
* IVR simulator works

Backend:

* API starts
* PostgreSQL starts
* Migrations work
* Seed works
* Authentication works
* Authorization works
* Content review works
* Targeting works
* Messaging simulation works

GitHub:

* Repository name is professional
* insa-ctc-devhub invited
* Issues assigned
* Feature branches used
* PRs reviewed
* CI passes
* main protected if supported

Security:

* No secrets
* Input validation
* Safe errors
* Backend authorization

Scope:

* No separate web application
* No assistance/help subsystem
* No unnecessary AI/IoT/payment features
* Core mobile + backend workflow is complete

### B34. README Template

# Agri-Insight Beacon

## Short Description

Agri-Insight Beacon is a mobile agricultural information and communication platform that connects farmers with relevant, expert-reviewed agricultural information through a structured backend and Flutter mobile application.

## Problem

Farmers may not receive agricultural information that is relevant to their crop, location or preferred language. The system provides structured farmer data, expert-reviewed information, targeting and communication simulation.

## MVP Features

* Flutter mobile application
* Authentication
* Farmer profile
* Crop and location management
* Agricultural information
* Expert review/approval
* Targeting
* SMS simulator
* IVR simulator
* Role-based access
* PostgreSQL persistence
* REST API

## Technologies

* Flutter / Dart
* Node.js
* Express
* TypeScript
* PostgreSQL
* Drizzle ORM
* Zod
* JWT
* GitHub Actions

## Team

ONE team — 6 members
2 Mobile/Frontend
4 Backend

| Full Name | CTC Number | Classroom | Responsibility |
| --- | --- | --- | --- |
| Eldana Babu | CTC-3321-26 | 3003 | Mobile UI & Navigation |
| Etsegenet Amsalu | CTC-1495-26 | 3003 | Mobile State/API |
| Ezra Ambaw | CTC-2682-26 | 3003 | Backend Auth/Security |
| Hanifa Seid | CTC-1646-26 | 3003 | Database/Farmers/Crops |
| Hawi Jarso | CTC-3472-26 | 3003 | Content/Review/Targeting |
| Fuad Yibrie | CTC-0345-26 | 3003 | Messaging/Integration/CI |

## Scope

Current client: Mobile only.
Web is not part of the current MVP.

## Development

All work is done through feature branches and Pull Requests. Direct pushes to main are not allowed.

## Documentation

See /docs for technical architecture, database, API, GitHub workflow, team responsibilities and demo instructions.

### B35. New Member — Exact Start Checklist

1. Read Part A to understand the product.
2. Read your assigned responsibility in Part B.
3. Read the README.
4. Clone the repository.
5. Install required tools.
6. Configure local environment.
7. Start PostgreSQL.
8. Run migrations.
9. Run seed.
10. Start backend.
11. Start Flutter app.
12. Confirm the project works before changing code.
13. Open your assigned GitHub Issue.
14. Create a feature branch.
15. Implement only the assigned scope.
16. Run tests.
17. Commit.
18. Push.
19. Open PR.
20. Link issue.
21. Wait for review/CI.
22. Fix comments.
23. Merge after approval.
24. Pull main.
25. Confirm integration.
26. Move issue to DONE.

### B36. Final Responsibility Map

* MEMBER 1 (Eldana Babu) — MOBILE: Flutter UI, navigation, reusable widgets, farmer-facing screens
* MEMBER 2 (Etsegenet Amsalu) — MOBILE: Dart models, API client, state/forms, alerts/simulators integration
* MEMBER 3 (Ezra Ambaw) — BACKEND: Node/Express foundation, authentication, authorization, security
* MEMBER 4 (Hanifa Seid) — BACKEND: PostgreSQL, Drizzle, migrations, farmers, crops, seeds
* MEMBER 5 (Hawi Jarso) — BACKEND: Agricultural content, expert review, approval, targeting
* MEMBER 6 (Fuad Yibrie) — BACKEND: SMS/IVR simulation, messaging APIs, integration tests, CI

ALL SIX

* communicate API/schema changes
* review PRs
* test integration
* protect MVP scope
* prepare the final demo

There are no separate "help", "assistance", or "web" development teams in this plan.

```

```