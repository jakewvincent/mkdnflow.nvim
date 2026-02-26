-- tests/test_cmp.lua
-- Tests for nvim-cmp completion source functionality

local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local child = MiniTest.new_child_neovim()

-- Create a temporary directory structure for testing
local test_root = vim.fn.tempname()

--- Helper: set up mock cmp and mkdnflow with given config in the child process.
--- The test_root is passed so the child can set buffer name and initial_dir.
---@param config_overrides string Lua table literal for mkdnflow setup overrides
local function setup_cmp_child(config_overrides)
    child.restart({ '-u', 'scripts/minimal_init.lua' })
    child.lua('_G._test_root = "' .. test_root .. '"')
    child.lua([[
        -- Mock nvim-cmp so cmp.lua can be loaded without the real dependency.
        _G._registered_source = nil
        package.loaded['cmp'] = {
            lsp = {
                CompletionItemKind = { File = 17, Reference = 18 },
                MarkupKind = { Markdown = 'markdown' },
            },
            register_source = function(_, src)
                _G._registered_source = src
            end,
        }

        -- Set buffer to a file inside test_root so path resolution works
        vim.api.nvim_buf_set_name(0, _G._test_root .. '/current.md')
        vim.bo.filetype = 'markdown'

        require('mkdnflow').setup(]] .. config_overrides .. [[)
    ]])
end

