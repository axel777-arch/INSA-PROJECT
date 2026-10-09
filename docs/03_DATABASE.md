# Data Architecture & Database Specification
## Agri-Insight Beacon Platform

**Database Engine:** PostgreSQL 16  
**ORM Framework:** Drizzle ORM (Node.js/TypeScript)  
**Schema Definition Location:** `/database/schema/` & `/backend/src/db/schema/`  
**Last Updated:** October 2026  

---

## 1. Entity-Relationship Model (ERD)

The database schema is organized around a central user identity graph supporting role-based operational entities, agronomic content pipelines, and multi-channel messaging dispatches:

```
┌───────────────────────┐             1:1             ┌───────────────────────┐
│         USERS         ├─────────────────────────────┤        FARMERS        │
│ (Admin, Expert, DA,   │                             │ (Location, Alerts)    │
│  Farmer Identity)     │                             └───┬───────────────┬───┘
└──────────┬────────────┘                                 │ 1             │ 1
           │ 1                                            │               │
           │                                          *   │           *   │
           │ *                                 ┌──────────▼───┐   ┌───────▼───────────┐
     ┌─────┴─────────────┐                     │ FARMER_CROPS │   │MESSAGE_RECIPIENTS │
     │    AUDIT_LOGS     │                     │ (Junction)   │   │ (Farmer alerts)   │
     └───────────────────┘                     └──────▲───────┘   └───────▲───────────┘
           │ 1                                        │ *                 │ *
           │                                          │                   │
           │ *                                    1   │               1   │
     ┌─────┴─────────────┐                     ┌──────┴───────┐   ┌───────┴───────────┐
     │  REFRESH_TOKENS   │                     │    CROPS     │   │     MESSAGES      │
     └───────────────────┘                     │ (Catalog)    │   │ (SMS/IVR Master)  │
           │ 1                                 └──────▲───────┘   └───────▲───────────┘
           │                                          │ 1                 │ 1
           │ * (author/reviewer)                      │                   │
     ┌─────┴─────────────┐                     *      │           *       │
     │      CONTENT      ├────────────────────────────┘                   │
     │ (Advisory items)  ├────────────────────────────────────────────────┘
     └─────┬─────────────┘
           │ 1
           │
           │ *
     ┌─────┴─────────────┐
     │  CONTENT_REVIEWS  │
     │ (Audit log/notes) │
     └───────────────────┘
```

### Cardinality Summary
- **Users $\rightarrow$ Farmers:** One-to-One ($1:1$, optional).
- **Users $\rightarrow$ Content:** One-to-Many ($1:N$, as author or approving expert).
- **Farmers $\rightarrow$ Crops:** Many-to-Many ($M:N$, via `farmer_crops` junction table).
- **Crops $\rightarrow$ Content:** One-to-Many ($1:N$, optional reference).
- **Content $\rightarrow$ Content Reviews:** One-to-Many ($1:N$, recording workflow audit trails).
- **Content $\rightarrow$ Messages:** One-to-Many ($1:N$, triggered upon publication).
- **Messages $\rightarrow$ Message Recipients:** One-to-Many ($1:N$, per-farmer recipient dispatch records).
- **Users $\rightarrow$ Refresh Tokens:** One-to-Many ($1:N$, active sessions).
- **Users $\rightarrow$ Audit Logs:** One-to-Many ($1:N$, system audit actions).

---

## 2. Comprehensive Data Dictionary

