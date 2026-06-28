#!/usr/bin/env bash
# ops/audit-org-contract.sh - audit Authority/ES/Issue/WIP contract fields.

set -euo pipefail

REPO="${ORG_REPO:-kiwamust/org}"
FROM_FILE=""
SOFT=0

PARENT_LIMIT="${ORG_WIP_PARENT_LIMIT:-3}"
TASK_LIMIT="${ORG_WIP_TASK_LIMIT:-7}"
EXTERNAL_LIMIT="${ORG_WIP_EXTERNAL_LIMIT:-2}"

usage() {
  cat <<'USAGE'
Usage: bash ops/audit-org-contract.sh [--repo owner/name] [--from-file issues.json] [--soft]

Audits open org Issues for the active Org operating contract:
- required execution fields: parent_project/work_ref, data_profile, role, phase, expected_return, gate, closeout_evidence, next_circulation
- WIP limits: active parent projects <=3, active tasks <=7, active ES-3/4 external-facing artifacts <=2

Input JSON for --from-file should be an array of GitHub issue-like objects:
[
  {"number":1,"title":"...","state":"OPEN","body":"...","labels":[{"name":"org:type/task"}]}
]
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      REPO="$2"
      shift 2
      ;;
    --from-file)
      FROM_FILE="$2"
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

read_issues() {
  if [[ -n "$FROM_FILE" ]]; then
    cat "$FROM_FILE"
    return
  fi

  gh issue list --repo "$REPO" --state open --limit 500 --json number,title,state,body,labels
}

labels_for_issue() {
  jq -r '[.labels[]? | if type == "string" then . else .name end] | join(",")'
}

contains_label() {
  local labels="$1"
  local label="$2"
  [[ ",$labels," == *",$label,"* ]]
}

field_present() {
  local body="$1"
  shift
  local body_lc token token_lc
  body_lc="$(printf '%s' "$body" | tr '[:upper:]' '[:lower:]')"
  for token in "$@"; do
    token_lc="$(printf '%s' "$token" | tr '[:upper:]' '[:lower:]')"
    if [[ "$body_lc" == *"$token_lc"* ]]; then
      return 0
    fi
  done
  return 1
}

active_issue() {
  local state="$1"
  local labels="$2"
  local state_lc
  state_lc="$(printf '%s' "$state" | tr '[:upper:]' '[:lower:]')"
  [[ "$state_lc" == "closed" ]] && return 1
  contains_label "$labels" "org:phase/done" && return 1
  contains_label "$labels" "org:phase/blocked" && return 1
  return 0
}

external_facing() {
  local text="$1"
  field_present "$text" \
    "external" "client-facing" "public" "proposal" "outreach" "submission" \
    "外部" "公開" "提案" "送信" "提出"
}

append_missing() {
  local issue_ref="$1"
  local missing="$2"
  MISSING_REPORT+="- ${issue_ref}: ${missing}"$'\n'
  MISSING_COUNT=$((MISSING_COUNT + 1))
}

append_qcd_warning() {
  local issue_ref="$1"
  local missing="$2"
  QCD_WARNING_REPORT+="- ${issue_ref}: ${missing}"$'\n'
  QCD_WARNING_COUNT=$((QCD_WARNING_COUNT + 1))
}

issues_json="$(read_issues)" || {
  echo "Unable to observe org issues from $REPO." >&2
  exit 1
}

printf '%s' "$issues_json" | jq empty >/dev/null

ACTIVE_PARENT=0
ACTIVE_TASKS=0
ACTIVE_EXTERNAL=0
MISSING_COUNT=0
MISSING_REPORT=""
QCD_WARNING_COUNT=0
QCD_WARNING_REPORT=""

