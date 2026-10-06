@echo off
cd /d "%~dp0.."
set "DEFINES=dart_defines.json"
if not exist "%DEFINES%" (
  echo.
  echo Arquivo %DEFINES% nao encontrado.
  echo 1. Copie dart_defines.example.json para dart_defines.json
  echo 2. Cole sua chave TMDB v3 em TMDB_API_KEY
  echo    Obtenha em: https://www.themoviedb.org/settings/api
  echo.
  exit /b 1
)
set "PATH=C:\flutter\bin;%PATH%"
flutter run -d chrome --dart-define-from-file=%DEFINES%
