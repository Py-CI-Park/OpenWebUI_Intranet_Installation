# Open WebUI 폐쇄망(오프라인) 설치 자동화 프로젝트 – Try_Version_Update

> **Commit:** f07eb933e25a345f7079d1a105a868fe2b0b68f1  
> **Branch:** feature/used_version  
> **프로젝트 목적:** 인터넷이 차단된 폐쇄망 환경에서 Open WebUI를 설치·실행하기 위한 여러 설치 플로우(오프라인 번들, pip 스타일 v5)를 실험하고 검증

---

## 목차

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

이 문서는 **폐쇄망(인터넷 차단) 환경**에서 Open WebUI를 설치하고 실행하기 위해 시도한 두 가지 흐름을 정리합니다.

- **오프라인 번들 흐름:** 온라인 PC에서 필요한 패키지를 다운로드하고 설치/실행 스크립트까지 포함된 ZIP 번들을 만들어 폐쇄망에 전달.
- **pip 스타일 v5 흐름:** 온라인 PC에서 소스와 패키지를 내려받아 `open-webui-pip-style.zip`으로 묶은 뒤, 폐쇄망에서 설치·실행.

### 핵심 문제

- 인터넷 접근 불가한 환경에서 모든 의존성을 확보해야 함
- Python 패키지 버전 호환성 및 바이너리(whl) 확보 필요
- 설치·실행 과정의 반복성과 안정성 확보

### 솔루션

1. 온라인 환경에서 필요한 자산(소스, 패키지, 스크립트)을 ZIP 번들로 제작
2. 폐쇄망으로 이동해 압축 해제 후 자동화된 배치 스크립트로 설치·실행

---

## 주요 기능

### 오프라인 번들 플로우

| 스크립트 | 실행 환경 | 주요 기능 |
|---------|----------|----------|
| `download_openwebui.bat` | 인터넷 환경 | Open WebUI 패키지 다운로드, 오프라인 설치/실행 스크립트 생성, 번들 ZIP 생성 |
| `install_openwebui_offline.bat` | 폐쇄망 환경 | 번들에 포함된 패키지로 오프라인 설치 |
| `run_openwebui.bat` | 폐쇄망 환경 | 설치된 Open WebUI 실행 (venv 필요) |

### pip 스타일 v5 플로우

| 스크립트 | 실행 환경 | 주요 기능 |
|---------|----------|----------|
| `prepare_openwebui_pip_style_v5 (1).bat` | 인터넷 환경 | 소스 및 패키지 다운로드 후 `open-webui-pip-style.zip` 생성 |
| `install_openwebui_pip_style_v5 (1).bat` | 폐쇄망 환경 | ZIP 해제 후 venv 생성 및 오프라인 설치 |
| `run_openwebui_pip_style_v5 (1).bat` | 폐쇄망 환경 | Ollama 확인 후 Open WebUI 실행 |

---

## 시스템 요구사항

### 공통 요구사항
- **OS:** Windows 10 이상 (PowerShell 사용 가능)
- **Python:** 3.8 이상 (venv 모듈 포함)
- **Ollama:** 설치 필요 (LLM 백엔드)
- **디스크 공간:** 최소 5GB 이상 권장

### 인터넷 환경(준비 단계)
- 안정적인 네트워크
- curl 사용 가능
- PowerShell 실행 권한

### 폐쇄망 환경(설치/실행 단계)
- PowerShell로 압축 해제 가능
- Python venv 생성 권한
- 관리자 권한은 선택적

---

## 스크립트 상세 분석

### 1. prepare_openwebui_pip_style_v5 (1).bat

**목적:** 온라인에서 소스와 모든 의존성을 내려받아 `open-webui-pip-style.zip`을 생성하는 준비 스크립트.

**주요 흐름**
1. **작업 경로 설정**: 인자 미지정 시 `%~dp0OpenWebUI_Prep` 사용, 로그 `prep.log` 작성.
2. **pip 업그레이드**: `python -m pip install --upgrade pip`.
3. **Open WebUI 소스 다운로드**: GitHub main 브랜치 ZIP (`open-webui-main.zip`, retry 3회, 재시작 `-C -` 지원).
4. **requirements 추출**: PowerShell `Expand-Archive`로 소스 압축 해제 후 `backend\requirements*.txt` 탐색.
5. **의존성 다운로드**: `pip download --prefer-binary -r requirements*.txt wheel setuptools` → `packages` 폴더에 whl/tar.gz 수집.
6. **Open WebUI 휠 확보**: 버전 후보 `0.6.4`, `0.5.3` 순회 후 성공 시 종료, 실패 시 소스 아카이브로 폴백.
7. **최종 ZIP 생성**: 소스 ZIP, 해제된 소스, 패키지 폴더를 `open-webui-pip-style.zip`으로 압축.
8. **에러 처리/로그**: 실패 시 `prep.log` 확인 안내.

