# Architecture — kiwamust/org

## 設計原則

1. **Issues が真実**: エージェントは揮発する。Issues は残る。全状態を Issues に記録
2. **承認ゲート不可侵**: ユーザー承認なしに工程を進めない
3. **HAAS 階層**: dispatch=SOB層 → 局長=Executive層 → 担当者=SubAgent層。ネスト2段制限
4. **品質ゲート必須**: UQG フレームワークを全局適用
5. **QAD本部の中央集約**: Operations は品質基準・不良コード・Gate・Hook/eval を一元管理
6. **GBT マッピング**: Generation → Behavior → Target の流れで全プロジェクトを構造化
7. **Authority Ladder**: `Data-Evidence > Work > Life > Org > Codex` を越権しない
8. **Evidence Strictness**: `ES-0..ES-4` を issue ごとに設定し、外部性・不可逆性に応じて gate を強める

現在の実行契約の正本は `docs/ORG_OPERATING_BASELINE.md`。本ファイルは構造説明であり、衝突時は baseline を優先する。

## Authority Ladder

```text
Data-Evidence > Work > Life > Org > Codex
```

| Subsystem | 正本にするもの | Org の制約 |
| --- | --- | --- |
| Data-Evidence | observed fact, metric, citation, lineage, confidence, access class | evidence conflict があれば `blocked:evidence_conflict` とし、gate pass にしない |
| Work | ontology, claim, source inventory, artifact meaning | unsupported claim を proposal-ready / publish-ready にしない |
| Life | portfolio priority, continue/stop/defer/integrate, final DoD | Life stop/defer を Org WIP で上書きしない |
| Org | execution plan, role, phase, UQG, WIP, handoff | 上位 gate の範囲内だけで実行を決める |
| Codex | observation, draft, patch, verification proposal | trace / issue / artifact に保存されるまで長期状態にしない |

## Evidence Strictness

| ES | 用途 | Org gate |
| --- | --- | --- |
| ES-0 | private scratch / ideation | lightweight self-check |
| ES-1 | reversible internal decision | internal QA |
| ES-2 | business experiment / lightweight external test | experiment gate + Work check |
| ES-3 | client-facing / public / strategic artifact | QA + Work + Data-Evidence check |
| ES-4 | procurement / legal / research result / financial commitment | Data-Evidence + Work + Life approval + second review |

## HAAS 階層マッピング

```
┌─────────────────────────────────────────┐
│  SOB (dispatch)                         │
│  戦略判断・倫理チェック・リソース配分   │
│  GBT分類 → 部門ルーティング            │
└────────────────┬────────────────────────┘
                 │
    ┌────────────┼────────────┬────────────┬────────────┐
    │            │            │            │            │
┌───▼───┐  ┌───▼───┐  ┌───▼────┐  ┌───▼───┐  ┌───▼───┐
│ R&D   │  │ Brand │  │Emrg   │  │ Eng   │  │ Ops   │
│Director│  │Director│ │Tech   │  │Tech   │  │Director│
│       │  │       │  │Scout  │  │Lead   │  │       │
└───┬───┘  └───┬───┘  └───┬────┘  └───┬───┘  └───┬───┘
    │          │           │           │           │
 5 sub-    5 sub-      5 sub-      5 sub-      5 sub-
 agents   agents     agents     agents     agents
```

## GBT フレームワーク

| GBT フェーズ | 主担当局    | 内容                      |
| ------------ | ----------- | ------------------------- |
| Generation   | R&D         | 価値探索・仮説生成・調査  |
| Behavior     | Engineering | 計画・実装・テスト        |
| Target       | Brand       | 成果物完成・配信・KPI計測 |

EmergingTech は Generation と Behavior の「あわい」。
Operations は Behavior と Target を横断する品質保証層であり、`org` の QAD本部でもある。

## 実行フロー

```
Org self-prompt candidate or User directive
  ↓
[dispatch/SOB] 構造化 → GBT分類 → 部門ルーティング → 体制提案 → ✅ ユーザー承認
  ↓
[dispatch] PJ起票 → タスク分解 → 担当局長(Executive)を Agent で起動
  ↓
[局長/Executive] → [担当エージェント/SubAgent] 実行 → Issue に進捗記録
  ↓
[operations/QAD-HQ] 品質ゲート検査 / 不良コード管理 / 再発防止
  ↓ (合格)
[dispatch] 完了報告 → ✅ ユーザー最終承認
```

Operational issue は次を持つ: `parent_project` or `work_ref`, `data_profile`, `role`, `phase`, `expected_return`, `gate`, `closeout_evidence`, `next_circulation`。

## Self-Prompting 入口

従来の入口は `User directive` のみだった。`org` はこれを拡張し、`Observe -> Extract Signals -> Generate Directive Candidates -> UQG Self-Check -> User Approval` の self-prompt 入口を持つ。

Self-prompt は dispatch の代替ではない。dispatch に渡す前の directive 候補を作るだけであり、候補生成時点では Issue 作成、label 変更、phase 遷移を行わない。

主な signal:

- `org:quality/gate-fail`: gate recovery directive 候補
- `org:status/red`: escalation / recovery directive 候補
- Issue / Work link 欠落: org-work repair directive 候補
- open Issue なし: intake baseline refresh directive 候補

詳細は `docs/SELF_PROMPTING.md` を参照。

## 品質ゲートフレームワーク (UQG)

KPLS の IQC/IPQC/FQC を一般化:

| Gate          | 目的     | 全局共通チェック                 |
| ------------- | -------- | -------------------------------- |
| IQG (Input)   | 入力品質 | 目的明確、材料充足、スコープ定義 |
| PQG (Process) | 中間品質 | 構造健全、根拠充足、一貫性       |
| OQG (Output)  | 出力品質 | 要件充足、再利用性、体裁         |

