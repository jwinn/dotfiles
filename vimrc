" modeline {
" vim:set ft=vim sw=2 ts=2 sts=2 et tw=78 foldmarker={,} spell:
" }

" variables {

" g:sys {
let s:tmp_ignorecase = &ignorecase

" temp set ignorecase
let &ignorecase = 1

let g:sys = {}
let g:sys.uname =  system('uname -s')
let g:sys.osx =    (g:sys.uname =~ 'darwin') || has('macunix')
let g:sys.linux =  (g:sys.uname =~ 'linux') && has('unix') && !g:sys.osx
let g:sys.win =    has('win16') || has('win32') || has('win64')
let g:sys.unix =   has('unix') && !g:sys.osx && !g:sys.win
let g:sys.gui =    has('gui_running')
let g:sys.macvim = has('gui_macvim')
let g:sys.nvim =   has('nvim')
let g:sys.python = has('python')
let g:sys.ruby =   has('ruby')
let g:sys.has256 = (&term =~ '256color') || g:sys.gui

" reset changes and clean up
let &ignorecase = s:tmp_ignorecase
unlet s:tmp_ignorecase
" }

" g:opts {
let g:opts = {
      \ 'airline_theme': 'hybrid',
      \ 'color_dark': 1,
      \ 'color_scheme': 'hybrid',
      \ 'font_dir': expand('~/.fonts'),
      \ 'leader': ',',
      \ 'patched_font': 'Inconsolata for Powerline Nerd Font Complete.otf',
      \ 'patched_font_rel_dir': 'Inconsolata/complete',
      \ 'vim_home': expand('~/.vim')
      \ }

if g:sys.win
  let g:opts.patched_font = 'Inconsolata for Powerline Nerd Font Complete Windows Compatible.otf'
  let g:opts.vim_home = expand('~/vimfiles')
elseif g:sys.nvim
  let g:opts.vim_home = expand('~/.config/nvim')
endif

let g:opts.backup_dir = expand(g:opts.vim_home . '/.backup')
let g:opts.plugin_dir = expand(g:opts.vim_home . '/plugged')
let g:opts.undo_dir = expand(g:opts.backup_dir . '/undo')

if g:sys.osx
  let g:opts.font_dir = expand('~/Library/Fonts')
endif

" }

" }

" important {
set pastetoggle=<F2> " pastetoggle (sane indentation on paste)

