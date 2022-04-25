<p align=center>
<img src="assets/logo/mkdnflow_logo.png"><br/>
   <strong>Jump to</strong>: <a href="#-features">Features</a> / <a href="#-installation">Installation</a> / <a href="#%EF%B8%8F-configuration">Configuration</a><br/>
   <a href="#-commands-and-default-mappings">Commands & default mappings</a> / <a href="#%EF%B8%8F-to-do">To do</a> / <a href="#-recent-changes">Recent changes</a><br/><a href="#-links">Other plugins and links</a>
</p>

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

### Link creation
* Create links (to other markdown documents) from (a) word under cursor or (b) visual selection (mapped to `<CR>` by default)
    * Automatically prefix filenames created in the above manner with the current date: `YYYY-MM-DD_<word>.md`. The prefix can be changed; see [Configuration](#%EF%B8%8F-configuration).
    * 🆕 Create anchor links from a visual selection if the selection starts with `#` 
    * 🆕 Yank an anchor link out of a heading on the current line (mapped to `ya` by default)
    * 🆕 If what's under the cursor is identified as a URL, create a link from that URL

### Jump to links
* Jump to the next/previous link in the file, optionally wrapping to beginning/end of file (mapped to `<Tab>` and `<S-Tab>` by default, respectively)
* 🆕 Jump to headings in the current file that match an anchor link. Headings must start with a hash, and the path part of the link must look like the heading with (a) any spaces between the last hash mark and the beginning of the heading text removed, (b) all other spaces converted to a dash, (c) non-alphanumeric characters removed, (d) strings of multiple hashes converted into a single hash, and (e) all upper-case characters converted to lower-case characters. For example:
    * `## Bills to pay` will be jumped to if the path in the anchor link is `#bills-to-pay`
    * `#### Groceries/other things to buy` will be jumped to if the path in the anchor link is `#groceriesother-things-to-buy`

### Customize perspective
* Specify what perspective the plugin-should take when interpreting links to files. There are three options:
    1. Interpret links relative to the first-opened file (default behavior)
    2. Interpret links relative to the file open in the current buffer
    3. 🆕 Interpret links relative to the root directory of the notebook/wiki that the file in the current buffer is a part of. To enable this functionality, you must set `links_relative_to.target` to `root` in your config and specify a "tell" for the root directory under `links_relative_to.root_tell`. The _tell_ is the name of a single file that can be used to identify the root directory (e.g. `index.md`, `.git`, `.root`, `.wiki_root`, etc.). See [Configuration](#%EF%B8%8F-configuration) for the default config and an example of how to configure the `links_relative_to` table.

### Act on links
* Follow links relative to the first-opened file or current file (as specified in your config) or, if the path is prefixed with `file:`, the path can be absolute (starting with `/`) or relative to your home directory (starting with `~/`) (mapped to `<CR>` by default)
    * `<CR>`ing on a link to a text file will open it in the current window (i.e. `:e <filename>`)
    * `<CR>`ing on a link to a file prefixed with `file:` (formerly `local:`), e.g. `[My Xournal notes](file:notes.xopp)`, will open that file with whatever the system's associated program is for that filetype (using `xdg-open` on Linux or `open` on macOS)
    * `<CR>`ing on a link to an absolute path or a path in ~/, as long as that path is prefixed with `file:`, will open that file with the system's associated program for that filetype (see above)
    * `<CR>`ing on a link to a web URL will open that link in your default browser
* 🆕 Open files or websites associated with citations (using `<CR>`).
    * Specify a path to a [.bib](http://www.bibtex.org/Format/) file in your config (see [Configuration](#%EF%B8%8F-configuration))
    * `<CR>`ing on a citation (e.g. `@Chomsky1957`, with or without square brackets around it) will open a file or website, depending on what fields are provided in the bib file. It opens whichever of these bib fields it finds first, prioritizing the higher items: `file > url > doi > howpublished`
* Create missing directories if a link goes to a file in a directory that doesn't exist

### Backward and forward navigation
* `<BS>` to go to previous file/buffer opened in the current window
* 🆕 `<Del>` to go to subsequent file/buffer opened in the current window (i.e. one that you just `<BS>`ed away from)

### Act on citations
* 🆕 If a default .bib file is specified in your mkdnflow [configuration](#%EF%B8%8F-configuration), `<CR>`ing on a citation key (e.g. `@Chomsky1957`) will try to do one of the following (in the following order, stopping if it succeeds):
    - Open a file specified under that citation key using your OS's default program for that filetype, if one is specified in your bib file
    - Open a URL specified under that citation key in your default browser
    - Open a DOI specified under that citation key in your default browser

### Keybindings
* Enable/disable default keybindings (see [Configuration](#%EF%B8%8F-configuration))
    - 🆕 Modify default keybindings individually in table passed to setup function (see [Configuration](#%EF%B8%8F-configuration))

### Manipulate headings
* 🆕 Increase/decrease heading levels (mapped to `+`/`-` by default). **Note**: *Increasing* the heading means increasing it in importance (i.e. making it bigger or more prominent when convertedto HTML and rendered in a browser), which counterintuitively means *removing a hash symbol*.

### 🆕 Lists
* Toggle the status of a to-do list item on the current line (mapped to `<C-Space>` by default). Toggling `* [ ] ...` will yield `* [-] ...`; toggling `* [-] ...` will yield `* [X] ...`; and toggling `* [X] ...` will yield `* [ ] ...`.

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
    -- Type: boolean. Create directories (recursively) if link contains a
    --     missing directory.
    -- 'false' prevents missing directories from being created
    create_dirs = true,             

    -- Type: table. The 'target' key specifies what the priority perspective s-
    -- hould be. The default is whatever file is opened first. 'fallback' spec-
    -- ifies a backup perspective if the target perspective cannot be determin-
    -- ed. Other options: 'root'. 'root_tell' should be a string telling mkdnf-
    -- low how to identify the root directory if 'target' or 'fallback' is set
    -- to 'root'. The tell should be a file in the root directory, e.g. '.git',
    -- 'index.md', or any arbitrary file that can reliably be used to identify
    -- the root directory of your notebook/wiki.
    links_relative_to = {
        target = 'first',
        fallback = 'current',
        root_tell = false
    },    

    -- Type: key-value pair(s). The plugin's features are enabled only when one
    -- of these filetypes is opened; otherwise, the plugin does nothing. NOTE:
    -- extensions are converted to lowercase, so any filetypes that convention-
    -- ally use uppercase characters should be provided here in lowercase.
    filetypes = {md = true, rmd = true, markdown = true},

    -- Type: boolean. When true, the createLinks() function tries to evaluate
    --     the string provided as the value of new_file_prefix.
    -- 'false' results in the value of new_file_prefix being used as a string,
    --     i.e. it is not evaluated, and the prefix will be invariant.
    evaluate_prefix = true,

    -- Type: string. Defines the prefix that should be used to create new links.
    --     This is evaluated at the time createLink() is run, which is to say
    --     that it's run whenever <CR> is pressed (under the default mappings).
    --     This makes for many interesting possibilities.
    new_file_prefix = [[os.date('%Y-%m-%d_')]],

    -- Type: boolean. When true and Mkdnflow is searching for the next/previous
    --     link or heading in the file, it will wrap to the beginning of the
    -- file (if it's reached the end) or wrap to the end of the file (if it's
    -- reached the beginning during a backwards search).
    wrap_to_beginning = false,
    wrap_to_end = false,

    -- Type: string. This is the path where mkdnflow will look for a .bib file
    --     when acting upon markdown citations.
    default_bib_path = '',

    -- Type: boolean. A value of 'false' will prevent any messages from being
    -- printed to the area below the status line (except for important compa-
    -- tibility warnings about breaking changes)
    silent = false,

    -- Type: boolean. Use mapping table (see '❕Commands and default mappings').
    -- 'false' disables mappings and prevents user from modifying mappings via
    -- the 'mappings' table.
    use_mappings_table = true,        

    -- Type: table. Keys should be the names of commands (see :h Mkdnflow-comma-
    -- nds for a list), and values should be strings indicating the key mapping.
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
