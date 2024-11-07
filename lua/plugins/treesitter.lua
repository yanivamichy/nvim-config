return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter.configs').setup {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
      auto_install = true,
      highlight = {
        enable = true,
        disable = { 'csv' },
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    }
    vim.api.nvim_set_hl(0, '@variable.python', { fg = '#c0caf5', bg = 'NONE' })
    vim.api.nvim_set_hl(0, '@variable.member.python', { fg = '#c0caf5', bg = 'NONE' })
    vim.api.nvim_set_hl(0, '@function.call.python', { fg = '#DCDCAA', bg = 'NONE' })
    vim.api.nvim_set_hl(0, '@function.method.python', { fg = '#DCDCAA', bg = 'NONE' })
    vim.api.nvim_set_hl(0, '@keyword.function.python', { fg = '#7aa2f7', bg = 'NONE' })
    vim.api.nvim_set_hl(0, '@keyword.import.python', { fg = '#BB9AF7', bg = 'NONE' })
    vim.api.nvim_set_hl(0, '@keyword.type.python', { fg = '#7aa2f7', bg = 'NONE' })
    vim.api.nvim_set_hl(0, '@keyword.operator.python', { fg = '#7aa2f7', bg = 'NONE' })
  end,
  -- There are additional nvim-treesitter modules that you can use to interact
  -- with nvim-treesitter. You should go explore a few and see what interests you:
  --
  --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
  --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
  --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
}
