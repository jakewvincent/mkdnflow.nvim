-- File navigation functions
local M = {}

-- Get the path of the link under the cursor
local get_path = function()
    -- Get current cursor position
    local position = vim.api.nvim_win_get_cursor(0)
    local row = position[1]
    local col = position[2]

    -- Get the indices of the links in the line
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false) -- Get the line text
    local link_pattern = '%[.-%]%(.-%)'                             -- What links look like
    local indices = {}                                              -- Table for match indices
    local last_fin = 1                                              -- Last end index
    local unfound = true
    while unfound do
        -- Get the indices of a match
        local com, fin = string.find(line[1], link_pattern, last_fin)
        -- Check if there's actually after last_fin
        if com and fin then
            -- If there is, check if the match overlaps with the cursor position
            if com - 1 <= col and fin - 1 >= col then
                -- If it does overlap, save the indices of the match
                indices = {com = com, fin = fin}
                -- End the loop
                unfound = false
            else
                -- If it doesn't overlap, save the end index of the match so
                -- we can look for a match following it on the next loop.
                last_fin = fin
            end
        else
            unfound = nil
        end
    end

    -- Check if a link was found under the cursor
    if unfound == false then
        -- If one was found, get the path part of the match and return it
        local path_pattern = '%((.-)%)'
        local path = string.match(string.sub(line[1], indices['com'], indices['fin']), path_pattern)
        return(path)
    else
        return(nil)
    end
end

