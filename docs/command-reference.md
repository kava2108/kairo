# kairo コマンドリファレンス

各コマンドの構文・オプション・出力・前提条件を網羅したリファレンスです。

---

## 目次

### セットアップ
- [install](#install)

### REQ フェーズ（要件定義）
- [spec-steering](#spec-steering)
- [spec-req](#spec-req)

### TDS フェーズ（技術設計）
- [spec-design](#spec-design)
- [spec-tasks](#spec-tasks)
- [design-system](#design-system)

### ブリッジ
- [issue-generate](#issue-generate)

### IMP フェーズ（実装管理）
- [issue_init](#issue_init)
- [imp_generate](#imp_generate)
- [implement](#implement)

### TEST フェーズ（品質保証）
- [test](#test)
- [review](#review)

### OPS フェーズ（整合性確認）
- [rev](#rev)
- [drift_check](#drift_check)

### CHANGE フェーズ
- [sync](#sync)
- [pr](#pr)

### ユーティリティ
- [baton-status](#baton-status)
- [coherence-scan](#coherence-scan)
- [cli](#cli)
- [help](#help)

---

## install

プロジェクトに kairo を導入します。`.kairo/config.json`・`KAIRO.md`・`specs/` を生成します。

### 構文

```
/kairo:install [project-name] [--lang ja|en] [--speckit] [--harness]
```

### オプション

| オプション | 説明 | デフォルト |
|-----------|------|-----------|
| `project-name` | プロジェクト名（省略時は対話入力） | ─ |
| `--lang` | 出力言語 | `ja` |
| `--speckit` | SpecKit との連携設定を有効化 | `false` |
| `--harness` | バトン信号フック・GitHub ラベルも設定する | `false` |

### 出力ファイル

```
.kairo/
├── config.json              # プロジェクト設定（issue_id_format, integrations 等）
├── templates/               # IMP テンプレートなど
└── hooks/                   # --harness 時: バトン信号フック
    └── post-tool-use.sh

KAIRO.md                     # プロジェクト固有の kairo コンテキスト
specs/                       # 全成果物の置き場所（空ディレクトリ）
```

### 例

```bash
# 最小構成でインストール
/kairo:install

# 英語モードで
/kairo:install MyProject --lang en

# バトン信号フックも設定する場合
/kairo:install MyProject --harness
```

### 注意

- **冪等**: 既存ファイルは上書きしません。`--force` オプションは存在しません。
- `config.json` の `integrations.design_system.enabled: true` になっていると、`spec-design` 実行時に自動でデザインシステムを生成します。

---

## spec-steering

プロジェクトの技術スタック・ディレクトリ構成・規約を Steering 文書として生成します。  
全 kairo コマンドがこの文書を共有コンテキストとして参照します。

### 構文

```
/kairo:spec-steering [--update] [--custom <domain>]
```

### オプション

| オプション | 説明 |
|-----------|------|
| `--update` | 既存 Steering 文書を差分更新する |
| `--custom <domain>` | 特定ドメインの規約を追加する（例: `--custom security`） |

### 出力ファイル

```
.kiro/steering/
├── structure.md    # ディレクトリ構成・命名規則・ファイルパターン
├── tech.md         # 技術スタック・フレームワーク・依存ライブラリ
└── product.md      # プロダクト概要・ドメイン知識
```

### 動作詳細

コードベースを自動スキャンして以下を分析します:
- `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml` などから技術スタックを特定
- ディレクトリ構造から命名規則・アーキテクチャパターンを推論
- `README.md`, `CLAUDE.md` などからプロダクトコンテキストを取得

### 例

```bash
# 新規プロジェクトで最初に実行
/kairo:spec-steering

# 技術スタックが変わった場合に更新
/kairo:spec-steering --update
```

### 注意

- 全コマンドの中で**最初に実行する**べきコマンドです。
- 既存 Steering がある場合（`--update` なし）は続行確認ダイアログが表示されます。

---

## spec-req

EARS（Easy Approach to Requirements Syntax）形式の要件定義書を生成します。  
受け入れ基準に `REQ-NNN-AC-MM` の一意 ID を付与し、後続フェーズとのトレーサビリティを確保します。

### 構文

```
/kairo:spec-req <feature-name> [--suggest] [-y]
```

### 引数・オプション

| 引数/オプション | 説明 |
|---------------|------|
| `feature-name` | フィーチャー名（kebab-case 推奨）。`--suggest` 時は不要 |
| `--suggest` | フィーチャー候補を AI が提案し、複数選択してディレクトリを一括作成する |
| `-y` | Phase Gate の承認確認をスキップ（自動実行用） |

### 出力ファイル

```
.kiro/specs/<feature>/
├── requirements.md    # EARS 形式の要件定義書（AC-ID 付き）
└── spec.json          # フェーズ管理ファイル（phases.requirements が更新される）
```

### EARS 記法の例

```markdown
## REQ-001: ユーザー認証

### REQ-001-AC-01: JWT 発行
WHEN ユーザーが有効な認証情報を送信する
THE SYSTEM SHALL JWT アクセストークン（有効期限 1h）を返す

### REQ-001-AC-02: 失敗時エラー
WHEN 認証情報が無効である
THE SYSTEM SHALL 401 Unauthorized を返す
```

### 例

```bash
# 単体フィーチャーの要件定義
/kairo:spec-req user-auth-oauth

# フィーチャー候補を提案してもらう場合
/kairo:spec-req --suggest

# 承認確認なしで自動実行
/kairo:spec-req user-auth-oauth -y
```

### 注意

- **前提**: `spec-steering` が完了していること（なくても動作しますが Steering を参照する精度が下がります）。
- `spec.json` の `phases.requirements` が `"approved"` になると、`spec-design` に進めます。

---

## spec-design

要件定義書をもとに技術設計書（`design.md`）を生成します。  
アーキテクチャ・API 設計・DB 設計を Mermaid 図付きで出力します。

### 構文

```
/kairo:spec-design <feature-name> [-y] [--no-design-system]
```

### 引数・オプション

| 引数/オプション | 説明 |
|---------------|------|
| `feature-name` | フィーチャー名 |
| `-y` | Phase Gate の承認確認をスキップ |
| `--no-design-system` | デザインシステム自動生成をスキップ |

### 出力ファイル

```
.kiro/specs/<feature>/
├── design.md          # 技術設計書（Mermaid 図付き）
├── research.md        # 技術選定調査メモ（技術的選択肢がある場合のみ）
└── spec.json          # phases.design が更新される

design-system/
└── MASTER.md          # UI/UX デザインシステム（自動生成、--no-design-system で抑制）
```

### design.md の構成

```markdown
# Technical Design Document: <feature>
## アーキテクチャ概要（Mermaid シーケンス図）
## コンポーネント設計
## API 設計（エンドポイント・リクエスト/レスポンス）
## データベース設計（ER 図 / スキーマ）
## セキュリティ考慮事項
## パフォーマンス考慮事項
## テスト戦略
## Design System（design-system/MASTER.md 参照）
```

### デザインシステム自動生成について

`.kairo/config.json` の `integrations.design_system.enabled: true` かつ `design-system/MASTER.md` が未存在の場合、
Claude ネイティブ推論でデザインシステムを自動生成します（`design-system` コマンドと同等の処理）。

### 例

```bash
# 標準実行
/kairo:spec-design user-auth-oauth

# デザインシステム不要の場合（バックエンド API のみなど）
/kairo:spec-design billing-api --no-design-system
```

### 注意

- **前提**: `spec-req` が承認済みであること（`spec.json` の `phases.requirements === "approved"`）。
- 承認前でも続行確認ダイアログで進行できます。

---

## spec-tasks

技術設計書を P0/P1 波形の実装タスクに分解します。  
各タスクに要件 AC-ID を紐付け、`issue-generate` への入力となる `tasks.md` を生成します。

### 構文

```
/kairo:spec-tasks <feature-name> [-y]
```

### 引数・オプション

| 引数/オプション | 説明 |
|---------------|------|
| `feature-name` | フィーチャー名 |
| `-y` | 承認確認をスキップ |

### 出力ファイル

```
.kiro/specs/<feature>/
├── tasks.md    # P0/P1/P2 波形のタスク一覧（依存グラフ・AC-ID 付き）
└── spec.json   # phases.tasks が更新される
```

### 波形（Wave）の概念

| 波形 | 意味 | 例 |
|------|------|-----|
| **P0** | 依存なし、並列実行可能 | DB スキーマ作成、認証基盤 |
| **P1** | P0 完了後に実行 | API エンドポイント実装 |
| **P2** | P1 完了後に実行 | フロントエンド UI |
| **P_n** | Pn-1 完了後 | E2E テスト等 |

### tasks.md の例

```markdown
## Wave P0

### タスク 1.1: DB スキーマ作成 [P0]
- マイグレーションファイルの作成
- users テーブル・oauth_tokens テーブルの定義
_Requirements: REQ-001-AC-01, REQ-001-AC-02_
_Parallel: P0（依存なし）_
```

### 注意

- **前提**: `spec-design` が承認済みであること。
- `tasks.md` は `issue-generate` の直接の入力になります。

---

## design-system

プロダクトの説明から UI/UX デザインシステムを Claude ネイティブ推論で生成します。  
`design-system/MASTER.md` に出力し、全フェーズで参照される CEG ノードとして管理します。

### 構文

```
/kairo:design-system "<product-description>" [--stack <stack>] [--page <page-name>] [--feature <feature>] [--persist]
```

### 引数・オプション

| 引数/オプション | 説明 | デフォルト |
|---------------|------|-----------|
| `product-description` | プロダクトの説明（自然言語） | 必須 |
| `--stack` | CSS フレームワーク | `html-tailwind` |
| `--page <page>` | 特定ページのコンポーネント仕様を追加 | ─ |
| `--feature <feature>` | 特定フィーチャー向けの設計を追加 | `main` |
| `--persist` | 既存 MASTER.md がある場合も上書きする | `false` |

### 対応スタック

| スタック | 説明 |
|---------|------|
| `html-tailwind` | HTML + Tailwind CSS |
| `react-tailwind` | React + Tailwind CSS |
| `vue-tailwind` | Vue.js + Tailwind CSS |

### 出力ファイル

```
design-system/
└── MASTER.md    # デザインシステム SSOT
```

### MASTER.md の構成

```markdown
# Design System MASTER
## 業界カテゴリ（推論結果）
## カラーパレット（Primary/Secondary/Semantic/Neutral）
## タイポグラフィスケール
## スペーシング・レイアウトシステム
## コンポーネントパターン（業界固有）
## インタラクション・モーション規約
## アクセシビリティ要件
## Anti-patterns（業界固有の禁忌パターン）
## Pre-delivery Checklist（U01–U06）
```

### 推論する 5 次元

| 次元 | 内容 |
|------|------|
| 1. 色彩 | 業界感情期待に基づくカラーパレット |
| 2. タイポグラフィ | フォント選択・スケール設計 |
| 3. スペーシング | グリッド・余白システム |
| 4. インタラクション | アニメーション・トランジション |
| 5. アクセシビリティ | WCAG 準拠・コントラスト比 |

### 例

```bash
# 医療系 SaaS のデザインシステム
/kairo:design-system "医療向け予約管理 SaaS。患者が医師の予約を取り見守れる"

# EC サイト、React + Tailwind
/kairo:design-system "ハンドメイド雑貨のオンラインマーケットプレイス" --stack react-tailwind

# 特定ページのコンポーネント仕様を追加
/kairo:design-system "フィンテック決済アプリ" --page checkout

# 強制再生成
/kairo:design-system "SaaS ダッシュボード" --persist
```

### 注意

- **冪等**: `--persist` 未指定時は既存 MASTER.md に差分マージします。
- `spec-design` が自動的にこのコマンドを呼び出すことがあります（`auto_design_system_on_spec_design: true` の場合）。
- `implement` コマンドは MASTER.md が存在すれば自動的に参照します。

---

## issue-generate

`tasks.md` の各タスクを GitHub Issues に変換します。  
`specs/<issue-id>/issue-struct.md` を自動生成し、`imp_generate` への入力を準備します。

### 構文

```
/kairo:issue-generate <feature-name> [--wave P0|P1|all] [--dry-run] [--diff]
```

### 引数・オプション

| 引数/オプション | 説明 | デフォルト |
|---------------|------|-----------|
| `feature-name` | フィーチャー名 | 必須 |
| `--wave` | 生成対象の波形 | `P0` |
| `--dry-run` | Issue を実際に作成せず内容のみ表示 | `false` |
| `--diff` | すでに存在する Issue との差分のみ表示 | `false` |

### 出力

- **GitHub Issues**: 各タスクに対応する Issue（`label: phase:imp` 付き）
- **ローカルファイル**:
  ```
  specs/<issue-id>/
  └── issue-struct.md    # 各 Issue に対応する構造化定義
  ```

### 例

```bash
# P0 タスクのみ Issue 化（最初はこれが多い）
/kairo:issue-generate user-auth-oauth --wave P0

# 全波形の Issue を一括生成
/kairo:issue-generate user-auth-oauth --wave all

# 内容確認のみ（GitHub には作成しない）
/kairo:issue-generate user-auth-oauth --dry-run
```

### 注意

- **前提**: `gh auth login` で GitHub CLI の認証が完了していること。
- `--dry-run` モードでは `gh` コマンドが未設定でも動作します。
- Issue ID の形式は `.kairo/config.json` の `issue_id_format` に従います（例: `042-user-auth-login`）。

---

## issue_init

GitHub Issue または自然言語の課題記述から、構造化タスク定義を生成します。  
IMP 生成のインプットとなる成果物を作成します。

### 構文

```
/kairo:issue_init <issue-id> [issue-url-or-text] [--scope full|lite] [--issue <number>]
```

### 引数・オプション

| 引数/オプション | 説明 | デフォルト |
|---------------|------|-----------|
| `issue-id` | Issue の識別子（ブランチ名から自動推論も可） | 必須 |
| `issue-url-or-text` | GitHub Issue の URL またはテキスト記述 | 対話入力 |
| `--scope full\|lite` | 分解の詳細度 | `full` |
| `--issue <number>` | GitHub Issue 番号で自動フェッチ | ─ |

### スコープの違い

| スコープ | 説明 | 用途 |
|---------|------|------|
| `full` | 詳細分解、技術コンテキスト調査あり | 通常の作業 |
| `lite` | 最小限の分解のみ | 小さなバグフィックス等 |

### 出力ファイル

```
specs/<issue-id>/
├── issue-struct.md    # 構造化 Issue 定義（受け入れ基準・制約・前提条件）
├── tasks.md           # TASK-XXXX 形式のタスク分解
└── note.md            # 技術コンテキストノート（関連コード・依存関係）
```

### 例

```bash
# ブランチにいる場合は issue-id 不要なことも
git checkout -b feature/042-user-auth-login
/kairo:issue_init 042-user-auth-login

# GitHub Issue URL を直接渡す
/kairo:issue_init 042-user-auth-login https://github.com/org/repo/issues/42

# GitHub Issue 番号でフェッチ
/kairo:issue_init 042-user-auth-login --issue 42

# 軽量モード
/kairo:issue_init 099-fix-bug --scope lite
```

### 注意

- **冪等**: 再実行時は既存ファイルに差分マージします。安全に何度でも実行できます。
- issue-id はブランチ名から自動推論されます（`feature/042-xxx` → `042-xxx`）。

---

## imp_generate

Issue 構造定義から IMP（実装管理計画書）を生成・更新します。  
IMP は実装・テスト・レビュー・乖離チェックの**全フェーズで参照される単一の真実の源**です。

### 構文

```
/kairo:imp_generate [issue-id] [--update] [--reviewer arch|security|qa]
```

### 引数・オプション

| 引数/オプション | 説明 | デフォルト |
|---------------|------|-----------|
| `issue-id` | Issue の識別子（省略時はブランチから推論） | ─ |
| `--update` | 既存 IMP を差分更新する（バージョンをインクリメント） | `false` |
| `--reviewer` | 想定レビュアー役割（複数指定可）：`arch\|security\|qa` | ─ |

### 出力ファイル

```
specs/<issue-id>/
├── IMP.md              # 実装管理計画書（メインファイル）
├── IMP-checklist.md    # レビュアーチェックリスト（ペルソナ別）
└── IMP-risks.md        # リスクマトリクス（確率×影響度×軽減策）
```

### IMP.md の主要セクション

```markdown
# IMP: <issue-id>
## Executive Summary（ビジネス判断用の要約）
## 受け入れ基準（AC-ID 付き、EARS 形式）
## API 変更仕様（エンドポイント・リクエスト/レスポンス）
## スキーマ変更（DB テーブル・カラム・インデックス）
## 依存関係・前提条件
## リスク・制約
## タスク一覧（優先度・依存関係）
## テスト戦略
## ロールバック手順
```

### バージョン管理

IMP はセマンティックバージョン（`1.0.0`）で管理されます:

| 変更種別 | バージョン |
|---------|-----------|
| 初回生成 | `1.0.0` |
| `--update`（マイナー変更） | `1.1.0`, `1.2.0`... |
| 大きな仕様変更 | `2.0.0` |

### 例

```bash
# 初回生成
/kairo:imp_generate 042-user-auth-login

# セキュリティレビュアーを想定して生成
/kairo:imp_generate 042-user-auth-login --reviewer security

# 仕様変更後に更新
/kairo:imp_generate 042-user-auth-login --update
```

### 注意

- **前提**: `issue_init` が完了していること（`specs/<issue-id>/issue-struct.md` が存在する）。
- `--update` なしで再実行すると続行確認ダイアログが表示されます。

---

## implement

IMP をインプットとして実装案・パッチ案を生成します。  
TDD モード（デフォルト）ではテストファーストで実装を進めます。

### 構文

```
/kairo:implement [issue-id] [task-id] [--dry-run] [--mode tdd|direct] [--issue <number>]
```

### 引数・オプション

| 引数/オプション | 説明 | デフォルト |
|---------------|------|-----------|
| `issue-id` | Issue の識別子（省略時はブランチから推論） | ─ |
| `task-id` | 特定タスクのみ実装（省略時は全タスク） | ─ |
| `--dry-run` | パッチ案の生成のみ（実ファイル変更なし） | `false` |
| `--mode tdd` | テストファーストモード | `tdd` |
| `--mode direct` | 実装ファーストモード（テストは後で書く） | ─ |
| `--issue <number>` | GitHub Issue に着手通知コメントを投稿する | ─ |

### TDD モードの流れ

```
1. Red Phase  : 失敗するテストを先に作成（red-phase.md に記録）
2. Green Phase: テストが通る最小実装を作成
3. Refactor   : コードを整理（DRY・可読性向上）
```

### 出力ファイル

```
specs/<issue-id>/implements/<task-id>/
├── patch-plan.md     # 変更ファイル一覧・変更内容・完了チェックリスト
├── impl-memo.md      # 実装判断の根拠・代替案の検討・トレードオフ
└── red-phase.md      # TDD の Red フェーズ（失敗テストコード）
```

### デザインシステム統合

`design-system/MASTER.md` が存在する場合、自動的に参照してカラー・タイポグラフィ・スペーシングの制約を適用します。
MASTER.md がない場合は警告を表示しますが実装は継続します。

### 例

```bash
# 全タスクを TDD モードで実装
/kairo:implement 042-user-auth-login

# 特定タスクのみ
/kairo:implement 042-user-auth-login TASK-0001

# 変更内容のプレビューのみ
/kairo:implement 042-user-auth-login --dry-run

# 直接実装モード
/kairo:implement 042-user-auth-login --mode direct
```

### 注意

- **前提**: `imp_generate` が完了していること（`IMP.md` が存在する）。
- 実装後は自動で `drift_check` を実行します（軽量チェック）。

---

## test

IMP の受け入れ基準に対してテストケースマトリクスと検証方針を生成します。  
正常系・異常系・境界値・セキュリティを網羅し、AC-ID でトレースします。

### 構文

```
/kairo:test [issue-id] [task-id] [--exec] [--focus unit|integration|e2e|security|all]
```

### 引数・オプション

| 引数/オプション | 説明 | デフォルト |
|---------------|------|-----------|
| `issue-id` | Issue の識別子 | ─ |
| `task-id` | 特定タスクのみ（省略時は全タスク） | ─ |
| `--exec` | テストを実際に実行して結果を記録する | `false` |
| `--focus` | テストの重点領域 | `all` |

### テスト分類

| 分類 | 内容 |
|------|------|
| `unit` | 単体テスト（関数・メソッドレベル） |
| `integration` | 統合テスト（API・DB 連携） |
| `e2e` | エンドツーエンドテスト（ユーザーシナリオ） |
| `security` | セキュリティテスト（認証・認可・インジェクション） |
| `all` | 上記全て |

### 出力ファイル

```
specs/<issue-id>/tests/<task-id>/
├── testcases.md      # テストケースマトリクス（Priority・AC-ID・期待結果・前提条件）
├── test-plan.md      # テスト計画書（カバレッジ目標・実行順序）
└── test-results.md   # テスト実行結果（--exec 時のみ）
```

### testcases.md の例

```markdown
| TC-ID | Priority | テスト内容 | In | Expected Out | AC-ID |
|-------|----------|-----------|-----|--------------|-------|
| TC-001 | P0 | 正常認証→JWT発行 | 正規クレデンシャル | JWT(200) | REQ-001-AC-01 |
| TC-002 | P0 | 無効クレデンシャル | 誤パスワード | 401 | REQ-001-AC-02 |
| TC-003 | P1 | SQL インジェクション試行 | `' OR 1=1--` | 400 | REQ-001-AC-02 |
```

### 例

```bash
# 全テストケース生成
/kairo:test 042-user-auth-login

# テスト実行して結果まで記録
/kairo:test 042-user-auth-login --exec

# セキュリティだけ集中チェック
/kairo:test 042-user-auth-login --focus security

# 特定タスクのみ
/kairo:test 042-user-auth-login TASK-0001 --focus unit
```

### 注意

- **前提**: `imp_generate` が完了していること。`implement` の後が理想ですが直後でも可。

---

## review

reviewer-oriented な観点で差分・リスク・確認事項を整理します。  
ペルソナ別のチェックリストと、`--adversary` モードによる厳格な独立評価を提供します。

### 構文

```
/kairo:review [issue-id] [--persona arch|security|qa|ui|all] [--adversary] [--pr <pr-number>]
```

### 引数・オプション

| 引数/オプション | 説明 | デフォルト |
|---------------|------|-----------|
| `issue-id` | Issue の識別子 | ─ |
| `--persona` | レビュアー役割（複数可、`\|` 区切り） | `all` |
| `--adversary` | Adversarial Review モードで実行 | `false` |
| `--pr <number>` | 指定した PR 番号のレビュー資料を生成 | ─ |

### ペルソナの視点

| ペルソナ | チェック観点 |
|---------|-------------|
| `arch` | アーキテクチャ整合性・スケーラビリティ・設計パターン |
| `security` | 認証・認可・インジェクション・OWASP Top 10 |
| `qa` | テストカバレッジ・エッジケース・回帰リスク |
| `ui` | UI 実装とデザインシステム（MASTER.md）との整合性 |
| `all` | 上記全て |

### Adversarial Review（`--adversary`）

コンテキストを分離した「批判者」として 6 次元でバイナリ評価します:

| 次元 | 内容 |
|------|------|
| D1 | 機能仕様（受け入れ基準のカバレッジ） |
| D2 | API 契約（エンドポイント・メソッド・レスポンス） |
| D3 | スキーマ（DB カラム・型・インデックス） |
| D4 | テストカバレッジ（P0 テスト必須） |
| D5 | タスク完了（全 TASK の patch-plan.md チェック） |
| D6 | デザイン忠実性（MASTER.md 準拠） |

各次元は `PASS / FAIL / SKIP` のバイナリ評価です。

### 出力ファイル

```
specs/<issue-id>/
├── review-checklist.md    # ペルソナ別チェックリスト
├── risk-matrix.md         # リスクマトリクス（確率×影響度×リスク軽減策）
├── review-questions.md    # 確認質問リスト（人間がレビュー時に答えるべき）
└── adversary-report.md    # Adversarial Review 報告書（--adversary 時のみ）
```

### 例

```bash
# 全ペルソナでレビュー資料生成
/kairo:review 042-user-auth-login --persona all

# セキュリティ観点のみ
/kairo:review 042-user-auth-login --persona security

# Adversarial Review（最も厳格）
/kairo:review 042-user-auth-login --adversary

# PR レビュー資料生成
/kairo:review 042-user-auth-login --pr 142
```

### 注意

- `--adversary` は実装者のコンテキストを意図的に持たないため、表面的には正しく見える欠陥を検出します。
- Phase Gate TEST→OPS は `--adversary` の実行結果が基準になります。

---

## rev

実装コードから逆仕様・API 仕様・スキーマ・要件を生成します。  
IMP との差分箇所に ⚠️ マークを付与し、意図していない変更を可視化します。

### 構文

```
/kairo:rev [issue-id] [--target api|schema|spec|requirements|all]
```

### 引数・オプション

| 引数/オプション | 説明 | デフォルト |
|---------------|------|-----------|
| `issue-id` | Issue の識別子 | ─ |
| `--target` | 生成対象（複数可、`\|` 区切り） | `all` |

### 生成ターゲット

| ターゲット | 内容 |
|-----------|------|
| `api` | エンドポイント・メソッド・リクエスト/レスポンス仕様 |
| `schema` | DB テーブル・カラム・インデックス定義 |
| `spec` | 機能仕様・ユーザーストーリー |
| `requirements` | EARS 形式の要件定義 |
| `all` | 上記全て |

### 出力ファイル

```
specs/<issue-id>/
├── rev-spec.md           # 逆生成した機能仕様（⚠️ 差分マーク付き）
├── rev-api.md            # 逆生成した API 仕様
├── rev-schema.md         # 逆生成したスキーマ
└── rev-requirements.md   # 逆生成した要件定義
```

### IMP との差分マーク

```markdown
## POST /api/auth/login
- Request: { email, password }
- Response: { token, expiresAt }
- ⚠️ **IMP との差分**: IMP では refresh_token も返却する仕様だが実装に含まれていない
```

### 例

```bash
# 全ターゲットを生成
/kairo:rev 042-user-auth-login --target all

# API 仕様のみ生成
/kairo:rev 042-user-auth-login --target api

# スキーマとAPI
/kairo:rev 042-user-auth-login --target api|schema
```

### 注意

- IMP がない場合でも逆仕様生成は可能（差分比較はスキップ）。
- `drift_check` の前に実行すると、より正確な乖離検出ができます。

---

## drift_check

IMP（仕様）と実装の乖離を 6 次元で定量化します。  
drift スコア（0-100）を算出し、`drift-report.md` と `drift-timeline.md` に記録します。

### 構文

```
/kairo:drift_check [issue-id] [--since <commit-ish>] [--threshold <0-100>]
```

### 引数・オプション

| 引数/オプション | 説明 | デフォルト |
|---------------|------|-----------|
| `issue-id` | Issue の識別子 | ─ |
| `--since` | 特定コミット以降の変更のみ検出 | ─ |
| `--threshold` | 警告表示する drift スコアの閾値 | `20` |

### 6 次元評価

| 次元 | 内容 | CRITICAL | WARNING | INFO |
|------|------|---------|---------|------|
| D1 | 機能仕様（AC カバレッジ） | AC が未実装・未テスト | AC が実装のみ（テストなし） | ─ |
| D2 | API 契約 | HTTP メソッド不一致 | パス・レスポンス不一致 | IMP 未記載の新規 EP |
| D3 | スキーマ | 型変更 | カラム追加/削除の不一致 | IMP 未記載のスキーマ変更 |
| D4 | テストカバレッジ | P0 テスト未実装 | カバレッジ目標比10%超過落 | ─ |
| D5 | タスク完了状態 | ─ | チェックリスト未完了 | patch-plan.md 未作成 |
| D6 | デザイン忠実性 | U01–U06 Checklist 未達成 | MASTER.md 定義外カラー | ─ |

- **D6 は `design-system/MASTER.md` が存在しない場合は SKIP（スコアへの影響なし）**

### スコアの解釈

| スコア | 状態 | 推奨アクション |
|--------|------|---------------|
| 0-10 | ✅ Aligned | そのまま進行可能 |
| 11-20 | ⚠️ Minor Drift | 次のサイクルで修正 |
| 21-50 | ⚠️ Significant Drift | IMP 更新か実装修正 |
| 51-100 | ❌ Critical Drift | リリース前に即時対応必要 |

### 出力ファイル

```
specs/<issue-id>/
├── drift-report.md      # 乖離レポート（D1〜D6 詳細）
└── drift-timeline.md    # 実行履歴（実行ごとに追記）
```

### 例

```bash
# 標準実行
/kairo:drift_check 042-user-auth-login

# 特定コミット以降の変更のみチェック
/kairo:drift_check 042-user-auth-login --since main

# 閾値を厳しく設定
/kairo:drift_check 042-user-auth-login --threshold 10
```

### 注意

- **冪等**: 実行するたびに `drift-timeline.md` に記録が蓄積されます。何度実行しても安全です。
- `implement` コマンドの実行後に自動的に軽量チェックが走ります。

---

## sync

Issue・IMP・実装・テスト・ドキュメント全体の整合性を確認・修正します。  
一貫性スコア（0-100）を算出し、不整合を可視化します。

### 構文

```
/kairo:sync [issue-id] [--fix] [--report-only] [--audit]
```

### 引数・オプション

| 引数/オプション | 説明 | デフォルト |
|---------------|------|-----------|
| `issue-id` | Issue の識別子 | ─ |
| `--fix` | 自動修正可能な不整合を修正する | `false` |
| `--report-only` | レポート生成のみ（修正なし） | `false` |
| `--audit` | 監査用の詳細レポートを生成する | `false` |

### 検査項目

| 項目 | 内容 |
|------|------|
| IMP バージョン整合性 | 全成果物が同一 IMP バージョンを参照しているか |
| 受け入れ基準カバレッジ | 全 AC-ID がテストに紐付いているか |
| タスク完了状態 | 全 TASK に patch-plan.md が存在するか |
| API 仕様整合性 | rev-api.md と IMP の API 仕様が一致しているか |
| スキーマ整合性 | rev-schema.md と IMP のスキーマ定義が一致しているか |

### 出力ファイル

```
specs/<issue-id>/
├── sync-report.md     # 整合性レポート（スコア・不整合一覧）
└── sync-actions.md    # 自動修正アクション一覧（--fix 時）
```

### 例

```bash
# レポートのみ確認
/kairo:sync 042-user-auth-login --report-only

# 自動修正も実行
/kairo:sync 042-user-auth-login --fix

# PR 前の最終確認（監査ログ付き）
/kairo:sync 042-user-auth-login --audit
```

### 注意

- **冪等**: 何度実行しても安全です。
- `pr` コマンドの前に実行することを強く推奨します。

---

## pr

IMP の内容から GitHub PR を作成します。  
drift スコア・整合性スコアをエビデンスとして PR 本文に埋め込みます。

### 構文

```
/kairo:pr [issue-id] [--draft] [--base <branch>] [--post-checklist] [--issue <number>]
```

### 引数・オプション

| 引数/オプション | 説明 | デフォルト |
|---------------|------|-----------|
| `issue-id` | Issue の識別子 | ─ |
| `--draft` | ドラフト PR として作成する | `false` |
| `--base <branch>` | マージ先ブランチ | `main` |
| `--post-checklist` | レビューチェックリストをコメントとして投稿する | `false` |
| `--issue <number>` | 関連 Issue を PR に紐付ける | ─ |

### PR 本文の内容

自動生成される PR 本文には以下が含まれます:

```markdown
## Summary
[IMP の Executive Summary から生成]

## 変更内容
[patch-plan.md の変更ファイル一覧]

## テスト
[testcases.md のサマリー]

## エビデンス
- drift スコア: X/100（Aligned / Minor / Significant）
- 整合性スコア: X/100
- Adversarial Review: PASS/FAIL（実施済みの場合）

## チェックリスト
[IMP-checklist.md の内容]
```

### 例

```bash
# 標準 PR 作成
/kairo:pr 042-user-auth-login

# ドラフト PR
/kairo:pr 042-user-auth-login --draft

# レビューチェックリストも投稿
/kairo:pr 042-user-auth-login --post-checklist

# develop ブランチへの PR
/kairo:pr 042-user-auth-login --base develop
```

### 注意

- **前提**: `gh auth login` で認証済みであること。未コミットの変更がないこと。
- PR 作成前に `sync --report-only` で整合性を確認することを推奨します。

---

## baton-status

全 Issue のバトン遷移履歴とラベル状態を表示します。

### 構文

```
/kairo:baton-status [<issue-id>]
```

### 表示内容

- 各 Issue の現在のフェーズラベル
- バトン遷移履歴（`graph/baton-log.json` より）
- Phase Gate 通過/未通過状況

---

## coherence-scan

`graph/coherence.json`（CEG: Conditioned Evidence Graph）を再構築します。  
全成果物の `coherence:` frontmatter を読み込み、依存グラフを更新します。

### 構文

```
/kairo:coherence-scan
```

---

## cli

自然言語入力を kairo コマンドにルーティングします。  
「何をしたいか」を伝えるだけで、適切なコマンドを提案・実行します。

### 構文

```
/kairo:cli [自然言語の指示]
```

### 対応クエリの例

| クエリ | 提案コマンド |
|--------|-------------|
| 「Issue を整理したい」 | `/kairo:issue_init <issue-id>` |
| 「IMP を作って」 | `/kairo:imp_generate <issue-id>` |
| 「実装して」 | `/kairo:implement <issue-id>` |
| 「セキュリティを確認して」 | `/kairo:review <issue-id> --persona security` |
| 「仕様と実装がずれていないか確認して」 | `/kairo:drift_check <issue-id>` |
| 「デザインシステムを作りたい」 | `/kairo:design-system "<説明>"` |
| 「次に何をすればいい？」 | 現状分析 → 次ステップ提案 |

---

## help

コマンド一覧・詳細ヘルプを表示します。

### 構文

```
/kairo:help [command-name | キーワード]
```

### 例

```bash
# 全コマンド一覧を表示
/kairo:help

# 特定コマンドの詳細
/kairo:help implement
/kairo:help drift_check
```

---

## コマンド依存関係マップ

```
spec-steering ─────────────────────────────────────────►（全コマンドが参照）
     │
spec-req ──► spec-design ──► spec-tasks ──► issue-generate
                │
          design-system（自動連携 or 手動実行）

issue-generate
     │
     ▼
issue_init ──► imp_generate ──► implement ──► test ──► review
                                    │                      │
                                    ▼                      ▼
                               drift_check ◄──── rev ──► sync ──► pr
```

> 各コマンドの詳細については個別の節を参照してください。
