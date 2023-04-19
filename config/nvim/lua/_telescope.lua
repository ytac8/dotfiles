local status, telescope = pcall(require, "telescope")
if not status then
    return
end
require("telescope").setup {
  extensions = {
    file_browser = {
      theme = "dropdown",
      hijack_netrw = true,
      files = false,
      depth = false,
      mappings = {
        ["i"] = {
          ["<C-h>"] = false,
          ["<bs>"] = false
        },
        ["n"] = {},
      },
    },
  },
}

-- load extension
require("telescope").load_extension("file_browser")
