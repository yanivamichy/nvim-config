vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function(args)
    local buf = args.buf

    vim.api.nvim_buf_create_user_command(buf, 'Pandoc', function(cmd_args)
      local output_filetype = cmd_args.fargs[1]
      local input_file = vim.fn.fnameescape(vim.fn.expand '%:p')
      local output_file = vim.fn.fnameescape('~/renders/' .. vim.fn.expand '%:t:r' .. '.' .. output_filetype)
      local assets_dir = vim.fn.stdpath 'config' .. '/assets'
      local filter_file = assets_dir .. '/pandoc_filters/tikz.lua'

      local cmd = 'pandoc -i ' .. input_file .. ' -o ' .. output_file .. ' --embed-resources --standalone --mathjax'
      cmd = cmd .. ' --lua-filter=' .. filter_file

      -- local css_file = (#args.fargs == 2 and vim.fn.fnameescape(args.fargs[2])) or (vim.fn.stdpath 'config' .. '/assets/css/water.css')
      -- local css_file = vim.fn.stdpath 'config' .. '/assets/css/water.css'
      if #cmd_args.fargs == 2 then
        local css_file = vim.fn.fnameescape(cmd_args.fargs[2])
        cmd = cmd .. ' --css=' .. css_file
      end

      if output_filetype == 'pdf' then
        cmd = cmd .. ' --include-in-header=' .. assets_dir .. '/pandoc_headers/latex_header.tex'
      end

      vim.cmd('!' .. cmd)
    end, {
      nargs = '+',
      desc = 'Convert Markdown with Pandoc',
    })

    local open_render = function(file_type)
      local rendered_file = vim.fn.fnameescape('~/renders/' .. vim.fn.expand '%:t:r' .. '.' .. file_type)
      vim.cmd('!xdg-open ' .. rendered_file)
    end

    vim.keymap.set('n', '<leader>mop', function()
      open_render 'pdf'
    end, { buffer = true, desc = 'Open Render - Pdf' })
    vim.keymap.set('n', '<leader>moh', function()
      open_render 'html'
    end, { buffer = true, desc = 'Open Render - html' })
    vim.keymap.set('n', '<leader>mpp', ':Pandoc pdf<CR>', { buffer = true, desc = 'Pandoc - Convert2Pdf' })
    vim.keymap.set('n', '<leader>mph', ':Pandoc html<CR>', { buffer = true, desc = 'Pandoc - Convert2Html' })
  end,
})

return {
  {
    'obsidian-nvim/obsidian.nvim',
    -- version = '3.11.0',
    commit = '3baea08',
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
      mappings = {
        ['gf'] = {
          action = function()
            return require('obsidian').util.gf_passthrough()
          end,
          opts = { noremap = false, expr = true, buffer = true },
        },
      },

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
      { '<leader>mf', ':ObsidianQuickSwitch<cr>', desc = 'Markdown search [F]iles' },
      { '<leader>mt', ':ObsidianTags<cr>', desc = 'Markdown search [T]ags' },
      { '<leader>mg', ':ObsidianSearch<cr>', desc = 'Markdown [G]rep notes' },
      { '<leader>mw', ':ObsidianWorkspace<cr>', desc = 'Markdown switch [W]orkspace' },
      { '<leader>mn', ':ObsidianNew<cr>', desc = 'Markdown [N]ew note' },
      { '<leader>mN', ':ObsidianNewFromTemplate<cr>', desc = 'Markdown [N]ew from template' },
      { '<leader>mb', ':ObsidianBacklinks<cr>', desc = 'Markdown search [B]acklinks' },
      { '<leader>md', ':ObsidianToday<cr>', desc = 'Markdown open [D]aily note' },
      { '<leader>ml', ':ObsidianLink<cr>', desc = 'Markdown [L]link text' },
      { '<leader>me', ':ObsidianExtract<cr>', desc = 'Markdown [E]xtract text' },
      { '<leader>mc', ':ObsidianTOC<cr>', desc = 'Markdown TO[C]' },
      {
        '<leader>mm',
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
        -- { 'inoremap', '<C-cr>', '<cr>' },
        { 'nmap', 'o', '<Plug>(bullets-newline)' },
        { 'vmap', 'gN', '<Plug>(bullets-renumber)' },
        { 'nmap', 'gN', '<Plug>(bullets-renumber)' },
        -- { 'nmap', '<leader>x', '<Plug>(bullets-toggle-checkbox)' },
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
      { '<leader>mP', ':MarkdownPreview<cr>', desc = '[O]bsidian [P]review' },
    },
  },

  -- {
  --   'jmbuhr/otter.nvim',
  --   dependencies = {
  --     'hrsh7th/nvim-cmp',
  --     'nvim-treesitter/nvim-treesitter',
  --   },
  --   opts = {},
  --   keys = {
  --     {
  --       '<leader>oa',
  --       function()
  --         local languages = { 'python', 'lua' }
  --         local completion = true
  --         local diagnostics = true
  --         local tsquery = nil
  --         local otter = require 'otter'
  --         otter.activate(languages, completion, diagnostics, tsquery)
  --       end,
  --       desc = '[A]ctivate Otter',
  --     },
  --   },
  -- },

  -- {
  --   'Kurama622/markdown-org',
  --   ft = 'markdown',
  --   init = function()
  --     python_env = require('utils.LanguageToolFinders').get_python_env()
  --     vim.g.language_path = {
  --       python = python_env,
  --       python3 = python_env,
  --       bash = 'bash',
  --     }
  --     vim.g.default_quick_keys = 0
  --     vim.api.nvim_set_var('org#style#border', 2)
  --     vim.api.nvim_set_var('org#style#bordercolor', 'FloatBorder')
  --     vim.api.nvim_set_var('org#style#color', 'String')
  --   end,
  --   keys = {
  --     { '<leader>or', '<cmd>call org#main#runCodeBlock()<cr>', desc = '[R]un code block' },
  --     { '<leader>oR', '<cmd>call org#main#runLanguage()<cr>', desc = '[R]un language' },
  --   },
  -- },

  -- {
  --   'lervag/vimtex',
  --   lazy = false,
  -- },
}
