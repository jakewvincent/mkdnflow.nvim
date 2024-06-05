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

-- Modules and config options
local links = require('mkdnflow').links
local wrap = require('mkdnflow').config.wrap
local silent = require('mkdnflow').config.silent
local context = require('mkdnflow').config.links.context
local jump_patterns = require('mkdnflow').config.cursor.jump_patterns
local utils = require('mkdnflow').utils

--[[
find_patterns() is like a more complex version of string.find that accepts a list of patterns to
search for and permits reverse searches.
--]]
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

local M = {}

--[[
goTo() sends the cursor to the beginning of the next instance of a pattern or a list of patterns.
If 'reverse' is 'true', it will go to the previous instance of the pattern.
--]]
M.goTo = function(pattern, reverse)
    -- Get current position of cursor
    local position = vim.api.nvim_win_get_cursor(0)
    local row, col = position[1], position[2]
    local line, line_len, left, right
    local already_wrapped = false

    -- Get the line's contents
    line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    line_len = #line
    if context > 0 and line_len > 0 then
        for i = 1, context, 1 do
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
                -- These values will be used on the next iteration of the loop.
                left, right = find_patterns(line, pattern, reverse, reverse and left or right)
            end
        else -- If there's not a match on the current line, keep checking line-by-line
            -- Update row to search next line
            row = (reverse and row - 1) or row + 1
            -- Get the content of the next line (if any), appending contextual lines if context > 0
            line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
            line_len = line and #line
            -- Since we're on the next line, cursor position no longer matters and we want to make
            -- sure that `col` is always < left (or > if reverse == true)
            col = reverse and line_len or -1
            if line and context > 0 and line_len > 0 then
                for i = 1, context, 1 do
                    local following_line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
                    line = (following_line and line .. following_line) or line
                end
            end
            if line then -- If it's a real line, search it
                left, right = find_patterns(line, pattern, reverse)
            else
                -- If the line is nil, there is no next line and the loop should stop (unless wrapping is on)
                if wrap == true then -- If searching backwards & user wants search to wrap, go to last line in file
                    if not already_wrapped then
                        row = (reverse and vim.api.nvim_buf_line_count(0) + 1) or 0
                        already_wrapped = true
                    else
                        continue = nil
                    end
                else -- Otherwise, search is done
                    continue = nil
                end
            end
        end
    end
end

--[[
go_to_heading() finds a heading for the text passed in from an anchor link. If
no argument is provided, it goes to the next heading it can find, if possible.
--]]
local go_to_heading = function(anchor_text, reverse)
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
                    vim.api.nvim_win_set_cursor(0, { row, 0 })
                    continue = false
                else
                    -- Format current heading to see if it matches our search term
                    local heading_as_anchor = links.formatLink(line[1], nil, 2)
                    if anchor_text == heading_as_anchor then
                        -- Set a mark
                        vim.api.nvim_buf_set_mark(0, '`', position[1], position[2], {})
                        -- Send the cursor to the row w/ the matching heading
                        vim.api.nvim_win_set_cursor(0, { row, 0 })
                        continue = false
                    end
                end
            end
            row = (reverse and row - 1) or row + 1
            if row == starting_row + 1 then
                continue = nil
                if anchor_text == nil then
                    local message = "⬇️  Couldn't find a heading to go to!"
                    if not silent then
                        vim.api.nvim_echo({ { message, 'WarningMsg' } }, true, {})
                    end
                else
                    local message = "⬇️  Couldn't find a heading matching "
                        .. anchor_text
                        .. '!'
                    if not silent then
                        vim.api.nvim_echo({ { message, 'WarningMsg' } }, true, {})
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
                local message = '⬇️  There are no more headings '
                    .. preposition
                    .. ' the '
                    .. place
                    .. ' of the document!'
                if not silent then
                    vim.api.nvim_echo({ { message, 'WarningMsg' } }, true, {})
                end
            end
        end
    end
end

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
            if substring:match('{[^%}]*' .. utils.luaEscape(id) .. '[^%}]*}') then
                continue = false
            else
                local continue_line = true
                while continue_line do
                    start, finish = line:find('%b[]%b{}', finish)
                    if start then
                        substring = string.sub(line, start, finish)
                        if substring:match('{[^%}]*' .. utils.luaEscape(id) .. '[^%}]*}') then
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

--[[
changeHeadingLevel() changes the importance of a heading by adding or removing
a hash symbol. Fewer hashes = more important.
--]]
M.changeHeadingLevel = function(change)
    -- Get the row number and the line contents
    local row = vim.api.nvim_win_get_cursor(0)[1]
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
                local message = "⬇️  Can't increase this heading any more!"
                if not silent then
                    vim.api.nvim_echo({ { message, 'WarningMsg' } }, true, {})
                end
            else
                vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, 1, { '' })
            end
        end
    end
end

--[[
toNextLink() goes to the next link according to an optional pattern passed as an
argument. If no pattern is passed in, it looks for the default markdown link
pattern.
--]]
M.toNextLink = function(pattern)
    M.goTo(jump_patterns)
end

--[[
toPrevLink() goes to the previous link according to an optional pattern passed
as an argument. If no pattern is passed in, it looks for the default markdown
link pattern.
--]]
M.toPrevLink = function(pattern)
    M.goTo(jump_patterns, true)
end

--[[
toHeading() finds a particular heading in the file
--]]
M.toHeading = function(anchor_text, reverse)
    go_to_heading(anchor_text, reverse)
end

M.toId = function(id, starting_row)
    return go_to_id(id, starting_row)
end

--[[
yankAsAnchorLink() takes the current line, converts it into an anchor link int-
ernally, an adds the link to the register, effectively yanking the heading as
an anchor link. Assumes current line is a heading.
--]]
M.yankAsAnchorLink = function(full_path)
    full_path = full_path or false
    -- Get the row number and the line contents
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)
    -- See if the line starts with a hash
    local is_heading = string.find(line[1], '^#')
    local is_bracketed_span = links.getBracketedSpanPart()
    if is_heading then
        -- Format the line as an anchor link
        local anchor_link = links.formatLink(line[1])
        anchor_link = string.gsub(anchor_link[1], '"', '\\"')
        if full_path then
            -- Get the full buffer name and insert it before the hash
            local buffer = vim.api.nvim_buf_get_name(0)
            local left = anchor_link:match('(%b[]%()#')
            local right = anchor_link:match('%b[]%((#.*)$')
            anchor_link = left .. buffer .. right
            vim.cmd('let @"="' .. anchor_link .. '"')
        else
            -- Add to the unnamed register
            vim.cmd('let @"="' .. anchor_link .. '"')
        end
    elseif is_bracketed_span then
        local name = links.getBracketedSpanPart('text')
        local attr = is_bracketed_span
        local anchor_link
        if name and attr then
            if full_path then
                local buffer = vim.api.nvim_buf_get_name(0)
                anchor_link = '[' .. name .. ']' .. '(' .. buffer .. attr .. ')'
            else
                anchor_link = '[' .. name .. ']' .. '(' .. attr .. ')'
            end
            vim.cmd('let @"="' .. anchor_link .. '"')
        end
    else
        local message = '⬇️  The current line is not a heading or bracketed span!'
        if not silent then
            vim.api.nvim_echo({ { message, 'WarningMsg' } }, true, {})
        end
    end
end

return M
