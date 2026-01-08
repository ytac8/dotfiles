local options = {
  encoding = "utf-8",
  fileformats = "unix",
  title = true,
  backup = false,
  swapfile = false,
  writebackup = false,
  smarttab = true,
  expandtab = true,
  tabstop = 4,
  shiftwidth = 4,
  wrapscan = true,
  cursorline = true,
  virtualedit = "all",
  ignorecase = true,
  smartcase = true,
  incsearch = true,
  hlsearch = true,
  foldenable = true,
  ruler = true,
  clipboard = "unnamedplus",
  wildmenu = true,
  history = 5000,
  shiftround = true,
  infercase = true,
  hidden = true,
  showmatch = true,
  matchtime = 3,
  list = true,
  wrap = true,
  textwidth = 0,
  backspace = "indent,eol,start",
  termguicolors = true,
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

-- dont display "~" in the line number area
vim.opt.fillchars:append { eob = " " }

-- Explicitly set clipboard provider for macOS
vim.g.clipboard = {
  name = 'macOS-clipboard',
  copy = {
    ['+'] = {'bash', '-c', 'LC_ALL=ja_JP.UTF-8 pbcopy'},
    ['*'] = {'bash', '-c', 'LC_ALL=ja_JP.UTF-8 pbcopy'},
  },
  paste = {
    ['+'] = 'pbpaste',
    ['*'] = 'pbpaste',
  },
  cache_enabled = 0,
}
