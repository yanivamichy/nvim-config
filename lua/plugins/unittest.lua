return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/neotest-python',
    },

    config = function()
      local neotest = require 'neotest'
      neotest.setup {
        adapters = {
          require 'neotest-python' {
            dap = {
              justMyCode = false,
              console = 'integratedTerminal',
            },
            args = { '--log-level', 'DEBUG', '--quiet' },
            runner = 'pytest',
          },
        },
        vim.keymap.set('n', '<leader>ur', "<cmd>lua require('neotest').run.run()<cr>", { desc = '[U]nit test nearest [T]est' }),
        vim.keymap.set('n', '<leader>uR', "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>", { desc = 'Debug - [U]nit test nearest [T]est' }),
        vim.keymap.set('n', '<leader>uf', "<cmd>lua require('neotest').run.run({vim.fn.expand('%')})<cr>", { desc = 'Run all [U]nit tests in [F]ile' }),
        vim.keymap.set('n', '<leader>uw', "<cmd>lua require('neotest').run.run(vim.fn.getcwd())<cr>", { desc = 'Run all [U]nit tests in [W]orkspace' }),
        vim.keymap.set('n', '<leader>ua', "<cmd>lua require('neotest').run.stop(vim.fn.getcwd())<cr>", { desc = '[A]bort all [U]nit tests' }),
        vim.keymap.set('n', '<leader>us', "<cmd>lua require('neotest').summary.toggle()<cr>", { desc = '[U]nit tests [S]ummary toggle' }),
      }
    end,
  },
}
