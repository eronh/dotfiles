-- This file is automatically loaded by plugins.core
vim.g.mapleader = ";"
vim.g.maplocalleader = ";"

-- LazyVim auto format
vim.g.autoformat = true

-- Snacks animations
-- Set to `false` to globally disable all snacks animations
vim.g.snacks_animate = true

-- LazyVim picker to use.
-- Can be one of: telescope, fzf
-- Leave it to "auto" to automatically use the picker
-- enabled with `:LazyExtras`
vim.g.lazyvim_picker = "auto"

-- LazyVim completion engine to use.
-- Can be one of: nvim-cmp, blink.cmp
-- Leave it to "auto" to automatically use the completion engine
-- enabled with `:LazyExtras`
vim.g.lazyvim_cmp = "auto"

-- if the completion engine supports the AI source,
-- use that instead of inline suggestions
vim.g.ai_cmp = true

-- LazyVim root dir detection
-- Each entry can be:
-- * the name of a detector function like `lsp` or `cwd`
-- * a pattern or array of patterns like `.git` or `lua`.
-- * a function with signature `function(buf) -> string|string[]`
-- vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

-- Optionally setup the terminal to use
-- This sets `vim.o.shell` and does some additional configuration for:
-- * pwsh
-- * powershell
-- LazyVim.terminal.setup("pwsh")

-- Set LSP servers to be ignored when used with `util.root.detectors.lsp`
-- for detecting the LSP root
vim.g.root_lsp_ignore = { "copilot" }

-- Hide deprecation warnings
vim.g.deprecation_warnings = false

-- Show the current document symbols location from Trouble in lualine
-- You can disable this for a buffer by setting `vim.b.trouble_lualine = false`
vim.g.trouble_lualine = true

local opt = vim.opt

opt.autowrite = true -- Enable auto write
-- only set clipboard if not in ssh, to make sure the OSC 52
-- integration works automatically. Requires Neovim >= 0.10.0
-- WSL: force win32yank, else auto-detection picks WSLg's flaky wl-copy/xclip first.
-- Over SSH, force OSC 52 instead: auto-detection would still find win32yank.exe
-- before falling back to OSC 52, sending yanks to the remote Windows clipboard.
if vim.fn.has("wsl") == 1 then
    vim.g.clipboard = vim.env.SSH_TTY and "osc52" or "win32yank"
end
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line
opt.expandtab = true -- Use spaces instead of tabs
opt.fillchars = {
    foldopen = "",
    foldclose = "",
    fold = " ",
    foldsep = " ",
    diff = "╱",
    eob = " ",
}
opt.foldlevel = 99
opt.formatexpr = "v:lua.require'lazyvim.util'.format.formatexpr()"
opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true -- Ignore case
opt.inccommand = "nosplit" -- preview incremental substitute
opt.jumpoptions = "view"
opt.laststatus = 3 -- global statusline
opt.linebreak = true -- Wrap lines at convenient points
opt.list = true -- Show some invisible characters (tabs...
opt.mouse = "a" -- Enable mouse mode
opt.number = true -- Print line number
opt.pumblend = 10 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.relativenumber = true -- Relative line numbers
opt.ruler = false -- Disable the default ruler
opt.scrolloff = 4 -- Lines of context
-- opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
-- opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
vim.opt.sessionoptions = "buffers,tabpages,curdir,folds,help,winsize,winpos,terminal,localoptions"
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Size of an indent
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false -- Dont show mode since we have a statusline
opt.sidescrolloff = 8 -- Columns of context
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.spelllang = { "en" }
opt.splitbelow = true -- Put new windows below current
opt.splitkeep = "screen"
opt.splitright = true -- Put new windows right of current
-- opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]
opt.tabstop = 2 -- Number of spaces tabs count for
opt.termguicolors = true -- True color support
opt.timeoutlen = vim.g.vscode and 1000 or 300 -- Lower than default (1000) to quickly trigger which-key
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width
opt.wrap = false -- Disable line wrap

if vim.fn.has("nvim-0.10") == 1 then
    opt.smoothscroll = true
    opt.foldexpr = "v:lua.require'lazyvim.util'.ui.foldexpr()"
    opt.foldmethod = "expr"
    opt.foldtext = ""
else
    opt.foldmethod = "indent"
    opt.foldtext = "v:lua.require'lazyvim.util'.ui.foldtext()"
end

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0

---

vim.g.mapleader = ";"
vim.g.maplocalleader = ";"

vim.g.have_nerd_font = true

opt.cul = true
opt.number = true
opt.relativenumber = true
-- opt.linebreak
-- Enable break indent
opt.breakindent = true
opt.showbreak = "+++"
-- opt.textwidth=100
-- opt.nowrap
-- opt.formatoptions=
opt.showmatch = true
opt.virtualedit = "block"

opt.hlsearch = false
opt.smartcase = true
opt.ignorecase = true
opt.incsearch = true

opt.autoindent = true
opt.expandtab = true
opt.shiftwidth = 2
opt.smartindent = true
opt.smarttab = true
opt.softtabstop = 2
opt.ruler = true
opt.tabstop = 2

opt.undolevels = 1000
opt.backspace = "indent,eol,start"

-- Enable system clipboard integration. See: https://stackoverflow.com/a/27928635
-- opt.clipboard = unnamed

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.schedule(function()
opt.clipboard = "unnamedplus"
-- end)

-- recommended settings from http://vim.wikia.com/wiki/Example_vimrc
-- opt.nocompatible = true
opt.wildmenu = true
-- opt.nomodeline = true
-- opt.nostartofline = true
opt.confirm = true
opt.mouse = "a"

-- Show which line your cursor is on
opt.cursorline = true

-- From set.lua
opt.nu = true
opt.relativenumber = true

opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true

opt.smartindent = true

opt.wrap = false

opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

opt.incsearch = true

opt.termguicolors = true

opt.signcolumn = "yes"
opt.isfname:append("@-@")

opt.updatetime = 250
opt.timeoutlen = 300

opt.colorcolumn = "120"

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
opt.list = true
opt.listchars = {
    -- lead = "·",
    trail = "⋅",
    tab = "» ",
    nbsp = "␣",
    -- space = "⋅",
    -- eol = "↲",
}

-- Preview substitutions live, as you type!
opt.inccommand = "split"

-- Minimal number of screen lines to keep above and below the cursor.
opt.scrolloff = 10

-- Code folding settings for treesitter and ufo plugins
opt.foldcolumn = "1"
opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99
vim.g.markdown_folding = 1

vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- Enable break indent
opt.breakindent = true

--

-- opt.autochdir = true
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Update buffer if changed externally
-- See: https://www.reddit.com/r/neovim/comments/1flr88l/how_to_update_buffer_content_when_file_changes/
opt.autoread = true
opt.shortmess = "I"

vim.g.vscode = 1

-- vim.g.lazyvim_eslint_auto_format = 1
vim.g.ale_use_neovim_diagnostics_api = 1
vim.g.ale_fix_on_save = 1
