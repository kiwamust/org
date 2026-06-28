# Research Support AI Eval Checklist

Status: v0.1 gate candidate
Created: 2026-06-09
Project: [[org/research/research-support-ai/README]]
PM: [[PM/PJ-C-研究支援AI-MVP/project-charter]]
Org task: kiwamust/org#25
Readiness gate: kiwamust/org#26

## Evaluation Target

`文献探索と論点マッピング` が、実際の企画・文章・研究メモへ再利用できる品質に達しているかを判定する。

## Task Shape

```yaml
task:
  id:
  topic:
  user_goal:
  source_set:
  expected_output:
    - source_inventory
    - point_map
    - claim_evidence_table
    - contradiction_table
    - open_questions
    - reusable_summary
```

## Outcome Checks

| check | pass condition | grader |
|---|---|---|
| source coverage | 重要文献が漏れていない | human |
| citation grounding | 各主要 claim が source に戻れる | deterministic + human |
| point map utility | 論点、対立軸、未解決問いが分離されている | human rubric |
| contradiction handling | 反例・制約・弱い根拠が明示されている | human rubric |
| reuse trace | 企画、文章、研究メモのどこかに転用された | human |
| hallucination control | source にない強い断定がない | human + spot check |

## Required Fields For Each Run

```yaml
pilot_run_id:
input_ref: "org/research/research-support-ai/first-pilot-run.md#input-package"
output_ref: "org/research/research-support-ai/first-pilot-run.md#output-package"
real_output_ref:
time_saved_minutes:
reuse_trace:
  - generated_section:
    reused_in:
    reuse_type: "verbatim|edited|structure_only|idea_only|none"
    note:
grounding_spot_check:
  sampled_claims_count:
  supported_claims_count:
  unsupported_claim_ids: []
  correction_notes: []
correction_load: "none|light|heavy|rewrite"
return_intent: "yes|no|conditional"
return_intent_reason:
```

## Rubric

| score | meaning |
|---|---|
| 0 | 使えない。検索結果の羅列か、根拠が追えない |
| 1 | 一部使えるが、再利用には人間の大幅な補正が必要 |
| 2 | 企画・文章・研究メモの一部に転用できる |
| 3 | そのまま骨子や論点表として使える |

## Capability Evals

難しい素材で能力上限を見る。

- 異分野文献を横断して共通論点を抽出できるか
- 似た概念を混同せずに差分を出せるか
- 主流説と反例を同じ表に置けるか
- 研究目的に不要な情報を捨てられるか

## Regression Evals

毎回壊してはいけない基本動作を見る。

- source URL / title / author / date を保持する
- claim と evidence を混ぜない
- source にない固有名詞を増やさない
- uncertainty を明示する
- reusable summary がユーザー目的に沿っている

## Metrics

| metric | type | note |
|---|---|---|
| time_saved_minutes | quantitative | user estimate |
| reuse_trace | structured | generated section -> real output ref |
| reused_sections_count | quantitative | count from reuse_trace |
| source_grounding_rate | quantitative | grounded claims / total claims |
| grounding_spot_check | structured | sampled claim IDs, support status, correction notes |
| correction_load | ordinal | none / light / heavy / rewrite |
| return_intent | categorical | yes / no / conditional |

## First Task Bank

1. 既存クリップ3-5本から、研究支援AIの評価設計を作る
2. `研究コモンズ再編` 関連ノートから、研究支援AIの勝ち筋・負け筋を抽出する
3. OtoPrism の `moment-anchored chat` を、文献探索UIの anchor pattern に翻訳する

## Gate Minimum For org#26

- Input form contains topic, purpose, source set, constraints, and intended output.
- Output form separates source inventory, claims, evidence, contradictions, open questions, point map, reusable summary, and grounding spot check.
- Eval record contains time saved, reuse trace, grounding spot check, correction load, and return intent.
- No 3-5 person pilot starts before `kiwamust/org#26` records pass / fail / waived.
