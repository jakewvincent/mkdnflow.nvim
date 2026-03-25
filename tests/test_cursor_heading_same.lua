-- tests/test_cursor_heading_same.lua
-- Tests for same-level heading navigation (goToSame)

local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local child = MiniTest.new_child_neovim()

-- Helper to set buffer content
local function set_lines(lines)
    child.lua('vim.api.nvim_buf_set_lines(0, 0, -1, false, ' .. vim.inspect(lines) .. ')')
end

-- Helper to set cursor position (1-indexed row, 0-indexed col)
local function set_cursor(row, col)
    child.lua('vim.api.nvim_win_set_cursor(0, {' .. row .. ', ' .. col .. '})')
end

-- Helper to get cursor position
local function get_cursor()
    return child.lua_get('vim.api.nvim_win_get_cursor(0)')
end

local T = new_set({
    hooks = {
        pre_case = function()
            child.restart({ '-u', 'scripts/minimal_init.lua' })
            child.lua([[
                vim.api.nvim_buf_set_name(0, 'test.md')
                vim.bo.filetype = 'markdown'
                require('mkdnflow').setup({
                    silent = true
                })
                vim.cmd('doautocmd FileType')
            ]])
        end,
        post_once = child.stop,
    },
})

-- =============================================================================
-- goToSame() - Same-level heading navigation
-- =============================================================================
T['goToSame'] = new_set()

T['goToSame']['next: jumps to next heading of same level'] = function()
    set_lines({ '# A', '## B', '## C', '# D' })
    set_cursor(2, 0) -- on ## B
    child.lua([[require('mkdnflow.cursor').goToSame(false)]])
    eq(get_cursor()[1], 3) -- should land on ## C
end

T['goToSame']['prev: jumps to previous heading of same level'] = function()
    set_lines({ '# A', '## B', '## C', '# D' })
    set_cursor(3, 0) -- on ## C
    child.lua([[require('mkdnflow.cursor').goToSame(true)]])
    eq(get_cursor()[1], 2) -- should land on ## B
end

T['goToSame']['next: from inside section finds next same-level heading'] = function()
    set_lines({ '# A', 'some text', '# B' })
    set_cursor(2, 0) -- on text inside # A section
    child.lua([[require('mkdnflow.cursor').goToSame(false)]])
    eq(get_cursor()[1], 3) -- should land on # B
end

T['goToSame']['prev: from inside section jumps to heading before current section'] = function()
    set_lines({ '# A', '# B', 'some text', '# C' })
    set_cursor(3, 0) -- on text inside # B section
    child.lua([[require('mkdnflow.cursor').goToSame(true)]])
    eq(get_cursor()[1], 1) -- should land on # A
end

T['goToSame']['no match: cursor stays put'] = function()
    set_lines({ '# A', '## B', '# C' })
    set_cursor(2, 0) -- on ## B, no other ## headings
    child.lua([[require('mkdnflow.cursor').goToSame(false)]])
    eq(get_cursor()[1], 2) -- should stay on ## B
end

T['goToSame']['no parent heading: cursor stays put'] = function()
    set_lines({ 'some text', '# A', '# B' })
    set_cursor(1, 0) -- above any heading
    child.lua([[require('mkdnflow.cursor').goToSame(false)]])
    eq(get_cursor()[1], 1) -- should stay put
end

T['goToSame']['skips headings of different levels'] = function()
    set_lines({ '## A', '### B', '## C' })
    set_cursor(1, 0) -- on ## A
    child.lua([[require('mkdnflow.cursor').goToSame(false)]])
    eq(get_cursor()[1], 3) -- should skip ### B and land on ## C
end

-- =============================================================================
-- E2E keymap tests
-- =============================================================================
T['goToSame_e2e'] = new_set({
    hooks = {
        pre_case = function()
            child.restart({ '-u', 'scripts/minimal_init.lua' })
            child.lua([[
                vim.cmd('runtime plugin/mkdnflow.lua')
                vim.api.nvim_buf_set_name(0, 'test.md')
                vim.bo.filetype = 'markdown'
                require('mkdnflow').setup({
                    silent = true
                })
                vim.cmd('doautocmd BufEnter')
            ]])
        end,
    },
})

T['goToSame_e2e']['][ jumps to next same-level heading'] = function()
    set_lines({ '## A', '### B', '## C' })
    set_cursor(1, 0)
    child.type_keys('][')
    eq(get_cursor()[1], 3)
end

T['goToSame_e2e']['[] jumps to previous same-level heading'] = function()
    set_lines({ '## A', '### B', '## C' })
    set_cursor(3, 0)
    child.type_keys('[]')
    eq(get_cursor()[1], 1)
end

return T
