return {
  { -- Jump anywhere on screen: press `s` then the characters you see
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {},
    keys = {
      {
        's',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').jump()
        end,
        desc = 'Flash jump',
      },
      {
        'S',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').treesitter()
        end,
        desc = 'Flash select treesitter node',
      },
    },
  },

  { -- Pin the current function/class signature at the top while scrolling
    'nvim-treesitter/nvim-treesitter-context',
    event = 'VeryLazy',
    opts = { max_lines = 3 },
    keys = {
      {
        '<leader>tc',
        function()
          require('treesitter-context').toggle()
        end,
        desc = '[T]oggle sticky [C]ontext',
      },
    },
  },

  { -- Panels for diagnostics, references, symbols and quickfix
    'folke/trouble.nvim',
    cmd = 'Trouble',
    opts = {},
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (project)' },
      { '<leader>xb', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Diagnostics (buffer)' },
      { '<leader>xs', '<cmd>Trouble symbols toggle focus=false<cr>', desc = 'Symbols outline' },
      { '<leader>xr', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', desc = 'LSP references/definitions' },
      { '<leader>xq', '<cmd>Trouble qflist toggle<cr>', desc = 'Quickfix list' },
      { '<leader>xt', '<cmd>Trouble todo toggle<cr>', desc = 'TODOs' },
    },
  },

  { -- Save open files/splits per directory; restore them on demand
    'folke/persistence.nvim',
    event = 'BufReadPre',
    opts = {},
    keys = {
      {
        '<leader>ps',
        function()
          require('persistence').load()
        end,
        desc = 'Restore [S]ession for this directory',
      },
      {
        '<leader>pS',
        function()
          require('persistence').select()
        end,
        desc = 'Pick a [S]ession',
      },
      {
        '<leader>pl',
        function()
          require('persistence').load { last = true }
        end,
        desc = 'Restore [L]ast session',
      },
      {
        '<leader>pd',
        function()
          require('persistence').stop()
        end,
        desc = "[D]on't save this session",
      },
    },
  },
}
