return {
  { -- Lua LSP support for the Neovim config, runtime and plugins
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  { -- LSP status updates
    'j-hui/fidget.nvim',
    event = 'LspAttach',
    opts = {},
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    config = function()
      -- csharp_ls (a dotnet tool) needs this to find the .NET SDKs in ~/.dotnet
      local dotnet_root = vim.fs.normalize '~/.dotnet'
      if not vim.env.DOTNET_ROOT and vim.uv.fs_stat(dotnet_root) then
        vim.env.DOTNET_ROOT = dotnet_root
        vim.env.PATH = dotnet_root .. ':' .. vim.env.PATH
      end

      -- Neovim 0.11+ ships default LSP keymaps:
      --   grn rename, gra code action, grr references, gri implementation,
      --   grt type definition, gO document symbols, K hover, <C-s> signature help (insert)
      -- Below we point the "list" ones at the snacks picker instead of the quickfix list.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            vim.keymap.set(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', function()
            Snacks.picker.lsp_definitions()
          end, '[G]oto [D]efinition')
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('grr', function()
            Snacks.picker.lsp_references()
          end, '[G]oto [R]eferences')
          map('gri', function()
            Snacks.picker.lsp_implementations()
          end, '[G]oto [I]mplementation')
          map('grt', function()
            Snacks.picker.lsp_type_definitions()
          end, '[G]oto [T]ype Definition')
          map('gO', function()
            Snacks.picker.lsp_symbols()
          end, 'Document Symbols')
          map('gW', function()
            Snacks.picker.lsp_workspace_symbols()
          end, '[W]orkspace Symbols')

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- Highlight references of the word under the cursor after it rests there a moment
          if client and client:supports_method('textDocument/documentHighlight', event.buf) then
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

          if client and client:supports_method('textDocument/inlayHint', event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Language servers to install and enable. Overrides are merged on top of the
      -- defaults nvim-lspconfig ships (see `:help lspconfig-all`).
      -- Completion capabilities are added automatically by blink.cmp.
      local servers = {
        bashls = {},
        clangd = {},
        cmake = {},
        csharp_ls = {},
        cssls = {},
        dockerls = {},
        gopls = {},
        html = {},
        jsonls = {},
        rust_analyzer = {},
        -- vue_ls only handles templates/styles; TypeScript in .vue files goes through
        -- ts_ls with the Vue plugin (bundled with Mason's vue-language-server)
        ts_ls = {
          filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' },
          init_options = {
            plugins = {
              {
                name = '@vue/typescript-plugin',
                location = vim.fn.stdpath 'data' .. '/mason/packages/vue-language-server/node_modules/@vue/language-server',
                languages = { 'vue' },
              },
            },
          },
        },
        vue_ls = {},
        zls = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
            },
          },
        },
      }

      -- Formatters and linters used by conform.nvim and nvim-lint
      local tools = { 'stylua', 'prettierd', 'eslint_d', 'shfmt', 'clang-format', 'goimports' }

      require('mason-tool-installer').setup {
        ensure_installed = vim.list_extend(vim.tbl_keys(servers), tools),
      }
      -- Servers are enabled below, so mason-lspconfig only needs to map names
      require('mason-lspconfig').setup { automatic_enable = false }

      for name, config in pairs(servers) do
        vim.lsp.config(name, config)
        vim.lsp.enable(name)
      end
    end,
  },
}
