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

local silent = require('mkdnflow').config.silent
local perspective = require('mkdnflow').config.perspective

-- Table for global functions and variables
local M = {}

-- Create local tables to keep track of buffers for backward and forward navigation
M.main = {}
M.hist = {}

M.push = function(stack_name, bufnr)
    -- Add the provided buffer number to the first position in the provided
    -- stack, pushing down the others in the provided stack
    table.insert(stack_name, 1, bufnr)
end

M.pop = function(stack_name)
    -- Remove the topmost element in the provided stack
    table.remove(stack_name, 1)
end

--[[
goBack() gets the current buffer number to see if it's greater than 1. If it
is, the current buffer is not the first that was opened, and there is a buffer
to go back to. It gets the previous buffer number from the buffer stack, goes
there, and then pops the top element from the main stack.
--]]
M.goBack = function()
    local cur_bufnr = vim.api.nvim_win_get_buf(0)
    if cur_bufnr > 1 and #M.main > 0 then
        -- Add current buffer number to history
        M.push(M.hist, cur_bufnr)
        -- Get previous buffer number
        local prev_buf = M.main[1]
        -- Go to buffer
        vim.api.nvim_command('buffer ' .. prev_buf)
        -- Pop the buffer we just navigated to off the top of the stack
        M.pop(M.main)
        -- Update the root and/or directory if needed
        require('mkdnflow').paths.updateDirs()
        -- return a boolean if goback succeeded (for users who want <bs> to do
        -- sth else if goback isn't possible)
        return true
    else
        if not silent then
            vim.api.nvim_echo({ { "⬇️  Can't go back any further!", 'WarningMsg' } }, true, {})
        end
        -- Return a boolean if goBack fails
        return false
    end
end

--[[
goForward() looks at the historical buffer stack to see if there's anything to
be navigated to. If there is, it adds the current buffer to the main stack,
goes to the buffer at the top of the history stack, and pops it from the histo-
ry stack. Returns `true` if successful, `false` if it fails.
--]]
M.goForward = function()
    -- Get current buffer number
    local cur_bufnr = vim.api.nvim_win_get_buf(0)
    -- Get historical buffer number
    local hist_bufnr = M.hist[1]
    -- If there is a buffer number in the history stack, do the following; if
    -- not, print a warning
    if hist_bufnr then
        M.push(M.main, cur_bufnr)
        -- Go to the historical buffer number
        vim.api.nvim_command('buffer ' .. hist_bufnr)
        -- Pop historical buffer stack
        M.pop(M.hist)
        -- Update the root and/or working directory if needed
        require('mkdnflow').paths.updateDirs()
        -- Return a boolean if goForward succeeded (for users who want <Del> to
        -- do sth else if goForward isn't possible)
        return true
    else
        -- Print out an error if there's nothing in the historical buffer stack
        if not silent then
            vim.api.nvim_echo(
                { { "⬇️  Can't go forward any further!", 'WarningMsg' } },
                true,
                {}
            )
        end
        -- Return a boolean if goForward failed (for users who want <Del> to do
        -- sth else if goForward isn't possible)
        return false
    end
end

return M
