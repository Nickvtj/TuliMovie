# Deploy PWA para Firebase Hosting
$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)

if (-not (Test-Path "build/web/index.html")) {
  Write-Error "Rode scripts/build_release.ps1 (ou flutter build web) antes do deploy."
}

# Copia SW de messaging para o build (Flutter não inclui automaticamente)
Copy-Item -Force "web/firebase-messaging-sw.js" "build/web/firebase-messaging-sw.js"
Copy-Item -Force "web/manifest.json" "build/web/manifest.json"

Write-Host ">> firebase deploy --only hosting"
firebase deploy --only hosting
