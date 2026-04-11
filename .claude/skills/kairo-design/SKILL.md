---
name: kairo-design
description: >
  kairo IMP 中心設計と CEG（Conditioned Evidence Graph）に統合された UI/UX デザインインテリジェンス。
  UUPM（ui-ux-pro-max-skill）の設計思想を Claude ネイティブ推論として内部化し、
  VCKD パイプライン（REQ → TDS → IMP → TEST → OPS → CHANGE）全体で
  デザインシステムの生成・検証・ドリフト検出を自律的に実行する。
  Actions: design, build, create, implement, review, fix, improve, optimize, check UI/UX, generate design system.
applyTo: "**"
---

# kairo Design Intelligence — UUPM × IMP × CEG

> kairo v1.1 方針: 外部スクリプト呼び出し・git clone は一切使用しない。
> Claude 自身が UUPM 設計思想データベースとして機能し、全推論をネイティブに実行する。

---

## When to Apply

### Must Use（必須発動）

このスキルは以下の状況で **必ず** 使用する:

- `/kairo:design-system` を実行するとき
- `/kairo:spec-design` で UI/UX 設計を含む設計書を生成するとき
- `/kairo:implement` で UI コンポーネントを実装するとき（`design-system/MASTER.md` 参照）
- `/kairo:review --persona ui` または `/kairo:review --adversary` で D6 を評価するとき
- `/kairo:drift_check` で D6（デザインドリフト）を評価するとき
- IMP のタスクに `UI`, `画面`, `コンポーネント`, `レイアウト`, `デザイン` が含まれるとき

### Recommended（推奨発動）

- `/kairo:imp_generate` で UI 実装タスクを含む IMP を生成するとき
- `/kairo:test` で UI コンポーネントのテスト戦略を設計するとき
- `/kairo:sync` で design-system アーティファクトの整合性を確認するとき
- UI の「プロらしくない」「統一感がない」というフィードバックに対応するとき

### Skip（スキップ）

- 純粋なバックエンドロジック・API・DB 設計のとき
- パフォーマンス最適化が UI に関わらないとき
- インフラ・DevOps 作業のとき

**判断基準**: タスクが「画面の見た目・感触・動き・インタラクション」に影響する場合はこのスキルを使う。

---

## kairo VCKD パイプラインでの位置づけ

```
REQ ──► TDS ──► IMP ──► TEST ──► OPS ──► CHANGE
         │        │        │
         │        │        └── implement 時に MASTER.md 参照（REQ-013）
         │        └─────────── IMP タスクに UIコンポーネント設計を記述
         └──────────────────── design-system/MASTER.md 生成（TDS フェーズ）
                                CEG ノード: design-system:<feature>
```

**CEG 成果物の連鎖**:
```
req:<feature>
  └─► design-system:<feature>  (design-system/MASTER.md)
        └─► design:<feature>   (design.md の ## Design System セクション)
              └─► imp:<feature>  (IMP.md の UI タスク)
                    └─► drift-report:<feature> (D6: デザインドリフト)
```

---

## Part 1: 業界カテゴリ特定（Step 2a）

### 10 大業界分類

プロダクトの説明から以下のカテゴリに分類し、ユーザーの感情的期待を特定する:

| カテゴリ | 代表プロダクト | ユーザーの感情的期待 |
|---------|--------------|-------------------|
| **Tech/SaaS** | SaaS, B2B, 開発ツール, AI/Chatbot | 信頼性・革新性・効率感 |
| **Finance** | Fintech, 銀行, 保険, 請求ツール | 安心感・堅牢性・透明性 |
| **Healthcare** | 病院, 薬局, メンタルヘルス | 清潔感・安心感・プロ感 |
| **E-commerce** | 総合EC, 高級EC, 食品デリバリー | 欲求喚起・信頼・発見感 |
| **Services** | 美容/スパ, レストラン, 法律 | 親近感・信頼・上質感 |
| **Creative** | ポートフォリオ, 写真, ゲーム | 個性・驚き・没入感 |
| **Lifestyle** | 習慣管理, レシピ, 瞑想 | 穏やかさ・継続性・達成感 |
| **Education** | 学習, コーチング, 資格 | 成長感・安心・モチベーション |
| **Community** | SNS, フォーラム, イベント | 帰属感・楽しさ・つながり |
| **Emerging** | Web3/NFT, 空間コンピューティング | 未来感・希少性・革新 |

