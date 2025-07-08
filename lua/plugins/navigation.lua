require 'plugins.custom.messages'
require 'plugins.custom.large_files'
vim.g.tmux_navigator_no_mappings = 1

return {
  {
    'stevearc/oil.nvim',
    version = '2.15.0',
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
      vim.keymap.set('n', '<leader>o-', ':Oil --float ~/renders<CR>', { desc = 'Open renders directory' })
    end,
  },

  {
    'refractalize/oil-git-status.nvim',
    dependencies = { 'stevearc/oil.nvim' },
    config = true,
  },

  {
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
      'MunifTanjim/nui.nvim',
    },
    cmd = 'Neotree',
    keys = {
      { '<space>tt', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
    },
    opts = {
      filesystem = {
        window = {
          mappings = {
            ['<space>tt'] = 'close_window',
            ['gx'] = 'system_open',
          },
        },
      },
      commands = {
        system_open = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()
          vim.fn.jobstart({ 'xdg-open', path }, { detach = true })
        end,
      },
    },
  },

  {
    'christoomey/vim-tmux-navigator',
    cmd = {
      'TmuxNavigateLeft',
      'TmuxNavigateDown',
      'TmuxNavigateUp',
      'TmuxNavigateRight',
      -- 'TmuxNavigatePrevious',
    },
    keys = {
      { '<c-h>', ':TmuxNavigateLeft<cr>' },
      { '<c-j>', ':TmuxNavigateDown<cr>' },
      { '<c-k>', ':TmuxNavigateUp<cr>' },
      { '<c-l>', ':TmuxNavigateRight<cr>' },
      -- { '<M-o>', '<cmd><C-U>TmuxNavigatePrevious<cr>' },
    },
  },
}
