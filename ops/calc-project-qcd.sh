#!/usr/bin/env bash
# ops/calc-project-qcd.sh — プロジェクト単位の QCD 算出
# D (Delivery), C (Cost), ε (Entropy), Π (Productivity) を計算する

set -euo pipefail

REPO="kiwamust/org"
DATE=$(date +%Y-%m-%d)
QCD_DIR="$HOME/Desktop/work/work/org/data/qcd"
QCD_CSV="$QCD_DIR/project-qcd.csv"

# --- Usage ---
usage() {
  cat <<'USAGE'
Usage: ops/calc-project-qcd.sh --project <number> [OPTIONS]

プロジェクト Issue 番号を指定して QCD 値を算出する。

Options:
  --project <number>  プロジェクト Issue 番号（必須）
  --help              このヘルプを表示

Calculates:
  D (Delivery)     : schedule variance = completed / total tasks
  C (Cost)         : resource utilization = active tasks / total tasks
  ε (Entropy)      : disorder = (rework + blocked + red) / total tasks
  Π (Productivity) : throughput / WIP = done tasks / executing tasks

Output:
  - QCD summary to stdout
  - Appends to ~/Desktop/work/work/org/data/qcd/project-qcd.csv
USAGE
  exit 0
}

# --- Parse args ---
PROJECT_NUM=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      PROJECT_NUM="${2:-}"
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

if [ -z "$PROJECT_NUM" ]; then
  echo "Error: --project <number> is required" >&2
  echo "" >&2
  usage
fi

# --- Get project info ---
PROJECT_JSON=$(gh issue view "$PROJECT_NUM" --repo "$REPO" --json number,title,state,labels,body,createdAt 2>/dev/null)
if [ -z "$PROJECT_JSON" ] || [ "$PROJECT_JSON" = "null" ]; then
  echo "Error: Issue #$PROJECT_NUM not found in $REPO" >&2
  exit 1
fi

PROJECT_TITLE=$(echo "$PROJECT_JSON" | jq -r '.title')
PROJECT_STATE=$(echo "$PROJECT_JSON" | jq -r '.state')

# Verify it's a project issue
IS_PROJECT=$(echo "$PROJECT_JSON" | jq -r '.labels[]?.name // empty' | grep -c "org:type/project" || true)
if [ "$IS_PROJECT" -eq 0 ]; then
  echo "Warning: Issue #$PROJECT_NUM does not have org:type/project label" >&2
fi

# --- Find child task issues ---
# Search for tasks that reference this project number in body
ALL_TASKS=$(gh issue list --repo "$REPO" --label "org:type/task" --state all --limit 500 \
  --json number,title,state,labels,body,createdAt,closedAt,updatedAt 2>/dev/null || echo "[]")

# Filter tasks whose body contains reference to this project number
CHILD_TASKS=$(echo "$ALL_TASKS" | jq --arg pn "#$PROJECT_NUM" \
  '[.[] | select(.body | test("#'"$PROJECT_NUM"'\\b"))]' 2>/dev/null || echo "[]")

# If no children found by body search, try broader match
CHILD_COUNT=$(echo "$CHILD_TASKS" | jq 'length')
if [ "$CHILD_COUNT" -eq 0 ]; then
  # Fallback: search issue comments via API
  CHILD_TASKS=$(echo "$ALL_TASKS" | jq --arg pn "$PROJECT_NUM" \
    '[.[] | select(.body | contains("#" + $pn))]' 2>/dev/null || echo "[]")
  CHILD_COUNT=$(echo "$CHILD_TASKS" | jq 'length')
fi

# --- Calculate QCD ---

# Task counts by state/phase
TOTAL_TASKS=$CHILD_COUNT
DONE_TASKS=$(echo "$CHILD_TASKS" | jq '[.[] | select(.state == "CLOSED")] | length')
OPEN_TASKS=$(echo "$CHILD_TASKS" | jq '[.[] | select(.state == "OPEN")] | length')

# Phase counts from labels
EXECUTE_TASKS=$(echo "$CHILD_TASKS" | jq '[.[] | select(.labels[].name == "org:phase/execute")] | length')
REVIEW_TASKS=$(echo "$CHILD_TASKS" | jq '[.[] | select(.labels[].name == "org:phase/review")] | length')
BLOCKED_TASKS=$(echo "$CHILD_TASKS" | jq '[.[] | select(.labels[].name == "org:phase/blocked")] | length')
PLANNING_TASKS=$(echo "$CHILD_TASKS" | jq '[.[] | select(.labels[].name == "org:phase/planning")] | length')

