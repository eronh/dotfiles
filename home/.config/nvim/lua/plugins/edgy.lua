local function neo_tree_source(source)
    return function(buf)
        return vim.b[buf].neo_tree_source == source
    end
end

local is_open_editors = neo_tree_source("buffers")

local function open_editors_height()
    local max = math.floor(vim.o.lines * 0.3)
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if is_open_editors(buf) then
            return math.min(vim.api.nvim_buf_line_count(buf), max)
        end
    end
    return max
end
return {
    "folke/edgy.nvim",
    event = "VeryLazy",
    opts = {
        right = {
            {
                title = "Open Editors",
                ft = "neo-tree",
                filter = is_open_editors,
                pinned = true,
                size = { height = open_editors_height },
                -- position=top gives it its own window; edgy moves it into the sidebar.
                open = "Neotree position=top buffers",
            },
            {
                title = "Files",
                ft = "neo-tree",
                filter = neo_tree_source("filesystem"),
                pinned = true,
                open = "Neotree position=right filesystem",
            },
            -- any other neo-tree windows (git_status, document_symbols)
            "neo-tree",
        },
        options = {
            right = { size = 48 },
        },
        animate = { enabled = false },
    },
}
