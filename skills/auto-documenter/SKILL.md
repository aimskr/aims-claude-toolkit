---
name: auto-documenter
description: "자동 문서화, 문서 업데이트, 아키텍처 문서, memory, 변경 기록, ADR, 의사결정 기록 - 작업 완료 후 프로젝트 문서를 자동 생성/업데이트한다. architecture.md, memory.md, decisions/ ADR을 관리하며 memory.md 로테이션을 수행한다. Use when a development task is completed and documentation needs updating. Also use standalone to generate or refresh project documentation. Do NOT use for writing specs or proposals (use doc-coauthoring) or PRD (use prd-strategist)."
tools: Read, Write, Edit, Grep, Glob, Bash
model: opus
metadata:
  author: jaehashin
  version: 2.1.0
---

# Auto-Documenter

작업 완료 후 프로젝트 문서를 자동으로 생성하고 업데이트한다.

> ⚠ LLM이 생성한 문서이므로 사용자 검토를 권장한다. 특히 architecture.md 변경 시 반드시 사용자 확인을 거친다.

## 문서 구조

```
docs/
├── architecture.md          # 아키텍처 전용 (구조, 스택, 레이어, 데이터 플로우)
├── memory.md                # 작업 요약 + 변경 이력 (로테이션 관리)
├── decisions/               # ADR — 의사결정 기록 (Medium/Large 변경 시)
│   └── NNNN.YYYY-MM-DD-제목.md
└── archive/                 # 로테이션된 memory 압축본 (월별, 기본 6개월 보존)
    └── memory-YYYY-MM.md
```

## 실행 모드

| 변경 규모 | 실행 모드 | 동작 |
|-----------|-----------|------|
| Small | 경량 모드 (Skill 본문만 참조) | memory.md append만 수행 |
| Medium | 정식 호출 (templates.md 포함) | memory.md + ADR 생성 |
| Large | 정식 호출 + 사용자 확인 | memory.md + ADR + architecture.md 업데이트 |

사용자가 문서화를 건너뛰고 싶으면 "문서화 스킵"으로 opt-out 가능하다.
컨텍스트 절약이 필요하면 서브에이전트로 위임할 수 있다.

## 변경 규모 판단

**1차 기준 (파일 수 휴리스틱):**

| 규모 | 파일 수 |
|------|---------|
| Small | 1-3개 |
| Medium | 4-10개 |
| Large | 10+개 |

**상향 기준 (다음 중 하나라도 해당하면 한 단계 상향):**
- 아키텍처 파일 변경 (라우팅, DB 스키마, CI/CD 설정, 인프라 설정)
- 새 모듈/패키지 생성
- 외부 의존성(dependency) 추가/제거
- 기존 ADR을 대체하는 결정

**하향 기준 (다음 중 하나라도 해당하면 한 단계 하향):**
- import 경로/네임스페이스 일괄 변경 (동작 변경 없음)
- 코드 포매팅/린트 수정만
- 파일 수 대비 변경 라인 수가 극히 적음 (파일당 평균 3줄 이하)

예(상향): 파일 2개 수정(Small 기준)이지만 DB 스키마 마이그레이션 포함 → Medium으로 상향.
예(하향): 파일 15개 수정(Large 기준)이지만 import 경로 일괄 변경 → Small로 하향.

## 입력: 작업 컨텍스트 수집

문서화 시작 전 다음 정보를 수집한다:

```
1. 변경 파일 목록      → git diff --name-only (또는 작업 중 추적한 파일)
2. 변경 이유           → 사용자 요청 또는 Skill이 전달한 컨텍스트
3. 의사결정 사항       → 왜 이 방식을 선택했는지 (대안 포함)
4. 변경 규모 판단      → 파일 수 + 보조 기준
```

## 문서별 업데이트 규칙

### 1. architecture.md

아키텍처 전용 문서. Large 변경 시에만 업데이트한다.

- **초기 생성**: 프로젝트 구조 분석 후 템플릿 기반 생성 → **사용자에게 확인 요청** 후 저장
- **업데이트**: `str_replace`로 변경된 섹션만 수정 → 변경 diff를 사용자에게 보고
- 전체 재생성 금지 — 항상 부분 수정
- 모든 기술 항목에 근거 소스 경로를 주석으로 기록

