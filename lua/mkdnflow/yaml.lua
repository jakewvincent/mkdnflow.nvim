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

local bib = require('mkdnflow').bib
local filetypes = require('mkdnflow').config.filetypes
local patterns = {}
for ext, value in pairs(filetypes) do
    if value then
        table.insert(patterns, '*.' .. ext)
    end
end

local M = {}

vim.api.nvim_create_autocmd('BufWinEnter', {
    pattern = patterns,
    callback = function()
        bib.bib_paths.yaml = {}
        local start, finish = M.hasYaml()
        if start then
            local yaml = M.ingestYamlBlock(start, finish)
            bib.bib_paths.yaml = yaml.bib
        end
    end,
})

M.hasYaml = function()
    local first_line, row, line_count =
        vim.api.nvim_buf_get_lines(0, 0, 1, false)[1], 1, vim.api.nvim_buf_line_count(0)
    if first_line:match('^---$') then
        local continue = true
        while continue and row <= line_count do
            local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
            if line:match('^---$') then
                continue = false
                return 0, row
            else
                row = row + 1
            end
        end
    end
end

M.ingestYamlBlock = function(start, finish)
    local yaml = {}
    if start and finish then
        local last_key
        for i = 0, finish, 1 do
            local line = vim.api.nvim_buf_get_lines(0, i, i + 1, false)[1]
            local key = line:match('^([%a_-]*):')
            local value = line:match('.*:%s?(.+)$')
            local item = line:match('^  %- (.*)')
            if item then
                print(item)
            end
            if key and value then
                yaml[key] = { value }
            elseif key and not item then
                last_key = key
                yaml[key] = {}
            elseif item and last_key then
                table.insert(yaml[last_key], item)
            end
        end
        return yaml
    end
end

return M
