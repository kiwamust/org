# kiwamust/org

仮想 AI 組織。Claude Code のサブエージェント機構を「組織」として編成し、GitHub Issues を永続層としてプロジェクトを自律的に遂行する。

## 組織構成

```
dispatch (SOB層)
├── R&D局         — 知を掘る（調査・分析・知識統合）
├── Brand局       — 知を届ける（記事・スライド・Vlog）
├── EmergingTech局 — 未来を拓く（新技術探索・プロトタイプ）
├── Engineering局  — 動くものを作る（開発・DevOps）
└── Operations局   — 組織を回す（QAD本部・品質管理・PMO・改善）
```

## 理論的基盤

- **GBT**: Generation → Behavior → Target の流れでプロジェクトを構造化
- **HAAS**: SOB → Executive → SubAgent の階層的自律エージェント群

## 使い方

directive（指示）を出すと dispatch が GBT 分類 → 部門ルーティング → 体制提案を行う。

```bash
# directive 発行
gh issue create --repo kiwamust/org \
  --template directive.yml \
  --title "DIR: 指示内容"

# ダッシュボード確認
bash ops/dashboard.sh
```

### Self-Prompting

ユーザーが毎回 directive を直接書く代わりに、Org が open Issues / quality gate / Work 連携の状態を観測し、次に提案すべき directive 候補を生成できる。

```bash
bash ops/self-prompt.sh
```

このコマンドは proposal-only。候補生成時点では Issue 作成やラベル変更を行わない。承認後に `org-dispatch` が通常フローで directive を処理する。詳細は `docs/SELF_PROMPTING.md` を参照。

## 品質ゲート (UQG)

全成果物は品質ゲートを通過する:

- **IQG** (Input): 入力品質
- **PQG** (Process): 中間品質
- **OQG** (Output): 出力品質

Operations局は `org` の QAD本部として、UQGの運営だけでなく、不良コード体系、Hook/eval、再発防止を中央集約で担う。詳細は `docs/OPERATIONS_QAD_CHARTER.md` を参照。

品質レベル: Draft / Standard / Premium / Scientific

### TCC（タスク完了チェック）

タスク → `phase:done` 遷移時の軽量3項目チェック（AC充足・成果物参照・スコープ逸脱）。Standard 以上で自動適用。

### Fact-check

品質フロー内の事実検証。Scientific/Premium は PQG 後に必須。Standard は R-type 不良検出時のみ。

## Ops スクリプト

```bash
bash ops/dashboard.sh                    # 組織ダッシュボード
bash ops/collect-qcd-metrics.sh          # V1-V15 メトリクス収集
bash ops/calc-project-qcd.sh --project 1 # PJ 別 QCD 計算
bash ops/resume-project.sh 1             # PJ 状態復元
```

### データ保存先（Vault 側）

```
~/Desktop/work/work/org/data/
├── metrics/YYYY-MM-DD.json      # V1-V15 メトリクス
├── qcd/project-qcd.csv          # PJ 別 QCD 値
├── entropy/entropy-timeseries.csv
└── experiments/<id>.json
```

## Safety Hooks

PreToolUse hook で gh コマンドの安全性を検証:

- `--repo kiwamust/org` 強制（cross-repo 防止）
- `gh issue delete` ブロック
- `gh issue close` ワーニング（非ブロック）

## タスクライフサイクル

タスク close の条件: TCC 合格 + 親 PJ close。PJ close 時に dispatch が子タスクを一括 close。

## リポジトリ構造

```
.claude/skills/     # 局スキル定義
agents/             # エージェント定義（system prompts）
.github/            # Issue テンプレート
ops/
├── dashboard.sh           # CLI ダッシュボード（stale issues + QCD サマリ）
├── collect-qcd-metrics.sh # V1-V15 メトリクス自動収集
├── calc-project-qcd.sh    # PJ 別 QCD 計算
├── resume-project.sh      # PJ 状態復元
└── hooks/
    └── pre-gh-check.sh    # gh コマンド安全性検証（PreToolUse hook）
docs/               # アーキテクチャドキュメント
```
