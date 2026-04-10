#!/bin/bash
# Unsplash API ヘルスチェックスクリプト
# 使い方: ./unsplash-health-check.sh
# 出力: JSON形式で status: "ok" または status: "error"
# 注意: API キーはこのスクリプト内でのみ使用し、外部（Claude コンテキスト等）には渡さない

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

# .env.local から UNSPLASH_ACCESS_KEY を読み込む（未設定の場合のみ）
if [ -z "${UNSPLASH_ACCESS_KEY:-}" ] && [ -f "${PROJECT_ROOT}/.env.local" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// }" ]] && continue
    key="${line%%=*}"
    value="${line#*=}"
    if [ "$key" = "UNSPLASH_ACCESS_KEY" ] && [ -z "${UNSPLASH_ACCESS_KEY:-}" ]; then
      export UNSPLASH_ACCESS_KEY="$value"
    fi
  done < "${PROJECT_ROOT}/.env.local"
fi

# Step 1: APIキーの存在確認
if [ -z "${UNSPLASH_ACCESS_KEY:-}" ]; then
  cat <<'EOF'
{
  "status": "error",
  "message": "UNSPLASH_ACCESS_KEY が設定されていません",
  "guide": "設定手順:\n1. https://unsplash.com/developers でアカウント作成・ログイン\n2. 「New Application」でアプリを作成し、Access Key を取得\n3. プロジェクトルートに .env.local ファイルを作成し、以下を記入:\n   UNSPLASH_ACCESS_KEY=取得したキー"
}
EOF
  exit 1
fi

# Step 2: テスト検索（curl はプロキシ環境変数を自動認識）
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --get \
  "https://api.unsplash.com/search/photos" \
  --data-urlencode "query=test" \
  -d "per_page=1" \
  -H "Authorization: Client-ID ${UNSPLASH_ACCESS_KEY}" \
  -H "Accept-Version: v1")

case "$HTTP_STATUS" in
  200)
    echo '{"status":"ok","message":"Unsplash API は正常に動作しています"}'
    ;;
  401)
    echo '{"status":"error","message":"APIキーが無効です（HTTP 401）","guide":".env.local の UNSPLASH_ACCESS_KEY を確認してください"}'
    exit 1
    ;;
  403)
    echo '{"status":"error","message":"アクセス拒否またはレート制限（HTTP 403）","guide":"しばらく待ってから再試行してください"}'
    exit 1
    ;;
  000)
    echo '{"status":"error","message":"接続エラー（ネットワーク到達不可）","guide":"ネットワーク接続とプロキシ設定（HTTPS_PROXY 環境変数）を確認してください"}'
    exit 1
    ;;
  *)
    echo "{\"status\":\"error\",\"message\":\"予期しないHTTPステータス: ${HTTP_STATUS}\"}"
    exit 1
    ;;
esac
