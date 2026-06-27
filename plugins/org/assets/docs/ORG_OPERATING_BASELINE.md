---
title: Org Operating Baseline
subsystem: org
version: 1.0
status: active-contract
last_updated: 2026-06-28
primary_pilot: otoprism business start
authority_order: Data-Evidence > Work > Life > Org > Codex
---

# Org Operating Baseline

This is the Codex plugin distribution copy of `docs/ORG_OPERATING_BASELINE.md`. Keep the root document and this file synchronized.

## Authority Ladder

```text
Data-Evidence > Work > Life > Org > Codex
```

| Rank | Subsystem | Final authority over | Constraint on lower layers |
| ---: | --- | --- | --- |
| 1 | Data-Evidence | observed facts, metrics, citations, lineage, confidence, access class, evidence admissibility | weak, stale, contradictory, or access-violating evidence stops lower work |
| 2 | Work | ontology, meaning, claim state, artifact semantics, output readiness | unsupported Work claims cannot become supported in Life/Org/Codex |
| 3 | Life | portfolio priority, continue/stop/integrate/publish, opportunity cost, final DoD | Org momentum cannot override Life stop/defer |
| 4 | Org | execution plan, role assignment, phase, UQG, WIP, handoff, schedule | Org cannot pass Data-invalid, Work-unsupported, or Life-stopped work |
| 5 | Codex | observation, draft, patch, tool execution, verification proposal, trace emission | Codex does not own long-term state |

## Evidence Strictness

| Level | Use | Allowed | Not allowed |
| --- | --- | --- | --- |
| ES-0 | private scratch, ideation | ideas, framing, private notes | external send, decision, canonical update |
| ES-1 | reversible internal decision | backlog, prototype, internal draft | client-facing assertion, public claim |
| ES-2 | business experiment, lightweight external test | MVP test, first sales call, hypothesis check | high-value contract, official proposal, research conclusion |
| ES-3 | client-facing, public, strategic artifact | proposal, public deck, paper draft, major decision | legal/procurement/research conclusion without verification |
| ES-4 | high-irreversibility, procurement, legal, research result, financial commitment | final submission, contract premise, regulated/public-sector claim | waiver without explicit Life/Data/Work approval |

Record `uncertainty_band`, `sample_size`, `source_quality`, `contradiction_status`, and `decision_reversibility` when strict statistical intervals are unavailable.

## Execution Contract

```text
Input package -> Role assignment -> Execution -> Gate -> Closeout evidence -> Next circulation
```

Every project or task carries parent Life project or Work output, required evidence strictness, role, phase, expected return, gate, closeout evidence, and next circulation.

## Issue Contract

```yaml
issue_id: ""
parent_project: "life:..."
work_ref: "work:..."
data_profile: "ES-0..ES-4"
role: ""
phase: "intake|plan|execute|review|blocked|done|closed"
expected_return: ""
input_refs: []
constraints: []
gate:
  type: "UQG|sales|research|proposal|data|privacy"
  status: "pending|pass|fail|waived"
  required_evidence: []
closeout_evidence:
  artifact_refs: []
  trace_refs: []
  verification_result: ""
next_circulation: "Data-Evidence|Work|Life|Org|Codex|me"
```

## Gate Semantics

| Status | Meaning | Required condition |
| --- | --- | --- |
| pending | Not verified yet | next action is explicit |
| pass | Execution may advance | No contradiction with Data/Work/Life gates |
| fail | Cannot advance | remediation task or stop reason exists |
| waived | Conditional advance | owner, reason, expiry, and risk acceptance are recorded; ES-4 waiver is exceptional |

## WIP Safety Limits

| WIP type | Default limit | Exceeding limit |
| --- | ---: | --- |
| Active parent project | 3 | No addition without Life review |
| Active Org tasks per pilot | 7 | Freeze new task intake; close or merge first |
| ES-3/4 external-facing artifacts | 2 | Add reviewer/evidence before intake |
| Codex substantial runs without trace | 0 after grace | Convert missing trace into improvement candidate |

## Role Contract

| Role | Purpose | Output | Prohibited |
| --- | --- | --- | --- |
| Strategist Agent | scope and route the project | execution plan, issue breakdown | portfolio final decision |
| Research Agent | gather evidence candidates | source pack, evidence gaps | evidence admissibility assertion |
| Drafting Agent | draft artifacts | draft, revision notes | unsupported claim assertion |
| QA Gate Agent | run gates | pass/fail/waive recommendation | waiver without owner/expiry |
| Sales Agent | prepare audience/proposal flow | outreach draft, objection log | external send without approval |
| Research Writing Agent | run QCD paper flow | section draft, figure plan | empirical claim without lineage |
| Data Steward Agent | package trace/metric/evidence | Data-Evidence ingest package | restricted raw upload without approval |
| Codex Executor | execute tools/patch/verification | trace, artifact, verification | long-term state ownership |

## First Pilot

Default first pilot is `otoprism business start`, with ES-2 as the baseline and ES-3 for public/external claims.

| Issue | Role | Strictness | Done |
| --- | --- | --- | --- |
| OTO-ORG-01 Pilot setup | Strategist Agent | ES-1 | parent Life/Work refs, scope, WIP, review date exist |
| OTO-ORG-02 Source / claim evidence gap | Research Agent | ES-2 | source pack and evidence gap per claim exist |
| OTO-ORG-03 1-page offer draft | Drafting Agent | ES-2 | offer v0 is connected to Work claim ledger |
| OTO-ORG-04 Interview script QA | QA Gate Agent | ES-2 | leading questions, unsupported claims, and privacy risk removed |
| OTO-ORG-05 Audience list / outreach draft | Sales Agent | ES-2/3 | target segment and outreach draft exist; send waits for Life approval |
| OTO-ORG-06 Signal capture setup | Data Steward Agent | ES-2 | feedback fields, metric, and evidence refs are defined |
| OTO-ORG-07 Week1 closeout | Strategist plus Data Steward | ES-2 | signal, gate, trace, and decision package return to Life |

## Completion Levels

| Level | State | Done | Verification |
| --- | --- | --- | --- |
| O0 | Role Ready | major roles and prohibited actions defined | role contract review |
| O1 | Issue Protocol Ready | issues have parent, role, phase, gate, strictness, next circulation | issue field audit |
| O2 | Gate Instrumented | UQG/project gate returns pass/fail/waive | gate audit |
| O3 | Operational | WIP, blocked, stale, rework are managed | flow metrics review |
| O4 | Sovereign RDE/FDE Ready | agents divide work under higher authority | handoff test and conflict drill |
