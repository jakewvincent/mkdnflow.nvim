-- mkdnflow.nvim (Tools for fluent markdown notebook navigation and management)
-- Copyright (C) 2024 Jake W. Vincent <https://github.com/jakewvincent>
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
local to_do_statuses = require('mkdnflow').config.to_do.statuses
local vim_indent = vim.api.nvim_buf_get_option(0, 'expandtab') == true
        and string.rep(' ', vim.api.nvim_buf_get_option(0, 'shiftwidth'))
    or '\t'

--- Method to get the name of a to-do symbol
--- @param symbol string A to-do status symbol
--- @return string|nil # The name of a to-do status symbol
function to_do_statuses:name(symbol)
    -- Look for the symbol first in the primary symbols
    for _, v in ipairs(self) do
        if v.symbol == symbol then
            return v.name
        end
    end
    -- If the name has not been found yet, look in legacy symbols
    for _, v in ipairs(self) do
        if not vim.tbl_isempty(v.legacy_symbols) then
            for _, v_ in ipairs(v.legacy_symbols) do
                if v_ == symbol then
                    return v.name
                end
            end
        end
    end
end

--- Method to get the symbol for a to-do status name
--- @param name string A to-do status name
--- @return string|nil # The corresponding symbol, or nil if there is no corresponding symbol
function to_do_statuses:symbol(name)
    for _, v in ipairs(self) do
        if v.name == name then
            return v.symbol
        end
    end
end

--- Method to get the index of a to-do status name
--- @param status string|table A to-do status name or symbol, or a status table
--- @return integer|nil # The index of the status in the list of statuses
function to_do_statuses:index(status)
    status = type(status) == 'table' and status.name or status
    for i, v in ipairs(self) do
        if v.name == status or v.symbol == status then
            return i
        end
    end
    -- If the status has not been found yet, look in legacy symbols
    for i, v in ipairs(self) do
        if not vim.tbl_isempty(v.legacy_symbols) then
            for _, v_ in ipairs(v.legacy_symbols) do
                if v_ == status then
                    return i
                end
            end
        end
    end
end

--- Method to get a status table (includes name and symbol) based on a name or symbol
--- @param status string|table A name or symbol by which to retrieve a status table from the config
--- @return table|nil # A table containing at least the name and symbol for a status
function to_do_statuses:get(status)
    status = type(status) == 'table' and status.name or status
    for _, v in ipairs(self) do
        if v.name == status or v.symbol == status then
            return v
        end
    end
    -- If the status has not been found yet, look in legacy symbols
    for _, v in ipairs(self) do
        if not vim.tbl_isempty(v.legacy_symbols) then
            for _, v_ in ipairs(v.legacy_symbols) do
                if v_ == status then
                    return v
                end
            end
        end
    end
end

--- Method to get the next symbol
--- @param status string|table A name or symbol by which to retrieve a status table from the config
--- @return table # A status table (containing the name and symbol of the status)
function to_do_statuses:next(status)
    status = type(status) == 'table' and status.name or status
    local idx = self:index(status)
    -- If we're at the last index, return the first item
    if idx == #self then
        return self[1]
    else
        return self[idx + 1]
    end
end

--- To-do lists
--- @class to_do_list A class for a complete to-do list (series of same-level to-do items)
--- @field items table[] A list of same-level to-do items
--- @field line_range table A table containing the start and end line numbers of the list
--- @field line_range.start integer The line number on which the to-do list starts
--- @field line_range.finish integer The line number on which the to-do list ends
local to_do_list = {}
to_do_list.__index = to_do_list
to_do_list.__className = 'to_do_list'

--- Constructor method for to-do lists
--- @return to_do_list # A skeletal to-do list
function to_do_list:new()
    local instance = {
        items = {},
        line_range = { start = 0, finish = 0 },
    }
    setmetatable(instance, self)
    return instance
end

