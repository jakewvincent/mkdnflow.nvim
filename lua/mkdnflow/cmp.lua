-- mkdnflow.nvim (Tools for personal markdown notebook navigation and management)
-- Copyright (C) 2022-2023 Jake W. Vincent <https://github.com/jakewvincent>
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

local mkdnflow_root_dir = require('mkdnflow').root_dir
-- Only try to load bib paths if the bib module is enabled
local bib_paths = require('mkdnflow').bib and require('mkdnflow').bib.bib_paths or nil
local plenary_scandir = require('plenary').scandir.scan_dir
local cmp = require('cmp')
local extension = '.md' -- Keep the '.'

local transform_explicit = require('mkdnflow').config.links.transform_explicit

local function get_files_items()
    local filepaths_in_root = plenary_scandir(mkdnflow_root_dir)
    local items = {}
    -- Iterate over files in the root directory & prepare for completion (if md file)
    for _, path in ipairs(filepaths_in_root) do
        if vim.endswith(path, extension) then
            local item = {}
            -- Absolute path of the file
            item.path = path
            -- Anything except / and \ (\\) followed by the extension so that folders will be excluded
            -- from the label
            item.label = path:match('([^/^\\]+)' .. extension .. '$')
            local explicit_link = transform_explicit and transform_explicit(item.label) .. extension or item.label .. extension
            -- Text should be inserted in markdown format
            item.insertText = '[' .. item.label .. '](' .. explicit_link .. ')'
            -- For beautification
            item.kind = cmp.lsp.CompletionItemKind.File

            local filepath = item.path
            local binary = assert(io.open(filepath, 'rb'))
            local first_kb = binary:read(1024)

            -- Close the file
            binary:close()

            local contents = {}
            -- Add to the table if it's not an empty file
            if first_kb then
                for content in first_kb:gmatch('[^\r\n]+') do
                    table.insert(contents, content)
                end
            end

            item.documentation = { kind = cmp.lsp.MarkupKind.Markdown, value = first_kb }

            table.insert(items, item)
        end
    end
    return items
end

-- Remove newline chars and excessive whitespace. Will be used in parse_bib function.
local function clean(text)
    if text then
        text = text:gsub('\n', ' ')
        return text:gsub('%s%s+', ' ')
    else
        return text
    end
end

-- Parses the .bib file, formatting the completion item
-- Adapted from http://rgieseke.github.io/ta-bibtex/
local function parse_bib(filename)
    local items = {}
    local file = io.open(filename, 'rb')
    local bibentries = file:read('*all')
    file:close()
    for bibentry in bibentries:gmatch('@.-\n}\n') do
        local item = {}

        local title = clean(bibentry:match('title%s*=%s*["{]*(.-)["}],?')) or ''
        local author = clean(bibentry:match('author%s*=%s*["{]*(.-)["}],?')) or ''
        local year = bibentry:match('year%s*=%s*["{]?(%d+)["}]?,?') or ''

        local doc = { '**' .. title .. '**', '', '*' .. author .. '*', year }

        item.documentation = {
            kind = cmp.lsp.MarkupKind.Markdown,
            value = table.concat(doc, '\n'),
        }
        item.label = '@' .. bibentry:match('@%w+{(.-),')
        item.kind = cmp.lsp.CompletionItemKind.Reference
        item.insertText = item.label

        table.insert(items, item)
    end
    return items
end

local source = {}

source.new = function()
    return setmetatable({}, { __index = source })
end

function source:complete(params, callback)
    local items = get_files_items()
    if bib_paths then
        -- For bib files, there are three lists (tables) in mkdnflow where we might find the paths for a bib file
        if bib_paths.default then
            for _, v in pairs(bib_paths.default) do
                local bib_items_default = parse_bib(v)
                for _, item in ipairs(bib_items_default) do
                    table.insert(items, item)
                end
            end
        end
        if bib_paths.root then
            for _, v in pairs(bib_paths.root) do
                local bib_items_root = parse_bib(v)
                for _, item in ipairs(bib_items_root) do
                    table.insert(items, item)
                end
            end
        end
        if bib_paths.yaml then
            for _, v in pairs(bib_paths.yaml) do
                local bib_items_yaml = parse_bib(v)
                for _, item in ipairs(bib_items_yaml) do
                    table.insert(items, item)
                end
            end
        end
    end
    callback(items)
end

-- Register this as a completion source
cmp.register_source('mkdnflow', source.new())
