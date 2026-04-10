#!/bin/bash
# Unsplash ダウンロード追跡スクリプト（API 規約準拠）
# 使い方: ./unsplash-track.sh "https://api.unsplash.com/photos/xxx/download?ixid=..."
# 注意: API キーはこのスクリプト内でのみ使用し、外部（Claude コンテキスト等）には渡さない

set -euo pipefail

DOWNLOAD_LOCATION="${1:-}"
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
  echo "error: UNSPLASH_ACCESS_KEY が設定されていません" >&2
  exit 1
fi

if [ -z "$DOWNLOAD_LOCATION" ]; then
  echo "使い方: $0 \"download_location_url\"" >&2
  exit 1
fi

# curl はプロキシ環境変数（HTTPS_PROXY / HTTP_PROXY 等）を自動認識する
curl -sf \
  "$DOWNLOAD_LOCATION" \
  -H "Authorization: Client-ID ${UNSPLASH_ACCESS_KEY}" \
  -H "Accept-Version: v1" \
  -o /dev/null

echo "tracked"
