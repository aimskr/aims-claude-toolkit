# Auto-Documenter 설계 비판적 검토 보고서

> 작성일: 2026-02-13
> 대상: auto-documenter Skill v2.0.0 (SKILL.md + references/templates.md)

---

## 1. 주요 비판 시나리오와 대응

### 비판 1: "LLM이 생성한 문서는 신뢰할 수 없다 — hallucination 위험"

**핵심**: LLM이 코드를 분석하여 architecture.md를 생성할 때, 실제 코드에 없는 모듈/의존성을 기술하거나, 데이터 플로우를 잘못 서술할 수 있다. 문서 자체가 오정보 소스가 되는 역설.

**현재 대응 (v2 반영 완료)**:
- architecture.md 템플릿에 "⚠ LLM 자동 생성 문서. 사용자 검토 완료: [예/아니오]" 고지
- Large 변경 시 사용자 확인 게이트 존재
- 기술 스택 테이블에 "근거 소스" 컬럼 (예: `package.json → node v20`)

**추가 보완 필요**:
- architecture.md 내 **모든 사실적 주장에 파일 경로 근거**를 기록해야 한다. 현재는 기술 스택 테이블에만 근거 소스가 있고, 레이어 구조/데이터 플로우 섹션에는 없다.
- **검증 스크립트**: architecture.md에 기술된 모듈 경로가 실제 존재하는지 `ls`/`find`로 검증하는 후처리 단계 추가.

### 비판 2: "문서화가 컨텍스트 윈도우를 낭비한다 — 비용 대비 효과 의문"

**핵심**: Claude Code의 컨텍스트 윈도우는 유한하다. 매 작업마다 auto-documenter가 docs/를 읽고 쓰는 데 토큰을 소비하면, 실제 개발 작업에 쓸 컨텍스트가 줄어든다. 특히 Opus 모델은 비용이 높다.

**현재 대응 (v2 반영 완료)**:
- Small 변경 시 "경량 모드" — SKILL.md 본문만 참조, references/ 미로드
- subagent 위임 가능 언급
- Troubleshooting에 "컨텍스트 윈도우 부족 시" 대응 포함

**추가 보완 필요**:
- Small 변경의 memory.md append는 약 200-300 토큰 수준으로, 실질적 오버헤드가 낮다. 그러나 이 수치 근거를 SKILL.md에 명시하여 사용자가 비용을 판단할 수 있게 해야 한다.
- **모델 등급 분리**: Small→Haiku subagent, Medium→Sonnet, Large만 Opus를 사용하는 방식으로 비용을 최적화할 수 있다. 현재 SKILL.md의 `model: opus`는 과잉.

### 비판 3: "memory.md 로테이션이 데이터 손실을 유발한다"

**핵심**: 압축 요약 과정에서 정보가 유실된다. "파일 2개 수정 + DB 스키마 변경" 같은 맥락이 "DB 스키마 변경"으로 압축되면 파일 변경 컨텍스트가 사라진다. git log가 대안이라 하지만, git이 없는 프로젝트도 있다.

**현재 대응 (v2 반영 완료)**:
- write-verify-delete 패턴 (archive 기록 확인 후 삭제)
- archive 보존 정책 6개월
- git log 안내 포함

**추가 보완 필요**:
- 압축 포맷이 "1줄 요약"으로만 정의되어 있어 정보 밀도가 낮다. **압축 시 '변경 파일 수'와 '규모'는 반드시 보존**하는 규칙을 추가해야 한다.
- git이 없는 프로젝트를 위해 archive에 **파일 목록까지 보존하는 확장 포맷**을 `.documenter-config`에서 선택 가능하게 해야 한다.

### 비판 4: "파일 수 기반 규모 판단은 부정확하다"

**핵심**: 파일 수만으로 변경의 중요도를 판단하는 것은 휴리스틱에 불과하다. 파일 1개 수정이지만 DB 마이그레이션 스크립트 변경은 아키텍처적으로 중대할 수 있고, 파일 20개 수정이지만 import 경로 일괄 변경은 사소할 수 있다.

