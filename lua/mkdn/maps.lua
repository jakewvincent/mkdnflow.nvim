-- Mkdn mappings

-- Get user's setting
local maps = vim.api.nvim_get_var('mkdn_maps')

-- If user has set mkdn_maps to true, set the mappings
if maps then
    vim.api.nvim_set_keymap('n', '<Tab>', [[<Cmd>:MkdnNextLink<CR>]], {noremap = true})
    vim.api.nvim_set_keymap('n', '<S-Tab>', [[<Cmd>:MkdnPrevLink<CR>]], {noremap = true})
    vim.api.nvim_set_keymap('n', '<BS>', ':edit #<CR>', {noremap = true, silent = true})    -- bs to :e last file
    vim.api.nvim_set_keymap('n', '<CR>', [[<Cmd>:MkdnFollowPath<CR>]], {noremap = true})
end
