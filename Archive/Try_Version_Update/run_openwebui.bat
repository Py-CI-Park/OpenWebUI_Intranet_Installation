@echo off
setlocal EnableDelayedExpansion

echo === Open WebUI 실행 스크립트 ===

:: 작업 디렉토리 설정
set "WORK_DIR=C:\OpenWebUI"

:: 1. 설치 확인
echo 1. 설치 상태 확인 중...
if not exist "%WORK_DIR%\venv" (
    echo ERROR: Open WebUI가 설치되지 않았습니다.
    echo 먼저 install_openwebui_offline.bat를 실행하세요.
    pause
    exit /b 1
)

:: 2. 가상 환경 활성화
echo 2. 가상 환경 활성화 중...
call "%WORK_DIR%\venv\Scripts\activate"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: 가상 환경을 활성화할 수 없습니다.
    echo 설치에 문제가 있을 수 있습니다. install_openwebui_offline.bat를 다시 실행해보세요.
    pause
    exit /b 1
)

:: 3. Open WebUI 설치 확인
echo 3. Open WebUI 설치 확인 중...
pip show open-webui >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Open WebUI가 제대로 설치되지 않았습니다.
    echo install_openwebui_offline.bat를 다시 실행해보세요.
    pause
    exit /b 1
)

:: 4. 실행 안내
echo.
echo === Open WebUI 실행 중 ===
echo.
echo 브라우저에서 다음 주소로 접속하세요:
echo http://localhost:8080
echo.
echo 종료하려면 이 창에서 Ctrl+C를 누르세요.
echo.
echo 실행 중...

:: 5. Open WebUI 실행
open-webui serve --host 0.0.0.0 --port 8080
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Open WebUI 실행 실패
    echo 오류가 지속되면 설치 상태를 확인하세요.
    pause
    exit /b 1
)

echo.
echo === Open WebUI가 종료되었습니다 ===
pause