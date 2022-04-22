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
-- File and link navigation functions

-- Get OS for use in a couple of functions
local this_os = vim.loop.os_uname().sysname
-- Generic OS message
local this_os_err = 'Function unavailable for '..this_os..'. Please file an issue.'
-- Get config setting for whether to make missing directories or not
local create_dirs = require('mkdnflow').config.create_dirs
-- Get config setting for where links should be relative to
local links_relative_to = require('mkdnflow').config.links_relative_to
-- Get directory of first-opened file
local initial_dir = require('mkdnflow').initial_dir

-- Load modules
local buffers = require('mkdnflow.buffers')
local bib = require('mkdnflow.bib')
local cursor = require('mkdnflow.cursor')
local links = require('mkdnflow.links')

--[[

path_handler() handles vim-external paths, including local files or web URLs
Returns nothing
Private function

--]]
local path_handler = function(path)
    if this_os == "Linux" then
        vim.api.nvim_command('silent !xdg-open '..path)
    elseif this_os == "Darwin" then
        vim.api.nvim_command('silent !open '..path..' &')
    else
        print('⬇️ : '..this_os_err)
    end
end

--[[

path_type() determines what kind of path is in a url
Returns a string:
     1. 'file' if the path has the 'file:' prefix,
     2. 'url' is the result of hasUrl(path) is true
     3. 'filename' if (1) and (2) aren't true
Private function

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
Private function

--]]
local does_exist = function(path, type)
    -- If type is not specified, use "d" (directory) by default
    type = type or "d"
    if this_os == "Linux" or this_os == "POSIX" or this_os == "Darwin" then

        -- Use the shell to determine if the path exists
        local handle = io.popen(
            'if [ -'..type..' "'..path..'" ]; then echo true; else echo false; fi'
        )
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
    else
        print('⬇️ : '..this_os_err)

        -- Return a blep
        return(nil)
    end
end


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

local M = {}

