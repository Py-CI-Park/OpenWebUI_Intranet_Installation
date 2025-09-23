@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM =============================================================
REM Open Web UI Offline Installer (ASCII-only, offline-safe)
REM =============================================================

echo.
echo [Open Web UI] Offline installation starting...

REM ---------------------------
REM 0) Locate packages (folder or zip)
REM ---------------------------
set "SCRIPT_DIR=%~dp0"
set "PACKAGES_DIR="
set "PACKAGES_ZIP="

REM If argument provided and is a folder with packages, use it
if not "%~1"=="" (
  if exist "%~1\*.whl" (
    set "PACKAGES_DIR=%~1"
  ) else if exist "%~1\*.tar.gz" (
    set "PACKAGES_DIR=%~1"
  ) else (
    if exist "%~1" (
      REM If it's a zip archive
      for %%Z in ("%~1") do (
        set "_ext=%%~xZ"
        if /I "!_ext!"==".zip" set "PACKAGES_ZIP=%%~fZ"
      )
    )
  )
)

REM If not set, check current directory (flat wheels)
if not defined PACKAGES_DIR if exist "%CD%\*.whl" set "PACKAGES_DIR=%CD%"

REM If not set, check a local 'openwebui_packages' folder next to the script
if not defined PACKAGES_DIR if exist "%SCRIPT_DIR%openwebui_packages\*.whl" set "PACKAGES_DIR=%SCRIPT_DIR%openwebui_packages"
if not defined PACKAGES_DIR if exist "%SCRIPT_DIR%openwebui_packages\*.tar.gz" set "PACKAGES_DIR=%SCRIPT_DIR%openwebui_packages"

REM If not set, check a local 'openwebui_packages' folder under current directory
if not defined PACKAGES_DIR if exist "%CD%\openwebui_packages\*.whl" set "PACKAGES_DIR=%CD%\openwebui_packages"
if not defined PACKAGES_DIR if exist "%CD%\openwebui_packages\*.tar.gz" set "PACKAGES_DIR=%CD%\openwebui_packages"

REM If not set, check parent of script directory (common layout: ..\openwebui_packages)
if not defined PACKAGES_DIR if exist "%SCRIPT_DIR%..\openwebui_packages\*.whl" set "PACKAGES_DIR=%SCRIPT_DIR%..\openwebui_packages"
if not defined PACKAGES_DIR if exist "%SCRIPT_DIR%..\openwebui_packages\*.tar.gz" set "PACKAGES_DIR=%SCRIPT_DIR%..\openwebui_packages"

REM If not set, check parent of current directory
if not defined PACKAGES_DIR if exist "%CD%\..\openwebui_packages\*.whl" set "PACKAGES_DIR=%CD%\..\openwebui_packages"
if not defined PACKAGES_DIR if exist "%CD%\..\openwebui_packages\*.tar.gz" set "PACKAGES_DIR=%CD%\..\openwebui_packages"

REM If not set, check sibling internet/openwebui_packages
if not defined PACKAGES_DIR if exist "%SCRIPT_DIR%..\internet\openwebui_packages\*.whl" set "PACKAGES_DIR=%SCRIPT_DIR%..\internet\openwebui_packages"

