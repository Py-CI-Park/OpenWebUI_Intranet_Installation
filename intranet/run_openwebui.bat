@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM =============================================
REM Open Web UI Runner (ASCII-only)
REM =============================================

REM Optional args: 1) install_dir  2) port
set "INSTALL_PATH=%~1"
set "PORT=%~2"

if "%INSTALL_PATH%"=="" set "INSTALL_PATH=C:\OpenWebUI"
if "%PORT%"=="" if not "%OPENWEBUI_PORT%"=="" set "PORT=%OPENWEBUI_PORT%"
if "%PORT%"=="" set "PORT=8080"

set "VENV_PATH=%INSTALL_PATH%\venv"
set "START_BAT=%INSTALL_PATH%\start_openwebui.bat"

REM If not found at C:\OpenWebUI, try LocalAppData fallback
if not exist "%VENV_PATH%\Scripts\activate.bat" (
  set "INSTALL_PATH=%LocalAppData%\OpenWebUI"
  set "VENV_PATH=%INSTALL_PATH%\venv"
  set "START_BAT=%INSTALL_PATH%\start_openwebui.bat"
)

if not exist "%VENV_PATH%\Scripts\activate.bat" (
  echo [ERROR] Open Web UI not installed.
  echo         Expected venv at: %VENV_PATH%
  echo         Run intranet\install_openwebui.bat first.
  goto :_abort
)

echo [INFO] Using install dir: %INSTALL_PATH%
echo [INFO] Activating venv...
call "%VENV_PATH%\Scripts\activate.bat"
if errorlevel 1 (
  echo [ERROR] Failed to activate virtual environment.
  goto :_abort
)

REM If a start script exists, prefer it (uses its own host/port defaults)
if exist "%START_BAT%" (
  echo [INFO] Launching via: %START_BAT%
  call "%START_BAT%"
  if errorlevel 1 goto :_abort
  goto :_success
)

REM Direct run fallback
echo [INFO] Starting Open Web UI on http://0.0.0.0:%PORT% ...
open-webui serve --host 0.0.0.0 --port %PORT%
if errorlevel 1 goto :_abort
goto :_success

:_success
endlocal
exit /b 0

:_abort
echo.
echo [INFO] Run aborted due to an error. Press any key to close...
pause >nul
endlocal
exit /b 1
