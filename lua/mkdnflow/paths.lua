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
--
-- This module: File and link navigation functions

-- Get OS for use in a couple of functions
local this_os = require('mkdnflow').this_os
-- Generic OS message
local this_os_err = '⬇️ Function unavailable for '..this_os..'. Please file an issue.'
-- Set path separator based on OS
local sep = this_os:match('Windows') and '\\' or '/'
-- Get config setting for whether to make missing directories or not
local create_dirs = require('mkdnflow').config.create_dirs
-- Get config setting for where links should be relative to
local perspective = require('mkdnflow').config.perspective
-- Get directory of first-opened file
local initial_dir = require('mkdnflow').initial_dir
local root_dir = require('mkdnflow').root_dir
local silent = require('mkdnflow').config.silent
local implicit_extension = require('mkdnflow').config.links.implicit_extension
local link_transform = require('mkdnflow').config.links.transform_implicit

-- Load modules
local utils = require('mkdnflow').utils
local buffers = require('mkdnflow.buffers')
local bib = require('mkdnflow.bib')
local cursor = require('mkdnflow.cursor')
local links = require('mkdnflow.links')

--[[
does_exist() determines whether the path specified as the argument exists
NOTE: Assumes that the initially opened file is in an existing directory!
--]]
local does_exist = function(path, type)
    -- If type is not specified, use "d" (directory) by default
    type = type or "d"
    local handle
    if this_os:match('Windows') then
        if type == 'd' then type = '\\' else type = '' end
        handle = io.popen('IF exist "'..path..type..'" ( echo true ) ELSE ( echo false )')
    else
        -- Use the shell to determine if the path exists
        handle = io.popen(
            'if [ -'..type..' "'..path..'" ]; then echo true; else echo false; fi'
        )
    end
    local exists = handle:read('*l')
    io.close(handle)
    -- Get the contents of the first (only) line & store as a boolean
    if exists == 'false' then
        exists = false
    else
        exists = true
    end
    -- Return the existence property of the path
    return(exists)
end

local M = {}

local handle_internal_file = function(path, anchor)
    -- Local function to open the provided path
    local internal_open = function(path_, anchor_)
        -- See if a directory is part of the path
        local dir = string.match(path_, '(.*)'..sep..'.-$')
        -- If there's a dir & user wants dirs created, do so if necessary
        if dir and create_dirs then
            local dir_exists = does_exist(dir)
            if not dir_exists then
                if this_os:match('Windows') then
                    os.execute('mkdir "'..dir..'"')
                else
                    local path_to_file = utils.escapeChars(dir)
                    os.execute('mkdir -p '..path_to_file)
                end
            end
        end
        -- If the path starts with a tilde, replace it w/ $HOME
        if this_os == 'Linux' or this_os == 'Darwin' then
            if string.match(path_, '^~/') then
                path_ = string.gsub(path_, '^~/', '$HOME/')
            end
        end
        -- Push the current buffer name onto the main buffer stack
        buffers.push(buffers.main, vim.api.nvim_win_get_buf(0))
        vim.cmd(':e '..path_)
        if anchor_ then
            cursor.toHeading(anchor_)
        end
    end

    if this_os:match('Windows') then
        path = path:gsub('/', '\\')
    end

    local wd

    -- Decide what to pass to internal_open function
    if path:match('^~/') or path:match('^/') or path:match('^%u:\\') then
        path = path
    elseif perspective.priority == 'root' and root_dir then
        -- Paste root directory and the directory in link
        path = root_dir..sep..path
        -- See if the path exists
    elseif perspective.priority == 'first' or (perspective.priority == 'root' and perspective.fallback == 'first') then
        -- Paste together the dir of first-opened file & dir in link path
        path = initial_dir..sep..path
        wd = path:match('(.*)'..sep..'.-$')
    else -- Otherwise, they want it relative to the current file
        -- Path of current file
        local cur_file = vim.api.nvim_buf_get_name(0)
        -- Directory current file is in
        local cur_file_dir = string.match(cur_file, '(.*)'..sep..'.-$')
        -- Paste together dir of current file & dir path provided in link
        if cur_file_dir then path = cur_file_dir..sep..path end
    end
    internal_open(path, anchor)
    M.updateDirs()
