return {
  { -- Autocompletion
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*', -- release builds ship a prebuilt fuzzy matcher
    dependencies = { 'rafamadriz/friendly-snippets' },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        -- 'enter' preset: <CR> accepts, <C-n>/<C-p> select, <C-space> opens menu,
        -- <C-b>/<C-f> scroll docs, <Tab>/<S-Tab> jump through snippet placeholders
        preset = 'enter',
      },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },
      signature = { enabled = true },
    },
  },

  { -- Auto-close brackets and quotes
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },
}