**推論手順**:
1. プロダクト説明からキーワードを抽出する
2. 最も近いカテゴリを 1〜2 個選定する
3. 「ユーザーが初めてプロダクトを見たときに感じてほしい感情」を 1 文で定義する

---

## Part 2: 5 次元デザイン推論（Step 2b）

業界カテゴリを踏まえ、以下の 5 次元を**同時に**推論して整合性を保つ:

### 次元 1: スタイル方向性

| スタイル名 | 特徴 | 適合業界 |
|-----------|------|---------|
| Minimalism | 余白・シンプル・フォント主体 | SaaS, Finance, Healthcare |
| Glassmorphism | 半透明・ブラー・光彩 | Tech, Creative, Emerging |
| Soft UI / Neumorphism | ソフトシャドウ・凸凹感 | Lifestyle, Wellness, Education |
| Claymorphism | 丸み・立体感・彩度高め | Lifestyle, Education, Community |
| Bento Grid | カード分割・非対称グリッド | SaaS, Portfolio, Tech |
| Dark Mode Native | ダーク基調・高コントラスト | Tech, Gaming, Creative |
| Brutalism | 生々しさ・意図的な粗さ | Creative, Emerging |
| Corporate Clean | グリッド厳密・権威感 | Finance, Healthcare, Legal |
| Warm Editorial | 温かみ・読みやすさ・人間味 | Lifestyle, Education, Services |
| Luxury Minimal | 余白最大・ゴールド/モノクロ | 高級EC, Hotel, Legal |

**選定基準**: 業界カテゴリ × ユーザーの感情的期待 × スタック制約の 3 要素で決定する。

### 次元 2: カラーパレット

**必須 8 役割** を業界に合わせて定義する:

| 役割 | トークン | 用途 |
|------|---------|------|
| Primary | `--color-primary` | CTA, リンク, フォーカスリング |
| Secondary | `--color-secondary` | サブアクション, ホバー |
| Accent | `--color-accent` | ハイライト, バッジ, 装飾 |
| Neutral-100 | `--color-neutral-100` | 背景, 最明カラー |
| Neutral-900 | `--color-neutral-900` | 本文テキスト |
| Success | `--color-success` | 成功/完了状態 |
| Warning | `--color-warning` | 注意/警告状態 |
| Error | `--color-error` | エラー状態 |

**業界別カラー禁忌**（アンチパターン）:

| 業界 | 禁忌 | 理由 |
|------|------|------|
| Finance/Banking | AI パープル・ピンク系グラデーション | 信頼性を損なう |
| Healthcare | 過剰なダークモード・鮮やかな赤 | 不安感・緊急感を生む |
| 高級品 EC | 安売り感のある黄/橙, 多色使い | ブランド毀損 |
| Legal/Professional | 原色・ポップな配色 | 権威性を損なう |
| Education（子供向け） | 単色ダーク基調 | 学習意欲を低下させる |

### 次元 3: タイポグラフィ

**必須スケール** (4 段階):

| スケール | トークン | サイズ | ウェイト | 行間 |
|---------|---------|--------|---------|------|
| H1 | `--text-h1` | 2.5rem | 700 | 1.2 |
| H2 | `--text-h2` | 2rem | 600 | 1.3 |
| H3 | `--text-h3` | 1.5rem | 600 | 1.4 |
| Body | `--text-body` | 1rem（最小 16px） | 400 | 1.6 |
| Small | `--text-small` | 0.875rem | 400 | 1.5 |

