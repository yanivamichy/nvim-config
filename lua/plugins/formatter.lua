return { -- Autoformat
  'stevearc/conform.nvim',
  dependencies = {
    { 'williamboman/mason.nvim', config = true },
    'zapling/mason-conform.nvim',
    'neovim/nvim-lspconfig',
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
        tex = { 'tex-fmt', 'bibtex-tidy' },
        -- tex = {'tex-fmt'},
        ['_'] = { 'trim_whitespace' },
      },
      format_on_save = false,
      -- format_on_save = function(bufnr)
      --   local disable_filetypes = { c = true, cpp = true } -- Disable fallback for problematic languages
      --   return {
      --     timeout_ms = 500,
      --     lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
      --   }
      -- end,
    }











    -- require('conform').formatters.ruff_organize_imports = {
    --   args = {
    --     'check',
    --     '--fix',
    --     '--force-exclude',
    --     '--select=I001',
    --     '--line-length',
    --     '120',
    --     '--exit-zero',
    --     '--no-cache',
    --     '--stdin-filename',
    --     '$FILENAME',
    --     '-',
    --   },
    -- }
    --
    -- require('conform').formatters.ruff_format = {
    --   args = {
    --     'format',
    --     '--force-exclude',
    --     -- '--line-length',
    --     -- '120',
    --     '--stdin-filename',
    --     '$FILENAME',
    --     '-',
    --   },
    -- }

    vim.keymap.set('', '<leader>f', function()
      -- require('conform').format { async = true, lsp_format = 'never' }
      require('conform').format { async = true, lsp_fallback = true }
    end, { desc = '[F]ormat buffer' })

    require('mason-conform').setup()
  end,
}
