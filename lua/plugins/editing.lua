return {
  { 'tpope/vim-sleuth', tag = 'v2.0' }, -- Detect tabstop and shiftwidth automatically

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }
      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()
    end,
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    -- dependencies = { 'hrsh7th/nvim-cmp' },
    config = function()
      local autopairs = require 'nvim-autopairs'
      autopairs.setup {
        map_cr = false,
      }
      f = function()
        -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-G>u', true, false, true), 'n', false)
        return autopairs.autopairs_cr()
      end
      -- vim.keymap.set('i', '<CR>', f, { expr = true, noremap = true, silent = true })
      -- vim.api.nvim_set_keymap('i', '<cr>', function()
      --   return autopairs.autopairs_cr()
      -- end, { expr = true, noremap = true })
      -- vim.api.nvim_set_keymap('i', '<cr>', 'v:lua.f()', { expr = true, noremap = true })
      vim.keymap.set('i', '<cr>', function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-G>u', true, false, true), 'n', false)
        return autopairs.autopairs_cr()
      end, { expr = true, noremap = true, replace_keycodes = false })
      -- If you want to automatically add `(` after selecting a function or method
      local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
      local cmp = require 'cmp'
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },
  { 'mg979/vim-visual-multi', tag = 'v0.5.8' }, -- :help visual-multi, tutorial: vim -Nu path/to/visual-multi/tutorialrc
}
