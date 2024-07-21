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
    return str:gsub('[_ ](.)', function(char) return char:upper() end):gsub('^%l', string.upper)
end

local M = {}

local match_ids = {}

M.set_highlights = function(to_do_statuses)
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

local function clear_syntax_matches()
    for _, id in ipairs(match_ids) do
        vim.fn.matchdelete(id)
    end
    match_ids = {}
end

function M.highlight_to_dos()
    local statuses = require('mkdnflow').config.to_do.statuses
    M.set_highlights(statuses)
    clear_syntax_matches()
    for _, status in ipairs(statuses) do
        local marker_pattern = string.format('\\v(^[ \\t]*[-*+]\\s+)\\zs\\[%s\\]\\ze',
            status:get_symbol(), status:get_symbol())
        local content_pattern = string.format('\\v(^[ \\t]*[-*+]\\s+\\[%s\\]\\s+\\zs.+)',
            status:get_symbol())
        local marker_id = vim.fn.matchadd(string.format('MkdnflowToDoMarker%s', status.name:pascal()),
            marker_pattern)
        local content_id = vim.fn.matchadd(string.format('MkdnflowToDoContent%s', status.name:pascal()),
            content_pattern)
        table.insert(match_ids, marker_id)
        table.insert(match_ids, content_id)
    end
end

function M.init()
    local todo_augroup = vim.api.nvim_create_augroup('MkdnflowToDoStatuses', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
        pattern = 'markdown',
        callback = function()
            M.highlight_to_dos()
        end,
        group = todo_augroup,
    })
    vim.api.nvim_create_autocmd('BufWritePost', {
        -- TODO: Use filetypes provided in config here
        pattern = '*.md',
        callback = function()
            M.highlight_to_dos()
        end,
        group = todo_augroup,
    })
end

return M
