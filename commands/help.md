---
description: kairo のコマンド一覧・詳細ヘルプ・困りごと検索を提供します。
allowed-tools: Read, AskUserQuestion
argument-hint: "[command-name | キーワード]"
---

# kairo help

kairo のヘルプを表示します。引数なしで全コマンド一覧、引数ありで詳細ヘルプを表示します。

# step

- $ARGUMENTS がある場合は step3 へスキップ
- $ARGUMENTS がない場合は step2 を実行する

## step2: 全コマンド一覧の表示

以下を表示する：

---

## kairo コマンド一覧

### Kiro フェーズ（上流：仕様・設計）

| コマンド | 説明 |
|---------|------|
| `/kairo:spec-steering` | プロジェクト全体の技術方針・規約を Steering 文書として生成 |
| `/kairo:spec-init <description>` | フィーチャーの仕様ワークスペースを初期化 |
| `/kairo:spec-req <feature>` | EARS 形式の要件定義書（requirements.md）を生成 |
| `/kairo:spec-design <feature>` | 技術設計書（design.md）を Mermaid 図付きで生成 |
| `/kairo:design-system "<description>"` | UI/UX デザインシステムを Claude ネイティブ推論で生成。`design-system/MASTER.md` を出力し CEG ノードとして管理 |
| `/kairo:spec-tasks <feature>` | P0/P1 波形の実装タスク（tasks.md）に分解 |
| `/kairo:issue-generate <feature>` | tasks.md を GitHub Issues に変換・issue-struct.md を自動生成 |

### コアワークフロー（下流：実装・品質）

| コマンド | 説明 |
|---------|------|
| `/kairo:install` | プロジェクト初期セットアップ |
| `/kairo:issue_init <issue-id>` | Issue → 構造化タスク定義・note.md 生成 |
| `/kairo:imp_generate [issue-id]` | IMP（実装管理計画書）を生成・更新 |
| `/kairo:implement [issue-id]` | IMP ベースで実装案・パッチ案を生成 |
| `/kairo:test [issue-id]` | テストケースマトリクス・検証方針を生成 |
| `/kairo:rev [issue-id]` | 実装から逆仕様・API 仕様・スキーマを生成 |
| `/kairo:sync [issue-id]` | 全成果物の整合性確認・修正 |
| `/kairo:review [issue-id]` | reviewer-oriented な差分・リスク整理 |
| `/kairo:drift_check [issue-id]` | 仕様と実装の乖離を検出・スコア化 |
| `/kairo:pr [issue-id]` | GitHub PR を作成しレビューチェックリストを投稿 |

### ユーティリティ

| コマンド | 説明 |
|---------|------|
| `/kairo:help [command]` | このヘルプ |
| `/kairo:cli [自然言語]` | 自然言語 → コマンドルーティング |

### 標準ワークフロー（Kiro フェーズ → 実装）

```
/kairo:spec-steering
    ↓
/kairo:spec-init <feature-description>
    ↓
/kairo:spec-req <feature>
    ↓
/kairo:spec-design <feature>
    ↓
/kairo:design-system "<product-description>"  ← オプション（UI/UX ありの場合）
    ↓
/kairo:spec-tasks <feature>
    ↓
/kairo:issue-generate <feature> [--wave P0]
    ↓
/kairo:issue_init 001-feature-name
    ↓
/kairo:imp_generate 001-feature-name
    ↓
/kairo:implement 001-feature-name [--mode tdd|direct]
    ↓
/kairo:test 001-feature-name [--exec]
    ↓
/kairo:rev 001-feature-name
    ↓
/kairo:drift_check 001-feature-name    ← いつでも実行可
    ↓
/kairo:sync 001-feature-name [--fix]
    ↓
/kairo:review 001-feature-name [--persona arch|security|qa|all]
    ↓
/kairo:pr 001-feature-name [--post-checklist]
```

### 困ったときは

```bash
# 何をすべきかわからない
/kairo:cli [やりたいことを自然言語で]

# 仕様と実装がずれている気がする
/kairo:drift_check [issue-id]

# 全体がちゃんと揃っているか確認したい
/kairo:sync [issue-id] --report-only

# レビュー前に資料を整えたい
/kairo:review [issue-id] --persona all
```

---

次のコマンドで詳細ヘルプを見られます：
`/kairo:help <command-name>`

