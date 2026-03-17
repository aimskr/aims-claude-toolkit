# Playwright Reference

## 설정 (playwright.config.ts)

```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html'],
    ['json', { outputFile: 'test-results.json' }]
  ],
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] },
    },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

## 실행 명령어

### 기본 실행
```bash
# 모든 테스트 실행
npx playwright test

# 특정 파일 실행
npx playwright test e2e/login.spec.ts

# 특정 브라우저
npx playwright test --project=chromium

# UI 모드
npx playwright test --ui

# 헤드리스 모드 비활성화
npx playwright test --headed
```

### 디버깅
```bash
# 디버그 모드
npx playwright test --debug

# 트레이스 뷰어
npx playwright show-trace trace.zip
```

### 리포트
```bash
# HTML 리포트 열기
npx playwright show-report
```

## 자주 사용하는 패턴

### 페이지 네비게이션
```typescript
await page.goto('/dashboard');
await page.waitForURL('**/dashboard');
```

### 요소 대기
```typescript
await page.waitForSelector('[data-testid="loading"]', { state: 'hidden' });
await expect(page.locator('[data-testid="content"]')).toBeVisible();
```

### 폼 입력
```typescript
await page.fill('input[name="email"]', 'test@example.com');
await page.selectOption('select[name="country"]', 'KR');
await page.check('input[type="checkbox"]');
```

### API 모킹
```typescript
await page.route('**/api/users', async route => {
  await route.fulfill({
    status: 200,
    body: JSON.stringify([{ id: 1, name: 'Test User' }]),
  });
});
```

### 스크린샷
```typescript
await page.screenshot({ path: 'screenshot.png', fullPage: true });
```

## Page Object 패턴

```typescript
// pages/login.page.ts
import { Page, Locator } from '@playwright/test';

export class LoginPage {
  readonly page: Page;
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly loginButton: Locator;
  readonly errorMessage: Locator;

  constructor(page: Page) {
    this.page = page;
    this.emailInput = page.locator('[data-testid="email"]');
    this.passwordInput = page.locator('[data-testid="password"]');
    this.loginButton = page.locator('[data-testid="login-button"]');
    this.errorMessage = page.locator('[data-testid="error-message"]');
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.loginButton.click();
  }
}
```

## 테스트 구조 예시

```
e2e/
├── fixtures/
│   ├── test-data.json
│   └── auth.setup.ts
├── pages/
│   ├── login.page.ts
│   └── dashboard.page.ts
├── tests/
│   ├── auth/
│   │   ├── login.spec.ts
│   │   └── logout.spec.ts
│   ├── dashboard/
│   │   └── overview.spec.ts
│   └── settings/
│       └── profile.spec.ts
└── playwright.config.ts
```

## Flaky 테스트 처리

```typescript
// 재시도 추가
test('flaky test', async ({ page }) => {
  test.retry(2);
  // ...
});

// 명시적 대기 추가
await page.waitForLoadState('networkidle');
```
