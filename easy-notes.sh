#!/bin/bash

# 日付を取得してフォーマット
date_str=$(date +"%Y-%m-%d")
year_month=$(date +"%Y-%m")

# 保存ディレクトリを作成
source "$(dirname "$0")/.env"
echo "$DATA_DIRECTORY"
save_dir="${DATA_DIRECTORY}/${year_month}"
mkdir -p "$save_dir"

# 保存ファイルパス
save_file="${save_dir}/${date_str}.json"

# JSONファイルを初期化しない（既存のファイルがあればそのまま）
if [ ! -f "$save_file" ]; then
    echo "[]" > "$save_file"
fi
echo "save_file: $save_file"

# 表示部分を更新する関数
update_display() {
    clear
    echo "=== チャット履歴 ==="
    jq -r '.[] | "\(.timestamp)\(.unixtime)\n\(.content)\n---"' "$save_file"
    echo ""
    echo "==================="
    echo "テキストを入力してね（終了するにはCtrl+Cを押してね）："
}

# 入力を繰り返し待つループ
while true; do
    # 画面を更新
    update_display

    # 日付と時間を取得してフォーマット
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    unixtime=$(date +%s)

    # 入力を待つ
    read text

    # 入力が空でない場合のみ保存
    if [ -n "$text" ]; then
        # jqでJSONに追加
        jq --arg timestamp "$timestamp" --arg unixtime "$unixtime" --arg text "$text" \
           '. += [{"timestamp": $timestamp, "unixtime": ($unixtime | tonumber), "content": $text}]' \
           "$save_file" > tmp.json && mv tmp.json "$save_file"
    fi
done
