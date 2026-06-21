---
type: org-project-index
project: project-thermodynamics-path-c
created: 2026-06-09
status: planning
---

# Project Thermodynamics Path C

## Links

- Life parent Issue: [kiwamust/life#29](https://github.com/kiwamust/life/issues/29)
- org execution:
  - [kiwamust/org#14](https://github.com/kiwamust/org/issues/14) — TASK: QCD Path C metric normalization
  - [kiwamust/org#16](https://github.com/kiwamust/org/issues/16) — TASK: QCD Path C collector
  - [kiwamust/org#22](https://github.com/kiwamust/org/issues/22) — TASK: QCD Path C baseline run
  - [kiwamust/org#20](https://github.com/kiwamust/org/issues/20) — QG: QCD Path C IQG

## Purpose

Move Project Thermodynamics from v0.4 theory into Path C empirical validation, starting with org's own GitHub Issue and quality-gate logs.

## Charter

- Parent project: [[研究PJ: プロジェクトQCDの熱統計力学的定式化 — 経営学の自然科学化]]
- Current theory: [[project_thermodynamics_v04]]
- Prior QCD formulation: [[../qcd-thermodynamics/05-formulation]]
- Handoff: `project_thermodynamics_v04.md` Section 11

## Operating Ontology

| Object | Mapping |
| --- | --- |
| Activity | empirical validation of project thermodynamics |
| Asset | T0-T6 formal model, Handoff Package, metric collector, baseline data |
| Output | Path C validation report and reusable org metrics pipeline |
| Audience | kiwamu.sato, project management research audience, org operations |
| Signal | baseline metrics, label events, quality gate outcomes, estimation diagnostics |
| Decision | whether Path C can move from baseline to Phase 1 estimation |

## Source Artifacts

- [[T0_foundation]]
- [[T1_langevin_parameters]]
- [[T2_transition_kernel]]
- [[T3_activity]]
- [[T3_5_integration_check]]
- [[T4_TUR_constant]]
- [[T5_lyapunov]]
- [[T6_measurability]]
- [[project_thermodynamics_v04]]
- [[../qcd-thermodynamics/04-experiment-design]]

## Current Risks

- The org repository has little or no historical org Issue data, so immediate empirical validation is not possible.
- Existing experiment design uses `org:phase/active` and `org:status/active`, which do not match current org labels.
- Phase 0 must define empty-state behavior before any collector output is interpreted.

## Next Actions

1. Normalize label definitions.
2. Build collector against actual org labels.
3. Run baseline and record empty-state semantics.
4. Run IQG before Phase 1.

