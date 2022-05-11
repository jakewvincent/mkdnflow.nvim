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
local to_do_update_parents = require('mkdnflow').config.to_do.update_parents
local to_do_not_started = require('mkdnflow').config.to_do.not_started
local to_do_in_progress = require('mkdnflow').config.to_do.in_progress
local to_do_complete = require('mkdnflow').config.to_do.complete

local update_numbering = function(row, starting_number)
    local next_line = vim.api.nvim_buf_get_lines(0, row + 1, row + 2, false)
    local is_numbered
    if next_line[1] then
        is_numbered = next_line[1]:match('^(%s*%d+%.%s*).-')
    end
    while is_numbered do
        -- Replace the number on whichever line
        --local item_number = is_numbered:match('^%s*(%d*)%.')
        local item_number = starting_number + 1
        local spacing = next_line[1]:match('^(%s*)%d')
        local new_line = next_line[1]:gsub('^%s*%d+', spacing..item_number)
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

local get_status = function(line)
    local todo = nil
    if line then
        for _, v in ipairs(to_do_symbols) do
            v = escape_lua_chars(v)
            local pattern = "^%s*[*-]%s+%["..v.."%]%s+"
            local match = string.match(line, pattern, nil)
            if match then todo = v end
        end
    end
    return(todo)
end

local same_siblings = function(indentation, row, status)
    -- Find the siblings of this to-do
    local start = row - 1
    local done_looking = nil
    local sib_statuses = {}
    while not done_looking and start >= 0 do
        local prev_line = vim.api.nvim_buf_get_lines(0, start, start + 1, false)
        local has_status = get_status(prev_line[1])
        if has_status then
            local sib_indentation = prev_line[1]:match('(%s*)[-*]')
            if #sib_indentation == #indentation then
                table.insert(sib_statuses, has_status)
                start = start - 1
            -- If more nested, keep looking above for to-dos w/ same indentation
            elseif #sib_indentation > #indentation then
                start = start - 1
            else
                done_looking = true
            end
        else
            done_looking = true
        end
    end
    -- Now look below the current line
    done_looking = false
    start = row + 1
    while not done_looking do
        local next_line = vim.api.nvim_buf_get_lines(0, start, start + 1, false)
        local has_status = get_status(next_line[1])
        if has_status then
            local sib_indentation = next_line[1]:match('(%s*)[-*]')
            if #sib_indentation == #indentation then
                table.insert(sib_statuses, has_status)
                start = start + 1
            -- If nested, keep looking below for to-dos w/ same indentation
            elseif #sib_indentation > #indentation then
                start = start + 1
            else
                done_looking = true
            end
        else
            done_looking = true
        end
    end
    if #sib_statuses == 0 then
        return(true)
    else
        local all_done = true
        local i = 1
        done_looking = false
        while not done_looking do
            if escape_lua_chars(sib_statuses[i]) ~= status then
                done_looking = true
                all_done = false
            elseif i == #sib_statuses then
                done_looking = true
            else
                i = i + 1
            end
        end
        return(all_done)
    end
end

local M = {}

M.toggleToDo = function() end
local update_parent_to_do = function() end

update_parent_to_do = function(line, row, symbol)
    -- See if there's any whitespace before the bullet
    local is_indented = line:match('(%s+)[-*]')
    -- If the current to-do is indented, it may have a parent to-do
    if is_indented then
        local start = row - 2
        local parent = nil
        -- While a parent hasn't been found and start is at least the first line, keep
        -- looking for a parent
        while not parent and start >= 0 do
            local prev_line = vim.api.nvim_buf_get_lines(0, start, start + 1, false)
            -- See if it's a to-do, and if so, what its indentation is
            -- If there's a to-do on the prev line, see if it's less indented
            local has_to_do = get_status(prev_line[1])
            if has_to_do then
                local indentation = prev_line[1]:match('(%s*)[-*]')
                parent = #indentation < #is_indented
            else
                parent = nil
            end
            -- If it's a parent (= less indented), update it appropriately
            if parent then
                -- Update parent to in-progress
                if has_to_do == escape_lua_chars(to_do_not_started) then
                    if symbol == to_do_in_progress then
                        M.toggleToDo(start + 1, to_do_in_progress)
                    elseif symbol == escape_lua_chars(to_do_complete) then
                        if same_siblings(is_indented, row - 1, symbol) then
                            M.toggleToDo(start + 1, to_do_complete)
                        else
                            M.toggleToDo(start + 1, to_do_in_progress)
                        end
                    elseif symbol == escape_lua_chars(to_do_not_started) then
                        if same_siblings(is_indented, row - 1, symbol) then
                            M.toggleToDo(start + 1, to_do_not_started)
                        end
                    end
                elseif has_to_do == escape_lua_chars(to_do_in_progress) then
                    if symbol == to_do_complete then
                        if same_siblings(is_indented, row - 1, symbol) then
                            M.toggleToDo(start + 1, to_do_complete)
                        end
                    elseif symbol == to_do_not_started then
                        if same_siblings(is_indented, row - 1, symbol) then
                            M.toggleToDo(start + 1, to_do_not_started)
                        end
                    end
                elseif has_to_do == escape_lua_chars(to_do_complete) then
                    if symbol == to_do_complete then
                        if not same_siblings(is_indented, row - 1, symbol) then
                            M.toggleToDo(start + 1, to_do_in_progress)
                        end
                    elseif symbol == to_do_in_progress then
                        M.toggleToDo(start + 1, to_do_in_progress)
                    elseif symbol == to_do_not_started then
                        if same_siblings(is_indented, row - 1, symbol) then
                            M.toggleToDo(start + 1, to_do_not_started)
                        else
                            M.toggleToDo(start + 1, to_do_in_progress)
                        end
                    end
                end
            else
                -- On the next pass, look at the line above the current one
                start = start - 1
            end
        end
    end
