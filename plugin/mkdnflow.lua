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

    -- Define commands
    vim.api.nvim_exec("command! MkdnNextLink lua require('mkdnflow').cursor.toNextLink()", true)
    vim.api.nvim_exec("command! MkdnPrevLink lua require('mkdnflow').cursor.toPrevLink()", true)
    vim.api.nvim_exec("command! MkdnNextHeading lua require('mkdnflow').cursor.toHeading(nil)", true)
    vim.api.nvim_exec("command! MkdnPrevHeading lua require('mkdnflow').cursor.toHeading(nil, true)", true)
    vim.api.nvim_exec("command! MkdnFollowLink lua require('mkdnflow').links.followLink()", true)
    vim.api.nvim_exec("command! MkdnFollowPath lua require('mkdnflow').files.followPath()", true)
    vim.api.nvim_exec("command! MkdnCreateLink lua require('mkdnflow').links.createLink()", true)
    vim.api.nvim_exec("command! MkdnDestroyLink lua require('mkdnflow').links.destroyLink()", true)
    vim.api.nvim_exec("command! MkdnYankAnchorLink lua require('mkdnflow').cursor.yankAsAnchorLink()", true)
    vim.api.nvim_exec("command! MkdnGoBack lua require('mkdnflow').buffers.goBack()", true)
    vim.api.nvim_exec("command! MkdnGoForward lua require('mkdnflow').buffers.goForward()", true)
    vim.api.nvim_exec("command! MkdnFlow lua print('Please use :Mkdnflow instead (lowercase f).')", true)
    vim.api.nvim_exec("command! Mkdnflow lua require('mkdnflow').forceStart()", true)
    vim.api.nvim_exec("command! MkdnIncreaseHeading lua require('mkdnflow').cursor.changeHeadingLevel('increase')", true)
    vim.api.nvim_exec("command! MkdnDecreaseHeading lua require('mkdnflow').cursor.changeHeadingLevel('decrease')", true)
    vim.api.nvim_exec("command! MkdnToggleToDo lua require('mkdnflow').lists.toggleToDo()", true)

    -- Return coptions to user values
    vim.api.nvim_set_option('cpoptions', save_cpo)

    -- Record that the plugin has been loaded
    vim.api.nvim_set_var('loaded_mkdnflow', true)
end
