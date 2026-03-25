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
--
-- This module: Shared cross-file notebook primitives for scanning files,
-- headings, and links. Provides both synchronous and asynchronous variants.
--
-- Dependencies:
--   - links (always loaded as a core module in mkdnflow.lua:541)
--   - utils.getHeadingLevel (pure string match, always available)
--
-- Known limitations:
--   - ref_style_link and shortcut_ref_link source resolution calls get_ref() which
--     searches the current buffer for reference definitions. For files read from disk
--     (not the current buffer), these types will produce nil sources. Callers scanning
--     off-disk files should use opts.types to exclude these, or accept nil sources.
--   - scan_line processes one line at a time, so multi-line links (which Link:read()
--     handles via search_range context) will not be detected. In practice, the vast
--     majority of links in markdown files are single-line.

-- TODO: Use vim.uv directly when v0.9.5 support is dropped
local uv = vim.uv or vim.loop

local M = {}

local function cfg()
    return require('mkdnflow').config
end

-- =============================================================================
-- Private helpers
-- =============================================================================

--- Iterate over content lines, skipping YAML frontmatter and fenced code blocks.
---@param lines string[] Array of line strings
---@param opts? {skip_frontmatter?: boolean, skip_code_blocks?: boolean}
---@param callback fun(line: string, line_index: integer)
---@private
local function iterate_content_lines(lines, opts, callback)
    opts = opts or {}
    local skip_frontmatter = opts.skip_frontmatter ~= false -- default true
    local skip_code_blocks = opts.skip_code_blocks ~= false -- default true

    local start_idx = 1
    local in_fence = false

    -- Skip YAML frontmatter (--- delimited block starting at line 1)
    if skip_frontmatter and lines[1] and lines[1]:match('^%-%-%-$') then
        for i = 2, #lines do
            if lines[i]:match('^%-%-%-$') then
                start_idx = i + 1
                break
            end
        end
    end

    for i = start_idx, #lines do
        local line = lines[i]
        if skip_code_blocks and (line:match('^```') or line:match('^~~~')) then
            in_fence = not in_fence
        elseif not in_fence then
            callback(line, i)
        end
    end
end

-- =============================================================================
-- Synchronous file operations
-- =============================================================================

--- Read a file synchronously and return its lines.
---@param filepath string Absolute file path
---@return string[]|nil lines Array of lines, or nil if file is not readable
M.readFileSync = function(filepath)
    if vim.fn.filereadable(filepath) ~= 1 then
        return nil
    end
    return vim.fn.readfile(filepath)
end

--- Recursively scan a directory for notebook files, synchronously.
---@param dir string Base directory to scan
---@param opts? {extensions?: table<string, boolean>, max_depth?: integer, predicate?: fun(name: string): boolean}
---@return string[] filepaths Array of absolute file paths
M.scanFilesSync = function(dir, opts)
    opts = opts or {}
    local extensions = opts.extensions or cfg().notebook_extensions or { md = true }
    local max_depth = opts.max_depth or 20
    local predicate = opts.predicate
    local results = {}
    local seen = {}

    local function scan(path, depth)
        if depth > max_depth then
            return
        end
        if vim.fn.isdirectory(path) ~= 1 then
            return
        end
        local entries = vim.fn.readdir(path)
        for _, name in ipairs(entries) do
            local full_path = path .. '/' .. name
            if vim.fn.isdirectory(full_path) == 1 then
                scan(full_path, depth + 1)
            else
                local ext = name:match('%.([^%.]+)$')
                local ext_match = ext and extensions[ext:lower()] or false
                if ext_match then
                    if not predicate or predicate(name) then
                        local real = vim.fn.resolve(full_path)
                        if not seen[real] then
                            seen[real] = true
                            table.insert(results, full_path)
                        end
                    end
                end
            end
        end
    end

    scan(dir, 0)
    return results
end

-- =============================================================================
-- Heading and link scanning
-- =============================================================================

--- Scan lines for markdown headings.
---@param lines string[] Array of line strings
---@param opts? {with_anchor?: boolean, skip_frontmatter?: boolean, skip_code_blocks?: boolean}
---@return table[] headings Array of {row, level, text, anchor}
M.scanHeadings = function(lines, opts)
    opts = opts or {}
    local with_anchor = opts.with_anchor ~= false -- default true
    local utils = require('mkdnflow.utils')
    local links_mod = with_anchor and require('mkdnflow.links') or nil
    local headings = {}

    iterate_content_lines(lines, opts, function(line, line_index)
        local level = utils.getHeadingLevel(line)
        if level < 99 then
            local text = line:gsub('^#+ *', '')
            local anchor = nil
            if with_anchor and links_mod then
                anchor = links_mod.formatLink(line, nil, 2)
            end
            table.insert(headings, {
                row = line_index,
                level = level,
                text = text,
                anchor = anchor,
            })
        end
    end)

    return headings
