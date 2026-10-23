return {
    "saghen/blink.cmp",
    -- Not lazy: lsp.lua calls get_lsp_capabilities() in its config, so blink has
    -- to be loadable by then. Upstream also recommends against lazy-loading it.
    lazy = false,
    version = "1.*", -- release tags ship the prebuilt fuzzy binary; no Rust toolchain needed
    dependencies = { "rafamadriz/friendly-snippets" },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        keymap = {
            preset = "default", -- <C-space> open, <C-n>/<C-p> select, <C-e> hide, <C-y> accept
            ["<CR>"] = { "accept", "fallback" },
            ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
            ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
            ["<C-l>"] = { "snippet_forward", "fallback" },
            ["<C-h>"] = { "snippet_backward", "fallback" },
        },
        appearance = { nerd_font_variant = "mono" },
        completion = {
            documentation = { auto_show = true, auto_show_delay_ms = 200 },
            ghost_text = { enabled = false },
        },
        sources = {
            default = { "lsp", "path", "snippets", "buffer" },
            per_filetype = { lua = { inherit_defaults = true, "lazydev" } },
            providers = {
                lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
            },
        },
        fuzzy = { implementation = "prefer_rust_with_warning" },
        signature = { enabled = true },
    },
    opts_extend = { "sources.default" },
}
