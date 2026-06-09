#!/usr/bin/env bash
# ops/collect-qcd-metrics.sh — V1-V15 メトリクス自動収集
# QCD 熱力学定式化の観測変数を GitHub Issues から抽出する

set -euo pipefail

REPO="kiwamust/org"
DATE=$(date +%Y-%m-%d)
OUTPUT_DIR="$HOME/Desktop/work/work/org/data/metrics"
OUTPUT_FORMAT="table"

# --- Usage ---
usage() {
  cat <<'USAGE'
Usage: ops/collect-qcd-metrics.sh [OPTIONS]

QCD 熱力学定式化の V1-V15 メトリクスを GitHub Issues から収集する。

Options:
  --output json    JSON 形式で出力
  --output table   人間可読テーブルで出力（デフォルト）
  --help           このヘルプを表示

Metrics:
  Velocity (V1-V5):  throughput, cycle time, gate pass rate, rework rate, lead time
  Quality (V6-V10):  first-pass yield, defect density, scope creep, red status, escalations
  Entropy (V11-V15): WIP count, dept utilization, blocked, stale, cross-dept

Output: ~/Desktop/work/work/org/data/metrics/YYYY-MM-DD.json
USAGE
  exit 0
}

# --- Parse args ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --output)
      OUTPUT_FORMAT="${2:-table}"
      shift 2
      ;;
    --help|-h)
      usage
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      ;;
  esac
done

# --- Helper: count issues matching labels ---
count_issues() {
  local labels="$1"
  local state="${2:-all}"
  gh issue list --repo "$REPO" --label "$labels" --state "$state" --json number --jq 'length' 2>/dev/null || echo "0"
}

# --- Helper: get issues as JSON array ---
get_issues() {
  local labels="$1"
  local state="${2:-all}"
  gh issue list --repo "$REPO" --label "$labels" --state "$state" --limit 500 \
    --json number,title,state,labels,createdAt,closedAt,updatedAt 2>/dev/null || echo "[]"
}

# ============================================================
# V1: Task throughput (tasks closed in last 7 days)
# ============================================================
SEVEN_DAYS_AGO=$(date -v-7d +%Y-%m-%d 2>/dev/null || date -d '7 days ago' +%Y-%m-%d 2>/dev/null || echo "")
V1=$(gh issue list --repo "$REPO" --label "org:type/task" --state closed --json closedAt \
  --jq "[.[] | select(.closedAt >= \"${SEVEN_DAYS_AGO}T00:00:00Z\")] | length" 2>/dev/null || echo "0")

# ============================================================
# V2: Cycle time (avg days from execute to done for closed tasks)
# Approximation: days between createdAt and closedAt for done tasks
# ============================================================
CYCLE_TIMES=$(gh issue list --repo "$REPO" --label "org:type/task" --state closed --json createdAt,closedAt \
  --jq '[.[] | select(.closedAt != null) |
    (((.closedAt | fromdateiso8601) - (.createdAt | fromdateiso8601)) / 86400)] |
    if length > 0 then (add / length | . * 10 | round / 10) else 0 end' 2>/dev/null || echo "0")
V2="${CYCLE_TIMES}"

# ============================================================
# V3: Gate pass rate
# ============================================================
GATE_PASS=$(count_issues "org:quality/gate-pass")
GATE_FAIL=$(count_issues "org:quality/gate-fail")
GATE_TOTAL=$((GATE_PASS + GATE_FAIL))
if [ "$GATE_TOTAL" -gt 0 ]; then
  # bash integer math: multiply by 1000 for one decimal place
  V3=$(echo "$GATE_PASS $GATE_TOTAL" | awk '{printf "%.1f", ($1/$2)*100}')
else
  V3="N/A"
fi

# ============================================================
# V4: Rework rate (tasks with both execute and review labels historically)
# Approximation: tasks currently in execute that previously had review label
# With small dataset, check for tasks with gate-fail
# ============================================================
REWORK_TASKS=$(gh issue list --repo "$REPO" --label "org:type/task,org:quality/gate-fail" --state all --json number --jq 'length' 2>/dev/null || echo "0")
TOTAL_TASKS=$(count_issues "org:type/task")
if [ "$TOTAL_TASKS" -gt 0 ] && [ "$TOTAL_TASKS" != "0" ]; then
  V4=$(echo "$REWORK_TASKS $TOTAL_TASKS" | awk '{printf "%.1f", ($1/$2)*100}')
