$ErrorActionPreference = "Stop"

Write-Host "A preparar a TechAir 2.0..." -ForegroundColor Cyan

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw "Flutter não foi encontrado no PATH. Abre um terminal onde 'flutter doctor' funcione."
}

flutter config --enable-windows-desktop
flutter create --platforms=windows,android,web --project-name techair_2_0 .

if (Test-Path "android/app/google-services.json.backup") {
  Copy-Item "android/app/google-services.json.backup" "android/app/google-services.json" -Force
}

flutter pub get
flutter clean

Write-Host "Projeto preparado. Executa: flutter run -d windows" -ForegroundColor Green
