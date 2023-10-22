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

-- Mkdnflow mappings
local config = require('mkdnflow').config
local nvim_version = require('mkdnflow').nvim_version
local command_deps = require('mkdnflow').command_deps
local extension_patterns = {}
for key, _ in pairs(config.filetypes) do
    table.insert(extension_patterns, '*.' .. key)
end

-- Enable mappings in buffers in which Mkdnflow activates
if nvim_version >= 7 then
    vim.api.nvim_create_augroup('MkdnflowMappings', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
        pattern = extension_patterns,
        callback = function()
            for command, mapping in pairs(config.mappings) do
                local available = true
                -- Check if the modules the command is dependent on are disabled by user
                if command_deps[command] then
                    for _, module in ipairs(command_deps[command]) do
                        if not config.modules[module] then
                            available = false
                        end
                    end
                end
                if available and mapping and type(mapping[1]) == 'table' then
                    for _, value in ipairs(mapping[1]) do
                        vim.api.nvim_buf_set_keymap(
                            0,
                            value,
                            mapping[2],
                            '<Cmd>:' .. command .. '<CR>',
                            { noremap = true }
                        )
                    end
                elseif available and type(mapping) == 'table' then
                    vim.api.nvim_buf_set_keymap(
                        0,
                        mapping[1],
                        mapping[2],
                        '<Cmd>:' .. command .. '<CR>',
                        { noremap = true }
                    )
                end
            end
        end,
    })
end
