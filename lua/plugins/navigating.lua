local function get_buf_by_name(name)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local buf_name = vim.api.nvim_buf_get_name(buf)
    vim.api.nvim_echo({ { tostring(buf_name), 'Normal' } }, true, {})
    if buf_name == name then
      return buf
    end
  end
  return nil
end

return {
  {
    'stevearc/oil.nvim',
    opts = {},
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('oil').setup {
        keymaps = {
          ['q'] = 'actions.close',
          ['<BS>'] = 'actions.parent',
        },
        win_options = {
          signcolumn = 'yes:2',
        },
        columns = {
          -- 'permissions',
          -- 'size',
          -- 'mtime',
        },
        view_options = { show_hidden = true },
      }
      vim.keymap.set('n', '-', ':Oil --float<CR>', { desc = 'Open parent directory' })
    end,
  },

  {
    'refractalize/oil-git-status.nvim',
    dependencies = { 'stevearc/oil.nvim' },
    config = true,
  },

  -- {
  --   'ThePrimeagen/harpoon',
  --   branch = 'harpoon2',
  --   dependencies = { 'nvim-lua/plenary.nvim' },
  -- },

  {
    'AndrewRadev/bufferize.vim',
    keys = {
      {
        '<leader>m',
        -- ':Bufferize messages<CR>:res 40<CR>:set wfh<CR>',
        function()
          local command = 'messages'
          local bufnr = get_buf_by_name('Bufferize: ' .. command)

          -- vim.api.nvim_list_bufs()

          -- vim.api.nvim_buf_get_name
          -- vim.fn.bufname()
          vim.cmd 'Bufferize messages'
          -- vim.api.nvim_echo({ { 'Bufferize: ' .. command, 'Normal' } }, true, {})
          -- vim.api.nvim_echo({ { tostring(bufnr), 'Normal' } }, true, {})

          --   vim.api.cmd 'Bufferize messages<CR>'
        end,
        desc = 'Open [M]essages',
      },
    },
    -- config = function()
    -- require('bufferize.vim').setup()
    -- vim.keymap.set('n', '<leader>m', function()
    --   vim.api.nvim_command 'Bufferize messages'
    -- end, { desc = 'Open [M]essages' })
    -- end,
  },
  { 'tpope/vim-scriptease' },
  -- {
  --   'AckslD/messages.nvim',
  --   config = function()
  --     require('messages').setup()
  --     Msg = function(...)
  --       require('messages.api').capture_thing(...)
  --     end
  --   end,
  --   keys = {
  --     {
  --       '<leader>m',
  --       ':Messages messages<CR>',
  --       desc = 'Display [M]essages in buffer',
  --     },
  --   },
  -- },
}
