" AutoCloseTag {
  " make it so AutoCloseTag works for xml and xhtml files as well
  autocmd FileType xhtml,xml runtime ftplugin/html/autoclosetag.vim
  nmap <leader>ac <plug>ToggleAutoCloseMappings
" }
