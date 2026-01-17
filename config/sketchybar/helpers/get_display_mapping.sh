#!/bin/bash

# sketchybar displays からarrangement-idとx座標を取得
# sketchybarが起動完了するまで少し待つ
sleep 0.5
echo "SKETCHYBAR"
sketchybar --query displays 2>/dev/null | tr -d '\n\t ' | grep -oE '"arrangement-id":[0-9]+,"DirectDisplayID":[0-9]+,"UUID":"[^"]+","frame":\{"x":[0-9.-]+' | sed 's/.*"arrangement-id":\([0-9]*\).*"x":\([0-9.-]*\).*/\1|\2/'

# NSScreenからindex+1とx座標を取得
echo "NSSCREEN"
swift -e '
import AppKit
for (idx, screen) in NSScreen.screens.enumerated() {
    print("\(idx + 1)|\(Int(screen.frame.origin.x))")
}
' 2>/dev/null

# aerospace monitorsからmonitor-idとnsscreen-idを取得
echo "AEROSPACE"
aerospace list-monitors --format '%{monitor-id}|%{monitor-appkit-nsscreen-screens-id}' 2>/dev/null
