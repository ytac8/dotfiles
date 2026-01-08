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
local all_workspaces = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11",
                        "A", "B", "C", "D", "E", "F", "G", "I", "M", "N",
                        "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}

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

local colors_spaces = {
	[1] = colors.cmap_1,
	[2] = colors.cmap_2,
	[3] = colors.cmap_3,
	[4] = colors.cmap_4,
	[5] = colors.cmap_5,
	[6] = colors.cmap_6,
	[7] = colors.cmap_7,
	[8] = colors.cmap_8,
	[9] = colors.cmap_9,
	[10] = colors.cmap_10,
}

-- spaces_indicator + front_app_icon (workspacesより前に配置)
local spaces_indicator = sbar.add("item", {
	background = {
		color = colors.with_alpha(colors.grey, 0.0),
		border_color = colors.with_alpha(colors.bg1, 0.0),
		border_width = 0,
		corner_radius = 6,
		height = 24,
		padding_left = 6,
		padding_right = 6,
	},
	icon = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Bold"],
			size = 14.0,
		},
		padding_left = 6,
		padding_right = 9,
		color = colors.accent1,
		string = icons.switch.on,
	},
	label = {
		drawing = "off",
		padding_left = 0,
		padding_right = 0,
	},
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
			background = {
				color = colors.tn_black1,
				border_color = { alpha = 1.0 },
				padding_left = 6,
				padding_right = 6,
			},
			icon = {
				color = colors.accent1,
				padding_left = 6,
				padding_right = 9,
			},
			label = { drawing = "off" },
			padding_left = 6,
			padding_right = 6,
		})
	end)
end)

spaces_indicator:subscribe("mouse.exited", function(env)
	sbar.animate("tanh", 30, function()
		spaces_indicator:set({
			background = {
				color = { alpha = 0.0 },
				border_color = { alpha = 0.0 },
			},
			icon = { color = colors.accent1 },
			label = { width = 0 },
		})
	end)
end)

spaces_indicator:subscribe("mouse.clicked", function(env)
	sbar.trigger("swap_menus_and_spaces")
end)

local front_app_icon = sbar.add("item", "front_app_icon", {
	display = "active",
	icon = { drawing = false },
	label = {
		font = "sketchybar-app-font-bg:Regular:21.0",
	},
	updates = true,
	padding_right = 0,
	padding_left = -10,
})

front_app_icon:subscribe("front_app_switched", function(env)
	sbar.exec("aerospace list-windows --focused --format '%{app-name}' 2>/dev/null | head -n 1", function(app_name)
		app_name = app_name:gsub("^%s+", ""):gsub("%s+$", "") -- trim leading/trailing whitespace only
		if app_name ~= "" then
			local lookup = app_icons[app_name]
			local icon = ((lookup == nil) and app_icons["default"] or lookup)
			front_app_icon:set({ label = { string = icon, color = colors.accent1 } })
		end
	end)
end)

sbar.add("bracket", {
	spaces_indicator.name,
	front_app_icon.name,
}, {
	background = {
		color = colors.tn_black3,
		border_color = colors.accent1,
		border_width = 2,
	},
})

sbar.add("item", { width = 6 })

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
					size = 14,
				},
				string = ws_name,
				padding_left = 5,
				padding_right = 0,
				color = colors_spaces[tonumber(ws_name)] or colors.grey,
				highlight_color = colors.tn_black3,
			},
			label = {
				padding_right = 10,
				padding_left = 3,
				color = colors_spaces[tonumber(ws_name)] or colors.grey,
				font = "sketchybar-app-font-bg:Regular:21.0",
				y_offset = -2,
			},
			padding_right = 4,
			padding_left = 4,
			background = {
				color = colors.transparent,
				height = 22,
				border_width = 0,
				border_color = colors.transparent,
			},
		})

		workspaces[display_id][ws_name] = workspace

		-- Padding
		local padding = sbar.add("item", "workspace." .. ws_name .. ".display." .. display_id .. ".padding", {
			position = "left",
			display = display_id,
			drawing = false,  -- 初期状態は非表示
			width = settings.group_paddings,
		})

		workspace_paddings[display_id][ws_name] = padding

		-- Event subscriptions (フォーカス状態はupdate_workspace_highlight関数で更新)

		workspace:subscribe("mouse.clicked", function(env)
			sbar.exec("aerospace workspace " .. ws_name)
		end)
	end
end

