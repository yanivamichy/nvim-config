local M = {}
function M.get_python_env()
  local cwd = vim.fn.getcwd()
  vim.api.nvim_echo({ { cwd, 'Normal' } }, true, {})
  if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
    return cwd .. '/venv/bin/python'
  elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
    return cwd .. '/.venv/bin/python'
  else
    return '/usr/bin/python3'
  end
end

return M
