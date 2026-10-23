-- Terminal Mappings
local function term_nav(direction)
    ---@param self snacks.terminal
    return function(self)
        return self:is_floating() and "<c-" .. direction .. ">"
            or vim.schedule(function()
                vim.cmd.wincmd(direction)
            end)
    end
end

return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@module 'snacks'
    ---@type snacks.Config
    opts = {
        bigfile = { enabled = true },
        -- explorer = { enabled = false },
        indent = {
            enabled = true,
            animate = { enabled = false },
            scope = { enabled = false },
            chunk = { enabled = false },
        },
        input = { enabled = true }, -- used by opencode's ask()
        notifier = { enabled = true, top_down = false },
        -- Off: Telescope is the picker here. Leaving this on means two plugins
        -- both replace vim.ui.select (telescope-ui-select is the one we want).
        -- opencode.lua adds picker opts that stay inert while this is false.
        picker = { enabled = false },
        quickfile = { enabled = true },
        scope = { enabled = true },
        image = { enabled = false },
        -- scroll = { enabled = false },
        -- statuscolumn = { enabled = false },
        -- words = { enabled = true },
        terminal = {},
        -- terminal = {
        --     win = {
        --         keys = {
        --             nav_h = { "<C-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
        --             nav_j = { "<C-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
        --             nav_k = { "<C-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
        --             nav_l = { "<C-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
        --         },
        --     },
        -- },

        dashboard = {
            enabled = false,
            preset = {
                -- LazyVim is not installed; use snacks' own picker shim so this
                -- still works if `enabled` is flipped back to true.
                pick = function(cmd, opts)
                    return Snacks.dashboard.pick(cmd, opts)
                end,
                header = [[
       _______   ________  ________  ________  ________
      ╱    ╱  ╲╲╱        ╲╱        ╲╱        ╲╱    ╱   ╲
     ╱        ╱╱         ╱         ╱         ╱         ╱
    ╱         ╱        _╱        _╱         ╱         ╱
    ╲___╱____╱╲________╱╲____╱___╱╲________╱╲__╱_____╱]],
                -- stylua: ignore
                ---@type snacks.dashboard.Item[]
                keys = {
                    { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
                    { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
                    { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
                    { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
                    { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
                    { icon = " ", key = "s", desc = "Restore Session", section = "session" },
                    { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
                    { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
                    { icon = " ", key = "q", desc = "Quit", action = ":qa" },
                },
            },
        },
    },
    -- stylua: ignore
    keys = {
        { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
        { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
        { "<leader>dps", function() Snacks.profiler.scratch() end, desc = "Profiler Scratch Buffer" },
    },
    config = function(_, opts)
        require("snacks").setup(opts)

        -- vim.keymap.set("n", "<leader>ds", ":lua require('snacks').dashboard()<CR>", { desc = "Open Snacks Dashboard" })
        --
        -- vim.api.nvim_create_autocmd("VimEnter", {
        --     callback = function()
        --         -- Close the initial empty buffer if it exists
        --         if vim.fn.bufname() == "" and vim.fn.line2byte(vim.fn.line("$")) == -1 then
        --             vim.cmd("silent! bd") -- Force close empty buffer
        --         end
        --
        --         -- Force Snacks to open
        --         vim.schedule(function()
        --             require("snacks").dashboard()
        --         end)
        --     end,
        -- })

        -- vim.api.nvim_create_autocmd("User", {
        --     pattern = "SessionLoadPost",
        --     callback = function()
        --         if not vim.g.snacks_opened then
        --             require("neo-tree.command").execute({ toggle = true })
        --         end
        --     end,
        -- })
    end,
}
