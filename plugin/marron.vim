if exists('g:loaded_marron')
  finish
endif
let g:loaded_marron = 1

command! -nargs=1 -complete=file MarronSource
      \ call marron#source_script(<q-args>)

if filereadable(expand('~/.vimrc'))
  nnoremap <silent> <Plug>(marron-reload-vimrc)
        \ :<C-u>call marron#source_script('~/.vimrc')<CR>
elseif filereadable(expand('~/.vim/vimrc'))
  nnoremap <silent> <Plug>(marron-reload-vimrc)
        \ :<C-u>call marron#source_script('~/.vim/vimrc')<CR>
endif

if has('gui_running')
  if filereadable(expand('~/.gvimrc'))
    nnoremap <silent> <Plug>(marron-reload-gvimrc)
          \ :<C-u>call marron#source_script('~/.gvimrc')<CR>
  elseif filereadable(expand('~/.vim/gvimrc'))
    nnoremap <silent> <Plug>(marron-reload-gvimrc)
          \ :<C-u>call marron#source_script('~/.vim/gvimrc')<CR>
  endif
endif
