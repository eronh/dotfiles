-- Only the settings that differ from neo-tree's defaults are listed here. The
-- full annotated default config is upstream in `lua/neo-tree/defaults.lua`, or
-- `:h neo-tree-configuration`; it used to be pasted into this file in full.

local toggle_focus_keymap = "\\"
local toggle_reveal_keymap = "<C-\\>"

local function focus_left_window()
    vim.cmd("wincmd h")
end

return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
        },

        -- Was "Neotree focus", which is not a valid command name — only the
        -- `keys` below were actually loading the plugin.
        cmd = "Neotree",
        keys = {
            { toggle_focus_keymap, ":Neotree focus last<CR>", desc = "NeoTree focus", silent = true },
            { toggle_reveal_keymap, ":Neotree reveal last<CR>", desc = "NeoTree reveal", silent = true },
        },

        deactivate = function()
            vim.cmd([[Neotree close]])
        end,

        init = function()
            -- FIX: use `autocmd` for lazy-loading neo-tree instead of directly requiring it,
            -- because `cwd` is not set up properly.
            vim.api.nvim_create_autocmd("BufEnter", {
                group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
                desc = "Start Neo-tree with directory",
                once = true,
                callback = function()
                    if package.loaded["neo-tree"] then
                        return
                    end
                    local stats = vim.uv.fs_stat(vim.fn.argv(0))
                    if stats and stats.type == "directory" then
                        require("neo-tree")
                    end
                end,
            })
        end,

        config = function(_, opts)
            local events = require("neo-tree.events")
            local utils = require("neo-tree.utils")
            local sources_manager = require("neo-tree.sources.manager")
            local ui_inputs = require("neo-tree.ui.inputs")

            -- Keep LSP clients (and their rename-aware imports) in step when a
            -- file is moved from inside the tree.
            local function on_move(data)
                Snacks.rename.on_rename_file(data.source, data.destination)
            end

            vim.api.nvim_create_autocmd("TermClose", {
                pattern = "*lazygit",
                callback = function()
                    if package.loaded["neo-tree.sources.git_status"] then
                        require("neo-tree.sources.git_status").refresh()
                    end
                end,
            })

            ---@see https://github.com/nvim-neo-tree/neo-tree.nvim/issues/202#issuecomment-2538240927
            local function confirm_trash(msg, paths, state)
                ui_inputs.confirm(msg, function(confirmed)
                    if not confirmed then
                        return
                    end
                    for _, path in ipairs(paths) do
                        vim.fn.system({ "trash", vim.fn.fnameescape(path) })
                    end
                    sources_manager.refresh(state.name)
                end)
            end

            local function handle_move_to_trash(state)
                local path = state.tree:get_node().path
                local _, name = utils.split_path(path)
                confirm_trash(string.format("Are you sure you want to trash '%s'?", name), { path }, state)
            end

            local function handle_move_to_trash_in_visual_mode(state, selected_nodes)
                local paths = vim.tbl_map(function(node)
                    return node.path
                end, selected_nodes)
                confirm_trash("Are you sure you want to trash " .. #paths .. " files ?", paths, state)
            end

            require("neo-tree").setup({
                -- document_symbols is the addition; the other three are default.
                sources = { "filesystem", "buffers", "git_status", "document_symbols" },

                auto_clean_after_session_restore = true, -- Drop broken neo-tree buffers saved in sessions
                auto_restore_session_experimental = true, -- https://github.com/nvim-neo-tree/neo-tree.nvim/issues/1365
                open_files_using_relative_paths = true,
                -- "edgy" matters here: neo-tree lives in an edgy sidebar.
                open_files_do_not_replace_types = { "terminal", "Trouble", "qf", "edgy" },

                event_handlers = vim.list_extend(opts.event_handlers or {}, {
                    { event = events.FILE_MOVED, handler = on_move },
                    { event = events.FILE_RENAMED, handler = on_move },
                }),

                default_component_configs = {
                    name = {
                        trailing_slash = true,
                        highlight_opened_files = true, -- Requires `enable_opened_markers = true` (default)
                    },
                },

                window = {
                    position = "right", -- edgy pins this side; see edgy.lua
                    width = 48, -- keep in step with edgy's `right = { size = 48 }`
                    mappings = {
                        ["<Esc>"] = focus_left_window,
                        [toggle_focus_keymap] = focus_left_window,
                        [toggle_reveal_keymap] = "close_window",
                        ["b"] = "close_node",
                        ["d"] = "trash", -- default is "delete"
                        -- Default binds these to <C-b>/<C-f>.
                        ["<C-d>"] = { "scroll_preview", config = { direction = -10 } },
                        ["<C-u>"] = { "scroll_preview", config = { direction = 10 } },
                        ["P"] = {
                            "toggle_preview",
                            -- snacks' image module is off, so don't ask for it.
                            config = { use_float = true, use_image_nvim = false },
                        },
                    },
                },

                filesystem = {
                    commands = {
                        trash = handle_move_to_trash,
                        trash_visual_mode = handle_move_to_trash_in_visual_mode,
                    },
                    window = {
                        mappings = {
                            ["d"] = "trash",
                        },
                    },
                    bind_to_cwd = false,
                    follow_current_file = {
                        enabled = true, -- Focus the active buffer's file in the tree
                        leave_dirs_open = true,
                    },
                    -- OS-level watchers, so files an external agent or a rebase
                    -- writes show up without a manual refresh.
                    use_libuv_file_watcher = true,
                    filtered_items = {
                        visible = true, -- Show hidden files, just styled differently
                        hide_dotfiles = true,
                        hide_gitignored = true,
                        never_show = { ".DS_Store" },
                    },
                },

                buffers = {
                    bind_to_cwd = false,
                    follow_current_file = {
                        enabled = true,
                        leave_dirs_open = true,
                    },
                    group_empty_dirs = true,
                },
            })
        end,
    },
}
