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

--- blink.cmp source adapter for mkdnflow completion.
--- Implements the blink source interface: https://cmp.saghen.dev/development/source-boilerplate
---@class MkdnflowBlinkSource
local source = {}

function source.new(opts)
    return setmetatable({}, { __index = source })
end

--- Check mkdnflow is initialized and completion is enabled.
--- `require('mkdnflow').loaded` is `true` after activate(),
--- `nil` before setup or when no markdown buffer has been opened.
--- Also respects `modules.completion = false` (explicit disable).
function source:enabled()
    local ok, mkdn = pcall(require, 'mkdnflow')
    if not ok or mkdn.loaded ~= true then
        return false
    end
    return mkdn.config.modules.completion ~= false
end

--- blink needs '@' explicitly because unlike nvim-cmp, blink only triggers
--- on declared trigger characters for non-keyword chars.
function source:get_trigger_characters()
    return { '@', '^', '#' }
end

--- Translate blink context to engine-agnostic context and delegate to core.
---@param ctx table blink.cmp context: { line, cursor = {row_1, col_0}, bufnr }
---@param callback fun(result: table) blink callback with { items, is_incomplete_forward, is_incomplete_backward }
function source:get_completions(ctx, callback)
    -- Guard against pre-setup race (blink may call before enabled() is checked)
    if not self:enabled() then
        callback({ items = {}, is_incomplete_forward = false, is_incomplete_backward = false })
        return
    end
    local core_ctx = {
        line_before_cursor = ctx.line:sub(1, ctx.cursor[2]),
        line_after_cursor = ctx.line:sub(ctx.cursor[2] + 1),
        cursor_row_0 = ctx.cursor[1] - 1,
    }
    completion.complete(core_ctx, function(items)
        callback({
            items = items,
            is_incomplete_forward = false,
            is_incomplete_backward = false,
        })
    end)
end

return source