end

--- Scan lines for markdown links.
---@param lines string[] Array of line strings
---@param opts? {types?: table<string, boolean>, skip_frontmatter?: boolean, skip_code_blocks?: boolean}
---@return table[] links Array of {row, col, type, match, source, anchor}
M.scanLinks = function(lines, opts)
    opts = opts or {}
    local types_filter = opts.types
    local Link = require('mkdnflow.links.core').Link
    local found = {}

    iterate_content_lines(lines, opts, function(line, line_index)
        local line_links = Link.scan_line(line, line_index)
        for _, link in ipairs(line_links) do
            if not types_filter or types_filter[link.type] then
                local source_text, anchor
                local source_part = link:get_source()
                if source_part and source_part.text then
                    source_text = source_part.text
                    anchor = source_part.anchor
                end
                table.insert(found, {
                    row = link.start_row,
                    col = link.start_col,
                    type = link.type,
                    match = link.match,
                    source = source_text,
                    anchor = anchor,
                })
            end
        end
    end)

    return found
end

-- =============================================================================
-- Asynchronous file operations
-- =============================================================================

--- Read a file asynchronously.
--- Does NOT wrap callback in vim.schedule — callers are responsible for
--- scheduling back to the main thread if they need to call Vim API.
---@param filepath string Absolute file path
---@param on_done fun(lines: string[]|nil) Called with array of lines or nil on error
M.readFile = function(filepath, on_done)
    uv.fs_open(filepath, 'r', 438, function(err_open, fd)
        if err_open or not fd then
            on_done(nil)
            return
        end
        uv.fs_fstat(fd, function(err_stat, stat)
            if err_stat or not stat then
                uv.fs_close(fd, function()
                    on_done(nil)
                end)
                return
            end
            uv.fs_read(fd, stat.size, 0, function(err_read, data)
                uv.fs_close(fd, function()
                    if err_read or not data then
                        on_done(nil)
                        return
                    end
                    -- Normalize line endings and split
                    data = data:gsub('\r\n', '\n'):gsub('\r', '\n')
                    local lines = vim.split(data, '\n')
                    -- Trim trailing empty element to match readFileSync/vim.fn.readfile behavior
                    if lines[#lines] == '' then
                        lines[#lines] = nil
                    end
                    on_done(lines)
                end)
            end)
        end)
    end)
end

--- Recursively scan a directory for notebook files, asynchronously.
--- Does NOT wrap callback in vim.schedule — callers are responsible for
--- scheduling back to the main thread if they need to call Vim API.
---@param dir string Base directory to scan
---@param opts table|fun(filepaths: string[]) Options table or on_done callback (2-arg form)
---@param on_done? fun(filepaths: string[]) Called with all matching absolute paths
M.scanFiles = function(dir, opts, on_done)
    -- Support 2-arg form: scanFiles(dir, on_done)
    if type(opts) == 'function' then
        on_done = opts
        opts = {}
    end
    opts = opts or {}
    local extensions = opts.extensions or cfg().notebook_extensions or { md = true }
    local max_depth = opts.max_depth or 20
    local results = {}
    local seen = {}
    local pending = 0

    local function process_entry(full_path, resolved_type, depth)
        if resolved_type == 'directory' then
            scan_dir(full_path, depth + 1)
        elseif resolved_type == 'file' then
            local name = full_path:match('[^/]+$')
            if name then
                local ext = name:match('%.([^%.]+)$')
                if ext and extensions[ext:lower()] then
                    local real = uv.fs_realpath(full_path)
                    if real and not seen[real] then
                        seen[real] = true
                        table.insert(results, full_path)
                    end
                end
            end
        end
    end

    function scan_dir(path, depth)
        if depth > max_depth then
            return
        end
        pending = pending + 1
        uv.fs_scandir(path, function(err, handle)
            if err or not handle then
                pending = pending - 1
                if pending == 0 then
                    on_done(results)
                end
                return
            end

            local entries = {}
            while true do
                local name, entry_type = uv.fs_scandir_next(handle)
                if not name then
                    break
                end
                table.insert(entries, { name = name, type = entry_type })
            end

            for _, entry in ipairs(entries) do
                local full_path = path .. '/' .. entry.name
                if entry.type == 'link' or entry.type == 'unknown' then
                    pending = pending + 1
                    uv.fs_stat(full_path, function(stat_err, stat)
                        if not stat_err and stat then
                            process_entry(full_path, stat.type, depth)
                        end
                        pending = pending - 1
                        if pending == 0 then
                            on_done(results)
                        end
                    end)
                else
                    process_entry(full_path, entry.type, depth)
                end
            end

            pending = pending - 1
            if pending == 0 then
                on_done(results)
            end
        end)
    end

    scan_dir(dir, 0)
end

return M
