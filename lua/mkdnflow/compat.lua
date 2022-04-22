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

local M = {}

local buffers = require('mkdnflow.buffers')

M.goBack = function()
    buffers.goBack()
    print("⬇️ : WARNING - files.lua in mkdnflow is deprecated. Please replace any references to `files` in your config with references to `buffers` (e.g. change `require('mkdnflow').files.goBack()` to `require('mkdnflow').buffers.goBack()`).")
end

M.goForward = function()
    buffers.goForward()
    print("⬇️ : WARNING - files.lua in mkdnflow is deprecated. Please replace any references to `files` in your config with references to `buffers` (e.g. change `require('mkdnflow').files.goForward()` to `require('mkdnflow').buffers.goForward()`).")
end

return M