--- A class for individual to-do items
--- @class to_do_item
--- @field line_nr integer The (one-based) line number on which the to-do item can be found
--- @field level integer The indentation-based level of the to-do item (0 == the item has no indentation and no parents)
--- @field content string The text of the entire line stored under line_nr
--- @field status table A to-do status table
--- @field status.name string The to-do status name (e.g. 'completed')
--- @field status.symbol string The to-do status symbol (e.g. 'x')
--- @field status.legacy_symbols? table A list of legacy (previously-used) symbols
--- @field valid boolean Whether the line contains a recognized to-do item
--- @field parent to_do_item The closest item in the list that has a level one less than the child item
--- @field children to_do_list A list of to-do items one level higher beneath the main item
--- @field siblings table[] A list of same-level to-do items adjacent to the current item
local to_do_item = {}
to_do_item.__index = to_do_item
to_do_item.__className = 'to_do_item'

--- Constructor method for to-do items
--- @param opts? table # A table of possible options with values for the instance
--- @return to_do_item # A skeletal to-do item
function to_do_item:new(opts)
    opts = opts or {}
    local instance = {
        line_nr = opts.line_nr or -1,
        level = opts.level or -1,
        content = opts.content or '',
        status = opts.status or {},
        valid = opts.valid or false,
        parent = opts.parent or {},
        children = opts.children or to_do_list:new(),
        siblings = opts.siblings or {},
    }
    setmetatable(instance, self)
    return instance
end

--- Method to read a to-do item from a line number
--- @param line_nr integer A (one-based) line number from which to read the to-do item
--- @param find_ancestors? boolean Whether or not to look for and register ancestors of the to-do item
--- @return to_do_item # A complete to-do item
function to_do_item:read(line_nr, find_ancestors)
    find_ancestors = find_ancestors == nil and true or find_ancestors
    local new_to_do_item = to_do_item:new() -- Create a new instance
    -- Get the line
    local line = vim.api.nvim_buf_get_lines(0, line_nr - 1, line_nr, false)
    new_to_do_item.content = (not vim.tbl_isempty(line)) and line[1] or ''
    -- Check if we have a valid to-do list new_to_do_item
    local valid_str = new_to_do_item.content:match('^%s-[-+*%d]+%.?%s-%[..?.?.?%]') -- Up to 4 bytes for the status
    if valid_str then
        -- Retrieve the symbol from the matching string
        local symbol = valid_str:match('%[(..?.?.?)%]')
        -- Record line nr, status
        new_to_do_item.valid, new_to_do_item.line_nr, new_to_do_item.status =
            true, line_nr, to_do_statuses:get(symbol)

        -- Figure out the level of the new_to_do_item (based on indentation)
        _, new_to_do_item.level = string.gsub(new_to_do_item.content:match('^%s*'), vim_indent, '')

        -- Identify parents, siblings, and children
        if find_ancestors then
            new_to_do_item:add_ancestors()
        end
    else
        new_to_do_item.valid = false
    end
    return new_to_do_item
end

--- Method for a to-do item to update itself (e.g. if it is only partially complete)
--- @param find_ancestors? boolean Whether or not to look for ancestors of the to-do item
function to_do_item:update(find_ancestors)
    find_ancestors = find_ancestors == nil and true or find_ancestors
    -- Check if we have a valid to-do list new_to_do_item
    local valid_str = self.content:match('^%s-[-+*%d]+%.?%s-%[..?.?.?%]') -- Up to 4 bytes for the status
    if valid_str then
        -- Retrieve the symbol from the matching string
        local symbol = valid_str:match('%[(..?.?.?)%]')
        -- Record validity, status
        self.valid, self.status = true, to_do_statuses:get(symbol) or self.status

        -- Figure out the level of the current to-do item (based on indentation)
        _, self.level = string.gsub(self.content:match('^%s*'), vim_indent, '')

        -- Identify parents, siblings, and children
        if find_ancestors then
            self:add_ancestors()
        end
    else
        self.valid = false
    end
end

