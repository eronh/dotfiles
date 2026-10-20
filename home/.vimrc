
" n: normal only
" v: visual and select
" o: operator-pending
" x: visual only
" s: select only
" i: insert
" c: command-line
" l: insert, command-line, regexp-search (and others. Collectively called "Lang-Arg" pseudo-mode)

let mapleader = ';'

call plug#begin('~/.vim/plugged')

Plug 'editorconfig/editorconfig-vim'
Plug 'romainl/vim-cool' " https://vi.stackexchange.com/a/13378
Plug 'habamax/vim-gruvbit'
Plug 'easymotion/vim-easymotion'
Plug 'arcticicestudio/nord-vim'
Plug 'tpope/vim-surround'

call plug#end()

syntax on
filetype plugin indent on

set cul                 " Enable current line
set number              " Show line numbers
" set linebreak           " Break lines at word (requires Wrap lines)
set showbreak=+++       " Wrap-broken line prefix
" set textwidth=100       " Line wrap (number of cols)
" set nowrap              " Do not automatically wrap on load
" set formatoptions=      " Do not automatically wrap text when typing
set showmatch           " Highlight matching brace
set virtualedit=block   " Enable free-range cursor

set hlsearch            " Highlight all search results
set smartcase           " Enable smart-case search
set ignorecase          " Always case-insensitive
set incsearch           " Searches for strings incrementally

set autoindent          " Auto-indent new lines
set expandtab           " Use spaces instead of tabs
set shiftwidth=2        " Number of auto-indent spaces
set smartindent         " Enable smart-indent
set smarttab            " Enable smart-tabs
set softtabstop=2       " Number of spaces per Tab
set ruler               " Show row and column ruler information
set tabstop=2

set undolevels=1000             " Number of undo levels
set backspace=indent,eol,start  " Backspace behaviour
set clipboard=unnamedplus       " Enable system clipboard integration. See: https://stackoverflow.com/a/27928635

" recommended settings from http://vim.wikia.com/wiki/Example_vimrc
set nocompatible
set wildmenu
set nomodeline
set nostartofline
set confirm
set mouse=a

" nerdtree settings
" auto start plugin when starting vim opening a directory
" autocmd StdinReadPre * let s:std_in=1
" autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif

" search for visually selected text. see: https://vim.fandom.com/wiki/Search_for_visually_selected_text
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" delete sends text to 'black hole' instead of clipboard: https://stackoverflow.com/q/54255,
nnoremap d "_d
nnoremap x "_x
nnoremap dd "_dd
vnoremap d "_d
" vnoremap x "_x

" save current file
nnoremap <leader>w :w<CR>
inoremap <leader>w <Esc>:w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>wq :wq<CR>

" increment/decrement
nnoremap + <C-a>
nnoremap - <C-x>

" select all text
nnoremap <C-A> ggVG

" Wayland only: elsewhere (macOS) these overrode vim's own "+y/"+p with a missing tool.
if executable('wl-copy')
  xnoremap "+y y:call system("wl-copy", @")<cr>
  nnoremap "+p :let @"=substitute(system("wl-paste --no-newline"), '<C-v><C-m>', '', 'g')<cr>p
  nnoremap "*p :let @"=substitute(system("wl-paste --no-newline --primary"), '<C-v><C-m>', '', 'g')<cr>p
endif

" Get current direcory in command mode
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

" clipboard copy-paste (requires vim to be compiled with +clipboard)
xnoremap y "+y
nnoremap p "+p

" move selected lines up/down
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" keep cursor centered
nnoremap J mzJ`z
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap n nzzzv
nnoremap N Nzzzv

" paste over selection without overwriting default register
xnoremap <leader>p "_dP

" substitute word under cursor
nnoremap <leader>s :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>
vnoremap <leader>s :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>

" C-c as Esc
inoremap <C-c> <Esc>

" clear search highlighting on Esc
nnoremap <Esc> :nohlsearch<CR>

" double Esc
nnoremap <Esc> <Esc><Esc>
inoremap <Esc> <Esc><Esc>
vnoremap <Esc> <Esc><Esc>

" Previous/Next cursor positions
nnoremap <C-p> <C-o>
nnoremap <C-n> <C-i>

" preserve selection when yanking in visual mode
vnoremap y ygv<Esc>

" visual search using selected text
vnoremap // y/\V<C-R>"<CR>

" exit insert mode with 'jk'
inoremap jk <Esc>
inoremap kj <Esc>

" move down/up 3 lines and center
nnoremap <C-j> 3jzz
nnoremap <C-k> 3kzz
