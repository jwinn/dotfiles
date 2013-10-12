" Clojure static {
  " Set maximum scan distance of searchpairpos(). Larger values trade
  " performance for correctness when dealing with very long forms. A value of
  " 0 will scan without limits.
  let g:clojure_maxlines = 100

  " g:clojure_fuzzy_indent_patterns and g:clojure_fuzzy_indent_blacklist are
  " lists of patterns that will be matched against the unqualified symbol at
  " the head of a list. This means that a pattern like "^foo" will match all
  " these candidates: foobar, my.ns/foobar, and #'foobar.'
  let g:clojure_fuzzy_indent = 1
  let g:clojure_fuzzy_indent_patterns = [ '^with', '^def', '^let' ]
  let g:clojure_fuzzy_indent_blacklist = [ '-fn$',
    \ '\v^with-%(meta|out-str|loading-context)$' ]

  " Some forms in Clojure are indented so that every subform is indented only
  " two spaces, regardless of 'lispwords'. If you have a custom construct that
  " should be indented in this idiosyncratic fashion, you can add your symbols
  " to the default list below.
  let g:clojure_special_indent_words =
    \ 'deftype,defrecord,reify,proxy,extend-type,extend-protocol,letfn'

  " Align subsequent lines in multiline strings to the column after the
  " opening quote, instead of the same column.
  let g:clojure_align_multiline_strings = 0
" }
