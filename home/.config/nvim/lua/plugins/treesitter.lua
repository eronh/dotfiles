return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",

        dependencies = {
            {
                "nvim-treesitter/nvim-treesitter-textobjects",
                branch = "main",
            },
        },

        config = function()
            local ts = require("nvim-treesitter")
            local parsers = {
                "bash",
                "c",
                "diff",
                "fish",
                "dockerfile",
                "html",
                "javascript",
                "json",
                "lua",
                "luadoc",
                "luap",
                "markdown",
                "markdown_inline",
                "python",
                "query",
                "regex",
                "sql",
                "toml",
                "tsx", -- typescriptreact; `typescript` doesn't cover it
                "typescript",
                "vim",
                "vimdoc",
                "yaml",
            }

            for _, parser in ipairs(parsers) do
                pcall(ts.install, parser)
            end

            vim.api.nvim_create_autocmd("FileType", {
                callback = function()
                    pcall(vim.treesitter.start)
                end,
            })

            -- Textobjects (main-branch API): wire keymaps directly
            local sel = require("nvim-treesitter-textobjects.select")
            local move = require("nvim-treesitter-textobjects.move")

            for _, cfg in ipairs({
                { "af", "@function.outer", "textobjects" },
                { "if", "@function.inner", "textobjects" },
                { "ac", "@class.outer",    "textobjects" },
                { "ic", "@class.inner",    "textobjects" },
                { "as", "@local.scope",    "locals" },
            }) do
                vim.keymap.set({ "x", "o" }, cfg[1], function()
                    sel.select_textobject(cfg[2], cfg[3])
                end, { desc = "Select " .. cfg[2] })
            end

            local moves = {
                ["]f"] = { "goto_next_start", "@function.outer" },
                ["]F"] = { "goto_next_end", "@function.outer" },
                ["[f"] = { "goto_previous_start", "@function.outer" },
                ["[F"] = { "goto_previous_end", "@function.outer" },
                ["]c"] = { "goto_next_start", "@class.outer" },
                ["]C"] = { "goto_next_end", "@class.outer" },
                ["[c"] = { "goto_previous_start", "@class.outer" },
                ["[C"] = { "goto_previous_end", "@class.outer" },
                ["]a"] = { "goto_next_start", "@parameter.inner" },
                ["]A"] = { "goto_next_end", "@parameter.inner" },
                ["[a"] = { "goto_previous_start", "@parameter.inner" },
                ["[A"] = { "goto_previous_end", "@parameter.inner" },
            }
            for key, cfg in pairs(moves) do
                vim.keymap.set("n", key, function()
                    move[cfg[1]](cfg[2], "textobjects")
                end, { desc = cfg[2] })
            end
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter-context",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        opts = function()
            local ts_context = require("treesitter-context")
            Snacks.toggle({
                name = "Treesitter Context",
                get = ts_context.enabled,
                set = function(state)
                    if state then
                        ts_context.enable()
                    else
                        ts_context.disable()
                    end
                end,
            }):map("<leader>ut")
            return {
                mode = "cursor",
                max_lines = 3,
            }
        end,
    },
}
