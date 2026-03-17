---
name: doc-coauthoring
description: "문서 작성, 문서화, 문서, 스펙 작성, 기술 문서, 제안서, RFC, 설계 문서, 의사결정 문서 - Collaborative document co-authoring through 3 stages: context gathering, iterative refinement, and reader testing. Use when writing docs, proposals, tech specs, decision docs, or RFCs. Do NOT use for PRD/product requirements (use prd-strategist) or implementation plans (use writing-plans)."
tools: Read, Write, Edit, Grep, Glob
model: opus
metadata:
  author: jaehashin
  version: 1.2.0
---

# Doc Co-Authoring Workflow

Guide users through collaborative document creation via three stages.

## When to Offer This Workflow

**Trigger conditions:**
- User mentions writing documentation: "write a doc", "draft a proposal", "create a spec"
- User mentions specific doc types: "PRD", "design doc", "decision doc", "RFC"
- User seems to be starting a substantial writing task

## The Three Stages

### Stage 1: Context Gathering
- Ask meta-context questions (doc type, audience, desired impact)
- Encourage info dumping (background, discussions, constraints)
- Ask 5-10 clarifying questions to close knowledge gaps
- **Exit when:** Edge cases and trade-offs can be discussed without needing basics

### Stage 2: Refinement & Structure
For each section:
1. Ask clarifying questions
2. Brainstorm 5-20 options
3. User curates (keep/remove/combine)
4. Draft the section
5. Iterative refinement via `str_replace`

**Section order:** Start with most unknowns, leave summary for last

### Stage 3: Reader Testing
- Predict 5-10 reader questions
- Test with fresh Claude (sub-agent or new session)
- Check for ambiguity, assumptions, contradictions
- Fix any gaps found

## Key Principles

- **One question at a time** - Don't overwhelm
- **Surgical edits** - Use `str_replace`, never reprint whole doc
- **Quality over speed** - Each iteration should improve meaningfully
- **User agency** - Let them skip or adjust the process

## Detailed Reference

For complete stage instructions, tips, and handling edge cases:
**Read `REFERENCE.md` in this skill directory when needed.**

## Completion

Stage 3 Reader Testing을 통과하고 최종 문서가 사용자 승인을 받으면 완료.

## Troubleshooting

**User dumps a wall of text with no structure**: Start Stage 1 — ask meta-context questions to organize their input into sections before attempting to structure.
**User wants to skip straight to writing**: Confirm they have audience and purpose clear. If yes, jump to Stage 2 with their existing outline. If no, brief Stage 1.
**Reader testing reveals fundamental gaps**: Don't patch — return to Stage 2 for the affected section. Rewrite based on new understanding.
