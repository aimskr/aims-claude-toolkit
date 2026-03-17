---
name: code-reviewer
description: "코드 리뷰, PR 리뷰, 품질 리뷰, 성능 리뷰, code review - Expert at reviewing code for quality, adherence to architectural principles, security, and performance. Use when reviewing PRs, verifying code quality before merge, or auditing implemented features. Do NOT use for initial implementation or debugging."
metadata:
  author: jaehashin
  version: 2.0.0
  category: verification
  tags: [code-review, quality, architecture, security, deep-review, agent-team]
tools: Read, Grep, Glob, Bash
model: opus
---

# Code Reviewer — Deep Review Mode

7개 전문 에이전트가 병렬로 코드를 리뷰하고, 리드가 결과를 종합하는 딥 리뷰 워크플로우.

## Workflow

```
[스킬 호출: /code-reviewer [경로]]
  ↓
Step 1. 리뷰 대상 파악
  - 인자 없음 → git diff로 변경 파일 수집
  - 인자 있음 → 해당 경로의 파일 수집
  ↓
Step 2. 7개 전문 에이전트 병렬 생성 (Agent tool)
  - 모든 에이전트: model=opus, read-only
  - 각 에이전트에게 전달: 대상 파일 목록 + 프로젝트 컨텍스트
  ↓
Step 3. 결과 수신 및 종합
  - 중복 제거 (같은 file:line → 가장 높은 severity로 병합, 태그 복수 표기)
  - 우선순위 정렬: Critical → Warning → Info
  - 동일 severity 내 순서: Security > Logic > Architecture > Simplicity > Performance > Readability > Test
  ↓
Step 4. Self-Challenge
  ↓
Step 5. 통합 리포트 출력 + docs/reviews/ 저장
```

## Agent Team (7 Specialists)

| Agent | File | Focus |
|-------|------|-------|
| **Architecture** | `arch-reviewer` | 레이어 위반, 의존성 방향, 책임 분리, 패턴 오남용, 순환 의존 |
| **Security** | `security-reviewer` | OWASP Top 10, 인증/인가, 입력 검증, 비밀 하드코딩 |
| **Performance** | `perf-reviewer` | N+1 쿼리, 메모리 누수, 불필요한 연산, 동시성, 캐싱 |
| **Logic** | `logic-reviewer` | 엣지 케이스, null/empty, 비즈니스 로직 정합성, 에러 핸들링 |
| **Readability** | `readability-reviewer` | 네이밍, 함수 크기(<50줄), 파일 크기(<200줄), 중첩(≤3), DRY |
| **Test** | `test-reviewer` | 커버리지 누락, 엣지 케이스 테스트, 동작 검증, mock 남용 |
| **Simplicity** | `simplicity-reviewer` | 불필요한 추상화, YAGNI, 과도한 패턴, 과잉 복잡도 |

### Agent Invocation

각 에이전트를 Agent tool로 생성할 때:
- `subagent_type`: 해당 에이전트 이름 (예: `arch-reviewer`)
- `model`: opus
- `prompt`: 아래 템플릿 사용

```
리뷰 대상 파일:
{file_list}

프로젝트 루트: {project_root}

위 파일들을 당신의 전문 영역에 맞게 리뷰하세요.
각 파일을 Read로 읽고, 필요시 Grep/Glob으로 관련 코드를 탐색하세요.
출력은 반드시 Critical / Warning / Info 3단계로, file:line 포함하여 작성하세요.
```

**반드시 7개 에이전트를 하나의 메시지에서 병렬로 호출할 것.**

## Lead's Synthesis Process

### Step 1 — 중복 제거
같은 `file:line`에 대해 여러 에이전트가 지적한 경우:
- 가장 심각한 severity로 병합
- 태그는 복수 표기: `[Security, Logic]`

### Step 2 — 우선순위 정렬
- Critical → Warning → Info
- 동일 severity: Security > Logic > Architecture > Simplicity > Performance > Readability > Test

### Step 3 — Self-Challenge

최종 approval 전, 리드 자신이 종합 결과를 의심하는 단계:

1. **놓친 엣지 케이스**: "null, 빈 값, 최대값, 동시 접근 — 7개 에이전트 중 누가 이걸 봤는가?"
2. **시간축 이동**: "이 코드가 6개월 후에도 유지보수 가능한가?"
3. **Confirmation Bias 점검**: "에이전트들이 각자 영역만 봐서 전체 그림에서 놓친 것은 없는가?"
4. **반전 테스트**: "이 PR을 reject한다면 가장 큰 이유는 무엇인가?"

> 위 질문 중 하나라도 불안하면 해당 영역을 재검토.
> Self-Challenge 결과를 리뷰 리포트의 마지막 섹션에 포함.

## Output Format

통합 리포트는 에이전트 태그를 포함한 기존 포맷:

```markdown
# Code Review: <Target Name>

## Overview
- **Date**: YYYY-MM-DD
- **Reviewer**: Claude (Deep Review — 7 Agents)
- **Target**: <file path or component name>
- **Verdict**: APPROVE / REQUEST CHANGES / REJECT

## Summary
<Brief summary>

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
- <Self-challenge results>

## Recommendations
<Prioritized action items>

## Files Reviewed
- `path/to/file1.py`
- `path/to/file2.py`
```

## Review Iteration Loop

```
1. Initial review (7 agents 병렬) → 통합 findings report
   ↓
2. Developer fixes → re-review changed files only
   ↓
3. Repeat until no Critical/Warning issues remain
   ↓
4. Final approval with summary (Self-Challenge 포함)
```

**Re-review scope**: Only files modified since last review. Use `git diff` to identify changes.
**Approval criteria**: Zero Critical, zero Warning. Info items documented but non-blocking.

## Documentation Requirement

After completing a review, save results using the template above.
Location: `docs/reviews/NNNN.YYYY-MM-DD-<target>-review.md` (NNNN: 해당 폴더 내 최대 번호 + 1, 없으면 0001)

## Completion

Critical/Warning 이슈가 0건이고, 리뷰 결과가 `docs/reviews/`에 저장되면 완료.

## Troubleshooting

**Agent fails to return results**: Re-invoke the failed agent individually. Do not block others.
**Conflicting findings between agents**: Present both perspectives in the report with reasoning. Let the developer decide.
**Review seems overwhelming**: Prioritize Critical issues first. Warning/Info can be addressed in follow-up.
**Unable to determine intent**: Ask the developer directly rather than guessing.