--[[

followPath() does something with the path in the link under the cursor:
     1. Creates the file specified in the path, if the path is determined to
        be a filename,
     2. Uses path_handler to open the URL specified in the path, if the path
        is determined to be a URL, or
     3. Uses path_handler to open a local file at the specified path via the
        system's default application for that filetype, if the path is dete-
        rmined to be neither the filename for a text file nor a URL.
Returns nothing
Public function

--]]
M.followPath = function(path)

    -- Path can be provided as an argument (this is currently only used when
    -- this function retrieves a path from the citation handler). If no path
    -- is provided as an arg, get the path under the cursor via getLinkPart().
    if not path then
        -- Get the path in the link
        path = links.getLinkPart('path')
    end

    -- Check that there's a non-nil output of getLinkPart()
    if path then

        -- Get the name of the file in the link path. Will return nil if the
        -- link doesn't contain any directories.
        local filename = string.match(path, '.*/(.-)$')
        -- Get the name of the directory path to the file in the link path. Will
        -- return nil if the link doesn't contain any directories.
        local dir = string.match(path, '(.*)/.-$')

        -- If so, go to the path specified in the output
        if path_type(path) == 'filename' then

            -- Check if the user wants directories to be created and if
            -- a directory is specified in the link that we need to check
            if create_dirs and dir then
                -- If so, check how the user wants links to be interpreted
                if links_relative_to == 'first' then
                    -- Paste together the directory of the first-opened file
                    -- and the directory in the link path
                    local paste = initial_dir..'/'..dir

                    -- See if the path exists
                    local exists = does_exist(paste)

                    -- If the path doesn't exist, make it!
                    if not exists then
                        -- Escape special characters in path
                        local sh_esc_paste = escape_chars(paste)
                        -- Send command to shell
                        os.execute('mkdir -p '..sh_esc_paste)
                    end

                    -- Remember the buffer we're currently viewing
                    buffers.push(buffers.main, vim.api.nvim_win_get_buf(0))
                    -- And follow the path!
                    vim.cmd(':e '..paste..'/'..filename)

                else -- Otherwise, they want it relative to the current file

                    -- So, get the path of the current file
                    local cur_file = vim.api.nvim_buf_get_name(0)

                    -- Get the directory the current file is in
                    local cur_file_dir = string.match(cur_file, '(.*)/.-$')

                    -- Paste together the directory of the current file and the
                    -- directory path provided in the link
                    local paste = cur_file_dir..'/'..dir

                    -- See if the path exists
                    local exists = does_exist(paste)

                    -- If the path doesn't exist, make it!
                    if not exists then
                        -- Escape special characters in path
                        local sh_esc_paste = escape_chars(paste)
                        -- Send command to shell
                        os.execute('mkdir -p '..sh_esc_paste)
                    end

                    -- Remember the buffer we're currently viewing
                    buffers.push(buffers.main, vim.api.nvim_win_get_buf(0))
                    -- And follow the path!
                    vim.cmd(':e '..paste..'/'..filename)
                end

            -- Otherwise, if links are interpreted rel to first-opened file
            elseif links_relative_to == 'current' then

                -- Get the path of the current file
                local cur_file = vim.api.nvim_buf_get_name(0)

                -- Get the directory the current file is in
                local cur_file_dir = string.match(cur_file, '(.*)/.-$')

                -- Paste together the directory of the current file and the
                -- directory path provided in the link
                local paste = cur_file_dir..'/'..path

                -- Remember the buffer we're currently viewing
                buffers.push(buffers.main, vim.api.nvim_win_get_buf(0))
                -- And follow the path!
                vim.cmd(':e '..paste)

            else -- Otherwise, links are relative to the first-opened file

                -- Paste the dir of the first-opened file and path in the link
                local paste = initial_dir..'/'..path

                -- Remember the buffer we're currently viewing
                buffers.push(buffers.main, vim.api.nvim_win_get_buf(0))
                -- And follow the path!
                vim.cmd(':e '..paste)

            end

        elseif path_type(path) == 'url' then

            local se_path = vim.fn.shellescape(path)
            path_handler(se_path)

        elseif path_type(path) == 'file' then

            -- Get what's after the file: tag
            local real_path = string.match(path, '^file:(.*)')

            -- Check if path provided is absolute or relative to $HOME
            if string.match(real_path, '^~/') or string.match(real_path, '^/') then

                local se_paste = escape_chars(real_path)

                -- If the path starts with a tilde, replace it w/ $HOME
                if string.match(real_path, '^~/') then
                    se_paste = string.gsub(se_paste, '^~/', '$HOME/')
                end

                -- If the file exists, handle it; otherwise, print a warning
                -- Don't want to use the shell-escaped version; it will throw a
                -- false alert if there are escape chars
                if does_exist(se_paste, "f") == false and
                   does_exist(se_paste, "d") == false then
                    print("⬇️ : "..se_paste.." doesn't seem to exist!")
                else
                    path_handler(se_paste)
                end

            elseif links_relative_to == 'current' then

                -- Get the path of the current file
                local cur_file = vim.api.nvim_buf_get_name(0)

                -- Get the directory the current file is in
                local cur_file_dir = string.match(cur_file, '(.*)/.-$')

                -- Paste together the directory of the current file and the
                -- directory path provided in the link
                local paste = cur_file_dir..'/'..real_path

                -- Escape special characters
                local se_paste = escape_chars(paste)
                -- Pass to the path_handler function
                path_handler(se_paste)

            else
                -- Otherwise, links are relative to the first-opened file
                -- Paste together the directory of the first-opened file
                -- and the path in the link
                local paste = initial_dir..'/'..real_path

                -- Escape special characters
                local se_paste = escape_chars(paste)
                -- Pass to the path_handler function
                path_handler(se_paste)

            end
        elseif path_type(path) == 'anchor' then
            cursor.toHeading(path)
        elseif path_type(path) == 'citation' then
            -- Pass to the citation_handler function from bib.lua to get
            -- highest-priority field in bib entry (if it exists)
            local field = bib.citationHandler(
                escape_lua_chars(path)
            )
            -- Use this function to do sth with the information returned (if any)
            if field then
                M.followPath(field)
            end
        end
    else
        links.createLink()
    end
end

-- Return all the functions added to the table M!
return M
