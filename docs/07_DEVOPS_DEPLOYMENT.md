# DevOps & Deployment Guide
## Agri-Insight Beacon Platform

**Operating Systems Supported:** Linux (Ubuntu 22.04+ / Debian 12), Windows 10/11, macOS  
**Containerization:** Docker & Docker Compose  
**Database:** PostgreSQL 16 (Alpine)  
**Last Updated:** October 2026  

---

## 1. Environment Variables Dictionary

The system uses `dotenv` to load environment variables at runtime. Ensure `.env` is created in `/backend` or the root workspace based on `.env.example`:

| Variable Key | Required | Default / Example Value | Description |
| :--- | :---: | :--- | :--- |
| `PORT` | No | `3000` | Port on which the Express REST API listens. |
| `NODE_ENV` | No | `development` | Operating environment (`development`, `test`, `production`). |
| `DATABASE_URL` | **Yes** | `postgresql://postgres:postgres@localhost:5433/agri_insight` | PostgreSQL connection string. (Port 5433 maps to container port 5432). |
| `JWT_ACCESS_SECRET`| **Yes** | `f87920ab4c6731e84a9235bc0123...` | Cryptographic secret for signing access tokens (minimum 32 characters). |
| `JWT_ACCESS_TTL` | No | `15m` | Lifetime of JWT access token before expiration. |
| `REFRESH_TOKEN_TTL_DAYS`| No | `7` | Retention window for opaque refresh tokens. |
| `CORS_ORIGINS` | No | `http://localhost:3000,http://localhost:8080` | Comma-separated list of permitted web origins. |
| `API_BASE_URL` | **Yes** | `http://localhost:3000/api` | Base API URL configured for Flutter mobile and web clients. |

---

## 2. Local Development Setup (Step-by-Step)

Follow these steps to initialize the database, apply migrations, seed default users, and launch both backend and frontend applications:

### Step 1: Start PostgreSQL via Docker Compose
From the project root directory, launch the database container:
```bash
# Clean previous volumes (optional) and start PostgreSQL
docker compose down -v
docker compose up -d postgres
```
Verify the container is healthy:
```bash
docker compose ps
# Expected state: Up (healthy) on port 0.0.0.0:5433->5432/tcp
```

### Step 2: Initialize & Seed the Backend Database
Navigate to `/backend`, install dependencies, and run migrations:
```bash
cd backend
npm install

# Push DDL schema to PostgreSQL
npm run db:migrate

# Seed baseline users (Admin, Expert, DA, Farmer) and crops
npm run db:seed
```

### Step 3: Start the Express Development Server
Start the backend with TypeScript watch mode enabled:
```bash
npm run dev
# Server will listen on http://localhost:3000
```
Confirm health status by visiting `http://localhost:3000/api/health` in your browser.

### Step 4: Run the Flutter Client (Web or Mobile)
In a separate terminal, navigate to `/mobile`:
```bash
cd mobile
flutter pub get
```

- **Run on Chrome (Flutter Web):**
  ```bash
  flutter run -d chrome --web-port 8080
  ```
- **Run on Android Emulator:**
  ```bash
  flutter run -d android
  ```

---

## 3. Production Deployment Guide

### 3.1 Containerized Deployment (Docker)
The root `Dockerfile` utilizes a multi-stage build to produce a lean production image:

```bash
# Build the production Docker image
docker build -t agri-insight-backend:latest .

# Run the backend container in production mode
docker run -d \
  --name agri-backend \
  -p 3000:3000 \
  -e NODE_ENV=production \
  -e DATABASE_URL="postgresql://prod_user:strong_password@db-host:5432/agri_insight" \
  -e JWT_ACCESS_SECRET="a_very_long_secure_random_string_of_at_least_32_chars" \
  agri-insight-backend:latest
```

### 3.2 Building the Flutter Web Client for Production
Compile the Flutter web application to optimized HTML/JS/CanvasKit assets:
```bash
cd mobile
flutter build web --release --base-href "/"
```
Compiled output assets are placed in `/mobile/build/web`.

### 3.3 Nginx Web Server Configuration
Serve the Flutter Web bundle and reverse-proxy `/api` requests to Express using Nginx:

```nginx
server {
    listen 80;
    server_name agri-insight.et;

    # Serve Flutter Web Static Files
    location / {
        root /var/www/agri-insight/build/web;
        try_files $uri $uri/ /index.html;
        add_header Cache-Control "no-cache";
    }

    # Proxy API Requests to Express
    location /api/ {
        proxy_pass http://127.0.0.1:3000/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_cache_bypass $http_upgrade;
    }
}
```

---

## 4. CI/CD Pipeline Commands

Execute this automated check before merging pull requests or deploying releases:
```bash
# 1. Backend Lint & Typecheck
cd backend && npm run lint

# 2. Backend Automated Test Suite
npm run test

# 3. Backend Production TypeScript Build
npm run build

# 4. Flutter Static Code Analysis
cd ../mobile && flutter analyze

# 5. Flutter Unit & Widget Tests
flutter test
```
All commands must exit with code `0`.
