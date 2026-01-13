local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.icon_map")

-- 実装メモ:
-- ネイティブ'space'タイプではなくカスタム'item'タイプを使用しています。理由:
-- 1. aerospaceのworkspaceはmacOSのSpaceとは独立している
-- 2. マルチディスプレイ環境では各ディスプレイで異なるmacOS Spaceインデックスを持つ
-- 3. カスタムアイテムを使うことでaerospace workspace名への直接マッピングが可能
--
-- 動的検出方式:
-- - 全workspace（1-10, A-Z）を各ディスプレイ用に事前作成（初期状態は非表示）
-- - aerospace list-workspaces --monitor Nで現在の割り当てを検出
-- - 検出結果に基づいてdrawingプロパティを切り替え
-- - 各ディスプレイ最大10個まで表示
--
-- 動的マッピング:
-- - 起動時にaerospaceとmacOSのディスプレイ情報をクエリして自動的にマッピングを構築
-- - ディスプレイ名でマッチング（同名ディスプレイはdisplayIDの順序で対応）
-- - ディスプレイの接続順序が変わっても自動的に対応

-- すべての可能なworkspace名
local all_workspaces = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}

-- ディスプレイ数（最大3を想定）
local num_displays = 3

-- sketchybar display番号 → aerospace monitor番号のマッピング（起動時に動的構築）
local display_to_monitor = {}
local mapping_ready = false

-- 動的マッピング構築関数
local function build_display_mapping(callback)
	-- sketchybarはdisplayIDの昇順でディスプレイを番号付け
	-- aerospaceは独自の順序でmonitorを番号付け
	-- 同名ディスプレイはdisplayID順 = aerospaceの(1)(2)サフィックス順で対応

	-- Step 1: macOS displays を取得（displayID順にソート）
	local get_displays_script = [[python3 -c "
import json,sys,subprocess
result = subprocess.run(['system_profiler', 'SPDisplaysDataType', '-json'], capture_output=True, text=True)
d = json.loads(result.stdout)
displays = []
for disp in d.get('SPDisplaysDataType', []):
    for s in disp.get('spdisplays_ndrvs', []):
        displays.append((int(s.get('_spdisplays_displayID', '0')), s.get('_name', '')))
# Sort by displayID (sketchybar uses this order)
displays.sort(key=lambda x: x[0])
for did, name in displays:
    print(name)
" 2>/dev/null]]

	sbar.exec(get_displays_script, function(macos_output)
		-- Parse macOS displays in displayID order (= sketchybar display order)
		local sketchybar_displays = {} -- index -> name
		local sketchybar_by_name = {} -- name -> list of display indices
		local idx = 1

		for name in macos_output:gmatch("[^\r\n]+") do
			if name ~= "" then
				sketchybar_displays[idx] = name
				if not sketchybar_by_name[name] then
					sketchybar_by_name[name] = {}
				end
				table.insert(sketchybar_by_name[name], idx)
				idx = idx + 1
			end
		end

		-- Step 2: aerospace monitors を取得
		sbar.exec("aerospace list-monitors 2>/dev/null", function(aerospace_output)
			-- Parse aerospace monitors
			local aerospace_monitors = {} -- monitor_id -> name
			local aerospace_by_basename = {} -- basename -> list of {id, suffix}

			for line in aerospace_output:gmatch("[^\r\n]+") do
				local monitor_id, name = line:match("(%d+)%s*|%s*(.+)")
				if monitor_id and name then
					monitor_id = tonumber(monitor_id)
					aerospace_monitors[monitor_id] = name

					-- Extract basename (remove " (N)" suffix)
					local basename = name:match("^(.-)%s*%(%d+%)$") or name
					local suffix = tonumber(name:match("%((%d+)%)$")) or 0

					if not aerospace_by_basename[basename] then
						aerospace_by_basename[basename] = {}
					end
					table.insert(aerospace_by_basename[basename], {id = monitor_id, suffix = suffix})
				end
			end

			-- Sort aerospace monitors by suffix for each basename
			for _, group in pairs(aerospace_by_basename) do
				table.sort(group, function(a, b) return a.suffix < b.suffix end)
			end

			-- Step 3: Build mapping by matching names
			for display_idx, display_name in pairs(sketchybar_displays) do
				local matches = aerospace_by_basename[display_name]
				if matches then
					if #matches == 1 then
						-- Unique name: direct match
						display_to_monitor[display_idx] = matches[1].id
					else
						-- Multiple monitors with same name
						-- Find this display's position among same-name displays
						local same_name_displays = sketchybar_by_name[display_name]
						for pos, d_idx in ipairs(same_name_displays) do
							if d_idx == display_idx and matches[pos] then
								display_to_monitor[display_idx] = matches[pos].id
								break
							end
						end
					end
				end
			end

			-- Fallback: fill any missing mappings with 1:1
			for i = 1, num_displays do
				if not display_to_monitor[i] then
					display_to_monitor[i] = i
				end
			end

			mapping_ready = true
			if callback then callback() end
		end)
	end)
end

-- workspace管理テーブル: workspaces[display_id][workspace_name] = workspace_item
local workspaces = {}

-- padding管理テーブル: workspace_paddings[display_id][workspace_name] = padding_item
local workspace_paddings = {}

-- 統一されたworkspace色
local workspace_color = colors.catppuccin_lavender

-- spaces_indicator + front_app_icon (workspacesより前に配置)
local spaces_indicator = sbar.add("item", {
	background = {
		color = colors.transparent,
		border_width = 0,
	},
	icon = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Regular"],
			size = 16.0,
		},
		padding_left = settings.paddings,
		padding_right = settings.paddings,
		color = colors.catppuccin_text,
		string = icons.switch.on,
	},
	label = {
		drawing = "off",
	},
	padding_left = settings.paddings,
	padding_right = settings.paddings,
})

