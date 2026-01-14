local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.icon_map")

-- Padding item required because of bracket
-- sbar.add("item", { width = 8 })

local reddit = sbar.add("item", {
	background = {
		color = colors.transparent,
		border_width = 0,
	},
	icon = {
		drawing = "off",
	},
	label = {
		string = "\u{f281}",
		font = {
			family = "JetBrainsMono Nerd Font",
			style = "Regular",
			size = 20.0,
		},
		padding_left = settings.paddings + 4,
		padding_right = settings.paddings,
		color = colors.catppuccin_text,
	},
	click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 0",
	padding_left = settings.paddings,
	padding_right = settings.paddings,
})

-- Padding item required because of bracket
sbar.add("item", { width = 6 })
