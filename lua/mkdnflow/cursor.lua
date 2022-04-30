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

-- Modules
local links = require('mkdnflow.links')
local wrap = require('mkdnflow').config.wrap
local silent = require('mkdnflow').config.silent

--[[
rev_get_line() retrieves line text and reverses it
--]]
local rev_get_line = function(buffer, start, end_, strict_indexing)
    local line = vim.api.nvim_buf_get_lines(buffer, start, end_, strict_indexing)
    if line[1] then
        line[1] = string.reverse(line[1])
    end
    return line
end

--[[
rev_indices() takes two indices and a string and returns the equivalent indices
for the reversed string
--]]
local rev_indices = function(r, l, str)
    local right, left = nil, nil
    if r and l then
        right = #str + 1 - r
        left = #str + 1 - l
    end
    return left, right
end

--[[
go_to() sends the cursor to the beginning of the next instance of a pattern. If
'reverse' is 'true', it looks backwards.
--]]
local go_to = function(pattern, reverse)
    -- Get current position of cursor
    local position = vim.api.nvim_win_get_cursor(0)
    local row = position[1]
    local col = position[2]
    local line, rev_col, left, right, left_, right_ = nil
    local already_wrapped = false

    if reverse then
        -- Get the line's contents
        line = rev_get_line(0, row - 1, row, false)
        rev_col = #line[1] - col
        -- Get start & end indices of match (if any)
        right_, left_ = string.find(line[1], pattern)
        left, right = rev_indices(right_, left_, line[1])
    else
        -- Get the line's contents
        line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)
        -- Get start & end indices of match (if any)
        left, right = string.find(line[1], pattern)
    end
    -- As long as a match hasn't been found, keep looking as long as possible!
    local unfound = true
    while unfound do
        -- See if there's a match on the current line.
        if left and right then
            if reverse then
                -- If there is, see if the cursor is before the match
                if rev_col + 1 < right_ then
                    -- If it is, send the cursor to the start of the match
                    vim.api.nvim_win_set_cursor(0, {row, left - 1})
                    unfound = false
                -- If it isn't, search after the end of the previous match.
                else
                    -- These values will be used on the next iteration of the loop.
                    right_, left_ = string.find(line[1], pattern, right_ + 1)
                    left, right = rev_indices(right_, left_, line[1])
                end

            else
                -- If there is, see if the cursor is before the match
                if col + 1 < left then
                    -- If it is, send the cursor to the start of the match
                    vim.api.nvim_win_set_cursor(0, {row, left - 1})
                    unfound = false
                -- If it isn't, search after the end of the previous match.
                else
                    -- These values will be used on the next iteration of the loop.
                    left, right = string.find(line[1], pattern, right)
                end

            end
        -- If there's not a match on the current line, keep checking line-by-line
        else
            -- Update row to search next line
            if reverse then
                row = row - 1
            else
                row = row + 1
            end
            -- Since we're on the next line, column position no longer matters
            -- and we want to make sure that col is always less than left
            if reverse then
                rev_col = -1
            else
                col = -1
            end
            -- Get the content of the next line (if any)
            if reverse then
                line = rev_get_line(0, row - 1, row, false)
            else
                line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)
            end
            -- Check if the line is a real line
            if line[1] then
                -- If it's a real line, search it
                if reverse then
                    right_, left_ = string.find(line[1], pattern)
                    left, right = rev_indices(right_, left_, line[1])
                else
                    left, right = string.find(line[1], pattern)
                end
            else
                -- If the line is nil, there is no next line and the loop should stop (unless wrapping is on)
                -- If we're searching backwards and user wants the search to wrap, go to last line in file
                if wrap == true then
                    if not already_wrapped then
                        if reverse then
                            row = vim.api.nvim_buf_line_count(0) + 1
                        else
                            row = 0
                        end
                        already_wrapped = true
                    else
                        unfound = nil
                    end
                -- Otherwise, search is done
                else
                    unfound = nil
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
    local starting_row = position[1]
    local unfound = true
    local row
    if reverse then
        row = starting_row - 1
    else
        row = starting_row + 1
    end
    while unfound do
        local line
        if reverse then
            line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)
        else
            line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)
        end
        -- If the line has contents, do the thing
        if line[1] then
            -- Does the line start with a hash?
            local has_heading = string.find(line[1], '^#')
            if has_heading then
                if anchor_text == nil then
                    -- Send the cursor to the heading
                    vim.api.nvim_win_set_cursor(0, {row, 0})
                    unfound = false
                else
                    -- Format current heading to see if it matches our search term
                    local heading_as_anchor = links.formatLink(line[1], 2)
                    if anchor_text == heading_as_anchor then
                        -- Set a mark
                        vim.api.nvim_buf_set_mark(0, '`', position[1], position[2], {})
                        -- Send the cursor to the row w/ the matching heading
                        vim.api.nvim_win_set_cursor(0, {row, 0})
                        unfound = false
                    end
                end
            end
            if reverse then
                row = row - 1
            else
                row = row + 1
            end
            if row == starting_row + 1 then
                unfound = nil
                if anchor_text == nil then
                    if not silent then vim.api.nvim_echo({{"⬇️  Couldn't find a heading to go to!", 'WarningMsg'}}, true, {}) end
                else
                    if not silent then vim.api.nvim_echo({{"⬇️  Couldn't find a heading matching "..anchor_text.."!", 'WarningMsg'}}, true, {}) end
                end
            end
        else
            -- If the line does not have contents, start searching from the beginning
            if anchor_text ~= nil or wrap == true then
                if reverse then
                    row = vim.api.nvim_buf_line_count(0)
                else
                    row = 1
                end
            else
                unfound = nil
                local place, preposition
                if reverse then
                    place = 'beginning'; preposition = 'after'
                else
                    place = 'end'; preposition = 'before'
                end
                if not silent then vim.api.nvim_echo({{"⬇️  There are no more headings "..preposition.." the "..place.." of the document!", 'WarningMsg'}}, true, {}) end
            end
        end
    end
