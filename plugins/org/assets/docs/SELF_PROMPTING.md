# Self-Prompting — org が自ら directive 候補を生成する

## 目的

従来の org は `User directive -> dispatch` を入口にしていた。Self-Prompting はこの入口の前段に `Org observation -> prompt candidate` を置く。

これはユーザー承認を不要にする仕組みではない。Org が観測した状態から「次にユーザーへ提案すべき directive」を自ら生成し、承認前の候補として提示する仕組みである。

## 原則

1. **観測が先、提案が後**: Issue、Work Vault、repo docs、quality gate 結果など観測可能な状態だけを材料にする。
2. **候補は directive ではない**: ユーザー承認までは `candidate`。Issue 作成や phase 遷移はしない。
3. **承認ゲート不可侵**: 候補採択、Issue 作成、PJ 起票、最終完了は従来通りユーザー承認を要する。
4. **不確実性を残す**: 観測できない材料は `unknown` として残し、推測で埋めない。
5. **最小前進**: 候補は次に実行可能な一手へ絞る。大きな構想は分割する。

## Self-Prompt Loop

```
Observe
  -> Extract Signals
  -> Generate Directive Candidates
  -> Self-Check With UQG
  -> Present Candidate For Approval
  -> dispatch after approval
```

### 1. Observe

優先して読むもの:

- `kiwamust/org` open Issues: red/yellow、gate-fail、gate-pending、blocked
- Work Vault の org project indexes: link 欠落、decision-log 欠落、quality-gates 欠落
- repo docs: `docs/ARCHITECTURE.md`、`docs/WORK_INTEGRATION.md`
- recent local changes: `git status --short`

### 2. Extract Signals

Signal は「次の directive が必要な事実」である。

| Signal | 条件 | 初期 routing |
| --- | --- | --- |
| Gate recovery | `org:quality/gate-fail` | Operations +該当局 |
| Stalled planning | `org:phase/planning` が長期滞留 | dispatch + PMO |
| Missing link | Issue / Work link の片側欠落 | org-work + Operations |
| Red project | `org:status/red` | Operations escalation |
| Empty state | open Issue がない | Operations intake baseline |

### 3. Generate Directive Candidates

候補は以下の形に固定する。

```markdown
Title: DIR: ...
GBT: generation | behavior | target
Dept: rnd | brand | emergingtech | engineering | operations | cross
Priority: p1 | p2 | p3
Evidence: #issue or file path
Prompt: dispatch が処理できる directive 本文
Approval gate: user approval required before mutation
```

### 4. Self-Check With UQG

候補生成時点の軽量 UQG:

| Gate | Check |
| --- | --- |
| IQG | 目的、DoD、材料、制約のうち観測できたものと unknown が分離されている |
| PQG | Evidence が候補と対応している。Signal と routing に飛躍がない |
| OQG | ユーザーが yes/no で承認または却下できる粒度になっている |

### 5. Present Candidate For Approval

候補提示時は mutation しない。Issue 作成コマンドは「承認後の suggested command」として表示するだけに留める。

## CLI

```bash
bash ops/self-prompt.sh
```

テストや dry-run では TSV を渡せる。

```bash
bash ops/self-prompt.sh --from-file path/to/issues.tsv
```

TSV format:

```text
number<TAB>title<TAB>comma-separated-labels
```

## Codex Skill

Codex plugin では `org-self-prompt` を入口にする。通常は以下の順で使う。

1. `org-self-prompt`: 候補生成
2. ユーザーが候補を承認
3. `org-dispatch`: directive 構造化と体制提案
4. 承認後に Issue 作成

## 禁止事項

- open Issue がないだけでユーザー意図を捏造しない
- 候補生成と同時に Issue を作らない
- Work Vault の confidential 内容を GitHub Issue に引用しない
- dispatch / 局長 / SubAgent の階層を飛ばして担当へ直接実行させない