- AskUserQuestion ツールを使って質問する：
  - question: "詳細を知りたいコマンドはありますか？"
  - header: "詳細ヘルプ"
  - multiSelect: false
  - options:
    - label: "spec-steering — Steering 文書生成"
    - label: "spec-init — フィーチャーワークスペース初期化"
    - label: "spec-req — 要件定義書（EARS）生成"
    - label: "spec-design — 技術設計書生成"
    - label: "design-system — UI/UX デザインシステム生成"
    - label: "spec-tasks — タスク分解（P0/P1 波形）"
    - label: "issue-generate — tasks.md → GitHub Issues 変換"
    - label: "install — 初期セットアップ"
    - label: "issue_init — Issue 構造化"
    - label: "imp_generate — IMP 生成"
    - label: "implement — 実装案生成"
    - label: "test — テスト生成"
    - label: "rev — 逆仕様生成"
    - label: "sync — 整合性確認"
    - label: "review — レビュー資料生成"
    - label: "drift_check — 乖離検出"
    - label: "pr — GitHub PR 作成"
    - label: "cli — 自然言語ルーティング"
    - label: "特に不要（閉じる）"
  - 選択されたコマンドがある場合は step3 へ、「特に不要」の場合は終了する

## step3: 詳細ヘルプの表示

$ARGUMENTS または選択されたコマンド名に応じて以下を表示する：

### design-system

```
/kairo:design-system "<product-description>" [--feature <feature>] [--page <page>] [--stack html-tailwind|react-tailwind|vue-tailwind] [--no-design-system]

UI/UX デザインシステムを Claude ネイティブ推論で生成します。
業界カテゴリ・5次元デザイン（色彩・タイポグラフィ・スペーシング・インタラクション・アクセシビリティ）を
自律推論し、design-system/MASTER.md として出力します。

引数:
  product-description   プロダクトの説明（例: "医療向け予約管理SaaS"）
  --feature             特定フィーチャー向けのデザインを追加
  --page                特定ページのコンポーネント仕様を追加
  --stack               CSS フレームワーク（デフォルト: html-tailwind）
  --no-design-system    デザインシステム生成をスキップ

出力:
  design-system/MASTER.md   デザインシステム SSOT
                            （カラー/タイポグラフィ/スペーシング/コンポーネント/アンチパターン）

冪等: ✅ 再実行時は差分マージ
前提: なし（spec-design と組み合わせて使うと効果的）
```

### install

```
/kairo:install [project-name] [--lang ja|en] [--speckit]

プロジェクトに kairo を導入します。

オプション:
  project-name  プロジェクト名（省略時は対話入力）
  --lang        出力言語（デフォルト: ja）
  --speckit     SpecKit との連携設定を有効化

生成物:
  .kairo/config.json
  .kairo/templates/IMP-template.md
  KAIRO.md
  specs/

冪等: ✅ 既存ファイルは上書きしません
```

### issue_init

```
/kairo:issue_init <issue-id> [issue-url-or-text] [--scope full|lite]

Issue を構造化し、IMP 生成のインプットとなるタスク定義を作成します。

引数:
  issue-id        Issue の識別子（省略時はブランチ名から自動推論）
                  例: 001-feature-name, 042-fix-login
  issue-url-or-text  GitHub URL またはテキスト（省略時は対話入力）
  --scope         分解の詳細度（full=詳細, lite=最小限、デフォルト: full）

出力:
  specs/{{issue_id}}/issue-struct.md  構造化 Issue 定義
  specs/{{issue_id}}/tasks.md         タスク分解（TASK-XXXX 形式）
  specs/{{issue_id}}/note.md          技術コンテキストノート

冪等: ✅ 再実行時は既存ファイルに差分マージ
前提: なし（最初のステップ）
```

### imp_generate

```
/kairo:imp_generate [issue-id] [--update] [--reviewer arch|security|qa]

IMP（実装管理計画書）を生成します。
IMP は Issue〜実装〜ドキュメントの単一の真実の源です。

引数:
  issue-id    Issue の識別子
  --update    既存 IMP を差分更新する
  --reviewer  想定レビュアー役割（複数指定可）

出力:
  specs/{{issue_id}}/IMP.md             IMP 本体
  specs/{{issue_id}}/IMP-checklist.md   レビュアーチェックリスト
  specs/{{issue_id}}/IMP-risks.md       リスクマトリクス

冪等: ✅ --update なしの再実行は差分確認後に更新
前提: /kairo:issue_init が完了していること
```

### implement

```
/kairo:implement [issue-id] [task-id] [--dry-run] [--mode tdd|direct]

IMP ベースで実装案・パッチ案を生成します。

引数:
  issue-id   Issue の識別子
  task-id    特定タスクのみ実装（省略時は全タスク）
  --dry-run  パッチ案のみ生成、実ファイル変更なし
  --mode     実装モード（tdd=テストファースト, direct=実装ファースト）

出力:
  specs/{{issue_id}}/implements/{task_id}/patch-plan.md  実装計画
  specs/{{issue_id}}/implements/{task_id}/impl-memo.md   実装判断の根拠
  specs/{{issue_id}}/implements/{task_id}/red-phase.md   TDD Red フェーズ

冪等: ✅ 既存実装に diff 形式で提示、確認後に適用
前提: /kairo:imp_generate が完了していること
```

