#!/usr/bin/env bash
# Regression tests for the scheduled self-prompt automation contract.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKFLOW="$ROOT/.github/workflows/org-self-prompt.yml"

assert_file_contains() {
  local file="$1"
  local needle="$2"
  if ! grep -Fq -- "$needle" "$file"; then
    echo "Expected $file to contain: $needle" >&2
    exit 1
  fi
}

if [[ ! -f "$WORKFLOW" ]]; then
  echo "Missing workflow: $WORKFLOW" >&2
  exit 1
fi

assert_file_contains "$WORKFLOW" "name: Org Self-Prompt"
assert_file_contains "$WORKFLOW" "- cron: '0 23 * * *' # 08:00 JST"
assert_file_contains "$WORKFLOW" "- cron: '0 4 * * *' # 13:00 JST"
assert_file_contains "$WORKFLOW" "- cron: '0 10 * * *' # 19:00 JST"
assert_file_contains "$WORKFLOW" "workflow_dispatch:"
assert_file_contains "$WORKFLOW" "issues: read"
assert_file_contains "$WORKFLOW" "GH_TOKEN: \${{ github.token }}"
assert_file_contains "$WORKFLOW" "bash ops/self-prompt.sh"
assert_file_contains "$WORKFLOW" "self-prompt.md"
assert_file_contains "$WORKFLOW" "actions/upload-artifact@v4"

echo "self-prompt automation tests passed"
