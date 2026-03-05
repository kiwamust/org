# Architecture — kiwamust/org

## 設計原則

1. **Issues が真実**: エージェントは揮発する。Issues は残る。全状態を Issues に記録
2. **承認ゲート不可侵**: ユーザー承認なしに工程を進めない
3. **HAAS 階層**: dispatch=SOB層 → 局長=Executive層 → 担当者=SubAgent層。ネスト2段制限
4. **品質ゲート必須**: UQG フレームワークを全局適用
5. **GBT マッピング**: Generation → Behavior → Target の流れで全プロジェクトを構造化

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
Operations は Behavior と Target を横断する品質保証層。

## 実行フロー

```
User directive
  ↓
[dispatch/SOB] 構造化 → GBT分類 → 部門ルーティング → 体制提案 → ✅ ユーザー承認
  ↓
[dispatch] PJ起票 → タスク分解 → 担当局長(Executive)を Agent で起動
  ↓
[局長/Executive] → [担当エージェント/SubAgent] 実行 → Issue に進捗記録
  ↓
[operations/quality-inspector] 品質ゲート検査
  ↓ (合格)
[dispatch] 完了報告 → ✅ ユーザー最終承認
```

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

### 不良コード体系

- D01-D34: KPLS 既存（知的生産全般）
- E01-E10: Engineering 局固有（コード品質）
- R01-R10: R&D 局固有（調査品質）
- B01-B10: Brand 局固有（コンテンツ品質）
- T01-T10: EmergingTech 局固有（技術評価品質）

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
