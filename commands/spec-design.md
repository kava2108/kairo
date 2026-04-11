---
description: 技術設計書（design.md）を生成します。要件定義を受けて、アーキテクチャ・API設計・DB設計・コンポーネント設計を Mermaid 図付きで生成します。
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion, TodoWrite
argument-hint: "<feature-name> [-y]"
---

# kairo spec-design

`requirements.md` の受け入れ基準をもとに、技術設計書（`design.md`）を生成します。
Steering の tech.md・structure.md に準拠したアーキテクチャ設計・API 設計・DB 設計を
Mermaid 図付きで出力します。

# context

feature_name={{feature_name}}
auto_approve={{auto_approve}}
spec_dir=.kairo/specs/{{feature_name}}
requirements_file=.kairo/specs/{{feature_name}}/requirements.md
design_file=.kairo/specs/{{feature_name}}/design.md
research_file=.kairo/specs/{{feature_name}}/research.md
spec_json=.kairo/specs/{{feature_name}}/spec.json

# step

- $ARGUMENTS がない場合は「引数に feature-name を指定してください（例: /kairo:spec-design user-auth-oauth）」と言って終了する
- $ARGUMENTS を解析する：
  - `-y` フラグを確認し auto_approve に設定（デフォルト: false）
  - 最初のトークンを feature_name に設定
- context の内容をユーザーに宣言する
- step2 を実行する

## step2: 前提チェック

- `.kairo/specs/{{feature_name}}/spec.json` を Read してフェーズ情報を確認する
  - 存在しない場合：「先に `/kairo:spec-init` → `/kairo:spec-req` を実行してください」と言って終了する
  - `phases.requirements` が `"approved"` でない場合：
    - 「requirements.md が未承認です。`/kairo:spec-req {{feature_name}}` を先に実行してください」と表示する
    - AskUserQuestion で確認する：
      - question: "requirements.md が未承認ですが、続行しますか？"
      - options: ["続行する（draft のまま進める）", "中断する"]
    - 「中断する」が選ばれた場合：終了する
- step3 を実行する

## step3: コンテキスト収集

- `.kairo/specs/{{feature_name}}/requirements.md` を Read する
- `.kairo/steering/structure.md` を存在する場合に Read する
- `.kairo/steering/tech.md` を存在する場合に Read する
- 既存コードベースの関連実装を以下で調査する：
  - Glob: `src/**`, `app/**`, `lib/**`, `api/**`
  - Grep: requirements.md に登場するキーワードで既存実装を検索する
- step4 を実行する

## step4: 技術調査（複雑な選択肢がある場合のみ）

- 要件に新技術・未確定の技術選択肢が含まれる場合：
  - 比較候補を 2〜3 案提示し、AskUserQuestion で技術選択を確認する
  - 調査結果を `research.md` に Write する（任意成果物）
- Steering の tech.md に制約が記載されている場合は必ずそれに従う
- step5 を実行する

## step5: design.md の生成

以下の構造で `design.md` を Write する：

```markdown
# Technical Design Document: {{feature_name}}

**ステータス**: draft
**要件参照**: .kairo/specs/{{feature_name}}/requirements.md
**作成日**: <現在の日付>

---

## Overview

**Purpose**: [設計の目的]
**Users**: [影響を受けるユーザー]
**Impact**: [システムへの影響範囲]

### Goals
- [設計で実現すること]

### Non-Goals
- [設計の対象外事項]

---

## Architecture

### High-Level Architecture

\`\`\`mermaid
graph TB
  [コンポーネント構成を Mermaid で描画]
\`\`\`

**Architecture Integration**: [既存アーキテクチャパターンとの整合性（Steering structure.md より）]
**Technology Stack**: [採用技術と選定理由（Steering tech.md を参照）]

### Sequence Diagram（主要フロー）

\`\`\`mermaid
sequenceDiagram
  [主要なユースケースのシーケンスを描画]
\`\`\`

---

## API Design

| Method | Path | 説明 | Auth | REQ-ID |
|--------|------|------|------|--------|
| POST | /api/... | ... | required | REQ-001 |

### リクエスト / レスポンス例

\`\`\`json
// リクエスト
{
  ...
}

// レスポンス
{
  ...
}
\`\`\`

---

## Database Design

\`\`\`mermaid
erDiagram
  [テーブル定義を ER 図で描画]
\`\`\`

| テーブル | カラム | 型 | 説明 |
|---------|-------|-----|------|

---

## Component Design

[コンポーネント・モジュール構成と各責任範囲]

---

## Security Considerations

| 脅威 | 対策 | REQ-ID |
|------|------|--------|
| | | |

> OWASP Top10 に沿って記載（Steering tech.md の security constraints を参照）

---

## Error Handling

| エラー種別 | HTTPステータス / エラーコード | ログレベル | 対応策 |
|-----------|---------------------------|----------|------|

---

## Non-Functional Requirements 対応

| NFR | 設計上の対応 |
|-----|------------|
| パフォーマンス | |
| セキュリティ | |
| 可用性 | |
```

## step6: Human Gate（`-y` なし時）

- 設計の主要判断（技術選定・アーキテクチャ・API 設計）を要約して提示する
- AskUserQuestion ツールで確認する：
  - question: "この技術設計書を承認しますか？"
  - options: ["承認する", "修正して再提示する", "中断する"]
- 「修正して再提示する」が選ばれた場合：フィードバックを受け取り step5 に戻る
- 「中断する」が選ばれた場合：現状の draft を保存して終了する

## step7: 承認後の更新

- `spec.json` の `phases.design` を `"approved"` に更新する
- requirements.md の Traceability テーブルに設計参照列を更新する

## step8: 完了通知

```
✅ design.md を生成しました

.kairo/specs/{{feature_name}}/design.md
  - アーキテクチャ図: ✅
  - API 設計: <エンドポイント数> 件
  - DB 設計: <テーブル数> 件
  - ステータス: approved
```

次のステップ:
```
/kairo:spec-tasks {{feature_name}}
```
