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

-- Default config table (where defaults and user-provided config will be combined)
local default_config = {
    create_dirs = true,
    silent = false,
    wrap = false,
    on_attach = false,
    modules = {
        bib = true,
        buffers = true,
        conceal = true,
        cursor = true,
        folds = true,
        foldtext = true,
        links = true,
        lists = true,
        maps = true,
        paths = true,
        tables = true,
        templates = true,
        to_do = true,
        yaml = false,
        completion = false,
        notebook = true,
        backlinks = true,
    },
    path_resolution = {
        primary = 'first',
        fallback = 'current',
        root_marker = false,
        sync_cwd = false,
        update_on_navigate = true,
    },
    filetypes = {
        markdown = true, -- Covers .md, .markdown, .mkd, .mkdn, .mdwn, .mdown
        rmd = true, -- Covers .rmd
    },
    foldtext = {
        object_count = true,
        object_count_icon_set = 'emoji',
        object_count_opts = function()
            return require('mkdnflow').foldtext.default_count_opts()
        end,
        line_count = true,
        line_percentage = true,
        word_count = false,
        title_transformer = function()
            return require('mkdnflow').foldtext.default_title_transformer
        end,
        fill_chars = {
            left_edge = '⢾⣿⣿',
            right_edge = '⣿⣿⡷',
            item_separator = ' · ',
            section_separator = ' ⣹⣿⣏ ',
            left_inside = ' ⣹',
            right_inside = '⣏ ',
            middle = '⣿',
        },
    },
    bib = {
        default_path = nil,
        find_in_root = true,
    },
    cursor = {
        jump_patterns = nil,
        yank_register = '"',
    },
    links = {
        style = 'markdown',
        compact = false,
        conceal = false,
        ref_hint = false,
        search_range = 0,
        implicit_extension = nil,
        transform_on_follow = false,
        transform_on_create = function(text)
            text = text:gsub('[ /]', '-')
            text = text:lower()
            text = os.date('%Y-%m-%d_') .. text
            return text
        end,
        transform_scope = 'path',
        auto_create = true,
        on_create_new = false,
        edit_dirs = false,
        uri_handlers = {},
    },
    footnotes = {
        heading = '## Footnotes',
    },
    new_file_template = {
        enabled = false,
        placeholders = {
            title = 'link_title',
            date = 'os_date',
        },
        template = '# {{title}}',
    },
    to_do = {
        create_on_toggle = true,
        highlight = false,
        statuses = {
            not_started = {
                marker = ' ',
                highlight = {
                    marker = { link = 'Conceal' },
                    content = { link = 'Conceal' },
                },
                sort = { section = 2, position = 'top' },
                propagate = {
                    up = function(host_list)
                        local no_items_started = true
                        for _, item in ipairs(host_list.items) do
                            if item.status.name ~= 'not_started' then
                                no_items_started = false
                            end
                        end
                        if no_items_started then
                            return 'not_started'
                        else
                            return 'in_progress'
                        end
                    end,
                    down = function(child_list)
                        local target_statuses = {}
                        for _ = 1, #child_list.items, 1 do
                            table.insert(target_statuses, 'not_started')
                        end
                        return target_statuses
                    end,
                },
            },
            in_progress = {
                marker = '-',
                highlight = {
                    marker = { link = 'WarningMsg' },
                    content = { bold = true },
                },
                sort = { section = 1, position = 'bottom' },
                propagate = {
                    up = function(host_list)
                        return 'in_progress'
                    end,
                    down = function(child_list) end,
                },
            },
            complete = {
                marker = { 'X', 'x' },
                highlight = {
                    marker = { link = 'String' },
                    content = { link = 'Conceal' },
                },
                sort = { section = 3, position = 'top' },
                propagate = {
                    up = function(host_list)
                        local all_items_complete = true
                        for _, item in ipairs(host_list.items) do
                            if item.status.name ~= 'complete' then
                                all_items_complete = false
                            end
                        end
                        if all_items_complete then
                            return 'complete'
                        else
                            return 'in_progress'
                        end
                    end,
                    down = function(child_list)
                        local target_statuses = {}
                        for _ = 1, #child_list.items, 1 do
                            table.insert(target_statuses, 'complete')
                        end
                        return target_statuses
                    end,
                },
            },
        },
        status_order = { 'not_started', 'in_progress', 'complete' },
        status_propagation = {
            up = true,
            down = true,
        },
        sort = {
            on_status_change = false,
            recursive = false,
            cursor_behavior = {
                track = true,
            },
        },
    },
    tables = {
        type = 'pipe',
        trim_whitespace = true,
        format_on_move = true,
        auto_extend_rows = false,
        auto_extend_cols = false,
        style = {
            cell_padding = 1,
            separator_padding = 1,
            outer_pipes = true,
            apply_alignment = true,
        },
    },
    backlinks = {
        auto_refresh = true,
    },
    panels = {
        position = 'right',
        width = 40,
        height = 15,
        close_maps = { 'q' },
        focus = true,
        float = {
            border = 'rounded',
            width = 0.6,
            height = 0.7,
        },
    },
    yaml = {
        bib = { override = false },
    },
    mappings = {
        MkdnEnter = { { 'n', 'v' }, '<CR>' },
        MkdnGoBack = { 'n', '<BS>' },
        MkdnGoForward = { 'n', '<Del>' },
        MkdnMoveSource = { 'n', '<F2>' },
        MkdnDeadLinks = false,
        MkdnNextLink = { 'n', '<Tab>' },
        MkdnPrevLink = { 'n', '<S-Tab>' },
        MkdnFollowLink = false,
        MkdnDestroyLink = { 'n', '<M-CR>' },
        MkdnTagSpan = { 'v', '<M-CR>' },
        MkdnYankAnchorLink = { 'n', 'yaa' },
        MkdnYankFileAnchorLink = { 'n', 'yfa' },
        MkdnNextHeading = { 'n', ']]' },
        MkdnPrevHeading = { 'n', '[[' },
        MkdnIncreaseHeading = { { 'n', 'v' }, '+' },
        MkdnDecreaseHeading = { { 'n', 'v' }, '-' },
        MkdnIncreaseHeadingOp = { { 'n', 'v' }, 'g+' },
        MkdnDecreaseHeadingOp = { { 'n', 'v' }, 'g-' },
        MkdnToggleToDo = { { 'n', 'v' }, '<C-Space>' },
        MkdnNewListItem = false,
        MkdnNewListItemBelowInsert = { 'n', 'o' },
        MkdnNewListItemAboveInsert = { 'n', 'O' },
        MkdnExtendList = false,
        MkdnUpdateNumbering = { 'n', '<leader>nn' },
        MkdnChangeListType = false,
        MkdnTableNextCell = { 'i', '<Tab>' },
        MkdnTablePrevCell = { 'i', '<S-Tab>' },
        MkdnTableCellNewLine = { 'i', '<S-CR>' },
        MkdnTableNextRow = false,
        MkdnTablePrevRow = { 'i', '<M-CR>' },
        MkdnTableNewRowBelow = { 'n', '<leader>ir' },
        MkdnTableNewRowAbove = { 'n', '<leader>iR' },
        MkdnTableNewColAfter = { 'n', '<leader>ic' },
        MkdnTableNewColBefore = { 'n', '<leader>iC' },
        MkdnTableDeleteRow = { 'n', '<leader>dr' },
        MkdnTableDeleteCol = { 'n', '<leader>dc' },
        MkdnTableAlignLeft = { 'n', '<leader>al' },
        MkdnTableAlignRight = { 'n', '<leader>ar' },
        MkdnTableAlignCenter = { 'n', '<leader>ac' },
        MkdnTableAlignDefault = { 'n', '<leader>ax' },
        MkdnTablePaste = false,
        MkdnTableFromSelection = false,
        MkdnFoldSection = { 'n', '<leader>f' },
        MkdnUnfoldSection = { 'n', '<leader>F' },
        MkdnTab = false,
        MkdnSTab = false,
        MkdnIndentListItem = { 'i', '<C-t>' },
        MkdnDedentListItem = { 'i', '<C-d>' },
        MkdnCreateLink = false,
        MkdnCreateLinkFromClipboard = { { 'n', 'v' }, '<leader>p' },
        MkdnCreateFootnote = false,
        MkdnRenumberFootnotes = false,
        MkdnRefreshFootnotes = false,
        MkdnBacklinks = false,
        MkdnBacklinksRefresh = false,
    },
}

