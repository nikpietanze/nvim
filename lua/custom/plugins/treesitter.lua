-- Highlight, edit, and navigate code. Uses the `main` branch rewrite, which needs
-- the `tree-sitter` CLI (brew install tree-sitter-cli).
return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    local ts = require 'nvim-treesitter'
    ts.install { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }

    local function start(buf)
      if pcall(vim.treesitter.start, buf) then
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end

    -- Start treesitter for every filetype, installing missing parsers on first use
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('custom-treesitter', { clear = true }),
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match)
        if not lang then
          return
        end
        if vim.list_contains(ts.get_installed(), lang) then
          start(args.buf)
        elseif vim.list_contains(ts.get_available(), lang) then
          ts.install(lang):await(function()
            if vim.api.nvim_buf_is_valid(args.buf) then
              start(args.buf)
            end
          end)
        end
      end,
    })
  end,
}
