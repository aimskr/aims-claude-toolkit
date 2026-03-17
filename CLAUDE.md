# Work Instructions

## Skill Auto-Invocation Rules

**Always invoke the corresponding Skill first based on task type.**

### Planning/Design Phase

| Situation | Skill | Description |
|-----------|-------|-------------|
| Idea refinement, feature design | `brainstorming` | Explore requirements and design before creative work |
| Product planning, PRD, MVP definition | `prd-strategist` | Product strategy and requirements documentation |
| Implementation planning | `writing-plans` | Detailed implementation plan before coding |
| Architecture-level decisions, multi-system tradeoffs | `sequential-thinking` | Systematic thinking process, critical design review. 단순 기술 질문에는 불필요 |
| 기술/주제 학습, 개념 정리, 스터디 | `learning-research` | 학습 자료 수집 및 이해도별 정리. study/deep-study 모드. Obsidian 저장 |
| 기술 자료 조사, 의사결정용 리서치 | `research` | 병렬 전문가 기반 종합 리포트. 기술 스택 선택, 아키텍처 결정 등 |
| 시장조사, 경쟁분석 | `market-research` | 시장 규모, 경쟁사 분석, 사용자 니즈 조사 |

### Development Phase

| Situation | Skill | Description |
|-----------|-------|-------------|
| Code exploration/analysis | `code-explorer` | Understand code structure via LSP + Glob/Grep (LSP 미설치 시 Grep fallback) |
| System/feature design | `architect` | Clean Architecture, DDD, implementation blueprints |
| Code style, naming (new modules/classes only) | `code-conventions` | Code conventions and style guide. 소규모 수정에는 불필요 |
| Feature implementation | `feature-development` | Systematic 7-phase development workflow |
| Spec-driven parallel dev (multi-module only) | `harness` | TDD harness with Agent Teams. 단일 파일/50줄 미만 작업에는 부적합 → `feature-development` 사용 |
| TDD implementation | `tdd-workflow` | Red-Green-Refactor cycle with coverage targets |
| UI/Web component development | `ui-ux-design` | Production-grade frontend implementation |
| Code simplification | `code-simpler` | Reduce complexity based on insight reports |
| Dead code removal, cleanup | `refactor-cleaner` | Safe dead code identification and removal |
| E2E test creation/maintenance | `e2e-runner` | Playwright-based E2E test workflow |

### Verification Phase

| Situation | Skill | Description |
|-----------|-------|-------------|
| Build/compilation errors | `build-error-resolver` | Systematic build error diagnosis and resolution |
| Bug fixing, error analysis | `debug-specialist` | Root cause analysis and resolution |
| Code review | `code-reviewer` | Deep Review: 7 전문 에이전트 병렬 리뷰 (arch/security/perf/logic/readability/test/simplicity) |
| Security review | `security-review` | OWASP-based vulnerability analysis |
| Test strategy/planning | `testing-strategy` | Systematic test design |

### Documentation & Operations

| Situation | Skill | Description |
|-----------|-------|-------------|
| Writing docs (specs, proposals, etc.) | `doc-coauthoring` | Structured document collaboration |
| Post-task documentation | `auto-documenter` | Auto-update architecture.md, memory.md, ADR |
| Git commits, branches, PRs | `github-operator` | Git/GitHub operations with branch naming rules |
| CLAUDE.md optimization | `review-claudemd` | Analyze conversations to improve CLAUDE.md |

---

## Integrated Workflows

### "Implement a feature" Request

**Small feature** (단일 모듈, 명확한 요구사항):
```
1. brainstorming       → Confirm requirements and design
2. writing-plans       → Create implementation plan
3. feature-development → Implement actual code
4. code-reviewer       → Verify code quality (+ Codex 병렬 리뷰 자동 포함)
5. auto-documenter     → Update project documentation (if 4+ files changed)
```

