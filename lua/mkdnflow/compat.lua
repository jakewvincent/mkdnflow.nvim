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

--[[
goBack() calls the version of goBack() in the buffers module. This is here so
that anyone calling goBack from the old files module will still have functiona-
lity. (The compat module is called as files in init.lua.)
TODO: Remove this function in June 2022
--]]
M.goBack = function()
    buffers.goBack()
    print("⬇️ : Friendly warning - references to files.lua will soon stop working. See :h mkdnflow-changes, commit 511e8e...")
end

--[[
goForward() calls the version of goForward() in the buffers module. This is
here so that anyone calling goForward from the old files module will still have
functionality. (The compat module is called as files in init.lua.)
TODO: Remove this function in June 2022
--]]
M.goForward = function()
    buffers.goForward()
    print("⬇️ : Friendly warning - references to files.lua will soon stop working. See :h mkdnflow-changes, commit 511e8e...")
end

--[[
userConfigCheck() will check a user config for particular settings that have
since been migrated to another setting or another format. It returns an equiva-
lent user config that is upgraded to the new format.
--]]
M.userConfigCheck = function(user_config)
    -- Inspect links_relative_to setting, if specified
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
