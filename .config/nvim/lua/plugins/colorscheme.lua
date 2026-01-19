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
      -- Sets true colors, 24 bits I think.
      -- Setting termguicolors affects how you should set color overrides through your configs.
      -- If you set termguicolors to true use guifg and guibg, if you set it to false you should use ctermfg and ctermbg.
      vim.opt.termguicolors = true

      -- Set theme
      vim.cmd.colorscheme("gruvbox")

      -- Set color overrides
      vim.cmd("hi Normal guibg=none | hi SignColumn guibg=none")
      -- Set searching colors
      vim.cmd("hi Search guifg=#F7E19E guibg=black | hi IncSearch guibg=#FB4934 guifg=white | hi CurSearch guifg=white guibg=#FB4934")
      -- Set `gitsigns` plugin colors. Here for all color names: https://github.com/lewis6991/gitsigns.nvim/blob/f388995990aba04cfdc7c3ab870c33e280601109/doc/gitsigns.txt#L937
      vim.cmd("hi GitSignsAdd guibg=none guifg=darkcyan | hi GitSignsChange guibg=none guifg=green | hi GitSignsDelete guibg=none guifg=red | hi GitSignsChangedelete guibg=none guifg=brown | hi GitSignsTopdelete guibg=none guifg=red | hi GitSignsUntracked guibg=none guifg=lightgray")
      vim.cmd("hi NormalFloat guibg=#292825")
      -- Treesitter diff highlights (for gitcommit)
      vim.cmd("hi @text.diff.add guifg=#b8bb26 | hi @text.diff.delete guifg=#fb4934")
    end
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = { style = "moon" },
  },
}