-- Known Neovim filetypes (explicit list to avoid fragile heuristics)
local known_filetypes = {
    markdown = true,
    rmd = true,
}

-- Extensions that map to known filetypes
local extension_to_filetype = {
    md = 'markdown',
    markdown = 'markdown',
    mkd = 'markdown',
    mkdn = 'markdown',
    mdwn = 'markdown',
    mdown = 'markdown',
    rmd = 'rmd',
}

--- Process the filetypes config and return a list of filetype patterns for autocmds
--- Also registers unknown extensions via vim.filetype.add()
---@param filetypes_config table<string, boolean|string> Map of filetype/extension to enabled flag or filetype name
---@return string[] patterns Array of filetype strings for use in autocmd patterns
---@private
local function resolve_filetypes(filetypes_config)
    local patterns = {} -- Set of filetypes to enable
    local disabled = {} -- Set of filetypes explicitly disabled

    -- First pass: collect disabled filetypes (false takes precedence)
    for key, value in pairs(filetypes_config) do
        if value == false then
            local ft = extension_to_filetype[key] or key
            disabled[ft] = true
        end
    end

    -- Second pass: process enabled filetypes
    for key, value in pairs(filetypes_config) do
        if value == false then
            -- Skip (handled above)
        elseif known_filetypes[key] then
            -- Direct filetype name (e.g., 'markdown')
            if not disabled[key] then
                patterns[key] = true
            end
        elseif extension_to_filetype[key] then
            -- Known extension (e.g., 'md' -> 'markdown')
            local ft = extension_to_filetype[key]
            if not disabled[ft] then
                patterns[ft] = true
            end
        elseif type(value) == 'string' then
            -- Unknown extension, register as specified filetype
            vim.filetype.add({ extension = { [key] = value } })
            if not disabled[value] then
                patterns[value] = true
            end
        else
            -- Unknown extension (value = true), register as its own filetype
            vim.filetype.add({ extension = { [key] = key } })
            if not disabled[key] then
                patterns[key] = true
            end
        end
    end

    -- Convert to array for autocmd pattern
    local result = {}
    for ft, _ in pairs(patterns) do
        table.insert(result, ft)
    end
    return result
