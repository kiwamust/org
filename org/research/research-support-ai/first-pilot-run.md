# First Pilot Run

Status: template
Project: [[org/research/research-support-ai/README]]
Protocol: [[org/research/research-support-ai/pilot-protocol]]
Eval: [[org/research/research-support-ai/eval-checklist]]
Org task: kiwamust/org#25
Readiness gate: kiwamust/org#26

## Run Metadata

```yaml
pilot_run_id: "rsa-pilot-YYYYMMDD-01"
run_status: "not_started|running|completed|abandoned"
pilot_user_role: "independent cross-domain practitioner"
started_at:
completed_at:
operator:
```

## Input Package

```yaml
topic:
purpose:
why_now:
intended_output:
  type: "plan|article|research_note|other"
  working_title:
  target_audience:
  reuse_deadline:
source_set:
  required_sources:
    - source_id: "S1"
      title:
      url_or_path:
      author_or_publisher:
      published_or_updated:
      why_included:
  optional_sources: []
  excluded_sources: []
constraints:
  must_include: []
  must_avoid: []
  language: "ja|en|mixed"
  privacy_notes:
  time_limit_minutes: 45
intended_output_use:
  where_reuse_will_be_checked: "plan|article|research_note|other"
  baseline_without_ai_minutes:
  expected_reusable_sections: []
```

## Output Package

### Source Inventory

| source_id | title | author/publisher | date | url/path | role in run | reliability | note |
|---|---|---|---|---|---|---|---|

### Claims

| claim_id | claim | evidence summary | source_ids | confidence | uncertainty | reusable as |
|---|---|---|---|---|---|---|

### Contradictions / Constraints

| point_id | claim_or_assumption_limited | source_ids | implication for user output |
|---|---|---|---|

### Open Questions

| question_id | question | why it matters | next source or action |
|---|---|---|---|

### Point Map

| axis | position A | position B | practical implication |
|---|---|---|---|

### Grounding Spot Check

| sampled_claim_id | source_id | source pointer | supported? | correction needed |
|---|---|---|---|---|

### Reusable Summary

TBD.

## Reuse Trace

| generated_section | reused_in | reuse_type | note |
|---|---|---|---|

Allowed `reuse_type`: `verbatim`, `edited`, `structure_only`, `idea_only`, `none`.

## Eval Record

```yaml
time_saved_minutes:
reused_sections_count:
source_grounding_rate:
grounding_spot_check:
  sampled_claims_count:
  supported_claims_count:
  unsupported_claim_ids: []
  correction_notes: []
correction_load: "none|light|heavy|rewrite"
return_intent: "yes|no|conditional"
return_intent_reason:
```

## Closeout Notes

- What worked:
- What failed:
- Scope drift observed:
- Follow-up before 3-5 person pilot:
