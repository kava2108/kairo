#!/usr/bin/env bash
# kairo setup — Claude Code スラッシュコマンドをインストールする
# Usage:
#   bash setup.sh           # グローバルインストール (~/.claude/commands/kairo/)
#   bash setup.sh --project # プロジェクトローカルインストール (.claude/commands/kairo/)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_SRC="$SCRIPT_DIR/commands"
TEMPLATES_SRC="$SCRIPT_DIR/templates"

# インストール先を決定
if [[ "${1:-}" == "--project" ]]; then
  DEST_DIR=".claude/commands/kairo"
  SCOPE="プロジェクト"
else
  DEST_DIR="$HOME/.claude/commands/kairo"
  SCOPE="グローバル"
fi

TEMPLATES_DEST="$DEST_DIR/templates"

echo "kairo コマンドを $SCOPE インストールします..."
echo "インストール先: $DEST_DIR"

mkdir -p "$DEST_DIR"
mkdir -p "$TEMPLATES_DEST"

echo ""
echo "コマンドをインストール中..."
for src in "$COMMANDS_SRC"/*.md; do
  filename="$(basename "$src")"
  cp "$src" "$DEST_DIR/$filename"
  echo "  ✓ commands/$filename"
done

echo ""
echo "テンプレートをインストール中..."
for src in "$TEMPLATES_SRC"/*.md; do
  filename="$(basename "$src")"
  cp "$src" "$TEMPLATES_DEST/$filename"
  echo "  ✓ templates/$filename"
done

echo ""
echo "✅ インストール完了！"
echo ""
echo "次のコマンドが使えます:"
echo "  /kairo:install      — プロジェクト初期セットアップ"
echo "  /kairo:issue_init   — Issue → タスク構造起こし"
echo "  /kairo:imp_generate — IMP 生成・更新"
echo "  /kairo:implement    — 実装案・パッチ案を生成"
echo "  /kairo:test         — テストケース・検証方針を生成"
echo "  /kairo:rev          — 逆仕様・ドキュメントを生成"
echo "  /kairo:drift_check  — 仕様と実装の乖離を検出"
echo "  /kairo:sync         — 全成果物の整合性確認・修正"
echo "  /kairo:review       — reviewer-oriented な差分・リスク整理"
echo "  /kairo:help         — ヘルプ・コマンド一覧"
echo "  /kairo:cli          — 自然言語からのコマンドルーティング"
echo ""
if [[ "$SCOPE" == "グローバル" ]]; then
  echo "Claude Code を再起動してコマンドを有効化してください。"
else
  echo "このプロジェクトで Claude Code を開くとコマンドが有効になります。"
fi
