" vim:set ft=vim et sw=2 ts=2 sts=2 tw=78 foldmethod=marker:

" vim-plug {{{
" make sure plugin dir exists
call JW_MakeDir(g:jw.dirs.plugin)

call JW_InstallPlug(g:jw.dirs.vim)
call plug#begin(g:jw.dirs.plugin)

" start with sensible defaults
" see: https://github.com/tpope/vim-sensible
Plug 'tpope/vim-sensible'

" install more plugins if minimal is falsy {{{
if ! g:jw.opts.minimal
  " ack file searcher
  if g:jw.has.ack
    Plug 'mileszs/ack.vim'
    if g:jw.has.ag
      let g:ackprg = 'ag --vimgrep'
    endif
  endif

  " ripgrep file searcher
  if g:jw.has.rg
    Plug 'jremmen/vim-ripgrep'
  endif

  " allow plugins to repeat
  Plug 'tpope/vim-repeat'

  " sensible? key bindings
  Plug 'tpope/vim-unimpaired'

  " fancy vim start screen
  Plug 'mhinz/vim-startify'

  " helpful motion keys (<leader><leader> to trigger)
  Plug 'easymotion/vim-easymotion'

  " allow % to match more than chars
  Plug 'adelarsq/vim-matchit'

  " work with variants of words
  Plug 'tpope/vim-abolish'

  " surround a block of text
  Plug 'tpope/vim-surround'

  " comment support
  Plug 'tpope/vim-commentary'

  " arbitrary alignment by symbol
  Plug 'junegunn/vim-easy-align'

  " demarcate indentation
  Plug 'nathanaelkane/vim-indent-guides'
  let g:indent_guides_enable_on_vim_startup = 1

  " tags for source code files
  if g:jw.has.ctags
    Plug 'vim-scripts/taglist.vim'
    set tags+=./tags
    map <silent> <leader>c :TlistToggle<cr>
    map <silent> <leader>r :!ctags -R --exclude=.git --exclude=logs --exclude=doc .<cr>
  endif

  " editorconfig {{{
  if (g:jw.has.python || g:jw.has.python3) && g:jw.has.editorconfig
    " only supports python 2?
    Plug 'editorconfig/editorconfig-vim'
    " ensure plugin works with fugitive
    let g:EditorConfig_exclude_patterns = ['fugitive://.*']
    " do not load remote files over ssh
    "let g:EditorConfig_exclude_patterns = ['scp://.*']
    "let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']
    "let g:EditorConfig_disable_rules = ['trim_trailing_whitespace']
    "let g:EditorConfig_exec_path = ''
    silent let g:EditorConfig_exec_path = system('command -v editorconfig')
    let g:EditorConfig_exec_path = substitute(g:EditorConfig_exec_path, "\n", "", "")
  else
    Plug 'sgur/vim-editorconfig'
    "let g:editorconfig_verbose = 1
    "let g:editorconfig_local_vimrc = 1
    let g:editorconfig_blacklist = {
          \ 'filetype': ['git.*', 'fugitive'],
          \ 'pattern': ['\.un~$']}
  endif
  " }}}

  " Colors {{{
  Plug 'chriskempson/base16-vim'
  if g:jw.has.256color
    let base16colorspace = 256
  endif
  Plug 'nanotech/jellybeans.vim'
  Plug 'morhetz/gruvbox'
  Plug 'lifepillar/vim-gruvbox8'
  Plug 'w0ng/vim-hybrid'
  Plug 'nordtheme/vim'
  Plug 'rakr/vim-one'
  if g:jw.has.italics
    let g:one_allow_italics = 1
  endif
  Plug 'NLKNguyen/papercolor-theme'

  " inline colors
  Plug 'chrisbra/Colorizer'
  " }}}

  " File Browser {{{
  " enhance netrw
  Plug 'tpope/vim-vinegar'
  let g:netrw_altv=1
  " let g:netrw_banner=0
  let g:netrw_browse_split=4
  let g:netrw_liststyle=3
  let g:netrw_sort_by='time'
  let g:netrw_sort_direction='reverse'
  let g:netrw_winsize=24
  nnoremap <silent> <leader>x :Lexplore<cr>
  nnoremap <silent> <leader>sx :Sexplore<cr>

  if g:jw.has.ranger
    Plug 'rafaqz/ranger.vim'
    map <silent> <leader>rr :RangerEdit<cr>
    map <silent> <leader>rv :RangerVSplit<cr>
    map <silent> <leader>rs :RangerSplit<cr>
    map <silent> <leader>rt :RangerTab<cr>
    map <silent> <leader>ri :RangerInsert<cr>
    map <silent> <leader>ra :RangerAppend<cr>
    map <silent> <leader>rc :set operatorfunc=RangerChangeOperator<cr>g@
  endif
  " }}}

  " fzy file finder {{{
  if g:jw.has.fzy
    function! FzyCommand(choice_command, vim_command)
      try
        let output = system(a:choice_command . " | fzy ")
      catch /Vim:Interrupt/
        " Swallow errors from ^C, allow redraw! below
      endtry
      redraw!
      if v:shell_error == 0 && !empty(output)
        exec a:vim_command . " " . output
      endif
    endfunction

    if g:jw.has.fd
      let fzy_cmd = "fd . --type file --follow --hidden --exclude .git"
    elseif g:jw.has.ag
      let fzy_cmd = "ag . --silent -l -g ''"
    else
      let fzy_cmd = "find . -type f"
    end

    nnoremap <leader>e :call FzyCommand(fzy_cmd, ":e")<cr>
    nnoremap <leader>v :call FzyCommand(fzy_cmd, ":vs")<cr>
    nnoremap <leader>s :call FzyCommand(fzy_cmd, ":sp")<cr>
  endif
  " }}}

  " fuzzy file finder {{{
