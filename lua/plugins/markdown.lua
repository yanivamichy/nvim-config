return {
  {
    'obsidian-nvim/obsidian.nvim',
    version = '3.11.0',
    ft = 'markdown',
    lazy = false,
    dependencies = { 'nvim-lua/plenary.nvim', 'hrsh7th/nvim-cmp', 'nvim-telescope/telescope.nvim' },
    opts = {
      workspaces = {
        {
          name = 'work',
          path = '~/vaults/work',
        },
        {
          name = 'personal',
          path = '~/vaults/personal',
        },
      },
      mappings = {},

      ui = { enable = false },
      completion = { nvim_cmp = true },
      picker = { name = 'telescope.nvim' },
      templates = {
        folder = 'templates',
      },
      note_id_func = function(title)
        local suffix = ''
        if title ~= nil then
          suffix = title:gsub(' ', '_'):gsub('[^A-Za-z0-9-_]', ''):lower()
        else
          for _ = 1, 4 do
            suffix = suffix .. string.char(math.random(65, 90))
          end
        end
        local timestamp = os.date('!%Y-%m-%d-%H%M%S', os.time() - 5 * 3600)
        return timestamp .. '_' .. suffix
      end,
    },
    keys = {
      { '<leader>of', ':ObsidianQuickSwitch<cr>', desc = '[O]bsidian search [F]iles' },
      { '<leader>ot', ':ObsidianTags<cr>', desc = '[O]bsidian search [T]ags' },
      { '<leader>og', ':ObsidianSearch<cr>', desc = '[O]bsidian [G]rep notes' },
      { '<leader>ow', ':ObsidianWorkspace<cr>', desc = '[O]bsidian switch [W]orkspace' },
      { '<leader>on', ':ObsidianNew<cr>', desc = '[O]bsidian [N]ew note' },
      { '<leader>oN', ':ObsidianNewFromTemplate<cr>', desc = '[O]bsidian [N]ew from template' },
      { '<leader>ob', ':ObsidianBacklinks<cr>', desc = '[O]bsidian search [B]acklinks' },
      { '<leader>od', ':ObsidianToday<cr>', desc = '[O]bsidian open [D]aily note' },
      { '<leader>ol', ':ObsidianLink<cr>', desc = '[O]bsidian [L]link text' },
      { '<leader>oe', ':ObsidianExtract<cr>', desc = '[O]bsidian [E]xtract text' },
      { '<leader>oc', ':ObsidianTOC<cr>', desc = '[O]bsidian TO[C]' },
      {
        '<leader>om',
        function()
          return require('obsidian').util.toggle_checkbox()
        end,
        desc = 'Toggle Check [M]ark',
      },
    },
  },

  {
    'bullets-vim/bullets.vim',
    ft = { 'markdown', 'text', 'extensionless' },
    init = function()
      vim.g.bullets_set_mappings = 0
      vim.g.bullets_enable_in_empty_buffers = 1
      vim.g.bullets_custom_mappings = {
        { 'imap', '<cr>', '<Plug>(bullets-newline)' },
        { 'inoremap', '<C-cr>', '<cr>' },
        { 'nmap', 'o', '<Plug>(bullets-newline)' },
        { 'vmap', 'gN', '<Plug>(bullets-renumber)' },
        { 'nmap', 'gN', '<Plug>(bullets-renumber)' },
        { 'nmap', '<leader>x', '<Plug>(bullets-toggle-checkbox)' },
        { 'imap', '<C-t>', '<Plug>(bullets-demote)' },
        { 'nmap', '>>', '<Plug>(bullets-demote)' },
        { 'vmap', '>', '<Plug>(bullets-demote)' },
        { 'imap', '<C-d>', '<Plug>(bullets-promote)' },
        { 'nmap', '<<', '<Plug>(bullets-promote)' },
        { 'vmap', '<', '<Plug>(bullets-promote)' },
      }
    end,
  },

  {
    'iamcco/markdown-preview.nvim',
    dependencies = { 'iamcco/mathjax-support-for-mkdp' },
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown' },
    build = ':call mkdp#util#install()',
    init = function()
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_combine_preview = 1
    end,
    keys = {
      { '<leader>op', ':MarkdownPreview<cr>', desc = '[O]bsidian [P]review' },
    },
  },

  {
    'jmbuhr/otter.nvim',
    dependencies = {
      'hrsh7th/nvim-cmp',
      'nvim-treesitter/nvim-treesitter',
    },
    opts = {},
    keys = {
      {
        '<leader>oa',
        function()
          local languages = { 'python', 'lua' }
          local completion = true
          local diagnostics = true
          local tsquery = nil
          local otter = require 'otter'
          otter.activate(languages, completion, diagnostics, tsquery)
        end,
        desc = '[A]ctivate Otter',
      },
    },
  },

  {
    'Kurama622/markdown-org',
    ft = 'markdown',
    init = function()
      python_env = require('utils.LanguageToolFinders').get_python_env()
      vim.g.language_path = {
        python = python_env,
        python3 = python_env,
        bash = 'bash',
      }
      vim.g.default_quick_keys = 0
      vim.api.nvim_set_var('org#style#border', 2)
      vim.api.nvim_set_var('org#style#bordercolor', 'FloatBorder')
      vim.api.nvim_set_var('org#style#color', 'String')
    end,
    keys = {
      { '<leader>or', '<cmd>call org#main#runCodeBlock()<cr>', desc = '[R]un code block' },
      { '<leader>oR', '<cmd>call org#main#runLanguage()<cr>', desc = '[R]un language' },
    },
  },

  {
    'lervag/vimtex',
    lazy = false,
  },
}
