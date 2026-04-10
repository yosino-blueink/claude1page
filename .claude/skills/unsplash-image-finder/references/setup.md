# Unsplash API セットアップ

## Access Key の取得

1. https://unsplash.com/developers にアクセス
2. 「New Application」をクリック
3. API Key（Access Key）を取得

## 環境変数の設定

環境変数に設定すると、他のプロジェクトでも使えて便利です。

また、プロジェクトルートの `.env.local` に記載することもできます。

```
UNSPLASH_ACCESS_KEY=your_access_key_here
```

設定後、ヘルスチェックで動作確認：

```bash
bash .claude/skills/unsplash-image-finder/unsplash-health-check.sh
```