**フォントペア選定方針**:
- 見出し: ブランド個性を担う（Serif 系 or Display 系）
- 本文: 可読性最優先（Sans-serif 系）
- 両者のウェイト感・時代感を合わせる（新古典 × 幾何）

### 次元 4: スペーシングシステム

4px ベースグリッド。`--spacing-<n>` = `n × 4px`:

| トークン | 値 | 用途 |
|---------|-----|------|
| `--spacing-1` | 4px | アイコンギャップ |
| `--spacing-2` | 8px | コンポーネント内パディング |
| `--spacing-4` | 16px | デフォルト要素間隔 |
| `--spacing-6` | 24px | セクション内スペーシング |
| `--spacing-8` | 32px | カードパディング |
| `--spacing-16` | 64px | セクション間スペーシング |

### 次元 5: コンポーネントパターンとインタラクション

**必須インタラクション仕様**:

| 項目 | 仕様 |
|------|------|
| ホバーステート | 150–300ms transition（全インタラクティブ要素） |
| フォーカスリング | `outline: 2px solid var(--color-primary); outline-offset: 2px;` |
| カーソル | `cursor: pointer` を全クリック要素に付与（**最重要**） |
| アニメーション | `prefers-reduced-motion` を尊重 |
| ローディング | スケルトン UI 使用（スピナーは 150ms 超に限定） |

**ブレークポイント標準**:

| 名称 | 幅 | コンテナ最大幅 |
|-----|-----|--------------|
| Mobile | 375px | 100% |
| Tablet | 768px | 720px |
| Desktop | 1024px | 960px |
| Wide | 1440px | 1280px |

---

## Part 3: kairo IMP 統合ルール

### IMP タスクへの UI 設計記述

`/kairo:imp_generate` で UI タスクを含む IMP を生成する際、以下を必ず記述する:

#### IMP タスクの UI 拡張フォーマット

```markdown
### T0X: <UIコンポーネント名>

#### 1.4 Implementation Strategy

**デザインシステム参照**: `design-system/MASTER.md`

**適用トークン**:
- カラー: `var(--color-primary)`, `var(--color-neutral-100)`
- タイポグラフィ: `var(--text-h2)`, `var(--text-body)`
- スペーシング: `var(--spacing-4)`, `var(--spacing-8)`

**コンポーネントパターン**: <業界カテゴリ固有のパターン名>

**インタラクション仕様**:
- hover: opacity 0.9, transition 200ms ease
- focus: `outline: 2px solid var(--color-primary); outline-offset: 2px`
- cursor: pointer（全クリック要素）

#### 1.6 Test Strategy

| TC-ID | AC-ID | テスト観点 | レイヤー |
|-------|-------|----------|---------|
| TC-01 | AC-1 | cursor:pointer が全クリック要素に付与されているか | visual |
| TC-02 | AC-2 | ホバーステートが 150–300ms の transition で動作するか | visual |
| TC-03 | AC-3 | フォーカスリングがキーボードナビで表示されるか | a11y |
| TC-04 | AC-4 | レスポンシブが 375/768/1024/1440px を満たすか | visual |
| TC-05 | AC-5 | カラーコントラスト比が WCAG 2.1 AA (4.5:1) 以上か | a11y |
```

### design-system/MASTER.md の CEG 登録ルール

`design-system/MASTER.md` 生成時に `graph/coherence.json` に以下のノードを追加する:

```json
{
  "node_id": "design-system:<feature>",
  "artifact_type": "design-system",
  "phase": "TDS",
  "file": "design-system/MASTER.md",
  "depends_on": ["req:<feature>"],
  "trusted_by": ["design:<feature>", "imp:<feature>"],
  "confidence": 1.0,
  "status": "APPROVED"
}
```

**CEG バンド判定**:
- `Green`: MASTER.md が存在し、IMP の UI タスクとの整合性が確認済み
- `Amber`: MASTER.md は存在するが、UIタスクとの未整合が 1 件以上ある
- `Gray`: MASTER.md が存在しない（UI タスクがある場合は警告）

---

