" vim:set ft=vim et sw=2 ts=2 sts=2 tw=78 foldmethod=marker:

always show
set laststatus=2
set statusline=\ %{g:JW_HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ %{FugitiveStatusline()}\ \ Line:\ %l\ \ Column:\ %c\ \ %{g:JW_LinterStatus()}
