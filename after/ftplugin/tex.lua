local autopairs = require 'nvim-autopairs'

vim.keymap.set('i', '<CR>', function()
  local line = vim.api.nvim_get_current_line()
  local empty_item_indent = line:match '^(%s*)\\item%s*$'
  if empty_item_indent then
    return '<Esc>cc'
  end

  local indent = line:match '^(%s*)\\item%s+.+'
  if indent then
    return '<CR>' .. '\\item '
  end

  return autopairs.autopairs_cr()
end, {
  buffer = true,
  expr = true,
  noremap = true,
  replace_keycodes = false,
  desc = 'Continue LaTeX item on Enter',
})
