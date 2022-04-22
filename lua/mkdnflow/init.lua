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

-- Default config table (where defaults and user-provided config will be combined)
local default_config = {
    create_dirs = true,
    links_relative_to = {
        target = {'root', 'index.md'},
        fallback = 'first'
        -- other option: current
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
        MkdnFollowPath = '<CR>',
        MkdnYankAnchorLink = 'ya',
        MkdnIncreaseHeading = '+',
        MkdnDecreaseHeading = '-',
        MkdnToggleToDo = '<C-Space>',
        MkdnDestroyLink = '<M-CR>'
    }
}

-- Table to store merged configs
init.config = {}
-- Initialize a variable for status
init.loaded = nil

-- Private function to detect the file's extension
local getFileType = function()
    local ext = init.initial_buf:match("^.*%.(.+)$")
    return(ext ~= nil and string.lower(ext) or '')
end

-- Private function to merge the user_config with the default config
local merge_configs = function(defaults, user_config)
    local config = {}
    for key, value in pairs(defaults) do
        if type(value) == 'table' then
            subtable = {}
            for key_, value_ in pairs(value) do
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

init.setup = function(user_config)
    -- Record the user's config
    init.config = merge_configs(default_config, user_config)
    -- Get the extension of the file being edited
    local ft = getFileType()
    -- Load the extension if the filetype has a match in config.filetypes
    if init.config.filetypes[ft] then
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
        if init.config.use_mappings_table == true and user_config.default_mappings ~= false then
            require('mkdnflow.maps')
            if user_config.default_mappings == true then
                print("⬇️ : NOTE - Mappings can now be specified in the setup function. See :h mkdnflow-mappings.")
            end
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
