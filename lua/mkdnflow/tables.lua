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
local silent = require('mkdnflow').config.silent

local is_part_of_table = function(text)
    if text:match('^|.+|.-$') then
        return true
    else
        return false
    end
end

local extract_cell_data = function(text)
    local cells, complete, first, last = {}, false, nil, 1
    while not complete do
        first, last = text:find('|.-|', last - 1)
        if first and last then
            local content = text:sub(first + 1, last - 1)
            cells[#cells + 1] = {
                content = content,
                start = first + 1,
                finish = last - 1,
                length = #content
            }
        else
            complete = true
        end
    end
    return cells
end

local ingest_table = function(row)
    -- Get the table text
    row = row or vim.api.nvim_win_get_cursor(0)[1]
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    local next_row, i, table_rows = row, 1, {rowdata = {}, metadata = {}}
    while is_part_of_table(line) do
        table_rows.rowdata[tostring(next_row)] = extract_cell_data(line)
        if line:match('%a') == nil then
            table_rows.metadata.midrule_row = next_row
        end
        next_row = next_row + i
        line = vim.api.nvim_buf_get_lines(0, next_row - 1, next_row, false)[1]
        if i == 1 and not is_part_of_table(line) then
            next_row = row - 1
            i = -1
            line = vim.api.nvim_buf_get_lines(0, next_row - 1, next_row, false)[1]
        end
        if i == -1 and not is_part_of_table(line) then
            table_rows.metadata.header_row = next_row - i
        end
    end
    return table_rows
end

local get_max_lengths = function(table_data)
    local max_lengths = {}
    local header = table_data.rowdata[tostring(table_data.metadata.header_row)]
    local midrule_row = table_data.metadata.midrule_row
    for _, cell_data in pairs(header) do
        table.insert(max_lengths, cell_data.length)
    end
    for rownr, row_data in pairs(table_data.rowdata) do
        if #max_lengths ~= #row_data then
            if not silent then vim.api.nvim_echo({{'⬇️  At least one row does not have the same number of cells as there are column headers.', 'WarningMsg'}}, true, {}) end
        end
        if #row_data > 0 then
            for cellnr, cell_data in pairs(row_data) do
                if cell_data.length > max_lengths[cellnr] and tonumber(rownr) ~= tonumber(midrule_row) then
                    max_lengths[cellnr] = cell_data.length
                end
            end
        end
    end
    return max_lengths
end

local M = {}

M.newTable = function(cols, rows, header)
    cols, rows = tonumber(cols), tonumber(rows)
    if header and header:match('noh') then
        header = false
    else
        header = true
    end
    local cursor = vim.api.nvim_win_get_cursor(0)
    local table_row, divider_row, new_cell, new_divider = '|', '|', '   |', ' - |'
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

local format_table = function(table_rows)
    local max_lengths = get_max_lengths(table_rows)
    for cur_col, max_length in ipairs(max_lengths) do
        for row, rowdata in pairs(table_rows.rowdata) do
            local diff = max_length - rowdata[cur_col].length
            if diff > 0 then
                local replacement = ''
                if tonumber(row) == table_rows.metadata.midrule_row then
                    local target_length = (max_length > 2 and max_length - 2) or max_length * -1
                    repeat replacement = replacement..'-' until #replacement == target_length
                    replacement = ' '..replacement..' '
                    vim.api.nvim_buf_set_text(0, tonumber(row) - 1, rowdata[cur_col].start - 1, tonumber(row) - 1, rowdata[cur_col].finish, {replacement})
                else
                    repeat replacement = replacement..' ' until #replacement == diff
                    vim.api.nvim_buf_set_text(0, tonumber(row) - 1, rowdata[cur_col].finish, tonumber(row) - 1, rowdata[cur_col].finish, {replacement})
                    -- Update indices for that row
                end
            elseif diff < 0 and tonumber(row) == table_rows.metadata.midrule_row then
                local replacement = ''
                -- Guard against negative to zero numbers, which would cause the repeat loop to repeat till EOT
                local target_length = (max_length > 2 and max_length - 2) or max_length * -1
                repeat replacement = replacement..'-' until #replacement == target_length
                replacement = ' '..replacement..' '
                vim.api.nvim_buf_set_text(0, tonumber(row) - 1, rowdata[cur_col].start - 1, tonumber(row) - 1, rowdata[cur_col].finish, {replacement})
            end
            -- Update indices in table data
            for col, _ in ipairs(rowdata) do
                if col >= cur_col then
                    table_rows.rowdata[row][col].start = table_rows.rowdata[row][col].start + diff
                    table_rows.rowdata[row][col].finish = table_rows.rowdata[row][col].finish + diff
                end
            end
        end
    end
    return(table_rows)
end

M.formatTable = function()
    local table_rows = ingest_table()
    table_rows = format_table(table_rows)
end

--M.nextcell = function() end
M.nextCell = function(row_offset, cell_offset)
    row_offset = row_offset or 0
    cell_offset = cell_offset or 0
    local position = vim.api.nvim_win_get_cursor(0)
    local row, col = position[1] + row_offset, position[2] + 1
    if is_part_of_table(vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]) then
        local table_rows = ingest_table(row)
        table_rows = format_table(table_rows)
        local ncols = #table_rows.rowdata[tostring(table_rows.metadata.header_row)]
        -- Figure out which cell the cursor is currently in
        local continue, cell = true, 1
        while continue and row_offset == 0 do
            local celldata = table_rows.rowdata[tostring(row)][cell]
            if celldata.start <= col and celldata.finish >= col then
                continue = false
            else
                cell = cell + 1
            end
        end
        local target_cell = cell_offset + cell
        if cell_offset > 0 and target_cell > ncols then -- If we want to move forward, but the target cell is greater than the current number of columns
            local quotient = math.floor(target_cell/ncols)
            row_offset, cell_offset = row_offset + quotient, target_cell - (ncols * quotient) - 1
            M.nextCell(row_offset, cell_offset)
        elseif cell_offset < 0 and target_cell < 1 then
            local quotient = math.abs(math.floor(target_cell - 1/ncols))
            row_offset, cell_offset = row_offset - quotient, target_cell + (ncols * quotient) - 1
            M.nextCell(row_offset, cell_offset)
        else
            vim.api.nvim_win_set_cursor(0, {row, table_rows.rowdata[tostring(row)][target_cell].start})
        end
    else
        if position[1] == row then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-I>", true, false, true), 'i', true)
        end
    end
end

return M
