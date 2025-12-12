# Open WebUI 오프라인 설치 스크립트 개선 보고서

> **Commit 기준:** e48a38510f9fb4cc2c695972968f2c30a8f69f67  
> **Branch:** main  
> **범위:** Archive(Used/Try), internet, intranet 폴더 내 배치 스크립트 전반

---

## 목차

1. 개요
2. 현재 구조/흐름 요약
3. 공통 개선 포인트
4. 영역별 세부 검토
   - internet (온라인 패키지 준비)
   - intranet (오프라인 설치/실행)
   - Archive/Used_Version (pip-style, install/run 통합)
   - Archive/Try_Version_Update (pip-style v5, 번들 흐름)
5. 보안·운영 관점 권장사항
6. 업데이트 계획(우선순위/단계)

---

## 1) 개요

- 목적: 폐쇄망용 Open WebUI 설치 스크립트의 신뢰성·재현성·운영 편의성 향상.
- 방법: 폴더별 코드 리뷰 후, 개선 항목과 실행 계획 제안.

---

## 2) 현재 구조/흐름 요약

- **internet/download_packages.bat**  
  - 온라인 PC에서 `pip download open-webui`로 패키지 캐시(`openwebui_packages/`) 생성 후 ZIP(`openwebui_intranet_package_*.zip`)으로 묶어 전달.
- **intranet/install_openwebui.bat, run_openwebui.bat**  
  - 패키지 ZIP/폴더 자동 탐색 → venv 생성/활성화 → `--no-index --find-links`로 오프라인 설치 → 실행 스크립트 작성 및 기동.
- **Archive/Used_Version**  
  - `prepare/install/run/install_and_run` 네 가지 pip-style 배치(버전 핀 미흡, 개선 섹션 없음).  
  - README는 최신 main 메타데이터로 동기화됨.
- **Archive/Try_Version_Update**  
  - v5 흐름(prepare/install/run) + 오프라인 번들 흐름(download/install/run) 동시 보유.  
  - 일부 배치 파일명이 공백·괄호를 포함(`...v5 (1).bat`), 인코딩 깨짐(run_openwebui.bat 등) 존재.

---

## 3) 공통 개선 포인트

- **버전 핀·무결성**: open-webui 및 주요 의존성 버전 고정 + SHA256 체크섬 생성/검증.
- **로그/디버깅**: 모든 스크립트에 로그 파일 경로 명시, 실패 시 로그 출력.
- **Python 버전/아키텍처 검증**: cp 태그와 맞는 64bit Python 필수 확인(3.12/3.11 등).
- **경로/인자 안전성**: 공백·괄호 없는 파일명/경로 사용 권장, 경로 유효성 검사 추가.
- **인코딩 통일**: ASCII 또는 UTF-8(BOM)로 저장, 한글 깨짐 제거.
- **설정 외부화**: 포트/데이터 경로/버전 등을 config(.ini/.env)로 분리 가능성 검토.
- **오프라인 보장**: `PIP_NO_INDEX=1` 또는 `--no-index` 일관 적용, 온라인 fallback 제거.

---

## 4) 영역별 세부 검토

### A. internet (download_packages.bat)
- **버전 고정**: `open-webui==<target>` 지정.  
- **wheel 우선**: `--only-binary=:all:` 시도 후 실패 시 소스 병행.  
- **플랫폼 지정**: 필요 시 `--platform win_amd64 --python-version 3.12` 등으로 재현성 강화.  
- **requirements 스냅샷**: `pip freeze > packages/requirements_resolved.txt` 포함.  
- **체크섬**: ZIP에 대해 `certutil -hashfile ... SHA256` 생성.  
- **로그 파일**: `download.log`에 단계별 출력, 실패 시 즉시 표시.

### B. intranet (install/run)
- **오프라인 강제**: `set PIP_NO_INDEX=1` 후 `pip install --no-index --find-links ...`.  
- **wheel 필수 검증**: `*.whl` 없으면 즉시 경고/중단.  
- **디스크 여유 확인**: 5GB 이상 권고 메시지.  
- **데이터 경로 설정**: `OPENWEBUI_DATA_DIR` 기본값을 install 스크립트에서 지정/출력.  
- **포트 충돌 처리**: 8080 사용 중이면 대체 포트 안내 및 자동 선택 옵션(예: 8081).  
- **로그 파일**: `install.log`/`run.log` 생성, 오류 시 tail 출력.  
- **방화벽 규칙**: 관리자 권한 아닐 때 건너뛰고 경고 메시지.

### C. Archive/Used_Version (pip-style)
- **버전 핀 추가**: 준비 스크립트에서 목표 태그 지정(`OPENWEBUI_VERSION=v0.6.4` 등).  
- **체크섬/로그**: 준비 ZIP에 SHA256, 설치 시 `install.log`.  
- **재실행 안전성**: venv 존재 시 삭제/유지 선택.  
- **패키지 완전성 검사**: 필수 휠(wheel/setuptools/open-webui) 존재 여부 확인.  
- **인코딩**: 메시지/주석 ASCII 정리.

### D. Archive/Try_Version_Update (v5 흐름)
- **파일명 정리**: `(1)` 및 공백 제거(`prepare_openwebui_pip_style_v5.bat` 등).  
- **인코딩 복원**: `run_openwebui.bat`, `install_openwebui_offline.bat`에 깨진 한글을 ASCII/UTF-8로 수정.  
- **버전/휠 탐색 개선**: open-webui 버전 후보 리스트 외에도 해시 검증 추가.  
- **로그/체크섬**: `prep.log`, `install.log`, 최종 ZIP의 SHA256 생성.  
- **Ollama 확인**: run 스크립트에서 미설치 시 명확히 안내.  
- **중복 로직 통합**: 오프라인 번들 흐름과 v5 흐름의 공통 부분(venv 생성/설치)을 함수 레이블로 정리.

---

## 5) 보안·운영 관점 권장사항

- **신뢰된 소스 해시 관리**: open-webui 소스 ZIP 및 패키지 해시 목록을 repo에 기록.  
- **검증 가능한 릴리스**: 릴리스 노트에 사용 버전/해시/패키지 목록 첨부.  
- **오류 코드/로그 표준화**: 실패 시 명확한 종료 코드와 로그 위치 출력.  
- **CI 검증**(선택): 온라인 환경에서 `prepare/install/run` 시나리오를 GitHub Actions 등으로 주기적 테스트.

---

## 6) 업데이트 계획

**Phase 1 (신속 개선)**
- internet: open-webui 버전 핀, `--only-binary=:all:` 적용, SHA256 생성, `download.log` 추가.  
- intranet: `PIP_NO_INDEX=1`, 필수 휠 검사, `install.log`, 포트 충돌 안내, 데이터 경로 기본값 출력.

**Phase 2 (품질 강화)**
- Archive/Used_Version: 버전 핀·체크섬·재실행 안전성·인코딩 정리.  
- Archive/Try_Version_Update: 파일명 정리, 인코딩 복원, 해시 검증, Ollama 체크, 로그 확충.  
- 공통: config(.ini/.env) 지원으로 경로/포트/버전 외부화.

**Phase 3 (운영/재현성)**
- 해시/패키지 목록을 릴리스 노트 형태로 문서화.  
- 선택적으로 CI로 온라인 준비 → 오프라인 설치 시나리오 검증.  
- 방화벽/디스크 체크, 포트 자동 선택 옵션을 모든 실행 스크립트에 일관되게 반영.

완료 후 README(루트/각 폴더)와 보고서를 업데이트해 변경사항과 사용법을 재정리합니다.
