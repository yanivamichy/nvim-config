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

      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = vim.api.nvim_create_augroup('lint', { clear = true }),
        callback = function()
          lint.try_lint()
        end,
      })
      require('mason-nvim-lint').setup {
        ensured_installed = { 'mypy' },
      }
    end,
  },
}
