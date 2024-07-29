<p align="center">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/logo/mkdnflow_logo_dark.png">
      <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/logo/mkdnflow_logo_light.png">
      <img alt="Black mkdnflow logo in light color mode and white logo in dark color mode." src="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/logo/mkdnflow_logo_light.png">
    </picture>
</p>
<p align=center><img src="https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white"> <img src="https://img.shields.io/badge/Markdown-000000?style=for-the-badge&logo=markdown&logoColor=white"> <img src="https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white"></p>

### Contents

1. [🚀 Introduction](#-introduction)
2. [✨ Features](#-features)
3. [💾 Installation and configuration](#-installation-and-configuration)
    1. [⚡ Quick Start](#-quick-start)
    2. [⚙️  Advanced configuration](#%EF%B8%8F--advanced-configuration)
        1. [🎨 Configuration options](#-configuration-options)
4. [🔍 Usage](#-usage)
    1. [🛠️ Commands & mappings](#%EF%B8%8F-commands--mappings)
    2. [🔌 API](#-api)
5. [🤝 Contributing](#-contributing)
6. [🐛 Troubleshooting](#-troubleshooting)
7. [🔢 Version information](#-version-information)
8. [🔗 Related projects](#-related-projects)

## 🚀 Introduction

Mkdnflow is designed for the *fluent* navigation and management of [markdown](https://markdownguide.org) documents and document collections (notebooks, wikis, etc). It features numerous convenience functions that make it easier to work within raw markdown documents or document collections: [link and reference handling](#-link-and-reference-handling), [navigation](#-navigation), [table support](#-table-support), [list](#-list-support) and [to-do list](#-to-do-list-support) support, [file management](#-file-management), [section folding](#-section-folding), and more. Use it for notetaking, personal knowledge management, static website building, and more. Most features are [highly tweakable](#-configuration).

## ✨ Features

### 🧭 Navigation

#### Within-buffer navigation
* [x] Jump to links
* [x] Jump to section headings

#### Within-notebook navigation
* [x] Open Markdown files in the current window
* [x] Browser-like 'Back' and 'Forward' functionality

### 🔗 Link and reference handling

* [x] Link creation from a visual selection or the word under the cursor
* [x] Link destruction
* [x] Follow links to local paths, other Markdown files, and websites
* [x] Follow external links
* [x] Follow `.bib`-based references
    * [x] Open `url` or `doi` field in the default browser
    * [x] Open documents specified in `file` field

### 📊 Table support

* [x] Table creation
* [x] Table extension (add rows and columns)
* [x] Table formatting
* [ ] Paste delimited data as a table
* [ ] Import delimited file into a new table

### 📝 List support

* [x] Automatic list extension
* [x] Sensible auto-indentation and auto-dedentation
* [x] Ordered list number updating

### ✅ To-do list support

* [x] Toggle to-do item status
* [x] Status propagation
* [x] To-do list sorting
* [x] Create to-do items from plain ordered or unordered list items
* [x] [Highlighting](#%EF%B8%8F-highlighting)

### 📁 File management

* [x] Simultaneous link and file renaming
* [x] As-needed directory creation

### 🪗 Folding

* [x] Section folding and fold toggling
* [ ] YAML block folding

### 🔮 Completion

* [x] Path completion
* [x] Completion of bibliography items

### 🧩 YAML block parsing

* [x] Specify a bibliography file in YAML front matter

### 🖌️ Visual enhancements

#### 🗂️ Enhanced foldtext

* [x] Helpful visualization of folded section contents:
    * [x] Section heading level
    * [x] Object counts
    * [x] Line and word counts

#### 🙈 Conceal

* [x] Conceal markdown and wiki link syntax

#### 🖍️ Highlighting

* [ ] Highlight to-do items

### ⚙️ Configurability

## 💾 Installation and configuration

Install Mkdnflow using your preferred package manager for Neovim. Once installed, Mkdnflow is configured and initialized using a setup function.

<details>
<summary>Install with <a href="https://github.com/folke/lazy.nvim">Lazy</a></summary><p>

```lua
require('lazy').setup({
    -- Your other plugins
    {
        'jakewvincent/mkdnflow.nvim',
        config = function()
            require('mkdnflow').setup({
                -- Your config
            })
        end
    }
    -- Your other plugins
})
```

</p></details>

<details>
<summary>Install with Vim-Plug</summary><p>

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

### ⚡ Quick start

Mkdnflow is configured and initialized using a setup function. To use the [default settings](#-default-settings), pass no arguments or an empty table to the setup function:

```lua
{
    'jakewvincent/mkdnflow.nvim',
    config = function()
        require('mkdnflow').setup({})
    end
}
```


### ⚙️  Advanced configuration

Most features are highly configurable. Study the default config first and read the documentation for the configuration options [below](#-configuration-options) or in the help files.

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
        to_do = true,
        yaml = false,
        cmp = false,
    },
    create_dirs = true,
    silent = false,
    wrap = false,
    perspective = {
        priority = 'first',
        fallback = 'current',
        root_tell = false,
        nvim_wd_heel = false,
        update = true,
    },
    filetypes = {
        md = true,
        rmd = true,
        markdown = true,
    },
    foldtext = {
        object_count = true,
        object_count_icon_set = 'emoji',
        object_count_opts = function()
            return require('mkdnflow').foldtext.default_count_opts
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
        name_is_source = false,
        conceal = false,
        context = 0,
        implicit_extension = nil,
        transform_implicit = false,
        transform_explicit = function(text)
            text = text:gsub('[ /]', '-')
            text = text:lower()
            text = os.date('%Y-%m-%d_') .. text
            return text
        end,
        create_on_follow_failure = true,
    },
    new_file_template = {
        use_template = false,
        placeholders = {
            before = {
                title = 'link_title',
                date = 'os_date',
            },
            after = {},
        },
        template = '# {{title}}',
    },
    to_do = {
        statuses = {
            {
                name = 'not_started',
                marker = ' ',
                sort = { section = 1, position = 'relative' },
                exclude_from_rotation = false,
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
            {
                name = 'in_progress',
                marker = '-',
                sort = { section = 1, position = 'relative' },
                exclude_from_rotation = false,
                propagate = {
                    up = function(host_list)
                        return 'in_progress'
                    end,
                    down = function(child_list) end,
                },
            },
            {
                name = 'complete',
                marker = { 'X', 'x' },
                sort = { section = 2, position = 'top' },
                exclude_from_rotation = false,
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
        trim_whitespace = true,
        format_on_move = true,
        auto_extend_rows = false,
        auto_extend_cols = false,
        style = {
            cell_padding = 1,
            separator_padding = 1,
            outer_pipes = true,
            mimic_alignment = true,
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
        MkdnIncreaseHeading = { 'n', '+' },
        MkdnDecreaseHeading = { 'n', '-' },
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
        MkdnFoldSection = { 'n', '<leader>f' },
        MkdnUnfoldSection = { 'n', '<leader>F' },
        MkdnTab = false,
        MkdnSTab = false,
        MkdnCreateLink = false,
        MkdnCreateLinkFromClipboard = { { 'n', 'v' }, '<leader>p' },
    },
}
```

</details>

#### 🎨 Configuration options

<details>
    <summary>
        <code>modules = ...</code>
    </summary>

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
    }
})
```

{{ modules_config_options }}

---

</details>

<details>
    <summary>
        <code>create_dirs = ...</code>
    </summary>

```lua
require('mkdnflow').setup({
    create_dirs = true,
})
```

{{ create_dirs_config_options }}

---

</details>

<details>
    <summary>
        <code>perspective = ...</code>
    </summary>

```lua
require('mkdnflow').setup({
    perspective = {
        priority = 'first',
        fallback = 'current',
        root_tell = false,
        nvim_wd_heel = false,
        update = false,
    },
})
```

{{ perspective_config_options }}

---

</details>

<details>
    <summary>
        <code>filetypes = ...</code>
    </summary>

```lua
require('mkdnflow').setup({
    filetypes = {
        md = true,
        rmd = true,
        markdown = true,
    },
)
```

{{ filetypes_config_options }}

> [!NOTE]
> This functionality references the file's extension. It does not rely on Neovim's filetype recognition. The extension must be provided in lower case because the plugin converts file names to lowercase. Any arbitrary extension can be supplied. Setting an extension to `false` is the same as not including it in the list.

---

</details>

<details>
    <summary>
        <code>wrap = ...</code>
    </summary>

```lua
require('mkdnflow').setup({
    wrap = false,
})
```

{{ wrap_config_options}}

---

</details>

<details>
    <summary>
        <code>bib = ...</code>
    </summary>

```lua
require('mkdnflow').setup({
    bib = {
        default_path = nil,
        find_in_root = true,
    },
})
```

{{ bib_config_options }}

---

</details>

<details>
    <summary>
        <code>silent = ...</code>
    </summary>

```lua
require('mkdnflow').setup({
    silent = false,
})
```

{{ silent_config_options }}

---

</details>

<details>
    <summary>
        <code>cursor = ...</code>
    </summary>

```lua
require('mkdnflow').setup({
    cursor = {
        jump_patterns = nil,
    },
})
```

{{ cursor_config_options }}

---

</details>

<details>
    <summary>
        <code>links = ...</code>
    </summary>

```lua
require('mkdnflow').setup({
    links = {
        style = 'markdown',
        name_is_source = false,
        conceal = false,
        context = 0,
        implicit_extension = nil,
        transform_implicit = false,
        transform_explicit = function(text)
            text = text:gsub(" ", "-")
            text = text:lower()
            text = os.date('%Y-%m-%d_') .. text
            return(text)
        end,
        create_on_follow_failure = true,
    },
})
```

---

{{ links_config_options }}

<details>
    <summary>Sample `link` recipes</summary>

```lua
require('mkdnflow').setup({
    links = {
        -- If you want all link paths to be explicitly prefixed with the year and for the path to be converted to uppercase, you could provide the following function under the `transform_explicit` key:
        transform_explicit = function(input)
            return(string.upper(os.date('%Y-')..input))
        end
        -- Link paths that match a date pattern can be opened in a `journals` subdirectory of your notebook, and all others can be opened in a `pages` subdirectory, using the following function:
        transform_implicit = function(input)
            if input:match('%d%d%d%d%-%d%d%-%d%d') then
                return('journals/'..input)
            else
                return('pages/'..input)
        end
end
    }
})
```

</details>

---

</details>

<details>
    <summary>
        <code>new_file_template = ...</code>
    </summary>

```lua
require('mkdnflow').setup({
    new_file_template = {
        use_template = false,
        placeholders = {
            before = { title = 'link_title', date = 'os_date' },
            after = {},
        },
        template = '# {{ title }}',
    },
})
```

{{ new_file_template_config_options }}

---

</details>

<details>
    <summary>
        <code>to_do = ...</code>
    </summary>

```lua
require('mkdnflow').setup({
    to_do = {
        highlight = false,
        status_propagation = { up = true, down = true },
        sort = {
            on_status_change = false,
            recursive = false,
            cursor_behavior = { track = true },
        },
        statuses = {
            {
                name = 'not_started',
                marker = ' ',
                sort = { section = 2, position = 'top' },
                propagation = {
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
            {
                name = 'in_progress',
                marker = '-',
                sort = { section = 1, position = 'bottom' },
                propagation = {
                    up = function(host_list)
                        return 'in_progress'
                    end,
                    down = function(child_list) end,
                },
            },
            {
                name = 'complete',
                marker = { 'X', 'x' },
                sort = { section = 3, position = 'top' },
                propagation = {
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
    },
})
```

{{ to_do_config_options }}

> [!WARNING]
> **The following to-do configuration options are deprecated. Please use the `to_do.statuses` table instead. Continued support for these options is temporarily provided by a compatibility layer that will be removed in the near future.**
> * `to_do.symbols` (array-like table): A list of markers (each no more than one character) that represent to-do list completion statuses. `MkdnToggleToDo` references these when toggling the status of a to-do item. Three are expected: one representing not-yet-started to-dos (default: `' '`), one representing in-progress to-dos (default: `-`), and one representing complete to-dos (default: `X`).
> * `to_do.not_started` (string): Stipulates which marker represents a not-yet-started to-do (default: `' '`)
> * `to_do.in_progress` (string):  Stipulates which marker represents an in-progress to-do (default: `'-'`)
> * `to_do.complete` (string):  Stipulates which marker represents a complete to-do (default: `'X'`)
> * `to_do.update_parents` (boolean): Whether parent to-dos' statuses should be updated based on child to-do status changes performed via `MkdnToggleToDo`
>    * `true` (default): Parent to-do statuses will be inferred and automatically updated when a child to-do's status is changed
>    * `false`: To-do items can be toggled, but parent to-do statuses (if any) will not be automatically changed


---

</details>

<details>
    <summary>
        <code>foldtext = ...</code>
    </summary>

```lua
require('mkdnflow').setup({
    foldtext = {
        object_count = true,
        object_count_icon_set = 'emoji',
        object_count_opts = function()
            return require('mkdnflow').foldtext.default_count_opts
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

{{ foldtext_config_options }}

<details>
    <summary>Sample <code>foldtext</code> recipes</summary>

```lua
-- SAMPLE FOLDTEXT CONFIGURATION RECIPE WITH COMMENTS
require('mkdnflow').setup({
    -- Other config options
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
        object_count_icon_set = 'nerdfont', -- Use/fall back on the nerdfont icon set
        object_count_opts = function()
            local opts = {
                link = false, -- Prevent links from being counted
                blockquote = { -- Count block quotes (these aren't counted by default)
                    icon = ' ',
                    count_method = {
                        pattern = { '^>.+$' },
                        tally = 'blocks',
                    }
                },
                fncblk = { icon = ' ' } -- Override the icon for fenced code blocks with 
            }
            return opts
        end,
        line_count = false, -- Prevent lines from being counted
        word_count = true, -- Count the words in the section
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
    -- Other config options
})
```

The above recipe will produce foldtext like the following (for an h3-level section heading called `My section`):

<p align="center">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/foldtext/foldtext_ex_dark.png">
      <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/foldtext/foldtext_ex.png">
      <img src="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/foldtext/foldtext_ex.png">
    </picture>
</p>

</details>
</details>

<details>
    <summary>
        <code>tables = ...</code>
    </summary>

```lua
require('mkdnflow').setup({
    tables = {
        trim_whitespace = true,
        format_on_move = true,
        auto_extend_rows = false,
        auto_extend_cols = false,
        style = {
            cell_padding = 1,
            separator_padding = 1,
            outer_pipes = true,
            mimic_alignment = true,
        },
    },
})
```

{{ tables_config_options }}

</details>

<details>
    <summary>
        <code>yaml = ...</code>
    </summary>

```lua
require('mkdnflow').setup({
    yaml = {
        bib = { override = false },
    },
})
```

{{ yaml_config_options }}

</details>

<details>
    <summary>
        <code>mappings = ...</code>
    </summary>

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
        MkdnIncreaseHeading = { 'n', '+' },
        MkdnDecreaseHeading = { 'n', '-' },
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
        MkdnFoldSection = { 'n', '<leader>f' },
        MkdnUnfoldSection = { 'n', '<leader>F' },
        MkdnTab = false,
        MkdnSTab = false,
        MkdnCreateLink = false,
        MkdnCreateLinkFromClipboard = { { 'n', 'v' }, '<leader>p' },
    },
})
```

> [!NOTE]
> `<name of command>` should be the name of a commands defined in `mkdnflow.nvim/plugin/mkdnflow.lua` (see :h Mkdnflow-commands for a list).

See descriptions of commands and mappings below.

{{ mappings_config_options }}

</details>


## 🔍 Usage
### 🛠️ Commands & mappings

Below are descriptions of the user commands defined by Mkdnflow. For the default mappings to these commands, see the `mappings = ...` section of [🎨 Configuration options](#-configuration-options).

{{ commands_and_mappings }}
                                  
> [!TIP]
> The back-end function for `:MkdnGoBack`, `require('mkdnflow').buffers.goBack()`, returns a boolean indicating the success of `goBack()` (thanks, @pbogut!). This is useful if the user wishes to remap `<BS>` so that when `goBack()` is unsuccessful, another function is performed.

> [!NOTE]
> There is no insert-mode mapping for this command by default since some may find its effects intrusive. To enable the insert-mode functionality, add to the mappings table: `MkdnEnter = {{'i', 'n', 'v'}, '}`.

> [!NOTE]
> If you are attempting to (re)map `<CR>` in insert mode but can't get it to work, try inspecting your current insert mode mappings and seeing if anything is overriding your mapping. Possible candidates are completion plugins and auto-pair plugins.
> If using [nvim-cmp](https://github.com/hrsh7th/nvim-cmp), consider using using the mapping with a fallback, as shown here: [*cmp-mapping*](https://github.com/hrsh7th/nvim-cmp/blob/bba6fb67fdafc0af7c5454058dfbabc2182741f4/doc/cmp.txt#L238)
> If using an autopair plugin that automtically maps `<CR>` (e.g. [nvim-autopairs](https://github.com/windwp/nvim-autopairs)), see if it provides a way to disable its `<CR>` mapping (e.g. nvim-autopairs allows you to disable that mapping by adding `map_cr = false` to the table passed to its setup function).

### 🔌 API

## 🤝 Contributing

## 🐛 Troubleshooting

## 🔢 Version information

## 🔗 Related projects
