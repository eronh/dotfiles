return {
    "Shatur/neovim-session-manager",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = function(_, opts)
        local session_manager = require("session_manager")
        local config = require("session_manager.config")

        -- Quick edits of single files must not overwrite the cwd's session.
        -- `nvim .` (directory args only) still counts as a project session.
        local started_with_files = vim.iter(vim.fn.argv()):any(function(arg)
            return vim.fn.isdirectory(arg) == 0
        end)
        require("session_manager").setup(vim.tbl_deep_extend("force", opts, {
            autoload_mode = { config.AutoloadMode.CurrentDir },
            autosave_last_session = not started_with_files,
            load_include_current = true,
        }))

        -- Save the current session
        vim.keymap.set("n", "<leader>qs", function()
            session_manager.save_current_session()
            vim.notify("Session saved! 🎯")
        end, { noremap = true, silent = true, desc = "Save session" })

        -- Load the last session
        vim.keymap.set("n", "<leader>ql", function()
            session_manager.load_last_session()
        end, { noremap = true, silent = true, desc = "Load last session" })

        -- Delete the current session
        vim.keymap.set("n", "<leader>qd", function()
            session_manager.delete_session()
        end, { noremap = true, silent = true, desc = "Delete session" })

        -- Browse and load a session using Telescope
        vim.keymap.set("n", "<leader>qb", function()
            require("session_manager").load_session(false)
        end, { noremap = true, silent = true, desc = "Browse sessions" })

        -- Auto save session
        vim.api.nvim_create_autocmd({ "BufWritePre" }, {
            callback = function()
                if started_with_files then
                    return
                end
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    -- Don't save while there's any 'nofile' buffer open.
                    if vim.api.nvim_get_option_value("buftype", { buf = buf }) == "nofile" then
                        return
                    end
                end
                session_manager.save_current_session()
            end,
        })

        -- https://github.com/Shatur/neovim-session-manager?tab=readme-ov-file#autocommands
        local config_group = vim.api.nvim_create_augroup("MyConfigGroup", {}) -- A global group for all your config autocommands
        -- The plugin skips autoload whenever there are args, so `nvim .` never restored.
        -- Load the directory's session when the only arg is a directory.
        vim.api.nvim_create_autocmd("VimEnter", {
            group = config_group,
            nested = true,
            callback = function()
                if vim.fn.argc() ~= 1 or vim.g.started_with_stdin then
                    return
                end
                local dir = vim.uv.fs_realpath(vim.fn.argv(0))
                if not dir or vim.fn.isdirectory(dir) == 0 then
                    return
                end
                local session = config.dir_to_session_filename(dir)
                if session:exists() then
                    vim.cmd("%argdel")
                    require("session_manager.utils").load_session(session.filename)
                end
            end,
        })
        vim.api.nvim_create_autocmd({ "User" }, {
            pattern = "SessionLoadPost",
            group = config_group,
            callback = function()
                require("neo-tree.command").execute({
                    show = true,
                    toggle = false,
                })
            end,
        })
    end,
}
