# ⬇️ mkdnflow

Jump to: [Installation](#-installation) / [Features](#-features) / [Configuration](#%EF%B8%8F-configuration) / [Commands & default mappings](#-commands-and-default-mappings) / [To do](#%EF%B8%8F-to-do) / [Other plugins and links](#-links)

## 📝 Description

This plugin is designed to replicate the features I use most from [Vimwiki](https://github.com/vimwiki/vimwiki), implementing them in Lua instead of VimL. It is a set of functions and keybindings (optional, but enabled by default) that make it easy to navigate and manipulate personal markdown notebooks/journals/wikis in Neovim.

If you have a suggestion or problem with anything, file an [issue](https://github.com/jakewvincent/mkdnflow.nvim/issues); or if you'd like to contribute, work on a fork of this repo and submit a [pull request](https://github.com/jakewvincent/mkdnflow.nvim/pulls).

### ⚡ Requirements

* Linux (for full functionality)
* Windows or macOS (for partial functionality; see [Caveats/warnings](#-caveats-warnings))
* Neovim >= 0.5.0

### ➖ Differences from [Vimwiki](https://github.com/vimwiki/vimwiki)

* Vimwiki doesn't use markdown by default; mkdnflow only works for markdown.
* I'm intending mkdnflow to be a little lighter weight/less involved than Vimwiki. Mkdnflow doesn't and won't provide syntax highlighting and won't create new filetypes.

## 📦 Installation

### init.lua
#### [Packer](https://github.com/wbthomason/packer.nvim)
```lua
use({'jakewvincent/mkdnflow.nvim',
     config = function()
        require('mkdnflow').setup({
            -- Config goes here; leave blank for defaults
        })
     end
})
```

#### [Paq](https://github.com/savq/paq-nvim)
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

### init.vim
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

## ✨ Features

* Create links from the word under the cursor (mapped to `<CR>` by default)
    * The default filename provided for the path prefixes the word under the cursor with the date in YYYY-MM-DD format: `YYYY-MM-DD_<word>.md`. The prefix can be changed. See [Configuration](#%EF%B8%8F-configuration).
* Jump to the next or previous link in the file (mapped to `<Tab>` and `<S-Tab>` by default, respectively)
* Follow links relative to the first-opened file or the current file (mapped to `<CR>` by default)
    * `<CR>`ing on a link to any kind of text file will open it (i.e. `:e <filename>`)
    * `<CR>`ing on a link to a file tagged with `file:` (formerly `local:`), e.g. `[My Xournal notes](file:notes.xopp)`, will open that file with whatever the system's associated program is for that filetype (using `xdg-open`)
    * `<CR>`ing on a link to a web URL will open that link in your default browser
* Create missing directories if a link goes to a file in a directory that doesn't exist
* `<BS>` to go to previous file/buffer opened in the window
* Enable/disable default keybindings (see [Configuration](#%EF%B8%8F-configuration))

### ❗ Caveats/warnings

* The plugin effectively won't start if the first-opened file is not one of the default or named extensions (see [Configuration](#%EF%B8%8F-configuration)).
* On macOS and Windows, the plugin should successfully load, but the use of certain functions will result in a message in the command line: `Function unavailable for <your OS>`. The functionality currently unavailable for macOS and Windows includes:
    * Opening local files and URLs outside of Neovim
    * Following links within Neovim while `create_dirs` is enabled. If you are on macOS or Windows, you should set `create_dirs` to `false` and make sure that all directories you specify as part of a link already exist.

## ⚙️ Configuration

Currently, the setup function uses the defaults shown below. See the descriptions and non-default options in the comments above each setting. To change these settings, specify new values for them wherever you've placed the setup function.

```lua
require('mkdnflow').setup({
    -- Type: boolean. Use default mappings (see '❕Commands and default
    --     mappings').
    -- 'false' disables mappings
    default_mappings = true,        

    -- Type: boolean. Create directories (recursively) if link contains a
    --     missing directory.
    -- 'false' prevents missing directories from being created
    create_dirs = true,             

    -- Type: string. Navigate to links relative to the directory of the first-
    --     opened file.
    -- 'current' navigates links relative to currently open file
    links_relative_to = 'first',    

    -- Type: key-value pair(s). The plugin's features are enabled only when one
    -- of these filetypes is opened; otherwise, the plugin does nothing.
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
    new_file_prefix = [[os.date('%Y-%m-%d_')]]
})
```

### ❕ Commands and default mappings

These default mappings can be disabled; see [Configuration](#%EF%B8%8F-configuration). Commands with no mappings trigger functions that are called by the functions with mappings, but I've given them a command name so you can use them as independent functions if you'd like to.

| Keymap    | Mode | Command               | Description                                                                                                                                                  |
|---------- | ---- | --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `<Tab>`   | n    | `:MkdnNextLink<CR>`   | Move cursor to the beginning of the next link (if there is a next link)                                                                                      |
| `<S-Tab>` | n    | `:MkdnPrevLink<CR>`   | Move the cursor to the beginning of the previous link (if there is one)                                                                                      |
| `<BS>`    | n    | `:edit #<CR>`         | Open the last-active buffer in the current window                                                                                                            |
| `<CR>`    | n    | `:MkdnFollowPath<CR>` | Open the link under the cursor, creating missing directories if desired, or if there is no link under the cursor, make a link from the word under the cursor |
| --        | --   | `:MkdnGetPath<CR>`    | With a link under the cursor, extract (and return) just the path part of it (i.e. the part in parentheses, following the brackets)                           |
| --        | --   | `:MkdnCreateLink<CR>` | Replace the word under the cursor with a link in which the word under the cursor is the name of the link                                                     |



## ☑️ To do

* [X] Navigate between links (w/ `<Tab>` and `<S-Tab>`)
* [X] Follow links internally and externally (w/ `<CR>`)
* [X] Create links from word under cursor
* [X] File naming options for link creation
* [X] Smarter/"deeper" navigation to previous files with `<BS>`
* [ ] Easy forward navigation through buffers (with `<S-BS>`?)
* [ ] Create links from visual selection (not just word under cursor)
* [ ] "Undo" a link (replace link w/ the text part of the link)
* [ ] To-do list functions & mappings
* [ ] Add documentation
* [ ] Smart `<CR>` when in lists, etc.
* [ ] Fancy table creation & editing
    * [ ] Add/remove columns and rows
    * [ ] Navigation through table (maybe with `<Tab>` by default?)
* [ ] Full compatibility with Windows and macOS

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