### 2.1 Table: `users`
Stores system user authentication credentials, profiles, and role assignments.
Defined in: [database/schema/users.ts](file:///c:/Insa/grad_project/INSA-PROJECT/database/schema/users.ts)

| Column Name | Data Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `uuid` | `PRIMARY KEY` | `gen_random_uuid()` | Unique user identifier |
| `phone` | `varchar(20)` | `NOT NULL`, `UNIQUE` | — | E.164 phone number (`+2519...`) |
| `email` | `varchar(255)`| `UNIQUE` | `NULL` | Optional email address for login |
| `password_hash` | `varchar(255)`| `NOT NULL` | — | Argon2id cryptographic hash |
| `full_name` | `varchar(255)`| `NOT NULL` | — | Full display name |
| `role` | `enum('user_role')`| `NOT NULL` | `'FARMER'` | Values: `ADMIN`, `EXPERT`, `EXTENSION_WORKER`, `FARMER` |
| `preferred_language`| `varchar(10)` | `NOT NULL` | `'en'` | Preferred locale (`en`, `am`, `om`) |
| `created_at` | `timestamp with time zone` | `NOT NULL` | `now()` | Record creation timestamp |
| `updated_at` | `timestamp with time zone` | `NOT NULL` | `now()` | Last modification timestamp |

---

### 2.2 Table: `crops`
Agricultural crop master catalog.
Defined in: [database/schema/crops.ts](file:///c:/Insa/grad_project/INSA-PROJECT/database/schema/crops.ts)

| Column Name | Data Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `uuid` | `PRIMARY KEY` | `gen_random_uuid()` | Unique crop identifier |
| `name` | `varchar(100)`| `NOT NULL`, `UNIQUE`| — | Crop name (e.g., Maize, Teff, Wheat) |
| `description`| `text` | `NULL` | `NULL` | Agronomic characteristics |
| `active` | `boolean` | `NOT NULL` | `true` | Catalog visibility status |
| `created_at` | `timestamp with time zone` | `NOT NULL` | `now()` | Record creation timestamp |
| `updated_at` | `timestamp with time zone` | `NOT NULL` | `now()` | Last modification timestamp |

---

### 2.3 Table: `farmers`
Demographic and geographic extension data for registered farmers.
Defined in: [database/schema/farmers.ts](file:///c:/Insa/grad_project/INSA-PROJECT/database/schema/farmers.ts)

| Column Name | Data Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `uuid` | `PRIMARY KEY` | `gen_random_uuid()` | Unique farmer profile identifier |
| `user_id` | `uuid` | `NOT NULL`, `UNIQUE`, `FK(users.id)` | — | Linked user identity |
| `region` | `varchar(100)`| `NOT NULL` | — | Administrative region (e.g., Oromia, Amhara) |
| `zone` | `varchar(100)`| `NOT NULL` | — | Administrative zone |
| `woreda` | `varchar(100)`| `NOT NULL` | — | Administrative district (Woreda) |
| `kebele` | `varchar(100)`| `NOT NULL` | — | Local neighborhood / Kebele |
| `alert_enabled`| `boolean` | `NOT NULL` | `true` | Consent to receive broadcast alerts |
| `created_at` | `timestamp with time zone` | `NOT NULL` | `now()` | Record creation timestamp |
| `updated_at` | `timestamp with time zone` | `NOT NULL` | `now()` | Last modification timestamp |

---

### 2.4 Table: `farmer_crops`
Junction table mapping farmers to cultivated crops for targeted messaging.
Defined in: [database/schema/farmerCrops.ts](file:///c:/Insa/grad_project/INSA-PROJECT/database/schema/farmerCrops.ts)

| Column Name | Data Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `farmer_id` | `uuid` | `NOT NULL`, `FK(farmers.id)` | — | Associated farmer |
| `crop_id` | `uuid` | `NOT NULL`, `FK(crops.id)` | — | Cultivated crop |
| `created_at`| `timestamp with time zone` | `NOT NULL` | `now()` | Association timestamp |
| *Composite PK* | `(farmer_id, crop_id)` | `PRIMARY KEY` | — | Prevents duplicate bindings |

---

### 2.5 Table: `content`
Agronomic advisories, pest alerts, and technical bulletins.
Defined in: [database/schema/content.ts](file:///c:/Insa/grad_project/INSA-PROJECT/database/schema/content.ts)

| Column Name | Data Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `uuid` | `PRIMARY KEY` | `gen_random_uuid()` | Unique content identifier |
| `title` | `varchar(255)`| `NOT NULL` | — | Advisory headline |
| `body` | `text` | `NOT NULL` | — | Technical text or recommendation |
| `crop_id` | `uuid` | `FK(crops.id)`, `NULL` | `NULL` | Target crop (if crop-specific) |
| `category` | `varchar(100)`| `NULL` | `NULL` | Category (e.g., Pest & Disease, Irrigation) |
| `status` | `enum('content_status')` | `NOT NULL` | `'DRAFT'` | Values: `DRAFT`, `PENDING_REVIEW`, `APPROVED`, `PUBLISHED`, `REJECTED` |
| `author_id` | `uuid` | `FK(users.id)`, `NULL` | `NULL` | Author identity (DA or Expert) |
| `approved_by`| `uuid` | `FK(users.id)`, `NULL` | `NULL` | Approving expert identity |
| `created_at`| `timestamp with time zone` | `NOT NULL` | `now()` | Creation timestamp |
| `updated_at`| `timestamp with time zone` | `NOT NULL` | `now()` | Last status modification timestamp |

---

### 2.6 Table: `content_reviews`
Editorial audit trail capturing expert evaluations and rejection rationale.
Defined in: [database/schema/contentReviews.ts](file:///c:/Insa/grad_project/INSA-PROJECT/database/schema/contentReviews.ts)

| Column Name | Data Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `uuid` | `PRIMARY KEY` | `gen_random_uuid()` | Review record ID |
| `content_id`| `uuid` | `NOT NULL`, `FK(content.id)` | — | Reviewed advisory |
| `reviewer_id`| `uuid` | `NOT NULL`, `FK(users.id)` | — | Agronomy expert who evaluated |
| `decision` | `varchar(50)` | `NOT NULL` | — | Outcome (`APPROVED` or `REJECTED`) |
| `comment` | `text` | `NULL` | `NULL` | Mandatory rejection or review notes |
| `created_at`| `timestamp with time zone` | `NOT NULL` | `now()` | Review timestamp |

---

### 2.7 Tables: `messages` & `message_recipients`
Broadcast dispatches triggered upon advisory publication.
Defined in: [database/schema/messages.ts](file:///c:/Insa/grad_project/INSA-PROJECT/database/schema/messages.ts) and [database/schema/messageRecipients.ts](file:///c:/Insa/grad_project/INSA-PROJECT/database/schema/messageRecipients.ts)

#### `messages` (Broadcast Master)
| Column Name | Data Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `uuid` | `PRIMARY KEY` | `gen_random_uuid()` | Unique master message ID |
| `content_id`| `uuid` | `FK(content.id)`, `NULL` | `NULL` | Originating advisory |
| `channel` | `enum('message_channel')` | `NOT NULL` | `'SMS'` | Values: `SMS`, `IVR`, `PUSH` |
| `title` | `varchar(255)`| `NOT NULL` | — | Broadcast subject |
| `body` | `text` | `NOT NULL` | — | Message payload |
| `created_at`| `timestamp with time zone` | `NOT NULL` | `now()` | Dispatch timestamp |

#### `message_recipients` (Delivery Ledger)
| Column Name | Data Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `uuid` | `PRIMARY KEY` | `gen_random_uuid()` | Recipient item ID |
| `message_id`| `uuid` | `NOT NULL`, `FK(messages.id)` | — | Associated broadcast |
| `farmer_id` | `uuid` | `NOT NULL`, `FK(farmers.id)` | — | Recipient farmer |
| `status` | `enum('message_status')` | `NOT NULL` | `'QUEUED'` | Values: `QUEUED`, `SENT`, `DELIVERED`, `FAILED` |
| `sent_at` | `timestamp with time zone` | `NULL` | `NULL` | Timestamp transmission started |
| `delivered_at`| `timestamp with time zone`| `NULL` | `NULL` | Timestamp delivery acknowledged |
| `created_at`| `timestamp with time zone` | `NOT NULL` | `now()` | Ledger entry timestamp |

---

### 2.8 Table: `audit_logs`
System security and administrative audit log.
Defined in: [database/schema/auditLogs.ts](file:///c:/Insa/grad_project/INSA-PROJECT/database/schema/auditLogs.ts)

| Column Name | Data Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `uuid` | `PRIMARY KEY` | `gen_random_uuid()` | Audit event ID |
| `user_id` | `uuid` | `FK(users.id)`, `NULL` | `NULL` | Actor user (if authenticated) |
| `action` | `varchar(100)`| `NOT NULL` | — | Event code (e.g. `CONTENT_APPROVED`) |
| `entity_type`| `varchar(50)` | `NOT NULL` | — | Target entity (`content`, `user`, etc.) |
| `entity_id` | `varchar(100)`| `NOT NULL` | — | Identifier of impacted entity |
| `metadata` | `jsonb` | `NULL` | `NULL` | Contextual payload (IP, params, diff) |
| `created_at`| `timestamp with time zone` | `NOT NULL` | `now()` | Timestamp of event |

---

### 2.9 Table: `refresh_tokens`
Opaque rotated session refresh tokens.
Defined in: [backend/src/db/schema/refresh-tokens.ts](file:///c:/Insa/grad_project/INSA-PROJECT/backend/src/db/schema/refresh-tokens.ts)

| Column Name | Data Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `uuid` | `PRIMARY KEY` | `gen_random_uuid()` | Token record ID |
| `user_id` | `uuid` | `NOT NULL`, `FK(users.id)` | — | User owner |
| `token_hash`| `varchar(255)`| `NOT NULL` | — | SHA-256 hash of opaque token string |
| `expires_at`| `timestamp with time zone` | `NOT NULL` | — | Expiration threshold (7-day TTL) |
| `revoked_at`| `timestamp with time zone` | `NULL` | `NULL` | Invalidation timestamp (rotation/reuse) |
| `created_at`| `timestamp with time zone` | `NOT NULL` | `now()` | Issuance timestamp |

---

## 3. ORM & Database Migration Operations

### 3.1 Drizzle ORM Configuration
Database schemas are managed using Drizzle Kit. Configuration is set in [drizzle.config.ts](file:///c:/Insa/grad_project/INSA-PROJECT/drizzle.config.ts):

```typescript
import { defineConfig } from "drizzle-kit";

export default defineConfig({
  dialect: "postgresql",
  schema: "./database/schema/*",
  out: "./database/migrations",
  dbCredentials: {
    url: process.env.DATABASE_URL || "postgres://postgres:postgres@localhost:5433/agri_insight",
  },
});
```

### 3.2 Standard Migration & Seeding Workflow

1. **Generate Migration Files:** Generates SQL DDL migration files comparing schema definitions against current DB:
   ```bash
   cd backend
   npm run db:generate
   ```
2. **Apply Migrations:** Runs unapplied migration files against the target database:
   ```bash
   npm run db:migrate
   ```
3. **Seed Master Baseline Data:** Executes [database/seed.ts](file:///c:/Insa/grad_project/INSA-PROJECT/database/seed.ts) to populate initial seed records:
   ```bash
   npm run db:seed
   ```

#### Baseline Seeded Accounts:
- **System Admin:** `admin@gmail.com` / `+251900000000` (Password: `Admin$2026`)
- **Agronomy Expert:** `expert@gmail.com` / `+251912000001` (Password: `Expert$2026`)
- **Extension Worker:** `worker@gmail.com` / `+251911000001` (Password: `Worker$2026`)
- **Registered Farmer:** `farmer@gmail.com` / `+251911223344` (Password: `Farmer$2026`)
