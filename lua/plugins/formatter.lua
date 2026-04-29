return {
  'stevearc/conform.nvim',
  dependencies = {
    'williamboman/mason.nvim',
    'zapling/mason-conform.nvim',
  },
  tag = 'v8.4.0',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    require('conform').setup {
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'ruff_organize_imports', 'ruff_format' },
        json = { 'biome' },
        toml = { 'taplo' },
        mysql = { 'sql_formatter' },
        markdown = { 'injected', 'prettier' },
        css = { 'prettier' },
        -- tex = { 'tex-fmt', 'bibtex-tidy' },
        ['_'] = { 'trim_whitespace' },
      },

      formatters = {
        prettier = {
          prepend_args = { '--tab-width', '4' },
        },
      },
    }

    vim.keymap.set('n', '<leader>f', function()
      require('conform').format { async = true, lsp_fallback = true }
    end, { desc = '[F]ormat buffer' })

    require('mason-conform').setup()
  end,
}
