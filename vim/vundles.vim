" modeline {
" vim: set sw=2 ts=2 sts=2 et tw=78 foldmarker={,} spell:
"
" If you like some of these, plese refer to github/spf13-vim
" as that distribution is a large base of this one,
" each piece added from the spf13 distro when learned by me
" }

" setup {
  filetype off                    " required for vundle
  set rtp+=~/.vim/bundle/vundle/  " add vundle to runtimepath
  call vundle#rc()                " start vundle
" }

" Vundles {
  " Dependencies {
    " let vundle manage itself
    Bundle 'gmarik/vundle'
    Bundle 'MarcWeber/vim-addon-mw-utils'
    Bundle 'tomtom/tlib_vim'
    if executable('ack-grep')
        let g:ackprg="ack-grep -H --nocolor --nogroup --column"
        Bundle 'mileszs/ack.vim'
    elseif executable('ack')
        Bundle 'mileszs/ack.vim'
    elseif executable('ag')
        Bundle 'mileszs/ack.vim'
        let g:ackprg = 'ag --nogroup --nocolor --column --smart-case'
    endif
  " }

  " allow for user vundle customization before other vundles are added
  if filereadable(expand("~/.vim/vundles.before.vim"))
    source ~/.vim/vundles.before.vim
  endif

  "Bundles {
    " set the default vundle sets to install
    if !exists("g:vundle_groups")
      let g:vundle_groups = [ "general", "programming", "neocomplcache", "codeformat", "javascript", "html", "node", "java", "ruby", "php", "python", "lisp", "go", "haskell", "twig", "misc" ]
    endif

    " allow override of all vundles
    " could also set g:vundle_groups to an empty set
    "   let g:override_vundles = 1
    " in your .vim/vundles.before.vim
    if !exists("g:override_vundles")

    " General {
      if count(g:vundle_groups, "general")
        Bundle 'tpope/vim-surround'
        Bundle 'tpope/vim-abolish.git'
        Bundle 'mileszs/ack.vim'
        Bundle 'scrooloose/nerdtree'
        Bundle 'jistr/vim-nerdtree-tabs'
        Bundle 'spf13/vim-autoclose'
        Bundle 'kien/ctrlp.vim'
        Bundle 'mbbill/undotree'
        Bundle 'nathanaelkane/vim-indent-guides'
        Bundle 'myusuf3/numbers.vim'
        Bundle 'godlygeek/csapprox'
        Bundle 'Lokaltog/vim-easymotion'
        Bundle 'airblade/vim-gitgutter'
        Bundle 'vim-scripts/sessionman.vim'
        Bundle 'matchit.zip'
        Bundle 'altercation/vim-colors-solarized'
        Bundle 'spf13/vim-colors'
        Bundle 'flazz/vim-colorschemes'
        Bundle 'chriskempson/base16-vim'
        Bundle 'goatslacker/mango.vim'

        if (has("python") || has("python3")) && exists('g:use_powerline') && !exists('g:use_old_powerline')
          Bundle 'Lokaltog/powerline', {'rtp':'/powerline/bindings/vim'}
        elseif exists('g:use_powerline') && exists('g:use_old_powerline')
          Bundle 'Lokaltog/vim-powerline'
        else
          Bundle 'bling/vim-airline'
        endif

        if !exists("g:no_views")
          Bundle 'vim-scripts/restore_view.vim'
        endif
      endif
    " }

    " General Programming {
      if count(g:vundle_groups, "programming")
        " pick one of the checksyntax, jslint, or syntastic
        Bundle 'scrooloose/syntastic'
        Bundle 'scrooloose/nerdcommenter'
        Bundle 'tpope/vim-fugitive'
        Bundle 'godlygeek/tabular'
        Bundle 'mattn/zencoding-vim'
        Bundle 'mattn/webapi-vim'
        Bundle 'mattn/gist-vim'
        if executable("ctags")
          Bundle 'majutsushi/tagbar'
        endif
      endif
    " }

    " Snippets and AutoComplete {
      if count(g:vundle_groups, "snipmate")
        Bundle 'honza/vim-snippets'
        Bundle 'garbas/vim-snipmate'

        " source support_function.vim to support vim-snippets
        if filereadable(expand("~/.vim/bundle/vim-snippets/snippets/support_functions.vim"))
          source ~/.vim/bundle/vim-snippets/snippets/support_functions.vim
        endif
      elseif count(g:vundle_groups, "neocomplcache")
        Bundle 'Shougo/neocomplcache'
        Bundle 'Shougo/neosnippet'
        Bundle 'honza/vim-snippets'
      endif
    " }

    " Code Formatting {
      if count(g:vundle_groups, "codeformat")
        Bundle 'einars/js-beautify'
        Bundle 'maksimr/vim-jsbeautify'
        "Bundle 'Chiel92/vim-autoformat'
      endif
    " }

    " Javascript {
      if count(g:vundle_groups, "javascript")
        Bundle 'elzr/vim-json'
        Bundle 'groenewege/vim-less'
        Bundle 'pangloss/vim-javascript'
        Bundle 'briancollins/vim-jst'
        Bundle 'kchmck/vim-coffee-script'
      endif
    " }

    " HTML {
      if count(g:vundle_groups, "html")
        Bundle 'amirh/HTML-AutoCloseTag'
        Bundle 'hail2u/vim-css3-syntax'
        Bundle 'tpope/vim-haml'
      endif
    " }

    " Node {
      if count(g:vundle_groups, "node")
        Bundle 'digitaltoad/vim-jade'
        Bundle 'wavded/vim-stylus'
      endif
    " }

    " Java {
      if count(g:vundle_groups, "java")
        Bundle 'derekwyatt/vim-scala'
        Bundle 'derekwyatt/vim-sbt'
      endif
    " }

    " Ruby {
      if count(g:vundle_groups, "ruby")
        Bundle 'tpope/vim-rails'
        Bundle 'tpope/vim-bundler'
        Bundle 'vim-ruby/vim-ruby'
      endif
    " }

    " PHP {
      if count(g:vundle_groups, "php")
        Bundle 'spf13/PIV'
        Bundle 'arnaud-lb/vim-php-namespace'
      endif
    " }

    " Python {
      if count(g:vundle_groups, "python")
        " pick either python-mode or pyflakes & pydoc
        Bundle 'klen/python-mode'
        Bundle 'python.vim'
        Bundle 'python_match.vim'
        Bundle 'pythoncomplete'
      endif
    " }

    " Lisp {
      if count(g:vundle_groups, "lisp")
        Bundle 'tpope/vim-fireplace'
        Bundle 'tpope/vim-classpath'
        Bundle 'guns/vim-clojure-static'
        Bundle 'vim-scripts/slimv.vim'
      endif
    " }

    " Go {
      if count(g:vundle_groups, "go")
        Bundle 'jnwhiteh/vim-golang'
        Bundle 'spf13/vim-gocode'
      endif
    " }

    " Haskell {
      if count(g:vundle_groups, "haskell")
        Bundle 'travitch/hasksyn'
        Bundle 'dag/vim2hs'
        Bundle 'Twinside/vim-haskellConceal'
        Bundle 'lukerandall/haskellmode-vim'
        Bundle 'ujihisa/neco-ghc'
        Bundle 'eagletmt/ghcmod-vim'
        Bundle 'Shougo/vimproc'
        Bundle 'adinapoli/cumino'
        Bundle 'bitc/vim-hdevtools'
      endif
    " }

    " HTML Twig {
      if count(g:vundle_groups, "twig")
        Bundle 'beyondwords/vim-twig'
      endif
    " }

    " Miscellaneous {
      if count(g:vundle_groups, "misc")
        Bundle 'tpope/vim-cucumber'
        Bundle 'tpope/vim-markdown'
        Bundle 'spf13/vim-preview'
        Bundle 'quentindecock/vim-cucumber-align-pipes'
        Bundle 'Puppet-Syntax-Highlighting'
      endif
    " }
    endif
  " }

  " allow for user vundle customization after other vundles are added
  if filereadable(expand("~/.vim/vundles.after.vim"))
    source ~/.vim/vundles.after.vim
  endif
" }
