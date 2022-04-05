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

-- Function to get line and reverse the string data of the returned object
local rev_get_line = function(buffer, start, end_, strict_indexing)
    local line = vim.api.nvim_buf_get_lines(buffer, start, end_, strict_indexing)
    if line[1] then
        line[1] = string.reverse(line[1])
    end
    return line
end

-- Function to search reversed string & return indices for non-reversed string
local rev_indices = function(r, l, str)
    local right, left = nil, nil
    if r and l then
        right = #str + 1 - r
        left = #str + 1 - l
    end
    return left, right
end

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
                if reverse then
                    -- If we're searching backwards and user wants the search to wrap, go to last line in file
                    if require('mkdnflow').config.wrap_to_end == true then
                        if not already_wrapped then
                            row = vim.api.nvim_buf_line_count(0) + 1
                            already_wrapped = true
                        else
                            unfound = nil
                        end
                    -- Otherwise, search is done
                    else
                        unfound = nil
                    end
                else
                    -- If we're searching forwards and user wants the search to wrap, go to first line in file
                    if require('mkdnflow').config.wrap_to_beginning == true then
                        if not already_wrapped then
                            row = 0
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
end

-- Function to find a heading for the text passed in from an anchor link
-- If no argument is provided, go to the next found heading
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
                    heading_as_anchor = require('mkdnflow.files').formatLink(line[1], 2)
                    if anchor_text == heading_as_anchor then
                        -- If it's a match, send the cursor there and stop the while loop
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
            if row == starting_row then
                unfound = nil
                if anchor_text == nil then
                    print("Couldn't find a heading to go to!")
                else
                    print("Couldn't find a heading matching "..anchor_text.."!")
                end
            end
        else
            -- If the line does not have contents, start searching from the beginning
            if reverse then
                if anchor_link ~= nil or require('mkdnflow').config.wrap_to_beginning == true then
                    row = vim.api.nvim_buf_line_count(0)
                else
                    unfound = nil
                    print("There are no more headings after the beginning of the document!")
                end
            else
                if anchor_link ~= nil or require('mkdnflow').config.wrap_to_end == true then
                    row = 1
                else
                    unfound = nil
                    print("There are no more headings before the end of the document!")
                end
            end
        end
    end
end

-- Find the next link
M.toNextLink = function(pattern)
    -- %b special sequence looks for balanced [ and ) and everything in between them (this was a revelation)
    pattern = pattern or '%b[)'
    go_to(pattern)
end

-- Find the previous link
M.toPrevLink = function(pattern)
    pattern = pattern or '%b)['
    go_to(pattern, true)
end

-- Find a particular heading in the file
M.toHeading = function(anchor_text, reverse)
    go_to_heading(anchor_text, reverse)
end

-- Yank the current line as an anchor link (assumes current line is a heading)
M.yankAsAnchorLink = function()
    -- Get the row number and the line contents
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)
    -- See if the line starts with a hash
    local is_heading = string.find(line[1], '^#')
    if is_heading then
        -- Format the line as an anchor link
        local anchor_link = require('mkdnflow.files').formatLink(line[1])
        -- Add to the unnamed register
        vim.cmd('let @"="'..anchor_link[1]..'"')
    else
        print("The current line is not a heading!")
    end
end

return M
