local function capture_cmd(command)
  local output = vim.api.nvim_exec2(command, { output = true }).output
  return output:gmatch '[^\r\n]+'
end

local function toggle_buffer(name)
  local bufnr = vim.fn.bufnr(name)
  if vim.fn.bufwinid(name) > 0 then
    vim.fn.execute('bw ' .. bufnr)
    return nil
  end
  if bufnr > 0 then
    vim.fn.execute('bw ' .. bufnr)
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, name)
  local winid = vim.api.nvim_open_win(buf, true, { split = 'below' })
  vim.api.nvim_win_set_buf(0, buf)
  vim.fn.execute 'wincmd J | res10 | set wfh'

  vim.fn.execute 'wincmd p'
  return winid
end

local function display_cmd(command, buf_name)
  buf_name = buf_name or command:gsub('^%l', string.upper)
  local winid = toggle_buffer(buf_name)
  if winid then
    local line_iterator = capture_cmd(command)
    local line_table = {}
    for line in line_iterator do
      table.insert(line_table, line)
    end
    local bufnr = vim.fn.bufnr(buf_name)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, line_table)
    vim.api.nvim_win_set_cursor(winid, { vim.api.nvim_buf_line_count(bufnr), 0 })
  end
end

vim.keymap.set('n', '<leader>tm', function()
  display_cmd 'messages'
end, { desc = '[T]oggle [M]essages' })

vim.cmd 'redir @Z'
vim.keymap.set('n', '<leader>tc', function()
  display_cmd('echo @z', 'Command outputs')
end, { desc = '[T]oggle [C]ommands' })
