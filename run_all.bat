@echo off
rem ---------- Start Docker containers (PostgreSQL) ----------
docker compose up -d

rem ---------- Launch Backend (Node/Express) ----------
start "Backend" cmd /c "cd /d %~dp0backend ^&^& (if not exist node_modules (npm ci) ) ^& npm run dev"

rem ---------- Launch Mobile (Flutter) ----------
start "Mobile" cmd /c "cd /d %~dp0mobile ^&^& flutter pub get ^& flutter run"

rem ---------- Done ----------
echo All services have been started. Use Ctrl+C to stop the batch if needed.
pause