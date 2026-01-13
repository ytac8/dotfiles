local colors = require("colors")
local settings = require("settings")

-- Clock item (HH:MM)
local clock = sbar.add("item", "widgets.clock", {
	position = "right",
	icon = {
		string = "󰥔",
		color = colors.catppuccin_text,
		padding_left = settings.paddings,
		padding_right = 4,
		font = {
			size = 16.0,
		},
	},
	label = {
		string = "00:00",
		color = colors.catppuccin_text,
		padding_right = settings.paddings,
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Bold"],
			size = 13.0,
		},
	},
	update_freq = 10,
	background = {
		color = colors.transparent,
		border_width = 0,
	},
})

-- Update clock
clock:subscribe("routine", function(env)
	clock:set({ label = os.date("%H:%M") })
end)

-- Spacing after clock
sbar.add("item", {
	position = "right",
	width = 8,
})
