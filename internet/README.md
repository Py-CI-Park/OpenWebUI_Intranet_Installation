# internet 폴더 가이드 (온라인 준비)

> **Commit:** cc474605d12a90846b32553c9f378bad4de47fb0  
> **Branch:** main  
> **역할:** 인터넷 연결이 가능한 PC에서 폐쇄망 설치에 필요한 패키지 번들을 만드는 단계

---

## 주요 스크립트

| 파일 | 설명 |
|---|---|
| `download_packages.bat` | Open WebUI 및 의존성 패키지를 다운로드하고, 오프라인 설치 번들 ZIP(`openwebui_intranet_package_*.zip`)을 생성 |

---

## 요구사항 (온라인 PC)

- Windows 10/11 혹은 Windows Server  
- Python 3.8+ (64bit) 및 `python`/`pip` PATH 인식  
- 인터넷 연결 필수, PowerShell 사용 가능  
- 관리자 권한은 선택 사항(로그에서 알림)

---

## 동작 흐름 (`download_packages.bat`)

1. **Python 확인**: 존재하지 않으면 종료.  
2. **pip 업그레이드**: `pip`와 `setuptools>=70`/`wheel`을 최신화하여 Python 3.12 sdists도 빌드 가능하게 준비.  
3. **다운로드 디렉터리 생성**: `%CD%\openwebui_packages`를 새로 만들고 기존 내용은 제거.  
4. **패키지 다운로드**: `pip download open-webui`로 모든 의존성까지 내려받고, 추가로 `pip/setuptools/wheel`도 오프라인 용도로 저장.  
5. **ZIP 번들 생성**: `openwebui_intranet_package_YYYYMMDD_HHMMSS.zip` 생성 후 경로와 크기 출력.  
6. **다음 단계 안내**: ZIP을 폐쇄망 PC로 옮기고 `intranet` 스크립트로 설치·실행하라고 안내.

**산출물**  
- `openwebui_packages/` : 오프라인 설치에 사용할 whl/tar.gz 캐시  
- `openwebui_intranet_package_*.zip` : 패키지 폴더를 묶은 전달용 압축 파일

---

## 사용 예시

```bat
cd internet
download_packages.bat
```
- 완료 후 생성된 `openwebui_intranet_package_*.zip`을 폐쇄망 PC로 복사합니다.

---

## 자주 묻는 질문

- **pip 업그레이드 실패**: 네트워크/프록시 확인 후 재실행.  
- **압축 생성 실패**: `openwebui_packages` 내 파일을 확인하고 `Compress-Archive` 오류 메시지를 검토.  
- **Python 인식 불가**: PATH 설정을 확인하고 64bit Python 3.8+를 설치한 뒤 재실행.  
- **패키지 크기**: 네트워크/버전 상황에 따라 수백 MB~수 GB까지 변동 가능.  
