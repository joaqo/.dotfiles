-- https://github.com/alexghergh/nvim-tmux-navigation

return {
  {
    "alexghergh/nvim-tmux-navigation",
    config = function(_, opts)
        local nvim_tmux_nav = require('nvim-tmux-navigation')
        nvim_tmux_nav.setup {
            disable_when_zoomed = true
        }

        local function is_floating_win()
            return vim.api.nvim_win_get_config(0).relative ~= ''
        end

        local function nav(tmux_dir, nav_fn)
            return function()
                if is_floating_win() then
                    vim.fn.system('tmux select-pane -' .. tmux_dir)
                else
                    nav_fn()
                end
            end
        end

        vim.keymap.set('n', "<C-h>", nav('L', nvim_tmux_nav.NvimTmuxNavigateLeft))
        vim.keymap.set('n', "<C-j>", nav('D', nvim_tmux_nav.NvimTmuxNavigateDown))
        vim.keymap.set('n', "<C-k>", nav('U', nvim_tmux_nav.NvimTmuxNavigateUp))
        vim.keymap.set('n', "<C-l>", nav('R', nvim_tmux_nav.NvimTmuxNavigateRight))
        vim.keymap.set('t', "<C-h>", function() vim.fn.system('tmux select-pane -L') end, { silent = true })
        vim.keymap.set('t', "<C-j>", function() vim.fn.system('tmux select-pane -D') end, { silent = true })
        vim.keymap.set('t', "<C-k>", function() vim.fn.system('tmux select-pane -U') end, { silent = true })
        vim.keymap.set('t', "<C-l>", function() vim.fn.system('tmux select-pane -R') end, { silent = true })
    end
  }
}
