vim.g.markdown_vault = vim.g.markdown_vault or vim.fn.expand '~/vaults/personal'

local map = function(keys, func, desc)
  vim.keymap.set('n', keys, func, { desc = 'Markdown: ' .. desc })
end

map('<leader>mf', function()
  require('telescope.builtin').find_files {
    cwd = vim.g.markdown_vault,
    -- search_dirs = { vim.g.markdown_vault },
    find_command = { 'rg', '--files', '--glob=*.md', '--sortr=modified' },
  }
end, 'Search [F]iles')

map('<leader>mg', function()
  require('telescope.builtin').live_grep {
    cwd = vim.g.markdown_vault,
    -- search_dirs = { vim.g.markdown_vault },
  }
end, '[G]rep notes')

-- map('<leader>mT', function()
--   require('telescope.builtin').live_grep {
--     search_dirs = { vim.g.markdown_vault },
--     default_text = '#',
--   }
-- end, 'Search [T]ags')

map('<leader>mw', function()
  vim.ui.select({ 'personal', 'work' }, { prompt = 'Select workspace:' }, function(choice)
    if not choice then
      return
    end
    vim.g.markdown_vault = vim.fn.expand('~/vaults/' .. choice)
    vim.notify('Switched to ' .. choice .. ' vault', vim.log.levels.INFO)
  end)
end, 'Switch [W]orkspace')

local function new_note(template_path, title)
  local suffix = title:match '%.(%a+)$'
  if suffix and suffix ~= 'md' then
    vim.notify('Error: only .md files are supported', vim.log.levels.ERROR)
    return
  end
  local bare = title:match '^(.-)%.md$' or title
  local normalized_title = bare:sub(1, 1):upper() .. bare:sub(2)
  local id = os.date '%Y-%m-%d-%H%M%S' .. '_' .. bare:gsub(' ', '_'):gsub('[^A-Za-z0-9-_]', ''):lower()
  local filename = vim.g.markdown_vault .. '/' .. (suffix == 'md' and title or id .. '.md')
  if vim.fn.filereadable(filename) == 1 then
    vim.notify('Error: file already exists: ' .. filename, vim.log.levels.ERROR)
    return
  end

  local vars = { title = normalized_title, id = id, date = os.date '%Y-%m-%d' }
  local lines = vim.tbl_map(function(line)
    return (line:gsub('{{(%w+)}}', function(k)
      return vars[k] or ''
    end))
  end, vim.fn.readfile(template_path))
  vim.cmd('edit ' .. filename)
  vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
  vim.cmd 'write'
end

map('<leader>mn', function()
  local title = vim.fn.input 'Note title: '
  if title == '' then
    return
  end
  new_note(vim.g.markdown_vault .. '/templates/default_template.md', title)
end, '[N]ew note')

return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '<leader>mt', '<cmd>RenderMarkdown toggle<cr>', desc = 'Toggle Markdown Rendering' },
    },
    opts = {
      file_types = { 'markdown', 'opencode_output' },
      dash = { enabled = false },
      latex = {
        enabled = false,
      },
    },
  },

  -- {
  --   'bullets-vim/bullets.vim',
  --   ft = { 'markdown', 'text', 'extensionless' },
  --   init = function()
  --     vim.g.bullets_set_mappings = 0
  --     vim.g.bullets_enable_in_empty_buffers = 1
  --     vim.g.bullets_custom_mappings = {
  --       { 'imap', '<cr>', '<Plug>(bullets-newline)' },
  --       { 'nmap', 'o', '<Plug>(bullets-newline)' },
  --       -- { 'vmap', 'gN', '<Plug>(bullets-renumber)' },
  --       -- { 'nmap', 'gN', '<Plug>(bullets-renumber)' },
  --       { 'nmap', '<C-m>', '<Plug>(bullets-toggle-checkbox)' },
  --       { 'imap', '<C-t>', '<Plug>(bullets-demote)' },
  --       { 'nmap', '>>', '<Plug>(bullets-demote)' },
  --       { 'vmap', '>', '<Plug>(bullets-demote)' },
  --       { 'imap', '<C-d>', '<Plug>(bullets-promote)' },
  --       { 'nmap', '<<', '<Plug>(bullets-promote)' },
  --       { 'vmap', '<', '<Plug>(bullets-promote)' },
  --     }
  --   end,
  -- },

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
    config = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'markdown',
        callback = function()
          vim.keymap.set('n', '<leader>mP', ':MarkdownPreview<cr>', { buffer = true, desc = '[M]arkdown [P]review' })
        end,
      })
    end,
  },

  {
    'jmbuhr/otter.nvim',
    config = function()
      require('otter').setup()
      vim.api.nvim_create_autocmd('LspAttach', {
        pattern = '*.md',
        callback = function()
          vim.defer_fn(function()
            require('otter').activate()
          end, 100)
        end,
      })
    end,
  },

  -- {
  --   'AckslD/nvim-FeMaco.lua',
  --   config = function()
  --     require('femaco').setup()
  --     vim.api.nvim_create_autocmd('FileType', {
  --       pattern = 'markdown',
  --       callback = function()
  --         vim.keymap.set('n', '<leader>me', function()
  --           require('femaco.edit').edit_code_block()
  --         end, { buffer = true, desc = '[M]arkdown [E]dit code' })
  --       end,
  --     })
  --   end,
  -- },

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
    config = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'markdown',
        callback = function()
          local opts = { buffer = true }
          vim.keymap.set(
            'n',
            '<leader>mr',
            '<cmd>call org#main#runCodeBlock()<cr>',
            vim.tbl_extend('force', opts, { desc = '[R]un code block' })
          )
          vim.keymap.set(
            'n',
            '<leader>mR',
            '<cmd>call org#main#runLanguage()<cr>',
            vim.tbl_extend('force', opts, { desc = '[R]un language' })
          )
        end,
      })
    end,
  },
}
