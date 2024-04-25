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
local utils = require('mkdnflow').utils
local silent = require('mkdnflow').config.silent
local to_do_symbols = require('mkdnflow').config.to_do.symbols
local to_do_update_parents = require('mkdnflow').config.to_do.update_parents
local to_do_not_started = require('mkdnflow').config.to_do.not_started
local to_do_in_progress = require('mkdnflow').config.to_do.in_progress
local to_do_complete = require('mkdnflow').config.to_do.complete
local vim_indent
if vim.api.nvim_buf_get_option(0, 'expandtab') == true then
    vim_indent = string.rep(' ', vim.api.nvim_buf_get_option(0, 'shiftwidth'))
else
    vim_indent = '\t'
end

local M = {}

M.patterns = {
    ultd = { -- allow up to 4 bytes in the to-do checkbox
        li_type = 'ultd',
        main = '^%s*[+*-]%s+%[..?.?.?%]%s+',
        indentation = '^(%s*)[+*-]%s+%[..?.?.?%]',
        marker = '^%s*([+*-]%s+)%[..?.?.?%]%s+',
        content = '^%s*[+*-]%s+%[..?.?.?%]%s+(.+)',
        demotion = '^%s*[+*-]%s+',
        empty = '^%s*[+*-]%s+%[..?.?.?%]%s+$',
    },
    oltd = { -- allow up to 4 bytes in the to-do checkbox
        li_type = 'oltd',
        main = '^%s*%d+%.%s+%[..?.?.?%]%s+',
        indentation = '^(%s*)%d+%.%s+',
        marker = '^%s*%d+(%.%s+)%[..?.?.?%]%s+',
        number = '^%s*(%d+)%.',
        content = '^%s*%d+%.%s+%[..?.?.?%]%s+(.+)',
        demotion = '^%s*%d+%.%s+',
        empty = '^%s*%d+%.%s+%[..?.?.?%]%s+$',
    },
    ul = {
        li_type = 'ul',
        main = '^%s*[-*+]%s+',
        indentation = '^(%s*)[-*+]%s+',
        marker = '^%s*([-*+]%s+)',
        pre = '^%s*[-*+]',
        content = '^%s*[-*+]%s+(.+)',
        demotion = '^%s*',
        empty = '^%s*[-*+]%s+$',
    },
    ol = {
        li_type = 'ol',
        main = '^%s*%d+%.%s+',
        indentation = '^(%s*)%d+%.',
        marker = '^%s*%d+(%.%s+)',
        pre = '^%s*%d+%.',
        number = '^%s*(%d+)%.',
        content = '^%s*%d+%.%s+(.+)',
        demotion = '^%s*',
        empty = '^%s*%d+%.%s+$',
    },
}

M.hasListType = function(line)
    local match
    local i = 1
    local li_types = { 'ultd', 'oltd', 'ul', 'ol' }
    local result
    local indentation
    if line == nil then
        local row = vim.api.nvim_win_get_cursor(0)[1]
        line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    end
    while not match and i <= 4 do
        local li_type = li_types[i]
        match = string.match(line, M.patterns[li_type].main)
        if match then
            result = li_type
            indentation = line:match(M.patterns[li_type].indentation)
        else
            i = i + 1
        end
    end
    return result, indentation
end

