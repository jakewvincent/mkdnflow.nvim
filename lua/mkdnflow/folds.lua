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
local utils = require('mkdnflow').utils

M.getHeadingLevel = function(line)
    local level
    if line then
        level = line:match('^%s-(#+)')
    end
    return (level and string.len(level)) or 99
end

local get_section_range = function(start_row)
    start_row = start_row or vim.api.nvim_win_get_cursor(0)[1]
    local line, n_lines =
        vim.api.nvim_buf_get_lines(0, start_row - 1, start_row, false)[1],
        vim.api.nvim_buf_line_count(0)
    local heading_level = M.getHeadingLevel(line)
    if heading_level > 0 then
        local continue, in_fenced_code_block = true, utils.cursorInCodeBlock(start_row)
        local end_row = start_row + 1
        while continue do
            local next_line = vim.api.nvim_buf_get_lines(0, end_row - 1, end_row, false)
            if next_line[1] then
                if string.find(next_line[1], '^```') then
                    -- Flip the truth value
                    in_fenced_code_block = not in_fenced_code_block
                end
                if
                    M.getHeadingLevel(next_line[1]) <= heading_level and not in_fenced_code_block
                then
                    continue = false
                else
                    end_row = end_row + 1
                end
            elseif end_row <= n_lines then -- Line might just be empty; make sure we're not at end of buffer
                end_row = end_row + 1
            else -- End of buffer reached
                continue = false
            end
        end
        return { start_row, end_row - 1 }
    end
end

local get_nearest_heading = function()
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local continue, in_fenced_code_block = true, utils.cursorInCodeBlock(row)
    while continue and row > 0 do
        local prev_line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
        if string.find(prev_line, '^```') then
            -- Flip the truth value
            in_fenced_code_block = not in_fenced_code_block
        end
        if M.getHeadingLevel(prev_line) < 99 and not in_fenced_code_block then
            continue = false
            return row
        else
            row = row - 1
        end
    end
end

M.foldSection = function()
    local row, line = vim.api.nvim_win_get_cursor(0)[1], vim.api.nvim_get_current_line()
    -- See if the cursor is in an open fold. If so, and if it is not also on a heading, close the
    -- open fold.
    if vim.fn.foldlevel(row) > 0 and not (M.getHeadingLevel(line) < 99) then
        vim.cmd.foldclose()
    else -- Otherwise, create a fold
        local in_fenced_code_block = utils.cursorInCodeBlock(row)
        -- See if the cursor is on a heading
        if M.getHeadingLevel(line) < 99 and not in_fenced_code_block then
            local range = get_section_range()
            if range then
                vim.cmd(tostring(range[1]) .. ',' .. tostring(range[2]) .. 'fold')
            end
        else -- The cursor isn't on a heading, so find what the range of the fold should be
            local start_row = get_nearest_heading()
            if start_row then
                local range = get_section_range(start_row)
                if range then
                    vim.cmd(tostring(range[1]) .. ',' .. tostring(range[2]) .. 'fold')
                end
            end
        end
    end
end

M.unfoldSection = function(row)
    row = row or vim.api.nvim_win_get_cursor(0)[1]
    -- If the cursor is on a closed fold, open the fold.
    if vim.fn.foldlevel(row) > 0 then
        vim.cmd.foldopen()
    end
end

return M
