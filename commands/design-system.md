---
description: >
  プロダクトの説明から UI/UX デザインシステムを自動生成します。
  業界カテゴリ・スタイル・カラー・タイポグラフィ・レイアウトパターンをAIが推論し、
  design-system/MASTER.md として永続化します。
  生成した MASTER.md は CEG ノードとして管理されます。
allowed-tools: Read, Write, Bash, AskUserQuestion, TodoWrite, Glob, Grep, Edit
argument-hint: "<product-description> [--stack <stack>] [--page <page-name>] [--persist] [--feature <feature>]"
---

# /kairo:design-system

## 目的

プロダクトの自然言語説明から UI/UX デザインシステムを推論・生成し、`design-system/MASTER.md`
として永続化する。外部ツールに依存せず、kairo 自身の設計知識を使って業界固有の
デザインパターンを選択し、kairo CEG（Conditioned Evidence Graph）の TDS フェーズノードとして統合する。

---

# context

```
PRODUCT_DESC=$ARGUMENTS  （"--" 以前のテキスト）
STACK_ARG=（--stack オプション。未指定時は html-tailwind を使用）
PAGE_ARG=（--page オプション。指定時はページ別オーバーライドを生成）
FEATURE=（--feature オプション。未指定時は "main" を使用）
PERSIST=（--persist フラグ。既存 MASTER.md がある場合も上書き）

MASTER_MD=design-system/MASTER.md
COHERENCE_JSON=graph/coherence.json
```

---

# step1: コンテキスト収集

1. `.kiro/steering/*.md` を Read してプロダクトコンテキスト（技術スタック・規約）を把握する。
   ファイルが存在しない場合は、`$PRODUCT_DESC` と `$STACK_ARG` のみを使用する。
2. `$MASTER_MD` の存在を確認する。
   - **存在する場合（かつ --persist 未指定）**: 差分マージモードとして既存設計を保持し追記する。
   - **存在しない場合 / --persist 指定時**: 新規生成モード。

---

# step2: 業界・プロダクトカテゴリの特定

`$PRODUCT_DESC` を分析し、以下の軸でプロダクトを分類する。

**業界カテゴリ（例）**:

| 大分類 | 代表的なプロダクトタイプ |
|--------|------------------------|
| Tech / SaaS | SaaS ダッシュボード、開発ツール、AI プラットフォーム、B2B サービス |
| Finance | Fintech、決済、資産管理、請求・インボイス |
| Healthcare | 医療クリニック、薬局、メンタルヘルス、予約管理 |
| E-commerce | 一般 EC、高級品、マーケットプレイス、サブスクリプション |
| Services | 美容・スパ、飲食、ホテル、法律、ホームサービス |
| Creative | ポートフォリオ、エージェンシー、写真、ゲーム、音楽 |
| Lifestyle | ハビットトラッカー、料理、瞑想、日記、気分管理 |
| Education | LMS、語学学習、スキルアップ、資格試験 |
| Community | SNS、フォーラム、イベント管理、DAO / Web3 |
| Emerging | NFT / Web3、スペーシャルコンピューティング、IoT |

分類結果を基に、**業界固有の設計原則**を以下の観点で決定する:
- ユーザーの感情的期待（信頼感、楽しさ、高級感、効率性など）
- 典型的なランディングページ構造（ヒーロー→機能→社会的証明→CTA など）
- 避けるべき業界固有のアンチパターン

---

# step3: 多次元デザイン推論

以下の 5 次元を同時に推論し、`$PRODUCT_DESC` と step2 のカテゴリに最適な組み合わせを選定する。

## 次元 1: スタイル方向性

代表的なスタイルから最も適切なものを 1〜2 つ選択し、選択理由を記載する。

