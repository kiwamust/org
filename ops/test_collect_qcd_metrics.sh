#!/usr/bin/env bash
# Regression tests for ops/collect-qcd-metrics.sh execution schema.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "$TMPDIR/bin"

cat >"$TMPDIR/bin/gh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-} ${2:-}" != "issue list" ]]; then
  echo "unsupported fake gh invocation: $*" >&2
  exit 1
fi

if [[ "${GH_FORCE_FAIL:-0}" == "1" ]]; then
  exit 42
fi

state="all"
labels=""
jq_query=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --state)
      state="$2"
      shift 2
      ;;
    --label)
      labels="$2"
      shift 2
      ;;
    --jq)
      jq_query="$2"
      shift 2
      ;;
    --repo|--json|--limit)
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

data='[
  {
    "number": 1,
    "title": "PJ: sample",
    "state": "OPEN",
    "body": "qcd:\nquality_target:\ndelivery_target:\ncost_budget:\nstop_rules:",
    "labels": [{"name":"org:type/project"},{"name":"org:phase/execute"},{"name":"org:status/green"}],
    "createdAt": "2026-06-01T00:00:00Z",
    "updatedAt": "2026-06-28T00:00:00Z",
    "closedAt": null
  },
  {
    "number": 2,
    "title": "TASK: planning",
    "state": "OPEN",
    "body": "qcd:\nquality_target:\ndelivery_target:\ncost_budget:\nstop_rules:",
    "labels": [{"name":"org:type/task"},{"name":"org:phase/planning"},{"name":"org:status/yellow"},{"name":"org:dept/rnd"}],
    "createdAt": "2026-06-10T00:00:00Z",
    "updatedAt": "2026-06-28T00:00:00Z",
    "closedAt": null
  },
  {
    "number": 3,
    "title": "TASK: execute",
    "state": "OPEN",
    "body": "qcd:\nquality_target:\ndelivery_target:\ncost_budget:\nstop_rules:",
    "labels": [{"name":"org:type/task"},{"name":"org:phase/execute"},{"name":"org:status/green"},{"name":"org:dept/engineering"}],
    "createdAt": "2026-06-11T00:00:00Z",
    "updatedAt": "2026-06-28T00:00:00Z",
    "closedAt": null
  },
  {
    "number": 4,
    "title": "TASK: review",
    "state": "OPEN",
    "body": "qcd:\nquality_target:\ndelivery_target:\ncost_budget:\nstop_rules:",
    "labels": [{"name":"org:type/task"},{"name":"org:phase/review"},{"name":"org:status/green"},{"name":"org:dept/operations"}],
    "createdAt": "2026-06-12T00:00:00Z",
    "updatedAt": "2026-06-28T00:00:00Z",
    "closedAt": null
  },
  {
    "number": 5,
    "title": "TASK: blocked",
    "state": "OPEN",
    "body": "qcd:\nquality_target:\ndelivery_target:\ncost_budget:\nstop_rules:",
    "labels": [{"name":"org:type/task"},{"name":"org:phase/blocked"},{"name":"org:status/red"},{"name":"org:dept/brand"}],
    "createdAt": "2026-06-13T00:00:00Z",
    "updatedAt": "2026-06-28T00:00:00Z",
    "closedAt": null
  },
  {
    "number": 6,
    "title": "TASK: missing qcd",
    "state": "OPEN",
    "body": "parent_project: life",
    "labels": [{"name":"org:type/task"},{"name":"org:phase/planning"},{"name":"org:status/yellow"},{"name":"org:dept/rnd"}],
    "createdAt": "2026-06-14T00:00:00Z",
    "updatedAt": "2026-06-28T00:00:00Z",
    "closedAt": null
  },
  {
    "number": 7,
    "title": "QG: pending",
    "state": "OPEN",
    "body": "gate: pending",
    "labels": [{"name":"org:type/quality-gate"},{"name":"org:quality/gate-pending"},{"name":"org:phase/planning"}],
    "createdAt": "2026-06-15T00:00:00Z",
    "updatedAt": "2026-06-28T00:00:00Z",
    "closedAt": null
  },
  {
    "number": 8,
    "title": "QG: pass",
    "state": "CLOSED",
    "body": "gate: pass",
    "labels": [{"name":"org:type/quality-gate"},{"name":"org:quality/gate-pass"},{"name":"org:phase/done"}],
    "createdAt": "2026-06-01T00:00:00Z",
    "updatedAt": "2026-06-20T00:00:00Z",
    "closedAt": "2026-06-20T00:00:00Z"
  },
  {
    "number": 9,
    "title": "TASK: done",
    "state": "CLOSED",
    "body": "qcd:\nquality_target:\ndelivery_target:\ncost_budget:\nstop_rules:",
    "labels": [{"name":"org:type/task"},{"name":"org:phase/done"},{"name":"org:status/green"},{"name":"org:dept/rnd"}],
    "createdAt": "2026-06-20T00:00:00Z",
    "updatedAt": "2026-06-28T00:00:00Z",
    "closedAt": "2026-06-28T00:00:00Z"
  }
]'

filter='
  def names: [.labels[]?.name];
  def state_ok: $state == "all" or ((.state | ascii_downcase) == $state);
  def labels_ok:
    $labels == "" or (($labels | split(",")) - names | length == 0);
  [.[] | select(state_ok and labels_ok)]
'

if [[ -n "$jq_query" ]]; then
  printf '%s' "$data" | jq --arg state "$state" --arg labels "$labels" "$filter | $jq_query"
else
  printf '%s' "$data" | jq --arg state "$state" --arg labels "$labels" "$filter"
fi
SH

chmod +x "$TMPDIR/bin/gh"
export PATH="$TMPDIR/bin:$PATH"
export HOME="$TMPDIR/home"

"$ROOT/ops/collect-qcd-metrics.sh" --output json >/dev/null

metrics_file="$HOME/Work/work/org/data/metrics/$(date +%Y-%m-%d).json"

if ! jq -e '
  .source_state == "OBSERVED" and
  .gate == "PASS" and
  .execution.open_task_count == 5 and
  .execution.active_task_inventory == 4 and
  .execution.planning_inventory == 2 and
  .execution.execute_wip_count == 1 and
  .execution.review_wip_count == 1 and
  .execution.blocked_count == 1 and
  .execution.active_parent_projects == 1 and
  .execution.gate_pending_count == 1 and
  .execution.qcd_contract_missing_count == 1 and
  .entropy.V11_wip_count == 2
' "$metrics_file" >/dev/null; then
  echo "Unexpected metrics JSON:" >&2
  jq '.' "$metrics_file" >&2
  exit 1
fi

rm -f "$metrics_file"
set +e
failure_output="$(GH_FORCE_FAIL=1 "$ROOT/ops/collect-qcd-metrics.sh" --output json 2>/dev/null)"
failure_status=$?
set -e

if [[ "$failure_status" -ne 70 ]]; then
  echo "Expected source outage exit 70, got $failure_status" >&2
  exit 1
fi
if ! jq -e '
  .source_state == "UNKNOWN" and
  .gate == "BLOCK" and
  .metrics == null
' <<<"$failure_output" >/dev/null; then
  echo "Unexpected source outage contract: $failure_output" >&2
  exit 1
fi
if [[ -e "$metrics_file" ]]; then
  echo "Source outage must not write canonical metrics" >&2
  exit 1
fi

echo "collect qcd metrics tests passed"
