-- To know which keys to map run in vim `:help map-which-keys`
-- Or look at this list: https://vim.fandom.com/wiki/Unused_keys
--
-- GOOD KEYS FREE FOR REMAPPING:
-- ",": Already remapped to "<C-h>"

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

-- The keys ^ and $ are unergonomic
map({"n", "v"}, "H", "^")
map({"n", "v"}, "L", "$")

-- Terminal
map({ "n", "t" }, "<C-\\>", ToggleTerminal, {desc = "Toggle Terminal"})
map("t", "<C-x>", "<c-\\><c-n>", {desc = "Enter Normal Mode"})
map("t", "<C-k>", "<c-\\><c-n><C-W>p", {desc = "Go back to last pane"})

-- Motions
map({"n", "v"}, "(", ",", { desc = "Repeat last motion reversed", noremap = true })
map({"n", "v"}, ")", ";", { desc = "Repeat last motion", noremap = true })

-- Move by visual line (better for wrapped text)
map({"n", "v"}, "j", "gj", { noremap = true })
map({"n", "v"}, "k", "gk", { noremap = true })

-- Quickfix list
map('n', '<leader>q', ':cclose\n')

-- Misc
map("n", "<leader>n", "<C-^>", { desc = "Go to last opened file", noremap = true })
map("v", "p", "pgvy", { desc = "Bind p in visual mode to paste without overriding the current register" } )
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })
map("n", "<leader>cp", function() vim.fn.setreg("+", vim.fn.expand("%:.")) end, { desc = "Copy file path to clipboard" })

-- Space remap (using the map function made it not show `:` correctly on first press)
vim.cmd("nnoremap <Space> :")
vim.cmd("vnoremap <Space> :")

-- React Comment
map("n", "<leader>v", "o{/*  */}<esc>hhhi", { desc = "Add React comment", noremap = true })

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
