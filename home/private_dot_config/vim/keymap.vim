" vim:set ft=vim et sw=2 ts=2 sts=2 tw=78 foldmethod=marker:

nnoremap <silent> <leader>ev :rightbelow vsplit $MYVIMRC<cr>
nnoremap <silent> <leader>sv :source $MYVIMRC<cr>
nnoremap <silent> <leader>ss :setlocal spell!<cr>

inoremap jj <Esc>

xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<cr>

nnoremap <silent> <leader><leader>ww :setlocal wrap<cr>
nnoremap <silent> <leader><leader>nw :setlocal nowrap<cr>

nnoremap <silent> <leader><leader>h :setlocal hlsearch!<cr>
nnoremap <silent> <leader><leader>n :setlocal number!<cr>

if g:jw.has.terminal || g:jw.has.nvim
  nnoremap <silent> <leader>t term<cr>
  nnoremap <silent> <leader>tv :vertical term<cr>
endif

nnoremap <leader><leader>cs :colorscheme 

" provide functions to other scripts
nnoremap <silent> <leader><leader>$ :call <SID>TrimTrailingWhitespace()<cr>
if &diff
  set cursorline
  map ] ]c
  map [ [c
  hi DiffAdd    ctermfg=233 ctermbg=LightGreen guifg=#003300 guibg=#DDFFDD gui=none cterm=none
  hi DiffChange ctermbg=white  guibg=#ececec gui=none   cterm=none
  hi DiffText   ctermfg=233  ctermbg=yellow  guifg=#000033 guibg=#DDDDFF gui=none cterm=none
endif
