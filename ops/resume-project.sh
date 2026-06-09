#!/usr/bin/env bash
# ops/resume-project.sh — プロジェクト状態復元
# PJ Issue からプロジェクトコンテキストを再構築する

set -euo pipefail

REPO="kiwamust/org"

# --- Usage ---
usage() {
  cat <<'USAGE'
Usage: ops/resume-project.sh <project-number>

プロジェクト Issue 番号を指定し、コンテキスト復元用の構造化 Markdown を出力する。

Arguments:
  <project-number>  プロジェクト Issue 番号

Options:
  --help             このヘルプを表示

Output (stdout):
  - Project charter (Issue body)
  - Child task Issues (status/phase/labels)
  - Quality gate results
  - Recent activity (last 5 comments across related issues)
USAGE
  exit 0
}

# --- Parse args ---
if [ $# -eq 0 ]; then
  echo "Error: project number is required" >&2
  echo "" >&2
  usage
fi

case "$1" in
  --help|-h)
    usage
    ;;
esac

PROJECT_NUM="$1"

# --- Get project issue ---
PROJECT_JSON=$(gh issue view "$PROJECT_NUM" --repo "$REPO" \
  --json number,title,state,labels,body,createdAt,updatedAt 2>/dev/null)

if [ -z "$PROJECT_JSON" ] || [ "$PROJECT_JSON" = "null" ]; then
  echo "Error: Issue #$PROJECT_NUM not found in $REPO" >&2
  exit 1
fi

PROJECT_TITLE=$(echo "$PROJECT_JSON" | jq -r '.title')
PROJECT_STATE=$(echo "$PROJECT_JSON" | jq -r '.state')
PROJECT_BODY=$(echo "$PROJECT_JSON" | jq -r '.body')
PROJECT_CREATED=$(echo "$PROJECT_JSON" | jq -r '.createdAt' | cut -dT -f1)
PROJECT_UPDATED=$(echo "$PROJECT_JSON" | jq -r '.updatedAt' | cut -dT -f1)
PROJECT_LABELS=$(echo "$PROJECT_JSON" | jq -r '[.labels[].name] | join(", ")')

# --- Extract key fields from body ---
# GBT, Department, Quality Level are typically in the project body
GBT=$(echo "$PROJECT_LABELS" | grep -oE 'org:gbt/[a-z]+' | head -1 | sed 's/org:gbt\///' || echo "N/A")
DEPT=$(echo "$PROJECT_LABELS" | grep -oE 'org:dept/[a-z]+' | head -1 | sed 's/org:dept\///' || echo "N/A")
PHASE=$(echo "$PROJECT_LABELS" | grep -oE 'org:phase/[a-z]+' | head -1 | sed 's/org:phase\///' || echo "N/A")
STATUS=$(echo "$PROJECT_LABELS" | grep -oE 'org:status/[a-z]+' | head -1 | sed 's/org:status\///' || echo "N/A")

# --- Find child tasks ---
ALL_TASKS=$(gh issue list --repo "$REPO" --label "org:type/task" --state all --limit 500 \
  --json number,title,state,labels,createdAt,closedAt,updatedAt,body 2>/dev/null || echo "[]")

CHILD_TASKS=$(echo "$ALL_TASKS" | jq --arg pn "$PROJECT_NUM" \
  '[.[] | select(.body | contains("#" + $pn))]' 2>/dev/null || echo "[]")

CHILD_COUNT=$(echo "$CHILD_TASKS" | jq 'length')

# --- Find quality gate issues ---
QG_ISSUES=$(gh issue list --repo "$REPO" --label "org:type/quality-gate" --state all --limit 100 \
  --json number,title,state,labels,body,createdAt 2>/dev/null || echo "[]")

# Filter QG issues that reference this project or its child tasks
CHILD_NUMBERS=$(echo "$CHILD_TASKS" | jq -r '.[].number' 2>/dev/null || echo "")
RELATED_QG=$(echo "$QG_ISSUES" | jq --arg pn "$PROJECT_NUM" \
  '[.[] | select(.body | contains("#" + $pn))]' 2>/dev/null || echo "[]")

# Also find QGs referencing child task numbers
for cn in $CHILD_NUMBERS; do
  MORE_QG=$(echo "$QG_ISSUES" | jq --arg cn "$cn" \
    '[.[] | select(.body | contains("#" + $cn))]' 2>/dev/null || echo "[]")
  RELATED_QG=$(echo "$RELATED_QG" "$MORE_QG" | jq -s 'add | unique_by(.number)' 2>/dev/null || echo "[]")
