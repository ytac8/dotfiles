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
-- workspace 1-10をサポート。A-Zに拡張するには:
-- 1. ループを変更して希望のworkspace名で反復
-- 2. 文字workspaceの色マッピングを更新
-- 3. aerospace.tomlのpersistent-workspacesにそれらのworkspaceが含まれていることを確認

local workspaces = {}

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

for i = 1, 10, 1 do
	local workspace = sbar.add("item", "workspace." .. i, {
		position = "left",
		icon = {
			font = {
				family = settings.font.numbers,
				size = 14,
			},
			string = i,
			padding_left = 5,
			padding_right = 0,
			color = colors_spaces[i],
			highlight_color = colors.tn_black3,
		},
		label = {
			padding_right = 10,
			padding_left = 3,
			color = colors_spaces[i],
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

	workspaces[i] = workspace

	-- Padding between workspace items
	sbar.add("item", "workspace.padding." .. i, {
		position = "left",
		width = settings.group_paddings,
	})

	workspace:subscribe("aerospace_workspace_change", function(env)
		local focused_workspace = env.FOCUSED_WORKSPACE
		local selected = focused_workspace == tostring(i)
		workspace:set({
			icon = { highlight = selected },
			label = { highlight = selected },
			background = {
				height = 25,
				border_color = selected and colors_spaces[i] or colors.transparent,
				color = selected and colors_spaces[i] or colors.transparent,
				corner_radius = selected and 6 or 0,
			},
		})
	end)

	workspace:subscribe("mouse.clicked", function(env)
		-- Left click: focus workspace
		sbar.exec("aerospace workspace " .. i)
	end)
end

sbar.add("bracket", {
	workspaces[1].name,
	workspaces[2].name,
	workspaces[3].name,
	workspaces[4].name,
	workspaces[5].name,
	workspaces[6].name,
	workspaces[7].name,
	workspaces[8].name,
	workspaces[9].name,
	workspaces[10].name,
}, {
	background = {
		color = colors.background,
		border_color = colors.accent3,
		border_width = 2,
	},
})

local space_window_observer = sbar.add("item", {
	drawing = false,
	updates = true,
})

sbar.add("item", { width = 6 })

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

-- Update workspace window icons
local function update_workspace_icons()
	for i = 1, 10, 1 do
		sbar.exec("aerospace list-windows --workspace " .. i .. " --format '%{app-name}' 2>/dev/null", function(apps_output)
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
				workspaces[i]:set({ label = icon_line })
			end)
		end)
	end
end

-- Update icons on workspace change
space_window_observer:subscribe("aerospace_workspace_change", function(env)
	update_workspace_icons()
end)

-- Initial update
update_workspace_icons()

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
				-- color = { alpha = 1.0 },
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

-- disable front_app
-- local front_app = sbar.add("item", "front_app", {
-- 	display = "active",
-- 	icon = { drawing = false },
-- 	label = {
-- 		font = {
-- 			style = settings.font.style_map["Black"],
-- 			size = 12.0,
-- 		},
-- 	},
-- 	updates = true,
-- 	padding_right = 8,
-- 	padding_left = -6,
-- })

front_app_icon:subscribe("front_app_switched", function(env)
	sbar.exec("aerospace list-windows --focused --format '%{app-name}' 2>/dev/null | head -n 1", function(app_name)
		app_name = app_name:gsub("%s+", "") -- trim whitespace
		if app_name ~= "" then
			local lookup = app_icons[app_name]
			local icon = ((lookup == nil) and app_icons["default"] or lookup)
			front_app_icon:set({ label = { string = icon, color = colors.accent1 } })
		end
	end)
end)

-- front_app:subscribe("mouse.clicked", function(env)
-- 	sbar.trigger("swap_menus_and_spaces")
-- end)

sbar.add("bracket", {
	spaces_indicator.name,
	front_app_icon.name,
	-- front_app.name,
}, {
	background = {
		color = colors.tn_black3,
		border_color = colors.accent1,
		border_width = 2,
	},
})
