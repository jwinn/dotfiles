" vim:set ft=vim et sw=2 ts=2 sts=2 tw=78 foldmethod=marker:

if g:jw.has.256color
  " disable Background Color Erase (BCE) so that color schemes
  " render properly when inside 256-color tmux and GNU screen.
  " see also https://sunaku.github.io/vim-256color-bce.html
  set t_ut=
endif

if g:jw.has.termguicolors && has("patch-7.4-1799")
  set t_8f="\<Esc>[38;2;%lu;%lu;%lum"
  set t_8b="\<Esc>[48;2;%lu;%lu;%lum"

  " change cursor shape based on mode
  set t_SI="\<Esc>[6 q"
  set t_SR="\<Esc>[4 q"
  set t_EI="\<Esc>[2 q"

  set t_Co=256

  " set termguicolors
endif

if g:jw.has.colorcolumn
  if g:jw.has.256color
    highlight ColorColumn guibg=#444444 ctermbg=238
  else
    highlight ColorColumn ctermbg=7 ctermfg=1
  endif
endif

if g:jw.has.256color
  highlight SpellErrors guibg=#8700af ctermbg=91
else
  highlight SpellErrors ctermbg=5 ctermfg=0
endif

" used for color determinations
let &background = g:jw.opts.colorscheme.background
silent! execute 'colorscheme ' . g:jw.opts.colorscheme.scheme

if g:jw.has.iterm
  " csapprox can look silly on iterm, do not load it
  let g:CSApprox_loaded = 1
endif

if g:jw.has.conemu
  set term=pcansi
  set t_Co=256
  set t_AB="\e[48;5;%dm"
  set t_AF="\e[38;5;%dm"
endif
