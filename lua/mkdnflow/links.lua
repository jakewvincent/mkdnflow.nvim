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

-- Modules and variables
local config = require('mkdnflow').config
local new_file_prefix = config.prefix ~= nil and config.prefix.string
local evaluate_prefix = config.prefix ~= nil and config.prefix.evaluate
local link_style = config.links.style
local implicit_extension = config.links.implicit_extension
local transform_path = config.links.transform_explicit
local utils = require('mkdnflow').utils

-- Table for global functions
local M = {}

M.getLinkUnderCursor = function(col)
    col = col or vim.api.nvim_win_get_cursor(0)[2]
    local patterns = {
        md_link = '%b[]%b()',
        wiki_link = '%[%b[]%]',
        ref_style_link = '%b[]%s?%b[]',
        citation = '[^%a%d]-(@[%a%d_%.%-\']*[%a%d]+)[%s%p%c]?'
    }
    local line = vim.api.nvim_get_current_line()
    -- Iterate through the patterns to see if there's a matching link under the cursor
    for type, pattern in pairs(patterns) do
        local continue, init, iteration, match = true, 1, 1, nil
        local counter = 1
        while continue and counter < 100 do
            counter = counter + 1
            if counter == 100 then print("Infinite loop :(") end
            local start, finish, capture = string.find(line, pattern, init)
            if start and type == 'citation' then
                capture = string.gsub(capture, "'s$", '') -- Remove Saxon genitive if it's on the end of the citekey
                start, finish = string.find(line, capture, start, true) -- Get match for citekey w/o surrounding context
            end
            if start then -- There's a match
                if iteration == 1 and col + 1 < start then -- If the first match is after the cursor, stop
                    continue = false
                elseif col + 1 >= start and col < finish then -- Cursor is between start and finish
                    continue = false
                    match = string.sub(line, start, finish)
                else -- Cursor is outside of start and finish; 
                    init = finish
                end
            else
                continue = false
            end
            iteration = iteration + 1
        end
        if match then -- Return the match and type of link if there was a match
            return {match, type}
        end
    end
end

--[[
getLinkPart() extracts part of a link
Returns a string (or two strings if there is an anchor within the source)
--]]
M.getLinkPart = function(link_table, part)
    table.unpack = table.unpack or unpack
    if link_table then
        local text, type = table.unpack(link_table)
        part = part or 'source'
        local patterns = {
            name = {
                md_link = '%[(.*)%]',
                wiki_link = '|(.-)%]',
                wiki_link_no_bar = '%[%[(.-)%]%]',
                wiki_link_anchor_no_bar = '%[%[(.-)#.-%]%]',
                ref_style_link = '^%[(.*)%]%s?%[',
                citation = '(@.*)'
            },
            source = {
                md_link = '%]%((.*)%)',
                wiki_link = '%[%[(.-)|.-%]%]',
                wiki_link_no_bar = '%[%[(.-)%]%]',
                ref_style_link = '%]%s?%[(.*)%]',
                citation = '(@.*)'
            },
            anchor = {
                md_link = '%(.*(#.*)%)',
                wiki_link = '%[%[.-(#.-)|',
                wiki_link_no_bar = '%[%[.-(#.-)%]%]'
            }
        }
        local get_from = { -- Table of functions by link type
            md_link = function(part_)
                local match = string.match(text, patterns[part_]['md_link'])
                if part_ == 'source' then
                    local start, finish, anchor = string.find(match, '(#.*)')
                    if start then
                        match = string.sub(match, 1, start - 1)
                        return match, anchor
                    else
                        return match
                    end
                else
                    return match
                end
            end,
            wiki_link = function(part_)
                local match = string.match(text, patterns[part_]['wiki_link'])
                if match then
                    if part_ == 'source' then
                        local start, finish, anchor = string.find(match, '(#.*)')
                        if start then
                            match = string.sub(match, 1, start - 1)
                            return match, anchor
                        else
                            return match
                        end
                    else
                        return match
                    end
                elseif part_ == 'name' and string.match(text, '#') then
                    return string.match(text, patterns[part_]['wiki_link_anchor_no_bar'])
                else
                    match = string.match(text, patterns[part_]['wiki_link_no_bar'])
                    if part_ == 'source' then
                        local start, finish, anchor = string.find(match, '(#.*)')
                        if start then
                            match = string.sub(match, 1, start - 1)
                            return match, anchor
                        else
                            return match
                        end
                    else
                        return match
                    end
                end
            end,
            ref_style_link = function(part_)
                return string.match(text, patterns[part_]['ref_style_link'])
            end,
            citation = function(part_)
                return string.match(text, patterns[part_]['citation'])
            end
        }
        return get_from[type](part)
    end
