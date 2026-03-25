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

-- Only define these commands if the plugin hasn't already been loaded
if vim.fn.exists('g:loaded_mkdnflow') == 0 then
    -- Save user coptions
    local save_cpo = vim.o.cpoptions
    -- Retrieve defaults
    local cpo_defaults = vim.api.nvim_get_option_info('cpoptions')['default']
    -- Set to defaults
    vim.o.cpoptions = cpo_defaults
    local user_command = vim.api.nvim_create_user_command
    local mkdnflow = require('mkdnflow')

    -- Helper to check if mkdnflow is initialized before running a command
    local function require_module(module_name)
        local module = mkdnflow[module_name]
        if not module then
            vim.notify(
                "⬇️  Mkdnflow not initialized. Call require('mkdnflow').setup() first, or check that the "
                    .. module_name
                    .. ' module is enabled.',
                vim.log.levels.WARN
            )
            return nil
        end
        return module
    end

    --- Resolve an abbreviated link style argument to its full name
    ---@param arg string User input (e.g., 'm', 'wiki', 'markdown')
    ---@return string|nil style The resolved style, or nil if no match
    local function resolve_style(arg)
        arg = arg:lower()
        if ('markdown'):sub(1, #arg) == arg then
            return 'markdown'
        elseif ('wiki'):sub(1, #arg) == arg then
            return 'wiki'
        end
        return nil
    end

    --- Resolve an abbreviated transform scope argument to its full name
    ---@param arg string User input (e.g., 'p', 'path', 'f', 'filename')
    ---@return string|nil scope The resolved scope, or nil if no match
    local function resolve_scope(arg)
        arg = arg:lower()
        if ('path'):sub(1, #arg) == arg then
            return 'path'
        elseif ('filename'):sub(1, #arg) == arg then
            return 'filename'
        end
        return nil
    end

    --- Parse link command arguments, resolving style and transform_scope in any order
    ---@param fargs string[] Raw command arguments
    ---@return table|nil args Table with style and transform_scope keys, or nil on error
    local function resolve_link_args(fargs)
        local style, transform_scope
        for _, arg in ipairs(fargs) do
            local s = resolve_style(arg)
            if s then
                style = s
            else
                local sc = resolve_scope(arg)
                if sc then
                    transform_scope = sc
                else
                    vim.notify(
                        "⬇️  Invalid argument: '"
                            .. arg
                            .. "'. Expected a style ('markdown', 'wiki')"
                            .. " or scope ('path', 'filename').",
                        vim.log.levels.WARN
                    )
                    return nil
                end
            end
        end
        return { style = style, transform_scope = transform_scope }
    end

    local link_complete = function()
        return { 'markdown', 'wiki', 'path', 'filename' }
    end

    user_command('Mkdnflow', function(opts)
        require('mkdnflow.dispatch').dispatch(opts)
    end, {
        nargs = '*',
        range = true,
        complete = function(arg_lead, cmd_line, cursor_pos)
            return require('mkdnflow.dispatch').complete(arg_lead, cmd_line, cursor_pos)
        end,
    })
    user_command('MkdnEnter', function(opts)
        if opts.range > 0 then
            require('mkdnflow.wrappers').multiFuncEnter({ range = true })
        else
            require('mkdnflow.wrappers').multiFuncEnter()
        end
    end, { range = true })
    user_command('MkdnTab', function(opts)
        require('mkdnflow.wrappers').indentListItemOrJumpTableCell(1)
    end, {})
    user_command('MkdnSTab', function(opts)
        require('mkdnflow.wrappers').indentListItemOrJumpTableCell(-1)
    end, {})
    user_command('MkdnIndentListItem', function(opts)
        require('mkdnflow.wrappers').indentListItem(1)
    end, {})
    user_command('MkdnDedentListItem', function(opts)
        require('mkdnflow.wrappers').indentListItem(-1)
    end, {})
    user_command('MkdnGoBack', function(opts)
        local buffers = require_module('buffers')
        if buffers then
            buffers.goBack()
        end
    end, {})
    user_command('MkdnGoForward', function(opts)
        local buffers = require_module('buffers')
        if buffers then
            buffers.goForward()
        end
    end, {})
    user_command('MkdnMoveSource', function(opts)
        local paths = require_module('paths')
        if paths then
            paths.moveSource()
        end
    end, {})
    user_command('MkdnDeadLinks', function(opts)
        local paths = require_module('paths')
        if paths then
            paths.deadLinks(opts.fargs[1])
        end
    end, { nargs = '?' })
    user_command('MkdnNextLink', function(opts)
        local cursor = require_module('cursor')
        if cursor then
            cursor.toNextLink()
        end
    end, {})
    user_command('MkdnPrevLink', function(opts)
        local cursor = require_module('cursor')
        if cursor then
            cursor.toPrevLink()
        end
    end, {})
    user_command('MkdnFollowLink', function(opts)
        local links = require_module('links')
        if links then
            links.followLink()
        end
    end, {})
    user_command('MkdnCreateLink', function(opts)
        local links = require_module('links')
        if not links then
            return
        end
        local link_args = resolve_link_args(opts.fargs)
        if not link_args then
            return
        end
        if opts.range > 0 then
            link_args.range = true
        end
        links.createLink(link_args)
    end, { range = true, nargs = '*', complete = link_complete })
    user_command('MkdnCreateLinkFromClipboard', function(opts)
        local links = require_module('links')
        if not links then
            return
        end
        local link_args = resolve_link_args(opts.fargs)
        if not link_args then
            return
        end
        link_args.from_clipboard = true
        if opts.range > 0 then
            link_args.range = true
        end
        links.createLink(link_args)
    end, { range = true, nargs = '*', complete = link_complete })
    user_command('MkdnCreateFootnote', function(opts)
        local links = require_module('links')
        if not links then
            return
        end
        links.createFootnote({ label = opts.fargs[1] })
    end, { nargs = '?' })
    user_command('MkdnRenumberFootnotes', function(opts)
        local links = require_module('links')
        if not links then
            return
        end
        links.renumberFootnotes()
    end, {})
    user_command('MkdnRefreshFootnotes', function(opts)
        local links = require_module('links')
        if not links then
            return
        end
        links.refreshFootnotes()
    end, {})
    user_command('MkdnDestroyLink', function(opts)
        local links = require_module('links')
        if links then
            links.destroyLink()
        end
    end, {})
    user_command('MkdnTagSpan', function(opts)
        local links = require_module('links')
        if links then
            links.tagSpan()
        end
    end, {})
    user_command('MkdnYankAnchorLink', function(opts)
        local cursor = require_module('cursor')
        if cursor then
            cursor.yankAsAnchorLink()
        end
    end, {})
    user_command('MkdnYankFileAnchorLink', function(opts)
        local cursor = require_module('cursor')
        if cursor then
            cursor.yankAsAnchorLink({})
        end
    end, {})
    user_command('MkdnNextHeading', function(opts)
        local cursor = require_module('cursor')
        if cursor then
            cursor.toHeading(nil)
        end
    end, {})
    user_command('MkdnPrevHeading', function(opts)
        local cursor = require_module('cursor')
        if cursor then
            cursor.toHeading(nil, {})
        end
    end, {})
    user_command('MkdnNextHeadingSame', function(opts)
        mkdnflow.cursor.goToSame(false)
    end, {})
    user_command('MkdnPrevHeadingSame', function(opts)
        mkdnflow.cursor.goToSame(true)
    end, {})
    user_command('MkdnIncreaseHeading', function(opts)
        local cursor = require_module('cursor')
        if cursor then
            if opts.range > 0 then
                cursor.changeHeadingLevel('increase', { line1 = opts.line1, line2 = opts.line2 })
            else
                cursor.changeHeadingLevel('increase')
            end
        end
    end, { range = true })
    user_command('MkdnDecreaseHeading', function(opts)
        local cursor = require_module('cursor')
        if cursor then
            if opts.range > 0 then
                cursor.changeHeadingLevel('decrease', { line1 = opts.line1, line2 = opts.line2 })
            else
                cursor.changeHeadingLevel('decrease')
            end
        end
    end, { range = true })
    user_command('MkdnToggleToDo', function(opts)
        local to_do = require_module('to_do')
        if to_do then
            if opts.range > 0 then
                to_do.toggle_to_do({ line1 = opts.line1, line2 = opts.line2 })
            else
                to_do.toggle_to_do()
            end
        end
    end, { range = true })
    user_command('MkdnSortToDoList', function(opts)
        local to_do = require_module('to_do')
        if to_do then
            to_do.sort_to_do_list()
        end
    end, {})
    user_command('MkdnNewListItem', function(opts)
        local lists = require_module('lists')
        if lists then
            lists.newListItem(true, false, true, 'i', '<CR>')
        end
    end, {})
    user_command('MkdnNewListItemBelowInsert', function(opts)
        local lists = require_module('lists')
        if lists then
            lists.newListItem(false, false, true, 'i', 'o')
        end
    end, {})
    user_command('MkdnNewListItemAboveInsert', function(opts)
        local lists = require_module('lists')
        if lists then
            lists.newListItem(false, true, true, 'i', 'O')
        end
    end, {})
    user_command('MkdnExtendList', function(opts)
        local lists = require_module('lists')
        if lists then
            lists.newListItem(false, 'n')
        end
    end, {})
    user_command('MkdnUpdateNumbering', function(opts)
        local lists = require_module('lists')
        if lists then
            lists.updateNumbering(opts.fargs)
        end
    end, { nargs = '*' })
    user_command('MkdnChangeListType', function(opts)
        local lists = require_module('lists')
        if lists then
            local target = opts.fargs[1]
            local marker = opts.fargs[2]
            if opts.range > 0 then
                lists.changeListType(
                    target,
                    { line1 = opts.line1, line2 = opts.line2, marker = marker }
                )
            else
                lists.changeListType(target, { marker = marker })
            end
        end
    end, {
        range = true,
        nargs = '+',
        complete = function()
            return { 'ul', 'ol', 'ultd', 'oltd' }
        end,
    })
    user_command('MkdnTable', function(opts)
        local tables = require_module('tables')
        if tables then
            tables.newTable(opts.fargs)
        end
    end, { nargs = '*' })
    user_command('MkdnTableFormat', function(opts)
        local tables = require_module('tables')
        if tables then
            tables.formatTable()
        end
    end, {})
    user_command('MkdnTableNextCell', function(opts)
        local tables = require_module('tables')
        if tables then
            tables.moveToCell(0, 1)
        end
    end, {})
    user_command('MkdnTablePrevCell', function(opts)
        local tables = require_module('tables')
        if tables then
            tables.moveToCell(0, -1)
        end
    end, {})
    user_command('MkdnTableNextRow', function(opts)
        local tables = require_module('tables')
        if tables then
            tables.moveToCell(1, 0)
        end
    end, {})
    user_command('MkdnTablePrevRow', function(opts)
        local tables = require_module('tables')
        if tables then
            tables.moveToCell(-1, 0)
        end
    end, {})
    user_command('MkdnTableNewRowBelow', function(opts)
        local tables = require_module('tables')
        if tables then
            tables.addRow()
        end
    end, {})
    user_command('MkdnTableNewRowAbove', function(opts)
        local tables = require_module('tables')
        if tables then
            tables.addRow(-1)
        end
    end, {})
    user_command('MkdnTableNewColAfter', function(opts)
        local tables = require_module('tables')
        if tables then
            tables.addCol()
        end
    end, {})
    user_command('MkdnTableNewColBefore', function(opts)
        local tables = require_module('tables')
        if tables then
            tables.addCol(-1)
        end
    end, {})
    user_command('MkdnTableDeleteRow', function(opts)
        local tables = require_module('tables')
        if tables then
            tables.deleteRow()
        end
    end, {})
    user_command('MkdnTableDeleteCol', function(opts)
        local tables = require_module('tables')
        if tables then
            tables.deleteCol()
        end
    end, {})
    user_command('MkdnTableCellNewLine', function(opts)
        local tables = require_module('tables')
        if tables then
            tables.cellNewLine()
        end
    end, {})
    user_command('MkdnTableAlignLeft', function(opts)
        local tables = require_module('tables')
        if tables then
            tables.alignCol('left')
        end
    end, {})
    user_command('MkdnTableAlignRight', function(opts)
        local tables = require_module('tables')
        if tables then
            tables.alignCol('right')
        end
    end, {})
    user_command('MkdnTableAlignCenter', function(opts)
        local tables = require_module('tables')
        if tables then
            tables.alignCol('center')
        end
    end, {})
    user_command('MkdnTableAlignDefault', function(opts)
        local tables = require_module('tables')
        if tables then
            tables.alignCol('default')
        end
    end, {})
    user_command('MkdnTablePaste', function(opts)
        local tables = require_module('tables')
        if tables then
            local header = true
            local delimiter = nil
            for _, arg in ipairs(opts.fargs) do
                if arg:match('noh') then
                    header = false
                else
                    delimiter = arg
                end
            end
            tables.pasteTable({ delimiter = delimiter, header = header })
        end
    end, { nargs = '*' })
    user_command('MkdnTableFromSelection', function(opts)
        local tables = require_module('tables')
        if tables then
            local header = true
            local delimiter = nil
            for _, arg in ipairs(opts.fargs) do
                if arg:match('noh') then
                    header = false
                else
                    delimiter = arg
                end
            end
            tables.tableFromSelection(
                opts.line1,
                opts.line2,
                { delimiter = delimiter, header = header }
            )
        end
    end, { range = true, nargs = '*' })
    user_command('MkdnFoldSection', function(opts)
        local folds = require_module('folds')
        if folds then
            folds.foldSection()
        end
    end, {})
    user_command('MkdnUnfoldSection', function(opts)
        local folds = require_module('folds')
        if folds then
            folds.unfoldSection()
        end
    end, {})
    user_command('MkdnBacklinks', function(opts)
        local backlinks = require_module('backlinks')
        if backlinks then
            backlinks.toggleBacklinks()
        end
    end, {})
    user_command('MkdnBacklinksRefresh', function(opts)
        local backlinks = require_module('backlinks')
        if backlinks then
            backlinks.refreshBacklinks()
        end
    end, {})
    user_command('MkdnCleanConfig', function()
        require('mkdnflow.health').cleanConfig()
    end, {})

    -- Return coptions to user values
    vim.o.cpoptions = save_cpo

    -- Record that the plugin has been loaded
    vim.api.nvim_set_var('loaded_mkdnflow', true)
end