**현재 대응 (v2 반영 완료)**:
- "보조 기준"으로 아키텍처 파일 변경, 새 모듈 생성, 의존성 변경 시 한 단계 상향
- 예시 포함: "파일 2개 수정이지만 DB 스키마 마이그레이션 포함 → Medium 상향"

**추가 보완 필요**:
- **하향 조건**도 정의해야 한다. 파일 15개지만 `import` 경로 일괄 변경 = Large가 아니라 Small이어야 한다.
- diff의 **변경 라인 수**를 보조 지표로 추가 (예: 파일 15개지만 각각 1줄 변경 = 실질 Small).

### 비판 5: "7개 Skills에 MANDATORY 트리거를 넣으면 사용자 자율성이 훼손된다"

**핵심**: 빠르게 프로토타이핑할 때, 매번 문서화가 강제되면 워크플로우가 느려진다. MANDATORY라는 표현은 사용자에게 거부감을 줄 수 있다.

**현재 대응 (v2 반영 완료)**:
- opt-out 가능: "문서화 스킵"
- `.documenter-config`에서 `auto_run: false`로 비활성화 가능

**추가 보완 필요**:
- MANDATORY라는 워딩을 "AUTO (opt-out: '문서화 스킵')"으로 변경하여 톤을 완화하면서도 기본 동작은 유지.
- `.documenter-config`에 `skip_patterns` 추가: 특정 브랜치(feature/prototype-*)나 파일 패턴에서는 자동 문서화를 건너뛸 수 있게.

---

## 2. 다각적 분석과 반대의견 검토

### 관점 A: 성능 (Performance)

**분석**: auto-documenter의 주요 성능 병목은 컨텍스트 윈도우 소비와 I/O(파일 읽기/쓰기)다.

| 동작 | 예상 토큰 소비 | I/O 횟수 |
|------|---------------|----------|
| Small (memory.md append) | 200-500 | 읽기 1 + 쓰기 1 |
| Medium (+ ADR 생성) | 800-1500 | 읽기 2 + 쓰기 2 |
| Large (+ architecture.md) | 2000-4000 | 읽기 3 + 쓰기 3 + 검증 |

**반대의견**: "문서화 자체를 별도 세션으로 분리하면 성능 영향이 0이 된다."
**반박**: 별도 세션에서는 작업 컨텍스트가 유실된다. "왜 이 결정을 했는지"를 가장 정확하게 기록할 수 있는 시점은 작업 직후다. Docs-as-Code 원칙(Write the Docs[^1])에서도 "문서를 코드 변경과 동일한 CL(changelist)에서 수정하라"고 권장한다. Google의 Documentation Best Practices[^2]에서도 "Change your documentation in the same CL as the code change"를 명시한다.

**결론**: Small 변경의 오버헤드(200-500 토큰)는 무시 가능 수준. Large 변경에서만 subagent 위임을 고려.

### 관점 B: 유지보수성 (Maintainability)

**분석**: 4종류 파일(architecture.md, memory.md, decisions/, archive/) 관리의 장기적 부담.

**반대의견**: "파일이 4종류나 되면 유지보수 포인트가 너무 많다. 단일 CHANGELOG.md로 충분하다."
**반박**: 단일 파일은 관심사가 혼재된다. Microsoft Azure Well-Architected Framework[^3]는 아키텍처 결정을 별도 ADR로 분리할 것을 권고하며, "The ADR serves as an append-only log"로서 변경 이력과 구분해야 한다고 명시한다. 현재 설계에서:
- architecture.md = 현재 상태 (what is)
- memory.md = 변경 이력 (what changed)
- decisions/ = 결정 근거 (why)

이 3축 분리는 정보 검색 효율을 높인다. "현재 DB가 뭐지?" → architecture.md, "지난주에 뭘 했지?" → memory.md, "왜 JWT를 선택했지?" → decisions/.

**보완**: archive/는 자동 관리되므로 사용자가 직접 관리할 필요가 없다. 유지보수 포인트는 실질적으로 3개.

### 관점 C: 정보 정확성 (Accuracy)

**분석**: LLM 생성 문서의 정확성은 입력(코드베이스 분석)의 품질에 의존한다.

