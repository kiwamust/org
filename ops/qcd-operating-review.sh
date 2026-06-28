#!/usr/bin/env bash
# ops/qcd-operating-review.sh — turn QCD metrics into operating decisions.

set -euo pipefail

METRICS_FILE=""
SOFT=0
METRICS_DIR="${ORG_METRICS_DIR:-$HOME/Desktop/work/work/org/data/metrics}"

MIN_GATE_PASS="${ORG_QCD_MIN_GATE_PASS:-80}"
MIN_FIRST_PASS="${ORG_QCD_MIN_FIRST_PASS:-80}"
MAX_REWORK="${ORG_QCD_MAX_REWORK:-20}"
MAX_DEFECT_DENSITY="${ORG_QCD_MAX_DEFECT_DENSITY:-0.10}"
MAX_CYCLE_DAYS="${ORG_QCD_MAX_CYCLE_DAYS:-7}"
MAX_WIP="${ORG_WIP_TASK_LIMIT:-7}"
MAX_BLOCKED="${ORG_QCD_MAX_BLOCKED:-0}"
MAX_STALE="${ORG_QCD_MAX_STALE:-0}"

usage() {
  cat <<'USAGE'
Usage: bash ops/qcd-operating-review.sh [--from-file metrics.json] [--soft]

Reads QCD metrics JSON produced by ops/collect-qcd-metrics.sh and emits
operating decisions:

- continue
- freeze_intake
- move_gate_earlier
- split_or_stop
- escalate_blocker
- review_to_rule

By default it reads the newest JSON from ~/Desktop/work/work/org/data/metrics.
Use --soft to report failures without exiting non-zero.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --from-file)
      METRICS_FILE="$2"
      shift 2
      ;;
    --soft)
      SOFT=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$METRICS_FILE" ]]; then
  METRICS_FILE="$(ls -t "$METRICS_DIR"/*.json 2>/dev/null | head -1 || true)"
fi

if [[ -z "$METRICS_FILE" || ! -f "$METRICS_FILE" ]]; then
  echo "Error: metrics JSON not found. Run ops/collect-qcd-metrics.sh first or pass --from-file." >&2
  exit 1
fi

jq empty "$METRICS_FILE" >/dev/null

num_or_null() {
  local query="$1"
  jq -r "$query // \"null\"" "$METRICS_FILE"
}

is_nullish() {
  local value="$1"
  [[ -z "$value" || "$value" == "null" || "$value" == "N/A" ]]
}

lt_num() {
  awk -v a="$1" -v b="$2" 'BEGIN { exit !(a < b) }'
}

gt_num() {
  awk -v a="$1" -v b="$2" 'BEGIN { exit !(a > b) }'
}

ISSUES=0
REPORT=""

add_row() {
  local axis="$1"
  local signal="$2"
  local value="$3"
  local threshold="$4"
  local decision="$5"
  local action="$6"
  REPORT+="$(printf "| %s | %s | %s | %s | %s | %s |" "$axis" "$signal" "$value" "$threshold" "$decision" "$action")"$'\n'
  if [[ "$decision" != "continue" && "$decision" != "observe" ]]; then
    ISSUES=$((ISSUES + 1))
  fi
}

date_value="$(num_or_null '.date')"
repo_value="$(num_or_null '.repo')"

gate_pass="$(num_or_null '.velocity.V3_gate_pass_rate')"
rework="$(num_or_null '.velocity.V4_rework_rate')"
cycle_days="$(num_or_null '.velocity.V2_cycle_time_days')"
throughput="$(num_or_null '.velocity.V1_throughput_weekly')"
first_pass="$(num_or_null '.quality.V6_first_pass_yield')"
defect_density="$(num_or_null '.quality.V7_defect_density')"
wip="$(num_or_null '.entropy.V11_wip_count')"
blocked="$(num_or_null '.entropy.V13_blocked_count')"
stale="$(num_or_null '.entropy.V14_stale_count')"

if is_nullish "$gate_pass"; then
  add_row "Quality" "gate_pass_rate" "N/A" ">=${MIN_GATE_PASS}%" "observe" "Need at least one pass/fail gate result"
elif lt_num "$gate_pass" "$MIN_GATE_PASS"; then
  add_row "Quality" "gate_pass_rate" "${gate_pass}%" ">=${MIN_GATE_PASS}%" "move_gate_earlier" "Move IQG/PQG earlier and inspect failing gate pattern"
