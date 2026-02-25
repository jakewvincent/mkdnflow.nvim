-- mkdnflow.nvim (Tools for personal markdown notebook navigation and management)
-- Copyright (C) 2022-2023 Jake W. Vincent <https://github.com/jakewvincent>
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

local cmp = require('cmp')
-- TODO: Use vim.uv directly when v0.9.5 support is dropped
local uv = vim.uv or vim.loop

--- Generation counter for cancelling stale async completion requests.
--- Incremented on each source:complete() call; the deferred callback bails
--- if its captured generation no longer matches.
local generation = 0

local MAX_SCAN_DEPTH = 20

--- Pattern matching footnote definition lines: `[^label]: ` with up to 3 leading spaces.
--- Captures the label. Used by scan_footnote_defs() and scan_undefined_refs().
local DEF_PAT = '^%s?%s?%s?%[%^(.-)%]:%s'

--- Recursively scan a directory for files matching a predicate, asynchronously.
---
--- uv.fs_scandir offloads the directory read to libuv's thread pool (async),
--- while uv.fs_scandir_next iterates over already-loaded in-memory results
--- (synchronous). The async benefit comes from the directory read, not the
--- entry iteration.
---
---@param dir string Base directory to scan
---@param predicate fun(name: string): boolean Filter function for file names
---@param on_done fun(filepaths: string[]) Called with all matching absolute paths
---@private
local function async_scan_dir(dir, predicate, on_done)
    local results = {}
    local pending = 0

    local function scan(path, depth)
        if depth > MAX_SCAN_DEPTH then
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

            -- Collect entries first, then process (scandir_next is synchronous
            -- iteration over already-loaded results)
            local entries = {}
            while true do
                local name, entry_type = uv.fs_scandir_next(handle)
                if not name then
                    break
                end
                table.insert(entries, { name = name, type = entry_type })
            end

            local function process_entry(full_path, resolved_type)
                if resolved_type == 'directory' then
                    scan(full_path, depth + 1)
                elseif resolved_type == 'file' then
                    local name = full_path:match('[^/]+$')
                    if name and predicate(name) then
                        table.insert(results, full_path)
                    end
                end
                -- Other types (socket, fifo, etc.) are silently skipped
            end

            for _, entry in ipairs(entries) do
                local full_path = path .. '/' .. entry.name
                if entry.type == 'link' or entry.type == 'unknown' then
                    -- Resolve symlinks and unknown dirent types via stat to
                    -- maintain behavioral parity with vim.fs.find (which follows
                    -- symlinks transparently). On NFS or older ext4 without
                    -- dirent.d_type, all entries may come back as 'unknown'.
                    pending = pending + 1
                    uv.fs_stat(full_path, function(stat_err, stat)
                        if not stat_err and stat then
                            local resolved = stat.type
                            process_entry(full_path, resolved)
                        end
                        pending = pending - 1
                        if pending == 0 then
                            on_done(results)
                        end
                    end)
                else
                    process_entry(full_path, entry.type)
                end
            end

            pending = pending - 1
            if pending == 0 then
                on_done(results)
            end
        end)
    end

    scan(dir, 0)
end

--- Read an entire file asynchronously.
--- Every error branch after a successful fs_open closes the fd to prevent leaks.
---@param filepath string Absolute file path
---@param on_done fun(data: string|nil) Called with file content or nil on error
---@private
local function async_read_file(filepath, on_done)
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
                    on_done(err_read and nil or data)
                end)
            end)
        end)
    end)
end

