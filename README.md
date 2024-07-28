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
    2. [⚙️  Advanced configuration](#-advanced-configuration)
        1. [🎨 Configuration options](#-configuration-options)
4. [🔍 Usage](#-usage)
    1. [🛠️ Commands](#-commands)
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


| Option             | Type      | Default | Description                                                               |
| ------------------ | --------- | ------- | ------------------------------------------------------------------------- |
| `modules.bib`      | `boolean` | `true`  | Required for parsing `.bib` files and following citations.                |
| `modules.buffers`  | `boolean` | `true`  | Required for backward and forward navigation through buffers.             |
| `modules.conceal`  | `boolean` | `true`  | Required if you wish to enable link concealing. See `links.conceal`.      |
| `modules.cursor`   | `boolean` | `true`  | Required for cursor navigation (jumping to links, headings, etc.).        |
| `modules.folds`    | `boolean` | `true`  | Required for folding by section.                                          |
| `modules.foldtext` | `boolean` | `true`  | Required for prettified foldtext.                                         |
| `modules.links`    | `boolean` | `true`  | Required for creating, destroying, and following links.                   |
| `modules.lists`    | `boolean` | `true`  | Required for working in and manipulating lists, etc.                      |
| `modules.to_do`    | `boolean` | `true`  | Required for mnipulating to-do statuses/lists, toggling to-do items, etc. |
| `modules.paths`    | `boolean` | `true`  | Required for link interpretation, link following, etc.                    |
| `modules.tables`   | `boolean` | `true`  | Required for table management, navigation, formatting, etc.               |
| `modules.yaml`     | `boolean` | `false` | Required for parsing yaml blocks.                                         |
| `modules.cmp`      | `boolean` | `false` | Required if you wish to enable completion for `nvim-cmp`.                 |

---

</details>

<details>
    <summary>
        <code>create_dirs = ...</code>
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

| Option        | Type      | Default | Description                                                             | Possible values                                                                                                                                                                                                                                                                |
| ------------- | --------- | ------- | ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `create_dirs` | `boolean` | `true`  | Whether missing directories will be created when following a local link | `true`: Directories referenced in a link will be (recursively) created if they do not exist<br>`false`: No action will be taken when directories referenced in a link do not exist. Neovim will open a new file, but you will get an error when you attempt to write the file. |

---

</details>

<details>
    <summary>
        <code>perspective = ...</code>
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

| Option                     | Type              | Default     | Description                                                                                                                                                                                                                                  | Possible values                                                                                                                                                                                                                                                                                                                                                                                    |
| -------------------------- | ----------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `perspective.priority`     | `string`          | `'first'`   | Specifies the priority perspective to take when interpreting link paths                                                                                                                                                                      | `'first'`*: Links will be interpreted relative to the first-opened file (when the current instance of Neovim was started)<br>`'current'`: Links will be interpreted relative to the current file<br>`'root'`: Links will be interpreted relative to the root directory of the current notebook (requires `perspective.root_tell` to be specified)                                                  |
| `perspective.fallback`     | `string`          | `'current'` | Specifies the backup perspective to take if priority isn't possible (e.g. if it is `'root'` but no root directory is found)                                                                                                                  | `'first'`: (see above)<br>`'current'`*: (see above)<br>`'root'`: (see above)                                                                                                                                                                                                                                                                                                                       |
| `perspective.root_tell`    | `string\|boolean` | `false`     | Any arbitrary filename by which the plugin can uniquely identify the root directory of the current notebook. If `false` is used instead, the plugin will never search for a root directory, even if `perspective.priority` is set to `root`. | Any filename                                                                                                                                                                                                                                                                                                                                                                                       |
| `perspective.nvim_wd_heel` | `boolean`         | `false`     | Specifies whether changes in perspective will result in corresponding changes to Neovim's working directory                                                                                                                                  | `true`: Changes in perspective will be reflected in the nvim working directory. (In other words, the working directory will "heel" to the plugin's perspective.) This helps ensure (at least) that path completions (if using a completion plugin with support for paths) will be accurate and usable.<br>`false`: Neovim's working directory will not be affected by Mkdnflow.                    |
| `perspective.update`       | `boolean`         | `false`     | Determines whether the plugin looks to determine if a followed link is in a different notebook/wiki than before. If it is, the perspective will be updated. Requires `root_tell` to be defined and `priority` to be `root`.                  | `true`: Perspective will be updated when following a link to a file in a separate notebook/wiki (or navigating backwards to a file in another notebook/wiki).<br>`false`: Perspective will be not updated when following a link to a file in a separate notebook/wiki. Under the hood, links in the file in the separate notebook/wiki will be interpreted relative to the original notebook/wiki. |

---

</details>

<details>
    <summary>
        <code>filetypes = ...</code>
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

| Option               | Type      | Default | Description                                                         | Possible values                                                                                                                           |
| -------------------- | --------- | ------- | ------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `filetypes.md`       | `boolean` | `true`  | Whether the plugin should activate for markdown files               | `true`*: The plugin will be enabled for files with the extension<br>`false`: The plugin will remain disabled for files with the extension |
| `filetypes.rmd`      | `boolean` | `true`  | Whether the plugin should activate for rmarkdown files              | (see above)                                                                                                                               |
| `filetypes.markdown` | `boolean` | `true`  | Whether the plugin should activate for markdown files               | (see above)                                                                                                                               |
| `filetypes.<ext>`    | `boolean` | --      | Whether the plugin should activate for files with extension `<ext>` | (see above)                                                                                                                               |

> ![NOTE]
> This functionality references the file's extension. It does not rely on Neovim's filetype recognition. The extension must be provided in lower case because the plugin converts file names to lowercase. Any arbitrary extension can be supplied. Setting an extension to `false` is the same as not including it in the list.

---

</details>

<details>
    <summary>
        <code>wrap = ...</code>
    </summary>

<details>
    <summary>
        View as Lua table
    </summary>

```lua
require('mkdnflow').setup({
    wrap = false,
})
```

</details>

| Option | Type      | Default | Description                                                                                                                                                 | Possible values                                                                                                                                                                                                                                            |
| ------ | --------- | ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `wrap` | `boolean` | `false` | Whether the cursor should jump back to the beginning of the document when jumping to links or other objects and the last such object in the file is reached | `true`: When jumping to next/previous links or headings, the cursor will continue searching at the beginning/end of the file<br>`false`*: When jumping to next/previous links or headings, the cursor will stop searching at the end/beginning of the file |

---

</details>

<details>
    <summary>
        <code>bib = ...</code>
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

| Option             | Type          | Default | Description                                                                                                      | Possible values                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ------------------ | ------------- | ------- | ---------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `bib.default_path` | `string\|nil` | `nil`   | Specifies a path to a default .bib file to look for citation keys in (need not be in root directory of notebook) | A path                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| `bib.find_in_root` | `boolean`     | `true`  | Whether Mkdnflow should look for .bib files in the notebook's root directory (where `root_tell` is)              | `true`*: When `perspective.priority` is also set to `root` (and a root directory was found), the plugin will search for bib files to reference in the notebook's top-level directory. If `bib.default_path` is also specified, the default path will be appended to the list of bib files found in the top level directory so that it will also be searched.<br>`false`: The notebook's root directory will not be searched for bib files. |

---

</details>

<details>
    <summary>
        <code>silent = ...</code>
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

| Option   | Type      | Default | Description                                                       | Possible values                                                                                                                                                                                                                |
| -------- | --------- | ------- | ----------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `silent` | `boolean` | `false` | Whether the plugin will display various notifications or warnings | `true`: The plugin will not display any messages in the console except compatibility warnings related to your config<br>`false`*: The plugin will display messages to the console (all messages from the plugin start with ⬇️ ) |

---

</details>

<details>
    <summary>
        <code>cursor = ...</code>
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

| Option                 | Type         | Default | Description                                                                       | Possible values                                                                                                                                                                                                                                                                      |
| ---------------------- | ------------ | ------- | --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `cursor.jump_patterns` | `table\|nil` | `nil`   | A list of Lua regex patterns to jump to using `:MkdnNextLink` and `:MkdnPrevLink` | `nil`*: When `nil`, the [default jump patterns](#jump-to-links-headings) for the configured link style are used (markdown-style links by default)<br>table of custom Lua regex patterns<br>`{}` (empty table) to disable link jumping without disabling the `cursor` module |

---

</details>

<details>
    <summary>
        <code>links = ...</code>
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
---

</details>

| Option                           | Type                               | Default                                                                                                                                                                                                                        | Description                                                                                                                                                                                                                      | Possible values                                                                                                                                                                                                                                                                                                                                     |
| -------------------------------- | ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `links.style`                    | `string`                           | `'markdown'`                                                                                                                                                                                                                   |                                                                                                                                                                                                                                  | `'markdown'`: Links will be expected in the standard markdown format: `[<title>](<source>)`<br>`'wiki'`: Links will be expected in the unofficial wiki-link style, specifically the [title-after-pipe format](https://github.com/jgm/pandoc/pull/7705): `[[<source>\|<title>]]`.                                                                    |
| `links.name_is_source`           | `boolean`                          | `false`                                                                                                                                                                                                                        |                                                                                                                                                                                                                                  | `true`: Wiki-style links will be created with the source and name being the same (e.g. `[[Link]]` will display as "Link" and go to a file named "Link.md")<br>`false` (default): Wiki-style links will be created with separate name and source (e.g. `[[link-to-source\|Link]]` will display as "Link" and go to a file named "link-to-source.md") |
| `links.conceal`                  | `boolean`                          | `false`                                                                                                                                                                                                                        |                                                                                                                                                                                                                                  | `true`: Link sources and delimiters will be concealed (depending on which link style is selected)<br>`false` (default): Link sources and delimiters will not be concealed by mkdnflow                                                                                                                                                               |
| `links.context`                  | `integer`                          | `0`                                                                                                                                                                                                                            |                                                                                                                                                                                                                                  | `<n>`: When following or jumping to links, consider `<n>` lines before and after a given line (useful if you ever permit links to be interrupted by a hard line break)                                                                                                                                                                              |
| `links.implicit_extension`       | `string`                           | `nil`                                                                                                                                                                                                                          | A string that instructs the plugin (a) how to _interpret_ links to files that do not have an extension, and (b) how to create new links from the word under cursor or text selection.                                            | `nil` (default): Extensions will be explicit when a link is created and must be explicit in any notebook link.<br>`<any extension>` (e.g. `'md'`): Links without an extension (e.g. `[Homepage](index)`) will be interpreted with the implicit extension (e.g. `index.md`), and new links will be created without an extension.                     |
| `links.transform_explicit`       | `fun(string): string`<br>`boolean` | <details><summary>View Lua</summary><pre lang='lua'>function(text)&#13;    text = text:gsub(" ", "-")&#13;    text = text:lower()&#13;    text = os.date('%Y-%m-%d_') .. text&#13;    return text&#13;end</pre></details> | A function that transforms the text to be inserted as the source/path of a link when a link is created. Anchor links are not currently customizable. For an example, see the sample recipes.                                     | A function or `false`                                                                                                                                                                                                                                                                                                                               |
| `links.transform_implicit`       | `fun(string): string`<br>`boolean` | `false`                                                                                                                                                                                                                        | A function that transforms the path of a link immediately before interpretation. It does not transform the actual text in the buffer but can be used to modify link interpretation. For an example, see the sample recipe below. | A function or `false`                                                                                                                                                                                                                                                                                                                               |
| `links.create_on_follow_failure` | `boolean`                          | `true`                                                                                                                                                                                                                         | Whether a link should be created if there is no link to follow under the cursor.                                                                                                                                                 | `true`: Create a link if there's no link to follow<br>`false`: Do not create a link if there's no link to follow                                                                                                                                                                                                                                    |


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

<details>
    <summary>
        View as Lua table
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

</details>

| Option                                  | Type                      | Default                                                                              | Description                                                                                                                                  | Possible values                                                                                                                                                                                                                       |
| --------------------------------------- | ------------------------- | ------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `new_file_template.use_template`        | `boolean`                 | `false`                                                                              |                                                                                                                                              | `true`: the template is filled in (if it contains placeholders) and inserted into any new buffers entered by following a link to a buffer that doesn't exist yet<br>`false`: no templates are filled in and inserted into new buffers |
| `new_file_template.placeholders.before` | `table (dictionary-like)` | <details><summary>View Lua</summary><pre lang='lua'>{&#13;    title = 'link_title',&#13;    date = 'os_date'&#13;}</pre></details> | A table whose keys are placeholder names pointing to functions to be evaluated immediately before the buffer is opened in the current window |                                                                                                                                                                                                                                       |
| `new_file_template.placeholders.after`  | `table (dictionary-like)` | `{}`                                                                                 | A table hose keys are placeholder names pointing to functions to be evaluated immediately after the buffer is opened in the current window   |                                                                                                                                                                                                                                       |
| `new_file_template.template`            | `string`                  | `'# {{ title }}'`                                                                    | A string, optionally containing placeholder names, that will be inserted into new buffers                                                    |                                                                                                                                                                                                                                       |

---

</details>

<details>
    <summary>
        <code>to_do = ...</code>
    </summary>

<details>
    <summary>
        View as Lua table
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

</details>

| Option                                    | Type                                      | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| ----------------------------------------- | ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `to_do.highlight`                         | `boolean`                                 | `true`: Apply highlighting to to-do status markers and/or content (as defined in `to_do.statuses[*].highlight`).<br>`false`*: Do not apply any highlighting.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| `to_do.status_propagation.up`             | `boolean`                                 | `true`*: Update ancestor statuses (recursively) when a descendant status is changed. Updated according to logic provided in `to_do.statuses[*].propagate.up`.<br>`false`: Ancestor statuses are not affected by descendant status changes.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| `to_do.status_propagation.down`           | `boolean`                                 | `true`*: Update descendant statuses (recursively) when an ancestor's status is changed. Updated according to logic provided in `to_do.statuses[*].propagate.down`.<br>`false`: Descendant statuses are not affected by ancestor status changes.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| `to_do.sort_on_status_change`             | `boolean`                                 | `true`: Sort a to-do list when an item's status is changed.<br>`false`*: Leave all to-do items in their current position when an item's status is changed.<br>NOTE: This will not apply if the to-do item's status is changed manually (i.e. by typing or pasting in the status marker).                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `to_do.sort.recursive`                    | `boolean`                                 | `true`: `sort_on_status_change` applies recursively, sorting the host list of each successive parent until the root of the list is reached.<br>`false`*: `sort_on_status_change` only applies at the current to-do list level (not to the host list of the parent to-do item).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| `to_do.sort.cursor_behavior.track`        | `boolean`                                 | `true`*: Move the cursor so that it remains on the same to-do item, even after a to-do list sort relocates the item.<br>`false`: The cursor remains on its current line number, even if the to-do item is relocated by sorting.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| `to_do.statuses`                          | `table (array-like)`                      | A list of tables, each of which represents a to-do status. See options in the following rows. An arbitrary number of to-do status tables can be provided. See default statuses in the settings table.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| `to_do.statuses[*].name`                  | `string`                                  | The designated name of the to-do status.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `to_do.statuses[*].marker`                | `string`<br>`table`                       | The marker symbol to use for the status. The marker's string width must be 1.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| `to_do.statuses[*].highlight.marker`      | `table` (a highlight definition map)      | A table of highlight definitions to apply to a status marker, including brackets. See the `{val}` parameter of `:h nvim_set_hl` for possible options.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| `to_do.statuses[*].highlight.content`     | `table` (a highlight definition map)      | A table of highlight definitions to apply to the to-do item content (everything following the status marker). See the `{val}` parameter of `:h nvim_set-hl` for possible options.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| `to_do.statuses[*].exclude_from_rotation` | `boolean`                                 | `true`: When toggling/rotating a to-do item's status, exclude the current symbol from the list of symbols used.<br>`false`: Leave the symbol in the rotation.<br>NOTE: This setting is useful if, e.g., there is a status marker that you never want to manually set and only want to apply when automatically updating ancestors or descendants. See the `complete_pending` status in the sample recipe for an example.                                                                                                                                                                                                                                                                                                                                            |
| `to_do.statuses[*].sort.section`          | `integer`                                 | The integer should represent the linear section of the list in which items of this status should be placed when sorted. A section refers to a segment of a to-do list. If you want items with the `'in_progress'` status to be first in the list, you would set this option to `1` for the status (this is the default section for `'in_progress'` status items).<br>NOTE: Sections are not visually delineated in any way other than items with the same section number occurring on adjacent lines in the list.                                                                                                                                                                                                                                                   |
| `to_do.statuses[*].sort.position`         | `string`                                  | Where in its assigned section a to-do item should be placed:<br>`'top'`: Place a sorted item at the top of its corresponding section.<br>`'bottom'`: Place a sorted item at the bottom of its corresponding section.<br>`'relative'`: Maintain the current relative order of the sorted item whose status was just changed (vs. other list items). For example, if an item at the bottom of a to-do list is changed to `'not_started'` and there are already `'not_started'` items at the top of the list, the `'relative'` option for `'not_started'` will bring the sorted item to the bottom of the `'not_started'` section. With the same setting, an item located above other `'not_started'` items would be placed at the top of the `'not_started'` section. |
| `to_do.statuses[*].propagate.up`          | `fun(table: to_do_list): string`<br>`nil` | A function that will accept one argument (an instance of the to-do list class) and return a valid to-do status name (a status name that matches the name of a status in the `to_do.statuses` table). The list that is passed into this function is the list that hosts the to-do item whose status was just changed. The return value should be the desired value of the parent, based on whatever logic is provided in the function. `nil` should be returned if the desired outcome is to leave the parent's status as is.                                                                                                                                                                                                                                        |
| `to_do.statuses[*].propagate.down`        | `function(table: to_do_list): string[]`   | A function that will accept one argument (an instance of the to-do list class) and return a **list** of valid to-do status names (status names must match the name of some status in the `to_do.statuses` table). The list that is passed into this function will be the child list of the to-do item whose status was just changed. The list of return values should be the desired values of each child in the list, based on whatever logic is provided in the function. `nil` or an empty table should be returned if the desired outcome is to leave the children's status as is.                                                                                                                                                                              |

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

<details>
    <summary>
        View as Lua table
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

</details>

| Option                                                            | Type                                           | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| ----------------------------------------------------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `foldtext.object_count`                                           | `boolean`                                      | `true`*: Show a count of all objects inside of a folded section.<br>`false`: Do not show a count of any objects inside of a folded section.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| `foldtext.object_count_icon_set`                                  | `string`<br>`table (array-like)`               | `'emoji'`*: Use pre-defined emojis as icons for counted objects.<br>`'plain'`: Use pre-defined plaintext UTF-8 characters as icons for counted objects.<br>`'nerdfont'`: Use pre-defined nerdfont characters as icons for counted objects. Requires a nerdfont.<br>`table<string, string>`: Use custom mapping of object names to icons, object names being one of the keys in the table returned by `foldtext.object_count_opts()`.                                                                                                                                                                                                             |
| `foldtext.object_count_opts`                                      | `fun(): table<string, table>`                  | `function() return require('mkdnflow').foldtext.default_count_opts end`*: The default options table, which defines the final attributes of the objects to be counted, including its icon (taken from `foldtext.object_count_icon_set`) and a table defining how the object type should be counted (see below). The pre-defined object types are `tbl`, `ul`, `ol`, `todo`, `img`, `fncblk`, `sec`, `par`, and `link`.                                                                                                                                                                                                                            |
| `foldtext.object_count_opts().<object_name>.icon`                 | `string`                                       | The icon used to represent the object in the counts area of the custom foldtext. By default, this is a reference to the icon specified for `<object_name>` in `foldtext.object_count_icon_set`, as long as `<object_name>` is one of `tbl`, `ul`, `ol`, `todo`, `img`, `fncblk`, `sec`, `par`, and `link`. Otherwise, the icon will need to be defined here.                                                                                                                                                                                                                                                                                     |
| `foldtext.object_count_opts().<object_name>.count_method.prep`    | `fun(text: string): string`                    | A function that (optionally) performs preprocessing manipulations to the text before `pattern` is used to count objects according to the tallying method specified. The text passed into this function depends on the value of `tally` (see below). Only `tbl` (table) and `fncblk` (fenced code block) have default preprocessing functions (see `M.default_count_opts` in the `foldtext` module). A preprocessing function may be useful if it helps you write a simpler pattern, for instance.                                                                                                                                                |
| `foldtext.object_count_opts().<object_name>.count_method.pattern` | `table (array-like)`                           | An array-like table of strings (Lua patterns) that are used to count objects according to the object's specified `tally` method (see below).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| `foldtext.object_count_opts().<object_name>.count_method.tally`   | `string`                                       | `'blocks'`: The count is the number of line _clusters_ in the buffer in which each sub-line matches a pattern in `<object_name>`'s `pattern`. Objects counted using this method by default include `tbl`, `ul`, `ol`, and `todo`.<br>`'line_matches'`: The count is the number of lines that one of `<object_name>`'s patterns matches. Multiple matches on the line are not counted. The object counted using this method by default is `sec`.<br>`'global_matches'`: The count is the number of times the pattern is matched across the whole buffer. Objects counted using this method by default include `img`, `fncblk`, `par`, and `link`. |
| `foldtext.line_count`                                             | `boolean`                                      | `true`*: Show a count of the lines contained in the folded section.<br>`false`: Don't show a line count.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `foldtext.line_percentage`                                        | `boolean`                                      | `true`*: Show the percentage of document (buffer) lines contained in the folded section.<br>`false`: Don't show the percentage.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `foldtext.word_count`                                             | `boolean`                                      | `true`: Show a count of the _paragraph_ words in the folded section, ignoring words inside of other objects.<br>`false`*: Don't show a word count.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| `foldtext.title_transformer`                                      | `fun(): fun(line: string): string`             | A function _f_ that returns a function _g_, _g_ being a function that accepts a string and returns a potentially modified string. The string passed into the function will be the text of the first line in the fold (a section heading).                                                                                                                                                                                                                                                                                                                                                                                                        |
| `foldtext.fill_chars.left_edge`                                   | `string`                                       | The character(s) to use at the very left edge of the foldtext, adjacent to the left edge of the window. Default: `'⢾⣿⣿'`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| `foldtext.fill_chars.right_edge`                                  | `string`                                       | The character(s) to use at the very right edge of the foldtext, adjacent to the right edge of the window. Default: `'⣿⣿⡷'`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| `foldtext.fill_chars.item_separator`                              | `string`                                       | The character(s) used to separate the items within a section, such as the various object counts. Default: `' · '`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| `foldtext.fill_chars.section_separator`                           | `string`                                       | The character(s) used to separate _adjacent_ sections. At time of writing, the only adjacent sections are the item-count section and the line- and word-count section (both on the right end of the foldtext line). The section title is a separate section (on the left) but is not adjacent to any other sections, so it will not occur with this separator. Default: `' ⣹⣿⣏ '`                                                                                                                                                                                                                                                                |
| `foldtext.fill_chars.left_inside`                                 | `string`                                       | The character(s) used to separate the internal left edge of a span of `middle` fill characters. Default: `' ⣹'`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `foldtext.fill_chars.right_inside`                                | `string`                                       | The character(s) used to separate the internal right edge of a span of `middle` fill characters. Default: `'⣏ '`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| `foldtext.fill_chars.middle`                                      | `string`                                       | The character used to fill empty space in the foldtext line. Default: `'⣿'`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |

<details>
    <summary>Sample `foldtext` recipes</summary>

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

<details>
    <summary>
        View as Lua table
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

</details>

| Option                           | Type      | Description                                                                                                                                                                                                                                                                                     |
| -------------------------------- | --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `tables.trim_whitespace`         | `boolean` | `true`*: Trim extra whitespace from the end of a table cell when a table is formatted.<br>`false`: Leave whitespace at the end of a table cell when formatting.                                                                                                                                 |
| `tables.format_on_move`          | `boolean` | `true`*: Format the table each time the cursor is moved to the next/previous cell/row using the plugin's API.<br>`false`: Don't format the table when the cursor is moved.                                                                                                                      |
| `tables.auto_extend_rows`        | `boolean` | `true`: Add another row when attempting to jump to the next row using the plugin's API and the row doesn't exist.<br>`false`*: Leave the table when attempting to jump to the next row using the plugin's API and the row doesn't exist.                                                        |
| `tables.auto_extend_cols`        | `boolean` | `true`: Add another column when attempting to jump to the next column using the plugin's API and the column doesn't exist.<br>`false`*: Go to the first cell of the next row when attempting to jump to the next column using the plugin's API and the column doesn't exist.                    |
| `tables.style.cell_padding`      | `integer` | `1`*: Use one space as padding at the beginning and end of each cell.<br>`<n>`: Use `<n>` spaces as cell padding at the beginning and end of each cell.                                                                                                                                         |
| `tables.style.separator_padding` | `integer` | `1`*: Use one space as padding for the beginning and end of each cell in the separator row (the row beneath the column header row).<br>`<n>`: Use `<n>` spaces as padding for the beginning and end of each cell in the separator row.                                                          |
| `tables.style.outer_pipes`       | `boolean` | `true`*: Include outer pipes when formatting a table or inserting a new table.<br>`false`: Do not use outer pipes when formatting a table or inserting a new table.                                                                                                                             |
| `tables.style.mimic_alignment`   | `boolean` | `true`*: Mimic the cell alignment indicated in the separator row when formatting the table (default to left alignment if alignment is not specified).<br>`false`: Always visually left-align cell contents when formatting a table, regardless of the alignment specified in the separator row. |

</details>

<details>
    <summary>
        <code>yaml = ...</code>
    </summary>

<details>
    <summary>
        View as Lua table
    </summary>

```lua
require('mkdnflow').setup({
    yaml = {
        bib = { override = false },
    },
})
```

</details>

| Option              | Type      | Default | Description                                                                                                              | Possible values | Note |
| ------------------- | --------- | ------- | ------------------------------------------------------------------------------------------------------------------------ | --------------- | ---- |
| `yaml.bib.override` | `boolean` | `false` | Whether or not a bib path specified in a yaml block should be the only source considered for bib references in that file |                 |      |

</details>

<details>
    <summary>
        <code>mappings = ...</code>
    </summary>

<details>
    <summary>
        View as Lua table
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

</details>

> [!NOTE]
> `<name of command>` should be the name of a commands defined in `mkdnflow.nvim/plugin/mkdnflow.lua` (see :h Mkdnflow-commands for a list).

| Option                                 | Type                          | Default                         | Description                                                                                                           | Note |
| -------------------------------------- | ----------------------------- | ------------------------------- | --------------------------------------------------------------------------------------------------------------------- | ---- |
| `mappings.<name_of_command>`           | `table (array-like)\|boolean` | --                              |                                                                                                                       |      |
| `mappings.<name_of_command>[1]`        | `string\|string[]`            | --                              | String or array table representing the mode (or array of modes) that the mapping should apply in (`'n'`, `'v'`, etc.) |      |
| `mappings.<name_of_command>[2]`        | `string`                      | --                              | String representing the keymap (e.g. `'<Space>'`)                                                                     |      |
| `mappings.MkdnEnter`                   | `table (array-like)\|boolean` | `{ { 'n', 'v' }, '<CR>' }`      | See [🛠️ Commands](#-commands)                                                                                         |      |
| `mappings.MkdnGoBack`                  | `table (array-like)\|boolean` | `{ 'n', '<BS>' }`               | "                                                                                                                     |      |
| `mappings.MkdnGoForward`               | `table (array-like)\|boolean` | `{ 'n', '<Del>' }`              | "                                                                                                                     |      |
| `mappings.MkdnMoveSource`              | `table (array-like)\|boolean` | `{ 'n', '<F2>' }`               | "                                                                                                                     |      |
| `mappings.MkdnNextLink`                | `table (array-like)\|boolean` | `{ 'n', '<Tab>' }`              | "                                                                                                                     |      |
| `mappings.MkdnPrevLink`                | `table (array-like)\|boolean` | `{ 'n', '<S-Tab>' }`            | "                                                                                                                     |      |
| `mappings.MkdnFollowLink`              | `table (array-like)\|boolean` | `false`                         | "                                                                                                                     |      |
| `mappings.MkdnDestroyLink`             | `table (array-like)\|boolean` | `{ 'n', '<M-CR>' }`             | "                                                                                                                     |      |
| `mappings.MkdnTagSpan`                 | `table (array-like)\|boolean` | `{ 'v', '<M-CR>' }`             | "                                                                                                                     |      |
| `mappings.MkdnYankAnchorLink`          | `table (array-like)\|boolean` | `{ 'n', 'yaa' }`                | "                                                                                                                     |      |
| `mappings.MkdnYankFileAnchorLink`      | `table (array-like)\|boolean` | `{ 'n', 'yfa' }`                | "                                                                                                                     |      |
| `mappings.MkdnNextHeading`             | `table (array-like)\|boolean` | `{ 'n', ']]' }`                 | "                                                                                                                     |      |
| `mappings.MkdnPrevHeading`             | `table (array-like)\|boolean` | `{ 'n', '[[' }`                 | "                                                                                                                     |      |
| `mappings.MkdnIncreaseHeading`         | `table (array-like)\|boolean` | `{ 'n', '+' }`                  | "                                                                                                                     |      |
| `mappings.MkdnDecreaseHeading`         | `table (array-like)\|boolean` | `{ 'n', '-' }`                  | "                                                                                                                     |      |
| `mappings.MkdnToggleToDo`              | `table (array-like)\|boolean` | `{ { 'n', 'v' }, '<C-Space>' }` | "                                                                                                                     |      |
| `mappings.MkdnNewListItem`             | `table (array-like)\|boolean` | `false`                         | "                                                                                                                     |      |
| `mappings.MkdnNewListItemBelowInsert`  | `table (array-like)\|boolean` | `{ 'n', 'o' }`                  | "                                                                                                                     |      |
| `mappings.MkdnNewListItemAboveInsert`  | `table (array-like)\|boolean` | `{ 'n', 'O' }`                  | "                                                                                                                     |      |
| `mappings.MkdnExtendList`              | `table (array-like)\|boolean` | `false`                         | "                                                                                                                     |      |
| `mappings.MkdnUpdateNumbering`         | `table (array-like)\|boolean` | `{ 'n', '<leader>nn' }`         | "                                                                                                                     |      |
| `mappings.MkdnTable ncol nrow (noh)`   | `table (array-like)\|boolean` | `false`                         | "                                                                                                                     |      |
| `mappings.MkdnTableNextCell`           | `table (array-like)\|boolean` | `{ 'i', '<Tab>' }`              | "                                                                                                                     |      |
| `mappings.MkdnTablePrevCell`           | `table (array-like)\|boolean` | `{ 'i', '<S-Tab>' }`            | "                                                                                                                     |      |
| `mappings.MkdnTableNextRow`            | `table (array-like)\|boolean` | `false`                         | "                                                                                                                     |      |
| `mappings.MkdnTablePrevRow`            | `table (array-like)\|boolean` | `{ 'i', '<M-CR>' }`             | "                                                                                                                     |      |
| `mappings.MkdnTableNewRowBelow`        | `table (array-like)\|boolean` | `{ 'n', '<leader>ir' }`         | "                                                                                                                     |      |
| `mappings.MkdnTableNewRowAbove`        | `table (array-like)\|boolean` | `{ 'n', '<leader>iR' }`         | "                                                                                                                     |      |
| `mappings.MkdnTableNewColAfter`        | `table (array-like)\|boolean` | `{ 'n', '<leader>ic' }`         | "                                                                                                                     |      |
| `mappings.MkdnTableNewColBefore`       | `table (array-like)\|boolean` | `{ 'n', '<leader>iC' }`         | "                                                                                                                     |      |
| `mappings.MkdnFoldSection`             | `table (array-like)\|boolean` | `{ 'n', '<leader>f' }`          | "                                                                                                                     |      |
| `mappings.MkdnUnfoldSection`           | `table (array-like)\|boolean` | `{ 'n', '<leader>F' }`          | "                                                                                                                     |      |
| `mappings.MkdnTab`                     | `table (array-like)\|boolean` | `false`                         | "                                                                                                                     |      |
| `mappings.MkdnSTab`                    | `table (array-like)\|boolean` | `false`                         | "                                                                                                                     |      |
| `mappings.MkdnCreateLink`              | `table (array-like)\|boolean` | `false`                         | "                                                                                                                     |      |
| `mappings.MkdnCreateLinkFromClipboard` | `table (array-like)\|boolean` | `{ { 'n', 'v' }, '<leader>p' }` | "                                                                                                                     |      |

</details>


## 🔍 Usage

### 🛠️ Commands

Below are descriptions of the user commands defined by Mkdnflow. For the default mappings to these commands, see the `mappings = ...` section of [🎨 Configuration options](#-configuration-options).

| Command                       | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `MkdnEnter`                   | Triggers a wrapper function which will (a) infer your editor mode, and then if in normal or visual mode, either follow a link, create a new link from the word under the cursor or visual selection, or fold a section (if cursor is on a section heading); if in insert mode, it will create a new list item (if cursor is in a list), go to the next row in a table (if cursor is in a table), or behave normally (if cursor is not in a list or a table) NOTE: There is no insert-mode mapping for this command by default since some may find its effects intrusive. To enable the insert-mode functionality, add to the mappings table: `MkdnEnter = {{'i', 'n', 'v'}, '}` |
| `MkdnNextLink`                | Move cursor to the beginning of the next link (if there is a next link)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `MkdnPrevLink`                | Move the cursor to the beginning of the previous link (if there is one)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `MkdnNextHeading`             | Move the cursor to the beginning of the next heading (if there is one)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| `MkdnPrevHeading`             | Move the cursor to the beginning of the previous heading (if there is one)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| `MkdnGoBack`                  | Open the historically last-active buffer in the current window                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `MkdnGoForward`               | Open the buffer that was historically navigated away from in the current window                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| `MkdnCreateLink`              | Create a link from the word under the cursor (in normal mode) or from the visual selection (in visual mode)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| `MkdnCreateLinkFromClipboard` | Create a link, using the content from the system clipboard (e.g. a URL) as the source and the word under cursor or visual selection as the link text                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `MkdnFollowLink`              | Open the link under the cursor, creating missing directories if desired, or if there is no link under the cursor, make a link from the word under the cursor                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| `MkdnDestroyLink`             | Destroy the link under the cursor, replacing it with just the text from [...]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| `MkdnTagSpan`                 | Tag a visually-selected span of text with an ID, allowing it to be linked to with an anchor link                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| `MkdnMoveSource`              | Open a dialog where you can provide a new source for a link and the plugin will rename and move the associated file on the backend (and rename the link source)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| `MkdnYankAnchorLink`          | Yank a formatted anchor link (if cursor is currently on a line with a heading)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `MkdnYankFileAnchorLink`      | Yank a formatted anchor link with the filename included before the anchor (if cursor is currently on a line with a heading)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| `MkdnIncreaseHeading`         | Increase heading importance (remove hashes)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| `MkdnDecreaseHeading`         | Decrease heading importance (add hashes)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| `MkdnToggleToDo`              | Toggle to-do list item's completion status or convert a list item into a to-do list item                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| `MkdnUpdateNumbering`         | Update numbering for all siblings of the list item of the current line                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| `MkdnNewListItem`             | Add a new ordered list item, unordered list item, or (uncompleted) to-do list item                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| `MkdnNewListItemBelowInsert`  | Add a new ordered list item, unordered list item, or (uncompleted) to-do list item below the current line and begin insert mode. Add a new line and enter insert mode when the cursor is not in a list.                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `MkdnNewListItemAboveInsert`  | Add a new ordered list item, unordered list item, or (uncompleted) to-do list item above the current line and begin insert mode. Add a new line and enter insert mode when the cursor is not in a list.                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `MkdnExtendList`              | Like above, but the cursor stays on the current line (new list items of the same typ are added below)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| `MkdnTable ncol nrow (noh)`   | Make a table of ncol columns and nrow rows. Pass 'noh' as a third argument to exclude table headers.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `MkdnTableFormat`             | Format a table under the cursor                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| `MkdnTableNextCell`           | Move the cursor to the beginning of the next cell in the table, jumping to the next row if needed                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| `MkdnTablePrevCell`           | Move the cursor to the beginning of the previous cell in the table, jumping to the previous row if needed                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| `MkdnTableNextRow`            | Move the cursor to the beginning of the same cell in the next row of the table                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `MkdnTablePrevRow`            | Move the cursor to the beginning of the same cell in the previous row of the table                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| `MkdnTableNewRowBelow`        | Add a new row below the row the cursor is currently in                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| `MkdnTableNewRowAbove`        | Add a new row above the row the cursor is currently in                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| `MkdnTableNewColAfter`        | Add a new column following the column the cursor is currently in                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| `MkdnTableNewColBefore`       | Add a new column before the column the cursor is currently in                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| `MkdnTab`                     | Wrapper function which will jump to the next cell in a table (if cursor is in a table) or indent an (empty) list item (if cursor is in a list item)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `MkdnSTab`                    | Wrapper function which will jump to the previous cell in a table (if cursor is in a table) or de-indent an (empty) list item (if cursor is in a list item)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| `MkdnFoldSection`             | Fold the section the cursor is currently on/in                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `MkdnUnfoldSection`           | Unfold the folded section the cursor is currently on                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `Mkdnflow`                    | Manually start Mkdnflow                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |

> [!TIP]
> The back-end function for `:MkdnGoBack`, `require('mkdnflow').buffers.goBack()`, returns a boolean indicating the success of `goBack()` (thanks, @pbogut!). This is useful if the user wishes to remap `<BS>` so that when `goBack()` is unsuccessful, another function is performed.

> [!NOTE]
> If you are attempting to (re)map `<CR>` in insert mode but can't get it to work, try inspecting your current insert mode mappings and seeing if anything is overriding your mapping. Possible candidates are completion plugins and auto-pair plugins.
> If using [nvim-cmp](https://github.com/hrsh7th/nvim-cmp), consider using using the mapping with a fallback, as shown here: [*cmp-mapping*](https://github.com/hrsh7th/nvim-cmp/blob/bba6fb67fdafc0af7c5454058dfbabc2182741f4/doc/cmp.txt#L238)
> If using an autopair plugin that automtically maps `<CR>` (e.g. [nvim-autopairs](https://github.com/windwp/nvim-autopairs)), see if it provides a way to disable its `<CR>` mapping (e.g. nvim-autopairs allows you to disable that mapping by adding `map_cr = false` to the table passed to its setup function).

### 🔌 API

## 🤝 Contributing

## 🐛 Troubleshooting

## 🔢 Version information

## 🔗 Related projects