**Large feature** (다중 모듈, 새 도메인, 복잡한 요구사항):
```
1. brainstorming       → Explore requirements and design
2. prd-strategist      → Formalize PRD
3. writing-plans       → Create implementation plan
4. code-explorer       → Understand existing codebase
5. architect           → Design structure/layers
6. feature-development → Implement actual code
7. code-reviewer       → Verify code quality (+ Codex 병렬 리뷰 자동 포함)
8. auto-documenter     → Update project documentation
```

> Small/Large 판단: 변경 예상 파일 10개 이상 또는 새 모듈/패키지 생성 → Large. 그 외 → Small.

### "Modify existing feature" Request

```
1. 기존 스펙 문서 확인   → docs/plans/에서 해당 기능 문서 검색 (Glob)
2. code-explorer         → 현재 구현 상태 파악 (LSP 사용)
3. feature-development   → Modify 모드: Phase 2(Exploration)부터 시작
4. code-reviewer         → Verify changes
5. 스펙 문서 Changelog   → 기존 문서에 Changelog 항목 추가
```

> 기존 기능에 서브기능 추가, 동작 변경, 확장 등. 새 스펙 문서를 만들지 않고 기존 문서의 Changelog에 변경 이력을 기록한다.

### "Fix a bug" Request

```
1. debug-specialist    → Root cause analysis
2. code-explorer       → Explore related code
3. Implement fix
4. testing-strategy    → Verify regression tests
5. auto-documenter     → Update project documentation (if significant)
```

### "Fix build error" Request

```
1. build-error-resolver → Diagnose and resolve build error
2. auto-documenter      → Update project documentation (if significant)
```

### "New project/product planning" Request

```
1. brainstorming       → Explore ideas and requirements
2. prd-strategist      → Write PRD (+ Codex 병렬 분석 자동 포함)
3. architect           → Design system architecture
4. writing-plans       → Create implementation roadmap
```

### "Review code" Request

```
1. code-reviewer       → Deep Review: 7 전문 에이전트 병렬 리뷰 (arch/security/perf/logic/readability/test/simplicity)
```

> code-reviewer가 architecture, security, performance, logic, readability, test, simplicity 7개 전문 에이전트를 병렬 실행하므로 별도 스킬 호출 불필요.

### "Simplify code" Request

```
1. code-explorer       → Understand current structure
2. code-simpler        → Apply simplification techniques
3. code-reviewer       → Verify changes
4. auto-documenter     → Update project documentation
```

### "Refactor" Request

```
1. code-explorer       → Understand current code structure
2. architect           → Design improved structure
3. refactor-cleaner    → Remove dead code
4. code-reviewer       → Verify changes
5. auto-documenter     → Update project documentation (if significant)
```

### "TDD development" Request

```
1. testing-strategy    → Design test strategy (if scope is large)
2. tdd-workflow        → Red-Green-Refactor cycle
3. code-reviewer       → Verify code quality
4. auto-documenter     → Update project documentation
```

### "E2E test" Request

```
1. e2e-runner          → Generate/run/maintain Playwright tests
2. auto-documenter     → Update project documentation
```

### "Quick fix" Request (10줄 미만, 단일 파일)

```
1. Read file           → 대상 파일 읽기
2. Edit                → 변경 적용
3. Verify              → 테스트/빌드 확인
```

> 풀 워크플로우 불필요. 타이포 수정, 포트 번호 변경, 단일 변수 추가 등에 적용.

### "Dockerfile modification" Request

```
1. code-explorer       → 기존 Docker 구조 및 의존성 파악
2. Clarify scope       → 대상 환경(local/runpod/onprem)과 파일 범위 확인
3. Implement           → 1개 RUN layer씩 변경 → docker build 검증 → 다음 변경
4. auto-documenter     → 프로젝트 문서 업데이트
```

> Dockerfile은 반드시 1개 레이어씩 변경 후 빌드 검증. 여러 레이어를 한 번에 수정 금지.

### "Critical review / design validation" Request

