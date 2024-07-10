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

local status_methods = {
    __index = {
        get_symbol = function(self)
            if type(self.symbol) == 'table' then
                return self.symbol[1]
            else
                return self.symbol
            end
        end,
        get_extra_symbols = function(self)
            local symbols = {}
            if type(self.symbol) == 'table' then
                for i = 2, #self.symbol do
                    table.insert(symbols, self.symbol[i])
                end
            end
            return symbols
        end,
    },
}

-- Set the methods for each status table
for _, status in ipairs(to_do_statuses) do
    setmetatable(status, status_methods)
end

--- Method to get the name of a to-do symbol
--- @param symbol string A to-do status symbol
--- @return string|nil # The name of a to-do status symbol
function to_do_statuses:name(symbol)
    -- Look for the symbol first in the primary symbols
    for _, status_tbl in ipairs(self) do
        if status_tbl:get_symbol() == symbol then
            return status_tbl.name
        end
    end
    -- If the name has not been found yet, look in legacy symbols
    for _, status_tbl in ipairs(self) do
        if vim.list_contains(status_tbl:get_extra_symbols(), symbol) then
            return status_tbl.name
        end
    end
end

--- Method to get the symbol for a to-do status name
--- @param name string A to-do status name
--- @return string|nil # The corresponding symbol, or nil if there is no corresponding symbol
function to_do_statuses:get_symbol(name)
    for _, status_tbl in ipairs(self) do
        if status_tbl.name == name then
            return status_tbl:get_symbol()
        end
    end
end

--- Method to get the index of a to-do status name
--- @param status string|table A to-do status name or symbol, or a status table
--- @return integer|nil # The index of the status in the list of statuses
function to_do_statuses:index(status)
    status = type(status) == 'table' and status.name or status
    for i, status_tbl in ipairs(self) do
        if status_tbl.name == status or status_tbl:get_symbol() == status then
            return i
        end
    end
    -- If the status has not been found yet, look in legacy symbols
    for i, status_tbl in ipairs(self) do
        if vim.list_contains(status_tbl:get_extra_symbols(), status) then
            return i
        end
    end
end

--- Method to get a status table (includes name and symbol) based on a name or symbol
--- @param status string|table A name or symbol by which to retrieve a status table from the config
--- @return table|nil # A table containing at least the name and symbol for a status
function to_do_statuses:get(status)
    status = type(status) == 'table' and status.name or status
    for _, status_tbl in ipairs(self) do
        if status_tbl.name == status or status_tbl:get_symbol() == status then
            return status_tbl
        end
    end
    -- If the status has not been found yet, look in legacy symbols
    for _, status_tbl in ipairs(self) do
        if vim.list_contains(status_tbl:get_extra_symbols(), status) then
            return status_tbl
        end
    end
end

--- Method to get the next symbol
--- @param status string|table A name or symbol by which to retrieve a status table from the config
--- @return table # A status table (containing the name and symbol of the status)
function to_do_statuses:next(status)
    status = type(status) == 'table' and status.name or status
    if type(status) == 'table' then
        if status.name then
            status = status.name
        else
            status = status[1]
        end
    end
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
--- @field relatives_added boolean
--- @field line_range{start: integer, finish:integer} A table containing the start and end line numbers of the list
--- @field base_level integer
--- @field requester_idx integer
local to_do_list = {}
to_do_list.__index = to_do_list
to_do_list.__className = 'to_do_list'

--- Constructor method for to-do lists
--- @return to_do_list # A skeletal to-do list
function to_do_list:new()
    local instance = {
        items = {},
        relatives_added = false,
        parent = {},
        line_range = { start = 0, finish = 0 },
        base_level = -1,
        requester_idx = -1,
    }
    setmetatable(instance, self)
    return instance
end

--- A class for individual to-do items
--- @class to_do_item
--- @field line_nr integer The (one-based) line number on which the to-do item can be found
--- @field level integer The indentation-based level of the to-do item (0 == the item has no indentation and no parents)
--- @field content string The text of the entire line stored under line_nr
--- @field status {name: string, symbol: string|string[], sort: {section: integer, position: string}, propagate: {up: fun(host_list: to_do_list):string|nil, down: fun(children_list: to_do_list): string|nil}} A to-do status table
--- @field valid boolean Whether the line contains a recognized to-do item
--- @field parent to_do_item The closest item in the list that has a level one less than the child item
--- @field children to_do_list A list of to-do items one level higher beneath the main item
--- @field host_list to_do_list The to-do list that contains the item
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
        host_list = opts.host_list or {},
    }
    setmetatable(instance, self)
    return instance
