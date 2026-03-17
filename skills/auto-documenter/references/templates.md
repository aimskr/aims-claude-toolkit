# Auto-Documenter 템플릿

## architecture.md 템플릿

```markdown
# [프로젝트명] 아키텍처 문서

> 최종 업데이트: YYYY-MM-DD HH:mm
> ⚠ LLM 자동 생성 문서. 사용자 검토 완료: [예/아니오]

## 기술 스택

| 분류 | 기술 | 버전 | 근거 소스 |
|------|------|------|-----------|
| 언어 | | | <!-- 예: package.json → node v20 --> |
| 프레임워크 | | | |
| DB | | | |
| 인프라 | | | |

## 프로젝트 구조

\`\`\`
src/
├── ...
\`\`\`

## 레이어 구조

\`\`\`
[진입점] → [비즈니스 로직] → [데이터 접근] → [저장소]
\`\`\`
<!-- 근거: src/ 디렉토리 구조 분석 결과 -->

## 주요 모듈

| 모듈 | 경로 | 역할 |
|------|------|------|
| | | |

## 데이터 플로우

\`\`\`
[요청] → [처리] → [응답]
\`\`\`
<!-- 근거: 진입점 파일의 라우팅/핸들러 분석 결과 -->

## 외부 연동

| 서비스 | 용도 | 연동 방식 |
|--------|------|-----------|
| | | |
```

---

## memory.md 템플릿 (초기 헤더)

```markdown
# 프로젝트 Memory

> 작업 요약 및 변경 이력. 로테이션 관리됨 (기본: 50KB 또는 50건 초과 시).
> 초과분은 `archive/`로 이동.

---

```

---

## memory.md 항목 포맷

```markdown
### #번호 — YYYY-MM-DD HH:mm | 규모

**작업**: 무엇을 했는지 (1줄)
**이유**: 왜 했는지 (1줄)
**변경 파일**: `path/to/file1.py`, `path/to/file2.py` 외 N개
**의사결정**: 핵심 결정사항 (있을 경우만)
**관련 ADR**: [NNNN.날짜-제목](decisions/NNNN.날짜-제목.md) (있을 경우만)
```

---

## ADR 템플릿

```markdown
# NNNN. 제목

**날짜**: YYYY-MM-DD
**상태**: Accepted | Deprecated by [NNNN] | Superseded by [NNNN]
**규모**: Medium / Large

## 배경

왜 이 결정이 필요했는지.

## 결정

무엇을 선택했는지.

## 대안

| 대안 | 장점 | 단점 | 탈락 이유 |
|------|------|------|-----------|
| | | | |

## 결과

이 결정으로 인해 변경된 사항.

## 관련 ADR

- 선행: [NNNN.제목](NNNN.날짜-제목.md) (있을 경우)
- 대체 대상: [NNNN.제목](NNNN.날짜-제목.md) (있을 경우)
```

---

## archive/memory-YYYY-MM.md 포맷

```markdown
# Memory Archive — YYYY년 MM월

> 보존 기간: 생성일로부터 6개월 (기본값)

| 날짜 | 번호 | 규모 | 파일 수 | 요약 |
|------|------|------|--------|------|
| YYYY-MM-DD | #번호 | Small | 2개 | 작업 요약 1줄 |
```

---

## .documenter-config 템플릿 (선택사항)

```yaml
rotation:
  max_size_kb: 50
  max_entries: 50
  archive_retention_months: 6
  archive_detail: compact  # compact | full (full = 파일 목록 보존)
behavior:
  auto_run: true
  require_approval: large  # large | medium | all
  skip_patterns: []        # 예: ["feature/prototype-*", "*.test.*"]
  docs_root: docs          # 문서 루트 경로 (기본: docs/)
```
