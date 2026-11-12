-- Symbols in the current file (functions, methods, classes, variables, ...)
-- in a Telescope picker: <leader>ds, or "Go to Symbol in Editor" in the
-- command palette.
--
-- The language server is the source when one attached to the buffer supports
-- document symbols. Otherwise Treesitter's `locals` query lists the
-- definitions it knows about (functions, methods, variables, parameters, ...),
-- so shell scripts, config files and buffers whose server hasn't attached yet
-- still get a list.
--
-- In the picker, a leading `:kind` narrows by symbol kind: `:method draw`,
-- `:class`, `:function` ...

local M = {}

-- True when the buffer's filetype has a Treesitter parser and a `locals` query.
local function has_treesitter_symbols(bufnr)
    local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
    if not lang then
        return false
    end
    local ok, added = pcall(vim.treesitter.language.add, lang)
    if not (ok and added) then
        return false
    end
    local has_query, query = pcall(vim.treesitter.query.get, lang, "locals")
    return has_query and query ~= nil
end

function M.document()
    local bufnr = vim.api.nvim_get_current_buf()
    local builtin = require("telescope.builtin")
    local method = vim.lsp.protocol.Methods.textDocument_documentSymbol
    if #vim.lsp.get_clients({ bufnr = bufnr, method = method }) > 0 then
        builtin.lsp_document_symbols()
    elseif has_treesitter_symbols(bufnr) then
        builtin.treesitter()
    else
        vim.notify(
            "No symbols: no language server or Treesitter parser for this buffer",
            vim.log.levels.WARN,
            { title = "Symbols" }
        )
    end
end

vim.keymap.set("n", "<leader>ds", function()
    M.document()
end, { desc = "[D]ocument [S]ymbols" })

return M
