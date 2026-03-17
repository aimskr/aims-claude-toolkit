# Deep Code Review with Agent Team

## Overview
기존 `code-reviewer` 스킬을 확장하여 7개 전문 에이전트가 병렬로 코드를 리뷰하는 Deep Review Mode를 기본값으로 설정한다.

## Goals
- 단일 에이전트의 관점 단일성 문제 해결
- 각 전문 영역별 깊이 있는 리뷰 수행
- 리드가 결과를 종합하여 통합 리포트 제공

## Key Requirements
- 7개 전문 에이전트 (모두 Opus, read-only)
- 리뷰 대상: 인자 없으면 git diff, 있으면 해당 경로
- 리드가 중복 제거 + 우선순위 정렬 + Self-Challenge 후 통합 리포트 출력
- 통합 리포트에 각 finding별 에이전트 태그 표기
- Codex 병렬 리뷰 제거

## Agent Roles

| Agent | File | Focus |
|-------|------|-------|
| Architecture | `arch-reviewer.md` | 레이어 위반, 의존성 방향, 책임 분리, 패턴 오남용, 순환 의존 |
| Security | `security-reviewer.md` | OWASP Top 10, 인증/인가, 입력 검증, 비밀 하드코딩 |
| Performance | `perf-reviewer.md` | N+1 쿼리, 메모리 누수, 불필요한 연산, 동시성 이슈, 캐싱 |
| Logic | `logic-reviewer.md` | 엣지 케이스, null/empty, 비즈니스 로직 정합성, 에러 핸들링 |
| Readability | `readability-reviewer.md` | 네이밍, 함수 크기, 파일 크기, 중첩 깊이, DRY |
| Test | `test-reviewer.md` | 커버리지 누락, 엣지 케이스 테스트, 동작 검증, mock 남용 |
| Simplicity | `simplicity-reviewer.md` | 불필요한 추상화, YAGNI, 과도한 패턴, 과잉 복잡도 |

## Workflow

```
1. 리뷰 대상 파악 (git diff or 경로)
2. 7개 에이전트 병렬 생성 (Agent tool, model: opus)
3. 각 에이전트에게 대상 파일 목록 + 컨텍스트 전달
4. 결과 수신
5. 종합: 중복 제거 → 우선순위 정렬 → Self-Challenge
6. 통합 리포트 출력 + docs/reviews/ 저장
```

## Output Format

기존 `review-template.md` 포맷 유지 + 에이전트 태그:
```
### Critical Issues
- [Security, Logic] src/api/auth.py:45 - SQL injection 취약점
- [Architecture] src/service/user.py:12 - Repository 레이어 우회
```

## Files to Create/Modify

### New (7 agents):
- `~/.claude/agents/arch-reviewer.md`
- `~/.claude/agents/security-reviewer.md`
- `~/.claude/agents/perf-reviewer.md`
- `~/.claude/agents/logic-reviewer.md`
- `~/.claude/agents/readability-reviewer.md`
- `~/.claude/agents/test-reviewer.md`
- `~/.claude/agents/simplicity-reviewer.md`

### Modified:
- `~/.claude/skills/code-reviewer/SKILL.md` — Deep Review Mode 기본, Codex 제거

## Implementation Order
1. 7개 에이전트 `.md` 파일 생성
2. `code-reviewer/SKILL.md` 수정
3. `review-template.md` 에이전트 태그 예시 추가