## Part 4: D6 デザインドリフト検出

`/kairo:drift_check` の既存 D1〜D5 に加えて **D6（デザインシステム乖離）** を評価する:

### D6 スコア算出ルール

| 乖離項目 | スコア加算 | 重大度 |
|---------|-----------|--------|
| `cursor: pointer` が未付与のクリック要素 | +10/件 | CRITICAL |
| ホバーステート (150–300ms transition) が未設定 | +5/件 | WARNING |
| MASTER.md のカラートークンと異なる色が使用されている | +8/件 | WARNING |
| タイポグラフィスケール外のフォントサイズ | +5/件 | WARNING |
| 4px グリッド外のスペーシング値 | +3/件 | INFO |
| レスポンシブブレークポイントが未対応 | +15/件 | CRITICAL |
| WCAG 2.1 AA (4.5:1) コントラスト比未達 | +15/件 | CRITICAL |
| フォーカスリング未設定 | +10/件 | CRITICAL |
| `prefers-reduced-motion` 未対応 | +5/件 | WARNING |
| MASTER.md が存在しない（UI タスクあり） | +20 | CRITICAL |

**D6 バンド判定**:
- `Green` (D6: 0–5): デザインシステムとの整合性が高い
- `Amber` (D6: 6–20): 軽微な乖離あり、修正を推奨
- `Red` (D6: 21+): 重大な乖離あり、リリース前に修正必須

### D6 drift-report への記述フォーマット

```markdown
## D6: デザインシステム乖離

**スコア**: <数値> / **バンド**: <Green|Amber|Red>
**MASTER.md**: <存在する / 存在しない>

### 検出された乖離

| 乖離ID | ファイル | 行 | 問題 | 重大度 | score |
|--------|---------|----|----|--------|-------|
| D6-001 | src/components/Button.tsx | L42 | cursor:pointer 未付与 | CRITICAL | +10 |

### 修正アクション

- [ ] D6-001: `cursor: pointer` を追加する
```

---

## Part 5: Adversarial Review D6 ペルソナ（--persona ui）

`/kairo:review --adversary --persona ui` 実行時の評価観点:

### UI/UX Adversary の評価軸

以下の 5 つのレンズで成果物を批判的に評価する:

#### L1: デザインシステム整合性
- `design-system/MASTER.md` のトークンが実装コードで使用されているか
- ハードコードされたカラー・サイズが混入していないか
- ページ別オーバーライドが MASTER.md に依存しているか

#### L2: アクセシビリティ（WCAG 2.1 AA）
- カラーコントラスト比 4.5:1 以上
- フォーカスリング（`outline: 2px solid`）が全インタラクティブ要素に存在するか
- スクリーンリーダー対応（`aria-label`, `alt` テキスト）
- `prefers-reduced-motion` の考慮

#### L3: インタラクション品質
- `cursor: pointer` が全クリック要素に付与されているか（最重要）
- ホバーステートが 150–300ms の transition で実装されているか
- タッチターゲットが 44×44px 以上か

#### L4: レスポンシブ設計
- 375 / 768 / 1024 / 1440px の各ブレークポイントに対応しているか
- 水平スクロールが発生しないか
- `min-h-dvh`（`100vh` ではなく）を使用しているか（モバイル）

#### L5: 業界アンチパターン違反
- 業界カテゴリに対して禁忌の配色・スタイルが使用されていないか
- 絵文字をアイコンとして使用していないか（SVG を使用すること）
- 過剰なアニメーション・装飾的モーションがないか

### Adversary レポート D6 記述フォーマット

```markdown
## D6: Design Fidelity Adversarial Review

**verdict**: PASS | FAIL
**evaluator**: UI/UX Adversary (kairo v1.1)

### FAIL 項目

| ID | レンズ | 問題 | 根拠 |
|----|-------|------|------|
| D6-F1 | L3 | Button.tsx L42: cursor:pointer 未付与 | MASTER.md §7 要件違反 |

### 修正指示

<!-- FAIL 項目の具体的な修正内容 -->
```

