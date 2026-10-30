return {
    -- Guess tabstop/shiftwidth when a project has no .editorconfig.
    { "tpope/vim-sleuth" },

    {
        "folke/todo-comments.nvim",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = { signs = false },
        keys = {
            { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Search todo comments" },
            { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
            { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
        },
    },

    -- Inline signs for added/changed/deleted lines. The main reason it's here:
    -- when opencode (or any agent) edits files under you, this is what shows
    -- what moved, and `<leader>hp` previews the change before you keep it.
    -- Also shows an inline blame for the cursor line (on by default - toggle with `<leader>ub`)
    -- `<leader>hb` is the one-shot full blame popup
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            signs = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "" },
                topdelete = { text = "" },
                changedelete = { text = "▎" },
                untracked = { text = "▎" },
            },
            current_line_blame = true,
            current_line_blame_opts = {
                virt_text_pos = "eol",
                delay = 500,
                ignore_whitespace = true,
            },
            current_line_blame_formatter = "  <author>, <author_time:%R> • <summary>",
            current_line_blame_formatter_nc = "  Not committed yet",
        },
        config = function(_, opts)
            require("gitsigns").setup(opts)

            Snacks.toggle({
                name = "Inline Git Blame",
                get = function()
                    return require("gitsigns.config").config.current_line_blame
                end,
                set = function(state)
                    require("gitsigns").toggle_current_line_blame(state)
                end,
            }):map("<leader>ub")
        end,
        keys = {
            { "]h", "<cmd>Gitsigns nav_hunk next<cr>", desc = "Next hunk" },
            { "[h", "<cmd>Gitsigns nav_hunk prev<cr>", desc = "Previous hunk" },
            { "<leader>hp", "<cmd>Gitsigns preview_hunk_inline<cr>", desc = "Preview hunk" },
            { "<leader>hr", "<cmd>Gitsigns reset_hunk<cr>", desc = "Reset hunk" },
            { "<leader>hb", "<cmd>Gitsigns blame_line<cr>", desc = "Blame line" },
            { "<leader>hd", "<cmd>Gitsigns diffthis<cr>", desc = "Diff this" },
        },
    },
}
