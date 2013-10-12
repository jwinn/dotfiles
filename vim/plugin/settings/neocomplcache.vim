" neocomplcache {
  " disable AutoComplPop--comment out this line if AutoComplPop is not installed.
  let g:acp_enableAtStartup = 0
  " launches neocomplcache automatically on vim startup
  let g:neocomplcache_enable_at_startup = 1
  " use smartcase
  let g:neocomplcache_enable_smart_case = 1
  " use camel case completion
  let g:neocomplcache_enable_camel_case_completion = 1
  " use underscore completion
  let g:neocomplcache_enable_underbar_completion = 1
  " sets min char length of syntax keyword
  let g:neocomplcache_min_syntax_length = 3
  " buffer file name pattern that locks neocomplcache. e.g. ku.vim or fuzzyfinder 
  "let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'
  " enables auto-delimiter
  let g:neocomplcache_enable_auto_delimiter = 1
  " sets max length of results displayed
  let g:neocomplcache_max_list = 15
  " forces overwriting of completefunc
  let g:neocomplcache_force_overwrite_completefunc = 1
  " AutoComplPop like behavior
  "let g:neocomplcache_enable_auto_select = 1

  " SuperTab like snippets behavior
  imap <silent><expr><tab> neosnippet#expandable() ?
    \ "\<plug>(neosnippet_expand_or_jump)" : (pumvisible() ?
    \ "\<C-e>" : "\<tab>")
  smap <tab> <right><plug>(neosnippet_jump_or_expand)

  " define file-type dependent dictionaries
  let g:neocomplcache_dictionary_filetype_lists = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
    \ }

  " define keyword, for minor languages
  if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
  endif
  let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

  " key-mappings

  " These two lines conflict with the default digraph mapping of <C-k>
  " If you prefer that functionality, add
  " let g:no_neosnippet_expand = 1
  " in your .vimrc.before file
  if !exists('g:no_neosnippet_expand')
    imap <C-k> <plug>(neosnippet_expand_or_jump)
    smap <C-k> <plug>(neosnippet_expand_or_jump)
  endif

  inoremap <expr><C-g> neocomplcache#undo_completion()
  inoremap <expr><C-l> neocomplcache#complete_common_string()
  inoremap <expr><cr> neocomplcache#complete_common_string()

  " <tab>: completion
  inoremap <expr><tab> pumvisible() ? "\<C-n>" : "\<tab>"
  inoremap <expr><S-tab> pumvisible() ? "\<C-p>" : "\<tab>"

  " <cr>: close popup
  " <s-cr>: close popup and save indent
  inoremap <expr><S-cr> pumvisible() ? neocomplcache#close_popup()"\<cr>" : "\<cr>"
  inoremap <expr><cr> pumvisible() ? neocomplcache#close_popup() : "\<cr>"

  " <C-h>, <bs>: close popup and delete backword char
  inoremap <expr><bs> neocomplcache#smart_close_popup()."\<C-h>"
  inoremap <expr><C-y> neocomplcache#close_popup()

  " enable omni completion
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
  autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
  autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

  " haskell post write lint and check with ghcmod
  " $ `cabal install ghcmod` if missing and ensure
  " ~/.cabal/bin is in your $PATH
  if !executable("ghcmod")
    autocmd BufWritePost *.hs GhcModCheckAndLintAsync
  endif

  " enable heavy omni completion,
  " which requires computational power and may stall vim
  if !exists('g:neocomplcache_omni_patterns')
    let g:neocomplcache_omni_patterns = {}
  endif
  let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
  let g:neocomplcache_omni_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
  let g:neocomplcache_omni_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
  let g:neocomplcache_omni_patterns.cpp =
    \ '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
  let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\h\w*\|\h\w*::'

  " use separate snippet repo
  let g:neosnippet#snippets_directory =
    \ '~/.vim/bundle/vim-snippets/snippets'

  " enable neosnippet snipmate compatibility mode
  let g:neosnippet#enable_snipmate_compatibility = 1

  " for snippet_complete marker
  if has('conceal')
    set conceallevel=2 concealcursor=i
  endif

  " disable the neosnippet preview candidate window
  " when enabled, there can be too much visual noise
  " especially when splits are used
  set completeopt-=preview
" }
