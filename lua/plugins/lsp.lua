-- vim.lsp.inlay_hint.enable()

local hover = vim.lsp.buf.hover
vim.lsp.buf.hover = function()
  return hover { max_width = 100, max_height = 14, border = 'single' }
end

return {
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {},
  },

  {
    'j-hui/fidget.nvim',
    opts = {},
  },

  {
    'neovim/nvim-lspconfig',
    version = '2.3.0',
    dependencies = {
      'williamboman/mason.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>Lt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype definition')
          map('<leader>Ld', require('telescope.builtin').lsp_document_symbols, '[D]ocument symbols')
          map('<leader>Lw', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace symbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            }) -- highlight references under cursor

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            }) -- clear highlight

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      local servers = {
        basedpyright = {
          settings = {
            python = { pythonPath = require('utils.LanguageToolFinders').get_python_env() },
            basedpyright = {
              -- disableOrganizeImports = true,
              analysis = {
                typeCheckingMode = 'off',
                diagnosticSeverityOverrides = {
                  -- reportArgumentType = 'error',
                  reportMissingModuleSource = 'error',
                  reportImplicitAbstractClass = 'error',
                  reportInvalidTypeForm = 'none',
                  reportUndefinedVariable = 'none',
                  reportMissingImports = 'error',
                  reportAttributeAccessIssue = 'error',
                },
              },
            },
          },
        },
        ruff = {
          init_options = {
            settings = {
              lineLength = 120,
              lint = {
                select = {
                  'E',
                  'W',
                  'F',
                  'I',
                  'B',
                  'A',
                  'N',
                  'COM',
                  'C4',
                  'LOG',
                  'SIM',
                  'TID',
                  'PT',
                  'ASYNC',
                  'SLF',
                  'YTT',
                  'FLY',
                  'PL',
                  'PERF',
                  'UP',
                  'RUF',
                },
                ignore = {
                  'PLR2004',
                  'UP045',
                  'B905',
                },
              },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },
        -- vimls = {},
        harper_ls = {},
      }
      require('mason-tool-installer').setup { ensure_installed = vim.tbl_keys(servers or {}) }

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
      capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true
      capabilities = vim.tbl_deep_extend('force', capabilities, {
        offsetEncoding = { 'utf-16' },
        general = {
          positionEncodings = { 'utf-16' },
        },
      })

      local lspconfig = require 'lspconfig'
      for server, config in pairs(servers) do
        config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, config.capabilities or {})
        lspconfig[server].setup(config)
      end

      local hover = vim.lsp.buf.hover
      vim.lsp.buf.hover = function()
        return hover { max_width = 100, max_height = 14, border = 'single' }
      end
      vim.api.nvim_set_hl(0, '@lsp.type.namespace.python', { fg = '#4EC9B0', bg = 'NONE' })
      vim.api.nvim_set_hl(0, '@lsp.type.function.python', { fg = '#DCDCAA', bg = 'NONE' })
      vim.api.nvim_set_hl(0, '@lsp.type.method.python', { fg = '#DCDCAA', bg = 'NONE' })
      vim.api.nvim_set_hl(0, '@lsp.typemod.function.defaultLibrary.python', { fg = '#DCDCAA', bg = 'NONE' })
      vim.api.nvim_set_hl(0, '@lsp.type.decorator.python', { fg = '#DCDCAA', bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'pythonInclude', { fg = '#BB9AF7', bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'pythonOperator', { fg = '#7aa2f7', bg = 'NONE' })
      -- vim.api.nvim_set_hl(0, 'pythonStatement', { fg = '#7aa2f7', bg = 'NONE' })
      vim.api.nvim_set_hl(0, '@lsp.type.variable.python', { fg = '#70d6ff', bg = 'NONE' })
      -- vim.api.nvim_set_hl(0, '@lsp.type.class.python', { fg = '#4FC1FF', bg = 'NONE' })
    end,
  },

  {
    'ray-x/lsp_signature.nvim',
    keys = {
      {
        '<C-k>',
        function()
          require('lsp_signature').toggle_float_win()
        end,
        mode = 'i',
        desc = 'Toggle LSP Signature',
      },
    },
    opts = {
      bind = true,
      handler_opts = {
        border = 'rounded',
      },
      floating_window = true,
      toggle_key_flip_floatwin_setting = true,
    },
  },

  -- {
  --   'kevinhwang91/nvim-bqf',
  --   config = function()
  --     require('bqf').setup()
  --   end,
  -- },

  -- {
  --   'stevearc/qf_helper.nvim',
  --   opts = {},
  -- },

  -- {
  --   'stevearc/quicker.nvim',
  --   opts = {},
  -- },
}