"  if g:jw.has.python3
"    if ! g:jw.has.fzf
"      " TODO: attempt to find the fzf home
"      Plug 'junegunn/fzf', {
"            \ 'dir': g:jw.fzf_dir,
"            \ 'do': './install --all'
"            \ }
"    endif
"
"    if isdirectory('/usr/local/opt/fzf')
"      let g:jw.fzf_dir = '/usr/local/opt/fzf'
"    else
"      let g:jw.fzf_dir = expand($XDG_CONFIG_HOME . '/.fzf')
"    endif
"
"    Plug g:jw.fzf_dir | Plug 'junegunn/fzf.vim'
"    nmap <C-p> :GFiles<cr>
"    nmap <silent> <leader>p :Files<cr>
"    nmap <silent> <leader>pa :Ag
"    nmap <silent> <leader>pb :Buffers<cr>
"    nmap <silent> <leader>pg :GFiles<cr>
"    nmap <silent> <leader>pr :Rg
"    nmap <silent> <leader>pt :Tags<cr>
"  else
    Plug 'ctrlpvim/ctrlp.vim'
    " use .gitignore
    let g:ctrlp_user_command = [
          \ '.git',
          \ 'cd %s && git ls-files -co --exclude-standard'
          \ ]
"  endif
  " }}}

  " Rainbow {{{
  Plug 'luochen1990/rainbow'
  let g:rainbow_active = 1 " 0 if you want to enable it later via :RainbowToggle
  let g:rainbow_conf = {
        \ 'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
        \ 'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
        \ 'operators': '_,_',
        \ 'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
        \ 'separately': {
        \   '*': {},
        \   'tex': {
        \     'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
        \   },
        \   'lisp': {
        \     'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],
        \   },
        \   'vim': {
        \     'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold', 'start=/(/ end=/)/ containedin=vimFuncBody', 'start=/\[/ end=/\]/ containedin=vimFuncBody', 'start=/{/ end=/}/ fold containedin=vimFuncBody'],
        \   },
        \   'html': {
        \     'parentheses': ['start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
        \   },
        \   'css': 0,
        \ }
        \ }
  " }}}

  " Linting {{{
  if g:jw.has.job && g:jw.has.timers
    Plug 'w0rp/ale'
    "let g:ale_linters = {
    "      \ 'javascript': ['eslint'],
    "      \}
    let g:ale_fixers = {
          \   '*': ['remove_trailing_lines', 'trim_whitespace'],
          \   'javascript': ['prettier', 'prettier-eslint', 'eslint'],
          \}
    " let g:ale_lint_on_text_changed = 'never'
    " let g:ale_lint_on_enter = 0
    " let g:ale_fix_on_save = 1
    let g:ale_sign_column_always = 1
    let g:ale_sign_error = '⚑'
    let g:ale_sign_warning = '⚐'
    nmap <silent> <leader>ld <Plug>(ale_detail)
    nmap <silent> <leader>lf <Plug>(ale_fix)
    nmap <silent> <leader>lg <Plug>(ale_go_to_definition)
    nmap <silent> <leader>ll <Plug>(ale_lint)
    nmap <silent> <leader>ln <Plug>(ale_next_wrap)
    nmap <silent> <leader>lo <Plug>(ale_open_list)
    nmap <silent> <leader>lp <Plug>(ale_previous_wrap)
    nmap <silent> <leader>lr <Plug>(ale_find_references)
    nmap <silent> <leader>lt <Plug>(ale_toggle)
  else
    Plug 'vim-syntastic/syntastic'
    let g:syntastic_javascript_checkers = ['standard', 'eslint', 'flow']
    let g:syntastic_javascript_standard_exec = 'semistandard'
    autocmd bufwritepost *.js silent !semistandard % --format
    set autoread
  endif

  if g:jw.has.npm
    " post install (npm install) then load plugin only for editing supported files
    Plug 'prettier/vim-prettier', {
          \ 'do': 'npm install',
          \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue'] }
    if g:jw.has.job
      let g:prettier#exec_cmd_async = 1  
    endif
    nmap <silent> <leader>fd <Plug>(Prettier)
  endif
  " }}}

  " Completion {{{
"  if g:jw.has.timers && g:jw.has.python3
"    if g:jw.has.nvim
"      Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
"    else
"      Plug 'Shougo/deoplete.nvim'
"      Plug 'roxma/nvim-yarp'
"      Plug 'roxma/vim-hug-neovim-rpc'
"    endif
"    let g:deoplete#enable_at_startup = 1
"    " inoremap <expr><Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
"    " inoremap <expr><S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
"    autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
"  else
"    " YouCompleteMe {{{
"    if g:jw.has.python || g:jw.has.python3
"      " handled by YCM below
"      Plug 'ervandew/supertab'
"
"      let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
"      let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
"      let g:SuperTabDefaultCompletionType = '<C-n>'
"
"      let g:jw.ycm = {
"            \ 'ft': ['eelixer', 'elixer',
"            \        'javascript', 'javascript.jsx', 'typescript'],
"            \ 'opts': []
"            \}
"      if g:jw.has.dotnet || g:jw.has.xbuild
"        call add(g:jw.ycm.ft, 'cs')
"        call add(g:jw.ycm.opts, '--omnisharp-completer')
"      endif
"      if g:jw.has.go
"        call add(g:jw.ycm.ft, 'go')
"        call add(g:jw.ycm.opts, '--gocode-completer')
"      endif
"      if g:jw.has.node && g:jw.has.npm
"        call add(g:jw.ycm.opts, '--tern-completer')
"      endif
"      if g:jw.has.ruby
"        call add(g:jw.ycm.ft, 'ruby')
"      endif
"      if g:jw.has.cargo || g:jw.has.rustc
"        call add(g:jw.ycm.ft, 'rustc')
"        call add(g:jw.ycm.opts, '--racer-completer')
"      endif
"
"      function! BuildYCM(info)
"        " info is a dictionary with 3 fields
"        " - name:   name of the plugin
"        " - status: 'installed', 'updated', or 'unchanged'
"        " - force:  set on PlugInstall! or PlugUpdate!
"        if a:info.status == 'installed' || a:info.force
"          execute './install.py ' . join(g:jw.ycm.opts, ' ')
"        endif
"      endfunction
"
"      Plug 'Valloric/YouCompleteMe',
"            \ { 'for': g:jw.ycm.ft, 'do': function('BuildYCM') }
"      autocmd! User YouCompleteMe call youcompleteme#Enable()
"    endif
"    " }}}
"  endif
  " }}}

  " Gist creation
  Plug 'mattn/gist-vim'
  let g:gist_clip_command = 'xclip -selection clipboard'

  " async builds
  Plug 'tpope/vim-dispatch'

  " auto add ending for programatic control structures
  Plug 'tpope/vim-endwise'
  let g:endwise_no_mappings = 1

  " git wrapper
  Plug 'tpope/vim-fugitive'

  " git (other scc) status per line
  "Plug 'airblade/vim-gitgutter'
  Plug 'mhinz/vim-signify'

  " Single package for languages
  Plug 'sheerun/vim-polyglot'
  let g:vim_markdown_conceal = 0

  " HTML
  Plug 'mattn/emmet-vim'

  " JavaScript {{{
  "Plug 'pangloss/vim-javascript', { 'for': ['javascript','javascript.jsx'] }
  if g:jw.has.node && g:jw.has.npm
    Plug 'ternjs/tern_for_vim', { 'do': 'npm install' }
  endif

  if g:jw.has.timers
    Plug 'ruanyl/coverage.vim'
    let g:coverage_json_report_path = 'coverage/coverage-final.json'
    " let g:coverage_sign_covered = '⦿'
    " let g:coverage_interval = 5000
    " let g:coverage_show_covered = 1
    " let g:coverage_show_uncovered = 0
  endif

  " insert JSDoc pieces
  Plug 'heavenshell/vim-jsdoc', { 'for': ['javascript','javascript.jsx'] }
  " turn on detecting underscore starting functions as private convention
  let g:jsdoc_underscore_private = 1
  let g:jsdoc_enable_es6 = 1 " allow ES6 shorthand syntax
  " since v0.3 there is no longer a default mapping
  nmap <silent> <leader>jd <Plug>(jsdoc)

  "Plug 'elzr/vim-json', { 'for': ['javascript','javascript.jsx', 'json'] }

  "Plug 'mxw/vim-jsx', { 'for': ['javascript','javascript.jsx'] }
  "let g:jsx_ext_required = 0
  " }}}

  " nix {{{
  " syntax for nix files
  Plug 'LnL7/vim-nix'
  " }}}

  " PHP {{{
  if g:jw.has.job && g:jw.has.timers
    Plug 'lvht/phpcd.vim', { 'for': 'php', 'do': 'composer install' }
    let g:PHP_outdentphpescape = 0
    if exists('*g:deoplete#enable')
      let g:deoplete#ignore_sources = get(g:, 'deoplete#ignore_sources', {})
      let g:deoplete#ignore_sources.php = ['omni']
    endif
  endif
  " }}}

  " statusline {{{
  Plug 'vim-airline/vim-airline'
  if g:jw.has.job && g:jw.has.timers
    let g:airline#extensions#ale#enabled = 1
  endif
  let g:airline#extensions#tabline#enabled = 1
  Plug 'vim-airline/vim-airline-themes'
  let g:airline_theme = g:jw.opts.colorscheme.statusline
  nnoremap <leader><leader>as :AirlineTheme 
  Plug 'edkolev/promptline.vim'
  nnoremap <leader><leader>ap :PromptlineSnapshot ~/.promptline.sh airline<cr>
  Plug 'edkolev/tmuxline.vim'
  " }}}

  " tmux {{{
  " syntax for tmux.conf
  Plug 'tmux-plugins/vim-tmux'
  " }}}

  " TypeScript
  "Plug 'leafgarland/typescript-vim'
  if g:jw.has.tsserver
    Plug 'Quramy/tsuquyomi'
  endif

  " Web API
  if g:jw.has.curl
    Plug 'mattn/webapi-vim'
  endif
endif
" }}}

" end installing plugins
call plug#end()
" }}}