end

M.getBracketedSpanPart = function(part)
    -- Use 'attr' as part if no argument provided
    part = part or 'attr'
    -- Get current cursor position
    local position = vim.api.nvim_win_get_cursor(0)
    local row, col = position[1], position[2]
    -- Get the indices of the bracketed spans in the line
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false) -- Get the line text
    local bracketed_span_pattern = '%b[](%b{})'
    local indices, prev_last, continue = {}, 1, true
    -- TODO: Move the check overlap bit, which is repeated twice, to a function
    -- definition here, then call the function twice
    while continue do
        -- Get the indices of any match on the current line
        local first, last = string.find(line[1], bracketed_span_pattern, prev_last)
        -- Check if there's a match that begins after the last from the previous
        -- iteration of the loop
        if first and last then
            -- If there is, check if the match overlaps with the cursor position
            if first - 1 <= col and last - 1 >= col then
                -- If it does overlap, save the indices of the match
                indices = {first = first, last = last}
                -- End the loop
                continue = false
            else
                -- If it doesn't overlap, save the end index of the match so
                -- we can look for a match following it on the next loop.
                prev_last = last
            end
        else
            continue = nil
        end
    end

    -- Check if a bracketed span was found under the cursor
    if continue == false then
        -- If one was found, get correct part of the match
        -- and return it
        if part == 'name' then
            local name_pattern = '(%b[])%b{}'
            local span = string.sub(line[1], indices['first'], indices['last'])
            local name = string.sub(string.match(span, name_pattern), 2, -2)
            -- Return the name and the indices of the bracketed span
            return name, indices['first'], indices['last'], row
        elseif part == 'attr' then
            local attr_pattern = '%b[](%b{})'
            local attr = string.sub(
                string.match(
                    string.sub(line[1], indices['first'], indices['last']),
                    attr_pattern
                ), 2, -2
            )
            local attr_first, attr_last = line[1]:find('%]%{'..utils.luaEscape(attr), indices['first'])
            attr_first = attr_first + 2
            return attr, attr_first, attr_last, row
        end
    else
        return(nil)
    end
end

