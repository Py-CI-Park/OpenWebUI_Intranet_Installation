# docs 폴더 가이드

> **Commit:** cc474605d12a90846b32553c9f378bad4de47fb0  
> **Branch:** main  
> **역할:** 프로젝트 전반 사용법과 설치 흐름을 설명하는 문서 모음(오프라인/폐쇄망 설치를 빠르게 파악할 때 참고)

---

## 파일 구성

| 파일 | 설명 |
|---|---|
| `usage_guide.md` | 초기 배포용 사용 가이드. 인터넷/폐쇄망 단계별 설치·실행 흐름을 요약한 문서(일부 한글이 깨져 있어 아래 요약을 함께 참고). |

---

## `usage_guide.md` 핵심 요약

- **목적:** 인터넷 차단 환경에서 Open WebUI를 설치·실행하는 절차를 한눈에 안내.  
- **구성:**  
  - 인터넷 PC: `internet/download_packages.bat`로 패키지 다운로드 → `openwebui_intranet_package_YYYYMMDD_HHMMSS.zip` 생성.  
  - 폐쇄망 PC: 압축 해제 후 `intranet/install_openwebui.bat`로 오프라인 설치, `intranet/run_openwebui.bat`로 실행.  
  - 기본 포트 8080, 필요 시 인자 또는 환경 변수(`OPENWEBUI_PORT`)로 변경.  
  - 방화벽 예시(`netsh advfirewall ...`)와 Python/포트 충돌 등 자주 발생하는 오류 해결 팁 제공.

---

## 빠른 시작 명령 예시

- 온라인(패키지 준비): `internet\download_packages.bat`  
- 오프라인 설치: `intranet\install_openwebui.bat`  
- 오프라인 실행: `intranet\run_openwebui.bat`  

---

## 개선 메모

- `usage_guide.md`는 일부 한글이 깨진 상태이므로, 필요 시 UTF-8 인코딩으로 재저장하거나 루트 README 및 각 폴더 README의 최신 내용을 우선 참고하세요.
