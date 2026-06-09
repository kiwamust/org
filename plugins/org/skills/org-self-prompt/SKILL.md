---
name: org-self-prompt
description: >-
  Codex版 org の self-prompt 入口。ユーザーが都度 directive を直接書かなくても、org が Issues / Work Vault /
  repo docs / quality signals を観測し、次に提案すべき directive 候補を自ら生成する。
  「org 自らプロンプト」「self-prompt」「自己プロンプト」「次のdirectiveを提案」「orgが自走」等で発動。
---

# org-self-prompt — Org が自ら directive 候補を生成する

Org は勝手に実行しない。Org は観測し、次に問うべき directive を提案する。承認後に dispatch が動く。

## Codex Plugin Notes

- 全体設計は `../../assets/docs/ARCHITECTURE.md` を読む。
- Self-Prompting の詳細契約は `../../assets/docs/SELF_PROMPTING.md` を読む。
- 候補生成 CLI は repo root の `ops/self-prompt.sh` を使う。
- Work Vault と接続する候補では `org-work` を併用する。
- 品質・滞留・gate-fail の候補では `org-operations` を併用する。

## Workflow: Observe -> Candidate

### Step 1: 観測

優先順位:

1. `git status --short` で local state を確認
2. `bash ops/self-prompt.sh` を実行し、open Issue から候補を生成
3. 必要に応じて Work Vault / org project index を読む
4. `docs/SELF_PROMPTING.md` の Signal 表に照らして欠落を確認

### Step 2: Candidate 検査

候補は以下を満たす必要がある。

| 項目 | 条件 |
| --- | --- |
| Title | `DIR:` で始まり、1つの directive として扱える |
| Evidence | Issue 番号または file path がある |
| GBT | generation / behavior / target のいずれか |
| Dept | 主担当局が1つに定まる |
| Priority | p1 / p2 / p3 のいずれか |
| Approval | mutation 前のユーザー承認が明記されている |

### Step 3: 提示

ユーザーには最大3件まで提示する。最初の候補には recommendation を付ける。

```markdown
## Self-prompt candidate

Recommendation: adopt / defer / needs more observation
Title:
Evidence:
Why now:
Expected DoD:
Approval needed:
```

### Step 4: 承認後

ユーザーが承認したら `org-dispatch` に渡す。承認前に Issue を作成しない。

## UQG for Self-Prompt

| Gate | Check |
| --- | --- |
| IQG | 観測事実と unknown が分離されている |
| PQG | Evidence -> Signal -> Candidate の因果が閉じている |
| OQG | ユーザーが承認/却下できる粒度で、次の action が明確 |

## Constraints

- 推測でユーザー意図を補完しない
- Issue 作成、label 変更、phase 遷移は承認後のみ
- confidential な Work 内容を Issue 候補本文に引用しない
- 候補生成は dispatch の代替ではない。dispatch の入力を作るだけ
