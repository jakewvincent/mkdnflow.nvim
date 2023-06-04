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
local utils = require('mkdnflow').utils
local utf8_available = utils.moduleAvailable('lua-utf8')
local vim_indent
if vim.api.nvim_buf_get_option(0, 'expandtab') == true then
    vim_indent = string.rep(' ', vim.api.nvim_buf_get_option(0, 'shiftwidth'))
else
    vim_indent = '	'
end

local M = {}

local width = function(string)
    if utf8_available then
        return require('lua-utf8').width(string)
    else
        return #string
    end
end

local extract_cell_data = function(text)
    local bars_escaped = text:gsub('\\|', '##')
    local cells, complete, first, last = {}, false, nil, 1
    while not complete do
        first, last = bars_escaped:find('|.-|', last)
        if first and last then
            local content = text:sub(first + 1, last - 1)
            local trimmed_content = content:match('^%s*( .- )%s*$') or content:match('^%s*(.-)%s*$')
            cells[#cells + 1] = {
                content = content,
                trimmed_content = trimmed_content,
                start = first + 1,
                finish = last,
                length = width(content),
                trimmed_length = width(trimmed_content),
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
    local next_row, i, table_rows = row, 1, { rowdata = {}, metadata = {} }
    while M.isPartOfTable(line) do
        table_rows.rowdata[tostring(next_row)] = extract_cell_data(line)
        if line:match('[:-]') and line:match('%a') == nil then
            table_rows.metadata.midrule_row = next_row
        end
        next_row = next_row + i
        line = vim.api.nvim_buf_get_lines(0, next_row - 1, next_row, false)[1]
        if i == 1 and not M.isPartOfTable(line) then
            next_row = row - 1
            i = -1
            line = vim.api.nvim_buf_get_lines(0, next_row - 1, next_row, false)[1]
        end
        if i == -1 and not M.isPartOfTable(line) then
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
        if config.tables.trim_whitespace then
            if cell_data.trimmed_length < 3 then
                table.insert(max_lengths, 3)
            elseif cell_data.content:sub(#cell_data.content) ~= ' ' then
                table.insert(max_lengths, cell_data.trimmed_length + 1)
            else
                table.insert(max_lengths, cell_data.trimmed_length)
            end
        else
            table.insert(max_lengths, cell_data.length)
        end
    end
    for rownr, row_data in pairs(table_data.rowdata) do
        if max_lengths and #max_lengths ~= #row_data then
            max_lengths = nil
        elseif max_lengths and #row_data > 0 then
            for cellnr, cell_data in pairs(row_data) do
                if config.tables.trim_whitespace then
                    -- See if a minimum is required by the midrule row
                    if tonumber(rownr) == tonumber(midrule_row) then
                        if cell_data.content:match('^ *:.*: *$') then
                            max_lengths[cellnr] = (max_lengths[cellnr] < 5 and 5)
                                or max_lengths[cellnr]
                        elseif
                            cell_data.content:match('^ *:') or cell_data.content:match('^ *.+:')
                        then
                            max_lengths[cellnr] = (max_lengths[cellnr] < 4 and 4)
                                or max_lengths[cellnr]
                        end
                    elseif
                        cell_data.content:sub(#cell_data.content) ~= ' '
                        and cell_data.trimmed_length + 1 > max_lengths[cellnr]
                    then
                        max_lengths[cellnr] = cell_data.trimmed_length + 1
                    elseif cell_data.trimmed_length > max_lengths[cellnr] then
                        max_lengths[cellnr] = cell_data.trimmed_length
                    end
                else
                    if tonumber(rownr) == tonumber(midrule_row) then
                        if cell_data.content:match('^ *:.*: *$') then
                            max_lengths[cellnr] = (max_lengths[cellnr] < 5 and 5)
                                or max_lengths[cellnr]
                        elseif
                            cell_data.content:match('^ *:') or cell_data.content:match('^ *.+:')
                        then
                            max_lengths[cellnr] = (max_lengths[cellnr] < 4 and 4)
                                or max_lengths[cellnr]
                        end
                    elseif
                        cell_data.content:sub(#cell_data.content) ~= ' '
                        and cell_data.length + 1 > max_lengths[cellnr]
                    then
                        max_lengths[cellnr] = cell_data.length + 1
                    elseif cell_data.length > max_lengths[cellnr] then
                        max_lengths[cellnr] = cell_data.length
                    end
                end
            end
        end
    end
    return max_lengths
end

M.isPartOfTable = function(text)
    if text and text:match('^%s*|.+|.-$') then
        return true
    else
        return false
    end
end

M.newTable = function(opts)
    local cols, rows, header = opts[1], opts[2], opts[3]
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
        table_row = table_row .. new_cell
    end
    if header then
        for cell = 1, cols, 1 do
            divider_row = divider_row .. new_divider
        end
    end
    -- Make the rows
    for row = 1, rows, 1 do
        vim.api.nvim_buf_set_lines(0, cursor[1], cursor[1], false, { table_row })
    end
    -- If a header is desired, add the separator and one more row for the headers
    if header then
        vim.api.nvim_buf_set_lines(0, cursor[1], cursor[1], false, { divider_row })
        vim.api.nvim_buf_set_lines(0, cursor[1], cursor[1], false, { table_row })
    end
end

local format_table = function(table_rows)
    local max_lengths = get_max_lengths(table_rows)
    local result = true
    if max_lengths then
        for cur_col, max_length in ipairs(max_lengths) do
            for row, rowdata in pairs(table_rows.rowdata) do
                local diff = max_length - rowdata[cur_col].length
                if diff > 0 then
                    local replacement = ''
                    if tonumber(row) == table_rows.metadata.midrule_row then
                        local target_length = (max_length > 2 and max_length - 2) or max_length * -1
                        -- Make sure to retain alignment markers
                        if rowdata[cur_col].content:match(' *:.*: *') then
                            replacement = ':'
                            repeat
                                replacement = replacement .. '-'
                            until width(replacement) == target_length - 1
                            replacement = replacement .. ':'
                        elseif rowdata[cur_col].content:match('^ *:') then
                            replacement = ':'
                            repeat
                                replacement = replacement .. '-'
                            until width(replacement) == target_length
                        elseif rowdata[cur_col].content:match(': *$') then
                            repeat
                                replacement = replacement .. '-'
                            until width(replacement) == target_length - 1
                            replacement = replacement .. ':'
                        else
                            repeat
                                replacement = replacement .. '-'
                            until width(replacement) == target_length
                        end
                        replacement = ' ' .. replacement .. ' '
                        vim.api.nvim_buf_set_text(
                            0,
                            tonumber(row) - 1,
                            rowdata[cur_col].start - 1,
                            tonumber(row) - 1,
                            rowdata[cur_col].finish - 1,
                            { replacement }
                        )
                    else
                        repeat
                            replacement = replacement .. ' '
                        until width(replacement) == diff
                        vim.api.nvim_buf_set_text(
                            0,
                            tonumber(row) - 1,
                            rowdata[cur_col].finish - 1,
                            tonumber(row) - 1,
                            rowdata[cur_col].finish - 1,
                            { replacement }
                        )
                        -- Update indices for that row
                    end
                elseif diff < 0 and tonumber(row) == table_rows.metadata.midrule_row then
                    local replacement = ''
                    -- Guard against negative to zero numbers, which would cause the repeat loop to repeat till EOT
                    local target_length = (max_length > 2 and max_length - 2) or max_length * -1
                    repeat
                        replacement = replacement .. '-'
                    until width(replacement) == target_length
                    replacement = ' ' .. replacement .. ' '
                    vim.api.nvim_buf_set_text(
                        0,
                        tonumber(row) - 1,
                        rowdata[cur_col].start - 1,
                        tonumber(row) - 1,
                        rowdata[cur_col].finish - 1,
                        { replacement }
                    )
                elseif diff < 0 then
                    local replacement = rowdata[cur_col].trimmed_content
                    if #replacement < max_length then
                        repeat
                            replacement = replacement .. ' '
                        until width(replacement) == max_length
                    end
                    vim.api.nvim_buf_set_text(
                        0,
                        tonumber(row) - 1,
                        rowdata[cur_col].start - 1,
                        tonumber(row) - 1,
                        rowdata[cur_col].finish - 1,
                        { replacement }
                    )
                end
                -- Update indices in table data
                for col, _ in ipairs(rowdata) do
                    if col > cur_col then
                        table_rows.rowdata[row][col].start = table_rows.rowdata[row][col].start
                            + diff
                        table_rows.rowdata[row][col].finish = table_rows.rowdata[row][col].finish
                            + diff
                    elseif col == cur_col then
                        table_rows.rowdata[row][col].finish = table_rows.rowdata[row][col].finish
                            + diff
                    end
                end
            end
        end
    else
        result = false
    end
    return table_rows, result
end

M.formatTable = function()
    local table_rows = ingest_table()
    local result
    table_rows, result = format_table(table_rows)
    if not result then
        if not config.silent then
            vim.api.nvim_echo({
                {
                    '⬇️  At least one row does not have the same number of cells as there are column headers.',
                    'WarningMsg',
                },
            }, true, {})
        end
    end
end

local which_cell = function(table_rows, row, col)
    -- Figure out which cell the cursor is currently in
    local continue, cell = true, 1
    while continue do
        local celldata = table_rows.rowdata[tostring(row)][cell]
        if celldata.start - 1 <= col + 1 and celldata.finish >= col + 1 then
            continue = false
        else
            cell = cell + 1
        end
    end
    return cell
end

M.moveToCell = function(row_offset, cell_offset)
    row_offset = row_offset or 0
    cell_offset = cell_offset or 0
    local position = vim.api.nvim_win_get_cursor(0)
    local row, col = position[1] + row_offset, position[2]
    if M.isPartOfTable(vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]) then
        local table_rows = ingest_table(row)
        table_rows = config.tables.format_on_move and format_table(table_rows) or table_rows
        local ncols = #table_rows.rowdata[tostring(table_rows.metadata.header_row)]
        -- Figure out which cell the cursor is currently in
        local cell = which_cell(table_rows, position[1], col)
        local target_cell = cell_offset + cell
        -- If we want to move forward, but the target cell is greater than the current number of columns
        if cell_offset > 0 and target_cell > ncols then
            if config.tables.auto_extend_cols then
                M.addCol()
                M.moveToCell(row_offset, cell_offset)
            else
                local quotient = math.floor(target_cell / ncols)
                row_offset, cell_offset = row_offset + quotient, (ncols - cell_offset) * -1
                M.moveToCell(row_offset, cell_offset)
            end
        elseif cell_offset < 0 and target_cell < 1 then
            local quotient = math.abs(math.floor(target_cell - 1 / ncols))
            row_offset, cell_offset = row_offset - quotient, target_cell + (ncols * quotient) - 1
            M.moveToCell(row_offset, cell_offset)
        else
            vim.api.nvim_win_set_cursor(
                0,
                { row, table_rows.rowdata[tostring(row)][target_cell].start }
            )
        end
    else
        if position[1] == row then
            vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes('<C-I>', true, false, true),
                'n',
                true
            )
        elseif row_offset == 1 and cell_offset == 0 then -- If moving to the next row
            if config.tables.auto_extend_rows then
                M.addRow()
                M.moveToCell(1, 0)
            else
                -- Create new line if needed
                if vim.api.nvim_buf_line_count(0) == position[1] then
                    vim.api.nvim_buf_set_lines(0, position[1] + 1, position[1] + 1, false, { '' })
                end
                -- Format the table
                if config.tables.format_on_move then
                    format_table(ingest_table(row - 1))
                end
                -- Move cursor to next line
                vim.api.nvim_win_set_cursor(0, { position[1] + 1, 1 })
            end
        end
    end
end

M.addRow = function(offset)
    offset = offset or 0
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row = cursor[1] + offset
    local line = vim.api.nvim_buf_get_lines(0, cursor[1] - 1, cursor[1], false)[1]
    if M.isPartOfTable(line) then
        line = line:gsub('\\|', '  ')
        if utf8_available then
            local utf8 = require('lua-utf8')
            local newline = ''
            for i = 1, #line, 1 do
                local char = utf8.sub(line, i, i)
                if char:match('[^|]') then
                    local char_width = utf8.width(char)
                    newline = newline .. string.rep(' ', char_width)
                else
                    newline = newline .. char
                end
            end
            line = newline
        else
            line = line:gsub('[^|]', ' ')
        end
        vim.api.nvim_buf_set_lines(0, row, row, false, { line })
    end
end

M.addCol = function(offset)
    local line = vim.api.nvim_get_current_line()
    if M.isPartOfTable(line) then
        offset = offset or 0
        local cursor = vim.api.nvim_win_get_cursor(0)
        local table_data = ingest_table(cursor[1])
        local cell = which_cell(table_data, cursor[1], cursor[2]) + offset
        for row, rowdata in pairs(table_data.rowdata) do
            -- Get header row
            local midrule_row = table_data.metadata.midrule_row
            local replacement = (tonumber(row) == midrule_row and ' - |') or '   |'
            -- Add a cell to each row
            if cell > 0 then
                vim.api.nvim_buf_set_text(
                    0,
                    tonumber(row) - 1,
                    rowdata[cell].finish,
                    tonumber(row - 1),
                    rowdata[cell].finish,
                    { replacement }
                )
            else
                vim.api.nvim_buf_set_text(
                    0,
                    tonumber(row) - 1,
                    1,
                    tonumber(row - 1),
                    1,
                    { replacement }
                )
            end
        end
    end
end

return M
