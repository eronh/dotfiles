--- Wrapper for running Telescope pickers with a specific cwd.
---
--- This function ensures that any Telescope picker uses `_G.MyGlobal.ROOT`
--- as its working directory (cwd), regardless of Neovim's current directory.
---
--- @param picker string|function The Telescope picker to run. This can be either:
---   - A string (e.g., `"find_files"`, `"live_grep"`) to look up the function dynamically.
---   - A function reference (e.g., `telescope.find_files`, `telescope.live_grep`).
--- @param opts table|nil (Optional) Additional options to pass to the picker.
---
--- @usage
--- my_custom_picker("find_files")   -- Call by name
--- my_custom_picker(telescope.find_files) -- Call by function reference
local function my_custom_picker(picker, opts)
    opts = opts or {}
    opts.cwd = Heron.ROOT -- Always use the global root

    if type(picker) == "string" then
        -- If a string is passed, dynamically call the function from telescope.builtin
        telescope[picker](opts)
    elseif type(picker) == "function" then
        -- If a function reference is passed, call it directly
        picker(opts)
    else
        error("Invalid argument: Expected function or string")
    end
end

return {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    defaults = { cwd = Heron.ROOT },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "jonarrien/telescope-cmdline.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",

            -- `build` is used to run some command when the plugin is installed/updated.
            -- This is only run then, not every time Neovim starts up.
            build = "make",

            -- `cond` is a condition used to determine whether this plugin should be
            -- installed and loaded.
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
        -- Telescope is a fuzzy finder that comes with a lot of different things that
        -- it can fuzzy find! It's more than just a "file finder", it can search
        -- many different aspects of Neovim, your workspace, LSP, and more!
        --
        -- The easiest way to use Telescope, is to start by doing something like:
        --  :Telescope help_tags
        --
        -- After running this command, a window will open up and you're able to
        -- type in the prompt window. You'll see a list of `help_tags` options and
        -- a corresponding preview of the help.
        --
        -- Two important keymaps to use while in Telescope are:
        --  - Insert mode: <c-/>
        --  - Normal mode: ?
        --
        -- This opens a window that shows you all of the keymaps for the current
        -- Telescope picker. This is really useful to discover what Telescope can
        -- do as well as how to actually do it!

        -- [[ Configure Telescope ]]
        -- See `:help telescope` and `:help telescope.setup()`
        require("telescope").setup({
            -- You can put your default mappings / updates / etc. in here
            --  All the info you're looking for is in `:help telescope.setup()`
            --
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
                persisted = {
                    layout_config = { width = 0.55, height = 0.55 },
                },
            },
        })

        -- Enable Telescope extensions if they are installed
        pcall(require("telescope").load_extension, "fzf")
        pcall(require("telescope").load_extension, "ui-select")
        -- pcall(require("telescope").load_extension, "harpoon")
        pcall(require("telescope").load_extension, "persisted")

        -- Keymaps
        -- See `:help telescope.builtin`
        local builtin = require("telescope.builtin")

        vim.keymap.set("n", "<leader>ff", function()
            my_custom_picker(builtin.find_files)
        end, { desc = "[F]ind [F]iles" })

        vim.keymap.set("n", "<leader>sg", function()
            my_custom_picker(function()
                builtin.live_grep({
                    additional_args = { "--hidden", "--no-ignore" },
                })
            end)
        end, { desc = "[S]earch by [G]rep" })

        vim.keymap.set("n", "<leader>sh", function()
            my_custom_picker(builtin.help_tags)
        end, { desc = "[S]earch [H]elp" })

        vim.keymap.set("n", "<leader>sk", function()
            my_custom_picker(builtin.keymaps)
        end, { desc = "[S]earch [K]eymaps" })

        vim.keymap.set("n", "<leader>ss", function()
            my_custom_picker(builtin.builtin)
        end, { desc = "[S]earch [S]elect Telescope" })

        vim.keymap.set("n", "<leader>sw", function()
            my_custom_picker(builtin.grep_string)
        end, { desc = "[S]earch current [W]ord" })

        vim.keymap.set("n", "<leader>sd", function()
            my_custom_picker(builtin.diagnostics)
        end, { desc = "[S]earch [D]iagnostics" })

        vim.keymap.set("n", "<leader>sr", function()
            my_custom_picker(builtin.resume)
        end, { desc = "[S]earch [R]esume" })

        vim.keymap.set("n", "<leader>s.", function()
            my_custom_picker(builtin.oldfiles)
        end, { desc = '[S]earch Recent Files ("." for repeat)' })

        vim.keymap.set("n", "<space><space>", function()
            builtin.buffers({ sort_mru = true })
        end, { desc = "[ ] Find existing buffers" })

        vim.keymap.set("n", "<leader>/", function()
            -- You can pass additional configuration to Telescope to change the theme, layout, etc.
            builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
                winblend = 10,
                previewer = false,
            }))
        end, { desc = "[/] Fuzzily search in current buffer" })

        vim.keymap.set("n", "<leader>s/", function()
            builtin.live_grep({
                grep_open_files = true,
                prompt_title = "Live Grep in Open Files",
            })
        end, { desc = "[S]earch [/] in Open Files" })

        -- Load extensions
        require("telescope").load_extension("cmdline")
        require("telescope").load_extension("noice")
        -- require("telescope").load_extension("possession")
    end,
}
