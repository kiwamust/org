# otoprism Business Start Pilot Issue Seed

Status: ready-for-user-approved-gh-issue-creation
Baseline: `docs/ORG_OPERATING_BASELINE.md`
Primary strictness: ES-2, with ES-3 for public/external claims
WIP rule: maximum 5 simultaneous active pilot issues and maximum 2 external-facing artifacts

Use these bodies after the user approves PJ / task creation. Do not send outreach from these issues until Life approval and signal capture are present.

## PJ: otoprism business start pilot

Labels:

```text
org:type/project,org:phase/intake,org:status/green,org:dept/cross,org:gbt/behavior,org:priority/p1
```

Body:

```yaml
parent_project: "life:otoprism-business-start"
work_ref: "work:org/projects/otoprism-business-start/"
data_profile: "ES-2"
role: "Strategist Agent"
phase: "intake"
expected_return: "one-week business-start pilot with offer, audience, signal capture, and continue/pivot/stop decision"
input_refs:
  - "docs/ORG_OPERATING_BASELINE.md"
  - "docs/issue-bodies/otoprism-business-start-pilot.md"
constraints:
  - "External-facing claims require ES-3 gate."
  - "No outreach send before Life approval."
  - "No outreach without signal capture fields."
gate:
  type: "MVP experiment gate"
  status: "pending"
  required_evidence:
    - "Work claim status"
    - "signal capture design"
    - "Life approval before external send"
closeout_evidence:
  artifact_refs: []
  trace_refs: []
  verification_result: ""
next_circulation: "Life"
```

## OTO-ORG-01 Pilot setup

Labels:

```text
org:type/task,org:phase/planning,org:status/green,org:dept/cross,org:gbt/behavior,org:priority/p1
```

Body:

```yaml
parent_project: "life:otoprism-business-start"
work_ref: "work:org/projects/otoprism-business-start/"
data_profile: "ES-1"
role: "Strategist Agent"
phase: "planning"
expected_return: "pilot scope, WIP, review date, and parent refs"
input_refs:
  - "PJ: otoprism business start pilot"
constraints:
  - "Active pilot issues <= 5."
gate:
  type: "UQG"
  status: "pending"
  required_evidence:
    - "parent Life ref"
    - "Work output ref"
    - "review date"
closeout_evidence:
  artifact_refs: []
  trace_refs: []
  verification_result: ""
next_circulation: "Org"
```

## OTO-ORG-02 Source / claim evidence gap

Labels:

```text
org:type/task,org:phase/planning,org:status/green,org:dept/rnd,org:gbt/generation,org:priority/p1
```

Body:

```yaml
parent_project: "life:otoprism-business-start"
work_ref: "work:org/projects/otoprism-business-start/sources.md"
data_profile: "ES-2"
role: "Research Agent"
phase: "planning"
expected_return: "source pack and evidence gap per business-start claim"
input_refs:
  - "Work claim ledger or current otoprism source notes"
constraints:
  - "Do not assert evidence admissibility; record gaps."
gate:
  type: "MVP experiment gate"
  status: "pending"
  required_evidence:
    - "claim list"
    - "source candidates"
    - "contradiction / unknown status"
closeout_evidence:
  artifact_refs: []
  trace_refs: []
  verification_result: ""
next_circulation: "Work"
```

## OTO-ORG-03 1-page offer draft

Labels:

```text
org:type/task,org:phase/planning,org:status/green,org:dept/brand,org:gbt/target,org:priority/p1
```

Body:

```yaml
parent_project: "life:otoprism-business-start"
work_ref: "work:org/projects/otoprism-business-start/offer-v0.md"
data_profile: "ES-2"
role: "Drafting Agent"
phase: "planning"
expected_return: "one-page offer v0 connected to Work claim status"
input_refs:
  - "OTO-ORG-02 source / claim evidence gap"
constraints:
  - "Unsupported claims stay marked as hypothesis."
  - "Public/external wording requires ES-3 check before send."
gate:
  type: "MVP experiment gate"
  status: "pending"
  required_evidence:
    - "Work claim ledger references"
    - "audience definition"
closeout_evidence:
  artifact_refs: []
  trace_refs: []
  verification_result: ""
next_circulation: "Work"
```

