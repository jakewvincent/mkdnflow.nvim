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

-- Mkdnflow mappings
vim.api.nvim_set_keymap('n', '<Tab>', [[<Cmd>:MkdnNextLink<CR>]], {noremap = true})
vim.api.nvim_set_keymap('n', '<S-Tab>', [[<Cmd>:MkdnPrevLink<CR>]], {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>mn', [[<Cmd>:MkdnNextHeading<CR>]], {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>mp', [[<Cmd>:MkdnPrevHeading<CR>]], {noremap = true})
vim.api.nvim_set_keymap('n', '<BS>', [[<Cmd>:MkdnGoBack<CR>]], {noremap = true})
vim.api.nvim_set_keymap('n', '<CR>', [[<Cmd>:MkdnFollowPath<CR>]], {noremap = true})
vim.api.nvim_set_keymap('v', '<CR>', [[<Cmd>:MkdnFollowPath<CR>]], {noremap = true})
vim.api.nvim_set_keymap('n', 'ya', [[<Cmd>:MkdnYankAnchorLink<CR>]], {noremap = true})
