Set-Location 'C:\Users\ezraa\Desktop\grad_proj'
docker compose up -d postgres

Set-Location 'C:\Users\ezraa\Desktop\grad_proj\backend'
if (-not (Test-Path .env)) { Copy-Item ..\.env.example .env }
npm ci
npm run db:migrate
npm run db:seed
npm run dev

Set-Location 'C:\Users\ezraa\Desktop\grad_proj\mobile'
flutter pub get
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
flutter run -d chrome --web-port 8080