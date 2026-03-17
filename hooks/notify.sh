#!/bin/bash
input=$(cat)
notification_type=$(echo "$input" | jq -r '.notification_type // empty')
message=$(echo "$input" | jq -r '.notification_message // "Claude Code notification"')

case "$notification_type" in
  "permission_prompt")
    title="Claude Code - 권한 요청"
    ;;
  "idle_prompt")
    title="Claude Code - 작업 완료"
    ;;
  *)
    exit 0
    ;;
esac

osascript -e "display notification \"$message\" with title \"$title\"" 2>/dev/null
exit 0
