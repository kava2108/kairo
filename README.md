# kairo — AI-TDD Engine (VCKD v3.0)

kairo は Claude Code を使った **AI-TDD エンジン**です。  
**VSDD × CoDD × Kiro × kairo × Harness Engineering** を統合した **VCKD**（Verified Coherence Kiro-Driven Development）フレームワークを実装します。

**Issue 作成 → 要件定義 → 技術設計 → 実装 → テスト → 整合性確認 → PR** までを AI エージェントが自律実行し、
人間の操作は原則 **3タッチ** だけです。

## 特徴

| 特徴 | 説明 |
|------|------|
| **Label-Driven Baton** | GitHub ラベル変更がフェーズ間のバトン信号。エージェントが自律起動する |
| **Phase Agent 専門化** | 21 の専門エージェントが各フェーズを担当。汎用エージェントより高精度 |
| **IMP 中心設計** | IMP（実装管理計画書）が Issue〜実装〜ドキュメントの単一の真実の源 |
| **CEG（依存グラフ）** | 全成果物ファイルの `coherence:` frontmatter から有向グラフを自動構築 |
| **Adversarial Review** | コンテキスト分離した独立評価で AI スロップを検出。Phase Gate に組み込み |
| **Drift Correction** | 仕様と実装の乖離を Green/Amber/Gray で定量化・可視化 |
| **Idempotent** | 全コマンドは再実行安全。既存成果物に差分マージ |

## 人間の役割（3 タッチのみ）

```
Touch 1: GitHub Issue を作成し、label: phase:req を付与する
Touch 2: human:review ラベルが付与されたとき、承認/差し戻しを判断する
         （設計の方向転換、Amber ノードの解消判断）
Touch 3: blocked:escalate ラベルのとき、詰まったエージェントをローカルで救出する

AI エージェントが自律実行する作業:
  EARS 要件整理 → 技術設計 → タスク分解 → Issue 生成
  → IMP 生成 → 実装 → テスト → Adversarial Review
  → 逆仕様生成 → 乖離チェック → PR 作成 + エビデンス添付
```

## インストール

リポジトリをクローンして `setup.sh` を実行します。
コマンドは `~/.claude/commands/kairo/` にインストールされ、すべてのプロジェクトで `/kairo:*` として利用できます。

```bash
# 1. リポジトリをクローン
git clone https://github.com/kava2108/kairo.git
cd kairo

# 2. グローバルインストール（全プロジェクトで使用可能）
bash setup.sh

# または、特定プロジェクトのみに限定する場合
# bash setup.sh --project
```

Claude Code を再起動するとコマンドが有効になります。

## クイックスタート

### 自律実行フロー（推奨）

```bash
# Touch 1: Issue を作成して label: phase:req を付与するだけ
gh issue create \
  --title "OAuth 2.0 認証機能" \
  --body "ユーザーが Google アカウントでログインできるようにしたい" \
  --label "phase:req"

# 以降はエージェントが自律実行:
# RequirementsAgent → DesignAgent → ImplementAgent（並列）
# → TestAgent + AdversaryAgent → OpsAgent → ChangeAgent → PR 作成
```

### 手動実行フロー（CI/CD なし環境・従来互換）

```bash
# REQ: 要件定義
/kairo:spec-steering

# フィーチャーが未確定の場合: AI 提案から複数選択して .kiro/specs/ を一括作成
/kairo:spec-req --suggest

# フィーチャーが決まっている場合: 単体で要件定義書を生成
/kairo:spec-req user-auth-oauth

# TDS: 技術設計
/kairo:spec-design user-auth-oauth
/kairo:spec-tasks user-auth-oauth

# ブリッジ: Issue 生成
/kairo:issue-generate user-auth-oauth --wave P0

# IMP: 実装
/kairo:imp_generate 042-user-auth-login
/kairo:implement 042-user-auth-login

# TEST: テスト + Adversarial Review
/kairo:test 042-user-auth-login --vmodel all
/kairo:review 042-user-auth-login --adversary

# OPS: 逆仕様生成 + 乖離チェック
/kairo:rev 042-user-auth-login --target all
/kairo:drift_check 042-user-auth-login

# CHANGE: 同期 + PR
/kairo:sync 042-user-auth-login --audit
/kairo:pr 042-user-auth-login
```

### 自然言語でも使える

