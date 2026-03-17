#!/bin/bash
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Java 파일
if [[ "$file_path" =~ \.java$ ]]; then
  if command -v google-java-format &>/dev/null; then
    google-java-format --replace "$file_path" 2>/dev/null
  fi
  exit 0
fi

# Kotlin 파일
if [[ "$file_path" =~ \.kt$ ]]; then
  if command -v ktlint &>/dev/null; then
    ktlint --format "$file_path" 2>/dev/null
    remaining=$(ktlint "$file_path" 2>&1)
    if [ -n "$remaining" ]; then
      echo "ktlint warnings remaining:" >&2
      echo "$remaining" >&2
    fi
  fi
  exit 0
fi

exit 0
