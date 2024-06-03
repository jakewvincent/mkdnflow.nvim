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
local links = config.links
local utils = require('mkdnflow').utils

-- Table for global functions
local M = {}

local contains = function(start_row, start_col, end_row, end_col, cur_row, cur_col)
    local contained = cur_row > start_row and cur_row < end_row
    if cur_row == start_row and start_row == end_row then
        contained = cur_col > start_col - 1 and cur_col <= end_col
    elseif cur_row == start_row then
        contained = cur_col > start_col - 1
    elseif cur_row == end_row then
        contained = cur_col <= end_col
    end
    return contained
end

--[[
getLinkUnderCursor() retrieves a link of any type that is beneath a given column
number on the current line. The col number will be the cursor position by
default, but that can be overridden by passing in a col number argument.
--]]
M.getLinkUnderCursor = function(col)
    local position = vim.api.nvim_win_get_cursor(0)
    local capture, start_row, start_col, end_row, end_col, match, match_lines
    col = col or position[2]
    local patterns = {
        md_link = '(%b[]%b())',
        wiki_link = '(%[%b[]%])',
        ref_style_link = '(%b[]%s?%b[])',
        auto_link = '(%b<>)',
        citation = "[^%a%d]-(@[%a%d_%.%-']*[%a%d]+)[%s%p%c]?",
    }
    local row = position[1]
    local lines = vim.api.nvim_buf_get_lines(0, row - 1 - links.context, row + links.context, false)
    -- Iterate through the patterns to see if there's a matching link under the cursor
    for link_type, pattern in pairs(patterns) do
        local init_row, init_col = 1, 1
        local continue = true
        while continue do
            -- Look for the pattern in the line(s)
            --link_start, link_finish, capture = string.find(lines, pattern, init)
            start_row, start_col, end_row, end_col, capture, match_lines =
                utils.mFind(lines, pattern, row - links.context, init_row, init_col)
            if start_row and link_type == 'citation' then
                local possessor = string.gsub(capture, "'s$", '') -- Remove Saxon genitive if it's on the end of the citekey
                if #capture > #possessor then
                    capture = possessor
                    end_col = end_col - 2
                end
            end
            -- Check for overlap w/ cursor
            if start_row then -- There's a match
                local overlaps =
                    contains(start_row, start_col, end_row, end_col, position[1], position[2] + 1)
                if overlaps then
                    match = capture
                    continue = false
                else
                    init_row, init_col = end_row, end_col
                end
            else
                continue = false
            end
        end
        if match then -- Return the match and type of link if there was a match
            return { match, match_lines, link_type, start_row, start_col, end_row, end_col }
        end
    end
end

--[[
get_ref()
--]]
local get_ref = function(refnr, start_row)
    start_row = start_row or vim.api.nvim_win_get_cursor(0)[1]
    local row = start_row + 1
    local line_count, continue = vim.api.nvim_buf_line_count(0), true
    -- Look for reference
    while continue and row <= line_count do
        local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
        local start, finish, match = string.find(line, '^(%[' .. refnr .. '%]: .*)')
        if match then
            local _, label_finish = string.find(match, '^%[.-%]: ')
            continue = false
            return string.sub(match, label_finish + 1), row, label_finish + 1, finish
        else
            row = row + 1
        end
    end
end

