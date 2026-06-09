# Work Integration

org と Work Obsidian Vault / personal ontology の接続契約。

## Principle

- GitHub Issues: 状態、承認、進捗、品質ゲートの正。
- Work Vault: 知識、素材、成果物、personal ontology の正。
- org plugin skills: 実行手順の正。
- Life Issues: portfolio / parent project の正。

混ぜない。必ずリンクする。

## Canonical Paths

- Work Vault: `/Users/kiwamusato/Work/work`
- org artifacts in Work: `/Users/kiwamusato/Work/work/org/`
- personal ontology: `/Users/kiwamusato/Work/work/_ontology/kiwamu-operating-ontology/`
- Desktop mirror candidate: `/Users/kiwamusato/Desktop/work/work`

`/Users/kiwamusato/Work/work` を canonical とする。Desktop 側は参照候補に留める。

## Issue Granularity

| Granularity | System | Rule |
| --- | --- | --- |
| Parent project | Life Issue (`kiwamust/life`) | 90日以上、life portfolio 優先度、最終DoD、最終承認 |
| Execution task / quality gate | org Issue (`kiwamust/org`) | 独立DoD、担当org role、成果物、レビューまたは品質ゲートがある |
| Working note / draft | Work Vault | 探索、素材、非公開情報、下書き、成果物 |

org Issue にする条件:

1. clear DoD がある。
2. responsible org role / department がある。
3. artifact または gate result がある。
4. 独立して phase / status を追う価値がある。

数十分の探索、下書き、仮説メモは Work に置く。Issue にする場合は親 Issue の checklist で足りるか先に確認する。

## Confidentiality

非公開情報は Work に閉じる。GitHub Issue には引用しない。private repo でもこの分離を守る。

```md
Confidential source:
- Work: org/brand/{slug}/confidential-brief.md
- Do not quote confidential details in GitHub Issues.
```

## Bidirectional Contract

Issue body must include:

- Life parent Issue, when applicable
- Vault index
- Source notes
- Output directory
- Ontology mapping: Activity / Asset / Output / Audience / Signal / Decision

Vault project index must include:

- Life parent Issue, when applicable
- GitHub Issue
- Status
- Charter
- Ontology mapping
- Artifacts
- Decision log
- Quality gates

## Folder Convention

| Type | Work folder |
| --- | --- |
| R&D | `/Users/kiwamusato/Work/work/org/research/{slug}/` |
| Brand / artwork | `/Users/kiwamusato/Work/work/org/brand/{slug}/` |
| Engineering | `/Users/kiwamusato/Work/work/org/engineering/{slug}/` |
| Operations | `/Users/kiwamusato/Work/work/org/operations/{slug}/` |
| Cross | `/Users/kiwamusato/Work/work/org/projects/{slug}/` |

Recommended files:

- `index.md`
- `project-charter.md`
- `decision-log.md`
- `quality-gates.md`
- `sources.md`
- `handoff.md`

## Quality Gate Additions

| Gate | Work-linked check |
| --- | --- |
| IQG | Source notes listed; ontology mapping complete; output directory defined |
| PQG | Claims cite source notes; decisions mirrored between Issue and Vault |
| OQG | Output has audience; reusable assets identified; final artifact stored under Work |

## Known QCD Label Mismatch

The current Work note `org/research/qcd-thermodynamics/04-experiment-design.md` uses `org:phase/active` and `org:status/active`.
The actual org label system uses `org:phase/execute` and `org:status/{green,yellow,red}`.

Before Path C data collection, normalize the metric definitions:

- active project phase = `org:phase/execute`
- WIP = open issues with `org:phase/execute`
- RAG status = `org:status/green|yellow|red`

## Recommended Structures

### T3 2026 Photo Artwork

```text
Life Issue
└── PJ: T3 2026 Photo Artwork

org Issues
├── TASK: T3 source-note map
├── TASK: T3 confidential brief ingestion
├── TASK: T3 concept statement v0.1
├── TASK: T3 shot/material plan
└── QG: T3 concept PQG-1

Work
└── org/brand/t3-2026-photo-work/
    ├── index.md
    ├── confidential-brief.md
    ├── source-map.md
    ├── concept-v0.1.md
    ├── shot-plan.md
    └── decision-log.md
```

### Project Thermodynamics / QCD

```text
Life Issue
└── PJ: Project Thermodynamics Path C

org Issues
├── TASK: QCD Path C metric normalization
├── TASK: QCD Path C collector
├── TASK: QCD Path C baseline run
└── QG: QCD Path C IQG

Work
└── org/research/project-thermodynamics/
    ├── index.md
    ├── project-charter.md
    ├── decision-log.md
    ├── quality-gates.md
    └── path-c/
```
