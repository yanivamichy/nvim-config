return {
  'epwalsh/obsidian.nvim',
  ft = 'markdown',
  lazy = false,
  -- event = {
  --   'BufReadPre ' .. vim.fn.expand '~' .. '/my-vault/*.md',
  --   'BufNewFile ' .. vim.fn.expand '~' .. '/my-vault/*.md',
  -- },
  dependencies = { 'nvim-lua/plenary.nvim', 'hrsh7th/nvim-cmp', 'nvim-telescope/telescope.nvim' },
  opts = {
    workspaces = {
      {
        name = 'personal',
        path = '~/vaults/personal',
      },
      {
        name = 'work',
        path = '~/vaults/work',
      },
    },
    ui = { enable = false },
    completion = { nvim_cmp = true },
    picker = { name = 'telescope.nvim' },
    templates = nil,
  },
  keys = {
    { '<leader>of', ':ObsidianQuickSwitch<cr>', desc = '[O]bsidian search [F]iles' },
    { '<leader>ot', ':ObsidianTags<cr>', desc = '[O]bsidian search [T]ags' },
    { '<leader>og', ':ObsidianSearch<cr>', desc = '[O]bsidian [G]rep notes' },
    { '<leader>ow', ':ObsidianWorkspace<cr>', desc = '[O]bsidian switch [W]orkspace' },
    { '<leader>on', ':ObsidianNew<cr>', desc = '[O]bsidian [N]ew note' },
    { '<leader>ob', ':ObsidianBacklinks<cr>', desc = '[O]bsidian search [B]acklinks' },
    { '<leader>ot', ':ObsidianToday<cr>', desc = '[O]bsidian open [T]oday note' },
    { '<leader>ol', ':ObsidianLink<cr>', desc = '[O]bsidian [L]link text' },
    { '<leader>oe', ':ObsidianExtract<cr>', desc = '[O]bsidian [E]xtract text' },
  },
}
