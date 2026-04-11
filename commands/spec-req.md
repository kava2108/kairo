---
description: EARS 形式の要件定義書（requirements.md）を生成します。--suggest でフィーチャー候補一覧を提示し承認後に .kiro/specs/<feature>/ を一括作成します。
allowed-tools: Read, Glob, Write, Edit, AskUserQuestion, TodoWrite
argument-hint: "<feature-name> [--suggest] [-y]"
---

# kairo spec-req

EARS（Easy Approach to Requirements Syntax）形式の要件定義書を生成します。
受け入れ基準に一意の `REQ-NNN-AC-MM` ID を付与し、後続の設計・テスト・drift_check とのトレーサビリティを確保します。

`--suggest` モードでは、プロダクト/コードベースの分析からフィーチャー候補一覧を提示し、
承認されたフィーチャーの `.kiro/specs/<feature>/` ディレクトリを一括作成します。

# context

feature_name={{feature_name}}
suggest_mode={{suggest_mode}}
auto_approve={{auto_approve}}
spec_dir=.kiro/specs/{{feature_name}}
requirements_file=.kiro/specs/{{feature_name}}/requirements.md
spec_json=.kiro/specs/{{feature_name}}/spec.json

# step

- $ARGUMENTS がない場合は「引数に feature-name を指定してください（例: /kairo:spec-req user-auth-oauth）」と言って終了する
- $ARGUMENTS を解析する：
  - `--suggest` フラグを確認し suggest_mode に設定（デフォルト: false）
  - `-y` フラグを確認し auto_approve に設定（デフォルト: false）
  - 最初のトークン（フラグ以外）を feature_name に設定
- `--suggest` フラグが有効な場合は suggest-step へジャンプする
- context の内容をユーザーに宣言する
- step2 を実行する

## suggest-step: フィーチャー候補の提示と一括ディレクトリ作成

### suggest-step1: コンテキスト収集

- `.kiro/steering/product.md` を存在する場合に Read する
- `.kiro/steering/structure.md` を存在する場合に Read する
- `README.md`, `KAIRO.md`, `CLAUDE.md` を存在する場合に Read する
- Glob で `src/**`, `app/**`, `lib/**` の構造を把握する
- 既存の `.kiro/specs/` ディレクトリ一覧を確認し、既に作成済みのフィーチャーを把握する

### suggest-step2: フィーチャー候補の生成

コードベース・プロダクト情報の分析から、実装が必要と推論されるフィーチャー候補を生成する：

- 候補は 5〜10 件を目安とし、kebab-case の feature-name と説明を付ける
- 既に `.kiro/specs/` に存在するフィーチャーは「✅ 作成済み」として一覧に含める（再作成しない）
- 依存関係がある場合は「依存: <feature-name>」を付記する

提示形式：

```
【フィーチャー候補一覧】

新規作成候補:
  1. user-auth-oauth        — OAuth 2.0 / JWT 認証基盤
  2. product-catalog-api    — 商品カタログ CRUD API
  3. payment-integration    — 決済処理統合（Stripe）
  4. notification-service   — メール/Push 通知サービス（依存: user-auth-oauth）
  5. admin-dashboard        — 管理画面 UI

作成済み:
  ✅ onboarding-flow        — ユーザーオンボーディング
```

### suggest-step3: Human Gate — フィーチャー選択

AskUserQuestion ツールで確認する：
- question: "作成するフィーチャーを選択してください（複数選択可）"
- header: "フィーチャー選択"
- multiSelect: true
- options: 候補一覧の各フィーチャーを option として列挙する（label: "<feature-name> — <説明>"）
- 「全て選択」「選択をクリア」オプションも加える
- allowFreeformInput: true（一覧にないフィーチャーも追加入力可能）

### suggest-step4: ディレクトリの一括作成

選択されたフィーチャーそれぞれに対して以下を実行する（既存ディレクトリはスキップ）：

1. `.kiro/specs/<feature-name>/` ディレクトリを作成する
2. `spec.json` を以下の内容で Write する：
   ```json
   {
     "feature": "<feature-name>",
     "description": "<説明>",
     "status": "init",
     "phases": {
       "steering": "<.kiro/steering/ が存在すれば 'available' でなければ 'skipped'>",
       "requirements": "pending",
       "design": "pending",
       "tasks": "pending",
       "issues_generated": false
     },
     "generated_issues": [],
     "wave_config": {},
     "created_at": "<現在の ISO8601 日時>",
     "updated_at": "<現在の ISO8601 日時>"
   }
   ```
3. `requirements.md` を以下のスタブで Write する：
   ```markdown
   # Requirements Document: <feature-name>

   > **ステータス**: draft（`/kairo:spec-req <feature-name>` で詳細を生成）

   ## Introduction
   <説明>

   ## Requirements
   （`/kairo:spec-req <feature-name>` で自動生成されます）
   ```

### suggest-step5: 完了通知

作成したディレクトリ一覧を表示する：

```
✅ フィーチャーワークスペースを一括作成しました

.kiro/specs/
├── user-auth-oauth/        ← 新規作成
├── product-catalog-api/    ← 新規作成
├── payment-integration/    ← 新規作成
└── notification-service/   ← 新規作成

次のステップ（各フィーチャーの要件定義を生成）:
  /kairo:spec-req user-auth-oauth
  /kairo:spec-req product-catalog-api
  ...
```

終了する（ここ以降の通常フローへは進まない）。

## step2: 前提チェック

- `.kiro/specs/{{feature_name}}/spec.json` の存在を確認する
  - 存在しない場合：「先に `/kairo:spec-init {{feature_name}}` を実行してください」と言って終了する
- `spec.json` を Read してフィーチャー情報を取得する
- step3 を実行する

## step3: コンテキスト収集

- `.kiro/steering/structure.md` を存在する場合に Read する
- `.kiro/steering/tech.md` を存在する場合に Read する
- `.kiro/steering/product.md` を存在する場合に Read する
- `.kiro/specs/{{feature_name}}/requirements.md` を Read して既存コンテンツを確認する
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

.kiro/specs/{{feature_name}}/requirements.md
  - REQ 件数: <N> 件
  - AC 件数: <M> 件
  - ステータス: approved
```

次のステップ:
```
/kairo:spec-design {{feature_name}}
```
