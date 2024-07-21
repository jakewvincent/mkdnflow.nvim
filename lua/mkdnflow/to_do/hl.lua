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

--- Table to keep track of match IDs generated (for the purpose of clearing them later)
local match_ids = {}

--- Function to create highlight groups
--- @param to_do_statuses table[] A table of to-do status tables (from the config)
local function set_highlights(to_do_statuses)
    for _, status in ipairs(to_do_statuses) do
        if status.colors.marker then
            vim.api.nvim_set_hl(0, string.format('MkdnflowToDoMarker%s', status.name:pascal()),
                status.colors.marker)
        end
        if status.colors.content then
            vim.api.nvim_set_hl(0, string.format('MkdnflowToDoContent%s', status.name:pascal()),
                status.colors.content)
        end
    end
end

--- Function to clear existing matches
local function clear_syntax_matches()
    for _, id in ipairs(match_ids) do
        vim.fn.matchdelete(id)
    end
    match_ids = {}
end

--- Function to perform highlighting on matches
local function highlight_to_dos()
    local statuses = require('mkdnflow').config.to_do.statuses
    set_highlights(statuses)
    clear_syntax_matches()
    for _, status in ipairs(statuses) do
        -- Marker highlighting
        local marker_pattern = string.format(
            '\\v(^[ \\t]*[-*+]\\s+)\\zs\\[%s\\]\\ze',
            status:get_symbol(), status:get_symbol()
        )
        local marker_id = vim.fn.matchadd(
            string.format('MkdnflowToDoMarker%s', status.name:pascal()),
            marker_pattern
        )
        -- Content highlighting
        local content_pattern = string.format(
            '\\v(^[ \\t]*[-*+]\\s+\\[%s\\]\\s+\\zs.+)',
            status:get_symbol()
        )
        local content_id = vim.fn.matchadd(
            string.format('MkdnflowToDoContent%s', status.name:pascal()),
            content_pattern
        )
        -- Save the match IDs
        table.insert(match_ids, marker_id)
        table.insert(match_ids, content_id)
    end
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
