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
      require('mini.surround').setup {
        mappings = {
          add = '<M-s>a',
          delete = '<M-s>d',
          find = '<M-s>f',
          find_left = '<M-s>F',
          highlight = '<M-s>h',
          replace = '<M-s>r',
          update_n_lines = '<M-s>n',
        },
      }
      require('mini.splitjoin').setup { mappings = { toggle = '<leader>ts' } }
    end,
  },

  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    dependencies = { 'hrsh7th/nvim-cmp' },
    config = function()
      local autopairs = require 'nvim-autopairs'
      autopairs.setup { map_cr = true }

      local Rule = require 'nvim-autopairs.rule'
      local cond = require 'nvim-autopairs.conds'

      local not_in_math = function()
        return vim.fn['vimtex#syntax#in_mathzone']() == 0
      end
      local between_dollars = function(opts)
        return cond.before_text '$'(opts) and cond.after_text '$'(opts)
      end

      autopairs.add_rules {
        Rule('$', '$', { 'markdown', 'tex' })
          :with_pair(function(opts)
            return not_in_math() or between_dollars(opts)
          end)
          :with_move(cond.not_before_text '$')
          :with_cr(cond.none()),
      }

      autopairs.add_rules {
        Rule('$$', '$$', { 'markdown', 'tex' }):with_pair(cond.not_before_text '$'):with_move(cond.done()),
      }

      -- If you want to automatically add `(` after selecting a function or method
      local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
      local cmp = require 'cmp'
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },

  {
    'jake-stewart/multicursor.nvim',
    config = function()
      local mc = require 'multicursor-nvim'
      mc.setup()

      vim.keymap.set({ 'n', 'x' }, '<C-M-k>', function()
        mc.lineAddCursor(-1)
      end, { desc = 'Multi Cursor - Add Down' })
      vim.keymap.set({ 'n', 'x' }, '<C-M-j>', function()
        mc.lineAddCursor(1)
      end, { desc = 'Multi Cursor - Add Up' })
      vim.keymap.set({ 'n', 'x' }, '<c-q>', mc.toggleCursor, { desc = 'Multi Cursor - Toggle Cursor' })
      vim.keymap.set({ 'n', 'x' }, '<C-M-h>', function()
        mc.lineSkipCursor(-1)
      end, { desc = 'Multi Cursor - Skip Down' })
      vim.keymap.set({ 'n', 'x' }, '<C-M-l>', function()
        mc.lineSkipCursor(1)
      end, { desc = 'Multi Cursor - Skip Up' })

      mc.addKeymapLayer(function(layerSet)
        layerSet({ 'n', 'x' }, '<left>', mc.prevCursor)
        layerSet({ 'n', 'x' }, '<right>', mc.nextCursor)
        layerSet({ 'n', 'x' }, '<leader>x', mc.deleteCursor)
        layerSet('n', '<esc>', function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end)
      end)
      local hl = vim.api.nvim_set_hl
      hl(0, 'MultiCursorCursor', { reverse = true })
      hl(0, 'MultiCursorVisual', { link = 'Visual' })
      hl(0, 'MultiCursorSign', { link = 'SignColumn' })
      hl(0, 'MultiCursorMatchPreview', { link = 'Search' })
      hl(0, 'MultiCursorDisabledCursor', { reverse = true })
      hl(0, 'MultiCursorDisabledVisual', { link = 'Visual' })
      hl(0, 'MultiCursorDisabledSign', { link = 'SignColumn' })
    end,
  },

  {
    'gbprod/yanky.nvim',
    event = 'VimEnter',
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
        mode = { 'n', 'v' },
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
        desc = 'Open Yank History - Reversed',
        mode = { 'n', 'v' },
      },
    },
  },

  {
    'mbbill/undotree',
    init = function()
      vim.keymap.set('n', '<leader>tu', ':UndotreeToggle<CR>', { desc = '[T]oggle [U]ndoTree' })
    end,
  },

  {
    'kevinhwang91/nvim-bqf',
    config = function()
      require('bqf').setup()
    end,
  },
}