**산출물 구조**
```
open-webui-pip-style.zip
├── open-webui-main.zip          # GitHub 원본
├── open-webui-main/             # 압축 해제 소스
│   └── backend/requirements*.txt
└── packages/                    # pip download 결과
    ├── open_webui-*.whl|tar.gz
    ├── wheel-*.whl
    ├── setuptools-*.whl
    └── 기타 의존성 *.whl
```

---

### 2. install_openwebui_pip_style_v5 (1).bat

**목적:** 폐쇄망에서 `open-webui-pip-style.zip`을 해제하고 venv에 오프라인 설치.

**주요 흐름**
1. **작업 경로 설정**: 기본 `%~dp0OpenWebUI`, 필요 시 첫 번째 인자로 변경 가능.
2. **ZIP 검증/해제**: `open-webui-pip-style.zip` 존재 확인 후 `Expand-Archive`로 강제 해제.
3. **가상환경 생성/활성화**: `python -m venv "%WORK_DIR%\venv"` → `Scripts\activate`.
4. **기본 도구 설치**: `pip install --no-index --find-links="%PACKAGE_DIR%" wheel setuptools`.
5. **Open WebUI 설치**: 버전 후보 `0.6.4`, `0.5.3` 순회 설치, 실패 시 일반 `open-webui` 설치로 폴백.
6. **출력**: 성공/실패 메시지와 `pause` 처리.

---

### 3. run_openwebui_pip_style_v5 (1).bat

**목적:** 설치된 환경에서 Ollama를 확인 후 Open WebUI 실행.

**주요 흐름**
1. **venv 확인/활성화**: 없으면 설치 스크립트 실행 요청.
2. **데이터 디렉터리**: `%WORK_DIR%\data` 생성, `OPENWEBUI_DATA_DIR` 설정.
3. **Ollama 확인**: `tasklist`로 `ollama.exe` 탐지, 없으면 새 CMD 창에서 `ollama serve` 시작 후 5초 대기.
4. **Open WebUI 실행**: `open-webui serve`, 종료는 수동(Ctrl+C).

---

### 4. download_openwebui.bat

**목적:** 온라인에서 오프라인 설치 번들(`openwebui_offline_package.zip`)을 생성하고, 설치/실행 배치까지 함께 만들어 폐쇄망에 전달.

**주요 흐름**
1. **네트워크/파이썬 확인**: `ping 8.8.8.8`으로 연결 확인, Python 버전 출력.
2. **작업 디렉터리 재생성**: `C:\OpenWebUI_Download` 비우고 `packages`, `venv` 생성.
3. **venv 생성/활성화**: 온라인 준비 전용 가상환경.
4. **pip 업그레이드**: 실패 시 경고 후 진행.
5. **Open WebUI 패키지 다운로드**: `pip download open-webui --dest packages`.
6. **추가 필수 패키지**: `pip download wheel setuptools`.
7. **오프라인 설치/실행 스크립트 자동 생성**: `install_openwebui_offline.bat`, `run_openwebui.bat`를 작업 디렉터리에 씀.
8. **최종 ZIP 생성**: `packages` + 두 스크립트를 `openwebui_offline_package.zip`으로 압축.

**산출물**
- `packages/` (whl/tar.gz)
- `install_openwebui_offline.bat`
- `run_openwebui.bat`
- `openwebui_offline_package.zip`

---

### 5. install_openwebui_offline.bat

**목적:** `packages` 폴더에 있는 whl들을 사용해 폐쇄망에서 Open WebUI를 설치.

**주요 흐름**
1. **작업/패키지 경로 확인**: 기본 `C:\OpenWebUI`, `packages` 존재 및 whl 유무 확인.
2. **Python 확인**: PATH에 Python이 없으면 종료.
3. **venv 생성/활성화**: `python -m venv "%WORK_DIR%\venv"` 후 `activate`.
4. **wheel/setuptools 설치**: `--no-index --find-links="%PACKAGE_DIR%"`.
5. **open-webui 설치/검증**: 동일한 옵션으로 설치 후 `pip show open-webui` 확인.
6. **다음 단계 안내**: `run_openwebui.bat` 실행 위치 표시.

