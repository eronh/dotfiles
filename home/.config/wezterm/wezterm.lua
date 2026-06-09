---@class WeztermConfig
---@field font any
---@field font_size number
---@field color_scheme string
---@field hide_tab_bar_if_only_one_tab boolean
---@field tab_bar_at_bottom boolean
---@field use_fancy_tab_bar boolean
---@field colors table
---@field keys table
local wezterm = require("wezterm")

local features = require("./features")
local act = wezterm.action

---@class Config: WeztermConfig
local config = wezterm.config_builder()

config.initial_cols = 130
config.initial_rows = 40

local function get_color_scheme()
    if wezterm.gui.get_appearance():find("Dark") then
        return "Nord (Gogh)"
    else
        return "Solarized Light (Gogh)"
    end
end

config.automatically_reload_config = true
config.scrollback_lines = 100000

config.color_scheme = get_color_scheme()
-- config.font = wezterm.font("Iosevka Nerd Font Mono" --[[{,  weight = "Bold", italic = true } --]])
config.font = wezterm.font_with_fallback({ "IosevkaTerm Nerd Font Mono", "Monaco", "monospace" })
config.font_size = 12

-- 🌙 Transparent background with blur
-- config.window_background_opacity = 0.95 -- 90% opacity (adjust to your liking)
-- config.macos_window_background_blur = 55 -- Adds a blurred effect

-- config.enable_tab_bar = false -- Hide ugly default tab bar
config.tab_bar_at_bottom = true -- Moves the tab bar to the bottom
config.use_fancy_tab_bar = true -- Enables a sleek, modern tab bar
config.hide_tab_bar_if_only_one_tab = true

-- Persistent Sessions (Like Tmux)
-- Auto-save all open tabs and panes so they reopen exactly as you left them:
config.default_prog = { "/bin/zsh", "-l" }
wezterm.on("gui-startup", function(cmd)
    local _, _, window = wezterm.mux.spawn_window(cmd or {})
    window:gui_window():maximize() -- Start maximized
end)

-- Auto-Launch Tmux
-- config.default_prog = { "/opt/homebrew/bin/tmux", "new-session", "-A", "-s", "main" }

-- config.enable_csi_u_key_encoding = true

config.window_decorations = "RESIZE"

