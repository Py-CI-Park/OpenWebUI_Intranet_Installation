@echo off
setlocal EnableDelayedExpansion

echo === 폐쇄망에서 Open Web UI 설치 스크립트 ===

:: 작업 디렉토리 설정
set "WORK_DIR=C:\OpenWebUI"
set "PACKAGE_DIR=%WORK_DIR%\packages"

:: 1. 작업 디렉토리 생성
echo 1. 작업 디렉토리 생성 중...
if not exist "%WORK_DIR%" mkdir "%WORK_DIR%"
cd /d "%WORK_DIR%"

:: 2. packages 폴더 존재 확인
echo 2. packages 폴더 존재 확인 중...
if not exist "%PACKAGE_DIR%" (
    echo ERROR: packages 폴더가 없습니다.
    echo 인터넷망에서 다운로드한 openwebui_offline_package.zip을 압축 해제하여
    echo packages 폴더를 이 위치(%WORK_DIR%)에 복사하세요.
    echo.
    echo 현재 디렉토리: %WORK_DIR%
    echo 필요한 폴더: %PACKAGE_DIR%
    pause
    exit /b 1
)

:: 3. packages 폴더 내용 확인
echo 3. packages 폴더 내용 확인 중...
dir "%PACKAGE_DIR%\*.whl" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: packages 폴더에 .whl 파일이 없습니다.
    echo 올바른 packages 폴더인지 확인하세요.
    pause
    exit /b 1
)

:: 4. Python 설치 확인
echo 4. Python 설치 확인 중...
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Python이 설치되지 않았거나 PATH에 없습니다.
    echo Python을 설치한 후 다시 시도하세요.
    pause
    exit /b 1
)

:: 5. Python 가상 환경 생성
echo 5. Python 가상 환경 생성 중...
python -m venv "%WORK_DIR%\venv"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: 가상 환경 생성 실패
    pause
    exit /b 1
)

:: 6. 가상 환경 활성화
echo 6. 가상 환경 활성화 중...
call "%WORK_DIR%\venv\Scripts\activate"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: 가상 환경 활성화 실패
    pause
    exit /b 1
)

:: 7. 기본 패키지 설치
echo 7. 기본 패키지 설치 중...
pip install --no-index --find-links="%PACKAGE_DIR%" wheel setuptools
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: 기본 패키지 설치 실패
    pause
    exit /b 1
)

:: 8. Open WebUI 및 의존성 설치
echo 8. Open WebUI 및 의존성 설치 중...
pip install --no-index --find-links="%PACKAGE_DIR%" open-webui
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Open WebUI 설치 실패
    pause
    exit /b 1
)

:: 9. 설치 확인
echo 9. 설치 확인 중...
pip show open-webui >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Open WebUI가 제대로 설치되지 않았습니다.
    pause
    exit /b 1
)

echo.
echo === 설치 완료! ===
echo.
echo Open WebUI가 성공적으로 설치되었습니다.
echo 실행하려면 run_openwebui.bat 파일을 실행하세요.
echo.
echo 설치 위치: %WORK_DIR%
echo 가상 환경: %WORK_DIR%\venv
echo.
pause