REM If not set, try to find a zip next to the repo's internet folder
if not defined PACKAGES_ZIP (
  REM Look under repo's internet folder
  for /f "delims=" %%Z in ('dir /b /s /a:-d "%SCRIPT_DIR%..\internet\openwebui_intranet_package_*.zip" 2^>nul') do (
    set "PACKAGES_ZIP=%%Z"
    goto :_zip_found
  )
  REM Look in script directory
  for /f "delims=" %%Z in ('dir /b /s /a:-d "%SCRIPT_DIR%openwebui_intranet_package_*.zip" 2^>nul') do (
    set "PACKAGES_ZIP=%%Z"
    goto :_zip_found
  )
  REM Look in current working directory
  for /f "delims=" %%Z in ('dir /b /s /a:-d "%CD%\openwebui_intranet_package_*.zip" 2^>nul') do (
    set "PACKAGES_ZIP=%%Z"
    goto :_zip_found
  )
  REM Fallback: pick any .zip in internet folder (most recent)
  for /f "delims=" %%Z in ('dir /b /s /a:-d /o:-d "%SCRIPT_DIR%..\internet\*.zip" 2^>nul') do (
    set "PACKAGES_ZIP=%%Z"
    goto :_zip_found
  )
  REM Fallback: pick any .zip near script folder (most recent)
  for /f "delims=" %%Z in ('dir /b /s /a:-d /o:-d "%SCRIPT_DIR%*.zip" 2^>nul') do (
    set "PACKAGES_ZIP=%%Z"
    goto :_zip_found
  )
  REM Fallback: pick any .zip under current directory (most recent)
  for /f "delims=" %%Z in ('dir /b /s /a:-d /o:-d "%CD%\*.zip" 2^>nul') do (
    set "PACKAGES_ZIP=%%Z"
    goto :_zip_found
  )
)
:_zip_found

REM If we have a zip but no folder, extract it
if not defined PACKAGES_DIR if defined PACKAGES_ZIP (
  set "TMP_PACK_DIR=%TEMP%\openwebui_packages_%RANDOM%%RANDOM%"
  echo [INFO] Extracting packages: "%PACKAGES_ZIP%"
  powershell -NoProfile -Command "Expand-Archive -Path '%PACKAGES_ZIP%' -DestinationPath '%TMP_PACK_DIR%' -Force" 1>nul 2>nul
  if errorlevel 1 (
    echo [ERROR] Failed to extract packages zip. Please extract manually.
    goto :_abort
  )
  set "PACKAGES_DIR=%TMP_PACK_DIR%"
)

if not defined PACKAGES_DIR (
  echo [ERROR] Packages not found.
  echo         Provide path to extracted packages folder (with .whl files),
  echo         or place a zip named openwebui_intranet_package_*.zip under the internet/ folder,
  echo         or pass the full path to the zip or folder as an argument.
  echo         Usage: install_openwebui.bat "C:\path\to\packages"
  echo         Searched paths:
  echo           - %SCRIPT_DIR%..\internet\openwebui_intranet_package_*.zip
  echo           - %SCRIPT_DIR%openwebui_intranet_package_*.zip
  echo           - %CD%\openwebui_intranet_package_*.zip
  echo           - %SCRIPT_DIR%openwebui_packages\
  echo           - %CD%\openwebui_packages\
  echo           - %SCRIPT_DIR%..\openwebui_packages\
  echo           - %CD%\..\openwebui_packages\
  goto :_abort
)

echo [INFO] Packages directory: %PACKAGES_DIR%

REM ---------------------------
REM 1) Check Python availability
REM ---------------------------
python -c "import sys;print(sys.version)" >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Python not found. Install Python 3.x and try again.
  goto :_abort
)

for /f %%v in ('python -c "import sys;print(str(sys.version_info.major)+str(sys.version_info.minor))"') do set "PY_DETECTED=%%v"
for /f %%b in ('python -c "import struct;print(struct.calcsize(\"P\")*8)"') do set "PY_BITS=%%b"
echo [INFO] Python detected: %PY_DETECTED% (%PY_BITS%-bit)

if not "%PY_BITS%"=="64" (
  echo [ERROR] 64-bit Python is required (packages are win_amd64).
  goto :_abort
)

REM Infer required cp tag from wheel names (if any compiled wheels exist)
set "REQ_TAG="
for %%t in (cp312 cp311 cp310 cp39 cp38) do (
  dir /b "%PACKAGES_DIR%\*%%t*.whl" >nul 2>&1 && (
    set "REQ_TAG=%%t"
    goto :_tag_found
  )
)
:_tag_found
if defined REQ_TAG (
  for /f "tokens=2 delims=p" %%x in ("%REQ_TAG%") do set "REQ_PY=%%x"
  if not "%PY_DETECTED%"=="%REQ_PY%" (
    echo [ERROR] Python %REQ_PY% required by wheels (found %PY_DETECTED%).
    echo         Install matching Python version and retry.
    goto :_abort
  )
  echo [INFO] Wheels require CPython tag: %REQ_TAG%
) else (
  echo [INFO] No CPython-specific wheels detected; proceeding.
)

