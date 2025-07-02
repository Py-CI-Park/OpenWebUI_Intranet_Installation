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
echo    ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗
echo    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗
echo    ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     █████╗  ██████╔╝
echo    ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗
echo    ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║
echo    ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
echo.
echo    ═══════════════════════════════════════════════════════════════════════════════════════
echo                        Open Web UI 폐쇄망 설치 관리자 v1.0
echo                              Intranet Installation Manager
echo    ═══════════════════════════════════════════════════════════════════════════════════════
echo.

REM 관리자 권한 확인
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [INFO] 관리자 권한으로 실행 중입니다.
) else (
    echo [WARNING] 관리자 권한이 아닙니다. 설치 경로에 대한 권한을 확인해주세요.
)

REM 현재 디렉토리 확인
echo [INFO] 현재 작업 디렉토리: %CD%
echo.

REM 설치 경로 설정
set INSTALL_PATH=C:\OpenWebUI
set VENV_PATH=%INSTALL_PATH%\venv
set PACKAGES_PATH=%CD%

echo [INFO] 설치 경로: %INSTALL_PATH%
echo [INFO] 가상환경 경로: %VENV_PATH%
echo [INFO] 패키지 경로: %PACKAGES_PATH%
echo.

REM Python 설치 확인
echo [STEP 1/7] Python 설치 확인 중...
python --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Python이 설치되지 않았습니다.
    echo [ERROR] Python 3.8 이상이 필요합니다.
    pause
    exit /b 1
)

for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo [INFO] Python 버전: %PYTHON_VERSION%

REM 패키지 파일 확인
echo.
echo [STEP 2/7] 패키지 파일 확인 중...
if not exist "*.whl" (
    if not exist "*.tar.gz" (
        echo [ERROR] 패키지 파일을 찾을 수 없습니다.
        echo [ERROR] 다운로드한 패키지 파일들이 현재 디렉토리에 있는지 확인해주세요.
        echo [ERROR] 필요한 파일: *.whl, *.tar.gz
        pause
        exit /b 1
    )
)
echo [INFO] 패키지 파일이 확인되었습니다.

REM 설치 디렉토리 생성
echo.
echo [STEP 3/7] 설치 디렉토리 준비 중...
if exist "%INSTALL_PATH%" (
    echo [WARNING] 기존 설치 디렉토리가 존재합니다.
    echo [WARNING] 기존 설치를 제거하고 새로 설치하시겠습니까? (Y/N)
    set /p CONFIRM=선택: 
    if /i "%CONFIRM%"=="Y" (
        echo [INFO] 기존 설치를 제거합니다...
        rmdir /s /q "%INSTALL_PATH%"
    ) else (
        echo [INFO] 설치를 취소합니다.
        pause
        exit /b 0
    )
)

mkdir "%INSTALL_PATH%" 2>nul
if %errorLevel% neq 0 (
    echo [ERROR] 설치 디렉토리를 생성할 수 없습니다.
    echo [ERROR] 관리자 권한으로 실행하거나 경로를 확인해주세요.
    pause
    exit /b 1
)
echo [INFO] 설치 디렉토리가 생성되었습니다: %INSTALL_PATH%

REM 가상환경 생성
echo.
echo [STEP 4/7] Python 가상환경 생성 중...
python -m venv "%VENV_PATH%"
if %errorLevel% neq 0 (
    echo [ERROR] 가상환경 생성에 실패했습니다.
    pause
    exit /b 1
)
echo [INFO] 가상환경이 생성되었습니다: %VENV_PATH%

REM 가상환경 활성화
echo.
echo [STEP 5/7] 가상환경 활성화 중...
call "%VENV_PATH%\Scripts\activate.bat"
if %errorLevel% neq 0 (
    echo [ERROR] 가상환경 활성화에 실패했습니다.
    pause
    exit /b 1
)
echo [INFO] 가상환경이 활성화되었습니다.

REM pip 업그레이드
echo.
echo [STEP 6/7] pip 업그레이드 중...
python -m pip install --upgrade pip --no-index --find-links "%PACKAGES_PATH%"
if %errorLevel% neq 0 (
    echo [WARNING] pip 업그레이드에 실패했습니다. 계속 진행합니다.
)

REM Open Web UI 설치
echo.
echo [STEP 7/7] Open Web UI 설치 중...
echo [INFO] 이 과정은 시간이 소요될 수 있습니다...
python -m pip install --no-index --find-links "%PACKAGES_PATH%" open-webui
if %errorLevel% neq 0 (
    echo [ERROR] Open Web UI 설치에 실패했습니다.
    echo [ERROR] 패키지 파일들을 확인해주세요.
    pause
    exit /b 1
)

REM 설치 확인
echo.
echo [INFO] 설치 확인 중...
python -c "import open_webui; print('Open Web UI 설치 완료!')" 2>nul
if %errorLevel% neq 0 (
    echo [WARNING] 설치 확인에 실패했습니다. 하지만 설치는 완료되었을 수 있습니다.
)

REM 실행 스크립트 생성
echo [INFO] 실행 스크립트를 생성합니다...
echo @echo off > "%INSTALL_PATH%\start_openwebui.bat"
echo cd /d "%INSTALL_PATH%" >> "%INSTALL_PATH%\start_openwebui.bat"
echo call venv\Scripts\activate.bat >> "%INSTALL_PATH%\start_openwebui.bat"
echo echo Open Web UI를 시작합니다... >> "%INSTALL_PATH%\start_openwebui.bat"
echo open-webui serve >> "%INSTALL_PATH%\start_openwebui.bat"
echo pause >> "%INSTALL_PATH%\start_openwebui.bat"

REM 바탕화면 바로가기 생성 (선택사항)
echo.
echo [INFO] 바탕화면 바로가기를 생성하시겠습니까? (Y/N)
set /p CREATE_SHORTCUT=선택: 
if /i "%CREATE_SHORTCUT%"=="Y" (
    powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\Open Web UI.lnk'); $Shortcut.TargetPath = '%INSTALL_PATH%\start_openwebui.bat'; $Shortcut.WorkingDirectory = '%INSTALL_PATH%'; $Shortcut.IconLocation = 'shell32.dll,21'; $Shortcut.Save()"
    echo [INFO] 바탕화면 바로가기가 생성되었습니다.
)

REM 완료 메시지
echo.
echo ═══════════════════════════════════════════════════════════════════════════════════════
echo                                   설치 완료!
echo ═══════════════════════════════════════════════════════════════════════════════════════
echo.
echo [SUCCESS] Open Web UI가 성공적으로 설치되었습니다!
echo.
echo [설치 정보]
echo - 설치 경로: %INSTALL_PATH%
echo - 가상환경: %VENV_PATH%
echo - 실행 파일: %INSTALL_PATH%\start_openwebui.bat
echo.
echo [실행 방법]
echo 1. %INSTALL_PATH%\start_openwebui.bat 실행
echo 2. 또는 바탕화면의 'Open Web UI' 바로가기 실행
echo 3. 웹 브라우저에서 http://localhost:8080 접속
echo.
echo [주의사항]
echo - 방화벽에서 포트 8080을 허용해야 할 수 있습니다.
echo - 처음 실행 시 계정 생성이 필요합니다.
echo.
echo [INFO] 설치가 완료되었습니다. 아무 키나 누르면 종료됩니다.
pause >nul