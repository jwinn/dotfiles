" vim-autoformat {
  "noremap <C-S-b> :Autoformat<CR><CR>
  "let g:formatprg_args_expr_javascript =
  "  \ '"--stdin --jslint-happy --indent-size=".&shiftwidth'
  if has("autocmd")
    autocmd FileType javascript noremap
      \ <buffer> <C-S-b> :call JsBeautify()<CR>
    autocmd FileType html noremap
      \ <buffer> <C-S-b> :call HtmlBeautify()<CR>
    autocmd FileType css noremap
      \ <buffer> <C-S-b> :call CSSBeautify()<CR>
  endif
" }