-- Workspace表示を動的更新する関数
local function update_workspace_visibility()
	if not mapping_ready then return end
	for display_id = 1, num_displays do
		local monitor_id = display_to_monitor[display_id]
		if not monitor_id then monitor_id = display_id end -- fallback
		sbar.exec("aerospace list-workspaces --monitor " .. monitor_id, function(output)
			-- 各ディスプレイの現在のworkspaceリストを取得
			local active_workspaces = {}
			for ws_name in string.gmatch(output, "[^\r\n]+") do
				if ws_name ~= "" then
					table.insert(active_workspaces, ws_name)
				end
			end

			-- 最大10個まで表示
			local visible_workspaces = {}
			for i = 1, math.min(10, #active_workspaces) do
				visible_workspaces[active_workspaces[i]] = true
			end

			-- すべてのworkspaceアイテムの表示状態を更新
			for ws_name, workspace_item in pairs(workspaces[display_id]) do
				local should_show = visible_workspaces[ws_name] == true
				workspace_item:set({ drawing = should_show })

				-- Paddingも更新
				local padding_item = workspace_paddings[display_id][ws_name]
				if padding_item then
					padding_item:set({ drawing = should_show })
				end
			end
		end)
	end
end

-- Workspaceハイライト更新関数（フォーカス中 + 各ディスプレイで表示中）
local function update_workspace_highlight(focused_workspace)
	if not mapping_ready then return end

	-- まず全workspaceのハイライトをリセット
	for display_id = 1, num_displays do
		for ws_name, workspace_item in pairs(workspaces[display_id]) do
			workspace_item:set({
				icon = { highlight = false },
				label = { highlight = false },
				background = {
					height = 22,
					border_color = colors.transparent,
					color = colors.transparent,
					border_width = 0,
					corner_radius = 0,
				},
			})
		end
	end

	-- 各ディスプレイの表示中workspaceを取得してハイライト
	for display_id = 1, num_displays do
		local monitor_id = display_to_monitor[display_id]
		if not monitor_id then monitor_id = display_id end

		sbar.exec("aerospace list-workspaces --monitor " .. monitor_id .. " --visible", function(visible_ws)
			visible_ws = visible_ws:gsub("%s+", "") -- trim
			if visible_ws ~= "" then
				local workspace_item = workspaces[display_id][visible_ws]
				if workspace_item then
					local is_focused = (visible_ws == focused_workspace)
					local ws_color = colors_spaces[tonumber(visible_ws)] or colors.grey

					workspace_item:set({
						icon = { highlight = is_focused },
						label = { highlight = is_focused },
						background = {
							height = 25,
							-- フォーカス中: 背景色あり、表示中のみ: 枠線のみ
							border_color = ws_color,
							border_width = 2,
							color = is_focused and ws_color or colors.transparent,
							corner_radius = 6,
						},
					})
				end
			end
		end)
	end
end

-- Window Icon更新関数（全ディスプレイ・全workspace対応）
local function update_workspace_icons()
	-- すべてのディスプレイの全workspaceのアイコンを更新
	for display_id = 1, num_displays do
		for ws_name, workspace_item in pairs(workspaces[display_id]) do
			sbar.exec("aerospace list-windows --workspace " .. ws_name .. " --format '%{app-name}' 2>/dev/null", function(apps_output)
				local icon_line = ""
				local no_app = true
				local seen_apps = {}

				-- Parse each app name from output
				for app in string.gmatch(apps_output, "[^\r\n]+") do
					if app ~= "" and not seen_apps[app] then
						no_app = false
						seen_apps[app] = true
						local lookup = app_icons[app]
						local icon = ((lookup == nil) and app_icons["default"] or lookup)
						icon_line = icon_line .. utf8.char(0x202F) .. icon
					end
				end

				if no_app then
					icon_line = "—"
				end

				sbar.animate("tanh", 10, function()
					workspace_item:set({ label = icon_line })
				end)
			end)
		end
	end
end

-- Workspace変更時に表示を更新
local workspace_observer = sbar.add("item", {
	drawing = false,
	updates = true,
})

workspace_observer:subscribe("aerospace_workspace_change", function(env)
	-- マッピングが準備できていない場合はスキップ
	if not mapping_ready then return end
	-- Workspace割り当てが変わった可能性があるため、表示を更新
	update_workspace_visibility()
	-- ハイライト更新（フォーカス中 + 表示中のworkspace）
	update_workspace_highlight(env.FOCUSED_WORKSPACE)
	-- アイコンも更新
	update_workspace_icons()
end)

-- 初回: マッピングを構築してから更新
build_display_mapping(function()
	update_workspace_visibility()
	-- 初回のハイライト更新（フォーカス中workspaceを取得）
	sbar.exec("aerospace list-workspaces --focused", function(focused)
		focused = focused:gsub("%s+", "")
		update_workspace_highlight(focused)
	end)
	update_workspace_icons()
end)

