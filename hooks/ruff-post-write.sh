#!/usr/bin/env bash
set -euo pipefail

# stdin에서 JSON payload 읽기
input=$(cat)

# file_path 추출
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# .py 파일이 아니면 스킵
if [[ -z "$file_path" || "$file_path" != *.py || ! -f "$file_path" ]]; then
  exit 0
fi

# ruff 바이너리 탐색
RUFF="/Users/sinjaeha/.local/bin/ruff"
if [[ ! -x "$RUFF" ]]; then
  RUFF=$(command -v ruff 2>/dev/null || true)
fi
if [[ -z "$RUFF" || ! -x "$RUFF" ]]; then
  exit 0
fi

# 1) ruff check --fix (린트 자동 수정)
if ! "$RUFF" check --fix --quiet "$file_path" 2>/dev/null; then
  remaining=$("$RUFF" check --output-format concise "$file_path" 2>/dev/null || true)
  if [[ -n "$remaining" ]]; then
    echo "ruff: unfixable lint violations in $file_path:" >&2
    echo "$remaining" >&2
  fi
fi

# 2) ruff format (포맷팅)
if ! "$RUFF" format --quiet "$file_path" 2>/dev/null; then
  echo "ruff: format failed for $file_path" >&2
fi

exit 0
