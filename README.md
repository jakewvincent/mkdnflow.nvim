<p align="center">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/logo/mkdnflow_logo_dark.png">
      <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/logo/mkdnflow_logo_light.png">
      <img alt="Black mkdnflow logo in light color mode and white logo in dark color mode." src="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/logo/mkdnflow_logo_light.png">
    </picture>
</p>
<p align=center><img src="https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white"> <img src="https://img.shields.io/badge/Markdown-000000?style=for-the-badge&logo=markdown&logoColor=white"> <img src="https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white"></p>
<p align=center>
   <a href="#-features">Features</a> / <a href="#-installation-and-usage">Installation</a> / <a href="#-starting-a-notebook">Starting a notebook</a> / <a href="#%EF%B8%8F-configuration">Config</a> / <a href="#-commands-and-default-mappings">Commands & mappings</a> / <a href="#%EF%B8%8F-to-do">To do</a> / <a href="#-recent-changes">Recent changes</a> / <a href="#-links">Links</a>
</p>

### Contents

1. [🚀 Introduction](#-introduction)
2. [✨ Features](#-features)
3. [💾 Installation and configuration](#-installation-and-configuration)
    1. [⚡ Quick Start](#-quick-start)
    2. [⚙️  Advanced configuration](#-advanced-configuration)
        1. [🎨 Configuration options](#-configuration-options)
4. [🔍 Usage](#-usage)
    1. [🛠️ Commands](#-commands)
    2. [⌨️  Mappings](#-mappings)
5. [❓ Frequently asked questions](#-frequently-asked-questions)
6. [🤝 Contributing](#-contributing)
7. [📜 License](#-license)
8. [🐛 Troubleshooting](#-license)
9. [📋 Quick reference](#-quick-reference)
10. [🔢 Version information](#-version-information)
11. [🔗 Related projects](#-related-projects)

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
* [x] [Highlighting](#-highlighting)

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
                symbol = ' ',
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
                symbol = '-',
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
                symbol = { 'X', 'x' },
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
        <code>modules = {...</code>
    </summary>

<details>
    <summary>
        View as Lua table
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

</details>


| Option             | Type    | Default | Description                                                               | Note                |
| ------------------ | ------- | ------- | ------------------------------------------------------------------------- | ------------------- |
| `modules.bib`      | boolean | `true`  | Required for parsing `.bib` files and following citations                 |                     |
| `modules.buffers`  | boolean | `true`  | Required for backward and forward navigation through buffers              |                     |
| `modules.conceal`  | boolean | `true`  | Required if you wish to enable link concealing                            | See `links.conceal` |
| `modules.cursor`   | boolean | `true`  | Required for cursor navigation (jumping to links, headings, etc.)         |                     |
| `modules.folds`    | boolean | `true`  | Required for folding by section                                           |                     |
| `modules.foldtext` | boolean | `true`  | Required for prettified foldtext                                          |                     |
| `modules.links`    | boolean | `true`  | Required for creating, destroying, and following links                    |                     |
| `modules.lists`    | boolean | `true`  | Required for working in and manipulating lists, etc.                      |                     |
| `modules.to_do`    | boolean | `true`  | Required for mnipulating to-do statuses/lists, toggling to-do items, etc. |                     |
| `modules.paths`    | boolean | `true`  | Required for link interpretation, link following, etc.                    |                     |
| `modules.tables`   | boolean | `true`  | Required for table management, navigation, formatting, etc.               |                     |
| `modules.yaml`     | boolean | `false` | Required for parsing yaml blocks                                          |                     |
| `modules.cmp`      | boolean | `false` | Required if you wish to enable completion for `nvim-cmp`                  |                     |

</details>

<details>
    <summary>
        <code>create_dirs = {...</code>
    </summary>

<details>
    <summary>
        View as Lua table
    </summary>

```lua
require('mkdnflow').setup({
    create_dirs = true,
})
```

</details>

| Option        | Type    | Default | Description                                                             | Possible values                                                                                                                                                                                                                                                               | Note |
| ------------- | ------- | ------- | ----------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---- |
| `create_dirs` | boolean | `true`  | Whether missing directories will be created when following a local link | `true`: Directories referenced in a link will be (recursively) created if they do not exist<br>`false` No action will be taken when directories referenced in a link do not exist. Neovim will open a new file, but you will get an error when you attempt to write the file. |      |

</details>

<details>
    <summary>
        <code>perspective = {...</code>
    </summary>

<details>
    <summary>
        View as Lua table
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

</details>

| Option                     | Type            | Default     | Description                                                                                                                                                                                                                                  | Possible values                                                                                                                                                                                                                                                                                                                                                                                    | Note |
| -------------------------- | --------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---- |
| `perspective.priority`     | string          | `'first'`   | Specifies the priority perspective to take when interpreting link paths                                                                                                                                                                      | `'first'`: Links will be interpreted relative to the first-opened file (when the current instance of Neovim was started)<br>`'current'`: Links will be interpreted relative to the current file<br>`'root'`: Links will be interpreted relative to the root directory of the current notebook (requires `perspective.root_tell` to be specified)                                                   |      |
| `perspective.fallback`     | string          | `'current'` | Specifies the backup perspective to take if priority isn't possible (e.g. if it is `'root'` but no root directory is found)                                                                                                                  | `'first'`: (see above)<br>`'current'` (default): (see above)<br>`'root'`: (see above)                                                                                                                                                                                                                                                                                                              |      |
| `perspective.root_tell`    | string\|boolean | `false`     | Any arbitrary filename by which the plugin can uniquely identify the root directory of the current notebook. If `false` is used instead, the plugin will never search for a root directory, even if `perspective.priority` is set to `root`. | Any filename                                                                                                                                                                                                                                                                                                                                                                                       |      |
| `perspective.nvim_wd_heel` | boolean         | `false`     | Specifies whether changes in perspective will result in corresponding changes to Neovim's working directory                                                                                                                                  | `true`: Changes in perspective will be reflected in the nvim working directory. (In other words, the working directory will "heel" to the plugin's perspective.) This helps ensure (at least) that path completions (if using a completion plugin with support for paths) will be accurate and usable.<br>`false`: Neovim's working directory will not be affected by Mkdnflow.                    |      |
| `perspective.update`       | update          | `false`     | Determines whether the plugin looks to determine if a followed link is in a different notebook/wiki than before. If it is, the perspective will be updated. Requires `root_tell` to be defined and `priority` to be `root`.                  | `true`: Perspective will be updated when following a link to a file in a separate notebook/wiki (or navigating backwards to a file in another notebook/wiki).<br>`false`: Perspective will be not updated when following a link to a file in a separate notebook/wiki. Under the hood, links in the file in the separate notebook/wiki will be interpreted relative to the original notebook/wiki. |      |

</details>

<details>
    <summary>
        <code>filetypes = {...</code>
    </summary>

<details>
    <summary>
        View as Lua table
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

</details>

| Option               | Type    | Default | Description                                                         | Possible values                                                                                                                          | Note |
| -------------------- | ------- | ------- | ------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ---- |
| `filetypes.md`       | boolean | true    | Whether the plugin should activate for markdown files               | `true`: The plugin will be enabled for files with the extension<br>`false`: The plugin will remain disabled for files with the extension |      |
| `filetypes.rmd`      | boolean | true    | Whether the plugin should activate for rmarkdown files              | (see above)                                                                                                                              |      |
| `filetypes.markdown` | boolean | true    | Whether the plugin should activate for markdown files               | (see above)                                                                                                                              |      |
| `filetypes.<ext>`    | boolean | N/A     | Whether the plugin should activate for files with extension `<ext>` | (see above)                                                                                                                                         |      |

NOTE: This functionality references the file's extension. It does not rely on Neovim's filetype recognition. The extension must be provided in lower case because the plugin converts file names to lowercase. Any arbitrary extension can be supplied. Setting an extension to `false` is the same as not including it in the list.

</details>

<details>
    <summary>
        <code>wrap = {...</code>
    </summary>

<details>
    <summary>
        View as Lua table
    </summary>

```lua
require('mkdnflow').setup({
    wrap = true,
})
```

</details>

| Option | Type    | Default | Description                                                                                                                                                 | Possible values                                                                                                                                                                                                                                                     | Note |
| ------ | ------- | ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---- |
| `wrap` | boolean | `false` | Whether the cursor should jump back to the beginning of the document when jumping to links or other objects and the last such object in the file is reached | `true`: When jumping to next/previous links or headings, the cursor will continue searching at the beginning/end of the file<br>`false` (default): When jumping to next/previous links or headings, the cursor will stop searching at the end/beginning of the file |      |

</details>

<details>
    <summary>
        <code>bib = {...</code>
    </summary>

<details>
    <summary>
        View as Lua table
    </summary>

```lua
require('mkdnflow').setup({
    bib = {
        default_path = nil,
        find_in_root = true,
    },
})
```

</details>

| Option             | Type        | Default | Description                                                                                                      | Possible values                                                                                                                                                                                                                                                                                                                                                                                                                                     | Note |
| ------------------ | ----------- | ------- | ---------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---- |
| `bib.default_path` | string\|nil | `nil`   | Specifies a path to a default .bib file to look for citation keys in (need not be in root directory of notebook) | A path                                                                                                                                                                                                                                                                                                                                                                                                                                              |      |
| `bib.find_in_root` | boolean     | `true`  | Whether Mkdnflow should look for .bib files in the notebook's root directory (where `root_tell` is)              | `true` (default): When `perspective.priority` is also set to `root` (and a root directory was found), the plugin will search for bib files to reference in the notebook's top-level directory. If `bib.default_path` is also specified, the default path will be appended to the list of bib files found in the top level directory so that it will also be searched.<br>`false`: The notebook's root directory will not be searched for bib files. |      |

</details>

<details>
    <summary>
        <code>silent = {...</code>
    </summary>

<details>
    <summary>
        View as Lua table
    </summary>

```lua
require('mkdnflow').setup({
    silent = false,
})
```

</details>

| Option   | Type    | Default | Description                                                       | Possible values                                                                                                                                                                                                                         | Note |
| -------- | ------- | ------- | ----------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---- |
| `silent` | boolean | `false` | Whether the plugin will display various notifications or warnings | `true`: The plugin will not display any messages in the console except compatibility warnings related to your config<br>`false` (default): The plugin will display messages to the console (all messages from the plugin start with ⬇️ ) |      |

</details>

<details>
    <summary>
        <code>cursor = {...</code>
    </summary>

<details>
    <summary>
        View as Lua table
    </summary>

```lua
require('mkdnflow').setup({
    cursor = {
        jump_patterns = nil,
    },
})
```

</details>

| Option                 | Type       | Default | Description                                                                       | Possible values                                                                                                                                                                                                                                                                      | Note |
| ---------------------- | ---------- | ------- | --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---- |
| `cursor.jump_patterns` | table\|nil | `nil`   | A list of Lua regex patterns to jump to using `:MkdnNextLink` and `:MkdnPrevLink` | `nil` (default): When `nil`, the [default jump patterns](#jump-to-links-headings) for the configured link style are used (markdown-style links by default)<br>table of custom Lua regex patterns<br>`{}` (empty table) to disable link jumping without disabling the `cursor` module |      |

</details>

<details>
    <summary>
        <code>links = {...</code>
    </summary>

<details>
    <summary>
        View as Lua table
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

</details>

| Option                           | Type              | Default                                                                                                                                                                     | Description                                                                                                                                                                                                                      | Possible values                                                                                                                                                                                                                                                                                                                                     | Note |
| -------------------------------- | ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---- |
| `links.style`                    | string            | `'markdown'`                                                                                                                                                                |                                                                                                                                                                                                                                  | `'markdown'`: Links will be expected in the standard markdown format: `[<title>](<source>)`<br>`'wiki'`: Links will be expected in the unofficial wiki-link style, specifically the [title-after-pipe format](https://github.com/jgm/pandoc/pull/7705): `[[<source>\|<title>]]`.                                                                    |      |
| `links.name_is_source`           | boolean           | `false`                                                                                                                                                                     |                                                                                                                                                                                                                                  | `true`: Wiki-style links will be created with the source and name being the same (e.g. `[[Link]]` will display as "Link" and go to a file named "Link.md")<br>`false` (default): Wiki-style links will be created with separate name and source (e.g. `[[link-to-source\|Link]]` will display as "Link" and go to a file named "link-to-source.md") |      |
| `links.conceal`                  | boolean           | `false`                                                                                                                                                                     |                                                                                                                                                                                                                                  | `true`: Link sources and delimiters will be concealed (depending on which link style is selected)<br>`false` (default): Link sources and delimiters will not be concealed by mkdnflow                                                                                                                                                               |      |
| `links.context`                  | integer           | `0`                                                                                                                                                                         |                                                                                                                                                                                                                                  | `<n>`: When following or jumping to links, consider `<n>` lines before and after a given line (useful if you ever permit links to be interrupted by a hard line break)                                                                                                                                                                              |      |
| `links.implicit_extension`       | string            | `nil`                                                                                                                                                                       | A string that instructs the plugin (a) how to _interpret_ links to files that do not have an extension, and (b) how to create new links from the word under cursor or text selection.                                            | `nil` (default): Extensions will be explicit when a link is created and must be explicit in any notebook link.<br>`<any extension>` (e.g. `'md'`): Links without an extension (e.g. `[Homepage](index)`) will be interpreted with the implicit extension (e.g. `index.md`), and new links will be created without an extension.                     |      |
| `links.transform_explicit`       | function\|boolean | <pre lang='lua'>function(text)&#13;    text = text:gsub(" ", "-")&#13;    text = text:lower()&#13;    text = os.date('%Y-%m-%d_') .. text&#13;    return text&#13;end</pre> | A function that transforms the text to be inserted as the source/path of a link when a link is created. Anchor links are not currently customizable. For an example, see the sample recipes.                                     | A function or `false`                                                                                                                                                                                                                                                                                                                               |      |
| `links.transform_implicit`       | function\|boolean | `false`                                                                                                                                                                     | A function that transforms the path of a link immediately before interpretation. It does not transform the actual text in the buffer but can be used to modify link interpretation. For an example, see the sample recipe below. | A function or `false`                                                                                                                                                                                                                                                                                                                               |      |
| `links.create_on_follow_failure` | boolean           | `true`                                                                                                                                                                      | Whether a link should be created if there is no link to follow under the cursor.                                                                                                                                                 | `true`: Create a link if there's no link to follow<br>`false`: Do not create a link if there's no link to follow                                                                                                                                                                                                                                    |      |


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

</details>

<details>
    <summary>
        <code>new_file_template = {...</code>
    </summary>

<details>
    <summary>
        View as Lua table
    </summary>

```lua
require('mkdnflow').setup({
    new_file_template = {
        use_template = false,
        placeholders = {
            before = {
                title = 'link_title',
                date = 'os_date',
            },
            after = {},
        },
        template = '# {{ title }}',
    },
})
```

</details>

| Option                                  | Type                    | Default                                                                              | Description                                                                                                                                  | Possible values                                                                                                                                                                                                                       | Note |
| --------------------------------------- | ----------------------- | ------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---- |
| `new_file_template.use_template`        | boolean                 | `false`                                                                              |                                                                                                                                              | `true`: the template is filled in (if it contains placeholders) and inserted into any new buffers entered by following a link to a buffer that doesn't exist yet<br>`false`: no templates are filled in and inserted into new buffers |      |
| `new_file_template.placeholders.before` | table (dictionary-like) | <pre lang='lua'>{&#13;    title = 'link_title',&#13;    date = 'os_date'&#13;}</pre> | A table whose keys are placeholder names pointing to functions to be evaluated immediately before the buffer is opened in the current window |                                                                                                                                                                                                                                       |      |
| `new_file_template.placeholders.after`  | table (dictionary-like) | `{}`                                                                                 | A table hose keys are placeholder names pointing to functions to be evaluated immediately after the buffer is opened in the current window   |                                                                                                                                                                                                                                       |      |
| `new_file_template.template`            | string                  | `'# {{ title }}'`                                                                    | A string, optionally containing placeholder names, that will be inserted into new buffers                                                    |                                                                                                                                                                                                                                       |      |

</details>

<details>
    <summary>
        <code>to_do = {...</code>
    </summary>

<details>
    <summary>
        View as Lua table
    </summary>

```lua
```

</details>

| Option | Type | Default | Description | Possible values | Note |
| ------ | ---- | ------- | ----------- | --------------- | ---- |
|        |      |         |             |                 |      |

</details>

#### `to_do` (dictionary-like table)
* `to_do.statuses` (array-like table): A list of tables, each of which represents a to-do status and minimally has a `name` key and a `symbol` key, optionally also a `legacy_symbols` key with a table value. An arbitrary number of to-do statuses can be provided, but built-in functionality only works with recognized status names (see `to_do.statuses[].name` below, as well as [To-do lists](#to-do-lists))
    * `to_do.statuses[n].name` (string): The name of the to-do status. The recognized names are `not_started`, `in_progress`, and `complete`.
    * `to_do.statuses[n].symbol` (string): The symbol to use for the status. Up to four bytes are permitted, but the symbol must only be one character.
    * `to_do.statuses[n].legacy_symbols` (array-like table): A list of symbols previously used for the status. This will ensure compatibility with any to-do lists you have previously made with different symbols. Not providing legacy symbols will mean that you may not be able to toggle the status of old to-do lists that use other status symbols.
    * `to_do.statuses[n].sort` (dictionary-like table)
        * `to_do.statuses[n].sort.section` (integer): The section in which items of this status should be placed when sorted. A section refers to a segment of a to-do list. If you want items with the `'in_progress'` status to be first in the list, you would set this option to `1` for the status (this is the default section for `'in_progress'` status items).
        * `to_do.statuses[n].sort.position` (string)
            * `'top'`: Place the item whose status was just changed at the top of its corresponding section.
            * `'bottom'`: Place the item whose status was just changed at the bottom of its corresponding section.
            * `'relative'`: Maintain the order of the item whose status was just changed (relative to the other members of its section). For example, if an item at the bottom of a to-do list is changed `'not_started'` and there are already `'not_started'` items at the top of the list, a position option of `'relative'` for `'not_started'` will bring the bottom of the `'not_started'` section. With the same setting, an item located above other `'not_started'` items would be placed at the top of the `'not_started'` section.
    * `to_do.statuses[n].propagate` (dictionary-like table)
        * `to_do.statuses[n].propagate.up` (function): A function that will accept one argument (an instance of the to-do list class) and return a valid to-do status (a status name that matches the name of a status in the `to_do.statuses` table). The list that is passed into this function is the list that hosts the to-do item whose status was just changed. The return value should be the desired value of the parent, based on whatever logic is provided in the function. `nil` should be returned if the desired outcome is to leave the parent's status as is.
        * `to_do.statuses[n].propagate.down` (function): A function that will accept one argument (an instance of the to-do list class) and return a list of valid to-do status names (status names must match the name of a status in the `to_do.statuses` table). The list that is passed into this function is the child list of the to-do item whose status was just changed. The list of return values should be the desired values of each child in the list, based on whatever logic is provided in the function. `nil` or an empty table should be returned if the desired outcome is to leave the children's status as is.
* `to_do.sort` (dictionary-like table)
    * `to_do.sort.on_status_change` (boolean): Whether to sort a to-do list (or sub-to-do list) on a status change that is completed using the plugin's functionality.
    * `to_do.sort.recursive` (boolean): (not yet implemented) Whether the sort should apply to parent items whose statuses are updated when a child is updated.
        * `true`: Recursively sort the host list of the parent until the root of the list is reached.
        * `false`: Only sort the (sub-)list that immediately hosts the to-do item whose status was just changed.
    * `to_do.sort.cursor_behavior` (dictionary-like table)
    * `to_do.sort.cursor_behavior.track` (boolean): Whether to move the cursor so that it remains on the same to-do item, even after a to-do list sort relocates the item.
* `to_do.status_propagation` (dictionary-like table)
    * `to_do.status_propagation.up` (boolean): Whether a status change should propagate upwards along the to-do item's parental lineage. If `true`, the logic provided in `to_do.statuses[n].propagate.up` will be used to determine the target status of the parent item. Applies recursively.
    * `to_do.status_propagation.down` (boolean): Whether a status change should propagate downwards to the descendants of the to-do item. If `true`, the logic provided in `to_do.statuses[n].propagate.down` will be used to determine the target statuses of the children. Applies recursively.

> [!WARNING]
> **The following to-do configuration options are deprecated. Please use the `to_do.statuses` table instead. Continued support for these options is temporarily provided by a compatibility layer that will be removed in the near future.**
> * `to_do.symbols` (array-like table): A list of symbols (each no more than one character) that represent to-do list completion statuses. `MkdnToggleToDo` references these when toggling the status of a to-do item. Three are expected: one representing not-yet-started to-dos (default: `' '`), one representing in-progress to-dos (default: `-`), and one representing complete to-dos (default: `X`).
> * `to_do.not_started` (string): Stipulates which symbol represents a not-yet-started to-do (default: `' '`)
> * `to_do.in_progress` (string):  Stipulates which symbol represents an in-progress to-do (default: `'-'`)
> * `to_do.complete` (string):  Stipulates which symbol represents a complete to-do (default: `'X'`)
> * `to_do.update_parents` (boolean): Whether parent to-dos' statuses should be updated based on child to-do status changes performed via `MkdnToggleToDo`
>    * `true` (default): Parent to-do statuses will be inferred and automatically updated when a child to-do's status is changed
>    * `false`: To-do items can be toggled, but parent to-do statuses (if any) will not be automatically changed

<details>
    <summary>
        <code>foldtext = {...</code>
    </summary>

<details>
    <summary>
        View as Lua table
    </summary>

```lua
```

</details>

| Option | Type | Default | Description | Possible values | Note |
| ------ | ---- | ------- | ----------- | --------------- | ---- |
|        |      |         |             |                 |      |

</details>

#### `foldtext` (dictionary-like table)
* `foldtext.object_count` (boolean): Whether to show a count of all the objects inside of a folded section (default: `true`)
* `foldtext.object_count_icon_set` (string or dictionary-like table): Which icon set to use to represent the counted objects. The pre-packaged icon sets are named `'emoji'` (default), `'plain'`, and `'nerdfont'`.
* `foldtext.object_count_opts` (function => table): A function returning a dictionary-like table specifying various attributes of the objects to be counted (default: `function() return require('mkdnflow').foldtext.default_count_opts end`), where the keys are the names of the objects to be counted. If the names are one of the `{name}`s `tbl`, `ul`, `ol`, `todo`, `img`, `fncblk`, `sec`, `par`, or `link`, any of the following entries will be filled in with the default value if you do not provide a value for it in your custom table (see below this list for a sample foldtext configuration 'recipe'):
    * `foldtext.object_count_opts().{name}.icon` (string): The icon to use to represent the counted object (default: the value for `{name}` in the emoji icon set, or if another icon set is named, the value for `{name}` in whichever icon set you've specified)
    * `foldtext.object_count_opts().{name}.count_method.prep` (function => string): A function that performs any preprocessing manipulations to the text before the pattern is used to count objects according to the tallying method specified. This may be useful if it helps you write a simpler pattern (default: Only `tbl` \[table\] and `fncblk` \[fenced code block\] have default preprocessing functions:
        * `tbl`'s preprocessor strips wiki-style links from the document so that the vertical bar is not counted as part of a table
        * `fncblk`'s preprocessor adds a newline character to the beginning of the section if the section starts immediately with a fenced code block).
    * `foldtext.object_count_opts().{name}.count_method.pattern` (table): An array-like table of strings (Lua patterns). Used differently depending on the object type's corresponding tally method (see below).
    * `foldtext.object_count_opts().{name}.count_method.tally` (string): One of three tallying methods to use for the object type: `'blocks'`, `'line_matches'`, or `'global_matches'`. The effects of each of these are as follows:
        * `'blocks'`: If this tally method is used for an object type, all contiguous _blocks_ of lines matching the pattern(s) for a particular type are counted. (Patterns for this method need to cause a successful match if part of a multi-line object occurs on the line—for instance, `'^[-*] '` will match a line with an unordered list item using `*` or `-` as an item marker.) `tbl`, `ul`, `ol`, and `todo` use this method by default.
        * `'line_matches'`: If this tally method is used for an object type, one or more matches on a line will count as one match. (Patterns for this method need to cause a successful match if the object occurs on the line—for instance, `'^#+%s'` will match a section heading beginning with at least one hash.) `sec` uses this method by default.
        * `'global_matches'`: If this tally method is used for an object type, every match of an instance across the entire fold section is counted individually. Patterns may take multiple lines into account because the string searched is a concatenation of all lines in the folded section (separated by newlines characters `\n`). (Patterns for this method should match every individual occurrence of the object—for instance, `'%b[]%b()'` will match every markdown-style link.) `img`, `fncblk`, `par`, and `link` use this method by default.
* `foldtext.line_count` (boolean): Whether to show the count of lines contained in the fold (default: `true`)
* `foldtext.line_percentage` (boolean): Whether to show the percentage of document lines contained in the fold (default: `true`)
* `foldtext.word_count` (boolean): Whether to show the count of words contained in the fold (default: `false`)
* `foldtext.title_transformer` (function => \[function => string\]): A function that returns a function that returns a string. This function accepts a string (the text of the first line in the fold \[a section heading\]) and returns a transformed string for use in the foldtext. (default: `function() require('mkdnflow').foldtext.default_title_transformer end`)
* `foldtext.fill_chars` (dictionary-like table)
    * `foldtext.fill_chars.left_edge` (string): The character(s) to use at the very left edge of the foldtext, adjacent to the left edge of the window (default: `'⢾⣿⣿'`)
    * `foldtext.fill_chars.right_edge` (string): The character(s) to use at the very right edge of the foldtext, adjacent to the right edge of the window (default: `'⣿⣿⡷'`)
    * `foldtext.fill_chars.item_separator` (string): The character(s) used to separate the items within a section, such as the various object counts (default: `' · '`)
    * `foldtext.fill_chars.section_separator` (string): The character(s) used to separate _adjacent_ sections (default: `' ⣹⣿⣏ '`). At time of writing, the only adjacent sections are the item-count section and the line- and word-count section (both on the right end of the foldtext). The section title is a separate section (on the left) but is not adjacent to any other sections.
    * `foldtext.fill_chars.left_inside` (string): The character(s) used to separate  (default: `' ⣹'`)
    * `foldtext.fill_chars.right_inside` (string): (default: `'⣏ '`)
    * `foldtext.fill_chars.middle` (string): (default: `'⣿'`)

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
                fncblk = {
                    -- Override the icon for fenced code blocks with 
                    icon = ' '
                }
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

<details>
    <summary>
        <code>tables = {...</code>
    </summary>

<details>
    <summary>
        View as Lua table
    </summary>

```lua
```

</details>

| Option | Type | Default | Description | Possible values | Note |
| ------ | ---- | ------- | ----------- | --------------- | ---- |
|        |      |         |             |                 |      |

</details>

#### `tables` (dictionary-like table)
* `tables.trim_whitespace` (boolean): Whether extra whitespace should be trimmed from the end of a table cell when a table is formatted (default: `true`)
* `tables.format_on_move` (boolean): Whether tables should be formatted each time the cursor is moved via MkdnTable{Next/Prev}{Cell/Row} (default: `true`)
* `tables.auto_extend_rows` (boolean): Whether calling `MkdnTableNextRow` when the cursor is in the last row should add another row instead of leaving the table (default: `false`)
* `tables.auto_extend_cols` (boolean): Whether calling `MkdnTableNextCol` when the cursor is in the last cell should add another column instead of jumping to the first cell of the next row (default: `false`)
* 🆕 `tables.style` (dictionary-like table)
    * 🆕 `tables.style.cell_padding` (integer): Number of spaces to use as cell padding (default: `1`)
    * 🆕 `tables.style.separator_padding` (integer): Number of spaces to use as cell padding in the row that separates a header row from the table body, if present (default: `1`)
    * 🆕 `tables.style.outer_pipes` (boolean): Whether to use (`true`) or exclude (`false`) outer pipes when formatting a table or inserting a new table (default: `true`)
    * 🆕 `tables.style.mimic_alignment` (boolean): Whether to mimic the cell alignment indicated in the separator row when formatting the table; left-alignment always used when alignment not specified (default: `true`)

<details>
    <summary>
        <code>yaml = {...</code>
    </summary>

<details>
    <summary>
        View as Lua table
    </summary>

```lua
```

</details>

| Option | Type | Default | Description | Possible values | Note |
| ------ | ---- | ------- | ----------- | --------------- | ---- |
|        |      |         |             |                 |      |

</details>

#### `yaml` (dictionary-like table)
* `yaml.bib` (dictionary-like table)
    * `yaml.bib.override` (boolean): Whether or not a bib path specified in a yaml block should be the only source considered for bib references in that file (default: `false`)

<details>
    <summary>
        <code>mappings = {...</code>
    </summary>

<details>
    <summary>
        View as Lua table
    </summary>

```lua
```

</details>

| Option | Type | Default | Description | Note |
| ------ | ---- | ------- | ----------- | ---- |
|        |      |         |             |      |

</details>

#### `mappings` (dictionary-like table)
* `mappings.<name of command>` (array-like table or `false`)
    * `mappings.<name of command>[1]` string or array table representing the mode (or array of modes) that the mapping should apply in (`'n'`, `'v'`, etc.)
    * `mappings.<name of command>[2]` string representing the keymap (e.g. `'<Space>'`)
    * set `mappings.<name of command> = false` to disable default mapping without providing a custom mapping

NOTE: `<name of command>` should be the name of a commands defined in `mkdnflow.nvim/plugin/mkdnflow.lua` (see :h Mkdnflow-commands for a list).

## 🔍 Usage

### 🛠️ Commands

### ⌨️  Mappings

## ❓ Frequently asked questions

## 🤝 Contributing

## 📜 License

## 🐛 Troubleshooting

## 📋 Quick reference

## 🔢 Version information

## 🔗 Related projects
