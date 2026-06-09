---
name: org-work
description: >-
  Codex版 org と Work Obsidian Vault / personal ontology を相互連携する。
  GitHub Issues を状態・承認・進捗の正とし、Work Vault を知識・素材・成果物・personal ontology の正とする。
  「Workと接続」「Vault連携」「personal ontology」「orgプロジェクトをVaultに保存」
  「Vault素材からorgを動かす」「Activity Asset Output Audience Signal Decision」等で発動。
---

# org-work — Work Vault 連携契約

org はプロジェクト実行系。Work は個人知識基盤と成果物保管庫。両者を混ぜない。状態は Issue、知識は Vault、判断は明示的なリンクで接続する。

## Canonical Paths

- Work Vault: `/Users/kiwamusato/Work/work`
- Legacy / mirror candidate: `/Users/kiwamusato/Desktop/work/work`
- org project artifacts in Vault: `/Users/kiwamusato/Work/work/org/`
- personal ontology: `/Users/kiwamusato/Work/work/_ontology/kiwamu-operating-ontology/`

`/Users/kiwamusato/Work/work` を canonical とする。Desktop 側は同名ノートが存在する場合の参照候補に留め、明示指示がない限り書き込まない。

## Boundary

| Layer | Source of truth | Content |
| --- | --- | --- |
| Portfolio / parent project | Life GitHub Issues (`kiwamust/life`) | project ownership, cross-life priority, final DoD, overall RAG, major decisions |
| Project state | GitHub Issues (`kiwamust/org`) | phase, status, assignee, gate result, decisions, blockers |
| Knowledge/assets | Work Vault | source notes, research memos, artwork concepts, drafts, reusable assets |
| Operating ontology | Work `_ontology` | Activity / Asset / Output / Audience / Signal / Decision mapping |
| Executable workflow | org plugin skills | dispatch, R&D, Brand, Engineering, Operations, Work connection rules |

## Issue Granularity

| Granularity | System | Rule |
| --- | --- | --- |
| Parent project | Life Issue | 90+ day horizon, life portfolio priority, final outcome, final approval |
| Execution task / gate | org Issue | independent DoD, role ownership, artifact, review or quality gate |
| Working note / draft | Work Vault | exploration, source material, confidential detail, drafts, artifacts |

Create an org Issue only when the unit has a clear DoD, a responsible org role, an artifact or gate result, and independently meaningful state. Scratch work stays in Work.

## Confidentiality

Confidential or non-public material belongs in Work, not GitHub Issues. For confidential projects, Issues may link to a Work file but must not quote sensitive content.

## Bidirectional Link Contract

Every org project that uses Work should have both:

1. GitHub Issue body with a `Vault` section:
   - `Life parent Issue`, when this is a portfolio-level project
   - `Vault index`: Wikilink-style note name and absolute path
   - `Source notes`: key input notes
   - `Output directory`: destination folder
   - `Ontology mapping`: Activity / Asset / Output / Audience / Signal / Decision
2. Vault project index:
   - `Life parent Issue`, when applicable
   - `GitHub Issue`: URL or issue number
   - `Status`: phase and RAG status
   - `Charter`: purpose, DoD, scope, constraints
   - `Ontology mapping`
   - `Artifacts`
   - `Decision log`
   - `Quality gates`

If either side is missing, create the missing link before advancing the project phase.

## Project Folder Convention

Use stable slugs under `/Users/kiwamusato/Work/work/org/`:

| Project type | Folder |
| --- | --- |
| R&D / research | `research/{slug}/` |
| Brand / artwork / content | `brand/{slug}/` |
| Engineering / tools | `engineering/{slug}/` |
| Operations / governance | `operations/{slug}/` |
| Cross-department | `projects/{slug}/` |

Recommended files:

- `index.md` — project index and bidirectional links
- `project-charter.md` — approved charter
- `decision-log.md` — dated decisions
- `quality-gates.md` — IQG/PQG/OQG results
- `sources.md` — Vault source notes and external references
- `handoff.md` — downstream handoff package when applicable

## Operating Ontology Mapping

For every project, map it into the personal ontology loop:

| Ontology object | Project question |
| --- | --- |
| Activity | What ongoing practice does this project advance? |
| Asset | What reusable knowledge, method, image set, code, or concept is produced? |
| Output | What audience-facing artifact will be shipped? |
| Audience | Who receives or evaluates the output? |
| Signal | What evidence updates the project judgment? |
| Decision | What decision changes the next action? |

Guardrails inherited from Work ontology:

- No concept without output.
- No output without audience.
- No endless preparation.

## Workflows

### A. Intake From Vault

1. Search Work for source notes with `obsidian-search`.
2. Summarize only observed notes; mark gaps as unknown.
3. Produce a project charter with the ontology mapping.
4. Ask for approval before creating or updating GitHub Issues.
5. After approval, create the Issue and Vault project index.

### B. Push org Progress To Work

1. Read the Issue and latest comments.
2. Write or update the Vault `index.md`, `decision-log.md`, and relevant artifact file.
3. Preserve links back to Issue numbers and gate results.
4. Do not overwrite source notes. Append project outputs under `/org/`.

### C. Pull Work Signals Into org

1. Search source notes and project artifact folders.
2. Extract Signals: new evidence, changed concepts, constraints, audience feedback.
3. Convert Signals into Decisions or next tasks.
4. Record decisions in both Issue comment and Vault `decision-log.md`.

## Quality Gate Additions

Operations checks for Work-linked projects:

| Gate | Extra check |
| --- | --- |
| IQG | Source notes are listed; ontology mapping is complete; output directory is defined |
| PQG | Claims cite source notes; decisions are mirrored between Issue and Vault |
| OQG | Output has audience; reusable assets are identified; final artifact is stored under Work |

## Constraints

- Do not mutate existing Vault source notes unless explicitly asked.
- Do not treat AI conversation dumps as primary sources unless the user explicitly includes them.
- Do not let Vault become the status tracker. Status remains in Issues.
- Do not let Issues become the knowledge base. Knowledge and artifacts remain in Work.
