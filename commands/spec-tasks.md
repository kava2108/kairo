---
description: design.md を P0/P1 波形の実装タスクに分解します。各タスクに依存グラフと REQ 受け入れ基準 ID を紐付け、後続の issue-generate へ渡す tasks.md を生成します。
allowed-tools: Read, Write, Edit, AskUserQuestion, TodoWrite
argument-hint: "<feature-name> [-y]"
---

# kairo spec-tasks

`design.md` を実装タスクに分解し、`tasks.md` を生成します。
各タスクに要件 AC-ID（`REQ-NNN-AC-MM`）を紐付け、並列実行可能なタスクを P0/P1/P2 波形で整理します。
生成した `tasks.md` は `/kairo:issue-generate` への入力になります。

# context

feature_name={{feature_name}}
auto_approve={{auto_approve}}
spec_dir=.kairo/specs/{{feature_name}}
requirements_file=.kairo/specs/{{feature_name}}/requirements.md
design_file=.kairo/specs/{{feature_name}}/design.md
tasks_file=.kairo/specs/{{feature_name}}/tasks.md
spec_json=.kairo/specs/{{feature_name}}/spec.json

# step

- $ARGUMENTS がない場合は「引数に feature-name を指定してください（例: /kairo:spec-tasks user-auth-oauth）」と言って終了する
- $ARGUMENTS を解析する：
  - `-y` フラグを確認し auto_approve に設定（デフォルト: false）
  - 最初のトークンを feature_name に設定
- context の内容をユーザーに宣言する
- step2 を実行する

## step2: 前提チェック

- `.kairo/specs/{{feature_name}}/spec.json` を Read してフェーズ情報を確認する
  - `phases.design` が `"approved"` でない場合：
    - 「design.md が未承認です。`/kairo:spec-design {{feature_name}}` を先に実行してください」と表示する
    - AskUserQuestion で確認する：
      - question: "design.md が未承認ですが、続行しますか？"
      - options: ["続行する（draft のまま進める）", "中断する"]
    - 「中断する」が選ばれた場合：終了する
- step3 を実行する

## step3: コンテキスト収集

- `.kairo/specs/{{feature_name}}/requirements.md` を Read する
- `.kairo/specs/{{feature_name}}/design.md` を Read する
- `.kairo/steering/structure.md` を存在する場合に Read する（実装パターン確認用）
- step4 を実行する

## step4: タスク分解

design.md から以下のルールで実装タスクを抽出・生成する：

**分解ルール**:
- DB スキーマ / マイグレーション → 独立タスク（P0）
- 認証・ミドルウェア基盤 → 独立タスク（P0）
- API エンドポイント実装 → DB・Auth タスクに依存（P1 以降）
- UI / フロントエンド → API に依存（P1 以降）
- E2E / 統合テスト → 全実装完了後（最終波形）

**波形判定ルール**:
- 依存タスクがないもの → P0
- P0 の完了を要するもの → P1
- P1 の完了を要するもの → P2
- ...（依存チェーンに従い延長）

各タスクに付与する情報：
- タスク番号（1.1, 1.2, 2.1 など）
- タスク説明
- 実装ステップ（箇条書き、3〜7 項目）
- 要件トレース（`_Requirements: REQ-NNN-AC-MM, ..._`）
- 並列波形（`_Parallel: P0（依存なし）_` または `_Parallel: P1（依存: 1.1, 1.2）_`）
- wave タグ（`[P0]`, `[P1]` など）

- step5 を実行する

## step5: tasks.md の生成

以下の構造で `tasks.md` を Write する：

```markdown
# Implementation Plan: {{feature_name}}

**フィーチャー**: {{feature_description}}
**要件参照**: .kairo/specs/{{feature_name}}/requirements.md
**設計参照**: .kairo/specs/{{feature_name}}/design.md
**作成日**: <現在の日付>

---

## Task List

- [ ] 1. <グループ名（例: インフラストラクチャ基盤）>              [P0]
- [ ] 1.1 <タスク説明>                                          [P0]
  - <実装ステップ 1>
  - <実装ステップ 2>
  - ...
  - _Requirements: REQ-001-AC-1, REQ-001-AC-2_
  - _Parallel: P0（依存なし）_

- [ ] 2. <グループ名（例: コア機能実装）>                         [P1]
- [ ] 2.1 <タスク説明>                                          [P1]
  - <実装ステップ>
  - _Requirements: REQ-002-AC-1_
  - _Parallel: P1（依存: 1.1, 1.2）_

---

## Dependency Graph

\`\`\`mermaid
graph TD
  T1_1[1.1 ...] --> T2_1[2.1 ...]
  T1_2[1.2 ...] --> T2_1
\`\`\`

---

## Parallel Execution Waves

| Wave | Tasks | 前提条件 | 推定工数 |
|------|-------|---------|---------|
| P0 | 1.1, 1.2 | なし | ... |
| P1 | 2.1 | P0 完了 | ... |
```

## step6: タスク→ Issue 変換テンプレートの付与

各タスクに GitHub Issue 生成用テンプレートを spec.json の wave_config に書き込む：

```json
"wave_config": {
  "P0": ["1.1", "1.2"],
  "P1": ["2.1"],
  ...
}
```

## step7: Human Gate（`-y` なし時）

- タスク一覧と波形・依存グラフを提示する
- AskUserQuestion ツールで確認する：
  - question: "このタスク分解を承認しますか？"
  - options: ["承認する", "修正して再提示する", "中断する"]
- 「修正して再提示する」が選ばれた場合：フィードバックを受け取り step4 に戻る
- 「中断する」が選ばれた場合：現状の draft を保存して終了する

## step8: 承認後の更新

- `spec.json` の `phases.tasks` を `"approved"` に更新する

## step9: 完了通知

```
✅ tasks.md を生成しました

.kairo/specs/{{feature_name}}/tasks.md
  - タスク総数: <N> 件
  - P0 タスク: <N> 件（並列実行可能）
  - P1 タスク: <N> 件
  - ステータス: approved
```

次のステップ:
```
/kairo:issue-generate {{feature_name}}
```

> **P0 のみ先行発行を推奨**: `--wave P0` で P0 タスクのみ Issue 化し、
> 実装が進んだ段階で `--wave P1` を実行すると依存管理が容易になります。
