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

--- Add a method to the `string` class to turn a string into a Pascal-cased string
--- @param str string A string to convert
--- @return string
function string.pascal(str)
    return str:gsub('[_ ](.)', function(char)
        return char:upper()
    end):gsub('^%l', string.upper)
end

--- Function to create highlight groups
--- @param to_do_statuses table[] A table of to-do status tables (from the config)
local function set_highlights(to_do_statuses)
    for _, status in ipairs(to_do_statuses) do
        if status.highlight.marker then
            vim.api.nvim_set_hl(
                0,
                string.format('MkdnflowToDoMarker%s', status.name:pascal()),
                status.highlight.marker
            )
        end
        if status.highlight.content then
            vim.api.nvim_set_hl(
                0,
                string.format('MkdnflowToDoContent%s', status.name:pascal()),
                status.highlight.content
            )
        end
    end
end

--- Clear all previously added to-do syntax matches in the current window
---@private
local function clear_syntax_matches()
    local ids = vim.w.mkdnflow_todo_match_ids or {}
    for _, id in ipairs(ids) do
        vim.fn.matchdelete(id)
    end
    vim.w.mkdnflow_todo_match_ids = nil
end

--- Apply syntax highlighting to to-do items based on their status
---@private
local function highlight_to_dos()
    local statuses = require('mkdnflow').config.to_do.statuses
    set_highlights(statuses)
    clear_syntax_matches()
    local ids = {}
    for _, status in ipairs(statuses) do
        -- Marker highlighting
        local marker_pattern = string.format(
            '\\v(^[ \\t]*[-*+]\\s+)\\zs\\[%s\\]\\ze',
            status:get_marker(),
            status:get_marker()
        )
        local marker_id = vim.fn.matchadd(
            string.format('MkdnflowToDoMarker%s', status.name:pascal()),
            marker_pattern
        )
        -- Content highlighting
        local content_pattern =
            string.format('\\v(^[ \\t]*[-*+]\\s+\\[%s\\]\\s+\\zs.+)', status:get_marker())
        local content_id = vim.fn.matchadd(
            string.format('MkdnflowToDoContent%s', status.name:pascal()),
            content_pattern
        )
        -- Save the match IDs
        table.insert(ids, marker_id)
        table.insert(ids, content_id)
    end
    vim.w.mkdnflow_todo_match_ids = ids
end

local M = {}

--- Function to initialize highlighting
function M.init()
    local todo_augroup = vim.api.nvim_create_augroup('MkdnflowToDoStatuses', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
        pattern = 'markdown',
        callback = function()
            highlight_to_dos()
        end,
        group = todo_augroup,
    })
end

return M
