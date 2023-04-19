local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end
local packer_bootstrap = ensure_packer()

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

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
packer.startup(
  function(use)
    -- cmp
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-nvim-lua'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'
    use 'hrsh7th/vim-vsnip'
    use 'hrsh7th/cmp-vsnip'
    use 'onsails/lspkind.nvim'

    -- LSP
    use "williamboman/mason.nvim"
    use "williamboman/mason-lspconfig.nvim"
    use "neovim/nvim-lspconfig"

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

    -- telescope
    use ({
      'nvim-telescope/telescope.nvim', tag = '0.1.1',
      requires = {
        'nvim-lua/plenary.nvim',
        'kyazdani42/nvim-web-devicons'
      }
    })

    use {
        "nvim-telescope/telescope-file-browser.nvim",
        requires = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
    }

    -- nvim tree
    use {
      'nvim-tree/nvim-tree.lua',
      requires = {
        'nvim-tree/nvim-web-devicons',
      },
      config = function()
        require("nvim-tree").setup {}
      end
    }


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
    use 'folke/tokyonight.nvim'


    -- hop nvim (easy motion)
    use {
      'phaazon/hop.nvim',
      branch = 'v2', -- optional but strongly recommended
      config = function()
        -- you can configure Hop the way you like here; see :h hop-config
        require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
      end
    }

    -- auto comment
    use ({
        "terrortylor/nvim-comment",
        config = function()
            require("nvim_comment").setup()
        end,
    })

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

    if packer_bootstrap then
        require('packer').sync()
    end
  end
)
