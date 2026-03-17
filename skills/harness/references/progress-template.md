# PROGRESS Template

> **File**: `.harness/PROGRESS-{feature-name}.md`
> Phase 0에서 feature 이름(kebab-case)을 확정한 뒤, 이 템플릿으로 생성한다.

```markdown
# Harness: {feature-name}

## Status: PHASE 0 - SPEC INTAKE
## Pass Rate: 0/0 (0%)
## Last Updated: [timestamp]
## Iteration: 0 / max 10

## Module Ownership

| Module | Tests | Pass | Fail | Owner | Status |
|--------|-------|------|------|-------|--------|
| [module] | 0 | 0 | 0 | [owner] | not_started |

## Recent Progress
- [timestamp] Project initialized from spec

## Blocking Issues
- (none)

## Failed Approaches (DO NOT RETRY)
- (none)

## Mistake Log

| # | Iteration | Category | What Happened | Root Cause | Prevention Rule |
|---|-----------|----------|---------------|------------|----------------|
| (none) | | | | | |

Categories: `process` (workflow/decision error), `technical` (wrong approach/implementation), `communication` (misassignment/unclear task), `scope` (over/under-engineering)
```
