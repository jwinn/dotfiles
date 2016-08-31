" modeline {
" vim:set ft=vim sw=2 ts=2 sts=2 et tw=78 foldmarker={,} spell:
" }

" variables {

" g:jw {
let g:jw = {}

" g:jw.sys {
let s:tmp_ignorecase = &ignorecase

" temp set ignorecase
let &ignorecase = 1

let g:jw.sys = {}
let g:jw.sys.uname = system('uname -s')
let g:jw.sys.osx = (g:jw.sys.uname =~ 'darwin') || has('macunix')
let g:jw.sys.linux = (g:jw.sys.uname =~ 'linux') && has('unix') && !g:jw.sys.osx
let g:jw.sys.win = has('win16') || has('win32') || has('win64')
let g:jw.sys.unix = has('unix') && !g:jw.sys.osx && !g:jw.sys.win

" reset changes and clean up
let &ignorecase = s:tmp_ignorecase
unlet s:tmp_ignorecase
" }

" g:jw.cap {
let g:jw.cap = {}
let g:jw.cap.ack = executable('ack')
let g:jw.cap.ackgrep = executable('ackgrep')
let g:jw.cap.ag = executable('ag')
let g:jw.cap.ctags = executable('ctags')
let g:jw.cap.dash = isdirectory('/Applications/Dash.app')
let g:jw.cap.fzf = executable('fzf')
let g:jw.cap.gui = has('gui_running')
let g:jw.cap.has256 = (&term =~ '256color') || g:jw.cap.gui
let g:jw.cap.lua = has('lua')
let g:jw.cap.macvim = has('gui_macvim')
let g:jw.cap.npm = executable('npm')
let g:jw.cap.nvim = has('nvim')
let g:jw.cap.python = has('python')
let g:jw.cap.python3 = has('python3')
let g:jw.cap.ruby = has('ruby')
let g:jw.cap.termguicolors = has('termguicolors')
let g:jw.cap.tmux = executable('tmux')
" }

" g:jw.xdg {
let g:jw.xdg = {}
let g:jw.xdg.config_home = exists('$XDG_CONFIG_HOME')
      \ ? $XDG_CONFIG_HOME : expand('~/.config')
let g:jw.xdg.cache_home = exists('$XDG_CACHE_HOME')
      \ ? $XDG_CACHE_HOME : expand('~/.cache')
" }

" g:jw.opts {
let g:jw.opts = {
      \ 'colors': {
      \   'dark': {
      \     'airline': 'hybrid',
      \     'background': 'dark',
      \     'scheme': 'hybrid'
      \   },
      \   'light': {
      \     'airline': 'papercolor',
      \     'background': 'light',
      \     'scheme': 'papercolor'
      \   },
      \   'use_dark': 1
      \ },
      \ 'encoding': 'utf-8',
      \ 'font_dir': expand('~/.fonts'),
      \ 'leader': '\<space>',
      \ 'patched_font': 'Inconsolata for Powerline Nerd Font Complete.otf',
      \ 'patched_font_rel_dir': 'Inconsolata/complete',
      \ 'path': fnamemodify(resolve(expand('<sfile>:p')), ':h'),
      \ 'vim_home': expand(g:jw.xdg.config_home . '/vim')
      \ }