spaces_indicator:subscribe("swap_menus_and_spaces", function(env)
	local currently_on = spaces_indicator:query().icon.value == icons.switch.on
	spaces_indicator:set({
		icon = currently_on and icons.switch.off or icons.switch.on,
	})
end)

spaces_indicator:subscribe("mouse.entered", function(env)
	sbar.animate("tanh", 30, function()
		spaces_indicator:set({
			icon = {
				color = colors.catppuccin_lavender,
			},
		})
	end)
end)

spaces_indicator:subscribe("mouse.exited", function(env)
	sbar.animate("tanh", 30, function()
		spaces_indicator:set({
			icon = { color = colors.catppuccin_text },
		})
	end)
end)

spaces_indicator:subscribe("mouse.clicked", function(env)
	sbar.trigger("swap_menus_and_spaces")
end)

-- bracket removed as the indicator now has its own background

sbar.add("item", { width = 18 })

-- すべてのworkspaceアイテムを事前作成（初期状態は非表示）
for display_id = 1, num_displays do
	workspaces[display_id] = {}
	workspace_paddings[display_id] = {}

	for _, ws_name in ipairs(all_workspaces) do
		local workspace = sbar.add("item", "workspace." .. ws_name .. ".display." .. display_id, {
			position = "left",
			display = display_id,
			drawing = false,  -- 初期状態は非表示
			icon = {
				font = {
					family = settings.font.numbers,
					style = settings.font.style_map["Bold"],
					size = 16.0,
				},
				string = ws_name,
				padding_left = settings.paddings,
				padding_right = 2,
				color = workspace_color,
				highlight_color = colors.catppuccin_base,
			},
			label = {
				padding_right = settings.paddings,
				padding_left = settings.paddings,
				color = workspace_color,
				font = "sketchybar-app-font-bg:Regular:19.0",
				y_offset = -2,
			},
			padding_right = settings.paddings,
			padding_left = settings.paddings,
			background = {
				color = colors.transparent,
				border_width = 0,
			},
		})

		workspaces[display_id][ws_name] = workspace

		-- Padding
		local padding = sbar.add("item", "workspace." .. ws_name .. ".display." .. display_id .. ".padding", {
			position = "left",
			display = display_id,
			drawing = false,  -- 初期状態は非表示
			width = 4,
		})

		workspace_paddings[display_id][ws_name] = padding

		-- Event subscriptions (フォーカス状態はupdate_workspace_highlight関数で更新)

		workspace:subscribe("mouse.clicked", function(env)
			sbar.exec("aerospace workspace " .. ws_name)
		end)
	end
end

