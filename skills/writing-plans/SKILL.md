---
name: writing-plans
description: "계획, 구현 계획, 플랜 작성, 작업 계획, 구현 플랜, 플랜 저장, TODO 저장, 계획 캡처, plan 저장, 플랜 캡처 - Creates detailed implementation plans with bite-sized tasks and TDD steps. Also captures Plan mode output to structured markdown. Use when planning multi-step implementations before coding, or saving Plan mode output. Do NOT use for brainstorming (use brainstorming) or PRD/product strategy (use prd-strategist)."
tools: Read, Write, Grep, Glob
model: opus
metadata:
  author: jaehashin
  version: 1.2.0
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** This should be run in a dedicated worktree (created by brainstorming skill).

**Save plans to:** `docs/plans/NNNN.YYYY-MM-DD-<feature-name>.md` (NNNN: 해당 폴더 내 최대 번호 + 1, 없으면 0001)

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

**Constraints:**
- Technical: [기술 스택/인프라/호환성 제약]
- Resource: [시간/인원/예산/환경 제약]
- Business: [법적/규제/계약/정책 제약]
- Scope: [하지 않을 것, 범위 외]

**Business Rules:**
| Rule | Rationale (근거) | Source (출처) |
|------|-------------------|---------------|
| [도메인 규칙] | [왜 이렇게 결정했는가] | [출처] |

> 상위 문서(brainstorming design / PRD)에서 Constraints와 Business Rules를 인계받아 기재한다. 상위 문서가 없으면 사용자에게 직접 확인한다.

---
```

## Task Structure

```markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

**Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

**Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

**Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

**Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
```

## Plan Sanity Check (Devil's Advocate)

플랜을 파일에 저장하기 직전, 아래 3가지를 자가 점검하고 결과를 사용자에게 공유:

1. **순서 공격**: "Task 순서를 뒤집거나 병합하면 더 효율적이지 않은가?"
2. **누락 점검**: "가장 간과하기 쉬운 엣지 케이스 또는 의존성은?"
3. **복잡도 공격**: "이 계획이 과도하게 복잡하지 않은가? Task 수를 절반으로 줄일 수 있는가?"

> 계획 단계에서 발견하면 코스트 1, 구현 중 발견하면 코스트 10.
> 점검 결과 문제가 있으면 수정 후 저장. 문제 없으면 그대로 진행.

## Remember
- Exact file paths always
- Complete code in plan (not "add validation")
- Exact commands with expected output
- Reference relevant skills with @ syntax
- DRY, YAGNI, TDD, frequent commits

---

## Plan Mode Output Capture

Capture TODO lists generated from Plan mode and save them as structured markdown files.

**Triggers:** "플랜 저장해줘", "TODO 저장", "계획 캡처", "save plan", "capture plan"

**Announce at start:** "I'm capturing the Plan mode output to save as structured markdown."

### Storage Mode Selection

Ask user first:

**"How would you like to save the Plan output?**

1. **Task-based** - Each TODO as separate file (enables parallel work)
2. **Step-based** - Single file with sequential checklist (single workflow)

**Please choose."**

### Task-based Storage

Save each TODO as separate file:

**Location:** `docs/plans/<feature>/`

```
docs/plans/<feature>/
├── _index.md           # Overview + task links
├── task-01-<n>.md
├── task-02-<n>.md
└── task-03-<n>.md
```

**_index.md format:**

```markdown
# [Feature Name] Implementation Plan

**Created:** YYYY-MM-DD HH:mm
**Status:** In Progress

## Overview
[Context analyzed from Plan mode]

## Task List

| # | Task | Status | File |
|---|------|--------|------|
| 1 | [Task name] | ⬜ | [task-01-name.md](./task-01-name.md) |
| 2 | [Task name] | ⬜ | [task-02-name.md](./task-02-name.md) |

## Dependencies
[Task dependency description]
```

**Individual task file format:**

```markdown
# Task 1: [Task Name]

**Status:** ⬜ Pending | 🔄 In Progress | ✅ Complete
**Estimated time:** N min
**Dependencies:** None | After Task N

## Goal
[What this task achieves]

## Work Items

### Step 1: [Step name]
- [ ] Detail 1
- [ ] Detail 2

### Step 2: [Step name]
- [ ] Detail

## Related Files
- `path/to/file.py`

## Completion Criteria
- [ ] Tests pass
- [ ] Code review complete
```

### Step-based Storage

Single file with sequential checklist:

**Location:** `docs/plans/NNNN.YYYY-MM-DD-HHmm-<feature>.md`

```markdown
# [Feature Name] Implementation Plan

**Created:** YYYY-MM-DD HH:mm
**Status:** In Progress

## Overview
[Context analyzed from Plan mode]

---

## Checklist

### Phase 1: [Phase name]
- [ ] Step 1: [Description]
- [ ] Step 2: [Description]
- [ ] Step 3: [Description]

### Phase 2: [Phase name]
- [ ] Step 4: [Description]
- [ ] Step 5: [Description]

---

## Progress Log

| Time | Completed Item | Notes |
|------|----------------|-------|
| | | |
```

### Required Information to Capture

Always extract from Plan mode output:

1. **Context** - Why this work is being done
2. **TODO list** - All work items
3. **Dependencies** - Items with ordering constraints
4. **Related files** - Files to modify/create
5. **Decisions** - Technical decisions made during planning

### Post-save Message

```
✅ Plan saved!

📁 Location: docs/plans/<path>
📋 Tasks: N items

Next steps:
1. Review saved files
2. Modify if needed
3. To start execution, say "execute plan" or "플랜 실행해줘"
```

---

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `docs/plans/<filename>.md`. Two execution options:**

**1. Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration

**2. Parallel Session (separate)** - Open new session with executing-plans, batch execution with checkpoints

**Which approach?"**

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
- Stay in this session
- Fresh subagent per task + code review

**If Parallel Session chosen:**
- Guide them to open new session in worktree
- **REQUIRED SUB-SKILL:** New session uses superpowers:executing-plans

## Completion

플랜이 `docs/plans/`에 저장되고 실행 방식(Subagent-Driven / Parallel Session)이 선택되면 완료.

## Troubleshooting

**Plan tasks are too large (>5 minutes each)**: Split further. Each step should be one action: write test, run test, implement, commit. If a step has "and", it's two steps.
**User's Plan mode output is unstructured**: Extract TODO items manually. Look for numbered lists, bullet points, or action verbs. Ask user to confirm the extracted task list before saving.
**Plan becomes outdated during implementation**: Plans are living documents. Update the plan file as decisions change. Add a "Changes from original plan" section at the bottom.
