local function char2hex(char)
  return string.format('%02X', string.byte(char))
end

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
        suppress_dirs = { '~/', '~/Downloads', '/' },
        create_enabled = false,
        pre_save_cmds = {
          function()
            local session_name = require('auto-session.lib').current_session_name()
            if session_name ~= '' then
              vim.cmd.wshada('~/.local/state/nvim/shada/' .. session_name:gsub('[/, .]', char2hex) .. '.shada')
            end
          end,
        },
        pre_restore_cmds = {
          save_buffers,
        },
        post_restore_cmds = {
          function()
            local shada_file = '~/.local/state/nvim/shada/' .. require('auto-session.lib').current_session_name():gsub('[/, .]', char2hex) .. '.shada'
            vim.cmd.rshada(shada_file)
          end,
        },
        session_lens = {
          load_on_setup = true,
        },
      }
    end,
  },
}
