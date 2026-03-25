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

-- Subcommand dispatcher for :Mkdnflow

local M = {}

--- Subcommand groups mapping group → array of {action, cmd, desc, complete?}
--- `cmd` is the name of the existing Mkdn* user command (dispatched via vim.cmd).
--- `_forceStart` is a sentinel handled specially (calls forceStart directly).
--- `_default` as an action name marks single-action groups where the group name IS the action.
---@type table<string, table[]>
local groups = {
    link = {
        { action = 'follow', cmd = 'MkdnFollowLink', desc = 'Follow link under cursor' },
        {
            action = 'create',
            cmd = 'MkdnCreateLink',
            desc = 'Create link from word or selection',
            complete = 'link_args',
        },
        {
            action = 'create-from-clipboard',
            cmd = 'MkdnCreateLinkFromClipboard',
            desc = 'Create link using clipboard URL',
            complete = 'link_args',
        },
        { action = 'destroy', cmd = 'MkdnDestroyLink', desc = 'Remove link formatting, keep text' },
        {
            action = 'footnote',
            cmd = 'MkdnCreateFootnote',
            desc = 'Create footnote reference and definition',
        },
        {
            action = 'renumber-footnotes',
            cmd = 'MkdnRenumberFootnotes',
            desc = 'Renumber footnotes sequentially',
        },
        {
            action = 'refresh-footnotes',
            cmd = 'MkdnRefreshFootnotes',
            desc = 'Refresh footnote numbering and consolidate',
        },
        {
            action = 'tag-span',
            cmd = 'MkdnTagSpan',
            desc = 'Wrap selection with span and generate ID',
        },
        {
            action = 'move-source',
            cmd = 'MkdnMoveSource',
            desc = 'Move link source file and update references',
        },
        {
            action = 'dead-links',
            cmd = 'MkdnDeadLinks',
            desc = 'Find dead links to non-existent files',
            complete = 'scope',
        },
    },
    nav = {
        { action = 'back', cmd = 'MkdnGoBack', desc = 'Go back to previous buffer' },
        { action = 'forward', cmd = 'MkdnGoForward', desc = 'Go forward to next buffer' },
        { action = 'next-link', cmd = 'MkdnNextLink', desc = 'Jump to next link' },
        { action = 'prev-link', cmd = 'MkdnPrevLink', desc = 'Jump to previous link' },
        { action = 'next-heading', cmd = 'MkdnNextHeading', desc = 'Jump to next heading' },
        { action = 'prev-heading', cmd = 'MkdnPrevHeading', desc = 'Jump to previous heading' },
        { action = 'next-heading-same', cmd = 'MkdnNextHeadingSame', desc = 'Jump to next heading of same level' },
        { action = 'prev-heading-same', cmd = 'MkdnPrevHeadingSame', desc = 'Jump to previous heading of same level' },
    },
    heading = {
        { action = 'increase', cmd = 'MkdnIncreaseHeading', desc = 'Increase heading level' },
        { action = 'decrease', cmd = 'MkdnDecreaseHeading', desc = 'Decrease heading level' },
        {
            action = 'increase-op',
            cmd = 'MkdnIncreaseHeadingOp',
            desc = 'Increase heading level (operator, dot-repeatable)',
        },
        {
            action = 'decrease-op',
            cmd = 'MkdnDecreaseHeadingOp',
            desc = 'Decrease heading level (operator, dot-repeatable)',
        },
    },
    todo = {
        { action = 'toggle', cmd = 'MkdnToggleToDo', desc = 'Toggle to-do item status' },
        { action = 'sort', cmd = 'MkdnSortToDoList', desc = 'Sort to-do list by status' },
    },
    list = {
        {
            action = 'new-item',
            cmd = 'MkdnNewListItem',
            desc = 'Create new list item (insert mode)',
        },
        {
            action = 'new-item-below',
            cmd = 'MkdnNewListItemBelowInsert',
            desc = 'Create list item below and enter insert mode',
        },
        {
            action = 'new-item-above',
            cmd = 'MkdnNewListItemAboveInsert',
            desc = 'Create list item above and enter insert mode',
        },
        { action = 'extend', cmd = 'MkdnExtendList', desc = 'Extend list with new item' },
        {
            action = 'update-numbering',
            cmd = 'MkdnUpdateNumbering',
            desc = 'Update numbering in ordered list',
        },
        {
            action = 'change-type',
            cmd = 'MkdnChangeListType',
            desc = 'Change list type (ul, ol, ultd, oltd)',
            complete = 'list_type',
        },
        {
            action = 'indent',
            cmd = 'MkdnIndentListItem',
            desc = 'Indent list item and update numbering',
        },
        {
            action = 'dedent',
            cmd = 'MkdnDedentListItem',
            desc = 'Dedent list item and update numbering',
        },
    },
    table = {
        { action = 'new', cmd = 'MkdnTable', desc = 'Create a new table (cols rows)' },
        { action = 'format', cmd = 'MkdnTableFormat', desc = 'Format table under cursor' },
        { action = 'next-cell', cmd = 'MkdnTableNextCell', desc = 'Jump to next table cell' },
        { action = 'prev-cell', cmd = 'MkdnTablePrevCell', desc = 'Jump to previous table cell' },
        { action = 'next-row', cmd = 'MkdnTableNextRow', desc = 'Jump to next table row' },
        { action = 'prev-row', cmd = 'MkdnTablePrevRow', desc = 'Jump to previous table row' },
        {
            action = 'new-row-below',
            cmd = 'MkdnTableNewRowBelow',
            desc = 'Insert table row below',
        },
        {
            action = 'new-row-above',
            cmd = 'MkdnTableNewRowAbove',
            desc = 'Insert table row above',
        },
        {
            action = 'new-col-after',
            cmd = 'MkdnTableNewColAfter',
            desc = 'Insert table column after',
        },
        {
            action = 'new-col-before',
            cmd = 'MkdnTableNewColBefore',
            desc = 'Insert table column before',
        },
        { action = 'delete-row', cmd = 'MkdnTableDeleteRow', desc = 'Delete current table row' },
        {
            action = 'delete-col',
            cmd = 'MkdnTableDeleteCol',
            desc = 'Delete current table column',
        },
        {
            action = 'cell-newline',
            cmd = 'MkdnTableCellNewLine',
            desc = 'Insert new line in table cell',
        },
        {
            action = 'align-left',
            cmd = 'MkdnTableAlignLeft',
            desc = 'Set column to left alignment',
        },
        {
            action = 'align-right',
            cmd = 'MkdnTableAlignRight',
            desc = 'Set column to right alignment',
        },
        {
            action = 'align-center',
            cmd = 'MkdnTableAlignCenter',
            desc = 'Set column to center alignment',
        },
        {
            action = 'align-default',
            cmd = 'MkdnTableAlignDefault',
            desc = 'Remove alignment from column',
        },
        {
            action = 'paste',
            cmd = 'MkdnTablePaste',
            desc = 'Paste clipboard data as markdown table',
        },
        {
            action = 'from-selection',
            cmd = 'MkdnTableFromSelection',
            desc = 'Convert selected data to markdown table',
        },
    },
    fold = {
        { action = 'fold', cmd = 'MkdnFoldSection', desc = 'Fold current section' },
        { action = 'unfold', cmd = 'MkdnUnfoldSection', desc = 'Unfold current section' },
    },
    yank = {
        {
            action = 'anchor-link',
            cmd = 'MkdnYankAnchorLink',
            desc = 'Yank heading as anchor link',
        },
        {
            action = 'file-anchor-link',
            cmd = 'MkdnYankFileAnchorLink',
            desc = 'Yank heading as full file anchor link',
        },
    },
    view = {
        {
            action = 'backlinks',
            cmd = 'MkdnBacklinks',
            desc = 'Toggle backlinks panel for current file',
        },
        {
            action = 'backlinks-refresh',
            cmd = 'MkdnBacklinksRefresh',
            desc = 'Refresh backlinks panel',
        },
    },
    start = {
        { action = '_default', cmd = '_forceStart', desc = 'Force-start Mkdnflow' },
    },
    config = {
        { action = 'clean', cmd = 'MkdnCleanConfig', desc = 'Show minimal optimized config' },
    },
    enter = {
        {
            action = '_default',
            cmd = 'MkdnEnter',
            desc = 'Follow link, toggle to-do, or create link',
        },
    },
    tab = {
        {
            action = '_default',
            cmd = 'MkdnTab',
            desc = 'Indent list item or jump to next table cell',
        },
    },
    ['shift-tab'] = {
        {
            action = '_default',
            cmd = 'MkdnSTab',
            desc = 'Dedent list item or jump to previous table cell',
        },
    },
}

