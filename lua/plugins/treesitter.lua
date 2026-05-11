return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    branch = 'main',
    config = function()
      require('nvim-treesitter').install {
        'python',
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
        'latex',
      }

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local buf, filetype = args.buf, args.match

          if vim.api.nvim_buf_line_count(buf) > 10000 then
            return
          end

          local language = vim.treesitter.language.get_lang(filetype)
          if not language then
            return
          end
          local langs_to_ignore = { csv = true, latex = true }
          if langs_to_ignore[language] then
            return
          end

          if not vim.treesitter.language.add(language) then
            return
          end

          vim.treesitter.start(buf, language)
          if vim.treesitter.query.get(language, 'indents') then
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

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
