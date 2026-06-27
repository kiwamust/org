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

Org is the execution subsystem for kiwamust and agent groups. It is not a knowledge base, a portfolio owner, or a source of observed truth. Its job is to move work through role, phase, WIP, gate, handoff, and closeout evidence without violating higher authority.

## Authority Ladder

When subsystem state, judgment, or claims conflict, resolve by this order:

```text
Data-Evidence > Work > Life > Org > Codex
```

| Rank | Subsystem | Final authority over | Constraint on lower layers |
| ---: | --- | --- | --- |
| 1 | Data-Evidence | observed facts, metrics, citations, lineage, confidence, access class, evidence admissibility | If evidence is weak, stale, contradictory, or access-violating, Work/Life/Org/Codex decisions stop. |
| 2 | Work | ontology, meaning, claim state, source inventory, artifact semantics, output readiness | Life/Org/Codex cannot turn unsupported Work claims into supported claims. |
| 3 | Life | portfolio priority, continue/stop/integrate/publish, opportunity cost, final personal DoD | Org momentum cannot override Life stop/defer decisions. |
| 4 | Org | execution plan, role assignment, phase, UQG, WIP, handoff, schedule | Org cannot pass Data-invalid, Work-unsupported, or Life-stopped work. |
| 5 | Codex | observation, draft, patch, tool execution, verification proposal, trace emission | Codex does not own long-term state until it is saved into Issue, Work artifact, or trace. |

### Conflict Handling

1. Data conflict: set the Org issue to blocked and record `blocked:evidence_conflict`.
2. Claim conflict: return to Work; do not rewrite claim meaning in Org.
3. Priority conflict: return to Life for continue/stop/defer/integrate.
4. Execution conflict: Org decides phase, owner, WIP, and gate after higher gates are satisfied.
5. Agent conflict: Codex output remains proposal/draft until incorporated into a higher subsystem artifact.

## Evidence Strictness

Evidence Strictness is selected per project by externality, reversibility, money impact, publicness, privacy, legal/procurement risk, and research risk.

| Level | Use | Quantitative claim | Qualitative claim | Allowed | Not allowed |
| --- | --- | --- | --- | --- | --- |
| ES-0 | private scratch, ideation | no CI required | hypothesis explicitly marked | ideas, framing, private notes | external send, decision, canonical update |
| ES-1 | reversible internal decision | broad uncertainty acceptable | one source family plus uncertainty | backlog, prototype, internal draft | client-facing assertion, public claim |
| ES-2 | business experiment, lightweight external test | target 80% confidence equivalent, wide intervals allowed | at least two evidence lines or explicit falsifier | MVP test, first sales call, hypothesis check | high-value contract, official proposal, research conclusion |
| ES-3 | client-facing, public, strategic artifact | target 90% confidence equivalent | primary sources preferred, 2-3 line triangulation, review | proposal, public deck, paper draft, major decision | legal/procurement/research conclusion without verification |
| ES-4 | high-irreversibility, procurement, legal, research result, financial commitment | target 95% confidence equivalent | official source or reproducible evidence plus second review | final submission, contract premise, regulated/public-sector claim | waiver without explicit Life/Data/Work approval |

If a strict statistical interval cannot be created, record `uncertainty_band`, `sample_size`, `source_quality`, `contradiction_status`, and `decision_reversibility` in the evidence package.

## Org Ownership

Org owns:

- execution issue, task, phase, role, owner
- UQG and project-specific gates
- WIP limit, blocked/stale/escalation state
- handoff package and closeout evidence
- quality signal and cycle-time metric generation

Org does not own:

- evidence admissibility, which belongs to Data-Evidence
- claim or artifact meaning, which belongs to Work
- portfolio priority and final DoD, which belong to Life
- long-term state from Codex sessions unless saved as Issue, artifact, or trace

## Execution Contract

Every execution unit follows this path:

```text
Input package -> Role assignment -> Execution -> Gate -> Closeout evidence -> Next circulation
```

Every project or task must carry:

- parent Life project or Work output
- required evidence strictness
- role
- phase
- expected return
- gate
- closeout evidence
- next circulation

## Issue Contract

Use this shape in project and task bodies when a GitHub form does not capture the fields explicitly:

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

### ES-Aware Gate Mapping

| ES | Org gate | Required review | Closeout evidence |
| --- | --- | --- | --- |
| ES-0 | lightweight | self-check | draft, note, next question |
| ES-1 | internal QA | role owner | artifact diff, known uncertainty |
| ES-2 | experiment gate | QA Agent plus Work check | audience plan, claim status, signal capture |
| ES-3 | external-facing gate | QA Agent plus Work plus Data-Evidence check | citations, claim support, approval request |
| ES-4 | high-stakes gate | Data-Evidence plus Work plus Life approval plus second review | official source trace, reproducibility, compliance matrix, explicit approval |

## WIP Safety Limits

WIP limits are sovereignty and quality controls, not productivity targets.

| WIP type | Default limit | Exceeding limit |
| --- | ---: | --- |
| Active parent project | 3 | No addition without Life review |
| Active Org tasks per pilot | 7 | Freeze new task intake; close or merge first |
| ES-3/4 external-facing artifacts | 2 | Add reviewer/evidence before intake |
| Codex substantial runs without trace | 0 after grace | Convert missing trace into improvement candidate |

