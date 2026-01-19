-- Highlight commands and groups here: https://neovim.io/doc/user/syntax.html#%3Ahighlight
-- To see all currently active groups execute this in vim `:so $VIMRUNTIME/syntax/hitest.vim`
-- To see all colors execute this in vim `:runtime syntax/colortest.vim`

return {
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent_mode = true,
      italic = {
        strings = false,
        comments = false,
        operators = false,
        folds = false,
      },
      -- overrides = {
      --   Search = { fg = "#F7E19E", bg = "black" },
      --   IncSearch = { fg = "white", bg = "#FB4934" },
      --   CurSearch = { fg = "white", bg = "#FB4934" },
      --   GitSignsAdd = { bg = "NONE", fg = "darkcyan" },
      --   GitSignsChange = { bg = "NONE", fg = "green" },
      --   GitSignsDelete = { bg = "NONE", fg = "red" },
      --   GitSignsChangedelete = { bg = "NONE", fg = "brown" },
      --   GitSignsTopdelete = { bg = "NONE", fg = "red" },
      --   GitSignsUntracked = { bg = "NONE", fg = "lightgray" },
      --   NormalFloat = { bg = "#292825" },
      -- },
    },
    config = function(_, opts)
      vim.opt.termguicolors = true
      require("gruvbox").setup(opts)
      vim.cmd.colorscheme("gruvbox")
    end
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = { style = "moon" },
  },
}
