-- mkdnflow.nvim (Tools for personal markdown notebook navigation and management)
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

local init = {}

-- Get first opened file/buffer path and directory
init.initial_buf = vim.api.nvim_buf_get_name(0)
init.initial_dir = init.initial_buf:match('(.*)/.-')

-- Final config table (where defaults and user-provided config will be combined)
init.config = {
    default_mappings = true,
    create_dirs = true,
    links_relative_to = 'first', -- other option: current
    filetypes = {md = true, rmd = true, markdown = true},
    new_file_prefix = [[os.date('%Y-%m-%d_')]],
    evaluate_prefix = true,
    load_tests = false,
    wrap_to_beginning = false,
    wrap_to_end = false,
    default_bib_path = nil,
    bib_refresh_trigger = 'init'
}

init.loaded = nil

-- Private function to detect the file's extension
local getFileType = function()
    local ext = init.initial_buf:match("^.*%.(.+)$")
    return(ext ~= nil and string.lower(ext) or '')
end

init.setup = function(user_config)

    -- Record the user's config
    for key, _ in pairs(user_config) do
        -- This loop won't run if no config is provided, but the rest of the
        -- setup will still run.
        init.config[key] = user_config[key]
    end

    -- Get the extension of the file being edited
    local ft = getFileType()

    -- Load the extension if the filetype has a match in config.filetypes
    if init.config.filetypes[ft] then

        -- Record load status (i.e. loaded)
        init.loaded = true

        -- Load functions
        init.cursor = require('mkdnflow.cursor')
        init.files = require('mkdnflow.files')

        -- Only load the mappings if the user hasn't said "no"
        if init.config.default_mappings == true then
            require('mkdnflow.maps')
        end

        -- Only load tests if the user has said yes
        if init.config.load_tests == true then
            init.tests = require('mkdnflow.tests')
        end

    else
        -- Record load status (i.e. not loaded)
        init.loaded = false
    end

end

init.forceStart = function()
    if init.loaded == true then
        print("MkdnFlow already running!")
    else
        -- Record load status (i.e. loaded)
        init.loaded = true

        -- Load functions
        init.cursor = require('mkdnflow.cursor')
        init.files = require('mkdnflow.files')

        -- Only load the mappings if the user hasn't said "no"
        if init.config.default_mappings == true then
            require('mkdnflow.maps')
        end

        -- Only load tests if the user has said yes
        if init.config.load_tests == true then
            init.tests = require('mkdnflow.tests')
        end
    end
end

return init
