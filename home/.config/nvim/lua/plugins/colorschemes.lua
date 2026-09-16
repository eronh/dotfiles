local function persist_colorscheme(name)
    local init = vim.fn.stdpath("config") .. "/init.lua"
    local lines = vim.fn.readfile(init)

    for i, line in ipairs(lines) do
        if line:match("^vim%.cmd%(['\"]colorscheme ") then
            lines[i] = string.format("vim.cmd(%q)", "colorscheme " .. name)
            vim.fn.writefile(lines, init)
            return
        end
    end

    vim.notify("Could not persist colorscheme: no colorscheme command in init.lua", vim.log.levels.ERROR)
end

vim.keymap.set("n", "<leader>tt", function()
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    require("telescope.builtin").colorscheme({
        enable_preview = true,
        attach_mappings = function(_, map)
            map({ "i", "n" }, "<CR>", function(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                    vim.cmd.colorscheme(selection.value)
                    persist_colorscheme(selection.value)
                end
                actions.close(prompt_bufnr)
            end)
            return true
        end,
    })
end, { desc = "Pick colorscheme" })

return {
    { "shaunsingh/nord.nvim", name = "nord" },
    { "ellisonleao/gruvbox.nvim", name = "gruvbox", opts = { contrast = "soft" } },
}
