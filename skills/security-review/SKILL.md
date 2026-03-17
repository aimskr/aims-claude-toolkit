---
name: security-review
description: "보안, 보안 리뷰, 보안 검토, 취약점, 보안 분석, OWASP, 인증, 인가, 취약점 점검 - Systematic security analysis based on OWASP Top 10. Reviews code for vulnerabilities, designs auth/authz systems, and produces severity-classified reports. Use when auditing security, designing authentication, or pre-deployment security checks. Do NOT use for general code quality reviews (use code-reviewer) or debugging (use debug-specialist)."
tools: Read, Grep, Glob, WebSearch
model: opus
metadata:
  author: jaehashin
  version: 1.2.0
---

# Security Review Skill

Systematic workflow for security review and vulnerability analysis.

## When to Use

- Reviewing code for security vulnerabilities
- Designing authentication/authorization systems
- Establishing sensitive data handling practices
- Pre-deployment security checklist verification

## The Process

### Phase 1: Security Scope Assessment

**Codebase Analysis:**
1. Identify authentication/authorization code
2. Map external input handling points
3. Trace sensitive data flow
4. Check external API integration points

**Attack Surface Definition:**
- User input: forms, URL params, headers
- File uploads: type, size, storage location
- API endpoints: public/private, auth requirements
- Database: query generation methods

### Phase 2: OWASP Top 10 Check

Perform systematic check against OWASP Top 10 (2021):
- A01: Broken Access Control
- A02: Cryptographic Failures
- A03: Injection
- A04: Insecure Design
- A05: Security Misconfiguration
- A06: Vulnerable Components
- A07: Authentication Failures
- A08: Data Integrity Failures
- A09: Logging Failures
- A10: SSRF

**For detailed checklist, code patterns, and search queries:**
**Read `OWASP-CHECKLIST.md` in this skill directory.**

### Phase 3: Vulnerability Report

**Severity Classification:**
| Level | Description | Response Time |
|-------|-------------|---------------|
| 🔴 Critical | Immediately exploitable, severe impact | Within 24h |
| 🟠 High | Exploitable, significant impact | Within 1 week |
| 🟡 Medium | Conditional exploit, limited impact | Within 1 month |
| 🟢 Low | Hard to exploit, minimal impact | Next release |

### Phase 4: Security Design Recommendations

Provide recommendations for:
- Authentication design (JWT, session management)
- Authorization model (RBAC, ABAC)
- Data encryption strategies
- Secure coding practices

## Key Principles

1. **Zero Trust**: Never trust any input
2. **Defense in Depth**: Multi-layer defense
3. **Least Privilege**: Minimum required permissions
4. **Fail Secure**: Safe state on failure
5. **Security by Design**: Consider security from design phase

## Detailed Reference

For OWASP checklist, vulnerable code patterns, search queries, and report templates:
**Read `OWASP-CHECKLIST.md` in this skill directory.**

## Completion

취약점 리포트(Severity 분류 + 권고 사항)가 전달되면 완료.

## Troubleshooting

**Too many findings to prioritize**: Focus on Critical/High first. If >20 Critical findings, the codebase likely needs a dedicated security sprint rather than a review.
**False positives from pattern matching**: Verify each finding with actual data flow analysis. A SQL query using parameterized binding is safe even if grep finds `SELECT` near user input.
**Team pushes back on security fixes**: Quantify risk with severity + exploitability. "This allows unauthenticated admin access" is more actionable than "A01 violation found."
