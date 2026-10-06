@echo off
setlocal
if "%~1"=="" (
  echo Uso: scripts\firebase_setup.cmd PROJECT_ID
  echo Exemplo: scripts\firebase_setup.cmd tulimovie
  exit /b 1
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0firebase_setup.ps1" -ProjectId %~1
exit /b %ERRORLEVEL%
