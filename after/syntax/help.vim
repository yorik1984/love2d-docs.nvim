" Help extensions for love2d-docs
" This is based on luarefvim

" Only apply syntax changes to love2d-docs.txt
if expand('%:t') != 'love2d-docs.txt'
    finish
endif

syn clear helpHyperTextJump
syn clear helpHyperTextEntry

syn match helpHyperTextJump  "\\\@<!|[#-)!+-~]\+|" contains=helpBar,helpHideLrv,helpHideLoveTextJump
syn match helpHyperTextEntry "\*[#-)!+-~]\+\*\s"he=e-1 contains=helpStar,helpHideLoveTextEntry
syn match helpHyperTextEntry "\*[#-)!+-~]\+\*$" contains=helpStar,helpHideLoveTextEntry

if has("conceal")
    syn match helpHideLrv           contained "\<lrv-" conceal
    syn match helpHideLoveTextJump  contained "\<love2d-docs-" conceal
    syn match helpHideLoveTextEntry contained "\<love2d-docs-" conceal
else
    syn match helpHideLrv           contained "\<lrv-"
    syn match helpHideLoveTextJump  contained "\<love2d-docs-"
    syn match helpHideLoveTextEntry contained "\<love2d-docs-"
endif

hi def link helpHideLrv           helpHyperTextJump
hi def link helpHideLoveTextJump  helpHyperTextJump
hi def link helpHideLoveTextEntry helpHyperTextEntry
