" vim:set ft=vim et sw=2 ts=2 sts=2 tw=78 foldmethod=marker:

" g:jw {{{
" alot of these var declarations may be redundant,
" and are here for normalizing purposes

let g:jw = {}

" g:jw.sys {{{

let g:jw.sys = {
      \ 'arch': 0,
      \ 'darwin': 0,
      \ 'linux': 0,
      \ 'unix': has('unix'),
      \ 'win16': has('win16'),
      \ 'win32': has('win32'),
      \ 'win64': has('win64'),
      \ }

if executable('uname')
  let s:system_uname = system('uname -s')

  let g:jw.sys.darwin = (s:system_uname =~? 'darwin')
  let g:jw.sys.linux = g:jw.sys.unix && (s:system_uname =~? 'linux')
  let g:jw.sys.arch = system('uname -m')
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
      \ 'fd': executable('fd'),
      \ 'fzf': executable('fzf'),
      \ 'fzy': executable('fzy'),
      \ 'go': executable('go'),
      \ 'gui': has('gui_running'),
      \ 'italics': $TERM =~? 'italic',
      \ 'iterm': !empty($ITERM_PROFILE),
      \ 'java': has('java'),
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
"       if there's no unix like env on Win,
"       then %USERPROFILE% and %USERDATA% should be used

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
      \     'scheme': 'jellybeans',
      \     'statusline': 'hybrid',
      \   },
      \   'light': {
      \     'background': 'light',
      \     'scheme': 'PaperColor',
      \     'statusline': 'papercolor',
      \   },
      \   'use': 'dark',
      \ },
      \ 'encoding': 'utf-8',
      \ 'font_dir': expand('$HOME/.fonts'),
      \ 'leader': '\<Space>',
      \ 'minimal': 0,
      \ 'path': fnamemodify(resolve(expand('<sfile>:p')), ':h'),
      \ }
let g:jw.opts.colorscheme =
      \ get(g:jw.opts.colors, g:jw.opts.colors.use, 'dark')
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

" }}}
