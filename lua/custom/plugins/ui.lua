return {
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  { -- Colorscheme
    'loctvl842/monokai-pro.nvim',
    priority = 1000,
    init = function()
      -- Remember the last colorscheme picked (e.g. via <leader>sc) across restarts
      local file = vim.fn.stdpath 'state' .. '/colorscheme'
      local ok, saved = pcall(vim.fn.readfile, file)
      if not (ok and saved[1] and pcall(vim.cmd.colorscheme, saved[1])) then
        vim.cmd.colorscheme 'monokai-pro-octagon'
      end
      vim.cmd.hi 'Comment gui=none'

      vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('custom-save-colorscheme', { clear = true }),
        callback = function(args)
          vim.fn.writefile({ args.match }, file)
        end,
      })
    end,
  },
  -- Extra colorschemes (browse with :lua Snacks.picker.colorschemes())
  { 'ellisonleao/gruvbox.nvim' },
  { 'folke/tokyonight.nvim' },
  { 'catppuccin/nvim', name = 'catppuccin' },
  { 'rose-pine/neovim', name = 'rose-pine' },
  { 'rebelot/kanagawa.nvim' },
  { 'neanias/everforest-nvim' },
  { 'EdenEast/nightfox.nvim' },
  { 'scottmckendry/cyberdream.nvim' },
  { 'sainnhe/gruvbox-material' },

  { -- Shows pending keybinds
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },
      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { '<leader>g', group = '[G]it' },
        { 'gr', group = 'LSP' },
        { 'gs', group = 'Surround', mode = { 'n', 'x' } },
        { '<leader>x', group = 'Trouble' },
        { '<leader>p', group = '[P]roject / session' },
        { '<leader>d', group = '[D]ebug' },
      },
    },
  },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Collection of small independent modules
    'nvim-mini/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects, e.g. va) yinq ci'
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings, e.g. gsaiw) gsd' gsr)'
      -- (under `gs` because flash.nvim uses `s` for jumping)
      require('mini.surround').setup {
        mappings = {
          add = 'gsa',
          delete = 'gsd',
          find = 'gsf',
          find_left = 'gsF',
          highlight = 'gsh',
          replace = 'gsr',
          update_n_lines = 'gsn',
        },
      }

      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },
}
