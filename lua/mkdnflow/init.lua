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

-- Default config table (where defaults and user-provided config will be combined)
local default_config = {
    create_dirs = true,
    links_relative_to = {
        target = 'first',
        fallback = 'current',
        root_tell = false
    },
    filetypes = {
        md = true,
        rmd = true,
        markdown = true
    },
    new_file_prefix = [[os.date('%Y-%m-%d_')]],
    evaluate_prefix = true,
    wrap_to_beginning = false,
    wrap_to_end = false,
    default_bib_path = '',
    use_mappings_table = true,
    mappings = {
        MkdnNextLink = '<Tab>',
        MkdnPrevLink = '<S-Tab>',
        MkdnNextHeading = '<leader>]',
        MkdnPrevHeading = '<leader>[',
        MkdnGoBack = '<BS>',
        MkdnGoForward = '<Del>',
        MkdnFollowLink = '<CR>',
        MkdnYankAnchorLink = 'ya',
        MkdnIncreaseHeading = '+',
        MkdnDecreaseHeading = '-',
        MkdnToggleToDo = '<C-Space>',
        MkdnDestroyLink = '<M-CR>'
    }
}

-- Private function to merge the user_config with the default config
local merge_configs = function(defaults, user_config)
    local config = {}
    for key, value in pairs(defaults) do
        if type(value) == 'table' then
            local subtable = {}
            for key_, _ in pairs(value) do
                if user_config[key][key_] then
                    subtable[key_] = user_config[key][key_]
                else
                    subtable[key_] = value[key_]
                end
            end
            config[key] = subtable
        else
            if user_config[key] then
                config[key] = user_config[key]
            else
                config[key] = defaults[key]
            end
        end
    end
    return config
end

-- Private function to detect the extension of a filename passed as a string
local get_file_type = function(string)
    local ext = string:match("^.*%.(.+)$")
    return(ext ~= nil and string.lower(ext) or '')
end

-- Private function to identify root directory on a unix machine
local get_root_dir_unix = function(dir, root_tell)
    -- List files in directory
    local search_is_on, root = true, nil
    -- Until the root directory is found, keep looking higher and higher
    -- each pass
    while search_is_on do
        -- Get the output of running ls -a in dir
        local pfile = io.popen('ls -a "'..dir..'"')
        -- Check the list of files for the tell
        for filename in pfile:lines() do
            local match = filename == root_tell
            if match then
                root = dir
                search_is_on = false
            end
        end
        pfile:close()
        if search_is_on then
            if dir == '/' or dir == '~/' then
                -- If we've reached the highest directory possible, call off
                -- the search and return nothing
                search_is_on = false
                return(nil)
            else
                -- If there's still more to remove, remove it
                dir = dir:match('(.*)/')
                -- If dir is an empty string, look for the tell in *root* root
                if dir == '' then dir = '/' end
            end
        else
            return(root)
        end
    end
end

-- Private function to identify root directory on a windows machine
local get_root_dir_windows = function(dir, root_tell)
    -- List files in directory
    local search_is_on, root = true, nil
    -- Until the root directory is found, keep looking higher and higher
    -- each pass
    while search_is_on do
        -- Get the output of running ls -a in dir
        local pfile = io.popen('dir /b "'..dir..'"')
        -- Check the list of files for the tell
        for filename in pfile:lines() do
            local match = filename == root_tell
            if match then
                root = dir
                search_is_on = false
            end
        end
        pfile:close()
        if search_is_on then
            if dir == 'C:\\' then
                -- If we've reached the highest directory possible, call off
                -- the search and return nothing
                search_is_on = false
                return(nil)
            else
                -- If there's still more to remove, remove it
                dir = dir:match('(.*)\\')
                -- If dir is an empty string, look for the tell in *root* root
                if dir == 'C:' then dir = 'C:\\' end
            end
        else
            return(root)
        end
    end
end

-- Initialize "init" table
local init = {}
-- Table to store merged configs
init.config = {}
-- Initialize a variable for load status
init.loaded = nil

