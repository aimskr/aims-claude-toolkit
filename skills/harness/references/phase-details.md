# Harness - Phase Details Reference

## Phase 0: Spec Intake (Detail)

1. Ask user for spec location (file path, URL, or inline)
2. Check if `~/.claude/skills/harness/LESSONS_LEARNED.md` exists. If yes, read it and incorporate relevant prevention rules into the project's PROGRESS file Mistake Log header as pre-loaded rules.
3. Read the provided spec/PRD document
4. Analyze existing project structure to detect tech stack and conventions:
   - Language, framework, test runner (pytest, jest, JUnit, etc.)
   - Directory conventions (src/, app/, lib/, etc.)
   - Existing test patterns if any
5. **Extract feature name** from spec/PRD title → kebab-case → confirm with user
   - 예: "사용자 인증 시스템 MVP" → `auth-system-mvp`
   - 영문/숫자/하이픈만 허용
6. **Prepare `.harness/` directory**
   - `mkdir -p .harness`
   - If `.gitignore` does not contain `.harness/`, append it
7. **Conflict check**: If `.harness/PROGRESS-{feature}.md` already exists, warn user (another harness may be running). Ask to overwrite or rename.
8. Identify all modules/components to implement
9. Define module boundaries and file ownership map (adapt to actual project structure):
   - Module A → [actual path pattern] → implementer-1
   - Module B → [actual path pattern] → implementer-2
   - Tests → [test path pattern] → tester
   - (adjust module count to match actual spec)
10. Create `.harness/PROGRESS-{feature}.md` (see `progress-template.md`)
11. Confirm module breakdown with user before proceeding

## Phase 1: Test Suite Generation (Detail)

**The lead writes tests directly in this phase.** This is the only phase where the lead writes code — all subsequent implementation is delegated to teammates.

For each module identified in the spec:

1. Create test files using the project's existing test runner and conventions
2. For each spec requirement, write at least one test covering:
   - Happy path (normal operation)
   - Edge cases (boundary values, empty inputs)
   - Error cases (invalid inputs, failures)
   - Integration points (module interactions)
3. Each test must have a descriptive name mapping to a spec requirement
4. **Tests must verify general correctness, not specific outputs.** Write tests that validate behavior for all valid inputs, not just hard-coded examples.
5. Run all tests → confirm ALL FAIL (this is the correct starting state)
6. Count total tests → update `.harness/PROGRESS-{feature}.md`

### Test Result Reporting Format

The tester agent summarizes results (parsed from actual test runner output):

```
=== TEST RESULTS ===
PASS: 0/[total] (0%)
FAIL: [total]

[FAIL BY MODULE]
  [module-a]:  0/[n]  ([n] FAIL)
  [module-b]:  0/[n]  ([n] FAIL)

[TOP 5 ERRORS]
  ERROR [module]/[test_file]:[line] - [one-line description]
```

**Reporting rules:**
- Summary ≤ 10 lines
- `ERROR` keyword on same line as reason (for grep)
- Module-level aggregation
- Full stack traces → log file only
- NEVER print per-test output for passing tests
- Incremental progress: print only every 25th test

### Test Execution Strategy (Three Tiers)

- **Quick check** (after each implementer change): Run only the target module's tests
- **Smoke test** (each loop iteration): Run a deterministic 10% random sample. Each agent uses a different seed.
- **Full suite** (exit condition only): Run all tests. Use ONLY when `.harness/PROGRESS-{feature}.md` shows 100% on smoke tests.

7. Commit: `test: initial test suite (0/N passing)`
8. Update `.harness/PROGRESS-{feature}.md` status to `PHASE 1 COMPLETE`

## Phase 2: Team Setup (Detail)

Inform user: **"Phase 2 시작: delegate mode (Shift+Tab)로 전환해주세요."**

### Team Creation Prompt

```
Create an agent team for harness development.
Spawn teammates:
- "researcher" using researcher agent - codebase exploration and investigation
- "impl-1" using implementer agent - owns [Module A files]
- "impl-2" using implementer agent - owns [Module B files]
- "impl-3" using implementer agent - owns [Module C files]
- "tester" using tester agent - owns tests/**, runs test suite
- "reviewer" using reviewer agent - reviews completed modules

(adjust implementer count to match module count, max 4 concurrent implementers)
```

### Sub-agent Usage Guidelines

