local M = {}
function M.get_python_env()
  local cwd = vim.fn.getcwd()
  local relative_paths = {
    '/venv/bin/python',
    '/.venv/bin/python',
    '/.venv/Scripts/python',
    '/venv/Scripts/python.exe',
    '/.venv/Scripts/python.exe',
  }
  for _, relative_path in ipairs(relative_paths) do
    local abs_path = cwd .. relative_path
    if vim.fn.executable(abs_path) == 1 then
      return abs_path
    end
  end
  return vim.fn.exepath("python3")
end
return M
