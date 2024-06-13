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
local config = require('mkdnflow').config
local lists = require('mkdnflow').lists
local utils = require('mkdnflow').utils
local vim_indent
if vim.api.nvim_buf_get_option(0, 'expandtab') == true then
    vim_indent = string.rep(' ', vim.api.nvim_buf_get_option(0, 'shiftwidth'))
else
    vim_indent = '\t'
end

local M = {}

-- Wrapper function for new list items in lists or going to the same cell/next row in a table
M.newListItemOrNextTableRow = function()
    -- Get the current line
    local line = vim.api.nvim_get_current_line()
    if require('mkdnflow').lists.hasListType(line) then
        require('mkdnflow').lists.newListItem(true, false, true, 'i', '<CR>', line)
    elseif require('mkdnflow').tables.isPartOfTable(line) then
        require('mkdnflow').tables.moveToCell(1, 0)
    else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', true)
    end
end

M.indentListItemOrJumpTableCell = function(direction)
    -- Get the current line
    local row, line = vim.api.nvim_win_get_cursor(0)[1], vim.api.nvim_get_current_line()
    local list_type = lists.hasListType(line)
    if list_type and config.modules.lists and line:match(lists.patterns[list_type].empty) then
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
    elseif config.modules.tables and require('mkdnflow').tables.isPartOfTable(line) then
        if direction == -1 then
            require('mkdnflow').tables.moveToCell(0, -1)
        else
            require('mkdnflow').tables.moveToCell(0, 1)
        end
    else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-I>', true, false, true), 'n', true)
    end
end

M.followOrCreateLinksOrToggleFolds = function(args)
    args = args or {}
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
            and require('mkdnflow').folds.getHeadingLevel(line) < 99
        then
            require('mkdnflow').folds.foldSection()
        elseif config.modules.folds and on_fold then
            require('mkdnflow').folds.unfoldSection(row)
        elseif config.modules.links then
            require('mkdnflow').links.followLink({ range = range })
        end
    end
end

M.multiFuncEnter = function(args)
    args = args or {}
    local mode = vim.api.nvim_get_mode()['mode']
    local range = args.range or false
    if mode == 'n' or mode == 'v' then
        M.followOrCreateLinksOrToggleFolds({ mode = mode, range = range })
    elseif mode == 'i' then
        M.newListItemOrNextTableRow()
    end
end

return M
