return {
  "stevearc/aerial.nvim",
  branch = "nvim-0.11", -- main requires Neovim 0.12+
  event = "LazyFile",
  config = function()
    require("aerial").setup({
      width = 40,
      min_width = 40,
    })
  end,
  keys = {
    { "<leader>cs", "<cmd>AerialToggle<cr>", desc = "Aerial (Symbols)" },
  },
}
