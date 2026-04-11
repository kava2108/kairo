---
description: kairo プロジェクトの初期セットアップを行います。ディレクトリ構造・設定ファイル・IMP テンプレートを生成し、Skills の有効化手順を案内します。--harness フラグで VCKD Harness（Baton Infrastructure）を有効化します。
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion, TodoWrite
argument-hint: "[project-name] [--lang ja|en] [--speckit] [--harness] [--no-design-system]"
---

# kairo install

kairo エンジンをプロジェクトに導入するための初期セットアップを行います。
冪等設計のため、既存ファイルを上書きせずに差分のみを追加します。

# context

プロジェクト名={{project_name}}
言語={{lang}}
SpecKit連携={{speckit_enabled}}
デザインシステムスキップ={{no_design_system}}
作業ディレクトリ={{working_dir}}

# step

- $ARGUMENTS の内容を解析する：
  - `--lang en` が含まれる場合、lang を `en` に設定（デフォルト: `ja`）
  - `--speckit` が含まれる場合、speckit_enabled を `true` に設定
  - `--harness` が含まれる場合、harness_enabled を `true` に設定（デフォルト: `false`）
  - `--no-design-system` が含まれる場合、no_design_system を `true` に設定（デフォルト: `false`）
  - 残りの文字列をプロジェクト名として設定
- context の内容をユーザーに宣言する
- step2 を実行する

## step2: プロジェクト名の確認

- プロジェクト名が未指定の場合、AskUserQuestion ツールを使って質問する：
  - question: "プロジェクト名を教えてください"
  - header: "プロジェクト名"
  - multiSelect: false
- 取得したプロジェクト名を context の {{project_name}} に保存する
- step3 を実行する

## step3: 既存セットアップの確認（idempotent チェック）

- `.kairo/config.json` が存在するか確認する
  - 存在する場合：「既存の kairo 設定が見つかりました。差分のみを追加します」と表示する
  - 存在しない場合：「新規セットアップを開始します」と表示する
- step4 を実行する

## step4: ディレクトリ構造の生成

以下のディレクトリを作成する（既存ディレクトリは変更しない）：

```
specs/
.kairo/templates/
```

各ディレクトリに `.gitkeep` ファイルを作成する（既存ファイルはスキップ）。

## step5: VCKD 設定ファイルの生成

**`--harness` フラグなし（デフォルト）の場合**:
- `.vckd/config.yaml` が存在しない場合のみ、以下の内容で生成する（harness.enabled=false）：
  ```yaml
  harness:
    enabled: false
    AUTO_STEP: false
    mode: "claude-code-hooks"
  kiro:
    use_cc_sdd: "auto"
    kiro_dir: ".kairo"
  ```
- これにより `dispatch_baton` 等のバトン関数は早期リターンし、v1.0 互換動作を保証する

**`--harness` フラグあり**の場合:
- step8 で `harness.enabled=true` の設定を生成する（後続ステップで実施）

## step5b: kairo 設定ファイルの生成

`.kairo/config.json` が存在しない場合のみ、以下の内容で作成する：

```json
{
  "kairo_version": "1.0.0",
  "project": {
    "name": "{{project_name}}",
    "language": "{{lang}}",
    "created_at": "<現在の ISO8601 日時>"
  },
  "integrations": {
    "speckit": {{speckit_enabled}},
    "github": {
      "enabled": true,
      "issue_prefix": "GH"
    },
    "uupm": {
      "enabled": true,
      "skill_path": ".claude/skills/ui-ux-pro-max",
      "default_stack": "html-tailwind",
      "auto_design_system_on_spec_design": true,
      "persist_design_system": true
    },
    "kiro": {
      "enabled": true,
      "config_dir": ".kairo"
    }
  },
  "drift_check": {
    "threshold": 20,
    "auto_run_after_implement": true,
    "design_drift_enabled": true
  },
  "review": {
    "default_personas": ["arch", "security", "qa", "ui"],
    "adversary_dimensions": ["D1","D2","D3","D4","D5","D6"],
    "require_checklist_before_merge": true
  },
  "imp": {
    "require_executive_summary": true,
    "require_rollback_plan": true,
    "version_scheme": "semver"
  },
  "docs": {
    "base_path": "specs"
  },
  "harness": {
    "enabled": false,
    "AUTO_STEP": false,
    "mode": "claude-code-hooks"
  }
}
```

## step6: IMP テンプレートと harness ライブラリの生成

`.kairo/templates/IMP-template.md` を作成する（既存の場合はスキップ）。

- テンプレートを Read する（以下の順で探索し、最初に見つかったものを使用する）：
  - `~/.claude/commands/kairo/templates/IMP-template.md`
  - `.claude/commands/kairo/templates/IMP-template.md`
- 読み込んだテンプレートをそのまま `.kairo/templates/IMP-template.md` として Write する

## step7: KAIRO.md の生成

プロジェクトルートに `KAIRO.md` を作成する（既存の場合はスキップ）。

- テンプレートを Read する（以下の順で探索し、最初に見つかったものを使用する）：
  - `~/.claude/commands/kairo/templates/KAIRO-md-template.md`
  - `.claude/commands/kairo/templates/KAIRO-md-template.md`