else
  V4="0"
fi

# ============================================================
# V5: Lead time (avg days from creation to close, all issue types)
# ============================================================
LEAD_TIMES=$(gh issue list --repo "$REPO" --state closed --json createdAt,closedAt \
  --jq '[.[] | select(.closedAt != null) |
    (((.closedAt | fromdateiso8601) - (.createdAt | fromdateiso8601)) / 86400)] |
    if length > 0 then (add / length | . * 10 | round / 10) else 0 end' 2>/dev/null || echo "0")
V5="${LEAD_TIMES}"

# ============================================================
# V6: First-pass yield (tasks passing gate on first attempt)
# gate-pass without any prior gate-fail
# Approximation: gate-pass that are NOT also gate-fail
# ============================================================
PASS_ONLY=$(gh issue list --repo "$REPO" --label "org:quality/gate-pass" --state all --json number \
  --jq '[.[].number]' 2>/dev/null || echo "[]")
FAIL_NUMBERS=$(gh issue list --repo "$REPO" --label "org:quality/gate-fail" --state all --json number \
  --jq '[.[].number]' 2>/dev/null || echo "[]")
# Count pass numbers not in fail numbers
FIRST_PASS_COUNT=$(echo "$PASS_ONLY" "$FAIL_NUMBERS" | jq -s '.[0] - .[1] | length' 2>/dev/null || echo "0")
if [ "$GATE_PASS" -gt 0 ]; then
  V6=$(echo "$FIRST_PASS_COUNT $GATE_PASS" | awk '{printf "%.1f", ($1/$2)*100}')
else
  V6="N/A"
fi

# ============================================================
# V7: Defect density (gate-fail count per total tasks)
# ============================================================
if [ "$TOTAL_TASKS" -gt 0 ] && [ "$TOTAL_TASKS" != "0" ]; then
  V7=$(echo "$GATE_FAIL $TOTAL_TASKS" | awk '{printf "%.2f", $1/$2}')
else
  V7="0"
fi

# ============================================================
# V8: Scope creep ratio (placeholder — not directly observable from labels)
# ============================================================
V8="0"

# ============================================================
# V9: Status changes to red
# ============================================================
V9=$(count_issues "org:status/red" "open")

# ============================================================
# V10: Escalation count (placeholder — would need event tracking)
# ============================================================
V10="0"

# ============================================================
# V11: WIP count (open issues in execute phase)
# ============================================================
V11=$(count_issues "org:phase/execute" "open")

# ============================================================
# V12: Department utilization (issues per department)
# ============================================================
DEPT_rnd=$(count_issues "org:dept/rnd" "open")
DEPT_brand=$(count_issues "org:dept/brand" "open")
DEPT_emergingtech=$(count_issues "org:dept/emergingtech" "open")
DEPT_engineering=$(count_issues "org:dept/engineering" "open")
DEPT_operations=$(count_issues "org:dept/operations" "open")
DEPT_cross=$(count_issues "org:dept/cross" "open")
V12=$((DEPT_rnd + DEPT_brand + DEPT_emergingtech + DEPT_engineering + DEPT_operations + DEPT_cross))

# ============================================================
# V13: Blocked issues count
# ============================================================
V13=$(count_issues "org:phase/blocked" "open")

# ============================================================
# V14: Stale issues (>7 days no update in execute phase)
# ============================================================
if [ -n "$SEVEN_DAYS_AGO" ]; then
  V14=$(gh issue list --repo "$REPO" --label "org:phase/execute" --state open --json number,updatedAt \
    --jq "[.[] | select(.updatedAt < \"${SEVEN_DAYS_AGO}T00:00:00Z\")] | length" 2>/dev/null || echo "0")
else
  V14="0"
fi

# ============================================================
# V15: Cross-department issues count
# ============================================================
V15=$(count_issues "org:dept/cross" "open")

# ============================================================
# Output
# ============================================================

# Build department utilization JSON fragment
DEPT_JSON="\"rnd\":${DEPT_rnd},\"brand\":${DEPT_brand},\"emergingtech\":${DEPT_emergingtech},\"engineering\":${DEPT_engineering},\"operations\":${DEPT_operations},\"cross\":${DEPT_cross}"

