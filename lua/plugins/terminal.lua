local function UpdateCommands()
  local commands = {
    python = require('utils.LanguageToolFinders').get_python_env(),
  }
  return commands
end

return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
      require('toggleterm').setup {
        start_in_insert = false,
        -- shell = 'tmux',
        winbar = {
          enabled = true,
        },
      }
      vim.keymap.set('n', '<C-\\>', ':ToggleTerm<CR>', { desc = '[T]oggle [T]erminal' })
      vim.keymap.set('v', '<F34>', ":'<,'>:ToggleTermSendVisualSelection<CR>", { desc = 'Execute in terminal' })
      vim.keymap.set('x', '<F34>', ":'<,'>:ToggleTermSendVisualLines<CR>", { desc = 'Execute in terminal' })
      local commands = UpdateCommands()
      vim.keymap.set('n', '<F29>', function()
        local filetype = vim.bo.filetype
        local cmd = commands[filetype]
        if cmd then
          local filename = vim.fn.expand '%:.' or vim.fn.expand '%:p'
          vim.fn.execute(':TermExec cmd="' .. cmd .. ' ' .. filename .. '"<CR>')
        end
      end, { desc = 'Run file' })

      vim.api.nvim_create_autocmd('DirChanged', {
        callback = function()
          commands = UpdateCommands()
        end,
      })
    end,
  },

  -- {
  --   'ryanmsnyder/toggleterm-manager.nvim',
  --   dependencies = {
  --     'akinsho/toggleterm.nvim',
  --     'nvim-telescope/telescope.nvim',
  --   },
  --   config = true,
  -- },
}
