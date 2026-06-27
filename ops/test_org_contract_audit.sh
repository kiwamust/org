#!/usr/bin/env bash
# Regression tests for ops/audit-org-contract.sh.

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

cat >"$TMPDIR/good.json" <<'JSON'
[
  {
    "number": 1,
    "title": "PJ: OTO pilot setup",
    "state": "OPEN",
    "labels": [{"name":"org:type/project"},{"name":"org:phase/intake"}],
    "body": "parent_project: life:1\nwork_ref: work:otoprism\nEvidence Strictness: ES-2\nrole: Strategist Agent\nphase: intake\nexpected_return: pilot charter\ngate:\n  type: UQG\ncloseout_evidence:\n  artifact_refs: []\nnext_circulation: Life"
  },
  {
    "number": 2,
    "title": "TASK: OTO signal capture",
    "state": "OPEN",
    "labels": [{"name":"org:type/task"},{"name":"org:phase/execute"}],
    "body": "parent_project: life:1\nwork_ref: work:otoprism\nData_profile: ES-2\nrole: Data Steward Agent\nphase: execute\nexpected_return: signal fields\ngate: MVP experiment gate\ncloseout_evidence:\n  artifact_refs: []\nnext_circulation: Data-Evidence"
  },
  {
    "number": 3,
    "title": "QG: OTO interview script",
    "state": "OPEN",
    "labels": [{"name":"org:type/quality-gate"},{"name":"org:quality/gate-pending"}],
    "body": "data_profile: ES-2\ngate: MVP experiment gate\nrequired_evidence:\n  Data-Evidence:\n  Work:\n  Life:\nresult: pending\nnext_circulation: Org"
  }
]
JSON

good_output="$("$ROOT/ops/audit-org-contract.sh" --from-file "$TMPDIR/good.json")"
assert_contains "$good_output" "Result: pass"
assert_contains "$good_output" "Missing critical fields: 0"
assert_contains "$good_output" "Active Org tasks"

cat >"$TMPDIR/missing.json" <<'JSON'
[
  {
    "number": 4,
    "title": "TASK: Missing contract fields",
    "state": "OPEN",
    "labels": [{"name":"org:type/task"},{"name":"org:phase/execute"}],
    "body": "Do something useful."
  }
]
JSON

set +e
missing_output="$("$ROOT/ops/audit-org-contract.sh" --from-file "$TMPDIR/missing.json" 2>&1)"
missing_status=$?
set -e

if [[ "$missing_status" -eq 0 ]]; then
  echo "Expected missing contract fields to fail" >&2
  echo "$missing_output" >&2
  exit 1
fi

assert_contains "$missing_output" "Missing critical fields: 1"
assert_contains "$missing_output" "parent_project"
assert_contains "$missing_output" "next_circulation"
assert_contains "$missing_output" "Result: fail"

cat >"$TMPDIR/wip.json" <<'JSON'
[
  {"number": 10, "title": "TASK: 1", "state": "OPEN", "labels": [{"name":"org:type/task"},{"name":"org:phase/execute"}], "body": "parent_project: life\nwork_ref: work\nData_profile: ES-2\nrole: Codex Executor\nphase: execute\nexpected_return: x\ngate: UQG\ncloseout_evidence: x\nnext_circulation: Org"},
  {"number": 11, "title": "TASK: 2", "state": "OPEN", "labels": [{"name":"org:type/task"},{"name":"org:phase/execute"}], "body": "parent_project: life\nwork_ref: work\nData_profile: ES-2\nrole: Codex Executor\nphase: execute\nexpected_return: x\ngate: UQG\ncloseout_evidence: x\nnext_circulation: Org"},
  {"number": 12, "title": "TASK: 3", "state": "OPEN", "labels": [{"name":"org:type/task"},{"name":"org:phase/execute"}], "body": "parent_project: life\nwork_ref: work\nData_profile: ES-2\nrole: Codex Executor\nphase: execute\nexpected_return: x\ngate: UQG\ncloseout_evidence: x\nnext_circulation: Org"},
  {"number": 13, "title": "TASK: 4", "state": "OPEN", "labels": [{"name":"org:type/task"},{"name":"org:phase/execute"}], "body": "parent_project: life\nwork_ref: work\nData_profile: ES-2\nrole: Codex Executor\nphase: execute\nexpected_return: x\ngate: UQG\ncloseout_evidence: x\nnext_circulation: Org"},
  {"number": 14, "title": "TASK: 5", "state": "OPEN", "labels": [{"name":"org:type/task"},{"name":"org:phase/execute"}], "body": "parent_project: life\nwork_ref: work\nData_profile: ES-2\nrole: Codex Executor\nphase: execute\nexpected_return: x\ngate: UQG\ncloseout_evidence: x\nnext_circulation: Org"},
  {"number": 15, "title": "TASK: 6", "state": "OPEN", "labels": [{"name":"org:type/task"},{"name":"org:phase/execute"}], "body": "parent_project: life\nwork_ref: work\nData_profile: ES-2\nrole: Codex Executor\nphase: execute\nexpected_return: x\ngate: UQG\ncloseout_evidence: x\nnext_circulation: Org"},
  {"number": 16, "title": "TASK: 7", "state": "OPEN", "labels": [{"name":"org:type/task"},{"name":"org:phase/execute"}], "body": "parent_project: life\nwork_ref: work\nData_profile: ES-2\nrole: Codex Executor\nphase: execute\nexpected_return: x\ngate: UQG\ncloseout_evidence: x\nnext_circulation: Org"},
  {"number": 17, "title": "TASK: 8", "state": "OPEN", "labels": [{"name":"org:type/task"},{"name":"org:phase/execute"}], "body": "parent_project: life\nwork_ref: work\nData_profile: ES-2\nrole: Codex Executor\nphase: execute\nexpected_return: x\ngate: UQG\ncloseout_evidence: x\nnext_circulation: Org"}
]
JSON

set +e
wip_output="$("$ROOT/ops/audit-org-contract.sh" --from-file "$TMPDIR/wip.json" 2>&1)"
wip_status=$?
set -e

if [[ "$wip_status" -eq 0 ]]; then
  echo "Expected WIP limit breach to fail" >&2
  echo "$wip_output" >&2
  exit 1
fi

assert_contains "$wip_output" "Active Org tasks"
assert_contains "$wip_output" "FAIL"
assert_contains "$wip_output" "Result: fail"

echo "org contract audit tests passed"
