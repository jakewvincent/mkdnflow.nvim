-- tests/test_folds.lua
-- Tests for section folding functionality

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
                vim.opt.foldmethod = 'manual'
                require('mkdnflow').setup({
                    modules = { folds = true },
                    silent = true
                })
            ]])
        end,
        post_once = child.stop,
    },
})

-- =============================================================================
-- getHeadingLevel() - Determine heading level from line content
-- =============================================================================
T['getHeadingLevel'] = new_set()

T['getHeadingLevel']['returns 1 for H1'] = function()
    local result = child.lua_get([[require('mkdnflow.utils').getHeadingLevel('# Heading')]])
    eq(result, 1)
end

T['getHeadingLevel']['returns 2 for H2'] = function()
    local result = child.lua_get([[require('mkdnflow.utils').getHeadingLevel('## Heading')]])
    eq(result, 2)
end

T['getHeadingLevel']['returns 3 for H3'] = function()
    local result = child.lua_get([[require('mkdnflow.utils').getHeadingLevel('### Heading')]])
    eq(result, 3)
end

T['getHeadingLevel']['returns 6 for H6'] = function()
    local result = child.lua_get([[require('mkdnflow.utils').getHeadingLevel('###### Heading')]])
    eq(result, 6)
end

T['getHeadingLevel']['returns 99 for non-heading'] = function()
    local result = child.lua_get([[require('mkdnflow.utils').getHeadingLevel('Regular text')]])
    eq(result, 99)
end

T['getHeadingLevel']['returns 99 for empty string'] = function()
    local result = child.lua_get([[require('mkdnflow.utils').getHeadingLevel('')]])
    eq(result, 99)
end

T['getHeadingLevel']['returns 99 for nil'] = function()
    local result = child.lua_get([[require('mkdnflow.utils').getHeadingLevel(nil)]])
    eq(result, 99)
end

T['getHeadingLevel']['handles leading whitespace'] = function()
    local result = child.lua_get([[require('mkdnflow.utils').getHeadingLevel('  ## Heading')]])
    eq(result, 2)
end

T['getHeadingLevel']['handles hash without space'] = function()
    -- This might be treated as a heading depending on implementation
    local result = child.lua_get([[require('mkdnflow.utils').getHeadingLevel('#NoSpace')]])
    -- Check if it's recognized as heading level 1 or not
    eq(result, 1) -- Actually it matches the pattern
end

T['getHeadingLevel']['handles multiple hashes in text'] = function()
    -- Pattern matches leading hashes only
    local result =
        child.lua_get([[require('mkdnflow.utils').getHeadingLevel('# Heading ## with hashes')]])
    eq(result, 1)
end

-- =============================================================================
-- foldSection() - Create fold for section
-- =============================================================================
T['foldSection'] = new_set()

T['foldSection']['creates fold on heading line'] = function()
    set_lines({ '# Heading', 'Content line 1', 'Content line 2', '# Next Heading' })
    set_cursor(1, 0)
    child.lua([[require('mkdnflow.folds').foldSection()]])
    -- Check if fold was created
    local foldlevel = child.lua_get('vim.fn.foldlevel(1)')
    eq(foldlevel > 0, true)
end

T['foldSection']['fold ends before next same-level heading'] = function()
    set_lines({ '# First', 'Content', '# Second' })
    set_cursor(1, 0)
    child.lua([[require('mkdnflow.folds').foldSection()]])
    -- Line 1 and 2 should be in fold, line 3 should not
    local fold1 = child.lua_get('vim.fn.foldclosed(1)')
    local fold3 = child.lua_get('vim.fn.foldclosed(3)')
    eq(fold1, 1) -- Fold starts at line 1
    eq(fold3, -1) -- Line 3 is not folded
end

T['foldSection']['includes subsections in fold'] = function()
    set_lines({ '# Main', '## Sub', 'Content', '# Another' })
    set_cursor(1, 0)
    child.lua([[require('mkdnflow.folds').foldSection()]])
    -- Lines 1-3 should be in fold
    local foldend = child.lua_get('vim.fn.foldclosedend(1)')
    eq(foldend, 3)
end

T['foldSection']['from content finds nearest heading'] = function()
    set_lines({ '# Heading', 'Content here', 'More content' })
    set_cursor(2, 0) -- Cursor on content
    child.lua([[require('mkdnflow.folds').foldSection()]])
    -- Should fold from heading
    local fold1 = child.lua_get('vim.fn.foldclosed(1)')
    eq(fold1, 1)
end

T['foldSection']['does nothing in code block'] = function()
    set_lines({ '```', '# Not a heading', '```', 'Content' })
    set_cursor(2, 0) -- On "# Not a heading" inside code block
    -- This should not create a fold since we're in a code block
    child.lua([[require('mkdnflow.folds').foldSection()]])
    local fold1 = child.lua_get('vim.fn.foldlevel(2)')
    eq(fold1, 0)
end

