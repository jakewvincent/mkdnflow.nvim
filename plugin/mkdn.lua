-- mkdn.nvim (Tools for personal markdown notebook management)
-- Copyright (C) 2021 Jake W. Vincent <https://github.com/jakewvincent>
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
if vim.fn.exists('g:loaded_mkdn') == 0 then

    -- Save user coptions
    local save_cpo = vim.api.nvim_get_option('cpoptions')
    -- Retrieve defaults
    local cpo_defaults = vim.api.nvim_get_option_info('cpoptions')['default']
    -- Set to defaults
    vim.api.nvim_set_option('cpoptions', cpo_defaults)

    -- Define commands
    vim.api.nvim_exec("command! MkdnNextLink lua require('mkdn').cursor.toNextLink()", true)
    vim.api.nvim_exec("command! MkdnPrevLink lua require('mkdn').cursor.toPrevLink()", true)

    -- Test commands
    vim.api.nvim_exec("command! MkdnGetPath lua require('mkdn').files.getPath()", true)
    vim.api.nvim_exec("command! MkdnFollowPath lua require('mkdn').files.followPath()", true)
    vim.api.nvim_exec("command! MkdnCreateLink lua require('mkdn').files.createLink()", true)

    -- Return coptions to user values
    vim.api.nvim_set_option('cpoptions', save_cpo)

    -- Record that the plugin has been loaded
    vim.api.nvim_set_var('loaded_mkdn', true)
end
