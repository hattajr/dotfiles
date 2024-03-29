" auto-install vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  "autocmd VimEnter * PlugInstall
  "autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/autoload/plugged')


    " Theme
    Plug 'projekt0n/github-nvim-theme', { 'tag': 'v0.0.7' }
    " Better Syntax Support
    Plug 'sheerun/vim-polyglot'
    " Copilot
    Plug 'github/copilot.vim'
    "File Explorer
    Plug 'scrooloose/NERDTree'
    " Auto pairs for '(' '[' '{'
    Plug 'jiangmiao/auto-pairs'
    " Status bar
    Plug 'itchyny/lightline.vim'
    " Comment
    Plug 'tpope/vim-commentary'

call plug#end()
