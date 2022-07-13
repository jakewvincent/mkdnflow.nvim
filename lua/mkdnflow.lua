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
    perspective = {
        priority = 'first',
        fallback = 'current',
        root_tell = false,
        update = true,
        nvim_wd_heel = true
    },
    filetypes = {
        md = true,
        rmd = true,
        markdown = true
    },
    wrap = false,
    bib = {
        default_path = nil,
        find_in_root = true
    },
    silent = false,
    links = {
        style = 'markdown',
        conceal = false,
        implicit_extension = nil,
        transform_implicit = false,
        transform_explicit = function(text)
            text = text:gsub("[ /]", "-")
            text = text:lower()
            text = os.date('%Y-%m-%d_')..text
            return(text)
        end
    },
    to_do = {
        symbols = {' ', '-', 'X'},
        update_parents = true,
        not_started = ' ',
        in_progress = '-',
        complete = 'X'
    },
    tables = {
        trim_whitespace = true,
        format_on_move = true
    },
    use_mappings_table = true,
    mappings = {
        MkdnGoBack = {'n', '<BS>'},
        MkdnGoForward = {'n', '<Del>'},
        MkdnMoveSource = {'n', '<F2>'},
        MkdnNextLink = {'n', '<Tab>'},
        MkdnPrevLink = {'n', '<S-Tab>'},
        MkdnFollowLink = false,
        MkdnDestroyLink = {'n', '<M-CR>'},
        MkdnYankAnchorLink = {'n', 'ya'},
        MkdnYankFileAnchorLink = {'n', 'yfa'},
        MkdnNextHeading = {'n', '<leader>]'},
        MkdnPrevHeading = {'n', '<leader>['},
        MkdnIncreaseHeading = {'n', '+'},
        MkdnDecreaseHeading = {'n', '-'},
        MkdnToggleToDo = {{'n', 'v'}, '<C-Space>'},
        MkdnNewListItem = false,
        MkdnExtendList = false,
        MkdnUpdateNumbering = {'n', '<leader>nn'},
        MkdnTableNextCell = {'i', '<Tab>'},
        MkdnTablePrevCell = {'i', '<S-Tab>'},
        MkdnTableNextRow = false,
        MkdnTablePrevRow = {'i', '<M-CR>'},
        MkdnTableNewRowBelow = {{'n', 'i'}, '<leader>ir'},
        MkdnTableNewRowAbove = {{'n', 'i'}, '<leader>iR'},
        MkdnTableNewColAfter = {{'n', 'i'}, '<leader>ic'},
        MkdnTableNewColBefore = {{'n', 'i'}, '<leader>iC'},
        MkdnImodeMultiFunc = false,
        MkdnNVmodeMultiFunc = {{'n', 'v'}, '<CR>'},
        MkdnFoldSection = {'n', '<leader>f'},
        MkdnUnfoldSection = {'n', '<leader>F'}
    }
}

local init = {} -- Init functions & variables
init.utils = require('mkdnflow.utils')
init.user_config = {} -- For user config
init.config = {} -- For merged configs
init.loaded = nil -- For load status

