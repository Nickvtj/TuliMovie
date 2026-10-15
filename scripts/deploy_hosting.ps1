# Deploy Firebase Hosting (usa npx — não precisa firebase global no PATH)
param(
  [string]$TmdbApiKey = $env:TMDB_API_KEY
)

$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)

function Find-Node {
  $candidates = @(
    "$env:ProgramFiles\nodejs\node.exe",
    "${env:ProgramFiles(x86)}\nodejs\node.exe",
    "$env:LOCALAPPDATA\Programs\nodejs\node.exe",
    "C:\nvm\nodejs\node.exe"
  )
  foreach ($p in $candidates) {
    if (Test-Path $p) { return $p }
  }
  $cmd = Get-Command node -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  return $null
}

$node = Find-Node
if (-not $node) {
  Write-Host ""
  Write-Host "Node.js não encontrado. No instalador do Node:"
  Write-Host "  1) Custom Setup -> marque TUDO como 'instalar no disco'"
  Write-Host "  2) Em 'Add to PATH' -> 'Node.js and npm' = instalado"
  Write-Host "  3) Conclua o instalador e FECHE/ABRA o PowerShell"
  Write-Host ""
  Write-Host "Ou instale: winget install OpenJS.NodeJS.LTS"
  exit 1
}

Write-Host "Node: $node"
& $node -v

if (-not $TmdbApiKey) {
  Write-Warning "TMDB_API_KEY não definida. Descubra/Avaliar não carregam filmes na web."
  Write-Host "Exemplo: `$env:TMDB_API_KEY='sua_chave'; .\scripts\deploy_hosting.ps1"
}

$defines = @()
if ($TmdbApiKey) { $defines += "--dart-define=TMDB_API_KEY=$TmdbApiKey" }

Write-Host ">> flutter pub get"
flutter pub get

Write-Host ">> flutter build web --release"
if ($defines.Count -gt 0) {
  flutter build web --release @defines
} else {
  flutter build web --release
}

if (-not (Test-Path "build/web/index.html")) {
  Write-Error "Build web falhou."
}

if (Test-Path "web/firebase-messaging-sw.js") {
  Copy-Item -Force "web/firebase-messaging-sw.js" "build/web/firebase-messaging-sw.js"
}

Write-Host ">> npx firebase-tools deploy --only hosting"
$npx = Join-Path (Split-Path $node -Parent) "npx.cmd"
if (Test-Path $npx) {
  & $npx --yes firebase-tools@latest deploy --only hosting
} else {
  & $node (Join-Path (Split-Path $node -Parent) "node_modules\npm\bin\npx-cli.js") --yes firebase-tools@latest deploy --only hosting
}
