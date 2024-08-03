-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '<leader>b', ':Neotree reveal<CR>', desc = 'Open File Tree' },
  },
  opts = {
    default_component_configs = {
      git_status = {
        symbols = false,
      },
    },
    filesystem = {
      symbols = false,
      filtered_items = {
        visible = true,
      },
      window = {
        mappings = {
          ['<leader>b'] = 'close_window',
        },
      },
    },
  },
}
