if vim.loader then
    vim.loader.enable() -- cache lua modules (https://github.com/neovim/neovim/pull/22668)
end

require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")
require("config.usercmds")

vim.opt.background = "dark"
vim.cmd('colorscheme nord')
