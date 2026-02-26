-- mkdnflow.nvim (Tools for fluent markdown notebook navigation and management)
-- Copyright (C) 2022-2024 Jake W. Vincent <https://github.com/jakewvincent>
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

-- ---------------------------------------------------------------------------
-- Local helpers
-- ---------------------------------------------------------------------------

--- Recursive deep equality check. Returns false for function values (not comparable).
---@param a any
---@param b any
---@return boolean
local function deepEqual(a, b)
    if type(a) ~= type(b) then
        return false
    end
    if type(a) == 'function' then
        return false
    end
    if type(a) ~= 'table' then
        return a == b
    end
    -- Both are tables: compare all keys in both directions
    for k, v in pairs(a) do
        if not deepEqual(v, b[k]) then
            return false
        end
    end
    for k, _ in pairs(b) do
        if a[k] == nil then
            return false
        end
    end
    return true
end

--- Retrieve a nested value from a table by key path.
---@param tbl table
---@param path string[] e.g. {'links', 'compact'}
---@return any value The value at that path, or nil
local function getPath(tbl, path)
    local current = tbl
    for _, key in ipairs(path) do
        if type(current) ~= 'table' then
            return nil
        end
        current = current[key]
    end
    return current
end

--- Format a key path as a dotted string for display.
---@param path string[]
---@return string
local function pathStr(path)
    return table.concat(path, '.')
end

--- Check if a table has only consecutive integer keys starting at 1.
---@param tbl table
---@return boolean
local function isArray(tbl)
    local n = 0
    for _ in pairs(tbl) do
        n = n + 1
    end
    for i = 1, n do
        if tbl[i] == nil then
            return false
        end
    end
    return n > 0
end

--- Determine whether a value should be compared atomically (not recursed into).
--- We check the defaults side rather than the user config side because the user's
--- config tables may have been mutated after setup (e.g., the to_do module adds
--- method functions onto the statuses array, polluting it with non-integer keys).
--- The defaults copy (init.default_config) is pristine and always reflects the
--- original structure.
---
--- This matters because mergeTables replaces arrays wholesale — individual elements
--- are NOT merged with their positional counterparts in the defaults. So a user
--- cannot remove a single field from an array element and expect it to be filled
--- in from defaults. Arrays must be compared as atomic units: either the entire
--- array matches the default (and is redundant) or it doesn't.
---@param v any The user config value
---@param default_val any The corresponding default config value
---@return boolean
local function isAtomicValue(v, default_val)
    if type(v) ~= 'table' or type(default_val) ~= 'table' then
        return true
    end
    -- If either side is an array, compare atomically. We check both because:
    -- - The defaults side is pristine and reliable
    -- - The user side may have been polluted with non-integer keys after setup
    return isArray(v) or isArray(default_val)
end

--- Walk user_config and find keys whose values match the corresponding default.
--- Returns a list of dotted key path strings.
---@param user_config table Post-compat user config (only keys the user set)
---@param defaults table The pristine default config
---@param prefix? string[] Accumulator for recursion
---@return string[] redundant List of dotted path strings
local function findRedundantDefaults(user_config, defaults, prefix)
    prefix = prefix or {}
    local redundant = {}
    for k, v in pairs(user_config) do
        local path = vim.list_extend(vim.deepcopy(prefix), { k })
        local default_val = defaults[k]
        if not isAtomicValue(v, default_val) then
            -- Both sides are dict-like tables: recurse to compare individual keys
            vim.list_extend(redundant, findRedundantDefaults(v, default_val, path))
        elseif deepEqual(v, default_val) then
            table.insert(redundant, pathStr(path))
        end
    end
    return redundant
end

--- Remove keys from user_config whose values match the corresponding default.
--- Prunes empty parent tables left behind.
---@param user_config table Post-compat user config (will be modified in place)
---@param defaults table The pristine default config
local function removeRedundantDefaults(user_config, defaults)
    for k, v in pairs(user_config) do
        local default_val = defaults[k]
        if not isAtomicValue(v, default_val) then
            removeRedundantDefaults(v, default_val)
            -- Prune if now empty
            if next(v) == nil then
                user_config[k] = nil
            end
        elseif deepEqual(v, default_val) then
            user_config[k] = nil
        end
    end
