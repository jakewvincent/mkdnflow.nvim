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
local bib_path = require('mkdnflow').config.default_bib_path

--[[
find_bib_entry() takes a citation
--]]
-- Citation finder function
local find_bib_entry = function(citation)
    -- Remove @
    local citekey = string.sub(citation, 2, -1)
    -- Open bibliography file
    local bib_file = io.open(bib_path, 'r')
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
                        --print("Found the entry for "..citation.."!") -- TEST
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
                unfound = nil
                bib_file:close()
                print('⬇️ : No entry found for "'..citekey..'"!')
            end
        end
    else
        print('⬇️ : Could not find a bib file. The default bib path is currently "'..bib_path..'". Fix the path or add a default bib path by specifying a value for the "default_bib_path" key.')
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
            print('⬇️ : Bib entry with citekey "'..citekey..'" had no relevant content!')
            return nil
        end
    end
end

-- Return everything added to the table M
return M
