# sketchybar設定

## マルチディスプレイ対応

### 問題

aerospaceのworkspaceをsketchybarで表示する際、sketchybar display番号とaerospace monitor番号のマッピングが必要。

通常は `sketchybar --query displays` でディスプレイ情報を取得できるが、macOS Tahoe (26.x) では動作しない。

```bash
# macOS Tahoeでのエラー
$ sketchybar --query displays
[!] Query: Invalid query, or item 'displays' not found
```

参考: https://felixkratz.github.io/SketchyBar/config/querying

### 解決策

`helpers/get_display_mapping.sh` でfallback処理を実装。

1. まず `sketchybar --query displays` を試行
2. 失敗した場合、`sketchybar --query widgets.clock` のbounding_rectsからx座標を取得
3. NSScreenのx座標とマッチングしてdisplay番号を特定

### マッピングの仕組み

```
NSSCREEN: NSScreen index → x座標
SKETCHYBAR: sketchybar display番号 → x座標
AEROSPACE: aerospace monitor番号 → NSScreen index
```

これらを組み合わせて `sketchybar display → aerospace monitor` のマッピングを構築。

### 関連ファイル

- `helpers/get_display_mapping.sh`: マッピング情報を取得するスクリプト
- `items/spaces.lua`: workspaceの表示ロジック（`build_display_mapping`関数でマッピングを構築）

### 確認済み環境

- macOS Tahoe 26.1 + sketchybar v2.21.0: `--query displays` 動作せず、fallbackで動作
- macOS Tahoe以前: `--query displays` が動作すればそれを使用、動作しなければfallback
