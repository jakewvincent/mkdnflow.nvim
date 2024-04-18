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

local start_link_concealing = function()
    if link_style == 'markdown' then
        vim.fn.matchadd('Conceal', '\\[[^[]\\{-}\\]\\zs([^(]\\{-})\\ze', 0, -1, { conceal = '' })
        vim.fn.matchadd('Conceal', '\\zs\\[\\ze[^[]\\{-}\\]([^(]\\{-})', 0, -1, { conceal = '' })
        vim.fn.matchadd('Conceal', '\\[[^[]\\{-}\\zs\\]\\ze([^(]\\{-})', 0, -1, { conceal = '' })
        vim.fn.matchadd(
            'Conceal',
            '\\[[^[]\\{-}\\]\\zs\\%[ ]\\[[^[]\\{-}\\]\\ze\\%[ ]\\v([^(]|$)',
            0,
            -1,
            { conceal = '' }
        )
        vim.fn.matchadd(
            'Conceal',
            '\\zs\\[\\ze[^[]\\{-}\\]\\%[ ]\\[[^[]\\{-}\\]\\%[ ]\\v([^(]|$)',
            0,
            -1,
            { conceal = '' }
        )
        vim.fn.matchadd(
            'Conceal',
            '\\[[^[]\\{-}\\zs\\]\\ze\\%[ ]\\[[^[]\\{-}\\]\\%[ ]\\v([^(]|$)',
            0,
            -1,
            { conceal = '' }
        )
        vim.fn.matchadd(
            'Conceal',
            '\\[[^[]\\{-}\\]\\zs\\%[ ]\\[[^[]\\{-}\\]\\ze\\n',
            0,
            -1,
            { conceal = '' }
        )
        vim.fn.matchadd(
            'Conceal',
            '\\zs\\[\\ze[^[]\\{-}\\]\\%[ ]\\[[^[]\\{-}\\]\\n',
            0,
            -1,
            { conceal = '' }
        )
        vim.fn.matchadd(
            'Conceal',
            '\\[[^[]\\{-}\\zs\\]\\ze\\%[ ]\\[[^[]\\{-}\\]\\n',
            0,
            -1,
            { conceal = '' }
        )
    elseif link_style == 'wiki' then
        vim.fn.matchadd(
            'Conceal',
            '\\zs\\[\\[[^[]\\{-}[|]\\ze[^[]\\{-}\\]\\]',
            0,
            -1,
            { conceal = '' }
        )
        vim.fn.matchadd(
            'Conceal',
            '\\[\\[[^[\\{-}[|][^[]\\{-}\\zs\\]\\]\\ze',
            0,
            -1,
            { conceal = '' }
        )
        vim.fn.matchadd('Conceal', '\\zs\\[\\[\\ze[^[]\\{-}\\]\\]', 0, -1, { conceal = '' })
        vim.fn.matchadd('Conceal', '\\[\\[[^[]\\{-}\\zs\\]\\]\\ze', 0, -1, { conceal = '' })
    end

    -- Set conceal level
    vim.wo.conceallevel = 2

    -- Don't change the highlighting of concealed characters
    vim.api.nvim_exec([[highlight Conceal ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE]], false)
end

-- Set up autocommands to trigger the link concealing setup in Markdown files
local conceal_augroup = vim.api.nvim_create_augroup('MkdnflowLinkConcealing', { clear = true })

local ft_patterns = function()
    -- Create ft pattern
    local filetypes = require('mkdnflow').config.filetypes
    local ft_pattern = ''

    for ext, _ in pairs(filetypes) do
        ft_pattern = ft_pattern .. '*.' .. ext .. ','
    end
    return ft_pattern
end

vim.api.nvim_create_autocmd({ 'FileType', 'BufRead', 'BufEnter' }, {
    pattern = ft_patterns(),
    callback = function()
        start_link_concealing()
    end,
    group = conceal_augroup,
})
