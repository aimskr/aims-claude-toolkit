#!/bin/bash
# stdin에서 JSON 읽기
input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

# git push 또는 git commit 명령인지 확인
if ! echo "$command" | grep -qE '^\s*git\s+(push|commit)'; then
  exit 0
fi

# 현재 브랜치 확인
current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
protected_branches="main dev"

for branch in $protected_branches; do
  if [ "$current_branch" = "$branch" ]; then
    # push 대상 브랜치도 확인 (git push origin main 등)
    if echo "$command" | grep -qE '^\s*git\s+push'; then
      echo "BLOCKED: '$branch' 브랜치에 직접 push할 수 없습니다. feature 브랜치를 사용하세요." >&2
      exit 2
    fi
    if echo "$command" | grep -qE '^\s*git\s+commit'; then
      echo "BLOCKED: '$branch' 브랜치에서 직접 commit할 수 없습니다. feature 브랜치를 사용하세요." >&2
      exit 2
    fi
  fi
done

exit 0
