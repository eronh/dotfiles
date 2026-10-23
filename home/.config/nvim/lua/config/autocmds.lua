vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        -- vim.highlight was renamed to vim.hl in 0.11; keep the old path as a
        -- fallback so this file still works on 0.10.
        local hl = vim.hl or vim.highlight
        hl.on_yank()
    end,
})

-- 'autoread' only reloads a buffer once Neovim actually checks the file, and it
-- never checks on its own. Without this, edits made by an external agent
-- (opencode, a formatter, a rebase) sit invisible until you switch buffers.
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave", "BufEnter", "CursorHold" }, {
    desc = "Reload buffers changed outside Neovim",
    group = vim.api.nvim_create_augroup("checktime", { clear = true }),
    callback = function()
        if vim.o.buftype ~= "nofile" then
            vim.cmd("checktime")
        end
    end,
})

-- detect tmux filetype
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*tmux.conf", ".tmux.local.conf" },
    callback = function()
        vim.bo.filetype = "tmux"
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function()
        vim.opt_local.expandtab = false -- Use real tabs
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
    end,
})