## OTO-ORG-04 Interview script QA

Labels:

```text
org:type/quality-gate,org:phase/review,org:status/green,org:quality/gate-pending,org:dept/operations,org:gbt/behavior,org:priority/p1
```

Body:

```yaml
parent_project: "life:otoprism-business-start"
work_ref: "work:org/projects/otoprism-business-start/interview-script.md"
data_profile: "ES-2"
role: "QA Gate Agent"
phase: "review"
expected_return: "QA result removing leading questions, unsupported claims, and privacy risk"
input_refs:
  - "interview script draft"
constraints:
  - "No external interview until privacy and signal capture are checked."
gate:
  type: "MVP experiment gate"
  status: "pending"
  required_evidence:
    - "question list"
    - "privacy risk check"
    - "unsupported claim check"
closeout_evidence:
  artifact_refs: []
  trace_refs: []
  verification_result: ""
next_circulation: "Org"
```

## OTO-ORG-05 Audience list / outreach draft

Labels:

```text
org:type/task,org:phase/planning,org:status/green,org:dept/brand,org:gbt/target,org:priority/p1
```

Body:

```yaml
parent_project: "life:otoprism-business-start"
work_ref: "work:org/projects/otoprism-business-start/audience-outreach.md"
data_profile: "ES-3"
role: "Sales Agent"
phase: "planning"
expected_return: "target segment and outreach draft; no send"
input_refs:
  - "OTO-ORG-03 1-page offer draft"
  - "OTO-ORG-06 signal capture setup"
constraints:
  - "External send requires Life approval."
  - "ES-3 claim support required for client-facing wording."
gate:
  type: "MVP experiment gate"
  status: "pending"
  required_evidence:
    - "target segment rationale"
    - "claim support"
    - "Life approval before send"
closeout_evidence:
  artifact_refs: []
  trace_refs: []
  verification_result: ""
next_circulation: "Life"
```

## OTO-ORG-06 Signal capture setup

Labels:

```text
org:type/task,org:phase/planning,org:status/green,org:dept/operations,org:gbt/behavior,org:priority/p1
```

Body:

```yaml
parent_project: "life:otoprism-business-start"
work_ref: "work:org/projects/otoprism-business-start/signal-capture.md"
data_profile: "ES-2"
role: "Data Steward Agent"
phase: "planning"
expected_return: "feedback fields, metric definitions, and evidence refs"
input_refs:
  - "offer draft"
  - "interview script"
constraints:
  - "Do not upload restricted raw data without approval."
gate:
  type: "data"
  status: "pending"
  required_evidence:
    - "feedback fields"
    - "metric definitions"
    - "access class"
closeout_evidence:
  artifact_refs: []
  trace_refs: []
  verification_result: ""
next_circulation: "Data-Evidence"
```

## OTO-ORG-07 Week1 closeout

Labels:

```text
org:type/task,org:phase/planning,org:status/green,org:dept/cross,org:gbt/behavior,org:priority/p1
```

Body:

```yaml
parent_project: "life:otoprism-business-start"
work_ref: "work:org/projects/otoprism-business-start/week1-closeout.md"
data_profile: "ES-2"
role: "Strategist Agent + Data Steward Agent"
phase: "planning"
expected_return: "signal / gate / trace / decision package returned to Life"
input_refs:
  - "OTO-ORG-01..06"
constraints:
  - "Decision is continue / pivot / stop; do not invent signal."
gate:
  type: "MVP experiment gate"
  status: "pending"
  required_evidence:
    - "captured signals"
    - "gate results"
    - "trace refs"
    - "decision package"
closeout_evidence:
  artifact_refs: []
  trace_refs: []
  verification_result: ""
next_circulation: "Life"
```
