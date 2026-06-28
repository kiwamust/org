#!/usr/bin/env bash
# Regression tests for ops/qcd-operating-review.sh.

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
{
  "date": "2026-06-28",
  "repo": "kiwamust/org",
  "velocity": {
    "V1_throughput_weekly": 3,
    "V2_cycle_time_days": 2.5,
    "V3_gate_pass_rate": 100,
    "V4_rework_rate": 0,
    "V5_lead_time_days": 3
  },
  "quality": {
    "V6_first_pass_yield": 100,
    "V7_defect_density": 0,
    "V8_scope_creep_ratio": 0,
    "V9_red_status_count": 0,
    "V10_escalation_count": 0
  },
  "entropy": {
    "V11_wip_count": 2,
    "V12_dept_utilization": {"rnd":1},
    "V12_dept_total": 2,
    "V13_blocked_count": 0,
    "V14_stale_count": 0,
    "V15_cross_dept_count": 0
  }
}
JSON

good_output="$("$ROOT/ops/qcd-operating-review.sh" --from-file "$TMPDIR/good.json")"
assert_contains "$good_output" "Result: pass"
assert_contains "$good_output" "Next operation: continue"
assert_contains "$good_output" $'| Quality | gate_pass_rate | 100% | >=80% | continue | Keep gate placement |\n| Quality | first_pass_yield'

cat >"$TMPDIR/bad.json" <<'JSON'
{
  "date": "2026-06-28",
  "repo": "kiwamust/org",
  "velocity": {
    "V1_throughput_weekly": 0,
    "V2_cycle_time_days": 12,
    "V3_gate_pass_rate": 50,
    "V4_rework_rate": 30,
    "V5_lead_time_days": 12
  },
  "quality": {
    "V6_first_pass_yield": 50,
    "V7_defect_density": 0.25,
    "V8_scope_creep_ratio": 0,
    "V9_red_status_count": 1,
    "V10_escalation_count": 0
  },
  "entropy": {
    "V11_wip_count": 9,
    "V12_dept_utilization": {"rnd":4},
    "V12_dept_total": 9,
    "V13_blocked_count": 2,
    "V14_stale_count": 1,
    "V15_cross_dept_count": 1
  }
}
JSON

set +e
bad_output="$("$ROOT/ops/qcd-operating-review.sh" --from-file "$TMPDIR/bad.json" 2>&1)"
bad_status=$?
set -e

if [[ "$bad_status" -eq 0 ]]; then
  echo "Expected bad QCD metrics to fail" >&2
  echo "$bad_output" >&2
  exit 1
fi

assert_contains "$bad_output" "Result: fail"
assert_contains "$bad_output" "freeze_intake"
assert_contains "$bad_output" "move_gate_earlier"
assert_contains "$bad_output" "split_or_stop"
assert_contains "$bad_output" "escalate_blocker"

echo "qcd operating review tests passed"