if g:jw.cap.nvim
  let g:jw.opts.vim_home = expand(g:jw.xdg.config_home . '/nvim')
  let &runtimepath = &runtimepath . ',' . g:jw.opts.vim_home
  set t_8f=^[[38:2:%lu:%lu:%lum
  set t_8b=^[[48:2:%lu:%lu:%lum
endif

let g:jw.opts.backup_dir = expand(g:jw.opts.vim_home . '/.backup')
let g:jw.opts.plugin_dir = expand(g:jw.opts.vim_home . '/plugged')
let g:jw.opts.undo_dir = expand(g:jw.opts.backup_dir . '/undo')

if g:jw.sys.win
  let g:jw.opts.patched_font = 'Inconsolata for Powerline Nerd Font Complete Windows Compatible.otf'
  " use vim_home instead of default vimfiles
  set runtimepath=g:jw.opts.vim_home,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,g:jw.opts.vim_home/after
endif

if g:jw.sys.osx
  let g:jw.opts.font_dir = expand('~/Library/Fonts')
endif

if g:jw.opts.leader ==? '\<space>' || g:jw.opts.leader ==? ' '
  let s:leader_is_space = 1
endif

if g:jw.opts.colors.use_dark
  let s:colors = g:jw.opts.colors.dark
else
  let s:colors = g:jw.opts.colors.light
endif
" default to base16 when term is 16 color or less
if &t_Co <= 16
  let s:colors.scheme = 'base16-default'
endif
" }

" }

" }

" leader {
" if g:jw.opts.leader is a space, map <space> to <leader>
if s:leader_is_space
  map <space> <leader>
  map <space><space> <leader><leader>
else
  " change mapleader <leader> to g:jw.opts.leader,
  " but retain default for local buffers
  " setting here causes this to be set for any <leader> references later
  " in the initialization sequence

  let &maplocalleader = &mapleader
  let mapleader = g:jw.opts.leader
endif
" }

" functions {

" CopyFile {
function! CopyFile(src, dest)
  let ret = writefile(readfile(a:src, 'b'), a:dest, 'b')
  if ret == -1
    return 0
  endif
  return 1
endfunction
" }

" InstallFont {
function! InstallFont(src, dest)
  let src_font_path = expand(a:src)
  let src_font = fnamemodify(src_font_path, ':t')
  let dest_dir = expand(a:dest)
  let dest_font = expand(a:dest . '/' . src_font)

  if filereadable(src_font_path)
    call s:MakeDir(dest_dir)

    if !filereadable(dest_font)
      echom "Copying font from: '" . src_font_path . "' to: '" . dest_font . "'"
      call CopyFile(src_font_path, dest_font)

      if g:jw.sys.win
        echom "Attempting to install font: " .  dest_font
        let font_name = fnamemodify(dest_font, ':t')

        call s:PowerShellCmd([
              \ "(New-Object -ComObject Shell.Application).Namespace(0x14).CopyHere('" . dest_font . "', 0x10)"
              \ ])

        if filereadable(expand($windir . '/fonts/' . font_name))
          echom "Successfully installed font: " . font_name
        else
          echoerr "Unable to install, please manually install the font: " . dest_font
        endif
      endif

      if executable('fc-cache')
        echom 'Updating font cache'
        system('fc-cache -f ' . g:jw.sysvars.fonts)
      endif
    endif
  endif
endfunction
" }

" InstallFonts {
function! s:InstallFonts(src, dest)
  let src_dir = expand(a:src)
  let dest_dir = expand(a:dest)

  if isdirectory(src_dir)
    call s:MakeDir(dest_dir)

    let src_fonts = split(globpath(src_dir, '**/*.[ot]tf'), '\n')
    for src_font in src_fonts
      call InstallFont(src_font, dest_dir)
    endfor
  endif
endfunction
"}

" InstallPlug {
function! InstallPlug(vhome)
  if !filereadable(expand(a:vhome . '/autoload/plug.vim'))
    let autoload_dir = expand(a:vhome . '/autoload')
    let plug_file = expand(autoload_dir . '/plug.vim')
    let plug_uri = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

    if g:jw.sys.win
      call s:MakeDir(autoload_dir)
      call s:PowerShellCmd([
            \ "(New-Object Net.WebClient).DownloadFile('" . plug_uri . "', $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath('" . plug_file . "'))"
            \ ])
    else
      silent execute '!curl -fLo ' . plug_file . ' --create-dirs ' . plug_uri
    endif

    autocmd VimEnter * PlugInstall | source $MYVIMRC
  endif
endfunction
" }

" MakeDir {
function! s:MakeDir(path)
  if !isdirectory(expand(a:path))
    silent call mkdir(expand(a:path), 'p')
  endif
endfunction
" }

" PowerShellCmd {
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
" }

" ToggleLineNumbers {
nmap <leader>N :call <sid>ToggleLineNumbers()<cr>
function! s:ToggleLineNumbers()
  if &number
    set nonumber
  else
    set number
  endif
endfunction
" }

" TrimTrailingWhitespace {
nmap <leader>$ :call <sid>TrimTrailingWhitespace()<cr>
function! s:TrimTrailingWhitespace()
  let _s=@/
  :%s/\s\+$//e
  let @/=_s
  echohl Question
  echo 'Trailing whitespace cleared'
  echohl none
endfunction
" }

" }

" vim-plug {
" make sure XDG folders exist
call s:MakeDir(g:jw.xdg.config_home)
call s:MakeDir(g:jw.xdg.cache_home)

call InstallPlug(g:jw.opts.vim_home)
call plug#begin(g:jw.opts.plugin_dir)

" be sensible (default settings)
Plug 'tpope/vim-sensible'

" ctags sidebar
if g:jw.cap.ctags
  Plug 'majutsushi/tagbar'
endif

" code search
if g:jw.cap.ack
  Plug 'mileszs/ack.vim'
elseif g:jw.cap.ackgrep
  let g:ackprg="ack-grep -H --nocolor --nogroup --column"
  Plug 'mileszs/ack.vim'
elseif g:jw.cap.ag
  Plug 'mileszs/ack.vim'
  let g:ackprg = 'ag --nogroup --nocolor --column --smart-case'
endif

" Dash doc integration
if g:jw.sys.osx && g:jw.cap.dash
  Plug 'rizzatti/dash.vim'
  nmap <silent> <leader>d <Plug>DashSearch
endif

" airline
Plug 'vim-airline/vim-airline' | Plug 'vim-airline/vim-airline-themes'

" colorschemes
Plug 'chriskempson/base16-vim' " base16 theme
Plug 'godlygeek/csapprox' " CSApprox
Plug 'morhetz/gruvbox' " gruvbox
Plug 'NLKNguyen/papercolor-theme' " pastel theme
Plug 'junegunn/seoul256.vim' " nice dark/light color
Plug 'altercation/vim-colors-solarized' " old classic
Plug 'toupeira/vim-desertink' " desert ink theme
Plug 'w0ng/vim-hybrid' " dark color scheme

" common
Plug 'luochen1990/rainbow' " colors for multiple parentheses
Plug 'scrooloose/syntastic' " syntax check
Plug 'tComment' " comment helper
Plug 'terryma/vim-multiple-cursors' " multiple cursors
Plug 'tpope/vim-surround' " surround things
Plug 'janko-m/vim-test' " test runner
if g:jw.cap.nvim
  Plug 'neomake/neomake' " async make through nvim
  Plug 'kassio/neoterm' " wraps nvim terminal functions
endif

" completion
if g:jw.cap.fzf
  Plug 'junegunn/fzf.vim' " fuzzy file finder
else
  Plug 'ctrlpvim/ctrlp.vim' " CtrlP support
  Plug 'tacahiroy/ctrlp-funky' " CtrlP funky plugin
endif
if g:jw.cap.nvim && g:jw.cap.python3
  function! DoRemote(arg)
    UpdateRemotePlugins
  endfunction
  Plug 'Shougo/deoplete.nvim', { 'do': function('DoRemote') }
else
  Plug 'ajh17/VimCompletesMe' " Completion support
endif

" css
Plug 'JulesWang/css.vim' " CSS syntax
Plug 'skammer/vim-css-color' " colors css color strings
Plug 'groenewege/vim-less' " LESS support

" git
Plug 'tpope/vim-fugitive' " git
Plug 'airblade/vim-gitgutter' " git changes in gutter

" go
Plug 'fatih/vim-go' " go lang support

" html
Plug 'mattn/emmet-vim' " emmet support
Plug 'othree/html5.vim' " html5 + svg support

" js
Plug 'othree/javascript-libraries-syntax.vim' " js lib syntax
Plug 'pangloss/vim-javascript' " Javscript syntax
Plug 'heavenshell/vim-jsdoc' " generate jsdoc
Plug 'elzr/vim-json' " json support
Plug 'mxw/vim-jsx' " jsx support
Plug 'moll/vim-node' " node.js support
Plug 'othree/yajs.vim', { 'for': 'javascript' } " js syntax
Plug 'othree/jspc.vim' " parameter completion

" less
Plug 'groenewege/vim-less' " LESS support

" markdown
Plug 'vim-pandoc/vim-pandoc-syntax' " markdown syntax
if g:jw.cap.npm
  Plug 'suan/vim-instant-markdown',
        \{ 'do': 'npm install -g instant-markdown-d' }
endif

" rust
Plug 'rust-lang/rust.vim' " rust lang support

" swift
Plug 'Keithbsmiley/swift.vim' " swift syntax support

" tmux
if g:jw.cap.tmux
  Plug 'christoomey/vim-tmux-navigator' " movement consistency
endif

" vim-devicons and pre-patched fonts
" should be loaded after NERDTree, airline and/or unite
Plug 'ryanoasis/nerd-fonts' | Plug 'ryanoasis/vim-devicons'

call plug#end()
" }

" 1 important {
if &compatible
  set nocompatible
endif

set pastetoggle=<F12> " pastetoggle (sane indentation on paste)
" }

" 2 moving around, searching and patterns {
set incsearch
set ignorecase
set smartcase
" }

" 3 tags {
set tags=./tags;/,~/.vimtags

" Make tags placed in .git/tags file available in all levels of a repository
let gitroot = substitute(system('git rev-parse --show-toplevel'), '[\n\r]', '', 'g')
if gitroot != ''
  let &tags = &tags . ',' . gitroot . '/.git/tags'
endif
" }

" 4 displaying text {
set scrolloff=5
set sidescroll=1
set sidescrolloff=8
set display+=lastline
set lines=40
set number
set norelativenumber
set numberwidth=5
if has('conceal')
  set conceallevel=0
  set concealcursor=nvc
endif
" }

" 5 syntax, highlighting and spelling {
filetype plugin indent on
let &background = s:colors.background
set synmaxcol=2048 " no need to syntax color super long lines
set hlsearch " highlights matched search pattern
if g:jw.cap.nvim && g:jw.cap.termguicolors
  set termguicolors
endif
set cursorline " highlight screen line of cursor
set textwidth=80 " highlight 80 column

if exists('&colorcolumn')
  " highlight column at #
  set colorcolumn=80
  let &colorcolumn="80,".join(range(120,999),",")
else
  au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
endif
if has('spell')
  set nospell
  let &spellfile = expand(g:jw.opts.vim_home . '/spells/en.add')
  if !isdirectory(expand(g:jw.opts.vim_home . '/spells'))
    call s:MakeDir(expand(g:jw.opts.vim_home . '/spells', 'p'))
  endif
endif
" }

" 6 multiple windows {
" }

" 7 multiple tab pages {
" }

" 8 terminal {
if ! g:jw.cap.nvim
  set ttyfast
endif
" }

" 9 using the mouse {
" }

" 10 printing {
set printoptions=header:0,duplex:long,paper:letter
" }

" 11 messages and info {
set shortmess+=filmnrxoOtT      " abbr. of messages (avoids "hit enter")
set showcmd                     " show partial cmd keys in status bar
" ruler on steroids?
set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%)
set visualbell                  " use visual bell instead of beep
" }

" 12 selecting text {
if has('unnamedplus')
  set clipboard=unnamed,unnamedplus " use + register for copy/paste
else
  set clipboard=unnamed " use system clipboard
endif
" }

" 13 editing text {
" persistent undo
if has('persistent_undo')
  set undofile
  let &undodir = g:jw.opts.undo_dir . ',~/tmp,.'
  " create the backup dir if it doesn't exist
  call s:MakeDir(g:jw.opts.undo_dir)
endif
set completeopt=menu,preview,longest
set showmatch " when inserting bracket, brief jump to match
set nojoinspaces " do not add second space when joining lines
" }

" 14 tabs and indenting {
set tabstop=2 " # spaces <Tab> equals
set shiftwidth=2 " # spaces used for each (auto)indent
set softtabstop=2 " # spaces to insert for tab (<ctrl-v><TAB>)
set shiftround " round to 'shiftwidth' for "<<" and ">>"
set expandtab " expand <TAB> to spaces in Insert mode
set smartindent " do clever autoindenting
" }

" 15 folding {
if has('folding')
  set foldenable " auto fold code
  set foldmethod=marker " folding type
endif
" }

" 16 diff mode {
set diffopt+=iwhite
" }

" 17 mapping {
" }

" 18 reading and writing files {
set nobackup " do not keep a backup ~ file
" list of dirs for backup file
let &backupdir = g:jw.opts.backup_dir . ',.'
set autoread " auto read file modified outside of vim
" create the backup dir if it doesn't exist
call s:MakeDir(g:jw.opts.backup_dir)
" }

" 19 the swap file {
set noswapfile " do not use a swap file
" list of dirs for swap files
let &directory = g:jw.opts.backup_dir . ',~/tmp,.'
" }

" 20 command line editing {
" }

" 21 executing external commands {
if g:jw.sys.win
  " change to powershell
  "set shell=powershell.exe\ -ExecutionPolicy\ Unrestricted
  "set shellcmdflag=-Command
  "set shellpipe=>
  "set shellredir=>
elseif exists($SHELL)
  set shell=$SHELL " shell to use for ext cmds
endif
" }

" 22 running make and jumping to errors {
" }

" 23 language specific {
" }

" 24 multi-byte characters {
let &encoding = g:jw.opts.encoding
scriptencoding g:jw.opts.encoding
" }

" 25 various {
" }

" autocmd {
if has('autocmd')
  " recalculate the trailing whitespace warning when idle, and after saving
  au cursorhold,bufwritepost * unlet! b:statusline_trailing_space_warning

  " recalculate the tab warning flag when idle and after writing
  au cursorhold,bufwritepost * unlet! b:statusline_tab_warning

  "recalculate the long line warning when idle and after saving
  au cursorhold,bufwritepost * unlet! b:statusline_long_line_warning

  " automatically switch to the current file directory when a new
  " buffer is opened
  au BufEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | lcd %:p:h | endif

  " remember last position in file
  au BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \   exe "normal g`\"" |
        \ endif

  " instead of reverting the cursor to the last position in the buffer,
  " set it to the first line when editing a git commit message
  au FileType gitcommit
        \ au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

  " remove trailing whitespace and ^M chars
  au FileType c,cpp,java,go,php,javascript,python,twig,xml,yml
        \ au BufWritePre <buffer> call s:TrimTrailingWhitespace()

  " format go docs on load
  au FileType go autocmd BufWritePre <buffer> Fmt

  " auto resize window splits
  au VimResized * exe "normal! \<C-w>="

  " set coffeescript filetype, just in case
  au BufNewFile,BufRead *.coffee set filetype=coffee
endif
" }

" keybindings {
" exit insert mode with jj
inoremap jj <ESC>

" make Y consistent with C and D
nnoremap Y y$

" easier window moving
map <C-j> <C-w>j<C-w>_
map <C-k> <C-w>k<C-w>_
map <C-l> <C-w>l<C-w>_
map <C-h> <C-w>h<C-w>_
" }

" GUI (here instead of .gvimrc) {
if g:jw.cap.gui
  set guioptions-=m " remove the menu
  set guioptions-=T " remove the toolbar
  set guioptions-=t " remove tear-off menus
  set guioptions+=a " visual mode is global
  set guioptions+=c " use :ex prompt instead of modal dialogs

  if g:jw.sys.osx
    " make Mac 'Option' key behave as 'Alt'
    set macmeta

    set linespace=2 " # pixel lines between characters
    set guifont=Inconsolata:h14,Monaco:h14,Consolas:h14,Courier\ New:h14,Courier:h14

    " MacVIM shift+arrow-keys behavior (required in .vimrc)
    let macvim_hig_shift_movement = 1
  else
    set guifont=Inconsolata:h14,Monaco:h14,Consolas:h14,Courier\ New:h14,Courier:h14
  endif

  if has('transparency')
    set transparency=5 " transparency of text bg as %
    set blurradius=1 " blur effect on transparent bg
  endif

  " open macvim in fullscreen
  if g:jw.cap.macvim
    set fuoptions=maxvert,maxhorz
    "au GUIEnter * set fullscreen
  endif

  if !s:leader_is_space
    " setting these in GVim/MacVim because terminals cannot distinguish between
    " <space> and <S-space> because curses sees them the same
    nnoremap <space> <PageDown>
    nnoremap <S-space> <PageUp>
  endif

  if has('autocmd')
    " auto resize splits when window resizes
    "autocmd VimResized * wincdm =
  endif
elseif g:jw.cap.has256
  set t_Co=256 " enable 256 colors for CSApprox warning
endif
" }

" plugin config {

" ctrlp {
if isdirectory(expand(g:jw.opts.plugin_dir . '/ctrlp.vim'))
  let g:ctrlp_working_path_mode = 'ra'
  nnoremap <silent> <D-t> :CtrlP<CR>
  nnoremap <silent> <D-r> :CtrlPMRU<CR>
  let g:ctrlp_custom_ignore = {
        \ 'dir':  '\.git$\|\.hg$\|\.svn|node_modules|bower_components$',
        \ 'file': '\.exe$\|\.so$\|\.dll$\|\.pyc$' }

  if executable('ag')
    let s:ctrlp_fallback = 'ag %s --nocolor -l -g ""'
  elseif executable('ack-grep')
    let s:ctrlp_fallback = 'ack-grep %s --nocolor -f'
  elseif executable('ack')
    let s:ctrlp_fallback = 'ack %s --nocolor -f'
  " on Windows use "dir" as fallback command.
  elseif g:jw.sys.win
    let s:ctrlp_fallback = 'dir %s /-n /b /s /a-d'
  else
    let s:ctrlp_fallback = 'find %s -type f'
  endif
  if exists("g:ctrlp_user_command")
    unlet g:ctrlp_user_command
  endif
  let g:ctrlp_user_command = {
        \ 'types': {
        \ 1: ['.git', 'cd %s && git ls-files . --cached --exclude-standard --others'],
        \ 2: ['.hg', 'hg --cwd %s locate -I .'],
        \ },
        \ 'fallback': s:ctrlp_fallback
        \ }

  if isdirectory(expand(g:jw.opts.plugin_dir . '/ctrlp-funky'))
    " ctrlp extensions
    let g:ctrlp_extensions = ['funky']

    " funky
    nnoremap <leader>fu :CtrlPFunky<cr>
    " narrow the list down with a word under cursor
    nnoremap <leader>fU :execute 'CtrlPFunky ' . expand('<cword>')<cr>
    let g:ctrlp_funky_matchtype = 'path'
    let g:ctrlp_funky_syntax_highlight = 1
  endif
endif
" }

" deoplete {
if isdirectory(expand(g:jw.opts.plugin_dir . '/deoplete'))
  let g:deoplete#enable_at_startup = 1
  let g:deoplete#disable_auto_complete = 0
  autocmd InsertLeave,CompleteDone *
        \ if pumvisible() == 0 | pclose | endif
  if !exists('g:deoplete#omni#input_patterns')
    let g:deoplete#omni#input_patterns = {}
  endif
endif
" }

" emmet-vim {
if isdirectory(expand(g:jw.opts.plugin_dir . '/emmet-vim'))
  let g:user_emmet_mode = 'i' " only enable in insert mode
  let g:user_emmet_leader_key = '<C-y>' " default, change, if necessary
  " only enable for html,css,scss
  let g:user_emmet_install_global = 0
  autocmd FileType html,css,scss EmmetInstall
endif
" }

" fugitive {
if isdirectory(expand(g:jw.opts.plugin_dir . '/vim-fugitive'))
  nnoremap <silent> <leader>gs :Gstatus<CR>
  nnoremap <silent> <leader>gd :Gdiff<CR>
  nnoremap <silent> <leader>gc :Gcommit<CR>
  nnoremap <silent> <leader>gb :Gblame<CR>
  nnoremap <silent> <leader>gl :Glog<CR>
  nnoremap <silent> <leader>gp :Git push<CR>
  nnoremap <silent> <leader>gr :Gread<CR>
  nnoremap <silent> <leader>gw :Gwrite<CR>
  nnoremap <silent> <leader>ge :Gedit<CR>
  " Mnemonic _i_nteractive
  nnoremap <silent> <leader>gi :Git add -p %<CR>
  nnoremap <silent> <leader>gg :SignifyToggle<CR>
endif
" }

" javascript-libraries-syntax.vim {
if isdirectory(expand(g:jw.opts.plugin_dir . '/javascript-libraries-syntax.vim'))
  " jquery,underscore,backbone,prelude,angularjs,angualrui,angularuirouter,react,flux,requirejs,sugar,jasmine,chai,handlebars
  let g:used_javascript_libs = 'jquery,underscore,angularjs,angularui,angularuirouter,react,flux,jamine,chai'
endif
" }

" nerd-fonts {
if isdirectory(expand(g:jw.opts.plugin_dir . '/nerd-fonts'))
  let nerdfont_dir = expand(g:jw.opts.plugin_dir . '/nerd-fonts/patched-fonts')
  let patched_font_dir = expand(nerdfont_dir . '/' . g:jw.opts.patched_font_rel_dir)
  let patched_font = expand(patched_font_dir . '/' . g:jw.opts.patched_font)
  let font_name = substitute(fnamemodify(patched_font, ':t:r'), ' ', '_', 'g')

  call InstallFont(patched_font, g:jw.opts.font_dir)

  if g:jw.cap.gui
    if g:jw.sys.linux
      let &guifont = font_name . '\ 14'
    else
      let &guifont = font_name . ':h14'
    endif
  endif
endif
" }

" neomake {
if isdirectory(expand(g:jw.opts.plugin_dir . '/neomake'))
  autocmd! BufWritePost * Neomake
  " autocmd BufLeave * QFix

  let g:neomake_warning_sign = {
        \ 'text': 'W',
        \ 'texthl': 'WarningMsg',
        \ }

  let g:neomake_error_sign = {
        \ 'text': 'E',
        \ 'texthl': 'ErrorMsg',
        \ }

  let g:neomake_open_list = 2

  let g:neomake_javascript_enabled_makers = ['eslint']
endif
" }

" neoterm {
if isdirectory(expand(g:jw.opts.plugin_dir . '/neoterm'))
endif
" }

" netrw {
let g:netrw_altv = 1
let g:netrw_ftp_cmd = 'ftp -p'
let g:netrw_ftpmode = 'ascii'
let g:netrw_longlist = 1
let g:netrw_preview = 1
let g:netrw_silent = 1
let g:netrw_winsize = 40
let g:DrChipTopLvlMenu = 'Plugins.'
if g:jw.sys.unix && exists("$DISPLAY")
  let g:netrw_browsex_viewer = 'xdg-open'
endif
" }

" omnicomplete {
if has('autocmd') && exists('+omnifunc')
  autocmd Filetype *
        \if &omnifunc == "" |
        \setlocal omnifunc=syntaxcomplete#Complete |
        \endif
endif

hi Pmenu guifg=#000000 guibg=#F8F8F8 ctermfg=black ctermbg=Lightgray
hi PmenuSbar guifg=#8A95A7 guibg=#F8F8F8 gui=NONE ctermfg=darkcyan ctermbg=lightgray cterm=NONE
hi PmenuThumb guifg=#F8F8F8 guibg=#8A95A7 gui=NONE ctermfg=lightgray ctermbg=darkcyan cterm=NONE

" Some convenient mappings
"inoremap <expr> <Esc>      pumvisible() ? "\<C-e>" : "\<Esc>"
inoremap <expr> <Down>     pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <expr> <Up>       pumvisible() ? "\<C-p>" : "\<Up>"
inoremap <expr> <C-d>      pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<C-d>"
inoremap <expr> <C-u>      pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<C-u>"

" Automatically open and close the popup menu / preview window
au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
set completeopt=menu,preview,longest
" }

" rainbow {
if exists("g:plugs['rainbow']")
  let g:rainbow_active = 1 " 0 if you want to enable it later via :RainbowToggle
  let g:rainbow_conf = {
        \   'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
        \   'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
        \   'operators': '_,_',
        \   'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
        \   'separately': {
        \       '*': {},
        \       'tex': {
        \           'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
        \       },
        \       'lisp': {
        \           'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],
        \       },
        \       'vim': {
        \           'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold', 'start=/(/ end=/)/ containedin=vimFuncBody', 'start=/\[/ end=/\]/ containedin=vimFuncBody', 'start=/{/ end=/}/ fold containedin=vimFuncBody'],
        \       },
        \       'html': {
        \           'parentheses': ['start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
        \       },
        \       'css': 0,
        \   }
        \}
endif
" }

" syntastic {
if isdirectory(expand(g:jw.opts.plugin_dir . '/syntastic'))
  set statusline+=%#warningmsg#
  set statusline+=%{SyntasticStatuslineFlag()}
  set statusline+=%*

  nmap <leader>l :SyntasticToggleMode<cr>
  nmap <leader>L :SyntasticCheck<cr>

  let g:syntastic_always_populate_loc_list = 1
  let g:syntastic_auto_loc_list = 1
  let g:syntastic_check_on_open = 1
  let g:syntastic_check_on_wq = 0

  let g:syntastic_javascript_checkers = [ 'eslint', 'jscs' ]
  let g:syntastic_python_checkers = [ 'python' ]
endif
" }

" unite {
if isdirectory(expand(g:jw.opts.plugin_dir . '/unite.vim'))
  call unite#filters#matcher_default#use(['matcher_fuzzy'])
  call unite#filters#sorter_default#use(['sorter_rank'])
  "call unite#custom#source('file_rec/async','sorters','sorter_rank', )
  " ctrl+p
  let g:unite_data_directory='~/.vim/.cache/unite'
  let g:unite_enable_start_insert = 1
  let g:unite_source_history_yank_enable = 1
  let g:unite_prompt = '» '
  let g:unite_split_rule = 'botright'
  if executable('ag')
    let g:unite_source_grep_command = 'ag'
    let g:unite_source_grep_default_opts = '--nocolor --nogroup -S -C4'
    let g:unite_source_grep_recursive_opt = ''
  endif
  nnoremap <silent> <c-p> :Unite -auto-resize file file_mru file_rec<cr>

  " ack.vim/ag.vim
  nnoremap <Space>/ :Unite grep:.<CR>

  " yankring/yankstack
  nnoremap <Space>y :Unite history/yank<cr>

  " LustyJuggler
  nnoremap <Space>s :Unite -quick-match buffer<CR>
endif
" }

" vim-airline {
if isdirectory(expand(g:jw.opts.plugin_dir . '/vim-airline'))
  if isdirectory(expand(g:jw.opts.plugin_dir . '/nerd-fonts'))
    let g:airline_powerline_fonts = 1
  else
    if !exists('g:airline_symbols')
      let g:airline_symbols = {}
    endif

    " unicode symbols
    let g:airline_left_sep = '»'
    let g:airline_left_sep = '▶'
    let g:airline_right_sep = '«'
    let g:airline_right_sep = '◀'
    let g:airline_symbols.linenr = '␊'
    let g:airline_symbols.linenr = '␤'
    let g:airline_symbols.linenr = '¶'
    let g:airline_symbols.branch = '⎇'
    let g:airline_symbols.paste = 'ρ'
    let g:airline_symbols.paste = 'Þ'
    let g:airline_symbols.paste = '∥'
    let g:airline_symbols.whitespace = 'Ξ'
    " let g:airline_left_sep = "\ue0b0"
    " let g:airline_left_alt_sep = "\ue0b1"
    " let g:airline_right_sep = "\ue0b2"
    " let g:airline_right_alt_sep = "\ue0b3"
    " let g:airline_symbols.branch = "\ue0a0"
    " let g:airline_symbols.readonly = "\ue0a2"
    " let g:airline_symbols.linenr = "\ue0a1"
  endif
endif
" }

" vim-css-color {
if isdirectory(expand(g:jw.opts.plugin_dir . '/vim-css-color'))
  let g:cssColorVimDoNotMessMyUpdatetime = 1
endif
" }

" vim-css3-syntax {
if isdirectory(expand(g:jw.opts.plugin_dir . '/vim-css3-syntax'))
  highlight VendorPrefix guifg=#00ffff gui=bold
  match VendorPrefix /-\(moz\|webkit\|o\|ms\)-[a-zA-Z-]\+/
endif
" }

" vim-gitgutter {
if isdirectory(expand(g:jw.opts.plugin_dir . '/vim-gitgutter'))
  let g:gitgutter_max_signs = 500  " default value
endif
" }

" vim-jsdoc {
if isdirectory(expand(g:jw.opts.plugin_dir . '/vim-jsdoc'))
  " turn on detecting underscore starting functions as private convention
  let g:jsdoc_underscore_private = 1
  let g:jsdoc_enable_es6 = 1 " allow ES6 shorthand syntax

  " since v0.3 there is no longer a default mapping
  nmap <silent> <leader>jd <Plug>(jsdoc)
endif
" }

" vim-json {
if isdirectory(expand(g:jw.opts.plugin_dir . '/vim-json'))
  let g:vim_json_syntax_conceal = 0
endif
" }

" vim-jsx {
if isdirectory(expand(g:jw.opts.plugin_dir . '/vim-jsx'))
  let g:jsx_ext_required = 0 " allows for jsx syntax in .js files
endif
" }

" vim-less {
if isdirectory(expand(g:jw.opts.plugin_dir . '/vim-less'))
  if executable('lessc')
    nnoremap <Leader>m :w <BAR> !lessc % > %:t:r.css<CR><space>
  endif
endif
" }

" vim-multiple-cursors {
if isdirectory(expand(g:jw.opts.plugin_dir . '/vim-multiple-cursors'))
  let g:multi_cursor_start_key = '<C-d>'
  let g:multi_cursor_start_word_key = 'g<C-d>'
  let g:multi_cursor_next_key = '<C-d>'
  let g:multi_cursor_prev_key = '<C-S-d>'
  let g:multi_cursor_skip_key = '<C-x>'
  let g:multi_cursor_quit_key = '<Esc>'

  let g:multi_cursor_exit_from_visual_mode = 1
  let g:multi_cursor_exit_from_insert_mode = 1

  " account for neocomplete to improve perf
  function! Multiple_cursors_before()
    if exists(':NeoCompleteLock') == 2
      execute 'NeoCompleteLock'
    endif
  endfunction

  function! Multiple_cursors_after()
    if exists(':NeoCompleteUnlock') == 2
      execute 'NeoCompleteUnlock'
    endif
  endfunction

  highlight multiple_cursors_cursor term=reverse cterm=reverse gui=reverse
  highlight link multiple_cursors_visual Visual
endif
" }

" vim-test {
if isdirectory(expand(g:jw.opts.plugin_dir . '/vim-test'))
endif
" }

" vim-tmux-navigator {
if isdirectory(expand(g:jw.opts.plugin_dir . '/vim-tmux-navigator'))
  let g:tmux_navigator_no_mappings = 1
  let g:tmux_navigator_save_on_switch = 0 " default [0]

  nnoremap <silent> {Left-mapping} :TmuxNavigateLeft<cr>
  nnoremap <silent> {Down-Mapping} :TmuxNavigateDown<cr>
  nnoremap <silent> {Up-Mapping} :TmuxNavigateUp<cr>
  nnoremap <silent> {Right-Mapping} :TmuxNavigateRight<cr>
  nnoremap <silent> {Previous-Mapping} :TmuxNavigatePrevious<cr>
endif
" }

" colors {
if exists('&colorcolumn')
  if g:jw.cap.has256
    highlight ColorColumn guibg=#444444 ctermbg=238
  else
    highlight ColorColumn ctermbg=7 ctermfg=1
  endif
endif

if g:jw.cap.has256
  highlight SpellErrors guibg=#8700af ctermbg=91
else
  highlight SpellErrors ctermbg=5 ctermfg=0
endif

if isdirectory(expand(g:jw.opts.plugin_dir . '/seoul256.vim'))
  let g:seoul256_light_background = 256
  let g:seoul256_background = 233
endif

if isdirectory(expand(g:jw.opts.plugin_dir . '/vim-colors-solarized'))
  let g:solarized_termcolors = 256
  let g:solarized_termtrans = 1
  let g:solarized_contrast = "high"
  let g:solarized_visibility = "high"
endif

if isdirectory(expand(g:jw.opts.plugin_dir . '/vim-hybrid'))
  let g:hybrid_custom_term_colors = 1
  let g:hybrid_reduced_contrast = 1 " low contrast colors
endif

if !empty($ITERM_PROFILE)
  " csapprox can look silly on iterm, do not load it
  let g:CSApprox_loaded = 1
endif

if !empty($CONEMUBUILD)
  set term=pcansi
  set t_Co=256
  let &t_AB="\e[48;5;%dm"
  let &t_AF="\e[38;5;%dm"
endif

silent! execute 'colorscheme ' . s:colors.scheme
let g:airline_theme = s:colors.airline
" }

