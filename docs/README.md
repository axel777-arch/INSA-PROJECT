# Agri-Insight Beacon — Software Documentation Suite

Welcome to the enterprise software documentation suite for the **Agri-Insight Beacon Platform**. This repository contains the complete cross-platform mobile/web client (built with Flutter) and backend REST API engine (built with Node.js, Express, TypeScript, and PostgreSQL).

---

## Documentation Index

| # | Document | Target Audience | Purpose & Summary |
| :-: | :--- | :--- | :--- |
| **01** | [**Software Requirements Specification (SRS)**](./01_SRS.md) | Product Owners, Engineers, Evaluators | Complete functional requirements (FRs), non-functional requirements (NFRs), and Role-Based Access Control (RBAC) matrix. |
| **02** | [**System Architecture & Design**](./02_ARCHITECTURE.md) | Architects, Lead Developers | Multi-tier system architecture, Flutter cross-platform layering (`kIsWeb` abstraction), Express 5-stage pipeline, and project tree. |
| **03** | [**Data Architecture & Database Specification**](./03_DATABASE.md) | Database Engineers, Backend Devs | Entity-Relationship Model (ERD), full table-by-table data dictionary, and Drizzle ORM migration workflows. |
| **04** | [**REST API & Interface Specification**](./04_API.md) | Frontend Devs, QA Engineers, Integrators | Complete REST API endpoint reference, request/response JSON schemas, Zod validation constraints, and error matrices. |
| **05** | [**UI/UX Workflows & Platform Specifications**](./05_WORKFLOWS_UI.md) | UI/UX Designers, Mobile Devs | Screen transition hierarchy, role-based portals, and technical rules for handling web vs. mobile image rendering. |
| **06** | [**Quality Assurance & Hardening Log**](./06_TESTING_QA.md) | QA Leads, Reviewers | Automated test execution commands, pass/fail metrics, and detailed root-cause hardening logs for critical bug fixes. |
| **07** | [**DevOps & Deployment Guide**](./07_DEVOPS_DEPLOYMENT.md) | DevOps Engineers, System Admins | Environment variables dictionary, local development quickstart, Docker builds, Nginx proxy configs, and CI/CD pipelines. |
| **08** | [**Maintenance & Troubleshooting Guide**](./08_TROUBLESHOOTING.md) | Support Engineers, On-Call Devs | Terminal logging format, incident response matrix, common error solutions, and database reset procedures. |

---

## Quick Architecture Summary

```
   ┌────────────────────────────────┐       ┌────────────────────────────────┐
   │    Flutter Web Client (SPA)    │       │     Flutter Mobile (Android)   │
   └───────────────┬────────────────┘       └───────────────┬────────────────┘
                   │                                        │
                   └───────────────────┬────────────────────┘
                                       │ HTTP / REST (Bearer JWT)
                                       ▼
                       ┌────────────────────────────────┐
                       │   Node.js / Express Backend    │
                       │     (TypeScript, Port 3000)    │
                       └───────────────┬────────────────┘
                                       │ SQL (Drizzle ORM)
                                       ▼
                       ┌────────────────────────────────┐
                       │      PostgreSQL 16 Database    │
                       │     (Docker Container :5433)   │
                       └────────────────────────────────┘
```

---

## Baseline Seeded User Accounts

For automated and manual validation across RBAC roles, use the following credentials:

| Role | Email / Phone | Password | Key Permissions |
| :--- | :--- | :--- | :--- |
| **System Admin** | `admin@gmail.com` / `+251900000000` | `Admin$2026` | Full platform control, audit logs, catalog creation |
| **Agronomy Expert** | `expert@gmail.com` / `+251912000001` | `Expert$2026` | Advisory validation, diagnosis responses, publishing |
| **Extension Worker** | `worker@gmail.com` / `+251911000001` | `Worker$2026` | Advisory drafting, farmer onboarding, field notes |
| **Smallholder Farmer**| `farmer@gmail.com` / `+251911223344` | `Farmer$2026` | Viewing advisories, receiving alerts, profile updates |

---

## Automated Test Verification

All automated test suites pass with 100% success rate:
- **Backend Test Suite:** `20 / 20 passed` (`npm run test` in `/backend`)
- **Mobile Test Suite:** `13 / 13 passed` (`flutter test` in `/mobile`)
- **API Newman Suite:** `18 / 18 passed` (`npx newman run Agri-Insight_API.postman_collection.json ...`)
- **Static Analysis:** `0 issues found` (`flutter analyze` & `npm run lint`)
