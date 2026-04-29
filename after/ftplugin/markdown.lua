vim.keymap.set('n', '<leader>mc', function()
  require('telescope.builtin').lsp_document_symbols()
end, { buffer = true, desc = 'Markdown: TO[C]' })

vim.api.nvim_buf_create_user_command(0, 'Pandoc', function(cmd_args)
  local output_filetype = cmd_args.fargs[1]
  local input_file = vim.fn.fnameescape(vim.fn.expand '%:p')
  local output_file = vim.fn.fnameescape('~/renders/' .. vim.fn.expand '%:t:r' .. '.' .. output_filetype)
  local assets_dir = vim.fn.stdpath 'config' .. '/assets'
  local filters = { 'tikz.lua', 'diagrams.lua', 'matplotlib.lua' }
  local extensions = { 'lists_without_preceding_blankline', 'hard_line_breaks', 'tex_math_single_backslash' }

  local cmd = 'pandoc'
    .. ' -f markdown+'
    .. table.concat(extensions, '+')
    -- .. ' -i '
    -- .. input_file
    .. ' -o '
    .. output_file
    .. ' --embed-resources --standalone --mathjax'
    .. ' --citeproc'
    .. ' -M link-citations=true'
    .. ' --csl '
    .. assets_dir
    .. '/csl/ieee.csl'
    .. ' -V colorlinks=true'
    .. ' --number-sections'

  for _, f in ipairs(filters) do
    cmd = cmd .. ' --lua-filter=' .. assets_dir .. '/pandoc_filters/' .. f
  end

  -- local css_file = (#args.fargs == 2 and vim.fn.fnameescape(args.fargs[2])) or (vim.fn.stdpath 'config' .. '/assets/css/water.css')
  -- local css_file = vim.fn.stdpath 'config' .. '/assets/css/water.css'
  if #cmd_args.fargs == 2 then
    local css_file = vim.fn.fnameescape(cmd_args.fargs[2])
    cmd = cmd .. ' --css=' .. css_file
  end

  local python_env = require('utils.LanguageToolFinders').get_python_env()
  cmd = 'PYTHON_ENV=' .. python_env .. ' ' .. cmd

  local preprocess = 'python3 ' .. assets_dir .. '/pandoc_filters/citations_preprocess.py'
  local full_cmd = 'bib=$(mktemp /tmp/pandoc-refs-XXXXXX.bib); '
    .. 'trap "rm -f \\$bib" EXIT; '
    .. preprocess
    .. ' < '
    .. input_file
    .. ' 3>"$bib" | '
    .. cmd
    .. ' --bibliography "$bib"'
  vim.cmd('!' .. full_cmd)
end, {
  nargs = '+',
  desc = 'Convert Markdown with Pandoc',
})
vim.keymap.set('n', '<leader>mpp', ':Pandoc pdf<CR>', { buffer = true, desc = 'Pandoc - Convert2Pdf' })
vim.keymap.set('n', '<leader>mph', ':Pandoc html<CR>', { buffer = true, desc = 'Pandoc - Convert2Html' })

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

vim.keymap.set('n', '<leader>mC', function()
  local pandoc_cache_dir = os.getenv 'HOME' .. '/.cache/pandoc/'
  vim.fn.delete(pandoc_cache_dir, 'rf')
  print('Cleared: ' .. pandoc_cache_dir)
end, { buffer = true, desc = 'Clear Pandoc cache directory' })
