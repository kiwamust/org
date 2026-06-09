# Project Intake — 2026-06-09

Observed by Codex using `org-dispatch`, `org-work`, `org-rnd`, `org-brand`, and `org-operations` procedures.

## Current Observations

- `kiwamust/org` currently has no visible Issues from `gh issue list --state all --limit 80`.
- Project-level parent Issues may live in `kiwamust/life`; org should hold execution tasks and quality gates.
- org labels exist for departments, phases, RAG status, quality gates, and GBT.
- Work canonical path is `/Users/kiwamusato/Work/work`.
- QCD / project thermodynamics artifacts already exist under:
  - `/Users/kiwamusato/Work/work/org/research/qcd-thermodynamics/`
  - `/Users/kiwamusato/Work/work/org/research/project-thermodynamics/`
- Work personal ontology exists under:
  - `/Users/kiwamusato/Work/work/_ontology/kiwamu-operating-ontology/`
- T3 2026 public details were not confirmed in local Vault. Current public T3 sources confirm T3's mission and pillars, but 2026 dates/open call details are TBD.

## Charter A: Work-org Integration

### Purpose

Connect org execution with Work's personal ontology so projects can move through Activity -> Asset -> Output -> Audience -> Signal -> Decision without losing state or source knowledge.

### DoD

- `org-work` skill exists in the Codex plugin.
- repo documentation defines the Issue/Vault boundary.
- Life/org/Work issue granularity is documented.
- every new org project has both a GitHub Issue and a Vault project index.
- QCD and T3 2026 projects are the first two linked projects.

### Scope

In:

- Work canonical path selection.
- Issue/Vault bidirectional link contract.
- project folder conventions.
- ontology mapping fields.
- UQG additions for Work-linked projects.

Out:

- bulk migration of existing Vault notes.
- editing source notes outside `/Users/kiwamusato/Work/work/org/`.
- replacing Obsidian with GitHub or GitHub with Obsidian.

### Routing

- Main: Operations
- Support: R&D, Brand
- GBT: behavior
- Quality: Standard

## Charter B: Project Thermodynamics Path C

### Purpose

Move the existing QCD / project thermodynamics research from v0.4 theory into Path C empirical validation, starting with org's own Issue and gate logs.

### Observed Inputs

- `project_thermodynamics_v04.md` marks T0-T6 and Handoff Package complete.
- Path C requires at least 35 sprints for single-team parameter estimation and ideally 50 sprints for C / TUR validation.
- Current org Issues are empty, so immediate empirical validation cannot start until org project state begins accumulating.
- Existing QCD experiment design contains a label mismatch: `org:phase/active` / `org:status/active` should be normalized to `org:phase/execute` and RAG status labels.

### DoD

- GitHub project Issue created and linked to Work index.
- Life parent Issue created and linked to Work index.
- Work index exists at `/Users/kiwamusato/Work/work/org/research/project-thermodynamics/index.md`.
- metric label mismatch is corrected in the Path C plan.
- Phase 0 baseline collector is specified: current label counts, event schema, empty-state behavior.
- first Path C task list is created: metric normalization, data collector, baseline run, acceptance criteria.

### Scope

In:

- Path C Phase 0 / Phase 1 launch.
- org repository as the first measurement system.
- GitHub-only minimum data path.
- q1/q2/q3 and issue phase/RAG/gate label definitions.

Out:

- claiming empirical validation before data exists.
- pooled multi-team model fitting.
- full 50-sprint TUR validation.

### Routing

- Main: R&D (`research-director`)
- Support: Engineering (`toolsmith`), Operations (`quality-inspector`)
- GBT: mixed, primary generation
- Quality: Premium

### Initial Tasks

1. `T-C0`: Normalize Path C metric definitions against actual org labels.
2. `T-C1`: Build `ops/collect-qcd-metrics.sh` against current labels.
3. `T-C2`: Create Work project index and bidirectional Issue link.
4. `T-C3`: Run baseline collection and record empty-state semantics.
5. `T-C4`: IQG review for Path C Phase 1 readiness.

## Charter C: T3 2026 Photo Artwork

### Purpose

Start an artwork-production project for T3 2026, using Work's LLM photography / urban-technology-human source notes as substrate and org Brand as execution system.

### Observed Inputs

- Work contains repeated self-definition notes around "写真作品を用いて都市とテクノロジーと人間の関係性を問う".
- Work personal ontology identifies LLM photography and photo work as part of the "Practitioner-Thinker" path.
- T3 public mission centers photography staged in Tokyo's urban space and includes PHOTO FESTIVAL / PHOTO ASIA / NEW TALENT pillars.
- 2026 details are TBD, so the first phase should be work development, not submission packaging.
- The user has non-public 2026 theme/context and will provide it later. It must be stored in Work and not quoted in GitHub Issues.

### DoD

- GitHub project Issue created and linked to Work index.
- Life parent Issue created and linked to Work index.
- Work index exists at `/Users/kiwamusato/Work/work/org/brand/t3-2026-photo-work/index.md`.
- confidential brief placeholder exists in Work.
- source note map exists.
- concept statement v0.1 exists.
- shot / material research plan exists.
- audience and submission assumptions are explicitly marked TBD until official 2026 requirements are confirmed.

### Scope

In:

- concept development.
- Work source note synthesis.
- visual research and shot plan.
- prototype selection/editing workflow.
- submission-readiness tracker once T3 2026 details are published.

Out:

- final submission before requirements are known.
- inventing T3 2026 dates or rules.
- quoting non-public T3 details in GitHub Issues.
- generic photo-series advice disconnected from Work notes.

### Routing

- Main: Brand (`brand-director`)
- Support: R&D (`knowledge-architect`), EmergingTech if AR/AI/interactive layer is chosen, Operations for gates.
- GBT: target, with generation in early concept phase
- Quality: Premium

### Operating Ontology Mapping

| Object | Mapping |
| --- | --- |
| Activity | photographing / thinking through urban technology and human presence |
| Asset | LLM photography theory, source note map, image corpus, concept vocabulary |
| Output | T3 2026 artwork proposal / photo series / exhibition package |
| Audience | T3 selectors, photography audience, Tokyo urban public |
| Signal | official T3 requirements, critique feedback, prototype image strength |
| Decision | concept direction, medium, submission package, production schedule |

### Initial Tasks

1. `T3-0`: Source-note map from Work.
2. `T3-1`: Confidential brief ingestion into Work-only file.
3. `T3-2`: Concept statement v0.1.
4. `T3-3`: Reference field: T3 mission, 2025 program, comparable urban photo works.
5. `T3-4`: Shot / material acquisition plan.
6. `T3-5`: PQG concept review before production sprint.
