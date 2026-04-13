---
name: one-page-site-builder
description: 指定された技術スタックや、作成指針に従ってHTMLを生成します。ユーザーの指示が結局は、HTMLの作成や編集を意図しているときに使います。ランディングページ、ページ、Webページ、ホームページ作成・編集を行う時に使います。
---

非エンジニア向けの、ワンページ完結型・高品質HTML生成スキル。

ランディングページ・サービス紹介・ポートフォリオ・イベント告知・プロフィールページなど、1ページに情報をまとめたいケース。「ワンページで」「LP」「1枚もの」などの指示が目安。

ダッシュボード・管理画面・動的SPAには使わない。

あなたの仕事は、

- **作成**: ユーザーがコンテンツを任せたい場合は創造性を発揮する。コンテンツが事前に決まっている場合はそれに従う
- **編集**: 指定箇所を編集する

## 保存先

文脈・設定ファイルから判断。不明ならユーザーに確認。UTF-8で保存すること。

## 技術スタック

### ライブラリ
- **Tailwind CSS v4.1+**: 必ず以下の形式で読み込む（v3の`<link>`形式は不可）
```html
  <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
```
- カスタムテーマは `<style type="text/tailwindcss">` 内の `@theme` で定義：
```html
  <style type="text/tailwindcss">
    @theme {
      --color-primary: #3b82f6;
      --font-sans: 'Noto Sans JP', sans-serif;
    }
  </style>
```
- **Animate.css v4.1.1+**: アニメーション（控えめに）
- **スクロールアニメーション**: AOS v2.3+ または Animate.css + Intersection Observer API
- **アイコン**: Lucide v0.536.0 (https://lucide.dev/)

### HTML
- セマンティック要素・各セクションにID・メタタグ（description, keywords, og:image等）・ファビコン
- レスポンシブ（モバイルファースト）、画像に `loading="lazy" decoding="async"`

## デザイン

- カラーパレットは `@theme` で設定（コンテンツに合わせて選ぶ）
- フォントはパフォーマンスを考慮して選択

### コンテンツ構造

- セクション構成の指示がなければ自分で考える。**最低8セクション（A4換算6ページ以上）**。ユーザー指示がある場合はそれに従う
- ヒーローセクションから始め、ナビゲーションを重ね、洗練されたイメージを与える
- ナビゲーションリンクを設置（セクションが多すぎる場合は適宜絞る）
- フォームにはバリデーションを実装
- 適度に画像を使用（背景画像も可）

### 画像について

- ユーザー指定がなければ unsplash.com から選ぶ（`/unsplash-image-finder` スキルで検索）
- URLを最適化する例: `https://images.unsplash.com/photo-xxx?w=800&q=80`
- リンク切れを必ず確認すること

## ナビゲーション仕様

### 動作
- `position: fixed` で上部固定（`sticky` 不可）
- 初期：背景透明・リンク白系（Hero背景考慮）
- スクロール50px以降：`backdrop-filter: blur(12px)` + 白の半透明背景（透明度約70%）・リンク暗色に切替
- スクロールイベントは `requestAnimationFrame` でスロットリング
- レスポンシブ：`lg:` ブレークポイントで切替

### アクセシビリティ（必須）
- `<nav>` に `aria-label`
- モバイルメニューボタンに `aria-expanded`・`aria-controls`・`aria-label`、開閉時に動的更新
- アイコンは Lucide の `menu` ⇔ `x` で切替

### デザイン
色・トランジション速度・影は全体デザインに合わせてClaudeが判断。
