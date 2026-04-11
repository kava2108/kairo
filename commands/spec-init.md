---
description: フィーチャーの仕様ワークスペースを初期化します。自然言語の説明から feature-name を生成し、.kiro/specs/ にディレクトリと spec.json を作成します。
allowed-tools: Read, Glob, Write, Bash, AskUserQuestion, TodoWrite
argument-hint: "<feature-description>"
---

# kairo spec-init

フィーチャーの仕様ワークスペースを初期化します。
自然言語の説明から kebab-case の feature-name を生成し、`.kiro/specs/<feature-name>/` を作成します。
冪等設計のため、既存ワークスペースが存在する場合は確認を求めます。

# context

feature_description={{feature_description}}
feature_name={{feature_name}}
specs_dir=.kairo/specs
steering_dir=.kairo/steering

# step

- $ARGUMENTS がない場合は「フィーチャーの説明を引数に指定してください（例: /kairo:spec-init OAuth 2.0 認証機能）」と言って終了する
- $ARGUMENTS を feature_description として取得する
- context の内容をユーザーに宣言する
- step2 を実行する

## step2: Steering コンテキストの読み込み

- `.kiro/steering/structure.md` を存在する場合に Read する
- `.kiro/steering/tech.md` を存在する場合に Read する
- `.kiro/steering/product.md` を存在する場合に Read する
- Steering が存在しない場合：「Steering 文書が未生成です。先に `/kairo:spec-steering` を実行することを推奨します（スキップして続行も可能）」と表示する
- step3 を実行する

## step3: フィーチャー名の生成

- feature_description を以下のルールで kebab-case の feature_name に変換する：
  - 日本語・英語混在を英語に翻訳・整理する
  - 主要な名詞・動詞を抽出して連結する
  - 最大 5 単語、全て小文字、ハイフン区切り
  - 例: "OAuth 2.0 認証機能" → `user-auth-oauth`
  - 例: "商品レビュー投稿 API" → `product-review-api`
- 生成した feature_name をユーザーに提示し、AskUserQuestion で確認する：
  - question: "フィーチャー名として `<feature_name>` を使用します。変更しますか？"
  - options: ["そのまま使用する", "変更する"]
  - 「変更する」が選ばれた場合：新しい名前を自由入力で受け取る
- step4 を実行する

## step4: 既存ワークスペースの確認（idempotent チェック）

- `.kiro/specs/{{feature_name}}/` が既に存在するか確認する
  - 存在する場合：
    - `.kiro/specs/{{feature_name}}/spec.json` を Read してステータスを確認する
    - 「既存のワークスペースが見つかりました（status: <status>）」と表示する
    - AskUserQuestion で確認する：
      - question: "続行しますか？"
      - options: ["上書きして再初期化する", "現状を表示して終了する", "中断する"]
    - 「現状を表示して終了する」が選ばれた場合：spec.json の内容を表示して終了する
    - 「中断する」が選ばれた場合：終了する
  - 存在しない場合：「新規ワークスペースを初期化します」と表示する
- step5 を実行する

## step5: ワークスペースの初期化

- `.kiro/specs/{{feature_name}}/` ディレクトリを作成する
- `spec.json` を以下の内容で Write する：

```json
{
  "feature": "{{feature_name}}",
  "description": "{{feature_description}}",
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

- `requirements.md` を以下のスタブで Write する（Steering の product.md が読み込まれている場合はコンテキストを反映）：

```markdown
# Requirements Document: {{feature_name}}

> **ステータス**: draft（`/kairo:spec-req {{feature_name}}` で詳細を生成）

## Introduction
{{feature_description}}

## Requirements
（`/kairo:spec-req {{feature_name}}` で自動生成されます）
```

## step6: 完了通知

生成されたワークスペースを表示する：
```
✅ フィーチャーワークスペースを初期化しました

.kiro/specs/{{feature_name}}/
├── spec.json        — フィーチャーメタデータ（status: init）
└── requirements.md  — 要件スタブ（未生成）
```

次のステップ:
```
/kairo:spec-req {{feature_name}}
```
