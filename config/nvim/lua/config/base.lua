vim.scriptencoding = "utf-8"
vim.wo.number = true
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- linter 表示設定
vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})

vim.diagnostic.config({
	signs = {
		-- アイコン（text）のみを設定する場合
		text = {
			[vim.diagnostic.severity.ERROR] = "", -- Error
			[vim.diagnostic.severity.WARN] = "", -- Warn
			[vim.diagnostic.severity.HINT] = "", -- Hint
			[vim.diagnostic.severity.INFO] = "", -- Info
		},
	},
})

-- colorscheme
vim.cmd([[colorscheme catppuccin]])
