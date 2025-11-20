@echo off
setlocal EnableDelayedExpansion

echo ====================================================================
echo    Open WebUI 폐쇄망 설치용 다운로드 스크립트 v1.0
echo ====================================================================
echo.

:: 작업 디렉토리 설정
set "WORK_DIR=C:\OpenWebUI_Download"
set "PACKAGE_DIR=%WORK_DIR%\packages"
set "VENV_DIR=%WORK_DIR%\venv"

echo [1/9] 네트워크 연결 상태 확인 중...
ping -n 1 8.8.8.8 >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ ERROR: 인터넷 연결이 필요합니다.
    echo    네트워크 연결 상태를 확인하고 다시 시도하세요.
    pause
    exit /b 1
)
echo ✅ 네트워크 연결 확인됨

echo.
echo [2/9] Python 설치 확인 중...
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ ERROR: Python이 설치되지 않았거나 PATH에 없습니다.
    echo    Python 3.8 이상을 설치한 후 다시 시도하세요.
    echo    다운로드: https://www.python.org/downloads/
    pause
    exit /b 1
)

for /f "tokens=2" %%v in ('python --version 2^>^&1') do set PYTHON_VERSION=%%v
echo ✅ Python %PYTHON_VERSION% 확인됨

echo.
echo [3/9] 작업 디렉토리 준비 중...
if exist "%WORK_DIR%" (
    echo    기존 작업 디렉토리 발견. 정리 중...
    rmdir /s /q "%WORK_DIR%" 2>nul
)
mkdir "%WORK_DIR%" 2>nul
mkdir "%PACKAGE_DIR%" 2>nul
cd /d "%WORK_DIR%"
if %ERRORLEVEL% NEQ 0 (
    echo ❌ ERROR: 작업 디렉토리 생성 실패
    echo    경로: %WORK_DIR%
    echo    관리자 권한이 필요하거나 디스크 공간이 부족할 수 있습니다.
    pause
    exit /b 1
)
echo ✅ 작업 디렉토리 준비 완료: %WORK_DIR%

echo.
echo [4/9] Python 가상환경 생성 중...
python -m venv "%VENV_DIR%"
if %ERRORLEVEL% NEQ 0 (
    echo ❌ ERROR: 가상환경 생성 실패
    echo    Python venv 모듈이 설치되어 있는지 확인하세요.
    pause
    exit /b 1
)
echo ✅ 가상환경 생성 완료

echo.
echo [5/9] 가상환경 활성화 중...
call "%VENV_DIR%\Scripts\activate"
if %ERRORLEVEL% NEQ 0 (
    echo ❌ ERROR: 가상환경 활성화 실패
    pause
    exit /b 1
)
echo ✅ 가상환경 활성화 완료

echo.
echo [6/9] pip 도구 업그레이드 중...
python -m pip install --upgrade pip
if %ERRORLEVEL% NEQ 0 (
    echo ⚠️  WARNING: pip 업그레이드 실패 (계속 진행)
)
echo ✅ pip 업그레이드 완료

echo.
echo [7/9] Open WebUI 및 의존성 다운로드 중...
echo    이 과정은 몇 분이 소요될 수 있습니다...
echo.
pip download open-webui --dest "%PACKAGE_DIR%" --progress-bar on
if %ERRORLEVEL% NEQ 0 (
    echo ❌ ERROR: Open WebUI 다운로드 실패
    echo    네트워크 연결을 확인하거나 잠시 후 다시 시도하세요.
    pause
    exit /b 1
)

echo.
echo [8/9] 추가 필수 패키지 다운로드 중...
pip download wheel setuptools --dest "%PACKAGE_DIR%"
if %ERRORLEVEL% NEQ 0 (
    echo ⚠️  WARNING: 추가 패키지 다운로드 실패 (계속 진행)
)

echo.
echo [9/9] 폐쇄망용 스크립트 생성 중...

