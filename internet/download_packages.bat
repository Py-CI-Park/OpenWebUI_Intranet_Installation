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
echo    ██████╗  ██████╗ ██╗    ██╗███╗   ██╗██╗      ██████╗  █████╗ ██████╗ ███████╗██████╗
echo    ██╔══██╗██╔═══██╗██║    ██║████╗  ██║██║     ██╔═══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗
echo    ██║  ██║██║   ██║██║ █╗ ██║██╔██╗ ██║██║     ██║   ██║███████║██║  ██║█████╗  ██████╔╝
echo    ██║  ██║██║   ██║██║███╗██║██║╚██╗██║██║     ██║   ██║██╔══██║██║  ██║██╔══╝  ██╔══██╗
echo    ██████╔╝╚██████╔╝╚███╔███╔╝██║ ╚████║███████╗╚██████╔╝██║  ██║██████╔╝███████╗██║  ██║
echo    ╚═════╝  ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝
echo.
echo    ═══════════════════════════════════════════════════════════════════════════════════════
echo                        Open Web UI 인터넷망 패키지 다운로더 v1.0
echo                          for Intranet Installation Package Creator
echo    ═══════════════════════════════════════════════════════════════════════════════════════
echo.

REM 관리자 권한 확인
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [INFO] 관리자 권한으로 실행 중입니다.
) else (
    echo [WARNING] 관리자 권한이 아닙니다. 일부 기능이 제한될 수 있습니다.
)

REM 현재 디렉토리 확인
echo [INFO] 현재 작업 디렉토리: %CD%
echo.

REM Python 설치 확인
echo [STEP 1/5] Python 설치 확인 중...
python --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Python이 설치되지 않았습니다.
    echo [ERROR] Python 3.8 이상을 설치한 후 다시 실행해주세요.
    echo [ERROR] 다운로드: https://www.python.org/downloads/
    pause
    exit /b 1
)

for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo [INFO] Python 버전: %PYTHON_VERSION%

REM pip 업그레이드
echo.
echo [STEP 2/5] pip 업그레이드 중...
python -m pip install --upgrade pip
if %errorLevel% neq 0 (
    echo [ERROR] pip 업그레이드에 실패했습니다.
    pause
    exit /b 1
)

REM 다운로드 디렉토리 생성
echo.
echo [STEP 3/5] 다운로드 디렉토리 준비 중...
set DOWNLOAD_DIR=%CD%\openwebui_packages
if exist "%DOWNLOAD_DIR%" (
    echo [INFO] 기존 다운로드 디렉토리를 정리합니다.
    rmdir /s /q "%DOWNLOAD_DIR%"
)
mkdir "%DOWNLOAD_DIR%"
echo [INFO] 다운로드 디렉토리: %DOWNLOAD_DIR%

REM Open Web UI 및 의존성 패키지 다운로드
echo.
echo [STEP 4/5] Open Web UI 패키지 다운로드 중...
echo [INFO] 이 과정은 네트워크 상태에 따라 시간이 소요될 수 있습니다.
echo.

cd /d "%DOWNLOAD_DIR%"
if %errorLevel% neq 0 (
    echo [ERROR] Open Web UI 다운로드에 실패했습니다.
    cd /d "%~dp0"
    pause
    exit /b 1
)

echo [INFO] 의존성 패키지들을 다운로드합니다...
python -m pip download open-webui --dest .
if %errorLevel% neq 0 (
    echo [ERROR] 의존성 패키지 다운로드에 실패했습니다.
    cd /d "%~dp0"
    pause
    exit /b 1
)

REM 패키지 압축
echo.
echo [STEP 5/5] 패키지 압축 중...
echo [INFO] 오프라인 설치 안정화를 위한 pip/setuptools/wheel 추가 다운로드..
python -m pip download pip setuptools wheel --dest .
if %errorLevel% neq 0 (
    echo [WARNING] pip/setuptools/wheel 다운로드에 실패했습니다. 계속 진행합니다.
)
cd /d "%~dp0"

set ARCHIVE_NAME=openwebui_intranet_package_%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set ARCHIVE_NAME=%ARCHIVE_NAME: =0%

REM PowerShell을 사용하여 압축
echo [INFO] PowerShell을 사용하여 압축합니다...
powershell -Command "Compress-Archive -Path '%DOWNLOAD_DIR%\*' -DestinationPath '%ARCHIVE_NAME%.zip' -Force"
if %errorLevel% neq 0 (
    echo [ERROR] 압축에 실패했습니다.
    pause
    exit /b 1
)

REM 완료 메시지
echo.
echo ═══════════════════════════════════════════════════════════════════════════════════════
echo                                   다운로드 완료!
echo ═══════════════════════════════════════════════════════════════════════════════════════
echo.
echo [SUCCESS] 모든 패키지가 성공적으로 다운로드되었습니다.
echo [INFO] 압축 파일: %ARCHIVE_NAME%.zip
echo [INFO] 원본 폴더: %DOWNLOAD_DIR%
echo.
echo [NEXT STEP] 
echo 1. %ARCHIVE_NAME%.zip 파일을 폐쇄망으로 이동하세요.
echo 2. 폐쇄망에서 압축을 해제하세요.
echo 3. 폐쇄망 설치 배치 파일을 실행하세요.
echo.
echo 압축 파일 크기:
for %%A in ("%ARCHIVE_NAME%.zip") do echo [INFO] 파일 크기: %%~zA bytes

echo.
echo 다운로드된 패키지 목록:
dir "%DOWNLOAD_DIR%" /b

echo.
echo [INFO] 작업이 완료되었습니다. 아무 키나 누르면 종료됩니다.
pause >nul
