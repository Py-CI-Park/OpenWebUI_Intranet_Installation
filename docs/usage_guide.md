# Open Web UI 폐쇄망 설치 가이드

## 📋 개요

이 가이드는 인터넷이 연결되지 않은 폐쇄망 환경에서 Open Web UI를 설치하고 사용하는 방법을 설명합니다.

### 🎯 설치 목표
- 폐쇄망에서 Open Web UI 완전한 설치 및 실행
- 인터넷망에서 필요한 모든 패키지 사전 다운로드
- 자동화된 설치 프로세스 제공

### 📁 프로젝트 구조
```
OpenWebUI_Intranet_Installation/
├── internet/                    # 인터넷망 환경 파일
│   └── download_packages.bat    # 패키지 다운로드 스크립트
├── intranet/                    # 폐쇄망 환경 파일
│   ├── install_openwebui.bat    # 초기 설치 스크립트
│   └── run_openwebui.bat        # 실행 전용 스크립트
├── docs/                        # 문서
│   └── usage_guide.md           # 본 사용 가이드
├── Claude.md                    # 개발 기록
└── README.md                    # 프로젝트 소개
```

---

## 🌐 STEP 1: 인터넷망에서 패키지 다운로드

### 사전 요구사항
- Windows 10/11 또는 Windows Server
- Python 3.8 이상 설치
- 인터넷 연결
- 관리자 권한 (권장)

### 다운로드 실행
1. `internet/download_packages.bat` 파일을 관리자 권한으로 실행
2. 스크립트가 자동으로 다음 작업을 수행:
   - Python 버전 확인
   - pip 업그레이드
   - Open Web UI 및 모든 의존성 패키지 다운로드
   - 패키지들을 압축 파일로 생성

### 출력 결과
- `openwebui_intranet_package_YYYYMMDD_HHMMSS.zip`: 설치용 압축 파일
- `openwebui_packages/`: 원본 패키지 폴더

### 주의사항
- 다운로드 시간은 네트워크 상태에 따라 5-30분 소요
- 압축 파일 크기는 약 100-500MB
- 다운로드가 실패하면 네트워크 상태를 확인 후 재시도

---

## 🔒 STEP 2: 폐쇄망으로 파일 이동

### 이동할 파일
1. `openwebui_intranet_package_YYYYMMDD_HHMMSS.zip` (필수)
2. `intranet/install_openwebui.bat` (필수)
3. `intranet/run_openwebui.bat` (필수)

### 이동 방법
- USB 드라이브
- 내부 네트워크 파일 공유
- 기타 승인된 파일 전송 방법

---

## 🖥️ STEP 3: 폐쇄망에서 설치 실행

### 사전 요구사항
- Windows 10/11 또는 Windows Server
- Python 3.8 이상 설치
- C:\ 드라이브에 충분한 공간 (최소 2GB)
- 관리자 권한 (권장)

### 설치 절차

#### 3.1 압축 해제
```bash
# 작업 디렉토리 생성
mkdir C:\OpenWebUI_Setup
cd C:\OpenWebUI_Setup

# 압축 파일 해제 (PowerShell 사용)
Expand-Archive -Path "openwebui_intranet_package_YYYYMMDD_HHMMSS.zip" -DestinationPath "packages"
```

#### 3.2 설치 실행
1. `packages` 폴더로 이동
2. `install_openwebui.bat` 파일을 해당 폴더에 복사
3. `install_openwebui.bat`을 관리자 권한으로 실행

#### 3.3 설치 과정
스크립트가 자동으로 다음 작업을 수행:
1. Python 설치 확인
2. 패키지 파일 확인
3. `C:\OpenWebUI` 디렉토리 생성
4. Python 가상환경 생성
5. 가상환경 활성화
6. pip 업그레이드
7. Open Web UI 설치
8. 실행 스크립트 생성
9. 바탕화면 바로가기 생성 (선택사항)

### 예상 소요 시간
- 5-15분 (시스템 성능에 따라 다름)

---

## 🚀 STEP 4: Open Web UI 실행

### 실행 방법 (3가지)

#### 방법 1: 바탕화면 바로가기
- 설치 시 생성된 "Open Web UI" 바로가기 더블클릭

#### 방법 2: 설치 폴더에서 실행
```bash
C:\OpenWebUI\start_openwebui.bat
```

#### 방법 3: 실행 전용 스크립트
```bash
# run_openwebui.bat을 C:\OpenWebUI에 복사 후 실행
run_openwebui.bat
```