end

local M = {}

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
            vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, 0, {'#'})
        else
            -- Remove a hash, but only if there's more than one
            if not string.find(line[1], '^##') then
                if not silent then vim.api.nvim_echo({{"⬇️  Can't increase this heading any more!", 'WarningMsg'}}, true, {}) end
            else
                vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, 1, {''})
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
    -- %b special sequence looks for balanced [ and ) and everything in between them (this was a revelation)
    pattern = pattern or '%b[]%b()'
    go_to(pattern)
end

--[[
toPrevLink() goes to the previous link according to an optional pattern passed
as an argument. If no pattern is passed in, it looks for the default markdown
link pattern.
--]]
M.toPrevLink = function(pattern)
    pattern = pattern or '%b)(%b]['
    -- Leave
    go_to(pattern, true)
end

--[[
toHeading() finds a particular heading in the file
--]]
M.toHeading = function(anchor_text, reverse)
    -- Set mark before leaving
    -- Leave
    go_to_heading(anchor_text, reverse)
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
    if is_heading then
        -- Format the line as an anchor link
        local anchor_link = links.formatLink(line[1])
        anchor_link = string.gsub(anchor_link[1], '"', '\\"')
        if full_path then
            -- Get the full buffer name and insert it before the hash
            local buffer = vim.api.nvim_buf_get_name(0)
            local left = anchor_link:match('(%b[]%()#')
            local right = anchor_link:match('%b[]%((#.*)$')
            anchor_link = left..buffer..right
            vim.cmd('let @"="'..anchor_link..'"')
        else
            -- Add to the unnamed register
            vim.cmd('let @"="'..anchor_link..'"')
        end
    else
        if not silent then vim.api.nvim_echo({{'⬇️  The current line is not a heading!', 'WarningMsg'}}, true, {}) end
    end
end

return M
