return {
  "Zeioth/compiler.nvim",
  cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
  dependencies = { "stevearc/overseer.nvim" },
  opts = {},
  keys = {
    { "<F6>", "<cmd>CompilerOpen<cr>", desc = "Open Compiler" },
    { "<S-F6>", "<cmd>CompilerStop<cr><cmd>CompilerRedo<cr>", desc = "Stop & Redo Compiler" },
    { "<S-F7>", "<cmd>CompilerToggleResults<cr>", desc = "Toggle Compiler Results" },
  },
}
