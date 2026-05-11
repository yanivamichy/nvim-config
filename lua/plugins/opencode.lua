vim.api.nvim_create_autocmd('VimLeavePre', {
  callback = function()
    vim.fn.system { 'pkill', '-f', 'opencode.*--port 14500' }
  end,
})

return {
  -- {
  --   'Cannon07/code-preview.nvim',
  --   config = function()
  --     require('code-preview').setup {
  --       diff = { layout = 'inline' },
  --     }
  --   end,
  -- },

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

  -- {
  --   'sudo-tee/opencode.nvim',
  --   dependencies = {
  --     'nvim-lua/plenary.nvim',
  --     'MeanderingProgrammer/render-markdown.nvim',
  --     'hrsh7th/nvim-cmp',
  --     'folke/snacks.nvim',
  --   },
  --   config = function()
  --     require('opencode').setup {
  --       preferred_picker = 'telescope',
  --       default_mode = 'plan',
  --       default_global_keymaps = false,
  --       server = { port = 14500 },
  --       keymap = {
  --         editor = {
  --           ['<leader>ot'] = { 'toggle' },
  --           ['<leader>oT'] = { 'timeline' },
  --           ['<leader>os'] = { 'select_session' },
  --           ['<leader>op'] = { 'configure_provider' },
  --           ['<leader>oV'] = { 'configure_variant' },
  --           ['<leader>oy'] = { 'add_visual_selection', mode = { 'v' } },
  --           ['<leader>oY'] = { 'add_visual_selection_inline', mode = { 'v' } },
  --           ['<leader>oz'] = { 'toggle_zoom' },
  --           -- ['<leader>od'] = { 'diff_open' },
  --           -- ['<leader>o]'] = { 'diff_next' },
  --           -- ['<leader>o['] = { 'diff_prev' },
  --           -- ['<leader>oc'] = { 'diff_close' },
  --         },
  --         input_window = {
  --           ['<C-cr>'] = { 'submit_input_prompt', mode = 'i' },
  --           ['<C-c>'] = { 'cancel', defer_to_completion = true },
  --           ['~'] = { 'mention_file', mode = 'i' },
  --           ['@'] = { 'mention', mode = 'i' },
  --           ['/'] = { 'slash_commands', mode = 'i' },
  --           ['#'] = { 'context_items', mode = 'i' },
  --           ['<up>'] = { 'prev_prompt_history', mode = { 'n', 'i' }, defer_to_completion = true },
  --           ['<down>'] = { 'next_prompt_history', mode = { 'n', 'i' }, defer_to_completion = true },
  --           ['<Tab>'] = { 'switch_mode', mode = 'i' },
  --           -- ['<M-r>'] = { 'cycle_variant', mode = 'i' },
  --         },
  --         output_window = {
  --           ['<C-c>'] = { 'cancel' },
  --           [']]'] = { 'next_message' },
  --           ['[['] = { 'prev_message' },
  --           ['i'] = { 'focus_input', 'n' },
  --           -- ['<leader>oD'] = { 'debug_message' },
  --           -- ['<leader>oO'] = { 'debug_output' },
  --           -- ['<leader>ods'] = { 'debug_session' },
  --         },
  --       },
  --       ui = {
  --         icons = {
  --           -- preset = 'text',
  --         },
  --       },
  --     }
  --   end,
  -- },

  -- {
  --   'olimorris/codecompanion.nvim',
  --   dependencies = {
  --     'nvim-lua/plenary.nvim',
  --     'nvim-treesitter/nvim-treesitter',
  --   },
  --   opts = {
  --     interactions = {
  --       chat = {
  --         adapter = 'opencode',
  --       },
  --     },
  --   },
  -- },
  --
  -- {
  --   'yetone/avante.nvim',
  --   build = 'make',
  --   event = 'VeryLazy',
  --   version = false,
  --   opts = {
  --     mode = 'agentic',
  --     input = {
  --       provider = 'snacks',
  --     },
  --     provider = 'opencode',
  --     acp_providers = {
  --       opencode = {
  --         command = 'opencode',
  --         args = { 'acp' },
  --       },
  --     },
  --     behaviour = {
  --       auto_apply_diff_after_generation = false, -- Don't auto-apply changes
  --       enable_cursor_planning_mode = true, -- Enable cursor-like review
  --       auto_approve_tool_permissions = false, -- Require manual approval for edits
  --       confirmation_ui_style = 'inline_buttons', -- Nice UI for accept/reject
  --       minimize_diff = true, -- Hide unchanged lines in diff
  --       auto_set_keymaps = true,
  --       auto_set_highlight_group = true,
  --     },
  --     diff = {
  --       autojump = true, -- Jump to diff after generation
  --       override_timeoutlen = 500,
  --     },
  --   },
  --   dependencies = {
  --     'nvim-lua/plenary.nvim',
  --     'MunifTanjim/nui.nvim',
  --   },
  -- },

  -- {
  --   'folke/sidekick.nvim',
  --   opts = {
  --     nes = { enabled = false },
  --     cli = {
  --       tools = {
  --         opencode = {},
  --       },
  --       mux = {
  --         backend = 'tmux',
  --         enabled = false,
  --       },
  --     },
  --   },
  --   keys = {
  --     {
  --       '<leader>ot',
  --       function()
  --         require("sidekick.cli").toggle({ name = "opencode", focus = false })
  --       end,
  --       desc = 'Sidekick Toggle CLI',
  --     },
  --     {
  --       '<leader>oa',
  --       function()
  --         require('sidekick.cli').prompt()
  --       end,
  --       mode = { 'n', 'x' },
  --       desc = 'Sidekick Select Prompt',
  --     },
  --   },
  -- },
}
