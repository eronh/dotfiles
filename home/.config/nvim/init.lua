vim.loader.enable() -- cache lua modules (https://github.com/neovim/neovim/pull/22668)

require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autopairs")
require("config.autocmds")
require("config.usercmds")
require("config.git_history")
require("config.palette")

-- The colorscheme picker (<leader>tt, plugins/colorschemes.lua) rewrites this line.
vim.cmd("colorscheme nord")

if vim.fn.has("wsl") == 1 then
    vim.g.clipboard = "win32yank"
end
