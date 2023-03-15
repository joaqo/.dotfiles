-- Based on: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

vim.g.mapleader = ";"
-- vim.g.maplocalleader = ";"

local opt = vim.opt
opt.clipboard = "unnamedplus"
opt.completeopt = "menu,menuone,noselect"
opt.confirm = true
-- opt.cursorline = true
-- opt.formatoptions = "jcroqlnt" -- tcqj
opt.ignorecase = true
-- opt.inccommand = "nosplit"
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.relativenumber = true
opt.scrolloff = 4 -- Lines of context

-- Tab
opt.expandtab = true
opt.shiftround = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2

opt.shortmess:append { W = true, I = true, c = true }
opt.showmode = false
opt.sidescrolloff = 8 -- Columns of context
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current
-- opt.termguicolors = true -- True color support
-- opt.undofile = true  -- Not sure I actually want this
opt.undolevels = 10000
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.wrap = false -- Disable line wrap