- テンプレートの `{{project_name}}` を context の {{project_name}} に置換して `KAIRO.md` を Write する

## step8: VCKD Harness セットアップ（--harness フラグ時のみ）

harness_enabled が `true` の場合のみ、このステップを実行する。

**8.1 `gh` CLI の確認**:
- Bash で `gh --version 2>/dev/null` を実行する
- 失敗した場合は「`gh` CLI が見つかりません。https://cli.github.com/ からインストールしてください」と警告して step8.2 以降をスキップ

**8.2 `.vckd/config.yaml` の生成**:
- `.vckd/config.yaml` が既に存在する場合は「既存の `.vckd/config.yaml` を検出しました。`--force` を指定しない限り上書きしません」と表示してスキップ
- 存在しない場合は以下の内容で生成する：

```yaml
harness:
  enabled: true
  AUTO_STEP: false
  mode: "claude-code-hooks"
  baton:
    post_comment: true
    pending_label: "pending:next-phase"
    approve_label: "approve"
kiro:
  use_cc_sdd: "auto"
  kiro_dir: ".kairo"
codd:
  cli_path: null
```

**8.3 `graph/` ディレクトリとファイルの生成**:
- Bash で `mkdir -p graph` を実行する
- `graph/baton-log.json` を以下の内容で生成する（既存の場合はスキップ）：
  ```json
  {"version":"1.0.0","transitions":[],"pending":{}}
  ```
- `graph/coherence.json` を以下の内容で生成する（既存の場合はスキップ）：
  ```json
  {"version":"1.0.0","nodes":{},"edges":[],"summary":{"total":0,"green":0,"amber":0,"gray":0,"last_scanned":null}}
  ```

**8.4 `.kairo/hooks/post-tool-use.sh` の生成**:
- Bash で `mkdir -p .kairo/hooks .kairo/lib .kairo/agents .kairo/templates` を実行する
- `.kairo/hooks/post-tool-use.sh` を `.kairo/` ディレクトリから Read して Write する（既存の場合はスキップ）
- Bash で `chmod +x .kairo/hooks/post-tool-use.sh` を実行する

**8.5 `.claude/settings.json` への PostToolUse フック追加**:
- `.claude/settings.json` が存在するか確認する
  - 存在する場合: Read して PostToolUse 配列に既にフックが登録されているか確認する（`.kairo/hooks/post-tool-use.sh` のパスで判定）
    - 登録済みならスキップ
    - 未登録なら `hooks.PostToolUse` 配列に `{"matcher":"","hooks":[{"type":"command","command":"bash .kairo/hooks/post-tool-use.sh"}]}` を追加して Write する
  - 存在しない場合: 以下の内容で新規作成する：
    ```json
    {
      "hooks": {
        "PostToolUse": [
          {
            "matcher": "",
            "hooks": [
              {
                "type": "command",
                "command": "bash .kairo/hooks/post-tool-use.sh"
              }
            ]
          }
        ]
      }
    }
    ```

**8.6 GitHub Labels の作成**:
- Bash で以下のラベルを作成する（既存の場合は `gh label create --force` でスキップ対応）：
  - `phase:req`, `phase:tds`, `phase:imp`, `phase:test`, `phase:ops`, `phase:change`, `phase:done`
  - `pending:next-phase`, `approve`
  - `blocked:req`, `blocked:tds`, `blocked:imp`, `blocked:ops`, `blocked:escalate`
  - `human:review`
- エラーが発生した場合は「権限不足のためラベルを手動で作成してください」と案内して続行する

## step9: デザインシステム設定の初期化

`--no-design-system` フラグが指定されている場合はこのステップをスキップする。

**9.1 `.kairo/config.json` へのデザインシステム設定の追加**:

`.kairo/config.json` の `integrations` に `design_system` セクションが存在しない場合のみ追加する：

```json
"design_system": {
  "enabled": true,
  "master_path": "design-system/MASTER.md",
  "auto_generate_on_spec_design": true,
  "persist": true,
  "default_stack": "html-tailwind"
}
```

> **方針（v1.1）**: UI/UX デザイン知識は外部リポジトリのクローンや Python スクリプト呼び出しに
> 依存せず、Claude ネイティブ推論として内部化されています。
> `git clone` によるインストールは不要です。

## step10: 完了通知

以下を表示する（harness_enabled の値に応じてメッセージを変える）：

```
✅ kairo セットアップ完了

生成されたファイル:
  .kairo/config.json
  .kairo/templates/IMP-template.md
  KAIRO.md
  specs/.gitkeep

（--harness 時は以下も追加）
  .vckd/config.yaml
  graph/baton-log.json
  graph/coherence.json
  .kairo/hooks/post-tool-use.sh
  .claude/settings.json（PostToolUse フック追加）
  GitHub Labels: 15 件作成済み

次のステップ:
  1. デザインシステムを生成（推奨）:
     /kairo:design-system "<プロダクト説明>" --feature <feature-name>

  2. 最初の Issue から作業を開始:
     /kairo:issue_init <issue-id>

  3. ヘルプを確認:
     /kairo:help

  （--harness 時）
  4. バトン状態を確認:
     /kairo:baton-status
```

- TodoWrite ツールでセットアップ完了をマークする
