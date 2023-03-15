-- Inspired by: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- To know which keys to map run in vim `:help map-which-keys`

local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

-- -- Removed because nvim-tmux-naviation controls this now
-- -- Move to window using the <ctrl> hjkl keys
-- map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
-- map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
-- map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
-- map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- -- Resize window using <ctrl> arrow keys
-- map("n", "<Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
-- map("n", "<Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
-- map("n", "<Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
-- map("n", "<Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })


-- The keys ^ and $ are unergonomic
map({"n", "v"}, "H", "^")
map({"n", "v"}, "L", "$")


-- Terminal
map({ "n", "t" }, "<C-\\>", ToggleTerminal, {desc = "Toggle Terminal"})
map("t", "<C-x>", "<c-\\><c-n>", {desc = "Enter Normal Mode"})
map("t", "<C-k>", "<c-\\><c-n><C-W>p", {desc = "Go back to last pane"})

-- Misc
map("n", "<C-M>", "<C-^>", { desc = "Go to last opened file", noremap = true })
map("v", "p", "pgvy", { desc = "Bind p in visual mode to paste without overriding the current register" } )
map({"n", "v"}, ",", ";", { desc = "Repeat last motion", noremap = true })
map({"n", "v"}, "<leader>b", "<cmd>enew<cr>", { desc = "Create and open a new buffer" })
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })
vim.cmd("nnoremap <Space> :")  -- Using the map function made it not show `:` correctly on first press
