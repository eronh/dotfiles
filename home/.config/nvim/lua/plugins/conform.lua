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
        return {
            notify_on_error = false,
            format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
            formatters_by_ft = {
                ["*"] = { "codespell", "trim_whitespace" },

                c = { "clang_format" },
                go = { "goimports", "gofmt" },

                css = { "prettierd" },
                html = { "prettierd" },
                javascript = { "oxfmt", "eslint_d", "prettierd", stop_after_first = true },
                typescript = { "eslint_d", "prettierd", stop_after_first = true },
                javascriptreact = { "eslint_d", "prettierd", stop_after_first = true },
                typescriptreact = { "eslint_d", "prettierd", stop_after_first = true },
                json = { "eslint_d", "prettierd", stop_after_first = true },

                lua = { "stylua" },

                markdown = { "prettierd", "prettier" },

                python = function(bufnr)
                    if require("conform").get_formatter_info("ruff_format", bufnr).available then
                        return { "ruff_format" }
                    else
                        return { "isort", "black" }
                    end
                end,

                shell = { "shfmt", "shellcheck", stop_after_first = true },
                sh = { "shfmt", "shellcheck", stop_after_first = true },
                bash = { "shfmt", "shellcheck", stop_after_first = true },
                zsh = { "shfmt", "shellcheck", stop_after_first = true },
            },
        }
    end,
}
