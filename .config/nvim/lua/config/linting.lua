-- Taken from https://www.reddit.com/r/neovim/comments/15tpl36/format_your_code_using_prettier_without_nullls/
-- I think I can improve it using the most upvoted comment

function RunLinter()
  local fmt_command = '%!npx prettier --stdin-filepath %'
  local cursor = vim.api.nvim_win_get_cursor(0) vim.cmd(fmt_command) -- In case formatting got rid of the line we came from.
  cursor[1] = math.min(cursor[1], vim.api.nvim_buf_line_count(0))
  vim.api.nvim_win_set_cursor(0, cursor)
end
