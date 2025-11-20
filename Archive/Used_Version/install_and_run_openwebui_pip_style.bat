@echo off
setlocal EnableDelayedExpansion

echo === 폐쇄망에서 Open WebUI 설치 및 실행 시작 (pip install 방식 모방) ===

:: 작업 디렉토리 설정
set "WORK_DIR=C:\OpenWebUI"
set "FINAL_ZIP=%WORK_DIR%\open-webui-pip-style.zip"
set "OPENWEBUI_DIR=%WORK_DIR%\open-webui-main"
set "PACKAGE_DIR=%WORK_DIR%\packages"
set "BACKEND_DIR=%OPENWEBUI_DIR%\backend"
set "DATA_DIR=%WORK_DIR%\data"

:: 작업 디렉토리 생성
if not exist "%WORK_DIR%" mkdir "%WORK_DIR%"
cd /d "%WORK_DIR%"

echo 1. 단일 ZIP 파일 확인 및 압축 해제 중...
if not exist "%FINAL_ZIP%" (
    echo ERROR: %FINAL_ZIP% 파일이 없습니다. 인터넷망에서 파일을 이동하세요.
    pause
    exit /b 1
)
powershell -command "Expand-Archive -Path '%FINAL_ZIP%' -DestinationPath '.'"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: ZIP 파일 압축 해제 실패
    pause
    exit /b 1
)

echo 2. Python 가상 환경 생성 중...
python -m venv "%WORK_DIR%\venv"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: 가상 환경 생성 실패
    pause
    exit /b 1
)

echo 3. 가상 환경 활성화 및 빌드 도구 설치 중...
call "%WORK_DIR%\venv\Scripts\activate"
pip install --no-index --find-links="%PACKAGE_DIR%" wheel setuptools
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: 빌드 도구 설치 실패
    pause
    exit /b 1
)

echo 4. Open WebUI 및 종속성 설치 중...
pip install --no-index --find-links="%PACKAGE_DIR%" open-webui
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Open WebUI 설치 실패
    pause
    exit /b 1
)

echo 5. DATA_DIR 설정: %DATA_DIR%
if not exist "%DATA_DIR%" mkdir "%DATA_DIR%"
set "OPENWEBUI_DATA_DIR=%DATA_DIR%"

echo 6. Ollama 실행 확인 중...
ollama serve >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo WARN: Ollama가 실행 중이 아닙니다. 별도 CMD에서 'ollama serve'를 실행하세요.
    start cmd /k ollama serve
    timeout /t 5
) else (
    echo Ollama가 이미 실행 중입니다.
)

echo 7. Open WebUI 실행 중...
open-webui serve
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Open WebUI 실행 실패
    pause
    exit /b 1
)

echo === Open WebUI가 실행 중입니다 ===
echo 브라우저에서 http://localhost:8080 에 접속하세요.
pause