```
1. sequential-thinking → Critical Design Review Mode:
   Stage 1: Devil's Advocate (비판 시나리오 3-5개)
   Stage 2: Multi-perspective analysis (성능/보안/유지보수성)
   Stage 3: Bias detection (인지 편향 점검)
   Stage 4: Evidence validation (근거·출처 명시)
   Stage 5: Conclusion (개선 항목 + 놓친 이슈)
```

### "Harness development" Request (스펙 기반 병렬 개발)

```
1. brainstorming       → Confirm spec/requirements
2. harness             → Run full harness workflow:
   Phase 0: Spec intake → module breakdown
   Phase 1: Generate ALL tests first (TDD)
   Phase 2: Create agent team (6 members)
   Phase 3: Harness loop (test → implement → verify → repeat)
   Phase 4: Convergence (100% pass → final review → cleanup)
   Progress tracked in PROGRESS.md
3. auto-documenter     → Update project documentation
```

### Codex Synthesis (자동 통합)

아래 스킬은 실행 시 **자동으로 Codex를 백그라운드 병렬 호출**하여 독립 분석 후 합성한다. `codex-synthesis.md` 참조.

| 스킬 | Codex 역할 | 합성 시점 |
|------|-----------|----------|
| `code-reviewer` | 독립 코드 리뷰 | 리뷰 리포트 작성 시 |
| `prd-strategist` | 제품 컨셉 독립 분석 | PRD 초안 작성 후 |
| `research` | 독립 전문가로 참여 | 교차 검증 시 |

> Codex 설정: gpt-5.3-codex / high effort / read-only sandbox (고정)
> Codex 실패 시 Claude 단독 진행 (자동 fallback)

---

## Core Principles

1. **Skill First**: Always invoke the relevant Skill before starting work. 사용자가 호출한 스킬이 부적합하면 이유를 설명하고 확인 후 대체
2. **LSP Default**: LSP 플러그인 설치 완료 (pyright, typescript-lsp, jdtls-lsp, swift-lsp). 코드 탐색 시 LSP 도구(`goToDefinition`, `findReferences`, `workspaceSymbol`, `incomingCalls`, `outgoingCalls`)를 **기본으로 사용**한다. LSP 도구가 에러를 반환한 경우에만 Grep/Glob fallback. LSP 시도 없이 Grep부터 사용 금지.
3. **Follow Workflows**: Proceed in the order defined in integrated workflows. 10줄 미만 단일 파일 변경은 "Quick fix" 워크플로우 적용
4. **Apply Conventions**: Reference `code-conventions` when writing new modules or classes (소규모 수정에는 불필요)
5. **Verify Before Moving On**: Run tests or build after every change. Never assume it works. 로컬 빌드가 불가능한 환경(Docker/GPU)에서는 가능한 부분 검증(syntax check 등)을 명시
6. **Document After Work**: Trigger `auto-documenter` when ANY of these conditions are met:
   - 변경 파일 4개 이상
   - 새 모듈/패키지 생성
   - 아키텍처 변경 (DB 스키마, 라우팅, 인프라 설정)
   - 외부 의존성 추가/제거
   - 워크플로우에 `auto-documenter`가 조건 없이 명시된 경우

   **스킵 시**: "auto-documenter 조건 미충족 (변경 파일 N개, 아키텍처 변경 없음) — 문서화 스킵" 1줄 고지. 사용자가 요청하면 즉시 실행
7. **Scope Restriction**: 사용자가 명시하지 않은 파일은 절대 수정 금지. 관련 이슈 발견 시 "X 파일도 수정할까요?" 질문 후 진행. "while I'm at it" 변경 금지

---

## Mistake Reduction Protocol

Apply these rules on EVERY task to continuously reduce errors. Inspired by the harness approach.

### 1. Read Before Write

