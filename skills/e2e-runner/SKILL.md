---
name: e2e-runner
description: "E2E 테스트, Playwright, 엔드투엔드, 통합 테스트, UI 테스트 - Generates, runs, and maintains E2E tests using Playwright. Use when creating browser-based tests, debugging flaky E2E tests, or maintaining Playwright test suites. Do NOT use for unit/integration tests (use tdd-workflow) or test strategy planning (use testing-strategy)."
tools: Read, Write, Edit, Bash, Grep, Glob
model: opus
metadata:
  author: jaehashin
  version: 1.2.0
---

# E2E Runner

Playwright를 사용한 엔드투엔드 테스트 워크플로우입니다.

## 핵심 기능

1. **테스트 생성**: 사용자 시나리오 기반 테스트 자동 생성
2. **테스트 실행**: 다양한 브라우저에서 테스트 실행
3. **결과 분석**: 실패 원인 분석 및 수정 제안
4. **유지보수**: 깨진 테스트 자동 수정

## 테스트 시나리오 템플릿

### 기본 구조
```typescript
import { test, expect } from '@playwright/test';

test.describe('Feature: [기능명]', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('should [expected behavior]', async ({ page }) => {
    // Arrange
    // Act
    // Assert
  });
});
```

## 테스트 생성 프로세스

### Phase 1: 시나리오 정의
```
사용자 스토리 → 테스트 시나리오 변환

예: "사용자가 로그인할 수 있다"
→ 
1. 유효한 자격 증명으로 로그인 성공
2. 잘못된 비밀번호로 로그인 실패
3. 존재하지 않는 이메일로 로그인 실패
4. 빈 필드로 로그인 시도
```

### Phase 2: 선택자 식별
```
우선순위:
1. data-testid (권장)
2. role + name
3. text content
4. CSS selector (최후 수단)
```

### Phase 3: 테스트 작성
```
AAA 패턴:
- Arrange: 테스트 환경 설정
- Act: 사용자 액션 수행
- Assert: 결과 검증
```

## 테스트 유지보수

### 깨진 테스트 수정
```
1. 실패 원인 분석 (스크린샷, 트레이스)
2. 선택자 변경 확인
3. 타이밍 이슈 확인
4. API 응답 변경 확인
5. 테스트 수정 또는 기능 버그 보고
```

## Playwright 상세 참조

Playwright 설정, 실행 명령어, 코드 패턴, Page Object 패턴, 테스트 구조 등 상세 참조:
**Read `references/playwright-reference.md` in this skill directory.**

## 사용 방법

### 테스트 생성 요청
```
로그인 기능에 대한 E2E 테스트를 생성해주세요.
```

### 테스트 실행 및 분석
```
E2E 테스트를 실행하고 실패한 테스트를 분석해주세요.
```

### 깨진 테스트 수정
```
이 E2E 테스트가 실패합니다. 수정해주세요.
[테스트 코드]
[에러 메시지]
```

## 문서화 (작업 완료 후 자동 실행)

작업 완료 시 `auto-documenter`를 호출하여 프로젝트 문서를 업데이트한다.

## Completion

모든 대상 테스트가 통과하거나, 실패 원인 분석 리포트가 전달되면 완료.

## Troubleshooting

**테스트가 간헐적으로 실패 (flaky)**: 타이밍 이슈가 대부분. `waitFor` / `expect().toBeVisible()` 등 명시적 대기로 교체. `page.waitForTimeout()` 사용 금지.
**Selector가 자주 깨지는 경우**: CSS selector 대신 `data-testid` 또는 `role + name` 선택자로 전환. 선택자 우선순위 Phase 2 참조.
**CI에서만 실패하는 테스트**: headless 모드 차이, 화면 해상도, 네트워크 지연 확인. `--trace on`으로 trace 수집 후 분석.
