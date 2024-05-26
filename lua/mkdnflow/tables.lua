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
local sep_padding, cell_padding =
    string.rep(' ', config.tables.style.separator_padding or 1),
    string.rep(' ', config.tables.style.cell_padding or 1)

table.unpack = table.unpack or unpack -- 5.1 compatibility

local M = {}

local width = vim.api.nvim_strwidth

local has_outer_pipes = function(line)
    local result, side = false, nil
    if line:match('^|.*|%s*$') then
        result, side = true, 'both'
    elseif line:match('^%s*|.*[^|]$') then
        result, side = true, 'left'
    elseif line:match('^%s*[^|].*|%s*$') then
        result, side = true, 'right'
    end
    return result, side
end

local is_separator_row = function(line)
    local outer_pipes, location = has_outer_pipes(line)
    local pattern = (outer_pipes and location == 'both' and '^|[| %-:]+|%s*$')
        or (outer_pipes and location == 'left' and '^|[| %-:]+$')
        or (outer_pipes and location == 'right' and '^[| %-:]+|%s*$')
        or '^[^|][| %-:]+[^|]$'
    local result = false
    if line:match(pattern) and line:match('%-+') then
        result = true
    end
    return result
end

local read_col_alignments = function(row_data)
    local col_alignments = {}
    for _, value in ipairs(row_data) do
        if value:match('^%s*:%-*:%s*$') then
            table.insert(col_alignments, 'center')
        elseif value:match('^%s*:%-*%s*$') then
            table.insert(col_alignments, 'left')
        elseif value:match('^%s*%-*:%s*') then
            table.insert(col_alignments, 'right')
        else
            table.insert(col_alignments, 'default')
        end
    end
    return col_alignments
end

local read_celldata_from_row = function(row)
    -- Temporarily replace escaped bars
    row = row:gsub('\\|', 'U%+007C')
    local cells = {}
    local max = 0
    for match in string.gmatch(row, '([^|]+)') do
        max = max + 1
        -- Replace escaped bars back to their original form; strip whitespace around cell data
        local cell = match:gsub('U%+007C', '\\|'):gsub('^%s*', ''):gsub('%s*$', '')
        table.insert(cells, cell)
    end
    -- The last match is stuff following the table, unless the table is the kind w/o outer pipes;
    -- store this stuff under a key, separately from the rest
    --if row:match('^|.-|$') then
    --    cells['after'] = cells[max]
    --    table.remove(cells, max)
    --end
    return cells
end

