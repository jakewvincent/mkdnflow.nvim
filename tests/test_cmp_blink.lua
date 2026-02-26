-- tests/test_cmp_blink.lua
-- Tests for blink.cmp completion adapter

local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local child = MiniTest.new_child_neovim()

-- Create a temporary directory structure for testing
local test_root = vim.fn.tempname()

--- Helper: set up mkdnflow in the child process for blink adapter testing.
--- No nvim-cmp mock needed — the blink adapter goes straight to the core module.
---@param config_overrides string Lua table literal for mkdnflow setup overrides
local function setup_blink_child(config_overrides)
    child.restart({ '-u', 'scripts/minimal_init.lua' })
    child.lua('_G._test_root = "' .. test_root .. '"')
    child.lua([[
        -- Set buffer to a file inside test_root so path resolution works
        vim.api.nvim_buf_set_name(0, _G._test_root .. '/current.md')
        vim.bo.filetype = 'markdown'

        require('mkdnflow').setup(]] .. config_overrides .. [[)
    ]])
end

--- Helper: invoke blink adapter with mocked blink context.
--- blink ctx: { line = full_line, cursor = {row_1, col_0}, bufnr = bufnr }
---@param full_line string The full line text
---@param cursor_col integer 0-indexed cursor column
---@param cursor_row? integer 1-indexed cursor row (defaults to 1)
---@return table result { items, is_incomplete_forward, is_incomplete_backward }
local function blink_complete(full_line, cursor_col, cursor_row)
    cursor_row = cursor_row or 1
    child.lua('_G._bl = ' .. vim.inspect({ line = full_line, col = cursor_col, row = cursor_row }))
    child.lua([[
        _G._blink_result = nil
        local src = require('mkdnflow.completion.blink').new()
        src:get_completions(
            { line = _G._bl.line, cursor = { _G._bl.row, _G._bl.col } },
            function(result) _G._blink_result = result end
        )
    ]])
    child.lua('vim.wait(2000, function() return _G._blink_result ~= nil end, 10)')
    return child.lua_get('_G._blink_result')
end

--- Helper: find a completion item by label
---@param items table[]
---@param label string
---@return table|nil
local function find_item(items, label)
    for _, item in ipairs(items) do
        if item.label == label then
            return item
        end
    end
    return nil
end

local T = new_set({
    hooks = {
        pre_once = function()
            -- Create test directory structure
            vim.fn.mkdir(test_root, 'p')
            vim.fn.mkdir(test_root .. '/subdir', 'p')

            -- Create test files
            local files = {
                { test_root .. '/note1.md', '# Note 1\n\nFirst note.' },
                { test_root .. '/note2.md', '# Note 2\n\nSecond note.' },
                { test_root .. '/subdir/nested.md', '# Nested\n\nNested note.' },
            }
            for _, entry in ipairs(files) do
                local f = io.open(entry[1], 'w')
                f:write(entry[2])
                f:close()
            end
        end,
        post_once = function()
            child.stop()
            vim.fn.delete(test_root, 'rf')
        end,
    },
})

-- =============================================================================
-- Source interface
-- =============================================================================
T['source_interface'] = new_set()

T['source_interface']['get_trigger_characters includes @'] = function()
    child.restart({ '-u', 'scripts/minimal_init.lua' })
    child.lua([[_G._bl_src = require('mkdnflow.completion.blink').new()]])
    local triggers = child.lua_get([[_G._bl_src:get_trigger_characters()]])
    eq(triggers, { '@', '^', '#' })
end

T['source_interface']['enabled() returns false before setup'] = function()
    child.restart({ '-u', 'scripts/minimal_init.lua' })
    child.lua([[_G._bl_src = require('mkdnflow.completion.blink').new()]])
    local enabled = child.lua_get([[_G._bl_src:enabled()]])
    eq(enabled, false)
end

T['source_interface']['enabled() returns true after setup'] = function()
    setup_blink_child([[{ modules = { completion = true }, silent = true }]])
    child.lua([[_G._bl_src = require('mkdnflow.completion.blink').new()]])
    local enabled = child.lua_get([[_G._bl_src:enabled()]])
    eq(enabled, true)
end

T['source_interface']['callback format has is_incomplete fields'] = function()
    setup_blink_child([[{
        modules = { completion = true },
        links = { transform_on_create = false },
        silent = true,
    }]])
    local result = blink_complete('@', 1)
    eq(result.is_incomplete_forward, false)
    eq(result.is_incomplete_backward, false)
    eq(type(result.items), 'table')
end

