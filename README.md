# OpenWebUI_Intranet_Installation

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![Windows](https://img.shields.io/badge/platform-windows-blue.svg)](https://www.microsoft.com/windows)

## 프로젝트 소개

사내/폐쇄망 환경에서 Open Web UI를 안정적으로 설치·운영하기 위한 오프라인 설치 패키지와 스크립트를 제공합니다.

### 주요 특징
- 100% 오프라인 설치: 인터넷 없이 설치 가능
- 자동 의존성 패키징: 온라인 PC에서 한 번에 다운로드/압축
- ASCII 전용 배치 스크립트: 인코딩/코드페이지 오류 방지
- 버전·아키텍처 검증: 64bit Python 및 cp 태그(cp312 등) 자동 확인
- 간편 실행: 시작 배치와 실행 런처 제공

---

## 빠른 시작

### 1) 온라인 PC에서 패키지 다운로드
```bat
cd internet
download_packages.bat
```
- 결과물: `internet\openwebui_packages\` 폴더와 `openwebui_intranet_package_YYYYMMDD_HHMMSS.zip`

### 2) 파일을 폐쇄망으로 이동
다음 파일들을 폐쇄망 PC로 복사합니다.
- `openwebui_intranet_package_YYYYMMDD_HHMMSS.zip` 또는 압축 해제한 `openwebui_packages/`
- `intranet\install_openwebui.bat`
- `intranet\run_openwebui.bat`

### 3) 폐쇄망에서 설치
옵션 A: ZIP 자동 추출(권장)
```bat
intranet\install_openwebui.bat
```
옵션 B: 압축을 직접 풀었다면 폴더 경로 전달
```bat
intranet\install_openwebui.bat "D:\path\to\openwebui_packages"
```
- 기본 설치 경로: `C:\OpenWebUI` (권한이 없으면 `%LocalAppData%\OpenWebUI`로 자동 대체)
- venv 생성 → 로컬 휠로만 설치(`--no-index`) → 시작 배치 생성
- 8080 방화벽 허용 규칙 추가 시도
- 휠 cp 태그(cp312 등)와 현재 Python 버전 불일치 시 오류 안내

### 4) 실행
옵션 A: 시작 스크립트
```bat
C:\OpenWebUI\start_openwebui.bat
```
옵션 B: 런처 사용(경로/포트 지정 가능)
```bat
intranet\run_openwebui.bat [설치경로] [포트]
intranet\run_openwebui.bat "C:\OpenWebUI" 9000
```
또는 환경변수로 지정
```bat
set OPENWEBUI_PORT=9000
intranet\run_openwebui.bat
```
기본 접속: http://localhost:8080

---

## 디렉터리 구조
```
OpenWebUI_Intranet_Installation/
├─ internet/                  # 온라인(다운로드) 환경
│  └─ download_packages.bat   # 의존성 일괄 다운로드 스크립트
├─ intranet/                  # 폐쇄망(설치/실행) 환경
│  ├─ install_openwebui.bat   # 오프라인 설치 스크립트(ASCII 전용)
│  └─ run_openwebui.bat       # 실행 런처(ASCII 전용)
└─ docs/
   └─ usage_guide.md          # 상세 사용 가이드
```

---

## 요구 사항
- OS: Windows 10/11 또는 Windows Server 2016+
- Python: 64bit 권장, 휠 cp 태그와 동일 버전(예: cp312 → Python 3.12)
- 디스크: 최소 2GB 여유 공간

---

## 자주 묻는 질문(요약)
- Python을 찾지 못함: Python 3.x(64bit) 설치 및 PATH 등록 확인
- 버전 불일치: 휠 cp 태그(cp312 등)와 현재 Python 버전(메이저·마이너) 일치 필요
- 8080 포트 점유: 다른 포트로 실행(`run_openwebui.bat "" 9000`)
- 인코딩 오류: 스크립트는 ASCII만 사용하므로 코드페이지 오류 없이 동작

자세한 사용법과 문제 해결은 `docs/usage_guide.md`를 참고하세요.

---

## 라이선스
MIT License. Open Web UI 프로젝트 라이선스는 해당 저장소를 참고하세요.