--- Compute a path relative to a base directory.
--- Inlined from paths.relativeToBase() to avoid calling Neovim APIs
--- (nvim_buf_get_name) from a deferred vim.schedule callback, which would
--- be racy if the user switches buffers during async I/O.
---@param abs_path string Absolute file path
---@param base string Base directory (captured on the main thread before async)
---@return string rel_path Relative path, or basename if not under base
---@private
local function relative_to(abs_path, base)
    local prefix = base:match('/$') and base or (base .. '/')
    if abs_path:sub(1, #prefix) == prefix then
        return abs_path:sub(#prefix + 1)
    end
    return vim.fs.basename(abs_path)
end

--- Extract a bib field value, handling both brace- and quote-delimited values.
--- Strips outer braces/quotes and any nested BibTeX braces (used only for
--- capitalization preservation). Collapses newlines and excess whitespace.
---@param entry string The raw bib entry text
---@param field string The field name to extract (e.g., 'title', 'author')
---@return string|nil value The cleaned field value, or nil if not found
---@private
local function bib_field(entry, field)
    -- Match field = {value} or field = "value", allowing nested braces
    local value = entry:match(field .. '%s*=%s*{(.-)}%s*[,}]')
        or entry:match(field .. '%s*=%s*"(.-)"%s*[,}]')
    if not value then
        return nil
    end
    -- Strip BibTeX braces used for capitalization preservation
    value = value:gsub('[{}]', '')
    -- Collapse newlines and excess whitespace
    value = value:gsub('\n', ' ')
    value = value:gsub('%s%s+', ' ')
    return value
end

--- Format a human-readable entry type label from a BibTeX type string
---@param entry_type string Raw type (e.g., 'article', 'inproceedings')
---@return string label Formatted label (e.g., 'Article', 'Conference Paper')
---@private
local function format_entry_type(entry_type)
    local labels = {
        article = 'Article',
        book = 'Book',
        inbook = 'Book Chapter',
        incollection = 'Book Chapter',
        inproceedings = 'Conference Paper',
        conference = 'Conference Paper',
        mastersthesis = "Master's Thesis",
        phdthesis = 'PhD Thesis',
        techreport = 'Technical Report',
        misc = 'Misc',
        unpublished = 'Unpublished',
    }
    return labels[entry_type:lower()] or entry_type
end

--- Parse bib entries from a string and build nvim-cmp completion items.
--- Extracts rich metadata for the documentation preview: title, author, year,
--- venue, entry type, and the link that would open on MkdnFollowLink (matching
--- the priority in bib.core: file > url > doi > howpublished).
---@param bibentries string The raw contents of a .bib file
---@param bib_source? string Basename of the source .bib file (shown when multiple bib files)
---@return table[] items Array of nvim-cmp completion items
---@private
local function parse_bib_string(bibentries, bib_source)
    local items = {}
    for bibentry in bibentries:gmatch('@.-\n}\n') do
        local item = {}

        local entry_type = bibentry:match('^@(%w+){') or ''
        local title = bib_field(bibentry, 'title') or ''
        local author = bib_field(bibentry, 'author') or ''
        local year = bibentry:match('year%s*=%s*["{]?(%d+)["}]?,?') or ''

        -- Venue: journal for articles, booktitle for proceedings, publisher for books
        local venue = bib_field(bibentry, 'journal')
            or bib_field(bibentry, 'booktitle')
            or bib_field(bibentry, 'publisher')

        -- Link that would open on MkdnFollowLink (same priority as bib.core.get_link)
        local file = bib_field(bibentry, 'file')
        local url = bib_field(bibentry, 'url')
        local doi = bib_field(bibentry, 'doi')
        local howpublished = bib_field(bibentry, 'howpublished')

        -- Build display version of the link: basename for files, full for URLs
        local link_display
        if file then
            link_display = vim.fs.basename(file)
        elseif url then
            link_display = url
        elseif doi then
            link_display = 'https://doi.org/' .. doi
        elseif howpublished then
            link_display = howpublished
        end

        -- Build documentation preview
        local doc = {}
        table.insert(doc, '**' .. title .. '**')
        table.insert(doc, '')

        -- Author line, cleaning up BibTeX "and" separators
        if author ~= '' then
            local cleaned_author = author:gsub('%s+and%s+', ', ')
            table.insert(doc, cleaned_author)
        end

        -- Venue and year on one line
        local venue_year = {}
        if venue then
            table.insert(venue_year, '*' .. venue .. '*')
        end
        if year ~= '' then
            table.insert(venue_year, year)
        end
        if #venue_year > 0 then
            table.insert(doc, table.concat(venue_year, ', '))
        end

        -- Entry type
        if entry_type ~= '' then
            table.insert(doc, format_entry_type(entry_type))
        end

        -- Link (what MkdnFollowLink would open)
        if link_display then
            table.insert(doc, '')
            table.insert(doc, '---')
            table.insert(doc, 'Opens: `' .. link_display .. '`')
        end

        -- Source bib file (only shown when multiple bib files are configured)
        if bib_source then
            if not link_display then
                table.insert(doc, '')
                table.insert(doc, '---')
            end
            table.insert(doc, 'Source: `' .. bib_source .. '`')
        end

        item.documentation = {
            kind = cmp.lsp.MarkupKind.Markdown,
            value = table.concat(doc, '\n'),
        }
        item.label = '@' .. bibentry:match('@%w+{(.-),')
        item.kind = cmp.lsp.CompletionItemKind.Reference
        item.insertText = item.label

        table.insert(items, item)
    end
    return items
end

--- Scan the current buffer for footnote definitions and build completion items.
--- Footnote definitions have the form `[^label]: content` with up to 3 leading spaces.
--- Only the first line of each definition is used for the documentation preview.
---@return table[] items Array of nvim-cmp completion items
---@private
local function scan_footnote_defs()
    local items = {}
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    for _, line in ipairs(lines) do
        local label = string.match(line, DEF_PAT)
        if label then
            local content = string.match(line, '^%s?%s?%s?%[%^.-%]:%s(.+)$') or ''
            content = content:gsub('%s+$', '')

            table.insert(items, {
                label = '[^' .. label .. ']',
                insertText = '^' .. label .. ']',
                filterText = '^' .. label,
                kind = cmp.lsp.CompletionItemKind.Reference,
                documentation = content ~= ''
                        and { kind = cmp.lsp.MarkupKind.Markdown, value = content }
                    or nil,
            })
        end
    end

    return items
end

--- Scan the current buffer for footnote references that have no definition.
--- For each undefined reference, builds a completion item with the definition syntax
--- (`[^label]: `) as insertText and a truncated preview of the line where the
--- reference first appears.
---@return table[] items Array of nvim-cmp completion items
---@private
local function scan_undefined_refs()
    local items = {}
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local ref_pat = '%[%^([^%]]+)%]'

    -- Pass 1: collect defined labels
    local defined = {}
    for _, line in ipairs(lines) do
        local label = string.match(line, DEF_PAT)
        if label then
            defined[label] = true
        end
    end

    -- Pass 2: collect undefined references with context
    local seen = {}
    for _, line in ipairs(lines) do
        -- Skip definition lines to avoid counting [^label] in [^label]: text
        if not string.match(line, DEF_PAT) then
            for label in string.gmatch(line, ref_pat) do
                if not defined[label] and not seen[label] then
                    seen[label] = true

                    -- Build context preview: truncate the line
                    local preview = line
                    if #preview > 80 then
                        preview = preview:sub(1, 77) .. '...'
                    end

                    table.insert(items, {
                        label = '[^' .. label .. ']',
                        insertText = '^' .. label .. ']: ',
                        filterText = '^' .. label,
                        kind = cmp.lsp.CompletionItemKind.Reference,
                        documentation = {
                            kind = cmp.lsp.MarkupKind.Markdown,
                            value = preview,
                        },
                    })
                end
            end
        end
    end

    return items
end

--- Scan the current buffer for headings and return structured heading data.
--- Skips headings inside fenced code blocks (backtick and tilde) and YAML frontmatter.
--- For each heading, collects up to 5 non-empty context lines for the documentation preview.
---@return table[] headings Array of {display, anchor, level, context}
---@private
local function scan_headings()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local links_mod = require('mkdnflow.links')
    local headings = {}
    local in_fence = false
    local start_idx = 1

    -- Skip YAML frontmatter (--- delimited block starting at line 1)
    if lines[1] and lines[1]:match('^%-%-%-$') then
        for i = 2, #lines do
            if lines[i]:match('^%-%-%-$') then
                start_idx = i + 1
                break
            end
        end
    end

    for i = start_idx, #lines do
        local line = lines[i]
        if line:match('^```') or line:match('^~~~') then
            in_fence = not in_fence
        end
        if not in_fence and line:match('^#+%s') then
            local display = line:gsub('^#+ *', '')
            local anchor = links_mod.formatLink(line, nil, 2)

            -- Collect context: up to 5 non-empty lines after the heading
            local context_lines = {}
            for j = i + 1, math.min(i + 10, #lines) do
                local cl = lines[j]
                if cl:match('^#+%s') then
                    break
                end
                if cl:match('^```') or cl:match('^~~~') then
                    break
                end
                if cl ~= '' then
                    table.insert(context_lines, cl)
                    if #context_lines >= 5 then
                        break
                    end
                end
            end

            table.insert(headings, {
                display = display,
                anchor = anchor,
                level = #line:match('^(#+)'),
                context = context_lines,
            })
        end
    end
    return headings
end

--- Build heading completion items for markdown-style or wiki-style anchor triggers.
---@param headings table[] Heading data from scan_headings()
---@param style string 'markdown' or 'wiki'
---@param has_title boolean Whether the link already has display text (markdown only)
---@param has_closing boolean Whether the closing delimiter is already present after cursor
---@param compact boolean Whether wiki links use compact style (wiki only)
---@param title_insert_col? integer 0-indexed column to insert title (for additionalTextEdits)
---@param cursor_row_0? integer 0-indexed cursor row (for additionalTextEdits)
---@return table[] items Array of nvim-cmp completion items
---@private
local function build_heading_items(
    headings,
    style,
    has_title,
    has_closing,
    compact,
    title_insert_col,
    cursor_row_0
)
    local items = {}

    for _, h in ipairs(headings) do
        -- Build documentation preview
        local doc = { string.rep('#', h.level) .. ' ' .. h.display }
        if #h.context > 0 then
            table.insert(doc, '')
            for _, cl in ipairs(h.context) do
                table.insert(doc, cl)
            end
        end

        local item = {
            label = h.display,
            filterText = '#' .. h.display,
            kind = cmp.lsp.CompletionItemKind.Reference,
            detail = 'H' .. h.level,
            documentation = {
                kind = cmp.lsp.MarkupKind.Markdown,
                value = table.concat(doc, '\n'),
            },
        }

        -- Strip leading # from anchor for insertText (the # is already typed)
        local slug = h.anchor:sub(2) -- "my-heading" (without #)

        -- Append slug to filterText so users can filter by either heading text or anchor slug
        item.filterText = item.filterText .. ' ' .. slug

        if style == 'wiki' then
            if compact then
                item.insertText = '#' .. slug .. (has_closing and '' or ']]')
            else
                item.insertText = '#' .. slug .. '|' .. h.display .. (has_closing and '' or ']]')
            end
        else
            -- Markdown style
            item.insertText = '#' .. slug .. (has_closing and '' or ')')
            -- If no title text, add additionalTextEdits to fill in the display text
            if not has_title and title_insert_col and cursor_row_0 then
                item.additionalTextEdits = {
                    {
                        range = {
                            start = { line = cursor_row_0, character = title_insert_col },
                            ['end'] = { line = cursor_row_0, character = title_insert_col },
                        },
                        newText = h.display,
                    },
                }
            end
        end

        table.insert(items, item)
    end

    return items
end

--- Build completion items from async results on the main thread.
---@param file_paths string[] Absolute paths discovered by async_scan_dir
---@param bib_results table<integer, {data: string|nil, path: string}> Bib file contents and paths
---@param bib_count integer Total number of bib files (used to decide whether to show source)
---@param base string Base directory captured before async (for relative path computation)
---@param implicit_ext string|nil Implicit extension config value
---@param links_mod table The links module (for formatLink)
---@return table[] items Array of nvim-cmp completion items
---@private
local function build_items(file_paths, bib_results, bib_count, base, implicit_ext, links_mod)
    local items = {}

    -- Process discovered file paths into file completion items
    if file_paths then
        for _, abs_path in ipairs(file_paths) do
            local rel_path = relative_to(abs_path, base)

            -- Strip extension from link target when implicit_extension is configured
            local source_path = rel_path
            if implicit_ext then
                source_path = rel_path:gsub('%.[^%.]+$', '')
            end

            -- Display label is the filename without extension
            local label = vim.fs.basename(abs_path):gsub('%.[^%.]+$', '')

            -- Format link using the canonical formatter (respects style, compact, etc.)
            local formatted = links_mod.formatLink(label, source_path)
            if formatted then
                -- Read first 1KB for documentation preview (synchronous — fast per file)
                local f = io.open(abs_path, 'rb')
                local preview = f and f:read(1024)
                if f then
                    f:close()
                end

                table.insert(items, {
                    label = label,
                    insertText = formatted[1],
                    kind = cmp.lsp.CompletionItemKind.File,
                    documentation = preview
                            and { kind = cmp.lsp.MarkupKind.Markdown, value = preview }
                        or nil,
                })
            end
        end
    end

    -- Process bib file contents into citation completion items
    local show_bib_source = bib_count > 1
    for _, entry in pairs(bib_results) do
        if entry.data then
            local bib_source = show_bib_source and vim.fs.basename(entry.path) or nil
            local bib_items = parse_bib_string(entry.data, bib_source)
            for _, item in ipairs(bib_items) do
                table.insert(items, item)
            end
        end
    end

    return items
end

---@class MkdnflowCmpSource
local source = {}

--- Create a new completion source instance
---@return MkdnflowCmpSource
source.new = function()
    return setmetatable({}, { __index = source })
end

--- Declare characters that should trigger completion.
--- `^` triggers footnote `[^` completions; `#` triggers heading anchor `](#`
--- and `[[#` completions. The existing `@` trigger works without being declared
--- here; adding it could change offset semantics.
---@return string[]
function source:get_trigger_characters()
    return { '^', '#' }
end

--- Provide completion items when triggered by `@` (files + bib), `[^` (footnotes),
--- or `](#` / `[[#` (heading anchors).
--- File scanning and bib reading are performed asynchronously via vim.uv to
--- avoid blocking the editor. Footnote and heading scanning are synchronous (buffer-local).
---@param params table nvim-cmp completion parameters
---@param callback fun(items: table[]) Callback to return completion items
function source:complete(params, callback)
    local line = params.context.cursor_before_line
    if not line then
        callback({})
        return
    end

    -- Footnote trigger: [^ optionally followed by partial label chars
    if line:match('%[%^[%w_%-]*$') then
        -- Line-start = writing a definition → offer undefined refs
        -- Mid-line = placing a reference → offer defined labels
        if line:match('^%s?%s?%s?%[%^[%w_%-]*$') then
            callback(scan_undefined_refs())
        else
            callback(scan_footnote_defs())
        end
        return
    end

    -- Markdown-style heading anchor trigger: ](#
    -- Matches ](#  but NOT ](filename#  (requires # immediately after open-paren)
    if line:match('%]%(#[^%)]*$') then
        local after = (params.context.cursor_after_line or '')
        local has_closing = after:match('^%)') ~= nil
        local title = line:match('%[(.-)%]%(#[^%)]*$')
        local has_title = title ~= nil and title ~= ''
        local headings = scan_headings()

        -- For the no-title case, compute where to insert the display text
        local title_insert_col, cursor_row_0
        if not has_title then
            cursor_row_0 = params.context.cursor.line
            -- Find the position of [ before ]( — the title goes right after [
            local bracket_pos = line:find('%[%]%(#[^%)]*$')
            if bracket_pos then
                title_insert_col = bracket_pos -- 1-indexed in Lua, but [ is at pos, ] is at pos+1
                -- LSP uses 0-indexed characters; Lua find returns 1-indexed byte offset
                -- Insert position is after the [ character
            end
        end

        callback(
            build_heading_items(
                headings,
                'markdown',
                has_title,
                has_closing,
                false,
                title_insert_col,
                cursor_row_0
            )
        )
        return
    end

    -- Wiki-style heading anchor trigger: [[#
    -- Matches [[#  but NOT [[filename#  (requires # immediately after [[)
    if line:match('%[%[#[^%]|]*$') then
        local after = (params.context.cursor_after_line or '')
        local has_closing = after:match('^%]%]') ~= nil
        local compact = require('mkdnflow').config.links.compact or false
        local headings = scan_headings()

        callback(build_heading_items(headings, 'wiki', true, has_closing, compact, nil, nil))
        return
    end

    -- @ trigger: file links and bib citations
    if not (line:match('^@%w*$') or line:match('%W@%w*$')) then
        callback({})
        return
    end

    -- Bump generation to cancel any in-flight async work from prior calls
    generation = generation + 1
    local my_gen = generation

    -- Capture all Neovim-dependent state on the main thread before going async
    local mkdn = require('mkdnflow')
    local config = mkdn.config
    local links_mod = require('mkdnflow.links')

    -- Determine scan base using the same fallback chain as paths.relativeToBase()
    local path_resolution = config.path_resolution
    local base
    if path_resolution.primary == 'root' and mkdn.root_dir then
        base = mkdn.root_dir
    elseif
        path_resolution.primary == 'first'
        or (path_resolution.primary == 'root' and path_resolution.fallback == 'first')
    then
        base = mkdn.initial_dir
    else
        base = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
    end
    if not base or base == '' then
        base = vim.fn.getcwd()
    end
    -- Normalize backslashes to forward slashes so that relative_to()'s
    -- prefix comparison works on Windows, where root_dir / initial_dir
    -- use native '\' but async_scan_dir joins paths with '/'.
    base = base:gsub('\\', '/')

    local extensions = config.notebook_extensions or { md = true }
    local implicit_ext = config.links.implicit_extension

    -- Collect all bib file paths into a flat list
    local bib_file_list = {}
    local bib_paths = mkdn.bib and mkdn.bib.bib_paths or nil
    if bib_paths then
        for _, group in ipairs({ 'default', 'root', 'yaml' }) do
            if bib_paths[group] then
                for _, v in pairs(bib_paths[group]) do
                    table.insert(bib_file_list, v)
                end
            end
        end
    end

    -- Async coordination: pending must be computed before any async launches
    local file_paths = nil
    local bib_results = {}
    local bib_count = #bib_file_list
    local pending = 1 + bib_count -- 1 for dir scan + N for bib reads

    local function check_done()
        if pending > 0 then
            return
        end
        vim.schedule(function()
            -- Bail if a newer complete() call has superseded this one
            if my_gen ~= generation then
                return
            end
            callback(build_items(file_paths, bib_results, bib_count, base, implicit_ext, links_mod))
        end)
    end

    -- Launch async directory scan
    async_scan_dir(base, function(name)
        local ext = name:match('%.([^%.]+)$')
        return ext and extensions[ext:lower()] or false
    end, function(paths_result)
        file_paths = paths_result
        pending = pending - 1
        check_done()
    end)

    -- Launch async bib file reads in parallel
    for i, bib_path in ipairs(bib_file_list) do
        async_read_file(bib_path, function(data)
            bib_results[i] = { data = data, path = bib_path }
            pending = pending - 1
            check_done()
        end)
    end
end

local M = {}

--- Initialize cmp module: register as a completion source
M.init = function()
    cmp.register_source('mkdnflow', source.new())
end

return M
