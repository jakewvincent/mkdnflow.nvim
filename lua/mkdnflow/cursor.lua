-- mkdnflow.nvim (Tools for personal markdown notebook navigation and management)
-- Copyright (C) 2021 Jake W. Vincent <https://github.com/jakewvincent>
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
                -- If the line is nil, there is no next line and the loop should stop
                unfound = nil
            end
        end
    end
end

-- Find the next link
M.toNextLink = function()
    local pattern = '%[.-%]%(.-%)'
    go_to(pattern)
end

-- Find the previous link
M.toPrevLink = function()
    local pattern = '%).-%(%].-%['
    go_to(pattern, true)
end

return M
