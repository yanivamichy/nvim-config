return {
  { -- LSP Configuration & Plugins, `:help lsp-vs-treesitter`.
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-nvim-lsp',
      { 'j-hui/fidget.nvim', opts = {} }, -- Useful status updates for LSP.
      -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
      -- used for completion, annotations and signatures of Neovim apis
      {
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
          library = {
            -- Load luvit types when the `vim.uv` word is found
            { path = 'luvit-meta/library', words = { 'vim%.uv' } },
          },
        },
      },
      { 'Bilal2453/luvit-meta', lazy = true },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>lD', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ld', require('telescope.builtin').lsp_document_symbols, '[D]ocument symbols')
          map('<leader>lw', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace symbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          map('gDD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('gDT', vim.lsp.buf.type_definition, '[G]oto [T]ype definition')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
          -- client.server_capabilities.semanticTokensProvider = nil
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
      capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        -- pylsp = {},
        -- jedi_language_server = {},
        -- pylyzer = {},
        -- pyre = {},
        -- ast_grep = {},
        -- harper_ls = {},
        -- mutt_ls = {},
        -- pyright = {},
        -- basedpyright = {},
        -- ruff = {},
        -- ruff_lsp = {},
        basedpyright = {
          settings = {
            pyright = {
              disableOrganizeImports = true,
            },
            python = {
              analysis = {
                diagnosticMode = 'openFilesOnly',
                typeCheckingMode = 'off',
                diagnosticSeverityOverrides = {
                  reportMissingModuleSource = 'error',
                  reportInvalidTypeForm = 'none',
                  reportMissingImports = 'error',
                  reportUndefinedVariable = 'none',
                },
              },
              pythonPath = require('utils.LanguageToolFinders').get_python_env(),
            },
            basedpyright = {
              analysis = {
                typeCheckingMode = 'off',
                diagnosticSeverityOverrides = {
                  reportMissingImports = 'error',
                  reportAttributeAccessIssue = 'error',
                  -- reportMissingTypeStubs = 'none',
                  -- reportImportCycles = 'warning',
                },
              },
            },
          },
        },
        ruff = {
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
        vimls = {},
      }

      local lspconfig = require 'lspconfig'
      require('mason-lspconfig').setup {
        ensure_installed = vim.tbl_keys(servers or {}),
        handlers = {
          function(server_name)
            local server = servers[server_name]
            if not server then
              return
            end
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            lspconfig[server_name].setup(server)
          end,
        },
      }

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
    event = 'InsertEnter',
    opts = {
      bind = true,
      handler_opts = {
        border = 'rounded',
      },
      toggle_key = '<C-k>',
    },
    config = function(_, opts)
      require('lsp_signature').setup(opts)
      vim.keymap.set({ 'n' }, '<M-k>', function()
        require('lsp_signature').toggle_float_win()
      end, { silent = true, noremap = true, desc = 'toggle signature' })
    end,
  },
}
