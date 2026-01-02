---@diagnostic disable: undefined-global
return {
	{
		"glepnir/lspsaga.nvim",
		branch = "main",
		event = "LspAttach",
		config = function()
			require("lspsaga").setup({
				ui = {
					code_action = "",
				},
			})
			-- keymap
			vim.keymap.set("n", "gh", "<cmd>Lspsaga lsp_finder<CR>")
			vim.keymap.set({ "n", "v" }, "<leader>ca", "<cmd>Lspsaga code_action<CR>")
			vim.keymap.set("n", "gr", "<cmd>Lspsaga rename<CR>")
			vim.keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>")
			vim.keymap.set("n", "<leader>sl", "<cmd>Lspsaga show_line_diagnostics<CR>")
			vim.keymap.set("n", "<leader>sb", "<cmd>Lspsaga show_buf_diagnostics<CR>")
			vim.keymap.set("n", "<leader>sw", "<cmd>Lspsaga show_workspace_diagnostics<CR>")
			vim.keymap.set("n", "<leader>sc", "<cmd>Lspsaga show_cursor_diagnostics<CR>")
			vim.keymap.set("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>")
			vim.keymap.set("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>")
			-- Diagnostic jump with filters such as only jumping to an error
			vim.keymap.set("n", "[E", function()
				require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
			end)
			vim.keymap.set("n", "]E", function()
				require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
			end)
			vim.keymap.set("n", "<leader>o", "<cmd>Lspsaga outline<CR>")
			vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>")
			vim.keymap.set("n", "<leader>ci", "<cmd>Lspsaga incoming_calls<CR>")
			vim.keymap.set("n", "<leader>co", "<cmd>Lspsaga outgoing_calls<CR>")
			vim.keymap.set({ "n", "t" }, "<A-d>", "<cmd>Lspsaga term_toggle<CR>")
		end,
		dependencies = {
			{ "nvim-tree/nvim-web-devicons", opt = true },
			{ "nvim-treesitter/nvim-treesitter" },
		},
	},

	-- status line
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons", opt = true },
		event = "VeryLazy",
		config = function()
			local status, lualine = pcall(require, "lualine")
			if not status then
				return
			end
			require("lualine").setup({
				options = {
					section_separators = { left = "", right = "" },
					component_separators = { left = "", right = "" },
					icons_enabled = true,
					theme = "catppuccin",
					disabled_filetypes = {
						statusline = {},
						winbar = {},
					},
					ignore_focus = {},
					always_divide_middle = true,
					globalstatus = false,
					refresh = {
						statusline = 1000,
						tabline = 1000,
						winbar = 1000,
					},
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { "filename" },
					lualine_x = { "encoding", "fileformat", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { "filename" },
					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},
				tabline = {},
				winbar = {},
				inactive_winbar = {},
				extensions = {},
			})
		end,
	},
	-- nvim tree
	{
		"nvim-tree/nvim-tree.lua",
		event = "VimEnter",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("nvim-tree").setup({})
			-- nvim tree
			vim.keymap.set("n", "<leader>tt", ":NvimTreeToggle<CR>")
			vim.keymap.set("n", "<leader>tt", ":NvimTreeToggle<CR>")
			vim.keymap.set("n", "<leader>tf", ":NvimTreeFocus<CR>")
		end,
	},
	-- git
	{
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		config = function()
			require("gitsigns").setup()
		end,
	},
	-- colorscheme
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				transparent_background = true,
				flavour = "mocha",
			})
		end,
	},
}
