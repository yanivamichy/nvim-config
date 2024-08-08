return {
  {
    'stevearc/oil.nvim',
    opts = {},
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('oil').setup {
        keymaps = {
          ['q'] = 'actions.close',
        },
        win_options = {
          signcolumn = 'yes:2',
        },
        columns = {
          -- 'permissions',
          -- 'size',
          -- 'mtime',
        },
        view_options = { show_hidden = true },
      }
      vim.keymap.set('n', '-', ':Oil --float<CR>', { desc = 'Open parent directory' })
      vim.keymap.set('n', '<leader>b', ':Oil --float<CR>', { desc = 'Open parent directory' })
    end,
  },

  {
    'refractalize/oil-git-status.nvim',
    dependencies = { 'stevearc/oil.nvim' },
    config = true,
  },

  --   version = '*',
  --   dependencies = {
  --     'nvim-lua/plenary.nvim',
  --     'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
  --     'MunifTanjim/nui.nvim',
  --   },
  --   cmd = 'Neotree',
  --   keys = {
  --     { '<leader>b', ':Neotree reveal<CR>', desc = 'Open File Tree' },
  --   },
  --   opts = {
  --     default_component_configs = {
  --       git_status = {
  --         symbols = false,
  --       },
  --     },
  --     filesystem = {
  --       symbols = false,
  --       filtered_items = {
  --         visible = true,
  --       },
  --       window = {
  --         mappings = {
  --           ['<leader>b'] = 'close_window',
  --         },
  --       },
  --     },
  --   },
  -- },

  {
    'AckslD/messages.nvim',
    config = function()
      require('messages').setup()
      Msg = function(...)
        require('messages.api').capture_thing(...)
      end
    end,
    keys = {
      {
        '<leader>m',
        ':Messages messages<CR>',
        desc = 'Display [M]essages in buffer',
      },
    },
  },
}