if [ "$OUTPUT_FORMAT" = "json" ]; then
  JSON_OUT=$(cat <<JSON
{
  "date": "$DATE",
  "repo": "$REPO",
  "velocity": {
    "V1_throughput_weekly": $V1,
    "V2_cycle_time_days": $V2,
    "V3_gate_pass_rate": $([ "$V3" = "N/A" ] && echo "null" || echo "$V3"),
    "V4_rework_rate": $V4,
    "V5_lead_time_days": $V5
  },
  "quality": {
    "V6_first_pass_yield": $([ "$V6" = "N/A" ] && echo "null" || echo "$V6"),
    "V7_defect_density": $V7,
    "V8_scope_creep_ratio": $V8,
    "V9_red_status_count": $V9,
    "V10_escalation_count": $V10
  },
  "entropy": {
    "V11_wip_count": $V11,
    "V12_dept_utilization": {$DEPT_JSON},
    "V12_dept_total": $V12,
    "V13_blocked_count": $V13,
    "V14_stale_count": $V14,
    "V15_cross_dept_count": $V15
  }
}
JSON
)
  echo "$JSON_OUT" | jq '.'

  # Save to file
  mkdir -p "$OUTPUT_DIR"
  echo "$JSON_OUT" | jq '.' > "$OUTPUT_DIR/$DATE.json"
  echo "" >&2
  echo "Saved: $OUTPUT_DIR/$DATE.json" >&2

else
  echo "============================================"
  echo "  QCD Metrics Collection ($DATE)"
  echo "  repo: $REPO"
  echo "============================================"
  echo ""
  echo "## Velocity"
  printf "  V1  Task throughput (weekly)   : %s\n" "$V1"
  printf "  V2  Cycle time (days)          : %s\n" "$V2"
  printf "  V3  Gate pass rate (%%)         : %s\n" "$V3"
  printf "  V4  Rework rate (%%)            : %s\n" "$V4"
  printf "  V5  Lead time (days)           : %s\n" "$V5"
  echo ""
  echo "## Quality"
  printf "  V6  First-pass yield (%%)       : %s\n" "$V6"
  printf "  V7  Defect density             : %s\n" "$V7"
  printf "  V8  Scope creep ratio          : %s\n" "$V8"
  printf "  V9  Red status count           : %s\n" "$V9"
  printf "  V10 Escalation count           : %s\n" "$V10"
  echo ""
  echo "## Entropy"
  printf "  V11 WIP count                  : %s\n" "$V11"
  echo "  V12 Dept utilization:"
  printf "       %-15s          : %s\n" "rnd" "$DEPT_rnd"
  printf "       %-15s          : %s\n" "brand" "$DEPT_brand"
  printf "       %-15s          : %s\n" "emergingtech" "$DEPT_emergingtech"
  printf "       %-15s          : %s\n" "engineering" "$DEPT_engineering"
  printf "       %-15s          : %s\n" "operations" "$DEPT_operations"
  printf "       %-15s          : %s\n" "cross" "$DEPT_cross"
  printf "  V13 Blocked count              : %s\n" "$V13"
  printf "  V14 Stale count (>7d)          : %s\n" "$V14"
  printf "  V15 Cross-dept count           : %s\n" "$V15"
  echo ""
  echo "============================================"

  # Also save JSON
  JSON_OUT=$(cat <<JSON
{
  "date": "$DATE",
  "repo": "$REPO",
  "velocity": {
    "V1_throughput_weekly": $V1,
    "V2_cycle_time_days": $V2,
    "V3_gate_pass_rate": $([ "$V3" = "N/A" ] && echo "null" || echo "$V3"),
    "V4_rework_rate": $V4,
    "V5_lead_time_days": $V5
  },
  "quality": {
    "V6_first_pass_yield": $([ "$V6" = "N/A" ] && echo "null" || echo "$V6"),
    "V7_defect_density": $V7,
    "V8_scope_creep_ratio": $V8,
    "V9_red_status_count": $V9,
    "V10_escalation_count": $V10
  },
  "entropy": {
    "V11_wip_count": $V11,
    "V12_dept_utilization": {$DEPT_JSON},
    "V12_dept_total": $V12,
    "V13_blocked_count": $V13,
    "V14_stale_count": $V14,
    "V15_cross_dept_count": $V15
  }
}
JSON
)
  mkdir -p "$OUTPUT_DIR"
  echo "$JSON_OUT" | jq '.' > "$OUTPUT_DIR/$DATE.json"
  echo "Saved: $OUTPUT_DIR/$DATE.json"
fi
