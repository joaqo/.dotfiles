-- It may make sense in the future to not be so low level and allow mason to manage my lsp servers, watch this: https://www.youtube.com/watch?v=lpQMeFph1RE
-- You need a version of node installed with nvm (`nvm install node`) or you get access errors when trying to install global packages with npm, after that do:
-- npm install -g pyright
-- npm install -g typescript-language-server typescript

return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Diagnostic mappings
      local opts = { noremap=true, silent=true }
      vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
      vim.keymap.set('n', '<leader>Q', vim.diagnostic.setqflist, opts)

      -- LSP keymaps on attach
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local bufnr = args.buf
          vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

          local bufopts = { noremap=true, silent=true, buffer=bufnr }
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
          vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
          vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
          vim.keymap.set('n', '<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, bufopts)
          vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
          vim.keymap.set('n', '<leader>gf', function() vim.lsp.buf.format { async = true } end, bufopts)
        end
      })

      -- Server configs
      vim.lsp.config('pyright', {
        root_markers = { 'pyrightconfig.json', 'pyproject.toml', '.python-version' },
        settings = {
          python = {
            analysis = {
              diagnosticMode = 'workspace',
            },
          },
        },
      })

      vim.lsp.config('ruff', {
        root_markers = { 'pyproject.toml', 'ruff.toml', '.python-version' },
      })

      vim.lsp.config('vtsls', {
        root_markers = { 'pnpm-workspace.yaml', 'tsconfig.json', 'jsconfig.json', '.git' },
      })

      vim.lsp.config('tailwindcss', {})

      vim.lsp.config('eslint', {})

      -- Enable servers
      vim.lsp.enable({ 'pyright', 'ruff', 'vtsls', 'tailwindcss', 'eslint' })
    end
  }
}
