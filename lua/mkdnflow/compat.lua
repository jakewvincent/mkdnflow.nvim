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

local buffers = require('mkdnflow.buffers')
local init = require('mkdnflow.init')

local M = {}

M.goBack = function()
    -- TODO: Remove this function in June 2022
    buffers.goBack()
    print("⬇️ : Friendly warning - references to files.lua will soon stop working. See :h mkdnflow-changes, commit 511e8e...")
end

M.goForward = function()
    -- TODO: Remove this function in June 2022
    buffers.goForward()
    print("⬇️ : Friendly warning - references to files.lua will soon stop working. See :h mkdnflow-changes, commit 511e8e...")
end

M.userConfigCheck = function(user_config)
    if user_config.links_relative_to then
        if type(user_config.links_relative_to) ~= 'table' then
            print('⬇️ : Friendly warning - the links_relative_to key in the table passed to the setup function should now be associated with a table value. See :h mkdnflow-changes, commit 75c8ec...')
            if user_config.links_relative_to == 'current' then
                local table = {
                    target = 'current',
                    fallback = 'first'
                }
                user_config.links_relative_to = table
            elseif user_config.links_relative_to == 'first' then
                local table = {
                    target = 'first',
                    fallback = 'current'
                }
                user_config.links_relative_to = table
            end
        end
    end
    return(user_config)
end

return M
