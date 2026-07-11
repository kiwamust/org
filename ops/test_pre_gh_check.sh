#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="$ROOT/ops/hooks/pre-gh-check.sh"

probe() {
  local command="$1"
  local expected="$2"
  local actual
  actual="$(jq -cn --arg command "$command" \
    '{tool_name:"Bash",tool_input:{command:$command}}' \
    | "$HOOK" \
    | jq -r '.decision')"
  if [[ "$actual" != "$expected" ]]; then
    printf 'command=%q expected=%s actual=%s\n' "$command" "$expected" "$actual" >&2
    return 1
  fi
}

probe 'gh issue list --repo kiwamust/org' approve
probe 'gh pr list -R kiwamust/org' approve
probe 'gh issue list' block
probe 'command gh issue delete 1 --repo kiwamust/org' block
probe 'GH_PAGER=cat gh issue list --repo kiwamust/other' block
probe 'bash -lc "gh issue list --repo kiwamust/org"' block
probe '/opt/homebrew/bin/gh issue list --repo kiwamust/org' block
probe 'gh api --method DELETE repos/kiwamust/org/issues/1' block
probe 'gh issue list --repo kiwamust/org-attacker' block
probe 'gh issue list --repo kiwamust/org && echo unsafe' block
probe 'echo hello' approve

invalid="$(printf 'not-json' | "$HOOK" | jq -r '.decision')"
if [[ "$invalid" != "block" ]]; then
  echo "invalid JSON must block" >&2
  exit 1
fi

echo "pre-gh hook tests passed"
