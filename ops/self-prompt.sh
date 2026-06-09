#!/usr/bin/env bash
# ops/self-prompt.sh - generate org directive candidates from observed state.

set -euo pipefail

REPO="${ORG_REPO:-kiwamust/org}"
LIMIT="${ORG_SELF_PROMPT_LIMIT:-30}"
FROM_FILE=""

usage() {
  cat <<'USAGE'
Usage: bash ops/self-prompt.sh [--repo owner/name] [--limit N] [--from-file issues.tsv]

Generate proposal-only directive candidates from org state.

Input TSV format for --from-file:
  number<TAB>title<TAB>comma-separated-labels
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      REPO="$2"
      shift 2
      ;;
    --limit)
      LIMIT="$2"
      shift 2
      ;;
    --from-file)
      FROM_FILE="$2"
      shift 2
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

contains_label() {
  local labels="$1"
  local label="$2"
  [[ ",$labels," == *",$label,"* ]]
}

priority_for() {
  local labels="$1"
  if contains_label "$labels" "org:priority/p1"; then
    echo "p1"
  elif contains_label "$labels" "org:priority/p2"; then
    echo "p2"
  elif contains_label "$labels" "org:priority/p3"; then
    echo "p3"
  elif contains_label "$labels" "org:status/red" || contains_label "$labels" "org:quality/gate-fail"; then
    echo "p1"
  elif contains_label "$labels" "org:status/yellow" || contains_label "$labels" "org:quality/gate-pending"; then
    echo "p2"
  else
    echo "p3"
  fi
}

dept_for() {
  local labels="$1"
  local title="$2"
  local lower_title
  lower_title="$(printf '%s' "$title" | tr '[:upper:]' '[:lower:]')"
  for dept in operations engineering rnd brand emergingtech cross; do
    if contains_label "$labels" "org:dept/$dept"; then
      echo "$dept"
      return
    fi
  done
  case "$lower_title" in
    *quality*|*gate*|*handoff*|*qad*) echo "operations" ;;
    *code*|*build*|*test*|*fix*) echo "engineering" ;;
    *article*|*slide*|*vlog*|*brand*) echo "brand" ;;
    *research*|*synthesis*|*hypothesis*) echo "rnd" ;;
    *prototype*|*radar*|*tool*) echo "emergingtech" ;;
    *) echo "cross" ;;
  esac
}

gbt_for() {
  local labels="$1"
  local title="$2"
  local lower_title
  lower_title="$(printf '%s' "$title" | tr '[:upper:]' '[:lower:]')"
  if contains_label "$labels" "org:quality/gate-fail" || contains_label "$labels" "org:quality/gate-pending"; then
    echo "behavior"
    return
  fi
  for gbt in generation behavior target; do
    if contains_label "$labels" "org:gbt/$gbt"; then
      echo "$gbt"
      return
    fi
  done
  case "$lower_title" in
    *research*|*synthesis*|*hypothesis*|*survey*) echo "generation" ;;
    *article*|*slide*|*vlog*|*publish*) echo "target" ;;
    *) echo "behavior" ;;
  esac
}

candidate_title_for() {
  local number="$1"
  local title="$2"
  local labels="$3"
  if contains_label "$labels" "org:quality/gate-fail"; then
    echo "DIR: Recover gate failure in #$number - $title"
  elif contains_label "$labels" "org:status/red"; then
    echo "DIR: Recover red org issue #$number - $title"
  elif contains_label "$labels" "org:quality/gate-pending"; then
    echo "DIR: Advance pending quality gate #$number - $title"
  elif contains_label "$labels" "org:status/yellow"; then
    echo "DIR: Stabilize yellow org issue #$number - $title"
  else
    echo "DIR: Progress org issue #$number - $title"
  fi
}

signal_score_for() {
  local labels="$1"
  if contains_label "$labels" "org:quality/gate-fail"; then
    echo 100
  elif contains_label "$labels" "org:status/red"; then
    echo 90
  elif contains_label "$labels" "org:quality/gate-pending"; then
    echo 80
  elif contains_label "$labels" "org:status/yellow"; then
    echo 70
  elif contains_label "$labels" "org:phase/blocked"; then
    echo 60
  else
    echo 10
  fi
}

read_issues() {
  if [[ -n "$FROM_FILE" ]]; then
    cat "$FROM_FILE"
    return
  fi

  gh issue list --repo "$REPO" --state open --limit "$LIMIT" --json number,title,labels \
    --jq '.[] | [.number, .title, (.labels | map(.name) | join(","))] | @tsv'
}

emit_empty_candidate() {
  cat <<EOF
# org self-prompt candidates

Observation:
- Source: $REPO open issues
- Mode: proposal-only
- No open org issues were observed.

## Candidate 1
Title: DIR: Refresh org intake baseline
GBT: generation
Dept: operations
Priority: p2
Evidence: issue list was empty

Prompt:
Observe Work/Vault project seeds, current org docs, and recent decisions. Propose the next smallest org directive that would create durable state without fabricating user intent.

Approval gate:
No GitHub Issue is created until the user approves one candidate.
EOF
}

emit_candidate() {
  local number="$1"
  local title="$2"
  local labels="$3"
  local candidate_title priority dept gbt

  candidate_title="$(candidate_title_for "$number" "$title" "$labels")"
  priority="$(priority_for "$labels")"
  dept="$(dept_for "$labels" "$title")"
  gbt="$(gbt_for "$labels" "$title")"

  cat <<EOF
# org self-prompt candidates

Observation:
- Source: $REPO open issues
- Mode: proposal-only
- Selected signal: #$number

## Candidate 1
Title: $candidate_title
GBT: $gbt
Dept: $dept
Priority: $priority
Evidence: #$number "$title" [$labels]

Prompt:
Use org-dispatch to structure this directive. Diagnose the observed signal, define the smallest recoverable DoD, route it to $dept with Operations/QAD oversight, and return a plan for user approval before creating or mutating Issues.

Approval gate:
No GitHub Issue is created until the user approves one candidate.

Suggested command after approval:
gh issue create --repo "$REPO" --title "$candidate_title" --label "org:type/directive,org:dept/$dept,org:gbt/$gbt,org:priority/$priority"
EOF
}

main() {
  local selected_line=""
  local issues_output=""
  local best_score=-1
  local score

  if ! issues_output="$(read_issues)"; then
    cat >&2 <<EOF
Unable to observe org issues from $REPO.
No candidate generated because observation failed.
EOF
    return 1
  fi

  while IFS=$'\t' read -r number title labels _; do
    [[ -z "${number:-}" ]] && continue
    score="$(signal_score_for "${labels:-}")"
    if [[ "$score" -gt "$best_score" ]]; then
      best_score="$score"
      selected_line="$number"$'\t'"$title"$'\t'"${labels:-}"
    fi
  done <<<"$issues_output"

  if [[ -z "$selected_line" ]]; then
    emit_empty_candidate
    return
  fi

  IFS=$'\t' read -r number title labels <<<"$selected_line"
  emit_candidate "$number" "$title" "${labels:-}"
}

main "$@"
