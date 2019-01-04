" vim:set ft=vim et sw=2 ts=2 sts=2 tw=78 foldmethod=marker:

" compatability {{{
if &compatible
  set nocompatible
endif
" }}}

" g:jw {{{
" alot of these var declarations may be redundant,
" and are here for normalizing purposes

let g:jw = {}

" g:jw.sys {{{

let g:jw.sys = {
      \ 'darwin': 0,
      \ 'linux': 0,
      \ 'unix': has('unix'),
      \ 'win16': has('win16'),
      \ 'win32': has('win32'),
      \ 'win64': has('win64'),
      \ }

if executable('uname')
  " store current ignorecase and set to on (will be reset later)
  let s:tmp_ignorecase = &ignorecase
  let &ignorecase = 1
  let s:system_uname = system('uname -s')

  let g:jw.sys.darwin = (s:system_uname =~ 'darwin')
  let g:jw.sys.linux = g:jw.sys.unix && (s:system_uname =~ 'linux')

  " reset changes and clean up
  let &ignorecase = s:tmp_ignorecase
  unlet s:tmp_ignorecase
endif

let g:jw.sys.mac = g:jw.sys.darwin || has('macunix')
let g:jw.sys.win = g:jw.sys.win64 || g:jw.sys.win32 || g:jw.sys.win16
" }}}

" g:jw.has {{{
let g:jw.has = {
      \ 'ack': executable('ack'),
      \ 'ackgrep': executable('ackgrep'),
      \ 'ag': executable('ag'),
      \ 'cargo': executable('cargo'),
      \ 'colorcolumn': exists('&colorcolumn'),
      \ 'conceal': has('conceal'),
      \ 'conemu': !empty($CONEMUBUILD),
      \ 'curl': executable('curl'),
      \ 'ctags': executable('ctags'),
      \ 'dash': g:jw.sys.darwin && isdirectory('/Applications/Dash.app'),
      \ 'dotnet': executable('dotnet'),
      \ 'editorconfig': executable('editorconfig'),
      \ 'elm': executable('elm'),
      \ 'fzf': executable('fzf'),
      \ 'go': executable('go'),
      \ 'gui': has('gui_running'),
      \ 'iterm': !empty($ITERM_PROFILE),
      \ 'job': has('job'),
      \ 'lessc': executable('lessc'),
      \ 'lua': has('lua'),
      \ 'macvim': has('macvim'),
      \ 'make': executable('make'),
      \ 'node': executable('node'),
      \ 'npm': executable('npm'),
      \ 'nvim': has('nvim'),
      \ 'packages': has('packages'),
      \ 'pip': executable('pip'),
      \ 'pip3': executable('pip3'),
      \ 'python': has('python'),
      \ 'python3': has('python3'),
      \ 'pythonx': has('pythonx'),
      \ 'ranger': executable('ranger'),
      \ 'rg': executable('rg'),
      \ 'ruby': has('ruby'),
      \ 'rustc': executable('rustc'),
      \ 'spell': has('spell'),
      \ 'termguicolors': has('termguicolors'),
      \ 'terminal': has('terminal'),
      \ 'timers': has('timers'),
      \ 'tmux': executable('tmux'),
      \ 'tsserver': executable('tsserver'),
      \ 'undo': has('persistent_undo'),
      \ 'virtualedit': has('virtualedit'),
      \ 'xbuild': executable('xbuild'),
      \ }

let g:jw.has.256color = g:jw.has.gui || (&term =~ '256color')
" }}}

" g:jw.xdg {{{
" try to use XDG folder structure where possible or use defaults
" TODO: there's a potential problem with windows env here

let g:jw.xdg = {
      \ 'cache_home': exists('$XDG_CACHE_HOME')
      \   ? $XDG_CACHE_HOME : expand('$HOME/.cache'),
      \ 'config_home': exists('$XDG_CONFIG_HOME')
      \   ? $XDG_CONFIG_HOME : expand('$HOME/.config'),
      \ 'data_home': exists('$XDG_DATA_HOME')
      \   ? $XDG_DATA_HOME : expand('$HOME/.local/share'),
      \ }
" }}}

" g:jw.opts {{{
let g:jw.opts = {
      \ 'colors': {
      \   'dark': {
      \     'background': 'dark',
      \     'scheme': 'base16-default-dark',
      \     'statusline': 'base16_default',
      \   },
      \   'light': {
      \     'background': 'light',
      \     'scheme': 'base16-default-light',
      \     'statusline': 'base16_default',
      \   },
      \   'use': 'dark',
      \ },
      \ 'encoding': 'utf-8',
      \ 'font_dir': expand('$HOME/.fonts'),
      \ 'leader': '\<Space>',
      \ 'minimal': 0,
      \ 'path': fnamemodify(resolve(expand('<sfile>:p')), ':h'),
      \ }
