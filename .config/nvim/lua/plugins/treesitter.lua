return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = "v0.9.2",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup({
      highlight = { enable = true },
      indent = {
        enable = true,
        disable = { "python" }
      },
      context_commentstring = { enable = true, enable_autocmd = false },
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "gitcommit",
        "vimdoc",
        "html",
        "javascript",
        "json",
        "jsonc",
        "lua",
        "luap",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "yaml",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = "<nop>",
          node_decremental = "<bs>",
        },
      },
    })
    end
  },
}
