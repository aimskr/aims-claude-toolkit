# aims-claude-toolkit

AIMS 팀을 위한 Claude Code 통합 도구 모음입니다. Skills, Agents, Hooks, LSP, MCP를 포함합니다.

## 구성 요소

| 구성 | 수량 | 설명 |
|------|------|------|
| Skills | 29개 | 기획~개발~검증~문서화 전 단계 자동화 스킬 |
| Agents | 11개 | 병렬 코드 리뷰 및 구현 전문 에이전트 |
| Hooks | 5개 | Git 보호, 린터, 포매터, 알림 자동화 |
| LSP | 4개 | Python, TypeScript/JS, Java, Swift 코드 인텔리전스 |
| MCP | 2개 | Context7, Playwright |

## 사전 요구사항

- **Node.js** 18 이상
- **Python** 3.10 이상

### LSP 서버 (선택)

LSP 기능을 사용하려면 해당 language server를 설치해야 합니다.

```bash
# Python
pip install pyright

# TypeScript/JavaScript
npm install -g typescript-language-server typescript

# Java
# jdtls 설치: https://github.com/eclipse-jdtls/eclipse.jdt.ls

# Swift (Xcode 포함)
# sourcekit-lsp는 Xcode에 기본 포함
```

## 환경 변수 설정

Context7 사용을 위해 API 키를 환경 변수로 설정해야 합니다.

```bash
# ~/.bashrc 또는 ~/.zshrc에 추가
export CONTEXT7_API_KEY="your-api-key"
```

## 설치 방법

### 1단계: 마켓플레이스 등록

```bash
claude plugin marketplace add aimskr/aims-claude-toolkit
```

### 2단계: 플러그인 설치

```bash
claude plugin install aims-toolkit
```

프로젝트 범위로 설치하려면:

```bash
claude plugin install aims-toolkit --scope project
```

## MCP 서버

| 서버 | 설명 |
|------|------|
| context7 | 컨텍스트 기반 코드 이해 도구 |
| playwright | 브라우저 자동화 및 테스트 도구 |

## LSP 서버

| 서버 | Command | 지원 확장자 |
|------|---------|------------|
| Pyright | `pyright-langserver` | `.py`, `.pyi` |
| TypeScript | `typescript-language-server` | `.ts`, `.tsx`, `.js`, `.jsx`, `.mts`, `.cts`, `.mjs`, `.cjs` |
| JDTLS | `jdtls` | `.java` |
| SourceKit | `sourcekit-lsp` | `.swift` |

## Skills

### 기획/설계 단계

| 스킬 | 설명 |
|------|------|
| brainstorming | 아이디어 브레인스토밍 및 요구사항 탐색 |
| prd-strategist | PRD 및 제품 전략 수립 |
| writing-plans | 구현 계획 작성 |
| sequential-thinking | 복잡한 문제의 단계별 분석 및 의사결정 |
| research | 기술 자료 조사 (병렬 전문가 에이전트) |
| learning-research | 학습 자료 수집 및 체계화 |
| market-research | 시장조사 및 경쟁분석 |

### 개발 단계

| 스킬 | 설명 |
|------|------|
| code-explorer | LSP 기반 코드 탐색 및 분석 |
| architect | 시스템/피처 아키텍처 설계 |
| feature-development | 7단계 체계적 기능 개발 워크플로우 |
| harness | 스펙 기반 병렬 TDD 개발 (Agent Teams) |
| tdd-workflow | Red-Green-Refactor TDD 사이클 |
| code-conventions | 코드 컨벤션 가이드 (TypeScript, Python, Java) |
| ui-ux-design | UI/UX 디자인 및 라이브 리뷰 |
| code-simpler | 코드 복잡도 감소 및 단순화 |
| refactor-cleaner | 데드 코드 제거 및 정리 |
| e2e-runner | Playwright 기반 E2E 테스트 |
| codex | OpenAI Codex CLI 연동 |

### 검증 단계

| 스킬 | 설명 |
|------|------|
| code-reviewer | 7개 전문 에이전트 병렬 코드 리뷰 |
| security-review | OWASP 기반 보안 취약점 분석 |
| debug-specialist | 런타임 버그 근본 원인 분석 |
| build-error-resolver | 빌드/컴파일 에러 진단 및 해결 |
| testing-strategy | 테스트 전략 설계 |
| devil-advocate | Devil's Advocate 비판적 검토 |

### 문서/운영 단계

| 스킬 | 설명 |
|------|------|
| doc-coauthoring | 문서 공동 작성 (스펙, 제안서, RFC) |
| auto-documenter | 작업 후 자동 문서화 (architecture.md, ADR) |
| github-operator | Git/GitHub 커밋, 브랜치, PR 운영 |
| review-claudemd | CLAUDE.md 분석 및 최적화 |

## Agents

| 에이전트 | 모델 | 역할 |
|----------|------|------|
| researcher | Haiku | 코드베이스 빠른 탐색 (read-only) |
| implementer | Opus | 코드 구현 |
| tester | Sonnet | 테스트 작성 및 실행 |
| reviewer | Opus | 코드 리뷰 (read-only) |
| arch-reviewer | Opus | 아키텍처 리뷰 (read-only) |
| security-reviewer | Opus | 보안 리뷰 (read-only) |
| perf-reviewer | Opus | 성능 리뷰 (read-only) |
| logic-reviewer | Opus | 로직/정확성 리뷰 (read-only) |
| readability-reviewer | Opus | 가독성/컨벤션 리뷰 (read-only) |
| test-reviewer | Opus | 테스트 품질 리뷰 (read-only) |
| simplicity-reviewer | Opus | 단순성/YAGNI 리뷰 (read-only) |

## Hooks

| 훅 | 트리거 | 설명 |
|----|--------|------|
| git-branch-protect.sh | PreToolUse (Bash) | main 브랜치 직접 커밋 차단 |
| ruff-post-write.sh | PostToolUse (Write/Edit) | Python 파일 자동 린트 |
| eslint-post-write.sh | PostToolUse (Write/Edit) | JS/TS 파일 자동 린트 |
| java-format-post-write.sh | PostToolUse (Write/Edit) | Java 파일 자동 포맷 |
| notify.sh | Notification | 작업 완료 알림 |

## 프로젝트 구조

```
aims-claude-toolkit/
├── .claude-plugin/        # 플러그인 메타데이터
│   ├── plugin.json        # 플러그인 설정 + LSP 서버 정의
│   └── marketplace.json   # 마켓플레이스 등록 정보
├── .mcp.json              # MCP 서버 설정 (context7, playwright)
├── skills/                # 29개 스킬 정의
├── agents/                # 11개 에이전트 정의
├── hooks/                 # 5개 훅 스크립트
├── settings.json          # Claude Code 설정 템플릿
├── CLAUDE.md              # 워크플로우 지침 및 스킬 오케스트레이션
└── README.md
```

## 로컬 테스트

```bash
claude --plugin-dir ./
```
