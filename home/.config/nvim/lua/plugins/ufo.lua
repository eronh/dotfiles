return {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    -- Treesitter as the main provider (the `nvim-treesitter` plugin is *not*
    -- needed for this — ufo uses the same queries/<lang>/folds.scm files).
    -- Better performance and stability than foldmethod=expr.
    opts = {
        provider_selector = function()
            return { "treesitter", "indent" }
        end,
    },
    keys = {
        -- ufo replaces foldlevel, so the built-in zR/zM stop working.
        { "zR", function() require("ufo").openAllFolds() end, desc = "Open all folds" },
        { "zM", function() require("ufo").closeAllFolds() end, desc = "Close all folds" },
        { "zK", function() require("ufo").peekFoldedLinesUnderCursor() end, desc = "Peek fold" },
    },
}
