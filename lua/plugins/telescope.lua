return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  config = function()
    -- Two important keymaps to use while in Telescope are:
    --  - Insert mode: <c-/>
    --  - Normal mode: ?
    require('telescope').setup {
      defaults = {
        mappings = {
          i = {
            ['<M-w>'] = require('telescope.actions').delete_buffer,
            ['<M-r>'] = 'to_fuzzy_refine',
          },
          n = { ['<M-w>'] = require('telescope.actions').delete_buffer },
        },
        dynamic_preview_title = true,
        preview = { treesitter = false },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }

    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>st', builtin.builtin, { desc = '[S]earch select [T]elescope' })
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sz', function()
      builtin.live_grep { cwd = require('telescope.utils').buffer_dir() }
    end, { desc = '[S]earch by [G]rep (at file location)' })
    vim.keymap.set('n', '<leader>sZ', function()
      builtin.live_grep {
        cwd = require('telescope.utils').buffer_dir(),
        additional_args = function()
          return { '--hidden', '--no-ignore' }
        end,
      }
    end, { desc = '[S]earch Ignored by [G]rep (at file location)' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader>sb', builtin.buffers, { desc = '[S]earch [B]uffers' })
    vim.keymap.set('n', '<leader>gsc', builtin.git_commits, { desc = '[G]it [S]earch [C]ommits' })
    vim.keymap.set('n', '<leader>gss', builtin.git_status, { desc = '[G]it [S]earch [S]tatus' })
    vim.keymap.set('n', '<leader>gsb', builtin.git_branches, { desc = '[G]it [S]earch [B]ranches' })
    vim.keymap.set(
      'n',
      '<leader>si',
      '<cmd>Telescope find_files hidden=true no_ignore=true<cr>',
      { desc = '[S]earch [I]gnored files' }
    )
    vim.keymap.set('n', '<leader>/', function()
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winbend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })
    vim.keymap.set('n', '<leader>s/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch [/] in Open Files' })
    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })
  end,
}