--[[
getLinkPart() extracts a given part of a link (source, name, or anchor)
Returns a string (or two strings if there is an anchor within the source)
--]]
M.getLinkPart = function(link_table, part)
    table.unpack = table.unpack or unpack
    if link_table then
        local text, match_lines, link_type, start_row, start_col, end_row, end_col =
            table.unpack(link_table)
        part = part or 'source'
        local patterns = {
            name = {
                md_link = '%[(.*)%]',
                wiki_link = '|(.-)%]',
                wiki_link_no_bar = '%[%[(.-)%]%]',
                wiki_link_anchor_no_bar = '%[%[(.-)#.-%]%]',
                ref_style_link = '%[(.*)%]%s?%[',
                citation = '(@.*)',
            },
            source = {
                md_link = { '%](%b())', '%((.*)%)' }, -- 3 thru length of match
                wiki_link = '%[%[(.-)|.-%]%]', -- 3 thru length of match
                wiki_link_no_bar = '%[%[(.-)%]%]', -- 3 thru length of match
                ref_style_link = '%]%[(.*)%]', -- 3 or 4 thru length of match
                auto_link = '<(.-)>',
                citation = '(@.*)', -- find indices will work
            },
            anchor = {
                md_link = '(#.-)%)', -- ?
                wiki_link = '(#.-)|', -- ?
                wiki_link_no_bar = '(#.-)%]%]', -- ?
                auto_link = '<.-(#.-)>',
            },
        }
        local get_from = { -- Table of functions by link type
            md_link = function(part_)
                local part_start_row, part_start_col, part_end_row, part_end_col, match, rematch_lines =
                    utils.mFind(match_lines, patterns[part_]['md_link'], start_row, nil, start_col)
                if part_ == 'source' then
                    -- Check for angle brackets
                    if match:find('^<.*>$') then
                        part_start_row, part_start_col, part_end_row, part_end_col, match, rematch_lines =
                            utils.mFind(match_lines, '%(<(.*)>%)', part_start_row)
                    end
                    -- Make part start and finish relative to line start, not link start
                    local anchor_start, _, anchor = string.find(match, '(#.*)')
                    if anchor_start then
                        match = string.sub(match, 1, anchor_start - 1)
                    else
                        anchor = ''
                    end
                    return match, anchor, part_start_row, part_start_col, part_end_row, part_end_col
                else
                    return match, '', part_start_row, part_start_col, part_end_row, part_end_col
                end
            end,
            wiki_link = function(part_)
                local part_start_row, part_start_col, part_end_row, part_end_col, match, rematch_lines =
                    utils.mFind(
                        match_lines,
                        patterns[part_]['wiki_link'],
                        start_row,
                        nil,
                        start_col
                    )
                if match then
                    if part_ == 'source' then
                        -- Check for angle brackets
                        if match:find('^<.*>$') then
                            part_start_row, part_start_col, part_end_row, part_end_col, match, rematch_lines =
                                utils.mFind(match_lines, '%[<(.*)>|', part_start_row)
                        end
                        -- Make part start and finish relative to line start, not link start
                        local anchor_start, _, anchor = string.find(match, '(#.*)')
                        if anchor_start then
                            match = string.sub(match, 1, anchor_start - 1)
                        else
                            anchor = ''
                        end
                        return match,
                            anchor,
                            part_start_row,
                            part_start_col,
                            part_end_row,
                            part_end_col
                    else
                        return match, '', part_start_row, part_start_col, part_end_row, part_end_col
                    end
                elseif match and part_ == 'name' and string.match(match, '#') then -- If there was no match, we have a link w/ no bar; check for an anchor first
                    part_start_row, part_start_col, part_end_row, part_end_col, match, rematch_lines =
                        utils.mFind(
                            match_lines,
                            patterns[part_]['wiki_link_anchor_no_bar'],
                            start_row,
                            nil,
                            start_col
                        )
                    return match, '', part_start_row, part_start_col, part_end_row, part_end_col
                else
                    part_start_row, part_start_col, part_end_row, part_end_col, match, rematch_lines =
                        utils.mFind(
                            match_lines,
                            patterns[part_]['wiki_link_no_bar'],
                            start_row,
                            nil,
                            start_col
                        )
                    if part_ == 'source' then
                        -- Check for angle brackets
                        if match:find('^<.*>$') then
                            part_start_row, part_start_col, part_end_row, part_end_col, match, rematch_lines =
                                utils.mFind(match_lines, '%[<(.*)>]', part_start_row)
                        end
                        -- Make part start and finish relative to line start, not link start
                        local anchor_start, _, anchor = string.find(match, '(#.*)')
                        if anchor_start then
                            match = string.sub(match, 1, anchor_start - 1)
                        else
                            anchor = ''
                        end
                        return match,
                            anchor,
                            part_start_row,
                            part_start_col,
                            part_end_row,
                            part_end_col
                    else
                        return match, '', part_start_row, part_start_col, part_end_row, part_end_col
                    end
                end
            end,
            ref_style_link = function(part_)
                local part_start_row, part_start_col, part_end_row, part_end_col, match, rematch_lines =
                    utils.mFind(match_lines, patterns[part_]['ref_style_link'], start_row)
                if part_ == 'source' then
                    local source, source_row, source_start, _ = get_ref(match, part_start_row)
                    if source then -- If a source was found, extract the relevant information from the source line
                        local title = string.match(source, '.* (["\'%(%[].*["\'%)%]])') -- Check for a title on the source line
                        if title then
                            local start, ref_source
                            -- Check first for sources surrounded by < ... >
                            start, _, ref_source =
                                string.find(source, '^<(.*)> ["\'%(%[].*["\'%)%]]')
                            if not start then
                                start, _, source = string.find(source, '^(.*) ["\'%(%[].*["\'%)%]]')
                            else
                                start = start + 1 -- Add 1 if the source is surrounded by < ... >
                                source = ref_source
                            end
                            part_start_col = source_start + start - 1
                            part_end_col = part_start_col + #source - 1
                        else
                            local start, ref_source
                            -- Check first for sources surrounded by < ... >
                            start, _, ref_source = string.find(source, '^<(.*)>')
                            if not start then
                                start, _, source = string.find(source, '^(.-)%s*$')
                            else
                                start = start + 1
                                source = ref_source
                            end
                            part_start_col = source_start + start - 1
                            part_end_col = part_start_col + #source - 1
                        end
                        -- Check for an anchor
                        local anchor_start, _, anchor = string.find(source, '(#.*)')
                        if anchor_start then
                            source = string.sub(source, 1, anchor_start - 1)
                            --return source, anchor, part_start, part_finish, source_row
                            return source,
                                anchor,
                                source_row,
                                part_start_col,
                                source_row,
                                part_end_col
                        else
                            return source, '', source_row, part_start_col, source_row, part_end_col
                        end
                    end
                else
                    return match, '', part_start_row, part_start_col, part_end_row, part_end_col
                end
            end,
            auto_link = function(part_)
                local part_start_row, part_start_col, part_end_row, part_end_col, match, rematch_lines =
                    utils.mFind(match_lines, patterns[part_]['auto_link'], start_row)
                if part_ == 'source' then
                    local anchor_start, _, anchor = string.find(match, '(#.*)')
                    if anchor_start then
                        match = string.sub(match, 1, anchor_start - 1)
                    else
                        anchor = ''
                    end
                    return match, anchor, part_start_row, part_start_col, part_end_row, part_end_col
                end
            end,
            citation = function(part_)
                local part_start_col, part_end_col, match =
                    string.find(text, patterns[part_]['citation'])
                return match, '', start_row, part_start_col, end_row, part_end_col
            end,
        }
        local part_text, anchor
        part_text, anchor, start_row, start_col, end_row, end_col = get_from[link_type](part)
        return part_text, anchor, link_type, start_row, start_col, end_row, end_col
    end
