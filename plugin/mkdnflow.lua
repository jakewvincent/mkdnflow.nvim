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
    local save_cpo = vim.api.nvim_get_option('cpoptions')
    -- Retrieve defaults
    local cpo_defaults = vim.api.nvim_get_option_info('cpoptions')['default']
    -- Set to defaults
    vim.api.nvim_set_option('cpoptions', cpo_defaults)
    local user_command = vim.api.nvim_create_user_command
    local mkdnflow = require('mkdnflow')

    user_command('Mkdnflow', function(opts)
        mkdnflow.forceStart(opts.fargs)
    end, { nargs = '*' })
    user_command('MkdnEnter', function(opts)
        if opts.range > 0 then
            require('mkdnflow.wrappers').multiFuncEnter({range = true})
        else
            require('mkdnflow.wrappers').multiFuncEnter()
        end
    end, {range = true})
    user_command('MkdnTab', function(opts)
        require('mkdnflow.wrappers').indentListItemOrJumpTableCell(1)
    end, {})
    user_command('MkdnSTab', function(opts)
        require('mkdnflow.wrappers').indentListItemOrJumpTableCell(-1)
    end, {})
    user_command('MkdnGoBack', function(opts)
        mkdnflow.buffers.goBack()
    end, {})
    user_command('MkdnGoForward', function(opts)
        mkdnflow.buffers.goForward()
    end, {})
    user_command('MkdnMoveSource', function(opts)
        mkdnflow.paths.moveSource()
    end, {})
    user_command('MkdnNextLink', function(opts)
        mkdnflow.cursor.toNextLink()
    end, {})
    user_command('MkdnPrevLink', function(opts)
        mkdnflow.cursor.toPrevLink()
    end, {})
    user_command('MkdnFollowLink', function(opts)
        mkdnflow.links.followLink()
    end, {})
    user_command('MkdnCreateLink', function(opts)
        if opts.range > 0 then
            mkdnflow.links.createLink({range = true})
        else
            mkdnflow.links.createLink()
        end
    end, {range = true})
    user_command('MkdnCreateLinkFromClipboard', function(opts)
        if opts.range > 0 then
            mkdnflow.links.createLink({from_clipboard = true, range = true})
        else
            mkdnflow.links.createLink({from_clipboard = true})
        end
    end, {range = true})
    user_command('MkdnDestroyLink', function(opts)
        mkdnflow.links.destroyLink()
    end, {})
    user_command('MkdnTagSpan', function(opts)
        mkdnflow.links.tagSpan()
    end, {})
    user_command('MkdnYankAnchorLink', function(opts)
        mkdnflow.cursor.yankAsAnchorLink()
    end, {})
    user_command('MkdnYankFileAnchorLink', function(opts)
        mkdnflow.cursor.yankAsAnchorLink({})
    end, {})
    user_command('MkdnNextHeading', function(opts)
        mkdnflow.cursor.toHeading(nil)
    end, {})
    user_command('MkdnPrevHeading', function(opts)
        mkdnflow.cursor.toHeading(nil, {})
    end, {})
    user_command('MkdnIncreaseHeading', function(opts)
        mkdnflow.cursor.changeHeadingLevel('increase')
    end, {})
    user_command('MkdnDecreaseHeading', function(opts)
        mkdnflow.cursor.changeHeadingLevel('decrease')
    end, {})
    user_command('MkdnToggleToDo', function(opts)
        mkdnflow.lists.toggleToDo(false, false, {})
    end, {})
    user_command('MkdnNewListItem', function(opts)
        mkdnflow.lists.newListItem(true, false, true, 'i', '<CR>')
    end, {})
    user_command('MkdnNewListItemBelowInsert', function(opts)
        mkdnflow.lists.newListItem(false, false, true, 'i', 'o')
    end, {})
    user_command('MkdnNewListItemAboveInsert', function(opts)
        mkdnflow.lists.newListItem(false, true, true, 'i', 'O')
    end, {})
    user_command('MkdnExtendList', function(opts)
        mkdnflow.lists.newListItem(false, 'n')
    end, {})
    user_command('MkdnUpdateNumbering', function(opts)
        mkdnflow.lists.updateNumbering(opts.fargs)
    end, { nargs = '*' })
    user_command('MkdnTable', function(opts)
        mkdnflow.tables.newTable(opts.fargs)
    end, { nargs = '*' })
    user_command('MkdnTableFormat', function(opts)
        mkdnflow.tables.formatTable()
    end, {})
    user_command('MkdnTableNextCell', function(opts)
        mkdnflow.tables.moveToCell(0, 1)
    end, {})
    user_command('MkdnTablePrevCell', function(opts)
        mkdnflow.tables.moveToCell(0, -1)
    end, {})
    user_command('MkdnTableNextRow', function(opts)
        mkdnflow.tables.moveToCell(1, 0)
    end, {})
    user_command('MkdnTablePrevRow', function(opts)
        mkdnflow.tables.moveToCell(-1, 0)
    end, {})
    user_command('MkdnTableNewRowBelow', function(opts)
        mkdnflow.tables.addRow()
    end, {})
    user_command('MkdnTableNewRowAbove', function(opts)
        mkdnflow.tables.addRow(-1)
    end, {})
    user_command('MkdnTableNewColAfter', function(opts)
        mkdnflow.tables.addCol()
    end, {})
    user_command('MkdnTableNewColBefore', function(opts)
        mkdnflow.tables.addCol(-1)
    end, {})
    user_command('MkdnFoldSection', function(opts)
        mkdnflow.folds.foldSection()
    end, {})
    user_command('MkdnUnfoldSection', function(opts)
        mkdnflow.folds.unfoldSection()
    end, {})

    -- Return coptions to user values
    vim.api.nvim_set_option('cpoptions', save_cpo)

    -- Record that the plugin has been loaded
    vim.api.nvim_set_var('loaded_mkdnflow', true)
end
