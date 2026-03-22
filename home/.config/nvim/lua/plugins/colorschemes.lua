local function select_colorscheme()
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local builtin = require("telescope.builtin")

    builtin.colorscheme({
        enable_preview = true,
        attach_mappings = function(_, map)
            map("i", "<CR>", function(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                    local colorscheme = selection.value

                    -- Apply the selected colorscheme
                    vim.cmd("colorscheme " .. colorscheme)

                    -- Save the colorscheme persistently
                    local config_path = vim.fn.stdpath("config") .. "/lua/config/colorscheme.vim"
                    local file = io.open(config_path, "w")
                    if file then
                        file:write(colorscheme .. "\n") -- Store just the name
                        file:close()
                    end

                    -- Automatically source colors.lua to apply the theme
                    vim.cmd("source " .. vim.fn.stdpath("config") .. "/lua/config/colors.lua")

                    -- Debug: Confirm colorscheme application
                    print("Colorscheme applied and saved: " .. colorscheme)
                end
                actions.close(prompt_bufnr)
            end)
            return true
        end,
    })
end

vim.keymap.set("n", "<leader>tt", select_colorscheme)

return {
    {
        "ellisonleao/gruvbox.nvim",
        name = "gruvbox",
        opts = {
            contrast = "soft",
        },
    },
    { "catppuccin/nvim", name = "catppuccin" },
    { "shaunsingh/nord.nvim", name = "nord" },
    { "rose-pine/neovim", name = "rose-pine" },
    { "folke/tokyonight.nvim", name = "tokyonight" },
    { "rebelot/kanagawa.nvim", name = "kanagawa" },
    { "Mofiqul/dracula.nvim", name = "dracula" },
    {
        "maxmx03/solarized.nvim",
        name = "solarized",
        opts = {
            variant = "winter", -- "spring" | "summer" | "autumn" | "winter"
            palette = "solarized", -- "solarized" | "selenized"
            transparent = { enabled = false },
        },
    },
    { "EdenEast/nightfox.nvim" },
    { "navarasu/onedark.nvim" },
    { "sainnhe/everforest" },
    { "folke/tokyonight.nvim", lazy = false, priority = 1000 },
    { "rebelot/kanagawa.nvim" },
}
