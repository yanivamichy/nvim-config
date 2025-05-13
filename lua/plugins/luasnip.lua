return {
  'L3MON4D3/LuaSnip',
  dependencies = {
    'rafamadriz/friendly-snippets', -- optional, but helpful
  },
  config = function()
    require('luasnip.loaders.from_vscode').lazy_load() -- if using friendly-snippets
  end,
}
