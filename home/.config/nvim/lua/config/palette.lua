-- A VS Code-style command palette: <F1> or <leader><leader> (`;;`). Actions are
-- named like VS Code's ("File: Copy Relative Path of Active File") and
-- fuzzy-searched in Telescope. The right column shows the mapping or Ex command
-- that does the same thing, so the palette also teaches the bindings. Recently
-- used actions are listed first.
--
-- Opened from visual mode, line-based actions (sort, copy path with lines, git
-- links, comment, send to Claude) use the selected lines, and `gv` still
-- reselects them afterwards.
--
-- To add an action, append to `items`:
--   name  what you type to find it, "Category: Action"
--   keys  a mapping to run, e.g. "<leader>ff". The action is hidden when the
--         mapping doesn't exist in the current buffer (LSP-only keys, say).
--         `mode = "x"` marks a visual-mode mapping: it reselects and runs it.
--   cmd   an Ex command to run, e.g. "Lazy"
--   run   function(ctx) for anything else; ctx.range is { first, last } when
--         opened from visual mode. With `run`, `keys`/`cmd` are only shown.
--   hint  text for the right column, when it isn't `keys` or `cmd`
--   when  function(ctx) -> boolean; the action is hidden when false

local M = {}

local function notify(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO, { title = "Command Palette" })
end

local function copy(text)
    vim.fn.setreg("+", text)
    notify("Copied " .. text)
end

local function feed(keys)
    vim.api.nvim_feedkeys(vim.keycode(keys), "m", false)
end

local function has_file()
    return vim.bo.buftype == "" and vim.api.nvim_buf_get_name(0) ~= ""
end

local function has_lsp()
    return #vim.lsp.get_clients({ bufnr = 0 }) > 0
end

local function is_wsl()
    return vim.fn.has("wsl") == 1
end

local function windows_path()
    return vim.trim(vim.fn.system({ "wslpath", "-w", vim.fn.expand("%:p") }))
end

-- The Ex range for an action: the selected lines, else the whole file.
local function range(ctx)
    return ctx.range and (ctx.range[1] .. "," .. ctx.range[2]) or "%"
end

local function lines(ctx)
    if ctx.range then
        return ctx.range[1], ctx.range[2]
    end
    return 1, vim.api.nvim_buf_line_count(0)
end

local function line_suffix(ctx)
    local first, last = ctx.range and ctx.range[1] or vim.fn.line("."), ctx.range and ctx.range[2]
    return (last and last ~= first) and (":%d-%d"):format(first, last) or (":" .. first)
end

local function gitbrowse(ctx, opts)
    local first, last = ctx.range and ctx.range[1] or vim.fn.line("."), ctx.range and ctx.range[2]
    Snacks.gitbrowse(vim.tbl_extend("force", { line_start = first, line_end = last or first }, opts))
end

