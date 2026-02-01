return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	lazy = false,
	main = "nvim-treesitter",
	opts = {
		ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "bash", "python", "typescript", "go" },
	},
}
