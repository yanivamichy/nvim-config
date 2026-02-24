vim.api.nvim_create_autocmd('VimLeavePre', {
  callback = function()
    vim.fn.system { 'pkill', '-f', 'opencode.*--port 14500' }
  end,
})

return {
  {
    'nickjvandyke/opencode.nvim',
    version = '*', -- Latest stable release
    dependencies = { 'folke/snacks.nvim' },
    config = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        -- lsp = { enabled = true },
        port = 14500,
      }

      vim.o.autoread = true -- Required for `opts.events.reload`

      vim.keymap.set({ 'n' }, '<leader>ot', function()
        require('opencode').toggle()
      end, { desc = 'Toggle opencode' })

      vim.keymap.set({ 'x' }, '<leader>oa', function()
        require('opencode').ask('@this: ', { submit = true })
      end, { desc = 'Ask opencode…' })

      vim.keymap.set({ 'n' }, '<leader>oa', function()
        require('opencode').ask('@buffer: ', { submit = true })
      end, { desc = 'Ask opencode…' })

      vim.keymap.set({ 'n', 'x' }, '<leader>oe', function()
        require('opencode').select()
      end, { desc = 'Execute opencode action…' })

      -- vim.keymap.set({ 'n', 'x' }, '<leader>op', function()
      --   require('opencode').prompt('@this:')
      -- end, { desc = 'Execute opencode action…' })
    end,
  },
}
