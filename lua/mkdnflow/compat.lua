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

local utils = require('mkdnflow').utils
local silent = require('mkdnflow').config.silent
local warn = function(message)
    vim.api.nvim_echo({ { message, 'WarningMsg' } }, true, {})
end
-- Show a warning message if nvim < 0.7.x
if require('mkdnflow').nvim_version < 7 and not silent then
    warn(
        '⬇️  Not all Mkdnflow functionality will work for your current version of Neovim, including mappings. Please upgrade to Neovim >= 0.7 or make sure to set your mappings in your Neovim config.'
    )
end
local M = {}

--[[
userConfigCheck() will check a user config for particular settings that have
since been migrated to another setting or another format. It returns an equiva-
lent user config that is upgraded to the new format.
--]]
M.userConfigCheck = function(user_config)
    -- Check if to-do symbols are being customized but no values were provided
    -- for not_started, in_progress, and complete
    if user_config.to_do then
        if
            user_config.to_do.symbols
            and not (
                user_config.to_do.not_started
                or user_config.to_do.in_progress
                or user_config.to_do.complete
            )
        then
            if #user_config.to_do.symbols == 3 then
                user_config.to_do.not_started = user_config.to_do.symbols[1]
                user_config.to_do.in_progress = user_config.to_do.symbols[2]
                user_config.to_do.complete = user_config.to_do.symbols[3]
            elseif #user_config.to_do.symbols > 3 then
                local max = #user_config.to_do.symbols
                user_config.to_do.not_started = user_config.to_do.symbols[1]
                user_config.to_do.in_progress = user_config.to_do.symbols[2]
                user_config.to_do.complete = user_config.to_do.symbols[max]
            elseif #user_config.to_do.symbols == 2 then
                user_config.to_do.not_started = user_config.to_do.symbols[1]
                user_config.to_do.in_progress = user_config.to_do.symbols[1]
                user_config.to_do.complete = user_config.to_do.symbols[2]
            end
        end
    end

    -- Look for default bib path
    if user_config.default_bib_path then
        if user_config.default_bib_path == '' then
            user_config.bib.default_path = nil
        else
            user_config.bib.default_path = user_config.default_bib_path
        end
        warn(
            '⬇️  The default_bib_path key has now been migrated into the bib key under the default_path option. Please update your config. See :h mkdnflow-changes, commit e9f7815...'
        )
    end

    -- Look for link style
    if user_config.link_style then
        user_config.links.style = user_config.link_style
    end

    -- Look for implicit extension and remove periods
    if user_config.links then
        if user_config.links.implicit_extension then
            user_config.links.implicit_extension =
                string.gsub(user_config.links.implicit_extension, '%.', '')
        end
    end

    -- Look for links_relative_to
    if user_config.links_relative_to then
        user_config.perspective = user_config.links_relative_to
        warn(
            '⬇️  The links_relative_to key is now called "perspective". Please update your config. See :h mkdnflow-changes, commit e42290...'
        )
    end

    -- Look for wrap preferences
    if user_config.wrap_to_beginning or user_config.wrap_to_end then
        user_config.wrap = true
        warn(
            '⬇️  The wrap_to_beginning/end keys have been merged into a single "wrap" key. Please update your config. See :h mkdnflow-changes, commit 9068e1...'
        )
    end

    -- Inspect perspective setting, if specified
    if user_config.perspective then
        if type(user_config.perspective) ~= 'table' then
            warn(
                '⬇️  The perspective key (previously "links_relative_to") should now be associated with a table value. Please update your config. See :h mkdnflow-changes, commit 75c8ec...'
            )
            if user_config.perspective == 'current' then
                local table = {
                    priority = 'current',
                    fallback = 'first',
                }
                user_config.perspective = table
            elseif user_config.perspective == 'first' then
                local table = {
                    priority = 'first',
                    fallback = 'current',
                }
                user_config.perspective = table
            end
        end
        if user_config.perspective.vimwd_heel ~= nil then
            user_config.perspective['nvim_wd_heel'] = user_config.perspective.vimwd_heel
        end
    end

    -- Check for old use_mappings_table config option
    if user_config.use_mappings_table == false then
        if user_config.modules then
            user_config.modules.maps = false
        else
            user_config.modules = {
                maps = false,
            }
        end
    end

    -- Inspect mappings
    if user_config.mappings then
        local string = false
        for _, value in pairs(user_config.mappings) do
            if type(value) == 'string' then
                string = true
            end
        end
        if string then
            warn(
                '⬇️  In the mappings table, commands should now be associated with a table value instead of a string. See :h mkdnflow-changes, commit 436510...'
            )
            local compatible_mappings = {}
            for key, value in pairs(user_config.mappings) do
                if key == 'MkdnFollowLink' then
                    compatible_mappings[key] = { { 'n', 'v' }, value }
                else
                    compatible_mappings[key] = { 'n', value }
                end
            end
            user_config.mappings = compatible_mappings
        end
        -- If MkdnCR has a mapping, update it to MkdnImodeMultiFunc
        if user_config.mappings.MkdnCR then
            if user_config.mappings.MkdnEnter then
                if
                    user_config.mappings.MkdnEnter[2]:lower()
                    == user_config.mappings.MkdnCR[2]:lower()
                then
                    local mode = user_config.mappings.MkdnEnter[1]
                    local mapping = user_config.mappings.MkdnEnter[2]
                    if type(mode) == 'table' then
                        table.insert(mode, 'i')
                    else
                        mode = { mode, 'i' }
                    end
                    user_config.mappings.MkdnEnter = { mode, mapping }
                    warn(
                        '⬇️  Merging MkdnCR mapping (deprecated) with MkdnEnter. Consider merging these in your Mkdnflow config.'
                    )
                else
                    warn(
                        '⬇️  MkdnCR is deprecated in favor of MkdnEnter. Could not merge your mapping for MkdnCR with that for MkdnEnter because they have different key mappings.'
                    )
                end
            else
                local mode = user_config.mappings.MkdnCR[1]
                local mapping = user_config.mappings.MkdnCR[2]
                if type(mode) == 'table' then
                    table.insert(mode, 'n')
                    table.insert(mode, 'v')
                else
                    mode = { mode, 'n', 'v' }
                end
                if mapping:lower() ~= '<cr>' then
                    warn(
                        '⬇️  MkdnCR is deprecated in favor of MkdnEnter. Could not merge your mapping for MkdnCR with the default mapping for MkdnEnter because they have different key mappings.'
                    )
                else
                    warn(
                        '⬇️  Merging MkdnCR mapping (deprecated) with default mapping for MkdnEnter. Consider merging your MkdnCR mapping with a mapping for MkdnEnter in your Mkdnflow config.'
                    )
                    user_config.mappings.MkdnEnter = { mode, mapping }
                end
            end
            user_config.mappings.MkdnCR = nil
        end

        --
        local cmp, _ = pcall(require, 'cmp')
        if user_config.modules and user_config.modules.cmp and not cmp then
            vim.notify(
                "⬇️  cmp module is enabled, but require('cmp') failed.",
                vim.log.levels.WARN,
                {
                    title = "mkdnflow.nvim"
                }
            )
            user_config.cmp = false
        end
    end
    return user_config
end

return M
