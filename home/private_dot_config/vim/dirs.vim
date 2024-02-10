" vim:set ft=vim et sw=2 ts=2 sts=2 tw=78 foldmethod=marker:

" set directories to those provided
if stridx(&backupdir, g:jw.dirs.backup) == -1
  let &backupdir = g:jw.dirs.backup . ',' . &backupdir " .bak files
endif

if stridx(&directory, g:jw.dirs.backup) == -1
  let &directory = g:jw.dirs.backup . ',' . &directory " .swp files
endif

if stridx(&viminfo, g:jw.dirs.viminfo) == -1
  call g:JW_MakeDir(expand(g:jw.dirs.viminfo))
  let &viminfo = &viminfo . ',n' . g:jw.dirs.viminfo . '/viminfo'
  "silent! execute 'set viminfo+=n' . g:jw.dirs.viminfo
endif

if g:jw.has.undo
  set undofile
  call g:JW_MakeDir(expand(g:jw.dirs.undo))
  let &undodir = g:jw.dirs.undo
endif

let s:dir_vim_after = expand(g:jw.dirs.vim . '/after')
if g:jw.sys.win
  " for windows, use our defined vim location instead of default vimfiles
  let s:rt_vimfiles = expand($VIM . '/vimfiles')
  let &runtimepath = g:jw.dirs.vim . ',' .
        \ s:rt_vimfiles . ',' . $VIMRUNTIME .  ',' .
        \ expand(s:rt_vimfiles . '/after') . ',' . s:dir_vim_after
else
  let &runtimepath = g:jw.dirs.vim . ',' .
        \ s:dir_vim_after . ',' . $VIM . ',' . $VIMRUNTIME
endif