--- Group descriptions for top-level help
local group_descriptions = {
    link = 'Link creation, following, and management',
    nav = 'Buffer and cursor navigation',
    heading = 'Heading level adjustment',
    todo = 'To-do list management',
    list = 'List item management',
    table = 'Table creation and formatting',
    fold = 'Section folding',
    yank = 'Yank formatted links',
    view = 'Panel views (backlinks, outline)',
    start = 'Force-start Mkdnflow on current buffer',
    config = 'Configuration utilities',
    enter = 'Multi-function enter key',
    tab = 'Indent / table cell navigation',
    ['shift-tab'] = 'Dedent / table cell navigation',
}

--- Sorted group names for stable ordering in help and completion
local sorted_group_names = (function()
    local names = {}
    for name, _ in pairs(groups) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end)()

--- Action-specific completion values
local completers = {
    style = function()
        return { 'markdown', 'wiki' }
    end,
    link_args = function()
        return { 'markdown', 'wiki', 'path', 'filename' }
    end,
    list_type = function()
        return { 'ul', 'ol', 'ultd', 'oltd' }
    end,
    scope = function()
        return { 'notebook' }
    end,
}

--- Filter a list of candidates by prefix
---@param candidates string[]
---@param prefix string
---@return string[]
local function filter(candidates, prefix)
    if not prefix or prefix == '' then
        return candidates
    end
    local results = {}
    for _, candidate in ipairs(candidates) do
        if candidate:sub(1, #prefix) == prefix then
            table.insert(results, candidate)
        end
    end
    return results
end

--- Find an action entry in a group by exact name, or return the _default entry
---@param group table[] Array of action entries
---@param action_name? string The action name to look up
---@return table? entry The matching entry, or nil
local function resolveAction(group, action_name)
    if not action_name then
        for _, entry in ipairs(group) do
            if entry.action == '_default' then
                return entry
            end
        end
        return nil
    end
    for _, entry in ipairs(group) do
        if entry.action == action_name then
            return entry
        end
    end
    return nil
end

--- Parse the subcommand arguments from a raw command line string.
--- Strips range prefix and command name, returns the argument tokens.
---@param cmd_line string Raw command line (e.g., "'<,'>Mkdnflow link create")
---@return string[] args The argument tokens after the command name
local function parseCmdlineArgs(cmd_line)
    -- Strip everything up to and including 'Mkdnflow', then split remaining on whitespace
    local after = cmd_line:match('[Mm]kdnflow%s+(.*)$')
    if not after or after == '' then
        return {}
    end
    local args = {}
    for token in after:gmatch('%S+') do
        table.insert(args, token)
    end
    return args
end

--- Display top-level help showing all groups
local function showTopHelp()
    local lines = { { 'Mkdnflow subcommands:\n', 'Title' } }
    -- Find max group name length for alignment
    local max_len = 0
    for _, name in ipairs(sorted_group_names) do
        if #name > max_len then
            max_len = #name
        end
    end
    for _, name in ipairs(sorted_group_names) do
        local padding = string.rep(' ', max_len - #name + 2)
        table.insert(lines, { '  ' .. name .. padding, 'Identifier' })
        table.insert(lines, { (group_descriptions[name] or '') .. '\n', 'Normal' })
    end
    table.insert(
        lines,
        { '\nUse :Mkdnflow <group> for actions. Use :Mkdnflow <group> <action> to run.\n', 'Comment' }
    )
    vim.api.nvim_echo(lines, true, {})
end

--- Display help for a specific group showing its actions
---@param group_name string
local function showGroupHelp(group_name)
    local group = groups[group_name]
    if not group then
        return
    end
    local lines = { { 'Mkdnflow ' .. group_name .. ':\n', 'Title' } }
    -- Find max action name length for alignment
    local max_len = 0
    for _, entry in ipairs(group) do
        if entry.action ~= '_default' and #entry.action > max_len then
            max_len = #entry.action
        end
    end
    -- Single-action groups: just show the description
    if #group == 1 and group[1].action == '_default' then
        table.insert(lines, { '  ' .. group[1].desc .. '\n', 'Normal' })
        table.insert(
            lines,
            { '  Usage: :Mkdnflow ' .. group_name .. '\n', 'Comment' }
        )
    else
        for _, entry in ipairs(group) do
            if entry.action ~= '_default' then
                local padding = string.rep(' ', max_len - #entry.action + 2)
                table.insert(lines, { '  ' .. entry.action .. padding, 'Identifier' })
                table.insert(lines, { entry.desc .. '\n', 'Normal' })
            end
        end
    end
    vim.api.nvim_echo(lines, true, {})
end

--- Handle the deprecated bare :Mkdnflow usage (no subcommand or unrecognized first arg).
--- Shows a deprecation warning and calls forceStart for backward compatibility.
---@param fargs string[] The raw arguments passed to the command
local function handleLegacy(fargs)
    vim.notify(
        "⬇️  ':Mkdnflow' for force-start is deprecated. Use ':Mkdnflow start' instead."
            .. " Run ':Mkdnflow' with no arguments to see available subcommands.",
        vim.log.levels.WARN
    )
    require('mkdnflow').forceStart(fargs)
end

--- Main dispatch function. Called by the :Mkdnflow user command.
---@param opts table Command callback opts (fargs, range, line1, line2, etc.)
M.dispatch = function(opts)
    local fargs = opts.fargs
    local group_name = fargs[1]

    -- No arguments: deprecation path (will become help display in v3)
    if not group_name or group_name == '' then
        handleLegacy(fargs)
        return
    end

    local group = groups[group_name]

    -- Unrecognized first arg: assume legacy forceStart usage (e.g., :Mkdnflow silent)
    if not group then
        handleLegacy(fargs)
        return
    end

    -- Resolve the action within the group
    local action_name = fargs[2]
    local entry = resolveAction(group, action_name)

    -- If no action matched and this is not a single-action group, show group help
    if not entry then
        if action_name then
            vim.notify(
                "⬇️  Unknown action '"
                    .. action_name
                    .. "' for group '"
                    .. group_name
                    .. "'. Run ':Mkdnflow "
                    .. group_name
                    .. "' to see available actions.",
                vim.log.levels.WARN
            )
        else
            showGroupHelp(group_name)
        end
        return
    end

    -- Special case: forceStart
    if entry.cmd == '_forceStart' then
        local remaining = { unpack(fargs, 2) }
        require('mkdnflow').forceStart(remaining)
        return
    end

    -- Build the underlying command string
    local cmd = entry.cmd
    -- Remaining args start after group + action (or just group for _default actions)
    local arg_start = entry.action == '_default' and 2 or 3
    local remaining = { unpack(fargs, arg_start) }
    local args_str = ''
    if #remaining > 0 then
        args_str = ' ' .. table.concat(remaining, ' ')
    end

    -- Execute with range if provided
    if opts.range > 0 then
        vim.cmd(opts.line1 .. ',' .. opts.line2 .. cmd .. args_str)
    else
        vim.cmd(cmd .. args_str)
    end
end

--- Tab completion function for :Mkdnflow.
---@param arg_lead string Current argument being completed
---@param cmd_line string Full command line text
---@param _ number Cursor position (unused)
---@return string[] completions
M.complete = function(arg_lead, cmd_line, _)
    local args = parseCmdlineArgs(cmd_line)
    local trailing_space = cmd_line:match('%s$') ~= nil

    -- Determine completion level based on parsed args and trailing space
    -- Level 1: completing group name
    -- Level 2: completing action name
    -- Level 3+: completing action arguments
    local level
    if #args == 0 then
        level = 1
    elseif #args == 1 and not trailing_space then
        level = 1
    elseif #args == 1 and trailing_space then
        level = 2
    elseif #args == 2 and not trailing_space then
        level = 2
    else
        level = 3
    end

    if level == 1 then
        return filter(sorted_group_names, arg_lead)
    end

    local group_name = args[1]
    local group = groups[group_name]
    if not group then
        return {}
    end

    if level == 2 then
        -- For single-action groups (_default), no action completion needed
        if #group == 1 and group[1].action == '_default' then
            return {}
        end
        local action_names = {}
        for _, entry in ipairs(group) do
            if entry.action ~= '_default' then
                table.insert(action_names, entry.action)
            end
        end
        return filter(action_names, arg_lead)
    end

    -- Level 3+: action-specific completions
    local action_name = args[2]
    if action_name then
        local entry = resolveAction(group, action_name)
        if entry and entry.complete and completers[entry.complete] then
            return filter(completers[entry.complete](), arg_lead)
        end
    end

    return {}
end

--- Expose internals for testing
M._groups = groups
M._parseCmdlineArgs = parseCmdlineArgs
M._resolveAction = resolveAction

return M
