-- snacks.nvim: picker (replaces telescope), file explorer (replaces netrw) and small QoL pieces

-- Root of the app the current file belongs to (for monorepos): nearest .sln, then .csproj/package.json
local function project_root()
  return vim.fs.root(0, function(name)
    return name:match '%.slnx?$' ~= nil
  end) or vim.fs.root(0, function(name)
    return name:match '%.csproj$' ~= nil or name == 'package.json'
  end) or vim.fn.getcwd()
end

return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    explorer = { enabled = true, replace_netrw = true },
    indent = { enabled = true },
    input = { enabled = true },
    lazygit = { enabled = true },
    notifier = { enabled = true },
    picker = { enabled = true, ui_select = true },
    quickfile = { enabled = true },
  },
  keys = {
    -- Search
    {
      '<leader>sh',
      function()
        Snacks.picker.help()
      end,
      desc = '[S]earch [H]elp',
    },
    {
      '<leader>sk',
      function()
        Snacks.picker.keymaps()
      end,
      desc = '[S]earch [K]eymaps',
    },
    {
      '<leader>sf',
      function()
        Snacks.picker.files()
      end,
      desc = '[S]earch [F]iles',
    },
    {
      '<leader>ss',
      function()
        Snacks.picker()
      end,
      desc = '[S]earch [S]elect Picker',
    },
    {
      '<leader>sw',
      function()
        Snacks.picker.grep_word()
      end,
      desc = '[S]earch current [W]ord',
      mode = { 'n', 'x' },
    },
    {
      '<leader>sg',
      function()
        Snacks.picker.grep()
      end,
      desc = '[S]earch by [G]rep',
    },
    {
      '<leader>sd',
      function()
        Snacks.picker.diagnostics()
      end,
      desc = '[S]earch [D]iagnostics',
    },
    {
      '<leader>sr',
      function()
        Snacks.picker.resume()
      end,
      desc = '[S]earch [R]esume',
    },
    {
      '<leader>s.',
      function()
        Snacks.picker.recent()
      end,
      desc = '[S]earch Recent Files',
    },
    {
      '<leader>s/',
      function()
        Snacks.picker.grep_buffers()
      end,
      desc = '[S]earch [/] in Open Files',
    },
    {
      '<leader>sp',
      function()
        Snacks.picker.grep { cwd = project_root() }
      end,
      desc = '[S]earch by grep in current [P]roject',
    },
    {
      '<leader>sP',
      function()
        Snacks.picker.files { cwd = project_root() }
      end,
      desc = '[S]earch files in current [P]roject',
    },
    {
      '<leader>sc',
      function()
        Snacks.picker.colorschemes()
      end,
      desc = '[S]earch [C]olorschemes',
    },
    {
      '<leader>sn',
      function()
        Snacks.picker.files { cwd = vim.fn.stdpath 'config' }
      end,
      desc = '[S]earch [N]eovim files',
    },
    {
      '<leader>/',
      function()
        Snacks.picker.lines()
      end,
      desc = '[/] Fuzzily search in current buffer',
    },
    {
      '<leader><leader>',
      function()
        Snacks.picker.buffers()
      end,
      desc = '[ ] Find existing buffers',
    },
    -- Explorer
    {
      '<leader>pv',
      function()
        Snacks.explorer()
      end,
      desc = 'File Tree',
    },
    -- Git
    {
      '<leader>gg',
      function()
        Snacks.lazygit()
      end,
      desc = 'Lazy[g]it',
    },
    {
      '<leader>gs',
      function()
        Snacks.picker.git_status()
      end,
      desc = '[G]it [S]tatus',
    },
    {
      '<leader>gl',
      function()
        Snacks.picker.git_log()
      end,
      desc = '[G]it [L]og',
    },
    {
      '<leader>gf',
      function()
        Snacks.picker.git_log_file()
      end,
      desc = '[G]it log for current [F]ile',
    },
    {
      '<leader>gb',
      function()
        Snacks.picker.git_branches()
      end,
      desc = '[G]it [B]ranches',
    },
    {
      '<leader>gd',
      function()
        Snacks.picker.git_diff()
      end,
      desc = '[G]it [D]iff (hunks)',
    },
    -- Notifications
    {
      '<leader>n',
      function()
        Snacks.picker.notifications()
      end,
      desc = '[N]otification history',
    },
  },
}
