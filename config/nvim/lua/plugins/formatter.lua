return {
	-- formatter
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					python = {
						"isort",
						"ruff_format",
					},
					markdown = { "prettier" },
					json = { "jq" },
					-- toml = { "pyproject-fmt" },
				},
				format_on_save = {
					timeout_ms = 1000,
					lsp_format = "fallback",
				},
			})
		end,
	},
}