end

--- A method to read a to-do list at the level of the item at the line number passed in
--- @param line_nr integer A line number where a to-do item can be found
--- @return to_do_list # A filled-in to-do list instance
function to_do_list:read(line_nr)
    local item, line_count = to_do_item:read(line_nr), vim.api.nvim_buf_line_count(0)
    if item.valid then
        self:add_item(item)
        self.base_level = item.level
        -- Look up for siblings
        for _line_nr = item.line_nr - 1, 1, -1 do
            local candidate = to_do_item:read(_line_nr)
            if candidate.level < self.base_level or not candidate.valid then
                break
            end
            if candidate.valid and candidate.level == self.base_level then
                self:add_item(candidate)
            end
        end
        -- Look down for siblings
        for _line_nr = item.line_nr + 1, line_count, 1 do
            local candidate = to_do_item:read(_line_nr)
            if candidate.level < self.base_level or not candidate.valid then
                break
            end
            if candidate.valid and candidate.level == self.base_level then
                self:add_item(candidate)
            end
        end
        -- Set the index of the requester
        for i, sibling in ipairs(self.items) do
            if sibling.line_nr == line_nr then
                self.requester_idx = i
                break
            end
        end
    end
    return self:add_relatives()
end

--- A method to identify all relationships within a to-do list
--- @param parent? to_do_item The parent that all list members descend from
--- @return to_do_list # A to-do list with relationships identified
function to_do_list:add_relatives(parent)
    -- Look for a parent
    if self.base_level > 0 then
        parent = parent or to_do_item:read(self.line_range.start - 1)
        if parent.valid then
            parent.children = self
            self.parent = parent
            for _, child in ipairs(self.items) do
                child.parent = self.parent
            end
        end
    end
    -- Register any children
    for i, sibling in ipairs(self.items) do
        -- If there is space between the next item and the current item, there must be children
        if self.items[i + 1] and self.items[i + 1].line_nr > sibling.line_nr + 1 then
            local children = to_do_list:new():read(sibling.line_nr + 1)
            sibling.children = children
        else -- We're at the last sibling; check below it
            local candidate = to_do_item:read(sibling.line_nr + 1)
            if candidate.valid and candidate.level == sibling.level + 1 then
                local children = to_do_list:new():read(sibling.line_nr + 1)
                sibling.children = children
            end
        end
    end
    self.relatives_added = true
    self.line_range.finish = self:terminus().line_nr
    return self
end

