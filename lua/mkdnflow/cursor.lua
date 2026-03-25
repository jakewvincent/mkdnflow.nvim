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

local utils = require('mkdnflow.utils')

--- Find the nearest match among multiple patterns, with support for reverse searching
---@param str string The string to search in
---@param patterns string|string[] One or more Lua patterns to search for
---@param reverse? boolean Search for the rightmost match instead of the leftmost (default false)
---@param init? integer Starting position for the search
---@return integer|nil left Start index of the closest match
---@return integer|nil right End index of the closest match
---@private
local find_patterns = function(str, patterns, reverse, init)
    reverse = reverse or false
    -- If the patterns arg is a string, add it to a table
    patterns = type(patterns) == 'table' and patterns or { patterns }
    -- Truncate the string if we're doing a reverse search
    str = (reverse and init and string.sub(str, 1, init)) or str
    local left, right, left_tmp, right_tmp
    -- Look for the patterns
    for i = 1, #patterns, 1 do
        left_tmp, right_tmp = string.find(str, patterns[i], reverse and 1 or init)
        if reverse then
            local left_check, right_check = left_tmp, right_tmp
            -- Make sure we're finding the rightmost match if we're doing a reverse search
            while left_check do
                left_check, right_check = string.find(str, patterns[i], left_tmp + 1)
                if left_check then
                    left_tmp, right_tmp = left_check, right_check
                end
            end
        end
        -- If we've found a closer match amongst the provided patterns, use that instead
        -- (NOTE: 'closer' means closer to the beginning of the string if we're doing a forward
        -- search and closer to the end of the string if we're doing a reverse search)
        if left_tmp and (left == nil or ((reverse and left_tmp > left) or left_tmp < left)) then
            left, right = left_tmp, right_tmp
        end
    end
    return left, right
end

-- =============================================================================
-- Detection-based jumping helpers
-- =============================================================================

--- Find inline code ranges on a line (backtick-delimited spans)
---@param line string The line text
---@return table[] Array of {start, end} pairs
---@private
local function find_inline_code_ranges(line)
    local ranges = {}
    local pos = 1
    while true do
        local s, e = line:find('`[^`]+`', pos)
        if not s then
            break
        end
        table.insert(ranges, { s, e })
        pos = e + 1
    end
    return ranges
end

--- Check if a column falls within any inline code range
---@param col integer 1-indexed column
---@param code_ranges table[] Array of {start, end} pairs
---@return boolean
---@private
local function in_code_range(col, code_ranges)
    for _, range in ipairs(code_ranges) do
        if col >= range[1] and col <= range[2] then
            return true
        end
    end
    return false
end

--- Collect all footnote definition labels in the buffer
---@param bufnr? integer Buffer number (defaults to current)
---@return table<string, boolean> Set of footnote labels that have definitions
---@private
local function collect_footnote_defs(bufnr)
    local defs = {}
    local lines = vim.api.nvim_buf_get_lines(bufnr or 0, 0, -1, false)
    for _, line in ipairs(lines) do
        local label = string.match(line, '^%s?%s?%s?%[%^(.-)%]:%s')
        if label then
            defs[label] = true
        end
    end
    return defs
end

--- Determine whether a detected link should be a jump target
---@param link table A Link instance from scan_line
---@param footnote_defs table<string, boolean> Set of footnote definition labels
---@param style string The configured link style ('markdown' or 'wiki')
---@return boolean
---@private
local function should_jump_to(link, footnote_defs, style)
    local t = link.type
    -- Definition lines aren't navigable jump targets
    if t == 'ref_definition' or t == 'footnote_definition' then
        return false
    end
    -- Footnote refs require a matching definition to avoid false positives
    if t == 'footnote_ref' then
        local label = string.match(link.match, '%[%^(.-)%]')
        return label and footnote_defs[label] == true
    end
    -- Wiki links only when wiki style is configured
    if t == 'wiki_link' then
        return style == 'wiki'
    end
    return true
end

--- Collect all match positions from extra user patterns on a line
---@param line string The line text
---@param extra_patterns string|string[] Lua patterns
---@return table[] Array of {col, end_col} tables
---@private
local function collect_extra_pattern_positions(line, extra_patterns)
    local positions = {}
    extra_patterns = type(extra_patterns) == 'table' and extra_patterns or { extra_patterns }
    for _, pat in ipairs(extra_patterns) do
        local pos = 1
        while true do
            local s, e = string.find(line, pat, pos)
            if not s then
                break
            end
            table.insert(positions, { col = s, end_col = e })
            pos = e + 1
        end
    end
    return positions
end

local M = {}

--- Move the cursor to the next (or previous) instance of a pattern or detection target
---@param pattern_or_finder string|string[]|function Lua patterns, or a finder function(line, row) → integer[]
---@param reverse? boolean If true, search backward instead of forward
M.goTo = function(pattern_or_finder, reverse)
    local is_finder = type(pattern_or_finder) == 'function'
    local search_range = require('mkdnflow').config.links.search_range
    local wrap = require('mkdnflow').config.wrap
    -- Get current position of cursor
    local position = vim.api.nvim_win_get_cursor(0)
    local row, col = position[1], position[2]
    local already_wrapped = false

    if is_finder then
        -- Detection-based path: build finder with correct code block state
        local Link = require('mkdnflow.links.core').Link
        local footnote_defs = collect_footnote_defs()
        local config = require('mkdnflow').config
        local extra_patterns = config.cursor.jump_patterns
        local style = config.links.style

        -- Pre-compute code block state at the cursor row
        local pre_lines = vim.api.nvim_buf_get_lines(0, 0, row - 1, false)
        local fences_before = 0
        for _, pre_line in ipairs(pre_lines) do
            if string.find(pre_line, '^```') then
                fences_before = fences_before + 1
            end
        end
        local in_code_block = (fences_before % 2) == 1

        -- Finder returns {col, end_col} pairs sorted by col
        local function finder(line, finder_row)
            if string.find(line, '^```') then
                in_code_block = not in_code_block
            end
            if in_code_block then
                return {}
            end

            local targets = {}
            local code_ranges = find_inline_code_ranges(line)

            local links = Link.scan_line(line, finder_row)
            for _, link in ipairs(links) do
                if
                    should_jump_to(link, footnote_defs, style)
                    and not in_code_range(link.start_col, code_ranges)
                then
                    table.insert(targets, { col = link.start_col, end_col = link.end_col })
                end
            end

            if extra_patterns and #extra_patterns > 0 then
                local extras = collect_extra_pattern_positions(line, extra_patterns)
                for _, t in ipairs(extras) do
                    table.insert(targets, t)
                end
            end

            table.sort(targets, function(a, b)
                return a.col < b.col
            end)
            return targets
        end

        -- Scan lines to find the target
        local continue = true
        while continue do
            local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
            if line then
                local line_len = #line
                local targets = finder(line, row)
                local best = nil
                if reverse then
                    -- Find rightmost target that the cursor is NOT inside of.
                    -- cursor is at 0-indexed col; 1-indexed = col + 1
                    local cur_1 = col + 1
                    for i = #targets, 1, -1 do
                        local t = targets[i]
                        -- Skip links the cursor is currently inside
                        if cur_1 >= t.col and cur_1 <= t.end_col then
                            goto skip_reverse
                        end
                        if t.col < cur_1 then
                            best = t.col
                            break
                        end
                        ::skip_reverse::
                    end
                else
                    -- Find leftmost target after cursor
                    local cur_1 = col + 1
                    for _, t in ipairs(targets) do
                        if t.col > cur_1 and t.col <= line_len then
                            best = t.col
                            break
                        end
                    end
                end

                if best then
                    vim.api.nvim_win_set_cursor(0, { row, best - 1 })
                    continue = false
                else
                    row = reverse and row - 1 or row + 1
                    col = reverse and math.huge or -1
                end
            else
                if wrap == true then
                    if not already_wrapped then
                        in_code_block = false
                        row = reverse and vim.api.nvim_buf_line_count(0) or 1
                        col = reverse and math.huge or -1
                        already_wrapped = true
                    else
                        continue = nil
                    end
                else
                    continue = nil
                end
            end
        end
    else
        -- Pattern-based path (original behavior for direct goTo() calls)
        local pattern = pattern_or_finder
        local line, line_len, left, right
        -- Get the line's contents
        line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
        line_len = #line
        if search_range > 0 and line_len > 0 then
            for i = 1, search_range, 1 do
                local following_line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
                line = (following_line and line .. following_line) or line
            end
        end
        -- Get start & end indices of match (if any)
        left, right = find_patterns(line, pattern, reverse, col)
        -- As long as a match hasn't been found, keep looking as long as possible!
        local continue = true
        while continue do
            -- See if there's a match on the current line.
            if left and right then
                -- If there is, see if the cursor is before the match (or after if rev = true)
                if
                    ((reverse and col + 1 > left) or ((not reverse) and col + 1 < left))
                    and left <= line_len
                then
                    -- If it is, send the cursor to the start of the match
                    vim.api.nvim_win_set_cursor(0, { row, left - 1 })
                    continue = false
                else -- If it isn't, search after the end of the previous match (before if reverse).
                    left, right = find_patterns(line, pattern, reverse, reverse and left or right)
                end
            else -- If there's not a match on the current line, keep checking line-by-line
                -- Update row to search next line
                row = (reverse and row - 1) or row + 1
                -- Get the content of the next line (if any)
                line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
                line_len = line and #line
                col = reverse and line_len or -1
                if line and search_range > 0 and line_len > 0 then
                    for i = 1, search_range, 1 do
                        local following_line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
                        line = (following_line and line .. following_line) or line
                    end
                end
                if line then
                    left, right = find_patterns(line, pattern, reverse)
                else
                    if wrap == true then
                        if not already_wrapped then
                            row = (reverse and vim.api.nvim_buf_line_count(0) + 1) or 0
                            already_wrapped = true
                        else
                            continue = nil
                        end
                    else
                        continue = nil
                    end
                end
            end
        end
    end
end

--- Jump to a heading matching the given anchor text, or to the next/previous heading
---@param anchor_text? string The anchor link text to match (e.g., "#my-heading"); if nil, jumps to next heading
---@param reverse? boolean If true, search backward
---@param level? number Level of the heading to jump to
---@return boolean found Whether a matching heading was found
---@private
local go_to_heading = function(anchor_text, reverse, level)
    local links = require('mkdnflow').links
    local silent = require('mkdnflow').config.silent
    local wrap = require('mkdnflow').config.wrap

    -- Record which line we're on; chances are the link goes to something later,
    -- so we'll start looking from here onwards and then circle back to the beginning
    local position = vim.api.nvim_win_get_cursor(0)
    local starting_row, continue = position[1], true
    local in_fenced_code_block = utils.cursorInCodeBlock(starting_row, reverse)
    local row = (reverse and starting_row - 1) or starting_row + 1
    while continue do
        local line = (reverse and vim.api.nvim_buf_get_lines(0, row - 1, row, false))
            or vim.api.nvim_buf_get_lines(0, row - 1, row, false)
        -- If the line has contents, do the thing
        if line[1] then
            -- Are we in a code block?
            if string.find(line[1], '^```') then
                -- Flip the truth value
                in_fenced_code_block = not in_fenced_code_block
            end
            -- Does the line start with a hash?
            local has_heading = string.find(line[1], '^#')
            if has_heading and not in_fenced_code_block then
                if anchor_text == nil then
                    -- Send the cursor to the heading
                    -- local new_line = vim.api.nvim_get_current_line()
                    -- local heading_level = utils.getHeadingLevel(new_line)
                    local new_line = vim.api.nvim_buf_get_lines(0, row-1, row, false)[1]
                    local heading_level = utils.getHeadingLevel(new_line)
                    if level == nil or heading_level == level then
                        vim.api.nvim_win_set_cursor(0, { row, 0 })
                        return true
                    end
                else
                    -- Format current heading to see if it matches our search term
                    -- Try new Unicode-aware anchor first
                    local heading_as_anchor = links.formatLink(line[1], nil, 2)
                    -- Also generate legacy ASCII-only anchor for fallback matching
                    local heading_as_anchor_legacy = links.formatAnchorLegacy(line[1])
                    if
                        anchor_text == heading_as_anchor
                        or anchor_text == heading_as_anchor_legacy
                    then
                        -- Set a mark
                        vim.api.nvim_buf_set_mark(0, '`', position[1], position[2], {})
                        -- Send the cursor to the row w/ the matching heading
                        vim.api.nvim_win_set_cursor(0, { row, 0 })
                        return true
                    end
                end
            end
            row = (reverse and row - 1) or row + 1
            if row == starting_row + 1 then
                continue = nil
                if anchor_text == nil then
                    if not silent then
                        vim.notify("⬇️  Couldn't find a heading to go to!", vim.log.levels.WARN)
                    end
                else
                    if not silent then
                        vim.notify(
                            "⬇️  Couldn't find a heading matching " .. anchor_text .. '!',
                            vim.log.levels.WARN
                        )
                    end
                end
            end
        else
            -- If the line does not have contents, start searching from the beginning
            if anchor_text ~= nil or wrap == true then
                row = (reverse and vim.api.nvim_buf_line_count(0)) or 1
                in_fenced_code_block = false
            else
                continue = nil
                local place = (reverse and 'beginning') or 'end'
                local preposition = (reverse and 'after') or 'before'
                if not silent then
                    vim.notify(
                        '⬇️  There are no more headings '
                            .. preposition
                            .. ' the '
                            .. place
                            .. ' of the document!',
                        vim.log.levels.WARN
                    )
                end
            end
        end
    end
    return false
end

--- Go to the next or previous heading of the same level
---@param reverse? boolean If true, search backward
M.goToSame = function(reverse)
     -- save start position to jump back if no headings
    local start_pos = vim.api.nvim_win_get_cursor(0)

    -- Scan backwards to find the closest heading
    -- (including current line)
    local line
    local level = 99 -- default return value for invalid level
    local row = vim.api.nvim_win_get_cursor(0)[1]
    while (level == 99) and row > 0 do
        line = vim.api.nvim_buf_get_lines(0, row-1, row, false)[1]
        level = utils.getHeadingLevel(line)
        row = row - 1
    end
    -- no parent heading found... return early
    if row == 0 and (level == 99) then
        return
    end
    -- Now search for the next heading
    go_to_heading(nil, reverse, level)
end

--- Jump to a Pandoc-style bracketed span or heading with a matching ID attribute
---@param id string The ID to search for (e.g., "#my-id")
---@param starting_row? integer The 1-indexed row to start searching from (defaults to cursor row)
---@return boolean found Whether a matching element was found
---@private
local go_to_id = function(id, starting_row)
    starting_row = starting_row or vim.api.nvim_win_get_cursor(0)[1]
    local continue = true
    local row, line_count = starting_row, vim.api.nvim_buf_line_count(0)
    local start, finish
    while continue and row <= line_count do
        local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
        start, finish = line:find('%b[]%b{}')
        -- Look for Pandoc-style ID attributes in headings if a bracketed span wasn't found
        if not start and not finish then
            start, finish = line:find('%s*#+.*%b{}%s*$')
        end
        if start then
            local substring = string.sub(line, start, finish)
            if substring:match('{[^%}]*' .. vim.pesc(id) .. '[^%}]*}') then
                continue = false
            else
                local continue_line = true
                while continue_line do
                    start, finish = line:find('%b[]%b{}', finish)
                    if start then
                        substring = string.sub(line, start, finish)
                        if substring:match('{[^%}]*' .. vim.pesc(id) .. '[^%}]*}') then
                            continue_line = false
                            continue = false
                        end
                    else
                        continue_line = false
                        row = row + 1
                    end
                end
            end
        else
            row = row + 1
        end
    end
    if start and finish then
        vim.api.nvim_win_set_cursor(0, { row, start - 1 })
        return true
    else
        return false
    end
end

--- Change the heading level by adding or removing a `#` symbol
---@param change 'increase'|'decrease' Direction to change (increase = remove `#`, decrease = add `#`)
---@param opts? {line1?: integer, line2?: integer} Optional range for multi-line operations
M.changeHeadingLevel = function(change, opts)
    opts = opts or {}
    local start_row = opts.line1 or vim.api.nvim_win_get_cursor(0)[1]
    local end_row = opts.line2 or start_row

    for row = start_row, end_row do
        local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)
        -- See if the line starts with a hash
        local is_heading = string.find(line[1], '^#')
        if is_heading then
            if change == 'decrease' then
                -- Add a hash
                vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, 0, { '#' })
            else
                -- Remove a hash, but only if there's more than one
                if not string.find(line[1], '^##') then
                    -- Only show warning for single-line operations
                    if start_row == end_row then
                        if not require('mkdnflow').config.silent then
                            vim.notify(
                                "⬇️  Can't increase this heading any more!",
                                vim.log.levels.WARN
                            )
                        end
                    end
                else
                    vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, 1, { '' })
                end
            end
        end
    end