end

local init = {} -- Init functions & variables
init.utils = require('mkdnflow.utils')
init.user_config = {} -- For user config
init.config = {} -- For merged configs
init.loaded = nil -- For load status

--- Load a module and call its init() if present
---@param name string Module name under mkdnflow/
---@param enabled boolean|nil Whether the module is enabled
---@return table|false mod The loaded module table, or false if disabled
---@private
local function load_module(name, enabled)
    if not enabled then
        return false
    end
    local mod = require('mkdnflow.' .. name)
    if type(mod) == 'table' and type(mod.init) == 'function' then
        mod.init()
    end
    return mod
end

--- Pure configuration: merge user config with defaults, resolve filetypes, compute jump_patterns.
--- No side effects beyond the idempotent vim.filetype.add() for unknown extensions.
---@param user_config table The (post-compat) user configuration
---@private
local function configure(user_config)
    -- Detect OS, nvim version, initial buffer/dir
    init.this_os = vim.loop.os_uname().sysname
    init.nvim_version = vim.fn.api_info().version.minor
    init.initial_buf = vim.api.nvim_buf_get_name(0)
    init.initial_dir = (init.this_os:match('Windows') ~= nil and init.initial_buf:match('(.*)\\.-'))
        or init.initial_buf:match('(.*)/.-')

    -- Deep-copy the raw user config before compat mutates it (for :checkhealth)
    init.raw_user_config = vim.deepcopy(user_config)

    -- Read compatibility module & pass user config through config checker
    local compat = require('mkdnflow.compat')
    user_config = compat.userConfigCheck(user_config)

    -- Store a clean, independent copy of the user config (post-compat) for
    -- health checks (:checkhealth, :MkdnCleanConfig) and potential re-setup
    -- via forceStart(). This must be a deep copy because mergeTables assigns
    -- array references directly into the merged config, and modules may later
    -- mutate those shared objects (e.g. to_do adds method functions onto the
    -- statuses array). Without a copy, init.user_config would be polluted.
    if next(user_config) then
        init.user_config = vim.deepcopy(user_config)
    end

    -- Deep-copy defaults before mergeTables mutates them (for :checkhealth / :MkdnCleanConfig)
    init.default_config = vim.deepcopy(default_config)

    -- Validate post-compat user config against defaults and schema
    local validate = require('mkdnflow.validate')
    local diagnostics = validate.validate(user_config, init.default_config)
    validate.checkConflicts(init.raw_user_config, diagnostics)
    init.validation_diagnostics = diagnostics

    if not user_config.silent then
        for _, diag in ipairs(diagnostics) do
            vim.notify(
                string.format("⬇️  '%s': %s", diag.path, diag.message),
                vim.log.levels.WARN
            )
        end
    end

    -- Merge user config with defaults
    init.config = init.utils.mergeTables(default_config, user_config)

    -- Normalize to_do.statuses: convert dict + status_order → ordered array
    -- Internal code (core.lua, hl.lua) expects an array with .name and .skip_on_toggle
    -- Only normalize if statuses is a dict (string keys). If it's already an array
    -- (from a previous setup() call in the same process), skip normalization.
    local td = init.config.to_do
    local first_status_key = td and type(td.statuses) == 'table' and next(td.statuses)
    if td and type(first_status_key) == 'string' then
        local statuses_dict = td.statuses
        local status_order = td.status_order or {}

        -- Build set of ordered names for O(1) membership check
        local ordered_set = {}
        for _, name in ipairs(status_order) do
            ordered_set[name] = true
        end

        -- Fallback: if status_order is empty, use all names in sorted order
        if #status_order == 0 then
            for name, _ in pairs(statuses_dict) do
                table.insert(status_order, name)
            end
            table.sort(status_order)
            for _, name in ipairs(status_order) do
                ordered_set[name] = true
            end
        end

        local statuses_array = {}

        -- Statuses in status_order (participate in toggle rotation)
        for _, name in ipairs(status_order) do
            if statuses_dict[name] then
                local status = vim.deepcopy(statuses_dict[name])
                status.name = name
                status.skip_on_toggle = false
                table.insert(statuses_array, status)
            elseif not init.config.silent then
                vim.notify(
                    string.format(
                        "⬇️  status_order entry '%s' not found in to_do.statuses",
                        name
                    ),
                    vim.log.levels.WARN
                )
            end
        end

        -- Remaining statuses NOT in status_order (recognized but excluded from rotation)
        for name, _ in pairs(statuses_dict) do
            if not ordered_set[name] then
                local status = vim.deepcopy(statuses_dict[name])
                status.name = name
                status.skip_on_toggle = true
                table.insert(statuses_array, status)
            end
        end

        td.statuses = statuses_array
    end

    -- Normalize footnotes.heading into a heading_lines array so that both
    -- single-line (ATX) and multi-line (setext) headings use one code path.
    local fh = init.config.footnotes and init.config.footnotes.heading
    if type(fh) == 'string' then
        init.config.footnotes.heading_lines = { fh }
    elseif type(fh) == 'table' then
        init.config.footnotes.heading_lines = fh
    end
    -- When heading is false/nil, heading_lines stays nil

    -- Resolve filetypes (registers unknown extensions via vim.filetype.add)
    local filetype_patterns = resolve_filetypes(init.config.filetypes)
    init.config.resolved_filetypes = filetype_patterns

    -- Build set of file extensions considered notebook-internal (for pathType)
    local notebook_extensions = {}
    local disabled_ft = {}
    for key, value in pairs(init.config.filetypes) do
        if value == false then
            disabled_ft[extension_to_filetype[key] or key] = true
        end
    end
    for ext, ft in pairs(extension_to_filetype) do
        if not disabled_ft[ft] then
            notebook_extensions[ext] = true
        end
    end
    for key, value in pairs(init.config.filetypes) do
        if value ~= false and not known_filetypes[key] and not extension_to_filetype[key] then
            notebook_extensions[key] = true
        end
    end
    init.config.notebook_extensions = notebook_extensions

    -- jump_patterns: nil means "no extras" (detection-based jumping handles all link types).
    -- If a user sets jump_patterns, those patterns are added on top of detection results.
