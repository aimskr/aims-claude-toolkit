# Review Document Template

## File Location
```
docs/reviews/YYYY-MM-DD-<target>-review.md
```

## Template

```markdown
# Code Review: <Target Name>

## Overview
- **Date**: YYYY-MM-DD
- **Reviewer**: Claude (Deep Review — 7 Agents)
- **Target**: <file path or component name>
- **Verdict**: APPROVE / REQUEST CHANGES / REJECT

## Summary
<Brief summary of what was reviewed>

## Findings

### Critical Issues
- [Security, Logic] src/api/auth.py:45 - 미검증 입력이 쿼리에 직접 삽입 → 파라미터화된 쿼리 사용
- [Architecture] src/service/user.py:12 - Repository 레이어 우회 → Service에서 Repository를 통해 접근

### Warning
- [Performance] src/repo/user.py:30 - 루프 내 개별 쿼리 → 배치 쿼리로 변경
- [Simplicity] src/utils/factory.py:1-50 - 단일 구현체용 Factory → 직접 생성자 사용

### Info
- [Readability] src/service/order.py:88 - 함수명 `proc` → `processOrder`로 개선 권장
- [Test] src/service/order.py:processOrder - 에러 경로 테스트 누락

### Positive Points
- <What was done well>

## Self-Challenge
- <Self-challenge results from lead's final verification>

## Recommendations
<Prioritized action items>

## Files Reviewed
- `path/to/file1.py`
- `path/to/file2.py`
```

### Agent Tag Reference
| Tag | Agent | Focus |
|-----|-------|-------|
| `[Architecture]` | arch-reviewer | 레이어, 의존성, 책임 분리 |
| `[Security]` | security-reviewer | OWASP, 인증/인가, 입력 검증 |
| `[Performance]` | perf-reviewer | 쿼리, 메모리, 동시성 |
| `[Logic]` | logic-reviewer | 엣지 케이스, 정합성, 에러 핸들링 |
| `[Readability]` | readability-reviewer | 네이밍, 크기, DRY |
| `[Test]` | test-reviewer | 커버리지, 테스트 품질 |
| `[Simplicity]` | simplicity-reviewer | 과잉 복잡도, YAGNI |

## Rules
1. Always create the review document after completing the review
2. Create `docs/reviews/` directory if it doesn't exist
3. Use descriptive target names (e.g., `cell-normalizer`, `auth-module`)
4. Include specific line numbers when referencing issues

## Review Questions Template

```markdown
### Critical Questions
1. What problem does this solve? Is it the right problem?
2. What are the assumptions? Are they valid?
3. What could break this? Under what conditions?
4. What's the worst-case scenario if this fails?
5. Is there a simpler way to achieve the same result?
6. Is this complexity justified? Is there a concrete reason?
7. Is there code added "because it might be needed in the future"? (YAGNI violation)
8. How much simpler would it be if implemented directly without this abstraction?
```
