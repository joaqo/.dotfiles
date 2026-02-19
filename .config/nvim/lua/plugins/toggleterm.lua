return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<C-\\>", function() vim.cmd(vim.v.count1 .. "ToggleTerm direction=float") end, mode = { "n", "t" }, desc = "Toggle Terminal" },
    },
    opts = {
      float_opts = {
        width = function() return vim.o.columns end,
        height = function() return vim.o.lines - 3 end,
      },
      shade_terminals = false,
      on_open = function()
        pcall(vim.cmd, "Neotree close")
      end,
    },
  },
}
