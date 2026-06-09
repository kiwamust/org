# Pilot Protocol

Status: draft
Created: 2026-06-09
Project: [[org/research/research-support-ai/README]]

## Pilot Goal

3-5人の候補ユーザーに対して、`文献探索と論点マッピング` が実アウトプットへ転用されるかを観測する。

## Input Form

```yaml
topic:
why_now:
intended_output:
audience:
source_urls:
must_include:
must_avoid:
time_limit_minutes:
```

## Output Form

```markdown
# Point Map

## Source Inventory

| source | role | reliability | note |
|---|---|---|---|

## Claims

| claim | evidence | source | confidence |
|---|---|---|---|

## Contradictions / Constraints

| point | contradicts_or_limits | source | implication |
|---|---|---|---|

## Open Questions

| question | why it matters | next source |
|---|---|---|

## Reusable Summary

<300-600字で、ユーザーの intended_output に直接転用できる形で書く>
```

## Pilot Steps

1. 候補ユーザーを1人選ぶ
2. 20分以内で input form を埋める
3. AI が point map を作る
4. ユーザーが実アウトプットに転用した箇所をマークする
5. `eval-checklist.md` の metrics を埋める

## Stop Conditions

- source grounding が追えない
- reusable summary がユーザー目的から外れる
- correction_load が毎回 `rewrite` になる
- 文献探索ではなく一般論生成になっている
