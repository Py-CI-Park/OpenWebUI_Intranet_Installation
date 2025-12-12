@echo off
setlocal EnableDelayedExpansion

:: ================================================================
::  install_openwebui_pip_style_v5.bat
:: ================================================================

if "%~1"=="" (
  set "WORK_DIR=%~dp0OpenWebUI"
) else (
  set "WORK_DIR=%~1"
)
set "FINAL_ZIP=%WORK_DIR%\\open-webui-pip-style.zip"
set "PACKAGE_DIR=%WORK_DIR%\\packages"
pushd "%WORK_DIR%"

if not exist "%FINAL_ZIP%" (
  echo [ERROR] zip missing
  pause
  goto :END
)

echo [1] extract zip...
powershell -NoLogo -NoProfile -Command ^
  "Expand-Archive -Path '%FINAL_ZIP%' -DestinationPath '.' -Force"
if %ERRORLEVEL% NEQ 0 (
  echo extract error
  pause
  goto :END
)

echo [2] create venv...
python -m venv "%WORK_DIR%\\venv"
if %ERRORLEVEL% NEQ 0 goto :ERR

call "%WORK_DIR%\\venv\\Scripts\\activate"

echo [3] install wheel/setuptools...
pip install --no-index --find-links="%PACKAGE_DIR%" wheel setuptools
if %ERRORLEVEL% NEQ 0 goto :ERR

echo [4] install open-webui wheel...
for %%V in (0.6.4 0.5.3) do (
  pip install --no-index --find-links="%PACKAGE_DIR%" open-webui==%%V
  if !ERRORLEVEL! EQU 0 goto :OWU_OK
)
pip install --no-index --find-links="%PACKAGE_DIR%" open-webui
if %ERRORLEVEL% NEQ 0 goto :ERR

:OWU_OK
echo install success
goto :END

:ERR
echo install failed
pause
:END
popd
exit /b 0