**반대의견**: "코드를 직접 읽으면 되지 왜 LLM이 생성한 요약을 믿어야 하나?"
**반박**: 이 Skill의 목적은 "코드를 읽을 필요를 없애는 것"이 아니라 "코드를 읽기 전에 오리엔테이션을 제공하는 것"이다. 코드 자체가 primary source이고, docs/는 secondary index다. 이 관점은 Nygard의 원래 ADR 제안[^4]과 일치한다: "We will write each ADR as if it is a conversation with a future developer."

**보완**: 모든 문서에 "이 문서는 코드의 요약이며, 정확한 정보는 소스 코드를 참조하십시오" 면책 고지를 추가. architecture.md의 근거 소스 컬럼을 전체 섹션으로 확대.

---

## 3. 잠재 오류·편향 점검

### 편향 1: 파일 수 휴리스틱의 과신 (Anchoring Bias)

**현상**: 파일 수를 primary metric으로 사용하고 보조 기준은 "해당하면 한 단계 상향"으로만 정의. 이는 파일 수에 과도하게 앵커링된 판단이다.

**개선**: 파일 수와 보조 기준을 **동등한 가중치**로 평가하는 매트릭스 방식으로 변경. 예를 들어 "아키텍처 파일 변경 = 무조건 Medium 이상"처럼 보조 기준이 독립적으로 최소 등급을 보장하게.

### 편향 2: Markdown 선호 편향 (Tool Familiarity Bias)

**현상**: 모든 문서를 Markdown으로 작성한다. 이는 개발자 친화적이지만, 비개발자(PM, 기획자)에게는 접근성이 떨어질 수 있다.

**반론**: 이 Skill의 대상 사용자는 Claude Code를 사용하는 개발자이므로 Markdown은 적절한 선택이다. Google Cloud Architecture Center[^5]에서도 "An ADR is often written in Markdown to keep it lightweight and text-based"라고 권고한다. Docs-as-Code(Write the Docs[^1])에서도 Markdown/reStructuredText를 기본 포맷으로 권장한다.

**결론**: 이 맥락에서는 편향이 아닌 합리적 선택. 변경 불필요.

### 편향 3: 로테이션 임계값의 근거 부족

**현상**: 50건/50KB라는 임계값의 근거가 명시되지 않았다. "왜 50이지 30이나 100이 아닌가?"라는 질문에 답할 수 없다.

**개선**: 임계값의 산출 근거를 명시해야 한다:
- 50건 × 평균 5줄/건 = 250줄 ≈ 문서 1개로 읽기 적정한 분량
- 50KB ≈ Markdown 기준 약 12,000단어 ≈ Claude 컨텍스트에서 단일 파일로 처리 가능한 상한
- `.documenter-config`로 프로젝트별 조정 가능하므로 경직적이지 않음

### 편향 4: ADR 상태 관리의 논리적 비약

**현상**: "새 ADR 생성 시 기본 상태: Accepted (사용자 승인 후 작성되므로)"라고 했으나, auto-documenter가 자동 생성하는 ADR은 사용자가 명시적으로 승인한 것이 아니다.

**개선**: ADR 자동 생성 시 기본 상태를 `Accepted`가 아닌 `Proposed`로 설정하고, 사용자가 확인 후 `Accepted`로 변경하거나, `.documenter-config`의 `require_approval` 설정에 따라 자동 `Accepted` 처리하는 것이 논리적으로 일관된다.

---

## 4. 근거와 출처 명시

| 설계 요소 | 근거 | 출처 |
|-----------|------|------|
| ADR 구조 (Title, Status, Context, Decision, Consequences) | Michael Nygard의 원본 ADR 제안 | [^4] Cognitect Blog, 2011 |
| ADR 상태 라이프사이클 (Proposed → Accepted → Deprecated/Superseded) | 업계 표준 상태 관리 | [^3] Microsoft Azure WAF; [^6] TechTarget ADR Best Practices; [^7] AWS Architecture Blog |
| Docs-as-Code (코드와 동일한 리포지터리에 문서 관리) | Docs-as-Code 방법론 | [^1] Write the Docs; [^8] Google Documentation Best Practices |
| "코드 변경과 동일한 CL에서 문서 수정" 원칙 | Google Engineering Practices | [^2] google.github.io/styleguide/docguide |
| Markdown을 ADR 포맷으로 사용 | 경량 텍스트 기반 문서 권고 | [^5] Google Cloud Architecture Center |
| docs/ 디렉토리 구조 | 프로젝트 내 전용 docs 폴더 권고 | [^9] Codacy Code Documentation Best Practices |
| ADR의 append-only 특성 | Microsoft Azure WAF | [^3] "The ADR serves as an append-only log" |
| ADR 간 cross-reference (Superseded by) | AWS Prescriptive Guidance | [^10] AWS ADR Process |
| 변경 이력과 아키텍처 결정의 분리 | 관심사 분리 원칙 | [^4] Nygard: "One ADR describes one significant decision" |

