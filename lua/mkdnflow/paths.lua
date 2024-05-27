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
local this_os_err = '⬇️ Function unavailable for ' .. this_os .. '. Please file an issue.'
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
local links_config = require('mkdnflow').config.links
local new_file_config = require('mkdnflow').config.new_file_template
local implicit_extension = links_config.implicit_extension
local link_transform = links_config.transform_implicit

-- Load modules
local utils = require('mkdnflow.utils')
local buffers = require('mkdnflow.buffers')
local bib = require('mkdnflow.bib')
local cursor = require('mkdnflow.cursor')
local links = require('mkdnflow.links')

local tobool = function(str)
    local bool = false
    str = (str:gsub(' ', ''))
    if str == 'true' then
        bool = true
    end
    return bool
end

--[[
exists() determines whether the path specified as the argument exists
NOTE: Assumes that the initially opened file is in an existing directory!
--]]
local exists = function(path, unit_type)
    -- If type is not specified, use "d" (directory) by default
    unit_type = unit_type or 'd'
    local handle
    if this_os:match('Windows') then
        if unit_type == 'd' then
            unit_type = '\\'
        else
            unit_type = ''
        end
        local command = 'IF exist "' .. path .. unit_type .. '" ( echo true ) ELSE ( echo false )'
        handle = io.popen(command)
    else
        -- Use the shell to determine if the path exists
        handle = io.popen(
            'if [ -'
                .. unit_type
                .. ' '
                .. vim.fn.shellescape(path)
                .. ' ]; then echo true; else echo false; fi'
        )
    end
    local output = handle:read('*l')
    io.close(handle)
    -- Get the contents of the first (only) line & store as a boolean
    output = tobool(output)
    -- Return the existence property of the path
    return output
end

local M = {}

--[[
resolve_notebook_path() takes a link source and determines what its absolute reference is
--]]
local resolve_notebook_path = function(path, sub_home_var)
    sub_home_var = sub_home_var or false
    local derived_path = path
    if this_os:match('Windows') then
        derived_path = derived_path:gsub('/', '\\')
        if derived_path:match('^~\\') then
            derived_path = string.gsub(derived_path, '^~\\', vim.loop.os_homedir() .. '\\')
        end
    end
    -- Decide what to pass to internal_open function
    if derived_path:match('^~/') or derived_path:match('^/') or derived_path:match('^%u:\\') then
        derived_path = sub_home_var and string.gsub(derived_path, '^~/', '$HOME/') or derived_path
    elseif perspective.priority == 'root' and root_dir then
        -- Paste root directory and the directory in link
        derived_path = root_dir .. sep .. derived_path
    -- See if the path exists
    elseif
        perspective.priority == 'first'
        or (perspective.priority == 'root' and perspective.fallback == 'first')
    then
        -- Paste together the dir of first-opened file & dir in link path
        derived_path = initial_dir .. sep .. derived_path
    else -- Otherwise, they want it relative to the current file
        -- Path of current file
        local cur_file = vim.api.nvim_buf_get_name(0)
        -- Directory current file is in
        local cur_file_dir = string.match(cur_file, '(.*)' .. sep .. '.-$')
        -- Paste together dir of current file & dir path provided in link
        if cur_file_dir then
            derived_path = cur_file_dir .. sep .. derived_path
        end
    end
    return derived_path
end

local enter_internal_path = function() end

--[[
formatTemplate() takes the user-provided (or default) template and replaces it
with the user-specified (or default) value
--]]
M.formatTemplate = function(timing, template)
    timing = timing or 'before'
    template = template or new_file_config.template
    for placeholder_name, replacement in pairs(new_file_config.placeholders[timing]) do
        if replacement == 'link_title' then
            replacement = links.getLinkPart(links.getLinkUnderCursor(), 'name')
        elseif replacement == 'os_date' then
            replacement = os.date('%Y-%m-%d')
        end
        template = string.gsub(template, '{{%s?' .. placeholder_name .. '%s?}}', replacement)
    end
    return template
end

