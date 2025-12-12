# Open WebUI 폐쇄망(오프라인) 설치 자동화 프로젝트

> **Commit:** e62915fe5c3a6a333935b9df5dfb3157eedf69e8
> **Branch:** feature/used_version
> **프로젝트 목적:** 인터넷이 차단된 폐쇄망 환경에서 Open WebUI를 자동으로 설치하고 실행할 수 있도록 지원

---

## 📋 목차

1. [프로젝트 개요](#프로젝트-개요)
2. [주요 기능](#주요-기능)
3. [시스템 요구사항](#시스템-요구사항)
4. [스크립트 상세 분석](#스크립트-상세-분석)
5. [설치 및 사용 가이드](#설치-및-사용-가이드)
6. [아키텍처 및 워크플로우](#아키텍처-및-워크플로우)
7. [코드 목적 분석](#코드-목적-분석)
8. [개선 제안사항](#개선-제안사항)
9. [문제 해결](#문제-해결)

---

## 프로젝트 개요

이 프로젝트는 **폐쇄망(인터넷 차단) 환경**에서 Open WebUI를 설치하고 실행할 수 있도록 하는 Windows 배치 스크립트 모음입니다. Open WebUI는 로컬 LLM(Large Language Model)을 위한 웹 기반 사용자 인터페이스로, Ollama와 함께 사용됩니다.

### 핵심 문제

- **인터넷 접근 불가**: 보안상 이유로 인터넷이 차단된 환경
- **패키지 의존성**: Python 패키지와 그 의존성을 오프라인으로 설치해야 함
- **복잡한 설정**: 수동 설치 시 많은 단계와 기술적 지식 필요

### 솔루션

1. **인터넷 환경**에서 모든 필요한 패키지를 다운로드
2. **압축 파일**로 패키징하여 폐쇄망으로 이동
3. **자동화된 스크립트**로 폐쇄망에서 설치 및 실행

---

## 주요 기능

### 🔧 4개의 핵심 스크립트

| 스크립트 | 실행 환경 | 주요 기능 |
|---------|----------|----------|
| `prepare_openwebui_pip_style.bat` | 인터넷 환경 | 패키지 다운로드 및 압축 |
| `install_openwebui_pip_style.bat` | 폐쇄망 환경 | 오프라인 설치 |
| `run_openwebui_pip_style.bat` | 폐쇄망 환경 | Open WebUI 실행 |
| `install_and_run_openwebui_pip_style.bat` | 폐쇄망 환경 | 설치 + 실행 통합 |

---

## 시스템 요구사항

### 공통 요구사항
- **OS**: Windows 10 이상 (PowerShell 지원 필수)
- **Python**: 3.8 이상 (venv 모듈 포함)
- **Ollama**: 설치 필요 (LLM 백엔드)
- **디스크 공간**: 최소 5GB 이상 권장

### 인터넷 환경 (준비 단계)
- 인터넷 연결
- curl 명령어 사용 가능
- PowerShell 실행 권한

### 폐쇄망 환경 (설치 단계)
- 압축 해제를 위한 PowerShell
- Python 가상환경 생성 권한
- 관리자 권한 (선택적)

---

## 스크립트 상세 분석

### 1. prepare_openwebui_pip_style.bat

**목적**: 인터넷 환경에서 Open WebUI와 모든 의존성 패키지를 다운로드하고 압축

#### 주요 작업 흐름

```batch
작업 디렉토리: C:\OpenWebUI_Prep
최종 산출물: open-webui-pip-style.zip
```

**단계별 분석:**

1. **작업 디렉토리 생성** (Line 7-14)
   ```batch
   set "WORK_DIR=C:\OpenWebUI_Prep"
   if not exist "%WORK_DIR%" mkdir "%WORK_DIR%"
   ```
   - 고정된 경로 사용으로 일관성 확보
   - 기존 디렉토리가 있어도 안전하게 처리

2. **Open WebUI 소스 다운로드** (Line 16-22)
   ```batch
   curl -L -o "%OPENWEBUI_ZIP%" "https://github.com/open-webui/open-webui/archive/refs/heads/main.zip"
   ```
   - `-L` 옵션: 리다이렉트 자동 처리
   - main 브랜치의 최신 버전 다운로드
   - 에러 체크로 실패 시 즉시 중단

3. **ZIP 파일 압축 해제** (Line 24-30)
   ```batch
   powershell -command "Expand-Archive -Path '%OPENWEBUI_ZIP%' -DestinationPath '.'"
   ```
   - PowerShell의 네이티브 압축 해제 기능 사용
   - 별도 툴 불필요

4. **Python 패키지 다운로드** (Line 32-42)
   ```batch
   pip download -r "%WORK_DIR%\open-webui-main\backend\requirements.txt"
   ```
   - `pip download`: 설치 없이 패키지 파일(.whl, .tar.gz)만 다운로드
   - 모든 의존성 자동 다운로드
   - requirements.txt의 모든 패키지 처리

5. **추가 필수 패키지 다운로드** (Line 44-50)
   ```batch
   pip download wheel setuptools open-webui
   ```
   - `wheel`: 바이너리 패키지 설치에 필요
   - `setuptools`: 패키지 빌드 도구
   - `open-webui`: PyPI의 공식 패키지

6. **최종 압축 파일 생성** (Line 52-59)
   ```batch
   powershell -command "Compress-Archive -Path '%OPENWEBUI_ZIP%', 'open-webui-main', 'packages' -DestinationPath '%FINAL_ZIP%'"
   ```
   - 3개 항목 압축:
     - 원본 ZIP 파일
     - 압축 해제된 소스 코드
     - 다운로드된 패키지 디렉토리

**출력 파일 구조:**
```
open-webui-pip-style.zip
├── open-webui-main.zip          # GitHub 원본
├── open-webui-main/             # 소스 코드
│   └── backend/
│       └── requirements.txt
└── packages/                    # Python 패키지들
    ├── open_webui-*.whl
    ├── fastapi-*.whl
    ├── uvicorn-*.whl
    └── ... (모든 의존성)
```

---

### 2. install_openwebui_pip_style.bat

**목적**: 폐쇄망 환경에서 다운로드된 패키지를 사용하여 Open WebUI 설치

#### 주요 작업 흐름

```batch
작업 디렉토리: C:\OpenWebUI
필요 파일: open-webui-pip-style.zip
```

**단계별 분석:**

1. **환경 설정** (Line 7-11)
   ```batch
   set "WORK_DIR=C:\OpenWebUI"
   set "FINAL_ZIP=%WORK_DIR%\open-webui-pip-style.zip"
   set "PACKAGE_DIR=%OPENWEBUI_DIR%\packages"
   ```
   - 설치 디렉토리 고정
   - ZIP 파일 위치 지정

2. **ZIP 파일 검증 및 압축 해제** (Line 18-29)
   ```batch
   if not exist "%FINAL_ZIP%" (
       echo ERROR: ZIP 파일이 존재하지 않습니다.
       exit /b 1
   )
   powershell -command "Expand-Archive -Path '%FINAL_ZIP%' -DestinationPath '%OPENWEBUI_DIR%'"
   ```
   - 파일 존재 여부 검증
   - 명확한 에러 메시지 제공
   - 압축 해제 실패 시 즉시 중단

3. **Python 가상환경 생성** (Line 31-38)
   ```batch
   python -m venv "%WORK_DIR%\venv"
   ```
   - 격리된 Python 환경 생성
   - 시스템 Python에 영향 없음
   - 패키지 충돌 방지

4. **가상환경 활성화 및 기본 도구 설치** (Line 40-48)
   ```batch
   call "%WORK_DIR%\venv\Scripts\activate"
   pip install --no-index --find-links="%PACKAGE_DIR%" wheel setuptools
   ```
   - `--no-index`: PyPI 접근 차단 (오프라인 보장)
   - `--find-links`: 로컬 패키지 디렉토리 지정
   - wheel, setuptools 우선 설치로 이후 설치 안정화

5. **Open WebUI 설치** (Line 50-57)
   ```batch
   pip install --no-index --find-links="%PACKAGE_DIR%" open-webui
   ```
   - 완전 오프라인 설치
   - 모든 의존성 자동 해결
   - packages 폴더에서만 패키지 검색

**핵심 기술:**
- `--no-index`: 인터넷 접근 시도 차단
- `--find-links`: 로컬 파일 시스템에서 패키지 검색
- 의존성 자동 해결: pip가 packages 폴더에서 필요한 모든 의존성 찾기

---

### 3. run_openwebui_pip_style.bat

**목적**: 설치된 Open WebUI와 Ollama를 실행

#### 주요 작업 흐름

**단계별 분석:**

1. **가상환경 활성화** (Line 10-17)
   ```batch
   call "%WORK_DIR%\venv\Scripts\activate"
   ```
   - 설치된 패키지에 접근하기 위해 필수
   - 활성화 실패 시 명확한 에러 메시지

2. **Ollama 서비스 확인 및 시작** (Line 19-28)
   ```batch
   ollama serve >nul 2>&1
   if %ERRORLEVEL% NEQ 0 (
       start cmd /k "ollama serve"
       timeout /t 5
   )
   ```
   - 먼저 Ollama가 실행 중인지 확인
   - 실행 중이 아니면 새 CMD 창에서 시작
   - `>nul 2>&1`: 출력 숨김 (확인 목적만)
   - `start cmd /k`: 새 창에서 실행하고 유지
   - `timeout /t 5`: Ollama 초기화 대기

3. **Open WebUI 실행** (Line 30-37)
   ```batch
   open-webui serve
   ```
   - 기본 포트 8080으로 웹 서버 시작
   - 블로킹 명령어 (실행 중 유지)

**서비스 아키텍처:**
```
┌─────────────────┐
│   웹 브라우저    │
│ localhost:8080  │
└────────┬────────┘
         │ HTTP
┌────────▼────────┐
│   Open WebUI    │
│   (Python)      │
└────────┬────────┘
         │ API
┌────────▼────────┐
│     Ollama      │
│   (LLM 백엔드)   │
└─────────────────┘
```

---

### 4. install_and_run_openwebui_pip_style.bat

**목적**: 설치와 실행을 한 번에 처리하는 통합 스크립트

#### 주요 작업 흐름

이 스크립트는 `install_openwebui_pip_style.bat`와 `run_openwebui_pip_style.bat`의 기능을 결합한 올인원 솔루션입니다.

**단계별 분석:**

1. **환경 변수 설정** (Line 6-13)
   ```batch
   set "WORK_DIR=C:\OpenWebUI"
   set "DATA_DIR=%WORK_DIR%\data"
   ```
   - 추가 변수: `DATA_DIR` (데이터 저장 위치)
   - `BACKEND_DIR` 정의 (사용하지 않지만 확장성 고려)

2. **설치 프로세스** (Line 18-54)
   - ZIP 압축 해제
   - Python 가상환경 생성
   - wheel, setuptools 설치
   - open-webui 설치
   - **install 스크립트와 동일**

3. **데이터 디렉토리 설정** (Line 56-58)
   ```batch
   if not exist "%DATA_DIR%" mkdir "%DATA_DIR%"
   set "OPENWEBUI_DATA_DIR=%DATA_DIR%"
   ```
   - 사용자 데이터, 설정, 대화 기록 저장 위치
   - 환경 변수로 Open WebUI에 전달

4. **Ollama 및 Open WebUI 실행** (Line 60-76)
   - Ollama 상태 확인 및 시작
   - Open WebUI 서버 실행
   - **run 스크립트와 동일**

**장점:**
- 한 번의 실행으로 완전한 설정
- 초보자 친화적
- 데이터 디렉토리 명시적 설정

**단점:**
- 재실행 시 재설치 시도 (이미 설치된 경우 오류 가능)
- 설치와 실행을 분리하는 것이 더 유연함

---

## 설치 및 사용 가이드

### 📦 STEP 1: 인터넷 환경에서 패키지 준비

```batch
# prepare_openwebui_pip_style.bat 실행
C:\> prepare_openwebui_pip_style.bat

# 결과 파일 확인
C:\OpenWebUI_Prep\open-webui-pip-style.zip
```

**예상 소요 시간**: 10-30분 (인터넷 속도에 따라)
**파일 크기**: 약 500MB-2GB

---

### 💾 STEP 2: 폐쇄망으로 파일 이동

1. USB 드라이브 또는 승인된 파일 전송 방법 사용
2. `open-webui-pip-style.zip`을 폐쇄망 PC의 `C:\OpenWebUI\`에 복사

---

### 🔧 STEP 3: 폐쇄망에서 설치

**옵션 A: 설치만 수행**
```batch
C:\> install_openwebui_pip_style.bat
```

**옵션 B: 설치 + 즉시 실행**
```batch
C:\> install_and_run_openwebui_pip_style.bat
```

---

### 🚀 STEP 4: Open WebUI 실행 (이미 설치된 경우)

```batch
C:\> run_openwebui_pip_style.bat
```

웹 브라우저에서 접속:
```
http://localhost:8080
```

---

## 아키텍처 및 워크플로우

### 전체 워크플로우

```
┌─────────────────────────────────────────────────────────────┐
│                  인터넷 환경 (온라인)                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  [prepare_openwebui_pip_style.bat]                          │
│         │                                                    │
│         ├─ GitHub에서 Open WebUI 소스 다운로드               │
│         ├─ PyPI에서 모든 패키지 다운로드                     │
│         └─ ZIP 파일로 압축                                   │
│                   │                                          │
│                   ▼                                          │
│         [open-webui-pip-style.zip]                          │
│                   │                                          │
└───────────────────┼──────────────────────────────────────────┘
                    │
                    │ USB / 파일 전송
                    │
┌───────────────────▼──────────────────────────────────────────┐
│                  폐쇄망 환경 (오프라인)                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  [install_openwebui_pip_style.bat]                          │
│         │                                                    │
│         ├─ ZIP 압축 해제                                     │
│         ├─ Python 가상환경 생성                              │
│         └─ 오프라인 패키지 설치                              │
│                   │                                          │
│                   ▼                                          │
│  [run_openwebui_pip_style.bat]                              │
│         │                                                    │
│         ├─ Ollama 서비스 시작                                │
│         └─ Open WebUI 웹 서버 시작                           │
│                   │                                          │
│                   ▼                                          │
│         [http://localhost:8080]                             │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 디렉토리 구조

**인터넷 환경:**
```
C:\OpenWebUI_Prep\
├── open-webui-main.zip          # GitHub 원본
├── open-webui-main/             # 압축 해제된 소스
│   └── backend/
│       └── requirements.txt
├── packages/                    # 다운로드된 패키지
│   ├── *.whl
│   └── *.tar.gz
└── open-webui-pip-style.zip     # 최종 산출물
```

**폐쇄망 환경 (설치 후):**
```
C:\OpenWebUI\
├── open-webui-pip-style.zip     # 이동된 ZIP
├── open-webui-main/             # 압축 해제
│   ├── backend/
│   └── packages/                # 패키지 파일들
├── venv/                        # Python 가상환경
│   ├── Scripts/
│   │   ├── python.exe
│   │   ├── pip.exe
│   │   └── open-webui.exe
│   └── Lib/
└── data/                        # Open WebUI 데이터 (생성됨)
    ├── webui.db                 # SQLite 데이터베이스
    └── uploads/                 # 사용자 업로드 파일
```

---

## 코드 목적 분석

### 핵심 목적

이 프로젝트는 **보안이 중요한 폐쇄망 환경**에서 AI 기술(LLM)을 사용할 수 있도록 하는 것이 목적입니다.

#### 1. **보안 요구사항 충족**
- 인터넷 차단 환경에서도 AI 서비스 제공
- 데이터 외부 유출 방지
- 온프레미스 LLM 솔루션 구축

#### 2. **기술적 과제 해결**
- Python 패키지 의존성의 복잡한 그래프 해결
- 오프라인 설치의 어려움 극복
- 비기술 사용자도 쉽게 사용 가능

#### 3. **자동화를 통한 효율성**
- 수동 설치 시 수십 개 패키지를 일일이 다운로드해야 함
- 의존성 버전 충돌 수동 해결 필요
- 배치 스크립트로 모든 과정 자동화

### 대상 사용자

1. **기업 IT 관리자**: 폐쇄망 서버에 AI 서비스 구축
2. **보안 연구원**: 격리된 환경에서 AI 도구 사용
3. **정부/국방 기관**: 민감 데이터 환경에서 AI 활용
4. **교육 기관**: 인터넷 제한 환경에서 AI 학습

### 기술적 의의

#### ✅ pip download의 활용
```batch
pip download -r requirements.txt
```
- 설치 없이 패키지 파일만 다운로드
- 의존성 자동 해결
- 플랫폼별 바이너리 자동 선택

#### ✅ --no-index의 중요성
```batch
pip install --no-index --find-links="%PACKAGE_DIR%" open-webui
```
- PyPI 접근 완전 차단
- 로컬 패키지만 사용
- 오프라인 보장

#### ✅ 가상환경의 필수성
```batch
python -m venv "%WORK_DIR%\venv"
```
- 시스템 Python 격리
- 패키지 충돌 방지
- 재현 가능한 환경

---

## 개선 제안사항

### 🔴 Critical (중요도: 높음)

#### 1. **에러 처리 강화**

**현재 문제:**
```batch
pip install --no-index --find-links="%PACKAGE_DIR%" open-webui
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Open WebUI 설치 실패
    pause
    exit /b 1
)
```
- 에러 원인이 명확하지 않음
- 로그 파일이 생성되지 않음

**개선안:**
```batch
pip install --no-index --find-links="%PACKAGE_DIR%" open-webui > install.log 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Open WebUI 설치 실패
    echo 상세 로그: %WORK_DIR%\install.log
    type install.log
    pause
    exit /b 1
)
```

#### 2. **버전 고정 (Version Pinning)**

**현재 문제:**
- `main` 브랜치에서 최신 코드 다운로드
- 버전이 바뀌면 호환성 문제 발생 가능

**개선안:**
```batch
:: 특정 버전 태그 사용
set "OPENWEBUI_VERSION=v0.1.125"
curl -L -o "%OPENWEBUI_ZIP%" "https://github.com/open-webui/open-webui/archive/refs/tags/%OPENWEBUI_VERSION%.zip"
```

#### 3. **Python 버전 검증**

**현재 문제:**
- Python 버전 확인 없음
- 호환되지 않는 버전에서 실패 가능

**개선안:**
```batch
:: Python 버전 확인
python --version > python_version.txt 2>&1
findstr /C:"Python 3." python_version.txt >nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Python 3.x가 필요합니다
    echo 현재 설치된 Python:
    type python_version.txt
    del python_version.txt
    pause
    exit /b 1
)
del python_version.txt
```

#### 4. **재실행 안전성**

**현재 문제:**
- `install_and_run_openwebui_pip_style.bat` 재실행 시 이미 설치된 환경에서 오류 발생

**개선안:**
```batch
:: 기존 venv 확인 및 처리
if exist "%WORK_DIR%\venv" (
    echo 기존 가상환경이 발견되었습니다.
    choice /C YN /M "기존 환경을 삭제하고 재설치하시겠습니까?"
    if errorlevel 2 goto :skip_install
    if errorlevel 1 (
        echo 기존 환경 삭제 중...
        rmdir /s /q "%WORK_DIR%\venv"
    )
)

:skip_install
```

#### 5. **인코딩 문제 해결**

**현재 문제:**
- 한글 주석과 메시지로 인한 인코딩 문제
- Windows 코드페이지에 따라 깨짐 발생

**개선안:**
```batch
:: ASCII 영어로 모든 메시지 작성
echo === Open WebUI Offline Installation (pip-style) ===
echo.
echo Step 1: Creating working directory...
echo Step 2: Downloading Open WebUI source...
```

---

### 🟡 Important (중요도: 중간)

#### 6. **로깅 시스템 구현**

**개선안:**
```batch
:: 로그 파일 설정
set "LOG_FILE=%WORK_DIR%\installation_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.log"
set "LOG_FILE=%LOG_FILE: =0%"

:: 로깅 함수
:log
echo [%date% %time%] %~1 >> "%LOG_FILE%"
echo %~1
goto :eof

:: 사용 예
call :log "Open WebUI installation started"
```

#### 7. **진행률 표시**

**개선안:**
```batch
echo [1/7] Creating working directory...
echo [2/7] Downloading Open WebUI source...
echo [3/7] Extracting ZIP archive...
echo [4/7] Downloading Python packages...
echo [5/7] Downloading additional tools...
echo [6/7] Creating final package...
echo [7/7] Done!
```

#### 8. **Ollama 설치 확인**

**현재 문제:**
- Ollama가 설치되지 않은 경우 명확한 안내 없음

**개선안:**
```batch
:: Ollama 설치 확인
where ollama >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Ollama is not installed
    echo Please download and install Ollama from: https://ollama.ai
    pause
    exit /b 1
)

:: Ollama 버전 확인
ollama --version
```

#### 9. **환경 변수 검증**

**개선안:**
```batch
:: 필수 환경 변수 확인
if not defined WORK_DIR (
    echo ERROR: WORK_DIR is not set
    exit /b 1
)

:: 경로 유효성 검증
echo %WORK_DIR% | findstr /R /C:"[<>:\"/\\|?*]" >nul
if %ERRORLEVEL% EQU 0 (
    echo ERROR: Invalid path specified
    exit /b 1
)
```

#### 10. **디스크 공간 확인**

**개선안:**
```batch
:: 디스크 공간 확인 (최소 5GB 필요)
for /f "tokens=3" %%a in ('dir /-c %WORK_DIR:~0,2%\ ^| findstr /C:"bytes free"') do set FREE_SPACE=%%a
if %FREE_SPACE% LSS 5000000000 (
    echo WARNING: Low disk space. At least 5GB recommended.
    pause
)
```

---

### 🟢 Nice to Have (중요도: 낮음)

#### 11. **GUI 또는 대화형 모드**

**개선안:**
```batch
:: 사용자 선택 메뉴
:menu
cls
echo ================================
echo   Open WebUI Installation Manager
echo ================================
echo.
echo 1. Fresh Installation
echo 2. Update Existing Environment
echo 3. Uninstall
echo 4. Exit
echo.
choice /C 1234 /N /M "Select option: "

if errorlevel 4 exit /b
if errorlevel 3 goto :uninstall
if errorlevel 2 goto :update
if errorlevel 1 goto :install
```

#### 12. **설정 파일 지원**

**개선안:**
```ini
; config.ini
[Paths]
WorkDir=C:\OpenWebUI
DataDir=C:\OpenWebUI\data

[Versions]
OpenWebUIVersion=v0.1.125
PythonMinVersion=3.8

[Options]
AutoStartOllama=yes
Port=8080
```

#### 13. **압축 파일 체크섬 검증**

**개선안:**
```batch
:: SHA256 체크섬 생성 (준비 단계)
certutil -hashfile "%FINAL_ZIP%" SHA256 > "%FINAL_ZIP%.sha256"

:: 체크섬 검증 (설치 단계)
certutil -hashfile "%FINAL_ZIP%" SHA256 > temp_hash.txt
fc "%FINAL_ZIP%.sha256" temp_hash.txt >nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: File integrity check failed
    del temp_hash.txt
    pause
    exit /b 1
)
del temp_hash.txt
```

#### 14. **자동 업데이트 스크립트**

**개선안:**
```batch
:: update_openwebui.bat
:: 기존 설치 유지하면서 패키지만 업데이트
call "%WORK_DIR%\venv\Scripts\activate"
pip install --upgrade --no-index --find-links="%PACKAGE_DIR%" open-webui
```

#### 15. **설치된 패키지 버전 목록 생성**

**개선안:**
```batch
:: 설치된 패키지 버전 기록
pip freeze > "%WORK_DIR%\installed_packages.txt"
echo Package list saved to: installed_packages.txt
```

---

## 문제 해결

### 일반적인 오류

#### ❌ "Python을 찾을 수 없습니다"

**원인**: Python이 PATH에 없음

**해결:**
```batch
where python
:: 출력이 없으면 Python 재설치 필요 (Add to PATH 옵션 체크)
```

---

#### ❌ "PowerShell 실행이 차단되었습니다"

**원인**: PowerShell 실행 정책

**해결:**
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

---

#### ❌ "ZIP 압축 해제 실패"

**원인**: PowerShell 버전 문제 또는 손상된 ZIP 파일

**해결:**
```batch
:: 파일 무결성 확인
dir "%FINAL_ZIP%"

:: 수동으로 압축 해제 시도
powershell -command "Expand-Archive -Path '%FINAL_ZIP%' -DestinationPath '%WORK_DIR%' -Force"
```

---

#### ❌ "패키지를 찾을 수 없습니다"

**원인**: packages 디렉토리 경로 오류

**해결:**
```batch
:: 경로 확인
dir "%PACKAGE_DIR%"
:: *.whl, *.tar.gz 파일이 있어야 함

:: 수동으로 경로 지정
set "PACKAGE_DIR=C:\OpenWebUI\open-webui-main\packages"
pip install --no-index --find-links="%PACKAGE_DIR%" open-webui
```

---

#### ❌ "Ollama 연결 실패"

**원인**: Ollama 서비스 미실행

**해결:**
```batch
:: 수동으로 Ollama 시작
ollama serve

:: 다른 터미널에서 Open WebUI 실행
call "%WORK_DIR%\venv\Scripts\activate"
open-webui serve
```

---

#### ❌ "포트 8080이 이미 사용 중입니다"

**원인**: 다른 서비스가 8080 포트 사용

**해결:**
```batch
:: 환경 변수로 포트 변경
set OPENWEBUI_PORT=8081
open-webui serve
```

---

## 결론

이 프로젝트는 **폐쇄망 환경에서 AI 기술을 안전하게 사용**할 수 있도록 하는 실용적인 솔루션입니다.

### 주요 성과

✅ **자동화**: 복잡한 설치 과정을 배치 스크립트로 단순화
✅ **오프라인**: 완전한 인터넷 차단 환경에서 작동
✅ **재현성**: 일관된 설치 환경 보장
✅ **사용자 친화적**: 비기술 사용자도 사용 가능

### 적용 분야

- 🏢 기업 폐쇄망
- 🛡️ 보안 연구 환경
- 🏛️ 정부/국방 기관
- 🎓 교육 기관
- 🏥 의료 기관 (환자 데이터 보호)

### 기술적 교훈

1. **pip download + --no-index**: 오프라인 Python 패키지 관리의 표준 패턴
2. **가상환경의 중요성**: 시스템 격리와 재현성
3. **에러 처리**: 각 단계의 검증으로 디버깅 용이성 확보
4. **배치 스크립트**: Windows 환경에서 자동화의 간단하고 효과적인 방법

---

## 참고 자료

- [Open WebUI 공식 문서](https://docs.openwebui.com/)
- [Ollama 공식 사이트](https://ollama.ai/)
- [Python pip 문서](https://pip.pypa.io/en/stable/)
- [Windows 배치 스크립트 가이드](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/windows-commands)

---

**작성일**: 2025-12-12
**버전**: 1.0.0
**작성자**: Claude (코드 분석 및 문서화)
**대상 커밋**: e62915fe5c3a6a333935b9df5dfb3157eedf69e8
