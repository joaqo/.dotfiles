-- Requires install for file searching: brew install ripgrep
-- Official example configs: https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#mapping-esc-to-quit-in-insert-mode

-- Hotkeys inside telescope search
-- <C-q> open in quickfix list
-- <C-x> go to file selection as a split   
-- <C-v> go to file selection as a vsplit   
-- <C-t> go to a file in a new tab

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
    keys = {
      { "<leader>,", "<cmd>Telescope buffers show_all_buffers=true<cr>", desc = "Switch Buffer" },
      { "<leader>/", "<cmd>Telescope live_grep<cr>", desc = "Find in Files (Grep)" },
      { "<leader>?", "<cmd>Telescope live_grep additional_args={'--no-ignore'}<cr>", desc = "Grep All (incl gitignored)" },
      { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
      { "<leader>f", "<cmd>Telescope find_files<cr>", desc = "Find Files (root dir)" },
      { "<leader>a", "<cmd>Telescope find_files no_ignore=true<cr>", desc = "Find Files (incl gitignored)" },
      { "<leader>c",'<cmd>lua require("telescope.builtin").find_files{ cwd = require("telescope.utils").buffer_dir() }<cr>', desc = "Find Files (current dir)" },
      { "<leader>m", "<cmd>Telescope oldfiles<cr>", desc = "File history" },
      { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "commits" },
      { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "status" },
      { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
      { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
      { "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
      { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
      { "<leader>sd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
      { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
      { "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
      { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
      { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
      { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
      { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
      { "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
      { "<leader>uC", "<cmd>Telescope colorscheme<cr>", desc = "Colorscheme with preview" },
    },
    config = function(_, opts)
      local actions = require('telescope.actions')
      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<esc>"] = actions.close,
              ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            file_ignore_patterns = { "^%.git/" },
          },
        }
      })
    end
  }
}