## Role Contract

| Role | Purpose | Input | Output | Prohibited |
| --- | --- | --- | --- | --- |
| Strategist Agent | Scope and route the project | Life DoD, Work output, Data profile | execution plan, issue breakdown | portfolio final decision |
| Research Agent | Gather source and evidence candidates | claim, question, strictness | source pack, evidence gaps | evidence admissibility assertion |
| Drafting Agent | Draft artifacts | Work claim, audience, format | draft, revision notes | unsupported claim assertion |
| QA Gate Agent | Run UQG and project gates | artifact, claim, evidence refs | pass/fail/waive recommendation | waiver without owner/expiry |
| Sales Agent | Prepare audience and proposal flow | offer, target, constraints | outreach draft, objection log | external send without approval |
| Research Writing Agent | Run QCD paper flow | claim ledger, data, outline | section draft, figure plan | empirical claim without lineage |
| Data Steward Agent | Package trace, metric, evidence | run outputs, source refs | Data-Evidence ingest package | restricted raw upload without approval |
| Codex Executor | Tool execution, patch, verification | bounded task | trace, artifact, verification | long-term state ownership |

## Project Gates

| Project | Default gate | ES | Gate focus |
| --- | --- | --- | --- |
| otoprism | MVP experiment gate | ES-2; public/external claims are ES-3 | offer clarity, audience fit, interview ethics, signal capture |
| public-service proposal | proposal/compliance gate | ES-3/4 | RFP compliance, official facts, value proof, delivery feasibility, approval |
| QCD paper | research quality gate | ES-3/4 | novelty, related work, method, data lineage, reproducibility, claim discipline |

## First Pilot: otoprism Business Start

The first pilot is `otoprism business start` unless a higher-priority Life deadline overrides it. The objective is one evidence-backed subsystem loop, not maximum scope.

| Issue | Role | Strictness | Done |
| --- | --- | --- | --- |
| OTO-ORG-01 Pilot setup | Strategist Agent | ES-1 | parent Life/Work refs, scope, WIP, review date exist |
| OTO-ORG-02 Source / claim evidence gap | Research Agent | ES-2 | source pack and evidence gap per claim exist |
| OTO-ORG-03 1-page offer draft | Drafting Agent | ES-2 | offer v0 is connected to Work claim ledger |
| OTO-ORG-04 Interview script QA | QA Gate Agent | ES-2 | leading questions, unsupported claims, and privacy risk removed |
| OTO-ORG-05 Audience list / outreach draft | Sales Agent | ES-2/3 | target segment and outreach draft exist; send waits for Life approval |
| OTO-ORG-06 Signal capture setup | Data Steward Agent | ES-2 | feedback fields, metric, and evidence refs are defined |
| OTO-ORG-07 Week1 closeout | Strategist plus Data Steward | ES-2 | signal, gate, trace, and decision package return to Life |

Pilot WIP rules:

- Maximum 5 simultaneous active pilot issues.
- Maximum 2 external-facing artifacts.
- No outreach is sent until signal capture is defined.
- Codex substantial runs leave trace or verification.
- Gate fail is a task-generation condition, not a worker failure.

## Audit Methods

Issue Field Audit checks active issues for `parent_project`, `work_ref`, `data_profile`, `role`, `phase`, `gate`, `next_circulation`, and `closeout_evidence`. P0/P1 issues pass only when no critical field is missing.

Handoff Test uses this minimal package:

```yaml
handoff_package:
  issue_id: ""
  role: ""
  phase: ""
  context: ""
  input_refs: []
  strictness: "ES-0..ES-4"
  constraints: []
  expected_return: ""
  gate: ""
  next_circulation: ""
```

Gate Audit checks strictness fit, pass/fail/waive reason, remediation task, waiver owner/expiry, ES-4 waiver absence, and contradiction against Data-Evidence/Work/Life.

Flow Metrics Review tracks throughput, cycle time, rework rate, blocked count, stale count, and scope creep. Triggers:

- throughput grows without signal: reduce WIP
- long cycle time: split or stop issue
- rework rate greater than 20%: move gate earlier
- blocked count grows: escalate to Data/Work/Life
- stale issue older than 7 days: review
- scope creep greater than 15%: Life review

## Stop Conditions

| Condition | Org response |
| --- | --- |
| Data-Evidence invalidates key evidence | mark blocked:data and return to Work/Life |
| Work claim is unsupported | artifact gate fails and returns to draft |
| Life stops or defers | close/freeze active tasks and return retained asset to Work |
| WIP limit exceeded | freeze new intake |
| ES-4 lacks reviewer, official source, or approval | prohibit external-facing action |
| Codex lacks trace or verification | do not mark done; create improvement candidate |
| handoff package is insufficient | fix issue contract defect |

## Completion Levels

| Level | State | Done | Verification |
| --- | --- | --- | --- |
| O0 | Role Ready | major roles and prohibited actions defined | role contract review |
| O1 | Issue Protocol Ready | issues have parent, role, phase, gate, strictness, next circulation | issue field audit |
| O2 | Gate Instrumented | UQG/project gate returns pass/fail/waive | gate audit |
| O3 | Operational | WIP, blocked, stale, rework are managed | flow metrics review |
| O4 | Sovereign RDE/FDE Ready | agents divide work under higher authority | handoff test and conflict drill |
