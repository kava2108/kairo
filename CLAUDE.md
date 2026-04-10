# CLAUDE.md — kairo

このファイルは、Claude Code が kairo リポジトリで作業するときのガイダンスを提供します。

## 概要

kairo は AI 開発プロセスを"回路化"する**次世代 AI-TDD エンジン**です。tsumigi の思想を継承し、`setup.sh` でインストールして
Issue → IMP → 実装 → テスト → 逆仕様 → 同期 の全フェーズを一貫して実行します。

このリポジトリには以下が含まれています：
- **`commands/`**: Claude Code スラッシュコマンド（`.md` ファイル）
- **`setup.sh`**: コマンドを `~/.claude/commands/kairo/` にインストールするスクリプト

## インストール方法

```bash
git clone https://github.com/kava2108/kairo.git
cd kairo
bash setup.sh
```

`setup.sh` は `~/.claude/commands/kairo/` に全コマンドをコピーします。
Claude Code を再起動後、`/kairo:` プレフィックスでコマンドが使えます。

特定プロジェクトのみで使う場合は `bash setup.sh --project` を実行します（`.claude/commands/kairo/` にインストール）。

## コマンド一覧

| コマンド | 説明 |
|---------|------|
| `kairo:install` | プロジェクト初期セットアップ |
| `kairo:issue_init` | Issue → タスク構造起こし |
| `kairo:imp_generate` | IMP（実装管理計画書）生成・更新 |
| `kairo:implement` | IMP ベースで実装案・パッチ案を生成 |
| `kairo:test` | テストケース・検証方針を生成 |
| `kairo:rev` | 実装から逆仕様・ドキュメントを生成 |
| `kairo:sync` | 全成果物の整合性確認・修正 |
| `kairo:review` | reviewer-oriented な差分・リスク整理 |
| `kairo:drift_check` | 仕様と実装の乖離を検出・可視化 |
| `kairo:help` | ヘルプ・コマンド一覧 |
| `kairo:cli` | 自然言語からのコマンドルーティング |

## 設計原則

- **Idempotent**: 全 Skill は再実行安全。既存ファイルに差分マージする。
- **Reviewer-oriented**: 全出力は監査可能・再現可能な形式で生成する。
- **IMP 中心設計**: IMP.md が Issue〜実装〜ドキュメントの単一の真実の源となる。
- **Drift Correction**: 仕様と実装の乖離を定量化し、可視化する。

## プロジェクト構造

```
kairo/
├── commands/             # スラッシュコマンド定義（.md）
│   └── *.md              # ~/.claude/commands/kairo/ にコピーされる
├── setup.sh              # インストールスクリプト
├── CLAUDE.md             # このファイル
├── README.md             # ユーザー向けドキュメント
└── package.json
```

## コマンドファイルの書き方

コマンドファイル（`commands/*.md`）は kairo の形式に従います：

```markdown
---
description: コマンドの説明
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, TodoWrite, AskUserQuestion
argument-hint: "<必須引数> [任意引数]"
---

# コマンド名

## 目的
...

# context
変数名={{変数}}

# step
...

## step2
...
```

## 注意事項

- コマンドファイル（`.md`）を修正する際は、シークレット情報が含まれていないことを確認してから commit してください。
- `$ARGUMENTS` はユーザーがコマンドに渡した引数文字列全体を参照します。
- `{{variable}}` は context セクションで定義されたテンプレート変数です。
