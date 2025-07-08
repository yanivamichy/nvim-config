vim.api.nvim_buf_create_user_command(0, 'Pandoc', function(args)
  local output_filetype = args.fargs[1]
  local input_file = vim.fn.fnameescape(vim.fn.expand '%:p')
  local output_file = vim.fn.fnameescape('~/renders/' .. vim.fn.expand '%:t:r' .. '.' .. output_filetype)
  local assets_dir = vim.fn.stdpath 'config' .. '/assets'

  -- local css_file = (#args.fargs == 2 and vim.fn.fnameescape(args.fargs[2])) or (vim.fn.stdpath 'config' .. '/assets/css/water.css')
  -- local css_file = vim.fn.stdpath 'config' .. '/assets/css/water.css'
  if #args.fargs == 2 then
    local css_file = vim.fn.fnameescape(args.fargs[2])
    cmd = cmd .. ' --css=' .. css_file
  end
  local filter_file = assets_dir .. '/pandoc_filters/tikz.lua'

  local cmd = 'pandoc -i ' .. input_file .. ' -o ' .. output_file .. ' --embed-resources --standalone --mathjax'
  cmd = cmd .. ' --lua-filter=' .. filter_file

  if output_filetype == 'pdf' then
    cmd = cmd .. ' --include-in-header=' .. assets_dir .. '/pandoc_headers/latex_header.tex'
  end
  vim.cmd('!' .. cmd)
end, { nargs = '+' })
