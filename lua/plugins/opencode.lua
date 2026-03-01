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
        ask = {
          snacks = {
            win = {
              keys = { i_s_cr = false },
            },
          },
        },
      }

      vim.o.autoread = true

      vim.keymap.set({ 'n' }, '<leader>ot', function()
        require('opencode').toggle()
      end, { desc = 'Toggle opencode' })

      vim.keymap.set({ 'x' }, '<leader>oa', function()
        require('opencode').ask('@this: ', { submit = true })
      end, { desc = 'Ask opencode…' })

      vim.keymap.set({ 'n' }, '<leader>oa', function()
        require('opencode').ask('@buffer: ', { submit = true })
      end, { desc = 'Ask opencode…' })

      vim.keymap.set({ 'n', 'x' }, '<leader>os', function()
        require('opencode').select()
      end, { desc = 'Execute opencode action…' })

      vim.keymap.set('n', '<leader>o+', function()
        require('opencode').prompt('@buffer', { append = true })
      end, { desc = 'Add buffer to prompt' })

      vim.keymap.set('v', '<leader>o+', function()
        require('opencode').prompt('@this', { append = true })
      end, { desc = 'Add selection to prompt' })

      vim.keymap.set({ 'n' }, '<leader>oA', function()
        require('opencode').ask('', { append = true })
      end, { desc = 'Append to prompt' })

      vim.keymap.set('n', '<leader>oC', function()
        require('opencode').command 'prompt.clear'
      end, { desc = 'Clear prompt' })

      vim.keymap.set('n', '<leader>oS', function()
        require('opencode').command 'prompt.submit'
      end, { desc = 'Clear prompt' })

      vim.keymap.set('n', '<leader>or', function()
        if require('opencode.config').provider:get().win then
          require('opencode').toggle()
        end
        require('opencode').stop()
        require('opencode.events').disconnect()

        vim.defer_fn(function()
          local buf_dir = vim.fn.expand '%:p:h'
          if buf_dir == '' or vim.fn.isdirectory(buf_dir) == 0 then
            buf_dir = vim.fn.getcwd()
          end
          local orig_cwd = vim.fn.getcwd(0)

          vim.cmd.lcd(vim.fn.fnameescape(buf_dir))
          require('opencode').start()
          vim.cmd.lcd(vim.fn.fnameescape(orig_cwd))
        end, 1000)
      end, { desc = 'Restart opencode in current buffer directory' })
    end,
  },
}
