return {
  "mrcjkb/rustaceanvim",
  version = "^8", -- v9+ dropped Neovim 0.11 support
  opts = {
    server = {
      on_attach = function(_, bufnr)
        -- LazyVim rust extra keymaps (kept so they are not lost on override)
        vim.keymap.set("n", "<leader>cR", function()
          vim.cmd.RustLsp("codeAction")
        end, { desc = "Code Action (Rust)", buffer = bufnr })
        vim.keymap.set("n", "<leader>dr", function()
          vim.cmd.RustLsp("debuggables")
        end, { desc = "Rust Debuggables", buffer = bufnr })
        -- Hover with actions
        vim.keymap.set("n", "K", "<cmd>RustLSP hover actions<cr>", { desc = "Hover Actions (Rust)", buffer = bufnr })
      end,
    },
  },
}
