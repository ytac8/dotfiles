return {
	{
		"mason-org/mason.nvim",
		version = "^1.0.0",
		lazy = true,
		cmd = {
			"Mason",
			"MasonInstall",
			"MasonUninstall",
			"MasonUninstallAll",
			"MasonLog",
			"MasonUpdate",
		},
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		event = "VeryLazy",
		opts = {
			ensure_installed = { "lua_ls", "ruff", "pyright" },
		},
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
		config = function()
			local on_attach = function(client, bufnr)
				-- 共通のキーマップなどをここに設定
			end
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local servers = {
				-- ruffをLSPとしてセットアップ (名前が `ruff` に変更)
				ruff = {
					init_options = {
						settings = {
							interpreter = { ".venv/bin/python" },
							lint = {
								ignore = {
									-- "ANN",
									-- "B018",
									-- "F821",
									"F401",
									-- "PLC0414",
									-- "RUF013",
									-- "RUF016",
								},
							},
						},
					},
				},
				pyright = {
					settings = {
						python = {
							pythonPath = "./.venv/bin/python",
							analysis = {
								-- typeCheckingMode = "basic",
							},
						},
					},
				},
				lua_ls = {},
			}

			for name, config in pairs(servers) do
				config.on_attach = on_attach
				config.capabilities = capabilities
				vim.lsp.config(name, config)
				vim.lsp.enable(name)
			end
		end,
	},

	-- 3. nvim-lspconfig (LSPのセットアップ)
	{
		"neovim/nvim-lspconfig",
		event = "FileType",
	},
}