config.keys = {

    -- 🪟 Split windows
    { key = "D", mods = "CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "E", mods = "CMD", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

    -- 🔳 Split Panes
    { key = "D", mods = "CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) }, -- Split Horizontally (Cmd + D)
    { key = "E", mods = "CMD", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) }, -- Split Vertically (Cmd + E)

    -- 🧭 Navigation
    { key = "LeftArrow", mods = "ALT", action = act.SendString("\x1bb") }, -- Move back one word (Option + Left)
    { key = "RightArrow", mods = "ALT", action = act.SendString("\x1bf") }, -- Move forward one word (Option + Right)
    { key = "LeftArrow", mods = "CMD", action = act.SendString("\x1bOH") }, -- Move to line start (Cmd + Left)
    { key = "RightArrow", mods = "CMD", action = act.SendString("\x1bOF") }, -- Move to line end (Cmd + Right)

    -- 📝 Editing
    { key = "Backspace", mods = "ALT", action = act.SendString("\x17") }, -- Delete previous word (Option + Backspace)
    { key = "Backspace", mods = "CMD", action = act.SendString("\x15") }, -- Delete entire line (Cmd + Backspace)
    { key = "K", mods = "CTRL", action = act.SendString("\x0b") }, -- Kill text to end of line (Ctrl + K)

    -- 🖥️ Terminal Management
    {
        key = "k",
        mods = "CMD",
        action = act.Multiple({
            act.ClearScrollback("ScrollbackAndViewport"),
            act.SendKey({ key = "L", mods = "CTRL" }),
        }),
    },
    { key = "Q", mods = "CMD", action = act.QuitApplication }, -- Quit WezTerm (Cmd + Q)
    { key = "Return", mods = "CMD", action = act.ToggleFullScreen }, -- Fullscreen (Cmd + Enter)

    -- 🔄 Scrolling
    { key = "UpArrow", mods = "CMD", action = act.ScrollByPage(-1) }, -- Page Up (Cmd + Up)
    { key = "DownArrow", mods = "CMD", action = act.ScrollByPage(1) }, -- Page Down (Cmd + Down)

    -- 📋 Copy/Paste
    { key = "V", mods = "CMD", action = act.PasteFrom("Clipboard") }, -- Paste (Cmd + V)
    { key = "C", mods = "CMD", action = act.CopyTo("Clipboard") }, -- Copy (Cmd + C)

    -- 🔀 Tmux-like Pane Navigation
    -- { key = "H", mods = "CMD", action = act.ActivatePaneDirection("Left") }, -- Move pane left (Cmd + H)
    -- { key = "L", mods = "CMD", action = act.ActivatePaneDirection("Right") }, -- Move pane right (Cmd + L)
    -- { key = "J", mods = "CMD", action = act.ActivatePaneDirection("Down") }, -- Move pane down (Cmd + J)
    -- { key = "K", mods = "CMD", action = act.ActivatePaneDirection("Up") }, -- Move pane up (Cmd + K)

    -- 🔄 Tabs
    { key = "T", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") }, -- New Tab (Cmd + T)
    { key = "Tab", mods = "CMD", action = act.ActivateTabRelative(1) }, -- Next Tab (Cmd + Tab)
    { key = "Tab", mods = "CMD|SHIFT", action = act.ActivateTabRelative(-1) }, -- Previous Tab (Cmd + Shift + Tab)

    -- Navigate text with arrow keys
    { key = "Home", mods = "", action = act.SendKey({ key = "A", mods = "CTRL" }) },
    { key = "End", mods = "", action = act.SendKey({ key = "E", mods = "CTRL" }) },

    {
        key = "K",
        mods = "CMD|SHIFT",
        action = wezterm.action_callback(function(window, pane)
            features.theme_switcher(window, pane)
        end),
    },
    { key = "f", mods = "CMD", action = wezterm.action.Search({ CaseInSensitiveString = "" }) },

    {
        key = "g",
        mods = "CMD",
        action = wezterm.action.ActivateCommandPalette,
    },
}

config.window_frame = {
    font_size = 13.0, -- Adjust tab font size
}

local home_dir = wezterm.home_dir
local target_dir = home_dir .. "/Workbench/airtm/local-env/repos"
config.default_cwd = wezterm.run_child_process({
    "test",
    "-d",
    target_dir,
}) and target_dir or home_dir .. "/Workbench"

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local pane = tab.active_pane

    -- Extract process name
    local process = string.match(pane.foreground_process_name or "", "([^/\\]+)$") or ""

    -- Get current working directory
    local cwd_uri = pane.current_working_dir
    local cwd = cwd_uri and cwd_uri.file_path or ""

    -- Replace home dir with ~
    local home = wezterm.home_dir
    cwd = cwd:gsub("^" .. home, "~")

    -- Smart truncate the path
    -- local function smart_shorten(path)
    --     local parts = {}
    --     for part in path:gmatch("[^/]+") do
    --         table.insert(parts, part)
    --     end
    --
    --     if #parts <= 2 then
    --         return table.concat(parts, "/") -- nothing to shorten
    --     end
    --
    --     local shortened = {}
    --     for i = 1, #parts - 1 do
    --         if i == 1 then
    --             table.insert(shortened, parts[i]) -- keep '~' or leading part
    --         else
    --             table.insert(shortened, parts[i]:sub(1, 1)) -- first letter only
    --         end
    --     end
    --
    --     -- Keep the last part fully
    --     table.insert(shortened, parts[#parts])
    --
    --     return table.concat(shortened, "/")
    -- end

    -- local short_cwd = smart_shorten(cwd)
    local title = tab.active_pane.title or ""
    local cwd_uri = tab.active_pane.current_working_dir
    if cwd_uri then
        local cwd = cwd_uri.file_path or ""
        -- Extract the last directory name
        local last_path = string.match(cwd, "([^/]+)/*$")
        if last_path then
            title = last_path
        end
    end

    -- Optional: Add emojis or icons based on process
    local icon = ""
    if process:find("nvim") then
        icon = "👨‍💻"
        process = ""
    elseif process:find("ssh") then
        icon = "🔒"
    elseif process:find("git") then
        icon = "🔀" -- 🌿
    elseif process:find("htop") then
        icon = "📊"
    elseif process:find("zsh") or process:find("bash") then
        icon = "💲"
    elseif process:find("node") then
        icon = "🦖"
    end

    -- Format: `process — ~/W/p/project-a`
    -- local formatted = string.format("%s %s %s", icon, process, title)
    local formatted = string.format("%s %s", icon, title)

    -- -- Truncate if still too long
    -- if #formatted > max_width then
    --     formatted = "..." .. formatted:sub(-max_width + 1)
    -- end

    return {
        { Text = " " .. formatted .. " " },
    }
end)

config.selection_word_boundary = " \t\n{}[]()\"'`~,;:│=&!%^<>"

-- config.mouse_bindings = {
--     -- Disable default click on hyperlinks (and prevent copy on select)
--     {
--         event = { Up = { streak = 1, button = "Left" } },
--         mods = "NONE",
--         action = act.Nop,
--     },
--
--     -- Enable link opening with CTRL (or CMD on macOS)
--     {
--         event = { Up = { streak = 1, button = "Left" } },
--         mods = "CTRL",
--         action = act.OpenLinkAtMouseCursor,
--     },
--     {
--         event = { Up = { streak = 1, button = "Left" } },
--         mods = "CMD",
--         action = act.OpenLinkAtMouseCursor,
--     },
-- }

-- Disable copy on single/double/triple click select
config.mouse_bindings = {
    {
        event = { Up = { streak = 1, button = "Left" } },
        mods = "NONE",
        action = act.Nop,
    },
    {
        event = { Up = { streak = 2, button = "Left" } },
        mods = "NONE",
        action = act.Nop,
    },
    {
        event = { Up = { streak = 3, button = "Left" } },
        mods = "NONE",
        action = act.Nop,
    },
    {
        event = { Up = { streak = 1, button = "Left" } },
        mods = "CMD",
        action = act.OpenLinkAtMouseCursor,
    },
    {
        event = { Up = { streak = 1, button = "Left" } },
        mods = "CTRL",
        action = act.OpenLinkAtMouseCursor,
    },
}

return config