--- Helper: call source:complete with '@' trigger and return the items.
--- Uses vim.wait to poll for the async callback to fire.
---@return table[] items
local function complete_items()
    child.lua([[
        _G._complete_items = nil
        local params = { context = { cursor_before_line = '@' } }
        _G._registered_source:complete(params, function(items)
            _G._complete_items = items
        end)
    ]])
    child.lua('vim.wait(2000, function() return _G._complete_items ~= nil end, 10)')
    return child.lua_get('_G._complete_items')
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
            vim.fn.mkdir(test_root .. '/another', 'p')

            -- Create test files with various extensions
            local files = {
                { test_root .. '/note1.md', '# Note 1\n\nFirst note.' },
                { test_root .. '/note2.md', '# Note 2\n\nSecond note.' },
                { test_root .. '/subdir/nested.md', '# Nested\n\nNested note.' },
                { test_root .. '/another/deep.md', '# Deep\n\nDeep note.' },
                { test_root .. '/report.rmd', '# Report\n\nR markdown.' },
                { test_root .. '/not-notebook.txt', 'Plain text file.' },
                { test_root .. '/subdir/script.lua', 'return {}' },
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
-- get_files_items: relative paths
-- =============================================================================
T['get_files_items'] = new_set()

T['get_files_items']['includes subdirectory in link path'] = function()
    setup_cmp_child([[{
        modules = { completion = true },
        links = { transform_on_create = false },
        silent = true,
    }]])
    local items = complete_items()
    local nested = find_item(items, 'nested')
    -- insertText should contain the relative path with subdirectory, not just basename
    eq(type(nested), 'table')
    eq(nested.insertText, '[nested](subdir/nested.md)')
end

T['get_files_items']['root-level file has no directory prefix'] = function()
    setup_cmp_child([[{
        modules = { completion = true },
        links = { transform_on_create = false },
        silent = true,
    }]])
    local items = complete_items()
    local note1 = find_item(items, 'note1')
    eq(type(note1), 'table')
    eq(note1.insertText, '[note1](note1.md)')
end

T['get_files_items']['does not apply transform_on_create to existing files'] = function()
    setup_cmp_child([[{
        modules = { completion = true },
        links = {
            transform_on_create = function(text)
                return 'TRANSFORMED_' .. text
            end,
        },
        silent = true,
    }]])
    local items = complete_items()
    local note1 = find_item(items, 'note1')
    eq(type(note1), 'table')
    -- The path should be the real filename, NOT 'TRANSFORMED_note1.md'
    eq(note1.insertText, '[note1](note1.md)')
end

T['get_files_items']['finds files in all subdirectories'] = function()
    setup_cmp_child([[{
        modules = { completion = true },
        links = { transform_on_create = false },
        silent = true,
    }]])
    local items = complete_items()
    -- Should find note1, note2, nested, deep (4 .md files) plus report (.rmd)
    local nested = find_item(items, 'nested')
    local deep = find_item(items, 'deep')
    eq(type(nested), 'table')
    eq(type(deep), 'table')
end

-- =============================================================================
-- get_files_items: notebook extensions
-- =============================================================================
T['notebook_extensions'] = new_set()

T['notebook_extensions']['includes rmd files by default'] = function()
    setup_cmp_child([[{
        modules = { completion = true },
        links = { transform_on_create = false },
        silent = true,
    }]])
    local items = complete_items()
    local report = find_item(items, 'report')
    eq(type(report), 'table')
    eq(report.insertText, '[report](report.rmd)')
end

T['notebook_extensions']['excludes non-notebook files'] = function()
    setup_cmp_child([[{
        modules = { completion = true },
        links = { transform_on_create = false },
        silent = true,
    }]])
    local items = complete_items()
    -- .txt and .lua files should not appear
    for _, item in ipairs(items) do
        eq(item.label ~= 'not-notebook', true)
        eq(item.label ~= 'script', true)
    end
end

T['notebook_extensions']['excludes rmd when disabled'] = function()
    setup_cmp_child([[{
        modules = { completion = true },
        filetypes = { markdown = true, rmd = false },
        links = { transform_on_create = false },
        silent = true,
    }]])
    local items = complete_items()
    local report = find_item(items, 'report')
    eq(report, nil)
end

-- =============================================================================
-- get_files_items: implicit_extension
-- =============================================================================
T['implicit_extension'] = new_set()

T['implicit_extension']['strips extension when implicit_extension is set'] = function()
    setup_cmp_child([[{
        modules = { completion = true },
        links = { transform_on_create = false, implicit_extension = 'md' },
        silent = true,
    }]])
    local items = complete_items()
    local note1 = find_item(items, 'note1')
    eq(type(note1), 'table')
    -- With implicit_extension, the path should have no extension
    eq(note1.insertText, '[note1](note1)')
end

T['implicit_extension']['strips extension from subdirectory paths'] = function()
    setup_cmp_child([[{
        modules = { completion = true },
        links = { transform_on_create = false, implicit_extension = 'md' },
        silent = true,
    }]])
    local items = complete_items()
    local nested = find_item(items, 'nested')
    eq(type(nested), 'table')
    eq(nested.insertText, '[nested](subdir/nested)')
end

T['implicit_extension']['keeps extension when implicit_extension is nil'] = function()
    setup_cmp_child([[{
        modules = { completion = true },
        links = { transform_on_create = false, implicit_extension = nil },
        silent = true,
    }]])
    local items = complete_items()
    local note1 = find_item(items, 'note1')
    eq(type(note1), 'table')
    eq(note1.insertText, '[note1](note1.md)')
end

-- =============================================================================
-- get_files_items: link style
-- =============================================================================
T['link_style'] = new_set()

T['link_style']['uses markdown style by default'] = function()
    setup_cmp_child([[{
        modules = { completion = true },
        links = { transform_on_create = false },
        silent = true,
    }]])
    local items = complete_items()
    local note1 = find_item(items, 'note1')
    eq(type(note1), 'table')
    eq(note1.insertText, '[note1](note1.md)')
end

T['link_style']['uses wiki style when configured'] = function()
    setup_cmp_child([[{
        modules = { completion = true },
        links = { style = 'wiki', transform_on_create = false },
        silent = true,
    }]])
    local items = complete_items()
    local note1 = find_item(items, 'note1')
    eq(type(note1), 'table')
    eq(note1.insertText, '[[note1.md|note1]]')
end

T['link_style']['wiki style includes subdirectory path'] = function()
    setup_cmp_child([[{
        modules = { completion = true },
        links = { style = 'wiki', transform_on_create = false },
        silent = true,
    }]])
    local items = complete_items()
    local nested = find_item(items, 'nested')
    eq(type(nested), 'table')
    eq(nested.insertText, '[[subdir/nested.md|nested]]')
end

T['link_style']['compact wiki style omits path'] = function()
    setup_cmp_child([[{
        modules = { completion = true },
        links = { style = 'wiki', compact = true, transform_on_create = false },
        silent = true,
    }]])
    local items = complete_items()
    local note1 = find_item(items, 'note1')
    eq(type(note1), 'table')
    eq(note1.insertText, '[[note1]]')
end

-- =============================================================================
-- get_files_items: base directory fallback
-- =============================================================================
T['base_directory'] = new_set()

T['base_directory']['falls back to initial_dir with default config'] = function()
    -- Default path_resolution.primary is 'first', so it should use initial_dir
    setup_cmp_child([[{
        modules = { completion = true },
        links = { transform_on_create = false },
        silent = true,
    }]])
    local items = complete_items()
    -- Should find files (proves the base directory was resolved correctly)
    local note1 = find_item(items, 'note1')
    eq(type(note1), 'table')
end

T['base_directory']['returns empty when scanning empty directory'] = function()
    local empty_dir = vim.fn.tempname()
    vim.fn.mkdir(empty_dir, 'p')

    child.restart({ '-u', 'scripts/minimal_init.lua' })
    child.lua('_G._empty_dir = "' .. empty_dir .. '"')
    child.lua([[
        _G._registered_source = nil
        package.loaded['cmp'] = {
            lsp = {
                CompletionItemKind = { File = 17, Reference = 18 },
                MarkupKind = { Markdown = 'markdown' },
            },
            register_source = function(_, src)
                _G._registered_source = src
            end,
        }
        vim.api.nvim_buf_set_name(0, _G._empty_dir .. '/test.md')
        vim.bo.filetype = 'markdown'
        require('mkdnflow').setup({
            modules = { completion = true },
            links = { transform_on_create = false },
            silent = true,
        })
    ]])
    -- complete_items() uses the test_root buffer name; call inline for empty_dir
    child.lua([[
        _G._complete_items = nil
        local params = { context = { cursor_before_line = '@' } }
        _G._registered_source:complete(params, function(items)
            _G._complete_items = items
        end)
    ]])
    child.lua('vim.wait(2000, function() return _G._complete_items ~= nil end, 10)')
    local items = child.lua_get('_G._complete_items')
    eq(#items, 0)

    vim.fn.delete(empty_dir, 'rf')
end

-- =============================================================================
-- get_files_items: documentation preview
-- =============================================================================
T['documentation'] = new_set()

T['documentation']['includes file preview in documentation'] = function()
    setup_cmp_child([[{
        modules = { completion = true },
        links = { transform_on_create = false },
        silent = true,
    }]])
    local items = complete_items()
    local note1 = find_item(items, 'note1')
    eq(type(note1), 'table')
    eq(type(note1.documentation), 'table')
    eq(note1.documentation.kind, 'markdown')
    -- Should contain the file's content
    eq(note1.documentation.value:match('# Note 1') ~= nil, true)
end

-- =============================================================================
-- source:complete trigger filtering
-- =============================================================================
T['trigger'] = new_set()

T['trigger']['returns empty without @ trigger'] = function()
    setup_cmp_child([[{
        modules = { completion = true },
        links = { transform_on_create = false },
        silent = true,
    }]])
    child.lua([[
        _G._complete_items = nil
        local params = { context = { cursor_before_line = 'no trigger here' } }
        _G._registered_source:complete(params, function(items)
            _G._complete_items = items
        end)
    ]])
    child.lua('vim.wait(2000, function() return _G._complete_items ~= nil end, 10)')
    local items = child.lua_get('_G._complete_items')
    eq(#items, 0)
end

-- =============================================================================
-- parse_bib (via source:complete) with mock cmp
-- =============================================================================
T['parse_bib'] = new_set({
    hooks = {
        pre_case = function()
            child.restart({ '-u', 'scripts/minimal_init.lua' })
            child.lua([[
                _G._registered_source = nil
                package.loaded['cmp'] = {
                    lsp = {
                        CompletionItemKind = { File = 17, Reference = 18 },
                        MarkupKind = { Markdown = 'markdown' },
                    },
                    register_source = function(_, src)
                        _G._registered_source = src
                    end,
                }
                vim.api.nvim_buf_set_name(0, 'test.md')
                vim.bo.filetype = 'markdown'
            ]])
        end,
    },
})

T['parse_bib']['nonexistent bib path does not error'] = function()
    child.lua([[
        require('mkdnflow').setup({
            modules = { bib = true, completion = true },
            bib = {
                default_path = '/tmp/nonexistent_' .. vim.fn.getpid() .. '.bib',
                find_in_root = false,
            },
            silent = true,
        })

        _G._complete_items = nil
        local params = { context = { cursor_before_line = '@cite' } }
        _G._complete_ok, _G._complete_err = pcall(function()
            _G._registered_source:complete(params, function(items)
                _G._complete_items = items
            end)
        end)
    ]])
    eq(child.lua_get('_G._complete_ok'), true)
    -- Wait for async callback to verify it completes without error
    child.lua('vim.wait(2000, function() return _G._complete_items ~= nil end, 10)')
end

-- =============================================================================
-- Integration with mkdnflow setup
-- =============================================================================
T['integration'] = new_set()

T['integration']['completion module can be enabled'] = function()
    child.restart({ '-u', 'scripts/minimal_init.lua' })
    child.lua([[
        _success = pcall(function()
            package.loaded['cmp'] = {
                lsp = {
                    CompletionItemKind = { File = 17, Reference = 18 },
                    MarkupKind = { Markdown = 'markdown' },
                },
                register_source = function() end,
            }
            vim.api.nvim_buf_set_name(0, 'test.md')
            vim.bo.filetype = 'markdown'
            require('mkdnflow').setup({
                modules = { completion = true },
                silent = true,
            })
        end)
    ]])
    eq(child.lua_get('_success'), true)
end

T['integration']['completion module disabled by default'] = function()
    child.restart({ '-u', 'scripts/minimal_init.lua' })
    child.lua([[
        vim.api.nvim_buf_set_name(0, 'test.md')
        vim.bo.filetype = 'markdown'
        require('mkdnflow').setup({ silent = true })
    ]])
    local enabled = child.lua_get('require("mkdnflow").config.modules.completion')
    eq(enabled, false)
end

-- =============================================================================
-- Footnote completions
-- =============================================================================

--- Helper: set buffer content in the child and call source:complete with a
--- footnote trigger. Returns the completion items.
---@param buffer_lines table Lines to set in the buffer
---@param trigger? string The cursor_before_line text (defaults to '[^')
---@return table[] items
local function complete_footnote_items(buffer_lines, trigger)
    trigger = trigger or '[^'
    child.lua('vim.api.nvim_buf_set_lines(0, 0, -1, false, ' .. vim.inspect(buffer_lines) .. ')')
    child.lua('_G._fn_trigger = ' .. vim.inspect(trigger))
    child.lua([[
        _G._complete_items = nil
        local params = { context = { cursor_before_line = _G._fn_trigger } }
        _G._registered_source:complete(params, function(items)
            _G._complete_items = items
        end)
    ]])
    child.lua('vim.wait(2000, function() return _G._complete_items ~= nil end, 10)')
    return child.lua_get('_G._complete_items')
end

T['footnote_completion'] = new_set({
    hooks = {
        pre_case = function()
            setup_cmp_child([[{
                modules = { completion = true },
                silent = true,
            }]])
        end,
    },
})

T['footnote_completion']['finds single footnote definition'] = function()
    local items = complete_footnote_items({
        'Some text[^1] here.',
        '',
        '[^1]: First footnote',
    }, 'text [^')
    eq(#items, 1)
    eq(items[1].label, '[^1]')
end

T['footnote_completion']['finds multiple footnote definitions'] = function()
    local items = complete_footnote_items({
        'Text[^1] and[^2] and[^myref].',
        '',
        '[^1]: First',
        '[^2]: Second',
        '[^myref]: Third',
    }, 'text [^')
    eq(#items, 3)
    eq(items[1].label, '[^1]')
    eq(items[2].label, '[^2]')
    eq(items[3].label, '[^myref]')
end

T['footnote_completion']['extracts content as documentation'] = function()
    local items = complete_footnote_items({
        'Text[^note].',
        '',
        '[^note]: This is the footnote content',
    }, 'text [^')
    eq(#items, 1)
    eq(items[1].documentation.kind, 'markdown')
    eq(items[1].documentation.value, 'This is the footnote content')
end

T['footnote_completion']['returns Reference kind'] = function()
    local items = complete_footnote_items({
        '[^1]: A footnote',
    }, 'text [^')
    eq(#items, 1)
    -- CompletionItemKind.Reference = 18 in our mock
    eq(items[1].kind, 18)
end

T['footnote_completion']['returns empty for buffer with no footnotes'] = function()
    local items = complete_footnote_items({
        '# Heading',
        '',
        'Just some regular text.',
    }, 'text [^')
    eq(#items, 0)
end

T['footnote_completion']['handles labels with hyphens and underscores'] = function()
    local items = complete_footnote_items({
        '[^my-note]: Hyphenated',
        '[^my_note]: Underscored',
    }, 'text [^')
    eq(#items, 2)
    eq(items[1].label, '[^my-note]')
    eq(items[2].label, '[^my_note]')
end

T['footnote_completion']['partial trigger is recognized'] = function()
    local items = complete_footnote_items({
        '[^foo]: Foo note',
        '[^bar]: Bar note',
    }, 'text [^fo')
    eq(#items, 2) -- All definitions returned; nvim-cmp handles filtering
end

T['footnote_completion']['@ trigger does not return footnote items'] = function()
    setup_cmp_child([[{
        modules = { completion = true },
        silent = true,
    }]])
    child.lua([[
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {
            '[^1]: A footnote definition',
        })
    ]])
    local items = complete_items()
    for _, item in ipairs(items) do
        eq(item.label ~= '[^1]', true)
    end
end

T['footnote_completion']['insertText omits leading bracket'] = function()
    local items = complete_footnote_items({
        '[^test]: Content',
    }, 'text [^')
    eq(#items, 1)
    eq(items[1].insertText, '^test]')
end

T['footnote_completion']['filterText omits leading bracket and closing bracket'] = function()
    local items = complete_footnote_items({
        '[^test]: Content',
    }, 'text [^')
    eq(#items, 1)
    eq(items[1].filterText, '^test')
end

T['footnote_completion']['no documentation when definition content is empty'] = function()
    local items = complete_footnote_items({
        '[^empty]: ',
    }, 'text [^')
    eq(#items, 1)
    eq(items[1].documentation == nil or items[1].documentation == vim.NIL, true)
end

T['footnote_completion']['definition with leading spaces'] = function()
    local items = complete_footnote_items({
        '   [^indented]: Indented definition',
    }, 'text [^')
    eq(#items, 1)
    eq(items[1].label, '[^indented]')
    eq(items[1].documentation.value, 'Indented definition')
end

-- =============================================================================
-- Footnote undefined reference completions (line-start trigger)
-- =============================================================================

T['footnote_undefined'] = new_set({
    hooks = {
        pre_case = function()
            setup_cmp_child([[{
                modules = { completion = true },
                silent = true,
            }]])
        end,
    },
})

T['footnote_undefined']['offers undefined refs at line start'] = function()
    local items = complete_footnote_items({
        'Text with[^1] and[^2] refs.',
    }, '[^')
    eq(#items, 2)
    eq(items[1].label, '[^1]')
    eq(items[2].label, '[^2]')
end

T['footnote_undefined']['does not offer defined labels at line start'] = function()
    local items = complete_footnote_items({
        'Text[^1] here.',
        '',
        '[^1]: Already defined',
    }, '[^')
    eq(#items, 0)
end

T['footnote_undefined']['still offers defined labels mid-line'] = function()
    local items = complete_footnote_items({
        'Text[^1] here.',
        '',
        '[^1]: Already defined',
    }, 'text [^')
    eq(#items, 1)
    eq(items[1].label, '[^1]')
end

T['footnote_undefined']['multiple undefined refs with one defined'] = function()
    local items = complete_footnote_items({
        'Text[^a] and[^b] and[^c].',
        '',
        '[^a]: Defined',
    }, '[^')
    eq(#items, 2)
    eq(items[1].label, '[^b]')
    eq(items[2].label, '[^c]')
end

T['footnote_undefined']['context preview shows source line'] = function()
    local items = complete_footnote_items({
        'Important claim here[^1].',
    }, '[^')
    eq(#items, 1)
    eq(items[1].documentation.value, 'Important claim here[^1].')
end

T['footnote_undefined']['context preview truncated for long lines'] = function()
    local long_line = string.rep('x', 90) .. '[^1]'
    local items = complete_footnote_items({
        long_line,
    }, '[^')
    eq(#items, 1)
    eq(string.sub(items[1].documentation.value, -3), '...')
    -- Truncated to 77 chars + '...' = 80
    eq(#items[1].documentation.value, 80)
end

T['footnote_undefined']['insertText includes definition syntax'] = function()
    local items = complete_footnote_items({
        'Text[^myref] here.',
    }, '[^')
    eq(#items, 1)
    eq(items[1].insertText, '^myref]: ')
end

T['footnote_undefined']['deduplicates multiple refs to same label'] = function()
    local items = complete_footnote_items({
        'First[^1] mention.',
        'Second[^1] mention.',
        'Third[^1] mention.',
    }, '[^')
    eq(#items, 1)
    eq(items[1].label, '[^1]')
end

T['footnote_undefined']['definition lines are skipped'] = function()
    -- [^b] only appears inside a definition line for [^a], not in the body
    local items = complete_footnote_items({
        'Text[^a] here.',
        '',
        '[^a]: See also [^b].',
    }, '[^')
    -- [^a] is defined, [^b] only appears in a definition line → empty
    eq(#items, 0)
end

T['footnote_undefined']['leading spaces in trigger'] = function()
    local items = complete_footnote_items({
        'Text[^1] here.',
    }, '   [^')
    eq(#items, 1)
    eq(items[1].label, '[^1]')
end

-- =============================================================================
-- Heading/anchor completions
-- =============================================================================

--- Helper: set buffer content in the child and call source:complete with a
--- heading anchor trigger. Returns the completion items.
---@param buffer_lines table Lines to set in the buffer
---@param trigger string The cursor_before_line text (e.g., '](#' or 'text ](#')
---@param after? string The cursor_after_line text (e.g., ')' for auto-pairs)
---@return table[] items
local function complete_heading_items(buffer_lines, trigger, after)
    child.lua('vim.api.nvim_buf_set_lines(0, 0, -1, false, ' .. vim.inspect(buffer_lines) .. ')')
    child.lua('_G._heading_trigger = ' .. vim.inspect(trigger))
    child.lua('_G._heading_after = ' .. vim.inspect(after or ''))
    child.lua([[
        _G._complete_items = nil
        local params = {
            context = {
                cursor_before_line = _G._heading_trigger,
                cursor_after_line = _G._heading_after,
                cursor = { line = 0, character = 0 },
            },
        }
        _G._registered_source:complete(params, function(items)
            _G._complete_items = items
        end)
    ]])
    child.lua('vim.wait(2000, function() return _G._complete_items ~= nil end, 10)')
    return child.lua_get('_G._complete_items')
end

T['heading_completion'] = new_set({
    hooks = {
        pre_case = function()
            setup_cmp_child([[{
                modules = { completion = true },
                silent = true,
            }]])
        end,
    },
})

T['heading_completion']['finds headings at different levels'] = function()
    local items = complete_heading_items({
        '# Top Level',
        '',
        '## Second Level',
        '',
        '### Third Level',
    }, '[text](#')
    eq(#items, 3)
    eq(items[1].label, 'Top Level')
    eq(items[1].detail, 'H1')
    eq(items[2].label, 'Second Level')
    eq(items[2].detail, 'H2')
    eq(items[3].label, 'Third Level')
    eq(items[3].detail, 'H3')
end

T['heading_completion']['generates correct anchor slugs'] = function()
    local items = complete_heading_items({
        '## My Cool Heading',
    }, '[text](#')
    eq(#items, 1)
    eq(items[1].insertText, '#my-cool-heading)')
end

T['heading_completion']['skips headings inside backtick code fences'] = function()
    local items = complete_heading_items({
        '## Real Heading',
        '',
        '```',
        '## Fenced Heading',
        '```',
        '',
        '## Another Real',
    }, '[text](#')
    eq(#items, 2)
    eq(items[1].label, 'Real Heading')
    eq(items[2].label, 'Another Real')
end

T['heading_completion']['skips headings inside tilde code fences'] = function()
    local items = complete_heading_items({
        '## Real Heading',
        '',
        '~~~',
        '## Tilde Fenced',
        '~~~',
    }, '[text](#')
    eq(#items, 1)
    eq(items[1].label, 'Real Heading')
end

T['heading_completion']['skips YAML frontmatter comments'] = function()
    local items = complete_heading_items({
        '---',
        '# Configuration',
        'title: My Doc',
        '---',
        '',
        '## Actual Heading',
    }, '[text](#')
    eq(#items, 1)
    eq(items[1].label, 'Actual Heading')
end

T['heading_completion']['collects context lines in documentation'] = function()
    local items = complete_heading_items({
        '## Introduction',
        '',
        'This is the first paragraph.',
        'And a second line.',
    }, '[text](#')
    eq(#items, 1)
    -- Documentation should contain heading + context
    local doc_value = items[1].documentation.value
    eq(doc_value:find('## Introduction') ~= nil, true)
    eq(doc_value:find('This is the first paragraph.') ~= nil, true)
    eq(doc_value:find('And a second line.') ~= nil, true)
end

T['heading_completion']['context stops at next heading'] = function()
    local items = complete_heading_items({
        '## First',
        'Content under first.',
        '## Second',
        'Content under second.',
    }, '[text](#')
    eq(#items, 2)
    -- First heading's doc should NOT contain "Content under second."
    local doc1 = items[1].documentation.value
    eq(doc1:find('Content under first.') ~= nil, true)
    eq(doc1:find('Content under second.') == nil, true)
end

T['heading_completion']['special characters produce correct anchor'] = function()
    local items = complete_heading_items({
        "## What's New in v2.0?",
    }, '[text](#')
    eq(#items, 1)
    -- Punctuation stripped, spaces → hyphens
    eq(items[1].insertText, '#whats-new-in-v20)')
end

T['heading_completion']['markdown with title: insertText has anchor + closing paren'] = function()
    local items = complete_heading_items({
        '## Target Heading',
    }, '[My Link](#')
    eq(#items, 1)
    eq(items[1].insertText, '#target-heading)')
end

T['heading_completion']['markdown without title: has additionalTextEdits'] = function()
    local items = complete_heading_items({
        '## Target Heading',
    }, '[](#')
    eq(#items, 1)
    eq(items[1].insertText, '#target-heading)')
    -- Should have additionalTextEdits to fill in the display text
    eq(items[1].additionalTextEdits ~= nil, true)
    eq(#items[1].additionalTextEdits, 1)
    eq(items[1].additionalTextEdits[1].newText, 'Target Heading')
end

T['heading_completion']['auto-pairs: omits closing paren when present'] = function()
    local items = complete_heading_items({
        '## Target Heading',
    }, '[My Link](#', ')')
    eq(#items, 1)
    -- Should NOT include ) since it's already after the cursor
    eq(items[1].insertText, '#target-heading')
end

T['heading_completion']['auto-pairs: includes closing paren when absent'] = function()
    local items = complete_heading_items({
        '## Target Heading',
    }, '[My Link](#', '')
    eq(#items, 1)
    eq(items[1].insertText, '#target-heading)')
end

T['heading_completion']['wiki-style trigger'] = function()
    local items = complete_heading_items({
        '## Wiki Heading',
    }, '[[#')
    eq(#items, 1)
    -- Non-compact: includes pipe and display text
    eq(items[1].insertText, '#wiki-heading|Wiki Heading]]')
end

T['heading_completion']['wiki-style auto-pairs: omits closing brackets'] = function()
    local items = complete_heading_items({
        '## Wiki Heading',
    }, '[[#', ']]')
    eq(#items, 1)
    eq(items[1].insertText, '#wiki-heading|Wiki Heading')
end

T['heading_completion']['wiki-style compact'] = function()
    setup_cmp_child([[{
        modules = { completion = true },
        links = { style = 'wiki', compact = true },
        silent = true,
    }]])
    local items = complete_heading_items({
        '## Compact Heading',
    }, '[[#')
    eq(#items, 1)
    eq(items[1].insertText, '#compact-heading]]')
end

T['heading_completion']['empty buffer returns no items'] = function()
    local items = complete_heading_items({
        'Just regular text, no headings.',
    }, '[text](#')
    eq(#items, 0)
end

T['heading_completion']['non-matching trigger returns no heading items'] = function()
    -- Bare # at line start (heading, not anchor trigger) — should not match
    child.lua([[
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { '## Some Heading' })
        _G._complete_items = nil
        local params = {
            context = {
                cursor_before_line = '# ',
                cursor_after_line = '',
                cursor = { line = 0, character = 0 },
            },
        }
        _G._registered_source:complete(params, function(items)
            _G._complete_items = items
        end)
    ]])
    child.lua('vim.wait(2000, function() return _G._complete_items ~= nil end, 10)')
    local items = child.lua_get('_G._complete_items')
    eq(#items, 0)
end

T['heading_completion']['filterText includes heading text and slug for fuzzy matching'] = function()
    local items = complete_heading_items({
        '## My Heading',
    }, '[text](#')
    eq(#items, 1)
    eq(items[1].filterText, '#My Heading my-heading')
end

T['heading_completion']['kind is Reference'] = function()
    local items = complete_heading_items({
        '## Test',
    }, '[text](#')
    eq(#items, 1)
    -- CompletionItemKind.Reference = 18 in our mock
    eq(items[1].kind, 18)
end

T['heading_completion']['partial typing after trigger still matches'] = function()
    local items = complete_heading_items({
        '## Alpha',
        '## Beta',
    }, '[text](#al')
    eq(#items, 2) -- All headings returned; nvim-cmp handles filtering
end

T['heading_completion']['cross-file pattern does not trigger heading completion'] = function()
    -- ](filename# should NOT trigger heading completions (only ](# does)
    child.lua([[
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { '## Some Heading' })
        _G._complete_items = nil
        local params = {
            context = {
                cursor_before_line = '[text](other-file#',
                cursor_after_line = '',
                cursor = { line = 0, character = 0 },
            },
        }
        _G._registered_source:complete(params, function(items)
            _G._complete_items = items
        end)
    ]])
    child.lua('vim.wait(2000, function() return _G._complete_items ~= nil end, 10)')
    local items = child.lua_get('_G._complete_items')
    eq(#items, 0)
end

return T