---

### 6. run_openwebui.bat

**목적:** 오프라인 설치된 Open WebUI 실행.

**주요 흐름**
1. **venv/설치 확인**: 존재하지 않으면 `install_openwebui_offline.bat` 실행 안내.
2. **venv 활성화**: 실패 시 재설치 안내.
3. **Open WebUI 실행**: `open-webui serve --host 0.0.0.0 --port 8080`, 브라우저 접속 주소 출력.
4. **종료**: Ctrl+C로 수동 종료.

---

## 설치 및 사용 가이드

### A. pip 스타일 v5 플로우

1. **온라인에서 패키지 준비**
   ```batch
   # 기본 경로 사용 예시
   prepare_openwebui_pip_style_v5 (1).bat
   ```
   - 결과: `%~dp0OpenWebUI_Prep\open-webui-pip-style.zip`

2. **폐쇄망으로 ZIP 이동**
   - `open-webui-pip-style.zip`을 폐쇄망 PC의 원하는 작업 경로(예: `C:\OpenWebUI\`)로 복사.

3. **폐쇄망에서 오프라인 설치**
   ```batch
   install_openwebui_pip_style_v5 (1).bat
   ```
   - venv 생성 후 open-webui 설치.

4. **폐쇄망에서 실행**
   ```batch
   run_openwebui_pip_style_v5 (1).bat
   ```
   - Ollama 기동 여부 확인 후 Open WebUI 서버 시작.
   - 브라우저 접속: `http://localhost:8080`

**예상 소요**: 준비 10~30분(네트워크 의존), 설치 3~10분(디스크/CPU 의존)

---

### B. 오프라인 번들 플로우

1. **온라인에서 번들 생성**
   ```batch
   download_openwebui.bat
   ```
   - 생성물: `packages/`, `install_openwebui_offline.bat`, `run_openwebui.bat`, `openwebui_offline_package.zip`

2. **폐쇄망으로 이동**
   - `openwebui_offline_package.zip` 또는 생성된 개별 파일을 폐쇄망 PC로 복사 후 압축 해제.

3. **폐쇄망에서 설치**
   ```batch
   install_openwebui_offline.bat
   ```
   - `packages` 폴더 내 whl로 오프라인 설치.

4. **폐쇄망에서 실행**
   ```batch
   run_openwebui.bat
   ```
   - 브라우저 접속: `http://localhost:8080`

**예상 소요**: 번들 생성 5~15분, 설치 3~8분

---

## 아키텍처 및 워크플로우

### pip 스타일 v5 흐름
```
온라인 PC
└─ prepare_openwebui_pip_style_v5 (1).bat
      ├─ GitHub 소스 ZIP 다운로드
      ├─ requirements 기반 패키지 다운로드
      ├─ open-webui 휠(0.6.4/0.5.3) 확보
      └─ open-webui-pip-style.zip 생성
                 │ USB/파일 전송
폐쇄망 PC
└─ install_openwebui_pip_style_v5 (1).bat
      ├─ ZIP 해제
      ├─ venv 생성/활성화
      └─ 오프라인 open-webui 설치
└─ run_openwebui_pip_style_v5 (1).bat
      ├─ Ollama 확인/시작
      └─ Open WebUI serve
```

### 오프라인 번들 흐름
```
온라인 PC
└─ download_openwebui.bat
      ├─ venv 준비 및 pip upgrade
      ├─ open-webui + wheel/setuptools 다운로드
      ├─ install/run 스크립트 자동 생성
      └─ openwebui_offline_package.zip 생성
                 │ USB/파일 전송
폐쇄망 PC
└─ install_openwebui_offline.bat
      ├─ venv 생성/활성화
      └─ 오프라인 설치
└─ run_openwebui.bat
      └─ Open WebUI serve
```

---

## 디렉터리 구조 예시

### 온라인 준비 후(pip 스타일)
```
OpenWebUI_Prep/
├── open-webui-main.zip
├── open-webui-main/
│   └── backend/requirements*.txt
├── packages/
│   ├── *.whl / *.tar.gz
└── open-webui-pip-style.zip
```

### 폐쇄망 설치 후(pip 스타일)
```
OpenWebUI/
├── open-webui-pip-style.zip
├── open-webui-main/
│   └── packages/
├── packages/               # 설치용 패키지
├── venv/
│   ├── Scripts/python.exe
│   └── Scripts/open-webui.exe
└── data/                   # 실행 시 생성
    ├── webui.db
    └── uploads/
```

### 오프라인 번들 생성 후
```
OpenWebUI_Download/
├── packages/
│   └── *.whl
├── install_openwebui_offline.bat
├── run_openwebui.bat
└── openwebui_offline_package.zip
```

---

## 코드 목적 분석

- **보안/폐쇄망 대응**: 인터넷 없이도 설치 가능한 모든 자산을 미리 확보.
- **버전 호환성 실험**: open-webui 0.6.4, 0.5.3 우선 설치 후 폴백하도록 구성.
- **자동화**: 준비·설치·실행 전 과정을 배치 스크립트로 재현 가능하게 만듦.
- **운영 편의**: Ollama 자동 기동, 데이터 디렉터리 자동 생성 등 실행 편의 제공.

---

## 개선 제안사항

### Critical
1. **인코딩 정비**: `run_openwebui.bat`, `install_openwebui_offline.bat`에 한글이 깨진 부분이 있어 UTF-8(BOM) 또는 ASCII 영어 메시지로 통일 필요.
2. **버전 핀 고도화**: `prepare/install_*_v5`에서 명시 버전 리스트(0.6.4/0.5.3)에 대한 해시 검증(SHA256) 추가.
3. **오류 로그 출력**: `install_*` 스크립트에 `> install.log 2>&1` 후 실패 시 로그 경로 안내.
4. **기존 venv 처리**: 재설치 시 기존 venv 발견하면 삭제/유지 여부를 사용자 선택으로 처리.
5. **Ollama 필수 확인**: `run_*`에서 Ollama 미설치 시 다운로드 안내 메시지 추가.

### Important
1. **진행률 안내**: `[1/7] ...` 형태로 현재 단계 표기(준비/설치/실행 공통).
2. **디스크 여유 검증**: 5GB 미만 시 경고 출력.
3. **환경 변수 검증**: 사용자 인자(작업 경로) 유효성 검사 추가.
4. **포트 충돌 처리**: 8080 사용 중이면 대체 포트 안내 및 `OPENWEBUI_PORT` 예시 제공.
5. **로그 타임스탬프**: `prep.log` 등 로그에 시각 포함.

### Nice to Have
1. **config 파일 지원**: 경로/포트/버전 등을 ini로 분리.
2. **업데이트 스크립트**: `pip install --upgrade --no-index ...`로 패키지만 갱신.
3. **체크섬 검증**: `certutil -hashfile ... SHA256`으로 전달 ZIP 무결성 확인.
4. **간단 메뉴 UI**: 설치/실행/업데이트/삭제 선택 메뉴.
5. **오프라인 문서 동봉**: HTML/PDF 매뉴얼을 번들에 포함.

---

## 문제 해결

- **ZIP 없음/손상**: `open-webui-pip-style.zip` 또는 `openwebui_offline_package.zip` 경로 확인, 재압축 시 `-Force` 옵션 활용.
- **packages 폴더 비어 있음**: `pip download` 성공 여부 로그 확인 후 다시 실행.
- **Python 미검출**: `where python`으로 PATH 확인, 3.8+ 설치 후 재시도.
- **venv 활성화 실패**: 기존 venv 삭제 후 재생성, 관리자 PowerShell에서 실행 정책 `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` 적용.
- **포트 8080 충돌**: `set OPENWEBUI_PORT=8081` 후 `open-webui serve`.
- **Ollama 미실행**: `ollama serve` 수동 실행 후 `run_*` 재시도.

---

## 결론

이 폴더는 **오프라인 번들**과 **pip 스타일 v5** 두 가지 흐름을 비교·검증하기 위한 실험용 자산을 담고 있습니다. 각각의 스크립트를 통해 차단망에서도 Open WebUI를 신뢰성 있게 설치·실행할 수 있으며, 추가 개선 사항을 적용하면 재현성과 안정성을 더 높일 수 있습니다.

---

**작성일**: 2025-12-12  
**버전**: 1.0.0  
**작성자**: Codex (문서화)  
**대상 커밋**: f07eb933e25a345f7079d1a105a868fe2b0b68f1
