local function neo_tree_source(source)
    return function(buf)
        return vim.b[buf].neo_tree_source == source
    end
end

return {
    "folke/edgy.nvim",
    event = "VeryLazy",
    opts = {
        right = {
            {
                title = "Open Editors",
                ft = "neo-tree",
                filter = neo_tree_source("buffers"),
                pinned = true,
                size = { height = 0.3 },
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