:: 폐쇄망 설치 스크립트 생성
(
echo @echo off
echo setlocal EnableDelayedExpansion
echo.
echo echo ====================================================================
echo echo    Open WebUI 폐쇄망 설치 스크립트 v1.0
echo echo ====================================================================
echo echo.
echo.
echo :: 작업 디렉토리 설정
echo set "WORK_DIR=C:\OpenWebUI"
echo set "PACKAGE_DIR=%%WORK_DIR%%\packages"
echo set "VENV_DIR=%%WORK_DIR%%\venv"
echo.
echo echo [1/8] 환경 검증 중...
echo :: Python 설치 확인
echo python --version ^>nul 2^>^&1
echo if %%ERRORLEVEL%% NEQ 0 ^(
echo     echo ❌ ERROR: Python이 설치되지 않았거나 PATH에 없습니다.
echo     echo    Python 3.8 이상을 설치한 후 다시 시도하세요.
echo     pause
echo     exit /b 1
echo ^)
echo for /f "tokens=2" %%%%v in ^('python --version 2^^^>^^^&1'^) do set PYTHON_VERSION=%%%%v
echo echo ✅ Python %%PYTHON_VERSION%% 확인됨
echo.
echo echo [2/8] 작업 디렉토리 준비 중...
echo if not exist "%%WORK_DIR%%" mkdir "%%WORK_DIR%%"
echo cd /d "%%WORK_DIR%%"
echo if %%ERRORLEVEL%% NEQ 0 ^(
echo     echo ❌ ERROR: 작업 디렉토리 접근 실패
echo     pause
echo     exit /b 1
echo ^)
echo echo ✅ 작업 디렉토리: %%WORK_DIR%%
echo.
echo echo [3/8] 패키지 파일 확인 중...
echo if not exist "%%PACKAGE_DIR%%" ^(
echo     echo ❌ ERROR: packages 폴더가 없습니다.
echo     echo    인터넷망에서 다운로드한 압축파일을 여기에 풀어주세요.
echo     echo    필요한 폴더: %%PACKAGE_DIR%%
echo     pause
echo     exit /b 1
echo ^)
echo dir "%%PACKAGE_DIR%%\*.whl" ^>nul 2^>^&1
echo if %%ERRORLEVEL%% NEQ 0 ^(
echo     echo ❌ ERROR: packages 폴더에 .whl 파일이 없습니다.
echo     echo    올바른 패키지 폴더인지 확인하세요.
echo     pause
echo     exit /b 1
echo ^)
echo echo ✅ 패키지 파일 확인 완료
echo.
echo echo [4/8] Python 가상환경 생성 중...
echo if exist "%%VENV_DIR%%" ^(
echo     echo    기존 가상환경 제거 중...
echo     rmdir /s /q "%%VENV_DIR%%" 2^>nul
echo ^)
echo python -m venv "%%VENV_DIR%%"
echo if %%ERRORLEVEL%% NEQ 0 ^(
echo     echo ❌ ERROR: 가상환경 생성 실패
echo     pause
echo     exit /b 1
echo ^)
echo echo ✅ 가상환경 생성 완료
echo.
echo echo [5/8] 가상환경 활성화 중...
echo call "%%VENV_DIR%%\Scripts\activate"
echo if %%ERRORLEVEL%% NEQ 0 ^(
echo     echo ❌ ERROR: 가상환경 활성화 실패
echo     pause
echo     exit /b 1
echo ^)
echo echo ✅ 가상환경 활성화 완료
echo.
echo echo [6/8] 기본 패키지 설치 중...
echo pip install --no-index --find-links="%%PACKAGE_DIR%%" wheel setuptools
echo if %%ERRORLEVEL%% NEQ 0 ^(
echo     echo ❌ ERROR: 기본 패키지 설치 실패
echo     pause
echo     exit /b 1
echo ^)
echo echo ✅ 기본 패키지 설치 완료
echo.
echo echo [7/8] Open WebUI 설치 중...
echo echo    설치 진행 중... 잠시만 기다려주세요.
echo pip install --no-index --find-links="%%PACKAGE_DIR%%" open-webui
echo if %%ERRORLEVEL%% NEQ 0 ^(
echo     echo ❌ ERROR: Open WebUI 설치 실패
echo     echo    패키지 파일이 손상되었거나 호환되지 않을 수 있습니다.
echo     pause
echo     exit /b 1
echo ^)
echo echo ✅ Open WebUI 설치 완료
echo.
echo echo [8/8] 설치 검증 중...
echo pip show open-webui ^>nul 2^>^&1
echo if %%ERRORLEVEL%% NEQ 0 ^(
echo     echo ❌ ERROR: Open WebUI 설치 검증 실패
echo     pause
echo     exit /b 1
echo ^)
echo echo ✅ 설치 검증 완료
echo.
echo echo ====================================================================
echo echo                           설치 완료!
echo echo ====================================================================
echo echo.
echo echo Open WebUI가 성공적으로 설치되었습니다.
echo echo.
echo echo 실행 방법:
echo echo   1. run_openwebui.bat 파일을 실행하세요
echo echo   2. 브라우저에서 http://localhost:8080 으로 접속하세요
echo echo.
echo echo 설치 정보:
echo echo   설치 위치: %%WORK_DIR%%
echo echo   가상환경: %%VENV_DIR%%
echo echo.
echo pause
) > "%WORK_DIR%\install_openwebui_offline.bat"

