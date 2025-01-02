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

--  Navigate tabs / buffers
vim.keymap.set('n', '<M-h>', ':tabprev<CR>', { desc = 'Move to the previous tab' })
vim.keymap.set('n', '<M-l>', ':tabnext<CR>', { desc = 'Move to the next tab' })
vim.keymap.set('n', '<M-t>', ':tabnew<CR>', { desc = 'Open new tab' })
vim.keymap.set('n', '<M-w>', ':bd<CR>', { desc = 'Close buffer' })

-- toggle comment
vim.keymap.set('n', '<C-_>', 'gcc', { remap = true, desc = 'toggle comment' })
vim.keymap.set('v', '<C-_>', 'gc', { remap = true, desc = 'toggle multiple comment' })

-- mapping deleting and cutting
vim.keymap.set({ 'n', 'v' }, ',p', '"+p')
vim.keymap.set({ 'n', 'v' }, ',P', '"+P')
vim.keymap.set({ 'n', 'v' }, ',y', '"+y', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'v' }, 'x', '"_x')
vim.keymap.set({ 'n', 'v' }, 'X', '"_X')

-- increase/decrease split window size
vim.keymap.set('n', '<M-up>', ':res+1<CR>', { desc = 'Increase split window height' })
vim.keymap.set('n', '<M-down>', ':res-1<CR>', { desc = 'Decrease split window height' })
vim.keymap.set('n', '<M-right>', ':vert res+1<CR>', { desc = 'Increase split window width' })
vim.keymap.set('n', '<M-left>', ':vert res-1<CR>', { desc = 'Decrease split window width' })

-- set undo breakpoints
vim.keymap.set('i', '<space>', '<C-G>u<space>', { noremap = true, silent = true })
vim.keymap.set('i', '<CR>', '<C-G>u<CR>', { noremap = true, silent = true })
vim.keymap.set('i', '.', '<C-G>u.', { noremap = true, silent = true })
vim.keymap.set('i', ',', '<C-G>u,', { noremap = true, silent = true })
vim.keymap.set('i', '(', '<C-G>u(', { noremap = true, silent = true })
vim.keymap.set('i', '<', '<C-G>u<', { noremap = true, silent = true })
vim.keymap.set('i', '[', '<C-G>u[', { noremap = true, silent = true })
vim.keymap.set('i', '{', '<C-G>u{', { noremap = true, silent = true })
