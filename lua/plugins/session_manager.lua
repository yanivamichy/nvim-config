return {
  {
    'rmagatti/auto-session',
    lazy = false,
    dependencies = {
      'nvim-telescope/telescope.nvim',
    },
    keys = {
      { '<leader>sm', '<cmd>SessionSearch<CR>', desc = '[S]earch session [M]anager' },
    },
    config = function()
      local function save_buffers()
        vim.cmd 'wa'
      end
      require('auto-session').setup {
        auto_session_suppress_dirs = { '~/', '~/Downloads', '/' },
        auto_session_create_enabled = false,
        pre_restore_cmds = { save_buffers },
        session_lens = {
          load_on_setup = true,
        },
      }
    end,
  },
}