### 웹 접속
1. 스크립트 실행 후 웹 브라우저 열기
2. 주소창에 입력: `http://localhost:8080`
3. 첫 실행 시 관리자 계정 생성 필요

---

## 🔧 설정 및 관리

### 기본 설정
- **포트**: 8080 (변경 가능)
- **호스트**: 0.0.0.0 (모든 인터페이스)
- **데이터 저장**: `C:\OpenWebUI\data`
- **로그 파일**: `C:\OpenWebUI\logs`

### 방화벽 설정
Windows Defender 방화벽에서 포트 8080 허용:
```powershell
netsh advfirewall firewall add rule name="Open Web UI" dir=in action=allow protocol=TCP localport=8080
```

### 서비스 등록 (선택사항)
시스템 부팅 시 자동 시작하려면 Windows 서비스로 등록 가능

---

## 🛠️ 문제 해결

### 자주 발생하는 문제

#### 1. Python을 찾을 수 없음
**오류**: `'python'은(는) 내부 또는 외부 명령, 실행할 수 있는 프로그램, 또는 배치 파일이 아닙니다.`

**해결방법**:
- Python이 설치되어 있는지 확인
- PATH 환경변수에 Python이 추가되어 있는지 확인
- Command Prompt에서 `python --version` 테스트

#### 2. 가상환경 생성 실패
**오류**: `가상환경 생성에 실패했습니다.`

**해결방법**:
- 관리자 권한으로 실행
- C:\ 드라이브 공간 확인
- Python venv 모듈 설치 확인: `python -m pip install virtualenv`

#### 3. 패키지 설치 실패
**오류**: `Open Web UI 설치에 실패했습니다.`

**해결방법**:
- 패키지 파일이 모두 존재하는지 확인
- 패키지 파일이 손상되지 않았는지 확인
- 인터넷망에서 다시 다운로드

#### 4. 포트 8080 사용 중
**오류**: `Address already in use: 8080`

**해결방법**:
```bash
# 포트 사용 프로세스 확인
netstat -ano | findstr :8080

# 프로세스 종료 (PID 확인 후)
taskkill /PID [PID번호] /F
```

#### 5. 웹 페이지 접속 불가
**해결방법**:
- 방화벽 설정 확인
- 브라우저 캐시 삭제
- 다른 브라우저로 테스트
- `http://127.0.0.1:8080` 으로 접속 시도

### 로그 확인
- 설치 로그: 설치 과정 중 콘솔 출력 확인
- 실행 로그: `C:\OpenWebUI\logs\openwebui_YYYYMMDD.log`

---

## 📊 시스템 요구사항

### 최소 요구사항
- **OS**: Windows 10 또는 Windows Server 2016 이상
- **CPU**: 2코어 이상
- **메모리**: 4GB RAM
- **저장공간**: 2GB 여유 공간
- **Python**: 3.8 이상

### 권장 요구사항
- **OS**: Windows 11 또는 Windows Server 2022
- **CPU**: 4코어 이상
- **메모리**: 8GB RAM 이상
- **저장공간**: 5GB 여유 공간
- **Python**: 3.9 이상

---

## 🔄 업데이트 방법

### 새 버전 설치
1. 인터넷망에서 새로운 패키지 다운로드
2. 기존 설치 제거 또는 백업
3. 새 패키지로 재설치

### 데이터 백업
중요한 데이터는 다음 폴더를 백업:
- `C:\OpenWebUI\data`
- 사용자 설정 파일

---

## 📞 지원 및 문의

### 추가 정보
- Open Web UI 공식 GitHub: https://github.com/open-webui/open-webui
- 공식 문서: https://docs.openwebui.com

### 문제 리포트
설치나 사용 중 문제 발생 시 다음 정보를 포함하여 문의:
- Windows 버전
- Python 버전  
- 오류 메시지
- 로그 파일 내용

---

## 📝 라이선스 및 면책

이 설치 가이드와 스크립트는 Open Web UI 프로젝트의 라이선스를 따릅니다. 
사용자는 각 조직의 보안 정책을 준수하여 사용해야 합니다.

**면책 조항**: 본 스크립트 사용으로 인한 시스템 문제나 데이터 손실에 대해 
개발자는 책임을 지지 않습니다. 사용 전 충분한 테스트를 권장합니다.

---

*마지막 업데이트: 2024년 12월*