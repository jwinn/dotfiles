" vim:set ft=vim et sw=2 ts=2 sts=2 tw=78 foldmethod=marker:

augroup filetypes
  autocmd!
  autocmd BufNewFile,BufRead *.md setlocal spell wrap
  autocmd FileType vim setlocal foldmethod=marker
augroup END