- **Direct (lead does it):** Single-file grep/search, reading a file for context, simple `.harness/PROGRESS-{feature}.md` updates, quick git operations
- **Delegate to sub-agent:** Multi-file implementation, cross-module investigation, full test suite execution, code review
- **Researcher:** Invoke ONLY when a module is stalled for 2+ rounds. Do NOT invoke for simple questions.
- **Concurrency cap:** Maximum 4 implementers active simultaneously.

### Spawn Context for Each Implementer

```
You own [actual/path/pattern/**] exclusively. NEVER edit files outside this path.
Your goal: make the following tests pass: [list of test names]
Read .harness/PROGRESS-{feature}.md for context, especially "Failed Approaches" section.
After making changes, message tester to run tests.
When done, message the team lead.

RULES:
- Implement the MINIMUM change needed to pass the target tests.
- Do not refactor, add abstractions, create helper utilities beyond what is required.
- If you want to create a new file or abstraction layer, message the lead first.
- NEVER hard-code values or write solutions that only work for specific test inputs.
- Do not remove, weaken, or skip any existing tests.

CONTEXT MANAGEMENT:
- Do NOT stop work early due to context window concerns.
- If context is running low, save state to .harness/PROGRESS-{feature}.md BEFORE reset.
- On fresh session, read: .harness/PROGRESS-{feature}.md, git log --oneline -20, failing test output.
```

### Initial Task Creation

1. Group failing tests by module (3-5 tests per task)
2. Create tasks with TaskCreate for each group
3. Assign to corresponding implementer
4. Set dependencies with addBlockedBy if modules depend on each other

## Phase 3: Harness Loop (Detail)

### Step-by-step Loop

**Step 1: Test** → Message tester with appropriate tier (quick/smoke/full)

**Step 2: Analyze** → Parse pass/fail counts per module, compare with previous `.harness/PROGRESS-{feature}.md`

**Step 3: Decide & Act**

| Condition | Action |
|-----------|--------|
| Regression detected | Message implementer IMMEDIATELY. Fix before any new work. |
| Module stalled (2+ rounds) | Message researcher to investigate. Add to Failed Approaches. |
| Test itself is wrong | Confirm with user. Only modify tests with approval. |
| Module complete | Message reviewer. Update status to "review". Reassign implementer. |
| Reviewer finds issues | Create fix tasks. Critical issues block "done" status. |

**Step 4: Track** → Update `.harness/PROGRESS-{feature}.md` after EVERY iteration (increment counter, module pass rates, blocking issues, failed approaches, mistake log)

**Step 5: Commit** → Each implementer commits on pass. Lead commits `.harness/PROGRESS-{feature}.md`. Regression fix uses `fix()` prefix.

**Step 6: Loop Guard** → IF iteration >= 10: Pause, report to user, let them decide.

### Parallelism Strategy by Pass Rate

- **0-80% (early):** Group by module, maximum parallelism
- **80-95% (mid):** Cluster by dependency graph, independent clusters parallel
- **95-100% (late):** Researcher investigates first, then single implementer sequential

### Mistake Recording Protocol

Record when ANY of the following occurs:
- Regression introduced (`technical`)
- Implementer worked on wrong files/tests (`communication`)
- Hard-coded solution submitted (`technical`)
- Over-engineered solution submitted (`scope`)
- Stall caused by unclear task description (`communication`)
- Test was wrong and required user adjustment (`process`)
- Duplicate work by multiple implementers (`process`)
- Sub-agent spawned unnecessarily (`process`)

Each entry MUST include a concrete **Prevention Rule**.

## Phase 4: Convergence (Detail)

1. Run full test suite → confirm 100% pass
2. Extract lessons learned from Mistake Log
3. Append to `~/.claude/skills/harness/LESSONS_LEARNED.md`:

```markdown
## [Project Name] - [Date]

### Mistakes & Prevention Rules
- [Prevention Rule 1]
- [Prevention Rule 2]

### What Worked Well
- [effective pattern]
```

4. **Delete `.harness/PROGRESS-{feature}.md`** (lessons already extracted to LESSONS_LEARNED.md)
5. If `.harness/` directory is empty after deletion, remove it
6. Final commit: `chore: mark project COMPLETE - all tests passing`
7. Shut down all teammates gracefully (shutdown_request)
8. Clean up team (TeamDelete)
9. Report to user: final pass rate, modules implemented, total iterations, key decisions, mistake summary, known limitations
