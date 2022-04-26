-- mkdnflow.nvim (Tools for fluent markdown notebook navigation and management)
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

-- This module: To-do list related functions
local silent = require('mkdnflow').config.silent
local M = {}

--[[
toggleToDo() retrieves a line when called, checks if it has a to-do item with
[ ], [-], or [X], and changes the completion status to the next in line.
--]]
M.toggleToDo = function()
    -- Get the line the cursor is on
    local line = vim.api.nvim_get_current_line()
    local position = vim.api.nvim_win_get_cursor(0)
    local row = position[1]
    -- See if pattern is matched
    local pattern = '^%s*[*-]%s+%[([ -X])%]%s+'
    local todo = string.match(line, pattern, nil)
    -- If it is, do the replacement with the next completion status
    if todo then
        if todo == ' ' then
            local com, fin = string.find(line, '%['..' '..'%]')
            vim.api.nvim_buf_set_text(0, row - 1, com, row - 1, fin - 1, {'-'})
        elseif todo == '-' then
            local com, fin = string.find(line, '%['..'%-'..'%]')
            vim.api.nvim_buf_set_text(0, row - 1, com, row - 1, fin - 1, {'X'})
        elseif todo == 'X' then
            local com, fin = string.find(line, '%['..'X'..'%]')
            vim.api.nvim_buf_set_text(0, row - 1, com, row - 1, fin - 1, {' '})
        end
    else
        if not silent then vim.api.nvim_echo({{'⬇️  Not a to-do list item!', 'WarningMsg'}}, true, {}) end
    end
end

M.newListItem = function()
    -- Get line
    local line = vim.api.nvim_get_current_line()
    -- See if there's a list item on it
    -- Look for an ordered list item first
    local match = line:match('^%s*%d+%.%s*[^%s]')
    local partial_match = line:match('^(%s*%d+%.%s*).-')
    if partial_match and not match then
        local row = vim.api.nvim_win_get_cursor(0)[1]
        vim.api.nvim_buf_set_lines(0, row - 1, row, false, {''})
        vim.api.nvim_win_set_cursor(0, {row, 0})
    elseif match then
        local row = vim.api.nvim_win_get_cursor(0)[1]
        local item_number = match:match('^%s*(%d*)%.')
        item_number = item_number + 1
        local new_line = partial_match:gsub('%d+', item_number)
        vim.api.nvim_buf_set_lines(0, row, row, false, {new_line})
        vim.api.nvim_win_set_cursor(0, {row + 1, (#new_line)})
    else
        -- Then look for unordered list
        match = line:match('^%s*[-*]%s*[^%s]')
        partial_match = line:match('^(%s*[-*]%s*).-')
        -- If there's no content on the line other than the bullet, remove the list item
        if partial_match and not match then
            local row = vim.api.nvim_win_get_cursor(0)[1]
            vim.api.nvim_buf_set_lines(0, row - 1, row, false, {''})
            vim.api.nvim_win_set_cursor(0, {row, 0})
        elseif match then
            --vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), 'n', true)
            local row = vim.api.nvim_win_get_cursor(0)[1]
            vim.api.nvim_buf_set_lines(0, row, row, false, {partial_match})
            vim.api.nvim_win_set_cursor(0, {row + 1, (#partial_match)})
        else
            print("Found nothing noteworthy!")
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), 'n', true)
        end
    end
end

return M