-- Run setup
init.setup = function(user_config)
    user_config = user_config or {}
    init.this_os = vim.loop.os_uname().sysname -- Get OS
    init.nvim_version = vim.fn.api_info().version.minor
    -- Get first opened file/buffer path and directory
    init.initial_buf = vim.api.nvim_buf_get_name(0)
    -- Determine initial_dir according to OS
    if init.this_os:match('Windows') then
        init.initial_dir = init.initial_buf:match('(.*)\\.-')
    else
        init.initial_dir = init.initial_buf:match('(.*)/.-')
    end
    -- Get the extension of the file being edited
    local ft = init.utils.getFileType(init.initial_buf)
    -- Before fully loading config see if the plugin should be started
    local load_on_ft = default_config.filetypes
    if next(user_config) then
        if user_config.filetypes then
            load_on_ft = init.utils.mergeTables(load_on_ft, user_config.filetypes)
        end
        init.user_config = user_config
    end
    -- Read compatibility module & pass user config through config checker
    local compat = require('mkdnflow.compat')
    -- Load extension if the filetype has a match in config.filetypes
    -- Overwrite defaults w/ user's config settings, if any
    user_config = compat.userConfigCheck(user_config)
    init.config = init.utils.mergeTables(default_config, user_config)
    -- Only load the mapping autocommands if the user hasn't said "no"
    if init.config.use_mappings_table == true then
        require('mkdnflow.maps')
    end
    if load_on_ft[ft] then
        -- Get silence preference
        local silent = init.config.silent
        -- Determine perspective
        local perspective = init.config.perspective
        if perspective.priority == 'root' then
            -- Retrieve the root 'tell'
            local root_tell = perspective.root_tell
            -- If one was provided, try to find the root directory for the
            -- notebook/wiki using the tell
            if root_tell then
                init.root_dir = init.utils.getRootDir(init.initial_dir, root_tell, init.this_os)
                -- Get notebook name
                if init.root_dir then
                    vim.api.nvim_set_current_dir(init.root_dir)
                    local name = init.root_dir:match('.*/(.*)') or init.root_dir
                    if not silent then vim.api.nvim_echo({{'⬇️  Notebook: '..name}}, true, {}) end
                else
                    local fallback = init.config.perspective.fallback
                    if not silent then vim.api.nvim_echo({{'⬇️  No notebook found. Fallback perspective: '..fallback, 'WarningMsg'}}, true, {}) end
                    --init.config.perspective.priority = init.config.perspective.fallback
                    -- Set working directory according to current perspective
                    if fallback == 'first' then
                        vim.api.nvim_set_current_dir(init.initial_dir)
                    else
                        local bufname = vim.api.nvim_buf_get_name(0)
                        if init.this_os:match('Windows') then
                            vim.api.nvim_set_current_dir(bufname:match('(.*)\\.-$'))
                        else
                            vim.api.nvim_set_current_dir(bufname:match('(.*)/.-$'))
                        end
                    end
                end
            else
                if not silent then vim.api.nvim_echo({{'⬇️  No tell was provided for the notebook\'s root directory. See :h mkdnflow-configuration.', 'WarningMsg'}}, true, {}) end
                if init.config.perspective.fallback == 'first' then
                    vim.api.nvim_set_current_dir(init.initial_dir)
                else
                    -- Set working directory
                    local bufname = vim.api.nvim_buf_get_name(0)
                    if init.this_os:match('Windows') then
                        vim.api.nvim_set_current_dir(bufname:match('(.*)\\.-$'))
                    else
                        vim.api.nvim_set_current_dir(bufname:match('(.*)/.-$'))
                    end
                end
            end
        end
        -- Load modules
        init.paths = require('mkdnflow.paths')
        init.cursor = require('mkdnflow.cursor')
        init.links = require('mkdnflow.links')
        init.buffers = require('mkdnflow.buffers')
        init.bib = require('mkdnflow.bib')
        init.lists = require('mkdnflow.lists')
        init.tables = require('mkdnflow.tables')
        if init.config.links.conceal then
            init.conceal = require('mkdnflow.conceal')
        end
        init.folds = require('mkdnflow.folds')
        -- Record load status (i.e. loaded)
        init.loaded = true
    else
        -- Record load status (i.e. not loaded)
        init.loaded = false
        -- Make table of extension patterns to try to match
        local extension_patterns = {}
        for key, _ in pairs(load_on_ft) do
            table.insert(extension_patterns, '*.'..key)
        end
        -- Define an autocommand to enable to plugin when the right buffer type is entered
        if init.nvim_version >= 7 then
            init.autocmd_id = vim.api.nvim_create_autocmd(
                {"BufEnter", "BufWinEnter"},
                {
                    pattern = extension_patterns,
                    command = "Mkdnflow silent"
                }
            )
        end
    end

end

-- Force start
init.forceStart = function(opts)
    local silent = opts[1] or false
    if init.loaded == true then
        vim.api.nvim_echo({{"⬇️  Mkdnflow is already running!", 'ErrorMsg'}}, true, {})
    else
        if silent ~= 'silent' then
            vim.api.nvim_echo({{"⬇️  Starting Mkdnflow", 'WarningMsg'}}, true, {})
        end
        init.setup(init.user_config)
        if vim.fn.api_info().version.minor >= 7 then
            -- Delete the autocommand
            vim.api.nvim_del_autocmd(init.autocmd_id)
        end
    end
end

return init
