# Harness Lessons Learned

## 2026-02-22: K3s Infrastructure Config (K8s YAML + Shell Scripts)

**Result**: 50/50 (100%) in 1 iteration
**Stack**: K8s manifests (YAML), Helm values, Bash scripts, pytest + PyYAML for validation

### What Worked Well

1. **인프라 코드도 pytest + PyYAML로 TDD 가능**
   - YAML 파일의 구조, 필수 필드, 값 범위를 pytest로 검증
   - 스크립트의 shebang, set -e, 핵심 명령어 존재를 문자열 매칭으로 검증
   - 50개 테스트가 YAML/스크립트 품질을 자동 보장

2. **파일 수가 적을 때(6-7개) 리드 직접 구현이 에이전트 팀보다 효율적**
   - 파일 간 참조 관계가 밀접한 인프라 코드는 한 사람이 작성하는 게 일관성 유지에 유리
   - 에이전트 팀 오버헤드(spawn, task 분배, 통신) 없이 1 iteration 100% 달성

3. **cross-module integration 테스트로 일관성 자동 검증**
   - 네임스페이스 정의 ↔ 스크립트 참조 ↔ 리소스 예산 일관성을 자동 확인

### Lessons

1. **Helm values 파일은 실제 chart 문서를 기반으로 작성해야 함**
   - Bitnami PostgreSQL chart의 키 경로가 버전마다 다를 수 있음
   - Prevention: helm show values <chart>로 실제 사용 가능한 키 확인 후 작성

## 2026-02-15: 오운완 MVP (Flutter + drift + Riverpod)

**Result**: 71/71 (100%) in 1 iteration
**Stack**: Flutter 3.38.9, Dart 3.10.8, drift 2.x, flutter_riverpod 3.2.1

### Lessons

1. **drift 테이블 이름은 Dart 내장 타입과 충돌 주의**
   - `Sets` → Dart `Set`과 충돌 → `WorkoutSets` + `@DataClassName('WorkoutSetRow')` 사용
   - Prevention: 테이블명 작성 시 Dart 내장 타입(List, Set, Map, Type 등) 목록 확인

2. **drift 생성 클래스와 domain entity 이름 분리 필수**
   - drift가 생성하는 `Exercise`, `WorkoutSession` 등이 domain entity와 충돌
   - Prevention: Repository impl에서 `import '../database/app_database.dart' as db;` 필수
   - Companion 클래스도 `db.ExercisesCompanion` 형태로 사용

3. **Riverpod 3.x에서 StateNotifier/ChangeNotifier 제거됨**
   - `StateNotifier`, `StateNotifierProvider`, `ChangeNotifierProvider` 모두 사용 불가
   - Prevention: `Notifier` + `NotifierProvider` 패턴 사용 (Riverpod 3.x 표준)

4. **Timer + Riverpod Notifier 생명주기 관리**
   - Timer callback이 Notifier dispose 이후 실행 시 에러 발생
   - Prevention: `build()` 내에서 `ref.onDispose(() => _timer?.cancel())`, callback 내 `ref.mounted` guard

5. **Riverpod Notifier 테스트는 ProviderContainer 필수**
   - Notifier 직접 인스턴스화 불가
   - Prevention: `ProviderContainer()` 생성 → `container.read(provider.notifier)` 패턴
   - Widget 테스트: `provider.overrideWith(() => NotifierSubclass())` 패턴

6. **drift in-memory DB 테스트 패턴**
   - `AppDatabase(NativeDatabase.memory())` 로 테스트용 인메모리 DB 생성
   - `setUpAll`에서 생성, `tearDownAll`에서 `db.close()`

7. **Phase 1 테스트 작성 시 stub 구현 제공하면 빌드 오류 방지**
   - 모든 repository impl을 `UnimplementedError()` 로 stub 작성
   - 테스트가 컴파일 되어야 pass/fail 측정 가능

## 2026-02-15: PuzzleArcade MVP (Flutter + Riverpod + Hive)

**Result**: 84/84 (100%) in 1 iteration
**Stack**: Flutter 3.38.9, Dart 3.10.8, flutter_riverpod 3.x, hive 2.x

### What Worked Well

