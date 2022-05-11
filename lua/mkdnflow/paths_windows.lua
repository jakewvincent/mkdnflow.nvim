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
-- Get config setting for whether to make missing directories or not
local create_dirs = require('mkdnflow').config.create_dirs
-- Get config setting for where links should be relative to
local perspective = require('mkdnflow').config.perspective.priority
-- Get directory of first-opened file
local initial_dir = require('mkdnflow').initial_dir
-- Get root_dir for notebook/wiki
local root_dir = require('mkdnflow').root_dir
local silent = require('mkdnflow').config.silent
local implicit_extension = require('mkdnflow').config.links.implicit_extension

-- Load modules
local buffers = require('mkdnflow.buffers')
local bib = require('mkdnflow.bib')
local cursor = require('mkdnflow.cursor')
local links = require('mkdnflow.links')
local paths = require('mkdnflow.paths')

--[[
path_type() determines what kind of path is in a url
Returns a string:
     1. 'file' if the path has the 'file:' prefix,
     2. 'url' is the result of hasUrl(path) is true
     3. 'filename' if (1) and (2) aren't true
--]]
local path_type = function(path)
    if string.find(path, '^file:') then
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
does_exist() determines whether the path specified as the argument exists
NOTE: Assumes that the initially opened file is in an existing directory!
--]]
local does_exist = function(path, type)
    -- If type is not specified, use "d" (directory) by default
    type = type or "d"
    -- Add a backslash if we're searching for a directory
    if type == 'd' then type = '\\' else type = '' end
    -- Use the shell to determine if the path exists
    local handle = io.popen('IF exist "'..path..type..'" ( echo true ) ELSE ( echo false )')
    local exists = handle:read('*l')
    io.close(handle)
    if exists:match('true') then
        exists = true
    else
        exists = false
    end
    -- Return the existence property of the path
    return(exists)
end

--[[
escape_chars() escapes the set of characters in 'chars' with the mappings in
'replacements'. For shell escapes.
--]]
local escape_chars = function(string)
    -- Which characters to match
    local chars = "[ '&()$]"
    -- Set up table of replacements
    local replacements = {
        [" "] = "\\ ",
        ["'"] = "\\'",
        ["&"] = "\\&",
        ["("] = "\\(",
        [")"] = "\\)",
        ["$"] = "\\$",
        ["#"] = "\\#",
    }
    -- Do the replacement
    local escaped = string.gsub(string, chars, replacements)
    -- Return the new string
    return(escaped)
end

--[[
escape_lua_chars() escapes the set of characters in 'chars' with the mappings
provided in 'replacements'. For Lua escapes.
--]]
local escape_lua_chars = function(string)
    -- Which characters to match
    local chars = "[-.'\"a]"
    -- Set up table of replacements
    local replacements = {
        ["-"] = "%-",
        ["."] = "%.",
        ["'"] = "\'",
        ['"'] = '\"'
    }
    -- Do the replacement
    local escaped = string.gsub(string, chars, replacements)
    -- Return the new string
    return(escaped)
end

local handle_internal_file = function(path, anchor)
    local internal_open = function(path_, anchor_)
        -- See if a directory is part of the path
        local dir = string.match(path_, '(.*)\\.-$')
        -- If there's a match and user wants dirs created, check if any dirs
        -- need to be created and act accordingly
        if dir and create_dirs then
            local dir_exists = does_exist(dir)
            if not dir_exists then
                os.execute('mkdir "'..dir..'"')
            end
        end
        buffers.push(buffers.main, vim.api.nvim_win_get_buf(0))
        vim.cmd(':e '..path_)
        if anchor_ then
            cursor.toHeading(anchor_)
        end
    end
    -- Decide what to pass to above local function
    if path:match('^%u:\\') then
        internal_open(path, anchor)
    elseif perspective == 'root' then
        -- Paste root directory and the directory in link
        path = root_dir..'\\'..path
        -- Remember the buffer we're currently in and follow path
        buffers.push(buffers.main, vim.api.nvim_win_get_buf(0))
        internal_open(path, anchor)
    elseif perspective == 'first' then
        -- Paste together the directory of the first-opened file
        -- and the directory in the link path
        path = initial_dir..'\\'..path
        internal_open(path, anchor)
    else -- Otherwise, they want it relative to the current file
        -- So, get the path of the current file
        local cur_file = vim.api.nvim_buf_get_name(0)
        -- Get the directory the current file is in
        local cur_file_dir = string.match(cur_file, '(.*)\\.-$')
        -- Paste together the directory of the current file and the
        -- directory path provided in the link
        if cur_file_dir then
            path = cur_file_dir..'\\'..path
        end
        internal_open(path, anchor)
    end
end

--[[
open() handles vim-external paths, including local files or web URLs
Returns nothing
--]]
local open = function(path)
    local shell_open = function(path_)
        --vim.api.nvim_command('silent !cmd.exe /c "start "" "'..path_..'"')
        os.execute('cmd.exe /c "start "" "'..path_..'"')
    end
    -- If the file exists, handle it; otherwise, print a warning
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
    -- Check if path provided is absolute
    if string.match(real_path, '^%u:\\') then
        open(real_path)
    elseif perspective == 'root' then
        -- Paste together root directory path and path in link
        local paste = root_dir..'\\'..real_path
        -- Pass to the open() function
        open(paste)
    elseif perspective == 'current' then
        -- Get the path of the current file
        local cur_file = vim.api.nvim_buf_get_name(0)
        -- Get the directory the current file is in
        local cur_file_dir = string.match(cur_file, '(.*)\\.-$')
        -- Paste together the directory of the current file and the
        -- directory path provided in the link, and escape for shell
        local paste = cur_file_dir..'\\'..real_path
        -- Pass to the open() function
        open(paste)
    else
        -- Otherwise, links are relative to the first-opened file, so
        -- paste together the directory of the first-opened file and the
        -- path in the link and escape for the shell
        local paste = initial_dir..'\\'..real_path
        -- Pass to the open() function
        open(paste)
    end
end

local M = {}

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
    path = paths.transformPath(path)
    if path_type(path) == 'filename' then
        if not path:match('%.md$') then
            if implicit_extension then
                path = path..'.'..implicit_extension
            else
                path = path..'.md'
            end
        end
        handle_internal_file(path, anchor)
    elseif path_type(path) == 'url' then
        local se_path = vim.fn.shellescape(path)
        open(se_path)
    elseif path_type(path) == 'file' then
        handle_external_file(path)
    elseif path_type(path) == 'anchor' then
        cursor.toHeading(path)
    elseif path_type(path) == 'citation' then
        -- Retrieve highest-priority field in bib entry (if it exists)
        local field = bib.citationHandler(escape_lua_chars(path))
        -- Use this function to do sth with the information returned (if any)
        if field then M.handlePath(field) end
    end
end

-- Return all the functions added to the table M!
return M
