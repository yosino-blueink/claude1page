#!/bin/bash
# claude1page アップデートスクリプト
# Usage: curl -fsSL https://raw.githubusercontent.com/toiee-lab/claude1page/main/scripts/update.sh | bash
set -e

BASE_URL="https://raw.githubusercontent.com/toiee-lab/claude1page/main"

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  claude1page アップデート${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# カレントディレクトリに CLAUDE.md があるか確認
if [ ! -f "CLAUDE.md" ]; then
    echo -e "${RED}エラー: CLAUDE.md が見つかりません。${NC}"
    echo "claude1page プロジェクトのルートディレクトリで実行してください。"
    exit 1
fi

# --- 古いファイルの削除 ---
echo -e "${YELLOW}古いファイルを削除中...${NC}"

# v1 の構成で存在していたファイル
rm -rf scripts/install_pkgs.sh
rm -rf dev-tools/
rm -f .claude/agents/unsplash-image-finder.md
# Node.js 版から Shell 版への移行で不要になったファイル
rm -f .claude/skills/unsplash-image-finder/unsplash-search.js
# one-page-site-builder references を SKILL.md に統合
rm -rf .claude/skills/one-page-site-builder/references

echo "  done"

# --- ディレクトリ作成 ---
echo -e "${YELLOW}ディレクトリを準備中...${NC}"
mkdir -p .claude/skills/unsplash-image-finder
mkdir -p .claude/skills/unsplash-image-finder/references
mkdir -p .claude/skills/one-page-site-builder
mkdir -p scripts
echo "  done"

# --- 最新ファイルのダウンロード ---
echo -e "${YELLOW}最新ファイルをダウンロード中...${NC}"

download() {
    local dest="$1"
    local url="${BASE_URL}/${dest}"
    if curl -fsSL -o "$dest" "$url"; then
        echo "  ✓ $dest"
    else
        echo -e "  ${RED}✗ $dest (ダウンロード失敗)${NC}"
    fi
}

download "CLAUDE.md"
download ".claude/settings.json"
download ".claude/launch.json"
download ".rgignore"
download ".env.local.example"
download ".gitignore"
download ".claude/skills/unsplash-image-finder/SKILL.md"
download ".claude/skills/unsplash-image-finder/unsplash-search.sh"
download ".claude/skills/unsplash-image-finder/unsplash-health-check.sh"
download ".claude/skills/unsplash-image-finder/unsplash-track.sh"
download ".claude/skills/unsplash-image-finder/references/setup.md"
download ".claude/skills/one-page-site-builder/SKILL.md"
download "scripts/update.sh"
download "scripts/update.ps1"
download "package.json"
download "package-lock.json"
download "README.md"

# 実行権限を付与
chmod +x scripts/update.sh 2>/dev/null || true
chmod +x .claude/skills/unsplash-image-finder/unsplash-search.sh 2>/dev/null || true
chmod +x .claude/skills/unsplash-image-finder/unsplash-health-check.sh 2>/dev/null || true
chmod +x .claude/skills/unsplash-image-finder/unsplash-track.sh 2>/dev/null || true

# --- 完了 ---
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ アップデート完了！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}⚠️  注意:${NC}"
echo "  CLAUDE.md をカスタマイズしていた場合は、"
echo "  git diff で変更を確認し、必要に応じて再反映してください。"
echo ""
