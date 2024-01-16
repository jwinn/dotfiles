" vim:set ft=vim et sw=2 ts=2 sts=2 tw=78 foldmethod=marker:

if g:jw.has.spell
  call g:JW_MakeDir(expand(g:jw.dirs.vim . '/spells'))
  "let &spellfile = expand(g:jw.dirs.vim . '/spell/custom.en.utf-8.add')

  if g:jw.has.256color
    highlight SpellErrors guibg=#8700af ctermbg=91
  else
    highlight SpellErrors ctermbg=5 ctermfg=0
  endif
endif
