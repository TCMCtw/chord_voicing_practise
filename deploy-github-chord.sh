#!/usr/bin/env bash
# 一鍵部署到 GitHub Pages
# 1) 自動從 ~/Downloads 抓「最新下載」的 index*.html 更新 index.html（若有的話）
# 2) 一併加入 manual/ 資料夾內的使用手冊 PDF（若有的話）
# 3) commit + push
set -e

DOWNLOADS="$HOME/Downloads"

# 這個 repo 資料夾＝這支 deploy 腳本所在的資料夾
cd "$(dirname "$0")"

# 在 Downloads 裡找所有 index*.html，依修改時間排序，取最新的一個
LATEST_FILE=$(ls -t "$DOWNLOADS"/index*.html 2>/dev/null | head -n 1)

if [ -n "$LATEST_FILE" ]; then
  echo "找到最新下載的檔案：$LATEST_FILE"
  echo "（修改時間：$(date -r "$LATEST_FILE" '+%Y-%m-%d %H:%M:%S')）"
  cp "$LATEST_FILE" ./index.html
else
  echo "ℹ️  在 $DOWNLOADS 裡找不到 index*.html，略過更新 index.html。"
  echo "   （如果你只是要推送 manual 資料夾裡新增的手冊 PDF，這樣沒關係。）"
fi
echo ""

# 加入 index.html 的變更
git add index.html

# 如果有 manual 資料夾（使用手冊 PDF），一併加入
if [ -d manual ]; then
  git add manual
fi

if git diff --cached --quiet; then
  echo "內容跟上次一樣，沒有變更，略過 commit。"
  echo ""
  echo "⚠️  如果你確定有新版本，可能是："
  echo "   1. Downloads 裡抓到的不是最新那個 index.html 檔案，或"
  echo "   2. 手冊 PDF 還沒放進 manual/ 資料夾裡"
  echo "   請確認後再重新執行這支腳本。"
else
  git commit -m "Update site content $(date '+%Y-%m-%d %H:%M')"
  git push
  echo ""
  echo "✅ 已推送到 GitHub！"
  echo "   GitHub Pages 大約 1–2 分鐘後會自動更新完成，網址不會變。"
fi
