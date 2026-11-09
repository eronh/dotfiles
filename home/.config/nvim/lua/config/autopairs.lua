-- Auto-pairs for brackets and quotes.
--
-- Replaces mini.pairs, whose rules only ever see one character on each side
-- of the cursor. These read the whole line instead: whether the cursor is
-- inside a string, whether the brackets on the line balance, which word is
-- right before the cursor. No treesitter, so it works the same in every
-- filetype and on any Neovim version.
--
-- Typing ( [ {
--   foo|       (   ->  foo(|)       pairs before space, end of line, ) ] } , ; : >
--   |foo       (   ->  (|foo        ...but not before a word or a quote, so you can wrap it
--   print|)    (   ->  print(|)     a stray ) on the line gets its partner instead
--   x = "|"    (   ->  x = "(|)"    the quote that ends the string you're in counts as a closer
--   \|         (   ->  \(|          escaped
--
-- Typing ) ] } skips over the closer under the cursor (or " }" after padding),
-- unless the line still has an unclosed opener that needs it:
--   foo(|)     )   ->  foo()|
--   foo(bar(|) )   ->  foo(bar()|)
--
-- Typing " ' `
--   x = |      "   ->  x = "|"
--   "foo|"     "   ->  "foo"|       skips over the closing quote
--   x = "a, |  "   ->  x = "a, "|   closes the string you're in instead of pairing
--   don|       '   ->  don'|        no pair after a letter (apostrophes)
--   x = f|     "   ->  x = f"|"     ...except Python string prefixes (f r b u rb ...)
--   sql|       `   ->  sql`|`       ...and JS/TS tagged templates
--   ""|        "   ->  """|"""      docstrings: Python, TOML, Kotlin, ...
--   ``|        `   ->  ```|         Markdown code fence, closing fence on the next line
--                      ```
--
-- <CR>     in (|) [|] {|} ( | ) """|""" puts the closer on its own line, cursor indented between
-- <BS>     deletes both halves of an empty pair, the padding of ( | ), or a pair <CR> split
-- <Space>  in an empty bracket pair pads both sides: {|} -> { | }
--
-- Toggle with <leader>up; vim.b.autopairs_disable = true turns it off for one buffer.

local function termcodes(keys)
    return vim.api.nvim_replace_termcodes(keys, true, true, true)
end

-- <C-g>U stops the cursor moves from breaking undo and dot-repeat
local LEFT, RIGHT = termcodes("<C-g>U<Left>"), termcodes("<C-g>U<Right>")
local BS, DEL, CR = termcodes("<BS>"), termcodes("<Del>"), termcodes("<CR>")

local BRACKETS = { ["("] = ")", ["["] = "]", ["{"] = "}" }
local QUOTES = { ['"'] = true, ["'"] = true, ["`"] = true }

-- What may follow the cursor for a new pair to open. Anything else (a word,
-- an opening bracket or quote, . $ - ...) is something you're likely wrapping.
local PAIRS_BEFORE = "^[%s%)%]},;:>]"
-- \128-\255 are the bytes of multibyte characters: treat ç, ã, é... as letters
local WORD = "[%w_\128-\255]"

-- Filetypes where a string can be opened right after a word
local PY_PREFIXES = { f = 1, r = 1, b = 1, u = 1, t = 1, rb = 1, br = 1, fr = 1, rf = 1, tr = 1, rt = 1 }
local TAGGED_TEMPLATES = {
    javascript = true,
    javascriptreact = true,
    typescript = true,
    typescriptreact = true,
    vue = true,
    svelte = true,
    astro = true,
}
-- Quotes that tripled open a multi-line string
local TRIPLE = {
    python = "\"'",
    toml = "\"'",
    elixir = '"',
    julia = '"',
    kotlin = '"',
    scala = '"',
    swift = '"',
    java = '"',
}
local MARKDOWN = { markdown = true, quarto = true, rmd = true, mdx = true, vimwiki = true }
-- ' quotes a symbol here, it never opens a string
local LISP = { lisp = true, scheme = true, clojure = true, fennel = true, racket = true, janet = true }

local function context()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    return line:sub(1, col), line:sub(col + 1)
end

local function disabled()
    return vim.g.autopairs_disable == true
        or vim.b.autopairs_disable == true
        or vim.bo.buftype == "prompt" -- Telescope's prompt and friends
        or vim.api.nvim_get_mode().mode:sub(1, 1) == "R" -- Replace mode would overwrite the next character
end

-- An odd run of backslashes before the cursor escapes the next character
local function escaped(before)
    return #before:match("\\*$") % 2 == 1
end

local function is_prefix(word, quote, ft)
    if TAGGED_TEMPLATES[ft] then
        return quote == "`" and word ~= ""
    end
    return ft == "python" and quote ~= "`" and PY_PREFIXES[word:lower()] ~= nil
end

-- Whether a quote typed after `text` starts a string, rather than being an
-- apostrophe (don't), a Lisp quote ('sym) or a Vim script comment.
local function opens_string(text, quote, ft)
    if quote == '"' then
        return not (ft == "vim" and text:match("^%s*$"))
    end
    if quote == "`" then
        return true
    end
    if LISP[ft] then
        return false
    end
    return not text:sub(-1):match(WORD) or is_prefix(text:match(WORD .. "*$"), quote, ft)
end

-- Quotes still open at the end of `text`, outermost first:
-- `print("say 'hi` -> { '"', "'" }
local function open_quotes(text, ft)
    local stack, i = {}, 1
    while i <= #text do
        local ch = text:sub(i, i)
        if ch == "\\" then
            i = i + 1
        elseif QUOTES[ch] then
            if vim.tbl_contains(stack, ch) then
                -- closes that string, and anything still open inside it
                repeat
                until table.remove(stack) == ch
            elseif opens_string(text:sub(1, i - 1), ch, ft) then
                stack[#stack + 1] = ch
            end
        end
        i = i + 1
    end
    return stack
end

-- Openers before the cursor that nothing before the cursor closes, and
-- closers after it that nothing after it opens.
local function unmatched(before, after, open, close)
    local openers, closers, depth = 0, 0, 0
    for i = #before, 1, -1 do
        local ch = before:sub(i, i)
        if ch == close then
            depth = depth + 1
        elseif ch == open then
            if depth > 0 then
                depth = depth - 1
            else
                openers = openers + 1
            end
        end
    end
    depth = 0
    for i = 1, #after do
        local ch = after:sub(i, i)
        if ch == open then
            depth = depth + 1
        elseif ch == close then
            if depth > 0 then
                depth = depth - 1
            else
                closers = closers + 1
            end
        end
    end
    return openers, closers
end

-- Set an option until Neovim is done handling this key
local saved = {}
local function for_this_key(name, value)
    if saved[name] == nil then
        saved[name] = vim.o[name]
        vim.schedule(function()
            vim.o[name] = saved[name]
            saved[name] = nil
        end)
    end
    vim.o[name] = value
end

local function pair(open, close)
    for_this_key("lazyredraw", true) -- no cursor flicker from the <Left>s
    return open .. close .. LEFT:rep(vim.fn.strchars(close))
end

-- Breaks the pair around the cursor onto three lines
local function split()
    -- <C-o> leaves Insert mode for one command; keep completion, diagnostics and
    -- other InsertLeave/InsertEnter handlers from running for it
    local events = "InsertLeave,InsertLeavePre,InsertEnter,ModeChanged,TextChanged"
    local ignored = saved.eventignore or vim.o.eventignore
    for_this_key("eventignore", ignored == "" and events or ignored .. "," .. events)
    for_this_key("lazyredraw", true)
    return CR .. termcodes("<C-o>O")
end

local function open_bracket(open)
    local close = BRACKETS[open]
    if disabled() then
        return open
    end
    local before, after = context()
    if escaped(before) then
        return open
    end
    local next_char = after:sub(1, 1)
    local quotes = open_quotes(before, vim.bo.filetype)
    if not (next_char == "" or next_char:match(PAIRS_BEFORE) or next_char == quotes[#quotes]) then
        return open
    end
    local openers, closers = unmatched(before, after, open, close)
    if closers > openers then
        return open
    end
    return pair(open, close)
end

local function close_bracket(close)
    local open = ({ [")"] = "(", ["]"] = "[", ["}"] = "{" })[close]
    if disabled() then
        return close
    end
    local before, after = context()
    local skip = (after:sub(1, 1) == close and 1) or (after:sub(1, 2) == " " .. close and 2)
    if not skip or escaped(before) then
        return close
    end
    local openers, closers = unmatched(before, after, open, close)
    if openers > closers then
        return close
    end
    return RIGHT:rep(skip)
end

local function quote(q)
    if disabled() then
        return q
    end
    local ft = vim.bo.filetype
    local before, after = context()
    if escaped(before) then
        return q
    end
    local prev_char, next_char = before:sub(-1), after:sub(1, 1)

    if next_char == q then
        return RIGHT
    end

    if before:sub(-2) == q .. q and before:sub(-3, -3) ~= q then
        if q == "`" and MARKDOWN[ft] and before:match("^%s*``$") and after == "" then
            return q .. CR .. "```" .. termcodes("<Up><End>")
        end
        if TRIPLE[ft] and TRIPLE[ft]:find(q, 1, true) then
            return pair(q, q:rep(3))
        end
    end

    local quotes = open_quotes(before, ft)
    if quotes[#quotes] == q then
        return q -- closes the string the cursor is in
    end
    if prev_char == q or (prev_char:match(WORD) and not is_prefix(before:match(WORD .. "*$"), q, ft)) then
        return q
    end
    if not opens_string(before, q, ft) then
        return q
    end
    if not (next_char == "" or next_char:match(PAIRS_BEFORE) or next_char == quotes[#quotes]) then
        return q
    end
    return pair(q, q)
end

local function triple_quotes_around(before, after)
    local triple, q = TRIPLE[vim.bo.filetype], before:sub(-1)
    return triple ~= nil
        and QUOTES[q] ~= nil
        and triple:find(q, 1, true) ~= nil
        and before:sub(-3) == q:rep(3)
        and after:sub(1, 3) == q:rep(3)
end

-- ( | ) with one space of padding on each side
local function padded_brackets(before, after)
    local open = before:sub(-2, -2)
    return before:sub(-1) == " "
        and after:sub(1, 1) == " "
        and BRACKETS[open] ~= nil
        and after:sub(2, 2) == BRACKETS[open]
end

local function enter()
    if disabled() then
        return CR
    end
    local before, after = context()
    local open = before:sub(-1)
    if (BRACKETS[open] and after:sub(1, 1) == BRACKETS[open]) or triple_quotes_around(before, after) then
        return split()
    end
    if padded_brackets(before, after) then
        return DEL .. BS .. split()
    end
    return CR
end

local function backspace()
    if disabled() then
        return BS
    end
    local before, after = context()
    local prev_char, next_char = before:sub(-1), after:sub(1, 1)

    if (BRACKETS[prev_char] and next_char == BRACKETS[prev_char]) or padded_brackets(before, after) then
        return BS .. DEL
    end
    if triple_quotes_around(before, after) then
        return BS:rep(3) .. DEL:rep(3)
    end
    -- "|" but not "foo"|"bar"
    if QUOTES[prev_char] and next_char == prev_char then
        local quotes = open_quotes(before, vim.bo.filetype)
        if quotes[#quotes] == prev_char then
            return BS .. DEL
        end
    end

    -- {
    --   |      ->  {|}
    -- }
    local row = vim.api.nvim_win_get_cursor(0)[1]
    if row > 1 and before:match("^%s*$") and after:match("^%s*$") then
        local lines = vim.api.nvim_buf_get_lines(0, row - 2, row + 1, false)
        local close = BRACKETS[(lines[1] or ""):sub(-1)]
        local indent, rest = (lines[3] or ""):match("^(%s*)(.*)$")
        if close and rest and rest:sub(1, 1) == close then
            -- clear this line, pull the closer up without its indent, then join onto the opener
            return LEFT:rep(#before) .. DEL:rep(#before + #after + 1 + #indent) .. BS
        end
    end
    return BS
end

local function space()
    if disabled() then
        return " "
    end
    local before, after = context()
    local open = before:sub(-1)
    -- `- [ ]` task boxes stay unpadded
    if BRACKETS[open] and after:sub(1, 1) == BRACKETS[open] and not (open == "[" and MARKDOWN[vim.bo.filetype]) then
        return "  " .. LEFT
    end
    -- { a = 1| }  ->  { a = 1 |}   type through the padding instead of doubling it
    if after:match("^ [%)%]}]") then
        return RIGHT
    end
    return " "
end

local function map(lhs, fn, desc)
    vim.keymap.set("i", lhs, fn, { expr = true, replace_keycodes = false, silent = true, desc = desc })
end

for open, close in pairs(BRACKETS) do
    map(open, function()
        return open_bracket(open)
    end, "Auto-pair " .. open .. close)
    map(close, function()
        return close_bracket(close)
    end, "Skip over " .. close)
end
for q in pairs(QUOTES) do
    map(q, function()
        return quote(q)
    end, "Auto-pair " .. q .. q)
end
-- blink.cmp's <CR> and <BS> fall back to these when no completion is selected
map("<CR>", enter, "Split pair onto separate lines")
map("<BS>", backspace, "Delete pair")
map("<Space>", space, "Pad pair")

if _G.Snacks then
    Snacks.toggle({
        name = "Auto Pairs",
        get = function()
            return not vim.g.autopairs_disable
        end,
        set = function(state)
            vim.g.autopairs_disable = not state
        end,
    }):map("<leader>up")
end