end

--- Pending direction for operator-pending heading changes (used for dot-repeat)
---@type 'increase'|'decrease'|nil
M._pending_direction = nil

--- Operatorfunc callback for `g@`; extracts the range from marks and calls changeHeadingLevel
---@param motion? string The motion type passed by Vim ('v', 'V', '\22' for visual block, or char/line/block)
M._headingOperator = function(motion)
    if not M._pending_direction then
        return
    end

    local start_row, end_row

    -- Check if this is a visual mode operation
    if motion and (motion:match('[vV]') or motion == '\22') then
        -- Visual mode: use '< and '> marks
        -- '\22' is <C-v> (visual block mode)
        start_row = vim.api.nvim_buf_get_mark(0, '<')[1]
        end_row = vim.api.nvim_buf_get_mark(0, '>')[1]
    else
        -- Normal mode with motion: use '[ and '] marks set by g@
        start_row = vim.api.nvim_buf_get_mark(0, '[')[1]
        end_row = vim.api.nvim_buf_get_mark(0, ']')[1]
    end

    M.changeHeadingLevel(M._pending_direction, { line1 = start_row, line2 = end_row })
end

--- Prepare the heading operator for normal mode (sets operatorfunc and returns `g@`)
--- Used with `expr = true` mappings so Vim waits for a motion.
---@param direction 'increase'|'decrease' The heading change direction
---@return string operator_key Always returns `'g@'`
M.setupHeadingOperator = function(direction)
    M._pending_direction = direction
    vim.o.operatorfunc = "v:lua.require'mkdnflow.cursor'._headingOperator"
    return 'g@'