--- Method to find and register the ancestors of a to-do item in itself
function to_do_item:add_ancestors()
    -- Of all the ancestors, only the children will be a complete (sub-) to-do list
    local children = to_do_list:new()
    -- Only look for parents and siblings if we have an indentation
    if self.level > 0 then
        -- Look up for the parent (and siblings)
        local cur_line = self.line_nr - 1
        local candidate = self:read(cur_line, false)
        local parent_sib_or_cous = (candidate.level == self.level - 1)
            or candidate.level >= self.level
        -- Keep checking as long as we have a valid candidate that is a parent or a sibling
        while candidate.valid and cur_line > 0 and parent_sib_or_cous do
            if candidate.valid and candidate.level < self.level then
                self.parent = candidate
                break -- Leave the while-loop if we've found the parent
            elseif candidate.valid and candidate.level == self.level then
                -- Take the opportunity to record any siblings we find
                table.insert(self.siblings, 1, candidate)
                -- Skip valid candidates w/ a level greater than self's level; these would be cousins
            end
            -- Get the next candidate
            cur_line = cur_line - 1
            candidate = self:read(cur_line, false)
            parent_sib_or_cous = (candidate.level == self.level - 1)
                or candidate.level >= self.level
        end
        -- Now look down for children or siblings
        cur_line = self.line_nr + 1
        candidate = self:read(cur_line, false)
        local descendant_or_sib = candidate.level >= self.level
        -- Stop when the candidate is invalid or has a lower level than the current item
        while candidate.valid and descendant_or_sib do
            if candidate.level == self.level then -- Sibling
                table.insert(self.siblings, candidate)
            elseif candidate.level == self.level + 1 then -- Child
                children:add_item(candidate)
                -- Skip valid candidates w/ a level > self's level + 1; these would be grandchildren
            end
            cur_line = cur_line + 1
            candidate = self:read(cur_line, false)
            descendant_or_sib = candidate.level >= self.level
        end
    else -- If the level is 0, we still need to look for children
        local cur_line = self.line_nr + 1
        local candidate = self:read(cur_line, false)
        local descendant = candidate.level > self.level
        while candidate.valid and descendant do
            children:add_item(candidate)
            cur_line = cur_line + 1
            candidate = self:read(cur_line, false)
            descendant = candidate.level > self.level
        end
    end
    -- Add the sub-list of children to the children field
    self.children = children
end

--- Method to get the status object for a target status
--- @param target string|table A string (to-do symbol or to-do name) or a table containing both
function to_do_item:set_status(target)
    -- Create the new line, substituting the current status with the target status
    -- Get the status object
    local target_status = type(target) == 'table' and target or to_do_statuses:get(target)
    -- Prep the updated text for the line
    local new_line = self.content:gsub(
        string.format('%%[(%s)%%]', self.status.symbol), -- The current symbol
        -- Recycle the current symbol if the target status is not regognized
        string.format('%%[%s%%]', target_status ~= nil and target_status.symbol or '%1'),
        1
    )
    vim.api.nvim_buf_set_lines(0, self.line_nr - 1, self.line_nr, false, { new_line })
    -- Update status
    self.status = target_status ~= nil and target_status or self.status
    -- Update parents if possible and desired
    if not vim.tbl_isempty(self.parent) and require('mkdnflow').config.to_do.update_parents then
        self:update_parent()
    end
end

--- Method to change a to-do item's status to the next status in the config list
function to_do_item:cycle_status()
    local next_status = to_do_statuses:next(self.status)
    self:set_status(next_status)
end

--- Shortcut method to change a to-do item's status to 'complete'
function to_do_item:complete()
    self:set_status('complete')
end

--- Shortcut method to change a to-do item's status to 'not_started'
function to_do_item:not_started()
    self:set_status('not_started')
end

--- Shortcut method to change a to-do item's status to 'in_progress'
function to_do_item:in_progress()
    self:set_status('in_progress')
end

--- Method to update parents in response to children status changes
function to_do_item:update_parent()
    if self.status.name == 'complete' then
        -- Check if all the siblings are also complete
        local sibs_complete = true
        for _, sib in ipairs(self.siblings) do
            if sib.status.name ~= 'complete' then
                sibs_complete = false
            end
        end
        -- Complete the parent if all the sibs are complete; otherwise, mark the parent as in
        -- progress
        if sibs_complete then
            self.parent:complete()
        else
            self.parent:in_progress()
        end
    elseif self.status.name == 'in_progress' then
        -- In this case, the parent should also be in progress, regardless of the status of the sibs
        if self.parent.status.name ~= 'in_progress' then
            self.parent:in_progress()
        end
    elseif self.status.name == 'not_started' then
        -- Check if any of the siblings are either complete or in progress
        local sibs_not_started = true
        for _, sib in ipairs(self.siblings) do
            if sib.status.name ~= 'not_started' then
                sibs_not_started = false
            end
        end
        -- Mark the parent as not started if none of the sibs are started either; otherwise, mark
        -- the parent as in progress
        if sibs_not_started then
            self.parent:not_started()
        else
            self.parent:in_progress()
        end
    end
