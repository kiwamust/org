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

echo "============================================"
echo "  Total open issues: $(gh issue list --repo "$REPO" --state open --json number --jq 'length' 2>/dev/null || echo "0")"
echo "============================================"