done

# --- Collect recent comments ---
# Get comments from the project issue and child tasks
COMMENT_COLLECTION="[]"

# Project comments
PJ_COMMENTS=$(gh api "repos/$REPO/issues/$PROJECT_NUM/comments" --jq \
  '[.[] | {issue: '"$PROJECT_NUM"', body: .body, created_at: .created_at, user: .user.login}] | sort_by(.created_at) | reverse | .[0:5]' 2>/dev/null || echo "[]")
COMMENT_COLLECTION=$(echo "$COMMENT_COLLECTION" "$PJ_COMMENTS" | jq -s 'add' 2>/dev/null || echo "[]")

# Child task comments (last 2 per task to avoid flooding)
for cn in $CHILD_NUMBERS; do
  TASK_COMMENTS=$(gh api "repos/$REPO/issues/$cn/comments" --jq \
    '[.[] | {issue: '"$cn"', body: .body, created_at: .created_at, user: .user.login}] | sort_by(.created_at) | reverse | .[0:2]' 2>/dev/null || echo "[]")
  COMMENT_COLLECTION=$(echo "$COMMENT_COLLECTION" "$TASK_COMMENTS" | jq -s 'add' 2>/dev/null || echo "[]")
done

# Sort all comments by date, take last 5
RECENT_COMMENTS=$(echo "$COMMENT_COLLECTION" | jq 'sort_by(.created_at) | reverse | .[0:5]' 2>/dev/null || echo "[]")

# ============================================================
# Output structured markdown
# ============================================================

cat <<HEADER
# Project Resume: #$PROJECT_NUM $PROJECT_TITLE

| Field     | Value                |
| --------- | -------------------- |
| State     | $PROJECT_STATE       |
| Phase     | $PHASE               |
| Status    | $STATUS              |
| GBT       | $GBT                 |
| Dept      | $DEPT                |
| Created   | $PROJECT_CREATED     |
| Updated   | $PROJECT_UPDATED     |
| Labels    | $PROJECT_LABELS      |

---

## Charter

$PROJECT_BODY

---

## Child Tasks ($CHILD_COUNT)

HEADER

if [ "$CHILD_COUNT" -gt 0 ]; then
  echo "| # | Title | State | Phase | Status | Updated |"
  echo "| --: | ----- | ----- | ----- | ------ | ------- |"
  echo "$CHILD_TASKS" | jq -r '.[] |
    "| #\(.number) | \(.title) | \(.state) | \(.labels | map(select(.name | startswith("org:phase/"))) | map(.name | sub("org:phase/";"")) | join(",") // "—") | \(.labels | map(select(.name | startswith("org:status/"))) | map(.name | sub("org:status/";"")) | join(",") // "—") | \(.updatedAt | split("T")[0]) |"'
else
  echo "(No child tasks found)"
fi

echo ""
echo "---"
echo ""

# --- Quality Gates ---
QG_COUNT=$(echo "$RELATED_QG" | jq 'length')
echo "## Quality Gates ($QG_COUNT)"
echo ""

if [ "$QG_COUNT" -gt 0 ]; then
  echo "| # | Title | Result | Target |"
  echo "| --: | ----- | ------ | ------ |"
  echo "$RELATED_QG" | jq -r '.[] |
    "| #\(.number) | \(.title) | \(.labels | map(select(.name | startswith("org:quality/"))) | map(.name | sub("org:quality/";"")) | join(",") // "—") | (if .body then (.body | split("\n") | map(select(startswith("#"))) | first // "—") else "—" end) |"'
else
  echo "(No quality gate records)"
fi

echo ""
echo "---"
echo ""

# --- Recent Activity ---
COMMENT_COUNT=$(echo "$RECENT_COMMENTS" | jq 'length')
echo "## Recent Activity (last $COMMENT_COUNT comments)"
echo ""

if [ "$COMMENT_COUNT" -gt 0 ]; then
  echo "$RECENT_COMMENTS" | jq -r '.[] |
    "### Issue #\(.issue) — \(.created_at | split("T")[0])\n\n\(.body | split("\n")[0:5] | join("\n"))\n"'
else
  echo "(No recent comments)"
fi

echo ""
echo "---"
echo ""
echo "*Generated: $(date +%Y-%m-%d\ %H:%M) by ops/resume-project.sh*"
