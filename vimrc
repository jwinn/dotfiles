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
      \ 'pip': executable('pip'),
      \ 'pip3': executable('pip3'),
      \ 'python': has('python'),
      \ 'python3': has('python3'),
      \ 'pythonx': has('pythonx'),
      \ 'ruby': has('ruby'),
      \ 'rustc': executable('rustc'),
      \ 'spell': has('spell'),
      \ 'termguicolors': has('termguicolors'),
      \ 'timers': has('timers'),
      \ 'tmux': executable('tmux'),
      \ 'tsserver': executable('tsserver'),
      \ 'undo': has('persistent_undo'),
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
      \     'airline': 'base16',
      \     'background': 'dark',
      \     'scheme': 'base16-default-dark',
      \   },
      \   'light': {
      \     'airline': 'base16',
      \     'background': 'light',
      \     'scheme': 'base16-default-light',
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

" s:CopyFile {{{
function! s:CopyFile(src, dest)
  let ret = writefile(readfile(a:src, 'b'), a:dest, 'b')
  " writeFile returns 0 for success and -1 for failure
  " make it truthy to vim and implicit return falsy (0)
  if ret == 0
    return 1
  endif
endfunction
" }}}

" s:ExecuteMacroOverVisualRange {{{
function! s:ExecuteMacroOverVisualRange()
  echo "@" . getcmdline()
  execute ":'<,'>normal @" . nr2char(getchar())
endfunction
" }}}

" s:HasPythonPackage {{{
function! s:HasPythonPackage(pkg)
  if !has('python') && !has('python3') && !has('pythonx')
    return 0
  endif

  " naive approach to checking if python package is available
  if has('python3') && executable('pip3')
    let output = system('pip3 freeze')
  else
    let output = system('pip freeze')
  endif

  if stridx(output, a:pkg) == -1 
    return 0
  endif

  return 1
endfunction
" }}}

" s:InstallFont {{{
function! s:InstallFont(src, dest)
  let src_font_path = expand(a:src)
  let src_font = fnamemodify(src_font_path, ':t')
  let dest_dir = expand(a:dest)
  let dest_font = expand(a:dest . '/' . src_font)

  if filereadable(src_font_path)
    call s:MakeDir(dest_dir)

    if !filereadable(dest_font)
      echom 'Copying font from: "' . src_font_path .
            \ '" to: "' . dest_font . '"'
      call CopyFile(src_font_path, dest_font)

      if g:jw.sys.win
        echom 'Attempting to install font: ' .  dest_font
        let font_name = fnamemodify(dest_font, ':t')

        call s:PowerShellCmd([
              \ '(New-Object-ComObject Shell.Application)' .
              \ '.Namespace(0x14).CopyHere("' . dest_font . '", 0x10)'
              \ ])

        if filereadable(expand($windir . '/fonts/' . font_name))
          echom 'Successfully installed font: ' . font_name
        else
          echoerr 'Unable to install, ' .
                \ 'please manually install the font: ' . dest_font
        endif
      endif

      if executable('fc-cache')
        echom 'Updating font cache'
        system('fc-cache -f ' . dest_dir)
      endif
    endif
  endif
endfunction
" }}}

" s:InstallFonts {{{
function! s:InstallFonts(src, dest)
  let src_dir = expand(a:src)
  let dest_dir = expand(a:dest)

  if isdirectory(src_dir)
    call s:MakeDir(dest_dir)

    let src_fonts = split(globpath(src_dir, '**/*.[ot]tf'), '\n')
    for src_font in src_fonts
      call s:InstallFont(src_font, dest_dir)
    endfor
  endif
endfunction
" }}}

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

" s:TrimTrailingWhitespace {{{
function! s:TrimTrailingWhitespace()
  let _s=@/
  :%s/\s\+$//e
  let @/=_s
  echohl Question
  echo 'Trailing whitespace cleared'
  echohl none
endfunction
" }}}

" }}}

" Leader {{{
" if g:jw.opts.leader is a space, map <Space> to <Leader>
" otherwise, change mapleader <Leader> to g:jw.opts.leader,
" but retain default for local buffers
"
" setting here causes this to be set for any <Leader> references later
" in the initialization sequence
if g:jw.opts.leader ==? '\<space>' || g:jw.opts.leader == ' '
  map <Space> <Leader>
  map <Space><Space> <Leader><Leader>
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
nnoremap <Leader>ev :rightbelow vsplit $MYVIMRC<CR>
nnoremap <Leader>sv :source $MYVIMRC<CR>
nnoremap <Leader>ss :setlocal spell!<CR>

inoremap jj <Esc>

xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>

nnoremap <Leader><Leader>h :setlocal hlsearch!<CR>

" provide functions to other scripts
nnoremap <Leader><Leader>n :setlocal number!<CR>
nnoremap <Leader><Leader>$ :call <SID>TrimTrailingWhitespace()<CR>
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

  " code in the dark (aka power mode)
  Plug 'mattn/vim-particle', { 'on': 'ParticleOn' }

  " helpful motion keys (<Leader><Leader> to trigger)
  Plug 'easymotion/vim-easymotion'

  " allow % to match more than chars
  Plug 'adelarsq/vim-matchit'

  " tags for source code files
  if g:jw.has.ctags
    Plug 'vim-scripts/taglist.vim'
    set tags+=./tags
    map <Leader>c :TlistToggle<CR>
    map <Leader>r :!ctags -R --exclude=.git --exclude=logs --exclude=doc .<CR>
  endif

  " editorconfig support
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

  " ColorScheme
  Plug 'chriskempson/base16-vim'
  if g:jw.has.256color
    let base16colorspace = 256
  endif
  Plug 'w0ng/vim-hybrid'
  Plug 'morhetz/gruvbox'
  Plug 'altercation/vim-colors-solarized'
  Plug 'colepeters/spacemacs-theme.vim'

  " inline colors
  Plug 'chrisbra/Colorizer'

  " improve? netrw
  Plug 'tpope/vim-vinegar'

  " netrw works, but NERDTree offers some extra features
  Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
  nmap <Leader>n :NERDTreeToggle<CR>
  let NERDTreeHighlightCursorline = 1
  let NERDTreeIgnore = ['tmp[[dir]]', '.yardoc', 'pkg']

  " async commands
  if g:jw.has.make
    Plug 'Shougo/vimproc.vim', { 'do': 'make' }
  endif

  " fuzzy file finder {{{
  if g:jw.has.fzf
    " TODO: may want to change to XDG dir?
    let g:jw.fzf_dir = expand($HOME . '/.fzf')

    if ! isdirectory(g:jw.fzf_dir)
      " TODO: find the fzf home
    endif
    Plug 'junegunn/fzf', {
          \ 'dir': g:jw.fzf_dir,
          \ 'do': './install --all'
          \ }
    Plug 'junegunn/fzf.vim'
    map <C-p> :Files<CR>
  else
    Plug 'ctrlpvim/ctrlp.vim'
    " use .gitignore
    let g:ctrlp_user_command = [
          \ '.git',
          \ 'cd %s && git ls-files -co --exclude-standard'
          \ ]
  endif
  " }}}

  " Snippets {{{
  if g:jw.has.python || g:jw.has.python3
    Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
    let g:UltiSnipsSnippetsDir = [g:jw.dirs.vim . '/UltiSnips']
    let g:UltiSnipsExpandTrigger = "<tab>"
    let g:UltiSnipsJumpForwardTrigger = "<tab>"
    let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"
    let g:UltiSnipsEditSplit = "vertical"
  endif
  " }}}

  " Text/Visual {{{
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

  " work with variants of words
  Plug 'tpope/vim-abolish'

  " status line goodness -- issue with NeoVim to remedy
  if ! g:jw.has.nvim
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    let g:airline_powerline_fonts = 1
    let g:airline_theme = s:colors.airline
  endif

  " arbitrary alignment by symbol
  Plug 'junegunn/vim-easy-align'

  " demarcate indentation
  Plug 'nathanaelkane/vim-indent-guides'
  let g:indent_guides_enable_on_vim_startup = 1
  "Plug 'Yggdroot/indentLine'
  "let g:indentLine_setColors = 0
  "let g:indentLine_char = '┆'
  "let g:indentLine_char = '│'

  " General Programming {{{

  " Linting {{{
  if g:jw.has.job && g:jw.has.timers
    "Plug 'neomake/neomake', { 'on': 'Neomake' }
    "let g:neomake_javascript_enabled_makers =
    "      \ ['standard', 'eslint', 'flow']

    Plug 'w0rp/ale'
    "let g:ale_linters = {
    "      \ 'javascript': ['eslint'],
    "      \}
    let g:ale_sign_column_always = 1
    let g:ale_sign_error = '⚑'
    let g:ale_sign_warning = '⚐'
    if exists('g:loaded_airline')
      let g:airline#extensions#ale#enabled = 1
    else
      function! LinterStatus() abort
        let l:counts = ale#statusline#Count(bufnr(''))

        let l:all_errors = l:counts.error + l:counts.style_error
        let l:all_non_errors = l:counts.total - l:all_errors

        return l:counts.total == 0 ? 'OK' : printf(
              \   '%dW %dE',
              \   all_non_errors,
              \   all_errors
              \)
      endfunction

      set statusline=%{LinterStatus()}
    endif
  else
    Plug 'vim-syntastic/syntastic'
    let g:syntastic_javascript_checkers = ['standard', 'eslint', 'flow']
    let g:syntastic_javascript_standard_exec = 'semistandard'
    autocmd bufwritepost *.js silent !semistandard % --format
    set autoread
  endif
  " }}}
  
  " Completion {{{
  if g:jw.has.timers && g:jw.has.python3
    if g:jw.has.nvim
      Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    else
      " check if neovim client installed (req for vim-hug-neovim-rpc)
      let hasnvimclient = s:HasPythonPackage('neovim')
      if !hasnvimclient
        echo "Installing neovim client..."
        let nvimclientinstall = system('pip3 install neovim')
      endif

      Plug 'Shougo/deoplete.nvim'
      Plug 'roxma/nvim-yarp'
      Plug 'roxma/vim-hug-neovim-rpc'
      let g:deoplete#enable_yarp = 1
    endif
    let g:deoplete#enable_at_startup = 1
    inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
    inoremap <expr><s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"
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
  " }}}

  " Single package for languages
  Plug 'sheerun/vim-polyglot'
  let g:vim_markdown_conceal = 0

  " Clojure
  "Plug 'tpope/vim-fireplace'
  "Plug 'guns/vim-clojure-static'
  "Plug 'vim-scripts/paredit.vim'

  " CSS {{{
  "let g:cssColorVimDoNotMessMyUpdatetime = 1
  "highlight VendorPrefix guifg=#00ffff gui=bold
  "match VendorPrefix /-\(moz\|webkit\|o\|ms\)-[a-zA-Z-]\+/
  " }}}

  " Elixir
  "Plug 'elixir-lang/vim-elixir'
  "Plug 'slashmili/alchemist.vim'

  "if g:jw.has.elm
  "  Plug 'lambdatoast/elm.vim'
  "  nnoremap <leader>el :ElmEvalLine<CR>
  "  vnoremap <leader>es :<C-u>ElmEvalSelection<CR>
  "  nnoremap <leader>em :ElmMakeCurrentFile<CR>
    "autocmd BufWritePost *.elm ElmMakeCurrentFile
    "autocmd BufWritePost *.elm ElmMakeFile("Main.elm")
  "endif

  " Go {{{
  "if g:jw.has.go
  "  Plug 'fatih/vim-go', { 'for': 'go' }
  "  augroup vimGo
  "    autocmd!

  "    autocmd FileType go nmap <Leader>s <Plug>(go-implements)
  "    autocmd FileType go nmap <Leader>i <Plug>(go-info)
  "    autocmd FileType go nmap <Leader>t <Plug>(go-test)
  "  augroup END
  "endif
  " }}}

  " HTML
  Plug 'mattn/emmet-vim'
  "Plug 'othree/html5.vim', { 'for': 'html' }
  "Plug 'mustache/vim-mustache-handlebars'

  " JavaScript {{{
  "Plug 'pangloss/vim-javascript', { 'for': ['javascript','javascript.jsx'] }
  if g:jw.has.node && g:jw.has.npm
    Plug 'ternjs/tern_for_vim', { 'do': 'npm install' }
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

  " LESS
  "Plug 'groenewege/vim-less' " LESS support
  "if g:jw.has.lessc
  "  nnoremap <Leader>m :w <BAR> !lessc % > %:t:r.css<CR><space>
  "endif

  " Markdown
  "Plug 'godlygeek/tabular'
  "Plug 'plasticboy/vim-markdown'
  "let g:vim_markdown_frontmatter = 1

  " PHP
  if g:jw.has.job && g:jw.has.timers
    Plug 'lvht/phpcd.vim', { 'for': 'php', 'do': 'composer install' }
    let g:PHP_outdentphpescape = 0
    if exists('*g:deoplete#enable')
      let g:deoplete#ignore_sources = get(g:, 'deoplete#ignore_sources', {})
      let g:deoplete#ignore_sources.php = ['omni']
    endif
  endif

  " Ruby {{{
  "if g:jw.has.ruby
  "  Plug 'vim-ruby/vim-ruby', { 'for': 'ruby' }
  "  Plug 'tpope/vim-rails', { 'for': 'ruby' }
  "  Plug 'thoughtbot/vim-rspec', { 'for': 'ruby' }
  "  let g:ruby_fold = 1
  "  let g:rspec_command = "Dispatch rspec {spec}"
  "  map <Leader>t :call RunCurrentSpecFile()<CR>
  "  map <Leader>s :call RunNearestSpec()<CR>
  "  map <Leader>l :call RunLastSpec()<CR>
  "  map <Leader>a :call RunAllSpecs()<CR>

  "  Plug 'hwartig/vim-seeing-is-believing'
  "  augroup seeingIsBelievingSettings
  "    autocmd!

  "    autocmd FileType ruby nmap <Buffer> <Enter> <Plug>(seeing-is-believing-mark-and-run)
  "    autocmd FileType ruby xmap <Buffer> <Enter> <Plug>(seeing-is-believing-mark-and-run)

  "    autocmd FileType ruby nmap <Buffer> <F4> <Plug>(seeing-is-believing-mark)
  "    autocmd FileType ruby xmap <Buffer> <F4> <Plug>(seeing-is-believing-mark)
  "    autocmd FileType ruby imap <Buffer> <F4> <Plug>(seeing-is-believing-mark)

  "    autocmd FileType ruby nmap <Buffer> <F5> <Plug>(seeing-is-believing-run)
  "    autocmd FileType ruby imap <Buffer> <F5> <Plug>(seeing-is-believing-run)
  "  augroup END
  "endif
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
