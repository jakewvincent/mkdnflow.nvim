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

M.newTable = function(cols, rows, header)
    cols = tonumber(cols)
    rows = tonumber(rows)
    if header and header:match('noh') then
        header = false
    else
        header = true
    end
    local cursor = vim.api.nvim_win_get_cursor(0)
    local table_row = '|'
    local divider_row = '|'
    local new_cell = '   |'
    local new_divider = ' - |'
    -- Make a prototypical row
    for cell = 1, cols, 1 do
        table_row = table_row..new_cell
    end
    if header then
        for cell = 1, cols, 1 do
            divider_row = divider_row..new_divider
        end
    end
    -- Make the rows
    for row = 1, rows, 1 do
        vim.api.nvim_buf_set_lines(0, cursor[1], cursor[1], false, {table_row})
    end
    -- If a header is desired, add the separator and one more row for the headers
    if header then
        vim.api.nvim_buf_set_lines(0, cursor[1], cursor[1], false, {divider_row})
        vim.api.nvim_buf_set_lines(0, cursor[1], cursor[1], false, {table_row})
    end
end

return M
