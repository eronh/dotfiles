return {
    "nickjvandyke/opencode.nvim",
    version = "*", -- Latest stable release
    dependencies = {
        {
            -- `snacks.nvim` integration is recommended, but optional
            ---@module "snacks" <- Loads `snacks.nvim` types for configuration intellisense
            "folke/snacks.nvim",
            optional = true,
            opts = {
                input = {}, -- Enhances `ask()`
                -- These picker opts stay inert: snacks.picker is disabled in
                -- snacks.lua because Telescope is this config's picker, so
                -- `select()` falls through to vim.ui.select (telescope-ui-select).
                picker = {
                    actions = {
                        opencode_send = function(...)
                            return require("opencode").snacks_picker_send(...)
                        end,
                    },
                    win = {
                        input = {
                            keys = {
                                ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
                            },
                        },
                    },
                },
            },
        },
    },
    config = function()
        -- opencode.nvim no longer embeds a terminal (`toggle()` is gone): it
        -- attaches to any running `opencode --port`, and calls `server.start`
        -- when there is none. Both start it in the same snacks split.
        local opencode_cmd = "opencode --port"
        ---@type snacks.terminal.Opts
        local terminal_opts = { win = { position = "right", enter = false } }

        ---@type opencode.Opts
        vim.g.opencode_opts = {
            -- Off: `events.reload` is a table now and on by default; `true` made
            -- the config module fail to load (it indexes `.reload.enabled`).
            -- events = { reload = true },
            server = {
                start = function()
                    require("snacks.terminal").open(opencode_cmd, terminal_opts)
                end,
            },
        }

        -- Required for `opts.events.reload`.
        vim.o.autoread = true

        -- <leader>o… instead of the upstream <C-a>/<C-x> example keymaps, which
        -- shadow the built-in increment/decrement that `+`/`-` map to.
        vim.keymap.set({ "n", "x" }, "<leader>oa", function()
            require("opencode").ask("@this: ")
        end, { desc = "Ask opencode…" })
        vim.keymap.set({ "n", "x" }, "<leader>os", function()
            require("opencode").select()
        end, { desc = "Execute opencode action…" })
        vim.keymap.set({ "n", "t" }, "<C-.>", function()
            require("snacks.terminal").toggle(opencode_cmd, terminal_opts)
        end, { desc = "Toggle opencode" })

        vim.keymap.set({ "n", "x" }, "go", function()
            return require("opencode").operator("@this ")
        end, { desc = "Add range to opencode", expr = true })
        vim.keymap.set("n", "goo", function()
            return require("opencode").operator("@this ") .. "_"
        end, { desc = "Add line to opencode", expr = true })

        vim.keymap.set("n", "<S-C-u>", function()
            require("opencode").command("session.half.page.up")
        end, { desc = "Scroll opencode up" })
        vim.keymap.set("n", "<S-C-d>", function()
            require("opencode").command("session.half.page.down")
        end, { desc = "Scroll opencode down" })

        -- Off: upstream's opinionated bindings. They took <C-a>/<C-x> and then
        -- handed increment/decrement to `+`/`-`, which config/keymaps.lua
        -- already does — so these only served to break <C-a>/<C-x>.
        -- vim.keymap.set({ "n", "x" }, "<C-a>", ...)  -- ask
        -- vim.keymap.set({ "n", "x" }, "<C-x>", ...)  -- select
        -- vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
        -- vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })
    end,
}