템플릿은 `references/templates.md`의 "architecture.md 템플릿" 참조.

### 2. memory.md

작업 요약과 변경 이력을 기록한다.

**항목 작성 규칙:**
- 매 작업 완료 시 하단에 append
- 한국어로 작성, 기술 용어는 영어 허용
- 항목당 5-8줄 이내

**항목 포맷:**
```markdown
### #번호 — YYYY-MM-DD HH:mm | 규모

**작업**: 무엇을 했는지 (1줄)
**이유**: 왜 했는지 (1줄)
**변경 파일**: 주요 파일 목록 (최대 5개, 초과 시 "외 N개")
**의사결정**: 핵심 결정사항 (있을 경우만)
**관련 ADR**: [NNNN.날짜-제목](decisions/NNNN.날짜-제목.md) (있을 경우만)
```

### 3. decisions/ ADR

Medium/Large 변경 시 자동 생성한다.

**넘버링**: `NNNN.YYYY-MM-DD-제목.md` (0001부터 순차 증가)
- 다음 번호 결정: decisions/ 폴더의 기존 파일 중 가장 큰 번호 + 1
- 제목: kebab-case 한국어 또는 영어

**ADR 상태 라이프사이클:**
```
Proposed → Accepted → Deprecated by [NNNN] 또는 Superseded by [NNNN]
```

- 자동 생성 시 기본 상태: `Proposed` (사용자가 확인 후 `Accepted`로 변경)
- `.documenter-config`의 `require_approval: large`이면 Large 변경 시만 Proposed, 나머지는 자동 Accepted
- 기존 결정을 대체하는 ADR 생성 시: 기존 ADR 상태를 `Superseded by [새 NNNN]`으로 자동 업데이트
- 더 이상 유효하지 않은 결정: `Deprecated by [새 NNNN]`으로 변경

템플릿은 `references/templates.md`의 "ADR 템플릿" 참조.

### 4. memory.md 로테이션

**듀얼 트리거**: memory.md가 50KB를 초과하거나 항목이 50건을 초과하면 로테이션 수행.

> 임계값 근거: 50건 × 평균 5줄/건 = 250줄 ≈ 단일 문서로 읽기 적정한 분량. 50KB ≈ 약 12,000단어 ≈ LLM 컨텍스트에서 단일 파일로 처리 가능한 상한. `.documenter-config`로 프로젝트별 조정 가능.

```
로테이션 프로세스 (write-verify-delete 패턴):
1. memory.md의 크기와 항목 수 확인
2. 트리거 조건 충족 시:
   a. 로테이션 대상(오래된 항목 10건)을 압축 요약
   b. archive/memory-해당월.md에 append → 파일 정상 기록 확인
   c. 확인 후 memory.md에서 해당 항목 삭제
3. 실패 시: memory.md 원본 유지, 에러 보고, 다음 실행 시 재시도
```

**압축 요약 포맷:**
```markdown
- YYYY-MM-DD | #번호 | 규모 | 파일N개 | 작업 요약 1줄
```

> 압축 시 변경 파일 수와 규모는 반드시 보존한다. 상세 파일 목록이 필요하면 `.documenter-config`에서 `archive_detail: full`로 설정.

**archive 보존 정책**: 기본 6개월. 6개월 이전 archive 파일은 사용자 확인 후 삭제. git 기반 프로젝트에서는 git log로 과거 이력 추적이 가능하므로, 오래된 archive 삭제 시 `git log -- docs/`를 안내한다.

## 실행 프로세스

```
1. 컨텍스트 수집 (변경 파일, 이유, 의사결정)
   ↓
2. 변경 규모 판단 (파일 수 + 보조 기준)
   ↓
3. docs/ 디렉토리 확인 (없으면 초기 생성 → 사용자 확인)
   ↓
4. 규모에 따라 문서 업데이트:
   - Small:  memory.md append (경량 모드)
   - Medium: memory.md + ADR 생성
   - Large:  memory.md + ADR + architecture.md 업데이트 (→ 사용자 확인)
   ↓
5. ADR 상태 업데이트 (기존 ADR 대체 시)
   ↓
6. 로테이션 체크 (듀얼 트리거: 50KB OR 50건)
   ↓
7. 완료 보고 (업데이트된 문서 목록 1줄)
```

