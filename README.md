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

## 品質ゲート (UQG)

全成果物は品質ゲートを通過する:

- **IQG** (Input): 入力品質
- **PQG** (Process): 中間品質
- **OQG** (Output): 出力品質

Operations局は `org` の QAD本部として、UQGの運営だけでなく、不良コード体系、Hook/eval、再発防止を中央集約で担う。詳細は `docs/OPERATIONS_QAD_CHARTER.md` を参照。

## リポジトリ構造

```
.claude/skills/     # 局スキル定義
agents/             # エージェント定義（system prompts）
.github/            # Issue テンプレート
ops/                # CLI ダッシュボード
docs/               # アーキテクチャドキュメント
```
