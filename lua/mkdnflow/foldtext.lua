-- mkdnflow.nvim (Tools for personal markdown notebook navigation and management)
-- Copyright (C) 2024 Jake W. Vincent <https://github.com/jakewvincent>
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

local config = require('mkdnflow').config
local ffi = require('ffi')

local M = {}

ffi.cdef([[
    typedef struct window_S win_T;
    int win_col_off(win_T *wp);
    extern win_T *curwin;
]])

-- Function to get the level of a heading
local heading_level = function(text)
    local count = 0
    while text:match('^%s*#') do
        count = count + 1
        text = text:gsub('^%s*#', '')
    end
    return count
end

-- Function to remove unnecessary elements from the leading line of a fold
M.default_title_transformer = function(text)
    -- Get the level of the heading before we remove it
    local level = heading_level(text)
    local level_fill = 6 - level
    text = text:gsub('%b{}', '') -- Attributes
    text = text:gsub('^%s*', '') -- Leading whitespace
    text = text:gsub('%s*$', '') -- Trailing whitespace
    text = text:gsub('^%s*#+%s*', '') -- Hashes and any surrounding whitespace

    -- Add text representing the heading level
    text = string.rep('●', level) .. string.rep('○', level_fill) .. ' ' .. text

    return text
end

-- Symbols for the objects counted in a fold
M.object_icons = {
    nerdfont = {
        tbl = ' ',
        ul = ' ',
        ol = ' ',
        todo = ' ',
        img = ' ',
        fncblk = ' ',
        sec = '󰚟',
        par = '󰛘',
        link = ' ',
    },
    plain = {
        tbl = '⊞ ',
        ul = '•',
        ol = '① ',
        todo = '☑',
        img = '⧉ ',
        fncblk = '‵',
        sec = '§',
        par = '¶',
        link = '⇔ ',
    },
    emoji = {
        tbl = '📈 ',
        ul = '*️⃣  ',
        ol = '1️⃣  ',
        todo = '✅ ',
        img = '🖼️ ',
        fncblk = '🧮 ',
        sec = '🏷️ ',
        par = '📃',
        link = '🔗 ',
    },
}

local percentage = function(num, div)
    local quo = (num / div) * 100
    local round = string.format('%.1f', tostring(quo))
    return round .. '%'
end

local count_words = function(lines, singular, plural)
    local word_count = 0
    -- Iterate through each string in the table
    for _, str in ipairs(lines) do
        -- Make some changes to ensure a proper word count
        local _str = str:gsub('^%s*%d+%.%s*', '') -- Remove the number for ordered lists
        _str = _str:gsub('%s*[-*+%d]%.?%s*%[.%]%s+', '') -- Remove to-do checkboxes, either in an ordered or unordered list
        _str = _str:gsub('(%b[])%b()', '%1') -- Remove the source part of a markdown link
        _str = _str:gsub('%[%[([^|]-)|([^%]]-)%]%]', '[[%2]]') -- Remove the source part of a wiki link
        _str = _str:gsub("(%w+)['](%w+)", '%1%2') -- Remove word-internal apostrophes, dashes
        _str = _str:gsub('([%w._-]+)@[%w]+%.[%w]+', '%1') -- Keep only the name (not the domain) of an email address
        -- TODO: URLs, paths (ensure that each of these is only counted as a single word)
        -- Split the string into words using the space delimiter
        for _ in _str:gmatch('%w+') do
            word_count = word_count + 1
        end
    end
    return string.format('%s %s', tostring(word_count), word_count == 1 and singular or plural)
end

local icon_set = config.foldtext.object_count_icon_set

