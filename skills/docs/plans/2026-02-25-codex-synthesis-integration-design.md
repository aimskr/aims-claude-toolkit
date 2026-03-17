# Codex Synthesis Integration Design

## Overview

Claude 스킬 실행 시 OpenAI Codex를 병렬로 호출하여 독립 분석을 수행하고, 두 AI의 관점을 합성하여 관점 다양성이 확보된 통합 리포트를 생성한다.

## Goals

1. **관점 다양성**: Claude와 Codex가 독립적으로 분석하여 편향 없는 다중 관점 확보
2. **자동 통합**: 대상 스킬 실행 시 항상 자동으로 Codex를 병렬 호출
3. **통합 리포트**: 일치/불일치/고유 인사이트를 구조화하여 사용자에게 제공
4. **유지보수성**: 공유 모듈 패턴으로 Codex 설정을 한 곳에서 관리

## Key Requirements

- **대상 스킬**: code-reviewer, prd-strategist, research (3개)
- **제외**: brainstorming (대화형이라 지연 시간 이슈)
- **Codex 설정**: gpt-5.3-codex / high effort / read-only sandbox (고정)
- **실행 방식**: 백그라운드 병렬 실행 (Claude 분석과 동시)
- **합성 프레임워크**: Consensus / Divergence / Unique Insights 3영역

## File Structure

```
skills/
  codex-synthesis.md              ← NEW: 공유 모듈 (Codex 호출 + 합성 프레임워크)
  code-reviewer/SKILL.md          ← MODIFIED: Codex 통합 스텝 추가
  prd-strategist/SKILL.md         ← MODIFIED: Codex 통합 스텝 추가
  research/SKILL.md               ← MODIFIED: Codex 통합 스텝 추가
```

## Detailed Design

### 1. 공유 모듈: `codex-synthesis.md`

Codex 호출 설정, 프롬프트 조립 방법, 합성 프레임워크를 담는 공유 모듈.

#### 1.1 Codex 호출 설정

```
모델: gpt-5.3-codex
Reasoning effort: high
Sandbox: read-only
명령어 패턴:
  echo "<prompt>" | codex exec --skip-git-repo-check \
    -m gpt-5.3-codex \
    --config model_reasoning_effort="high" \
    --sandbox read-only \
    -C <working-dir> \
    2>/dev/null
```

- 항상 `--skip-git-repo-check` 사용
- 항상 `2>/dev/null`로 thinking tokens 억제
- Bash `run_in_background: true`로 백그라운드 실행

#### 1.2 프롬프트 구조

```
You are an independent analyst providing a second opinion.
Context: [스킬별 컨텍스트]
Task: [스킬별 분석 지시]

IMPORTANT: Analyze independently. Do not assume any prior analysis exists.
Provide your findings in this structure:
1. Key Findings (3-7 items, severity-ranked)
2. Recommendations
3. Concerns / Risks
4. What others might miss
```

#### 1.3 스킬별 프롬프트 템플릿

**code-reviewer:**
```
Context: Code review of [target files/PR description]
Task: Review this code for architecture violations, hidden bugs,
security vulnerabilities, performance issues, and testing gaps.
Rate each finding: Critical / High / Medium / Low.
Focus especially on what a first reviewer might overlook.
```

**prd-strategist:**
```
Context: Product planning for [project name].
Target: [audience], Problem: [problem], Solution: [solution], Platform: [platform]
Task: Analyze this product concept. Identify:
1. Risks and blind spots in the approach
2. Missing requirements or edge cases
3. Alternative approaches worth considering
4. MVP scope concerns (too broad or too narrow?)
```

**research:**
```
Context: Research on [topic] for [purpose].
Task: Independently research this topic. Provide:
1. Key findings with sources
2. Common misconceptions about this topic
3. Gaps in typical analysis
4. Contrarian or unconventional perspectives
```

#### 1.4 합성 프레임워크

Codex 결과 수집 후, Claude가 아래 3영역으로 분류:

| 영역 | 정의 | 처리 방식 |
|------|------|----------|
| **Consensus** | 양쪽 동의하는 발견 | 높은 신뢰도로 표시 |
| **Divergence** | 의견이 다른 부분 | 양쪽 근거를 나란히 제시, Claude가 평가 |
| **Unique Insights** | 한쪽만 발견한 것 | 추가 가치로 포함, 검증 필요 여부 표시 |

**합성 시 Claude의 역할:**
- Codex 결과를 **비판적으로 평가** (맹목적 수용 금지)
- Codex의 knowledge cutoff 차이를 감안
- 불일치 시 **양쪽 근거를 모두 제시**하고 Claude의 판단 근거를 명시
- Codex가 틀렸다고 판단되면 이유와 함께 명시

#### 1.5 통합 리포트 섹션 (기존 리포트에 추가)

```markdown
## AI Peer Analysis (Claude + Codex)

### Consensus (높은 신뢰도)
- [양쪽 동의 사항 1]
- [양쪽 동의 사항 2]

### Divergent Views
- **[주제]**: Claude는 [X]로 판단, Codex는 [Y]로 판단
  - Claude 근거: ...
  - Codex 근거: ...
  - 종합 평가: ...

### Unique Insights from Codex
- [Claude가 놓쳤을 수 있는 관점 1]
- [Claude가 놓쳤을 수 있는 관점 2]

### Synthesis Conclusion
[두 AI의 분석을 종합한 최종 결론. 신뢰도가 높아진 항목과 추가 검토가 필요한 항목 구분.]
```