end

--[[
open() handles vim-external paths, including local files or web URLs
Returns nothing
--]]
local open = function(path)
    local shell_open = function(path_)
        if this_os == "Linux" then
            vim.api.nvim_command('silent !xdg-open '..path_)
        elseif this_os == "Darwin" then
            vim.api.nvim_command('silent !open '..path_..' &')
        elseif this_os:match('Windows') then
            os.execute('cmd.exe /c "start "" "'..path_..'"')
        else
            if not silent then vim.api.nvim_echo({{this_os_err, 'ErrorMsg'}}, true, {}) end
        end
    end
    -- If the file exists, handle it; otherwise,  a warning
    -- Don't want to use the shell-escaped version; it will throw a
    -- false alert if there are escape chars
    if links.hasUrl(path) then
        shell_open(path)
    elseif does_exist(path, "f") == false and
        does_exist(path, "d") == false then
        if not silent then vim.api.nvim_echo({{"⬇️  "..path.." doesn't seem to exist!", 'ErrorMsg'}}, true, {}) end
    else
        shell_open(path)
    end
end

local handle_external_file = function(path)
    -- Get what's after the file: tag
    local real_path = string.match(path, '^file:(.*)')
    local escaped_path
    -- Check if path provided is absolute or relative to $HOME
    if real_path:match('^~/') or real_path:match('^/') or real_path:match('^%:\\') then
        if this_os:match('Windows') then
            open(real_path)
        else
            escaped_path = utils.escapeChars(real_path)
            -- If the path starts with a tilde, replace it w/ $HOME
            if string.match(real_path, '^~/') then
                escaped_path = string.gsub(escaped_path, '^~/', '$HOME/')
            end
        end
    elseif perspective.priority == 'root' and root_dir then
        -- Paste together root directory path and path in link and escape
        if this_os:match('Windows') then
            escaped_path = root_dir..sep..real_path
        else
            escaped_path = utils.escapeChars(root_dir..sep..real_path)
        end
    elseif perspective.priority == 'first' or (perspective.priority == 'root' and perspective.fallback == 'first') then
        -- Otherwise, links are relative to the first-opened file, so
        -- paste together the directory of the first-opened file and the
        -- path in the link and escape for the shell
        if this_os:match('Windows') then
            escaped_path = initial_dir..sep..real_path
        else
            escaped_path = utils.escapeChars(initial_dir..sep..real_path)
        end
    else
        -- Get the path of the current file
        local cur_file = vim.api.nvim_buf_get_name(0)
        -- Get the directory the current file is in and paste together the
        -- directory of the current file and the directory path provided in the
        -- link, and escape for shell
        local cur_file_dir = string.match(cur_file, '(.*)'..sep..'.-$')
        if this_os:match('Windows') then
            escaped_path = cur_file_dir..sep..real_path
        else
            escaped_path = utils.escapeChars(cur_file_dir..sep..real_path)
        end
    end
    -- Pass to the open() function
    open(escaped_path)
end

M.updateDirs = function()
    local wd
    -- See if the new file is in a different root directory
    if perspective.update or perspective.vimwd_heel then
        if perspective.priority == 'root' then
            local cur_file = vim.api.nvim_buf_get_name(0)
            if not root_dir or not cur_file:match(root_dir) then
                -- Get the new root dir, if there is one
                local dir = cur_file:match('(.*)'..sep..'.-')
                if perspective.update then
                    root_dir = require('mkdnflow').getRootDir(dir, perspective.root_tell, this_os)
                    if root_dir then
                        local name = root_dir:match('.*'..sep..'(.*)') or root_dir
                        if not silent then vim.api.nvim_echo({{'⬇️  Notebook: '..name}}, true, {}) end
                        wd = root_dir
                    else
                        if not silent then
                            vim.api.nvim_echo(
                                {{'⬇️  No notebook found. Fallback perspective: '..perspective.fallback, 'WarningMsg'}},
                                true, {}
                            )
                            if perspective.fallback == 'first' and perspective.vimwd_heel then
                                wd = initial_dir
                            elseif perspective.vimwd_heel then -- Otherwise, set wd to directory the current buffer is in
                                wd = dir
                            end
                        end
                    end
                end
            end
        elseif perspective.priority == 'first' and perspective.vimwd_heel then
            wd = initial_dir
        elseif perspective.vimwd_heel then
            local cur_file = vim.api.nvim_buf_get_name(0)
            wd = cur_file:match('(.*)'..sep..'.-$')
        end
        if perspective.vimwd_heel and wd then
            vim.api.nvim_set_current_dir(wd)
        end
    end
