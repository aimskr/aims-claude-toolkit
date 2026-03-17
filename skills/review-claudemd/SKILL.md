---
name: review-claudemd
description: "CLAUDE.md 리뷰, CLAUDE.md 개선, 대화 분석, 설정 개선, 프롬프트 최적화, 컨텍스트 최적화 - Analyzes recent conversation history to find improvements for global and local CLAUDE.md files. Use when reviewing CLAUDE.md settings, improving Claude Code context, or analyzing past conversations for patterns. Do NOT use for document writing (use doc-coauthoring) or project planning."
tools: Bash, Read, Write, Grep, Glob
model: opus
metadata:
  author: jaehashin
  version: 1.2.0
---
# Review CLAUDE.md from conversation history
Analyze recent conversations to improve both global (~/.claude/CLAUDE.md) and local (project) CLAUDE.md files.
## Step 1: Find conversation history
The project's conversation history is in ~/.claude/projects/. The folder name is the project path with slashes replaced by dashes.
bash
# Find the project folder (replace / with -)
PROJECT_PATH=$(pwd | sed 's|/|-|g' | sed 's|^-||')
CONVO_DIR=~/.claude/projects/-${PROJECT_PATH}
ls -lt "$CONVO_DIR"/*.jsonl | head -20

## Step 2: Extract recent conversations
Extract the 15-20 most recent conversations (excluding the current one) to a temp directory:
bash
SCRATCH=/tmp/claudemd-review-$(date +%s)
mkdir -p "$SCRATCH"
for f in $(ls -t "$CONVO_DIR"/*.jsonl | head -20); do
  basename=$(basename "$f" .jsonl)
  # Skip current conversation if known
  cat "$f" | jq -r '
    if .type == "user" then
      "USER: " + (.message.content // "")
    elif .type == "assistant" then
      "ASSISTANT: " + ((.message.content // []) | map(select(.type == "text") | .text) | join("\n"))
    else
      empty
    end
  ' 2>/dev/null | grep -v "^ASSISTANT: $" > "$SCRATCH/${basename}.txt"
done
ls -lhS "$SCRATCH"

## Step 3: Spin up Sonnet subagents
Launch parallel Sonnet subagents to analyze conversations. Each agent should read:
- Global CLAUDE.md: ~/.claude/CLAUDE.md
- Local CLAUDE.md: ./CLAUDE.md (if exists)
- Batch of conversation files
Give each agent this prompt template:

Read:
1. Global CLAUDE.md: ~/.claude/CLAUDE.md
2. Local CLAUDE.md: [project]/CLAUDE.md
3. Conversations: [list of files]
Analyze the conversations against BOTH CLAUDE.md files. Find:
1. Instructions that exist but were violated (need reinforcement or rewording)
2. Patterns that should be added to LOCAL CLAUDE.md (project-specific)
3. Patterns that should be added to GLOBAL CLAUDE.md (applies everywhere)
4. Anything in either file that seems outdated or unnecessary
Be specific. Output bullet points only.

Batch conversations by size:
- Large (>100KB): 1-2 per agent
- Medium (10-100KB): 3-5 per agent
- Small (<10KB): 5-10 per agent
## Step 4: Aggregate findings
Combine results from all agents into a summary with these sections:
1. **Instructions violated** - existing rules that weren't followed (need stronger wording)
2. **Suggested additions - LOCAL** - project-specific patterns
3. **Suggested additions - GLOBAL** - patterns that apply everywhere
4. **Potentially outdated** - items that may no longer be relevant
Present as tables or bullet points. Ask user if they want edits drafted.

## Completion

분석 결과(violations, suggested additions, potentially outdated)가 집계되고 사용자가 검토하면 완료.

## Troubleshooting

**Conversation history is empty or too few files**: Check the project path mapping (slashes → dashes). If the user started with a different project path, the folder name won't match.
**Subagents return conflicting recommendations**: Prioritize by frequency — if 3+ agents flag the same pattern, it's a strong signal. Unique findings need manual user review.
**CLAUDE.md is already well-optimized**: Focus on Step 4 "potentially outdated" items. Even good configs accumulate stale rules over time.
