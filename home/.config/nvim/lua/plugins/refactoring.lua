-- The rewrite swapped plenary/nvim-treesitter for async.nvim and replaced
-- `refactor("<name>")` with one function per refactoring, so the old mappings
-- all errored. These are operators: in normal mode follow them with a
-- motion or textobject (`<leader>reip`, `<leader>rvi(`); in visual mode they act
-- on the selection.
local function refactor(name)
    return function()
        return require("refactoring")[name]()
    end
end

return { -- https://github.com/ThePrimeagen/refactoring.nvim
    "ThePrimeagen/refactoring.nvim",
    -- Needs 0.12.5 for vim.pos/vim.range; apt's neovim (0.11.6 on Ubuntu 26.04)
    -- is too old, so it's skipped there.
    cond = vim.fn.has("nvim-0.12.5") == 1,
    dependencies = { "lewis6991/async.nvim" },
    config = function()
        -- It reaches async.nvim as `vim.async or require("async")`, but nvim-ufo's
        -- promise-async also ships a top-level `async` module and is loaded first,
        -- so require() hands back the wrong library. Load async.nvim by path into
        -- the slot it checks first; this goes away once Neovim ships vim.async.
        local async_nvim = require("lazy.core.config").plugins["async.nvim"].dir
        vim.async = vim.async or dofile(async_nvim .. "/lua/async.lua")
    end,
    keys = {
        {
            "<leader>re",
            refactor("extract_func"),
            mode = { "n", "x" },
            expr = true,
            desc = "Refactor: Extract function",
        },
        {
            "<leader>rf",
            refactor("extract_func_to_file"),
            mode = { "n", "x" },
            expr = true,
            desc = "Refactor: Extract function to file",
        },
        {
            "<leader>rv",
            refactor("extract_var"),
            mode = { "n", "x" },
            expr = true,
            desc = "Refactor: Extract variable",
        },
        { "<leader>ri", refactor("inline_var"), mode = { "n", "x" }, expr = true, desc = "Refactor: Inline variable" },
        { "<leader>rI", refactor("inline_func"), mode = { "n", "x" }, expr = true, desc = "Refactor: Inline function" },
        -- Off: "Extract Block" and "Extract Block To File" were dropped upstream.
        -- { "<leader>rb", ... desc = "Refactor: Extract block" },
        -- { "<leader>rbf", ... desc = "Refactor: Extract block to file" },
    },
}
