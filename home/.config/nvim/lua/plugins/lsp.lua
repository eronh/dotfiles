-- Servers are configured with the built-in `vim.lsp.config()` / `vim.lsp.enable()`
-- API (Neovim >= 0.11) rather than `require("lspconfig")[name].setup()`, which is
-- deprecated. nvim-lspconfig is still the source of each server's default cmd,
-- filetypes and root markers; we only layer overrides on top.
--
-- Mason lives under `mason-org/` now — the `williamboman/` repos are archived.
-- mason-lspconfig v2 dropped the `handlers` table, so there is nothing to
-- replace it with: it now just installs servers and calls `vim.lsp.enable()`.

---@type table<string, vim.lsp.Config>
local servers = {
    lua_ls = {
        settings = {
            Lua = {
                completion = { callSnippet = "Replace" },
                -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                -- diagnostics = { disable = { "missing-fields" } },
            },
        },
    },

    pyright = {
        -- ruff sorts imports; one "Organize Imports" code action is enough.
        settings = { pyright = { disableOrganizeImports = true } },
    },
    -- Python linting and quick fixes; pyright keeps types, hover and completion.
    ruff = {},
    clangd = {},
    taplo = {},

    ts_ls = {
        root_markers = { "package.json", "tsconfig.json", ".git" },
    },

    eslint = {
        -- Fall back to the Workbench-level config when a project has none, so
        -- scratch files still get linted.
        root_dir = function(bufnr, on_dir)
            local name = vim.api.nvim_buf_get_name(bufnr)
            if name == "" then
                return
            end
            -- Same list as lspconfig's eslint; the old one missed eslint.config.ts
            -- and friends, so those projects fell back to ~/Workbench.
            local markers = {
                ".eslintrc",
                ".eslintrc.js",
                ".eslintrc.cjs",
                ".eslintrc.yaml",
                ".eslintrc.yml",
                ".eslintrc.json",
                "eslint.config.js",
                "eslint.config.mjs",
                "eslint.config.cjs",
                "eslint.config.ts",
                "eslint.config.mts",
                "eslint.config.cts",
            }
            local found = vim.fs.find(markers, { path = name, upward = true })[1]
            on_dir(found and vim.fs.dirname(found) or vim.fn.expand("~/Workbench"))
        end,
    },
}

-- Tools that are not language servers (formatters, linters) still need Mason to
-- fetch them for conform.nvim.
local tools = {
    "black",
    "clang-format",
    "codespell",
    "eslint_d",
    "isort",
    "prettierd",
    "ruff",
    "shfmt",
    "stylua",
}

return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "mason-org/mason-lspconfig.nvim",
            { "WhoIsSethDaniel/mason-tool-installer.nvim", opts = { ensure_installed = tools } },

            -- Useful status updates for LSP.
            { "j-hui/fidget.nvim", opts = {} },

            -- get_lsp_capabilities() is called in config below.
            "saghen/blink.cmp",
        },
        config = function()
            -- Buffer-local mappings, set once per attached server.
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
                callback = function(event)
                    local builtin = require("telescope.builtin")
                    local map = function(keys, func, desc, mode)
                        vim.keymap.set(mode or "n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                    end

                    map("gd", builtin.lsp_definitions, "[G]oto [D]efinition")
                    map("gr", builtin.lsp_references, "[G]oto [R]eferences")
                    map("gI", builtin.lsp_implementations, "[G]oto [I]mplementation")
                    map("<leader>D", builtin.lsp_type_definitions, "Type [D]efinition")
                    map("<leader>ds", builtin.lsp_document_symbols, "[D]ocument [S]ymbols")
                    map("<leader>ws", builtin.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
                    map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
                    map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
                    -- WARN: not Goto Definition. In C this takes you to the header.
                    map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if not client then
                        return
                    end

                    -- Highlight other references to the symbol under the cursor
                    -- while it rests there.
                    if client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
                        local hl_group = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
                        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                            buffer = event.buf,
                            group = hl_group,
                            callback = vim.lsp.buf.document_highlight,
                        })
                        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                            buffer = event.buf,
                            group = hl_group,
                            callback = vim.lsp.buf.clear_references,
                        })
                        vim.api.nvim_create_autocmd("LspDetach", {
                            group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
                            end,
                        })
                    end

                    if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
                        map("<leader>th", function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
                        end, "[T]oggle Inlay [H]ints")
                    end
                end,
            })

            -- blink.cmp advertises the extra completion capabilities it adds on
            -- top of Neovim's defaults. '*' applies them to every server.
            vim.lsp.config("*", {
                capabilities = require("blink.cmp").get_lsp_capabilities(),
            })

            for name, config in pairs(servers) do
                vim.lsp.config(name, config)
            end

            require("mason-lspconfig").setup({
                ensure_installed = vim.tbl_keys(servers),
                automatic_enable = true, -- calls vim.lsp.enable() for each installed server
            })

            -- Diagnostic Config
            -- See :help vim.diagnostic.Opts
            vim.diagnostic.config({
                severity_sort = true,
                float = { border = "rounded", source = "if_many" },
                underline = { severity = vim.diagnostic.severity.ERROR },
                signs = vim.g.have_nerd_font and {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "󰅚 ",
                        [vim.diagnostic.severity.WARN] = "󰀪 ",
                        [vim.diagnostic.severity.INFO] = "󰋽 ",
                        [vim.diagnostic.severity.HINT] = "󰌶 ",
                    },
                } or {},
                virtual_text = { source = "if_many", spacing = 2 },
            })
        end,
    },
}