local is_url = function(string)
    -- This function based largely on the solution in <https://stackoverflow.com/questions/23590304/finding-a-url-in-a-string-lua-pattern>
    -- Table of top-level domains
    local tlds = {ac = true, ad = true, ae = true, aero = true, af = true, ag = true, ai = true, al = true, am = true, an = true, ao = true, aq = true, ar = true, arpa = true, as = true, asia = true, at = true, au = true, aw = true, ax = true, az = true, ba = true, bb = true, bd = true, be = true, bf = true, bg = true, bh = true, bi = true, biz = true, bj = true, bm = true, bn = true, bo = true, br = true, bs = true, bt = true, bv = true, bw = true, by = true, bz = true, ca = true, cat = true, cc = true, cd = true, cf = true, cg = true, ch = true, ci = true, ck = true, cl = true, cm = true, cn = true, co = true, com = true, coop = true, cr = true, cs = true, cu = true, cv = true, cx = true, cy = true, cz = true, dd = true, de = true, dj = true, dk = true, dm = true, ['do'] = true, dz = true, ec = true, edu = true, ee = true, eg = true, eh = true, er = true, es = true, et = true, eu = true, fi = true, firm = true, fj = true, fk = true, fm = true, fo = true, fr = true, fx = true, ga = true, gb = true, gd = true, ge = true, gf = true, gh = true, gi = true, gl = true, gm = true, gn = true, gov = true, gp = true, gq = true, gr = true, gs = true, gt = true, gu = true, gw = true, gy = true, hk = true, hm = true, hn = true, hr = true, ht = true, hu = true, id = true, ie = true, il = true, im = true, ['in'] = true, info = true, int = true, io = true, iq = true, ir = true, is = true, it = true, je = true, jm = true, jo = true, jobs = true, jp = true, ke = true, kg = true, kh = true, ki = true, km = true, kn = true, kp = true, kr = true, kw = true, ky = true, kz = true, la = true, lb = true, lc = true, li = true, lk = true, lr = true, ls = true, lt = true, lu = true, lv = true, ly = true, ma = true, mc = true, md = false, me = true, mg = true, mh = true, mil = true, mk = true, ml = true, mm = true, mn = true, mo = true, mobi = true, mp = true, mq = true, mr = true, ms = true, mt = true, mu = true, museum = true, mv = true, mw = true, mx = true, my = true, mz = true, na = true, name = true, nato = true, nc = true, ne = true, net = true, nf = true, ng = true, ni = true, nl = true, no = true, nom = true, np = true, nr = true, nt = true, nu = true, nz = true, om = true, org = true, pa = true, pe = true, pf = true, pg = true, ph = true, pk = true, pl = true, pm = true, pn = true, post = true, pr = true, pro = true, ps = true, pt = true, pw = true, py = true, qa = true, re = true, ro = true, ru = true, rw = true, sa = true, sb = true, sc = true, sd = true, se = true, sg = true, sh = true, si = true, sj = true, sk = true, sl = true, sm = true, sn = true, so = true, sr = true, ss = true, st = true, store = true, su = true, sv = true, sy = true, sz = true, tc = true, td = true, tel = true, tf = true, tg = true, th = true, tj = true, tk = true, tl = true, tm = true, tn = true, to = true, tp = true, tr = true, travel = true, tt = true, tv = true, tw = true, tz = true, ua = true, ug = true, uk = true, um = true, us = true, uy = true, va = true, vc = true, ve = true, vg = true, vi = true, vn = true, vu = true, web = true, wf = true, ws = true, xxx = true, ye = true, yt = true, yu = true, za = true, zm = true, zr = true, zw = true}

    -- Table of protocols
    local protocols = {[''] = 0, ['http://'] = 0, ['https://'] = 0, ['ftp://'] = 0}

    -- Table for status of url search
    local finished = {}

    -- URL identified
    local found_url = nil

    -- Function to return the max value of the four inputs
    local max_of_four = function(a, b, c, d)
        return math.max(a + 0, b + 0, c + 0, d + 0)
    end

    -- For each group in the match, do some stuff
    for pos_start, url, prot, subd, tld, colon, port, slash, path in
        string:gmatch'()(([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w+)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))'
    do
        if protocols[prot:lower()] == (1 - #slash) * #path and not subd:find'%W%W'
            and (colon == '' or port ~= '' and port + 0 < 65536)
            and (tlds[tld:lower()] or tld:find'^%d+$' and subd:find'^%d+%.%d+%.%d+%.$'
            and max_of_four(tld, subd:match'^(%d+)%.(%d+)%.(%d+)%.$') < 256)
        then
            finished[pos_start] = true
            found_url = true
        end
    end

    for pos_start, url, prot, dom, colon, port, slash, path in
        string:gmatch'()((%f[%w]%a+://)(%w[-.%w]*)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))'
        do
        if not finished[pos_start] and not (dom..'.'):find'%W%W'
            and protocols[prot:lower()] == (1 - #slash) * #path
            and (colon == '' or port ~= '' and port + 0 < 65536)
        then
            found_url = true
        end
    end

    if found_url ~= true then found_url = false end
    return(found_url)
end

-- Function to open paths outside of vim
local path_handler = function(path)
    local this_os = jit.os
    if this_os == "Linux" then
        vim.api.nvim_command('silent !xdg-open '..path..' &')
    else
        print('File opening is not set up for your OS. Please file an issue.')
    end
end

-- Function to determine the path type (local, url, or filename)
local path_type = function(path)
    if string.find(path, '^local:') then
        return('local')
    elseif is_url(path) then
        return('url')
    else
        return('filename')
    end
end

-- Create the specified file at the specified path (relative to current file?)
M.createLink = function()
    -- Get cursor position and the line the cursor is on
    local position = vim.api.nvim_win_get_cursor(0)
    local row = position[1]
    local col = position[2]
    local line = vim.api.nvim_get_current_line()
    -- If in normal mode, get the word under the cursor and make a markdown link out of it
    local cursor_word = vim.fn.expand('<cword>')
    local date = os.date('%Y-%m-%d')
    local replacement = {'['..cursor_word..']'..'('..date..'_'..cursor_word..'.md)'}

    local left, right = string.find(line, cursor_word, nil, true)

    while right < col do
        left, right = string.find(line, cursor_word, right, true)
    end

    -- Replace w/ the link
    vim.api.nvim_buf_set_text(0, row - 1, left - 1, row - 1, right, replacement)

    -- If in visual mode, get the selection and make a markdown link out of it
end

-- Function to follow the path specified in the link under the cursor, or to
-- create a link out of the word/selection under the cursor
M.followPath = function()
    local path = get_path()
    -- Check that there's a non-nil output of getPath()
    if path then
        -- If so, go to the path specified in the output
        if path_type(path) == 'filename' then
            vim.cmd(':e '..path)
        elseif path_type(path) == 'url' then
            local se_path = vim.fn.shellescape(path)
            path_handler(se_path)
        elseif path_type(path) == 'local' then
            local real_path = vim.fn.shellescape(string.match(path, '^local:(.*)'))
            path_handler(real_path)
        end
    else
        M.createLink()
    end
end

return M
