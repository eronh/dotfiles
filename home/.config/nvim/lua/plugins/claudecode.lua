-- Claude Code's IDE protocol: Claude sees the current selection and the LSP
-- diagnostics, takes files/ranges sent from here, and proposes each edit as a
-- diff in this Neovim (`:w` or <leader>aa accepts, `:q` or <leader>ad rejects).
-- `<C-,>` runs `claude` from $PATH on the host, not in an sbx sandbox; a claude
-- started elsewhere on the host attaches with `/ide` after `:ClaudeCodeStart`.
return {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {},
    cmd = { "ClaudeCode", "ClaudeCodeStart" },
    keys = {
        -- Pairs with <C-.> for opencode.
        { "<C-,>", "<cmd>ClaudeCodeFocus<cr>", mode = { "n", "t" }, desc = "Toggle Claude Code" },
        { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add buffer to Claude" },
        { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
        { "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", ft = "neo-tree", desc = "Add file to Claude" },
        { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Claude's diff" },
        { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Reject Claude's diff" },
    },
}
