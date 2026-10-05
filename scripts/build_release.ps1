# TuliMovie — build otimizado Web + APK (Windows PowerShell)
param(
  [string]$TmdbApiKey = $env:TMDB_API_KEY,
  [string]$FcmVapidKey = $env:FCM_VAPID_KEY
)

$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)

if (-not $TmdbApiKey) {
  Write-Warning "Defina TMDB_API_KEY ou passe -TmdbApiKey"
}

$defines = @("--dart-define=TMDB_API_KEY=$TmdbApiKey")
if ($FcmVapidKey) {
  $defines += "--dart-define=FCM_VAPID_KEY=$FcmVapidKey"
}

Write-Host ">> flutter pub get"
flutter pub get

Write-Host ">> flutter build web --release (Wasm/CanvasKit auto)"
flutter build web --release @defines

Write-Host ">> flutter build apk --release"
flutter build apk --release @defines

Write-Host ""
Write-Host "Artefatos:"
Write-Host "  Web: build/web"
Write-Host "  APK: build/app/outputs/flutter-apk/app-release.apk"
Write-Host ""
Write-Host "Deploy Hosting: firebase deploy --only hosting"