T['source_interface']['get_completions returns empty before setup'] = function()
    child.restart({ '-u', 'scripts/minimal_init.lua' })
    child.lua([[
        _G._blink_result = nil
        local src = require('mkdnflow.completion.blink').new()
        src:get_completions(
            { line = '@', cursor = { 1, 1 } },
            function(result) _G._blink_result = result end
        )
    ]])
    child.lua('vim.wait(500, function() return _G._blink_result ~= nil end, 10)')
    local result = child.lua_get('_G._blink_result')
    eq(#result.items, 0)
end

-- =============================================================================
-- @ trigger: file completions
-- =============================================================================
T['at_trigger'] = new_set({
    hooks = {
        pre_case = function()
            setup_blink_child([[{
                modules = { completion = true },
                links = { transform_on_create = false },
                silent = true,
            }]])
        end,
    },
})

T['at_trigger']['returns file items'] = function()
    local result = blink_complete('@', 1)
    local note1 = find_item(result.items, 'note1')
    eq(type(note1), 'table')
    eq(note1.insertText, '[note1](note1.md)')
end

T['at_trigger']['includes nested files'] = function()
    local result = blink_complete('@', 1)
    local nested = find_item(result.items, 'nested')
    eq(type(nested), 'table')
    eq(nested.insertText, '[nested](subdir/nested.md)')
end

T['at_trigger']['no trigger returns empty'] = function()
    local result = blink_complete('no trigger', 10)
    eq(#result.items, 0)
end

-- =============================================================================
-- Footnote trigger
-- =============================================================================
T['footnote'] = new_set({
    hooks = {
        pre_case = function()
            setup_blink_child([[{ modules = { completion = true }, silent = true }]])
        end,
    },
})

T['footnote']['mid-line returns defined footnotes'] = function()
    child.lua([[
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {
            'Text[^1] here.',
            '',
            '[^1]: First footnote',
        })
    ]])
    local result = blink_complete('text [^', 7)
    eq(#result.items, 1)
    eq(result.items[1].label, '[^1]')
end

T['footnote']['line-start returns undefined refs'] = function()
    child.lua([[
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {
            'Text[^1] and[^2] here.',
        })
    ]])
    local result = blink_complete('[^', 2)
    eq(#result.items, 2)
    eq(result.items[1].label, '[^1]')
    eq(result.items[2].label, '[^2]')
end

-- =============================================================================
-- Heading anchor trigger: markdown style ](#
-- =============================================================================
T['heading_markdown'] = new_set({
    hooks = {
        pre_case = function()
            setup_blink_child([[{ modules = { completion = true }, silent = true }]])
        end,
    },
})

T['heading_markdown']['returns heading items'] = function()
    child.lua([[
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {
            '# Top Level',
            '',
            '## Second Level',
        })
    ]])
    local result = blink_complete('[text](#', 8)
    eq(#result.items, 2)
    eq(result.items[1].label, 'Top Level')
    eq(result.items[2].label, 'Second Level')
end

T['heading_markdown']['auto-pairs: omits closing paren when present'] = function()
    child.lua([[
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {
            '## Target Heading',
        })
    ]])
    -- full_line = '[text](#)', cursor at col 8 (before ')')
    local result = blink_complete('[text](#)', 8)
    eq(#result.items, 1)
    -- Should NOT include ) since it's already after the cursor
    eq(result.items[1].insertText, '#target-heading')
end

T['heading_markdown']['auto-pairs: includes closing paren when absent'] = function()
    child.lua([[
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {
            '## Target Heading',
        })
    ]])
    -- full_line = '[text](#', cursor at col 8 (no ')' after)
    local result = blink_complete('[text](#', 8)
    eq(#result.items, 1)
    eq(result.items[1].insertText, '#target-heading)')
end

-- =============================================================================
-- Heading anchor trigger: wiki style [[#
-- =============================================================================
T['heading_wiki'] = new_set({
    hooks = {
        pre_case = function()
            setup_blink_child([[{
                modules = { completion = true },
                links = { style = 'wiki' },
                silent = true,
            }]])
        end,
    },
})

T['heading_wiki']['returns heading items'] = function()
    child.lua([[
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {
            '## Wiki Heading',
        })
    ]])
    local result = blink_complete('[[#', 3)
    eq(#result.items, 1)
    eq(result.items[1].insertText, '#wiki-heading|Wiki Heading]]')
end

T['heading_wiki']['auto-pairs: omits closing brackets when present'] = function()
    child.lua([[
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {
            '## Wiki Heading',
        })
    ]])
    -- full_line = '[[#]]', cursor at col 3 (before ']]')
    local result = blink_complete('[[#]]', 3)
    eq(#result.items, 1)
    eq(result.items[1].insertText, '#wiki-heading|Wiki Heading')
end

return T
