local preview_highlight = vim.api.nvim_create_namespace 'preview_highlight'
local function previewed_float(elem_name, float_args)
  require('nio').run(function()
    local dapui = require 'dapui'
    local config = {}
    for key, value in pairs(float_args) do
      config[key] = value
    end
    config.width = math.floor(config.width / 2)
    config.position =
      { line = (vim.o.lines - vim.o.cmdheight - config.height) / 2, col = vim.o.columns / 2 - config.width - 3 }

    local ok, task = pcall(dapui.float_element, elem_name, config)
    if not ok or not task then
      return
    end
    task.wait()

    local element = dapui.elements[elem_name]
    local _, window = pcall(require('dapui.windows').open_float, elem_name)

    if window and vim.api.nvim_win_is_valid(window.win_id) then
      config = vim.api.nvim_win_get_config(window.win_id)
      config.col = config.col + config.width + 2
      config.style = 'minimal'
      config.title = 'Preview'

      local preview_buf = vim.api.nvim_create_buf(false, true)
      local preview_win = vim.api.nvim_open_win(preview_buf, false, config)
      local augroup = vim.api.nvim_create_augroup('PreviewFloat_' .. tostring(preview_buf), { clear = true })
      vim.api.nvim_create_autocmd('CursorMoved', {
        group = augroup,
        buffer = element.buffer(),
        callback = function()
          local cursor = vim.api.nvim_win_get_cursor(0)
          local link = element.canvas.links[cursor[1]]
          if link ~= nil then
            local filetype = vim.filetype.match { filename = link.path }
            local lines = vim.fn.readfile(link.path)
            vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)
            vim.bo[preview_buf].filetype = filetype
            vim.api.nvim_buf_clear_namespace(preview_buf, preview_highlight, 0, -1)
            vim.api.nvim_buf_add_highlight(preview_buf, preview_highlight, 'Visual', link.line - 1, 0, -1) -- TODO: fix here
            vim.api.nvim_win_call(preview_win, function()
              vim.api.nvim_win_set_cursor(preview_win, { link.line, 1 })
              vim.cmd 'normal! zz'
            end)
          else
            vim.bo[preview_buf].buftype = 'nofile'
            vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, {
              '<no link>',
            })
          end
        end,
      })
      vim.api.nvim_create_autocmd('BufLeave', {
        group = augroup,
        buffer = element.buffer(),
        callback = function()
          pcall(vim.api.nvim_buf_delete, preview_buf, { force = true })
          pcall(vim.api.nvim_win_close, preview_win, { force = true })
          vim.api.nvim_del_augroup_by_id(augroup)
        end,
      })
    end
  end)
end

return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'yanivamichy/nvim-dap-ui',
      'jay-babu/mason-nvim-dap.nvim',
      'mfussenegger/nvim-dap-python',
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

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
        layouts = {
          {
            elements = {
              {

                id = 'repl',
                size = 0.5,
              },
              {
                id = 'console',
                size = 0.5,
              },
            },
            position = 'bottom',
            size = 10,
          },
        },
        element_mappings = {
          stacks = { open = '<CR>', expand = 'o' },
          breakpoints = { open = '<CR>', expand = 'o' },
        },
        floating = {
          border = 'rounded',
        },
      }
      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      vim.keymap.set('n', '<F4>', dap.pause, { desc = 'Debug: Pause' })
      vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
      vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<C-F10>', dap.step_into, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
      vim.keymap.set('n', '<F9>', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
      vim.keymap.set('n', '<F8>', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end, { desc = 'Debug: Set Breakpoint' })
      vim.keymap.set('n', '<C-c>', dap.terminate, { desc = 'Debug: Terminate' })
      vim.keymap.set({ 'n', 'v' }, '<F2>', dapui.eval, { desc = 'Debug: Evaluate' })
      vim.keymap.set('v', '<C-F9>', function()
        local lines = vim.fn.getregion(vim.fn.getpos '.', vim.fn.getpos 'v', { type = vim.fn.mode() })
        dap.repl.execute(table.concat(lines, '\n'))
      end, { desc = 'Debug: Execute selected' })

      local float_args = {
        width = math.floor(vim.o.columns * 0.9),
        height = math.floor(vim.o.lines * 0.8),
        enter = true,
        position = 'center',
      }

      vim.keymap.set('n', '<leader>dS', function()
        previewed_float('stacks', float_args)
      end, { desc = 'Debug: Stacks.' })
      vim.keymap.set('n', '<leader>ds', function()
        dapui.float_element('scopes', float_args)
      end, { desc = 'Debug: Scopes.' })
      vim.keymap.set('n', '<leader>dw', function()
        dapui.float_element('watches', float_args)
      end, { desc = 'Debug: Watches.' })
      vim.keymap.set('n', '<leader>db', function()
        previewed_float('breakpoints', float_args)
      end, { desc = 'Debug: Breakpoints.' })
      vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: Toggle UI.' })

      require('mason-nvim-dap').setup {
        automatic_installation = true,
        ensure_installed = {
          'python',
        },
      }

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
          python = require('utils.LanguageToolFinders').get_python_env,
          justMyCode = false,
          stopOnEntry = false,
          env = { PYTHONPATH = '${workspaceFolder}' .. ':' .. (os.getenv 'PYTHONPATH' or '') },
        },
      }
    end,
  },
}
