local capabilities = require("cmp_nvim_lsp").default_capabilities()

require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})
require("mason-lspconfig").setup()
require("mason-lspconfig").setup_handlers {
  function (server_name) -- default handler (optional)
    require("lspconfig")[server_name].setup {
      on_attach = on_attach, --keyバインドなどの設定を登録
      capabilities = capabilities, --cmpを連携
    }
  end,
}

require('lspconfig').pylsp.setup{
   settings = {
       pylsp = {
           plugins = {
                 flake8 = {
                    config = {maxLineLength = 200}
                 }
            }
        }
    }
}
