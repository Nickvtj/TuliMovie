# TuliMovie — configura Firebase (FlutterFire) para Web + Android
param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectId
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

function Get-NodeDir {
  $candidates = @(
    "C:\Program Files\nodejs",
    "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Microsoft\VisualStudio\NodeJs",
    "C:\Program Files\Microsoft Visual Studio\2022\BuildTools\MSBuild\Microsoft\VisualStudio\NodeJs"
  )
  foreach ($dir in $candidates) {
    if (Test-Path (Join-Path $dir "node.exe")) { return $dir }
  }
  return $null
}

function Get-DartExe {
  $dart = Get-Command dart -ErrorAction SilentlyContinue
  if ($dart) { return $dart.Source }
  $fallback = "C:\flutter\bin\dart.bat"
  if (Test-Path $fallback) { return $fallback }
  throw "Dart/Flutter não encontrado. Instale Flutter ou adicione C:\flutter\bin ao PATH."
}

function Get-FlutterfireCmd {
  $paths = @(
    (Join-Path $env:LOCALAPPDATA "Pub\Cache\bin\flutterfire.bat"),
    (Join-Path $env:USERPROFILE "AppData\Local\Pub\Cache\bin\flutterfire.bat")
  )
  foreach ($p in $paths) {
    if (Test-Path $p) { return $p }
  }
  return $null
}

function Ensure-GitSafeFlutter {
  $flutterRoot = "C:/flutter"
  if (-not (Test-Path "C:\flutter\.git")) { return }
  $check = git -C $flutterRoot rev-parse --is-inside-work-tree 2>$null
  if ($LASTEXITCODE -ne 0) {
    Write-Host ">> Ajustando Git safe.directory para C:\flutter (donos de pasta diferentes)..."
    git config --global --add safe.directory $flutterRoot 2>$null
  }
}

$nodeDir = Get-NodeDir
if ($nodeDir) {
  $env:Path = "$nodeDir;$env:Path"
}
if (Test-Path "C:\flutter\bin") {
  $env:Path = "C:\flutter\bin;$env:Path"
}

$firebaseCmd = Join-Path $env:LOCALAPPDATA "firebase-cli\node_modules\.bin\firebase.cmd"

if (-not (Test-Path $firebaseCmd)) {
  if (-not $nodeDir) {
    throw "Node.js não encontrado. Instale Node LTS ou Visual Studio com Node."
  }
  Write-Host "Instalando firebase-tools em $env:LOCALAPPDATA\firebase-cli ..."
  New-Item -ItemType Directory -Force -Path (Join-Path $env:LOCALAPPDATA "firebase-cli") | Out-Null
  & (Join-Path $nodeDir "npm.cmd") install firebase-tools --prefix (Join-Path $env:LOCALAPPDATA "firebase-cli")
}

$flutterfireCmd = Get-FlutterfireCmd
if (-not $flutterfireCmd) {
  Write-Host "Instalando flutterfire_cli..."
  Ensure-GitSafeFlutter
  $dart = Get-DartExe
  & $dart pub global activate flutterfire_cli
  $env:Path = "$(Split-Path $dart -Parent);$(Join-Path $env:LOCALAPPDATA 'Pub\Cache\bin');$env:Path"
  $flutterfireCmd = Get-FlutterfireCmd
  if (-not $flutterfireCmd) {
    throw "flutterfire não encontrado após activate. Adicione ao PATH: $env:LOCALAPPDATA\Pub\Cache\bin"
  }
}

Write-Host ">> Verificando login Firebase..."
& $firebaseCmd projects:list 2>$null
if ($LASTEXITCODE -ne 0) {
  Write-Host ""
  Write-Host "Faça login no Google (abre o navegador):"
  & $firebaseCmd login
}

Write-Host ">> flutterfire configure (projeto: $ProjectId)"
Write-Host ">> Usando: $flutterfireCmd"
& $flutterfireCmd configure `
  --project=$ProjectId `
  --yes `
  --platforms=android,web `
  --android-package-name=com.tulimovie.tulimovie `
  -o lib/core/config/firebase_options.dart `
  --android-out=android/app/google-services.json `
  --overwrite-firebase-options

Write-Host ""
Write-Host "Próximo passo no Console Firebase:"
Write-Host "  1. Authentication -> E-mail/Senha (ativar)"
Write-Host "  2. Firestore -> Criar banco de dados"
Write-Host ""
Write-Host "Rodar app:"
Write-Host "  flutter run -d chrome --dart-define=TMDB_API_KEY=SUA_CHAVE"
