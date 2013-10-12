 " OmniComplete {
  if has("autocmd") && exists("+omnifunc")
    autocmd FileType *
      \ if &omnifunc == "" |
      \ setlocal omnifunc=syntaxcomplete#Complete |
      \ endif
  endif

  hi Pmenu guifg=#000000 guibg=#F8F8F8 ctermfg=black ctermbg=Lightgray
  hi PmenuSbar guifg=#8A95A7 guibg=#F8F8F8 gui=NONE ctermfg=darkcyan ctermbg=lightgray cterm=NONE
  hi PmenuThumb guifg=#F8F8F8 guibg=#8A95A7 gui=NONE ctermfg=lightgray ctermbg=darkcyan cterm=NONE

  " some convenient mappings
  inoremap <expr> <esc> pumvisible() ? "\<C-e>" : "\<esc>"
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<cr>"
  inoremap <expr> <down> pumvisible() ? "\<C-n>" : "\<down>"
  inoremap <expr> <up> pumvisible() ? "\<C-p>" : "\<up>"
  inoremap <expr> <C-d> pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<C-d>"
  inoremap <expr> <C-u> pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<C-u>"

  " automatically open and close the popup menu / preview window
  autocmd CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
  set completeopt=menu,preview,longest
" }
