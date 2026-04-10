# kairo × ui-ux-pro-max-skill 統合要件仕様書 v1.0

**プロジェクト名**: kairo  
**対象バージョン**: kairo v1.0（tsumigi v3.0 継承）  
**作成日**: 2026-04-11  
**ステータス**: Draft  
**参照リポジトリ**:
- [kava2108/tsumigi](https://github.com/kava2108/tsumigi) — 継承元 AI-TDD エンジン
- [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) — 統合対象 UI/UX デザインインテリジェンス

---

## 目次

1. [プロジェクト概要](#1-プロジェクト概要)
2. [kairo の位置づけ：tsumigi からの継承とリネーム](#2-kairo-の位置づけtsumigi-からの継承とリネーム)
3. [ui-ux-pro-max-skill の概要](#3-ui-ux-pro-max-skill-の概要)
4. [統合の目的と設計原則](#4-統合の目的と設計原則)
5. [アーキテクチャ概要](#5-アーキテクチャ概要)
6. [機能要件：tsumigi → kairo リネーム](#6-機能要件tsumigi--kairo-リネーム)
7. [機能要件：ui-ux-pro-max-skill 統合](#7-機能要件ui-ux-pro-max-skill-統合)
8. [新規コマンド設計](#8-新規コマンド設計)
9. [ディレクトリ構造](#9-ディレクトリ構造)
10. [CEG (Conditioned Evidence Graph) 拡張](#10-ceg-conditioned-evidence-graph-拡張)
11. [Phase Gate 拡張：UI/UX フェーズの組み込み](#11-phase-gate-拡張uiux-フェーズの組み込み)
12. [非機能要件](#12-非機能要件)
13. [MVP 最小実装セット](#13-mvp-最小実装セット)
14. [移行ガイド（tsumigi → kairo）](#14-移行ガイドtsumigi--kairo)
15. [付録](#15-付録)

---

## 1. プロジェクト概要

### 1.1 kairo とは

**kairo**（回路）は、tsumigi の思想を継承した次世代 AI-TDD エンジンである。  
tsumigi が「仕様と実装を紡ぐ（weave）」エンジンであるのに対し、  
kairo は「AI 開発プロセスを**回路化**（circuit）」する——すなわち、要件定義から UI 実装まで、  
すべての工程が **接続され、検証され、自律的に流れ続ける** 開発パイプラインを実現する。

### 1.2 プロジェクトゴール

| ゴール | 内容 |
|--------|------|
| **G1: tsumigi 継承** | tsumigi v3.0（VCKD フレームワーク）のソースを kairo にコピーし、コマンド体系を `/kairo:*` にリネーム |
| **G2: UI/UX 回路化** | ui-ux-pro-max-skill のデザインインテリジェンス（161 推論ルール・67 スタイル・57 フォントペア）を VCKD パイプラインに統合 |
| **G3: 設計の自動生成** | REQ フェーズの要件からデザインシステムを AI が自動生成し、TDS フェーズの技術設計に接続する |
| **G4: 品質の自動検証** | 生成された UI コードを kairo の Adversarial Review・Phase Gate で検証し、乖離を定量化する |

---

## 2. kairo の位置づけ：tsumigi からの継承とリネーム

### 2.1 継承するコンポーネント

tsumigi v3.0 の以下をすべて kairo に取り込む。

| tsumigi コンポーネント | kairo での扱い |
|-----------------------|----------------|
| `commands/` — 全スラッシュコマンド | `/kairo:*` にリネーム（後述） |
| `.tsumigi/` — 設定・フック・エージェント | `.kairo/` にリネーム |
| `.vckd/` — Harness 設定 | そのまま継承 |
| `.kiro/` — Kiro ステアリング | そのまま継承 |
| `templates/` | そのまま継承 |
| `graph/` — CEG | そのまま継承 |
| `specs/` | そのまま継承 |
| `setup.sh` | `setup.sh`（インストール先を `~/.claude/commands/kairo/` に変更） |
| `CLAUDE.md` | kairo 向けに更新 |

### 2.2 コマンドリネームマッピング

| tsumigi コマンド | kairo コマンド | 変更内容 |
|----------------|---------------|----------|
| `/tsumigi:spec-steering` | `/kairo:spec-steering` | コマンド名のみ変更 |
| `/tsumigi:spec-req` | `/kairo:spec-req` | 同上 |
| `/tsumigi:spec-design` | `/kairo:spec-design` | UI/UX 連携を追加（§7 参照） |
| `/tsumigi:spec-tasks` | `/kairo:spec-tasks` | 同上 |
| `/tsumigi:issue-generate` | `/kairo:issue-generate` | 同上 |
| `/tsumigi:imp_generate` | `/kairo:imp_generate` | デザインシステム参照を追加 |
| `/tsumigi:implement` | `/kairo:implement` | UI コンポーネント実装を追加 |
| `/tsumigi:test` | `/kairo:test` | UI テスト（Visual Regression）連携を追加 |
| `/tsumigi:review` | `/kairo:review` | UI/UX Adversarial Review を追加 |
| `/tsumigi:rev` | `/kairo:rev` | 同上 |
| `/tsumigi:drift_check` | `/kairo:drift_check` | デザインドリフト次元を追加 |
| `/tsumigi:sync` | `/kairo:sync` | 同上 |
| `/tsumigi:pr` | `/kairo:pr` | 同上 |
| `/tsumigi:baton-status` | `/kairo:baton-status` | 変更なし |
| `/tsumigi:coherence-scan` | `/kairo:coherence-scan` | 変更なし |
| `/tsumigi:spec-status` | `/kairo:spec-status` | 変更なし |
| `/tsumigi:impact` | `/kairo:impact` | 変更なし |
| `/tsumigi:install` | `/kairo:install` | ui-ux-pro-max-skill セットアップを追加 |
| `/tsumigi:help` | `/kairo:help` | 変更なし |
| `/tsumigi:cli` | `/kairo:cli` | UI/UX ルーティングを追加 |
| `/tsumigi:rescue` | `/kairo:rescue` | 変更なし |

### 2.3 設定ファイルのリネーム

| 変更前 | 変更後 |
|--------|--------|
| `.tsumigi/config.json` | `.kairo/config.json` |
| `.tsumigi/hooks/` | `.kairo/hooks/` |
| `.tsumigi/agents/` | `.kairo/agents/` |
| `tsumigi:` frontmatter キー | `kairo:` frontmatter キー（後方互換エイリアスを維持） |

---

## 3. ui-ux-pro-max-skill の概要

### 3.1 提供機能

ui-ux-pro-max-skill（UUPM）は、AI コーディングアシスタント向けのデザインインテリジェンスツールキットである。

| 機能 | 規模 | 詳細 |
|------|------|------|
| **UI スタイル** | 67 種 | Glassmorphism, Claymorphism, Minimalism, Brutalism, Neumorphism, Bento Grid, Dark Mode, AI-Native UI 等 |
| **カラーパレット** | 161 種 | 業界別パレット（161 プロダクトタイプに 1:1 対応） |
| **フォントペアリング** | 57 種 | Google Fonts インポート付き |
| **チャートタイプ** | 25 種 | ダッシュボード・分析向け推奨 |
| **テックスタック** | 15 種 | React, Next.js, Astro, Vue, Nuxt.js, Nuxt UI, Svelte, SwiftUI, React Native, Flutter, HTML+Tailwind, shadcn/ui, Jetpack Compose, Angular, Laravel |
| **UX ガイドライン** | 99 件 | ベストプラクティス・アンチパターン・アクセシビリティルール |
| **業界推論ルール** | 161 件 | 業界別デザインシステム自動生成エンジン（v2.0 新機能） |

### 3.2 アーキテクチャ

```
src/ui-ux-pro-max/
├── data/                    # CSVデータベース（スタイル・カラー・フォント等）
│   ├── products.csv         # 161 プロダクトタイプ
│   ├── styles.csv           # 67 UIスタイル
│   ├── colors.csv           # 161 カラーパレット
│   ├── typography.csv       # 57 フォントペアリング
│   ├── landing.csv          # ランディングページパターン
│   ├── charts.csv           # チャートタイプ
│   ├── ux.csv               # UXガイドライン
│   └── stacks/              # スタック別ガイドライン
├── scripts/
│   ├── search.py            # CLIエントリポイント（BM25 + regex ハイブリッド）
│   ├── core.py              # 検索エンジン
│   └── design_system.py     # デザインシステム生成エンジン
└── templates/
    ├── base/                # 共通テンプレート
    └── platforms/           # プラットフォーム別設定
```

### 3.3 デザインシステム生成フロー

```
ユーザーリクエスト（例: "SaaS向けランディングページ"）
    │
    ▼
5並列検索（プロダクトタイプ・スタイル・カラー・ランディング・タイポグラフィ）
    │
    ▼
推論エンジン（BM25 ランキング + 業界別ルール適用）
    │
    ▼
完全なデザインシステムを出力
    （パターン・スタイル・カラー・タイポグラフィ・アンチパターン・チェックリスト）
```

---

## 4. 統合の目的と設計原則

### 4.1 統合の目的

kairo の VCKD パイプライン（REQ → TDS → IMP → TEST → OPS → CHANGE）に、  
UUPM のデザインインテリジェンスを **フローとして自然に統合** することで、  
UI/UX 設計から実装・検証まで、人間の介入を最小化した自律的なフロントエンド開発を実現する。

### 4.2 設計原則

| 原則 | 内容 |
|------|------|
| **Design-as-Code** | デザインシステムは成果物ファイル（`design-system/MASTER.md`）として管理し、CEG ノードとして可視化する |
| **UI-first TDD** | UI コンポーネントも IMP → testcases.md の V-Model TDD サイクルで検証する |
| **フェーズ統合** | デザインシステム生成は TDS フェーズに統合し、Phase Gate で品質を担保する |
| **後方互換性** | tsumigi コマンドは kairo でも動作するエイリアスを維持する |
| **Idempotent** | 全コマンドは再実行安全。生成されたデザインアセットに差分マージする |

---

## 5. アーキテクチャ概要

### 5.1 kairo 統合アーキテクチャ

```
┌─────────────────────────────────────────────────────────────────────┐
│  kairo VCKD Pipeline (v1.0)                                         │
│                                                                     │
│  REQ ──► TDS ──► IMP ──► TEST ──► OPS ──► CHANGE                  │
│   │        │       │        │        │        │                     │
│  Kiro    Kiro  kairo    kairo    kairo    kairo                     │
│   │       │+UUPM  CoDD     VSDD     CoDD     CoDD                  │
│   │       │                                                         │
│   │  ┌────┴──────────────────────────┐                             │
│   │  │  ui-ux-pro-max Layer          │                             │
│   │  │                               │                             │
│   │  │  /kairo:design-system         │                             │
│   │  │    → design-system/MASTER.md  │  (TDS フェーズ統合)         │
│   │  │  /kairo:spec-design (拡張)    │                             │
│   │  │    → design.md + MASTER.md    │                             │
│   │  │  /kairo:implement (拡張)      │                             │
│   │  │    → UIコンポーネントコード   │                             │
│   │  └───────────────────────────────┘                             │
└─────────────────────────────────────────────────────────────────────┘
```

### 5.2 UUPM スキルの配置

```
kairo インストール後のプロジェクト構造（UUPM 統合部分）:

.claude/skills/ui-ux-pro-max/       ← UUPM スキル（自動インストール）
    ├── data/                        ← 161 推論ルール・67 スタイル等
    ├── scripts/search.py            ← デザインシステム生成スクリプト
    └── templates/

design-system/                      ← 生成されたデザインシステム成果物
    ├── MASTER.md                    ← グローバルデザインシステム（SSOT）
    └── pages/                       ← ページ別オーバーライド
        ├── landing.md
        ├── dashboard.md
        └── ...
```

---

## 6. 機能要件：tsumigi → kairo リネーム

### REQ-001: コマンドネームスペース変更

**Objective**: tsumigi のすべてのスラッシュコマンドを `/kairo:*` として動作させる。

| AC-ID | 受け入れ基準（EARS） | テストレイヤー |
|-------|---------------------|----------------|
| REQ-001-AC-1 | WHEN ユーザーが `/kairo:spec-req` を実行する THEN tsumigi の spec-req と同等の処理が実行される | integration |
| REQ-001-AC-2 | WHEN ユーザーが `/tsumigi:` プレフィックスのコマンドを実行する THEN 非推奨警告を表示し `/kairo:` への移行を案内する | integration |
| REQ-001-AC-3 | IF `~/.claude/commands/tsumigi/` が存在する THEN kairo のインストール時に競合を検出し案内する | integration |

### REQ-002: 設定ファイルのリネーム

**Objective**: `.tsumigi/` 以下の設定を `.kairo/` に移行する。

| AC-ID | 受け入れ基準（EARS） | テストレイヤー |
|-------|---------------------|----------------|
| REQ-002-AC-1 | WHEN `/kairo:install` を実行する THEN `.kairo/config.json` が生成される | unit |
| REQ-002-AC-2 | WHEN 既存の `.tsumigi/config.json` が存在する THEN 内容を `.kairo/config.json` にマイグレーションする | integration |
| REQ-002-AC-3 | IF `tsumigi:` frontmatter が既存ファイルに存在する THEN `kairo:` を正として読み込み、`tsumigi:` を後方互換エイリアスとして扱う | unit |

### REQ-003: インストーラーの更新

**Objective**: `setup.sh` が kairo として動作するよう更新する。

| AC-ID | 受け入れ基準（EARS） | テストレイヤー |
|-------|---------------------|----------------|
| REQ-003-AC-1 | WHEN `bash setup.sh` を実行する THEN コマンドが `~/.claude/commands/kairo/` にインストールされる | integration |
| REQ-003-AC-2 | WHEN `bash setup.sh` を実行する THEN UUPM の依存チェック（Python 3.x）を実施し案内する | integration |
| REQ-003-AC-3 | WHEN `bash setup.sh --project` を実行する THEN プロジェクトローカルに `.kairo/` が初期化される | integration |

### REQ-004: CLAUDE.md および README の更新

**Objective**: プロジェクトドキュメントを kairo として整合させる。

| AC-ID | 受け入れ基準（EARS） | テストレイヤー |
|-------|---------------------|----------------|
| REQ-004-AC-1 | WHEN CLAUDE.md を開く THEN kairo のコマンド体系・アーキテクチャが記述されている | e2e |
| REQ-004-AC-2 | WHEN README.md を開く THEN kairo のクイックスタートが `/kairo:*` のコマンドで記述されている | e2e |

---

## 7. 機能要件：ui-ux-pro-max-skill 統合

### REQ-010: UUPM のインストール統合

**Objective**: `/kairo:install` 実行時に UUPM スキルを自動セットアップする。

| AC-ID | 受け入れ基準（EARS） | テストレイヤー |
|-------|---------------------|----------------|
| REQ-010-AC-1 | WHEN `/kairo:install` を実行する THEN UUPM スキルが `.claude/skills/ui-ux-pro-max/` に配置される | integration |
| REQ-010-AC-2 | WHEN Python 3.x が存在しない THEN インストール手順の案内を表示し処理を継続する | integration |
| REQ-010-AC-3 | WHEN `--skip-uupm` フラグを指定する THEN UUPM のインストールをスキップする | unit |

### REQ-011: デザインシステム生成コマンド

**Objective**: `/kairo:design-system` コマンドで UUPM を呼び出し、デザインシステムを生成する。

| AC-ID | 受け入れ基準（EARS） | テストレイヤー |
|-------|---------------------|----------------|
| REQ-011-AC-1 | WHEN `/kairo:design-system <product-description>` を実行する THEN `design-system/MASTER.md` が生成される | integration |
| REQ-011-AC-2 | WHEN MASTER.md が既に存在する THEN 差分マージを行い既存内容を上書きしない | integration |
| REQ-011-AC-3 | WHEN `--page <page-name>` を指定する THEN `design-system/pages/<page-name>.md` にページ別オーバーライドを生成する | unit |
| REQ-011-AC-4 | WHEN `--stack <stack-name>` を指定する THEN スタック別ガイドラインを MASTER.md に統合する | unit |
| REQ-011-AC-5 | IF `design-system/MASTER.md` が存在する THEN CEG ノード `design-system:<feature>` として `coherence:` frontmatter を付与する | unit |

### REQ-012: spec-design の UI/UX 拡張

**Objective**: `/kairo:spec-design` 実行時に UUPM を自動呼び出し、デザインシステムを design.md に統合する。

| AC-ID | 受け入れ基準（EARS） | テストレイヤー |
|-------|---------------------|----------------|
| REQ-012-AC-1 | WHEN `/kairo:spec-design <feature>` を実行する THEN UUPM の推論エンジンを呼び出しデザインシステムを生成する | integration |
| REQ-012-AC-2 | WHEN `design-system/MASTER.md` が生成される THEN `.kiro/specs/<feature>/design.md` に `## Design System` セクションとして参照リンクを追加する | integration |
| REQ-012-AC-3 | IF `--no-uupm` フラグを指定する THEN デザインシステム生成をスキップし既存フローのみ実行する | unit |

### REQ-013: implement の UI コンポーネント生成拡張

**Objective**: `/kairo:implement` で UI コンポーネントを生成する際に UUPM のデザインシステムを参照する。

| AC-ID | 受け入れ基準（EARS） | テストレイヤー |
|-------|---------------------|----------------|
| REQ-013-AC-1 | WHEN `/kairo:implement <issue-id>` を実行し UI コンポーネント実装を含む THEN `design-system/MASTER.md` を自動参照して色・フォント・スペーシングを適用する | integration |
| REQ-013-AC-2 | WHEN ページ別オーバーライドファイルが存在する THEN MASTER.md よりオーバーライドを優先して適用する | unit |
| REQ-013-AC-3 | IF `design-system/MASTER.md` が存在しない THEN 警告を表示しデザインシステム生成を促す | integration |

### REQ-014: UI/UX Adversarial Review

**Objective**: `/kairo:review --adversary` に UI/UX 品質次元を追加する。

| AC-ID | 受け入れ基準（EARS） | テストレイヤー |
|-------|---------------------|----------------|
| REQ-014-AC-1 | WHEN `/kairo:review <issue-id> --adversary` を実行する THEN 既存 5 次元に加え D6（Design Fidelity）を評価する | integration |
| REQ-014-AC-2 | WHEN D6 評価が FAIL の THEN MASTER.md との乖離箇所を列挙し adversary-report.md に記録する | unit |
| REQ-014-AC-3 | WHEN `--persona ui` を指定する THEN UI/UX 専門ペルソナでレビューを実施し UX ガイドライン 99 件で検証する | integration |

### REQ-015: デザインドリフト検出

**Objective**: `/kairo:drift_check` に UI/UX 乖離次元（D6）を追加する。

| AC-ID | 受け入れ基準（EARS） | テストレイヤー |
|-------|---------------------|----------------|
| REQ-015-AC-1 | WHEN `/kairo:drift_check <issue-id>` を実行する THEN D6（デザインシステムとの乖離）を既存 D1-D5 に加え評価する | integration |
| REQ-015-AC-2 | WHEN UI コンポーネントのカラー・タイポグラフィが MASTER.md と乖離している THEN Amber または Gray バンドを付与する | unit |
| REQ-015-AC-3 | WHEN MASTER.md が存在しない THEN D6 をスキップし既存 D1-D5 のみ評価する | unit |

### REQ-016: デザインシステムバトン統合

**Objective**: GitHub ラベル駆動バトン（Harness）に UI/UX フェーズを統合する。

| AC-ID | 受け入れ基準（EARS） | テストレイヤー |
|-------|---------------------|----------------|
| REQ-016-AC-1 | WHEN `phase:tds` ラベルが付与される THEN DesignAgent がデザインシステム生成を自動実行する | integration |
| REQ-016-AC-2 | WHEN デザインシステム生成が完了する THEN `design-system:` CEG ノードが `graph/coherence.json` に登録される | unit |
| REQ-016-AC-3 | WHEN Phase Gate TDS→IMP が実行される THEN `design-system/MASTER.md` の存在を必須チェック項目に追加する | integration |

---

## 8. 新規コマンド設計

### 8.1 `/kairo:design-system` (新規)

```markdown
---
description: >
  プロダクトの説明から UI/UX デザインシステムを自動生成します。
  ui-ux-pro-max-skill の推論エンジンを使用し、
  スタイル・カラー・タイポグラフィ・レイアウトパターンを決定します。
allowed-tools: Read, Write, Bash, AskUserQuestion, TodoWrite
argument-hint: "<product-description> [--stack <stack>] [--page <page-name>] [--persist] [--no-uupm]"
---
```

**処理フロー**:

```
step1: コンテキスト収集
  - .kiro/steering/*.md を Read してプロダクトコンテキストを取得
  - 既存の design-system/MASTER.md を確認（存在時は差分マージモード）

step2: UUPM 推論エンジン呼び出し
  python3 .claude/skills/ui-ux-pro-max/scripts/search.py \
    "<product-description>" --design-system -p "<feature>" -f markdown
  - 生成結果を parse してデザインシステムを構造化

step3: design-system/MASTER.md 生成
  - パターン・スタイル・カラー・タイポグラフィ・アンチパターン・チェックリストを記録
  - coherence: frontmatter を付与（node_id: "design-system:<feature>"）

step4: ページ別オーバーライド（--page 指定時）
  - design-system/pages/<page-name>.md を生成

step5: CEG 更新
  - graph/coherence.json に design-system ノードを追加
  - 次のステップ: /kairo:spec-design または /kairo:implement
```

**出力成果物**:

| ファイル | 内容 |
|--------|------|
| `design-system/MASTER.md` | グローバルデザインシステム（カラー・タイポグラフィ・スペーシング・コンポーネント仕様） |
| `design-system/pages/<page>.md` | ページ別オーバーライド（--page 指定時） |

---

### 8.2 `/kairo:spec-design` の拡張（既存コマンド拡張）

既存の `spec-design` に以下のステップを追加する。

```
step2.5: デザインシステム生成（UUPM 統合）
  - --no-uupm フラグが未指定の場合:
    /kairo:design-system <feature> --stack <tech_stack_from_steering> を実行
  - design-system/MASTER.md を生成（または更新）

step3.5: design.md への統合
  - design.md の末尾に ## Design System セクションを追加
    → MASTER.md への参照リンク
    → 主要カラー・フォントのサマリー
    → スタック固有の実装ノート
```

---

### 8.3 `/kairo:implement` の拡張（既存コマンド拡張）

UI コンポーネント実装時に MASTER.md を自動参照する。

```
step1.5: デザインシステムコンテキスト読み込み（UI 実装時のみ）
  - IMP.md の変更スコープに UI コンポーネントが含まれるか判定
  - 含まれる場合:
    ① design-system/MASTER.md を Read する
    ② ページ固有オーバーライドを確認（pages/<page-name>.md）
    ③ MASTER.md のルールを実装の制約として適用

pre-delivery チェック（UI 実装完了後）:
  - MASTER.md の Pre-delivery Checklist を自動検証
    ✅ カーソルポインタが全クリック要素に付与されているか
    ✅ ホバーステート（150-300ms）が設定されているか
    ✅ フォーカスステートがキーボードナビ向けに設定されているか
    ✅ レスポンシブブレークポイント（375/768/1024/1440px）を満たすか
    ✅ prefers-reduced-motion が考慮されているか
```

---

### 8.4 `/kairo:review` の拡張（既存コマンド拡張）

```
--persona ui オプション追加:
  既存ペルソナ（arch / security / qa）に加え ui ペルソナを追加

--adversary 実行時の D6 次元追加:
  D6 Design Fidelity:
    ① MASTER.md のカラーが実装に適用されているか
    ② タイポグラフィが MASTER.md と一致するか
    ③ UX ガイドライン 99 件のアンチパターンに違反していないか
    ④ Pre-delivery チェックリストを全て満たしているか
  
  D6 FAIL → adversary-report.md に乖離箇所を記録
          → coherence.score を 0.0（Gray）に設定
```

---

### 8.5 `/kairo:cli` の拡張（既存コマンド拡張）

自然言語ルーティングに UI/UX 関連を追加。

```
（追加ルーティング）
デザインシステムを作りたい         → design-system
UIを実装したい                     → implement（UUPM参照を自動適用）
デザインの乖離を確認したい         → drift_check（D6含む）
UI品質をチェックしたい             → review --persona ui
カラー・フォントを決めたい         → design-system
```

---

## 9. ディレクトリ構造

### 9.1 kairo 統合後の完全ディレクトリ構造（差分のみ記載）

```
project-root/
│
├── .claude/
│   └── skills/
│       └── ui-ux-pro-max/          ← UUPM スキル（/kairo:install で配置）
│           ├── data/
│           ├── scripts/
│           │   ├── search.py
│           │   ├── core.py
│           │   └── design_system.py
│           └── templates/
│
├── .kairo/                          ← (.tsumigi/ からリネーム)
│   ├── config.json                  ← uupm 統合設定を追加
│   ├── hooks/
│   │   └── post-tool-use.sh
│   └── agents/
│       ├── requirements-agent.md
│       ├── design-agent.md          ← UUPM 呼び出し処理を追加
│       ├── implement-agent.md       ← MASTER.md 参照を追加
│       ├── test-agent.md
│       ├── adversary-agent.md       ← D6 次元を追加
│       ├── ops-agent.md
│       └── change-agent.md
│
├── design-system/                   ← UUPM 成果物（新規）
│   ├── MASTER.md                    ← グローバルデザインシステム SSOT
│   │   （coherence: node_id: "design-system:<feature>"）
│   └── pages/                       ← ページ別オーバーライド
│       ├── landing.md
│       ├── dashboard.md
│       └── ...
│
├── .kiro/                           ← （変更なし）
│   ├── steering/
│   └── specs/<feature>/
│       ├── requirements.md
│       ├── design.md                ← ## Design System セクションを追加
│       └── tasks.md
│
├── graph/
│   ├── coherence.json               ← design-system ノードを追加
│   └── baton-log.json
│
└── commands/                        ← /kairo:* コマンド群
    ├── design-system.md             ← 新規
    ├── spec-design.md               ← UUPM 統合拡張
    ├── implement.md                 ← UUPM 参照拡張
    ├── review.md                    ← D6・--persona ui 追加
    ├── drift_check.md               ← D6 次元追加
    ├── install.md                   ← UUPM インストール追加
    ├── cli.md                       ← UI/UX ルーティング追加
    └── ...（既存コマンド・リネームのみ）
```

### 9.2 `.kairo/config.json` 拡張スキーマ

```json
{
  "kairo_version": "1.0.0",
  "project": {
    "name": "...",
    "language": "ja"
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
  "integrations": {
    "uupm": {
      "enabled": true,
      "skill_path": ".claude/skills/ui-ux-pro-max",
      "default_stack": "html-tailwind",
      "auto_design_system_on_spec_design": true,
      "persist_design_system": true
    },
    "kiro": {
      "enabled": true,
      "config_dir": ".kiro"
    },
    "codd": {
      "enabled": "auto",
      "fallback_to_kairo": true
    }
  },
  "harness": {
    "enabled": false,
    "AUTO_STEP": false,
    "mode": "claude-code-hooks"
  }
}
```

---

## 10. CEG (Conditioned Evidence Graph) 拡張

### 10.1 新規 frontmatter ノード

UUPM 統合により、以下の新規ノードタイプを CEG に追加する。

| node_id パターン | artifact_type | フェーズ | 依存元 |
|----------------|--------------|---------|--------|
| `design-system:<feature>` | `design-system` | TDS | `req:<feature>` |
| `design-system-page:<feature>/<page>` | `design-system-page` | TDS/IMP | `design-system:<feature>` |

### 10.2 `design-system/MASTER.md` frontmatter テンプレート

```yaml
---
kairo:
  node_id: "design-system:<feature>"
  artifact_type: "design-system"
  phase: "TDS"
  feature: "<feature-name>"
  uupm_version: "2.5.0"
  stack: "html-tailwind"
  status: "approved"
  created_at: "2026-04-11T00:00:00Z"
  updated_at: "2026-04-11T00:00:00Z"

coherence:
  id: "design-system:<feature>"
  depends_on:
    - id: "req:<feature>"
      relation: "derives_from"
      confidence: 0.95
      required: true
  modules: ["ui", "styles"]
  band: "Green"
  last_validated: "2026-04-11T00:00:00Z"
---
```

### 10.3 依存グラフの拡張

```
req:<feature>
    │ derives_from
    ▼
design-system:<feature>      ← UUPM 生成
    │ constrains
    ▼
design:<feature>             ← spec-design 生成（既存 + 参照リンク追加）
    │ implements
    ▼
imp:<issue-id>
    │ implements（UIコンポーネント）
    ▼
impl:<issue-id>/<task-id>    ← implement 生成（MASTER.md 参照）
    │ verifies
    ▼
test:<issue-id>/<task-id>    ← V-Model TDD（D6 検証を含む）
```

---

## 11. Phase Gate 拡張：UI/UX フェーズの組み込み

### 11.1 TDS→IMP Phase Gate 拡張

既存のチェック項目に以下を追加する。

| 追加チェック | 条件 | 判定 |
|------------|------|------|
| デザインシステム存在確認 | `design-system/MASTER.md` が存在する | PASS / FAIL |
| デザインシステム CEG 登録 | `graph/coherence.json` に `design-system:<feature>` が存在する | PASS / WARNING |
| カラーパレット定義確認 | MASTER.md に Primary/Secondary/CTA カラーが定義されている | PASS / WARNING |

> `design-system/MASTER.md` が存在しない場合: FAIL → `blocked:tds` ラベルを付与し、`/kairo:design-system` の実行を案内する。

### 11.2 TEST→OPS Phase Gate 拡張（D6 追加）

Adversarial Review に D6（Design Fidelity）を追加する。

```
D6 Design Fidelity 評価基準:

CHECK 1: カラー整合性
  - 実装コード内のカラー値が MASTER.md の定義と一致しているか
  - FAIL → Gray バンド付与

CHECK 2: タイポグラフィ整合性
  - font-family / font-size が MASTER.md の定義と一致しているか
  - FAIL → Amber バンド付与

CHECK 3: UX アンチパターン違反
  - MASTER.md の AVOID セクションに記載のアンチパターンが存在しないか
  - FAIL → Gray バンド付与

CHECK 4: Pre-delivery チェックリスト
  - MASTER.md の Pre-delivery Checklist の全項目を満たしているか
  - FAIL → Amber バンド付与

判定:
  D6 全 CHECK PASS → adversary-report.md に PASS 記録
  D6 いずれかが Gray FAIL → Phase Gate FAIL → blocked:imp 付与
  D6 いずれかが Amber WARNING → Phase Gate PASS with WARNING → human:review 付与
```

---

## 12. 非機能要件

### 12.1 性能要件

| 要件 | 基準 |
|------|------|
| NFR-001 | UUPM 検索スクリプト（`search.py`）は 5 秒以内に完了する |
| NFR-002 | `design-system/MASTER.md` の生成は 30 秒以内に完了する |
| NFR-003 | D6 評価を含む Adversarial Review は 60 秒以内に完了する |

### 12.2 互換性要件

| 要件 | 基準 |
|------|------|
| NFR-010 | Python 3.8 以上で UUPM スクリプトが動作する |
| NFR-011 | UUPM がインストールされていない環境でも、`--no-uupm` フラグで全コマンドが動作する |
| NFR-012 | tsumigi v3.0 で生成された既存成果物（`tsumigi:` frontmatter）は kairo で読み込める |
| NFR-013 | `design-system/MASTER.md` が存在しない場合、既存の VCKD フローは影響を受けない |

### 12.3 セキュリティ要件

| 要件 | 基準 |
|------|------|
| NFR-020 | UUPM スクリプトへの入力（`<product-description>`）はシェルインジェクションを防ぐために適切にエスケープする |
| NFR-021 | UUPM は外部ネットワーク通信を行わない（オフラインで動作する） |

---

## 13. MVP 最小実装セット

### 13.1 MVP の選定基準

以下の 2 つの MVP を定義する。

- **MVP-A（リネーム）**: tsumigi → kairo のコマンドリネームを完了させ、kairo として動作する
- **MVP-B（UUPM 統合）**: `/kairo:design-system` と `spec-design` の UUPM 統合を動作させる

### 13.2 MVP-A: kairo リネーム（優先度：🔴 MUST、2〜3日）

| # | 作業 | 対象ファイル |
|---|------|------------|
| A-1 | `commands/` 内の全ファイルの `/tsumigi:` 参照を `/kairo:` に書き換え | `commands/*.md` 全 18 ファイル |
| A-2 | `.tsumigi/` ディレクトリを `.kairo/` にリネーム | `setup.sh`, `.tsumigi/config.json` |
| A-3 | `setup.sh` のインストール先を `~/.claude/commands/kairo/` に変更 | `setup.sh` |
| A-4 | `CLAUDE.md` および `README.md` を kairo 向けに更新 | `CLAUDE.md`, `README.md` |
| A-5 | `package.json` の name・description を kairo に更新 | `package.json` |

**MVP-A 完了基準**:
```
1. bash setup.sh 実行後、/kairo:help が動作する
2. /kairo:install でプロジェクトが初期化される
3. /kairo:spec-req で要件定義が生成される
4. graph/coherence.json に kairo: frontmatter が記録される
```

### 13.3 MVP-B: UUPM 統合（優先度：🔴 MUST、3〜4日）

| # | 作業 | 対象ファイル |
|---|------|------------|
| B-1 | `commands/design-system.md` の新規作成 | `commands/design-system.md` |
| B-2 | `commands/install.md` に UUPM インストールステップを追加 | `commands/install.md` |
| B-3 | `commands/spec-design.md` に step2.5 を追加 | `commands/spec-design.md` |
| B-4 | `commands/implement.md` に step1.5 を追加 | `commands/implement.md` |
| B-5 | `.kairo/config.json` テンプレートに `integrations.uupm` セクションを追加 | テンプレート |

**MVP-B 完了基準**:
```
1. /kairo:install 後、.claude/skills/ui-ux-pro-max/ が存在する
2. /kairo:design-system "SaaSダッシュボード" でdesign-system/MASTER.md が生成される
3. /kairo:spec-design <feature> でdesign.md に ## Design System セクションが含まれる
4. design-system/MASTER.md に coherence: frontmatter が付与される
```

### 13.4 Phase 2: D6 Adversarial Review（優先度：🟡 SHOULD、3〜4日）

| # | 作業 | 対象ファイル |
|---|------|------------|
| C-1 | `commands/review.md` に D6 評価ロジックを追加 | `commands/review.md` |
| C-2 | `commands/drift_check.md` に D6 次元を追加 | `commands/drift_check.md` |
| C-3 | `.kairo/agents/adversary-agent.md` に D6 チェック手順を追加 | `.kairo/agents/adversary-agent.md` |
| C-4 | `templates/adversary-report-template.md` に D6 セクションを追加 | `templates/adversary-report-template.md` |

### 13.5 Phase 3: Harness / Phase Gate 統合（優先度：🟡 SHOULD、2〜3日）

| # | 作業 | 対象ファイル |
|---|------|------------|
| D-1 | TDS→IMP Phase Gate に `design-system/MASTER.md` 存在チェックを追加 | `.kairo/hooks/post-tool-use.sh` |
| D-2 | `.kairo/agents/design-agent.md` に UUPM 呼び出しを追加 | `.kairo/agents/design-agent.md` |

### 13.6 依存関係

```
MVP-A（リネーム）
    ↓ 前提
MVP-B（UUPM 統合）
    ↓ 前提
Phase 2（D6 Adversarial Review）
    ↓ 前提
Phase 3（Harness / Phase Gate 統合）
```

---

## 14. 移行ガイド（tsumigi → kairo）

### 14.1 新規プロジェクト（推奨）

```bash
# 1. kairo をクローン
git clone https://github.com/kava2108/kairo.git
cd kairo

# 2. kairo をグローバルインストール
bash setup.sh

# 3. プロジェクト初期化（UUPM も自動インストール）
/kairo:install my-project

# 4. REQ フェーズ
/kairo:spec-steering
/kairo:spec-req user-auth-oauth

# 5. TDS フェーズ（デザインシステム自動生成）
/kairo:spec-design user-auth-oauth
# → design-system/MASTER.md が自動生成される
# → .kiro/specs/user-auth-oauth/design.md に ## Design System が追加される

# 6. 以降は通常の kairo フロー
/kairo:spec-tasks user-auth-oauth
/kairo:issue-generate user-auth-oauth --wave P0
/kairo:imp_generate 042-user-auth-login
/kairo:implement 042-user-auth-login    # MASTER.md を自動参照
/kairo:test 042-user-auth-login --vmodel all
/kairo:review 042-user-auth-login --adversary  # D6 を含む
/kairo:rev 042-user-auth-login --target all
/kairo:drift_check 042-user-auth-login          # D6 を含む
/kairo:sync 042-user-auth-login --audit
/kairo:pr 042-user-auth-login
```

### 14.2 tsumigi プロジェクトからの移行

```bash
# 1. .tsumigi/ を .kairo/ にコピー
cp -r .tsumigi/ .kairo/

# 2. .kairo/config.json に uupm セクションを追加（手動）

# 3. 既存の tsumigi: frontmatter は kairo: エイリアスとして動作
#    （移行は任意。新規ファイルから kairo: で記述）

# 4. kairo グローバルインストール
bash setup.sh

# 5. UUPM インストール（既存プロジェクトへの後付け）
/kairo:install --uupm-only
```

### 14.3 後方互換性の保証

- `tsumigi:` frontmatter を持つ既存ファイルは v1.0 で正常動作する
- `/tsumigi:*` コマンドは非推奨警告付きで動作するエイリアスを提供する（Phase 4 以降に削除予定）
- `design-system/MASTER.md` が存在しない場合、UUPM 統合は自動スキップされ既存フローに影響しない

---

## 15. 付録

### 付録 A: kairo フルコマンド一覧（v1.0）

```
━━ REQ フェーズ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/kairo:spec-steering [--update]          Steering 文書を生成
/kairo:spec-req <feature> [-y]           EARS 要件定義書を生成

━━ TDS フェーズ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/kairo:spec-design <feature> [-y]        技術設計書 + デザインシステム（UUPM）を生成 ★拡張
/kairo:spec-tasks <feature> [-y]         P0/P1 波形タスク分解
/kairo:design-system <desc> [options]    デザインシステムを独立生成（UUPM）★新規

━━ ブリッジ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/kairo:issue-generate <feature> [...]    tasks.md → GitHub Issues 一括生成

━━ IMP フェーズ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/kairo:imp_generate <issue-id> [...]     IMP を生成（デザインシステム参照付き）★拡張
/kairo:implement <issue-id> [task-id]    実装生成（MASTER.md 自動参照）★拡張

━━ TEST フェーズ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/kairo:test <issue-id> [--vmodel ...]    V-Model テストケース生成
/kairo:review <issue-id> [--adversary]  レビュー（D6 Design Fidelity 追加）★拡張
                          [--persona ui]  UI/UX 専門ペルソナ ★新規オプション

━━ OPS フェーズ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/kairo:rev <issue-id> [--target ...]     逆仕様生成
/kairo:drift_check <issue-id> [...]      乖離検出（D6 デザインドリフト追加）★拡張

━━ CHANGE フェーズ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/kairo:sync <issue-id> [--audit]         全成果物の整合性確認
/kairo:pr <issue-id>                     PR 生成 + エビデンス添付

━━ ユーティリティ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/kairo:install [--harness] [--uupm-only] プロジェクト初期化（UUPM インストール含む）★拡張
/kairo:baton-status [<issue-id>]         バトン遷移状態表示
/kairo:spec-status <feature>             フィーチャー進捗 + CEG サマリー
/kairo:coherence-scan                    graph/coherence.json 再構築
/kairo:impact <issue-id> [--node ...]    BFS 影響分析
/kairo:rescue [<issue-id>]               中間状態リカバリー
/kairo:help [command-name]               コマンド一覧・ヘルプ
/kairo:cli [自然言語の指示]              自然言語ルーティング（UI/UX 追加）★拡張
```

### 付録 B: ui-ux-pro-max-skill 利用可能スタック

| スタック ID | 説明 |
|------------|------|
| `html-tailwind` | HTML + Tailwind CSS（デフォルト） |
| `react` | React |
| `nextjs` | Next.js |
| `astro` | Astro |
| `vue` | Vue.js |
| `nuxtjs` | Nuxt.js |
| `nuxt-ui` | Nuxt UI |
| `svelte` | Svelte |
| `shadcn` | shadcn/ui |
| `angular` | Angular |
| `laravel` | Laravel（Blade, Livewire, Inertia.js） |
| `swiftui` | SwiftUI（iOS） |
| `jetpack-compose` | Jetpack Compose（Android） |
| `react-native` | React Native |
| `flutter` | Flutter |

### 付録 C: 関連リポジトリ

| リポジトリ | 役割 |
|-----------|------|
| [kava2108/kairo](https://github.com/kava2108/kairo) | 本リポジトリ（kairo エンジン） |
| [kava2108/tsumigi](https://github.com/kava2108/tsumigi) | 継承元（tsumigi v3.0） |
| [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | 統合対象（UUPM v2.5.0） |

### 付録 D: 用語定義

| 用語 | 定義 |
|------|------|
| **kairo** | tsumigi を継承した次世代 AI-TDD エンジン。「回路」を意味する |
| **UUPM** | ui-ux-pro-max-skill の略称 |
| **MASTER.md** | UUPM が生成するグローバルデザインシステム仕様書。デザインの SSOT |
| **D6** | Adversarial Review の第 6 次元：Design Fidelity（デザイン忠実度） |
| **デザインドリフト** | 実装されたUIとdesign-system/MASTER.mdの乖離スコア |
| **VCKD** | Verified Coherence Kiro-Driven Development（tsumigi/kairo の統合フレームワーク名） |
| **CEG** | Conditioned Evidence Graph。frontmatter `coherence:` から構築される有向グラフ |
| **Phase Gate** | フェーズ遷移前の自動整合性チェック。PASS でバトン信号を発行 |

---

*kairo × ui-ux-pro-max-skill 統合要件仕様書 v1.0*  
*作成: 2026-04-11*  
*ステータス: Draft — 実装前にレビュー・承認が必要*
