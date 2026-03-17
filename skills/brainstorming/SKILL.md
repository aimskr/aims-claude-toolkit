---
name: brainstorming
description: "브레인스토밍, 아이디어, 기획, 구상, 아이디어회의, 설계, 요구사항 분석, 접근법 탐색 - Use before creating new features or significant changes to explore user intent, requirements, and design options. Collaborative brainstorming through step-by-step questioning. Do NOT use for simple bug fixes, config changes, or tasks with clear requirements already defined."
tools: Read, Grep, Glob, Write
model: opus
metadata:
  author: jaehashin
  version: 1.3.0
---

# Brainstorming Ideas Into Designs

## Overview

Help turn ideas into fully formed designs and specs through natural collaborative dialogue.

Start by understanding the current project context, then ask questions one at a time to refine the idea. Once you understand what you're building, present the design in small sections (200-300 words), checking after each section whether it looks right so far.

## The Process

**Understanding the idea:**
- Check out the current project state first (files, docs, recent commits)
- Ask questions one at a time to refine the idea
- Prefer multiple choice questions when possible, but open-ended is fine too
- Only one question per message - if a topic needs more exploration, break it into multiple questions
- Focus on understanding: purpose, success criteria

**Constraints 수집 (반드시 질문):**
아이디어 파악 후, 아래 4분류를 각각 질문하여 제약조건을 수집한다:
- **Technical**: 기술 스택, 인프라, 호환성 한계 (예: "기존 DB 유지?", "특정 언어/프레임워크 제약?")
- **Resource**: 시간, 인원, 예산, 환경 (예: "데드라인?", "1인 개발?", "서버 비용 한도?")
- **Business**: 법적/규제, 계약, 정책 (예: "개인정보보호법 적용?", "외부 API 계약 조건?")
- **Scope**: 하지 않을 것, 범위 외 (예: "MVP에서 명시적으로 제외할 것?")

> 사용자가 "없다"고 답해도 기록한다. 명시적 "제약 없음"은 암묵적 누락과 다르다.

**Business Rules 수집:**
제약조건 확인 후, 핵심 비즈니스 규칙을 질문한다:
- "이 서비스에서 반드시 지켜야 하는 도메인 규칙이 있는가?"
- "그 규칙의 근거(법령, 정책, 관행)는 무엇인가?"
- 각 규칙에 대해 Rule(무엇) / Rationale(왜) / Source(출처)를 확인

**Exploring approaches:**
- Propose 2-3 different approaches with trade-offs
- Present options conversationally with your recommendation and reasoning
- Lead with your recommended option and explain why

**Devil's Advocate checkpoint (접근법 확정 직전):**
- 추천한 접근법의 **가장 큰 약점 1가지**를 명시적으로 제시
- 사용자에게 질문: "이 접근법이 실패한다면 가장 큰 이유는 무엇일까요?"
- 사용자가 약점을 인지한 상태에서 최종 선택하도록 유도
- devil-advocate 스킬의 프레임워크 적용: 전제 공격 + 반례 제시 (각 1문장)
- 이 단계를 건너뛰지 않을 것 — 약점을 모른 채 진행하면 설계 품질이 저하됨

**Presenting the design:**
- Once you believe you understand what you're building, present the design
- Break it into sections of 200-300 words
- Ask after each section whether it looks right so far
- Cover: architecture, components, data flow, error handling, testing
- Be ready to go back and clarify if something doesn't make sense

## After the Design (MANDATORY)

**Documentation (MUST DO IMMEDIATELY after user approval):**
- IMMEDIATELY write the validated design to `docs/plans/NNNN.YYYY-MM-DD-<topic>-design.md` (NNNN: 해당 폴더 내 최대 번호 + 1, 없으면 0001)
- This is NOT optional - do this BEFORE any implementation
- Include in the document:
  - Overview and goals
  - Key requirements summary
  - Constraints (Technical / Resource / Business / Scope 4분류)
  - Business Rules (Rule / Rationale / Source 테이블)
  - File structure (new/modified files list)
  - Detailed design (with code examples)
  - Implementation order (separable into TODO items)
  - Verification methods

**TODO Generation (MUST DO after documentation):**
- Create implementation tasks from the design
- Each TODO should be ONE independent work unit
- TODO order must match implementation order

**PRD Handoff (Large feature / New project만):**
- 다중 모듈, 새 도메인, 새 프로젝트인 경우에만 `prd-strategist` 호출
- Pass the design document path as context
- **Small feature (단일 모듈, 명확한 요구사항)에서는 PRD 스킵** → 바로 `writing-plans`로 직행

**Implementation (if continuing):**
- `writing-plans`를 호출하여 구현 계획 작성
- Create isolated workspace if applicable

## Key Principles

- **One question at a time** - Don't overwhelm with multiple questions
- **Multiple choice preferred** - Easier to answer than open-ended when possible
- **YAGNI ruthlessly** - Remove unnecessary features from all designs
- **Explore alternatives** - Always propose 2-3 approaches before settling
- **Incremental validation** - Present design in sections, validate each
- **Be flexible** - Go back and clarify when something doesn't make sense

## Completion

설계가 `docs/plans/`에 저장되고 TODO가 생성되면 완료.

## Troubleshooting

**User gives vague idea with no constraints**: Ask "What would make this a failure?" to surface hidden requirements and scope boundaries.
**Design discussion going too long**: After 10+ exchanges without convergence, pause and summarize what's been decided so far. Present remaining open questions as a numbered list.
**Conflicting requirements discovered mid-design**: Stop, present the conflict explicitly with trade-offs, and ask user to choose before continuing.
**User wants to skip brainstorming and jump to code**: Confirm they have clear requirements. If yes, hand off to writing-plans or feature-development. If no, explain that 10 minutes of brainstorming saves hours of rework.
**Design keeps expanding in scope**: Restate the original goal. Apply YAGNI: "Which of these features validates the core idea?"