else
  add_row "Quality" "gate_pass_rate" "${gate_pass}%" ">=${MIN_GATE_PASS}%" "continue" "Keep gate placement"
fi

if is_nullish "$first_pass"; then
  add_row "Quality" "first_pass_yield" "N/A" ">=${MIN_FIRST_PASS}%" "observe" "Need completed gate history"
elif lt_num "$first_pass" "$MIN_FIRST_PASS"; then
  add_row "Quality" "first_pass_yield" "${first_pass}%" ">=${MIN_FIRST_PASS}%" "review_to_rule" "Encode rework cause into defect code and prevention rule"
else
  add_row "Quality" "first_pass_yield" "${first_pass}%" ">=${MIN_FIRST_PASS}%" "continue" "No extra quality action"
fi

if ! is_nullish "$rework" && gt_num "$rework" "$MAX_REWORK"; then
  add_row "Quality" "rework_rate" "${rework}%" "<=${MAX_REWORK}%" "move_gate_earlier" "Tighten input gate and split broad tasks"
else
  add_row "Quality" "rework_rate" "${rework}%" "<=${MAX_REWORK}%" "continue" "No rework intervention"
fi

if ! is_nullish "$defect_density" && gt_num "$defect_density" "$MAX_DEFECT_DENSITY"; then
  add_row "Quality" "defect_density" "$defect_density" "<=${MAX_DEFECT_DENSITY}" "review_to_rule" "Turn gate-fail pattern into template or hook"
else
  add_row "Quality" "defect_density" "$defect_density" "<=${MAX_DEFECT_DENSITY}" "continue" "No defect-density intervention"
fi

if ! is_nullish "$wip" && gt_num "$wip" "$MAX_WIP"; then
  add_row "Cost" "wip_count" "$wip" "<=${MAX_WIP}" "freeze_intake" "Stop new task intake; close, merge, or defer existing WIP"
else
  add_row "Cost" "wip_count" "$wip" "<=${MAX_WIP}" "continue" "WIP within limit"
fi

if ! is_nullish "$blocked" && gt_num "$blocked" "$MAX_BLOCKED"; then
  add_row "Cost" "blocked_count" "$blocked" "<=${MAX_BLOCKED}" "escalate_blocker" "Route blocker to Data-Evidence, Work, Life, Org, or user"
else
  add_row "Cost" "blocked_count" "$blocked" "<=${MAX_BLOCKED}" "continue" "No blocked work intervention"
fi

if ! is_nullish "$stale" && gt_num "$stale" "$MAX_STALE"; then
  add_row "Delivery" "stale_count" "$stale" "<=${MAX_STALE}" "split_or_stop" "Add checkpoint comment within 24h or split/stop issue"
else
  add_row "Delivery" "stale_count" "$stale" "<=${MAX_STALE}" "continue" "No stale-work intervention"
fi

if ! is_nullish "$cycle_days" && gt_num "$cycle_days" "$MAX_CYCLE_DAYS"; then
  add_row "Delivery" "cycle_time_days" "$cycle_days" "<=${MAX_CYCLE_DAYS}" "split_or_stop" "Reduce batch size or cut scope"
else
  add_row "Delivery" "cycle_time_days" "$cycle_days" "<=${MAX_CYCLE_DAYS}" "continue" "Cycle time within target"
fi

if ! is_nullish "$throughput" && ! is_nullish "$wip" && gt_num "$wip" "0" && lt_num "$throughput" "1"; then
  add_row "Delivery" "throughput_with_wip" "$throughput/week with WIP=$wip" ">=1/week when WIP>0" "split_or_stop" "Convert parked work into next checkpoint or stop"
else
  add_row "Delivery" "throughput_with_wip" "$throughput/week with WIP=$wip" ">=1/week when WIP>0" "continue" "Throughput is not stalled"
fi

echo "# QCD operating review"
echo ""
echo "Source: $METRICS_FILE"
echo "Date: $date_value"
echo "Repo: $repo_value"
echo ""
echo "| Axis | Signal | Value | Threshold | Decision | Action |"
echo "| --- | --- | ---: | ---: | --- | --- |"
printf '%s' "$REPORT"
echo ""

if [[ "$ISSUES" -eq 0 ]]; then
  echo "Result: pass"
  echo "Next operation: continue"
else
  echo "Result: fail"
  echo "Next operation: handle ${ISSUES} QCD intervention(s) before expanding intake"
fi

if [[ "$ISSUES" -ne 0 && "$SOFT" -eq 0 ]]; then
  exit 1
fi
