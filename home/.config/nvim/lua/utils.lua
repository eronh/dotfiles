local M = {}

-- Launch dir wins; a single file uses its parent dir; else cwd.
function M.get_project_root()
    local arg = vim.fn.argv(0)
    if arg ~= "" and vim.fn.isdirectory(arg) == 1 then
        return vim.fn.fnamemodify(arg, ":p")
    elseif arg ~= "" and vim.fn.filereadable(arg) == 1 then
        return vim.fn.fnamemodify(arg, ":h")
    end
    return vim.fn.getcwd()
end

M.ROOT = M.get_project_root()

return M
