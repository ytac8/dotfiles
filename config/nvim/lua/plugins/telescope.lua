return {
	{
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		opts = {
			extensions = {
				file_browser = {
					theme = "dropdown",
					hijack_netrw = true,
					files = false,
					depth = false,
					mappings = {
						["i"] = {
							["<C-h>"] = false,
							["<bs>"] = false,
						},
						["n"] = {},
					},
				},
			},
		},
		config = function()
			local status, telescope = pcall(require, "telescope")
			if not status then
				return
			end
			-- load extension
			require("telescope").load_extension("file_browser")

			-- telescope
			local telescope_builtin = require("telescope.builtin")
			vim.keymap.set("n", "<space>ff", function()
				telescope_builtin.find_files({ cwd = vim.fn.expand("%:p:h") })
			end)
			vim.keymap.set("n", "<space>fg", telescope_builtin.live_grep)
			vim.keymap.set("n", "<space>fb", telescope_builtin.buffers)
			vim.keymap.set(
				"n",
				"<space>fd",
				"<Cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>",
				{ noremap = true, silent = true }
			)
			vim.keymap.set("n", "<space>fh", telescope_builtin.help_tags)
		end,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
		},
	},
	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
	},
	{ "nvim-telescope/telescope-ui-select.nvim" },
}
