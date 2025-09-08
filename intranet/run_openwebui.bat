@echo off
chcp 65001 >nul
cls

echo.
echo    ███████╗██████╗ ███████╗███╗   ██╗    ██╗    ██╗███████╗██████╗     ██╗   ██╗██╗
echo    ██╔═══██╗██╔══██╗██╔════╝████╗  ██║    ██║    ██║██╔════╝██╔══██╗    ██║   ██║██║
echo    ██║   ██║██████╔╝█████╗  ██╔██╗ ██║    ██║ █╗ ██║█████╗  ██████╔╝    ██║   ██║██║
echo    ██║   ██║██╔═══╝ ██╔══╝  ██║╚██╗██║    ██║███╗██║██╔══╝  ██╔══██╗    ██║   ██║██║
echo    ╚██████╔╝██║     ███████╗██║ ╚████║    ╚███╔███╔╝███████╗██████╔╝    ╚██████╔╝██║
echo     ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═══╝     ╚══╝╚══╝ ╚══════╝╚═════╝      ╚═════╝ ╚═╝
echo.
echo    ██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗███████╗██████╗
echo    ██╔══██╗██║   ██║████╗  ██║████╗  ██║██╔════╝██╔══██╗
echo    ██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝
echo    ██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗
echo    ██║  ██║╚██████╔╝██║ ╚████║██║ ╚████║███████╗██║  ██║
echo    ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝
echo.
echo    ═══════════════════════════════════════════════════════════════════════════════════════
echo                        Open Web UI 실행 관리자 v1.0
echo                              Quick Start Launcher
echo    ═══════════════════════════════════════════════════════════════════════════════════════
echo.

REM 설치 경로 확인
set INSTALL_PATH=C:\OpenWebUI
set VENV_PATH=%INSTALL_PATH%\venv
set START_SCRIPT=%INSTALL_PATH%\start_openwebui.bat

echo [INFO] 설치 경로 확인 중...
if not exist "%INSTALL_PATH%" (
    echo [ERROR] Open Web UI가 설치되지 않았습니다.
    echo [ERROR] 설치 경로를 찾을 수 없습니다: %INSTALL_PATH%
    echo [ERROR] 먼저 install_openwebui.bat을 실행하여 설치해주세요.
    echo.
    pause
    exit /b 1
)

if not exist "%VENV_PATH%" (
    echo [ERROR] 가상환경을 찾을 수 없습니다.
    echo [ERROR] 가상환경 경로: %VENV_PATH%
    echo [ERROR] 재설치가 필요할 수 있습니다.
    echo.
    pause
    exit /b 1
)

echo [INFO] 설치 경로: %INSTALL_PATH%
echo [INFO] 가상환경: %VENV_PATH%
echo.

REM 실행 스크립트 확인
if exist "%START_SCRIPT%" (
    echo [INFO] 기존 실행 스크립트를 사용합니다.
    echo [INFO] 실행 중: %START_SCRIPT%
    echo.
    call "%START_SCRIPT%"
) else (
    echo [INFO] 실행 스크립트를 새로 생성합니다.
    echo [INFO] 가상환경을 활성화하고 Open Web UI를 시작합니다...
    echo.
    
    cd /d "%INSTALL_PATH%"
    call "%VENV_PATH%\Scripts\activate.bat"
    
    if %errorLevel% neq 0 (
        echo [ERROR] 가상환경 활성화에 실패했습니다.
        echo [ERROR] 설치 상태를 확인해주세요.
        pause
        exit /b 1
    )
    
    echo [INFO] Open Web UI를 시작합니다...
    echo [INFO] 웹 브라우저에서 http://localhost:8080 으로 접속하세요.
    echo [INFO] 종료하려면 Ctrl+C를 누르세요.
    echo.
    
    REM 로그 파일 경로 설정
    set LOG_FILE=%INSTALL_PATH%\logs\openwebui_%date:~0,4%%date:~5,2%%date:~8,2%.log
    if not exist "%INSTALL_PATH%\logs" mkdir "%INSTALL_PATH%\logs"
    
    echo [INFO] 로그 파일: %LOG_FILE%
    echo.
    
    REM Open Web UI 실행
    REM Windows 기본 CMD에는 tee가 없어 PowerShell Tee-Object를 우선 사용하고,
    REM 사용 불가 시 파일 리디렉션으로 대체합니다.
    where powershell >nul 2>&1
    if %errorLevel% EQU 0 (
        powershell -NoProfile -Command "$log=$env:LOG_FILE; & open-webui serve --host 0.0.0.0 --port 8080 2>&1 | Tee-Object -FilePath $log -Append; exit $LASTEXITCODE"
    ) else (
        echo [WARNING] PowerShell을 찾을 수 없습니다. 로그 파일로만 기록합니다.
        open-webui serve --host 0.0.0.0 --port 8080 >> "%LOG_FILE%" 2>&1
    )
    
    if %errorLevel% neq 0 (
        echo.
        echo [ERROR] Open Web UI 실행에 실패했습니다.
        echo [ERROR] 로그 파일을 확인해주세요: %LOG_FILE%
        echo [ERROR] 오류 내용을 확인하여 문제를 해결해주세요.
        echo.
        pause
        exit /b 1
    )
)

echo.
echo [INFO] Open Web UI가 종료되었습니다.
echo [INFO] 아무 키나 누르면 종료됩니다.
pause >nul
