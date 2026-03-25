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
local utils = require('mkdnflow.utils')

local M = {}

--- Get the vim indentation unit (spaces or tab) for the current buffer
--- @return string The indentation string (spaces based on shiftwidth, or tab)
local function get_vim_indent()
    if vim.bo.expandtab then
        return string.rep(' ', vim.bo.shiftwidth)
    else
        return '\t'
    end
end

--- Create a new list item (if on a list line) or move to the next table row (if in a table)
---@return string|nil fallback_key The fallback key to feed, or nil if the action was handled
M.newListItemOrNextTableRow = function()
    -- Get the current line and line number
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local line = vim.api.nvim_get_current_line()
    if require('mkdnflow').lists.hasListType(line) then
        require('mkdnflow').lists.newListItem(true, false, true, 'i', '<CR>', line)
        return nil -- Handled
    elseif require('mkdnflow').tables.isPartOfTable(line, row) then
        -- Pass line number for proper continuation line detection
        require('mkdnflow').tables.moveToCell(1, 0)
        return nil -- Handled
    else
        -- Return the fallback key for expression mapping
        return utils.keycode('<CR>')
    end
end

--- Indent/dedent a list item and update numbering for ordered lists
---@param direction integer 1 for indent, -1 for dedent
---@return string|nil fallback_key The fallback key to feed, or nil if the action was handled
M.indentListItem = function(direction)
    local lists = require('mkdnflow').lists
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local list_type = lists.hasListType(line)
    if list_type and require('mkdnflow').config.modules.lists then
        local vim_indent = get_vim_indent()
        local indent_len = #vim_indent
        if direction == -1 then
            if line:match('^' .. vim_indent) then
                local new_line = line:gsub('^' .. vim_indent, '')
                vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, #line, { new_line })
                vim.api.nvim_win_set_cursor(0, { row, math.max(0, col - indent_len) })
            end
        else
            vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, 0, { vim_indent })
            vim.api.nvim_win_set_cursor(0, { row, col + indent_len })
        end
        if list_type == 'ol' or list_type == 'oltd' then
            lists.updateNumbering()
            lists.updateNumbering({}, -1)
            lists.updateNumbering({}, 1)
        end
        return nil -- Handled
    else
        local fallback_key = direction == -1 and '<C-d>' or '<C-t>'
        return utils.keycode(fallback_key)
    end
end

--- Indent/dedent an empty list item, or jump to the next/previous table cell
---@param direction integer 1 for forward (indent/next cell), -1 for backward (dedent/prev cell)
---@return string|nil fallback_key The fallback key to feed, or nil if the action was handled
M.indentListItemOrJumpTableCell = function(direction)
    -- Get the current line and line number
    local config = require('mkdnflow').config
    local lists = require('mkdnflow').lists
    local row, line = vim.api.nvim_win_get_cursor(0)[1], vim.api.nvim_get_current_line()
    local list_type = lists.hasListType(line)
    if list_type and config.modules.lists and line:match(lists.patterns[list_type].empty) then
        local vim_indent = get_vim_indent()
        if direction == -1 then
            if line:match('^' .. vim_indent) then
                local new_line = line:gsub('^' .. vim_indent, '')
                vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, #line, { new_line })
            end
        else
            vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, 0, { vim_indent })
        end
        -- Update numbering if it's a numbered list
        if list_type == 'ol' or list_type == 'oltd' then
            lists.updateNumbering()
            lists.updateNumbering({}, -1)
            lists.updateNumbering({}, 1)
        end
        return nil -- Handled
    elseif config.modules.tables and require('mkdnflow').tables.isPartOfTable(line, row) then
        -- Pass line number for proper continuation line detection
        if direction == -1 then
            require('mkdnflow').tables.moveToCell(0, -1)
        else
            require('mkdnflow').tables.moveToCell(0, 1)
        end
        return nil -- Handled
    else
        -- Return the fallback key for expression mapping
        local fallback_key = direction == -1 and '<S-Tab>' or '<Tab>'
        return utils.keycode(fallback_key)
    end
end

--- Follow/create a link, or toggle a fold, depending on context
---@param args? {mode?: string, range?: boolean} Optional mode and range info
M.followOrCreateLinksOrToggleFolds = function(args)
    args = args or {}
    local config = require('mkdnflow').config
    local mode = args.mode or vim.api.nvim_get_mode()['mode']
    local range = args.range or false
    if config.modules.links and (mode == 'v' or range) then
        require('mkdnflow').links.followLink({ range = range })
    else
        local row, line = vim.api.nvim_win_get_cursor(0)[1], vim.api.nvim_get_current_line()
        local on_fold, in_fenced_code_block =
            vim.fn.foldclosed(tostring(row)) ~= -1, utils.cursorInCodeBlock(row)
        if
            config.modules.folds
            and not on_fold
            and not in_fenced_code_block
            and utils.getHeadingLevel(line) < 99
        then
            require('mkdnflow').folds.foldSection()
        elseif config.modules.folds and on_fold then
            require('mkdnflow').folds.unfoldSection(row)
        elseif config.modules.links then
            require('mkdnflow').links.followLink({ range = range })
        end
    end
end

--- Multi-function Enter key handler: follows links/toggles folds in normal/visual, creates list items in insert
---@param args? {range?: boolean} Optional range info
---@return string|nil fallback_key The fallback key to feed, or nil if the action was handled
M.multiFuncEnter = function(args)
    args = args or {}
    local mode = vim.api.nvim_get_mode()['mode']
    local range = args.range or false
    if mode == 'n' or mode == 'v' then
        return M.followOrCreateLinksOrToggleFolds({ mode = mode, range = range })
    elseif mode == 'i' then
        return M.newListItemOrNextTableRow()
    end
    return nil
end

return M
