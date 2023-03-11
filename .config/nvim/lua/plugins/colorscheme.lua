-- If we don't set `lazy = false`, the colorscheme won't appear in the colorschemes list
-- Someday I should move to this one probably, but it changed some text to italics and I
-- couldn't be bothered to fix it: https://github.com/ellisonleao/gruvbox.nvim

return {
  {
    "morhetz/gruvbox",
    lazy = false,
    config = function(lazy_plugin, opts)
        vim.o.background = "dark"
        vim.cmd.colorscheme("gruvbox")
        vim.cmd("hi Normal ctermbg=black | hi StatusLine ctermbg=red ctermfg=black | hi SignColumn ctermbg=black")
    end
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = { style = "moon" },
  },
}
