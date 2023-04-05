local options = {
  encoding = "utf-8",
  fileformats = "unix",
  title = true,
  backup = false,
  swapfile = false,
  smarttab = true,
  expandtab = true,
  tabstop = 2,
  shiftwidth = 2,
  wrapscan = true,
  cursorline = true,
  virtualedit = "all",
  ignorecase = true,
  smartcase = true,
  incsearch = true,
  hlsearch = true,
  foldenable = true,
  ruler = true,
  clipboard = "unnamed",
  wildmenu = true,
  history = 5000,
  shiftround = true,
  infercase = true,
  hidden = true,
  switchbuf = "useopen",
  showmatch = true,
  matchtime = 3,
  list = true,
  wrap = true,
  textwidth = 0,
  backspace = "indent,eol,start",
  background = "dark"

}

for k, v in pairs(options) do
  vim.opt[k] = v
end
