return {
  {
    'lervag/vimtex',
    init = function()
      -- vim.g.vimtex_view_method = 'zathura'
      vim.g.vimtex_view_method = 'general'
      vim.g.vimtex_view_general_viewer = 'xdg-open'
      -- vim.g.vimtex_complete_enabled = 0
      vim.g.vimtex_imap_enabled = 0
    end,
  },
  {
    'let-def/texpresso.vim',
    init = function()
      vim.keymap.set('n', '<leader>lP', ':TeXpresso %<cr>', { desc = '[P]review latex file' })
    end,
  },
}
