return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      c = { "clang-format" },
      cpp = { "clang-format" },
      -- java formatting is handled by the lang.java extra (google-java-format)
    },
  },
}
