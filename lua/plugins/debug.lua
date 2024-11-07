return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui', -- Required dependency for nvim-dap-ui
      'nvim-neotest/nvim-nio',
      { 'williamboman/mason.nvim', config = true },
      'jay-babu/mason-nvim-dap.nvim',
      'mfussenegger/nvim-dap-python',
      'nvim-telescope/telescope-dap.nvim',
    },
    keys = function(_, keys)
      local dap = require 'dap'
      local dapui = require 'dapui'
      vim.keymap.set({ 'n', 'v' }, '<F2>', dapui.eval, { desc = 'Debug: Evaluate' })
      local execute_selected = function() -- keymap is <C-F9>
        local mode = vim.fn.mode()
        local lines
        if mode == 'V' then
          lines = vim.fn.getline(vim.fn.getpos('.')[2], vim.fn.getpos('v')[2])
        else
          lines = vim.fn.getregion(vim.fn.getpos '.', vim.fn.getpos 'v')
        end
        dap.repl.execute(table.concat(lines, '\n'))
        local bufnr = dapui.elements.repl.buffer()
        local winid = vim.fn.bufwinid(bufnr)
        vim.api.nvim_win_set_cursor(winid, { vim.api.nvim_buf_line_count(bufnr), 0 })
      end
      vim.keymap.set('x', '<F33>', execute_selected, { desc = 'Debug: Execute selected' })
      vim.keymap.set('x', '<C-F9>', execute_selected, { desc = 'Debug: Execute selected' })

      return {
        -- Basic debugging keymaps, feel free to change to your liking!
        { '<F5>', dap.continue, desc = 'Debug: Start/Continue' },
        { '<F10>', dap.step_over, desc = 'Debug: Step Over' },
        { '<C-F10>', dap.step_into, desc = 'Debug: Step Into' },
        { '<F34>', dap.step_into, desc = 'Debug: Step Into' },
        { '<F3>', dap.step_out, desc = 'Debug: Step Out' },
        { '<F9>', dap.toggle_breakpoint, desc = 'Debug: Toggle Breakpoint' },
        {
          '<F8>',
          function()
            dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
          end,
          desc = 'Debug: Set Breakpoint',
        },
        { '<F7>', dapui.toggle, desc = 'Debug: See last session result.' },
        { '<C-c>', dap.terminate, desc = 'Debug: Terminate' },
        unpack(keys),
      }
    end,
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      require('mason-nvim-dap').setup {
        automatic_installation = true,
        ensure_installed = {
          'python',
        },
      }
      dapui.setup {
        -- Set icons to characters that are more likely to work in every terminal.
        icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
        controls = {
          icons = {
            pause = '⏸',
            play = '▶',
            step_into = '⏎',
            step_over = '⏭',
            step_out = '⏮',
            step_back = 'b',
            run_last = '▶▶',
            terminate = '⏹',
            disconnect = '⏏',
          },
        },
      }

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      require('telescope').load_extension 'dap'
      vim.keymap.set('n', '<leader>df', ':Telescope dap frames<CR>', { desc = '[D]ebug [F]rames' })
      vim.keymap.set('n', '<leader>db', ':Telescope dap list_breakpoints<CR>', { desc = '[D]ebug [B]reakpoints' })

      dap.adapters.python = {
        type = 'executable',
        command = vim.fn.expand '~/.local/share/nvim/mason/packages/debugpy/venv/bin/python',
        args = { '-m', 'debugpy.adapter' },
        options = {
          source_filetype = 'python',
        },
      }
      local ltf = require 'utils.LanguageToolFinders'
      dap.configurations.python = {
        {
          type = 'python',
          request = 'launch',
          name = 'Launch File',
          console = 'integratedTerminal',
          program = '${file}',
          cwd = '${workspaceFolder}',
          python = ltf.get_python_env,
          justMyCode = false,
          stopOnEntry = false,
          env = { PYTHONPATH = '${workspaceFolder}' .. ':' .. (os.getenv 'PYTHONPATH' or '') },
        },
      }
    end,
  },
}
