# org — 仮想 AI 組織憲章

推測するな、観測せよ。Issues が真実。エージェントは揮発する、Issues は残る。

## 思想的源流

- **GBT Agent Swarm**: Generation（価値探索）→ Behavior（計画・実行）→ Target（成果物・KPI）。物理学的フレームワークでプロジェクトを最適化
- **HAAS**: 階層的自律エージェント群。SOB → Executive → SubAgent の権限サブセット化

## 組織構成

| 層        | 実体                    | 権限                                               |
| --------- | ----------------------- | -------------------------------------------------- |
| SOB       | dispatch スキル         | 全局への指示権、リソース配分、エスカレーション判断 |
| Executive | 各局長（\*-director等） | 自局内のタスク分解・割当・品質判断                 |
| SubAgent  | 各担当エージェント      | 自タスクの実行・Issue更新・成果物生成              |

### 5局

- **R&D局**: 調査・分析・知識統合。Obsidian Vault を知識基盤に、ファクトベースの知見を供給
- **Brand局**: kiwamu.sato のブランド構築と発信。Anti-Convergence 死守
- **EmergingTech局**: 新技術の探索・評価・プロトタイピング。組織自体の進化エンジン
- **Engineering局**: 本番品質のソフトウェア開発。コードの品質と保守性を担保
- **Operations局**: QAD本部。品質管理・PM支援・プロセス改善・メトリクス。UQG、不良コード、Hook/eval を全局に展開

## 実行フロー

```
User directive → [dispatch/SOB] GBT分類 → 部門ルーティング → ✅ ユーザー承認
→ PJ起票 → タスク分解 → [局長/Executive] → [担当/SubAgent] → Issue に進捗記録
→ [operations/QAD-HQ] 品質ゲート / 不良コード管理 / 再発防止 → ✅ ユーザー最終承認
```

## Authority Ladder / Evidence Strictness

Org の実行判断は `docs/ORG_OPERATING_BASELINE.md` を正本とし、衝突時は必ず次の順序で解決する。

```text
Data-Evidence > Work > Life > Org > Codex
```

- Data-Evidence: observed fact / metric / citation / lineage / confidence / access class の正
- Work: ontology / claim / source inventory / artifact meaning の正
- Life: portfolio priority / continue-stop-integrate-publish / final DoD の正
- Org: execution plan / role / phase / UQG / WIP / handoff の正
- Codex: observation / draft / patch / verification proposal。長期状態の正本ではない

Evidence Strictness は `ES-0..ES-4` で issue ごとに設定する。ES-3/4 の external-facing artifact は Data-Evidence / Work / Life の上位 gate と矛盾してはならない。ES-4 の waiver は原則禁止し、例外は owner / reason / expiry / risk acceptance を必須にする。

## Issue / Gate Contract

Org issue は最低限次を持つ:

- `parent_project` または `work_ref`
- `data_profile: ES-0..ES-4`
- `role`
- `phase`
- `expected_return`
- `gate.type/status/required_evidence`
- `closeout_evidence`
- `next_circulation`

Gate status は `pending|pass|fail|waived`。`pass` は Data-Evidence / Work / Life の上位判断と矛盾しない場合だけ使う。

## WIP Safety Limits

| WIP type | 既定 limit | 超過時 |
| --- | ---: | --- |
| Active parent project | 3 | Life review なしに追加不可 |
| Active Org tasks / pilot | 7 | new task intake を止め、close / merge を優先 |
| ES-3/4 external-facing artifacts | 2 | reviewer / evidence 確保まで追加不可 |
| Codex substantial runs without trace | 0 after grace | trace missing を improvement candidate 化 |

## 承認ゲート（不可侵）

ユーザー承認なしに工程を進めない。以下のポイントで必ず承認を取る:

1. dispatch の体制提案時
2. PJ起票時
3. 品質ゲート結果報告時
4. 最終成果物の納品時

## 品質ゲートフレームワーク (UQG)

| Gate          | 目的     | チェック                         |
| ------------- | -------- | -------------------------------- |
| IQG (Input)   | 入力品質 | 目的明確、材料充足、スコープ定義 |
| PQG (Process) | 中間品質 | 構造健全、根拠充足、一貫性       |
| OQG (Output)  | 出力品質 | 要件充足、再利用性、体裁         |

品質レベル: Draft（OQGのみ）/ Standard（3ゲート）/ Premium（全ゲート+複数レビュー）

Operations局は `hub-and-spoke` の QAD本部として動く。中央で品質基準・不良コード・Gate・Hook/eval を管理し、各局は `QAD liaison` で局所適用する。

## GBT 分類

- `generation`: R&D主導の探索プロジェクト
- `behavior`: Engineering主導の構築プロジェクト
- `target`: Brand主導の配信プロジェクト
- `mixed`: 複数フェーズにまたがる → `org:dept/cross` + 主担当局を指定

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

## 横断不良コード

- `Q01-Q08`: QAD本部の横断不良コード。基盤定義欠落、依存未閉包、DoD非自己完結、Tier監査不能、契約/暫定混線、Handoff不完全、合流依存矛盾、ゲート判定非自己完結を扱う

## 共有知識基盤

- Obsidian Vault: `~/Desktop/work/work`
- 成果物保存先: `~/Desktop/work/work/org/`

```
~/Desktop/work/work/org/
├── projects/PJ-{名}/           # プロジェクト成果物
├── research/{テーマ}/          # R&D局の調査成果物
├── brand/{作品名}/             # Brand局のコンテンツ成果物
├── reports/weekly-YYYY-WXX.md  # Operations局の定型レポート
└── tech-radar/                 # EmergingTech局の技術評価
```

## 制約

- **Issues が真実**: 全状態を Issues に記録。エージェントは揮発する
- **Authority Ladder**: Org は Data-Evidence / Work / Life を上書きしない
- **Evidence Strictness**: 外部性・不可逆性・公開性・調達/法務/研究リスクに応じて ES-0..ES-4 を設定する
- **ネスト2段制限**: dispatch → 局長 → 担当。これ以上深くしない
- **system prompt 200行以内**: 各エージェント定義は簡潔に
- **成果物は即永続化**: コンテキスト消失に備え、成果物は即座に Issue or ファイルに記録
- **life との境界**: リポジトリ物理分離。相互参照禁止。Vault のみ共有
- **ゲート免除**: 10行以下の成果物は品質ゲート免除
- **SubAgent は他局の Issue を直接変更できない**: 局間連携は dispatch 経由

## kiwamu.sato の役割

PM（要所で判断に入る）。ゲート承認と方向転換の判断を担う。
