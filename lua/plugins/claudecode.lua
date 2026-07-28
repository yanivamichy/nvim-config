return {
  {
    'coder/claudecode.nvim',
    dependencies = { 'folke/snacks.nvim' },
    opts = {
      terminal = {
        auto_insert = false,
      },
    },
    -- `cmd` lets lazy.nvim create command stubs that load the plugin on first use,
    -- so `:ClaudeCode` and friends work on a fresh start. Without it, a keys-only
    -- spec defers loading until a <leader>a* mapping is pressed and the commands
    -- would not exist yet.
    cmd = {
      'ClaudeCode',
      'ClaudeCodeFocus',
      'ClaudeCodeSelectModel',
      'ClaudeCodeAdd',
      'ClaudeCodeSend',
      'ClaudeCodeTreeAdd',
      'ClaudeCodeStatus',
      'ClaudeCodeStart',
      'ClaudeCodeStop',
      'ClaudeCodeOpen',
      'ClaudeCodeClose',
      'ClaudeCodeDiffAccept',
      'ClaudeCodeDiffDeny',
      'ClaudeCodeCloseAllDiffs',
    },
    keys = {
      { '<leader>O', nil, desc = 'AI/Claude Code' },
      { '<leader>Ot', '<cmd>ClaudeCode<cr>', desc = 'Toggle Claude' },
      -- { '<leader>af', '<cmd>ClaudeCodeFocus<cr>', desc = 'Focus Claude' },
      -- { '<leader>ar', '<cmd>ClaudeCode --resume<cr>', desc = 'Resume Claude' },
      -- { '<leader>aC', '<cmd>ClaudeCode --continue<cr>', desc = 'Continue Claude' },
      -- { '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', desc = 'Select Claude model' },
      { '<leader>Oa', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Add current buffer' },
      -- { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send to Claude' },
      {
        '<leader>OT',
        '<cmd>ClaudeCodeTreeAdd<cr>',
        desc = 'Add file',
        ft = { 'NvimTree', 'neo-tree', 'oil', 'minifiles', 'netrw', 'snacks_picker_list' },
      },
      -- Diff management
      { '<leader>OA', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept diff' },
      { '<leader>OD', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Deny diff' },
    },
  },
}
