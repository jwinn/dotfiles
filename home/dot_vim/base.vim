" vim:set ft=vim et sw=2 ts=2 sts=2 tw=78 foldmethod=marker:

" TODO: move to init.vim
if g:jw.has.nvim
  set t_8f=^[[38:2:%lu:%lu:%lum
  set t_8b=^[[48:2:%lu:%lu:%lum
endif

let &encoding = g:jw.opts.encoding

"set backspace=indent,eol,start

"set cursorline
set number

set ignorecase
set smartcase

"set autoindent
set expandtab
set shiftwidth=2
set tabstop=2
set softtabstop=2

"set incsearch
set hlsearch

set pastetoggle=<F2>
"set textwidth=80
set title

set fillchars=vert:\ ,fold:\  listchars=tab:⎸\ ,nbsp:⎕
set linebreak showbreak=↪\  breakindent breakindentopt=shift:-2
set formatoptions+=nj
