-- Basing a lot of my config on: https://github.com/LazyVim/LazyVim/tree/main/lua/lazyvim
-- Interesting base repo to copy or maybe even migrate to: https://github.com/NvChad/NvChad
--
-- TRY THIS: https://github.com/echasnovski/mini.nvim
-- And this: https://www.youtube.com/watch?v=GEHPiZ10gOk
--
-- AND THIS: https://github.com/nvim-treesitter/nvim-treesitter-context
--
-- Interesting: https://arslan.io/2021/02/15/automatic-dark-mode-for-terminal-applications/
--
-- Consider Make tmux and vim use <C-x> for exit insert mode, and tmux to use v to select text

require("config.linting")
require("config.terminal")
require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")
