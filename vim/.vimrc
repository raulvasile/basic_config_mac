call plug#begin('~/.vim/plugged')

Plug 'preservim/nerdtree'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'airblade/vim-gitgutter'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'vim-airline/vim-airline'
Plug 'morhetz/gruvbox'

call plug#end()

syntax on
set number
set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab
set clipboard=unnamedplus
colorscheme gruvbox

