---
description: tasks.md の各タスクを GitHub Issue に変換します。issue-struct.md を自動生成し、kairo:imp_generate へ渡す準備を整えます。
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion, TodoWrite
argument-hint: "<feature-name> [--wave <P0|P1|all>] [--dry-run] [--diff]"
---

# kairo issue-generate

`tasks.md` の各タスクを GitHub Issue に変換し、`specs/<issue-id>/issue-struct.md` を自動生成します。
生成した Issue は `/kairo:imp_generate` への入力となります。

# context

feature_name={{feature_name}}
target_wave={{target_wave}}
dry_run={{dry_run}}
diff_mode={{diff_mode}}
spec_dir=.kiro/specs/{{feature_name}}
tasks_file=.kiro/specs/{{feature_name}}/tasks.md
spec_json=.kiro/specs/{{feature_name}}/spec.json

# step

- $ARGUMENTS がない場合は「引数に feature-name を指定してください（例: /kairo:issue-generate user-auth-oauth）」と言って終了する
- $ARGUMENTS を解析する：
  - `--wave` の後の値を target_wave に設定（デフォルト: `P0`）
  - `--dry-run` フラグを確認し dry_run に設定
  - `--diff` フラグを確認し diff_mode に設定
  - 最初のトークンを feature_name に設定
- context の内容をユーザーに宣言する
- step2 を実行する

## step2: 前提チェック

- `gh` コマンドの存在を Bash で確認する：
  ```bash
  gh auth status 2>/dev/null
  ```
  - `gh` が未認証または未インストールの場合：
    - 「`gh` CLI が設定されていません。`gh auth login` を実行後に再試行してください」と表示する
    - `--dry-run` が有効な場合はスキップして続行する
- `.kiro/specs/{{feature_name}}/spec.json` を Read してフェーズ情報を確認する
  - `phases.tasks` が `"approved"` でない場合：
    - 「tasks.md が未承認です。先に `/kairo:spec-tasks {{feature_name}}` を実行してください」と表示する
    - AskUserQuestion で確認する：
      - question: "tasks.md が未承認ですが、続行しますか？"
      - options: ["続行する（draft のまま進める）", "中断する"]
    - 「中断する」が選ばれた場合：終了する
- step3 を実行する

## step3: コンテキスト収集

- `.kiro/specs/{{feature_name}}/tasks.md` を Read する
- `.kiro/specs/{{feature_name}}/requirements.md` を Read する（AC 展開用）
- `.kiro/specs/{{feature_name}}/design.md` を Read する（設計参照リンク用）
- step4 を実行する

## step4: 対象タスクの抽出

- target_wave の値に応じてタスクを抽出する：
  - `P0`: `[P0]` タグのタスクのみ
  - `P1`: `[P1]` タグのタスクのみ
  - `all`: 全タスク
- `--diff` モードの場合：`spec.json` の `generated_issues` と照合し、未生成タスクのみ抽出する
- 抽出したタスク一覧を表示する

## step5: Issue コンテンツの生成

各タスクに対して以下の Issue 本文を生成する：

**タイトル形式**: `[{{feature_name}}] <タスク説明>`

**本文テンプレート**:

```markdown
## 概要
<tasks.md のタスク説明>

## 受け入れ基準（requirements.md より）

<_Requirements_ に記載された AC-ID を requirements.md から展開>

| AC-ID | EARS 記法 | 優先度 |
|-------|----------|-------|
| REQ-001-AC-1 | WHEN ... THEN ... SHALL ... | Must |

## 関連設計
- 設計書: `.kiro/specs/{{feature_name}}/design.md`
- 関連タスク: tasks.md#<タスク番号>

## 実装ステップ
<tasks.md の実装ステップ箇条書きをそのまま転写>

## 依存関係
- 依存する Issue: <先行タスクの Issue 番号（判明している場合）>
- 並列実行波形: <P0/P1/P2>

## kairo リンク
- フィーチャー仕様: `.kiro/specs/{{feature_name}}/`
- IMP 生成コマンド: `/kairo:imp_generate <issue-id>`
```

## step6: Human Gate（`--dry-run` なし時）

- 生成する Issue の一覧をプレビュー表示する：
  ```
  生成予定 Issue:
  [1] [{{feature_name}}] <タスク1説明> [P0]
  [2] [{{feature_name}}] <タスク2説明> [P0]
  ...
  ```
- AskUserQuestion ツールで確認する：
  - question: "上記の Issue を GitHub に作成しますか？"
  - options: ["作成する", "内容を修正してから作成する", "dry-run のみ（作成しない）", "中断する"]
- 「dry-run のみ」または `--dry-run` フラグが有効な場合：Issue コンテンツを表示して終了する
- 「中断する」が選ばれた場合：終了する

## step7: GitHub Issue の作成

各タスクに対して Bash で以下を実行する：

```bash
gh issue create \
  --title "<タイトル>" \
  --body "<本文>" \
  --label "kairo,{{feature_name}}" 2>/dev/null
```

- 生成された Issue の URL と番号を取得・表示する
- エラーが発生した場合：エラー内容を表示し、該当タスクをスキップして続行する
- step8 を実行する

## step8: issue-struct.md の自動生成

各 Issue に対して：

- issue-id を `<Issue番号>-<kebab-case-タスク名>` で生成する
  - 例: `042-user-auth-oauth-provider`
- `specs/<issue-id>/` ディレクトリを作成する
- `specs/<issue-id>/issue-struct.md` を生成する（既存の `issue_init` コマンドのテンプレートに準拠）：

```markdown
# Issue 構造定義: <issue-id>

## 概要
<タスク説明>

## フィーチャー参照
- フィーチャー: {{feature_name}}
- タスク参照: tasks.md#<タスク番号>
- 要件参照: .kiro/specs/{{feature_name}}/requirements.md
- 設計参照: .kiro/specs/{{feature_name}}/design.md

## 受け入れ基準
<requirements.md から AC を転写（AC-ID リンク付き）>

## タスク一覧
<tasks.md の実装ステップ>

## 依存関係
- 先行タスク: <先行タスクの issue-id>
- 並列波形: <P0/P1/...>

## GitHub Issue
- Issue 番号: #<N>
- Issue URL: <URL>
```

## step9: spec.json の更新

`.kiro/specs/{{feature_name}}/spec.json` の `generated_issues` を更新する：

```json
{
  "id": "<issue-id>",
  "gh_number": <N>,
  "task_ref": "<タスク番号>",
  "wave": "<P0/P1>",
  "status": "pending",
  "created_at": "<ISO8601 日時>"
}
```

`phases.issues_generated` を `true` に更新する（全波形生成済みの場合）。

## step10: 完了通知

生成した Issue の一覧を表示する：

```
✅ GitHub Issue を生成しました（波形: {{target_wave}}）

生成した Issue:
  #<N1> [P0] <タスク1説明> → specs/<issue-id-1>/
  #<N2> [P0] <タスク2説明> → specs/<issue-id-2>/
  ...

次のステップ（P0 タスクから順に実装を開始）:
  /kairo:imp_generate <issue-id-1>
  /kairo:imp_generate <issue-id-2>
```

> **P1 以降のタスクを追加する場合**:
> ```
> /kairo:issue-generate {{feature_name}} --wave P1
> ```