| スタイル | 特徴 | 適したプロダクト |
|---------|------|----------------|
| Minimalism | 余白重視、モノクロ基調、タイポグラフィ主役 | SaaS、開発ツール、ポートフォリオ |
| Soft UI / Neumorphism | ソフトシャドウ、柔らかな奥行き | ウェルネス、美容、ライフスタイル |
| Glassmorphism | 半透明、ぼかし、レイヤー感 | AI、Fintech、Web3、ゲーム |
| Brutalism | 太いボーダー、コントラスト強、意図的な荒さ | クリエイティブ、音楽、カウンターカルチャー |
| Corporate / Enterprise | 整然、信頼感、ブルー/グレー基調 | B2B、金融、医療、法律 |
| Dark Mode First | ダーク背景、明るいアクセント | 開発ツール、エンタメ、ゲーム |
| Bento Grid | カード型グリッド、モダン、Notion 風 | SaaS、分析ダッシュボード |
| AI-Native | パープル〜ブルーグラデーション ※金融・医療には不適 | AI プラットフォーム限定 |
| Claymorphism | 3D 感、鮮やかな色、柔らかい影 | 子ども向け、教育、ゲーミフィケーション |
| Luxury / Editorial | セリフフォント、ゴールド/シルバー、大胆な余白 | 高級ブランド、ファッション、不動産 |

## 次元 2: カラーパレット

業界カテゴリと選択スタイルに基づいてカラーパレットを決定する。

**カラー選定の原則**:
- Primary: ブランドの核となる色。業界の感情的期待に沿う色相を選ぶ。
- Secondary: Primary と調和しつつ補助的役割を担う色。
- Accent: CTA・バッジ・ハイライトに使う。注目を集める高彩度または対照色。
- Neutral: テキスト・背景・ボーダー用。ライトモードで 100〜900 スケールを定義。
- Semantic: Success（緑系）/ Warning（橙系）/ Error（赤系）/ Info（青系）。

**業界別カラームード（参考）**:

| 業界 | 推奨色の方向性 | 避けるべき色 |
|------|--------------|------------|
| 金融・銀行 | ネイビー、ダークグリーン、グレー | AI パープル、ネオン系 |
| 医療・ヘルスケア | クリーンホワイト、ソフトブルー、グリーン | 暗すぎる色、過度な彩度 |
| 美容・ウェルネス | ソフトピンク、セージグリーン、ゴールド | 原色系、ビビッド |
| EC（高級品） | ブラック、ゴールド、シルバー、クリーム | 安っぽい明るい色 |
| クリエイティブ | 自由だが一貫性を保つ | 4色以上の主要色 |
| SaaS / 開発ツール | インディゴ、スレート、白 | 過度な彩度・多色使い |

各色は必ず **CSS カスタムプロパティ名（`--color-*`）** と **HEX 値** のセットで定義する。

## 次元 3: タイポグラフィ

**フォントペアリングの原則**:
- 見出し用（Display）と本文用（Body）の 2 フォントを選ぶ。
- 見出し: 個性と印象を担う。セリフ・サンセリフ・スラブセリフから業界に合わせる。
- 本文: 可読性最優先。サンセリフが基本。16px 以上、line-height 1.5〜1.7。
- Google Fonts から選ぶことでウェブフォントの可用性を担保する。

**業界別フォントムード**:

| ムード | 推奨フォント例（見出し / 本文） |
|--------|-------------------------------|
| Trust / Corporate | Inter / Inter、Source Sans / Roboto |
| Elegant / Luxury | Cormorant Garamond / Montserrat、Playfair Display / Lato |
| Modern / Tech | Plus Jakarta Sans / Inter、Space Grotesk / Work Sans |
| Friendly / Casual | Nunito / Nunito Sans、Poppins / Open Sans |
| Creative / Editorial | DM Serif Display / DM Sans、Fraunces / Figtree |

フォントサイズスケールは **1.25 倍（Major Third）** または **1.333 倍（Perfect Fourth）** を基準に定義する。

## 次元 4: スペーシング・レイアウト

- **4px ベースグリッド**を採用。全スペーシング値は 4 の倍数。
- コンテナ最大幅: Mobile 100% / Tablet 720px / Desktop 960px / Wide 1280px。
- カラムシステム: 12 カラムグリッドを基本とし、モバイルは 4 カラムに縮退。

## 次元 5: インタラクション・エフェクト

- ホバー: 150〜300ms の CSS transition（transform / opacity / background-color）。
- フォーカス: `outline: 2px solid var(--color-primary); outline-offset: 2px;`。
- アニメーション: `prefers-reduced-motion: reduce` で無効化できる設計。
- ローディング: スケルトン UI 優先。スピナーは 150ms 超の処理に限定。

---

# step4: 業界固有チェックリスト・アンチパターン選定

step2 の業界カテゴリと step3 の推論結果に基づき、以下を具体的に列挙する。