end

--- Handle visual mode heading operator calls with dot-repeat support
--- Uses `g@` with a count-based motion so dot-repeat applies to the same number of lines.
---@param direction 'increase'|'decrease' The heading change direction
M.headingOperatorVisual = function(direction)
    M._pending_direction = direction
    vim.o.operatorfunc = "v:lua.require'mkdnflow.cursor'._headingOperator"
    -- Calculate the number of lines in the visual selection
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    local line_count = end_line - start_line + 1
    -- Go to start of selection and execute g@ with count
    -- Using {count}g@_ operates on {count} lines from cursor (like {count}>>)
    -- The _ motion means "current line" and accepts a count
    vim.cmd('normal! `<' .. line_count .. 'g@_')
end

--- Sentinel value indicating detection-based jumping should be used
local DETECTION_FINDER = function() end

--- Jump to the next link in the buffer (using detection-based jumping)
---@param pattern? string|string[] Unused; detection-based jumping is always used
M.toNextLink = function(pattern)
    M.goTo(DETECTION_FINDER)
end

--- Jump to the previous link in the buffer (using detection-based jumping)
---@param pattern? string|string[] Unused; detection-based jumping is always used
M.toPrevLink = function(pattern)
    M.goTo(DETECTION_FINDER, true)
end

--- Jump to a heading matching the given anchor text, or to the next/previous heading
---@param anchor_text? string The anchor link text to match; if nil, jumps to next/previous heading
---@param reverse? boolean If true, search backward
M.toHeading = function(anchor_text, reverse)
    go_to_heading(anchor_text, reverse)