-- Rewrites only the leading whitespace, unlike :retab! which also turns runs
-- of spaces inside a line (alignment, strings) into tabs.
local function convert_indent(ctx, use_tabs)
    local first, last = lines(ctx)
    local unit = vim.fn.shiftwidth()
    local text = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
    for i, line in ipairs(text) do
        local indent = line:match("^[ \t]*")
        local width = vim.fn.strdisplaywidth(indent)
        local new = use_tabs and (("\t"):rep(math.floor(width / unit)) .. (" "):rep(width % unit)) or (" "):rep(width)
        text[i] = new .. line:sub(#indent + 1)
    end
    vim.api.nvim_buf_set_lines(0, first - 1, last, false, text)
    vim.bo.expandtab = not use_tabs
    if use_tabs then
        vim.bo.tabstop = unit
    end
end

local items = {
    -- Files
    { name = "File: Copy Path of Active File", cmd = "CAbsPath", when = has_file },
    { name = "File: Copy Relative Path of Active File", cmd = "CRelPath", when = has_file },
    {
        name = "File: Copy Relative Path with Line Numbers",
        hint = "path:line",
        when = has_file,
        run = function(ctx)
            copy(vim.fn.expand("%:.") .. line_suffix(ctx))
        end,
    },
    {
        name = "File: Copy File Name",
        when = has_file,
        run = function()
            copy(vim.fn.expand("%:t"))
        end,
    },
    {
        name = "File: Copy Windows Path of Active File",
        keys = "<leader>cw",
        when = function()
            return is_wsl() and has_file()
        end,
        run = function()
            copy(windows_path())
        end,
    },
    {
        name = "File: Reveal in File Explorer (Windows)",
        when = function()
            return is_wsl() and has_file() and vim.fn.executable("explorer.exe") == 1
        end,
        run = function()
            vim.system({ "explorer.exe", "/select," .. windows_path() }, { detach = true })
        end,
    },
    { name = "File: Reveal Active File in Explorer View", cmd = "Neotree reveal", when = has_file },
    { name = "File: New Untitled File", cmd = "enew" },
    {
        name = "File: Rename Active File",
        when = has_file,
        run = function()
            Snacks.rename.rename_file()
        end,
    },
    { name = "File: Revert File (Discard Unsaved Changes)", cmd = "edit!", when = has_file },
    { name = "File: Save without Formatting", cmd = "noautocmd write", when = has_file },
    { name = "File: Open Recent", keys = "<leader>s." },
    { name = "Go to File...", keys = "<leader>ff" },
    { name = "Go to File... (Including Ignored)", keys = "<leader>fF" },

    -- Editors and layout
    { name = "View: Show Open Editors", keys = "<space><space>" },
    { name = "View: Close Editor", keys = "<leader>q" },
    {
        name = "View: Close Other Editors",
        run = function()
            Snacks.bufdelete.other()
        end,
    },
    { name = "View: Close All Editors", keys = "<C-M-W>" },
    { name = "View: Split Editor Right", cmd = "vsplit", hint = "<C-w>v" },
    { name = "View: Split Editor Down", cmd = "split", hint = "<C-w>s" },
    { name = "View: Toggle Explorer Sidebar", keys = "<C-S-\\>" },
    { name = "View: Focus Explorer", keys = "<C-\\>" },
    {
        name = "View: Toggle Terminal",
        run = function()
            Snacks.terminal.toggle()
        end,
    },
    {
        name = "View: Toggle Word Wrap",
        run = function()
            vim.wo.wrap = not vim.wo.wrap
            notify("Word wrap " .. (vim.wo.wrap and "on" or "off"))
        end,
    },
    {
        name = "View: Toggle Zen Mode",
        run = function()
            Snacks.zen()
        end,
    },
    { name = "View: Toggle Sticky Scroll", keys = "<leader>ut" },
    { name = "View: Toggle Inlay Hints", keys = "<leader>th" },
    { name = "View: Toggle Undo History", keys = "<leader>u" },
    { name = "View: Fold All", keys = "zM" },
    { name = "View: Unfold All", keys = "zR" },
    {
        name = "View: Show Notification History",
        run = function()
            Snacks.notifier.show_history()
        end,
    },
    { name = "Scratch: Toggle Scratch Buffer", keys = "<leader>." },

    -- Search and navigation
    { name = "Search: Find in Files", keys = "<leader>sg" },
    { name = "Search: Find in Files (Including Ignored)", keys = "<leader>sG" },
    { name = "Search: Find Word Under Cursor in Files", keys = "<leader>sw" },
    { name = "Search: Find in Active File", keys = "<leader>/" },
    { name = "Search: Find in Open Files", keys = "<leader>s/" },
    { name = "Search: Find TODO Comments", keys = "<leader>st" },
    { name = "Search: Resume Last Search", keys = "<leader>sr" },
    {
        name = "Search: Replace in Active File",
        hint = ":%s/old/new/g",
        run = function(ctx)
            feed(":" .. (ctx.range and "'<,'>" or "%") .. "s/")
        end,
    },
    {
        name = "Go to Line...",
        hint = "{n}G",
        run = function()
            vim.ui.input({ prompt = "Line: " }, function(input)
                local n = tonumber(input)
                if n then
                    vim.cmd("normal! " .. n .. "G")
                end
            end)
        end,
    },
    { name = "Go to Symbol in Editor", keys = "<leader>ds", when = has_lsp },
    { name = "Go to Symbol in Workspace", keys = "<leader>ws", when = has_lsp },
    { name = "Go to Definition", keys = "gd", when = has_lsp },
    { name = "Go to References", keys = "gr", when = has_lsp },
    { name = "Problems: Show All Diagnostics", keys = "<leader>sd" },

    -- Code
    { name = "Rename Symbol", keys = "<leader>rn", when = has_lsp },
    { name = "Code Actions / Quick Fix", keys = "<leader>ca", when = has_lsp },
    { name = "Format Document", keys = "<leader>fm" },
    {
        name = "Organize Imports",
        when = has_lsp,
        run = function()
            vim.lsp.buf.code_action({
                context = { only = { "source.organizeImports" }, diagnostics = {} },
                apply = true,
            })
        end,
    },
    {
        name = "Toggle Line Comment",
        hint = "gcc",
        run = function(ctx)
            feed(ctx.range and "gvgc" or "gcc")
        end,
    },
    {
        name = "Sort Lines Ascending",
        hint = ":sort",
        run = function(ctx)
            vim.cmd(range(ctx) .. "sort")
        end,
    },
    {
        name = "Sort Lines Descending",
        hint = ":sort!",
        run = function(ctx)
            vim.cmd(range(ctx) .. "sort!")
        end,
    },
    {
        name = "Trim Trailing Whitespace",
        run = function(ctx)
            local view = vim.fn.winsaveview()
            vim.cmd("keeppatterns " .. range(ctx) .. [[s/\s\+$//e]])
            vim.fn.winrestview(view)
        end,
    },
    {
        name = "Convert Indentation to Spaces",
        run = function(ctx)
            convert_indent(ctx, false)
        end,
    },
    {
        name = "Convert Indentation to Tabs",
        run = function(ctx)
            convert_indent(ctx, true)
        end,
    },
    {
        name = "Change Language Mode",
        hint = ":set ft=",
        run = function()
            require("telescope.builtin").filetypes()
        end,
    },
    {
        name = "Change End of Line Sequence",
        hint = ":set ff=",
        run = function()
            vim.ui.select({ "unix", "dos" }, {
                prompt = "End of line (now " .. vim.bo.fileformat .. ")",
                format_item = function(ff)
                    return ff == "unix" and "LF (unix)" or "CRLF (dos)"
                end,
            }, function(ff)
                if ff then
                    vim.bo.fileformat = ff
                end
            end)
        end,
    },
    { name = "Edit: Paste from Yank History", keys = "<leader>yp" },
    { name = "Editor: Toggle Auto Closing Brackets", keys = "<leader>up" },

    -- Git
    { name = "Git: Open LazyGit", keys = "<leader>lg" },
    { name = "Git: Open Changes (Diff with Index)", keys = "<leader>hd" },
    { name = "Git: Preview Change Under Cursor", keys = "<leader>hp" },
    { name = "Git: Revert Change Under Cursor", keys = "<leader>hr" },
    { name = "Git: Show Blame for Line", keys = "<leader>hb" },
    {
        name = "Git: Show Line History",
        keys = "<leader>hl",
        when = has_file,
        run = function(ctx)
            local range = ctx.range or {}
            require("config.git_history").line(range[1], range[2])
        end,
    },
    {
        name = "Git: Show File History",
        keys = "<leader>hf",
        when = has_file,
        run = function()
            require("config.git_history").file()
        end,
    },
    { name = "Git: Toggle Inline Blame", keys = "<leader>ub" },
    {
        name = "Git: Open File on Remote",
        when = has_file,
        run = function(ctx)
            gitbrowse(ctx, { what = "file" })
        end,
    },
    {
        name = "Git: Copy Permalink to Line(s)",
        when = has_file,
        run = function(ctx)
            gitbrowse(ctx, { what = "permalink", notify = false, open = copy })
        end,
    },

    -- AI
    { name = "Claude: Toggle Claude Code", keys = "<C-,>" },
    { name = "Claude: Add Active File to Context", keys = "<leader>ab" },
    { name = "Claude: Send Selection", keys = "<leader>as", mode = "x" },
    { name = "Claude: Accept Diff", keys = "<leader>aa" },
    { name = "Claude: Reject Diff", keys = "<leader>ad" },
    { name = "opencode: Ask...", keys = "<leader>oa" },
    { name = "opencode: Select Action...", keys = "<leader>os" },

    -- Sessions
    { name = "Session: Save", keys = "<leader>qs" },
    { name = "Session: Load Last", keys = "<leader>ql" },
    { name = "Session: Browse", keys = "<leader>qb" },

    -- Preferences, plugins, help
    { name = "Preferences: Color Theme", keys = "<leader>tt" },
    { name = "Preferences: Keyboard Shortcuts", keys = "<leader>sk" },
    {
        name = "Preferences: Open Settings (Config Files)",
        run = function()
            require("telescope.builtin").find_files({
                cwd = vim.fn.stdpath("config"),
                prompt_title = "Config Files",
            })
        end,
    },
    { name = "Extensions: Manage Plugins (Lazy)", cmd = "Lazy" },
    { name = "Extensions: Manage Language Servers and Tools (Mason)", cmd = "Mason" },
    { name = "LSP: Restart Language Server", cmd = "LspRestart", when = has_lsp },
    { name = "LSP: Show Info", cmd = "checkhealth vim.lsp" },
    { name = "Help: Search Help", keys = "<leader>sh" },
    { name = "Show All Commands (Ex)", cmd = "Telescope commands" },
    { name = "Developer: Inspect Editor Tokens and Scopes", cmd = "Inspect" },
    { name = "Developer: Show Messages", cmd = "messages" },
    { name = "Developer: Check Health", cmd = "checkhealth" },
    { name = "Developer: Startup Profile", cmd = "Lazy profile" },
}

local function available(item, ctx)
    if item.mode == "x" and not ctx.range then
        return false
    end
    if item.keys and not item.run and vim.fn.maparg(item.keys, item.mode or "n") == "" then
        return false
    end
    return not item.when or item.when(ctx)
end

local function hint(item)
    if item.hint then
        return item.hint
    elseif item.keys then
        local leader = vim.g.mapleader or "\\"
        return (item.keys:gsub("<[Ll]eader>", leader == " " and "<Space>" or leader))
    elseif item.cmd then
        return ":" .. item.cmd
    end
    return ""
end

local function run(item, ctx)
    if item.run then
        item.run(ctx)
    elseif item.cmd then
        vim.cmd(item.cmd)
    else
        feed((item.mode == "x" and "gv" or "") .. item.keys)
    end
end

-- Recently used actions, newest first, kept across sessions.
local recent_file = vim.fn.stdpath("state") .. "/palette-recent.json"
local max_recent = 10

local function load_recent()
    local ok, list = pcall(function()
        return vim.json.decode(table.concat(vim.fn.readfile(recent_file), "\n"))
    end)
    return ok and type(list) == "table" and list or {}
end

local function remember(name)
    local list = vim.tbl_filter(function(n)
        return n ~= name
    end, load_recent())
    table.insert(list, 1, name)
    pcall(vim.fn.writefile, { vim.json.encode(vim.list_slice(list, 1, max_recent)) }, recent_file)
end

local function ordered(visible)
    local by_name, seen, out = {}, {}, {}
    for _, item in ipairs(visible) do
        by_name[item.name] = item
    end
    for _, name in ipairs(load_recent()) do
        if by_name[name] then
            table.insert(out, by_name[name])
            seen[name] = true
        end
    end
    for _, item in ipairs(visible) do
        if not seen[item.name] then
            table.insert(out, item)
        end
    end
    return out
end

---@param ctx? { range?: integer[] }
function M.open(ctx)
    ctx = ctx or {}
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local entry_display = require("telescope.pickers.entry_display")

    local list = ordered(vim.tbl_filter(function(item)
        return available(item, ctx)
    end, items))

    local name_width, hint_width = 0, 0
    for _, item in ipairs(list) do
        name_width = math.max(name_width, vim.fn.strdisplaywidth(item.name))
        hint_width = math.max(hint_width, vim.fn.strdisplaywidth(hint(item)))
    end
    local displayer = entry_display.create({
        separator = "  ",
        items = { { width = name_width }, { remaining = true } },
    })

    local title = "Command Palette"
    if ctx.range then
        title = ("%s (lines %d-%d)"):format(title, ctx.range[1], ctx.range[2])
    end

    require("telescope.pickers")
        .new(
            require("telescope.themes").get_dropdown({
                previewer = false,
                layout_config = {
                    width = function(_, cols)
                        return math.min(cols - 4, name_width + hint_width + 10)
                    end,
                    height = function(_, _, lines_)
                        return math.min(lines_ - 4, 20)
                    end,
                },
            }),
            {
                prompt_title = title,
                finder = require("telescope.finders").new_table({
                    results = list,
                    entry_maker = function(item)
                        return {
                            value = item,
                            ordinal = item.name,
                            display = function()
                                return displayer({ item.name, { hint(item), "TelescopeResultsComment" } })
                            end,
                        }
                    end,
                }),
                sorter = require("telescope.config").values.generic_sorter({}),
                attach_mappings = function(prompt_bufnr)
                    actions.select_default:replace(function()
                        local entry = action_state.get_selected_entry()
                        actions.close(prompt_bufnr)
                        if not entry then
                            return
                        end
                        remember(entry.value.name)
                        -- After close, so the action runs in the original
                        -- window and can open a picker of its own.
                        vim.schedule(function()
                            local ok, err = pcall(run, entry.value, ctx)
                            if not ok then
                                notify(entry.value.name .. ": " .. tostring(err), vim.log.levels.ERROR)
                            end
                        end)
                    end)
                    return true
                end,
            }
        )
        :find()
end

local function open_with_selection()
    local first, last = vim.fn.line("v"), vim.fn.line(".")
    if first > last then
        first, last = last, first
    end
    -- Leave visual mode: sets '< and '> (for gv) and returns to normal mode.
    vim.cmd("normal! \27")
    M.open({ range = { first, last } })
end

-- <F1> is VS Code's other palette key. Ctrl+Shift+P is taken by Windows
-- Terminal's own palette.
for _, lhs in ipairs({ "<F1>", "<leader><leader>" }) do
    vim.keymap.set("n", lhs, function()
        M.open()
    end, { desc = "Command palette" })
    vim.keymap.set("x", lhs, open_with_selection, { desc = "Command palette (selected lines)" })
end

return M