" }}}

" g:jw.dirs {{{
let g:jw.dirs = {}

if g:jw.has.nvim
  let g:jw.dirs.cache = expand(g:jw.xdg.cache_home . '/nvim')
  let g:jw.dirs.vim = expand(g:jw.xdg.config_home . '/nvim')
else
  let g:jw.dirs.cache = expand(g:jw.xdg.cache_home . '/vim')
  let g:jw.dirs.vim = expand(g:jw.xdg.config_home . '/vim')
endif

if g:jw.sys.darwin
  let g:jw.dirs.font = expand('$HOME/Library/Fonts')
else
  let g:jw.dirs.font = expand('$HOME/.fonts')
endif

let g:jw.dirs.backup = expand(g:jw.dirs.cache . '/backup')
let g:jw.dirs.plugin = expand(g:jw.dirs.vim . '/plugged')
let g:jw.dirs.undo = expand(g:jw.dirs.cache . '/undo')
let g:jw.dirs.viminfo = expand(g:jw.dirs.cache)
" }}}

" used for color determinations
let s:colors = get(g:jw.opts.colors, g:jw.opts.colors.use, 'dark')
" }}}

" Functions {{{

" s:InstallPlug {{{
function! s:InstallPlug(vhome)
  let autoload_dir = expand(a:vhome . '/autoload')
  let plug_file = expand(autoload_dir . '/plug.vim')

  if !filereadable(plug_file)
    let plug_uri = 'https://raw.githubusercontent.com/' .
          \ 'junegunn/vim-plug/master/plug.vim'

    if g:jw.sys.win
      call s:MakeDir(autoload_dir)
      call s:PowerShellCmd([
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

" s:MakeDir {{{
function! s:MakeDir(path)
  if !isdirectory(expand(a:path))
    silent call mkdir(expand(a:path), 'p')
  endif
endfunction
" }}}

" s:PowerShellCmd {{{
function! s:PowerShellCmd(cmds)
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

" }}}

" Leader {{{
" if g:jw.opts.leader is a space, map <Space> to <leader>
" otherwise, change mapleader <leader> to g:jw.opts.leader,
" but retain default for local buffers
"
" setting here causes this to be set for any <leader> references later
" in the initialization sequence
if g:jw.opts.leader ==? '\<space>' || g:jw.opts.leader == ' '
  map <Space> <leader>
  map <Space><Space> <leader><leader>
else
  let &maplocalleader = &mapleader
  let mapleader = g:jw.opts.leader
endif
" }}}

" set directories to those provided {{{
if stridx(&backupdir, g:jw.dirs.backup) == -1
  let &backupdir = g:jw.dirs.backup . ',' . &backupdir " .bak files
endif
if stridx(&directory, g:jw.dirs.backup) == -1
  let &directory = g:jw.dirs.backup . ',' . &directory " .swp files
endif
if stridx(&viminfo, g:jw.dirs.viminfo) == -1
  call s:MakeDir(expand(g:jw.dirs.viminfo))
  let &viminfo = &viminfo . ',n' . g:jw.dirs.viminfo . '/viminfo'
  "silent! execute 'set viminfo+=n' . g:jw.dirs.viminfo
endif
if g:jw.has.undo
  set undofile
  call s:MakeDir(expand(g:jw.dirs.undo))
  let &undodir = g:jw.dirs.undo
endif

let s:dir_vim_after = expand(g:jw.dirs.vim . '/after')
if g:jw.sys.win
  " for windows, use our defined vim location instead of default vimfiles
  let s:rt_vimfiles = expand($VIM . '/vimfiles')
  let &runtimepath = g:jw.dirs.vim . ',' .
        \ s:rt_vimfiles . ',' . $VIMRUNTIME .  ',' .
        \ expand(s:rt_vimfiles . '/after') . ',' . s:dir_vim_after
else
  let &runtimepath = g:jw.dirs.vim . ',' .
        \ s:dir_vim_after . ',' . $VIM . ',' . $VIMRUNTIME
endif
" }}}

" basic settings {{{
if g:jw.has.nvim
  set t_8f=^[[38:2:%lu:%lu:%lum
  set t_8b=^[[48:2:%lu:%lu:%lum
endif

let &encoding = g:jw.opts.encoding

"set cursorline
set number
set ignorecase smartcase
set expandtab shiftwidth=2 tabstop=2 softtabstop=2
set incsearch hlsearch

set pastetoggle=<F12>
"set textwidth=80
set title

set fillchars=vert:\ ,fold:\  listchars=tab:⎸\ ,nbsp:⎕
set linebreak showbreak=↪\  breakindent breakindentopt=shift:-2
set formatoptions+=nj
" }}}

" colorcolumn config {{{
if g:jw.has.colorcolumn
  " highlight column at #
  set colorcolumn=80
  let &colorcolumn="80,".join(range(120,999),",")
  if g:jw.has.256color
    highlight ColorColumn guibg=#444444 ctermbg=238
  else
    highlight ColorColumn ctermbg=7 ctermfg=1
  endif
else
  "autocmd BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
  if g:jw.has.256color
    autocmd BufEnter * highlight OverLength guibg=#444444 ctermbg=238
  else
    autocmd BufEnter * highlight OverLength ctermbg=7 ctermfg=1
  endif
  autocmd BufEnter * match OverLength /\%80v.*/
endif
" }}}

" spell config {{{
if g:jw.has.spell
  call s:MakeDir(expand(g:jw.dirs.vim . '/spells'))
  "let &spellfile = expand(g:jw.dirs.vim . '/spell/custom.en.utf-8.add')

  if g:jw.has.256color
    highlight SpellErrors guibg=#8700af ctermbg=91
  else
    highlight SpellErrors ctermbg=5 ctermfg=0
  endif
endif
" }}}

" keymaps {{{
nnoremap <silent> <leader>ev :rightbelow vsplit $MYVIMRC<cr>
nnoremap <silent> <leader>sv :source $MYVIMRC<cr>
nnoremap <silent> <leader>ss :setlocal spell!<cr>

inoremap jj <Esc>

xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<cr>

nnoremap <silent> <leader><leader>ww :setlocal wrap<cr>
nnoremap <silent> <leader><leader>nw :setlocal nowrap<cr>

nnoremap <silent> <leader><leader>h :setlocal hlsearch!<cr>
nnoremap <silent> <leader><leader>n :setlocal number!<cr>

if g:jw.has.terminal || g:jw.has.nvim
  nnoremap <silent> <leader>t term<cr>
  nnoremap <silent> <leader>tv :vertical term<cr>
endif

nnoremap <leader><leader>cs :colorscheme 

" provide functions to other scripts
nnoremap <silent> <leader><leader>$ :call <SID>TrimTrailingWhitespace()<cr>
if &diff
  set cursorline
  map ] ]c
  map [ [c
  hi DiffAdd    ctermfg=233 ctermbg=LightGreen guifg=#003300 guibg=#DDFFDD gui=none cterm=none
  hi DiffChange ctermbg=white  guibg=#ececec gui=none   cterm=none
  hi DiffText   ctermfg=233  ctermbg=yellow  guifg=#000033 guibg=#DDDDFF gui=none cterm=none
endif
" }}}

" abbreviations {{{
iabbrev adn and
iabbrev tehn then
iabbrev waht what
" }}}

" autocommands {{{
augroup filetypes
  autocmd!
  autocmd BufNewFile,BufRead *.md setlocal spell wrap
  autocmd FileType vim setlocal foldmethod=marker
augroup END
" }}}

" statusline {{{
" s:LinterStatus {{{
" function! s:LinterStatus() abort
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

" s:HasPaste {{{
" function! s:HasPaste()
"   if &paste
"     return 'PASTE MODE  '
"   endif
"   return ''
" endfunction
" }}}
" always show
" set laststatus=2
" set statusline=\ %{s:HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ %{FugitiveStatusline()}\ \ Line:\ %l\ \ Column:\ %c\ \ %{s:LinterStatus()}
" }}}

" vim-plug {{{
" make sure plugin dir exists
call s:MakeDir(g:jw.dirs.plugin)

call s:InstallPlug(g:jw.dirs.vim)
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
  Plug 'dracula/vim', { 'as': 'dracula' }
  Plug 'morhetz/gruvbox'
  Plug 'w0ng/vim-hybrid'
  Plug 'arcticicestudio/nord-vim'
  Plug 'NLKNguyen/papercolor-theme'
  Plug 'altercation/vim-colors-solarized'
  Plug 'colepeters/spacemacs-theme.vim'

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

  " fuzzy file finder {{{
  if g:jw.has.python3
    if ! g:jw.has.fzf
      " TODO: attempt to find the fzf home
      Plug 'junegunn/fzf', {
            \ 'dir': g:jw.fzf_dir,
            \ 'do': './install --all'
            \ }
    endif

    if isdirectory('/usr/local/opt/fzf')
      let g:jw.fzf_dir = '/usr/local/opt/fzf'
    else
      let g:jw.fzf_dir = expand($XDG_CONFIG_HOME . '/.fzf')
    endif

    Plug g:jw.fzf_dir | Plug 'junegunn/fzf.vim'
    nmap <C-p> :GFiles<cr>
    nmap <silent> <leader>p :Files<cr>
    nmap <silent> <leader>pa :Ag
    nmap <silent> <leader>pb :Buffers<cr>
    nmap <silent> <leader>pg :GFiles<cr>
    nmap <silent> <leader>pr :Rg
    nmap <silent> <leader>pt :Tags<cr>
  else
    Plug 'ctrlpvim/ctrlp.vim'
    " use .gitignore
    let g:ctrlp_user_command = [
          \ '.git',
          \ 'cd %s && git ls-files -co --exclude-standard'
          \ ]
  endif
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
  if g:jw.has.timers && g:jw.has.python3
    if g:jw.has.nvim
      Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    else
      Plug 'Shougo/deoplete.nvim'
      Plug 'roxma/nvim-yarp'
      Plug 'roxma/vim-hug-neovim-rpc'
    endif
    let g:deoplete#enable_at_startup = 1
    " inoremap <expr><Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
    " inoremap <expr><S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
    autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
  else
    " YouCompleteMe {{{
    if g:jw.has.python || g:jw.has.python3
      " handled by YCM below
      Plug 'ervandew/supertab'

      let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
      let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
      let g:SuperTabDefaultCompletionType = '<C-n>'

      let g:jw.ycm = {
            \ 'ft': ['eelixer', 'elixer',
            \        'javascript', 'javascript.jsx', 'typescript'],
            \ 'opts': []
            \}
      if g:jw.has.dotnet || g:jw.has.xbuild
        call add(g:jw.ycm.ft, 'cs')
        call add(g:jw.ycm.opts, '--omnisharp-completer')
      endif
      if g:jw.has.go
        call add(g:jw.ycm.ft, 'go')
        call add(g:jw.ycm.opts, '--gocode-completer')
      endif
      if g:jw.has.node && g:jw.has.npm
        call add(g:jw.ycm.opts, '--tern-completer')
      endif
      if g:jw.has.ruby
        call add(g:jw.ycm.ft, 'ruby')
      endif
      if g:jw.has.cargo || g:jw.has.rustc
        call add(g:jw.ycm.ft, 'rustc')
        call add(g:jw.ycm.opts, '--racer-completer')
      endif

      function! BuildYCM(info)
        " info is a dictionary with 3 fields
        " - name:   name of the plugin
        " - status: 'installed', 'updated', or 'unchanged'
        " - force:  set on PlugInstall! or PlugUpdate!
        if a:info.status == 'installed' || a:info.force
          execute './install.py ' . join(g:jw.ycm.opts, ' ')
        endif
      endfunction

      Plug 'Valloric/YouCompleteMe',
            \ { 'for': g:jw.ycm.ft, 'do': function('BuildYCM') }
      autocmd! User YouCompleteMe call youcompleteme#Enable()
    endif
    " }}}
  endif
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
  let g:airline_theme = s:colors.statusline
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

" Colors {{{
if g:jw.has.termguicolors
  set termguicolors
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

  " change cursor shape based on mode
  let &t_SI = "\<Esc>[6 q"
  let &t_SR = "\<Esc>[4 q"
  let &t_EI = "\<Esc>[2 q"
endif

if g:jw.has.colorcolumn
  if g:jw.has.256color
    highlight ColorColumn guibg=#444444 ctermbg=238
  else
    highlight ColorColumn ctermbg=7 ctermfg=1
  endif
endif

if g:jw.has.256color
  highlight SpellErrors guibg=#8700af ctermbg=91
else
  highlight SpellErrors ctermbg=5 ctermfg=0
endif

let &background = s:colors.background
silent! execute 'colorscheme ' . s:colors.scheme

if g:jw.has.iterm
  " csapprox can look silly on iterm, do not load it
  let g:CSApprox_loaded = 1
endif

if g:jw.has.conemu
  set term=pcansi
  set t_Co=256
  let &t_AB="\e[48;5;%dm"
  let &t_AF="\e[38;5;%dm"
endif
" }}}
