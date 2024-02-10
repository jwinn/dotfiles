" vim:set ft=vim et sw=2 ts=2 sts=2 tw=78 foldmethod=marker:

" load defaults, if available, otherwise set nocompatible
if has("patch-7.4-2111") && file_readable($VIMRUNTIME . "/defaults.vim")
  unlet! skip_defaults_vim
  source $VIMRUNTIME/defaults.vim
else
  if &compatible
    set nocompatible
  endif
  syntax on
endif

if has("eval")
  " s:SourceRelative {{{
  let s:cwd = fnamemodify(resolve(expand('<sfile>:p')), ':h')
  function! s:SourceRelative(path)
    exec 'source ' . resolve(s:cwd . '/' . a:path)
  endfunction
  " }}}

  call s:SourceRelative('variables.vim')
  call s:SourceRelative('functions.vim')
  call s:SourceRelative('base.vim')
  call s:SourceRelative('dirs.vim')
  call s:SourceRelative('leader.vim')
  call s:SourceRelative('colorcolumn.vim')
  call s:SourceRelative('spell.vim')
  call s:SourceRelative('keymap.vim')
  call s:SourceRelative('abbreviations.vim')
  " call s:SourceRelative('statusline.vim')
  " call s:SourceRelative('plugins.vim')
  call s:SourceRelative('colors.vim')
endif
