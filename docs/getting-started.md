# kairo はじめてガイド

> **このガイドの対象**: kairo をはじめて使う方。  
> インストールから最初の PR 作成まで、一通りの流れを体験します。

---

## 目次

1. [kairo とは何か](#1-kairo-とは何か)
2. [インストール](#2-インストール)
3. [2 つのワークフロー](#3-2-つのワークフロー)
4. [チュートリアル：機能を一から作る](#4-チュートリアル機能を一から作る)
   - [フェーズ 0: プロジェクトに kairo を導入する](#フェーズ-0-プロジェクトに-kairo-を導入する)
   - [フェーズ 1: 要件定義（REQ）](#フェーズ-1-要件定義req)
   - [フェーズ 2: 技術設計（TDS）](#フェーズ-2-技術設計tds)
   - [フェーズ 3: Issue 生成からタスク開始（IMP 準備）](#フェーズ-3-issue-生成からタスク開始imp-準備)
   - [フェーズ 4: 実装（IMP）](#フェーズ-4-実装imp)
   - [フェーズ 5: テスト・レビュー（TEST）](#フェーズ-5-テストレビューtest)
   - [フェーズ 6: 整合性確認・PR（OPS/CHANGE）](#フェーズ-6-整合性確認propschange)
5. [成果物の場所と構造](#5-成果物の場所と構造)
6. [よくあるパターン](#6-よくあるパターン)
7. [困ったときは](#7-困ったときは)

---

## 1. kairo とは何か

kairo は **Claude Code のスラッシュコマンド群**です。  
「Issue を作る → 要件を定義する → 設計する → 実装する → テストする → PR を出す」という開発フローを、
AI が一貫して補佐します。

### コアコンセプト

| 用語 | 意味 |
|------|------|
| **VCKD** | Verified Coherence Kiro-Driven Development。kairo が実装するフレームワーク |
| **IMP** | Implementation Management Plan（実装管理計画書）。Issue〜実装〜ドキュメントの **単一の真実の源** |
| **CEG** | Conditioned Evidence Graph。成果物間の依存グラフ。整合性チェックに使用 |
| **Phase Gate** | フェーズ間の整合性チェックポイント。Gate を通過しないと次フェーズに進めない |
| **Drift** | 仕様（IMP）と実装の乖離。`drift_check` で定量化 |
| **Baton** | GitHub ラベル変更によるフェーズ間の引き継ぎ信号 |

### VCKD パイプライン

```
REQ ──► TDS ──► IMP ──► TEST ──► OPS ──► CHANGE
 │        │       │        │        │        │
要件     設計    実装     テスト  整合性   PR作成
定義     分解    管理     品質    確認
```

各フェーズの間に **Phase Gate**（整合性チェック）があります。  
Gate PASS 時にバトン信号（GitHub ラベル変更）が発行され、次のフェーズが起動します。

---

## 2. インストール

### 前提条件

- **Claude Code** がインストール済みであること
- `git` が使えること
- GitHub CLI（`gh`）— PR 作成・Issue 操作に使用（任意だが推奨）

### インストール手順

```bash
# kairo リポジトリをクローン
git clone https://github.com/kava2108/kairo.git
cd kairo

# グローバルインストール（全プロジェクトで /kairo:* が使えるようになる）
bash setup.sh
```

Claude Code を **再起動**するとコマンドが有効になります。

> **特定プロジェクトのみ**に限定したい場合:
> ```bash
> bash setup.sh --project
> # プロジェクトの .claude/commands/kairo/ にインストールされる
> ```

---

## 3. 2 つのワークフロー

kairo には 2 つの使い方があります。

### A. 自律実行フロー（推奨）

GitHub Issue を作成してラベルを付けるだけ。エージェントが自動実行します。

```bash
gh issue create \
  --title "OAuth 2.0 認証機能" \
  --body "Google アカウントでログインできるようにしたい" \
  --label "phase:req"
```

以降、`RequirementsAgent → DesignAgent → ImplementAgent → TestAgent → OpsAgent → ChangeAgent` が
バトン信号を受け取って順番に起動します。人間の操作は原則 **3 タッチ**のみ。

### B. 手動実行フロー（このガイドで説明）

各コマンドを自分で実行します。CI/CD がない環境や、各ステップを確認しながら進めたい場合に最適です。

---

## 4. チュートリアル：機能を一から作る

例として「ユーザー認証機能（user-auth-oauth）」を実装する流れで説明します。

---

### フェーズ 0: プロジェクトに kairo を導入する

作業したいプロジェクトのルートで実行します。

```
/kairo:install
```

**何が起きるか**:
- `.kairo/config.json` が生成される（プロジェクト設定）
- `KAIRO.md` が生成される（プロジェクト固有のコンテキスト）
- `specs/` ディレクトリが作成される（全成果物の置き場所）

> **冪等性**: 既存ファイルがあっても上書きしないので、何度実行しても安全です。

---

### フェーズ 1: 要件定義（REQ）

#### ステップ 1-1: Steering 文書を生成する

まずプロジェクトの技術スタック・規約を Steering 文書として生成します。
全コマンドがこの文書を参照します。

```
/kairo:spec-steering
```

**生成物**:
- `.kiro/steering/structure.md` — ディレクトリ構成・命名規則
- `.kiro/steering/tech.md` — 技術スタック・フレームワーク
- `.kiro/steering/product.md` — プロダクト概要

> **ポイント**: コードベースを自動スキャンして現在の構成を把握します。既存プロジェクトでも最初に実行してください。

#### ステップ 1-2: 要件定義書を生成する

```
/kairo:spec-req user-auth-oauth
```

Claude が EARS（Easy Approach to Requirements Syntax）形式で要件を整理します。  
各受け入れ基準に一意の ID（`REQ-001-AC-01` など）が付与され、後工程のトレーサビリティを確保します。

**生成物**:
- `.kiro/specs/user-auth-oauth/requirements.md` — EARS 形式の要件定義書

> **ヒント**: フィーチャーが決まっていない場合は `--suggest` モードでアイデアを提案してもらえます:
> ```
> /kairo:spec-req --suggest
> ```

---

### フェーズ 2: 技術設計（TDS）

#### ステップ 2-1: 技術設計書を生成する

```
/kairo:spec-design user-auth-oauth
```

要件定義書をもとに、アーキテクチャ・API 設計・DB 設計を Mermaid 図付きで生成します。  
UI/UX が含まれる場合、`design-system/MASTER.md` も自動生成されます。

**生成物**:
- `.kiro/specs/user-auth-oauth/design.md` — 技術設計書
- `design-system/MASTER.md` — UI/UX デザインシステム（UI ありの場合）

#### ステップ 2-2: タスクに分解する

```
/kairo:spec-tasks user-auth-oauth
```

設計書を P0/P1 波形の実装タスクに分解します。  
依存関係を自動整理し、並列実行可能なタスクを識別します。

```
P0（並列実行可能）:
  1.1 DB スキーマ作成（マイグレーション）
  1.2 JWT 認証ミドルウェア基盤

P1（P0 完了後）:
  2.1 OAuth コールバックエンドポイント実装（依存: 1.1, 1.2）
  2.2 ユーザープロフィール取得 API（依存: 1.1, 1.2）

P2（P1 完了後）:
  3.1 フロントエンド認証 UI（依存: 2.1）
```

**生成物**:
- `.kiro/specs/user-auth-oauth/tasks.md` — タスク分解

---

### フェーズ 3: Issue 生成からタスク開始（IMP 準備）

#### ステップ 3-1: GitHub Issues を一括生成する

```
/kairo:issue-generate user-auth-oauth --wave P0
```

`tasks.md` の P0 タスクを GitHub Issues に変換します。  
各 Issue に `label: phase:imp` が付与されます。

**生成物**:
- GitHub Issues（各タスクに対応）
- `specs/<issue-id>/issue-struct.md`（各 Issue ごと）

> `--wave all` で P0/P1/P2 全てを一括生成することもできます。

#### ステップ 3-2: Issue ごとに作業开始

Issue ごとにブランチを作り、構造化します。

```bash
# ブランチを作成
git checkout -b feature/042-user-auth-login

# Issue を構造化する
/kairo:issue_init 042-user-auth-login
```

**何が起きるか**:
- GitHub Issue から要件・受け入れ基準・技術コンテキストを収集
- タスクを TASK-XXXX 形式に分解
- 技術コンテキストノートを生成

**生成物** (`specs/042-user-auth-login/` 以下):
- `issue-struct.md` — 構造化された Issue 定義
- `tasks.md` — TASK 分解
- `note.md` — 技術コンテキスト

---

### フェーズ 4: 実装（IMP）

#### ステップ 4-1: IMP（実装管理計画書）を生成する

```
/kairo:imp_generate 042-user-auth-login
```

IMP は **このフィーチャーの単一の真実の源**です。  
以降の実装・テスト・レビュー・乖離チェックは全て IMP を参照します。

**生成物** (`specs/042-user-auth-login/` 以下):
- `IMP.md` — 実装管理計画書（受け入れ基準・API 仕様・スキーマ・リスク・タスク一覧）
- `IMP-checklist.md` — レビュアーチェックリスト
- `IMP-risks.md` — リスクマトリクス

> **IMP の構成**（主要セクション）:
> - Executive Summary（経営・ビジネス判断用の要約）
> - 受け入れ基準（AC-ID 付き）
> - API 変更仕様
> - スキーマ変更
> - リスク・依存関係
> - タスク一覧と実装順序

#### ステップ 4-2: 実装案を生成する

```
/kairo:implement 042-user-auth-login
```

IMP のタスクを順番に実装します。デフォルトは **TDD モード**（テストファースト）。

```bash
# 特定タスクだけ実装する場合
/kairo:implement 042-user-auth-login TASK-0001

# 実装内容のプレビューのみ（ファイル変更なし）
/kairo:implement 042-user-auth-login --dry-run

# 直接実装モード（テストを後から書く場合）
/kairo:implement 042-user-auth-login --mode direct
```

**生成物** (`specs/042-user-auth-login/implements/<task-id>/` 以下):
- `patch-plan.md` — 変更ファイル一覧・変更内容・完了チェックリスト
- `impl-memo.md` — 実装判断の根拠・代替案の検討
- `red-phase.md` — TDD の Red フェーズ（失敗テスト先行実装）

---

### フェーズ 5: テスト・レビュー（TEST）

#### ステップ 5-1: テストケースを生成する

```
/kairo:test 042-user-auth-login
```

正常系・異常系・境界値・セキュリティを網羅したテストケースマトリクスを生成します。  
IMP の受け入れ基準 ID と紐付いており、カバレッジを追跡できます。

```bash
# テストを実際に実行して結果を記録する
/kairo:test 042-user-auth-login --exec

# セキュリティテストに集中する
/kairo:test 042-user-auth-login --focus security
```

**生成物** (`specs/042-user-auth-login/tests/<task-id>/` 以下):
- `testcases.md` — テストケースマトリクス（AC-ID トレース付き）
- `test-plan.md` — テスト計画書
- `test-results.md` — テスト実行結果（`--exec` 時）

#### ステップ 5-2: レビュー資料を生成する

```
/kairo:review 042-user-auth-login --persona all
```

アーキテクチャ・セキュリティ・QA・UI の各ペルソナ視点でチェックリストとリスクマトリクスを生成します。

```bash
# セキュリティ観点でのみレビュー
/kairo:review 042-user-auth-login --persona security

# Adversarial Review（最も厳しいモード）
# コンテキストを分離した「批判者」として 6 次元評価を実行
/kairo:review 042-user-auth-login --adversary
```

> **Adversarial Review とは**:  
> --adversary モードでは、実装者のコンテキストを持たない「批判者」として評価します。
> AI スロップ（表面的に正しく見えるが実質的に欠陥がある実装）を検出するのに効果的です。
> 6 次元評価: 機能仕様・API 契約・スキーマ・テストカバレッジ・タスク完了・デザイン忠実性

**生成物** (`specs/042-user-auth-login/` 以下):
- `review-checklist.md` — ペルソナ別チェックリスト
- `risk-matrix.md` — リスクマトリクス
- `review-questions.md` — 確認質問リスト
- `adversary-report.md` — Adversarial Review 報告書（`--adversary` 時）

---

### フェーズ 6: 整合性確認・PR（OPS/CHANGE）

#### ステップ 6-1: 逆仕様を生成する

```
/kairo:rev 042-user-auth-login --target all
```

実装コードから逆に仕様・API ドキュメント・スキーマを生成します。  
IMP との差分箇所には ⚠️ マークが付き、意図しない変更を可視化します。

**生成物** (`specs/042-user-auth-login/` 以下):
- `rev-spec.md` — 逆生成した機能仕様
- `rev-api.md` — 逆生成した API 仕様
- `rev-schema.md` — 逆生成したスキーマ
- `rev-requirements.md` — 逆生成した要件

#### ステップ 6-2: 乖離チェックを実行する

```
/kairo:drift_check 042-user-auth-login
```

IMP と実装の乖離を **6 次元**で定量化します（drift スコア 0-100）。

| 次元 | 内容 |
|------|------|
| D1 | 機能仕様（受け入れ基準のカバレッジ） |
| D2 | API 契約（エンドポイント・レスポンス） |
| D3 | スキーマ（DB カラム・型） |
| D4 | テストカバレッジ（目標 vs 実際） |
| D5 | タスク完了状態 |
| D6 | デザイン忠実性（MASTER.md 準拠・UI あり時のみ） |

```
drift スコア: 8/100 — ✅ Aligned
CRITICAL: 0件 / WARNING: 2件 / INFO: 3件
```

**生成物** (`specs/042-user-auth-login/` 以下):
- `drift-report.md` — 乖離レポート
- `drift-timeline.md` — 乖離の時系列記録（実行ごとに追記）

#### ステップ 6-3: 全体の整合性を確認する

```
/kairo:sync 042-user-auth-login --report-only
```

Issue・IMP・実装・テスト・ドキュメントの整合性スコアを算出します。

```bash
# 自動修正も実行する
/kairo:sync 042-user-auth-login --fix
```

**生成物** (`specs/042-user-auth-login/` 以下):
- `sync-report.md` — 整合性レポート
- `sync-actions.md` — 修正アクション一覧

#### ステップ 6-4: PR を作成する

```
/kairo:pr 042-user-auth-login
```

IMP の内容から PR タイトル・本文を自動生成し、drift スコア・整合性スコアをエビデンスとして埋め込みます。

```bash
# ドラフト PR として作成する
/kairo:pr 042-user-auth-login --draft

# PR 作成 + レビューチェックリストをコメントに投稿
/kairo:pr 042-user-auth-login --post-checklist
```

---

## 5. 成果物の場所と構造

### Kiro フェーズ（REQ/TDS）の成果物

```
.kiro/
├── steering/
│   ├── structure.md   # ディレクトリ構成・命名規則
│   ├── tech.md        # 技術スタック・フレームワーク
│   └── product.md     # プロダクト概要
└── specs/<feature>/
    ├── requirements.md  # EARS 要件定義
    ├── design.md        # 技術設計書
    └── tasks.md         # タスク分解
```

### Issue フェーズ以降の成果物

```
specs/<issue-id>/
├── issue-struct.md      # issue_init の出力
├── tasks.md
├── note.md
├── IMP.md               # メイン: 全フェーズの真実の源
├── IMP-checklist.md
├── IMP-risks.md
├── implements/
│   └── TASK-XXXX/
│       ├── patch-plan.md
│       ├── impl-memo.md
│       └── red-phase.md
├── tests/
│   └── TASK-XXXX/
│       ├── testcases.md
│       ├── test-plan.md
│       └── test-results.md
├── rev-spec.md          # rev の出力
├── rev-api.md
├── rev-schema.md
├── rev-requirements.md
├── drift-report.md      # drift_check の出力
├── drift-timeline.md
├── review-checklist.md  # review の出力
├── risk-matrix.md
├── review-questions.md
├── adversary-report.md
├── sync-report.md       # sync の出力
└── sync-actions.md
```

### デザインシステム

```
design-system/
└── MASTER.md    # UI/UX デザインシステム（spec-design または design-system コマンドで生成）
```

---

## 6. よくあるパターン

### パターン A: レビュー直前に全部確認したい

```bash
# 全ペルソナでレビュー資料を生成
/kairo:review 042-user-auth-login --persona all

# 乖離がないか確認
/kairo:drift_check 042-user-auth-login

# 全体整合性確認
/kairo:sync 042-user-auth-login --report-only
```

### パターン B: 途中から作業を再開する

```bash
# 今どこにいるか確認する
/kairo:cli 042-user-auth-login の作業はどこまで進んでいる？

# または baton-status で確認
/kairo:baton-status 042-user-auth-login
```

### パターン C: 仕様が変わった

```bash
# IMP を更新する
/kairo:imp_generate 042-user-auth-login --update

# 乖離を再チェック
/kairo:drift_check 042-user-auth-login
```

### パターン D: UI/UX も含めて設計したい

```bash
# デザインシステムを先に作成
/kairo:design-system "医療向け予約管理 SaaS" --stack html-tailwind

# 技術設計（MASTER.md が自動参照される）
/kairo:spec-design appointment-booking

# 実装（MASTER.md のカラー・フォント制約が自動適用）
/kairo:implement 043-appointment-ui
```

### パターン E: わからなくなったら

```bash
# 自然言語でコマンドを聞く
/kairo:cli セキュリティ観点でチェックしたい
/kairo:cli 仕様と実装がずれていないか確認して
/kairo:cli 全コマンドを教えて
```

---

## 7. 困ったときは

### Q. コマンドが見つからない

Claude Code を **再起動**してください。インストール後に再起動が必要です。  
再起動後も見つからない場合は `setup.sh` が正常に完了したか確認してください:

```bash
ls ~/.claude/commands/kairo/
```

### Q. IMP.md が存在しないと言われる

各コマンドには前提とするコマンドがあります。以下の順番で実行してください:

```
issue_init → imp_generate → implement → test → review → rev → drift_check → sync → pr
```

### Q. drift スコアが高い（乖離が大きい）

```bash
# まず何が乖離しているか確認
/kairo:drift_check <issue-id>

# IMP を最新実装に合わせて更新する場合
/kairo:imp_generate <issue-id> --update

# または実装が間違っている場合 → IMP を参照して修正
```

### Q. Adversarial Review が FAIL になった

Adversarial Review の FAIL は「批判者の視点で問題がある」ことを意味します。  
`adversary-report.md` の各次元の詳細を確認し、CRITICAL 項目から優先して対応してください。

### Q. どのコマンドを使えばいいかわからない

```
/kairo:cli [やりたいことを自然言語で書く]
```

例:
```
/kairo:cli テストケースがちゃんと揃っているか確認したい
/kairo:cli 実装前にリスクを洗い出したい
/kairo:cli PR のチェックリストを作りたい
```

---

> **次のステップ**: 各コマンドの詳細オプションや出力形式については [コマンドリファレンス](./command-reference.md) を参照してください。
