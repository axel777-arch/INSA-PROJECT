@echo off
echo ===================================================
echo   Agri-Insight Beacon - Local Environment Startup
echo ===================================================

echo [1/3] Building and starting latest Docker containers...
docker compose up -d --build

echo.
echo [2/3] Waiting for backend and database to become ready...
timeout /t 5 /nobreak >nul

echo.
echo [3/3] Fetching Flutter dependencies and launching app...
cd /d %~dp0mobile
call flutter pub get
start "Agri-Insight Mobile" cmd /c "flutter run -d chrome"

echo.
echo ===================================================
echo   System successfully launched!
echo   - Backend API: http://localhost:3001/api
echo   - Database: localhost:5433 (PostgreSQL)
echo   - Flutter Web: Opening in Google Chrome
echo   (Tip: In Chrome, press Ctrl+Shift+R to clear cache)
echo ===================================================
pause
