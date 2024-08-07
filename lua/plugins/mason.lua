return { -- Install LSP, Linters, Formatters & DAP
  'WhoIsSethDaniel/mason-tool-installer.nvim',
  dependencies = { 'williamboman/mason.nvim', config = true },
  config = function()
    require('mason-tool-installer').setup {
      ensure_installed = { 'lua_ls', 'stylua', 'ruff', 'pyright', 'mypy' },
    }
  end,
}