- **ALWAYS** read the file before editing it
- **ALWAYS** understand existing patterns before adding new code
- Check for similar implementations in the codebase first
- Before calling any class method, LSP `go-to-definition`/`find-references`로 메서드 존재 여부 확인 (LSP 미사용 시 Grep으로 대체)
- **List Before Delete**: 파괴적 작업(삭제, 대량 이동) 전 대상 목록과 크기를 표시하고 사용자 확인 후 실행
- Before removing any dependency/package, grep으로 전체 코드베이스에서 사용처 검색

### 2. Verify After Every Change

- Run tests / build / lint after each meaningful change
- If verification fails, fix immediately before proceeding
- Never stack multiple unverified changes
- **Dockerfile**: 1개 RUN layer 변경 → `docker build` 검증 → 다음 변경. 여러 레이어 동시 수정 금지
- **외부 서비스 의존 배치 작업**: 전체 배치 전 단일 요청 smoke test 필수
- 로컬 빌드 불가 시(Docker/GPU) 가능한 부분 검증을 명시하고, 검증 스킵을 묵인하지 말 것

### 3. Failed Approaches Log

When an approach fails during a session, record it in `PROGRESS.md` (if exists) or communicate it clearly:

```
## Failed Approaches (DO NOT RETRY)
- [timestamp] [what was tried] → [why it failed]
```

**Rules:**
- Check this log BEFORE attempting any fix
- Never retry the same approach that already failed
- When delegating to teammates, include this log in task descriptions
- 같은 에러가 수정 시도 후 재발하면 STOP → 로그 확인 → 새 접근법 제시 전 기존 시도 나열

### 4. Regression Guard

- If a previously passing test now fails → stop all new work, fix regression first
- After fixing a bug, verify that no existing tests broke
- Treat regressions as highest priority

### 5. One Thing at a Time

- Make one logical change per step
- Verify that change works before starting the next
- If multiple files need changing, change and verify incrementally

---

## Agent Team Rules

### Available Agents (`~/.claude/agents/`)

| Agent | Model | Role | Memory |
|-------|-------|------|--------|
| `researcher` | haiku | Fast codebase exploration (read-only) | - |
| `implementer` | opus | Code implementation | - |
| `reviewer` | opus | Code review & security (read-only) | user |
| `tester` | sonnet | Test writing & execution | - |
| `arch-reviewer` | opus | Architecture review (read-only) | - |
| `security-reviewer` | opus | Security review (read-only) | - |
| `perf-reviewer` | opus | Performance review (read-only) | - |
| `logic-reviewer` | opus | Logic/correctness review (read-only) | - |
| `readability-reviewer` | opus | Readability/convention review (read-only) | - |
| `test-reviewer` | opus | Test quality review (read-only) | - |
| `simplicity-reviewer` | opus | Simplicity/YAGNI review (read-only) | - |

### For Team Lead

- Use delegate mode (Shift+Tab) to avoid implementing directly
- Create 5-6 tasks per teammate for optimal throughput
- Set task dependencies with addBlockedBy when order matters
- Require plan approval for risky implementations
- Wait for all teammates before synthesizing results
- Shut down teammates gracefully before cleanup

### For Teammates

- Check TaskList after completing each task for next work
- Claim unassigned, unblocked tasks (prefer lowest ID first)
- Own specific files exclusively - never edit another teammate's files
- Message teammates directly when sharing relevant findings
- Use broadcast only for critical blocking issues
- Mark tasks completed immediately when done

### File Ownership

When working in a team, each teammate must own distinct files to avoid conflicts.
The lead defines ownership at task creation time.

### Team Creation Templates

> 템플릿 유형: Feature development (researcher + implementers + tester), Parallel code review (multi-reviewer), Competing hypothesis debugging (multi-debugger). 팀 생성 시 각 teammate에 명확한 파일 소유권 지정 필수.

### Notes

- Agent team에 파일 경로 전달 시 `/tmp/` 등 제한 경로 피하기 → 프로젝트 워킹 디렉토리 기준 경로 사용
- 2분 초과 background task는 25%/50%/75%/100% 진행률 보고
