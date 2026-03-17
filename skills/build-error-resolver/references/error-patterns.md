# 에러 유형별 해결 전략

## 1. 의존성 에러
```
증상:
- ModuleNotFoundError
- Cannot find module
- Package not found

진단:
1. package.json / requirements.txt / pom.xml 확인
2. lock 파일 상태 확인
3. node_modules / venv / .m2 상태 확인

해결:
- npm install / pip install / mvn install
- lock 파일 삭제 후 재설치
- 버전 충돌 해결
```

## 2. 타입 에러
```
증상:
- Type 'X' is not assignable to type 'Y'
- TypeError
- ClassCastException

진단:
1. 타입 정의 파일 확인
2. 인터페이스/클래스 정의 확인
3. 타입 추론 흐름 추적

해결:
- 타입 정의 수정
- 타입 캐스팅 추가
- 제네릭 타입 명시
```

## 3. 구문 에러
```
증상:
- SyntaxError
- Unexpected token
- Parse error

진단:
1. 에러 발생 라인 확인
2. 괄호/중괄호/세미콜론 매칭 확인
3. 문법 버전 호환성 확인

해결:
- 구문 오류 수정
- 언어 버전 설정 확인
- 린터 실행으로 추가 오류 확인
```

## 4. 런타임 에러 (빌드 시)
```
증상:
- NullPointerException
- undefined is not a function
- AttributeError

진단:
1. 스택 트레이스 분석
2. 변수 초기화 상태 확인
3. 외부 의존성 상태 확인

해결:
- null 체크 추가
- 초기화 순서 수정
- 환경 변수/설정 확인
```

## 5. 환경 설정 에러
```
증상:
- JAVA_HOME not set
- Python version mismatch
- Node version incompatible

진단:
1. 환경 변수 확인
2. 버전 요구사항 확인
3. PATH 설정 확인

해결:
- 환경 변수 설정
- 버전 매니저 사용 (nvm, pyenv, sdkman)
- Docker 환경 사용
```

---

## 프레임워크별 에러 패턴

### Python/FastAPI
| 에러 | 원인 | 해결 |
|------|------|------|
| `ModuleNotFoundError` | 패키지 미설치 | `pip install` |
| `ImportError: circular` | 순환 참조 | 임포트 구조 수정 |
| `pydantic ValidationError` | 스키마 불일치 | 모델 정의 확인 |

### JavaScript/TypeScript
| 에러 | 원인 | 해결 |
|------|------|------|
| `Cannot find module` | 패키지 미설치 | `npm install` |
| `Type error` | 타입 불일치 | 타입 정의 수정 |
| `ESLint error` | 린트 규칙 위반 | 코드 수정 또는 규칙 조정 |

### Java/Spring Boot
| 에러 | 원인 | 해결 |
|------|------|------|
| `ClassNotFoundException` | 클래스 경로 문제 | 의존성 확인 |
| `BeanCreationException` | DI 설정 오류 | Bean 설정 확인 |
| `NoSuchMethodError` | 버전 불일치 | 의존성 버전 통일 |

### Docker
| 에러 | 원인 | 해결 |
|------|------|------|
| `COPY failed` | 파일 경로 오류 | Dockerfile 경로 확인 |
| `network error` | 네트워크 설정 | 네트워크 모드 확인 |
| `permission denied` | 권한 문제 | USER 설정 또는 chmod |

---

## 진단 스크립트

### 빌드 로그 수집
```bash
# 전체 빌드 로그 저장
npm run build 2>&1 | tee build.log
python setup.py build 2>&1 | tee build.log
mvn clean install 2>&1 | tee build.log
```

## 예방 조치

1. **CI/CD 설정**: 모든 PR에 빌드 검사
2. **Lock 파일 관리**: 의존성 버전 고정
3. **환경 일관성**: Docker 또는 버전 매니저 사용
4. **점진적 업그레이드**: 의존성 한 번에 하나씩 업그레이드
