# Harness PROGRESS.md Isolation Design

## Overview

다중 하네스 동시 실행 시 PROGRESS.md 충돌 문제를 해결한다.
기존에는 프로젝트 루트에 단일 `PROGRESS.md`를 사용하여, 같은 프로젝트에서 3~4개 feature를 동시에 하네스 실행하면 서로 덮어쓰기가 발생하여 이전 하네스의 진행상황이 완전 유실되었다.

## Goals

1. 다중 하네스 동시 실행 시 PROGRESS 파일 충돌 방지
2. 기존 하네스 워크플로우 최소 변경
3. 프로젝트 루트 깔끔하게 유지
4. Context recovery 안정성 확보

## Key Requirements

- `.harness/PROGRESS-{feature}.md` 플랫 구조로 격리
- `.harness/` 디렉토리는 `.gitignore`에 추가 (로컬만 유지)
- Feature 이름은 spec/PRD 제목에서 자동 추출 (kebab-case)
- Phase 4 완료 시 해당 PROGRESS 파일 삭제

## Design

### 1. 디렉토리 구조

```
project-root/
├── .harness/
│   ├── PROGRESS-auth-system.md
│   ├── PROGRESS-payment-flow.md
│   └── PROGRESS-notification-service.md
├── .gitignore          ← `.harness/` 추가
└── (기존 프로젝트 파일들)
```

- `.harness/` 하위에 플랫하게 `PROGRESS-{feature}.md` 파일 배치
- 하위 디렉토리 없음 (단순성 유지)
- `.gitignore`에 `.harness/` 추가하여 git 추적 제외

### 2. Feature 이름 규칙

- spec/PRD 제목에서 자동 추출 → kebab-case 변환
- 예: "사용자 인증 시스템 MVP" → `auth-system-mvp`
- Phase 0에서 추출 결과를 사용자에게 확인
- 영문/숫자/하이픈만 허용

### 3. Phase 0 워크플로우 (기존 6단계 → 9단계)

```
1. spec 위치 확인
2. LESSONS_LEARNED.md 확인
3. spec 분석, 프로젝트 구조 파악
4. [NEW] Feature 이름 추출: spec/PRD 제목 → kebab-case → 사용자 확인
5. [NEW] .harness/ 디렉토리 확인/생성 + .gitignore 처리
6. [NEW] 기존 하네스 충돌 체크 (동일 이름 존재 시 경고)
7. 모듈 경계 및 파일 소유권 정의
8. .harness/PROGRESS-{feature}.md 생성 (템플릿 적용)
9. 사용자 확인
```

### 4. Context Recovery (세션 리셋 시)

```
1. ls .harness/PROGRESS-*.md → 자신의 feature 파일 식별
2. Read .harness/PROGRESS-{my-feature}.md
3. git log --oneline -20
4. Run quick test
```

### 5. 에이전트 행동 규칙 (추가)

| 규칙 | 내용 |
|------|------|
| 자기 파일만 읽기 | implementer는 자신에게 지정된 PROGRESS 파일만 읽고 쓰기 |
| 파일명 전달 필수 | lead가 spawn 시 정확한 PROGRESS 파일명을 context에 포함 |
| 다른 하네스 간섭 금지 | 다른 feature의 PROGRESS 파일 수정 금지 |
| Phase 4 정리 | 완료 시 PROGRESS 파일 삭제 |

### 6. Phase 4 완료 시 정리

- `.harness/PROGRESS-{feature}.md` 삭제
- lessons는 이미 `LESSONS_LEARNED.md`에 추출됨
- `.harness/`가 비어있으면 폴더도 삭제 가능

## File Structure (수정 대상)

| 파일 | 변경 내용 |
|------|-----------|
| `harness/SKILL.md` | Phase 0에서 `.harness/PROGRESS-{feature}.md` 생성. feature 이름 추출 절차 추가 |
| `harness/references/phase-details.md` | 모든 PROGRESS.md 참조를 새 경로로 변경. Phase 0에 .gitignore 처리 추가 |
| `harness/references/lead-rules.md` | 모든 PROGRESS.md 참조를 새 경로로 변경. Context recovery 절차 변경 |
| `harness/references/progress-template.md` | 헤더에 `## Harness: {feature-name}` 추가 |

## Implementation Order

1. `progress-template.md` 수정 (헤더에 feature 식별자 추가)
2. `SKILL.md` 수정 (Phase 0 워크플로우 변경, 전체 참조 업데이트)
3. `phase-details.md` 수정 (상세 참조 업데이트, spawn context 변경)
4. `lead-rules.md` 수정 (참조 업데이트, context recovery 절차 변경)

## Verification

- 모든 PROGRESS.md 하드코딩 참조가 `.harness/PROGRESS-{feature}.md` 패턴으로 변경되었는지 grep 확인
- Phase 0 절차에 feature 이름 추출/확인 단계가 포함되었는지 확인
- spawn context에 올바른 PROGRESS 파일 경로가 포함되었는지 확인
