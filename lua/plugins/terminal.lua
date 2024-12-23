local function UpdateCommands()
  local commands = {
    python = require('utils.LanguageToolFinders').get_python_env(),
  }
  return commands
end

local commands = UpdateCommands()

local function execute()
  local filetype = vim.bo.filetype
  local cmd = commands[filetype]
  if cmd then
    local filename = vim.fn.expand '%:.' or vim.fn.expand '%:p'
    vim.fn.execute(':TermExec cmd="' .. cmd .. ' ' .. filename .. '"<CR>')
  end
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
      -- vim.keymap.set('v', '<F33>', ":'<,'>:ToggleTermSendVisualSelection<CR>", { desc = 'Execute in terminal' })
      -- vim.keymap.set('v', '<C-F9>', ":'<,'>:ToggleTermSendVisualSelection<CR>", { desc = 'Execute in terminal' })
      -- vim.keymap.set('x', '<F33>', ":'<,'>:ToggleTermSendVisualLines<CR>", { desc = 'Execute in terminal' })
      -- vim.keymap.set('x', '<C-F9>', ":'<,'>:ToggleTermSendVisualLines<CR>", { desc = 'Execute in terminal' })
      -- local commands = UpdateCommands()
      vim.keymap.set('n', '<F29>', execute, { desc = 'Run file' })
      vim.keymap.set('n', '<C-F5>', execute, { desc = 'Run file' })

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
