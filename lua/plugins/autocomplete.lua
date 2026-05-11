return {
  {
    'L3MON4D3/LuaSnip',
    version = '2.*',
    build = (function()
      return 'make install_jsregexp'
    end)(),
    dependencies = {
      {
        'rafamadriz/friendly-snippets',
        config = function()
          require('luasnip.loaders.from_vscode').lazy_load()
        end,
      },
    },
  },

  {
    'SirVer/ultisnips',
    ft = { 'tex', 'plaintex', 'latex' },
    init = function()
      vim.g.UltiSnipsSnippetDirectories = {
        vim.fn.stdpath 'config' .. '/UltiSnips',
      }

      -- -- Use Ctrl-j / Ctrl-k to avoid fighting LazyVim's Tab completion mappings
      -- vim.g.UltiSnipsExpandTrigger = '<c-j>'
      vim.g.UltiSnipsJumpForwardTrigger = '<c-j>'
      vim.g.UltiSnipsJumpBackwardTrigger = '<c-k>'
    end,
  },

  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'folke/lazydev.nvim',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp',
      'mfussenegger/nvim-dap',
      'rcarriga/cmp-dap',
      'quangnguyen30192/cmp-nvim-ultisnips',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      local compare = require 'cmp.config.compare'
      local types = require 'cmp.types'

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-y>'] = cmp.mapping.confirm { select = true },
          ['<C-Space>'] = cmp.mapping.complete {},
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),
        },
        sources = {
          {
            name = 'lazydev',
            group_index = 0, -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
          },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
          -- { name = 'copilot' },
        },
        sorting = {
          priority_weight = 2,
          comparators = {
            compare.offset,
            compare.exact,
            function(e1, e2)
              e1_is_snippet = e1:get_kind() == types.lsp.CompletionItemKind.Snippet
              e2_is_snippet = e2:get_kind() == types.lsp.CompletionItemKind.Snippet
              if e1_is_snippet ~= e2_is_snippet then
                return e1_is_snippet
              end
            end,
            compare.score,
            compare.locality,
            -- compare.kind,
            compare.sort_text,
            compare.length,
            compare.order,
          },
        },
        enabled = function()
          return vim.api.nvim_buf_get_option(0, 'buftype') ~= 'prompt' or require('cmp_dap').is_dap_buffer()
        end,
      }

      cmp.setup.filetype({ 'dap-repl', 'dapui_watches', 'dapui_hover' }, {
        sources = { { name = 'dap' } },
      })
      -- cmp.setup.filetype({ 'tex', 'plaintex', 'latex' }, {
      --   sources = cmp.config.sources { { name = 'ultisnips' } },
      -- })

      cmp.setup.filetype({ 'tex', 'plaintex', 'latex' }, {
        sources = cmp.config.sources({ { name = 'ultisnips' } }, cmp.get_config().sources),
      })
    end,
  },
}
