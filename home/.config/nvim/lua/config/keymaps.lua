local keymap = vim.keymap

-- delete sends text to 'black hole' instead of clipboard
-- https://stackoverflow.com/q/54255
-- keymap.set("n", "d", '"_d')
keymap.set("n", "dd", '"_dd')
keymap.set("v", "d", '"_d')
keymap.set("n", "x", '"_x')
-- keymap.set({ "n", "v" }, "x", '"_x"')

keymap.set("n", "<leader>pv", vim.cmd.Ex)

keymap.set("n", "<leader>w", ":w<CR>")
keymap.set("i", "<leader>w", "<ESC>:w<CR>")
-- keymap.set("n", "<leader>q", ":q<CR>")
keymap.set("", "<leader>q", function(bufnr)
    Snacks.bufdelete(bufnr)
end)
keymap.set("n", "<leader>wq", ":wq<CR>")

-- Buffer cycling (bufferline is disabled, so these use the built-ins)
keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })

keymap.set("x", "y", '"+y')
keymap.set("n", "p", '"+p')
keymap.set("n", "p", '"*p')

-- Increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- Allow moving code
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keep J in place when appending line below
keymap.set("n", "J", "mzJ`z")

-- Keep cursor in the center while navigating page up and down
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")

-- Keep cursor in the center while navigating search results
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- Keep pasted text after pasting over selection
keymap.set("x", "<leader>p", '"_dP')

-- keymap.set({ "n", "v" }, "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
keymap.set({ "n", "v" }, "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- keymap.set("n", "j", "jzz")
-- keymap.set("n", "k", "kzz")
-- keymap.set("n", "G", "Gzz")

-- C-c should have the same effect as <ESC>
keymap.set("i", "<C-c>", "<ESC>")

-- After kickstart.nvim

-- [[ Basic Keymaps ]]
--  See `:help keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Map esc to double esc
keymap.set({ "n", "i", "v" }, "<esc>", "<esc><esc>", { silent = true })

-- Diagnostic keymaps
-- keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- C-p and C-n should go to previous and next cursor positions, having the same behavior as C-o and C-i, respectively
keymap.set("n", "<C-p>", "<C-o>", { silent = true })
keymap.set("n", "<C-n>", "<C-i>", { silent = true })

-- Keep cursor at the bottom of the visual selection after you yank it.
keymap.set("v", "y", "ygv<Esc>")

-- Double slashes // should search for the currently selected string
keymap.set("v", "//", 'y/\\V<C-R>"<CR>', { noremap = true, silent = false })

keymap.set("n", "<C-S-G>", ":DiffviewOpen<CR>", { noremap = true })

-- vim.api.nvim_set_keymap("i", "jk", "<Esc>", { noremap = false })
keymap.set("i", "jk", "<Esc>", { noremap = false })

-- https://www.reddit.com/r/neovim/comments/1707ppd/comment/k3j499u/
-- keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Center cursor after moving down half-page" })
-- keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Center cursor after moving down half-page" })

keymap.set("n", "<C-j>", "3jzz")
keymap.set("n", "<C-k>", "3kzz")
