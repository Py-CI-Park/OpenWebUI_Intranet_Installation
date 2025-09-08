@echo off
setlocal enabledelayedexpansion
cls

echo(
echo ===============================================
echo  Open Web UI Intranet Package Downloader v1.0
echo  for Intranet Installation Package Creator
echo ===============================================
echo(

REM Admin rights check
net session >nul 2>&1
if %errorlevel%==0 (
    echo [INFO] Running with administrator privileges.
) else (
    echo [WARN] Not running as administrator. Some steps may be limited.
)

REM Current working directory
echo [INFO] Current directory: %CD%
echo(

REM STEP 1: Check Python
echo [STEP 1/5] Checking Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python not found.
    echo [ERROR] Please install Python 3.8+ and retry.
    echo [ERROR] https://www.python.org/downloads/
    pause
    exit /b 1
)
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo [INFO] Python version: %PYTHON_VERSION%

REM STEP 2: Upgrade pip (online)
echo(
echo [STEP 2/5] Upgrading pip...
python -m pip install --upgrade pip
if %errorlevel% neq 0 (
    echo [ERROR] Failed to upgrade pip.
    pause
    exit /b 1
)

REM STEP 3: Prepare download directory
echo(
echo [STEP 3/5] Preparing download directory...
set "DOWNLOAD_DIR=%CD%\openwebui_packages"
if exist "%DOWNLOAD_DIR%" (
    echo [INFO] Removing existing download directory...
    rmdir /s /q "%DOWNLOAD_DIR%"
)
mkdir "%DOWNLOAD_DIR%"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to create directory: %DOWNLOAD_DIR%
    pause
    exit /b 1
)
echo [INFO] Download directory: %DOWNLOAD_DIR%

REM STEP 4: Download packages
echo(
echo [STEP 4/5] Downloading Open Web UI packages...
echo [INFO] This may take a while depending on network.
cd /d "%DOWNLOAD_DIR%"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to change directory to: %DOWNLOAD_DIR%
    cd /d "%~dp0"
    pause
    exit /b 1
)

python -m pip download open-webui --dest .
if %errorlevel% neq 0 (
    echo [ERROR] Failed to download open-webui and dependencies.
    cd /d "%~dp0"
    pause
    exit /b 1
)

echo [INFO] Downloading pip/setuptools/wheel for offline installs...
python -m pip download pip setuptools wheel --dest .
if %errorlevel% neq 0 (
    echo [WARN] Failed to download pip/setuptools/wheel. Continuing.
)

REM STEP 5: Create archive
echo(
echo [STEP 5/5] Creating package archive...
cd /d "%~dp0"
set "ARCHIVE_NAME=openwebui_intranet_package_%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "ARCHIVE_NAME=%ARCHIVE_NAME: =0%"
powershell -Command "Compress-Archive -Path '%DOWNLOAD_DIR%\*' -DestinationPath '%ARCHIVE_NAME%.zip' -Force"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to create archive.
    pause
    exit /b 1
)

echo(
echo ===============================================
echo  Download complete!
echo ===============================================
echo(
echo [SUCCESS] All packages downloaded successfully.
echo [INFO] Archive: %ARCHIVE_NAME%.zip
echo [INFO] Source folder: %DOWNLOAD_DIR%
echo(
echo [NEXT STEPS]
echo 1) Move %ARCHIVE_NAME%.zip to the intranet host.
echo 2) Extract the archive on the intranet host.
echo 3) Run the intranet install scripts.
echo(
for %%A in ("%ARCHIVE_NAME%.zip") do echo [INFO] Archive size: %%~zA bytes
echo(
echo Package list:
dir "%DOWNLOAD_DIR%" /b
echo(
echo [INFO] Done. Press any key to exit.
pause >nul
endlocal