--[[
hasUrl() determines whether a string is a URL
Arguments: the string to lok for a url in; (optional) what should be returned--
either 'boolean' [default] or 'positions'; (optional) current cursor position
Returns: a boolean or nil if to_return is empty or 'boolean'; positions of url
if to_return is 'positions'.
--]]
M.hasUrl = function(string, to_return, col)
    to_return = to_return or 'boolean'
    col = col or nil
    -- This function based largely on the solution in https://stackoverflow.com/
    -- questions/23590304/finding-a-url-in-a-string-lua-pattern
    -- Table of top-level domains
    local tlds = {ac = true, ad = true, ae = true, aero = true, af = true,
        ag = true, ai = true, al = true, am = true, an = true, ao = true,
        aq = true, ar = true, arpa = true, as = true, asia = true, at = true,
        au = true, aw = true, ax = true, az = true, ba = true, bb = true,
        bd = true, be = true, bf = true, bg = true, bh = true, bi = true,
        biz = true, bj = true, bm = true, bn = true, bo = true, br = true,
        bs = true, bt = true, bv = true, bw = true, by = true, bz = true,
        ca = true, cat = true, cc = true, cd = true, cf = true, cg = true,
        ch = true, ci = true, ck = true, cl = true, cm = true, cn = true,
        co = true, com = true, coop = true, cr = true, cs = true, cu = true,
        cv = true, cx = true, cy = true, cz = true, dd = true, de = true,
        dj = true, dk = true, dm = true, ['do'] = true, dz = true, ec = true,
        edu = true, ee = true, eg = true, eh = true, er = true, es = true,
        et = true, eu = true, fi = true, firm = true, fj = true, fk = true,
        fm = true, fo = true, fr = true, fx = true, ga = true, gb = true,
        gd = true, ge = true, gf = true, gh = true, gi = true, gl = true,
        gm = true, gn = true, gov = true, gp = true, gq = true, gr = true,
        gs = true, gt = true, gu = true, gw = true, gy = true, hk = true,
        hm = true, hn = true, hr = true, ht = true, hu = true, id = true,
        ie = true, il = true, im = true, ['in'] = true, info = true, int = true,
        io = true, iq = true, ir = true, is = true, it = true, je = true,
        jm = true, jo = true, jobs = true, jp = true, ke = true, kg = true,
        kh = true, ki = true, km = true, kn = true, kp = true, kr = true,
        kw = true, ky = true, kz = true, la = true, lb = true, lc = true,
        li = true, lk = true, lr = true, ls = true, lt = true, lu = true,
        lv = true, ly = true, ma = true, mc = true, md = false, me = true,
        mg = true, mh = true, mil = true, mk = true, ml = true, mm = true,
        mn = true, mo = true, mobi = true, mp = true, mq = true, mr = true,
        ms = true, mt = true, mu = true, museum = true, mv = true, mw = true,
        mx = true, my = true, mz = true, na = true, name = true, nato = true,
        nc = true, ne = true, net = true, nf = true, ng = true, ni = true,
        nl = true, no = true, nom = true, np = true, nr = true, nt = true,
        nu = true, nz = true, om = true, org = true, pa = true, pe = true,
        pf = true, pg = true, ph = true, pk = true, pl = true, pm = true,
        pn = true, post = true, pr = true, pro = true, ps = true, pt = true,
        pw = true, py = true, qa = true, re = true, ro = true, ru = true,
        rw = true, sa = true, sb = true, sc = true, sd = true, se = true,
        sg = true, sh = true, si = true, sj = true, sk = true, sl = true,
        sm = true, sn = true, so = true, sr = true, ss = true, st = true,
        store = true, su = true, sv = true, sy = true, sz = true, tc = true,
        td = true, tel = true, tf = true, tg = true, th = true, tj = true,
        tk = true, tl = true, tm = true, tn = true, to = true, tp = true,
        tr = true, travel = true, tt = true, tv = true, tw = true, tz = true,
        ua = true, ug = true, uk = true, um = true, us = true, uy = true,
        va = true, vc = true, ve = true, vg = true, vi = true, vn = true,
        vu = true, web = true, wf = true, ws = true, xxx = true, ye = true,
        yt = true, yu = true, za = true, zm = true, zr = true, zw = true}
    -- Table of protocols
    local protocols = {
        [''] = 0,
        ['http://'] = 0,
        ['https://'] = 0,
        ['ftp://'] = 0
    }
    -- Table for status of url search
    local finished = {}
    -- URL identified
    local found_url = nil
    -- Function to return the max value of the four inputs
    local max_of_four = function(a, b, c, d)
        return math.max(a + 0, b + 0, c + 0, d + 0)
    end
    -- For each group in the match, do some stuff
    local first, last
    for pos_start, url, prot, subd, tld, colon, port, slash, path, pos_end in
        string:gmatch('()(([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w+)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))()')
    do
        if protocols[prot:lower()] == (1 - #slash) * #path and not subd:find('%W%W')
            and (colon == '' or port ~= '' and port + 0 < 65536)
            and (tlds[tld:lower()] or tld:find('^%d+$') and subd:find('^%d+%.%d+%.%d+%.$')
            and max_of_four(tld, subd:match('^(%d+)%.(%d+)%.(%d+)%.$')) < 256)
        then
            finished[pos_start] = true
            found_url = true
            if col then
                if col >= pos_start - 1 and col < pos_end - 1 then
                    first, last = pos_start, pos_end
                end
            end
        end
    end
    -- TODO: add comment
    for pos_start, url, prot, dom, colon, port, slash, path, pos_end in
        string:gmatch('()((%f[%w]%a+://)(%w[-.%w]*)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))()')
        do
        if not finished[pos_start] and not (dom..'.'):find('%W%W')
            and protocols[prot:lower()] == (1 - #slash) * #path
            and (colon == '' or port ~= '' and port + 0 < 65536)
        then
            found_url = true
            if col then
                if col >= pos_start - 1 and col < pos_end - 1 then
                    first, last = pos_start, pos_end
                end
            end
        end
    end
    -- TODO: add comment
    if found_url ~= true then found_url = false end
    if to_return == 'boolean' then
        return(found_url)
    elseif to_return == 'positions' then
        if found_url then
            return first, last
        end
    end
end

M.transformPath = function(text)
    if new_file_prefix then
        local prefix
        -- If user wants the prefix evaluated, do it now
        if evaluate_prefix then
            prefix = loadstring("return "..new_file_prefix)()
        -- Otherwise, use the string provided by the user as the prefix
        else
            prefix = new_file_prefix
        end
        -- Set up the replacement
        text = string.gsub(text, " ", "-")
        -- Add prefix and make lowercase
        text = prefix..string.lower(text)
        return(text)
    elseif type(transform_path) ~= 'function' or not transform_path then
        return(text)
    else
        return(transform_path(text))
    end
end

--[[
formatLink() creates a formatted link from whatever text is passed to it
Returns a string:
     1. '[string of text](<prefix>_string-of-text.md)' in most cases
     2. '[anchor link](#anchor-link)' if the text starts with a hash (#)
--]]
M.formatLink = function(text, part)
    local replacement, path_text
    -- If the text starts with a hash, format the link as an anchor link
    if string.sub(text, 0, 1) == '#' then
        path_text = string.gsub(text, '[^%a%s%d%-_]', '')
        text = string.gsub(text, '^#* *', '')
        path_text = string.gsub(path_text, '^ ', '')
        path_text = string.gsub(path_text, ' ', '-')
        path_text = string.gsub(path_text, '%-%-', '-')
        path_text = '#'..string.lower(path_text)
    else
        path_text = M.transformPath(text)
        if not implicit_extension then
            path_text = path_text..'.md'
        end
    end
    -- Format the replacement depending on the user's link style preference
    if link_style == 'wiki' then
        replacement = {'[['..path_text..'|'..text..']]'}
    else
        replacement = {'['..text..']'..'('..path_text..')'}
    end
    -- Return the requested part
    if part == nil then
        return(replacement)
    elseif part == 1 then
        return(text)
    elseif part == 2 then
        return(path_text)
    end
end

--[[
createLink() makes a link from the word under the cursor--or, if no word is
under the cursor, produces the syntax for a md link: [](YYYY-MM-DD_.md)
Returns nothing via stdout, but does insert text into the vim buffer
--]]
M.createLink = function()
    -- Get mode from vim
    local mode = vim.api.nvim_get_mode()['mode']
    -- Get the cursor position
    local position = vim.api.nvim_win_get_cursor(0)
    local row = position[1]
    local col = position[2]
    -- If the current mode is 'normal', make link from word under cursor
    if mode == 'n' then
        -- Get the text of the line the cursor is on
        local line = vim.api.nvim_get_current_line()
        local url_start, url_end = M.hasUrl(line, 'positions', col)
        if url_start and url_end then
            -- Prepare the replacement
            local url = line:sub(url_start, url_end - 1)
            local replacement = (link_style == 'wiki' and {'[['..url..'|]]'}) or {'[]'..'('..url..')'}
            -- Replace
            vim.api.nvim_buf_set_text(0, row - 1, url_start - 1, row - 1, url_end - 1, replacement)
            -- Move the cursor to the name part of the link and change mode
            vim.api.nvim_win_set_cursor(0, {row, url_start})
            vim.cmd('startinsert')
        else
            -- Get the word under the cursor
            local cursor_word = vim.fn.expand('<cword>')
            -- Make a markdown link out of the date and cursor
            local replacement = M.formatLink(cursor_word)
            -- Find the (first) position of the matched word in the line
            local left, right = string.find(line, cursor_word, nil, true)
            -- Make sure it's not a duplicate of the word under the cursor, and if it
            -- is, perform the search until a match is found whose right edge follows
            -- the cursor position
            while right < col do
                left, right = string.find(line, cursor_word, right, true)
            end
            -- Replace the word under the cursor w/ the formatted link replacement
            vim.api.nvim_buf_set_text(0, row - 1, left - 1, row - 1, right, replacement)
            vim.api.nvim_win_set_cursor(0, {row, col + 1})
        end
    -- If current mode is 'visual', make link from selection
    elseif mode == 'v' then
        -- Get the start of the visual selection (the end is the cursor position)
        local first = vim.fn.getpos('v')
        -- If the start of the visual selection is after the cursor position,
        -- use the cursor position as start and the visual position as finish
        local inverted = first[3] > col
        local start = (inverted and {row - 1, col}) or {first[2] - 1, first[3] - 1 + first[4]}
        local finish = (inverted and {first[2] - 1, first[3] - 1 + first[4]}) or {row - 1, col}
        local start_row = (inverted and row - 1) or first[2] - 1
        local start_col = (inverted and col) or first[3] - 1
        local end_row = (inverted and first[2] - 1) or row - 1
        local end_col = (inverted and first[3]) or col + 1
        local region = vim.region(
                0,
                start,
                finish,
                vim.fn.visualmode(),
                (vim.o.selection ~= 'exclusive')
            )
        local lines = vim.api.nvim_buf_get_lines(
            0, start[1], finish[1] + 1, false
        )
        lines[1] = lines[1]:sub(
            region[start[1]][1] + 1, region[start[1]][2]
        )
        if start[1] ~= finish[1] then
            lines[#lines] = lines[#lines]:sub(
                region[finish[1]][1] + 1, region[finish[1]][2]
            )
        end
        -- Save the text selection & replace spaces with dashes
        local text = table.concat(lines)
        local replacement = M.formatLink(text)
        -- Replace the visual selection w/ the formatted link replacement
        vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, replacement)
        -- Leave visual mode
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), 'x', true)
        -- Retain original cursor position
        vim.api.nvim_win_set_cursor(0, {row, col + 1})
    end
