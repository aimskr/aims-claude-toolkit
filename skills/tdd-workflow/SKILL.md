---
name: tdd-workflow
description: "TDD, 테스트 주도 개발, 테스트 먼저, RED-GREEN-REFACTOR - Red-Green-Refactor TDD workflow. Writes failing tests first, then implements minimal code to pass. Use when implementing features test-first or when strict TDD process is needed. Do NOT use for test strategy planning (use testing-strategy) or E2E browser tests (use e2e-runner)."
tools: Read, Write, Edit, Bash, Grep, Glob
model: opus
metadata:
  author: jaehashin
  version: 1.2.0
---

# TDD Workflow

테스트 주도 개발 워크플로우입니다. 테스트를 먼저 작성하고, 테스트를 통과하는 코드를 구현합니다.

## 핵심 원칙

> **ALWAYS write tests first, then implement code to make tests pass.**

### Red-Green-Refactor 사이클
```
🔴 RED: 실패하는 테스트 작성
    ↓
🟢 GREEN: 테스트를 통과하는 최소한의 코드 작성
    ↓
🔵 REFACTOR: 코드 개선 (테스트는 계속 통과)
    ↓
   반복
```

## 워크플로우

### Phase 1: 요구사항 분석
```
As a [role],
I want to [action],
So that [benefit]
```

### Phase 2: 인터페이스 정의 (RED 준비)
```
1. 입력 타입 정의
2. 출력 타입 정의
3. 에러 케이스 정의
4. 경계 조건 정의
```

### Phase 3: 테스트 작성 (RED)
```python
class TestSemanticSearch:
    def test_returns_relevant_results_for_valid_query(self):
        service = SemanticSearchService()
        results = service.search("crypto trading platform")
        assert len(results) > 0
        assert all(result.relevance_score > 0.5 for result in results)
    
    def test_returns_empty_for_no_matches(self):
        service = SemanticSearchService()
        results = service.search("xyz123nonexistent")
        assert results == []
    
    def test_raises_error_for_empty_query(self):
        service = SemanticSearchService()
        with pytest.raises(ValueError, match="Query cannot be empty"):
            service.search("")
```

### Phase 4: 최소 구현 (GREEN)
테스트를 통과하는 최소한의 코드만 작성합니다.

### Phase 5: 리팩토링 (REFACTOR)
테스트가 통과하는 상태에서 코드를 개선합니다.
⚠️ 리팩토링 후 반드시 테스트 재실행

### Phase 6: 커버리지 확인
Line 80%+, Branch 75%+, Function 90%+ 달성을 확인합니다.

## 체크리스트

### 테스트 작성 전
- [ ] 요구사항 명확히 이해
- [ ] 입출력 타입 정의
- [ ] 경계 조건 식별
- [ ] 에러 케이스 식별

### 테스트 작성 시
- [ ] 실패하는 테스트 먼저 확인
- [ ] 하나의 테스트는 하나의 동작만
- [ ] 의미 있는 테스트 이름
- [ ] 적절한 assertion

### 구현 후
- [ ] 모든 테스트 통과
- [ ] 80%+ 커버리지
- [ ] 리팩토링 완료

## 상세 참조

테스트 유형별 가이드, 커버리지 기준, 모킹 가이드, 테스트 작성 패턴(BDD/AAA):
**Read `references/testing-patterns.md` in this skill directory.**

## 문서화 (작업 완료 후 자동 실행)

작업 완료 시 `auto-documenter`를 호출하여 프로젝트 문서를 업데이트한다.

## Completion

RED-GREEN-REFACTOR 사이클 완료 + 커버리지 목표(Line 80%+, Branch 75%+, Function 90%+) 달성.

## Troubleshooting

**RED 단계에서 테스트가 이미 통과함**: 테스트가 실제로 동작을 검증하는지 확인. 통과하는 테스트는 검증력이 없을 수 있음. assertion을 강화하거나 테스트 재작성.
**REFACTOR 후 테스트 실패**: 리팩토링이 동작을 변경한 것. 즉시 revert 후 더 작은 단위로 리팩토링 재시도.
**커버리지 80% 미달**: 테스트 누락 영역 확인 (`--cov-report=term-missing`). edge case/error case 테스트 추가 우선.
