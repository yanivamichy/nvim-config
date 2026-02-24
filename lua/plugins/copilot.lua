return {
  {
    'github/copilot.vim',
    event = 'InsertEnter',
    config = function()
      -- Disable default Tab mapping
      vim.g.copilot_no_tab_map = true

      -- Custom accept key (recommended)
      vim.keymap.set('i', '<M-y>', 'copilot#Accept("<CR>")', {
        expr = true,
        replace_keycodes = false,
      })
    end,
  },

  {
    'zbirenbaum/copilot-cmp',
    dependencies = { 'github/copilot.vim' },
    config = function()
      require('copilot_cmp').setup()
    end,
  },
}