" change mapleader <leader> to g:opts.leader,
" but retain default for local buffers
" setting here causes this to be set for any <leader> references later
" in the initialization sequence
let mapleader = g:opts.leader
let maplocalleader = "\\"
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
    call MakeDir(dest_dir)

    if !filereadable(dest_font)
      echom "Copying font from: '" . src_font_path . "' to: '" . dest_font . "'"
      call CopyFile(src_font_path, dest_font)

      if g:sys.win
        echom "Attempting to install font: " .  dest_font
        let font_name = fnamemodify(dest_font, ':t')

        call PowerShellCmd([
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
        system('fc-cache -f ' . g:sysvars.fonts)
      endif
    endif
  endif
endfunction
" }

" InstallFonts {
function! InstallFonts(src, dest)
  let src_dir = expand(a:src)
  let dest_dir = expand(a:dest)

  if isdirectory(src_dir)
    call MakeDir(dest_dir)

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

    if g:sys.win
      call MakeDir(autoload_dir)
      call PowerShellCmd([
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
function! MakeDir(path)
  if !isdirectory(expand(a:path))
    silent call mkdir(expand(a:path), 'p')
  endif
endfunction
" }

" PowerShellCmd {
function! PowerShellCmd(cmds)
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

" StatuslineCurrentHighlight {
" return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
  let name = synIDattr(synID(line('.'),col('.'),1),'name')

  if name == ''
    return ''
  else
    return '[' . name . ']'
  endif
endfunction
" }

" StatuslineLongLineWarning {
" return a list containing the lengths of the long lines in this buffer
function! s:LongLines()
  let threshold = (&tw ? &tw : 80)
  let spaces = repeat(" ", &ts)
  let line_lens = map(getline(1,'$'), 'len(substitute(v:val, "\\t", spaces, "g"))')
  return filter(line_lens, 'v:val > threshold')
endfunction

" find the median of the given array of numbers
function! s:Median(nums)
  let nums = sort(a:nums)
  let l = len(nums)

  if l % 2 == 1
    let i = (l-1) / 2
    return nums[i]
  else
    return (nums[l/2] + nums[(l/2)-1]) / 2
  endif
endfunction

" return a warning for "long lines" where "long" is either &textwidth or 80
" (if no &textwidth is set)
"
" return '' if no long lines
" return '[#x,my,$z] if long lines are found, were x is the number of long
" lines, y is the median length of the long lines and z is the length of the
" longest line
function! StatuslineLongLineWarning()
  if !exists('b:statusline_long_line_warning')
    if !&modifiable
      let b:statusline_long_line_warning = ''
      return b:statusline_long_line_warning
    endif

    let long_line_lens = s:LongLines()

    if len(long_line_lens) > 0
      let b:statusline_long_line_warning = "[" .
            \ '#' . len(long_line_lens) . "," .
            \ 'm' . s:Median(long_line_lens) . "," .
            \ '$' . max(long_line_lens) . "]"
    else
      let b:statusline_long_line_warning = ""
    endif
  endif

  return b:statusline_long_line_warning
endfunction
" }

" StatuslineTabWarning {
" return '[&et]' if &et is set wrong
" return '[mixed-indenting]' if spaces and tabs are used to indent
" return an empty string if everything is fine
function! StatuslineTabWarning()
  if !exists('b:statusline_tab_warning')
    let b:statusline_tab_warning = ''

    if !&modifiable
      return b:statusline_tab_warning
    endif

    let tabs = search('^\t', 'nw') != 0

    " find spaces that arent used as alignment in the first indent column
    let spaces = search('^ \{' . &ts . ',}[^\t]', 'nw') != 0

    if (tabs && spaces)
      let b:statusline_tab_warning = '[mixed-indenting]'
    elseif (spaces && !&et) || (tabs && &et)
      let b:statusline_tab_warning = '[&et]'
    endif
  endif

  return b:statusline_tab_warning
endfunction
" }

" StatuslineTrailingSpaceWarning {
" return '[\s]' if trailing white space is detected
" return '' otherwise
function! StatuslineTrailingSpaceWarning()
  if !exists('b:statusline_trailing_space_warning')
    if !&modifiable
      let b:statusline_trailing_space_warning = ''
      return b:statusline_trailing_space_warning
    endif

    if search('\s\+$', 'nw') != 0
      let b:statusline_trailing_space_warning = '[\s]'
    else
      let b:statusline_trailing_space_warning = ''
    endif
  endif

  return b:statusline_trailing_space_warning
endfunction
" }

" StripTrailingWhitespace {
function! StripTrailingWhitespace()
  if !exists('g:keep_trailing_whitespace')
    " prep: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " do the business:
    %s/\s\+$//e
    " clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
  endif
endfunction
" }

" }

" vim-plug {
call InstallPlug(g:opts.vim_home)
call plug#begin(g:opts.plugin_dir)

" be sensible (default settings)
Plug 'tpope/vim-sensible'

" ctags sidebar
if executable('ctags')
  Plug 'majutsushi/tagbar'
endif

" code search
if executable('ack')
  Plug 'mileszs/ack.vim'
elseif executable('ackgrep')
  let g:ackprg="ack-grep -H --nocolor --nogroup --column"
  Plug 'mileszs/ack.vim'
elseif executable('ag')
  Plug 'mileszs/ack.vim'
  let g:ackprg = 'ag --nogroup --nocolor --column --smart-case'
endif

" Dash doc integration
if g:sys.osx && isdirectory('/Applications/Dash.app')
  Plug 'rizzatti/dash.vim'
  nmap <silent> <leader>d <Plug>DashSearch
endif

" airline
Plug 'vim-airline/vim-airline' | Plug 'vim-airline/vim-airline-themes'

" async processes
Plug 'Shougo/vimproc.vim', { 'do': 'make' }

" colorschemes
Plug 'chriskempson/base16-vim' " base16 theme
Plug 'godlygeek/csapprox' " CSApprox
Plug 'junegunn/seoul256.vim' " nice dark/light color
Plug 'altercation/vim-colors-solarized' " old classic
Plug 'morhetz/gruvbox' " gruvbox
Plug 'w0ng/vim-hybrid' " dark color scheme

" common
Plug 'scrooloose/syntastic' " syntax check
Plug 'tComment' " comment helper
Plug 'terryma/vim-multiple-cursors' " multiple cursors
Plug 'tpope/vim-surround' " surround things

" css
Plug 'skammer/vim-css-color' " colors css color strings
Plug 'hail2u/vim-css3-syntax' " CSS / SCSS

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
Plug 'heavenshell/vim-jsdoc' " generate jsdoc
Plug 'elzr/vim-json' " json support
Plug 'mxw/vim-jsx' " jsx support
Plug 'moll/vim-node' " node.js support
Plug 'othree/yajs.vim', { 'for': 'javascript' } " js syntax
Plug 'othree/jspc.vim' " parameter completion

" less
Plug 'groenewege/vim-less' " LESS support

" NERDTree
Plug 'scrooloose/nerdtree' 
      \| Plug 'Xuyuanp/nerdtree-git-plugin' 
      \| Plug 'jistr/vim-nerdtree-tabs',
      \{ 'on': ['NERDTree', 'NERDTreeToggle'] }

" markdown
Plug 'vim-pandoc/vim-pandoc-syntax' " markdown syntax
if executable('npm')
  Plug 'suan/vim-instant-markdown',
        \{ 'do': 'npm install -g instant-markdown-d' }
endif

" rust
Plug 'rust-lang/rust.vim' " rust lang support

" swift
Plug 'Keithbsmiley/swift.vim' " swift syntax support

" unite and MRU features
if exists("g:plugs['vimproc.vim']")
  Plug 'Shougo/unite.vim' 
      \| Plug 'Shougo/vimfiler.vim'
      \| Plug 'Shougo/neomru.vim'
      \| Plug 'Shougo/unite-outline'
      \| Plug 'tsukkee/unite-tag'
endif

" vim-devicons and pre-patched fonts
" should be loaded after NEDTree, airline and unite
Plug 'ryanoasis/nerd-fonts' | Plug 'ryanoasis/vim-devicons'

call plug#end()
" }

" displaying text {
set number
" }

" syntax, highlighting and spelling {
set synmaxcol=2048 " no need to syntax color super long lines
set hlsearch " highlights matched search pattern
set cursorline " highlight screen line of cursor
set textwidth=80 " highlight 80 column

if exists('&colorcolumn')
  " highlight column at #
  set colorcolumn=80
  let &colorcolumn="80,".join(range(120,999),",")
else
  au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
endif
" }

" printing {
set printoptions=header:0,duplex:long,paper:letter
" }

" messages and info {
set shortmess+=filmnrxoOtT      " abbr. of messages (avoids "hit enter")
set showcmd                     " show partial cmd keys in status bar
" ruler on steroids?
set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%)
set visualbell                  " use visual bell instead of beep
" }

" tabs and indenting {
set tabstop=2 " # spaces <Tab> equals
set shiftwidth=2 " # spaces used for each (auto)indent
set softtabstop=2 " # spaces to insert for tab (<ctrl-v><TAB>)
set shiftround " round to 'shiftwidth' for "<<" and ">>"
set expandtab " expand <TAB> to spaces in Insert mode
set smartindent " do clever autoindenting
" }

" selecting text {
if has('unnamedplus')
  set clipboard=unnamed,unnamedplus " use + register for copy/paste
else
  set clipboard=unnamed " use system clipboard
endif
" }

" editing text {
set completeopt=menu,preview,longest
set showmatch " when inserting bracket, brief jump to match
set nojoinspaces " do not add second space when joining lines
" }

" folding {
if has('folding')
  set foldenable " auto fold code
  set foldmethod=marker " folding type
endif
" }

" reading and writing files {
set nobackup " do not keep a backup ~ file
" list of dirs for backup file
execute 'set backupdir=' . g:opts.backup_dir . ',.'
set autoread " auto read file modified outside of vim
" create the backup dir if it doesn't exist
if empty(glob(g:opts.backup_dir))
  silent call mkdir(g:opts.backup_dir, 'p')
endif
" }

" the swap file {
set noswapfile " do not use a swap file
" list of dirs for swap files
execute 'set directory=' . g:opts.backup_dir . ',~/tmp,.'
" }

" command line editing {
" persistent undo
if has('persistent_undo')
  set undofile
  execute 'set undodir=' . g:opts.undo_dir . ',~/tmp,.'
  " create the backup dir if it doesn't exist
  if empty(glob(g:opts.undo_dir))
    silent call mkdir(g:opts.undo_dir, 'p')
  endif
endif
" }

" executing external commands {
if g:sys.win
  " change to powershell
  "set shell=powershell.exe\ -ExecutionPolicy\ Unrestricted
  "set shellcmdflag=-Command
  "set shellpipe=>
  "set shellredir=>
elseif exists($SHELL)
  set shell=$SHELL " shell to use for ext cmds
endif
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
        \ au BufWritePre <buffer> call StripTrailingWhitespace()

  " format go docs on load
  au FileType go autocmd BufWritePre <buffer> Fmt

  " auto resize window splits
  au VimResized * exe "normal! \<C-w>="

  " set coffeescript filetype, just in case
  au BufNewFile,BufRead *.coffee set filetype=coffee
endif
" }

" GUI (here instead of .gvimrc) {
if g:sys.gui
  set lines=40

  set guioptions-=m " remove the menu
  set guioptions-=T " remove the toolbar
  set guioptions-=t " remove tear-off menus
  set guioptions+=a " visual mode is global
  set guioptions+=c " use :ex prompt instead of modal dialogs

  if g:sys.osx
    " make Mac 'Option' key behave as 'Alt'
    set mmta

    set linespace=2 " # pixel lines between characters
    set guifont=Inconsolata:h14,Monaco:h14,Consolas:h14,Courier\ New:h14,Courier:h14

    " MacVIM shift+arrow-keys behavior (required in .vimrc)
    let macvim_hig_shift_movement = 1
  else
    set guifont=Inconsolata:h14,Monaco:h14,Consolas:h14,Courier\ New:h14,Courier:h14
  endif

  if exists('transparency')
    set transparency=5 " transparency of text bg as %
  endif

  " open macvim in fullscreen
  if g:sys.macvim
    set fuoptions=maxvert,maxhorz
    "au GUIEnter * set fullscreen
  endif

  " setting these in GVim/MacVim because terminals cannot distinguish between
  " <space> and <S-space> because curses sees them the same
  nnoremap <space> <PageDown>
  nnoremap <S-space> <PageUp>

  if has('autocmd')
    " auto resize splits when window resizes
    "autocmd VimResized * wincdm =
  endif
elseif g:sys.has256
  set t_Co=256 " enable 256 colors for CSApprox warning
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

" plugin config {
" emmet-vim {
if isdirectory(expand(g:opts.plugin_dir . '/emmet-vim'))
  let g:user_emmet_mode = 'i' " only enable in insert mode
  let g:user_emmet_leader_key = '<C-y>' " default, change, if necessary
  " only enable for html,css,scss
  let g:user_emmet_install_global = 0
  autocmd FileType html,css,scss EmmetInstall
endif
" }

" fugitive {
if isdirectory(expand(g:opts.plugin_dir . '/vim-fugitive'))
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
if isdirectory(expand(g:opts.plugin_dir . '/javascript-libraries-syntax.vim'))
  " jquery,underscore,backbone,prelude,angularjs,angualrui,angularuirouter,react,flux,requirejs,sugar,jasmine,chai,handlebars
  let g:used_javascript_libs = 'jquery,underscore,angularjs,angularui,angularuirouter,react,flux,jamine,chai'
endif
" }

" nerd-fonts {
if isdirectory(expand(g:opts.plugin_dir . '/nerd-fonts'))
  let nerdfont_dir = expand(g:opts.plugin_dir . '/nerd-fonts/patched-fonts')
  let patched_font_dir = expand(nerdfont_dir . '/' . g:opts.patched_font_rel_dir)
  let patched_font = expand(patched_font_dir . '/' . g:opts.patched_font)
  let font_name = substitute(fnamemodify(patched_font, ':t:r'), ' ', '_', 'g')

  call InstallFont(patched_font, g:opts.font_dir)

  if g:sys.gui
    if g:sys.linux
      execute 'set guifont=' . font_name . '\ 14'
    else
      execute 'set guifont=' . font_name . ':h14'
    endif
  endif
endif
" }

" nerdtree {
if isdirectory(expand(g:opts.plugin_dir . '/nerdtree'))
  map <C-e> <plug>NERDTreeTabsToggle<CR>
  map <leader>e :NERDTreeFind<CR>
  nmap <leader>nt :NERDTreeFind<CR>

  let g:NERDShutUp = 1

  let NERDTreeShowBookmarks = 1
  let NERDTreeIgnore = ['\.pyc','\~$','\.swo$','\.swp$','\.git',
        \ '\.hg','\.svn','\.bzr','\.DS_Store']
  let NERDTreeChDirMode = 0
  let NERDTreeQuitOnOpen = 1
  let NERDTreeMouseMode = 2
  let NERDTreeShowHidden = 1
  let NERDTreeKeepTreeInNewTab = 1

  if isdirectory(expand('~/.vim/bundle/vim-nerdtree-tabs'))
    let g:nerdtree_tabs_open_on_gui_startup = 0 " do not show on gui start
    let g:nerdtree_tabs_focus_on_files = 1 " switch to file not nerdtree
  endif
endif
" }

" nerdtree-git-plugin {
if isdirectory(expand(g:opts.plugin_dir . '/nerdtree-git-plugin'))
  let g:NERDTreeIndicatorMapCustom = {
        \ "Modified"  : "✹",
        \ "Staged"    : "✚",
        \ "Untracked" : "✭",
        \ "Renamed"   : "➜",
        \ "Unmerged"  : "═",
        \ "Deleted"   : "✖",
        \ "Dirty"     : "✗",
        \ "Clean"     : "✔︎",
        \ "Unknown"   : "?"
        \ }
endif
" }

" syntastic {
if isdirectory(expand(g:opts.plugin_dir . '/syntastic'))
  set statusline+=%#warningmsg#
  set statusline+=%{SyntasticStatuslineFlag()}
  set statusline+=%*

  let g:syntastic_always_populate_loc_list = 1
  let g:syntastic_auto_loc_list = 1
  let g:syntastic_check_on_open = 1
  let g:syntastic_check_on_wq = 0
endif
" }

" unite {
if isdirectory(expand(g:opts.plugin_dir . '/unite.vim'))
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
if isdirectory(expand(g:opts.plugin_dir . '/vim-airline'))
  if !empty('g:opts.airline_theme')
    let g:airline_theme = g:opts.airline_theme
  endif

  if isdirectory(expand(g:opts.plugin_dir . '/nerd-fonts'))
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
if isdirectory(expand(g:opts.plugin_dir . '/vim-css-color'))
  let g:cssColorVimDoNotMessMyUpdatetime = 1
endif
" }

" vim-css3-syntax {
if isdirectory(expand(g:opts.plugin_dir . '/vim-css3-syntax'))
  highlight VendorPrefix guifg=#00ffff gui=bold
  match VendorPrefix /-\(moz\|webkit\|o\|ms\)-[a-zA-Z-]\+/
endif
" }

" vim-gitgutter {
if isdirectory(expand(g:opts.plugin_dir . '/vim-gitgutter'))
  let g:gitgutter_max_signs = 500  " default value
endif
" }

" vim-jsdoc {
if isdirectory(expand(g:opts.plugin_dir . '/vim-jsdoc'))
  " turn on detecting underscore starting functions as private convention
  let g:jsdoc_underscore_private = 1
  let g:jsdoc_enable_es6 = 1 " allow ES6 shorthand syntax

  " since v0.3 there is no longer a default mapping
  nmap <silent> <C-b> <Plug>(jsdoc)
endif
" }

" vim-json {
if isdirectory(expand(g:opts.plugin_dir . '/vim-json'))
  let g:vim_json_syntax_conceal = 0
endif
" }

" vim-jsx {
if isdirectory(expand(g:opts.plugin_dir . '/vim-jsx'))
  let g:jsx_ext_required = 0 " allows for jsx syntax in .js files
endif
" }

" vim-less {
if isdirectory(expand(g:opts.plugin_dir . '/vim-less'))
  if executable('lessc')
    nnoremap <Leader>m :w <BAR> !lessc % > %:t:r.css<CR><space>
  endif
endif
" }

" vim-multiple-cursors {
if isdirectory(expand(g:opts.plugin_dir . '/vim-multiple-cursors'))
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
" }

" colors {
if exists('&colorcolumn')
  if g:sys.has256
    highlight ColorColumn guibg=#444444 ctermbg=238
  else
    highlight ColorColumn ctermbg=7 ctermfg=1
  endif
endif

if g:sys.has256
  highlight SpellErrors guibg=#8700af ctermbg=91
else
  highlight SpellErrors ctermbg=5 ctermfg=0
endif

if exists("g:plugs['seoul256.vim']")
  let g:seoul256_light_background = 256
  let g:seoul256_background = 233
endif

if exists("g:plugs['vim-colors-solarized']")
  let g:solarized_termcolors = 256
  let g:solarized_termtrans = 1
  let g:solarized_contrast = "high"
  let g:solarized_visibility = "high"
endif

if exists("g:plugs['vim-hybrid']")
  let g:hybrid_custom_term_colors = 1
  let g:hybrid_reduced_contrast = 1 " low contrast colors
endif

if !empty($ITERM_PROFILE)
  " csapprox can look silly on iterm, do not load it
  let g:CSApprox_loaded = 1
  "let g:options.color_scheme = $ITERM_PROFILE
endif

if !empty($CONEMUBUILD)
  set term=pcansi
  set t_Co=256
  let &t_AB="\e[48;5;%dm"
  let &t_AF="\e[38;5;%dm"
endif

if g:opts.color_dark
  set background=dark
endif

" default to base16 when term is 16 color or less
if &t_Co <= 16 && exists("g:plugs['base16-vim']")
  let g:opts.color_scheme = 'base16-default'
endif

if !empty(g:opts.color_scheme)
  silent! execute 'colorscheme ' . g:opts.color_scheme
endif
" }

