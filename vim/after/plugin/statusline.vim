if has("statusline")
  " configure the status line

  " statusline setup
  set statusline =%#identifier#
  set statusline+=[%t] "tail of the filename
  set statusline+=%*

  " display a warning if fileformat isnt unix
  set statusline+=%#warningmsg#
  set statusline+=%{&ff!='unix'?'['.&ff.']':''}
  set statusline+=%*

  " display a warning if file encoding isnt utf-8
  set statusline+=%#warningmsg#
  set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}
  set statusline+=%*

  set statusline+=%h "help file flag
  set statusline+=%y "filetype

  " read only flag
  set statusline+=%#identifier#
  set statusline+=%r
  set statusline+=%*

  " modified flag
  set statusline+=%#identifier#
  set statusline+=%m
  set statusline+=%*

  if exists("*fugitive#statusline")
    set statusline+=%{fugitive#statusline()}
  endif

  if exists("*StatuslineTabWarning")
    " display a warning if &et is wrong, or we have mixed-indenting
    set statusline+=%#error#
    set statusline+=%{StatuslineTabWarning()}
    set statusline+=%*
  endif

  if exists("*StatuslineTrailingSpaceWarning")
    set statusline+=%{StatuslineTrailingSpaceWarning()}
  endif

  if exists("*StatuslineLongLineWarning")
    set statusline+=%{StatuslineLongLineWarning()}
  endif

  if exists("*SyntasticStatuslineFlag")
    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*
  endif

  " display a warning if &paste is set
  set statusline+=%#error#
  set statusline+=%{&paste?'[paste]':''}
  set statusline+=%*

  set statusline+=%= "left/right separator
  if exists("*StatuslineCurrentHighlight")
    set statusline+=%{StatuslineCurrentHighlight()}\ \ "current highlight
  endif
  set statusline+=%c, "cursor column
  set statusline+=%l/%L "cursor line/total lines
  set statusline+=\ %P "percent through file

  "
  " overwrite the above until this can be changed to a more succinct version
  "
  set statusline=%<%f\                       " Filename
  set statusline+=%w%h%m%r                   " Options
  if exists("*fugitive#statusline")
    set statusline+=%{fugitive#statusline()} " Git Hotness
  endif
  set statusline+=\ [%{&ff}/%Y]              " Filetype
  set statusline+=\ [%{getcwd()}]            " Current dir
  set statusline+=%=%-14.(%l,%c%V%)\ %p%%    " Right aligned file nav info
endif
