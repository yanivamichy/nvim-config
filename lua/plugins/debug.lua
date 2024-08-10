return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui', -- Required dependency for nvim-dap-ui
      'nvim-neotest/nvim-nio',
      { 'williamboman/mason.nvim', config = true },
      'jay-babu/mason-nvim-dap.nvim',
      'mfussenegger/nvim-dap-python',
    },
    keys = function(_, keys)
      local dap = require 'dap'
      local dapui = require 'dapui'
      return {
        -- Basic debugging keymaps, feel free to change to your liking!
        { '<F5>', dap.continue, desc = 'Debug: Start/Continue' },
        { '<F11>', dap.step_into, desc = 'Debug: Step Into' },
        { '<F10>', dap.step_over, desc = 'Debug: Step Over' },
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

      -- require('dap-python').setup '~/.local/share/nvim/mason/packages/debugpy/venv/bin/python'
      dap.adapters.python = {
        type = 'executable',
        command = vim.fn.expand '~/.local/share/nvim/mason/packages/debugpy/venv/bin/python',
        args = { '-m', 'debugpy.adapter' },
        options = {
          source_filetype = 'python',
        },
      }
      dap.configurations.python = {
        {
          type = 'python',
          request = 'launch',
          name = 'Launch File',
          console = 'integratedTerminal',
          program = '${file}',
          cwd = '${workspaceFolder}',
          python = function()
            local cwd = vim.fn.getcwd()
            if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
              return cwd .. '/venv/bin/python'
            elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
              return cwd .. '/.venv/bin/python'
            else
              return '/usr/bin/python3'
            end
          end,
          justMyCode = false,
          stopOnEntry = false,
          env = { PYTHONPATH = '${workspaceFolder}' .. ':' .. (os.getenv 'PYTHONPATH' or '') },
        },
      }
    end,
  },
}
