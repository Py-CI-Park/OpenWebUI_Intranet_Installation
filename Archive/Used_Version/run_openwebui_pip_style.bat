@echo off
setlocal EnableDelayedExpansion

echo === Open WebUI 실행 시작 ===

:: 작업 디렉토리 설정 (install 스크립트와 동일하게 맞춰주세요)
set "WORK_DIR=C:\OpenWebUI"
set "OPENWEBUI_DIR=%WORK_DIR%\open-webui-main"

:: 1. 가상 환경 활성화
echo 1. 가상 환경 활성화...
call "%WORK_DIR%\venv\Scripts\activate"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: 가상 환경을 활성화할 수 없습니다.
    pause
    exit /b 1
)

:: 2. Ollama 서버 실행 확인
echo 2. Ollama 서버 실행 확인...
ollama serve >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo WARN: Ollama가 실행 중이 아닙니다. 별도 CMD에서 'ollama serve'를 실행합니다.
    start cmd /k "ollama serve"
    timeout /t 5
) else (
    echo Ollama가 이미 실행 중입니다.
)

:: 3. Open WebUI 실행
echo 3. Open WebUI 실행...
open-webui serve
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Open WebUI 실행 실패
    pause
    exit /b 1
)

echo === Open WebUI가 실행 중입니다 (http://localhost:8080) ===
pause
