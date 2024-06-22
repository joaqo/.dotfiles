local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- Close terminal instead of showing process exited on <C-D>
-- Taken from: https://github.com/neovim/neovim/issues/14986#issuecomment-902705190
vim.api.nvim_create_autocmd({ "TermClose" }, {
  command = "bdelete! " .. vim.fn.expand("<abuf>"),
})

-- Automatically enter insert mode when entering a terminal buffer
vim.cmd("autocmd BufWinEnter,WinEnter term://* startinsert")

-- Run linting on saving file in js
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = {"*.ts", "*.tsx", "*.js", "*.jsx"},
--   callback = RunLinter,
-- })

-- Check if we need to reload the file when it changed
-- vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
--   group = augroup("checktime"),
--   command = "checktime",
-- })

-- Highlight on yank
-- vim.api.nvim_create_autocmd("TextYankPost", {
--   group = augroup("highlight_yank"),
--   callback = function()
--     vim.highlight.on_yank()
--   end,
-- })
