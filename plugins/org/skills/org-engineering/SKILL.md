---
name: org-engineering
description: >-
  Codex版 org Engineering局。本番品質のソフトウェア開発。ツール構築、自動化スクリプト、DevOps。
  コードの品質と保守性を担保。
  「org Engineering」「コード」「スクリプト」「開発」「実装」「ツール作成」「自動化」「デバッグ」等で発動。
---

# Engineering局 — 本番品質のコードを書く

動くコードではなく、正しいコードを書く。テストが証明し、レビューが担保する。

## Codex Plugin Notes

- Engineering局のロール定義は `../../assets/agents/engineering/*.md` を必要時に読む。
- org 全体設計は `../../assets/docs/ARCHITECTURE.md` を参照する。
- Codex の開発者指示と既存 repo 規約を最優先し、その上に org の TDD・レビュー・不良コード体系を重ねる。

## Charter

本番品質のソフトウェア開発。ツール構築、自動化スクリプト、DevOps。コードの品質と保守性を担保する。

## GBT Position

主に **Behavior**（計画→実装→テスト）。Generation フェーズのプロトタイプ構築も担う。

## エージェント構成

| Role            | 責務                                           |
| --------------- | ---------------------------------------------- |
| tech-lead       | 局長。技術判断・アーキテクチャ設計・タスク分解 |
| backend-dev     | バックエンド開発。Python / API / DB設計        |
| frontend-dev    | フロントエンド開発。UI/UX実装                  |
| devops-engineer | CI/CD・インフラ・自動化                        |
| code-reviewer   | コードレビュー。品質・セキュリティ・保守性     |
| toolsmith       | 社内ツール・スクリプト・CLIツール構築          |

## Workflow A: Development Pipeline（TDD）

### Step 1: 設計（tech-lead）

- 要件を受け、技術選定・アーキテクチャを決定
- タスクを分解し、担当エージェントに割り当て
- インターフェース定義を先に確定させる

### Step 2: テスト先行（担当 dev）

- 実装前にテストを書く。テストが仕様書
- Red → Green → Refactor のサイクルを回す
- テストが通らない状態で次のタスクに進まない

### Step 3: 実装（担当 dev）

- テストを通す最小限のコードを書く
- docstring より comment。Why を書く
- 1関数1責務。長い関数は設計の匂い

### Step 4: レビュー（code-reviewer）

- Workflow B を適用。不良コード検出
- レビュー通過まで merge しない

### Step 5: 検証（devops-engineer）

- CI/CD パイプラインでテスト実行
- カバレッジ・リンター・型チェック通過を確認

## Workflow B: Code Review

### Step 1: 差分確認

- `git diff` で変更範囲を把握
- 変更の意図（Issue / commit message）を確認

### Step 2: 不良コード検出

不良コード E01-E10 を検出する:

| Code | 不良               | 判定基準                                |
| ---- | ------------------ | --------------------------------------- |
| E01  | テスト欠落         | 新規コードにテストがない                |
| E02  | エラー握り潰し     | bare except / pass で例外を無視         |
| E03  | ハードコード       | マジックナンバー / 環境依存値の埋め込み |
| E04  | 過剰複雑性         | 1関数50行超 / ネスト4段以上             |
| E05  | セキュリティ脆弱性 | SQL注入 / 機密情報のハードコード        |
| E06  | 命名不良           | 意味不明な変数名 / 略語の乱用           |
| E07  | デッドコード       | 未使用の import / 関数 / 変数           |
| E08  | 重複コード         | DRY違反。3回以上の同一パターン          |
| E09  | フォールバック実装 | 根本解決ではなく回避策                  |
| E10  | 型不整合           | 型ヒント欠落 / 実行時型エラーリスク     |

### Step 3: レビュー結果記録

```markdown
## Code Review (YYYY-MM-DD)

| #   | ファイル:行 | 不良コード | 指摘内容 | 重大度 |
| --- | ----------- | ---------- | -------- | ------ |
| 1   | ...         | E01        | ...      | H/M/L  |

**結果: 承認 / 要修正** (重大度H: 0件が承認条件)
```

## Workflow C: Tool Building

### Step 1: 要件定義（tech-lead + toolsmith）

- ツールの目的・ユーザー・使用頻度を明確化
- CLI インターフェース（引数、オプション、出力形式）を設計
- 既存ツールとの重複を確認

### Step 2: プロトタイプ（toolsmith）

- 最小動作するバージョンを TDD で構築
- `ops/` ディレクトリに配置

### Step 3: 検証・ドキュメント

- ヘルプメッセージ（`--help`）が self-documenting であること
- エラーハンドリングが適切であること

## Workflow D: Debug（証拠駆動）

`life` リポジトリの `skills/debug/SKILL.md` を参照。Evidence-driven debugging を適用する。

- 推測で修正しない。仮説→計装→再現→証拠分析→最小修正
- Quick Fix 2回失敗 → Full Debug に自動昇格
- 全計装に `[DEBUG-INSTRUMENT]` マーカー必須。残存ゼロで完了
- フォールバック実装（try/except 握り潰し等）は禁止

## Tech Stack

| 項目           | 標準                          |
| -------------- | ----------------------------- |
| 言語           | Python 3.11                   |
| パッケージ管理 | uv                            |
| テスト         | pytest                        |
| 開発手法       | TDD（Red → Green → Refactor） |
| リンター       | ruff                          |
| 型チェック     | mypy / pyright                |
| CI             | GitHub Actions                |

## 制約

- **TDD必須**: テストなしのコードは merge しない
- **コードレビュー必須**: セルフマージ禁止。Workflow B を通す
- **docstring より comment**: Why を書く。What はコードが語る
- **フォールバック実装禁止**: 根本原因に向き合う。回避策は技術的負債
- **本質解決**: 同じバグが2回出たらプロセスを疑う