end

--[[
pathType() determines what kind of path is in a url
Returns a string:
     1. 'file' if the path has the 'file:' prefix,
     2. 'url' is the result of hasUrl(path) is true
     3. 'filename' if (1) and (2) aren't true
--]]
M.pathType = function(path)
    if not path then
        return(nil)
    elseif string.find(path, '^file:') then
        return('file')
    elseif links.hasUrl(path) then
        return('url')
    elseif string.find(path, '^@') then
        return('citation')
    elseif string.find(path, '^#') then
        return('anchor')
    else
        return('filename')
    end
end


--[[
transformPath() takes a string and transforms it with a user-defined function if
it was set. Otherwise returns the string / path unchanged.
--]]
M.transformPath = function(path)
    if type(link_transform) ~= 'function' or not link_transform then
        return path
    else
        return link_transform(path)
    end
end

local rename_file = function()
end

--[[
handlePath() does something with the path in the link under the cursor:
     1. Creates the file specified in the path, if the path is determined to
        be a filename,
     2. Uses open() to open the URL specified in the path, if the path
        is determined to be a URL, or
     3. Uses open() to open a local file at the specified path via the
        system's default application for that filetype, if the path is dete-
        rmined to be neither the filename for a text file nor a URL.
Returns nothing
--]]
M.handlePath = function(path, anchor)
    anchor = anchor or false
    path = M.transformPath(path)
    -- Handle according to path type
    if M.pathType(path) == 'filename' then
        if not path:match('%..+$') then
            if implicit_extension then
                path = path..'.'..implicit_extension
            else
                path = path..'.md'
            end
        end
        handle_internal_file(path, anchor)
    elseif M.pathType(path) == 'url' then
        path = vim.fn.escape(path, '%')
        open(path)
    elseif M.pathType(path) == 'file' then
        handle_external_file(path)
    elseif M.pathType(path) == 'anchor' then
        -- Send cursor to matching heading
        cursor.toHeading(path)
    elseif M.pathType(path) == 'citation' then
        -- Retrieve highest-priority field in bib entry (if it exists)
        local field = bib.citationHandler(utils.luaEscape(path))
        -- Use this function to do sth with the information returned (if any)
        if field then M.handlePath(field) end
    end
end

