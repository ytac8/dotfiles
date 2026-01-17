#!/bin/bash

# NSScreenからindex+1とx座標を取得
echo "NSSCREEN"
nsscreen_data=$(swift -e '
import AppKit
for (idx, screen) in NSScreen.screens.enumerated() {
    print("\(idx + 1)|\(Int(screen.frame.origin.x))")
}
' 2>/dev/null)
echo "$nsscreen_data"

# sketchybar displays からarrangement-idとx座標を取得
echo "SKETCHYBAR"
sketchybar_data=$(sketchybar --query displays 2>/dev/null | tr -d '\n\t ' | grep -oE '"arrangement-id":[0-9]+,"DirectDisplayID":[0-9]+,"UUID":"[^"]+","frame":\{"x":[0-9.-]+' | sed 's/.*"arrangement-id":\([0-9]*\).*"x":\([0-9.-]*\).*/\1|\2/')
if [ -n "$sketchybar_data" ]; then
    echo "$sketchybar_data"
else
    # Fallback: bounding_rectsからsketchybar display番号とx座標の対応を取得
    # widgets.clockをクエリして各displayのbounding_rects x座標を取得し、NSScreenのx座標にマッピング
    clock_query=$(sketchybar --query widgets.clock 2>/dev/null)
    for d in 1 2 3; do
        # display-N の次の行からorigin座標を取得
        x_coord=$(echo "$clock_query" | grep -A2 "\"display-${d}\"" | grep origin | sed 's/.*\[ *\([^,]*\).*/\1/' | tr -d ' ')
        if [ -n "$x_coord" ]; then
            x_int=${x_coord%.*}
            # NSScreenのx座標と比較してマッチするものを探す
            echo "$nsscreen_data" | while IFS='|' read ns_id ns_x; do
                # x_intがns_xからns_x+4000の範囲内かチェック
                if [ "$x_int" -ge "$ns_x" ] 2>/dev/null && [ "$x_int" -lt "$((ns_x + 4000))" ] 2>/dev/null; then
                    echo "${d}|${ns_x}"
                fi
            done
        fi
    done
fi

# aerospace monitorsからmonitor-idとnsscreen-idを取得
echo "AEROSPACE"
aerospace list-monitors --format '%{monitor-id}|%{monitor-appkit-nsscreen-screens-id}' 2>/dev/null
