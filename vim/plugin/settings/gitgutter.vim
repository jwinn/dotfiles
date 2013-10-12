" Git Gutter {
  " enabled by default (0 to disable)
  let g:gitgutter_enabled = 1
  " args for git diff (-w = ignore whitespace)
  let g:gitgutter_diff_args = '-w'
  " turn on highlighting by default
  let g:gitgutter_highlight_lines = 1
  " stop running on BufEnter
  let g:gitgutter_on_bufenter = 0
  " stop running for all buffers on FocusGained
  let g:gitgutter_all_on_focusgained = 0

  nnoremap <silent> <leader>ggt :GitGutterToggle<CR>
  nnoremap <silent> <leader>ggh :GitGutterLineHighlightsToggle<cr>
" }
