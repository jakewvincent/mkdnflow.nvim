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

-- Wrapper function for new list items in lists or going to the same cell/next row in a table
M.newListItemOrNextTableRow = function()
    -- Get the current line
    local line = vim.api.nvim_get_current_line()
    if require('mkdnflow').lists.hasListType(line) then
        require('mkdnflow').lists.newListItem('fancy', line)
    elseif require('mkdnflow').tables.isPartOfTable(line) then
        require('mkdnflow').tables.moveToCell(1, 0)
    else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), 'n', true)
    end
end

return M