**アンチパターン（業界固有のタブー）の例**:
- 金融: AI パープル/ピンクグラデーション、信頼感を損なう派手なアニメーション
- 医療: 過度なダークモード、クリックを急かす強引な CTA
- 高級品 EC: 過度なソーシャルプルーフ、安売り訴求
- SaaS: 情報量過多のヒーロー、6色以上のカラー使用

**Pre-delivery チェックリスト（全プロダクト共通）**:
- アイコンに絵文字を使わない（SVG アイコン：Heroicons / Lucide）
- 全クリック要素に `cursor: pointer`
- ホバーステート（150〜300ms smooth transition）
- テキストコントラスト比 4.5:1 以上（WCAG 2.1 AA）
- フォーカスステートがキーボードナビ向けに設定されている
- `prefers-reduced-motion` 対応
- レスポンシブ対応（375px / 768px / 1024px / 1440px）

---

# step5: design-system/MASTER.md 生成

`design-system/` ディレクトリを作成し、以下のフォーマットで `MASTER.md` を Write する。

```markdown
---
kairo:
  node_id: "design-system:$FEATURE"
  artifact_type: "design-system"
  phase: "TDS"
  feature: "$FEATURE"
  stack: "$STACK_ARG"
  status: "approved"
  created_at: "<ISO8601 現在時刻>"
  updated_at: "<ISO8601 現在時刻>"

coherence:
  depends_on:
    - "req:$FEATURE"
  trusted_by:
    - "design:$FEATURE"
    - "imp:*"
  confidence: 1.0
---

# Design System — $FEATURE

> Generated by `/kairo:design-system`
> Stack: $STACK_ARG | Feature: $FEATURE | Category: <業界カテゴリ>

## 1. Style Direction

**スタイル**: <選択スタイル名>
**方向性**: <キーワード3〜5個。例: "Soft shadows, subtle depth, calming, premium feel">
**選択理由**: <プロダクトカテゴリとスタイルの適合性を 1〜2 文で説明>
**このプロダクトに最適な理由**: <ターゲットユーザーの期待・業界慣習との整合性>

## 2. Color Palette

| Role | Token | Hex | Usage |
|------|-------|-----|-------|
| Primary | `--color-primary` | `#...` | CTA, Links, Focus ring |
| Secondary | `--color-secondary` | `#...` | Secondary actions |
| Accent | `--color-accent` | `#...` | Highlights, Badges |
| Neutral 50 | `--color-neutral-50` | `#...` | Background (light) |
| Neutral 100 | `--color-neutral-100` | `#...` | Surface |
| Neutral 700 | `--color-neutral-700` | `#...` | Secondary text |
| Neutral 900 | `--color-neutral-900` | `#...` | Body text |
| Success | `--color-success` | `#...` | Positive states |
| Warning | `--color-warning` | `#...` | Caution states |
| Error | `--color-error` | `#...` | Error states |

**カラームード**: <パレットのトーン・雰囲気を 1 文で>

## 3. Typography

**Font Pair**: <見出しフォント名> / <本文フォント名>
**Google Fonts Import URL**: `https://fonts.google.com/share?selection.family=...`

| Scale | Token | Size | Weight | Line Height | Usage |
|-------|-------|------|--------|-------------|-------|
| Display | `--text-display` | 3rem | 700 | 1.1 | Hero headlines |
| H1 | `--text-h1` | 2.25rem | 700 | 1.2 | Page titles |
| H2 | `--text-h2` | 1.75rem | 600 | 1.3 | Section titles |
| H3 | `--text-h3` | 1.375rem | 600 | 1.4 | Subsections |
| Body | `--text-body` | 1rem | 400 | 1.6 | Body text |
| Small | `--text-small` | 0.875rem | 400 | 1.5 | Captions |
| Label | `--text-label` | 0.75rem | 500 | 1.4 | Form labels, tags |

## 4. Spacing System

4px ベースグリッド。`--spacing-<n>` = `n * 4px`。

| Token | Value | Usage |
|-------|-------|-------|
| `--spacing-1` | 4px | Icon gap, tight elements |
| `--spacing-2` | 8px | Component internal padding |
| `--spacing-4` | 16px | Default element spacing |
| `--spacing-6` | 24px | Section internal spacing |
| `--spacing-8` | 32px | Card padding |
| `--spacing-12` | 48px | Large section gap |
| `--spacing-16` | 64px | Section-to-section spacing |

