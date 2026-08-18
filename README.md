# Agri-Insight Beacon

## Project Title
**Agri-Insight Beacon** — Mobile Agricultural Information & Advisory Platform

## Short Description
Agri-Insight Beacon is a mobile application and backend platform that delivers relevant, expert-reviewed agricultural information to farmers. Farmers maintain a profile (location, language, crops), agricultural content is created and passed through an expert review/approval workflow, and the system identifies which farmers each approved piece of content is relevant to. The mobile app is built with Flutter, and the platform also demonstrates how alerts could be delivered through an SMS simulator and an IVR-style voice menu simulator — without requiring a real telecom integration.

## The Problem This Project Solves
Farmers often do not receive agricultural information that matches their crop, location, or preferred language, and the volume of agricultural knowledge available is difficult to organize and deliver in a structured way. Agri-Insight Beacon solves the **software side** of this problem by providing:
- Structured farmer profiles (location, language, crops)
- A centralized system for managing agricultural content
- An expert review/approval workflow so only validated information reaches farmers
- Targeted delivery of information to the farmers it's actually relevant to
- A mobile app as the farmer-facing access point
- Simulated SMS and IVR communication channels
- Role-based access so each type of user only does what they're permitted to do

This MVP demonstrates the digital workflow, not the full real-world agricultural extension infrastructure.

## Main Features We Plan to Develop
- **Authentication & Role-Based Access** — login and permissions for Farmer, Extension Worker, Agricultural Expert, and Admin roles
- **Farmer Profile** — location, preferred language, and crop information per farmer
- **Agricultural Content Management** — authorized users can create and manage advisory content
- **Expert Review Workflow** — content moves through Draft → In Review → Approved/Rejected → Published → Archived
- **Targeting** — approved content is matched to farmers based on crop, location, and language
- **Mobile Experience (Flutter)** — the farmer-facing app for viewing profile info and agricultural content
- **SMS Simulator** — demonstrates how an approved message would be selected and "sent" without a real telecom provider
- **IVR Simulator** — demonstrates a voice-menu style interaction without a real telecom provider
- **Backend REST API** — Node.js/Express/TypeScript API with PostgreSQL persistence via Drizzle ORM
- **Validation, Error Handling & Audit Logging** — for a secure, reliable MVP
- **Automated Tests** — covering the critical authentication, authorization, review, and targeting workflows

**Out of scope for this MVP:** a separate web interface, production SMS/IVR telecom integration, AI crop diagnosis, IoT/sensor integration, satellite analytics, and payment systems.

## Team

**ONE development team — 6 members**
Work split: 2 Frontend/Mobile + 4 Backend

## 👥 Team Members

| # | Full Name | CTC Number | Classroom Number |
|---|---|---|---|
| 1 | Eldana Babu | CTC-3321-26 | 3003 |
| 2 | Etsegenet Amsalu | CTC-1495-26 | 3003 |
| 3 | Ezra Ambaw | CTC-2682-26 | 3003 |
| 4 | Fuad Yibrie | CTC-0345-26 | 3003 |
| 5 | Hanifa Seid | CTC-1646-26 | 3003 |
| 6 | Hawi Jarso | CTC-3472-26 | 3003 |
## Technologies

**Backend:** Node.js, TypeScript, Express, Drizzle ORM, PostgreSQL, Zod, JWT/session auth, Argon2id password hashing
**Mobile:** Flutter, Dart
**Testing:** Vitest/Jest, Supertest, Flutter test
**DevOps:** Git, GitHub, GitHub Actions, Docker / Docker Compose

## Scope
Current client target: **Mobile application only.** A separate web interface is not part of the current MVP deliverable.

## Repository Structure
```
agri-insight-beacon/
├── backend/        # Node/Express/TypeScript API
├── mobile/         # Flutter application
├── database/       # Drizzle schema, migrations, seed data
├── docs/           # Technical and project documentation
└── .github/        # CI workflows
```
See `/docs` for architecture, database, API, GitHub workflow, and demo details.

## Development Workflow
All work happens on feature branches, merged into `main` through reviewed Pull Requests. Direct pushes to `main` are not allowed. See `docs/github-workflow.md` for the full branching and PR process.

## Getting Started

**Backend**
```bash
cd backend
npm install
# create backend/.env from .env.example
npm run dev
```

**Mobile**
```bash
cd mobile
flutter pub get
flutter run
```

**Database**
```bash
docker compose up -d
# run migrations, then seed demo data
```

## Collaborators
This repository has invited `insa-ctc-devhub` as a collaborator as required for review.
