let s:path_separator = (has('win32') || has('win64')) ? '\' : '/'


" Public ---------------------------------------------------------------------
function! marron#source_script(path, ...) abort
  let quiet = get(a:000, 0, 0)
  let path = expand(a:path)
  if !filereadable(path)
    return
  elseif has('vim_starting')
    execute 'source' fnameescape(simplify(path))
    return
  endif
  let cache = s:get_cache_path(path)
  let time1 = str2nr(getftime(resolve(path)))
  let time2 = str2nr(getftime(resolve(cache)))
  if &verbose
    echomsg time1 . ';' . path
    echomsg time2 . ';' . cache
  endif
  if filereadable(cache) && time1 <= time2
    execute 'source' fnameescape(simplify(cache))
    if !quiet
      call s:indicate(path, 1)
    endif
    return
  endif
  call marron#build_cache(path)
  execute 'source' fnameescape(simplify(cache))
  if !quiet
    call s:indicate(path, 0)
  endif
endfunction

function! marron#build_cache(path) abort
  let content = map(
        \ readfile(expand(a:path)),
        \ 's:translate(v:val)'
        \)
  call writefile(content, s:get_cache_path(a:path))
endfunction


" Private --------------------------------------------------------------------
function! s:get_cache_path(path) abort
  let name = a:path
  let name = substitute(name, '[/\:]', '_', 'g')
  let root = substitute(
        \ expand(g:marron#cache_dir),
        \ s:path_separator . '$',
        \ '', ''
        \)
  return root . s:path_separator . name
endfunction

function! s:translate(line) abort
  let r = a:line
  let r = substitute(r, '\C\s*\zsset\>', 'setglobal', '')
  let r = substitute(r, '\C\<source\>', 'MarronSource', 'g')
  return r
endfunction

function! s:indicate(path, cache) abort
  let name = fnamemodify(simplify(a:path), ':~:.')
  let time = strftime('%c')
  if a:cache
    redraw | echo printf('"%s" has sourced from cache (%s)', name, time)
  else
    redraw | echo printf('"%s" has sourced (%s)', name, time)
  endif
endfunction


" Configure ------------------------------------------------------------------
if !exists('g:marron#cache_dir')
  let g:marron#cache_dir = '~/.cache/vim-marron'
endif

" Create a cache dir when missing
if !isdirectory(expand(g:marron#cache_dir))
  call mkdir(expand(g:marron#cache_dir), 'p')
endif
