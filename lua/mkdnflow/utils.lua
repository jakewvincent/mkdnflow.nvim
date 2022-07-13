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

local M = {}

-- Function to merge the user_config with the default config
M.mergeTables = function(defaults, user_config)
    for k, v in pairs(user_config) do
        if type(v) == 'table' then
            if type(defaults[k] or false) == 'table' then
                M.mergeTables(defaults[k] or {}, user_config[k] or {})
            else
                defaults[k] = v
            end
        else
            defaults[k] = v
        end
    end
    return(defaults)
end

-- Private function to detect the extension of a filename passed as a string
M.getFileType = function(string)
    local ext = string:match("^.*%.(.+)$")
    return(ext ~= nil and string.lower(ext) or '')
end

-- Public function to identify root directory on a unix or Windows machine
M.getRootDir = function(dir, root_tell, os)
    local drive = dir:match('^%u')
    -- List files in directory
    local search_is_on, root = true, nil
    -- Until the root directory is found, keep looking higher and higher
    -- each pass
    while search_is_on do
        -- Get the output of running ls -a in dir
        local pfile
        if os:match('Windows') then
            pfile = io.popen('dir /b "'..dir..'"')
        else
            pfile = io.popen('ls -a "'..dir..'"')
        end
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
            if os:match('Windows') then
                if dir == drive..':\\' then
                    -- If we've reached the highest directory possible, call off
                    -- the search and return nothing
                    search_is_on = false
                    return(nil)
                else
                    -- If there's still more to remove, remove it
                    dir = dir:match('(.*)\\')
                    -- If dir is an empty string, look for the tell in *root* root
                    if dir == drive..':' then dir = drive..':\\' end
                end
            else
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
            end
        else
            return(root)
        end
    end
end


M.moduleAvailable = function(name)
  if package.loaded[name] then
    return true
  else
    for _, searcher in ipairs(package.searchers or package.loaders) do
      local loader = searcher(name)
      if type(loader) == 'function' then
        package.preload[name] = loader
        return true
      end
    end
    return false
  end
end

M.luaEscape = function(string)
    -- Which characters to match
    local chars = "[-.'\"+?%%]"
    -- Set up table of replacements
    local replacements = {
        ["-"] = "%-",
        ["."] = "%.",
        ["'"] = "\'",
        ['"'] = '\"',
        ['+'] = '%+',
        ['?'] = '%?',
        ['%'] = '%%'
    }
    -- Do the replacement
    local escaped = string.gsub(string, chars, replacements)
    -- Return the new string
    return(escaped)
end

M.escapeChars = function(string)
    -- Which characters to match
    local chars = "[ '&()$#]"
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

return M
