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
-- Get a list of bib files in the root directory
local bib_paths = {}
if find_in_root and root_dir then
    local pfile = io.popen('ls -a "'..root_dir..'"')
    -- Check the list of files for any bib files
    for filename in pfile:lines() do
        local match = filename:match('%.bib$')
        if match then
            table.insert(bib_paths, root_dir..'/'..filename)
        end
    end
    -- Add the default bib path too
    table.insert(bib_paths, bib_path)
end

--[[
find_bib_entry() takes a citation
--]]
-- Citation finder function
local find_bib_entry = function(citation)
    -- Remove @
    local citekey = string.sub(citation, 2, -1)
    -- Open bibliography file
    local bib_file
    local current_bib_file = 0
    if find_in_root and root_dir then
        bib_file = io.open(bib_paths[1], 'r')
        current_bib_file = 1
    else
        if bib_path then bib_file = io.open(bib_path, 'r') end
    end
    -- If the file exists, search it line-by-line for the citekey
    if bib_file then
        local unfound = true
        while unfound do
            local line = bib_file:read('*l')
            if line then
                local begin_entry = string.find(line, '^@')
                if begin_entry then
                    local match = string.match(line, '{%s-'..citekey..'%s-,')
                    if match then
                        --vim.api.nvim_echo({{"Found the entry for "..citation.."!"}}, true, {}) -- TEST
                        local bib_entry = {}
                        -- Save the citekey
                        bib_entry.citekey = citekey
                        -- Extract the type
                        bib_entry.type = string.sub(string.match(line, '^@.+{'), 2, -2)
                        -- Go through and save the relevant information in the entry
                        local brace_counter = 1
                        while brace_counter > 0 do
                            -- Read the next line
                            line = bib_file:read('*l')
                            local _, open_braces = line:gsub('{', '')
                            local _, close_braces = line:gsub('}', '')
                            brace_counter = brace_counter + open_braces - close_braces
                            -- Get the first unbroken string of word characters in the line
                            local field = string.match(line, '%a+')
                            if field then
                                local entry = string.sub(string.match(line, '{.*}'), 2, -2)
                                bib_entry[string.lower(field)] = entry
                            end
                        end
                        unfound = false
                        bib_file:close()
                        -- Return the whole entry for that citekey
                        return citekey, bib_entry
                    end
                end
            else
                if current_bib_file == #bib_paths then
                    unfound = nil
                    bib_file:close()
                    if not silent then vim.api.nvim_echo({{'⬇️  No entry found for "'..citekey..'"!', 'WarningMsg'}}, true, {}) end
                else
                    bib_file:close()
                    current_bib_file = current_bib_file + 1
                    bib_file = io.open(bib_paths[current_bib_file], 'r')
                end
            end
        end
    else
        if bib_path == nil then
            bib_path = '<nil>'
        else
            bib_path = '"'..bib_path..'"'
        end
        if not silent then vim.api.nvim_echo({{'⬇️  Could not find a bib file. The default bib path is currently '..bib_path..'. Fix the path or add a default bib path by specifying a value for the "default_bib_path" key.', 'ErrorMsg'}}, true, {}) end
    end
end

local M = {}

--[[
citationHandler() takes a citation passes it to find_bib_entry. If a match
is found in the bib file, this function decides what to return depending option
the information found in that bib entry. If nothing relevant was found, it
prints a warning message and returns nothing.
--]]
M.citationHandler = function(citation)
    local citekey, bib_entry = find_bib_entry(citation)
    if citekey and bib_entry then
        if bib_entry['file'] then
            local path = 'file:'..bib_entry['file']
            return path
        elseif bib_entry['url'] then
            local url = bib_entry['url']
            return url
        elseif bib_entry['doi'] then
            local doi = 'https://doi.org/'..bib_entry['doi']
            return doi
        elseif bib_entry['howpublished'] then
            local howpublished = bib_entry['howpublished']
            return howpublished
        else
            if not silent then vim.api.nvim_echo({{'⬇️  Bib entry with citekey "'..citekey..'" had no relevant content!', 'WarningMsg'}}, true, {}) end
            return nil
        end
    end
end

-- Return everything added to the table M
return M