end

--[[
getBracketedSpanPart() retrieves the given part of a bracketed span (either
the attribute or the spanned text).
--]]
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
                indices = { first = first, last = last }
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
        if part == 'text' then
            local text_pattern = '(%b[])%b{}'
            local span = string.sub(line[1], indices['first'], indices['last'])
            local text = string.sub(string.match(span, text_pattern), 2, -2)
            -- Return the text and the indices of the bracketed span
            return text, indices['first'], indices['last'], row
        elseif part == 'attr' then
            local attr_pattern = '%b[](%b{})'
            local attr = string.sub(
                string.match(string.sub(line[1], indices['first'], indices['last']), attr_pattern),
                2,
                -2
            )
            local attr_first, attr_last =
                line[1]:find('%]%{' .. utils.luaEscape(attr), indices['first'])
            attr_first = attr_first + 2
            return attr, attr_first, attr_last, row
        end
    else
        return nil
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
    -- This function based largely on the solution in https://stackoverflow.com/questions/23590304/finding-a-url-in-a-string-lua-pattern
    -- Table of top-level domains
    local tlds = {
        ac = true,
        ad = true,
        ae = true,
        aero = true,
        af = true,
        ag = true,
        ai = true,
        al = true,
        am = true,
        an = true,
        ao = true,
        aq = true,
        ar = true,
        arpa = true,
        as = true,
        asia = true,
        at = true,
        au = true,
        aw = true,
        ax = true,
        az = true,
        ba = true,
        bb = true,
        bd = true,
        be = true,
        bf = true,
        bg = true,
        bh = true,
        bi = true,
        biz = true,
        bj = true,
        bm = true,
        bn = true,
        bo = true,
        br = true,
        bs = true,
        bt = true,
        bv = true,
        bw = true,
        by = true,
        bz = true,
        ca = true,
        cat = true,
        cc = true,
        cd = true,
        cf = true,
        cg = true,
        ch = true,
        ci = true,
        ck = true,
        cl = true,
        cm = true,
        cn = true,
        co = true,
        com = true,
        coop = true,
        cr = true,
        cs = true,
        cu = true,
        cv = true,
        cx = true,
        cy = true,
        cz = true,
        dd = true,
        de = true,
        dj = true,
        dk = true,
        dm = true,
        ['do'] = true,
        dz = true,
        ec = true,
        edu = true,
        ee = true,
        eg = true,
        eh = true,
        er = true,
        es = true,
        et = true,
        eu = true,
        fi = true,
        firm = true,
        fj = true,
        fk = true,
        fm = true,
        fo = true,
        fr = true,
        fx = true,
        ga = true,
        gb = true,
        gd = true,
        ge = true,
        gf = true,
        gh = true,
        gi = true,
        gl = true,
        gm = true,
        gn = true,
        gov = true,
        gp = true,
        gq = true,
        gr = true,
        gs = true,
        gt = true,
        gu = true,
        gw = true,
        gy = true,
        hk = true,
        hm = true,
        hn = true,
        hr = true,
        ht = true,
        hu = true,
        id = true,
        ie = true,
        il = true,
        im = true,
        ['in'] = true,
        info = true,
        int = true,
        io = true,
        iq = true,
        ir = true,
        is = true,
        it = true,
        je = true,
        jm = true,
        jo = true,
        jobs = true,
        jp = true,
        ke = true,
        kg = true,
        kh = true,
        ki = true,
        km = true,
        kn = true,
        kp = true,
        kr = true,
        kw = true,
        ky = true,
        kz = true,
        la = true,
        lb = true,
        lc = true,
        li = true,
        lk = true,
        lr = true,
        ls = true,
        lt = true,
        lu = true,
        lv = true,
        ly = true,
        ma = true,
        mc = true,
        md = false,
        me = true,
        mg = true,
        mh = true,
        mil = true,
        mk = true,
        ml = true,
        mm = true,
        mn = true,
        mo = true,
        mobi = true,
        mp = true,
        mq = true,
        mr = true,
        ms = true,
        mt = true,
        mu = true,
        museum = true,
        mv = true,
        mw = true,
        mx = true,
        my = true,
        mz = true,
        na = true,
        name = true,
        nato = true,
        nc = true,
        ne = true,
        net = true,
        nf = true,
        ng = true,
        ni = true,
        nl = true,
        no = true,
        nom = true,
        np = true,
        nr = true,
        nt = true,
        nu = true,
        nz = true,
        om = true,
        org = true,
        pa = true,
        pe = true,
        pf = true,
        pg = true,
        ph = true,
        pk = true,
        pl = true,
        pm = true,
        pn = true,
        post = true,
        pr = true,
        pro = true,
        ps = true,
        pt = true,
        pw = true,
        py = true,
        qa = true,
        re = true,
        ro = true,
        ru = true,
        rw = true,
        sa = true,
        sb = true,
        sc = true,
        sd = true,
        se = true,
        sg = true,
        sh = true,
        si = true,
        sj = true,
        sk = true,
        sl = true,
        sm = true,
        sn = true,
        so = true,
        sr = true,
        ss = true,
        st = true,
        store = true,
        su = true,
        sv = true,
        sy = true,
        sz = true,
        tc = true,
        td = true,
        tel = true,
        tf = true,
        tg = true,
        th = true,
        tj = true,
        tk = true,
        tl = true,
        tm = true,
        tn = true,
        to = true,
        tp = true,
        tr = true,
        travel = true,
        tt = true,
        tv = true,
        tw = true,
        tz = true,
        ua = true,
        ug = true,
        uk = true,
        um = true,
        us = true,
        uy = true,
        va = true,
        vc = true,
        ve = true,
        vg = true,
        vi = true,
        vn = true,
        vu = true,
        web = true,
        wf = true,
        ws = true,
        xxx = true,
        ye = true,
        yt = true,
        yu = true,
        za = true,
        zm = true,
        zr = true,
        zw = true,
    }
    -- Table of protocols
    local protocols = {
        [''] = 0,
        ['http://'] = 0,
        ['https://'] = 0,
        ['ftp://'] = 0,
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
        string.gmatch(
            string,
            '()(([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w+)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))()'
        )
    do
        if
            protocols[prot:lower()] == (1 - #slash) * #path
            and not subd:find('%W%W')
            and (colon == '' or port ~= '' and port + 0 < 65536)
            and (
                tlds[tld:lower()]
                or tld:find('^%d+$')
                    and subd:find('^%d+%.%d+%.%d+%.$')
                    and max_of_four(tld, subd:match('^(%d+)%.(%d+)%.(%d+)%.$')) < 256
            )
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
        string.gmatch(
            string,
            '()((%f[%w]%a+://)(%w[-.%w]*)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))()'
        )
    do
        if
            not finished[pos_start]
            and not (dom .. '.'):find('%W%W')
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
    if found_url ~= true then
        found_url = false
    end
    if to_return == 'boolean' then
        return found_url
    elseif to_return == 'positions' then
        if found_url then
            return first, last
        end
    end
end

--[[
transformPath() transforms the text passed in according to the default or
user-supplied explicit transformation function.
--]]
M.transformPath = function(text)
    if type(links.transform_explicit) ~= 'function' or not links.transform_explicit then
        return text
    else
        return (links.transform_explicit(text))
    end
end

--[[
formatLink() creates a formatted link from whatever text is passed to it
Returns a string:
     1. '[string of text](<prefix>_string-of-text.md)' in most cases
     2. '[anchor link](#anchor-link)' if the text starts with a hash (#)
--]]
M.formatLink = function(text, source, part)
    local replacement, path_text
    -- If the text starts with a hash, format the link as an anchor link
    if string.sub(text, 0, 1) == '#' and not source then
        path_text = string.gsub(text, '[^%a%s%d%-_]', '')
        text = string.gsub(text, '^#* *', '')
        path_text = string.gsub(path_text, '^ ', '')
        path_text = string.gsub(path_text, ' ', '-')
        path_text = string.gsub(path_text, '%-%-', '-')
        path_text = '#' .. string.lower(path_text)
    elseif not source then
        path_text = M.transformPath(text)
        -- If no path_text, end here
        if not path_text then
            return
        end
        if not links.implicit_extension then
            path_text = path_text .. '.md'
        end
    else
        path_text = source
    end
    -- Format the replacement depending on the user's link style preference
    if links.style == 'wiki' then
        replacement = (links.name_is_source and { '[[' .. text .. ']]' })
            or { '[[' .. path_text .. '|' .. text .. ']]' }
    else
        replacement = { '[' .. text .. ']' .. '(' .. path_text .. ')' }
    end
    -- Return the requested part
    if part == nil then
        return replacement
    elseif part == 1 then
        return text
    elseif part == 2 then
        return path_text
    end
end

--[[
createLink() makes a link from the word under the cursor--or, if no word is
under the cursor, produces the syntax for a md link: [](YYYY-MM-DD_.md)
Returns nothing via stdout, but does insert text into the vim buffer
--]]
M.createLink = function(args)
    args = args or {}
    local from_clipboard = args.from_clipboard or false
    local range = args.range or false
    -- Get mode from vim
    local mode = vim.api.nvim_get_mode()['mode']
    -- Get the cursor position
    local position = vim.api.nvim_win_get_cursor(0)
    local row = position[1]
    local col = position[2]
    -- If the current mode is 'normal', make link from word under cursor
    if mode == 'n' and not range then
        -- Get the text of the line the cursor is on
        local line = vim.api.nvim_get_current_line()
        local url_start, url_end = M.hasUrl(line, 'positions', col)
        if url_start and url_end then
            -- Prepare the replacement
            local url = line:sub(url_start, url_end - 1)
            local replacement = (links.style == 'wiki' and { '[[' .. url .. '|]]' })
                or { '[]' .. '(' .. url .. ')' }
            -- Replace
            vim.api.nvim_buf_set_text(0, row - 1, url_start - 1, row - 1, url_end - 1, replacement)
            -- Move the cursor to the name part of the link and change mode
            if links.style == 'wiki' then
                vim.api.nvim_win_set_cursor(0, { row, url_end + 2 })
            else
                vim.api.nvim_win_set_cursor(0, { row, url_start })
            end
            vim.cmd('startinsert')
        else
            -- Get the word under the cursor
            local cursor_word = vim.fn.expand('<cword>')
            -- Make a markdown link out of the date and cursor
            local replacement
            if from_clipboard then
                replacement = M.formatLink(cursor_word, vim.fn.getreg('+'))
            else
                replacement = M.formatLink(cursor_word)
            end
            -- If there's no replacement, stop here
            if not replacement then
                return
            end
            -- Find the (first) position of the matched word in the line
            local left, right = string.find(line, cursor_word, nil, true)
            -- Make sure it's not a duplicate of the word under the cursor, and if it
            -- is, perform the search until a match is found whose right edge follows
            -- the cursor position
            if cursor_word ~= '' then
                while right < col do
                    left, right = string.find(line, cursor_word, right, true)
                end
            else
                left, right = col + 1, col
            end
            -- Replace the word under the cursor w/ the formatted link replacement
            vim.api.nvim_buf_set_text(0, row - 1, left - 1, row - 1, right, replacement)
            vim.api.nvim_win_set_cursor(0, { row, col + 1 })
        end
    -- If current mode is 'visual', make link from selection
    elseif mode == 'v' or range then
        -- Get the start of the visual selection (the end is the cursor position)
        local vis = vim.fn.getpos('v')
        -- If the start of the visual selection is after the cursor position,
        -- use the cursor position as start and the visual position as finish
        local inverted = range and false or vis[3] > col
        local start, finish
        if range then
            start = vim.api.nvim_buf_get_mark(0, '<')
            finish = vim.api.nvim_buf_get_mark(0, '>')
            -- Update char offsets
            start[1] = start[1] - 1
            finish[1] = finish[1] - 1
        else
            start = (inverted and { row - 1, col }) or { vis[2] - 1, vis[3] - 1 + vis[4] }
            finish = (inverted and { vis[2] - 1, vis[3] - 1 + vis[4] }) or { row - 1, col }
        end
        local start_row = (inverted and row - 1) or vis[2] - 1
        local start_col = (inverted and col) or vis[3] - 1
        local end_row = (inverted and vis[2] - 1) or row - 1
        -- If inverted, use the col value from the visual selection; otherwise, use the col value
        -- from start.
        local end_col = (inverted and vis[3]) or finish[2] + 1
        -- Make sure the selection is on a single line; otherwise, do nothing & throw a warning
        if start_row == end_row then
            local lines = vim.api.nvim_buf_get_lines(0, start[1], finish[1] + 1, false)

            -- Check if last byte is part of a multibyte character & adjust end index if so
            local is_multibyte_char =
                utils.isMultibyteChar({ buffer = 0, row = finish[1], start_col = end_col })
            if is_multibyte_char then
                end_col = is_multibyte_char['finish']
            end

            -- Reduce the text only to the visual selection
            lines[1] = lines[1]:sub(start_col + 1, end_col)

            -- If start and end are on different rows, reduce the text on the last line to the visual
            -- selection as well
            if start[1] ~= finish[1] then
                lines[#lines] = lines[#lines]:sub(start_col + 1, end_col)
            end
            -- Save the text selection & format as a link
            local text = table.concat(lines)
            local replacement = from_clipboard and M.formatLink(text, vim.fn.getreg('+'))
                or M.formatLink(text)
            -- If no replacement, end here
            if not replacement then
                return
            end
            -- Replace the visual selection w/ the formatted link replacement
            vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, replacement)
            -- Leave visual mode
            vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes('<esc>', true, false, true),
                'x',
                true
            )
            -- Retain original cursor position
            vim.api.nvim_win_set_cursor(0, { row, col + 1 })
        else
            vim.api.nvim_echo(
                {
                    {
                        '⬇️  Creating links from multi-line visual selection not supported',
                        'WarningMsg',
                    },
                },
                true,
                {}
            )
        end
    end
end

--[[
destroyLink() replaces any link the cursor is currently overlapping with just
the name part of the link.
--]]
M.destroyLink = function()
    -- Get link name, indices, and row the cursor is currently on
    local link = M.getLinkUnderCursor()
    if link then
        local link_name = M.getLinkPart(link, 'name')
        -- Replace the link with just the name
        vim.api.nvim_buf_set_text(0, link[4] - 1, link[5] - 1, link[6] - 1, link[7], { link_name })
    else
        vim.api.nvim_echo(
            { { "⬇️  Couldn't find a link under the cursor to destroy!", 'WarningMsg' } },
            true,
            {}
        )
    end
end

--[[
followLink() passes a path and anchor (passed in or picked up from a link under
the cursor) to handlePath from the paths module. If no path or anchor are passed
in and there is no link under the cursor, createLink() is called to create a
link from the word under the cursor or a visual selection (if there is one).
--]]
M.followLink = function(args)
    -- Path can be provided as an argument (this is currently only used when
    -- this function retrieves a path from the citation handler). If no path
    -- is provided as an arg, get the path under the cursor via getLinkPart().
    args = args or {}
    local path = args.path
    local anchor = args.anchor
    local range = args.range or false
    local link_type
    if path or anchor then
        path, anchor = path, anchor
    else
        path, anchor, link_type = M.getLinkPart(M.getLinkUnderCursor(), 'source')
    end
    if path then
        require('mkdnflow').paths.handlePath(path, anchor)
    elseif link_type == 'ref_style_link' then -- If this condition is met, no reference was found
        vim.api.nvim_echo(
            { { "⬇️  Couldn't find a matching reference label!", 'WarningMsg' } },
            true,
            {}
        )
    elseif links.create_on_follow_failure then
        M.createLink({ range = range })
    end
end

--[[
tagSpan() creates a bracketed span from a visual selection and formats the ID
attribute.
--]]
M.tagSpan = function()
    -- Get mode & cursor position from vim
    local mode, position = vim.api.nvim_get_mode()['mode'], vim.api.nvim_win_get_cursor(0)
    local row, col = position[1], position[2]
    -- If the current mode is 'normal', make link from word under cursor
    if mode == 'v' then
        -- Get the start of the visual selection (the end is the cursor position)
        local vis = vim.fn.getpos('v')
        -- If the start of the visual selection is after the cursor position,
        -- use the cursor position as start and the visual position as finish
        local inverted = vis[3] > col
        local start = (inverted and { row - 1, col }) or { vis[2] - 1, vis[3] - 1 + vis[4] }
        local finish = (inverted and { vis[2] - 1, vis[3] - 1 + vis[4] }) or { row - 1, col }
        local start_row = (inverted and row - 1) or vis[2] - 1
        local start_col = (inverted and col) or vis[3] - 1
        local end_row = (inverted and vis[2] - 1) or row - 1
        local end_col = (inverted and vis[3]) or col + 1
        local region =
            vim.region(0, start, finish, vim.fn.visualmode(), (vim.o.selection ~= 'exclusive'))
        local lines = vim.api.nvim_buf_get_lines(0, start[1], finish[1] + 1, false)
        lines[1] = lines[1]:sub(region[start[1]][1] + 1, region[start[1]][2])
        if start[1] ~= finish[1] then
            lines[#lines] = lines[#lines]:sub(region[finish[1]][1] + 1, region[finish[1]][2])
        end
        -- Save the text selection & replace spaces with dashes
        local text = table.concat(lines)
        local replacement = '[' .. text .. ']' .. '{' .. M.formatLink('#' .. text, nil, 2) .. '}'
        -- Replace the visual selection w/ the formatted link replacement
        vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, { replacement })
        -- Leave visual mode
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'x', true)
        -- Retain original cursor position
        vim.api.nvim_win_set_cursor(0, { row, col + 1 })
    end
end

return M
