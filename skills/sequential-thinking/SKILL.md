---
name: sequential-thinking
description: "순차적 사고, 분석, 문제 해결, 복잡한 문제, 단계별 분석, 의사결정, 트레이드오프, 가설 검증, 비판적 검토, 설계 검증, 약점 분석, 반대 의견, 편향 점검 - Systematic step-by-step thinking for complex multi-step analysis. Use when making architectural decisions, evaluating trade-offs, critically reviewing designs, or solving problems that need step-by-step decomposition. Also use for devil's advocate analysis, bias detection, and design validation. Do NOT use for simple questions that can be answered directly."
model: opus
metadata:
  author: jaehashin
  version: 2.0.0
---

# Sequential Thinking Workflow

Claude의 내장 사고 능력을 활용한 단계적 분석 프로세스. 외부 MCP 없이 수행.

## Use Scenarios

1. **Complex Design Decisions**: Architecture selection, tech stack decisions
2. **Multi-step Problem Solving**: Bug root cause analysis, performance optimization strategy
3. **Uncertain Requirements**: Requirements interpretation, approach exploration
4. **Trade-off Analysis**: Comparing pros and cons of multiple options
5. **Refactoring Planning**: Code improvement strategy
6. **Critical Design Review**: 설계/아키텍처/계획의 비판적 검증. 약점 도출, 반대의견 검토, 인지 편향 점검, 근거 확인. → `references/critical-review-framework.md` 참조

## Thinking Process

```
1. 문제 분해 (Problem Decomposition)
   → 문제를 독립적 하위 질문으로 분할, 분석 단계 수 추정
   ↓
2. 단계별 분석 (Step-by-step Analysis)
   → 각 단계에 명확한 목적 부여, 이전 단계와 논리적 연결
   ↓
3. 검증/수정 (Verification & Revision)
   → 이전 단계의 결론을 재검토, 오류 발견 시 수정
   ↓
4. 가설 형성 및 검증 (Hypothesis Testing)
   → 대안 탐색, 분기 분석(A안 vs B안)
   ↓
5. 최종 결론 (Final Conclusion)
   → 근거 기반 결론 도출
```

## Checklist

**Before Starting:**
- [ ] 정말 복잡한 문제인가? (단순한 질문은 직접 답변)
- [ ] 단계적 사고가 도움이 되는가?
- [ ] 분석 단계 수 추정 (5-15단계)

**During Process:**
- [ ] 각 단계에 명확한 목적이 있는가?
- [ ] 이전 단계와 논리적으로 연결되는가?
- [ ] 막힌 부분: 이전 단계로 돌아가 재검토
- [ ] 대안 탐색: A안/B안 분기 분석 수행

**At Completion:**
- [ ] 충분한 답에 도달했는가?
- [ ] 가설이 충분히 검증되었는가?
- [ ] 결론이 근거에 기반하는가?

## Effective Usage Tips

- 초기 추정에 얽매이지 말고 필요한 만큼 단계를 추가
- 불확실한 부분은 솔직하게 불확실성을 표현
- 이전 결정이 잘못되었으면 명시적으로 수정
- 대안 비교 시 분기 분석(A안 vs B안)을 활용
- 현재 단계와 무관한 정보는 무시

## What to Avoid

- 단순한 질문에 과도한 분석 적용
- 결론에 도달하기 전 조기 종료
- 이전 단계와 논리적 연결 없는 분석
- 불확실한데 확실한 척하기

## Troubleshooting

**사고가 맴돌 때**: 막힌 지점을 명시적으로 재구성. 여전히 막히면 완전히 다른 각도에서 접근.
**분석 단계가 부족할 때**: 추가 단계를 이어서 진행. 초기 추정은 가이드일 뿐 제한이 아님.
**분석 마비 — 대안이 너무 많을 때**: 가장 강한 근거가 있는 안을 선택하고 커밋. 대안은 fallback으로 기록.

## Completion

근거 기반 최종 결론이 도출되면 완료. Critical Design Review Mode의 경우 5단계 결론(개선 항목 테이블) 전달 시 종료.

## Critical Design Review Mode

사용자가 "비판적 검토", "비판적 분석", "설계 검증", "약점 분석", "devil's advocate" 등을 요청하면 이 모드로 진입한다.

```
1단계: 비판 시나리오 3-5개 가정 (Devil's Advocate)
  ↓
2단계: 다각적 분석 2-3 관점 (성능/보안/유지보수성 등)
  ↓
3단계: 잠재 오류·편향 점검 (Anchoring, Confirmation, Complexity 등)
  ↓
4단계: 근거·출처 명시 (공식 문서, 업계 표준 레퍼런스)
  ↓
5단계: 결론 — 개선 항목 테이블 + 놓친 이슈 점검
```

상세 프레임워크는 `references/critical-review-framework.md` 참조.

## Integration with Code Exploration

For complex code work:
1. **Sequential Thinking**: Analyze requirements and establish approach strategy
2. **LSP / Grep**: Explore code structure and current state
3. **Sequential Thinking**: Analyze exploration results and design modifications
4. **LSP / Grep + Edit**: Perform actual code modifications