## 5. Layout & Breakpoints

| Breakpoint | Min Width | Container Max | Grid Columns |
|-----------|-----------|---------------|-------------|
| Mobile | 375px | 100% (16px padding) | 4 |
| Tablet | 768px | 720px | 8 |
| Desktop | 1024px | 960px | 12 |
| Wide | 1440px | 1280px | 12 |

## 6. Component Patterns

**推奨ランディングページ構造**:
<業界カテゴリに最適なセクション順序。例: Hero → Features → Social Proof → Pricing → CTA>

**Key Components**:
<業界固有の重要 UI コンポーネントとその設計指針>

## 7. Interaction Principles

- **Hover**: `transition: all 200ms ease;` を全インタラクティブ要素に
- **Focus**: `outline: 2px solid var(--color-primary); outline-offset: 2px;`
- **Cursor**: `cursor: pointer` を全クリック要素に
- **Animation**: `@media (prefers-reduced-motion: reduce)` で transition を無効化
- **Loading**: スケルトン UI 優先。スピナーは 150ms 超の処理のみ

## 8. Stack-specific Notes

**Stack**: $STACK_ARG

<Tailwind / React / Next.js / Vue など、選択スタックに合わせた実装ノート>

例（html-tailwind の場合）:
- カラートークンは `tailwind.config.js` の `theme.extend.colors` で定義
- フォントは `tailwind.config.js` の `theme.extend.fontFamily` で定義
- スペーシングは Tailwind デフォルトとほぼ一致（4px ベース）

## 9. Anti-patterns（このプロダクトで避けるべきパターン）

<step4 で選定した業界固有アンチパターンを箇条書きで記載>

## 10. Pre-delivery Checklist

`/kairo:implement` の UI 完了後に自動検証するチェックリスト。

- [ ] アイコンに絵文字を使っていない（SVG: Heroicons / Lucide を使用）
- [ ] `cursor: pointer` が全クリック要素に付与されている
- [ ] ホバーステート `transition 150–300ms` が設定されている
- [ ] テキストコントラスト比 4.5:1 以上（WCAG 2.1 AA）を満たす
- [ ] フォーカスステートがキーボードナビ向けに設定されている
- [ ] `prefers-reduced-motion` が考慮されている
- [ ] レスポンシブ対応（375px / 768px / 1024px / 1440px）
- [ ] 本ドキュメントのカラートークンのみ使用（ハードコード HEX なし）
- [ ] タイポグラフィが section3 のスケールに準拠している
- [ ] スペーシングが 4px グリッドに合っている
```

---

# step6: ページ別オーバーライド（--page 指定時のみ）

`$PAGE_ARG` が指定された場合 `design-system/pages/$PAGE_ARG.md` を Write する。

MASTER.md から**逸脱する部分のみ**を記載する（MASTER.md に準拠する項目は省略）。

```markdown
---
kairo:
  node_id: "design-system-page:$FEATURE/$PAGE_ARG"
  artifact_type: "design-system-page"
  phase: "TDS"
coherence:
  depends_on:
    - "design-system:$FEATURE"
  confidence: 1.0
---

# Page Design Override — $PAGE_ARG

<!-- MASTER.md から逸脱するルールのみ記載。準拠する部分は省略してここに書かない -->
```

---

# step7: CEG 更新

`$COHERENCE_JSON` を Read し、以下のノードを追加または更新して Write する:

```json
{
  "node_id": "design-system:$FEATURE",
  "artifact_type": "design-system",
  "phase": "TDS",
  "file": "design-system/MASTER.md",
  "depends_on": ["req:$FEATURE"],
  "trusted_by": ["design:$FEATURE"],
  "confidence": 1.0,
  "status": "APPROVED"
}
```

---

# step8: サマリー出力

```
✅ design-system/MASTER.md を生成しました

📦 スタック    : $STACK_ARG
🏷  カテゴリ   : <業界カテゴリ>
🎨 スタイル    : <推奨スタイル名>
🎯 Primary    : <hex>  Secondary: <hex>
🔤 フォントペア: <見出しフォント> / <本文フォント>
🔗 CEG ノード  : design-system:$FEATURE

次のステップ:
  /kairo:spec-design $FEATURE   ← design.md に Design System セクションを追加
  /kairo:implement <issue-id>   ← UI 実装時に MASTER.md を自動参照
```
