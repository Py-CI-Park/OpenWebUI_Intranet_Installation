@echo off
setlocal EnableDelayedExpansion

:: ================================================================
::  Open WebUI 오프라인 패키지 준비 스크립트 (prepare_openwebui_pip_style_v5.bat)
:: ================================================================

if "%~1"=="" (
    set "WORK_DIR=%~dp0OpenWebUI_Prep"
) else (
    set "WORK_DIR=%~1"
)
set "OPENWEBUI_ZIP=open-webui-main.zip"
set "PACKAGE_DIR=%WORK_DIR%\\packages"
set "FINAL_ZIP=open-webui-pip-style.zip"
set "LOG=%WORK_DIR%\\prep.log"

if not exist "%WORK_DIR%" mkdir "%WORK_DIR%"
pushd "%WORK_DIR%"

> "%LOG%" (
    echo ================= PREP START %DATE% %TIME% =================
)

echo [1] pip upgrade... | tee -a "%LOG%"
python -m pip install --upgrade pip >> "%LOG%" 2>&1

echo [2] Download Open WebUI source zip... | tee -a "%LOG%"
curl -L --retry 3 --retry-delay 2 -C - -o "%OPENWEBUI_ZIP%" ^
  "https://github.com/open-webui/open-webui/archive/refs/heads/main.zip" >> "%LOG%" 2>&1
if %ERRORLEVEL% NEQ 0 goto :ERR

echo [3] Prepare packages dir... | tee -a "%LOG%"
if not exist "%PACKAGE_DIR%" mkdir "%PACKAGE_DIR%"

echo [4] Extract requirements.txt... | tee -a "%LOG%"
powershell -NoLogo -NoProfile -Command ^
  "Expand-Archive -Path '%WORK_DIR%\\%OPENWEBUI_ZIP%' -DestinationPath '%WORK_DIR%' -Force" >> "%LOG%" 2>&1

for %%F in ("%WORK_DIR%\\open-webui-main\\backend\\requirements*.txt") do set "REQ_FILE=%%~F"
if not defined REQ_FILE goto :ERR

echo [5] Download dependencies (prefer wheel)... | tee -a "%LOG%"
pip download --dest "%PACKAGE_DIR%" --prefer-binary ^
  -r "!REQ_FILE!" wheel setuptools >> "%LOG%" 2>&1
if %ERRORLEVEL% NEQ 0 goto :ERR

echo [6] Download Open WebUI wheel... | tee -a "%LOG%"
set "VERSIONS=0.6.4 0.5.3"
set "FOUND="
for %%V in (%VERSIONS%) do (
  pip download --dest "%PACKAGE_DIR%" --only-binary=:all: open-webui==%%V >> "%LOG%" 2>&1
  if !ERRORLEVEL! EQU 0 (
     echo    Found wheel for open-webui %%V | tee -a "%LOG%"
     set "FOUND=1"
     goto :WHEEL_DONE
  )
)
:WHEEL_DONE
if not defined FOUND (
  echo    Wheel not found, download source... | tee -a "%LOG%"
  pip download --dest "%PACKAGE_DIR%" open-webui==0.6.4 >> "%LOG%" 2>&1
)

echo [7] Create final zip... | tee -a "%LOG%"
powershell -NoLogo -NoProfile -Command ^
  "Compress-Archive -Path '%OPENWEBUI_ZIP%', 'open-webui-main', 'packages' -DestinationPath '%FINAL_ZIP%' -Force" >> "%LOG%" 2>&1
if %ERRORLEVEL% NEQ 0 goto :ERR

echo SUCCESS! zip at %WORK_DIR%\\%FINAL_ZIP% | tee -a "%LOG%"
goto :END

:ERR
echo [FAIL] see log %LOG%
pause
:END
popd
exit /b %ERRORLEVEL%
