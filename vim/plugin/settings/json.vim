" JSON {
  if has("python")
    nmap <leader>jt <esc>:%!python -m json.tool<cr>
      \ <esc>:set filetype=json<cr>
  endif
" }
