---
name: refactor-cleaner
description: "리팩토링, 데드 코드, 사용하지 않는 코드, 코드 정리, 클린업, 미사용 임포트 - Identifies and safely removes dead code, unused imports, and redundant code. Use when cleaning up codebases, removing unused functions, or reducing technical debt. Do NOT use for code simplification (use code-simpler) or full code reviews (use code-reviewer)."
tools: Read, Edit, Grep, Glob, Bash
model: opus
metadata:
  author: jaehashin
  version: 1.2.0
---

# Refactor Cleaner

데드 코드를 식별하고 안전하게 제거합니다.

## 핵심 원칙

1. **안전 우선**: 삭제 전 사용처 완전 확인
2. **점진적 정리**: 한 번에 하나씩 제거
3. **테스트 유지**: 삭제 후 테스트 통과 확인
4. **문서화**: 삭제 이유 기록

## 워크플로우

```
Phase 0: 코드 탐색 (code-explorer 활용) — REQUIRED
    ↓
Phase 1: 스캔 (데드 코드 식별)
    ↓
Phase 2: 검증 (사용처 확인)
    ↓
Phase 3: 분류 (🔴 삭제 가능 / 🟡 추가 확인 / 🟢 유지)
    ↓
Phase 4: 정리 (안전한 삭제)
    ↓
Phase 5: 문서화 (리팩토링 기록) — REQUIRED
```

### Phase 0: 코드 탐색 (REQUIRED)

**리팩토링 대상 분석을 위해 code-explorer 서브에이전트를 먼저 실행합니다.**

1. code-explorer 에이전트로 실행 흐름 추적, 의존성 맵핑, 아키텍처 레이어 파악
2. 탐색 결과에서 핵심 컴포넌트, 진입점, 외부 의존성 확인
3. 리팩토링 범위 결정: 안전 영역 / 주의 영역 / 금지 영역

### Phase 1-2: 스캔 & 검증

**호출되지 않는 함수 삭제 전 확인:**
1. 전체 코드베이스에서 호출 검색
2. 테스트에서 호출 검색
3. 동적 호출 가능성 확인 (getattr, __import__)
4. API 엔드포인트로 노출 여부 확인

### Phase 3-4: 분류 & 정리 (반복 루프)

```
for each 삭제 후보:
  1. Verify → 사용처 검색 (grep, 동적 참조, API 노출)
  2. Delete → 안전하면 삭제
  3. Test → 테스트 실행 + 빌드 확인
  4. Rollback → 실패 시 즉시 복원 후 해당 항목 황색(확인 필요)으로 재분류
  5. Repeat → 다음 후보로 이동
```

안전 체크리스트 (per item):
- [ ] grep으로 전체 검색 완료
- [ ] 테스트/설정/문서에서 검색 완료
- [ ] 동적 참조 가능성 확인
- [ ] 외부 API 노출 여부 확인
- [ ] 삭제 후 모든 테스트 통과
- [ ] 빌드 성공 및 린트 통과

### Phase 5: 문서화 (REQUIRED)

리팩토링 결과를 `docs/refactoring/NNNN.YYYY-MM-DD-<target>-refactor.md`에 기록합니다. (NNNN: 해당 폴더 내 최대 번호 + 1, 없으면 0001)

## 도구별 명령어 및 문서 템플릿

분석/자동 정리 명령어(Python/JS/Java), 코드 패턴 예시, 리포트 템플릿:
**Read `references/tooling-reference.md` in this skill directory.**

## 사용 방법

### 전체 리팩토링 (권장)
```
src/services/ 디렉토리 리팩토링해줘
```

### 분석만 (삭제 안 함)
```
이 프로젝트의 데드 코드를 분석만 해줘 (삭제는 하지 마)
```

## 문서화 (작업 완료 후 자동 실행)

작업 완료 시 `auto-documenter`를 호출하여 프로젝트 문서를 업데이트한다.

## Completion

Phase 5 완료: 데드 코드 제거 + 테스트 통과 + 리팩토링 기록 `docs/refactoring/`에 저장.

## Troubleshooting

**삭제 후 테스트 실패**: 즉시 git revert. 동적 참조(getattr, reflection, DI) 또는 테스트 전용 코드일 가능성 확인. 해당 항목을 황색(확인 필요)으로 재분류.
**데드 코드인지 판단이 어려운 경우**: grep 결과가 0이라도 동적 호출, API 노출, 이벤트 핸들러 등을 추가 확인. 확신이 없으면 황색 분류로 남겨두고 사용자에게 확인 요청.
**대규모 리팩토링으로 변경사항이 너무 많을 때**: 모듈/디렉토리 단위로 분할하여 각각 커밋. 한 번에 전체 삭제 금지.
