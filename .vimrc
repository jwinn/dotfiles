" modeline {
" vim: set sw=2 ts=2 sts=2 et tw=78 foldmarker={,} spell:
" }
" be improved
set nocompatible

" functions { 
function! InstallNeoBundle()
  if empty(glob('~/.vim/bundle/neobundle.vim'))
    echo "Installing NeoBundle..."
    echo ""
    silent call mkdir($HOME.'/.vim/bundle', 'p')
    silent !git clone https://github.com/Shougo/neobundle.vim
          \ ~/.vim/bundle/neobundle.vim > /dev/null 2>&1
  endif
endfunction

function! CopyFile(src, dest)
  let ret = writefile(readfile(a:src, 'b'), a:dest, 'b')
  if ret == -1
    return 0
  endif
  return 1
endfunction

function! MakeFontsDir()
  if empty(g:sysvars.fonts)
    silent call mkdir(g:sysvars.fonts, 'p')
  endif
endfunction

function! InstallFonts(src, exists_glob)
  let src_dir = expand(a:src)
  let exists_path = globpath(g:sysvars.fonts, a:exists_glob)
  if isdirectory(src_dir)
    call MakeFontsDir()
    if len(split(exists_path)) == 0
      echo 'Installing fonts from: '.src_dir
      let src_font_files = split(globpath(src_dir, '**/*.[ot]tf'), '\n')
      for src_font_file in src_font_files
        let dest_font_file = g:sysvars.fonts.'/'.fnamemodify(src_font_file, ':t')
        call CopyFile(src_font_file, dest_font_file)
      endfor
      if executable('fc-cache')
        echo 'Updating font cache'
        system('fc-cache -f '.g:sysvars.fonts)
      endif
    endif
  endif
endfunction

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

" return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
  let name = synIDattr(synID(line('.'),col('.'),1),'name')

  if name == ''
    return ''
  else
    return '[' . name . ']'
  endif
endfunction

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