### 2. code-reviewer 통합

#### 변경 내용

워크플로우에 Codex 병렬 분석 스텝 추가:

```
[기존] Initial review → findings report → Re-review → Final approval

[변경] Initial review 시작 시:
  ├── Claude: 기존 5개 Focus Area 리뷰
  └── Codex: 백그라운드 독립 리뷰 (codex-synthesis.md 참조)
       ↓
  합성: 통합 리뷰 리포트 (기존 포맷 + "AI Peer Analysis" 섹션)
       ↓
  Re-review loop (수정 시 Codex 재호출은 선택적)
  Final approval
```

#### 추가할 내용 (SKILL.md)

```markdown
## Codex Parallel Review

리뷰 시작 시 `codex-synthesis.md`를 참조하여 Codex를 백그라운드로 병렬 실행한다.

1. 리뷰 대상 코드를 Codex에게 전달 (code-reviewer 프롬프트 템플릿 사용)
2. Claude는 기존 리뷰를 수행
3. Codex 결과 수집 후 합성 프레임워크 적용
4. 최종 리뷰 리포트에 "AI Peer Analysis" 섹션 추가

Re-review 시에는 변경된 부분이 Critical/High인 경우에만 Codex를 재호출.
```

### 3. prd-strategist 통합

#### 변경 내용

Input Collection 완료 후 PRD 작성 시점에 Codex 병렬 분석:

```
[기존] Input → Problem Deep Dive → Competitive Analysis → Draft PRD → Review

[변경] Input Collection 완료 후:
  ├── Claude: PRD 초안 작성
  └── Codex: 동일 입력으로 독립 분석 (prd-strategist 프롬프트 템플릿)
       ↓
  합성: PRD에 "AI Peer Analysis" 섹션 추가
    - MVP 범위에 대한 Codex의 다른 시각
    - Codex가 발견한 추가 리스크
    - 기술 스택/아키텍처에 대한 다른 의견
       ↓
  Review & Refine → Export
```

#### 추가할 내용 (SKILL.md)

```markdown
## Codex Parallel Analysis

PRD 초안 작성 시작 시 `codex-synthesis.md`를 참조하여 Codex를 병렬 실행한다.

1. 수집된 5가지 필수 입력을 Codex에게 전달 (prd-strategist 프롬프트 템플릿)
2. Claude는 기존 PRD 초안 작성
3. Codex 결과 수집 후 합성 프레임워크 적용
4. PRD Section 8 (Risks & Decisions)에 Codex 관점 반영
5. 별도 "AI Peer Analysis" 섹션을 PRD 마지막에 추가
```

### 4. research 통합

#### 변경 내용

기존 병렬 전문가 체계에 Codex를 추가 전문가로 합류:

```
[기존] 전문가 할당 → 병렬 조사 → 교차 검증 → 리포트

[변경] 전문가 할당 시:
  기존 전문가들 + Codex (추가 독립 전문가)
       ↓
  병렬 조사 (기존 에이전트들 + Codex 동시 실행)
       ↓
  교차 검증 (기존 전문가 간 + Codex 결과 포함)
       ↓
  리포트 (기존 포맷 + Codex 전문가 영역 포함)
```

#### 추가할 내용 (SKILL.md)

```markdown
## Codex 독립 전문가

병렬 조사 시 `codex-synthesis.md`를 참조하여 Codex를 추가 전문가로 투입한다.

1. 전문가 할당 시 Codex를 "독립 분석가"로 추가
2. 다른 전문가와 동시에 Codex 백그라운드 실행 (research 프롬프트 템플릿)
3. Step 3 교차 검증 시 Codex 결과도 포함하여 검증
4. 리포트의 "핵심 발견사항"에 Codex 전문가 섹션 추가
5. "AI Peer Analysis" 섹션에서 기존 전문가와 Codex의 차이점 분석
```

## Implementation Order

1. **`codex-synthesis.md` 생성** — 공유 모듈 (Codex 호출 설정 + 합성 프레임워크)
2. **`code-reviewer/SKILL.md` 수정** — Codex Parallel Review 섹션 추가
3. **`prd-strategist/SKILL.md` 수정** — Codex Parallel Analysis 섹션 추가
4. **`research/SKILL.md` 수정** — Codex 독립 전문가 섹션 추가
5. **`CLAUDE.md` 업데이트** — Integrated Workflows에 Codex 자동 통합 반영

## Verification

- [ ] `codex-synthesis.md`가 올바른 Codex 명령어 패턴을 포함하는지 확인
- [ ] 각 스킬의 기존 워크플로우가 깨지지 않았는지 확인
- [ ] Codex 호출이 `run_in_background: true`로 병렬 실행되는지 확인
- [ ] 합성 프레임워크 (Consensus/Divergence/Unique) 포맷이 일관적인지 확인
- [ ] 실제 스킬 실행 시 Codex 호출 → 합성 → 통합 리포트 생성이 작동하는지 테스트
