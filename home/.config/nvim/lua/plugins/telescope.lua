-- Telescope is the picker for this config. snacks.picker is explicitly disabled
-- in snacks.lua so the two don't both claim vim.ui.select and the same keys.

-- File and text searches don't respect .gitignore, so git-ignored files that
-- matter (.env, local config) are found; the generated/vendored dirs listed in
-- rg-ignore are excluded instead. "All files" mode drops every ignore rule,
-- keeping only .git out. `grepprg` in config/options.lua uses the same flags.
local rg_ignore = vim.fn.stdpath("config") .. "/rg-ignore"

local function rg_args(all)
    if all then
        return { "--hidden", "--no-ignore", "--glob=!.git" }
    end
    return { "--hidden", "--no-ignore-vcs", "--glob=!.git", "--ignore-file=" .. rg_ignore }
end

return {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "jonarrien/telescope-cmdline.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            -- `build` runs when the plugin is installed/updated, not on startup.
            build = "make",
            cond = function()
                return vim.fn.executable("make") == 1
            end,
        },
        { "nvim-telescope/telescope-ui-select.nvim" },
    },
    keys = {
        { "Q", "<cmd>Telescope cmdline<cr>", desc = "Cmdline" },
    },
    config = function()
        local builtin = require("telescope.builtin")
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")

        -- The pickers that take the rg filter, and how each passes it to rg.
        local function filter_opts(kind, all)
            if kind == "find_files" then
                return { find_command = vim.list_extend({ "rg", "--files" }, rg_args(all)) }
            end
            return { additional_args = rg_args(all) }
        end

        local search_all -- defined below; it and the toggle reopen each other

        -- <M-i> reopens the picker in the other mode, keeping the typed prompt.
        local function toggle_ignored(kind, all)
            return function(_, map)
                map({ "i", "n" }, "<M-i>", function(prompt_bufnr)
                    local prompt = action_state.get_current_line()
                    actions.close(prompt_bufnr)
                    if all then
                        builtin[kind]({ default_text = prompt })
                    else
                        search_all(kind, { default_text = prompt })
                    end
                end, { desc = all and "Hide ignored files" or "Show ignored files" })
                return true
            end
        end

        -- The setup below makes filtered mode the default for these pickers, so
        -- `:Telescope live_grep` etc. get it too. The `attach_mappings` here runs
        -- after that default's, so its <M-i> (back to filtered) is the one bound.
        search_all = function(kind, opts)
            local title = ({ find_files = "Find Files", live_grep = "Live Grep" })[kind]
                or ("Find Word (%s)"):format(vim.fn.expand("<cword>"))
            builtin[kind](vim.tbl_extend("force", filter_opts(kind, true), {
                prompt_title = title .. " — all files",
                attach_mappings = toggle_ignored(kind, true),
            }, opts or {}))
        end

        local function filtered(kind)
            return vim.tbl_extend("force", filter_opts(kind, false), {
                attach_mappings = toggle_ignored(kind, false),
            })
        end

        -- Inside any picker, <c-/> (insert) or ? (normal) lists its mappings.
        require("telescope").setup({
            defaults = {
                sorting_strategy = "ascending",
                layout_config = {
                    prompt_position = "top",
                },
                -- mappings = {
                --   i = { ['<c-enter>'] = 'to_fuzzy_refine' },
                -- },
            },
            pickers = {
                buffers = {
                    show_all_buffers = true,
                    sort_mru = true,
                },
                find_files = filtered("find_files"),
                live_grep = filtered("live_grep"),
                grep_string = filtered("grep_string"),
            },
            extensions = {
                ["ui-select"] = {
                    require("telescope.themes").get_dropdown(),
                },
                -- Off: persisted.nvim is not installed; neovim-session-manager
                -- handles sessions.
                -- persisted = {
                --     layout_config = { width = 0.55, height = 0.55 },
                -- },
            },
        })

        -- All extension loads are pcall'd: noice is VeryLazy and so may not have
        -- loaded yet at VimEnter, and fzf needs a successful `make`.
        for _, ext in ipairs({ "fzf", "ui-select", "cmdline", "noice" }) do
            pcall(require("telescope").load_extension, ext)
        end

        -- Keymaps. See `:help telescope.builtin`
        local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { desc = desc })
        end

        map("<leader>ff", builtin.find_files, "[F]ind [F]iles")
        map("<leader>sh", builtin.help_tags, "[S]earch [H]elp")
        map("<leader>sk", builtin.keymaps, "[S]earch [K]eymaps")
        map("<leader>ss", builtin.builtin, "[S]earch [S]elect Telescope")
        map("<leader>sw", builtin.grep_string, "[S]earch current [W]ord")
        map("<leader>sd", builtin.diagnostics, "[S]earch [D]iagnostics")
        map("<leader>sr", builtin.resume, "[S]earch [R]esume")
        map("<leader>s.", builtin.oldfiles, '[S]earch Recent Files ("." for repeat)')
        map("<leader>sg", builtin.live_grep, "[S]earch by [G]rep")

        -- Same searches including ignored files (node_modules, dist, ...).
        map("<leader>fF", function()
            search_all("find_files")
        end, "[F]ind [F]iles (all)")
        map("<leader>sG", function()
            search_all("live_grep")
        end, "[S]earch by [G]rep (all)")
        map("<leader>sW", function()
            search_all("grep_string")
        end, "[S]earch current [W]ord (all)")

        map("<space><space>", function()
            builtin.buffers({ sort_mru = true })
        end, "[ ] Find existing buffers")

        map("<leader>/", function()
            builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
                winblend = 10,
                previewer = false,
            }))
        end, "[/] Fuzzily search in current buffer")

        map("<leader>s/", function()
            builtin.live_grep({
                grep_open_files = true,
                prompt_title = "Live Grep in Open Files",
            })
        end, "[S]earch [/] in Open Files")
    end,
}
