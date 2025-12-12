# intranet 폴더 가이드 (오프라인 설치/실행)

> **Commit:** cc474605d12a90846b32553c9f378bad4de47fb0  
> **Branch:** main  
> **역할:** 폐쇄망(오프라인) 환경에서 Open WebUI를 설치하고 실행하는 배치 스크립트 제공

---

## 주요 스크립트

| 파일 | 설명 |
|---|---|
| `install_openwebui.bat` | 오프라인 패키지(.whl/.tar.gz) 또는 `openwebui_intranet_package_*.zip`을 찾아 venv를 만들고 Open WebUI를 설치 |
| `run_openwebui.bat` | 설치된 venv를 활성화 후 Open WebUI를 실행(기본 포트 8080, 인자/환경변수로 변경 가능) |

---

## 요구사항 (폐쇄망 PC)

- Windows 10/11 혹은 Windows Server  
- Python 3.x 64bit (휠 파일의 cp 태그와 일치해야 함, 예: cp312 → Python 3.12)  
- 인터넷 불필요, PowerShell로 압축 해제 가능  
- 관리자 권한은 선택 사항(방화벽 규칙 추가 시 필요할 수 있음)

---

## 설치 플로우 (`install_openwebui.bat`)

1. **패키지 위치 자동 탐색**  
   - 인자 경로의 폴더/ZIP, 현재/상위 디렉터리의 `openwebui_packages/`, `internet` 폴더 내 ZIP 등을 우선순위로 검색.  
   - ZIP만 있으면 임시 폴더로 자동 압축 해제.  
2. **Python/아키텍처 확인**  
   - 64bit 여부와 wheel의 cp 태그(cp312 등)와 Python 버전 일치 여부 검사.  
3. **설치 경로 결정**  
   - 기본 `C:\OpenWebUI`, 권한 문제 시 `%LocalAppData%\OpenWebUI`로 대체.  
4. **venv 생성·활성화**  
   - 없으면 새로 생성, 있으면 재사용.  
5. **오프라인 설치**  
   - `--no-index --find-links`로 `pip/setuptools/wheel` 후 `open-webui` 설치.  
6. **실행 스크립트 작성**  
   - `start_openwebui.bat` 생성(기본 host 0.0.0.0, port 8080).  
7. **방화벽 규칙 시도(선택적)**  
   - `netsh advfirewall ... localport=8080` 추가 시도.

**산출물**  
- 설치 경로: `C:\OpenWebUI` (또는 `%LocalAppData%\OpenWebUI`)  
- 가상환경: `venv/`  
- 실행 스크립트: `start_openwebui.bat`

---

## 실행 플로우 (`run_openwebui.bat`)

1. **venv 확인/활성화**: 미설치 시 오류 안내.  
2. **포트 설정**: 인자 2번째 값 또는 `OPENWEBUI_PORT`, 기본 8080.  
3. **실행 경로**: 기본 `C:\OpenWebUI`, 없으면 `%LocalAppData%\OpenWebUI` 재시도.  
4. **실행**: `start_openwebui.bat`가 있으면 이를 호출, 없으면 직접 `open-webui serve --host 0.0.0.0 --port <PORT>` 실행.

**브라우저 접속**: `http://localhost:<PORT>` (기본 8080)

---

## 사용 예시

```bat
:: 패키지 ZIP 또는 폴더를 이미 같은 경로에 둔 경우
intranet\install_openwebui.bat

:: 패키지 폴더를 직접 지정
intranet\install_openwebui.bat "D:\temp\openwebui_packages"

:: 실행 (포트 9000으로 변경)
intranet\run_openwebui.bat "" 9000
```

---

## 문제 해결 팁

- **패키지 미검출**: 인자에 패키지 폴더를 직접 지정하거나 ZIP 이름이 `openwebui_intranet_package_*.zip`인지 확인.  
- **Python 불일치**: wheel 이름의 cp 태그(예: cp312)와 동일한 버전의 64bit Python을 설치 후 재시도.  
- **권한 문제**: `C:\OpenWebUI` 생성/쓰기 실패 시 스크립트가 `%LocalAppData%`로 자동 대체.  
- **포트 충돌**: `run_openwebui.bat "" 9000` 또는 `set OPENWEBUI_PORT=9000` 후 실행.  
- **방화벽**: 필요 시 관리자 권한으로 `netsh advfirewall firewall add rule name="Open Web UI" dir=in action=allow protocol=TCP localport=8080`.
