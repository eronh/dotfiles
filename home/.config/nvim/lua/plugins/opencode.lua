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
        ---@type opencode.Opts
        vim.g.opencode_opts = {
            -- Reload buffers when opencode edits files on disk. The autocmd in
            -- config/autocmds.lua runs :checktime on focus/idle, which is what
            -- makes 'autoread' actually fire.
            events = { reload = true },
        }

        -- Required for `opts.events.reload`.
        vim.o.autoread = true

        local opencode = function(fn, ...)
            local args = { ... }
            return function()
                return require("opencode")[fn](unpack(args))
            end
        end

        -- <leader>o… instead of the upstream <C-a>/<C-x> example keymaps, which
        -- shadow the built-in increment/decrement that `+`/`-` map to.
        vim.keymap.set({ "n", "x" }, "<leader>oa", function()
            require("opencode").ask("@this: ", { submit = true })
        end, { desc = "Ask opencode…" })
        vim.keymap.set({ "n", "x" }, "<leader>os", opencode("select"), { desc = "Execute opencode action…" })
        vim.keymap.set({ "n", "t" }, "<C-.>", opencode("toggle"), { desc = "Toggle opencode" })

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
