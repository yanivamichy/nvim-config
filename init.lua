-- Type these commands and read through:
-- :Tutor
-- :help
-- :help lua-guide / https://learnxinyminutes.com/docs/lua/
-- :checkhealth
-- "<space>sh" to [s]earch the [h]elp documentation

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = false

require 'options'
require 'keymaps'
require 'autocommands'
require 'commands'

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
-- see :Lazy, update with :Lazy update
require('lazy').setup {
  require 'plugins.telescope',
  require 'plugins.visual',
  require 'plugins.editing',
  require 'plugins.navigation',
  require 'plugins.treesitter',
  require 'plugins.formatter',
  require 'plugins.lsp',
  require 'plugins.autocomplete',
  require 'plugins.luasnip',
  require 'plugins.lint',
  require 'plugins.debug',
  require 'plugins.unittest',
  require 'plugins.terminal',
  require 'plugins.git',
  require 'plugins.markdown',
  require 'plugins.session_manager',
  require 'plugins.remote',
  require 'plugins.dadbod',
}
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
