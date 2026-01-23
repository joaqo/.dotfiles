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

-- Show diagnostic on hover
vim.api.nvim_create_autocmd("CursorHold", {
  group = augroup("diagnostic_float"),
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false })
  end,
})

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

-- Enable wrap for prose files
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("prose_wrap"),
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})