local max_cols = function(list)
    local col_counts = {}
    for _, row in pairs(list) do
        table.insert(col_counts, #row)
    end
    return math.max(table.unpack(col_counts))
end

local equalize_rows = function(rowdata)
    local target_cols = max_cols(rowdata)
    for _, v in pairs(rowdata) do
        while #v < target_cols do
            table.insert(v, '')
        end
    end
end

local read_table = function(rownr)
    -- Get the table text
    rownr = rownr or vim.api.nvim_win_get_cursor(0)[1]
    local init_rownr = rownr
    local line = vim.api.nvim_buf_get_lines(0, rownr - 1, rownr, false)[1]
    local i, table_rows = 1, { rowdata = {}, metadata = {}, raw = {} }
    while M.isPartOfTable(line) do
        table_rows.rowdata[rownr] = read_celldata_from_row(line)
        table_rows.raw[rownr] = line
        -- Midrule row needs at least one hyphen & should only have bars, spaces, dashes, and colons
        if is_separator_row(line) then
            table_rows.metadata.midrule_row = rownr
        end
        -- Increment by 1 or -1
        rownr = rownr + i
        line = vim.api.nvim_buf_get_lines(0, rownr - 1, rownr, false)[1]
        if i == 1 and not M.isPartOfTable(line) then
            -- Flip i to -1 and start looking in the other direction
            rownr = init_rownr - 1
            i = -1
            line = vim.api.nvim_buf_get_lines(0, rownr - 1, rownr, false)[1]
        end
        if i == -1 and not M.isPartOfTable(line) then
            table_rows.metadata.header_row = rownr - i
        end
    end
    -- Add in cell alignments
    if table_rows.metadata.midrule_row then
        table_rows.metadata.col_alignments =
            read_col_alignments(table_rows.rowdata[table_rows.metadata.midrule_row])
    end
    equalize_rows(table_rows.rowdata)
    return table_rows
end

local ncol = function(rowdata)
    local cols = {}
    if rowdata then
        for _, row in utils.spairs(rowdata) do
            if not utils.inTable(#row, cols) then
                table.insert(cols, #row)
            end
        end
    end
    return cols
end

local get_max_lengths = function(table_data)
    local max_lengths = {}
    local cols = ncol(table_data.rowdata)
    -- Start each at 3
    for i = 1, cols[1] do
        max_lengths[i] = 3
    end
    -- Go through and check lengths of each cell in each col
    for linenr, row in utils.spairs(table_data.rowdata) do
        if linenr ~= table_data.metadata.midrule_row then
            for colnr, content in ipairs(row) do
                max_lengths[colnr] = width(content) > max_lengths[colnr] and width(content)
                    or max_lengths[colnr]
            end
        end
    end
    return max_lengths
end

M.isPartOfTable = function(text, linenr)
    local tableyness = 0
    -- Start by just looking for a single pipe in the line
    if text and text:match('^.+|.+$') then
        tableyness = tableyness + 1
        -- Do some more thorough checks; look up and down if we have linenr
        if linenr then
            local above, below =
                vim.api.nvim_buf_get_lines(0, linenr, linenr + 1, false),
                vim.api.nvim_buf_get_lines(0, linenr - 2, linenr - 1, false)
            above = above and above[1] or ''
            below = below and below[1] or ''
            for _, line in ipairs({ above, text, below }) do
                tableyness = tableyness + (line:match('^.+|.+$') and 1 or 0)
                tableyness = tableyness + (line:match('^%s*|.+|%s*$') and 1 or 0)
                tableyness = tableyness + (line:match('^|.+|$') and 1 or 0)
            end
        else
            tableyness = tableyness + (text:match('^.+|.+$') and 1 or 0)
            tableyness = tableyness + (text:match('^%s*|.+|%s*$') and 1 or 0)
            tableyness = tableyness + (text:match('^|.+|$') and 1 or 0)
        end
    end
    if tableyness >= 2 then
        return true
    else
        return false
    end
end

M.newTable = function(opts)
    local cols, rows, header = opts[1], opts[2], opts[3]
    local min_width =
        math.max(#(sep_padding .. '---' .. sep_padding), #(cell_padding .. cell_padding))
    cols, rows = tonumber(cols), tonumber(rows)
    if header and header:match('noh') then
        header = false
    else
        header = true
    end
    local cursor = vim.api.nvim_win_get_cursor(0)
    -- Starting points
    local table_row = config.tables.style.outer_pipes and '|' or ''
    local divider_row = config.tables.style.outer_pipes and '|' or ''
    local new_cell = cell_padding .. string.rep(' ', min_width - 2 * #cell_padding) .. cell_padding
    local new_divider = sep_padding .. string.rep('-', min_width - 2 * #sep_padding) .. sep_padding
    -- Make a prototypical row
    for i = 1, cols, 1 do
        table_row = table_row
            .. new_cell
            .. ((i < cols and '|') or (config.tables.style.outer_pipes and '|') or '')
    end
    if header then
        for i = 1, cols, 1 do
            divider_row = divider_row
                .. new_divider
                .. ((i < cols and '|') or (config.tables.style.outer_pipes and '|') or '')
        end
    end
    local new_rows = {}
    -- Make the rows
    table.insert(new_rows, table_row)
    if header then
        table.insert(new_rows, divider_row)
        for _ = 1, rows, 1 do
            table.insert(new_rows, table_row)
        end
    else
        for _ = 2, rows, 1 do
            table.insert(new_rows, table_row)
        end
    end
    vim.api.nvim_buf_set_lines(0, cursor[1], cursor[1], false, new_rows)
end

local format_table = function(table_data)
    local max_lengths, outer_pipes = get_max_lengths(table_data), config.tables.style.outer_pipes
    local new_lines = {}
    local start, finish
    for linenr, row_data in utils.spairs(table_data.rowdata) do
        -- Assign current linenr on the first iteration
        start = start == nil and linenr or start
        -- Assign current linenr if nil or greater than current value
        finish = (finish == nil and linenr) or (linenr > finish and linenr) or finish
        local new_line = ''
        -- Special formatting for the separator row
        if linenr == table_data.metadata.midrule_row then
            local diff = #cell_padding - #sep_padding
            for idx, value in ipairs(table_data.metadata.col_alignments) do
                local end_sep = idx == #row_data and '' or '|'
                local aligned_value
                if value == 'left' then
                    aligned_value = ':' .. string.rep('-', max_lengths[idx] - 1 + 2 * diff)
                elseif value == 'right' then
                    aligned_value = string.rep('-', max_lengths[idx] - 1 + 2 * diff) .. ':'
                elseif value == 'center' then
                    aligned_value = ':' .. string.rep('-', max_lengths[idx] - 2 + 2 * diff) .. ':'
                elseif value == 'default' then
                    aligned_value = string.rep('-', max_lengths[idx] + 2 * diff)
                end
                new_line = new_line .. sep_padding .. aligned_value .. sep_padding .. end_sep
            end
        else
            for idx = 1, max_cols(table_data.rowdata), 1 do
                local value = row_data[idx] or ''
                local diff = max_lengths[idx] - width(value)
                local aligned_value
                local end_sep = idx == #row_data and '' or '|'
                if
                    table_data.metadata.col_alignments[idx] == 'right'
                    and config.tables.style.mimic_alignment
                then
                    aligned_value = string.rep(' ', diff) .. value
                    new_line = new_line .. cell_padding .. aligned_value .. cell_padding .. end_sep
                elseif
                    table_data.metadata.col_alignments[idx] == 'center'
                    and config.tables.style.mimic_alignment
                then
                    local left_fill = string.rep(' ', math.floor(diff / 2))
                    local right_fill = string.rep(' ', diff - #left_fill)
                    aligned_value = left_fill .. value .. right_fill
                    new_line = new_line .. cell_padding .. aligned_value .. cell_padding .. end_sep
                else
                    aligned_value = value .. string.rep(' ', diff)
                    new_line = new_line .. cell_padding .. aligned_value .. cell_padding .. end_sep
                end
            end
        end
        -- Append any content that was following the table back onto the line
        new_line = (outer_pipes and '|' or '') .. new_line .. (outer_pipes and '|' or '')
        if row_data['after'] ~= nil and #row_data['after'] > 0 then
            new_line = new_line .. cell_padding .. row_data['after']
        end
        table.insert(new_lines, new_line)
    end
    vim.api.nvim_buf_set_lines(0, start - 1, finish, true, new_lines)
    -- Return a table with linenumber keys and formatted rows
    local idx = 1
    table_data.formatted_rows = {}
    for linenr, _ in utils.spairs(table_data.rowdata) do
        table_data.formatted_rows[linenr] = new_lines[idx]
        idx = idx + 1
    end
    return table_data
end

M.formatTable = function()
    local table_rows = read_table()
    local formatted_tdata = format_table(table_rows)
    if not formatted_tdata then
        if not config.silent then
            vim.api.nvim_echo({
                {
                    '⬇️  Table formatting failed.',
                    'WarningMsg',
                },
            }, true, {})
        end
    end
end

local which_cell = function(row, col)
    -- Figure out which cell the cursor is currently in
    local cursorline = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    cursorline = cursorline:gsub('\\|', '##')
    local init, cell, cursor_cell = 1, 1, nil
    for start, finish in utils.betterGmatch(cursorline, '[^|]+') do
        -- Find the indices of the match
        if col + 1 >= start and col <= finish then
            cursor_cell = cell
        end
        init = finish or init
        cell = cell + 1
    end
    return cursor_cell
end

local locate_cell = function(table_row, target_cellnr, locate_cell_contents)
    locate_cell_contents = locate_cell_contents == nil and true or locate_cell_contents
    local init, cur_cell = 1, 0
    local start, finish
    -- Internally replace any escaped bars
    table_row = table_row:gsub('\\|', '  ')
    for match_start, match_end, match in utils.betterGmatch(table_row, '([^|]+)') do
        cur_cell = cur_cell + 1
        --start, finish = string.find(table_row, match, init, true)
        if cur_cell == target_cellnr then
            -- Get the position of the non-whitespace content
            local content_start, content_end, cell_value = string.find(match, '%s*(.*)%s*')
            -- If the cell is non-empty, find where the content starts
            if cell_value ~= '' and locate_cell_contents then
                match_start, match_end = match_start + content_start, match_start + content_end
            -- Otherwise, assume the cell starts one character after the match
            elseif locate_cell_contents then
                match_start = match_start + 1
            end
            --return start, finish
            return match_start, match_end
        end
        init = finish or init
    end
    return start, finish
end

M.moveToCell = function(row_offset, cell_offset)
    row_offset = row_offset or 0
    cell_offset = cell_offset or 0
    local position = vim.api.nvim_win_get_cursor(0)
    -- Figure out which cell the cursor is currently in
    local cursor_cell = which_cell(position[1], position[2])
    local row = position[1] + row_offset
    local line_count = vim.api.nvim_buf_line_count(0)
    if row > line_count then
        row = line_count
    end
    local target_line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    if is_separator_row(target_line) then
        M.moveToCell(row_offset + (row_offset < 0 and -1 or 1), cell_offset)
    elseif M.isPartOfTable(target_line, row) then
        local table_rows = read_table(row)
        if config.tables.format_on_move then
            table_rows = format_table(table_rows)
            target_line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
        end
        local ncols = ncol(table_rows.rowdata)[1]
        local target_cell = cell_offset + cursor_cell
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
            -- Figure out where the beginning of the cell is
            local cell_start, _ = locate_cell(target_line, target_cell)
            vim.api.nvim_win_set_cursor(0, {
                row,
                cell_start - 1,
            })
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
                    format_table(read_table(row - 1))
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
    if M.isPartOfTable(line, row) then
        -- Ignore escaped bars
        line = line:gsub('\\|', '  ')
        local init, start, finish, new_line = 1, nil, nil, ''
        for match in line:gmatch('([^|]+)', init) do
            start, finish = line:find(match, init, true)
            new_line = new_line .. line:sub(init, start - 1) .. string.rep(' ', width(match))
            init = finish + 1
            --newline = newline .. '|' .. string.rep(' ', width(match))
        end
        new_line = new_line .. line:sub(finish + 1)
        vim.api.nvim_buf_set_lines(0, row, row, false, { new_line })
    end
end

M.addCol = function(offset)
    local line, linenr = vim.api.nvim_get_current_line(), vim.api.nvim_win_get_cursor(0)[1]
    if M.isPartOfTable(line, linenr) then
        -- -1 means insert before current col; 0 means insert after current col
        offset = offset or 0
        local cursor = vim.api.nvim_win_get_cursor(0)
        local table_data, current_col = read_table(cursor[1]), which_cell(cursor[1], cursor[2])
        local midrule_row, ncols = table_data.metadata.midrule_row, ncol(table_data.rowdata)[1]
        local min_width =
            math.max(#(sep_padding .. '---' .. sep_padding), #(cell_padding .. cell_padding))
        local replacements, range_start, range_finish = {}, nil, nil
        for row, row_text in utils.spairs(table_data.raw) do
            range_start = range_start == nil and row or range_start
            range_finish = (range_finish == nil and row) or (row > range_finish and row)
            local pattern
            if offset < 0 then
                if has_outer_pipes(row_text) then
                    pattern = string.rep('|[^|]*', current_col - 1)
                else
                    pattern = '[^|]*' .. string.rep('|[^|]*', current_col - 2)
                end
            else
                if has_outer_pipes(row_text) then
                    pattern = string.rep('|[^|]*', current_col)
                else
                    pattern = '[^|]*' .. string.rep('[^|]*', current_col - 1)
                end
            end
            local new_cell
            if row == midrule_row then
                new_cell = sep_padding
                    .. string.rep('-', min_width - 2 * #sep_padding)
                    .. sep_padding
            else
                new_cell = cell_padding
                    .. string.rep(' ', min_width - 2 * #cell_padding)
                    .. cell_padding
            end
            if
                not (offset < 0 and current_col == 1 and config.tables.style.outer_pipes == false)
            then
                new_cell = '|' .. new_cell
            end
            local _, finish, match
            if pattern == '' then
                finish, match = 0, ''
            else
                _, finish, match = row_text:find('(' .. pattern .. ')')
            end
            -- Insert the new cell in the current row
            local replacement = match .. new_cell .. row_text:sub(finish + 1)
            table.insert(replacements, replacement)
        end
        vim.api.nvim_buf_set_lines(0, range_start - 1, range_finish, true, replacements)
    end
end

return M
