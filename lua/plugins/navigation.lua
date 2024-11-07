require 'plugins.custom.messages'
vim.g.tmux_navigator_no_mappings = 1
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

          -- -- Windows: Without removing the file from the path, it opens in code.exe instead of explorer.exe
          -- local p
          -- local lastSlashIndex = path:match '^.+()\\[^\\]*$' -- Match the last slash and everything before it
          -- if lastSlashIndex then
          --   p = path:sub(1, lastSlashIndex - 1) -- Extract substring before the last slash
          -- else
          --   p = path -- If no slash found, return original path
          -- end
          -- vim.cmd('silent !start explorer ' .. p)
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
