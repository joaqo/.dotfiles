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
        vim.cmd.colorscheme("gruvbox")
        vim.cmd("hi Normal ctermbg=none | hi StatusLine ctermfg=darkgrey | hi SignColumn ctermbg=none")
        -- Set searching colors
        vim.cmd("hi Search ctermfg=white ctermbg=darkgrey | hi IncSearch ctermbg=red ctermfg=white | hi CurSearch ctermbg=red ctermfg=white")
        -- Set `gitsigns` plugin colors. Here for all color names: https://github.com/lewis6991/gitsigns.nvim/blob/f388995990aba04cfdc7c3ab870c33e280601109/doc/gitsigns.txt#L937
        vim.cmd("hi GitSignsAdd ctermbg=none ctermfg=darkcyan | hi GitSignsChange ctermbg=none ctermfg=green | hi GitSignsDelete ctermbg=none ctermfg=red | hi GitSignsChangedelete ctermbg=none ctermfg=brown | hi GitSignsTopdelete ctermbg=none ctermfg=red | hi GitSignsUntracked ctermbg=none ctermfg=lightgray")
    end
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = { style = "moon" },
  },
}
