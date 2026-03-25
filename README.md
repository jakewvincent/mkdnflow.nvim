<p align="center">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow-media/main/assets/logo/mkdnflow_logo_dark.png">
      <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow-media/main/assets/logo/mkdnflow_logo_light.png">
      <img alt="Black mkdnflow logo in light color mode and white logo in dark color mode" src="https://raw.githubusercontent.com/jakewvincent/mkdnflow-media/main/assets/logo/mkdnflow_logo_light.png">
    </picture>
</p>
<p align=center>
    <img src="https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white">
    <img src="https://img.shields.io/badge/Markdown-000000?style=for-the-badge&logo=markdown&logoColor=white">
    <img src="https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white">
</p>

### Contents

1. [🚀 Introduction](#-introduction)
2. [✨ Features](#-features)
3. [💾 Installation](#-installation)
4. [⚙️ Configuration](#-configuration)
5. [🛠️ Commands & mappings](#-commands-mappings)
6. [📚 API](#-api)
7. [🤝 Contributing](#-contributing)
8. [🔢 Version information](#-version-information)
9. [🔗 Related projects](#-related-projects)

## 🚀 Introduction

Mkdnflow is designed for the *fluent* navigation and management of
[markdown](https://markdownguide.org) documents and document collections
(notebooks, wikis, etc). It features numerous convenience functions that
make it easier to work within raw markdown documents or document collections:
link and reference handling ([🔗 Link and reference handling](#-link-and-reference-handling)), navigation
([🧭 Navigation](#-navigation)), table support ([📊 Table support](#-table-support)), list
([📝 List support](#-list-support)) and to-do list ([✅ To-do list support](#-to-do-list-support)) support, file
management ([📁 File management](#-file-management)), section folding ([🪗 Folding](#-folding)), and more.
Use it for notetaking, personal knowledge management, static website
building, and more. Most features are highly tweakable ([⚙️ Configuration](#-configuration)).

## ✨ Features

### 🧭 Navigation

#### Within-buffer navigation

- [x] Jump to links
- [x] Jump to section headings

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow-media/main/demos/navigation_dark.gif">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow-media/main/demos/navigation_light.gif">
  <img alt="In-buffer navigation demo" src="https://raw.githubusercontent.com/jakewvincent/mkdnflow-media/main/demos/navigation_light.gif">
</picture>

#### Within-notebook navigation

- [x] Link following
    - [x] Open markdown and other text filetypes in the current window
    - [x] Open other filetypes and URLs with your system's default application
- [x] Browser-like 'Back' and 'Forward' functionality
- [ ] Table of contents window

### 🔗 Link and reference handling

- [x] Link creation from a visual selection or the text under the cursor
- [x] Link destruction
- [x] Follow links to local paths and other Markdown files
- [x] Follow external links (open using default application)
- [x] Follow `.bib`-based references
    - [x] Open `url` or `doi` field in the default browser
    - [x] Open documents specified in `file` field
- [x] Implicit filetype extensions
- [x] Support for various link types
    - [x] Standard Markdown links (`[my page](my_page.md)`)
    - [x] Wiki links (direct `[[my page]]` or piped `[[my_page.md|my page]]`)
    - [x] Automatic links (`<https://my.page>`)
    - [x] Reference-style links (`[my page][1]` with `[1]: my_page.md`)
    - [x] Image links (`![alt text](image.png)`) — opened in system viewer
    - [x] Citations (`@citekey` or Pandoc-style `[@citekey]`)
    - [x] Footnotes (`[^1]` with `[^1]: Footnote text`)

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow-media/main/demos/links_dark.gif">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow-media/main/demos/links_light.gif">
  <img alt="Link lifecycle demo" src="https://raw.githubusercontent.com/jakewvincent/mkdnflow-media/main/demos/links_light.gif">
</picture>

### 📊 Table support

- [x] Table creation
- [x] Table extension (add rows and columns)
- [x] Table formatting
- [x] Pandoc grid table support
- [x] Column alignment (left, right, center)
- [x] Paste delimited data as a table
- [x] Import delimited file into a new table

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow-media/main/demos/tables_dark.gif">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow-media/main/demos/tables_light.gif">
  <img alt="Table workflow demo" src="https://raw.githubusercontent.com/jakewvincent/mkdnflow-media/main/demos/tables_light.gif">
</picture>

### 📝 List support

- [x] Automatic list extension
- [x] Sensible auto-indentation and auto-dedentation
- [x] Ordered list number updating

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow-media/main/demos/lists_dark.gif">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow-media/main/demos/lists_light.gif">
  <img alt="List management demo" src="https://raw.githubusercontent.com/jakewvincent/mkdnflow-media/main/demos/lists_light.gif">
</picture>

### ✅ To-do list support

- [x] Toggle to-do item status
- [x] Status propagation
- [x] To-do list sorting
- [x] Create to-do items from plain ordered or unordered list items
- [x] Customizable highlighting for to-do status markers and content

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow-media/main/demos/todo_dark.gif">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow-media/main/demos/todo_light.gif">
  <img alt="To-do list demo" src="https://raw.githubusercontent.com/jakewvincent/mkdnflow-media/main/demos/todo_light.gif">
</picture>

### 📁 File management

- [x] Simultaneous link and file renaming
- [x] As-needed directory creation

### 🪗 Folding

- [x] Section folding and fold toggling
- [x] Helpful indicators for folded section contents
    - [x] Section heading level
    - [x] Counts of Markdown objects (tables, lists, code blocks, etc.)
    - [x] Line and word counts
- [ ] YAML block folding

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow-media/main/demos/folding_dark.gif">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow-media/main/demos/folding_light.gif">
  <img alt="Section folding demo" src="https://raw.githubusercontent.com/jakewvincent/mkdnflow-media/main/demos/folding_light.gif">
</picture>

### 🔮 Completion

- [x] Path completion
- [x] Completion of bibliography items

### 🧩 YAML block parsing

- [x] Specify a bibliography file in YAML front matter

### 🖌️ Visual enhancements

- [x] Conceal markdown and wiki link syntax
- [ ] Extended link highlighting
    - [ ] Automatic links
    - [ ] Wiki links

## 💾 Installation

**Requirements**:

* Linux, macOS, or Windows
* Neovim >= 0.9.5 (tested on 0.9.5, 0.10.x, and stable)

Install Mkdnflow using your preferred package manager for Neovim. Once installed,
Mkdnflow is configured and initialized using a setup function.

<details>
<summary>Install with Lazy</summary>

```lua
require('lazy').setup({
    -- Your other plugins
    {
        'jakewvincent/mkdnflow.nvim',
        ft = { 'markdown', 'rmd' },  -- Add custom filetypes here if configured
        config = function()
            require('mkdnflow').setup({
                -- Your config
            })
        end
    }
    -- Your other plugins
})
```

</details>

<details>
<summary>Install with Vim-Plug</summary>

```vim
" Vim-Plug
Plug 'jakewvincent/mkdnflow.nvim'

" Include the setup function somewhere else in your init.vim file, or the
" plugin won't activate itself:
lua << EOF
require('mkdnflow').setup({
    -- Config goes here; leave blank for defaults
})
EOF
```

</details>

## ⚙️ Configuration

### ⚡ Quick start

Mkdnflow is configured and initialized using a setup function. To use
the default settings, pass no arguments or an empty table to the setup function:

```lua
{
    'jakewvincent/mkdnflow.nvim',
    config = function()
        require('mkdnflow').setup({})
    end
}
```

### 🔧 Advanced configuration and sample recipes

Most features are highly configurable. Study the default config first
and read the documentation for the configuration options below or in
the help files.

<details>
<summary>🔧 Complete default config</summary>

```lua
{
    modules = {
        bib = true,
        buffers = true,
        conceal = true,
        cursor = true,
        folds = true,
        foldtext = true,
        links = true,
        lists = true,
        maps = true,
        paths = true,
        tables = true,
        templates = true,
        to_do = true,
        yaml = false,
        completion = false,
    },
    create_dirs = true,
    silent = false,
    wrap = false,
    on_attach = false,
    path_resolution = {
        primary = 'first',
        fallback = 'current',
        root_marker = false,
        sync_cwd = false,
        update_on_navigate = true,
    },
    filetypes = {
        markdown = true,
        rmd = true,
    },
    foldtext = {
        object_count = true,
        object_count_icon_set = 'emoji',
        object_count_opts = function()
            return require('mkdnflow').foldtext.default_count_opts()
        end,
        line_count = true,
        line_percentage = true,
        word_count = false,
        title_transformer = function()
            return require('mkdnflow').foldtext.default_title_transformer
        end,
        fill_chars = {
            left_edge = '⢾⣿⣿',
            right_edge = '⣿⣿⡷',
            item_separator = ' · ',
            section_separator = ' ⣹⣿⣏ ',
            left_inside = ' ⣹',
            right_inside = '⣏ ',
            middle = '⣿',
        },
    },
    bib = {
        default_path = nil,
        find_in_root = true,
    },
    cursor = {
        jump_patterns = nil,
    },
    links = {
        style = 'markdown',
        compact = false,
        conceal = false,
        search_range = 0,
        implicit_extension = nil,
        transform_on_follow = false,
        transform_on_create = function(text)
            text = text:gsub('[ /]', '-')
            text = text:lower()
            text = os.date('%Y-%m-%d_') .. text
            return text
        end,
        transform_scope = 'path',
        auto_create = true,
        on_create_new = false,
    },
    new_file_template = {
        enabled = false,
        placeholders = {
            before = {
                title = 'link_title',
                date = 'os_date',
            },
            after = {},
        },
        template = '# {{ title }}',
    },
    to_do = {
        highlight = false,
        statuses = {
            not_started = {
                marker = ' ',
                highlight = {
                    marker = { link = 'Conceal' },
                    content = { link = 'Conceal' },
                },
                sort = { section = 2, position = 'top' },
                propagate = {
                    up = function(host_list)
                        local no_items_started = true
                        for _, item in ipairs(host_list.items) do
                            if item.status.name ~= 'not_started' then
                                no_items_started = false
                            end
                        end
                        if no_items_started then
                            return 'not_started'
                        else
                            return 'in_progress'
                        end
                    end,
                    down = function(child_list)
                        local target_statuses = {}
                        for _ = 1, #child_list.items, 1 do
                            table.insert(target_statuses, 'not_started')
                        end
                        return target_statuses
                    end,
                },
            },
            in_progress = {
                marker = '-',
                highlight = {
                    marker = { link = 'WarningMsg' },
                    content = { bold = true },
                },
                sort = { section = 1, position = 'bottom' },
                propagate = {
                    up = function(host_list)
                        return 'in_progress'
                    end,
                    down = function(child_list) end,
                },
            },
            complete = {
                marker = { 'X', 'x' },
                highlight = {
                    marker = { link = 'String' },
                    content = { link = 'Conceal' },
                },
                sort = { section = 3, position = 'top' },
                propagate = {
                    up = function(host_list)
                        local all_items_complete = true
                        for _, item in ipairs(host_list.items) do
                            if item.status.name ~= 'complete' then
                                all_items_complete = false
                            end
                        end
                        if all_items_complete then
                            return 'complete'
                        else
                            return 'in_progress'
                        end
                    end,
                    down = function(child_list)
                        local target_statuses = {}
                        for _ = 1, #child_list.items, 1 do
                            table.insert(target_statuses, 'complete')
                        end
                        return target_statuses
                    end,
                },
            },
        },
        status_order = { 'not_started', 'in_progress', 'complete' },
        status_propagation = {
            up = true,
            down = true,
        },
        sort = {
            on_status_change = false,
            recursive = false,
            cursor_behavior = {
                track = true,
            },
        },
    },
    tables = {
        type = 'pipe',
        trim_whitespace = true,
        format_on_move = true,
        auto_extend_rows = false,
        auto_extend_cols = false,
        style = {
            cell_padding = 1,
            separator_padding = 1,
            outer_pipes = true,
            apply_alignment = true,
        },
    },
    yaml = {
        bib = { override = false },
    },
    mappings = {
        MkdnEnter = { { 'n', 'v' }, '<CR>' },
        MkdnGoBack = { 'n', '<BS>' },
        MkdnGoForward = { 'n', '<Del>' },
        MkdnMoveSource = { 'n', '<F2>' },
        MkdnNextLink = { 'n', '<Tab>' },
        MkdnPrevLink = { 'n', '<S-Tab>' },
        MkdnFollowLink = false,
        MkdnDestroyLink = { 'n', '<M-CR>' },
        MkdnTagSpan = { 'v', '<M-CR>' },
        MkdnYankAnchorLink = { 'n', 'yaa' },
        MkdnYankFileAnchorLink = { 'n', 'yfa' },
        MkdnNextHeading = { 'n', ']]' },
        MkdnPrevHeading = { 'n', '[[' },
        MkdnIncreaseHeading = { { 'n', 'v' }, '+' },
        MkdnDecreaseHeading = { { 'n', 'v' }, '-' },
        MkdnIncreaseHeadingOp = { { 'n', 'v' }, 'g+' },
        MkdnDecreaseHeadingOp = { { 'n', 'v' }, 'g-' },
        MkdnToggleToDo = { { 'n', 'v' }, '<C-Space>' },
        MkdnNewListItem = false,
        MkdnNewListItemBelowInsert = { 'n', 'o' },
        MkdnNewListItemAboveInsert = { 'n', 'O' },
        MkdnExtendList = false,
        MkdnUpdateNumbering = { 'n', '<leader>nn' },
        MkdnTableNextCell = { 'i', '<Tab>' },
        MkdnTablePrevCell = { 'i', '<S-Tab>' },
        MkdnTableNextRow = false,
        MkdnTablePrevRow = { 'i', '<M-CR>' },
        MkdnTableNewRowBelow = { 'n', '<leader>ir' },
        MkdnTableNewRowAbove = { 'n', '<leader>iR' },
        MkdnTableNewColAfter = { 'n', '<leader>ic' },
        MkdnTableNewColBefore = { 'n', '<leader>iC' },
        MkdnTableDeleteRow = { 'n', '<leader>dr' },
        MkdnTableDeleteCol = { 'n', '<leader>dc' },
        MkdnFoldSection = { 'n', '<leader>f' },
        MkdnUnfoldSection = { 'n', '<leader>F' },
        MkdnTab = false,
        MkdnSTab = false,
        MkdnIndentListItem = { 'i', '<C-t>' },
        MkdnDedentListItem = { 'i', '<C-d>' },
        MkdnCreateLink = false,
        MkdnCreateLinkFromClipboard = { { 'n', 'v' }, '<leader>p' },
    },
}
```

</details>

#### 🎨 Configuration options

##### modules

```lua
require('mkdnflow').setup({
    modules = {
        bib = true,
        buffers = true,
        conceal = true,
        cursor = true,
        folds = true,
        foldtext = true,
        links = true,
        lists = true,
        maps = true,
        paths = true,
        tables = true,
        to_do = true,
        yaml = false,
        cmp = false,
    notebook = true,
    }
})
```

| Option | Type | Description |
| --- | --- | --- |
| `modules.bib` | `boolean` | **`true`** (default): `bib` module is enabled (required for parsing `.bib` files and following citations).<br>`false`: Disable `bib` module functionality. |
| `modules.buffers` | `boolean` | **`true`** (default): `buffers` module is enabled (required for backward and forward navigation through buffers).<br>`false`: Suppress `buffers` keybindings. Note: This is a core module and is always loaded internally because other modules depend on it. Setting this to `false` only disables its keybindings. |
| `modules.conceal` | `boolean` | **`true`** (default): `conceal` module is enabled (required if you wish to enable link concealing. This does not automatically enable conceal behavior; see `links.conceal`.)<br>`false`: Disable `conceal` module functionality. |
| `modules.cursor` | `boolean` | **`true`** (default): `cursor` module is enabled (required for cursor movements: jumping to links, headings, etc.).<br>`false`: Suppress `cursor` keybindings. Note: This is a core module and is always loaded internally because other modules depend on it. Setting this to `false` only disables its keybindings. |
| `modules.folds` | `boolean` | **`true`** (default): `folds` module is enabled (required for section folding).<br>`false`: Disable `folds` module functionality. |
| `modules.foldtext` | `boolean` | **`true`** (default): `foldtext` module is enabled (required for prettified foldtext).<br>`false`: Disable `foldtext` module functionality. |
| `modules.links` | `boolean` | **`true`** (default): `links` module is enabled (required for creating, destroying, and following links).<br>`false`: Suppress `links` keybindings. Note: This is a core module and is always loaded internally because other modules depend on it. Setting this to `false` only disables its keybindings. |
| `modules.lists` | `boolean` | **`true`** (default): `lists` module is enabled (required for working in and manipulating lists, etc.).<br>`false`: Disable `lists` module functionality. |
| `modules.to_do` | `boolean` | **`true`** (default): `to_do` module is enabled (required for manipulating to-do statuses/lists, toggling to-do items, to-do list sorting, etc.)<br>`false`: Disable `to_do` module functionality. |
| `modules.paths` | `boolean` | **`true`** (default): `paths` module is enabled (required for link interpretation, link following, etc.).<br>`false`: Suppress `paths` keybindings. Note: This is a core module and is always loaded internally because other modules depend on it. Setting this to `false` only disables its keybindings. |
| `modules.tables` | `boolean` | **`true`** (default): `tables` module is enabled (required for table management, navigation, formatting, etc.).<br>`false`: Disable `tables` module functionality. |
| `modules.templates` | `boolean` | **`true`** (default): `templates` module is enabled (required for new-file template formatting and injection when following links to non-existent files).<br>`false`: Disable `templates` module functionality. Template injection will be skipped even if `new_file_template.enabled` is `true`. |
| `modules.yaml` | `boolean` | `true`: `yaml` module is enabled (required for parsing yaml headers).<br>**`false`** (default): Disable `yaml` module functionality. |
| `modules.completion` | `boolean` | `true`: Completion module is enabled. Automatically registers with `nvim-cmp` if installed; `blink.cmp` users should also set this to `true` (see completion setup below).<br>**`false`** (default): Disable completion module functionality. |
| `modules.notebook` | `boolean` | **`true`** (default): `notebook` module is enabled. Provides shared cross-file primitives for scanning notebook files, headings, and links. This module has zero cost at load time (no autocommands, keymaps, or side effects) and serves as infrastructure for other features.<br>`false`: Disable `notebook` module functionality. |
| `modules.backlinks` | `boolean` | **`true`** (default): `backlinks` module is enabled. Provides a side panel showing all files in the notebook that link to the current file. Requires the `notebook` module.<br>`false`: Disable `backlinks` module functionality. |

##### create_dirs

```lua
require('mkdnflow').setup({
    create_dirs = true,
})
```

| Option | Type | Description |
| --- | --- | --- |
| `create_dirs` | `boolean` | **`true`** (default): Directories referenced in a link will be (recursively) created if they do not exist.<br>`false`: No action will be taken when directories referenced in a link do not exist. Neovim will open a new file, but you will get an error when you attempt to write the file. |

##### path_resolution

```lua
require('mkdnflow').setup({
    path_resolution = {
        primary = 'first',
        fallback = 'current',
        root_marker = false,
        sync_cwd = false,
        update_on_navigate = false,
    },
})
```

| Option | Type | Description |
| --- | --- | --- |
| `path_resolution.primary` | `string` | **`'first'`** (default): Links will be interpreted relative to the first-opened file (when the current instance of Neovim was started).<br>`'current'`: Links will always be interpreted relative to the current file.<br>`'root'`: Links will be always interpreted relative to the root directory of the current notebook (requires `path_resolution.root_marker` to be specified).<br>Previously named `perspective.priority`. |
| `path_resolution.fallback` | `string` | `'first'`: Links will be resolved relative to the first-opened file.<br>**`'current'`** (default): Links will be resolved relative to the current file.<br>The fallback strategy is used when the primary strategy cannot resolve a path (e.g. when `primary` is `'root'` but no root marker is found). Since `'root'` cannot fall back to itself, only `'first'` and `'current'` are valid here. |
| `path_resolution.root_marker` | `string` \| `boolean` | **`false`** (default): The plugin does not look for the notebook root.<br>`string`: The name of a file (not a full path) by which a notebook's root directory can be identified. For instance, `'.root'` or `'index.md'`.<br>Previously named `perspective.root_tell`. |
| `path_resolution.sync_cwd` | `boolean` | `true`: Changes in path resolution will be reflected in the nvim working directory. (In other words, the working directory will sync with the plugin's path resolution.) This helps ensure (at least) that path completions (if using a completion plugin with support for paths) will be accurate and usable.<br>**`false`** (default): Neovim's working directory will not be affected by Mkdnflow.<br>Previously named `perspective.nvim_wd_heel`. |
| `path_resolution.update_on_navigate` | `boolean` | `true`: Path resolution will be updated when following a link to a file in a separate notebook/wiki (or navigating backwards to a file in another notebook/wiki).<br>**`false`** (default): Path resolution will be not updated when following a link to a file in a separate notebook/wiki. (Links in the file in the separate notebook/wiki will be interpreted relative to the original notebook/wiki.)<br>Previously named `perspective.update`. |

##### filetypes

```lua
require('mkdnflow').setup({
    filetypes = {
        markdown = true,
        rmd = true,
    },
})
```

| Option | Type | Description |
| --- | --- | --- |
| `filetypes.markdown` | `boolean` | **`true`** (default): The plugin activates for files with the `markdown` filetype (includes `.md`, `.markdown`, `.mkd`, `.mkdn`, `.mdwn`, `.mdown` extensions).<br>`false`: The plugin does not activate for markdown files. |
| `filetypes.rmd` | `boolean` | **`true`** (default): The plugin activates for files with the `rmd` filetype (`.rmd` extension).<br>`false`: The plugin does not activate for R Markdown files. |
| `filetypes.<name>` | `boolean` \| `string` | Custom filetype/extension configuration:<br><br>- `true`: If Neovim recognizes this as an extension (e.g., `md`), the detected filetype is used. Otherwise, the extension is auto-registered as its own filetype (e.g., `wiki = true` registers `.wiki` files as filetype `wiki`).<br>- `'filetype'` (string): Register this extension as the specified filetype. Example: `txt = 'markdown'` makes `.txt` files activate mkdnflow and be treated as markdown.<br>- `false`: Disable for this filetype/extension.<br><br>Note: Old extension-based configs (e.g., `md = true`) are automatically migrated to filetype-based configs (e.g., `markdown = true`).<br><br>Examples:<br>```lua<br>filetypes = {<br>    markdown = true,      -- Standard (default)<br>    rmd = true,           -- Standard (default)<br>    wiki = true,          -- Auto-register .wiki as 'wiki' filetype<br>    txt = 'markdown',     -- Treat .txt files as markdown<br>}<br>``` |

> [!NOTE]
> Mkdnflow activates based on Neovim's filetype detection, not file extensions.
> This means files with modelines like `vim: ft=markdown` will activate the plugin
> regardless of their extension.
>
> **Lazy loading note**: If you use a plugin manager with lazy loading (e.g., `ft = { 'markdown' }`)
> and configure custom extensions like `wiki = true`, you must add those filetypes
> to your lazy loading configuration (e.g., `ft = { 'markdown', 'wiki' }`), since the
> plugin won't load until it sees a matching filetype.

##### wrap

```lua
require('mkdnflow').setup({
    wrap = false,
})
```

| Option | Type | Description |
| --- | --- | --- |
| `wrap` | `boolean` | `true`: When jumping to next/previous links or headings, the cursor will continue searching at the beginning/end of the file.<br>**`false`** (default): When jumping to next/previous links or headings, the cursor will stop searching at the end/beginning of the file. |

##### bib

```lua
require('mkdnflow').setup({
    bib = {
        default_path = nil,
        find_in_root = true,
    },
})
```

| Option | Type | Description |
| --- | --- | --- |
| `bib.default_path` | `string` \| `nil` | **`nil`** (default): No default/fallback bib file will be used to search for citation keys.<br>`string`: A path to a default .bib file to look for citation keys in when attempting to follow a reference. The path need not be in the root directory of the notebook. |
| `bib.find_in_root` | `boolean` | **`true`** (default): When `path_resolution.primary` is also set to `root` (and a root directory was found), the plugin will search for bib files to reference in the notebook's top-level directory. If `bib.default_path` is also specified, the default path will be added to the list of bib files found in the top-level directory so that it will also be searched.<br>`false`: The notebook's root directory will not be searched for bib files. |

##### silent

```lua
require('mkdnflow').setup({
    silent = false,
})
```

| Option | Type | Description |
| --- | --- | --- |
| `silent` | `boolean` | `true`: The plugin will not display any messages in the console except compatibility warnings related to your config.<br>**`false`** (default): The plugin will display messages to the console. |

##### cursor

```lua
require('mkdnflow').setup({
    cursor = {
        jump_patterns = nil,
    },
})
```

| Option | Type | Description |
| --- | --- | --- |
| `cursor.jump_patterns` | `table` \| `nil` | **`nil`** (default): Cursor jumping (`MkdnNextLink`/`MkdnPrevLink`) uses detection-based link finding, which reuses the same link detection system as `followLink()`. All recognized link types (markdown links, wiki links, auto links, reference links, citations, footnote refs with definitions) are automatically jumped to based on the configured `links.style`. Links inside fenced code blocks and inline code spans are skipped.<br>`table`: A table of additional Lua regex patterns to jump to alongside detected links. Useful for non-link targets like `TODO` markers (e.g. `{ 'TODO', 'FIXME' }`).<br>`{}` (empty table): No extra patterns; only detected links are jumped to (same as `nil`). |
| `cursor.yank_register` | `string` | **`'"'`** (default): Anchor links are yanked to the unnamed register.<br>`'+'`: Yank to the system clipboard.<br>`'<any register>'`: Yank to any valid Vim register (e.g. `'a'`, `'*'`, `'0'`). |

##### links

```lua
require('mkdnflow').setup({
    links = {
        style = 'markdown',
        compact = false,
        conceal = false,
        search_range = 0,
        implicit_extension = nil,
        transform_on_follow = false,
        transform_on_create = function(text)
            text = text:gsub(" ", "-")
            text = text:lower()
            text = os.date('%Y-%m-%d_') .. text
            return(text)
        end,
        auto_create = true,
        on_create_new = false,
    },
})
```

| Option | Type | Description |
| --- | --- | --- |
| `links.style` | `string` | **`'markdown'`** (default): Links will be expected in the standard markdown format: `[<title>](<source>)`<br>`'wiki'`: Links will be expected in the unofficial wiki-link style, specifically the title-after-pipe format: `[[<source>\|<title>]]`.<br>This sets the default style for link creation. To create links in both styles, you can override the style per-call via `:MkdnCreateLink wiki` (or `markdown`), or via the Lua API: `createLink({ style = 'wiki' })`. See 'custom-mappings-on-attach' for an example. |
| `links.compact` | `boolean` | `true`: Wiki-style links will be created with the source and name being the same (e.g. `[[Link]]` will display as "Link" and go to a file named "Link.md").<br>**`false`** (default): Wiki-style links will be created with separate name and source (e.g. `[[link-to-source\|Link]]` will display as "Link" and go to a file named "link-to-source.md").<br>Previously named `links.name_is_source`. |
| `links.conceal` | `boolean` | `true`: Link sources and delimiters will be concealed (depending on which link style is selected).<br>**`false`** (default): Link sources and delimiters will not be concealed by mkdnflow. |
| `links.ref_hint` | `boolean` | `true`: When the cursor is on a reference-style link (`[text][ref]` or `[label]`), the resolved URL is shown as virtual text at the end of the line. When the cursor is on a reference definition line (`[ref]: url`), a usage count is shown instead. The virtual text uses the `MkdnflowRefHint` highlight group, which is linked to `Comment` by default. To customize its appearance, override the highlight group, e.g. `vim.api.nvim_set_hl(0, 'MkdnflowRefHint', { fg = '#88aaff', italic = true })`.<br>**`false`** (default): No virtual text hints for reference links. |
| `links.search_range` | `integer` | When following or jumping to links, consider `n` lines before and after a given line (useful if you ever permit links to be interrupted by a hard line break). Default: **`0`**.<br>Previously named `links.context`. |
| `links.implicit_extension` | `string` | A string that instructs the plugin (a) how to interpret links to files that do not have an extension, and (b) how to create new links from the text under the cursor or text selection.<br><br>**`nil`** (default): Extensions will be explicit when a link is created and must be explicit in any notebook link.<br>`'<any extension>'` (e.g. `'md'`): Links without an extension (e.g. `[Homepage](index)`) will be interpreted with the implicit extension (e.g. `index.md`), and new links will be created without an extension. |
| `links.transform_on_create` | `fun(string): string` \| `boolean` | `false`: No transformations are applied to the text to be turned into the name of the link source/path.<br>**`fun(string): string`** (default): A function that transforms the text to be inserted as the source/path of a link when a link is created. Anchor links are not currently customizable. For an example, see the sample recipes beneath this table.<br>Previously named `links.transform_explicit`. |
| `links.transform_scope` | `string` | Controls which part of the link text is passed to `transform_on_create` when the text contains `/`.<br>**`'path'`** (default): The entire text (including directory components) is passed to `transform_on_create`. For example, `work/with/dirs` is transformed as a single string, and the default transform produces `2026-02-15_work-with-dirs.md`.<br>`'filename'`: Only the filename portion (after the last `/`) is passed to `transform_on_create`; the directory prefix is preserved. For example, `work/with/dirs` becomes `work/with/2026-02-15_dirs.md`.<br>If the text contains no `/`, both modes behave identically.<br>Can be overridden per-call via the Lua API: `createLink({ transform_scope = 'filename' })`, or via command argument: `:MkdnCreateLink filename`. |
| `links.transform_on_follow` | `fun(string): string` \| `boolean` | **`false`** (default): Do not perform any transformations on the link's source when following.<br>`fun(string): string`: A function that transforms the path of a link immediately before interpretation. It does not transform the actual text in the buffer but can be used to modify link interpretation. For an example, see the sample recipe below.<br>Previously named `links.transform_implicit`. |
| `links.auto_create` | `boolean` | **`true`** (default): Try to create a link from the text under the cursor if there is no link under the cursor to follow.<br>`false`: Do nothing if trying to follow a link and a link can't be found under the cursor.<br>Previously named `links.create_on_follow_failure`. |
| `links.on_create_new` | `false` \| `fun(string, string\|nil): string\|nil` | A callback invoked when following a link to a file that does not yet exist,<br>allowing file creation to be delegated to an external tool (e.g. `zk`,<br>Obsidian CLI, a custom script). This callback is only invoked when the target<br>file does not yet exist. Following a link to an existing file bypasses this<br>callback entirely.<br><br>The function receives two arguments: the full resolved path (with extension)<br>that mkdnflow would create, and the link's display text (which may be `nil`).<br><br>It should return a `string` (file path for mkdnflow to open) or `nil` (if the<br>callback handled everything). If a path is returned and the file exists there,<br>mkdnflow opens it directly (skipping template injection). If the file does not<br>exist at the returned path, mkdnflow runs its normal creation flow.<br><br>**`false`** (default): Use mkdnflow's built-in file creation. |
| `links.edit_dirs` | `boolean` \| `fun(path: string)` | Controls what happens when you follow a link that points to a directory<br>rather than a file. This is useful when your notebook has subdirectories<br>that you link to (e.g. `[recipes](recipes/)`) and you want your preferred<br>file browser plugin to handle them instead of the default filename prompt.<br><br>**`false`** (default): Prompt the user to type a filename within the directory.<br><br>`true`: Run `:edit` on the directory, which triggers whatever<br>directory-browsing plugin you have installed (netrw, oil.nvim, etc.).<br><br>`fun(path: string)`: Call the supplied function with the absolute<br>directory path. The return value is ignored. This is useful for file<br>browsers that don't hook into `:edit` and need their own API call.<br><br>In all non-default modes, the buffer stack is updated before the<br>directory is opened, so `MkdnGoBack` will return you to the previous<br>file.<br><br>Example:<br>```lua<br>-- Open directories with mini.files<br>links = {<br>    edit_dirs = require('mini.files').open,<br>}<br>``` |
| `links.uri_handlers` | `table<string, fun(uri: string, scheme: string, path: string, anchor: string\|nil)\|'system'>` | A table of custom URI scheme handlers, keyed by scheme name (without `://`).<br>When following a link whose path starts with `<scheme>://`, the registered<br>handler is called instead of the normal path classification. This is useful<br>for custom protocols like `phd://`, `zotero://`, `obsidian://`, etc.<br><br>Each value can be:<br><br>- A **function** `fun(uri, scheme, path, anchor)` receiving the full URI<br>  (with anchor reattached), the scheme name, the path (without anchor), and<br>  the anchor (e.g. `'#section'`) or `nil`. The function has full control<br>  over what happens when the link is followed.<br>- The string **`'system'`** to open the URI with the OS default handler<br>  (same as how `http://` URLs are opened).<br><br>Standard schemes like `http` and `https` can also be overridden by<br>registering a handler for them.<br><br>**`{}`** (default): No custom URI scheme handlers are registered.<br><br>Example:<br>```lua<br>links = {<br>    uri_handlers = {<br>        phd = function(uri, scheme, path, anchor)<br>            vim.fn.jobstart({ 'xdg-open', uri }, { detach = true })<br>        end,<br>        zotero = 'system',<br>    },<br>}<br>``` |

<details>
<summary>Sample links recipes</summary>

```lua
require('mkdnflow').setup({
    links = {
        -- If you want all link paths to be explicitly prefixed with the year
        -- and for the path to be converted to uppercase:
        transform_on_create = function(input)
            return(string.upper(os.date('%Y-')..input))
        end,
        -- Link paths that match a date pattern can be opened in a `journals`
        -- subdirectory of your notebook, and all others can be opened in a
        -- `pages` subdirectory:
        transform_on_follow = function(input)
            if input:match('%d%d%d%d%-%d%d%-%d%d') then
                return('journals/'..input)
            else
                return('pages/'..input)
            end
        end
    }
})
```

**Delegate new-file creation to [zk](https://github.com/zk-org/zk):**

```lua
require('mkdnflow').setup({
    links = {
        on_create_new = function(path, title)
            -- Let zk create the note with its own templates and ID scheme.
            -- `zk new` prints the created path to stdout.
            local dir = vim.fn.fnamemodify(path, ':h')
            local cmd = { 'zk', 'new', '--no-input', '--print-path', dir }
            if title then
                table.insert(cmd, '--title')
                table.insert(cmd, title)
            end
            local result = vim.fn.system(cmd)
            local new_path = vim.trim(result)
            if vim.v.shell_error ~= 0 then
                vim.notify('zk new failed: ' .. result, vim.log.levels.ERROR)
                return nil
            end
            return new_path  -- mkdnflow opens the zk-created file
        end,
    },
})
```

</details>

##### new_file_template

```lua
require('mkdnflow').setup({
    new_file_template = {
        enabled = false,
        placeholders = {
            before = { title = 'link_title', date = 'os_date' },
            after = {},
        },
        template = '# {{ title }}',
    },
})
```

| Option | Type | Description |
| --- | --- | --- |
| `new_file_template.enabled` | `boolean` | `true`: Use the new-file template when opening a new file by following a link.<br>**`false`** (default): Don't use the new-file template when opening a new file by following a link.<br>Previously named `new_file_template.use_template`. |
| `new_file_template.placeholders` | `table<string, string\|fun(ctx: table): string>` | A flat table whose keys are placeholder names mapped to one of:<br><br>- A **function** `fun(ctx): string` — called with a context table containing all resolved built-in values. Available fields in `ctx`:<br>  - `link_title` — the display text of the link under the cursor, or `''`<br>  - `os_date` — today's date as `YYYY-MM-DD`<br>  - `source_file` — basename of the source file (e.g. `'index.md'`)<br>  - `filename` — stem of the new file being created, without extension (e.g. `'my-page'`)<br>  - `heading_context` — text of the nearest heading above the cursor (without `#` prefix), or `''`<br>- A **magic string shorthand** — one of `'link_title'` or `'os_date'`, which resolves to the corresponding `ctx` value.<br>- A **plain string literal** — used as-is (e.g., `author = 'Jake'`).<br><br>All placeholders are resolved in a single pass before the new buffer is opened.<br><br>Default: `{ title = 'link_title', date = 'os_date' }`<br><br>**Deprecated:** The old nested format `{ before = {...}, after = {} }` is auto-migrated to this flat format. `placeholders.after` entries are merged in but all placeholders now resolve before the buffer switch. |
| `new_file_template.template` | `string` | A string, optionally containing placeholder names, that will be inserted into a new file. Default: `'# {{ title }}'` |

##### to_do

```lua
require('mkdnflow').setup({
    to_do = {
        highlight = false,
        statuses = {
            not_started = { marker = ' ', ... },
            in_progress = { marker = '-', ... },
            complete = { marker = { 'X', 'x' }, ... },
        },
        status_order = { 'not_started', 'in_progress', 'complete' },
        status_propagation = { up = true, down = true },
        sort = {
            on_status_change = false,
            recursive = false,
            cursor_behavior = { track = true },
        },
    },
})
```

| Option | Type | Description |
| --- | --- | --- |
| `to_do.create_on_toggle` | `boolean` | **`true`** (default): When toggling a line that is not already a to-do item, convert it into one (adding a checkbox to plain list items or wrapping plain text in `- [ ] `).<br>`false`: Only rotate the status of existing to-do items. Lines without a checkbox are left unchanged. This is useful when mapping `MkdnToggleToDo` to a key like `<CR>` alongside other context-sensitive actions — the command becomes a no-op on non-to-do lines, allowing subsequent actions to fire instead. |
| `to_do.highlight` | `boolean` | `true`: Apply highlighting to to-do status markers and/or content (as defined in `to_do.statuses[*].highlight`).<br>**`false`** (default): Do not apply any highlighting. |
| `to_do.status_propagation.up` | `boolean` | **`true`** (default): Update ancestor statuses (recursively) when a descendant status is changed or when a new to-do item is added to a list (e.g. a completed parent reverts to in-progress when a new uncompleted child is added). Updated according to logic provided in `to_do.statuses[*].propagate.up`.<br>`false`: Ancestor statuses are not affected by descendant status changes or new item creation. |
| `to_do.status_propagation.down` | `boolean` | **`true`** (default): Update descendant statuses (recursively) when an ancestor's status is changed. Updated according to logic provided in `to_do.statuses[*].propagate.down`.<br>`false`: Descendant statuses are not affected by ancestor status changes. |
| `to_do.sort_on_status_change` | `boolean` | `true`: Sort a to-do list when an item's status is changed.<br>**`false`** (default): Leave all to-do items in their current position when an item's status is changed.<br>Note: This will not apply if the to-do item's status is changed manually (i.e. by typing or pasting in the status marker). |
| `to_do.sort.recursive` | `boolean` | `true`: `sort_on_status_change` applies recursively, sorting the host list of each successive parent until the root of the list is reached.<br>**`false`** (default): `sort_on_status_change` only applies at the current to-do list level (not to the host list of the parent to-do item). |
| `to_do.sort.cursor_behavior.track` | `boolean` | **`true`** (default): Move the cursor so that it remains on the same to-do item, even after a to-do list sort relocates the item.<br>`false`: The cursor remains on its current line number, even if the to-do item is relocated by sorting. |
| `to_do.statuses` | `table` (dict-like) | A dictionary of to-do statuses, keyed by status name (e.g. `'not_started'`, `'in_progress'`, `'complete'`). Each value is a table with the options described in the following rows. An arbitrary number of statuses can be defined. Users can partially override individual statuses — for example, overriding just the highlight of `not_started` while keeping all other defaults. See default statuses in the settings table. |
| `to_do.statuses.<name>.marker` | `string` \| `table` | The marker symbol to use for the status. The marker's string width must be 1.<br>When provided as a string (e.g. `' '`), the string is used as both the recognized and written marker.<br>When provided as a table (e.g. `{ 'X', 'x' }`), the first element is the **primary** marker — the one written to the buffer when the status is set. Any additional elements are **legacy** markers that will be recognized as belonging to this status when read from a file, but will be replaced with the primary marker on the next toggle. This is useful for accepting alternate symbols from other tools or conventions without losing compatibility. |
| `to_do.statuses.<name>.highlight.marker` | `table` (highlight definition) | A table of highlight definitions to apply to a status marker, including brackets. See the `{val}` parameter of `:h nvim_set_hl` for possible options. |
| `to_do.statuses.<name>.highlight.content` | `table` (highlight definition) | A table of highlight definitions to apply to the to-do item content (everything following the status marker). See the `{val}` parameter of `:h nvim_set_hl` for possible options. |
| `to_do.statuses.<name>.sort.section` | `integer` | The integer should represent the linear section of the list in which items of this status should be placed when sorted. A section refers to a segment of a to-do list. If you want items with the `'in_progress'` status to be first in the list, you would set this option to `1` for the status.<br>Note: Sections are not visually delineated in any way other than items with the same section number occurring on adjacent lines in the list. |
| `to_do.statuses.<name>.sort.position` | `string` | Where in its assigned section a to-do item should be placed:<br>`'top'`: Place a sorted item at the top of its corresponding section.<br>`'bottom'`: Place a sorted item at the bottom of its corresponding section.<br>`'relative'`: Maintain the current relative order of the sorted item whose status was just changed (vs. other list items). |
| `to_do.statuses.<name>.propagate.up` | `fun(to_do_list): string` \| `nil` | A function that accepts a to-do list instance and returns a valid to-do status name. The list passed in is the list that hosts the to-do item whose status was just changed. The return value should be the desired value of the parent. Return `nil` to leave the parent's status as is. |
| `to_do.statuses.<name>.propagate.down` | `fun(to_do_list): string[]` | A function that accepts a to-do list instance and returns a list of valid to-do status names. The list passed in will be the child list of the to-do item whose status was just changed. Return `nil` or an empty table to leave the children's status as is. |
| `to_do.status_order` | `table` (array-like) | An ordered list of status names that controls the toggle rotation order. When a to-do item is toggled, it cycles through the statuses in this order. A status defined in `to_do.statuses` but absent from `status_order` is still recognized when reading files, but excluded from toggle rotation (useful for statuses that should only be set via propagation).<br>Replaces the deprecated `to_do.statuses[*].skip_on_toggle` option. |

> [!WARNING]
> The following to-do configuration options are deprecated. Please use the
> `to_do.statuses` dict and `to_do.status_order` instead. Continued support
> for these options is temporarily provided by a compatibility layer that will
> be removed in the near future.
>
> * `to_do.symbols` - A list of markers representing to-do completion statuses
> * `to_do.not_started` - Which marker represents a not-yet-started to-do
> * `to_do.in_progress` - Which marker represents an in-progress to-do
> * `to_do.complete` - Which marker represents a complete to-do
> * `to_do.update_parents` - Whether parent to-dos' statuses should be updated
> * `to_do.statuses` (array form) - The old array-of-tables format for statuses
> * `to_do.statuses[*].skip_on_toggle` - Use `status_order` membership instead
> * `to_do.statuses[*].exclude_from_rotation` - Use `status_order` membership instead

##### foldtext

```lua
require('mkdnflow').setup({
    foldtext = {
        object_count = true,
        object_count_icon_set = 'emoji',
        object_count_opts = function()
            return require('mkdnflow').foldtext.default_count_opts()
        end,
        line_count = true,
        line_percentage = true,
        word_count = false,
        title_transformer = function()
            return require('mkdnflow').foldtext.default_title_transformer
        end,
        fill_chars = {
            left_edge = '⢾⣿⣿',
            right_edge = '⣿⣿⡷',
            item_separator = ' · ',
            section_separator = ' ⣹⣿⣏ ',
            left_inside = ' ⣹',
            right_inside = '⣏ ',
            middle = '⣿',
        },
    },
})
```

| Option | Type | Description |
| --- | --- | --- |
| `foldtext.object_count` | `boolean` | **`true`** (default): Show a count of all objects inside of a folded section.<br>`false`: Do not show a count of any objects inside of a folded section. |
| `foldtext.object_count_icon_set` | `string` \| `table` | **`'emoji'`** (default): Use pre-defined emojis as icons for counted objects.<br>`'plain'`: Use pre-defined plaintext UTF-8 characters as icons for counted objects.<br>`'nerdfont'`: Use pre-defined nerdfont characters as icons for counted objects. Requires a nerdfont.<br>`table<string, string>`: Use custom mapping of object names to icons. |
| `foldtext.object_count_opts` | `fun(): table<string, table>` | A function that returns the options table defining the final attributes of the objects to be counted, including icons and counting methods. The pre-defined object types are `tbl`, `ul`, `ol`, `todo`, `img`, `fncblk`, `sec`, `par`, and `link`. |
| `foldtext.line_count` | `boolean` | **`true`** (default): Show a count of the lines contained in the folded section.<br>`false`: Don't show a line count. |
| `foldtext.line_percentage` | `boolean` | **`true`** (default): Show the percentage of document (buffer) lines contained in the folded section.<br>`false`: Don't show the percentage. |
| `foldtext.word_count` | `boolean` | `true`: Show a count of the paragraph words in the folded section, ignoring words inside of other objects.<br>**`false`** (default): Don't show a word count. |
| `foldtext.title_transformer` | `fun(): fun(string): string` | A function that returns another function. The inner function accepts a string (the section heading text) and returns a potentially modified string. |
| `foldtext.fill_chars.left_edge` | `string` | The character(s) to use at the very left edge of the foldtext. Default: `'⢾⣿⣿'`. |
| `foldtext.fill_chars.right_edge` | `string` | The character(s) to use at the very right edge of the foldtext. Default: `'⣿⣿⡷'` |
| `foldtext.fill_chars.item_separator` | `string` | The character(s) used to separate the items within a section. Default: `' · '` |
| `foldtext.fill_chars.section_separator` | `string` | The character(s) used to separate adjacent sections. Default: `' ⣹⣿⣏ '` |
| `foldtext.fill_chars.left_inside` | `string` | The character(s) used at the internal left edge of fill characters. Default: `' ⣹'` |
| `foldtext.fill_chars.right_inside` | `string` | The character(s) used at the internal right edge of fill characters. Default: `'⣏ '` |
| `foldtext.fill_chars.middle` | `string` | The character used to fill empty space in the foldtext line. Default: `'⣿'` |

<details>
<summary>Sample foldtext recipes</summary>

```lua
-- SAMPLE FOLDTEXT CONFIGURATION RECIPE WITH COMMENTS
require('mkdnflow').setup({
    foldtext = {
        title_transformer = function()
            local function my_title_transformer(text)
                local updated_title = text:gsub('%b{}', '')
                updated_title = updated_title:gsub('^%s*', '')
                updated_title = updated_title:gsub('%s*$', '')
                updated_title = updated_title:gsub('^######', '░░░░░▓')
                updated_title = updated_title:gsub('^#####', '░░░░▓▓')
                updated_title = updated_title:gsub('^####', '░░░▓▓▓')
                updated_title = updated_title:gsub('^###', '░░▓▓▓▓')
                updated_title = updated_title:gsub('^##', '░▓▓▓▓▓')
                updated_title = updated_title:gsub('^#', '▓▓▓▓▓▓')
                return updated_title
            end
            return my_title_transformer
        end,
        object_count_icon_set = 'nerdfont',
        object_count_opts = function()
            local opts = {
                link = false,
                blockquote = {
                    icon = ' ',
                    count_method = {
                        pattern = { '^>.+$' },
                        tally = 'blocks',
                    }
                },
                fncblk = { icon = ' ' }
            }
            return opts
        end,
        line_count = false,
        word_count = true,
        fill_chars = {
            left_edge = '╾─🖿 ─',
            right_edge = '──╼',
            item_separator = ' · ',
            section_separator = ' // ',
            left_inside = ' ┝',
            right_inside = '┥ ',
            middle = '─',
        },
    },
})
```

The above recipe will produce foldtext like the following
(for an h3-level section heading called `My section`):

<p align="center">
  <picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow-media/main/assets/foldtext/foldtext_ex_dark.png">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow-media/main/assets/foldtext/foldtext_ex.png">
  <img alt="Enhanced foldtext example" src="https://raw.githubusercontent.com/jakewvincent/mkdnflow-media/main/assets/foldtext/foldtext_ex.png">
</picture>
</p>

</details>

##### tables

```lua
require('mkdnflow').setup({
    tables = {
        type = 'pipe',
        trim_whitespace = true,
        format_on_move = true,
        auto_extend_rows = false,
        auto_extend_cols = false,
        style = {
            cell_padding = 1,
            separator_padding = 1,
            outer_pipes = true,
            apply_alignment = true,
        },
    },
})
```

| Option | Type | Description |
| --- | --- | --- |
| `tables.type` | `string` | **`'pipe'`** (default): New tables are created in pipe format (`\| cell \| cell \|` with `\| --- \| --- \|` separator).<br>`'grid'`: New tables are created in pandoc grid format with `+---+` border lines between rows and `+===+` header separators. Grid tables support native multiline cells.<br>Regardless of this setting, existing tables are auto-detected and handled in their native format when formatting, navigating, or editing. |
| `tables.trim_whitespace` | `boolean` | **`true`** (default): Trim extra whitespace from the end of a table cell when a table is formatted.<br>`false`: Leave whitespace at the end of a table cell when formatting. |
| `tables.format_on_move` | `boolean` | **`true`** (default): Format the table each time the cursor is moved to the next/previous cell/row using the plugin's API.<br>`false`: Don't format the table when the cursor is moved. |
| `tables.auto_extend_rows` | `boolean` | `true`: Add another row when attempting to jump to the next row and the row doesn't exist.<br>**`false`** (default): Leave the table when attempting to jump to the next row and the row doesn't exist. |
| `tables.auto_extend_cols` | `boolean` | `true`: Add another column when attempting to jump to the next column and the column doesn't exist.<br>**`false`** (default): Go to the first cell of the next row when attempting to jump to the next column and the column doesn't exist. |
| `tables.style.cell_padding` | `integer` | **`1`** (default): Use one space as padding at the beginning and end of each cell.<br>`<n>`: Use `<n>` spaces as cell padding. |
| `tables.style.separator_padding` | `integer` | **`1`** (default): Use one space as padding in the separator row.<br>`<n>`: Use `<n>` spaces as padding in the separator row. |
| `tables.style.outer_pipes` | `boolean` | **`true`** (default): Include outer pipes when formatting a table.<br>`false`: Do not use outer pipes when formatting a table. |
| `tables.style.apply_alignment` | `boolean` | **`true`** (default): Apply the cell alignment indicated in the separator row when formatting the table.<br>`false`: Always visually left-align cell contents when formatting a table.<br>Previously named `tables.style.mimic_alignment`. |

##### yaml

```lua
require('mkdnflow').setup({
    yaml = {
        bib = { override = false },
    },
})
```

| Option | Type | Description |
| --- | --- | --- |
| `yaml.bib.override` | `boolean` | `true`: A bib path specified in a markdown file's yaml header should be the only source considered for bib references in that file.<br>**`false`** (default): All known bib paths will be considered, whether specified in the yaml header or in your configuration settings. |

##### mappings

```lua
require('mkdnflow').setup({
    mappings = {
        MkdnEnter = { { 'n', 'v' }, '<CR>' },
        MkdnGoBack = { 'n', '<BS>' },
        MkdnGoForward = { 'n', '<Del>' },
        MkdnMoveSource = { 'n', '<F2>' },
        MkdnNextLink = { 'n', '<Tab>' },
        MkdnPrevLink = { 'n', '<S-Tab>' },
        MkdnFollowLink = false,
        MkdnDestroyLink = { 'n', '<M-CR>' },
        MkdnTagSpan = { 'v', '<M-CR>' },
        MkdnYankAnchorLink = { 'n', 'yaa' },
        MkdnYankFileAnchorLink = { 'n', 'yfa' },
        MkdnNextHeading = { 'n', ']]' },
        MkdnPrevHeading = { 'n', '[[' },
        MkdnIncreaseHeading = { { 'n', 'v' }, '+' },
        MkdnDecreaseHeading = { { 'n', 'v' }, '-' },
        MkdnIncreaseHeadingOp = { { 'n', 'v' }, 'g+' },
        MkdnDecreaseHeadingOp = { { 'n', 'v' }, 'g-' },
        MkdnToggleToDo = { { 'n', 'v' }, '<C-Space>' },
        MkdnNewListItem = false,
        MkdnNewListItemBelowInsert = { 'n', 'o' },
        MkdnNewListItemAboveInsert = { 'n', 'O' },
        MkdnExtendList = false,
        MkdnUpdateNumbering = { 'n', '<leader>nn' },
        MkdnTableNextCell = { 'i', '<Tab>' },
        MkdnTablePrevCell = { 'i', '<S-Tab>' },
        MkdnTableNextRow = false,
        MkdnTablePrevRow = { 'i', '<M-CR>' },
        MkdnTableNewRowBelow = { 'n', '<leader>ir' },
        MkdnTableNewRowAbove = { 'n', '<leader>iR' },
        MkdnTableNewColAfter = { 'n', '<leader>ic' },
        MkdnTableNewColBefore = { 'n', '<leader>iC' },
        MkdnTableDeleteRow = { 'n', '<leader>dr' },
        MkdnTableDeleteCol = { 'n', '<leader>dc' },
        MkdnTableAlignLeft = { 'n', '<leader>al' },
        MkdnTableAlignRight = { 'n', '<leader>ar' },
        MkdnTableAlignCenter = { 'n', '<leader>ac' },
        MkdnTableAlignDefault = { 'n', '<leader>ax' },
        MkdnFoldSection = { 'n', '<leader>f' },
        MkdnUnfoldSection = { 'n', '<leader>F' },
        MkdnTab = false,
        MkdnSTab = false,
        MkdnIndentListItem = { 'i', '<C-t>' },
        MkdnDedentListItem = { 'i', '<C-d>' },
        MkdnCreateLink = false,
        MkdnCreateLinkFromClipboard = { { 'n', 'v' }, '<leader>p' },
    },
})
```

See descriptions of commands and mappings below.

**Note**: `<command>` should be the name of a command defined in
`mkdnflow.nvim/plugin/mkdnflow.lua` (see `:h Mkdnflow-commands` for a list).

| Option | Type | Description |
| --- | --- | --- |
| `mappings.<command>` | `[string\|string[], string]` | The first item is a string or an array of strings representing the mode(s) that the mapping should apply in (`'n'`, `'v'`, etc.). The second item is a string representing the mapping (in the expected format for vim). |

#### 🔮 Completion setup

Mkdnflow provides completion for file links, bib citations (`@`), footnotes
(`[^`), and heading anchors (`](#` / `[[#`). Both **nvim-cmp** and **blink.cmp**
are supported.

#### nvim-cmp

Set `modules.completion = true` in your mkdnflow config, then add `mkdnflow`
as a source in your `cmp` setup:

```lua
-- mkdnflow setup
require('mkdnflow').setup({
    modules = { completion = true },
})

-- nvim-cmp setup
cmp.setup({
    sources = cmp.config.sources({
        { name = 'mkdnflow' },
    }),
    formatting = {
        format = function(entry, vim_item)
            vim_item.menu = ({
                mkdnflow = '[Mkdnflow]',
            })[entry.source_name]
            return vim_item
        end
    }
})
```

#### blink.cmp

Set `modules.completion = true` in your mkdnflow config, then register the
source in your blink.cmp setup:

```lua
-- mkdnflow setup
require('mkdnflow').setup({
    modules = { completion = true },
})

-- blink.cmp setup
require('blink.cmp').setup({
    sources = {
        default = { 'lsp', 'mkdnflow' },
        providers = {
            mkdnflow = {
                name = 'Mkdnflow',
                module = 'mkdnflow.completion.blink',
            },
        },
    },
})
```

> [!WARNING]
> There may be some compatibility issues with the completion module and
> `links.transform_on_create`/`links.transform_on_follow` functions.
>
> If you have some `transform_on_create` option for links to organizing in folders
> then the folder name will be inserted accordingly. Some transformations may not
> work as expected in completions.
>
> To prevent this, make sure you write sensible transformation functions,
> preferably using it for folder organization.

## 🛠️ Commands & mappings

Below are descriptions of the user commands defined by Mkdnflow. For the
default mappings to these commands, see the `mappings = ...` section of
Configuration options.

| Command | Default mapping | Description |
| --- | --- | --- |
| `MkdnEnter` | -- | Triggers a wrapper function which will (a) infer your editor mode, and then if in normal or visual mode, either follow a link, create a new link from the text under the cursor or visual selection, or fold a section (if cursor is on a section heading); if in insert mode, it will create a new list item (if cursor is in a list), go to the next row in a table (if cursor is in a table), or behave normally (if cursor is not in a list or a table). In visual mode, if the selection overlaps a citation (`@citekey` or `[@citekey]`), a markdown link is created from the citekey instead of following the citation.<br><br>Note: There is no insert-mode mapping for this command by default since some may find its effects intrusive. To enable the insert-mode functionality, add to the mappings table: `MkdnEnter = {{'i', 'n', 'v'}, '<CR>'}`. |
| `MkdnNextLink` | `{ 'n', '<Tab>' }` | Move cursor to the beginning of the next link (if there is a next link). |
| `MkdnPrevLink` | `{ 'n', '<S-Tab>' }` | Move the cursor to the beginning of the previous link (if there is one). |
| `MkdnNextHeading` | `{ 'n', ']]' }` | Move the cursor to the beginning of the next heading (if there is one). |
| `MkdnPrevHeading` | `{ 'n', '[[' }` | Move the cursor to the beginning of the previous heading (if there is one). |
| `MkdnGoBack` | `{ 'n', '<BS>' }` | Open the historically last-active buffer in the current window.<br><br>Note: The back-end function for `:MkdnGoBack` (`require('mkdnflow').buffers.goBack()`) returns a boolean indicating the success of `goBack()`. This may be useful if you wish to remap `<BS>` such that when `goBack()` is unsuccessful, another function is performed. |
| `MkdnGoForward` | `{ 'n', '<Del>' }` | Open the buffer that was historically navigated away from in the current window. |
| `MkdnCreateLink` | -- | Create a link from the text under the cursor (in normal mode) or from the visual selection (in visual mode). Accepts optional arguments to override the link style and/or transform scope, in any order: `:MkdnCreateLink wiki`, `:MkdnCreateLink filename`, or `:MkdnCreateLink wiki filename`. Abbreviations are accepted (e.g. `:MkdnCreateLink w f`). |
| `MkdnCreateLinkFromClipboard` | `{ { 'n', 'v' }, '<leader>p' }` | Create a link, using the content from the system clipboard (e.g. a URL) as the source and the text under the cursor or visual selection as the link text. Accepts optional arguments to override the link style and/or transform scope, in any order: `:MkdnCreateLinkFromClipboard wiki filename`. Abbreviations are accepted (e.g. `:MkdnCreateLinkFromClipboard w f`). |
| `MkdnCreateFootnote` | -- | Create a footnote reference (`[^N]`) at the cursor position and a corresponding definition (`[^N]: `) at the end of the document. The reference is placed after the current word and any trailing punctuation (e.g., `word.[^1]` rather than `word[^1].`). The cursor jumps to the definition line in insert mode so the footnote text can be filled in immediately. After filling in the definition, use `MkdnFollowLink` (`<CR>`) on the definition to jump back to the reference (or use ` `` `/`''` via the jumplist).<br><br>Auto-numbering increments from the highest existing numeric footnote label. An optional argument specifies an explicit string label instead (e.g., `:MkdnCreateFootnote myref` creates `[^myref]`).<br><br>If no footnote definitions exist in the buffer and `footnotes.heading` is configured, the heading is appended to the end of the document before the definition. If definitions already exist, the new definition is placed after the last one. |
| `MkdnRenumberFootnotes` | -- | Renumber all footnote references and definitions in the current buffer so they form a sequential series (1, 2, 3, ...) based on order of first appearance in the document. Both references (`[^label]`) and definitions (`[^label]: ...`) are updated. String-labeled footnotes (e.g., `[^myref]`) are converted to numeric labels. Multiple references to the same footnote are all updated consistently.<br><br>Definitions are consolidated under the configured `footnotes.heading` (default: `## Footnotes`) in appearance order. Multi-line definitions (with indented continuation lines) are moved as a block. If the heading doesn't exist, it is appended to the end of the document.<br><br>Aborts with a warning if duplicate definitions are found (same label defined more than once). If footnotes are already up to date, a message is shown and no changes are made. |
| `MkdnRefreshFootnotes` | -- | Refresh footnote numbering and consolidate definitions. Like `MkdnRenumberFootnotes`, but only renumbers footnotes that already have numeric labels — string-labeled footnotes (e.g., `[^myref]`) are preserved as-is.<br><br>Definitions are reordered by first appearance in the document and consolidated under the configured `footnotes.heading`. This is useful for documents that mix numbered and named footnotes, or for reordering a disorganized definition list.<br><br>Aborts with a warning if duplicate definitions are found. If footnotes are already up to date, a message is shown and no changes are made. |
| `MkdnFollowLink` | -- | Open the link under the cursor, creating missing directories if desired, or if there is no link under the cursor, make a link from the text under the cursor. Image links (`![alt](path)`) are opened in the system's default viewer.<br><br>For footnotes, this command jumps bidirectionally: pressing `<CR>` on a footnote reference (`[^1]`) jumps to its definition (`[^1]: ...`), and pressing `<CR>` on a definition jumps back to the reference. |
| `MkdnDestroyLink` | `{ 'n', '<M-CR>' }` | Destroy the link under the cursor, replacing it with just the text from the link name. |
| `MkdnTagSpan` | `{ 'v', '<M-CR>' }` | Tag a visually-selected span of text with an ID, allowing it to be linked to with an anchor link. |
| `MkdnMoveSource` | `{ 'n', '<F2>' }` | Open a dialog where you can provide a new source for a link and the<br>plugin will rename and move the associated file on the backend (and<br>rename the link source). After the file is moved, the notebook is<br>scanned for other files that reference the old path. If any are<br>found, a quickfix list opens with proposed link updates. Use `a` to<br>apply a change, `s` to skip, `A` to apply all, or `q` to quit. |
| `MkdnDeadLinks (notebook)` | -- | Scan for dead links — links whose target files do not exist on disk. Results are shown in a read-only quickfix list. Navigate with standard quickfix commands (`:cnext`, `:cprev`, `<CR>` to jump).<br><br>Without arguments, checks only the current buffer. Pass `notebook` to scan all files in the notebook (requires the `notebook` module).<br><br>Checked link types: markdown links (`[text](path)`), wiki links (`[[path]]`), image links (`![alt](path.png)`), and reference definitions (`[label]: path`). Image links and non-notebook extensions (`.pdf`, `.csv`, etc.) are checked for file existence.<br><br>Skipped: URLs, citations (`@citekey`), same-file anchors (`#heading`), and links using registered `uri_handler` schemes. |
| `MkdnBacklinks` | -- | Toggle the backlinks panel, which shows all files in the notebook that contain links pointing to the current buffer's file. Press `<CR>` on a result line to jump to that location. The panel auto-refreshes when you switch buffers (configurable via `backlinks.auto_refresh`). Requires the `notebook` module. |
| `MkdnBacklinksRefresh` | -- | Force a refresh of the backlinks panel content. Useful when `backlinks.auto_refresh` is disabled or after editing files externally. The panel must already be open. |
| `MkdnYankAnchorLink` | `{ 'n', 'yaa' }` | Yank a formatted anchor link (if cursor is currently on a line with a heading). |
| `MkdnYankFileAnchorLink` | `{ 'n', 'yfa' }` | Yank a formatted anchor link with the file path included before the anchor (if cursor is currently on a line with a heading). The file path is relative to the notebook's path resolution base (root directory, initial directory, or current file directory, depending on `path_resolution` config). |
| `MkdnIncreaseHeading` | `{ { 'n', 'v' }, '+' }` | Increase heading importance (remove hashes). Supports visual selection to change multiple headings at once. Visual mode supports dot-repeat (like Vim's `<` and `>`). |
| `MkdnDecreaseHeading` | `{ { 'n', 'v' }, '-' }` | Decrease heading importance (add hashes). Supports visual selection to change multiple headings at once. Visual mode supports dot-repeat (like Vim's `<` and `>`). |
| `MkdnIncreaseHeadingOp` | `{ { 'n', 'v' }, 'g+' }` | Operator version of MkdnIncreaseHeading. In normal mode, use with a motion (e.g., `g+}` to increase headings to next paragraph). In visual mode, operates on selection. Supports dot-repeat. |
| `MkdnDecreaseHeadingOp` | `{ { 'n', 'v' }, 'g-' }` | Operator version of MkdnDecreaseHeading. In normal mode, use with a motion (e.g., `g-}` to decrease headings to next paragraph). In visual mode, operates on selection. Supports dot-repeat. |
| `MkdnToggleToDo` | `{ { 'n', 'v' }, '<C-Space>' }` | Toggle to-do list item's completion status, convert a list item into a to-do list item, or convert a plain text line into a to-do list item. Block-level markdown structures (headings, blockquotes, tables, code fences, thematic breaks, HTML blocks) and lines inside fenced code blocks are not converted. |
| `MkdnSortToDoList` | -- | Sort the to-do list at the cursor position by status. Items are grouped by their status's `sort.section` value and positioned according to `sort.position`. |
| `MkdnUpdateNumbering` | `{ 'n', '<leader>nn' }` | Update numbering for all siblings of the list item of the current line. |
| `MkdnChangeListType {type} (marker)` | -- | Change the type of a list. The `type` argument must be one of `ul` (unordered), `ol` (ordered), `ultd` (unordered to-do), or `oltd` (ordered to-do). An optional `marker` argument (`-`, `*`, or `+`) specifies which bullet character to use when converting to an unordered type. Defaults to `-`. Ignored for ordered types. When used with a marker on a list that is already the target type, the bullet character is swapped (e.g., `:MkdnChangeListType ul *` changes `-` bullets to `*`).<br><br>Without a visual selection, changes all siblings at the cursor's indentation level. With a visual selection, changes all list items in the selected range.<br><br>When converting to a to-do type, items receive a `not_started` checkbox. When converting from a to-do type to a plain type, checkboxes are removed. When converting between to-do types, the existing checkbox status is preserved. |
| `MkdnNewListItem` | -- | Add a new ordered list item, unordered list item, or (uncompleted) to-do list item. When adding a to-do item and `to_do.status_propagation.up` is enabled, ancestor to-do statuses are updated accordingly (e.g. a completed parent reverts to in-progress). |
| `MkdnNewListItemBelowInsert` | `{ 'n', 'o' }` | Add a new list item below the current line and begin insert mode. Add a new line and enter insert mode when the cursor is not in a list. |
| `MkdnNewListItemAboveInsert` | `{ 'n', 'O' }` | Add a new list item above the current line and begin insert mode. Add a new line and enter insert mode when the cursor is not in a list. |
| `MkdnExtendList` | -- | Like above, but the cursor stays on the current line (new list items of the same type are added below). |
| `MkdnTable ncol nrow (noh)` | -- | Make a table of `ncol` columns and `nrow` rows. Pass `noh` as a third argument to exclude table headers. |
| `MkdnTableFormat` | -- | Format a table under the cursor. |
| `MkdnTableNextCell` | `{ 'i', '<Tab>' }` | Move the cursor to the beginning of the next cell in the table, jumping to the next row if needed. |
| `MkdnTablePrevCell` | `{ 'i', '<S-Tab>' }` | Move the cursor to the beginning of the previous cell in the table, jumping to the previous row if needed. |
| `MkdnTableCellNewLine` | `{ 'i', '<S-CR>' }` | Insert a new line within the current table cell. In grid tables, this adds a new content line within the current row. In pipe tables, this inserts a `<br>` tag at the cursor position. |
| `MkdnTableNextRow` | -- | Move the cursor to the beginning of the same cell in the next row of the table. |
| `MkdnTablePrevRow` | `{ 'i', '<M-CR>' }` | Move the cursor to the beginning of the same cell in the previous row of the table. |
| `MkdnTableNewRowBelow` | `{ 'n', '<leader>ir' }` | Add a new row below the row the cursor is currently in. |
| `MkdnTableNewRowAbove` | `{ 'n', '<leader>iR' }` | Add a new row above the row the cursor is currently in. |
| `MkdnTableNewColAfter` | `{ 'n', '<leader>ic' }` | Add a new column following the column the cursor is currently in. |
| `MkdnTableNewColBefore` | `{ 'n', '<leader>iC' }` | Add a new column before the column the cursor is currently in. |
| `MkdnTableDeleteRow` | `{ 'n', '<leader>dr' }` | Delete the row the cursor is currently in. Does nothing if cursor is on the separator row. |
| `MkdnTableDeleteCol` | `{ 'n', '<leader>dc' }` | Delete the column the cursor is currently in. Does nothing if the table has only one column. |
| `MkdnTableAlignLeft` | `{ 'n', '<leader>al' }` | Set the alignment of the current table column to left. Updates the separator row and reformats the table. |
| `MkdnTableAlignRight` | `{ 'n', '<leader>ar' }` | Set the alignment of the current table column to right. Updates the separator row and reformats the table. |
| `MkdnTableAlignCenter` | `{ 'n', '<leader>ac' }` | Set the alignment of the current table column to center. Updates the separator row and reformats the table. |
| `MkdnTableAlignDefault` | `{ 'n', '<leader>ax' }` | Remove alignment from the current table column, returning it to the default. Updates the separator row and reformats the table. |
| `MkdnTablePaste (delimiter) (noh)` | -- | Paste delimited data from the system clipboard as a formatted markdown table. The delimiter is auto-detected by default (supports tab, comma, semicolon, and pipe), but can be specified explicitly as the first argument. Pass `noh` to suppress the header separator row. The table is inserted below the current cursor line. |
| `MkdnTableFromSelection (delimiter) (noh)` | -- | Convert visually-selected delimited lines into a formatted markdown table, replacing the selection. The delimiter is auto-detected by default, but can be specified explicitly. Pass `noh` to suppress the header separator row. Supports CSV, TSV, and other delimited formats including quoted fields. |
| `MkdnIndentListItem` | `{ 'i', '<C-t>' }` | Indent the current list item and update numbering for ordered lists. Falls back to the default `<C-t>` behavior when the cursor is not on a list item. |
| `MkdnDedentListItem` | `{ 'i', '<C-d>' }` | Dedent the current list item and update numbering for ordered lists. Falls back to the default `<C-d>` behavior when the cursor is not on a list item. |
| `MkdnTab` | -- | Wrapper function which will jump to the next cell in a table (if cursor is in a table) or indent an (empty) list item (if cursor is in a list item). |
| `MkdnSTab` | -- | Wrapper function which will jump to the previous cell in a table (if cursor is in a table) or de-indent an (empty) list item (if cursor is in a list item). |
| `MkdnFoldSection` | `{ 'n', '<leader>f' }` | Fold the section the cursor is currently on/in. |
| `MkdnUnfoldSection` | `{ 'n', '<leader>F' }` | Unfold the folded section the cursor is currently on. |
| `MkdnCleanConfig` | -- | Open a scratch buffer showing a minimal, optimized version of your Mkdnflow config. Deprecated key names are updated to their modern equivalents, and values matching defaults are removed. Function values cannot be serialized and are shown with a placeholder comment.<br><br>See also `:checkhealth mkdnflow` for a diagnostic report on your configuration. |
| `Mkdnflow` | -- | Subcommand dispatcher for Mkdnflow. Provides a single entry point to all<br>Mkdnflow functionality with tab completion at every level.<br><br>Use `:Mkdnflow` with no arguments to see available command groups. Use<br>`:Mkdnflow <group>` to see actions within a group. Use<br>`:Mkdnflow <group> <action> [args]` to execute a command.<br><br>Available groups: `link`, `nav`, `heading`, `todo`, `list`, `table`,<br>`fold`, `yank`, `view`, `start`, `config`, `enter`, `tab`, `shift-tab`.<br><br>Examples:<br><br>- `:Mkdnflow link follow` — follow link under cursor<br>- `:Mkdnflow table new 3 4` — create a 3-column, 4-row table<br>- `:'<,'>Mkdnflow todo toggle` — toggle to-do status for visual selection<br>- `:Mkdnflow link create wiki` — create a wiki-style link<br>- `:Mkdnflow start` — force-start Mkdnflow on non-configured filetypes<br>- `:Mkdnflow start silent` — force-start silently<br><br>Note: The previous behavior of `:Mkdnflow` (force-start) has moved to<br>`:Mkdnflow start`. The old usage still works but shows a deprecation<br>warning. |

> [!TIP]
> If you are attempting to (re)map `<CR>` in insert mode but can't get it to
> work, try inspecting your current insert mode mappings and seeing if anything
> is overriding your mapping. Possible candidates are completion plugins and
> auto-pair plugins.
>
> If using nvim-cmp, consider using the mapping with a fallback.
> If using an autopair plugin that automatically maps `<CR>` (e.g. nvim-autopairs),
> see if it provides a way to disable its `<CR>` mapping.

### Custom mappings

There are several ways to customize mkdnflow's keybindings. All
mkdnflow commands (e.g., `MkdnFollowLink`, `MkdnToggleToDo`) are
standard Neovim user commands and can be mapped using any method
you'd normally use to map a Neovim command.

#### Disabling default mappings

To disable a single default mapping, set it to `false` in the
`mappings` table:

```lua
require('mkdnflow').setup({
    mappings = {
        MkdnNextLink = false,              -- Frees <Tab>
        MkdnPrevLink = false,              -- Frees <S-Tab>
        MkdnNewListItemBelowInsert = false, -- Frees 'o'
        MkdnNewListItemAboveInsert = false, -- Frees 'O'
    },
})
```

To disable *all* default mappings at once, disable the `maps`
module:

```lua
require('mkdnflow').setup({
    modules = { maps = false },
})
```

#### Remapping via the mappings table

The simplest way to change a binding is to set a different key
in the `mappings` table. Each entry takes a mode (or array of
modes) and a key string:

```lua
require('mkdnflow').setup({
    mappings = {
        MkdnFollowLink = { 'n', 'gf' },         -- Single mode
        MkdnToggleToDo = { { 'n', 'v' }, 'tt' }, -- Multiple modes
        MkdnEnter = false,                       -- Disable default
    },
})
```

> [!NOTE]
> The `mappings` table maps each command to a single key. If you
> need the same command on multiple keys (e.g., in different
> modes), use `on_attach`, lazy.nvim `keys`, or a manual autocmd
> instead.

#### Using on_attach

The `on_attach` callback fires each time mkdnflow activates on
a matching buffer. It receives the buffer number as its
argument, making it ideal for buffer-local mappings, options,
or autocommands.

When `modules.maps` is enabled (the default), default mappings
are set up *before* `on_attach` runs, so you can selectively
override or supplement them:

```lua
require('mkdnflow').setup({
    on_attach = function(bufnr)
        local opts = { buffer = bufnr }

        -- Bind a command to an additional key
        vim.keymap.set('n', 'gf', '<Cmd>MkdnFollowLink<CR>', opts)

        -- Bind the same command in multiple modes
        vim.keymap.set({ 'n', 'v' }, 'tt', '<Cmd>MkdnToggleToDo<CR>', opts)

        -- Add a mapping not in the defaults
        vim.keymap.set('n', '<leader>ml', '<Cmd>MkdnCreateLink<CR>', opts)

        -- Delete a default mapping you don't want
        pcall(vim.keymap.del, 'n', '+', { buffer = bufnr })

        -- Set buffer-local options
        vim.bo[bufnr].textwidth = 80
    end,
})
```

To use `on_attach` as the *sole* source of mappings (fully
manual control), disable the `maps` module:

```lua
require('mkdnflow').setup({
    modules = { maps = false },
    on_attach = function(bufnr)
        local opts = { buffer = bufnr }
        vim.keymap.set('n', '<CR>', '<Cmd>MkdnEnter<CR>', opts)
        vim.keymap.set('n', '<BS>', '<Cmd>MkdnGoBack<CR>', opts)
        vim.keymap.set('n', '<Tab>', '<Cmd>MkdnNextLink<CR>', opts)
        vim.keymap.set({ 'n', 'v' }, '<C-Space>', '<Cmd>MkdnToggleToDo<CR>', opts)
    end,
})
```

You can also use `on_attach` to create links in both markdown
and wiki styles from different keys. The `MkdnCreateLink` and
`MkdnCreateLinkFromClipboard` commands accept an optional
style argument (abbreviations like `w` and `m` are accepted):

```lua
require('mkdnflow').setup({
    on_attach = function(bufnr)
        local opts = { buffer = bufnr }
        -- Markdown link from clipboard (uses configured default)
        vim.keymap.set({ 'n', 'v' }, '<leader>p',
            '<Cmd>MkdnCreateLinkFromClipboard<CR>', opts)
        -- Wiki link from clipboard (per-call style override)
        vim.keymap.set({ 'n', 'v' }, '<leader>wp',
            '<Cmd>MkdnCreateLinkFromClipboard wiki<CR>', opts)
    end,
})
```

#### Using lazy.nvim keys

If you use lazy.nvim, you can define mappings in the plugin
spec's `keys` table. Use the `ft` field to scope them to
markdown buffers:

```lua
{
    'jakewvincent/mkdnflow.nvim',
    ft = { 'markdown', 'rmd' },
    opts = {
        mappings = {
            MkdnFollowLink = false, -- Disable default
            MkdnEnter = false,
        },
    },
    keys = {
        { 'gf', '<Cmd>MkdnFollowLink<CR>', ft = 'markdown', desc = 'Follow link' },
        { '<CR>', '<Cmd>MkdnEnter<CR>', ft = 'markdown', desc = 'Mkdn enter' },
    },
}
```

> [!NOTE]
> Lazy.nvim's `ft`-scoped `keys` use a filetype autocmd
> internally, so they are effectively buffer-local. Plain `keys`
> entries without `ft` are global and will apply in non-markdown
> buffers too.

#### Manual autocmd

You can also set mappings via your own `FileType` autocmd.
This is equivalent to `on_attach` but managed outside of
mkdnflow's config:

```lua
vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'markdown', 'rmd' },
    callback = function(args)
        vim.keymap.set('n', 'gf', '<Cmd>MkdnFollowLink<CR>', {
            buffer = args.buf,
            desc = 'Follow link',
        })
    end,
})
```

> [!WARNING]
> With a manual autocmd, firing order depends on registration
> order. Your autocmd may fire before or after mkdnflow's,
> depending on when each is registered. Use `on_attach` for
> guaranteed ordering (it always runs after default mappings).

## 📚 API

Mkdnflow provides a range of Lua functions that can be called directly to
manipulate markdown files, navigate through buffers, manage links, and more.
Below are the primary functions available:

1. Initialization ([Initialization](#initialization))
2. Link management ([Link management](#link-management))
3. Link & path handling ([Link and path handling](#link-and-path-handling))
4. Templates ([Templates](#templates))
5. Buffer navigation ([Buffer navigation](#buffer-navigation))
6. Cursor movement ([Cursor movement](#cursor-movement))
7. Cursor-aware manipulations ([Cursor-aware manipulations](#cursor-aware-manipulations))
8. List management ([List management](#list-management))
9. To-do list management ([To-do list management](#to-do-list-management))
10. Table management ([Table management](#table-management))
11. Folds ([Folds](#folds))
12. Yaml blocks ([Yaml blocks](#yaml-blocks))
13. Notebook primitives ([Notebook primitives](#notebook-primitives))
14. Bibliography ([Bibliography](#bibliography))
15. Statusline components ([Statusline components](#statusline-components))

### Initialization

`require('mkdnflow').setup(config)`

Initializes the plugin with the provided configuration. See Advanced
configuration and sample recipes. If called with an empty table, the
default configuration is used.

- **Parameters:**
    - `config`: (table) Configuration table containing various settings such as filetypes, modules, mappings, and more.

`require('mkdnflow').forceStart(opts)`

Activates the plugin if it has not already been activated. This is called
automatically when a buffer with a matching filetype is opened, but can
be triggered manually via the :Mkdnflow command.

- **Parameters:**
    - `opts`: (table) Table of options.
        - `opts[1]`: (string) Pass `'silent'` to suppress the startup message.

### Link management

`require('mkdnflow').links.createLink(args)`

Creates a markdown link from the text under the cursor or visual selection.

- **Parameters:**
    - `args`: (table) Arguments to customize link creation.
        - `from_clipboard`: (boolean) If true, use the system clipboard content as the link source.
        - `style`: (string|nil) Link style override: `'markdown'` or `'wiki'`. Defaults to `links.style` from config.
        - `transform_scope`: (string|nil) Transform scope override: `'path'` or `'filename'`. Defaults to `links.transform_scope` from config.

`require('mkdnflow').links.createFootnote(args)`

Creates a footnote reference at the cursor position and a definition at the end of the document. Jumps to the definition line in insert mode.

- **Parameters:**
    - `args`: (table) Arguments to customize footnote creation.
        - `label`: (string|nil) If provided, uses this string as the footnote label (e.g., `'myref'` creates `[^myref]`). If nil, auto-increments from the highest existing numeric footnote.

`require('mkdnflow').links.renumberFootnotes()`

Renumbers all footnote references and definitions (including string-labeled) to form a sequential integer series based on order of first appearance. Consolidates definitions under the configured heading. Warns and aborts if duplicate definitions are found.

`require('mkdnflow').links.refreshFootnotes()`

Refreshes footnote numbering (numeric labels only) and consolidates definitions under the configured heading in appearance order. String-labeled footnotes are preserved. Warns and aborts if duplicate definitions are found.

`require('mkdnflow').links.followLink(args)`

Follows the link under the cursor, opening the corresponding file, URL, or directory. Image links are opened in the system's default image viewer.

- **Parameters:**
    - `args`: (table) Arguments for following the link.
        - `path`: (string|nil) The path/source to follow. If `nil`, a path from a link under the cursor will be used.
        - `anchor`: (string|nil) An anchor, either one in the current buffer (in which case `path` will be `nil`), or one in the file referred to in `path`.
        - `range`: (boolean|nil) Whether a link should be created from a visual selection range. This is only relevant if `create_on_follow_failure` is `true`, there is no link under the cursor, and there is currently a visual selection that needs to be made into a link.

`require('mkdnflow').links.destroyLink()`

Destroys the link under the cursor, replacing it with plain text.

`require('mkdnflow').links.tagSpan()`

Tags a visual selection as a span, useful for adding attributes to specific text segments.

`require('mkdnflow').links.getLinkUnderCursor(col)`

Returns the link under the cursor at the specified column.

- **Parameters:**
    - `col`: (number|nil) The column position to check for a link. The current cursor position is used if this is not specified.

`require('mkdnflow').links.getLinkPart(link_table, part)`

Retrieves a specific part of a link, such as the source or the text.

- **Parameters:**
    - `link_table`: (table) The table containing link details, as provided by `require('mkdnflow').links.getLinkUnderCursor()`.
    - `part`: (string|nil) The part of the link to retrieve (one of `'source'`, `'name'`, or `'anchor'`). Default: `'source'`.

`require('mkdnflow').links.getBracketedSpanPart(part)`

Retrieves a specific part of a bracketed span.

- **Parameters:**
    - `part`: (string|nil) The part of the span to retrieve (one of `'text'` or `'attr'`). Default: `'attr'`.

`require('mkdnflow').links.hasUrl(string, to_return, col)`

Checks if a given string contains a URL and optionally returns the URL.

- **Parameters:**
    - `string`: (string) The string to check for a URL.
    - `to_return`: (string) The part to return (e.g., "url").
    - `col`: (number) The column position to check.

`require('mkdnflow').links.transformPath(text, scope)`

Transforms the given text according to the default or user-supplied explicit transformation function.

- **Parameters:**
    - `text`: (string) The text to transform.
    - `scope`: (string|nil) Transform scope: `'path'` (transform entire text) or `'filename'` (transform only the filename portion after the last `/`). Defaults to `links.transform_scope` from config.

`require('mkdnflow').links.formatLink(text, source, part, style, transform_scope)`

Creates a formatted link with whatever is provided.

- **Parameters:**
    - `text`: (string) The link text.
    - `source`: (string) The link source.
    - `part`: (integer|nil) The specific part of the link to return.
        - `nil`: () Return the entire link.
        - `1`: () Return the text part of the link.
        - `2`: () Return the source part of the link.
    - `style`: (string|nil) Link style override: `'markdown'` or `'wiki'`. Defaults to `links.style` from config.
    - `transform_scope`: (string|nil) Transform scope override: `'path'` or `'filename'`. Defaults to `links.transform_scope` from config.

### Link and path handling

`require('mkdnflow').paths.moveSource()`

Moves the source file of a link to a new location, updating the link accordingly.

`require('mkdnflow').paths.handlePath(path, anchor)`

Handles all 'following' behavior for a given path, potentially opening it or performing other actions based on the type.

- **Parameters:**
    - `path`: (string) The path to handle.
    - `anchor`: (string|nil) Optional anchor within the path.

`require('mkdnflow').paths.formatTemplate(timing, template)`

**Deprecated:** Use `require('mkdnflow').templates.formatTemplate()` instead.
This function is a backward-compatible shim that delegates to the templates
module. It will be removed in a future major version.

- **Parameters:**
    - `timing`: (string) "before" or "after" specifying when to perform the formatting.
    - `template`: (string|nil) The template to format. If not provided, the default new file template is used.

`require('mkdnflow').paths.updateDirs()`

Updates the working directory after switching notebooks or notebook folders (if `nvim_wd_heel` is true).

`require('mkdnflow').paths.pathType(path, anchor, link_type)`

Determines the type of the given path. Returns `'external'` for image links, `file:`-prefixed paths, and paths with non-notebook file extensions (e.g. `.pdf`, `.docx`); `'url'` for web URLs; `'citation'` for `@`-prefixed paths; `'anchor'` for same-page anchors; `'nb_page'` for notebook pages (extensionless paths or paths with a notebook extension like `.md`); or `nil` if no path is provided.

- **Parameters:**
    - `path`: (string) The path to check.
    - `anchor`: (string|nil) Optional anchor within the path.
    - `link_type`: (string|nil) The link type from the parser (e.g. `'image_link'`).

`require('mkdnflow').paths.transformPath(path)`

Transforms the given path based on the plugin's configuration and transformations.

- **Parameters:**
    - `path`: (string) The path to transform.

### Templates

`require('mkdnflow').templates.formatTemplate(timing, template, opts)`

Formats the new file template by resolving all placeholders in a single
pass. Function placeholders receive a `ctx` table with resolved built-in
values: `link_title`, `os_date`, `source_file`, `filename`, and
`heading_context`.

- **Parameters:**
    - `timing`: (string|nil) Kept for API compatibility; no longer affects behavior. Previously distinguished "before" and "after" buffer creation.
    - `template`: (string|nil) The template to format. If not provided, the default new file template is used.
    - `opts`: (table|nil) Optional parameters.
        - `target_path`: (string|nil) The path of the new file being created. Used to derive the `filename` field in the `ctx` table. If not provided, the current buffer name is used as fallback.

`require('mkdnflow').templates.apply(template)`

Injects a formatted template string into the current buffer (replacing
all content). This is typically called after a new file buffer has been
opened.

- **Parameters:**
    - `template`: (string) The template string produced by `formatTemplate()`.

### Buffer navigation

`require('mkdnflow').buffers.goBack()`

Navigates to the previously opened buffer.

`require('mkdnflow').buffers.goForward()`

Navigates to the next buffer in the history.

### Cursor movement

`require('mkdnflow').cursor.goTo(pattern, reverse)`

Moves the cursor to the next or previous occurrence of the specified pattern.

- **Parameters:**
    - `pattern`: (string|table) The Lua regex pattern(s) to search for.
    - `reverse`: (boolean) If true, search backward.

```lua
require('mkdnflow').cursor.goTo("%[.*%](.*)", false) -- Go to next markdown link
```

`require('mkdnflow').cursor.toNextLink()`

Moves the cursor to the next link in the file.

`require('mkdnflow').cursor.toPrevLink()`

Moves the cursor to the previous link in the file.

`require('mkdnflow').cursor.toHeading(anchor_text, reverse)`

Moves the cursor to the specified heading.

- **Parameters:**
    - `anchor_text`: (string|nil) The text of the heading to move to, transformed in the way that is expected for an anchor link to a heading. If `nil`, the function will go to the next closest heading.
    - `reverse`: (boolean) If true, search backward.

`require('mkdnflow').cursor.toId(id, starting_row)`

Moves the cursor to the specified ID in the file.

- **Parameters:**
    - `id`: (string) The Pandoc-style ID attribute (in a tagged span) to move to.
    - `starting_row`: (number|nil) The row to start the search from. If not provided, the cursor row will be used.

### Cursor-aware manipulations

`require('mkdnflow').cursor.changeHeadingLevel(change)`

Increases or decreases the importance of the heading under the cursor by adjusting the number of hash symbols.

- **Parameters:**
    - `change`: (string) "increase" to decrease hash symbols (increasing importance), "decrease" to add hash symbols, decreasing importance.

`require('mkdnflow').cursor.yankAsAnchorLink(full_path)`

Yanks the current line as an anchor link, optionally including the file path (relative to the path resolution base) depending on the value of the argument.

- **Parameters:**
    - `full_path`: (boolean) If true, includes the file path relative to the configured path resolution base.

### List management

`require('mkdnflow').lists.newListItem({ carry, above, cursor_moves, mode_after, alt })`

Inserts a new list item with various customization options such as whether to carry content from the current line, position the new item above or below, and the editor mode after insertion.

- **Parameters:**
    - `carry`: (boolean) Whether to carry content following the cursor on the current line into the new line/list item.
    - `above`: (boolean) Whether to insert the new item above the current line.
    - `cursor_moves`: (boolean) Whether the cursor should move to the new line.
    - `mode_after`: (string) The mode to enter after insertion ("i" for insert, "n" for normal).
    - `alt`: (string) Which key(s) to feed if this is called while the cursor is not on a line with a list item. Must be a valid string for the first argument of `vim.api.nvim_feedkeys`.

`require('mkdnflow').lists.hasListType(line)`

Checks if the given line is part of a list.

- **Parameters:**
    - `line`: (string) The (content of the) line to check. If not provided, the current cursor line will be used.

`require('mkdnflow').lists.toggleToDo(opts)`

Toggles (rotates) the status of a to-do list item based on the provided options.

- **Parameters:**
    - `opts`: (table) Options for toggling.

`require('mkdnflow').lists.updateNumbering(opts, offset)`

Updates the numbering of the list items in the current list.

- **Parameters:**
    - `opts`: (table) Options for updating numbering.
        - `opts[1]`: (integer) The number to start the current ordered list with.
    - `offset`: (number) The offset to start numbering from. Defaults to `0` if not provided.

> [!WARNING]
> `require('mkdnflow').lists.toggleToDo(opts)` is deprecated. For convenience, it is
> now a wrapper function that calls its replacement, `require('mkdnflow').to_do.toggle_to_do(opts)`.
> See `require('mkdnflow').to_do.toggle_to_do()` for details.

### To-do list management

`require('mkdnflow').to_do.toggle_to_do()`

Toggle (rotate) to-do statuses for a to-do item under the cursor. Returns `true` if a to-do item was toggled or created, `false` otherwise. This is useful for composing context-sensitive mappings that fall through to another action when the cursor is not on a to-do item.

`require('mkdnflow').to_do.get_to_do_item(line_nr)`

Retrieves a to-do item from the specified line number.

- **Parameters:**
    - `line_nr`: (number) The line number to retrieve the to-do item from. If not provided, defaults to the cursor line number.

`require('mkdnflow').to_do.get_to_do_list(line_nr)`

Retrieves the entire to-do list of which the specified line number is an item/member.

- **Parameters:**
    - `line_nr`: (number) The line number to retrieve the to-do list from. If not provided, defaults to the cursor line number.

`require('mkdnflow').to_do.hl.init()`

Initializes highlighting for to-do items. If highlighting is enabled in your configuration, you should never need to use this.

### Table management

`require('mkdnflow').tables.formatTable()`

Formats the current table, ensuring proper alignment and spacing.

`require('mkdnflow').tables.addRow(offset)`

Adds a new row to the table at the specified offset.

- **Parameters:**
    - `offset`: (number) The position (relative to the current cursor row) in which to insert the new row. Defaults to `0`, in which case a new row is added beneath the current cursor row. An offset of `-1` will result in a row being inserted _above_ the current cursor row; an offset of `1` will result in a row being inserted after the row following the current cursor row; etc.

`require('mkdnflow').tables.addCol(offset)`

Adds a new column to the table at the specified offset.

- **Parameters:**
    - `offset`: (number) The position (relative to the table column the cursor is currently in) to insert the new column. Defaults to `0`, in which case a new column is added after the current cursor table column. An offset of `-1` will result in a column being inserted _before_ the current cursor table column; an offset of `1` will result in a column being inserted after the column following the current cursor table column; etc.

`require('mkdnflow').tables.newTable(opts)`

Creates a new table with the specified options.

- **Parameters:**
    - `opts`: (table) Options for the new table (number of columns and rows).
        - `opts[1]`: (integer) The number of columns the table should have
        - `opts[2]`: (integer) The number of rows the table should have (excluding the header row)
        - `opts[3]`: (string) Whether to include a header for the table or not (`'noh'` or `'noheader'`: Don't include a header row; `nil`: Include a header)

`require('mkdnflow').tables.alignCol(alignment)`

Sets the alignment of the table column under the cursor and reformats the table. Works with both pipe tables and Pandoc grid tables.

- **Parameters:**
    - `alignment`: (string) The alignment to set for the column. One of `'left'`, `'right'`, `'center'`, or `'default'`.

`require('mkdnflow').tables.pasteTable(opts)`

Pastes delimited data from the system clipboard as a formatted markdown table, inserted below the current cursor line. Auto-detects the delimiter unless one is specified.

- **Parameters:**
    - `opts`: (table) Options for pasting.
        - `delimiter`: (string|nil) The delimiter character to use. If `nil`, the delimiter is auto-detected from the clipboard content. Supported delimiters: tab, comma, semicolon, pipe.
        - `header`: (boolean) Whether to treat the first row as a header and insert a separator row after it. Default: `true`.

`require('mkdnflow').tables.tableFromSelection(line1, line2, opts)`

Converts visually-selected delimited lines into a formatted markdown table, replacing the selected lines. Auto-detects the delimiter unless one is specified. Supports CSV, TSV, and other delimited formats including RFC 4180-style quoted fields.

- **Parameters:**
    - `line1`: (integer) The start line of the selection (1-indexed).
    - `line2`: (integer) The end line of the selection (1-indexed).
    - `opts`: (table) Options for conversion.
        - `delimiter`: (string|nil) The delimiter character to use. If `nil`, the delimiter is auto-detected. Supported delimiters: tab, comma, semicolon, pipe.
        - `header`: (boolean) Whether to treat the first row as a header and insert a separator row after it. Default: `true`.

`require('mkdnflow').tables.isPartOfTable(text, linenr)`

Guesses as to whether the specified text is part of a table.

- **Parameters:**
    - `text`: (string) The content to check for table membership.
    - `linenr`: (number) The line number corresponding to the text passed in.

`require('mkdnflow').tables.moveToCell(row_offset, cell_offset)`

Moves the cursor to the specified cell in the table.

- **Parameters:**
    - `row_offset`: (number) The difference between the current row and the target row. `0`, for instance, will target the current row.
    - `cell_offset`: (number) The difference between the current table column and the target table column. `0`, for instance, will target the current column.

### Folds

`require('mkdnflow').folds.getHeadingLevel(line)`

Gets the heading level of the specified line.

- **Parameters:**
    - `line`: (string) The line content to get the heading level for. Required.

`require('mkdnflow').folds.foldSection()`

Folds the current section based on markdown headings.

`require('mkdnflow').folds.unfoldSection()`

Unfolds the current section.

### Yaml blocks

`require('mkdnflow').yaml.hasYaml()`

Checks if the current buffer contains a YAML header block.

`require('mkdnflow').yaml.ingestYamlBlock(start, finish)`

Parses and ingests a YAML block from the specified range.

- **Parameters:**
    - `start`: (number) The starting line number.
    - `finish`: (number) The ending line number.

### Notebook primitives

The following functions provide shared cross-file primitives for scanning
notebook files, headings, and links. Both synchronous and asynchronous
variants are available. These serve as building blocks for features like
backlinks, notebook indexing, and table-of-contents generation.

`require('mkdnflow').paths.getBaseDir(buf_path)`

Computes the resolution base directory for the current path resolution strategy.
Consolidates the 3-way `root`/`first`/`current` logic. Falls back to the current
working directory when the base cannot be determined.

- **Parameters:**
    - `buf_path`: (string|nil) Buffer path to use for the `'current'` strategy. If nil, the current buffer's name is used.

`require('mkdnflow').notebook.readFileSync(filepath)`

Reads a file synchronously and returns its lines. Returns nil if the file is not readable.

- **Parameters:**
    - `filepath`: (string) Absolute file path.

`require('mkdnflow').notebook.scanFilesSync(dir, opts)`

Recursively scans a directory for notebook files (`.md`, `.rmd`, etc.) synchronously.
Filters by configured `notebook_extensions` by default.

- **Parameters:**
    - `dir`: (string) Base directory to scan.
    - `opts`: (table|nil) Options for scanning.
        - `extensions`: (table<string, boolean>|nil) Map of file extensions to include (e.g. `{md = true}`). Defaults to `notebook_extensions` from config.
        - `max_depth`: (integer|nil) Maximum directory depth to recurse. Default `20`.
        - `predicate`: (fun(name)|nil) Optional filter function called with each filename; return `true` to include.

`require('mkdnflow').notebook.scanHeadings(lines, opts)`

Scans an array of lines for markdown headings. Skips YAML frontmatter and fenced
code blocks by default. Each returned entry contains the row number, heading level,
text, and an optional anchor slug.

- **Parameters:**
    - `lines`: (string[]) Array of line strings (e.g. from `readFileSync`).
    - `opts`: (table|nil) Options for scanning.
        - `with_anchor`: (boolean|nil) Compute an anchor slug for each heading. Default: `true`.

`require('mkdnflow').notebook.scanLinks(lines, opts)`

Scans an array of lines for markdown links (markdown-style, wiki-style, image links,
etc.). Skips YAML frontmatter and fenced code blocks by default. Returns plain data
tables rather than Link objects.

- **Parameters:**
    - `lines`: (string[]) Array of line strings.
    - `opts`: (table|nil) Options for scanning.
        - `types`: (table<string, boolean>|nil) Filter by link type (e.g. `{md_link = true, wiki_link = true}`). Default includes all types.

`require('mkdnflow').notebook.readFile(filepath, on_done)`

Reads a file asynchronously using `libuv`. Does not wrap the callback in
`vim.schedule` — callers are responsible for scheduling if they need Vim API access.

- **Parameters:**
    - `filepath`: (string) Absolute file path.
    - `on_done`: (fun(lines)) Callback receiving an array of lines, or nil on error.

`require('mkdnflow').notebook.scanFiles(dir, opts, on_done)`

Recursively scans a directory for notebook files asynchronously using `libuv`.
Supports a 2-argument form `scanFiles(dir, on_done)` with default options.
Does not wrap the callback in `vim.schedule`.

- **Parameters:**
    - `dir`: (string) Base directory to scan.
    - `opts`: (table|fun(filepaths)) Options table (same as `scanFilesSync`), or the `on_done` callback for the 2-argument form.
    - `on_done`: (fun(filepaths)|nil) Callback receiving an array of absolute file paths. Required if `opts` is a table.

### Bibliography

`require('mkdnflow').bib.handleCitation(citation)`

Handles a citation, potentially linking to a bibliography entry or external source.

- **Parameters:**
    - `citation`: (string) The citation key to handle. Required.

### Statusline components

The following functions are designed for use in statusline, winbar, or
tabline components. They return information about the plugin's current
state and are safe to call frequently (e.g. on every statusline redraw).

`require('mkdnflow').getNotebook()`

Returns information about the current notebook (root directory), or `nil`
if no root is active (e.g. when `path_resolution.primary` is not `'root'`,
or no root marker was found). Designed for use in statusline, winbar, or
tabline components.

**Example: lualine component**

```lua
require('lualine').setup({
    sections = {
        lualine_x = {
            {
                function()
                    local nb = require('mkdnflow').getNotebook()
                    return nb and nb.name or ''
                end,
                cond = function()
                    return require('mkdnflow').getNotebook() ~= nil
                end,
            },
        },
    },
})
```

**Example: custom statusline**

```lua
vim.o.statusline = '%f %m%=%{%v:lua.require("mkdnflow").getNotebook() '
    .. '~= nil and " " .. require("mkdnflow").getNotebook().name or ""%}'
```

## 🤝 Contributing

See [CONTRIBUTING.md](https://github.com/jakewvincent/mkdnflow.nvim/blob/main/CONTRIBUTING.md)

## 🔢 Version information

Mkdnflow uses [Semantic Versioning](https://semver.org/). Version numbers
follow the format MAJOR.MINOR.PATCH:

- **MAJOR**: Incompatible API or configuration changes
- **MINOR**: New functionality in a backward-compatible manner
- **PATCH**: Backward-compatible bug fixes

For a detailed history of changes, see
[CHANGELOG.md](https://github.com/jakewvincent/mkdnflow.nvim/blob/main/CHANGELOG.md).

## 🔗 Related projects

### Competition

- [obsidian.nvim](https://github.com/epwalsh/obsidian.nvim)
- [wiki.vim](https://github.com/lervag/wiki.vim/)
- [Neorg](https://github.com/nvim-neorg/neorg)
- [markdown.nvim](https://github.com/tadmccorkle/markdown.nvim)
- [Vimwiki](https://github.com/vimwiki/vimwiki)
- [mdnotes.nvim](https://github.com/ymich9963/mdnotes.nvim)
- [follow-md-links.nvim](https://github.com/jghauser/follow-md-links.nvim)

### Complementary plugins

- [Obsidian.md](https://obsidian.md)
- [clipboard-image.nvim](https://github.com/ekickx/clipboard-image.nvim)
- [mdeval.nvim](https://github.com/jubnzv/mdeval.nvim)
- In-editor rendering
    - [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim)
    - [markview.nvim](https://github.com/OXY2DEV/markview.nvim)
- Preview plugins
    - [Markdown Preview for (Neo)vim](https://github.com/iamcco/markdown-preview.nvim)
    - [nvim-markdown-preview](https://github.com/davidgranstrom/nvim-markdown-preview)
    - [glow.nvim](https://github.com/npxbr/glow.nvim)
    - [auto-pandoc.nvim](https://github.com/jghauser/auto-pandoc.nvim)
