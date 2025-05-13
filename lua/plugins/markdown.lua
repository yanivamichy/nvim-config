local function activate_otter()
  local languages = { 'python', 'lua' }
  local completion = true
  local diagnostics = true
  local tsquery = nil
  local otter = require 'otter'
  otter.activate(languages, completion, diagnostics, tsquery)
end

-- vim.keymap.set('i', '<CR>', '<CR>1', { noremap = false, silent = true })
-- vim.api.nvim_create_autocmd('FileType', {
--   pattern = { 'markdown' },
--   callback = function()
--     vim.keymap.set('i', '<CR>', function()
--       vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-G>u', true, false, true), 'n', false)
--
--       return autopairs.autopairs_cr()
--     end, { expr = true, noremap = false, silent = true, buffer = true })
--     -- vim.keymap.set('i', '<CR>', function()
--     --   return '<CR>'
--     -- end, { noremap = true, silent = true, buffer = true, expr = true })
--   end,
-- })

-- Function to print all objects detected in the current block
function print_objects_in_block()
  local ts = vim.treesitter
  local parsers = require 'nvim-treesitter.parsers'

  -- Get the current buffer number
  local bufnr = vim.api.nvim_get_current_buf()

  -- Get the language of the current buffer
  local lang = parsers.get_buf_lang(bufnr)

  -- Get the Tree-sitter parser for the current buffer
  local parser = parsers.get_parser(bufnr, lang)

  -- Parse the buffer and get the root node of the syntax tree
  local tree = parser:parse()[1]
  local root = tree:root()

  -- Get the current cursor position (row and column)
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))

  -- Find the node at the cursor position
  local current_node = root:named_descendant_for_range(row - 1, 0, row - 1, 9999)

  -- Query to capture various objects in the block
  local query = ts.query.parse(
    lang,
    [[
    (function_definition) @function
    (class_definition) @class
    (if_statement) @if
    (for_statement) @for
    (variable_declaration) @variable
    (identifier) @identifier
  ]]
  )
  --
  -- -- Iterate through the captures in the query
  -- for _, node in query:iter_captures(current_node, bufnr, current_node:range()) do
  --   local name = query.captures[node:id()] or 'unknown'
  --   local text = ts.get_node_text(node, bufnr)
  --   print(name .. ': ' .. text)
  -- end
end
vim.api.nvim_set_keymap('n', '<C-p>', ':lua print_objects_in_block()<CR>', { noremap = true, silent = true })

return {
  {
    -- 'epwalsh/obsidian.nvim',
    'obsidian-nvim/obsidian.nvim',
    version = '3.10.0',
    ft = 'markdown',
    lazy = false,
    -- event = {
    --   'BufReadPre ' .. vim.fn.expand '~' .. '/my-vault/*.md',
    --   'BufNewFile ' .. vim.fn.expand '~' .. '/my-vault/*.md',
    -- },
    dependencies = { 'nvim-lua/plenary.nvim', 'hrsh7th/nvim-cmp', 'nvim-telescope/telescope.nvim' },
    opts = {
      workspaces = {
        {
          name = 'personal',
          path = '~/vaults/personal',
        },
        -- {
        --   name = 'work',
        --   path = '~/vaults/work',
        -- },
      },
      ui = { enable = false },
      completion = { nvim_cmp = true },
      picker = { name = 'telescope.nvim' },
      templates = {
        folder = 'templates',
      },
      -- disable_frontmatter = true,
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
      { '<leader>ot', ':ObsidianTOC<cr>', desc = '[O]bsidian [T]OC' },
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
    build = function()
      vim.fn['mkdp#util#install']()
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
    config = function()
      local otter = require 'otter'
      otter.setup()
    end,
    keys = {
      { '<leader>oa', activate_otter, desc = '[A]ctivate Otter' },
    },
  },

  {
    'Kurama622/markdown-org',
    ft = 'markdown',
    config = function()
      vim.g.language_path = {
        python = 'python3',
        python3 = 'python3',
        -- go = 'go',
        -- c = 'gcc -Wall',
        -- cpp = 'g++ -std=c++11 -Wall',
        bash = 'bash',
        -- ['c++'] = 'g++ -std=c++11 -Wall',
      }
      return {
        default_quick_keys = 0,
        vim.api.nvim_set_var('org#style#border', 2),
        vim.api.nvim_set_var('org#style#bordercolor', 'FloatBorder'),
        vim.api.nvim_set_var('org#style#color', 'String'),
      }
    end,
    keys = {
      { '<leader>or', '<cmd>call org#main#runCodeBlock()<cr>', desc = '[R]un code block' },
      { '<leader>oR', '<cmd>call org#main#runLanguage()<cr>', desc = '[R]un language' },
    },
  },

  {
    'lervag/vimtex',
    lazy = false,
    -- init = function()
    -- vim.g.vimtex_view_method = 'zathura'
    -- end,
  },

  -- {
  --   'hedyhli/markdown-toc.nvim',
  --   ft = 'markdown', -- Lazy load on markdown filetype
  --   cmd = { 'Mtoc' }, -- Or, lazy load on "Mtoc" command
  --   opts = {
  --     -- Your configuration here (optional)
  --   },
  -- },

  -- {
  --   'MeanderingProgrammer/render-markdown.nvim',
  --   dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
  --   -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
  --   -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
  --   ---@module 'render-markdown'
  --   ---@type render.md.UserConfig
  --   opts = {},
  -- },
}
