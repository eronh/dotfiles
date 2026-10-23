local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- NOTE: everything below has to be in ONE table. `lazy.setup(spec, opts)` uses
-- the first argument as the whole config as soon as it contains a `spec` key,
-- and silently drops the second — so when these were split across two tables,
-- `defaults`, `checker` and `change_detection` were all being ignored.
require("lazy").setup({
    spec = {
        { import = "plugins" },
    },
    defaults = {
        -- Set this to `true` to have every plugin lazy-load by default.
        lazy = false,
        -- Left at false on purpose: plenty of plugins have outdated release
        -- tags, and this now actually takes effect. Plugins that do want a
        -- stable tag pin it themselves (blink.cmp, mini.nvim, opencode.nvim).
        version = false, -- always use the latest git commit
        -- version = "*", -- latest stable release for plugins that support semver
    },
    checker = { -- automatically check for plugin updates,
        enabled = true,
        notify = false,
    },
    change_detection = { -- automatically check for config file changes and reload the ui
        enabled = false,
        notify = false,
    },
    performance = {
        rtp = {
            -- Built-in plugins this config doesn't use.
            disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
        },
    },
})
