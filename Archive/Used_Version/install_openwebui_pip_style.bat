@echo off
setlocal EnableDelayedExpansion

echo === 폐쇄망에서 Open WebUI 설치 시작 (pip install 방식 모방) ===

:: 작업 디렉토리 설정
set "WORK_DIR=C:\OpenWebUI"
set "FINAL_ZIP=%WORK_DIR%\open-webui-pip-style.zip"
set "OPENWEBUI_DIR=%WORK_DIR%\open-webui-main"
set "PACKAGE_DIR=%OPENWEBUI_DIR%\packages"


:: 1. 작업 디렉토리 생성
if not exist "%WORK_DIR%" mkdir "%WORK_DIR%"
cd /d "%WORK_DIR%"

:: 2. ZIP 파일 확인 및 압축 해제
echo 1. ZIP 파일 확인 및 압축 해제...
if not exist "%FINAL_ZIP%" (
    echo ERROR: %FINAL_ZIP% 파일이 없습니다. 인터넷망에서 파일을 이동하세요.
    pause
    exit /b 1
)
powershell -command "Expand-Archive -Path '%FINAL_ZIP%' -DestinationPath '%OPENWEBUI_DIR%'"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: ZIP 파일 압축 해제 실패
    pause
    exit /b 1
)

:: 3. Python 가상 환경 생성
echo 2. Python 가상 환경 생성...
python -m venv "%WORK_DIR%\venv"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: 가상 환경 생성 실패
    pause
    exit /b 1
)

:: 4. 가상 환경 활성화 및 빌드 도구 설치
echo 3. 가상 환경 활성화 및 빌드 도구 설치...
call "%WORK_DIR%\venv\Scripts\activate"
pip install --no-index --find-links="%PACKAGE_DIR%" wheel setuptools
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: 빌드 도구 설치 실패
    pause
    exit /b 1
)

:: 5. Open WebUI 및 종속성 설치
echo 4. Open WebUI 및 종속성 설치...
pip install --no-index --find-links="%PACKAGE_DIR%" open-webui
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Open WebUI 설치 실패
    pause
    exit /b 1
)


echo === 설치 완료! 이제 start_openwebui.bat 으로 실행하세요. ===
pause
