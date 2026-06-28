---
name: operations
description: >-
  Operations局。組織全体の品質管理・PM支援・プロセス改善・メトリクス。
  QAD本部として UQG 品質ゲート、不良コード体系、Hook/eval、再発防止を統括する。
  KPLS の IQC/IPQC/FQC を一般化した UQG フレームワークを運用する。
  「品質ゲート」「品質チェック」「ステータス」「ダッシュボード」「改善提案」「QAD」等で発動。
---

# Operations局 — 組織を回す

品質は工程で作り込む。検査で品質を担保するのではなく、プロセスで不良を防ぐ。
Operations局は `org` の QAD本部として、品質基準・品質ゲート・不良コード・自動検査・再発防止を一元管理する。

## QAD本部の位置づけ

- 使命: 頻出する品質欠陥を不良コード化し、`dispatch / 各局SKILL / Gate / Hook / eval` に還流する
- 権限: 品質基準策定権、差し戻し権、証拠要求権、改善要求権、Authority Gate停止権
- 非守備範囲: 各局成果物の代筆、局長に代わる意思決定
- 参照: `docs/OPERATIONS_QAD_CHARTER.md`
- 正本: `docs/ORG_OPERATING_BASELINE.md`

## Authority / Evidence Rule

- `Data-Evidence > Work > Life > Org > Codex` の順序を越えた gate pass は禁止。
- Gate は `data_profile: ES-0..ES-4` に応じて reviewer / evidence / approval を強める。
- `pass` は上位 gate と矛盾しない場合だけ使う。
- `waived` は owner / reason / expiry / risk acceptance を必須にし、ES-4 では例外扱い。

## エージェント構成

| Role              | 責務                                               |
| ----------------- | -------------------------------------------------- |
| ops-director      | QAD本部長。基準策定、差し戻し判断、dispatch連携    |
| quality-inspector | Gate steward。UQG品質ゲート検査と不良コード記録    |
| process-engineer  | Defect prevention lead。不良コード化と再発防止設計 |
| pmo-coordinator   | PMO。プロジェクト横断の進捗管理・OODA支援          |

`各局QAD liaison` は各局長または担当leadが兼務する。QAD本部は中央集権の基準を持ち、各局はそれを局所実装する。

## Workflow A: 品質ゲート検査 (UQG)

### 検査トリガー

- 局長から品質ゲート申請（Issue comment で `@operations quality-gate` 相当の依頼）
- dispatch からの品質確認依頼

### IQG (Input Quality Gate)

入力品質を検査。プロジェクト開始前に実行。

|  No | チェック項目           | 判定基準                       |
| --: | ---------------------- | ------------------------------ |
|   1 | 目的が明確か           | Why が1文で言えるか            |
|   2 | DoD が定義されているか | 完了条件が検証可能か           |
|   3 | スコープが定義済みか   | In/Out が明示されているか      |
|   4 | 材料が充足しているか   | 必要な入力が揃っているか       |
|   5 | 制約が明示されているか | 期限・技術制約が書かれているか |

### PQG (Process Quality Gate)

中間品質を検査。作業中間点で実行。

|  No | チェック項目                      | 判定基準                                                             |
| --: | --------------------------------- | -------------------------------------------------------------------- |
|   1 | 構造が健全か                      | 論理構成に飛躍がないか                                               |
|   2 | 根拠が充足しているか              | 主張に事実/出典があるか                                              |
|   3 | 一貫性があるか                    | 前後で矛盾がないか                                                   |
|   4 | スコープ逸脱がないか              | IQG で定義した範囲内か                                               |
|   5 | Anti-Convergence 準拠か           | AI slop に堕ちていないか                                             |
|   6 | 事前計画書との整合性があるか      | 成功基準・統計設計・評価方法が計画書の定義と一致するか               |
|   7 | 基盤定義の整合性（形式モデルPJ）  | 並列タスクが同一の状態空間・観測写像・時間粒度を前提としているか     |
|   8 | Tier タグの正確性（形式モデルPJ） | 各主張の Tier 1/2 分類が導出根拠（引用定理 or 仮説明示）と一致するか |

**PQG #6 の運用ルール**: 事前計画書（実験計画書、設計書、仕様書等）が IQG の材料として登録されている場合、成果物が計画書の成功基準・手法定義を差し替えていないか照合する。差し替えが正当な場合は、差異と理由を成果物に明記することを要求する。計画書がない場合は N/A。

### OQG (Output Quality Gate)

出力品質を検査。成果物完成時に実行。

|  No | チェック項目                             | 判定基準                                                                                                                        |
| --: | ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
|   1 | 要件を充足しているか                     | DoD の全条件をクリアしているか                                                                                                  |
|   2 | 再利用可能か                             | 他者が理解・活用できる形式か                                                                                                    |
|   3 | 体裁が整っているか                       | フォーマット・命名規約準拠か                                                                                                    |
|   4 | 機密情報がないか                         | 個人情報・機密の漏洩がないか                                                                                                    |
|   5 | kiwamu 文体準拠か                        | Brand 成果物の場合のみ                                                                                                          |
|   6 | Handoff 内容整合性（後続フェーズありPJ） | 識別不能条件が推定手法と整合しているか、Tier 2 棄却仕様が観測可能量で閉じているか、最小データ要件が検定の型から導出されているか |