--- A method to identify the last to-do item in a to-do list, including the most deeply embedded
--- descendant of the last list item, if any
--- @return to_do_item # The last to-do item in the list
function to_do_list:terminus()
    local function last_item(list)
        local last_sib = list.items[#list.items]
        if last_sib:has_children() then
            last_sib = last_item(last_sib.children)
        end
        return last_sib
    end
    return last_item(self)
end

--- Method to read a to-do item from a line number
--- @param line_nr integer A (one-based) buffer line number from which to read the to-do item
--- @return to_do_item # A complete to-do item
function to_do_item:read(line_nr)
    local new_to_do_item = to_do_item:new() -- Create a new instance
    -- Get the line
    local line = vim.api.nvim_buf_get_lines(0, line_nr - 1, line_nr, false)
    new_to_do_item.content = (not vim.tbl_isempty(line)) and line[1] or ''
    -- Check if we have a valid to-do list new_to_do_item
    local valid_str = new_to_do_item.content:match('^%s-[-+*%d]+%.?%s-%[..?.?.?.?.?%]') -- Up to 6 bytes for the status
    if valid_str then
        -- Retrieve the symbol from the matching string
        local symbol = valid_str:match('%[(..?.?.?.?.?)%]')
        -- Record line nr, status
        new_to_do_item.valid, new_to_do_item.line_nr, new_to_do_item.status =
            true, line_nr, to_do_statuses:get(symbol) or {}

        -- Figure out the level of the new_to_do_item (based on indentation)
        _, new_to_do_item.level = string.gsub(new_to_do_item.content:match('^%s*'), vim_indent, '')
        -- TODO: Add this to-do item to a cache
        return new_to_do_item
    end
    new_to_do_item.valid = false
    return new_to_do_item
end

function to_do_item:get(line_nr)
    local list = to_do_list:new():read(line_nr)
    local item = list.items[list.requester_idx]
    item.host_list = list
    return item
end

--- Method to retrieve the default symbol of a to-do status
--- @return string # The to-do status symbol, as a string
function to_do_item:get_symbol()
    return self.status:get_symbol()
end

--- Method to get any and all legacy/extra symbols from a to-do status table
--- @return string[] # A list of strings
function to_do_item:get_extra_symbols()
    return self.status:get_extra_symbols()
end

--- Method to get the status object for a target status
--- @param target string|table A string (to-do symbol or to-do name) or a table containing both
function to_do_item:set_status(target, dependent_call, propagation_direction)
    dependent_call = dependent_call == nil and false or dependent_call
    local config = require('mkdnflow').config.to_do
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
    -- Update status (or keep the same if no target was found)
    self.status = target_status ~= nil and target_status or self.status
    -- Update the item's content attribute
    self.content = new_line
    -- Update parents if possible and desired
    if
        not vim.tbl_isempty(self.parent) and config.status_propagation.up
        or config.status_propagation.down
    then
        self:propagate_status(dependent_call, propagation_direction)
    end
    -- Sort the to-do list if desired
    if config.sort.on_status_change and not dependent_call then
        self.host_list:sort(self)
    end
end

--- Method to change a to-do item's status to the next status in the config list
function to_do_item:cycle_status(dependent_call)
    dependent_call = dependent_call == nil and false or dependent_call
    local next_status = to_do_statuses:next(self.status)
    self:set_status(next_status, dependent_call)
end

--- Shortcut method to change a to-do item's status to 'complete'
function to_do_item:complete(dependent_call, propagation_direction)
    dependent_call = dependent_call == nil and false or dependent_call
    self:set_status('complete', dependent_call, propagation_direction)
end

--- Shortcut method to change a to-do item's status to 'not_started'
function to_do_item:not_started(dependent_call, propagation_direction)
    dependent_call = dependent_call == nil and false or dependent_call
    self:set_status('not_started', dependent_call, propagation_direction)
end

--- Shortcut method to change a to-do item's status to 'in_progress'
function to_do_item:in_progress(dependent_call, propagation_direction)
    dependent_call = dependent_call == nil and false or dependent_call
    self:set_status('in_progress', dependent_call, propagation_direction)
end

--- Method to update parents in response to children status changes
function to_do_item:propagate_status(dependent_call, direction)
    local config = require('mkdnflow').config.to_do
    -- Don't do anything if the item has no parent
    if config.status_propagation.up == false and config.status_propagation.down == false then
        return
    end
    -- Update parental lineage first
    if config.status_propagation.up and self:has_parent() and direction ~= 'down' then
        local parent_updated = false
        local target_status = self.status.propagate.up(self.host_list)
        if target_status and self.parent.status.name ~= target_status then
            self.parent:set_status(target_status, true, 'up')
            parent_updated = true
        end
        if parent_updated then
            local parent_line_nr = self.parent.line_nr
            -- Get parent to-do list
            local parent = to_do_item:get(parent_line_nr)
            parent:propagate_status(true, 'up')
        end
    end
    -- Update children
    if config.status_propagation.down and self:has_children() then
        -- Get a list of target statuses
        local target_statuses = self.status.propagate.down(self.children)
        if target_statuses and #target_statuses ~= #self.children.items then
            -- TODO: Issue a warning
        end
        if target_statuses and not vim.tbl_isempty(target_statuses) then
            for i, child in ipairs(self.children.items) do
                child:set_status(target_statuses[i], true, 'down')
            end
        end
    end
end

--- Method to identify whether a to-do item has registered siblings or not
--- @return boolean
function to_do_item:has_siblings()
    -- The item will have siblings as long as it is not the only item in the host list
    if #self.host_list.items > 1 then
        return true
    end
    return false
end

--- Method to identify whether a to-do item has registered children or not
--- @return boolean
function to_do_item:has_children()
    if not vim.tbl_isempty(self.children.items) then
        return true
    end
    return false
end

--- Method to identify whether a to-do item has a registered parent or not
--- @return boolean
function to_do_item:has_parent()
    if not vim.tbl_isempty(self.parent) then
        return true
    end
    return false
end

--- Method to flatten a to-do item's descendants into one table
--- @param content_only boolean Whether to return just the content of the flattened lines or the
--- full to-do items
--- @return table[] # A list of descendant to-do items, empty if the item has no descendants
function to_do_list:flatten(content_only)
    local flattened = {}
    local function flatten_item(item)
        table.insert(flattened, content_only and item.content or item)
        if item:has_children() then
            for _, child in ipairs(item.children.items) do
                flatten_item(child)
            end
        end
    end

    for _, item in ipairs(self.items) do
        flatten_item(item)
    end
    return flattened
end

--- Method to add a to-do item to an (internal) to-do list
--- @param item to_do_item A valid to-do item
function to_do_list:add_item(item)
    if item.valid then
        local added = false
        for i = 1, #self.items, 1 do
            if self.items[i].line_nr > item.line_nr then
                table.insert(self.items, i, item)
                added = true
                break
            end
        end
        if not added then
            table.insert(self.items, item)
        end
        -- Update line range
        self.line_range.start = self.items[1].line_nr
        self.line_range.finish = self.items[#self.items].line_nr
    end
end

--- Method to sort a to-do list
--- @param target_item? to_do_item The item whose status change triggered the sort call
function to_do_list:sort(target_item)
    local sections, cursor = {}, { new_line = 0, old_position = vim.api.nvim_win_get_cursor(0) }
    -- Put the siblings in their respective section
    local hold = {}
    for _, item in ipairs(self.items) do
        if not sections[item.status.sort.section] then
            sections[item.status.sort.section] = {}
        end
        if
            target_item
            and target_item.line_nr == item.line_nr
            and (item.status.sort.position == 'top' or item.status.sort.position == 'bottom')
        then
            table.insert(hold, item)
        else
            table.insert(sections[item.status.sort.section], item)
        end
    end
    -- Now add the held items (if any)
    for _, item in ipairs(hold) do
        if not sections[item.status.sort.section] then
            sections[item.status.sort.section] = {}
        end
        if item.status.sort.position == 'top' then
            table.insert(sections[item.status.sort.section], 1, item)
        elseif item.status.sort.position == 'bottom' then
            table.insert(sections[item.status.sort.section], item)
        end
    end
    local replacement_lines = {}
    -- Gather the sections, flattening any descendants
    local cur_replacee_line = self.line_range.start
    for _, tbl in vim.spairs(sections) do
        for _, item in ipairs(tbl) do
            table.insert(replacement_lines, item.content)
            if item.line_nr == cursor.old_position[1] then
                cursor.new_line = cur_replacee_line
            end
            cur_replacee_line = cur_replacee_line + 1
            if item:has_children() then
                local descendants = item.children:flatten()
                for _, item_ in ipairs(descendants) do
                    if item_.line_nr == cursor.old_position[1] then
                        cursor.new_line = cur_replacee_line
                    end
                    cur_replacee_line = cur_replacee_line + 1
                    table.insert(replacement_lines, item_.content)
                end
            end
        end
    end
    -- Replace the lines in the buffer
    vim.api.nvim_buf_set_lines(
        0,
        self.line_range.start - 1,
        self.line_range.finish,
        false,
        replacement_lines
    )
    -- Move the cursor if desired
    -- TODO: Account for unicode bytes
    if
        require('mkdnflow').config.to_do.sort.on_status_change
        and require('mkdnflow').config.to_do.sort.cursor_behavior.track
        and cursor.new_line > 0
    then
        vim.api.nvim_win_set_cursor(0, { cursor.new_line, cursor.old_position[2] })
    end
end

--- The to_do module table
local M = {}

--- Function to retrieve a to-do item
--- @param line_nr? integer A table, optionally including line_nr (int) and find_ancestors (bool)
--- @return to_do_item # A processed to-do item
function M.get_to_do_item(line_nr)
    -- Use the current (cursor) line if no line number was provided
    line_nr = line_nr or vim.api.nvim_win_get_cursor(0)[1] -- Use cur. line if no line provided
    -- TODO If we have a visual selection spanning multiple lines, take a different approach
    local item = to_do_item:get(line_nr)
    return item
end

--- Function to retrieve an entire to-do list
--- @param line_nr integer A line number (anywhere in the list) from which to look for to-do items
--- @return to_do_list # A complete to-do list
function M.get_to_do_list(line_nr)
    line_nr = line_nr or vim.api.nvim_win_get_cursor(0)[1] -- Use cur. line if no line provided
    local list = to_do_list:new():read(line_nr)
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
            M.get_to_do_item(pos_b):cycle_status()
        else
            for line_nr = first, last do
                M.get_to_do_item(line_nr):cycle_status()
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
