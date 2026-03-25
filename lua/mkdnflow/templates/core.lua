-- mkdnflow.nvim (Tools for fluent markdown notebook navigation and management)
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
--
-- This module: Template formatting and injection for new files

local function mkdn()
    return require('mkdnflow')
end
local function cfg()
    return mkdn().config
end

local M = {}

--- Find the nearest heading above the cursor, skipping headings inside fenced code blocks.
---@return string heading_text The heading text (without # prefix), or '' if none found
---@private
local function get_heading_context()
    local utils = require('mkdnflow.utils')
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local in_fenced_code_block = utils.cursorInCodeBlock(row)
    row = row - 1
    while row > 0 do
        local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
        if line:find('^```') then
            in_fenced_code_block = not in_fenced_code_block
        end
        if utils.getHeadingLevel(line) < 99 and not in_fenced_code_block then
            return line:match('^%s*#+%s*(.*)') or ''
        end
        row = row - 1
    end
    return ''
end

--- Fill in placeholders in the new-file template string.
--- All placeholders are resolved in a single pass before the buffer switch.
---@param timing? string Kept for API compat; no longer affects behavior
---@param template? string The template string to fill (defaults to config template)
---@param opts? {target_path?: string} Options; target_path is used for the filename ctx field
---@return string template The template with placeholders replaced
M.formatTemplate = function(timing, template, opts)
    opts = opts or {}
    local new_file_config = cfg().new_file_template
    local links = mkdn().links
    template = template or new_file_config.template
    -- Build context table with all resolved built-in values
    local link_under_cursor = links.getLinkUnderCursor()
    local ctx = {
        link_title = links.getLinkPart(link_under_cursor, 'name') or '',
        os_date = os.date('%Y-%m-%d'),
        source_file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':t'),
        filename = opts.target_path and vim.fn.fnamemodify(opts.target_path, ':t:r')
            or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':t:r'),
        heading_context = get_heading_context(),
    }
    for placeholder_name, value in pairs(new_file_config.placeholders) do
        local replacement
        if type(value) == 'function' then
            replacement = value(ctx)
        elseif ctx[value] ~= nil then
            -- Magic string shorthand: 'link_title', 'os_date', etc.
            replacement = ctx[value]
        else
            -- Plain string literal (e.g., author = 'Jake')
            replacement = value
        end
        replacement = replacement ~= nil and tostring(replacement) or ''
        template = string.gsub(template, '{{%s?' .. placeholder_name .. '%s?}}', replacement)
    end
    return template
end

--- Inject a formatted template into the current (newly created) buffer.
---@param template string The pre-formatted template string (output of formatTemplate())
M.apply = function(template)
    local lines = vim.split(template, '\n', { plain = true })
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

return M
