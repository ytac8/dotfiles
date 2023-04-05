local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
  print("Installing packer close and reopen Neovim...")
  vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init({
  display = {
    open_fn = function()
      return require("packer.util").float({ border = "rounded" })
    end,
  },
})

-- Install plugins here
return packer.startup(
  function(use)
    -- cmp
    use ({
        'hrsh7th/nvim-cmp',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-nvim-lua',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
        'hrsh7th/vim-vsnip',
        'hrsh7th/cmp-vsnip',
        'onsails/lspkind.nvim',
    })

    -- LSP
    use (
        {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "neovim/nvim-lspconfig",
        }
    )

    -- formatter
    use({
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
            require("null-ls").setup()
        end,
        requires = { "nvim-lua/plenary.nvim" },
    })

    -- treesitter
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
    }

    use({ "windwp/nvim-autopairs" }) -- Autopairs, integrates with both cmp and treesitter

    -- telescope
    use ({
      'nvim-telescope/telescope.nvim', tag = '0.1.1',
      requires = {
        'nvim-lua/plenary.nvim',
        'kyazdani42/nvim-web-devicons'
      }
    })
    use ({
        "nvim-telescope/telescope-file-browser.nvim",
        requires = { 
          'nvim-telescope/telescope.nvim',
          'nvim-lua/plenary.nvim',
          'kyazdani42/nvim-web-devicons'
        }
    })

    -- git
    use ({
      'lewis6991/gitsigns.nvim',
      config = function()
        require('gitsigns').setup()
      end
    })

    -- terminal
    use ({"akinsho/toggleterm.nvim", tag = '*', config = function()
      require("toggleterm").setup()
      end
    })

    -- Colorschemes
    use ({ "catppuccin/nvim", as = "catppuccin" })

    -- hop nvim (easy motion)
    use {
      'phaazon/hop.nvim',
      branch = 'v2', -- optional but strongly recommended
      config = function()
        -- you can configure Hop the way you like here; see :h hop-config
        require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
      end
    }

    -- UI
    use({
      "glepnir/lspsaga.nvim",
      opt = true,
      branch = "main",
      event = "LspAttach",
      config = function()
          require("lspsaga").setup({})
      end,
      requires = {
          {'kyazdani42/nvim-web-devicons', opt = true },
          {"nvim-treesitter/nvim-treesitter"}
        }
    })
    -- status line
    use ({
      'nvim-lualine/lualine.nvim',
      requires = {'kyazdani42/nvim-web-devicons', opt = true }
    })


    use({ "akinsho/bufferline.nvim" })

  end
)
