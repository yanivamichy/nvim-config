local commands = { python = require('utils.LanguageToolFinders').get_python_env() }
local env = { PYTHONPATH = vim.fn.getcwd() }
vim.api.nvim_create_autocmd('DirChanged', {
  callback = function()
    commands.python = require('utils.LanguageToolFinders').get_python_env()
    env.PYTHONPATH = vim.fn.getcwd()
  end,
})

return {
  {
    'folke/snacks.nvim',
    opts = {
      input = {},
      picker = {},
      terminal = {
        enabled = true,
        auto_insert = false,
        start_insert = false,
        -- auto_close = false,
        win = {
          style = 'terminal',
          position = 'bottom',
          height = 0.15,
        },
      },
      -- styles = {
      -- input = { relative = 'cursor' },
      -- },
    },
    lazy = false,
    keys = {
      {
        '<C-F8>',
        function()
          local text = require('utils.misc').get_selected_text()
          local term = Snacks.terminal.get(nil, { win = { enter = false }, env = env })
          local job_id = vim.b[term.buf].terminal_job_id
          vim.api.nvim_chan_send(job_id, text .. '\r')
        end,
        mode = { 'v', 'n' },
        desc = 'Send selection to terminal',
      },
      {
        '<F32>',
        function()
          local text = require('utils.misc').get_selected_text()
          local term = Snacks.terminal.get(nil, { win = { enter = false }, env = env })
          local job_id = vim.b[term.buf].terminal_job_id
          vim.api.nvim_chan_send(job_id, text .. '\r')
        end,
        mode = { 'v', 'n' },
        desc = 'Send selection to terminal',
      },
      {
        '<C-F5>',
        function()
          local filetype = vim.bo.filetype
          local cmd = commands[filetype]
          if cmd then
            local filename = vim.fn.expand '%:.' or vim.fn.expand '%:p'
            local term = Snacks.terminal.get(nil, { win = { enter = false }, env = env })
            if not term:valid() then
              term:show()
            end
            vim.api.nvim_win_call(term.win, function()
              vim.cmd 'normal! G'
            end)
            local job_id = vim.b[term.buf].terminal_job_id
            vim.api.nvim_chan_send(job_id, cmd .. ' ' .. filename .. '\r')
          end
        end,
        mode = { 'v', 'n' },
        desc = 'Send selection to terminal',
      },
      {
        '<F29>',
        function()
          local filetype = vim.bo.filetype
          local cmd = commands[filetype]
          if cmd then
            local filename = vim.fn.expand '%:.' or vim.fn.expand '%:p'
            local term = Snacks.terminal.get(nil, { win = { enter = false }, env = env })
            if not term:valid() then
              term:show()
            end
            vim.api.nvim_win_call(term.win, function()
              vim.cmd 'normal! G'
            end)
            local job_id = vim.b[term.buf].terminal_job_id
            vim.api.nvim_chan_send(job_id, cmd .. ' ' .. filename .. '\r')
          end
        end,
        mode = { 'v', 'n' },
        desc = 'Send selection to terminal',
      },
      {
        '<C-\\>',
        function()
          local term = Snacks.terminal.get(nil, { create = false, env = env })
          if term and term.win and vim.api.nvim_win_is_valid(term.win) then
            term.opts.height = vim.api.nvim_win_get_height(term.win)
          end
          -- Snacks.terminal.toggle(nil, { win = { enter = false } })
          Snacks.terminal.toggle(nil, { win = { enter = false }, env = env })
        end,
        desc = 'Toggle Terminal',
      },
    },
  },
}