end

--- Jump to a Pandoc-style bracketed span or heading with a matching ID attribute
---@param id string The ID to search for
---@param starting_row? integer The 1-indexed row to start searching from (defaults to cursor row)
---@return boolean found Whether a matching element was found
M.toId = function(id, starting_row)
    return go_to_id(id, starting_row)
end

--- Yank the current heading (or bracketed span) as a markdown anchor link into a register
---@param full_path? boolean If true, prepend the full buffer path to the anchor (default false)
M.yankAsAnchorLink = function(full_path)
    full_path = full_path or false
    local register = require('mkdnflow').config.cursor.yank_register or '"'
    -- Get the row number and the line contents
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)
    -- See if the line starts with a hash
    local is_heading = string.find(line[1], '^#')
    local links = require('mkdnflow').links
    local is_bracketed_span = links.getBracketedSpanPart()
    if is_heading then
        -- Format the line as an anchor link
        local anchor_link = links.formatLink(line[1])
        anchor_link = anchor_link[1]
        if full_path then
            -- Get the buffer path relative to the resolution base
            local buffer = require('mkdnflow').paths.relativeToBase(vim.api.nvim_buf_get_name(0))
            local left = anchor_link:match('(%b[]%()#')
            local right = anchor_link:match('%b[]%((#.*)$')
            anchor_link = left .. buffer .. right
        end
        vim.fn.setreg(register, anchor_link)
    elseif is_bracketed_span then
        local name = links.getBracketedSpanPart('text')
        local attr = is_bracketed_span
        local anchor_link
        if name and attr then
            if full_path then
                local buffer =
                    require('mkdnflow').paths.relativeToBase(vim.api.nvim_buf_get_name(0))
                anchor_link = '[' .. name .. ']' .. '(' .. buffer .. attr .. ')'
            else
                anchor_link = '[' .. name .. ']' .. '(' .. attr .. ')'
            end
            vim.fn.setreg(register, anchor_link)
        end
    else
        if not require('mkdnflow').config.silent then
            vim.notify(
                '⬇️  The current line is not a heading or bracketed span!',
                vim.log.levels.WARN
            )
        end
    end
end

return M
