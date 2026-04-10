#!/bin/bash
# Unsplash 画像検索スクリプト
# 使い方: ./unsplash-search.sh "keyword" [per_page]
# 出力: Unsplash API の生 JSON を stdout に出力
# 注意: API キーはこのスクリプト内でのみ使用し、外部（Claude コンテキスト等）には渡さない

set -euo pipefail

QUERY="${1:-}"
PER_PAGE="${2:-10}"
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

if [ -z "${UNSPLASH_ACCESS_KEY:-}" ]; then
  echo '{"error":"UNSPLASH_ACCESS_KEY が設定されていません","guide":"プロジェクトルートの .env.local に UNSPLASH_ACCESS_KEY=your_key を追加してください"}' >&2
  exit 1
fi

if [ -z "$QUERY" ]; then
  echo "使い方: $0 \"keyword\" [per_page]" >&2
  exit 1
fi

# --get + --data-urlencode でクエリを安全にエンコード
# curl はプロキシ環境変数（HTTPS_PROXY / HTTP_PROXY 等）を自動認識する
curl -sf --get \
  "https://api.unsplash.com/search/photos" \
  --data-urlencode "query=${QUERY}" \
  -d "per_page=${PER_PAGE}" \
  -d "orientation=landscape" \
  -H "Authorization: Client-ID ${UNSPLASH_ACCESS_KEY}" \
  -H "Accept-Version: v1"
