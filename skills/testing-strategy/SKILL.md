---
name: testing-strategy
description: "테스트 전략, 테스팅 계획, QA 전략, 품질 보증, 테스트 피라미드, 테스트 시나리오, 커버리지 목표 - Designs test strategies including test pyramid ratios, scenario categories, and coverage targets. Use when planning how to test a feature, designing QA approach, or creating test plans. Do NOT use for TDD implementation (use tdd-workflow) or E2E test execution (use e2e-runner)."
tools: Read, Grep, Glob
model: opus
metadata:
  author: jaehashin
  version: 1.2.0
---

# Testing Strategy Skill

Provides a systematic workflow for test strategy planning and quality assurance.

## When to Use

- Designing test strategy for new features
- Improving test coverage
- Creating QA checklists
- Designing test scenarios

## Stack Detection (Auto)

Before designing strategy, detect the project's test stack:

```
1. Check package.json → Jest/Vitest/Mocha/Playwright/Cypress
2. Check requirements.txt/pyproject.toml → pytest/unittest
3. Check build.gradle/pom.xml → JUnit/TestNG/Mockito
4. Check CI config (.github/workflows, Jenkinsfile) → existing test stages
5. Check existing test files → patterns already in use
```

**Auto-select test tools based on detection:**

| Stack | Unit | Integration | E2E |
|-------|------|-------------|-----|
| TypeScript/Node | Jest or Vitest | Supertest | Playwright |
| Python/FastAPI | pytest | pytest + httpx | Playwright |
| Java/Spring Boot | JUnit 5 | Spring Boot Test | Selenium/Playwright |
| React/Next.js | Vitest + RTL | MSW | Playwright/Cypress |

If no test infrastructure exists, recommend setup based on detected stack before proceeding to strategy design.

## The Process

### Phase 1: Test Scope Analysis

**Current State Assessment:**
1. Analyze existing test code structure (`tests/`, `__tests__/`, `*.spec.*`)
2. Check current coverage
3. Review test stages in CI pipeline

**Scope Definition:**
- In Scope: What to test this time
- Out of Scope: What to exclude and why
- Dependencies: External dependencies requiring mocks/stubs

### Phase 2: Test Pyramid Design

```
Ratio Guide:

┌─────────────────────────────────────┐
│  E2E (5-10%)                        │
│  - Critical User Journeys only      │
│  - Execution: Slow                  │
│  - Maintenance: Difficult           │
├─────────────────────────────────────┤
│  Integration (15-25%)               │
│  - API boundaries, DB integration   │
│  - Module interactions              │
├─────────────────────────────────────┤
│  Unit (70-80%)                      │
│  - Pure functions, business logic   │
│  - Fast feedback                    │
│  - Isolated tests                   │
└─────────────────────────────────────┘
```

### Phase 3: Test Scenario Writing

**Scenario Categories:**

| Type | Description | Example |
|------|-------------|---------|
| Happy Path | Normal flow | Valid input → Success |
| Edge Cases | Boundary conditions | Empty array, max value, null |
| Error Cases | Error handling | Invalid input, network error |
| Security | Security scenarios | Unauthenticated access, permission overflow |

**Boundary Value Analysis (BVA):**
```
Input range: 1-100

Test values:
- 0 (lower -1) → Error
- 1 (lower bound) → Success
- 50 (middle) → Success
- 100 (upper bound) → Success
- 101 (upper +1) → Error
```

### Phase 4: Test Code Writing Guide

**AAA Pattern:**
```
def test_feature_condition_expectedResult():
    # Arrange - Setup
    user = User(name="test")

    # Act - Execute
    result = user.greet()

    # Assert - Verify
    assert result == "Hello, test"
```

**FIRST Principles:**
- **F**ast: Execute quickly
- **I**ndependent: No dependency on other tests
- **R**epeatable: Always same result
- **S**elf-validating: Clear success/failure
- **T**imely: Written alongside code

### Phase 5: Test Execution and Verification

**Coverage Targets:**
```
Target Setting Guide:

- Line Coverage: 80%+ (minimum baseline)
- Branch Coverage: 75%+ (conditional verification)
- Function Coverage: 90%+ (prevent function omission)

Note: Coverage is a means, not an end
High coverage ≠ Good tests
```

**Flaky Test Handling:**
1. Identify reproduction conditions
2. Timing issues → Explicit waits
3. Order dependency → Strengthen isolation
4. External dependency → Mock handling

## Output Templates

### Test Strategy Document
```markdown
# Test Strategy: [Feature Name]

## Test Scope
- **In Scope:**
- **Out of Scope:**

## Test Pyramid
| Type | Ratio | Target | Tools |
|------|-------|--------|-------|
| Unit | 70% | Business logic | Jest/Pytest/JUnit |
| Integration | 20% | API, DB | Supertest/pytest |
| E2E | 10% | Critical flows | Playwright/Cypress |

## Test Scenarios
### Normal Cases
| ID | Scenario | Input | Expected Result |
|----|----------|-------|-----------------|

### Exception Cases
| ID | Scenario | Input | Expected Result |
|----|----------|-------|-----------------|

## Coverage Targets
- Line: 80%
- Branch: 75%

## Test Environment
- Local: Docker Compose
- CI: GitHub Actions
```

## Key Principles

1. **Test First (TDD)**: Write tests before code when possible
2. **Isolation**: Each test must run independently
3. **Clear Failure**: Cause should be immediately apparent on failure
4. **Maintainability**: Manage test code like production code
5. **Appropriate Level**: Meaningful tests over 100% coverage

## Completion

테스트 전략 문서가 생성되고 사용자가 승인하면 완료.

## Troubleshooting

**Coverage is high but bugs still slip through**: Coverage measures lines executed, not behavior verified. Audit assertions — tests with no meaningful assertions inflate coverage without catching bugs.
**Test pyramid ratio is wrong (too many E2E)**: Identify E2E tests that test only one module’s logic and convert to unit/integration tests. Reserve E2E for cross-module critical paths only.
**Flaky tests blocking CI**: Quarantine flaky tests immediately (move to separate suite). Fix root cause (timing, order dependency, external state) before restoring to main suite.
