---
name: unsplash-image-finder
description: This skill should be used when searching for or inserting images from Unsplash into web pages. Triggered when the user asks to find photos or images, when hero sections, backgrounds, or visual content are needed during page creation, or when the user mentions Unsplash, photos, or visual search.
user-invocable: true
---

# Unsplash Image Finder Skill

Unsplash API を使って画像を検索し、最適化された URL を Web ページ用に提供する。

注意: 以下のコマンドはすべて**プロジェクトルートから実行**すること。

---

## シーン判定（最初に行うこと）

| 条件 | シーン |
|------|--------|
| 「動作確認」「テスト」「使えるか確認」の依頼 | **C** — ヘルスチェック |
| HTMLへの埋め込みが目的（`one-page-site-builder` 連携、または「使って」「入れて」等の指示） | **B** — 内部利用 |
| ユーザーへの候補提示が目的（「探して」「どんな画像がある？」等） | **A** — 候補提示 |

---

## シーン C: ヘルスチェック

```bash
bash .claude/skills/unsplash-image-finder/unsplash-health-check.sh
```

- `status: "ok"` → ユーザーに「画像検索は使えます」と伝える
- `status: "error"` → `message` と `guide` をユーザーに分かりやすく伝える

---

## 共通ステップ（シーン A・B 共通）

### ステップ 1: 画像を検索する

```bash
bash .claude/skills/unsplash-image-finder/unsplash-search.sh "keyword"
```

生 JSON を stdout に出力する。デフォルト 10 件（`results[0]`〜`results[9]`）。

```bash
# 件数を指定する場合
bash .claude/skills/unsplash-image-finder/unsplash-search.sh "keyword" 5
```

複数セクションに画像が必要な場合も 1 回の検索で賄えることが多い。適切な画像がない・数が足りない場合は再検索する。

### ステップ 2: JSON から情報を取り出す

```
results[n].urls.raw                → 画像のベースURL（パラメータ付加前）
results[n].urls.small              → サムネイルURL（約400px幅）
results[n].links.html              → UnsplashページURL（ユーザーがブラウザで確認できるURL）
results[n].links.download_location → ダウンロード追跡URL（規約必須）
results[n].description             → 画像の説明（画像選択の判断に使う）
results[n].alt_description         → 画像の代替テキスト（画像選択の判断に使う）
results[n].user.name               → 撮影者名（クレジット表記用）
results[n].user.username           → 撮影者のUnsplashユーザー名
```

**画像選択の判断**: `description` / `alt_description` フィールドと検索順位を根拠に選ぶ。サムネイルの視覚確認は省略してよい。

### ステップ 3: 画像 URL を最適化する

`results[n].urls.raw` に以下のパラメータを付加する：

| パラメータ | 推奨値 | 用途 |
|---|---|---|
| `w` | Hero: 1920 / コンテンツ: 800〜1200 / サムネイル: 400 | 幅 |
| `q` | 80（重要な画像は 90） | 品質 |
| `fm` | webp | フォーマット |
| `fit` | crop | フィット |

例: `https://images.unsplash.com/photo-xxx?w=1200&q=80&fm=webp&fit=crop`

### ステップ 4: ダウンロード追跡（規約必須）

画像 URL を使用したら必ず実行する：

```bash
bash .claude/skills/unsplash-image-finder/unsplash-track.sh "download_location の URL"
```

`tracked` と出力されれば成功。失敗しても処理を続行してよい。

---

## シーン A: 候補提示（ユーザーへの出力）

候補をマークダウン表で提示する。各行に以下を含める：

- `results[n].links.html` へのクリッカブルリンク（ユーザーが画像を確認するために**必須**）
- 最適化済み URL（コピー用）
- 撮影者名

**フォーマット例:**

```
| # | 内容 | 撮影者 | 最適化URL |
|---|------|--------|-----------|
| [1](https://unsplash.com/photos/xxx) | 辞書のクローズアップ | Romain Vignes | `https://images.unsplash.com/photo-xxx?w=1920&q=80&fm=webp&fit=crop` |
```

ユーザーが画像を選んだらステップ 4（追跡リクエスト）を実行する。

---

## シーン B: 内部利用（HTML への埋め込み）

ユーザーへの候補提示は省略し、最適な画像を選んで HTML に直接組み込む。
埋め込んだ時点でステップ 4（追跡リクエスト）を実行する。

---

## フォールバック

1. **API エラー / 検索結果なし**: 別キーワードで再検索（例: "coffee shop" → "cafe" → "coffee"）
2. **再検索でも取得できない**: `https://cwm.toiee.jp/images/dummy.jpg`（プレースホルダー）を使用し、ユーザーに通知する

---

## クレジット表記（推奨）

```html
Photo by <a href="https://unsplash.com/@username?utm_source=claude1page&utm_medium=referral">撮影者名</a>
on <a href="https://unsplash.com?utm_source=claude1page&utm_medium=referral">Unsplash</a>
```

---

初回セットアップは [references/setup.md](references/setup.md) を参照。
