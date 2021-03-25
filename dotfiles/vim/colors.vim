" vim:set ft=vim et sw=2 ts=2 sts=2 tw=78 foldmethod=marker:

if g:jw.has.termguicolors
  set termguicolors
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

  " change cursor shape based on mode
  let &t_SI = "\<Esc>[6 q"
  let &t_SR = "\<Esc>[4 q"
  let &t_EI = "\<Esc>[2 q"
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
let s:colors = get(g:jw.opts.colors, g:jw.opts.colors.use, 'dark')

let &background = s:colors.background
silent! execute 'colorscheme ' . s:colors.scheme

if g:jw.has.iterm
  " csapprox can look silly on iterm, do not load it
  let g:CSApprox_loaded = 1
endif

if g:jw.has.conemu
  set term=pcansi
  set t_Co=256
  let &t_AB="\e[48;5;%dm"
  let &t_AF="\e[38;5;%dm"
endif
