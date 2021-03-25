" vim:set ft=vim et sw=2 ts=2 sts=2 tw=78 foldmethod=marker:

" Functions {{{

" g:JW_SourceRelative {{{
function! g:JW_SourceRelative(path)
  let l:cwd = expand("%:p:h")
  exec "source " . l:cwd . "/" . a:path
endfunction
" }}}

" g:JW_InstallPlug {{{2
function! g:JW_InstallPlug(vhome)
  let autoload_dir = expand(a:vhome . '/autoload')
  let plug_file = expand(autoload_dir . '/plug.vim')

  if !filereadable(plug_file)
    let plug_uri = 'https://raw.githubusercontent.com/' .
          \ 'junegunn/vim-plug/master/plug.vim'

    if g:jw.sys.win
      call g:JW_MakeDir(autoload_dir)
      call g:JW_PowerShellCmd([
            \ "(New-Object System.Net.WebClient)" .
            \ ".DownloadFile('" . plug_uri . "', " .
            \ "$ExecutionContext.SessionState.Path" .
            \ ".GetUnresolvedProviderPathFromPSPath('" . plug_file . "'))"
            \ ])
    else
      if g:jw.has.curl
        silent execute '!curl -fLo ' . plug_file . ' --create-dirs ' . plug_uri
      else
        echoerr 'Cannot automate getting *vim-plug*, `curl` not found'
      endif
    endif

    autocmd VimEnter * PlugInstall | source $MYVIMRC
  endif
endfunction
" }}}

" g:JW_MakeDir {{{
function! g:JW_MakeDir(path)
  if !isdirectory(expand(a:path))
    silent call mkdir(expand(a:path), 'p')
  endif
endfunction
" }}}

" g:JW_PowerShellCmd {{{
function! g:JW_PowerShellCmd(cmds)
  let tmp = {
        \ 'shell': &shell,
        \ 'shellcmdflag': &shellcmdflag,
        \ 'shellpipe': &shellpipe,
        \ 'shellredir': &shellredir
        \ }

  let &shell = 'powershell.exe -ExecutionPolicy Unrestricted'
  let &shellcmdflag = '-Command'
  let &shellpipe = '>'
  let &shellredir = '>'

  for cmd in a:cmds
    silent execute '!' . cmd
  endfor

  let &shell = tmp.shell
  let &shellcmdflag = tmp.shellcmdflag
  let &shellpipe = tmp.shellpipe
  let &shellredir = tmp.shellredir
  unlet tmp
endfunction
" }}}

" g:JW_LinterStatus {{{
" function! g:JW_LinterStatus() abort
"   let l:counts = ale#statusline#Count(bufnr(''))

"   let l:all_errors = l:counts.error + l:counts.style_error
"   let l:all_non_errors = l:counts.total - l:all_errors

"   return l:counts.total == 0 ? 'OK' : printf(
"   \   '%dW %dE',
"   \   all_non_errors,
"   \   all_errors
"   \)
" endfunction
" }}}

" g:JW_HasPaste {{{
" function! g:JW_HasPaste()
"   if &paste
"     return 'PASTE MODE  '
"   endif
"   return ''
" endfunction
" }}}

" }}}
