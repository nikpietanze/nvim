-- Debugging with nvim-dap: C# (netcoredbg), JS/TS/Vue (js-debug-adapter) and Go (delve)
return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    'leoluz/nvim-dap-go',
  },
  keys = {
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F1>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<F2>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>db',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Toggle [B]reakpoint',
    },
    {
      '<leader>dB',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Conditional [B]reakpoint',
    },
    {
      '<leader>dt',
      function()
        require('dap').terminate()
      end,
      desc = '[T]erminate session',
    },
    {
      '<leader>du',
      function()
        require('dapui').toggle()
      end,
      desc = 'Toggle debug [U]I',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'
    local mason_bin = vim.fn.stdpath 'data' .. '/mason/bin/'

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      handlers = {}, -- adapters are configured below
      ensure_installed = { 'js-debug-adapter', 'delve' },
    }

    dapui.setup()
    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- C#: attach to a running app (e.g. Appbar.Marketing started by Aspire) or launch a built dll
    -- Mason's netcoredbg is Intel-only on macOS, so this uses Samsung's native arm64 build
    -- installed to ~/.local/share/netcoredbg (github.com/Samsung/netcoredbg/releases)
    dap.adapters.coreclr = {
      type = 'executable',
      command = vim.fs.normalize '~/.local/share/netcoredbg/netcoredbg/netcoredbg',
      args = { '--interpreter=vscode' },
    }
    dap.configurations.cs = {
      {
        type = 'coreclr',
        name = 'Attach to running .NET process',
        request = 'attach',
        processId = function()
          -- Only real app executables (…/bin/<tfm>/Name), not the `dotnet run` wrappers
          return require('dap.utils').pick_process {
            filter = function(proc)
              return proc.name:match '/bin/[^ ]-/[%w%.]+$' ~= nil and not proc.name:match '^dotnet '
            end,
          }
        end,
      },
      {
        type = 'coreclr',
        name = 'Launch dll (current project)',
        request = 'launch',
        cwd = function()
          return vim.fs.root(0, function(name)
            return name:match '%.csproj$' ~= nil
          end) or vim.fn.getcwd()
        end,
        program = function()
          local root = vim.fs.root(0, function(name)
            return name:match '%.csproj$' ~= nil
          end) or vim.fn.getcwd()
          local project = vim.fn.fnamemodify(vim.fn.glob(root .. '/*.csproj', false, true)[1] or '', ':t:r')
          local dll = vim.fn.glob(root .. '/bin/**/' .. project .. '.dll', false, true)[1]
          return vim.fn.input('Path to dll: ', dll or (root .. '/bin/'), 'file')
        end,
        env = { ASPNETCORE_ENVIRONMENT = 'Development' },
      },
    }

    -- JS/TS/Vue (Node): launch the current file, or attach to `node --inspect` (e.g. Nuxt server)
    dap.adapters['pwa-node'] = {
      type = 'server',
      host = 'localhost',
      port = '${port}',
      executable = { command = mason_bin .. 'js-debug-adapter', args = { '${port}' } },
    }
    for _, ft in ipairs { 'javascript', 'typescript', 'vue' } do
      dap.configurations[ft] = {
        { type = 'pwa-node', request = 'launch', name = 'Launch current file (Node)', program = '${file}', cwd = '${workspaceFolder}' },
        { type = 'pwa-node', request = 'attach', name = 'Attach to node --inspect (:9229)', port = 9229, cwd = '${workspaceFolder}' },
        { type = 'pwa-node', request = 'attach', name = 'Attach to Node process', processId = require('dap.utils').pick_process, cwd = '${workspaceFolder}' },
      }
    end

    -- Go
    require('dap-go').setup()
  end,
}
