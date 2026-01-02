return {
	-- hop nvim
	{
		"phaazon/hop.nvim",
		event = "BufRead",
		branch = "v2", -- optional but strongly recommended
		config = function()
			local hop = require("hop")
			-- you can configure Hop the way you like here; see :h hop-config
			hop.setup({ keys = "etovxqpdygfblzhckisuran" })
			-- keymap
			vim.keymap.set("n", "f", function()
				hop.hint_char1({ current_line_only = true })
			end, { remap = true })
			vim.keymap.set("v", "f", function()
				hop.hint_char1({ current_line_only = true })
			end, { remap = true })
			vim.keymap.set("n", "F", "<Cmd>HopPattern<CR>")
			vim.keymap.set("n", "s", "<Cmd>HopWord<CR>")
			vim.keymap.set("v", "s", "<Cmd>HopWord<CR>")
		end,
	},
	-- auto comment
	{
		"terrortylor/nvim-comment",
		lazy = true,
		config = function()
			require("nvim_comment").setup()
		end,
	},
}
