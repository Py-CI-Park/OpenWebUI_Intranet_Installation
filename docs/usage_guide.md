# Open Web UI 사용 가이드

## 개요

이 가이드는 인터넷이 차단된 폐쇄망 환경에서 Open Web UI를 설치하고 실행하는 방법을 설명합니다.

### 목표
- 온라인 PC에서 의존성 일괄 다운로드
- 폐쇄망 PC에서 100% 오프라인 설치
- 인코딩 문제 없이 안정적으로 실행

### 프로젝트 구조
```
OpenWebUI_Intranet_Installation/
├─ internet/                    # 온라인(다운로드) 환경
│  └─ download_packages.bat     # 의존성 다운로드 스크립트
├─ intranet/                    # 폐쇄망(설치/실행) 환경
│  ├─ install_openwebui.bat     # 오프라인 설치 스크립트(ASCII)
│  └─ run_openwebui.bat         # 실행 런처(ASCII)
└─ docs/
   └─ usage_guide.md            # 본 가이드
```

---

## STEP 1: 온라인에서 패키지 다운로드

### 사전 준비
- Windows 10/11 또는 Windows Server
- Python 3.8+ 설치(64bit 권장)
- 인터넷 연결 가능

### 다운로드 절차
1) `internet/download_packages.bat` 실행
2) 스크립트는 다음을 자동 수행합니다.
   - Python 확인 및 pip 업그레이드
   - Open Web UI 및 의존성 휠/소스 패키지 다운로드
   - 패키지 폴더(`openwebui_packages/`)와 압축본(`openwebui_intranet_package_YYYYMMDD_HHMMSS.zip`) 생성

### 결과물
- `openwebui_intranet_package_YYYYMMDD_HHMMSS.zip`: 폐쇄망 설치용 압축 파일
- `openwebui_packages/`: 다운로드된 패키지 폴더(선택적으로 사용)

---

## STEP 2: 폐쇄망으로 파일 이동
다음 파일을 이동합니다.
- `openwebui_intranet_package_YYYYMMDD_HHMMSS.zip` 또는 압축 해제한 `openwebui_packages/`
- `intranet/install_openwebui.bat`
- `intranet/run_openwebui.bat`

이동 매체: USB 메모리, 보안 반출 체계 등

---

## STEP 3: 폐쇄망에서 설치

### 사전 요구사항
- Windows 10/11 또는 Windows Server
- Python 3.x(64bit) 설치 권장
  - 다운로드된 휠의 cp 태그(cp312 등)와 동일한 메이저/마이너 버전 필요
  - 예: cp312 → Python 3.12 (64bit)

### 설치 방법
옵션 A: ZIP 자동 추출(권장)
```bat
intranet\install_openwebui.bat
```
옵션 B: 압축을 수동으로 풀었다면 폴더 경로 전달
```bat
intranet\install_openwebui.bat "D:\path\to\openwebui_packages"
```

설치 스크립트가 수행하는 작업
- 패키지 폴더/ZIP 자동 탐지 및 필요 시 자동 압축 해제
- 설치 경로 선택: 기본 `C:\OpenWebUI` (권한 없으면 `%LocalAppData%\OpenWebUI`)
- Python venv 생성 및 활성화
- 로컬 패키지로만 설치(`--no-index`, `--find-links`)
- 시작 배치(`C:\OpenWebUI\start_openwebui.bat`) 생성
- 방화벽 규칙(8080) 추가 시도
- 64bit 및 cp 태그 버전 호환성 검증

예상 소요 시간: 5~15분(시스템 성능에 따라 상이)

---

## STEP 4: Open Web UI 실행

### 실행 방법(택 1)
1) 시작 배치로 실행
```bat
C:\OpenWebUI\start_openwebui.bat
```
2) 런처 사용(경로/포트 지정 가능)
```bat
intranet\run_openwebui.bat [설치경로] [포트]
intranet\run_openwebui.bat "C:\OpenWebUI" 9000
```
또는 환경변수로 포트 지정
```bat
set OPENWEBUI_PORT=9000
intranet\run_openwebui.bat
```

기본 접속 주소: http://localhost:8080

---

## 기본 설정
- 포트: 8080 (변경 가능)
- 호스트: 0.0.0.0 (모든 인터페이스 바인딩)

### 방화벽 규칙(8080) 추가
설치 스크립트가 자동으로 시도합니다. 수동 추가가 필요할 경우:
```powershell
netsh advfirewall firewall add rule name="Open Web UI" dir=in action=allow protocol=TCP localport=8080
```

---

## 문제 해결

### 1) Python을 찾지 못함
증상: `'python'은(는) 내부 또는 외부 명령이 아닙니다.`
- Python 3.x(64bit) 설치 여부 확인
- PATH 환경변수에 Python이 등록되어 있는지 확인
- `python --version`으로 확인

### 2) 파이썬 버전/아키텍처 불일치
증상: 설치 스크립트가 cp 태그 불일치를 보고함 (예: cp312 필요)
- 다운로드한 휠의 cp 태그와 동일한 메이저/마이너 버전의 64bit Python 설치

### 3) 8080 포트 충돌
증상: `Address already in use: 8080`
```bat
netstat -ano | findstr :8080
taskkill /PID <PID> /F
```
또는 다른 포트로 실행: `run_openwebui.bat "" 9000`

### 4) 인코딩/코드페이지 오류 메시지
증상: 배치 출력이 깨지며 `'...은(는) 내부 또는 외부 명령...'`
- 새 스크립트는 ASCII 전용이므로 인코딩 문제로 인한 실행 오류가 발생하지 않습니다.
- 여전히 문제가 있으면 파일을 메모장으로 열어 특수문자가 섞이지 않았는지 확인

---

## 시스템 요구사항
- OS: Windows 10/11, Windows Server 2016+
- CPU: 2코어 이상 권장
- 메모리: 4GB 이상 권장
- 디스크: 2GB 이상 여유 공간
- Python: 64bit, 휠 cp 태그와 버전 일치

---

## 백업/운영 팁
- 데이터/설정 백업 경로는 Open Web UI 문서를 참고하세요.
- 포트 변경 시 방화벽 규칙도 함께 조정합니다.

---

## 참고 자료
- Open Web UI: https://openwebui.com
- GitHub: https://github.com/open-webui/open-webui
- 공식 문서: https://docs.openwebui.com