local get_siblings = function(row, indentation, li_type, up)
    up = up and true
    local orig_row = row
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    local number = M.patterns[li_type].number and line and line:match(M.patterns[li_type].number)
    local sibling_linenrs = {} -- Store line numbers of sibling list items
    local list_numbers = {} -- Store numbers of sibling list items
    if number then
        list_numbers = { number }
    end
    sibling_linenrs = { row }
    -- Look up till we find a parent or non-list-item
    local done = false
    local list_pos = 1
    local inc = up and -1 or 1
    while not done do
        local adj_line = ((up and row - 2 >= 0) and vim.api.nvim_buf_get_lines(0, row - 2, row - 1, true)[1])
            or (up == false and vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]) or nil
        if adj_line then
            local adj_li_type = M.hasListType(adj_line)
            if adj_li_type then
                local adj_indentation = string.match(adj_line, M.patterns[adj_li_type].indentation)
                    or nil
                if adj_li_type == li_type and adj_indentation == indentation then -- Add row
                    if number then
                        table.insert(
                            list_numbers,
                            up and list_pos or #list_numbers + 1,
                            adj_line:match(M.patterns[li_type].number)
                        )
                    end
                    table.insert(sibling_linenrs, up and list_pos or #sibling_linenrs + 1, row + inc)
                    row = row + inc
                elseif #adj_indentation > #indentation then -- List item is a child; keep looking
                    row = row + inc
                else
                    if up then -- Look downwards on the next iteration
                        up, row, inc = false, orig_row, 1
                    else -- Row is not a list item or indentation is lesser than original row
                        done = true
                    end
                end
            else
                if up then -- Look downwards on the next iteration
                    up, row, inc = false, orig_row, 1
                else -- Row is not a list item
                    done = true
                end
            end
        else -- Found no adjacent line
            if up then -- Look downwards on the next iteration
                up, row, inc = false, orig_row, 1
            else -- Row doesn't exist
                done = true
            end
        end
    end
    return sibling_linenrs, list_numbers
end

local update_numbering = function(row, indentation, li_type, up, start)
    local sibling_linenrs, list_numbers = get_siblings(row, indentation, li_type, up)
    local n = start
    for i, v in ipairs(list_numbers) do
        if not n then
            n = tonumber(v) + 1
        else
            if tonumber(v) ~= n then
                -- Replace with the correct number on that line
                local line = vim.api.nvim_buf_get_lines(0, sibling_linenrs[i] - 1, sibling_linenrs[i], false)[1]
                local replacement =
                    line:gsub('^' .. indentation .. '%d+%.', indentation .. n .. '.')
                vim.api.nvim_buf_set_lines(0, sibling_linenrs[i] - 1, sibling_linenrs[i], false, { replacement })
            end
            n = n + 1
        end
    end
end

local get_status = function(line)
    local todo = nil
    if line then
        for _, v in ipairs(to_do_symbols) do
            v = utils.luaEscape(v)
            local ul = '^%s*[+*-]%s+%[' .. v .. '%]%s+'
            local ol = '^%s*%d+%.%s+%[' .. v .. '%]%s+'
            local match = line:match(ul, nil) or line:match(ol, nil)
            if match then
                todo = v
            end
        end
    end
    return todo
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
            local sib_indentation = prev_line[1]:match('(%s*)[-*+%d]+%.*')
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
            local sib_indentation = next_line[1]:match('(%s*)[-*+%d]+%.*')
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
        return true
    else
        local all_done = true
        local i = 1
        done_looking = false
        while not done_looking do
            if utils.luaEscape(sib_statuses[i]) ~= status then
                done_looking = true
                all_done = false
            elseif i == #sib_statuses then
                done_looking = true
            else
                i = i + 1
            end
        end
        return all_done
    end
end

-- Initialize the names for these two functions
M.toggleToDo = function() end
local update_parent_to_do = function() end

update_parent_to_do = function(line, row, symbol)
    -- See if there's any whitespace before the bullet
    local is_indented = line:match('^(%s+)[-*+%d]+%.*')
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
                local indentation = prev_line[1]:match('^(%s*)[-*+%d]+%.*')
                parent = #indentation < #is_indented
            else
                parent = nil
            end
            -- If it's a parent (= less indented), update it appropriately
            if parent then
                -- Update parent to in-progress
                if has_to_do == utils.luaEscape(to_do_not_started) then
                    if symbol == to_do_in_progress then
                        M.toggleToDo(start + 1, to_do_in_progress)
                    elseif symbol == utils.luaEscape(to_do_complete) then
                        if same_siblings(is_indented, row - 1, symbol) then
                            M.toggleToDo(start + 1, to_do_complete)
                        else
                            M.toggleToDo(start + 1, to_do_in_progress)
                        end
                    elseif symbol == utils.luaEscape(to_do_not_started) then
                        if same_siblings(is_indented, row - 1, symbol) then
                            M.toggleToDo(start + 1, to_do_not_started)
                        end
                    end
                elseif has_to_do == utils.luaEscape(to_do_in_progress) then
                    if symbol == to_do_complete then
                        if same_siblings(is_indented, row - 1, symbol) then
                            M.toggleToDo(start + 1, to_do_complete)
                        end
                    elseif symbol == to_do_not_started then
                        if same_siblings(is_indented, row - 1, symbol) then
                            M.toggleToDo(start + 1, to_do_not_started)
                        end
                    end
                elseif has_to_do == utils.luaEscape(to_do_complete) then
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
M.toggleToDo = function(row, status, meta)
    -- Run considering the mode
    if meta then
        local mode = vim.api.nvim_get_mode()['mode']
        if mode == 'v' then
            local pos_a, pos_b = vim.fn.getpos('v')[2], vim.api.nvim_win_get_cursor(0)[1]
            local first, last =
                (pos_a < pos_b and pos_a) or pos_b, (pos_b > pos_a and pos_b) or pos_a
            if first == 0 or last == 0 then
                M.toggleToDo()
            else
                for line = first, last do
                    M.toggleToDo(line, status, false)
                end
            end
        elseif string.lower(mode):match('v') then
            if not silent then
                vim.api.nvim_echo(
                    { { '⬇️  Use simple visual mode (not line/block)', 'WarningMsg' } },
                    true,
                    {}
                )
            end
        else
            M.toggleToDo()
        end
    else
        -- Get the line the cursor is on or of the row that was provided
        --local position = vim.api.nvim_win_get_cursor(0)
        row = row or vim.api.nvim_win_get_cursor(0)[1]
        local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
        -- See if pattern is matched
        local todo = get_status(line)
        local get_index = function(symbol)
            for i, v in ipairs(to_do_symbols) do
                if symbol == utils.luaEscape(v) then
                    return i
                end
            end
        end
        -- If it is, do the replacement with the next completion status
        local li_type = M.hasListType(line)
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
            local first, last = string.find(line, '%[' .. todo .. '%]')
            vim.api.nvim_buf_set_text(0, row - 1, first, row - 1, last - 1, { new_symbol })
            -- Update parent to-dos (if any)
            if to_do_update_parents then
                update_parent_to_do(line, row, new_symbol)
            end
        elseif li_type == 'ul' or li_type == 'ol' then -- Convert into a to-do list item if current line is a list item
            local first, last = string.find(line, M.patterns[li_type].pre)
            vim.api.nvim_buf_set_text(
                0,
                row - 1,
                last,
                row - 1,
                last,
                { ' [' .. to_do_not_started .. ']' }
            )
            if to_do_update_parents then
                local new_todo_indent = line:match('^(%s*)[^%s]')
                local next_line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
                if next_line then
                    local next_li_type = M.hasListType(next_line)
                    if next_li_type == 'ultd' or next_li_type == 'oltd' then
                        local next_todo_indent = next_line:match('^(%s*)[^%s]')
                        if string.len(next_todo_indent) > string.len(new_todo_indent) then
                            -- Get the status of the to-do on the next line
                            local next_symbol = get_status(next_line)
                            -- Update the (new) parent
                            update_parent_to_do(next_line, row + 1, next_symbol)
                        end
                    end
                end
            end
        else
            -- If no to-do is found, insert one
            vim.api.nvim_buf_set_text(
                0,
                row - 1,
                0,
                row - 1,
                0,
                { '- [' .. to_do_not_started .. '] ' }
            )
        end
    end
end

M.newListItem = function(carry, above, cursor_moves, mode_after, alt, line)
    carry = (carry == nil and true) or (carry ~= nil and carry)
    above = above and true
    local current_mode = vim.api.nvim_get_mode()['mode']
    mode_after = mode_after or current_mode
    if mode_after ~= 'i' and mode_after ~= 'n' then
        mode_after = 'i'
    end
    -- Get the line and list type
    line = line or vim.api.nvim_get_current_line()
    local li_type = M.hasListType(line)
    if li_type then -- If the line has an item, do some stuff
        local has_contents = carry == false or string.match(line, M.patterns[li_type].content)
        local row, col = vim.api.nvim_win_get_cursor(0)[1], vim.api.nvim_win_get_cursor(0)[2]
        row = (above and row - 1) or row
        local indentation = string.match(line, M.patterns[li_type].indentation)
        if has_contents then
            local next_line = indentation
            local next_number
            if (not above) and line:sub(#line, #line) == ':' then -- If the current line ends in a colon, indent the next line
                next_line = next_line .. vim_indent
                if li_type == 'ol' or li_type == 'oltd' then
                    next_number = 1
                    next_line = next_line .. next_number
                end
            else
                if li_type == 'ol' or li_type == 'oltd' then
                    local current_number = string.match(line, M.patterns[li_type].number)
                    next_number = (above and current_number) or current_number + 1
                    next_line = next_line .. next_number
                end
            end
            -- Add the marker
            next_line = next_line .. string.match(line, M.patterns[li_type].marker)
            if li_type == 'oltd' or li_type == 'ultd' then -- Make sure new to-do items have not_started status
                next_line = next_line .. '[' .. to_do_not_started .. '] '
            end
            -- The current length is where we want the cursor to go
            local next_col = #next_line
            if (not above) and carry and col ~= #line then -- Add material from the current line if the cursor isn't @ end of line
                -- Get the material following the cursor for the next line
                next_line = next_line .. line:sub(col + 1, #line)
                -- Rid the current line of the material following the cursor
                vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, #line, { '' })
            end
            -- Set the next line and move the cursor
            vim.api.nvim_buf_set_lines(0, row, row, false, { next_line })
            if cursor_moves then
                vim.api.nvim_win_set_cursor(0, { row + 1, next_col })
            end
            if li_type == 'ol' or li_type == 'oltd' then -- Update the numbering
                if above then
                    update_numbering(row + 1, indentation, li_type, false)
                else
                    update_numbering(row, indentation, li_type, false)
                end
            end
            if mode_after == 'i' then
                vim.cmd('startinsert')
                if cursor_moves and current_mode == 'n' then
                    vim.api.nvim_win_set_cursor(0, { row + 1, (next_col + 1) })
                end
            elseif mode_after == 'n' then
                vim.cmd('stopinsert')
            end
        else
            if line:match('^' .. vim_indent) then -- If the line is indented, demote by removing the indentation
                local replacement = line:gsub('^' .. vim_indent, '')
                local new_indentation = replacement:match(M.patterns[li_type].indentation)
                vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, #line, { replacement })
                -- Update w/ the new indentation
                update_numbering(row, new_indentation, li_type)
                -- Update any adopted children
                update_numbering(row + 1, new_indentation .. vim_indent, li_type, false, 1)
            else -- Otherwise, demote using the canonical demotion
                -- Make a new line with the demotion
                local demotion = string.match(line, M.patterns[li_type].demotion)
                vim.api.nvim_buf_set_lines(0, row - 1, row, false, { demotion })
                vim.api.nvim_win_set_cursor(0, { row, #demotion })
                update_numbering(row - 1, indentation, li_type, false)
                -- Update any subsequent ordered list items that had the same indentation (if there's a next line)
                if vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] then
                    update_numbering(row + 1, indentation, li_type, false, 1)
                end
            end
        end
    elseif alt then -- Feed the requested keys
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(alt, true, false, true), 'n', true)
    end
end

M.updateNumbering = function(opts, offset)
    opts = opts or {}
    offset = offset or 0
    local start = opts[1] or 1
    local row = vim.api.nvim_win_get_cursor(0)[1]
    if row + offset <= vim.api.nvim_buf_line_count(0) then
        row = row + offset
        local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
        local li_type, indentation = M.hasListType(line)
        if li_type ~= nil then
            update_numbering(row, indentation, li_type, true, start)
        end
    end
end

return M
