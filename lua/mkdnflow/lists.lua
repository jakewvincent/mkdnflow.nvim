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
local to_do_symbols = require('mkdnflow').config.to_do.symbols
local to_do_in_progress = require('mkdnflow').config.to_do.in_progress

local update_numbering = function(row, starting_number)
    local next_line = vim.api.nvim_buf_get_lines(0, row + 1, row + 2, false)
    local is_numbered = next_line[1]:match('^(%s*%d+%.%s*).-')
    while is_numbered do
        -- Replace the number on whichever line
        --local item_number = is_numbered:match('^%s*(%d*)%.')
        local item_number = starting_number + 1
        local spacing = next_line[1]:match('^(%s*)%d')
        local new_line = next_line[1]:gsub(spacing..'%d+', item_number)
        vim.api.nvim_buf_set_lines(0, row + 1, row + 2, false, {new_line})
        -- Then retrieve the next line
        row = row + 1
        next_line = vim.api.nvim_buf_get_lines(0, row + 1, row + 2, false)
        is_numbered = next_line[1]:match('^(%s*%d+%.%s*).-')
        starting_number = item_number
    end
end

--[[
escape_lua_chars() escapes the set of characters in 'chars' with the mappings
provided in 'replacements'. For Lua escapes.
--]]
local escape_lua_chars = function(string)
    -- Which characters to match
    local chars = "[-.'\"a]"
    -- Set up table of replacements
    local replacements = {
        ["-"] = "%-",
        ["."] = "%.",
        ["'"] = "\'",
        ['"'] = '\"'
    }
    -- Do the replacement
    local escaped = string.gsub(string, chars, replacements)
    -- Return the new string
    return(escaped)
end

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
    local todo
    for _, v in ipairs(to_do_symbols) do
        local pattern = "^%s*[*-]%s+%["..v.."%]%s+"
        local match = string.match(line, pattern, nil)
        if match then todo = v end
    end
    local get_index = function(symbol)
        for i, v in ipairs(to_do_symbols) do
            if symbol == v then
                return i
            end
        end
    end
    -- If it is, do the replacement with the next completion status
    if todo then
        local index = get_index(todo)
        local next_index
        if index == #to_do_symbols then
            next_index = 1
        else
            next_index = index + 1
        end
        local new_symbol = to_do_symbols[next_index]
        local com, fin = string.find(line, '%['..escape_lua_chars(todo)..'%]')
        vim.api.nvim_buf_set_text(0, row - 1, com, row - 1, fin - 1, {new_symbol})
    else
        local message = '⬇️  Not a to-do list item!'
        if not silent then vim.api.nvim_echo({{message, 'WarningMsg'}}, true, {}) end
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
        -- Update numbering
        update_numbering(row - 1, '0')
    elseif match then
        local row = vim.api.nvim_win_get_cursor(0)[1]
        local item_number = match:match('^%s*(%d*)%.')
        item_number = item_number + 1
        local new_line = partial_match:gsub('%d+', item_number)
        vim.api.nvim_buf_set_lines(0, row, row, false, {new_line})
        vim.api.nvim_win_set_cursor(0, {row + 1, (#new_line)})
        -- Update numbering
        update_numbering(row, item_number)
    else
        -- Then look for a to-do item
        match = line:match('^%s*[*-]%s+%[[ -X]%]%s+[^%s]+')
        partial_match = line:match('^(%s*[-*]%s+%[.%]%s).-')
        if partial_match and not match then
            local row = vim.api.nvim_win_get_cursor(0)[1]
            local subpartial_match = partial_match:match('^(%s*[-*]%s+)')
            vim.api.nvim_buf_set_lines(0, row - 1, row, false, {subpartial_match})
            vim.api.nvim_win_set_cursor(0, {row, #subpartial_match})
        elseif match then
            local row = vim.api.nvim_win_get_cursor(0)[1]
            local subpartial_match = line:match('^(%s*[-*]%s+%[.%]%s).-')
            subpartial_match = subpartial_match:gsub('%[.%]', '[ ]')
            vim.api.nvim_buf_set_lines(0, row, row, false, {subpartial_match})
            vim.api.nvim_win_set_cursor(0, {row + 1, (#subpartial_match)})
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
                -- If the above criteria are not met, just do a normal CR
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), 'n', true)
            end
        end
    end
end

return M
