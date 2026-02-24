return {
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    init = function()
      vim.cmd.colorscheme 'tokyonight-night'
      vim.cmd.hi 'Comment gui=none'
      vim.cmd.hi 'LspSignatureActiveParameter guibg=#5f6687'
    end,
    opts = {
      on_colors = function(colors)
        colors.border = colors.blue0
      end,
    },
  },

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    version = 'v2.1.0',
    event = 'VimEnter',
    config = function()
      require('which-key').setup {
        icons = { mappings = false },
      }

      -- Document existing key chains
      require('which-key').register {
        ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
        ['<leader>d'] = { name = '[D]ebug', _ = 'which_key_ignore' },
        ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
        ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
        ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
        ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
        ['<leader>u'] = { name = '[U]nit tests', _ = 'which_key_ignore' },
        ['<leader>L'] = { name = '[L]sp symbols', _ = 'which_key_ignore' },
      }
    end,
  },

  -- Highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },

  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup {
        options = {
          icons_enabled = false,
          component_separators = { left = '|', right = '|' },
          section_separators = { left = '|', right = '|' },
          globalstatus = true,
          disabled_filetypes = { winbar = { 'dap-repl' } },
        },
        sections = {
          lualine_c = {
            {
              'filename',
              path = 1,
            },
          },
        },
        winbar = {
          lualine_a = {
            '%f',
          },
          lualine_b = {
            '%m',
          },
        },
        inactive_winbar = {
          lualine_a = {
            '%f',
          },
          lualine_b = {
            '%m',
          },
        },
      }
    end,
  },

  { 'chrisbra/csv.vim' },

  -- {
  --   'cameron-wags/rainbow_csv.nvim',
  --   config = true,
  --   ft = {
  --     'csv',
  --     'tsv',
  --     'csv_semicolon',
  --     'csv_whitespace',
  --     'csv_pipe',
  --     'rfc_csv',
  --     'rfc_semicolon',
  --   },
  --   cmd = {
  --     'RainbowDelim',
  --     'RainbowDelimSimple',
  --     'RainbowDelimQuoted',
  --     'RainbowMultiDelim',
  --   },
  -- },
}
