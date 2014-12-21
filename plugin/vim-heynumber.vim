" File: vim-heynumber.vim
" Author: frace
" Url: https://github.com/frace/vim-heynumber
" Description: Smart linenumber toggling

" Hide or change numbers on lost focus?

if exists('g:loaded_heynumber')
    finish
endif

let s:plugin_name = 'heynumber.vim'
let g:loaded_heynumber = 1

if v:version < 703 || &compatible
    echom 'Plugin ' . s:plugin_name . ': ' . 'requires at least Vim 7.3 and :set nocompatible.'
elseif v:version == 703 && !has('patch1115')
    echom 'Plugin ' . s:plugin_name . ': ' . 'Vim 7.3 requires patch1115.'
endif

" Check if a buffer is empty.
function! s:BufEmpty()
    return (line('$') == 1 && empty(getline(1))) ? 1 : 0
endfunction

" Check if a buffer is valid.
" A 'valid' buffer is shown in the bufferlist and returns no type.
function! s:BufValid()
    return (&buflisted && empty(&buftype)) ? 1 : 0
endfunction

" Set a local buffer flag inside valid buffers.
function! s:SetModeFlag(mode, buf_valid)
    if a:buf_valid
        let b:current_mode = (a:mode ==# 'insert') ? 1 :
                            \(a:mode ==# 'normal') ? 0 :
                            \''
    endif
endfunction

" :help number_relativenumber
function! s:SwitchNumberMode(number_mode)
    if a:number_mode ==# 'nonu_nornu'
        let &number = 0
        let &relativenumber = 0
    elseif a:number_mode ==# 'nu_nornu'
        let &number = 1
        let &relativenumber = 0
    elseif a:number_mode ==# 'nu_rnu'
        let &number = 1
        let &relativenumber = 1
    else
        echom "The Yada Yada"
    endif
endfunction

function! s:ManageNumbers(buf_valid, buf_empty)
    if exists('b:current_mode') && b:current_mode
        call s:SwitchNumberMode('nu_nornu')
    endif

    if !exists('b:current_mode') || !b:current_mode
        if !a:buf_empty && !a:buf_valid
            call s:SwitchNumberMode('nonu_nornu')
        elseif a:buf_empty && a:buf_valid
            call s:SwitchNumberMode('nonu_nornu')
        elseif !a:buf_empty && a:buf_valid
            call s:SwitchNumberMode('nu_rnu')
        endif
    endif
endfunction

augroup ManageNumbers
    autocmd!
    autocmd InsertEnter * call s:SetModeFlag('insert',s:BufValid())
    autocmd InsertLeave,BufWinEnter * call s:SetModeFlag('normal',s:BufValid())
    autocmd BufWinEnter,InsertEnter,InsertLeave,TextChanged,TextChangedI * call s:ManageNumbers(s:BufValid(),s:BufEmpty())
augroup end
