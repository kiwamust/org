#!/usr/bin/env bash
# Regression tests for the Codex Automation self-prompt contract.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GITHUB_WORKFLOW="$ROOT/.github/workflows/org-self-prompt.yml"
CODEX_AUTOMATION="$ROOT/docs/CODEX_AUTOMATION_SELF_PROMPT.md"

assert_file_contains() {
  local file="$1"
  local needle="$2"
  if ! grep -Fq -- "$needle" "$file"; then
    echo "Expected $file to contain: $needle" >&2
    exit 1
  fi
}

if [[ -f "$GITHUB_WORKFLOW" ]]; then
  echo "GitHub Actions workflow must not exist: $GITHUB_WORKFLOW" >&2
  exit 1
fi

if [[ ! -f "$CODEX_AUTOMATION" ]]; then
  echo "Missing Codex Automation contract: $CODEX_AUTOMATION" >&2
  exit 1
fi

assert_file_contains "$CODEX_AUTOMATION" "# Codex Automation — Org Self-Prompt"
assert_file_contains "$CODEX_AUTOMATION" "08:00 JST"
assert_file_contains "$CODEX_AUTOMATION" "13:00 JST"
assert_file_contains "$CODEX_AUTOMATION" "19:00 JST"
assert_file_contains "$CODEX_AUTOMATION" "Do not create Issues"
assert_file_contains "$CODEX_AUTOMATION" "Do not change labels"
assert_file_contains "$CODEX_AUTOMATION" "Do not push changes"
assert_file_contains "$CODEX_AUTOMATION" "bash ops/self-prompt.sh"
assert_file_contains "$CODEX_AUTOMATION" "approval question"

echo "self-prompt automation tests passed"
