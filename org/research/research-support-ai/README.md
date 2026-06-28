# Research Support AI

Status: package v0.1 for IQG
Created: 2026-06-09
Life parent: kiwamust/life#69
org issue: kiwamust/org#23
org task: kiwamust/org#25
readiness gate: kiwamust/org#26
Work PM: [[PM/PJ-C-研究支援AI-MVP/project-charter]]
Scenario: [[AIと日本社会の3ヵ年シナリオ#PW3 研究支援AI MVP]]

## Purpose

研究支援AIを、抽象的な研究OSではなく、まず `文献探索と論点マッピング` の運用プロトタイプとして動かす。

この `org/research/research-support-ai/` は `kiwamust/org` 側の実体作業場である。`PM/PJ-C-研究支援AI-MVP/` は Work Vault 側の進行管理、判定基準、スプリント管理を担う。

## First Use Case

- User: 分野横断で調べ物をする独立系・越境型の実践者
- Job: 複数文献から論点、対立軸、未解決問い、再利用可能な主張を作る
- Output: 企画メモ、文章構成、研究メモへ転用できる論点マップ
- Primary metric: 実際の企画・文章・研究メモへの再利用

## Operating Loop

1. User supplies topic, purpose, and source set.
2. AI builds a source inventory.
3. AI extracts claims, evidence, contradictions, and open questions.
4. AI returns a reusable point map.
5. User marks what was reused in a real output.
6. Eval notes update the rubric and next task bank.

## Current Artifacts

- [[org/research/research-support-ai/eval-checklist|eval-checklist]]
- [[org/research/research-support-ai/pilot-protocol|pilot-protocol]]
- [[org/research/research-support-ai/first-pilot-run|first-pilot-run]]

## Pilot Boundary

- Markdown input/output only. Do not start UI or product-surface work in this package.
- This package is ready for `kiwamust/org#26` inspection, not approved for a 3-5 person pilot until that gate records pass / fail / waived.
- The first run must capture source grounding, reuse trace, correction load, time saved, and return intent.
- Strong claims must point back to source IDs; uncertainty and contradictions must stay visible instead of being smoothed into summary prose.

## Non-Goals

- 全研究工程の自動化
- 論文生成そのもの
- DAO / token / funding mechanism
- 大規模プロダクトUI

## Near-Term Decision

次に作るべきものは UI ではなく、`評価可能な運用プロトタイプ` である。まずは Markdown 入出力で、再利用の痕跡が残る形にする。
