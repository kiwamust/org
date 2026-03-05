#!/usr/bin/env bash
# ops/dashboard.sh — org CLI ダッシュボード
# 全局の WIP/RAG を集約表示する

set -euo pipefail

REPO="kiwamust/org"
DATE=$(date +%Y-%m-%d)

echo "============================================"
echo "  org ダッシュボード ($DATE)"
echo "============================================"
echo ""

# --- Phase 別集計 ---
echo "## Phase 別 WIP"
echo ""
for phase in intake planning execute review done blocked; do
  count=$(gh issue list --repo "$REPO" --label "org:phase/$phase" --state open --json number --jq 'length' 2>/dev/null || echo "0")
  issues=$(gh issue list --repo "$REPO" --label "org:phase/$phase" --state open --json number --jq '[.[].number] | map("#" + tostring) | join(", ")' 2>/dev/null || echo "-")
  [ -z "$issues" ] && issues="-"
  printf "| %-10s | %3s | %s\n" "$phase" "$count" "$issues"
done
echo ""

# --- RAG ステータス ---
echo "## RAG ステータス"
echo ""
for status in green yellow red; do
  count=$(gh issue list --repo "$REPO" --label "org:status/$status" --state open --json number --jq 'length' 2>/dev/null || echo "0")
  issues=$(gh issue list --repo "$REPO" --label "org:status/$status" --state open --json number --jq '[.[].number] | map("#" + tostring) | join(", ")' 2>/dev/null || echo "-")
  [ -z "$issues" ] && issues="-"
  case $status in
    green)  indicator="🟢" ;;
    yellow) indicator="🟡" ;;
    red)    indicator="🔴" ;;
  esac
  printf "| %s %-8s | %3s | %s\n" "$indicator" "$status" "$count" "$issues"
done
echo ""

# --- 部門別 WIP ---
echo "## 部門別 WIP"
echo ""
for dept in rnd brand emergingtech engineering operations cross; do
  count=$(gh issue list --repo "$REPO" --label "org:dept/$dept" --state open --json number --jq 'length' 2>/dev/null || echo "0")
  printf "| %-15s | %3s\n" "$dept" "$count"
done
echo ""

# --- 品質ゲート状況 ---
echo "## 品質ゲート"
echo ""
for qg in gate-pending gate-pass gate-fail; do
  count=$(gh issue list --repo "$REPO" --label "org:quality/$qg" --state open --json number --jq 'length' 2>/dev/null || echo "0")
  printf "| %-15s | %3s\n" "$qg" "$count"
done
echo ""

# --- GBT 分類 ---
echo "## GBT 分類"
echo ""
for gbt in generation behavior target; do
  count=$(gh issue list --repo "$REPO" --label "org:gbt/$gbt" --state open --json number --jq 'length' 2>/dev/null || echo "0")
  printf "| %-12s | %3s\n" "$gbt" "$count"
done
echo ""

# --- 直近の Issue ---
echo "## 直近の Issue (最新10件)"
echo ""
gh issue list --repo "$REPO" --state open --limit 10 --json number,title,labels \
  --jq '.[] | "#\(.number) \(.title) [\(.labels | map(.name) | join(", "))]"' 2>/dev/null || echo "(なし)"
echo ""

# --- Stale Issues (7日以上 execute でコメントなし) ---
echo "## Stale Issues (>7d in execute)"
echo ""

# Get issues in execute phase
SEVEN_DAYS_AGO=$(date -v-7d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -d '7 days ago' +%Y-%m-%dT%H:%M:%SZ)

STALE_OUTPUT=$(gh issue list --repo "$REPO" --label "org:phase/execute" --state open \
  --json number,title,updatedAt \
  --jq ".[] | select(.updatedAt < \"$SEVEN_DAYS_AGO\") | \"  ⚠️  #\(.number) \(.title) (last update: \(.updatedAt | split(\"T\")[0]))\"" 2>/dev/null || true)

if [ -n "$STALE_OUTPUT" ]; then
  echo "$STALE_OUTPUT"
else
  echo "  (なし)"
fi
echo ""

# --- QCD サマリ (collect-qcd-metrics.sh 連携) ---
METRICS_DIR="$HOME/Desktop/work/work/org/data/metrics"
LATEST_METRICS=$(ls -t "$METRICS_DIR"/*.json 2>/dev/null | head -1)

if [ -n "$LATEST_METRICS" ]; then
  echo "## QCD サマリ ($(basename "$LATEST_METRICS" .json))"
  echo ""
  echo "  Velocity:"
  printf "    Task throughput:  %s/week\n" "$(jq -r '.velocity.V1_throughput_weekly // "N/A"' "$LATEST_METRICS")"
  printf "    Cycle time:       %s days\n" "$(jq -r '.velocity.V2_cycle_time_days // "N/A"' "$LATEST_METRICS")"
  printf "    Gate pass rate:   %s\n" "$(jq -r '.velocity.V3_gate_pass_rate // "N/A"' "$LATEST_METRICS")"
  echo ""
  echo "  Quality:"
  printf "    First-pass yield: %s\n" "$(jq -r '.quality.V6_first_pass_yield // "N/A"' "$LATEST_METRICS")"
  printf "    Defect density:   %s\n" "$(jq -r '.quality.V7_defect_density // "N/A"' "$LATEST_METRICS")"
  echo ""
  echo "  Entropy:"
  printf "    WIP count:        %s\n" "$(jq -r '.entropy.V11_wip_count // "N/A"' "$LATEST_METRICS")"
  printf "    Blocked:          %s\n" "$(jq -r '.entropy.V13_blocked_count // "N/A"' "$LATEST_METRICS")"
  printf "    Stale:            %s\n" "$(jq -r '.entropy.V14_stale_count // "N/A"' "$LATEST_METRICS")"
  echo ""
else
  echo "## QCD サマリ"
  echo ""
  echo "  (メトリクスデータなし。ops/collect-qcd-metrics.sh を実行してください)"
  echo ""
fi

echo "============================================"
echo "  Total open issues: $(gh issue list --repo "$REPO" --state open --json number --jq 'length' 2>/dev/null || echo "0")"
echo "============================================"
