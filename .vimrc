" Nathan's vimrc file.
"
" Maintainer:   Nathan Jent <nathanjent@gmail.com>

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

source $VIMRUNTIME/defaults.vim

colorscheme industry

let s:is_win = has('win32') || has('win64')
let s:is_python = has('python_compiled') || has('python3_compiled')

if s:is_win
    set runtimepath^=$HOME/.vim
    set runtimepath+=$HOME/.vim/after
    set packpath^=$HOME/.vim
    set packpath+=$HOME/.vim/after
endif
    
" Basic settings {{{
set autoindent              " Indent according to previous line.
set expandtab               " Use spaces instead of tabs.
set tabstop     =4          " Spaces per tab
set softtabstop =4          " Tab key indents by 4 spaces.
set shiftwidth  =4          " >> indents by 4 spaces.
set shiftround              " >> indents to next multiple of 'shiftwidth'.

set hidden                  " Switch between buffers without having to save first.
set showmatch               " Highlight matching [{()}]
if !s:is_win
    set laststatus  =2          " Always show statusline.
endif
set display     =lastline   " Show as much as possible of the last line.

set showmode                " Show current mode in command-line.

set incsearch               " Highlight while searching with / or ?.
set hlsearch                " Keep matches highlighted.

set ttyfast                 " Faster redrawing.
set lazyredraw              " Only redraw when necessary.

set splitbelow              " Open new windows below the current window.
set splitright              " Open new windows right of the current window.

"set cursorline              " Highlight the current line
set wrapscan                " Searches wrap around end-of-file.
set report      =0          " Always report changed lines.
set synmaxcol   =200        " Only highlight the first 200 columns.

set list                    " Show non-printable characters.

set number                  " Include the line number column
set cpoptions+=n            " Wrapped lines use line number column; example->--------------------------------------------------------------------------------------------------------------------------->

set foldenable              " Enable folding
set foldlevelstart=5        " Open folds to this level for new buffer
set foldnestmax=10          " 10 nested fold max

set noshowmatch             " Showmatch significantly slows down omnicomplete when the first match contains parentheses.
set completeopt=longest,menuone,preview
set splitbelow              " New split window below current
if s:is_win
    set wrapmargin=1        "Number of characters from the right where wrapping starts
endif

filetype plugin on
filetype plugin indent on

" Put all swp in same directory
set directory^=$HOME/.vim/swapfiles//
" }}}

" Sometimes utf-8 is required {{{
if has('multi_byte') && &encoding ==# 'utf-8'
  let &listchars = 'tab:? ,extends:?,precedes:?,nbsp:±'
else
  let &listchars = 'tab:> ,extends:>,precedes:<,nbsp:.'
endif
" }}}

" Highlight repeated lines {{{
command! -range=% HighlightRepeats <line1>,<line2>call HighlightRepeats()
function! HighlightRepeats() range
  let lineCounts = {}
  let lineNum = a:firstline
  while lineNum <= a:lastline
    let lineText = getline(lineNum)
    if lineText != ""
      let lineCounts[lineText] = (has_key(lineCounts, lineText) ? lineCounts[lineText] : 0) + 1
    endif
    let lineNum = lineNum + 1
  endwhile
  exe 'syn clear Repeat'
  for lineText in keys(lineCounts)
    if lineCounts[lineText] >= 2
      exe 'syn match Repeat "^' . escape(lineText, '".\^$*[]') . '$"'
    endif
  endfor
endfunction
" }}}

let s:vimfiles = expand('$HOME/.vim')

" Netrw Nerdtree like settings
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_winsize = 25
let g:netrw_dirhistmax = 0

" Plugins {{{
if s:is_python
    packadd! editorconfig-vim
    let g:EditorConfig_exec_path = s:vimfiles . '/pack/submodules/start/editorconfig-vim/plugin/editor-core-py/main.py'

    packadd! nvim-yarp

    set encoding=utf-8 " Required for plugin
    packadd! vim-hug-neovim-rpc
endif

packadd! vim-snippets
if s:is_python
    packadd! ultisnips
    let g:UltiSnipsExpandTrigger='<c-e>' " <tab> conflicts with YouCompleteMe
    " let g:UltiSnipsJumpForwardTrigger='<c-b>'
    " let g:UltiSnipsJumpBackwardTrigger="<c-z>"
    " If you want :UltiSnipsEdit to split your window.
    let g:UltiSnipsEditSplit="vertical"
endif

packadd! vim-polyglot " Support for many languages

" CoC {{{
packadd! coc.nvim

let g:coc_global_extensions=[
            \ 'coc-json',
            \ 'coc-tsserver',
            \ 'coc-html',
            \ 'coc-css',
            \ 'coc-java',
            \ 'coc-rls',
            \ 'coc-yaml',
            \ 'coc-highlight',
            \ 'coc-svg',
            \ 'coc-omnisharp',
            \ 'coc-snippets',
            \ ]
if s:is_win
    let g:coc_global_extensions+=[
                \ 'coc-powershell',
                \ ]
endif

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

set cmdheight=2

" Smaller updatetime for CursorHold & CursorHoldI
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

" Use `[c` and `]c` to navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup cocnvimgroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Using CocList
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList --number-select diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>
" }}}

if s:is_win
    packadd! windows-powershell-syntax-plugin " Support for Powershell
endif
" }}}

silent! helptags ALL

finish " break here

" vim:ts=4:sw=4:ai:foldmethod=marker:foldlevel=0
