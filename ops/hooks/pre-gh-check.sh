#!/usr/bin/env bash
# ops/hooks/pre-gh-check.sh — gh コマンドの安全性検証
# Claude Code の PreToolUse hook として使用
#
# 入力: stdin から JSON (tool_name, tool_input)
# 出力: JSON ({decision, reason})
#
# ルール:
# 1. gh に --repo kiwamust/org を強制（cross-repo 防止）
# 2. gh issue delete をブロック
# 3. gh issue close はワーニング（ブロックはしない）

set -euo pipefail

# Read hook input from stdin
INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only process Bash tool calls
if [ "$TOOL_NAME" != "Bash" ]; then
  echo '{"decision": "approve"}'
  exit 0
fi

# Only check gh commands
if ! echo "$TOOL_INPUT" | grep -q "^gh "; then
  echo '{"decision": "approve"}'
  exit 0
fi

# Rule 1: Block gh issue delete
if echo "$TOOL_INPUT" | grep -qE "gh\s+issue\s+delete"; then
  echo '{"decision": "block", "reason": "gh issue delete は禁止されています。Issue は close で対応してください。"}'
  exit 0
fi

# Rule 2: Warn on gh issue close (don't block)
if echo "$TOOL_INPUT" | grep -qE "gh\s+issue\s+close"; then
  # Approve but the warning is informational via stderr
  echo '{"decision": "approve"}'
  exit 0
fi

# Rule 3: Check for --repo flag on gh issue/pr commands
if echo "$TOOL_INPUT" | grep -qE "gh\s+(issue|pr)\s+" ; then
  if ! echo "$TOOL_INPUT" | grep -q "\-\-repo kiwamust/org"; then
    # Check if it might be using shorthand -R
    if ! echo "$TOOL_INPUT" | grep -q "\-R kiwamust/org"; then
      echo '{"decision": "block", "reason": "gh issue/pr コマンドには --repo kiwamust/org を指定してください（cross-repo 防止）。"}'
      exit 0
    fi
  fi
fi

echo '{"decision": "approve"}'
exit 0
