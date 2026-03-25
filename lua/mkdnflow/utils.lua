-- mkdnflow.nvim (Tools for personal markdown notebook navigation and management)
-- Copyright (C) 2022 Jake W. Vincent <https://github.com/jakewvincent>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

local M = {}

-- TODO: Remove when dropping Neovim 0.9 support
M.keycode = vim.keycode
    or function(str)
        return vim.api.nvim_replace_termcodes(str, true, false, true)
    end

--- Check if a table is array-like (consecutive integer keys starting at 1)
--- Used by mergeTables to determine whether to replace or recursively merge
---@param t any
---@return boolean
---@private
local function isArray(t)
    if type(t) ~= 'table' then
        return false
    end
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    -- Empty tables are not treated as arrays (preserves default values)
    if count == 0 then
        return false
    end
    -- Check if all keys are consecutive integers 1..count
    for i = 1, count do
        if t[i] == nil then
            return false
        end
    end
    return true
end

M.isArray = isArray

--- Merge user_config into the default config table (in-place)
--- Array-like tables are replaced entirely; dict-like tables are merged recursively
---@param defaults table The default configuration table (modified in-place)
---@param user_config table The user-provided configuration overrides
---@return table defaults The merged table (same reference as `defaults`)
M.mergeTables = function(defaults, user_config)
    for k, v in pairs(user_config) do
        if type(v) == 'table' then
            -- If user provides an array, replace entirely (don't merge element-by-element)
            if isArray(v) then
                defaults[k] = v
            elseif type(defaults[k] or false) == 'table' then
                M.mergeTables(defaults[k] or {}, user_config[k] or {})
            else
                defaults[k] = v
            end
        else
            defaults[k] = v
        end
    end
    return defaults
end

--- Identify the root directory by searching upward for a root indicator file/directory
---@param dir string The directory to start searching from
---@param root_tell string|string[] Filename(s) that indicate the project root
---@param os? string The operating system (unused, kept for API compatibility)
---@return string|nil root_dir The root directory path, or nil if not found
M.getRootDir = function(dir, root_tell, os)
    local results = vim.fs.find(root_tell, { upward = true, path = dir })
    if results and results[1] then
        return vim.fs.dirname(results[1])
    end
    return nil
end

--- Check if a Lua module is available (loadable) without actually loading it
---@param name string The module name (e.g., "mkdnflow.links")
---@return boolean available Whether the module can be loaded
M.moduleAvailable = function(name)
    if package.loaded[name] then
        return true
    else
        for _, searcher in ipairs(package.searchers or package.loaders) do
            local loader = searcher(name)
            if type(loader) == 'function' then
                package.preload[name] = loader
                return true
            end
        end
        return false
    end
end

--- Multi-line find: search for a pattern across concatenated lines
--- Returns the match position in terms of buffer rows and columns
---@param tbl string[] Array of line strings to search across
---@param str string|string[] Pattern(s) to search for; if a table, performs multi-step regex search
---@param start_row integer The buffer row corresponding to tbl[1]
---@param init_row? integer The cursor row (defaults to 1)
---@param init_col? integer The column to start searching from (defaults to 1)
---@param plain? boolean Use plain string matching (defaults to false)
---@return integer|nil match_start_row
---@return integer|nil match_start_col
---@return integer|nil match_end_row
---@return integer|nil match_end_col
---@return string|nil capture The captured group, if any
---@return string[] match_lines The lines spanning the match
M.mFind = function(tbl, str, start_row, init_row, init_col, plain)
    init_row = init_row or 1 -- Line where the cursor is (start_row is first line in table, including user-configurable context)
    init_col = init_col or 1 -- Where to start the search from in the line
    plain = plain or false
    local init, match_lines = init_col, {}
    -- Derive the init point for the concatenated lines
    if start_row < init_row then
        local diff = init_row - start_row
        for i = 1, diff, 1 do
            init = init + #tbl[i]
        end
    end
    local catlines = table.concat(tbl)
    local start, finish, capture
    -- If str is a table of strings, perform the a multi-step regex search
    if type(str) == 'table' then
        for i in ipairs(str) do
            local init_ = start or init
            local catlines_ = finish and string.sub(catlines, 1, finish) or catlines
            start, finish, capture = string.find(catlines_, str[i], init_, plain)
            if capture then
                start, finish = string.find(string.sub(catlines, 1, finish), capture, start, true)
            end
        end
    -- Otherwise, just do it once
    else
        start, finish, capture = string.find(catlines, str, init, plain)
        if capture then
            start, finish = string.find(catlines, capture, start, true)
        end
    end
    local chars, match_start_row, match_start_col, match_end_row, match_end_col =
        0, nil, nil, nil, nil
    if start and finish then
        for i, line in ipairs(tbl) do
            if match_start_row and not match_end_row then -- If we have the start row but not the end row...
                table.insert(match_lines, line)
            end
            if (not match_start_row) and start <= (#line + chars) then -- If we don't have the start row yet, and the match we've found starts before the end of the current line...
                match_start_row, match_start_col = start_row + i - 1, start - chars
                table.insert(match_lines, line)
            end
            if (not match_end_row) and finish <= (#line + chars) then -- If we don't have the end row yet, and the match we've found ends before the current line...
                match_end_row, match_end_col = start_row + i - 1, finish - chars
            end
            chars = chars + #line
        end
    end
    return match_start_row, match_start_col, match_end_row, match_end_col, capture, match_lines
end

--- Check if the character at a given position is a multi-byte character
---@param args {buffer?: integer, row?: integer, start_col?: integer, opts?: table, text?: string}
---@return {start: integer, finish: integer}|false result Byte range of the character, or false if single-byte
M.isMultibyteChar = function(args)
    -- Extract arguments from table
    local buffer = args.buffer or 0
    local row = args.row or nil
    local start_col = args.start_col or nil
    local opts = args.opts or {}
    local text = args.text or nil
    local byte
    if text ~= nil and start_col ~= nil then
        byte = string.sub(text, start_col, start_col + 1)
    else
        byte = vim.api.nvim_buf_get_text(buffer, row, start_col - 1, row, start_col, opts)[1]
    end
    local width = vim.api.nvim_strwidth(byte)
    local last_width = width
    -- Check up to the following three bytes (max byte count for a single char in unicode is 4)
    for i = 1, 3, 1 do
        -- Concat to the previous byte and see if the string width reduces
        if text ~= nil and start_col ~= nil then
            byte = byte .. string.sub(text, start_col + i, start_col + 1 + i)
        else
            byte = byte
                .. vim.api.nvim_buf_get_text(buffer, row, start_col - 1 + i, row, start_col + i, {})[1]
        end
        width = vim.api.nvim_strwidth(byte)
        if width < last_width then
            -- Return the byte indices for the character in question
            return { start = start_col - 1, finish = start_col + i }
        elseif i == 3 then
            -- If we're on the last iteration and this condition was met (rather than the other), there's no multibyte char
            return false
        end
    end
end

--- Iterate over a table in sorted key order
---@param tbl table<any, any> The table to iterate over
---@return fun(): any, any iterator A stateful iterator returning (key, value) pairs in sorted order
M.spairs = function(tbl)
    -- Get the keys and sort them
    local keys = {}
    for k, _ in pairs(tbl) do
        table.insert(keys, k)
    end
    table.sort(keys)

    -- Return an iterator function
    local i = 0
    return function()
        i = i + 1
        local key = keys[i]
        if key ~= nil then
            return key, tbl[key]
        end
    end
end

--- Iterator that yields match positions and captures for a pattern in text
---@param text string|nil The text to search in
---@param pattern string The Lua pattern to search for
---@param start? integer The byte position to start searching from (defaults to 1)
---@return fun(): integer|nil, integer|nil, string|nil iterator Returns (match_start, match_end, capture) or nil
M.gmatch = function(text, pattern, start)
    start = start ~= nil and start or 1
    return function()
        if not text then
            return nil -- Handle nil text gracefully
        end
        while start <= #text do
            local match_start, match_end, match = string.find(text, pattern, start)
            if match_start then
                start = match_end + 1 -- Update the start for the next search
                return match_start, match_end, match
            else
                break -- No more matches, exit loop
            end
        end
        return nil -- Explicitly return nil when no more data to iterate
    end
end

--- Check whether the cursor is inside a fenced code block
---@param cursor_row integer The 1-indexed row to check
---@param reverse? boolean If true, count fences from cursor_row to end of buffer instead of from start
---@return boolean in_code_block Whether the cursor is inside a code block
M.cursorInCodeBlock = function(cursor_row, reverse)
    if reverse == nil or reverse == false then
        reverse = false
    else
        reverse = true
    end
    local lines = reverse and vim.api.nvim_buf_get_lines(0, cursor_row - 1, -1, false)
        or vim.api.nvim_buf_get_lines(0, 0, cursor_row, false)
    local fences = 0
    for _, line_text in ipairs(lines) do
        local _, count = string.gsub(line_text, '^```', '```')
        fences = fences + count
    end
    if fences % 2 == 0 then
        return false
    end
    return true
end

--- Get the heading level of a markdown line
---@param line? string The line text to check
---@return integer level The heading level (1-6), or 99 if not a heading
M.getHeadingLevel = function(line)
    local level
    if line then
        level = line:match('^%s-(#+)')
    end
    return (level and string.len(level)) or 99
end

return M