T['foldSection']['H2 section ends at next H2'] = function()
    set_lines({ '## First', 'Content', '## Second', 'More' })
    set_cursor(1, 0)
    child.lua([[require('mkdnflow.folds').foldSection()]])
    local foldend = child.lua_get('vim.fn.foldclosedend(1)')
    eq(foldend, 2) -- Fold ends at line 2, before line 3
end

T['foldSection']['H2 section ends at H1'] = function()
    set_lines({ '## Sub', 'Content', '# Main' })
    set_cursor(1, 0)
    child.lua([[require('mkdnflow.folds').foldSection()]])
    local foldend = child.lua_get('vim.fn.foldclosedend(1)')
    eq(foldend, 2) -- Fold ends before H1
end

T['foldSection']['handles heading in code block correctly'] = function()
    set_lines({ '# Real', '```', '# Fake', '```', 'Content', '# Next' })
    set_cursor(1, 0)
    child.lua([[require('mkdnflow.folds').foldSection()]])
    -- Should include code block with fake heading, end before line 6
    local foldend = child.lua_get('vim.fn.foldclosedend(1)')
    eq(foldend, 5)
end

-- =============================================================================
-- unfoldSection() - Open fold
-- =============================================================================
T['unfoldSection'] = new_set()

T['unfoldSection']['opens closed fold'] = function()
    set_lines({ '# Heading', 'Content' })
    set_cursor(1, 0)
    -- Create a fold first
    child.lua([[require('mkdnflow.folds').foldSection()]])
    -- Verify it's folded
    local foldclosed = child.lua_get('vim.fn.foldclosed(1)')
    eq(foldclosed, 1)
    -- Now unfold
    child.lua([[require('mkdnflow.folds').unfoldSection()]])
    -- Verify it's unfolded
    foldclosed = child.lua_get('vim.fn.foldclosed(1)')
    eq(foldclosed, -1)
end

T['unfoldSection']['does nothing when not in fold'] = function()
    set_lines({ 'No fold here' })
    set_cursor(1, 0)
    -- Should not error
    child.lua([[require('mkdnflow.folds').unfoldSection()]])
    -- Still no fold
    local foldlevel = child.lua_get('vim.fn.foldlevel(1)')
    eq(foldlevel, 0)
end

T['unfoldSection']['accepts row parameter'] = function()
    set_lines({ '# Heading', 'Content', 'More' })
    set_cursor(1, 0)
    child.lua([[require('mkdnflow.folds').foldSection()]])
    -- Unfold using row parameter
    child.lua([[require('mkdnflow.folds').unfoldSection(1)]])
    local foldclosed = child.lua_get('vim.fn.foldclosed(1)')
    eq(foldclosed, -1)
end

-- =============================================================================
-- Integration tests
-- =============================================================================
T['integration'] = new_set()

T['integration']['fold and unfold cycle'] = function()
    set_lines({ '# Heading', 'Content 1', 'Content 2' })
    set_cursor(1, 0)

    -- Fold
    child.lua([[require('mkdnflow.folds').foldSection()]])
    eq(child.lua_get('vim.fn.foldclosed(1)'), 1)

    -- Unfold
    child.lua([[require('mkdnflow.folds').unfoldSection()]])
    eq(child.lua_get('vim.fn.foldclosed(1)'), -1)

    -- Fold again
    child.lua([[require('mkdnflow.folds').foldSection()]])
    eq(child.lua_get('vim.fn.foldclosed(1)'), 1)
end

T['integration']['repeated fold/unfold does not stack folds (#162)'] = function()
    set_lines({ '# Heading', 'Content 1', 'Content 2', '# Next' })
    set_cursor(1, 0)

    for _ = 1, 5 do
        child.lua([[require('mkdnflow.folds').foldSection()]])
        eq(child.lua_get('vim.fn.foldclosed(1)'), 1)
        child.lua([[require('mkdnflow.folds').unfoldSection()]])
        eq(child.lua_get('vim.fn.foldclosed(1)'), -1)
    end

    -- After 5 cycles, foldlevel should still be 1 (not 5)
    eq(child.lua_get('vim.fn.foldlevel(1)'), 1)
    -- A single zd should fully remove the fold
    child.lua('vim.cmd("normal! zd")')
    eq(child.lua_get('vim.fn.foldlevel(1)'), 0)
end

T['integration']['re-fold after adding content covers new lines (#162)'] = function()
    set_lines({ '# Heading', 'Line 1', 'Line 2', '# Next' })
    set_cursor(1, 0)

    -- Create initial fold (lines 1-3)
    child.lua([[require('mkdnflow.folds').foldSection()]])
    eq(child.lua_get('vim.fn.foldclosedend(1)'), 3)

    -- Unfold and add lines inside the section
    child.lua([[require('mkdnflow.folds').unfoldSection()]])
    child.lua([[vim.api.nvim_buf_set_lines(0, 3, 3, false, {'New A', 'New B', 'New C'})]])
    -- Buffer is now: Heading, Line 1, Line 2, New A, New B, New C, # Next

    -- Re-fold: should cover the expanded section (lines 1-6), not the stale range (1-3)
    set_cursor(1, 0)
    child.lua([[require('mkdnflow.folds').foldSection()]])
    eq(child.lua_get('vim.fn.foldclosed(1)'), 1)
    eq(child.lua_get('vim.fn.foldclosedend(1)'), 6)

    -- Foldlevel should still be 1 (no stacking)
    eq(child.lua_get('vim.fn.foldlevel(1)'), 1)
