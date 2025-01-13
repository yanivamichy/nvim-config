local function prompt_file_edit()
  local file = vim.fn.expand '%'
  local continue = true

  if vim.fn.getfsize(file) >= 1024 * 1024 then
    ---@type string
    local response = vim.fn.input('Are you sure you want to open "' .. file .. '"? [y/n]')
    continue = response == 'y'
  end

  if continue then
    vim.cmd('edit ' .. file)
    vim.cmd('doautocmd BufReadPost ' .. file)
  else
    vim.cmd 'bdelete'
  end
end

vim.api.nvim_create_augroup('bigfiles', { clear = true })
vim.api.nvim_create_autocmd('BufReadCmd', {
  group = 'bigfiles',
  pattern = '*',
  callback = prompt_file_edit,
})
