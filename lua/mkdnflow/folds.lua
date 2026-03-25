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
local utils = require('mkdnflow.utils')

--- Check if the current window's foldmethod allows manual fold creation
---@return boolean
---@private
local function can_create_manual_folds()
    local foldmethod = vim.wo.foldmethod
    return foldmethod == 'manual' or foldmethod == 'marker'
end

--- Get the row range of a markdown section (from heading to next same-or-higher-level heading)
---@param start_row? integer The 1-indexed row of the heading (defaults to cursor row)
---@return integer[]|nil range A two-element array {start_row, end_row}, or nil if not on a heading
---@private
local get_section_range = function(start_row)
    start_row = start_row or vim.api.nvim_win_get_cursor(0)[1]
    local line, n_lines =
        vim.api.nvim_buf_get_lines(0, start_row - 1, start_row, false)[1],
        vim.api.nvim_buf_line_count(0)
    local heading_level = utils.getHeadingLevel(line)
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

--- Find the nearest heading above the cursor position
---@return integer|nil row The 1-indexed row of the nearest heading, or nil if none found
---@private
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

--- Fold the current markdown section, replacing any stale fold with a fresh one
--- If on a heading, folds the entire section. If inside a section, finds the nearest heading first.
--- Deletes any existing fold before creating a new one to prevent stacking (#162) and ensure
--- the fold range always reflects the current content.
M.foldSection = function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    -- If the fold is already closed, nothing to do (unfoldSection handles opening)
    if vim.fn.foldclosed(row) ~= -1 then
        return
    end
    -- Check if foldmethod allows manual fold creation
    if not can_create_manual_folds() then
        if not require('mkdnflow').config.silent then
            vim.notify(
                "⬇️  Cannot create fold: 'foldmethod' must be 'manual' or 'marker'",
                vim.log.levels.WARN
            )
        end
        return
    end
    -- Compute the section range
    local line = vim.api.nvim_get_current_line()
    local in_fenced_code_block = utils.cursorInCodeBlock(row)
    local range
    if M.getHeadingLevel(line) < 99 and not in_fenced_code_block then
        range = get_section_range()
    else
        local start_row = get_nearest_heading()
        if start_row then
            range = get_section_range(start_row)
        end
    end
    if range then
        -- Delete any existing fold at the range start to prevent stacking and stale ranges
        if vim.fn.foldlevel(range[1]) > 0 then
            vim.api.nvim_win_set_cursor(0, { range[1], 0 })
            pcall(function()
                vim.cmd('normal! zd')
            end)
            vim.api.nvim_win_set_cursor(0, { row, 0 })
        end
        vim.cmd(tostring(range[1]) .. ',' .. tostring(range[2]) .. 'fold')
    end
end

--- Unfold the section at the given row (or cursor position)
---@param row? integer The 1-indexed row to unfold (defaults to cursor row)
M.unfoldSection = function(row)
    row = row or vim.api.nvim_win_get_cursor(0)[1]
    -- If the cursor is on a closed fold, open the fold.
    if vim.fn.foldlevel(row) > 0 then
        vim.cmd.foldopen()
    end
end

return M