end

--- Serialize a Lua value to formatted source code.
---@param value any
---@param indent number Current indentation level
---@return string
local function serializeLua(value, indent)
    indent = indent or 1
    local pad = string.rep('    ', indent)
    local pad_inner = string.rep('    ', indent + 1)
    local t = type(value)

    if t == 'string' then
        -- Use single quotes, escape embedded single quotes and backslashes
        local escaped = value:gsub('\\', '\\\\'):gsub("'", "\\'"):gsub('\n', '\\n')
        return "'" .. escaped .. "'"
    elseif t == 'number' then
        return tostring(value)
    elseif t == 'boolean' then
        return tostring(value)
    elseif t == 'function' then
        return 'nil --[[ custom function: copy from your current config ]]'
    elseif t == 'table' then
        if next(value) == nil then
            return '{}'
        end
        local lines = {}
        if isArray(value) then
            for i, v in ipairs(value) do
                local serialized = serializeLua(v, indent + 1)
                local comma = i < #value and ',' or ','
                table.insert(lines, pad_inner .. serialized .. comma)
            end
        else
            -- Sort keys for deterministic output
            local keys = {}
            for k in pairs(value) do
                table.insert(keys, k)
            end
            table.sort(keys, function(a, b)
                -- Sort: numbers first, then strings
                if type(a) ~= type(b) then
                    return type(a) == 'number'
                end
                return a < b
            end)
            for _, k in ipairs(keys) do
                local v = value[k]
                local key_str
                if type(k) == 'string' and k:match('^[%a_][%w_]*$') then
                    key_str = k
                else
                    key_str = '[' .. serializeLua(k, 0) .. ']'
                end
                local serialized = serializeLua(v, indent + 1)
                table.insert(lines, pad_inner .. key_str .. ' = ' .. serialized .. ',')
            end
        end
        return '{\n' .. table.concat(lines, '\n') .. '\n' .. pad .. '}'
    else
        return 'nil'
    end
end

-- ---------------------------------------------------------------------------
-- Health check
-- ---------------------------------------------------------------------------

