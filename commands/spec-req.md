---
description: EARS 形式の要件定義書（requirements.md）を生成します。Steering 文書とフィーチャー説明をもとに受け入れ基準を構造化します。
allowed-tools: Read, Glob, Write, Edit, AskUserQuestion, TodoWrite
argument-hint: "<feature-name> [-y]"
---

# kairo spec-req

EARS（Easy Approach to Requirements Syntax）形式の要件定義書を生成します。
受け入れ基準に一意の `REQ-NNN-AC-MM` ID を付与し、後続の設計・テスト・drift_check とのトレーサビリティを確保します。

# context

feature_name={{feature_name}}
auto_approve={{auto_approve}}
spec_dir=.kairo/specs/{{feature_name}}
requirements_file=.kairo/specs/{{feature_name}}/requirements.md
spec_json=.kairo/specs/{{feature_name}}/spec.json

# step

- $ARGUMENTS がない場合は「引数に feature-name を指定してください（例: /kairo:spec-req user-auth-oauth）」と言って終了する
- $ARGUMENTS を解析する：
  - `-y` フラグを確認し auto_approve に設定（デフォルト: false）
  - 最初のトークンを feature_name に設定
- context の内容をユーザーに宣言する
- step2 を実行する

## step2: 前提チェック

- `.kairo/specs/{{feature_name}}/spec.json` の存在を確認する
  - 存在しない場合：「先に `/kairo:spec-init {{feature_name}}` を実行してください」と言って終了する
- `spec.json` を Read してフィーチャー情報を取得する
- step3 を実行する

## step3: コンテキスト収集

- `.kairo/steering/structure.md` を存在する場合に Read する
- `.kairo/steering/tech.md` を存在する場合に Read する
- `.kairo/steering/product.md` を存在する場合に Read する
- `.kairo/specs/{{feature_name}}/requirements.md` を Read して既存コンテンツを確認する
- 既存コードベースの関連部分を Glob で確認する（`src/**`, `app/**` など）
- step4 を実行する

## step4: 冪等チェック（既存 requirements.md の確認）

- `requirements.md` に `REQ-001` 以降のIDが含まれているか確認する
  - 含まれている（承認済み仕様が存在）かつ `-y` なし：
    - AskUserQuestion ツールで確認する：
      - question: "既存の requirements.md が見つかりました。上書き生成しますか？"
      - options: ["上書きして再生成する", "既存を表示して終了", "中断する"]
    - 「既存を表示して終了」が選ばれた場合：requirements.md を表示して終了する
    - 「中断する」が選ばれた場合：終了する
  - 含まれていない（スタブのみ）：「新規生成を開始します」と表示する
- step5 を実行する

## step5: 要件の対話的精緻化（`-y` なし時）

- フィーチャーの説明と Steering product.md のプロダクトコンテキストから、主要ユーザーストーリーを 3〜5 件生成して提示する：

  ```
  【候補ストーリー】
  1. As a <role>, I want <action>, so that <benefit>.
  2. ...
  ```

- AskUserQuestion ツールで確認する：
  - question: "このユーザーストーリー一覧で進めますか？追加・修正があれば教えてください。"
  - allowFreeformInput: true
- フィードバックを反映してストーリーを確定させる
- step6 を実行する

## step6: requirements.md の生成

確定したユーザーストーリーをもとに EARS 記法の requirements.md を Write する：

```markdown
# Requirements Document: {{feature_name}}

**ステータス**: draft
**フィーチャー**: {{feature_description}}
**作成日**: <現在の日付>

---

## Introduction

[フィーチャーの目的・対象ユーザー・ビジネスインパクトを記述]

---

## Requirements

### Requirement 1: <機能名>

**Objective**: As a <role>, I want <action>, so that <benefit>.

#### Acceptance Criteria

| AC-ID | EARS 記法 | 優先度 |
|-------|----------|-------|
| REQ-001-AC-1 | WHEN <条件> THEN <システム名> SHALL <動作> | Must |
| REQ-001-AC-2 | IF <条件> THEN <システム名> SHALL <動作> | Must |
| REQ-001-AC-3 | WHILE <状態> THE <システム名> SHALL <動作> | Should |

### Requirement 2: ...

---

## Non-Functional Requirements

| カテゴリ | 要件 | 根拠（Steering） |
|---------|------|----------------|
| パフォーマンス | ... | tech.md より |
| セキュリティ | ... | tech.md より |
| 可用性 | ... | tech.md より |

---

## Traceability

| REQ-ID | ユーザーストーリー | 設計参照 | テスト参照 |
|--------|--------------------|---------|----------|
| REQ-001 | ... | （design.md 生成後に更新） | （testcases.md 生成後に更新） |
```

- 全ての受け入れ基準に一意の `REQ-NNN-AC-MM` ID を付与する
- Steering の tech.md から非機能要件を自動推論して記載する

## step7: Human Gate（`-y` なし時）

- requirements.md をユーザーに確認させる
- AskUserQuestion ツールで確認する：
  - question: "この要件定義書を承認しますか？"
  - options: ["承認する", "修正して再提示する", "中断する"]
- 「修正して再提示する」が選ばれた場合：フィードバックを受け取り step6 に戻る
- 「中断する」が選ばれた場合：現状の draft を保存して終了する

## step8: 承認後の更新

- `spec.json` を Read して `phases.requirements` を `"approved"` に更新する
- 「✅ requirements.md を承認しました（<REQ 件数> 件の受け入れ基準）」と表示する

## step9: 完了通知

```
✅ requirements.md を生成しました

.kairo/specs/{{feature_name}}/requirements.md
  - REQ 件数: <N> 件
  - AC 件数: <M> 件
  - ステータス: approved
```

次のステップ:
```
/kairo:spec-design {{feature_name}}
```