```
/kairo:cli 新機能の要件を整理したい
/kairo:cli 仕様と実装がずれていないか確認して
/kairo:cli セキュリティ観点で厳しくチェックして
/kairo:cli バトン状態を確認したい
```

## コマンド一覧

### REQ フェーズ（Kiro による要件定義）

| コマンド | 説明 |
|---------|------|
| `/kairo:spec-steering [--update]` | Steering 文書（技術スタック・規約）を生成 |
| `/kairo:spec-req <feature> [-y]` | EARS 記法の要件定義書を生成。Phase Gate REQ→TDS を実行 |
| `/kairo:spec-req --suggest` | フィーチャー候補を AI が提案 → 選択したものの `.kiro/specs/<feature>/` を一括作成 |

### TDS フェーズ（Kiro による技術設計）

| コマンド | 説明 |
|---------|------|
| `/kairo:spec-design <feature> [-y]` | Mermaid アーキテクチャ図・API 設計・DB 設計を生成 |
| `/kairo:spec-tasks <feature> [-y]` | P0/P1 波形でタスク分解。Phase Gate TDS→IMP を実行 |
| `/kairo:design-system <product-description> [--stack <stack>] [--page <page-name>] [--persist] [--no-design-system] [--feature <feature>]` | プロダクトの自然言語説明から UI/UX デザインシステムを生成し `design-system/MASTER.md` を出力。Claude ネイティブ推論でカラー・タイポグラフィ・コンポーネントパターンを自動決定し CEG ノードとして管理 |

### ブリッジ

| コマンド | 説明 |
|---------|------|
| `/kairo:issue-generate <feature> [--wave P0\|P1\|all]` | tasks.md → GitHub Issues 一括生成（label: phase:imp を付与） |

### IMP フェーズ（実装管理）

| コマンド | 説明 |
|---------|------|
| `/kairo:imp_generate <issue-id> [--update]` | IMP（実装管理計画書）を生成・更新（Kiro 参照 + CEG） |
| `/kairo:implement <issue-id> [task-id]` | IMP ベースで実装案・patch-plan.md を生成。Phase Gate IMP→TEST を実行 |

### TEST フェーズ（V-Model + Adversarial Gate）

| コマンド | 説明 |
|---------|------|
| `/kairo:test <issue-id> [--vmodel unit\|integration\|e2e\|all]` | V-Model + AC-ID トレースリンク付きテストケースを生成 |
| `/kairo:review <issue-id> [--adversary] [--persona arch\|security\|qa]` | ペルソナ別レビュー / `--adversary` で Phase Gate TEST→OPS を実行 |

### OPS フェーズ（整合性確認）

| コマンド | 説明 |
|---------|------|
| `/kairo:rev <issue-id> [--target api\|schema\|spec\|all]` | 実装から逆仕様・API 仕様・スキーマを生成（CEG 更新） |
| `/kairo:drift_check <issue-id> [--since <commit>]` | 仕様と実装の乖離を Green/Amber/Gray で検出。Phase Gate OPS→CHANGE を実行 |

### CHANGE フェーズ

| コマンド | 説明 |
|---------|------|
| `/kairo:sync <issue-id> [--audit]` | 全成果物の整合性確認・修正 |
| `/kairo:pr <issue-id>` | PR 生成 + エビデンス添付（Adversarial / coherence / drift） |

### ユーティリティ

| コマンド | 説明 |
|---------|------|
| `/kairo:impact <issue-id> [--node <node_id>]` | BFS 影響分析（変更の波及範囲） |
| `/kairo:spec-status <feature>` | フェーズ進捗 + CEG サマリー + バトン状態 |
| `/kairo:baton-status [<issue-id>]` | 全 Issue のラベル・バトン遷移履歴を表示 |
| `/kairo:coherence-scan` | graph/coherence.json を再構築 |
| `/kairo:install` | プロジェクト初期セットアップ（`--harness` でフック・ラベルも設定） |
| `/kairo:help` | コマンド一覧・詳細ヘルプ |
| `/kairo:cli` | 自然言語 → コマンドルーティング |

## 価値ストリーム（VSDD）

```
REQ ──► TDS ──► IMP ──► TEST ──► OPS ──► CHANGE
 │        │       │        │        │        │
Kiro   Kiro   kairo  kairo  kairo  kairo
               CoDD     VSDD     CoDD     CoDD
              Harness  Harness  Harness  Harness
```

