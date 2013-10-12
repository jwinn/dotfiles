 " NerdTree {
  map <C-e> :NERDTreeToggle<cr>:NERDTreeMirror<cr>
  map <leader>e :NERDTreeFind<cr>
  nmap <leader>nt :NERDTreeFind<cr>

  let NERDTreeShowBookmarks = 1
  let NERDTreeIgnore =
    \ ['\.pyc', '\~$', '\.swo$', '\.swp$', '\.git', '\.hg', '\.svn', '\.bzr']
  let NERDTreeChDirMode = 0
  let NERDTreeQuitOnOpen = 1
  let NERDTreeMouseMode = 2
  let NERDTreeShowHidden = 1
  let NERDTreeKeepTreeInNewTab = 1
  let NERDTreeWinSize = 31
  let g:nerdtree_tabs_open_on_gui_startup = 0
" }
