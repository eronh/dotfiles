-- Globals
vim.g.mapleader = ";"
vim.g.maplocalleader = ";"
vim.g.have_nerd_font = true
-- vim.g.snacks_animate = false -- disable every snacks animation

-- netrw is replaced by neo-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local opt = vim.opt

-- UI
opt.termguicolors = true -- tmux's screen-256color hides truecolor from auto-detection
opt.background = "dark"  -- Don't follow the terminal's detected background
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.colorcolumn = "120"
opt.signcolumn = "yes" -- Always on, so text doesn't shift when signs appear
opt.laststatus = 3     -- Global statusline
opt.showmode = false   -- Redundant with the statusline
opt.showmatch = true
opt.pumblend = 10
opt.pumheight = 10
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.smoothscroll = true
opt.conceallevel = 2 -- Hide * markup for bold/italic, but not substituted markers
-- opt.fillchars = {
--     foldopen = "",
--     foldclose = "",
--     fold = " ",
--     foldsep = " ",
--     diff = "╱",
--     eob = " ",
-- }
opt.list = true
opt.listchars = {
    -- lead = "·",
    trail = "⋅",
    tab = "» ",
    nbsp = "␣",
    -- space = "⋅",
    -- eol = "↲",
}

-- Indentation. `.editorconfig` and vim-sleuth override these per project.
opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.shiftround = true
opt.smartindent = true

-- Wrapping
opt.wrap = false
opt.linebreak = true -- If wrap is turned back on, break at word boundaries
opt.breakindent = true
opt.showbreak = "+++"
-- opt.textwidth = 100
opt.formatoptions = "jcroqlnt"

-- Filetype plugins
vim.g.markdown_recommended_style = 0 -- Don't force 4-space indents in markdown

-- Search
opt.hlsearch = false
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"     -- Preview :s matches in a split
opt.grepprg = "rg --vimgrep" -- Unlike nvim's default (`-uu`), respects .gitignore
opt.grepformat = "%f:%l:%c:%m"

-- Files and undo
opt.autowrite = true
opt.confirm = true -- Ask to save instead of failing on :q with changes
opt.swapfile = false
opt.undofile = true
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

-- Clipboard. Leaving it empty over SSH lets nvim's OSC 52 integration take over,
-- which is what makes yanks reach the local clipboard through the tunnel.
-- WSL: force win32yank, else auto-detection picks WSLg's flaky wl-copy/xclip first.
-- Over SSH, force OSC 52 instead: auto-detection would still find win32yank.exe
-- before falling back to OSC 52, sending yanks to the remote Windows clipboard.
if vim.fn.has("wsl") == 1 then
    vim.g.clipboard = vim.env.SSH_TTY and "osc52" or "win32yank"
end
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"

-- Splits
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen"
opt.winminwidth = 5

-- Folding. nvim-ufo takes over at runtime; these are the fallback if it's removed.
opt.foldcolumn = "1"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = ""
vim.g.markdown_folding = 1

-- Input
opt.mouse = "a"
opt.virtualedit = "block" -- Let the cursor move past EOL in visual block
opt.isfname:append("@-@")
opt.wildmode = "longest:full,full"
opt.jumpoptions:append("view") -- Keeps the default "clean"
opt.updatetime = 250           -- CursorHold delay (reference highlights, :checktime)
opt.timeoutlen = 300           -- So leader chords like ;w / ;wq resolve quickly

-- Messages: no "written", intro screen or completion-menu chatter
opt.shortmess:append({ W = true, I = true, c = true })

-- Sessions. Leaves out "blank" and "options" so a restored session doesn't
-- fight the settings above.
opt.sessionoptions = "buffers,tabpages,curdir,folds,help,winsize,winpos,terminal,localoptions"
