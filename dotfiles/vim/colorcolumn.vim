" vim:set ft=vim et sw=2 ts=2 sts=2 tw=78 foldmethod=marker:

if g:jw.has.colorcolumn
  " highlight column at #
  set colorcolumn=80
  let &colorcolumn="80,".join(range(120,999),",")
  if g:jw.has.256color
    highlight ColorColumn guibg=#444444 ctermbg=238
  else
    highlight ColorColumn ctermbg=7 ctermfg=1
  endif
else
  "autocmd BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
  if g:jw.has.256color
    autocmd BufEnter * highlight OverLength guibg=#444444 ctermbg=238
  else
    autocmd BufEnter * highlight OverLength ctermbg=7 ctermfg=1
  endif
  autocmd BufEnter * match OverLength /\%80v.*/
endif
