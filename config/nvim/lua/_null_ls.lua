local null_ls = require("null-ls")
local sources = {
    null_ls.builtins.formatting.autopep8.with({
        filetypes = { "python" },
        extra_args = { "--line-length", "160" },
    }),
    null_ls.builtins.formatting.isort.with({
        filetypes = { "python" },
        extra_args = { "--line-length", "160" },
    }),
    null_ls.builtins.formatting.sqlfluff.with({
        extra_args = { "--dialect", "BigQuery" },
    }),
    null_ls.builtins.formatting.prettierd.with({
        filetypes = { "json" },
    })
}

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.format({ bufnr = bufnr })
                -- vim.lsp.buf.formatting_sync()
            end,
        })
    end
end


null_ls.setup({
    sources = sources,
    debug = true,
    on_attach = on_attach
})
