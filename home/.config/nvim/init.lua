vim.loader.enable() -- cache lua modules (https://github.com/neovim/neovim/pull/22668)

require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")
require("config.usercmds")

-- The colorscheme picker (<leader>tt, plugins/colorschemes.lua) rewrites this line.
vim.cmd("colorscheme nord")
