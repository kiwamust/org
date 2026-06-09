#!/usr/bin/env bash
# Lightweight regression tests for the org self-prompt loop.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

assert_contains() {
  local haystack="$1"
  local needle="$2"
  if [[ "$haystack" != *"$needle"* ]]; then
    echo "Expected output to contain: $needle" >&2
    echo "--- output ---" >&2
    echo "$haystack" >&2
    exit 1
  fi
}

cat >"$TMPDIR/issues.tsv" <<'EOF'
31	Fix gate-fail loop in Work handoff	org:type/improvement,org:status/red,org:quality/gate-fail,org:dept/operations
32	Draft public article from research synthesis	org:type/task,org:status/green,org:dept/brand,org:gbt/target
EOF

output="$("$ROOT/ops/self-prompt.sh" --from-file "$TMPDIR/issues.tsv")"

assert_contains "$output" "# org self-prompt candidates"
assert_contains "$output" "Mode: proposal-only"
assert_contains "$output" "Title: DIR: Recover gate failure in #31 - Fix gate-fail loop in Work handoff"
assert_contains "$output" "GBT: behavior"
assert_contains "$output" "Dept: operations"
assert_contains "$output" "Priority: p1"
assert_contains "$output" "Evidence: #31"
assert_contains "$output" "No GitHub Issue is created until the user approves one candidate."

empty_output="$("$ROOT/ops/self-prompt.sh" --from-file /dev/null)"

assert_contains "$empty_output" "No open org issues were observed."
assert_contains "$empty_output" "Title: DIR: Refresh org intake baseline"

mkdir -p "$TMPDIR/bin"
cat >"$TMPDIR/bin/gh" <<'EOF'
#!/usr/bin/env bash
echo "gh unavailable" >&2
exit 1
EOF
chmod +x "$TMPDIR/bin/gh"

set +e
failure_output="$(PATH="$TMPDIR/bin:$PATH" "$ROOT/ops/self-prompt.sh" 2>&1)"
failure_status=$?
set -e

if [[ "$failure_status" -eq 0 ]]; then
  echo "Expected gh observation failure to return non-zero" >&2
  echo "$failure_output" >&2
  exit 1
fi

assert_contains "$failure_output" "Unable to observe org issues"
assert_contains "$failure_output" "No candidate generated"

echo "self-prompt tests passed"
