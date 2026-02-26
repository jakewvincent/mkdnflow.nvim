-- mkdnflow.nvim (Tools for personal markdown notebook navigation and management)
-- Copyright (C) 2022-2023 Jake W. Vincent <https://github.com/jakewvincent>
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

local completion = require('mkdnflow.completion')

--- nvim-cmp source adapter for mkdnflow completion.
---@class MkdnflowCmpSource
local source = {}

--- Create a new completion source instance
---@return MkdnflowCmpSource
source.new = function()
    return setmetatable({}, { __index = source })
end

--- Declare characters that should trigger completion.
--- '@' works in nvim-cmp without being declared here; adding it could change
--- offset semantics.
---@return string[]
function source:get_trigger_characters()
    return completion.get_trigger_characters()
end

--- Translate nvim-cmp params to engine-agnostic context and delegate to core.
---@param params table nvim-cmp completion parameters
---@param callback fun(items: table[]) Callback to return completion items
function source:complete(params, callback)
    local ctx = {
        line_before_cursor = params.context.cursor_before_line,
        line_after_cursor = params.context.cursor_after_line or '',
        cursor_row_0 = params.context.cursor and params.context.cursor.line or 0,
    }
    completion.complete(ctx, callback)
end

return source
