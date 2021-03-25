" vim:set ft=vim et sw=2 ts=2 sts=2 tw=78 foldmethod=marker:

" compatability {{{
if &compatible
  set nocompatible
endif
" }}}

" s:SourceRelative {{{
function! s:SourceRelative(path)
  let l:cwd = expand("%:p:h")
  exec "source " . l:cwd . "/" . a:path
endfunction
" }}}

call s:SourceRelative("variables.vim")
call s:SourceRelative("functions.vim")
call s:SourceRelative("base.vim")
call s:SourceRelative("dirs.vim")
call s:SourceRelative("leader.vim")
call s:SourceRelative("colorcolumn.vim")
call s:SourceRelative("spell.vim")
call s:SourceRelative("keymap.vim")
call s:SourceRelative("abbreviations.vim")
"call s:SourceRelative("statusline.vim")
"call s:SourceRelative("plugins.vim")
call s:SourceRelative("colors.vim")
