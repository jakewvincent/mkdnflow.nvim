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
    local command_deps = mkdnflow.command_deps
    local define_command = {
        MkdnEnter = function()
            user_command('MkdnEnter', function(opts) require('mkdnflow.wrappers').multiFuncEnter() end, {})
        end,
        MkdnTab = function()
            user_command('MkdnTab', function(opts) require('mkdnflow.wrappers').indentListItemOrJumpTableCell(1) end, {})
        end,
        MkdnSTab = function()
            user_command('MkdnSTab', function(opts) require('mkdnflow.wrappers').indentListItemOrJumpTableCell(-1) end, {})
        end,
        MkdnGoBack = function()
            user_command('MkdnGoBack', function(opts) mkdnflow.buffers.goBack() end, {})
        end,
        MkdnGoForward = function()
            user_command('MkdnGoForward', function(opts) mkdnflow.buffers.goForward() end, {})
        end,
        MkdnMoveSource = function()
            user_command('MkdnMoveSource', function(opts) mkdnflow.paths.moveSource() end, {})
        end,
        MkdnNextLink = function()
            user_command('MkdnNextLink', function(opts) mkdnflow.cursor.toNextLink() end, {})
        end,
        MkdnPrevLink = function()
            user_command('MkdnPrevLink', function(opts) mkdnflow.cursor.toPrevLink() end, {})
        end,
        MkdnFollowLink = function()
            user_command('MkdnFollowLink', function(opts) mkdnflow.links.followLink() end, {})
        end,
        MkdnCreateLink = function()
            user_command('MkdnCreateLink', function(opts) mkdnflow.links.createLink() end, {})
        end,
        MkdnDestroyLink = function()
            user_command('MkdnDestroyLink', function(opts) mkdnflow.links.destroyLink() end, {})
        end,
        MkdnYankAnchorLink = function()
            user_command('MkdnYankAnchorLink', function(opts) mkdnflow.cursor.yankAsAnchorLink() end, {})
        end,
        MkdnYankFileAnchorLink = function()
            user_command('MkdnYankFileAnchorLink', function(opts) mkdnflow.cursor.yankAsAnchorLink({}) end, {})
        end,
        MkdnNextHeading = function()
            user_command('MkdnNextHeading', function(opts) mkdnflow.cursor.toHeading(nil) end, {})
        end,
        MkdnPrevHeading = function()
            user_command('MkdnPrevHeading', function(opts) mkdnflow.cursor.toHeading(nil, {}) end, {})
        end,
        MkdnIncreaseHeading = function()
            user_command('MkdnIncreaseHeading', function(opts) mkdnflow.cursor.changeHeadingLevel('increase') end, {})
        end,
        MkdnDecreaseHeading = function()
            user_command('MkdnDecreaseHeading', function(opts) mkdnflow.cursor.changeHeadingLevel('decrease') end, {})
        end,
        MkdnToggleToDo = function()
            user_command('MkdnToggleToDo', function(opts) mkdnflow.lists.toggleToDo(false, false, {}) end, {})
        end,
        MkdnNewListItem = function()
            user_command('MkdnNewListItem', function(opts) mkdnflow.lists.newListItem() end, {})
        end,
        MkdnExtendList = function()
            user_command('MkdnExtendList', function(opts) mkdnflow.lists.newListItem('simple') end, {})
        end,
        MkdnUpdateNumbering = function()
            user_command('MkdnUpdateNumbering', function(opts) mkdnflow.lists.updateNumbering(opts.fargs) end, {nargs = '*'})
        end,
        MkdnTable = function()
            user_command('MkdnTable', function(opts) mkdnflow.tables.newTable(opts.fargs) end, {nargs = '*'})
        end,
        MkdnTableFormat = function()
            user_command('MkdnTableFormat', function(opts) mkdnflow.tables.formatTable() end, {})
        end,
        MkdnTableNextCell = function()
            user_command('MkdnTableNextCell', function(opts) mkdnflow.tables.moveToCell(0, 1) end, {})
        end,
        MkdnTablePrevCell = function()
            user_command('MkdnTablePrevCell', function(opts) mkdnflow.tables.moveToCell(0, -1) end, {})
        end,
        MkdnTableNextRow = function()
            user_command('MkdnTableNextRow', function(opts) mkdnflow.tables.moveToCell(1, 0) end, {})
        end,
        MkdnTablePrevRow = function()
            user_command('MkdnTablePrevRow', function(opts) mkdnflow.tables.moveToCell(-1, 0) end, {})
        end,
        MkdnTableNewRowBelow = function()
            user_command('MkdnTableNewRowBelow', function(opts) mkdnflow.tables.addRow() end, {})
        end,
        MkdnTableNewRowAbove = function()
            user_command('MkdnTableNewRowAbove', function(opts) mkdnflow.tables.addRow(-1) end, {})
        end,
        MkdnTableNewColAfter = function()
            user_command('MkdnTableNewColAfter', function(opts) mkdnflow.tables.addCol() end, {})
        end,
        MkdnTableNewColBefore = function()
            user_command('MkdnTableNewColBefore', function(opts) mkdnflow.tables.addCol(-1) end, {})
        end,
        MkdnFoldSection = function()
            user_command('MkdnFoldSection', function(opts) mkdnflow.folds.foldSection() end, {})
        end,
        MkdnUnfoldSection = function()
            user_command('MkdnUnfoldSection', function(opts) mkdnflow.folds.unfoldSection() end, {})
        end,
    }

    -- Define forceStart command
    user_command('Mkdnflow', function(opts) mkdnflow.forceStart(opts.fargs) end, {nargs = '*'})
    -- Define remaining commands based on module availability
    for command, deps in pairs(command_deps) do
        local available = true
        for _, module in ipairs(deps) do
            if not mkdnflow.config.modules[module] then
                available = false
            end
        end
        if available then
            define_command[command]()
        end
    end

    -- Return coptions to user values
    vim.api.nvim_set_option('cpoptions', save_cpo)

    -- Record that the plugin has been loaded
    vim.api.nvim_set_var('loaded_mkdnflow', true)
end