---

## Part 6: Pre-Delivery チェックリスト

`/kairo:implement` の UI コンポーネント完成後、以下を全件確認する:

### 必須（CRITICAL— リリースブロッカー）

- [ ] `cursor: pointer` が全クリック要素に付与されている
- [ ] レスポンシブブレークポイント (375 / 768 / 1024 / 1440px) を満たす
- [ ] カラーコントラスト比が WCAG 2.1 AA (4.5:1) 以上
- [ ] フォーカスリング (`outline: 2px solid var(--color-primary)`) が存在する
- [ ] `design-system/MASTER.md` のトークン（`--color-*`, `--text-*`, `--spacing-*`）を使用している

### 重要（WARNING— Sprint 内修正推奨）

- [ ] ホバーステート (150–300ms `transition`) が設定されている
- [ ] `prefers-reduced-motion` が考慮されている
- [ ] スペーシングが 4px グリッドに合っている
- [ ] タイポグラフィが MASTER.md の `--text-*` スケールに準拠している
- [ ] 絵文字をアイコンとして使用していない（SVG/Lucide/Heroicons を使用）

### 推奨（INFO— 次回イテレーションで対応可）

- [ ] スケルトン UI がローディング状態に使用されている（スピナーは 150ms 超に限定）
- [ ] アニメーションが意味のある因果関係を表現している（装飾目的は不可）
- [ ] コンポーネントが MASTER.md §5 のパターンに準拠している
- [ ] ページ別オーバーライド (`design-system/pages/*.md`) が必要な場合に作成されている

---

## Part 7: スタック別実装ガイドライン

### HTML + Tailwind（デフォルト）

```html
<!-- カラートークンの使い方 -->
<style>
  :root {
    --color-primary: #...;
    --color-secondary: #...;
  }
</style>
<!-- Tailwind 任意値で参照 -->
<button class="bg-[var(--color-primary)] cursor-pointer hover:opacity-90 transition-opacity duration-200">
```

### React / Next.js

```tsx
// CSS Modules + トークン
import styles from './Button.module.css';
// または CSS-in-JS でトークン参照
const Button = styled.button`
  background: var(--color-primary);
  cursor: pointer;
  transition: opacity 200ms ease;
  &:hover { opacity: 0.9; }
  &:focus-visible {
    outline: 2px solid var(--color-primary);
    outline-offset: 2px;
  }
`;
```

### shadcn/ui

- `tailwind.config.ts` の `extend.colors` にトークンを追加する
- `globals.css` の `:root` にトークンを定義する
- shadcn UI コンポーネントの `className` で `text-primary`, `bg-primary` を使用する

---

## Part 8: kairo ワークフローとの統合フロー

```
1. /kairo:design-system <product-desc>
   │
   ├── Part 1: 業界カテゴリ特定
   ├── Part 2: 5次元推論実行
   ├── design-system/MASTER.md 生成
   └── graph/coherence.json に CEG ノード登録

2. /kairo:imp_generate <issue-id>
   │
   └── UI タスクに Part 3 の IMP 拡張フォーマットを適用

3. /kairo:implement <issue-id>
   │
   ├── design-system/MASTER.md を Read して参照
   └── Part 5 のトークンを実装コードに適用

4. /kairo:drift_check <issue-id>
   │
   └── Part 4: D6 スコア算出 → drift-report.md に追記

5. /kairo:review --adversary --persona ui <issue-id>
   │
   └── Part 5: Adversary D6 評価 → adversary-report.md に追記

6. /kairo:sync <issue-id>
   │
   └── design-system CEG ノードの整合性を確認
```

---

## 参照仕様

- `docs/kairo-ui-ux-integration-spec-v1.1.md` — 本スキルの設計根拠
- REQ-011: `/kairo:design-system` 機能要件
- REQ-013: `/kairo:implement` UI 参照要件
- REQ-014: UI/UX Adversarial Review（D6）
- REQ-015: デザインドリフト検出（D6）
