local function close_all_buffers_except_neotree()
    local neo_tree_bufs = {}

    -- Find all Neo-tree buffers
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local bufname = vim.api.nvim_buf_get_name(buf)
        if bufname:match("neo%-tree") then
            table.insert(neo_tree_bufs, buf)
        end
    end

    -- Close all other buffers
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if not vim.tbl_contains(neo_tree_bufs, buf) and vim.api.nvim_buf_is_valid(buf) then
            require("mini.bufremove").delete(buf, true) -- `true` forces deletion without prompt
        end
    end
end

return { -- Collection of various small independent plugins/modules
    "echasnovski/mini.nvim",
    version = "*",
    config = function()
        -- Better Around/Inside textobjects
        --
        -- Examples:
        --  - va)  - [V]isually select [A]round [)]paren
        --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
        --  - ci'  - [C]hange [I]nside [']quote
        require("mini.ai").setup({ n_lines = 500 })

        -- Add/delete/replace surroundings (brackets, quotes, etc.)
        --
        -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
        -- - sd'   - [S]urround [D]elete [']quotes
        -- - sr)'  - [S]urround [R]eplace [)] [']
        require("mini.surround").setup()

        -- Simple and easy statusline.
        --  You could remove this setup call if you don't like it,
        --  and try some other statusline plugin
        local statusline = require("mini.statusline")
        -- set use_icons to true if you have a Nerd Font
        statusline.setup({ use_icons = vim.g.have_nerd_font })

        -- You can configure sections in the statusline by overriding their
        -- default behavior. For example, here we set the section for
        -- cursor location to LINE:COLUMN
        ---@diagnostic disable-next-line: duplicate-set-field
        statusline.section_location = function()
            return "%2l:%-2v"
        end

        -- ... and there is more!
        --  Check out: https://github.com/echasnovski/mini.nvim

        -- require("mini.comment").setup({
        --     -- No need to copy this inside `setup()`. Will be used automatically.
        --     -- Options which control module behavior
        --     options = {
        --         -- Function to compute custom 'commentstring' (optional)
        --         custom_commentstring = nil,
        --
        --         -- Whether to ignore blank lines when commenting
        --         ignore_blank_line = false,
        --
        --         -- Whether to ignore blank lines in actions and textobject
        --         start_of_line = false,
        --
        --         -- Whether to force single space inner padding for comment parts
        --         pad_comment_parts = true,
        --     },
        --
        --     -- Module mappings. Use `''` (empty string) to disable one.
        --     mappings = {
        --         -- Toggle comment (like `gcip` - comment inner paragraph) for both
        --         -- Normal and Visual modes
        --         comment = "gc",
        --
        --         -- Toggle comment on current line
        --         comment_line = "gcc",
        --
        --         -- Toggle comment on visual selection
        --         comment_visual = "gc",
        --
        --         -- Define 'comment' textobject (like `dgc` - delete whole comment block)
        --         -- Works also in Visual mode if mapping differs from `comment_visual`
        --         textobject = "gc",
        --     },
        --
        --     -- Hook functions to be executed at certain stage of commenting
        --     hooks = {
        --         -- Before successful commenting. Does nothing by default.
        --         pre = function() end,
        --         -- After successful commenting. Does nothing by default.
        --         post = function() end,
        --     },
        -- })

        require("mini.bufremove").setup()
        require("mini.pairs").setup({
            -- In which modes mappings from this `config` should be created
            modes = { insert = true, command = false, terminal = false },

            -- Global mappings. Each right hand side should be a pair information, a
            -- table with at least these fields (see more in |MiniPairs.map|):
            -- - <action> - one of 'open', 'close', 'closeopen'.
            -- - <pair> - two character string for pair to be used.
            -- By default pair is not inserted after `\`, quotes are not recognized by
            -- `<CR>`, `'` does not insert pair after a letter.
            -- Only parts of tables can be tweaked (others will use these defaults).
            mappings = {
                [")"] = { action = "close", pair = "()", neigh_pattern = "[^\\]." },
                ["]"] = { action = "close", pair = "[]", neigh_pattern = "[^\\]." },
                ["}"] = { action = "close", pair = "{}", neigh_pattern = "[^\\]." },
                ["["] = {
                    action = "open",
                    pair = "[]",
                    neigh_pattern = ".[%s%z%)}%]]",
                    register = { cr = false },
                    -- foo|bar -> press "[" -> foo[bar
                    -- foobar| -> press "[" -> foobar[]
                    -- |foobar -> press "[" -> [foobar
                    -- | foobar -> press "[" -> [] foobar
                    -- foobar | -> press "[" -> foobar []
                    -- {|} -> press "[" -> {[]}
                    -- (|) -> press "[" -> ([])
                    -- [|] -> press "[" -> [[]]
                },
                ["{"] = {
                    action = "open",
                    pair = "{}",
                    -- neigh_pattern = ".[%s%z%)}]",
                    neigh_pattern = ".[%s%z%)}%]]",
                    register = { cr = false },
                    -- foo|bar -> press "{" -> foo{bar
                    -- foobar| -> press "{" -> foobar{}
                    -- |foobar -> press "{" -> {foobar
                    -- | foobar -> press "{" -> {} foobar
                    -- foobar | -> press "{" -> foobar {}
                    -- (|) -> press "{" -> ({})
                    -- {|} -> press "{" -> {{}}
                },
                ["("] = {
                    action = "open",
                    pair = "()",
                    -- neigh_pattern = ".[%s%z]",
                    neigh_pattern = ".[%s%z%)]",
                    register = { cr = false },
                    -- foo|bar -> press "(" -> foo(bar
                    -- foobar| -> press "(" -> foobar()
                    -- |foobar -> press "(" -> (foobar
                    -- | foobar -> press "(" -> () foobar
                    -- foobar | -> press "(" -> foobar ()
                },
                -- Single quote: Prevent pairing if either side is a letter
                ['"'] = {
                    action = "closeopen",
                    pair = '""',
                    neigh_pattern = "[^%w\\][^%w]",
                    register = { cr = false },
                },
                -- Single quote: Prevent pairing if either side is a letter
                ["'"] = {
                    action = "closeopen",
                    pair = "''",
                    neigh_pattern = "[^%w\\][^%w]",
                    register = { cr = false },
                },
                -- Backtick: Prevent pairing if either side is a letter
                ["`"] = {
                    action = "closeopen",
                    pair = "``",
                    neigh_pattern = "[^%w\\][^%w]",
                    register = { cr = false },
                },
            },
        })

        vim.api.nvim_create_user_command("CloseAllExceptNeoTree", close_all_buffers_except_neotree, {})
        vim.keymap.set("", "<leader>bw", "<cmd>lua MiniBufremove.delete()<CR>")
        vim.keymap.set("n", "<C-M-W>", ":CloseAllExceptNeoTree<CR>", { desc = "Close all buffers except Neo-tree" })
    end,
}