end

--[[
destroyLink() replaces any link the cursor is currently overlapping with just
the name part of the link.
--]]
M.destroyLink = function()
    -- Get link name, indices, and row the cursor is currently on
    local link_name, first, last, row = M.getLinkPart(M.getLinkUnderCursor(), 'name')
    -- Replace the link with just the name
    vim.api.nvim_buf_set_text(0, row - 1, first - 1, row - 1, last, {link_name})
end

--[[
followLink()
--]]
M.followLink = function(path, anchor)
    -- Path can be provided as an argument (this is currently only used when
    -- this function retrieves a path from the citation handler). If no path
    -- is provided as an arg, get the path under the cursor via getLinkPart().
    if path or anchor then
        path, anchor = path, anchor
    else
        path, anchor = M.getLinkPart(M.getLinkUnderCursor(), 'source')
    end
    if path then
        require('mkdnflow').paths.handlePath(path, anchor)
    else
        M.createLink()
    end
end

M.tagSpan = function()
    -- Get mode & cursor position from vim
    local mode, position = vim.api.nvim_get_mode()['mode'], vim.api.nvim_win_get_cursor(0)
    local row, col = position[1], position[2]
    -- If the current mode is 'normal', make link from word under cursor
    if mode == 'v' then
        -- Get the start of the visual selection (the end is the cursor position)
        local first = vim.fn.getpos('v')
        -- If the start of the visual selection is after the cursor position,
        -- use the cursor position as start and the visual position as finish
        local inverted = first[3] > col
        local start = (inverted and {row - 1, col}) or {first[2] - 1, first[3] - 1 + first[4]}
        local finish = (inverted and {first[2] - 1, first[3] - 1 + first[4]}) or {row - 1, col}
        local start_row = (inverted and row - 1) or first[2] - 1
        local start_col = (inverted and col) or first[3] - 1
        local end_row = (inverted and first[2] - 1) or row - 1
        local end_col = (inverted and first[3]) or col + 1
        local region = vim.region(
            0,
            start,
            finish,
            vim.fn.visualmode(),
            (vim.o.selection ~= 'exclusive')
        )
        local lines = vim.api.nvim_buf_get_lines(
            0, start[1], finish[1] + 1, false
        )
        lines[1] = lines[1]:sub(
            region[start[1]][1] + 1, region[start[1]][2]
        )
        if start[1] ~= finish[1] then
            lines[#lines] = lines[#lines]:sub(
                region[finish[1]][1] + 1, region[finish[1]][2]
            )
        end
        -- Save the text selection & replace spaces with dashes
        local text = table.concat(lines)
        local replacement = '['..text..']'..'{'..M.formatLink('#'..text, 2)..'}'
        -- Replace the visual selection w/ the formatted link replacement
        vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, {replacement})
        -- Leave visual mode
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), 'x', true)
        -- Retain original cursor position
        vim.api.nvim_win_set_cursor(0, {row, col + 1})
    end
end

return M
