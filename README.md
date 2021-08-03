# ⬇️ mkdn.nvim

Jump to: [Description](#-description) / [Requirements](#-requirements) / [Installation](#-installation) / [Features](#-features) / [Configuration](#%EF%B8%8F-configuration)/ [Commands & default mappings](#-commands-and-default-mappings) / [To do](#%EF%B8%8F-to-do)

### 📝 Description

This plugin is designed to replicate the features I use most from [Vimwiki](https://github.com/vimwiki/vimwiki), implementing them in Lua instead of VimL.

### ⚡ Requirements

* Linux
* Neovim >= 0.5.0

## 📦 Installation

### init.lua
#### [Packer](https://github.com/wbthomason/packer.nvim)
```lua
use({'jakewvincent/mkdn.nvim',
     config = function()
        require('mkdn').setup({})
     end
})
```

#### [Paq](https://github.com/savq/paq-nvim)
```
require('paq')({
        -- your other packages;
        'jakewvincent/mkdn.nvim';
        -- your other packages;
    })

-- Include the setup function somewhere else in your init.lua/vim file, or the plugin won't activate itself
require('mkdn').setup({})
```

### init.vim
```vim
" Vim-Plug
Plug 'jakewvincent/mkdn.nvim'

" NeoBundle
NeoBundle 'jakewvincent/mkdn.nvim'

" Vundle
Bundle 'jakewvincent/mkdn.nvim'

" Pathogen
git clone https://github.com/jakewvincent/mkdn.nvim.git ~/.vim/bundle/vgit.nvim

" Dein
call dein#add('jakewvincent/mkdn.nvim')
```

## ✨ Features

* Create links from the word under the cursor
* \<Tab\> and \<S-Tab\> to jump to next and previous link in the file, respectively
* Follow links relative to the first-opened file or the current file using \<CR\>
    * \<CR\>ing on a link to any kind of text file will open it (i.e. `:e <filename>`).
    * \<CR\>ing on a link to a file tagged with `local:`, e.g. [My Xournal notes](local:notes.xopp), will open that file with whatever the system's associated program is (using `xdg-open`).
    * \<CR\>ing on a link to a web URL will open that link in your default browser.
* Creates missing directories if a link goes to a file in a directory that doesn't exist.
* \<BS\> to go to last-open file (has limitations; see [to do](#-to-do))
* Enable/disable default keybindings (see [Configuration](#-configuration))

### ❗ Caveats/warnings

* The plugin effectively won't start if the first-opened file is not one of the default or named extensions (see [Configuration](#-configuration)).

## ⚙️ Configuration

Currently, the setup function uses the following defaults shown below. See the descriptions and non-default options in the comments.

```lua
require('mkdn').setup({
    -- Type: boolean. Use default mappings (see below).
    default_mappings = true,        -- 'false' disables mappings; see available commands below

    -- Type: boolean. Create directories (recursively) if link contains a missing directory.
    create_dirs = true,             -- 'false' prevents missing directories from being created

    -- Type: string. Navigate to links relative to the directory of the first-opened file.
    links_relative_to = 'first',    -- 'current' navigates links relative to currently open file

    -- Type: key-value pair(s). Enable the plugin's features only when one of these filetypes is opened
    filetypes = {md = true, rmd = true, markdown = true}
})
```

### ❕ Commands and default mappings

These default mappings can be disabled; see [Configuration](#-configuration).

| Keymap    | Mode | Command               | Description                                                                                                                                                  |
|---------- | ---- | --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| \<Tab\>   | n    | `:MkdnNextLink<CR>`   | Move cursor to the beginning of the next link (if there is a next link)                                                                                      |
| \<S-Tab\> | n    | `:MkdnPrevLink<CR>`   | Move the cursor to the beginning of the previous link (if there is one)                                                                                      |
| \<BS\>    | n    | `:edit #<CR>`         | Open the last-open file                                                                                                                                      |
| \<CR\>    | n    | `:MkdnFollowPath<CR>` | Open the link under the cursor, creating missing directories if desired, or if there is no link under the cursor, make a link from the word under the cursor |


## ☑️ To do

* [ ] Documentation
* [ ] Smart \<CR\> when in lists, etc.
* [ ] Fancy table creation & editing
* [ ] Create links from visual selection (not just word under cursor)
* [ ] Smarter/"deeper" navigation to previous files with \<BS\>
* [ ] ...
