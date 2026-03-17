---
name: feature-development
description: "기능 개발, 기능 구현, 신규 개발, 피처 개발, 개발 워크플로우 - Guided feature development with codebase understanding and architecture focus. Systematic 7-phase approach from discovery to implementation. Use when building new features or adding significant functionality. Do NOT use for simple bug fixes, config changes, or single-file edits."
metadata:
  author: jaehashin
  version: 1.2.0
  category: development
  tags: [feature, implementation, workflow, architecture]
argument-hint: Optional feature description
tools: Read, Write, Edit, Bash, Grep, Glob
model: opus
---

# Feature Development Workflow

Systematic approach: understand codebase → clarify requirements → design → implement.

## Core Principles

- **Ask clarifying questions**: Identify all ambiguities before implementation
- **Understand before acting**: Read existing code patterns first
- **Library-First**: Search for existing solutions before custom code
- **Simple and elegant**: Prioritize readable, maintainable code
- **Use TodoWrite**: Track all progress

## Execution Mode

**New feature** (기본): Phase 1부터 전체 실행
**Modify feature**: 기존 기능 수정 시. Phase 2(Exploration)부터 시작. 기존 스펙 문서를 먼저 읽고, 새 문서를 만들지 않고 Changelog를 추가한다.

> Modify 모드 진입 조건: 사용자가 기존 기능의 변경/확장을 요청하고, `docs/plans/`에 해당 기능의 스펙 문서가 이미 존재하는 경우.

## Phase Overview

```
Phase 1: Discovery        → What are we building? (Modify 모드: 스킵 — 기존 스펙 문서 참조)
Phase 2: Exploration      → How does existing code work?
Phase 3: Questions        → What's unclear? (DON'T SKIP!)
Phase 4: Architecture     → How should we build it?
Phase 5: Implementation   → Build it (after approval)
Phase 6: Review           → Is it good?
Phase 7: Documentation    → Update spec doc with Changelog (DON'T SKIP!)
```

For detailed steps in each phase, see `references/phase-details.md`.

## Key Phase Summaries

### Phase 1-2: Discovery & Exploration
Create todo list → Launch parallel `code-explorer` agents → Build deep understanding

### Phase 3: Clarifying Questions ⚠️ CRITICAL
Identify ALL underspecified aspects → Present questions → **Wait for answers**

### Phase 4: Architecture Design
Launch parallel architect agents (Minimal / Clean / Pragmatic) → Present trade-offs → **Ask user preference**

### Phase 4.5: Implementation Gate (Devil's Advocate - 경량)

구현 돌입 전 30초 체크 — 아래 2가지를 사용자에게 간결하게 공유:

- "이 설계에서 **가장 먼저 깨질 부분**은 어디인가?" (1문장)
- "**테스트하기 가장 어려운 부분**은?" (1문장)

> 블로커가 아닌 인지 도구. 1-2문장으로 답하고 바로 Phase 5로 진행.
> 심각한 문제가 발견되면 Phase 4로 돌아가서 설계 수정.

### Phase 5: Implementation
**⛔ DO NOT START WITHOUT USER APPROVAL**
Library-first → Follow codebase conventions → Update todos

### Phase 6-7: Review & Documentation
Launch reviewer agents → Address findings →

- **New feature**: `docs/plans/NNNN.YYYY-MM-DD-<feature>-summary.md` 생성 (NNNN: 해당 폴더 내 최대 번호 + 1, 없으면 0001)
- **Modify feature**: 기존 스펙 문서에 Changelog 항목 추가 (새 문서 생성 금지)

**Changelog 포맷:**
```markdown
## Changelog

### vN — YYYY-MM-DD
**변경**: 무엇을 변경했는지 (1줄)
**이유**: 왜 변경했는지 (1줄)
**영향 범위**: 변경된 모듈/파일 목록
**관련 커밋**: conventional commit 메시지
```

## Implementation Guidelines

Follow Karpathy Guidelines for all code changes. See `references/karpathy-guidelines.md`.

Key points:
- Think before coding, state assumptions explicitly
- Implement only what's requested (YAGNI)
- Surgical changes — don't "improve" adjacent code
- Verifiable goals for every change

## 문서화 (Phase 7 완료 후 자동 실행)

작업 완료 시 `auto-documenter`를 호출하여 프로젝트 문서를 업데이트한다.

## Completion

- **New feature**: Phase 7 완료: 기능 구현 + 리뷰 통과 + `docs/plans/NNNN.YYYY-MM-DD-<feature>-summary.md` 생성.
- **Modify feature**: Phase 7 완료: 기능 수정 + 리뷰 통과 + 기존 스펙 문서에 Changelog 항목 추가.

## Anti-Patterns to Avoid

- **NIH (Not Invented Here)**: Rebuilding what already exists
- **Premature Optimization**: Unnecessary optimization
- **Over-Engineering**: Excessive abstraction for simple tasks
- **Skipping Questions**: Making assumptions instead of asking

## Troubleshooting

**User says "just do it" when asked clarifying questions**: Provide your best recommendation with stated assumptions. Document assumptions in the summary so they can be corrected later.
**Codebase has no clear patterns to follow**: Fall back to the project's language/framework conventions. Document the new pattern as a precedent.
**Phase 5 implementation diverges from Phase 4 design**: Stop, compare, and ask user whether to adjust design or revert implementation. Never silently deviate from approved architecture.
