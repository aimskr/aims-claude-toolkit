# Codex Synthesis Module

Codex를 병렬로 호출하여 독립 분석을 수행하고, Claude의 분석과 합성하여 통합 리포트를 생성하는 공유 모듈.

대상 스킬: code-reviewer, prd-strategist, research

## Codex 호출 설정

| 항목 | 값 |
|------|---|
| 모델 | gpt-5.3-codex |
| Reasoning effort | high |
| Sandbox | read-only |
| 추가 플래그 | --skip-git-repo-check |
| stderr 처리 | 임시 파일로 리다이렉트 (실패 시 진단용) |

### 명령어 패턴

```bash
CODEX_STDERR=$(mktemp)
cat <<'CODEX_PROMPT' | codex exec --skip-git-repo-check \
  -m gpt-5.3-codex \
  --config model_reasoning_effort="high" \
  --sandbox read-only \
  -C <working-dir> \
  2>"$CODEX_STDERR"
<prompt content here>
CODEX_PROMPT
```

- **heredoc 사용**: `echo`가 아닌 `cat <<'CODEX_PROMPT'` heredoc으로 프롬프트 전달. 따옴표, 줄바꿈, 백틱이 포함된 코드도 안전하게 전달.
- **stderr 보존**: `2>/dev/null` 대신 임시 파일로 리다이렉트. 성공 시 무시, 실패 시 진단에 활용.
- Bash `run_in_background: true`로 실행하여 Claude 분석과 병렬 처리
- Claude가 자체 분석을 완료한 후 Codex 결과를 수집
- 실패 시 `cat "$CODEX_STDERR"`로 원인 확인 후 Claude 단독 진행

## 프롬프트 구조

모든 스킬에서 Codex에게 전달하는 프롬프트의 공통 구조:

```
You are an independent analyst providing a second opinion.
You are NOT seeing any prior analysis — analyze from scratch.

Context: [스킬별 컨텍스트]
Task: [스킬별 분석 지시]

Provide your findings in this structure:
1. Key Findings (3-7 items, severity-ranked where applicable)
2. Recommendations
3. Concerns / Risks
4. What others might miss (blind spots, unconventional perspectives)
```

## 스킬별 프롬프트 템플릿

### code-reviewer

```
You are an independent code reviewer providing a second opinion.
You are NOT seeing any prior review — review from scratch.

Review target: [대상 파일/PR 설명]

Review this code focusing on:
1. Architecture violations or design concerns
2. Hidden bugs, edge cases, race conditions
3. Security vulnerabilities (OWASP Top 10)
4. Performance bottlenecks
5. Testing gaps
6. What a first reviewer might overlook

Rate each finding: Critical / High / Medium / Low.
```

### prd-strategist

```
You are an independent product analyst providing a second opinion.
You are NOT seeing any prior analysis — analyze from scratch.

Product concept:
- Project: [project name]
- Target: [audience]
- Problem: [problem statement]
- Solution: [core solution]
- Platform: [platform]

Analyze this product concept:
1. Risks and blind spots in the approach
2. Missing requirements or edge cases the team might overlook
3. Alternative approaches worth considering
4. MVP scope assessment — too broad or too narrow?
5. Technical feasibility concerns
```

### research

```
You are an independent research analyst providing a second opinion.
You are NOT seeing any prior research — analyze from scratch.

Research topic: [topic]
Research purpose: [purpose]

IMPORTANT: You do NOT have web access. Your analysis is based on training data only.
For every claim, clearly indicate:
- If you are confident (based on well-known facts in your training data), state it directly.
- If you are uncertain or the information may be outdated, prefix with "[Training data estimate]".
- Do NOT fabricate URLs, paper titles, or specific statistics you cannot verify.

Independently research this topic and provide:
1. Key findings with reasoning (mark confidence level for each)
2. Common misconceptions about this topic
3. Gaps that typical analysis misses
4. Contrarian or unconventional perspectives
5. Areas of uncertainty that need further investigation
```

## 합성 프레임워크

Codex 결과 수집 후, Claude가 아래 3영역으로 분류한다.

| 영역 | 기호 | 정의 | 처리 방식 |
|------|------|------|----------|
| **Consensus** | ✅ | 양쪽 동의하는 발견 | 높은 신뢰도로 표시 |
| **Divergence** | ⚡ | 의견이 다른 부분 | 양쪽 근거를 나란히 제시, Claude가 평가 |
| **Unique Insights** | 💡 | 한쪽만 발견한 것 | 추가 가치로 포함, 검증 필요 여부 표시 |

### 합성 시 Claude의 역할

- Codex 결과를 **비판적으로 평가**한다 (맹목적 수용 금지)
- Codex의 knowledge cutoff 차이를 감안한다
- 불일치 시 **양쪽 근거를 모두 제시**하고 Claude의 판단 근거를 명시한다
- Codex가 틀렸다고 판단되면 이유와 함께 명시한다
- Codex가 옳다고 판단되면 솔직하게 인정한다

### Codex가 틀렸을 때

1. 불일치 사항을 명시
2. 근거 제시 (자체 지식, 웹 검색, 문서)
3. 필요시 Codex 세션을 resume하여 토론:
   ```bash
   cat <<'CODEX_PROMPT' | codex exec --skip-git-repo-check resume --last 2>/dev/null
   This is Claude following up. I disagree with [X] because [evidence]. What's your take?
   CODEX_PROMPT
   ```
4. 사용자에게 판단을 맡기는 것이 원칙

## 통합 리포트 섹션

기존 스킬의 리포트에 아래 섹션을 추가한다:

```markdown
## AI Peer Analysis (Claude + Codex)

### ✅ Consensus (높은 신뢰도)
- [양쪽 동의 사항 1]
- [양쪽 동의 사항 2]

### ⚡ Divergent Views
- **[주제]**: Claude는 [X]로 판단, Codex는 [Y]로 판단
  - Claude 근거: ...
  - Codex 근거: ...
  - 종합 평가: ...

### 💡 Unique Insights from Codex
- [Claude가 놓쳤을 수 있는 관점 1]
- [추가 검증 필요 여부]

### 💡 Unique Insights from Claude
- [Codex가 다루지 않은 Claude 고유 발견 1]
- [해당 발견의 근거]

### Synthesis Conclusion
[두 AI의 분석을 종합한 최종 결론. 신뢰도가 높아진 항목과 추가 검토 필요 항목 구분.]
```

## 에러 처리

- Codex 호출이 실패하면 (exit code != 0): Claude 단독 분석으로 진행, "Codex 호출 실패" 명시
- Codex 응답이 비어있거나 불완전하면: 가용한 부분만 합성, 누락 부분 명시
- Codex가 timeout되면 (2분 초과): Claude 단독 분석으로 진행
- 사용자에게 Codex 실패 시 재시도 여부를 묻지 않는다 (자동으로 Claude 단독 진행)