# Quality counts
GATE_FAIL_TASKS=$(echo "$CHILD_TASKS" | jq '[.[] | select(.labels[].name == "org:quality/gate-fail")] | length')
RED_TASKS=$(echo "$CHILD_TASKS" | jq '[.[] | select(.labels[].name == "org:status/red")] | length')

# Also count quality gates related to this project
GATE_ISSUES=$(gh issue list --repo "$REPO" --label "org:type/quality-gate" --state all --limit 100 \
  --json number,body,labels --jq "[.[] | select(.body | contains(\"#$PROJECT_NUM\"))]" 2>/dev/null || echo "[]")
GATE_PASS_COUNT=$(echo "$GATE_ISSUES" | jq '[.[] | select(.labels[].name == "org:quality/gate-pass")] | length')
GATE_FAIL_COUNT=$(echo "$GATE_ISSUES" | jq '[.[] | select(.labels[].name == "org:quality/gate-fail")] | length')

# --- D (Delivery): completion ratio ---
if [ "$TOTAL_TASKS" -gt 0 ]; then
  D=$(echo "$DONE_TASKS $TOTAL_TASKS" | awk '{printf "%.2f", $1/$2}')
else
  D="N/A"
fi

# --- C (Cost): resource utilization = actively worked / total ---
ACTIVE_TASKS=$((EXECUTE_TASKS + REVIEW_TASKS))
if [ "$TOTAL_TASKS" -gt 0 ]; then
  C=$(echo "$ACTIVE_TASKS $TOTAL_TASKS" | awk '{printf "%.2f", $1/$2}')
else
  C="N/A"
fi

# --- ε (Entropy): disorder measure ---
DISORDER=$((GATE_FAIL_TASKS + BLOCKED_TASKS + RED_TASKS))
if [ "$TOTAL_TASKS" -gt 0 ]; then
  EPSILON=$(echo "$DISORDER $TOTAL_TASKS" | awk '{printf "%.2f", $1/$2}')
else
  EPSILON="0.00"
fi

# --- Π (Productivity): throughput / WIP ---
WIP=$((EXECUTE_TASKS > 0 ? EXECUTE_TASKS : 1))
if [ "$EXECUTE_TASKS" -gt 0 ]; then
  PI=$(echo "$DONE_TASKS $WIP" | awk '{printf "%.2f", $1/$2}')
else
  if [ "$DONE_TASKS" -gt 0 ]; then
    PI="$DONE_TASKS.00"
  else
    PI="0.00"
  fi
fi

# --- Output ---
echo "============================================"
echo "  QCD Analysis: #$PROJECT_NUM $PROJECT_TITLE"
echo "  Date: $DATE  State: $PROJECT_STATE"
echo "============================================"
echo ""
echo "## Task Breakdown"
printf "  Total tasks    : %s\n" "$TOTAL_TASKS"
printf "  Done           : %s\n" "$DONE_TASKS"
printf "  Execute        : %s\n" "$EXECUTE_TASKS"
printf "  Review         : %s\n" "$REVIEW_TASKS"
printf "  Planning       : %s\n" "$PLANNING_TASKS"
printf "  Blocked        : %s\n" "$BLOCKED_TASKS"
echo ""
echo "## Quality Gates"
printf "  Pass           : %s\n" "$GATE_PASS_COUNT"
printf "  Fail           : %s\n" "$GATE_FAIL_COUNT"
printf "  Gate-fail tasks: %s\n" "$GATE_FAIL_TASKS"
printf "  Red status     : %s\n" "$RED_TASKS"
echo ""
echo "## QCD Values"
printf "  D (Delivery)    = %s  (completed/total)\n" "$D"
printf "  C (Cost)        = %s  (active/total)\n" "$C"
printf "  ε (Entropy)     = %s  (disorder/total)\n" "$EPSILON"
printf "  Π (Productivity)= %s  (done/WIP)\n" "$PI"
echo ""
echo "============================================"

# --- Append to CSV ---
mkdir -p "$QCD_DIR"

# Create CSV header if file doesn't exist
if [ ! -f "$QCD_CSV" ]; then
  echo "date,project_num,project_title,total_tasks,done,execute,review,planning,blocked,gate_pass,gate_fail,D,C,epsilon,pi" > "$QCD_CSV"
fi

# Sanitize title for CSV (replace commas)
CSV_TITLE=$(echo "$PROJECT_TITLE" | tr ',' ';')
echo "$DATE,$PROJECT_NUM,$CSV_TITLE,$TOTAL_TASKS,$DONE_TASKS,$EXECUTE_TASKS,$REVIEW_TASKS,$PLANNING_TASKS,$BLOCKED_TASKS,$GATE_PASS_COUNT,$GATE_FAIL_COUNT,$D,$C,$EPSILON,$PI" >> "$QCD_CSV"

echo "Appended to: $QCD_CSV"
