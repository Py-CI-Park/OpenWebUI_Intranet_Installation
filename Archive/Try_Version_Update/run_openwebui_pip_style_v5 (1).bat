@echo off
setlocal EnableDelayedExpansion
if "%~1"=="" (
  set "WORK_DIR=%~dp0OpenWebUI"
) else (
  set "WORK_DIR=%~1"
)
set "DATA_DIR=%WORK_DIR%\\data"

if not exist "%WORK_DIR%\\venv\\Scripts\\activate" (
  echo [ERROR] run install script first
  pause
  goto :END
)
call "%WORK_DIR%\\venv\\Scripts\\activate"
if not exist "%DATA_DIR%" mkdir "%DATA_DIR%"
set "OPENWEBUI_DATA_DIR=%DATA_DIR%"

tasklist /FI "IMAGENAME eq ollama.exe" | find /I "ollama.exe" >NUL
if %ERRORLEVEL% NEQ 0 (
  start "Ollama" cmd /k ollama serve
  timeout /t 5 >NUL
)

open-webui serve
pause
:END
exit /b 0
