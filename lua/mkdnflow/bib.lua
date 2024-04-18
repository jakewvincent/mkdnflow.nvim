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

-- Bibliography functions

-- Retrieve default bibliography path
local bib_path = require('mkdnflow').config.bib.default_path
local find_in_root = require('mkdnflow').config.bib.find_in_root
local root_dir = require('mkdnflow').root_dir
local silent = require('mkdnflow').config.silent
local this_os = require('mkdnflow').this_os
local yaml = require('mkdnflow').config.yaml
local utils = require('mkdnflow').utils

local M = {}

-- Get a list of bib files in the root directory
M.bib_paths = {
    default = {},
    root = {},
    yaml = {},
}

if find_in_root and root_dir then
    local pfile
    if this_os:match('Windows') then
        pfile = io.popen('dir /b "' .. root_dir .. '"')
    else
        pfile = io.popen('ls -a "' .. root_dir .. '"')
    end
    -- Check the list of files for any bib files
    for filename in pfile:lines() do
        local match = filename:match('%.bib$')
        if match then
            -- TODO: Make the following OS-agnostic
            table.insert(M.bib_paths.root, root_dir .. '/' .. filename)
        end
    end
    pfile:close()
end

-- Add the default bib path too
if type(bib_path) == 'table' then
    M.bib_paths.default = bib_path
else
    table.insert(M.bib_paths.default, bib_path)
end

local ingest_entry = function(text)
    local data = {}
    local citekey_found = false
    for line in text:gmatch('%s*(.-)\n') do
        if not citekey_found then
            local citekey = line:match('{(.-),')
            if citekey then
                citekey_found = true
                data.key = citekey
            end
        else
            local key = string.lower(line:match('^(.-)%s*='))
            local value = line:match('=%s*{(.-)},?')
            data[key] = value
        end
    end
    return data
end

local search_bib_file = function(path, citekey)
    local bib_file = io.open(path, 'r')
    if bib_file then
        local text = bib_file:read('*a')
        if text then
            local start, _ = string.find(text, '\n%s?@[%a]-{%s?' .. utils.luaEscape(citekey))
            if start then
                local match = text:match('%b{}', start)
                return match
            end
        end
        bib_file:close()
    else
        local bib_path_name
        if bib_path == nil then
            bib_path_name = '<nil>'
        else
            bib_path_name = '"' .. bib_path .. '"'
        end
        if not silent then
            vim.api.nvim_echo({
                {
                    '⬇️  Could not find a bib file. The default bib path is currently '
                        .. bib_path_name
                        .. '. Fix the path or add a default bib path by specifying a value for the "default_bib_path" key.',
                    'ErrorMsg',
                },
            }, true, {})
        end
        -- TODO: Make this section a little smarter. Change message depending on both bib_path and find_in_root.
    end
end

local search_bib_source = function(citekey, source)
    local i, continue = #M.bib_paths[source], true
    while continue and i <= #M.bib_paths[source] and i > 0 do
        local entry = search_bib_file(M.bib_paths[source][i], citekey)
        if entry then
            entry = ingest_entry(entry)
            continue = false
            return entry
        else
            i = i + 1
        end
    end
end

local find_bib_entry = function(citation)
    local citekey = string.sub(citation, 2, -1)
    local entry
    if yaml.bib.override and M.bib_paths.yaml[1] then
        entry = search_bib_source(citekey, 'yaml')
    elseif find_in_root and root_dir and M.bib_paths.root[1] then
        entry = search_bib_source(citekey, 'yaml')
            or search_bib_source(citekey, 'root')
            or search_bib_source(citekey, 'default')
    elseif M.bib_paths.yaml[1] or M.bib_paths.default[1] then
        entry = search_bib_source(citekey, 'yaml') or search_bib_source(citekey, 'default')
    else
        if not silent then
            vim.api.nvim_echo({
                {
                    '⬇️  Could not find a bib file. The default bib path is currently '
                        .. tostring(M.bib_paths.default[1])
                        .. '. Fix the path or add a default bib path by specifying a value for the "bib.default_path" key.',
                    'ErrorMsg',
                },
            }, true, {})
        end
        -- TODO: Make this section a little smarter. Change message depending on both bib_path and find_in_root.
    end
    if not silent and not entry then
        vim.api.nvim_echo(
            { { '⬇️  No entry found for "' .. citekey .. '"!', 'WarningMsg' } },
            true,
            {}
        )
    else
        return entry
    end
end

--[[
handleCitation() takes a citation passes it to find_bib_entry. If a match
is found in the bib file, this function decides what to return depending option
the information found in that bib entry. If nothing relevant was found, it
prints a warning message and returns nothing.
--]]
M.handleCitation = function(citation)
    local bib_entry = find_bib_entry(citation)
    if bib_entry then
        if bib_entry['file'] then
            local path = 'file:' .. bib_entry['file']
            return path
        elseif bib_entry['url'] then
            local url = bib_entry['url']
            return url
        elseif bib_entry['doi'] then
            local doi = 'https://doi.org/' .. bib_entry['doi']
            return doi
        elseif bib_entry['howpublished'] then
            local howpublished = bib_entry['howpublished']
            return howpublished
        else
            if not silent then
                vim.api.nvim_echo({
                    {
                        '⬇️  Bib entry with citekey "'
                            .. bib_entry.key
                            .. '" had no relevant content!',
                        'WarningMsg',
                    },
                }, true, {})
            end
            return nil
        end
    end
end

-- Return everything added to the table M
return M
