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

-- File and link navigation functions
local M = {}

--[[
toggleToDo() retrieves a line when called, checks if it has a to-do item with
[ ], [-], or [X], and changes the completion status to the next in line.
--]]
M.toggleToDo = function()
    -- Get the line the cursor is on
    local line = vim.api.nvim_get_current_line()
    local position = vim.api.nvim_win_get_cursor(0)
    local row = position[1]
    -- See if pattern is matched
    local pattern = '^%s*[*-]%s+%[([ -X])%]%s+'
    local todo = string.match(line, pattern, nil)
    -- If it is, do the replacement with the next completion status
    if todo then
        if todo == ' ' then
            local com, fin = string.find(line, '%['..' '..'%]')
            vim.api.nvim_buf_set_text(0, row - 1, com, row - 1, fin - 1, {'-'})
        elseif todo == '-' then
            local com, fin = string.find(line, '%['..'%-'..'%]')
            vim.api.nvim_buf_set_text(0, row - 1, com, row - 1, fin - 1, {'X'})
        elseif todo == 'X' then
            local com, fin = string.find(line, '%['..'X'..'%]')
            vim.api.nvim_buf_set_text(0, row - 1, com, row - 1, fin - 1, {' '})
        end
    else
        print('⬇️  Not a to-do list item!')
    end
end

return M
