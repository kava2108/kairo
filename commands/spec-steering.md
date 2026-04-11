---
description: プロジェクトのアーキテクチャ・技術スタック・規約を Steering 文書として生成します。全 kairo コマンドが参照する共有コンテキストになります。
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion, TodoWrite
argument-hint: "[--update] [--custom <domain>]"
---

# kairo spec-steering

プロジェクト全体の技術方針・構造・規約を Steering 文書として生成します。
Steering 文書は全 kairo コマンドが参照する共有コンテキストとなります。
冪等設計のため、既存 Steering への差分マージも安全に実行できます。

# context

update_mode={{update_mode}}
custom_domain={{custom_domain}}
steering_dir=.kairo/steering
出力ファイル=.kiro/steering/structure.md, .kiro/steering/tech.md, .kiro/steering/product.md

# step

- $ARGUMENTS を解析する：
  - `--update` フラグを確認し update_mode に設定
  - `--custom` の後の値を custom_domain に設定
- context の内容をユーザーに宣言する
- step2 を実行する

## step2: 既存 Steering の確認（idempotent チェック）

- `.kiro/steering/` ディレクトリを確認する
- `structure.md`, `tech.md`, `product.md` の存在をそれぞれ確認する
  - 全て存在する かつ `--update` フラグなし：
    - 「既存の Steering 文書が見つかりました。--update を付けて再実行すると差分更新します」と表示する
    - AskUserQuestion ツールで確認する：
      - question: "続行しますか？"
      - options: ["更新する（--update 相当）", "現在の Steering を表示して終了", "中断する"]
    - 「現在の Steering を表示して終了」が選ばれた場合：各ファイルを Read して表示する
    - 「中断する」が選ばれた場合：終了する
  - 一部 or 全て欠けている かつ `--update` なし：「新規生成を開始します」と表示する
  - `--update` フラグあり：「差分更新モードで実行します」と表示する
- step3 を実行する

## step3: コードベース分析

- 以下を Glob で確認する：
  - `src/**`, `app/**`, `lib/**`, `pkg/**` のディレクトリ構造を把握する
  - ルート直下のファイル（`*.json`, `*.toml`, `*.yaml`, `*.mod` など）を確認する
- 以下を存在する場合に Read する：
  - `package.json` — 言語・フレームワーク・依存関係を取得
  - `pyproject.toml` / `Pipfile` / `requirements.txt` — Python スタックを確認
  - `go.mod` — Go モジュール構成を確認
  - `Cargo.toml` — Rust スタックを確認
  - `pom.xml` / `build.gradle` — Java/Kotlin スタックを確認
  - `README.md` — プロダクト概要を取得
  - `CLAUDE.md` / `TSUMIGI.md` / `.kairo/config.json` — 既存プロジェクトコンテキストを取得
- step4 を実行する

## step4: Steering 文書の生成

コードベース分析の結果をもとに以下の3ファイルを生成する（`--update` 時は差分マージ）：

### .kiro/steering/structure.md の生成

以下の構造で Write する：

```markdown
# Project Structure Steering

## アーキテクチャパターン
[フロントエンド/バックエンド/モノリス/マイクロサービスなど検出されたパターン]

## ディレクトリ構成
[実際のディレクトリ構成と各ディレクトリの役割]

## 命名規則
- ファイル名: [kebab-case / snake_case など]
- 変数名: [camelCase / snake_case など]
- クラス名: [PascalCase など]
- テストファイル: [*.test.ts / test_*.py など]

## モジュール境界
[主要モジュールとその責任範囲]

## コーディング規約
[Linter・Formatter・import 順序など]
```

### .kiro/steering/tech.md の生成

以下の構造で Write する：

```markdown
# Technical Stack Steering

## 言語・ランタイム
[検出された言語とバージョン]

## フレームワーク
[使用フレームワークとバージョン]

## 主要ライブラリ
[依存関係から抽出した主要ライブラリ一覧]

## データベース
[使用DB・ORM・マイグレーションツール]

## インフラ・デプロイ
[検出されたインフラ構成]

## テスト戦略
[使用テストフレームワーク・カバレッジ要件]

## セキュリティ制約
[認証方式・秘匿情報管理・OWASP Top10 対応方針]

## 制約・非推奨事項
[使用禁止ライブラリ・アンチパターンなど]
```

### .kiro/steering/product.md の生成

以下の構造で Write する：

```markdown
# Product Context Steering

## プロダクト概要
[README・CLAUDE.md から抽出したプロダクトの目的]

## 対象ユーザー
[想定ユーザーとユースケース]

## ビジネスゴール
[解決する課題・KPI・成功指標]

## スコープ（In / Out）
[このプロジェクトが対応する範囲と対応しない範囲]

## 主要な制約
[法的・技術的・ビジネス上の制約]
```

## step5: カスタム Steering の生成（`--custom <domain>` 指定時）

利用可能なドメイン: `api-standards` / `testing` / `security` / `database` / `deployment`

対応するファイルを `.kiro/steering/custom/<domain>.md` に生成する：
- `api-standards`: REST/GraphQL/gRPC の設計標準・命名規則・バージョニング方針
- `testing`: テストピラミッド・カバレッジ基準・E2E 戦略・テストデータ管理
- `security`: 認証認可・入力バリデーション・秘匿情報・OWASP Top10 対応
- `database`: スキーマ設計・マイグレーション・インデックス・クエリ最適化方針
- `deployment`: CI/CD パイプライン・環境構成・リリース戦略

## step6: 完了通知

生成されたファイルの一覧を表示する：
```
✅ Steering 文書を生成しました

.kiro/steering/
├── structure.md  — アーキテクチャ・ディレクトリ・命名規則
├── tech.md       — 技術スタック・フレームワーク・制約
└── product.md    — プロダクト背景・ユーザー・ゴール
```

次のステップ:
```
/kairo:spec-init <feature-description>
```

> **Steering の参照**: `implement`, `test`, `imp_generate` など全コマンドは
> `.kiro/steering/` を自動的に読み込み、技術スタック・規約に沿った出力を生成します。
