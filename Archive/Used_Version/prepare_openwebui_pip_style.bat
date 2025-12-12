@echo off
setlocal EnableDelayedExpansion

echo === Open WebUI 및 종속성을 준비 시작 (pip install 방식 모방) ===

:: 작업 디렉토리 설정
set "WORK_DIR=C:\OpenWebUI_Prep"
set "OPENWEBUI_ZIP=open-webui-main.zip"
set "PACKAGE_DIR=%WORK_DIR%\packages"
set "FINAL_ZIP=open-webui-pip-style.zip"

:: 작업 디렉토리 생성
if not exist "%WORK_DIR%" mkdir "%WORK_DIR%"
cd /d "%WORK_DIR%"

echo 1. Open WebUI GitHub에서 ZIP 다운로드 중...
curl -L -o "%OPENWEBUI_ZIP%" "https://github.com/open-webui/open-webui/archive/refs/heads/main.zip"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Open WebUI ZIP 다운로드 실패
    pause
    exit /b 1
)

echo 2. ZIP 파일 압축 해제 중...
powershell -command "Expand-Archive -Path '%OPENWEBUI_ZIP%' -DestinationPath '.'"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: ZIP 파일 압축 해제 실패
    pause
    exit /b 1
)

echo 3. Python 패키지 다운로드 준비 중...
if not exist "%PACKAGE_DIR%" mkdir "%PACKAGE_DIR%"
cd /d "%PACKAGE_DIR%"

echo 4. backend/requirements.txt에서 종속성 다운로드 중...
pip download -r "%WORK_DIR%\open-webui-main\backend\requirements.txt"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Python 패키지 다운로드 실패
    pause
    exit /b 1
)

echo 5. 빌드 도구 및 Open WebUI 자체 다운로드 중...
pip download wheel setuptools open-webui
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: 빌드 도구 및 Open WebUI 다운로드 실패
    pause
    exit /b 1
)

echo 6. 모든 파일을 하나의 ZIP으로 압축 중...
cd /d "%WORK_DIR%"
powershell -command "Compress-Archive -Path '%OPENWEBUI_ZIP%', 'open-webui-main', 'packages' -DestinationPath '%FINAL_ZIP%'"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: 최종 ZIP 파일 생성 실패
    pause
    exit /b 1
)

echo === 모든 작업 완료 ===
echo 다음 파일을 폐쇄망 컴퓨터로 이동하세요:
echo - %WORK_DIR%\%FINAL_ZIP%
pause