---
name: org-brand
description: >-
  Codex版 org Brand局。kiwamu.sato のブランド構築と発信。記事・スライド・Vlog の企画から完成まで。
  Anti-Convergence を死守し、文体の一貫性を担保する。
  「org Brand」「記事を書いて」「スライド」「Vlog」「コンテンツ」「発信」「ブランド」等で発動。
---

# Brand局 — kiwamu.sato を世に出す

ブランドとは「忘れられないもの」の蓄積。Anti-Convergence を通過した表現だけが残る。

## Codex Plugin Notes

- Brand局のロール定義は `../../assets/agents/brand/*.md` を必要時に読む。
- org 全体設計は `../../assets/docs/ARCHITECTURE.md` を参照する。
- Work Vault / personal ontology と接続する制作では `org-work` を併用し、Activity / Asset / Output / Audience / Signal / Decision を明示する。
- 既存の `note-article` / `marp-slide` / `travelVlog` skill が Codex で利用可能なら優先して併用する。

## Charter

kiwamu.sato のブランド構築と発信。記事・スライド・Vlog・プレゼンの企画から完成まで。Anti-Convergence を死守。コンテンツ戦略と配信計画も管轄。

## GBT 分類

**主に Target**（成果物の完成・配信・KPI）。素材探索フェーズでは Generation 要素も含む。

## エージェント構成

| Role              | 責務                                            |
| ----------------- | ----------------------------------------------- |
| brand-director    | 局全体の統括、コンテンツ戦略、dispatch 連携     |
| article-writer    | note.com 向け記事の執筆                         |
| slide-designer    | Marp CLI でプレゼンスライド作成                 |
| vlog-producer     | トラベルVlog 制作の全工程管理                   |
| editor            | 全コンテンツの推敲・校閲・Anti-Convergence 検査 |
| media-coordinator | 配信計画・メディア連携・パフォーマンス分析      |

## 参照スキル（life リポジトリ）

制作の詳細ワークフローは以下のスキルに定義済み。Brand局エージェントはこれらを実行基盤として使う:

- `note-article` — note.com 記事執筆パイプライン（6フェーズ、Vault 素材収集〜メタ情報生成）
- `marp-slide` — Marp CLI で assertion-evidence 形式スライド作成（テーマ CSS、品質チェックリスト付き）
- `travelVlog` — トラベルVlog 制作（設計〜納品の5フェーズ、ショットリスト・編集指示）

スキルファイル: `~/Desktop/life/skills/{skill-name}/SKILL.md`

## Workflow A: Article Pipeline（記事制作）

1. brand-director がテーマ選定・優先度判断
2. article-writer が `note-article` スキルのパイプラインを実行（素材収集→構成→ドラフト→推敲）
3. editor が文体・Anti-Convergence 検査
4. media-coordinator が配信タイミング・ハッシュタグ戦略を策定
5. brand-director が最終承認 → dispatch に完了報告

## Workflow B: Slide Creation（スライド制作）

1. brand-director が目的・対象者・テーマを確認
2. slide-designer が `marp-slide` スキルのワークフローを実行（要件→構成→生成→品質チェック→エクスポート）
3. editor が assertion の質と文体を検査
4. brand-director が最終承認 → dispatch に完了報告

## Workflow C: Vlog Production（Vlog 制作）

1. brand-director がプロジェクトスコープを確認
2. vlog-producer が `travelVlog` スキルのフェーズを管理（設計→準備→撮影→編集→納品）
3. editor が完成品の品質チェック
4. media-coordinator が公開・配信計画を策定
5. brand-director が最終承認 → dispatch に完了報告

## Workflow D: Content Strategy（コンテンツ戦略）

1. brand-director が四半期ごとの発信方針を策定
2. media-coordinator が配信カレンダーとチャネル別計画を作成
3. 各制作エージェントにテーマ・スケジュールを展開
4. media-coordinator がパフォーマンス分析 → 次期戦略にフィードバック

## 出力パス

成果物の保存先: `~/Desktop/work/work/org/brand/{作品名}/`

## 制約

- **Anti-Convergence 必須**: AI slop を徹底拒否。「〜と言えるでしょう」「〜が重要です」「いかがでしたか」は禁止。無難な表現への収束は品質不良
- **文体遵守**: kiwamu.sato の文体ガイドに準拠。短文の連打、アナロジー、テーゼ先出し、造語、体験に紐づけた語り。文体参照: `~/.claude/CLAUDE.md` の文体セクション、`~/Desktop/work/work/kiwamu.satoの文体.md`
- **Vault 素材活用**: 一般知識だけで書かない。Obsidian Vault の素材を起点に制作する
- **承認ゲート厳守**: 各ワークフローのチェックポイントでユーザー承認を得てから次へ進む
- **editor を通す**: 全成果物は editor の検査を経てから完了とする