--- Health check entry point, called by :checkhealth mkdnflow
function M.check()
    local mkdnflow = require('mkdnflow')

    -- == Environment ==
    vim.health.start('mkdnflow: environment')

    local nvim_ver = vim.version()
    if nvim_ver.minor >= 9 then
        vim.health.ok(
            string.format(
                'Neovim v%d.%d.%d (>= 0.9 required)',
                nvim_ver.major,
                nvim_ver.minor,
                nvim_ver.patch
            )
        )
    else
        vim.health.error(
            string.format(
                'Neovim v%d.%d.%d is too old (>= 0.9 required)',
                nvim_ver.major,
                nvim_ver.minor,
                nvim_ver.patch
            )
        )
    end

    if mkdnflow.loaded then
        vim.health.ok('setup() has been called and plugin is active')
    elseif mkdnflow.config then
        vim.health.warn('setup() has been called but plugin has not activated yet', {
            'Open a file with a configured filetype (e.g. .md) to activate',
        })
    else
        vim.health.warn('setup() has not been called', {
            "Add require('mkdnflow').setup() to your Neovim config",
        })
        return
    end

    -- == Configuration ==
    vim.health.start('mkdnflow: configuration')

    local raw = mkdnflow.raw_user_config
    if not raw or not next(raw) then
        vim.health.ok('Using default configuration (no user overrides)')
    else
        local compat = require('mkdnflow.compat')
        local found_deprecated = false

        -- Check top-level / nested deprecated keys
        for _, dep in ipairs(compat.deprecations) do
            if getPath(raw, dep.path) ~= nil then
                vim.health.warn(
                    string.format(
                        '`%s` is deprecated. Use `%s` instead.',
                        pathStr(dep.path),
                        pathStr(dep.new_path)
                    )
                )
                found_deprecated = true
            end
        end

        -- Check extension-based filetype keys
        if raw.filetypes then
            for key, _ in pairs(raw.filetypes) do
                if compat.extension_to_filetype[key] then
                    vim.health.warn(
                        string.format(
                            'Filetype key `%s` is an extension. Use the filetype name `%s` instead.',
                            key,
                            compat.extension_to_filetype[key]
                        )
                    )
                    found_deprecated = true
                end
            end
        end

        -- Check status-level deprecated keys
        if raw.to_do and raw.to_do.statuses and type(raw.to_do.statuses) == 'table' then
            if isArray(raw.to_do.statuses) then
                -- Array form is itself deprecated
                vim.health.warn(
                    '`to_do.statuses` is in deprecated array form. '
                        .. 'Use a dict keyed by status name with a `status_order` sibling.'
                )
                found_deprecated = true
                -- Also check per-element deprecated keys
                for i, status in ipairs(raw.to_do.statuses) do
                    for _, dep in ipairs(compat.status_deprecations) do
                        if status[dep.key] ~= nil then
                            vim.health.warn(
                                string.format(
                                    '`to_do.statuses[%d].%s` is deprecated. Use `%s` instead.',
                                    i,
                                    dep.key,
                                    dep.new_key
                                )
                            )
                            found_deprecated = true
                        end
                    end
                end
            else
                -- Dict form: check for deprecated keys within each status
                for name, status in pairs(raw.to_do.statuses) do
                    if type(status) == 'table' then
                        for _, dep in ipairs(compat.status_deprecations) do
                            if status[dep.key] ~= nil then
                                vim.health.warn(
                                    string.format(
                                        '`to_do.statuses.%s.%s` is deprecated. Use `%s` instead.',
                                        name,
                                        dep.key,
                                        dep.new_key
                                    )
                                )
                                found_deprecated = true
                            end
                        end
                        if status.skip_on_toggle ~= nil then
                            vim.health.warn(
                                string.format(
                                    '`to_do.statuses.%s.skip_on_toggle` is ignored in dict form. '
                                        .. 'To exclude a status from rotation, omit it from `status_order`.',
                                    name
                                )
                            )
                            found_deprecated = true
                        end
                    end
                end
            end
        end

        -- Check mapping string values
        if raw.mappings then
            for cmd, val in pairs(raw.mappings) do
                if type(val) == 'string' then
                    vim.health.warn(
                        string.format(
                            "`mappings.%s` is a string. Use a table `{ 'n', '%s' }` instead.",
                            cmd,
                            val
                        )
                    )
                    found_deprecated = true
                end
            end
        end

        if not found_deprecated then
            vim.health.ok('No deprecated config keys found')
        end

        -- Check for redundant defaults
        local defaults = mkdnflow.default_config
        local user_config = mkdnflow.user_config
        if defaults and user_config then
            local redundant = findRedundantDefaults(user_config, defaults)
            if #redundant > 0 then
                local items = {}
                for _, path in ipairs(redundant) do
                    table.insert(items, '  - ' .. path)
                end
                vim.health.info(
                    string.format(
                        '%d config value(s) match their defaults and could be removed:\n%s\n'
                            .. 'Run `:MkdnCleanConfig` to see a minimal version of your config.',
                        #redundant,
                        table.concat(items, '\n')
                    )
                )
            else
                vim.health.ok('No redundant default values found')
            end
        end
    end

    -- == Validation ==
    vim.health.start('mkdnflow: config validation')

    local diagnostics = mkdnflow.validation_diagnostics
    if not diagnostics and mkdnflow.user_config and next(mkdnflow.user_config) then
        -- setup() may not have stored diagnostics (e.g. older code path); run now
        local validate = require('mkdnflow.validate')
        diagnostics = validate.validate(mkdnflow.user_config, mkdnflow.default_config)
        validate.checkConflicts(mkdnflow.raw_user_config, diagnostics)
    end

    if not diagnostics or #diagnostics == 0 then
        vim.health.ok('No config validation issues found')
    else
        for _, diag in ipairs(diagnostics) do
            vim.health.warn(string.format('`%s`: %s', diag.path, diag.message))
        end
    end

    -- == Modules ==
    vim.health.start('mkdnflow: modules')

    local modules = mkdnflow.config.modules
    if modules then
        local enabled = {}
        local disabled = {}
        for name, val in pairs(modules) do
            if val then
                table.insert(enabled, name)
            else
                table.insert(disabled, name)
            end
        end
        table.sort(enabled)
        table.sort(disabled)
        if #enabled > 0 then
            vim.health.ok(#enabled .. ' modules enabled: ' .. table.concat(enabled, ', '))
        end
        if #disabled > 0 then
            vim.health.info(#disabled .. ' modules disabled: ' .. table.concat(disabled, ', '))
        end
    end

    -- == Optional dependencies ==
    vim.health.start('mkdnflow: optional dependencies')

    if modules and modules.completion then
        local cmp_ok, _ = pcall(require, 'cmp')
        local blink_ok, _ = pcall(require, 'blink.cmp')
        if cmp_ok or blink_ok then
            local engines = {}
            if cmp_ok then
                table.insert(engines, 'nvim-cmp')
            end
            if blink_ok then
                table.insert(engines, 'blink.cmp')
            end
            vim.health.ok('Completion engine available: ' .. table.concat(engines, ', '))
        else
            vim.health.warn('Completion module is enabled but no engine found', {
                'Install nvim-cmp or blink.cmp, or disable the completion module',
            })
        end
    else
        vim.health.ok('Completion module disabled')
    end
end

-- ---------------------------------------------------------------------------
-- Clean config
-- ---------------------------------------------------------------------------

--- Generate a minimal, up-to-date config and display it in a floating window.
function M.cleanConfig()
    local mkdnflow = require('mkdnflow')

    if not mkdnflow.config then
        vim.notify(
            "Mkdnflow: setup() has not been called. Can't generate clean config.",
            vim.log.levels.WARN
        )
        return
    end

    local defaults = mkdnflow.default_config
    local user_config = mkdnflow.user_config

    -- If no user config was provided, nothing to clean
    if not user_config or not next(user_config) then
        vim.notify(
            'Mkdnflow: No user configuration overrides found. You are using all defaults.',
            vim.log.levels.INFO
        )
        return
    end

    -- Work on a deep copy so we don't mutate stored state
    local clean = vim.deepcopy(user_config)

    -- Remove values that match defaults
    if defaults then
        removeRedundantDefaults(clean, defaults)
    end

    -- Build the output
    local lines = {
        '-- Mkdnflow: Optimized configuration',
        '-- Generated by :MkdnCleanConfig',
        '-- Only non-default values are shown. Copy this into your setup() call.',
        '--',
        '-- Note: Function values cannot be serialized. Look for "custom function"',
        '-- comments below and copy the corresponding functions from your config.',
        '',
    }

    if not next(clean) then
        table.insert(lines, '-- Your config is already minimal! All values match defaults.')
        table.insert(lines, "require('mkdnflow').setup({})")
    else
        local serialized = serializeLua(clean, 0)
        table.insert(lines, "require('mkdnflow').setup(" .. serialized .. ')')
    end

    -- Flatten: split any multi-line strings into individual lines for nvim_buf_set_lines
    local flat_lines = {}
    for _, line in ipairs(lines) do
        for sub in (line .. '\n'):gmatch('(.-)\n') do
            table.insert(flat_lines, sub)
        end
    end

    -- Size the floating window to fit content, capped to 80% of the editor
    local max_width = math.floor(vim.o.columns * 0.8)
    local max_height = math.floor(vim.o.lines * 0.8)
    local content_width = 0
    for _, line in ipairs(flat_lines) do
        content_width = math.max(content_width, #line)
    end
    content_width = math.min(content_width + 2, max_width)
    local content_height = math.min(#flat_lines, max_height)

    require('mkdnflow.panels').open({
        name = 'clean_config',
        lines = flat_lines,
        position = 'float',
        filetype = 'lua',
        modifiable = false,
        close_maps = { 'q', '<Esc>' },
        title = ' MkdnCleanConfig ',
        float = {
            border = 'rounded',
            width = content_width,
            height = content_height,
        },
    })
end

return M
