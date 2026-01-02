return {
	{ "hrsh7th/nvim-cmp" },
	{
		"hrsh7th/nvim-cmp",
		-- load cmp on InsertEnter
		lazy = true,
		event = "InsertEnter",
		-- these dependencies will only be loaded when cmp loads
		-- dependencies are always lazy-loaded unless specified otherwise
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
		},
		config = function()
			local cmp = require("cmp")
			local lspkind = require("lspkind")

			cmp.setup({
				snippet = {
					expand = function(args)
						vim.fn["vsnip#anonymous"](args.body)
					end,
				},
				sources = {
					{ name = "nvim_lsp" },
					{ name = "vsnip" },
					{ name = "buffer" },
					{ name = "path" },
				},
				mapping = cmp.mapping.preset.insert({
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						else
							fallback()
						end
					end,
					["<S-Tab>"] = function(fallback)
						if cmp.visivle() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end,
				}),
				experimental = {
					ghost_text = false,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol_text", -- show only symbol annotations
						preset = "codicons",
						symbol_map = {
							"  Text", -- = 1
							"  Function", -- = 2;
							"  Method", -- = 3;
							"  Constructor", -- = 4;
							"  Field", -- = 5;
							"  Variable", -- = 6;
							"  Class", -- = 7;
							"  Interface", -- = 8;
							"  Module", -- = 9;
							"  Property", -- = 10;
							"  Unit", -- = 11;
							"  Value", -- = 12;
							"  Enum", -- = 13;
							"  Keyword", -- = 14;
							"  Snippet", -- = 15;
							"  Color", -- = 16;
							"  File", -- = 17;
							"  Reference", -- = 18;
							"  Folder", -- = 19;
							"  EnumMember", -- = 20;
							"  Constant", -- = 21;
							"  Struct", -- = 22;
							"  Event", -- = 23;
							"  Operator", -- = 24;
							"  TypeParameter", -- = 25;
						},
					}),
				},
			})

			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "path" },
				},
			})
		end,
	},
	{ "hrsh7th/cmp-nvim-lua" },
	{ "hrsh7th/cmp-path" },
	{ "hrsh7th/cmp-cmdline" },
	{ "hrsh7th/vim-vsnip" },
	{ "hrsh7th/cmp-vsnip" },
	{ "onsails/lspkind.nvim" },
}
