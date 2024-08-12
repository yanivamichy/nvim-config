-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

--  Navigate tabs
vim.keymap.set('n', '<M-h>', ':tabprev<CR>', { desc = 'Move to the previous tab' })
vim.keymap.set('n', '<M-l>', ':tabnext<CR>', { desc = 'Move to the next tab' })
vim.keymap.set('n', '<M-t>', ':tabnew<CR>', { desc = 'Open new tab' })
vim.keymap.set('n', '<M-w>', ':tabc<CR>', { desc = 'Close tab' })

-- toggle comment
vim.keymap.set('n', '<C-_>', 'gcc', { remap = true, desc = 'toggle comment' })
vim.keymap.set('v', '<C-_>', 'gc', { remap = true, desc = 'toggle multiple comment' })

-- mapping deleting and cutting
vim.keymap.set('n', '<M-x>', 'x')
vim.keymap.set({ 'n', 'v' }, '<M-d>', 'd')
vim.keymap.set('n', '<M-D>', 'D')
vim.keymap.set('n', 'x', '"_x')
vim.keymap.set({ 'n', 'v' }, 'd', '"_d')
vim.keymap.set('n', 'D', '"_D')
vim.keymap.set('n', 'cw', '"_cw')
vim.keymap.set('n', '<M-c>w', 'cw')

-- increase/decrease split window size
vim.keymap.set('n', '<C-up>', ':res+1<CR>', { desc = 'Increase split window height' })
vim.keymap.set('n', '<C-down>', ':res-1<CR>', { desc = 'Decrease split window height' })
vim.keymap.set('n', '<C-right>', ':vert res+1<CR>', { desc = 'Increase split window width' })
vim.keymap.set('n', '<C-left>', ':vert res-1<CR>', { desc = 'Decrease split window width' })

-- Set local settings for terminal buffers
-- local set = vim.opt_local
-- vim.api.nvim_create_autocmd('TermOpen', {
--   group = vim.api.nvim_create_augroup('custom-term-open', {}),
--   callback = function()
--     set.number = false
--     set.relativenumber = false
--     set.scrolloff = 0
--   end,
-- })
--
-- vim.keymap.set('n', '<leader>tt', function()
--   vim.cmd.new()
--   vim.cmd.wincmd 'J'
--   vim.api.nvim_win_set_height(0, 12)
--   vim.wo.winfixheight = true
--   vim.cmd.term()
-- end, { desc = '[T]oggle [T]erminal' })
