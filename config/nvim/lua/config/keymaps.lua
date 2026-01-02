local opts = { noremap = true, silent = true }
local keymap = vim.api.nvim_set_keymap

-- keymap("", "<Space>", "<Nop>", opts)
keymap("n", "n", "nzz", opts)
keymap("n", "N", "Nzz", opts)
keymap("n", "*", "*zz", opts)
keymap("n", "#", "#zz", opts)
keymap("n", "g*", "g*zz", opts)
keymap("n", "g#", "g#zz", opts)
keymap("n", "<C-c>", "<Esc>", opts)
keymap("n", "j", "gj", opts)
keymap("n", "k", "gk", opts)
keymap("n", ",l", "$", opts)
keymap("n", ",h", "^", opts)
keymap("n", ",v", ":vsplit", opts)
keymap("n", ",s", ":split", opts)
keymap("n", "<Esc><Esc>", ":nohlsearch<CR>", opts)

keymap("v", "v", "$h", opts)
keymap("v", "<C-c>", "<Esc>", opts)

keymap("i", "<C-c>", "<Esc>", opts)
