-- Only the settings that differ from neo-tree's defaults are listed here. The
-- full annotated default config is upstream in `lua/neo-tree/defaults.lua`, or
-- `:h neo-tree-configuration`; it used to be pasted into this file in full.

-- Each key focuses its pane, and pressed again inside that pane goes back to
-- the editor. From the other pane it falls through to the global mapping, so
-- `\` and `<C-\>` also hop between Open Editors and Files.
local open_editors_keymap = "<C-\\>"
local files_keymap = "\\"

-- Ctrl+Shift+\ reaches nvim as <C-S-\> (CSI 92;6u) or <C-|> (CSI 124;5u),
-- depending on the terminal. Windows Terminal needs a sendInput binding for
-- it, or it sends the same byte as Ctrl+\.
local toggle_keymaps = { "<C-S-\\>", "<C-|>" }

-- The sidebar is on the left, so the editor is to its right.
local function focus_editor()
    vim.cmd("wincmd l")
end

-- Hide every neo-tree window in the tab, or bring the sidebar back without
-- moving the cursor (opening Files pulls Open Editors in with it).
local function toggle_sidebar()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neo-tree" then
            vim.cmd("Neotree close")
            return
        end
    end
    vim.cmd("Neotree show filesystem")
end

-- Directories of installed or generated files. Opening a file inside one
-- expands it in the tree (follow_current_file + leave_dirs_open), and nothing
-- collapses it again, so once the file is closed the tree collapses it here.
local collapse_on_close = {}
for _, names in ipairs({
    { "node_modules", "bower_components", ".yarn", ".pnpm-store", "vendor" }, -- dependencies
    { "dist", "build", "out", "target", "coverage" }, -- build output
    { ".next", ".nuxt", ".svelte-kit", ".turbo", ".angular", ".parcel-cache", ".gradle" }, -- tool caches
    { ".venv", "venv", "__pycache__", "site-packages", ".tox", ".mypy_cache", ".pytest_cache" }, -- Python
    { ".git" },
}) do
    for _, name in ipairs(names) do
        collapse_on_close[name] = true
    end
end

local function open_file_paths()
    local paths = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buflisted and vim.bo[buf].buftype == "" then
            local name = vim.api.nvim_buf_get_name(buf)
            if name ~= "" then
                table.insert(paths, name)
            end
        end
    end
    return paths
end

local function holds_open_file(dir, open_paths)
    return vim.iter(open_paths):any(function(p)
        return vim.fs.relpath(dir, p) ~= nil
    end)
end

-- The outermost collapse-on-close dir between `root` and the closed file, or,
-- when other open files still live under it, the outermost dir further down
-- that holds none of them. Nil if the file isn't under such a dir.
local function dir_to_collapse(root, path, open_paths)
    local rel = vim.fs.relpath(root, path)
    if not rel then
        return nil
    end
    local parts = vim.split(rel, "/", { plain = true })
    local dir, inside = root, false
    for i = 1, #parts - 1 do
        dir = vim.fs.joinpath(dir, parts[i])
        inside = inside or collapse_on_close[parts[i]] == true
        if inside and not holds_open_file(dir, open_paths) then
            return dir
        end
    end
end

-- Collapse the dir (and every dir expanded under it) in each tab's Files tree.
local function collapse_dirs_of_closed_files(closed)
    local renderer = require("neo-tree.ui.renderer")
    local open_paths = open_file_paths()
    require("neo-tree.sources.manager")._for_each_state("filesystem", function(state)
        local tree = state.tree
        if not (tree and state.path) then
            return
        end
        local changed = false
        for _, path in ipairs(closed) do
            local dir = dir_to_collapse(state.path, path, open_paths)
            if dir and tree:get_node(dir) then
                for _, id in ipairs(renderer.get_expanded_nodes(tree, dir)) do
                    tree:get_node(id):collapse()
                    if state.explicitly_opened_nodes then
                        state.explicitly_opened_nodes[id] = nil
                    end
                    changed = true
                end
            end
        end
        if changed then
            renderer.redraw(state)
        end
    end)
end

local function icon_provider(icon, node)
    if node.type == "directory" then
        local glyph, hl, is_default = MiniIcons.get("directory", node.name)
        if is_default then
            local bare = node.name:lower():gsub("^[._]+", ""):gsub("_+$", "")
            glyph, hl, is_default = MiniIcons.get("directory", bare)
        end
        if not is_default then
            icon.text, icon.highlight = glyph, hl
        end
    elseif node.type == "file" or node.type == "terminal" then
        icon.text, icon.highlight = MiniIcons.get("file", node.type == "terminal" and "terminal" or node.name)
    end
end
local keys = {
    { open_editors_keymap, "<Cmd>Neotree focus position=top buffers<CR>", desc = "NeoTree: focus open editors" },
    { files_keymap,        "<Cmd>Neotree focus filesystem<CR>",           desc = "NeoTree: focus files" },
}
for _, lhs in ipairs(toggle_keymaps) do
    table.insert(keys, { lhs, toggle_sidebar, desc = "NeoTree: toggle sidebar" })
end

return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
        },

        -- Was "Neotree focus", which is not a valid command name — only the
        -- `keys` below were actually loading the plugin.
        cmd = "Neotree",
        keys = keys,

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

            -- Closing several buffers at once (e.g. "close all") is handled
            -- in one pass once they're all gone from the buffer list.
            local closed_files = {}
            vim.api.nvim_create_autocmd("BufDelete", {
                group = vim.api.nvim_create_augroup("Neotree_collapse_on_close", { clear = true }),
                desc = "Collapse dependency/build dirs in neo-tree once their files are closed",
                callback = function(args)
                    local name = vim.api.nvim_buf_get_name(args.buf)
                    if vim.bo[args.buf].buftype ~= "" or name == "" then
                        return
                    end
                    if #closed_files == 0 then
                        vim.schedule(function()
                            local batch = closed_files
                            closed_files = {}
                            collapse_dirs_of_closed_files(batch)
                        end)
                    end
                    table.insert(closed_files, name)
                end,
            })

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
                sort_case_insensitive = true,             -- 'README.md' sorts among 'bootstrap', not before it
                -- "edgy" matters here: neo-tree lives in an edgy sidebar.
                open_files_do_not_replace_types = { "terminal", "Trouble", "qf", "edgy" },

                event_handlers = vim.list_extend(opts.event_handlers or {}, {
                    { event = events.FILE_MOVED, handler = on_move },
                    { event = events.FILE_RENAMED, handler = on_move },
                    {
                        event = events.NEO_TREE_WINDOW_AFTER_OPEN,
                        handler = function(args)
                            local partner = ({
                                filesystem = "position=top buffers",
                                buffers = "filesystem",
                            })[args.source]
                            if partner then
                                vim.schedule(function()
                                    vim.cmd("Neotree show " .. partner)
                                end)
                            end
                        end,
                    },
                    {
                        event = events.AFTER_RENDER,
                        handler = function(state)
                            if state.name == "buffers" then
                                require("edgy.layout").update()
                            end
                        end,
                    },
                }),

                default_component_configs = {
                    icon = { provider = icon_provider },
                    name = {
                        trailing_slash = true,
                        highlight_opened_files = true, -- Requires `enable_opened_markers = true` (default)
                    },
                },

                window = {
                    position = "left", -- edgy pins this side; see edgy.lua
                    width = 48, -- keep in step with edgy's `left = { size = 48 }`
                    mappings = {
                        ["<Esc>"] = focus_editor,
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
                            [files_keymap] = focus_editor,
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
                    window = {
                        mappings = {
                            [open_editors_keymap] = focus_editor,
                        },
                    },
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
