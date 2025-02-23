local function find_index(array, target)
  for index, value in ipairs(array) do
    if value == target then
      return index
    end
  end
  return nil
end

return {
  { -- Linting
    'mfussenegger/nvim-lint',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'rshkarin/mason-nvim-lint',
    },
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
        python = { 'mypy' },
      }
      local mypy = lint.linters.mypy
      local args = mypy.args
      local index = find_index(args, '--python-executable')
      args[index + 1] = require('utils.LanguageToolFinders').get_python_env
      local max_index = #args
      args[max_index + 1] = '--strict'

      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = vim.api.nvim_create_augroup('lint', { clear = true }),
        callback = function()
          lint.try_lint()
        end,
      })
      require('mason-nvim-lint').setup {
        ensured_installed = { 'mypy', 'sqlfluff' },
      }
    end,
  },
}
