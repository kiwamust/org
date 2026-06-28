# Operations QAD本部 Charter v0.1

## 目的

Operations局のQAD本部は、`org` の成果物品質を個人の巧拙や事後レビューへの依存で担保するのではなく、`工程設計・品質基準・自動検査・再発防止` によって制度化するために存在する。

QAD本部は事後的なダメ出し機関ではない。各局の成果物が最初から崩れにくい構造で生成されるようにするための中枢である。

## ミッション

1. 頻出する品質欠陥を `不良コード` として体系化する。
2. 不良コードを `dispatch / 各局SKILL / Gate / Hook / eval` に還流し、再発を防止する。
3. 品質判定を感想ではなく、`構造・根拠・検証可能性` に基づいて行う。
4. 外部レビューを依存先ではなく学習源として扱う。

## 守備範囲

- 品質基準の定義と更新
- 不良コード体系の管理
- UQG (`IQG / PQG / OQG`) の設計と運営
- Hook / 自動構造チェック / eval の設計
- レビュー指摘の収集、分類、再発防止策への変換
- 各局QAD liaison の運用設計と支援
- 品質メトリクスの観測と改善提案
- QCD operating review による intake freeze / gate 前倒し / task split / stop 判断

## 権限

1. `品質基準策定権`
   何を品質不良とみなすかを定義できる。
2. `差し戻し権`
   PQG / OQG において、基準未達の成果物を不合格にできる。
3. `証拠要求権`
   各局に対して、主張の根拠、依存関係、検証条件、成果物テンプレートの充足状況を要求できる。
4. `改善要求権`
   頻出不良に対して、SKILL、テンプレート、Hook、ゲート基準の改訂を要求できる。

5. `Authority Gate停止権`
   Data-Evidence / Work / Life の上位判断と矛盾する成果物を gate pass にしない。

## 非守備範囲

- 各局成果物の代筆
- 局長や担当者に代わる意思決定
- 内容の正しさを無条件に保証すること
- 品質基準なしの感想レビュー

品質の実装責任は各局に残る。QAD本部はそれを肩代わりしない。

## 成果物

- `QAD Charter`
- `Defect Taxonomy`
- `Gate Criteria`
- `Hook Spec`
- `Review-to-Rule Log`
- `Quality Metrics Report`
- `各局向けQAD適用ガイド`

## 品質判定原則

- `Fact First`: 判定には必ず観測可能な根拠を付ける
- `Structure Over Impression`: 印象ではなく構造欠陥として扱う
- `Prevention Over Inspection`: 事後検査より生成時の制約注入を優先する
- `No Ambiguous Pass`: 基準未達を曖昧に通さない
- `Regression Is Failure`: 一度封じた不良の再発を制度不備として扱う
- `Authority-Aware`: Data-Evidence > Work > Life > Org > Codex の順序を越えた gate pass を禁止する
- `Strictness-Aware`: ES-0..ES-4 に応じて要求 evidence と reviewer を変える

## Evidence Strictness 対応

| ES | QAD gate | 必須確認 |
| --- | --- | --- |
| ES-0 | lightweight | hypothesis / scratch と明記されている |
| ES-1 | internal QA | uncertainty と可逆性が記録されている |
| ES-2 | experiment gate | signal capture と Work claim status がある |
| ES-3 | external-facing gate | Data-Evidence / Work check と approval request がある |
| ES-4 | high-stakes gate | official source / reproducibility / compliance / Life approval / second review がある |

Gate status は `pending|pass|fail|waived`。`waived` は owner / reason / expiry / risk acceptance を必須にし、ES-4 では例外として扱う。

## Hub-and-Spoke 構造

- `Operations / QAD本部`
  - 基準策定
  - 横断監査
  - ゲート運営
  - Hook / eval 管理
  - 不良コード管理
- `各局QAD liaison`
  - 局内成果物への基準適用
  - ゲート前自己点検
  - 局固有の不良パターンの収集
  - 本部への不良コード起票

QAD liaison は各局の局長または担当leadが兼務する。独立した小さな品質部門を各局に複製しない。

## 初期の横断不良コード

| コード | 不良内容                   |
| ------ | -------------------------- |
| Q01    | 基盤定義欠落               |
| Q02    | 依存関係未閉包             |
| Q03    | DoD の非自己完結           |
| Q04    | Claim / Tier 監査不能      |
| Q05    | 契約と暫定メモの混線       |
| Q06    | Handoff Package 不完全     |
| Q07    | 合流タスクの依存矛盾       |
| Q08    | ゲート判定条件の非自己完結 |

## 運用サイクル

1. `Observe`
   レビュー指摘、差し戻し理由、Hook違反、再発事例を収集する。
2. `Encode`
   指摘を不良コードへ圧縮する。
3. `Prevent`
   SKILL、テンプレート、チェックリスト、Hookに反映する。
4. `Enforce`
   ゲートと自動検査で適用する。
5. `Learn`
   再発率と検出率を見て、基準を更新する。

## QCD Operating Review

QAD本部は `ops/collect-qcd-metrics.sh` の V1-V15 と `ops/qcd-operating-review.sh` の判定を使い、QCD を次の実行判断へ戻す。

| QCD軸 | 観測 | 判断 |
| --- | --- | --- |
| Quality | gate pass rate, first-pass yield, defect density, rework | pass rate <80% または rework >20% なら gate を前倒しし、Review-to-Rule を起票する |
| Cost | WIP, blocked, reviewer load, Codex run budget | WIP 超過または blocker 発生時は new task intake を止め、close / split / escalate を優先する |
| Delivery | throughput, cycle time, stale issue, target checkpoint | stale >0 または cycle time 長期化時は scope cut / task split / stop を選ぶ |

QCD review の出力は感想ではなく、`freeze_intake`, `move_gate_earlier`, `split_or_stop`, `escalate_blocker`, `continue` のいずれかの運用指示に落とす。

## 発足時の優先対象

- 状態空間や基盤定義の欠落
- 依存関係の未閉包
- DoD の非自己完結
- Tier運用の未操作化
- 契約と暫定メモの混線
- Handoff不足
- 合流タスクの依存矛盾

## 差し戻し条件

以下のいずれかを満たす場合、QAD本部は差し戻す。

- 必須成果物が欠けている
- 依存関係が論理的に閉じていない
- 主張が監査可能な単位に落ちていない
- ゲート判定条件が自己完結していない
- Handoff先で再解釈が必要になる
- 既知の不良コードが再発している
- Data-Evidence / Work / Life の上位 gate と矛盾している
- ES-3/4 external-facing artifact に必要な reviewer / evidence / approval がない
