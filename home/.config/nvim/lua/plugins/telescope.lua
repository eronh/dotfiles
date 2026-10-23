-- Telescope is the picker for this config. snacks.picker is explicitly disabled
-- in snacks.lua so the two don't both claim vim.ui.select and the same keys.
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
        { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
    },
    keys = {
        { "Q", "<cmd>Telescope cmdline<cr>", desc = "Cmdline" },
    },
    config = function()
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
                find_files = {
                    find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
                    -- hidden = true,
                },
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
        local builtin = require("telescope.builtin")
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

        map("<leader>sg", function()
            builtin.live_grep({ additional_args = { "--hidden", "--no-ignore" } })
        end, "[S]earch by [G]rep")

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