## 초기 생성 (프로젝트에 docs/가 없을 때)

docs/ 디렉토리가 없거나 architecture.md가 없으면 초기 생성을 수행한다:

1. 프로젝트 구조 분석 (Glob, Grep)
2. 기술 스택 감지 (package.json, requirements.txt, build.gradle 등)
3. architecture.md **초안** 생성
4. **사용자에게 architecture.md 초안 확인 요청** ← 필수 게이트
5. 승인 후 memory.md 빈 파일 생성 (헤더만)
6. decisions/ 디렉토리 생성

## 다른 Skills에서 호출될 때

개발계 Skills가 작업 완료 후 auto-documenter를 트리거한다.
auto-documenter는 현재 컨텍스트에서 다음을 자동 수집한다:
- 변경 파일 목록 (git diff 또는 작업 이력)
- 변경 이유 (사용자의 원래 요청)
- 의사결정 사항 (선택한 접근법과 이유)

호출하는 Skill은 최소한의 트리거 문구만 포함하면 된다:
```
작업 완료 시 `auto-documenter`를 호출하여 프로젝트 문서를 업데이트한다.
```

## 프로젝트별 설정 (선택사항)

`docs/.documenter-config`를 생성하여 기본값을 오버라이드할 수 있다:

```yaml
rotation:
  max_size_kb: 50        # memory.md 최대 크기 (기본: 50KB)
  max_entries: 50         # memory.md 최대 항목 수 (기본: 50)
  archive_retention_months: 6  # archive 보존 기간 (기본: 6개월)
  archive_detail: compact # compact | full (full = 파일 목록 보존)
behavior:
  auto_run: true          # false로 설정하면 문서화 비활성화
  require_approval: large # 사용자 확인 필요 단계 (large/medium/all)
  skip_patterns: []       # 예: ["feature/prototype-*"]
  docs_root: docs         # 문서 루트 경로 (기존 docs/ 충돌 시 변경)
```

설정 파일이 없으면 기본값을 사용한다.

## Completion

규모별 문서 업데이트 완료 + 로테이션 체크 통과 + 완료 보고(1줄) 전달이면 종료.

## Troubleshooting

**architecture.md가 실제 코드와 불일치**: 삭제하지 말고 코드베이스를 다시 분석하여 불일치 섹션만 `str_replace`로 수정. 전체 재생성이 필요하면 사용자 확인 후 진행.

**memory.md 항목 수 카운트가 정확하지 않음**: `grep -c "^### #" docs/memory.md`로 카운트. 수동 편집으로 포맷이 깨진 경우 포맷 정규화를 먼저 수행.

**decisions/ 넘버링 충돌**: `ls docs/decisions/ | sort -n | tail -1`로 확인 후 다음 번호 결정. 수동 생성 파일이 있을 수 있으므로 항상 확인.

**로테이션 중 실패 (archive에 기록되었으나 memory.md에서 미삭제)**: archive와 memory.md를 비교하여 중복 항목을 식별하고, memory.md에서 중복분만 삭제. 데이터 손실보다 중복이 안전하므로 archive를 기준으로 한다.

**Superseded ADR 관리**: `grep -l "Superseded" docs/decisions/`로 대체된 ADR 목록 확인. 의사결정 추적 시 최신 Accepted 상태의 ADR만 참조.

**컨텍스트 윈도우 부족으로 문서화 품질 저하**: subagent로 위임하거나, memory.md append만 수행 후 나머지는 별도 세션에서 처리. Small 변경의 예상 오버헤드는 200-500 토큰 수준.

**멀티 브랜치에서 memory.md 넘버링 충돌**: 별도 브랜치에서 docs/가 동시 수정되면 merge 시 넘버링이 충돌할 수 있다. git merge 후 memory.md의 항목 번호를 순차적으로 재배정해야 한다.

**기존 docs/ 디렉토리와 충돌**: 프로젝트에 이미 docs/가 다른 용도로 사용 중이면, `.documenter-config`의 `docs_root`를 변경하여 충돌을 회피 (ex: `docs_root: .project-docs`).

**모노레포 환경에서 docs/ 위치 모호**: 서브 디렉토리별로 docs/를 둘지, 루트에 둘지 판단 필요. `docs_root`를 서브 프로젝트 내로 설정 (ex: `docs_root: packages/api/docs`).
