# Phase Details Reference

## Phase 1: Discovery

**Goal**: Understand what needs to be built

1. Create todo list with all phases
2. If feature unclear, ask user for: problem, requirements, constraints
3. Summarize understanding and confirm with user

## Phase 2: Codebase Exploration

**Goal**: Understand relevant existing code and patterns

1. Launch 2-3 `code-explorer` agents in parallel:
   - "Find features similar to [feature] and trace their implementation"
   - "Map the architecture and abstractions for [feature area]"
   - "Analyze the current implementation of [existing feature/area]"
2. Read all files identified by agents
3. Present comprehensive summary

## Phase 3: Clarifying Questions ⚠️ CRITICAL

**DO NOT SKIP THIS PHASE**

1. Review findings and original request
2. Identify underspecified aspects: edge cases, error handling, integration points, scope boundaries, backward compatibility, performance requirements
3. **Present all questions in organized list**
4. **Wait for answers before proceeding**

If user says "whatever you think is best", provide recommendation and get explicit confirmation.

## Phase 4: Architecture Design

1. Launch 2-3 `code-architect` agents:
   - **Minimal**: Smallest change, maximum reuse
   - **Clean**: Maintainability, elegant abstractions
   - **Pragmatic**: Speed + quality balance
2. Review approaches, form recommendation
3. Present trade-offs comparison and recommendation
4. **Ask user which approach they prefer**

## Phase 5: Implementation

**⛔ DO NOT START WITHOUT USER APPROVAL**

### Library-First Approach

| Need | ❌ Don't Build | ✅ Use Library |
|------|---------------|----------------|
| Retry logic | Custom | `tenacity`, `resilience4j` |
| Validation | If statements | `pydantic`, `zod` |
| Date handling | Manual | `pendulum`, `date-fns` |
| HTTP | Raw requests | `httpx`, `axios` |

1. Read all relevant files from previous phases
2. Implement following chosen architecture
3. Follow codebase conventions strictly
4. Update todos as you progress

## Phase 6: Quality Review

1. Launch 3 `code-reviewer` agents:
   - **Simplicity**: DRY, elegance, readability
   - **Correctness**: Bugs, functional issues
   - **Conventions**: Project patterns, abstractions
2. Consolidate findings
3. **Present findings and ask user**: Fix now / Fix later / Proceed as-is
4. Address based on user decision

## Phase 7: Documentation & Summary ⚠️ MANDATORY

**DO NOT SKIP THIS PHASE**

1. Mark all todos complete
2. Create `docs/plans/YYYY-MM-DD-<feature>-summary.md`:

```markdown
# <Feature Name>

## 개요
- **날짜**: YYYY-MM-DD
- **요청**: [원래 요청 내용]

## 변경 사항
- [변경된 파일 목록과 변경 내용]

## 구현 세부사항
[기술적 세부사항, 알고리즘, 설계 결정 등]

## 사용법
[해당되는 경우]

## 관련 이슈
[해당되는 경우]

## 향후 개선 사항
[알려진 제한사항, 추후 개선점]
```

3. Summarize: what was built, key decisions, files modified, doc path, next steps, limitations
