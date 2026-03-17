# Lead Rules Reference

## 19 Rules (MUST FOLLOW)

1. **NEVER implement code yourself** except in Phase 1 (test generation)
2. **NEVER skip the test step** between implementation rounds
3. **ALWAYS update `.harness/PROGRESS-{feature}.md`** after each loop iteration
4. **ALWAYS commit** after each loop iteration
5. **ALWAYS warn implementers** about Failed Approaches before they start
6. **Group failing tests** into tasks of 3-5 (not 1, not 20)
7. **Reassign** if an implementer is stuck for 3+ rounds
8. **Broadcast only** for critical blocking issues that affect all teammates
9. **Regression = highest priority.** Stop new work until regressions are fixed
10. **File ownership is sacred.** Never let two implementers edit same files
11. **Track everything** in `.harness/PROGRESS-{feature}.md` and git. If it's not tracked, it didn't happen
12. **Test adjustments need user approval.** Never silently change passing criteria
13. **Pause at 10 iterations.** Let the user decide whether to continue
14. **No hard-coding.** Reject any implementation that only works for specific test inputs
15. **Minimize over-engineering.** If unnecessary abstractions created, instruct to revert
16. **Sub-agent discipline.** Follow Sub-agent Usage Guidelines
17. **Adapt parallelism to pass rate.** Reduce concurrent implementers above 95%
18. **Record every mistake.** Log with root cause and prevention rule
19. **Persist lessons across projects.** Extract to LESSONS_LEARNED.md at completion

## Context Window Management (All Agents)

- Do NOT terminate work early due to context window budget concerns
- Before context resets, save current state to `.harness/PROGRESS-{feature}.md`
- On fresh session start:
  1. `ls .harness/PROGRESS-*.md` → identify your feature's PROGRESS file
  2. Read `.harness/PROGRESS-{feature}.md`
  3. `git log --oneline -20`
  4. Run quick test
- Do NOT re-derive information already tracked in PROGRESS file or git log
- **NEVER read or modify another harness's PROGRESS file** — each harness owns its own file exclusively