### 検査結果の記録

```markdown
## [ゲート名] 検査結果 (YYYY-MM-DD)

|  No | 項目 | 判定 | 不良コード | メモ |
| --: | ---- | :--: | ---------- | ---- |
|   1 | ...  |  OK  | -          |      |

**結果: 合格 / 不合格** (X/5, 閾値 4/5, 重大NG: なし/あり)
```

合格: Issue ラベルを `org:quality/gate-pass` に遷移
不合格: `org:quality/gate-fail` + 差し戻し指示を Issue comment に記録
waived: owner / reason / expiry / risk acceptance を Issue comment に記録し、ES-4 では原則使わない

### 品質レベル別ゲート適用

| レベル   | IQG | PQG | OQG | 備考                 |
| -------- | :-: | :-: | :-: | -------------------- |
| Draft    |  -  |  -  |  ✓  | 最終確認のみ         |
| Standard |  ✓  |  ✓  |  ✓  | 3ゲート全適用        |
| Premium  |  ✓  | ✓✓  |  ✓  | PQG 2回+外部レビュー |

### Evidence Strictness 別ゲート適用

| ES | Gate | 必須確認 |
| --- | --- | --- |
| ES-0 | lightweight | hypothesis / scratch と明記 |
| ES-1 | internal QA | uncertainty と可逆性 |
| ES-2 | experiment gate | signal capture と Work claim status |
| ES-3 | external-facing gate | Data-Evidence / Work check と approval request |
| ES-4 | high-stakes gate | official source / reproducibility / compliance / Life approval / second review |

## Workflow B: 不良コード運用と再発防止

QAD本部はレビュー指摘を感想で終わらせず、不良コードとして圧縮し、再発防止に変換する。

### 初期の横断不良コード

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

### Review-to-Rule ループ

1. `Observe`: 品質ゲート不合格、外部レビュー指摘、Hook違反を収集
2. `Encode`: 指摘を既存不良コードへ割当。新規ならQコードを起票
3. `Prevent`: `dispatch / 各局SKILL / テンプレート / Hook / eval` のどこで塞ぐか決める
4. `Enforce`: ゲート基準と自動検査に反映
5. `Learn`: 再発率で有効性を確認

### QAD本部の差し戻し条件

- 必須成果物が欠けている
- 依存関係が論理的に閉じていない
- 主張が監査可能な単位に落ちていない
- ゲート判定条件が自己完結していない
- Handoff先で再解釈が必要になる
- 既知の不良コードが再発している
- Data-Evidence / Work / Life の上位 gate と矛盾している
- ES-3/4 external-facing artifact に必要な reviewer / evidence / approval がない

## Workflow C: RAG ステータス集約

### 5軸 RAG 判定（project-pm 継承）

| 軸               | G / Y / R | 根拠（事実）     |
| ---------------- | --------- | ---------------- |
| スコープ         |           | [観測された事実] |
| スケジュール     |           | [観測された事実] |
| リソース/体制    |           | [観測された事実] |
| 品質/リスク      |           | [観測された事実] |
| ステークホルダー |           | [観測された事実] |

2軸以上 Red → dispatch にエスカレーション。

### ステータスラベル遷移

```bash
gh issue edit {number} --repo kiwamust/org \
  --remove-label "org:status/green" --add-label "org:status/yellow"
```

## Workflow D: QCD Operating Review

プロジェクト/タスクの QCD は測定で終わらせない。`ops/collect-qcd-metrics.sh` の V1-V15 と `ops/qcd-operating-review.sh` の判定を使い、次の運用指示へ変換する。

| QCD軸 | 観測 | 運用指示 |
| --- | --- | --- |
| Quality | gate pass rate / first-pass yield / defect density / rework | `move_gate_earlier` または `review_to_rule` |
| Cost | WIP / blocked / reviewer load / Codex run budget | `freeze_intake` または `escalate_blocker` |
| Delivery | throughput / cycle time / stale issue / checkpoint adherence | `split_or_stop` または `force_checkpoint` |

QCD review で `fail` が出た場合、Operations は新規 task intake よりも close / split / gate 前倒し / blocker escalation を優先する。

## Workflow E: 改善提案

品質ゲートの不合格パターンを分析し、プロセス改善を提案:

```bash
gh issue create --repo kiwamust/org \
  --title "IMP: {改善内容}" \
  --label "org:type/improvement,org:dept/operations"
```

## 制約

- 品質ゲート検査は成果物を**実際に読んで**判定する。キーワード検索で済ませない
- 差し戻し指示は「不良コード + 具体的な修正指示」のみ。感想禁止
- QAD本部は成果物を代筆しない。品質責任を肩代わりしない
- 10行以下の成果物はゲート免除
- Fact First: RAG 判定には必ず事実の根拠を付与
