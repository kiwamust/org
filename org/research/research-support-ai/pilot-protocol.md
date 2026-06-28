# Pilot Protocol

Status: v0.1 gate candidate
Created: 2026-06-09
Project: [[org/research/research-support-ai/README]]
Org task: kiwamust/org#25
Readiness gate: kiwamust/org#26

## Pilot Goal

3-5人の候補ユーザーに対して、`文献探索と論点マッピング` が実アウトプットへ転用されるかを観測する。

この文書は、まず1人の実行者で回せる Markdown 入出力プロトコルを定義する。3-5人の外部パイロットは `kiwamust/org#26` の IQG pass 後にだけ開始する。

## Input Form

```yaml
pilot_run:
  id: "rsa-pilot-YYYYMMDD-01"
  user_role: "independent cross-domain practitioner"
  topic: ""
  purpose: ""
  why_now: ""
  intended_output:
    type: "plan|article|research_note|other"
    working_title: ""
    target_audience: ""
    reuse_deadline: ""
  source_set:
    required_sources:
      - source_id: "S1"
        title: ""
        url_or_path: ""
        author_or_publisher: ""
        published_or_updated: ""
        why_included: ""
    optional_sources: []
    excluded_sources: []
  constraints:
    must_include: []
    must_avoid: []
    language: "ja|en|mixed"
    privacy_notes: ""
    time_limit_minutes: 45
  intended_output_use:
    where_reuse_will_be_checked: "plan|article|research_note|other"
    baseline_without_ai_minutes:
    expected_reusable_sections:
      - ""
```

## Output Form

```markdown
# Point Map

## Source Inventory

| source_id | title | author/publisher | date | url/path | role in run | reliability | note |
|---|---|---|---|---|---|---|---|

## Claims

| claim_id | claim | evidence summary | source_ids | confidence | uncertainty | reusable as |
|---|---|---|---|---|---|---|

## Contradictions / Constraints

| point_id | claim_or_assumption_limited | source_ids | implication for user output |
|---|---|---|---|

## Open Questions

| question_id | question | why it matters | next source or action |
|---|---|---|---|

## Point Map

| axis | position A | position B | practical implication |
|---|---|---|---|

## Grounding Spot Check

| sampled_claim_id | source_id | source pointer | supported? | correction needed |
|---|---|---|---|---|

## Reusable Summary

<300-600字で、ユーザーの intended_output に直接転用できる形で書く>
```

## Pilot Steps

1. 候補ユーザーを1人選ぶ。ユーザー像は `分野横断で調べ物をする独立系・越境型の実践者` に寄せる。
2. `first-pilot-run.md` をコピーせず、そのファイル自体に run id を付けて初回記録として埋める。
3. 45分以内で input form を埋める。source set が空、または目的が一般論の場合は開始しない。
4. AI が output form の構造で point map を作る。claim は必ず `source_id` に戻せる単位で書く。
5. 主要 claim から最低5件を sampled claim として grounding spot check に入れる。source pointer は URL、見出し、ページ、段落など追跡可能な位置にする。
6. ユーザーが実アウトプットに転用した箇所を `reuse_trace` としてマークする。転用なしの場合も `none` と記録する。
7. `eval-checklist.md` の required fields を埋め、`kiwamust/org#26` の IQG 入力に回す。

## First Run Capture Path

初回実行の記録先は [[org/research/research-support-ai/first-pilot-run|first-pilot-run]] とする。

## Stop Conditions

- source grounding が追えない
- reusable summary がユーザー目的から外れる
- correction_load が毎回 `rewrite` になる
- 文献探索ではなく一般論生成になっている
- input form が topic / purpose / source_set / constraints / intended_output を欠く
- output form が claim と evidence を混ぜる
