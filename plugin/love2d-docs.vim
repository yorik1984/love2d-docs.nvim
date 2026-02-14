" Vim plugin for LÖVE syntax highlighting and help file
" original:    https://github.com/davisdude/vim-love-docs
" fork:        https://github.com/yorik1984/love2d-docs.nvim
" Last Change: Feb 2026
" Maintainer:  Davis Claiborne <davisclaib@gmail.com>
" Modified :   yorik1984 <yorik1984@gmail.com>
" License:     MIT

let s:save_cpo = &cpo

if exists( 'g:lovedocs_loaded' )
	finish
endif
let g:lovedocs_loaded = 1

" Allow custom colors for LOVE functions
if !exists( 'g:lovedocs_colors_love' )
	let g:lovedocs_colors_love = 'guifg=#E54D95 ctermfg=162 gui=bold cterm=bold'
endif

if !exists( 'g:lovedocs_colors_module' )
	let g:lovedocs_colors_module = 'guifg=#E54D95 ctermfg=162'
endif

if !exists( 'g:lovedocs_colors_function' )
	let g:lovedocs_colors_function = 'guifg=#2FA8DC ctermfg=38'
endif

if !exists( 'g:lovedocs_colors_type' )
	let g:lovedocs_colors_type = 'guifg=#2FA8DC ctermfg=38'
endif

if !exists( 'g:lovedocs_colors_callback' )
	let g:lovedocs_colors_callback = 'guifg=#2FA8DC ctermfg=38'
endif

if !exists( 'g:lovedocs_colors_conf' )
	let g:lovedocs_colors_conf = 'guifg=#2FA8DC ctermfg=38'
endif

" Reset compatibility
let &cpo = s:save_cpo
