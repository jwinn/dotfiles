" Gist {
  if has("macunix")
    let g:gist_clip_command = 'pbcopy'
  elseif has("unix")
    let g:gist_clip_command = 'xclip -selection clipboard'
  elseif has("win32") || has("win64")
    let g:Gist_clip_command = 'putclip'
  endif
  let g:gist_detect_filetype = 1 " detect filetype from name
" }