REM ---------------------------
REM 2) Choose install directory (try C:\OpenWebUI, fallback to LocalAppData)
REM ---------------------------
set "INSTALL_PATH=C:\OpenWebUI"
mkdir "%INSTALL_PATH%\_perm_test" >nul 2>&1
if errorlevel 1 (
  set "INSTALL_PATH=%LocalAppData%\OpenWebUI"
)
if exist "%INSTALL_PATH%\_perm_test" rmdir "%INSTALL_PATH%\_perm_test" >nul 2>&1

set "VENV_PATH=%INSTALL_PATH%\venv"
echo [INFO] Install dir: %INSTALL_PATH%

if exist "%INSTALL_PATH%" (
  echo [INFO] Reusing existing directory.
) else (
  mkdir "%INSTALL_PATH%" >nul 2>&1
  if errorlevel 1 (
    echo [ERROR] Cannot create install dir: %INSTALL_PATH%
    goto :_abort
  )
)

REM ---------------------------
REM 3) Create virtual environment
REM ---------------------------
if not exist "%VENV_PATH%\Scripts\activate.bat" (
  echo [STEP] Creating Python venv...
  python -m venv "%VENV_PATH%"
  if errorlevel 1 (
    echo [ERROR] Failed to create virtual environment.
    goto :_abort
  )
) else (
  echo [INFO] Using existing venv.
)

call "%VENV_PATH%\Scripts\activate.bat"
if errorlevel 1 (
  echo [ERROR] Failed to activate venv.
  goto :_abort
)

REM ---------------------------
REM 4) Install/upgrade build tools from local wheels
REM ---------------------------
echo [STEP] Installing pip/setuptools/wheel (offline)...
python -m pip install --no-index --find-links "%PACKAGES_DIR%" pip setuptools wheel >nul
if errorlevel 1 (
  echo [WARN] Could not install/upgrade pip tools from local cache.
)

REM ---------------------------
REM 5) Install Open Web UI (offline)
REM ---------------------------
echo [STEP] Installing open-webui (offline)... This may take a while.
python -m pip install --no-index --find-links "%PACKAGES_DIR%" open-webui
if errorlevel 1 (
  echo [ERROR] Failed to install open-webui from local packages.
  goto :_abort
)

REM Quick import check
python -c "import sys; import importlib; importlib.import_module('open_webui'); print('OK')" >nul 2>&1
if errorlevel 1 (
  echo [WARN] Installation verification failed, but install may still be usable.
)

REM ---------------------------
REM 6) Write start script
REM ---------------------------
set "START_BAT=%INSTALL_PATH%\start_openwebui.bat"
(
  echo @echo off
  echo setlocal EnableExtensions
  echo cd /d "%%~dp0"
  echo call "venv\Scripts\activate.bat"
  echo set "HOST=0.0.0.0"
  echo set "PORT=8080"
  echo echo Starting Open Web UI on http://%%HOST%%:%%PORT%% ...
  echo open-webui serve --host %%HOST%% --port %%PORT%%
) > "%START_BAT%"
if errorlevel 1 (
  echo [ERROR] Failed to create start script: %START_BAT%
  goto :_abort
)

REM ---------------------------
REM 7) Try adding firewall rule (optional)
REM ---------------------------
where netsh >nul 2>&1 && (
  netsh advfirewall firewall add rule name="Open Web UI 8080" dir=in action=allow protocol=TCP localport=8080 >nul 2>&1
)

echo.
echo =============================================
echo  Open Web UI offline installation complete
echo =============================================
echo Install dir : %INSTALL_PATH%
echo Venv        : %VENV_PATH%
echo Start script: %START_BAT%
echo URL         : http://localhost:8080
echo.
echo To run now:
echo   "%START_BAT%"
echo.
endlocal
exit /b 0

:_abort
echo.
echo [INFO] Installation aborted. Press any key to close...
pause >nul
endlocal
exit /b 1
