require 'plugins.custom.messages'
return {
  {
    'stevearc/oil.nvim',
    opts = {},
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('oil').setup {
        keymaps = {
          ['q'] = 'actions.close',
          ['<BS>'] = 'actions.parent',
        },
        win_options = {
          signcolumn = 'yes:2',
        },
        columns = {
          -- 'permissions',
          -- 'size',
          -- 'mtime',
        },
        lsp_file_methods = {
          timeout_ms = 10000,
        },
        view_options = { show_hidden = true },
      }
      vim.keymap.set('n', '-', ':Oil --float<CR>', { desc = 'Open parent directory' })
    end,
  },

  {
    'refractalize/oil-git-status.nvim',
    dependencies = { 'stevearc/oil.nvim' },
    config = true,
  },

  -- {
  --   'chrishrb/gx.nvim',
  --   keys = { { 'gx', '<cmd>Browse<cr>', mode = { 'n', 'x' } } },
  --   cmd = { 'Browse' },
  --   init = function()
  --     vim.g.netrw_nogx = 1 -- disable netrw gx
  --   end,
  --   dependencies = { 'nvim-lua/plenary.nvim' }, -- Required for Neovim < 0.10.0
  --   config = true, -- default settings
  --   submodules = false, -- not needed, submodules are required only for tests
  -- },
}