**References**:
- [^1]: https://www.writethedocs.org/guide/docs-as-code/
- [^2]: https://google.github.io/styleguide/docguide/best_practices.html
- [^3]: https://learn.microsoft.com/en-us/azure/well-architected/architect-role/architecture-decision-record
- [^4]: https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions (Michael Nygard, 2011)
- [^5]: https://cloud.google.com/architecture/architecture-decision-records
- [^6]: https://www.techtarget.com/searchapparchitecture/tip/4-best-practices-for-creating-architecture-decision-records
- [^7]: https://aws.amazon.com/blogs/architecture/master-architecture-decision-records-adrs-best-practices-for-effective-decision-making/
- [^8]: https://konghq.com/blog/learning-center/what-is-docs-as-code
- [^9]: https://blog.codacy.com/code-documentation
- [^10]: https://docs.aws.amazon.com/prescriptive-guidance/latest/architectural-decision-records/adr-process.html
- [^11]: https://adr.github.io/ (ADR GitHub Organization)
- [^12]: https://github.com/joelparkerhenderson/architecture-decision-record

---

## 5. 결론 및 추가 점검

### 핵심 요점 요약

1. **설계의 강점**: 3축 분리(현재 상태 / 변경 이력 / 결정 근거), 로테이션으로 문서 비대화 방지, 규모 기반 자동 조절, opt-out 지원
2. **업계 표준 정합성**: ADR 포맷은 Nygard/MADR 표준 준수, Docs-as-Code 원칙 준수, Microsoft/AWS/Google의 ADR 가이드와 일관됨
3. **주요 리스크**: LLM hallucination → 근거 소스 기록 + 사용자 검증 게이트로 완화

### 식별된 개선 항목 (우선순위순)

| # | 개선 항목 | 심각도 | 상태 |
|---|-----------|--------|------|
| 1 | ADR 자동 생성 시 기본 상태를 `Proposed`로 변경 | High | 수정 필요 |
| 2 | 규모 판단에 하향 조건 추가 (일괄 import 변경 등) | High | 수정 필요 |
| 3 | architecture.md 전체 섹션에 근거 소스 기록 확대 | Medium | 수정 필요 |
| 4 | MANDATORY 워딩을 AUTO (opt-out 가능)로 완화 | Medium | 수정 필요 |
| 5 | 로테이션 임계값 산출 근거 명시 | Medium | 수정 필요 |
| 6 | 압축 포맷에 변경 파일 수 보존 규칙 추가 | Low | 수정 필요 |
| 7 | Small 변경의 예상 토큰 오버헤드 명시 | Low | 수정 필요 |
| 8 | architecture.md 검증 스크립트 추가 | Low | 선택적 |
| 9 | `.documenter-config`에 `skip_patterns` 추가 | Low | 선택적 |

### 놓친 이슈 점검

- **멀티 브랜치 환경**: 브랜치별로 docs/가 분기될 때 memory.md 넘버링 충돌 가능. → git merge 시 수동 해결이 필요하며, 이 점을 Troubleshooting에 추가해야 함.
- **모노레포 환경**: 여러 프로젝트가 한 리포에 있을 때 docs/의 위치 모호. → 프로젝트 루트가 아닌 서브 디렉토리별 docs/ 지원 여부 명시 필요.
- **기존 docs/ 충돌**: 프로젝트에 이미 docs/가 있고 다른 용도로 사용 중일 때. → `.documenter-config`에서 문서 루트 경로를 커스터마이즈할 수 있게 해야 함.
