---
name: emergingtech
description: >-
  EmergingTech局。新技術の探索・評価・プロトタイピング。AI/エージェント技術、DeSci、新規ツールの目利きと組織への統合。
  skill-evolve/skill-creator も管轄。組織自体の進化エンジン。
  「新技術」「技術評価」「プロトタイプ」「DeSci」「スキル改善」「skill-evolve」「tech radar」等で発動。
---

# EmergingTech局 — 組織の進化エンジン

未知の技術を探り、評価し、組織に統合する。探索と実装の「あわい」に立つ局。

## Charter

新技術の探索・評価・プロトタイピング。AI/エージェント技術、DeSci、新規ツールの目利きと組織への統合。skill-evolve / skill-creator もここが管轄。組織自体の進化エンジン。

## GBT Position

Generation と Behavior の「あわい」。未知の価値を探りながら実装する。純粋な調査（Generation）でも純粋な構築（Behavior）でもない。探索と実装を高速に往復する。

## 関連スキル

- `life` リポジトリの `skill-evolve`: スキルの進化・改善サイクル
- `life` リポジトリの `skill-creator`: 新規スキルの設計・eval ループ

## エージェント構成

| Role                 | 責務                                       |
| -------------------- | ------------------------------------------ |
| tech-scout           | 局長。技術動向の監視・評価方針の決定       |
| ai-researcher        | AI/LLM/エージェント技術の深掘り調査        |
| prototype-builder    | 新技術のプロトタイプ実装・MVP構築          |
| desci-explorer       | 分散科学(DeSci)の探索・プロトコル調査      |
| tool-evaluator       | 新規ツール・サービスの評価・導入分析       |
| integration-engineer | 評価済み技術の組織統合・ワークフロー組込み |

## Workflow A: Tech Radar Update（技術評価）

### トリガー

- dispatch からの技術評価依頼
- tech-scout による定期スキャン（月次）
- 他局からの技術相談

### 評価フレームワーク: Adopt / Trial / Assess / Hold

| Ring   | 定義                                 | アクション                          |
| ------ | ------------------------------------ | ----------------------------------- |
| Adopt  | 本番利用推奨。実績あり               | integration-engineer が統合計画策定 |
| Trial  | 限定的に試行。プロトタイプ検証済み   | prototype-builder が PoC 実施       |
| Assess | 調査段階。可能性はあるが未検証       | ai-researcher / tool-evaluator 調査 |
| Hold   | 現時点では不採用。理由を明記して凍結 | 定期的に再評価                      |

### 評価記録

```markdown
## Tech Radar Entry: {技術名} (YYYY-MM-DD)

| 項目         | 内容                    |
| ------------ | ----------------------- |
| Ring         | Adopt/Trial/Assess/Hold |
| カテゴリ     | AI/Tool/Protocol/Other  |
| 評価者       | {agent}                 |
| 概要         | ...                     |
| 強み         | ...                     |
| リスク       | ...                     |
| 統合パス     | ...                     |
| 次アクション | ...                     |
```

出力先: `~/Desktop/work/work/org/tech-radar/`

## Workflow B: Prototype Sprint

### タイムボックス: 2週間以内

1. tech-scout が対象技術とスコープを決定
2. prototype-builder が MVP を構築
3. tool-evaluator が実用性を評価
4. 結果を Tech Radar に反映（Ring の昇格 or 降格）

### 成果物

- 動作するプロトタイプ（コード or 設定）
- 技術評価レポート（強み・弱み・統合パスの3点必須）
- Tech Radar エントリの更新

## Workflow C: Skill Evolution（skill-evolve / skill-creator 連携）

### トリガー

- 品質ゲート不合格パターンからスキル改善余地を検出
- 新ワークフロー確立に伴う新規スキル需要
- ユーザーからの直接依頼

### フロー

1. integration-engineer が改善対象スキルを特定
2. `life` リポジトリの `skill-creator` で eval ループを実行
   - with-skill / without-skill 並列テスト → grading → benchmark
3. 改善されたスキルを組織に展開
4. Operations 局の品質ゲートで効果を検証

## Workflow D: DeSci Exploration

### フロー

1. desci-explorer がプロトコル・コミュニティを調査
2. ai-researcher が技術的実現可能性を分析
3. 応用可能性レポートを作成
4. 有望な場合、Prototype Sprint（Workflow B）に昇格

## 不良コード体系（T01-T10）

| コード | 不良内容                            |
| ------ | ----------------------------------- |
| T01    | 評価Ring の根拠が不十分             |
| T02    | 統合パスが未定義                    |
| T03    | プロトタイプがタイムボックス超過    |
| T04    | 既存スタックとの互換性未確認        |
| T05    | セキュリティ/ライセンスリスク未評価 |
| T06    | 再現可能性が担保されていない        |
| T07    | 比較対象（代替技術）の検討が不足    |
| T08    | コスト見積もりが欠落                |
| T09    | スキル eval の benchmark 不足       |
| T10    | DeSci プロトコル調査の網羅性不足    |

## 制約

- 評価は構造化する（Adopt / Trial / Assess / Hold）。印象評価禁止
- プロトタイプは2週間以内。超過する場合はスコープを削る
- 組織への統合パスを必ず提示する。評価だけで終わらせない
- skill-evolve / skill-creator の実行は eval ループ必須。手動作成を許容しない
- 他局の技術相談は dispatch 経由で受け付ける
