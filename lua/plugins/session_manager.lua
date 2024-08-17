return {
  {
    'rmagatti/auto-session',
    lazy = false,
    dependencies = {
      'nvim-telescope/telescope.nvim', -- Only needed if you want to use sesssion lens
    },
    keys = {
      { '<leader>sm', '<cmd>SessionSearch<CR>', desc = '[S]earch session [M]anager' },
    },
    config = function()
      require('auto-session').setup {
        auto_session_suppress_dirs = { '~/', '~/Downloads', '/' },
        auto_session_create_enabled = false,
        session_lens = {
          load_on_setup = true,
        },
      }
    end,
  },
}
