return {
	"akinsho/toggleterm.nvim",
	event = "VeryLazy",
	config = function()
		require("toggleterm").setup()
		local Terminal = require("toggleterm.terminal").Terminal
		local lazygit = Terminal:new({ cmd = "lazygit", direction = "float", hidden = true })
		function _lazygit_toggle()
			lazygit:toggle()
		end
		vim.api.nvim_set_keymap("n", "<space>lg", "<cmd>lua _lazygit_toggle()<CR>", { noremap = true, silent = true })
	end,
}