while IFS= read -r issue; do
  number="$(jq -r '.number // "?"' <<<"$issue")"
  title="$(jq -r '.title // ""' <<<"$issue")"
  state="$(jq -r '.state // "OPEN"' <<<"$issue")"
  body="$(jq -r '.body // ""' <<<"$issue")"
  labels="$(labels_for_issue <<<"$issue")"
  issue_ref="#${number} ${title}"

  if active_issue "$state" "$labels"; then
    if contains_label "$labels" "org:type/project"; then
      ACTIVE_PARENT=$((ACTIVE_PARENT + 1))
    fi
    if contains_label "$labels" "org:type/task"; then
      ACTIVE_TASKS=$((ACTIVE_TASKS + 1))
    fi
    if ! contains_label "$labels" "org:type/quality-gate" && [[ "$body $title $labels" == *"ES-3"* || "$body $title $labels" == *"ES-4"* ]]; then
      if external_facing "$body $title"; then
        ACTIVE_EXTERNAL=$((ACTIVE_EXTERNAL + 1))
      fi
    fi
  fi

  if contains_label "$labels" "org:type/project" || contains_label "$labels" "org:type/task"; then
    missing_fields=()
    field_present "$body" "parent_project" "parent project" "parent-project" "親プロジェクト" || missing_fields+=("parent_project")
    field_present "$body" "work_ref" "work ref" "work-ref" "Vault" || missing_fields+=("work_ref")
    field_present "$body" "data_profile" "Evidence Strictness" "ES-0" "ES-1" "ES-2" "ES-3" "ES-4" || missing_fields+=("data_profile")
    field_present "$body" "role" "担当エージェント" || missing_fields+=("role")
    field_present "$body" "phase" "org:phase" || missing_fields+=("phase")
    field_present "$body" "expected_return" "expected return" || missing_fields+=("expected_return")
    field_present "$body" "gate" "UQG" "quality" || missing_fields+=("gate")
    field_present "$body" "closeout_evidence" "closeout evidence" "artifact_refs" || missing_fields+=("closeout_evidence")
    field_present "$body" "next_circulation" "next circulation" || missing_fields+=("next_circulation")

    if [[ "${#missing_fields[@]}" -gt 0 ]]; then
      append_missing "$issue_ref" "$(IFS=,; echo "${missing_fields[*]}")"
    fi

    qcd_missing=()
    field_present "$body" "qcd:" "qcd contract" || qcd_missing+=("qcd")
    field_present "$body" "quality_target" "quality target" || qcd_missing+=("quality_target")
    field_present "$body" "delivery_target" "delivery target" "next_checkpoint" || qcd_missing+=("delivery_target")
    field_present "$body" "cost_budget" "cost budget" "wip_slots" || qcd_missing+=("cost_budget")
    field_present "$body" "stop_rules" "stop rule" || qcd_missing+=("stop_rules")

    if [[ "${#qcd_missing[@]}" -gt 0 ]]; then
      append_qcd_warning "$issue_ref" "$(IFS=,; echo "${qcd_missing[*]}")"
    fi
  fi

  if contains_label "$labels" "org:type/quality-gate"; then
    missing_fields=()
    field_present "$body" "data_profile" "Evidence Strictness" "ES-0" "ES-1" "ES-2" "ES-3" "ES-4" || missing_fields+=("data_profile")
    field_present "$body" "gate" "ゲート" || missing_fields+=("gate")
    field_present "$body" "required_evidence" "Data-Evidence" "Work" "Life" || missing_fields+=("required_evidence")
    field_present "$body" "result" "status" "判定結果" "pass" "fail" "waived" || missing_fields+=("result")
    field_present "$body" "next_circulation" "next circulation" || missing_fields+=("next_circulation")

    if [[ "${#missing_fields[@]}" -gt 0 ]]; then
      append_missing "$issue_ref" "$(IFS=,; echo "${missing_fields[*]}")"
    fi
  fi
done < <(jq -c '.[]' <<<"$issues_json")

FAILURES=0

echo "# org contract audit"
echo ""
echo "Source: ${FROM_FILE:-$REPO open issues}"
echo "Authority: Data-Evidence > Work > Life > Org > Codex"
echo ""
echo "## WIP"
printf "| %-35s | %5s | %5s | %s\n" "Type" "Count" "Limit" "Status"
printf "| %-35s | %5s | %5s | %s\n" "---" "---:" "---:" "---"

if [[ "$ACTIVE_PARENT" -le "$PARENT_LIMIT" ]]; then parent_status="PASS"; else parent_status="FAIL"; FAILURES=$((FAILURES + 1)); fi
if [[ "$ACTIVE_TASKS" -le "$TASK_LIMIT" ]]; then task_status="PASS"; else task_status="FAIL"; FAILURES=$((FAILURES + 1)); fi
if [[ "$ACTIVE_EXTERNAL" -le "$EXTERNAL_LIMIT" ]]; then external_status="PASS"; else external_status="FAIL"; FAILURES=$((FAILURES + 1)); fi

printf "| %-35s | %5s | %5s | %s\n" "Active parent projects" "$ACTIVE_PARENT" "$PARENT_LIMIT" "$parent_status"
printf "| %-35s | %5s | %5s | %s\n" "Active Org tasks" "$ACTIVE_TASKS" "$TASK_LIMIT" "$task_status"
printf "| %-35s | %5s | %5s | %s\n" "ES-3/4 external-facing artifacts" "$ACTIVE_EXTERNAL" "$EXTERNAL_LIMIT" "$external_status"
echo ""

echo "## Issue field audit"
if [[ "$MISSING_COUNT" -eq 0 ]]; then
  echo "Missing critical fields: 0"
else
  echo "Missing critical fields: $MISSING_COUNT"
  printf '%s' "$MISSING_REPORT"
  FAILURES=$((FAILURES + MISSING_COUNT))
fi
echo ""

echo "## QCD readiness"
if [[ "$QCD_WARNING_COUNT" -eq 0 ]]; then
  echo "Missing QCD contract fields: 0"
else
  echo "Missing QCD contract fields: $QCD_WARNING_COUNT"
  printf '%s' "$QCD_WARNING_REPORT"
  echo "Note: QCD readiness warnings do not fail this audit yet; fill them at the next planning touch."
fi
echo ""

if [[ "$FAILURES" -eq 0 ]]; then
  echo "Result: pass"
else
  echo "Result: fail"
fi

if [[ "$FAILURES" -ne 0 && "$SOFT" -eq 0 ]]; then
  exit 1
fi