--[[
vim_open() takes a path to a notebook-internal file and (optionally) an
anchor and opens it in nvim.
--]]
local vim_open = function(path, anchor)
    if this_os:match('Windows') then
        path = path:gsub('/', '\\')
    end

    path = resolve_notebook_path(path)

    -- See if a directory is part of the path
    local dir = string.match(path, '(.*)' .. sep .. '.-$')
    -- If there's a dir & user wants dirs created, do so if necessary
    if dir and create_dirs then
        if not exists(dir) then
            if this_os:match('Windows') then
                os.execute('mkdir "' .. dir .. '"')
            else
                os.execute('mkdir -p ' .. vim.fn.shellescape(dir))
            end
        end
    end
    -- If the path starts with a tilde, replace it w/ $HOME
    if this_os == 'Linux' or this_os == 'Darwin' then
        if string.match(path, '^~/') then
            path = string.gsub(path, '^~/', '$HOME/')
        end
    end
    local path_w_ext
    if not path:match('%.[%a]+$') then
        if implicit_extension then
            path_w_ext = path .. '.' .. implicit_extension
        else
            path_w_ext = path .. '.md'
        end
    else
        path_w_ext = path
    end
    if exists(path, 'd') and not exists(path_w_ext, 'f') then
        -- Looks like this links to a directory, possibly a notebook
        enter_internal_path(path)
    else
        -- Push the current buffer name onto the main buffer stack
        buffers.push(buffers.main, vim.api.nvim_win_get_buf(0))
        -- Prepare to inject the filled-out template at the top of the new file
        local template
        if new_file_config.use_template then
            if not exists(path_w_ext, 'f') then
                template = M.formatTemplate('before')
            end
        end
        vim.cmd(':e ' .. path_w_ext)
        M.updateDirs()
        -- Inject the template
        if new_file_config.use_template and template then
            template = M.formatTemplate('after', template)
            local lines = utils.strSplit(template, '\n')
            vim.api.nvim_buf_set_lines(0, 0, #template, false, lines)
        end
        if anchor and anchor ~= '' then
            if not cursor.toId(anchor) then
                cursor.toHeading(anchor)
            end
        end
    end
end

--[[
enter_internal_path() takes a path and opens a dialog in the command line that
asks the user to complete the path. Called when the path goes to a directory
in the notebook, rather than a file.
--]]
enter_internal_path = function(path)
    path = path:match(sep .. '$') ~= nil and path or path .. sep
    local input_opts = {
        prompt = '⬇️  Name of file in directory to open or create: ',
        default = path,
        completion = 'file',
    }
    vim.ui.input(input_opts, function(response)
        if response ~= nil and response ~= path .. sep then
            internal_open(response)
            vim.api.nvim_command('normal! :')
        end
    end)
end

--[[
system_open() handles vim-external paths, including local files or web URLs
Returns nothing
--]]
local system_open = function(path, type)
    local shell_open = function(path_)
        if this_os == 'Linux' then
            vim.api.nvim_command('silent !xdg-open ' .. vim.fn.shellescape(path_, true))
        elseif this_os == 'Darwin' then
            vim.api.nvim_command('silent !open ' .. vim.fn.shellescape(path_, true) .. ' &')
        elseif this_os:match('Windows') then
            os.execute('cmd.exe /c "start "" "' .. path_ .. '"')
        else
            if not silent then
                vim.api.nvim_echo({ { this_os_err, 'ErrorMsg' } }, true, {})
            end
        end
    end
    -- If the file exists, open it; otherwise, issue a warning
    if type == 'url' then
        shell_open(path)
    elseif exists(path, 'f') == false and exists(path, 'd') == false then
        if not silent then
            vim.api.nvim_echo(
                { { '⬇️  ' .. path .. " doesn't seem to exist!", 'ErrorMsg' } },
                true,
                {}
            )
        end
    else
        shell_open(path)
    end
end

--[[
handle_external_file() takes a path to a non-notebook file and determines how to open it:
--]]
local handle_external_file = function(path)
    -- Get what's after the file: tag
    local real_path = string.match(path, '^file:(.*)')
    if this_os:match('Windows') then
        real_path = real_path:gsub('/', '\\')
        if real_path:match('^~\\') then
            real_path = string.gsub(real_path, '^~\\', vim.loop.os_homedir() .. '\\')
        end
    end
    -- Check if path provided is absolute or relative to $HOME
    if real_path:match('^~/') or real_path:match('^/') or real_path:match('^%u:\\') then
        if this_os:match('Windows') then
            system_open(real_path)
        else
            -- If the path starts with a tilde, replace it w/ $HOME
            if string.match(real_path, '^~/') then
                real_path = string.gsub(real_path, '^~/', '$HOME/')
            end
        end
    elseif perspective.priority == 'root' and root_dir then
        -- Paste together root directory path and path in link and escape
        real_path = root_dir .. sep .. real_path
    elseif
        perspective.priority == 'first'
        or (perspective.priority == 'root' and perspective.fallback == 'first')
    then
        -- Otherwise, links are relative to the first-opened file, so
        -- paste together the directory of the first-opened file and the
        -- path in the link and escape for the shell
        real_path = initial_dir .. sep .. real_path
    else
        -- Get the path of the current file
        local cur_file = vim.api.nvim_buf_get_name(0)
        -- Get the directory the current file is in and paste together the
        -- directory of the current file and the directory path provided in the
        -- link, and escape for shell
        local cur_file_dir = string.match(cur_file, '(.*)' .. sep .. '.-$')
        real_path = cur_file_dir .. sep .. real_path
    end
    -- Pass to the system_open() function
    if real_path then
        system_open(real_path)
    end
end

--[[
updateDirs() updates the working directory after switching notebooks or notebook
folders if nvim_wd_heel is true.
--]]
M.updateDirs = function()
    local wd
    -- See if the new file is in a different root directory
    if perspective.update or perspective.nvim_wd_heel then
        if perspective.priority == 'root' then
            local cur_file = vim.api.nvim_buf_get_name(0)
            if not root_dir or not cur_file:match(root_dir) then
                -- Get the new root dir, if there is one
                local dir = cur_file:match('(.*)' .. sep .. '.-')
                if perspective.update then
                    root_dir =
                        require('mkdnflow').utils.getRootDir(dir, perspective.root_tell, this_os)
                    if root_dir then
                        local name = root_dir:match('.*' .. sep .. '(.*)') or root_dir
                        if not silent then
                            vim.api.nvim_echo({ { '⬇️  Notebook: ' .. name } }, true, {})
                        end
                        wd = root_dir
                    else
                        if not silent then
                            vim.api.nvim_echo({
                                {
                                    '⬇️  No notebook found. Fallback perspective: '
                                        .. perspective.fallback,
                                    'WarningMsg',
                                },
                            }, true, {})
                            if perspective.fallback == 'first' and perspective.nvim_wd_heel then
                                wd = initial_dir
                            elseif perspective.nvim_wd_heel then -- Otherwise, set wd to directory the current buffer is in
                                wd = dir
                            end
                        end
                    end
                end
            end
        elseif perspective.priority == 'first' and perspective.nvim_wd_heel then
            wd = initial_dir
        elseif perspective.nvim_wd_heel then
            local cur_file = vim.api.nvim_buf_get_name(0)
            wd = cur_file:match('(.*)' .. sep .. '.-$')
        end
        if perspective.nvim_wd_heel and wd then
            vim.api.nvim_set_current_dir(wd)
        end
    end
end

--[[
pathType() determines what kind of path is in a url
Returns a string:
     1. 'file' if the path has the 'file:' prefix,
     2. 'url' is the result of hasUrl(path) is true
     3. 'nb_page' if (1) and (2) aren't true
--]]
M.pathType = function(path, anchor)
    if not path then
        return nil
    elseif string.find(path, '^file:') then
        return 'file'
    elseif links.hasUrl(path) then
        return 'url'
    elseif string.find(path, '^@') then
        return 'citation'
    elseif path == '' and anchor then
        return 'anchor'
    else
        return 'nb_page'
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

--[[
handlePath() does something with the path in the link under the cursor:
     1. Creates the file specified in the path, if the path is determined to
        be a notebook page,
     2. Uses system_open() to open the URL specified in the path, if the path
        is determined to be a URL, or
     3. Uses system_open() to open a local file at the specified path via the
        system's default application for that filetype, if the path is dete-
        rmined to be neither the filename for a text file nor a URL.
Returns nothing
--]]
M.handlePath = function(path, anchor)
    anchor = anchor or false
    path = M.transformPath(path)
    local path_type = M.pathType(path, anchor)
    -- Handle according to path type
    if path_type == 'nb_page' then
        vim_open(path, anchor)
    elseif path_type == 'url' then
        system_open(path .. (anchor or ''), 'url')
    elseif path_type == 'file' then
        handle_external_file(path)
    elseif path_type == 'anchor' then
        -- Send cursor to matching heading
        if not cursor.toId(anchor, 1) then
            cursor.toHeading(anchor)
        end
    elseif path_type == 'citation' then
        -- Retrieve highest-priority field in bib entry (if it exists)
        local field = bib.handleCitation(path)
        -- Use this function to do sth with the information returned (if any)
        if field then
            M.handlePath(field)
        end
    end
end

--[[
truncate_path() cuts out the middle of a path for improved presentation of long
paths.
--]]
local truncate_path = function(oldpath, newpath)
    local difference = ''
    local last_slash = string.find(string.reverse(newpath), sep)
    last_slash = last_slash and #newpath - last_slash + 1 or nil
    local continue = true
    local char = 1
    while continue do
        local newpath_char = newpath:sub(char, char)
        if oldpath:sub(char, char) ~= newpath_char and char <= #newpath then
            continue = false
        else
            char = char + 1
        end
    end
    if char > last_slash then
        difference = string.sub(newpath, last_slash)
    else
        difference = string.sub(newpath, char)
    end
    return difference
end

--[[
moveSource() renames the source part of a link and simultaneously renames and/or
moves the file the link refers to.
--]]
M.moveSource = function()
    local derive_path = function(source, type)
        if type == 'file' then
            source = source:gsub('^file:', '')
        end
        return resolve_notebook_path(source, true)
    end
    local confirm_and_execute = function(
        derived_source,
        source,
        derived_goal,
        anchor,
        location,
        start_row,
        start_col,
        end_row,
        end_col
    )
        local truncated_goal = '...' .. truncate_path(derived_source, derived_goal)
        local prompt = "⬇️  Move '"
            .. derived_source
            .. "' ("
            .. source
            .. ") to '"
            .. truncated_goal
            .. "' ("
            .. location
            .. ')? [y/n] '
        local cmdheight = vim.api.nvim_get_option('cmdheight')
        local str_width, win_width = vim.api.nvim_strwidth(prompt), vim.api.nvim_win_get_width(0)
        local rows_needed = str_width / win_width
        if rows_needed / math.floor(rows_needed) > 1.0 then
            rows_needed = math.floor(rows_needed) + 1
        else
            rows_needed = math.floor(rows_needed)
        end
        vim.api.nvim_set_option('cmdheight', rows_needed)
        vim.ui.input({ prompt = prompt }, function(response)
            if response == 'y' then
                if this_os:match('Windows') then
                    os.execute('move "' .. derived_source .. '" "' .. derived_goal .. '"')
                else
                    os.execute(
                        'mv '
                            .. utils.escapeChars(derived_source)
                            .. ' '
                            .. utils.escapeChars(derived_goal)
                    )
                end
                -- Change the link content
                vim.api.nvim_buf_set_text(
                    0,
                    start_row - 1,
                    start_col - 1,
                    end_row - 1,
                    end_col,
                    { location .. anchor }
                )
                -- Clear the prompt & print sth
                -- Reset cmdheight value
                vim.api.nvim_command('normal! :')
                vim.api.nvim_set_option('cmdheight', cmdheight)
                vim.api.nvim_echo(
                    { { '⬇️  Success! File moved to ' .. derived_goal } },
                    true,
                    {}
                )
            else
                -- Clear the prompt & print sth
                -- Reset cmdheight value
                vim.api.nvim_command('normal! :')
                vim.api.nvim_set_option('cmdheight', cmdheight)
                vim.api.nvim_echo({ { '⬇️  Aborted', 'WarningMsg' } }, true, {})
            end
        end)
    end
    -- Retrieve source from link
    local source, anchor, link_type, start_row, start_col, end_row, end_col =
        links.getLinkPart(links.getLinkUnderCursor(), 'source')
    if source then
        -- Determine type of source
        local source_type = M.pathType(source)
        -- Modify source path in the same way as when links are interpreted
        local derived_source = M.transformPath(source)
        if not derived_source:match('%..+$') then
            if implicit_extension then
                derived_source = derived_source .. '.' .. implicit_extension
            else
                derived_source = derived_source .. '.md'
            end
        end
        -- If it's a file, determine the full path of the source using perspective
        derived_source = derive_path(derived_source, source_type)
        -- Ask user to edit name in console (only display what's in the link)
        local input_opts = {
            prompt = '⬇️  Move to: ',
            default = source,
            completion = 'file',
        }
        -- Determine what to do based on user input
        vim.ui.input(input_opts, function(location)
            if location then
                local derived_goal = M.transformPath(location)
                if not derived_goal:match('%..+$') then
                    if implicit_extension then
                        derived_goal = derived_goal .. '.' .. implicit_extension
                    else
                        derived_goal = derived_goal .. '.md'
                    end
                end
                derived_goal = derive_path(derived_goal, M.pathType(derived_goal))
                local source_exists = exists(derived_source, 'f')
                local goal_exists = exists(derived_goal, 'f')
                local dir = string.match(derived_goal, '(.*)' .. sep .. '.-$')
                if goal_exists then -- If the goal location already exists, abort
                    vim.api.nvim_command('normal! :')
                    vim.api.nvim_echo(
                        { { "⬇️  '" .. location .. "' already exists! Aborting.", 'WarningMsg' } },
                        true,
                        {}
                    )
                elseif source_exists then -- If the source location exists, proceed
                    if dir then -- If there's a directory in the goal location, ...
                        local to_dir_exists = exists(dir, 'd')
                        if not to_dir_exists then
                            if create_dirs then
                                local path_to_file = vim.fn.shellescape(dir)
                                local command = this_os:match('Windows') and 'mkdir' or 'mkdir -p'
                                os.execute(command .. ' ' .. path_to_file)
                            else
                                vim.api.nvim_command('normal! :')
                                vim.api.nvim_echo({
                                    {
                                        "⬇️  The goal directory doesn't exist. Set create_dirs to true for automatic directory creation.",
                                    },
                                })
                            end
                        else
                            confirm_and_execute(
                                derived_source,
                                source,
                                derived_goal,
                                anchor,
                                location,
                                start_row,
                                start_col,
                                end_row,
                                end_col
                            )
                        end
                    else -- Move
                        confirm_and_execute(
                            derived_source,
                            source,
                            derived_goal,
                            anchor,
                            location,
                            start_row,
                            start_col,
                            end_row,
                            end_col
                        )
                    end
                else -- Otherwise, the file we're trying to move must not exist
                    -- Clear the prompt & send a warning
                    vim.api.nvim_command('normal! :')
                    vim.api.nvim_echo(
                        {
                            {
                                '⬇️  ' .. derived_source .. " doesn't seem to exist! Aborting.",
                                'WarningMsg',
                            },
                        },
                        true,
                        {}
                    )
                end
            end
        end)
    else
        vim.api.nvim_echo(
            { { "⬇️  Couldn't find a link under the cursor to rename!", 'WarningMsg' } },
            true,
            {}
        )
    end
end

-- Return all the functions added to the table M!
return M