### test

```
/kairo:test [issue-id] [task-id] [--exec] [--focus unit|integration|e2e|security|all]

テストケースマトリクスと検証方針を生成します。

引数:
  issue-id  Issue の識別子
  task-id   特定タスクのみ（省略時は全タスク）
  --exec    テストを実際に実行して結果を記録
  --focus   テストの重点領域（デフォルト: all）

出力:
  specs/{{issue_id}}/tests/{task_id}/testcases.md    テストケースマトリクス
  specs/{{issue_id}}/tests/{task_id}/test-plan.md    テスト計画書
  specs/{{issue_id}}/tests/{task_id}/test-results.md テスト実行結果（--exec 時）

冪等: ✅
前提: /kairo:implement が完了していること
```

### rev

```
/kairo:rev [issue-id] [--target api|schema|spec|requirements|all]

実装コードから逆仕様・ドキュメントを生成します。

引数:
  issue-id   Issue の識別子
  --target   生成対象（デフォルト: all）

出力:
  specs/{{issue_id}}/rev-spec.md          逆生成仕様書
  specs/{{issue_id}}/rev-api.md           API 仕様（api 対象時）
  specs/{{issue_id}}/rev-schema.md        データスキーマ（schema 対象時）
  specs/{{issue_id}}/rev-requirements.md  逆生成要件定義（requirements 対象時）

冪等: ✅
前提: 実装が存在すること
```

### sync

```
/kairo:sync [issue-id] [--fix] [--report-only]

Issue/IMP/実装/ドキュメントの整合性を確認・修正します。

引数:
  issue-id       Issue の識別子
  --fix          自動修正可能な乖離を修正する
  --report-only  レポートのみ生成、変更なし

出力:
  specs/{{issue_id}}/sync-report.md   整合性レポート（スコア 0-100）
  specs/{{issue_id}}/sync-actions.md  手動対応アクション一覧

整合性スコア:
  90-100: ✅ Excellent
  70-89:  ⚠️ Good（軽微な不整合）
  50-69:  ⚠️ Fair（要対応）
  0-49:   ❌ Poor（即時対応が必要）

冪等: ✅
```

### review

```
/kairo:review [issue-id] [--persona arch|security|qa|all] [--pr <pr-number>]

reviewer-oriented な差分・リスク・確認事項を整理します。

引数:
  issue-id         Issue の識別子
  --persona        レビュアーペルソナ（デフォルト: all）
  --pr             PR 番号（GitHub PR の diff を取得）

出力:
  specs/{{issue_id}}/review-checklist.md   ペルソナ別チェックリスト
  specs/{{issue_id}}/risk-matrix.md        リスクマトリクス
  specs/{{issue_id}}/review-questions.md   レビュアー確認質問

冪等: ✅
```

### drift_check

```
/kairo:drift_check [issue-id] [--since <commit-ish>] [--threshold <0-100>]

IMP（仕様）と実装の乖離を検出・可視化します。

引数:
  issue-id     Issue の識別子
  --since      比較基点のコミット・ブランチ
  --threshold  警告閾値（デフォルト: 20）

出力:
  specs/{{issue_id}}/drift-report.md   乖離レポート（スコア 0-100）
  specs/{{issue_id}}/drift-timeline.md 乖離の時系列変化

Drift スコア:
  0-10:   ✅ Aligned
  11-20:  ⚠️ Minor Drift
  21-50:  ⚠️ Significant Drift
  51-100: ❌ Critical Drift

冪等: ✅ 再実行時は前回レポートとの diff を表示
前提: IMP.md が存在すること
```

### pr

```
/kairo:pr [issue-id] [--draft] [--base <branch>] [--post-checklist]

IMP の内容から GitHub PR を作成します。
drift スコア・整合性スコアを PR 本文に埋め込みます。

引数:
  issue-id         Issue の識別子（例: 001-feature-name）
  --draft          ドラフト PR として作成
  --base           ベースブランチ（デフォルト: main）
  --post-checklist レビューチェックリストを PR コメントに投稿

出力:
  GitHub PR（URL を表示）
  PR コメント: specs/{{issue_id}}/review-checklist.md（--post-checklist 時）

前提: /kairo:review が完了していること（--post-checklist を使う場合）
```

### cli

```
/kairo:cli [自然言語の指示]

自然言語入力を kairo コマンドにルーティングします。

例:
  /kairo:cli 001-feature-name の Issue から作業を始めたい
  /kairo:cli 仕様と実装がずれていないか確認して
  /kairo:cli セキュリティ観点でレビューして
  /kairo:cli 何をすべきか教えて
```
