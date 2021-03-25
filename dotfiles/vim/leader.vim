" vim:set ft=vim et sw=2 ts=2 sts=2 tw=78 foldmethod=marker:

" if g:jw.opts.leader is a space, map <Space> to <leader>
" otherwise, change mapleader <leader> to g:jw.opts.leader,
" but retain default for local buffers
"
" setting here causes this to be set for any <leader> references later
" in the initialization sequence
if g:jw.opts.leader ==? '\<space>' || g:jw.opts.leader == ' '
  map <Space> <leader>
  map <Space><Space> <leader><leader>
else
  let &maplocalleader = &mapleader
  let mapleader = g:jw.opts.leader
endif