" determine how tab functions should be used for insert mode mappings
inoremap <tab> <C-r>=s:InsertTabWrapper()<cr>
" inoremap <S-tab> <C-n>
function! s:InsertTabWrapper()
  let col = col(".") - 1
  if !col || getline(".")[col - 1] !~ "\k"
    return "\<tab>"
  else
    return "\<C-n>"
  endfunction

  function! CleverCr()
    if pumvisible()
      if neosnippet#expandable()
        let exp = "\<Plug>(neosnippet_expand)"
        return exp . neocomplete#smart_close_popup()
      else
        return neocomplete#smart_close_popup()
      endif
    else
      return "\<CR>"
    endif
  endfunction

  function! CleverTab()
    if pumvisible()
      return "\<C-n>"
    endif
    let substr = strpart(getline('.'), 0, col('.') - 1)
    let substr = matchstr(substr, '[^ \t]*$')
    if strlen(substr) == 0
      " nothing to match on empty string
      return "\<Tab>"
    else
      " existing text matching
      if neosnippet#expandable_or_jumpable()
        return "\<Plug>(neosnippet_expand_or_jump)"
      else
        return neocomplete#start_manual_complete()
      endif
    endif
  endfunction
  " }

  " variables {
  let s:tmp_ignorecase = &ignorecase

  " temp set ignorecase
  let &ignorecase = 1

  let g:sysvars = {}
  let g:sysvars.uname =  system('echo -n "$(uname -s)"')
  let g:sysvars.osx =    (g:sysvars.uname =~ 'darwin') || has('macunix')
  let g:sysvars.linux =  (g:sysvars.uname =~ 'linux') && has('unix') && !g:sysvars.osx
  let g:sysvars.win =    has('win16') || has('win32') || has('win64')
  let g:sysvars.unix =   has('unix') && !g:sysvars.osx && !g:sysvars.win
  let g:sysvars.gui =    has('gui_running')
  let g:sysvars.macvim = has('gui_macvim')

  if g:sysvars.osx
    let g:sysvars.fonts = expand('~/Library/Fonts')
  else
    let g:sysvars.fonts = expand('~/.fonts')
  endif

  " reset changes and clean up
  let &ignorecase = s:tmp_ignorecase
  unlet s:tmp_ignorecase

  let g:bundles = {
        \ 'airline': 1,
        \ 'autocomplete': 1,
        \ 'colors': 1,
        \ 'common': 1,
        \ 'css': 1,
        \ 'git': 1,
        \ 'go': 1,
        \ 'html': 1,
        \ 'icons': 1,
        \ 'js': 1,
        \ 'less': 1,
        \ 'md': 1,
        \ 'rust': 1,
        \ 'swift': 1,
        \ 'unite': 1
        \ }

  let g:options = {
        \ 'airline_theme': '',
        \ 'color_dark': 1,
        \ 'color_scheme': 'default'
        \ }
  if isdirectory(expand('~/.vim/bundle/vim-colorschemes'))
    let g:options.color_scheme = 'jellybeans'
  endif
  if isdirectory(expand('~/.vim/bundle/vim-airline'))
    let g:options.airline_theme = 'jellybeans'
  endif
  " }

  " important {
  " allow for user customization before vimrc sourced
  if filereadable(expand('~/.vimrc.before'))
    source ~/.vimrc.before
  endif

  set pastetoggle=<F2> " pastetoggle (sane indentation on paste)

  if g:sysvars.win
    " use '.vim' instead of 'vimfiles';
    " this makes synchronization across (heterogeneous) systems easier
    set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
  endif

  " change mapleader <leader> to comma, but retain default for local buffers
  " setting here causes this to be set for any <leader> references later
  " in the initialization sequence
  if !exists('g:no_leader_change')
    let mapleader = ','
    let maplocalleader = "\\"
  endif

  " neobundle {
  silent call InstallNeoBundle()
  if has('vim_starting')
    set runtimepath+=~/.vim/bundle/neobundle.vim/
  endif
  call neobundle#begin(expand('~/.vim/bundle/'))

  " let neobundle manage NeoBundle
  NeoBundleFetch 'Shougo/neobundle.vim'

  " bundles here
  if filereadable(expand('~/.vimrc.bundles'))
    source ~/.vimrc.bundles
  endif

  call neobundle#end()

  NeoBundleCheck
  " }
  " }

  " moving around, searching and patterns {
  set whichwrap=b,s,h,l,<,>,[,]   " which cmnds wrap to another line
  set incsearch                   " incremental search
  set ignorecase                  " case insensitive search matching
  set smartcase                   " no ignore if pattern has upper-case characters
  " }

  " tags {
  " }

  " displaying text {
  set scrolljump=5                " lines to scroll when cursor leaves screen
  set scrolloff=3                 " # of screen lines to show around cursor
  set nowrap                      " do not wrap long lines
  set linebreak                   " wrap long lines in 'breakat' (not a hard break)
  set showbreak=↪\                " placed before wrapped screen lines
  if (&termencoding ==# "utf-8" || &encoding ==# "utf-8")
    let &showbreak = "\u21aa "
  endif
  set sidescrolloff=2             " min # cols to keep left/right of cursor
  set display+=lastline           " show last line, even if it doesn't fit
  set cmdheight=1                 " # of lined for the cli
  set lazyredraw                  " don't redraw while executing macros
  if (&listchars ==# "eol:$")     " strings used for list mode
    set listchars=tab:→\ ,trail:▸
    if (&termencoding ==# "utf-8" || &encoding ==# "utf-8")
      let &showbreak = "\u21aa "
      let &listchars = "tab:\u2192 ,trail:\u25b8"
    endif
  endif
  set number                      " show line #
  set norelativenumber            " do not show relative line #
  set numberwidth=1               " # cols for line #
  " }

  " syntax, highlighting and spelling {
  if has('autocmd')
    " turn on ft detection, plugins and indent
    filetype plugin indent on
  endif

  if has('syntax') && !exists('g:syntax_on')
    syntax enable                 " turn on syntax highlighting
  endif

  set synmaxcol=2048              " no need to syntax color super long lines
  set hlsearch                    " highlights matched search pattern
  set cursorline                  " highlight screen line of cursor

  if exists('&colorcolumn')
    set colorcolumn=80            " highlight column at #
  else
    au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
  endif

  " toggle spelling mistakes
  map <F7> :setlocal spell! spell?<CR>
  highlight SpellErrors guibg=red guifg=black ctermbg=red ctermfg=black
  " }

  " multiple windows {
  set laststatus=2                " show status line even if only 1 window

  " statusline setup
  set statusline=%<%f\                       " filename
  set statusline+=%w%h%m%r                   " options
  if exists('*fugitive#statusline')
    set statusline+=%{fugitive#statusline()} " git
  endif
  set statusline+=\ [%{&ff}/%Y]              " filetype
  set statusline+=\ [%{getcwd()}]            " current dir
  set statusline+=%=%-14.(%l,%c%V%)\ %p%%    " right aligned file nav info

  "set helpheight=30               " initial height of help window
  set hidden                      " keep buffer when no longer shown
  " }

  " multiple tab pages {
  " }

  " terminal {
  set ttyfast                     " term connection is fast
  " set up gui cursor to look nice
  set guicursor=n-v-c:block-Cursor-blinkon0,ve:ver35-Cursor,o:hor50-Cursor,i-ci:ver25-Cursor,r-cr:hor20-Cursor,sm:block-Cursor-blinkwait175-blinkoff150-blinkon175
  " }

  " using the mouse {
  if has('mouse')
    set mouse=a                   " list of flags for using the mouse
  endif
  set mousehide                   " hide mouse on insert mode
  " }

  " GUI (here instead of .gvimrc) {
  if g:sysvars.gui
    set lines=40

    set guioptions-=m             " remove the menu
    set guioptions-=T             " remove the toolbar
    set guioptions-=t             " remove tear-off menus
    set guioptions+=a             " visual mode is global
    set guioptions+=c             " use :ex prompt instead of modal dialogs

    if g:sysvars.osx
      " make Mac 'Option' key behave as 'Alt'
      set mmta

      set linespace=2             " # pixel lines between characters
      set guifont=Inconsolata:h14,Monaco:h14,Consolas:h14,Courier\ New:h14,Courier:h14

      " MacVIM shift+arrow-keys behavior (required in .vimrc)
      let macvim_hig_shift_movement = 1
    else
      set guifont=Inconsolata:h12,Monaco:h12,Consolas:h12,Courier\ New:h12,Courier:h12
    endif

    if exists('transparency')
      set transparency=5           " transparency of text bg as %
    endif

    " open macvim in fullscreen
    if g:sysvars.macvim
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
  elseif &term == 'xterm' || &term == 'screen'
    set t_Co=256                  " enable 256 colors for CSApprox warning
  endif
  " }

  " printing {
  set printoptions=header:0,duplex:long,paper:letter
  " }

  " messages and info {
  set shortmess+=filmnrxoOtT      " abbr. of messages (avoids "hit enter")
  set showcmd                     " show partial cmd keys in status bar
  set ruler                       " show cursor position below window
  " ruler on steroids?
  set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%)
  set visualbell                  " use visual bell instead of beep
  " }

  " selecting text {
  if has('unamedplus')
    set clipboard=unnamed,unnamedplus " use + register for copy/paste
  else
    set clipboard=unnamed         " use system clipboard
  endif
  " }

  " editing text {
  set backspace=indent,eol,start  " backspace over everything
  if (v:version > 703)
    " delete comment char on 2nd line when joining commented lines
    set formatoptions+=j
  endif
  "set completeopt+=longest        " better omni-complete menu
  set completeopt=menu,preview,longest
  set showmatch                   " when inserting bracket, brief jump to match
  set nojoinspaces                " do not add second space when joining lines
  " }

  " tabs and indenting {
  set tabstop=2                   " # spaces <Tab> equals
  set shiftwidth=2                " # spaces used for each (auto)indent
  set smarttab                    " <Tab> in indent inserts 'shiftwidth' spaces
  set softtabstop=2               " # spaces to insert for tab (<ctrl-v><TAB>)
  set shiftround                  " round to 'shiftwidth' for "<<" and ">>"
  set expandtab                   " expand <TAB> to spaces in Insert mode
  set autoindent                  " automatically set indent of a new line
  set smartindent                 " do clever autoindenting
  " }

  " folding {
  if has('folding')
    set foldenable                " auto fold code
    set foldmethod=marker         " folding type
  endif
  " }

  " diff mode {
  " }

  " mapping {
  " }

  " reading and writing files {
  set nobackup                    " do not keep a backup ~ file
  set backupdir=~/.vim/.backup,.  " list of dirs for backup file
  set autoread                    " auto read file modified outside of vim
  " create the backup dir if it doesn't exist
  if empty(glob('~/.vim/.backup'))
    silent call mkdir($HOME.'/.vim/.backup', 'p')
  endif
  " }

  " the swap file {
  set noswapfile                  " do not use a swap file
  set directory=~/.vim/.backup,~/tmp,. " list of dirs for swap files
  " }

  " command line editing {
  set history=500                 " save # cmds in history
  set wildmode=list:longest,full  " how cmd line completion works

  " file name completion ignores
  set wildignore+=*.exe,*.swp,.DS_Store

  " prevent term vim error
  if exists('&wildignorecase')
    set wildignorecase            " ignore case when completing file names
  endif
  set wildmenu                    " cmd line completion shows list of matches

  " persistent undo
  if has('persistent_undo')
    set undofile
    set undodir=~/.vim/.backup/undo,~/tmp,.
    " create the backup dir if it doesn't exist
    if empty(glob('~/.vim/.backup/undo'))
      silent call mkdir($HOME.'/.vim/.backup/undo', 'p')
    endif
  endif
  " }

  " executing external commands {
  if !g:sysvars.win
    set shell=$SHELL              " shell to use for ext cmds
  endif
  " }

  " running make and jumping to errors {
  " }

  " language specific {
  " }

  " multi-byte characters {
  set encoding=utf-8              " character encoding
  " }

  " various {
  set virtualedit=insert          " allow for cursor beyond last char
  " better unix/win compatibility
  set viewoptions=folds,options,cursor,unix,slash
  if !exists('g:no_views')
    " add exclusions to mkview and loadview
    " eg: *.*, svn-commit.tmp
    let g:skipview_files = [
          \ '\[example pattern\]' ]
  endif
  " ctags {
  set tags=./tags;/,~/.vimtags
  " }
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
    " buffer is opened; to prevent this behavior, add the following to
    " your .vimrc.before
    "   let g:no_autochdir = 1
    if !exists('g:no_autochdir')
      au BufEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | lcd %:p:h | endif
    endif

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

  " bindings {
  " exit insert mode with jj
  inoremap jj <ESC>

  " make Y consistent with C and D
  nnoremap Y y$

  " easier window moving
  map <C-j> <C-w>j<C-w>_
  map <C-k> <C-w>k<C-w>_
  map <C-l> <C-w>l<C-w>_
  map <C-h> <C-w>h<C-w>_

  " move to next row, not wrapped line
  nnoremap j gj
  nnoremap k gk

  " move to first/last of row, not line
  nnoremap 0 g0
  nnoremap $ g$

  " retain selection after (in/out)dent
  vnoremap < <gv
  vnoremap > >gv

  " easier increment/decrement
  nnoremap + <C-a>
  nnoremap - <C-x>

  " shift key fixes
  if !exists('g:no_shiftkey_fixes') && has('user_commands')
    command! -bang -nargs=* -complete=file E e<bang> <args>
    command! -bang -nargs=* -complete=file W w<bang> <args>
    command! -bang -nargs=* -complete=file Wq wq<bang> <args>
    command! -bang -nargs=* -complete=file WQ wq<bang> <args>
    command! -bang Wa wa<bang>
    command! -bang WA wa<bang>
    command! -bang Q q<bang>
    command! -bang QA qa<bang>
    command! -bang Qa qa<bang>

    cmap Tabe tabe
  endif

  " toggle search highlighting
  nmap <silent> <leader>/ :set invhlsearch<cr>

  " code folding options
  nmap <leader>f0 :set foldlevel=0<cr>
  nmap <leader>f1 :set foldlevel=1<cr>
  nmap <leader>f2 :set foldlevel=2<cr>
  nmap <leader>f3 :set foldlevel=3<cr>
  nmap <leader>f4 :set foldlevel=4<cr>
  nmap <leader>f5 :set foldlevel=5<cr>
  nmap <leader>f6 :set foldlevel=6<cr>
  nmap <leader>f7 :set foldlevel=7<cr>
  nmap <leader>f8 :set foldlevel=8<cr>
  nmap <leader>f9 :set foldlevel=9<cr>

  " fix home and end keybindings for screen, particularly on mac
  " - for some reason this fixes the arrow keys too. huh.
  map [F $
  imap [F $
  map [H g0
  imap [H g0

  " some helpers to edit mode (http://vimcasts.org/e/14)
  cnoremap %% <C-r>=expand('%:h').'/'<cr>
  map <leader>ew :e %%
  map <leader>es :sp %%
  map <leader>ev :vsp %%
  map <leader>et :tabe %%

  " maps Alt-[h,j,k,l] to resizing split window
  nnoremap <M-h> <C-w><
  nnoremap <M-j> <C-w>-
  nnoremap <M-k> <C-w>+
  nnoremap <M-l> <C-w>>
  if g:sysvars.osx
    nnoremap ˙ <C-w><
    nnoremap ∆ <C-w>-
    nnoremap ˚ <C-w>+
    nnoremap ¬ <C-w>>
  endif

  " Shift-Alt-[h,j,k,l] will resize window
  if g:sysvars.gui
    nnoremap <S-M-h> :set columns+=5<cr>
    nnoremap <S-M-j> :set lines-=1<cr>
    nnoremap <S-M-k> :set lines+=1<cr>
    nnoremap <S-M-l> :set columns-=5<cr>
    if g:sysvars.osx
      nnoremap Ó :set columns-=5<cr>
      nnoremap Ô :set lines-=1<cr>
      nnoremap  :set lines+=1<cr>
      nnoremap Ò :set columns+=5<cr>
    endif
  endif

  " map ctrl+s for saving
  noremap <silent> <C-s> :update<cr>
  vnoremap <silent> <C-s> <C-c>:update<cr>
  inoremap <silent> <C-s> <C-o>:update<cr>

  " adjust viewports to the same size
  map <leader>= <C-w>=

  " map <leader>ff to display all lines with keyword under cursor
  " and ask which one to jump to
  nmap <leader>ff [I:let nr = input("Which one: ")<bar>exe "normal " . nr ."[\t"<cr>

  " easier horizontal scrolling
  map zl zL
  map zh zH

  " <F1> + (buffer #/name fragment) to jump to it
  " also removes help binding
  map <F1> :ls<cr>:b<space>
  " }

  " colors {
  if isdirectory(expand('~/.vim/bundle/vim-colorschemes/colors'))
    let g:solarized_termcolors = 256
    let g:solarized_termtrans = 1
    let g:solarized_contrast = "high"
    let g:solarized_visibility = "high"
  endif

  if !empty($ITERM_PROFILE)
    " csapprox can look silly on iterm, do not load it
    let g:CSApprox_loaded = 1
    " let g:options.color_scheme = $ITERM_PROFILE
  endif

  if g:options.color_dark == 1
    set background=dark
  endif

  if !empty('g:options.color_scheme')
    execute 'colorscheme '.g:options.color_scheme
  endif
  " }

  " plugins {

  " omnicomplete {
  if has('autocmd') && exists('+omnifunc')
    autocmd Filetype *
          \if &omnifunc == "" |
          \  setlocal omnifunc=syntaxcomplete#Complete |
          \endif
  endif

  hi Pmenu      guifg=#000000 guibg=#F8F8F8 ctermfg=black ctermbg=Lightgray
  hi PmenuSbar  guifg=#8A95A7 guibg=#F8F8F8 gui=NONE ctermfg=darkcyan ctermbg=lightgray cterm=NONE
  hi PmenuThumb guifg=#F8F8F8 guibg=#8A95A7 gui=NONE ctermfg=lightgray ctermbg=darkcyan cterm=NONE

  " some convenient mappings, otherwise, you have to use C-N, C-P to navigate
  inoremap <expr> <Esc>   pumvisible() ? "\<C-e>" : "\<Esc>"
  inoremap <expr> <CR>    pumvisible() ? "\<C-y>" : "\<CR>"
  inoremap <expr> <Down>  pumvisible() ? "\<C-n>" : "\<Down>"
  inoremap <expr> <Up>    pumvisible() ? "\<C-p>" : "\<Up>"
  inoremap <expr> <C-d>   pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<C-d>"
  inoremap <expr> <C-u>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<C-u>"

  " automatically open and close the popup menu / preview window
  au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
  set completeopt=menu,preview,longest
  " }

  " ctrlp.vim {
  if isdirectory(expand('~/.vim/bundle/ctrlp.vim'))
    let g:ctrlp_working_path_mode = 'ra'
    nnoremap <silent> <D-t> :CtrlP<CR>
    nnoremap <silent> <D-r> :CtrlPMRU<CR>
    let g:ctrlp_custom_ignore = {
          \ 'dir':  '\.git$\|\.hg$\|\.svn$',
          \ 'file': '\.exe$\|\.so$\|\.dll$\|\.pyc$' }

    " On Windows use 'dir' as fallback command.
    if g:sysvars.win
      let s:ctrlp_fallback = 'dir %s /-n /b /s /a-d'
    elseif executable('ag')
      let s:ctrlp_fallback = 'ag %s --nocolor -l -g ""'
    elseif executable('ack-grep')
      let s:ctrlp_fallback = 'ack-grep %s --nocolor -f'
    elseif executable('ack')
      let s:ctrlp_fallback = 'ack %s --nocolor -f'
    else
      let s:ctrlp_fallback = 'find %s -type f'
    endif

    let g:ctrlp_user_command = {
          \ 'types': {
          \ 1: ['.git', 'cd %s && git ls-files . --cached --exclude-standard --others'],
          \ 2: ['.hg', 'hg --cwd %s locate -I .'],
          \ },
          \ 'fallback': s:ctrlp_fallback
          \ }
  endif
  " }

  " emmet-vim {
  if isdirectory(expand('~/.vim/bundle/emmet-vim'))
    let g:user_emmet_mode = 'i' " only enable in insert mode
    let g:user_emmet_leader_key = '<C-y>' " default, change, if necessary
    " only enable for html,css,scss
    let g:user_emmet_install_global = 0
    autocmd FileType html,css,scss EmmetInstall
  endif
  " }

  " fugitive {
  if isdirectory(expand('~/.vim/bundle/vim-fugitive'))
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
  if isdirectory(expand('~/.vim/bundle/javascript-libraries-syntax.vim'))
    " jquery,underscore,backbone,prelude,angularjs,angualrui,react,flux,requirejs,sugar,jasmine,chai,handlebars
    let g:used_javascript_libs = 'jquery,underscore,angularjs,react,flux,chai'
  endif
  " }

  " minibufexpl {
  let g:miniBufExplMapWindowNavVim = 1
  let g:miniBufExplMapWindowNavArrows = 1
  let g:miniBufExplMapCTabSwitchBufs = 1
  let g:miniBufExplModSelTarget = 1
  " colors
  hi MBENormal               guifg=#808080 guibg=fg
  hi MBEChanged              guifg=#CD5907 guibg=fg
  hi MBEVisibleNormal        guifg=#5DC2D6 guibg=fg
  hi MBEVisibleChanged       guifg=#F1266F guibg=fg
  hi MBEVisibleActiveNormal  guifg=#A6DB29 guibg=fg
  hi MBEVisibleActiveChanged guifg=#F1266F guibg=fg
  " }

  " nerdtree {
  if isdirectory(expand('~/.vim/bundle/nerdtree'))
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

  " neocomplete.vim {
  if isdirectory(expand('~/.vim/bundle/neocomplete.vim'))
    " Disable AutoComplPop.
    let g:acp_enableAtStartup = 0
    " Use neocomplete.
    let g:neocomplete#enable_at_startup = 1
    " Use smartcase.
    let g:neocomplete#enable_smart_case = 1
    " Set maximum items to display.
    let g:neocomplete#max_list = 15
    " Set minimum syntax keyword length.
    let g:neocomplete#sources#syntax#min_keyword_length = 3
    let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'
    let g:neocomplete#enable_auto_delimiter = 1
    let g:neocomplete#force_overwrite_completefunc = 1

    " Define dictionary.
    let g:neocomplete#sources#dictionary#dictionaries = {
          \ 'default' : '',
          \ 'vimshell' : $HOME.'/.vimshell_hist',
          \ 'scheme' : $HOME.'/.gosh_completions'
          \ }

    " Define keyword.
    if !exists('g:neocomplete#keyword_patterns')
      let g:neocomplete#keyword_patterns = {}
    endif
    let g:neocomplete#keyword_patterns['default'] = '\h\w*'

    " Plugin key-mappings.

    inoremap <expr><C-g> neocomplete#undo_completion()
    inoremap <expr><C-l> neocomplete#complete_common_string()

    " Recommended key-mappings.
    " <CR> close popup and save indent or expand snippet
    imap <expr> <CR> CleverCr()

    " <s-CR>: close popup and save indent.
    inoremap <expr><s-CR> pumvisible() 
          \ ? neocomplete#smart_close_popup()"\<CR>" : "\<CR>"

    " <C-h>, <BS>: close popup and delete backword char.
    inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
    inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
    inoremap <expr><C-y> neocomplete#close_popup()
    " inoremap <expr><C-e> neocomplete#cancel_popup()

    " <TAB>: completion.
    inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
    inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"

    imap <expr> <Tab> CleverTab()

    " Enable omni completion.
    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
    autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
    autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

    " Enable heavy omni completion.
    if !exists('g:neocomplete#sources#omni#input_patterns')
      let g:neocomplete#sources#omni#input_patterns = {}
    endif
    let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
    let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
    let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
    let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
    let g:neocomplete#sources#omni#input_patterns.ruby = '[^. *\t]\.\h\w*\|\h\w*::'
  endif
  " }

  " neosnippet.vim {
  if isdirectory(expand('~/.vim/bundle/neosnippet.vim'))
    " Plugin key-mappings.
    imap <C-k> <Plug>(neosnippet_expand_or_jump)
    smap <C-k> <Plug>(neosnippet_expand_or_jump)
    xmap <C-k> <Plug>(neosnippet_expand_target)

    " SuperTab like snippets behavior.
    imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
          \ "\<Plug>(neosnippet_expand_or_jump)"
          \: pumvisible() ? "\<C-n>" : "\<TAB>"
    smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
          \ "\<Plug>(neosnippet_expand_or_jump)"
          \: "\<TAB>"

    " For snippet_complete marker.
    if has('conceal')
      set conceallevel=2 concealcursor=niv
    endif

    " Enable snipMate compatibility feature.
    let g:neosnippet#enable_snipmate_compatibility = 1

    " Tell Neosnippet about the other snippets
    let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'

    " Enable neosnippets when using go
    let g:go_snippet_engine = "neosnippet"

    " Disable the neosnippet preview candidate window
    " When enabled, there can be too much visual noise
    " especially when splits are used.
    set completeopt-=preview
  endif
  " }

  " syntastic {
  if isdirectory(expand('~/.vim/bundle/syntastic'))
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
  if isdirectory(expand('~/.vim/bundle/unite.vim'))
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

  " ultisnips {
  if isdirectory(expand('~/.vim/bundle/vim-snippets/UltiSnips'))
    let g:UltiSnipsSnippetsDir = '~/.vim/bundle/vim-snippets/UltiSnips'
  endif
  " }

  " vim-airline {
  if isdirectory(expand('~/.vim/bundle/vim-airline'))
    if !empty('g:options.airline_theme')
      let g:airline_theme = g:options.airline_theme
    endif

    if isdirectory(expand('~/.vim/bundle/fonts'))
      call InstallFonts('~/.vim/bundle/fonts', '*Powerline*.[ot]tf')
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
  if isdirectory(expand('~/.vim/bundle/vim-css-color'))
    let g:cssColorVimDoNotMessMyUpdatetime = 1
  endif
  " }

  " vim-css3-syntax {
  if isdirectory(expand('~/.vim/bundle/vim-css3-syntax'))
    highlight VendorPrefix guifg=#00ffff gui=bold
    match VendorPrefix /-\(moz\|webkit\|o\|ms\)-[a-zA-Z-]\+/
  endif
  " }

  " vim-jsdoc {
  if isdirectory(expand('~/.vim/bundle/vim-jsdoc'))
    " turn on detecting underscore starting functions as private convention 
    let g:jsdoc_underscore_private = 1
    let g:jsdoc_allow_shorthand = 1 " allow ES6 shorthand syntax
  endif
  " }

  " vim-json {
  if isdirectory(expand('~/.vim/bundle/vim-json'))
    let g:vim_json_syntax_conceal = 0
  endif
  " }

  " vim-jsx {
  if isdirectory(expand('~/.vim/bundle/vim-jsx'))
    let g:jsx_ext_required = 0 " allows for jsx syntax in .js files
  endif
  " }

  " vim-less {
  if isdirectory(expand('~/.vim/bundle/vim-less'))
    if executable('lessc')
      nnoremap <Leader>m :w <BAR> !lessc % > %:t:r.css<CR><space>
    endif
  endif
  " }

  " vim-multiple-cursors {
  if isdirectory(expand('~/.vim/bundle/vim-multiple-cursors'))
    let g:multi_cursor_start_key = '<C-n>'
    let g:multi_cursor_next_key = '<C-n>'
    let g:multi_cursor_prev_key = '<C-p>'
    let g:multi_cursor_skip_key = '<C-x>'
    let g:multi_cursor_quit_key = '<Esc>'

    let g:multi_cursor_exit_from_visual_mode = 1
    let g:multi_cursor_exit_from_insert_mode = 1

    highlight multiple_cursors_cursor term=reverse cterm=reverse gui=reverse
    highlight link multiple_cursors_visual Visual
  endif
  " }

  " vim-webdevicons {
  if isdirectory(expand('~/.vim/bundle/vim-webdevicons'))
    let wdi_fontdir = '~/.vim/bundle/nerd-filetype-glyphs-fonts-patcher'
    if isdirectory(expand(wdi_fontdir))
      call InstallFonts(wdi_fontdir.'/patched-fonts', '*Nerd File*.[ot]tf')
    endif

    let g:webdevicons_enable = 1
    let g:webdevicons_enable_nerdtree = 1
    let g:webdevicons_enable_airline_tabline = 1
    let g:webdevicons_enable_airline_statusline = 1
    let g:WebDevIconsUnicodeDecorateFileNodes = 1
    let g:WebDevIconsUnicodeGlyphDoubleWidth = 1
    let g:webdevicons_conceal_nerdtree_brackets = 1
    let g:WebDevIconsNerdTreeAfterGlyphPadding = '  '
    " let g:WebDevIconsUnicodeDecorateFileNodesDefaultSymbol = 'ƛ'
    let g:WebDevIconsUnicodeDecorateFolderNodes = 0
    let g:WebDevIconsUnicodeDecorateFolderNodesExactMatches = 1
    " let g:WebDevIconsUnicodeDecorateFolderNodeDefaultSymbol = 'ƛ'
  endif
  " }

  if g:sysvars.gui
    if exists('g:bundles.icons')
      set guifont=Sauce\ Code\ Powerline\ Plus\ Nerd\ File\ Types\ Mono:h14
    elseif exists('g:bundles.airline')
      set guifont=Sauce\ Code\ Powerline:h14
    endif
  endif

  " }

  " allow for user customization after vimrc sourced
  if filereadable(expand("~/.vimrc.after"))
    source ~/.vimrc.after
  endif
