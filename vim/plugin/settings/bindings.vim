
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
if !exists("g:no_shiftkey_fixes") && has("user_commands")
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

" adjust viewports to the same size
map <leader>= <C-w>=

" maps Alt-[h,j,k,l] to resizing split window
nnoremap <M-h> <C-w><
nnoremap <M-j> <C-w>-
nnoremap <M-k> <C-w>+
nnoremap <M-l> <C-w>>
if has("macunix")
  nnoremap ˙ <C-w><
  nnoremap ∆ <C-w>-
  nnoremap ˚ <C-w>+
  nnoremap ¬ <C-w>>
endif

" Shift-Alt-[h,j,k,l] will resize window
if has("gui_running")
  nnoremap <S-M-h> :set columns+=5<cr>
  nnoremap <S-M-j> :set lines-=1<cr>
  nnoremap <S-M-k> :set lines+=1<cr>
  nnoremap <S-M-l> :set columns-=5<cr>
  if has("macunix")
    nnoremap Ó :set columns-=5<cr>
    nnoremap Ô :set lines-=1<cr>
    nnoremap  :set lines+=1<cr>
    nnoremap Ò :set columns+=5<cr>
  endif
endif

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
