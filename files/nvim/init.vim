let g:ale_disable_lsp = 1

call plug#begin(stdpath('data') . '/plugged')
source ~/.config/nvim/plugins/floaterm.vim
source ~/.config/nvim/plugins/ale.vim
source ~/.config/nvim/plugins/blamer.vim
source ~/.config/nvim/plugins/coc.vim
source ~/.config/nvim/plugins/nerdcommenter.vim
source ~/.config/nvim/plugins/nerdtree.vim
source ~/.config/nvim/plugins/sonokai.vim
source ~/.config/nvim/plugins/vim-devicons.vim
source ~/.config/nvim/plugins/salt-vim.vim
source ~/.config/nvim/plugins/vim-gitgutter.vim
source ~/.config/nvim/plugins/vim-polyglot.vim
source ~/.config/nvim/plugins/vim-surround.vim
source ~/.config/nvim/plugins/fzf.vim
source ~/.config/nvim/plugins/smoothie.vim
call plug#end()
doautocmd User PlugLoaded

let mapleader = ","
let maplocalleader = "\\"
set nocompatible            " disable compatibility to old-time vi
set showmatch               " show matching
set ignorecase              " case insensitive
set mouse=v                 " middle-click paste with
set hlsearch                " highlight search
set incsearch               " incremental search
set tabstop=4               " number of columns occupied by a tab
set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
set expandtab               " converts tabs to white space
set shiftwidth=4            " width for autoindents
set autoindent              " indent a new line the same amount as the line just typed
set number                  " add line numbers
set wildmode=longest,list   " get bash-like tab completions
set cc=90                  " set an 80 column border for good coding style
filetype plugin indent on   "allow auto-indenting depending on file type
syntax on                   " syntax highlighting
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
filetype plugin on
set cursorline              " highlight current cursorline
set ttyfast                 " Speed up scrolling in Vim
set noswapfile            " disable creating swap file
set list
set listchars=tab:➜\ ,trail:-
set background = "dark"
colorscheme sonokai
set guifont = "Meslo Nerd Font"

" Vim Settings
nmap <leader>ve :edit ~/.config/nvim/init.vim<CR>
nmap <leader>vc :edit ~/.config/nvim/coc-settings.json<CR>
nmap <leader>vr :source ~/.config/nvim/init.vim<CR>


" editorconfig
" projectionist
" jessearcher for vim file examples

" vimspector
" vimmaximizer


" NERD Tree that can't live in source file
map <leader>p :NERDTreeToggle<CR>

" Clear search highlighting when done searching
:command C let @/=""
