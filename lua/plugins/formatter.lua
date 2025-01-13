return { -- Autoformat
  'stevearc/conform.nvim',
  dependencies = {
    { 'williamboman/mason.nvim', config = true },
    'zapling/mason-conform.nvim',
  },
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    require('conform').setup {
      notify_on_error = false,
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'ruff_organize_imports', 'ruff_format' },
        json = { 'biome' },
        toml = { 'taplo' },
        mysql = { 'sql_formatter' },
        markdown = { 'prettier' },
        ['_'] = { 'trim_whitespace' },
      },
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true } -- Disable fallback for problematic languages
        return {
          timeout_ms = 500,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
    }
    vim.keymap.set('', '<leader>f', function()
      require('conform').format { async = true, lsp_fallback = true }
    end, { desc = '[F]ormat buffer' })

    require('mason-conform').setup()
  end,
}
