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

### 🆕 [Latest features](#-recent-changes) and announcements
1. [Custom and customizable foldtext for section folds](#section-folding)
2. [Improved table formatting and formatting style options](#tables)
3. [Customize "jump patterns" for link jumping](#cursor-dictionary-like-table)
4. [Completion of file links and bib-based references (for nvim-cmp)](#-completion-for-nvim-cmp)

#### Announcements
12/12/23: Mkdnflow no longer requires the `luautf8` lua rock as a dependency. UTF-8 characters can be used as [custom to-do symbols](#to_do-dictionary-like-table) out of the box, and table formatting will work out of the box when the table contains UTF-8 characters.

## 📝 Description

Mkdnflow is designed for the *fluent* navigation of documents and notebooks (AKA "wikis") written in [markdown](https://markdownguide.org). The plugin's [flexibility](#customizable-link-interpretation) and its prioritization of markdown also means it can become part of your webdev workflow if you use static site generators like [Jekyll](https://jekyllrb.com) or [Hugo](https://gohugo.io), which can generate static sites from markdown documents.

The plugin is an extended set of functions and mappings to those functions which make it easy to navigate and manipulate markdown documents and notebooks in Neovim. I originally started writing Mkdnflow to replicate some features from [Vimwiki](https://github.com/vimwiki/vimwiki) in Lua instead of Vimscript, but my current goal for this project is to make this plugin as useful as possible for anyone using Neovim who maintains a set of markdown notes and wishes to efficiently navigate those notes and keep them organized and connected. The plugin now includes some convenience features I wished Vimwiki had, including functionality to [rename the source part of a link and its associated file](#rename-link-sources-and-files-simultaneously) simultaneously.

I keep tabs on the project's [issues](https://github.com/jakewvincent/mkdnflow.nvim/issues) and appreciate feature requests, suggestions, and bug reports. I invite you to use the [discussion board](https://github.com/jakewvincent/mkdnflow.nvim/discussions) if you would like to share your config, share how Mkdnflow fits into your workflow, get help with setup, or contribute feature suggestions or optimizations. Contributions to the plugin are welcome: fork this repo and submit a [pull request](https://github.com/jakewvincent/mkdnflow.nvim/pulls) with your changes or additions. For Lua resources, see [this page](https://neovim.io/doc/lua-resources/) or call `:h lua` or `:h api` in Neovim.

### ⚡ Requirements

* Linux, macOS, or Windows
* Neovim >= 0.7.0 for all functionality (most will work with Neovim >= 0.5.0, but mappings will need to be set separately)
* [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) is required for the new completion module.

### ➖ Differences from [Vimwiki](https://github.com/vimwiki/vimwiki)

* Vimwiki doesn't use markdown by default; mkdnflow only works for markdown
* I'm intending mkdnflow to be a little lighter weight/less involved than Vimwiki. Mkdnflow doesn't and won't provide syntax highlighting and won't create new filetypes (although it now optionally provides link concealing, since this was a requested feature).
* Mkdnflow allows you to [prevent modules from being loaded](#modules-dictionary-like-table) that provide features you don't want or don't expect to use (all are enabled by default except `yaml`)
    * Mappings to user commands associated with these modules will not be defined if the command depends on a module that is not loaded
* Written in Lua

## ✨ Features

<p align=center>
<a href="https://user-images.githubusercontent.com/45184202/166573700-62cdec3b-a13f-4f9e-9d72-ab2650205042.mp4"><img src="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/demo/demo.mp4.png" width="75%"></a>
</p>

### Markdown or wiki link styles
* See [links config](#links-dictionary-like-table)
* Markdown link formats recognized:
    * Standard style: `[name](source)`
    * [Reference style](https://www.markdownguide.org/basic-syntax#reference-style-links):
        * `[name][label]` followed anywhere in the file by `[label]: source`, where `label` is an integer
        * `source` can optionally be surrounded by `<` and `>`
        * `source` can optionally be followed by a title, following any of the formats specified [here](https://www.markdownguide.org/basic-syntax#reference-style-links)
* Wiki link formats recognized:
    * Source-only wiki links: `[[source]]`
    * Source-left, name-right wiki links: `[[source|name]]`
* Conceal link sources for either link type by enabling conceal in [your config](#-configuration)
    * Markdown-style links are shortened from `[Link](source.md)` to `Link`
    * Wiki-style links are shortened from `[[source|Link]]` to `Link` or from `[[source]]` to `source`
    * NOTE: If you are using the [recently split treesitter parsers for markdown](https://github.com/nvim-treesitter/nvim-treesitter#supported-languages), you do not need to enable conceal through mkdnflow--if you are using markdown-style links. Just make sure you have `markdown` and `markdown_inline` installed and enabled in markdown filetypes, and in your `.vimrc` or `init.lua`, enable conceal (`set conceallevel=2` or `vim.wo.conceallevel = 2`).

### Follow links and citations
* `<CR>` on various kinds of links to "follow" them:
    * `.md` links open in the current window
    * Absolute links or `.md` links relative to home open in the current window but are interpreted with absolute perspective (e.g. `[File](/home/user/file.md)`/`[File](C:\Users\user\file.md)` on Windows, or `[File](~/Documents/file.md)`)
    * Links to a file prefixed with `file:` (e.g. `[My Xournal notes](file:notes.xopp)`) open with the system's default program for that filetype
    * Links to URLs are opened in the default browser
    * Anchor links to headings (or bracketed spans) in the current file will trigger a jump to that heading or bracketed span.
        * Bracketed spans can have arbitrary ID attributes; if multiple bracketed spans in a file have the same ID attribute, the first will be jumped to. If a bracketed span's ID attribute is identical to that of a heading, the bracketed span will be prioritized since it is explicitly labeled.
        * Headings must start with a hash, and the source part of the anchor link must look like the heading with (a) any spaces between the last hash mark and the beginning of the heading text removed, (b) all other spaces converted to a dash, (c) non-alphanumeric characters removed, (d) strings of multiple hashes converted into a single hash, and (e) all upper-case characters converted to lower-case characters. For example:
            * `## Bills to pay` will be jumped to if the path in the anchor link is `#bills-to-pay`
            * `#### Groceries/other things to buy` will be jumped to if the path in the anchor link is `#groceriesother-things-to-buy`
    * Links to markdown files that include an anchor (e.g. `[Link](grocery_list.md#produce)`) will open the file in the current window and jump to a bracketed span or heading matching the `#` attribute
    * Following a link to a directory (e.g. another notebook) will open a dialogue for you to select which file in the directory to open in the current window
    * [Automatic links](https://pandoc.org/MANUAL.html#automatic-links) (URLs enclosed in angle brackets, e.g. `<https://example.org>`) are followed directly
* `<CR>` on citations to open associated files or websites (e.g. `@Chomsky1957`, with or without brackets around it)
    * Specify a path to a [.bib](http://www.bibtex.org/Format/) file in [your config](#default_path-string)—or if `perspective.priority` is `root`, simply place your bib files to be searched in your notebook's root directory.
    * Files are prioritized. If no file is found associated with the citation key, a URL associated with it will be opened. If no URL is found, a DOI is opened. If no DOI is found, whatever is in the `howpublished` field is opened.
    * 🔥 Hot tip: make reaching your contacts via work messaging apps (e.g. Slack) easier by keeping a bib file that associates your contacts' messaging handles with the URL for your direct message thread with that contact. For instance, if you [point the plugin to a bib file](#default_bib_path-string) with the following entry, `<CR>`ing on `@dschrute` in a markdown document would take you to the associated Slack thread.

```bib
@misc{dschrute,
    url={https://dundermifflin.slack.com/archives/P07BFJD82}
}
```

### Templates for new files
* Define a custom template (under config option `new_file_template.template`) that gets populated and inserted into new markdown files.
* Familiar double-brace syntax for placeholders, e.g. `{{title}}` or `{{ title }}`
* Define custom template placeholders (under config option `new_file_template.placeholders`).
    * Evaluate the placeholder value before switching to the new buffer or after switching to the new buffer by defining the placeholder in either `placeholders.before` or `placeholders.after`.
    * `{{ title }}` and `{{ date }}` are assigned by default to `"link_title"` and `"os_date"` but can be overridden. `"link_title"` refers to the title of the file, _as determined by the label of the the link that led to the new document_. `"os_date"` refers to the system time (formatted as YYYY-MM-DD).

#### Example template
In the following example, `{{ date }}` will be filled in based on the result of evaluating the `date` function at the exact moment one tries to follow a link. `{{ filename }}` will be filled in based on the result of evaluating the `filename` function _after_ the new buffer has been opened (thereby inserting the filename of the newly-opened buffer, rather than the previous one).

```lua
new_file_template = {
    template = [[
# {{ title }}
Date: {{ date }}
Filename: {{ filename }}
]],
    placeholders = {
        before = {
            date = function()
                return os.date("%A, %B %d, %Y") -- Wednesday, March 1, 2023
            end
        },
        after = {
            filename = function()
                return vim.api.nvim_buf_get_name(0)
            end
        }
    }
}
```

### Customizable link interpretation
* Specify what perspective the plugin-should take when interpreting links to files. There are [three options](#perspective-dictionary-like-table):
    1. Interpret links relative to the first-opened file (default behavior; similar to #3 if your first-opened file is always in the root directory)
    2. Interpret links relative to the file open in the current buffer
    3. Interpret links relative to the root directory of the notebook that the file in the current buffer is a part of. To enable this functionality, set `perspective.priority` to `root` in your config, and pass a file as the value of `perspective.root_tell`. The _tell_ is the name of a single file that can be used to identify the root directory (e.g. `index.md`, `.git`, `.root`, `.wiki_root`, etc.). See [the default config](#%EF%B8%8F-configuration) for how to configure the `perspective` table.
    * Override any of the above settings by specifying a link to a markdown file with an absolute path (one that starts with `/` or `~/`). Links within this file will still receive the relative interpretation, so this is best for references out of the project directory to markdown files without their own dependencies (unless those dependencies are within the project directory).
* Keep your files organized **and** your links simple by customizing link interpretation using an [implicit transformation function](#links-dictionary-like-table).

### Create, customize, and destroy links
* `<CR>` on the word under cursor or visual selection to create a notebook-internal link
    * Customizable path text transformations (by default, text is converted to lowercase, spaces are converted to dashes, and the date in YYYY-MM-DD format is prefixed to the filename, separated by an underscore). See the description of the [`links`](#links-dictionary-like-table) config key for customization instructions.
* `<leader>p` on the word under cursor or visual selection to create a link using the system clipboard's content as the source
* `<M-CR>` (Alt-Enter) when your cursor is anywhere in a link to destroy it (replace it with the text in [...])
* Create an anchor link if the visual selection starts with `#` 
* Tag visually selected spans of text (mapped to `<M-CR>` in visual mode) using the style specified in the [Pandoc `bracketed_spans` extension](https://pandoc.org/MANUAL.html#extension-bracketed_spans) (ID must be assigned with the ID selector—i.e. `#`): `[This is a span]{#important-span}`.
* Create a web link if what's under the cursor is a URL (and move the cursor to enter the link name)
* `yaa` ("yank as anchor link"; formerly `ya`) on a heading or bracketed span to add a formatted anchor link for the heading to the default register (ready to paste in the current window)
    * `yfa` to do the same, but adding the absolute path of the file before the anchor (for pasting in another buffer)
* Customize how link sources are generated from text using a custom explicit transformation function
    * Adding the following to your setup would result in a link that looks like the following: `[Some text the link was created from](sometextthelinkwascreatedfrom.md)`

```lua
require('mkdnflow').setup({
    links = {
        transform_explicit = function(text)
            -- Make lowercase, remove spaces, and reverse the string
            return string.lower(text:gsub(' ', ''))
        end
    }
})
```

### Jump to links, headings, and arbitrary pattern matches
* `<Tab>` and `<S-Tab>` jump to the next and previous links in the file 
    * The type of link to jump to is determined by what [`links.style`](#links-dictionary-like-table) is set to (['markdown' or 'wiki'](#markdown-or-wiki-link-styles)), but you can also define your own _jump patterns_ under the [`cursor` config table](#cursor-dictionary-like-table).
* `]]` and `[[` jump to the next and previous headings in the file, respectively
* "Wrap" back to the beginning/end of the file when jumping with a [config setting](#wrap-boolean)
* 🆕 Map your own user command to `require("mkdnflow").cursor.goTo(pattern)` to jump to arbitrarily-defined Lua regex matches (see `:h Mkdnflow-cursor-goTo`)

### 🆕 Completion for [`nvim-cmp`](https://github.com/hrsh7th/nvim-cmp)
* Autocompletion in insert mode when the word you are typing matches any of the `.md` files in the notebook.
* Autocompletion for bibliography keys from entries in known `.bib` files (see [`bib`](#bib-dictionary-like-table)).
* File or bib entry contents are displayed in the completion menu before selecting the completion.
* A module for completion that can be disabled in configuration. Use the `cmp` key.

To enable completion via `cmp` using the provided source, add `mkdnflow` as one of the sources in your `cmp` setup function.
```lua
cmp.setup({
	sources = cmp.config.sources({
		-- Other cmp sources
		{ name = 'mkdnflow' },  -- Add this
		-- Other cmp sources
	}),
})
```

Also, don't forget to edit your `formatting` options in `cmp.setup`.

NOTE: There may be some compatibility issues with the completion module and `links.transform_explicit`/`links.transform_implicit` functions:

* If you have some `transform_explicit` option for links to organizing in folders then the folder name will be inserted accordingly. **Some transformations may not work as expected in completions**.
    * For example, if you have an implicit transformation that will make the link appear as `[author_year](author_year.md)` and you save the file as `ref_author_year.md`. The condition can be if the link name ends with *_yyyy*. Now `cmp` will complete it as `[ref_author_year](ref_author_year.md)` (without the transformation applied). Next, when you follow the link completed by `cmp`, you will go to a new file that is saved as `ref_ref_author_year.md`, which of course does not refer to the intended file.

To prevent this, make sure you write sensible transformation functions, preferably using it for folder organization. The other solution is to do a full text search in all the files for links.

Credit: We heavily referenced [cmp-pandoc-references](https://github.com/jc-doyle/cmp-pandoc-references) and code from other completion sources when writing the `cmp` module.

### Create missing directories
* If a link goes to a file in a directory that doesn't exist, it can optionally [be created](#create_dirs-boolean)

### Rename link sources and files simultaneously
* Use built-in dialog triggered by `MkdnMoveSource` (mapped to `<F2>` by default) to rename a link's source *and rename/move the linked file* simultaneously
    * [Perspective](#customizable-link-interpretation), [implicit extensions](#links-dictionary-like-table), and custom [implicit transformations](#links-dictionary-like-table) are all taken into account when moving the linked file
    * The dialog will confirm the details of the changes for you to approve/reject before taking any action
    * When a reference-style link is renamed, the reference line will be found and renamed accordingly without moving the cursor

### Backward and forward navigation through buffers
* `<BS>` to go **backward** (to the previous file/buffer opened in the current window, like clicking the back button in a web browser)
* `<Del>` to go **forward** (to the subsequent file/buffer opened in the current window, like clicking the forward button in a web browser)

### Keybindings
* Easy-to-remember [default keybindings](#-commands-and-default-mappings) that activate only in markdown files (and/or other filetypes you specify in the `filetypes` config table)
* [Customize keybindings](#mappings-dictionary-like-table) individually or [disable them altogether](#modules-dictionary-like-table) by disabling the `maps` module)

### Manipulate headings
* Increase/decrease heading levels (mapped to `+`/`-` by default). **Note**: *Increasing* the heading means increasing it in importance (i.e. making it bigger or more prominent when converted to HTML and rendered in a browser), which counterintuitively means *removing* a hash symbol.

### Section folding
* Fold a section using `<CR>` in normal mode if the cursor is on the heading of the section
    * Unfold a folded section using `<CR>` or `<leader>F` (both are default mappings; the former maps to a wrapper function that will follow links if the cursor is not on a fold or section heading; the latter is mapped specifically to `:MkdnUnfoldSection<CR>`)
    * If you wish to create a link in a heading (normally done with `<CR>`), you'll need to do so by making a visual selection of the text you wish to create a link from and then hitting `<CR>`, or otherwise disabling the mapping for `MkdnEnter` and mapping `MkdnFollowLink` to `<CR>` in visual and normal modes.
* Fold the section the cursor is currently in—even if the cursor is not on the heading—using `<leader>f`
* 🆕 By default, foldtext (the text displayed for a closed fold) is prettified and includes useful information, including:
    * The level of the section folded
    * The section title, modified by a (customizable) transformation function
    * The number of markdown objects contained by the fold, including tables, unordered lists, ordered lists, to-do lists, links, and subsections
        * Three icon sets are available—`emoji`, `nerdfont` (requires you to be using a nerdfont or patched font in your interface), `plain` (non-emoji unicode symbols)—see the table below—and the icons are [customizable/overridable](#foldtext-dictionary-like-table).
    * The number of lines in the fold
    * The percentage of document lines the fold contains
    * The number of words in the fold

| Object type               | Name     | `emoji` icon |                                                                                                                                                                                                                              `nerdfont` icon                                                                                                                                                                                                                               | `plain` icon |
| ------------------------- | -------- | :----------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | :----------: |
| Table                     | `tbl`    |      📈      |     <picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/tbl_dark.png"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/tbl.png"><img src="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/tbl.png" width="18"></picture>      |      ⊞       |
| Unordered (bulleted) list | `ul`     |      *️⃣       |       <picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/ul_dark.png"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/ul.png"><img src="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/ul.png" width="18"></picture>       |      •       |
| Ordered (numbered) list   | `ol`     |      1️⃣       |       <picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/ol_dark.png"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/ol.png"><img src="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/ol.png" width="18"></picture>       |      ①       |
| To-do list                | `todo`   |      ✅      |    <picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/todo_dark.png"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/todo.png"><img src="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/todo.png" width="18"></picture>    |      ☑       |
| Image                     | `img`    |      🖼️      |     <picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/img_dark.png"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/img.png"><img src="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/img.png" width="18"></picture>      |      ⧉       |
| Fenced code block         | `fncblk` |      🧮      | <picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/fncblk_dark.png"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/fncblk.png"><img src="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/fncblk.png" width="18"></picture> |      ‵       |
| Section                   | `sec`    |      🏷️      |     <picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/sec_dark.png"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/sec.png"><img src="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/sec.png" width="18"></picture>      |      §       |
| Paragraph                 | `par`    |      📃      |     <picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/par_dark.png"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/par.png"><img src="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/par.png" width="18"></picture>      |      ¶       |
| Link                      | `link`   |      🔗      |    <picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/link_dark.png"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/link.png"><img src="https://raw.githubusercontent.com/jakewvincent/mkdnflow.nvim/readme-media/assets/nerdfont/link.png" width="18"></picture>    |      ⇔       |

### Lists
* List markers recognized: `-`, `*`, and `+`
* Toggle the status of a to-do list item on the current line (mapped to `<C-Space>` by default). Using the default settings, toggling will result in the following changes. To-do symbols [can be customized](#to_do-dictionary-like-table).
    * `* [ ] ...` → `* [-] ...`
    * `* [-] ...` → `* [X] ...`
    * `* [X] ...` → `* [ ] ...`
* Toggle multiple to-do items at once by selecting the lines to toggle in (simple) visual mode (mapped to `<C-Space>` by default)
* Create to-do items from plain unordered or ordered lists by toggling a non-to-do-list item (`<C-Space>` by default)
* Automatically update any parent to-dos when child to-dos are toggled.
    * When all child to-dos have been marked complete, the parent is marked complete
    * When at least one child to-do has been marked in-progress, the parent to-do is marked in-progress
    * When a parent to-do is marked complete and one child to-do is reverted to not-yet-started or in-progress, the parent to-do is marked in-progress
    * When a parent to-do is marked complete or in-progress and all child to-dos have been reverted to not-yet-started, the parent to-do is marked not-yet-started.
* Update numbering for the list the cursor is currently on
    * `<leader>nn` (default mapping) or `:MkdnUpdateNumbering 0<CR>`, e.g., if you want to start numbering at 0
* Smart(er) behavior when `<CR>`ing in lists (NOTE: currently not enabled by default. See below.)
    * NOTE: The following functionality is disabled by default in case some find it intrusive. To enable the functionality, remap `<CR>` in insert mode (see the following code block).
    * In unordered lists: Add another bullet on the next line, unless the current list item is empty, in which case it will be erased
    * In ordered lists: Add another item on the next line (keeping numbering updated), unless the current item is empty, in which case it will be erased
    * In unordered and ordered to-do lists: Add another to-do item on the next line, unless the current to-do is empty, in which case it will be replaced with a simple (non-to-do) list item
    * Automatically indent a new list item when the current one ends in a colon
    * Demote empty indented list items by reducing the indentation by one level
* Add new list items using the list type of the current line without any of the fancy stuff listed above (see [MkdnExtendList](#-commands-and-default-mappings))

```lua
require('mkdnflow').setup({
    mappings = {
        MkdnEnter = {{'i', 'n', 'v'}, '<CR>'} -- This monolithic command has the aforementioned
            -- insert-mode-specific behavior and also will trigger row jumping in tables. Outside
            -- of lists and tables, it behaves as <CR> normally does.
        -- MkdnNewListItem = {'i', '<CR>'} -- Use this command instead if you only want <CR> in
            -- insert mode to add a new list item (and behave as usual outside of lists).
    }
})
```

### Tables
* Create a markdown table of `x` columns and `y` rows with `:MkdnTable x y`. Table headers are added automatically; to exclude headers, use `:MkdnTable x y noh`
* Format existing tables with `:MkdnTableFormat`
* Jump forward and backward between cells (mapped to `<Tab>` and `<S-Tab>` in insert mode by default)
* Jump forward and backward between rows (the latter is mapped to `<M-CR>` in insert mode by default; jumping forward is not mapped to anything by default; see `MkdnEnter` or `MkdnTableNextRow` in [default mappings](#-commands-and-default-mappings))
* Optionally trim extra whitespace from a cell when formatting (see [config options](#-configuration))
* Optionally disable formatting when moving cells
* Add new rows or columns (before or after the current row/cell; see [default mappings](#-commands-and-default-mappings))
* 🆕 Table styling options (see [table config options](#tables-dictionary-like-table))
    * 🆕 Customize cell padding
    * 🆕 Customize separator row padding
    * 🆕 Include or exclude outer pipes
    * 🆕 Mimic column alignment (left/center/right) in markdown

### Disable unused modules
* Individually disable any of the modules that enable all of the above functionality (see [`modules` config option descriptions](#modules-dictionary-like-table))
    * Prevents the module from being loaded (rather than simply disabling the functionality the module provides)
    * Disabling a module prevents mappings to commands that are dependent on that module from being defined

### YAML block parsing
* Use YAML blocks at the very top of a markdown document to specify certain settings on a by-file basis:
    * Paths to bib files (must be absolute paths):
        * Specify as a string or a list (see examples of each below)

Specify one bib source:
```markdown
---
bib: /home/user/Documents/Library/library.bib
---
```

Specify multiple bib sources:
```markdown
---
bib:
  - /home/user/Documents/Library/library.bib
  - /home/user/Projects/special_project/refs.bib
---
```

## 📦 Installation and usage

### init.lua
<details>
<summary>Install with <a href="https://github.com/folke/lazy.nvim">Lazy</a></summary><p>

```lua
require('lazy').setup({
    -- Your other plugins
    {
        'jakewvincent/mkdnflow.nvim',
        config = function()
            require('mkdnflow').setup({
                -- Config goes here; leave blank for defaults
            })
        end
    }
    -- Your other plugins
})
```

</p></details>

<details>
<summary>Install with <a href="https://github.com/lewis6991/pckr.nvim">Pckr</a></summary><p>

```lua
require('pckr').add({
    -- Your other plugins
    {
        'jakewvincent/mkdnflow.nvim',
        config = function()
            require('mkdnflow').setup({
                -- Config goes here; leave blank for defaults
            })
        end
    }
    -- Your other plugins
})
```

</p></details>

<details>
<summary>Install with <a href="https://github.com/savq/paq-nvim">Paq</a></summary><p>

```lua
require('paq')({
    -- Your other plugins
    'jakewvincent/mkdnflow.nvim',
    -- Your other plugins
})

-- Include the setup function somewhere else in your init.lua/vim file, or the
-- plugin won't activate itself:

require('mkdnflow').setup({
    -- Config goes here; leave blank for defaults
})
```

</p></details>

<details>
<summary>Install with <a href="https://github.com/wbthomason/packer.nvim">Packer</a></summary><p>

```lua
use({'jakewvincent/mkdnflow.nvim',
     config = function()
        require('mkdnflow').setup({
            -- Config goes here; leave blank for defaults
        })
     end
})
```

</p></details>

### init.vim
<details>
<summary>Install with Vim-Plug, NeoBundle, Vundle, Pathogen, or Dein</summary><p>

```vim
" Vim-Plug
Plug 'jakewvincent/mkdnflow.nvim'

" NeoBundle
NeoBundle 'jakewvincent/mkdnflow.nvim'

" Vundle
Bundle 'jakewvincent/mkdnflow.nvim'

" Pathogen
git clone https://github.com/jakewvincent/mkdnflow.nvim.git ~/.vim/bundle/mkdownflow.nvim

" Dein
call dein#add('jakewvincent/mkdnflow.nvim')

" Include the setup function somewhere else in your init.vim file, or the
" plugin won't activate itself:
lua << EOF
require('mkdnflow').setup({
    -- Config goes here; leave blank for defaults
})
EOF
```

</p></details>

### ❗ Caveats/warnings

All functionality of the plugin should now work on all operating systems, including Windows! However, since I don't use Windows on my daily driver, there may be edge cases that cause trouble. Please file an issue if anything comes up.

### 🏁 Starting a notebook

As long as you successfully installed Mkdnflow, you don't need to do anything special to start using the plugin. All of the plugin's features will be enabled for any markdown file (or for any filetype you specify under the `filetypes` config key). If you would like to start a notebook (AKA "wiki"), first create a directory for it. If you're using Neovim in the terminal, simply enter `nvim index.md` and start writing. I suggest using `index.md` as a landing page/table of contents that contains links to all other notes in your notebook. If you use such a landing page, try setting `perspective.priority` in your Mkdnflow config to `'root'` and your `perspective.root_tell` to `'index.md'` so that Mkdnflow can identify your notebook's root directory and reliably interpret links relative to this directory.

## ⚙️ Configuration

Currently, the setup function uses the defaults shown below. See the descriptions and non-default options in the [section below the following block](#config-descriptions). **To use these defaults, simply pass no arguments setup function:** `require('mkdnflow').setup()`. To change these settings, specify new values for any of them them in the setup function.

```lua
-- ** DEFAULT SETTINGS; TO USE THESE, PASS NO ARGUMENTS TO THE SETUP FUNCTION **
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
        yaml = false,
        cmp = false
    },
    filetypes = {md = true, rmd = true, markdown = true},
    create_dirs = true,
    perspective = {
        priority = 'first',
        fallback = 'current',
        root_tell = false,
        nvim_wd_heel = false,
        update = false
    },
    wrap = false,
    bib = {
        default_path = nil,
        find_in_root = true
    },
    silent = false,
    cursor = {
        jump_patterns = nil
    },
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
            text = os.date('%Y-%m-%d_')..text
            return(text)
        end,
        create_on_follow_failure = true
    },
    new_file_template = {
        use_template = false,
        placeholders = {
            before = {
                title = "link_title",
                date = "os_date"
            },
            after = {}
        },
        template = "# {{ title }}"
    },
    to_do = {
        symbols = {' ', '-', 'X'},
        update_parents = true,
        not_started = ' ',
        in_progress = '-',
        complete = 'X'
    },
    foldtext = {
        object_count = true,
        object_count_icons = 'emoji',
        object_count_opts = function()
            return require('mkdnflow').foldtext.default_count_opts()
        end,
        line_count = true,
        line_percentage = true,
        word_count = false,
        title_transformer = nil,
        separator = ' · ',
        fill_chars = {
            left_edge = '⢾',
            right_edge = '⡷',
            left_inside = ' ⣹',
            right_inside = '⣏ ',
            middle = '⣿',
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
            mimic_alignment = true
        }
    },
    yaml = {
        bib = { override = false }
    },
    mappings = {
        MkdnEnter = {{'n', 'v'}, '<CR>'},
        MkdnTab = false,
        MkdnSTab = false,
        MkdnNextLink = {'n', '<Tab>'},
        MkdnPrevLink = {'n', '<S-Tab>'},
        MkdnNextHeading = {'n', ']]'},
        MkdnPrevHeading = {'n', '[['},
        MkdnGoBack = {'n', '<BS>'},
        MkdnGoForward = {'n', '<Del>'},
        MkdnCreateLink = false, -- see MkdnEnter
        MkdnCreateLinkFromClipboard = {{'n', 'v'}, '<leader>p'}, -- see MkdnEnter
        MkdnFollowLink = false, -- see MkdnEnter
        MkdnDestroyLink = {'n', '<M-CR>'},
        MkdnTagSpan = {'v', '<M-CR>'},
        MkdnMoveSource = {'n', '<F2>'},
        MkdnYankAnchorLink = {'n', 'yaa'},
        MkdnYankFileAnchorLink = {'n', 'yfa'},
        MkdnIncreaseHeading = {'n', '+'},
        MkdnDecreaseHeading = {'n', '-'},
        MkdnToggleToDo = {{'n', 'v'}, '<C-Space>'},
        MkdnNewListItem = false,
        MkdnNewListItemBelowInsert = {'n', 'o'},
        MkdnNewListItemAboveInsert = {'n', 'O'},
        MkdnExtendList = false,
        MkdnUpdateNumbering = {'n', '<leader>nn'},
        MkdnTableNextCell = {'i', '<Tab>'},
        MkdnTablePrevCell = {'i', '<S-Tab>'},
        MkdnTableNextRow = false,
        MkdnTablePrevRow = {'i', '<M-CR>'},
        MkdnTableNewRowBelow = {'n', '<leader>ir'},
        MkdnTableNewRowAbove = {'n', '<leader>iR'},
        MkdnTableNewColAfter = {'n', '<leader>ic'},
        MkdnTableNewColBefore = {'n', '<leader>iC'},
        MkdnFoldSection = {'n', '<leader>f'},
        MkdnUnfoldSection = {'n', '<leader>F'}
    }
})
```

### Config descriptions
#### `modules` (dictionary-like table)
* Most modules are enabled by default:
    * `modules.bib` (required for [parsing bib files](#follow-links-and-citations) and [following citations](#follow-links-and-citations))
    * `modules.buffers` (required for [backward and forward navigation through buffers](#backward-and-forward-navigation-through-buffers))
    * `modules.conceal` (required if you wish to enable [link concealing](#markdown-or-wiki-link-styles); note that you must declare [`links.conceal` as `true`](#links-dictionary-like-table) in addition to leaving this module enabled [it is enabled by default] if you wish to conceal links)
    * `modules.cursor` (required for [jumping to links and headings](#jump-to-links-headings); [yanking anchor links](#create-customize-and-destroy-links))
    * `modules.folds` (required for [folding by section](#section-folding))
    * `modules.links` (required for [creating and destroying links](#create-customize-and-destroy-links) and [following links](#follow-links-and-citations))
    * `modules.lists` (required for [manipulating lists, toggling to-do list items, etc.](#lists))
    * `modules.maps` (required for [setting mappings via the mappings table](#keybindings); set to `false` if you wish to set mappings outside of the plugin)
    * `modules.paths` (required for [link interpretation](#customizable-link-interpretation) and [following links](#follow-links-and-citations))
    * `modules.tables` (required for [table navigation and formatting](#tables))
* Modules not enabled by default:
    * `modules.yaml` (required for parsing yaml blocks)
    * `modules.cmp` (required if you wish to enable [Completion for [`nvim-cmp`](https://github.com/hrsh7th/nvim-cmp)](#-completion-for-nvim-cmphttpsgithubcomhrsh7thnvim-cmp))

#### `create_dirs` (boolean)
* `true` (default): Directories referenced in a link will be (recursively) created if they do not exist
* `false` No action will be taken when directories referenced in a link do not exist. Neovim will open a new file, but you will get an error when you attempt to write the file.

#### `perspective` (dictionary-like table)
* `perspective.priority` (string): Specifies the priority perspective to take when interpreting link paths
    * `'first'` (default): Links will be interpreted relative to the first-opened file (when the current instance of Neovim was started)
    * `'current'`: Links will be interpreted relative to the current file
    * `'root'`: Links will be interpreted relative to the root directory of the current notebook (requires `perspective.root_tell` to be specified)
* `perspective.root_tell` (string or boolean)
    * `'<any file name>'`: Any arbitrary filename by which the plugin can uniquely identify the root directory of the current notebook. If `false` is used instead, the plugin will never search for a root directory, even if `perspective.priority` is set to `root`.
* `perspective.fallback` (string): Specifies the backup perspective to take if priority isn't possible (e.g. if it is `'root'` but no root directory is found)
    * `'first'`: (see above)
    * `'current'` (default): (see above)
    * `'root'`: (see above)
* `perspective.nvim_wd_heel` (boolean): Specifies whether changes in perspective will result in corresponding changes to Neovim's working directory
    * `true`: Changes in perspective will be reflected in the nvim working directory. (In other words, the working directory will "heel" to the plugin's perspective.) This helps ensure (at least) that path completions (if using a completion plugin with support for paths) will be accurate and usable.
    * `false` (default): Neovim's working directory will not be affected by Mkdnflow.
* `perspective.update` (boolean): Determines whether the plugin looks to determine if a followed link is in a different notebook/wiki than before. If it is, the perspective will be updated. Requires `root_tell` to be defined and `priority` to be `root`.
    * `true` (default): Perspective will be updated when following a link to a file in a separate notebook/wiki (or navigating backwards to a file in another notebook/wiki).
    * `false`: Perspective will be not updated when following a link to a file in a separate notebook/wiki. Under the hood, links in the file in the separate notebook/wiki will be interpreted relative to the original notebook/wiki.

#### `filetypes` (dictionary-like table)
* `<any arbitrary filetype extension>` (boolean value)
    * `true`: A matching extension will enable the plugin's functionality for a file with that extension

NOTE: This functionality references the file's extension. It does not rely on Neovim's filetype recognition. The extension must be provided in lower case because the plugin converts file names to lowercase. Any arbitrary extension can be supplied. Setting an extension to `false` is the same as not including it in the list.

#### `wrap` (boolean)
* `true`: When jumping to next/previous links or headings, the cursor will continue searching at the beginning/end of the file
* `false` (default): When jumping to next/previous links or headings, the cursor will stop searching at the end/beginning of the file

#### `bib` (dictionary-like table)
* `bib.default_path` (string or `nil`): Specifies a path to a default .bib file to look for citation keys in (need not be in root directory of notebook)
* `bib.find_in_root` (boolean)
    * `true` (default): When `perspective.priority` is also set to `root` (and a root directory was found), the plugin will search for bib files to reference in the notebook's top-level directory. If `bib.default_path` is also specified, the default path will be appended to the list of bib files found in the top level directory so that it will also be searched.
    * `false`: The notebook's root directory will not be searched for bib files.

#### `silent` (boolean)
* `true`: The plugin will not display any messages in the console except compatibility warnings related to your config
* `false` (default): The plugin will display messages to the console (all messages from the plugin start with ⬇️ )

#### `cursor` (dictionary-like table)
* `cursor.jump_patterns` (nil or table): A list of Lua regex patterns to jump to using `:MkdnNextLink` and `:MkdnPrevLink`
    * `nil` (default): When `nil`, the [default jump patterns](#jump-to-links-headings) for the configured link style are used (markdown-style links by default)
    * table of custom Lua regex patterns
    * `{}` (empty table) to disable link jumping without disabling the `cursor` module

#### `links` (dictionary-like table)
* `links.style` (string)
    * `'markdown'` (default): Links will be expected in the standard markdown format: `[<title>](<source>)`
    * `'wiki'`: Links will be expected in the unofficial wiki-link style, specifically the [title-after-pipe format](https://github.com/jgm/pandoc/pull/7705): `[[<source>|<title>]]`.
* `links.name_is_source` (boolean)
    * `true`: Wiki-style links will be created with the source and name being the same (e.g. `[[Link]]` will display as "Link" and go to a file named "Link.md")
    * `false` (default): Wiki-style links will be created with separate name and source (e.g. `[[link-to-source|Link]]` will display as "Link" and go to a file named "link-to-source.md")
* `links.conceal` (boolean)
    * `true`: Link sources and delimiters will be concealed (depending on which link style is selected)
    * `false` (default): Link sources and delimiters will not be concealed by mkdnflow
* `links.context` (number)
    * `0` (default): When following or jumping to links, assume no link will be split over multiple lines
    * `n` (an integer): When following or jumping to links, consider `n` lines before and after a given line (useful if you ever permit links to be interrupted by a hard line break)
* `links.implicit_extension` (string) A string that instructs the plugin (a) how to _interpret_ links to files that do not have an extension, and (b) how to create new links from the word under cursor or text selection.
    * `nil` (default): Extensions will be explicit when a link is created and must be explicit in any notebook link.
    * `<any extension>` (e.g. `'md'`): Links without an extension (e.g. `[Homepage](index)`) will be interpreted with the implicit extension (e.g. `index.md`), and new links will be created without an extension.
* `links.transform_explicit` (function or `false`): A function that transforms the text to be inserted as the source/path of a link when a link is created. Anchor links are not currently customizable. If you want all link paths to be explicitly prefixed with the year, for instance, and for the path to be converted to uppercase, you could provide the following function under this key. (FYI: The previous functionality specified under the `prefix` key has been migrated here to provide greater flexibility.)

```lua
function(input)
    return(string.upper(os.date('%Y-')..input))
end
```

* `links.transform_implicit` (function or `false`): A function that transforms the path of a link immediately before interpretation. It does not transform the actual text in the buffer but can be used to modify link interpretation. For instance, link paths that match a date pattern can be opened in a `journals` subdirectory of your notebook, and all others can be opened in a `pages` subdirectory, using the following function:

```lua
function(input)
    if input:match('%d%d%d%d%-%d%d%-%d%d') then
        return('journals/'..input)
    else
        return('pages/'..input)
    end
end
```

* 🆕 `links.create_on_follow_failure` (boolean): Whether a link should be created if there is no link to follow under the cursor.
    * `true` (default): Create a link if there's no link to follow
    * `false`: Do not create a link if there's no link to follow

#### `new_file_template` (dictionary-like table)
* `new_file_template.use_template` (boolean)
    * `true`: the template is filled in (if it contains placeholders) and inserted into any new buffers entered by following a link to a buffer that doesn't exist yet
    * `false`: no templates are filled in and inserted into new buffers
* `new_file_template.placeholders` (dictionary-like table)
    * `new_file_template.placeholders.before` (dictionary-like table) A table whose keys are placeholder names pointing to functions to be evaluated immediately before the buffer is opened in the current window
    * `new_file_template.placeholders.after` (dictionary-like table) A table hose keys are placeholder names pointing to functions to be evaluated immediately after the buffer is opened in the current window
* `new_file_template.template` (string) A string, optionally containing placeholder names, that will be inserted into new buffers

#### `to_do` (dictionary-like table)
* `to_do.symbols` (array-like table): A list of symbols (each no more than one character) that represent to-do list completion statuses. `MkdnToggleToDo` references these when toggling the status of a to-do item. Three are expected: one representing not-yet-started to-dos (default: `' '`), one representing in-progress to-dos (default: `-`), and one representing complete to-dos (default: `X`).
* `to_do.update_parents` (boolean): Whether parent to-dos' statuses should be updated based on child to-do status changes performed via `MkdnToggleToDo`
    * `true` (default): Parent to-do statuses will be inferred and automatically updated when a child to-do's status is changed
    * `false`: To-do items can be toggled, but parent to-do statuses (if any) will not be automatically changed
* The following entries can be used to stipulate which symbols shall be used when updating a parent to-do's status when a child to-do's status is changed. These are **not required**: if `to_do.symbols` is customized but these options are not provided, the plugin will attempt to infer what the meanings of the symbols in your list are by their order. For example, if you set `to_do.symbols` as `{' ', '⧖', '✓'}`, `' '` will be assiged to `to_do.not_started`, '⧖' will be assigned to `to_do.in_progress`, etc. If more than three symbols are specified, the first will be used as `not_started`, the second will be used as `in_progress`, and the last will be used as `complete`. If two symbols are provided (e.g. `' ', '✓'`), the first will be used as both `not_started` and `in_progress`, and the second will be used as `complete`.
    * `to_do.not_started` (string): Stipulates which symbol represents a not-yet-started to-do (default: `' '`)
    * `to_do.in_progress` (string):  Stipulates which symbol represents an in-progress to-do (default: `'-'`)
    * `to_do.complete` (string):  Stipulates which symbol represents a complete to-do (default: `'X'`)

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

#### `yaml` (dictionary-like table)
* `yaml.bib` (dictionary-like table)
    * `yaml.bib.override` (boolean): Whether or not a bib path specified in a yaml block should be the only source considered for bib references in that file (default: `false`)

#### `mappings` (dictionary-like table)
* `mappings.<name of command>` (array-like table or `false`)
    * `mappings.<name of command>[1]` string or array table representing the mode (or array of modes) that the mapping should apply in (`'n'`, `'v'`, etc.)
    * `mappings.<name of command>[2]` string representing the keymap (e.g. `'<Space>'`)
    * set `mappings.<name of command> = false` to disable default mapping without providing a custom mapping

NOTE: `<name of command>` should be the name of a commands defined in `mkdnflow.nvim/plugin/mkdnflow.lua` (see :h Mkdnflow-commands for a list).

### 👍 Recommended vim settings

I recommended turning on `autowriteall` in Neovim *for markdown filetypes*. This will ensure that changes to buffers are saved when you navigate away from that buffer, e.g. by following a link to another file. See `:h awa`. If you have `hidden` enabled or if a buffer is hidden by `bufhidden`, you may need to use the second option (thanks, @vandalt).

```lua
-- If you have an init.lua
vim.api.nvim_create_autocmd("FileType", {pattern = "markdown", command = "set awa"})
-- Use the following if your buffer is set to become hidden
--vim.api.nvim_create_autocmd("BufLeave", {pattern = "*.md", command = "silent! wall"})
```

```vim
" If you have an init.vim
autocmd FileType markdown set autowriteall
" Use the following if your buffer is set to become hidden
autocmd BufLeave *.md silent! wall
```

### ❕ Commands and default mappings

These default mappings can be disabled; see [Configuration](#%EF%B8%8F-configuration). Commands with no mappings trigger functions that are called by the functions with mappings, but I've given them a command name so you can use them as independent functions if you'd like to.

| Keymap       | Mode      | Command                            | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| ------------ | --------- | ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `<CR>`       | n, v(, i) | `:MkdnEnter<CR>`                   | Triggers a wrapper function which will (a) infer your editor mode, and then if in normal or visual mode, either follow a link, create a new link from the word under the cursor or visual selection, or fold a section (if cursor is on a section heading); if in insert mode, it will create a new list item (if cursor is in a list), go to the next row in a table (if cursor is in a table), or behave normally (if cursor is not in a list or a table) NOTE: There is no insert-mode mapping for this command by default since some may find its effects intrusive. To enable the insert-mode functionality, add to the mappings table: `MkdnEnter = {{'i', 'n', 'v'}, '<CR>}` |
| `<Tab>`      | n         | `:MkdnNextLink<CR>`                | Move cursor to the beginning of the next link (if there is a next link)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `<S-Tab>`    | n         | `:MkdnPrevLink<CR>`                | Move the cursor to the beginning of the previous link (if there is one)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `]]`         | n         | `:MkdnNextHeading<CR>`             | Move the cursor to the beginning of the next heading (if there is one)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| `[[`         | n         | `:MkdnPrevHeading<CR>`             | Move the cursor to the beginning of the previous heading (if there is one)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| `<BS>`       | n         | `:MkdnGoBack<CR>`                  | Open the historically last-active buffer in the current window                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| `<Del>`      | n         | `:MkdnGoForward<CR>`               | Open the buffer that was historically navigated away from in the current window                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| --           | --        | `:MkdnCreateLink<CR>`              | Create a link from the word under the cursor (in normal mode) or from the visual selection (in visual mode)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `<leader>p`  | n, v      | `:MkdnCreateLinkFromClipboard<CR>` | Create a link, using the content from the system clipboard (e.g. a URL) as the source and the word under cursor or visual selection as the link text                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| --           | --        | `:MkdnFollowLink<CR>`              | Open the link under the cursor, creating missing directories if desired, or if there is no link under the cursor, make a link from the word under the cursor                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| `<M-CR>`     | n         | `:MkdnDestroyLink<CR>`             | Destroy the link under the cursor, replacing it with just the text from [...]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| `<M-CR>`     | v         | `:MkdnTagSpan<CR>`                 | Tag a visually-selected span of text with an ID, allowing it to be linked to with an anchor link                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| `<F2>`       | n         | `:MkdnMoveSource<CR>`              | Open a dialog where you can provide a new source for a link and the plugin will rename and move the associated file on the backend (and rename the link source)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| `yaa`        | n         | `:MkdnYankAnchorLink<CR>`          | Yank a formatted anchor link (if cursor is currently on a line with a heading)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| `yfa`        | n         | `:MkdnYankFileAnchorLink<CR>`      | Yank a formatted anchor link with the filename included before the anchor (if cursor is currently on a line with a heading)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `+`          | n         | `:MkdnIncreaseHeading<CR>`         | Increase heading importance (remove hashes)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `-`          | n         | `:MkdnDecreaseHeading<CR>`         | Decrease heading importance (add hashes)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `<C-Space>`  | n         | `:MkdnToggleToDo<CR>`              | Toggle to-do list item's completion status or convert a list item into a to-do list item                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `<leader>nn` | n         | `:MkdnUpdateNumbering<CR>`         | Update numbering for all siblings of the list item of the current line                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| --           | --        | `:MkdnNewListItem<CR>`             | Add a new ordered list item, unordered list item, or (uncompleted) to-do list item                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `o`          | n         | `:MkdnNewListItemBelowInsert<CR>`  | Add a new ordered list item, unordered list item, or (uncompleted) to-do list item below the current line and begin insert mode. Add a new line and enter insert mode when the cursor is not in a list.                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `O`          | n         | `:MkdnNewListItemAboveInsert<CR>`  | Add a new ordered list item, unordered list item, or (uncompleted) to-do list item above the current line and begin insert mode. Add a new line and enter insert mode when the cursor is not in a list.                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| --           | --        | `:MkdnExtendList<CR>`              | Like above, but the cursor stays on the current line (new list items of the same typ are added below)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| --           | --        | `:MkdnTable ncol nrow (noh)`       | Make a table of ncol columns and nrow rows. Pass 'noh' as a third argument to exclude table headers.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| --           | --        | `:MkdnTableFormat<CR>`             | Format a table under the cursor                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| `<Tab>`      | i         | `:MkdnTableNextCell<CR>`           | Move the cursor to the beginning of the next cell in the table, jumping to the next row if needed                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| `<S-Tab>`    | i         | `:MkdnTablePrevCell<CR>`           | Move the cursor to the beginning of the previous cell in the table, jumping to the previous row if needed                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| `<leader>ir` | n         | `:MkdnTableNewRowBelow<CR>`        | Add a new row below the row the cursor is currently in                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| `<leader>iR` | n         | `:MkdnTableNewRowAbove<CR>`        | Add a new row above the row the cursor is currently in                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| `<leader>ic` | n         | `:MkdnTableNewColAfter<CR>`        | Add a new column following the column the cursor is currently in                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| `<leader>iC` | n         | `:MkdnTableNewColBefore<CR>`       | Add a new column before the column the cursor is currently in                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| --           | --        | `:MkdnTab<CR>`                     | Wrapper function which will jump to the next cell in a table (if cursor is in a table) or indent an (empty) list item (if cursor is in a list item)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| --           | --        | `:MkdnSTab<CR>`                    | Wrapper function which will jump to the previous cell in a table (if cursor is in a table) or de-indent an (empty) list item (if cursor is in a list item)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| `<leader>f`  | --        | `:MkdnFoldSection<CR>`             | Fold the section the cursor is currently on/in                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| `<leader>F`  | --        | `:MkdnUnfoldSection<CR>`           | Unfold the folded section the cursor is currently on                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| --           | --        | `:Mkdnflow<CR>`                    | Manually start Mkdnflow                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |

### Miscellaneous notes (+ troubleshooting) on remapping
* The back-end function for `:MkdnGoBack`, `require('mkdnflow').buffers.goBack()`, returns a boolean indicating the success of `goBack()` (thanks, @pbogut!). This is useful if the user wishes to remap `<BS>` so that when `goBack()` is unsuccessful, another function is performed.
* If you are attempting to (re)map `<CR>` in insert mode but can't get it to work, try inspecting your current insert mode mappings and seeing if anything is overriding your mapping. Possible candidates are completion plugins and auto-pair plugins.
    * If using [nvim-cmp](https://github.com/hrsh7th/nvim-cmp), consider using using the mapping with a fallback, as shown here: [*cmp-mapping*](https://github.com/hrsh7th/nvim-cmp/blob/bba6fb67fdafc0af7c5454058dfbabc2182741f4/doc/cmp.txt#L238)
    * If using an autopair plugin that automtically maps `<CR>` (e.g. [nvim-autopairs](https://github.com/windwp/nvim-autopairs)), see if it provides a way to disable its `<CR>` mapping (e.g. nvim-autopairs allows you to disable that mapping by adding `map_cr = false` to the table passed to its setup function).

## ☑️ To do
* [ ] Add option to continuously format tables as they are being edited
* [ ] Finalize completion module & add comments

<details>
<summary>Completed to-dos</summary><p>

* [X] Improve citation functionality
    * [X] Add ability to stipulate a .bib file in a yaml block at the top of a markdown file
* [X] Interpret reference-style links (spec: [Reference-style Links](https://www.markdownguide.org/basic-syntax#reference-style-links))
* [X] Overhaul help documents (i.e. `:h mkdnflow`)
* [X] Tables: add a config option to automatically expand a table (row-wise or col-wise) when attempting to jump to the next col/row and there is none
* [X] Add a way to disable modules the user doesn't wish/plan to use
* [X] Headings
    * [X] Easy folding & unfolding
* [X] Fancy table creation & editing
    * [X] Create a table of x columns and y rows
    * [X] Add/remove columns and rows
    * [X] Horizontal navigation through tables (with `<Tab>`)
    * [X] Vertical navigation through tables (with `<CR>`?)
    * [X] Table formatting for tables with explicit left-, center-, or right-aligned columns
* [X] Easily rename file in link
* [X] Add ability to identify/use any given .bib file in notebook's root directory (if `perspective` is set to `root`)
* [X] Lists
    * [X] To-do list functions & mappings
        * [X] Modify status of parent to-do when changing a child to-do (infer based on tab settings)
    * [X] Smart `<CR>` when in lists, etc.
* [X] Full compatibility with Windows
* [X] "Undo" a link (replace link w/ the text part of the link)
* [X] Easy *forward* navigation through buffers (with ~~`<S-BS>?`~~ `<Del>`)
* [X] Allow reference to absolute paths (interpret relatively [following config] if not prepended w/ `~` or `/`)
* [X] Allow parentheses in link names ([issue #8](https://github.com/jakewvincent/mkdnflow.nvim/issues/8))
* [X] Add a config option to wrap to the beginning of the document when navigating between links (11/08/21)

</p></details>


## 🔧 Recent changes
* 12/20/23: Major improvements to table formatting (efficiency improvements on the backend; more customization options)
* 12/12/23: `luautf8` no longer required for use of UTF8 symbols in customized to-do symbols or formatted tables
* 12/12/23: Customizable jump patterns for link jumping
* 09/11/23: Merge completion module PR for testing in dev branch

<details>
<summary>Older changes (> 1 month ago)</summary><p>

* 04/02/23: Updated yank-as-anchor mapping from `ya` to `yaa` to prevent interference with `yap` (yank around paragraph)
* 03/18/23: Added template functionality for new files
* 01/14/23: Added support for non-ascii symbols in anchor links (with the `luautf8` Luarocks module)
* 01/05/23: Added `+` as a valid unordered list or unordered to-do list marker (requested in [issue #112](https://github.com/jakewvincent/mkdnflow.nvim/issues/112))
* 01/02/23: Automatic links (URLs enclosed in `<` + `>` and lacking the usual markdown link syntax that are automatically rendered as links when compiled into HTML) will now be followed
* 10/08/22: Create links using the system clipboard content as the link's source
* 10/02/22: Add ability to consider n lines of context around the cursor when following, renaming, or removing links
* 09/21/22: Add compact option for wiki-link creation
* 09/21/22: Add support for angle brackets in link sources
* 09/20/22: Ignore escaped vertical bars when formatting tables
* 08/19/22: Add yaml parsing and yaml config options; add bib paths found in parsed yaml block to bib sources
* 08/11/22: Add two new commands (`:MkdnNewListItemBelowInsert` and `:MkdnNewListItemAboveInsert`) mapped to `o` and `O` by default
* 08/07/22: Extend link-following, link-jumping, and source editing/moving functionality to reference-style links
* 07/26/22: Add config option for automatically extending table (col-wise or row-wise) when attempting to jump to the next cell/row while in the last cell/row
* 07/26/22: Command & mapping for creating bracketed spans (spans assigned an ID attribute)
* 07/19/22: Update newly-converted (via `MkdnToggleToDo`/`<C-Space>`) to-do item's status if it has children
* 07/13/22: Follow links to arbitrary spans
* 07/13/22: Individually disable modules
* 07/09/22: Added folding functionality; replaced default normal/visual-mode mapping with mapping to wrapper function that will fold/open sections
* 07/01/22: Properly handle alignment markers in tables
* 07/01/22: Add option not to format table when moving the cursor to a different cell
* 06/29/22: Conceal links
* 06/27/22: Added wrapper functions so `<Tab>` and `<S-Tab>` can be used in both tables and lists
* 06/27/22: Added functionality to add new rows and columns
* 06/17/22: Added functionality to jump rows in tables
* 06/16/22: Added functionality to format tables and jump cells in tables
* 06/11/22: Added function and command to insert tables
* 06/06/22: Extend functionality of MkdnToggleToDo so that it (a) will create a to-do item from a plain list item, and (b) can toggle multiple to-do items selected with simple visual mode
* 06/04/22: Easily rename files in links (with `MkdnMoveSource`, mapped to `<F2>` by default)
* 06/04/22: Variant of MkdnNewListItem added as MkdnExtendList
* 06/03/22: Add command and mapping for updating numbering
* 05/30/22: Implement root directory switching to allow for easier switching between notebooks
* 05/30/22: Indent new list item when current one ends in a colon
* 05/12/22: Add functionality to search for bib files in the project's root directory
* 05/11/22: Customize path text when links are created with a customizable transformation function
* 05/11/22: Customize link interpretation with a customizable interpretation function (thanks @jmbuhr!)
* 04/30/22: Customize link style (markdown/wiki; addresses [issue #10](https://github.com/jakewvincent/mkdnflow.nvim/issues/10))
* 04/30/22: Added functionality to update parent to-dos when child to-do status is changed; customize to-do symbols
* 04/28/22: Interpret links to markdown files correctly when specified with an absolute path (one starting with `/` or `~/`)
* 04/28/22: Added ability to follow links to markdown files with an anchor and then jump to the appropriate heading (if one exists)
* 04/27/22: Add in some list item functionality (not mapped to anything by default yet)
* 04/26/22: Set command name to `false` in `mappings` table to disable mapping
* 04/25/22: Specify mode in mappings table
* 04/24/22: User can shut up messages by specifying 'true' in their config under the 'silent' key
* 04/24/22: Added Windows compatibility!
* 04/23/22: Major reorganization of followPath() function which ships off some of its old functionality to the new links module and much of it to smaller, path-type-specific functions in the new paths module
* 04/22/22: Added ability to identify the notebook's root directory by specifying a "tell" in the config (a file that can be used to identify the root)
* 04/20/22: Added ability to replace a link with just its name (effectively undoing the link) -- mapped to `<M-CR>` by default (Alt-Enter)
* 04/20/22: Fix for [issue #22](https://github.com/jakewvincent/mkdnflow.nvim/issues/22)
* 04/19/22: Toggle to-do list item's completion status
* 04/18/22: If URL is under cursor, make a link from the whole URL (addresses [issue #18](https://github.com/jakewvincent/mkdnflow.nvim/issues/18))
* 04/16/22: Added forward navigation (~undoing 'back')
* 04/11/22: Added ability to change heading level
* 04/05/22: Added ability to create anchor links; jump to matching headings; yank formatted anchor links from headings
* 04/03/22: Added ability to jump to headings if a link is an anchor link
* 03/06/22: Added ability to search .bib files and act on relevant information in bib entries when the cursor is in a citation and `<CR>` is pressed
* 02/03/22: Fixed case issue w/ file extensions ([issue #13](https://github.com/jakewvincent/mkdnflow.nvim/issues/13))
* 01/21/22: Path handler can now identify links with the file: prefix that have absolute paths or paths starting with `~/`
* 11/10/21: Merged [@pbogut's PR](https://github.com/jakewvincent/mkdnflow.nvim/pull/7), which modifies `require('mkdnflow').buffers.goBack()` to return a boolean (`true` if `goBack()` succeeds; `false` if `goBack()` isn't possible). For the default mappings, this causes no change in behavior, but users who wish `<BS>` to perform another function in the case that `goBack()` fails can now use `goBack()` in the antecedent of a conditional. @pbogut's mapping, for reference:
```lua
if not require('mkdnflow').buffers.goBack() then
  vim.cmd('Dirvish %:p')
end
```
* 11/08/21: Add option to wrap to beginning/end of file when jumping to next/previous link. Off by default.
* 11/01/21: Added vimdoc documentation
* 10/30/21: Added capability for manually starting the plugin with `:Mkdnflow`, addressing [issue #5](https://github.com/jakewvincent/mkdnflow.nvim/issues/5)
* 09/23/21: Fixed [issue #3](https://github.com/jakewvincent/mkdnflow.nvim/issues/3)
* 09/23/21: Added compatibility with macOS 
* 09/21/21: Fixed [issue #1](https://github.com/jakewvincent/mkdnflow.nvim/issues/1). Implemented a push-down stack to better handle backwards navigation through previously-opened buffers.
* 09/19/21: Fixed [issue #2](https://github.com/jakewvincent/mkdnflow.nvim/issues/2). Paths with spaces can now be created.

</p></details>

## 🔗 Links
* [Awesome Neovim's list of (markdown) plugins](https://github.com/rockerBOO/awesome-neovim#markdown)
* [A more granular list of Neovim plugins](https://github.com/yutkat/my-neovim-pluginlist)

### To complement mkdnflow
* [clipboard-image.nvim](https://github.com/ekickx/clipboard-image.nvim) (Paste links to images in markdown syntax)
* [mdeval.nvim](https://github.com/jubnzv/mdeval.nvim) (Evaluate code blocks inside markdown documents)
* Preview plugins
    * [Markdown Preview for (Neo)vim](https://github.com/iamcco/markdown-preview.nvim) ("Preview markdown on your modern browser with synchronised scrolling and flexible configuration")
    * [nvim-markdown-preview](https://github.com/davidgranstrom/nvim-markdown-preview) ("Markdown preview in the browser using pandoc and live-server through Neovim's job-control API")
    * [glow.nvim](https://github.com/npxbr/glow.nvim) (Markdown preview using [glow](https://github.com/charmbracelet/glow)—render markdown in Neovim, with *pizzazz*!)
    * [auto-pandoc.nvim](https://github.com/jghauser/auto-pandoc.nvim) ("[...] allows you to easily convert your markdown files using pandoc.")

### Alternatives to mkdnflow
* [Vimwiki](https://github.com/vimwiki/vimwiki) (Full-featured wiki navigation/maintenance and filetype plugin, written in Vimscript)
* [wiki.vim](https://github.com/lervag/wiki.vim/) (A lighter-weight alternative to Vimwiki, written in Vimscript)
* [Neorg](https://github.com/nvim-neorg/neorg) (A revised [Org-mode](https://en.wikipedia.org/wiki/Org-mode) for Neovim, written in Lua)
* [follow-md-links.nvim](https://github.com/jghauser/follow-md-links.nvim) (A simpler plugin for following markdown links, written in Lua)
