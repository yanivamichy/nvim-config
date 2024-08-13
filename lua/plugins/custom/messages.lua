local function capture_cmd(command)
  local output = vim.api.nvim_cmd({ cmd = command }, { output = true })
  return output:gmatch '[^\r\n]+'
end

local function toggle_buffer(name)
  if vim.fn.bufwinid(name) > 0 then
    vim.fn.execute('bw ' .. name)
    return nil
  end
  if vim.fn.bufexists(name) > 0 then
    vim.fn.execute('bw ' .. name)
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

-- display_cmd('messages', 'Messages')

vim.keymap.set('n', '<leader>m', function()
  display_cmd 'messages'
end, { desc = 'Toggle [M]essages' })
