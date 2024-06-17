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

local object_type = function(text)
    local is_todo = function(_text)
        if _text and _text:match('%s*[-*+%d]%.?%s*%[.%]') then
            return true
        end
    end
    local object = 'par'
    if text then
        if
            text:gsub('%[%[.-|.-%]%]', ''):match('%s*[^\\]|.*[^\\]|%s*')
            or text:gsub('%[%[.-|.-%]%]', ''):match('[^\\]|')
        then
            object = 'tbl'
        elseif text:match('^%s-%d+%.') then
            if is_todo(text) then
                object = 'todo'
            else
                object = 'ol'
            end
        elseif text:match('%s*[-+*]%s') then
            if is_todo(text) then
                object = 'todo'
            else
                object = 'ul'
            end
        elseif text:match('^```') then
            object = 'fncblk'
        elseif text:match('^#+%s') then
            object = 'sec'
        elseif text:match('!%b[]%b()') then
            object = 'img'
        elseif text:match('^%s*$') then
            object = 'empty'
        end
    end
    return object
end

local count_auto_links = function(text)
    local has_url = require('mkdnflow').links.hasUrl
    local count = 0
    for match in string.gmatch(text, '<.->') do
        if has_url(match:sub(2, -1)) then
            count = count + 1
        end
    end
    return count
end

local count_objects_in_lines = function(lines)
    local objects = {}
    -- Count the number of each type of object
    for _, line in ipairs(lines) do
        local cur_object = object_type(line)
        if line and cur_object then
            table.insert(objects, cur_object)
        end
    end
    -- Add an empty item since the change from one line to the next is what we're paying attention
    -- to for certain item types
    table.insert(objects, '')
    local object_counts = {}
    -- Count occurrences of each thing
    local last_object = { type = '', instances = 0 }
    for _, cur_object in ipairs(objects) do
        if cur_object == 'fncblk' then
            if object_counts[cur_object] then
                object_counts[cur_object] = object_counts[cur_object] + 0.5
            else
                object_counts[cur_object] = 0.5
            end
        elseif
            (
                cur_object == 'tbl'
                or cur_object == 'ol'
                or cur_object == 'ul'
                or cur_object == 'todo'
            ) and cur_object ~= last_object.type
        then
            -- Figure out if we were really in a table
            if last_object.type == 'tbl' and last_object.instances > 1 then
                if object_counts[cur_object] then
                    object_counts[cur_object] = object_counts[cur_object] + 1
                else
                    object_counts[cur_object] = 1
                end
            else
                if object_counts[cur_object] then
                    object_counts[cur_object] = object_counts[cur_object] + 1
                else
                    object_counts[cur_object] = 1
                end
            end
        elseif cur_object == 'img' or cur_object == 'sec' then
            if object_counts[cur_object] then
                object_counts[cur_object] = object_counts[cur_object] + 1
            else
                object_counts[cur_object] = 1
            end
        end
        -- Keep track of the object type we saw in this iteration. If it's the same as what was
        -- there before, increment the counter for the # of instances.
        if last_object.type == cur_object then
            last_object.instances = last_object.instances + 1
        else
            last_object.type = cur_object
            last_object.instances = 0
        end
    end
    -- Round the number of fenced blocks down (we counted 0.5 for each ```, and we don't want to
    -- count an improperly closed fenced block)
    if object_counts.fncblk then
        object_counts.fncblk = math.floor(object_counts.fncblk)
    end
    -- Count certain objects based on global patterns
    local cat = table.concat(lines)
    -- Count links
    local _, md_link_count = cat:gsub('%b[]%b()', '')
    local _, ref_link_count = cat:gsub('%b[]%b[]', '')
    local _, wiki_link_count = cat:gsub('%[%[.-%]%]', '')
    local auto_link_count = count_auto_links(cat)
    local link_count = md_link_count + ref_link_count + wiki_link_count + auto_link_count
    if link_count > 0 then
        object_counts['link'] = link_count
    end
    return object_counts
end

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
local title_transformer = function(text)
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
local object_icons = {
    nerdfont = {
        tbl = ' ',
        ul = ' ',
        ol = ' ',
        todo = ' ',
        img = ' ',
        fncblk = ' ',
        sec = '§',
        link = ' ',
    },
    plain = {
        tbl = '⊞ ',
        ul = '• ',
        ol = '① ',
        todo = '☑ ',
        img = '⧉ ',
        fncblk = '‵',
        sec = '§ ',
        link = '⇔ ',
    },
    emoji = {
        tbl = '📈 ',
        ul = '*️⃣  ',
        ol = '1️⃣  ',
        todo = '✅ ',
        img = '🖼️ ',
        fncblk = '🖥️ ',
        sec = '🏷️ ',
        link = '🔗 ',
    },
}

-- Function to generate the text that shows up when a section is folded
M.fold_text = function()
    local _title_transformer = config.foldtext.title_transformer or title_transformer
    local user_icons = config.foldtext.object_count_icons
    local _object_icons = type(user_icons) == 'table'
            and vim.tbl_extend('force', object_icons.emoji, user_icons)
        or (type(user_icons) == 'string' and object_icons[user_icons] or object_icons.emoji)
    local fold_start, fold_end = vim.v.foldstart, vim.v.foldend
    local line_count = fold_end - fold_start
    local start_line, lines =
        vim.api.nvim_buf_get_lines(0, fold_start - 1, fold_start, false),
        vim.api.nvim_buf_get_lines(0, fold_start, fold_end, false)
    local object_counts = count_objects_in_lines(lines)
    -- Get the available width to fill
    local gutter_width = ffi.C.win_col_off(ffi.C.curwin)
    local visible_win_width = vim.api.nvim_win_get_width(0) - gutter_width
    -- Gather characters to use (from config)
    local sep, le, re, li, ri, mi =
        config.foldtext.fill_chars.separator,
        config.foldtext.fill_chars.left_edge,
        config.foldtext.fill_chars.right_edge,
        config.foldtext.fill_chars.left_inside,
        config.foldtext.fill_chars.right_inside,
        config.foldtext.fill_chars.middle

    local fold_text = le .. mi .. mi .. ri .. _title_transformer(start_line[1])

    -- Add in counts of the object types found
    local current, table_size = 1, #vim.tbl_keys(object_counts)
    local content_info = ''
    for obj, count in vim.spairs(object_counts) do
        if _object_icons[obj] and count ~= nil then
            content_info = content_info
                .. _object_icons[obj]
                .. tostring(count)
                .. (current < table_size and sep or '')
        end
        current = current + 1
    end
    -- Add line count to content
    content_info = content_info
        .. (content_info ~= '' and li .. mi .. ri or '')
        .. tostring(line_count)
        .. (line_count == 1 and ' line' or ' lines')
    -- Figure out how many fill chars are needed
    local fill_count = visible_win_width - vim.api.nvim_strwidth(fold_text .. content_info)
    -- Create the final string
    fold_text = fold_text
        .. li
        .. string.rep(mi, fill_count - 7)
        .. (content_info ~= '' and ri or mi)
        .. content_info
        .. (content_info ~= '' and li .. mi .. mi .. re or mi .. mi .. mi .. re)
    return fold_text
end

vim.opt.foldtext = "v:lua.require('mkdnflow').foldtext.fold_text()"

return M