end

T['integration']['nested headings fold correctly'] = function()
    set_lines({
        '# Main',
        '## Sub 1',
        'Content 1',
        '## Sub 2',
        'Content 2',
        '# Next Main',
    })
    set_cursor(1, 0)
    child.lua([[require('mkdnflow.folds').foldSection()]])
    -- Main section should include everything until Next Main
    local foldend = child.lua_get('vim.fn.foldclosedend(1)')
    eq(foldend, 5)
end

T['integration']['multiple independent folds'] = function()
    set_lines({ '# First', 'Content', '# Second', 'More' })

    -- Fold first section
    set_cursor(1, 0)
    child.lua([[require('mkdnflow.folds').foldSection()]])

    -- Fold second section
    set_cursor(3, 0)
    child.lua([[require('mkdnflow.folds').foldSection()]])

    -- Both should be folded
    eq(child.lua_get('vim.fn.foldclosed(1)'), 1)
    eq(child.lua_get('vim.fn.foldclosed(3)'), 3)
end

-- =============================================================================
-- Edge cases
-- =============================================================================
T['edge_cases'] = new_set()

T['edge_cases']['single line heading'] = function()
    set_lines({ '# Only Heading' })
    set_cursor(1, 0)
    -- Cannot create a fold with just one line in Neovim
    child.lua([[require('mkdnflow.folds').foldSection()]])
    local foldend = child.lua_get('vim.fn.foldclosedend(1)')
    eq(foldend, -1) -- No fold created
end

T['edge_cases']['heading at end of file'] = function()
    set_lines({ 'Some content', '# Last Heading', 'Final content' })
    set_cursor(2, 0)
    child.lua([[require('mkdnflow.folds').foldSection()]])
    -- Should fold to end of file
    local foldend = child.lua_get('vim.fn.foldclosedend(2)')
    eq(foldend, 3)
end

T['edge_cases']['empty lines between headings'] = function()
    set_lines({ '# First', '', '', '# Second' })
    set_cursor(1, 0)
    child.lua([[require('mkdnflow.folds').foldSection()]])
    -- Should include empty lines
    local foldend = child.lua_get('vim.fn.foldclosedend(1)')
    eq(foldend, 3)
end

T['edge_cases']['deep nesting levels'] = function()
    set_lines({
        '# H1',
        '## H2',
        '### H3',
        '#### H4',
        '##### H5',
        '###### H6',
        'Content',
        '# Next H1',
    })
    set_cursor(1, 0)
    child.lua([[require('mkdnflow.folds').foldSection()]])
    -- H1 should include all nested headings
    local foldend = child.lua_get('vim.fn.foldclosedend(1)')
    eq(foldend, 7)
end

T['edge_cases']['no headings in buffer'] = function()
    set_lines({ 'Just', 'regular', 'text' })
    set_cursor(1, 0)
    -- Should not error, should not create fold
    child.lua([[require('mkdnflow.folds').foldSection()]])
    local foldlevel = child.lua_get('vim.fn.foldlevel(1)')
    eq(foldlevel, 0)
end

T['edge_cases']['foldSection closes existing fold when inside one'] = function()
    set_lines({ '# Heading', 'Content' })
    set_cursor(1, 0)
    child.lua([[require('mkdnflow.folds').foldSection()]])
    -- Open the fold
    child.lua('vim.cmd.foldopen()')
    set_cursor(2, 0) -- Move to content inside fold
    -- Calling foldSection when inside an open fold should close it
    child.lua([[require('mkdnflow.folds').foldSection()]])
    -- Check if fold is closed
    local foldclosed = child.lua_get('vim.fn.foldclosed(1)')
    eq(foldclosed, 1)
end

-- Issue #254: foldSection should not error when foldmethod is not 'manual'
T['edge_cases']['foldSection handles non-manual foldmethod (#254)'] = function()
    set_lines({ '# Heading', 'Content line' })
    set_cursor(1, 0)
    -- Set foldmethod to something other than 'manual'
    child.lua([[vim.opt.foldmethod = 'indent']])
    -- This should not throw an error
    child.lua([[
        _G.test_ok, _G.test_err = pcall(function()
            require('mkdnflow.folds').foldSection()
        end)
    ]])
    local success = child.lua_get('_G.test_ok')
    if not success then
        local err = child.lua_get('tostring(_G.test_err)')
        if err:match('E350') or err:match('foldmethod') then
            error('Issue #254 reproduced: ' .. err)
        end
        error('foldSection failed: ' .. err)
    end
    eq(success, true)
end

return T
