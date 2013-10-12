" indent_guides {
  if !exists('g:no_indent_guides_autocolor')
    let g:indent_guides_auto_colors = 1
  else
    " for some colorschemes, autocolor will not work (eg: 'desert', 'ir_black')
    autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd guibg=#212121 ctermbg=3
    autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=#404040 ctermbg=4
  endif
  let g:indent_guides_start_level = 2
  let g:indent_guides_guide_size = 1
  let g:indent_guides_enable_on_vim_startup = 1
" }
