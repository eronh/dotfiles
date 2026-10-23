return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
        {
            "<leader>fm",
            function()
                require("conform").format({
                    async = true,
                    lsp_format = "fallback",
                })
            end,
            mode = "",
            desc = "[F]ormat buffer",
        },
    },
    opts = function()
        -- First one that's actually installed wins.
        local js = { "oxfmt", "prettierd", "prettier", "eslint_d", stop_after_first = true }
        -- shellcheck is a linter, not a conform formatter, and "shell" is not a
        -- filetype — both were silently ignored. shfmt handles all three.
        local sh = { "shfmt" }

        return {
            notify_on_error = false,
            format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
            formatters_by_ft = {
                ["*"] = { "codespell", "trim_whitespace" },

                c = { "clang_format" },
                go = { "goimports", "gofmt" },

                css = { "prettierd", "prettier", stop_after_first = true },
                html = { "prettierd", "prettier", stop_after_first = true },
                json = { "prettierd", "prettier", stop_after_first = true },

                -- Same chain for the whole JS/TS family; `javascript` used to be
                -- the only one that tried oxfmt.
                javascript = js,
                typescript = js,
                javascriptreact = js,
                typescriptreact = js,

                lua = { "stylua" },

                markdown = { "prettierd", "prettier", stop_after_first = true },

                python = function(bufnr)
                    if require("conform").get_formatter_info("ruff_format", bufnr).available then
                        return { "ruff_format" }
                    else
                        return { "isort", "black" }
                    end
                end,

                sh = sh,
                bash = sh,
                zsh = sh,
            },
        }
    end,
}
