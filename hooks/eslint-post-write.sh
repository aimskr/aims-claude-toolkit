#!/bin/bash
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# TS/JS 파일만 대상
if [[ ! "$file_path" =~ \.(ts|tsx|js|jsx)$ ]]; then
  exit 0
fi

# 파일 존재 확인
if [ ! -f "$file_path" ]; then
  exit 0
fi

# eslint 감지 (프로젝트 로컬 → npx fallback)
project_dir="${CLAUDE_PROJECT_DIR:-.}"
if [ -x "$project_dir/node_modules/.bin/eslint" ]; then
  ESLINT="$project_dir/node_modules/.bin/eslint"
elif command -v npx &>/dev/null; then
  ESLINT="npx eslint"
else
  exit 0  # eslint 없으면 스킵
fi

# eslint --fix 실행
$ESLINT --fix --quiet "$file_path" 2>/dev/null

# 수정 불가 에러가 있으면 stderr로 출력
remaining=$($ESLINT --quiet "$file_path" 2>&1)
if [ -n "$remaining" ]; then
  echo "ESLint warnings remaining:" >&2
  echo "$remaining" >&2
fi

exit 0