:: 폐쇄망 실행 스크립트 생성
(
echo @echo off
echo setlocal EnableDelayedExpansion
echo.
echo echo ====================================================================
echo echo    Open WebUI 실행 스크립트 v1.0
echo echo ====================================================================
echo echo.
echo.
echo :: 작업 디렉토리 설정
echo set "WORK_DIR=C:\OpenWebUI"
echo set "VENV_DIR=%%WORK_DIR%%\venv"
echo.
echo echo [1/4] 설치 상태 확인 중...
echo if not exist "%%VENV_DIR%%" ^(
echo     echo ❌ ERROR: Open WebUI가 설치되지 않았습니다.
echo     echo    먼저 install_openwebui_offline.bat를 실행하세요.
echo     pause
echo     exit /b 1
echo ^)
echo echo ✅ 설치 상태 확인됨
echo.
echo echo [2/4] 가상환경 활성화 중...
echo call "%%VENV_DIR%%\Scripts\activate"
echo if %%ERRORLEVEL%% NEQ 0 ^(
echo     echo ❌ ERROR: 가상환경 활성화 실패
echo     echo    설치에 문제가 있을 수 있습니다.
echo     echo    install_openwebui_offline.bat를 다시 실행해보세요.
echo     pause
echo     exit /b 1
echo ^)
echo echo ✅ 가상환경 활성화 완료
echo.
echo echo [3/4] Open WebUI 실행 확인 중...
echo pip show open-webui ^>nul 2^>^&1
echo if %%ERRORLEVEL%% NEQ 0 ^(
echo     echo ❌ ERROR: Open WebUI가 제대로 설치되지 않았습니다.
echo     echo    install_openwebui_offline.bat를 다시 실행해보세요.
echo     pause
echo     exit /b 1
echo ^)
echo echo ✅ Open WebUI 설치 확인됨
echo.
echo echo [4/4] Open WebUI 서버 시작 중...
echo echo.
echo echo ====================================================================
echo echo                      Open WebUI 실행 중
echo echo ====================================================================
echo echo.
echo echo 🌐 브라우저에서 다음 주소로 접속하세요:
echo echo    http://localhost:8080
echo echo.
echo echo 📝 사용 방법:
echo echo    - 첫 접속 시 관리자 계정을 생성하세요
echo echo    - AI 모델은 별도로 설치해야 합니다 ^(Ollama 등^)
echo echo.
echo echo 🛑 종료 방법:
echo echo    - 이 창에서 Ctrl+C를 누르세요
echo echo.
echo echo ⏰ 서버 시작 중... 잠시만 기다려주세요.
echo echo.
echo open-webui serve --host 0.0.0.0 --port 8080
echo.
echo if %%ERRORLEVEL%% NEQ 0 ^(
echo     echo.
echo     echo ❌ ERROR: Open WebUI 실행 실패
echo     echo    포트 8080이 이미 사용 중이거나 설치에 문제가 있을 수 있습니다.
echo     pause
echo     exit /b 1
echo ^)
echo.
echo echo ====================================================================
echo echo                    Open WebUI가 종료되었습니다
echo echo ====================================================================
echo pause
) > "%WORK_DIR%\run_openwebui.bat"

:: 압축 파일 생성
echo.
echo 압축 파일 생성 중...
powershell -command "Compress-Archive -Path '%PACKAGE_DIR%', '%WORK_DIR%\install_openwebui_offline.bat', '%WORK_DIR%\run_openwebui.bat' -DestinationPath '%WORK_DIR%\openwebui_offline_package.zip' -Force"
if %ERRORLEVEL% NEQ 0 (
    echo ⚠️  WARNING: 압축 파일 생성 실패
    echo    수동으로 다음 파일들을 폐쇄망으로 복사하세요:
    echo    - %PACKAGE_DIR%
    echo    - %WORK_DIR%\install_openwebui_offline.bat
    echo    - %WORK_DIR%\run_openwebui.bat
) else (
    echo ✅ 압축 파일 생성 완료
)

echo.
echo ====================================================================
echo                        다운로드 완료!
echo ====================================================================
echo.
echo 생성된 파일들:
echo   📁 %PACKAGE_DIR% (패키지 파일들)
echo   📄 %WORK_DIR%\install_openwebui_offline.bat (폐쇄망 설치 스크립트)
echo   📄 %WORK_DIR%\run_openwebui.bat (폐쇄망 실행 스크립트)
echo   📦 %WORK_DIR%\openwebui_offline_package.zip (이동용 압축 파일)
echo.
echo 📋 다음 단계:
echo   1. openwebui_offline_package.zip 파일을 폐쇄망 PC로 복사
echo   2. 폐쇄망에서 압축 해제
echo   3. install_openwebui_offline.bat 실행
echo   4. run_openwebui.bat 실행
echo.
echo 💡 참고: 패키지 크기는 약 500MB~1GB 정도입니다.
echo.
pause