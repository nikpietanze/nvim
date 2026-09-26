return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'
    lint.linters_by_ft = {
      javascript = { 'eslint_d' },
      typescript = { 'eslint_d' },
      vue = { 'eslint_d' },
    }

    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = vim.api.nvim_create_augroup('lint', { clear = true }),
      callback = function()
        -- Skip non-modifiable buffers (e.g. LSP hover popups)
        if vim.bo.modifiable then
          -- Only run linters that are actually installed
          local names = vim.tbl_filter(function(name)
            local linter = lint.linters[name]
            local cmd = type(linter) == 'table' and linter.cmd or name
            return type(cmd) ~= 'string' or vim.fn.executable(cmd) == 1
          end, lint.linters_by_ft[vim.bo.filetype] or {})
          -- Run from the file's project root so tools like eslint_d find the project's
          -- own node_modules, even when nvim was opened from a parent (monorepo) folder
          local root = vim.fs.root(0, {
            'eslint.config.js',
            'eslint.config.mjs',
            'eslint.config.cjs',
            'eslint.config.ts',
            '.eslintrc.js',
            '.eslintrc.cjs',
            '.eslintrc.json',
            'package.json',
          })
          lint.try_lint(names, { cwd = root })
        end
      end,
    })
  end,
}