### 品質レベル

| レベル     | ゲート                           | 用途                         |
| ---------- | -------------------------------- | ---------------------------- |
| Draft      | OQG のみ                         | 簡易タスク、内部メモ         |
| Standard   | IQG+PQG+OQG                      | 標準プロジェクト             |
| Premium    | 全ゲート+複数レビュー            | 外部公開・重要成果物         |
| Scientific | 全ゲート+追加項目+fact-check必須 | 学術研究・定式化プロジェクト |

品質レベルは工程の厚み、Evidence Strictness は claim/evidence の許容不確実性を表す。外部向け artifact は品質レベルだけで通さず、ES-3/4 の上位 gate を確認する。

### Gate Status

| Status | 意味 | 条件 |
| --- | --- | --- |
| pending | 未検証 | next action が明確 |
| pass | 次へ進める | Data / Work / Life と矛盾しない |
| fail | 次へ進めない | remediation task または stop reason がある |
| waived | 条件付きで進める | owner / reason / expiry / risk acceptance がある。ES-4 は例外扱い |

### 不良コード体系

- D01-D34: KPLS 既存（知的生産全般）
- Q01-Q08: QAD本部の横断不良コード（構造・依存・Handoff）
- E01-E10: Engineering 局固有（コード品質）
- R01-R10: R&D 局固有（調査品質）
- B01-B10: Brand 局固有（コンテンツ品質）
- T01-T10: EmergingTech 局固有（技術評価品質）

### QAD本部

Operations局は `hub-and-spoke` で品質制度を運営する。

- `hub`: Operations / QAD本部。品質基準、不良コード、UQG、Hook/eval、回帰防止を管理
- `spoke`: 各局QAD liaison。局内成果物へ中央基準を適用し、不良コードを起票

詳細は `docs/OPERATIONS_QAD_CHARTER.md` を参照。

## GitHub Issues ラベル体系

```
org:dept/{rnd,brand,emergingtech,engineering,operations,cross}
org:type/{directive,project,task,quality-gate,improvement}
org:status/{green,yellow,red}
org:phase/{intake,planning,execute,review,done,blocked}
org:priority/{p1,p2,p3}
org:quality/{gate-pending,gate-pass,gate-fail}
org:gbt/{generation,behavior,target}
```

## TCC（タスク完了チェック）

タスク → `phase:done` 遷移時の軽量品質チェック。UQG とは独立したタスクレベルの完了確認。

|  No | チェック項目 | 判定基準                                  |
| --: | ------------ | ----------------------------------------- |
|   1 | AC 充足      | 完了条件を全て満たしているか              |
|   2 | 成果物参照   | 成果物が Issue comment に参照されているか |
|   3 | スコープ逸脱 | スコープ外の追加作業がないか              |

適用: Standard 以上で自動。Draft はオプション。

## Fact-check フロー

| 品質レベル | fact-check | トリガー                            |
| ---------- | :--------: | ----------------------------------- |
| Draft      |     -      | N/A                                 |
| Standard   |   条件付   | PQG で R-type 不良（R01-R10）検出時 |
| Premium    |     ✓      | PQG 完了後に自動                    |
| Scientific |     ✓      | PQG 完了後に自動（必須）            |

フロー: PQG → (条件判定) → fact-check → OQG

## タスクライフサイクル

タスク close 条件: TCC 合格（Draft 免除） + 親 PJ close。
PJ close 時: dispatch が全子タスクを一括 close。

## WIP Safety Limits

| WIP type | 既定 limit | 超過時 |
| --- | ---: | --- |
| Active parent project | 3 | Life review なしに追加不可 |
| Active Org tasks / pilot | 7 | new task intake を止め、close / merge 優先 |
| ES-3/4 external-facing artifacts | 2 | reviewer / evidence 確保まで追加不可 |
| Codex substantial runs without trace | 0 after grace | trace missing を improvement candidate 化 |

## Safety Hooks

PreToolUse hook (`ops/hooks/pre-gh-check.sh`) で gh コマンドの安全性を検証:

- `--repo kiwamust/org` 強制（cross-repo 防止）
- `gh issue delete` ブロック
- `gh issue close` ワーニング（非ブロック）

## Ops スクリプト

| スクリプト               | 目的                              |
| ------------------------ | --------------------------------- |
| `dashboard.sh`           | 組織ダッシュボード（stale + QCD） |
| `collect-qcd-metrics.sh` | V1-V15 メトリクス自動収集         |
| `calc-project-qcd.sh`    | PJ 別 QCD 計算（D, C, ε, Π）      |
| `resume-project.sh`      | PJ 状態復元（コンテキスト回復）   |
| `audit-org-contract.sh`  | Authority/ES/Issue/WIP 契約監査   |

### データディレクトリ構造（Vault 側）

```
~/Desktop/work/work/org/data/
├── metrics/YYYY-MM-DD.json
├── qcd/project-qcd.csv
├── entropy/entropy-timeseries.csv
└── experiments/<experiment-id>.json
```

## 外部連携

- **Obsidian Vault** (`~/Desktop/work/work`): 共有知識基盤。成果物保存先
- **life リポジトリ** (`~/Desktop/life`): 個人タスク管理。直接参照禁止、Vault のみ共有

## コンテキスト管理戦略

- エージェント system prompt: 200行以内
- ネスト深度: 最大2段（dispatch → 局長 → 担当）
- 成果物は生成即永続化（Issue comment or ファイル）
- 局間連携は dispatch 経由。SubAgent は他局の Issue を直接変更不可
