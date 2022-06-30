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

local link_style = require('mkdnflow').config.links.style
vim.wo.conceallevel = 2

if link_style == 'markdown' then
    vim.api.nvim_exec([[
        call matchadd('Conceal', '\[[^[]\{-}\]\zs(.\{-})\ze', 0, 14, {'conceal': ''})
        call matchadd('Conceal', '\zs\[\ze[^[]\{-}\](.\{-})', 0, 15, {'conceal': ''})
        call matchadd('Conceal', '\[[^[]\{-}\zs\]\ze(.\{-})', 0, 16, {'conceal': ''})
    ]], false)
elseif link_style == 'wiki' then
    vim.api.nvim_exec([[
        call matchadd('Conceal', '\zs\[\[.\{-}[|]\ze.\{-}\]\]', 0, 14, {'conceal': ''})
        call matchadd('Conceal', '\[\[.\{-}[|].\{-}\zs\]\]\ze', 0, 15, {'conceal': ''})
        call matchadd('Conceal', '\zs\[\[\ze.\{-}\]\]', 0, 16, {'conceal': ''})
        call matchadd('Conceal', '\[\[.\{-}\zs\]\]\ze', 0, 17, {'conceal': ''})
    ]], false)
end

-- Don't change the highlighting of concealed characters
vim.api.nvim_exec([[highlight Conceal ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE]], false)
