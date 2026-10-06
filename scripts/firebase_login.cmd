@echo off
setlocal
set "FB=%LOCALAPPDATA%\firebase-cli\node_modules\.bin\firebase.cmd"
if not exist "%FB%" (
  echo firebase-tools nao encontrado. Rode: scripts\firebase_setup.cmd tulimovie
  exit /b 1
)
echo Abrindo login Google no navegador...
echo Use a conta do projeto TuliMovie no Console.
echo.
call "%FB%" login
if errorlevel 1 exit /b 1
echo.
echo Projetos disponiveis:
call "%FB%" projects:list
endlocal
