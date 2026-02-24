local M = {}
function M.get_selected_text()
  local mode = vim.api.nvim_get_mode().mode

  -- Check if we are in any Visual Mode (v, V, or Ctrl-V)
  if vim.tbl_contains({ 'v', 'V', '\22' }, mode) then
    -- Get the start and end positions
    local _, s_row, s_col, _ = unpack(vim.fn.getpos 'v')
    local _, e_row, e_col, _ = unpack(vim.fn.getpos '.')

    -- Normalize range: ensure start is before end
    if s_row > e_row or (s_row == e_row and s_col > e_col) then
      s_row, e_row = e_row, s_row
      s_col, e_col = e_col, s_col
    end

    -- Special handling for Visual Line Mode (V)
    -- If in 'V', we want the whole line from column 1 to the end
    if mode == 'V' then
      s_col = 1
      e_col = #vim.api.nvim_buf_get_lines(0, e_row - 1, e_row, false)[1]
    end

    -- Get text (0-indexed)
    local lines = vim.api.nvim_buf_get_text(0, s_row - 1, s_col - 1, e_row - 1, e_col, {})
    return table.concat(lines, '\r')
  else
    -- Fallback: Return the word under the cursor
    return vim.fn.expand '<cword>'
  end
end
return M