M.moveSource = function()
    if this_os:match('Windows') then
        vim.api.nvim_echo({{this_os_err, 'ErrorMsg'}}, true, {})
    else
        local derive_path = function(source, type)
            local derived_path
            if type == 'file' then
                source = source:gsub('^file:', '')
            end
            if string.match(source, '^~/') then
                derived_path = string.gsub(source, '^~/', '$HOME/')
            elseif string.match(source, '^/') then
                derived_path = source
            elseif perspective == 'root' then
                -- Paste root directory and the directory in link
                derived_path = root_dir..'/'..source
            elseif perspective == 'first' then
                -- Paste together the directory of the first-opened file
                -- and the directory in the link source
                derived_path = initial_dir..'/'..source
            else -- Otherwise, they want it relative to the current file
                -- So, get the source of the current file
                local cur_file = vim.api.nvim_buf_get_name(0)
                -- Get the directory the current file is in
                local cur_file_dir = string.match(cur_file, '(.*)'..sep..'.-$')
                -- Paste together the directory of the current file and the
                -- directory source provided in the link
                if cur_file_dir then
                    derived_path = cur_file_dir..sep..source
                end
            end
            return derived_path
        end
        -- Retrieve source from link
        local source, anchor, first, last, path_row = links.getLinkPart('path')
        -- Determine type of source
        local source_type = M.pathType(source)
        -- Modify source path in the same way as when links are interpreted
        local derived_source = M.transformPath(source)
        if not derived_source:match('%..+$') then
            if implicit_extension then
                derived_source = derived_source..'.'..implicit_extension
            else
                derived_source = derived_source..'.md'
            end
        end
        -- If it's a file, determine the full path of the source using perspective
        derived_source = derive_path(derived_source, source_type)
        -- Ask user to edit name in console (only display what's in the link)
        local input_opts = {
            prompt = '⬇️  Move to: ',
            default = source,
            completion = 'file'
        }
        -- Determine what to do based on user input
        vim.ui.input(input_opts, function(location)
            if location then
                local derived_goal = M.transformPath(location)
                if not derived_goal:match('%..+$') then
                    if implicit_extension then
                        derived_goal = derived_goal..'.'..implicit_extension
                    else
                        derived_goal = derived_goal..'.md'
                    end
                end
                derived_goal = derive_path(derived_goal, M.pathType(derived_goal))
                local source_exists = does_exist(derived_source, 'f')
                local goal_exists = does_exist(derived_goal, 'f')
                local dir = string.match(derived_goal, '(.*)'..sep..'.-$')
                if goal_exists then -- If the goal location already exists, abort
                    vim.api.nvim_command("normal! :")
                    vim.api.nvim_echo({{'⬇️  \''..location..'\' already exists! Aborting.', 'WarningMsg'}}, true, {})
                elseif source_exists then -- If the source location exists, proceed
                    if dir then -- If there's a directory in the goal location, ...
                        local to_dir_exists = does_exist(dir, 'd')
                        if not to_dir_exists then
                            if create_dirs then
                                local path_to_file = utils.escapeChars(dir)
                                os.execute('mkdir -p '..path_to_file)
                            else
                                vim.api.nvim_command("normal! :")
                                vim.api.nvim_echo({{'⬇️  The goal directory doesn\'t exist. Set create_dirs to true for automatic directory creation.'}})
                            end
                        else
                            vim.ui.input(
                                {prompt = '⬇️  Move \''..derived_source..'\' to \''..derived_goal..'\' and rename the link source to \''..location..'\'? [y/n] '},
                                function(response)
                                    if response == 'y' then
                                        os.execute('mv '..derived_source..' '..derived_goal)
                                        -- Change the link content
                                        vim.api.nvim_buf_set_text(0, path_row - 1, first - 1, path_row - 1, last, {location})
                                        -- Clear the prompt & print sth
                                        vim.api.nvim_command("normal! :")
                                        vim.api.nvim_echo({{'⬇️  Success! File moved to '..derived_goal}}, true, {})
                                    else
                                        -- Clear the prompt & print sth
                                        vim.api.nvim_command("normal! :")
                                        vim.api.nvim_echo({{'⬇️  Aborted', 'WarningMsg'}}, true, {})
                                    end
                                end
                            )
                        end
                    else -- Move
                        vim.ui.input(
                            {prompt = '⬇️  Move \''..derived_source..'\' to \''..derived_goal..'\' and rename the link source to \''..location..'\'? [y/n] '},
                            function(response)
                                if response == 'y' then
                                    os.execute('mv '..derived_source..' '..derived_goal)
                                    -- Change the link content
                                    vim.api.nvim_buf_set_text(0, path_row - 1, first - 1, path_row - 1, last, {location})
                                    -- Clear the prompt & print sth
                                    vim.api.nvim_command("normal! :")
                                    vim.api.nvim_echo({{'⬇️  Success! File moved to '..derived_goal}}, true, {})
                                else
                                    -- Clear the prompt & print sth
                                    vim.api.nvim_command("normal! :")
                                    vim.api.nvim_echo({{'⬇️  Aborted', 'WarningMsg'}}, true, {})
                                end
                            end
                        )
                    end
                else -- Otherwise, the file we're trying to move must not exist
                    -- Clear the prompt & send a warning
                    vim.api.nvim_command("normal! :")
                    vim.api.nvim_echo({{'⬇️  '..derived_source..' doesn\'t seem to exist! Aborting.', 'WarningMsg'}}, true, {})
                end
            end
        end)
    end
end

-- Return all the functions added to the table M!
return M