end

--- Load all enabled modules and set up path resolution/root directory
--- Called by both setup() and forceStart().
---@private
local function activate()
    if init.loaded then
        return
    end

    -- If initial_dir is nil (e.g., setup() ran with an unnamed buffer, as when
    -- lazy.nvim loads the plugin via a key mapping), derive it from the current
    -- buffer or fall back to cwd.
    if not init.initial_dir then
        init.initial_buf = vim.api.nvim_buf_get_name(0)
        init.initial_dir = (init.this_os:match('Windows') and init.initial_buf:match('(.*)\\.-'))
            or init.initial_buf:match('(.*)/.-')
            or vim.fn.getcwd()
    end

    -- Get silence preference
    local silent = init.config.silent
    -- Determine path resolution
    local path_resolution = init.config.path_resolution
    if path_resolution.primary == 'root' then
        -- Retrieve the root marker
        local root_marker = path_resolution.root_marker
        -- If one was provided, try to find the root directory for the notebook/wiki using the marker
        if root_marker then
            init.root_dir = init.utils.getRootDir(init.initial_dir, root_marker, init.this_os)
            -- Get notebook name
            if init.root_dir then
                vim.api.nvim_set_current_dir(init.root_dir)
                local name = init.root_dir:match('.*/(.*)') or init.root_dir
                if not silent then
                    vim.notify('⬇️  Notebook: ' .. name, vim.log.levels.INFO)
                end
            else
                local fallback = init.config.path_resolution.fallback
                if not silent then
                    vim.notify(
                        '⬇️  No notebook found. Fallback perspective: ' .. fallback,
                        vim.log.levels.WARN
                    )
                end
                -- Set working directory according to current perspective
                if fallback == 'first' then
                    vim.api.nvim_set_current_dir(init.initial_dir)
                else
                    local bufname = vim.api.nvim_buf_get_name(0)
                    local dir = init.this_os:match('Windows') and bufname:match('(.*)\\.-$')
                        or bufname:match('(.*)/.-$')
                    if dir then
                        vim.api.nvim_set_current_dir(dir)
                    end
                end
            end
        else
            if not silent then
                vim.notify(
                    "⬇️  No root marker was provided for the notebook's root directory. See :h mkdnflow-configuration.",
                    vim.log.levels.WARN
                )
            end
            if init.config.path_resolution.fallback == 'first' then
                vim.api.nvim_set_current_dir(init.initial_dir)
            else
                -- Set working directory
                local bufname = vim.api.nvim_buf_get_name(0)
                local dir = init.this_os:match('Windows') and bufname:match('(.*)\\.-$')
                    or bufname:match('(.*)/.-$')
                if dir then
                    vim.api.nvim_set_current_dir(dir)
                end
            end
        end
    end
    -- Load modules
    -- Core modules are always loaded because they have hard cross-dependencies
    -- (e.g. paths calls into links, buffers, and cursor). Setting their modules
    -- key to false still suppresses their keybindings via command_deps in maps.
    init.buffers = load_module('buffers', true)
    init.links = load_module('links', true)
    init.cursor = load_module('cursor', true)
    init.paths = load_module('paths', true)
    -- Optional modules respect the user's modules config
    init.conceal = load_module('conceal', init.config.links.conceal)
    init.ref_hint = load_module('links.hints', init.config.links.ref_hint)
    init.bib = load_module('bib', init.config.modules.bib)
    init.folds = load_module('folds', init.config.modules.folds)
    init.foldtext = load_module('foldtext', init.config.modules.foldtext)
    init.lists = load_module('lists', init.config.modules.lists)
    init.maps = load_module('maps', init.config.modules.maps)
    init.tables = load_module('tables', init.config.modules.tables)
    init.templates = load_module('templates', init.config.modules.templates)
    init.yaml = load_module('yaml', init.config.modules.yaml)
    init.completion = load_module('completion', init.config.modules.completion)
    init.notebook = load_module('notebook', init.config.modules.notebook)
    init.backlinks = load_module('backlinks', init.config.modules.backlinks)
    init.to_do = load_module('to_do', init.config.modules.to_do)
    -- Set up on_attach autocmd (fires per buffer, independent of maps module)
    local on_attach = init.config.on_attach
    if type(on_attach) == 'function' then
        local on_attach_patterns = init.config.resolved_filetypes
        if #on_attach_patterns > 0 then
            vim.api.nvim_create_augroup('MkdnflowOnAttach', { clear = true })
            vim.api.nvim_create_autocmd('FileType', {
                group = 'MkdnflowOnAttach',
                pattern = on_attach_patterns,
                callback = function(args)
                    on_attach(args.buf)
                end,
            })
        end
    end
    -- Record load status
    init.loaded = true
    -- Re-trigger FileType so module autocmds (maps, conceal, foldtext, yaml) fire
    vim.cmd('doautocmd FileType')
