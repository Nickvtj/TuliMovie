# TuliMovie — build otimizado Web + APK (Windows PowerShell)
param(
  [string]$TmdbApiKey = $env:TMDB_API_KEY
)

$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)

if (-not $TmdbApiKey) {
  Write-Warning "Defina TMDB_API_KEY ou passe -TmdbApiKey"
}

$defines = @("--dart-define=TMDB_API_KEY=$TmdbApiKey")

Write-Host ">> flutter pub get"
flutter pub get

Write-Host ">> flutter build web --release (Wasm/CanvasKit auto)"
# --no-web-resources-cdn: CanvasKit servido pelo próprio site (evita tela branca no iPhone).
flutter build web --release --no-web-resources-cdn @defines

Write-Host ">> flutter build apk --release"
flutter build apk --release @defines

Write-Host ""
Write-Host "Artefatos:"
Write-Host "  Web: build/web"
Write-Host "  APK: build/app/outputs/flutter-apk/app-release.apk"
Write-Host ""
Write-Host "Deploy Hosting: firebase deploy --only hosting"
