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
        2. [🔮 Completion setup](#-completion-setup)
4. [🔍 Usage](#-usage)
    1. [🛠️ Commands & mappings](#%EF%B8%8F-commands--mappings)
    2. [🔌 API](#-api)
5. [🤝 Contributing](#-contributing)
6. [🔢 Version information](#-version-information)
7. [🔗 Related projects](#-related-projects)

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
* [x] [🗂️ Enhanced foldtext](#%EF%B8%8F-enhanced-foldtext)
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

* [ ] Custom(izable) highlighting for to-do status markers and content

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

See descriptions of commands and mappings below.

🛈 **Note**: `<command>` should be the name of a command defined in `mkdnflow.nvim/plugin/mkdnflow.lua` (see :h Mkdnflow-commands for a list).

{{ mappings_config_options }}

</details>


#### 🔮 Completion setup

To enable completion via `cmp` using the provided source, add `mkdnflow` as a source in your `cmp` setup function. You may also want to modify the formatting to see which completions are coming from Mkdnflow:

```lua
cmp.setup({
    -- Add 'mkdnflow' as a completion source
	sources = cmp.config.sources({
		{ name = 'mkdnflow' },
	}),
    -- Completion source attribution
    formatting = {
        format = function(entry, vim_item)
            vim_item.menu = ({
                -- Other attributions
                mkdnflow = '[Mkdnflow]',
            })[entry.source_name]
            return vim_item
        end
    }
})
```

> [!WARNING]
> There may be some compatibility issues with the completion module and `links.transform_explicit`/`links.transform_implicit` functions:
>
> * If you have some `transform_explicit` option for links to organizing in folders then the folder name will be inserted accordingly. **Some transformations may not work as expected in completions**.
>     * For example, if you have an implicit transformation that will make the link appear as `[author_year](author_year.md)` and you save the file as `ref_author_year.md`. The condition can be if the link name ends with *_yyyy*. Now `cmp` will complete it as `[ref_author_year](ref_author_year.md)` (without the transformation applied). Next, when you follow the link completed by `cmp`, you will go to a new file that is saved as `ref_ref_author_year.md`, which of course does not refer to the intended file.
>
> To prevent this, make sure you write sensible transformation functions, preferably using it for folder organization. The other solution is to do a full text search in all the files for links.

## 🔍 Usage
### 🛠️ Commands & mappings

Below are descriptions of the user commands defined by Mkdnflow. For the default mappings to these commands, see the `mappings = ...` section of [🎨 Configuration options](#-configuration-options).

{{ commands_and_mappings }}
                                  
> [!TIP]
> If you are attempting to (re)map `<CR>` in insert mode but can't get it to work, try inspecting your current insert mode mappings and seeing if anything is overriding your mapping. Possible candidates are completion plugins and auto-pair plugins.
> If using [nvim-cmp](https://github.com/hrsh7th/nvim-cmp), consider using using the mapping with a fallback, as shown here: [*cmp-mapping*](https://github.com/hrsh7th/nvim-cmp/blob/bba6fb67fdafc0af7c5454058dfbabc2182741f4/doc/cmp.txt#L238)
> If using an autopair plugin that automtically maps `<CR>` (e.g. [nvim-autopairs](https://github.com/windwp/nvim-autopairs)), see if it provides a way to disable its `<CR>` mapping (e.g. nvim-autopairs allows you to disable that mapping by adding `map_cr = false` to the table passed to its setup function).

### 🔌 API

`Mkdnflow` provides a range of Lua functions that can be called directly to manipulate markdown files, navigate through buffers, manage links, and more. Below are the primary functions available:

#### Initialization

##### `require('mkdnflow').setup(config)`

Initializes the plugin with the provided configuration. See [⚙️  Advanced configuration](#%EF%B8%8F--advanced-configuration). If called with an empty table, the default configuration is used.

* **Parameters**:
    * `config`: (table) Configuration table containing various settings such as filetypes, modules, mappings, and more.

##### `require('mkdnflow').forceStart(opts)`

Similar to setup, but forces the initialization of the plugin regardless of the current buffer's filetype.

* **Parameters:**
    * `opts`: (table) Table of options.
        * `opts[1]`: (boolean) Whether to attempt initialization silently (`true`) or not (`false`).

#### Link management

##### `require('mkdnflow').links.createLink(args)`

Creates a markdown link from the word under the cursor or visual selection.

* **Parameters:**
    * `args`: (table) Arguments to customize link creation.
        * `from_clipboard`: (boolean) If true, use the system clipboard content as the link source.


##### `require('mkdnflow').links.followLink(args)`

Follows the link under the cursor, opening the corresponding file, URL, or directory.

* **Parameters:**
    * `args`: (table) Arguments for following the link.
        * `path`: (string|nil) The path/source to follow. If `nil`, a path from a link under the cursor will be used.
        * `anchor`: (string|nil) An anchor, either one in the current buffer (in which case `path` will be `nil`), or one in the file referred to in `path`.
        * `range`: (boolean|nil) Whether a link should be created from a visual selection range. This is only relevant if `create_on_follow_failure` is `true` (see config for `links` module), there is no link under the cursor, and there is currently a visual selection that needs to be made into a link.

##### `require('mkdnflow').links.destroyLink()`

Destroys the link under the cursor, replacing it with plain text.

##### `require('mkdnflow').links.tagSpan()`

Tags a visual selection as a span, useful for adding attributes to specific text segments.

##### `require('mkdnflow').links.getLinkUnderCursor(col)`

Returns the link under the cursor at the specified column.

* **Parameters:**
    * `col`: (number|nil) The column position to check for a link. The current cursor position is used if this is not specified.

##### `require('mkdnflow').links.getLinkPart(link_table, part)`

Retrieves a specific part of a link, such as the source or the text.

* **Parameters:**
    * `link_table`: (table) The table containing link details, as provided by `require('mkdnflow').links.getLinkUnderCursor()`.
    * `part`: (string|nil) The part of the link to retrieve (one of `'source'`, `'name'`, or `'anchor'`). Default: `'source'`.


##### `require('mkdnflow').links.getBracketedSpanPart(part)`

Retrieves a specific part of a bracketed span.

* **Parameters:**
    * `part`: (string|nil) The part of the span to retrieve (one of `'text'` or `'attr'`). Default: `'attr'`.


##### `require('mkdnflow').links.hasUrl(string, to_return, col)`

Checks if a given string contains a URL and optionally returns the URL.

* **Parameters:**
    * `string`: (string) The string to check for a URL.
    * `to_return`: (string) The part to return (e.g., "url").
    * `col`: (number) The column position to check.

##### `require('mkdnflow').links.transformPath(text)`

Transforms the given text according to the default or user-supplied explicit transformation function.

* **Parameters:**
    * `text`: (string) The text to transform.

##### `require('mkdnflow').links.formatLink(text, source, part)`

Creates a formatted link with whatever is provided.

* **Parameters:**
    * `text`: (string) The link text.
    * `source`: (string) The link source.
    * `part`: (integer|nil) The specific part of the link to return.
        * `nil`: Return the entire link.
        * `1`: Return the text part of the link.
        * `2`: Return the source part of the link.


#### Link & path handling

##### `require('mkdnflow').paths.moveSource()`

Moves the source file of a link to a new location, updating the link accordingly.

##### `require('mkdnflow').paths.handlePath(path, anchor)`

Handles all 'following' behavior for a given path, potentially opening it or performing other actions based on the type.

* **Parameters:**
    * `path`: (string) The path to handle.
    * `anchor`: (string|nil) Optional anchor within the path.

##### `require('mkdnflow').paths.formatTemplate(timing, template)`

Formats the new file template based on the specified timing (before or after buffer creation). If this is called once with 'before' timing, the output can be captured and passed back in with 'after' timing to perform different substitutions before and after a new buffer is opened.

* **Parameters:**
  * `timing`: (string) "before" or "after" specifying when to perform the formatting.
      * `'before'`: Perform the template formatting before the new buffer is opened.
      * `'after'`: Perform the template formatting after the new buffer is opened.
  * `template`: (string|nil) The template to format. If not provided, the default new file template is used.


##### `require('mkdnflow').paths.updateDirs()`

Updates the working directory after switching notebooks or notebook folders (if `nvim_wd_heel` is true).

##### `require('mkdnflow').paths.pathType(path, anchor)`

Determines the type of the given path (file, directory, URL, etc.).

* **Parameters:**
    * `path`: (string) The path to check.
    * `anchor`: (string|nil) Optional anchor within the path.

##### `require('mkdnflow').paths.transformPath(path)`

Transforms the given path based on the plugin's configuration and transformations.

* **Parameters:**
    * `path`: (string) The path to transform.

#### Buffer navigation

##### `require('mkdnflow').buffers.goBack()`

Navigates to the previously opened buffer.

##### `require('mkdnflow').buffers.goForward()`

Navigates to the next buffer in the history.

#### Cursor movement

##### `require('mkdnflow').cursor.goTo(pattern, reverse)`

Moves the cursor to the next or previous occurrence of the specified pattern.

* **Parameters:**
    * `pattern`: (string|table) The Lua regex pattern(s) to search for.
    * `reverse`: (boolean) If true, search backward.

```lua
require('mkdnflow').cursor.goTo("%[.*%](.*)", false) -- Go to next markdown link
```

##### `require('mkdnflow').cursor.toNextLink()`

Moves the cursor to the next link in the file.

##### `require('mkdnflow').cursor.toPrevLink()`

Moves the cursor to the previous link in the file.

##### `require('mkdnflow').cursor.toHeading(anchor_text, reverse)`

Moves the cursor to the specified heading.

* **Parameters:**
    * `anchor_text`: (string|nil) The text of the heading to move to, transformed in the way that is expected for an anchor link to a heading. If `nil`, the function will go to the next closest heading.
    * `reverse`: (boolean) If true, search backward.

##### `require('mkdnflow').cursor.toId(id, starting_row)`

Moves the cursor to the specified ID in the file.

* **Parameters:**
    * `id`: (string) The Pandoc-style ID attribute (in a tagged span) to move to.
    * `starting_row`: (number|nil) The row to start the search from. If not provided, the cursor row will be used.

#### Cursor-aware manipulations

##### `require('mkdnflow').cursor.changeHeadingLevel(change)`

Increases or decreases the importance of the heading under the cursor by adjusting the number of hash symbols.

* **Parameters:**
    * `change`: (string) "increase" to decrease hash symbols (increasing importance), "decrease" to add hash symbols, decreasing importance.

##### `require('mkdnflow').cursor.yankAsAnchorLink(full_path)`

Yanks the current line as an anchor link, optionally including the full file path depending on the value of the argument.

* **Parameters:**
    * `full_path`: (boolean) If true, includes the full file path.


#### List management

##### `require('mkdnflow').lists.newListItem({ carry, above, cursor_moves, mode_after, alt })`

Inserts a new list item with various customization options such as whether to carry content from the current line, position the new item above or below, and the editor mode after insertion.

* **Parameters:**
    * `carry`: (boolean) Whether to carry content following the cursor on the current line into the new line/list item.
    * `above`: (boolean) Whether to insert the new item above the current line.
    * `cursor_moves`: (boolean) Whether the cursor should move to the new line.
    * `mode_after`: (string) The mode to enter after insertion ("i" for insert, "n" for normal).
    * `alt`: (string) Which key(s) to feed if this is called while the cursor is not on a line with a list item. Must be a valid string for the first argument of `vim.api.nvim_feedkeys`.

##### `require('mkdnflow').lists.hasListType(line)`

Checks if the given line is part of a list.

* **Parameters:**
    * `line`: (string) The (content of the) line to check. If not provided, the current cursor line will be used.

##### `require('mkdnflow').lists.toggleToDo(opts)`

Toggles (rotates) the status of a to-do list item based on the provided options.

> [!WARNING]
> `require('mkdnflow').lists.toggleToDo(opts)` is deprecated. For convenience, it is now a wrapper function that calls its replacement, `require('mkdnflow').to_do.toggle_to_do(opts)` See [`require('mkdnflow').to_do.core.toggle_to_do()`](#requiremkdnflowto_docoretoggle_to_do) for details.

##### `require('mkdnflow').lists.updateNumbering(opts, offset)`

Updates the numbering of the list items in the current list.

* **Parameters:**
    * `opts`: (table) Options for updating numbering.
        * `opts[1]`: (integer) The number to start the current ordered list with.
    * `offset`: (number) The offset to start numbering from. Defaults to `0` if not provided.

#### To-do list management

##### `require('mkdnflow').to_do.toggle_to_do()`

Toggle (rotate) to-do statuses for a to-do item under the cursor.

##### `require('mkdnflow').to_do.get_to_do_item(line_nr)`

Retrieves a to-do item from the specified line number.

* **Parameters:**
    * `line_nr`: (number) The line number to retrieve the to-do item from. If not provided, defaults to the cursor line number.

##### `require('mkdnflow').to_do.get_to_do_list(line_nr)`

Retrieves the entire to-do list of which the specified line number is an item/member.

* **Parameters:**
    * `line_nr`: (number) The line number to retrieve the to-do list from. If not provided, defaults to the cursor line number.

##### `require('mkdnflow').to_do.hl.init()`

Initializes highlighting for to-do items. If highlighting is enabled in your configuration, you should never need to use this.

#### Table management

##### `require('mkdnflow').tables.formatTable()`

Formats the current table, ensuring proper alignment and spacing.

##### `require('mkdnflow').tables.addRow(offset)`

Adds a new row to the table at the specified offset.

* **Parameters:**
    * `offset`: (number) The position (relative to the current cursor row) in which to insert the new row. Defaults to `0`, in which case a new row is added beneath the current cursor row. An offset of `-1` will result in a row being inserted _above_ the current cursor row; an offset of `1` will result in a row being inserted after the row following the current cursor row; etc.

##### `require('mkdnflow').tables.addCol(offset)`

Adds a new column to the table at the specified offset.

* **Parameters:**
    * `offset`: (number) The position (relative to the table column the cursor is currently in) to insert the new column. Defaults to `0`, in which case a new column is added after the current cursor table column. An offset of `-1` will result in a column being inserted _before_ the current cursor table column; an offset of `1` will result in a column being inserted after the column following the current cursor table column; etc.


##### `require('mkdnflow').tables.newTable(opts)`

Creates a new table with the specified options.

* **Parameters:**
    * `opts`: (table) Options for the new table (number of columns and rows).
        * `opts[1]`: (integer) The number of columns the table should have
        * `opts[2]`: (integer) The number of rows the table should have (excluding the header row)
        * `opts[3]`: (string) Whether to include a header for the table or not
            * `'noh'` or `'noheader'`: Don't include a header row
            * `nil`: Include a header

##### `require('mkdnflow').tables.isPartOfTable(text, linenr)`

Guesses as to whether the specified text is part of a table.

* **Parameters:**
    * `text`: (string) The content to check for table membership.
    * `linenr`: (number) The line number corresponding to the text passed in.

##### `require('mkdnflow').tables.moveToCell(row_offset, cell_offset)`

Moves the cursor to the specified cell in the table.

* **Parameters:**
    * `row_offset`: (number) The difference between the current row and the target row. `0`, for instance, will target the current row.
    * `cell_offset`: (number) The difference between the current table column and the target table column. `0`, for instance, will target the current column.

#### Folds

##### `require('mkdnflow').folds.getHeadingLevel(line)`

Gets the heading level of the specified line.

* **Parameters:**
    * `line`: (string) The line content to get the heading level for. Required.


##### `require('mkdnflow').folds.foldSection()`

Folds the current section based on markdown headings.

##### `require('mkdnflow').folds.unfoldSection()`

Unfolds the current section.

#### Yaml blocks

##### `require('mkdnflow').yaml.hasYaml()`

Checks if the current buffer contains a YAML header block.

##### `require('mkdnflow').yaml.ingestYamlBlock(start, finish)`

Parses and ingests a YAML block from the specified range.

* **Parameters:**
    * `start`: (number) The starting line number.
    * `finish`: (number) The ending line number.

#### Bibliography

##### `require('mkdnflow').bib.handleCitation(citation)`

Handles a citation, potentially linking to a bibliography entry or external source.

* **Parameters:**
    * `citation`: (string) The citation key to handle. Required.

## 🤝 Contributing

## 🔢 Version information

## 🔗 Related projects
