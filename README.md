<p align=center>
<img src="assets/logo/mkdnflow_logo.png"><br/>
   <strong>Jump to</strong>: <a href="#-features">Features</a> / <a href="#-installation">Installation</a> / <a href="#%EF%B8%8F-configuration">Configuration</a><br/>
   <a href="#-commands-and-default-mappings">Commands & default mappings</a> / <a href="#%EF%B8%8F-to-do">To do</a> / <a href="#-recent-changes">Recent changes</a><br/><a href="#-links">Other plugins and links</a>
</p>
<p align=center><img src="https://camo.githubusercontent.com/dba3dd4ec5c0640974a4dad6acdef2e5fe9ef9eee3160ff309aa40dcb091b956/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f6c75612d2532333243324437322e7376673f267374796c653d666c6174266c6f676f3d6c7561266c6f676f436f6c6f723d7768697465"></p>

## 📝 Description

This plugin is designed for the *fluent* navigation of notebooks/journals/wikis written in [markdown](https://markdownguide.org). It is a set of functions and and mappings to those functions which make it easy to navigate and manipulate markdown notebooks/journals/wikis in Neovim. The original goal of Mkdnflow was to replicate some features from [Vimwiki](https://github.com/vimwiki/vimwiki) in Lua instead of VimL, but my current goal for this project is to make this plugin as useful as possible for anyone using Neovim who maintains a set of markdown notes and wishes to keep those notes organized and connected.

I keep tabs on the project's [issues](https://github.com/jakewvincent/mkdnflow.nvim/issues) and appreciate feature requests, suggestions, and bug reports. If you'd like to contribute to the plugin, fork this repo and submit a [pull request](https://github.com/jakewvincent/mkdnflow.nvim/pulls) with your changes or additions. If you need Lua resources, see [this page](https://neovim.io/doc/lua-resources/) for a starting point or run `:h lua` or `:h api` in Neovim.

### ⚡ Requirements

* Linux, macOS, or Windows
* Neovim >= 0.5.0

### ➖ Differences from [Vimwiki](https://github.com/vimwiki/vimwiki)

* Vimwiki doesn't use markdown by default; mkdnflow only works for markdown.
* I'm intending mkdnflow to be a little lighter weight/less involved than Vimwiki. Mkdnflow doesn't and won't provide syntax highlighting and won't create new filetypes.
* Written in Lua

## ✨ Features

### Create links
* `<CR>` on word under cursor or visual selection to create a notebook-internal link
    * Customizable filename prefix (default is the current date in `YYYY-MM-DD` format (see [Configuration](#%EF%B8%8F-configuration)).
* 🆕 Create an anchor links if the visual selection starts with `#` 
* 🆕 Create a web link if what's under the cursor is a URL (and move the cursor to enter the link name)
* 🆕 `ya` on a heading to add a formatted anchor link for the heading to the default register (ready to paste)

### Jump to links
* `<Tab>` and `<S-Tab>` to jump to the next and previous links in the file
    * Wrap the beginning/end of the file with a [config setting](#%EF%B8%8F-configuration)

### Customize perspective for link interpretation
* Specify what perspective the plugin-should take when interpreting links to files. There are three options:
    1. Interpret links relative to the first-opened file (default behavior)
    2. Interpret links relative to the file open in the current buffer
    3. 🆕 Interpret links relative to the root directory of the notebook/wiki that the file in the current buffer is a part of. To enable this functionality, you must set `links_relative_to.target` to `root` in your config and specify a "tell" for the root directory under `links_relative_to.root_tell`. The _tell_ is the name of a single file that can be used to identify the root directory (e.g. `index.md`, `.git`, `.root`, `.wiki_root`, etc.). See [Configuration](#%EF%B8%8F-configuration) for the default config and an example of how to configure the `links_relative_to` table.

### Follow links _and citations_
* `<CR>` on various kinds of links to "follow" them:
    * `.md` links open in the current window
    * Absolute links or `.md` links relative to home open in the current window but are interpreted with absolute perspective (e.g. `[File](/home/user/file.md)`/`[File](C:\Users\user\file.md)` on Windows, or `[File](~/Documents/file.md)`)
    * Links to a file prefixed with `file:` (e.g. `[My Xournal notes](file:notes.xopp)`) open with the system's default program for that filetype
    * Link to URLs are opened in the default browser
    * 🆕 Anchor links to headings in the current file will trigger a jump to that heading. Headings must start with a hash, and the path part of the link must look like the heading with (a) any spaces between the last hash mark and the beginning of the heading text removed, (b) all other spaces converted to a dash, (c) non-alphanumeric characters removed, (d) strings of multiple hashes converted into a single hash, and (e) all upper-case characters converted to lower-case characters. For example:
        * `## Bills to pay` will be jumped to if the path in the anchor link is `#bills-to-pay`
        * `#### Groceries/other things to buy` will be jumped to if the path in the anchor link is `#groceriesother-things-to-buy`
* 🆕 `<CR>` on citations to open associated files or websites (e.g. `@Chomsky1957`, with or without brackets around it)
    * Specify a path to a [.bib](http://www.bibtex.org/Format/) file in [your config](#%EF%B8%8F-configuration)
    * Files are prioritized. If no file is found associated with the citation key, a URL associated with it will be opened. If no URL is found, a DOI is opened. If no DOI is found, whatever is in the `howpublished` field is opened.

### Create missing directories
* If a link goes to a file in a directory that doesn't exist, it can optionally [be created](#%EF%B8%8F-configuration)

### Backward and forward navigation
* `<BS>` to go to previous file/buffer opened in the current window
* 🆕 `<Del>` to go to subsequent file/buffer opened in the current window (i.e. one that you just `<BS>`ed away from)

### Keybindings
* Easy-to-remember [default keybindings](#-commands-and-default-mappings)
* 🆕 [Customize keybindings](#%EF%B8%8F-configuration) individually or [disable them altogether](#%EF%B8%8F-configuration))

### Manipulate headings
* 🆕 Increase/decrease heading levels (mapped to `+`/`-` by default). **Note**: *Increasing* the heading means increasing it in importance (i.e. making it bigger or more prominent when convertedto HTML and rendered in a browser), which counterintuitively means *removing a hash symbol*.

### To-do lists
* Toggle the status of a to-do list item on the current line (mapped to `<C-Space>` by default). Toggling `* [ ] ...` will yield `* [-] ...`; toggling `* [-] ...` will yield `* [X] ...`; and toggling `* [X] ...` will yield `* [ ] ...`.

<p align=center>**More coming soon! I use this plugin daily for work and regularly add new features inspired by real-world use cases. Please share ideas feature requests by [creating an issue](https://github.com/jakewvincent/mkdnflow.nvim/issues).**</p>

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

Currently, the setup function uses the defaults shown below. See the descriptions and non-default options in the comments above each setting. **To use these defaults, simply call the setup function with an empty table as the argument:** `require('mkdnflow').setup({})`. To change these settings, specify new values for any of them them in the setup function.

```lua
require('mkdnflow').setup({
    -- Boolean. Create directories (recursively) if link references a missing
    -- directory.
    create_dirs = true, -- true causes missing directories to be created. Other values: false.

    -- Table. 'target' key specifies priority perspective. 'fallback' specifies a backup perspective
    -- if the target perspective cannot be determined. 'root_tell' specifies a file by which the ro-
    -- ot directory of the notebook/wiki can be identified (if 'target' is specified as 'root').
    links_relative_to = {
        target = 'first',       -- 'first' means links open relative to first-opened file. Other va-
                                -- lues: 'current'; 'root'
        fallback = 'current',   -- Backup value for target.
        root_tell = false       -- false prevents root directory from being identified if 'target'
                                -- is 'root'. Other values: any string representing a file.
    },    

    -- Table. Plugin's features enabled only when a file with one of these extensions is opened. Pr-
    -- ovide in lowercase. Any arbitrary extension can be supplied.
    filetypes = {md = true, rmd = true, markdown = true},

    -- Boolean. Tells plugin whether `new_file_prefix` should be evaluated as Lua code or interpret-
    -- ed as a fixed string when links are made.
    evaluate_prefix = true, -- true means the plugin will evaluate new_file_prefix as Lua code. Oth-
                            -- er values: false.

    -- String. Should be Lua code that produces a string value if evaluate_prefix is true.
    new_file_prefix = [[os.date('%Y-%m-%d_')]],

    -- Boolean. Tells plugin whether to jump to beginning/end of file when searching for the next/p-
    -- revious link or heading.
    wrap_to_beginning = false,  -- false means search will stop at document boundaries. Other value-
    wrap_to_end = false,        -- s: true.

    -- String. Path where the plugin will look for a .bib file when acting upon markdown citations.
    default_bib_path = '',

    -- Boolean. Whether the plugin should display relevant messages or not. Warnings about breaking
    -- changes will always be displayed.
    silent = false, -- false means relevant messages will be printed to the area below the status l-
                    -- ine. Other values: true.

    -- Boolean. Whether to use mapping table (see '❕Commands and default mappings').
    use_mappings_table = true, -- true means the table will be used. Other values: false (disables
                               -- mappings and prevents modification of mappings via table).

    -- Table. Keys should be the names of commands (see :h Mkdnflow-commands for a list). Values sh-
    -- ould be strings indicating the key mapping.
    mappings = {
        MkdnNextLink = '<Tab>',
        MkdnPrevLink = '<S-Tab>',
        MkdnNextHeading = '<leader>]',
        MkdnPrevHeading = '<leader>[',
        MkdnGoBack = '<BS>',
        MkdnGoForward = '<Del>',
        MkdnFollowLink = '<CR>',
        MkdnYankAnchorLink = 'ya',
        MkdnIncreaseHeading = '+',
        MkdnDecreaseHeading = '-',
        MkdnToggleToDo = '<C-Space>'
    }
})
```

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

| Keymap       | Mode | Command                    | Description |
|--------------| ---- | -------------------------- | ------------|
| `<Tab>`      | n    | `:MkdnNextLink<CR>`        | Move cursor to the beginning of the next link (if there is a next link) |
| `<S-Tab>`    | n    | `:MkdnPrevLink<CR>`        | Move the cursor to the beginning of the previous link (if there is one) |
| `<leader>]`  | n    | `:MkdnNextHeading<CR>`     | Move the cursor to the beginning of the next heading (if there is one) |
| `<leader>[`  | n    | `:MkdnPrevHeading<CR>`     | Move the cursor to the beginning of the previous heading (if there is one) |
| `<BS>`       | n    | `:MkdnGoBack<CR>`          | Open the historically last-active buffer in the current window |
| `<Del>`      | n    | `:MkdnGoForward<CR>`       | Open the buffer that was historically navigated away from in the current window |
| `<CR>`       | n    | `:MkdnFollowLink<CR>`      | Open the link under the cursor, creating missing directories if desired, or if there is no link under the cursor, make a link from the word under the cursor |
| `ya`         | n    | `:MkdnYankAnchorLink<CR>`  | Yank a formatted anchor link (if cursor is currently on a line with a heading) |
| `+`          | n    | `:MkdnIncreaseHeading<CR>` | Increase heading importance (remove hashes) |
| `-`          | n    | `:MkdnDecreaseHeading<CR>` | Decrease heading importance (add hashes) |
| `<C-Space>`  | n    | `:MkdnToggleToDo<CR>`      | Toggle to-do list item's completion status |
| --           | --   | `:MkdnCreateLink<CR>`      | Replace the word under the cursor with a link in which the word under the cursor is the name of the link |
| --           | --   | `:Mkdnflow<CR>`            | Manually start Mkdnflow |

### Miscellaneous notes on remapping
* The back-end function for `:MkdnGoBack`, `require('mkdnflow).buffers.goBack()`, returns a boolean indicating the success of `goBack()` (thanks, @pbogut!). This is useful if the user wishes to remap `<BS>` so that when `goBack()` is unsuccessful, another function is performed.

## ☑️ To do
* [ ] Lists
    * [ ] To-do list functions & mappings
    * [ ] Smart `<CR>` when in lists, etc.
* [ ] Fancy table creation & editing
    * [ ] Create a table of x columns and y rows
    * [ ] Add/remove columns and rows
    * [ ] Horizontal and vertical navigation through tables (with `<Tab>` and `<CR>`?)
    * [ ] Make a way for the user to define specialized tables (e.g. time sheets)
* [ ] Easily rename file in link
* [ ] Command to add a "quick note" (add link to a specified file, e.g. `index.md`, and open the quick note)
* [ ] Improve citation functionality
    - [ ] Add ability to stipulate a .bib file in a yaml block at the top of a markdown file

<details>
<summary>Completed to-dos</summary><p>

* [X] Full compatibility with Windows
* [X] "Undo" a link (replace link w/ the text part of the link)
* [X] Easy *forward* navigation through buffers (with ~~`<S-BS>?`~~ `<Del>`)
* [X] Allow reference to absolute paths (interpret relatively [following config] if not prepended w/ `~` or `/`)
* [X] Allow parentheses in link names ([issue #8](https://github.com/jakewvincent/mkdnflow.nvim/issues/8))
* [X] Add a config option to wrap to the beginning of the document when navigating between links (11/08/21)
* [X] Function to increase/decrease the level of headings
* [X] Jump to in-file locations by `<CR>`ing on links to headings

</p></details>


## 🔧 Recent changes
* 04/24/22: User can shut up messages by specifying 'false' in their config under the 'silent' key
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
