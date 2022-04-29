<p align=center>
<img src="assets/logo/mkdnflow_logo.png">
</p>
<p align=center><img src="https://camo.githubusercontent.com/dba3dd4ec5c0640974a4dad6acdef2e5fe9ef9eee3160ff309aa40dcb091b956/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f6c75612d2532333243324437322e7376673f267374796c653d666c6174266c6f676f3d6c7561266c6f676f436f6c6f723d7768697465"></p>
<p align=center>
   <a href="#-features">Features</a> / <a href="#-installation">Installation</a> / <a href="#%EF%B8%8F-configuration">Config</a> / <a href="#-commands-and-default-mappings">Commands & mappings</a> / <a href="#%EF%B8%8F-to-do">To do</a> / <a href="#-recent-changes">Recent changes</a> / <a href="#-links">Links</a>
</p>

## 📝 Description

This plugin is designed for the *fluent* navigation of notebooks/journals/wikis written in [markdown](https://markdownguide.org). It is a set of functions and mappings to those functions which make it easy to navigate and manipulate markdown notebooks/journals/wikis in Neovim. The original goal of Mkdnflow was to replicate some features from [Vimwiki](https://github.com/vimwiki/vimwiki) in Lua instead of VimL, but my current goal for this project is to make this plugin as useful as possible for anyone using Neovim who maintains a set of markdown notes and wishes to efficiently navigate those notes and keep them organized and connected.

I keep tabs on the project's [issues](https://github.com/jakewvincent/mkdnflow.nvim/issues) and appreciate feature requests, suggestions, and bug reports. If you'd like to contribute to the plugin, fork this repo and submit a [pull request](https://github.com/jakewvincent/mkdnflow.nvim/pulls) with your changes or additions. If you need Lua resources, see [this page](https://neovim.io/doc/lua-resources/) for a starting point or run `:h lua` or `:h api` in Neovim.

### ⚡ Requirements

* Linux, macOS, or Windows
* Neovim >= 0.5.0

### ➖ Differences from [Vimwiki](https://github.com/vimwiki/vimwiki)

* Vimwiki doesn't use markdown by default; mkdnflow only works for markdown.
* I'm intending mkdnflow to be a little lighter weight/less involved than Vimwiki. Mkdnflow doesn't and won't provide syntax highlighting and won't create new filetypes.
* Written in Lua

## ✨ Features

### Create and destroy links
* `<CR>` on word under cursor or visual selection to create a notebook-internal link
    * Customizable filename prefix (default is the current date in `YYYY-MM-DD` format (see [Configuration](#%EF%B8%8F-configuration)).
* `<M-CR>` (Alt-Enter) when your cursor is anywhere in a link to destroy it (replace it with the text in [...])
* Create an anchor link if the visual selection starts with `#` 
* Create a web link if what's under the cursor is a URL (and move the cursor to enter the link name)
* `ya` on a heading to add a formatted anchor link for the heading to the default register (ready to paste in the current buffer)
    * 🆕 `yfa` to do the same, but adding the absolute path of the file before the anchor (for pasting in another buffer)

### Jump between links
* `<Tab>` and `<S-Tab>` to jump to the next and previous links in the file
    * "Wrap" to the beginning/end of the file with a [config setting](#%EF%B8%8F-configuration)

### Customize perspective for link interpretation
* Specify what perspective the plugin-should take when interpreting links to files. There are three options:
    1. Interpret links relative to the first-opened file (default behavior; similar to #3 if your first-opened file is always in the root directory)
    2. Interpret links relative to the file open in the current buffer
    3. 🆕 Interpret links relative to the root directory of the notebook/wiki that the file in the current buffer is a part of. To enable this functionality, set `perspective.priority` to `root` in your config, and pass a file as the value of `perspective.root_tell`. The _tell_ is the name of a single file that can be used to identify the root directory (e.g. `index.md`, `.git`, `.root`, `.wiki_root`, etc.). See [the default config](#%EF%B8%8F-configuration) for how to configure the `perspective` table.
* 🆕 Override any of the above settings by specifying a link to a markdown file with an absolute path (one that starts with `/` or `~/`). Links within this file will still receive the relative interpretation, so this is best for references out of the project directory to markdown files without their own dependencies (unless those dependencies are within the project directory).

### Follow links _and citations_
* `<CR>` on various kinds of links to "follow" them:
    * `.md` links open in the current window
    * Absolute links or `.md` links relative to home open in the current window but are interpreted with absolute perspective (e.g. `[File](/home/user/file.md)`/`[File](C:\Users\user\file.md)` on Windows, or `[File](~/Documents/file.md)`)
    * Links to a file prefixed with `file:` (e.g. `[My Xournal notes](file:notes.xopp)`) open with the system's default program for that filetype
    * Link to URLs are opened in the default browser
    * Anchor links to headings in the current file will trigger a jump to that heading. Headings must start with a hash, and the path part of the link must look like the heading with (a) any spaces between the last hash mark and the beginning of the heading text removed, (b) all other spaces converted to a dash, (c) non-alphanumeric characters removed, (d) strings of multiple hashes converted into a single hash, and (e) all upper-case characters converted to lower-case characters. For example:
        * `## Bills to pay` will be jumped to if the path in the anchor link is `#bills-to-pay`
        * `#### Groceries/other things to buy` will be jumped to if the path in the anchor link is `#groceriesother-things-to-buy`
* `<CR>` on citations to open associated files or websites (e.g. `@Chomsky1957`, with or without brackets around it)
    * Specify a path to a [.bib](http://www.bibtex.org/Format/) file in [your config](#%EF%B8%8F-configuration)
    * Files are prioritized. If no file is found associated with the citation key, a URL associated with it will be opened. If no URL is found, a DOI is opened. If no DOI is found, whatever is in the `howpublished` field is opened.

### Create missing directories
* If a link goes to a file in a directory that doesn't exist, it can optionally [be created](#%EF%B8%8F-configuration)

### Backward and forward navigation
* `<BS>` to go **backward** (to the previous file/buffer opened in the current window, like clicking the back button in a web browser)
* `<Del>` to go **forward** (to the subsequent file/buffer opened in the current window, like clicking the forward button in a web browser)

### Keybindings
* Easy-to-remember [default keybindings](#-commands-and-default-mappings)
* 🆕 [Customize keybindings](#%EF%B8%8F-configuration) individually or [disable them altogether](#%EF%B8%8F-configuration))

### Manipulate headings
* Increase/decrease heading levels (mapped to `+`/`-` by default). **Note**: *Increasing* the heading means increasing it in importance (i.e. making it bigger or more prominent when converted to HTML and rendered in a browser), which counterintuitively means *removing a hash symbol*.

### Lists
* 🆕 Toggle the status of a to-do list item on the current line (mapped to `<C-Space>` by default). Toggling will result in the following changes:
    * `* [ ] ...` → `* [-] ...`
    * `* [-] ...` → `* [X] ...`
    * `* [X] ...` → `* [ ] ...`
* 🆕 Smart(er) behavior when `<CR>`ing in lists (NOTE: currently not enabled by default. See below.)
    * In unordered lists: Add another bullet on the next line, unless the current list item is empty, in which case it will be erased
    * In unordered to-do lists: Add another to-do item on the next line, unless the current to-do is empty, in which case it will be replaced with a simple (non-to-do) list item
    * In ordered lists: Add another item on the next line (keeping numbering updated), unless the current item is empty, in which case it will be erased
    * NOTE: The above list functions are currently disabled by default in case some find them too intrusive. Please test them and provide feedback! To enable the functionality, you'll need to remap `<CR>` in insert mode:

```lua
require('mkdnflow').setup({
    mappings = {
        MkdnNewListItem = {'i', '<CR>'}
    }
})
```

<p align=center><strong>More coming soon! I use this plugin daily for work have been regularly adding new features for my use cases. Please share ideas and feature requests by <a href="https://github.com/jakewvincent/mkdnflow.nvim/issues">creating an issue</a>.</strong></p>

## 📦 Installation

### init.lua
<details>
<summary>Install with Packer</summary><p>

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

<details>
<summary>Install with Paq</summary><p>

```lua
require('paq')({
    -- Your other plugins;
    'jakewvincent/mkdnflow.nvim';
    -- Your other plugins;
})

-- Include the setup function somewhere else in your init.lua/vim file, or the
-- plugin won't activate itself:

require('mkdnflow').setup({
    -- Config goes here; leave blank for defaults
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

* The plugin won't start *automatically* if the first-opened file is not one of the default or named extensions (see [Configuration](#%EF%B8%8F-configuration)), but you can manually start the plugin with the defined command `:Mkdnflow`.
* All functionality of the plugin should now work on all operating systems, including Windows! However, since I don't use Windows on my daily driver, there may be edge cases that cause trouble. Please file an issue if anything comes up.

## ⚙️ Configuration

Currently, the setup function uses the defaults shown below. See the descriptions and non-default options in the [section below the following block](#config-descriptions). **To use these defaults, simply pass an empty table to the setup function:** `require('mkdnflow').setup({})`. To change these settings, specify new values for any of them them in the setup function.

```lua
-- ** DEFAULT SETTINGS; TO USE THESE, PASS AN EMPTY TABLE TO THE SETUP FUNCTION **
require('mkdnflow').setup({
    create_dirs = true,             
    perspective = {
        priority = 'first',
        fallback = 'current',
        root_tell = false
    },    
    filetypes = {md = true, rmd = true, markdown = true},
    prefix = {
        evaluate = true,
        string = [[os.date('%Y-%m-%d_')]]
    },
    wrap = false,
    default_bib_path = '',
    silent = false,
    use_mappings_table = true,
    mappings = {
        MkdnNextLink = {'n', '<Tab>'},
        MkdnPrevLink = {'<S-Tab>'},
        MkdnNextHeading = {'n', '<leader>]'},
        MkdnPrevHeading = {'n', '<leader>['},
        MkdnGoBack = {'n', '<BS>'},
        MkdnGoForward = {'n', '<Del>'},
        MkdnFollowLink = {{'n', 'v'}, '<CR>'},
        MkdnDestroyLink = {'n', '<M-CR>'},
        MkdnYankAnchorLink = {'n', 'ya'},
        MkdnYankFileAnchorLink = {'n', 'yfa'},
        MkdnIncreaseHeading = {'n', '+'},
        MkdnDecreaseHeading = {'n', '-'},
        MkdnToggleToDo = {'n', '<C-Space>'},
        MkdnNewListItem = false
    }
})
```

### Config descriptions
#### `create_dirs` (boolean value)
* `true`: Directories referenced in a link will be (recursively) created if they do not exist
* `false` No action will be taken when directories referenced in a link do not exist. Neovim will open a new file, but you will get an error when you attempt to write the file.

#### `perspective` (table value)
* `perspective.priority` (string value): Specifies the priority perspective to take when interpreting link paths
    * `'first'`: Links will be interpreted relative to the first-opened file (when the current instance of Neovim was started)
    * `'current'`: Links will be interpreted relative to the current file
    * `'root'`: Links will be interpreted relative to the root directory of the current notebook/wiki (requires `perspective.root_tell` to be specified)
* `perspective.fallback` (string value): Specifies the backup perspective to take if priority isn't possible (e.g. if it is `'root'` but no root directory is found)
    * `'first'`: (see above)
    * `'current'`: (see above)
    * `'root'`: (see above)
* `perspective.root_tell` (string or boolean value)
    * `'<any file name>'`: Any arbitrary filename by which the plugin can uniquely identify the root directory of the current notebook/wiki. If `false` is used instead, the plugin will never search for a root directory, even if `perspective.priority` is set to `root`.

#### `filetypes` (table value)
* `<any arbitrary filetype extension>` (boolean value)
    * `true`: A matching extension will enable the plugin's functionality for a file with that extension

Note: This functionality references the file's extension. It does not rely on Neovim's filetype recognition. The extension must be provided in lower case because the plugin converts file names to lowercase. Any arbitrary extension can be supplied. Setting an extension to `false` is the same as not including it in the list.

#### `prefix` (table value)
* `prefix.string` (string value)
    * `[[string]]`: A fixed string to prefix to new markdown document names in a link or a string of Lua code to evaluate at the time of link creation and use the output of as a prefix to the file name
* `prefix.evaluate` (boolean value)
    * `true`: The plugin will attempt to have Lua evaluate the string and will retrieve its output to prefix to the file name in the link
    * `false`: The plugin will use `prefix.string` as a fixed prefix

Note: If you don't want prefixes, set `evaluate = false` and `string = ''`

#### `wrap` (boolean value)
* `true`: When jumping to next/previous links or headings, the cursor will continue searching at the beginning/end of the file
* `false`: When jumping to next/previous links or headings, the cursor will stop searching at the end/beginning of the file

#### `use_mappings_table` (boolean value)
* `true`: Mappings will be defined with the help of `mappings` (see below), including your custom mappings (if defined in your mkdnflow config)
* `false`: Mappings will not be defined with the help of the `mappings` table, and in fact, **no default mappings will be activated at all**

Note: See [default mappings](#-commands-and-default-mappings)

#### `mappings` (table value)
* `mappings.<name of command>` (table value or `false`)
    * `mappings.<name of command>[1]` string or table value representing the mode (or table of modes) the mapping should apply in (`'n'`, `'v'`, etc.)
    * `mappings.<name of command>[2]` string representing the keymap (e.g. `'<Space>'`)
    * set `mappings.<name of command> = false` to disable default mapping without providing a custom mapping

Note: `<name of command>` should be the name of a commands defined in `mkdnflow.nvim/plugin/mkdnflow.lua` (see :h Mkdnflow-commands for a list).

#### `default_bib_path` (string value)
* `'path/to/.bib/file'`: Specifies a path where the plugin will look for a .bib file when citations are "followed"

#### `silent` (boolean value)
* `true`: The plugin will not display any messages in the console except compatibility warnings related to your config
* `false`: The plugin will display messages to the console (all messages from the plugin start with ⬇️ )

### 👍 Recommended vim settings

I recommended turning on `autowriteall` in Neovim *for markdown filetypes*. This will ensure that changes to buffers are saved when you navigate away from that buffer, e.g. by following a link to another file. See `:h awa`.

```lua
-- If you have an init.lua
vim.cmd('autocmd FileType markdown set autowriteall')
```

```vim
" If you have an init.vim
autocmd FileType markdown set autowriteall
```

### ❕ Commands and default mappings

These default mappings can be disabled; see [Configuration](#%EF%B8%8F-configuration). Commands with no mappings trigger functions that are called by the functions with mappings, but I've given them a command name so you can use them as independent functions if you'd like to.

| Keymap       | Mode | Command                       | Description |
|--------------| ---- | ----------------------------- | ------------|
| `<Tab>`      | n    | `:MkdnNextLink<CR>`           | Move cursor to the beginning of the next link (if there is a next link) |
| `<S-Tab>`    | n    | `:MkdnPrevLink<CR>`           | Move the cursor to the beginning of the previous link (if there is one) |
| `<leader>]`  | n    | `:MkdnNextHeading<CR>`        | Move the cursor to the beginning of the next heading (if there is one) |
| `<leader>[`  | n    | `:MkdnPrevHeading<CR>`        | Move the cursor to the beginning of the previous heading (if there is one) |
| `<BS>`       | n    | `:MkdnGoBack<CR>`             | Open the historically last-active buffer in the current window |
| `<Del>`      | n    | `:MkdnGoForward<CR>`          | Open the buffer that was historically navigated away from in the current window |
| `<CR>`       | n, v | `:MkdnFollowLink<CR>`         | Open the link under the cursor, creating missing directories if desired, or if there is no link under the cursor, make a link from the word under the cursor |
| `<M-CR>`     | n    | `:MkdnDestroyLink<CR>`        | Destoy the link under the cursor, replacing it with just the text from [...] |
| `ya`         | n    | `:MkdnYankAnchorLink<CR>`     | Yank a formatted anchor link (if cursor is currently on a line with a heading) |
| `yfa`        | n    | `:MkdnYankFileAnchorLink<CR>` | Yank a formatted anchor link with the filename included before the anchor (if cursor is currently on a line with a heading) |
| `+`          | n    | `:MkdnIncreaseHeading<CR>`    | Increase heading importance (remove hashes) |
| `-`          | n    | `:MkdnDecreaseHeading<CR>`    | Decrease heading importance (add hashes) |
| `<C-Space>`  | n    | `:MkdnToggleToDo<CR>`         | Toggle to-do list item's completion status |
| --           | --   | `:MkdnNewListItem<CR>`        | Add a new ordered list item, unordered list item, or (uncompleted) to-do list item |
| --           | --   | `:MkdnCreateLink<CR>`         | Replace the word under the cursor with a link in which the word under the cursor is the name of the link. This is called by MkdnFollowLink if there is no link under the cursor. |
| --           | --   | `:Mkdnflow<CR>`               | Manually start Mkdnflow |

### Miscellaneous notes on remapping
* The back-end function for `:MkdnGoBack`, `require('mkdnflow').buffers.goBack()`, returns a boolean indicating the success of `goBack()` (thanks, @pbogut!). This is useful if the user wishes to remap `<BS>` so that when `goBack()` is unsuccessful, another function is performed.

## ☑️ To do
* [ ] Lists
    * [ ] To-do list functions & mappings
        * [ ] Modify status of parent to-do when changing a child to-do (infer based on tab settings)
* [ ] Fancy table creation & editing
    * [ ] Create a table of x columns and y rows
    * [ ] Add/remove columns and rows
    * [ ] Horizontal and vertical navigation through tables (with `<Tab>` and `<CR>`?)
    * [ ] Make a way for the user to define specialized tables (e.g. time sheets)
* [ ] Easily rename file in link
* [ ] Command to add a "quick note" (add link to a specified file, e.g. `index.md`, and open the quick note)
* [ ] Improve citation functionality
    * [ ] Add ability to stipulate a .bib file in a yaml block at the top of a markdown file
* [ ] Headings
    * [ ] Easy folding & unfolding

<details>
<summary>Completed to-dos</summary><p>

* [X] Smart `<CR>` when in lists, etc.
* [X] Full compatibility with Windows
* [X] "Undo" a link (replace link w/ the text part of the link)
* [X] Easy *forward* navigation through buffers (with ~~`<S-BS>?`~~ `<Del>`)
* [X] Allow reference to absolute paths (interpret relatively [following config] if not prepended w/ `~` or `/`)
* [X] Allow parentheses in link names ([issue #8](https://github.com/jakewvincent/mkdnflow.nvim/issues/8))
* [X] Add a config option to wrap to the beginning of the document when navigating between links (11/08/21)

</p></details>


## 🔧 Recent changes
* 04/28/22: Interpret links to markdown files correctly when specified with an absolute path (one starting with `/` or `~/`)
* 04/28/22: Added ability to follow links to markdown files with an anchor and then jump to the appropriate heading (if one exists)
* 04/27/22: Add in some list item functionality (not mapped to anything by default yet)
* 04/26/22: Set command name to `false` in `mappings` table to disable mapping
* 04/25/22: Specify mode in mappings table
* 04/24/22: User can shut up messages by specifying 'true' in their config under the 'silent' key
* 04/24/22: Added Windows compatibility!
* 04/23/22: Major reorganization of followPath() function which ships off some of its old functionality to the new links module and much of it to smaller, path-type-specific functions in the new paths module
* 04/22/22: Added ability to identify the notebook/wiki's root directory by specifying a "tell" in the config (a file that can be used to identify the root)
* 04/20/22: Added ability to replace a link with just its name (effectively undoing the link) -- mapped to `<M-CR>` by default (Alt-Enter)
* 04/20/22: Fix for [issue #22](https://github.com/jakewvincent/mkdnflow.nvim/issues/22)
* 04/19/22: Toggle to-do list item's completion status
* 04/18/22: If URL is under cursor, make a link from the whole URL (addresses [issue #18](https://github.com/jakewvincent/mkdnflow.nvim/issues/18))
* 04/16/22: Added forward navigation (~undoing 'back')
* 04/11/22: Added ability to change heading level
* 04/05/22: Added ability to create anchor links; jump to matching headings; yank formatted anchor links from headings
* 04/03/22: Added ability to jump to headings if a link is an anchor link
* 03/06/22: Added ability to search .bib files and act on relevant information in bib entries when the cursor is in a citation and `<CR>` is pressed

<details>
<summary>Older changes</summary><p>

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
* Plugins that would complement mkdnflow:
    * [clipboard-image.nvim](https://github.com/ekickx/clipboard-image.nvim) (Paste links to images in markdown syntax)
    * [mdeval.nvim](https://github.com/jubnzv/mdeval.nvim) (Evaluate code blocks inside markdown documents)
    * Preview plugins
        * [Markdown Preview for (Neo)vim](https://github.com/iamcco/markdown-preview.nvim) ("Preview markdown on your modern browser with synchronised scrolling and flexible configuration")
        * [nvim-markdown-preview](https://github.com/davidgranstrom/nvim-markdown-preview) ("Markdown preview in the browser using pandoc and live-server through Neovim's job-control API")
        * [glow.nvim](https://github.com/npxbr/glow.nvim) (Markdown preview using [glow](https://github.com/charmbracelet/glow)—render markdown in Neovim, with *pizzazz*!)
        * [auto-pandoc.nvim](https://github.com/jghauser/auto-pandoc.nvim) ("[...] allows you to easily convert your markdown files using pandoc.")
* [Awesome Neovim's list of markdown plugins](https://github.com/rockerBOO/awesome-neovim#markdown) (a big list of plugins for Neovim)
* [Vimwiki](https://github.com/vimwiki/vimwiki) (Full-featured journal navigation/maintenance)
