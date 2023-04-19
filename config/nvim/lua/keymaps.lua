local opts = { noremap = true, silent = true }
local term_opts = { silent = true }
local keymap = vim.api.nvim_set_keymap

keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

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

-- telescope
local telescope = require('telescope')
local telescope_builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', function() telescope_builtin.find_files({cwd=vim.fn.expand('%:p:h')}) end, opts)
vim.keymap.set('n', '<leader>fg', telescope_builtin.live_grep, opts)
vim.keymap.set('n', '<leader>fb', telescope_builtin.buffers, opts)
vim.keymap.set("n", "<leader>fd", '<Cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fh', telescope_builtin.help_tags, opts)

-- nvim tree
vim.keymap.set('n', '<leader>tt', ":NvimTreeToggle<CR>", opts)
vim.keymap.set('n', '<leader>tt', ":NvimTreeToggle<CR>", opts)
vim.keymap.set('n', '<leader>tf', ":NvimTreeFocus<CR>", opts)
 
--hop
local hop = require('hop')
vim.keymap.set("n", 'f', function()
  hop.hint_char1({current_line_only = true})
end, {remap=true})
vim.keymap.set("v", 'f', function()
  hop.hint_char1({current_line_only = true})
end, {remap=true})
vim.keymap.set("n", "F", "<Cmd>HopPattern<CR>")
vim.keymap.set("n", "s", "<Cmd>HopWord<CR>")
vim.keymap.set("v", "s", "<Cmd>HopWord<CR>")

-- lspsaga
local keymap = vim.keymap.set
keymap("n", "gh", "<cmd>Lspsaga lsp_finder<CR>")
keymap({"n","v"}, "<leader>ca", "<cmd>Lspsaga code_action<CR>")
keymap("n", "gr", "<cmd>Lspsaga rename<CR>")
keymap("n", "gd", "<cmd>Lspsaga peek_definition<CR>")
keymap("n", "gt", "<cmd>Lspsaga peek_type_definition<CR>")
keymap("n", "<leader>sl", "<cmd>Lspsaga show_line_diagnostics<CR>")
keymap("n", "<leader>sb", "<cmd>Lspsaga show_buf_diagnostics<CR>")
keymap("n", "<leader>sw", "<cmd>Lspsaga show_workspace_diagnostics<CR>")
keymap("n", "<leader>sc", "<cmd>Lspsaga show_cursor_diagnostics<CR>")
keymap("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>")
keymap("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>")
-- Diagnostic jump with filters such as only jumping to an error
keymap("n", "[E", function()
  require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
end)
keymap("n", "]E", function()
  require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
end)
keymap("n","<leader>o", "<cmd>Lspsaga outline<CR>")
keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>")
keymap("n", "<Leader>ci", "<cmd>Lspsaga incoming_calls<CR>")
keymap("n", "<Leader>co", "<cmd>Lspsaga outgoing_calls<CR>")
keymap({"n", "t"}, "<A-d>", "<cmd>Lspsaga term_toggle<CR>")