end

--[[
toggleToDo() retrieves a line when called, checks if it has a to-do item with
[ ], [-], or [X], and changes the completion status to the next in line.
--]]
M.toggleToDo = function(row, status)
    -- Get the line the cursor is on or of the row that was provided
    local position = vim.api.nvim_win_get_cursor(0)
    row = row or position[1]
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    -- See if pattern is matched
    local todo = get_status(line)
    local get_index = function(symbol)
        for i, v in ipairs(to_do_symbols) do
            if symbol == escape_lua_chars(v) then
                return i
            end
        end
    end
    -- If it is, do the replacement with the next completion status
    if todo then
        local new_symbol
        if status then
            new_symbol = status
        else
            local index = get_index(todo)
            local next_index
            if index == #to_do_symbols then
                next_index = 1
            else
                next_index = index + 1
            end
            new_symbol = to_do_symbols[next_index]
        end
        local com, fin = string.find(line, '%['..todo..'%]')
        vim.api.nvim_buf_set_text(0, row - 1, com, row - 1, fin - 1, {new_symbol})
        -- Update parent to-dos (if any)
        if to_do_update_parents then update_parent_to_do(line, row, new_symbol) end
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
    -- Any whitespace, a digit+period, whitespace, non-whitespace character
    local match = line:match('^%s*%d+%.%s*[^%s]')
    -- All the stuff before the non-whitespace character
    local partial_match = line:match('^(%s*%d+%.%s*).-')
    -- If this is an ordered list item with no contents, remove the item
    if partial_match and not match then
        local row = vim.api.nvim_win_get_cursor(0)[1]
        vim.api.nvim_buf_set_lines(0, row - 1, row, false, {''})
        vim.api.nvim_win_set_cursor(0, {row, 0})
        -- Update numbering
        update_numbering(row - 1, '0')
    -- If it's an ordered list item *with* contents, make a new list item
    elseif match then
        local position = vim.api.nvim_win_get_cursor(0)
        local row, col = position[1], position[2]
        local item_number = match:match('^%s*(%d*)%.')
        item_number = item_number + 1
        local next_number = partial_match:gsub('%d+', item_number)
        local next_line = next_number
        -- If the cursor is not at the end of the line, append the stuff follo-
        -- wing the cursor to the new line
        if col ~= #line then
            next_line = next_number..line:sub(col + 1, #line)
            vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, #line, {''})
        end
        vim.api.nvim_buf_set_lines(0, row, row, false, {next_line})
        vim.api.nvim_win_set_cursor(0, {row + 1, (#next_number)})
        -- Update numbering
        update_numbering(row, item_number)
    else
        -- Then look for a to-do item
        match = line:match('^%s*[*-]%s+%[.%]%s+[^%s]+')
        partial_match = line:match('^(%s*[-*]%s+%[.%]%s).-')
        if partial_match and not match then
            local row = vim.api.nvim_win_get_cursor(0)[1]
            local subpartial_match = partial_match:match('^(%s*[-*]%s+)')
            vim.api.nvim_buf_set_lines(0, row - 1, row, false, {subpartial_match})
            vim.api.nvim_win_set_cursor(0, {row, #subpartial_match})
        elseif match then
            local position = vim.api.nvim_win_get_cursor(0)
            local row, col = position[1], position[2]
            local subpartial_match = line:match('^(%s*[-*]%s+%[.%]%s).-')
            subpartial_match = subpartial_match:gsub('%[.%]', '[ ]')
            local next_line = subpartial_match
            if col ~= #line then
                next_line = subpartial_match..line:sub(col + 1, #line)
                vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, #line, {''})
            end
            vim.api.nvim_buf_set_lines(0, row, row, false, {next_line})
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
                local position = vim.api.nvim_win_get_cursor(0)
                local row, col = position[1], position[2]
                local next_line = partial_match
                if col ~= #line then
                    next_line = partial_match..line:sub(col + 1, #line)
                    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, #line, {''})
                end
                vim.api.nvim_buf_set_lines(0, row, row, false, {next_line})
                vim.api.nvim_win_set_cursor(0, {row + 1, (#partial_match)})
            else
                -- If the above criteria are not met, just do a normal CR
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), 'n', true)
            end
        end
    end
end

return M