end

--- Method to read in a to-do list. If `end_line_nr` is passed in, `line_nr` should be the line
--- number of the first item in the list. Otherwise, `line_nr` can be the line number of any item in
--- the list, and the function will identify the start and end of the list independently.
--- @param line_nr? integer A line number of an item in the list
--- @return to_do_list # A filled-in to-do list
function to_do_list:get(line_nr)
    line_nr = line_nr ~= nil and line_nr or vim.api.nvim_win_get_cursor(0)[1]
    -- Prepare a table for the to-do list
    local new_to_do_list = to_do_list:new()
    -- Look up, adding lines that are valid to-do list items into the list
    local cur_line_nr, item = line_nr, to_do_item:read(line_nr)
    while cur_line_nr >= 0 and item.valid do
        table.insert(new_to_do_list.items, 1, item)
        cur_line_nr = cur_line_nr - 1
        item = to_do_item:read(cur_line_nr)
    end
    -- Record the starting line of the to-do list
    new_to_do_list.line_range[1] = #new_to_do_list.items > 0 and new_to_do_list.items[1].line_nr
        or 0

    -- Look down...
    local line_count = vim.api.nvim_buf_line_count(0)
    cur_line_nr, item = line_nr + 1, to_do_item:read(line_nr + 1)
    while cur_line_nr <= line_count and item.valid do
        table.insert(new_to_do_list.items, item)
        cur_line_nr = cur_line_nr + 1
        item = to_do_item:read(cur_line_nr)
    end
    -- Record the ending line of the to-do list
    new_to_do_list.line_range[2] = #new_to_do_list.items > 0
            and new_to_do_list.items[#new_to_do_list.items].line_nr
        or 0
    return new_to_do_list
end

--- The to_do module table
local M = {}

--- Function to retrieve a to-do item
--- @param opts? table A table, optionally including line_nr (int) and find_ancestors (bool)
--- @return to_do_item # A processed to-do item
function M.get_to_do_item(opts)
    -- Use the current (cursor) line if no line number was provided
    local line_nr, find_ancestors =
        opts and opts.line_nr or vim.api.nvim_win_get_cursor(0)[1], -- Use cur. line if no line provided
        opts and opts.find_ancestors or nil -- Use nil if no find_ancestors value provided
    -- If we have a visual selection spanning multiple lines, take a different approach
    local item = to_do_item:read(line_nr, find_ancestors)
    return item
end

--- Function to retrieve an entire to-do list
--- @param line_nr integer A line number (anywhere in the list) from which to look for to-do items
--- @return to_do_list # A complete to-do list
function M.get_to_do_list(line_nr)
    line_nr = line_nr or vim.api.nvim_win_get_cursor(0)[1] -- Use cur. line if no line provided
    local list = to_do_list:get(line_nr)
    return list
end

--- Function to cycle through the to-do status symbols for the item on the current line
function M.toggle_to_do()
    local mode = vim.api.nvim_get_mode()['mode']
    -- If we're in visual mode, toggle the to-do items on all selected lines
    if mode == 'v' then
        local pos_a, pos_b = vim.fn.getpos('v')[2], vim.api.nvim_win_get_cursor(0)[1]
        -- Use the lower value for `first` and the higher value for `last`
        local first, last = (pos_a < pos_b and pos_a) or pos_b, (pos_b > pos_a and pos_b) or pos_a
        if first == 0 or last == 0 then
            M.get_to_do_item({ line_nr = pos_b }):cycle_status()
        else
            for line_nr = first, last do
                M.get_to_do_item({ line_nr = line_nr }):cycle_status()
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
        M.get_to_do_item():cycle_status()
    end
end

return M
