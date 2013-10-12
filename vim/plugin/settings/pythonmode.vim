 " PythonMode {
  let g:pymode_lint_checker = "pyflakes"
  let g:pymode_utils_whitespaces = 0
  let g:pymode_options = 0
  " disable if python support not present
  if (!has('python') && !has('python3'))
    let g:pymode = 1
  endif
" }
