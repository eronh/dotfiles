-- Git history of the cursor line or selected lines (<leader>hl, like GitLens'
-- "Show Line History") and of the whole file (<leader>hf), as Telescope
-- pickers. Each commit's diff of the file shows in the preview.
--   <CR>               the commit (message and diff of this file) in a split; q closes it
--   <C-v> <C-x> <C-t>  diff the file against its version in that commit
-- Upstream's <CR> runs `git checkout <commit> -- <file>`, which silently
-- overwrites the working copy, so it is replaced here.

local M = {}

local function notify(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO, { title = "Git History" })
end

local function git(dir, args)
    local out = vim.system(vim.list_extend({ "git", "-C", dir }, args), { text = true }):wait()
    return out.code == 0 and out.stdout or nil, out.stderr
end

-- The current buffer's file and directory, or nil (with a message) when it
-- isn't a file in a git repository.
local function current_file()
    local file = vim.api.nvim_buf_get_name(0)
    if vim.bo.buftype ~= "" or file == "" then
        return notify("Not a file", vim.log.levels.WARN)
    end
    local dir = vim.fn.fnamemodify(file, ":h")
    if not git(dir, { "rev-parse", "--show-toplevel" }) then
        return notify("Not in a git repository", vim.log.levels.WARN)
    end
    return file, dir
end

-- `git log -L` counts lines in HEAD, not in the buffer, so uncommitted or
-- unsaved edits above the cursor would shift the range onto other lines. This
-- diffs HEAD's version against the buffer and maps the range back; edited
-- lines map to the lines they replaced. Returns nil when the file isn't in
-- HEAD or every line in the range is new.
local function head_range(file, dir, first, last)
    local head = git(dir, { "show", "HEAD:./" .. vim.fn.fnamemodify(file, ":t") })
    if not head then
        return nil
    end
    local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n") .. "\n"
    local hunks = (vim.text and vim.text.diff or vim.diff)(head, text, { result_type = "indices" })

    local function map(line, is_first)
        local offset = 0
        for _, h in ipairs(hunks) do
            local old_start, old_count, new_start, new_count = h[1], h[2], h[3], h[4]
            -- With a count of 0, the start is the line before the hunk.
            if old_count == 0 then
                old_start = old_start + 1
            end
            if new_count == 0 then
                new_start = new_start + 1
            end
            if line < new_start then
                break
            end
            if line < new_start + new_count then
                return is_first and old_start or old_start + old_count - 1
            end
            offset = (old_start + old_count) - (new_start + new_count)
        end
        return line + offset
    end

    local from, to = map(first, true), map(last, false)
    if from <= to then
        return from, to
    end
end

local function show_commit(dir, sha, file)
    local out, err = git(dir, { "show", "--no-color", "--no-ext-diff", sha, "--", file })
    if not out then
        return notify(err, vim.log.levels.ERROR)
    end
    local lines = vim.split(out, "\n", { plain = true })
    if lines[#lines] == "" then
        table.remove(lines)
    end
    vim.cmd("vertical new")
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = "git"
    pcall(vim.api.nvim_buf_set_name, buf, ("git show %s -- %s"):format(sha, vim.fn.fnamemodify(file, ":t")))
    vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = buf, desc = "Close" })
end

local function picker_opts(file, dir, opts)
    return vim.tbl_extend("force", {
        use_file_path = true, -- the file's repo, not the cwd's
        -- Runs after the picker's own attach_mappings, so this <CR> wins.
        attach_mappings = function()
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")
            actions.select_default:replace(function(prompt_bufnr)
                local entry = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if entry then
                    show_commit(dir, entry.value, file)
                end
            end)
            return true
        end,
    }, opts)
end

---@param first? integer buffer line, defaults to the cursor line
---@param last? integer defaults to `first`
function M.line(first, last)
    local file, dir = current_file()
    if not file then
        return
    end
    first = first or vim.fn.line(".")
    last = last or first
    local from, to = head_range(file, dir, first, last)
    if not from then
        return notify(first == last and "Line not committed yet" or "Lines not committed yet")
    end
    require("telescope.builtin").git_bcommits_range(picker_opts(file, dir, {
        from = from,
        to = to,
        prompt_title = first == last and ("Line %d History"):format(first)
            or ("Lines %d-%d History"):format(first, last),
    }))
end

function M.file()
    local file, dir = current_file()
    if not file then
        return
    end
    require("telescope.builtin").git_bcommits(picker_opts(file, dir, {
        prompt_title = vim.fn.fnamemodify(file, ":t") .. " History",
    }))
end

vim.keymap.set("n", "<leader>hl", function()
    M.line()
end, { desc = "Git: line history" })

vim.keymap.set("x", "<leader>hl", function()
    local first, last = vim.fn.line("v"), vim.fn.line(".")
    if first > last then
        first, last = last, first
    end
    vim.cmd("normal! \27") -- leave visual mode before the picker opens
    M.line(first, last)
end, { desc = "Git: history of selected lines" })

vim.keymap.set("n", "<leader>hf", function()
    M.file()
end, { desc = "Git: file history" })

return M