-- Run setup
init.setup = function(user_config)
    -- Get OS for use in a couple of functions
    init.this_os = vim.loop.os_uname().sysname
    -- Get first opened file/buffer path and directory
    init.initial_buf = vim.api.nvim_buf_get_name(0)
    -- Determine initial_dir according to OS
    if init.this_os == 'Windows_NT' then
        init.initial_dir = init.initial_buf:match('(.*)\\.-')
    else
        init.initial_dir = init.initial_buf:match('(.*)/.-')
    end
    -- Read compatibility module & pass user config through config checker
    local compat = require('mkdnflow.compat')
    user_config = compat.userConfigCheck(user_config)
    -- Overwrite defaults w/ user's config settings, if any
    init.config = merge_configs(default_config, user_config)
    -- Get the extension of the file being edited
    local ft = get_file_type(init.initial_buf)
    -- Load extension if the filetype has a match in config.filetypes
    if init.config.filetypes[ft] then
        -- Determine perspective
        local links_relative_to = init.config.links_relative_to
        if links_relative_to.target == 'root' then
            -- Retrieve the root 'tell'
            local root_tell = links_relative_to.root_tell
            -- If one was provided, try to find the root directory for the
            -- notebook/wiki using the tell
            if root_tell then
                if init.this_os == 'Linux' or init.this_os == 'Darwin' then
                    init.root_dir = get_root_dir_unix(init.initial_dir, root_tell)
                    if init.root_dir then
                        print('⬇️  Root directory found: '..init.root_dir)
                    else
                        print('⬇️  No suitable root directory found!')
                        init.config.links_relative_to.target = init.config.links_relative_to.fallback
                    end
                elseif init.this_os == 'Windows_NT' then
                    init.root_dir = get_root_dir_windows(init.initial_dir, root_tell)
                    if init.root_dir then
                        print('⬇️  Root directory found: '..init.root_dir)
                    else
                        print('⬇️  No suitable root directory found!')
                        init.config.links_relative_to.target = init.config.links_relative_to.fallback
                    end
                else
                    print('⬇️  Cannot yet search for root directory on '..init.this_os..' machines.')
                    init.config.links_relative_to.target = init.config.links_relative_to.fallback
                end
            else
                print('⬇️  No tell was provided for the root directory. See :h mkdnflow-configuration.')
                init.config.links_relative_to.target = init.config.links_relative_to.fallback
            end
        end
        -- Load functions
        init.cursor = require('mkdnflow.cursor')
        init.paths = require('mkdnflow.paths')
        init.links = require('mkdnflow.links')
        init.buffers = require('mkdnflow.buffers')
        init.bib = require('mkdnflow.bib')
        init.lists = require('mkdnflow.lists')
        init.files = compat
        -- Only load the mappings if the user hasn't said "no"
        if init.config.use_mappings_table == true and user_config.default_mappings ~= false then
            require('mkdnflow.maps')
            if user_config.default_mappings == true then
                print("⬇️  NOTE: Mappings can now be specified in the setup function. See :h mkdnflow-mappings.")
            end
        end
        -- Record load status (i.e. loaded)
        init.loaded = true
    else
        -- Record load status (i.e. not loaded)
        init.loaded = false
    end

end

-- Force start
init.forceStart = function()
    if init.loaded == true then
        print("⬇️  Mkdnflow is already running!")
    else
        -- Record load status (i.e. loaded)
        init.loaded = true
        -- Load functions
        init.cursor = require('mkdnflow.cursor')
        init.paths = require('mkdnflow.paths')
        init.links = require('mkdnflow.links')
        init.buffers = require('mkdnflow.buffers')
        init.bib = require('mkdnflow.bib')
        init.lists = require('mkdnflow.lists')
        init.files = require('mkdnflow.compat')
        -- Only load the mappings if the user hasn't said "no"
        if init.config.default_mappings == true then
            require('mkdnflow.maps')
        end
    end
end

return init