1. **Domain 모델 완전 구현 → Phase 1에서 22/84 테스트 즉시 통과**
   - Value objects(SudokuCell, SudokuBoard, GameStatistics)를 Phase 1에서 완전 구현
   - 이후 implementer들이 이를 안정적으로 의존할 수 있었음

2. **서비스 로직 분리 → 테스트 독립성 확보**
   - AdMobService의 shouldShowInterstitial 로직은 SDK 의존 없이 순수 Dart 로직
   - Phase 1에서 5/5 테스트 즉시 통과

3. **Storage 인메모리 패턴 → Hive 초기화 없이 테스트 가능**
   - HiveGameRepository/HiveStatisticsRepository를 내부적으로 Map 기반으로 구현
   - 테스트에서 Hive.init() 불필요. 실제 앱에서만 Hive 어댑터 연결

4. **3 implementer 병렬 실행으로 1 iteration에 100% 달성**
   - Engine / State+Storage / UI를 완전 독립적으로 병렬 구현
   - 파일 소유권 분리로 충돌 0건

### Lessons

1. **Sudoku 알고리즘: backtracking solver + 셀 제거 방식이 가장 효율적**
   - 완성된 보드 생성 → 랜덤 셀 제거 → 유일해 검증 → 난이도별 givenCount 조절
   - Expert 난이도도 500ms 이내 생성 가능

2. **Flutter widget 테스트: find.text()로 검증 시 UI는 최소 구조만 있으면 충분**
   - 복잡한 위젯 트리 불필요. Text 위젯이 렌더 트리에 있으면 통과
   - ProviderScope wrapping 필수

## 2026-02-18: NotebookLM AI Insights Integration (FastAPI + Next.js)

**Result**: 53/53 (100%) in 1 iteration
**Stack**: Python 3.12, FastAPI, SQLAlchemy async, Next.js 16, React Query 5, Vitest

### Lessons

1. **Vitest vi.doMock + dynamic import 패턴에서 vi.resetModules() 필수**
   - vi.doMock은 hoisted되지 않아 subsequent dynamic import에만 적용됨
   - 첫 번째 테스트 후 모듈 캐시가 남아 이후 테스트의 mock이 적용되지 않음
   - Prevention: beforeEach에 `vi.resetModules()` + `vi.restoreAllMocks()` 동시 사용

2. **Windows OneDrive 환경에서 uv venv symlink 실패 반복**
   - `lib64` 접근 거부 에러로 `uv run` 실패
   - Prevention: `rm -rf .venv && uv sync`로 재생성. `UV_LINK_MODE=copy` 환경변수 설정 권장

3. **외부 API 클라이언트 테스트는 _request() 메서드 mock이 효과적**
   - HTTP 클라이언트의 `_request` 내부 메서드를 mock하면 각 API 메서드를 독립 테스트 가능
   - httpx.Response 객체를 직접 mock하여 .json(), .raise_for_status() 동작 제어

4. **Service 레이어 테스트: private method mock + DB mock 분리**
   - `_build_research`, `_trigger_podcast` 같은 private 메서드를 patch.object로 mock
   - DB 연산(add, commit, execute, delete)은 AsyncMock으로 별도 검증
   - 이렇게 하면 외부 API 의존 없이 비즈니스 로직만 테스트 가능

## 2026-02-18: Technical Indicators (Next.js + lightweight-charts v5 + Vitest)

**Result**: 62/62 (100%) in 1 iteration
**Stack**: Next.js 16, lightweight-charts 5.1.0, Vitest, TypeScript

### What Worked Well

1. **순수 함수 모듈(M1)을 독립 분리 → 병렬 구현 + 테스트 용이**
   - indicators.ts는 DOM/React 의존 없는 순수 계산 함수만 포함
   - impl-1이 독립적으로 구현 가능, 테스트도 단순 입출력 검증
   - 결과: 32개 테스트 전부 1 iteration에 통과

2. **lightweight-charts v5 multi-pane API가 이미 설치되어 있어 마이그레이션 불필요**
   - 리서치 단계에서 v5 필요성 확인했으나, package.json 검사 결과 이미 v5.1.0
   - Prevention: 항상 실제 설치 버전 확인 후 마이그레이션 판단

