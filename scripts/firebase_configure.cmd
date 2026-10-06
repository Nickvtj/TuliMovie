@echo off
REM Só roda flutterfire (login Firebase ja feito). Nao precisa de .ps1 no PATH.
setlocal
cd /d "%~dp0.."

set "NODE_DIR=C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Microsoft\VisualStudio\NodeJs"
if exist "C:\Program Files\nodejs\node.exe" set "NODE_DIR=C:\Program Files\nodejs"
set "PATH=%NODE_DIR%;C:\flutter\bin;%LOCALAPPDATA%\Pub\Cache\bin;%LOCALAPPDATA%\firebase-cli\node_modules\.bin;%PATH%"

set "FF=%LOCALAPPDATA%\Pub\Cache\bin\flutterfire.bat"
if not exist "%FF%" (
  echo flutterfire nao encontrado. Instalando...
  git config --global --add safe.directory C:/flutter 2>nul
  dart pub global activate flutterfire_cli
)

if "%~1"=="" set "PROJECT=tulimovie"
if not "%~1"=="" set "PROJECT=%~1"

echo Configurando projeto Firebase: %PROJECT%
call "%FF%" configure --project=%PROJECT% --yes --platforms=android,web --android-package-name=com.tulimovie.tulimovie -o lib/core/config/firebase_options.dart --android-out=android/app/google-services.json --overwrite-firebase-options
exit /b %ERRORLEVEL%
