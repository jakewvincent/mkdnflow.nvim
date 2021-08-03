# ⬇️ mkdn.nvim

Jump to: [Description](#-description) / [Requirements](#-requirements) / [Installation](#-installation) / [Features](#-features) / [Configuration](#-configuration)

### 📝 Description

This plugin is designed to replicate a subset of the features of [Vimwiki](https://github.com/vimwiki/vimwiki), implementing them in Lua instead of VimL.

### ⚡ Requirements

* Linux
* Neovim >= 0.5.0

## 📦 Installation

### init.lua
```lua
-- Packer <https://github.com/wbthomason/packer.nvim>
use({'jakewvincent/mkdn.nvim',
     config = function()
        require('mkdn').setup({})
     end
})

-- Paq <https://github.com/savq/paq-nvim>
require('paq')({
        -- your other packages;
        'jakewvincent/mkdn.nvim';
        -- your other packages;
    })

-- For Paq, include the setup function somewhere else in your init.lua/vim file:
require('mkdn').setup({})
```

### init.vim
```vimscript
" Vim-Plug <https://github.com/junegunn/vim-plug>
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

### Notes

* The plugin effectively won't start if the first-opened file is not one of the default or named extensions (see [Configuration](#-configuration)).

## ⚙️ Configuration

## ☑️ To do

* [ ] Documentation
* [ ] Smart \<CR\> when in lists, etc.
* [ ] Fancy table creation & editing
* [ ] Create links from visual selection (not just word under cursor)
* [ ] Smarter navigation to previous files with \<BS\>
* [ ] ...