end

init.command_deps = {
    MkdnGoBack = { 'buffers' },
    MkdnGoForward = { 'buffers' },
    MkdnMoveSource = { 'paths', 'links' },
    MkdnDeadLinks = { 'paths', 'links' },
    MkdnBacklinks = { 'backlinks', 'paths', 'notebook' },
    MkdnBacklinksRefresh = { 'backlinks', 'paths', 'notebook' },
    MkdnNextLink = { 'links', 'cursor' },
    MkdnPrevLink = { 'links', 'cursor' },
    MkdnCreateLink = { 'links' },
    MkdnCreateLinkFromClipboard = { 'links' },
    MkdnCreateFootnote = { 'links' },
    MkdnRenumberFootnotes = { 'links' },
    MkdnRefreshFootnotes = { 'links' },
    MkdnTagSpan = { 'links' },
    MkdnFollowLink = { 'links', 'paths' },
    MkdnDestroyLink = { 'links' },
    MkdnYankAnchorLink = { 'cursor' },
    MkdnYankFileAnchorLink = { 'cursor' },
    MkdnNextHeading = { 'cursor' },
    MkdnPrevHeading = { 'cursor' },
    MkdnIncreaseHeading = { 'cursor' },
    MkdnDecreaseHeading = { 'cursor' },
    MkdnIncreaseHeadingOp = { 'cursor' },
    MkdnDecreaseHeadingOp = { 'cursor' },
    MkdnToggleToDo = { 'lists' },
    MkdnSortToDoList = { 'to_do' },
    MkdnNewListItem = { 'lists' },
    MkdnNewListItemAboveInsert = { 'lists' },
    MkdnNewListItemBelowInsert = { 'lists' },
    MkdnExtendList = { 'lists' },
    MkdnUpdateNumbering = { 'lists' },
    MkdnChangeListType = { 'lists' },
    MkdnTable = { 'tables' },
    MkdnTableFormat = { 'tables' },
    MkdnTableNextCell = { 'tables' },
    MkdnTablePrevCell = { 'tables' },
    MkdnTableNextRow = { 'tables' },
    MkdnTablePrevRow = { 'tables' },
    MkdnTableNewRowBelow = { 'tables' },
    MkdnTableNewRowAbove = { 'tables' },
    MkdnTableNewColAfter = { 'tables' },
    MkdnTableNewColBefore = { 'tables' },
    MkdnTableDeleteRow = { 'tables' },
    MkdnTableDeleteCol = { 'tables' },
    MkdnTableCellNewLine = { 'tables' },
    MkdnTableAlignLeft = { 'tables' },
    MkdnTableAlignRight = { 'tables' },
    MkdnTableAlignCenter = { 'tables' },
    MkdnTableAlignDefault = { 'tables' },
    MkdnTablePaste = { 'tables' },
    MkdnTableFromSelection = { 'tables' },
    MkdnFoldSection = { 'folds' },
    MkdnUnfoldSection = { 'folds' },
    -- The following three depend on multiple modules; they will be defined but will
    -- self-limit their functionality depending on the available modules
    MkdnEnter = {},
    MkdnTab = {},
    MkdnSTab = {},
    MkdnIndentListItem = { 'lists' },
    MkdnDedentListItem = { 'lists' },
}