M.default_count_opts = {
    tbl = {
        icon = M.object_icons[icon_set].tbl,
        count_method = {
            prep = function(text)
                return text:gsub('%[%[.-|.-%]%]', '')
            end,
            pattern = { '%s*[^\\]|.*[^\\]|%s*', '[^\\]|' },
            tally = 'blocks',
        },
    },
    ul = {
        icon = M.object_icons[icon_set].ul,
        count_method = {
            pattern = { '^%s*[-+*]%s' },
            tally = 'blocks',
        },
    },
    ol = {
        icon = M.object_icons[icon_set].ol,
        count_method = {
            pattern = { '^%s-%d+%.' },
            tally = 'blocks',
        },
    },
    todo = {
        icon = M.object_icons[icon_set].todo,
        count_method = {
            pattern = { '[-+*%d]%.?%s+%[.%]' },
            tally = 'blocks',
        },
    },
    img = {
        icon = M.object_icons[icon_set].img,
        count_method = {
            pattern = { '!%b[]%b()' },
            tally = 'global_matches',
        },
    },
    fncblk = {
        icon = M.object_icons[icon_set].fncblk,
        count_method = {
            prep = function(text)
                return text:gsub('^```', '\n```')
            end,
            pattern = { '\n```.-\n```' },
            tally = 'global_matches',
        },
    },
    sec = {
        icon = M.object_icons[icon_set].sec,
        count_method = {
            pattern = { '^#+%s' },
            tally = 'line_matches',
        },
    },
    par = {
        icon = M.object_icons[icon_set].par,
        count_method = {
            pattern = { '\n%s*\n%a' },
            tally = 'global_matches',
        },
    },
    link = {
        icon = M.object_icons[icon_set].link,
        count_method = {
            pattern = { '%b[]%b()', '%b[]%b[]', '%[%[.-%]%]' },
            tally = 'global_matches',
        },
    },
}

