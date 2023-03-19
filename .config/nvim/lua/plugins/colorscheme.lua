-- If we don't set `lazy = false`, the colorscheme won't appear in the colorschemes list
-- Someday I should move to this one probably, but it changed some text to italics and I
-- couldn't be bothered to fix it: https://github.com/ellisonleao/gruvbox.nvim
-- Highlight commands and groups here: https://neovim.io/doc/user/syntax.html#%3Ahighlight
-- To see all currently active groups execute this in vim `:so $VIMRUNTIME/syntax/hitest.vim`
-- To see all colors execute this in vim `:runtime syntax/colortest.vim`

return {
  {
    "morhetz/gruvbox",
    lazy = false,
    config = function(lazy_plugin, opts)
        vim.o.background = "dark"
        vim.cmd.colorscheme("gruvbox")
        vim.cmd("hi Normal ctermbg=black | hi StatusLine ctermbg=red ctermfg=black | hi SignColumn ctermbg=black")
        vim.cmd("hi Search ctermfg=white ctermbg=darkgrey | hi IncSearch ctermbg=red ctermfg=white | hi CurSearch ctermbg=red ctermfg=white")
    end
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = { style = "moon" },
  },
}