--- Initialize Mkdnflow with the given user configuration
---@param user_config? table User configuration overrides (merged with defaults)
init.setup = function(user_config)
    user_config = user_config or {}

    -- Allow re-initialization when setup() is called again (e.g. hot-reload)
    init.loaded = nil

    -- Pure configuration: merge, resolve filetypes, compute jump_patterns
    configure(user_config)

    local filetype_patterns = init.config.resolved_filetypes

    -- Re-detect current buffer's filetype if it was opened before registration
    local current_file = vim.api.nvim_buf_get_name(0)
    if current_file ~= '' then
        local detected = vim.filetype.match({ filename = current_file })
        if
            detected
            and vim.tbl_contains(filetype_patterns, detected)
            and vim.bo.filetype ~= detected
        then
            vim.bo.filetype = detected -- This triggers FileType autocmd
        end
    end

    -- Register activation augroup (clear ensures repeated setup() calls are safe)
    vim.api.nvim_create_augroup('MkdnflowActivation', { clear = true })

    -- Only create FileType autocmd if there are filetypes to watch
    if #filetype_patterns > 0 then
        vim.api.nvim_create_autocmd('FileType', {
            group = 'MkdnflowActivation',
            pattern = filetype_patterns,
            callback = function()
                activate()
            end,
        })
    end

    -- If current buffer already matches, activate immediately
    local ft = vim.bo.filetype
    if vim.tbl_contains(filetype_patterns, ft) then
        activate()
    end
end

--- Get current notebook info (for statusline components, etc.)
---@return {name: string, root: string}|nil info The notebook name and root path, or nil if no root
init.getNotebook = function()
    if not init.root_dir then
        return nil
    end
    local name = init.root_dir:match('.*/(.*)') or init.root_dir
    return { name = name, root = init.root_dir }
end

--- Force-start Mkdnflow regardless of current buffer filetype
---@param opts table Options list; opts[1] can be 'silent' to suppress messages
init.forceStart = function(opts)
    local silent = (opts[1] == 'silent') or (init.config and init.config.silent)
    if init.loaded then
        if not silent then
            vim.notify('⬇️  Mkdnflow is already running!', vim.log.levels.ERROR)
        end
    else
        -- If setup() was never called, call it first
        if not init.config.resolved_filetypes then
            init.setup(init.user_config or {})
        end
        -- If still not loaded (e.g. non-matching buffer), force activate
        if not init.loaded then
            activate()
        end
        if not silent then
            vim.notify('⬇️  Mkdnflow started!', vim.log.levels.WARN)
        end
    end
end

return init
