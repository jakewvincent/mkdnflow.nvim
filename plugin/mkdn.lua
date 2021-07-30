-- License here

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
vim.api.nvim_exec("command! MkdnTestNav lua require('mkdn').files.testNavFunc()", true)
vim.api.nvim_exec("command! MkdnGetWord lua require('mkdn').files.createLink()", true)

--nnoremap <Tab> :MkdnNextLink<CR>
--nnoremap <S-Tab> :MkdnPrevLink<CR>

-- Return coptions to user's value
vim.api.nvim_set_option('cpoptions', save_cpo)

-- Loaded
vim.api.nvim_set_var('loaded_mkdn', true)
end
