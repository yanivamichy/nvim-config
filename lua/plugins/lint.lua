return {
  {
    'mfussenegger/nvim-lint',
    dependencies = {
      'williamboman/mason.nvim',
      'rshkarin/mason-nvim-lint',
    },
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('mason-nvim-lint').setup {
        ensured_installed = { 'mypy', 'sqlfluff' },
      }
      local lint = require 'lint'

      lint.linters_by_ft = {
        -- markdown = { 'markdownlint' },
        python = { 'mypy' },
        sql = { 'sqlfluff' },
      }
      vim.list_extend(lint.linters.mypy.args, {
        '--python-executable=' .. require('utils.LanguageToolFinders').get_python_env(),
      })

      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = vim.api.nvim_create_augroup('lint', { clear = true }),
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