local count_blocks = function(line_objs)
    local counts = {}
    -- Function to increment the count for an object type
    local increment = function(obj_type)
        counts[obj_type] = counts[obj_type] == nil and 1 or (counts[obj_type] + 1)
    end
    -- Iterate through the main table
    for i = 1, #line_objs do
        local line_tbl = line_objs[i]
        -- Iterate through object types (strings) in the current subtable
        for _, obj_type in ipairs(line_tbl) do
            -- If there is no preceding subtable or the preceding subtable is empty, increment the
            -- count (we're starting a new block for this type)
            if i == 1 or not line_objs[i - 1] or not line_objs[i - 1][1] then
                increment(obj_type)
            else
                local found = false
                -- Look through the last line objects to see if the current object is a continuation
                -- of a block or the start of a new block
                for _, prev_obj_type in ipairs(line_objs[i - 1]) do
                    if obj_type == prev_obj_type then
                        found = true
                        break
                    end
                end
                -- If we didn't find the object type in the previous table, we've reached the end of
                -- the block and should count the block
                if not found then
                    increment(obj_type)
                end
            end
        end
    end
    return counts
end

-- Function to inject defaults for any object type for which the user didn't specify necessary
-- information.
local inject_object_count_defaults = function(user_object_count_opts)
    return vim.tbl_deep_extend('force', M.default_count_opts, user_object_count_opts)
end

-- Initialize as an empty table; will be loaded once count_objects is run for the first time
local object_count_opts = {}

local count_objects = function(lines)
    -- Load up the object count opts into the table above the first time this function is called
    if vim.tbl_isempty(object_count_opts) then
        object_count_opts = inject_object_count_defaults(config.foldtext.object_count_opts())
    end
    -- Organize the object counts by tally method
    local tally_methods = {
        blocks = {},
        line_matches = {},
        global_matches = {},
    }
    local icons = {}
    for k, v in pairs(object_count_opts) do
        if v then
            -- Get the tally method
            tally_methods[v.count_method.tally][k] = v.count_method
            -- Get just the icon
            icons[k] = v.icon
        end
    end
    -- Iterate over lines for blocks and line objects
    local block_objects, object_counts = {}, {}
    for _, line in ipairs(lines) do
        local line_tbl = {}
        -- Block method
        for k, v in pairs(tally_methods.blocks) do
            local match, _line = false, v.prep ~= nil and v.prep(line) or line
            -- If a string was passed in for v.pattern, place it in a table to prevent errors
            v.pattern = type(v.pattern) == 'string' and {v.pattern} or v.pattern
            for _, pattern in ipairs(v.pattern) do
                if _line:match(pattern) then
                    match = true
                    break -- Stop if we find a match
                end
            end
            if match then
                -- Add the name of the object to the table of matches for the line
                table.insert(line_tbl, k)
            end
        end
        -- Add the table to the block objects table
        table.insert(block_objects, line_tbl)
        -- Line method (direct counting)
        for k, v in pairs(tally_methods.line_matches) do
            local match, _line = false, v.prep ~= nil and v.prep(line) or line
            for _, pattern in ipairs(v.pattern) do
                if _line:match(pattern) then
                    match = true
                    break
                end
            end
            if match then
                -- Increment the count, or if the entry doesn't exist yet, add it
                object_counts[k] = object_counts[k] == nil and 1 or (object_counts[k] + 1)
            end
        end
    end
    -- Add the block-count object types to the table
    object_counts = vim.tbl_extend('error', object_counts, count_blocks(block_objects))
    -- Global matches
    local glom = table.concat(lines, '\n')
    for k, v in pairs(tally_methods.global_matches) do
        local matches, _glom = 0, v.prep ~= nil and v.prep(glom) or glom
        for _, pattern in ipairs(v.pattern) do
            local _, reps = _glom:gsub(pattern, '')
            matches = matches + reps
        end
        if matches > 0 then
            -- Add the count to the table
            object_counts[k] = matches
        end
    end
    -- Finally, format using the icons
    local formatted = {}
    for k, v in pairs(object_counts) do
        if v > 0 then
            table.insert(formatted, string.format('%s%s', icons[k], tostring(v)))
        end
    end
    return formatted
end

-- Function to generate the text that shows up when a section is folded
M.fold_text = function()
    local title_transformer = config.foldtext.title_transformer()
    local fold_start, fold_end = vim.v.foldstart, vim.v.foldend
    local line_count = fold_end - fold_start
    local total_lines = vim.api.nvim_buf_line_count(0)
    local start_line, lines =
        vim.api.nvim_buf_get_lines(0, fold_start - 1, fold_start, false),
        vim.api.nvim_buf_get_lines(0, fold_start, fold_end, false)
    local object_counts = count_objects(lines)
    -- Get the available width to fill
    local gutter_width = ffi.C.win_col_off(ffi.C.curwin)
    local visible_win_width = vim.api.nvim_win_get_width(0) - gutter_width
    -- Gather characters to use (from config)
    local isep, ssep, le, re, li, ri, mi =
        config.foldtext.fill_chars.item_separator,
        config.foldtext.fill_chars.section_separator,
        config.foldtext.fill_chars.left_edge,
        config.foldtext.fill_chars.right_edge,
        config.foldtext.fill_chars.left_inside,
        config.foldtext.fill_chars.right_inside,
        config.foldtext.fill_chars.middle

    -- Add in counts of the object types found
    local content_info = {
        left = object_counts,
        right = {},
    }
    -- Add line count
    if config.foldtext.line_count == true then
        table.insert(
            content_info.right,
            tostring(line_count) .. (line_count == 1 and ' line' or ' lines')
        )
    end
    -- Add line percentage
    if config.foldtext.line_percentage == true then
        table.insert(content_info.right, percentage(line_count, total_lines))
    end
    -- Add word count
    if config.foldtext.word_count == true then
        table.insert(content_info.right, count_words(lines, 'word', 'words'))
    end
    -- Stringify content info
    local content_strs = {}
    for _, key in ipairs({ 'left', 'right' }) do
        if not vim.tbl_isempty(content_info[key]) then
            table.insert(content_strs, table.concat(content_info[key], isep))
        end
    end
    local content_str = table.concat(content_strs, ssep)
    -- Put together some pieces
    local left = le .. ri .. title_transformer(start_line[1]) .. li
    local right = (content_str ~= '' and ri or mi)
        .. content_str
        .. (content_str ~= '' and li .. re or mi .. re)
    -- Figure out how many fill chars are needed
    local fill_count = visible_win_width - vim.api.nvim_strwidth(left .. right)
    -- Return the final string with fill characters between the left and right parts
    return left .. string.rep(mi, fill_count) .. right
end

vim.opt.foldtext = "v:lua.require('mkdnflow').foldtext.fold_text()"

return M
