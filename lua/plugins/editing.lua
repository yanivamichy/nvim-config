return {
  { 'tpope/vim-sleuth', tag = 'v2.0' }, -- Detect tabstop and shiftwidth automatically

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.move').setup {
        mappings = {
          line_left = '',
          line_right = '',
          line_up = '',
          line_down = '',
        },
      }
      require('mini.surround').setup()
      require('mini.splitjoin').setup { mappings = { toggle = '<leader>ts' } }
    end,
  },

  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    dependencies = { 'hrsh7th/nvim-cmp' },
    config = function()
      local autopairs = require 'nvim-autopairs'
      autopairs.setup {
        map_cr = false,
      }
      vim.keymap.set('i', '<cr>', function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-G>u', true, false, true), 'n', false)
        return autopairs.autopairs_cr()
      end, { expr = true, noremap = true, replace_keycodes = false })

      local Rule = require 'nvim-autopairs.rule'
      local cond = require 'nvim-autopairs.conds'
      local function or_cond(c1, c2)
        return function(opts)
          return c1(opts) or c2(opts)
        end
      end
      autopairs.add_rules {
        Rule('$', '$', { 'markdown', 'tex' }):with_move(cond.not_before_text '$'):with_pair(function(opts)
          local after = cond.after_text '$'(opts)
          local before = cond.not_before_text '$'(opts)
          if before == nil then
            before = true
          end
          return before or after
        end),
      }

      autopairs.add_rules {
        Rule('$$', '$$', { 'markdown', 'tex' }):with_move(cond.after_text '$$'):with_pair(cond.not_before_text '$'),
      }

      -- If you want to automatically add `(` after selecting a function or method
      local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
      local cmp = require 'cmp'
      local handlers = require 'nvim-autopairs.completion.handlers'
      local Kind = cmp.lsp.CompletionItemKind
      cmp_autopairs.filetypes.tex = { ['{'] = {
        kind = { Kind.Function },
        handler = handlers['*'],
      } }
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },

  { 'mg979/vim-visual-multi' }, -- :help visual-multi, tutorial: vim -Nu path/to/visual-multi/tutorialrc

  {
    'gbprod/yanky.nvim',
    opts = {
      highlight = { on_put = false, on_yank = false },
    },
    keys = {
      {
        '<leader>p',
        function()
          vim.fn.execute 'YankyRingHistory'
        end,
        desc = 'Open Yank History',
      },
      {
        '<leader>P',
        function()
          local history = {}
          for index, value in pairs(require('yanky.history').all()) do
            value.history_index = index
            history[index] = value
          end

          local action = require('yanky.picker').actions.put('P', false)
          if action == nil then
            return
          end

          vim.ui.select(history, {
            prompt = 'Ring history',
            format_item = function(item)
              return item.regcontents and item.regcontents:gsub('\n', '\\n') or ''
            end,
          }, action)
        end,
      },
    },
  },

  -- { 'mbbill/undotree' },
}