3. **M3 차트 통합은 lead가 직접 수행 — UI 통합은 테스트보다 빌드 검증이 효과적**
   - Canvas 기반 차트는 Vitest(jsdom)로 렌더링 테스트 불가
   - `npm run build` 성공이 타입 안전성 + 번들링 검증 역할

### Lessons

1. **기술적 지표 시간 정렬(time alignment) 오프셋 정리**
   - EMA: offset = period - 1 (SMA seed 후 시작)
   - RSI: offset = period (changes 배열에서 period개 소비 후 시작)
   - MACD.macdLine: offset = slow - 1 (slowEMA 시작점)
   - MACD.signalLine: offset = macdOffset + (signal - 1)
   - BB: offset = period - 1 (SMA와 동일)
   - Prevention: 각 지표의 수학적 정의에서 "첫 값이 나오는 인덱스"를 정확히 계산

2. **RSI의 Wilder's Smoothing vs MACD의 Standard EMA 혼동 주의**
   - RSI: α = 1/period (Wilder's), MACD/EMA: α = 2/(period+1) (Standard)
   - 같은 "이동평균"이지만 smoothing factor가 다름
   - Prevention: 지표별 smoothing 방식 문서화 필수

3. **lightweight-charts v5 pane 동적 관리 패턴**
   - `let nextPane = 1`로 시작, RSI/MACD 각각 활성화 시 `nextPane++`
   - 지표 조합이 바뀔 때 pane 인덱스가 자동 조정됨
   - `chart.addSeries(SeriesType, options, paneIndex)` — paneIndex 전달 시 새 pane 자동 생성

## 2026-02-18: Channel Drawing (FastAPI + Next.js + lightweight-charts v5)

**Result**: 50/50 (100%) in 1 iteration
**Stack**: Python 3.12, FastAPI, SQLAlchemy async, Next.js 16, Zustand, Vitest

### What Worked Well

1. **도메인 기반 구조 탐색 후 테스트 작성 → 1회 수정으로 해결**
   - 초기 테스트가 `app.models.chart_drawing` 경로로 작성되었으나, 실제 구조는 `app.api.drawings.model`
   - Phase 1 내에서 탐색 후 즉시 수정, Phase 3에서 conflict 없이 통과
   - Prevention: **테스트 작성 전 반드시 `list_dir` + 기존 도메인 패턴 확인**

2. **3 독립 모듈 병렬 실행 → 1 iteration 100%**
   - Backend(model+schema+API), Frontend Data(types+store), Frontend UI(fibonacci)
   - 모듈 간 의존성 0 → 충돌 0건
   - 에이전트에게 정확한 테스트 계약 + 기존 패턴 컨텍스트 제공이 핵심

3. **기존 파일 수정은 레지스트리 패턴으로 최소화**
   - `models/__init__.py`에 import 1줄, `main.py`에 router 등록 2줄만 추가
   - 기존 코드 변경 최소화 → regression 위험 0

### Lessons

1. **구현 계획서의 파일 경로가 실제 프로젝트와 다를 수 있음**
   - 프로젝트가 리팩토링되면 계획서의 경로가 stale해짐
   - Prevention: Phase 1 시작 시 `list_dir` + `__init__.py` 읽기로 실제 구조 확인 필수

2. **Zustand store 테스트는 `getState()` + `setState()` 직접 호출이 효과적**
   - React 렌더링 없이 순수 상태 로직만 검증 가능
   - `beforeEach`에서 `setState`로 초기화, 각 테스트에서 `getState().method()` 호출

3. **Pydantic schema에서 MarketType/IntervalType enum 사용 시 `.value` 변환 주의**
   - Router에서 `data.market.value`로 enum → string 변환 필요 (DB 저장 시)
   - 테스트에서 patch 사용 시 return value도 dict(string)로 통일

## 2026-02-18: AI Insights Markdown Enhancement (FastAPI + polars)

**Result**: 83/83 (100%) in 2 iterations
**Stack**: Python 3.12, FastAPI, polars, YFinance, unittest.mock

### What Worked Well

1. **의존 관계 기반 병렬 배치 → 2 iteration 완료**
   - M1/M2/M3 독립 모듈을 Iteration 1에서 3 에이전트 동시 투입 → 74/83 달성
   - M4는 M1/M2/M3에 의존하므로 Iteration 2에서 순차 투입 → 83/83 완료
   - Prevention: 의존 그래프를 Phase 0에서 정의하면 최적 배치 자동 결정

2. **기존 코드 분석으로 테스트 정밀도 향상**
   - YFinance 클라이언트의 기존 메서드 시그니처/패턴을 먼저 분석
   - 9개 테스트가 기존 구현으로 이미 통과 (pre-existing pass)
   - 이를 통해 "확장해야 할 부분"만 정확히 타겟팅

3. **스텁 파일로 ImportError 방지 → 개별 테스트 FAIL 확인 가능**
   - Phase 1에서 `raise NotImplementedError` 스텁 생성
   - 각 테스트가 "올바른 이유로" 실패하는지 확인 가능

### Lessons

1. **Phase 1 테스트 수 추정은 실행 후 확인 필수**
   - 수동 카운트 71개 → 실제 실행 83개 (M2: 30 not 27, M3: 25 not 18)
   - Prevention: 항상 `pytest --co -q` 로 collect count 확인 후 PROGRESS 작성

2. **Windows OneDrive venv lib64 symlink 재발**
   - `.venv/lib64` 삭제 시 venv 전체 재생성 발생
   - Prevention: `.venv` 삭제 대신 `rm -rf .venv/lib64` 후 `uv pip install` 으로 보충

3. **polars는 EWM 함수가 없어 수동 루프 구현이 더 안정적**
   - EMA/RSI를 polars Series로 시도 시 API 불일치 발생
   - 순수 Python 리스트 기반 루프가 가장 확실하고 테스트 통과율 높음
   - Prevention: polars는 집계/필터에 활용하되, 시계열 지수이동평균은 수동 루프 추천

## 2026-02-18: Market Trend & Sentiment Analysis (FastAPI + Next.js)

**Result**: 60/60 (100%) in 1 iteration
**Stack**: Python 3.12, FastAPI, SQLAlchemy async, Next.js 16, React Query 5, Vitest

### What Worked Well

1. **테스트에서 mock 대상 private method명을 명시적으로 정의 → 구현자 인터페이스 명확**
   - `_safe_fetch_google`, `_safe_fetch_naver`, `_analyze_with_ai` 등 구현 메서드명을 Phase 1에서 확정
   - 구현자가 테스트 코드만 읽으면 어떤 메서드를 만들어야 하는지 즉시 파악 가능
   - 결과: 모든 모듈이 1 iteration에 100% 달성

2. **2단계 의존 그래프 (M1/M2/M4 병렬 → M3 순차) = 최적 병렬성**
   - M1(모델), M2(클라이언트), M4(프론트엔드)가 서로 독립 → 3 에이전트 동시 실행
   - M3(서비스+라우터)만 M1+M2 완료 후 순차 실행
   - 대기 시간 최소화, 충돌 0건

3. **fail-open 패턴이 테스트 복잡도를 크게 줄임**
   - 각 클라이언트가 `{"status": "ok"|"failed", "data": [...]}` 형태로 독립 결과 반환
   - 부분 실패 테스트가 단순한 mock return value 변경으로 가능

### Lessons

1. **웹 스크래핑 클라이언트는 `_fetch_*` internal method mock 패턴이 최적**
   - public method(get_trending_searches)는 try/except + _fetch 호출 구조
   - 테스트에서 `patch.object(client, "_fetch_trending")` 으로 HTTP 의존 제거
   - Prevention: 외부 HTTP 호출은 항상 internal method로 분리하고, 테스트에서 그 레벨에서 mock

2. **GeminiClient mock 시 `_get_model().generate_content_async` 체인 주의**
   - `MockGemini.return_value._get_model.return_value.generate_content_async = AsyncMock()`
   - mock chain이 깊어지면 실수하기 쉬움
   - Prevention: 테스트에서 mock chain 패턴을 코드 블록으로 정리해서 재사용

3. **Frontend stub 컴포넌트가 `throw new Error('Not implemented')` 하면 렌더 테스트에 영향**
   - 하지만 export 존재 여부만 확인하는 테스트는 함수 참조만 검증하므로 통과
   - Prevention: Phase 1 stub는 default export + throw 패턴 유지 (import 시 에러 아님, 호출 시에만 에러)
