return {
  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      vim.cmd.colorscheme 'tokyonight-night'

      -- You can configure highlights by doing something like:
      vim.cmd.hi 'Comment gui=none'
    end,
    opts = {
      on_colors = function(colors)
        colors.border = colors.blue0
      end,
    },
  },

  -- {
  --   'catppuccin/nvim',
  --   name = 'catppuccin',
  --   priority = 1000,
  --   init = function()
  --     vim.cmd.colorscheme 'catppuccin'
  --     vim.cmd.hi 'Comment gui=none'
  --   end,
  -- },

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    version = 'v2.1.0',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter' (`:help autocmd-events`).
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup {
        icons = { mappings = false },
      }

      -- Document existing key chains
      require('which-key').register {
        ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
        ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
        ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
        ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
        ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
        ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
        ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
        ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
        ['<leader>gs'] = { name = '[G]it [S]earch', _ = 'which_key_ignore' },
        ['<leader>gu'] = { name = '[U]nit tests', _ = 'which_key_ignore' },
      }
    end,
  },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

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
}