-- 統合更新関数: 1回のbash実行で全情報を取得し、visibility + highlight + iconsを更新
local function update_all_workspaces()
	if not mapping_ready then return end

	-- 全情報を1回のbashスクリプトで取得（割り当て済みworkspaceのみアプリ情報取得）
	local cmd = [[
echo "FOCUSED:$(aerospace list-workspaces --focused 2>/dev/null | tr -d '\n')"
assigned_ws=""
for m in 1 2 3; do
  echo "VISIBLE:$m:$(aerospace list-workspaces --monitor $m --visible 2>/dev/null | tr -d '\n')"
  for ws in $(aerospace list-workspaces --monitor $m 2>/dev/null); do
    [ -n "$ws" ] && echo "ASSIGNED:$m:$ws" && assigned_ws="$assigned_ws $ws"
  done
done
for ws in $assigned_ws; do
  apps=$(aerospace list-windows --workspace "$ws" --format '%{app-name}' 2>/dev/null | tr '\n' '|')
  [ -n "$apps" ] && echo "APPS:$ws:$apps"
done
]]
	sbar.exec(cmd, function(output)
		local focused_workspace = ""
		local monitor_visible = {}    -- monitor_id -> visible_workspace
		local monitor_assigned = {}   -- monitor_id -> {workspace_name -> true}
		local workspace_apps = {}     -- workspace_name -> "app1|app2|..."

		-- パース
		for line in output:gmatch("[^\r\n]+") do
			local f = line:match("^FOCUSED:(.*)$")
			if f then focused_workspace = f end

			local m, v = line:match("^VISIBLE:(%d+):(.*)$")
			if m and v then monitor_visible[tonumber(m)] = v end

			local m2, ws = line:match("^ASSIGNED:(%d+):(.+)$")
			if m2 and ws then
				local mid = tonumber(m2)
				if not monitor_assigned[mid] then monitor_assigned[mid] = {} end
				monitor_assigned[mid][ws] = true
			end

			local ws2, apps = line:match("^APPS:(.+):(.+)$")
			if ws2 and apps then workspace_apps[ws2] = apps end
		end

		-- 各ディスプレイを更新
		for display_id = 1, num_displays do
			local monitor_id = display_to_monitor[display_id]
			if not monitor_id then monitor_id = display_id end

			local assigned = monitor_assigned[monitor_id] or {}
			local visible_ws = monitor_visible[monitor_id] or ""

			-- 全workspaceを更新（assignedならdrawing=true）
			for ws_name, workspace_item in pairs(workspaces[display_id]) do
				local should_show = assigned[ws_name] == true

				-- ハイライト計算
				local is_visible = (ws_name == visible_ws)
				local is_focused = is_visible and (ws_name == focused_workspace)

				-- アイコン計算
				local apps_str = workspace_apps[ws_name] or ""
				local icon_line = ""
				local seen_apps = {}
				for app in apps_str:gmatch("[^|]+") do
					if app ~= "" and not seen_apps[app] then
						seen_apps[app] = true
						local lookup = app_icons[app]
						local icon = lookup or app_icons["default"]
						icon_line = icon_line .. utf8.char(0x202F) .. icon
					end
				end
				if icon_line == "" then icon_line = "—" end

				-- 背景設定（明示的にすべてのプロパティを設定）
				local bg_config = {}
				if is_visible then
					-- visible（表示中）: 下にバーを表示
					bg_config = {
						color = workspace_color,
						height = 2,
						y_offset = -16,
					}
				else
					-- 非表示: 透明
					bg_config = {
						color = colors.transparent,
						height = 32,
						y_offset = 0,
					}
				end

				-- 一括設定
				workspace_item:set({
					drawing = should_show,
					icon = {
						color = workspace_color,
					},
					label = {
						string = icon_line,
						color = workspace_color,
					},
					background = bg_config,
				})

				-- Padding更新
				local padding_item = workspace_paddings[display_id][ws_name]
				if padding_item then
					padding_item:set({ drawing = should_show })
				end
			end
		end
	end)
end

-- 互換性のための関数（統合関数を呼ぶだけ）
local function update_workspace_visibility()
	update_all_workspaces()
end

local function update_workspace_highlight(focused_workspace_hint)
	update_all_workspaces()
end

-- Window Icon更新関数（互換性のため残す、統合関数を呼ぶだけ）
local function update_workspace_icons()
	-- update_all_workspaces()に統合済み、何もしない
end

-- Workspace変更時に表示を更新
local workspace_observer = sbar.add("item", {
	drawing = false,
	updates = true,
})

-- aerospace_workspace_change: workspace切り替え・移動時
workspace_observer:subscribe("aerospace_workspace_change", function(env)
	if not mapping_ready then return end
	update_all_workspaces()
end)

-- front_app_switched: フォーカス移動時
workspace_observer:subscribe("front_app_switched", function(env)
	if not mapping_ready then return end
	update_all_workspaces()
end)

-- system_woke: スリープ復帰時（マッピング再構築）
workspace_observer:subscribe("system_woke", function(env)
	build_display_mapping(function()
		update_all_workspaces()
	end)
end)

-- display_change: ディスプレイ接続/切断時（マッピング再構築）
workspace_observer:subscribe("display_change", function(env)
	build_display_mapping(function()
		update_all_workspaces()
	end)
end)

-- 初回: マッピングを構築してから更新
build_display_mapping(function()
	update_all_workspaces()
end)