各フェーズ間に **Phase Gate** があり、整合性チェックを通過しないと次フェーズに進めません。
Gate PASS 時はバトン信号（GitHub ラベル変更）が発行され、次の Phase Agent が自律起動します。

## AUTO_STEP 設定

Phase Gate PASS 後の自動進行は `.vckd/config.yaml` で制御します。

```yaml
harness:
  AUTO_STEP: false   # デフォルト: false（手動承認モード）
```

| モード | AUTO_STEP | 動作 |
|--------|-----------|------|
| **Manual Baton**（推奨・初期） | `false` | Gate PASS → `pending:next-phase` ラベル + コメント投稿。人間が `approve` ラベルで進行 |
| **Auto Baton**（本番） | `true` | Gate PASS → 即座に次フェーズラベルに変更。人間の操作不要 |

## 成果物の場所

```
.kiro/
├── steering/              # プロジェクト規約・技術スタック
│   ├── structure.md
│   └── tech.md
└── specs/<feature>/       # フィーチャー単位の仕様
    ├── requirements.md    # EARS 要件定義（REQ）
    ├── design.md          # アーキテクチャ設計（TDS）
    └── tasks.md           # タスク分解・P0/P1 波形（TDS）

specs/<issue-id>/          # Issue 単位の全成果物（issue_init 以降の全コマンド出力先）
├── issue-struct.md        # issue_init の出力
├── tasks.md
├── note.md
├── IMP.md                 # imp_generate の出力
├── IMP-checklist.md
├── IMP-risks.md
├── implements/            # implement の出力
│   └── <task-id>/
│       ├── patch-plan.md
│       └── impl-memo.md
├── tests/                 # test の出力
│   └── <task-id>/
│       ├── testcases.md
│       ├── test-plan.md
│       └── test-results.md
├── rev-spec.md            # rev の出力
├── rev-api.md
├── rev-schema.md
├── rev-requirements.md
├── drift-report.md        # drift_check の出力
├── drift-timeline.md
├── review-checklist.md    # review の出力
├── risk-matrix.md
├── review-questions.md
├── adversary-report.md
├── sync-report.md         # sync の出力
└── sync-actions.md

graph/
├── coherence.json         # グローバル CEG（依存グラフ）
└── baton-log.json         # バトン遷移履歴

.kairo/
├── config.json
└── hooks/                 # Claude Code hooks（バトン発行）
    ├── post-tool-use.sh
    └── agents/            # Phase Agent システムプロンプト
        ├── requirements-agent.md
        ├── design-agent.md
        ├── implement-agent.md
        ├── test-agent.md
        ├── adversary-agent.md
        ├── ops-agent.md
        └── change-agent.md
```

## 継承関係

kairo は **tsumigi**（kava2108）の後継プロジェクトです。tsumigi は [tsumiki](https://github.com/classmethod/tsumiki) の設計思想を継承していました。
kairo はその哲学をさらに昇華し、**AI 開発プロセスを"回路化"する次世代 AI-TDD エンジン**です。

| tsumigi (前身) | kairo v1.0 |
|---------------|------------|
| `/tsumigi:spec-steering` | `/kairo:spec-steering` |
| `/tsumigi:spec-req` | `/kairo:spec-req`（EARS + CEG frontmatter 強化） |
| `/tsumigi:spec-design` | `/kairo:spec-design` + `/kairo:design-system`（UI/UX デザインシステム生成） |
| `/tsumigi:spec-tasks` | `/kairo:spec-tasks` |
| `/tsumigi:issue-generate` | `/kairo:issue-generate` |
| `/tsumigi:imp_generate` | `/kairo:imp_generate` |
| `/tsumigi:implement` | `/kairo:implement` |
| `/tsumigi:test` | `/kairo:test` |
| `/tsumigi:review --adversary` | `/kairo:review --adversary`（D6 Design Fidelity 追加予定） |
| `/tsumigi:rev` | `/kairo:rev` |
| `/tsumigi:drift_check` | `/kairo:drift_check` |
| `/tsumigi:sync` | `/kairo:sync` |
| `/tsumigi:pr` | `/kairo:pr` |
| ─ | `/kairo:design-system`（kairo 独自・Claude ネイティブ推論） |

## ライセンス

MIT
