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
 5 agents  5 agents    5 agents    5 agents    5 agents
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

| レベル   | ゲート                | 用途                 |
| -------- | --------------------- | -------------------- |
| Draft    | OQG のみ              | 簡易タスク、内部メモ |
| Standard | IQG+PQG+OQG           | 標準プロジェクト     |
| Premium  | 全ゲート+複数レビュー | 外部公開・重要成果物 |

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

## 外部連携

- **Obsidian Vault** (`~/Desktop/work/work`): 共有知識基盤。成果物保存先
- **life リポジトリ** (`~/Desktop/life`): 個人タスク管理。直接参照禁止、Vault のみ共有

## コンテキスト管理戦略

- エージェント system prompt: 200行以内
- ネスト深度: 最大2段（dispatch → 局長 → 担当）
- 成果物は生成即永続化（Issue comment or ファイル）
- 局間連携は dispatch 経由。SubAgent は他局の Issue を直接変更不可
