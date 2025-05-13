return {
  { -- Highlight, edit, and navigate code
    dependencies = { 'nvim-treesitter/playground' },
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
        auto_install = true,
        ignore_install = { 'latex' },
        highlight = {
          enable = true,
          disable = function(lang, bufnr)
            local langs_to_ignore = { csv = true, latex = true, markdown = false }
            return langs_to_ignore[lang] or vim.api.nvim_buf_line_count(bufnr) > 10000
          end,
          -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
          --  If you are experiencing weird indenting issues, add the language to
          --  the list of additional_vim_regex_highlighting and disabled languages for indent.
          additional_vim_regex_highlighting = { 'ruby' },
        },
        indent = { enable = true, disable = { 'ruby' } },
      }
      vim.api.nvim_set_hl(0, '@variable.python', { fg = '#c0caf5', bg = 'NONE' })
      vim.api.nvim_set_hl(0, '@variable.member.python', { fg = '#c0caf5', bg = 'NONE' })
      -- vim.api.nvim_set_hl(0, '@type.python', { fg = '#c0caf5', bg = 'NONE' })
      vim.api.nvim_set_hl(0, '@function.call.python', { fg = '#DCDCAA', bg = 'NONE' })
      vim.api.nvim_set_hl(0, '@function.method.python', { fg = '#DCDCAA', bg = 'NONE' })
      vim.api.nvim_set_hl(0, '@keyword.function.python', { fg = '#7aa2f7', bg = 'NONE' })
      vim.api.nvim_set_hl(0, '@keyword.import.python', { fg = '#BB9AF7', bg = 'NONE' })
      vim.api.nvim_set_hl(0, '@keyword.type.python', { fg = '#7aa2f7', bg = 'NONE' })
      vim.api.nvim_set_hl(0, '@keyword.operator.python', { fg = '#7aa2f7', bg = 'NONE' })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('treesitter-context').setup {
        multiline_threshold = 1,
      }
      vim.keymap.set('n', '[C', function()
        require('treesitter-context').go_to_context(vim.v.count1)
      end, { silent = true, desc = 'jump to [C]ontext' })
    end,
  },
}
